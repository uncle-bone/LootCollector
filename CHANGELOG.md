## 1.0.21 — SmartSync CoASync receive validation

- Correct `CHAT_MSG_CHANNEL` parsing for WoW 3.3.5a by validating both the local CoASync channel number and the incoming plain or decorated channel name.
- Add an automated Lua 5.1 regression test for valid receipt, peer accounting, and wrong-channel rejection.
- Keep the LCS3 protocol, rate limits, duplicate suppression, and saved discovery data unchanged.
- Requires in-game multi-client confirmation; previous stable version remains available.

## 1.0.19 — Map compatibility

- Dynamic map button placement for Blizzard stock map, Mapster, DragonUI WorldMap and ElvUI, with throttled layout updates.

## 1.0.17 — Mapster and Discoveries performance

- Correct map button anchoring, constrain sync status layout, avoid expensive item-hover scans.

## 1.0.16 — About panel metadata

- Correct in-game version, maintainer, contact, and repository link; preserve upstream credits.

## 1.0.15 — CoASync chat visibility

- Guarded 20-second startup and automatic CoASync chat-tab hiding.

## 1.0.14 — Stuck outgoing shares hotfix

- Reduced excessive legacy sharing interval; added channel-health and send guards.

## 1.0.13 — CoASync development preview

- CoASync migration, self-echo filtering, channel-visibility safety, SmartSync diagnostics, settings controls.
- Existing data and map marker structures retained; in-game validation required.

## v1.0.12 — Loading progress chat
- Added visible startup stages and completion notices for core, database, shared channel and SmartSync.

# Changelog

## 1.0.22 — SmartSync identity and long-session fixes

- Index every record by its short identity and content fingerprint pair so short-hash collisions cannot overwrite another record.
- Resolve DIFF and REQUEST packets against the full pair while preserving the existing LCS3 packet format.
- Remove the hidden per-session send cutoff; retain four-second pacing, queue limits, throttling, duplicate checks, and SavedVariables.
- Add Lua 5.1 regressions for collision-variant selection and more than 120 successful sends.
- Cross-client in-game verification remains pending.

All published versions and downloadable packages are listed under [Releases](https://github.com/uncle-bone/LootCollector/releases).

## v1.0.11 experimental — Startup lag mitigation

- Deferred SmartSync indexing and removed periodic complete rescans after severe startup FPS report.
- Reduced SmartSync index processing batch size. Requires in-game validation.

## v1.0.10 experimental — SmartSync v3

- Added bounded incremental cross-client reconciliation on BBLC25C using LCS3 wire framing.
- Added loading-screen safeguards, replay suppression, per-peer limits, rate-limited FIFO queues and clickable options.
- Kept legacy discovery modules and saved data intact.

## Unreleased

- Repository initialized; awaiting verified current addon source.
