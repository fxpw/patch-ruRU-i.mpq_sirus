local error = error
local next = next
local pairs = pairs
local ipairs = ipairs
local pcall = pcall
local tonumber = tonumber
local type = type
local bitband = bit.band
local mathabs, mathceil, mathmax, mathmin = math.abs, math.ceil, math.max, math.min
local strfind, strformat, strgmatch, strgsub, strrep = string.find, string.format, string.gmatch, string.gsub, string.rep
local strlen, strlower, strmatch, strsplit, strsub, strtrim = string.len, string.lower, string.match, string.split, string.sub, string.trim
local tconcat, tinsert, tremove, tsort, twipe = table.concat, table.insert, table.remove, table.sort, table.wipe
local utf8byte, utf8len, utf8sub = utf8.byte, utf8.len, utf8.sub

local CalculateStringEditDistance = CalculateStringEditDistance
local GetFramerate = GetFramerate
local KBSystem_GetMOTD = KBSystem_GetMOTD
local KBSystem_GetServerNotice = KBSystem_GetServerNotice
local KBSystem_GetServerStatus = KBSystem_GetServerStatus
local debugprofilestop = debugprofilestop
local geterrorhandler = geterrorhandler

local ClampedPercentageBetween = ClampedPercentageBetween
local CopyTable = CopyTable
local FireCustomClientEvent = FireCustomClientEvent
local GMError = GMError
local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient
local RoundToSignificantDigits = RoundToSignificantDigits
local RunNextFrame = RunNextFrame
local tCompare = tCompare
local tIndexOf = tIndexOf

SIRUS_KNOWLEDGE_BASE_IDS = {}
SIRUS_KNOWLEDGE_BASE_IDS.ROOT = Enum.CreateMirror({
	ARTICLE = 1,
	CATEGORY = 2,
	SUB_CATEGORY = 3,
--	LANGUAGE = 4,
	LAST_EDIT_TIME = 9,
})

SIRUS_KNOWLEDGE_BASE_IDS.ARTICLE = {
	ARTICLE_ID		= 1,	-- articleID
	ARTICLE_HEADER	= 2,	-- articleHeader
	SUBJECT			= 3,	-- subject
	SUBJECT_ALT		= 4,	-- subjectAlt
	KEYWORDS		= 5,	-- keywords
	TEXT			= 6,	-- text

	IS_HOT			= 7,	-- isHot
	IS_NEW			= 8,	-- isNew
	IS_TOP			= 9,	-- isTopIssue

	CATEGORY_ID		= 10,	-- categoryID
	SUB_CATEGORY_ID	= 11,	-- subCategoryID
	LANGUAGE_ID		= 12,	-- languageID

	VISIBILITY		= 13,	-- visibility
	PRIORITY		= 14,	-- priority
}
SIRUS_KNOWLEDGE_BASE_IDS.CATEGORY = {
	CATEGORY_ID		= 1,	-- categoryID
	CAPTION			= 2,	-- caption

	PARENT_ID		= 3,	-- parentID

	VISIBILITY		= 4,	-- visibility
	PRIORITY		= 5,	-- priority
}
SIRUS_KNOWLEDGE_BASE_IDS.SUB_CATEGORY = SIRUS_KNOWLEDGE_BASE_IDS.CATEGORY

SIRUS_KNOWLEDGE_BASE_DEFAULTS = {}
SIRUS_KNOWLEDGE_BASE_DEFAULTS.ARTICLE = {
--	articleID = 0,
	articleHeader = "",
	isHot = false,
	isNew = false,
	isTopIssue = false,
	categoryID = 0,
	subCategoryID = 0,

	text = "",
	subject = "",
	subjectAlt = "",
	keywords = "",
	languageID = 1,

	visibility = 0x1,
	priority = 0,
}
SIRUS_KNOWLEDGE_BASE_DEFAULTS.CATEGORY = {
--	categoryID = 0,
	caption = "",

	parentID = -1,

	visibility = 0x1,
	priority = 0,
}
SIRUS_KNOWLEDGE_BASE_DEFAULTS.SUB_CATEGORY = SIRUS_KNOWLEDGE_BASE_DEFAULTS.CATEGORY

KNOWLEDGEBASE_BACKUP = {
	KNOWLEDGEBASE_ARTICLES = {},
	KNOWLEDGEBASE_CATEGORIES = {},
	KNOWLEDGEBASE_SUB_CATEGORIES = {},
	KNOWLEDGEBASE_LANGUAGES = {},
}

KNOWLEDGE_BASE_SAVE_TEMPLATE = {
	[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE] = true,
	[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY] = true,
	[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY] = true,
--	[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.LANGUAGES] = true,
}

KNOWLEDGE_BASE_VISIBILITY_FLAGS = {
	NONE						= 0x0,
	ALL							= 0x1,
--	SEASONAL					= 0x2,

--	[E_REALM_ID.FROSTMOURNE]	= 0x10,
	[E_REALM_ID.NELTHARION]		= 0x20,
	[E_REALM_ID.LEGACY_X10]		= 0x40,

	[E_REALM_ID.SCOURGE]		= 0x80,
	[E_REALM_ID.ALGALON]		= 0x100,
	[E_REALM_ID.SIRUS]			= 0x200,
	[E_REALM_ID.SOULSEEKER]		= 0x400,
}

local KB_NO_PAGES = true
local KB_SEARCH_LIMIT = 128
local KB_SORT_ARTICLES = true
local KB_SORT_CATEGORIES = true
local KB_KEYWORDS_DELIMITER = ","
local KB_QUERY_SEACH_BY_TAGS = true

local SEARCH_TYPE = {
	QUERY = 1,
	SUGGESTIONS = 2,
}

local KB_KEYWORD_TYPES = {
	EXACT = "=",
	CONTAINS = "+",
	CONTAINS_DIST = "~",
	STARTS_WITH = "^",
	ENDS_WITH = "$",
}

local KB_SUGGESTION_WORD_DICT_ENUM = {
	COUNT = 1,
	INDEXES = 2,
}

local PRIVATE = {
	ARTICLES_LOADED = false,
	ARTICLE_DEFAULT_LOADED = false,
	CATEGORIES_LOADED = false,
	CATEGORY_DEFAULT_LOADED = false,

	CATEGORIES = {},
	CURRENT_ARTICLES = {},
	TOP_ISSUES = {},

	KEYWORDS_CACHE = {},
	KEYWORDS_CACHE_LEN = 0,

	SEARCHES_ACTIVE = {},
	SEARCHES = {},
	SEARCH_DISTANCE_CACHE = {},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("VARIABLES_LOADED")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGOUT")
PRIVATE.eventHandler:SetScript("OnEvent", function(this, event, ...)
	if event == "VARIABLES_LOADED" then
		if not SIRUS_KNOWLEDGE_BASE then
			SIRUS_KNOWLEDGE_BASE = {}
		elseif KNOWLEDGEBASE_VERSION then
			local lastEditTime = SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.LAST_EDIT_TIME]
			if not lastEditTime or lastEditTime < KNOWLEDGEBASE_VERSION then
				twipe(SIRUS_KNOWLEDGE_BASE)
			end
		end
		for index in pairs(KNOWLEDGE_BASE_SAVE_TEMPLATE) do
			if not SIRUS_KNOWLEDGE_BASE[index] then
				SIRUS_KNOWLEDGE_BASE[index] = {}
			end
		end
	elseif event == "PLAYER_LOGOUT" then
		if type(SIRUS_KNOWLEDGE_BASE) ~= "table" then
			return
		end
		local t, r = 0, 0
		for index in pairs(KNOWLEDGE_BASE_SAVE_TEMPLATE) do
			t = t + 1
			if not SIRUS_KNOWLEDGE_BASE[index] then
				r = r + 1
			elseif not next(SIRUS_KNOWLEDGE_BASE[index]) then
				SIRUS_KNOWLEDGE_BASE[index] = nil
				r = r + 1
			end
		end
		if t == r then
			twipe(SIRUS_KNOWLEDGE_BASE)
		else
			for index in pairs(SIRUS_KNOWLEDGE_BASE) do
				if not SIRUS_KNOWLEDGE_BASE_IDS.ROOT[index] then
					SIRUS_KNOWLEDGE_BASE[index] = nil
				end
			end
		end
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(this, elapsed)
	local index = 1
	local search = PRIVATE.SEARCHES_ACTIVE[index]
	while search do
		local frametimeStep = search.FRAMETIME_TARGET - elapsed

		if frametimeStep ~= 0 then
			frametimeStep = frametimeStep * 1000
			search.FRAMETIME_AVAILABLE = mathmax(5, search.FRAMETIME_AVAILABLE + frametimeStep)
		end

		if search.COROUTINE then
			search.COROUTINE_TIMESTAMP = debugprofilestop()
			local status, progress, result = coroutine.resume(search.COROUTINE)

			if not status then
				search.COROUTINE_RESULT = nil
				search.COROUTINE = nil
				tremove(PRIVATE.SEARCHES_ACTIVE, index)
				index = index - 1
				PRIVATE.SearchFireFinishCallback(search, false)
				error(progress, 2)
			elseif progress ~= -1 then
				FireCustomClientEvent(search.EVENT_PROGRESS, progress)
				if search.COROUTINE_DEBUG then print(search.EVENT_PROGRESS, progress) end
			else
				search.COROUTINE_RESULT = result
				search.COROUTINE = nil
				tremove(PRIVATE.SEARCHES_ACTIVE, index)
				index = index - 1
				PRIVATE.SendSearchAvailable(SEARCH_TYPE.SUGGESTIONS, "Delayed")
				PRIVATE.SearchFireFinishCallback(search, true)
			end
		else
			tremove(PRIVATE.SEARCHES_ACTIVE, index)
			index = index - 1
		end

		index = index + 1
		search = PRIVATE.SEARCHES_ACTIVE[index]
	end

	if #PRIVATE.SEARCHES_ACTIVE == 0 then
		this:Hide()
	end
end)

