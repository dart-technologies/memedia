# MeMedia static Vercel preview handoff

Prepared 2026-09-10T17:19:32.689874+00:00. Status: **locally verified, not deployed**.

## Reviewable upload

- Candidate destination: signed-in Vercel workspace **Dart Technologies**, slug `michow`, observed at https://vercel.com/michow . User approval still required; project name availability and deployment permissions remain to be verified when approved.
- Proposed new project: `memedia-preview`, public recorded-research explorer. Do not overwrite any existing project with that name.
- Upload directory: `/Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/outputs/memedia-vercel-preview`.
- Public payload: 43 files / 42,500,447 bytes of compiled Flutter, Flutter engine resources, public source metadata, MIT license and third-party notices. The package also has hosting configuration and a local file-hash manifest.
- Credentials/environment variables: **none**. No Node backend, live mission state, source checkout or `.env` upload. No API keys in browser code.
- Public functionality: 12 channels, source rails, thumbnails, raw views/likes, provenance, event-horizon filtering, local saved navigation. Live API actions explain their unavailability and preserve the scene.
- Remote thumbnails load from provider URLs; linked source pages remain subject to their own availability. Media bytes were not downloaded into the package. Platform marks identify origin, not endorsement or factual certification.

The manifest is `/Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/outputs/memedia-vercel-preview/DEPLOYMENT-MANIFEST.json`. SHA-256 checks passed for every public file; a private comparison against all three populated secrets found zero matches across all 46 package files.

## Reproduce the package

```sh
cd /Users/dartbot/dev/memedia
export PATH="/Users/dartbot/.nvm/versions/node/v24.18.1/bin:/Users/dartbot/dev/flutter/bin:$PATH"
node scripts/prepare-explorer.mjs
cd apps/flutter_app
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --no-web-resources-cdn --no-pub
cd ../..
node scripts/package-preview.mjs '/Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/outputs/memedia-vercel-preview'
python3 -m http.server 8791 --bind 127.0.0.1 --directory '/Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/outputs/memedia-vercel-preview/public'
```

Port 8791 is already running at handoff. Do not launch a duplicate. Rebuilding the package updates its manifest and byte count; recheck exclusion before a later upload.

Use the **isolated package as the Vercel project root**, with framework Other, no build command, and output directory `public`. The package's vercel.json records those settings. The repository-root vercel.json is a local prebuilt convenience; Git integration alone cannot build this checkout because Flutter build output is ignored and the Vercel build environment has not been provisioned with the pinned Flutter SDK. No continuous deployment is configured.

## Approval boundary

Automatic approval review rejected deployment because the destination account, visibility, upload payload and environment-variable handling were unspecified. The package above resolves the payload ambiguity; approval for this named workspace and public static upload is the remaining step. Do not retry deployment through another tool to bypass that rejection. No production alias promotion, domain change or repository publication is proposed.

## Hosted live follow-up

A live hosted demo needs a separately reviewed backend deployment with server-only credentials, per-user or demo access limits, provider budgets and durable mission storage. The current local filesystem snapshot/journal is not durable Vercel Function storage. Keep the existing local credentials private until a specific hosted server environment is approved. The preview is explicitly recorded research, not an Astra recording replay.
