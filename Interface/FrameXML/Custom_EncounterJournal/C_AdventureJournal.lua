local ADVENTURE_TYPE = {
	PRIMARY = 1,
	SECONDARY = 2,
}

local ADVENTURE_CATEGORY = {
	DEV							= 0,
	NOVICE_TIPS					= 1,
	WINTERGRASP					= 2,
	CATEGORY_BOSSES				= 3,
	SPEC_INFO					= 4,
	QUEST_DAILY_CRYSTALS		= 5,
	BATTLE_PASS_QUEST_DAILY		= 6,
	QUEST_RENEGADE				= 7,
	QUEST_SIRUS					= 8,
	SEASONAL_EVENT				= 9,
	QUEST_WEEKLY_PVE			= 10,
	BRAWL						= 11,
	BATTLE_PASS_QUEST_WEEKLY	= 12,
	RAID_NEWEST_NORMAL			= 13,
	RAID_NEWEST_HEROIC			= 14,
	WEEKEND_EVENT				= 15,
	QUEST_DAILY_ISLAND			= 16,
	ZONE_QUEST					= 17,
	TUTORIAL_COINS				= 100,
	MISC						= 128,
}

local ADVENTURE_CATEGORY_PRIORITY = {
	[ADVENTURE_CATEGORY.DEV] = 0,
	[ADVENTURE_CATEGORY.NOVICE_TIPS] = 1,
	[ADVENTURE_CATEGORY.WINTERGRASP] = 1,
	[ADVENTURE_CATEGORY.CATEGORY_BOSSES] = 1,
	[ADVENTURE_CATEGORY.SPEC_INFO] = 3,
	[ADVENTURE_CATEGORY.QUEST_DAILY_CRYSTALS] = 1,
	[ADVENTURE_CATEGORY.BATTLE_PASS_QUEST_DAILY] = 2,
	[ADVENTURE_CATEGORY.QUEST_RENEGADE] = 2,
	[ADVENTURE_CATEGORY.QUEST_SIRUS] = 2,
	[ADVENTURE_CATEGORY.SEASONAL_EVENT] = 2,
	[ADVENTURE_CATEGORY.QUEST_WEEKLY_PVE] = 2,
	[ADVENTURE_CATEGORY.BRAWL] = 2,
	[ADVENTURE_CATEGORY.BATTLE_PASS_QUEST_WEEKLY] = 5,
	[ADVENTURE_CATEGORY.RAID_NEWEST_NORMAL] = 2,
	[ADVENTURE_CATEGORY.RAID_NEWEST_HEROIC] = 2,
	[ADVENTURE_CATEGORY.WEEKEND_EVENT] = 4,
	[ADVENTURE_CATEGORY.QUEST_DAILY_ISLAND] = 5,
	[ADVENTURE_CATEGORY.ZONE_QUEST] = 5,
	[ADVENTURE_CATEGORY.TUTORIAL_COINS] = 6,
	[ADVENTURE_CATEGORY.MISC] = 5,
}

local CONDITION_CHECK = {
	PLAYER_IN_GM_MODE = 0,
	PLAYER_FACTION = 1,
	PLAYER_LEVEL = 2,
	PLAYER_HAS_BUFF = 3,
	PLAYER_HAS_DEBUFF = 4,
	PLAYER_HAS_ITEM = 5,
	PLAYER_SPELL_KNOWN = 6,
	PET_SPELL_KNOWN = 7,
	REALM_STAGE = 8,
	REALM_DUNGEON_ACTUAL = 9,
	REALM_GAME_EVENT_ACTIVE = 10,
	PLAYER_QUEST_COMPLETE = 11,
	PLAYER_ACHIEVEMENT_COMPLETE = 12,
	PLAYER_BATTLEPASS_DAILY_COUNT = 13,
	PLAYER_BATTLEPASS_WEEKLY_COUNT = 14,
	REALM_WINTERGRASP_REGISTRATION_ACTIVE = 15,
	REALM_BRAWL_ACTIVE = 16,
	PLAYER_LFG_DUNGEON_JOINABLE = 17,
	PLAYER_LFG_MINIGAME_JOINABLE = 18,
	PLAYER_CUSTOM_VALUE = 19,
	PLAYER_HAS_QUEST_IN_QUESTLOG = 20,
	PLAYER_TALENT_GROUPS_COUNT = 21,
	REALM_ID = 22,
	PLAYER_IN_CHALLENGE_MODE = 23,
}

local CONDITION_OPERATOR = {
	COMP_TYPE_EQ = 0,
	COMP_TYPE_HIGH = 1,
	COMP_TYPE_LOW = 2,
	COMP_TYPE_HIGH_EQ = 3,
	COMP_TYPE_LOW_EQ = 4,
}

