# LootCollector CoA

> **[Download Here!](https://github.com/uncle-bone/LootCollector/releases/download/v1.0.21/LootCollector-v1.0.21.zip)** · [Release notes](https://github.com/uncle-bone/LootCollector/releases/tag/v1.0.21)
> **Current stable release: v1.0.21.**

**Discover, map, track and share Worldforged loot, rare creatures and treasure chests** in Ascension: Conquest of Azeroth / Conquest Reborn (WoW 3.3.5a, Interface 30300).

Maintained by **Uncle Bone** · [GitHub](https://github.com/uncle-bone) · [Report an issue](https://github.com/uncle-bone/LootCollector/issues)

## **Current stable release: v1.0.21.**

This release fixes SmartSync v3 CoASync receive validation for WoW 3.3.5a. Incoming messages are accepted only when the local channel number and plain or decorated channel name both identify CoASync. Automated Lua 5.1 regression, TOC-reference, and ZIP-integrity checks passed. Existing discoveries, map features, protocols, throttling, duplicate protection, and SavedVariables are preserved. In-game multi-client peer verification remains pending.

## Features

- Browse and search collected or community-reported Worldforged items, loot locations, rare sightings, and treasure chests.
- View map and minimap pins, item details, filters, and direction/distance guidance; TomTom integration is optional.
- Save supported sightings and loot observations locally, with duplicate suppression.
- Share compatible discoveries through **CoASync** with other compatible, online clients.
- Optional starter database and custom import addon are included.

Discovery pins are community reports, not guaranteed current spawns. Respawn estimates and observed loot lists are not authoritative.

## Recent changes

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
2. Download the [current stable ZIP](https://github.com/uncle-bone/LootCollector/releases/download/v1.0.21/LootCollector-v1.0.21.zip).
3. Extract these **three sibling folders** into `Interface/AddOns/`: `LootCollector`, `LootCollector_CustomImport`, and `LootCollector_StarterDB`.
4. Restart Conquest Reborn and enable the addons.

Do not nest companion folders inside `LootCollector`. Keep your SavedVariables when replacing addon files.

## Compatibility and support

Built for the older Interface 30300 client, not retail WoW. Map overlays can interact with ElvUI-CoA, DragonUI, Mapster/Magnify, ConquestWorldMapImprovement, and other map modifications; every combination has not been validated. CoASync sharing requires compatible players online.

## Credits and licensing

CoA adaptation maintained by **Uncle Bone**. Original LootCollector by **Skulltrail** and contributors; retain the included license notices and original credits. Community project, not an official Ascension addon.
