
atroxArenaViewer = LibStub("AceAddon-3.0"):NewAddon("atroxArenaViewer", "AceComm-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("atroxArenaViewer", true)
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("LibSerialize")

local M -- AAV_MatchStub
local T -- AAV_PlayStub
local timer -- playback timer
local queuetimer -- queue timer
local newversion = 0 -- prevent version check spam
local queue = {} -- messages at issue
local broadcasters = {} -- all broadcasters
local spectators = {} -- all spectators
local versions = {} -- all aav users
local initbroadcast = false -- whether a lookup has been sent
local currentstate = 1
local exportnum = 0
local currentbracket = nil
local tempbuffs = {} -- used for determining new buffs
local tempdebuffs = {} -- used for determining new debuffs
local exceptauras = { -- these auras won't be tracked
	32727,	-- Arena Preparation
}
local guids = {} -- used to temp save guids of your arenamates ( needed to fix some other shit when someone already left the arena)
----
-- reused for packet sending
local message = {
	["std"] = {}, -- used for standard sending
	["dude"] = {}, -- used for single dude data
	["dudes"] = {}, -- used for multiple dude data
	["stats"] = {}, -- used for end match stats
}


-------------------------
-- GLOBALS
-------------------------
AAV_VERSIONMAJOR = 1
AAV_VERSIONMINOR = 4
AAV_VERSIONBUGFIX = 23
AAV_UPDATESPEED = 60
AAV_AURAFULLINDEXSTEP = 1
AAV_INITOFFTIME = 0.5
AAV_QUEUESENDTIME = 0.1
AAV_MANATRESHOLD = 5
AAV_MINIMUM_COOLDOWN = 5
AAV_AURA_LONGLASTING = 180
AAV_MAX_AURASVISIBLE = 11

AAV_GUI_VERTICALFRAMEDISTANCE = 110
AAV_GUI_MAXCOMBATTEXTOBJECTS = 64
AAV_GUI_COMBATTEXTOBJECTSOFFSET = 0.2
AAV_GUI_MAXUSEDSKILLSOBJECTS = 9
AAV_GUI_HEALTHBARHEIGHT = 16
AAV_GUI_MANABARHEIGHT = 5
AAV_GUI_UPDATEFRAME = CreateFrame("Frame")

AAV_COMBATTEXT_PERSISTENCE = 2.0
AAV_COMBATTEXT_FADETIME = 0.8
AAV_COMBATTEXT_CRITTIME = 0.5 -- UNUSED
AAV_COMBATTEXT_FRAMESPEED = 40
AAV_COMBATTEXT_ALPHASPEED = 3
AAV_COMBATTEXT_CRITSPEED = 30
AAV_COMBATTEXT_SCROLLINGTEXTFONTSIZE = 12
AAV_COMBATTEXT_SCROLLINGTEXTCRITPLUS = 26

AAV_USEDSKILL_PERSISTENCE = 6.0
AAV_USEDSKILL_FRAMESPEED = 60
AAV_USEDSKILL_ICONSPEED = 150
AAV_USEDSKILL_FADEINSPEED = 10
AAV_USEDSKILL_FADEOUTSPEED = 0.5
AAV_USEDSKILL_FADEOUTTIME = 2.0
AAV_USEDSKILL_FADEINTIME = 1
AAV_USEDSKILL_ICONSIZE = 25
AAV_USEDSKILL_ICONMARGIN = 3
AAV_USEDSKILL_ICONBUFFSIZE = 15

AAV_CROWD_FADEOUTTIME = 0.2
AAV_CROWD_FADEOUTSPEED = 10
AAV_CROWD_FADEINTIME = 0.5
AAV_CROWD_FADEINSPEED = 10

AAV_CC_ICONSIZE = 15
AAV_CC_ICONMARGIN = 1
AAV_CC_ICONSPEED = 150
AAV_CC_FADEINTIME = 0.5
AAV_CC_FADEINSPEED = 10
AAV_CC_FADEOUTTIME = 0.25
AAV_CC_FADEOUTSPEED = 10
AAV_CC_MAXLISTING = 5

AAV_DETAIL_ENTRYHEIGHT = 20
AAV_DETAIL_ENTRYWIDTH = 560

AAV_MAX_SAVED_MATCHES_COUNT = 50

AAV_DEBUG_MODE = false

AAV_COMM_LOOKUPBROADCAST = "AAVLookup"
AAV_COMM_HANDLEMATCHDATA = "AAVHandle"

AAV_COMM_EVENT = {
	["cmd_versioncheck"]		= 1,
	["cmd_broadcaststart"]		= 2,
	["cmd_broadcaststop"]		= 3,
	["cmd_status"]				= 4,
	["cmd_connect"]				= 5,
	["cmd_accept"]				= 6,
	["cmd_matchend"]			= 7,
	["cmd_newmatch"]			= 8,
	["cmd_updateplayer"]		= 9,
	["cmd_updateallplayers"]	= 10,
	["cmd_spectatorstop"]		= 11,
}

AAV_COMM_MAPS = {
	[0] = L.ARENA_UNKNOWN,
	[1] = L.ARENA_NAGRAND,
	[2] = L.ARENA_LORDAERON,
	[3] = L.ARENA_BLADEEDGE,
	[4] = L.ARENA_DALARAN,
	[5] = L.ARENA_VALOR,
	[6] = L.ARENA_TOLVIR,
	[7] = L.ASHAMANE,
	[8] = L.BLACK_ROOKHOLD,
	[9] = L.SHADO_PANSHOWDOWN,
	[10]= L.HOOK_POINT,
	[11]= L.MUGAMBALA,
}

StaticPopupDialogs["AAV_EXPORT_DIALOG"] = {
	text = "Copy this export string.",
	button1 = "OK",
	hasEditBox = true,
	OnShow = function (s, d)
		s.editBox:SetText(atroxArenaViewer:getExportString(exportnum))
		s.editBox:HighlightText(0)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

StaticPopupDialogs["AAV_PLAYOLDMATCHES_DIALOG"] = {
	text = L.ERROR_OLDMATCHES,
	button1 = "Ok",
	timeout = 0,
	hideOnEscape = true,
}

function atroxArenaViewer:Archive(data)
	local serialized = LibSerialize:SerializeEx({errorOnUnserializableType = false}, data)
	local compressed = LibDeflate:CompressDeflate(serialized)
	local encoded = LibDeflate:EncodeForPrint(compressed)
	return encoded
end

function atroxArenaViewer:DeArchive(encoded)
	local compressed = LibDeflate:DecodeForPrint(encoded)
	local serialized = LibDeflate:DecompressDeflate(compressed)
	local success, data = LibSerialize:Deserialize(serialized)
	return data
end

function atroxArenaViewer:OnInitialize()

	AAV_DB = AAV_DB or {}
	atroxArenaViewerData = atroxArenaViewerData or nil
	_atroxArenaViewerData = _atroxArenaViewerData or nil

	--convert old db to new variable and drop old data
	if type(atroxArenaViewerData) == 'table' and type(atroxArenaViewerData.data) == 'table' then
		--print('old data found')
		_atroxArenaViewerData = atroxArenaViewerData
		_atroxArenaViewerMatchData = atroxArenaViewerData.data
		--compress old data
		if _atroxArenaViewerMatchData ~= nil then
			AAV_DB = {}
			for k,v in pairs(_atroxArenaViewerMatchData) do
				if k > AAV_MAX_SAVED_MATCHES_COUNT or v == nil or type(v.data) ~= 'table' then
					break
				end
				AAV_DB[k] = AAV_DB[k] or {}
				local v_info = {}
				for i,j in pairs(v) do
					if i=='data' then
						local compressed_data = atroxArenaViewer:Archive(j)
						AAV_DB[k]['data'] = compressed_data
						_atroxArenaViewerMatchData[k]['data'] = compressed_data
					else
						v_info[i] = j
					end
				end
				AAV_DB[k]['info'] = atroxArenaViewer:Archive(v_info)
			end
		end
		--purge old data
		atroxArenaViewerData = nil
		_atroxArenaViewerData.data = nil
		--print('convert old data complete')
	else
		--decompress saved data
		_atroxArenaViewerMatchData = {}
		if AAV_DB ~= nil then
			--print('loading data start')
			for k,v in pairs(AAV_DB) do
				if k > AAV_MAX_SAVED_MATCHES_COUNT then
					break
				end
				_atroxArenaViewerMatchData[k] = _atroxArenaViewerMatchData[k] or {}
				_atroxArenaViewerMatchData[k] = atroxArenaViewer:DeArchive(v.info)
				_atroxArenaViewerMatchData[k]['data'] = v.data
			end
			--print('loading data complete')
		end
	end

	_atroxArenaViewerData = _atroxArenaViewerData or {
		defaults = {
			profile = {
				update = 0.1,
				interval = 0.1,
				minimapx = -54.6,
				minimapy = 58.8,
				hpbartexture = "oCB",
				manabartexture = "oCB",
				broadcastannounce = false, --broadcast announce
				showdetectedspec = true, --show detected spec in match table
				detectspec = true, --detect and save players spec
				shownamestooltip = true, --show team names over match table
				showplayerrealm = true, --adds realm name to player's name
				healthdisplay = 3, -- deficit percentage
				shortauras = true, -- don't exceed debuff buff bar
				uniquecolor = false, -- use class color as hp bar
				showBySpec = true, -- show the matchesTable with specs instead of names
			}
		}
	}

	--set enabled by default
	if (_atroxArenaViewerData.defaults.profile.showdetectedspec ~= false) then
		_atroxArenaViewerData.defaults.profile.showdetectedspec = true
	end
	if (_atroxArenaViewerData.defaults.profile.detectspec ~= false) then
		_atroxArenaViewerData.defaults.profile.detectspec = true
	end
	if (_atroxArenaViewerData.defaults.profile.shownamestooltip ~= false) then
		_atroxArenaViewerData.defaults.profile.shownamestooltip = true
	end
	if (_atroxArenaViewerData.defaults.profile.showplayerrealm ~= false) then
		_atroxArenaViewerData.defaults.profile.showplayerrealm = true
	end

	_atroxArenaViewerData.current = {
		inArena = false,
		inFight = false,
		entered = 0,
		time = 0,
		move = 0,
		broadcast = false,
		showdetectedspec = true, --detect players spec
		detectspec = true,
		shownamestooltip = true,
		showplayerrealm = true,
		record = true,
		listening = "",
		interval = 0.1,
		update = 0.1,
		communication = "GUILD",
		showBySpec = true,
	}
    
    local minimap = AAV_Gui:createMinimapIcon(self)
    
    print("AAV Cata Classic v"..AAV_VERSIONMAJOR.."."..AAV_VERSIONMINOR.."."..AAV_VERSIONBUGFIX.. " " .. L.AAV_LOADED)
    
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    -- Event that could be useful ARENA_TEAM_UPDATE 
end

function atroxArenaViewer:OnEnable()

	C_ChatInfo.RegisterAddonMessagePrefix(AAV_COMM_LOOKUPBROADCAST)
    C_ChatInfo.RegisterAddonMessagePrefix(AAV_COMM_HANDLEMATCHDATA)

    self:RegisterComm(AAV_COMM_LOOKUPBROADCAST, "lookupBroadcast")
    self:RegisterComm(AAV_COMM_HANDLEMATCHDATA, "handleMatchData")
    
    local msg = {
		event = AAV_COMM_EVENT["cmd_versioncheck"],
		major = AAV_VERSIONMAJOR,
		minor = AAV_VERSIONMINOR,
		bugfix = AAV_VERSIONBUGFIX,
    }
    
    self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(msg), self:getCommMethod(), nil)
    
end

function atroxArenaViewer:getBroadcasters()
	return broadcasters
end

----
-- searches for running broadcasts over the guild distribution.
function atroxArenaViewer:lookup()
	for k,v in pairs(broadcasters) do
		self:giveBroadcasterFound(k, v.version)
	end
end

----
-- returns the method which the communication is chosen to.
-- @return "GUILD" or "RAID"
function atroxArenaViewer:getCommMethod()
	return _atroxArenaViewerData.current.communication
end

----
-- from playerName-ServerName to playerName   used to fix stream issues
-- @param a player name
-- @return a player name without servername in it
function atroxArenaViewer:removeServerName(name)
	local nameReturned = name

	for nome,server in string.gmatch(name, "(%S+)-(%S+)") do
		nameReturned = nome
	end
	
	return nameReturned
end

----
-- used for broadcasts. if message contains the player's name, then stream will be listed.
-- @param prefix addon prefix
-- @param msg delivered msg
-- @param dist channel
-- @param sender player
function atroxArenaViewer:lookupBroadcast(prefix, msg, dist, sender)
	local b, sd = self:Deserialize(msg)
	
	sender = self:removeServerName(sender)
	
	if (b and sd.event == AAV_COMM_EVENT["cmd_versioncheck"]) then
	-- VERSION CHECK
		
		local version = nil
		versions[sender] = sd
		
		if (sd.major > AAV_VERSIONMAJOR) then 
			version = sd.major .. "." .. sd.minor .. "." .. sd.bugfix
		else
			if (sd.minor > AAV_VERSIONMINOR and sd.major >= AAV_VERSIONMAJOR) then
				version = AAV_VERSIONMAJOR .. "." .. sd.minor .. "." .. sd.bugfix
			else
				if (sd.bugfix > AAV_VERSIONBUGFIX and sd.major >= AAV_VERSIONMAJOR and sd.minor >= AAV_VERSIONMINOR) then
					version = AAV_VERSIONMAJOR .. "." .. AAV_VERSIONMINOR .. "." .. sd.bugfix
				end
			end
		end
		if (version and version ~= newversion) then
			newversion = version
			print("|cffe392c5<AAV>|r " .. L.AAV_VERSION_OUTDATED)
		end
		
		if (_atroxArenaViewerData.current.broadcast) then
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_broadcaststart"],
				target = nil,
				version = AAV_VERSIONMAJOR.."."..AAV_VERSIONMINOR.."."..AAV_VERSIONBUGFIX,
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
		end
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_broadcaststart"]) then
	-- BROADCAST START
	
		if (not broadcasters[sender]) then
			broadcasters[sender] = sd
			if (_atroxArenaViewerData.defaults.profile.broadcastannounce) then
				print("|cffe392c5<AAV>|r Broadcasting started: " .. sender)
			end
		end
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_broadcaststop"]) then
	-- BROADCAST STOP
	
		broadcasters[sender] = nil
		if (_atroxArenaViewerData.current.listening == sender) then
			print("|cffe392c5<AAV>|r " .. sender .. " stopped broadcasting")
		end
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_status"] and _atroxArenaViewerData.current.listening == sender) then
	-- STATUS
	
		if (T and sd.state) then
			T:setStatus(sd.state)
		end
		if (sd.map and sd.map ~= 0) then
			T:setMapText(sender .. ": " .. AAV_COMM_MAPS[sd.map])
		end
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_connect"] and string.lower(sd.target) == string.lower(UnitName("player")) and _atroxArenaViewerData.current.broadcast) then
	-- CONNECT
		
		table.insert(spectators, sender)
		print("|cffe392c5<AAV>|r New spectator connected: " .. sender .. " (total: " .. #atroxArenaViewer:getSpectators() .. ")")
		
		message["std"] = {
			event = AAV_COMM_EVENT["cmd_accept"],
			target = sender,
			version = nil,
			state = currentstate,
		}
		
		self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
		message["std"].state = nil
		
		-- if match is running, send match data
		if (M and _atroxArenaViewerData.current.inFight) then
			self:sendAllPlayerInfo(sender)
		end
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_connect"] and _atroxArenaViewerData.current.broadcast) then
	-- REMOVE SPECTATOR
		
		for k,v in pairs(spectators) do
			if (string.lower(v) == string.lower(sender)) then
				spectators[k] = nil
			end
		end
	
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_accept"] and sd.target == UnitName("player")) then
	-- ACCEPT
		
		_atroxArenaViewerData.current.listening = sender
		
		if (not T) then T = AAV_PlayStub:new() end
		
		T:resetData()
		T:hidePlayer(T.player)
		T:removeAllCooldowns()
		T:createPlayer(1, 1, true)
		T:setMapText(sender .. ": " .. L.CONNECT_WAITING_DATA)
		T:handleSeeker("hide")
		
		T:setStatus(sd.state)
		print("|cffe392c5<AAV>|r " .. L.CONNECT_CONNECTED_TO .. sender .. ". " .. L.CONNECT_WAITING_DATA)
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_matchend"] and _atroxArenaViewerData.current.listening == sender) then
	-- MATCH END
		--print("Match end")
		if (not T) then 
			--print("T is nil")
			return 
		end
		T.player:Hide()
		T:createStats(sd.match, sd.dudes, T:getCurrentBracket())
		--print("Show stats")
		T.stats:Show()
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_newmatch"] and _atroxArenaViewerData.current.listening == sender) then
	-- NEW MATCH
		
		if (not T) then 
			--print("error")
			return
		end -- should never happen cough
		
		T:hidePlayer(T.player)
		T:resetDudeData()
		T:removeAllCC()
		T:removeAllCooldowns()
		T:createPlayer(T:getCurrentBracket(), 1, true)
		--T:setMapText(sender .. ": " .. AAV_COMM_MAP[sd.map])
		T:handleSeeker("hide")
		T:setOnUpdate("start")
	
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_updateplayer"] and _atroxArenaViewerData.current.listening == sender) then
	-- UPDATE PLAYER
	
		T:addDudeData(sd.guid, sd.dude)
		AAV_Gui:setPlayerFrameSize(T.origin, T:getCurrentBracket())
		AAV_Gui:setPlayerFrameSize(T.player, T:getCurrentBracket())
		
		--print("update player")
		T:newEntities(T.player) -- redraw
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_updateallplayers"] and _atroxArenaViewerData.current.listening == sender and sd.target == UnitName("player")) then
	-- UPDATE ALL PLAYERS
	
		if (not T) then 
			--print("Error: PlayerStub not initialized.") 
			return 
		end -- should never happen cough
		
		T:hidePlayer(T.player)
		T:resetDudeData()
		
		for k,v in pairs(sd.dudes) do
			T:addDudeData(k, v)
		end
		
		AAV_Gui:setPlayerFrameSize(T.origin, T:getCurrentBracket())
		AAV_Gui:setPlayerFrameSize(T.player, T:getCurrentBracket())
		
		T:createPlayer(T:getCurrentBracket(), 1, true)
		T:setMapText(sender .. ": " .. AAV_COMM_MAPS[sd.map])
		T:handleSeeker("hide")
		
		T:setOnUpdate("start")
		
		--print("update all player")
		T:newEntities(T.player) -- redraw
		
	elseif (b and sd.event == AAV_COMM_EVENT["cmd_spectatorstop"] and _atroxArenaViewerData.current.broadcast and sd.target == UnitName("player")) then
	-- SPECTATOR CLOSES
		
		for k,v in pairs(spectators) do
			if (sender == v) then
				spectators[k] = nil
			end	
		end
	end
end

----
-- players stops listening to a broadcaster and sends a stop message.
function atroxArenaViewer:stopListening()
	
	message["std"] = {
		event = AAV_COMM_EVENT["cmd_spectatorstop"],
		target = _atroxArenaViewerData.current.listening,
		version = AAV_VERSIONMAJOR.."."..AAV_VERSIONMINOR.."."..AAV_VERSIONBUGFIX,
	}
	
	self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
	
	_atroxArenaViewerData.current.listening = ""
end

----
-- prints locally broadcaster with version.
-- @param sender broadcaster
-- @param version
function atroxArenaViewer:giveBroadcasterFound(sender, version)
	print("|cffe392c5<AAV>|r Broadcaster found: " .. sender .. " (v" .. version .. ")")
end

----
-- handles the use of enabling or disabling broadcasting and sends it to everyone in the channel.
-- @param val start or stop broadcasting
function atroxArenaViewer:handleBroadcasting(val)
	message["std"] = {
		event = AAV_COMM_EVENT["cmd_broadcast" .. val],
		target = nil,
		version = AAV_VERSIONMAJOR.."."..AAV_VERSIONMINOR.."."..AAV_VERSIONBUGFIX,
	}
	
	if (val == "start") then
		print("|cffe392c5<AAV>|r " .. L.CMD_ENABLE_BROADCAST)
		_atroxArenaViewerData.current.broadcast = true
		for k,v in pairs(spectators) do spectators[k] = nil end
		
		if (_atroxArenaViewerData.current.inFight) then
			self:handleQueueTimer("start")
		end
	elseif (val == "stop") then
		print("|cffe392c5<AAV>|r " .. L.CMD_DISABLE_BROADCAST)
		_atroxArenaViewerData.current.broadcast = false
		
		-- broadcasting that you're broadcasting
		
		if (_atroxArenaViewerData.current.inFight) then
			self:handleQueueTimer("stop")
		end
	end
	
	self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
end

----
-- connects someone to a broadcaster.
-- @param name broadcaster's name
function atroxArenaViewer:connectToBroadcast(name)
	message["std"] = {
		target = name,
		event = AAV_COMM_EVENT["cmd_connect"],
		version = AAV_VERSIONMAJOR.."."..AAV_VERSIONMINOR.."."..AAV_VERSIONBUGFIX
	}
	self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
end

----
-- incoming match data.
function atroxArenaViewer:handleMatchData(prefix, msg, dist, sender)
	local message = AAV_Util:split(msg, '^')
	
	sender = self:removeServerName(sender)

	if (_atroxArenaViewerData.current.listening == sender) then
		for k,v in pairs(message) do
			local post = AAV_Util:split("0," .. v, ',')
			self:executeMatchData(0, post)
		end
	end
end

----
-- sends an info about a single player
-- @param data serialized data
function atroxArenaViewer:sendPlayerInfo(key, data)
	if (_atroxArenaViewerData.current.broadcast) then
		message["dude"] = {
			event = AAV_COMM_EVENT["cmd_updateplayer"],
			--bracket = self:getCurrentBracket(),
			guid = key,
			dude = data,
		}
		self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["dude"]), self:getCommMethod(), nil)
	end
