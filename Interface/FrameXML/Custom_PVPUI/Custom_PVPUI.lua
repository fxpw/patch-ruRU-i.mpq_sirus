--	Filename:	Sirus_PVPUI.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

CONQUEST_SIZE_STRINGS = { ARENA_INSPECT_BRECKET_1, ARENA_INSPECT_BRECKET_2, ARENA_INSPECT_BRECKET_3, ARENA_INSPECT_BRECKET_4, ARENA_INSPECT_BRECKET_5 }
CONQUEST_SIZES = { 1, 2, 3 }
CONQUEST_BUTTONS = {}

SIRUS_ARENA_POINTS_PREDICT = {}
SIRUS_RATEDBATTLEGROUND_READY = {}

SIRUS_RATEDBATTLEGROUND_RANK = {}

local HORDE_TEX_COORDS = { left = 0.00195313, right = 0.63867188, top = 0.31738281, bottom = 0.44238281 }
local ALLIANCE_TEX_COORDS = { left = 0.00195313, right = 0.63867188, top = 0.19042969, bottom = 0.31542969 }

local pvpFrames = { "RatedBattlegroundFrame", "ConquestFrame", "PVPHonorFrame" }

local JoinBattlefield = JoinBattlefield
local AcceptBattlefieldPort = AcceptBattlefieldPort

local activeButton = 1

local RATED_BATTLEGROUND_BRACKET_ID = 4

local RATED_BATTLEGROUND_UNIT_DATA = {}

StaticPopupDialogs["CONFIRM_JOIN_SOLO"] = {
	text = CONFIRM_JOIN_SOLO,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		HonorFrame_Queue(false, true)
	end,
	OnShow = function(self)
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
}

BattlegroundsData = {
	[2] = { -- Ущелье Песни Войны
		battleGroundID = 2,
		maxPlayers = 10,
		icon = "LFGICON-WARSONGGULCH",
		gameType = CAPTURE_THE_FLAG,
		longDescription = BATTLEGROUND_WARSONG_DESC,
		backgroundAtlas = "Battleground-Stats-Background-Warsong",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_CAPTURE_FLAGS, STATS_RETURNED_FLAGS},
		}
	},
	[3] = { -- Низина Арати
		battleGroundID = 3,
		maxPlayers = 15,
		icon = "LFGICON-ARATHIBASIN",
		gameType = SUPERIORITY,
		longDescription = BATTLEGROUND_ARATHI_DESC,
		--backgroundCoords = {0, 0.298828125, 0.59765625, 0.896484375},
		backgroundAtlas = "Battleground-Stats-Background-Arathi",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_BASE_CAPTURED, STATS_BASE_PROTECTED},
		}
	},
	[1] = { -- Альтеракская долина
		battleGroundID = 1,
		maxPlayers = 40,
		icon = "LFGICON-BATTLEGROUND",
		gameType = RAID_BATTLE,
		longDescription = BATTLEGROUND_ALTERAC_DESC,
		backgroundAtlas = "Battleground-Stats-Background-Alterac",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_CAPTURED_GRAVEYARDS, STATS_PROTECTED_GRAVEYARDS, STATS_CAPTURED_TOWERS, STATS_PROTECTED_TOWERS, STATS_CAPTURED_MINES},
		}
	},
	[7] = { -- Око бури
		battleGroundID = 7,
		maxPlayers = 15,
		icon = "LFGICON-NETHERBATTLEGROUNDS",
		gameType = SUPERIORITY,
		longDescription = BATTLEGROUND_NETHER_DESC,
		backgroundAtlas = "Battleground-Stats-Background-Nether",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_CAPTURE_FLAGS},
		}
	},
	[9] = { -- Берег древних
		battleGroundID = 9,
		maxPlayers = 15,
		icon = "LFGICON-STRANDOFTHEANCIENTS",
		gameType = BUILDING_DAMAGE,
		longDescription = BATTLEGROUND_STRAND_OF_THE_ANCIENTS_DESC,
		backgroundAtlas = "Battleground-Stats-Background-StrandOfTheAncients",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_VEHICLE_DESTROYED, STATS_GATES_DESTROYED},
		}
	},
	[30] = { -- Остров завоеваний
		battleGroundID = 30,
		maxPlayers = 40,
		icon = "LFGICON-ISLEOFCONQUEST",
		gameType = RAID_BATTLE,
		longDescription = BATTLEGROUND_ISLE_OF_CONQUEST_DESC,
		backgroundAtlas = "Battleground-Stats-Background-IsleOfConquest",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_BASE_CAPTURED, STATS_BASE_PROTECTED},
		}
	},
	[31] = { -- Долина узников
        battleGroundID = 31,
        maxPlayers = 15,
        icon = "LFGICON-SLAVERY-VALLEY",
        gameType = SUPERIORITY,
        longDescription = BATTLEGROUND_SLAVERY_VALLEY_DESC,
		backgroundAtlas = "Battleground-Stats-Background-SlaveryValley",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_BASE_CAPTURED, STATS_BASE_PROTECTED},
		}
    },
    [12] = { -- Сверкающие копи
        battleGroundID = 12,
        maxPlayers = 10,
        icon = "LFGIcon-SilvershardMines",
        gameType = ESCORT,
        longDescription = BATTLEGROUND_SILVERSHARD_MINES_DESC,
		backgroundAtlas = "Battleground-Stats-Background-SilvershardMines",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_TROLLEYS_CAPTURED},
		}
    },
	[18] = { -- Битва за Гильнеас
		battleGroundID = 18,
		maxPlayers = 10,
		icon = "LFGICON-THEBATTLEFORGILNEAS",
		gameType = SUPERIORITY,
		longDescription = BATTLEGROUND_BATTLEFOR_GILNEAS_DESC,
		backgroundAtlas = "Battleground-Stats-Background-Gilneas",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH},
		}
	},
	[19] = { -- Храм Котмогу
		battleGroundID = 19,
		maxPlayers = 10,
		icon = "LFGIcon-TempleofKotmogu",
		gameType = SPHERES_OF_POWER,
		longDescription = BATTLEGROUND_TEMPLE_OF_KOTMGU_DESC,
		backgroundAtlas = "Battleground-Stats-Background-TempleofKotmogu",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_SPHERES},
		}
	},
	[20] = { -- Храмовый город Ала'ваште
		battleGroundID = 20,
		maxPlayers = 15,
		icon = "LFGICON-TEMPLEOFALAWASHTE",
		gameType = CAPTURE_THE_FLAG,
		longDescription = BATTLEGROUND_TEMPLE_OF_ALAWASHTE,
		backgroundAtlas = "Battleground-Stats-Background-TempleCityOfAlawashte",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_BASE_CAPTURED, STATS_BASE_PROTECTED, STATS_CAPTURE_FLAGS, STATS_RETURNED_FLAGS},
		}
	},
	[57] = { -- Два Пика
		battleGroundID = 57,
		maxPlayers = 10,
		icon = "LFGIcon-TwinPeaksBG",
		gameType = CAPTURE_THE_FLAG,
		longDescription = BATTLEGROUND_TWIN_PEAKS,
		backgroundAtlas = "Battleground-Stats-Background-TwinPeaks",
		statistics = {
			isCollapsed = true,
			statsLocale = {GAMES, PVPFRAME_WINS_LABEL, STATS_KILLS, STATS_DEATH, STATS_CAPTURE_FLAGS, STATS_RETURNED_FLAGS},
		}
	},
     [34] = { -- Случайное РБГ
         battleGroundID = 34,
         maxPlayers = 0,
         icon = "LFGFrame-SearchIcon-Background",
         gameType = "",
         longDescription = "",
         showOnlyGM = true
     },
    [33] = { -- Случайное БГ с наградами за килы
        battleGroundID = 33,
        maxPlayers = 0,
        icon = "LFGFrame-SearchIcon-Background",
        gameType = "",
        longDescription = "",
        showOnlyGM = true
    },
    [17] = { -- Тол Гадор
    	battleGroundID = 17,
        maxPlayers = 0,
        icon = "LFGFrame-SearchIcon-Background",
        gameType = "",
        longDescription = "",
        showOnlyGM = true
    },
	[58] = {
		battleGroundID = 58,
		maxPlayers = 0,
		icon = "",
		gameType = "",
		longDescription = "",
		showOnlyGM = true,
	},
	[59] = {
		battleGroundID = 59,
		maxPlayers = 0,
		icon = "",
		gameType = "",
		longDescription = "",
		showOnlyGM = true,
	},
}

UIPanelWindows["PVPUIFrame"] = { area = "left",	pushable = 0, whileDead = 1, xOffset = "15", yOffset = "-10", width = 563, height = 428 }

local panels = {
	{ name = "LFDParentFrame", addon = nil },
	{ name = "PVPUIFrame", addon = nil },
	{ name = "PVPLadderFrame", addon = nil },
	{ name = "RenegadeLadderFrame", addon = nil },
}

local RatedBattleGroundRankCoords = {
	{0.0009765625, 0.1259765625, 0.001953125, 0.251953125},
	{0.1259765625, 0.2509765625, 0.001953125, 0.251953125},
	{0.1259765625, 0.2509765625, 0.251953125, 0.501953125},
	{0.1259765625, 0.2509765625, 0.501953125, 0.751953125},
	{0.3759765625, 0.5009765625, 0.501953125, 0.751953125},
	{0.5009765625, 0.6259765625, 0.001953125, 0.251953125},
	{0.2509765625, 0.3759765625, 0.001953125, 0.251953125},
	{0.5009765625, 0.6259765625, 0.251953125, 0.501953125},
	{0.2509765625, 0.3759765625, 0.251953125, 0.501953125},
	{0.2509765625, 0.3759765625, 0.501953125, 0.751953125},
	{0.3759765625, 0.5009765625, 0.001953125, 0.251953125},
	{0.3759765625, 0.5009765625, 0.251953125, 0.501953125},
	{0.0009765625, 0.1259765625, 0.251953125, 0.501953125},
	{0.0009765625, 0.1259765625, 0.501953125, 0.751953125},
}


local RatedBattlegroundLaurelTexCoord = {
	{0.6240234375, 0.8798828125, 0.0009765625, 0.2158203125},
	{0.482421875, 0.73828125, 0.4609375, 0.67578125},
	{0.7421875, 0.998046875, 0.4609375, 0.67578125},
}

local RatedBattlegroundRankBackgroundTexCoord = {
	{
		["Neutral"] 	= {0, 0.04296875, 0.75, 0.8359375},
		["Horde"] 		= {0.12890625, 0.171875, 0.75, 0.8359375},
		["Alliance"] 	= {0.2578125, 0.30078125, 0.75, 0.8359375},
		["Renegade"] 	= {0.38671875, 0.4296875, 0.75, 0.8359375},
	},
	{
		["Neutral"] 	= {0.04296875, 0.0859375, 0.75, 0.8359375},
		["Horde"] 		= {0.171875, 0.21484375, 0.75, 0.8359375},
		["Alliance"]	= {0.30078125, 0.34375, 0.75, 0.8359375},
		["Renegade"] 	= {0.4296875, 0.47265625, 0.75, 0.8359375},
	},
	{
		["Neutral"] 	= {0.0859375, 0.12890625, 0.75, 0.8359375},
		["Horde"] 		= {0.21484375, 0.2578125, 0.75, 0.8359375},
		["Alliance"] 	= {0.34375, 0.38671875, 0.75, 0.8359375},
		["Renegade"] 	= {0.47265625, 0.515625, 0.75, 0.8359375},
	}
}

local RatedBattlegroundRankIndex = {
	[PVP_RANK_5_0] = 1,
	[PVP_RANK_6_0] = 2,
	[PVP_RANK_7_0] = 3,
	[PVP_RANK_8_0] = 4,
	[PVP_RANK_9_0] = 5,
	[PVP_RANK_10_0] = 6,
	[PVP_RANK_11_0] = 7,
	[PVP_RANK_12_0] = 8,
	[PVP_RANK_13_0] = 9,
	[PVP_RANK_14_0] = 10,
	[PVP_RANK_15_0] = 11,
	[PVP_RANK_16_0] = 12,
	[PVP_RANK_17_0] = 13,
	[PVP_RANK_18_0] = 14,
	[PVP_RANK_5_1] = 1,
	[PVP_RANK_6_1] = 2,
	[PVP_RANK_7_1] = 3,
	[PVP_RANK_8_1] = 4,
	[PVP_RANK_9_1] = 5,
	[PVP_RANK_10_1] = 6,
	[PVP_RANK_11_1] = 7,
	[PVP_RANK_12_1] = 8,
	[PVP_RANK_13_1] = 9,
	[PVP_RANK_14_1] = 10,
	[PVP_RANK_15_1] = 11,
	[PVP_RANK_16_1] = 12,
	[PVP_RANK_17_1] = 13,
	[PVP_RANK_18_1] = 14,
}

function TryToJoinSoloQ( isRated )
	SendServerMessage("ACMSG_ARENA_SOLOQ_JOIN", isRated and 1 or 0)
end

function GetArenaRating( bracketID )
	local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})

	if pvpStats[bracketID] then
		return pvpStats[bracketID].pvpRating
	end
end

function GetArenaDistributionTime()
	return C_CacheInstance:Get("ASMSG_NEXT_ARENA_DISTRIBUTION_TIME", 0) - time()
end

function GetArenaPointsPredict()
	return C_CacheInstance:Get("ASMSG_ARENA_POINTS_PREDICT", 0)
end

function GetUnitArenaTooltipInfo( unit, teamID, index )
	if not unit or not teamID and index then
		return
	end

	local data 		 = C_CacheInstance:Get("ASMSG_CHARACTER_ARENA_INFO")
	local playerGUID = tonumber(UnitGUID(unit))

	local name, games, wins, rating

	if data then
		if data[playerGUID] then
			if data[playerGUID][teamID] then
				if data[playerGUID][teamID][index] then
					local playerData = data[playerGUID][teamID][index]

					name 	= playerData.name
					games 	= playerData.seasonGame
					wins 	= playerData.seasonWin
					rating 	= playerData.rating
				end
			end
		else
			-- PH request data. used in GetUnitRatedBattlegroundRankInfo
		end
	end

	return name, games, wins, rating
end

function GetNumUnitArenaTooltipInfo( unit, teamID )
	if not unit or not teamID then
		return
	end

	local data 		 = C_CacheInstance:Get("ASMSG_CHARACTER_ARENA_INFO")
	local playerGUID = tonumber(UnitGUID(unit))

	if data then
		if data[playerGUID] and data[playerGUID][teamID] then
			return #data[playerGUID][teamID]
		end
	end

	return 0
end

function GetUnitRatedBattlegroundInfo( unit )
	if not unit then
		return
	end

	local data = C_CacheInstance:Get("ASMSG_CHARACTER_RBG_STATS")
	local currRating, weekWins, weekGames, totalWins, totalGames

	if data then
		local playerGUID = UnitGUID(unit)

		if data.GUID == tonumber(playerGUID) then
			currRating 	= data.currRating
			weekWins 	= data.weekWins
			weekGames 	= data.weekGames
			totalWins 	= data.totalWins
			totalGames 	= data.totalGames
		else
			-- PH request data. used in GetUnitRatedBattlegroundRankInfo
		end
	end

	currRating 	= currRating or 0
	weekWins 	= weekWins or 0
	weekGames 	= weekGames or 0
	totalWins 	= totalWins or 0
	totalGames 	= totalGames or 0

	return currRating, weekWins, weekGames, totalWins, totalGames
end

function GetNumBattlegroundStatustics( battleGroundID )
	if not battleGroundID then
		return
	end

	if not BattlegroundsData[battleGroundID] or not BattlegroundsData[battleGroundID].statistics then
		return
	end

	return #BattlegroundsData[battleGroundID].statistics.statsLocale
end

