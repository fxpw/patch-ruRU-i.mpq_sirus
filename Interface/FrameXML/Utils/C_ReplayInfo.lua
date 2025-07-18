local error = error
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local type = type
local mathmax = math.max
local strformat, strsplit, strtrim = string.format, string.split, string.trim
local tinsert, twipe = table.insert, table.wipe
local utf8len, utf8lower = utf8.len, utf8.lower

local UnitName = UnitName

local CopyTable = CopyTable
local FireCustomClientEvent = FireCustomClientEvent
local GMError = GMError
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx

local GetLastInspectName = C_Inspect.GetLastInspectName

local REPLAY_INFO_SOURCE = {
	LADDER = 1,
	INSPECT = 2,
	META = 3,
}

local REPLAY_EVENT_LOADING = {
	[REPLAY_INFO_SOURCE.LADDER] = "LADDER_REPLAY_LIST_LOADING",
	[REPLAY_INFO_SOURCE.INSPECT] = "INSPECT_REPLAY_LIST_LOADING",
	[REPLAY_INFO_SOURCE.META] = "REPLAY_INFO_LOADING",
}

local REPLAY_EVENT_READY = {
	[REPLAY_INFO_SOURCE.LADDER] = "LADDER_REPLAY_LIST_UPDATE",
	[REPLAY_INFO_SOURCE.INSPECT] = "INSPECT_REPLAY_LIST_UPDATE",
	[REPLAY_INFO_SOURCE.META] = "REPLAY_INFO_RECIEVED",
}

local BRACKET_INFO = {
	[0] = {size = 3, locale = BRACKET_SOLO},
	[1] = {size = 2, locale = "2x2"},
	[2] = {size = 3, locale = "3x3"},
	[4] = {size = 5, locale = "5x5"},
	[5] = {size = 1, locale = "1x1"},
}

local PRIVATE = {
	REPLAY_DATA = {
		[REPLAY_INFO_SOURCE.LADDER] = {},
		[REPLAY_INFO_SOURCE.INSPECT] = {},
		[REPLAY_INFO_SOURCE.META] = {},
	},

	PRESERVE_DATA = false,

--	AWAIT_ASMSG_AR_SEND_META_INFO = nil,
--	AWAIT_ASMSG_AR_LAST_REPLAYS = nil,
--	AWAIT_ASMSG_AR_LAST_INSPECT_REPLAYS = nil,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if channel == "UNKNOWN" and sender == UnitName("player") then
			if PRIVATE[prefix] then
				PRIVATE[prefix](message)
			end
		end
	end
end)

PRIVATE.ParseReplayEntry = function(source, replayInfoStr, bracketID, requestPlayerName)
	local replayID, team1DataStr, team2DataStr, winnerTeamID, ratingDataStr = StringSplitEx(":", replayInfoStr)
	local team1Data = {strsplit(",", team1DataStr)}
	local team2Data = {strsplit(",", team2DataStr)}
	local team1Rating, team2Rating = strsplit(",", ratingDataStr)

	replayID = tonumber(replayID)
	winnerTeamID = tonumber(winnerTeamID)

	if source ~= REPLAY_INFO_SOURCE.META then
		if winnerTeamID == 2 then
			-- draw
			winnerTeamID = 0
		elseif winnerTeamID == 0 then
			team1Data, team2Data = team2Data, team1Data
			team1Rating, team2Rating = team2Rating, team1Rating
			winnerTeamID = 1
		else
			winnerTeamID = 2
		end
	end

	local replayInfo = {
		replayID 		= replayID,
		bracketID 		= bracketID,
		winnerTeamID 	= winnerTeamID,

		team1Rating = tonumber(team1Rating),
		team2Rating = tonumber(team2Rating),

		roster = {
			[1] = {},
			[2] = {},
		},
	}

	for i = 1, #team1Data, 2 do
		local team1PlayerName = team1Data[i]
		local team2PlayerName = team2Data[i]

		tinsert(replayInfo.roster[1], {
			name	= team1PlayerName,
			classID	= mathmax(1, tonumber(team1Data[i + 1]) or 1),
		})
		tinsert(replayInfo.roster[2], {
			name	= team2PlayerName,
			classID	= mathmax(1, tonumber(team2Data[i + 1]) or 1),
		})

		if source ~= REPLAY_INFO_SOURCE.META and requestPlayerName then
			if requestPlayerName == utf8lower(team1PlayerName) then
				replayInfo.playerTeamID = 1
			elseif requestPlayerName == utf8lower(team2PlayerName) then
				replayInfo.playerTeamID = 2
			end
		end
	end

	return replayInfo
