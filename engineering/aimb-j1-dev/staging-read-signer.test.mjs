import {test} from 'node:test';
import assert from 'node:assert/strict';
import {constants,generateKeyPairSync,verify} from 'node:crypto';
import {DEVICE_ID,PROJECT_ACTIONS,STAGING_D1_UUID,STAGING_ORIGIN,STAGING_WORKER_VERSION,STAGING_PUBLIC_JWK_THUMBPRINT,assertStagingFixtureKey,publicRsaJwkThumbprint,projectPollBody,projectResultBody,projectStatusBody,signStagingRequest,validatePilotJob} from './staging-read-signer.mjs';

const {privateKey,publicKey}=generateKeyPairSync('rsa',{modulusLength:2048});
const id='11111111-2222-4333-8444-555555555555';
const fixedNonce='abcdefghijklmnopQRSTUV';

test('staging signing bytes exactly match V7 HTTP canonical',()=>{
 const raw=projectPollBody(),route='/agent/batch/poll',timestamp='1794517800';
 const headers=signStagingRequest({privateKey,route,rawBody:raw,timestamp,nonce:fixedNonce,nowSec:Number(timestamp)});
 const canonical=`${timestamp}\n${fixedNonce}\nPOST ${route}\n${raw}`;
 assert.equal(verify('RSA-SHA256',Buffer.from(canonical,'utf8'),{key:publicKey,padding:constants.RSA_PKCS1_PADDING},Buffer.from(headers['x-bridge-signature'],'base64url')),true);
 assert.equal(verify('RSA-SHA256',Buffer.from(canonical.replace(route,'/agent/batch/result'),'utf8'),{key:publicKey,padding:constants.RSA_PKCS1_PADDING},Buffer.from(headers['x-bridge-signature'],'base64url')),false);
 assert.deepEqual(JSON.parse(raw),{agent_version:'0.7.0',device_id:DEVICE_ID,purpose:'batch_poll',channels:['projects']});
 assert.deepEqual(PROJECT_ACTIONS,['list_project_files','read_project_text']);
 assert.equal(STAGING_WORKER_VERSION,'00000000-0000-4000-8000-000000000007');assert.equal(STAGING_D1_UUID,'00000000-0000-4000-8000-000000000008');assert.equal(new URL(STAGING_ORIGIN).protocol,'https:');
});

test('fixture key thumbprint check returns only public identity and rejects mismatch',()=>{
 const thumb=publicRsaJwkThumbprint(privateKey);
 assert.equal(thumb.length,64);assert.notEqual(thumb,STAGING_PUBLIC_JWK_THUMBPRINT);
 assert.throws(()=>assertStagingFixtureKey(privateKey),/FIXTURE_KEY_STAGING_MISMATCH/);
 const proof=assertStagingFixtureKey(privateKey,thumb);
 assert.deepEqual(proof,{matches:true,thumbprint:thumb});
});

test('project result and status bodies match V7 closed schemas',()=>{
 const result=JSON.parse(projectResultBody({jobId:id,action:'read_project_text',result:{ok:true,content:'fixture'}}));
 assert.deepEqual(Object.keys(result).sort(),['action','agent_version','channel','device_id','job_id','purpose','result'].sort());
 assert.equal(result.purpose,'batch_result');assert.equal(result.channel,'projects');
 const status=JSON.parse(projectStatusBody({jobId:id,action:'list_project_files'}));
 assert.deepEqual(Object.keys(status).sort(),['action','agent_version','channel','device_id','job_id','purpose'].sort());assert.equal(status.purpose,'result_status');
 assert.throws(()=>projectResultBody({jobId:id,action:'commit_project_patch',result:{}}),/PROJECT_ACTION_INVALID/);
 assert.throws(()=>projectStatusBody({jobId:'../bad',action:'read_project_text'}),/JOB_ID_INVALID/);
});

test('pilot TTL policy accepts 115 seconds with 48-second floor and rejects 121',()=>{
 assert.equal(validatePilotJob({id,action:'list_project_files',expires_at:1115},{now:1000}).expires_at,1115);
 assert.throws(()=>validatePilotJob({id,action:'list_project_files',expires_at:1121},{now:1000}),/TTL_OVER_POLICY/);
 assert.equal(validatePilotJob({id,action:'list_project_files',expires_at:1048},{now:1000}).expires_at,1048);
 assert.throws(()=>validatePilotJob({id,action:'list_project_files',expires_at:1047},{now:1000}),/TTL_MARGIN_TOO_SHORT/);
});

test('signer refuses route, timestamp, nonce and key outside V7 bounds',()=>{
 const raw=projectPollBody();
 assert.throws(()=>signStagingRequest({privateKey,route:'/agent/commands',rawBody:raw}),/STAGING_ROUTE_NOT_ALLOWLISTED/);
 assert.throws(()=>signStagingRequest({privateKey,route:'/agent/batch/poll',rawBody:raw,timestamp:'1794517800',nonce:fixedNonce,nowSec:1794517891}),/SIGNATURE_TIMESTAMP_OUT_OF_WINDOW/);
 assert.throws(()=>signStagingRequest({privateKey,route:'/agent/batch/poll',rawBody:raw,timestamp:'1794517800',nonce:'bad',nowSec:1794517800}),/SIGNATURE_NONCE_INVALID/);
 assert.throws(()=>signStagingRequest({privateKey:{asymmetricKeyType:'ec'},route:'/agent/batch/poll',rawBody:raw}),/RSA_KEY_POLICY/);
});

test('project-only signer refuses other channels and non-project results',()=>{
 const t='1794517800',common={privateKey,route:'/agent/batch/poll',timestamp:t,nowSec:Number(t),nonce:fixedNonce};
 assert.throws(()=>signStagingRequest({...common,rawBody:JSON.stringify({agent_version:'0.7.0',device_id:DEVICE_ID,purpose:'batch_poll',channels:['commands','projects']})}),/PROJECT_POLL_BODY_INVALID/);
 const poll=projectPollBody()+' ';
 assert.throws(()=>signStagingRequest({...common,rawBody:poll}),/BODY_NOT_CANONICAL_JSON/);
 const jobId=id;
 const bad=JSON.stringify({agent_version:'0.7.0',device_id:DEVICE_ID,purpose:'batch_result',channel:'commands',job_id:jobId,action:'get_system_info',result:{ok:true}});
 assert.throws(()=>signStagingRequest({privateKey,route:'/agent/batch/result',rawBody:bad,timestamp:t,nonce:fixedNonce,nowSec:Number(t)}),/PROJECT_RESULT_BODY_INVALID/);
});