function GetBattlegroundStatistics( battleGroundID, statIndex, unitGUID )
	if not battleGroundID then
		return
	end

	local title, week, season

	local cache = C_CacheInstance:Get("ASMSG_CHARACTER_BG_STATS")
	unitGUID 	= not unitGUID and tonumber(UnitGUID("player")) or tonumber(unitGUID)

	if cache and cache[unitGUID] then
		if cache[unitGUID][battleGroundID] and BattlegroundsData[battleGroundID] then
			local data = cache[unitGUID][battleGroundID]

			if data[statIndex] then
				title 	= BattlegroundsData[battleGroundID].statistics.statsLocale[statIndex] or "-"
				week 	= data[statIndex][1]
				season 	= data[statIndex][2]
			end
		end
	end

	return title, week, season
end

function GetBattlegroundRecordStatistics( battleGroundID, unitGUID )
	if not battleGroundID then
		return
	end

	local win, lose

	local cache = C_CacheInstance:Get("ASMSG_CHARACTER_BG_STATS")
	unitGUID 	= not unitGUID and tonumber(UnitGUID("player")) or tonumber(unitGUID)

	if cache and cache[unitGUID] then
		if cache[unitGUID][battleGroundID] then
			local data = cache[unitGUID][battleGroundID]

			win = data[2][2]
			lose = (data[1][2] - win)
		end
	end

	return win, lose
end

function Sirus_BattlegroundRegister( battlegroundID, isParty )
	for i = 1, GetNumBattlegroundTypes() do
		local name, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)
		if BattleGroundID == battlegroundID then
			RequestBattlegroundInstanceInfo(i)
			JoinBattlefield(i, isParty)
			break
		end
	end
end

function GetBattlegroundInfoByID( battlegroundID )
	battlegroundID = tonumber(battlegroundID)

	for i = 1, GetNumBattlegroundTypes() do
		local name, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)
		if BattleGroundID == battlegroundID then
			return name, canEnter, isHoliday, isRandom, BattleGroundID
		end
	end
end

function GetRatedBattlegroundRankInfo()
	local data = C_CacheInstance:Get("ASMSG_UPDATE_BG_RANK")
	local factionGroup, factionName = UnitFactionGroup("player")
	local currTitle, currStRank, currRankID, currRankIconCoord, currRating, nextTitle, nextRankID, nextRankIconCoord, nextRating, weekWins, weekGames, totalWins, totalGames, laurelCoord, rankBackgroundTexCoord

	if data then
		currStRank 	= data.currentStRank and tonumber( data.currentStRank ) or 0
		currRankID 	= data.currentRank and tonumber( data.currentRank ) or 0
		currRating 	= data.currentRating and tonumber( data.currentRating ) or 0
		nextRankID 	= data.nextRank and tonumber( data.nextRank ) or 0
		nextRating 	= data.nextRating and tonumber( data.nextRating ) or 0
		weekWins 	= data.weekWins and tonumber( data.weekWins ) or 0
		weekGames 	= data.weekGames and tonumber( data.weekGames ) or 0
		totalWins 	= data.totalWins and tonumber( data.totalWins ) or 0
		totalGames 	= data.totalGames and tonumber( data.totalGames ) or 0

		if currRankID and currRankID ~= 0 then
			if factionGroup then
				currTitle = _G[string.format("PVP_RANK_%d_%d", (currRankID + 4), factionGroup == "Alliance" and 1 or 0)]
			end
		else
			currTitle = RATED_BATTLEGROUND_NORANK
		end

		if factionGroup then
			nextTitle = _G[string.format("PVP_RANK_%d_%d", ((nextRankID == 0 and 1 or nextRankID) + 4), factionGroup == "Alliance" and 1 or 0)]
		end

		if currRankID and RatedBattleGroundRankCoords[currRankID] then
			currRankIconCoord = RatedBattleGroundRankCoords[currRankID]
		end

		if currRankID >= 14 then
			nextRankIconCoord = RatedBattleGroundRankCoords[14]
		else
			if RatedBattleGroundRankCoords[nextRankID == 0 and 1 or nextRankID] then
				nextRankIconCoord = RatedBattleGroundRankCoords[nextRankID == 0 and 1 or nextRankID]
			end
		end

		if C_InRange(currRankID, 0, 5) then
			laurelCoord = RatedBattlegroundLaurelTexCoord[1]
			rankBackgroundTexCoord = RatedBattlegroundRankBackgroundTexCoord[1]
		elseif C_InRange(currRankID, 6, 10) then
			laurelCoord = RatedBattlegroundLaurelTexCoord[2]
			rankBackgroundTexCoord = RatedBattlegroundRankBackgroundTexCoord[2]
		elseif C_InRange(currRankID, 11, 14) then
			laurelCoord = RatedBattlegroundLaurelTexCoord[3]
			rankBackgroundTexCoord = RatedBattlegroundRankBackgroundTexCoord[3]
		end
	end

	currStRank = currStRank or 0
	currRankID = currRankID or 0
	currRating = currRating or 0
	nextRankID = nextRankID or 0
	nextRating = nextRating or 0
	weekWins = weekWins or 0
	weekGames = weekGames or 0
	totalWins = totalWins or 0
	totalGames = totalGames or 0
	nextRankIconCoord = nextRankIconCoord or RatedBattleGroundRankCoords[nextRankID == 0 and 1 or nextRankID]
	laurelCoord = laurelCoord or RatedBattlegroundLaurelTexCoord[1]

	return currTitle, currStRank, currRankID, currRankIconCoord, currRating, nextTitle, nextRankID, nextRankIconCoord, nextRating, weekWins, weekGames, totalWins, totalGames, laurelCoord, rankBackgroundTexCoord
end

function GetUnitRatedBattlegroundRankInfo( unit )
	local currTitle, currRankID, currRankIconCoord, currRating, weekWins, weekGames, totalWins, totalGames, laurelCoord, rankBackgroundTexCoord

	if unit then
		local playerGUID = UnitGUID(unit)

		if playerGUID and UnitIsPlayer(unit) then
			local storage 	= C_CacheInstance:Get("ASMSG_CHARACTER_BG_INFO", {})
			local data 		= storage[tonumber(playerGUID)]

			if data and (data.ttl and data.ttl > time()) then
				currRankID 	= data.currRankID or 0
				currRating 	= data.currRating or 0
				weekWins 	= data.weekWins or 0
				weekGames 	= data.weekGames or 0
				totalWins 	= data.totalWins or 0
				totalGames 	= data.totalGames or 0

				if currRankID and currRankID ~= 0 then
					local factionGroup, factionName = UnitFactionGroup(unit)

					if factionGroup then
						currTitle = _G[string.format("PVP_RANK_%d_%d", (currRankID + 4), factionGroup == "Alliance" and 1 or 0)]
					end
				else
					currTitle = RATED_BATTLEGROUND_NORANK
				end

				if currRankID and RatedBattleGroundRankCoords[currRankID] then
					currRankIconCoord = RatedBattleGroundRankCoords[currRankID]
				end

				if C_InRange(currRankID, 0, 5) then
					laurelCoord = RatedBattlegroundLaurelTexCoord[1]
					rankBackgroundTexCoord = RatedBattlegroundRankBackgroundTexCoord[1]
				elseif C_InRange(currRankID, 6, 10) then
					laurelCoord = RatedBattlegroundLaurelTexCoord[2]
					rankBackgroundTexCoord = RatedBattlegroundRankBackgroundTexCoord[2]
				elseif C_InRange(currRankID, 11, 14) then
					laurelCoord = RatedBattlegroundLaurelTexCoord[3]
					rankBackgroundTexCoord = RatedBattlegroundRankBackgroundTexCoord[3]
				end
			else
				if UnitIsPlayer(unit) then
					SendServerMessage("ACMSG_BG_STATS_REQUEST", playerGUID)
				end
			end
		end
	end

	currRankID 	= currRankID or 0
	currRating 	= currRating or 0
	weekWins 	= weekWins or 0
	weekGames 	= weekGames or 0
	totalWins 	= totalWins or 0
	totalGames 	= totalGames or 0

	laurelCoord = laurelCoord or RatedBattlegroundLaurelTexCoord[1]

	return currTitle, currRankID, currRankIconCoord, currRating, weekWins, weekGames, totalWins, totalGames, laurelCoord, rankBackgroundTexCoord, unit
end

function GetRatedBattlegroundRankByTitle( title )
	return RatedBattlegroundRankIndex[title]
end

function TogglePVPUIFrame()
	if ( PVPFrame_IsJustBG() ) then
		PVPFrame_SetJustBG(false)
	else
		if ( UnitLevel("player") >= 10 ) then
			ToggleFrame(PVPUIFrame)
		end
	end
	UpdateMicroButtons()
end

function PVPMicroButton_SetPushed()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 5, -31);
	PVPMicroButtonTexture:SetAlpha(0.5);
end

function PVPMicroButton_SetNormal()
	PVPMicroButtonTexture:SetPoint("TOP", PVPMicroButton, "TOP", 6, -30);
	PVPMicroButtonTexture:SetAlpha(1.0);
end

PVPUIFRAME_PORTRAIT_DATA = {
	[0] = "Interface\\Icons\\INV_BannerPVP_01",
	[1] = "Interface\\Icons\\INV_BannerPVP_02",
	[2] = "Interface\\Icons\\INV_BannerPVP_03_2",
}

function PVPUIFrame_OnLoad( self, ... )
	self.Shadows:SetFrameLevel(3)

	local function UpdateFactionArt()
		SetPortraitToTexture(self.Art.portrait, PVPUIFRAME_PORTRAIT_DATA[C_Unit:GetFactionID("player")])
	end

	C_FactionManager:RegisterFactionOverrideCallback(UpdateFactionArt, true)

	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("ARENA_TEAM_UPDATE")
	self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
	self:RegisterEvent("PLAYER_PVP_RANK_CHANGED")
	self:RegisterEvent("HONOR_CURRENCY_UPDATE")
	self:RegisterEvent("UNIT_LEVEL")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("VARIABLES_LOADED")

	PVPFrame_SetupTitle()
end

function PVPFrame_SetupTitle()
	local seasonInfo = C_CacheInstance:Get("ASMSG_PVP_SEASON", {})
	local isActiveSeason = GetCurrentArenaSeason() ~= NO_ARENA_SEASON
	if isActiveSeason then
		if seasonInfo.currentSeason and seasonInfo.seasonEnd then
			local remainingTime = seasonInfo.seasonEnd - time()

			if remainingTime > 0 then
				PVPUIFrame.Art.TitleText:SetFormattedText(PVPFRAME_LABEL, seasonInfo.currentSeason, GetRemainingTime(remainingTime))
			end

			if PVPUIFrame.TitleTimer then
				PVPUIFrame.TitleTimer:Cancel()
				PVPUIFrame.TitleTimer = nil
			end

			PVPUIFrame.TitleTimer = C_Timer:NewTicker(1, function()
				local remainingTime = seasonInfo.seasonEnd - time()

				if remainingTime > 0 then
					PVPUIFrame.Art.TitleText:SetFormattedText(PVPFRAME_LABEL, seasonInfo.currentSeason, GetRemainingTime(remainingTime))
				end
			end)
		end
	else
		PVPUIFrame.Art.TitleText:SetText(PVPFRAME_LABEL_NOSEASON)
	end
end

function PVPFrame_TabOnClick( self, button, ... )
	PlaySound("igCharacterInfoTab")
	HideUIPanel(self:GetParent())
	ShowUIPanel(_G[panels[self:GetID()].name])
end

function PVPFrame_TabOnShow( self )
	PanelTemplates_TabResize(self, 0, nil, self:GetTextWidth());
end

local lastCategoryButtonSelect
function PVPUIFrame_OnShow( self, ... )
	local categoryButton = lastCategoryButtonSelect and _G["PVPQueueFrameCategoryButton"..lastCategoryButtonSelect] or PVPQueueFrame.CategoryButton3
	categoryButton:Click()

	PanelTemplates_SetTab(self, 2)
	UpdateMicroButtons()

	if UnitLevel("player") < 15 then
		PanelTemplates_DisableTab(self, 1)
	else
		PanelTemplates_EnableTab(self, 1)
	end

	PVPFrame_SetupTitle()
end

function PVPUIFrame_OnHide( self, ... )
	PVPUI_ArenaTeamDetails:Hide()
	UpdateMicroButtons()
	CloseBattlefield()

	if PVPUIFrame.TitleTimer then
		PVPUIFrame.TitleTimer:Cancel()
		PVPUIFrame.TitleTimer = nil
	end

	LAST_FINDPARTY_FRAME = self
end

function PVPUIFrame_OnEvent( self, event, ... )
	if event == "PLAYER_LOGIN" then
		PVPUIFrame_UpdateData()
	elseif event == "ARENA_TEAM_UPDATE" then
		if PVPUI_ArenaTeamDetails:IsShown() and PVPUI_ArenaTeamDetails.team then
			ArenaTeamRoster(PVPUI_ArenaTeamDetails.team)
			PVPUI_ArenaTeamDetails_Update(PVPUI_ArenaTeamDetails.team)
		end
		ConquestFrame_ArenaUpdate()
	elseif event == "ARENA_TEAM_ROSTER_UPDATE" then
		if PVPUI_ArenaTeamDetails:IsShown() and PVPUI_ArenaTeamDetails.team then
			ArenaTeamRoster(PVPUI_ArenaTeamDetails.team)
			PVPUI_ArenaTeamDetails_Update(PVPUI_ArenaTeamDetails.team)
		end
		ConquestFrame_ArenaUpdate()
	elseif event == "PLAYER_PVP_KILLS_CHANGED" then
		PVPUIFrame_UpdateData()
	elseif event == "PLAYER_PVP_RANK_CHANGED" then
		PVPUIFrame_UpdateData()
	elseif event == "HONOR_CURRENCY_UPDATE" then
		PVPUIFrame_UpdateData()
	elseif event == "UNIT_LEVEL" then
		PVPUIFrame_UpdateData()
	elseif event == "UPDATE_BATTLEFIELD_STATUS" then
		local id = ...
		local status, mapName = GetBattlefieldStatus(id)

		if status == "queued" then
			UIErrorsFrame:AddMessage(string.format(BATTLEFIELD_IN_QUEUE_SIMPLE, mapName), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1.0)
		end
	elseif event == "VARIABLES_LOADED" then
		UpdatePVPTabs(self)
	end
end

function PVPHonorFrame_OnLoad( self, ... )
	PVPHonorFrame.type = "bonus"

	PVPHonorFrameSpecificFrame.scrollBar.doNotHide = true
	PVPHonorFrameSpecificFrame.update = HonorFrameSpecificList_Update
	HybridScrollFrame_CreateButtons(PVPHonorFrameSpecificFrame, "PVPSpecificBattlegroundButtonTemplate", -4, 0.5)
	HybridScrollFrame_OnLoad(PVPHonorFrameSpecificFrame)
end

function PVPHonorFrame_OnEvent( self, event, ... )
	-- body
end

function PVPHonorFrameSpecificFrame_OnShow( self, ... )
	local buttons = self.buttons
	for i = 1, #buttons do
		buttons[i].SelectedTexture:Hide()
		buttons[i].NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		buttons[i].SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	end
end

