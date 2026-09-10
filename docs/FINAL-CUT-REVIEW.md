# MeMedia — playback polish and recording dry run

Reviewed September 10, 2026 in Chrome against the release Flutter build. The 60-second director completed uninterrupted and stopped at 01:00 on the showcase. Individual relationship and timeline beats were also inspected using manual seek. No final recording or audio mix was made in this review.

## Delivered behavior

- Headlines wrap fully; StellarSlate and its cluster previews no longer use ellipsis truncation or line limits. Source-authored punctuation remains intact. The horizontal rail still scrolls; a partly offscreen card is not a truncated headline.
- Selecting a thumbnail plays inside that card. The selected card has a mint outline and explicit loading/playing/paused/unavailable status. The separate leading player is removed. Cards keep their ranked order; the rail scrolls only as needed to reveal the selected card.
- Next/Previous and automatic video completion update the active card and URL. Refresh can update playlist metadata without restarting the current video. The embedded player has no enclosing Flutter tap target to swallow controls.
- Cards and constellation nodes use compact observed metrics, such as 1.45K, 308.1K and 8.16M. Details retain exact available integers and their observation timestamp. Unknown values remain unknown; source-rounded values remain rounded.
- Channel/topic navigation updates browser history. Video changes replace the current history entry, avoiding dozens of Back presses after autoplay. Reload restores channel/video identity, not playback position. Copy-link is available in the channel toolbar. Explicit links to a smaller creator reveal All signals; unknown or unrelated video IDs do not become arbitrary embeds.

