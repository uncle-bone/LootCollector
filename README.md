# LootCollector CoA

> **[Download Here!](https://coa-research.unclebone.workers.dev/download/LootCollector)** · [Release notes](https://github.com/uncle-bone/LootCollector/releases/tag/v1.0.28)
> **Current stable release: v1.0.28.**

**Discover, map, track and share Worldforged loot, rare creatures and treasure chests** in Ascension: Conquest of Azeroth / Conquest Reborn (WoW 3.3.5a, Interface 30300).

Maintained by **Uncle Bone** · [GitHub](https://github.com/uncle-bone) · [Report an issue](https://github.com/uncle-bone/LootCollector/issues)

## **Current stable release: v1.0.28.**

**v1.0.28 adds an opt-in, sandboxed SmartSync LCS3 solo diagnostic** (`/lcs3solo`) alongside unchanged real CoASync peer-to-peer sharing. The simulator exercises receive validation, import, duplicate and malformed input rejection, and index reconciliation without transmitting test packets or persisting test records. The Worldforged tooltip cache and rapid-hover protections from earlier releases are retained.

## SmartSync v3 local diagnostic (opt-in)

`/lcs3solo` runs an opt-in **local-only** SmartSync LCS3 receive-path simulation using isolated transient peer, queue, counter, and database state. It exercises HELLO, SUMMARY, DIFF, validated DATA, duplicate and malformed packets, and incremental index rebuild. The simulator blocks CoASync transport and persistent imports and restores live state after success or error. This checks **local protocol logic only**, not real channel delivery or two-client synchronization. Normal peer-to-peer CoASync remains enabled outside simulation.

## Features

- Browse and search collected or community-reported Worldforged items, loot locations, rare sightings, and treasure chests.
- View map and minimap pins, item details, filters, and direction/distance guidance; TomTom integration is optional.
- Save supported sightings and loot observations locally, with duplicate suppression.
- Share compatible discoveries through **CoASync** with other compatible, online clients.
- Optional starter database and custom import addon are included.

Discovery pins are community reports, not guaranteed current spawns. Respawn estimates and observed loot lists are not authoritative.

## Recent changes

### v1.0.28 — SmartSync LCS3 solo diagnostic

- Add `/lcs3solo` to exercise real LCS3 receive, validation, import, duplicate, malformed, and reconciliation logic using isolated test state.
- Block simulated CoASync sends and persistent imports; restore live state after test completion or failure.
- Preserve existing live LCS3 peer-to-peer sharing, throttling, collision protection, and SavedVariables.
- **In-game solo test:** PASS. Live counters advanced from peers=7, sent=46, received=241, imported=67 to peers=7, sent=65, received=307, imported=87. This is evidence of real receive/import progress, not an independent two-client comparison.


### v1.0.26 — Rapid-hover performance hotfix

- Wait 250 ms before starting Worldforged upgrade scans in Discoveries and cancel abandoned scans when moving between rows.
- Reuse completed upgrade cache; retain the existing upgrade tooltip, SmartSync v3 and SavedVariables.
- Live in-game FPS verification pending.


### v1.0.25 — Worldforged tooltip hover performance

- Spread upgrade-tier scanning across frames rather than scanning all tiers synchronously on Discoveries hover.
- Preserve upgrade tooltip details, SmartSync v3, and SavedVariables. Live FPS validation pending.


### v1.0.24 — Discoveries Worldforged upgrade tooltips

- Remove the Discoveries-only suppression that prevented enhanced Worldforged tooltips from displaying upgrades.
- Reuse the working chat/map upgrade display with existing caching; live hover-performance validation pending.
- Preserve discovery records, phase selection, SmartSync v3, and SavedVariables.


### v1.0.23 — SmartSync DATA receive validation

- Preserve both values returned by fingerprint recomputation so valid incoming LCS3 DATA records can pass validation and be applied.
- Keep the wire format and existing rate limits, duplicate protection, and saved data unchanged.
- In-game multi-client verification remains pending.

### v1.0.22 — SmartSync identity and long-session fixes

- Retain all records that share a short identity hash and answer requests by the full identity/fingerprint pair.
- Continue SmartSync traffic past 120 packets in one session while retaining four-second send pacing and queue limits.
- Add Lua 5.1 regressions for collision-variant selection and long-session sending.
- Show v1.0.22 consistently in addon metadata, the in-game About pane, and minimap/vendor build tooltips.

### v1.0.21 — SmartSync CoASync receive validation

- Correctly validate the local CoASync number and plain/decorated channel name in incoming channel messages.
- Add regression coverage for valid peer receipt and rejection of wrong channel names or numbers.
- Preserve SmartSync v3 protocol and existing database-sharing behavior.


### v1.0.16 — About panel metadata

- Show the current version and official maintainer/contact/repository details in the in-game About panel.
- Correct the About panel link to the official `uncle-bone/LootCollector` repository.
- Preserve original author and contributor credits.

### v1.0.15 — CoASync channel handling

- Wait 20 seconds after startup before attempting to join CoASync.
- Hide the channel from chat by default while preserving existing channel memberships.

### v1.0.12 — Loading progress

- Announce saved-discovery initialization, starter database lookup, core startup, channel readiness, SmartSync indexing, and sharing readiness.
- Defer indexing for 45 seconds and process five records per tick; throttle notices.

## Installation

1. Back up `LootCollectorDB_Asc` from SavedVariables before updating.
2. Download the [current stable ZIP](https://coa-research.unclebone.workers.dev/download/LootCollector).
3. Extract these **three sibling folders** into `Interface/AddOns/`: `LootCollector`, `LootCollector_CustomImport`, and `LootCollector_StarterDB`.
4. Restart Conquest Reborn and enable the addons.

Do not nest companion folders inside `LootCollector`. Keep your SavedVariables when replacing addon files.

## Compatibility and support

Built for the older Interface 30300 client, not retail WoW. Map overlays can interact with ElvUI-CoA, DragonUI, Mapster/Magnify, ConquestWorldMapImprovement, and other map modifications; every combination has not been validated. CoASync sharing requires compatible players online.

## Credits and licensing

CoA adaptation maintained by **Uncle Bone**. Original LootCollector by **Skulltrail** and contributors; retain the included license notices and original credits. Community project, not an official Ascension addon.