function HonorFrameSpecificList_Update()
	local scrollFrame = PVPHonorFrameSpecificFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local numBattlegrounds = GetNumBattlegroundTypes()
	local selectionID = scrollFrame.selectionID
	local buttonCount = -offset

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)

		if ( localizedName and canEnter and not isRandom ) then
			buttonCount = buttonCount + 1
			if ( buttonCount > 0 and buttonCount <= numButtons ) then
				local button = buttons[buttonCount]
				local BGData

				button.notShow = nil

				if BattlegroundsData and BattlegroundsData[BattleGroundID] then
					BGData = BattlegroundsData[BattleGroundID]
					button.SizeText:SetFormattedText("%d на %d", BGData.maxPlayers, BGData.maxPlayers)
					button.Icon:SetTexture("INTERFACE\\LFGFRAME\\"..BGData.icon)

					if BGData.showOnlyGM and BGData.showOnlyGM ~= IsGMAccount() then
						buttonCount = buttonCount - 1
						button.notShow = true
					elseif BGData.showOnlyGM and BGData.showOnlyGM == IsGMAccount() then
						localizedName = "[DEV] " .. localizedName
					end

					button.InfoText:SetText(BGData.gameType)

					button.longDescription = BGData.longDescription
				end

				if C_Service:IsGM() or IsDevClient() then
					localizedName = localizedName .. " - " .. BattleGroundID
				end

				button.NameText:SetText(localizedName)

				button:SetShown(not button.notShow)
				button.bgID = i
				button.name = localizedName

				if PVPHonorFrameSpecificFrame.selectionID and PVPHonorFrameSpecificFrame.selectionID == button.bgID then
					button.SelectedTexture:Show()
					button.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
					button.SizeText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
				else
					button.SelectedTexture:Hide()
					button.NameText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
					button.SizeText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
				end
			end
		end
	end

	buttonCount = max(buttonCount, 0)
	for i = buttonCount + 1, numButtons do
		buttons[i]:Hide()
	end

	local totalHeight = (buttonCount + offset) * 41.5
	HybridScrollFrame_Update(scrollFrame, totalHeight, numButtons * scrollFrame.buttonHeight)

	HonorFrame_UpdateQueueButtons()
end

function HonorFrameSpecificBattlegroundButton_OnClick( self, ... )
	PVPHonorFrameSpecificFrame.selectionID = self.bgID

	HonorFrameSpecificList_Update()
	HonorFrame_UpdateQueueButtons()
end

function HonorFrame_UpdateQueueButtons()
	local canQueue
	local selectedButtonID = PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton and PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton:GetID()
	local currentMapAreaID = GetCurrentMapAreaID()

	if ( currentMapAreaID == 915 or currentMapAreaID == 898 ) then
		canQueue = false
	elseif ( PVPHonorFrame.type == "specific" ) then
		if ( PVPHonorFrameSpecificFrame.selectionID ) then
			canQueue = true
		end
	elseif ( PVPHonorFrame.type == "bonus" ) then
		if ( selectedButtonID ) then
			canQueue = true
			if selectedButtonID == 0 then
				if GetWintergraspWaitTime() and GetWintergraspWaitTime() >= 900 then
					canQueue = false
				end
			end
		end
	end

	PVPHonorFrame.SoloQueueButton:SetEnabled(canQueue)
	PVPHonorFrame.GroupQueueButton:SetEnabled(canQueue and IsPartyLeader() and (selectedButtonID and selectedButtonID ~= 0))

	RatedBattlegroundFrame.SoloQueueButton:SetEnabled(true)
	RatedBattlegroundFrame.GroupQueueButton:SetEnabled(IsPartyLeader())
end

function PVPHonorFrame_OnShow( self, ... )
	HonorFrame_SetType(PVPHonorFrame.type or "bonus")

	local wintergraspWaitTime = GetWintergraspWaitTime()
	local worldPVP2Button = PVPHonorFrame.BottomInset.WorldPVPContainer.WorldPVP2Button

	worldPVP2Button.Contents.TimeText:SetShown(wintergraspWaitTime)
	worldPVP2Button.Contents.NextBattleText:SetShown(wintergraspWaitTime)
	worldPVP2Button.Contents.InProgressText:SetShown(not wintergraspWaitTime or wintergraspWaitTime == 0)

	worldPVP2Button.Contents.TimeText:SetRemainingTime(wintergraspWaitTime or 0)

	if worldPVP2Button.Timer then
		worldPVP2Button.Timer:Cancel()
		worldPVP2Button.Timer = nil
	end

	worldPVP2Button.Timer = C_Timer:NewTicker(1, function()
		local wintergraspWaitTime = GetWintergraspWaitTime()

		if not wintergraspWaitTime or wintergraspWaitTime == 0 or not self:IsShown() then
			worldPVP2Button.Timer:Cancel()
			worldPVP2Button.Timer = nil
		end

		worldPVP2Button.Contents.TimeText:SetRemainingTime(wintergraspWaitTime or 0)
	end)

	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.CallToArmsButton:SetID(33)

	for i = 1, GetNumBattlegroundTypes() do
		local BGname, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)

		if isHoliday and not isRandom then
			-- none
		elseif isRandom and not isHoliday then
			PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton:SetID(i)
		end
	end

	if UnitLevel("player") < 10 then
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton:Disable()
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton.Contents.Title:SetTextColor(0.5, 0.5, 0.5)
	else
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton:Enable()
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton.Contents.Title:SetTextColor(1, 1, 1)

		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.RandomBGButton:Click()
	end

	HonorFrameBonusFrame_Update()
	HonorFrame_UpdateQueueButtons()
end

function PVPHonorFrame_OnHide( self, ... )
	HelpPlate_Hide(false)

	if self.BottomInset.WorldPVPContainer.WorldPVP2Button.Timer then
		self.BottomInset.WorldPVPContainer.WorldPVP2Button.Timer:Cancel()
		self.BottomInset.WorldPVPContainer.WorldPVP2Button.Timer = nil
	end
end

function HonorFrameBonusFrame_Update()
	-- body
end

function HonorFrameBonusFrame_SelectButton( button )
	if ( PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton ) then
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton.SelectedTexture:Hide()
	end
	button.SelectedTexture:Show()
	PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton = button
	HonorFrame_UpdateQueueButtons()
end

function PVPHonorFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo()

	info.text = BONUS_BATTLEGROUNDS
	info.value = "bonus"
	info.func = HonorFrameTypeDropDown_OnClick
	info.checked = PVPHonorFrame.type == info.value
	if ( UnitLevel("player") < 10 ) then
		info.disabled = 1
		info.tooltipWhileDisabled = 1
		info.tooltipTitle = UNAVAILABLE
		info.tooltipText = string.format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10)
		info.tooltipOnButton = 1
	end
	UIDropDownMenu_AddButton(info)

	info.text = SPECIFIC_BATTLEGROUNDS
	info.value = "specific"
	info.func = HonorFrameTypeDropDown_OnClick
	info.checked = PVPHonorFrame.type == info.value
	info.disabled = nil
	UIDropDownMenu_AddButton(info)
end

function HonorFrameTypeDropDown_OnClick(self)
	HonorFrame_SetType(self.value)
end

function HonorFrame_SetType( value )
	PVPHonorFrame.BottomInset.BonusBattlegroundRadioButton:SetChecked(value == "bonus")
	PVPHonorFrame.BottomInset.SpecificBattlegroundRadioButton:SetChecked(value == "specific")

	local container = value == "bonus" and PVPHonorFrame.BottomInset.BonusBattlefieldContainer or PVPHonorFrame.BottomInset.SpecificFrame
	if PVPHonorFrame.type == value and container:IsShown() then
		return
	end

	PVPHonorFrame.type = value

	PVPHonorFrame.BottomInset.BonusBattlefieldContainer:SetShown(value == "bonus")
	PVPHonorFrame.BottomInset.WorldPVPContainer:SetShown(value == "bonus")
	PVPHonorFrame.BottomInset.SpecificFrame:SetShown(value == "specific")
	PVPHonorFrame.BottomInset.ShadowOverlay:SetShown(value == "bonus")
	PVPHonorFrame.PVPHonorFrameHelpButton:SetShown(value == "bonus")

	PVPHonorFrameSpecificFrame.selectionID = nil

	HonorFrame_UpdateQueueButtons()
	HelpPlate_Hide(false)
end

function PVPQueueFrame_OnLoad( self, ... )
	SetPortraitToTexture(self.CategoryButton3.Icon, "Interface\\Icons\\achievement_bg_winwsg")
	self.CategoryButton3.Name:SetText(HONOR_CONTRIBUTION_POINTS)

	SetPortraitToTexture(self.CategoryButton2.Icon, "Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
	self.CategoryButton2.Name:SetText(PVP_TAB_CONQUEST)

	SetPortraitToTexture(self.CategoryButton1.Icon, "Interface\\Icons\\Achievement_ChallengeMode_StormstoutBrewery_Bronze")
	self.CategoryButton1.Name:SetText(PVP_TAB_SERVICES)

	local function SetCurrencyIcon()
		local factionID = C_Unit:GetFactionID("player")
		self.CategoryButton3.CurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor-"..PLAYER_FACTION_GROUP[factionID])
		self.CategoryButton2.CurrencyIcon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest-"..PLAYER_FACTION_GROUP[factionID])
	end

	C_FactionManager:RegisterFactionOverrideCallback(SetCurrencyIcon, true)
end

function PVPQueueFrame_OnShow( self, ... )
	PVPQueueFrame_SelectArena(ConquestFrame.state or 1)

	PVPUIFrame_UpdateData()
	ConquestFrame_ArenaUpdate()
end

function PVPQueueFrame_OnEvent( self, ... )
	-- body
end

function PVPQueueFrame_OnHide( self, ... )
	if self.updateArenaTimer then
		self.updateArenaTimer:Cancel()
		self.updateArenaTimer = nil
	end

	PVPQueueFrame.selectedCategory = nil
end

function PVPUI_ArenaTeamDetails_OnLoad( self, ... )
	PanelTemplates_SetNumTabs(self, 2)
	PVPUI_ArenaTeamDetails_OnTabClick(1)
end

function PVPUI_ArenaTeamDetails_OnShow( self, ... )
	-- body
end

function PVPUI_ArenaTeamDetails_OnHide( self, ... )
	-- body
end

function PVPUI_ArenaTeamDetails_OnTabClick( tabID )
	PanelTemplates_SetTab(PVPUI_ArenaTeamDetails, tabID)

	if PVPUI_ArenaTeamDetails:IsShown() then
		PVPUI_ArenaTeamDetails.season = tabID == 2
		PVPUI_ArenaTeamDetails_Update(PVPUI_ArenaTeamDetails.team)
	end
end

function PVPQueueFrameButton_OnClick( self, ... )
	local buttonID = self:GetID()
	local frameName = pvpFrames[buttonID]
	local factionID = C_Unit:GetFactionID("player")

	if PVPQueueFrame.selectedCategory and PVPQueueFrame.selectedCategory == buttonID then
		return
	end

	PVPQueueFrame.CapTopFrame:SetShown(buttonID == 2 or buttonID == 3)
	PVPQueueFrame.StepBottomFrame:SetShown(buttonID == 2 or buttonID == 3)
	PVPQueueFrame.StepBottomFrame.Step4:SetShown(buttonID == 2)
	PVPQueueFrame.StepBottomFrame.Step3:SetShown(buttonID == 2)

	if buttonID == 2 then
		PVPQueueFrame.StepBottomFrame.StepEnd.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID])
		PVPQueueFrame.StepBottomFrame.StepEnd.WinLabel:SetFormattedText(PVPFRAME_STEPEND_WINS_LABEL, 5)

		if ConquestFrame.state == 1 then
			PVPFrame_StepButtonAndCapBarEnable()
		elseif ConquestFrame.state == 2 then
			PVPFrame_StepButtonAndCapBarDisable()
		end
	elseif buttonID == 3 then
		PVPQueueFrame.StepBottomFrame.StepEnd.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID])
		PVPQueueFrame.StepBottomFrame.StepEnd.WinLabel:SetFormattedText(PVPFRAME_STEPEND_WINS_LABEL, 3)

		PVPFrame_StepButtonAndCapBarEnable()
	end

	if PVPQueueFrame.StepBottomFrame.StepEnd.IsDisable then
		PVPQueueFrame.StepBottomFrame.StepEnd.Icon:SetDesaturated(true)
	end

	PVPQueueFrame.CapTopFrame.DisableOverlay:Hide()
	PVPQueueFrame.StepBottomFrame.DisableOverlay:Hide()

	PVPFrameStepButton_UpdateState(buttonID)
	PVPQueueFrameCapTopFrameStatusBar_UpdateValue(buttonID)
	PVPFrameStepButton_UpdateReward(buttonID)
	PVPQueueFrame_UpdateReward(buttonID)

	PVPQueueFrame_ShowFrame(_G[frameName])

	PlaySound("igCharacterInfoOpen")

	PVPQueueFrame.selectedCategory = buttonID
	lastCategoryButtonSelect = buttonID
end

function PVPQueueFrame_ShowFrame( frame )
	frame = frame or PVPQueueFrame.selection or HonorFrame
	for index, frameName in pairs(pvpFrames) do
		local pvpFrame = _G[frameName]
		if ( pvpFrame == frame ) then
			PVPQueueFrame_SelectButton(index)
		else
			pvpFrame:Hide()
		end
	end
	frame:Show()
	PVPQueueFrame.selection = frame
end

function PVPQueueFrame_SelectButton( index )
	local self = PVPQueueFrame
	for i = 1, #pvpFrames do
		local button = self["CategoryButton"..i]
		if ( i == index ) then
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188)
		else
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
		end
	end
end

function ConquestFrameButton_OnClick( self, button )
	local buttonID = self:GetID()

	CloseDropDownMenus()
	ConquestFrame_SelectButton(self)
	PlaySound("igMainMenuOptionCheckBoxOn")

	if buttonID == 1 or buttonID == 2 or buttonID == 5 then
		PVPFrameStepButton_UpdateReward(2)
		PVPQueueFrame_UpdateReward(2)
	end
end

function ConquestFrame_SelectButton(button, isSkirmish)
	button.SelectedTexture:Show()
	if isSkirmish then
		if ConquestFrame.selectedButtonSkirmish and ConquestFrame.selectedButtonSkirmish ~= button then
			ConquestFrame.selectedButtonSkirmish.SelectedTexture:Hide()
		end

		ConquestFrame.selectedButtonSkirmish = button
	else
		if ConquestFrame.selectedButton and ConquestFrame.selectedButton ~= button then
			ConquestFrame.selectedButton.SelectedTexture:Hide()
		end

		ConquestFrame.selectedButton = button

		PVPFrameStepButton_UpdateState(2)
		PVPQueueFrameCapTopFrameStatusBar_UpdateValue(2)
	end

	ConquestFrame_UpdateJoinButton()
end

function BottomInsetTypeDropDown_Initialize( self, ... )
	local info = UIDropDownMenu_CreateInfo()

	info.text = RATED_BATTLE_LABEL
	info.value = 1
	info.checked = checked
	info.func = BottomInsetTypeDropDown_OnClick
	UIDropDownMenu_AddButton(info)

	info.text = SKIRMISH_LABEL
	info.value = 2
	info.checked = checked
	info.func = BottomInsetTypeDropDown_OnClick
	UIDropDownMenu_AddButton(info)
end

function BottomInsetTypeDropDown_OnClick( self, ... )
	UIDropDownMenu_SetSelectedValue(ConquestFrame.BottomInset.TypeDropDown, self.value)
	PVPQueueFrame_SelectArena(self.value)
end

function PVPQueueFrame_SelectArena( state )
	ConquestFrame.BottomInset.RatedConquestRadioButton:SetChecked(state == 1)
	ConquestFrame.BottomInset.SkirmishConquestRadioButton:SetChecked(state == 2)

	if ConquestFrame.state == state then
		return
	end

	ConquestFrame.state = state

	ConquestFrame.BottomInset.ArenaContainer:SetShown(state == 1)
	ConquestFrame.BottomInset.SoloArenaContainer:SetShown(state == 1)
	ConquestFrame.BottomInset.ArenaSkirmishContainer:SetShown(state == 2)

	if state == 1 then
		if not ConquestFrame.selectedButton then
			ConquestFrame.BottomInset.ArenaContainer.Arena2v2:Click()
		end

		PVPFrame_StepButtonAndCapBarEnable()
		PVPFrameStepButton_UpdateState(2)
		PVPQueueFrameCapTopFrameStatusBar_UpdateValue(2)
	elseif state == 2 then
		if not ConquestFrame.selectedButtonSkirmish then
			ConquestFrame.BottomInset.ArenaSkirmishContainer.ArenaSkirmish2v2:Click()
		end

		PVPFrame_StepButtonAndCapBarDisable()
	end

	ConquestFrame.NoSeason:SetShown(GetCurrentArenaSeason() == NO_ARENA_SEASON and state ~= 2)
	ConquestFrame_UpdateJoinButton()
