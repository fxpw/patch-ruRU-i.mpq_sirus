local _G = _G
local ipairs = ipairs
local tonumber = tonumber
local type = type
local error = error
local wipe = table.wipe
local tinsert = table.insert
local tsort = table.sort
local tconcat = table.concat
local bitbor = bit.bor
local bitband = bit.band
local bitbnot = bit.bnot
local bitlshift = bit.lshift
local strlower = strlower
local strtrim = strtrim
local strsplit = strsplit

local C_CacheInstance = C_CacheInstance
local CopyTable = CopyTable
local HARDCORE_CHALLENGES = HARDCORE_CHALLENGES

Enum.Hardcore = {}
Enum.Hardcore.Status = {
	Failed = 1,
	InProgress = 2,
	Completed = 3,
}
Enum.Hardcore.SortOrder = {
	Name = 1,
	Class = 2,
	Level = 3,
	Time = 4,
	Status = 5,
}
Enum.Hardcore.Features = {
	VIP										= 0x0000001,
	PREMIUM									= 0x0000002,
	WEEKEND_EXP								= 0x0000004,
	CRASH_SPELL								= 0x0000008,
	REBOOT_SPELL							= 0x0000010,
	RETURN_TO_VIP							= 0x0000020,
	RETURN_TO_PRIME							= 0x0000040,
	LILI_CHEST								= 0x0000080,
	COLLECTIONS								= 0x0000100,
	HEIRLOOM_EQUIP							= 0x0000200,
	TWINK_VENDOR							= 0x0000400,
	GAME_SHOP								= 0x0000800,
	SPECIAL_CLASS_SPELL						= 0x0001000,
	AUCTION									= 0x0002000,
	MAIL									= 0x0004000,
	DUEL									= 0x0008000,
	ASSISTANT								= 0x0010000,
	GUILD_BONUSES							= 0x0020000,
	FACTION_TENACITY						= 0x0040000,
	HARDCORE_FEATURE_LOTTERY				= 0x0080000,
}
Enum.Hardcore.Features1 = {
	GUILD_REPAIR							= 0x0000001,
	HC_PLAYERS_PARTY_POSSIBLE				= 0x0000002,
	NON_HC_PLAYERS_PARTY_BLOCK				= 0x0000004,
	HC_PLAYERS_TRADE_POSSIBLE				= 0x0000008,
	NON_HC_PLAYERS_TRADE_BLOCK				= 0x0000010,
	BATTLEGROUND							= 0x0000020,
	ARENA									= 0x0000040,
	MINIGAME								= 0x0000080,
	DUNGEON									= 0x0000100,
	HEADHUNTING								= 0x0000200,
	HC_PLAYERS_POS_INTER_POSSIBLE			= 0x0000400,
	NON_HC_PLAYERS_POS_INTER_BLOCK			= 0x0000800,
	DUNGEON_AVAILABLE						= 0x0001000,
	SERVER_XP_RATE							= 0x0002000,
	NON_HC_PLAYERS_PVP						= 0x0004000,
	HC_PLAYERS_PVP_WITHIN_5_LVL				= 0x0008000,
	BATTLEPASS_REWARDS						= 0x0010000,
	ACCOUNT_WIDE_SPELLS						= 0x0020000,
	GUILD									= 0x0040000,
	HARDCORE_FEATURE1_BLACK_MARKET			= 0x0080000,
}
Enum.Hardcore.FeaturesCustom = {
	GURUBASHI								= 0x0000001,
}
Enum.Hardcore.DeathSouce = {
	Exhausted = 0,
	Drowning = 1,
	Fall = 2,
	Lava = 3,
	Slime = 4,
	Fire = 5,
	FallToVoid = 6,
	NPC = 7,
	PVP = 8,
	FriendlyFire = 9,
}

local ENVIROMENTAL_DAMAGE = {
	[Enum.Hardcore.DeathSouce.Exhausted] = ACTION_ENVIRONMENTAL_DAMAGE_FATIGUE,
	[Enum.Hardcore.DeathSouce.Drowning] = ACTION_ENVIRONMENTAL_DAMAGE_DROWNING,
	[Enum.Hardcore.DeathSouce.Fall] = ACTION_ENVIRONMENTAL_DAMAGE_FALLING,
	[Enum.Hardcore.DeathSouce.Lava] = ACTION_ENVIRONMENTAL_DAMAGE_LAVA,
	[Enum.Hardcore.DeathSouce.Slime] = ACTION_ENVIRONMENTAL_DAMAGE_SLIME,
	[Enum.Hardcore.DeathSouce.Fire] = ACTION_ENVIRONMENTAL_DAMAGE_FIRE,
	[Enum.Hardcore.DeathSouce.FallToVoid] = ACTION_ENVIRONMENTAL_DAMAGE_FALLING,
}