end

---- 
-- sendMatchInfo
function atroxArenaViewer:sendAllPlayerInfo(sender)
	message["dudes"] = {
		target = sender,
		event = AAV_COMM_EVENT["cmd_updateallplayers"],
		--bracket = self:getCurrentBracket(),
		dudes = M:getDudesData(),
		map = self:getCurrentMapId(),
	}

	self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["dudes"]), self:getCommMethod(), nil)
	message["dudes"].map = nil
end

function atroxArenaViewer:sendNewMatchInfo()
	message["std"] = {
		event = AAV_COMM_EVENT["cmd_newmatch"],
		target = nil,
		version = nil,
		--bracket = self:getCurrentBracket(),
		--map = M:getCurrentMap(),
	}
	
	self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
	message["std"].bracket = nil
	--message["std"].map = nil
end

function atroxArenaViewer:changeBroadcast()
	if (_atroxArenaViewerData.current.broadcast == true) then
		self:handleBroadcasting("stop")
		
	elseif (_atroxArenaViewerData.current.broadcast == false) then
		self:handleBroadcasting("start")
	end
end

function atroxArenaViewer:changeRecording()
	if (_atroxArenaViewerData.current.record == true) then
		if (_atroxArenaViewerData.current.inArena == false) then
			_atroxArenaViewerData.current.record = false
			print("|cffe392c5<AAV>|r " .. L.CMD_DISABLE_RECORDING)
		else
			print("|cffe392c5<AAV>|r Unable to complete this action while in arena.")
		end
		--if (_atroxArenaViewerData.current.inArena == true) then self:handleEvents("stop") end -- [#18] removed
	else
		_atroxArenaViewerData.current.record = true
		--if (_atroxArenaViewerData.current.inArena == true) then self:handleEvents("start") end -- [#18] removed
		print("|cffe392c5<AAV>|r " .. L.CMD_ENABLE_RECORDING)
	end
end

function atroxArenaViewer:OnDisable()
    
end

function atroxArenaViewer:onUpdate(elapsed)
	-- update combat text movements
	if (T) then
		T:onUpdate(elapsed * (_atroxArenaViewerData.current.interval * 10))
	end
	
	return
end


----
-- status 1 = in queue, in arena: message board; 2 = entered
function atroxArenaViewer:UPDATE_BATTLEFIELD_STATUS(event, status)

	-- print("battlefield status: " .. tostring(status))
	if (_atroxArenaViewerData.current.broadcast or _atroxArenaViewerData.current.record and M) then
		--[[
		if (_atroxArenaViewerData.current.broadcast and status == 1 and currentstate == 2) then
		-- unqueue
			currentstate = 1
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
		elseif (_atroxArenaViewerData.current.broadcast and status == 1 and not _atroxArenaViewerData.current.inArena) then
			currentstate = 2
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
		--]]
		if (_atroxArenaViewerData.current.broadcast and status == 1 and currentstate ~= 2) then
			-- if AAV_DEBUG_MODE then
			-- 	print("DEBUG: Broadcast...")
			-- end
			currentstate = 2
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
			
		elseif (status == 1 and _atroxArenaViewerData.current.inArena) then
			-- if AAV_DEBUG_MODE then
			-- 	print("DEBUG: I got here while still broadcasting...")
			-- end
			local arenaPlayers = GetNumBattlefieldScores()  -- Number of participant scores available in the current battleground; 0 if not in a battleground (number)
			local playerName = GetUnitName("player", false)
			local IsActiveBattlefieldArena,GetBattlefieldWinner,GetBattlefieldTeamInfo
				= IsActiveBattlefieldArena,GetBattlefieldWinner,GetBattlefieldTeamInfo
			local n = 1 --Chatframe#
			local _, oldTeamRating0, newTeamRating0, matchMakingRating0 = GetBattlefieldTeamInfo(0) -- Team = 0
			local _, oldTeamRating1, newTeamRating1, matchMakingRating1 = GetBattlefieldTeamInfo(1) -- Team = 1
			local teamName0 = "own team"
			local teamName1 = "enemy team"
			local diff0 = newTeamRating0 - oldTeamRating0

			-- get personal rating diff
			local teamrating = 0
			local teamratingdiff = 0
			local brSize = M:setBracket()

			if (brSize == 2) then
				teamrating,_,_,_ = GetPersonalRatedInfo(1)
				teamratingdiff = teamrating - self.rating2
			end
			if (brSize == 3) then
				teamrating,_,_,_ = GetPersonalRatedInfo(2)
				teamratingdiff = teamrating - self.rating3
			end
			if (brSize == 5) then
				teamrating,_,_,_ = GetPersonalRatedInfo(3)
				teamratingdiff = teamrating - self.rating5
			end

			local diff1 = newTeamRating1 - oldTeamRating1
			local playerTeamColor = 'nocolor'
			local isUnratedArena, isRatedArena = IsActiveBattlefieldArena() -- isUnratedArena needs to also check for not isRatedArena to be really sure its unrated arena
			-- this is because "isUnratedArena" returns true if it is any arena and (rated or unrated) and e.g. not a BG, while isRatedArena only returns true if its really rated arena
			local battlefieldWinnerTeam = GetBattlefieldWinner() -- 0 = purple team, 1 = gold team

			if (battlefieldWinnerTeam == nil) then
				-- sometires the event is fired (updates?) within arena, so just return
				-- if AAV_DEBUG_MODE then
				-- 	print("ERROR: Something is broken")
				-- end
				return
			end
			for j=1, arenaPlayers do
				local name, killingBlows, honorableKills, deaths, honorGained, faction, _, race, class, classToken, damageDone, healingDone, _, _, _, _, _ = GetBattlefieldScore(j);
   				-- original: local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(index)
			    -- no some fields are always 0 or nil, no idea what that field between faction and race represents
				-- bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec fields (as per API documentation) do not exist in TBC (they return nil)
				-- if AAV_DEBUG_MODE then
				-- 	print("DEBUG: I also got here...")
				-- end

				if(name == nil) then
					name = "player " .. j -- dirty fix, maybe not needed
				else
					name = self:removeServerName(name)
				end

				-- get the players team color (only self), currently we do nothing with this info
				if (name == playerName) then
					local playerTeamFaction = faction
					if playerTeamFaction == 0 then
						playerTeamColor = "PURPLE"	-- 0
					else
						playerTeamColor = "GOLD" -- 1
					end

					-- print('playerTeamColor:' .. playerTeamColor) -- debug
					-- check if we won
					if battlefieldWinnerTeam == playerTeamFaction then
						-- if AAV_DEBUG_MODE then
						-- 	print("I think we won") -- debug
						-- 	print("rated: " .. tostring(isRatedArena)) -- debug
						-- 	print("unrated: " .. tostring(isUnratedArena)) -- debug
						-- end
						M:setResult(1)
					else
						-- if AAV_DEBUG_MODE then
						-- 	print("I think we lost") -- debug
						-- 	print("rated: " .. tostring(isRatedArena)) -- debug
						-- 	print("unrated: " .. tostring(isUnratedArena)) -- debug
						-- end
						M:setResult(2)
					end
					
					-- TODO: need to fix a bug where both are false when playing unrated arena while broadcasting (don't know what causes this)
					-- below fix would work in skirmishes, breaks rates games, because this code is triggered twice and the second time, both are always false
					-- if AAV_DEBUG_MODE then
					-- 	print("isRated:") -- debug message
					-- 	print(isRatedArena)
					-- 	print("isUnRated:") -- debug message
					-- 	print(isUnratedArena)
					-- end
					-- if(isRatedArena == false and isUnratedArena == false) then
					-- 	isUnratedArena = true
					-- end
				end

				-- do stuff that only needs to be done once, so just do it while we iterate the player themselves
				if ((name == playerName) and (isRatedArena)) then
					-- if AAV_DEBUG_MODE then
					-- 	print("rated arena match") -- debug message
					-- end

					-- always set our own team to id 0, even if we were in team ("faction") 1, to make other stuff easier to manage (e.g. sorting columns in matches table)
					-- enemy team is always set to id 1 for the same reason
					if (faction == 0) then
						-- team (id), name (team), rating, diff, mmr
						M:setTeams(0, teamName0, teamrating, teamratingdiff, matchMakingRating0) -- we are in team 0
						M:setTeams(1, teamName1, oldTeamRating1, diff1, matchMakingRating1) -- enemy is in team 1
					else -- switch it up
						M:setTeams(0, teamName1, teamrating, teamratingdiff, matchMakingRating1) -- we are in team 1
						M:setTeams(1, teamName0, oldTeamRating0, diff0, matchMakingRating0) -- enemy is in team 0
					end
					
					-- further debug messages, got this stuff from the addon !mmr(Match Making Rating), credits to PacMan
					if AAV_DEBUG_MODE then
						local ChatFrame = _G["ChatFrame"..n]
						ChatFrame:AddMessage("< "..teamName0.." >".." MMR " .. matchMakingRating0.." ("..diff0..")", 189/255, 103/255, 255/255) -- Purple Team
						ChatFrame:AddMessage("< "..teamName1.." >".." MMR " .. matchMakingRating1.." ("..diff1..")", 255/255, 213/255, 0/255)  -- Gold Team
					end

				elseif ((name == playerName) and (isUnratedArena) and not (isRatedArena)) then
					-- if AAV_DEBUG_MODE then
					-- 	print("unrated arena match") -- debug message
					-- end
					
					-- same reason to always set own team to id 0 and enemy team to id 1 as for rated games, see comments further above
					if (faction == 0) then
						-- team (id), name (team), rating, diff, mmr
						teamName0 = "skirmish own team"
						teamName1 = "skirmish enemy team"
						M:setTeams(0, teamName0, "skirm: -", 0, 0) -- we are in team 0
						M:setTeams(1, teamName1, "skirm: -", 0, 0) -- enemy is in team 1
					else -- switch it up
						teamName1 = "skirmish own team"
						teamName0 = "skirmish enemy team"
						M:setTeams(0, teamName1, "skirm: -", 0, 0) -- we are in team 1
						M:setTeams(1, teamName0, "skirm: -", 0, 0) -- enemy is in team 0
					end
					
					-- further debug messages, got this stuff from the addon !mmr(Match Making Rating), credits to PacMan
					if AAV_DEBUG_MODE then
						local ChatFrame = _G["ChatFrame"..n]
						ChatFrame:AddMessage("< "..teamName0.." >".." - skirmish game, no ratings available", 189/255, 103/255, 255/255) -- Purple Team
						ChatFrame:AddMessage("< "..teamName1.." >".." - skirmish game, no ratings available", 255/255, 213/255, 0/255)  -- Gold Team
					end
				end
					
				-- original: M:setPlayer(guids,name, rating, damageDone, healingDone, personalRatingChange, mmr, specName)
				-- note: rating, personalRatingChange and mmr are not obtainable on a per-player basis in TBC classic, just per-team. so we always set 0 for now
				-- maybe we'll find some way in the future?
				if (_atroxArenaViewerData.defaults.profile.showdetectedspec) then
					M:setPlayer(guids,name, 0, damageDone, healingDone, 0, 0, "auto")
				else
					M:setPlayer(guids,name, 0, damageDone, healingDone, 0, 0, "nospec")
				end
					
			end
			
			if (_atroxArenaViewerData.current.broadcast) then
				if AAV_DEBUG_MODE then
					print("** Match ended **")
				end
				message["stats"] = {
					event = AAV_COMM_EVENT["cmd_matchend"],
					match = M:getTeams(),
					dudes = M:getDudesData(),
					--bracket = self:getCurrentBracket(),
				}
				self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["stats"]), self:getCommMethod(), nil)
			end
			
		elseif (_atroxArenaViewerData.current.broadcast and status == 2) then
			currentstate = 3
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
				map = self:getCurrentMapId(),
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
			message["std"].map = nil
			
		end
	end
	
end

----
-- event to track the start of the arena match.
-- @param event
-- @param msg message to compare
function atroxArenaViewer:CHAT_MSG_BG_SYSTEM_NEUTRAL(event, msg)
	if (string.upper(msg) == string.upper(L.ARENA_START)) then
		if (_atroxArenaViewerData.current.record == true) then
			_atroxArenaViewerData.current.entered = self:getCurrentTime()
			_atroxArenaViewerData.current.time = GetTime()
			
			self:sendNewMatchInfo() -- match starts
			
			guids = {} -- reset guids
			NotifyInspect("raid" .. 1) -- triggers INSPECT_READY which will get the specs of all party members.
			for i = 1, 5 do
				if (UnitExists("raid" .. i)) then
					local name, _ = UnitName("raid" .. i)					
					guids[name] = UnitGUID("raid" .. i)		
					local key, player = M:updateMatchPlayers(1, "raid" .. i)
					self:sendPlayerInfo(key, player)
				end
			end

			-- NOTE: at this point we don't have enemy team data yet, so I also moved setBracket to where the game ends and is saved
			-- right now we set bracket here AND later when the match ended (own team size is best guessed when match started, enemy team size is best guessed when match ended, so this seems like a good idea)
			M:setBracket() -- sets the bracket size according to dudes data
			
			self:handleEvents("register")
			self:handleQueueTimer("start")
		end
		currentstate = 8
		if (_atroxArenaViewerData.current.broadcast) then
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
		end
		
	elseif (msg == L.ARENA_60) then
		currentstate = 4
		if (_atroxArenaViewerData.current.broadcast) then
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
				map = self:getCurrentMapId(),
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
			message["std"].map = nil
		end
	elseif (msg == L.ARENA_45) then
		currentstate = 5
		if (_atroxArenaViewerData.current.broadcast) then
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
				map = self:getCurrentMapId(),
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
			message["std"].map = nil
		end
	elseif (msg == L.ARENA_30) then
		currentstate = 6
		if (_atroxArenaViewerData.current.broadcast) then
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
				map = self:getCurrentMapId(),
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
			message["std"].map = nil
		end
	elseif (msg == L.ARENA_15) then
		currentstate = 7
		
		self.rating2,_,_,_ = GetPersonalRatedInfo(1) -- 2v2
		self.rating3,_,_,_ = GetPersonalRatedInfo(2) -- 3v3
		self.rating5,_,_,_ = GetPersonalRatedInfo(3) -- 5v5

		if (_atroxArenaViewerData.current.broadcast) then
			message["std"] = {
				event = AAV_COMM_EVENT["cmd_status"],
				target = nil,
				version = nil,
				state = currentstate,
				map = self:getCurrentMapId(),
			}
			self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
			message["std"].state = nil
			message["std"].map = nil
		end
	end
end

---
-- Sets the specs for all party members. Only added as party specs wouldn't be set if the player left the game prematurely (eg if there was an obvious loss).
-- @param event
-- @param guid Guid used to find who to inspect
-- @param other
-- TBC Classic: removed, spec cannot be obtained via API. could only guess by presence of certain spec specific buffs like Gladdy does, but will not implement this here for now.
function atroxArenaViewer:INSPECT_READY(event, guid, other)
	--if guid then 
	--	if(M and M:getDudesData()[guid]) then
	--		for i = 1, 5 do
	--			if (UnitExists("raid" .. i)) then
	--				if(guid == UnitGUID("raid" .. i)) then --should only happen once
	--					AAV_Spec:ScanUnitBuffs("raid" .. i)
	--					--if(M:getDudesData()[guid].spec == nil or strlen(M:getDudesData()[guid].spec) == 0) then
	--					--	local specID = 0 --GetInspectSpecialization("raid" .. i)
	--					--	local specName = "nospec" --GetSpecializationInfoByID(specID)
	--					--	if(specName) then 
	--					--		M.combatans.dudes[guid].spec = specName
	--					--	end
	--					--end
	--					if(i<5) then NotifyInspect("raid" .. i+1) end
	--				end
	--			end
	--		end
	--	end
	--end
end

function atroxArenaViewer:ZONE_CHANGED_NEW_AREA(event, unit)	

	AAV_Spec.specTable = {}

	if (GetZonePVPInfo() == "arena") then
	
		CombatLogClearEntries() -- fixes combat log parse overflow problem		
		self:RegisterEvent("INSPECT_READY")
		self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
		
		_atroxArenaViewerData.current.inArena = true
		_atroxArenaViewerData.current.entered = self:getCurrentTime()
		_atroxArenaViewerData.current.time = GetTime()
		
		M = AAV_MatchStub:new()
		
	else --save match
		if (_atroxArenaViewerData.current.inArena) then
			
			self:handleEvents("unregister")
			self:handleQueueTimer("stop")
			self:UnregisterEvent("INSPECT_READY")
			self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
			
			if (_atroxArenaViewerData.current.record) then
				_atroxArenaViewerMatchData = _atroxArenaViewerMatchData or {}
				local saved_matches_count = #_atroxArenaViewerMatchData -- #matches in data before new match is saved

				-- if #matches + 1 exceeds threshold, delete oldest match to avoid 
				while saved_matches_count + 1 > AAV_MAX_SAVED_MATCHES_COUNT do
					print("|cffe392c5<AAV>|r " .. L.DEL_OLD_MATCHES_1 .. " " .. AAV_MAX_SAVED_MATCHES_COUNT .. " " .. L.DEL_OLD_MATCHES_2)
					self:deleteMatch(1) -- delete oldest match
					saved_matches_count = saved_matches_count - 1 -- decrement counter
				end
				local matchid = self:getNewMatchID()
				
				_atroxArenaViewerMatchData[matchid] = _atroxArenaViewerMatchData[matchid] or {}
				
				M:setBracket() -- sets the bracket size according to dudes data

				M:setMatchEnd()
				M:saveToVariable(matchid)
			end
			
			if (_atroxArenaViewerData.current.broadcast) then
				currentstate = 1
				message["std"] = {
					event = AAV_COMM_EVENT["cmd_status"],
					target = nil,
					version = nil,
					state = currentstate,
				}
				self:SendCommMessage(AAV_COMM_LOOKUPBROADCAST, self:Serialize(message["std"]), self:getCommMethod(), nil)
				message["std"].state = nil
			end
			
			_atroxArenaViewerData.current.inArena = false
			_atroxArenaViewerData.current.entered = 0
			_atroxArenaViewerData.current.time = 0
			_atroxArenaViewerData.current.move = 0
			
		end
	end
end

-----
function atroxArenaViewer:handleEvents(val)
	if (val == "register") then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:RegisterEvent("UNIT_HEALTH")
		self:RegisterEvent("UNIT_POWER_UPDATE") 
		self:RegisterEvent("ARENA_OPPONENT_UPDATE")
		--self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self:RegisterEvent("UNIT_NAME_UPDATE")
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("UNIT_SPELLCAST_START")
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		_atroxArenaViewerData.current.inFight = true
		
		
		--print("[debug] registering all events")
	elseif (val == "unregister") then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:UnregisterEvent("UNIT_HEALTH")
		self:UnregisterEvent("UNIT_POWER_UPDATE") 
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		--self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self:UnregisterEvent("UNIT_NAME_UPDATE")
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterEvent("UNIT_SPELLCAST_START")
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		_atroxArenaViewerData.current.inFight = false
		
	end
end

----
-- returns the player, null if not initialized.
-- @return T playstub
function atroxArenaViewer:getPlayer()
	return T
end

----
-- used to initialize the visible units when match starts.
-- @param val "raid" or "arena" specified
-- @param side 1 = left (self), 2 = right (enemies)
function atroxArenaViewer:initArenaMatchUnits(arr)
	local unit, side = arr[1], arr[2]
	local hp, hpmax, guid
	local buffs, debuffs = {}, {}
	local i, n = 1, 1
	
	if (UnitName(unit) == L.UNKNOWN or UnitClass(unit) == nil) then return end
	
	guid = M:getGUIDtoNumber(UnitGUID(unit))
	if (not guid) then return end
	
	-- BUFFS
	for n = 1, 40 do
		local _, _, icon, _, _, _, _, _, _, _, b = UnitBuff(unit, n) --spellid
		if (b and not self:isExcludedAura(spellId)) then
			if (string.find(string.lower(icon), "_mount_") == nil and string.lower(icon) ~= "inv_misc_key_14" and string.lower(icon) ~= "inv_misc_key_06") then
				table.insert(buffs, b)
			end
		else
			break
		end
	end
	
	-- DEBUFFS
	for n = 1, 40 do
		_, _, _, _, _, _, _, _, _, _, b = UnitDebuff(unit, n) --spellid
		if (b and not self:isExcludedAura(spellId)) then
			table.insert(debuffs, b)
		else
			break
		end
	end
	
	for k,v in pairs(buffs) do
		M:getBuffs(guid)[k] = true
	end
	for k,v in pairs(debuffs) do
		M:getDebuffs(guid)[k] = true
	end
	
	self:createMessage(self.getDiffTime(), "0," .. guid .. "," .. UnitHealth(unit) .. "," .. UnitHealthMax(unit) .. "," .. table.concat(buffs, ";") .. "," .. table.concat(debuffs, ";"))
end

function atroxArenaViewer:createMessage(tick, msg)
	if (_atroxArenaViewerData.current.record) then
		M:createMessage(tick .. "," .. msg)
	end
	
	-- broadcasting
	if (_atroxArenaViewerData.current.broadcast) then
		table.insert(queue, msg)
	end
end

function atroxArenaViewer:handleQueueTimer(val)
	if (val == "start" and self:TimeLeft(queuetimer)==0) then
		queuetimer = self:ScheduleRepeatingTimer("queueMatchData", AAV_QUEUESENDTIME)
	elseif (val == "stop" and self:TimeLeft(queuetimer)) then
		self:CancelTimer(queuetimer)
		queuetimer = nil
	end
end

----
-- repeated function that sends all collected data in a defined period.
function atroxArenaViewer:queueMatchData()
	if (#queue > 0) then
	--print(table.concat(queue, "^"))
		self:SendCommMessage(AAV_COMM_HANDLEMATCHDATA, table.concat(queue, "^"), self:getCommMethod(), nil)
		
		-- empty queue
		for k,v in pairs(queue) do
			queue[k] = nil
		end
	end
end

----
-- queries the current zone and compares the text with the ones in the AAV_COMM_MAPS.
-- @return map id
function atroxArenaViewer:getCurrentMapId()
	for k,v in pairs(AAV_COMM_MAPS) do
		if (GetZoneText() == v) then
			return k
		end
	end
	return 0
end

----
-- monitors the change of mana in consideration of mana treshold (AAV_MANATRESHOLD).
-- @param event
-- @param unit
-- @param type resource changed (mana, ragem ...)
--function atroxArenaViewer:UNIT_MANA(event, unit)
function atroxArenaViewer:UNIT_POWER_UPDATE(event, unit, type)
	if (type ~= "MANA") then
		return
	end
	
	local player = M:getDudesData()[UnitGUID(unit)]
	if (player) then --and (player.mana > (UnitPower(unit)/UnitPowerMax(unit))) then
		
		local mana = math.floor((UnitPower(unit)/UnitPowerMax(unit))*100)
		if not (mana > player.mana - AAV_MANATRESHOLD and mana < player.mana + AAV_MANATRESHOLD) then
			player.mana = mana
			local u = M:getGUIDtoNumber(UnitGUID(unit))
			if (u) then self:createMessage(self:getDiffTime(), "17," .. u .. "," .. mana) end
		end
	end
end

----
-- monitors the change of Health, inclusive Max HP.
-- Currently limited to raid and arena targets (no pets).
-- @param event
-- @param unit
function atroxArenaViewer:UNIT_HEALTH(event, unit)
	local sub = string.sub(unit,1,4)
	if (sub == "raid" or sub == "aren") then
		local target = M:getChangeInHealthFlags(unit)
		local u = M:getGUIDtoNumber(UnitGUID(unit))
		
		if (bit.band(target, 0x1) ~= 0 and u) then
			self:createMessage(self:getDiffTime(), "1," .. u .. "," .. UnitHealth(unit))
		end
		if (bit.band(target,0x2) ~= 0 and u) then
			self:createMessage(self:getDiffTime(), "2," .. u .. "," .. UnitHealthMax(unit))
		end
	end
end

function atroxArenaViewer:UNIT_AURA(event, unit)

	if (_atroxArenaViewerData.defaults.profile.detectspec) then
		AAV_Spec:ScanUnitBuffs(unit)
	end

	local n, m = 1, 1
	local sub = string.sub(unit,1,4)
	if (sub ~= "raid" and sub ~= "aren") then return end
	
	local id = M:getGUIDtoNumber(UnitGUID(unit))
	if (not id) then return end
	
	for n = 1, 40 do
		local bname, _, bstacks, _, btime, _, _, _, _, bspellid = UnitBuff(unit, n)
		local dname, _, dstacks, _, dtime, _, _, _, _, dspellid = UnitDebuff(unit, n)

		if (not bspellid and not dspellid) then break end
		
		if (bspellid) then tempbuffs[bspellid] = true end
		if (dspellid) then tempdebuffs[dspellid] = true end
		

		-- new buffs/debuffs
		if (bspellid and not M:getBuffs(id)[bspellid]) then
			-- create new buff
			M:getBuffs(id)[bspellid] = true
			
			if (not btime) then btime = 0 end
			-- if AAV_DEBUG_MODE then
			-- 	print("buff spell: " .. bname)
			-- 	--print("buff spellid: " .. bspellid)
			-- 	print("bstacks: " .. bstacks)
			-- end
			self:createMessage(self:getDiffTime(), "13," .. id .. "," .. bspellid .. ",1," .. btime .. "," .. bstacks)
		end
		if (dspellid and not M:getDebuffs(id)[dspellid]) then
			-- create new debuff
			M:getDebuffs(id)[dspellid] = true
			
			if (not dtime) then dtime = 0 end
			-- if AAV_DEBUG_MODE then
			-- 	print("debuff spell: " .. dname)
			-- 	print("debuff spellid: " .. dspellid)
			-- 	print("dstacks: " .. dstacks)
			-- 	print("---")
			-- end
			self:createMessage(self:getDiffTime(), "13," .. id .. "," .. dspellid .. ",2," .. dtime .. "," .. dstacks)
		end

		-- buff/debuff update (already exists = refreshed, stacks changed, ...)
		if (bspellid and M:getBuffs(id)[bspellid]) then
			-- update buff
			-- M:getBuffs(id)[bspellid] = true -- TODO: do we need this for update events?
			
			if (not dtime) then dtime = 0 end
			-- if AAV_DEBUG_MODE then
			-- 	print("update debuff spell: " .. dname)
			-- 	print("update debuff spellid: " .. dspellid)
			-- 	print("update dstacks: " .. dstacks)
			-- 	print("---")
			-- end
			self:createMessage(self:getDiffTime(), "15," .. id .. "," .. bspellid .. ",1," .. btime .. "," .. bstacks)
		end
		if (dspellid and M:getDebuffs(id)[dspellid]) then
			-- update debuff
			-- M:getDebuffs(id)[dspellid] = true -- TODO: do we need this for update events?
			
			if (not dtime) then dtime = 0 end
			-- if AAV_DEBUG_MODE then
			-- 	print("update debuff spell: " .. dname)
			-- 	print("update debuff spellid: " .. dspellid)
			-- 	print("update dstacks: " .. dstacks)
			-- 	print("---")
			-- end
			self:createMessage(self:getDiffTime(), "15," .. id .. "," .. dspellid .. ",2," .. dtime .. "," .. dstacks)
		end
	end
	
	-- buffs/debuffs ran out
	for k,v in pairs(M:getBuffs(id)) do
		if (not tempbuffs[k]) then
			--remove
			self:createMessage(self:getDiffTime(), "14," .. id .. "," .. k .. ",1")
			M:getBuffs(id)[k] = nil
		end
	end
	for k,v in pairs(M:getDebuffs(id)) do
		if (not tempdebuffs[k]) then
			--remove
			self:createMessage(self:getDiffTime(), "14," .. id .. "," .. k .. ",2")
			M:getDebuffs(id)[k] = nil
		end
	end
	
	for k,v in pairs(tempbuffs) do
		tempbuffs[k] = nil
	end
	for k,v in pairs(tempdebuffs) do
		tempdebuffs[k] = nil
	end
	
end

function atroxArenaViewer:UNIT_SPELLCAST_START(event, unit, castGUID)
	if (_atroxArenaViewerData.defaults.profile.detectspec) then
		local spellName, _, _, _, _, _, _, _, spellId = CastingInfo(event)

		if event then
			AAV_Spec:ScanUnitBuffs(unit)
		end

		if spellName then
			if AAV_Spec.specSpells[spellId] and event then
				AAV_Spec:OnSpecDetected(UnitGUID(unit), AAV_Spec.specSpells[spellId])
			end
		end
	end
end

function atroxArenaViewer:UNIT_SPELLCAST_CHANNEL_START(event, unit, castGuid, spellId)
	if (_atroxArenaViewerData.defaults.profile.detectspec) then
		if unit then 
			AAV_Spec:ScanUnitBuffs(unit)
		end

		if spellId then
			if AAV_Spec.specSpells[spellId] and unit then
				AAV_Spec:OnSpecDetected(UnitGUID(unit), AAV_Spec.specSpells[spellId])
			end
		end
	end
end

----
-- Called when a name update is available, will set the name and spec (spec removed in TBC classic, because not available via API)
-- @param event
-- @param unit arena1, arena2...
function atroxArenaViewer:UNIT_NAME_UPDATE(event, unit)
	if _atroxArenaViewerData.current.inArena then
		if (GetZonePVPInfo() == "arena") then -- make sure we really are in arena
			if (UnitIsPlayer(unit)) then
				if (not M) then return end
				local sourceGUID = UnitGUID(unit)
				
				-- debugging prints
				if AAV_DEBUG_MODE then
					print("======== UNIT_NAME_UPDATE DEBUG MESSAGES")
					print(sourceGUID)
					print(unit)
					print(UnitName(unit))
					print(M:getDudesData())
					print(M:getDudesData()[sourceGUID])
					print(M:getDudesData()[sourceGUID].name)
					-- TODO: sometimes the first line throws an error, check why
				end
				if((UnitName(unit) ~= nil) and (sourceGUID ~= nil) and (unit ~= nil) and (_atroxArenaViewerData.current.inArena)) then
					if (M:getDudesData()[sourceGUID]) then
						M:getDudesData()[sourceGUID].name, M:getDudesData()[sourceGUID].realm = UnitName(unit)
						self:sendPlayerInfo(sourceGUID, M:getDudesData()[sourceGUID])
					end
				else
					print("AAV: error UNIT_NAME_UPDATE")
				end
				
				-- if(strsub(unit, 1, strlen(unit)-1) ~= "raid") then
				-- 	M:SetOpponentSpec(sourceGUID, strsub(unit, strlen(unit)))
				-- end
			end
		end
	end
end

function atroxArenaViewer:ARENA_OPPONENT_UPDATE(event, unit, type)
	local u = M:getGUIDtoNumber(UnitGUID(unit))
	
	if (type == "seen") then
		if (not u) then
			local key, player = M:updateMatchPlayers(2, unit)
			self:sendPlayerInfo(key, player)
			if (UnitIsPlayer(unit)) then
				--M:SetOpponentSpec(UnitGUID(unit), strsub(unit, strlen(unit))) --TODO
				if (_atroxArenaViewerData.defaults.profile.detectspec) then
					AAV_Spec:ScanUnitBuffs(unit)
				end
			end
			
			--self:ScheduleTimer("initArenaMatchUnits", AAV_INITOFFTIME, {unit, 2})
			--self:initArenaMatchUnits({unit, 2})
		else
			-- if character vanishes and reappears
			--self:initArenaMatchUnits({unit, 2})
			self:createMessage(self:getDiffTime(), "18," .. u .. ",2")
		end
		
	elseif (type == "unseen") then
		-- lost track (stealth)
		if (u) then self:createMessage(self:getDiffTime(), "18," .. u .. ",1") end
		
	elseif (type == "destroyed") then
		-- has left the arena
		if (u) then self:createMessage(self:getDiffTime(), "18," .. u .. ",3") end
		
	end
end

----
-- triggered, when an arena match ended (3 times).
--[[
function atroxArenaViewer:UPDATE_BATTLEFIELD_SCORE(event, unit)
	--self:handleEvents("unregister")
	
end
--]]

-- Needed to track PvP trinkets and possibly other spells that do not show up in COMBAT_LOG_EVENT_UNFILTERED
-- may fire multiple times for the same spell with different units (player, target, party1, raid1, etc., ...) so we filter some duplicates
-- looks like enemies are best tracked as arena1, arena2 etc
-- looks like own team is best tracked as raid1, raid2 etc
-- got the idea how to handle this from Omnibar, credits to Omnibars developer!
function atroxArenaViewer:UNIT_SPELLCAST_SUCCEEDED(event,unit,_,spellid)

	if (_atroxArenaViewerData.defaults.profile.detectspec) then
		if unit then
			AAV_Spec:ScanUnitBuffs(unit)
		end

		if spellid then
			if AAV_Spec.specSpells[spellid] and unit then
				AAV_Spec:OnSpecDetected(UnitGUID(unit), AAV_Spec.specSpells[spellid])
			end
		end
	end

	-- filter out spell event from player (self), because we also get an event from raid1/party1 etc.
	-- filter out spell event from target, because we also get an event from raid1/party1/arena1 etc.
	-- TODO: check if party1 etc can be safely removed as duplicates from raid1 etc, or if we're missing trinkets then
	-- if (unit == "player") or (unit == "target") or (string.find(unit, "nameplate")) or (string.find(unit, "party")) then
	-- 	return
	-- end
	-- INFO: other possible solution used in other functions, needs testing tho:
	local sub = string.sub(unit,1,4)
	if (sub ~= "raid" and sub ~= "aren") then return end

	-- cata tracks pvp trinket without this
	---- PvP Trinket
	--if spellid == 42292 then
	--	
	--	local eventType = 10
	--	local dest = -1
	--	local source = M:getGUIDtoNumber(UnitGUID(unit))
	--	if (not source) then source = 0 end
	--	local time = 0

	--	-- if AAV_DEBUG_MODE then
	--	-- 	-- print("--aav message:")
	--	-- 	-- print(self:getDiffTime())
	--	-- 	-- print(eventType)
	--	-- 	-- print(source)
	--	-- 	-- print(dest)
	--	-- 	-- print(spellid)
	--	-- 	-- print(time)
	--	-- 	print("-- unit used pvp trinket --")
	--	-- 	print(GetUnitName(unit, true))
	--	-- 	print(unit)
	--	-- end
	--	self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. spellid .. "," .. time)
	--end
end

function atroxArenaViewer:COMBAT_LOG_EVENT_UNFILTERED(event)
	atroxArenaViewer:COMBAT_LOG_EVENT_ORIGINAL(event, CombatLogGetCurrentEventInfo() )
end
function atroxArenaViewer:COMBAT_LOG_EVENT_ORIGINAL(event, ...)
	--local timestamp, type, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = select(1, ...)
	--local timestamp, type, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical
	--type, _, sourceGUID, _, _, _, destGUID = select(2, ...)

	local eventType, msg
	local timestamp, type, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = CombatLogGetCurrentEventInfo()
	
	local source = M:getGUIDtoNumber(sourceGUID)
	local dest = M:getGUIDtoNumber(destGUID)
	
	-- check if name is unknown
	--[[
	if (source and M:getDudesData()[sourceGUID].name == L.UNKNOWN) then
		M:getDudesData()[sourceGUID].name = UnitName(M:getGUIDtoTarget(sourceGUID))
		self:sendPlayerInfo(sourceGUID, M:getDudesData()[sourceGUID])
		
	end
	if (dest and M:getDudesData()[destGUID].name == L.UNKNOWN) then
		M:getDudesData()[destGUID].name = UnitName(M:getGUIDtoTarget(destGUID))
		self:sendPlayerInfo(destGUID, M:getDudesData()[destGUID])
	end
	--]]
	
	if (type == "SWING_DAMAGE") then
		eventType = 3
		critical = critical and 1 or 0
		absorbed = absorbed and 1 or 0
		if (source and dest and amount) then -- dont track damage from unknown sources and destinations
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. amount .. "," .. critical)
			M:addStats(1, sourceGUID, amount + absorbed, "Melee")
		end
	elseif (type == "SPELL_DAMAGE") then
		eventType = 4
		critical = critical and 1 or 0
		absorbed = absorbed and 1 or 0
		if (source and dest and amount) then -- dont track damage from unknown sources and destinations
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. amount .. "," .. critical)
			M:addStats(1, sourceGUID, amount + absorbed, spellName)
		end
	elseif (type == "SPELL_PERIODIC_DAMAGE") then
		eventType = 5
		critical = critical and 1 or 0
		absorbed = absorbed and 1 or 0
		if (source and dest and amount) then -- dont track damage from unknown sources and destinations
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. amount .. "," .. critical)
			M:addStats(1, sourceGUID, amount + absorbed, spellName)
		end
	elseif (type == "RANGE_DAMAGE") then
		eventType = 6
		critical = critical and 1 or 0
		absorbed = absorbed and 1 or 0
		if (source and dest and amount) then -- dont track damage from unknown sources and destinations
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. amount .. "," .. critical)
			M:addStats(1, sourceGUID, amount + absorbed, spellName)
		end
	elseif (type == "SPELL_HEAL") then
		eventType = 7
		critical = critical and 1 or 0
		if (source and dest and amount) then -- dont track damage from unknown sources and destinations
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. amount .. "," .. critical)
			M:addStats(2, sourceGUID, amount - overkill, nil)
		end
	elseif (type == "SPELL_PERIODIC_HEAL") then
		eventType = 8
		critical = critical and 1 or 0
		if (source and dest and amount) then -- dont track damage from unknown sources and destinations
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. amount .. "," .. critical)
			M:addStats(2, sourceGUID, amount - overkill, nil)
		end
	elseif (type == "SPELL_CAST_START") then
		eventType = 9
		if (source) then
			local target, destTarget = M:getGUIDtoTarget(sourceGUID), ""
			if (target) then destTarget = M:getGUIDtoNumber(UnitGUID(target .. "target")) end
			if (not destTarget) then destTarget = source end
			--local _, _, _, _, _, _, casttime = GetSpellInfo(spellId)
			local _, _, _, casttime, _, _, _, _ = GetSpellInfo(spellId)
			local _, duration, _ = GetSpellCooldown(spellId)
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. destTarget .. "," .. spellId .. "," .. casttime .. "," .. duration)
		end
	elseif (type == "SPELL_CAST_SUCCESS") then
		eventType = 10
		if (source) then
			if (not dest) then dest = -1 end
			local time = 0
			--GetSpellCooldown(spellId)
			--M:getGUIDtoTarget(sourceGUID)
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. spellId .. "," .. time)
		end
	elseif (type == "SPELL_CAST_FAILED") then
		-- cant be tracked from others
		
	elseif (type == "SPELL_INTERRUPT") then
		eventType = 12
		if (source and dest) then
			self:createMessage(self:getDiffTime(), eventType .. "," .. source .. "," .. dest .. "," .. spellId .. "," .. amount)
		end
	elseif (type == "SPELL_AURA_APPLIED") then
		-- INFO: events 13 (aura applied), 14 (aura removed) and 15 (aura update) are handled in atroxArenaViewer:UNIT_AURA event
		--[[
		eventType = 13
		if (source and dest) then
			local time = 0
			local target
			if (amount == "BUFF") then amount = 1 else amount = 2 end -- buffs = 1, debuffs = 2
			
			if (AAV_IMPORTANTSKILLS[spellId]) then -- check importantskill
				local target = M:getGUIDtoTarget(destGUID)
				if (target) then 
					for i=1,40 do
						spid = 0
						if (amount == 1) then 
							_, _, _, _, _, time, _, _, _, _, spid = UnitBuff(target, i)
						elseif (amount == 2) then
							_, _, _, _, _, time, _, _, _, _, spid = UnitDebuff(target, i)
						end
						if (spid == spellId) then break end -- spell found
					end
				end
			end
			
			if (not time) then time = 0 end
			self:createMessage(self:getDiffTime(), eventType .. "," .. dest .. "," .. spellId .. "," .. amount .. "," .. time)
		end
		--]]
	elseif (type == "SPELL_AURA_REMOVED") then
		-- INFO: events 13 (aura applied), 14 (aura removed) and 15 (aura update) are handled in atroxArenaViewer:UNIT_AURA event
		--[[
		eventType = 14
		if (source and dest) then
			if (amount == "BUFF") then amount = 1 else amount = 2 end -- buffs = 1, debuffs = 2
			self:createMessage(self:getDiffTime(), eventType .. "," .. dest .. "," .. spellId .. "," .. amount)
		end
		--]]
	elseif (type == "SPELL_AURA_REFRESH") then
		-- INFO: events 13 (aura applied), 14 (aura removed) and 15 (aura update) are handled in atroxArenaViewer:UNIT_AURA event
		eventType = 15
		-- if AAV_DEBUG_MODE then
		-- 	print("SPELL AURA REFRESH EVENT:")
		-- 	print(dest)
		-- 	print(spellId)
		-- 	print("---")
		-- end
		--[[
		if (source and dest) then
			if (amount == "BUFF") then amount = 1 else amount = 2 end -- buffs = 1, debuffs = 2
			self:createMessage(self:getDiffTime(), eventType .. "," .. dest .. "," .. spellId .. "," .. amount)
		end
		--]]
	elseif (type == "UNIT_DIED") then
		eventType = 16
		-- 17 MANA
	end
	
