AAV_MatchStub = {}
AAV_MatchStub.__index = AAV_MatchStub

-- @param b bracket
function AAV_MatchStub:new()
	local self = {}
	setmetatable(self, AAV_MatchStub)
	
	self.version = AAV_VERSIONMAJOR .. "." .. AAV_VERSIONMINOR .. "." .. AAV_VERSIONBUGFIX
	self.startTime = atroxArenaViewerData.current.entered
	self.endTime = ""
	self.elapsed = 0
	self.bracket = 0
	self.result = 0 -- 0 = unknown, 1 = win, 2 = loss, 3 = draw
	self.server = GetRealmName()
	self.combatans = {
		dudes = {}
	}
	self.buffs = {}
	self.debuffs = {}
	self.teams = {
		[0] = {},
		[1] = {},
	}
	self.data = {}
	
	self.map = 0 -- default
	--self.map = GetZoneText()
	for k,v in pairs(AAV_COMM_MAPS) do
		if (GetZoneText() == v) then
			self.map = k
		end
	end
	
	return self
end


function AAV_MatchStub:setResult(winnerteamid)
	local winnerid = winnerteamid
	self.result = winnerid
end
----
-- saves temporary data to variables.
-- as of 1.1.7 buffs and debuffs arent saved to variables anymore.
-- @param mid matchid

----
-- saves temporary data to variables.
-- as of 1.1.7 buffs and debuffs arent saved to variables anymore.
-- @param mid matchid
function AAV_MatchStub:saveToVariable(matchid)

	for k,v in pairs(self) do
		if (k ~= "buffs" and k ~= "debuffs") then
			atroxArenaViewerData.data[matchid][k] = v
		end
	end

end

----
-- sets the bracket according to the dudes data (no of players per team. both teams are checked, higher value is returned)
function AAV_MatchStub:setBracket()
	local bracket = 0
	local teamOnePlayerCount = 0
	local teamTwoPlayerCount = 0
	for k,v in pairs(self.combatans.dudes) do
		-- get player count of team one
		if (v.team == 1 and v.player == true) then
			teamOnePlayerCount = teamOnePlayerCount + 1
		end
		-- get player count of team two
		if (v.team == 2 and v.player == true) then
			teamTwoPlayerCount = teamTwoPlayerCount + 1
		end
	end
	-- set whichever is higher
	bracket = math.max(teamOnePlayerCount, teamTwoPlayerCount)
	self.bracket = bracket
	-- if AAV_DEBUG_MODE then
	-- 	print("teamOnePlayerCount MatchStub: " .. teamOnePlayerCount)
	-- 	print("teamTwoPlayerCount MatchStub: " .. teamTwoPlayerCount)
	-- 	print("bracket MatchStub: " .. bracket)
	-- end
end


----
-- inserts a new match member.
-- @param unit unitGUID
-- @param max
function AAV_MatchStub:newDude(unit, team, max)
	local id
	if (UnitIsPlayer(unit)) then id = max else id = max-10 end
	
	if (self.combatans.dudes[UnitGUID(unit)]) then self.combatans.dudes[UnitGUID(unit)] = nil else self.combatans.dudes[UnitGUID(unit)] = {} end
	if (self.buffs[id]) then self.buffs[id] = nil else self.buffs[id] = {} end
	if (self.debuffs[id]) then self.debuffs[id] = nil else self.debuffs[id] = {} end
	
	self.combatans.dudes[UnitGUID(unit)].name, self.combatans.dudes[UnitGUID(unit)].realm = UnitName(unit)
	_, self.combatans.dudes[UnitGUID(unit)].class = UnitClass(unit)
	_, self.combatans.dudes[UnitGUID(unit)].race = UnitRace(unit)
	self.combatans.dudes[UnitGUID(unit)].team = team -- 1 = friendly, 0 = hostile
	self.combatans.dudes[UnitGUID(unit)].player = UnitIsPlayer(unit)
	self.combatans.dudes[UnitGUID(unit)].spec = ""
	self.combatans.dudes[UnitGUID(unit)].ID = id
	self.combatans.dudes[UnitGUID(unit)].mana = 100
	self.combatans.dudes[UnitGUID(unit)].starthpmax = UnitHealthMax(unit)
	self.combatans.dudes[UnitGUID(unit)].hp = 0
	self.combatans.dudes[UnitGUID(unit)].hpmax = 0
	self.combatans.dudes[UnitGUID(unit)].ddone = 0
	self.combatans.dudes[UnitGUID(unit)].hdone = 0
	self.combatans.dudes[UnitGUID(unit)].hcrit = 0
	self.combatans.dudes[UnitGUID(unit)].ratingChange = 0
	self.combatans.dudes[UnitGUID(unit)].mmr = 0
	self.combatans.dudes[UnitGUID(unit)].rating = 0
	self.combatans.dudes[UnitGUID(unit)].hCritName = "Unknown"
	
	if (atroxArenaViewerData.current.broadcast) then
		
	end
	return UnitGUID(unit), self.combatans.dudes[UnitGUID(unit)]
