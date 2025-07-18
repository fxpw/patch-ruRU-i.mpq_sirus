local error = error
local mathmax, mathmin = math.max, math.min
local select = select
local tonumber = tonumber
local type = type
local strfind, strformat, strsplit, strtrim = string.find, string.format, string.split, strtrim
local tconcat, twipe = table.concat, table.wipe
local utf8len = utf8.len

local GetBattlefieldWinner = GetBattlefieldWinner
local IsSpellHiddenInCombatLog = IsSpellHiddenInCombatLog
local IsSpellHiddenOnCastBar = IsSpellHiddenOnCastBar
local LeaveBattlefield = LeaveBattlefield
local UnitName = UnitName

local FireClientEvent = FireClientEvent
local FireCustomClientEvent = FireCustomClientEvent
local GMError = GMError
local IsInterfaceDevClient = IsInterfaceDevClient
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx

local SPECTATOR_MODE = {
	Disabled	= 0,
	Enabled		= 1,
	Tournament	= 2,
}

local MATCH_STATE = {
	NONE = 0,
	PREPARATION = 1,
	IN_PROGRESS = 2,
	SCORE = 3,
}

local CLASS_ID_WARRIOR = CLASS_ID_WARRIOR
local CLASS_ID_ROGUE = CLASS_ID_ROGUE
local CLASS_ID_DEATHKNIGHT = CLASS_ID_DEATHKNIGHT
local CLASS_ID_DRUID = CLASS_ID_DRUID
Enum.ArenaSpectator = {}
Enum.ArenaSpectator.Mode = CopyTable(SPECTATOR_MODE)
Enum.ArenaSpectator.CastType = {
	Range				= 99995,
	LOS					= 99996,
	Success				= 99997,
	Cancel				= 99998,
	Interrupt			= 99999,
	Casting				= 100000,
}

local TARGET_BLACKLIST = {
	["World Invisible Trigger"] = true,
}

local PLAYBACK_SPEED_MIN = 0.01
local PLAYBACK_SPEED_MAX = 5

local PRIVATE = {
	DEBUG = true,
	DEBUG_PACKETS = false,
	DEBUG_PARSER = false,
	DEBUG_UNKNOWN_SPELLS = false,
	DEBUG_HIDDEN_SPELLS = false,

	MODE = SPECTATOR_MODE.Disabled,
	STATE = MATCH_STATE.NONE,

	IS_PAUSED = false,
	PLAYBACK_SPEED = 1,

	MATCH_TIME = 0,
	FIGHT_TIME = 0,
--	FIGHT_TIME_END = nil,

	ROSTER_DATA = {},
	COMMAND_HANDLERS = {},

--	AWAIT_ASMSG_AR_WATCH = nil,
--	AWAIT_ASMSG_AR_SPEED = nil,
--	AWAIT_ASMSG_AR_PAUSED = nil,
--	AWAIT_ASMSG_AR_CLAIM = nil,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if channel == "UNKNOWN" and sender == UnitName("player") then
			if PRIVATE[prefix] then
				PRIVATE[prefix](message)
			end
		elseif prefix == "ARENASPEC" and channel == "WHISPER" and sender == "" then
			if PRIVATE.DEBUG_PACKETS then
				PRIVATE.LOG(message)
			end
			PRIVATE.ParseCommandMessage(message)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		PRIVATE.ON_SPECTATOR_MAP = false
		PRIVATE.FIGHT_TIME_END = nil
		PRIVATE.SetMode(SPECTATOR_MODE.Disabled)
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	if not PRIVATE.IS_PAUSED and PRIVATE.IsActive() then
		local replayElapsed = elapsed * PRIVATE.PLAYBACK_SPEED

		if PRIVATE.STATE == MATCH_STATE.PREPARATION
		or PRIVATE.STATE == MATCH_STATE.IN_PROGRESS
		then
			PRIVATE.MATCH_TIME = PRIVATE.MATCH_TIME + replayElapsed
		end

		if PRIVATE.STATE == MATCH_STATE.IN_PROGRESS then
			PRIVATE.FIGHT_TIME = PRIVATE.FIGHT_TIME + replayElapsed

			PRIVATE.WINNER_CHECK_ELAPSED = (PRIVATE.WINNER_CHECK_ELAPSED or 0) + elapsed
			if PRIVATE.WINNER_CHECK_ELAPSED >= 0.5 then
				PRIVATE.WINNER_CHECK_ELAPSED = 0

				local winner = GetBattlefieldWinner()
				if winner then
					PRIVATE.STATE = MATCH_STATE.SCORE
					FireCustomClientEvent("ARENA_SPECTATOR_MATCH_END")
					FireCustomClientEvent("ARENA_SPECTATOR_SCORE", winner)
				end
			end
		end
	end
end)

