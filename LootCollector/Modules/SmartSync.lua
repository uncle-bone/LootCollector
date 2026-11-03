-- LootCollector SmartSync v3: bounded, incremental discovery reconciliation.
-- WoW 3.3.5a / Lua 5.1. Protocol intentionally distinct from LCDB1, LCR1 and Questie.
local L = LootCollector
local S = L:NewModule("SmartSync", "AceEvent-3.0")
local PREFIX, CHANNEL = "LCS3", "CoASync"
local SECTIONS = {"W", "V", "R", "C"}
local MAX_WIRE, MAX_QUEUE, MAX_IN = 225, 96, 96
local SEND_INTERVAL, START_DELAY, HELLO_INTERVAL = 4, 10, 300
local RECORDS_PER_TICK = 5
-- Four-second pacing is the rolling send budget; no lifetime packet cutoff.
local ADVERTISE_COOLDOWN, REQUEST_COOLDOWN = 120, 120
local function clock() return GetTime and GetTime() or 0 end
local function enabled()
  local p = L.db and L.db.profile
  return p and p.sharing and p.sharing.enabled ~= false and p.sharing.publicChannelEnabled ~= false and p.sharing.smartSyncV3 ~= false
end
local function tidy(v, limit)
  return tostring(v or ""):gsub("[%c;~|]", " "):sub(1, limit or 50)
end
local function num(v) return tonumber(v) or 0 end
local function int(v) return math.floor(num(v) + 0.5) end
local function coord(v) return int(num(v) * 10000) end
local function hash(s)
  local h = 5381
  for i=1,#s do h = (h * 33 + s:byte(i)) % 2147483647 end
  return string.format("%08x", h)
end
local function channelID()
  local C = L:GetModule("Comm", true)
  local n = C and tonumber(C.channelId) or 0
  if n > 0 then return n end
  if GetChannelName then
    local id = GetChannelName(CHANNEL)
    return tonumber(id) or 0
  end
  return 0
end
local function rawData()
  local rc = L:GetModule("RareChest", true)
  return {
    W = L.GetDiscoveriesDB and L:GetDiscoveriesDB() or {},
    V = L.GetVendorsDB and L:GetVendorsDB() or {},
    R = rc and rc.GetRecords and rc:GetRecords() or {}
  }
end
local function encode(section, d)
  if type(d) ~= "table" then return nil end
  if section == "R" or section == "C" then
    if not d.name or not d.kind or num(d.map) <= 0 or num(d.x) < 0 or num(d.x) > 1 or num(d.y) < 0 or num(d.y) > 1 then return nil end
    local isRare = d.kind == "rare"
    if (section == "R") ~= isRare then return nil end
    local identity = table.concat({tidy(d.kind,12),int(d.map),isRare and tidy(d.name,50):lower() or coord(d.x),isRare and "" or coord(d.y),isRare and "" or tidy(d.name,40):lower()},":")
    local content = table.concat({tidy(d.kind,12),int(d.map),coord(d.x),coord(d.y),int(d.level),int(d.respawn),tidy(d.name,50),tidy(d.drops,45),tidy(d.notes,35)},"~")
    return hash(identity), hash(content), content
  end
  local xy = d.xy
  if not xy or not d.i or num(d.z) <= 0 then return nil end
  local c,z,i,x,y,iz = int(d.c),int(d.z),int(d.i),coord(xy.x),coord(xy.y),int(d.iz)
  if x < 0 or x > 10000 or y < 0 or y > 10000 then return nil end
  local identity = table.concat({section,c,z,i,x,y,iz},":")
  local content = table.concat({c,z,i,x,y,iz,int(d.dt),int(d.q),int(d.it),int(d.ist),tidy(d.itemName or d.vendorName,40)},"~")
  return hash(identity), hash(content), content
end
local function queueLength(q) return q.last - q.first + 1 end
local function push(q, value, maxCount)
  if queueLength(q) >= maxCount then return false end
  q.last = q.last + 1
  q[q.last] = value
  return true