end

PRIVATE.GenerateNamedStorage = function(source, playerName, bracketID)
	if not playerName or not bracketID then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[source]
	if not PRIVATE.PRESERVE_DATA then
		for name in pairs(storage) do
			if name ~= playerName then
				storage[name] = nil
			end
		end
	end
	if not storage[playerName] then
		storage[playerName] = {}
	end

	local bracketReplays = storage[playerName][bracketID]
	if bracketReplays then
		twipe(bracketReplays)
	else
		bracketReplays = {}
		storage[playerName][bracketID] = bracketReplays
	end

	return bracketReplays
end

PRIVATE.ASMSG_AR_SEND_META_INFO = function(msg)
	PRIVATE.AWAIT_ASMSG_AR_SEND_META_INFO = nil

	if msg == "" then
		local replayID = PRIVATE.REQUESTED_REPLAY_ID
		PRIVATE.REQUESTED_REPLAY_ID = nil
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.META], false, replayID)
		return
	end

	local bracketID, _, replayInfoStr = strsplit("|", msg)
	bracketID = tonumber(bracketID)

	local replayInfo = PRIVATE.ParseReplayEntry(REPLAY_INFO_SOURCE.META, replayInfoStr, bracketID, nil)

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.META]
	if not PRIVATE.PRESERVE_DATA then
		twipe(storage)
	end
	storage[replayInfo.replayID] = replayInfo

	if PRIVATE.REQUESTED_REPLAY_ID == replayInfo.replayID then
		PRIVATE.REQUESTED_REPLAY_ID = nil
	end

	FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.META], true, replayInfo.replayID)
end

PRIVATE.ASMSG_AR_LAST_REPLAYS = function(msg)
	PRIVATE.AWAIT_ACMSG_AR_LAST_REPLAYS = nil

	if msg == "" then
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.LADDER], false)
		return
	end

	local requestPlayerName = PRIVATE.ASMSG_AR_LAST_REPLAYS_PLAYER_NAME
	if requestPlayerName then
		requestPlayerName = utf8lower(requestPlayerName)
	else
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.LADDER], false)
		GMError("[ASMSG_AR_LAST_REPLAYS] data received without request for unknown player")
		return
	end

	local bracketID, replayListStr = strsplit("|", msg, 2)
	bracketID = tonumber(bracketID)

	local storage = PRIVATE.GenerateNamedStorage(REPLAY_INFO_SOURCE.LADDER, requestPlayerName, bracketID)

	if storage and replayListStr and replayListStr ~= "" then
		for index, replayInfoStr in ipairs({StringSplitEx("|", replayListStr)}) do
			storage[index] = PRIVATE.ParseReplayEntry(REPLAY_INFO_SOURCE.LADDER, replayInfoStr, bracketID, requestPlayerName)
		end

		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.LADDER], true)
	else
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.LADDER], false)
	end
end

PRIVATE.ASMSG_AR_LAST_INSPECT_REPLAYS = function(msg)
	if msg == "" then
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.INSPECT], false)
		return
	end

	local requestPlayerName = GetLastInspectName()
	if requestPlayerName then
		requestPlayerName = utf8lower(requestPlayerName)
	else
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.INSPECT], false)
		GMError("[ASMSG_AR_LAST_INSPECT_REPLAYS] data received without request for unknown player")
		return
	end

	local bracketID, replayListStr = strsplit("|", msg, 2)
	bracketID = tonumber(bracketID)

	local storage = PRIVATE.GenerateNamedStorage(REPLAY_INFO_SOURCE.INSPECT, requestPlayerName, bracketID)

	if storage and replayListStr and replayListStr ~= "" then
		for index, replayInfoStr in ipairs({StringSplitEx("|", replayListStr)}) do
			storage[index] = PRIVATE.ParseReplayEntry(REPLAY_INFO_SOURCE.INSPECT, replayInfoStr, bracketID, requestPlayerName)
		end

		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.INSPECT], true)
	else
		FireCustomClientEvent(REPLAY_EVENT_READY[REPLAY_INFO_SOURCE.INSPECT], false)
	end
