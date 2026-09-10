# MeMedia — release v6

Verified September 10, 2026. The user authorized deployment and production-only credential provisioning.

## Live demo

- Public URL: https://memedia-pi.vercel.app/
- Deployment: `dpl_2a8AjXuqSmwwDavph6qZWWb4xve5` (READY, production)
- Immutable deployment URL: https://memedia-d9pz3nyc2-michow.vercel.app/
- Vercel destination: Dart Technologies, `michow/memedia`.
- Flutter frontend and Node API ship together. The three API keys exist only in the production server environment, not preview environments or client assets.

## Delivered

The discovery view centers iPhone Duo, keeps related showcase channels nearby, and arranges other unfolding topics around it. Every surrounding topic displays one primary observation flag. Freshly pooled duplicates choose the country with the highest reported volume bucket; all observed countries remain in provenance. Flags do not imply nationality.

StellarSlate retains the twelve connected editorial channels, thumbnail stacks, explanation controls, raw observed views/likes and separate freshness markers. Global topics are ranked across monitored feeds without country quotas; this is not an exhaustive worldwide popularity measurement.

Cold world refreshes advance beyond the bundled snapshot revision. A rejected stale response clears the scanning indicator and retains accepted media.

The hosted API preserves current media while bounded YouTube discovery and Astra metadata screening complete. Schema validation, same-origin browser checks, request size limits, sanitized provider errors and a per-instance scan budget are included. Cache hits and coalesced requests do not consume fresh-scan budget.

## Verification

| Check | Result |
|---|---|
| Versions | Flutter 3.47.3; Dart 3.13.3; GenUI 0.10.2; Node 24.18.1; TypeScript 5.9.3; Vercel CLI 59.15.1. |
| Backend tests | 19 passed, including primary flag selection and hosted HTTP success/error handling. |
| Flutter tests | 6 passed, including persistent A2UI surface updates and primary flag rendering. |
| Static checks | Flutter analysis clean; TypeScript `tsc --noEmit` passed. |
| Flutter web build | Release build passed; final compile 68.6 seconds. |
| Hosted GET requests | `/api/health` and `/api/explorer` returned HTTP 200; explorer had 12 global topics. |
| Hosted world refresh | Final deployment returned HTTP 200 in 12,776 ms; all 24 monitored feeds available, 12 topics, revision 4 beyond the bundled revision 3. The browser displayed Scanned just now. |
| Hosted live channel refresh | `/api/explorer/refresh`, key `hands-on`: HTTP 200 in 12,678 ms; 24 candidate artifacts, 21 accepted by `gpt-6-astra`. This is metadata fit, not factual/video verification. |
| Public Chrome | Centered discovery, one flag per topic, twelve-channel showcase, refresh status, ranked raw metrics and inline YouTube playback verified. Refresh retained the currently playing selection. No warning/error entries in the inspected console sample. |
| Secret audit | Actual private keys compared against publishable source and deployment files; no matches. Values were never displayed. |

The first two deployments exposed TypeScript import and module-format startup errors. The final deployment fixes both with `rewriteRelativeImportExtensions` and root `type: module`; the final world refresh and browser scan-status checks verify the subsequent cold-start fix. Channel screening and playback were also verified during this release before that fix.

## Reproduce

From the repository root, with Node 24.18.1 and Flutter on PATH:

```sh
npm ci
npm run typecheck
npm test
cd apps/flutter_app
flutter pub get
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
cd ../..
npx vercel@59.15.1 pull --yes --environment=production --scope michow
npx vercel@59.15.1 build --prod --standalone --yes
npx vercel@59.15.1 deploy --prebuilt --prod --yes --scope michow
```

Use an already authorized Vercel login. `--standalone` copies referenced files into the output so the bundled seed is available for local artifact checks. Keep all downloaded environment files ignored. Manage keys through Vercel's server-side production environment; never embed them in Flutter defines or assets.

## Boundaries

The hosted cache lives in `/tmp` on each warm function instance. It is ephemeral, not shared durable storage: cold starts, scaling and new deployments can return the labeled recorded snapshot. Local backend disk persistence remains separate. Functions have a 120-second limit; the client retains media on scan failures. The hourly scan budget is per instance, not a deployment-wide quota.

Autoplay depends on browser and platform policy; Chrome playback was observed. The in-app browser has a known nested-player limitation. Other platforms may offer source previews and original links rather than inline playback.

GitHub repository identity and ADMIN access were verified. The initially empty repository could not auto-connect during Vercel linking; this release uses direct CLI deployment. The baseline is committed locally after deployment; no Git push is performed in this release step.

Use [the recording script](RECORDING-SCRIPT-60S.md). Its ten-second segments are presentation pacing, not research latency guarantees.
