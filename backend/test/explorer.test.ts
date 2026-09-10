import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,readFile,rm} from 'node:fs/promises';
import {join} from 'node:path';
import {tmpdir} from 'node:os';
import {ExplorerCache,parseTrends,curate} from '../src/explorer.ts';
import {readConfig} from '../src/config.ts';
const config=readConfig({DEMO_MODE:'live',OPENAI_API_KEY:'test-key',YOUTUBE_API_KEY_PRIMARY:'test-youtube'});
const video={id:{videoId:'abcdefghijk'},snippet:{title:'iPhone Duo &amp; Samsung',channelTitle:'Example',publishedAt:'2026-09-10T10:00:00Z'}};
function upstream(onCall:()=>void=()=>{}):typeof fetch{return async(url,init)=>{onCall();const u=String(url);if(u.includes('/search'))return Response.json({items:[video,video]});if(u.includes('/videos'))return Response.json({items:[{id:'abcdefghijk',snippet:{defaultAudioLanguage:'en'},statistics:{viewCount:'1234',likeCount:'0'},contentDetails:{duration:'PT1M'}}]});const input=JSON.parse(JSON.parse(String(init?.body)).input);return Response.json({status:'completed',output:[{content:[{type:'output_text',text:JSON.stringify({items:input.items.map((a:any)=>({id:a.id,include:true,why:'Direct metadata match.'}))})}]}]});};}
test('trend records preserve attribution and unknown article time/engagement',()=>{const rows=parseTrends('<rss><item><title>Test &amp; topic</title><pubDate>Thu, 10 Sep 2026 10:20:00 -0700</pubDate><ht:approx_traffic>1000+</ht:approx_traffic><ht:picture>https://example.org/a.jpg</ht:picture><ht:news_item><ht:news_item_title>A headline</ht:news_item_title><ht:news_item_url>https://example.org/story</ht:news_item_url><ht:news_item_source>Publisher</ht:news_item_source></ht:news_item></item></rss>','US','2026-09-10T18:00:00Z');assert.equal(rows[0].label,'Test & topic');assert.equal(rows[0].articles[0].publishedAt,null);assert.equal(rows[0].articles[0].views,null);assert.equal(rows[0].trendStartedAt,'2026-09-10T17:20:00.000Z');});
test('refresh coalesces requests, caches, persists, deduplicates and retains accepted state on failure',async()=>{const dir=await mkdtemp(join(tmpdir(),'memedia-cache-'));try{let calls=0;let clock=Date.parse('2026-09-10T18:00:00Z');let fail=false;const fetcher:typeof fetch=async(input,init)=>{if(fail)throw Error('upstream');return upstream(()=>calls++)(input,init);};const cache=new ExplorerCache(join(dir,'cache.json'),config,{world:{topics:[]}},fetcher,()=>clock);await cache.init();const [a,b]=await Promise.all([cache.refresh('competition'),cache.refresh('competition')]);assert.equal(a.revision,1);assert.deepEqual(a,b);assert.equal(a.artifacts.length,1);assert.equal(a.artifacts[0].likes,'0');assert.equal(calls,3);const hit=await cache.refresh('competition');assert.equal(hit.cacheHit,true);assert.equal(calls,3);clock+=130000;fail=true;await assert.rejects(cache.refresh('competition'));assert.equal(cache.overview().entries.competition.revision,1);const restore=new ExplorerCache(join(dir,'cache.json'),config,{world:{topics:[]}});await restore.init();assert.deepEqual(restore.overview().entries.competition,a);assert.equal(JSON.parse(await readFile(join(dir,'cache.json'),'utf8')).entries.competition.artifacts.length,1);await assert.rejects(cache.refresh('arbitrary-query'),/UNKNOWN_CHANNEL/);}finally{await rm(dir,{recursive:true,force:true});}});
test('curation rejects duplicate or invented ids before any cache mutation',async()=>{await assert.rejects(curate(config,[{id:'known',title:'title'}],'question',async()=>Response.json({status:'completed',output:[{content:[{type:'output_text',text:'{"items":[{"id":"invented","include":true,"why":"x"}]}'}]}]})),/CURATION_OUTPUT_INVALID/);});