end

----
-- adds a single dude to the match players list.
-- @param key GUID
-- @param dude table
function AAV_MatchStub:addDude(key, dude)
	if (self.combatans.dudes[key]) then self.combatans.dudes[key] = nil else self.combatans.dudes[key] = {} end
	if (self.buffs[id]) then self.buffs[id] = nil else self.buffs[id] = {} end
	if (self.debuffs[id]) then self.debuffs[id] = nil else self.debuffs[id] = {} end
	
	self.combatans.dudes[key].name = dude.name
	self.combatans.dudes[key].realm = dude.realm
	_, self.combatans.dudes[key].class = dude.class
	_, self.combatans.dudes[key].race = dude.race
	self.combatans.dudes[key].team = dude.team
	self.combatans.dudes[key].player = dude.player
	self.combatans.dudes[key].spec = dude.spec
	self.combatans.dudes[key].ID = dude.ID
	self.combatans.dudes[key].mana = dude.mana
	self.combatans.dudes[key].starthpmax = dude.starthpmax
	self.combatans.dudes[key].hp = dude.hp
	self.combatans.dudes[key].hpmax = dude.hpmax
	self.combatans.dudes[key].ddone = dude.ddone
	self.combatans.dudes[key].hdone = dude.hdone
	self.combatans.dudes[key].hcrit = dude.hcrit
	self.combatans.dudes[key].ratingChange = dude.ratingChange
	self.combatans.dudes[key].mmr = dude.mmr
	self.combatans.dudes[key].rating = dude.rating
	self.combatans.dudes[key].hCritName = dude.hCritName
end

----
-- returns all buffs on omitted player id.
-- @param id player id
-- @return buffs data
function AAV_MatchStub:getBuffs(id)
	return self.buffs[id]
end

----
-- returns all debuffs on omitted player id.
-- @param id player id
-- @return debuffs data
function AAV_MatchStub:getDebuffs(id)
	return self.debuffs[id]
end

----
-- returns all current dudes.
-- @return dude data
function AAV_MatchStub:getDudesData()
	return self.combatans.dudes
end

----
-- returns the ID of a GUID from a unit, if it has been saved to the dudes list. returns only player units.
-- @return ID
function AAV_MatchStub:getGUIDtoNumber(guid)
	for k,v in pairs(self:getDudesData()) do
		if (k == guid and v.player) then
			return v.ID
		end
	end
	return nil
end

----
-- converts the GUID and player name into a target like "raid1" or "arena3"
-- @param guid GUID
-- @return target
function AAV_MatchStub:getGUIDtoTarget(guid)
	local loc = {"raid", "arena"}
	for k,v in pairs(loc) do
		for i=1,5 do
			if (UnitGUID(v .. i) == guid) then
				return v .. i
			end
		end
	end
	return nil
end

----
-- converts the GUID and player name into a target like "raid1" or "arena3"
-- @param guid GUID
-- @return target
function AAV_MatchStub:getNametoGUID(name)
	local loc = {"raid", "arena"}
	for k,v in pairs(loc) do
		for i=1,5 do
			if (UnitName(v .. i) == name) then
				return UnitGUID(v .. i)
			end
		end
	end
	return nil
end
----
-- adds stats to the current match like damage done.
-- @param way 1 = damage, 2 = healing
-- @param key guid
-- @param amount value
function AAV_MatchStub:addStats(way, key, amount, spellname)
	-- DAMAGE
	if (way == 1) then
		self.combatans.dudes[key].ddone = self.combatans.dudes[key].ddone + amount
		if (amount > self.combatans.dudes[key].hcrit) then 
			self.combatans.dudes[key].hcrit = amount 
			self.combatans.dudes[key].hCritName = spellname 
		end
	-- HEALING
	elseif (way == 2) then
		self.combatans.dudes[key].hdone = self.combatans.dudes[key].hdone + amount
	end
