ACHIEVEMENTS_FACTION_CHANGE = {
	[6411] = PLAYER_FACTION_GROUP.Horde,
	[6413] = PLAYER_FACTION_GROUP.Horde,
	[6412] = PLAYER_FACTION_GROUP.Alliance,
	[6414] = PLAYER_FACTION_GROUP.Alliance,
}

---@class C_AchievementManagerMixin : Mixin
C_AchievementManagerMixin = {}

function C_AchievementManagerMixin:OnLoad()
	self.storage = {}
	self.counter = {}

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
	table.wipe(self.storage)
	table.wipe(self.counter)
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
			local factionID = C_FactionManager.GetFactionInfoOriginal()
			if factionID == PLAYER_FACTION_GROUP.Neutral then
				return false
			else
				return factionID == ACHIEVEMENTS_FACTION_CHANGE[entry]
			end
		else
			return true
		end
	elseif (achievementFactionID ~= 2 and C_Unit.GetServerFactionID("player") ~= achievementFactionID) then
		return false
	elseif achievementFactionID == 2 and not C_Service.IsRenegadeRealm() then
		return false
	else
		local isRenegade = C_Unit.IsRenegade("player")
		local isHideForRenegade = self:IsHideForRenegade(entry)

		if (isRenegade and isHideForRenegade) or (not isRenegade and not isHideForRenegade) then
			return false
		end
	end

	return true
end

---@overload fun(achievementID:integer):...
---@overload fun(categoryID:table, index:integer):...
function C_AchievementManagerMixin:GetAchievementInfo(categoryID, index)
	if type(categoryID) ~= "number" then
		error("Usage: GetAchievementInfo(achievementID)", 3)
	end

    if AchievementFrame and not AchievementFrame:IsShown() then
		return self._GetAchievementInfo(categoryID, index)
    end

	if type(index) ~= "number" then
		return self._GetAchievementInfo(categoryID) -- achievementID
	else
		local storage = self.storage[categoryID] and self.storage[categoryID][index]
        if storage then
            return unpack(storage, 1, 11)
        else
			return self._GetAchievementInfo(categoryID, index)
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

				if IsGMAccount() or IsDevClient() then
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

function GetAchievementInfo(categoryID, index)
	return C_AchievementManager:GetAchievementInfo(categoryID, index)
end

function GetCategoryNumAchievements( categoryID )
    return C_AchievementManager:GetCategoryNumAchievements(categoryID)
end
