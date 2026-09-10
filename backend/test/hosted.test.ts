import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {hostedHandler} from '../src/hosted.ts';
import {ProviderError} from '../src/providers/http.ts';
import type {ExplorerCache} from '../src/explorer.ts';

test('hosted explorer routes same-origin refresh and hides provider errors',async()=>{
 let calls=0;
 const fake={data:{entries:{}},pending:new Map(),overview:()=>({world:{topics:[]},entries:{}}),refresh:async(key:string)=>{calls++;if(key==='fail')throw new ProviderError('CURATION_UNAVAILABLE',502);return {key,revision:1};}} as unknown as ExplorerCache;
 const server=createServer(hostedHandler(async()=>fake));
 await new Promise<void>(r=>server.listen(0,'127.0.0.1',r));
 const {port}=server.address() as {port:number};
 const base=`http://127.0.0.1:${port}`;
 try{
  assert.equal((await fetch(base+'/api?route=health')).status,200);
  assert.deepEqual(await (await fetch(base+'/api?route=explorer')).json(),{world:{topics:[]},entries:{}});
  const post=(origin:string,key:string)=>fetch(base+'/api?route=refresh',{method:'POST',headers:{origin,'Content-Type':'application/json'},body:JSON.stringify({key})});
  assert.equal((await post('https://other.example','hands-on')).status,403);assert.equal(calls,0);
  const good=await post(`https://127.0.0.1:${port}`,'hands-on');assert.equal(good.status,200);assert.equal((await good.json()).revision,1);
  const failed=await post(`https://127.0.0.1:${port}`,'fail');assert.equal(failed.status,502);assert.deepEqual(await failed.json(),{error:'CURATION_UNAVAILABLE'});
  const huge=await fetch(base+'/api?route=refresh',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({key:'x'.repeat(1200)})});assert.equal(huge.status,413);
 }finally{await new Promise<void>(r=>server.close(()=>r()));}
});
