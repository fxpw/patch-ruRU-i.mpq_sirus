local error = error
local time = time
local tonumber = tonumber
local type = type
local strformat = string.format
local twipe = table.wipe

local UnitGUID = UnitGUID
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName

local C_GlobalStorage = C_GlobalStorage
local FireCustomClientEvent = FireCustomClientEvent
local IsInterfaceDevClient = IsInterfaceDevClient
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx

local TIMEOUT_REPETITIVE_REQUESTS = true

local TTL_ASMSG_CHARACTER_BG_INFO = 300
local TIMEOUT_ASMSG_CHARACTER_BG_INFO = 30
local TTL_AVERAGE_ITEM_LEVEL = 15

local PRIVATE = {
--	LAST_INSPECT_NAME = nil,
--	LAST_INSPECT_GUID = nil,

--	AWAIT_AVERAGE_ITEM_LEVEL = nil,
--	AVERAGE_ITEM_LEVEL_QUEUE = nil,
--	AVERAGE_ITEM_LEVEL_QUEUE_PLAYER = nil,
--	PLAYER_AVG_ITEM_LEVEL_TIMER = nil,
}

local ITEM_LEVEL_SLOTS_BLACKLIST = {
	[INVSLOT_BODY] = true,
	[INVSLOT_TABARD] = true,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGIN")
PRIVATE.eventHandler:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
PRIVATE.eventHandler:RegisterEvent("UNIT_INVENTORY_CHANGED")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if channel == "UNKNOWN" and sender == UnitName("player") then
			if PRIVATE[prefix] then
				PRIVATE[prefix](message)
			end
		end
	elseif event == "PLAYER_LOGIN" then
		local guid = UnitGUID("player")
		PRIVATE.RequestAvgItemLevel(guid, true)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local slotID, hasItem = ...
		if not ITEM_LEVEL_SLOTS_BLACKLIST[slotID] then
			PRIVATE.OnUnitItemsChanged("player")
		end
	elseif event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if not UnitIsUnit(unit, "player") then
			PRIVATE.OnUnitItemsChanged(unit)
		end
	end
end)

PRIVATE.ASMSG_CHARACTER_BG_INFO = function(msg)
	local guid, rating, rankID, weekWins, weekGames, totalWins, totalGames = StringSplitEx("|", msg)

	guid = strformat("0x%016X", guid)

	local data = C_GlobalStorage.GetVar("ASMSG_CHARACTER_BG_INFO")
	if not data then
		data = {}
		C_GlobalStorage.SetVar("ASMSG_CHARACTER_BG_INFO", data)
	end

	if data[guid] then
		twipe(data[guid])
	end

	local now = time()

	data[guid] = {
		guid 		= guid,
		rating 		= tonumber(rating) or 0,
		rankID 		= tonumber(rankID) or 0,
		weekWins 	= tonumber(weekWins) or 0,
		weekGames 	= tonumber(weekGames) or 0,
		totalWins 	= tonumber(totalWins) or 0,
		totalGames 	= tonumber(totalGames) or 0,
		timestamp	= now,
	}

	FireCustomClientEvent("INSPECT_BG_INFO_AVAILABLE", guid)
end

