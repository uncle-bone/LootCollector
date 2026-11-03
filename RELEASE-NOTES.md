# LootCollector v1.0.26 — rapid-hover performance hotfix

- Debounce Worldforged upgrade scans by 250 ms in Discoveries.
- Cancel stale scans when the pointer moves to a different row; avoid building backlogs of abandoned tooltip work.
- Reuse cached upgrades without synchronous rescanning in the Viewer.
- Preserve SmartSync v3, phase selection and SavedVariables.

Stable release. Automated Lua 5.1 and ZIP checks run before publication. In-game FPS testing remains pending.
