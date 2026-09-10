import type { MissionState } from './state.ts';
export const surfaceId='stellar-slate';
export const catalogId='dev.memedia.stellar';
const wire=(message:object)=>'```json\n'+JSON.stringify(message)+'\n```\n';
export function initializeSurface(state:MissionState) {
  return wire({version:'v0.9',createSurface:{surfaceId,catalogId}})+
    wire({version:'v0.9',updateComponents:{surfaceId,components:[{id:'root',component:'StellarSlate',scene:{path:'/scene'}}]}})+updateScene(state);
}
export function updateScene(state:MissionState) {
  // One atomic scene branch keeps graph, queue, context and revision consistent.
  return wire({version:'v0.9',updateDataModel:{surfaceId,path:'/scene',value:state}});
}
