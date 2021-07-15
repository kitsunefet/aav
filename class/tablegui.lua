
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
		print("Fill matches table isn't working.")
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
		 	["width"] = 125,
			["sort"] = "asc",
		}, -- [1]
		{
			["name"] = "Duration",
			["width"] = 70,
		}, -- [2]
		{
			["name"] = "Map",
			["width"] = 125,
		}, -- [3]
		{
			["name"] = " ",
			["width"] = 285,		
		}, -- [4]
		{
			["name"] = "Result",
			["width"] = 50,		
		}, -- [5]
		{
			["name"] = "Rating",
			["width"] = 100,		
		}, -- [6]
		{
			["name"] = " ",
			["width"] = 50,		
		}, -- [7]
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

----
-- Fills in the data in the matches results table. Called by showMatchesFrame().
function AAV_TableGui:fillMatchesTable()	
	local data = {}
	if(atroxArenaViewerData.data and atroxArenaViewerData.data[1]) then
		local deleteColor  = { ["r"] = 1.0, ["g"] = 0.0, ["b"] = 0.0, ["a"] = 1.0 };
		local wonMatchColor = { ["r"] = 0.00, ["g"] = 1.0, ["b"] = 0.00, ["a"] = 1.0 };
		local lostMatchColor = { ["r"] = 1.0, ["g"] = 0.00, ["b"] = 0.00, ["a"] = 1.0 };
		for row = 1, #atroxArenaViewerData.data do
			if not data[row] then
				data[row] = {};
			end
			data[row].cols = {};
			
			-- start time
			data[row].cols[1] = { ["value"] = atroxArenaViewerData.data[row]["startTime"] };

			-- elapsed time
			local elapsed = atroxArenaViewerData.data[row].elapsed
			data[row].cols[2] = { ["value"] = string.format("%.2d : %.2d", math.floor(elapsed / 60), elapsed % 60) };

			-- map name
			data[row].cols[3] = { ["value"] = AAV_COMM_MAPS[atroxArenaViewerData.data[row]["map"]] };

			-- match up against
			data[row].cols[4] = { ["value"] = "vs       " .. atroxArenaViewerData.data[row].teams[1].name };

			-- win or loss
			data[row].cols[5] = { ["value"] = atroxArenaViewerData.data[row]["result"] == 0 and "LOSS" or "WIN" };

			-- rating
			data[row].cols[6] = { ["value"] = atroxArenaViewerData.data[row]["teams"][1]["rating"] };

			-- delete
			data[row].cols[7] = { ["value"] = "DELETE" };

			if (atroxArenaViewerData.data[row]["result"] == 1) then
				data[row].cols[5].color = wonMatchColor
			elseif (atroxArenaViewerData.data[row]["result"] == 0) then
				data[row].cols[5].color = lostMatchColor
			end
			data[row].cols[7].color = deleteColor
		end
	else
		data[1] = {};
		data[1].cols = {};
		for i = 1, 7 do
			data[1].cols[i] = { ["value"] = "None" };
		end
	end
	matchesTable:SetData(data);
	matchesTable:SortData();
end

----
-- Brute force initializes the table that contains the spec icon and role of each spec.
function AAV_TableGui:generateSpecIconAndRoleTables()
	specIconTable = {}
	specRoleTable = {}

	--[[
	for a = 1, 300 do
		local _, spec, _, icon, _, role, class = GetSpecializationInfoByID(a)
		if(spec and icon and className) then
			specIconTable[className .. " " .. spec] = "\124T" .. icon .. ":22\124t"
			specRoleTable[className .. " " .. spec] = role
		end
	end
	]]--

	-- TBC Classic is unable to use GetSpecializationInfoByID. So Manually added classes / icons.
	-- Couldn't work out if "spec" and "role" is requried and how to get.

	local classIconPath = "Interface\\Addons\\aav\\images\\classes\\"
	local classIcons = {
		["DRUID"] = classIconPath .. "inv_misc_monsterclaw_04",
		["HUNTER"] = classIconPath .. "inv_weapon_bow_07",
		["MAGE"] = classIconPath .. "inv_staff_13",
		["PALADIN"] = classIconPath .. "inv_hammer_01",
		["PRIEST"] = classIconPath .. "inv_staff_30",
		["ROGUE"] = classIconPath .. "inv_throwingknife_04",
		["SHAMAN"] = classIconPath .. "inv_jewelry_talisman_04",
		["WARLOCK"] = classIconPath .. "spell_nature_drowsy",
		["WARRIOR"] = classIconPath .. "inv_sword_27",
	}

	local classNames = {
		["DRUID"] = C_CreatureInfo.GetClassInfo(11).className,
		["HUNTER"] = C_CreatureInfo.GetClassInfo(3).className,
		["MAGE"] = C_CreatureInfo.GetClassInfo(8).className,
		["PALADIN"] = C_CreatureInfo.GetClassInfo(2).className,
		["PRIEST"] = C_CreatureInfo.GetClassInfo(5).className,
		["ROGUE"] = C_CreatureInfo.GetClassInfo(4).className,
		["SHAMAN"] = C_CreatureInfo.GetClassInfo(7).className,
		["WARLOCK"] = C_CreatureInfo.GetClassInfo(9).className,
		["WARRIOR"] = C_CreatureInfo.GetClassInfo(1).className,
	}

	specIconTable[classNames["DRUID"] .. " " .. "spec"] = "\124T" .. classIcons["DRUID"] .. ":22\124t"
	specRoleTable[classNames["DRUID"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["HUNTER"] .. " " .. "spec"] = "\124T" .. classIcons["HUNTER"] .. ":22\124t"
	specRoleTable[classNames["HUNTER"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["MAGE"] .. " " .. "spec"] = "\124T" .. classIcons["MAGE"] .. ":22\124t"
	specRoleTable[classNames["MAGE"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["PALADIN"] .. " " .. "spec"] = "\124T" .. classIcons["PALADIN"] .. ":22\124t"
	specRoleTable[classNames["PALADIN"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["PRIEST"] .. " " .. "spec"] = "\124T" .. classIcons["PRIEST"] .. ":22\124t"
	specRoleTable[classNames["PRIEST"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["ROGUE"] .. " " .. "spec"] = "\124T" .. classIcons["ROGUE"] .. ":22\124t"
	specRoleTable[classNames["ROGUE"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["SHAMAN"] .. " " .. "spec"] = "\124T" .. classIcons["SHAMAN"] .. ":22\124t"
	specRoleTable[classNames["SHAMAN"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["WARLOCK"] .. " " .. "spec"] = "\124T" .. classIcons["WARLOCK"] .. ":22\124t"
	specRoleTable[classNames["WARLOCK"]  .. " " .. "spec"] = "role"
	specIconTable[classNames["WARRIOR"] .. " " .. "spec"] = "\124T" .. classIcons["WARRIOR"] .. ":22\124t"
	specRoleTable[classNames["WARRIOR"]  .. " " .. "spec"] = "role"

end

----
-- Uses AAV_Util to get the color that each name should be, and is called if a character's spec is not recorded or if (not showBySpec).
function AAV_TableGui:getClassColoredName(player)
	local r, g, b = AAV_Util:getTargetColor(player, true)
	return "\124c" .. format("ff%02x%02x%02x", r * 255, g * 255, b * 255) .. player.name .. "\124r"
end