import {constants,createPublicKey,verify} from 'node:crypto';

const MAX_RESULT_BYTES=64*1024;
const MAX_LIFETIME_MS=120_000;
const NONCE=/^[A-Za-z0-9_-]{16,64}$/;
const own=(x,k)=>Object.prototype.hasOwnProperty.call(x,k);
const need=(ok,code)=>{if(!ok)throw Error(code)};
function deepFreeze(value,depth=0){need(depth<=32,'RESULT_NESTING_LIMIT');if(value&&typeof value==='object'){for(const v of Object.values(value))deepFreeze(v,depth+1);Object.freeze(value)}return value}
function canonical(value,state={nodes:0},depth=0){
 need(depth<=32,'RESULT_NESTING_LIMIT');need(++state.nodes<=10000,'RESULT_NODE_LIMIT');
 if(value===null||typeof value==='string'||typeof value==='boolean')return JSON.stringify(value);
 if(typeof value==='number'){need(Number.isFinite(value),'RESULT_NONFINITE_NUMBER');return JSON.stringify(value)}
 if(Array.isArray(value)){need(value.length<=10000,'RESULT_NODE_LIMIT');return `[${value.map(v=>canonical(v,state,depth+1)).join(',')}]`}
 need(typeof value==='object'&&Object.getPrototypeOf(value)===Object.prototype,'RESULT_VALUE_INVALID');
 const keys=Object.keys(value);need(keys.length<=10000,'RESULT_NODE_LIMIT');return `{${keys.sort().map(k=>`${JSON.stringify(k)}:${canonical(value[k],state,depth+1)}`).join(',')}}`;
}
export function resultSigningBytes(envelope){
 const {signature,...signed}=envelope;
 return Buffer.from(canonical(signed),'utf8');
}
export class SignedResultVerifier{
 #used=new Map();
 constructor({publicKey,deviceId,now=()=>Date.now(),maxReplayEntries=10000,maxBytes=MAX_RESULT_BYTES,maxLifetimeMs=MAX_LIFETIME_MS}){
  need(publicKey&&deviceId,'VERIFIER_CONFIG_INVALID');
  need(Number.isInteger(maxReplayEntries)&&maxReplayEntries>0&&maxReplayEntries<=10000,'REPLAY_CAP_INVALID');
  need(Number.isInteger(maxBytes)&&maxBytes>=1024&&maxBytes<=MAX_RESULT_BYTES,'RESULT_SIZE_CAP_INVALID');
  need(Number.isInteger(maxLifetimeMs)&&maxLifetimeMs>=1000&&maxLifetimeMs<=MAX_LIFETIME_MS,'RESULT_TTL_CAP_INVALID');
  this.publicKey=publicKey?.type==='public'?publicKey:createPublicKey(publicKey);need(this.publicKey.asymmetricKeyType==='rsa'&&this.publicKey.asymmetricKeyDetails?.modulusLength>=2048,'RSA_PUBLIC_KEY_POLICY');
  this.deviceId=deviceId;this.now=now;this.maxReplayEntries=maxReplayEntries;this.maxBytes=maxBytes;this.maxLifetimeMs=maxLifetimeMs;
 }
 verify(envelope,{requestId,purpose='dev_read_result',clockSkewMs=30000}={}){
  const now=this.now();need(Number.isSafeInteger(now),'CLOCK_INVALID');
  need(Number.isInteger(clockSkewMs)&&clockSkewMs>=0&&clockSkewMs<=30000,'CLOCK_SKEW_POLICY_INVALID');
  for(const [nonce,expires] of this.#used)if(expires<=now)this.#used.delete(nonce);
  need(envelope&&typeof envelope==='object'&&!Array.isArray(envelope),'RESULT_ENVELOPE_INVALID');
  const expected=['device_id','expires_at','issued_at','nonce','purpose','request_id','result','signature'];
  need(Object.keys(envelope).length===expected.length&&expected.every(k=>own(envelope,k)),'RESULT_SCHEMA_INVALID');
  need(envelope.device_id===this.deviceId,'RESULT_DEVICE_MISMATCH');
  need(envelope.request_id===requestId&&typeof requestId==='string','RESULT_REQUEST_MISMATCH');
  need(envelope.purpose===purpose,'RESULT_PURPOSE_MISMATCH');
  need(Number.isSafeInteger(envelope.issued_at)&&Number.isSafeInteger(envelope.expires_at),'RESULT_TIME_INVALID');
  need(envelope.expires_at>now,'RESULT_EXPIRED');
  need(envelope.issued_at<=now+clockSkewMs&&envelope.issued_at>=now-clockSkewMs,'RESULT_ISSUED_AT_INVALID');
  need(envelope.expires_at>envelope.issued_at&&envelope.expires_at-envelope.issued_at<=this.maxLifetimeMs,'RESULT_TTL_INVALID');
  need(typeof envelope.nonce==='string'&&NONCE.test(envelope.nonce),'RESULT_NONCE_INVALID');
  need(typeof envelope.signature==='string'&&/^[A-Za-z0-9_-]+$/.test(envelope.signature),'RESULT_SIGNATURE_FORMAT');
  const bytes=resultSigningBytes(envelope);need(Buffer.byteLength(canonical(envelope),'utf8')<=this.maxBytes,'RESULT_TOO_LARGE');
  need(!this.#used.has(envelope.nonce),'RESULT_REPLAY');
  need(this.#used.size<this.maxReplayEntries,'RESULT_REPLAY_CAPACITY');
  const sig=Buffer.from(envelope.signature,'base64url');
  need(verify('RSA-SHA256',bytes,{key:this.publicKey,padding:constants.RSA_PKCS1_PADDING},sig),'RESULT_SIGNATURE_INVALID');
  this.#used.set(envelope.nonce,envelope.expires_at);
  const clonedResult=JSON.parse(JSON.stringify(envelope.result));
  return deepFreeze({requestId:envelope.request_id,deviceId:envelope.device_id,purpose:envelope.purpose,result:clonedResult,issuedAt:envelope.issued_at,expiresAt:envelope.expires_at});
 }
 get replayEntries(){return this.#used.size}
}
