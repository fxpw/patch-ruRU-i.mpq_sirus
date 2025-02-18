local type = type
local unpack = unpack
local bitband = bit.band
local tinsert, twipe = table.insert, table.wipe

local GetAchievementInfo = GetAchievementInfo
local GetCategoryNumAchievements = GetCategoryNumAchievements
local UnitFactionGroup = UnitFactionGroup

local IsDevClient = IsDevClient
local IsGMAccount = IsGMAccount

local ACHIEVEMENTS_FACTION_FLAG = {
	Alliance	= 0x1,
	Horde		= 0x2,
	Renegade	= 0x4,
	Neutral		= 0x8,
}

local ACHIEVEMENTS_FACTION_CHANGE = {
	[6411] = PLAYER_FACTION_GROUP.Horde,
	[6413] = PLAYER_FACTION_GROUP.Horde,
	[6412] = PLAYER_FACTION_GROUP.Alliance,
	[6414] = PLAYER_FACTION_GROUP.Alliance,
}

local PRIVATE = {
	storage = {},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.eventHandler:RegisterEvent("ACHIEVEMENT_EARNED")
PRIVATE.eventHandler:SetScript("OnEvent", function(this, event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "ACHIEVEMENT_EARNED" then
		twipe(PRIVATE.storage)
	end
end)

PRIVATE.IsAvailableForPlayerFaction = function(achievementID)
	local achievementFactionFlag = ACHIEVEMENTS_FACTIONDATA[achievementID]

	if achievementFactionFlag then
		local factionName = UnitFactionGroup("player")
		local factionFlag = ACHIEVEMENTS_FACTION_FLAG[factionName]
		return bitband(achievementFactionFlag, factionFlag) ~= 0
	else
		if ACHIEVEMENTS_FACTION_CHANGE[achievementID] then
			local factionID = C_FactionManager.GetFactionInfoOriginal()
			if factionID == PLAYER_FACTION_GROUP.Neutral then
				return false
			else
				return factionID == ACHIEVEMENTS_FACTION_CHANGE[achievementID]
			end
		end
	end

	return true
end

PRIVATE.GetAchievementInfo = function(categoryID, index)
	if type(categoryID) == "string" then
		categoryID = tonumber(categoryID)
	end
	if type(categoryID) ~= "number" then
		error("Usage: GetAchievementInfo(achievementID)", 3)
	end

	if AchievementFrame and not AchievementFrame:IsShown() then
		return GetAchievementInfo(categoryID, index)
	end

	if type(index) == "string" then
		index = tonumber(index)
	end
	if type(index) ~= "number" then
		return GetAchievementInfo(categoryID) -- achievementID
	else
		local storage = PRIVATE.storage[categoryID] and PRIVATE.storage[categoryID][index]
		if storage then
			return unpack(storage, 1, 11)
		else
			return GetAchievementInfo(categoryID, index)
		end
	end
end

PRIVATE.GetCategoryNumAchievements = function(categoryID)
	if type(categoryID) ~= "number" then
		error("Usage: GetCategoryNumAchievements(categoryID)", 3)
	end

	if AchievementFrame and not AchievementFrame:IsShown() then
		return GetCategoryNumAchievements(categoryID)
	end

	local category = PRIVATE.storage[categoryID]
	if not category then
		category = {total = 0, completed = 0}

		for i = 1, GetCategoryNumAchievements(categoryID) do
			local achievementID, name, points, completed, month, day, year, description, flags, icon, rewardText = GetAchievementInfo(categoryID, i)

			if PRIVATE.IsAvailableForPlayerFaction(achievementID) then
				category.total = category.total + 1

				if completed then
					category.completed = category.completed + 1
				end

				if IsGMAccount() or IsDevClient() then
					name = strconcat(achievementID, " - ", name)
				end

				tinsert(category, {achievementID, name, points, completed, month, day, year, description, flags, icon, rewardText})
			end
		end

		PRIVATE.storage[categoryID] = category
	end

	return category.total, category.completed
end

_G.GetAchievementInfo = function(categoryID, index)
	return PRIVATE.GetAchievementInfo(categoryID, index)
end

_G.GetCategoryNumAchievements = function(categoryID)
	return PRIVATE.GetCategoryNumAchievements(categoryID)
end