end

----
-- check function whether omitted spellId is in the exceptauras table.
-- @param spellId
-- @return true if it's excluded and unwanted spell
function atroxArenaViewer:isExcludedAura(spellId)
	for k,v in pairs(exceptauras) do
		if (spellId == v) then 
			return true
		end
	end
	return false
end

function atroxArenaViewer:getNewMatchID()
	local max = 0
	for k,v in pairs(_atroxArenaViewerMatchData) do
		if (tonumber(k) > max) then
			max = k
		end
	end
	return max + 1
end


-- removed in 4.0.3
-- function atroxArenaViewer:getCurrentBracket()
-- 	currentbracket = nil
-- 	for i=1,2 do
-- 		local status, _, _, _, _, teamSize = GetBattlefieldStatus(i)
-- 		if (status == "active" and teamSize > 0) then
-- 			currentbracket = teamSize
-- 			break
-- 		end
-- 	end
-- 	return currentbracket
-- end


function atroxArenaViewer:getCurrentTime()
	return date("%y-%m-%d %H:%M:%S")
end

function atroxArenaViewer:getDiffTime()
	return math.ceil((GetTime() - _atroxArenaViewerData.current.time)*100)/100
end


----
-- creates the player
-- as of 1.1.7 if bracket isnt available by data it'll be calculated.
-- @param num data entry
function atroxArenaViewer:createPlayer(num)
	local i = 1
	
	if (not T) then T = AAV_PlayStub:new() end
	
	T:hidePlayer(T.player)
	T:setOnUpdate("start")
	
	T:setMatchData(num)
	
	if (not T:getMatchData(1)) then
		return
	end
	
	-- check if bracket is available
	if (_atroxArenaViewerMatchData[num].bracket == nil) then
		_atroxArenaViewerMatchData[num].bracket = 0
		for k,v in pairs(_atroxArenaViewerMatchData[num].combatans.dudes) do
			if (v.player and v.team == 1) then
				_atroxArenaViewerMatchData[num].bracket = _atroxArenaViewerMatchData[num].bracket + 1
			end
		end
	end
	
	T:createPlayer(_atroxArenaViewerMatchData[num].bracket, _atroxArenaViewerMatchData[num].elapsed, false)
	print("|cffe392c5<AAV>|r Start playing: " .. AAV_COMM_MAPS[_atroxArenaViewerMatchData[num].map] .. " at " .. _atroxArenaViewerMatchData[num].startTime)
