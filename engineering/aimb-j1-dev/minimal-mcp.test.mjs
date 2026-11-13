import test from 'node:test';
import assert from 'node:assert/strict';
import {generateKeyPairSync,createSign,webcrypto} from 'node:crypto';
import {makeHandler} from './minimal-mcp.mjs';
import fixture from './fixture.mjs';
globalThis.crypto??=webcrypto;
const iss='https://fixture.auth0.com/',sub='auth0|pilot-test-only',aud='https://fixture.example/mcp';
const env={AUTH0_ISSUER:iss,AUTH0_AUDIENCE:aud,AUTH0_ALLOWED_SUB:sub};
const {publicKey,privateKey}=generateKeyPairSync('rsa',{modulusLength:2048});
const jwk={...publicKey.export({format:'jwk'}),use:'sig',alg:'RS256',kid:'fixture'};
const deps={fixture,fetch:async url=>{assert.equal(url,iss+'.well-known/jwks.json');return new Response(JSON.stringify({keys:[jwk]}),{status:200})}};
const enc=x=>Buffer.from(JSON.stringify(x)).toString('base64url');
function token(claims={}){const n=Math.floor(Date.now()/1000),h=enc({alg:'RS256',kid:'fixture',typ:'JWT'}),p=enc({iss,sub,aud,exp:n+600,iat:n,scope:'bridge.read',...claims}),msg=h+'.'+p;return msg+'.'+createSign('RSA-SHA256').update(msg).sign(privateKey).toString('base64url')}
const handler=makeHandler(deps);
async function call(method,params={},t=token()){const req=new Request('https://fixture.example/mcp',{method:'POST',headers:{authorization:'Bearer '+t,'content-type':'application/json'},body:JSON.stringify({jsonrpc:'2.0',id:1,method,params})});return handler(req,env)}
test('no anonymous tool access',async()=>{const r=await handler(new Request('https://fixture.example/mcp',{method:'POST'}),env);assert.equal(r.status,401);assert.match(r.headers.get('www-authenticate'),/resource_metadata/)});
test('OAuth metadata',async()=>{const r=await handler(new Request('https://fixture.example/.well-known/oauth-protected-resource'),env);assert.deepEqual((await r.json()).authorization_servers,[iss])});
test('initialization',async()=>{const r=await call('initialize');assert.equal((await r.json()).result.serverInfo.name,'aimb-fixture-staging')});
test('one tool only',async()=>{const r=await call('tools/list');assert.deepEqual((await r.json()).result.tools.map(x=>x.name),['read_staging_fixture'])});
test('actual bundled fixture read',async()=>{const r=await call('tools/call',{name:'read_staging_fixture',arguments:{name:'sample-a.txt'}});assert.equal((await r.json()).result.content[0].text,fixture)});
test('forbid write and other filenames',async()=>{const r=await call('tools/call',{name:'write_file',arguments:{name:'sample-a.txt'}});assert.equal((await r.json()).error.code,-32602)});
for(const [name,claims] of Object.entries({expired:{exp:10},wrongSub:{sub:'auth0|different'},wrongScope:{scope:'openid'},wrongAud:{aud:'not-allowed'},wrongIss:{iss:'https://wrong.example/'},future:{nbf:Math.floor(Date.now()/1000)+900}})){
test('reject '+name,async()=>{const r=await call('tools/list',{},token(claims));assert.equal(r.status,401)})}
test('fail closed on absent auth config',async()=>{const r=await handler(new Request('https://fixture.example/mcp',{method:'POST',headers:{authorization:'Bearer '+token()}}),{});assert.equal(r.status,401)});