PRIVATE.Initialize = function()
	PRIVATE.CreateSearchType(
		SEARCH_TYPE.QUERY,
		"KNOWLEDGE_BASE_QUERY_AVAILABLE",
		"KNOWLEDGE_BASE_QUERY_NEXT",
		"KNOWLEDGE_BASE_QUERY_PROGRESS"
	)
	PRIVATE.CreateSearchType(
		SEARCH_TYPE.SUGGESTIONS,
		"KNOWLEDGE_BASE_SUGGESTIONS_AVAILABLE",
		"KNOWLEDGE_BASE_SUGGESTIONS_NEXT",
		"KNOWLEDGE_BASE_SUGGESTIONS_PROGRESS"
	)

	if IsInterfaceDevClient(true) then
		_G.PRIVATE_KB = PRIVATE
	end
end

PRIVATE.CreateSearchType = function(searchType, eventAvailable, eventNext, eventProgress)
	if PRIVATE.SEARCHES[searchType] then
		return
	end
	PRIVATE.SEARCHES[searchType] = {
		TYPE = searchType,
		EVENT_AVAILABLE = eventAvailable,
		EVENT_NEXT = eventNext,
		EVENT_PROGRESS = eventProgress,

		DEBUG = false,
		DEBUG_KEYWORDS = false,

		MIN_CHARS = 2,
		MAX_CHAR_DIFF = 8,

		FRAMETIME_TARGET = 1 / 55,
		FRAMETIME_AVAILABLE = 8,
		FRAMETIME_RESERVE = 4,

		COROUTINE_DEBUG = false,
	--	COROUTINE = nil,
	--	COROUTINE_TIMESTAMP = nil,
	--	COROUTINE_RESULT = nil,

	--	WORD_DISTANCE = nil,
	--	WORD_ARRAY = nil,
	--	WORD_DICT = nil,
	--	WORD_DICT_LEN = nil,

		REQUEST_KEYWORDS = false,
	--	NEXT = nil,
	}
end

PRIVATE.GetSearchType = function(searchType)
	local search = PRIVATE.SEARCHES[searchType]
	assert(type(search) == "table")
	return search
end

PRIVATE.SearchEnqueue = function(search)
	tinsert(PRIVATE.SEARCHES_ACTIVE, search)
	PRIVATE.eventHandler:Show()
end

PRIVATE.SearchDequeue = function(search)
	local index = tIndexOf(PRIVATE.SEARCHES_ACTIVE, search)
	if index then
		tremove(PRIVATE.SEARCHES_ACTIVE, search)
		if #PRIVATE.SEARCHES_ACTIVE == 0 then
			PRIVATE.eventHandler:Hide()
		end
	end
end

PRIVATE.SearchFireFinishCallback = function(search, isSuccess)
	if type(search.COROUTINE_ON_FINISH_CALLBACK) == "function" then
		local success, err = pcall(search.COROUTINE_ON_FINISH_CALLBACK, search.TYPE, isSuccess)
		if not success then
			geterrorhandler()(err)
		end
	end
end

PRIVATE.UpgradeEntry = function(entry, dataTypeIndex)
	if type(entry.hidden) == "boolean" then
		entry.visibility = entry.hidden and KNOWLEDGE_BASE_VISIBILITY_FLAGS.NONE or KNOWLEDGE_BASE_VISIBILITY_FLAGS.ALL
		entry.hidden = nil
	end

	local editTimeIndex = SIRUS_KNOWLEDGE_BASE_IDS.ROOT.LAST_EDIT_TIME
	local lastEditTime = SIRUS_KNOWLEDGE_BASE[editTimeIndex]
	if lastEditTime then
--[[
		if lastEditTime < 0 then
			if dataTypeIndex == SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE then
				entry.text = entry.text:gsub("<spacing>", "<indent>")
			end
		end
--]]
	end
end

PRIVATE.IsEntryVisible = function(entry, realmID)
	if entry.visibility then
		if entry.visibility == KNOWLEDGE_BASE_VISIBILITY_FLAGS.ALL then
			return true
		elseif entry.visibility == KNOWLEDGE_BASE_VISIBILITY_FLAGS.NONE then
			return false
		else
			realmID = realmID or C_Service.GetRealmID()

			if KNOWLEDGE_BASE_VISIBILITY_FLAGS[realmID] then
				return bitband(entry.visibility, KNOWLEDGE_BASE_VISIBILITY_FLAGS[realmID]) ~= 0
			else
				return false
			end
		end
	else
		GMError("No visibility flag for entry")
	end
end

PRIVATE.GetOnPageNum = function(numItems, perPage, currentPage)
	local numOnPage = numItems - (currentPage - 1) * perPage
	return numOnPage > perPage and perPage or numOnPage
end

PRIVATE.SortArticles = function(a, b)
	if a.priority ~= b.priority then
		return a.priority > b.priority
	end

	if a.isHot and not b.isHot then
		return true
	elseif not a.isHot and b.isHot then
		return false
	end

	if a.isNew and not b.isNew then
		return true
	elseif not a.isNew and b.isNew then
		return false
	end

	return a.articleHeader < b.articleHeader
end

PRIVATE.SortCategories = function(a, b)
	if a.priority ~= b.priority then
		return a.priority > b.priority
	end

	return a.caption < b.caption
end

PRIVATE.LoadArticles = function()
	if PRIVATE.ARTICLES_LOADED and not Custom_KnowledgeBase.articlesChanged then return end

	if not PRIVATE.ARTICLE_DEFAULT_LOADED then
		for id, entry in pairs(KNOWLEDGEBASE_ARTICLES) do
			for key, defaultValue in pairs(SIRUS_KNOWLEDGE_BASE_DEFAULTS.ARTICLE) do
				if entry[key] == nil then
					entry[key] = defaultValue
				end
			end
			if not entry.articleID then
				entry.articleID = id
			end
			PRIVATE.UpgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE)
		end

		PRIVATE.ARTICLE_DEFAULT_LOADED = true
	end

	if SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE] then
		for id, diff in pairs(SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE]) do
			if diff == false then
				KNOWLEDGEBASE_ARTICLES[id] = nil
			else
				local entry

				if KNOWLEDGEBASE_ARTICLES[id] then
					if not KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES[id] then
						KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES[id] = CopyTable(KNOWLEDGEBASE_ARTICLES[id])
						entry = KNOWLEDGEBASE_ARTICLES[id]
					elseif KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES[id] ~= 0 then
						entry = CopyTable(KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES[id])
					else
						entry = KNOWLEDGEBASE_ARTICLES[id]
					end
				else
					KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES[id] = 0
					entry = CopyTable(SIRUS_KNOWLEDGE_BASE_DEFAULTS.ARTICLE)
				end

				if entry then
					for key, value in pairs(diff) do
						entry[key] = value
					end
					if not entry.articleID then
						entry.articleID = id
					end
					PRIVATE.UpgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE)
					KNOWLEDGEBASE_ARTICLES[id] = entry
				end
			end
		end

		for id, entry in pairs(KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES) do
			if SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE][id] == nil and KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_ARTICLES[id] ~= 0 then
				KNOWLEDGEBASE_ARTICLES[id] = CopyTable(entry)
			end
		end
	end

	do	-- TOP_ISSUES
		twipe(PRIVATE.TOP_ISSUES)
		local isGM = IsGMAccount()
		local realmID = C_Service.GetRealmID()

		for articleID, article in pairs(KNOWLEDGEBASE_ARTICLES) do
			if article.isTopIssue and (PRIVATE.IsEntryVisible(article, realmID) or isGM) then
				tinsert(PRIVATE.TOP_ISSUES, article)
			end
		end

		if KB_SORT_ARTICLES then
			tsort(PRIVATE.TOP_ISSUES, PRIVATE.SortArticles)
		end
	end

	twipe(PRIVATE.KEYWORDS_CACHE)
	PRIVATE.KEYWORDS_CACHE_LEN = 0

	PRIVATE.ARTICLES_LOADED = true
	Custom_KnowledgeBase.articlesChanged = nil
