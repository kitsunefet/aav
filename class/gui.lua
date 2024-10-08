
local _G = _G
local L = LibStub("AceLocale-3.0"):GetLocale("atroxArenaViewer", true)
local AceGUI = _G.LibStub("AceGUI-3.0")
AAV_Gui = {}
AAV_Gui.__index = AAV_Gui

function AAV_Gui:createPlayerFrame(obj, bracket)
	
	-- if AAV_DEBUG_MODE then
	-- 	print("AAV_Gui:createPlayerFrame")
	-- 	print("bracket: " .. bracket)
	-- end

	if (not bracket) then
		return
	end
	
	local o = CreateFrame("Frame", "AAVRoot", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	o:SetFrameStrata("HIGH")
	o:SetWidth(650)
	o:SetPoint("Center", 0, 0)
	self:setPlayerFrameSize(o, bracket)
	
	local f = CreateFrame("Frame", "$parentPlayer", o, BackdropTemplateMixin and "BackdropTemplate")
	f:SetFrameStrata("HIGH")
	f:SetWidth(650)
	f:SetPoint("TOPLEFT", o, "TOPLEFT", 0, 0)
	
	self:setPlayerFrameSize(f, bracket)
	--f:SetPoint("CENTER",0,0)
	o:SetBackdrop({
	  bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
	  --edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	  edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
	  tile=1, tileSize=10, edgeSize=10, 
	  insets={left=3, right=3, top=3, bottom=3}
	})
	o:SetMovable(true)
	o:EnableMouse(true)
	o:SetScript("OnMouseDown", o.StartMoving)
	o:SetScript("OnMouseUp", o.StopMovingOrSizing)
	o:Show()
	
	local m = CreateFrame("Frame", "$parentMapText", o, BackdropTemplateMixin and "BackdropTemplate")
	m:SetHeight(30)
	m:SetPoint("TOP", 0, 18)
	m:SetBackdrop({
	  bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
	  edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
	  tile=1, tileSize=10, edgeSize=20, 
	  insets={left=3, right=3, top=3, bottom=3}, 
	})
	m:SetBackdropColor(0, 0, 0, 1)
	
	local mt = m:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	mt:SetFont("Fonts\\FRIZQT___CYR.TTF", 16, "OUTLINE")
	mt:SetText("???")
	mt:SetPoint("CENTER", m, 0, 0)
	mt:Show()
	
	
	local l = CreateFrame("STATUSBAR", "$parentLoading", o, BackdropTemplateMixin and "BackdropTemplate")
	l:SetWidth(150)
	l:SetPoint("CENTER", o:GetName(), 0, 0)
	l:SetStatusBarTexture("Interface\\Addons\\aav\\res\\" .. _atroxArenaViewerData.defaults.profile.hpbartexture .. ".tga")
	l:SetHeight(30)
	l:SetMinMaxValues(0, 100)
	l:SetValue(50)
	l:Show()
	
	--m:SetWidth(mt:GetStringWidth() + 25)
	
	
	local btn = CreateFrame("Button", "PlayerCloseButton", o, BackdropTemplateMixin and "BackdropTemplate")
	btn:SetHeight(32)
	btn:SetWidth(32)
	
	btn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	btn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
	
	btn:SetPoint("TOPRIGHT" , o, "TOPRIGHT", 0, 0)
	btn:SetScript("OnClick", function (s, b, d)
		obj:hidePlayer(s:GetParent())
		obj:hideMovingObjects()
		atroxArenaViewer:stopListening()
		_atroxArenaViewerData.current.listening = ""
		obj:setOnUpdate("stop")
	end)
	btn:Show()
	
	return o, f, mt, l
end

function AAV_Gui:setPlayerFrameSize(frame, bracket)
	-- set size for cases where bracket size could not be determined safely, so we guess the size here as a fallback
	-- 0 or 1 players assumes 2v2 bracket
	-- 2 players is fine
	-- 3 players is fine
	-- 4 players assumes 5v5 bracket
	-- 5 players is fine
	if bracket == 0 or bracket == 1 then
		frame:SetHeight(110 + (AAV_GUI_VERTICALFRAMEDISTANCE * 2))
	elseif bracket == 4 then
		frame:SetHeight(110 + (AAV_GUI_VERTICALFRAMEDISTANCE * 5))
	else -- no guessing if its valid values (2, 3 or 5 obviously)
		frame:SetHeight(110 + (AAV_GUI_VERTICALFRAMEDISTANCE * tonumber(bracket))) -- all other cases (this could still be wrong e.g. only 3 out of 5 ppl joined, so we calculated 3 as bracket size)
	end
	
end

----
-- @return b statusbar HP
-- @return c frame icon
-- @return cr frame combattext range
-- @return br frame buff range
-- @return dr frame debuff range
function AAV_Gui:createEntityBar(parent, v, y)
	local anchor, offx, manauser
	
	--print("createEntityBar")
	--print("createEntityBar: " .. v.name)

	if (v.team==1) then anchor = "TOPLEFT" else anchor = "TOPRIGHT" end
	if (v.team==1) then offx = 85 else offx = 355 end
	
	manauser = AAV_Util:determineManaUser(v.class)
	
	-- FRAME
	local a = CreateFrame("Frame", "$parentEntity" .. v.team .. y, parent)
	a:SetWidth(180)
	a:SetHeight(15)
	a:SetPoint("TOPLEFT", parent, offx, -70-(y * AAV_GUI_VERTICALFRAMEDISTANCE))
	a:Show()
	
	-- ICON
	local c = CreateFrame("Frame", "$parentClazz", a)
	--c:SetFrameStrata("MEDIUM")
	c:SetWidth(30)
	c:SetHeight(30)
	
	local t = c:CreateTexture(nil)
	
	if (not v.class or v.class == "Unknown") then
		t:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark.blp")
	else
		t:SetTexture("Interface\\Addons\\aav\\res\\" .. v.class .. ".tga")
	end
	if (v.spec ~= "" and v.spec ~= "nospec" and _atroxArenaViewerData.defaults.profile.showdetectedspec) then
		t:SetTexture("Interface\\Addons\\aav\\res\\spec\\" .. v.spec .. ".tga")
	end
	t:SetAllPoints(c)
	c.texture = t
	c:SetPoint("TOPLEFT", a:GetName(), 0, 15)
	c:Show()

	
	
	-- HEALTH BAR
	local b = CreateFrame("STATUSBAR", "$parentHealthBar", a)
	b:SetWidth(135)
	if (manauser) then b:SetHeight(AAV_GUI_HEALTHBARHEIGHT - AAV_GUI_MANABARHEIGHT) else b:SetHeight(AAV_GUI_HEALTHBARHEIGHT) end
	b:SetStatusBarTexture("Interface\\Addons\\aav\\res\\" .. _atroxArenaViewerData.defaults.profile.hpbartexture .. ".tga")
	--b:SetStatusBarColor(AAV_Util:getTargetColor(v, false))
	b:SetMinMaxValues(0, UnitHealth("player"))
	b:SetPoint("TOPLEFT", a:GetName(), 30, 1)
	b:Show()
	

	local bback = b:CreateTexture(nil, "BACKGROUND")
	bback:SetAllPoints(b)
	bback:SetColorTexture(0, 0, 0, 1)
	b.tex = bback
	
	-- MANA BAR
	local m = CreateFrame("STATUSBAR", "$parentManaBar", a)
	m:SetWidth(135)
	m:SetHeight(AAV_GUI_MANABARHEIGHT)
	m:SetStatusBarTexture("Interface\\Addons\\aav\\res\\" .. _atroxArenaViewerData.defaults.profile.manabartexture .. ".tga")
	--m:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
	m:SetMinMaxValues(0,100)
	
	if (manauser) then m:SetStatusBarColor(0.53, 0.53, 0.9) end

	m:SetPoint("BOTTOMLEFT", a:GetName(), "TOPLEFT", 30, -(AAV_GUI_HEALTHBARHEIGHT - 1))
	if (manauser) then m:Show() else m:Hide() end
	
	local mback = m:CreateTexture(nil, "BACKGROUND")
	mback:SetAllPoints(m)
	mback:SetColorTexture(0, 0, 0, 1)
	m.tex = mback
	
	
	-- COMBAT TEXT
	local cr = CreateFrame("Frame", "$parentCombatRange", parent)
	cr:SetFrameStrata("HIGH")
	cr:SetWidth(70)
	cr:SetHeight(50)
	if (v.team == 1) then cr:SetPoint("BOTTOMLEFT", b, "BOTTOMRIGHT", -5, 0) end
	if (v.team == 2) then cr:SetPoint("BOTTOMRIGHT", b, "BOTTOMLEFT", -10, 0) end
	cr:Show()
	
	-- PLAYER NAME
	local n = c:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	n:SetFont("Fonts\\FRIZQT___CYR.TTF", 14, "OUTLINE")
	n:SetText(v.name)
	n:SetPoint("CENTER", b, 0, 15)
	n:Show()
	
	-- SKILL
	local sr = CreateFrame("Frame", "$parentEntity".. v.team .. y.."SkillRange", parent)
	sr:SetFrameStrata("HIGH")
	sr:SetWidth(a:GetWidth())
	sr:SetHeight(30)
	sr:SetPoint("BOTTOMLEFT", a, "TOPLEFT", 0, 15)
	sr:Show()
	
	
	return a, b, c, cr, n, sr, m
end

function AAV_Gui:createAuraRanges(parent)
	-- BUFF
	local br = CreateFrame("Frame", "$parentBuffRange", parent)
	br:SetFrameStrata("HIGH")
	br:SetWidth(parent:GetWidth())
	br:SetHeight(AAV_USEDSKILL_ICONBUFFSIZE)
	br:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -2)
	br:Show()
	
	-- DEBUFF
	local dr = CreateFrame("Frame", "$parentDebuffRange", parent)
	dr:SetFrameStrata("HIGH")
	dr:SetWidth(parent:GetWidth())
	dr:SetHeight(AAV_USEDSKILL_ICONBUFFSIZE)
	dr:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -(AAV_USEDSKILL_ICONBUFFSIZE+2))
	dr:Show()
	
	return br, dr
