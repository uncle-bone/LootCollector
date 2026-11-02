## 1.0.14 — Stuck outgoing shares hotfix

- Reduced excessive legacy sharing interval; added channel-health and send guards.

## 1.0.13 — CoASync development preview

- CoASync migration, self-echo filtering, channel-visibility safety, SmartSync diagnostics, settings controls.
- Existing data and map marker structures retained; in-game validation required.

## v1.0.12 — Loading progress chat
- Added visible startup stages and completion notices for core, database, shared channel and SmartSync.

# Changelog

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
