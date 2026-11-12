/**
 * Read-only public staging probe. No fixture key, no signed requests, no job writes.
 * Only verifies transport reachability and rejection of anonymous WebSocket upgrade.
 */
import {request} from 'node:https';
import {randomBytes} from 'node:crypto';
import {BASE} from './src/e2e-windows-runner.mjs';

const target = new URL(BASE);
if (target.hostname !== 'ai-machine-bridge-j1h-staging.benmoussa-achraf.workers.dev' ||
    target.protocol !== 'https:' || target.pathname !== '/' || target.search || target.hash) {
  throw Error('STAGING_ORIGIN_NOT_PINNED');
}

function probe(path, upgrade=false) {
  return new Promise((resolve,reject)=>{
    let done=false;
    const headers=upgrade ? {
      Upgrade:'websocket',Connection:'Upgrade','Sec-WebSocket-Version':'13',
      'Sec-WebSocket-Key':randomBytes(16).toString('base64')
    } : {};
    const req=request({hostname:target.hostname,port:443,method:'GET',path,
      headers,timeout:8000},res=>{
      res.setEncoding('utf8');
      let body='';
      res.on('data',chunk=>{if(body.length<4096) body+=chunk.slice(0,4096-body.length)});
      res.on('end',()=>finish(null,{status:res.statusCode,body}));
    });
    function finish(err,value){
      if(done)return;done=true;clearTimeout(timer);
      if(err)reject(err);else resolve(value);
    }
    const timer=setTimeout(()=>{req.destroy(Error('NETWORK_DEADLINE_10S'))},10000);
    req.on('upgrade',(_response,socket)=>{
      socket.destroy();
      finish(Error('UNSIGNED_WEBSOCKET_UPGRADE_ACCEPTED'));
    });
    req.on('timeout',()=>req.destroy(Error('NETWORK_TIMEOUT_8S')));
    req.on('error',e=>finish(e));
    req.end();
  });
}
async function main(){
  const health=await probe('/health');
  if(health.status!==200)throw Error('STAGING_HEALTH_HTTP_'+health.status);
  let body;
  try{body=JSON.parse(health.body)}catch{throw Error('STAGING_HEALTH_NOT_JSON')}
  if(body.production!==false || body.d1!==true || body.do_bound!==true){
    throw Error('STAGING_HEALTH_NOT_ISOLATED_OR_NOT_READY');
  }
  const anonymous=await probe('/agent/realtime',true);
  if(anonymous.status!==401)throw Error('UNSIGNED_WSS_EXPECTED_401_GOT_'+anonymous.status);
  console.log(JSON.stringify({goal:'J1-H Windows HTTPS / unsigned WSS transport check',
    result:'PASS',health:200,unsigned_websocket:401,
    signed_websocket:'NOT_TESTED_NO_FIXTURE_KEY',
    staging_only:true,production_touched:false}));
}
main().catch(e=>{console.error('NO_GO',String(e?.message||e));process.exitCode=1});
