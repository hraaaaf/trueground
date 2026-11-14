// AIMB J1 read-only MCP fixture candidate. NOT a deployed Worker.
const E=new TextEncoder();
const json=(o,s=200,h={})=>new Response(JSON.stringify(o),{status:s,headers:{"content-type":"application/json","cache-control":"no-store",...h}});
const error=(id,code,message)=>json({jsonrpc:"2.0",id,error:{code,message}});
function bytes(v){if(typeof v!=="string"||! /^[A-Za-z0-9_-]+$/.test(v))throw Error("bad_base64");const b=v.replace(/-/g,"+").replace(/_/g,"/");return Uint8Array.from(atob(b+"=".repeat((4-b.length%4)%4)),x=>x.charCodeAt(0))}
function issuer(s){if(typeof s!=="string"||s.length>350)throw Error("bad_issuer");const u=new URL(s);if(u.protocol!=="https:"||u.search||u.hash||u.username||u.password)throw Error("bad_issuer");return u.href.endsWith("/")?u.href:u.href+"/"}
export async function verifyToken(req,env,opts={}){
 const m=/^Bearer ([A-Za-z0-9_-]+[.][A-Za-z0-9_-]+[.][A-Za-z0-9_-]+)$/.exec(req.headers.get("authorization")||"");
 if(!m||!env.AUTH0_ISSUER||!env.AUTH0_AUDIENCE||!env.AUTH0_ALLOWED_SUB)return false;
 try{
  const [h,p,s]=m[1].split(".");if(h.length>8192||p.length>16384||s.length>2048)return false;
  const decode=x=>JSON.parse(new TextDecoder("utf-8",{fatal:true}).decode(bytes(x)));
  const header=decode(h),claims=decode(p),iss=issuer(env.AUTH0_ISSUER),now=Math.floor((opts.now?.()??Date.now())/1000);
  if(header.alg!=="RS256"||!header.kid||header.kid.length>200||header.typ&&header.typ!=="JWT")return false;
  if(claims.iss!==iss||claims.sub!==env.AUTH0_ALLOWED_SUB||typeof claims.exp!=="number"||claims.exp<=now||typeof claims.iat!=="number"||claims.iat>now+60||
    claims.nbf!==undefined&&(typeof claims.nbf!=="number"||claims.nbf>now+60)||
    !(Array.isArray(claims.aud)?claims.aud.includes(env.AUTH0_AUDIENCE):claims.aud===env.AUTH0_AUDIENCE)||
    typeof claims.scope!=="string"||!claims.scope.split(" ").includes("bridge.read"))return false;
  const u=new URL(".well-known/jwks.json",iss).href;
  const r=await (opts.fetch??fetch)(u,{redirect:"error",signal:AbortSignal.timeout(3500)});
  if(!r.ok||Number(r.headers.get("content-length")||0)>50000)return false;
  const raw=await r.text();if(raw.length>50000)return false;
  const keys=JSON.parse(raw).keys;if(!Array.isArray(keys)||keys.length>30)return false;
  const jwk=keys.find(x=>x.kid===header.kid&&x.kty==="RSA"&&x.use==="sig"&&x.alg==="RS256");if(!jwk)return false;
  const key=await crypto.subtle.importKey("jwk",{kty:"RSA",n:jwk.n,e:jwk.e,alg:"RS256",ext:true},{name:"RSASSA-PKCS1-v1_5",hash:"SHA-256"},false,["verify"]);
  return crypto.subtle.verify("RSASSA-PKCS1-v1_5",key,bytes(s),E.encode(h+"."+p));
 }catch{return false}
}
const tool={name:"read_staging_fixture",description:"Read one public bundled test fixture (not the Lenovo filesystem)",inputSchema:{type:"object",properties:{name:{type:"string",enum:["sample-a.txt"]}},required:["name"],additionalProperties:false}};
export function makeHandler(opts={}){
 return async(req,env={})=>{
  const u=new URL(req.url),meta=u.origin+"/.well-known/oauth-protected-resource";
  if(u.pathname==="/.well-known/oauth-protected-resource"&&req.method==="GET"){
   try{return json({resource:u.origin+"/mcp",authorization_servers:[issuer(env.AUTH0_ISSUER)],scopes_supported:["bridge.read"],bearer_methods_supported:["header"]})}catch{return json({error:"auth_not_configured"},503)}
  }
  if(u.pathname!=="/mcp")return json({error:"not_found"},404);
  if(!await verifyToken(req,env,opts))return json({error:"unauthorized"},401,{"www-authenticate":'Bearer resource_metadata="'+meta+'", scope="bridge.read"'});
  if(req.method!=="POST")return json({error:"method_not_allowed"},405,{allow:"POST"});
  if(!(req.headers.get("content-type")||"").toLowerCase().startsWith("application/json"))return json({error:"unsupported_media_type"},415);
  let s;try{s=await req.text();if(E.encode(s).length>4096)return json({error:"payload_too_large"},413)}catch{return json({error:"invalid_body"},400)}
  let msg;try{msg=JSON.parse(s)}catch{return error(null,-32700,"Parse error")}
  if(!msg||Array.isArray(msg)||msg.jsonrpc!=="2.0"||typeof msg.method!=="string")return error(null,-32600,"Invalid Request");
  if(msg.method==="notifications/initialized"&&!Object.hasOwn(msg,"id"))return new Response(null,{status:202});
  const id=msg.id;if(typeof id!=="string"&&!Number.isInteger(id))return error(null,-32600,"Invalid Request");
  if(msg.method==="initialize")return json({jsonrpc:"2.0",id,result:{protocolVersion:"2025-03-26",capabilities:{tools:{}},serverInfo:{name:"aimb-fixture-staging",version:"0.1.0"}}});
  if(msg.method==="ping")return json({jsonrpc:"2.0",id,result:{}});
  if(msg.method==="tools/list")return json({jsonrpc:"2.0",id,result:{tools:[tool]}});
  if(msg.method==="tools/call"){
   if(msg.params?.name!==tool.name||msg.params?.arguments?.name!=="sample-a.txt"||Object.keys(msg.params.arguments).length!==1)return error(id,-32602,"Invalid tool arguments");
   const fixture=opts.fixture;
   if(typeof fixture!=="string"||fixture.length>8192)return error(id,-32000,"Fixture unavailable");
   return json({jsonrpc:"2.0",id,result:{content:[{type:"text",text:fixture}],isError:false}});
  }
  return error(id,-32601,"Method not found");
 };
}
