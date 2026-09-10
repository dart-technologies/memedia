# MeMedia — one-shot prompt review

Reviewed September 10, 2026. Target: [GPT-6 Astra Hackathon NYC](https://cerebralvalley.ai/e/openai-gpt-6-astra-nyc). Repository: [dart-technologies/memedia](https://github.com/dart-technologies/memedia).

## Verdict

The original prompt defines a distinctive demo and a clear visual transformation: new evidence changes editorial weights, restructures constellations, and mutates a passenger's queue. It needs a concrete runtime contract, verifiable data requirements, and a separation between presentation pacing and live computation before a coding agent can execute it reliably.

The revised prompt preserves MeMedia, StellarSlate, Astra2UI, the six editorial roles, all three presenter interactions, and the six ten-second narrative beats. The user subsequently authorized an initial implementation scaffold and supplied three API keys locally. A Flutter/GenUI and Node baseline is now prepared in outputs; the full cinematic product and live API readiness remain incomplete. Nothing has been committed or published.

## P0 — resolve before product coding

| Original ambiguity or conflict | Correction |
|---|---|
| iPad native rendering is specified, but the machine has no full Xcode installation | Use Flutter web in Chrome, with iPad landscape proportions and touch-friendly controls. Defer native macOS/iPad packaging. |
| “Flutter GenUI + A2UI” does not identify the required custom rendering work | Pin GenUI 0.10.2 and A2UI v0.9. Register a custom `StellarSlate` catalog component. Flutter implements drawing, deterministic transitions, hit testing, and layout. |
| “Incremental updates” does not define surface lifecycle | Create the surface once, keep stable component/artifact IDs, and update specific data-model paths. Normal editorial changes must not delete or recreate the surface. |
| Runtime authentication and model capabilities were underspecified | Use the direct Responses API with server-side OPENAI_API_KEY and gpt-6-astra, as the user now requests. Keep YouTube primary and backup credentials server-side. Key presence is confirmed; successful live access and direct API async/steering capabilities remain verification gates. |
| The narrative assumes an exactly timed Samsung response and specific meme | Require source evidence before enabling those beats. Select a different verified aftershock if necessary and change the labels. Omit the specific meme if original-source verification fails. |
| An exact 60-second run competes with unpredictable live retrieval/model latency | Keep a live mode and an explicitly labeled replay of a recorded, verified run. Control presentation pacing independently of computation. Never label prerecorded decisions live. |
| Hundreds of particles and fixed decision counters could imply invented activity | Real stars and counts come from evidence and event logs. Decorative particles do not count as discovered media or expose invented source details. |

## P1 — preserve meaning and judge trust

- **Verification is claim-specific.** Confirming that a meme/post exists does not confirm its allegation. The long-fingers reaction must not become a verified assertion that Apple manipulated an image. A corporate statement is primary evidence of what the company said, not independent proof that every claim is true.
- **Publisher and content type differ.** A news organization can report on a meme; a creator can provide original footage. Keep the original source types and add independent content classification.
- **Authority and confidence differ.** Use separate source authority, factual confidence, and provenance confidence. Leave inapplicable factual confidence and unavailable engagement/velocity measurements null.
- **September 9 history cannot be invented on September 10.** Distinguish recorded-as-observed state from later reconstruction. Preserve published, retrieved, first-observed, and decision times; label projections on the emerging side.
- **A constellation needs a readable key.** Preserve the cosmic metaphor but avoid assigning authority and confidence to the same undifferentiated depth channel. Pair depth with source glyphs and a distinct confidence treatment. Add a compact legend and source preview on selection.
- **A queue is an actual model.** Use stable queue entries with durations, ordering, evidence references, status, and reason codes. Context changes recompute editorial state, not only animation.
- **“Persistent swarm” need not mean six services.** One local Node/TypeScript backend owns the mission and coordinates structured worker jobs. Use verified Responses conversation continuity and an append-only application event log for replay.
- **Fail visibly and recover.** Reject invalid/stale output, retain the last valid state, deduplicate incoming artifacts, and show a small stale/error indicator. Retrieved pages cannot give the model permission to execute code or change the mission.

## Historical subscription-backed probe: a separate runtime

Codex CLI 0.153.4 is installed and logged in through ChatGPT. A headless request explicitly selecting `gpt-6-astra` returned `{"status":"ok"}` under an output schema. A separate App Server probe observed a pending dynamic tool request, accepted `turn/steer` on the same turn, returned the tool result, and received final JSON preserving the mission, seed artifact, new artifact, and changed passenger context.

The account API reported plan type `prolite`; this is recorded as returned, not interpreted as an unlimited entitlement. These runs use the account's Codex allowances. They do not establish direct Responses API credentials, billing, or support for every API feature.

The published App Server interface supports active-turn steering; its dynamic tools are experimental. The installed generated `DynamicToolSpec` has no `async` field. Do not invent one or describe a pending-tool steering test as proof of direct Responses API asynchronous-tool execution. [Codex automation](https://learn.chatgpt.com/docs/non-interactive-mode), [App Server](https://learn.chatgpt.com/docs/app-server), [Responses async tools](https://developers.openai.com/api/docs/guides/async-tool-calling).

The current implementation instead uses provider API keys in a private backend environment. Keep credentials out of browser code, public repositories, recorded fixtures, and CI. The prior subscription-backed probe is historical evidence only; it does not verify the direct API integration.

## Eligibility and source grounding

The event requires work built during the hackathon and a public open-source repository. It does not mandate MIT specifically; MIT is the chosen default for original MeMedia code. Record the build period, dependency licenses, and third-party media attribution separately. [Event rules](https://cerebralvalley.ai/e/openai-gpt-6-astra-nyc).

Apple's official newsroom confirms the September 9 iPhone Duo launch. This setup review found reporting and discussion of the long-fingers reaction, but did not assemble a production evidence corpus or verify the original meme/Samsung posts. Those remain evidence gates in the revised build prompt. [Apple announcement](https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo/).

## Acceptance to carry into the build

1. A new verified signal changes the semantic graph and queue through validated A2UI updates.
2. Passenger context changes within the continuing mission; an active turn can accept steering.
3. Time scrubbing preserves the difference between recorded and reconstructed history.
4. Selecting a real star exposes its source, classification, timestamps, and usable URL.
5. Meme velocity never substitutes for factual confidence; unknown metrics are not invented.
6. Replay is explicitly labeled and derives from a real recorded run.
7. Metrics match the event log, not fixed presentation copy.
8. Flutter analyzes, tests, builds, and renders at desktop and iPad landscape viewports.

## Technical references

- [GenUI 0.10.2](https://pub.dev/packages/genui/versions/0.10.2)
- [A2UI v0.9](https://a2ui.org/specification/v0.9-a2ui/)
- [Flutter web setup](https://docs.flutter.dev/platform-integration/web/setup)
- [Native macOS prerequisites](https://docs.flutter.dev/platform-integration/macos/setup)
- [Astra model guidance](https://developers.openai.com/api/docs/guides/latest-model)

Pair this review with `memedia-one-shot-prompt.md` and `memedia-environment-readiness.md`.

## Current scaffold boundary

Nine backend tests pass with mocked providers. The scaffold supplies a persistent StellarSlate surface, an atomic `/scene` update, fixture discovery/programming, live provider adapters, a passenger toggle, and source links. The six worker roles, fine-grained branch updates, async tools, mid-turn steering, historical scrubbing, verified replay, and the final presentation remain backlog items. New Flutter validation, live provider calls and installation into the intended checkout are blocked by the app execution permissions. See the current environment readiness report; key presence is not demo readiness.
