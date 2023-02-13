Enum.MiniGames = {}
Enum.MiniGames.ScoreboardType = {
	Default = 0,
	Role = 1,
}

local MINI_GAMES_INFO = {
	{
		gameName = "FRAGILEFLOOR",
		icon = "Interface\\Icons\\Inv_radientazeritematrix",
		background = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER",
		mapAreaID = 957,
		scoreboardType = Enum.MiniGames.ScoreboardType.Default,
		defaultSortField = "seconds",
		stats = {
			{name = "name", text = MINI_GAME_STAT_NAME, icon = "", tooltip = "", width = 200, alignment = "LEFT"},
			{name = "position", text = MINI_GAME_STAT_POSITION, icon = "", tooltip = "", width = 48, default = true},
			{name = "stat1", text = MINI_GAME_STAT_FRAGILEFLOOR_PLATFORMS, icon = "", tooltip = "", width = 92},
			{name = "time", text = MINI_GAME_STAT_TIME, icon = "", tooltip = "", width = 92, sortType = "seconds"},
		},
	},
	{
		gameName = "FROZEN_SNOWMAN_LAIR_STORY",
		icon = "Interface\\Icons\\Achievement_challengemode_scholomance_gold",
		background = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER",
		mapAreaID = 932,
		scoreboardType = Enum.MiniGames.ScoreboardType.Role,
		stats = {
			{name = "name", text = MINI_GAME_STAT_NAME},
			{name = "stat1", text = MINI_GAME_STAT_SNOWMAN_ARMOR, type = "SNOWMAN_ARMOR"},
			{name = "role", text = MINI_GAME_STAT_ROLE, type = "ROLE"},
		},
	},
	{
		gameName = "FROZEN_SNOWMAN_LAIR_SURVIVAL",
		icon = "Interface\\Icons\\inv_10_jewelcrafting_gem3primal_frost_cut_blue",
		background = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER",
		mapAreaID = 932,
		scoreboardType = Enum.MiniGames.ScoreboardType.Role,
		stats = {
			{name = "name", text = MINI_GAME_STAT_NAME},
			{name = "stat1", text = MINI_GAME_STAT_SNOWMAN_ARMOR, type = "SNOWMAN_ARMOR"},
			{name = "role", text = MINI_GAME_STAT_ROLE, type = "ROLE"},
		},
	},
};

local MINI_GAME_STAT_TYPES = {
	ROLE = {
		[0] = "none",
		[1] = "tank",
		[2] = "damager",
		[3] = "healer",
	},
	SNOWMAN_ARMOR = {
		[0] = MINI_GAME_STAT_VALUE_NONE,
		[1] = SHARED_WARRIOR_MALE,
		[2] = SHARED_PALADIN_MALE,
		[3] = UNKNOWN,
		[4] = SHARED_ROGUE_MALE,
		[5] = SHARED_PRIEST_MALE,
		[6] = SHARED_DEATHKNIGHT_MALE,
		[7] = SHARED_SHAMAN_MALE,
		[8] = SHARED_MAGE_MALE,
		[9] = SHARED_WARLOCK_MALE,
		[11] = MINI_GAME_STAT_VALUE_SHREDDER,
	},
}

local AVAILABLE_MINI_GAMES = {};
local RECEIVED_MINI_GAMES = {};
local MINI_GAMES_LIST = {};

local MINI_GAME_SCORE_SORT_TYPE = nil;
local MINI_GAME_SCORE_SORT_TYPE_DEFAULT = nil;
local MINI_GAME_SCORE_SORT_REVERSE = false;

local MINI_GAME_SCORE_DATA = {};
local MINI_GAME_WINNERS = {};
local MINI_GAME_FILLUP_STATUS

local MINI_GAME_INVITE_ID;
local MINI_GAME_INVITE_GAME_ID;
local MINI_GAME_INVITE_MAX_PLAYERS;
local MINI_GAME_INVITE_ACCEPTED_PLAYERS;

local MINI_GAMES_QUEUE_STATUS = {
	[-1] = "error",
	[0] = "none",
	[1] = "queued",
	[2] = "confirm",
	[3] = "active",
	[4] = "locked",
};

local MAX_MINI_GAMES_QUEUES = 8;
local MINI_GAMES_QUEUES = {};
local ACTIVE_MINI_GAME_ID;

