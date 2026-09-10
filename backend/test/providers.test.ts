import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readConfig,readiness} from '../src/config.ts';
import {discoverYouTube} from '../src/providers/youtube.ts';
import {OpenAIEditorialProvider} from '../src/providers/openai.ts';
import {fixtureArtifacts,validateDecisions} from '../src/model.ts';
const config=readConfig({OPENAI_API_KEY:'test-openai-secret',YOUTUBE_API_KEY_PRIMARY:'test-primary-secret',YOUTUBE_API_KEY_BACKUP:'test-backup-secret'});
const success=()=>Response.json({items:[{id:{videoId:'abcdefghijk'},snippet:{title:'Candidate title',channelTitle:'Candidate channel',publishedAt:'2026-09-10T10:00:00Z'}}]});
test('readiness exposes flags, not secrets',()=>{
  const text=JSON.stringify(readiness(config));assert(!text.includes('secret'));assert(text.includes('openaiConfigured'));
});
test('quota errors do not consume the backup key',async()=>{
  let calls=0;
  await assert.rejects(discoverYouTube(config,'query',async()=>{calls++;return Response.json({error:{errors:[{reason:'quotaExceeded'}]}},{status:403});}),/YOUTUBE_QUOTA_EXCEEDED/);
  assert.equal(calls,1);
});
test('invalid primary key retries once with backup and maps real source metadata',async()=>{
  const keys:string[]=[];
  const items=await discoverYouTube(config,'query',async(url)=>{
    keys.push(new URL(String(url)).searchParams.get('key')!);
    return keys.length===1?Response.json({error:{errors:[{reason:'keyInvalid'}]}},{status:400}):success();
  });
  assert.deepEqual(keys,[config.youtubePrimary,config.youtubeBackup,config.youtubeBackup]);
  assert.equal(items[0].url,'https://www.youtube.com/watch?v=abcdefghijk');
  assert.equal(items[0].confidence,null);assert.equal(items[0].velocity_score,null);
});
test('explicit backup selection uses only backup',async()=>{
  await discoverYouTube({...config,youtubeSlot:'backup'},'query',async(url)=>{assert.equal(new URL(String(url)).searchParams.get('key'),config.youtubeBackup);return success();});
});
test('missing credentials never trigger a request',async()=>{
  const blank=readConfig({});let calls=0;
  const fetcher=async()=>{calls++;return success();};
  await assert.rejects(discoverYouTube(blank,'query',fetcher),/YOUTUBE_KEY_MISSING/);
  await assert.rejects(new OpenAIEditorialProvider(blank,fetcher).program(fixtureArtifacts(),'general'),/OPENAI_KEY_MISSING/);
  assert.equal(calls,0);
});
test('OpenAI uses bearer auth, strict output, and rejects invented artifact ids',async()=>{
  const provider=new OpenAIEditorialProvider(config,async(url,init)=>{
    assert.equal(String(url),'https://api.openai.com/v1/responses');
    const body=JSON.parse(String(init!.body));
    assert.equal(body.model,'gpt-6-astra');assert.equal(body.text.format.strict,true);
    assert(!String(init!.body).includes(config.openaiKey));
    return Response.json({status:'completed',output:[{content:[{type:'output_text',text:JSON.stringify({decisions:[{artifact_id:'invented',relevance:1,cluster_id:'launch',status:'NOW',reason_codes:[]}]})}]}]});
  });
  await assert.rejects(provider.program(fixtureArtifacts().slice(0,1),'general'),/OPENAI_OUTPUT_INVALID/);
});
test('duplicate references and multiple NOW entries are rejected',()=>{
  const artifacts=fixtureArtifacts().slice(0,2);
  const row={artifact_id:artifacts[0].id,relevance:0.9,cluster_id:'launch',status:'NOW',reason_codes:[]};
  assert.throws(()=>validateDecisions([row,row],artifacts));
  assert.throws(()=>validateDecisions([row,{...row,artifact_id:artifacts[1].id}],artifacts),/MULTIPLE_NOW_ITEMS/);
});
test('valid structured response becomes a bounded editorial decision',async()=>{
  const artifact=fixtureArtifacts()[0];
  const decision={artifact_id:artifact.id,relevance:0.8,cluster_id:'launch',status:'NOW',reason_codes:['RELEVANT_TO_PASSENGER']};
  const provider=new OpenAIEditorialProvider(config,async(_url,init)=>{
    assert.equal((init!.headers as Record<string,string>).Authorization,`Bearer ${config.openaiKey}`);
    return Response.json({status:'completed',output:[{content:[{type:'output_text',text:JSON.stringify({decisions:[decision]})}]}]});
  });
  assert.deepEqual(await provider.program([artifact],'business'),[decision]);
});

test('YouTube raw detail counts and language context stay distinct from confidence',async()=>{
 const items=await discoverYouTube(config,'iPhone Duo',async(url)=>{const u=new URL(String(url));if(u.pathname.endsWith('/search')){assert.equal(u.searchParams.get('relevanceLanguage'),'en');assert.equal(u.searchParams.get('regionCode'),'US');return success();}return Response.json({items:[{id:'abcdefghijk',statistics:{viewCount:'1000',likeCount:'0'},snippet:{defaultAudioLanguage:'hi'},contentDetails:{duration:'PT1M'},status:{embeddable:true}}]});});
 assert.equal(items[0].views,'1000');assert.equal(items[0].likes,'0');assert.equal(items[0].audio_language,'hi');assert.equal(items[0].confidence,null);assert.equal(items[0].provenance_confidence,null);
});