Try [First looks with Mrwhosetheboss](https://memedia-pi.vercel.app/?channel=hands-on&video=yt-6AkGhTBtR4o), [MKBHD](https://memedia-pi.vercel.app/?channel=hands-on&video=yt-Od6M0AXpcxQ), or [Long fingers with GodDrixx](https://memedia-pi.vercel.app/?channel=visual-memes&video=yt-aoEggczyUZQ).

## Long fingers: there is a video

The original [GodDrixx YouTube short](https://www.youtube.com/watch?v=aoEggczyUZQ), “Apple Duo's Hand Problem 💀,” loaded and played during browser inspection. YouTube showed approximately **4.5K views and 2.95K subscribers**. The retained API observation from 17:58 UTC has **1,448 views**, displayed as **1.45K**; those are different observations, not interchangeable measurements.

Top signals keeps YouTube items with at least 10K views or a creator with at least 100K subscribers. This short falls below both gates. The new explicit deep link switches to All signals and its embed was verified. The normal channel explains when the filtered selection has no playable videos and offers to include smaller creators.

A bounded hosted rescan at 20:27 UTC found one candidate with 14,217 views and 904 likes, but Astra excluded it because its generic Apple meme metadata did not establish a Duo/long-fingers connection. Higher engagement alone should not defeat relevance. This was a bounded search, not proof that no other video exists.

Long fingers is strongest as an **image-led reaction channel**: the [original Polymarket post](https://x.com/Polymarket/status/2097777885893292337), reporting and discussion, with one smaller-creator video. Browser playback and metadata fit do not establish the truth of every claim in a meme.

## Best channel for the recording

Use **First looks**. It has the strongest combination of recognizable creators, observed reach, direct product footage and playable depth. The 20:22 UTC hosted refresh accepted 21 of 24 candidates. Later local warm-up updated its cache successfully.

Open with [Mrwhosetheboss's hands-on short](https://www.youtube.com/watch?v=6AkGhTBtR4o): it shows the device immediately. Its retained observation is 6.64M views / 308.1K likes. Use [MKBHD's impressions](https://www.youtube.com/watch?v=Od6M0AXpcxQ) for long-form follow-up; the rehearsal displayed 8.16M views / 209.9K likes after refresh. These counts are dated observations, not permanent values. The director now selects the short for its 30-second channel cue without changing normal channel ranking.

## Dry-run scorecard

These are editorial judgments from the observed rehearsal, not automated quality metrics.

| Area | Grade | What the dry run showed / next improvement |
|---|---|---|
| Playback and navigation | A− / 9 | In-card playback, compact counts, direct links, Next and Previous work. Platform loading, autoplay policy and third-party controls still affect presentation timing. |
| Celestial visual hierarchy | B+ / 8 | Centered showcase, thumbnail neighborhoods and full labels read well. Small secondary labels need a closer crop for a compressed recording. |
| Pacing and script | B / 7.5 | 132 words fits 60 seconds; automatic close and final hold work. Two ten-second dialogs consume a third of the demo and obscure the media. |
| Source/evidence quality | B / 7.5 | First looks is convincing; metadata review and source review remain distinct. Long fingers has thin video depth, and some retained metrics lag live platform counters. |
| Astra differentiation | C+ / 6.5 | The actual warm-up runs, but a cached channel beat and generic explanation do not visibly prove a distinctive model capability. Async steering remains unimplemented. |
| Final-cut readiness | B+ / 8 | Functional rehearsal passes. Make the presentation changes below before treating this as the strongest final submission. |

## Beat-by-beat recording notes

| Time | Observed result | Final-cut direction |
|---|---|---|
| 0–10s | Centered Duo, surrounding global-feed topics, full wrapped headlines and primary flags. | Hold steady; eliminate the separate “Apple iPhone Duo launch” topic when it duplicates the showcase. Related football topics could also merge into an event cluster. |
| 10–20s | Twelve thumbnail channels in four editorial neighborhoods. | Emphasize Reactions & memes with a subtle local highlight; keep the central moment visible. |
| 20–30s | Relationship explanation opens and subsequent cue dismisses it. Manually sought and inspected as well. | Replace the broad modal with a concise anchored explanation that points at the three connected channels. |
| 30–40s | First looks opens; Mrwhosetheboss plays in the second ranked card, with MKBHD remaining first. | Keep 6–8 seconds of uninterrupted device footage. Avoid mouse hover over the YouTube frame so controls do not dominate. |
| 40–50s | Curation dialog appears; the same video continues underneath. Warm-up reported updated; channel entry correctly reported cached. | Show one actual include/exclude reason, its observation time and compact scan result beside the media. Do not narrate a new completed scan over a cache hit. |
| 50–56s | Timeline cue clears the dialog and restores PUBLISHED / NOW; separately checked by manual seek. | Demonstrate one clearly labeled time change if history is a key claim, or use the time for a direct-link/provenance close-up. Current cue only restores NOW. |
| 56–60s | Director returns to showcase and stops at 01:00 without a cue error. | Hold the ending still for the logo and final line. |

## Priority before the final cut

1. Replace the two broad explanation dialogs with short, anchored callouts. Keep footage and connections visible.
2. Show a concrete Astra decision from the completed warm-up; distinguish metadata fit, review pending and factual verification. Do not imply async steering has been implemented.
3. Deduplicate the showcase from the surrounding global-feed topics; cluster repeated event variants.
4. Use a 16:9 capture and check a short export at its actual delivery resolution. The inspected desktop content area was 1920×817; a dedicated 1920×1080 capture has not been graded here. Keep a closer crop during playback and details.
5. Refresh and inspect the selected clip immediately before recording, keeping scan freshness distinct from each metric's observation time. Record narration separately; the optional harness capture has no microphone/tab audio.

## Verification and release boundaries

Flutter analysis: clean. Eight Flutter tests pass, including compact-count boundaries, URI state, persistent A2UI updates, narrow layout and absence of a tap wrapper around the player. Twenty-one backend/timer tests and TypeScript checking passed in this change cycle. Final release web compilation passed in 38.5 seconds; the existing nonfatal Cupertino font warning remains. Chrome completed the rehearsal with no warnings/errors in the inspected console sample. Separate playback, filtered-video link and route checks were exercised.

The Vercel cache is still ephemeral per instance. Global pulse pools monitored feeds rather than measuring the entire web. Source badges identify origin, not endorsement. Native capture/export and an actual narrated final cut are outside the executed dry run.

### Published release

Production deployment **dpl_4ynV3DTQrwS7WZWC3wgQTr61AGaF** is READY at https://memedia-pi.vercel.app/ (immutable https://memedia-9wx1fm5av-michow.vercel.app/). Production health, explorer, presenter and both new JavaScript assets returned HTTP 200. Chrome verified the direct short link, Next advancing to UrAvgConsumer with the URL changing, and no warnings/errors in the inspected console sample. A production channel refresh displayed Scanned just now. The source/deployment audit checked 164 files against all three private key values and found zero matches, without displaying any credential.

Reproduce with Node 24.18.1, Flutter 3.47.3 / Dart 3.13.3, GenUI 0.10.2 and Vercel CLI 59.15.1:

```sh
npm run typecheck
npm test
cd apps/flutter_app
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn --no-pub
cd ../..
npx vercel@59.15.1 build --prod --standalone --yes
npx vercel@59.15.1 deploy --prebuilt --prod --yes --scope michow
```

This uses the already linked and authorized production project. Git push publishes source; it does not run the Flutter deployment build automatically.
