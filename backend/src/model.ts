export type Passenger = 'general' | 'business';
export type Status = 'NOW' | 'NEXT' | 'HOLD' | 'KILL';
export type Artifact = {
  id: string; title: string; source: string; source_type: 'CREATOR' | 'PRIMARY';
  content_kind: 'UNCLASSIFIED'; url: string | null; published_at: string | null;
  retrieved_at: string; first_observed_at: string; media_type: 'VIDEO' | 'FIXTURE';
  cluster_id: string; authority_score: number | null; freshness_score: number | null;
  velocity_score: number | null; passenger_relevance: number; confidence: number | null;
  provenance_confidence: number | null; semantic_position: {x:number;y:number};
  editorial_status: Status; reason_codes: string[]; evidence_refs: string[];
  metrics_basis: string; thumbnail_url: string | null;
  channel_id?:string|null;
  views?:string|null;likes?:string|null;metrics_observed_at?:string|null;duration_iso?:string|null;audio_language?:string|null;embeddable?:boolean|null;
};
export type Decision = {artifact_id:string; relevance:number; cluster_id:string; status:Status; reason_codes:string[]};
export const clusters = ['launch','competition','culture','business'] as const;
export const statuses: Status[] = ['NOW','NEXT','HOLD','KILL'];
export function validateDecisions(value: unknown, artifacts: Artifact[]): Decision[] {
  if (!Array.isArray(value) || value.length !== artifacts.length) throw new Error('DECISION_COUNT_INVALID');
  const remaining = new Set(artifacts.map(a=>a.id));
  const result: Decision[] = [];
  for (const row of value) {
    if (!row || typeof row!=='object' || !remaining.delete(row.artifact_id) ||
      typeof row.relevance!=='number' || !Number.isFinite(row.relevance) || row.relevance<0 || row.relevance>1 ||
      !clusters.includes(row.cluster_id) || !statuses.includes(row.status) ||
      !Array.isArray(row.reason_codes) || row.reason_codes.length>5 ||
      !row.reason_codes.every((v:unknown)=>typeof v==='string' && /^[A-Z_]{1,48}$/.test(v))) {
      throw new Error('DECISION_SCHEMA_INVALID');
    }
    result.push({artifact_id:row.artifact_id,relevance:row.relevance,cluster_id:row.cluster_id,status:row.status,reason_codes:row.reason_codes});
  }
  if (result.filter(r=>r.status==='NOW').length>1) throw new Error('MULTIPLE_NOW_ITEMS');
  return result;
}
export function fixtureArtifacts(): Artifact[] {
  return ['Launch sample','Competition sample','Culture sample'].map((title,i)=>({
    id:`fixture-${i+1}`,title,source:'Synthetic setup fixture',source_type:'PRIMARY',content_kind:'UNCLASSIFIED',
    url:null,published_at:null,retrieved_at:new Date().toISOString(),first_observed_at:new Date().toISOString(),
    media_type:'FIXTURE',cluster_id:clusters[i],authority_score:null,freshness_score:null,velocity_score:null,
    passenger_relevance:0.5,confidence:null,provenance_confidence:null,semantic_position:{x:0.25+i*0.25,y:0.5},
    editorial_status:'HOLD',reason_codes:['SETUP_FIXTURE'],evidence_refs:[],metrics_basis:'synthetic fixture; no measured metrics',thumbnail_url:null,
  }));
}
