# MeMedia — submission writeup and judging scorecard

**Unfolding moments. Connecting reactions.**

[Watch the demo](https://youtu.be/6qgCYbcgvGY) · [Explore the working app](https://memedia-pi.vercel.app/) · [Public MIT-licensed source](https://github.com/dart-technologies/memedia)

## Submission description

A big moment creates a scattered trail of coverage, competitive responses and memes. MeMedia organizes those reactions into connected, media-first channels. Start with a constellation of globally pooled topics, enter the iPhone Duo showcase, then move between first looks, Samsung responses, brand banter and visual memes. Thumbnails reveal the content before you read; selecting a video plays it in place with its source, observed engagement and shareable URL.

GPT-6 Astra supplies semantic curation on the backend. It groups matching trend events across languages and query variants, then screens retrieved YouTube metadata against each channel's editorial question. Each candidate gets an explicit include/exclude reason. Creator reach, views and likes order topical matches using deterministic rules; those observations are not model-invented scores or factual authority.

The frontend combines Flutter with a custom StellarSlate GenUI catalog component and A2UI v0.9. An existing surface receives `/scene` model updates as evidence changes. Flutter controls layout and playback; the model supplies bounded editorial decisions. The result is an explorable media interface with visible curation, rather than a chat transcript. “Astra2UI” is the project's integration label for this combination.

## Form-ready responses

### YouTube description — MeMedia powered by Astra2UI

One moment. A thousand reactions. MeMedia connects coverage, competitive responses and memes in an explorable constellation. GPT-6 Astra curates related topics and media relevance; Flutter with A2UI/GenUI keeps the experience unfolding as evidence updates.

Explore: https://memedia-pi.vercel.app/
Source: https://github.com/dart-technologies/memedia

### Describe your use of OpenAI products to build the submitted project.

We used Codex throughout MeMedia's development: architecture, Flutter and TypeScript implementation, debugging, tests, browser verification and recording preparation. In the application, GPT-6 Astra uses the Responses API to group related topics and screen media relevance, returning structured decisions with explicit reasons. Our backend validates those decisions before updating a persistent A2UI/GenUI surface. This lets fresh evidence change the curated channels while preserving the viewer's selection and playback. The demo shows an actual screening decision alongside the media it helps organize.

### Provide feedback from your experience using OpenAI products.

Codex helped us iterate across application code, APIs and browser behavior through computer use. Astra's structured outputs made editorial decisions easier to validate and explain. Discovery and screening took about 15 seconds in a recorded hosted check, so caching and visible progress were essential to the experience. Smoother local permission handling and clearer examples connecting asynchronous model work to persistent, interactive interfaces would improve the workflow.

The timing above is the team's reported hosted observation, not a latency guarantee or a model-only benchmark. Asking for better asynchronous examples is product feedback; it does not claim that MeMedia implements Astra mid-turn steering.

## How Astra was used during development

Development was an iterative collaboration in Codex: environment and protocol probes, architecture and implementation, API verification, browser inspection, user feedback, tests, deployment and recording. User-directed revisions changed the prototype from abstract particles into thumbnail-led channels, then added explainability, in-card playback, deep links and the timed demonstration. The model-assisted workflow connected implementation to observed failures: cropping, obstructive annotations, playback controls and recording viewport constraints were corrected and checked.

The public evidence is the [commit history](https://github.com/dart-technologies/memedia/commits/main), [readiness record](ENVIRONMENT-READINESS.md), [recording harness](RECORDING-HARNESS.md) and [completed cut review](REVIEW-CUT-01.md). These demonstrate the development process, but do not independently establish the exact model used for every Codex turn. For the **GPT-6 Astra in Development** criterion, attach a sanitized model/session screenshot or export if available. Do not claim development token savings, time savings, exclusive Astra usage, or use of new asynchronous capabilities without supporting evidence.

## How Astra works in the shipped project

The Node/TypeScript backend calls `gpt-6-astra` through the Responses API with strict JSON schemas. Two current paths in [explorer.ts](../backend/src/explorer.ts) matter:

1. **Global event grouping:** fetch 24 monitored country feeds, pool candidates, and ask Astra to group the same events or intents across languages. Validate that every supplied ID appears exactly once. Preserve source observations and use the highest reported search-volume bucket rather than summing overlapping estimates.
2. **Channel curation:** retrieve up to 24 YouTube candidates, enrich creator metadata, and ask Astra to screen topical fit with a reason per candidate. Validate IDs, coverage and output types before accepting the result. Cache accepted evidence and keep the previous valid entry when refresh fails.

The recorded demonstration shows an actual screening result: **21 of 24 retained**, including an exclusion reason for an introduction video that did not meet the hands-on question. That is a recorded cache decision, not proof that a new scan completed during the ten-second beat. The source text is treated as untrusted evidence. Metadata screening does not mean Astra watched or fact-checked a video.

The twelve showcase channels and their relationship links are authored editorial structure. Astra groups global event variants and screens channel candidates; it does not generate every visible relationship. The project uses the general capabilities of Astra through structured responses. Async tools, mid-turn steering, full audiovisual reasoning and six autonomous editorial workers are not implemented.

## Judging scorecard

This is a candid internal assessment against the supplied criteria, **not an official judge result**. Each category has equal 25% weight. Scores describe the current submission evidence, not hypothetical future functionality.

| Criterion | Score / 10 | Weighted / 25 | Evidence and deduction |
|---|---:|---:|---|
| GPT-6 Astra in Development | 7.5 | 18.75 | Iterative code, verification and browser-driven fixes are documented. Exact development-model provenance and efficient use of Astra-specific new capabilities are not independently demonstrated in the public repository. |
| GPT-6 Astra in Project | 7.5 | 18.75 | Live Responses API event grouping and schema-validated curation affect real content selection. Reasons and retained state make the integration inspectable. Usage is bounded metadata reasoning; no distinctive async steering or multimodal capability is demonstrated. |
| Live Demo | 8.5 | 21.25 | Working public Flutter app with constellation navigation, playable media and a concise narrated walkthrough. The connected-channel treatment is distinctive. Small labels, third-party autoplay and a partially prewarmed flow limit how strongly the recording proves live curation. Novelty is an editorial judgment, not a claim of market uniqueness. |
| Technicality | 8.0 | 20.00 | Genuine persistent GenUI/A2UI updates, strict output validation, deduplication, stale-revision handling, retained cache, deep links and server-side credentials. 23 backend/player/timer tests and 8 Flutter tests passed. Hosted cache and scan limits are per-instance; durable shared storage and broader retrieval-quality evaluations remain gaps. |
| **Total** | **7.875** | **78.75 / 100** | **Strong functional demo; model-specific evidence is the largest scoring opportunity.** |

The earlier A− recording assessment grades presentation quality only. It is not interchangeable with this four-part submission score.

## Final polish and publishing decision

Completed in this submission pass: a linked YouTube thumbnail at the top of the README, direct judge entry points, this evidence-based writeup, portable setup instructions, and clear separation of current hosted architecture from legacy local mission endpoints. The video oEmbed title and thumbnail are accessible; the app and health endpoint were checked without consuming a new curation request.

Before submitting the form, the highest-value remaining actions are:

1. **Add development-model evidence.** A sanitized Astra-in-Codex screenshot plus one concrete before/after example strengthens the weakest evidence gap. Include only material the team can verify.
2. **Listen to the uploaded video once.** Confirm the final line's pacing and pronunciation, readable captions, and audible source footage. The linked upload's metadata was checked in this pass; the uploaded video was not independently replayed end-to-end here.
3. **Prepare a live judge path.** Open Chrome, enter First looks, and show a reason plus its scan time. If refresh fails, leave the retained-cache state visible. Do not narrate a cache hit as fresh completed reasoning.

Submit the working scope accurately rather than adding an unverified major feature immediately before the deadline. After submission, prioritize a labeled relevance/grouping evaluation set and durable hosted state. Async steering would materially strengthen the Astra-specific story, but needs implementation and a new verified demonstration before it can be claimed.

This document does not certify event eligibility or newly written authorship for every dependency. Original project code uses [MIT](../LICENSE); third-party media retains its own terms and [attribution](../THIRD_PARTY_NOTICES.md). No submission form was published as part of this documentation pass.
