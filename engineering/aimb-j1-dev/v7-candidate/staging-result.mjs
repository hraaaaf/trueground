// J1-H staging-only read result receipt and status lookup.
const RECEIPT_ACTIONS=Object.freeze({
 commands:{table:"commands",allowed:["get_system_info"]},
 files:{table:"file_jobs",allowed:["list_authorized_files","read_authorized_text"]},
 maintenance:{table:"maintenance_jobs",allowed:["get_pc_resources","get_bridge_tasks","inspect_windows_service"]},
 workspace:{table:"workspace_jobs",allowed:["list_workspace_files","read_workspace_text"]},
 projects:{table:"project_jobs",allowed:["list_project_files","read_project_text"]}
});
const receiptJSON=(obj,code=200)=>new Response(JSON.stringify(obj),{status:code,headers:{"content-type":"application/json","cache-control":"no-store","x-content-type-options":"nosniff"}});
async function receiptBody(req,max=20000){
 if(!req.body)throw Error("missing_body");
 const reader=req.body.getReader(),chunks=[];let total=0;
 try{for(;;){const {done,value}=await reader.read();if(done)break;total+=value.byteLength;if(total>max){await reader.cancel();throw Error("too_large")}chunks.push(value)}}
 finally{reader.releaseLock()}
 const buf=new Uint8Array(total);let off=0;for(const ch of chunks){buf.set(ch,off);off+=ch.byteLength}
 return new TextDecoder("utf-8",{fatal:true}).decode(buf);
}
function receiptB64(s){const v=s.replace(/-/g,"+").replace(/_/g,"/");return Uint8Array.from(atob(v+"=".repeat((4-v.length%4)%4)),x=>x.charCodeAt(0))}
export async function handleReadResult(req,env,route){
 if(req.method!=="POST")return receiptJSON({error:"method_not_allowed"},405);
 if(!(req.headers.get("content-type")||"").startsWith("application/json"))return receiptJSON({error:"bad_media"},415);
 if(!env.STAGING_DB||!env.STAGING_PUB_JWK)return receiptJSON({error:"not_provisioned"},503);
 const isStatus=route==="/agent/batch/result-status";
 if(!isStatus&&route!=="/agent/batch/result")return receiptJSON({error:"not_found"},404);
 let raw,x;try{raw=await receiptBody(req);x=JSON.parse(raw)}catch{return receiptJSON({error:"invalid_body"},400)}
 if(!x||Array.isArray(x)||typeof x!=="object")return receiptJSON({error:"invalid_shape"},400);
 const expected=isStatus?"action,agent_version,channel,device_id,job_id,purpose":"action,agent_version,channel,device_id,job_id,purpose,result";
 const cfg=RECEIPT_ACTIONS[x.channel];
 if(Object.keys(x).sort().join(",")!==expected||x.agent_version!=="0.7.0"||x.device_id!=="j1h-staging-fixture"||x.purpose!==(isStatus?"result_status":"batch_result")||!cfg||!cfg.allowed.includes(x.action)||typeof x.job_id!=="string"||!/^[a-f0-9-]{36}$/.test(x.job_id)||(!isStatus&&(typeof x.result!=="object"||x.result===null||Array.isArray(x.result)||new TextEncoder().encode(JSON.stringify(x.result)).length>8192)))return receiptJSON({error:"invalid_shape"},400);
 const now=Math.floor(Date.now()/1000);
 const ts=req.headers.get("x-bridge-timestamp")||"",nonce=req.headers.get("x-bridge-nonce")||"",sig=req.headers.get("x-bridge-signature")||"";
 if(!/^\d{10,12}$/.test(ts)||Math.abs(now-Number(ts))>90||!/^[A-Za-z0-9_-]{16,64}$/.test(nonce)||!/^[A-Za-z0-9_-]{200,1000}$/.test(sig))return receiptJSON({error:"bad_auth"},401);
 try{
  const key=await crypto.subtle.importKey("jwk",JSON.parse(env.STAGING_PUB_JWK),{name:"RSASSA-PKCS1-v1_5",hash:"SHA-256"},false,["verify"]);
  if(!await crypto.subtle.verify("RSASSA-PKCS1-v1_5",key,receiptB64(sig),new TextEncoder().encode(ts+"\n"+nonce+"\nPOST "+route+"\n"+raw)))return receiptJSON({error:"bad_signature"},401);
 }catch{return receiptJSON({error:"bad_signature"},401)}
 try{
  const dedup=await env.STAGING_DB.prepare("INSERT OR IGNORE INTO agent_nonces(nonce,seen_at) VALUES (?,?)").bind(nonce,now).run();
  if(dedup.meta?.changes!==1)return receiptJSON({error:"replay"},409);
 }catch{return receiptJSON({error:"nonce_unavailable"},503)}
 let row;try{row=await env.STAGING_DB.prepare("SELECT action,status,result_json,expires_at FROM "+cfg.table+" WHERE id=? AND device_id=?").bind(x.job_id,x.device_id).first()}catch{return receiptJSON({error:"lookup_failed"},503)}
 if(!row||row.action!==x.action)return receiptJSON({error:"not_found"},404);
 if(isStatus){
  if(row.status==="done"){if(typeof row.result_json!=="string")return receiptJSON({error:"corrupt_result"},503);let saved;try{saved=JSON.parse(row.result_json)}catch{return receiptJSON({error:"corrupt_result"},503)}
   return receiptJSON({ok:true,channel:x.channel,job_id:x.job_id,action:x.action,status:"done",result:saved});
  }
  return receiptJSON({ok:true,channel:x.channel,job_id:x.job_id,action:x.action,status:Number(row.expires_at)<=now?"expired":row.status});
 }
 if(row.status==="done"){
  try{if(typeof row.result_json==="string"&&JSON.stringify(JSON.parse(row.result_json))===JSON.stringify(x.result))return receiptJSON({ok:true,received:true,already_received:true,job_id:x.job_id})}catch{}
  return receiptJSON({error:"result_conflict"},409);
 }
 if(row.status!=="leased"||Number(row.expires_at)<=now)return receiptJSON({error:"not_leased_or_expired"},409);
 try{
  const done=await env.STAGING_DB.prepare("UPDATE "+cfg.table+" SET status='done',result_json=?,handled_at=? WHERE id=? AND device_id=? AND action=? AND status='leased' AND expires_at>?").bind(JSON.stringify(x.result),now,x.job_id,x.device_id,x.action,now).run();
  return done.meta?.changes===1?receiptJSON({ok:true,received:true,job_id:x.job_id}):receiptJSON({error:"conflict"},409);
 }catch{return receiptJSON({error:"update_failed"},503)}
}