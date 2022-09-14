--	Filename:	C_AchievementManager.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

ACHIEVEMENTS_FACTION_CHANGE = {
	[6411] = PLAYER_FACTION_GROUP.Horde,
	[6413] = PLAYER_FACTION_GROUP.Horde,
	[6412] = PLAYER_FACTION_GROUP.Alliance,
	[6414] = PLAYER_FACTION_GROUP.Alliance,
}

---@class C_AchievementManagerMixin : Mixin
C_AchievementManagerMixin = {}

function C_AchievementManagerMixin:OnLoad()
    self:Reset()

    self._GetAchievementInfo            = GetAchievementInfo
    self._GetCategoryNumAchievements    = GetCategoryNumAchievements

    self:RegisterHookListener()
end

function C_AchievementManagerMixin:PLAYER_ENTERING_WORLD()
    self:Reset()
end

function C_AchievementManagerMixin:ACHIEVEMENT_EARNED()
    self:Reset()
end

function C_AchievementManagerMixin:Reset()
    self.storage    = {}
    self.counter    = {}
end

---@param entry number
---@return number factionID
function C_AchievementManagerMixin:GetAchievementFactionID( entry )
    return ACHIEVEMENTS_FACTIONDATA[entry] and ACHIEVEMENTS_FACTIONDATA[entry][E_ACHIEVEMENTS_FACTIONDATA.FACTION_ID]
end

---@param entry number
---@return boolean isHideForRenegade
function C_AchievementManagerMixin:IsHideForRenegade( entry )
    return ACHIEVEMENTS_FACTIONDATA[entry] and ACHIEVEMENTS_FACTIONDATA[entry][E_ACHIEVEMENTS_FACTIONDATA.ISRENEGADE_HIDE]
end

---@param entry number
---@return boolean isAchievementValid
function C_AchievementManagerMixin:ValidationFaction( entry )
	local achievementFactionID = self:GetAchievementFactionID(entry)

	if not achievementFactionID then
		if ACHIEVEMENTS_FACTION_CHANGE[entry] then
			local faction = C_CreatureInfo.GetFactionInfo(UnitRace("player"))
			if faction.factionID == PLAYER_FACTION_GROUP.Neutral then
				return false
			else
				return faction.factionID == ACHIEVEMENTS_FACTION_CHANGE[entry]
			end
		else
			return true
		end
	elseif (achievementFactionID ~= 2 and C_Unit:GetServerFactionID("player") ~= achievementFactionID) then
		return false
	elseif achievementFactionID == 2 and C_Service:IsLockRenegadeFeatures() then
		return false
	else
		local isRenegade = C_Unit:IsRenegade("player")
		local isHideForRenegade = self:IsHideForRenegade(entry)

		if (isRenegade and isHideForRenegade) or (not isRenegade and not isHideForRenegade) then
			return false
		end
	end

	return true
end

function C_AchievementManagerMixin:GetAchievementInfo( ... )
    if AchievementFrame and not AchievementFrame:IsShown() then
        return self._GetAchievementInfo(...)
    end

    local args = {...}

    if #args == 1 then
        return self._GetAchievementInfo(args[1])
    else
        local storage = self.storage[args[1]] and self.storage[args[1]][args[2]]

        if storage then
            return unpack(storage)
        else
            return self._GetAchievementInfo(args[1], args[2])
        end
    end
end

---@param categoryID number
---@return number totalAchievement
---@return number completedAchievement
function C_AchievementManagerMixin:GetCategoryNumAchievements( categoryID )
    if AchievementFrame and not AchievementFrame:IsShown() then
        return self._GetCategoryNumAchievements(categoryID)
    end

    if not self.storage[categoryID] then
        self.storage[categoryID] = {}
        self.counter[categoryID] = {total = 0, completed = 0}

        for i = 1, self._GetCategoryNumAchievements(categoryID) do
            local entry, name, points, completed, month, day, year, description, flags, icon, rewardText = self._GetAchievementInfo(categoryID, i)

            if self:ValidationFaction(entry) then
                self.counter[categoryID].total = self.counter[categoryID].total + 1

                if completed then
                    self.counter[categoryID].completed = self.counter[categoryID].completed + 1
                end

                if C_Service:IsGM() or IsDevClient() then
                    name = entry .. " - " .. name
                end

                table.insert(self.storage[categoryID], {entry, name, points, completed, month, day, year, description, flags, icon, rewardText})
            end
        end
    end

    return self.counter[categoryID].total, self.counter[categoryID].completed
end

---@class C_AchievementManager : C_AchievementManagerMixin
C_AchievementManager = CreateFromMixins(C_AchievementManagerMixin)
C_AchievementManager:OnLoad()

function GetAchievementInfo(...)
    return C_AchievementManager:GetAchievementInfo(...)
end

function GetCategoryNumAchievements( categoryID )
    return C_AchievementManager:GetCategoryNumAchievements(categoryID)
end