end

function atroxArenaViewer:deleteMatch(num)
	-- if AAV_DEBUG_MODE then
	-- 	print(num)
	-- 	for c,w in pairs(_atroxArenaViewerMatchData[num]) do
	-- 		if c == "startTime" then
	-- 			print("deleting match #" .. num .. " from " .. w)
	-- 		end
	-- 	end
	-- end
	table.remove(_atroxArenaViewerMatchData, num)
	table.remove(AAV_DB, num)
end

function atroxArenaViewer:exportMatch(num)
	exportnum = num
end

----
-- recursive function for export.
-- @param tab table
-- @param input if set then add skill legend
function atroxArenaViewer:getRecursiveExport(tab, input)
	local str = "{"
	local first = true
	for k,v in pairs(tab) do
		if (not first) then str = str .. "," end
		if (type(v) == "table") then
			str = str .. '"' .. tostring(k) .. '":' .. self:getRecursiveExport(v)
		else
			str = str .. '"' .. tostring(k) .. '":"' .. tostring(v) .. '"'
		end
		first = false
	end
	
	if (input) then
		str = str .. self:getSkillLegend(tab.data)
	end
	
	str = str .. "}"
	print(str)
	return str
end

----
-- exports all used skills in the match.
-- @param tab table
function atroxArenaViewer:getSkillLegend(tab)
	local str = ""
	local tmp
	local db = {}
	
	for k,v in pairs(tab) do 
		
		tmp = AAV_Util:split(v, ',')
		
		if (tmp[2] == "9" or tmp[2] == "10" or tmp[2] == "11" or tmp[2] == "12") then
			if (not db[tonumber(tmp[5])]) then
				db[tonumber(tmp[5])] = true
			end
		elseif (tmp[2] == "13" or tmp[2] == "14") then
			if (not db[tonumber(tmp[4])]) then
				db[tonumber(tmp[4])] = true
			end
		end
	end
	
	str = ',"legend":['
	
	local first = true
	for k,v in pairs(db) do
		local name, _, icon = GetSpellInfo(tonumber(k))
		icon = string.gsub(string.lower(icon), "interface\\icons\\", "")
		if (not first) then str = str .. "," end
		str = str .. '{"id":' .. tostring(k) .. ',"icon":"' .. icon .. '","name":"' .. name .. '"}'
		first = false
	end
	
	str = str .. ']'
	
	return str