end

PRIVATE.LoadCategories = function()
	if PRIVATE.CATEGORIES_LOADED and not Custom_KnowledgeBase.categoriesChanged then return end

	local isGM = IsGMAccount()
	local realmID = C_Service.GetRealmID()

	if not PRIVATE.CATEGORY_DEFAULT_LOADED then
		for id, entry in pairs(KNOWLEDGEBASE_CATEGORIES) do
			for key, defaultValue in pairs(SIRUS_KNOWLEDGE_BASE_DEFAULTS.CATEGORY) do
				if entry[key] == nil then
					entry[key] = defaultValue
				end
			end
			if not entry.categoryID then
				entry.categoryID = id
			end
			PRIVATE.UpgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY)
		end

		for id, entry in pairs(KNOWLEDGEBASE_SUB_CATEGORIES) do
			for key, defaultValue in pairs(SIRUS_KNOWLEDGE_BASE_DEFAULTS.SUB_CATEGORY) do
				if entry[key] == nil then
					entry[key] = defaultValue
				end
			end
			if not entry.categoryID then
				entry.categoryID = id
			end
			PRIVATE.UpgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY)
		end

		PRIVATE.CATEGORY_DEFAULT_LOADED = true
	end

	if SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY] then
		for id, diff in pairs(SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY]) do
			if diff == false then
				KNOWLEDGEBASE_CATEGORIES[id] = nil
			else
				local entry

				if KNOWLEDGEBASE_CATEGORIES[id] then
					if not KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES[id] then
						KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES[id] = CopyTable(KNOWLEDGEBASE_CATEGORIES[id])
						entry = KNOWLEDGEBASE_CATEGORIES[id]
					elseif KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES[id] ~= 0 then
						entry = CopyTable(KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES[id])
					else
						entry = KNOWLEDGEBASE_CATEGORIES[id]
					end
				else
					KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES[id] = 0
					entry = CopyTable(SIRUS_KNOWLEDGE_BASE_DEFAULTS.CATEGORY)
				end

				if entry then
					for key, value in pairs(diff) do
						entry[key] = value
					end
					if not entry.categoryID then
						entry.categoryID = id
					end
					PRIVATE.UpgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY)
					KNOWLEDGEBASE_CATEGORIES[id] = entry
				end
			end
		end

		for id, entry in pairs(KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES) do
			if SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY][id] == nil and KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_CATEGORIES[id] ~= 0 then
				KNOWLEDGEBASE_CATEGORIES[id] = CopyTable(entry)
			end
		end
	end

	if SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY] then
		for id, diff in pairs(SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY]) do
			if diff == false then
				KNOWLEDGEBASE_SUB_CATEGORIES[id] = nil
			else
				local entry

				if KNOWLEDGEBASE_SUB_CATEGORIES[id] then
					if not KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES[id] then
						KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES[id] = CopyTable(KNOWLEDGEBASE_SUB_CATEGORIES[id])
						entry = KNOWLEDGEBASE_SUB_CATEGORIES[id]
					elseif KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES[id] ~= 0 then
						entry = CopyTable(KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES[id])
					else
						entry = KNOWLEDGEBASE_SUB_CATEGORIES[id]
					end
				else
					KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES[id] = 0
					entry = CopyTable(SIRUS_KNOWLEDGE_BASE_DEFAULTS.CATEGORY)
				end

				if entry then
					for key, value in pairs(diff) do
						entry[key] = value
					end
					if not entry.categoryID then
						entry.categoryID = id
					end
					PRIVATE.UpgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY)
					KNOWLEDGEBASE_SUB_CATEGORIES[id] = entry
				end
			end
		end

		for id, entry in pairs(KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES) do
			if SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY][id] == nil and KNOWLEDGEBASE_BACKUP.KNOWLEDGEBASE_SUB_CATEGORIES[id] ~= 0 then
				KNOWLEDGEBASE_SUB_CATEGORIES[id] = CopyTable(entry)
			end
		end
	end

	do	-- SORTED CATEGORIES
		twipe(PRIVATE.CATEGORIES)

		-- Wipe old subCategories
		for categoryID, category in pairs(KNOWLEDGEBASE_CATEGORIES) do
			if category.parentID == -1 and (PRIVATE.IsEntryVisible(category, realmID) or isGM) then
				tinsert(PRIVATE.CATEGORIES, category)

				if not category.subCategories then
					category.subCategories = {}
				else
					twipe(category.subCategories)
				end
			end
		end

		-- Add subCategories
		for categoryID, category in pairs(KNOWLEDGEBASE_SUB_CATEGORIES) do
			if category.parentID ~= -1 and (PRIVATE.IsEntryVisible(category, realmID) or isGM) then
				tinsert(KNOWLEDGEBASE_CATEGORIES[category.parentID].subCategories, category)
			end
		end

		-- Sort subCategories
		if KB_SORT_CATEGORIES then
			tsort(PRIVATE.CATEGORIES, PRIVATE.SortCategories)

			for categoryID, category in pairs(PRIVATE.CATEGORIES) do
				if category.parentID == -1 then
					tsort(category.subCategories, PRIVATE.SortCategories)
				end
			end
		end
	end

	PRIVATE.CATEGORIES_LOADED = true
	Custom_KnowledgeBase.categoriesChanged = nil
end

PRIVATE.GetSubCategoryByIndex = function(categoryIndex, subCategoryIndex)
	return PRIVATE.CATEGORIES[categoryIndex].subCategories[subCategoryIndex].categoryID
end

PRIVATE.ToArrayKeywords = function(t)
	local newT = {}
	local index = 1
	for keyword in pairs(t) do
		newT[index] = keyword
		index = index + 1
	end
	tsort(newT)
	return newT
end

