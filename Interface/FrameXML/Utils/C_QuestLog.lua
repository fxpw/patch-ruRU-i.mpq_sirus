local error = error
local ipairs = ipairs
local pcall = pcall
local tonumber = tonumber
local type = type
local strformat = string.format
local tinsert, twipe = table.insert, table.wipe

local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestsCompleted = GetQuestsCompleted
local IsQuestDataCached = IsQuestDataCached
local QueryQuestsCompleted = QueryQuestsCompleted
local RequestLoadQuestByID = RequestLoadQuestByID
local UnitName = UnitName
local securecall = securecall

local FireClientEvent = FireClientEvent
local FireCustomClientEvent = FireCustomClientEvent
local SendServerMessage = SendServerMessage
local tIndexOf = tIndexOf

Enum.QueryQuestStartSource = {
	Suggestion = 1,
}
local QUERY_QUEST_START_SOURCE = Enum.CreateMirror(CopyTable(Enum.QueryQuestStartSource))

local PRIVATE = {
	CACHE_REQUESTS = {},
	CACHE_BLACKLIST = {},

	COMPLETED_QUESTS = {},
}

PRIVATE.EventHandler = CreateFrame("Frame")
PRIVATE.EventHandler:Hide()
PRIVATE.EventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.EventHandler:RegisterEvent("PLAYER_LOGIN")
PRIVATE.EventHandler:RegisterEvent("QUEST_DATA_LOAD_RESULT")
PRIVATE.EventHandler:RegisterEvent("QUEST_QUERY_COMPLETE")
PRIVATE.EventHandler:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
PRIVATE.EventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if channel == "UNKNOWN" and sender == UnitName("player") then
			if PRIVATE[prefix] then
				PRIVATE[prefix](message)
			end
		end
	elseif event == "QUEST_DATA_LOAD_RESULT" then
		local questID, success = ...

		if not success then
			PRIVATE.CACHE_BLACKLIST[questID] = true
		end

		local cacheRequest = PRIVATE.CACHE_REQUESTS[questID]
		if cacheRequest then
			if success and #cacheRequest > 0 then
				PRIVATE.HandleCacheCallbacks(cacheRequest, questID)
			end
			PRIVATE.CACHE_REQUESTS[questID] = nil
		end
	elseif event == "PLAYER_LOGIN" then
		QueryQuestsCompleted()
	elseif event == "QUEST_QUERY_COMPLETE" then
		twipe(PRIVATE.COMPLETED_QUESTS)
		GetQuestsCompleted(PRIVATE.COMPLETED_QUESTS)
		FireCustomClientEvent("QUEST_COMPLETED_BUCKET_UPDATE")
	elseif event == "PLAYERBANKSLOTS_CHANGED" then
		FireClientEvent("QUEST_LOG_UPDATE")
	end
end)

PRIVATE.GetQuestLogIndexByID = function(questID)
	local numEntries, numQuests = GetNumQuestLogEntries()
	for index = 1, numEntries do
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, _questID = GetQuestLogTitle(index)
		if not isHeader and questID == _questID then
			return index
		end
	end
end

PRIVATE.FireCacheCallback = function(callback, questID)
	local success, err = pcall(callback, questID)
	if not success then
		geterrorhandler()(err)
	end
end

PRIVATE.HandleCacheCallbacks = function(cacheRequests, questID)
	for index, callback in ipairs(cacheRequests) do
		securecall(PRIVATE.FireCacheCallback, callback, questID)
	end
end

PRIVATE.RequestQuestCacheByID = function(questID, callback)
	if type(callback) ~= "function" then
		callback = nil
	end

	if PRIVATE.CACHE_BLACKLIST[questID]
	or (PRIVATE.CACHE_REQUESTS[questID] and not callback)
	then
		return false
	end

	if IsQuestDataCached(questID) then
		if callback then
			PRIVATE.FireCacheCallback(callback, questID)
		end
		return false
	end

	if not PRIVATE.CACHE_REQUESTS[questID] then
		PRIVATE.CACHE_REQUESTS[questID] = {callback}
		RequestLoadQuestByID(questID)
	else
		if not tIndexOf(PRIVATE.CACHE_REQUESTS[questID], callback) then
			tinsert(PRIVATE.CACHE_REQUESTS[questID], callback)
		end
	end

	return true
end

PRIVATE.ASMSG_Q_C = function(msg)
	local questID = tonumber(msg)
	PRIVATE.COMPLETED_QUESTS[questID] = true
	FireCustomClientEvent("QUEST_COMPLETED", questID)
end

_G.GetQuestLogIndexByID = function(questID)
	if type(questID) ~= "number" then
		error(strformat("bad argument #1 to 'GetQuestLogIndexByID' (number expected, got %s)", type(questID)), 2)
	end

	return PRIVATE.GetQuestLogIndexByID(questID)
end

_G.QueryQuestStart = function(questID, sourceType, sourceID)
	if type(questID) ~= "number" then
		error(strformat("bad argument #1 to 'QueryQuestStart' (number expected, got %s)", type(questID)), 2)
	elseif type(sourceType) ~= "number" then
		error(strformat("bad argument #2 to 'QueryQuestStart' (number expected, got %s)", type(sourceType)), 2)
	elseif type(sourceID) ~= "number" then
		error(strformat("bad argument #3 to 'QueryQuestStart' (number expected, got %s)", type(sourceID)), 2)
	elseif sourceType < 0 or sourceType > #QUERY_QUEST_START_SOURCE then
		error(strformat("QueryQuestStart: unknown sourceType (%s)", sourceType), 2)
	end

	if PRIVATE.GetQuestLogIndexByID(questID) then
		return false
	end

	SendServerMessage("ACMSG_QUESTGIVER_QUERY_QUEST", questID, sourceType, sourceID)

	return true
end

_G.IsQuestCompleted = function(questID)
	if type(questID) ~= "number" then
		error(strformat("bad argument #1 to 'IsQuestCompleted' (number expected, got %s)", type(questID)), 2)
	end
	return PRIVATE.COMPLETED_QUESTS[questID] and true or false
end

_G.RequestQuestCacheByID = function(questID, callback)
	if type(questID) ~= "number" then
		error(strformat("bad argument #1 to 'RequestQuestCacheByID' (number expected, got %s)", questID ~= nil and type(questID) or "no value"), 2)
	end
	return PRIVATE.RequestQuestCacheByID(questID, callback)
end