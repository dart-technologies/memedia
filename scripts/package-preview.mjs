import {cp,mkdir,readFile,readdir,writeFile} from 'node:fs/promises';
import {resolve,relative} from 'node:path';
import {createHash} from 'node:crypto';
const root=resolve(new URL('..',import.meta.url).pathname);
const output=resolve(process.argv[2] || resolve(root,'preview-package'));
if(output===root || output.startsWith(resolve(root,'backend')))throw new Error('INVALID_OUTPUT');
await mkdir(resolve(output,'public'),{recursive:true});
await cp(resolve(root,'apps/flutter_app/build/web'),resolve(output,'public'),{recursive:true});
await cp(resolve(root,'LICENSE'),resolve(output,'public/LICENSE.txt'));
await cp(resolve(root,'THIRD_PARTY_NOTICES.md'),resolve(output,'public/THIRD_PARTY_NOTICES.md'));
await writeFile(resolve(output,'vercel.json'),JSON.stringify({version:2,framework:null,buildCommand:null,outputDirectory:'public',headers:[{source:'/(.*)',headers:[{key:'X-Content-Type-Options',value:'nosniff'},{key:'Referrer-Policy',value:'strict-origin-when-cross-origin'}]},{source:'/assets/assets/explorer.json',headers:[{key:'Cache-Control',value:'no-store'}]}]},null,2));
await writeFile(resolve(output,'.vercelignore'),'.env\n.env.*\nnode_modules\nDEPLOYMENT-MANIFEST.json\n');
const files=[];
async function walk(dir){for(const e of await readdir(dir,{withFileTypes:true})){const path=resolve(dir,e.name);if(e.isSymbolicLink())throw new Error('SYMLINK_NOT_ALLOWED');if(e.isDirectory())await walk(path);else {const name=relative(output,path);if(/(^|\/)(\.env|backend|data|node_modules|\.git)(\/|$|\.)/.test(name))throw new Error('PRIVATE_PATH_IN_PACKAGE');const body=await readFile(path);files.push({path:name,bytes:body.length,sha256:createHash('sha256').update(body).digest('hex')});}}}
await walk(resolve(output,'public'));
const report={generatedAt:new Date().toISOString(),purpose:'Vercel preview of the recorded Flutter research explorer',payload:'Compiled Flutter public files and dated public source metadata only',environmentVariables:[],backendIncluded:false,liveApiCallsAvailable:false,visibility:'Requires destination approval; no deployment performed',fileCount:files.length,totalBytes:files.reduce((s,f)=>s+f.bytes,0),files};
await writeFile(resolve(output,'DEPLOYMENT-MANIFEST.json'),JSON.stringify(report,null,2));
console.log(JSON.stringify({output,fileCount:report.fileCount,totalBytes:report.totalBytes,environmentVariables:0,backendIncluded:false}));
