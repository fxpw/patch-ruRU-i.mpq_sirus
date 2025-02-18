local select = select
local mathmax, mathmin = math.max, math.min
local strformat = string.format
local tinsert, tsort, twipe = table.insert, table.sort, table.wipe

local UnitLevel = UnitLevel

local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient
local WithinRange = WithinRange

local PLAYER_FACTION_GROUP = PLAYER_FACTION_GROUP

local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_WRATH_OF_THE_LICH_KING]

local INSTANCE_INFO_FIELD = {
	NAME = 1,
	DESCRIPTION = 2,
	BUTTONICON = 3,
	SMALL_BUTTON_ICON = 4,
	BACKGROUND = 5,
	LORE_BACKGROUND = 6,
	MAP_ID = 7,
	AREA_ID = 8,
	ORDER_INDEX = 9,
	FLAGS = 10,
	ID = 11,
	WORLD_MAP_AREA_ID = 12,
}

local INSTANCE_INFO_EX_FIELD = {
	MAP_ID = 1,
	DIFFICULTY_ID = 2,
	ITEM_LEVEL = 3,
	IS_OPEN = 4,
	IS_ACTUAL = 5,
	LEVEL_MIN = 6,
	LEVEL_MAX = 7,
	REQUIRED_ITEM_LEVEL = 8,
	REQUIRED_QUEST_ALLIANCE = 9,
	REQUIRED_QUEST_HORDE = 10,
	REQUIRED_ACHIEVEMENT = 11,
}

local PRIVATE = {
	MAP_TO_INSTANCE_ID = {},
	INSTANCE_TO_MAP_ID = {},

--	INSTANCE_INFO_EX = nil,
--	PLAYER_FACTION_ID = nil,
--	PLAYER_GUID = nil,
}

PRIVATE.Initialize = function()
	if IsInterfaceDevClient() then
		_G.PRIVATE_EJ = PRIVATE
	end

	PRIVATE.ReloadData()

	C_FactionManager.RegisterCallback(function()
		local factionGroup = UnitFactionGroup("player")
		if factionGroup == "Renegade" then
			PRIVATE.PLAYER_FACTION_ID = C_FactionManager.GetFactionInfoOriginal()
		else
			PRIVATE.PLAYER_FACTION_ID = PLAYER_FACTION_GROUP[factionGroup]
		end
		PRIVATE.PLAYER_GUID = UnitGUID("player")
	end, true, true)
end

PRIVATE.ReloadData = function()
	PRIVATE.INSTANCE_INFO_EX = JOURNAACTUALRAIDS[C_Service.GetRealmID()] or JOURNAACTUALRAIDS[9] or {}
	_G.JOURNAACTUALRAIDS = nil

	twipe(PRIVATE.MAP_TO_INSTANCE_ID)
	twipe(PRIVATE.INSTANCE_TO_MAP_ID)

	for instanceID, instanceInfo in pairs(JOURNALINSTANCE) do
		local mapID = instanceInfo[INSTANCE_INFO_FIELD.MAP_ID]
		if mapID and mapID ~= 0 then
			PRIVATE.MAP_TO_INSTANCE_ID[mapID] = instanceID
			PRIVATE.INSTANCE_TO_MAP_ID[instanceID] = mapID
		end
	end

	for index, instanceInfoEx in ipairs(PRIVATE.INSTANCE_INFO_EX) do
		instanceInfoEx[INSTANCE_INFO_EX_FIELD.DIFFICULTY_ID] = instanceInfoEx[INSTANCE_INFO_EX_FIELD.DIFFICULTY_ID] + 1
	end

	FireCustomClientEvent("EJ_DUNGEON_INFO_EX_UPDATE")
end

PRIVATE.GetInstanceIDByMapID = function(mapID)
	local instanceID = PRIVATE.MAP_TO_INSTANCE_ID[mapID]
	return instanceID
end

PRIVATE.GetMapIDByInstanceID = function(instanceID)
	local mapID = PRIVATE.MAP_TO_INSTANCE_ID[instanceID]
	return mapID
end

PRIVATE.IsRaidInstance = function(instanceID)
	local instanceInfo = JOURNALINSTANCE[instanceID]
	if instanceInfo and bit.band(instanceInfo[INSTANCE_INFO_FIELD.FLAGS], 0x16) ~= 0 then
		return true
	end
	return false
end

PRIVATE.IsRaidMap = function(mapID)
	local instanceID = PRIVATE.MAP_TO_INSTANCE_ID[mapID]
	if instanceID then
		return PRIVATE.IsRaidInstance(instanceID)
	end
	return false
end

