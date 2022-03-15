
local L = LibStub("AceLocale-3.0"):GetLocale("atroxArenaViewer", true)

AAV_TableGui = {}
AAV_TableGui.__index = AAV_TableGui
local matchesFrame

local matchesTable
local specIconTable
local specRoleTable
local currentShowType

----
--Initializes the frame that holds the matchesTable. Parameters should be moved to conf.lua or aav.lua?
function AAV_TableGui:createMatchesFrame()
	--local o = CreateFrame("Frame", "AAVMatches", UIParent)
	local o = CreateFrame("Frame", "AAVMatches", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	o:SetFrameStrata("HIGH")
	o:SetPoint("Center", 0, 0)

	o:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile=1, tileSize=10, edgeSize=10, 
		insets={left=3, right=3, top=3, bottom=3}
	  })
	o:SetMovable(true)
	o:EnableMouse(true)
	o:SetScript("OnMouseDown", function(self, button ) o:StartMoving() end)
	o:SetScript("OnMouseUp", function(self, button ) o:StopMovingOrSizing() end)

	
	local m = CreateFrame("Frame", "$parentTitle", o, BackdropTemplateMixin and "BackdropTemplate")
	m:SetHeight(30)
	m:SetPoint("TOP", 0, 18)
	m:SetBackdrop({
	  bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
	  edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
	  tile=1, tileSize=10, edgeSize=20, 
	  insets={left=3, right=3, top=3, bottom=3}, 
	})
	m:SetBackdropColor(0, 0, 0, 1) -- 0,0,0,1
	m:Show()
    m:SetMovable(true)
	m:SetScript("OnMouseDown", function(self, button) o:StartMoving() end)
	m:SetScript("OnMouseUp", function(self, button) o:StopMovingOrSizing() end)
	

	local ts = m:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	ts:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
	ts:SetText("AAV: Recorded Matches")
	ts:SetPoint("CENTER", m, 0, 0)
	ts:Show()
	m:SetWidth(ts:GetStringWidth() + 25)
		
	
	local btn = CreateFrame("Button", "$parentCloseButton", o, BackdropTemplateMixin and "BackdropTemplate")
	btn:SetHeight(32)
	btn:SetWidth(32)
	
	btn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	btn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
	
	btn:SetPoint("TOPRIGHT" , o, "TOPRIGHT", 0, 0)
	btn:SetScript("OnClick", function (s, b, d)
		o:Hide()
	end)
	
	matchesFrame = o
end