end

function AAV_Gui:createCooldown(parent)
	
	local f = CreateFrame("Frame", "$parentCooldown", parent)
	f:SetWidth(40)
	f:SetHeight(15)
	f:SetAlpha(1)
	f:Show()
	
	-- ICON
	local ic = CreateFrame("Frame", "$parentCooldownText", f)
	ic:SetWidth(AAV_CC_ICONSIZE)
	ic:SetHeight(AAV_CC_ICONSIZE)
	ic:SetPoint("LEFT", f, 0, 0)
	ic:Show()
	
	-- TEXT
	local n = ic:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	n:SetFont("Fonts\\FRIZQT___CYR.TTF", 10, "OUTLINE")
	n:SetText("?")
	n:SetPoint("LEFT", f, AAV_CC_ICONSIZE + 2, 0)
	n:Show()
	
	-- TEXTURE
	local t = ic:CreateTexture(nil)
	t:SetAllPoints(ic)
	--t:SetTexture(0.0, 0.0, 0.0)
	t:Show()
	ic.texture = t
	
	
	return f, ic, n
	
end

function AAV_Gui:createCooldownRanges(parent, team)
	local cb = CreateFrame("Frame", "$parentCDBar", parent)
	cb:SetFrameStrata("HIGH")
	cb:SetWidth(45)
	cb:SetHeight(100)
	if (team == 1) then cb:SetPoint("BOTTOMRIGHT", parent, "TOPLEFT", 0, -32 + AAV_CC_ICONSIZE) end
	if (team == 2) then cb:SetPoint("BOTTOMLEFT", parent, "TOPRIGHT", 0, -32 + AAV_CC_ICONSIZE) end
	cb:Show()
	
	return cb
end

function AAV_Gui:createBarHealthText(parent)
	local a = parent:CreateFontString("$parentHPText","ARTWORK","GameFontNormal")
	a:SetFont("Fonts\\FRIZQT___CYR.TTF", 10)
	a:SetText("100%")
	a:SetPoint("CENTER", parent:GetName(), 0, 1)
	a:Show()
	
	return a
end

