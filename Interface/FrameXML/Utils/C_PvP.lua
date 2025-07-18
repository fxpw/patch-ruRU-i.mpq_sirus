local error = error
local tonumber = tonumber
local type = type
local strformat, strlower = string.format, string.lower
local twipe = table.wipe

local GetCurrentMapAreaID = GetCurrentMapAreaID
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitName = UnitName

local C_GlobalStorage = C_GlobalStorage
--local C_Inspect = C_Inspect
local FireCustomClientEvent = FireCustomClientEvent
local StringSplitEx = StringSplitEx
local WithinRange = WithinRange

local RANK_OFFSET = 4

local PRIVATE = {
	PVP_RANK_NAME_TO_ID = {}
}

PRIVATE.EventHandler = CreateFrame("Frame")
PRIVATE.EventHandler:Hide()
PRIVATE.EventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.EventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if channel == "UNKNOWN" and sender == UnitName("player") then
			if PRIVATE[prefix] then
				PRIVATE[prefix](message)
			end
		end
	end
end)

PRIVATE.Initialize = function()
	for rankIndex = RANK_OFFSET + 1, 18 do
		for factionID = 0, 1 do
			local str = _G[strformat("PVP_RANK_%i_%i", rankIndex, factionID)]
			if str then
				PRIVATE.PVP_RANK_NAME_TO_ID[str] = rankIndex - RANK_OFFSET
			end
		end
	end
end

PRIVATE.ASMSG_UPDATE_BG_RANK = function(msg)
	local rankBaseRating, rankID, rating, nextRankID, nextRating, weekWins, weekGames, totalWins, totalGames = StringSplitEx("|", msg)

	local bgStatsInfo = C_GlobalStorage.GetVar("ASMSG_UPDATE_BG_RANK")
	if bgStatsInfo then
		twipe(bgStatsInfo)
	else
		bgStatsInfo = {}
		C_GlobalStorage.SetVar("ASMSG_UPDATE_BG_RANK", bgStatsInfo)
	end

	bgStatsInfo.rankBaseRating 	= tonumber(rankBaseRating) or 0
	bgStatsInfo.rankID 			= tonumber(rankID) or 0
	bgStatsInfo.rating 			= tonumber(rating) or 0
	bgStatsInfo.nextRankID 		= tonumber(nextRankID) or 0
	bgStatsInfo.nextRating 		= tonumber(nextRating) or 0
	bgStatsInfo.weekWins 		= tonumber(weekWins) or 0
	bgStatsInfo.weekGames 		= tonumber(weekGames) or 0
	bgStatsInfo.totalWins 		= tonumber(totalWins) or 0
	bgStatsInfo.totalGames 		= tonumber(totalGames) or 0

	FireCustomClientEvent("PLAYER_BATTLEGROUND_STATS_UPDATE")
end

PRIVATE.Initialize()

PRIVATE.GetRankInfo = function(rankID, factionID, unitToken)
	if rankID < 0 then
		return
	elseif rankID == 0 then
		rankID = 1
	elseif rankID > 14 then
		rankID = 14
	end

	if factionID == PLAYER_FACTION_GROUP.Neutral then
		factionID = PLAYER_FACTION_GROUP.Alliance
	end

	local rankIndex = rankID + RANK_OFFSET
	local name = _G[strformat("PVP_RANK_%d_%d", rankIndex, factionID)]
	if name then
		local iconAtlas = strformat("honorsystem-icon-prestige-%d", rankID)
		local laurelAtlas, backgroundAtlas, backgroundType

		if WithinRange(rankID, 0, 5) then
			laurelAtlas = "honorsystem-prestige-laurel"
			backgroundType = 1
		elseif WithinRange(rankID, 6, 10) then
			laurelAtlas = "honorsystem-prestige-laurel-2"
			backgroundType = 2
		elseif WithinRange(rankID, 11, 14) then
			laurelAtlas = "honorsystem-prestige-laurel-3"
			backgroundType = 3
		end

		if unitToken and UnitIsPVPFreeForAll(unitToken) then
			backgroundAtlas = strformat("honorsystem-portrait-neutral-%i", backgroundType)
		else
			backgroundAtlas = strformat("honorsystem-portrait-%s-%i", strlower(PLAYER_FACTION_GROUP[factionID]), backgroundType)
		end

		return name, iconAtlas, laurelAtlas, backgroundAtlas
	end
end

