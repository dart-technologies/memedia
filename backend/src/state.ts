import { appendFile, mkdir, writeFile, rename, readFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import type { Artifact, Decision, Passenger } from './model.ts';
export type MissionState = {missionId:string;revision:number;mode:'fixture'|'live';passenger:Passenger;artifacts:Artifact[];lastEvent:string;updatedAt:string};
export class MissionStore {
  state:MissionState;
  private path:string;
  constructor(path:string,mode:'fixture'|'live') {
    this.path=path;
    this.state={missionId:crypto.randomUUID(),revision:0,mode,passenger:'general',artifacts:[],lastEvent:'READY',updatedAt:new Date().toISOString()};
  }
  async init() {
    await mkdir(dirname(this.path),{recursive:true});
    try {
      const saved=JSON.parse(await readFile(this.path,'utf8'));
      if(saved.mode===this.state.mode && typeof saved.missionId==='string' && Number.isInteger(saved.revision) && Array.isArray(saved.artifacts))this.state=saved;
    }catch(error:any){if(error.code!=='ENOENT')throw new Error('STATE_FILE_INVALID');}
  }
  async commit(patch:Partial<MissionState>,event:string) {
    const next={...this.state,...patch,revision:this.state.revision+1,lastEvent:event,updatedAt:new Date().toISOString()};
    await writeFile(this.path+'.tmp',JSON.stringify(next,null,2));
    await rename(this.path+'.tmp',this.path);
    this.state=next;
    await appendFile(this.path+'.jsonl',JSON.stringify({event,revision:next.revision,at:next.updatedAt,snapshot:next})+'\n');
  }
  async ingest(items:Artifact[]) {
    const byId=new Map(this.state.artifacts.map(a=>[a.id,a]));
    for(const item of items)if(!byId.has(item.id) && byId.size<40)byId.set(item.id,item);
    if(byId.size===this.state.artifacts.length)return;
    await this.commit({artifacts:[...byId.values()]},'SIGNALS_DISCOVERED');
  }
  async program(decisions:Decision[],passenger:Passenger) {
    const byId=new Map(decisions.map(d=>[d.artifact_id,d]));
    const artifacts=this.state.artifacts.map(a=>{
      const decision=byId.get(a.id)!;
      return {...a,cluster_id:decision.cluster_id,passenger_relevance:decision.relevance,
        editorial_status:decision.status,reason_codes:decision.reason_codes};
    });
    await this.commit({artifacts,passenger},'PROGRAM_UPDATED');
  }
}
