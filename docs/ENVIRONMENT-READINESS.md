# MeMedia — environment readiness

## Playback and final-cut review

Headlines wrap fully; selected cards own playback; views/likes use compact notation with exact observations in detail. Channel/video URLs support reload and browser navigation. Eight Flutter tests and 21 backend/timer tests passed, analysis and TypeScript checking are clean, and the final release web build passed in 38.5 seconds. Chrome completed a 60-second director rehearsal and separate playback/deep-link checks. See [FINAL-CUT-REVIEW.md](FINAL-CUT-REVIEW.md) for source findings, grades, remaining limits and final-cut recommendations. This section supersedes earlier test counts and truncation behavior.

Production playback release: `dpl_4ynV3DTQrwS7WZWC3wgQTr61AGaF` (READY). Public route/API/assets passed, and Chrome verified direct playback and Next updating the URL. Source plus release audit: 164 files, zero private-key matches.

## Recording harness update

The presenter at `/recording.html` controls a clean `?demo=1` window, advancing the six ten-second script beats with a final showcase return at 56 seconds. Includes warm-up, pause/resume, manual jumps, restart and optional local WebM capture. 21 backend/timer tests and six Flutter tests pass; analysis is clean and the final release web compile passed in 38.4 seconds. Chrome completed the full 60-second rehearsal, including explanation routes, live cache warm-up and inline playback. Native tab-capture permission/download remains user-driven. See [RECORDING-HARNESS.md](RECORDING-HARNESS.md).

## Previous v6 production verification