local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		SendServerMessage("ACMSG_MG_LIST_AVAILABLE_REQUEST");
	elseif event == "PLAYER_ENTERING_WORLD" then
		table.wipe(MINI_GAME_SCORE_DATA);
		table.wipe(MINI_GAME_WINNERS);

		frame:RegisterEvent("WORLD_MAP_UPDATE");
	elseif event == "WORLD_MAP_UPDATE" then
		frame:UnregisterEvent(event);

		local currentMapAreaID = GetCurrentMapAreaID();

		for _, miniGame in ipairs(MINI_GAMES_INFO) do
			if miniGame.stats and miniGame.mapAreaID and miniGame.mapAreaID == currentMapAreaID then
				SendServerMessage("ACMSG_MG_LOG_DATA");
				break;
			end
		end
	end
end);

local function secondsToTime(seconds)
	seconds = floor(seconds);

	local tempTime = floor(seconds / 60);
	local time = format(MINUTES_ABBR, tempTime);
	seconds = mod(seconds, 60);

	time = strconcat(time, TIME_UNIT_DELIMITER);
	time = strconcat(time, format(SECONDS_ABBR, format("%d", seconds)));

	return time;
end

local function sortByScoreType(a, b)
	local sortType = MINI_GAME_SCORE_SORT_TYPE or MINI_GAME_SCORE_SORT_TYPE_DEFAULT;

	if a[sortType] and b[sortType] then
		if MINI_GAME_SCORE_SORT_REVERSE then
			return a[sortType] > b[sortType];
		else
			return a[sortType] < b[sortType];
		end
	end

	return MINI_GAME_SCORE_SORT_REVERSE and b[sortType] ~= nil or a[sortType] ~= nil;
end

C_MiniGames = {};

function C_MiniGames.GetGameInfo(miniGameID)
	if type(miniGameID) == "string" then
		miniGameID = tonumber(miniGameID);
	end
	if type(miniGameID) ~= "number" then
		error("Usage: local name, description, icon, background, objective, maxPlayers, gameName, mapAreaID = C_MiniGames.GetGameInfo(miniGameID)", 2);
	end

	local miniGame = MINI_GAMES_INFO[miniGameID];
	if not miniGame then
		return;
	end

	if not RECEIVED_MINI_GAMES[miniGameID] then
		SendServerMessage("ACMSG_MG_INFO_REQUEST", miniGameID);

		RECEIVED_MINI_GAMES[miniGameID] = true;
	end

	return miniGame.name, miniGame.description, miniGame.icon, miniGame.background, miniGame.objective, miniGame.maxPlayers, miniGame.gameName, miniGame.mapAreaID;
end

function C_MiniGames.GetGameRewards(miniGameID)
	if type(miniGameID) == "string" then
		miniGameID = tonumber(miniGameID);
	end
	if type(miniGameID) ~= "number" then
		error("Usage: rewards = C_MiniGames.GetGameRewards(miniGameID)", 2);
	end

	local miniGame = MINI_GAMES_INFO[miniGameID];
	if not miniGame then
		return;
	end

	local rewards = {};

	if miniGame.rewards then
		for i = 1, #miniGame.rewards do
			local rewardInfo = miniGame.rewards[i];

			rewards[#rewards + 1] = {
				itemID = rewardInfo.itemID,
				itemCount = rewardInfo.itemCount,
			}
		end
	end

	return miniGame.doneToday, miniGame.money or 0, rewards;
end

function C_MiniGames.GetNumGames()
	return #MINI_GAMES_LIST;
end

function C_MiniGames.QueueJoin(miniGameID, isGroup)
	if type(miniGameID) == "string" then
		miniGameID = tonumber(miniGameID);
	end
	if type(miniGameID) ~= "number" then
		error("Usage: C_MiniGames.QueueJoin(miniGameID, isGroup)", 2);
	end

	SendServerMessage("ACMSG_MG_QUEUE_JOIN_REQUEST", string.format("%d:%d", miniGameID, isGroup and 1 or 0));
end

function C_MiniGames.QueueLeave(queueIndex)
	if type(queueIndex) == "string" then
		queueIndex = tonumber(queueIndex);
	end
	if type(queueIndex) ~= "number" then
		error("Usage: C_MiniGames.QueueLeave(queueIndex)", 2);
	end

	SendServerMessage("ACMSG_MG_QUEUE_LEAVE", queueIndex);
end