end

function PVPUIFrame_UpdateData()
	local hk, cp, dk, contribution, rank, highestRank, rankName, rankNumber

	hk, contribution = GetPVPYesterdayStats()
	PVPUIHonorLabelYesterdayKills:SetText(hk)
	PVPUIHonorLabelYesterdayHonor:SetText(contribution)

	hk, contribution =  GetPVPLifetimeStats()
	PVPUIHonorLabelLifetimeKills:SetText(hk)

	hk, cp = GetPVPSessionStats()
	PVPUIHonorLabelTodayKills:SetText(hk)
	PVPUIHonorLabelTodayHonor:SetText(cp)
	PVPUIHonorLabelTodayHonor:SetHeight(14)

	PVPQueueFrame.CategoryButton3.CurrencyAmount:SetText(GetHonorCurrency())
	PVPQueueFrame.CategoryButton2.CurrencyAmount:SetText(GetArenaCurrency())

	PlayerFrame_UpdatePvPStatus()
	ConquestFrame_UpdateJoinButton()
end

function PVPConquestSkirmishButton_OnClick( self, ... )
	CloseDropDownMenus()
	ConquestFrame_SelectButton( self, true )
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function ConquestFrame_UpdateJoinButton()
	local button = ConquestJoinButton
	local groupSize = GetNumPartyMembers() + 1
	local currentMapAreaID = GetCurrentMapAreaID()

	if currentMapAreaID == 915 or currentMapAreaID == 898 then
		button:Disable()
		return
	end

	if ConquestFrame.state == 2 and ConquestFrame.selectedButtonSkirmish then
		button:Enable()
		return
	elseif ConquestFrame.state == 2 or GetCurrentArenaSeason() ~= NO_ARENA_SEASON then
		if ConquestFrame.selectedButton then
			if ConquestFrame.selectedButton.id == 1 or ConquestFrame.selectedButton.id == 5 then
				if groupSize > 1 then
					button.tooltip = CONQUEST_JOIN_ERROR_1
				else
					button:Enable()
					button.tooltip = nil
					return
				end
			else
				if groupSize == 0 then
					button.tooltip = PVP_NO_QUEUE_GROUP
				elseif not IsPartyLeader() then
					button.tooltip = PVP_NOT_LEADER
				else
					local neededSize = CONQUEST_SIZES[ConquestFrame.selectedButton.id]
					local token, loopMax
					if groupSize > (MAX_PARTY_MEMBERS + 1) then
						token = "raid"
						loopMax = groupSize
					else
						token = "party"
						loopMax = groupSize - 1
					end
					if neededSize == groupSize then
						local validGroup = true
						for i = 1, loopMax do
							if not UnitIsConnected(token..i) then
								validGroup = false
								button.tooltip = PVP_NO_QUEUE_DISCONNECTED_GROUP
								break
							end
						end
						if validGroup then
							button.tooltip = nil
							button:Enable()
							return
						end
					else
						button.tooltip = string.format(RATED_BATTLEGROUND_GROUP_MEMBER_ERROR, neededSize)
					end
				end
			end
		else
			button.tooltip = PVP_SELECT_BRACKET
		end
	end

	button:Disable()
end

function ConquestFrameJoinButton_OnClick( self, ... )
	if not ConquestFrame.state or not ConquestFrame.selectedButton then
		return
	end

	local isParty = GetNumPartyMembers() >= 1 and 1 or 0
	local state = ConquestFrame.state == 2 and 0 or 1
	local selectedButton = ConquestFrame.state == 1 and ConquestFrame.selectedButton or ConquestFrame.selectedButtonSkirmish

	if isParty == 1 and not IsPartyLeader() then
		UIErrorsFrame:AddMessage(ERR_NOT_LEADER, 1.0, 0.1, 0.1, 1.0)
		return
	end

	local formatedMessage = string.format("%d:%d:%d", selectedButton:GetID() - 1, isParty, state)
	SendServerMessage("ACMSG_JOIN_ARENA_REQUEST", formatedMessage)
end

function ConquestFrame_ArenaUpdate()

end

local CONQUEST_TOOLTIP_PADDING = 220
function ConquestFrameButton_OnEnter( self, ... )
	if self:IsEnabled() ~= 0 then
		local tooltip = ConquestTooltip
		local buttonID = self:GetID()
		local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})

		tooltip.TodayBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, pvpStats[buttonID] and pvpStats[buttonID].TodayWins or 0)
		tooltip.TodayGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, pvpStats[buttonID] and pvpStats[buttonID].TodayGames or 0)
		tooltip.WeeklyBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, pvpStats[buttonID] and pvpStats[buttonID].weekWins or 0)
		tooltip.WeeklyGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, pvpStats[buttonID] and pvpStats[buttonID].weekGames or 0)
		tooltip.SeasonBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, pvpStats[buttonID] and pvpStats[buttonID].seasonWins or 0)
		tooltip.SeasonGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, pvpStats[buttonID] and pvpStats[buttonID].seasonGames or 0)

		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
		tooltip:Show()
	end
end

function PVPUI_ArenaTeamDetails_Update( id )
	local self = PVPUI_ArenaTeamDetails
	local teamName, teamSize, teamRating, teamPlayed, teamWins,  seasonTeamPlayed, seasonTeamWins, playerPlayed, seasonPlayerPlayed, teamRank, personalRating  = GetArenaTeam(id)

	if not teamName then
		self:Hide()
		return
	end

	self.Tittle:SetFormattedText(ARENA_TEAM_DETAILS_TITLE, teamName, teamSize, teamSize)

	if PVPUI_ArenaTeamDetails.season then
		PVPUI_ArenaTeamDetailsColumnHeader3.sortType = "seasonplayed"
		PVPUI_ArenaTeamDetailsColumnHeader4.sortType = "seasonwon"
		self.Games:SetText(seasonTeamPlayed)
		self.Win:SetText(seasonTeamWins)
		self.Loss:SetText(seasonTeamPlayed - seasonTeamWins)
	else
		PVPUI_ArenaTeamDetailsColumnHeader3.sortType = "played"
		PVPUI_ArenaTeamDetailsColumnHeader4.sortType = "won"
		self.Games:SetText(teamPlayed)
		self.Win:SetText(teamWins)
		self.Loss:SetText(teamPlayed - teamWins)
	end

	self.Rank:SetText(teamRank)
	self.Rating:SetText(teamRating)

	local numMembers = GetNumArenaTeamMembers(id, 1)
	local playedValue, winValue, lossValue, playedPct

	for i = 1, 10, 1 do
		local button = _G["PVPUI_ArenaTeamDetailsButton"..i]

		if ( i > numMembers ) then
			button:Hide()
		else
			button.teamIndex = i
			local name, rank, level, class, online, played, win, seasonPlayed, seasonWin, rating = GetArenaTeamRosterInfo(id, i)
			local loss = played - win
			local seasonLoss = seasonPlayed - seasonWin

			if ( class ) then
				button.tooltip = LEVEL.." "..level.." "..class
			else
				button.tooltip = LEVEL.." "..level
			end

			if ( PVPUI_ArenaTeamDetails.season ) then
				playedValue = seasonPlayed
				winValue = seasonWin
				lossValue = seasonLoss
				teamPlayed = seasonTeamPlayed
			else
				playedValue = played
				winValue = win
				lossValue = loss
				teamPlayed = teamPlayed
			end

			if ( teamPlayed ~= 0 ) then
				playedPct =  floor( ( playedValue / teamPlayed ) * 100 )
			else
				playedPct =  floor( (playedValue / 1 ) * 100 )
			end

			if ( playedPct < 10 ) then
				_G["PVPUI_ArenaTeamDetailsButton"..i.."PlayedText"]:SetVertexColor(1.0, 0, 0)
			else
				_G["PVPUI_ArenaTeamDetailsButton"..i.."PlayedText"]:SetVertexColor(1.0, 1.0, 1.0)
			end

			playedPct = format("%d", playedPct)

			_G["PVPUI_ArenaTeamDetailsButton"..i.."Played"].tooltip = playedPct.."%"

			local nameText = _G["PVPUI_ArenaTeamDetailsButton"..i.."NameText"]
			local classText = _G["PVPUI_ArenaTeamDetailsButton"..i.."ClassText"]
			local playedText = _G["PVPUI_ArenaTeamDetailsButton"..i.."PlayedText"]
			local winLossWin = _G["PVPUI_ArenaTeamDetailsButton"..i.."WinLossWin"]
			local winLossLoss = _G["PVPUI_ArenaTeamDetailsButton"..i.."WinLossLoss"]
			local ratingText = _G["PVPUI_ArenaTeamDetailsButton"..i.."RatingText"]

			local nameButton = _G["PVPUI_ArenaTeamDetailsButton"..i.."Name"]
			local classButton = _G["PVPUI_ArenaTeamDetailsButton"..i.."Class"]
			local playedButton = _G["PVPUI_ArenaTeamDetailsButton"..i.."Played"]
			local winLossButton = _G["PVPUI_ArenaTeamDetailsButton"..i.."WinLoss"]

			nameText:SetText(name)
			classText:SetText(class)
			playedText:SetText(playedValue)
			winLossWin:SetText(winValue)
			winLossLoss:SetText(lossValue)
			ratingText:SetText(rating)

			local r, g, b
			if ( online ) then
				if ( rank > 0 ) then
					r = 1.0
					g = 1.0
					b = 1.0
				else
					r = 1.0
					g = 0.82
					b = 0.0
				end
			else
				r = 0.5
				g = 0.5
				b = 0.5
			end

			nameText:SetTextColor(r, g, b)
			classText:SetTextColor(r, g, b)
			playedText:SetTextColor(r, g, b)
			winLossWin:SetTextColor(r, g, b)
			_G["PVPUI_ArenaTeamDetailsButton"..i.."WinLoss-"]:SetTextColor(r, g, b)
			winLossLoss:SetTextColor(r, g, b)
			ratingText:SetTextColor(r, g, b)

			button:Show()

			if ( GetArenaTeamRosterSelection(id) == i ) then
				button:LockHighlight()
			else
				button:UnlockHighlight()
			end
		end
	end
end

function PVPUI_ArenaTeamDetails_OnClick( self, ... )
	if ( button == "LeftButton" ) then
		PVPUI_ArenaTeamDetails.previousSelectedTeamMember = PVPUI_ArenaTeamDetails.selectedTeamMember
		PVPUI_ArenaTeamDetails.selectedTeamMember = self.teamIndex
		SetArenaTeamRosterSelection(PVPUI_ArenaTeamDetails.team, PVPUI_ArenaTeamDetails.selectedTeamMember)
		PVPUI_ArenaTeamDetails_Update(PVPUI_ArenaTeamDetails.team)
	else
		local name, rank, level, class, online = GetArenaTeamRosterInfo(PVPUI_ArenaTeamDetails.team, self.teamIndex)
		PVPFrame_ShowDropdown(name, online)
	end
end

function PVPDropDown_Initialize()
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "TEAM", nil, PVPDropDown.name)
end

function PVPFrame_ShowDropdown(name, online)
	HideDropDownMenu(1)

	if ( not IsArenaTeamCaptain(PVPUI_ArenaTeamDetails.team) ) then
		if ( online ) then
			PVPDropDown.initialize = PVPDropDown_Initialize
			PVPDropDown.displayMode = "MENU"
			PVPDropDown.name = name
			PVPDropDown.online = online
			ToggleDropDownMenu(1, nil, PVPDropDown, "cursor")
		end
	else
		PVPDropDown.initialize = PVPDropDown_Initialize
		PVPDropDown.displayMode = "MENU"
		PVPDropDown.name = name
		PVPDropDown.online = online
		ToggleDropDownMenu(1, nil, PVPDropDown, "cursor")
	end
end

function PVPUI_ArenaTeamDetailsToggleButton_OnClick( self, ... )
	PlaySound("igMainMenuOptionCheckBoxOn")

	PVPUI_ArenaTeamDetails.season = not self:GetChecked()
	PVPUI_ArenaTeamDetails_Update(PVPUI_ArenaTeamDetails.team)
end

function HonorFrame_Queue(isParty, forceSolo)
	if (not isParty and not forceSolo and GetNumPartyMembers() > 1) then
		StaticPopup_Show("CONFIRM_JOIN_SOLO")
		return
	end

	local PVPHonorFrame = PVPHonorFrame
	if ( PVPHonorFrame.type == "specific" and PVPHonorFrameSpecificFrame.selectionID ) then
		RequestBattlegroundInstanceInfo(PVPHonorFrameSpecificFrame.selectionID)
		JoinBattlefield(PVPHonorFrameSpecificFrame.selectionID, isParty)
	elseif ( PVPHonorFrame.type == "bonus" and PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton ) then
		if ( PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton:GetID() == 0 ) then
			SendAddonMessage("ACMSG_JOIN_WINTERGRASP_REQUEST", nil, "WHISPER", UnitName("player"))
		elseif PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton:GetID() == 33 then
			Sirus_BattlegroundRegister(33, isParty)
		else
			RequestBattlegroundInstanceInfo(PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton:GetID())
			JoinBattlefield(PVPHonorFrame.BottomInset.BonusBattlefieldContainer.selectedButton:GetID(), isParty)
		end
	end
end

function RateBattleground_SetProgress(bar, currentValue)
	local MAX_BAR = bar:GetWidth() - 49
	bar.Progress:SetWidth(MAX_BAR * currentValue + 1)
end

function RatedBattlegroundHitArea_OnEnter( self, ... )
	local tooltip = RatedBattlegroundTooltip
	local _, _, _, _, _, _, _, _, _, weekWins, weekGames, totalWins, totalGames = GetRatedBattlegroundRankInfo()

	tooltip.WeeklyBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, weekWins)
	tooltip.WeeklyGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, weekGames)

	tooltip.SeasonBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, totalWins)
	tooltip.SeasonGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, totalGames)

	tooltip:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, 0)
	tooltip:Show()
end

function RatedBattlegroundStatisticsScrollFrame_OnLoad(self)
	ScrollFrame_OnLoad(self)

	local scrollBar = _G[self:GetName().."ScrollBar"]
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, 58)
	scrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 14)
end

function RatedBattlegroundStatisticsScrollFrame_OnShow(self)
	if not self.buttons then
		self.buttons = {}

		local numBattlegrounds = GetNumBattlegroundTypes()
		local buttonIndex = 0
		for i = 1, numBattlegrounds do
			local localizedName, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)

			if BattlegroundsData[BattleGroundID] and BattlegroundsData[BattleGroundID].statistics then
				buttonIndex = buttonIndex + 1

				local button = CreateFrame("Button", "RatedBattlegroundStatisticsScrollFrameButton"..buttonIndex, self.ScrollChild, "RatedBattlegroundStatisticsButtonTemplate")

				if buttonIndex == 1 then
					button:SetPoint("TOPLEFT", self.ScrollChild, "TOPLEFT", -1, 0)
				else
					button:SetPoint("TOP", self.buttons[buttonIndex - 1], "BOTTOM", 0, -4)
				end

				self.buttons[buttonIndex] = button
			end
		end
	end

	RatedBattlegroundStatisticsUpdate()
end

