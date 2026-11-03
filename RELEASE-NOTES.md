# LootCollector v1.0.23 — SmartSync DATA receive validation

- Preserve both return values when recomputing incoming record identity and fingerprint, allowing valid LCS3 DATA records to pass validation and be applied.
- Keep the LCS3 wire format, collision-safe indexing, throttling, duplicate protection, and saved discovery data unchanged.
- In-game multi-client verification remains pending.

Stable release. Automated Lua 5.1, TOC-reference, and ZIP-integrity checks run before publication.