function C_MiniGames.GetQueueInfo(queueIndex)
	if type(queueIndex) == "string" then
		queueIndex = tonumber(queueIndex);
	end
	if type(queueIndex) ~= "number" then
		error("Usage: local status, name, id = C_MiniGames.GetQueueInfo(queueIndex)", 2);
	end

	local queueInfo = MINI_GAMES_QUEUES[queueIndex];
	if queueInfo then
		return queueInfo.status, queueInfo.name, queueInfo.id;
	end
end

function C_MiniGames.GetQueueEstimatedWaitTime(queueIndex)
	if type(queueIndex) == "string" then
		queueIndex = tonumber(queueIndex);
	end
	if type(queueIndex) ~= "number" then
		error("Usage: local estimatedWaitTime = C_MiniGames.GetQueueEstimatedWaitTime(queueIndex)", 2);
	end

	local queueInfo = MINI_GAMES_QUEUES[queueIndex];
	if queueInfo then
		return queueInfo.estimatedWaitTime or 0;
	end
end

function C_MiniGames.GetQueueTimeWaited(queueIndex)
	if type(queueIndex) == "string" then
		queueIndex = tonumber(queueIndex);
	end
	if type(queueIndex) ~= "number" then
		error("Usage: local timeWaited = C_MiniGames.GetQueueTimeWaited(queueIndex)", 2);
	end

	local queueInfo = MINI_GAMES_QUEUES[queueIndex];
	if queueInfo and queueInfo.timeWaited then
		return (GetTime() - queueInfo.timeWaited) * 1000;
	end
end

function C_MiniGames.GetQueuePortExpiration(queueIndex)
	if type(queueIndex) == "string" then
		queueIndex = tonumber(queueIndex);
	end
	if type(queueIndex) ~= "number" then
		error("Usage: local portExpiration = C_MiniGames.GetQueuePortExpiration(queueIndex)", 2);
	end

	local queueInfo = MINI_GAMES_QUEUES[queueIndex];
	if queueInfo and queueInfo.portExpiration then
		return queueInfo.portExpiration - GetTime();
	end
end

function C_MiniGames.GetInstanceExpiration()
	for i = 1, MAX_MINI_GAMES_QUEUES do
		local queueInfo = MINI_GAMES_QUEUES[i];

		if queueInfo and queueInfo.status == "active" and queueInfo.instanceExpiration then
			return (GetTime() - queueInfo.instanceExpiration) * 1000;
		end
	end

	return 0;
end

function C_MiniGames.GetInstanceRunTime()
	for i = 1, MAX_MINI_GAMES_QUEUES do
		local queueInfo = MINI_GAMES_QUEUES[i];

		if queueInfo and queueInfo.status == "active" and queueInfo.instanceRunTime then
			if queueInfo.instanceExpiration then
				return queueInfo.instanceRunTime;
			else
				return (queueInfo.instanceRunTime + GetTime()) * 1000;
			end
		end
	end

	return 0;
end

function C_MiniGames.GetMaxQueues()
	return MAX_MINI_GAMES_QUEUES;
end

function C_MiniGames.AcceptInvite(inviteID)
	if type(inviteID) == "string" then
		inviteID = tonumber(inviteID);
	end
	if type(inviteID) ~= "number" then
		error("Usage: C_MiniGames.AcceptInvite(inviteID)", 2);
	end

	SendServerMessage("ACMSG_MG_ACCEPT_INVITE", inviteID);
end

function C_MiniGames.DeclineInvite(inviteID)
	if type(inviteID) == "string" then
		inviteID = tonumber(inviteID);
	end
	if type(inviteID) ~= "number" then
		error("Usage: C_MiniGames.DeclineInvite(inviteID)", 2);
	end

	SendServerMessage("ACMSG_MG_DECLINE_INVITE", inviteID);
end

function C_MiniGames.Leave()
	SendServerMessage("ACMSG_MG_LEAVE");
end

function C_MiniGames.RequestScoreData()
	SendServerMessage("ACMSG_MG_LOG_DATA");
end

function C_MiniGames.GetScoreboardType()
	if ACTIVE_MINI_GAME_ID and MINI_GAMES_INFO[ACTIVE_MINI_GAME_ID] then
		return MINI_GAMES_INFO[ACTIVE_MINI_GAME_ID].scoreboardType or Enum.MiniGames.ScoreboardType.Default
	end
	return Enum.MiniGames.ScoreboardType.Default