end

PRIVATE.GetReplayInfo = function(replay)
	if replay and replay.roster then
		local bracketInfo = BRACKET_INFO[replay.bracketID]
		if not bracketInfo then
			bracketInfo = BRACKET_INFO[0]
		end

		return replay.replayID, replay.bracketID, bracketInfo.locale, bracketInfo.size, replay.winnerTeamID, replay.team1Rating, replay.team2Rating,
			replay.playerTeamID
	end
end

PRIVATE.GetReplayRosters = function(replay)
	if replay and replay.roster then
		return CopyTable(replay.roster[1]), CopyTable(replay.roster[2])
	end
end

C_ReplayInfo = {}

function C_ReplayInfo.RequestInfo(replayID)
	if type(replayID) ~= "number" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.RequestInfo' (number expected, got %s)", replayID ~= nil and type(replayID) or "no value"), 2)
	end

	if PRIVATE.AWAIT_ASMSG_AR_SEND_META_INFO then
		return false
	end

	PRIVATE.AWAIT_ASMSG_AR_SEND_META_INFO = true
	PRIVATE.REQUESTED_REPLAY_ID = replayID
	FireCustomClientEvent(REPLAY_EVENT_LOADING[REPLAY_INFO_SOURCE.META])
	SendServerMessage("ACMSG_AR_GET_META_INFO", replayID)

	return true
end

function C_ReplayInfo.GetReplayInfo(replayID)
	if type(replayID) ~= "number" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetReplayInfo' (number expected, got %s)", replayID ~= nil and type(replayID) or "no value"), 2)
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.META]
	local replayInfo = storage[replayID]
	if not replayInfo then
		return
	end

	return PRIVATE.GetReplayInfo(replayInfo)
end

function C_ReplayInfo.GetReplayRoster(replayID)
	if type(replayID) ~= "number" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetReplayRoster' (number expected, got %s)", replayID ~= nil and type(replayID) or "no value"), 2)
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.META]
	local replayInfo = storage[replayID]
	if not replayInfo then
		return
	end

	return PRIVATE.GetReplayRosters(replayInfo)
end

function C_ReplayInfo.RequestLadderReplays(playerName)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.RequestLadderReplays' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	end

	-- TODO len check
	playerName = strtrim(playerName)
	local len = utf8len(playerName)

	if PRIVATE.AWAIT_ACMSG_AR_LAST_REPLAYS then
		return false
	end

	PRIVATE.AWAIT_ACMSG_AR_LAST_REPLAYS = true
	PRIVATE.ASMSG_AR_LAST_REPLAYS_PLAYER_NAME = playerName
	FireCustomClientEvent(REPLAY_EVENT_LOADING[REPLAY_INFO_SOURCE.LADDER])
	SendServerMessage("ACMSG_AR_LAST_REPLAYS", playerName)

	return true
end

function C_ReplayInfo.GetNumLadderReplays(playerName, bracketID)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetNumLadderReplays' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	elseif type(bracketID) ~= "number" then
		error(strformat("bad argument #2 to 'C_ReplayInfo.GetNumLadderReplays' (number expected, got %s)", bracketID ~= nil and type(bracketID) or "no value"), 2)
	end

	playerName = utf8lower(strtrim(playerName))
	if playerName == "" then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.LADDER]
	local replayBrackets = storage[playerName]
	if replayBrackets then
		local replayList = replayBrackets[bracketID]
		if replayList then
			return #replayList
		end
	end

	return 0
end