local ACTION_BUTTON_TYPE = {
	NONE = 0,
	QUEST_START = 1,
	UI_PVP_ARENA_RATING = 2,
	UI_PVP_HONOR_RANDOM = 3,
	UI_PVP_HONOR_WINTERGRASP = 4,
	UI_PVP_HONOR_BRAWL = 5,
	UI_PVE_LFG_DUNGEON_RANDOM = 6,
	UI_PVE_LFG_DUNGEON_ID = 7,
	UI_PVE_LFG_MINIGAME_ID = 8,
	UI_EJ_DUNGEON_ID = 9,
	UI_BATTLEPASS_QUESTS = 10,
	UI_HEAD_HUNTING = 11,
}

local error = error
local ipairs = ipairs
local select = select
local tonumber = tonumber
local type = type
local mathmax, mathmin, mathrandom = math.max, math.min, math.random
local strformat, strgsub = string.format, string.gsub
local tinsert, tsort, twipe, tCompare = table.insert, table.sort, table.wipe, tCompare

local CanQueueForWintergrasp = CanQueueForWintergrasp
local GetAchievementInfo = GetAchievementInfo
local GetFramerate = GetFramerate
local GetItemCount = GetItemCount
local GetSpellInfo = GetSpellInfo
local IsLFGDungeonJoinable = IsLFGDungeonJoinable
local IsQuestCompleted = IsQuestCompleted
local IsSpellKnown = IsSpellKnown
local QueryQuestStart = QueryQuestStart
local UnitFactionGroup = UnitFactionGroup
local UnitLevel = UnitLevel
local debugprofilestop = debugprofilestop

local FireCustomClientEvent = FireCustomClientEvent
local GetCurrentBrawlID = GetCurrentBrawlID
local IsGameEventActive = IsGameEventActive
local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient
local RequestLoadQuestByID = RequestLoadQuestByID

local AJ_ACTION_TEXT_JOIN_BATTLE = AJ_ACTION_TEXT_JOIN_BATTLE
local AJ_ACTION_TEXT_JOIN_GROUP = AJ_ACTION_TEXT_JOIN_GROUP
local AJ_ACTION_TEXT_OPEN_EJ = AJ_ACTION_TEXT_OPEN_EJ
local AJ_ACTION_TEXT_SHOW_QUEST = AJ_ACTION_TEXT_SHOW_QUEST
local AJ_ACTION_TEXT_START_HUNT = AJ_ACTION_TEXT_START_HUNT
--local AJ_ACTION_TEXT_START_QUEST = AJ_ACTION_TEXT_START_QUEST
local AJ_PRIMARY_REWARD_TEXT = AJ_PRIMARY_REWARD_TEXT
local UNKNOWN = UNKNOWN

local QUESTION_MARK_ICON = QUESTION_MARK_ICON:gsub("%.BLP$", "")

local NUM_SECONDARY_SUGGESTIONS = 2
local MAX_INT = 2^32/2-1

local PRIVATE = {
	DIRTY = true,

	FRAMETIME_TARGET = 1 / 55,
	FRAMETIME_AVAILABLE = 8,
	FRAMETIME_RESERVE = 4,

	REGISTRY = {},
	SUGGESTIONS = {},
	PRIMARY_OFFSET_INDEX = 1,

	QUEST_NAMES = {},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGIN")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:SetScript("OnEvent", function(this, event, ...)
	if event == "PLAYER_LOGIN" then
		C_BattlePass.RequestQuests()
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	local frametimeStep = PRIVATE.FRAMETIME_TARGET - elapsed

	if frametimeStep ~= 0 then
		frametimeStep = frametimeStep * 1000
		PRIVATE.FRAMETIME_AVAILABLE = mathmax(5, PRIVATE.FRAMETIME_AVAILABLE + frametimeStep)
	end

	if PRIVATE.BUILD_COROUTINE then
		PRIVATE.BUILD_COROUTINE_TIMESTAMP = debugprofilestop()
		local status, result, progress = coroutine.resume(PRIVATE.BUILD_COROUTINE)

		if not status then
			PRIVATE.BUILD_COROUTINE = nil
			self:Hide()
			error(result, 2)
		elseif not result then
			if PRIVATE.BUILD_COROUTINE_DEBUG then print("AJ_BUILD_COROUTINE", progress) end
		else
			PRIVATE.BUILD_COROUTINE = nil
			self:Hide()
		end
	else
		self:Hide()
	end
end)

