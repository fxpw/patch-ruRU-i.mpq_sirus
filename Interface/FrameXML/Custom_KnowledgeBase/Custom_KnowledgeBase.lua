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
}

local KB_NO_PAGES = true
local KB_SEARCH_LIMIT = 128
local KB_SORT_ARTICLES = true
local KB_SORT_CATEGORIES = true

local KB_CATEGORIES = {}
local KB_CURRENT_ARTICLES = {}
local KB_TOP_ISSUES = {}

local KB_KEYWORDS_CACHE = {}
local KB_KEYWORDS_CACHE_LEN = 0
local KB_KEYWORDS_DELIMITER = ","

local EVENT_HANDLER = CreateFrame("Frame")
EVENT_HANDLER:Hide()
EVENT_HANDLER:RegisterEvent("VARIABLES_LOADED")
EVENT_HANDLER:RegisterEvent("PLAYER_LOGOUT")
EVENT_HANDLER:SetScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		if not SIRUS_KNOWLEDGE_BASE then
			SIRUS_KNOWLEDGE_BASE = {}
		elseif KNOWLEDGEBASE_VERSION then
			local lastEditTime = SIRUS_KNOWLEDGE_BASE[SIRUS_KNOWLEDGE_BASE_IDS.ROOT.LAST_EDIT_TIME]
			if not lastEditTime or lastEditTime < KNOWLEDGEBASE_VERSION then
				table.wipe(SIRUS_KNOWLEDGE_BASE)
			end
		end
		for index in pairs(KNOWLEDGE_BASE_SAVE_TEMPLATE) do
			if not SIRUS_KNOWLEDGE_BASE[index] then
				SIRUS_KNOWLEDGE_BASE[index] = {}
			end
		end
	elseif event == "PLAYER_LOGOUT" then
		if not SIRUS_KNOWLEDGE_BASE then
			return
		end
		local t, r = 0, 0
		for index in pairs(KNOWLEDGE_BASE_SAVE_TEMPLATE) do
			t = t + 1
			if not next(SIRUS_KNOWLEDGE_BASE[index]) then
				SIRUS_KNOWLEDGE_BASE[index] = nil
				r = r + 1
			end
		end
		if t == r then
			table.wipe(SIRUS_KNOWLEDGE_BASE)
		else
			for index in pairs(SIRUS_KNOWLEDGE_BASE) do
				if not SIRUS_KNOWLEDGE_BASE_IDS.ROOT[index] then
					SIRUS_KNOWLEDGE_BASE[index] = nil
				end
			end
		end
	end
end)

Custom_KnowledgeBase = {}

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



local function upgradeEntry(entry, dataTypeIndex)
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

local function isEntryVisible(entry, realmID)
	if entry.visibility then
		if entry.visibility == KNOWLEDGE_BASE_VISIBILITY_FLAGS.ALL then
			return true
		elseif entry.visibility == KNOWLEDGE_BASE_VISIBILITY_FLAGS.NONE then
			return false
		else
			realmID = realmID or C_Service:GetRealmID()

			if KNOWLEDGE_BASE_VISIBILITY_FLAGS[realmID] then
				return bit.band(entry.visibility, KNOWLEDGE_BASE_VISIBILITY_FLAGS[realmID]) ~= 0
			else
				return false
			end
		end
	else
		GMError("No visibility flag for entry")
	end
end

local function getOnPageNum(numItems, perPage, currentPage)
	local numOnPage = numItems - (currentPage - 1) * perPage
	return numOnPage > perPage and perPage or numOnPage
end

local function sortArticles(a, b)
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

local function sortCategories(a, b)
	if a.priority ~= b.priority then
		return a.priority > b.priority
	end

	return a.caption < b.caption
end

local articlesLoaded, articleDefaultLoaded
local function loadArticles()
	if articlesLoaded and not Custom_KnowledgeBase.articlesChanged then return end

	if not articleDefaultLoaded then
		for id, entry in pairs(KNOWLEDGEBASE_ARTICLES) do
			for key, defaultValue in pairs(SIRUS_KNOWLEDGE_BASE_DEFAULTS.ARTICLE) do
				if entry[key] == nil then
					entry[key] = defaultValue
				end
			end
			if not entry.articleID then
				entry.articleID = id
			end
			upgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE)
		end

		articleDefaultLoaded = true
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
					upgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE)
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
		table.wipe(KB_TOP_ISSUES)
		local isGM = IsGMAccount()
		local realmID = C_Service:GetRealmID()

		for articleID, article in pairs(KNOWLEDGEBASE_ARTICLES) do
			if article.isTopIssue and (isEntryVisible(article, realmID) or isGM) then
				table.insert(KB_TOP_ISSUES, article)
			end
		end

		if KB_SORT_ARTICLES then
			table.sort(KB_TOP_ISSUES, sortArticles)
		end
	end

	table.wipe(KB_KEYWORDS_CACHE)
	KB_KEYWORDS_CACHE_LEN = 0

	articlesLoaded = true
	Custom_KnowledgeBase.articlesChanged = nil