test('world ranking has no country quota and never sums duplicate country buckets', async()=>{
 const {rankWorldTopics,trafficFloor}=await import('../src/explorer.ts');
 const t=(id:string,region:string,volume:string)=>({id,region,regions:[region],approxTraffic:volume,articles:[{url:'https://example.org/'+id}]});
 const ranked=rankWorldTopics([[t('a','US','2M+'),t('b','US','500K+')],[t('c','GB','10K+'),t('a','GB','1M+')]]);
 assert.deepEqual(ranked.map(t=>t.id),['a','b','c']);assert.equal(ranked[0].searchVolumeFloor,2000000);assert.deepEqual(ranked[0].regions,['US','GB']);assert.equal(trafficFloor('100,000+'),100000);
});
test('global discovery requests views order without a country restriction',async()=>{
 const {discoverYouTube}=await import('../src/providers/youtube.ts');
 await discoverYouTube(config,'query',async(url)=>{const u=new URL(String(url));assert.equal(u.searchParams.get('regionCode'),null);assert.equal(u.searchParams.get('order'),'viewCount');assert.equal(u.searchParams.get('maxResults'),'24');return Response.json({items:[]});},{global:true,order:'viewCount',maxResults:24});
});

test('world clustering rejects omissions and fabricated references',async()=>{
 const {clusterWorld}=await import('../src/explorer.ts');
 const topics=[{id:'a',label:'Story',searchVolumeFloor:1000,regions:['US'],articles:[]}];
 const response=(groups:any)=>async()=>Response.json({status:'completed',output:[{content:[{type:'output_text',text:JSON.stringify({groups})}]}]});
 await assert.rejects(clusterWorld(topics,config,response([])),/TOPIC_CLUSTERING_INVALID/);
 await assert.rejects(clusterWorld(topics,config,response([{label:'Story',ids:['made-up']}])),/TOPIC_CLUSTERING_INVALID/);
 const result=await clusterWorld(topics,config,response([{label:'Story',ids:['a']}]));assert.equal(result[0].rank,1);assert.equal(result[0].searchVolumeFloor,1000);
});

 test('primary flag follows the strongest observed country bucket',async()=>{
 const {rankWorldTopics}=await import('../src/explorer.ts');
 const t=(region:string,approxTraffic:string)=>({id:'same',region,regions:[region],approxTraffic,articles:[]});
 const result=rankWorldTopics([[t('US','10K+')],[t('GB','100K+')]]);
 assert.equal(result[0].primaryRegion,'GB');assert.deepEqual(result[0].regions,['US','GB']);
 });


test('cold world refresh advances beyond the bundled snapshot revision',async()=>{
 const dir=await mkdtemp(join(tmpdir(),'memedia-world-revision-'));
 try {
  const fetcher:typeof fetch=async(url,init)=>{
   if(String(url).includes('trends.google.com'))return new Response('<rss><item><title>Launch</title><ht:approx_traffic>100K+</ht:approx_traffic><ht:news_item><ht:news_item_title>Launch report</ht:news_item_title><ht:news_item_url>https://example.org/launch</ht:news_item_url></ht:news_item></item></rss>');
   const topics=JSON.parse(JSON.parse(String(init?.body)).input);
   return Response.json({status:'completed',output:[{content:[{type:'output_text',text:JSON.stringify({groups:topics.map((t:any)=>({label:t.label,ids:[t.id]}))})}]}]});
  };
  const cache=new ExplorerCache(join(dir,'cache.json'),config,{world:{revision:3,topics:[]}},fetcher);
  await cache.init();
  const result=await cache.refresh('world');
  assert.equal(result.revision,4);
  assert.ok(result.topics.length>0);
  assert.equal((await cache.refresh('world')).cacheHit,true);
 }finally{await rm(dir,{recursive:true,force:true});}
});
