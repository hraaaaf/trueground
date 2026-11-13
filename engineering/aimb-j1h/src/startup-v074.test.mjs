import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {SupervisorV07} from './supervisor-v07.mjs';
import {BASE} from './e2e-windows-runner.mjs';
const harness={base:BASE,request:async()=>({status:200,body:{ok:true,channels:Object.fromEntries(['commands','files','maintenance','workspace','projects'].map(x=>[x,{ok:true,command:null}]))}})};
test('supervisor emits startup evidence before pending WSS connect resolves',async()=>{
 let release;const connect=()=>new Promise(r=>{release=r});
 const s=new SupervisorV07({harness,connect,durationSec:70});const ev=[];s.on('evidence',x=>ev.push(x));
 const promise=s.run();await new Promise(r=>setImmediate(r));
 assert.equal(ev[0].type,'supervisor_started');assert.equal(ev[0].stagingOnly,true);
 s.stop();release({close(){},listeners:[],socket:null});await promise;
});
test('no websocket connection is a NO-GO under the CLI success criterion',()=>{
 const src=readFileSync(new URL('./supervisor-v07.mjs',import.meta.url),'utf8');
 assert.match(src,/websocketConnections<1\|\|result\.metrics\.batchPolls<1/);
});
test('native websocket deadline is explicit, independent of socket idle timeout',()=>{
 const src=readFileSync(new URL('./e2e-windows-runner.mjs',import.meta.url),'utf8');
 assert.match(src,/WEBSOCKET_HARD_DEADLINE_12S/);assert.match(src,/clearTimeout\(deadline\)/);
});
test('startup printed before loading fixture key',()=>{
 const src=readFileSync(new URL('./supervisor-v07.mjs',import.meta.url),'utf8');
 assert.ok(src.indexOf("console.log('STAGE_BOOT'")<src.indexOf('const key=loadKey();'));
});
