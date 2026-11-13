import {constants,createHash,createPublicKey,randomBytes,sign} from 'node:crypto';

export const STAGING_ORIGIN='https://staging-worker.example.invalid';
export const STAGING_WORKER_VERSION='00000000-0000-4000-8000-000000000007';
export const STAGING_D1_UUID='00000000-0000-4000-8000-000000000008';
export const DEVICE_ID='fixture-device-example';
export const ALLOWED_ROUTES=Object.freeze(['/agent/batch/poll','/agent/batch/result','/agent/batch/result-status']);
export const PROJECT_ACTIONS=Object.freeze(['list_project_files','read_project_text']);
export const STAGING_PUBLIC_JWK_THUMBPRINT='3a98cf5776bf8b243f7c6a423c505015e45a7870d002512c38eed85b8e3a5dbb';
export const PILOT_PUBLIC_JWK_THUMBPRINT='93cb80c05b03d8af15fa2ff3147bdc16ac84a2bda7de65d81ee731cd6ac96d01';
const NONCE=/^[A-Za-z0-9_-]{16,64}$/;
const UUID=/^[a-f0-9]{8}-(?:[a-f0-9]{4}-){3}[a-f0-9]{12}$/i;
const need=(ok,code)=>{if(!ok)throw Error(code)};

export function publicRsaJwkThumbprint(privateKey){
 need(privateKey?.asymmetricKeyType==='rsa','RSA_KEY_POLICY');
 const jwk=createPublicKey(privateKey).export({format:'jwk'});
 need(typeof jwk.n==='string'&&typeof jwk.e==='string','RSA_PUBLIC_KEY_INVALID');
 return createHash('sha256').update(JSON.stringify({e:jwk.e,kty:'RSA',n:jwk.n}),'utf8').digest('hex');
}
export function assertStagingFixtureKey(privateKey,expected=STAGING_PUBLIC_JWK_THUMBPRINT){
 need(/^[a-f0-9]{64}$/.test(expected),'EXPECTED_THUMBPRINT_INVALID');
 const actual=publicRsaJwkThumbprint(privateKey);
 need(actual===expected,'FIXTURE_KEY_STAGING_MISMATCH');
 return Object.freeze({matches:true,thumbprint:actual});
}

export function projectPollBody(){return JSON.stringify({agent_version:'0.7.0',device_id:DEVICE_ID,purpose:'batch_poll',channels:['projects']});}
export function projectResultBody({jobId,action,result}){
 need(UUID.test(jobId||''),'JOB_ID_INVALID');need(PROJECT_ACTIONS.includes(action),'PROJECT_ACTION_INVALID');
 need(result&&typeof result==='object'&&!Array.isArray(result),'RESULT_OBJECT_REQUIRED');
 const raw=JSON.stringify({agent_version:'0.7.0',device_id:DEVICE_ID,purpose:'batch_result',channel:'projects',job_id:jobId,action,result});
 need(Buffer.byteLength(raw)<=8192,'RESULT_TOO_LARGE');return raw;
}
export function projectStatusBody({jobId,action}){
 need(UUID.test(jobId||''),'JOB_ID_INVALID');need(PROJECT_ACTIONS.includes(action),'PROJECT_ACTION_INVALID');
 return JSON.stringify({agent_version:'0.7.0',device_id:DEVICE_ID,purpose:'result_status',channel:'projects',job_id:jobId,action});
}
export function validatePilotJob(job,{now=Math.floor(Date.now()/1000),minMarginSec=48,maxTtlSec=120}={}){
 need(job&&typeof job==='object'&&!Array.isArray(job),'JOB_OBJECT_REQUIRED');
 need(UUID.test(job.id||''),'JOB_ID_INVALID');need(PROJECT_ACTIONS.includes(job.action),'PROJECT_ACTION_INVALID');
 need(Number.isSafeInteger(job.expires_at),'JOB_EXPIRY_INVALID');
 need(Number.isSafeInteger(now)&&Number.isInteger(minMarginSec)&&minMarginSec>=1&&Number.isInteger(maxTtlSec)&&maxTtlSec>=minMarginSec,'TTL_POLICY_INVALID');
 need(job.expires_at>=now+minMarginSec,'TTL_MARGIN_TOO_SHORT');need(job.expires_at<=now+maxTtlSec,'TTL_OVER_POLICY');
 return Object.freeze({...job});
}
function validateBody(route,rawBody){
 let x;try{x=JSON.parse(rawBody)}catch{throw Error('BODY_JSON_INVALID')}
 need(x&&typeof x==='object'&&!Array.isArray(x)&&JSON.stringify(x)===rawBody,'BODY_NOT_CANONICAL_JSON');
 const common={agent_version:'0.7.0',device_id:DEVICE_ID};
 if(route==='/agent/batch/poll'){
  need(Object.keys(x).sort().join(',')==='agent_version,channels,device_id,purpose'&&x.agent_version===common.agent_version&&x.device_id===common.device_id&&x.purpose==='batch_poll'&&Array.isArray(x.channels)&&x.channels.length===1&&x.channels[0]==='projects','PROJECT_POLL_BODY_INVALID');
  return;
 }
 const status=route==='/agent/batch/result-status';
 need(status||route==='/agent/batch/result','STAGING_ROUTE_NOT_ALLOWLISTED');
 const expected=status?'action,agent_version,channel,device_id,job_id,purpose':'action,agent_version,channel,device_id,job_id,purpose,result';
 need(Object.keys(x).sort().join(',')===expected&&x.agent_version===common.agent_version&&x.device_id===common.device_id&&x.channel==='projects'&&x.purpose===(status?'result_status':'batch_result')&&UUID.test(x.job_id||'')&&PROJECT_ACTIONS.includes(x.action),'PROJECT_RESULT_BODY_INVALID');
 if(!status)need(x.result&&typeof x.result==='object'&&!Array.isArray(x.result)&&Buffer.byteLength(JSON.stringify(x.result))<=8192,'PROJECT_RESULT_INVALID');
}
export function signStagingRequest({privateKey,route,rawBody,timestamp=String(Math.floor(Date.now()/1000)),nonce=randomBytes(18).toString('base64url'),nowSec=Math.floor(Date.now()/1000)}){
 need(ALLOWED_ROUTES.includes(route),'STAGING_ROUTE_NOT_ALLOWLISTED');need(typeof rawBody==='string'&&Buffer.byteLength(rawBody)<=16384,'RAW_BODY_INVALID');validateBody(route,rawBody);
 need(/^\d{10,12}$/.test(timestamp)&&Number.isSafeInteger(nowSec)&&Math.abs(nowSec-Number(timestamp))<=90,'SIGNATURE_TIMESTAMP_OUT_OF_WINDOW');need(NONCE.test(nonce),'SIGNATURE_NONCE_INVALID');
 need(privateKey?.asymmetricKeyType==='rsa'&&privateKey.asymmetricKeyDetails?.modulusLength>=2048,'RSA_KEY_POLICY');
 const canonical=`${timestamp}\n${nonce}\nPOST ${route}\n${rawBody}`;
 const signature=sign('RSA-SHA256',Buffer.from(canonical,'utf8'),{key:privateKey,padding:constants.RSA_PKCS1_PADDING}).toString('base64url');
 return Object.freeze({'x-bridge-timestamp':timestamp,'x-bridge-nonce':nonce,'x-bridge-signature':signature});
}