end

----
-- returns all spectators to own broadcasted match.
-- @return spectator list
function atroxArenaViewer:getSpectators()
	return spectators
end

----
-- exports the match data.
-- @param num match id
function atroxArenaViewer:getExportString(num)
	local str = "["
	str = str .. self:getRecursiveExport(_atroxArenaViewerMatchData[num], true) 	
	str = str .. "]"
	return str
end

function atroxArenaViewer:getMatch()
	return T:getMatch()
end

----
-- plays the given match.
-- @param num matchid
function atroxArenaViewer:playMatch(num)
	local pre
	if (T:getCurrentMatchData()) then
		pre = AAV_Util:split(T:getCurrentMatchData(), ',')
		T:removeAllCC()
		T:removeAllCooldowns()
		T:setTickTime(tonumber(pre[1]))
		T:setMapText(T:getMatch()["map"])
		
		-- check if older matches
		local vmajor, vminor, vbugfix = strsplit(".", T:getMatch()["version"])
		vmajor = tonumber(vmajor)
		vminor = tonumber(vminor)
		vbugfix = tonumber(vbugfix)
		if ((vmajor < AAV_VERSIONMAJOR) or (vmajor == AAV_VERSIONMAJOR and vminor < AAV_VERSIONMINOR)) then --bugfix version should be compatible with old replays, othervise make it minor\major
			StaticPopup_Show("AAV_PLAYOLDMATCHES_DIALOG")
		end
		
		--T:handleTimer("start")
	else
		print("Error - bad match data.")
	end
