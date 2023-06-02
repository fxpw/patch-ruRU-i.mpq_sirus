local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetNumBattlefieldStats = GetNumBattlefieldStats
local GetBattlefieldStatData = GetBattlefieldStatData
local GetBattlefieldScore = GetBattlefieldScore
local SetBattlefieldScoreFaction = SetBattlefieldScoreFaction
local UnitGUID = UnitGUID

local tinsert, twipe = table.insert, table.wipe

BATTLEFIELD_SCORE_FACTION = Enum.CreateMirror({
	BOTH			= -1,
	HORDE			= 0,
	ALLIANCE		= 1,
})

local BATTLEFIELD_SCORE_INDEXES = {
	NAME			= 1,
	KILLING_BLOWS	= 2,
	HONORABLE_KILLS	= 3,
	DEATHS			= 4,
	HONOR_GAINED	= 5,
	FACTION			= 6,
	RANK			= 7,
	RACE_LOCALIZED	= 8,
	CLASS_LOCALIZED	= 9,
	CLASS_TOKEN		= 10,
	DAMAGE_DONE		= 11,
	HEALING_DONE	= 12,
	STAT_DATA		= 13,
}

local PRIVATE = {
	IN_BATTLEGROUND = false,
	IN_ARENA = false,

	FILTER_FACTION = BATTLEFIELD_SCORE_FACTION.BOTH,
	SCORE_DATA = {
		[BATTLEFIELD_SCORE_FACTION.BOTH] = {},
		[BATTLEFIELD_SCORE_FACTION.HORDE] = {},
		[BATTLEFIELD_SCORE_FACTION.ALLIANCE] = {},
	},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.eventHandler:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "UPDATE_BATTLEFIELD_SCORE" then
		PRIVATE.uptodate = nil
	elseif event == "PLAYER_ENTERING_WORLD" then
		local onBattleground = PRIVATE.IsPlayerOnBattleground()

		local inInstance, instanceType = IsInInstance()
		PRIVATE.IN_BATTLEGROUND = inInstance == 1 and instanceType == "pvp"
		PRIVATE.IN_ARENA_BATTLEFIELD = IsActiveBattlefieldArena()
		PRIVATE.uptodate = nil

		if onBattleground ~= PRIVATE.IsPlayerOnBattleground() then
			PRIVATE.FILTER_FACTION = BATTLEFIELD_SCORE_FACTION.BOTH
			SetBattlefieldScoreFaction(nil)
		end
	end
end)

PRIVATE.IsPlayerOnBattleground = function()
	return PRIVATE.IN_BATTLEGROUND and not PRIVATE.IN_ARENA
end

PRIVATE.UpdateScoreData = function()
	if PRIVATE.uptodate then
		return
	end

	twipe(PRIVATE.SCORE_DATA[BATTLEFIELD_SCORE_FACTION.BOTH])
	twipe(PRIVATE.SCORE_DATA[BATTLEFIELD_SCORE_FACTION.ALLIANCE])
	twipe(PRIVATE.SCORE_DATA[BATTLEFIELD_SCORE_FACTION.HORDE])

	local onBattleground = PRIVATE.IsPlayerOnBattleground()
	local factionID = C_FactionManager.GetFactionOverride()

	for scoreIndex = 1, GetNumBattlefieldScores() do
		local scoreData = {GetBattlefieldScore(scoreIndex)}

		if scoreData[BATTLEFIELD_SCORE_INDEXES.NAME] then
			if onBattleground then
				local statData = {}
				tinsert(scoreData, statData)

				for statIndex = 1, GetNumBattlefieldStats() do
					tinsert(statData, GetBattlefieldStatData(scoreIndex, statIndex))
				end

				if factionID then
					local guid = UnitGUID(scoreData[BATTLEFIELD_SCORE_INDEXES.NAME])
					if guid then
						scoreData[BATTLEFIELD_SCORE_INDEXES.FACTION] = factionID
					elseif factionID == PLAYER_FACTION_GROUP.Alliance then
						scoreData[BATTLEFIELD_SCORE_INDEXES.FACTION] = PLAYER_FACTION_GROUP.Horde
					else
						scoreData[BATTLEFIELD_SCORE_INDEXES.FACTION] = PLAYER_FACTION_GROUP.Alliance
					end
				end
			end

			tinsert(PRIVATE.SCORE_DATA[BATTLEFIELD_SCORE_FACTION.BOTH], scoreData)

			if scoreData[BATTLEFIELD_SCORE_INDEXES.FACTION] == PLAYER_FACTION_GROUP.Alliance then
				tinsert(PRIVATE.SCORE_DATA[BATTLEFIELD_SCORE_FACTION.ALLIANCE], scoreData)
			elseif scoreData[BATTLEFIELD_SCORE_INDEXES.FACTION] == PLAYER_FACTION_GROUP.Horde then
				tinsert(PRIVATE.SCORE_DATA[BATTLEFIELD_SCORE_FACTION.HORDE], scoreData)
			end
		end
	end

	PRIVATE.uptodate = true
