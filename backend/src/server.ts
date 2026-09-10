import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import {resolve,extname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {readConfig,readiness} from './config.ts';
import {MissionStore} from './state.ts';
import {initializeSurface,updateScene,surfaceId} from './a2ui.ts';
import {fixtureArtifacts} from './model.ts';
import {discoverYouTube} from './providers/youtube.ts';
import {FixtureEditorialProvider,OpenAIEditorialProvider} from './providers/openai.ts';
import {ExplorerCache} from './explorer.ts';
import {ProviderError} from './providers/http.ts';

const config=readConfig();
const root=resolve(fileURLToPath(new URL('.',import.meta.url)),'../..');
const webRoot=resolve(root,'apps/flutter_app/build/web');
const store=new MissionStore(resolve(root,`data/mission-${config.mode}.json`),config.mode);
await store.init();
const editorial=config.mode==='live'?new OpenAIEditorialProvider(config):new FixtureEditorialProvider();
const explorerSeed=JSON.parse(await readFile(resolve(root,'apps/flutter_app/assets/explorer.json'),'utf8'));
const explorer=new ExplorerCache(resolve(root,'data/explorer-cache.json'),config,explorerSeed);
await explorer.init();
let busy=false;
const mime:Record<string,string>={'.html':'text/html','.js':'text/javascript','.json':'application/json','.wasm':'application/wasm','.css':'text/css','.png':'image/png','.svg':'image/svg+xml','.ico':'image/x-icon','.woff2':'font/woff2'};
createServer(async(req,res)=>{
  const json=(status:number,data:object)=>{res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store'}).end(JSON.stringify(data));};
  try {
    const url=new URL(req.url!,'http://localhost');
    if(req.method==='GET' && url.pathname==='/api/explorer'){json(200,explorer.overview());return;}
    if(req.method==='POST' && url.pathname==='/api/explorer/refresh'){
      if(req.headers.origin && ![`http://127.0.0.1:${config.port}`,`http://localhost:${config.port}`].includes(req.headers.origin)){json(403,{error:'ORIGIN_NOT_ALLOWED'});return;}
      if(!req.headers['content-type']?.startsWith('application/json')){json(415,{error:'JSON_REQUIRED'});return;}
      let body='';for await(const chunk of req){body+=chunk;if(Buffer.byteLength(body)>1024){json(413,{error:'BODY_TOO_LARGE'});return;}}
      let input;try{input=JSON.parse(body);}catch{json(400,{error:'INVALID_JSON'});return;}
      if(typeof input.key!=='string'||input.key.length>80){json(400,{error:'INVALID_KEY'});return;}
      json(200,await explorer.refresh(input.key));return;
    }
    if(req.method==='GET' && url.pathname==='/api/health') {json(200,{status:'ok',...readiness(config),busy,revision:store.state.revision});return;}
    if(req.method==='GET' && url.pathname==='/api/state') {json(200,store.state);return;}
    if(req.method==='GET' && url.pathname==='/api/surface') {
      res.writeHead(200,{'Content-Type':'text/plain; charset=utf-8','Cache-Control':'no-store'}).end(initializeSurface(store.state));return;
    }
    if(req.method==='POST' && url.pathname==='/api/action') {
      if(req.headers.origin && ![`http://127.0.0.1:${config.port}`,`http://localhost:${config.port}`].includes(req.headers.origin)) {json(403,{error:'ORIGIN_NOT_ALLOWED'});return;}
      if(!req.headers['content-type']?.startsWith('application/json')) {json(415,{error:'JSON_REQUIRED'});return;}
      let body='';
      for await(const chunk of req){body+=chunk;if(Buffer.byteLength(body)>16384){json(413,{error:'BODY_TOO_LARGE'});return;}}
      let payload;try{payload=JSON.parse(body);}catch{json(400,{error:'INVALID_JSON'});return;}
      const action=payload.action;
      if(payload.version!=='v0.9' || action?.surfaceId!==surfaceId || !['discover','reprogram','passenger'].includes(action.name)) {json(400,{error:'INVALID_ACTION'});return;}
      if(busy || action.context?.revision!==store.state.revision){json(409,{error:'BUSY_OR_STALE_REVISION'});return;}
      busy=true;
      try {
        if(action.name==='discover') {
          const query=action.context?.query ?? 'Apple iPhone Duo';
          if(typeof query!=='string' || query.length<2 || query.length>160){json(400,{error:'INVALID_QUERY'});return;}
          await store.ingest(config.mode==='fixture'?fixtureArtifacts():await discoverYouTube(config,query));
        } else {
          const passenger=action.name==='passenger'?action.context?.passenger:store.state.passenger;
          if(passenger!=='business' && passenger!=='general'){json(400,{error:'INVALID_PASSENGER'});return;}
          if(!store.state.artifacts.length){json(409,{error:'DISCOVER_FIRST'});return;}
          const decisions=await editorial.program(store.state.artifacts,passenger);
          await store.program(decisions,passenger);
        }
        res.writeHead(200,{'Content-Type':'text/plain; charset=utf-8','Cache-Control':'no-store'}).end(updateScene(store.state));
      } finally {busy=false;}
      return;
    }
    if(req.method!=='GET'){json(405,{error:'METHOD_NOT_ALLOWED'});return;}
    const path=resolve(webRoot,'.'+(url.pathname==='/'?'/index.html':decodeURIComponent(url.pathname)));
    if(!path.startsWith(webRoot+'/')){json(403,{error:'FORBIDDEN'});return;}
    try{res.setHeader('Content-Type',mime[extname(path)] ?? 'application/octet-stream');res.end(await readFile(path));}
    catch{json(404,{error:'WEB_BUILD_OR_FILE_MISSING',next:'Run the Flutter web build; see README.'});}
  }catch(error){
    // Never return upstream response bodies, request URLs, headers or credentials.
    const known=error instanceof ProviderError;
    json(known?error.status:500,{error:known?error.code:'INTERNAL_ERROR',revision:store.state.revision});
    console.error(JSON.stringify({event:'request_failed',code:known?error.code:'INTERNAL_ERROR'}));
  }
}).on('error',(error:NodeJS.ErrnoException)=>{
  console.error(JSON.stringify({event:'server_start_failed',code:error.code ?? 'LISTEN_FAILED',port:config.port}));
  process.exitCode=1;
}).listen(config.port,'127.0.0.1',()=>console.log(`MeMedia ${config.mode} baseline: http://127.0.0.1:${config.port}`));