end

----
-- updates players in the match.
-- @param team which side the unit is on (0 = hostile, 1 = friendly)
-- @param unit unitID
-- @return 1 when the unit exists, otherwise nil
function AAV_MatchStub:updateMatchPlayers(team, unit)
	
	local max = -1
	for k,v in pairs(self.combatans.dudes) do
		if k == UnitGUID(unit) then
			return 1
		end
		if (tonumber(v.ID) > max) then
			max = v.ID
		end
	end
	max = max + 1

	return self:newDude(unit, team, max)
	
end

----
-- sets the teams of the end of an arena match.
-- @param team
-- @param name
-- @param rating
-- @param diff
-- @param mmr
function AAV_MatchStub:setTeams(team, name, rating, diff, mmr)
	self.teams[team].name = name
	self.teams[team].rating = rating -- teamrating before
	self.teams[team].diff = diff -- rating diff
	self.teams[team].mmr = mmr -- team mmr rating
end

----
-- sets the player at the end of an arena match.
-- @param guids
-- @param name
-- @param rating
-- @param damageDone
-- @param healingDone
-- @param personalRatingChange
-- @param mmr
-- @param spec
function AAV_MatchStub:setPlayer(guids, playerName, rating, damageDone, healingDone, personalRatingChange, mmr, spec)
	if( self:getNametoGUID(playerName) == nil ) then  --someone of your party already left
		guid = guids[playerName]
	else
		guid = self:getNametoGUID(playerName) --enemey guid is still present even if they already left
	end

	if (spec == "auto") then
		spec = AAV_Spec:GetSpecOrDefault(guid)
	end
	
	self.combatans.dudes[guid].rating = rating -- atm no api to get others rating
	self.combatans.dudes[guid].ddone = damageDone
	self.combatans.dudes[guid].hdone = healingDone
	self.combatans.dudes[guid].ratingChange = personalRatingChange
	self.combatans.dudes[guid].mmr = mmr
	self.combatans.dudes[guid].spec = spec
end

----
-- finds the spec of the arenaOpponent 1-5, corresponding to unit arena1 - arena5
-- @param guid
-- @param opponentNumber
-- TBC Classic: set to static value nospec, spec cannot be obtained via API. could only guess by presence of certain spec specific buffs like Gladdy does, but will not implement this here for now.
function AAV_MatchStub:SetOpponentSpec(guid, opponentNumber)
	if(self.combatans.dudes[guid].spec == nil or strlen(self.combatans.dudes[guid].spec) == 0) then
		local specID = 0 --GetArenaOpponentSpec(opponentNumber)
		local _, specName = "", "nospec" --GetSpecializationInfoByID(specID)
		if(specName) then 
			--print("[debug] From M:SetOpponentSpec Update: " .. opponentNumber .. " spec set to " .. specName)
			self.combatans.dudes[guid].spec = specName
		end
	end
end

----
-- gets the team info data.
-- @return team data
function AAV_MatchStub:getTeams()
	return self.teams
end

----
-- returns a value, whether the HP or MAX HP changed.
-- @return value flag
--	0x0 = nothing changed
--	0x1 = health
--	0x2 = max health
function AAV_MatchStub:getChangeInHealthFlags(unit)
	local map = 0x0
	for k,v in pairs(self.combatans.dudes) do
		if (k == UnitGUID(unit)) then
			if (v.hp ~= UnitHealth(unit)) then
				
				v.hp = UnitHealth(unit)
				map = map + 0x1
			end
			if (v.hpmax ~= UnitHealthMax(unit)) then
				v.hpmax = UnitHealthMax(unit)
				map = map + 0x2
			end
		end
	end
	return map
end


----
-- sets the match end from the first and the last data.
-- as of 1.1.7 brackets are verified if they consist of 2, 3 or 5 and not nil.
function AAV_MatchStub:setMatchEnd()
	local max, a, b = table.getn(self.data), 0, 0
	if (self.data[1] and max) then
		a = AAV_Util:split(self.data[1], ",")
		b = AAV_Util:split(self.data[max], ",")
		self.elapsed = math.ceil(tonumber(b[1]) - tonumber(a[1]))
	end
end

----
-- creates a message and saves it.
-- @param msg message string
function AAV_MatchStub:createMessage(msg)
	atroxArenaViewerData.current.move = atroxArenaViewerData.current.move + 1
	self.data[atroxArenaViewerData.current.move] = msg
end
