# LootCollector CoA

> **[Download](https://github.com/uncle-bone/LootCollector/releases/latest)**

**Discover, map, track and share Worldforged loot, rare creatures and treasure chests** in Ascension: Conquest of Azeroth / Conquest Reborn (WoW 3.3.5a, Interface 30300).

Maintained by **Uncle Bone** · [GitHub](https://github.com/uncle-bone) · [Report an issue](https://github.com/uncle-bone/LootCollector/issues)

## Current stable release: v1.0.19

**LootCollector CoA v1.0.19** brings discovery tracking and shared CoASync data to Conquest Reborn, with improved world-map filter button placement for **Blizzard's default map, Mapster, DragonUI WorldMap, and ElvUI**. The button repositions around map title controls and responds to resized maps, with throttled layout checks to reduce overhead.

The Discoveries browser includes a layout correction for overlapping sync status controls and a performance safeguard to avoid expensive Worldforged upgrade scans when hovering over item rows. CoASync uses a guarded 20-second startup delay and hides its chat channel without leaving or replacing other channels. The in-game About panel displays the installed version, maintainer **Uncle Bone**, and the official GitHub contact.

**Validation:** GitHub Actions passed Lua 5.1 syntax and addon TOC checks. Full in-game compatibility and FPS testing across every UI combination remains pending; this is not a claim that every map modification is conflict-free.

## Features

- Browse and search collected or community-reported Worldforged items, loot locations, rare sightings, and treasure chests.
- View map and minimap pins, item details, filters, and direction/distance guidance; TomTom integration is optional.
- Save supported sightings and loot observations locally, with duplicate suppression.
- Share compatible discoveries through **CoASync** with other compatible, online clients.
- Optional starter database and custom import addon are included.

Discovery pins are community reports, not guaranteed current spawns. Respawn estimates and observed loot lists are not authoritative.

## Recent changes

### v1.0.19 — Stable world-map compatibility update

- Reposition LootCollector's map filter button to stay inside the map and avoid existing title controls on Blizzard stock, Mapster, DragonUI WorldMap and ElvUI.
- Throttle repositioning checks instead of running every frame.

### v1.0.18 — Discoveries UI and hover performance

- Constrain sync status layout to reduce header overlap.
- Avoid expensive Worldforged tooltip augmentation scans for Discoveries browser item hover.

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
2. Download the [current stable ZIP](https://github.com/uncle-bone/LootCollector/releases/latest).
3. Extract these **three sibling folders** into `Interface/AddOns/`: `LootCollector`, `LootCollector_CustomImport`, and `LootCollector_StarterDB`.
4. Restart Conquest Reborn and enable the addons.

Do not nest companion folders inside `LootCollector`. Keep your SavedVariables when replacing addon files.

## Compatibility and support

Built for the older Interface 30300 client, not retail WoW. Map overlays can interact with ElvUI-CoA, DragonUI, Mapster/Magnify, ConquestWorldMapImprovement, and other map modifications; every combination has not been validated. CoASync sharing requires compatible players online.

## Credits and licensing

CoA adaptation maintained by **Uncle Bone**. Original LootCollector by **Skulltrail** and contributors; retain the included license notices and original credits. Community project, not an official Ascension addon.