do -- AverageItemLevel
	PRIVATE.RequestAvgItemLevel = function(guid, isPlayer)
		if PRIVATE.AWAIT_AVERAGE_ITEM_LEVEL then
			if PRIVATE.AWAIT_AVERAGE_ITEM_LEVEL == guid then
				return false
			elseif isPlayer then
				PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE_PLAYER = guid
			else
				PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE = guid
			end
			return false
		end

		PRIVATE.AWAIT_AVERAGE_ITEM_LEVEL = guid
		SendServerMessage("ACMSG_AVERAGE_ITEM_LEVEL_REQUEST", guid)
		return true
	end

	PRIVATE.ASMSG_AVERAGE_ITEM_LEVEL_RESPONSE = function(msg)
		local avgItemLevel = tonumber(msg)
		local guid = PRIVATE.AWAIT_AVERAGE_ITEM_LEVEL
		if not guid then
			return
		end

		local itemLevelCache = C_GlobalStorage.GetVar("ITEM_LEVEL_CACHE")
		if not itemLevelCache then
			itemLevelCache = {}
			C_GlobalStorage.SetVar("ITEM_LEVEL_CACHE", itemLevelCache)
		end

		local itemLevelInfo = itemLevelCache[guid]
		if not itemLevelInfo then
			itemLevelInfo = {}
			itemLevelCache[guid] = itemLevelInfo
		end

		if avgItemLevel >= 0 then
			itemLevelInfo.avgItemLevel = avgItemLevel
		else
			itemLevelInfo.avgItemLevel = nil
		end
		itemLevelInfo.timestamp = time()

		PRIVATE.AWAIT_AVERAGE_ITEM_LEVEL = nil
		PRIVATE.CheckAverageItemLevelQueue()

		if guid == UnitGUID("player") then
			FireCustomClientEvent("PLAYER_AVG_ITEM_LEVEL_READY")
		else
			FireCustomClientEvent("INSPECT_ITEM_LEVEL_UPDATE", guid)
		end
	end

	PRIVATE.CheckAverageItemLevelQueue = function()
		local guid

		if PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE_PLAYER then
			guid = PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE_PLAYER
			PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE_PLAYER = nil
		elseif PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE then
			guid = PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE
			PRIVATE.AVERAGE_ITEM_LEVEL_QUEUE = nil
		end

		if guid then
			PRIVATE.RequestAvgItemLevel(guid)
		end
	end

	PRIVATE.OnUnitItemsChanged = function(unit)
		local guid = UnitGUID(unit)
		if UnitIsUnit("player", unit) then
			if PRIVATE.PLAYER_AVG_ITEM_LEVEL_TIMER then
				PRIVATE.PLAYER_AVG_ITEM_LEVEL_TIMER:Cancel()
			end
			PRIVATE.PLAYER_AVG_ITEM_LEVEL_TIMER = C_Timer:After(0.05, function()
				PRIVATE.RequestAvgItemLevel(guid, true)
				PRIVATE.PLAYER_AVG_ITEM_LEVEL_TIMER = nil
			end)
		else
			local itemLevelCache = C_GlobalStorage.GetVar("ITEM_LEVEL_CACHE")
			if itemLevelCache then
				if itemLevelCache[guid] then
					itemLevelCache[guid].timestamp = 0
					FireCustomClientEvent("INSPECT_ITEM_LEVEL_UPDATE", guid)
				end
			end
		end
	end

	PRIVATE.GetPlayerAvgItemLevel = function()
		local guid = UnitGUID("player")
		if guid then
			local avgItemLevelEquipped = PRIVATE.GetAvgItemLevel(guid, true)
			return avgItemLevelEquipped or 0
		end
		return 0
	end

	PRIVATE.GetAvgItemLevel = function(guid, skitTTL)
		local itemLevelCache = C_GlobalStorage.GetVar("ITEM_LEVEL_CACHE")
		if itemLevelCache then
			local itemLevelInfo = itemLevelCache[guid]
			if itemLevelInfo then
				if not skitTTL and (itemLevelInfo.timestamp + TTL_AVERAGE_ITEM_LEVEL) <= time() then
					PRIVATE.RequestAvgItemLevel(guid)
				end
				return itemLevelInfo.avgItemLevel
			end
		end
	end
end

C_Inspect = {}

function C_Inspect.GetLastInspectName()
	return PRIVATE.LAST_INSPECT_NAME
end

function C_Inspect.GetLastInspectGUID()
	return PRIVATE.LAST_INSPECT_GUID
end

function C_Inspect.RequestInspectInfoEx(unitToken)
	if type(unitToken) ~= "string" then
		error("Usage: C_Inspect.RequestInspectInfoEx(unitToken)", 2)
	end

	if not UnitIsPlayer(unitToken) then
		return
	end

	local guid = UnitGUID(unitToken)
	if not guid then
		return
	end

	PRIVATE.LAST_INSPECT_NAME = UnitName(unitToken)
	PRIVATE.LAST_INSPECT_GUID = guid

	SendServerMessage("ACMSG_BG_STATS_REQUEST", guid)