function RatedBattlegroundStatisticsUpdate()
	local scrollFrame = RatedBattlegroundStatisticsScrollFrame
	local buttons = scrollFrame.buttons
	local numButtons = #buttons

	local numBattlegrounds = GetNumBattlegroundTypes()
	local buttonCount = 0

	local numCollapsed = 0
	local collapsedButtonHeight = 0

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)

		if BattlegroundsData[BattleGroundID] and ( BattlegroundsData[BattleGroundID].statistics ) then
			buttonCount = buttonCount + 1

			if buttonCount > 0 and buttonCount <= numButtons then
				local button = buttons[buttonCount]
				local bgData = BattlegroundsData[BattleGroundID]
				local bgStatistics = BattlegroundsData[BattleGroundID].statistics
				local atlasInfo = C_Texture.GetAtlasInfo(bgData.backgroundAtlas)
				local bgCoords = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
				local numStatistics = GetNumBattlegroundStatustics(BattleGroundID)
				local recordWin, recordLose = GetBattlegroundRecordStatistics(BattleGroundID)

				button.bgID = BattleGroundID
				button.isCollapsed = bgStatistics.isCollapsed
				button.buttonID = buttonCount

				button.BattlegroundName:SetText(localizedName)
				button.BattleRecord:SetFormattedText("%d - %d", recordWin or 0, recordLose or 0)

				button.TogglePlus:SetShown(bgStatistics.isCollapsed)
				button.ToggleMinus:SetShown(not bgStatistics.isCollapsed)

				button.BattleRecordLabel:SetShown(button.isCollapsed)
				button.BattleRecord:SetShown(button.isCollapsed)

				button.TodayLabel:SetShown(not button.isCollapsed)
				button.LifetimeLabel:SetShown(not button.isCollapsed)

				for b = 1, 10 do
					button.StipButton[b]:Hide()
				end

				button.Background:SetAtlas(bgData.backgroundAtlas)

				if not bgStatistics.isCollapsed then
					for t = 1, numStatistics do
						local title, week, season = GetBattlegroundStatistics(BattleGroundID, t)
						local stripFrame 		  = button.StipButton[t]

						stripFrame.Title:SetText(title)
						stripFrame.Today:SetText(week)
						stripFrame.Lifetime:SetText(season)

						stripFrame:SetShown(title)
					end

					local height = (18 * (numStatistics)) + 47
					--local coef 	 = ((height + 6) / 300) * (bgCoords[4] - bgCoords[3])

					button:SetHeight(height)
					--button.Background:SetTexCoord(bgCoords[1], bgCoords[2], bgCoords[3], bgCoords[3] + coef)

					numCollapsed = numCollapsed + 1
					collapsedButtonHeight = collapsedButtonHeight + height

					-- MountJournal_UpdateScrollPos(scrollFrame, buttonCount)
				else
					local coef = ((42) / 300) * (bgCoords[4] - bgCoords[3])

					button:SetHeight(42)
					button.Background:SetTexCoord(bgCoords[1], bgCoords[2], bgCoords[3], bgCoords[3] + coef)
				end

				button:Show()
			end
		end
	end

	buttonCount = max(buttonCount, 0)
	for i = buttonCount + 1, numButtons do
		buttons[i]:Hide()
	end
end

PVPFRAME_PRESTIGE_LARGE_BACKGROUNDS = {
	[PLAYER_FACTION_GROUP.Horde] = {0.755859, 0.886719, 0.217773, 0.348633},
	[PLAYER_FACTION_GROUP.Alliance] = {0.623047, 0.753906, 0.217773, 0.348633},
	[PLAYER_FACTION_GROUP.Renegade] = {0.3154296875, 0.4462890625, 0.5009765625, 0.6318359375}
}

PVPFRAME_PRESTIGE_FACTION_ICONS = {
	[PLAYER_FACTION_GROUP.Horde] = {0.513672, 0.628906, 0.597656, 0.732422},
	[PLAYER_FACTION_GROUP.Alliance] = {0.380859, 0.496094, 0.730469, 0.865234},
	[PLAYER_FACTION_GROUP.Renegade] = {0.5166015625, 0.626953125, 0.7314453125, 0.8671875}
}

function RatedBattlegroundFrame_OnShow( self, ... )
	local currTitle, currStRank, currRankID, currRankIconCoord, currRating, nextTitle, _, nextRankIconCoord, nextRating, weekWins, weekGames, totalWins, totalGames, laurelCoord = GetRatedBattlegroundRankInfo()
	local factionID = C_Unit:GetFactionID("player")

	PVPHonorFrame.type = "bonus"

	self.Container:Show()
	self.StatisticsFrame:Hide()

	self.Container.WeekWins:SetText(weekWins)
	self.Container.SezonWins:SetText(totalWins)
	self.Container.WeekGames:SetText(weekGames)
	self.Container.SezonGames:SetText(totalGames)
	self.Container.WeekProc:SetText(weekGames == 0 and "0%" or math.ceil(weekWins / weekGames * 100).."%")
	self.Container.SezonProc:SetText(totalGames == 0 and "0%" or math.ceil(totalWins / totalGames * 100).."%")

	self.Container.CurrentRankLabel:SetText(not currTitle and RATED_BATTLEGROUND_NORANK or currTitle)
	if currRating == 0 then
		self.Container.YouRating:SetFormattedText(RATED_BATTLEGROUND_YOURATING, "-", currRankID)
	else
		self.Container.YouRating:SetFormattedText(RATED_BATTLEGROUND_YOURATING, currRating, currRankID)
	end

	if laurelCoord then
		self.Container.Laurel:SetTexCoord(unpack(laurelCoord))
	end

	if currRankID == 0 and factionID then
		self.Container.RankIcon:ClearAllPoints()
		self.Container.RankIcon:SetPoint("CENTER", self.Container.Laurel, 0, 2)
		self.Container.RankIcon:SetTexture("Interface\\PVPFrame\\PvPQueue")
		self.Container.RankIcon:SetSize(86, 106)

		self.Container.RankIcon:SetTexCoord(unpack(PVPFRAME_PRESTIGE_FACTION_ICONS[factionID]))
	else
		self.Container.RankIcon:ClearAllPoints()
		self.Container.RankIcon:SetPoint("CENTER", self.Container.Laurel, -2, 3)
		self.Container.RankIcon:SetTexture("Interface\\PVPFrame\\PvPPrestigeIcons")
		self.Container.RankIcon:SetSize(64, 64)
	end

	if currRankIconCoord then
		self.Container.RankIcon:SetTexCoord(unpack(currRankIconCoord))
	end

	self.Container.LaurelBackground:SetTexCoord(unpack(PVPFRAME_PRESTIGE_LARGE_BACKGROUNDS[factionID]))

	RatedBattlegroundProgressBarFrame.NextRankIcon:SetShown(nextRankIconCoord)
	if nextRankIconCoord then
		RatedBattlegroundProgressBarFrame.NextRankIcon:SetTexCoord(unpack(nextRankIconCoord))
	end

	RatedBattlegroundProgressBarFrame.Level:SetShown(currRankID < 14)

	if nextTitle and currRankID < 14 then
		RatedBattlegroundProgressBarFrame.Level:SetFormattedText(RATED_BATTLEGROUND_NEXTRANK, nextTitle)
	end

	-- currRating = currRankID >= 14 and 9999 or currRating
	RateBattleground_SetProgress(RatedBattlegroundProgressBarFrame, currRating ~= 0 and ((nextRating - currStRank) - (nextRating - currRating)) / (nextRating - currStRank) or currRating, nextRating)
end

function RatedBattlegroundFrame_OnHide( self, ... )
	RatedBattlegroundFrame.StatisticsButton:UnlockHighlight()
	HelpPlate_Hide(false)
end

function RatedBattlegroundProgressBarFrame_OnEnter( self, ... )
	local currTitle, currStRank, currRankID, currRankIconCoord, currRating, nextTitle, nextRankID, nextRankIconCoord, nextRating, weekWins, weekGames, totalWins, totalGames = GetRatedBattlegroundRankInfo()
	if nextTitle and currRating and nextRating then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(RATED_BATTLEGROUND_TOOLTIP_NEXTRANK, 1, 1, 1)
		GameTooltip:AddLine(string.format( "%d / %d", currRating, nextRating), nil, nil, nil, true)
		GameTooltip:Show()
	end
end

local ConquestFrame_HelpPlate = {
	FramePos = { x = 0, y = 0 },
	FrameSize = { width = 343, height = 428 },
	[1] = { ButtonPos = { x = 312, y = -10 }, HighLightBox = { x = 2, y = -2, width = 336, height = 60 }, ToolTipDir = "DOWN", ToolTipText = CONQUESTFRAME_TUTORIAL_1 },
	[2] = { ButtonPos = { x = 312, y = -86 }, HighLightBox = { x = 250, y = -92, width = 84, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = CONQUESTFRAME_TUTORIAL_2 },
	-- [5] = { ButtonPos = { x = 294, y = -280 }, HighLightBox = { x = 20, y = -280, width = 298, height = 42 }, ToolTipDir = "RIGHT", ToolTipText = CONQUESTFRAME_TUTORIAL_4 },
}

function ConquestFrame_ToggleTutorial( self, ... )
	local rewardFinalStepCurrency = C_CacheInstance:Get("ASMSG_PVP_DAILY_REWARDS", {})
	local arenaReward = ConquestFrame.selectedButton == ConquestFrame.BottomInset.SoloArenaContainer.ArenaSolo and rewardFinalStepCurrency.arenaRewardSolo
		or ConquestFrame.selectedButton == ConquestFrame.BottomInset.ArenaContainer.Arena1v1 and rewardFinalStepCurrency.arenaReward1v1
		or rewardFinalStepCurrency.arenaReward2v2

	if arenaReward then
		ConquestFrame_HelpPlate[3] = { ButtonPos = { x = 312, y = -336 }, HighLightBox = { x = 2, y = -334, width = 336, height = 48 }, ToolTipDir = "RIGHT", ToolTipText = string.format(CONQUESTFRAME_TUTORIAL_3, arenaReward) }
	end

	local helpPlate = ConquestFrame_HelpPlate

	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, ConquestFrame, ConquestFrame.ConquestFrameHelpButton )
	else
		HelpPlate_Hide(true)
	end
end

local PVPHonorFrame_HelpPlate = {
	FramePos = { x = 0, y = 0 },
	FrameSize = { width = 343, height = 428 },
	[1] = { ButtonPos = { x = 312, y = -10 }, HighLightBox = { x = 2, y = -2, width = 336, height = 60 }, ToolTipDir = "DOWN", ToolTipText = PVPHONORFRAME_TUTORIAL_1 },
	[2] = { ButtonPos = { x = 312, y = -86 }, HighLightBox = { x = 250, y = -92, width = 84, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = PVPHONORFRAME_TUTORIAL_2 },
	[3] = { ButtonPos = { x = 312, y = -234 }, HighLightBox = { x = 250, y = -238, width = 84, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = PVPHONORFRAME_TUTORIAL_2 },
}

function PVPHonorFrame_ToggleTutorial( ... )
	local rewardFinalStepCurrency = C_CacheInstance:Get("ASMSG_PVP_DAILY_REWARDS", {})

	if rewardFinalStepCurrency and rewardFinalStepCurrency.battlegroundReward then
		PVPHonorFrame_HelpPlate[4] = { ButtonPos = { x = 312, y = -336 }, HighLightBox = { x = 2, y = -334, width = 336, height = 48 }, ToolTipDir = "RIGHT", ToolTipText = string.format(PVPHONORFRAME_TUTORIAL_3, rewardFinalStepCurrency.battlegroundReward) }
	end

	local helpPlate = PVPHonorFrame_HelpPlate

	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, PVPHonorFrame, PVPHonorFrame.PVPHonorFrameHelpButton )
	else
		HelpPlate_Hide(true)
	end
end

local RatedBattlegroundFrame_HelpPlate = {
	FramePos = { x = 0, y = 0 },
	FrameSize = { width = 343, height = 428 },
	[1] = { ButtonPos = { x = 312, y = 0 }, HighLightBox = { x = 6, y = -16, width = 330, height = 45 }, ToolTipDir = "RIGHT", ToolTipText = RATED_BATTLEGROUND_TUTORIAL_1 },
	[2] = { ButtonPos = { x = 312, y = -56 }, HighLightBox = { x = 6, y = -65, width = 330, height = 28 }, ToolTipDir = "RIGHT", ToolTipText = RATED_BATTLEGROUND_TUTORIAL_2 },
	[3] = { ButtonPos = { x = 312, y = -166 }, HighLightBox = { x = 6, y = -97, width = 330, height = 186 }, ToolTipDir = "RIGHT", ToolTipText = RATED_BATTLEGROUND_TUTORIAL_3 },
	[4] = { ButtonPos = { x = 312, y = -310 }, HighLightBox = { x = 6, y = -287, width = 330, height = 84 }, ToolTipDir = "RIGHT", ToolTipText = RATED_BATTLEGROUND_TUTORIAL_4 },
}

function RatedBattlegroundFrame_ToggleTutorial( self, ... )
	local helpPlate = RatedBattlegroundFrame_HelpPlate
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, RatedBattlegroundFrame, RatedBattlegroundFrame.MainHelpButton )
	else
		HelpPlate_Hide(true)
	end
end

BattlegroundInviteMixin = {}

function BattlegroundInviteMixin:OnLoad()
	self.factionIcons   = {
		[PLAYER_FACTION_GROUP.Horde]    = "right",
		[PLAYER_FACTION_GROUP.Alliance] = "left",
		[PLAYER_FACTION_GROUP.Renegade] = "Renegade",
	}

	local function UpdateFactionArt()
		local unitFactionGroup 	= UnitFactionGroup("player") or "Alliance"

		if unitFactionGroup == "Neutral" then
			return
		end

		self.PopupFrame.Body:SetAtlas("TalkingHeads-"..unitFactionGroup.."-TextBackground")
		self.PopupFrame.Header:SetAtlas("BattlegroundInvite-Background-Top-"..unitFactionGroup)
		self.PopupFrame.Bottom:SetAtlas("BattlegroundInvite-Background-Bottom-"..unitFactionGroup)
	end

	C_FactionManager:RegisterFactionOverrideCallback(UpdateFactionArt, true)

	self.PopupFrame.Body:SetSubTexCoord(1, 0, 0, 1)

	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
end

function BattlegroundInviteMixin:OnShow()
	self:Init()

	if not self.inviteState then
		self:Reset(true)
		return
	else
		self.PopupFrame.EnterButton:SetShown(self.inviteState == 1)
		self.PopupFrame.CancelButton:SetShown(self.inviteState == 1)
		self.PopupFrame.HideButton:SetShown(self.inviteState == 1)
		self.PopupFrame.ReadyButtonFrame:SetShown(self.inviteState == 2)

		local time = self.remainingTime - time()
		if time <= 10 then
			self.PopupFrame.Timer:SetTextColor(0.8, 0, 0)
		else
			self.PopupFrame.Timer:SetTextColor(0, 0, 0)
		end

		self.PopupFrame.Timer:SetText(SecondsToClock(time))
	end

	PlaySound("PVPTHROUGHQUEUE")
end

function BattlegroundInviteMixin:OnHide()
	self.readyPlayers = 0
end

function BattlegroundInviteMixin:OnEvent( event, ... )
	if event == "VARIABLES_LOADED" then
		self:Init()

		if self.inviteID and self.remainingTime > time() then
			if self.inviteState == 1 then
				self:ShowInviteFrame()
			else
				BattlegroundInviteQueueButton:ShowFrame()
			end
		else
			self:Reset(true)
		end
	elseif event == "PLAYER_ENTERING_BATTLEGROUND" then
		self:Reset(true)
	end
end

