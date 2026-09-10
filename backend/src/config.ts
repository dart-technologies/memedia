export type Config = {
  mode: 'fixture' | 'live'; port: number; model: string;
  openaiKey: string; youtubePrimary: string; youtubeBackup: string;
  youtubeSlot: 'primary' | 'backup';
};
export function readConfig(env: NodeJS.ProcessEnv = process.env): Config {
  const mode = env.DEMO_MODE || 'fixture';
  const youtubeSlot = env.YOUTUBE_KEY_SLOT || 'primary';
  const port = Number(env.PORT || 8787);
  if (mode !== 'fixture' && mode !== 'live') throw new Error('DEMO_MODE must be fixture or live');
  if (youtubeSlot !== 'primary' && youtubeSlot !== 'backup') throw new Error('Invalid YOUTUBE_KEY_SLOT');
  if (!Number.isInteger(port) || port < 1024 || port > 65535) throw new Error('Invalid PORT');
  return {mode,port,youtubeSlot,model:env.OPENAI_MODEL || 'gpt-6-astra',
    openaiKey:env.OPENAI_API_KEY?.trim() || '',youtubePrimary:env.YOUTUBE_API_KEY_PRIMARY?.trim() || '',
    youtubeBackup:env.YOUTUBE_API_KEY_BACKUP?.trim() || ''};
}
export function readiness(config: Config) {
  return {mode:config.mode,model:config.model,openaiConfigured:!!config.openaiKey,
    youtubePrimaryConfigured:!!config.youtubePrimary,youtubeBackupConfigured:!!config.youtubeBackup,
    youtubeKeySlot:config.youtubeSlot};
}
