import {readConfig} from './config.ts';
import {discoverYouTube} from './providers/youtube.ts';
import {OpenAIEditorialProvider} from './providers/openai.ts';
import {fixtureArtifacts} from './model.ts';
const config=readConfig();
let failed=false;
for(const slot of ['primary','backup'] as const) {
  try{const items=await discoverYouTube({...config,youtubeSlot:slot,youtubeBackup:slot==='primary'?'':config.youtubeBackup},'Apple iPhone Duo');console.log(JSON.stringify({provider:'youtube',slot,status:'passed',artifactCount:items.length}));}
  catch(error:any){failed=true;console.log(JSON.stringify({provider:'youtube',slot,status:'blocked_or_failed',code:error.code ?? 'UNKNOWN_ERROR'}));}
}
try{const decisions=await new OpenAIEditorialProvider(config).program(fixtureArtifacts().slice(0,1),'business');console.log(JSON.stringify({provider:'openai',model:config.model,status:'passed',decisions:decisions.length,syntheticProbe:true}));}
catch(error:any){failed=true;console.log(JSON.stringify({provider:'openai',status:'blocked_or_failed',code:error.code ?? 'UNKNOWN_ERROR'}));}
if(failed)process.exitCode=1;
