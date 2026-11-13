import {test} from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {generateKeyPairSync} from 'node:crypto';
import {mkdtempSync,writeFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
const gate=fileURLToPath(new URL('./live-staging-gate.mjs',import.meta.url));
const env=()=>{const out={...process.env};delete out.AIMB_J1H_PRIVATE_KEY_PATH;return out};
test('live staging gate refuses missing private key before any request',()=>{
 const r=spawnSync(process.execPath,[gate],{encoding:'utf8',env:env(),timeout:8000});
 assert.equal(r.status,1);
 assert.match(r.stderr,/NO_GO AUTHORIZED_FIXTURE_KEY_FILE_MISSING/);
 assert.doesNotMatch(r.stdout,/STAGING_PREFLIGHT_OK/);
});
test('live staging gate refuses a valid but unauthorized RSA key before any request',()=>{
 const dir=mkdtempSync(join(tmpdir(),'aimb-key-pin-'));
 try{
  const {privateKey}=generateKeyPairSync('rsa',{modulusLength:2048});
  const keyPath=join(dir,'fixture.pem');
  writeFileSync(keyPath,privateKey.export({type:'pkcs8',format:'pem'}));
  const r=spawnSync(process.execPath,[gate],{encoding:'utf8',env:{...env(),AIMB_J1H_PRIVATE_KEY_PATH:keyPath},timeout:8000});
  assert.equal(r.status,1);
  assert.match(r.stderr,/NO_GO FIXTURE_KEY_DOES_NOT_MATCH_LIVE_STAGING/);
  assert.doesNotMatch(r.stdout,/STAGING_PREFLIGHT_OK/);
 }finally{rmSync(dir,{recursive:true,force:true})}
});
