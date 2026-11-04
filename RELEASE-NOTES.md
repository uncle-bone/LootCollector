# LootCollector v1.0.28 — SmartSync LCS3 local diagnostic

- Added opt-in `/lcs3solo` isolated protocol simulator that exercises the existing LCS3 receive/validation path with HELLO, SUMMARY, DIFF, DATA import, duplicate rejection, malformed input, and incremental index rebuild.
- Prevented network transmission and persistent record imports during simulation; restored live module state on success and injected failure.
- Added Lua 5.1 regression test and release workflow gate.
- Preserved normal CoASync peer-to-peer sharing, wire formats, rate limits, collision-safe indexes, and SavedVariables schema.
- **In-game verification:** `/lcs3solo` reported PASS; live state reported clean and ready. Live CoASync counters progressed from 7 peers / 46 sent / 241 received / 67 imported to 7 peers / 65 sent / 307 received / 87 imported. Actual two-client record comparison remains unverified.