PRIVATE.Initialize = function()
	if IsInterfaceDevClient() then
		_G.PRIVATE_ARENA_SPECTATOR = PRIVATE
	end
end

PRIVATE.ASMSG_AR_WATCH = function(msg)
	PRIVATE.AWAIT_ASMSG_AR_WATCH = nil
end

PRIVATE.ASMSG_AR_SPEED = function(msg)
	PRIVATE.AWAIT_ASMSG_AR_SPEED = nil

	local status = tonumber(msg)
	if status >= 0 then
		PRIVATE.SetPlaybackSpeed(status)
	else
		local errorText = _G[strformat("ARENA_SPECTATOR_ERROR_%d", -(status))]
		if not errorText then
			errorText = strformat("[ASMSG_AR_SPEED] Error code '%s'", status or "nil")
		end
		PRIVATE.ShowError(errorText)
	end
end

PRIVATE.ASMSG_AR_PAUSED = function(msg)
	PRIVATE.AWAIT_ASMSG_AR_PAUSED = nil

	local status = tonumber(msg)
	if status >= 0 then
		PRIVATE.IS_PAUSED = status == 1
		FireCustomClientEvent("ARENA_SPECTATOR_PAUSE", PRIVATE.IS_PAUSED)
	else
		local errorText = _G[strformat("ARENA_SPECTATOR_ERROR_%d", -(status))]
		if not errorText then
			errorText = strformat("[ASMSG_AR_PAUSED] Error code '%s'", status or "nil")
		end
		PRIVATE.ShowError(errorText)
	end
end

PRIVATE.ASMSG_AR_CLAIM = function(msg)
	PRIVATE.AWAIT_ASMSG_AR_CLAIM = nil

	local status = tonumber(msg)
	if status == 0 then
		FireCustomClientEvent("ARENA_SPECTATOR_REPORT_SUCCESS")
	else
		local errorText = _G[strformat("ARENA_SPECTATOR_ERROR_%d", status)]
		if not errorText then
			errorText = strformat("[ASMSG_AR_CLAIM] Error code '%s'", status or "nil")
		end
		PRIVATE.ShowError(errorText)
	end
end

PRIVATE.ASMSG_AR_SEND_META_INFO = function(msg) -- TODO: replay
end

PRIVATE.LOG = function(...)
	if PRIVATE.DEBUG and IsInterfaceDevClient() then
		printc(...)
	end
end

PRIVATE.ShowError = function(errorText)
	FireClientEvent("UI_ERROR_MESSAGE", errorText)
	if IsInterfaceDevClient() then
		print(errorText)
	end
end

PRIVATE.IsActive = function()
	return PRIVATE.MODE ~= SPECTATOR_MODE.Disabled
end

