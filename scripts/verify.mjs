import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('..',import.meta.url));
const app=fileURLToPath(new URL('../apps/flutter_app',import.meta.url));
for(const [command,args,cwd] of [
  ['npm',['test'],root],
  ['flutter',['pub','get'],app],
  ['flutter',['analyze'],app],
  ['flutter',['test'],app],
  ['flutter',['build','web','--release'],app],
]){
  console.log(`Running ${command} ${args.join(' ')}`);
  const result=spawnSync(command,args,{cwd,stdio:'inherit'});
  if(result.error){console.error(result.error.message);process.exit(1);}
  if(result.status!==0)process.exit(result.status ?? 1);
}