end

function C_MiniGames.GetStatColumns()
	local statColumns = {};

	local game = ACTIVE_MINI_GAME_ID and MINI_GAMES_INFO[ACTIVE_MINI_GAME_ID]
	if game and game.scoreboardType == Enum.MiniGames.ScoreboardType.Default then
		for index, stat in ipairs(game.stats) do
			statColumns[index] = {
				name = stat.name,
				sortType = stat.sortType,
				text = stat.text,
				icon = stat.icon,
				tooltip = stat.tooltip,
				width = stat.width,
				alignment = stat.alignment,
			}
		end
	end

	return statColumns;
end

function C_MiniGames.GetNumScores()
	return ACTIVE_MINI_GAME_ID and #MINI_GAME_SCORE_DATA or 0
end

function C_MiniGames.GetScore(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local score = C_MiniGames.GetScore(index)", 2);
	end

	local game = ACTIVE_MINI_GAME_ID and MINI_GAMES_INFO[ACTIVE_MINI_GAME_ID]
	if game then
		local scoreData = MINI_GAME_SCORE_DATA[index];
		if scoreData then
			return {
				name = scoreData.name,
				position = scoreData.position,
				seconds = scoreData.seconds,
				time = scoreData.seconds and secondsToTime(scoreData.seconds) or nil,
				stat1 = scoreData.stat1,
				role = scoreData.role,
			};
		end
	end
end

function C_MiniGames.SortScoreData(sortType)
	if type(sortType) ~= "string" then
		error("Usage: C_MiniGames.SortScoreData(sortType)", 2);
	end

	local game = ACTIVE_MINI_GAME_ID and MINI_GAMES_INFO[ACTIVE_MINI_GAME_ID]
	if game and game.scoreboardType == Enum.MiniGames.ScoreboardType.Default then
		if MINI_GAME_SCORE_SORT_TYPE ~= sortType then
			MINI_GAME_SCORE_SORT_REVERSE = false;
		else
			MINI_GAME_SCORE_SORT_REVERSE = not MINI_GAME_SCORE_SORT_REVERSE;
		end

		MINI_GAME_SCORE_SORT_TYPE = sortType;

		table.sort(MINI_GAME_SCORE_DATA, sortByScoreType);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.UPDATE_MINI_GAME_SCORE);
	end
end

function C_MiniGames.GetNumWinners()
	return #MINI_GAME_WINNERS;
end

function C_MiniGames.GetWinners()
	return unpack(MINI_GAME_WINNERS);
end

function C_MiniGames.IsWinner(name)
	return tIndexOf(MINI_GAME_WINNERS, name) ~= nil;
end

function C_MiniGames.GetActiveID()
	return ACTIVE_MINI_GAME_ID;
end

function C_MiniGames.IsFillupActive()
	return ACTIVE_MINI_GAME_ID and MINI_GAME_FILLUP_STATUS == 1 or false
end

function C_MiniGames.GetInviteID()
	return MINI_GAME_INVITE_ID, MINI_GAME_INVITE_GAME_ID, MINI_GAME_INVITE_ACCEPTED_PLAYERS, MINI_GAME_INVITE_MAX_PLAYERS;
end

function EventHandler:ASMSG_MG_QUEUE_ACCEPT(msg)

end

local JOIN_ERRORS = {
	[0] = MINI_GAME_ERR_NOT_ELIGIBLE,
	[-1] = MINI_GAME_ERR_CANT_USE_IN_LFG,
	[-2] = MINI_GAME_ERR_PARTY_SIZE_TOO_BIG,
	[-3] = MINI_GAME_ERR_JOIN_FAILED,
	[-4] = MINI_GAME_ERR_TOO_MANY_QUEUES,
	[-5] = MINI_GAME_ERR_SECOND_WINDOW,
	[-6] = MINI_GAME_ERR_CANT_USE_IN_BG,
}

function EventHandler:ASMSG_MG_QUEUE_JOIN_ERR(msg)
	local errorID = tonumber(msg);

	local errorMsg = JOIN_ERRORS[errorID];
	if errorMsg then
		UIErrorsFrame:AddMessage(errorMsg, 1.0, 0.1, 0.1, 1.0)
	end
end