PRIVATE.SetMode = function(mode)
	PRIVATE.MODE = mode
	PRIVATE.IS_PAUSED = false
	PRIVATE.WINNER_CHECK_ELAPSED = 0

	if PRIVATE.ON_SPECTATOR_MAP
	and PRIVATE.MODE == SPECTATOR_MODE.Disabled
	and PRIVATE.FIGHT_TIME > 0
	then
		PRIVATE.FIGHT_TIME_END = PRIVATE.FIGHT_TIME
	end

	PRIVATE.MATCH_TIME = 0
	PRIVATE.FIGHT_TIME = 0

	twipe(PRIVATE.ROSTER_DATA)

	PRIVATE.AWAIT_ASMSG_AR_SPEED = nil
	PRIVATE.AWAIT_ASMSG_AR_PAUSED = nil
	PRIVATE.AWAIT_ASMSG_AR_CLAIM = nil

	if PRIVATE.MODE == SPECTATOR_MODE.Disabled then
		PRIVATE.STATE = MATCH_STATE.NONE
		PRIVATE.eventHandler:Hide()
	else
		PRIVATE.STATE = MATCH_STATE.PREPARATION
		PRIVATE.eventHandler:Show()
		PRIVATE.ON_SPECTATOR_MAP = true
	end

	FireCustomClientEvent("ARENA_SPECTATOR_MODE", PRIVATE.MODE)
	PRIVATE.SetPlaybackSpeed(1)
end

PRIVATE.SetPlaybackSpeed = function(speed)
	PRIVATE.PLAYBACK_SPEED = speed
	FireCustomClientEvent("ARENA_SPECTATOR_PLAYBACK_SPEED", speed)
end

