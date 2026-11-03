# LootCollector v1.0.28 — SmartSync LCS3 local diagnostic

- Added opt-in `/lcs3solo` isolated protocol simulator that exercises the existing LCS3 receive/validation path with HELLO, SUMMARY, DIFF, DATA import, duplicate rejection, malformed input, and incremental index rebuild.
- Prevented network transmission and persistent record imports during simulation; restored live module state on success and injected failure.
- Added Lua 5.1 regression test and release workflow gate.
- Preserved normal CoASync peer-to-peer sharing, wire formats, rate limits, collision-safe indexes, and SavedVariables schema.
- Simulator validates local logic only, not real two-client channel delivery. Live in-game validation remains pending.