function C_ReplayInfo.GetLadderReplayInfo(playerName, bracketID, index)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetLadderReplayInfo' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	elseif type(bracketID) ~= "number" then
		error(strformat("bad argument #2 to 'C_ReplayInfo.GetLadderReplayInfo' (number expected, got %s)", bracketID ~= nil and type(bracketID) or "no value"), 2)
	elseif type(index) ~= "number" then
		error(strformat("bad argument #3 to 'C_ReplayInfo.GetLadderReplayInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	end

	playerName = utf8lower(strtrim(playerName))
	if playerName == "" then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.LADDER]
	local replayBrackets = storage[playerName]
	if replayBrackets then
		local replayList = replayBrackets[bracketID]
		if replayList then
			local replayInfo = replayList[index]
			if replayInfo then
				return PRIVATE.GetReplayInfo(replayInfo)
			end
		end
	end
end

function C_ReplayInfo.GetLadderReplayRoster(playerName, bracketID, index)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetLadderReplayRoster' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	elseif type(bracketID) ~= "number" then
		error(strformat("bad argument #2 to 'C_ReplayInfo.GetLadderReplayRoster' (number expected, got %s)", bracketID ~= nil and type(bracketID) or "no value"), 2)
	elseif type(index) ~= "number" then
		error(strformat("bad argument #3 to 'C_ReplayInfo.GetLadderReplayRoster' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	end

	playerName = utf8lower(strtrim(playerName))
	if playerName == "" then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.LADDER]
	local replayBrackets = storage[playerName]
	if replayBrackets then
		local replayList = replayBrackets[bracketID]
		if replayList then
			local replayInfo = replayList[index]
			if replayInfo then
				return PRIVATE.GetReplayRosters(replayInfo)
			end
		end
	end
end

function C_ReplayInfo.GetNumInspectReplays(playerName, bracketID)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetNumInspectReplays' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	elseif type(bracketID) ~= "number" then
		error(strformat("bad argument #2 to 'C_ReplayInfo.GetNumInspectReplays' (number expected, got %s)", bracketID ~= nil and type(bracketID) or "no value"), 2)
	end

	playerName = utf8lower(strtrim(playerName))
	if playerName == "" then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.INSPECT]
	local replayBrackets = storage[playerName]
	if replayBrackets then
		local replayList = replayBrackets[bracketID]
		if replayList then
			return #replayList
		end
	end

	return 0
end

function C_ReplayInfo.GetInspectReplayInfo(playerName, bracketID, index)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetInspectReplayInfo' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	elseif type(bracketID) ~= "number" then
		error(strformat("bad argument #2 to 'C_ReplayInfo.GetInspectReplayInfo' (number expected, got %s)", bracketID ~= nil and type(bracketID) or "no value"), 2)
	elseif type(index) ~= "number" then
		error(strformat("bad argument #3 to 'C_ReplayInfo.GetInspectReplayInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	end

	playerName = utf8lower(strtrim(playerName))
	if playerName == "" then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.INSPECT]
	local replayBrackets = storage[playerName]
	if replayBrackets then
		local replayList = replayBrackets[bracketID]
		if replayList then
			local replayInfo = replayList[index]
			if replayInfo then
				return PRIVATE.GetReplayInfo(replayInfo)
			end
		end
	end
end

function C_ReplayInfo.GetInspectReplayRoster(playerName, bracketID, index)
	if type(playerName) ~= "string" then
		error(strformat("bad argument #1 to 'C_ReplayInfo.GetInspectReplayRoster' (string expected, got %s)", playerName ~= nil and type(playerName) or "no value"), 2)
	elseif type(bracketID) ~= "number" then
		error(strformat("bad argument #2 to 'C_ReplayInfo.GetInspectReplayRoster' (number expected, got %s)", bracketID ~= nil and type(bracketID) or "no value"), 2)
	elseif type(index) ~= "number" then
		error(strformat("bad argument #3 to 'C_ReplayInfo.GetInspectReplayRoster' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	end

	playerName = utf8lower(strtrim(playerName))
	if playerName == "" then
		return
	end

	local storage = PRIVATE.REPLAY_DATA[REPLAY_INFO_SOURCE.INSPECT]
	local replayBrackets = storage[playerName]
	if replayBrackets then
		local replayList = replayBrackets[bracketID]
		if replayList then
			local replayInfo = replayList[index]
			if replayInfo then
				return PRIVATE.GetReplayRosters(replayInfo)
			end
		end
	end
end