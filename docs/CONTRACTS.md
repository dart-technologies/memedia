# HTTP, domain, and A2UI contracts

Backend base: `http://127.0.0.1:8787`, configurable with `PORT`.

| Method/path | Result |
|---|---|
| `GET /api/explorer` | Current regional world snapshot and cached channel entries; no secrets |
| `POST /api/explorer/refresh` | JSON `{ "key": "visual-memes" }`; allowlisted channel, current topic ID or `world` |
| `GET /api/health` | Mode/model, key presence flags, selected key slot, busy flag, revision; no credentials |
| `GET /api/state` | Current accepted mission snapshot |
| `GET /api/surface` | Text containing fenced v0.9 createSurface, updateComponents, updateDataModel messages |
| `POST /api/action` | Accepts GenUI action JSON; returns a fenced v0.9 `/scene` update |
| `GET /` | Flutter release build from `apps/flutter_app/build/web` |

Example action:

```json
{"version":"v0.9","action":{"surfaceId":"stellar-slate","name":"discover","sourceComponentId":"root","context":{"revision":0,"query":"Apple iPhone Duo"}}}
```

Actions: `discover` (optional query, 2–160 characters); `reprogram`; `passenger` (`general` or `business`). Every mutation requires the current `context.revision`. UI events also include timestamps. POST requests require JSON; browser origins must match the local server. Maximum body size is 16 KiB.

A2UI scene update:

```json
{"version":"v0.9","updateDataModel":{"surfaceId":"stellar-slate","path":"/scene","value":{"missionId":"…","revision":1,"mode":"fixture","passenger":"general","artifacts":[],"lastEvent":"READY","updatedAt":"…"}}}
```

The ellipses above are documentation placeholders, not valid runtime IDs/timestamps. Code emits actual values. A2UI replaces the value at the given path; the update is not a recursive merge.

## Domain

`MissionState` holds mission ID, revision, mode, passenger, artifact collection, last event, and update timestamp. Artifact fields are defined in `backend/src/model.ts` and preserve the product brief's provenance/scoring fields.

`content_kind=UNCLASSIFIED` is the explicit baseline state until verification/classification exists. `confidence`, `authority_score`, `velocity_score`, and `freshness_score` remain null rather than invented. YouTube metadata provenance is independent of confidence in a video's claims. Synthetic artifacts have null URLs, publication dates, and confidence.

`Decision` contains one known artifact ID, relevance in [0,1], a cluster (`launch`, `competition`, `culture`, `business`), NOW/NEXT/HOLD/KILL, and up to five reason codes. Metadata ranking does not update factual confidence.

## Errors

Responses use `{"error":"SANITIZED_CODE","revision":N}` where available. Notable codes: `OPENAI_KEY_MISSING`, `YOUTUBE_KEY_MISSING`, `OPENAI_OUTPUT_INVALID`, `OPENAI_INCOMPLETE`, `YOUTUBE_QUOTA_EXCEEDED`, `BUSY_OR_STALE_REVISION`, `DISCOVER_FIRST`, and provider HTTP status codes. Upstream bodies/URLs/credentials are never exposed.

A missing key is configuration, not an empty corpus. Invalid output is an error, not a synthetic success. The UI retains its accepted scene and shows the error. Reload the local page to resynchronize a stale session; automatic reconnect is a backlog item.

## Galaxy v3 cache

Explorer refresh has a 1 KiB body limit and the same local origin policy. World entries use a ten-minute cache; channels/topics use two minutes. Concurrent requests for a key share one operation. Each accepted entry persists its revision, check time, artifacts and Astra decisions in `data/explorer-cache.json`, separately from legacy mission state. Invalid provider output preserves the last accepted entry. API JSON declares UTF-8.

The Flutter shell maps these entries into its existing GenUI `/scene` data binding. It creates `stellar-slate` once and uses v0.9 `updateDataModel` for subsequent scene revisions. Selection is independent of pending refreshes; the client rejects older cache revisions. `focusedTopic` retains a selected topic even if the next world sample no longer contains it.

Each raw metric retains its source observation time. `newIds` means newly added to this channel cache, not a newly published media artifact. Missing metrics and publication times remain null. The galaxy display is the current snapshot; the historical slider is an evidence filter, not a recorded decision replay.