function AAV_Gui:createSeekerBar(parent, elapsed)
	
	local f = CreateFrame("Frame", "$parentSeekerBarBack", parent)
	--f:SetFrameStrata("LOW")
	f:SetWidth(500)
	f:SetHeight(12)
	
	local t = f:CreateTexture(nil)
	--t:SetTexture(0.0, 0.0, 0.0)
	t:SetTexture("Interface\\Addons\\aav\\res\\Smooth.tga")
	t:SetVertexColor(0.4313, 0.4313, 0.4313)
	t:SetAllPoints(f)
	f.texture = t
	
	--c:SetAllPoints(parent)
	f:SetPoint("BOTTOMLEFT", parent, 25, 50)
	f:Show()
	
	
	
	local a = CreateFrame("STATUSBAR", "$parentSeekerBar", f)
	--a:SetFrameStrata("MEDIUM")
	a:SetWidth(f:GetWidth())
	a:SetHeight(f:GetHeight())
	a:SetStatusBarTexture("Interface\\Addons\\aav\\res\\Smooth.tga")
	a:SetStatusBarColor(1, 1, 1)
	a:SetMinMaxValues(0, elapsed)
	a:SetValue(0)
	a:SetPoint("BOTTOMLEFT", parent, 25, 50)
	--a:SetPoint("TOPLEFT", speedframe, 0, 0)
	a:Show()
	
	local left = CreateFrame("FRAME", nil, a)
	left:SetHeight(12)
	left:SetWidth(12)
	left:SetPoint("BOTTOMLEFT", a, -5, 0)
	left:Show()
	
	local t = left:CreateTexture(nil)
	t:SetTexture("Interface\\Addons\\aav\\res\\playerleft.tga")
	t:SetAllPoints(left)
	left.texture = t
	
	
	local speedval = parent:CreateFontString("$parentSpeedTitle", "ARTWORK", "GameFontNormal")
	speedval:SetFont("Fonts\\FRIZQT___CYR.TTF", 16, "OUTLINE")
	speedval:SetJustifyH("LEFT")
	speedval:SetPoint("BOTTOMLEFT", parent, 15, 20)
	speedval:Show()
	
	local slider = CreateFrame("SLIDER", "$parentSpeed", parent, "OptionsSliderTemplate")
	slider:SetHeight(15)
	slider:SetWidth(100)
	slider:SetMinMaxValues(0, 300)
	slider:SetValue(100)
	slider:SetValueStep(10)
	getglobal(slider:GetName() .. 'Low'):SetText("");
	getglobal(slider:GetName() .. 'High'):SetText("");
	--getglobal(slider:GetName() .. 'Text'):SetText('Speed');
	slider:SetPoint("LEFT", speedval, "RIGHT", 5, -2)
	slider:Show()
	
	local speed = parent:CreateFontString("$parentSpeedValue", "ARTWORK", "GameFontNormal")
	speed:SetText("100%")
	speed:SetJustifyH("LEFT")
	speed:SetPoint("LEFT", slider, "RIGHT", 5, 0)
	speed:Show()
	
	slider:SetScript("OnValueChanged", function(s)
		speed:SetText(string.format("%.2f",s:GetValue()) .. "%")
		if (s:GetValue()>0) then 
			_atroxArenaViewerData.current.interval = s:GetValue() / 1000
		else
			_atroxArenaViewerData.current.interval = 0
		end
	end)
	
	
	--[[
	parent:SetScript("OnMouseWheel", function(arg)
		local min, max = slider:GetMinMaxValues()
		if (arg == 1 and slider:GetValue() < max) then slider:SetValue(slider:GetValueStep()) end
		if (arg == -1 and slider:GetValue() > min) then slider:SetValue(slider:GetValueStep()) end
	end)
	--]]
	
	return a, f, slider, speedval, speed
end

function AAV_Gui:createStatsFrame(parent)
	
	--print("createStatsFrame")
	local stats = CreateFrame("Frame", "$parentStats", parent)
	stats:SetHeight(parent:GetHeight())
	stats:SetWidth(parent:GetWidth())
	stats:SetPoint("TOPLEFT", 0, -10)
	
	local ddone = stats:CreateFontString("$parentDamageDone", "ARTWORK", "GameFontNormal")
	ddone:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	ddone:SetJustifyH("CENTER")
	ddone:SetPoint("TOPLEFT", stats, 200, -20)
	ddone:SetText(L.DETAIL_DAMAGEDONE)
	--ddone:SetTextColor()
	ddone:Show()
	
	local hdmg = stats:CreateFontString("$parentDamageDone", "ARTWORK", "GameFontNormal")
	hdmg:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	hdmg:SetJustifyH("CENTER")
	hdmg:SetPoint("TOPLEFT", ddone, 80, 0)
	hdmg:SetText(L.DETAIL_HIGHDAMAGE)
	--hdmg:SetTextColor()
	hdmg:Show()
	
	local hdone = stats:CreateFontString("$parentDamageDone", "ARTWORK", "GameFontNormal")
	hdone:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	hdone:SetJustifyH("CENTER")
	hdone:SetPoint("TOPLEFT", hdmg, 115, 0) 
	hdone:SetText(L.DETAIL_HEALDONE)
	--hdone:SetTextColor()
	hdone:Show()
	
	local rating = stats:CreateFontString("$parentDamageDone", "ARTWORK", "GameFontNormal")
	rating:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	rating:SetJustifyH("CENTER")
	rating:SetPoint("TOPLEFT", hdone, 70, -12)
	rating:SetText(L.DETAIL_RATING)
	--rating:SetTextColor()
	rating:Show()
	
	local mmr = stats:CreateFontString("$parentDamageDone", "ARTWORK", "GameFontNormal")
	mmr:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	mmr:SetJustifyH("CENTER")
	mmr:SetPoint("TOPLEFT", rating, 80, 0)
	mmr:SetText(L.DETAIL_MMR)
	--mmr:SetTextColor()
	mmr:Show()
	
	return stats
end

function AAV_Gui:createDetailTeam(parent, num, bracket)
	
	local team = parent:CreateFontString("$parentDamageDone", "ARTWORK", "GameFontNormal")
	team:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	team:SetJustifyH("LEFT")
	team:SetPoint("TOPLEFT", rating, 0, 0)
	--mmr:SetTextColor()
	team:Show()
	
end

function AAV_Gui:createButtonDetail(parent)
	--print("createButtonDetail")
	local detail = CreateFrame("BUTTON", "$parentViewDetail", parent, "UIPanelButtonTemplate")
	detail:SetPoint("BOTTOMRIGHT", -10, 15)
	detail:SetWidth(120)
	detail:SetHeight(25)
	detail:Show()
	
	return detail
end