end

function atroxArenaViewer:evaluateMatchData()
	local done = false
	local post
	
	T:setTickTime(T:getTickTime() + _atroxArenaViewerData.current.interval)
	T:updatePlayerTick()
	
	while not done do
		if (not T:getCurrentMatchData()) then
			T:handleTimer("stop")
			done = true
		else
			post = AAV_Util:split(T:getCurrentMatchData(), ',')
			if (not T:getCurrentMatchData() or (tonumber(post[1]) >= T:getTickTime())) then
				done = true
			else
				self:executeMatchData(T:getTick(), post)
				T:setTick(T:getTick() + 1)
			end
		end
	end
end


function atroxArenaViewer:commEvaluateBroadcastData(prefix, msg, dist, sender)
	sender = self:removeServerName(sender)
	
	if (_atroxArenaViewerData.current.listening == sender) then
		
	end
end


function atroxArenaViewer:executeMatchData(tick, data)
	--[[ 
	INFO: other fields depend in the event type (t), so maybe it's not possible to document all possible combinations here..
	data[1] = timer/timestamp
	data[2] = t = event type
	data[3] =
	data[4] =
	data[5] =
	data[6] =
	data[7] =
	--]]
	local t = tonumber(data[2])
	
	-- init
	if (t == 0) then
		
		T:setBar(tonumber(data[3]), tonumber(data[4]))
		T:setMaxBar(tonumber(data[3]), tonumber(data[5]))
		--[[
		T:removeAllAuras(tonumber(data[3]))
		
		local buffs = AAV_Util:split(data[6], ";")
		
		if (buffs) then
			for k,v in pairs(buffs) do
				for c,w in pairs(buffs) do
					-- sexx
					T.entities[id]
				end
				T:addAura(tonumber(data[3]), tonumber(v), 1)
			end
		end
		
		local debuffs = AAV_Util:split(data[7], ";")
		if (debuffs) then
			for k,v in pairs(debuffs) do
				T:addAura(tonumber(data[3]), tonumber(v), 2)
			end
		end
		--]]
	-- current HP
	elseif (t == 1) then
		T:setBar(tonumber(data[3]), tonumber(data[4]))
		
	-- max HP
	elseif (t == 2) then
		T:setMaxBar(tonumber(data[3]), tonumber(data[4]))
		
	-- damage
	elseif (t == 3 or t == 4 or t == 5 or t == 6) then	
		T:addFloatingCombatText(tonumber(data[4]), tonumber(data[5]), tonumber(data[6]), 1)
		--T:addDamage(tonumber(data[4]), tonumber(data[5]))
		
	-- heal	
	elseif (t == 7 or t == 8) then
		T:addFloatingCombatText(tonumber(data[4]), tonumber(data[5]), tonumber(data[6]), 2)
		--T:addHeal(tonumber(data[4]), tonumber(data[5]))
		
	-- cast starts
	elseif (t == 9) then
		T:addSkillIcon(tonumber(data[3]), tonumber(data[5]), true, tonumber(data[4]), tonumber(data[6]))
		
	-- cast success
	elseif (t == 10) then
		--print("cast succes ".. data[1] .. " ".. data[2] .." ".. data[3] .." " .. data[4].." "..data[5].. " " ..data[6] )
		T:addSkillIcon(tonumber(data[3]), tonumber(data[5]), false, tonumber(data[4]))
		
		if (tonumber(data[6]) and AAV_CCSKILS[tonumber(data[5])]) then
			T:addCooldown(tonumber(data[3]), tonumber(data[5]), AAV_CCSKILS[tonumber(data[5])])
		end
		
	elseif (t == 11) then
		-- cast interrupt, not implemented -- TODO: check why not
		T:interruptSkill(tonumber(data[3]), tonumber(data[4]), tonumber(data[5]), tonumber(data[6]))

	elseif (t == 12) then
		-- spell_interrupt -- TODO: check what is the difference between cast interrupt and spell interrupt
		T:interruptSkill(tonumber(data[3]), tonumber(data[4]), tonumber(data[5]), tonumber(data[6]))
		
	elseif (t == 13) then
		-- spell_aura_applied
		T:addAura(tonumber(data[3]), tonumber(data[4]), tonumber(data[5]), tonumber(data[6]), tonumber(data[7]))
		-- if AAV_DEBUG_MODE then
		-- 	-- INFO: data[3] = playerID, data[4] = spellId, data[5] = 1 or 2 (buff/debuff), data[6] = duration, data[7] = #stacks
		-- 	print("aura_applied ".. tonumber(data[3]) .. ", " .. tonumber(data[4]).. ", ".. tonumber(data[5]) .. ", " .. tonumber(data[6]) .. ", " .. tonumber(data[7]))
		-- end
		-- TODO: this may be the place where timers for buffs/debuffs could also be added, because we already got the duration in the data
		if (data[6] and tonumber(data[6]) > 0 and AAV_IMPORTANTSKILLS[tonumber(data[4])]) then
			T:addCC(tonumber(data[3]), tonumber(data[4]), tonumber(data[6]), AAV_IMPORTANTSKILLS[tonumber(data[4])])
		end
		
		if (AAV_BUFFSTOSKILLS[tonumber(data[4])]) then
			T:addSkillIcon(tonumber(data[3]), tonumber(data[4]), false, nil)
		end
		
	elseif (t == 14) then
		-- spell_aura_removed
		T:removeAura(tonumber(data[3]), tonumber(data[4]), tonumber(data[5]))
		if (AAV_IMPORTANTSKILLS[tonumber(data[4])]) then
			T:removeCC(tonumber(data[3]), tonumber(data[4]))
		end
		
	elseif (t == 15) then
		-- spell_aura_refreshed
		-- TODO: maybe this could be optimized with a T:updateAura function
		T:removeAura(tonumber(data[3]), tonumber(data[4]), tonumber(data[5]))
		T:addAura(tonumber(data[3]), tonumber(data[4]), tonumber(data[5]), tonumber(data[6]), tonumber(data[7]))
	elseif (t == 16) then
		-- died
		-- T:setVisibility(tonumber(data[3]), 4)
		
	elseif (t == 17) then
		-- mana changes
		T:setMana(tonumber(data[3]), tonumber(data[4]))
		
	elseif (t == 18) then
		-- visibility changes
		T:setVisibility(tonumber(data[3]), tonumber(data[4]))
		
	end
	
end