do -- Search
	local SEARCH_MIN_DISTANCE = 0.8
	local SEARCH_MIN_DISTANCE_DEBUG = 0.6

	local SCORE_VALUE = {
		MATCH = 3,
		NEAR = 2,
		LONG = 1.5,
		SHORT = 0.5,
	}

	local WORD_BLACKLIST = {
		["мы"] = true, ["нас"] = true, ["нам"] = true,
		["они"] = true, ["их"] = true,
		["я"] = true, ["мне"] = true, ["меня"] = true, ["мной"] = true, ["мною"] = true,
		["ты"] = true, ["тебя"] = true, ["тебе"] = true, ["тобой"] = true, ["тобою"] = true,
		["он"] = true, ["него"] = true, ["ему"] = true, ["нему"] = true, ["его"] = true, ["им"] = true, ["ним"] = true, ["нем"] = true, ["нём"] = true,
		["она"] = true, ["её"] = true, ["ее"] = true, ["неё"] = true, ["нее"] = true, ["ей"] = true, ["ней"] = true, ["ею"] = true, ["нею"] = true,
		["оно"] = true,

		["как"] = true, ["кто"] = true, ["что"] = true,
		["какой"] = true, ["каков"] = true, ["чей"] = true, ["который"] = true,
		["этот"] = true, ["эта"] = true, ["это"] = true, ["эти"] = true,

		["тот"] = true, ["та"] = true, ["то"] = true, ["те"] = true,
		["такой"] = true, ["такая"] = true, ["такое"] = true, ["такие"] = true,
		["таков"] = true, ["такова"] = true, ["таково"] = true, ["таковы"] = true,
		["сей"] = true, ["сия"] = true, ["сие"] = true, ["сии"] = true,

		["все"] = true, ["весь"] = true,
		["всякий"] = true, ["любой"] = true, ["каждый"] = true,
		["сам"] = true, ["самый"] = true,
		["другой"] = true, ["иной"] = true,

		["никто"] = true, ["ничто"] = true, ["некого"] = true, ["нечего"] = true, ["нисколько"] = true,
		["никакой"] = true, ["ничей"] = true,

		["некто"] = true, ["нечто"] = true,
		["некий"] = true, ["некоторый"] = true,
		["несколько"] = true,
		["как-то"] = true, ["что-то"] = true,
		["както"] = true, ["чтото"] = true,
		["как-либо"] = true, ["что-либо"] = true,
		["каклибо"] = true, ["чтолибо"] = true,
		["как-нибудь"] = true, ["что-нибудь"] = true,
		["какнибудь"] = true, ["чтонибудь"] = true,

		["когда"] = true, ["сколько"] = true,
		["хочу"] = true, ["хотел"] = true,
		["не"] = true,
		["привет"] = true,

		["h1"] = true, ["h2"] = true, ["h3"] = true,
		["img"] = true, ["color"] = true,
		["br"] = true, ["li"] = true, ["hr"] = true,
		["center"] = true, ["right"] = true, ["left"] = true,
		["spacing"] = true, ["indent"] = true, ["align"] = true,
	}

	local punctuationChars = {
		"\033",		-- !
		"\034",		-- "
		"\035",		-- #
		"%\036",	-- $
		"%\037",	-- %
		"\038",		-- &
		"\039",		-- ’
		"%\040",	-- (
		"%\041",	-- )
		"%\042",	-- *
		"%\043",	-- +
		"\044",		-- ,
	--	"%\045",	-- -
		"%\046",	-- .
		"\047",		-- /
		"\058",		-- :
		"\059",		-- ;
		"\060",		-- <
		"\061",		-- =
		"\062",		-- >
		"\063",		-- ?
		"\064",		-- @
		"%\091",	-- [
		"\092",		-- \
		"%\093",	-- ]
		"%\094",	-- ^
		"\095",		-- _
		"\096",		-- `
		"\123",		-- {
		"\124",		-- |
		"\125",		-- }
		"\126",		-- ~
	}

	local WORD_MATCH_PATTERN = strformat("([^%%s%%p][^%%s%%p][^%%s%s]+)", tconcat(punctuationChars, ""))

	PRIVATE.SearchTextInArticleFields = function(article, text, split)
		if text == "" then
			return true
		end

		text = strtrim(text)

		if utf8len(text) < 2 then
			return false
		end

		text = text:lower()

		local articleID = strmatch(text, "^kb(%d+)$")
		if articleID then
			return article.articleID == tonumber(articleID)
		end

		text = text:gsub("%p+", " ")
		text = text:gsub("%s+", " ")

		if not split then
			if strfind(article.articleHeader:lower(), text, 1, true)
			or (article.subject ~= "" and strfind(article.subject:lower(), text, 1, true))
			or (article.subjectAlt ~= "" and strfind(article.subjectAlt:lower(), text, 1, true))
			or strfind(article.keywords, text, 1, true)
			or strfind(article.text:lower(), text, 1, true)
			then
				return true
			end
		else
			text = strtrim(text)

			for _, word in ipairs({strsplit(" ", text)}) do
				if not WORD_BLACKLIST[word] then
					if strfind(article.articleHeader:lower(), word, 1, true)
					or (article.subject ~= "" and strfind(article.subject:lower(), word, 1, true))
					or (article.subjectAlt ~= "" and strfind(article.subjectAlt:lower(), word, 1, true))
					or strfind(article.keywords, word, 1, true)
					or strfind(article.text:lower(), word, 1, true)
					then
						return true
					end
				end
			end
		end
	end

	PRIVATE.SortDistance = function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		elseif a[1].priority ~= b[1].priority then
			return a[1].priority > b[1].priority
		elseif a[1].articleHeader ~= b[1].articleHeader then
			return a[1].articleHeader > b[1].articleHeader
		end

		return a[1].articleID > b[1].articleID
	end

	local aLen, bLen
	PRIVATE.StringDistance = function(a, b, deleteCosts, insertCosts, substituteCosts)
		aLen = utf8len(a)
		bLen = utf8len(b)

		if not deleteCosts then deleteCosts = 1 end
		if not insertCosts then insertCosts = 1 end
		if not substituteCosts then substituteCosts = 1 end

		if aLen == 0 or bLen == 0 then
			return mathmax(aLen, bLen)
		end

		aLen = aLen + 1
		bLen = bLen + 1

		local matrix = {}

		-- increment along the first column of each row
		for i = 1, bLen do
			matrix[i] = {i - insertCosts}
		end

		-- increment each column in the first row
		for j = 1, aLen do
			matrix[1][j] = j - deleteCosts
		end

		-- fill in the rest of the matrix
		for i = 2, bLen do
			for j = 2, aLen do
				if utf8byte(b, i - 1) == utf8byte(a, j - 1) then
					matrix[i][j] = matrix[i - 1][j - 1]
				else
					matrix[i][j] = mathmin(
						matrix[i - 1][j] + deleteCosts,			-- deletion
						matrix[i][j - 1] + insertCosts,			-- insertion
						matrix[i - 1][j - 1] + substituteCosts	-- substitution
					)
				end
			end
		end

		return matrix[bLen][aLen]
	end

	PRIVATE.GetStringDistance = function(a, b, deleteCosts, insertCosts, substituteCosts)
		if a == b then
			return 0
		end

		if PRIVATE.SEARCH_DISTANCE_CACHE[a]
		and PRIVATE.SEARCH_DISTANCE_CACHE[a][b]
		then
			return PRIVATE.SEARCH_DISTANCE_CACHE[a][b]
		elseif PRIVATE.SEARCH_DISTANCE_CACHE[b]
		and PRIVATE.SEARCH_DISTANCE_CACHE[b][a]
		then
			return PRIVATE.SEARCH_DISTANCE_CACHE[b][a]
		end

		local distance = PRIVATE.StringDistance(a, b, deleteCosts, insertCosts, substituteCosts)
		PRIVATE.SEARCH_DISTANCE_CACHE[a] = PRIVATE.SEARCH_DISTANCE_CACHE[a] or {}
		PRIVATE.SEARCH_DISTANCE_CACHE[a][b] = distance

		return distance
	end

	PRIVATE.ScoreStrings = function(search, word, kWord, wordLen, kWordLen)
		if word == kWord then
			return SCORE_VALUE.MATCH, 0
		end

		local keywordType = strsub(kWord, 1, 1)

		if keywordType == KB_KEYWORD_TYPES.EXACT then
			local keyword = strsub(kWord, 2)
			if word == keyword then
				return SCORE_VALUE.MATCH, -3
			else
				return 0, -1
			end
		elseif keywordType == KB_KEYWORD_TYPES.STARTS_WITH then
			local keyword = strsub(kWord, 2)
			if strfind(word, keyword, 1, true) == 1 then
				return SCORE_VALUE.NEAR, -4
			else
				return 0, -1
			end
		elseif keywordType == KB_KEYWORD_TYPES.ENDS_WITH then
			local keyword = strsub(kWord, 2)
			if utf8sub(word, -(kWordLen or utf8len(keyword))) == keyword then
				return SCORE_VALUE.NEAR, -5
			else
				return 0, -1
			end
		elseif keywordType == KB_KEYWORD_TYPES.CONTAINS or keywordType == KB_KEYWORD_TYPES.CONTAINS_DIST then
			local keyword = strsub(kWord, 2)
			if strfind(word, keyword, 1, true) then
				return SCORE_VALUE.NEAR, -6
			elseif keywordType == KB_KEYWORD_TYPES.CONTAINS then
				return 0, -1
			end
		end

		if not wordLen then wordLen = utf8len(word) end
		if not kWordLen then kWordLen = utf8len(kWord) end

		if mathabs(wordLen - kWordLen) > search.MAX_CHAR_DIFF then
			return 0, -9
		end

		local mult

		if wordLen <= 3 or kWordLen <= 3 then
			if word == kWord then
				return SCORE_VALUE.MATCH, 0
			elseif wordLen == kWordLen
				or wordLen <= 2 or kWordLen <= 2
				or wordLen > kWordLen and not strfind(word, kWord, 1, true)
				or wordLen < kWordLen and not strfind(kWord, word, 1, true)
			then
				return 0, mathmax(wordLen, kWordLen)
			end

			mult = SCORE_VALUE.SHORT
--		elseif strfind(wordLen > kWordLen and word or kWord, wordLen > kWordLen and kWord or word, 1, true) then
--			mult = SCORE_VALUE.LONG
		end

	--	local distance = PRIVATE.GetStringDistance(word, kWord, 1, 1, 1)
		local distance = CalculateStringEditDistance(word, kWord)
		local score = ClampedPercentageBetween(distance, 5, 1)

		if not mult then
			if score >= 1 then
				mult = SCORE_VALUE.NEAR
			end
		end

		return score * (mult or 1), distance
	end

	PRIVATE.SearchCoroutine = function(search, wordArray, wordDict, wordCount, newWordDict)
		local totalEntries = PRIVATE.KEYWORDS_CACHE_LEN * wordCount
		local processedEntries = 0
		local distanceList = newWordDict and search.WORD_DISTANCE or {}
		local articleDistance = {}

		wordDict = wordDict or newWordDict

		for word, wordData in pairs(wordDict) do
			if not WORD_BLACKLIST[word] then
				local wordLen = utf8len(word)

				if wordLen >= search.MIN_CHARS then
					for keyword, data in pairs(PRIVATE.KEYWORDS_CACHE) do
						local keywordParts = data[1]
						local articles = data[2]

						local score, distance

						if type(keywordParts) == "string" then
							score, distance = PRIVATE.ScoreStrings(search, word, keyword, wordLen)
						else
							local bestKeywordIndex
							local bestKeywordScore = 0
							local bestKeywordDistance = -1

							for keywordIndex, keywordPart in ipairs(keywordParts) do
								local keywordPartLen = utf8len(keywordPart)
								if keywordPartLen > 2 then
									local keywordScore, keywordDistance = PRIVATE.ScoreStrings(search, word, keywordPart, wordLen, keywordPartLen)
									if keywordScore > bestKeywordScore then
										bestKeywordIndex = keywordIndex
										bestKeywordScore = keywordScore
										bestKeywordDistance = keywordDistance
									end
								end
							end

							local sequenceFound
							if bestKeywordIndex and bestKeywordScore > SEARCH_MIN_DISTANCE_DEBUG then
								for _, currentWordIndex in ipairs(wordData[KB_SUGGESTION_WORD_DICT_ENUM.INDEXES]) do
									local firstWordIndex = currentWordIndex - (bestKeywordIndex - 1)
									local lastWordIndex = currentWordIndex + (#keywordParts - bestKeywordIndex)

									local partKeywordScore, partKeywordDistance = 0, 99

									if firstWordIndex > 0 and lastWordIndex <= #wordArray then
										local validSequence

										for wordIndex = firstWordIndex, lastWordIndex do
											if wordIndex ~= currentWordIndex then
												local keywordIndex = bestKeywordIndex + wordIndex - currentWordIndex
												local offsettedWord = wordArray[wordIndex]
												local keywordPart = keywordParts[keywordIndex]

												local keywordScore, keywordDistance = PRIVATE.ScoreStrings(search, offsettedWord, keywordPart)

												if keywordScore < SEARCH_MIN_DISTANCE then
													validSequence = nil
													break
												else
													partKeywordScore = partKeywordScore + keywordScore
													partKeywordDistance = partKeywordDistance + keywordDistance
													validSequence = true
												end
											end
										end

										if validSequence then
											-- include skipped index
											partKeywordScore = partKeywordScore + bestKeywordScore
											bestKeywordDistance = bestKeywordDistance + partKeywordDistance

											score, distance = partKeywordScore / #keywordParts, partKeywordDistance
											sequenceFound = true
											break
										end
									end
								end

								if not sequenceFound then
									score, distance = 0, -1
								end
							else
								score, distance = 0, -1
							end
						end

						if search.DEBUG and score >= SEARCH_MIN_DISTANCE_DEBUG then
							print(word, keyword, wordLen, distance, RoundToSignificantDigits(score, 2))
						end

						if score >= SEARCH_MIN_DISTANCE then
							local count = wordData[KB_SUGGESTION_WORD_DICT_ENUM.COUNT]

							for _, article in ipairs(articles) do
								if search.REQUEST_KEYWORDS then
									local keywordPrefix = strsub(keyword, 1, 1)
									local keywordText = keyword

									if not search.DEBUG_KEYWORDS then
										for _, prefixValue in pairs(KB_KEYWORD_TYPES) do
											if prefixValue == keywordPrefix then
												keywordText = strsub(keyword, 2)
												break
											end
										end
									end

									if not articleDistance[article] then
										articleDistance[article] = {score * count, {[keywordText] = true}}
									else
										articleDistance[article][1] = articleDistance[article][1] + score * count
										articleDistance[article][2][keywordText] = true
									end
								else
									if not articleDistance[article] then
										articleDistance[article] = score * count
									else
										articleDistance[article] = articleDistance[article] + score * count
									end
								end
							end
						end

						processedEntries = processedEntries + 1

						if (debugprofilestop() - search.COROUTINE_TIMESTAMP) > search.FRAMETIME_AVAILABLE then
							if search.COROUTINE_DEBUG then print("yield", processedEntries / totalEntries, processedEntries, totalEntries) end
							coroutine.yield(processedEntries / totalEntries)
						end
					end
				end
			end
		end

		if newWordDict then
			if search.REQUEST_KEYWORDS then
				for i = #distanceList, 1, -1 do
					local wordData = articleDistance[distanceList[i][1]]
					if wordData then
						distanceList[i][2] = distanceList[i][2] + wordData[1]
						for word in pairs(wordData[2]) do
							distanceList[i][3][word] = true
						end
						articleDistance[distanceList[i][1]] = nil
					end
				end
			else
				for i = #distanceList, 1, -1 do
					local score = articleDistance[distanceList[i][1]]
					if score then
						distanceList[i][2] = distanceList[i][2] + score
						articleDistance[distanceList[i][1]] = nil
					end
				end
			end
		end

		if search.REQUEST_KEYWORDS then
			for article, wordData in pairs(articleDistance) do
				distanceList[#distanceList + 1] = {article, wordData[1], wordData[2]}
			end
		else
			for article, distance in pairs(articleDistance) do
				distanceList[#distanceList + 1] = {article, distance}
			end
		end

		tsort(distanceList, PRIVATE.SortDistance)

		search.WORD_DISTANCE = distanceList

		return -1, distanceList
	end

	PRIVATE.SendSearchAvailable = function(searchType, dbgInfo)
		local search = PRIVATE.GetSearchType(searchType)

		FireCustomClientEvent(search.EVENT_AVAILABLE)
		if search.COROUTINE_DEBUG then print(strformat("%s %s", search.EVENT_AVAILABLE, dbgInfo)) end

		if search.NEXT then
			RunNextFrame(function()
				PRIVATE.StartSearch(searchType, search.NEXT, search.REQUEST_KEYWORDS)
			end)
			FireCustomClientEvent(search.EVENT_NEXT)
		end
	end

	PRIVATE.StartSearch = function(searchType, text, requestKeywords, force, articleList, onFinishCallback)
		local search = PRIVATE.GetSearchType(searchType)

		if not text then
			search.NEXT = nil
			return false
		end

		text = strtrim(text)

		if text == "" then
			search.NEXT = nil
			return false
		end

		if search.COROUTINE then
			if force then
				PRIVATE.StartSearch(searchType)
			else
				search.NEXT = text
				return false
			end
		else
			search.NEXT = nil
		end

		if (requestKeywords and not search.REQUEST_KEYWORDS)
		or (not requestKeywords and search.REQUEST_KEYWORDS)
		then
			search.WORD_DISTANCE = nil
		end

		search.REQUEST_KEYWORDS = not not requestKeywords

		if not next(PRIVATE.KEYWORDS_CACHE) then
			local numWords = 0

			for _, article in pairs((articleList or KNOWLEDGEBASE_ARTICLES)) do
				if article.keywords ~= "" and PRIVATE.IsEntryVisible(article) then
					local keywords = {strsplit(KB_KEYWORDS_DELIMITER, article.keywords)}
					for _, keyword in ipairs(keywords) do
						if not PRIVATE.KEYWORDS_CACHE[keyword] then
							local keywordParts
							if strfind(keyword, " ", 1, true) then
								keywordParts = {strsplit(" ", keyword)}
							else
								keywordParts = keyword
							end

							PRIVATE.KEYWORDS_CACHE[keyword] = {
								[1] = keywordParts,
								[2] = {},
							}

							numWords = numWords + 1
						end

						tinsert(PRIVATE.KEYWORDS_CACHE[keyword][2], article)
					end
				end
			end

			PRIVATE.KEYWORDS_CACHE_LEN = numWords
		end

		local wordArray = {}
		local wordDict = {}
		local wordIndex = 0
		local wordCount = 0

		for word in strgmatch(text, WORD_MATCH_PATTERN) do
			wordIndex = wordIndex + 1
			word = strlower(word)
			word = strgsub(word, "ё", "е")
			wordArray[wordIndex] = word

			if not wordDict[word] then
				wordDict[word] = {
					[KB_SUGGESTION_WORD_DICT_ENUM.COUNT] = 1,
					[KB_SUGGESTION_WORD_DICT_ENUM.INDEXES] = {wordIndex},
				}

				wordCount = wordCount + 1
			else
				wordDict[word][KB_SUGGESTION_WORD_DICT_ENUM.COUNT] = wordDict[word][KB_SUGGESTION_WORD_DICT_ENUM.COUNT] + 1
				tinsert(wordDict[word][KB_SUGGESTION_WORD_DICT_ENUM.INDEXES], wordIndex)
			end
		end

		local newWordDict

		if search.WORD_DICT then
			if wordCount == search.WORD_DICT_LEN then
				if tCompare(wordDict, search.WORD_DICT) then
					FireCustomClientEvent(search.EVENT_AVAILABLE)
					PRIVATE.SearchFireFinishCallback(search, true)
					if search.COROUTINE_DEBUG then print(strformat("%s Cache", search.EVENT_AVAILABLE)) end
					return true
				end
			elseif wordCount > search.WORD_DICT_LEN then
				local wordRemoved
				for word in pairs(search.WORD_DICT) do
					if not wordDict[word] then
						wordRemoved = true
						break
					end
				end

				if not wordRemoved then
					newWordDict = {}

					for word, data in pairs(wordDict) do
						local count = data[KB_SUGGESTION_WORD_DICT_ENUM.COUNT]

						if not search.WORD_DICT[word] then
							newWordDict[word] = count
						end

						search.WORD_DICT[word] = count
					end
				end
			end
		end

		search.WORD_ARRAY = wordArray
		search.WORD_DICT = wordDict
		search.WORD_DICT_LEN = wordCount

		local framerate = GetFramerate()
		search.FRAMETIME_TARGET = framerate > 63 and (1 / 60) or (1 / 55)
		search.FRAMETIME_AVAILABLE = 1000 / framerate - search.FRAMETIME_RESERVE

		search.COROUTINE_ON_FINISH_CALLBACK = onFinishCallback
		search.COROUTINE = coroutine.create(PRIVATE.SearchCoroutine)
		search.COROUTINE_TIMESTAMP = debugprofilestop()

		local status, progress, result = coroutine.resume(search.COROUTINE, search, wordArray, wordDict, wordCount, newWordDict)
		if not status then
			search.COROUTINE_RESULT = nil
			search.COROUTINE = nil
			PRIVATE.SearchDequeue(search)
			PRIVATE.SearchFireFinishCallback(search, false)
			error(progress, 2)
			return false
		end

		if coroutine.status(search.COROUTINE) == "dead" then
			search.COROUTINE_RESULT = result
			search.COROUTINE = nil
			PRIVATE.SendSearchAvailable(SEARCH_TYPE.SUGGESTIONS, "Instant")
			PRIVATE.SearchFireFinishCallback(search, true)
		else
			FireCustomClientEvent(search.EVENT_PROGRESS, progress)
			if search.COROUTINE_DEBUG then print(search.EVENT_PROGRESS, progress) end
			PRIVATE.SearchEnqueue(search)
		end

		return true
	end

	PRIVATE.GetSearchResults = function(searchType, numResults)
		local search = PRIVATE.GetSearchType(searchType)

		if not search.COROUTINE_RESULT then
			if search.COROUTINE then
				return false, "SEARCH_IN_PROGRESS"
			else
				return false, "NO_SEARCH_REQUEST"
			end
		end

		numResults = numResults and mathmin(numResults, #search.COROUTINE_RESULT) or #search.COROUTINE_RESULT
		local results = {}
		local keywordsAvailable

		if search.REQUEST_KEYWORDS then
			for i = 1, numResults do
				results[#results + 1] = {search.COROUTINE_RESULT[i][1], PRIVATE.ToArrayKeywords(search.COROUTINE_RESULT[i][3])}
			end
			keywordsAvailable = true
		else
			for i = 1, numResults do
				results[#results + 1] = search.COROUTINE_RESULT[i][1]
			end
			keywordsAvailable = false
		end

		return true, results, keywordsAvailable
	end

	PRIVATE.AbortSearch = function(searchType)
		local search = PRIVATE.GetSearchType(searchType)
		if search.COROUTINE then
			search.COROUTINE = nil
			search.COROUTINE_RESULT = nil
			PRIVATE.SearchDequeue(search)
		end
	end
end

do -- PRIVATE.FormatArticleText
	local htmlTags = {
		{"<h1", "</h1>"},
		{"<h2", "</h2>"},
		{"<h3", "</h3>"},
		{"<p", "</p>"},
		{"<img", "/>"},
		{"<br/>"},
	}

	local getClosestMatchingTagFromPos = function(str, pos)
		if not pos then return end

		local minStartPos, minEndPos, minTag, _

		for _, tag in ipairs(htmlTags) do
			local startPos, endPos = strfind(str, tag[1], pos, true)
			if startPos and (not minStartPos or startPos < minStartPos) then
				minStartPos, minEndPos = startPos, endPos
				minTag = tag
			end
		end

		if minTag then
			if minTag[2] then
				_, minEndPos = strfind(str, minTag[2], minStartPos, true)
			end

			return minStartPos, minEndPos
		end
	end

	local formatPlainText = function(text)
		return strgsub(text, "(%s*)([^\n]+)(\n*)", "%1<p>%2</p>%3")
	end

	local formatHTMLText = function(text)
		local tags = {}

		do
			local startPos
			local endPos = 1
			while endPos do
				startPos, endPos = getClosestMatchingTagFromPos(text, endPos)
				if startPos then
					tags[#tags + 1] = {startPos, endPos}
				end
			end
		end

		local textLen = strlen(text)
		local tagsCount = #tags

		local result = {}
		result[#result + 1] = formatPlainText(strsub(text, 0, tagsCount > 0 and (tags[1][1] - 1) or textLen))

		for i = 1, tagsCount do
			local startPos = tags[i][2]
			local endPos = i ~= tagsCount and tags[i + 1][1] or (textLen + 1)

			result[#result + 1] = strsub(text, tags[i][1], tags[i][2])
			result[#result + 1] = formatPlainText(strsub(text, startPos + 1, endPos - 1))
		end

		return tconcat(result, "")
	end

	local tabWidth = 5
	local indent = strrep("|cff000000 |r", tabWidth)
	local li = [[<img src="Interface/Scenarios/ScenarioIcon-Combat" align="left"/>]] .. indent
	local hr = [[<img src="Interface/HelpFrame/CS_HelpTextures_Separator" align="center" width="600" height="8"/>]]
	local colorStart = strformat("<color=[\"'](%s)[\"']>", strrep("[0-9A-Fa-f]", 6))
	local colorEnd = "</color>"

	local specialTags = {
		spacing = "<p></p>",
		indent = indent,
	}

	local formatColor = function(hex)
		return strformat("|cff%s", hex)
	end

	local formatSpecialTag = function(tag, times)
		if times ~= "" then
			return strrep(specialTags[tag], times)
		end
		return specialTags[tag]
	end

	PRIVATE.ConvertToHTML = function(text)
		text = text:gsub("\r\n", "\n")
		text = text:gsub("\r", "\n")
		text = text:gsub("||", "|")
		text = text:gsub(colorStart, formatColor)
		text = text:gsub(colorEnd, "|r")
		text = text:gsub("<li>", li)
		text = text:gsub("<hr>", hr)
		text = text:gsub("<center>", "<p align=\"center\">")
		text = text:gsub("</center>", "</p>")
		text = text:gsub("<right>", "<p align=\"right\">")
		text = text:gsub("</right>", "</p>")
		text = text:gsub("<left>", "<p align=\"left\">")
		text = text:gsub("</left>", "</p>")
		text = text:gsub("<(spacing)=?(-?%d*)>", formatSpecialTag)
		text = formatHTMLText(text)
		text = text:gsub("<(indent)=?(-?%d*)>", formatSpecialTag)
		text = text:gsub("\n\n", "<br/>")
		return text
	end

	PRIVATE.FormatArticleText = function(text)
		return strformat("<html><body>%s<br/></body></html>", PRIVATE.ConvertToHTML(text))
	end
end

PRIVATE.Initialize()

Custom_KnowledgeBase = {}

do -- KBSystem
	---@return string motd
	function Custom_KnowledgeBase.KBSystem_GetMOTD()
		return KBSystem_GetMOTD()
	end

	---@return string? serverNotice
	function Custom_KnowledgeBase.KBSystem_GetServerNotice()
		return KBSystem_GetServerNotice()
	end

	---@return string? serverStatus
	function Custom_KnowledgeBase.KBSystem_GetServerStatus()
		return KBSystem_GetServerStatus()
	end
end

do -- KBSetup
	---@return boolean isLoaded
	function Custom_KnowledgeBase.KBSetup_IsLoaded()
		return PRIVATE.SETUP_LOADED == true
	end

	---@param articlesPerPage integer
	---@param curPage integer
	function Custom_KnowledgeBase.KBSetup_BeginLoading(articlesPerPage, curPage)
		articlesPerPage = tonumber(articlesPerPage)
		curPage = tonumber(curPage)

		twipe(PRIVATE.CURRENT_ARTICLES)
		PRIVATE.LoadArticles()

		if KB_NO_PAGES
		or (articlesPerPage and articlesPerPage > 0 and curPage and (curPage + 1) <= (mathceil(#PRIVATE.TOP_ISSUES / articlesPerPage)))
		then
			PRIVATE.ARTICLE_ID = nil
			PRIVATE.CATEGORY_INDEX = nil
			PRIVATE.SUBCATEGORY_INDEX = nil
			PRIVATE.LANGUAGE_INDEX = 1
			PRIVATE.ARTICLES_PER_PAGE = articlesPerPage
			PRIVATE.CUR_PAGE = curPage + 1
			PRIVATE.MAX_PAGE = mathceil(#PRIVATE.TOP_ISSUES / articlesPerPage)
			PRIVATE.SETUP_LOADED = true

			FireCustomClientEvent("KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS")
		else
			PRIVATE.ARTICLE_ID = nil
			PRIVATE.CATEGORY_INDEX = nil
			PRIVATE.SUBCATEGORY_INDEX = nil
			PRIVATE.LANGUAGE_INDEX = nil
			PRIVATE.ARTICLES_PER_PAGE = nil
			PRIVATE.CUR_PAGE = nil
			PRIVATE.MAX_PAGE = nil
			PRIVATE.SETUP_LOADED = nil

			FireCustomClientEvent("KNOWLEDGE_BASE_SETUP_LOAD_FAILURE")
		end
	end

	---@return integer articlesOnPage
	function Custom_KnowledgeBase.KBSetup_GetArticleHeaderCount()
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetArticleHeaderCount() failed because setup is not loaded", 2)
		end

		PRIVATE.LoadArticles()

		return #PRIVATE.TOP_ISSUES
	end

	---@return integer numArticlesInQuery
	function Custom_KnowledgeBase.KBSetup_GetTotalArticleCount()
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetTotalArticleCount() failed because setup is not loaded", 2)
		end

		PRIVATE.LoadArticles()

		if KB_NO_PAGES then
			return #PRIVATE.TOP_ISSUES
		else
			return PRIVATE.GetOnPageNum(#PRIVATE.TOP_ISSUES, PRIVATE.ARTICLES_PER_PAGE, PRIVATE.CUR_PAGE)
		end
	end

	---@param articleHeaderIndex integer
	---@return integer articleID
	---@return string articleHeader
	---@return boolean isHot
	---@return boolean isNew
	function Custom_KnowledgeBase.KBSetup_GetArticleHeaderData(articleHeaderIndex)
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetArticleHeaderData() failed because setup is not loaded", 2)
		elseif articleHeaderIndex <= 0 or articleHeaderIndex > (KB_NO_PAGES and #PRIVATE.TOP_ISSUES or Custom_KnowledgeBase.KBSetup_GetTotalArticleCount()) then
			error("Custom_KnowledgeBase.KBSetup_GetArticleHeaderData() called with invalid article header index", 2)
		end

		articleHeaderIndex = articleHeaderIndex + PRIVATE.ARTICLES_PER_PAGE * (PRIVATE.CUR_PAGE - 1)

		local article = PRIVATE.TOP_ISSUES[articleHeaderIndex]
		local articleHeader = article.articleHeader

		if not PRIVATE.IsEntryVisible(article) then
			articleHeader = strformat("%s |cffff0000(%s)|r", articleHeader, KBASE_ARTICLE_HIDDEN)
		end

		return article.articleID, articleHeader, article.isHot, article.isNew
	end

	---@return integer numCategories
	function Custom_KnowledgeBase.KBSetup_GetCategoryCount()
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryCount() failed because setup is not loaded", 2)
		end

		PRIVATE.LoadCategories()

		return #PRIVATE.CATEGORIES
	end

	---@param categoryIndex integer
	---@return integer categoryID
	---@return string caption
	function Custom_KnowledgeBase.KBSetup_GetCategoryData(categoryIndex)
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryData() failed because setup is not loaded", 2)
		elseif categoryIndex <= 0 or categoryIndex > Custom_KnowledgeBase.KBSetup_GetCategoryCount() then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryData() called with invalid category index", 2)
		end

		PRIVATE.LoadCategories()

		PRIVATE.CATEGORY_INDEX = categoryIndex
		PRIVATE.SUBCATEGORY_INDEX = nil

		local category = PRIVATE.CATEGORIES[categoryIndex]
		local caption = category.caption

		if not PRIVATE.IsEntryVisible(category) then
			caption = strformat("%s |cffff0000(%s)|r", caption, KBASE_ARTICLE_HIDDEN)
		end

		return category.categoryID, caption
	end

	---@return integer numLanguages
	function Custom_KnowledgeBase.KBSetup_GetLanguageCount()
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetLanguageCount() failed because setup is not loaded", 2)
		end

		return #KNOWLEDGEBASE_LANGUAGES
	end

	---@param languageIndex integer
	---@return integer languageID
	---@return string languageName
	function Custom_KnowledgeBase.KBSetup_GetLanguageData(languageIndex)
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryData() failed because setup is not loaded", 2)
		elseif languageIndex <= 0 or languageIndex > Custom_KnowledgeBase.KBSetup_GetLanguageCount() then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryData() called with invalid category index", 2)
		end

		PRIVATE.LANGUAGE_INDEX = languageIndex
		local language = KNOWLEDGEBASE_LANGUAGES[languageIndex]
		return language.languageID, language.languageName
	end

	---@param categoryIndex integer
	---@return integer numSubCategory
	function Custom_KnowledgeBase.KBSetup_GetSubCategoryCount(categoryIndex)
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetSubCategoryCount() failed because setup is not loaded", 2)
		end

		PRIVATE.LoadCategories()

		return PRIVATE.CATEGORIES[categoryIndex] and #PRIVATE.CATEGORIES[categoryIndex].subCategories or 0
	end

	---@param categoryIndex integer
	---@param subCategoryindex integer
	---@return integer categoryID
	---@return string caption
	function Custom_KnowledgeBase.KBSetup_GetSubCategoryData(categoryIndex, subCategoryindex)
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryData() failed because setup is not loaded", 2)
		elseif (categoryIndex <= 0 or categoryIndex > Custom_KnowledgeBase.KBSetup_GetCategoryCount())
			or (subCategoryindex <= 0 or subCategoryindex > Custom_KnowledgeBase.KBSetup_GetSubCategoryCount(categoryIndex))
		then
			error("Custom_KnowledgeBase.KBSetup_GetCategoryData() called with invalid category or sub category index", 2)
		end

		PRIVATE.LoadCategories()

		PRIVATE.CATEGORY_INDEX = categoryIndex
		PRIVATE.SUBCATEGORY_INDEX = subCategoryindex

		local subCategory = PRIVATE.CATEGORIES[categoryIndex].subCategories[subCategoryindex]
		local caption = subCategory.caption

		if not PRIVATE.IsEntryVisible(subCategory) then
			caption = strformat("%s |cffff0000(%s)|r", caption, KBASE_ARTICLE_HIDDEN)
		end

		return subCategory.categoryID, caption
	end
end

do -- KBArticle
	---@return boolean isLoaded
	function Custom_KnowledgeBase.KBArticle_IsLoaded()
		return PRIVATE.ARTICLE_LOADED == true
	end

	---@param articleID integer
	---@param searchType integer
	function Custom_KnowledgeBase.KBArticle_BeginLoading(articleID, searchType)
		PRIVATE.LoadArticles()

		if KNOWLEDGEBASE_ARTICLES[articleID] then
			PRIVATE.ARTICLE_ID = articleID
			PRIVATE.ARTICLE_SEARCH_TYPE = searchType	-- 1 | 2

			PRIVATE.ARTICLE_LOADED = true
			FireCustomClientEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS")
		else
			PRIVATE.ARTICLE_LOADED = nil
			FireCustomClientEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE")
		end
	end

	---@return integer articleID
	---@return string subject
	---@return string subjectAlt
	---@return string text
	---@return string keywords
	---@return integer languageID
	---@return boolean isHot
	function Custom_KnowledgeBase.KBArticle_GetData()
		if not Custom_KnowledgeBase.KBArticle_IsLoaded() then
			error("Custom_KnowledgeBase.KBArticle_GetData() failed because article is not loaded", 2)
		end

		PRIVATE.LoadArticles()

		local article = KNOWLEDGEBASE_ARTICLES[PRIVATE.ARTICLE_ID]
		local articleText = PRIVATE.FormatArticleText(article.text)
		local subject = article.subject and article.subject ~= "" and article.subject or article.articleHeader
		return article.articleID, subject or "", article.subjectAlt or "", articleText, article.keywords or "", article.languageID, article.isHot
	end
end

do -- KBQuery
	---@return boolean isLoaded
	function Custom_KnowledgeBase.KBQuery_IsLoaded()
		return PRIVATE.QUERY_LOADED == true
	end

	---@param searchText string
	---@param categoryIndex integer
	---@param subcategoryIndex integer
	---@param articlesPerPage integer
	---@param curPage integer
	function Custom_KnowledgeBase.KBQuery_BeginLoading(searchText, categoryIndex, subcategoryIndex, articlesPerPage, curPage)
		local errorText
		if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
			errorText = "Custom_KnowledgeBase.KBQuery_BeginLoading() failed because setup is not loaded"
		elseif type(searchText) ~= "string" then
			errorText = "Custom_KnowledgeBase.KBQuery_BeginLoading() called with a null string for search query"
		elseif utf8len(searchText) > KB_SEARCH_LIMIT then
			errorText = strformat("Custom_KnowledgeBase.KBQuery_BeginLoading() called with a string > %i bytes for search query", KB_SEARCH_LIMIT)
		elseif not tonumber(categoryIndex) and subcategoryIndex then
			errorText = "Custom_KnowledgeBase.KBQuery_BeginLoading() called with subcategory without category"
		end

		if errorText then
			FireCustomClientEvent("KNOWLEDGE_BASE_QUERY_LOAD_FAILURE")
			error(errorText, 2)
		end

		twipe(PRIVATE.CURRENT_ARTICLES)
		PRIVATE.LoadArticles()

		local allCategories = categoryIndex == 0
		local allSubCategories = subcategoryIndex == 0
		local isGM = IsGMAccount()
		local realmID = C_Service.GetRealmID()
		local articleID

		PRIVATE.QUERY_CATEGORY_INDEX = categoryIndex
		PRIVATE.QUERY_SUBCATEGORY_INDEX = subcategoryIndex
		PRIVATE.QUERY_ARTICLES_PER_PAGE = articlesPerPage or 50
		PRIVATE.QUERY_CURRENT_PAGE = curPage + 1

		do
			searchText = strtrim(searchText)

			if searchText ~= "" then
				articleID = strmatch(searchText:lower(), "^[Kk][Bb](%d+)$")
				if articleID then
					articleID = tonumber(articleID)
				end
			end
		end

		if KB_QUERY_SEACH_BY_TAGS
		and searchText ~= ""
		and not articleID
		and utf8len(searchText) > PRIVATE.GetSearchType(SEARCH_TYPE.QUERY).MIN_CHARS
		then
			local articles = {}

			for _, article in pairs(KNOWLEDGEBASE_ARTICLES) do
				if (PRIVATE.IsEntryVisible(article, realmID) or isGM)
				and (allCategories or article.categoryID == PRIVATE.CATEGORIES[categoryIndex].categoryID)
				and (allSubCategories or article.subCategoryID == PRIVATE.GetSubCategoryByIndex(categoryIndex, subcategoryIndex))
				then
					tinsert(articles, article)
				end
			end

			PRIVATE.QUERY_MAX_PAGE = 0
			PRIVATE.QUERY_LOADED = false

			PRIVATE.StartSearch(SEARCH_TYPE.QUERY, searchText, false, true, articles, function(searchType, isSuccess)
				local haveResults, results, keywordsAvailable = PRIVATE.GetSearchResults(searchType)
				if haveResults and #results > 0 then
					PRIVATE.CURRENT_ARTICLES = results

					if KB_SORT_ARTICLES then
						tsort(PRIVATE.CURRENT_ARTICLES, PRIVATE.SortArticles)
					end
				end

				PRIVATE.QUERY_MAX_PAGE = mathceil(#PRIVATE.CURRENT_ARTICLES / articlesPerPage)
				PRIVATE.QUERY_LOADED = isSuccess

				FireCustomClientEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS")
			end)
		else
			for _, article in pairs(KNOWLEDGEBASE_ARTICLES) do
				if (PRIVATE.IsEntryVisible(article, realmID) or isGM)
				and (allCategories or article.categoryID == PRIVATE.CATEGORIES[categoryIndex].categoryID)
				and (allSubCategories or article.subCategoryID == PRIVATE.GetSubCategoryByIndex(categoryIndex, subcategoryIndex))
				and (not articleID or article.articleID == articleID)
				and PRIVATE.SearchTextInArticleFields(article, searchText, true)
				then
					tinsert(PRIVATE.CURRENT_ARTICLES, article)
				end
			end

			if KB_SORT_ARTICLES then
				tsort(PRIVATE.CURRENT_ARTICLES, PRIVATE.SortArticles)
			end

			PRIVATE.QUERY_MAX_PAGE = mathceil(#PRIVATE.CURRENT_ARTICLES / articlesPerPage)
			PRIVATE.QUERY_LOADED = true

			FireCustomClientEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS")
		end
	end

	---@return integer numArticleHeadersInQuery
	function Custom_KnowledgeBase.KBQuery_GetArticleHeaderCount()
		if not Custom_KnowledgeBase.KBQuery_IsLoaded() then
			error("Custom_KnowledgeBase.KBQuery_GetArticleHeaderCount() failed because query is not loaded", 2)
		end

		return #PRIVATE.CURRENT_ARTICLES
	end

	---@return integer numArticlesInQuery
	function Custom_KnowledgeBase.KBQuery_GetTotalArticleCount()
		if not Custom_KnowledgeBase.KBQuery_IsLoaded() then
			error("Custom_KnowledgeBase.KBQuery_GetTotalArticleCount() failed because query is not loaded", 2)
		end

		if KB_NO_PAGES then
			return #PRIVATE.CURRENT_ARTICLES
		else
			return PRIVATE.GetOnPageNum(#PRIVATE.CURRENT_ARTICLES, PRIVATE.QUERY_ARTICLES_PER_PAGE, PRIVATE.QUERY_CURRENT_PAGE)
		end
	end

	---@param articleHeaderIndex integer
	---@return integer articleID
	---@return string articleHeader
	---@return boolean isHot
	---@return boolean isNew
	function Custom_KnowledgeBase.KBQuery_GetArticleHeaderData(articleHeaderIndex)
		if not Custom_KnowledgeBase.KBQuery_IsLoaded() then
			error("Custom_KnowledgeBase.KBQuery_GetArticleHeaderData() failed because query is not loaded", 2)
		elseif articleHeaderIndex <= 0 or articleHeaderIndex > (KB_NO_PAGES and #PRIVATE.CURRENT_ARTICLES or Custom_KnowledgeBase.KBQuery_GetArticleHeaderCount()) then
			error("Custom_KnowledgeBase.KBQuery_GetArticleHeaderData() called with invalid article header index", 2)
		end

		local article = PRIVATE.CURRENT_ARTICLES[articleHeaderIndex]
		local articleHeader = article.articleHeader

		if not PRIVATE.IsEntryVisible(article) then
			articleHeader = strformat("%s |cffff0000(%s)|r", articleHeader, KBASE_ARTICLE_HIDDEN)
		end

		return article.articleID, articleHeader, article.isHot, article.isNew
	end
end

do -- Suggestions
	function Custom_KnowledgeBase.AbortSuggestions()
		PRIVATE.AbortSearch(SEARCH_TYPE.SUGGESTIONS)
	end

	function Custom_KnowledgeBase.RequestSuggestions(text, requestKeywords, force)
		return PRIVATE.StartSearch(SEARCH_TYPE.SUGGESTIONS, text, requestKeywords, force)
	end

	function Custom_KnowledgeBase.GetSuggestions(numSuggestions)
		return PRIVATE.GetSearchResults(SEARCH_TYPE.SUGGESTIONS, numSuggestions)
	end
end

do -- Misc
	function Custom_KnowledgeBase.ForceLoadData()
		PRIVATE.LoadArticles()
		PRIVATE.LoadCategories()
	end

	---@param articleID integer
	---@return string? articleHeader
	function Custom_KnowledgeBase.GetArticleHeaderByID(articleID)
		local article = KNOWLEDGEBASE_ARTICLES[articleID]
		if article then
			if not PRIVATE.IsEntryVisible(article) then
				return strformat("%s |cffff0000(%s)|r", article.articleHeader, KBASE_ARTICLE_HIDDEN)
			else
				return article.articleHeader
			end
		end
	end

	---@param articleID integer
	---@return table? path
	function Custom_KnowledgeBase.GetArticlePath(articleID)
		local article = KNOWLEDGEBASE_ARTICLES[articleID]
		if article then
			if PRIVATE.IsEntryVisible(article) then
				local category = KNOWLEDGEBASE_CATEGORIES[article.categoryID]
				local subCategory = KNOWLEDGEBASE_SUB_CATEGORIES[article.subCategoryID]
				if category and PRIVATE.IsEntryVisible(category)
				and subCategory and PRIVATE.IsEntryVisible(subCategory)
				then
					local subCategoryIndex = tIndexOf(category.subCategories, subCategory)

					return {
						{
							id = category.categoryID,
							name = category.caption,
						},
						{
							id = subCategoryIndex,
							name = subCategory.caption,
							subcategory = true,
						},
					}
				end
			end
		end
	end

	function Custom_KnowledgeBase.FormatArticleText(text)
		return PRIVATE.FormatArticleText(text)
	end
end