local NUM_STATUSES = 3
local NUM_CLASSES = S_MAX_CLASSES

local CHALLENGE_INFO = {}
local CHALLENGES = {}
local PARTICIPANTS_LIST = {}
local LADDER_LIST = {}

local CHALLENGE_ICONS = {
	[1] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
}

for id, data in pairs(HARDCORE_CHALLENGES) do
	local flags, flags1, price, name, achievementID, items = unpack(data)

	CHALLENGE_INFO[id] = {
		id = id,
		name = name,
		icon = CHALLENGE_ICONS[id],
		flags = flags,
		flags1 = flags1,
		price = price,
		achievementID = achievementID,
		items = CopyTable(items),
	}

	CHALLENGES[#CHALLENGES + 1] = CHALLENGE_INFO[id]
end
tsort(CHALLENGES, function(a, b)
	return a.id < b.id
end)

local SELECTED_CHALLENGE = #CHALLENGES == 1 and 1 or nil

local SORT_NAMES = {
	[Enum.Hardcore.SortOrder.Name] = "name",
	[Enum.Hardcore.SortOrder.Class] = "class",
	[Enum.Hardcore.SortOrder.Level] = "level",
	[Enum.Hardcore.SortOrder.Time] = "time",
	[Enum.Hardcore.SortOrder.Status] = "status",
}

local PARTICIPANTS_SORT_INDEX = Enum.Hardcore.SortOrder.Level
local PARTICIPANTS_SORT_REVERSE = true
local PARTICIPANTS_SEARCH_FILTER = ""
local PARTICIPANTS_LEVEL_FILTER_MIN = 0
local PARTICIPANTS_LEVEL_FILTER_MAX = 0
local PARTICIPANTS_CLASS_FILTER = 0

local LEADERBOARD_SORT_INDEX = Enum.Hardcore.SortOrder.Time
local LEADERBOARD_SORT_REVERSE = false
local LEADERBOARD_SEARCH_FILTER = ""
local LEADERBOARD_LEVEL_FILTER_MIN = 0
local LEADERBOARD_LEVEL_FILTER_MAX = 0
local LEADERBOARD_STATUS_FILTER = 0
local LEADERBOARD_CLASS_FILTER = 0

C_Hardcore = {}

function C_Hardcore.GetActiveChallengeID()
	local challengeID = C_CacheInstance:Get("C_SERVICE_CHALLENGE_ID")
	if challengeID and challengeID ~= 0 then
		return challengeID
	end
end

function C_Hardcore.IsFeatureAvailable(flag)
	if type(flag) ~= "number" then
		error("Usage: C_Hardcore.IsFeatureAvailable(flag)", 2)
	end

	local challengeID = C_CacheInstance:Get("C_SERVICE_CHALLENGE_ID")
	if challengeID and challengeID ~= 0 then
		local challengeInfo = CHALLENGE_INFO[challengeID]
		if challengeInfo and challengeInfo.flags and bitband(challengeInfo.flags, flag) ~= 0 then
			return true
		end
	end
	return false
end

function C_Hardcore.IsFeature1Available(flag)
	if type(flag) ~= "number" then
		error("Usage: C_Hardcore.IsFeature1Available(flag)", 2)
	end

	local challengeID = C_CacheInstance:Get("C_SERVICE_CHALLENGE_ID")
	if challengeID and challengeID ~= 0 then
		local challengeInfo = CHALLENGE_INFO[challengeID]
		if challengeInfo and challengeInfo.flags1 and bitband(challengeInfo.flags1, flag) ~= 0 then
			return true
		end
	end
	return false
end

function C_Hardcore.GetSuggestions(suggestionTable)
	if type(suggestionTable) ~= "table" then
		error("Usage: C_Hardcore.GetSuggestions(suggestionTable)", 2)
	end

	wipe(suggestionTable)

	local index = 1
	local title = _G["HARDCORE_SUGGESTION_TITLE_"..index]
	while title do
		tinsert(suggestionTable, {
			title = title,
			description = _G["HARDCORE_SUGGESTION_DESCRIPTION_"..index],
			buttonText = index == 1 and NUM_ACTIVE_CHALLENGES_FORMAT:format(#CHALLENGES) or _G["HARDCORE_SUGGESTION_BUTTON_TEXT_"..index],
			iconPath = _G["HARDCORE_SUGGESTION_ICON_PATCH_"..index],
		})
		index = index + 1
		title = _G["HARDCORE_SUGGESTION_TITLE_"..index]
	end
end

function C_Hardcore.GetNumChallenges()
	return #CHALLENGES
end

function C_Hardcore.GetChallengeInfo(index)
	local challengeInfo = CHALLENGES[index]
	if challengeInfo then
		return challengeInfo.id, challengeInfo.name, challengeInfo.icon, challengeInfo.achievementID
	end
end

function C_Hardcore.GetChallengeInfoByID(challengeID)
	if type(challengeID) ~= "number" then
		error("Usage: C_Hardcore.GetChallengeInfoByID(challengeID)", 2)
	end

	local challengeInfo = CHALLENGE_INFO[challengeID]
	if challengeInfo then
		return challengeInfo.name, challengeInfo.id, challengeInfo.icon, challengeInfo.achievementID, nil, challengeInfo.price
	end
end

function C_Hardcore.GetChallengeDescriptionByID(challengeID)
	if type(challengeID) ~= "number" then
		error("Usage: C_Hardcore.GetChallengeDescriptionByID(challengeID)", 2)
	end

	local challengeInfo = CHALLENGE_INFO[challengeID]
	if challengeInfo then
		return _G[("HARDCORE_CHALLENGE_%d_DESCRIPTION"):format(challengeID)]
	end
end

function C_Hardcore.GetChallengeRewardsByID(challengeID)
	if type(challengeID) ~= "number" then
		error("Usage: C_Hardcore.GetChallengeRewardsByID(challengeID)", 2)
	end

	local rewards = {}
	local challengeInfo = CHALLENGE_INFO[challengeID]
	if challengeInfo and challengeInfo.items then
		for _, itemID in ipairs(challengeInfo.items) do
			rewards[#rewards + 1] = itemID
		end
	end
	return rewards
end

function C_Hardcore.GetChallengeFeaturesByID(challengeID)
	local features = {}
	local challengeInfo = CHALLENGE_INFO[challengeID]
	if challengeInfo then
		if challengeInfo.flags then
			for index = 1, 32 do
				if bitband(challengeInfo.flags, bitlshift(1, index - 1)) ~= 0 then
					features[#features + 1] = {
						index = index,
						name = _G[("HARDCORE_FEATURE_%d_NAME"):format(index)] or index,
					}
				end
			end
		end
	end
	return features
end

function C_Hardcore.GetChallengeFeatures1ByID(challengeID)
	local features = {}
	local challengeInfo = CHALLENGE_INFO[challengeID]
	if challengeInfo then
		if challengeInfo.flags1 then
			for index = 1, 32 do
				if bitband(challengeInfo.flags1, bitlshift(1, index - 1)) ~= 0 then
					features[#features + 1] = {
						index = index,
						name = _G[("HARDCORE_FEATURE1_%d_NAME"):format(index)] or index,
					}
				end
			end
		end
	end
	return features
end

function C_Hardcore.GetChallengeFeaturesCustomByID()
	local features = {}

	local index = 1
	local name = _G[("HARDCORE_FEATURE_CUSTOM_%d_NAME"):format(index)]
	while name do
		features[#features + 1] = {
			index = index,
			name = name,
		}
		index = index + 1
		name = _G[("HARDCORE_FEATURE_CUSTOM_%d_NAME"):format(index)]
	end

	return features
end

function C_Hardcore.GetFeatureDescription(featureIndex)
	if type(featureIndex) ~= "number" then
		error("Usage: C_Hardcore.GetFeatureDescription(featureIndex)", 2)
	end

	return _G[("HARDCORE_FEATURE_%d_DESCRIPTION"):format(featureIndex)]
end

function C_Hardcore.GetFeature1Description(featureIndex)
	if type(featureIndex) ~= "number" then
		error("Usage: C_Hardcore.GetFeature1Description(featureIndex)", 2)
	end

	return _G[("HARDCORE_FEATURE1_%d_DESCRIPTION"):format(featureIndex)]
end

function C_Hardcore.GetFeatureCustomDescription(featureIndex)
	if type(featureIndex) ~= "number" then
		error("Usage: C_Hardcore.GetFeatureCustomDescription(featureIndex)", 2)
	end

	return _G[("HARDCORE_FEATURE_CUSTOM_%d_DESCRIPTION"):format(featureIndex)]
end

function C_Hardcore.GetChallengeFinishConditionsByID(challengeID)
	if type(challengeID) ~= "number" then
		error("Usage: C_Hardcore.GetChallengeFinishConditionsByID(challengeID)", 2)
	end

	local challengeInfo = CHALLENGE_INFO[challengeID]
	if challengeInfo then
		local info = _G[("HARDCORE_CHALLENGE_%d_FINISH_INFO"):format(challengeID)]
		return info
	end
end

function C_Hardcore.SetSelectChallenge(index)
	if SELECTED_CHALLENGE ~= index then
		SELECTED_CHALLENGE = index

		FireCustomClientEvent("HARDCORE_SELECTED_CHALLENGE", index)
	end
end

function C_Hardcore.GetSelectedChallenge()
	return SELECTED_CHALLENGE
end

local FILTERED_PARTICIPANTS_LIST = {}
local function SortParticipants(a, b)
	local sortKey = SORT_NAMES[PARTICIPANTS_SORT_INDEX]

	if a[sortKey] and b[sortKey] then
		if a[sortKey] ~= b[sortKey] then
			if PARTICIPANTS_SORT_REVERSE then
				return a[sortKey] > b[sortKey]
			else
				return a[sortKey] < b[sortKey]
			end
		end
	end

	return (a.level or 0) < (b.level or 0)
end

local function SetSortParticipants(challengeID)
	if PARTICIPANTS_SORT_INDEX and FILTERED_PARTICIPANTS_LIST[challengeID] then
		tsort(FILTERED_PARTICIPANTS_LIST[challengeID], SortParticipants)
	end
end

local function FilteredParticipants()
	for challengeID, ladderList in pairs(PARTICIPANTS_LIST) do
		if not FILTERED_PARTICIPANTS_LIST[challengeID] then
			FILTERED_PARTICIPANTS_LIST[challengeID] = {}
		else
			wipe(FILTERED_PARTICIPANTS_LIST[challengeID])
		end

		for _, entry in ipairs(ladderList) do
			local classFlag = bitlshift(1, (entry.class or 1) - 1)

			if bitband(PARTICIPANTS_CLASS_FILTER, classFlag) ~= classFlag
				and (PARTICIPANTS_SEARCH_FILTER == "" or string.find(string.lower(entry.name or ""), PARTICIPANTS_SEARCH_FILTER, 1, true))
				and ((PARTICIPANTS_LEVEL_FILTER_MIN == 0 and PARTICIPANTS_LEVEL_FILTER_MAX == 0) or (entry.level >= PARTICIPANTS_LEVEL_FILTER_MIN and entry.level <= PARTICIPANTS_LEVEL_FILTER_MAX))
			then
				tinsert(FILTERED_PARTICIPANTS_LIST[challengeID], entry)
			end
		end

		SetSortParticipants(challengeID)
	end

	FireCustomClientEvent("HARDCORE_PARTICIPANTS_UPDATE")
end

function C_Hardcore.GetNumParticipantsEntries(challengeID)
	if FILTERED_PARTICIPANTS_LIST[challengeID] then
		return #FILTERED_PARTICIPANTS_LIST[challengeID]
	end
	return 0
end

function C_Hardcore.GetParticipantsEntry(challengeID, index)
	if not FILTERED_PARTICIPANTS_LIST[challengeID] then return end

	local entry = FILTERED_PARTICIPANTS_LIST[challengeID][index]
	if entry then
		return {
			name = entry.name,
			class = entry.class,
			race = entry.race,
			gender = entry.gender,
			level = entry.level,
		}
	end
end

function C_Hardcore.GetSortParticipants(challengeID)
	return PARTICIPANTS_SORT_INDEX, PARTICIPANTS_SORT_REVERSE
end

function C_Hardcore.SetSortParticipants(challengeID, sortIndex, reverse)
	if type(challengeID) == "string" then
		challengeID = tonumber(challengeID)
	end
	if type(sortIndex) == "string" then
		sortIndex = tonumber(sortIndex)
	end
	if type(challengeID) ~= "number" or type(sortIndex) ~= "number" then
		error("Usage: C_Hardcore.SetSortParticipants(challengeID, sortIndex)", 2)
	elseif not SORT_NAMES[sortIndex] then
		error("Usage: C_Hardcore.SetSortParticipants(challengeID, sortIndex)", 2)
	end

	PARTICIPANTS_SORT_INDEX = sortIndex
	PARTICIPANTS_SORT_REVERSE = reverse

	FilteredParticipants()
end

function C_Hardcore.SetParticipantsSearch(searchValue)
	PARTICIPANTS_SEARCH_FILTER = strlower(strtrim(searchValue or ""))

	FilteredParticipants()
end

function C_Hardcore.SetParticipantsLevelFilter(minLevel, maxLevel)
	if type(minLevel) ~= "number" or type(maxLevel) ~= "number" then
		error("Usage: C_Hardcore.SetParticipantsLevelFilter(minLevel, maxLevel)", 2)
	end

	PARTICIPANTS_LEVEL_FILTER_MIN = minLevel
	PARTICIPANTS_LEVEL_FILTER_MAX = maxLevel

	FilteredParticipants()
end

function C_Hardcore.SetParticipantsClassFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_Hardcore.SetParticipantsClassFilter(filterIndex, isChecked)", 2)
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked
	end

	if filterIndex > 0 and filterIndex <= NUM_CLASSES and filterIndex ~= 10 then
		if not isChecked then
			PARTICIPANTS_CLASS_FILTER = bitbor(PARTICIPANTS_CLASS_FILTER, bitlshift(1, filterIndex - 1))
		else
			PARTICIPANTS_CLASS_FILTER = bitband(PARTICIPANTS_CLASS_FILTER, bitbnot(bitlshift(1, filterIndex - 1)))
		end

		FilteredParticipants()
	end
end

function C_Hardcore.SetAllParticipantsClassFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_Hardcore.SetAllLeaderboardClassFilters(isChecked)", 2)
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked
	end

	for index = 1, NUM_CLASSES do
		if index ~= 10 then
			if not isChecked then
				PARTICIPANTS_CLASS_FILTER = bitbor(PARTICIPANTS_CLASS_FILTER, bitlshift(1, index - 1))
			else
				PARTICIPANTS_CLASS_FILTER = bitband(PARTICIPANTS_CLASS_FILTER, bitbnot(bitlshift(1, index - 1)))
			end
		end
	end

	FilteredParticipants()
end

function C_Hardcore.IsParticipantsClassChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_Hardcore.IsParticipantsClassChecked(filterIndex)", 2)
	end

	if bitband(PARTICIPANTS_CLASS_FILTER, bitlshift(1, filterIndex - 1)) ~= 0 then
		return false
	end

	return true
end

function C_Hardcore.IsValidParticipantsClassFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_Hardcore.IsValidParticipantsClassFilter(filterIndex)", 2)
	end

	if filterIndex <= 0 then
		return false
	elseif filterIndex == 10 then
		return false
	elseif filterIndex > NUM_CLASSES then
		return false
	end

	return true
end

function C_Hardcore.SetParticipantsDefaultFilters()
	PARTICIPANTS_SEARCH_FILTER = ""
	PARTICIPANTS_LEVEL_FILTER_MIN = 0
	PARTICIPANTS_LEVEL_FILTER_MAX = 0
	PARTICIPANTS_CLASS_FILTER = 0

	FilteredParticipants()
end

function C_Hardcore.IsUsingParticipantsDefaultFilters()
	if PARTICIPANTS_SEARCH_FILTER ~= ""
		or (PARTICIPANTS_LEVEL_FILTER_MIN ~= 0 and PARTICIPANTS_LEVEL_FILTER_MIN ~= 0)
		or PARTICIPANTS_CLASS_FILTER ~= 0
	then
		return false
	end

	return true
end

local FILTERED_LADDER_LIST = {}
local function SortLeaderboard(a, b)
	local sortKey = SORT_NAMES[LEADERBOARD_SORT_INDEX]

	if a[sortKey] and b[sortKey] then
		if a[sortKey] ~= b[sortKey] then
			if LEADERBOARD_SORT_REVERSE then
				return a[sortKey] > b[sortKey]
			else
				return a[sortKey] < b[sortKey]
			end
		end
	end

	return (a.time or 0) < (b.time or 0)
end

local function SetSortLeaderboard(challengeID)
	if LEADERBOARD_SORT_INDEX and FILTERED_LADDER_LIST[challengeID] then
		tsort(FILTERED_LADDER_LIST[challengeID], SortLeaderboard)
	end
end

local function FilteredLeaderboard()
	for challengeID, ladderList in pairs(LADDER_LIST) do
		if not FILTERED_LADDER_LIST[challengeID] then
			FILTERED_LADDER_LIST[challengeID] = {}
		else
			wipe(FILTERED_LADDER_LIST[challengeID])
		end

		for _, entry in ipairs(ladderList) do
			local statusFlag = bitlshift(1, (entry.status or 0) - 1)
			local classFlag = bitlshift(1, (entry.class or 1) - 1)

			if bitband(LEADERBOARD_STATUS_FILTER, statusFlag) ~= statusFlag
				and bitband(LEADERBOARD_CLASS_FILTER, classFlag) ~= classFlag
				and (LEADERBOARD_SEARCH_FILTER == "" or string.find(string.lower(entry.name or ""), LEADERBOARD_SEARCH_FILTER, 1, true))
				and ((LEADERBOARD_LEVEL_FILTER_MIN == 0 and LEADERBOARD_LEVEL_FILTER_MAX == 0) or (entry.level >= LEADERBOARD_LEVEL_FILTER_MIN and entry.level <= LEADERBOARD_LEVEL_FILTER_MAX))
			then
				tinsert(FILTERED_LADDER_LIST[challengeID], entry)
			end
		end

		SetSortLeaderboard(challengeID)
	end

	FireCustomClientEvent("HARDCORE_LADDER_UPDATE")
end

function C_Hardcore.GetNumLeaderboardEntries(challengeID)
	if FILTERED_LADDER_LIST[challengeID] then
		return #FILTERED_LADDER_LIST[challengeID]
	end
	return 0
end

function C_Hardcore.GetLeaderboardEntry(challengeID, index)
	if not FILTERED_LADDER_LIST[challengeID] then return end

	local entry = FILTERED_LADDER_LIST[challengeID][index]
	if entry then
		return {
			name = entry.name,
			class = entry.class,
			race = entry.race,
			gender = entry.gender,
			level = entry.level,
			time = entry.time,
			status = entry.status,
		}
	end
end

function C_Hardcore.GetSortLeaderboard(challengeID)
	return LEADERBOARD_SORT_INDEX, LEADERBOARD_SORT_REVERSE
end

function C_Hardcore.SetSortLeaderboard(challengeID, sortIndex, reverse)
	if type(challengeID) == "string" then
		challengeID = tonumber(challengeID)
	end
	if type(sortIndex) == "string" then
		sortIndex = tonumber(sortIndex)
	end
	if type(challengeID) ~= "number" or type(sortIndex) ~= "number" then
		error("Usage: C_Hardcore.SetSortLeaderboard(challengeID, sortIndex)", 2)
	elseif not SORT_NAMES[sortIndex] then
		error("Usage: C_Hardcore.SetSortLeaderboard(challengeID, sortIndex)", 2)
	end

	LEADERBOARD_SORT_INDEX = sortIndex
	LEADERBOARD_SORT_REVERSE = reverse

	FilteredLeaderboard()
end

function C_Hardcore.SetLeaderboardSearch(searchValue)
	LEADERBOARD_SEARCH_FILTER = strlower(strtrim(searchValue or ""))

	FilteredLeaderboard()
end

function C_Hardcore.SetLeaderboardLevelFilter(minLevel, maxLevel)
	if type(minLevel) ~= "number" or type(maxLevel) ~= "number" then
		error("Usage: C_Hardcore.SetLeaderboardLevelFilter(minLevel, maxLevel)", 2)
	end

	LEADERBOARD_LEVEL_FILTER_MIN = minLevel
	LEADERBOARD_LEVEL_FILTER_MAX = maxLevel

	FilteredLeaderboard()
end

function C_Hardcore.GetNumLeaderboardStatusFilters()
	return NUM_STATUSES
end

function C_Hardcore.SetLeaderboardStatusFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_Hardcore.SetLeaderboardStatusFilter(filterIndex, isChecked)", 2)
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked
	end

	if filterIndex > 0 and filterIndex <= NUM_STATUSES then
		if not isChecked then
			LEADERBOARD_STATUS_FILTER = bitbor(LEADERBOARD_STATUS_FILTER, bitlshift(1, filterIndex - 1))
		else
			LEADERBOARD_STATUS_FILTER = bitband(LEADERBOARD_STATUS_FILTER, bitbnot(bitlshift(1, filterIndex - 1)))
		end

		FilteredLeaderboard()
	end
end

function C_Hardcore.SetAllLeaderboardStatusFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_Hardcore.SetAllLeaderboardStatusFilters(isChecked)", 2)
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked
	end

	for index = 1, NUM_STATUSES do
		if not isChecked then
			LEADERBOARD_STATUS_FILTER = bitbor(LEADERBOARD_STATUS_FILTER, bitlshift(1, index - 1))
		else
			LEADERBOARD_STATUS_FILTER = bitband(LEADERBOARD_STATUS_FILTER, bitbnot(bitlshift(1, index - 1)))
		end
	end

	FilteredLeaderboard()
end

function C_Hardcore.IsLeaderboardStatusChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_Hardcore.IsLeaderboardStatusChecked(filterIndex)", 2)
	end

	if bitband(LEADERBOARD_STATUS_FILTER, bitlshift(1, filterIndex - 1)) ~= 0 then
		return false
	end

	return true
end

function C_Hardcore.IsValidLeaderboardStatusFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_Hardcore.IsValidLeaderboardStatusFilter(filterIndex)", 2)
	end

	if filterIndex <= 0 then
		return false
	elseif filterIndex == 2 then
		return false
	elseif filterIndex > NUM_STATUSES then
		return false
	end

	return true
end

function C_Hardcore.SetLeaderboardClassFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_Hardcore.SetLeaderboardClassFilter(filterIndex, isChecked)", 2)
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked
	end

	if filterIndex > 0 and filterIndex <= NUM_CLASSES and filterIndex ~= 10 then
		if not isChecked then
			LEADERBOARD_CLASS_FILTER = bitbor(LEADERBOARD_CLASS_FILTER, bitlshift(1, filterIndex - 1))
		else
			LEADERBOARD_CLASS_FILTER = bitband(LEADERBOARD_CLASS_FILTER, bitbnot(bitlshift(1, filterIndex - 1)))
		end

		FilteredLeaderboard()
	end
end

function C_Hardcore.SetAllLeaderboardClassFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_Hardcore.SetAllLeaderboardClassFilters(isChecked)", 2)
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked
	end

	for index = 1, NUM_CLASSES do
		if index ~= 10 then
			if not isChecked then
				LEADERBOARD_CLASS_FILTER = bitbor(LEADERBOARD_CLASS_FILTER, bitlshift(1, index - 1))
			else
				LEADERBOARD_CLASS_FILTER = bitband(LEADERBOARD_CLASS_FILTER, bitbnot(bitlshift(1, index - 1)))
			end
		end
	end

	FilteredLeaderboard()
end

function C_Hardcore.IsLeaderboardClassChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_Hardcore.IsLeaderboardClassChecked(filterIndex)", 2)
	end

	if bitband(LEADERBOARD_CLASS_FILTER, bitlshift(1, filterIndex - 1)) ~= 0 then
		return false
	end

	return true
end

function C_Hardcore.IsValidLeaderboardClassFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex)
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_Hardcore.IsValidLeaderboardClassFilter(filterIndex)", 2)
	end

	if filterIndex <= 0 then
		return false
	elseif filterIndex == 10 then
		return false
	elseif filterIndex > NUM_CLASSES then
		return false
	end

	return true
end

function C_Hardcore.SetLeaderboardDefaultFilters()
	LEADERBOARD_SEARCH_FILTER = ""
	LEADERBOARD_LEVEL_FILTER_MIN = 0
	LEADERBOARD_LEVEL_FILTER_MAX = 0
	LEADERBOARD_STATUS_FILTER = 0
	LEADERBOARD_CLASS_FILTER = 0

	FilteredLeaderboard()
end

function C_Hardcore.IsUsingLeaderboardDefaultFilters()
	if LEADERBOARD_SEARCH_FILTER ~= ""
		or (LEADERBOARD_LEVEL_FILTER_MIN ~= 0 and LEADERBOARD_LEVEL_FILTER_MAX ~= 0)
		or LEADERBOARD_STATUS_FILTER ~= 0
		or LEADERBOARD_CLASS_FILTER ~= 0
	then
		return false
	end

	return true
end

function C_Hardcore.GetEnviromentalDamageText(enviromentalDamage)
	if type(enviromentalDamage) == "string" then
		enviromentalDamage = tonumber(enviromentalDamage)
	end
	if type(enviromentalDamage) ~= "number" then
		error("Usage: C_Hardcore.GetEnviromentalDamageText(enviromentalDamage)", 2)
	end

	if ENVIROMENTAL_DAMAGE[enviromentalDamage] then
		return ENVIROMENTAL_DAMAGE[enviromentalDamage]
	end

	return UNKNOWN
end

C_HardcoreSecure = {}

function C_HardcoreSecure.StartChallenge(challengeID)
	if type(challengeID) ~= "number" then
		error("Usage: C_HardcoreSecure.StartChallenge(challengeID)", 2)
	end

	SendServerMessage("ACMSG_HARDCORE_CHALLENGE", challengeID)
end

function C_HardcoreSecure.CancelChallenge()
	SendServerMessage("ACMSG_REMOVE_HARDCORE", 3)
end

function C_HardcoreSecure.SaveCharacter()
	SendServerMessage("ACMSG_REMOVE_HARDCORE", 2)
end

local SPLIT_LIMIT = 1024
local function ProcessParticipantsListMessages(msg)
	for _, challengeMsg in ipairs({strsplit("|", msg)}) do
		local challengeID, entriesMessage = strsplit(":", challengeMsg, 2)
		challengeID = tonumber(challengeID)

		if not PARTICIPANTS_LIST[challengeID] then
			PARTICIPANTS_LIST[challengeID] = {}
		else
			wipe(PARTICIPANTS_LIST[challengeID])
		end

		if entriesMessage ~= "" then
			local entryList = {strsplit(";", entriesMessage, SPLIT_LIMIT)}
			local i = 1
			local entryMsg = entryList[i]
			while entryMsg do
				local charName, charClass, charRace, charGender, charLevel = strsplit(":", entryMsg, 5)

				if charGender ~= "0" then
					charGender = "1"
				end

				tinsert(PARTICIPANTS_LIST[challengeID], {
					name = charName,
					class = tonumber(charClass),
					race = E_CHARACTER_RACES[E_CHARACTER_RACES_DBC[tonumber(charRace)]],
					gender = tonumber(charGender),
					level = tonumber(charLevel),
				})

				i = i + 1
				if i == SPLIT_LIMIT and entryList[SPLIT_LIMIT] then
					entryList = {strsplit(";", entryList[SPLIT_LIMIT], SPLIT_LIMIT)}
					i = 1
				end
				entryMsg = entryList[i]
			end
		end
	end

	FilteredParticipants()
end

local PARTICIPANTS_LIST_MESSAGES = {}
function EventHandler:ASMSG_HARDCORE_PARTICIPANTS_LIST(msg)
	PARTICIPANTS_LIST_MESSAGES[#PARTICIPANTS_LIST_MESSAGES + 1] = msg

	local hasMessageDelimiter = string.sub(msg, -1) == ";"
	if not hasMessageDelimiter then
		local participantsListMessage = table.concat(PARTICIPANTS_LIST_MESSAGES)
		wipe(PARTICIPANTS_LIST_MESSAGES)
		ProcessParticipantsListMessages(participantsListMessage)
	end
end

local function ProcessLadderListMessages(msg)
	for _, challengeMsg in ipairs({strsplit("|", msg)}) do
		local challengeID, entriesMessage = strsplit(":", challengeMsg, 2)
		challengeID = tonumber(challengeID)

		if not LADDER_LIST[challengeID] then
			LADDER_LIST[challengeID] = {}
		else
			wipe(LADDER_LIST[challengeID])
		end

		if entriesMessage ~= "" then
			local entryList = {strsplit(";", entriesMessage, SPLIT_LIMIT)}
			local i = 1
			local entryMsg = entryList[i]
			while entryMsg do
				local status, charName, charClass, charRace, charGender, charLevel, lifeTime = strsplit(":", entryMsg, 7)

				if charGender ~= "0" then
					charGender = "1"
				end

				tinsert(LADDER_LIST[challengeID], {
					name = charName,
					class = tonumber(charClass),
					race = E_CHARACTER_RACES[E_CHARACTER_RACES_DBC[tonumber(charRace)]],
					gender = tonumber(charGender),
					level = tonumber(charLevel),
					time = tonumber(lifeTime),
					status = tonumber(status),
				})

				i = i + 1
				if i == SPLIT_LIMIT and entryList[SPLIT_LIMIT] then
					entryList = {strsplit(";", entryList[SPLIT_LIMIT], SPLIT_LIMIT)}
					i = 1
				end
				entryMsg = entryList[i]
			end
		end
	end

	FilteredLeaderboard()
end

local LADDER_LIST_MESSAGES = {}
function EventHandler:ASMSG_HARDCORE_LADDER_LIST(msg)
	LADDER_LIST_MESSAGES[#LADDER_LIST_MESSAGES + 1] = msg

	local hasMessageDelimiter = string.sub(msg, -1) == ";"
	if not hasMessageDelimiter then
		local ladderListMessage = table.concat(LADDER_LIST_MESSAGES)
		wipe(LADDER_LIST_MESSAGES)
		ProcessLadderListMessages(ladderListMessage)
	end
end

function EventHandler:ASMSG_HARDCORE_DEATH(msg)
	local name, race, gender, class, level, zone, reason, npc, npcLevel = strsplit(":", msg)

	if not npc or npc == "0" then
		FireCustomClientEvent("HARDCORE_DEATH", name, tonumber(race), tonumber(gender), tonumber(class), tonumber(level), zone, tonumber(reason) or 0)
	else
		FireCustomClientEvent("HARDCORE_DEATH", name, tonumber(race), tonumber(gender), tonumber(class), tonumber(level), zone, tonumber(reason) or 0, npc, tonumber(npcLevel))
	end
end

function EventHandler:ASMSG_HARDCORE_COMPLETE(msg)
	local name, race, gender, class, challengeID = strsplit(":", msg)

	FireCustomClientEvent("HARDCORE_COMPLETE", name, tonumber(race), tonumber(gender), tonumber(class), tonumber(challengeID) or 0)
end