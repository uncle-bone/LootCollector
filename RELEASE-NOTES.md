# LootCollector v1.0.20 — CoA-Research v2.0.1 integration (prerelease)

- New **Audit Saved Loot Against CoA Research** button in Sharing settings: compare local discovery item IDs against 999 sourced historical pending-SQL dungeon variant families in bounded 75-record frame batches.
- Reference evidence: 1,977 distinct candidate Heroic/Mythic IDs, no duplicate IDs. The shared items-and-loot export contains **zero verified live loot/drop relationships**; no candidate automatically becomes an item, vendor, boss drop or world-map marker.
- New **Rebuild CoASync Index** GUI action for local discoveries; existing saves and sharing protocol preserved.
- Sync status now distinguishes the SmartSync queue from legacy outgoing shares and rate-limit queue.
- Corrected in-game version, build stamp and peer metadata to follow the installed TOC (previously hardcoded v1.0.6).
- Included reference provenance, comparison limitations, Lua 5.1 mock and static audit tests.

**Not live tested:** in-game tooltip/FPS behavior, multi-user sync, stock/Mapster/DragonUI/ElvUI/CWMI world-map combinations. No claim that pending SQL is deployed on current Conquest Reborn.

Preview build for integration testing; previous stable v1.0.19 remains available.
