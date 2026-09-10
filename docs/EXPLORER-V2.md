# MeMedia explorer baseline

The Flutter web client now opens an explicit recorded-research snapshot with 12 curated channel definitions and 141 candidate source records. It renders through the existing GenUI 0.10.2 custom StellarSlate catalog using A2UI v0.9. Channel selection, saving and intent actions update the /scene data model without recreating the surface.

## Explore

Six channels appear in the initial constellation; the channel chooser exposes all twelve. Select a channel to see its editorial question, explanation, suggested source order, actual media thumbnails, publisher identity and provenance links. Source cards distinguish inspected originals, opened source text, metadata candidates and pending review. The source detail includes a larger preview, limitations, publication and observation dates.

The language filter defaults to English declarations. NYC is a user-selected context, not inferred language or evidence of local inventory. Save channel and passenger intent persist in this browser. Saving does not start background discovery. The browser preferences contain navigation choices only; local live editorial state remains on the Node backend.

The event horizon filters sources by either reconstructed publication chronology or recorded observation time. Date-only sources never receive an invented exact publication time. Unknown times remain explicit. Provider counts are hidden before their observation, and no counts are summed or converted into popularity/credibility scores. The graph is a stable thematic map; it is not a numerical embedding, a complete historical reconstruction of editorial cluster membership, or a claim that decorative stars represent retrieved items.

## Live studio

The optional studio calls the local Node server on the same origin for YouTube discovery and Astra programming. Results are shown separately from recorded research. The existing persisted live mission is retained. English/US query context is supplied to YouTube; raw detail metadata is fetched separately. The API can still return other audio languages, which are not proof of English speech. Missing details or upstream failures do not replace the accepted research snapshot.

The static Vercel preview package does not contain the live backend or credentials. It remains useful for channel exploration and source inspection. Live hosted operation additionally needs an approved destination, server-side credentials, access controls and durable mission storage. The current local filesystem store must not be presented as durable Vercel Function storage.

## Boundaries

Suggested source order is an editorial research sequence, not a claim that every video has been fact-checked or that a full continuous eight-minute program has been approved. Source links open provider pages; continuous embedded playback and automatic next-item playback are not implemented. Saved channels do not monitor the web. This baseline does not claim a complete asynchronous Astra steering demo or an API recording replay.

## Reproduce

From /Users/dartbot/dev/memedia:

```sh
node scripts/prepare-explorer.mjs
cd apps/flutter_app
/Users/dartbot/dev/flutter/bin/flutter pub get --offline
/Users/dartbot/dev/flutter/bin/flutter analyze
/Users/dartbot/dev/flutter/bin/flutter test
/Users/dartbot/dev/flutter/bin/flutter build web --release --no-web-resources-cdn
```

From the repository root, `npm start` serves the build with the local backend. A plain static file server can serve apps/flutter_app/build/web for recorded exploration. All public API metadata is dated September 10; refresh or remove the public metadata within the applicable provider retention window. The snapshot is not a permanent unrestricted archive.