PRIVATE.GetInstanceInfoExEntry = function(instanceID, difficultyID)
	for index, instanceInfoEx in ipairs(PRIVATE.INSTANCE_INFO_EX) do
		local entryInstanceID = PRIVATE.GetInstanceIDByMapID(instanceInfoEx[INSTANCE_INFO_EX_FIELD.MAP_ID])
		if entryInstanceID and entryInstanceID == instanceID
		and instanceInfoEx[INSTANCE_INFO_EX_FIELD.DIFFICULTY_ID] == difficultyID
		then
			return instanceInfoEx
		end
	end
end

PRIVATE.IsInstanceOpen = function(instanceID)
	local isOpen = true
	for index, instanceInfoEx in ipairs(PRIVATE.INSTANCE_INFO_EX) do
		local entryInstanceID = PRIVATE.GetInstanceIDByMapID(instanceInfoEx[INSTANCE_INFO_EX_FIELD.MAP_ID])
		if entryInstanceID and entryInstanceID == instanceID then
			if instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_OPEN] == 1 then
				return true
			else
				isOpen = false
			end
		end
	end
	return isOpen
end

PRIVATE.GetInstanceInfoExList = function(instanceID)
	local instanceInfoExList = {}
	for index, instanceInfoEx in ipairs(PRIVATE.INSTANCE_INFO_EX) do
		local entryInstanceID = PRIVATE.GetInstanceIDByMapID(instanceInfoEx[INSTANCE_INFO_EX_FIELD.MAP_ID])
		if entryInstanceID and entryInstanceID == instanceID then
			tinsert(instanceInfoExList, instanceInfoEx)
		end
	end
	return instanceInfoExList
end

PRIVATE.GetInstanceRequirementsEx = function(instanceInfoEx)
	local requiredMinLevel = instanceInfoEx[INSTANCE_INFO_EX_FIELD.LEVEL_MIN]
	local requiredMaxLevel = instanceInfoEx[INSTANCE_INFO_EX_FIELD.LEVEL_MAX]
	local requiredItemLevel = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_ITEM_LEVEL] or 0
	local requiredQuests = {}
	local requiredAchievements = {}

	if not requiredMinLevel or requiredMinLevel <= 0 then
		requiredMinLevel = 1
	elseif requiredMinLevel > MAX_PLAYER_LEVEL then
		requiredMinLevel = MAX_PLAYER_LEVEL
	end
	if not requiredMaxLevel or not WithinRange(requiredMaxLevel, 1, MAX_PLAYER_LEVEL) then
		requiredMaxLevel = MAX_PLAYER_LEVEL
	end

	local hasRequirements

	if requiredMaxLevel == MAX_PLAYER_LEVEL and (requiredMinLevel == 1 or requiredMinLevel == requiredMaxLevel) then
		requiredMinLevel = nil
		requiredMaxLevel = nil
	else
		hasRequirements = true
	end

	if requiredItemLevel <= 0 then
		requiredItemLevel = nil
	else
		hasRequirements = true
	end

	do -- quests
		local questList
		if PRIVATE.PLAYER_FACTION_ID == PLAYER_FACTION_GROUP.Horde then
			questList = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_QUEST_HORDE]
		else
			questList = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_QUEST_ALLIANCE]
		end

		if type(questList) == "table" then
			for index, questID in ipairs(questList) do
				if questID ~= 0 and not tIndexOf(requiredQuests, questID) then
					tinsert(requiredQuests, questID)
				end
			end
		elseif type(questList) == "number" then
			if questList ~= 0 and not tIndexOf(requiredQuests, questList) then
				tinsert(requiredQuests, questList)
			end
		end
	end

	do -- achievements
		local achievementList = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_ACHIEVEMENT]
		if type(achievementList) == "table" then
			for index, achievementID in ipairs(achievementList) do
				if achievementID ~= 0 and not tIndexOf(requiredAchievements, achievementID) then
					tinsert(requiredAchievements, achievementID)
				end
			end
		elseif type(achievementList) == "number" then
			if achievementList ~= 0 and not tIndexOf(requiredAchievements, achievementList) then
				tinsert(requiredAchievements, achievementList)
			end
		end
	end

	if #requiredQuests > 0 or #requiredAchievements > 0 then
		hasRequirements = true
	end

	if hasRequirements then
		return {
			isRaid			= PRIVATE.IsRaidMap(instanceInfoEx[INSTANCE_INFO_EX_FIELD.MAP_ID]),
			difficultyID	= instanceInfoEx[INSTANCE_INFO_EX_FIELD.DIFFICULTY_ID],
			minLevel		= requiredMinLevel,
			maxLevel		= requiredMaxLevel,
			itemLevel		= requiredItemLevel,
			quests			= #requiredQuests > 0 and requiredQuests or nil,
			achievements	= #requiredAchievements > 0 and requiredAchievements or nil,
		}
	end
end

