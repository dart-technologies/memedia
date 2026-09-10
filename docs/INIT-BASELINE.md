# Install this baseline into the empty GitHub checkout

Intended destination: `/Users/dartbot/dev/memedia` with origin `https://github.com/dart-technologies/memedia.git`.

The scaffold is delivered as a folder and a secret-free archive. Do not overwrite an existing implementation or replace `.git`. If the repository is still empty, copy the baseline contents excluding `backend/.env` and generated/runtime data. Preserve the repository's existing Git metadata.

On this Mac, the adjacent installer checks the repository origin and refuses a nonempty destination. It copies the populated private environment separately with mode 0600. Run it in a local terminal with write access:

```sh
python3 /Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/outputs/install-memedia-baseline.py
cd /Users/dartbot/dev/memedia
export PATH="/Users/dartbot/.nvm/versions/node/v24.18.1/bin:/Users/dartbot/dev/flutter/bin:$PATH"
```

From the copied baseline root:

```sh
npm run init:env
npm test
node scripts/verify.mjs
git status --short
git check-ignore backend/.env
```

Fill `.env` in the destination locally, or transfer the already populated file privately with mode 0600. The archive omits it. Do not paste or commit keys.

Before an initial commit, inspect the diff and ensure `.env`, API logs, recordings with private data, and build/dependency directories are excluded. Keep `backend/.env.example`, app source, docs, lockfiles, and LICENSE. Review recorded state separately; the baseline ignores it by default.

Suggested commit message: `Initialize MeMedia Flutter web and API baseline`.

No commit, push, release, deployment, or visibility change is performed automatically. GitHub authentication/write permission was verified earlier, but local filesystem permission is a separate requirement.
