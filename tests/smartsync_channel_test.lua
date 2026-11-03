-- WoW 3.3.5a / Lua 5.1 regression test for SmartSync CHAT_MSG_CHANNEL receipt.
-- Run from the repository root with: lua5.1 tests/smartsync_channel_test.lua
local module
LootCollector = {
  db = { profile = { sharing = { enabled = true, publicChannelEnabled = true, smartSyncV3 = true } } },
  NewModule = function(self)
    module = {}
    return module
  end,
  GetModule = function(self, name)
    if name == "Comm" then return { channelId = 6 } end
  end,
}
GetTime = function() return 100 end
dofile("LootCollector/Modules/SmartSync.lua")

local function event(message, sender, display, index, base)
  module:OnChannel("CHAT_MSG_CHANNEL", message, sender, "COMMON", display, nil, nil, nil, index, base)
end

event("LCS3;HELLO;3", "PeerOne-Realm", "6. CoASync", 6, "CoASync")
assert(module.stats.received == 1, "valid decorated CoASync message was not counted")
assert(module.peer["PeerOne-Realm"] ~= nil, "valid sender was not recorded as a peer")

event("LCS3;HELLO;3", "PeerTwo-Realm", "CoASync", 6, "CoASync")
assert(module.stats.received == 2, "valid plain CoASync message was not counted")
assert(module.peer["PeerTwo-Realm"] ~= nil, "plain-name sender was not recorded as a peer")

event("LCS3;HELLO;3", "WrongName-Realm", "6. General", 6, "General")
event("LCS3;HELLO;3", "WrongIndex-Realm", "7. CoASync", 7, "CoASync")
event("LCS3;HELLO;3", "MissingIndex-Realm", "6. CoASync", nil, "CoASync")
assert(module.stats.received == 2, "invalid channel identity was accepted")
assert(module.peer["WrongName-Realm"] == nil, "wrong channel created a peer")
assert(module.peer["WrongIndex-Realm"] == nil, "wrong local channel number created a peer")
assert(module.peer["MissingIndex-Realm"] == nil, "message without local channel number created a peer")
print("SmartSync channel receive regression passed: valid messages counted; invalid channel identities ignored.")
