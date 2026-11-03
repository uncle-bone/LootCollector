# CoA-Research v2.0.1 — LootCollector integration audit

**Research tag:** `uncle-bone/CoA-Research@shared-database-v2.0.1`  
**Addon target:** WoW 3.3.5a / Lua 5.1, LootCollector v1.0.20.  
**Import policy:** No source-candidate drops, NPC spawn coordinates, loot pins, or verified-source flags are imported from historical evidence.

## Checked source records and coverage

| Source | Observations | Confidence |
| --- | --- | --- |
| `datasets/shared-reference/v1/items-and-loot.json` | Archive inventory contains 240 item records and **0 live-verified item→loot edges** | Archived source inventory |
| `datasets/shared-reference/v1/quests-and-npcs.json` | Inventory includes 931 quests, 786 NPCs, 135 objects; **no normalized location coordinates** | Archived source inventory |
| `research/loot/vanilla-dungeon-gear-variant-families-2026-10-30.json` | **999** distinct base-ID families, **1,977** distinct nonzero Heroic/Mythic candidate variant IDs, **0** duplicate source IDs | Upstream **pending SQL**, not live |
| `research/shared/dungeon-loot-runtime-validation-rules-2026-10-30.md` | Loader eligibility, map allowlist and source-type restrictions apply; does not verify current Reborn loot | Upstream source analysis |
| `datasets/shared-reference/v1/client-compatibility.json` | WoW 3.3.5a / Lua 5.1 target; live UI/API tests not run | Historical compatibility target |

Source blob for pending variant mapping on the release tag: `d80d99d2baa87fa60983825f59df0df01a5f4f99`.

## Comparison against LootCollector's existing implementation

- Current Worldforged upgrade mapping includes **1,979 base records** and **11,233 numeric upgrade references**, compared statically with the 999 upstream historical candidate families. No exact overlap of candidate Heroic/Mythic IDs with the current Worldforged mapping was detected in this snapshot. These are **different systems**, not equivalent upgrades.
- The existing StarterDB uses a compressed `!LC1!` payload, and its metadata advertises 4,524 discoveries and 16 vendors. Those values do not establish verified item drop rates or NPC spawn ownership.
- Rare/chest tracker stores user-reported free-text `drops` and map coordinates. We have no verified crosswalk from the eight shared reference JSON documents to those local pins.
- The original `LootCollector.Version` and `BuildStamp` were hardcoded to v1.0.6 despite newer TOC releases. Version now derives from the TOC and is reflected in the in-game viewer and sharing metadata.
- CoASync's GUI diagnostics previously displayed only the SmartSync queue. The separate legacy outgoing and rate-limited queues are now displayed too.

## Safe v1.0.20 integration

A new **Audit Saved Loot Against CoA Research** button is available in the existing Sharing settings. Only when clicked, it builds a transient lookup of archived candidate IDs and scans local discovered items and rare/chest records in **75-record frame budgets**. It reports candidate-ID matches and unverified free-text drop notes; it **does not** validate those drops, create pins, replace item names, enable encounter warnings, modify SavedVariables, or broadcast records.

The 999 candidate families are stored in a compact string in `Modules/ResearchAudit.lua`. No lookup table is constructed at login or during ordinary gameplay. The audit frame is reused across runs. The original discovery and sync DB schemas stay unchanged.

A separate **Rebuild CoASync Index** GUI action refreshes the *existing* incremental SmartSync index so new local discoveries can be reconciled without resetting SavedVariables.

## Remaining validation gaps

1. Decode and compare the compressed StarterDB records against a trustworthy current Conquest Reborn item template and spawn crosswalk.
2. Confirm pending variant IDs are actually present in the live client/server and whether the inspected difficulty map allowlist remains deployed.
3. Capture live creature/gameobject loot events before promoting any historically mapped drop to a verified relation.
4. Test map/UI combinations in-game: Blizzard stock map, Mapster-CoA, DragonUI-CoA, ElvUI-CoA and ConquestWorldMapImprovement.
5. Test live CoASync cross-player sharing; no test partner was present in prior diagnostics.

**Never mark an upstream pending-SQL item association as verified merely because a candidate ID appears in the local discovery list.**

## Validation

GitHub Actions runs `luac5.1 -p` on all packaged Lua files, verifies the TOC and ZIP, checks the 999-source family integrity, and runs `lua5.1 tests/research_audit.lua`, which asserts incremental progress, correct candidate matching, absence of SavedVariables mutations and audit-frame reuse. This is static and mocked-runtime validation, not a genuine game-client test.
