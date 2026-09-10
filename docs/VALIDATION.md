# Baseline validation — September 10, 2026

**Installed baseline verified:** `/Users/dartbot/dev/memedia`. See [the actual readiness report](ENVIRONMENT-READINESS.md) for timestamps, evidence, versions and limits.

- Installer completed after checking the empty destination and expected origin. Three private keys preserved; mode 0600; Git ignore and source/build credential scan passed.
- `node scripts/verify.mjs` passed after approved Flutter cache access and a one-line lint correction: 9 backend tests, dependency resolution, clean Flutter analysis, 1 widget test, release web build and successful Wasm dry run.
- Both YouTube keys passed independently (8 candidates each). `gpt-6-astra` returned a valid structured synthetic smoke decision and two valid live eight-item programming responses.
- Chrome verified fixture discovery/programming/passenger queue changes, live discovery/programming/passenger state changes, source opening, visible disconnected-backend failure, and restart persistence.
- Live mission retained 8 candidates through revisions 1–3. Astra selected HOLD/KILL only, so the live NOW/NEXT queue stayed empty.
- Fixed missing UTF-8 charset on both A2UI responses; browser accents/emoji now render correctly. Backend tests passed again after the fix.
- Direct HTTP checks rejected stale revision, invalid JSON, unexpected Origin and non-JSON requests without changing accepted state.
- Desktop and 1024×768 Chrome layout inspected. Star labels overlap; HTML entity normalization and empty-queue messaging remain presentation issues. Actual iPad/Safari and frame timing untested.
- Build succeeded with a nonfatal missing Cupertino-font warning. TypeScript compiler checking, async API tools/steering, verified evidence, history and replay remain outside the completed baseline checks.

The local private configuration is now live/primary. Server left running at `http://127.0.0.1:8787`; Chrome shows the restored business mission at revision 3. No commit or push. These results validate the installed checkout; the earlier ZIP was not regenerated.
