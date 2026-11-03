# LootCollector v1.0.21 — SmartSync CoASync receive validation

- Parse WoW 3.3.5a `CHAT_MSG_CHANNEL` arguments correctly, accepting the decorated display name and plain base name only when the local channel number also matches CoASync.
- Add an automated Lua 5.1 regression test confirming valid messages increment received and peer counts, while mismatched channel names or local channel numbers are ignored.
- Preserve the existing SmartSync v3 wire protocol, database sharing, throttling, duplicate protection, and existing data.

Development prerelease. Automated Lua 5.1, TOC-reference, and ZIP-integrity checks run before publication. In-game multi-client verification remains pending.