function EventHandler:ASMSG_MG_STATUS(msg)
	local statusData = C_Split(msg, ";");

	local index = tonumber(statusData[1]);
	local statusID = tonumber(statusData[2]);

	if index and statusID then
		local queueInfo = MINI_GAMES_QUEUES[index] or {};

		queueInfo.name = string.format(MINI_GAME_QUEUE_NAME, statusData[3] or "");
		queueInfo.status = MINI_GAMES_QUEUE_STATUS[statusID or -1];
		queueInfo.id = tonumber(statusData[4]);
		queueInfo.portExpiration = nil;
		queueInfo.instanceRunTime = nil;
		queueInfo.instanceExpiration = nil;

		if statusID == 1 then
			queueInfo.estimatedWaitTime = tonumber(statusData[5]) or 0;
			queueInfo.timeWaited = GetTime() - ((tonumber(statusData[6]) or 0) / 1000);
		elseif statusID == 2 then
			queueInfo.portExpiration = GetTime() + ((tonumber(statusData[5]) or 0) / 1000);
		elseif statusID == 3 then
			local instanceExpiration = tonumber(statusData[5]) or 0;
			if instanceExpiration > 0 then
				queueInfo.instanceExpiration = GetTime() - (instanceExpiration / 1000);
			end
			local instanceRunTime = tonumber(statusData[6]) or 0;
			if instanceRunTime > 0 then
				if queueInfo.instanceExpiration then
					queueInfo.instanceRunTime = instanceRunTime;
				else
					queueInfo.instanceRunTime = (instanceRunTime / 1000) - GetTime();
				end
			end

			ACTIVE_MINI_GAME_ID = queueInfo.id;
		end

		MINI_GAMES_QUEUES[index] = queueInfo;
	elseif MINI_GAMES_QUEUES[index] then
		if MINI_GAMES_QUEUES[index].id == ACTIVE_MINI_GAME_ID then
			ACTIVE_MINI_GAME_ID = nil;
		end

		MINI_GAMES_QUEUES[index] = nil;
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.UPDATE_MINI_GAMES_STATUS, index);
end

function EventHandler:ASMSG_SEND_MG_INVITE(msg)
	local miniGameID, inviteID, remainingTime = strsplit(":", msg);
	miniGameID, inviteID, remainingTime = tonumber(miniGameID), tonumber(inviteID), tonumber(remainingTime);

	if miniGameID and inviteID then
		MINI_GAME_INVITE_ID = inviteID;
		MINI_GAME_INVITE_GAME_ID = miniGameID;
		MINI_GAME_INVITE_ACCEPTED_PLAYERS = nil;
		MINI_GAME_INVITE_MAX_PLAYERS = nil;

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.MINI_GAME_INVITE, miniGameID, inviteID, remainingTime);
	end
end

function EventHandler:ASMSG_SEND_MG_INVITE_STATUS(msg)
	local isPlayerReady, acceptedPlayers, maxPlayers = strsplit(":", msg);
	acceptedPlayers, maxPlayers = tonumber(acceptedPlayers), tonumber(maxPlayers);

	isPlayerReady = isPlayerReady == "1"

	if isPlayerReady then
		MINI_GAME_INVITE_ID = nil;
	end

	if acceptedPlayers and maxPlayers then
		MINI_GAME_INVITE_ACCEPTED_PLAYERS = acceptedPlayers;
		MINI_GAME_INVITE_MAX_PLAYERS = maxPlayers;
		MINI_GAME_INVITE_PLAYER_READY = isPlayerReady;
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.MINI_GAME_INVITE_STATUS, isPlayerReady, acceptedPlayers, maxPlayers);
end

function EventHandler:ASMSG_SEND_MG_INVITE_ACCEPT()
	MINI_GAME_INVITE_ID = nil;
	MINI_GAME_INVITE_GAME_ID = nil;
	MINI_GAME_INVITE_ACCEPTED_PLAYERS = nil;
	MINI_GAME_INVITE_MAX_PLAYERS = nil;

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.MINI_GAME_INVITE_ACCEPT);
end

function EventHandler:ASMSG_SEND_MG_INVITE_ABADDON()
	MINI_GAME_INVITE_ID = nil;
	MINI_GAME_INVITE_GAME_ID = nil;
	MINI_GAME_INVITE_ACCEPTED_PLAYERS = nil;
	MINI_GAME_INVITE_MAX_PLAYERS = nil;

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.MINI_GAME_INVITE_ABADDON);
end

