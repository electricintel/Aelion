---
name: "Upgrade Aelion Ladder"
description: "Upgrade Aelion through validated incremental rungs with minimal user intervention"
argument-hint: "Target version, upgrade ladder, or 'detect and continue'"
agent: "agent"
---

Upgrade Aelion autonomously through an upward-compatible, validated ladder.

Target or ladder: ${input:target:detect the current state and continue to the next safe rung}

Rules:
- Inspect the current repository state, existing upgrade guides, configuration, build scripts, and recent validation evidence before changing anything.
- Define the smallest safe next rung. Prefer existing project upgrade procedures and incremental version changes over broad rewrites.
- Establish a baseline build or test result when an appropriate command is available.
- Implement one rung at a time. Do not begin a later rung until the current rung has passed its focused validation.
- After each rung, run the narrowest relevant build, test, lint, or smoke check. Diagnose and repair failures within that rung before continuing.
- Preserve user changes and public behavior unless the upgrade explicitly requires a documented change.
- Update versioned configuration, scripts, and documentation only when they are required for the completed rung.
- Work without requesting routine confirmation. Stop and clearly report only when blocked by missing prerequisites, secrets, destructive actions, an ambiguous target, or a decision that changes deployment or compatibility commitments.
- Do not claim a rung is complete without executable validation, unless no applicable validation command exists; state that limitation explicitly.

Finish with a concise rung-by-rung report containing:
1. Starting state and target.
2. Each completed rung and its validation result.
3. Files changed.
4. Remaining blockers, compatibility risks, or recommended next rung.