PRIVATE.SortRequirementsByDifficulty = function(a, b)
	if a.isRaid ~= b.isRaid then
		return not a.isRaid
	elseif a.difficultyID ~= b.difficultyID then
		return a.difficultyID < b.difficultyID
	end
end

PRIVATE.IsInstanceAvailableForPlayer = function(instanceInfoEx, checkPlayerLevel, checkPlayerItemLevel, checkQuestRequirements, checkAchievementRequirements)
	if instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_OPEN] == 0 then
		return false
	end

	if checkPlayerLevel then
		local levelMin = instanceInfoEx[INSTANCE_INFO_EX_FIELD.LEVEL_MIN] or 0
		local levelMax = instanceInfoEx[INSTANCE_INFO_EX_FIELD.LEVEL_MAX] or 0
		if levelMin ~= 0 and levelMin ~= 0 then
			local playerLevel = UnitLevel("player")
			if levelMax == 0 then
				levelMax = playerLevel
			end
			if not WithinRange(playerLevel, levelMin, levelMax) then
				return false
			end
		end
	end

	if checkPlayerItemLevel then
		local itemLevel = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_ITEM_LEVEL] or 0
		if itemLevel ~= 0 then
			local playerItemLevel = ItemLevelMixIn:GetItemLevel(PRIVATE.PLAYER_GUID)
			if playerItemLevel and playerItemLevel < itemLevel then
				return false
			end
		end
	end

	if checkQuestRequirements then
		local questList
		if PRIVATE.PLAYER_FACTION_ID == PLAYER_FACTION_GROUP.Horde then
			questList = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_QUEST_HORDE]
		else
			questList = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_QUEST_ALLIANCE]
		end

		if type(questList) == "table" then
			for index, questID in ipairs(questList) do
				if questID ~= 0 and not IsQuestCompleted(questID) then
					return false
				end
			end
		elseif type(questList) == "number" then
			if questList ~= 0 and not IsQuestCompleted(questList) then
				return false
			end
		end
	end

	if checkAchievementRequirements then
		local achievementList = instanceInfoEx[INSTANCE_INFO_EX_FIELD.REQUIRED_ACHIEVEMENT]
		if type(achievementList) == "table" then
			for index, achievementID in ipairs(achievementList) do
				if achievementID ~= 0 and not select(4, GetAchievementInfo(achievementID)) then
					return false
				end
			end
		elseif type(achievementList) == "number" then
			if achievementList ~= 0 and not select(4, GetAchievementInfo(achievementList)) then
				return false
			end
		end
	end

	return true
end

PRIVATE.IsInstanceActualEntry = function(instanceInfoEx, skipRequirementsCheck, checkPlayerLevel, checkPlayerItemLevel, checkQuestRequirements, checkAchievementRequirements)
	if instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_ACTUAL] == 1
--	and instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_OPEN] == 1
	and (skipRequirementsCheck or PRIVATE.IsInstanceAvailableForPlayer(instanceInfoEx, checkPlayerLevel, checkPlayerItemLevel, checkQuestRequirements, checkAchievementRequirements))
	then
		return true
	end
	return false
end

PRIVATE.IsInstanceActual = function(instanceID, difficultyID, skipRequirementsCheck, checkPlayerLevel, checkPlayerItemLevel, checkQuestRequirements, checkAchievementRequirements)
	for index, instanceInfoEx in ipairs(PRIVATE.GetInstanceInfoExList(instanceID)) do
		if (not difficultyID or difficultyID == instanceInfoEx[INSTANCE_INFO_EX_FIELD.DIFFICULTY_ID])
		and PRIVATE.IsInstanceActualEntry(instanceInfoEx, skipRequirementsCheck, checkPlayerLevel, checkPlayerItemLevel, checkQuestRequirements, checkAchievementRequirements)
		then
			return true
		end
	end
	return false
end

PRIVATE.Initialize()

C_EncounterJournal = {}

function C_EncounterJournal.ReloadData()
	if IsInterfaceDevClient() then
		PRIVATE.ReloadData()
	end
end

function C_EncounterJournal.IsInstanceOpen(instanceID)
	if type(instanceID) ~= "number" then
		error(strformat("bad argument #1 to 'C_EncounterJournal.IsInstanceOpen' (number expected, got %s)", instanceID ~= nil and type(instanceID) or "no value"), 2)
	end

	if IsGMAccount() or IsInterfaceDevClient() then
		return true
	end

	return PRIVATE.IsInstanceOpen(instanceID)
end

function C_EncounterJournal.IsActualInstance(instanceID, difficultyID)
	if type(instanceID) ~= "number" then
		error(strformat("bad argument #1 to 'C_EncounterJournal.IsActualInstance' (number expected, got %s)", instanceID ~= nil and type(instanceID) or "no value"), 2)
	elseif difficultyID ~= nil and type(difficultyID) ~= "number" then
		error(strformat("bad argument #2 to 'C_EncounterJournal.IsActualInstance' (number expected, got %s)", difficultyID ~= nil and type(difficultyID) or "no value"), 2)
	end

	return PRIVATE.IsInstanceActual(instanceID, difficultyID, true, true, true, true, true)
