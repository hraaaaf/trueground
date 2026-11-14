import {test} from 'node:test';
import assert from 'node:assert/strict';
import {EventEmitter} from 'node:events';
import {join} from 'node:path';
import {MAX_SESSION_SECONDS,parseArgs,runForegroundSession,validateForegroundConfig} from './foreground-session.mjs';

const fixture=join(process.env.USERPROFILE||'C:\\Users\\test','AI_Machine_Bridge_DEV_FIXTURE','fixture-0123456789abcdef0123456789abcdef');

test('foreground runner pins the fixture root and five-minute maximum',()=>{
 const cfg=validateForegroundConfig({fixtureRoot:fixture,platform:'win32'});
 assert.equal(cfg.fixtureRoot,fixture);assert.equal(MAX_SESSION_SECONDS,300);
 assert.equal(parseArgs(['--fixture-root',fixture]).seconds,300);
 assert.throws(()=>validateForegroundConfig({fixtureRoot:fixture,seconds:301,platform:'win32'}),/SESSION_SECONDS_INVALID/);
 assert.throws(()=>validateForegroundConfig({fixtureRoot:join(process.env.USERPROFILE||'C:\\Users\\test','Documents'),platform:'win32'}),/FIXTURE_ROOT_NOT_ALLOWLISTED/);
 assert.throws(()=>validateForegroundConfig({fixtureRoot:fixture,platform:'linux'}),/WINDOWS_ONLY/);
});

test('five-minute guard kills the foreground child and returns timeout code',async()=>{
 const child=new EventEmitter();let killed=0,delay=0,cleared=false,argsSeen,optsSeen;
 child.kill=()=>{killed++;queueMicrotask(()=>child.emit('exit',null,'SIGTERM'));return true};
 const exit=await runForegroundSession({fixtureRoot:fixture,seconds:3,systemRoot:process.env.SystemRoot},{platform:'win32',spawnImpl:(exe,args,opts)=>{argsSeen={exe,args};optsSeen=opts;return child},setTimer:(fn,ms)=>{delay=ms;queueMicrotask(fn);return {id:1}},clearTimer:t=>{assert.deepEqual(t,{id:1});cleared=true}});
 assert.equal(exit,124);assert.equal(killed,1);assert.equal(delay,3000);assert.equal(cleared,true);
 assert.equal(argsSeen.exe,join(process.env.SystemRoot,'System32','WindowsPowerShell','v1.0','powershell.exe'));
 assert.ok(argsSeen.args.includes('-NonInteractive'));assert.ok(argsSeen.args.includes('-FixtureRoot'));assert.equal(optsSeen.shell,false);assert.deepEqual(optsSeen.stdio,'inherit');
});

test('normal foreground exit clears the deadline without killing the child',async()=>{
 const child=new EventEmitter();let killCount=0,callback,cleared=false;
 child.kill=()=>{killCount++;return true};
 const exitPromise=runForegroundSession({fixtureRoot:fixture,seconds:300,systemRoot:process.env.SystemRoot},{platform:'win32',spawnImpl:()=>{queueMicrotask(()=>child.emit('exit',0,null));return child},setTimer:(fn)=>{callback=fn;return 'timer'},clearTimer:t=>{assert.equal(t,'timer');cleared=true}});
 assert.equal(await exitPromise,0);callback();assert.equal(killCount,0);assert.equal(cleared,true);
});
