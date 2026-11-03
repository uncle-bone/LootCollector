-- Standalone WoW 3.3.5a / Lua 5.1 mock for on-demand CoA-Research audit.
local printCount=0
local oldPrint=print
print=function(...) printCount=printCount+1 end
local created=0
UIParent={}
function CreateFrame()
  created=created+1
  local f={visible=false}
  function f:SetScript(kind,cb) self[kind]=cb end
  function f:Hide() self.visible=false end
  function f:Show() self.visible=true end
  return f
end
LootCollector={}
local items={
  {i=720}, {i=1550720}, {i=1650720}, {i=987654321}, {i=0}, {i=-400001},
}
for i=1,255 do items[#items+1]={i=i+100000000} end
local chestRecords={
  rareA={kind="rare",name="A",drops="uncorroborated loot note"},
  chestB={kind="chest",name="B",drops=""},
}
function LootCollector:NewModule(name)
  local m={}
  self[name]=m
  return m
end
function LootCollector:GetDiscoveriesDB() return items end
function LootCollector:GetModule(name) return self[name] end
LootCollector.RareChest={GetRecords=function() return chestRecords end}
dofile("LootCollector/Modules/ResearchAudit.lua")
local audit=LootCollector.ResearchAudit
assert(audit and audit.referenceVersion=="CoA-Research v2.0.1")
assert(audit.verifiedLootEdges==0 and audit.expectedFamilies==999)
assert(audit:GetStatus():find("audit only",1,true))
audit:RunAudit()
assert(audit.running and created==1)
local cycles=0
while audit.running do
  assert(audit.auditFrame and audit.auditFrame.OnUpdate)
  audit.auditFrame.OnUpdate()
  cycles=cycles+1
  assert(cycles<20,"budgeted OnUpdate audit did not finish")
end
assert(cycles>1,"audit should be incremental")
assert(audit.lastReport:find("3 archived candidate-ID matches",1,true),audit.lastReport)
assert(audit.lastReport:find("base 1, heroic 1, mythic 1",1,true),audit.lastReport)
assert(audit.lastReport:find("1 records contain unverified",1,true),audit.lastReport)
assert(items[1].i==720 and items[2].i==1550720 and items[3].i==1650720)
assert(chestRecords.rareA.drops=="uncorroborated loot note")
assert(audit.auditFrame.OnUpdate==nil and not audit.auditFrame.visible)
audit:RunAudit()
while audit.running do audit.auditFrame.OnUpdate() end
assert(created==1,"repeated audit must reuse frame instead of leaking UI objects")
assert(printCount>=4 and audit.lastReport:find("3 archived candidate-ID matches",1,true))
oldPrint("PASS research audit: 999 families, 3 candidate-ID matches, incrementality, no data mutations, frame reuse")
