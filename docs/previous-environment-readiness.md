> Historical setup record. The current baseline uses direct API credentials; README, ENVIRONMENT.md, and VALIDATION.md supersede provider/setup decisions here.

# MeMedia — environment readiness

Verified September 10, 2026, on the presenter's Mac. Product coding has not started.

## Readiness verdict

**Ready for the next Flutter web + local Codex/Astra implementation phase.** GitHub authentication, repository permissions, Flutter web compilation, a custom GenUI/A2UI interaction, and authenticated Astra structured output with active-turn steering passed.

**Not verified/configured:** direct Responses API credentials and async-tool behavior, native macOS/iPad builds, iPad Safari, a production media corpus, production retrieval, replay, or sustained scene performance. Those are not implied by the setup probes.

The existing ChatGPT login was tested successfully for headless Codex. The implementation default chosen for this local demo is Codex App Server, with a direct Responses API adapter reserved for later. This changes the original plan's API-key prerequisite: the local route is verified; the direct API route is not configured. No API key was supplied or used.

## Installed and resolved versions

| Component | Verified value |
|---|---|
| Host | macOS 26.6.2, build 25G83, Apple Silicon |
| Flutter | 3.47.3 stable, framework `e8113bf456` |
| Flutter engine | `06a2e2a110` |
| Dart | 3.13.3 |
| DevTools | 2.60.0 |
| Chrome | 152.0.7977.83 |
| Node | 24.18.1 |
| npm | 11.16.0 |
| Git | 2.54.0, Apple Git-157 |
| GitHub CLI | 2.100.0 |
| Codex CLI | 0.153.4 |
| GenUI | 0.10.2, exact pin |
| A2UI protocol | v0.9 |
| a2ui_core | 0.1.1 |
| genai_primitives | 0.2.4 |
| json_schema_builder | 0.1.7 |
| http (probe) | 1.6.0 |
| CocoaPods | 1.16.2; native platforms deferred |

The complete resolved graph is retained in the probe's `pubspec.lock` and `work/genui-dependencies.txt`. Several newer transitive versions were reported; no broad dependency upgrade was performed.

## GitHub and checkout

- Installed GitHub CLI through Homebrew and completed user-mediated browser authentication.
- Authenticated GitHub account: **chownation**.
- Repository: **dart-technologies/memedia**; GitHub repository ID **1364379147**.
- Visibility: **public**. Authenticated flags: `pull`, `push`, `triage`, `maintain`, and `admin` are all true.
- Clone: `/Users/dartbot/dev/memedia`.
- Origin: `https://github.com/dart-technologies/memedia.git`.
- Default branch: `main`. The repository is empty and has no commits. Git's unborn-branch status can therefore show `origin/main [gone]`; no existing history was deleted.
- No product files, commits, pushes, releases, deployments, or visibility changes were made.

Permissions were verified via authenticated GitHub metadata, not by publishing a test commit. Existing Git author identity was left unchanged.

## Flutter PATH and web checks

Added an idempotent Flutter PATH block to `/Users/dartbot/.zprofile`, preserving existing content. The block adds `/Users/dartbot/dev/flutter/bin` only when missing. A fresh login shell resolves both `flutter` and `dart` there; the inspected PATH contained one SDK entry.

Flutter's final doctor report marks Flutter, Chrome, connected devices, and network resources healthy. It still reports missing/incomplete Android and Xcode toolchains. These do not block the selected web target. The SDK checkout remains clean; normal Flutter diagnostics refreshed ignored cache state.

## GenUI/A2UI probe results

Probe location:
`/Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/work/genui_probe`

This is disposable setup code outside the product checkout. It is deliberately a small diagnostic, not the StellarSlate design or the MeMedia implementation.

| Check | Result and evidence |
|---|---|
| Dependency resolution | Passed with GenUI 0.10.2 and the versions above |
| `flutter analyze --no-pub` | Passed: no issues found |
| Widget compatibility test | Passed: 1 test covering custom catalog render, v0.9 parser, action emission, path update, retained widget state and surface data-model identity |
| `flutter build web --release` | Passed; release build produced; compiler's Wasm dry run also passed |
| Real Chrome render | Passed: custom `StellarSlateProbe` displayed through `Surface` |
| Browser → Node → A2UI | Passed: click sent a v0.9 action; backend returned `/count` update; UI changed 0 → 1 |
| Instance preservation | Browser still showed `Widget instance: 1` and `Surface: setup-probe` after update |

Backend evidence timestamp: **2026-09-10T15:08:33.521Z**. Received action: `increment`, source component `root`, surface `setup-probe`, previous count 0. The action record is retained in `work/genui_probe/action-evidence.jsonl`.

The first widget-test attempt stalled while awaiting stream cancellation in Flutter's fake-async test environment. Teardown was corrected; the rerun passed. Static analysis also caught use of an internal surface accessor; the test now verifies identity using the public surface data-model interface. These were probe corrections, not changes to GenUI.

