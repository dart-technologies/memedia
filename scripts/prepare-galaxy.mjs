import {readFile,writeFile} from 'node:fs/promises';
import {worldTrends} from '../backend/src/explorer.ts';
const dir=new URL('../apps/flutter_app/assets/',import.meta.url);
const scene=JSON.parse(await readFile(new URL('explorer.json',dir),'utf8'));
const observedAt=new Date().toISOString();
scene.world=await worldTrends();
const videos=[
 ['apple','7683937074696768782','Club Duo','launch'],
 ['mkbhd','7683665862523440398','The unfolding animation','software'],
 ['ijustine','7683607334152637709','First look at iPhone Duo','hands-on'],
 ['brandon.butch','7683696064301436174','Hands-on with iPhone Duo','hands-on'],
 ['raywongtech','7683735507016273183','The unfold animation catches on','software'],
 ['techstack','7683630985153482014','Duo meets Galaxy Z Fold','competition']
];
for(const [author,id,title,channel] of videos){
 const url=`https://www.tiktok.com/@${author}/video/${id}`;let meta;
 try{const r=await fetch('https://www.tiktok.com/oembed?url='+encodeURIComponent(url),{signal:AbortSignal.timeout(15000)});if(r.ok)meta=await r.json();}catch{}
 const opened=author==='apple';
 const a={id:'tt-'+id,url,title,publisher:meta?.author_name??author,platform:'TikTok',thumbnailUrl:meta?.thumbnail_url??null,thumbnailObservedAt:observedAt,publishedAt:null,displayedPublicationTime:opened?'1h ago at Sep 10 17:28 UTC':'Relative time shown in search; exact time unknown',firstObservedAt:'2026-09-10T17:28:01Z',views:null,likes:null,likesDisplay:opened?'22.4K':null,metricsObservedAt:opened?'2026-09-10T17:28:01Z':null,language:null,languageBasis:'English caption; spoken language not independently checked',captionLanguage:'en',contentKind:opened?'Brand video':'Creator video',evidenceStatus:opened?'ORIGINAL_POST_INSPECTED':'SEARCH_CANDIDATE',reviewStatus:opened?'PUBLISHER_AND_PLAYBACK_CHECKED':'CONTENT_REVIEW_PENDING',playbackVerified:opened,publisherIdentityVerified:opened,why:opened?'Apple’s own short launch treatment; account and playback checked.':'A relevant TikTok search candidate for this perspective. Content review pending.',limitations:'Browser-assisted discovery. Views and exact publication time unavailable. Video claims are not independently verified.'};
 scene.artifacts=scene.artifacts.filter(v=>v.id!==a.id);scene.artifacts.push(a);
 const c=scene.channels.find(c=>c.id===channel);c.seedArtifactIds=[...new Set([...c.seedArtifactIds,a.id])];
}
// Use the publisher's own preview image for text-led research channels.
for(const id of ['w01','w17']) {
 const a=scene.artifacts.find(a=>a.id===id);if(!a)continue;
 try {const r=await fetch(a.url,{signal:AbortSignal.timeout(15000)});const html=await r.text();
 const meta=(html.match(/<meta\b[^>]*>/gi)??[]).find(t=>/property=["']og:image["']/.test(t));
 const image=meta?.match(/content=["']([^"']+)["']/)?.[1]?.replaceAll('&amp;','&');
 if(r.ok&&image?.startsWith('https://')){a.thumbnailUrl=image;a.thumbnailObservedAt=observedAt;a.thumbnailBasis='Original publisher Open Graph image';}
 }catch {/* Preserve the last available image. */}
}
const short={'launch':'Launch','hands-on':'First looks',competition:'Samsung responds',business:'Market moves',value:'Worth $1,999?', 'visual-memes':'Long fingers','brand-banter':'Brand banter',repair:'Built to last?',software:'Unfold magic',ergonomics:'In your hands',community:'Buy or wait',podcasts:'Deep dives'};
for(const c of scene.channels){c.shortLabel=short[c.id];c.previewIds=c.seedArtifactIds.filter(id=>scene.artifacts.find(a=>a.id===id)?.thumbnailUrl).slice(0,3);}
scene.galaxyVersion=3;scene.cacheEntries={};scene.scanStates={};scene.selectedTopicId=null;scene.selectedChannelId=null;scene.updatedAt=observedAt;
await writeFile(new URL('explorer.json',dir),JSON.stringify(scene,null,2));
console.log(JSON.stringify({topics:scene.world.topics.map(t=>({label:t.label,region:t.region})),artifacts:scene.artifacts.length,tiktokThumbnails:scene.artifacts.filter(a=>a.platform==='TikTok'&&a.thumbnailUrl).length}));
