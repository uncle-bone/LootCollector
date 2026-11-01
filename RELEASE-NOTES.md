# LootCollector v1.0.10 — Experimental SmartSync v3

- Adds an opt-out SmartSync v3 incremental reconciliation module on the existing BBLC25C channel, with a dedicated LCS3 message protocol.
- Adds HELLO, SUMMARY, DIFF, REQUEST, DATA, and ACK message handling for Worldforged, vendors, rare creatures, and chests.
- Normalizes records and compares stable content fingerprints without relying on observation timestamps.
- Time-slices local indexing, bounds incoming/outgoing queues, limits per-sender traffic and reply counts, suppresses replayed packets, and limits overall session sends.
- Defers sharing for at least 10 seconds after loading, drops stale transient queues on leaving the world, and pauses outgoing sends in combat.
- Adds clickable SmartSync and chat-progress toggles. Progress messages report local indexing and sync queue completion.
- Preserves the existing discovery and legacy communication modules and saved records.

**Experimental:** This is a conservative incremental sync foundation, not a confirmed production replacement for every legacy sharing mode. Automatic icon-processing progress is not included yet. In-game performance, cross-version interoperability, and full ElvUI map compatibility remain to be tested.

Install all three included folders directly in Interface/AddOns and keep LootCollectorDB_Asc in SavedVariables. Do not delete old discoveries.

Maintainer: Uncle Bone — https://github.com/uncle-bone/LootCollector