The diagnostic web server was bound only to `127.0.0.1:8765` and stopped after verification. The release build remains reproducible. This was a Chrome check at the current desktop viewport; it was not an iPad or frame-rate benchmark.

## Authenticated Astra verification

### Headless structured output

`codex login status` reported ChatGPT authentication. A bounded `codex exec` request explicitly selected **gpt-6-astra**, used a read-only sandbox and an output schema, and returned:

```json
{"status":"ok"}
```

Result retained in `work/codex-probe-result.json`. No direct API credential was used.

### Persistent-session and steering probe

Codex App Server's installed schemas were generated into `work/codex-schema` to verify actual parameter names. The probe used an ephemeral thread and one synthetic dynamic tool, with no browsing or product source work.

| UTC time | Observed event |
|---|---|
| 15:10:58.394 | Account read: authentication `chatgpt`; plan type `prolite` |
| 15:10:58.521 | Thread started with `gpt-6-astra` |
| 15:10:58.531 | Turn started |
| 15:11:03.695 | `probe_scout` tool request pending |
| 15:11:03.696 | `turn/steer` accepted with the same active turn ID |
| 15:11:03.696 | Synthetic scout result delivered |
| 15:11:08.067 | Turn completed and assertions passed |

Final schema-constrained output:

```json
{
  "mission_id": "setup-mission",
  "passenger": "business",
  "artifact_ids": ["seed-1", "scout-result"]
}
```

This proves authenticated Astra execution, structured output, a dynamic tool response, accepted context steering, and retention of original/new facts in one active turn. The synthetic artifact IDs are explicitly test data, not media evidence.

It does **not** prove model reasoning continued independently while waiting for the tool. The installed dynamic-tool schema has no `async` field. Direct Responses API async tools and API WebSocket steering remain separate, untested interfaces. Do not claim those probes passed.

The returned account plan identifier `prolite` is reported verbatim without inferring unlimited usage or a particular marketing tier. Local requests consume the signed-in account's Codex allowances. Neither model availability nor remaining allowance is guaranteed for a later session.

## Reproduce the checks

Run in a fresh local terminal. These commands do not push code. Model probes consume Codex usage.

```sh
zsh -lc 'command -v flutter dart; flutter --version; dart --version; flutter doctor -v'
gh auth status
gh api repos/dart-technologies/memedia --jq '{full_name,visibility,permissions,default_branch}'
git -C /Users/dartbot/dev/memedia remote -v
git -C /Users/dartbot/dev/memedia status --short --branch

cd /Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build/work/genui_probe
flutter pub get
flutter analyze --no-pub
flutter test --reporter expanded --timeout 30s
flutter build web --release
node server.ts
```

Open `http://127.0.0.1:8765` in Chrome, enable Flutter accessibility if needed, and press “Send action to backend.” Confirm count increments while the widget instance stays unchanged. Stop the server with Ctrl-C.

To repeat the authenticated model probes:

```sh
cd /Users/dartbot/Documents/Codex/2026-09-10/files-pasted-by-the-user-build
codex login status
codex exec --ignore-user-config --ephemeral --skip-git-repo-check \
  -s read-only -m gpt-6-astra -c 'model_reasoning_effort="low"' \
  --output-schema work/codex-probe-schema.json \
  --output-last-message work/codex-probe-result.json --json \
  'Authentication smoke check only. Do not use tools or inspect files. Return the required status ok JSON.'
node work/codex-appserver-probe.mjs
```

The App Server probe writes a sanitized result to `work/codex-appserver-evidence.json` and terminates its child server. It uses a 90-second timeout and denies extra server-requested operations. The tested run completed in roughly ten seconds; this is not a product latency guarantee.

## Files, credentials, and remaining work

Setup evidence is under this task's `work` directory: `flutter-readiness.log`, `github-readiness.json`, `genui-dependencies.txt`, the GenUI probe and lockfile, generated Codex schemas, and the two model-probe results.

`work/secrets/astra.env` was created as an empty 0600 file in a 0700 directory for the initially planned API flow. It remained empty. `work/.gitignore` excludes that directory. No secret was copied to the repository or outputs. Codex and GitHub manage their own login credentials.

An MIT template for original code is prepared at `work/LICENSE-MIT.txt`; it has not been published or applied to third-party assets. The repository currently has no license because it remains empty.

The remaining product work is intentionally deferred: retrieve/verify the actual source corpus, implement the editor and StellarSlate, record a real replay, validate iPad landscape layouts, measure performance, and prepare submission materials. Native Apple tooling and direct API provisioning are optional future setup paths, not silently satisfied requirements.

References: [GenUI](https://pub.dev/packages/genui/versions/0.10.2), [A2UI v0.9](https://a2ui.org/specification/v0.9-a2ui/), [Codex automation](https://learn.chatgpt.com/docs/non-interactive-mode), [Codex App Server](https://learn.chatgpt.com/docs/app-server).