function BattlegroundInviteMixin:OnUpdate( elapsed )
	self.elapsedReady = self.elapsedReady + elapsed
	self.elapsedTimer = self.elapsedTimer + elapsed
	self.elapsedHorn  = self.elapsedHorn  + elapsed

	if self.elapsedTimer >= 1 and (self.remainingTime and self.remainingTime > 0) then
		local time = self.remainingTime - time()

		if time >= 0 then
			if time == 10 then
				PlaySound("PVPTHROUGHQUEUE")
			else
				if self.elapsedHorn >= 20 then
					PlaySound("PVPTHROUGHQUEUE")
					self.elapsedHorn = 0
				end
			end

			if time <= 10 then
				self.PopupFrame.Timer.timetAnimation:Play()
				self.PopupFrame.Timer:SetTextColor(0.8, 0, 0)
			end

			self.PopupFrame.Timer:SetText(SecondsToClock(time))
		else
			self.PopupFrame.Timer:SetText(RBG_READY_CHECK_ENDTIME)
			self:HideInviteFrame()
		end

		self.elapsedTimer = 0
	end

	if self.elapsedReady >= 0.0800 then
		if self.readyPlayers < self.readyCount then
			if self.PopupFrame:IsVisible() and self.PopupFrame.ReadyButtonFrame:IsVisible() then
				self.readyPlayers = self.readyPlayers + 1
				self.readyButtons[self.readyPlayers].Icon.activeButton:Play()
			end
		end

		self.elapsedReady = 0
	end

	if self.inviteState == 1 then
		if UnitAffectingCombat("player") then
			self.PopupFrame.EnterButton:Disable()
		else
			self.PopupFrame.EnterButton:Enable()
		end
	end
end

function BattlegroundInviteMixin:Init()
	local data 			= C_CacheInstance:Get("ASMSG_SEND_BG_INVITE", {})
	local readyCount 	= C_CacheInstance:Get("ASMSG_SEND_BG_INVITE_STATUS", 0)

	self.readyButtons 	= self.readyButtons or {}
	self.readyPlayers 	= 0
	self.inviteID 		= data.inviteID
	self.inviteState 	= data.inviteState
	self.remainingTime 	= data.remainingTime
	self.readyCount 	= readyCount

	self.elapsedReady 	= 0
	self.elapsedTimer 	= 1
	self.elapsedHorn 	= 0

	local function updateFunc( _, elapsed )
		self:OnUpdate(elapsed)
	end

	self.UpdateFrame = self.UpdateFrame or CreateFrame("Frame")
	self.UpdateFrame:SetScript("OnUpdate", updateFunc)

	self:ResetReadyButtons()
end

function BattlegroundInviteMixin:Reset( forceHide )
	self.showUI:Stop()
	self.hideUI:Stop()
	self.fastHideUI:Stop()

	C_CacheInstance:Set("ASMSG_SEND_BG_INVITE", {})
	C_CacheInstance:Set("ASMSG_SEND_BG_INVITE_STATUS", 0)

	self:Init()

	if forceHide then
		self:Hide()
		BattlegroundInviteQueueButton:Hide()
	end

	self.UpdateFrame:SetScript("OnUpdate", nil)
end

function BattlegroundInviteMixin:ResetReadyButtons()
	local factionID = C_Unit:GetFactionID("player")

	for i = 1, 20 do
		local button = self.readyButtons[i]

		if not button then
			button = CreateFrame("BUTTON", nil, self.PopupFrame.ReadyButtonFrame, "BattlegroundInviteReadyButtonTemplate")

			if i == 1 then
				button:SetPoint("LEFT", 0, 0)
			else
				button:SetPoint("LEFT", self.readyButtons[i - 1], "RIGHT", 0, 0)
			end
		end

		button:SetAlpha(0.5)
		button.Icon:SetAtlas("objectivewidget-icon-"..self.factionIcons[factionID])
		button.IconHit:SetAtlas("objectivewidget-icon-"..self.factionIcons[factionID])

		self.readyButtons[i] = button
	end
end

function BattlegroundInviteMixin:Accept()
	local data = C_CacheInstance:Get("ASMSG_SEND_BG_INVITE")

	if not data then
		self:Hide()
		BattlegroundInviteQueueButton:Hide()
		return
	end

	self.PopupFrame.EnterButton:Disable()

	data.inviteState = 2
	self.inviteState = data.inviteState

	BattlegroundInviteQueueButton:ShowFrame()
	self:HideInviteFrame()

	SendServerMessage("ACMSG_BG_ACCEPT_INVITE", self.inviteID)
end

function BattlegroundInviteMixin:Abandon()
	SendServerMessage("ACMSG_BG_DECLINE_INVITE", self.inviteID)

	self:HideInviteFrame(true)
end

function BattlegroundInviteMixin:AbandonInvite()
	self.PopupFrame.Timer:SetText(RBG_READY_CHECK_ABADDON)

	self:Reset()
	self:HideInviteFrame(true)

	BattlegroundInviteQueueButton:HideFrame()
end

function BattlegroundInviteMixin:AcceptInvite()
	self.PopupFrame.Timer:SetText(RBG_READY_CHECK_ACCEPT)
	self.PopupFrame.Timer:SetTextColor(0.38, 0.65, 0.11)

	self:Reset()
	self:HideInviteFrame()

	BattlegroundInviteQueueButton:HideFrame()
end

function BattlegroundInviteMixin:ShowInviteFrame()
	if self.showUI:IsPlaying() then
		return
	end

	if self.hideUI:IsPlaying() or self.fastHideUI:IsPlaying() then
		self.hideUI:Stop()
		self.fastHideUI:Stop()
	end

	if not self:IsShown() then
		self:Show()
	end

	self.showUI:Play()
end

function BattlegroundInviteMixin:HideInviteFrame( isFastHide )
	if self.hideUI:IsPlaying() or self.fastHideUI:IsPlaying() then
		return
	end

	if self.showUI:IsPlaying() then
		self.showUI:Stop()
	end

	if not self:IsShown() then
		self:Reset(true)
		return
	end

	if isFastHide then
		self.fastHideUI:Play()
	else
		self.hideUI:Play()
	end
end

BattlegroundInviteQueueMixin = {}

function BattlegroundInviteQueueMixin:OnLoad()
	local function UpdateFactionArt()
		local unitFaction = UnitFactionGroup("player")

		if unitFaction == "Neutral" then
			return
		end

		self.normalTexture:SetAtlas("BattlegroundInvite-Queue-Button-Normal-"..unitFaction, true)
		self.highlightTexture:SetAtlas("BattlegroundInvite-Queue-Button-Highlight-"..unitFaction, true)
		self.Glow:SetAtlas("BattlegroundInvite-Queue-Button-Glow-"..unitFaction, true)

		self.Shadow:SetAtlas("BattlegroundInvite-Queue-Button-Shadow", true)

		local atlasInfo = C_Texture.GetAtlasInfo("BattlegroundInvite-Queue-Button-Normal-"..unitFaction)
		self:SetSize(atlasInfo.width, atlasInfo.height)
	end

	C_FactionManager:RegisterFactionOverrideCallback(UpdateFactionArt, true)
end

function BattlegroundInviteQueueMixin:OnClick()
	BattlegroundInviteFrame:ShowInviteFrame()
	self:HideFrame()
end

function BattlegroundInviteQueueMixin:ShowFrame()
	if self.pulse:IsPlaying() then
		self.pulse:Stop()
	end

	if self.hideUI:IsPlaying() then
		self.hideUI:Stop()
	end

	self:Show()
	self.animGroup_ShowUI = self:CreateAnimationGroup()

	self.animGroup_ShowUI.translate1 = self.animGroup_ShowUI:CreateAnimation("Translation")
	self.animGroup_ShowUI.translate1:SetSmoothing("IN")
	self.animGroup_ShowUI.translate1:SetOffset(0, -350)
	self.animGroup_ShowUI.translate1:SetDuration(0)
	self.animGroup_ShowUI.translate1:SetOrder(1)

	self.animGroup_ShowUI.translate2 = self.animGroup_ShowUI:CreateAnimation("Translation")
	self.animGroup_ShowUI.translate2:SetSmoothing("IN")
	self.animGroup_ShowUI.translate2:SetOffset(0, 350)
	self.animGroup_ShowUI.translate2:SetDuration(0.3)
	self.animGroup_ShowUI.translate2:SetStartDelay(0.300)
	self.animGroup_ShowUI.translate2:SetOrder(2)

	self.animGroup_ShowUI.scale1 = self.animGroup_ShowUI:CreateAnimation("Scale")
	self.animGroup_ShowUI.scale1:SetScale(2, 2)
	self.animGroup_ShowUI.scale1:SetOrder(1)
	self.animGroup_ShowUI.scale1:SetDuration(0)

	self.animGroup_ShowUI.scale2 = self.animGroup_ShowUI:CreateAnimation("Scale")
	self.animGroup_ShowUI.scale2:SetScale(0.50, 0.50)
	self.animGroup_ShowUI.scale2:SetOrder(2)
	self.animGroup_ShowUI.scale2:SetDuration(1)
	self.animGroup_ShowUI.scale2:SetSmoothing("OUT")

	self.animGroup_ShowUI.alpha1 = self.animGroup_ShowUI:CreateAnimation("Alpha")
	self.animGroup_ShowUI.alpha1:SetChange(-1)
	self.animGroup_ShowUI.alpha1:SetOrder(1)
	self.animGroup_ShowUI.alpha1:SetDuration(0)

	self.animGroup_ShowUI.alpha1 = self.animGroup_ShowUI:CreateAnimation("Alpha")
	self.animGroup_ShowUI.alpha1:SetChange(1)
	self.animGroup_ShowUI.alpha1:SetOrder(2)
	self.animGroup_ShowUI.alpha1:SetDuration(0.3)

	self.animGroup_ShowUI:Play()
end

function BattlegroundInviteQueueMixin:HideFrame()
	if self.pulse:IsPlaying() then
		self.pulse:Stop()
	end

	if self.hideUI:IsPlaying() then
		self.hideUI:Stop()
	end

	if not self.hideUI:IsPlaying() then
		self.hideUI:Play()
	end
end

function BattlegroundInviteQueueMixin:GlowBlink()
	self.Glow:Show()
	self.Glow.blink:Play()
end

function BattlegroundInviteQueueMixin:OnUpdate( elapsed )
	local frame = BattlegroundInviteFrame

	if self:IsMouseOver() then
		if not frame:IsShown() then
			if not frame.hideUI:IsPlaying() and not frame.showUI:IsPlaying() then
				frame:ShowInviteFrame()
			end
		end
	else
		if frame:IsShown() then
			if not frame.hideUI:IsPlaying() and not frame.showUI:IsPlaying() then
				frame:HideInviteFrame(true)
			end
		end
	end

	if frame.remainingTime then
		local remainingTime = frame.remainingTime - time()

		if remainingTime <= 5 then
			if not self.pulse:IsPlaying() then
				self.pulse:Play()
			end
		end
	end
end

function BattlegroundInviteQueueMixin:OnEnter()
	if not self.Shadow:IsShown() then
		self.Shadow:Show()
	end
end

function BattlegroundInviteQueueMixin:OnLeave()
	self.Shadow:Hide()
end

local checkedStatus
function ArenaPlayerReadyStatusButton_OnClick( self, ... )
	if not self.Selection.AnimOut:IsPlaying() and not self.AnimIn:IsPlaying() and not self.AnimOut:IsPlaying() then
		self.Selection.AnimOut:Stop()
		self.Selection.AnimIn:Stop()
		self.Selection:SetVertexColor(0, 1, 0)

		if self:GetChecked() then
			self.Selection:Show()
			self.Selection.AnimIn:Play()

			self.HighlightTexture:Hide()
		else
			self.Selection:Show()
			self.Selection:SetVertexColor(1, 0, 0)
			self.Selection.AnimOut:Play()
			self.Selection:SetAlpha(0.2)

			self.HighlightTexture:Show()
		end

		checkedStatus = self:GetChecked()

		C_CacheInstance:Set("ArenaPlayerReadyStatusButtonState", {value = checkedStatus == 1})
		SendServerMessage("ACMSG_ARENA_READY_STATUS", checkedStatus and 1 or 0)

		ArenaPlayerReadyStatusButton_UpdateText(true)
	end
	self:SetChecked(checkedStatus)
end

local oldState
function ArenaPlayerReadyStatusButton_UpdateText( forceUpdate )
	local button = ArenaPlayerReadyStatusButton
	local state = C_CacheInstance:Get("ArenaPlayerReadyStatusButtonState")

	if state then
		local needAnimationText = oldState ~= state.value

		if needAnimationText and not forceUpdate then
			button.ReadyText.AnimSwap:Play()
			button.ReadyTextDescription.AnimSwap:Play()
		end

		button:SetChecked(state.value)

		if not forceUpdate then
			if button:GetChecked() then
				button.Selection:Show()
				button.Selection:SetAlpha(0.2)
			else
				button.Selection:Hide()
			end
		end

		if state.value == true then
			local data = C_CacheInstance:Get("ASMSG_ARENA_READY_STATUS")

			if data and data.bracket and data.readyCount then
				button.ReadyText:SetFormattedText("%d / %d", data.readyCount, data.bracket)
				button.ReadyTextDescription:SetText(READY_ARENA_WAIT_PLAYER_LABEL)
			end
		else
			button.ReadyText:SetText(READY_LABEL)
			button.ReadyTextDescription:SetText(READY_ARENA_DESCRIPTION_LABEL)
		end
	end
end

function ArenaPlayerReadyStatusButton_OnEnter( self, ... )
	if self.Selection.AnimOut:IsPlaying() or self.AnimIn:IsPlaying() or self.AnimOut:IsPlaying() then
		return
	end

	if not self:GetChecked() then
		self.HighlightTexture:Show()
	else
		self.Selection:SetAlpha(0.3)
	end
end

function ArenaPlayerReadyStatusButton_OnLeave( self, ... )
	self.HighlightTexture:Hide()
	self.Selection:SetAlpha(0.2)
end

function ArenaPlayerReadyStatusButtonToggle( times, timerType )
	if ArenaPlayerReadyStatusButton and TimerTrackerTimer1 then
		local hidingTime = timerType == "2" and 15 or 12;

		if times > hidingTime and not ArenaPlayerReadyStatusButton:IsShown() then
			ArenaPlayerReadyStatusButton:Show()
			ArenaPlayerReadyStatusButton.AnimIn:Play()
		elseif times < hidingTime and ArenaPlayerReadyStatusButton:IsShown() then
			ArenaPlayerReadyStatusButton.AnimOut:Play()
		end
		ArenaPlayerReadyStatusButton:ClearAllPoints()
		ArenaPlayerReadyStatusButton:SetPoint("TOP", TimerTrackerTimer1, "BOTTOM", 1, 4)
	end
end

function ArenaPlayerReadyStatusButton_OnEvent( self, event, ... )
	local _, instanceTyp = IsInInstance()
	if instanceTyp == "none" then
		self:Hide()
		C_CacheInstance:Set("ArenaPlayerReadyStatusButtonState", {value = false})
	end
end

function ArenaPlayerReadyStatusButton_OnHide( self, ... )
	self.Selection:Hide()
	self.ReadyText:SetText("0 / 0")
end

local function PVPQueueFrameCapTopFrameStatusBar_SetDesaturated( self, toggle )
	local textColor = toggle and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR

	self.Label:SetTextColor(textColor.r, textColor.g, textColor.b)
	self.SubLayer.barText:SetTextColor(textColor.r, textColor.g, textColor.b)

	-- self.Spark:SetDesaturated(toggle)
	-- self.Left:SetDesaturated(toggle)
	-- self.Right:SetDesaturated(toggle)
	-- self.Middle:SetDesaturated(toggle)
	-- self.BarTexture:SetDesaturated(toggle)
end

local function PVPQueueFrameCapTopFrameStatusBar_SetStatusBarValue( self, value, categoryID )
	if not value then
		return
	end

	local _, max = self:GetMinMaxValues()

	self.Spark:SetShown(value > 0 and value < max)

	if not self:GetParent().LockOverlay.DisableFrame:IsShown() then
		self:GetParent().LockOverlay:SetShown(value >= max)
		self:GetParent().LockOverlay.CompleteFrame:SetShown(value >= max)
	end

	if value >= max then
		self.BarTexture:SetVertexColor(0, 0.8, 0)
	else
		if categoryID == 2 then
			if ConquestFrame.selectedButton == ConquestFrame.BottomInset.SoloArenaContainer.ArenaSolo then
				self.BarTexture:SetVertexColor(1, 0.7, 1)
				self:GetParent().Background:SetGradientAlpha("VERTICAL", 0.91, 0.51, 0.06, 0.5, 0, 0, 0, 0.1)
			else
				self.BarTexture:SetVertexColor(1, 1, 1)
				self:GetParent().Background:SetGradientAlpha("VERTICAL", 0.84, 0.65, 0.04, 0.5, 0, 0, 0, 0.1)
			end
		else
			self.BarTexture:SetVertexColor(0.67, 1, 0)
			self:GetParent().Background:SetGradientAlpha("VERTICAL", 0.6, 0.69, 0, 0.5, 0, 0, 0, 0.1)
		end
	end

	self.SubLayer.barText:SetFormattedText("%d / %d", value, max)

	self:SetValue(value)
