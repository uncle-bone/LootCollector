# LootCollector v1.0.11 — SmartSync Startup Lag Hotfix

- Defers SmartSync discovery indexing until at least 45 seconds after world entry to avoid competing with initial map and database loading.
- Reduces indexing batches from 30 to 5 records per 100ms update.
- Removes automatic full-database rescans every 10 minutes.
- Pauses indexing immediately when leaving the world and discards only temporary index state, not saved discoveries.
- Preserves v1.0.10 SmartSync protocol, existing addon features, BBLC25C sharing, and SavedVariables.

**Experimental:** BoneProfiler reported an 86.1-second severe FPS episode; the profiler could not attribute CPU time to an addon. This mitigation is not yet proven to resolve the lag. Compare with SmartSync disabled and with LootCollector disabled to isolate the source.

Install all three addon folders into Interface/AddOns. Maintainer: Uncle Bone.
