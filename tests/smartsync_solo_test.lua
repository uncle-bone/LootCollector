-- Lua 5.1 isolated LCS3 solo diagnostic regression.
local module
local sends=0
local now=1000
local persistent={W={{i=123}},V={},R={}}
LootCollector={
  db={profile={sharing={enabled=true,publicChannelEnabled=true,smartSyncV3=true}}},
  NewModule=function() module={};return module end,
  GetModule=function(_,name)
    if name=="Comm" then return {channelId=6} end
    if name=="DBSync" then return {ApplyRecord=function() error("persistent import during solo simulation") end} end
    if name=="RareChest" then return {Upsert=function() error("persistent rare import during solo simulation") end} end
  end,
  GetDiscoveriesDB=function() return persistent.W end,
  GetVendorsDB=function() return persistent.V end
}
GetTime=function() return now end
UnitName=function() return "ActualPlayer" end
SendChatMessage=function() sends=sends+1 end
dofile("LootCollector/Modules/SmartSync.lua")
local oldPeer=module.peer
local oldIndex=module.index
local oldStats=module.stats
local oldQueue=module.outgoing
local oldIncoming=module.incoming
local oldUrgent=module.urgent
local oldPending=module.pending
local oldRecord=persistent.W[1]
local ok,detail=module:SimulateSolo()
assert(ok,tostring(detail))
assert(sends==0,"simulator sent a real packet")
assert(module.peer==oldPeer and module.index==oldIndex and module.stats==oldStats,"live sync state changed")
assert(module.outgoing==oldQueue and module.incoming==oldIncoming and module.urgent==oldUrgent and module.pending==oldPending,"live queues changed")
assert(persistent.W[1]==oldRecord and #persistent.W==1,"persistent data changed")
assert(not module.simulationActive and not module.simulationDB,"simulation state leaked")
-- Failure injection: the same protected scope must restore live state.
local oldAccept=module.Accept
module.Accept=function() error("injected failure") end
local failed=module:SimulateSolo()
module.Accept=oldAccept
assert(not failed,"injected failure unexpectedly passed")
assert(not module.simulationActive and module.peer==oldPeer and module.index==oldIndex,"failed simulation leaked state")
assert(module.outgoing==oldQueue and module.stats==oldStats and sends==0,"failed simulation changed transport state")
print("LootCollector LCS3 solo sandbox, receive, no-send, restore regressions passed.")
