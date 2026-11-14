// Offline contract harness only. It is not a Worker route or a live plugin tool.
const TOOL_NAMES=Object.freeze([
 'list_dev_project_files','read_dev_project_file','prepare_project_patch',
 'commit_project_patch','run_allowlisted_tests'
]);
const PROJECT='bridge-agent';
function requireValue(value,code){if(!value)throw Error(code)}
function shape(value,required,optional=[]){if(!value||typeof value!=='object'||Array.isArray(value))return false;const keys=Object.keys(value);return required.every(k=>keys.includes(k))&&keys.every(k=>required.includes(k)||optional.includes(k))}

export function createOfflineDevBridge({fixture,verifyAuthorization,projectId=PROJECT}){
 requireValue(fixture&&typeof fixture.list_dev_project_files==='function','FIXTURE_REQUIRED');
 requireValue(typeof verifyAuthorization==='function','AUTHORIZER_REQUIRED');
 requireValue(projectId===PROJECT,'PROJECT_ID_NOT_ALLOWLISTED');
 return Object.freeze({
  tools:TOOL_NAMES,
  async call({authorization,tool,input,approval,signature}){
   requireValue(await verifyAuthorization(authorization,{scope:'dev:project',projectId}),'AUTH_REQUIRED');
   requireValue(TOOL_NAMES.includes(tool),'TOOL_NOT_ALLOWLISTED');
   requireValue(input&&input.project_id===projectId,'PROJECT_ID_NOT_ALLOWLISTED');
   switch(tool){
    case 'list_dev_project_files':
     requireValue(shape(input,['project_id'],['offset','limit']),'INPUT_SCHEMA_INVALID');
     return fixture.list_dev_project_files({offset:input.offset??0,limit:input.limit??50});
    case 'read_dev_project_file':
     requireValue(shape(input,['project_id','path']),'INPUT_SCHEMA_INVALID');
     return fixture.read_dev_project_file({file:input.path});
    case 'prepare_project_patch':
     requireValue(shape(input,['project_id','path','expected_sha256','old_text','new_text']),'INPUT_SCHEMA_INVALID');
     return fixture.prepare_project_patch({file:input.path,expectedSha256:input.expected_sha256,oldText:input.old_text,newText:input.new_text});
    case 'commit_project_patch':
     requireValue(shape(input,['project_id','draft_id']),'INPUT_SCHEMA_INVALID');
     requireValue(typeof approval==='object'&&typeof signature==='string','SIGNED_APPROVAL_REQUIRED');
     return fixture.commit_project_patch({draftId:input.draft_id,approval,signature});
    case 'run_allowlisted_tests':
     requireValue(shape(input,['project_id','test_id'],['timeout_ms']),'INPUT_SCHEMA_INVALID');
     return fixture.run_allowlisted_tests({id:input.test_id,timeoutMs:input.timeout_ms??5000});
    default: throw Error('TOOL_NOT_ALLOWLISTED');
   }
  }
 });
}

export {TOOL_NAMES as DEV_TOOL_NAMES};