PRIVATE.Initialize = function()
	if PRIVATE.initialized then
		return
	end

	PRIVATE.initialized = true

	_G.ADVENTURE_TYPE = nil
	_G.ADVENTURE_CATEGORY = nil
	_G.ADVENTURE_CATEGORY_PRIORITY = nil
	_G.CONDITION_CHECK = nil
	_G.ACTION_BUTTON_TYPE = nil

	local ADVENTURE_REGISTRY = _G.ADVENTURE_REGISTRY or {}
	if not IsInterfaceDevClient() then
		_G.ADVENTURE_REGISTRY = nil
	end

	for _, adventureType in pairs(ADVENTURE_TYPE) do
		PRIVATE.REGISTRY[adventureType] = {}
	end

	for index, entry in ipairs(ADVENTURE_REGISTRY) do
		if not entry.rngPriority then
			entry.rngPriority = mathrandom(1, MAX_INT)
		end

		if entry.content then
			entry.content = strgsub(entry.content, "\\n", "\n")
		end

		tinsert(PRIVATE.REGISTRY[entry.type], entry)
	end

	for adventureType, registry in pairs(PRIVATE.REGISTRY) do
		tsort(registry, PRIVATE.SortEntries)
	end
end

PRIVATE.SortEntries = function(a, b)
	if ADVENTURE_CATEGORY_PRIORITY[a.category] ~= ADVENTURE_CATEGORY_PRIORITY[b.category] then
		return ADVENTURE_CATEGORY_PRIORITY[a.category] < ADVENTURE_CATEGORY_PRIORITY[b.category]
	elseif a.rngPriority ~= b.rngPriority then
		return a.rngPriority < b.rngPriority
	elseif a.id ~= b.id then
		return a.id < b.id
	end
	return false
end

PRIVATE.IsMinigameAvailable = function(minigameID)
	for index = 1, C_MiniGames.GetNumGames() do
		if C_MiniGames.GetGameIDFromIndex(index) == minigameID then
			return true
		end
	end
	return false
end

PRIVATE.ApplyConditionOperator = function(operator, conditionValue, value)
	if operator == CONDITION_OPERATOR.COMP_TYPE_EQ then
		return value == conditionValue
	elseif operator == CONDITION_OPERATOR.COMP_TYPE_HIGH then
		return value > conditionValue
	elseif operator == CONDITION_OPERATOR.COMP_TYPE_LOW then
		return value < conditionValue
	elseif operator == CONDITION_OPERATOR.COMP_TYPE_HIGH_EQ then
		return value >= conditionValue
	elseif operator == CONDITION_OPERATOR.COMP_TYPE_LOW_EQ then
		return value <= conditionValue
	else
		return false
	end
end

PRIVATE.CheckCondition = function(entry, conditionType, conditionValue, operator, invert)
	local isComplete = false

	if conditionType == CONDITION_CHECK.PLAYER_QUEST_COMPLETE then
		isComplete = IsQuestCompleted(conditionValue)
	elseif conditionType == CONDITION_CHECK.PLAYER_HAS_QUEST_IN_QUESTLOG then
		isComplete = GetQuestLogIndexByID(conditionValue) ~= nil
	elseif conditionType == CONDITION_CHECK.PLAYER_ACHIEVEMENT_COMPLETE then
		isComplete = select(4, GetAchievementInfo(conditionValue))
	elseif conditionType == CONDITION_CHECK.PLAYER_BATTLEPASS_DAILY_COUNT then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_HIGH_EQ, conditionValue, C_BattlePass.GetNumQuests(Enum.BattlePass.QuestType.Daily))
	elseif conditionType == CONDITION_CHECK.PLAYER_BATTLEPASS_WEEKLY_COUNT then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_HIGH_EQ, conditionValue, C_BattlePass.GetNumQuests(Enum.BattlePass.QuestType.Weekly))
	elseif conditionType == CONDITION_CHECK.REALM_STAGE then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_HIGH_EQ, conditionValue, C_Service.GetRealmStage())
	elseif conditionType == CONDITION_CHECK.PLAYER_LEVEL then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_HIGH_EQ, conditionValue, UnitLevel("player"))
	elseif conditionType == CONDITION_CHECK.PLAYER_FACTION then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_EQ, conditionValue, SERVER_PLAYER_FACTION_GROUP[UnitFactionGroup("player")])
	elseif conditionType == CONDITION_CHECK.PLAYER_CUSTOM_VALUE then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_HIGH, 0, C_Service.GetCustomValue(conditionValue) or 0)
	elseif conditionType == CONDITION_CHECK.PLAYER_TALENT_GROUPS_COUNT then
		isComplete = PRIVATE.ApplyConditionOperator(operator or CONDITION_OPERATOR.COMP_TYPE_HIGH, conditionValue, C_Talent.GetNumTalentGroups() or 1)
	elseif conditionType == CONDITION_CHECK.PLAYER_HAS_ITEM then
		isComplete = GetItemCount(conditionValue) > 0
	elseif conditionType == CONDITION_CHECK.PLAYER_HAS_BUFF then
		isComplete = C_Unit.FindAuraBySpell("player", conditionValue, "HELPFUL") ~= nil
	elseif conditionType == CONDITION_CHECK.PLAYER_HAS_DEBUFF then
		isComplete = C_Unit.FindAuraBySpell("player", conditionValue, "HARMFUL") ~= nil
	elseif conditionType == CONDITION_CHECK.PLAYER_SPELL_KNOWN then
		isComplete = IsSpellKnown(conditionValue, false)
	elseif conditionType == CONDITION_CHECK.PET_SPELL_KNOWN then
		isComplete = IsSpellKnown(conditionValue, true)
	elseif conditionType == CONDITION_CHECK.REALM_ID then
		isComplete = C_Service.GetRealmID() == conditionValue
	elseif conditionType == CONDITION_CHECK.REALM_GAME_EVENT_ACTIVE then
		isComplete = IsGameEventActive(conditionValue)
	elseif conditionType == CONDITION_CHECK.REALM_BRAWL_ACTIVE then
		isComplete = GetCurrentBrawlID() == conditionValue
	elseif conditionType == CONDITION_CHECK.REALM_WINTERGRASP_REGISTRATION_ACTIVE then
		isComplete = CanQueueForWintergrasp() ~= nil
	elseif conditionType == CONDITION_CHECK.PLAYER_LFG_DUNGEON_JOINABLE then
		isComplete = conditionValue ~= 0 and IsLFGDungeonJoinable(conditionValue)
	elseif conditionType == CONDITION_CHECK.PLAYER_LFG_MINIGAME_JOINABLE then
		isComplete = conditionValue ~= 0 and PRIVATE.IsMinigameAvailable(conditionValue)
	elseif conditionType == CONDITION_CHECK.REALM_DUNGEON_ACTUAL then
		isComplete = C_EncounterJournal.IsActualInstance(conditionValue, entry.ej_difficultyID)
	elseif conditionType == CONDITION_CHECK.PLAYER_IN_CHALLENGE_MODE then
		isComplete = (C_Hardcore.GetActiveChallengeID() or 0) == conditionValue
	elseif conditionType == CONDITION_CHECK.PLAYER_IN_GM_MODE then
		isComplete = C_Service.IsInGMMode()
	else -- unhandled condition
		return false
	end

	if (not invert and isComplete)
	or (invert and not isComplete)
	then
		return true
	end

	return false
