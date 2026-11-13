/**
 * Staging MCP smoke. Anonymous only; never transmits a token, accesses user files,
 * invokes signed agent routes, or creates D1 jobs.
 * Runs only on GitHub-hosted Windows during the authorized staging verification.
 */
const ORIGIN='https://ai-machine-bridge-j1h-staging.benmoussa-achraf.workers.dev';
async function probe(path,{method='GET',body}={}){
 const res=await fetch(ORIGIN+path,{method,headers:body?{'content-type':'application/json'}:{},body:body&&JSON.stringify(body),redirect:'error',signal:AbortSignal.timeout(12000)});
 const text=await res.text();if(text.length>8192)throw Error('RESPONSE_TOO_LARGE');
 let data;try{data=JSON.parse(text)}catch{throw Error('NON_JSON_RESPONSE_'+path)}
 return {status:res.status,data,headers:res.headers};
}
async function main(){
 const health=await probe('/health');
 if(health.status!==200||health.data?.stage!=='j1h-isolated'||health.data?.d1!==true||health.data?.production!==false||health.data?.do_bound!==true)throw Error('HEALTH_BAD_OR_NOT_ISOLATED_'+health.status);
 const m=await probe('/.well-known/oauth-protected-resource');
 if(m.status!==200||m.data?.resource!==ORIGIN+'/mcp'||!m.data?.scopes_supported?.includes('bridge.read')||!Array.isArray(m.data.authorization_servers)||m.data.authorization_servers.length!==1||!m.data.authorization_servers[0].startsWith('https://'))throw Error('OAUTH_RESOURCE_METADATA_INVALID_'+m.status);
 const get=await probe('/mcp');
 if(get.status!==401||get.data?.error!=='unauthorized'||!get.headers.get('www-authenticate')?.includes('resource_metadata='))throw Error('MCP_GET_ANONYMOUS_NOT_DENIED_'+get.status);
 const post=await probe('/mcp',{method:'POST',body:{jsonrpc:'2.0',id:1,method:'tools/list'}});
 if(post.status!==401||post.data?.error!=='unauthorized')throw Error('MCP_POST_ANONYMOUS_NOT_DENIED_'+post.status);
 console.log(JSON.stringify({status:'PASS',staging:true,health:200,oauth_metadata:200,mcp_get_anonymous:401,mcp_post_anonymous:401,authenticated_e2e:'NOT_TESTED',cloudflare_deploy:'ALREADY_COMPLETED',d1_writes:0}));
}
main().catch(e=>{console.error('NO_GO',String(e?.message||e));process.exitCode=1});
