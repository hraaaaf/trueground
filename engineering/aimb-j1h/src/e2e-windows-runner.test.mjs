import {test} from 'node:test';
import assert from 'node:assert/strict';
import {generateKeyPairSync,verify,randomUUID,createHash} from 'node:crypto';
import {EventEmitter} from 'node:events';
import {BASE,DEVICE,CHANNELS,ACTIONS,requireStagingUrl,signRequest,validateManifest,parseArgs,percentile,RawWS,b64url,main} from './e2e-windows-runner.mjs';
const {privateKey,publicKey}=generateKeyPairSync('rsa',{modulusLength:2048});
function manifest(exp=Math.floor(Date.now()/1000)+80){return{device_id:DEVICE,staging_worker_version:'605a258b-580e-4f32-b9b0-4e0bd8d0efcd',jobs:Object.fromEntries(CHANNELS.map(ch=>[ch,{id:randomUUID(),action:ACTIONS[ch][0],expires_at:exp}]))}}
function error(fn,fragment){assert.throws(fn,new RegExp(fragment));}
test('stage base is pinned',()=>assert.equal(requireStagingUrl(),BASE));
test('other domain refused',()=>error(()=>requireStagingUrl('https://evil.example/'),'STAGING_URL_PIN_FAILED'));
test('prod-looking domain refused',()=>error(()=>requireStagingUrl('https://ai-machine-bridge-j0d.workers.dev/'),'STAGING_URL_PIN_FAILED'));
test('credentials/query/path refused',()=>{for(const s of [BASE+'/a',BASE+'/?a=b','https://user:pass@ai-machine-bridge-j1h-staging.benmoussa-achraf.workers.dev/'])error(()=>requireStagingUrl(s),'STAGING_URL_PIN_FAILED')});
test('cli: preflight works without root var',()=>assert.deepEqual(parseArgs(['--phase','preflight']),{phase:'preflight',manifest:null}));
test('cli: batch requires manifest',()=>error(()=>parseArgs(['--phase','batch']),'BATCH_NEEDS_MANIFEST'));
test('cli: manifest prohibited outside batch',()=>error(()=>parseArgs(['--phase','preflight','--manifest','a.json']),'MANIFEST_ONLY_FOR_BATCH'));
test('cli: unexpected options rejected',()=>error(()=>parseArgs(['--phase','preflight','--production']),'BAD_CLI_ARGUMENTS'));
test('valid 5-channel fixture passes margin',()=>assert.equal(validateManifest(manifest()).device_id,DEVICE));
test('TTL margin rejected before any side effects',()=>error(()=>validateManifest(manifest(Math.floor(Date.now()/1000)+30)),'TTL_MARGIN_TOO_SHORT'));
test('manifest expired rejected',()=>error(()=>validateManifest(manifest(Math.floor(Date.now()/1000)-1)),'TTL_MARGIN_TOO_SHORT'));
test('manifest far-future TTL rejected',()=>error(()=>validateManifest(manifest(Math.floor(Date.now()/1000)+99999)),'STAGING_TTL_OVER_120_SECONDS'));
test('manifest missing job refused',()=>{const m=manifest();delete m.jobs.projects;error(()=>validateManifest(m),'EXACT_FIVE_CHANNELS_REQUIRED')});
test('manifest unknown write action refused',()=>{const m=manifest();m.jobs.workspace.action='create_workspace_text';error(()=>validateManifest(m),'INVALID_FIXTURE_workspace')});
test('manifest other device refused',()=>{const m=manifest();m.device_id='production';error(()=>validateManifest(m),'MANIFEST_SCOPE_INVALID')});
test('manifest duplicate job id refused',()=>{const m=manifest();m.jobs.files.id=m.jobs.commands.id;error(()=>validateManifest(m),'DUPLICATE_JOB_ID')});
test('manifest stage version pinned',()=>{const m=manifest();m.staging_worker_version='wrong';error(()=>validateManifest(m),'STAGING_VERSION_MISMATCH')});
test('RSA canonical payload verified',()=>{const raw='{"purpose":"batch_poll"}';const t='1794390000',n=b64url(Buffer.alloc(18,3));const x=signRequest(privateKey,'/agent/batch/poll',raw,{timestamp:t,nonce:n});const canonical=`${t}\n${n}\nPOST /agent/batch/poll\n${raw}`;assert.ok(verify('RSA-SHA256',Buffer.from(canonical),publicKey,Buffer.from(x['x-bridge-signature'],'base64url')))});
test('RSA WSS canonical exact expected',()=>{const x=signRequest(privateKey,'/agent/realtime','',{timestamp:'1794390000',nonce:b64url(Buffer.alloc(18,4)),method:'GET',websocket:true});const canonical=`1794390000\n${x['x-bridge-nonce']}\nGET /agent/realtime\n${DEVICE}`;assert.ok(verify('RSA-SHA256',Buffer.from(canonical),publicKey,Buffer.from(x['x-bridge-signature'],'base64url')))});
test('nonce random string URL safe',()=>assert.match(b64url(Buffer.alloc(18,33)),/^[A-Za-z0-9_-]{16,64}$/));
test('percentile metrics correct',()=>{assert.equal(percentile([2,3,1,8,4],50),3);assert.equal(percentile([2,3,1,8,4],95),8)});
test('websocket frame decoded from server event',()=>{const sock=new EventEmitter();sock.destroy=()=>{};sock.end=()=>{};const w=new RawWS(sock);let x={type:'pending',channel:'projects'};const payload=Buffer.from(JSON.stringify(x));sock.emit('data',Buffer.concat([Buffer.from([0x81,payload.length]),payload]));assert.deepEqual(w.items[0],x)});
test('websocket close code parsed',()=>{const sock=new EventEmitter();sock.destroy=()=>{};sock.end=()=>{};const w=new RawWS(sock);sock.emit('data',Buffer.from([0x88,0x02,0x0f,0xa1]));assert.equal(w.closeCode,4001)});
test('websocket partial frame buffered before message',()=>{const sock=new EventEmitter();sock.destroy=()=>{};sock.end=()=>{};const w=new RawWS(sock);const frame=Buffer.from([0x81,0x02,0x7b,0x7d]);sock.emit('data',frame.subarray(0,2));assert.equal(w.items.length,0);sock.emit('data',frame.subarray(2));assert.deepEqual(w.items[0],{})});
test('websocket masked server frame refused',()=>{const sock=new EventEmitter();sock.destroy=()=>{};sock.end=()=>{};const w=new RawWS(sock);error(()=>sock.emit('data',Buffer.from([0x81,0x80])),'WS_SERVER_MASKED_FRAME')});

test('TTL 115s staging fixture valid',()=>assert.equal(validateManifest(manifest(Math.floor(Date.now()/1000)+115)).device_id,DEVICE));
test('TTL 121s staging fixture rejected',()=>error(()=>validateManifest(manifest(Math.floor(Date.now()/1000)+121)),'STAGING_TTL_OVER_120_SECONDS'));
test('stale V6 staging manifest rejected',()=>{const m=manifest();m.staging_worker_version='1e69955d-e499-4595-a1b4-18f2240e7214';error(()=>validateManifest(m),'STAGING_VERSION_MISMATCH')});
