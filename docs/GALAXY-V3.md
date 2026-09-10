# Galaxy v3 — manual review

Implemented September 10, 2026 in `/Users/dartbot/dev/memedia`. **Local review only; stop before Vercel deployment.**

Open http://127.0.0.1:8792/ . This is the new full-stack local preview. The older 8791 static page is v2.

## What changed

- A dark celestial galaxy with quiet orbital motion, image-first channel nodes, a pinned iPhone Duo showcase, and surrounding live regional trending topics. Desktop exposes eight world topics; mobile shows five regional leaders. The full regional snapshot remains in the API/cache.
- Twelve iPhone perspectives with thumbnail previews, a horizontal media rail, source platform marks, compact titles, and explanations in source/channel detail. Apple and 9to5Google publisher images fill the two text-led research channels; they do not imply completed teardown or accessibility testing.
- Selecting a channel or world topic starts a bounded YouTube search plus `gpt-6-astra` metadata screen. Last accepted content remains visible while scanning. The cache updates without rebuilding the GenUI surface or changing the selected channel.
- Publication age on each thumbnail, check age in the status line, raw views/likes on media nodes/cards, and observation timestamps in detail. Unknown values show an em dash. Rounded X/TikTok values remain source-rounded; no synthetic engagement or velocity score is shown.
- Time rings mark 12/24/36/48 hours from September 9 UTC for channel evidence. Small plotted points carry actual timestamps; thumbnail callouts stay in readable positions. Toggle Published/Observed and move the slider to filter evidence. Unknown/date-only publication times are not invented. Historical cuts hide later-observed engagement counts.
- Six TikTok thumbnail links use public oEmbed. Apple's Club Duo account and playback were inspected; five other TikTok entries remain search candidates. No cookies or signed-in browser session are exported.

## Manual walkthrough

1. Open Galaxy, select the central **iPhone Duo** beacon, and inspect the surrounding perspective thumbnails. Open **All 12 channels** to see the remaining branches.
2. Open **Long fingers**. Look for its original image and the newly screened YouTube meme. Compare the thumbnail's publication-age badge with the separate views/likes row and scan time.
3. While a scan runs, navigate to another channel. Return to the first channel to inspect the accepted cache. A check within two minutes reuses the cache instead of repeating provider work.
4. Select a media card. Check **Why it surfaces**, the content-review limitation, publication/observation times and **Open original**.
5. Toggle **Published / Observed** and move the time slider. This filters actual evidence; it is not a historical replay of editorial decisions.
6. Return to Galaxy and open a different regional topic. Inspect the news previews and the bounded YouTube scan. Try the layout at desktop and narrow widths.

## Verified in this pass

- Flutter 3.47.3 / Dart 3.13.3; GenUI 0.10.2; Node 24.18.1.
- Clean Flutter analysis; 5 widget/unit tests passed; release web build passed. The existing nonfatal Cupertino font warning remains; Material icons render in the inspected browser.
- All 13 backend tests passed on Node 24.18.1. Coverage includes request coalescing, TTL reuse, persistence, deduplication, invalid Astra IDs/output, failure retention and raw metadata semantics.
- Live Long fingers scan: 7 unique YouTube candidates, 1 accepted by `gpt-6-astra`; actual thumbnail and raw view count appeared. A later scan updated views from 1,448 to 1,465. Likes were unavailable and remained null. These are observations, not a promised count.
- Live durability/accessibility searches: 8 candidates each, no candidates accepted. Existing sources were retained; no fabricated results filled the gaps.
- A MobLand world-topic drill-in displayed linked news previews and completed a live scan (8 candidates, 3 accepted); returning to Galaxy and iPhone Duo remained responsive.
- Regional Google Trends feeds refreshed successfully across US, GB, IN, JP and BR. They form a sample, not a global popularity ranking. A topic's trend-start time is not an article publication time.
- Publisher thumbnails render through Flutter’s HTML-image fallback when canvas fetch is blocked; the complete 12-channel grid was visually checked.
- Browser inspected at 1280×720 and 390×844; mobile text overflow fixes validated. Source-detail link opened the matching YouTube URL in a new tab.
- Final browser console check returned no warning/error entries.
- Actual explorer-cache restart restoration passed. With the backend stopped, Refresh showed “Scan unavailable · cache kept” and preserved the media rail. Server restored afterward.

## Reproduce

Use the repository's pinned Node runtime (`.nvmrc` if available, or the full path below on this Mac). Keep credentials in the ignored private `backend/.env`.

```sh
cd /Users/dartbot/dev/memedia
/Users/dartbot/.nvm/versions/node/v24.18.1/bin/node --test backend/test/*.test.ts
cd apps/flutter_app
/Users/dartbot/dev/flutter/bin/flutter analyze --no-pub
/Users/dartbot/dev/flutter/bin/flutter test --no-pub
/Users/dartbot/dev/flutter/bin/flutter build web --release --no-web-resources-cdn --no-pub
cd ../../backend
PORT=8792 /Users/dartbot/.nvm/versions/node/v24.18.1/bin/node --env-file=.env src/server.ts
```

A review server is already running on 8792; do not start a duplicate on that port. To regenerate dated public evidence, run `npm run prepare:explorer` followed by `npm run prepare:galaxy`, then rebuild Flutter. These commands perform new retrieval and change the snapshot. TikTok image URLs may expire; regenerate their public oEmbed metadata when needed.

## Boundaries before hosting

The current Node service uses local disk and loopback HTTP. The new live cache is separate from the older mission state. A single Vercel project can serve the Flutter static build and API routes, but hosting the live experience still requires an appropriate function entry point, durable shared storage, request limits and any long-running-work adaptation. Do not simply deploy the local writable-file server.

No Vercel project, deployment, environment upload, commit or push was made in this pass. The older v2 static package was not republished or silently updated.

Astra screens supplied metadata; it does not prove a video was watched or a claim verified. NYC is a selected context with US/English YouTube hints, not precise geolocation. There is no exhaustive whole-web crawl, normalized worldwide ranking, autonomous TikTok scan, or complete recorded editorial replay. Decorative stars and angular layout are visual design; they do not imply measured relevance or artifact counts.
