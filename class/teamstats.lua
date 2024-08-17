AAV_TeamStats = {}
AAV_TeamStats.__index = AAV_TeamStats

function AAV_TeamStats:new(parent, teamdata, matchdata, team, bracket)

	-- if AAV_DEBUG_MODE then
	-- 	print("AAV_TeamStats:new") -- debug
	-- end
	local self = {}
	setmetatable(self, AAV_TeamStats)

	self.posY = ((team-1) * bracket * (35))
	self.teamhead = AAV_Gui:createTeamHead(parent, self.posY, team)
	self.entries = {}
	for i = 1, 5 do
		self.entries[i] = {}
		self.entries[i]["entry"], self.entries[i]["icon"], self.entries[i]["name"], self.entries[i]["damage"], self.entries[i]["high"], self.entries[i]["heal"], self.entries[i]["rating"], self.entries[i]["mmr"] = AAV_Gui:createDetailEntry(parent, self.posY, i-1, team)
	end
	
	self:setValue(parent, teamdata, matchdata, team, bracket)
	
	return self
	
end

function AAV_TeamStats:hideAll()
	for k,v in pairs(self.entries) do
		v["entry"]:Hide()
	end
	self.teamhead:Hide()
end

function AAV_TeamStats:trunkHCritSpellName(spellName)
	local spellNameLen = string.len(spellName)
	local MAXLINECHARS = 16
	local tmp
	
	if ( spellNameLen > MAXLINECHARS ) then
		spellName = string.sub(spellName,1,MAXLINECHARS)
	end
	return spellName
end

function AAV_TeamStats:setValue(parent, teamdata, matchdata, team, bracket)
	
	self.parent = parent
	self.team = team
	self.bracket = bracket
	
	self:hideAll()

	-- kind of a hack to re-align team-name position in stats frame
	self.teamhead:Show()
	self.teamhead:SetText(teamdata.name)

	local rating, mmr, diff
	local i = 1
	local j = 1
	
	for c,w in pairs(matchdata) do
		if (w.player == true and w.team == team) then
			
			
			if (teamdata.diff and teamdata.diff >= 0) then 
				diff = "+" .. teamdata.diff
			elseif (teamdata.diff == nil) then
				diff = 0
			else
				diff = teamdata.diff
			end

			if (not teamdata.rating) then
				rating = "? (" .. diff .. ")" 
			else 
				rating = teamdata.rating .. " (" .. diff .. ")" 
			end

			if (not teamdata.mmr) then 
				mmr = "-" 
			else 
				mmr = teamdata.mmr 
			end
			
			local higestDamage = w.hcrit .."\n" .. self:trunkHCritSpellName(w.hCritName)
			local class
			if (w.class) then
				class = w.class
			else
				class = "UNKNOWN"
			end
			self.entries[i]["entry"]:Show()
			self.entries[i]["icon"].texture:SetTexture("Interface\\Addons\\aav\\res\\" .. class .. ".tga")
			if (w.spec~="nospec" and w.spec~="" and _atroxArenaViewerData.defaults.profile.showdetectedspec) then
				self.entries[i]["icon"].texture:SetTexture("Interface\\Addons\\aav\\res\\spec\\" .. w.spec .. ".tga")
			end
			self.entries[i]["name"]:SetText(w.name)
			self.entries[i]["name"]:SetTextColor(AAV_Util:getTargetColor(w, true))
			self.entries[i]["damage"]:SetText(w.ddone)
			self.entries[i]["high"]:SetText(higestDamage)
			self.entries[i]["heal"]:SetText(w.hdone)
			self.entries[i]["rating"]:SetText(rating)
			self.entries[i]["mmr"]:SetText(mmr)
			i = i + 1
		end
	end
	
end
