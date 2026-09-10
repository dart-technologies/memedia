# StellarSlate: unfolding moments

September 10, 2026. Local review at http://127.0.0.1:8792/. Deployment remains paused for manual review.

## Copy direction

Working brand line: **Unfolding moments. Connecting reactions.** Discovery heading: **Unfolding moments.**

Alternate lines to consider:

- Unfolding moments. Unfiltered reactions.
- Moments unfold. Memes follow.
- The moment unfolds. The internet reacts.
- Unfolding stories. Unexpected takes.
- Every moment has an aftershock.

“Unfiltered” is only a copy alternative; the application does curate and filter its selection. Navigation now says Discover, Refresh topics, Saved channels and How it’s curated. Celestial styling stays visual rather than requiring people to learn astronomical navigation terms.

## Layout and components

The desktop discovery field keeps iPhone Duo and three channel previews in one neighborhood, separate from the monitored global topic pool. These links indicate channel membership, not a relationship between unrelated global trends.

Opening the showcase reveals all twelve channels in four stable editorial neighborhoods:

| Neighborhood | Channels |
|---|---|
| Product experience | First looks, In your hands, Built to last? |
| Reactions & memes | Samsung responds, Brand banter, Long fingers |
| Everyday use | Launch, Unfold magic, Deep dives |
| Buying decisions | Worth $1,999?, Buy or wait, Market moves |

Desktop uses four nearby groups around the launch anchor; mobile stacks the groups in a scrollable view. Lines inside each group are drawn only when the existing relatedChannelIds declares a relationship in either direction. Neighborhood proximity represents an editorial lens, not numerical similarity, causality, agreement or source authority. Cross-neighborhood links remain accessible through the channel explanation; the overview avoids drawing all possible edges.

The custom StellarSlate catalog root now composes reusable Flutter widgets in lib/stellar_clusters.dart:

- TopicCluster: neighborhood label, rationale and recorded relationship links.
- ChannelPreview: up to three actual ranked media thumbnails, source origin mark, open action and separate Why action.
- FreshnessMarker: scanning progress, a mint dot for a cache check within 15 minutes, an outline for older/unknown checks, amber for retained cache after failure.
- RelationshipLinks: connection paths and restrained decorative glow.

These are compositional widgets within the existing catalog root, not separately registered A2UI catalog entries. The scene supplies clusterGroups, channel membership and rationale. Current group definitions are explicitly authored editorial seed data; this change does not claim Astra inferred them live.

The persistent stellar-slate surface and v0.9 updateDataModel binding remain intact. Flutter owns layout and transitions. Tests verify a targeted /scene/clusterGroups/0/label update without recreating the surface. Stable channel keys preserve preview identity across cache refreshes.

## Signal semantics

Preview order uses the existing Top signals ranking. Source logos identify origin, not factual verification. Publication age, review status and raw views / likes remain on individual media cards. Scan freshness does not imply recent publication or rising engagement.

Orbital graphics no longer carry time-axis labels. Positions group media; the explicit publication/observation slider remains the time control. Unknown counts and timestamps remain unknown. Existing inline playback, provenance links and failure retention remain in place.

## Verification

- Six Flutter tests passed, including mobile channel navigation and incremental A2UI neighborhood updates.
- Final analysis: no issues. Release web build passed in 79.9 seconds.
- Desktop and 390×844 mobile neighborhood layouts were visually checked; explanation dialogs and thumbnail-to-channel refresh worked. No warnings or errors were reported in the in-app browser console during the check.
- Final Chrome preview rendered the existing YouTube player and began playing MKBHD inline. The previously documented in-app browser YouTube limitation remains; use Chrome for playback review.
- The build retains the pre-existing nonfatal Cupertino font warning; visible source marks now use supported Material icons.
- No backend scoring change, new research run, deployment or repository publication is part of this design pass.