end

local categoriesLoaded, categoryDefaultLoaded
local function loadCategories()
	if categoriesLoaded and not Custom_KnowledgeBase.categoriesChanged then return end

	local isGM = IsGMAccount()
	local realmID = C_Service:GetRealmID()

	if not categoryDefaultLoaded then
		for id, entry in pairs(KNOWLEDGEBASE_CATEGORIES) do
			for key, defaultValue in pairs(SIRUS_KNOWLEDGE_BASE_DEFAULTS.CATEGORY) do
				if entry[key] == nil then
					entry[key] = defaultValue
				end
			end
			if not entry.categoryID then
				entry.categoryID = id
			end
			upgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY)
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
			upgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY)
		end

		categoryDefaultLoaded = true
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
					upgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY)
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
					upgradeEntry(entry, SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY)
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
		table.wipe(KB_CATEGORIES)

		-- Wipe old subCategories
		for categoryID, category in pairs(KNOWLEDGEBASE_CATEGORIES) do
			if category.parentID == -1 and (isEntryVisible(category, realmID) or isGM) then
				table.insert(KB_CATEGORIES, category)

				if not category.subCategories then
					category.subCategories = {}
				else
					table.wipe(category.subCategories)
				end
			end
		end

		-- Add subCategories
		for categoryID, category in pairs(KNOWLEDGEBASE_SUB_CATEGORIES) do
			if category.parentID ~= -1 and (isEntryVisible(category, realmID) or isGM) then
				table.insert(KNOWLEDGEBASE_CATEGORIES[category.parentID].subCategories, category)
			end
		end

		-- Sort subCategories
		if KB_SORT_CATEGORIES then
			table.sort(KB_CATEGORIES, sortCategories)

			for categoryID, category in pairs(KB_CATEGORIES) do
				if category.parentID == -1 then
					table.sort(category.subCategories, sortCategories)
				end
			end
		end
	end

	categoriesLoaded = true
	Custom_KnowledgeBase.categoriesChanged = nil
end

function Custom_KnowledgeBase.ForceLoadData()
	loadArticles()
	loadCategories()
end

---@return boolean isLoaded
function Custom_KnowledgeBase.KBSetup_IsLoaded()
	return Custom_KnowledgeBase.setupLoaded == true
end