end

function C_EncounterJournal.IsActualInstanceForPlayer(instanceID, difficultyID)
	if type(instanceID) ~= "number" then
		error(strformat("bad argument #1 to 'C_EncounterJournal.IsActualInstanceForPlayer' (number expected, got %s)", instanceID ~= nil and type(instanceID) or "no value"), 2)
	elseif difficultyID ~= nil and type(difficultyID) ~= "number" then
		error(strformat("bad argument #2 to 'C_EncounterJournal.IsActualInstanceForPlayer' (number expected, got %s)", difficultyID ~= nil and type(difficultyID) or "no value"), 2)
	end

	return PRIVATE.IsInstanceActual(instanceID, difficultyID, false, true, true, true, true)
end

function C_EncounterJournal.GetInstanceInfoEx(instanceID, difficultyID)
	if type(instanceID) ~= "number" then
		error(strformat("bad argument #1 to 'C_EncounterJournal.GetInstanceInfoEx' (number expected, got %s)", instanceID ~= nil and type(instanceID) or "no value"), 2)
	elseif difficultyID ~= nil and type(difficultyID) ~= "number" then
		error(strformat("bad argument #2 to 'C_EncounterJournal.GetInstanceInfoEx' (number expected, got %s)", difficultyID ~= nil and type(difficultyID) or "no value"), 2)
	end

	if difficultyID == nil then
		local instanceInfoExList = PRIVATE.GetInstanceInfoExList(instanceID)
		if #instanceInfoExList > 0 then
			local isOpen = false
			local isActual = false
			local minItemLevel
			local maxItemLevel

			for index, instanceInfoEx in ipairs(instanceInfoExList) do
				if instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_OPEN] == 1 then
					isOpen = true
				end

				if instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_ACTUAL] == 1 then
					isActual = true
				end

				local itemLevel = instanceInfoEx[INSTANCE_INFO_EX_FIELD.ITEM_LEVEL] or 0
				if itemLevel ~= 0 then
					minItemLevel = mathmin(minItemLevel or itemLevel, itemLevel)
					maxItemLevel = mathmax(maxItemLevel or itemLevel, itemLevel)
				end
			end

			return isOpen, isActual, minItemLevel or 0, maxItemLevel or 0
		end
	else
		local instanceInfoEx = PRIVATE.GetInstanceInfoExEntry(instanceID, difficultyID)
		if instanceInfoEx then
			local isOpen = instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_OPEN] == 1
			local isActual = instanceInfoEx[INSTANCE_INFO_EX_FIELD.IS_ACTUAL] == 1
			local minItemLevel = instanceInfoEx[INSTANCE_INFO_EX_FIELD.ITEM_LEVEL] or 0
			local maxItemLevel = minItemLevel

			return isOpen, isActual, minItemLevel, maxItemLevel
		end
	end

	return true, true, 0, 0
end

function C_EncounterJournal.GetInstanceRequirementsEx(instanceID, difficultyID)
	if type(instanceID) ~= "number" then
		error(strformat("bad argument #1 to 'C_EncounterJournal.GetInstanceRequirementsEx' (number expected, got %s)", instanceID ~= nil and type(instanceID) or "no value"), 2)
	elseif difficultyID ~= nil and type(difficultyID) ~= "number" then
		error(strformat("bad argument #2 to 'C_EncounterJournal.GetInstanceRequirementsEx' (number expected, got %s)", difficultyID ~= nil and type(difficultyID) or "no value"), 2)
	end

	if difficultyID == nil then
		local instanceInfoExList = PRIVATE.GetInstanceInfoExList(instanceID)
		if #instanceInfoExList > 0 then
			local requirementsList = {}

			for index, instanceInfoEx in ipairs(instanceInfoExList) do
				local requirements = PRIVATE.GetInstanceRequirementsEx(instanceInfoEx)
				if requirements then
					tinsert(requirementsList, requirements)
				end
			end

			local hasRequirements = next(requirementsList) ~= nil
			if hasRequirements then
				tsort(requirementsList, PRIVATE.SortRequirementsByDifficulty)
				return hasRequirements, requirementsList
			end
		end
	else
		local instanceInfoEx = PRIVATE.GetInstanceInfoExEntry(instanceID, difficultyID)
		if instanceInfoEx then
			local requirements = PRIVATE.GetInstanceRequirementsEx(instanceInfoEx)
			local hasRequirements = requirements ~= nil
			return hasRequirements, requirements
		end
	end

	return false, nil
end