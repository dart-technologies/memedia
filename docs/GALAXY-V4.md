# Global pulse, curator ranking and inline playback

Updated September 10, 2026. Local review: http://127.0.0.1:8792/. **Vercel deployment remains paused.**

## Selection changes

The old galaxy reserved slots for five countries. V4 pools all returned trends from 24 country feeds, sorts by the largest reported search-volume bucket, and applies no country quota. Astra groups matching events/query variants and writes concise English labels; all supplied IDs must be accounted for exactly once. Grouped volume uses the maximum bucket, never a sum of overlapping searches. The first eight groups appear on desktop and first five on mobile, with iPhone Duo separately pinned as the showcase.

Flags identify countries where the trend was observed. They do not assign nationality to a topic or creator. This is the highest-volume pool across monitored sources, **not an independently measured worldwide top chart**. Google Trending Now exposes country/region feeds, so coverage and bucket precision constrain the result. Model grouping is editorial interpretation of headlines, not verification of the underlying events.

## Why GodDrixx appeared

V3 asked YouTube for eight relevance-ordered results and screened metadata for a topical match. It had no reach ranking, so a specific long-fingers title could appear despite roughly 1,500 views.

V4 requests up to 24 results ordered by view count, without a US country restriction, and retrieves channel subscriber statistics. Top signals requires YouTube videos to have at least 10,000 views or a channel with at least 100,000 subscribers. The latter is an explicit audience-size heuristic, not an assertion of factual authority or editorial prestige. All signals exposes lower-reach research. English audio filtering remains a separate option.

Within eligible topical candidates, the order is established-creator tier, raw views, then raw likes. Missing statistics remain unknown. Video cards retain their observed counts and timestamps; no composite score or invented velocity is displayed. The seeded inventory also received current channel statistics for 87 channels. Previously recorded niche evidence is retained for inspection.

A live First looks scan returned 24 candidates and accepted 20 metadata matches. Examples at the first check: MKBHD 6,051,320 views; UrAvgConsumer 1,203,585; Brian Tong 1,150,510. The existing Mrwhosetheboss shortlist item had 6,643,502 observed views and leads the combined queue. Counts are dated observations and may change. A narrow meme search did not produce a new suitable high-reach match; unrelated videos were not promoted to fill that gap.

## Inline channel behavior

The active YouTube/TikTok item plays in a single embedded player. Desktop places the player beside the media rail; mobile stacks it above the rail. Selecting a video card changes the player. Why opens evidence details, and Open original remains an optional provenance link. Non-video reporting and X image posts retain source-preview behavior.

Playback starts muted, with Unmute and Previous/Next controls. Supported end events advance the queue. The queue remains stable during background cache refresh; explicit channel, media or filter changes rebuild it. Native provider controls remain available. Browser autoplay rules, disabled embedding, removed videos, and provider login restrictions can prevent playback; the player reports supported errors and retains the media context.

YouTube playback and native Next were verified in Chrome: Mrwhosetheboss played inside MeMedia and advanced to MKBHD without opening another page. The in-app browser left the nested YouTube frame blank during this check, so use Chrome for manual playback verification. This is a known browser-specific limit, not a claimed successful in-app playback test. TikTok also rendered in Chrome and reached the final item’s ended state in the two-item First looks queue. Per-post availability and sound behavior remain subject to TikTok/browser policy; unmuted playback was not verified.

## Validation

- Node 24.18.1: 16 backend tests passed, including no-country-quota ranking, no overlapping volume sums, global view-count search parameters, and rejection of fabricated/omitted topic IDs.
- Flutter 3.47.3 / Dart 3.13.3: analysis clean; 6 tests pass, including the 390×844 channel/player layout and ranking/flag semantics.
- Release Flutter web build passed in 77.3 seconds. Final analysis completed with no issues.
- Live world refresh succeeded across all 24 monitored country feeds; grouped English labels and observed-country flags appeared.
- Chrome visibly rendered and played an embedded YouTube video; Next changed to the next curator. No separate source window was needed.
- TikTok’s official inline player reached the channel end in Chrome.
- No deployment, push or credential upload occurred. Keys remain in the private ignored backend environment.

## Commands and references

```sh
cd /Users/dartbot/dev/memedia
/Users/dartbot/.nvm/versions/node/v24.18.1/bin/node --test backend/test/*.test.ts
# Refresh creator statistics and the dated world snapshot, using private backend keys:
/Users/dartbot/.nvm/versions/node/v24.18.1/bin/node --env-file=backend/.env scripts/refresh-curators.mjs
cd apps/flutter_app
/Users/dartbot/dev/flutter/bin/flutter analyze --no-pub
/Users/dartbot/dev/flutter/bin/flutter test --no-pub
/Users/dartbot/dev/flutter/bin/flutter build web --release --no-web-resources-cdn --no-pub
```

Provider references: [Google Trending Now](https://support.google.com/trends/answer/3076011?hl=en-GB), [YouTube search ordering](https://developers.google.com/youtube/v3/docs/search/list), [YouTube IFrame API](https://developers.google.com/youtube/iframe_api_reference), [TikTok embed player](https://developers.tiktok.com/docs/en/embed-player).