C_PvP = {}

function C_PvP.IsInBrawl()
	local currentMapAreaID = GetCurrentMapAreaID()
	if currentMapAreaID == BATTLEGROUND_ARATHI_BLIZZARD or currentMapAreaID == BATTLEGROUND_THE_MAGNIFICENT_FIVE or currentMapAreaID == BATTLEGROUND_GRAVITY_LAPSE then
		return true
	end
	return false
end

function C_PvP.GetRankInfo(rankID, factionID)
	if type(rankID) ~= "number" then
		error(strformat("bad argument #1 to 'C_PvP.GetRankInfo' (number expected, got %s)", rankID ~= nil and type(rankID) or "no value"), 2)
	elseif type(factionID) ~= "number" then
		error(strformat("bad argument #2 to 'C_PvP.GetRankInfo' (number expected, got %s)", factionID ~= nil and type(factionID) or "no value"), 2)
	end

	return PRIVATE.GetRankInfo(rankID, factionID, "player")
end

function C_PvP.GetRatedBattlegroundRating()
	local bgStatsInfo = C_GlobalStorage.GetVar("ASMSG_UPDATE_BG_RANK")
	if bgStatsInfo then
		return bgStatsInfo.rating or 0
	end
	return 0
end

function C_PvP.GetRatedBattlegroundRankInfo()
	local bgStatsInfo = C_GlobalStorage.GetVar("ASMSG_UPDATE_BG_RANK")
	if bgStatsInfo then
		local factionGroup, factionName = UnitFactionGroup("player")
		local factionID = PLAYER_FACTION_GROUP[factionGroup] or PLAYER_FACTION_GROUP.Alliance

		local rankName, rankIconAtlas, laurelAtlas, backgroundAtlas = PRIVATE.GetRankInfo(bgStatsInfo.rankID, factionID, "player")
		local nextRankName, nextRankIconAtlas = PRIVATE.GetRankInfo(bgStatsInfo.nextRankID == 0 and 1 or bgStatsInfo.nextRankID, factionID, "player")

		if not rankName then
			rankName = RATED_BATTLEGROUND_NORANK
		end

		return rankName, bgStatsInfo.rankBaseRating, bgStatsInfo.rankID, rankIconAtlas, bgStatsInfo.rating,
			nextRankName, bgStatsInfo.nextRankID, nextRankIconAtlas, bgStatsInfo.nextRating,
			bgStatsInfo.weekWins, bgStatsInfo.weekGames, bgStatsInfo.totalWins, bgStatsInfo.totalGames,
			laurelAtlas, backgroundAtlas
	end

	return nil, 0, 0, nil, 0, nil, 0, nil, 0, 0, 0, 0, 0, nil, nil
end

function C_PvP.GetUnitRatedBattlegroundRankInfo(unitToken)
	if type(unitToken) ~= "string" then
		error(strformat("bad argument #1 to 'C_PvP.GetUnitRatedBattlegroundRankInfo' (string expected, got %s)", unitToken ~= nil and type(unitToken) or "no value"), 2)
	end

	if UnitExists(unitToken) then
		local rankID, rating, weekWins, weekGames, totalWins, totalGames = C_Inspect.GetBattlegroundRankInfo(unitToken)
		if rankID then
			local factionGroup, factionName = UnitFactionGroup(unitToken)
			local factionID = PLAYER_FACTION_GROUP[factionGroup] or PLAYER_FACTION_GROUP.Alliance

			local rankName, rankIconAtlas, laurelAtlas, backgroundAtlas = PRIVATE.GetRankInfo(rankID, factionID, unitToken)

			if not rankName then
				rankName = RATED_BATTLEGROUND_NORANK
			end

			return rankName, rankID, rankIconAtlas, rating,
				weekWins, weekGames, totalWins, totalGames,
				laurelAtlas, backgroundAtlas
		else
			C_Inspect.RequestBattlegroundRankInfo(unitToken)
		end
	end

	return nil, 0, nil, 0, 0, 0, 0, 0, nil, nil
end

function C_PvP.GetRatedBattlegroundRankByTitle(title)
	if type(title) ~= "string" then
		error(strformat("bad argument #1 to 'C_PvP.GetRatedBattlegroundRankByTitle' (string expected, got %s)", title ~= nil and type(title) or "no value"), 2)
	end

	return PRIVATE.PVP_RANK_NAME_TO_ID[title]
end