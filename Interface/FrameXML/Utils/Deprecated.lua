function DrawRouteLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, relPoint)
	DrawLine(texture, canvasFrame, startX, startY, endX, endY, lineWidth, TAXIROUTE_LINEFACTOR, relPoint)
end

function GetGuildXP()
	local guildLevel, guildMaxLevel = GetGuildLevel()
	local currentXP, nextLevelXP, dailyCapXP = UnitGetGuildXP("player")
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

GUILD_CHARACTER_ILEVEL_DATA = setmetatable({}, {__index = function(this, name) return GetGuildMemberItemLevel(name) end})

ItemLevelMixIn = {
	Request = function(self, unit, ignoreCache)
		C_Inspect.RequestAvgItemLevel(unit)
	end,
	GetItemLevel = function(self, guid)
		local unit = UnitTokenFromGUID(guid)
		if unit then
			return C_Inspect.GetAvgItemLevel(unit)
		end
	end,
	CanRequest = function(self, unit)
		return true
	end,
	Update = function(self, unit)
	end,
}

GetRatedBattlegroundRankByTitle = C_PvP.GetRatedBattlegroundRankByTitle

function GetRatedBattlegroundRankInfo()
	local rankName, rankBaseRating, rankID, rankIconAtlas, rating, nextRankName, nextRankID, nextRankIconAtlas, nextRating, weekWins, weekGames, totalWins, totalGames, laurelAtlas, backgroundAtlas = C_PvP.GetRatedBattlegroundRankInfo()
	local rankIconCoord, nextRankIconCoord, laurelCoord, backgroundTexCoord

	do
		local atlasInfo = C_Texture.GetAtlasInfo(rankIconAtlas or "honorsystem-icon-prestige-1")
		rankIconCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end
	do
		local atlasInfo = C_Texture.GetAtlasInfo(nextRankIconAtlas or "honorsystem-icon-prestige-1")
		nextRankIconCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end
	do
		local atlasInfo = C_Texture.GetAtlasInfo(laurelAtlas or "honorsystem-prestige-laurel")
		laurelCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end
	do
		local atlasInfo = C_Texture.GetAtlasInfo(backgroundAtlas or "honorsystem-portrait-neutral-1")
		backgroundTexCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end

	return rankName, rankBaseRating, rankID, rankIconCoord, rating, nextRankName, nextRankID, nextRankIconCoord, nextRating, weekWins, weekGames, totalWins, totalGames, laurelCoord, backgroundTexCoord
end

function GetUnitRatedBattlegroundRankInfo(unitToken)
	local rankName, rankID, rankIconAtlas, rating, weekWins, weekGames, totalWins, totalGames, laurelAtlas, backgroundAtlas = C_PvP.GetUnitRatedBattlegroundRankInfo(unitToken)
	local rankIconCoord, laurelCoord, backgroundTexCoord

	do
		local atlasInfo = C_Texture.GetAtlasInfo(rankIconAtlas or "honorsystem-icon-prestige-1")
		rankIconCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end
	do
		local atlasInfo = C_Texture.GetAtlasInfo(laurelAtlas or "honorsystem-prestige-laurel")
		laurelCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end
	do
		local atlasInfo = C_Texture.GetAtlasInfo(backgroundAtlas or "honorsystem-portrait-neutral-1")
		backgroundTexCoord = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
	end

	return rankName, rankID, rankIconCoord, rating, weekWins, weekGames, totalWins, totalGames, laurelCoord, backgroundTexCoord
end

GetInventoryTransmogID = C_Transmog.GetInventoryTransmogInfo
RequestInventoryTransmogInfo = function() end