end

PRIVATE.CheckConditions = function(entry)
	for index, condition in ipairs(entry.conditions) do
		local isComplete = PRIVATE.CheckCondition(entry, condition.type, condition.value, condition.operator, condition.invert)
		if not isComplete then
--[[
			if condition.altID then
				if type(condition.altID) == "table" then
					for idIndex, conditionAltID in ipairs(condition.altID) do
						isComplete = PRIVATE.CheckCondition(entry, condition.type, conditionAltID, condition.operator, condition.invert)
						if isComplete then
							break
						end
					end
				else
					isComplete = PRIVATE.CheckCondition(entry, condition.type, condition.altID, condition.operator, condition.invert)
				end

				if not isComplete then
					return false
				end
			else
				return false
			end
--]]
			return false
		end
	end

	return true
end

PRIVATE.UpdateSuggestionsCoroutine = function(isLevelUp)
	local oldIDs = PRIVATE.GetUniqueSuggestionIDs()

	local numEntries = 0
	local processedEntries = 0
	for adventureType, registry in ipairs(PRIVATE.REGISTRY) do
		numEntries = numEntries + #registry
	end

	do -- Build Suggestions
		twipe(PRIVATE.SUGGESTIONS)

		local numPrimary = 0
		local numSecondary = 0

		for adventureType, registry in ipairs(PRIVATE.REGISTRY) do
			local isPrimary = adventureType == ADVENTURE_TYPE.PRIMARY

			PRIVATE.SUGGESTIONS[adventureType] = {}

			for index, entry in ipairs(registry) do
				processedEntries = processedEntries + 1

				if PRIVATE.CheckConditions(entry) then
					if isPrimary then
						numPrimary = numPrimary + 1
						tinsert(PRIVATE.SUGGESTIONS[adventureType], entry)
					else
						if numSecondary >= NUM_SECONDARY_SUGGESTIONS or numPrimary == 0 then
							numPrimary = numPrimary + 1
							tinsert(PRIVATE.SUGGESTIONS[ADVENTURE_TYPE.PRIMARY], entry)
						else
							numSecondary = numSecondary + 1
							tinsert(PRIVATE.SUGGESTIONS[adventureType], entry)
						end
					end
				end

				if (debugprofilestop() - PRIVATE.BUILD_COROUTINE_TIMESTAMP) > PRIVATE.FRAMETIME_BUDGET then
					coroutine.yield(false, processedEntries / numEntries)
				end
			end
		end
	end

	local newIDs = PRIVATE.GetUniqueSuggestionIDs()
	local newAdventureNotice = tCompare(oldIDs, newIDs, 2)

	local offsetFound

	do -- try to select previously displayed primary suggestion
		if PRIVATE.PRIMARY_OFFSET_ID then
			local suggestion, offsetIndex = PRIVATE.GetSuggestionEntryByID(ADVENTURE_TYPE.PRIMARY, PRIVATE.PRIMARY_OFFSET_ID)
			if suggestion then
				PRIVATE.PRIMARY_OFFSET_INDEX = offsetIndex
				PRIVATE.PRIMARY_OFFSET_ID = suggestion.id
				offsetFound = true
			end
		end

		if not offsetFound then
			local suggestion = PRIVATE.GetSuggestionEntry(ADVENTURE_TYPE.PRIMARY, 1)
			if suggestion then
				PRIVATE.PRIMARY_OFFSET_ID = suggestion.id
			else
				PRIVATE.PRIMARY_OFFSET_ID = nil
			end
			PRIVATE.PRIMARY_OFFSET_INDEX = 1
		end
	end

	FireCustomClientEvent("AJ_REFRESH_DISPLAY", newAdventureNotice)

	return true, 1