function EventHandler:ASMSG_MG_LIST_AVAILABLE(msg)
	local availableMiniGames = C_Split(msg, ":");

	table.wipe(AVAILABLE_MINI_GAMES)
	table.wipe(MINI_GAMES_LIST)

	for i = 1, #availableMiniGames do
		local miniGameID = tonumber(availableMiniGames[i]);

		if miniGameID then
			AVAILABLE_MINI_GAMES[miniGameID] = true;

			if MINI_GAMES_INFO[miniGameID] then
				MINI_GAMES_LIST[#MINI_GAMES_LIST + 1] = miniGameID;
			end
		end
	end

	table.sort(MINI_GAMES_LIST);

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.UPDATE_AVAILABLE_MINI_GAMES);
end

function EventHandler:ASMSG_MG_INFO(msg)
	local miniGameData = C_Split(msg, "|");

	local miniGameID = tonumber(miniGameData[1]);
	if miniGameID then
		local miniGameInfo = MINI_GAMES_INFO[miniGameID];
		if miniGameInfo then
			miniGameInfo.doneToday = tonumber(miniGameData[2]) == 1;
			miniGameInfo.name = miniGameData[3];
			miniGameInfo.description = miniGameData[4];
			miniGameInfo.objective = miniGameData[5];

			if not miniGameInfo.rewards then
				miniGameInfo.rewards = {};
			else
				table.wipe(miniGameInfo.rewards);
			end

			for i = 6, 11, 2 do
				local itemID = tonumber(miniGameData[i]);
				local itemCount = tonumber(miniGameData[i + 1]);

				if itemID and itemID ~= 0 then
					miniGameInfo.rewards[#miniGameInfo.rewards + 1] = {
						itemID = itemID,
						itemCount = itemCount or 0
					};
				end
			end

			miniGameInfo.money = tonumber(miniGameData[12]);
			miniGameInfo.maxPlayers = tonumber(miniGameData[13]);

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.UPDATE_MINI_GAME, miniGameID);
		end
	end
end

function EventHandler:ASMSG_MG_LOST()
	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.MINI_GAME_LOST);
end

function EventHandler:ASMSG_MG_WON()
	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.MINI_GAME_WON);
end

function EventHandler:ASMSG_MG_EVENT_START_TIMER(msg)
	if self.ASMSG_BG_EVENT_START_TIMER then
		local timeLeft, shortType = string.split(":", msg)
		self:ASMSG_BG_EVENT_START_TIMER(string.format("%s:%i", timeLeft, shortType == "1" and 3 or 2));
	end
end

local SORT_LOG_DATA = {};
local SORT_WINNERS_DICT = {}
local SORT_DEFAULT_FIELD

local function sortByWinnerTime(a, b)
	if #MINI_GAME_WINNERS > 0 then
		local aNameIsWinner = SORT_WINNERS_DICT[MINI_GAME_SCORE_DATA[a].name];
		local bNameIsWinner = SORT_WINNERS_DICT[MINI_GAME_SCORE_DATA[b].name];

		if aNameIsWinner and not bNameIsWinner then
			return true
		elseif not aNameIsWinner and bNameIsWinner then
			return false
		end
	end

	if MINI_GAME_SCORE_DATA[a][SORT_DEFAULT_FIELD] ~= MINI_GAME_SCORE_DATA[b][SORT_DEFAULT_FIELD] then
		return (MINI_GAME_SCORE_DATA[a][SORT_DEFAULT_FIELD] or 0) > (MINI_GAME_SCORE_DATA[b][SORT_DEFAULT_FIELD] or 0);
	end

	return MINI_GAME_SCORE_DATA[a].name < MINI_GAME_SCORE_DATA[b].name;
end

local SORTED_ROLES = {["tank"] = 1, ["damager"] = 2, ["healer"] = 3, ["none"] = 4}
local function sortByRole(a, b)
	local aRoleOrder = SORTED_ROLES[a.role]
	local bRoleOrder = SORTED_ROLES[b.role]

	if aRoleOrder ~= bRoleOrder then
		return aRoleOrder < bRoleOrder
	end

	return a.name < b.name
end