---@param articlesPerPage integer
---@param curPage integer
function Custom_KnowledgeBase.KBSetup_BeginLoading(articlesPerPage, curPage)
	articlesPerPage = tonumber(articlesPerPage)
	curPage = tonumber(curPage)

	table.wipe(KB_CURRENT_ARTICLES)
	loadArticles()

	if KB_NO_PAGES
	or (articlesPerPage and articlesPerPage > 0 and curPage and (curPage + 1) <= (math.ceil(#KB_TOP_ISSUES / articlesPerPage)))
	then
		Custom_KnowledgeBase.articleID = nil
		Custom_KnowledgeBase.categoryIndex = nil
		Custom_KnowledgeBase.subCategoryIndex = nil
		Custom_KnowledgeBase.languageIndex = 1
		Custom_KnowledgeBase.articlesPerPage = articlesPerPage
		Custom_KnowledgeBase.curPage = curPage + 1
		Custom_KnowledgeBase.maxPage = math.ceil(#KB_TOP_ISSUES / articlesPerPage)
		Custom_KnowledgeBase.setupLoaded = true

		FireCustomClientEvent("KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS")
	else
		Custom_KnowledgeBase.articleID = nil
		Custom_KnowledgeBase.categoryIndex = nil
		Custom_KnowledgeBase.subCategoryIndex = nil
		Custom_KnowledgeBase.languageIndex = nil
		Custom_KnowledgeBase.articlesPerPage = nil
		Custom_KnowledgeBase.curPage = nil
		Custom_KnowledgeBase.maxPage = nil
		Custom_KnowledgeBase.setupLoaded = nil

		FireCustomClientEvent("KNOWLEDGE_BASE_SETUP_LOAD_FAILURE")
	end
end

---@return integer articlesOnPage
function Custom_KnowledgeBase.KBSetup_GetArticleHeaderCount()
	if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
		error("Custom_KnowledgeBase.KBSetup_GetArticleHeaderCount() failed because setup is not loaded", 2)
	end

	loadArticles()

	return #KB_TOP_ISSUES
end

---@return integer numArticlesInQuery
function Custom_KnowledgeBase.KBSetup_GetTotalArticleCount()
	if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
		error("Custom_KnowledgeBase.KBSetup_GetTotalArticleCount() failed because setup is not loaded", 2)
	end

	loadArticles()

	if KB_NO_PAGES then
		return #KB_TOP_ISSUES
	else
		return getOnPageNum(#KB_TOP_ISSUES, Custom_KnowledgeBase.articlesPerPage, Custom_KnowledgeBase.curPage)
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
	elseif articleHeaderIndex <= 0 or articleHeaderIndex > (KB_NO_PAGES and #KB_TOP_ISSUES or Custom_KnowledgeBase.KBSetup_GetTotalArticleCount()) then
		error("Custom_KnowledgeBase.KBSetup_GetArticleHeaderData() called with invalid article header index", 2)
	end

	articleHeaderIndex = articleHeaderIndex + Custom_KnowledgeBase.articlesPerPage * (Custom_KnowledgeBase.curPage - 1)

	local article = KB_TOP_ISSUES[articleHeaderIndex]
	local articleHeader = article.articleHeader

	if not isEntryVisible(article) then
		articleHeader = string.format("%s |cffff0000(%s)|r", articleHeader, KBASE_ARTICLE_HIDDEN)
	end

	return article.articleID, articleHeader, article.isHot, article.isNew
end

---@return integer numCategories
function Custom_KnowledgeBase.KBSetup_GetCategoryCount()
	if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
		error("Custom_KnowledgeBase.KBSetup_GetCategoryCount() failed because setup is not loaded", 2)
	end

	loadCategories()

	return #KB_CATEGORIES
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

	loadCategories()

	Custom_KnowledgeBase.categoryIndex = categoryIndex
	Custom_KnowledgeBase.subCategoryIndex = nil

	local category = KB_CATEGORIES[categoryIndex]
	local caption = category.caption

	if not isEntryVisible(category) then
		caption = string.format("%s |cffff0000(%s)|r", caption, KBASE_ARTICLE_HIDDEN)
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

	Custom_KnowledgeBase.languageIndex = languageIndex
	local language = KNOWLEDGEBASE_LANGUAGES[languageIndex]
	return language.languageID, language.languageName
end

---@param categoryIndex integer
---@return integer numSubCategory
function Custom_KnowledgeBase.KBSetup_GetSubCategoryCount(categoryIndex)
	if not Custom_KnowledgeBase.KBSetup_IsLoaded() then
		error("Custom_KnowledgeBase.KBSetup_GetSubCategoryCount() failed because setup is not loaded", 2)
	end

	loadCategories()

	return KB_CATEGORIES[categoryIndex] and #KB_CATEGORIES[categoryIndex].subCategories or 0
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

	loadCategories()

	Custom_KnowledgeBase.categoryID = categoryIndex
	Custom_KnowledgeBase.subCategoryIndex = subCategoryindex

	local subCategory = KB_CATEGORIES[categoryIndex].subCategories[subCategoryindex]
	local caption = subCategory.caption

	if not isEntryVisible(subCategory) then
		caption = string.format("%s |cffff0000(%s)|r", caption, KBASE_ARTICLE_HIDDEN)
	end

	return subCategory.categoryID, caption
end



---@return boolean isLoaded
function Custom_KnowledgeBase.KBArticle_IsLoaded()
	return Custom_KnowledgeBase.articleLoaded == true
end

---@param articleID integer
---@param searchType integer
function Custom_KnowledgeBase.KBArticle_BeginLoading(articleID, searchType)
	loadArticles()

	if KNOWLEDGEBASE_ARTICLES[articleID] then
		Custom_KnowledgeBase.articleID = articleID
		Custom_KnowledgeBase.articleSearchType = searchType	-- 1 | 2

		Custom_KnowledgeBase.articleLoaded = true
		FireCustomClientEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS")
	else
		Custom_KnowledgeBase.articleLoaded = nil
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

	loadArticles()

	local article = KNOWLEDGEBASE_ARTICLES[Custom_KnowledgeBase.articleID]
	local articleText = Custom_KnowledgeBase.FormatArticleText(article.text)
	local subject = article.subject and article.subject ~= "" and article.subject or article.articleHeader
	return article.articleID, subject or "", article.subjectAlt or "", articleText, article.keywords or "", article.languageID, article.isHot
end



---@return boolean isLoaded
function Custom_KnowledgeBase.KBQuery_IsLoaded()
	return Custom_KnowledgeBase.queryLoaded == true
end

local SEARCH_BLACKLIST = {
	["h1"] = true,
	["h2"] = true,
	["h3"] = true,
	["img"] = true,
	["br"] = true,
	["li"] = true,
	["hr"] = true,
	["center"] = true,
	["right"] = true,
	["left"] = true,
	["spacing"] = true,
	["indent"] = true,
	["color"] = true,
	["align"] = true,
}

local function searchTextInArticle(article, text, split)
	if text == "" then
		return true
	end

	text = string.trim(text)

	if strlenutf8(text) < 2 then
		return false
	end

	text = text:lower()

	local articleID = string.match(text, "^kb(%d+)$")
	if articleID then
		return article.articleID == tonumber(articleID)
	end

	text = text:gsub("%p+", " ")
	text = text:gsub("%s+", " ")

	if not split then
		if string.find(article.articleHeader:lower(), text, 1, true)
		or (article.subject ~= "" and string.find(article.subject:lower(), text, 1, true))
		or (article.subjectAlt ~= "" and string.find(article.subjectAlt:lower(), text, 1, true))
		or string.find(article.keywords, text, 1, true)
		or string.find(article.text:lower(), text, 1, true)
		then
			return true
		end
	else
		text = string.trim(text)

		for _, word in ipairs({string.split(" ", text)}) do
			if not SEARCH_BLACKLIST[word] then
				if string.find(article.articleHeader:lower(), word, 1, true)
				or (article.subject ~= "" and string.find(article.subject:lower(), word, 1, true))
				or (article.subjectAlt ~= "" and string.find(article.subjectAlt:lower(), word, 1, true))
				or string.find(article.keywords, word, 1, true)
				or string.find(article.text:lower(), word, 1, true)
				then
					return true
				end
			end
		end
	end
end

local function getSubCategoryByIndex(categoryIndex, subCategoryIndex)
	return KB_CATEGORIES[categoryIndex].subCategories[subCategoryIndex].categoryID
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
	elseif strlenutf8(searchText) > KB_SEARCH_LIMIT then
		errorText = string.format("Custom_KnowledgeBase.KBQuery_BeginLoading() called with a string > %i bytes for search query", KB_SEARCH_LIMIT)
	elseif not tonumber(categoryIndex) and subcategoryIndex then
		errorText = "Custom_KnowledgeBase.KBQuery_BeginLoading() called with subcategory without category"
	end

	if errorText then
		FireCustomClientEvent("KNOWLEDGE_BASE_QUERY_LOAD_FAILURE")
		error(errorText, 2)
	end

	table.wipe(KB_CURRENT_ARTICLES)
	loadArticles()

	local allCategories = categoryIndex == 0
	local allSubCategories = subcategoryIndex == 0
	local isGM = IsGMAccount()
	local realmID = C_Service:GetRealmID()

	for _, article in pairs(KNOWLEDGEBASE_ARTICLES) do
		if (isEntryVisible(article, realmID) or isGM)
		and (allCategories or article.categoryID == KB_CATEGORIES[categoryIndex].categoryID)
		and (allSubCategories or article.subCategoryID == getSubCategoryByIndex(categoryIndex, subcategoryIndex))
		and searchTextInArticle(article, searchText, true)
		then
			table.insert(KB_CURRENT_ARTICLES, article)
		end
	end

	if KB_SORT_ARTICLES then
		table.sort(KB_CURRENT_ARTICLES, sortArticles)
	end

	Custom_KnowledgeBase.queryCategoryID = categoryIndex
	Custom_KnowledgeBase.querySubCategoryIndex = subcategoryIndex
	Custom_KnowledgeBase.queryArticlesPerPage = articlesPerPage
	Custom_KnowledgeBase.queryCurPage = curPage + 1
	Custom_KnowledgeBase.queryMaxPage = math.ceil(#KB_CURRENT_ARTICLES / articlesPerPage)
	Custom_KnowledgeBase.queryLoaded = true

	FireCustomClientEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS")
end

---@return integer numArticleHeadersInQuery
function Custom_KnowledgeBase.KBQuery_GetArticleHeaderCount()
	if not Custom_KnowledgeBase.KBQuery_IsLoaded() then
		error("Custom_KnowledgeBase.KBQuery_GetArticleHeaderCount() failed because query is not loaded", 2)
	end

	return #KB_CURRENT_ARTICLES
end

---@return integer numArticlesInQuery
function Custom_KnowledgeBase.KBQuery_GetTotalArticleCount()
	if not Custom_KnowledgeBase.KBQuery_IsLoaded() then
		error("Custom_KnowledgeBase.KBQuery_GetTotalArticleCount() failed because query is not loaded", 2)
	end

	if KB_NO_PAGES then
		return #KB_CURRENT_ARTICLES
	else
		return getOnPageNum(#KB_CURRENT_ARTICLES, Custom_KnowledgeBase.queryArticlesPerPage, Custom_KnowledgeBase.queryCurPage)
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
	elseif articleHeaderIndex <= 0 or articleHeaderIndex > (KB_NO_PAGES and #KB_CURRENT_ARTICLES or Custom_KnowledgeBase.KBQuery_GetArticleHeaderCount()) then
		error("Custom_KnowledgeBase.KBQuery_GetArticleHeaderData() called with invalid article header index", 2)
	end

	local article = KB_CURRENT_ARTICLES[articleHeaderIndex]
	local articleHeader = article.articleHeader

	if not isEntryVisible(article) then
		articleHeader = string.format("%s |cffff0000(%s)|r", articleHeader, KBASE_ARTICLE_HIDDEN)
	end

	return article.articleID, articleHeader, article.isHot, article.isNew
end

---@param articleID integer
---@return string? articleHeader
function Custom_KnowledgeBase.GetArticleHeaderByID(articleID)
	local article = KNOWLEDGEBASE_ARTICLES[articleID]
	if article then
		if not isEntryVisible(article) then
			return string.format("%s |cffff0000(%s)|r", article.articleHeader, KBASE_ARTICLE_HIDDEN)
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
		if isEntryVisible(article) then
			local category = KNOWLEDGEBASE_CATEGORIES[article.categoryID]
			local subCategory = KNOWLEDGEBASE_SUB_CATEGORIES[article.subCategoryID]
			if category and isEntryVisible(category)
			and subCategory and isEntryVisible(subCategory)
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



local string_distance
do
	local max, min = math.max, math.min
	local utf8byte, utf8len = utf8byte, strlenutf8

	local aLen, bLen

	string_distance = function(a, b, deleteCosts, insertCosts, substituteCosts)
		aLen = utf8len(a)
		bLen = utf8len(b)

		if not deleteCosts then deleteCosts = 1 end
		if not insertCosts then insertCosts = 1 end
		if not substituteCosts then substituteCosts = 1 end

		if aLen == 0 or bLen == 0 then
			return max(aLen, bLen)
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
					matrix[i][j] = min(
						matrix[i - 1][j] + deleteCosts,			-- deletion
						matrix[i][j - 1] + insertCosts,			-- insertion
						matrix[i - 1][j - 1] + substituteCosts	-- substitution
					)
				end
			end
		end

		return matrix[bLen][aLen]
	end
end

local KB_SUGGESTIONS = {
	DEBUG = false,
	DEBUG_KEYWORDS = false,

	MIN_CHARS = 2,
	MAX_CHAR_DIFF = 8,

	DISTANCE_CACHE = {},

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

if IsInterfaceDevClient(true) then
	_G.KB_SUGGESTIONS = KB_SUGGESTIONS
end

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

local searchCoroutine
do
	local debugprofilestop = debugprofilestop
	local strlenutf8 = strlenutf8
	local pairs = pairs
	local ipairs = ipairs
	local max = math.max
	local strfind = string.find
	local tsort = table.sort
	local utf8sub = utf8sub

	local ClampedPercentageBetween = ClampedPercentageBetween

	local sortDistance = function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		elseif a[1].priority ~= b[1].priority then
			return a[1].priority > b[1].priority
		elseif a[1].articleHeader ~= b[1].articleHeader then
			return a[1].articleHeader > b[1].articleHeader
		end

		return a[1].articleID > b[1].articleID
	end

	local getStringDistance = function(a, b, deleteCosts, insertCosts, substituteCosts)
		if a == b then
			return 0
		end

		if KB_SUGGESTIONS.DISTANCE_CACHE[a]
		and KB_SUGGESTIONS.DISTANCE_CACHE[a][b]
		then
			return KB_SUGGESTIONS.DISTANCE_CACHE[a][b]
		end

		local distance = string_distance(a, b, deleteCosts, insertCosts, substituteCosts)
		KB_SUGGESTIONS.DISTANCE_CACHE[a] = KB_SUGGESTIONS.DISTANCE_CACHE[a] or {}
		KB_SUGGESTIONS.DISTANCE_CACHE[a][b] = distance

		return distance
	end

	local SCORE_VALUE = {
		MATCH = 3,
		NEAR = 2,
		LONG = 1.5,
		SHORT = 0.5,
	}

	local scoreStrings = function(word, kWord, wordLen, kWordLen)
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
			if utf8sub(word, -(kWordLen or strlenutf8(keyword))) == keyword then
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

		if not wordLen then wordLen = strlenutf8(word) end
		if not kWordLen then kWordLen = strlenutf8(kWord) end

		if abs(wordLen - kWordLen) > KB_SUGGESTIONS.MAX_CHAR_DIFF then
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
				return 0, max(wordLen, kWordLen)
			end

			mult = SCORE_VALUE.SHORT
--		elseif strfind(wordLen > kWordLen and word or kWord, wordLen > kWordLen and kWord or word, 1, true) then
--			mult = SCORE_VALUE.LONG
		end

		local distance = getStringDistance(word, kWord, 1, 1, 1)
		local score = ClampedPercentageBetween(distance, 5, 1)

		if not mult then
			if score >= 1 then
				mult = SCORE_VALUE.NEAR
			end
		end

		return score * (mult or 1), distance
	end

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
	}

	local SEARCH_MIN_DISTANCE = 0.8
	local SEARCH_MIN_DISTANCE_DEBUG = 0.6

	searchCoroutine = function(wordArray, wordDict, wordCount, newWordDict)
		local totalEntries = KB_KEYWORDS_CACHE_LEN * wordCount
		local processedEntries = 0
		local distanceList = newWordDict and KB_SUGGESTIONS.WORD_DISTANCE or {}
		local articleDistance = {}

		wordDict = wordDict or newWordDict

		for word, wordData in pairs(wordDict) do
			if not WORD_BLACKLIST[word] then
				local wordLen = strlenutf8(word)

				if wordLen >= KB_SUGGESTIONS.MIN_CHARS then
					for keyword, data in pairs(KB_KEYWORDS_CACHE) do
						local keywordParts = data[1]
						local articles = data[2]

						local score, distance

						if type(keywordParts) == "string" then
							score, distance = scoreStrings(word, keyword, wordLen)
						else
							local bestKeywordIndex
							local bestKeywordScore = 0
							local bestKeywordDistance = -1

							for keywordIndex, keywordPart in ipairs(keywordParts) do
								local keywordPartLen = strlenutf8(keywordPart)
								if keywordPartLen > 2 then
									local keywordScore, keywordDistance = scoreStrings(word, keywordPart, wordLen, keywordPartLen)
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

												local keywordScore, keywordDistance = scoreStrings(offsettedWord, keywordPart)

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

						if KB_SUGGESTIONS.DEBUG and score >= SEARCH_MIN_DISTANCE_DEBUG then
							print(word, keyword, wordLen, distance, RoundToSignificantDigits(score, 2))
						end

						if score >= SEARCH_MIN_DISTANCE then
							local count = wordData[KB_SUGGESTION_WORD_DICT_ENUM.COUNT]

							for _, article in ipairs(articles) do
								if KB_SUGGESTIONS.REQUEST_KEYWORDS then
									local keywordPrefix = strsub(keyword, 1, 1)
									local keywordText = keyword

									if not KB_SUGGESTIONS.DEBUG_KEYWORDS then
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

						if (debugprofilestop() - KB_SUGGESTIONS.COROUTINE_TIMESTAMP) > KB_SUGGESTIONS.FRAMETIME_AVAILABLE then
							if KB_SUGGESTIONS.COROUTINE_DEBUG then print("yield", processedEntries / totalEntries, processedEntries, totalEntries) end
							coroutine.yield(processedEntries / totalEntries)
						end
					end
				end
			end
		end

		if newWordDict then
			if KB_SUGGESTIONS.REQUEST_KEYWORDS then
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

		if KB_SUGGESTIONS.REQUEST_KEYWORDS then
			for article, wordData in pairs(articleDistance) do
				distanceList[#distanceList + 1] = {article, wordData[1], wordData[2]}
			end
		else
			for article, distance in pairs(articleDistance) do
				distanceList[#distanceList + 1] = {article, distance}
			end
		end

		tsort(distanceList, sortDistance)

		KB_SUGGESTIONS.WORD_DISTANCE = distanceList

		return -1, distanceList
	end
end

local sendSuggestionsAvailable = function(dbgInfo)
	FireCustomClientEvent("KNOWLEDGE_BASE_SUGGESTIONS_AVAILABLE")
	if KB_SUGGESTIONS.COROUTINE_DEBUG then print(string.format("KNOWLEDGE_BASE_SUGGESTIONS_AVAILABLE %s", dbgInfo)) end

	if KB_SUGGESTIONS.NEXT then
		RunNextFrame(function()
			Custom_KnowledgeBase.RequestSuggestions(KB_SUGGESTIONS.NEXT, KB_SUGGESTIONS.REQUEST_KEYWORDS)
		end)
		FireCustomClientEvent("KNOWLEDGE_BASE_SUGGESTIONS_NEXT")
	end
end

EVENT_HANDLER:SetScript("OnUpdate", function(self, elapsed)
	local frametimeStep = KB_SUGGESTIONS.FRAMETIME_TARGET - elapsed

	if frametimeStep ~= 0 then
		frametimeStep = frametimeStep * 1000
		KB_SUGGESTIONS.FRAMETIME_AVAILABLE = math.max(5, KB_SUGGESTIONS.FRAMETIME_AVAILABLE + frametimeStep)
	end

	if KB_SUGGESTIONS.COROUTINE then
		KB_SUGGESTIONS.COROUTINE_TIMESTAMP = debugprofilestop()
		local status, progress, result = coroutine.resume(KB_SUGGESTIONS.COROUTINE)

		if not status then
			KB_SUGGESTIONS.COROUTINE_RESULT = nil
			KB_SUGGESTIONS.COROUTINE = nil
			self:Hide()
			error(progress, 2)
		elseif progress ~= -1 then
			FireCustomClientEvent("KNOWLEDGE_BASE_SUGGESTIONS_PROGRESS", progress)
			if KB_SUGGESTIONS.COROUTINE_DEBUG then print("KNOWLEDGE_BASE_SUGGESTIONS_PROGRESS", progress) end
		else
			KB_SUGGESTIONS.COROUTINE_RESULT = result
			KB_SUGGESTIONS.COROUTINE = nil
			self:Hide()
			sendSuggestionsAvailable("Delayed")
		end
	else
		self:Hide()
	end
end)

function Custom_KnowledgeBase.AbortSuggestions()
	if KB_SUGGESTIONS.COROUTINE then
		KB_SUGGESTIONS.COROUTINE = nil
		KB_SUGGESTIONS.COROUTINE_RESULT = nil
		EVENT_HANDLER:Hide()
	end
end

local WORD_MATCH_PATTERN
do
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

	WORD_MATCH_PATTERN = string.format("([^%%s%%p][^%%s%%p][^%%s%s]+)", table.concat(punctuationChars, ""))
end

local GetFramerate = GetFramerate
function Custom_KnowledgeBase.RequestSuggestions(text, requestKeywords, force)
	if not text then
		KB_SUGGESTIONS.NEXT = nil
		return false
	end

	text = string.trim(text)

	if text == "" then
		KB_SUGGESTIONS.NEXT = nil
		return false
	end

	if KB_SUGGESTIONS.COROUTINE then
		if force then
			Custom_KnowledgeBase.AbortSuggestions()
		else
			KB_SUGGESTIONS.NEXT = text
			return false
		end
	else
		KB_SUGGESTIONS.NEXT = nil
	end

	if (requestKeywords and not KB_SUGGESTIONS.REQUEST_KEYWORDS)
	or (not requestKeywords and KB_SUGGESTIONS.REQUEST_KEYWORDS)
	then
		KB_SUGGESTIONS.WORD_DISTANCE = nil
	end

	KB_SUGGESTIONS.REQUEST_KEYWORDS = not not requestKeywords

	if not next(KB_KEYWORDS_CACHE) then
		local numWords = 0

		for _, article in pairs(KNOWLEDGEBASE_ARTICLES) do
			if article.keywords ~= "" and isEntryVisible(article) then
				local keywords = {string.split(KB_KEYWORDS_DELIMITER, article.keywords)}
				for _, keyword in ipairs(keywords) do
					if not KB_KEYWORDS_CACHE[keyword] then
						local keywordParts
						if string.find(keyword, " ", 1, true) then
							keywordParts = {string.split(" ", keyword)}
						else
							keywordParts = keyword
						end

						KB_KEYWORDS_CACHE[keyword] = {
							[1] = keywordParts,
							[2] = {},
						}

						numWords = numWords + 1
					end

					table.insert(KB_KEYWORDS_CACHE[keyword][2], article)
				end
			end
		end

		KB_KEYWORDS_CACHE_LEN = numWords
	end

	local wordArray = {}
	local wordDict = {}
	local wordIndex = 0
	local wordCount = 0

	for word in string.gmatch(text, WORD_MATCH_PATTERN) do
		wordIndex = wordIndex + 1
		word = string.lower(word)
		word = string.gsub(word, "ё", "е")
		wordArray[wordIndex] = word

		if not wordDict[word] then
			wordDict[word] = {
				[KB_SUGGESTION_WORD_DICT_ENUM.COUNT] = 1,
				[KB_SUGGESTION_WORD_DICT_ENUM.INDEXES] = {wordIndex},
			}

			wordCount = wordCount + 1
		else
			wordDict[word][KB_SUGGESTION_WORD_DICT_ENUM.COUNT] = wordDict[word][KB_SUGGESTION_WORD_DICT_ENUM.COUNT] + 1
			table.insert(wordDict[word][KB_SUGGESTION_WORD_DICT_ENUM.INDEXES], wordIndex)
		end
	end

	local newWordDict

	if KB_SUGGESTIONS.WORD_DICT then
		if wordCount == KB_SUGGESTIONS.WORD_DICT_LEN then
			if tCompare(wordDict, KB_SUGGESTIONS.WORD_DICT) then
				FireCustomClientEvent("KNOWLEDGE_BASE_SUGGESTIONS_AVAILABLE")
				if KB_SUGGESTIONS.COROUTINE_DEBUG then print("KNOWLEDGE_BASE_SUGGESTIONS_AVAILABLE Cache") end
				return true
			end
		elseif wordCount > KB_SUGGESTIONS.WORD_DICT_LEN then
			local wordRemoved
			for word in pairs(KB_SUGGESTIONS.WORD_DICT) do
				if not wordDict[word] then
					wordRemoved = true
					break
				end
			end

			if not wordRemoved then
				newWordDict = {}

				for word, data in pairs(wordDict) do
					local count = data[KB_SUGGESTION_WORD_DICT_ENUM.COUNT]

					if not KB_SUGGESTIONS.WORD_DICT[word] then
						newWordDict[word] = count
					end

					KB_SUGGESTIONS.WORD_DICT[word] = count
				end
			end
		end
	end

	KB_SUGGESTIONS.WORD_ARRAY = wordArray
	KB_SUGGESTIONS.WORD_DICT = wordDict
	KB_SUGGESTIONS.WORD_DICT_LEN = wordCount

	local framerate = GetFramerate()
	KB_SUGGESTIONS.FRAMETIME_TARGET = framerate > 63 and (1 / 60) or (1 / 55)
	KB_SUGGESTIONS.FRAMETIME_AVAILABLE = 1000 / framerate - KB_SUGGESTIONS.FRAMETIME_RESERVE

	KB_SUGGESTIONS.COROUTINE = coroutine.create(searchCoroutine)
	KB_SUGGESTIONS.COROUTINE_TIMESTAMP = debugprofilestop()

	local status, progress, result = coroutine.resume(KB_SUGGESTIONS.COROUTINE, wordArray, wordDict, wordCount, newWordDict)
	if not status then
		KB_SUGGESTIONS.COROUTINE_RESULT = nil
		KB_SUGGESTIONS.COROUTINE = nil
		EVENT_HANDLER:Hide()
		error(progress, 2)
	end

	if coroutine.status(KB_SUGGESTIONS.COROUTINE) == "dead" then
		KB_SUGGESTIONS.COROUTINE_RESULT = result
		KB_SUGGESTIONS.COROUTINE = nil
		sendSuggestionsAvailable("Instant")
	else
		FireCustomClientEvent("KNOWLEDGE_BASE_SUGGESTIONS_PROGRESS", progress)
		if KB_SUGGESTIONS.COROUTINE_DEBUG then print("KNOWLEDGE_BASE_SUGGESTIONS_PROGRESS", progress) end
		EVENT_HANDLER:Show()
	end

	return true
end

local toArrayKeywords = function(t)
	local newT = {}
	local index = 1
	for keyword in pairs(t) do
		newT[index] = keyword
		index = index + 1
	end
	table.sort(newT)
	return newT
end

function Custom_KnowledgeBase.GetSuggestions(numSuggestions)
	if not KB_SUGGESTIONS.COROUTINE_RESULT then
		if KB_SUGGESTIONS.COROUTINE then
			return false, "SEARCH_IN_PROGRESS"
		else
			return false, "NO_SEARCH_REQUEST"
		end
	end

	numSuggestions = numSuggestions and math.min(numSuggestions, #KB_SUGGESTIONS.COROUTINE_RESULT) or #KB_SUGGESTIONS.COROUTINE_RESULT
	local suggestions = {}
	local keywordsAvailable

	if KB_SUGGESTIONS.REQUEST_KEYWORDS then
		for i = 1, numSuggestions do
			suggestions[#suggestions + 1] = {KB_SUGGESTIONS.COROUTINE_RESULT[i][1], toArrayKeywords(KB_SUGGESTIONS.COROUTINE_RESULT[i][3])}
		end
		keywordsAvailable = true
	else
		for i = 1, numSuggestions do
			suggestions[#suggestions + 1] = KB_SUGGESTIONS.COROUTINE_RESULT[i][1]
		end
		keywordsAvailable = false
	end

	return true, suggestions, keywordsAvailable
end



local convertToHTML
do
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
			local startPos, endPos = string.find(str, tag[1], pos, true)
			if startPos and (not minStartPos or startPos < minStartPos) then
				minStartPos, minEndPos = startPos, endPos
				minTag = tag
			end
		end

		if minTag then
			if minTag[2] then
				_, minEndPos = string.find(str, minTag[2], minStartPos, true)
			end

			return minStartPos, minEndPos
		end
	end

	local formatPlainText = function(text)
		return string.gsub(text, "(%s*)([^\n]+)(\n*)", "%1<p>%2</p>%3")
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

		local textLen = string.len(text)
		local tagsCount = #tags

		local result = {}
		result[#result + 1] = formatPlainText(string.sub(text, 0, tagsCount > 0 and (tags[1][1] - 1) or textLen))

		for i = 1, tagsCount do
			local startPos = tags[i][2]
			local endPos = i ~= tagsCount and tags[i + 1][1] or (textLen + 1)

			result[#result + 1] = string.sub(text, tags[i][1], tags[i][2])
			result[#result + 1] = formatPlainText(string.sub(text, startPos + 1, endPos - 1))
		end

		return table.concat(result, "")
	end

	local tabWidth = 5
	local indent = string.rep("|cff000000 |r", tabWidth)
	local li = [[<img src="Interface/Scenarios/ScenarioIcon-Combat"/>]] .. indent
	local hr = [[<img src="Interface/HelpFrame/CS_HelpTextures_Separator" align="center" width="600" height="8"/>]]
	local colorStart = string.format("<color=[\"'](%s)[\"']>", string.rep("[0-9A-Fa-f]", 6))
	local colorEnd = "</color>"

	local specialTags = {
		spacing = "<p></p>",
		indent = indent,
	}

	local formatColor = function(hex)
		return string.format("|cff%s", hex)
	end

	local formatSpecialTag = function(tag, times)
		if times ~= "" then
			return string.rep(specialTags[tag], times)
		end
		return specialTags[tag]
	end

	convertToHTML = function(text)
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
end

function Custom_KnowledgeBase.FormatArticleText(text)
	return string.format("<html><body>%s<br/></body></html>", convertToHTML(text))
end