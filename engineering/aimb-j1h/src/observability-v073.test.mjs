import {test} from 'node:test';
import assert from 'node:assert/strict';
import {EventEmitter} from 'node:events';
import {PollScheduler} from './poll-scheduler.mjs';
import {SupervisorV07} from './supervisor-v07.mjs';
import {BASE,CHANNELS} from './e2e-windows-runner.mjs';

function stage(){
 let now=0;const calls=[],events=[];let connection;
 const harness={base:BASE,async request(path){calls.push({path,at:now});return {status:200,body:{ok:true,channels:Object.fromEntries(CHANNELS.map(c=>[c,{ok:true,command:null}]))}}}};
 const connect=async()=>{const socket=new EventEmitter();socket.destroy=()=>socket.emit('close');connection={listeners:[],socket,close:()=>socket.destroy()};return connection};
 const sup=new SupervisorV07({harness,connect,durationSec:70});
 sup.localTime=()=>now;sup.on('evidence',e=>events.push(e));
 return {sup,calls,events,get ws(){return connection},setTime:n=>{now=n},wake:(channel='projects')=>connection.listeners.forEach(fn=>fn({type:'pending',channel}))};
}

test('startup poll classified and correlated with no wake',async()=>{const m=stage();await m.sup.tick(0);assert.equal(m.sup.pollTrace[0].reason,'startup');assert.equal(m.sup.pollTrace[0].recovery,true);assert.equal(m.sup.pollTrace[0].wakeId,null);assert.equal(m.sup.metrics.pollReasons.startup,1);m.sup.stop()});
test('one wake => exactly one wakeup poll; no second within 250..600ms',async()=>{const m=stage();await m.sup.tick(0);m.setTime(5000);m.wake();m.setTime(5249);assert.equal(await m.sup.tick(5249),false);m.setTime(5250);assert.equal(await m.sup.tick(5250),true);for(const t of [5500,5650,5850,6250]){m.setTime(t);assert.equal(await m.sup.tick(t),false)}assert.deepEqual(m.sup.pollTrace.map(t=>t.reason),['startup','wakeup']);assert.equal(m.sup.pollTrace[1].wakeupToPollMs,250);m.sup.stop()});
test('fallback one minute after wake poll, not after notification',async()=>{const m=stage();await m.sup.tick(0);m.setTime(1000);m.wake();m.setTime(1250);await m.sup.tick(1250);m.setTime(61249);assert.equal(await m.sup.tick(61249),false);m.setTime(61250);await m.sup.tick(61250);assert.deepEqual(m.sup.pollTrace.map(t=>t.reason),['startup','wakeup','fallback']);assert.equal(m.sup.pollTrace[2].intervalMs,60000);m.sup.stop()});
test('duplicate websocket wake notifications coalesce into one signed batch',async()=>{const m=stage();await m.sup.tick(0);m.setTime(1000);m.wake();m.setTime(1010);m.wake();m.setTime(1250);await m.sup.tick(1250);assert.equal(m.sup.metrics.websocketWakeups,2);assert.equal(m.sup.metrics.pollReasons.wakeup,1);assert.equal(m.calls.length,2);m.sup.stop()});
test('poll at 5.1s with new wake is classified wakeup and not claimed duplicate',async()=>{const m=stage();await m.sup.tick(0);m.setTime(4850);m.wake();m.setTime(5100);await m.sup.tick(5100);assert.equal(m.sup.pollTrace[1].reason,'wakeup');assert.equal(m.sup.pollTrace[1].intervalMs,5100);assert.equal(m.sup.pollTrace[1].wakeupToPollMs,250);m.sup.stop()});
test('poll at 5.1s without new wake cannot happen',async()=>{const m=stage();await m.sup.tick(0);m.setTime(5100);assert.equal(await m.sup.tick(5100),false);assert.equal(m.sup.pollTrace.length,1);m.sup.stop()});
test('poll when wake coincides with earlier fallback is attributed to fallback',async()=>{const m=stage();await m.sup.tick(0);m.setTime(59900);m.wake();m.setTime(60000);await m.sup.tick(60000);assert.equal(m.sup.pollTrace[1].reason,'fallback');assert.equal(m.sup.pollTrace[1].wakeId,null);m.sup.stop()});
test('in-flight wake is preserved and triggers next coalesced poll',()=>{const s=new PollScheduler();assert.equal(s.step(0),true);s.wake(100);s.complete(200,{ok:true});assert.equal(s.state().dueCause,'wakeup');assert.equal(s.step(449),false);assert.equal(s.step(450),true);assert.equal(s.state().lastCause,'wakeup');s.complete(451,{ok:true});assert.equal(s.step(900),false)});
test('consumed wake never triggers duplicate after completion',()=>{const s=new PollScheduler();s.step(0);s.complete(0,{ok:true});s.wake(1000);s.step(1250);s.complete(1270,{ok:true});assert.equal(s.state().dueCause,'fallback');assert.equal(s.step(1770),false)});
test('scheduler cause distinguishes retry while supervisor remains 60s fail-safe',()=>{const s=new PollScheduler();s.step(0);s.complete(0,{ok:false});assert.equal(s.state().dueCause,'retry');assert.equal(s.step(5000),true);assert.equal(s.state().lastCause,'retry')});
test('each poll trace ID unique and no raw nonce or signature in evidence',async()=>{const m=stage();await m.sup.tick(0);m.setTime(60000);await m.sup.tick(60000);const ids=m.sup.pollTrace.map(x=>x.pollId);assert.equal(new Set(ids).size,2);assert.ok(m.events.some(x=>x.type==='poll_started'));assert.ok(m.events.some(x=>x.type==='poll_finished'));for(const e of m.events){assert.equal('nonce' in e,false);assert.equal('signature' in e,false);assert.equal('private_key' in e,false)}m.sup.stop()});
test('monotonic correlation no wall clock arithmetic',async()=>{const m=stage();await m.sup.tick(0);m.setTime(1500);m.wake();m.setTime(1750);await m.sup.tick(1750);assert.equal(m.sup.metrics.wakeupPollLatencyMs[0],250);assert.equal(m.sup.pollTrace[1].startedMonotonicMs,1750);m.sup.stop()});
test('report declares staging and no Windows task changes',async()=>{const m=stage();await m.sup.tick(0);const r=m.sup.report();assert.equal(r.production_touched,false);assert.equal(r.task_scheduler_modified,false);assert.equal(r.stage,BASE);assert.equal(r.pollTrace.length,1);m.sup.stop()});