local function processLogMessage(logMessage)
	table.wipe(MINI_GAME_SCORE_DATA);
	table.wipe(MINI_GAME_WINNERS);

	local gameID, fillupStatus
	gameID, fillupStatus, logMessage = string.split(":", logMessage, 3);
	gameID = tonumber(gameID)

	local game = gameID and MINI_GAMES_INFO[gameID];
	if game then
		if game.scoreboardType == Enum.MiniGames.ScoreboardType.Default then
			local foundDefaultSortType;
			for i = 1, #game.stats do
				local statInfo = game.stats[i];
				if statInfo.default then
					MINI_GAME_SCORE_SORT_TYPE_DEFAULT = statInfo.sortType or statInfo.name;
					foundDefaultSortType = true;
					break;
				end
			end

			if not foundDefaultSortType then
				local firstStat = game.stats[1];
				MINI_GAME_SCORE_SORT_TYPE_DEFAULT = firstStat and firstStat.sortType or firstStat.name;
			end

			MINI_GAME_SCORE_SORT_TYPE = nil;
			MINI_GAME_SCORE_SORT_REVERSE = false;
		else
			MINI_GAME_SCORE_SORT_TYPE_DEFAULT = nil
			MINI_GAME_SCORE_SORT_TYPE = nil
			MINI_GAME_SCORE_SORT_REVERSE = nil
		end

		for entryIndex, entry in ipairs({string.split("|", logMessage)}) do
			local name, isWinner, statList = string.split(":", entry, 3)

			if isWinner == "1" then
				MINI_GAME_WINNERS[#MINI_GAME_WINNERS + 1] = name
			end

			if game.scoreboardType == Enum.MiniGames.ScoreboardType.Default then
				local stat1, seconds = string.split(":", statList)
				seconds = tonumber(seconds) or 0
				seconds = seconds > 0 and seconds or nil

				MINI_GAME_SCORE_DATA[entryIndex] = {
					name = name,
					stat1 = tonumber(stat1) or 0,
					seconds = seconds,
				};
			else
				local stat1, role = string.split(":", statList)

				stat1 = tonumber(stat1) or 0
				role = tonumber(role) or 0

				stat1 = MINI_GAME_STAT_TYPES.SNOWMAN_ARMOR[stat1]
				role = MINI_GAME_STAT_TYPES.ROLE[role]

				MINI_GAME_SCORE_DATA[entryIndex] = {
					name = name,
					stat1 = stat1,
					role = role,
				};
			end
		end

		ACTIVE_MINI_GAME_ID = gameID;
		MINI_GAME_FILLUP_STATUS = tonumber(fillupStatus)

		if game.scoreboardType == Enum.MiniGames.ScoreboardType.Default then
			table.wipe(SORT_LOG_DATA);
			table.wipe(SORT_WINNERS_DICT);

			local haveWinner = #MINI_GAME_WINNERS > 0
			for entryIndex, entry in ipairs(MINI_GAME_SCORE_DATA) do
				if haveWinner or entry.seconds then
					SORT_LOG_DATA[#SORT_LOG_DATA + 1] = entryIndex
				end
			end

			if #SORT_LOG_DATA > 0 then
				for index, name in ipairs(MINI_GAME_WINNERS) do
					SORT_WINNERS_DICT[name] = true
				end

				SORT_DEFAULT_FIELD = MINI_GAMES_INFO[ACTIVE_MINI_GAME_ID].defaultSortField or "name"
				table.sort(SORT_LOG_DATA, sortByWinnerTime);

				for entryIndex = 1, #SORT_LOG_DATA do
					if MINI_GAME_SCORE_DATA[SORT_LOG_DATA[entryIndex]][SORT_DEFAULT_FIELD] then
						MINI_GAME_SCORE_DATA[SORT_LOG_DATA[entryIndex]].position = entryIndex;
					end
				end
			end

			if MINI_GAME_SCORE_SORT_TYPE_DEFAULT then
				table.sort(MINI_GAME_SCORE_DATA, sortByScoreType);
			end
		elseif game.scoreboardType == Enum.MiniGames.ScoreboardType.Role then
			table.sort(MINI_GAME_SCORE_DATA, sortByRole)
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.UPDATE_MINI_GAME_SCORE);
end

local LOG_MESSAGES = {};
function EventHandler:ASMSG_MG_LOG_DATA(msg)
	LOG_MESSAGES[#LOG_MESSAGES + 1] = msg;

	local hasMessageDelimiter = string.sub(msg, -1) == "|";
	if not hasMessageDelimiter then
		local logMessage = table.concat(LOG_MESSAGES);
		table.wipe(LOG_MESSAGES);
		processLogMessage(logMessage)
	end
end