end

function PVPQueueFrameCapTopFrameStatusBar_OnLoad( self, ... )
	self.SetBarValue = PVPQueueFrameCapTopFrameStatusBar_SetStatusBarValue
	self.SetDesaturated = PVPQueueFrameCapTopFrameStatusBar_SetDesaturated
	self.UpdateTooltip = PVPQueueFrameCapTopFrameStatusBar_UpdateTooltip

	self.Right:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)

	self.Spark:SetAtlas("honorsystem-bar-spark")

	self.Spark:ClearAllPoints()
	self.Spark:SetPoint("CENTER", self.BarTexture, "RIGHT", 0, 1)
end

function PVPQueueFrameCapTopFrameStatusBar_OnShow( self, ... )
	-- body
end

function PVPFrame_StepButtonAndCapBarEnable()
	if PVPQueueFrame.CapTopFrame.LockOverlay:IsShown() or PVPQueueFrame.StepBottomFrame.LockOverlay:IsShown() then
		PVPQueueFrame.CapTopFrame.LockOverlay:SetState("hide")
		PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("hide")
	end
end

function PVPFrame_StepButtonAndCapBarDisable()
	if not PVPQueueFrame.CapTopFrame.LockOverlay:IsShown() then
		PVPQueueFrame.CapTopFrame.LockOverlay:SetState("disable")
	end

	if not PVPQueueFrame.StepBottomFrame.LockOverlay:IsShown() then
		PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("disable")
	end
end

function PVPFrameStepButton_SetDesaturatedAll( toggle )
	for _, button in pairs(PVPQueueFrame.StepBottomFrame.StepButtons) do
		if toggle then
			if not button.IsDisable then
				button:SetState(nil)
			end
		else
			-- перевод в текущее состояние.
		end
	end
end

function PVPFrameLockOverlay_SetState( self, state )
	self:SetShown(state ~= "hide")

	self.CompleteFrame:SetShown(state == "complete")
	self.DisableFrame:SetShown(state == "disable")
end

function PVPFrameStepButton_SetState( self, state )
	local buttonID = self:GetID()
	local textColor = state and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR
	local textureColor

	if state == 1 then
		textureColor = "Red"
	elseif state == 2 then
		textureColor = "Green"
	end

	self.WinLabel:SetTextColor(textColor.r, textColor.g, textColor.b)

	if self.WinCount then
		self.WinCount:SetTextColor(textColor.r, textColor.g, textColor.b)
	else
		self.Amount:SetTextColor(textColor.r, textColor.g, textColor.b)
	end

	if self.Arrow then
		self.Arrow:SetAtlas("PVPFrame_Breadcrumbs_Arrow_"..(textureColor or "Red"))
	end
	self.Background:SetAtlas("PVPFrame_Breadcrumbs_Background_"..(textureColor or "Red"))

	if self.Arrow then
		self.Arrow:SetDesaturated(not textureColor)
	else
		self.Icon:SetDesaturated(not textureColor)
	end

	self.Background:SetDesaturated(not textureColor)

	-- if buttonID == 5 then
	-- end

	self.IsDisable = not textureColor
end

function PVPFrameStepButtonTemplate_OnLoad( self, ... )
	local buttonID = self:GetID()

	self.SetState = PVPFrameStepButton_SetState

	if not self:GetParent().StepButtons then
		self:GetParent().StepButtons = {}
	end

	self:GetParent().StepButtons[buttonID] = self

	if buttonID ~= 5 then
		if buttonID == 1 then
			self.WinLabel:ClearAllPoints()
			self.WinLabel:SetPoint("CENTER", 0, 7)
		end

		self.WinCount:SetText(buttonID)
	end

	-- self:SetState(1)
end

function PVPFrameStepButton_UpdateState( categoryID )
	local overlimitStats = C_CacheInstance:Get("ASMSG_PVP_DAILY_STATS", {})
	local arenaGames = ((ConquestFrame.selectedButton == ConquestFrame.BottomInset.SoloArenaContainer.ArenaSolo and overlimitStats.arenaGamesSolo) or (ConquestFrame.selectedButton == ConquestFrame.BottomInset.ArenaContainer.Arena1v1 and overlimitStats.arenaGames1v1) or overlimitStats.arenaGames) or 0
	local battlegroundGames = overlimitStats.battlegroundGames or 0

	if categoryID == 2 then
		for i = 1, 5 do
			local button = PVPQueueFrame.StepBottomFrame.StepButtons[i]

			if button then
				if arenaGames == 0 and i == 1 then
					button:SetState(1)
				elseif (arenaGames + 1) == i then
					button:SetState(1)
				elseif arenaGames >= i then
					button:SetState(2)
				elseif arenaGames < i then
					button:SetState(nil)
				end
			end
		end

		if arenaGames >= 5 then
			PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("complete")
		else
			if ConquestFrame.state and ConquestFrame.state == 2 then
				PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("disable")
			else
				PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("hide")
			end

		end
	elseif categoryID == 3 then
		for i = 1, 3 do
			local button = PVPQueueFrame.StepBottomFrame.StepButtons[i == 3 and 5 or i]

			if button then
				if battlegroundGames == 0 and i == 1 then
					button:SetState(1)
				elseif (battlegroundGames + 1) == i then
					button:SetState(1)
				elseif battlegroundGames >= i then
					button:SetState(2)
				elseif battlegroundGames < i then
					button:SetState(nil)
				end
			end
		end

		if battlegroundGames >= 3 then
			PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("complete")
		else
			PVPQueueFrame.StepBottomFrame.LockOverlay:SetState("hide")
		end
	end
end

function PVPQueueFrameCapTopFrameStatusBar_UpdateValue( categoryID )
	local pvpCapRewardCurrency = C_CacheInstance:Get("ASMSG_PVP_WEEKLY_LIMIT", {})

	if categoryID == 2 then
		if ConquestFrame.selectedButton == ConquestFrame.BottomInset.SoloArenaContainer.ArenaSolo then
			PVPQueueFrame.CapTopFrame.StatusBar:SetMinMaxValues(0, pvpCapRewardCurrency.maxArenaSolo or 100, categoryID)
			PVPQueueFrame.CapTopFrame.StatusBar:SetBarValue(pvpCapRewardCurrency.currentArenaSolo or 0, categoryID)
		else
			PVPQueueFrame.CapTopFrame.StatusBar:SetMinMaxValues(0, pvpCapRewardCurrency.maxArena or 100, categoryID)
			PVPQueueFrame.CapTopFrame.StatusBar:SetBarValue(pvpCapRewardCurrency.currentArena or 0, categoryID)
		end
	elseif categoryID == 3 then
		PVPQueueFrame.CapTopFrame.StatusBar:SetMinMaxValues(0, pvpCapRewardCurrency.maxHonor or 100, categoryID)
		PVPQueueFrame.CapTopFrame.StatusBar:SetBarValue(pvpCapRewardCurrency.currentHonor or 0, categoryID)
	end
end

function PVPFrameStepButton_UpdateReward( categoryID )
	local rewardFinalStepCurrency = C_CacheInstance:Get("ASMSG_PVP_DAILY_REWARDS", {})

	if categoryID == 2 then
		if ConquestFrame.selectedButton == ConquestFrame.BottomInset.SoloArenaContainer.ArenaSolo then
			PVPQueueFrame.StepBottomFrame.StepEnd.Amount:SetText(rewardFinalStepCurrency.arenaRewardSolo or 0)
		elseif ConquestFrame.selectedButton == ConquestFrame.BottomInset.ArenaContainer.Arena1v1 then
			PVPQueueFrame.StepBottomFrame.StepEnd.Amount:SetText(rewardFinalStepCurrency.arenaReward1v1 or 0)
		else
			PVPQueueFrame.StepBottomFrame.StepEnd.Amount:SetText(rewardFinalStepCurrency.arenaReward2v2 or 0)
		end
	elseif categoryID == 3 then
		PVPQueueFrame.StepBottomFrame.StepEnd.Amount:SetText(rewardFinalStepCurrency.battlegroundReward or 0)
	end
end

ASMSG_PVP_REWARDS_ARENA_2V2 	= 1
ASMSG_PVP_REWARDS_ARENA_3V3 	= 2
ASMSG_PVP_REWARDS_ARENA_SOLO 	= 3
ASMSG_PVP_REWARDS_BG 			= 4
ASMSG_PVP_REWARDS_BF 			= 5
ASMSG_PVP_REWARDS_ARENA_1V1 	= 6

function PVPQueueFrame_UpdateReward( categoryID )
	local pvpRewards = C_CacheInstance:Get("ASMSG_PVP_REWARDS", {})
	local factionID = C_Unit:GetFactionID("player")
	local xOffset

	if categoryID == 2 then
		local rateArenaRewards = ConquestFrame.selectedButton == ConquestFrame.BottomInset.ArenaContainer.Arena1v1 and pvpRewards[ASMSG_PVP_REWARDS_ARENA_1V1] or pvpRewards[ASMSG_PVP_REWARDS_ARENA_2V2]
		ConquestFrame.BottomInset.ArenaContainer.Header.RewardFrame.CurrencyReward:SetShown(rateArenaRewards and rateArenaRewards.currency > 0)
		ConquestFrame.BottomInset.ArenaContainer.Header.RewardFrame.LootReward:SetShown(rateArenaRewards and rateArenaRewards.loot == 1)

		xOffset = (rateArenaRewards and rateArenaRewards.loot == 1 and rateArenaRewards.currency > 0) and -98 or -22
		ConquestFrame.BottomInset.ArenaContainer.Header.RewardFrame.LootReward:SetPoint("TOPRIGHT", xOffset, -2)

		local soloArenaRewards = pvpRewards[ASMSG_PVP_REWARDS_ARENA_SOLO]
		ConquestFrame.BottomInset.SoloArenaContainer.Header.RewardFrame.CurrencyReward:SetShown(soloArenaRewards and soloArenaRewards.currency > 0)
		ConquestFrame.BottomInset.SoloArenaContainer.Header.RewardFrame.LootReward:SetShown(soloArenaRewards and soloArenaRewards.loot == 1)

		xOffset = (soloArenaRewards and soloArenaRewards.loot == 1 and soloArenaRewards.currency > 0) and -98 or -22
		ConquestFrame.BottomInset.SoloArenaContainer.Header.RewardFrame.LootReward:SetPoint("TOPRIGHT", xOffset, -2)

		ConquestFrame.BottomInset.ArenaContainer.Header.RewardFrame.CurrencyReward.Count:SetText(rateArenaRewards and rateArenaRewards.currency)
		ConquestFrame.BottomInset.SoloArenaContainer.Header.RewardFrame.CurrencyReward.Count:SetText(soloArenaRewards and soloArenaRewards.currency)

		ConquestFrame.BottomInset.ArenaContainer.Header.RewardFrame.CurrencyReward.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID])
		ConquestFrame.BottomInset.SoloArenaContainer.Header.RewardFrame.CurrencyReward.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID])
	elseif categoryID == 3 then
		local bgRewards = pvpRewards[ASMSG_PVP_REWARDS_BG]
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header.RewardFrame.CurrencyReward:SetShown(bgRewards and bgRewards.currency > 0)
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header.RewardFrame.LootReward:SetShown(bgRewards and bgRewards.loot == 1)

		xOffset = (bgRewards and bgRewards.loot == 1 and bgRewards.currency > 0) and -98 or -22
		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header.RewardFrame.LootReward:SetPoint("TOPRIGHT", xOffset, -2)

		local bfRewards = pvpRewards[ASMSG_PVP_REWARDS_BF]
		PVPHonorFrame.BottomInset.WorldPVPContainer.Header.RewardFrame.CurrencyReward:SetShown(bfRewards and bfRewards.currency > 0)
		PVPHonorFrame.BottomInset.WorldPVPContainer.Header.RewardFrame.LootReward:SetShown(bfRewards and bfRewards.loot == 1)

		xOffset = (bfRewards and bfRewards.loot == 1 and bfRewards.currency > 0) and -98 or -22
		PVPHonorFrame.BottomInset.WorldPVPContainer.Header.RewardFrame.LootReward:SetPoint("TOPRIGHT", xOffset, -2)

		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header.RewardFrame.CurrencyReward.Count:SetText(bgRewards and bgRewards.currency)
		PVPHonorFrame.BottomInset.WorldPVPContainer.Header.RewardFrame.CurrencyReward.Count:SetText(bfRewards and bfRewards.currency)

		PVPHonorFrame.BottomInset.BonusBattlefieldContainer.Header.RewardFrame.CurrencyReward.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID])
		PVPHonorFrame.BottomInset.WorldPVPContainer.Header.RewardFrame.CurrencyReward.Icon:SetTexture("Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID])
	end
end

function ConquestFrameButton_OnShow( self, ... )
	local buttonID = self:GetID()
	local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})

	if buttonID ~= 3 then -- TEMP
		self.Wins:SetText(pvpStats[buttonID] and pvpStats[buttonID].seasonWins or 0)
		self.BestRating:SetText(pvpStats[buttonID] and pvpStats[buttonID].seasonGames - pvpStats[buttonID].seasonWins or 0)
		self.CurrentRating:SetText(pvpStats[buttonID] and pvpStats[buttonID].pvpRating or 0)
	end
end

local function CalculateArenaLimit( rating )
	return math.Round(math.max(261.0, 1511.26 / (1.0 + 1639.28 * math.exp(-0.00412 * rating)) * 0.76))
end

local function CalculateHonorLimit()
	local _, _, battlegroundRank = GetRatedBattlegroundRankInfo()
	return 1044 + (battlegroundRank * 300)
end

function PVPQueueFrameCapTopFrameLockOverlayCompleteFrame_OnEnter( self, ... )
	local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})
	local timeData = C_CacheInstance:Get("ASMSG_PVP_LIMITS_TIMERS", {})
	local arenaRating = math.max(pvpStats[1].pvpRating, pvpStats[2].pvpRating)
	local _, _, _, _, battlegroundRating = GetRatedBattlegroundRankInfo()

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if PVPQueueFrame.selectedCategory == 2 then
		GameTooltip:SetText(PVPFRAME_CONQUEST_CAPBAR_COMPLETEFRAME_TOOLTIP_HEAD)
		GameTooltip:AddLine(string.format(PVPFRAME_CONQUEST_CAPBAR_COMPLETEFRAME_TOOLTIP, CalculateArenaLimit(arenaRating)), 1, 1, 1, true)
	elseif PVPQueueFrame.selectedCategory == 3 then
		GameTooltip:SetText(PVPFRAME_HONOR_CAPBAR_COMPLETEFRAME_TOOLTIP_HEAD)
		GameTooltip:AddLine(string.format(PVPFRAME_HONOR_CAPBAR_COMPLETEFRAME_TOOLTIP, CalculateHonorLimit()), 1, 1, 1, true)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(string.format(PVPFRAME_CAPBAR_RESET_LABEL, GetRemainingTime(timeData.weeklySeconds and timeData.weeklySeconds - time() or 0)))
	GameTooltip:Show()
end

