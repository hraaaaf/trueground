import {spawn} from 'node:child_process';
import {existsSync} from 'node:fs';
import {join,resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';

export const MAX_SESSION_SECONDS=300;
const AGENT=fileURLToPath(new URL('./foreground-readonly-agent.ps1',import.meta.url));
const FIXTURE_PARENT=join(process.env.USERPROFILE||'','AI_Machine_Bridge_DEV_FIXTURE');
const UUID=/^fixture-[0-9a-f]{32}$/i;
const need=(ok,code)=>{if(!ok)throw Error(code)};

export function validateForegroundConfig({fixtureRoot,seconds=MAX_SESSION_SECONDS,systemRoot=process.env.SystemRoot,platform=process.platform}={}){
 need(platform==='win32','WINDOWS_ONLY');
 need(typeof fixtureRoot==='string'&&fixtureRoot.length>0,'FIXTURE_ROOT_REQUIRED');
 const full=resolve(fixtureRoot),base=resolve(FIXTURE_PARENT);
 need(dirname(full).toLowerCase()===base.toLowerCase()&&UUID.test(full.slice(full.lastIndexOf('\\')+1)),'FIXTURE_ROOT_NOT_ALLOWLISTED');
 need(Number.isInteger(seconds)&&seconds>=1&&seconds<=MAX_SESSION_SECONDS,'SESSION_SECONDS_INVALID');
 need(typeof systemRoot==='string'&&systemRoot.length>0,'SYSTEM_ROOT_REQUIRED');
 const powershell=join(systemRoot,'System32','WindowsPowerShell','v1.0','powershell.exe');
 need(existsSync(powershell),'WINDOWS_POWERSHELL_NOT_FOUND');
 return {fixtureRoot:full,seconds,powershell,agent:AGENT};
}

export async function runForegroundSession(config,{spawnImpl=spawn,setTimer=setTimeout,clearTimer=clearTimeout,platform=process.platform}={}){
 const checked=validateForegroundConfig({...config,platform});
 const child=spawnImpl(checked.powershell,['-NoProfile','-NonInteractive','-File',checked.agent,'-FixtureRoot',checked.fixtureRoot],{shell:false,windowsHide:true,stdio:'inherit'});
 return await new Promise((resolvePromise,rejectPromise)=>{
  let settled=false,timedOut=false;
  const finish=(error,code)=>{if(settled)return;settled=true;clearTimer(timer);if(error)rejectPromise(error);else resolvePromise(timedOut?124:(Number.isInteger(code)?code:1));};
  const timer=setTimer(()=>{if(settled)return;timedOut=true;try{child.kill()}catch{};child.once('exit',code=>finish(null,code));},checked.seconds*1000);
  child.once('error',error=>finish(error));
  child.once('exit',code=>finish(null,code));
 });
}

export function parseArgs(args){
 let fixtureRoot,seconds=MAX_SESSION_SECONDS;
 for(let i=0;i<args.length;i++){
  if(args[i]==='--fixture-root'&&!fixtureRoot&&args[i+1])fixtureRoot=args[++i];
  else if(args[i]==='--session-seconds'&&args[i+1])seconds=Number(args[++i]);
  else if(args[i]==='--help'&&args.length===1)return {help:true};
  else throw Error('BAD_ARGUMENTS');
 }
 if(!fixtureRoot)throw Error('FIXTURE_ROOT_REQUIRED');
 return {fixtureRoot,seconds};
}

if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)){
 try{
  const config=parseArgs(process.argv.slice(2));
  if(config.help){process.stdout.write('Usage: node foreground-session.mjs --fixture-root <fixture-GUID> [--session-seconds 1..300]\n');process.exitCode=0;}
  else runForegroundSession(config).then(code=>{if(code===124)process.stderr.write('FOREGROUND_SESSION_DEADLINE\n');process.exitCode=code;}).catch(error=>{process.stderr.write(`${error.message}\n`);process.exitCode=1;});
 }catch(error){process.stderr.write(`${error.message}\n`);process.exitCode=2;}
}
