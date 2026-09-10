import type {IncomingMessage,ServerResponse} from 'node:http';
import {ProviderError} from './providers/http.ts';
import type {ExplorerCache} from './explorer.ts';

// One handler serves the hosted explorer. Legacy mission endpoints remain local.
export function hostedHandler(getCache:()=>Promise<ExplorerCache>){
 let budgetStart=Date.now(),starts=0;
 return async(req:IncomingMessage & {body?:unknown},res:ServerResponse)=>{
  const json=(status:number,data:object)=>res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'}).end(JSON.stringify(data));
  try{
   const url=new URL(req.url??'/','https://localhost');
   const route=url.searchParams.get('route')??url.pathname.replace(/^\/api\//,'');
   if(req.method==='GET'&&route==='health'){json(200,{status:'ok',mode:'live',cachePersistence:'ephemeral-instance',snapshotFallback:true});return;}
   if(req.method==='GET'&&route==='explorer'){json(200,(await getCache()).overview());return;}
   if(req.method!=='POST'||!['refresh','explorer/refresh'].includes(route)){json(404,{error:'NOT_FOUND'});return;}
   if(req.headers.origin&&req.headers.origin!==`https://${req.headers.host}`){json(403,{error:'ORIGIN_NOT_ALLOWED'});return;}
   if(!req.headers['content-type']?.startsWith('application/json')){json(415,{error:'JSON_REQUIRED'});return;}
   let input:any;
   if(req.body!==undefined){const body=typeof req.body==='string'?req.body:JSON.stringify(req.body);if(Buffer.byteLength(body)>1024){json(413,{error:'BODY_TOO_LARGE'});return;}try{input=JSON.parse(body);}catch{json(400,{error:'INVALID_JSON'});return;}}
   else {let body='';for await(const chunk of req){body+=chunk;if(Buffer.byteLength(body)>1024){json(413,{error:'BODY_TOO_LARGE'});return;}}try{input=JSON.parse(body);}catch{json(400,{error:'INVALID_JSON'});return;}}
   if(!input||typeof input.key!=='string'||input.key.length>80){json(400,{error:'INVALID_KEY'});return;}
   const cache=await getCache();
   const entry=input.key==='world'?cache.data.world:cache.data.entries[input.key];
   const age=Date.now()-Date.parse(entry?.checkedAt??entry?.observedAt??'');
   const hit=entry?.rankingVersion===2&&age<(input.key==='world'?600000:120000);
   if(!hit&&!cache.pending.has(input.key)){
    if(Date.now()-budgetStart>3600000){budgetStart=Date.now();starts=0;}
    if(starts>=30){res.setHeader('Retry-After','3600');json(429,{error:'DEMO_SCAN_LIMIT',retained:true});return;}
    starts++;
   }
   json(200,await cache.refresh(input.key));
  }catch(error){json(error instanceof ProviderError?error.status:500,{error:error instanceof ProviderError?error.code:'INTERNAL_ERROR'});}
 };
}