do -- process commands
	PRIVATE.ParseCommandMessage = function(msg)
		local targetName, payload = strsplit(";", msg, 2)
		if targetName and payload ~= "" then
			local nonTargetFormat = strfind(targetName, "[0-9=]") ~= nil
			if nonTargetFormat then
				PRIVATE.ParseCommands(nonTargetFormat, nil, StringSplitEx(";", msg))
			else
				if not TARGET_BLACKLIST[targetName] and PRIVATE.IsActive() then
					PRIVATE.ParseCommands(nonTargetFormat, targetName, StringSplitEx(";", payload))
				end
			end
		else
			PRIVATE.LOG(strformat("[ARENASPEC] Missing command [%s]", msg))
		end
	end

	PRIVATE.ParseCommands = function(isModeCommand, targetName, ...)
		local numCommands = select("#", ...)
		if numCommands == 0 then
			return
		end

		if isModeCommand then
			for i = 1, select("#", ...) do
				local command, value = strsplit("=", select(i, ...), 2)
				PRIVATE.ParseModeCommands(command, value)
			end
		else
			if numCommands == 1 then
				local commandStr = ...
				local command, value = strsplit("=", commandStr, 2)
				PRIVATE.ProcessTargetCommand(command, targetName, value)
			else
				local commandList = {}
				for i = 1, numCommands do
					local command, value = strsplit("=", select(i, ...), 2)
					commandList[command] = value
				end
				PRIVATE.ProcessTargetCommandList(commandList, targetName)
			end
		end
	end

	PRIVATE.ProcessTargetCommandList = function(commandList, targetName)
		if commandList["PWT"] then
			local unitData = PRIVATE.GetUnitData(targetName)
			if unitData then
				local classID = unitData.CLASS_ID
				local powerType = tonumber(commandList["PWT"])

				if not classID and commandList["CLA"] then
					classID = tonumber(commandList["CLA"])
				end

				if classID and not PRIVATE.IsValidPowerType(classID, powerType) then
					PRIVATE.LOG("FILTER WRONG POWER UPDATE:", targetName, classID, powerType)
					commandList["PWT"] = nil
					commandList["CPW"] = nil
					commandList["MPW"] = nil
				end
			end
		end

		for command, value in pairs(commandList) do
			PRIVATE.ProcessTargetCommand(command, targetName, value)
		end
	end

	PRIVATE.ParseModeCommands = function(command, ...)
		if PRIVATE.DEBUG_PARSER then
			PRIVATE.LOG("PROCESS MODE:", command, ...)
		end
		local handler = PRIVATE.COMMAND_HANDLERS[command]
		if handler then
			handler(command, nil, ...)
		else
			GMError(strformat("[ARENA_SPECTATOR] Unhandled mode prefix [%s] (%s)", command or "nil", tconcat(";", {...})))
		end
	end

	PRIVATE.ProcessTargetCommand = function(command, target, ...)
		if PRIVATE.DEBUG_PARSER then
			PRIVATE.LOG("PROCESS TARG:", command, target, ...)
		end
		local handler = PRIVATE.COMMAND_HANDLERS[command]
		if handler then
			handler(command, target, ...)
		else
			GMError(strformat("[ARENA_SPECTATOR] Unhandled target prefix [%s] (%s)", command or "nil", tconcat(";", {target or "NO_TARGET", ...})))
		end
	end

	PRIVATE.ProcessCommandSpectatorMode = function(command, target, value)
		PRIVATE.SetMode(tonumber(value) or 0)
	end

	PRIVATE.ProcessCommandMatchStart = function(command, target, value)
		PRIVATE.STATE = MATCH_STATE.IN_PROGRESS
		PRIVATE.FIGHT_TIME = tonumber(value)
		FireCustomClientEvent("ARENA_SPECTATOR_MATCH_START", PRIVATE.FIGHT_TIME)
	end

	PRIVATE.FireCommand = function(command, target, ...)
		if not target or target == "" then
			local value
			if select("#", ...) <= 1 then
				value = ...
			else
				value = tconcat({...}, "; ")
			end
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		PRIVATE.HandlerCommand(command, target, ...)
	end

	PRIVATE.ProcessCommandNumber = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		PRIVATE.FireCommand(command, target, tonumber(value))
	end

	PRIVATE.ProcessCommandString = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		PRIVATE.FireCommand(command, target, value)
	end

	PRIVATE.ProcessCommandTalent = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		value = (tonumber(value) or 0) + 1

		if value < 1 or value > 3 then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing incorrect talentTree index for command [%s] with value [%s]", command or "nil", value or "nil"))
			value = mathmax(1, mathmin(3, value))
		end

		PRIVATE.FireCommand(command, target, value)
	end

	PRIVATE.ProcessCommandSetHidden = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		PRIVATE.FireCommand(command, target, value == "1")
	end

	PRIVATE.ProcessCommandSpellCast = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		local spellID, castTime = strsplit(",", value)
		spellID = tonumber(spellID)

		local isHiddenInCombatLog = IsSpellHiddenInCombatLog(spellID)
		local isUnknownSpell = isHiddenInCombatLog == nil
		if isHiddenInCombatLog or IsSpellHiddenOnCastBar(spellID) then
			if PRIVATE.DEBUG_HIDDEN_SPELLS then
				local spellName = GetSpellInfo(spellID)
				PRIVATE.LOG(strformat("[ARENASPEC] Spell cast filtered [%s](%s) for [%s]", spellID or "nil", spellName or "UNKNOWN", target or "nil"))
			end
		elseif isUnknownSpell then
			if PRIVATE.DEBUG_UNKNOWN_SPELLS then
				PRIVATE.LOG(strformat("[ARENASPEC] Spell cast UNKNOWN spell [%s] for [%s]", spellID or "nil", target or "nil"))
			end
		else
			PRIVATE.FireCommand(command, target, spellID, tonumber(castTime) or 0)
		end
	end

	PRIVATE.ProcessCommandSpellCooldown = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end
		local spellID, cooldownTime = strsplit(",", value)
		spellID = tonumber(spellID)

		local isHiddenInCombatLog = IsSpellHiddenInCombatLog(spellID)
		local isUnknownSpell = isHiddenInCombatLog == nil
		if isHiddenInCombatLog then
			if PRIVATE.DEBUG_HIDDEN_SPELLS then
				local spellName = GetSpellInfo(spellID)
				PRIVATE.LOG(strformat("[ARENASPEC] Spell cooldown filtered [%s](%s) for [%s]", spellID or "nil", spellName or "UNKNOWN", target or "nil"))
			end
		elseif isUnknownSpell then
			if PRIVATE.DEBUG_UNKNOWN_SPELLS then
				PRIVATE.LOG(strformat("[ARENASPEC] Spell cooldown UNKNOWN spell [%s] for [%s]", spellID or "nil", target or "nil"))
			end
		else
			PRIVATE.FireCommand(command, target, spellID, tonumber(cooldownTime) or 0)
		end
	end

	PRIVATE.ProcessCommandAuraUpdate = function(command, target, value)
		if not target or target == "" then
			PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
			return
		end

		local isRemoved, stackCount, expirationTime, duration, spellID, debuffType, isDebuff, casterGUID = strsplit(",", value)

		spellID = tonumber(spellID)
		if not spellID then
			return
		end

		stackCount = tonumber(stackCount) or 1
		duration = tonumber(duration) or -1
		expirationTime = tonumber(expirationTime) or -1
		debuffType = tonumber(debuffType) or 0

		isRemoved = isRemoved == "true" or isRemoved == "1"
		isDebuff = not (isDebuff == "true" or isDebuff == "1")

		PRIVATE.FireCommand(command, target, spellID, isRemoved, stackCount, expirationTime, duration, debuffType, isDebuff, casterGUID)
	end

	PRIVATE.ProcessCommandTeam = function(command, target, value)
		local teamID
		if target == "469" then
			teamID = 2
			target = nil
		elseif target == "67" then
			teamID = 1
			target = nil
		end

		if teamID then
			FireCustomClientEvent("ARENA_SPECTATOR_TEAM_COMMAND", command, teamID, value)
		else
			if not target or target == "" then
				PRIVATE.LOG(strformat("[ARENASPEC] Missing target for command [%s] with value [%s]", command or "nil", value or "nil"))
				return
			end

			PRIVATE.FireCommand(command, target, value)
		end
	end

	PRIVATE.ProcessCommandTournamentInfo = function(command, target, value)
		FireCustomClientEvent("ARENA_SPECTATOR_TOURNAMENT_INFO", value)
	end

	PRIVATE.ProcessCommandTournamentStage = function(command, target, value)
		FireCustomClientEvent("ARENA_SPECTATOR_TOURNAMENT_STAGE", value)
	end

	PRIVATE.COMMAND_HANDLERS.STA = PRIVATE.ProcessCommandNumber				-- STATUS
	PRIVATE.COMMAND_HANDLERS.MHP = PRIVATE.ProcessCommandNumber				-- HP MAX
	PRIVATE.COMMAND_HANDLERS.CHP = PRIVATE.ProcessCommandNumber				-- HP CURRENT
	PRIVATE.COMMAND_HANDLERS.MPW = PRIVATE.ProcessCommandNumber				-- POWER MAX
	PRIVATE.COMMAND_HANDLERS.CPW = PRIVATE.ProcessCommandNumber				-- POWER CURRENT
	PRIVATE.COMMAND_HANDLERS.PWT = PRIVATE.ProcessCommandNumber				-- POWER TYPE
	PRIVATE.COMMAND_HANDLERS.TRG = PRIVATE.ProcessCommandString				-- TARGET
	PRIVATE.COMMAND_HANDLERS.CLA = PRIVATE.ProcessCommandNumber				-- CLASS
	PRIVATE.COMMAND_HANDLERS.TEM = PRIVATE.ProcessCommandNumber				-- TEAM
	PRIVATE.COMMAND_HANDLERS.SPE = PRIVATE.ProcessCommandSpellCast			-- SPELL CAST
	PRIVATE.COMMAND_HANDLERS.AUR = PRIVATE.ProcessCommandAuraUpdate			-- AURA
	PRIVATE.COMMAND_HANDLERS.ENB = PRIVATE.ProcessCommandSpectatorMode		-- SPECTATOR MODE
	PRIVATE.COMMAND_HANDLERS.ELA = PRIVATE.ProcessCommandMatchStart			-- START TIME
	PRIVATE.COMMAND_HANDLERS.TAL = PRIVATE.ProcessCommandTalent				-- SPEC
	PRIVATE.COMMAND_HANDLERS.CDN = PRIVATE.ProcessCommandSpellCooldown		-- SPELL COOLDOWN
	PRIVATE.COMMAND_HANDLERS.LEV = PRIVATE.ProcessCommandSetHidden			-- LOCK

	PRIVATE.COMMAND_HANDLERS.NAM = PRIVATE.ProcessCommandTeam				-- TEAM NAME
	PRIVATE.COMMAND_HANDLERS.COL = PRIVATE.ProcessCommandTeam				-- TEAM COLOR
	PRIVATE.COMMAND_HANDLERS.SRC = PRIVATE.ProcessCommandTeam				-- TEAM SCORE

	PRIVATE.COMMAND_HANDLERS.BOX = PRIVATE.ProcessCommandTournamentInfo		-- TOURNAMENT INFO
	PRIVATE.COMMAND_HANDLERS.STAGE = PRIVATE.ProcessCommandTournamentStage	-- TOURNAMENT STAGE
