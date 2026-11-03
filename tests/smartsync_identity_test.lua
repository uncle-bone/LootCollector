-- Lua 5.1 regressions for collision-safe SmartSync composite identity and long sessions.
local module
local now=100
local sent={}
LootCollector={
  db={profile={sharing={enabled=true,publicChannelEnabled=true,smartSyncV3=true}}},
  NewModule=function() module={};return module end,
  GetModule=function(_,name) if name=="Comm" then return {channelId=6} end end,
}
GetTime=function() return now end
SendChatMessage=function(message,_,_,channel) assert(channel==6);sent[#sent+1]=message end
dofile("LootCollector/Modules/SmartSync.lua")

-- Two records sharing the short ID must both remain addressable by (ID, content FP).
local id,fp1,fp2="deadbeef","11111111","22222222"
module.index={W={[id]={[fp1]={content="record-one"},[fp2]={content="record-two"}}},V={},R={},C={}}
module.peer.Peer={start=now,count=0,last=0,requests=0}
module:Process("Peer","LCS3;REQUEST;W;"..id..";"..fp2)
assert(module.outgoing.last==1,"requested collision variant was not queued")
assert(module.outgoing[1].wire=="LCS3;DATA;W;"..id..";"..fp2..";record-two","request returned the wrong collision variant")

-- There must be no per-session hard stop: a long-running client keeps sending.
module.outgoing={first=1,last=0};module.urgent={first=1,last=0};module.pending={}
module.lastHello=now+100000;module.lastSent=0;module.readyAt=0;module.scanAt=nil;module.scanning=false
for i=1,130 do
  assert(module:Queue({"TEST",i}),"test packet unexpectedly rejected at "..i)
  now=now+5
  module:OnUpdate(0.1)
end
assert(#sent>=130,"SmartSync stopped transmitting during a long session")
assert(module.stats.sent>=130,"sent counter did not advance after 120 messages")
print("LootCollector composite identity and long-session regressions passed.")
