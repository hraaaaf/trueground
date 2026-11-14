// Offline estimates; counts are hypothetical until measured from Cloudflare.
export const BUDGET=Object.freeze({worker:5000,d1read:50000,d1write:1000,doRequests:5000});
export const ZERO=()=>({worker:0,d1read:0,d1write:0,doRequests:0});
export function quotaDecision({used,cost,globalUsage,localCached=false}){
 if(localCached)return {allow:true,level:'LOCAL_CACHED'};
 if(!globalUsage?.reliable||!Number.isFinite(globalUsage.ratio)||globalUsage.ratio<0)return {allow:false,level:'GLOBAL_UNKNOWN'};
 if(globalUsage.ratio>=0.9)return {allow:false,level:'GLOBAL_NEAR_LIMIT'};
 let high=0;
 for(const k of Object.keys(BUDGET)){
  if(!Number.isFinite(used[k])||used[k]<0||!Number.isFinite(cost[k])||cost[k]<0)return {allow:false,level:'INVALID_COUNTER'};
  high=Math.max(high,(used[k]+cost[k])/BUDGET[k]);
 }
 if(high>=0.9)return {allow:false,level:'STOP'};
 return {allow:true,level:high>=0.8?'SLOW':high>=0.7?'ALERT':'NORMAL'};
}
export function retryPlan({active,results,maxAttempts=3}){
 if(!active)return {attempts:0,backoffMs:[],status:'IDLE'};
 const backoffMs=[];
 for(let i=0;i<Math.min(maxAttempts,results.length);i++){
  if(results[i]==='quota')return {attempts:i+1,backoffMs,status:'QUOTA_STOP'};
  if(results[i]==='ok')return {attempts:i+1,backoffMs,status:'OK'};
  if(i+1<maxAttempts)backoffMs.push(Math.min(60000,5000*2**i));
 }
 return {attempts:Math.min(maxAttempts,results.length),backoffMs,status:'STOP'};
}
const COST={batch:{worker:1,d1read:3,d1write:2,doRequests:1},read:{worker:1,d1read:2,d1write:1,doRequests:1},patch:{worker:2,d1read:4,d1write:4,doRequests:2},test:{worker:2,d1read:4,d1write:3,doRequests:2},retry:{worker:1,d1read:1,d1write:0,doRequests:1}};
export function simulate(events,{used=ZERO(),globalUsage={reliable:true,ratio:0.2}}={}){
 const consumed={...used},counts={accepted:0,rejected:0,alerts:0,slowed:0};
 for(const e of events){
  const cost=COST[e];if(!cost)throw Error('UNKNOWN_SIMULATION_EVENT');const d=quotaDecision({used:consumed,cost,globalUsage});
  if(!d.allow){counts.rejected++;continue}counts.accepted++;if(d.level==='ALERT')counts.alerts++;if(d.level==='SLOW')counts.slowed++;
  for(const k of Object.keys(BUDGET))consumed[k]+=cost[k];
 }
 return {consumed,counts,assumptions:'illustrative event costs; not Cloudflare measurements'};
}
