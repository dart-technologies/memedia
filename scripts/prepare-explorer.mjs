import {readFile,writeFile} from 'node:fs/promises';
const assets=new URL('../apps/flutter_app/assets/',import.meta.url);
const inventory=JSON.parse(await readFile(new URL('source-inventory.json',assets),'utf8'));
const catalog=JSON.parse(await readFile(new URL('channel-catalog.json',assets),'utf8'));
const a=new Map(inventory.artifacts.map(a=>[a.id,a]));
const originals=[
 ['2097743244775862468','Samsung teases its foldable lineup','1:45 PM','726K','Competition from the brand itself; the original post was inspected.'],
 ['2097748103478591990','Samsung calls it reheated leftovers','2:04 PM','12.3M','An original brand response, not a reviewer speaking for Samsung.'],
 ['2097748434341990533','Samsung reacts to the bedside clock','2:06 PM','868.1K','A second angle on the brand response; not independent corroboration.'],
 ['2097734978746372358','Duolingo joins the naming conversation','1:12 PM','1.2M','A cultural naming reaction from a non-competing brand.'],
 ['2097748226174582784','Duolingo replies to Samsung','2:05 PM','9.4M','The visible exchange links two brands through a shared joke.'],
 ['2097777885893292337','The long-fingers image becomes the story','4:03 PM','2.3M','The post and comparison images are visible. Image manipulation and the first meme creator remain unverified.']
];
for(const [id,title,time,views,why] of originals){
 Object.assign(a.get('x-'+id),{title,evidenceStatus:'ORIGINAL_POST_INSPECTED',reviewStatus:'POST_AND_ATTRIBUTION_REVIEWED',publishedAt:'2026-09-09',publicationTimePrecision:'day',displayedPublicationTime:time+' · Sep 9, 2026 (browser timezone unconfirmed)',browserObservedOn:'2026-09-10',browserRecordedAt:'2026-09-10T16:54:01Z',metricsObservedAt:'2026-09-10T16:54:01Z',viewsDisplay:views,metricsDisplayBasis:'Rounded value displayed by X; exact count unavailable',why,contentKind:'Brand response',limitations:why});
}
Object.assign(a.get('x-2097777885893292337'),{thumbnailUrl:'https://pbs.twimg.com/media/HRzM7V_bYAAhJ5Q?format=webp&name=medium',contentKind:'Reported allegation',likesDisplay:'29K',why:'The visible comparison explains the joke. It does not establish that Apple altered the image.'});
Object.assign(a.get('yt-bxSGfpoFP30'),{publisherIdentityVerified:true,playbackVerified:true,reviewStatus:'PUBLISHER_AND_PLAYBACK_CHECKED',why:'A short first-party product overview. Performance and durability statements remain Apple’s claims.'});
catalog.channels.sort((a,b)=>['launch','hands-on','competition','business','value','visual-memes','brand-banter','repair','software','ergonomics','community','podcasts'].indexOf(a.id)-['launch','hands-on','competition','business','value','visual-memes','brand-banter','repair','software','ergonomics','community','podcasts'].indexOf(b.id));
const priorities={launch:['yt-bxSGfpoFP30','yt-FUfGcZ092b0','w01'],competition:['x-2097748103478591990','yt-Zxi1AAPZ0xc','w17'], 'brand-banter':['x-2097734978746372358','x-2097748226174582784','w02'], 'visual-memes':['x-2097777885893292337','w03','w04'], 'hands-on':['yt-6AkGhTBtR4o','yt-qypQmnlFjNk','yt-2qNfOa5AuVU'],business:['yt-ZzGzNdppGS8','yt-2lkx5NQbXrE','w05']};
const colors=['#A9E6D4','#BCA9F7','#E8B991','#F0B7DA','#EEA69B','#DAC695','#A8C7ED','#ACC7A0','#9FCED4','#D6B8ED','#CAC3B2','#B5BEEA'];
for(const [i,c] of catalog.channels.entries()){
 c.color=colors[i];c.seedArtifactIds=[...new Set([...(priorities[c.id]||[]),...c.seedArtifactIds])];
 if(c.id==='visual-memes')c.seedArtifactIds=c.seedArtifactIds.filter(id=>!['yt-rc4ubS4KNZc','yt-_AXxnQjz0Sg'].includes(id));
 c.coverArtifactId=c.seedArtifactIds.find(id=>a.get(id)?.thumbnailUrl)||c.seedArtifactIds[0];
 c.programReason='Start with context, then add a different perspective. Candidate videos remain labeled until content review.';
 if(c.id==='competition')c.programReason='The original response first, then reporting, then a product comparison. Brand statements and analysis remain distinct.';
 if(c.id==='visual-memes')c.programReason='Inspect the image post, read the reporting, then explore the discussion. An allegation is not a finding.';
}
for(const v of a.values()){
 v.firstObservedAt ||= inventory.generatedAt;
 v.language=v.platform==='YouTube' ? (v.defaultAudioLanguage ?? null) : (v.id==='w23'?'es':v.id==='w28'?'zh':'en');
 v.languageBasis=v.platform==='YouTube'?'Publisher-declared audio language; speech not independently checked':'Research text language; full media language not independently checked';
 v.why ||= v.limitations || 'A research candidate for this topic. Publisher metadata alone does not verify its claims.';
 v.contentKind ||= v.platform==='YouTube'?'Video candidate':'Source';
 v.browseEligible=true;
}
const scene={missionId:catalog.missionId,revision:1,mode:'research',passenger:'business',selectedChannelId:'competition',followedChannelIds:[],channels:catalog.channels,artifacts:[...a.values()],recordedAt:inventory.youtubeLatestMetadataObservedBy,evidenceUpdatedOn:'2026-09-10',eventOrigin:catalog.eventOrigin,discovery:{youtube:107,webSocial:34},lastEvent:'RESEARCH_SNAPSHOT',updatedAt:new Date().toISOString()};
await writeFile(new URL('explorer.json',assets),JSON.stringify(scene,null,2));
console.log('Prepared 12 channels and 141 evidence records. No secrets read.');
