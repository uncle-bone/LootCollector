# LootCollector v1.0.14 — Stuck Outgoing Shares Hotfix

- Fix legacy outgoing share queue taking two minutes per record even on an idle channel, or up to an hour under congestion.
- Pace legacy broadcasts at 8–60 seconds, while retaining existing rate-limit and backpressure queues.
- Only drain outgoing discovery records when CoASync is healthy and sharing is not auto-paused.
- Guard raw chat sends against oversized payloads and Lua errors.
- Preserve all existing discoveries, SavedVariables, and map markers.

Development prerelease. Live in-game queue draining still requires verification.
