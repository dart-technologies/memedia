# MeMedia recording harness

Open `/recording.html` on the same host as MeMedia: [production presenter](https://memedia-pi.vercel.app/recording.html), or [local presenter](http://127.0.0.1:8792/recording.html) after rebuilding Flutter web.

## Record

1. Use Chrome in landscape. Select **Open demo window**. Keep that clean tab separate from the presenter; its URL ends in `?demo=1`.
2. Select **Warm First looks**. Wait for `hands-on: updated` or `hands-on: cached`. A failure remains labeled `retained`; the harness never invents successful research.
3. For your usual screen recorder, capture the clean demo tab and select **Start rehearsal**. Read the presenter narration or add voiceover afterward.
4. Alternatively, select **Record demo tab**, choose the clean MeMedia tab in Chrome’s sharing picker, and allow the three-second countdown. The script and local capture start together. At 60 seconds capture stops and **Download recording** appears. The optional capture uses WebM with no microphone or tab audio; no media is uploaded. Browser/OS capture permissions remain manual user actions.
5. Pause/resume, jump backward/forward or choose any beat to rehearse. Restart resets to discovery and stops an active recording. The final shot returns to the showcase at 56 seconds.

Controls stay in the presenter tab. Space toggles pause/resume, arrows change beats and R restarts. Pausing the clock also pauses an active MediaRecorder, but ongoing research and embedded playback continue. Keep both tabs open; a disconnected stage pauses the director. Do not close the presenter before downloading the recording.

## Cue sheet

| Time | Automatic app action |
|---|---|
| 0s | Centered Discover galaxy. |
| 10s | Open iPhone Duo showcase. |
| 20s | Show the recorded Reactions & memes relationship explanation. |
| 30s | Close explanation and enter First looks with Mrwhosetheboss’s short playing in its ranked card; normal bounded live refresh/cache behavior runs. |
| 40s | Show curation/freshness explanation while retaining the channel. |
| 50s | Close explanation; restore publication timeline to NOW. |
| 56s | Return to showcase for the closing line. |
| 60s | Stop script and optional capture. |

The spoken copy follows [RECORDING-SCRIPT-60S.md](RECORDING-SCRIPT-60S.md). These are presentation timings, not promises that research completes within a segment. The harness drives live UI over recorded evidence and refreshed metadata; it does not represent a verified historical replay.

## Implementation and checks

`web/recording/timeline.js` uses a monotonic clock with explicit pause/seek state. Delayed callbacks apply the current cue, avoiding accumulated timer drift and bursts of stale actions. The bridge is installed only for `?demo=1`, accepts an allowlist of commands from the same-origin opener and acknowledges commands. It never accepts arbitrary queries or executable source text. Ordinary visitor tabs have no demo receiver.

Flutter applies cue changes through the existing persistent A2UI surface. The harness owns only its explanation routes, dismisses them on cue changes and leaves real cache/error labels intact. No credential configuration changes are required.

Verification: 21 backend/timer tests; eight Flutter tests including cue dialog replacement and persistent surface identity; Flutter analysis and release build; Chrome full 60-second rehearsal, live warm-up, timed explanation/channel transitions and completion. Native capture permission and the final recording download are user-driven and are not claimed as an executed recording in this check.

For deployment, rebuild Flutter then use the existing Vercel prebuilt production workflow in [RELEASE-V6.md](RELEASE-V6.md). Push source commits to `origin/main`; compiled Flutter assets and private environments remain ignored. Git push alone is not configured to build/deploy Flutter on Vercel.

The latest playback and recording assessment is in [FINAL-CUT-REVIEW.md](FINAL-CUT-REVIEW.md). The channel cue selects an opening clip without reordering the rail. URLs preserve channel and playing-video identity; reload restarts that video. Exact available metrics remain in source details.