end
local function pop(q)
  if q.first > q.last then return nil end
  local v=q[q.first];q[q.first]=nil;q.first=q.first+1
  if q.first > q.last then q.first=1;q.last=0 end
  return v
end
S.outgoing={first=1,last=0}; S.urgent={first=1,last=0}; S.incoming={first=1,last=0}
S.pending={}; S.peer={}; S.index={}; S.order={}; S.sum={}
S.advertised={}; S.requested={}
S.stats={updated=0,sent=0,received=0,dropped=0,invalid=0,duplicates=0,throttled=0,ack=0}
S.readyAt=math.huge;S.lastSent=0;S.sentSession=0;S.lastHello=0
local function say(msg)
  if L.db and L.db.profile and L.db.profile.sharing and L.db.profile.sharing.syncNotifications == false then return end
  print("|cff66ccffLootCollector:|r " .. msg)
end
function S:Queue(parts, target)
  if not enabled() then return false end
  local wire = PREFIX..";"..table.concat(parts,";")
  if #wire > MAX_WIRE or wire:find("[%c]") then return false end
  local key = (target or "*")..":"..wire
  if self.pending[key] then return false end
  local urgent=parts[1]=="REQUEST" or parts[1]=="DATA" or parts[1]=="ACK"
  local q=urgent and self.urgent or self.outgoing
  if queueLength(self.outgoing)+queueLength(self.urgent)>=MAX_QUEUE or not push(q,{wire=wire,target=target,key=key,due=clock()+math.random(1,4)},MAX_QUEUE) then self.stats.dropped=self.stats.dropped+1; return false end
  self.pending[key]=true
  return true
end
function S:Rebuild()
  self.index={W={},V={},R={},C={}}
  self.order={W={},V={},R={},C={}}
  self.sum={}
  self.scanData=rawData()
  self.scanSection=1
  self.scanKey=nil
  self.scanning=true
  self.scanCount=0
  say("SmartSync indexing started (small batches).")
