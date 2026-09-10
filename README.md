# MeMedia

**Unfolding moments. Connecting reactions.**

[![Watch MeMedia powered by Astra2UI on YouTube](https://i.ytimg.com/vi/6qgCYbcgvGY/hqdefault.jpg)](https://youtu.be/6qgCYbcgvGY)

**[Watch the demo](https://youtu.be/6qgCYbcgvGY) · [Try MeMedia](https://memedia-pi.vercel.app/) · [Submission writeup and judging scorecard](docs/SUBMISSION.md)**

[Open the live demo](https://memedia-pi.vercel.app/) in Chrome. iPhone Duo anchors the centered showcase, surrounded by globally pooled topics with one primary observation flag each. Twelve thumbnail-led channels cluster related perspectives, explain their connections and play YouTube inline.

Flutter web + GenUI/A2UI v0.9 + Node/TypeScript, deployed together on Vercel. Through the Responses API, `gpt-6-astra` groups matching global topics across languages and screens YouTube candidates with explicit inclusion/exclusion reasons. Authored channel neighborhoods make related perspectives easy to explore; fresh evidence updates the persistent GenUI surface while preserving the current selection. Full-frame thumbnails, in-card playback, compact views/likes and shareable channel/video URLs keep media in focus. See [the completed recording review](docs/REVIEW-CUT-01.md), [current verification](docs/ENVIRONMENT-READINESS.md) and [the 60-second transcript](docs/RECORDING-SCRIPT-60S.md).

## Timed demo recording

Use the [recording presenter](https://memedia-pi.vercel.app/recording.html) to drive the six timed walkthrough beats in a separate clean demo tab. Includes an 81-word script, warm-up, pause/resume, manual advance and local WebM capture with tab audio. Compact annotations show a real Astra screening decision and explain the persistent GenUI surface. Optional ElevenLabs synthesis and local MP4 assembly are documented in the harness guide. See [harness instructions](docs/RECORDING-HARNESS.md).

## Start here

Requirements: Flutter 3.47.3 / Dart 3.13.3, Node 24.18.1, Chrome. Put your Flutter SDK's `bin` directory on PATH. No full Xcode installation is needed for this web target.

From the repository root:

```sh
npm install
npm run init:env
npm test
cd apps/flutter_app
flutter pub get
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
cd ../..
npm start
```

Open [MeMedia locally](http://127.0.0.1:8787). The Node server serves the Flutter release build and API from the same origin. Running Flutter's separate development web server without an API proxy is not configured in this baseline.

The galaxy starts with an embedded, dated snapshot, then reads the local cache. Opening a channel or world topic scans YouTube and screens metadata with Astra; accepted results update that channel while navigation stays available. Checks within two minutes reuse the cache. Publication age, cache observation time, and raw views/likes are separate.

Earlier review reports document historical milestones; [review cut 01](docs/REVIEW-CUT-01.md) describes the latest recording and playback behavior.

## Configure the actual API demo

Edit the private `backend/.env` in your local editor:

```dotenv
OPENAI_API_KEY=
OPENAI_MODEL=gpt-6-astra
YOUTUBE_API_KEY_PRIMARY=
YOUTUBE_API_KEY_BACKUP=
YOUTUBE_KEY_SLOT=primary
DEMO_MODE=live
PORT=8787
```

Fill the three blank values with credentials you provisioned. Do not paste them into chat or into Flutter assets. `npm run init:env` creates a private file without overwriting existing values; `.gitignore` excludes it. The deliverable archive contains `.env.example`, never `.env`.

```sh
npm run check:env
npm run check:apis
npm start
```

`check:env` prints presence flags only. `check:apis` makes one bounded YouTube search for each key and one small Astra ranking request, consuming provider quota/billing. It reports sanitized status and counts without credentials. Restart the backend after changing `.env`.

In live mode, opening a channel or topic retrieves up to 24 YouTube candidates and asks `gpt-6-astra` for a structured include/exclude reason for each. Metadata screening does not verify audiovisual content or factual claims. The older mission endpoints remain available but the new galaxy UI uses `/api/explorer` and `/api/explorer/refresh`.

Primary/backup selection is explicit. The provider can retry a credential-specific invalid/expired primary key once using the backup. It does not rotate keys on quota exhaustion, rate limits, or general errors. Keys in the same Google Cloud project share project quotas.

## Baseline contents

| Area | Implementation |
|---|---|
| Flutter | Custom `StellarSlate` GenUI component, channel constellation, timeline, source rail, provenance, saved navigation and action transport |
| A2UI | Persistent surface and root component; atomic updates to the `/scene` branch |
| Backend | Loopback HTTP server, typed domain model, bounded discovery, schema-constrained ranking, fixture provider |
| State | Separate live/fixture snapshots, monotonic revisions, append-only mutation records, stable mission ID |
| Key handling | Server environment only; sanitized errors; no credentials in API responses |
| Tests | Backend provider/configuration/state tests plus Flutter surface/action test source |
| Docs | Architecture, contracts, environment, demo runbook, backlog, product brief, validation status |

The local backend uses Node 24's built-in TypeScript stripping and standard `fetch`. Run `npm install` and `npm run typecheck` for compiler validation. Vercel compiles the same backend into a function; explicit ES-module configuration and rewritten TypeScript import extensions are required.

## Validation and current limits

Current checks: 23 backend/player/timer tests and 8 Flutter tests passed, clean analysis and TypeScript checking, and a successful release web build. Production health, explorer loading, live Astra/YouTube refresh, Chrome navigation and inline playback were verified. See [readiness](docs/ENVIRONMENT-READINESS.md) for current results and historical checks.

Six TikTok preview images are linked using public oEmbed. Apple’s account and Club Duo playback were inspected through the signed-in browser; the other five remain search candidates. No browser session or cookies are used by the backend. Source badges identify platforms, not endorsement or verified factual accuracy.

The surrounding topics pool 24 monitored Google Trends country feeds without country quotas. Ranking uses the highest reported search-volume bucket, not a measured worldwide total or exhaustive crawl. Each flag identifies the primary observation source, not topic nationality. NYC is selected context; the YouTube query uses US/English hints, not precise geolocation. English filtering applies to declared YouTube audio language; other source language uncertainty stays visible in detail.

Autonomous scouting across every platform, full factual verification, six-role scheduling, asynchronous Astra steering and authentic recording replay remain unimplemented. YouTube inline autoplay and Next are implemented; platform restrictions can still require a tap or source opening. Time rings/filtering distinguish publication from observation; they do not reconstruct complete historical editorial lineage. The live Vercel demo uses a temporary per-instance cache, a recorded seed fallback and bounded scan execution. Durable shared editorial storage remains future work.

Repository destination: [dart-technologies/memedia](https://github.com/dart-technologies/memedia). The release baseline and recording harness are published on `main`. See [INIT-BASELINE.md](docs/INIT-BASELINE.md) for safe installation and the initial commit checklist.

## Documentation

- [Submission writeup and judging scorecard](docs/SUBMISSION.md)
- [Completed recording review](docs/REVIEW-CUT-01.md)
- [Current environment and release verification](docs/ENVIRONMENT-READINESS.md)
- [Constellation design](docs/STELLARSLATE-V5.md)
- [Earlier galaxy design and manual review](docs/GALAXY-V3.md)
- [Earlier explorer behavior](docs/EXPLORER-V2.md)
- [Vercel preview handoff](docs/DEPLOYMENT-PREVIEW.md)
- [Environment and keys](docs/ENVIRONMENT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [HTTP and A2UI contracts](docs/CONTRACTS.md)
- [Demo runbook](docs/DEMO-RUNBOOK.md)
- [Iteration backlog](docs/BACKLOG.md)
- [Complete product brief](docs/PRODUCT-BRIEF.md)
- [Third-party attribution](THIRD_PARTY_NOTICES.md)

Original code: MIT, see [LICENSE](LICENSE). Third-party media remains under its own terms.