--[[
	ASMSG_CHARACTER_BG_INFO
	ASMSG_CHARACTER_BG_STATS
	ASMSG_CHARACTER_ARENA_INFO
	ASMSG_PVP_STATS_INSPECT
	ASMSG_INSPECT_GLYPHS
	ASMSG_AR_LAST_INSPECT_REPLAYS
	ASMSG_PVP_LADDER_PLAYER_INSPECT
--]]
end

function C_Inspect.RequestBattlegroundRankInfo(unitToken)
	if type(unitToken) ~= "string" then
		error("Usage: C_Inspect.RequestInspectInfoEx(unitToken)", 2)
	end

	if not UnitIsPlayer(unitToken) then
		return
	end

	local guid = UnitGUID(unitToken)
	if not guid then
		return
	end

	if TIMEOUT_REPETITIVE_REQUESTS and not IsInterfaceDevClient() then
		local data = C_GlobalStorage.GetVar("ASMSG_CHARACTER_BG_INFO")
		if data then
			local unitInfo = data[guid]
			if unitInfo then
				if (time() - unitInfo.timestamp) < TIMEOUT_ASMSG_CHARACTER_BG_INFO then
					return
				end
			end
		end
	end

	SendServerMessage("ACMSG_CHAR_BG_INFO", guid)
end

function C_Inspect.GetBattlegroundRankInfo(unitToken)
	if type(unitToken) ~= "string" then
		error("Usage: C_Inspect.GetBattlegroundRankInfo(unitToken)", 2)
	end

	if not UnitIsPlayer(unitToken) then
		return
	end

	local guid = UnitGUID(unitToken)
	if not guid then
		return
	end

	local data = C_GlobalStorage.GetVar("ASMSG_CHARACTER_BG_INFO")
	if data then
		local unitInfo = data[guid]
		if unitInfo then
			if (unitInfo.timestamp + TTL_ASMSG_CHARACTER_BG_INFO) <= time() then
				data[guid] = nil
				return
			end

			return unitInfo.rankID, unitInfo.rating, unitInfo.weekWins, unitInfo.weekGames, unitInfo.totalWins, unitInfo.totalGames
		end
	end
end

function C_Inspect.RequestAvgItemLevel(unitToken)
	if type(unitToken) ~= "string" then
		error("Usage: C_Inspect.GetItemLevel(unitToken)", 2)
	end

	if not UnitIsPlayer(unitToken)
--	or UnitIsEnemy(unitToken)
	or UnitIsUnit("player", unitToken) -- rely on internal handling of player
	or not UnitIsConnected(unitToken)
--	or not CanInspect(unitToken)
	then
		return false
	end

	local guid = UnitGUID(unitToken)
	if not guid then
		return false
	end

	local itemLevelCache = C_GlobalStorage.GetVar("ITEM_LEVEL_CACHE")
	if itemLevelCache then
		local itemLevelInfo = itemLevelCache[guid]
		if itemLevelInfo then
			if itemLevelInfo.timestamp + TTL_AVERAGE_ITEM_LEVEL > time() then
				return false
			end
		end
	end

	PRIVATE.RequestAvgItemLevel(guid)
	return true
end

function C_Inspect.GetAvgItemLevel(unitToken)
	if type(unitToken) ~= "string" then
		error("Usage: C_Inspect.GetItemLevel(unitToken)", 2)
	end

	if not UnitIsPlayer(unitToken) then
		return
	end

	if UnitIsUnit("player", unitToken) then
		return PRIVATE.GetPlayerAvgItemLevel()
	end

	local guid = UnitGUID(unitToken)
	if not guid then
		return
	end

	return PRIVATE.GetAvgItemLevel(guid)
end

function GetAverageItemLevel()
	return PRIVATE.GetPlayerAvgItemLevel()
end