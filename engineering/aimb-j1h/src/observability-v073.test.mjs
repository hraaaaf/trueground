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
test('one wake waits 15s after last batch; no duplicate on burst',async()=>{const m=stage();await m.sup.tick(0);m.setTime(5000);m.wake();m.setTime(14_999);assert.equal(await m.sup.tick(14_999),false);m.setTime(15_000);assert.equal(await m.sup.tick(15_000),true);for(const t of [15_250,15_650,15_850,16_250]){m.setTime(t);assert.equal(await m.sup.tick(t),false)}assert.deepEqual(m.sup.pollTrace.map(t=>t.reason),['startup','wakeup']);assert.equal(m.sup.pollTrace[1].wakeupToPollMs,10_000);m.sup.stop()});
test('fallback one minute after wake poll, not after notification',async()=>{const m=stage();await m.sup.tick(0);m.setTime(1000);m.wake();m.setTime(15_000);await m.sup.tick(15_000);m.setTime(74_999);assert.equal(await m.sup.tick(74_999),false);m.setTime(75_000);await m.sup.tick(75_000);assert.deepEqual(m.sup.pollTrace.map(t=>t.reason),['startup','wakeup','fallback']);assert.equal(m.sup.pollTrace[2].intervalMs,60000);m.sup.stop()});
test('duplicate websocket wake notifications coalesce into one signed batch',async()=>{const m=stage();await m.sup.tick(0);m.setTime(1000);m.wake();m.setTime(1010);m.wake();m.setTime(15_000);await m.sup.tick(15_000);assert.equal(m.sup.metrics.websocketWakeups,2);assert.equal(m.sup.metrics.pollReasons.wakeup,1);assert.equal(m.calls.length,2);m.sup.stop()});
test('notification at 4.85s cannot trigger a costly 5.1s batch',async()=>{const m=stage();await m.sup.tick(0);m.setTime(4850);m.wake();m.setTime(5100);assert.equal(await m.sup.tick(5100),false);m.setTime(15000);assert.equal(await m.sup.tick(15000),true);assert.equal(m.sup.pollTrace[1].reason,'wakeup');assert.equal(m.sup.pollTrace[1].intervalMs,15000);assert.equal(m.sup.pollTrace[1].wakeupToPollMs,10150);m.sup.stop()});
test('poll at 5.1s without new wake cannot happen',async()=>{const m=stage();await m.sup.tick(0);m.setTime(5100);assert.equal(await m.sup.tick(5100),false);assert.equal(m.sup.pollTrace.length,1);m.sup.stop()});
test('poll when wake coincides with earlier fallback is attributed to fallback',async()=>{const m=stage();await m.sup.tick(0);m.setTime(59900);m.wake();m.setTime(60000);await m.sup.tick(60000);assert.equal(m.sup.pollTrace[1].reason,'fallback');assert.equal(m.sup.pollTrace[1].wakeId,null);m.sup.stop()});
test('in-flight wake is preserved and triggers next coalesced poll',()=>{const s=new PollScheduler();assert.equal(s.step(0),true);s.wake(100);s.complete(200,{ok:true});assert.equal(s.state().dueCause,'wakeup');assert.equal(s.step(15_199),false);assert.equal(s.step(15_200),true);assert.equal(s.state().lastCause,'wakeup');s.complete(15_201,{ok:true});assert.equal(s.step(15_900),false)});
test('consumed wake never triggers duplicate after completion',()=>{const s=new PollScheduler();s.step(0);s.complete(0,{ok:true});s.wake(1000);assert.equal(s.step(15_000),true);s.complete(15_020,{ok:true});assert.equal(s.state().dueCause,'fallback');assert.equal(s.step(15_520),false)});
test('scheduler cause distinguishes retry while supervisor remains 60s fail-safe',()=>{const s=new PollScheduler();s.step(0);s.complete(0,{ok:false});assert.equal(s.state().dueCause,'retry');assert.equal(s.step(5000),true);assert.equal(s.state().lastCause,'retry')});
test('each poll trace ID unique and no raw nonce or signature in evidence',async()=>{const m=stage();await m.sup.tick(0);m.setTime(60000);await m.sup.tick(60000);const ids=m.sup.pollTrace.map(x=>x.pollId);assert.equal(new Set(ids).size,2);assert.ok(m.events.some(x=>x.type==='poll_started'));assert.ok(m.events.some(x=>x.type==='poll_finished'));for(const e of m.events){assert.equal('nonce' in e,false);assert.equal('signature' in e,false);assert.equal('private_key' in e,false)}m.sup.stop()});
test('monotonic correlation no wall clock arithmetic',async()=>{const m=stage();await m.sup.tick(0);m.setTime(1500);m.wake();m.setTime(15_000);await m.sup.tick(15_000);assert.equal(m.sup.metrics.wakeupPollLatencyMs[0],13_500);assert.equal(m.sup.pollTrace[1].startedMonotonicMs,15_000);m.sup.stop()});
test('report declares staging and no Windows task changes',async()=>{const m=stage();await m.sup.tick(0);const r=m.sup.report();assert.equal(r.production_touched,false);assert.equal(r.task_scheduler_modified,false);assert.equal(r.stage,BASE);assert.equal(r.pollTrace.length,1);m.sup.stop()});
