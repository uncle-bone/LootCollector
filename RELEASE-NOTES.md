# LootCollector v1.0.22 — SmartSync identity and long-session fixes

- Retain all records that share a short identity hash and answer requests by the full identity/fingerprint pair.
- Remove the hidden per-session send cutoff while preserving the four-second send interval, queue bounds, throttling and duplicate protection.
- Add Lua 5.1 regressions for colliding short IDs and more than 120 successful sends.
- Align in-game About and minimap/vendor build labels with v1.0.22.
- Existing saved discovery data and the LCS3 protocol remain intact.

Stable release. Automated Lua 5.1, TOC-reference, and ZIP-integrity checks run before publication. In-game multi-client verification remains pending.

# LootCollector v1.0.21 — SmartSync CoASync receive validation

- Parse WoW 3.3.5a `CHAT_MSG_CHANNEL` arguments correctly, accepting the decorated display name and plain base name only when the local channel number also matches CoASync.
- Add an automated Lua 5.1 regression test confirming valid messages increment received and peer counts, while mismatched channel names or local channel numbers are ignored.
- Preserve the existing SmartSync v3 wire protocol, database sharing, throttling, duplicate protection, and existing data.

Development prerelease. Automated Lua 5.1, TOC-reference, and ZIP-integrity checks run before publication. In-game multi-client verification remains pending.