[MeMedia is live](https://memedia-pi.vercel.app/) on Vercel, deployment `dpl_2a8AjXuqSmwwDavph6qZWWb4xve5`. Flutter and the Node API share one deployment. iPhone Duo is centered, with unfolding topics around it and one primary observation flag each.

19 backend tests and 6 Flutter tests passed; Flutter analysis and TypeScript checking are clean. Flutter 3.47.3 / Dart 3.13.3 / GenUI 0.10.2 / Node 24.18.1 / TypeScript 5.9.3 / Vercel CLI 59.15.1. Release web compilation passed in 68.6 seconds. Production health and explorer GETs returned 200. A hosted hands-on refresh returned 200 in 12,678 ms, with 24 candidates and 21 accepted by `gpt-6-astra`. Chrome verified navigation, inline YouTube playback, in-place refresh, raw counts and preserved playback selection. The final cold-start correction was verified with a hosted world refresh: 200 in 12,776 ms, all 24 feeds, 12 topics and revision 4; the browser cleared Scanning and displayed Scanned just now.

Three credentials were uploaded only to production with explicit authorization and remain server-side. Source and deployment audits found no private key matches. The hosted cache is ephemeral per instance with recorded seed fallback; durable shared state remains outstanding. GitHub is public with ADMIN access; deployment uses the CLI because the empty GitHub repository could not auto-connect. The baseline is committed locally after deployment, without a push.

See [Release v6](RELEASE-V6.md) for reproducible commands, verification details and hosting limits, and [the 60-second script](RECORDING-SCRIPT-60S.md) for recording. All pause/no-deployment statements below describe earlier milestones and are superseded by this section.

## Historical v5 design verification

StellarSlate now renders four editorial neighborhoods, twelve channel thumbnail stacks, recorded relationship links and separate scan-freshness markers. Six Flutter tests pass, including a targeted A2UI group-label update that retains the existing surface. Desktop (1280×720), mobile (390×844), the cluster explanation and thumbnail-to-channel refresh were checked in the browser. Analysis is clean; the final release web build passed in 79.9 seconds. Chrome inline playback was rechecked. The existing in-app YouTube embedding limitation remains; use Chrome for playback. See [STELLARSLATE-V5.md](STELLARSLATE-V5.md). Deployment remains paused.

## Previous v4 verification

Global topic pooling, flags, creator/view ranking and inline channel playback are implemented. All 16 backend tests and 6 Flutter tests pass; analysis is clean. Chrome autoplay and Next were visibly verified. The in-app browser’s nested YouTube frame stayed blank; use Chrome for playback review. See [GALAXY-V4.md](GALAXY-V4.md). Deployment remains paused.

## Historical galaxy v3 verification — September 10, 2026

**Implemented and ready for manual local review at http://127.0.0.1:8792/. Deployment is paused at the user's request.** This section supersedes prior layout, source-access and test-count summaries below. The previous static v2 package has not been republished.

- Flutter 3.47.3 / Dart 3.13.3, GenUI 0.10.2: analysis clean, 5 tests passed, final release web build passed (32.6 seconds). Existing nonfatal Cupertino font warning remains.
- Backend: 13 tests passed on Node 24.18.1. Live YouTube/Astra channel refresh and persisted explorer cache are implemented separately from legacy mission state.
- Long fingers: 7 candidates, 1 accepted by `gpt-6-astra`; thumbnail, source explanation and actual raw views rendered. Two subsequent research branches each returned 8 candidates with none accepted; previous evidence stayed available.
- Five regional Trends feeds refreshed; surrounding topics are a sample, not a world ranking. All 12 channel previews now have at least one linked source image. Six TikTok oEmbed thumbnails are included, with Apple account/playback verified and other five labeled candidates.
- Desktop (1280×720) and narrow (390×844) browser checks passed for galaxy/channel layouts. Original YouTube link opened correctly. Publication age and raw engagement remain separate.
- Actual cache restart comparison passed. Stopping the backend and refreshing produced “Scan unavailable · cache kept” without removing media; server restored on 8792.
- No Vercel deployment, credential upload, commit or push performed. Full details and review steps: [GALAXY-V3.md](GALAXY-V3.md).

---

## Historical v2 explorer verification — 2026-09-10T17:19:32.689874+00:00

**The recorded channel explorer is ready for local exploration and an approved static Vercel preview. No deployment has occurred.** This section supersedes the presentation/layout and test-count entries in the historical setup report below; it does not turn earlier live checks into newly executed checks.

| Check | Current result |
|---|---|
| Flutter analysis | No issues found. Flutter 3.47.3 / Dart 3.13.3; GenUI 0.10.2 retained. |
| Flutter tests | 5 passed: null/zero raw counts, publication versus observation, date-only precision, persistent GenUI surface/action update, narrow-screen rendering/channel chooser. |
| Release web build | Passed with `--release --no-web-resources-cdn --no-pub`; final compile 36.3 seconds. Wasm dry run passed; the existing nonfatal Cupertino font warning remains. |
| Backend tests | 10 passed. Added US/English query and raw statistics checks; invalid-key recovery still excludes quota exhaustion. |
| New live YouTube check | 8 candidates; all 8 returned views, likes, duration and language detail. No persisted mission changed. Existing private primary credential used without displaying it. |
| Astra / backup credential | Earlier successful checks below remain the evidence. Astra and backup were not re-probed in this explorer pass. |
| Computer-use evidence | Six original X posts opened without login. TikTok creator profile/grid readable; search login-gated. No verified Duo TikTok item imported. |
| Browser navigation | Channel chooser exposes 12 channels; selecting Brand banter changes the question and rail. Saved channel and selected channel survive reload. |
| Source provenance | Larger image preview and explanation render; Open original source opens the matching Polymarket X URL in a new tab. Rounded X counts remain labeled, not converted to precise integers. |
| Time/media filters | Moving observed horizon to Sep 9 removes later sources and node covers; restoring latest returns them. X filter leaves one source in the meme channel. |
| Static failure retention | Discover on YouTube against a plain static server displays the local-backend requirement and preserves the recorded channel. Error is dismissible. |
| Responsive layout | Browser inspected at 1280×720 and 390×844. Corrected mobile footer overlap and card overflow. Narrow labels can truncate; full labels remain in the chooser/accessibility text. No actual iPad/Safari or performance benchmark claim. |
| Browser console | Final static preview load produced no warning/error entries. Earlier deliberate missing-API request was separately verified. |
| Deployment package | 43 public files, 42,500,447 bytes. Compiled Flutter assets, dated public evidence metadata, MIT and third-party notices only. Manifest SHA-256 hashes match. |
| Credential exclusion | Privately compared all three populated secrets with all 46 package files; zero matches. No env files, backend source or editorial state in the package. |
| Vercel | Signed-in browser workspace is Dart Technologies (`michow`). Deployment blocked pending explicit approval of destination/public upload. No project created or external payload uploaded. |

Standalone local preview: http://127.0.0.1:8791/ . Its temporary static server is left running. The extra test backend on 8790 was stopped; the pre-existing process on 8787 was preserved. Restart that existing backend when you want it to load the changed YouTube provider. Avoid two backend processes writing the same mission file.

The 12 channel definitions are editorial groupings of the research inventory, not an exhaustive world-media scan or fully verified program. English filtering uses declared audio/research-text language, excluding unknown/non-English values by default; All languages exposes them. NYC is selected context, not geolocation or a claim of local-source coverage. See EXPLORER-V2.md and DEPLOYMENT-PREVIEW.md for boundaries and commands.

---

## Historical setup verification


Verified September 10, 2026. Updated 2026-09-10T15:55:18+00:00.

**Local baseline setup and live API connectivity are verified. The full presentation product remains incomplete.** These results apply to the installed application at `/Users/dartbot/dev/memedia`, including the fixes made during validation. They supersede the earlier permission-blocked report and the disposable GenUI probe.

| Check | Actual result and boundary |
|---|---|
| Destination installation | Passed. Confirmed the destination contained only `.git`, had no commits, and used origin `https://github.com/dart-technologies/memedia.git`. Ran the adjacent `outputs/install-memedia-baseline.py`; it installed 48 baseline files and copied the private environment separately. Existing Git metadata preserved. |
| Private credentials | All three populated keys preserved and compared privately with the source after installation and after switching mode. Destination `backend/.env` is mode 0600 and Git-ignored. No key values or fragments displayed. A scan of 87 publishable source/build files found no matching key values. |
| Backend tests | **9 passed, 0 failed**, including a rerun after the UTF-8 server fix. Provider/configuration/decision/state tests use mocks; live checks are recorded separately below. |
| Flutter dependency resolution | Passed against this application's manifest. GenUI 0.10.2 retained; `url_launcher` reconciled as a direct dependency and unused `cupertino_icons` removed from the seeded lockfile. Nine newer incompatible transitive versions were reported; no broad upgrade performed. |
| Flutter analysis | Passed: **No issues found** after adding braces to the orbit painter's loop. Flutter also added build/web exclusions to `analysis_options.yaml`. |
| Flutter widget test | **1 passed**: custom surface renders, discover action is emitted, and the same `StellarSlate` state instance survives a `/scene` update. |
| Flutter release web build | Passed: `apps/flutter_app/build/web`, compile reported 24.1 seconds. Wasm dry run succeeded; a Wasm release was not built. Nonfatal warning: an expected Cupertino icon font was absent; tested controls rendered correctly. |
| YouTube primary | Passed independently: **8 candidates** returned by the bounded API smoke check. |
| YouTube backup | Passed independently: **8 candidates** returned. Primary smoke check disabled backup recovery so its success was independent. |
| OpenAI Responses API | Passed using **gpt-6-astra**, one valid schema-constrained decision for the synthetic one-item smoke input. Subsequently accepted two live eight-item programming responses from browser actions. No model substitution or fixture fallback. |
| Loopback server | Passed. Release web assets and API served from `http://127.0.0.1:8787`. Local private config now has `DEMO_MODE=live`, primary YouTube slot. Server left running and MeMedia left open in Chrome. |
| Fixture browser flow | Passed: Load fixture → 3 signals/revision 1; Program fixture → revision 2/NOW Launch sample; business toggle → revision 3/NOW Culture sample. Clearly labeled synthetic throughout. |
| Live browser flow | Passed: YouTube discovery → 8 candidates/revision 1; Astra programming → revision 2; business passenger → revision 3. Stable mission and artifact IDs verified from persisted event snapshots. |
| Live editorial outcome | General response: **6 HOLD, 2 KILL**. Business response: **4 HOLD, 4 KILL**. Relevance/clusters/statuses changed, but neither response selected NOW/NEXT. The empty live queue is an actual model outcome, not a completed queued-media demo. |
| Source selection | Passed: selecting a real star showed its title, source, HOLD status and verification-pending label. Open source created a tab at the matching `https://www.youtube.com/watch?v=yr0u__x4FVI`. Playback/content claims were not verified. |
| UTF-8 transport | Fixed and verified. Both A2UI endpoints now declare `text/plain; charset=utf-8`. Browser reload and subsequent updates preserved accented text and emoji; previously they were garbled despite correct stored metadata. |
| HTTP rejection checks | Passed: stale revision 409, invalid JSON 400, unexpected Origin 403, non-JSON content type 415. Full accepted state was unchanged after these checks. |
| Visible network failure | Passed: stopped backend, clicked Program with Astra, observed “Network request failed; last accepted scene retained.” Scene remained at revision 3 with 8 candidates. |
| Restart persistence | Passed: restarted backend, compared `/api/state` with the persisted snapshot, then reloaded Chrome. Same mission, business context, 8 candidates and revision 3 restored; error cleared. |
| Browser layout | Inspected native desktop viewport (1920×873 initially) and Chrome viewport override 1024×768. Controls and source inspection work; settled star labels overlap, especially at landscape size. Temporary override reset. This is viewport coverage, not actual iPad/Safari verification. |
| Git | Still no commits; files are untracked, not staged. No commit, push, release, deployment or visibility change. Private environment, build output and runtime state are ignored. |

## Live run evidence

Mission ID: `7b935770-d392-47c9-82eb-281e65cd96d2`.

| Accepted UTC timestamp | Revision | Observed event |
|---|---|---|
| 2026-09-10T15:50:13.456Z | 1 | YouTube discovery, 8 real metadata candidates |
| 2026-09-10T15:51:19.798Z | 2 | Astra programming for general passenger, 8 validated decisions |
| 2026-09-10T15:51:53.956Z | 3 | Astra programming for business passenger, 8 validated decisions |

Local evidence is retained in ignored `data/mission-live.json` and `data/mission-live.json.jsonl`; fixture evidence is separate. The live log has exactly three accepted events with revisions 1–3, a stable mission ID and the same eight artifact IDs. These records are a baseline event log, not an implemented replay feature. Timestamps above are acceptance times, not latency measurements.

The API checks consumed actual provider quota/billing: two bounded YouTube smoke searches, one synthetic Astra ranking, one browser YouTube discovery and two browser Astra programming requests. No deliberate provider quota/auth failures were induced; those failure paths remain mock-tested. The disconnected browser check did not reach a provider.

## Versions and validation access

| Component | Observed version |
|---|---|
| Flutter | 3.47.3, framework `e8113bf45620cbeb8aff64947ee4c93e16adb4cf` |
| Engine | `06a2e2a110089dff50fe635cffd2a61e1b24fbcd` |
| Dart / DevTools | 3.13.3 / 2.60.0 |
| Node / npm | 24.18.1 / 11.16.0 |
| Chrome | 152.0.7977.83 |
| GenUI / A2UI | 0.10.2 / v0.9; a2ui_core 0.1.1 |

Initial sandboxed validation failed when Flutter tried to update `/Users/dartbot/.dart-tool/dart-flutter-telemetry.log`. The requested escalation was approved; `node scripts/verify.mjs` then completed using the required cache access. Installation, provider networking and loopback binding succeeded in this workspace. The prior report's installation/network permission blockers no longer apply.

## Remaining limits

- Full six-role orchestration, verified source corpus, async Responses tools, WebSocket mid-turn steering, history scrubbing, authentic replay and final cinematic presentation remain unimplemented. Earlier Codex App Server checks do not validate the direct API features.
- Discovery returns unclassified YouTube metadata. Claims, publication authenticity, source authority, factual confidence, durations and measured velocity were not verified by this setup run.
- No live NOW/NEXT items were accepted in this run. The empty-queue prompt still suggests programming even after all items are held/killed; it should explain that outcome in a product iteration.
- Star-label collision handling and HTML entity normalization (a title still displays `&amp;`) need presentation work.
- Actual iPad/Safari, native targets, comprehensive keyboard/touch/reduced-motion behavior and sustained frame timing were not tested. No 60 fps claim.
- Node tests execute TypeScript through native stripping; a dedicated TypeScript compiler check and persistent HTTP integration suite remain backlog items. The HTTP rejection checks above were executed directly during setup.
- The pre-existing ZIP was not regenerated. Use the installed checkout for the validated code; the source delivery folder/archive preceded the lint and UTF-8 corrections.

## Run again

```sh
cd /Users/dartbot/dev/memedia
export PATH="/Users/dartbot/.nvm/versions/node/v24.18.1/bin:/Users/dartbot/dev/flutter/bin:$PATH"
node scripts/verify.mjs
npm run check:env
npm run check:apis
npm start
```

`check:apis` makes real provider requests. The server is already running on port 8787 at handoff; stop that process before launching a second instance. Backend keys are loaded only from the private environment. Original populated keys remain in the source delivery folder; they were never placed in the ZIP or browser assets.