end

PRIVATE.UpdateSuggestions = function(isLevelUp)
	if PRIVATE.BUILD_COROUTINE then
		return
	end

	local framerate = GetFramerate()
	PRIVATE.FRAMETIME_TARGET = framerate > 63 and (1 / 60) or (1 / 55)
	PRIVATE.FRAMETIME_BUDGET = 1000 / framerate - PRIVATE.FRAMETIME_RESERVE

	PRIVATE.BUILD_COROUTINE = coroutine.create(PRIVATE.UpdateSuggestionsCoroutine)
	PRIVATE.BUILD_COROUTINE_TIMESTAMP = debugprofilestop()

	local status, result, progress = coroutine.resume(PRIVATE.BUILD_COROUTINE, isLevelUp)
	if not status then
		PRIVATE.BUILD_COROUTINE = nil
		PRIVATE.eventHandler:Hide()
		error(result, 2)
	end

	if coroutine.status(PRIVATE.BUILD_COROUTINE) == "dead" then
		PRIVATE.BUILD_COROUTINE = nil
	else
		if PRIVATE.BUILD_COROUTINE_DEBUG then print("AJ_BUILD_COROUTINE", progress) end
		PRIVATE.eventHandler:Show()
	end
end

PRIVATE.GetNumPrimarySuggestions = function()
	if PRIVATE.SUGGESTIONS[ADVENTURE_TYPE.PRIMARY] then
		return #PRIVATE.SUGGESTIONS[ADVENTURE_TYPE.PRIMARY]
	end
	return 0
end

PRIVATE.GetNumSecondarySuggestions = function()
	if PRIVATE.SUGGESTIONS[ADVENTURE_TYPE.SECONDARY] then
		return #PRIVATE.SUGGESTIONS[ADVENTURE_TYPE.SECONDARY]
	end
	return 0
end

PRIVATE.GetButtonText = function(suggestion)
	if suggestion.actionType == ACTION_BUTTON_TYPE.NONE then
		-- skip
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.QUEST_START then
		return AJ_ACTION_TEXT_START_QUEST
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_ARENA_RATING
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_HONOR_RANDOM
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_HONOR_WINTERGRASP
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_HONOR_BRAWL
	then
		return AJ_ACTION_TEXT_JOIN_BATTLE
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVE_LFG_DUNGEON_RANDOM
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVE_LFG_DUNGEON_ID
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVE_LFG_MINIGAME_ID
	then
		return AJ_ACTION_TEXT_JOIN_GROUP
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_EJ_DUNGEON_ID then
		return AJ_ACTION_TEXT_OPEN_EJ
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_BATTLEPASS_QUESTS then
		return AJ_ACTION_TEXT_SHOW_QUEST
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_HEAD_HUNTING then
		return AJ_ACTION_TEXT_START_HUNT
	end
end

local ACTION_TARGET_VIEW = {
	[ACTION_BUTTON_TYPE.UI_PVP_ARENA_RATING]		= "pvp-arena-rating",
	[ACTION_BUTTON_TYPE.UI_PVP_HONOR_RANDOM]		= "pvp-honor-random",
	[ACTION_BUTTON_TYPE.UI_PVP_HONOR_WINTERGRASP]	= "pvp-honor-wintergrasp",
	[ACTION_BUTTON_TYPE.UI_PVP_HONOR_BRAWL]			= "pvp-honor-brawl",

	[ACTION_BUTTON_TYPE.UI_PVE_LFG_DUNGEON_RANDOM]	= "pve-lfg-dungeon",
	[ACTION_BUTTON_TYPE.UI_PVE_LFG_DUNGEON_ID]		= "pve-lfg-dungeon",
	[ACTION_BUTTON_TYPE.UI_PVE_LFG_MINIGAME_ID]		= "pve-lfg-minigame",
}