end

PRIVATE.GetFactionScoreTable = function(filterFaction)
	PRIVATE.UpdateScoreData()
	return PRIVATE.SCORE_DATA[filterFaction or PRIVATE.FILTER_FACTION]
end

PRIVATE.GetNumBattlefieldScores = function(faction)
	if not PRIVATE.IsPlayerOnBattleground() then
		return GetNumBattlefieldScores()
	end

	return #PRIVATE.GetFactionScoreTable(faction)
end

PRIVATE.GetBattlefieldScore = function(scoreIndex, faction)
	if not PRIVATE.IsPlayerOnBattleground() then
		return GetBattlefieldScore(scoreIndex)
	end

	if type(scoreIndex) ~= "number" then
		error("Usage: GetBattlefieldScore(index)", 3)
	end

	local scoreData = PRIVATE.GetFactionScoreTable(faction)

	if scoreData[scoreIndex] then
		return unpack(scoreData[scoreIndex])
	end

	return nil, 0, 0, 0, 0, 0, 0, nil, nil, nil, 0, 0, {}
end

PRIVATE.GetBattlefieldStatData = function(scoreIndex, statIndex, faction)
	if not PRIVATE.IsPlayerOnBattleground() then
		return GetBattlefieldStatData(scoreIndex, statIndex)
	end

	if type(scoreIndex) ~= "number" or type(statIndex) ~= "number" then
		error("Usage: GetBattlefieldStatData(playerIndex, statIndex)", 3)
	end

	local scoreData = PRIVATE.GetFactionScoreTable(faction)
	local columnData

	if scoreData[scoreIndex] then
		local statData = scoreData[scoreIndex][BATTLEFIELD_SCORE_INDEXES.STAT_DATA]
		columnData = statData and statData[statIndex]
	end

	return columnData or 0
end

C_BattlefieldScore = {}

function C_BattlefieldScore.GetEntryByName(name, faction)
	if type(name) ~= "string" then
		error("Usage: C_BattlefieldScore.GetEntryByName(name[, faction])", 2)
	elseif faction and (type(faction) ~= "number" or not BATTLEFIELD_SCORE_FACTION[faction]) then
		error("Usage: C_BattlefieldScore.GetEntryByName(name[, faction])", 2)
	end

	for scoreIndex, scoreEntry in ipairs(PRIVATE.GetFactionScoreTable(faction or BATTLEFIELD_SCORE_FACTION.BOTH)) do
		if scoreEntry[BATTLEFIELD_SCORE_INDEXES.NAME] == name then
			return scoreIndex, unpack(scoreEntry)
		end
	end
end

function C_BattlefieldScore.GetNumBattlefieldScores(faction)
	if faction and (type(faction) ~= "number" or not BATTLEFIELD_SCORE_FACTION[faction]) then
		error("Usage: C_BattlefieldScore.GetEntryByName(name[, faction])", 2)
	end

	return PRIVATE.GetNumBattlefieldScores(faction or BATTLEFIELD_SCORE_FACTION.BOTH)
end

function C_BattlefieldScore.GetBattlefieldScore(scoreIndex, faction)
	if faction and (type(faction) ~= "number" or not BATTLEFIELD_SCORE_FACTION[faction]) then
		error("Usage: C_BattlefieldScore.GetEntryByName(name[, faction])", 2)
	end

	return PRIVATE.GetBattlefieldScore(scoreIndex, faction or BATTLEFIELD_SCORE_FACTION.BOTH)
end

function C_BattlefieldScore.GetBattlefieldStatData(scoreIndex, statIndex, faction)
	if faction and (type(faction) ~= "number" or not BATTLEFIELD_SCORE_FACTION[faction]) then
		error("Usage: C_BattlefieldScore.GetEntryByName(name[, faction])", 2)
	end

	return PRIVATE.GetBattlefieldStatData(scoreIndex, statIndex, faction or BATTLEFIELD_SCORE_FACTION.BOTH)
end

_G.SetBattlefieldScoreFaction = function(factionMode)
	if not PRIVATE.IsPlayerOnBattleground() then
		SetBattlefieldScoreFaction(factionMode)
	end

	if factionMode == nil or factionMode == 0 or factionMode == 1 then
		PRIVATE.FILTER_FACTION = factionMode or BATTLEFIELD_SCORE_FACTION.BOTH
		SetBattlefieldScoreFaction(nil) -- triggers event
	end
end

_G.GetNumBattlefieldScores = function()
	return PRIVATE.GetNumBattlefieldScores()
end

_G.GetBattlefieldScore = function(scoreIndex)
	return PRIVATE.GetBattlefieldScore(scoreIndex)
end

_G.GetBattlefieldStatData = function(scoreIndex, statIndex)
	return PRIVATE.GetBattlefieldStatData(scoreIndex, statIndex)
end