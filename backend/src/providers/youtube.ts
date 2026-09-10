import type { Config } from '../config.ts';
import type { Artifact } from '../model.ts';
import { ProviderError, safeFetch } from './http.ts';

export async function discoverYouTube(config:Config, query:string, fetcher:typeof fetch=fetch, options:{order?:'relevance'|'viewCount',maxResults?:number,global?:boolean}={}): Promise<Artifact[]> {
  let key = config.youtubeSlot==='primary' ? config.youtubePrimary : config.youtubeBackup;
  if(!key) throw new ProviderError('YOUTUBE_KEY_MISSING',503);
  const primaryAttempt = async (apiKey:string) => {
    const url=new URL('https://www.googleapis.com/youtube/v3/search');
    for(const [k,v] of Object.entries({part:'snippet',type:'video',q:query,maxResults:String(options.maxResults??8),order:options.order??'relevance',relevanceLanguage:'en',...(options.global?{}:{regionCode:'US'}),publishedAfter:'2026-09-09T00:00:00Z',key:apiKey})) url.searchParams.set(k,v);
    const response=await safeFetch(fetcher,url,{});
    const json=await response.json().catch(()=>({}));
    return {response,json};
  };
  let {response,json}=await primaryAttempt(key);
  const reasons=(json.error?.errors ?? []).map((e:{reason?:string})=>e.reason);
  // Backup is for key rotation/recovery, never a quota-exhaustion workaround.
  const invalidKey=reasons.some((r:string)=>['keyInvalid','keyExpired'].includes(r)) ||
    (json.error?.details ?? []).some((e:{reason?:string})=>e.reason==='API_KEY_INVALID');
  if(!response.ok && invalidKey && config.youtubeSlot==='primary' && config.youtubeBackup && config.youtubeBackup!==key) {
    key=config.youtubeBackup;
    ({response,json}=await primaryAttempt(key));
  }
  if(!response.ok) {
    const quota=(json.error?.errors ?? []).some((e:{reason?:string})=>['quotaExceeded','dailyLimitExceeded','rateLimitExceeded'].includes(e.reason ?? ''));
    throw new ProviderError(quota?'YOUTUBE_QUOTA_EXCEEDED':`YOUTUBE_HTTP_${response.status}`,quota?429:502);
  }
  const now=new Date().toISOString();
  const candidates:Artifact[] = (Array.isArray(json.items)?json.items:[]).filter((item:any)=>
    /^[A-Za-z0-9_-]{11}$/.test(item.id?.videoId ?? '') && typeof item.snippet?.title==='string'
  ).map((item:any,i:number)=>({
    id:`yt-${item.id.videoId}`,title:item.snippet.title.slice(0,300),source:String(item.snippet.channelTitle || 'YouTube channel').slice(0,150),
    channel_id:item.snippet.channelId??null,source_type:'CREATOR',content_kind:'UNCLASSIFIED',url:`https://www.youtube.com/watch?v=${item.id.videoId}`,
    published_at:Number.isFinite(Date.parse(item.snippet.publishedAt))?new Date(item.snippet.publishedAt).toISOString():null,
    retrieved_at:now,first_observed_at:now,media_type:'VIDEO',cluster_id:'launch',authority_score:null,freshness_score:null,
    velocity_score:null,passenger_relevance:0.5,confidence:null,provenance_confidence:null,
    semantic_position:{x:(i+1)/9,y:0.5},editorial_status:'HOLD',reason_codes:['UNVERIFIED_CANDIDATE'],
    evidence_refs:[`https://www.youtube.com/watch?v=${item.id.videoId}`],
    metrics_basis:'YouTube API metadata only; editorial and factual verification pending',
    thumbnail_url:typeof item.snippet.thumbnails?.medium?.url==='string' && item.snippet.thumbnails.medium.url.startsWith('https://i.ytimg.com/')?item.snippet.thumbnails.medium.url:null,
  }));
  if(!candidates.length)return [];
  const detailsUrl=new URL('https://www.googleapis.com/youtube/v3/videos');
  for(const [k,v] of Object.entries({part:'snippet,statistics,contentDetails,status',id:candidates.map(a=>a.id.slice(3)).join(','),key}))detailsUrl.searchParams.set(k,v);
  const detailsResponse=await safeFetch(fetcher,detailsUrl,{});
  if(!detailsResponse.ok)throw new ProviderError('YOUTUBE_DETAILS_UNAVAILABLE',502);
  const details=await detailsResponse.json();
  const byId=new Map((details.items??[]).map((v:any)=>[v.id,v]));
  const count=(v:unknown)=>typeof v==='string' && /^\d+$/.test(v)?v:null;
  return candidates.map(a=>{const v:any=byId.get(a.id.slice(3));return {...a,views:count(v?.statistics?.viewCount),likes:count(v?.statistics?.likeCount),metrics_observed_at:v?new Date().toISOString():null,duration_iso:v?.contentDetails?.duration??null,audio_language:v?.snippet?.defaultAudioLanguage??null,embeddable:v?.status?.embeddable??null};});
}