end

do -- command handling
	PRIVATE.CreateUnitData = function(name)
		return {
		--	HIDDEN		= false,
		--	READY		= false,
		--	ALIVE		= true,

			-- base data
			NAME		= name,
		--	CLASS_ID	= nil,
		--	HEALTH		= nil,
		--	HEALTH_MAX	= nil,
		--	POWER		= nil,
		--	POWER_MAX	= nil.
		--	POWER_TYPE	= nil,
		--	TEAM_ID		= nil,
		--	SPEC_INDEX	= nil,

			-- combat data
		--	TARGET		= nil,
		--	SPELL_CAST	= nil,
		}
	end

	PRIVATE.GetUnitData = function(name)
		return PRIVATE.ROSTER_DATA[name]
	end

	PRIVATE.IsValidPowerType = function(classID, powerType)
		if classID == CLASS_ID_WARRIOR then
			return powerType == 1
		elseif classID == CLASS_ID_ROGUE then
			return powerType == 3
		elseif classID == CLASS_ID_DEATHKNIGHT then
			return powerType == 6
		elseif classID == CLASS_ID_DRUID then
			return powerType == 0 --or powerType == 1 or powerType == 3
		else
			return powerType == 0
		end
		return false
	end

	PRIVATE.GetSpellCast = function(unit)
		local spellCast = unit.SPELL_CAST
		if spellCast then
			local status = spellCast.STATUS or Enum.ArenaSpectator.CastType.Casting
			return spellCast.SPELL_ID, spellCast.START_TIME, spellCast.CAST_TIME, status
		end
	end

	PRIVATE.HandlerCommand = function(command, unitName, ...)
		local unitData = PRIVATE.ROSTER_DATA[unitName]
		if not unitData then
			unitData = PRIVATE.CreateUnitData(unitName)
			PRIVATE.ROSTER_DATA[unitName] = unitData
		end

		if command == "CLA" then
			local classID = ...
			unitData.CLASS_ID = classID
		end

		FireCustomClientEvent("ARENA_SPECTATOR_UNIT_COMMAND", command, unitName, ...)
	end
