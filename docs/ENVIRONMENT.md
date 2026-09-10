# Environment and API keys

The active demo architecture uses direct OpenAI API access and public YouTube Data API reads from the Node backend. ChatGPT/Codex subscription authentication is not an OpenAI API key and is not used by this baseline provider.

| Variable | Purpose | Required |
|---|---|---|
| `OPENAI_API_KEY` | Bearer credential sent only to `https://api.openai.com/v1/responses` | Live Astra ranking |
| `OPENAI_MODEL` | Model identifier; default `gpt-6-astra` | Default supplied |
| `YOUTUBE_API_KEY_PRIMARY` | Primary credential for public video search | When primary slot is selected |
| `YOUTUBE_API_KEY_BACKUP` | Backup credential for explicit selection / invalid-primary recovery | Backup validation and recovery |
| `YOUTUBE_KEY_SLOT` | `primary` or `backup` | Defaults to primary |
| `DEMO_MODE` | `fixture` or `live` | Defaults to fixture |
| `PORT` | Loopback HTTP server port | Defaults to 8787 |

Node loads `backend/.env` through `--env-file-if-exists`. Existing process environment values take precedence over file values. Use `npm start` or `npm --prefix backend start` so the intended file is loaded from the backend directory. Never log the config object, send keys to Flutter, or use `--dart-define` for provider credentials.

## Provision and enter credentials

1. Create an OpenAI API project key in your own account and verify model/billing access. Enter it directly in the private `.env` file. Do not use a Codex authentication token as a substitute. [OpenAI quickstart](https://developers.openai.com/api/docs/quickstart).
2. Enable YouTube Data API v3 in your Google Cloud project and create the primary and backup API keys. Restrict them to the intended API and server usage. Public search does not require end-user OAuth. [YouTube setup](https://developers.google.com/youtube/v3/getting-started).
3. Fill the three key slots locally, run `npm run check:env`, then `npm run check:apis`. The latter is a live, billable/quota-consuming smoke check.
4. Change `DEMO_MODE=live` and restart the backend. Fixture mode is intentionally synthetic and never labeled live.

This work prepares local credential slots; it does not create provider-issued keys or activate provider billing on your behalf.

## Backup behavior

`YOUTUBE_KEY_SLOT=backup` uses the backup directly. With the primary selected, a recognized invalid/expired-key response may retry once using a distinct configured backup. Missing primary configuration does not silently use another key. Quota/rate-limit responses stop with a visible error and preserve accepted state.

Google quota is project-based, so another key in the same project is not additional quota. View actual limits in the provider console; this scaffold does not hard-code a historical search-quota cost. [Current quota documentation](https://developers.google.com/youtube/v3/getting-started#quota).

## Credential hygiene

- `npm run init:env` uses exclusive creation and mode 0600; it preserves existing values.
- `.env.example` is public and blank. `.env`, provider logs, and recorded state are ignored.
- Health/environment checks expose booleans and the selected slot, never key values or fragments.
- Provider failures return sanitized codes. YouTube request URLs contain a key and must not be added to logs.
- The supplied archive is generated from an allowlist that omits secrets, cached dependencies, and runtime state.

If keys were entered into the output scaffold before copying it to the repository, copy `.env` separately to the destination with mode 0600; it is intentionally absent from the archive. Never overwrite another existing credential file without reconciling it locally.