end
function S:ScanStep()
  if not self.scanning then return end
  local budget=RECORDS_PER_TICK
  while budget > 0 and self.scanSection <= #SECTIONS do
    local section=SECTIONS[self.scanSection]
    local db=section=="W" and self.scanData.W or section=="V" and self.scanData.V or self.scanData.R
    local valid,key,d=pcall(next,db,self.scanKey)
    if not valid then self.scanKey=nil;key,d=next(db,nil) end
    if key == nil then
      self.scanSection=self.scanSection+1;self.scanKey=nil
    else
      self.scanKey=key;budget=budget-1
      local id,fp,content=encode(section,d)
      if id then
        local old=self.index[section][id]
        if not old then
          self.order[section][#self.order[section]+1]=id
          self.index[section][id]={fp=fp,content=content}
          self.scanCount=self.scanCount+1
        elseif fp < old.fp then
          self.index[section][id]={fp=fp,content=content}
        end
      end
    end
  end
  if self.scanSection > #SECTIONS then
    for _,section in ipairs(SECTIONS) do
      local ids=self.order[section]
      local h=0
      for _,id in ipairs(ids) do
        h=(h+tonumber(hash(id..self.index[section][id].fp),16))%2147483647
      end
      self.sum[section]={count=#ids,fp=string.format("%08x",h)}
    end
    self.scanData=nil;self.scanning=false
    self.nextRebuild=nil -- never rescan the entire database on a periodic timer
    say("SmartSync indexing complete ("..self.scanCount.." records).")
  end
end
function S:Summaries()
  if self.scanning then return end
  for _,sec in ipairs(SECTIONS) do
    local a=self.sum[sec]
    self:Queue({"SUMMARY",sec,a.count,a.fp})
  end
end
function S:SendDiff(sec)
  if self.scanning or not self.order[sec] then return end
  local ids=self.order[sec]
  local limit=#ids
  if limit == 0 then return end
  local start=self.diffCursor and self.diffCursor[sec] or 1
  self.diffCursor=self.diffCursor or {}
  local now=clock()
  for i=start,math.min(start+7,limit) do
    local id=ids[i]
    local r=self.index[sec][id]
    local key=sec..":"..id..":"..(r and r.fp or "")
    if r and (not self.advertised[key] or now-self.advertised[key]>=ADVERTISE_COOLDOWN) then
      if self:Queue({"DIFF",sec,id,r.fp}) then self.advertised[key]=now end
    end
  end
  self.diffCursor[sec] = start+8 > limit and 1 or start+8
end
local function isSelfSender(sender)
  if type(sender) ~= "string" then return false end
  local player = UnitName and UnitName("player")
  if type(player) ~= "string" or player == "" then return false end
  local short = sender:match("^([^%-]+)")
  if not short or short:lower() ~= player:lower() then return false end
  local realm = sender:match("%-(.+)$")
  if not realm then return true end
  local own = GetRealmName and GetRealmName()
  if type(own) ~= "string" or own == "" then return false end
  local function norm(v) return v:lower():gsub("%s+", "") end
  return norm(realm) == norm(own)
end
function S:Accept(sender, wire)
  if not enabled() or type(wire)~="string" or #wire>MAX_WIRE or #wire<8 then return end
  if wire:sub(1,#PREFIX+1)~=PREFIX..";" or wire:find("[%c]") then return end
  if type(sender)~="string" or sender=="" or isSelfSender(sender) then return end
  local p=self.peer[sender]
  local t=clock()
  if not p then p={start=t,count=0,last=0,requests=0};self.peer[sender]=p end
  if t-p.start>=60 then p.start=t;p.count=0;p.requests=0;p.responses=0;p.seen={} end
  if p.count>=20 then self.stats.throttled=self.stats.throttled+1; return end
  p.count=p.count+1
  p.lastActivity=t
  p.seen=p.seen or {}
  if p.seen[wire] and t-p.seen[wire]<90 then self.stats.duplicates=self.stats.duplicates+1; return end
  if p.count==1 then p.seen={} end
  p.seen[wire]=t
  if push(self.incoming,{sender=sender,wire=wire},MAX_IN) then self.stats.received=self.stats.received+1 else self.stats.dropped=self.stats.dropped+1 end
end
function S:Apply(sec, content, sender)
  if type(content)~="string" or #content>190 then return end
  local a={}
  for f in (content.."~"):gmatch("(.-)~") do
    a[#a+1]=f
    if #a>15 then return end
  end
  if sec=="R" or sec=="C" then
    if #a~=9 then return end
    local kind=a[1]
    if (sec=="R" and kind~="rare") or (sec=="C" and kind~="chest" and kind~="highrisk" and kind~="warmode" and kind~="object") then return end
    local map,x,y=tonumber(a[2]),tonumber(a[3]),tonumber(a[4])
    if not map or map<=0 or not x or not y or x<0 or x>10000 or y<0 or y>10000 then return end
    local rc=L:GetModule("RareChest",true)
    if rc and rc.Upsert then
      local ok=rc:Upsert({kind=kind,map=map,x=x/10000,y=y/10000,level=tonumber(a[5]),respawn=tonumber(a[6]),name=a[7],drops=a[8],notes=a[9],updated=time()},false)
      if ok then self.stats.updated=self.stats.updated+1 end
    end
  else
    if #a~=11 then return end
    for i=1,10 do if tonumber(a[i])==nil then return end end
    local c,z,item,x,y,iz,dt,q,it,ist=unpack(a)
    c=tonumber(c);z=tonumber(z);item=tonumber(item);x=tonumber(x);y=tonumber(y)
    if z<=0 or item==0 or x<0 or x>10000 or y<0 or y>10000 then return end
    local D=L:GetModule("DBSync",true)
    if D and D.ApplyRecord then
      D:ApplyRecord(c,z,item,x,y,0,0,sender,tonumber(q),tonumber(dt),tonumber(it),tonumber(ist),nil,a[11],sender,tonumber(iz))
      self.stats.updated=self.stats.updated+1
    end
  end
end
function S:Process(sender,wire)
  local kind,rest=wire:match("^LCS3;([^;]+);?(.*)$")
  if not kind then return end
  local p=self.peer[sender]
  local now=clock()
  if kind=="HELLO" then
    if rest~="3" then return end
    if now-(p.last or -1000)<60 then return end
    p.last=now
    if not self.scanning then self:Summaries() end
  elseif kind=="SUMMARY" then
    local sec,count,fp=rest:match("^([WVRC]);(%d+);(%x+)$")
    if not sec or #fp~=8 or num(count)>100000 then return end
    local localSum=self.sum[sec]
    if not self.scanning and localSum and (localSum.fp~=fp or localSum.count~=num(count)) then
      -- Send bounded fingerprint advertisements; no DATA until explicitly requested.
      self:SendDiff(sec)
    end
  elseif kind=="DIFF" then
    local sec,id,fp=rest:match("^([WVRC]);(%x+);(%x+)$")
    if not sec or #id~=8 or #fp~=8 or self.scanning then return end
    local localRec=self.index[sec] and self.index[sec][id]
    local key=sec..":"..id..":"..fp
    if (not localRec or localRec.fp<fp) and (p.requests or 0)<16 and
       (not self.requested[key] or now-self.requested[key]>=REQUEST_COOLDOWN) then
      if self:Queue({"REQUEST",sec,id,fp}) then
        p.requests=p.requests+1
        self.requested[key]=now
      end
    end
  elseif kind=="REQUEST" then
    local sec,id,fp=rest:match("^([WVRC]);(%x+);(%x+)$")
    if not sec or #id~=8 or #fp~=8 then return end
    local record=self.index[sec] and self.index[sec][id]
    if record and record.fp==fp and (p.responses or 0)<12 then
      p.responses=(p.responses or 0)+1
      self:Queue({"DATA",sec,id,fp,record.content})
    end
  elseif kind=="DATA" then
    local sec,id,fp,content=rest:match("^([WVRC]);(%x+);(%x+);(.+)$")
    if not sec or #id~=8 or #fp~=8 or not content then return end
    -- Trust neither sender's declared fingerprint nor identity.
    local a={}
    for f in (content.."~"):gmatch("(.-)~") do a[#a+1]=f end
    local reconstructed
    if sec=="R" or sec=="C" then
      reconstructed={kind=a[1],map=num(a[2]),x=num(a[3])/10000,y=num(a[4])/10000,level=num(a[5]),respawn=num(a[6]),name=a[7],drops=a[8],notes=a[9]}
    elseif #a==11 then
      reconstructed={c=num(a[1]),z=num(a[2]),i=num(a[3]),xy={x=num(a[4])/10000,y=num(a[5])/10000},iz=num(a[6]),dt=num(a[7]),q=num(a[8]),it=num(a[9]),ist=num(a[10]),itemName=a[11]}
    end
    local checkId,checkFp=reconstructed and encode(sec,reconstructed)
    if checkId~=id or checkFp~=fp then return end
    self:Apply(sec,content,sender)
    self.requested[sec..":"..id..":"..fp]=nil
    self:Queue({"ACK",sec,id,fp})
  elseif kind=="ACK" then
    self.stats.ack=self.stats.ack+1
    -- ACK is intentionally informational. No rebroadcast on acknowledgment.
    return
  end
end
function S:OnChannel(_,message,sender,_,channelDisplay,_,_,_,channelIndex,channelBaseName)
  -- CHAT_MSG_CHANNEL args on 3.3.5a provide a decorated display label
  -- (for example "6. CoASync") and a plain base name. Check both the local
  -- channel slot and its name before accepting a packet.
  local expected=channelID()
  local received=tonumber(channelIndex)
  if not expected or expected<=0 or not received or received~=expected then return end
  local function matches(name)
    if type(name)~="string" then return false end
    name=name:gsub("^%s+",""):gsub("%s+$","")
    name=name:gsub("^%d+%.%s*","")
    return name:lower()==CHANNEL:lower()
  end
  if not matches(channelBaseName) and not matches(channelDisplay) then return end
  self:Accept(sender,message)
end
function S:OnLeave()
  self.readyAt=math.huge
  self.scanAt=nil
  self.scanning=false
  self.scanData=nil
  self.outgoing={first=1,last=0};self.urgent={first=1,last=0};self.pending={}
  self.advertised={};self.requested={}
  self.incoming={first=1,last=0}
end
function S:OnEnter()
  self.readyAt=clock()+30
  self.scanAt=clock()+45
  self.sentSession=0
  self.advertised={};self.requested={}
  self.readyNotified=false
  self.scanAnnouncement=0
  -- Do not scan the database during login, map initialization, or /reload.
  self.scanning=false
  self.scanData=nil
  self.index={};self.order={};self.sum={}
  self.nextRebuild=nil
  if enabled() then say("SmartSync queued; indexing starts after 45s.") else say("SmartSync disabled; indexing skipped.") end
end
function S:OnUpdate(elapsed)
  self.tick=(self.tick or 0)+elapsed
  if self.tick<0.1 then return end
  self.tick=0
  if not enabled() then
    if not self.disabledNotified then say("SmartSync disabled; no indexing or network work.");self.disabledNotified=true end
    return
  end
  self.disabledNotified=false
  if clock()<self.readyAt then return end
  if self.scanAt and clock()>=self.scanAt then
    self.scanAt=nil
    self:Rebuild()
  end
  if self.scanning then
    self:ScanStep()
    if self.scanning and clock()-(self.scanAnnouncement or 0)>15 then
      self.scanAnnouncement=clock()
      say("Indexing discoveries: "..self.scanCount.." scanned...")
    end
    return
  end

  local t=clock()
  if self.scanAt then return end
  if t-self.lastHello>HELLO_INTERVAL then
    self:Queue({"HELLO","3"})
    self.lastHello=t
  end
  -- Bounded CPU processing; never drain an untrusted burst in one frame.
  local start=debugprofilestop and debugprofilestop() or 0
  for i=1,3 do
    if debugprofilestop and debugprofilestop()-start>2 then break end
    local packet=pop(self.incoming)
    if not packet then break end
    self:Process(packet.sender,packet.wire)
  end
  if queueLength(self.outgoing)==0 and queueLength(self.urgent)==0 and queueLength(self.incoming)==0 and not self.readyNotified then
    say("SmartSync startup complete; sharing ready ("..self.stats.updated.." records updated).")
    self.readyNotified=true
  end
  if t-self.lastSent<SEND_INTERVAL then return end
  local id=channelID()
  if id<=0 or not SendChatMessage then return end
  local urgent=queueLength(self.urgent)>0
  local q=urgent and self.urgent or self.outgoing
  local packet=pop(q)
  if not packet then return end
  if t < packet.due then push(q,packet,MAX_QUEUE); return end
  self.pending[packet.key]=nil
  -- No hidden chat-channel joins; Comm owns CoASync independently.
  if InCombatLockdown and InCombatLockdown() then
    push(q,packet,MAX_QUEUE)
    self.pending[packet.key]=true
    return
  end
  local ok = pcall(SendChatMessage,packet.wire,"CHANNEL",nil,id)
  self.lastSent=t
  if ok then self.sentSession=self.sentSession+1;self.stats.sent=self.stats.sent+1 else self.stats.dropped=self.stats.dropped+1 end
end
function S:GetStatus()
  local peers=0
  for _,p in pairs(self.peer) do if clock()-(p.lastActivity or 0)<300 then peers=peers+1 end end
  return {channel=channelID(),identity="LootCollector-Discovery-v1",schema=1,protocol=3,building=self.scanning,ready=not self.scanning and not self.scanAt,records=self.scanCount or 0,peers=peers,outgoing=queueLength(self.outgoing)+queueLength(self.urgent),incoming=queueLength(self.incoming),stats=self.stats}
end
function S:OnInitialize()
  self:RegisterEvent("CHAT_MSG_CHANNEL","OnChannel")
  self:RegisterEvent("PLAYER_LEAVING_WORLD","OnLeave")
  self:RegisterEvent("PLAYER_ENTERING_WORLD","OnEnter")
  local frame=CreateFrame("Frame")
  frame:SetScript("OnUpdate",function(_,elapsed) S:OnUpdate(elapsed) end)
  self.frame=frame
  self:OnEnter()
end
