# Baseline demo runbook

## Before presenting

1. Follow README build steps and run the verification script: `node scripts/verify.mjs`.
2. Fill the three credential slots locally and run `npm run check:apis`. It checks both YouTube keys independently and Astra using synthetic ranking input; this does not verify a real event corpus.
3. Set `DEMO_MODE=live`, choose the intended YouTube key slot, and restart the backend.
4. Open the local page in Chrome; confirm **LIVE API · BASELINE**, not fixture mode.
5. Click **Discover on YouTube**, inspect a candidate's actual source URL, then **Program with Astra**.
6. Toggle business passenger context. Confirm the queue and revision update while mission identity remains stable.

This proves the iteration baseline's end-to-end flow. It does not complete the final 60-second storyboard, source verification, Samsung injection, timeline scrub, or authentic replay.

## Failure recovery

- Missing key: fill `.env` locally, restart, recheck. Do not expose the file during screen sharing.
- Invalid primary YouTube key: recognized key errors can use the configured backup once. For an explicit operational switch, set `YOUTUBE_KEY_SLOT=backup` and restart.
- Quota exhaustion: stop/reduce requests and review the provider quota. The code does not cycle keys for more quota.
- Model rate limit or timeout: retain the current scene; retry when the provider permits. Do not claim an immediate decision happened.
- Stale revision: reload the page to load the accepted snapshot, then retry the action.
- No network/credentials: deliberately restart in fixture mode and clearly describe it as a synthetic setup demonstration. It is not recorded replay.

## Toward the final presentation

The full narrative remains: world publishing → constellation formation → verified meme moment → verified aftershock → passenger context → autopilot. Implement the evidence and state transitions before rehearsing that narrative. Counts must derive from actual events; reconstructing yesterday's state must be labeled. Record a successful live run before adding REPLAY mode.
