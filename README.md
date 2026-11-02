# LootCollector CoA

> **[⬇ Download v1.0.12 — Current stable release](https://github.com/uncle-bone/LootCollector/releases/download/v1.0.12/LootCollector-v1.0.12.zip)**

**Discover, map, track and share Worldforged loot, rare creatures and treasure chests in Ascension: Conquest of Azeroth / Conquest Reborn (WoW 3.3.5a).**

**Current stable release: v1.0.12 — loading progress and SmartSync readiness messages.** [Download the current ZIP](https://github.com/uncle-bone/LootCollector/releases/download/v1.0.12/LootCollector-v1.0.12.zip) · [Report issues](https://github.com/uncle-bone/LootCollector/issues)

## What it does

- **Worldforged discoveries:** View and search collected or community-reported items, loot locations, map and minimap pins, item details and filters.
- **Rare creatures and treasure:** Track supported rare sightings, chest discoveries, known locations and observed drops; browse the Chests/Rares viewer.
- **Guidance:** Choose reported destinations with direction/distance guidance and optional TomTom integration where supported.
- **Learning:** Persist supported sightings and loot observations, suppress duplicates and improve local records as data is collected.
- **Community sharing:** Exchange compatible discoveries over **BBLC25C**. Questie-X and DBM-CoA may use the same channel with their own message formats.
- **Companion datasets:** Optional starter database and custom import module included with the package.

**Important:** Discovery pins represent reported locations, not guaranteed current spawns. Respawn estimates and observed loot lists are not authoritative. Some custom entities may not be detected automatically.

## v1.0.12 — Loading progress

The release announces saved-discovery initialization, starter database lookup, core startup, shared-channel readiness, SmartSync indexing and sharing readiness. Indexing stays deferred for 45 seconds and processes five records per tick. Notices are throttled. In-game verification is still needed.

## v1.0.9 — What changed

This release restores the earlier map implementation following marker regressions in v1.0.7–v1.0.8. It preserves the existing viewer, rare/chest tracking, Worldforged records, BBLC25C integration, and companion datasets. **The rollback is not a verified fix for every ElvUI or map-stack issue**; test map icons with your enabled UI addons. The release does **not** introduce a newly verified database of all rare spawns or complete loot tables.

## Installation

1. Back up `LootCollectorDB_Asc` from SavedVariables before updating.
2. Download the appropriate [release ZIP](https://github.com/uncle-bone/LootCollector/releases).
3. Extract **three sibling addon folders** to `Interface/AddOns/`: `LootCollector`, `LootCollector_CustomImport` and `LootCollector_StarterDB`.
4. Restart Conquest Reborn, enable the addons and open the LootCollector viewer.

Do not nest companion folders inside `LootCollector`. Preserve saved discoveries when replacing addon files.

## Compatibility / known limitations

Built for the older **Interface 30300** client, not retail WoW. Map overlays may interact with ElvUI-CoA, DragonUI, Mapster/Magnify, ConquestWorldMapImprovement, and other world-map modifications. The v1.0.9 rollback prioritizes restored marker visibility; compatibility across every combination remains unverified. BBLC25C sharing requires other compatible, online players. Treat learned data as community observations subject to mistakes.

## Maintenance and credits

CoA adaptation maintained by **Uncle Bone** ([GitHub](https://github.com/uncle-bone)). Original LootCollector by **Skulltrail** and contributors; retain their original notices and licensing. Community project, not an official Ascension addon.

**Feedback:** [Open an issue](https://github.com/uncle-bone/LootCollector/issues) with your installed version, UI/map addons and reproduction steps.


### CoASync development preview (v1.0.13)
Sharing now uses the shared CoASync channel, with a compact SmartSync status panel in settings. Local discoveries remain available when sharing is disabled. This is a prerelease requiring in-game compatibility testing.


### v1.0.14 sharing queue hotfix
Legacy outgoing shares now drain at bounded intervals when CoASync is healthy. The separate SmartSync v3 queue remains unchanged.