PRIVATE.ActivateEntry = function(suggestion)
	if suggestion.actionType == ACTION_BUTTON_TYPE.NONE then
		-- skip
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.QUEST_START then
		local questID = suggestion.actionParam
		if questID then
			QueryQuestStart(questID, Enum.QueryQuestStartSource.Suggestion, suggestion.id)
		--	FireCustomClientEvent("AJ_QUEST_LOG_OPEN", questID or 0, uiMapID or 0)
		else
			GMError(string.format("[Suggestion::ActivateEntry] no quest id to start [suggestionID=%d]", suggestion.id))
		end
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_ARENA_RATING
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_HONOR_RANDOM
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_HONOR_WINTERGRASP
	or suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVP_HONOR_BRAWL
	then
		local desiredViewType = ACTION_TARGET_VIEW[suggestion.actionType]
		FireCustomClientEvent("AJ_ACTION_PVP_LFG", desiredViewType)
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVE_LFG_DUNGEON_RANDOM then
		for i, lfgDungeonID in ipairs({258, 259, 261}) do
			if IsLFGDungeonJoinable(lfgDungeonID) then
				local desiredViewType = ACTION_TARGET_VIEW[suggestion.actionType]
				FireCustomClientEvent("AJ_ACTION_PVE_LFG", desiredViewType, lfgDungeonID)
				return
			end
		end
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVE_LFG_DUNGEON_ID then
		local desiredViewType = ACTION_TARGET_VIEW[suggestion.actionType]
		local lfgDungeonID = suggestion.actionParam or 0
		if IsLFGDungeonJoinable(lfgDungeonID) then
			FireCustomClientEvent("AJ_ACTION_PVE_LFG", desiredViewType, lfgDungeonID)
		end
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_PVE_LFG_MINIGAME_ID then
		local desiredViewType = ACTION_TARGET_VIEW[suggestion.actionType]
		local minigameID = suggestion.actionParam or 0
		FireCustomClientEvent("AJ_ACTION_PVE_LFG", desiredViewType, minigameID)
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_EJ_DUNGEON_ID then
		local dungeonID = suggestion.actionParam or 0
		local difficultyID = suggestion.actionParam2 or -1
		FireCustomClientEvent("AJ_ACTION_EJ_DUNGEON", dungeonID, difficultyID)
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_BATTLEPASS_QUESTS then
		local showQuestTab = true
		FireCustomClientEvent("AJ_ACTION_BATTLE_PASS", showQuestTab)
	elseif suggestion.actionType == ACTION_BUTTON_TYPE.UI_HEAD_HUNTING then
		FireCustomClientEvent("AJ_ACTION_HEAD_HUNTING")
	end
end

PRIVATE.GetSuggestionEntry = function(suggestionType, index)
	if PRIVATE.SUGGESTIONS[suggestionType] then
		return PRIVATE.SUGGESTIONS[suggestionType][index]
	end
end

PRIVATE.GetSuggestionEntryByID = function(suggestionType, id)
	if PRIVATE.SUGGESTIONS[suggestionType] then
		for index, suggestion in ipairs(PRIVATE.SUGGESTIONS[suggestionType]) do
			if suggestion.id == id then
				return suggestion, index
			end
		end
	end
end

PRIVATE.OnItemLoaded = function()
	FireCustomClientEvent("AJ_REWARD_DATA_RECEIVED")
end

PRIVATE.OnItemLoadedContent = function()
	FireCustomClientEvent("AJ_REFRESH_DISPLAY", false)
end

PRIVATE.OnQuestLoadedContent = function(questID, tooltipLines)
	if tooltipLines[1] and tooltipLines[1][1] then
		PRIVATE.QUEST_NAMES[questID] = tooltipLines[1][1]
	end
	FireCustomClientEvent("AJ_REFRESH_DISPLAY", false)
end

PRIVATE.GetQuestName = function(questID)
	local name = PRIVATE.QUEST_NAMES[questID]
	if not name then
		PRIVATE.QUEST_NAMES[questID] = true
		local hasQuestCache = RequestLoadQuestByID(questID, PRIVATE.OnQuestLoadedContent)
		if hasQuestCache then
			name = GetQuestNameByID(questID)
			if name then
				PRIVATE.QUEST_NAMES[questID] = name
			end
		end
	end
	return name ~= true and name or nil
end

PRIVATE.GetQuestLink = function(questID)
	questID = tonumber(questID)
	local name = PRIVATE.GetQuestName(questID)
	if not name then
		name = IsGMAccount() and strformat("%s (quest:%s)", UNKNOWN, questID) or UNKNOWN
	end
	return strformat("|cff8B0000|Hquest:%d:-1|h[%s]|h|r", questID, name)
