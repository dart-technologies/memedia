import seed from '../apps/flutter_app/assets/explorer.json' with {type:'json'};
import {join} from 'node:path';
import {tmpdir} from 'node:os';
import {ExplorerCache} from '../backend/src/explorer.ts';
import {readConfig} from '../backend/src/config.ts';
import {hostedHandler} from '../backend/src/hosted.ts';
let cached:Promise<ExplorerCache>|undefined;
async function getCache(){
 if(!cached)cached=(async()=>{
  const cache=new ExplorerCache(join(tmpdir(),'memedia-explorer-cache.json'),readConfig({...process.env,DEMO_MODE:'live'}),seed);
  await cache.init();return cache;
 })().catch(error=>{cached=undefined;throw error;});
 return cached;
}
export default hostedHandler(getCache);
