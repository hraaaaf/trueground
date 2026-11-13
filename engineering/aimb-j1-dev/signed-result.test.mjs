import {test} from 'node:test';
import assert from 'node:assert/strict';
import {generateKeyPairSync,sign} from 'node:crypto';
import {SignedResultVerifier,resultSigningBytes} from './signed-result.mjs';

const keys=generateKeyPairSync('rsa',{modulusLength:2048});
let now=1_800_000_000_000;
const nonce=n=>`nonce_fixture_${String(n).padStart(16,'0')}`;
function envelope(overrides={}){
 const x={device_id:'fixture-device',expires_at:now+90000,issued_at:now,nonce:nonce(1),purpose:'dev_read_result',request_id:'fixture-request',result:{files:['a.txt'],sha256:'a'.repeat(64)}};
 Object.assign(x,overrides);x.signature=sign('RSA-SHA256',resultSigningBytes(x),keys.privateKey).toString('base64url');return x;
}
function verifier(opts={}){return new SignedResultVerifier({publicKey:keys.publicKey,deviceId:'fixture-device',now:()=>now,...opts})}
test('RSA-SHA256 signed result is accepted for exact fixture request and device',()=>{const out=verifier().verify(envelope(),{requestId:'fixture-request'});assert.equal(out.result.files[0],'a.txt')});
test('changed payload, wrong request, wrong device and purpose are rejected',()=>{
 const bad=envelope();bad.result.files=['outside.txt'];assert.throws(()=>verifier().verify(bad,{requestId:'fixture-request'}),/RESULT_SIGNATURE_INVALID/);
 assert.throws(()=>verifier().verify(envelope(),{requestId:'other'}),/RESULT_REQUEST_MISMATCH/);
 assert.throws(()=>verifier().verify(envelope({device_id:'other-device'}),{requestId:'fixture-request'}),/RESULT_DEVICE_MISMATCH/);
 assert.throws(()=>verifier().verify(envelope({purpose:'other'}),{requestId:'fixture-request'}),/RESULT_PURPOSE_MISMATCH/);
});
test('expired, future-dated and overlong result attestations are rejected',()=>{
 assert.throws(()=>verifier().verify(envelope({expires_at:now}),{requestId:'fixture-request'}),/RESULT_EXPIRED/);
 assert.throws(()=>verifier().verify(envelope({issued_at:now+30001}),{requestId:'fixture-request'}),/RESULT_ISSUED_AT_INVALID/);
 assert.throws(()=>verifier().verify(envelope({expires_at:now+120001}),{requestId:'fixture-request'}),/RESULT_TTL_INVALID/);
});
test('nonce replay is denied until signed result expiry, then bounded cache reclaims it',()=>{
 const v=verifier(),x=envelope();v.verify(x,{requestId:'fixture-request'});assert.throws(()=>v.verify(x,{requestId:'fixture-request'}),/RESULT_REPLAY/);now=x.expires_at;assert.throws(()=>v.verify(x,{requestId:'fixture-request'}),/RESULT_EXPIRED/);assert.equal(v.replayEntries,0);
});
test('replay cache capacity fails closed while entries are still valid',()=>{
 const v=verifier({maxReplayEntries:1});v.verify(envelope({nonce:nonce(2)}),{requestId:'fixture-request'});assert.throws(()=>v.verify(envelope({nonce:nonce(3)}),{requestId:'fixture-request'}),/RESULT_REPLAY_CAPACITY/);
});
test('verification policy caps cannot be weakened by the caller and returned result is deeply immutable',()=>{
 assert.throws(()=>verifier({maxLifetimeMs:120001}),/RESULT_TTL_CAP_INVALID/);
 assert.throws(()=>verifier({maxBytes:65537}),/RESULT_SIZE_CAP_INVALID/);
 const out=verifier().verify(envelope(),{requestId:'fixture-request'});
 assert.throws(()=>{out.result.files.push('mutated.txt')},/read only|extensible|frozen/i);
 assert.deepEqual(out.result.files,['a.txt']);
 assert.throws(()=>verifier().verify(envelope(),{requestId:'fixture-request',clockSkewMs:900000}),/CLOCK_SKEW_POLICY_INVALID/);
});
test('malformed nonce, signature and oversize result fail closed',()=>{
 assert.throws(()=>verifier().verify(envelope({nonce:'short'}),{requestId:'fixture-request'}),/RESULT_NONCE_INVALID/);
 const badSignature=envelope();badSignature.signature='not-base64url!';assert.throws(()=>verifier().verify(badSignature,{requestId:'fixture-request'}),/RESULT_SIGNATURE_FORMAT/);
 const v=verifier({maxBytes:1024});assert.throws(()=>v.verify(envelope({result:{big:'x'.repeat(2000)}}),{requestId:'fixture-request'}),/RESULT_TOO_LARGE/);
 let deep='leaf';for(let i=0;i<40;i++)deep={next:deep};assert.throws(()=>verifier().verify(envelope({result:deep}),{requestId:'fixture-request'}),/RESULT_NESTING_LIMIT/);
});