end

PRIVATE.GetItemLink = function(itemID)
	itemID = tonumber(itemID)
	local name, link = C_Item.GetItemInfo(itemID, nil, PRIVATE.OnItemLoadedContent, true)
	if not link then
		name = IsGMAccount() and strformat("%s (item:%s)", UNKNOWN, itemID) or UNKNOWN
		return strformat("|cffffffff[%s]|r", name)
	end
	return link
end

PRIVATE.GetSpellLink = function(spellID)
	spellID = tonumber(spellID)
	local name = GetSpellInfo(spellID)
	if not name then
		name = IsGMAccount() and strformat("%s (spell:%s)", UNKNOWN, spellID) or UNKNOWN
		return strformat("|cffffffff[%s]|r", name)
	end
	return strformat("|cff000080|Hspell:%d|h[%s]|h|r", spellID, name)
end

PRIVATE.GetSuggestionInfo = function(suggestionType, index)
	local suggestion = PRIVATE.GetSuggestionEntry(suggestionType, index)
	if suggestion then
		local description = suggestion.content

		if description then
			description = strgsub(description, "{quest:(%d+)}", PRIVATE.GetQuestLink)
			description = strgsub(description, "{item:(%d+)}", PRIVATE.GetItemLink)
			description = strgsub(description, "{spell:(%d+)}", PRIVATE.GetSpellLink)
		end

		return {
			title = suggestion.title,
			description = description,
			buttonText = PRIVATE.GetButtonText(suggestion),
			iconPath = suggestion.icon and strconcat([[Interface\Icons\]], suggestion.icon) or QUESTION_MARK_ICON,
			ej_instanceID = suggestion.ej_instanceID,
			difficultyID = suggestion.ej_difficultyID or 1,
			expansionLevel = suggestion.ej_expansionLevel,
			isRandomDungeon = suggestion.ej_isRandomDungeon,
			hideDifficulty = suggestion.ej_showDifficulty ~= 1,
		}
	end
end

PRIVATE.GetSuggestionByIndex = function(suggestionIndex)
	if suggestionIndex <= 1 then
		return PRIVATE.GetSuggestionEntry(ADVENTURE_TYPE.PRIMARY, PRIVATE.PRIMARY_OFFSET_INDEX)
	else
		return PRIVATE.GetSuggestionEntry(ADVENTURE_TYPE.SECONDARY, suggestionIndex - 1)
	end
end

PRIVATE.GetReward = function(suggestion)
	if not suggestion then
		return
	end

	local numRewards = #suggestion.rewards

	if numRewards > 0 then
		if numRewards == 1 and suggestion.rewardDesc then
			local itemName, itemLink, itemRarity, iLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = C_Item.GetItemInfo(suggestion.rewards[1], nil, PRIVATE.OnItemLoaded, true)
			local rewardDesc = type(suggestion.rewardDesc) == "string" and suggestion.rewardDesc or AJ_PRIMARY_REWARD_TEXT

			return {
				isRewardTable = false,
				rewardDesc = rewardDesc,
				itemLink = itemLink,
				itemIcon = itemTexture,
				itemQuantity = 1,
			}
		else
			local rewards = {}

			for index, itemID in ipairs(suggestion.rewards) do
				local itemName, itemLink, itemRarity, iLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = C_Item.GetItemInfo(suggestion.rewards[index], nil, PRIVATE.OnItemLoaded, true)
				if itemLink then
					tinsert(rewards, {
						itemLink = itemLink,
						itemIcon = itemTexture,
						itemQuantity = 1,
					})
				end
			end

			if #rewards > 0 then
				rewards.isRewardList = true
				return rewards
			end
		end
	elseif false then -- currency item
		return {
			isRewardTable = false,
			rewardDesc = AJ_PRIMARY_REWARD_TEXT,
			currencyIcon = nil,
			currencyQuantity = nil,
			currencyIcon = nil,
		}
	else
		local minItemLevel = suggestion.reward_minItemLevel
		local maxItemLevel = suggestion.reward_maxItemLevel
		local itemLevel = suggestion.reward_itemLevel

		if itemLevel or minItemLevel or maxItemLevel then
			if itemLevel then
				minItemLevel = nil
				maxItemLevel = nil
			elseif not minItemLevel or not maxItemLevel then
				minItemLevel = nil
				maxItemLevel = nil
				itemLevel = minItemLevel or maxItemLevel
			end

			return {
				isRewardTable = true,
				itemLevel = itemLevel,
				minItemLevel = minItemLevel,
				maxItemLevel = maxItemLevel,
			}
		end
	end
end

