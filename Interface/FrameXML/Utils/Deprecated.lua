function DrawRouteLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, relPoint)
	DrawLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, TAXIROUTE_LINEFACTOR, relPoint)
end

function GetGuildXP()
	local guildLevel, guildMaxLevel = GetGuildLevel()
	local dailyCapXP = GetGuildXPDailtyCap()
	local currentXP, nextLevelXP = UnitGetGuildXP("player")
	return guildLevel, currentXP, nextLevelXP, dailyCapXP
end

function GetGuildPerks(index)
	local name, spellID, iconTexture, level = GetGuildPerkInfo(index)
	return spellID, level
end

function GetGuildRewards(index)
	local achievementID, itemID, itemName, iconTexture, repLevel, moneyCost = GetGuildRewardInfo(index);
	return itemID, repLevel, moneyCost
end

GetGuildNumPerks = GetNumGuildPerks
GetGuildNumRewards = GetNumGuildRewards

GUILD_CHARACTER_ILEVEL_DATA = setmetatable({}, {__index = GetGuildMemberItemLevel})