import {readFile,writeFile} from 'node:fs/promises';
import {creatorStats,worldTrends} from '../backend/src/explorer.ts';
import {readConfig} from '../backend/src/config.ts';
const path=new URL('../apps/flutter_app/assets/explorer.json',import.meta.url);
const scene=JSON.parse(await readFile(path,'utf8'));
const config=readConfig();
const rows=scene.artifacts.filter(a=>a.platform==='YouTube');
const byId=new Map();
for(let i=0;i<rows.length;i+=40){const stats=await creatorStats(config,rows.slice(i,i+40).map(a=>({channel_id:a.channelId})),fetch);for(const [id,s] of stats)byId.set(id,s);}
for(const a of rows){const stats=byId.get(a.channelId);if(stats){a.creatorSubscribers=stats.subscribers;a.creatorCountry=stats.creatorCountry;a.creatorStatsObservedAt=new Date().toISOString();}}
scene.world=await worldTrends(fetch,config);scene.galaxyVersion=4;
await writeFile(path,JSON.stringify(scene,null,2));
console.log(JSON.stringify({creatorChannels:byId.size,worldTopics:scene.world.topics.map(t=>({label:t.label,flags:t.regions,searchVolumeFloor:t.searchVolumeFloor})),feeds:scene.world.regions.length,unavailable:scene.world.unavailableRegions}));