PRIVATE.GetUniqueSuggestionIDs = function()
	local suggestionIDs = {}

	for adventureType, registry in ipairs(PRIVATE.REGISTRY) do
		suggestionIDs[adventureType] = {}

		for index, entry in ipairs(registry) do
			suggestionIDs[adventureType][entry.id] = true
		end
	end

	return suggestionIDs
end

do
	if IsInterfaceDevClient() then
		PRIVATE.BUILD_COROUTINE_DEBUG = true
		PRIVATE_AJ = PRIVATE
	end
	PRIVATE.Initialize()
end

C_AdventureJournal = {}

function C_AdventureJournal.ReloadData()
	if IsInterfaceDevClient() then
		if _G.ADVENTURE_REGISTRY and PRIVATE.initialized then
			PRIVATE.initialized = nil
			twipe(PRIVATE.REGISTRY)
			PRIVATE.Initialize()
		end
	end
end

function C_AdventureJournal.CanBeShown()
	return true
end

function C_AdventureJournal.UpdateSuggestions(isLevelUp)
	PRIVATE.UpdateSuggestions(not not isLevelUp)
end

function C_AdventureJournal.SetPrimaryOffset(offset)
	if type(offset) ~= "number" then
		error(strformat("bad argument #1 to 'C_AdventureJournal.SetPrimaryOffset' (number expected, got %s)", offset ~= nil and type(offset) or "no value"), 2)
	end

	offset = offset + 1

	if offset < 1 or offset > PRIVATE.GetNumPrimarySuggestions() then
		error(strformat("bad argument #1 to 'C_AdventureJournal.SetPrimaryOffset' (index %s out of range [1 - %s])", offset, PRIVATE.GetNumPrimarySuggestions()), 2)
	end

	if offset == PRIVATE.PRIMARY_OFFSET_INDEX then
		return
	end

	local suggestion = PRIVATE.GetSuggestionEntry(ADVENTURE_TYPE.PRIMARY, offset)
	if suggestion then
		PRIVATE.PRIMARY_OFFSET_INDEX = offset
		PRIVATE.PRIMARY_OFFSET_ID = suggestion.id
		FireCustomClientEvent("AJ_REFRESH_DISPLAY", false)
	end
end

function C_AdventureJournal.GetPrimaryOffset()
	return PRIVATE.PRIMARY_OFFSET_INDEX - 1
end

function C_AdventureJournal.GetNumAvailableSuggestions()
	return PRIVATE.GetNumPrimarySuggestions()
end

function C_AdventureJournal.GetSuggestions(suggestionTable)
	if type(suggestionTable) ~= "table" then
		error(strformat("bad argument #1 to 'C_AdventureJournal.GetSuggestions' (table expected, got %s)", suggestionTable ~= nil and type(suggestionTable) or "no value"), 2)
	end

	twipe(suggestionTable)

	if PRIVATE.GetNumPrimarySuggestions() > 0 then
		local suggestion = PRIVATE.GetSuggestionInfo(ADVENTURE_TYPE.PRIMARY, PRIVATE.PRIMARY_OFFSET_INDEX)
		if suggestion then
			tinsert(suggestionTable, suggestion)
		end
	end

	for index = 1, mathmin(NUM_SECONDARY_SUGGESTIONS, PRIVATE.GetNumSecondarySuggestions()) do
		local suggestion = PRIVATE.GetSuggestionInfo(ADVENTURE_TYPE.SECONDARY, index)
		if suggestion then
			tinsert(suggestionTable, suggestion)
		end
	end
end

function C_AdventureJournal.GetReward(suggestionIndex)
	if type(suggestionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_AdventureJournal.GetReward' (number expected, got %s)", suggestionIndex ~= nil and type(suggestionIndex) or "no value"), 2)
	elseif suggestionIndex < 1 or suggestionIndex > NUM_SECONDARY_SUGGESTIONS + 1 then
		error(strformat("bad argument #1 to 'C_AdventureJournal.GetReward' (index %s out of range [1 - %s])", suggestionIndex, NUM_SECONDARY_SUGGESTIONS + 1), 2)
	end

	return PRIVATE.GetReward(PRIVATE.GetSuggestionByIndex(suggestionIndex))
end

function C_AdventureJournal.ActivateEntry(suggestionIndex)
	if type(suggestionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_AdventureJournal.ActivateEntry' (number expected, got %s)", suggestionIndex ~= nil and type(suggestionIndex) or "no value"), 2)
	elseif suggestionIndex < 1 or suggestionIndex > NUM_SECONDARY_SUGGESTIONS + 1 then
		error(strformat("bad argument #1 to 'C_AdventureJournal.ActivateEntry' (index %s out of range [1 - %s])", suggestionIndex, NUM_SECONDARY_SUGGESTIONS + 1), 2)
	end

	local suggestion = PRIVATE.GetSuggestionByIndex(suggestionIndex)
	if suggestion then
		PRIVATE.ActivateEntry(suggestion)
	end
end