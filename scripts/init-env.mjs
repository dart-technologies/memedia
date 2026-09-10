import {readFile,writeFile,chmod} from 'node:fs/promises';
const target=new URL('../backend/.env',import.meta.url);
try {
  await writeFile(target,await readFile(new URL('../backend/.env.example',import.meta.url)),{flag:'wx',mode:0o600});
  console.log('Created backend/.env. Fill the three key slots locally; do not paste keys into chat.');
} catch(error) {
  if(error.code!=='EEXIST')throw error;
  console.log('backend/.env already exists; values preserved.');
}
await chmod(target,0o600);