end

PRIVATE.Initialize()

C_ArenaSpectator = {}

function C_ArenaSpectator.IsActive()
	return PRIVATE.IsActive()
end

function C_ArenaSpectator.IsTournament()
	return PRIVATE.MODE == SPECTATOR_MODE.Tournament
end

function C_ArenaSpectator.IsOnSpectatorMap()
	return PRIVATE.ON_SPECTATOR_MAP
end

function C_ArenaSpectator.Leave()
	if PRIVATE.ON_SPECTATOR_MAP then
		LeaveBattlefield()
	end
end

function C_ArenaSpectator.GetMode()
	return PRIVATE.MODE
end

function C_ArenaSpectator.IsInProgress()
	return PRIVATE.STATE == MATCH_STATE.IN_PROGRESS
end

function C_ArenaSpectator.IsInPreparation()
	return PRIVATE.STATE == MATCH_STATE.PREPARATION
end

function C_ArenaSpectator.GetMatchTime()
	return PRIVATE.MATCH_TIME
end

function C_ArenaSpectator.GetFightTime()
	return PRIVATE.FIGHT_TIME_END or PRIVATE.FIGHT_TIME
end

function C_ArenaSpectator.SetPaused(paused)
	paused = not not paused

	if not PRIVATE.IsActive()
	or PRIVATE.AWAIT_ASMSG_AR_PAUSED
	or PRIVATE.IS_PAUSED == paused
	then
		return false
	end

	PRIVATE.AWAIT_ASMSG_AR_PAUSED = true
	SendServerMessage("ACMSG_AR_PAUSED", paused and 1 or 2)

	return true
