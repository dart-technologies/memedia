import { readConfig, readiness } from './config.ts';
const status=readiness(readConfig());
console.log(JSON.stringify(status,null,2));
if(!status.openaiConfigured || !(status.youtubeKeySlot==='primary'?status.youtubePrimaryConfigured:status.youtubeBackupConfigured))process.exitCode=1;