function AAV_Gui:createButtonSpeed0(parent)
	local button = CreateFrame("BUTTON", "$parentViewSpeed0", parent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", -355, 15)
	button:SetWidth(25)
	button:SetHeight(25)
	button:Show()
	
	return button
end

function AAV_Gui:createButtonSpeed02(parent)
	local button = CreateFrame("BUTTON", "$parentViewSpeed02", parent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", -330, 15)
	button:SetWidth(25)
	button:SetHeight(25)
	button:Show()
	return button
end

function AAV_Gui:createButtonSpeed05(parent)
	local button = CreateFrame("BUTTON", "$parentViewSpeed05", parent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", -305, 15)
	button:SetWidth(25)
	button:SetHeight(25)
	button:Show()
	
	return button
end

function AAV_Gui:createButtonSpeed1(parent)
	local button = CreateFrame("BUTTON", "$parentViewSpeed1", parent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", -280, 15)
	button:SetWidth(25)
	button:SetHeight(25)
	button:Show()
	
	return button
end

function AAV_Gui:createButtonSpeed2(parent)
	local button = CreateFrame("BUTTON", "$parentViewSpeed2", parent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", -255, 15)
	button:SetWidth(25)
	button:SetHeight(25)
	button:Show()
	
	return button
end

function AAV_Gui:createButtonSpeed3(parent)
	local button = CreateFrame("BUTTON", "$parentViewSpeed3", parent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", -230, 15)
	button:SetWidth(25)
	button:SetHeight(25)
	button:Show()
	
	return button
end

function AAV_Gui:createTeamHead(parent, posY, team)

	-- if AAV_DEBUG_MODE then
	-- 	print("AAV_GUI:createTeamHead")
	-- end
	
	local head = parent:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	head:SetFont("Fonts\\FRIZQT___CYR.TTF", 20, "OUTLINE")
	head:SetJustifyH("LEFT")
	head:SetPoint("TOPLEFT", parent, 20, -25 - posY - (team * 55) + 15)
	head:SetTextColor(1, 1, 1)
	
	return head
end

function AAV_Gui:createDetailEntry(parent, posY, i, team)
	local entry = CreateFrame("Frame", "$parentEntry", parent)
	entry:SetHeight(AAV_DETAIL_ENTRYHEIGHT)
	entry:SetWidth(AAV_DETAIL_ENTRYWIDTH)
	entry:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -35 - posY - (team * 55) - (35 * i))
	
	local icon = CreateFrame("Frame", "$parentIcon", entry)
	icon:SetWidth(20)
	icon:SetHeight(20)
	
	local t = icon:CreateTexture(nil)
	--t:SetTexture()
	t:SetAllPoints(icon)
	icon.texture = t
	icon:SetPoint("TOPLEFT", entry, 20, -5)
	icon:Show()
	
	
	local name = parent:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	name:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	name:SetJustifyH("LEFT")
	name:SetParent(entry)
	name:SetPoint("BOTTOMLEFT", entry, 50, 0)
	name:SetTextColor(1, 1, 1)
	
	local dd = parent:CreateFontString("$parentDamage", "ARTWORK", "GameFontNormal")
	dd:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	dd:SetJustifyH("LEFT")
	dd:SetParent(entry)
	dd:SetPoint("BOTTOMLEFT", entry, 200, 0)
	dd:SetTextColor(1, 1, 1)
	
	local hd = parent:CreateFontString("$parentHighest", "ARTWORK", "GameFontNormal")
	hd:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	hd:SetJustifyH("LEFT")
	hd:SetParent(entry)
	hd:SetPoint("BOTTOMLEFT", dd, 80, 0)
	hd:SetTextColor(1, 1, 1)
	
	local h = parent:CreateFontString("$parentHeal", "ARTWORK", "GameFontNormal")
	h:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	h:SetJustifyH("LEFT")
	h:SetParent(entry)
	h:SetPoint("BOTTOMLEFT", hd, 115, 0)
	h:SetTextColor(1, 1, 1)
	
	local rc = parent:CreateFontString("$parentRating", "ARTWORK", "GameFontNormal")
	rc:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	rc:SetJustifyH("LEFT")
	rc:SetParent(entry)
	rc:SetPoint("BOTTOMLEFT", h, 70, 0)
	rc:SetTextColor(1, 1, 1)
	
	local mmr = parent:CreateFontString("$parentMMR", "ARTWORK", "GameFontNormal")
	mmr:SetFont("Fonts\\FRIZQT___CYR.TTF", 12, "OUTLINE")
	mmr:SetJustifyH("LEFT")
	mmr:SetParent(entry)
	mmr:SetPoint("BOTTOMLEFT", rc, 80, 0)
	mmr:SetTextColor(1, 1, 1)
	
	return entry, icon, name, dd, hd, h, rc, mmr
end

function AAV_Gui:createStatusText(parent)
	local status = parent:CreateFontString("$parentStatus", "ARTWORK", "GameFontNormal")
	status:SetFont("Fonts\\FRIZQT___CYR.TTF", 16, "OUTLINE")
	status:SetJustifyH("LEFT")
	status:SetPoint("BOTTOMLEFT", parent, 15, 20)
	status:Hide()
	
	return status
end

function AAV_Gui:createSeekerText(parent)
	local b = parent:CreateFontString("$parentTick", "ARTWORK", "GameFontNormal")
	b:SetFont("Fonts\\FRIZQT___CYR.TTF", 16, "OUTLINE")
	b:SetText("00:00.0")
	b:SetJustifyH("LEFT")
	b:SetPoint("LEFT", parent:GetName(), parent:GetWidth() + 15, 0)
	b:Show()
	
	return b
end

----
-- Sets the GameTooltip with provided message
-- @param msg message string for the tooltip
-- @param color colorize the message
function AAV_Gui:SetGameTooltip(msg, color, parent)
	GameTooltip:SetOwner(parent, "ANCHOR_CURSOR", 200, 250)
	GameTooltip:SetText(msg)
	
end

----
-- @param parent
function AAV_Gui:createCombatText(parent)
	local f = parent:CreateFontString("$parentHPText","ARTWORK","GameFontNormal")
	f:Show()
	
	return f
end

----
-- @param parent
-- @param i for unique ussage in name
function AAV_Gui:createUsedSkill(parent, i)
	
	local f = CreateFrame("Frame", "$parentSkill" .. i, parent)
	f:SetWidth(AAV_USEDSKILL_ICONSIZE)
	f:SetHeight(AAV_USEDSKILL_ICONSIZE)
	f:SetAlpha(0)
	f:Show()
	
	-- texture
	local t = f:CreateTexture(nil)
	t:SetAllPoints(f)
	f.texture = t
	
	
	local b = CreateFrame("Frame", "$parentBox", parent)
	--b:SetAllPoints(f)
	b:SetWidth(AAV_USEDSKILL_ICONSIZE-1)
	b:SetHeight(AAV_USEDSKILL_ICONSIZE)
	b:SetFrameLevel(5)
	b:SetAlpha(0)
	b:Show()
	
	-- texture
	local tb = b:CreateTexture(nil)
	tb:SetAllPoints(b)
	b.texture = tb
	
	-- target color
	local tc = CreateFrame("Frame", "$parentColor", f)
	tc:SetPoint("TOP", f, 0, 5)
	tc:SetWidth(23)
	tc:SetHeight(5)
	-- texture
	local ttc = f:CreateTexture(nil)
	ttc:SetAllPoints(tc)
	tc.texture = ttc
	
	
	-- target
	local tar = CreateFrame("Frame", "$parentTarget", f)
	tar:SetPoint("TOP", f, 0, 6)
	tar:SetWidth(f:GetWidth())
	tar:SetHeight(12)
	tar:Hide()
	-- texture
	local tt = f:CreateTexture(nil)
	tt:SetAllPoints(tar)
	tt:SetTexCoord(0, 1, 0, 0.5);
	tt:SetTexture("Interface\\Addons\\aav\\res\\TARGETBG.tga")
	tar.texture = tt
	--tar:SetFrameStrata("HIGH")
	
	
	
	
	return f, b, tar, tc
end

function AAV_Gui:createAura(parent, stacks)
	local f = CreateFrame("Frame", "$parentAura", parent)
	f:SetWidth(AAV_USEDSKILL_ICONBUFFSIZE)
	f:SetHeight(AAV_USEDSKILL_ICONBUFFSIZE)
	f:Show()
	
	-- texture
	local t = f:CreateTexture(nil)
	t:SetAllPoints(f)
	f.texture = t

	-- stacks
	
	local n = f:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	
	n:SetFont("Fonts\\FRIZQT___CYR.TTF", 9, "OUTLINE")
	n:SetJustifyH("LEFT")
	if stacks and stacks > 0 then
		n:SetText(stacks)
	else
		n:SetText()
	end
	n:SetPoint("BOTTOMLEFT", f, 3, 0)
	n:Show()
	
	return f, n
	
end

----
-- puts an X on the parent bar to indicate, that it's been interrupted.
-- @param parent skillused object, where the X is being put on
-- @param x the frame with the texture
function AAV_Gui:setInterruptOnBar(parent, x)
	x:SetParent(parent)
	x:SetAllPoints(parent)
end

----
-- creates an interrupt frame to indicate, that a skill's been interrupted.
-- @param parent a skillused object
-- @return frame 
function AAV_Gui:createInterruptFrame(parent)	
	local f = CreateFrame("Frame", "$parentX", parent)
	f:SetFrameStrata("HIGH")
	f:SetWidth(AAV_USEDSKILL_ICONSIZE)
	f:SetHeight(AAV_USEDSKILL_ICONSIZE)
	f:SetAllPoints(parent)
	f:Show()
	
	local t = f:CreateTexture(nil)
	t:SetTexture("Interface\\Addons\\aav\\res\\X.tga")
	f.texture = t
	t:SetAllPoints(f)
	t:Show()

	return f
end

function AAV_Gui:createMinimapIcon(parent, player)
	
	local button = CreateFrame("Button", nil, Minimap)
	button:SetFrameStrata("HIGH")
	button:SetWidth(31)
	button:SetHeight(31)
	button:RegisterForClicks("AnyUp")
	button:RegisterForDrag("RightButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	
	local x,y
	if (_atroxArenaViewerData.defaults.profile.minimapx and _atroxArenaViewerData.defaults.profile.minimapy) then
		x, y = _atroxArenaViewerData.defaults.profile.minimapx, _atroxArenaViewerData.defaults.profile.minimapy
	else
		x, y = -54.6, 58.8
	end
	button:SetPoint("CENTER", x, y)
	
	button:Show()

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")

	local icon = button:CreateTexture(nil, 'BACKGROUND')
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\Icons\\Spell_Magic_MageArmor")
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetPoint("TOPLEFT", 7, -5)

	local minimapShapes = {
		["ROUND"] = {true, true, true, true},
		["SQUARE"] = {false, false, false, false},
		["CORNER-TOPLEFT"] = {true, false, false, false},
		["CORNER-TOPRIGHT"] = {false, false, true, false},
		["CORNER-BOTTOMLEFT"] = {false, true, false, false},
		["CORNER-BOTTOMRIGHT"] = {false, false, false, true},
		["SIDE-LEFT"] = {true, true, false, false},
		["SIDE-RIGHT"] = {false, false, true, true},
		["SIDE-TOP"] = {true, false, true, false},
		["SIDE-BOTTOM"] = {false, true, false, true},
		["TRICORNER-TOPLEFT"] = {true, true, true, false},
		["TRICORNER-TOPRIGHT"] = {true, false, true, true},
		["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
		["TRICORNER-BOTTOMRIGHT"] = {false, true, true, true},
	}
	
	button:SetScript("OnDragStart", function(self, btn)
		self.dragging = true
		self:LockHighlight()
		icon:SetTexCoord(0, 1, 0, 1)
		self:SetScript('OnUpdate', function(self, btn)
			local mx, my = Minimap:GetCenter()
			local px, py = GetCursorPosition()
			local scale = Minimap:GetEffectiveScale()
			px, py = px / scale, py / scale
			local deg = math.deg(math.atan2(py - my, px - mx)) % 360
			
			local angle = math.rad(deg)
			local x, y, q = math.cos(angle), math.sin(angle), 1
			if x < 0 then q = q + 1 end
			if y > 0 then q = q + 2 end
			local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
			local quadTable = minimapShapes[minimapShape]
			if quadTable[q] then
				x, y = x*80, y*80
			else
				local diagRadius = 103.13708498985 
				x = math.max(-80, math.min(x*diagRadius, 80))
				y = math.max(-80, math.min(y*diagRadius, 80))
			end
			self:SetPoint("CENTER", self:GetParent(), "CENTER", x, y)
			_atroxArenaViewerData.defaults.profile.minimapx = x
			_atroxArenaViewerData.defaults.profile.minimapy = y
		end)
		GameTooltip:Hide()
	end)
	
	button:SetScript("OnDragStop", function(self, btn)
		self.dragging = nil
		self:SetScript('OnUpdate', nil)
		icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		self:UnlockHighlight()
	end)
	
	
	
	button:SetScript("OnEnter", function(self)
		if not self.dragging then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetText("atrox Arena Viewer")
			GameTooltip:AddLine("|cffe392c5Right-click|r to drag icon")
			GameTooltip:AddLine("|cffe392c5Left-click|r to open AAV")
			GameTooltip:Show()
		end
	end)
	
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	local reset = function(tab) for k,v in pairs(tab) do tab[k] = nil end end
	
	-- MENU
	local menu = CreateFrame("Frame", "AAVMinimapMenu", UIParent, "UIDropDownMenuTemplate")
	local info = {}
	UIDropDownMenu_Initialize(menu, function(self, level)
		level = level or 1
		info.disabled	= false
		
		if (level == 1) then
			-- ENABLE RECORDING
			reset(info)
			info.text       = "Enable recording"
			info.notCheckable = false
			info.notClickable = false
			info.hasArrow	= false
			info.checked	= _atroxArenaViewerData.current.record
			info.func       = function() parent:changeRecording() end
			
			UIDropDownMenu_AddButton(info, level)

			-- ENABLE BROADCASTING
			reset(info)
			info.text       = "Enable broadcasting"
			info.notCheckable = false
			info.notClickable = false
			info.hasArrow	= false
			info.checked	= _atroxArenaViewerData.current.broadcast
			info.func       = function() parent:changeBroadcast() end
			UIDropDownMenu_AddButton(info, level)
			info.checked	= nil
			
			-- PLAY MATCH
			reset(info)
			info.text       = "Play match"
			info.notCheckable = true
			info.notClickable = false
			info.hasArrow	= true
			info.func		= nil
			
			UIDropDownMenu_AddButton(info, level)
			
			
			-- CONNECT
			reset(info)
			info.text       = "Connect"
			info.notCheckable = true
			info.notClickable = false
			info.hasArrow	= true
			info.func		= nil
			UIDropDownMenu_AddButton(info, level)
			
			-- OPTIONS
			reset(info)
			info.text       = "Options"
			info.notCheckable = true
			info.notClickable = false
			info.hasArrow	= true
			info.func       = nil
			
			UIDropDownMenu_AddButton(info, level)
			
			-- DELETE
			reset(info)
			info.text       = "Delete"
			info.notCheckable = true
			info.notClickable = false
			info.hasArrow	= true
			info.func		= nil
			UIDropDownMenu_AddButton(info, level)
			

			-- EXPORT MATCH
			reset(info)
			info.text       = "Export match"
			info.notCheckable = true
			info.notClickable = false
			info.hasArrow	= true
			info.func       = nil
			
			UIDropDownMenu_AddButton(info, level)
		end
		
		if (level == 2) then
			
			if (UIDROPDOWNMENU_MENU_VALUE == "Play match") then
				-- PLAY MATCH
				
				--[[
				if (_atroxArenaViewerMatchData) then
					
					for i=1, math.ceil(#_atroxArenaViewerMatchData / 20) do
						reset(info)
						info.text = "Play Match " .. ((i-1) * 20)+1 .. "-" .. (i * 20)
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = true
						info.func = nil
						
						UIDropDownMenu_AddButton(info, level)
					end
					
				else
					reset(info)
					info.text = "none found"
					info.notCheckable = true
					info.notClickable = true
					info.hasArrow = false
					info.func = nil
					
					UIDropDownMenu_AddButton(info, level)
				end
				--]]
				
				if (_atroxArenaViewerMatchData) then
					for k,v in pairs(_atroxArenaViewerMatchData) do
						info.text = k .. " - " .. v.map .. " (" .. v.startTime .. ")"
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = false
						info.func = function() parent:createPlayer(k) parent:playMatch(k) end
						
						UIDropDownMenu_AddButton(info, level)
					end
				else
					info.text = "none found"
					info.notCheckable = true
					info.notClickable = true
					info.hasArrow = false
					info.func = nil
					
					UIDropDownMenu_AddButton(info, level)
				end
				
			end
				
				
			if (UIDROPDOWNMENU_MENU_VALUE == "Delete") then
				--DELETE
				--[[
				reset(info)
				info.text = "Delete All"
				info.notCheckable = true
				info.notClickable = false
				info.hasArrow = false
				info.func = function()
					while(#_atroxArenaViewerMatchData>0) do
						atroxArenaViewer:deleteMatch(#_atroxArenaViewerMatchData)					
					end
					AAV_TableGui:refreshMatchesFrame()
				end
				
				UIDropDownMenu_AddButton(info, level)
				--]]	
			
				if (_atroxArenaViewerMatchData) then
					for k,v in pairs(_atroxArenaViewerMatchData) do
						reset(info)
						info.text = k .. " - " .. v.map .. " (" .. v.startTime .. ")"
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = false
						info.func = function() parent:deleteMatch(k) end
						
						UIDropDownMenu_AddButton(info, level)
					end
					
					reset(info)
					info.text = "delete all"
					info.notCheckable = true
					info.notClickable = false
					info.hasArrow = false
					info.func = function() for i=1,#_atroxArenaViewerMatchData do parent:deleteMatch(1) end end
					
					UIDropDownMenu_AddButton(info, level)
					
				else
					reset(info)
					info.text = "none found"
					info.notCheckable = true
					info.notClickable = true
					info.hasArrow = false
					info.func = nil
					
					UIDropDownMenu_AddButton(info, level)
				end
				
			elseif (UIDROPDOWNMENU_MENU_VALUE == "Connect") then
				-- CONNECT
				local tmp = 0
				for k,v in pairs(parent:getBroadcasters()) do tmp = 1 break end
				if (tmp > 0) then
					for k,v in pairs(parent:getBroadcasters()) do
						reset(info)
						info.text = k .. " (v" .. v.version ..")"
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = false
						info.func = function() parent:connectToBroadcast(k) end
						
						UIDropDownMenu_AddButton(info, level)
						
					end
				else
					reset(info)
					info.text = "none found"
					info.notCheckable = true
					info.notClickable = true
					info.disabled = true
					info.hasArrow = false
					info.func = nil
					info.notClickable = true
					
					UIDropDownMenu_AddButton(info, level)
					info.notClickable = false
					
				end
				
			elseif (UIDROPDOWNMENU_MENU_VALUE == "Options") then
				reset(info)
				info.text = "Broadcast announcements"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.broadcastannounce
				info.func = function() _atroxArenaViewerData.defaults.profile.broadcastannounce = not _atroxArenaViewerData.defaults.profile.broadcastannounce end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Detect player specs"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.detectspec
				info.func = function() _atroxArenaViewerData.defaults.profile.detectspec = not _atroxArenaViewerData.defaults.profile.detectspec end
				
				UIDropDownMenu_AddButton(info, level)

				reset(info)
				info.notCheckable = true
				info.notClickable = true
				info.text = ""
				
				UIDropDownMenu_AddButton(info, level)

				reset(info)
				info.text = "GUI settings"
				info.notCheckable = true
				info.notClickable = true
				info.hasArrow = false
				info.func = nil
				info.r = 0.8901960784313725
				info.g = 0.5725490196078431
				info.b = 0.7725490196078431

				UIDropDownMenu_AddButton(info, level)

				reset(info)
				info.text = "Show detected specs"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.showdetectedspec
				info.func = function() _atroxArenaViewerData.defaults.profile.showdetectedspec = not _atroxArenaViewerData.defaults.profile.showdetectedspec end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Show tooltip with names"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.shownamestooltip
				info.func = function() _atroxArenaViewerData.defaults.profile.shownamestooltip = not _atroxArenaViewerData.defaults.profile.shownamestooltip end
				
				UIDropDownMenu_AddButton(info, level)

				reset(info)
				info.text = "Show player's realm in tooltip"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.showplayerrealm
				info.func = function() _atroxArenaViewerData.defaults.profile.showplayerrealm = not _atroxArenaViewerData.defaults.profile.showplayerrealm end
				
				UIDropDownMenu_AddButton(info, level)

				reset(info)
				info.notCheckable = true
				info.notClickable = true
				info.text = ""
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Buffs and Debuffs"
				info.notCheckable = true
				info.notClickable = true
				info.hasArrow = false
				info.func = nil
				info.r = 0.8901960784313725
				info.g = 0.5725490196078431
				info.b = 0.7725490196078431
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Don't Exceed Buffs and Debuffs"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.shortauras
				info.func = function() _atroxArenaViewerData.defaults.profile.shortauras = not _atroxArenaViewerData.defaults.profile.shortauras end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.notCheckable = true
				info.notClickable = true
				info.text = ""
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Health Bar Color"
				info.notCheckable = true
				info.notClickable = true
				info.hasArrow = false
				info.func = nil
				info.r = 0.8901960784313725
				info.g = 0.5725490196078431
				info.b = 0.7725490196078431
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Use Unique Color"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.uniquecolor
				info.func = function() _atroxArenaViewerData.defaults.profile.uniquecolor = not _atroxArenaViewerData.defaults.profile.uniquecolor end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.notCheckable = true
				info.notClickable = true
				info.text = ""
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Health Bar Text"
				info.notCheckable = true
				info.notClickable = true
				info.hasArrow = false
				info.func = nil
				info.r = 0.8901960784313725
				info.g = 0.5725490196078431
				info.b = 0.7725490196078431
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Percentage Health Value (100%)"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.healthdisplay == 1
				info.func = function() 
					_atroxArenaViewerData.defaults.profile.healthdisplay = 1 
					if (atroxArenaViewer:getPlayer()) then atroxArenaViewer:getPlayer():updateHealthtext() end 
				end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Absolute Health Value (20000)"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.healthdisplay == 2
				info.func = function() 
					_atroxArenaViewerData.defaults.profile.healthdisplay = 2 
					if (atroxArenaViewer:getPlayer()) then atroxArenaViewer:getPlayer():updateHealthtext() end 
				end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Deficit Health Value (-530/20000)"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.defaults.profile.healthdisplay == 3
				info.func = function() 
					_atroxArenaViewerData.defaults.profile.healthdisplay = 3 
					if (atroxArenaViewer:getPlayer()) then atroxArenaViewer:getPlayer():updateHealthtext() end 
				end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.notCheckable = true
				info.notClickable = true
				info.text = ""
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Communication Method"
				info.notCheckable = true
				info.notClickable = true
				info.hasArrow = false
				info.func = nil
				info.r = 0.8901960784313725
				info.g = 0.5725490196078431
				info.b = 0.7725490196078431
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Guild"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.current.communication == "GUILD"
				info.func = function()
					_atroxArenaViewerData.current.communication = "GUILD"
				end
				
				UIDropDownMenu_AddButton(info, level)
				
				reset(info)
				info.text = "Raid"
				info.notCheckable = false
				info.notClickable = false
				info.hasArrow = false
				info.checked = _atroxArenaViewerData.current.communication == "RAID"
				info.func = function() 
					_atroxArenaViewerData.current.communication = "RAID"
				end
				
				UIDropDownMenu_AddButton(info, level)
				
			elseif (UIDROPDOWNMENU_MENU_VALUE == "Export match") then
				-- PLAY MATCH
				--[[
				if (_atroxArenaViewerMatchData) then
					
					for i=1, math.ceil(#_atroxArenaViewerMatchData / 20) do
						reset(info)
						info.text = "Export Match " .. ((i-1) * 20)+1 .. "-" .. (i * 20)
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = true
						info.func = nil
						
						UIDropDownMenu_AddButton(info, level)
					end
					
				else
					reset(info)
					info.text = "none found"
					info.notCheckable = true
					info.notClickable = true
					info.hasArrow = false
					info.func = nil
					
					UIDropDownMenu_AddButton(info, level)
				end
				--]]
				
				if (_atroxArenaViewerMatchData) then
					for k,v in pairs(_atroxArenaViewerMatchData) do
						reset(info)
						info.text = k .. " - " .. v.map .. " (" .. v.startTime .. ")"
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = false
						info.func = function() parent:exportMatch(k) StaticPopup_Show("AAV_EXPORT_DIALOG") end
						
						UIDropDownMenu_AddButton(info, level)
					end
				else
					reset(info)
					info.text = "none found"
					info.notCheckable = true
					info.notClickable = true
					info.hasArrow = false
					info.func = nil
					
					UIDropDownMenu_AddButton(info, level)
				end
				
			end
		end
		
		if (level == 3) then
			
			for i=1, math.ceil(#_atroxArenaViewerMatchData / 20) do
				
--[[				if (UIDROPDOWNMENU_MENU_VALUE == "Play Match " .. ((i-1) * 20)+1 .. "-" .. (i * 20)) then
					
					if (_atroxArenaViewerMatchData) then
						for j=((i-1)*20)+1, (i*20) do
							if (not _atroxArenaViewerMatchData[j]) then break end
							reset(info)
							local mapname = ""
							if (type(_atroxArenaViewerMatchData[j]["map"])=="number") then
								if (AAV_COMM_MAPS[_atroxArenaViewerMatchData[j]["map"]]--) then
--[[									mapname = AAV_COMM_MAPS[_atroxArenaViewerMatchData[j]["map"]]
--[[								else
									mapname = "Unknown"
								end
							else
								mapname = _atroxArenaViewerMatchData[j]["map"]
							end
							if (mapname == nil) then print(_atroxArenaViewerMatchData[j]["map"]) end
							info.text = j .. " - " .. mapname .. " (" .. _atroxArenaViewerMatchData[j]["startTime"] .. ")"
							info.notCheckable = true
							info.notClickable = false
							info.hasArrow = false
							info.func = function() parent:createPlayer(j) parent:playMatch(j) end
							
							UIDropDownMenu_AddButton(info, level)
						end
					else
						reset(info)
						info.text = "none found"
						info.notCheckable = true
						info.notClickable = true
						info.hasArrow = false
						info.func = nil
						
						UIDropDownMenu_AddButton(info, level)
					end
				end
				
				if (UIDROPDOWNMENU_MENU_VALUE == "Delete Match " .. ((i-1) * 20)+1 .. "-" .. (i * 20)) then
					
					if (_atroxArenaViewerMatchData) then
						for j=((i-1)*20)+1, (i*20) do
							if (not _atroxArenaViewerMatchData[j]) then break end
							reset(info)
							local mapname = ""
							if (type(_atroxArenaViewerMatchData[j]["map"])=="number") then
								if (AAV_COMM_MAPS[_atroxArenaViewerMatchData[j]["map"]]--) then
--[[									mapname = AAV_COMM_MAPS[_atroxArenaViewerMatchData[j]["map"]]
--[[								else
									mapname = "Unknown"
								end
							else
								mapname = _atroxArenaViewerMatchData[j]["map"]
							end
							info.text = j .. " - " .. mapname .. " (" .. _atroxArenaViewerMatchData[j]["startTime"] .. ")"
							info.notCheckable = true
							info.notClickable = false
							info.hasArrow = false
							info.func = function() parent:deleteMatch(j) end
							
							UIDropDownMenu_AddButton(info, level)
						end
						
						reset(info)
						info.text = "delete all " .. ((i-1) * 20)+1 .. "-" .. (i * 20)
						info.notCheckable = true
						info.notClickable = false
						info.hasArrow = false
						info.func = function() for k=((i-1)*20)+1,((i-1)*20)+20 do parent:deleteMatch(k) end end
						
						UIDropDownMenu_AddButton(info, level)
					else
						reset(info)
						info.text = "none found"
						info.notCheckable = true
						info.notClickable = true
						info.hasArrow = false
						info.func = nil
						
						UIDropDownMenu_AddButton(info, level)
					end
					
				end]]--
				
				if (UIDROPDOWNMENU_MENU_VALUE == "Export Match " .. ((i-1) * 20)+1 .. "-" .. (i * 20)) then
					
					if (_atroxArenaViewerMatchData) then
						for j=((i-1)*20)+1, (i*20) do
							if (not _atroxArenaViewerMatchData[j]) then break end
							reset(info);
							info.text = j .. " - " .. _atroxArenaViewerMatchData[j]["map"] .. " (" .. _atroxArenaViewerMatchData[j]["startTime"] .. ")"
							info.notCheckable = true
							info.notClickable = false
							info.hasArrow = false
							info.func = function() parent:exportMatch(j) StaticPopup_Show("AAV_EXPORT_DIALOG") end
							
							UIDropDownMenu_AddButton(info, level)
						end
					else
						reset(info)
						info.text = "none found"
						info.notCheckable = true
						info.notClickable = true
						info.hasArrow = false
						info.func = nil
						
						UIDropDownMenu_AddButton(info, level)
					end
					
				end
			end
			
			
		end
		
	end, "MENU")
	
    --ToggleDropDownMenu(1, nil, TomTomPingMenu, "cursor", 0, 0);
	
	button:SetScript("OnClick", function(button, clickType)
		if(clickType == "LeftButton") then
			--print(AAV_TableGui:isMatchesFrameShowing())
			if(AAV_TableGui:isMatchesFrameShowing()) then
				AAV_TableGui:hideMatchesFrame()
			else
				AAV_TableGui:showMatchesFrame()
			end
		elseif (clickType == "RightButton") then
			ToggleDropDownMenu(1, nil, menu, button, 10, 10);
		end
	end)
	
	return button
end


function AAV_Gui:createCC(parent, id)
	
	-- FRAME
	local f = CreateFrame("FRAME", "$parentCC" .. id, parent)
	f:SetSize(30, 30)
	
	-- TEXTURE
	local t = f:CreateTexture(nil)
	f.texture = t
	t:SetAllPoints(f)
	t:Show()
	
	-- TIMER
	local n = f:CreateFontString("$parentName", "ARTWORK", "GameFontNormal")
	n:SetFont("Fonts\\FRIZQT___CYR.TTF", 10, "OUTLINE")
	n:SetJustifyH("LEFT")
	n:SetPoint("BOTTOMLEFT", f, 3, 0)
	n:Show()
	
	return f, n
	
end

function AAV_Gui:ShowTooltip(owner, teamPlayerNames, enemyPlayerNames, lose)
    AceGUI.tooltip:SetOwner(owner, "ANCHOR_TOP")
    AceGUI.tooltip:ClearLines()
    AceGUI.tooltip:AddLine(L["Names"])
    for i, name in ipairs(teamPlayerNames) do
        AceGUI.tooltip:AddLine(name, lose-0, 1-lose, 0)
    end
    AceGUI.tooltip:AddLine('---------------')
    for i, name in ipairs(enemyPlayerNames) do
        AceGUI.tooltip:AddLine(name, 1-lose, lose-0, 0)
    end
    AceGUI.tooltip:Show()
end

function AAV_Gui:HideTooltip() AceGUI.tooltip:Hide() end