end

function C_ArenaSpectator.IsPaused()
	return PRIVATE.IS_PAUSED
end

function C_ArenaSpectator.SetPlaybackSpeed(speed)
	if type(speed) ~= "number" then
		error(strformat("bad argument #1 to 'C_ArenaSpectator.SetPlaybackSpeed' (number expected, got %s)", speed ~= nil and type(speed) or "no value"), 2)
	end

	if not PRIVATE.IsActive()
	or PRIVATE.AWAIT_ASMSG_AR_SPEED
	then
		return false
	end

	speed = mathmin(PLAYBACK_SPEED_MAX, mathmax(PLAYBACK_SPEED_MIN, speed))

	if PRIVATE.PLAYBACK_SPEED == speed then
		return false
	end

	PRIVATE.AWAIT_ASMSG_AR_SPEED = true
	SendServerMessage("ACMSG_AR_SPEED", speed)

	return true
end

function C_ArenaSpectator.GetPlaybackSpeed()
	return PRIVATE.PLAYBACK_SPEED
end

function C_ArenaSpectator.GetPlaybackSpeedLimits()
	return PLAYBACK_SPEED_MIN, PLAYBACK_SPEED_MAX
end

function C_ArenaSpectator.SetUnitSpectation(unitName)
	if type(unitName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ArenaSpectator.SetUnitSpectation' (string expected, got %s)", unitName ~= nil and type(unitName) or "no value"), 2)
	end

	if not PRIVATE.IsActive() then
		return false
	end

	SendServerMessage("ACMSG_AR_SPECTATE_VIEW", unitName)
	return true
end

function C_ArenaSpectator.WatchReplay(replayID)
	if type(replayID) ~= "number" then
		error(strformat("bad argument #1 to 'C_ArenaSpectator.WatchReplay' (number expected, got %s)", replayID ~= nil and type(replayID) or "no value"), 2)
	end

	if PRIVATE.AWAIT_ASMSG_AR_WATCH then
		return false
	end

	if PRIVATE.ON_SPECTATOR_MAP then
		return false
	end

	PRIVATE.LAST_REPLAY_ID = replayID
--	PRIVATE.AWAIT_ASMSG_AR_WATCH = true
	SendServerMessage("ACMSG_AR_WATCH", replayID)

	return true
end

function C_ArenaSpectator.GetLastReplayID()
	return PRIVATE.LAST_REPLAY_ID
end

function C_ArenaSpectator.SendReport(reason)
	if type(reason) ~= "string" then
		error(strformat("bad argument #1 to 'C_ArenaSpectator.SendReport' (string expected, got %s)", reason ~= nil and type(reason) or "no value"), 2)
	end

	reason = strtrim(reason)

	local len = utf8len(reason)
	if len == 0 or len > 500 then
		return false
	end

	if not PRIVATE.IsActive()
	or PRIVATE.AWAIT_ASMSG_AR_CLAIM
	then
		return false
	end

	PRIVATE.AWAIT_ASMSG_AR_CLAIM = true
	SendServerMessage("ACMSG_AR_CLAIM", PRIVATE.FIGHT_TIME or 0, reason)

	return true
end