function PVPQueueFrameCapTopFrameStatusBar_OnEnter( self, ... )
	local _, maxValue = self:GetMinMaxValues()
	local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})
	local timeData = C_CacheInstance:Get("ASMSG_PVP_LIMITS_TIMERS", {})
	local limitData = C_CacheInstance:Get("ASMSG_PVP_WEEKLY_LIMIT", {})
	local arenaRating = 0

	if pvpStats[1] and pvpStats[2] then
		arenaRating = math.max(pvpStats[1].pvpRating, pvpStats[2].pvpRating)
	end

	if self:GetValue() ~= maxValue then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if PVPQueueFrame.selectedCategory == 2 then
			GameTooltip:SetText(PVPFRAME_CONQUEST_CAPBAR_TOOLTIP_HEAD)
			GameTooltip:AddLine(PVPFRAME_CONQUEST_CAPBAR_TOOLTIP, 1, 1, 1, true)
		elseif PVPQueueFrame.selectedCategory == 3 then
			GameTooltip:SetText(PVPFRAME_HONOR_CAPBAR_TOOLTIP_HEAD)
			GameTooltip:AddLine(PVPFRAME_HONOR_CAPBAR_TOOLTIP, 1, 1, 1, true)
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(string.format(PVPFRAME_CAPBAR_RESET_LABEL, GetRemainingTime(timeData.weeklySeconds and timeData.weeklySeconds - time() or 0)))
		GameTooltip:Show()
	end
end

function PVPQueueFrameCapTopFrameStatusBar_UpdateTooltip( self, ... )
	local timeData = C_CacheInstance:Get("ASMSG_PVP_LIMITS_TIMERS", {})

	if timeData.weeklySeconds then
		for i = 1, GameTooltip:NumLines() do
			local line = _G[GameTooltip:GetName().."TextLeft"..i]
			local lineText = line:GetText()

			if lineText and string.find(lineText, PVPFRAME_CAPBAR_RESET_LABEL_PATTERN) then
				line:SetFormattedText(PVPFRAME_CAPBAR_RESET_LABEL, GetRemainingTime(timeData.weeklySeconds and timeData.weeklySeconds - time() or 0))
			end
		end
	end
end

function PVPQueueFrameStepFrameStatusBar_UpdateTooltip( self, ... )
	local timeData = C_CacheInstance:Get("ASMSG_PVP_LIMITS_TIMERS", {})

	if timeData.dailySeconds then
		for i = 1, GameTooltip:NumLines() do
			local line = _G[GameTooltip:GetName().."TextLeft"..i]
			local lineText = line:GetText()

			if lineText and string.find(lineText, PVPFRAME_STEPFRAME_RESET_LABEL_PATTERN) then
				line:SetFormattedText(PVPFRAME_STEPFRAME_RESET_LABEL, GetRemainingTime(timeData.dailySeconds and timeData.dailySeconds - time() or 0))
			end
		end
	end
end

function PVPQueueFrameStepBottomFrameLockOverlay_OnEnter( self, ... )
	local timeData = C_CacheInstance:Get("ASMSG_PVP_LIMITS_TIMERS", {})

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(string.format(PVPFRAME_STEPFRAME_RESET_LABEL, GetRemainingTime(timeData.dailySeconds and timeData.dailySeconds - time() or 0)))
	GameTooltip:Show()
end

function EventHandler:ASMSG_CHARACTER_BG_STATS( msg )
	local splitData 	= C_Split( msg, "|" )
	local playerGUID 	= tonumber( table.remove( splitData, 1 ) )
	local bgID

	local buffer = {
		[playerGUID] = {}
	}

	for i = 1, #splitData do
		if splitData[i] then
			local bgStatData = C_Split( splitData[i], ":")
			for b = 1, #bgStatData do
				local statData = C_Split( bgStatData[b], "." )
				if statData[1] and not statData[2] then
					bgID 						= tonumber(statData[1])
					buffer[playerGUID][bgID] 	= {}
				else
					buffer[playerGUID][bgID][#buffer[playerGUID][bgID] + 1] = {tonumber(statData[1]), tonumber(statData[2])}
				end
			end
		end
	end

	C_CacheInstance:Set("ASMSG_CHARACTER_BG_STATS", buffer)
end

function EventHandler:ASMSG_UPDATE_BG_RANK( msg )
	local currentStRank, currentRank, currentRating, nextRank, nextRating, weekWins, weekGames, totalWins, totalGames = unpack( C_Split(msg, "|") )

	C_CacheInstance:Set("ASMSG_UPDATE_BG_RANK", {
		currentStRank 	= tonumber(currentStRank),
		currentRank 	= tonumber(currentRank),
		currentRating 	= tonumber(currentRating),
		nextRank 		= tonumber(nextRank),
		nextRating 		= tonumber(nextRating),
		weekWins 		= tonumber(weekWins),
		weekGames 		= tonumber(weekGames),
		totalWins 		= tonumber(totalWins),
		totalGames 		= tonumber(totalGames),
	})

	PlayerFrame_UpdatePvPStatus()
end

function EventHandler:ASMSG_CHARACTER_BG_INFO( msg )
	local currGUID, currRating, currRankID, weekWins, weekGames, totalWins, totalGames = unpack( C_Split(msg, "|") )

	local GUID = tonumber(currGUID)
	local data = C_CacheInstance:Get("ASMSG_CHARACTER_BG_INFO", {})

	data[GUID] = {
		currGUID 	= GUID,
		currRating 	= tonumber(currRating),
		currRankID 	= tonumber(currRankID),
		weekWins 	= tonumber(weekWins),
		weekGames 	= tonumber(weekGames),
		totalWins 	= tonumber(totalWins),
		totalGames 	= tonumber(totalGames),
		ttl 		= 300 + time()
	}

	C_CacheInstance:Set("ASMSG_CHARACTER_BG_INFO", data)

	TargetFrame_CheckFaction(TargetFrame)
	InspectRatedBattleGrounds_OnShow(InspectPVPFrame.Service)
end

function EventHandler:ASMSG_CHARACTER_RBG_STATS( msg )
	local GUID, currRating, weekWins, weekGames, totalWins, totalGames = unpack(C_Split( msg, "|"))

	C_CacheInstance:Set("ASMSG_CHARACTER_RBG_STATS", {
		GUID 		= tonumber(GUID),
		currRating 	= tonumber(currRating),
		weekWins 	= tonumber(weekWins),
		weekGames 	= tonumber(weekGames),
		totalWins 	= tonumber(totalWins),
		totalGames 	= tonumber(totalGames),
	})
end

function EventHandler:ASMSG_BG_EVENT_START_TIMER( msg )
	if msg then
		local splitData = C_Split(msg, ":")
		local times = ( tonumber( splitData[1] ) / 1000 )
		local timerType = tonumber( splitData[2] )

		if timerType == 0 then
			TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, times, 120)
		else
			StartTimer_StopAllTimers()
			TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, times, 60)
		end

		if not GetCVar("BattlegroundTimerType") then
			RegisterCVar("BattlegroundTimerType", timerType)
		end

		if not GetCVar("BattlegroundStartTimer") then
			RegisterCVar("BattlegroundStartTimer", time() + times)
			return
		end

		SetCVar("BattlegroundStartTimer", time() + times)
		SetCVar("BattlegroundTimerType", timerType)
	end
end

function EventHandler:ASMSG_CHARACTER_ARENA_INFO( msg )
	local teamData 	= C_Split(msg, "|")
	local GUID 		= table.remove(teamData, 1)
	local buffer 	= {
		[tonumber(GUID)] = {
			[1] = {},
			[2] = {},
			[3] = {}
		}
	}
	local slotID

	for i = 1, #teamData do
		if teamData[i] then
			local playerData = C_Split(teamData[i], "-")
			for b = 1, #playerData do
				if playerData[b] then
					local statData = C_Split(playerData[b], ":")

					if #statData == 5 then
						slotID = table.remove(statData, 1)
					end

					table.insert(buffer[tonumber(GUID)][tonumber(slotID) + 1], {
						name 		= statData[1],
						seasonGame 	= tonumber(statData[2]),
						seasonWin 	= tonumber(statData[3]),
						rating 		= tonumber(statData[4]),
					})
				end
			end
		end
	end

	C_CacheInstance:Set("ASMSG_CHARACTER_ARENA_INFO", buffer)
end

function EventHandler:ASMSG_ARENA_POINTS_PREDICT( msg )
	C_CacheInstance:Set("ASMSG_ARENA_POINTS_PREDICT", tonumber(msg))
end

function EventHandler:ASMSG_NEXT_ARENA_DISTRIBUTION_TIME( msg )
	local arenaDistributionTime = time() + tonumber(msg)
	C_CacheInstance:Set("ASMSG_NEXT_ARENA_DISTRIBUTION_TIME", arenaDistributionTime)
end

function EventHandler:ASMSG_ARENA_READY_STATUS( msg )
	local splitData = C_Split(msg, "|")

	if splitData and #splitData > 0 then
		C_CacheInstance:Set("ASMSG_ARENA_READY_STATUS", {
			bracket = tonumber(splitData[1]),
			readyCount = tonumber(splitData[2])
		})
	end

	ArenaPlayerReadyStatusButton_UpdateText(true)
end

function EventHandler:ASMSG_PVP_WEEKLY_LIMIT( msg )
	local splitData = C_Split(msg, ":")

	local currentArena 		= tonumber(splitData[1])
	local maxArena 			= tonumber(splitData[2])
	local currentHonor 		= tonumber(splitData[3])
	local maxHonor 			= tonumber(splitData[4])
	local currentArenaSolo 	= tonumber(splitData[5])
	local maxArenaSolo 		= tonumber(splitData[6])

	C_CacheInstance:Set("ASMSG_PVP_WEEKLY_LIMIT", {
		currentArena 		= currentArena,
		maxArena 			= maxArena,
		currentHonor 		= currentHonor,
		maxHonor 			= maxHonor,
		currentArenaSolo 	= currentArenaSolo,
		maxArenaSolo 		= maxArenaSolo
	})

	if PVPUIFrame:IsShown() and PVPUIFrame:IsVisible() then
		PVPQueueFrameCapTopFrameStatusBar_UpdateValue(PVPQueueFrame.selectedCategory or 3)
	end
end

function EventHandler:ASMSG_PVP_REWARDS( msg )
	local splitData = C_Split(msg, "|")
	local buffer = {}

	for _, value in pairs(splitData) do
		local data = C_Split(value, ":")

		table.insert(buffer, {
			currency 	= tonumber(data[1] or 0),
			loot 		= tonumber(data[2] or 0),
		})
	end

	C_CacheInstance:Set("ASMSG_PVP_REWARDS", buffer)

	PVPQueueFrame_UpdateReward(2)
	PVPQueueFrame_UpdateReward(3)
end

function EventHandler:ASMSG_PVP_STATS( msg )
	local splitData = C_Split(msg, "|")
	local pvpStats = C_CacheInstance:Get("ASMSG_PVP_STATS", {})

	for _, splittedMSG in pairs(splitData) do
		local splitData = C_Split(splittedMSG, ":")

		local pvpType = tonumber(splitData[1])
		local pvpRating = tonumber(splitData[2])
		local seasonGames = tonumber(splitData[3])
		local seasonWins = tonumber(splitData[4])
		local weekGames = tonumber(splitData[5])
		local weekWins = tonumber(splitData[6])
		local TodayGames = tonumber(splitData[7])
		local TodayWins = tonumber(splitData[8])

		pvpStats[pvpType] = {
			pvpType = pvpType,
			pvpRating = pvpRating,
			seasonGames = seasonGames,
			seasonWins = seasonWins,
			weekGames = weekGames,
			weekWins = weekWins,
			TodayGames = TodayGames,
			TodayWins = TodayWins
		}
	end
end

function EventHandler:ASMSG_PVP_DAILY_STATS( msg )
	local splitData = C_Split(msg, ":")

	local arenaGames 		= tonumber(splitData[1])
	local battlegroundGames = tonumber(splitData[2])
	local arenaGamesSolo 	= tonumber(splitData[3])
	local arenaGames1v1 	= tonumber(splitData[4])

	C_CacheInstance:Set("ASMSG_PVP_DAILY_STATS", {
		arenaGames 			= arenaGames,
		battlegroundGames 	= battlegroundGames,
		arenaGamesSolo 		= arenaGamesSolo,
		arenaGames1v1 		= arenaGames1v1,
	})
end

function EventHandler:ASMSG_PVP_DAILY_REWARDS( msg )
	local splitData = C_Split(msg, ":")

	local arenaReward2x2        = tonumber(splitData[1])
	local arenaReward1v1        = tonumber(splitData[2])
	local arenaRewardSolo       = tonumber(splitData[3])
	local battlegroundReward    = tonumber(splitData[4])

	C_CacheInstance:Set("ASMSG_PVP_DAILY_REWARDS", {
		arenaReward2v2 		= arenaReward2x2,
		arenaReward1v1 		= arenaReward1v1,
		arenaRewardSolo 	= arenaRewardSolo,
		battlegroundReward 	= battlegroundReward,
	})
end

function EventHandler:ASMSG_PVP_SEASON( msg )
	local splitData = C_Split(msg, ":")

	local currentSeason = tonumber(splitData[1])
	local seasonEnd = time() + tonumber(splitData[2])

	C_CacheInstance:Set("ASMSG_PVP_SEASON", {
		currentSeason = currentSeason,
		seasonEnd = seasonEnd
	})

	PVPFrame_SetupTitle()
end

function EventHandler:ASMSG_PVP_LIMITS_TIMERS( msg )
	local splitData = C_Split(msg, ":")

	local dailySeconds = time() + tonumber(splitData[1])
	local weeklySeconds = time() + tonumber(splitData[2])

	C_CacheInstance:Set("ASMSG_PVP_LIMITS_TIMERS", {
		dailySeconds = dailySeconds,
		weeklySeconds = weeklySeconds
	})
end

function EventHandler:ASMSG_SEND_BG_INVITE( msg )
	-- print("ASMSG_SEND_BG_INVITE", msg)
	BattlegroundInviteFrame:Reset(true)

	local splitData 	= C_Split(msg, ":")
	local inviteID 		= tonumber(splitData[1])
	local inviteState 	= 1
	local remainingTime = time() + tonumber(splitData[2])

	C_CacheInstance:Set("ASMSG_SEND_BG_INVITE", {
		inviteID 		= inviteID,
		inviteState 	= inviteState,
		remainingTime 	= remainingTime
	})

	BattlegroundInviteFrame.PopupFrame.EnterButton:Enable()
	BattlegroundInviteFrame:ShowInviteFrame()
end

function EventHandler:ASMSG_SEND_BG_INVITE_STATUS( msg )
	local playerIndex = tonumber(msg)
	C_CacheInstance:Set("ASMSG_SEND_BG_INVITE_STATUS", playerIndex)

	if BattlegroundInviteFrame.PopupFrame:IsVisible() and BattlegroundInviteFrame.PopupFrame.ReadyButtonFrame:IsVisible() then
		for i = 1, playerIndex do
			BattlegroundInviteFrame.readyButtons[i].Icon.activeButton:Play()
		end
	end

	BattlegroundInviteQueueButton:GlowBlink()
end

function EventHandler:ASMSG_SEND_BG_INVITE_ABADDON()
	-- print("ASMSG_SEND_BG_INVITE_ABADDON")
	C_CacheInstance:Set("ASMSG_SEND_BG_INVITE", nil)
	BattlegroundInviteFrame:AbandonInvite()
end

function EventHandler:ASMSG_SEND_BG_INVITE_ACCEPT()
	-- print("ASMSG_SEND_BG_INVITE_ACCEPT")
	BattlegroundInviteFrame:AcceptInvite()
end

function EventHandler:ASMSG_BATTLEGROUND_LOCKED( msg )
	local battlegroundLockIDs = C_Split(msg, ",")
	local battlegroundLockIDStorage = {}

	for index, battlegroundID in pairs(battlegroundLockIDs) do
		local name = GetBattlegroundInfoByID(battlegroundID)

		battlegroundLockIDStorage[index] = name
	end

	C_CacheInstance:Set("ASMSG_BATTLEGROUND_LOCKED", battlegroundLockIDStorage)
end