---
-- Shows the frames and the matchesTable, and initializes them if they are nil
function AAV_TableGui:showMatchesFrame()
	if (not matchesTable) then --All initialization
		AAV_TableGui:createMatchesFrame()
		AAV_TableGui:createMatchesTable()
		self:generateSpecIconAndRoleTables()
		matchesTable.frame:SetBackdropColor(0.1,0.1,0.1,0.9);
		currentShowType = atroxArenaViewerData.current.showBySpec
		local width, height = matchesTable.frame:GetSize()
		matchesTable.frame:SetPoint("CENTER",0,-15)
		matchesFrame:SetWidth(width)
		matchesFrame:SetHeight(height + 30)
	end
	if(atroxArenaViewerData.data and atroxArenaViewerData.data[1] and matchesTable.data and matchesTable.data[1]) then
		-- Quick check to see if the table needs to be updated: if the table has the most recent game and the same number of rows as games recorded then no update required
		if (atroxArenaViewerData.current.showBySpec ~= currentShowType or atroxArenaViewerData.data[1]["startTime"] ~= matchesTable.data[1].cols[1]["value"] or #atroxArenaViewerData.data ~= #matchesTable.data) then
			self:fillMatchesTable()
			currentShowType = atroxArenaViewerData.current.showBySpec
		end			
	else
		self:fillMatchesTable()
	end
	matchesFrame:Show()
end

----
-- Tells if the table holding the matches result is showing.
function AAV_TableGui:isMatchesFrameShowing()
	return (matchesFrame and matchesFrame:IsShown())
end

----
-- Hides the matches result table.
function AAV_TableGui:hideMatchesFrame()
	if (matchesFrame) then matchesFrame:Hide() end
end

----
-- Causes the matches result table to be refreshed if it is showing.
function AAV_TableGui:RefreshFrameIfShowing()
	if(self:isMatchesFrameShowing()) then AAV_TableGui:showMatchesFrame() end
end

----
-- Initializes the matches frame table with only columns and OnClick effects. Called by showMatchesFrame().
function AAV_TableGui:createMatchesTable()
	local ScrollingTable = LibStub("ScrollingTable")
	local cols = {
		{
			["name"] = "Date",
		 	["width"] = 115,
			["sort"] = "asc",
		}, -- [1]
		{
			["name"] = "Duration",
			["width"] = 60,
		}, -- [2]
		{
			["name"] = "Map",
			["width"] = 115,
		}, -- [3]
		{
			["name"] = "Team",
			["width"] = 125,
		}, -- [4]
		{
			["name"] = " ", -- matchup (class icons)
			["width"] = 250,
		}, -- [5]
		{
			["name"] = "Enemy Team",
			["width"] = 125,
		}, -- [6]
		{
			["name"] = "Result",
			["width"] = 50,
		}, -- [7]
		{
			["name"] = "Rating",
			["width"] = 70,
		}, -- [8]
		{
			["name"] = "MMR",
			["width"] = 70,
		}, -- [9]
		{
			["name"] = "Enemy Rating",
			["width"] = 70,
		}, -- [10]
		{
			["name"] = "Enemy MMR",
			["width"] = 70,
		}, -- [11]
		{
			["name"] = "Delete",
			["width"] = 50,
		}, -- [12]
	};
	matchesTable = ScrollingTable:CreateST(cols, 20, 22, nil, matchesFrame);
	matchesTable:RegisterEvents({
		["OnClick"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button, ...)
			if (button == "RightButton") then
				--self:hideMatchesFrame()
			elseif (row and column and realrow and atroxArenaViewerData and atroxArenaViewerData.data and atroxArenaViewerData.data[realrow]) then
				if(column == #cols) then
					atroxArenaViewer:deleteMatch(realrow)
					self:showMatchesFrame()
				else
					self:hideMatchesFrame()
					atroxArenaViewer:createPlayer(realrow)
					atroxArenaViewer:playMatch(realrow)
				end
			end
		end,
	});
end


-- debug function
local tabLevel = 0
local function printTable(table)
    for key,value in pairs(table) do
        if type(value) == "table" then
	        tabLevel = tabLevel + 1
	        print(string.rep("    ",tabLevel - 1)..key.." : {")
            printTable(value)
            print(string.rep("    ",tabLevel - 1).."}")
            tabLevel = tabLevel - 1
        else
            print(string.rep("    ",tabLevel)..key,value)
        end
    end
end

----
-- Fills in the data in the matches results table. Called by showMatchesFrame().
function AAV_TableGui:fillMatchesTable()	
	local data = {}
	if(atroxArenaViewerData.data and atroxArenaViewerData.data[1]) then
		local deleteColor  = { ["r"] = 1.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 1.0 };
		local unknownMatchColor = { ["r"] = 1.0, ["g"] = 0.00, ["b"] = 0.00, ["a"] = 1.0 };
		local wonMatchColor = { ["r"] = 0.00, ["g"] = 1.00, ["b"] = 0.00, ["a"] = 1.0 };
		local lostMatchColor = { ["r"] = 1.0, ["g"] = 0.00, ["b"] = 0.00, ["a"] = 1.0 };

		for row = 1, #atroxArenaViewerData.data do
			if not data[row] then
				data[row] = {};
			end
			data[row].cols = {};
			
			local startTime, elapsedStr, mapname, matchUp, ownTeam, enemyTeam, matchResult, ownTeamRating, ownTeamMMR, ownTeamRatingDiff, enemyTeamRating, enemyTeamMMR, enemyTeamRatingDiff = self:determineMatchSummary(row)

			-- start time
			data[row].cols[1] = { ["value"] = startTime };

			-- elapsed time
			data[row].cols[2] = { ["value"] = elapsedStr };

			-- map name
			data[row].cols[3] = { ["value"] = mapname };

			-- own team name
			data[row].cols[4] = { ["value"] = ownTeam or nil };
			
			-- matchUp (both teams classes xx vs yy)
			data[row].cols[5] = { ["value"] = matchUp };

			-- enemy team name
			data[row].cols[6] = { ["value"] = enemyTeam or nil };

			-- match result
			data[row].cols[7] = { ["value"] = matchResult or nil };

			-- own team rating + diff
			data[row].cols[8] = { ["value"] = ownTeamRating .. " (" .. ownTeamRatingDiff .. ")" };

			if (matchResult and matchResult == "WIN") then
				data[row].cols[7].color = wonMatchColor
				data[row].cols[8].color = wonMatchColor
			elseif (matchResult and matchResult == "LOSS") then
				data[row].cols[7].color = lostMatchColor
				data[row].cols[8].color = lostMatchColor
			end

			-- own team MMR
			data[row].cols[9] = { ["value"] = ownTeamMMR };
			--data[row].cols[8] = { ["value"] = teamOneRating };

			-- enemy team rating
			data[row].cols[10] = { ["value"] = enemyTeamRating .. " (" .. enemyTeamRatingDiff .. ")" };
			--data[row].cols[8] = { ["value"] = teamOneRating };

			-- enemy team MMR
			data[row].cols[11] = { ["value"] = enemyTeamMMR };
			--data[row].cols[8] = { ["value"] = teamOneRating };

			-- delete
			data[row].cols[12] = { ["value"] = "DELETE" };
			data[row].cols[12].color = deleteColor


		end
	else
		data[1] = {};
		data[1].cols = {};
		for i = 1, 12 do
			data[1].cols[i] = { ["value"] = "None" }; -- if no data available (empty data)
		end
	end
	matchesTable:SetData(data);
	matchesTable:SortData();
end


---
-- Returns the relavent information for match (num). 
-- @param num The match number.
function AAV_TableGui:determineMatchSummary(num)
	local elapsedStr, mapname, matchResult, idSortStr, ownTeam, enemyTeam, ownTeamRating, ownTeamMMR, ownTeamRatingDiff, enemyTeamRating, enemyTeamMMR, enemyTeamRatingDiff
	local teamdata = atroxArenaViewerData.data[num]["teams"]
	local matchdata = atroxArenaViewerData.data[num]["combatans"]["dudes"]
	local startTime = atroxArenaViewerData.data[num]["startTime"]
	local elapsed = atroxArenaViewerData.data[num].elapsed
	--local healersList = {a = true, b = true, c = true}

	elapsedStr = string.format("%.2d:%.2d", math.floor(elapsed / 60), elapsed % 60)

	-- set team names
	if (teamdata[0].name) then
		ownTeam = teamdata[0].name
	else
		ownTeam = "unknown teamname"
	end

	if (teamdata[1].name) then
		enemyTeam = teamdata[1].name
	else
		enemyTeam = "unknown teamname"
	end

	-- set map name
	if (type(atroxArenaViewerData.data[num]["map"])=="number") then
		if (AAV_COMM_MAPS[atroxArenaViewerData.data[num]["map"]]) then
			mapname = AAV_COMM_MAPS[atroxArenaViewerData.data[num]["map"]]
		else
			mapname = "Unknown"
		end
	else
		mapname = atroxArenaViewerData.data[num]["map"]
	end

	-- set match result
	-- win or loss
	if atroxArenaViewerData.data[num]["result"] == 0 then
		matchResult = "UNKNOWN"
	elseif atroxArenaViewerData.data[num]["result"] == 1 then
		matchResult = "WIN"
	elseif atroxArenaViewerData.data[num]["result"] == 2 then
		matchResult = "LOSS"
	else -- catch all, should not occur
		matchResult = atroxArenaViewerData.data[num]["result"]
		--print("unknownMatchColor no valid result") -- debug
	end

	-- ???
	local teamOne, teamTwo = {}, {}
	for k ,v in pairs(teamdata) do
		local team = k+1
		for c,w in pairs(matchdata) do
			if (w.player == true and w.team == team) then
				if (w.class) then
					idSortStr = w.class
				else
					idSortStr = "   " .. w.name .. c
				end
				if (w.ddone > w.hdone) then
					idSortStr = "DAMAGER".. idSortStr
				else
					idSortStr = "HEALER" .. idSortStr
				end
				if (team == 1) then
					teamOne[idSortStr] = w
				elseif (team == 2) then
					teamTwo[idSortStr] = w
				end
			end
		end
	end

	-- Sorts the way the names are displayed, so that DPS comes before healers, then alphabetically sorts through class, name, and guid.
	sortNames = function(aTeam)
		local keys, sortedNames = {}, ""
		for k in pairs(aTeam) do
			keys[#keys+1] = k
		end
		table.sort(keys)
		for k, v in pairs(keys) do
			local w, icon = aTeam[v], nil
			if (w.class) then
				icon = specIconTable[w.class]
			else
				icon = specIconTable("UNKNOWN")
			end
			sortedNames = sortedNames .. " " .. icon
		end
		return sortedNames
	end
	local matchUp = sortNames(teamOne) .. "  vs  " .. sortNames(teamTwo)
	
	-- set ratings, catch nil values (happens e.g. if you leave arena early)
	if (teamdata[0]["rating"]) then
		ownTeamRating = teamdata[0]["rating"]
		ownTeamMMR = teamdata[0]["mmr"]
		ownTeamRatingDiff = teamdata[0]["diff"]
	else
		ownTeamRating = 0
		ownTeamMMR = 0
		ownTeamRatingDiff = 0
	end

	if (teamdata[1]["rating"]) then
		enemyTeamRating = teamdata[1]["rating"]
		enemyTeamMMR = teamdata[1]["mmr"]
		enemyTeamRatingDiff = teamdata[1]["diff"]
	else
		enemyTeamRating = 0
		enemyTeamMMR = 0
		enemyTeamRatingDiff = 0
	end

	return startTime, elapsedStr, mapname, matchUp, ownTeam, enemyTeam, matchResult, ownTeamRating, ownTeamMMR, ownTeamRatingDiff, enemyTeamRating, enemyTeamMMR, enemyTeamRatingDiff
end

----
-- TBC Classic is unable to use GetSpecializationInfoByID. So Manually added classes / icons.
-- "spec" and "role" is not available in TBC classic, so these have been removed.
function AAV_TableGui:generateSpecIconAndRoleTables()
	specIconTable = {}

	local classIconPath = "Interface\\Addons\\aav\\res\\"
	local classIcons = {
		["DRUID"] = classIconPath .. "DRUID",
		["HUNTER"] = classIconPath .. "HUNTER",
		["MAGE"] = classIconPath .. "MAGE",
		["PALADIN"] = classIconPath .. "PALADIN",
		["PRIEST"] = classIconPath .. "PRIEST",
		["ROGUE"] = classIconPath .. "ROGUE",
		["SHAMAN"] = classIconPath .. "SHAMAN",
		["WARLOCK"] = classIconPath .. "WARLOCK",
		["WARRIOR"] = classIconPath .. "WARRIOR",
		["UNKNOWN"] = classIconPath .. "UNKNOWN",
	}

	local classNames = {
		["DRUID"] = C_CreatureInfo.GetClassInfo(11).classFile,
		["HUNTER"] = C_CreatureInfo.GetClassInfo(3).classFile,
		["MAGE"] = C_CreatureInfo.GetClassInfo(8).classFile,
		["PALADIN"] = C_CreatureInfo.GetClassInfo(2).classFile,
		["PRIEST"] = C_CreatureInfo.GetClassInfo(5).classFile,
		["ROGUE"] = C_CreatureInfo.GetClassInfo(4).classFile,
		["SHAMAN"] = C_CreatureInfo.GetClassInfo(7).classFile,
		["WARLOCK"] = C_CreatureInfo.GetClassInfo(9).classFile,
		["WARRIOR"] = C_CreatureInfo.GetClassInfo(1).classFile,
		["UNKNOWN"] = "UNKNOWN",
	}

	specIconTable[classNames["DRUID"]] = "\124T" .. classIcons["DRUID"] .. ":22\124t"
	specIconTable[classNames["HUNTER"]] = "\124T" .. classIcons["HUNTER"] .. ":22\124t"
	specIconTable[classNames["MAGE"]] = "\124T" .. classIcons["MAGE"] .. ":22\124t"
	specIconTable[classNames["PALADIN"]] = "\124T" .. classIcons["PALADIN"] .. ":22\124t"
	specIconTable[classNames["PRIEST"]] = "\124T" .. classIcons["PRIEST"] .. ":22\124t"
	specIconTable[classNames["ROGUE"]] = "\124T" .. classIcons["ROGUE"] .. ":22\124t"
	specIconTable[classNames["SHAMAN"]] = "\124T" .. classIcons["SHAMAN"] .. ":22\124t"
	specIconTable[classNames["WARLOCK"]] = "\124T" .. classIcons["WARLOCK"] .. ":22\124t"
	specIconTable[classNames["WARRIOR"]] = "\124T" .. classIcons["WARRIOR"] .. ":22\124t"
	specIconTable[classNames["UNKNOWN"]] = "\124T" .. classIcons["UNKNOWN"] .. ":22\124t"
end

----
-- Uses AAV_Util to get the color that each name should be, and is called if a character's spec is not recorded or if (not showBySpec).
function AAV_TableGui:getClassColoredName(player)
	local r, g, b = AAV_Util:getTargetColor(player, true)
	return "\124c" .. format("ff%02x%02x%02x", r * 255, g * 255, b * 255) .. player.name .. "\124r"
end