import test from 'node:test';
import assert from 'node:assert/strict';
import {webcrypto,generateKeyPairSync,createSign} from 'node:crypto';
import staging from './v7-candidate/worker.js';
globalThis.crypto??=webcrypto;
const origin='https://staging.example';
const env={AUTH0_ISSUER:'https://fixture.auth0.com/',AUTH0_AUDIENCE:origin+'/mcp',AUTH0_ALLOWED_SUB:'auth0|test-only'};
const {privateKey,publicKey}=generateKeyPairSync('rsa',{modulusLength:2048});
const oldFetch=globalThis.fetch;
const jwk={...publicKey.export({format:'jwk'}),alg:'RS256',kid:'fixture',use:'sig'};
const b64=x=>Buffer.from(JSON.stringify(x)).toString('base64url');
function bearer(){const n=Math.floor(Date.now()/1000),h=b64({alg:'RS256',kid:'fixture',typ:'JWT'}),p=b64({iss:env.AUTH0_ISSUER,sub:env.AUTH0_ALLOWED_SUB,aud:env.AUTH0_AUDIENCE,scope:'bridge.read',exp:n+600,iat:n}),msg=h+'.'+p;return msg+'.'+createSign('RSA-SHA256').update(msg).sign(privateKey).toString('base64url');}
async function mcp(method,params={}) {const t=bearer();return staging.fetch(new Request(origin+'/mcp',{method:'POST',headers:{authorization:'Bearer '+t,'content-type':'application/json'},body:JSON.stringify({jsonrpc:'2.0',id:7,method,params})}),env)}
test('V7 candidate MCP does not allow anonymous calls',async()=>{const r=await staging.fetch(new Request(origin+'/mcp',{method:'POST'}),env);assert.equal(r.status,401)});
test('V7 candidate preserves OAuth metadata',async()=>{const r=await staging.fetch(new Request(origin+'/.well-known/oauth-protected-resource'),env);assert.equal(r.status,200)});
test('V7 old batch route still rejects GET before D1',async()=>{const r=await staging.fetch(new Request(origin+'/agent/batch/poll'),env);assert.equal(r.status,405)});
test('V7 existing /health route still behaves',async()=>{const r=await staging.fetch(new Request(origin+'/health'),{...env,STAGING_DB:{prepare:()=>({first:async()=>({ok:1})})}});const x=await r.json();assert.equal(x.stage,'j1h-isolated');assert.equal(x.production,false)});
test('V7 new MCP lists just one fixture read tool',async()=>{globalThis.fetch=async u=>{assert.equal(u,env.AUTH0_ISSUER+'.well-known/jwks.json');return new Response(JSON.stringify({keys:[jwk]}))};try{const r=await mcp('tools/list');assert.equal(r.status,200);const b=await r.json();assert.deepEqual(b.result.tools.map(x=>x.name),['read_staging_fixture'])}finally{globalThis.fetch=oldFetch}});
test('V7 new MCP reads bundled fixture via actual route',async()=>{globalThis.fetch=async()=>new Response(JSON.stringify({keys:[jwk]}));try{const r=await mcp('tools/call',{name:'read_staging_fixture',arguments:{name:'sample-a.txt'}});assert.equal(r.status,200);assert.match((await r.json()).result.content[0].text,/hello-from-github-ci/)}finally{globalThis.fetch=oldFetch}});
