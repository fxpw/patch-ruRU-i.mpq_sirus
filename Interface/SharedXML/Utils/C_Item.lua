local _G = _G
local error = error
local ipairs = ipairs
local pcall = pcall
local tonumber = tonumber
local type = type
local unpack = unpack
local strfind, strformat, strmatch = string.find, string.format, string.match
local tIndexOf, tinsert, tremove = tIndexOf, table.insert, table.remove

local GetContainerItemGUID = GetContainerItemGUID
local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetInventoryItemGUID = GetInventoryItemGUID
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink
local GetItemIcon = GetItemIcon
local GetItemInfo = GetItemInfo
local GetItemInfoEx = GetItemInfoEx
local GetItemInfoInstant = GetItemInfoInstant
local GetItemLocation = GetItemLocation
local GetItemRandomPropertyName = GetItemRandomPropertyName
local IsBoundByGUID = IsBoundByGUID
local IsItemDataCachedByID = IsItemDataCachedByID
local LockItemByGUID = LockItemByGUID
local RequestLoadItemDataByID = RequestLoadItemDataByID
local UnlockItemByGUID = UnlockItemByGUID
local securecall = securecall

local FireCustomClientEvent = FireCustomClientEvent
local IsInterfaceDevClient = IsInterfaceDevClient

local ICON_UNKNOWN = [[Interface\Icons\INV_Misc_QuestionMark]]

local itemInvTypeToID = {
	INVTYPE_HEAD			= 1,
	INVTYPE_NECK			= 2,
	INVTYPE_SHOULDER		= 3,
	INVTYPE_BODY			= 4,
	INVTYPE_CHEST			= 5,
	INVTYPE_WAIST			= 6,
	INVTYPE_LEGS			= 7,
	INVTYPE_FEET			= 8,
	INVTYPE_WRIST			= 9,
	INVTYPE_HAND			= 10,
	INVTYPE_FINGER			= 11,
	INVTYPE_TRINKET			= 12,
	INVTYPE_WEAPON			= 13,
	INVTYPE_SHIELD			= 14,
	INVTYPE_RANGED			= 15,
	INVTYPE_CLOAK			= 16,
	INVTYPE_2HWEAPON		= 17,
	INVTYPE_BAG				= 18,
	INVTYPE_TABARD			= 19,
	INVTYPE_ROBE			= 20,
	INVTYPE_WEAPONMAINHAND	= 21,
	INVTYPE_WEAPONOFFHAND	= 22,
	INVTYPE_HOLDABLE		= 23,
	INVTYPE_AMMO			= 24,
	INVTYPE_THROWN			= 25,
	INVTYPE_RANGEDRIGHT		= 26,
	INVTYPE_QUIVER			= 27,
	INVTYPE_RELIC			= 28,
}

local ITEM_CACHE_FIELD = {
	NAME_ENGB	= 1,
	NAME_RURU	= 2,
	RARITY		= 3,
	ILEVEL		= 4,
	MINLEVEL	= 5,
	TYPE		= 6,
	SUBTYPE		= 7,
	STACKCOUNT	= 8,
	EQUIPLOC	= 9,
	TEXTURE		= 10,
	VENDORPRIC	= 11,
}
local ITEM_ID_FIELD = 0

local ITEM_CHEST_FIELD = {
	ITEM_ID		= 1,
	AMOUNT		= 2,
	AMOUNT_MAX	= 3,
}

local ITEM_REQUIREMENT_DATA = {
	TYPE			= 1,
	ARENA_PRICE		= 2,
	HONOR_PRICE		= 3,
	REQUIRED_RATING	= 4,
}

Enum.ItemCacheField = CopyTable(ITEM_CACHE_FIELD)
Enum.ItemCacheField.ITEM_ID = ITEM_ID_FIELD

Enum.ItemRequirementType = {
	Arena			= 0,
	Battleground	= 1,
	None			= 2,
	Removed			= 3,
}

local ItemsCache
local ITEMS_CHEST_LOOT
local ITEMS_CREATE_HEIRLOOM
local REQUIREMENT_ITEM_LIST
local ITEM_EXPIRATION_BLACKLIST

local PRIVATE = {
	IN_GLUE = IsOnGlueScreen(),
	LOGGED_IN = false,
	LOCALE_INDEX = GetLocale() == "ruRU" and ITEM_CACHE_FIELD.NAME_RURU or ITEM_CACHE_FIELD.NAME_ENGB,

	ITEM_QUALITY_HEX = {},
	ITEM_CLASS_MAP = {},
	ITEM_SUB_CLASS_MAP = {},
}

PRIVATE.ReloadData = function()
	ITEMS_CHEST_LOOT = _G.ITEMS_CHEST_LOOT
	ITEMS_CREATE_HEIRLOOM = _G.ITEMS_CREATE_HEIRLOOM
	REQUIREMENT_ITEM_LIST = _G.REQUIREMENT_ITEM_LIST
	ITEM_EXPIRATION_BLACKLIST = _G.ITEM_EXPIRATION_BLACKLIST

	if type(ItemsCache1) == "table" then
		if ItemsCache1 then
			ItemsCache = ItemsCache1
			ItemsCache1 = nil
			_G.ItemsCache = ItemsCache
		end

		if type(ItemsCache2) == "table" then
			for itemID, itemData in pairs(ItemsCache2) do
				ItemsCache[itemID] = itemData
			end
			table.wipe(ItemsCache2)
			ItemsCache2 = nil
		end

		local localeIndex = PRIVATE.LOCALE_INDEX
		local namedItems = {}
		for itemID, itemData in pairs(ItemsCache) do
			itemData[ITEM_ID_FIELD] = itemID

			local itemName = itemData[localeIndex]
			if itemName and itemName ~= "" then
				namedItems[itemName] = itemData
			end
		end

		setmetatable(ItemsCache, {__index = namedItems})
	end
end

PRIVATE.Initialize = function()
	PRIVATE.ReloadData()

	if not PRIVATE.IN_GLUE then
		PRIVATE.LOGGED_IN = IsLoggedIn() == 1
	end

	if IsInterfaceDevClient() then
		_G.PRIVATE_ITEM = PRIVATE
	end
end

PRIVATE.AssertNumValue = function(arg, funcName, noError)
	if arg == nil then
		return
	end

	local argType = type(arg)
	if argType == "number" then
		return arg
	elseif argType == "string" then
		return tonumber(arg)
	elseif not noError then
		error(strformat([[Usage: C_Item.%s(itemID|"name"|"itemlink" [, ...])]], funcName), 3)
	end
end

PRIVATE.GetItemID = function(item, funcName, ...)
	if type(item) == "string" then
		if ItemsCache[item] then
			return ItemsCache[item][ITEM_ID_FIELD]
		else
			return tonumber(item) or tonumber(strmatch(item, "item:(%d+)"))
		end
	else
		if type(item) ~= "number" then
			if funcName then
				error(strformat([[Usage: C_Item.%s(itemID|"name"|"itemlink")]], funcName), 3)
			end
		elseif item > 0 then
			return item
		end
	end
end

PRIVATE.GetItemIDEx = function(item, funcName, randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel)
	if type(item) == "string" then
		if ItemsCache[item] then
			item = ItemsCache[item][ITEM_ID_FIELD]
		else
			if randomPropertyID == true then
				local itemID = tonumber(item)
				if itemID then
					item = itemID
				else
					item, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, linkLevel = PRIVATE.GetItemLinkData(item)
				end
			else
				item = tonumber(item) or tonumber(strmatch(item, "item:(%d+)"))
			end
		end
	end
	if item then
		if type(item) ~= "number" then
			if funcName then
				error(strformat([[Usage: C_Item.%s(itemID|"name"|"itemlink")]], funcName), 3)
			end
		elseif item > 0 then
			return item, randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel
		end
	end
end

PRIVATE.CreateItemLink = function(itemName, itemID, itemRarity, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, linkLevel)
	return strformat("|c%s|Hitem:%d:%d:%d:%d:%d:%d:%d:%d:%d|h[%s]|h|r",
		itemRarity and PRIVATE.ITEM_QUALITY_HEX[itemRarity] or "ffffffff",
		itemID or 0,
		enchantID or 0,
		jewelItemID1 or 0,
		jewelItemID2 or 0,
		jewelItemID3 or 0,
		jewelItemID4 or 0,
		randomPropertyID or 0,
		uniqueID or 0,
		linkLevel or 0,
		itemName or UNKNOWN
	)
end

PRIVATE.GetItemLinkData = function(itemLink)
	if type(itemLink) == "string" then
		local itemID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, linkLevel = strmatch(itemLink, "item:(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(-?%d*):?(-?%d*):?(%d*)")
		if itemID then
			return tonumber(itemID) or 0,
				tonumber(enchantID) or 0,
				tonumber(jewelItemID1) or 0,
				tonumber(jewelItemID2) or 0,
				tonumber(jewelItemID3) or 0,
				tonumber(jewelItemID4) or 0,
				tonumber(randomPropertyID) or 0,
				tonumber(uniqueID) or 0,
				tonumber(linkLevel) or 0
		end
	end
	return 0, 0, 0, 0, 0, 0, 0, 0, 0
end

PRIVATE.GetItemGUIDByLocation = function(itemLocation)
	if itemLocation:IsBagAndSlot() then
		return GetContainerItemGUID(itemLocation:GetBagAndSlot())
	elseif itemLocation:IsEquipmentSlot() then
		return GetInventoryItemGUID("player", itemLocation:GetEquipmentSlot())
	end
end

PRIVATE.GetItemIDByLocation = function(itemLocation)
	if itemLocation:IsBagAndSlot() then
		return GetContainerItemID(itemLocation:GetBagAndSlot())
	elseif itemLocation:IsEquipmentSlot() then
		return GetInventoryItemID("player", itemLocation:GetEquipmentSlot())
	end
end

PRIVATE.GetItemLinkByLocation = function(itemLocation)
	if itemLocation:IsBagAndSlot() then
		return GetContainerItemLink(itemLocation:GetBagAndSlot())
	elseif itemLocation:IsEquipmentSlot() then
		return GetInventoryItemLink("player", itemLocation:GetEquipmentSlot())
	end
end

PRIVATE.GetItemChest = function(itemID)
	local itemChest = ITEMS_CHEST_LOOT[itemID]
	if type(itemChest) ~= "table" then
		return
	end

	if not itemChest.__size then
		local i = 1
		local itemData = itemChest[i]
		while itemData do
			if type(itemData) == "table" then
				local isDuplicate = false
				if itemID >= 100900 and itemID <= 100979 then
					for j = 1, i - 1 do
						local itemData2 = itemChest[j]
						if itemData[ITEM_CHEST_FIELD.ITEM_ID] == itemData2[ITEM_CHEST_FIELD.ITEM_ID]
						and itemData[ITEM_CHEST_FIELD.AMOUNT] == itemData2[ITEM_CHEST_FIELD.AMOUNT]
						and itemData[ITEM_CHEST_FIELD.AMOUNT_MAX] == itemData2[ITEM_CHEST_FIELD.AMOUNT_MAX]
						then
							isDuplicate = true
							break
						end
					end
				end
				if isDuplicate then
					tremove(itemChest, i)
				else
					i = i + 1
				end
			else
				tremove(itemChest, i)
			end
			itemData = itemChest[i]
		end
		itemChest.__size = #itemChest
	end

	if itemChest.__size > 0 then
		return itemChest
	end
end

C_Item = {}

function C_Item.ReloadData()
	if IsInterfaceDevClient() then
		PRIVATE.ReloadData()
	end
end

function C_Item.GetItemIDFromString(item)
	if type(item) ~= "number" and type(item) ~= "string" then
		error([[Usage: C_Item.GetItemIDFromString(itemID|"name"|"itemlink")]], 2)
	end
	local itemID = GetItemInfoInstant(item)
	return itemID or PRIVATE.GetItemID(item, "GetItemIDFromString")
end

---@param itemType string
---@return integer? itemClassID
function C_Item.GetItemClassID(itemType)
	return PRIVATE.ITEM_CLASS_MAP[itemType] or 0
end

---@param classID integer
---@param itemSubType string
---@return integer? itemSubClassID
function C_Item.GetItemSubClassID(classID, itemSubType)
	if PRIVATE.ITEM_SUB_CLASS_MAP[classID] then
		return PRIVATE.ITEM_SUB_CLASS_MAP[classID][itemSubType]
	end
end

---@param itemEquipLoc string
---@return integer? invEquipLocID
function C_Item.GetItemEquipLocID(itemEquipLoc)
	return itemInvTypeToID[itemEquipLoc] or 0
end

function C_Item.GetCreatedItemIDByItem(item)
	item = PRIVATE.GetItemID(item, "GetCreatedItem")
	if not item then
		return
	end
	return ITEMS_CREATE_HEIRLOOM[item]
end

function C_Item.IsItemChest(item)
	item = PRIVATE.GetItemID(item, "IsItemChest")
	if not item then
		return
	end
	local itemChest = PRIVATE.GetItemChest(item)
	if itemChest then
		return true
	end
	return false
end

function C_Item.GetNumItemChestItems(item)
	item = PRIVATE.GetItemID(item, "GetNumItemChestItems")
	if not item then
		return
	end
	local itemChest = PRIVATE.GetItemChest(item)
	if itemChest then
		return itemChest.__size or 0
	end
	return 0
end

function C_Item.GetItemChestItemData(item, index)
	item = PRIVATE.GetItemID(item, "GetItemChestItemData")
	if not item then
		return
	end

	local itemChest = PRIVATE.GetItemChest(item)
	if not itemChest then
		return
	end

	local numItems = itemChest.__size
	if index < 1 or index > numItems then
		error(strformat("bad argument #2 to 'C_Item.GetItemChestItemData' (index %s out of range)", index), 2)
	end

	local itemChestItemData = itemChest[index]
	if itemChestItemData then
		local itemID = itemChestItemData[ITEM_CHEST_FIELD.ITEM_ID]
		local amount = itemChestItemData[ITEM_CHEST_FIELD.AMOUNT]
		local amountRangeMax = itemChestItemData[ITEM_CHEST_FIELD.AMOUNT_MAX]

		return itemID, amount, amountRangeMax
	end
end

function C_Item.IsItemExpirationBlacklisted(item)
	item = PRIVATE.GetItemID(item, "IsItemExpirationBlacklisted")
	if not item then
		return false
	end

	return ITEM_EXPIRATION_BLACKLIST[item] ~= nil
end

if not PRIVATE.IN_GLUE then
	C_Item.GetItemInfoRaw = GetItemInfo
	C_Item.IsItemDataCachedByID = IsItemDataCachedByID
	C_Item.RequestLoadItemDataByID = RequestLoadItemDataByID

	local SERVER_ID = GetServerID()

	do -- cache handler
		PRIVATE.CACHE_REQUESTS = {}
		PRIVATE.CACHE_BLACKLIST = {}
		PRIVATE.CACHE_ITEM_INFO_REQUEST = {}
		PRIVATE.CACHE_REQUESTS_QUEUE = {}

		PRIVATE.EventHandler = CreateFrame("Frame")
		PRIVATE.EventHandler:Hide()
		PRIVATE.EventHandler:RegisterEvent("ITEM_DATA_LOAD_RESULT")
		PRIVATE.EventHandler:RegisterEvent("PLAYER_LOGIN")
		PRIVATE.EventHandler:SetScript("OnEvent", function(self, event, ...)
			if event == "ITEM_DATA_LOAD_RESULT" then
				local itemID, success = ...

				if not success then
					PRIVATE.CACHE_BLACKLIST[itemID] = true
				end

				local cacheRequest = PRIVATE.CACHE_REQUESTS[itemID]
				if cacheRequest then
					if success and #cacheRequest > 0 then
						PRIVATE.HandleCacheCallbacks(cacheRequest, itemID, GetItemInfoEx(itemID))
					end
					PRIVATE.CACHE_REQUESTS[itemID] = nil
				end

				if PRIVATE.CACHE_ITEM_INFO_REQUEST[itemID] then
					PRIVATE.CACHE_ITEM_INFO_REQUEST[itemID] = nil
					FireCustomClientEvent("GET_ITEM_INFO_RECEIVED", itemID, success)
				end
			elseif event == "PLAYER_LOGIN" then
				PRIVATE.LOGGED_IN = true
				PRIVATE.ProcessQueue()
			end
		end)

		PRIVATE.FireCacheCallback = function(callback, ...)
			local success, err = pcall(callback, ...)
			if not success then
				geterrorhandler()(err)
			end
		end

		PRIVATE.HandleCacheCallbacks = function(cacheRequests, itemID, itemName, ...)
			if itemName then
				for index, callback in ipairs(cacheRequests) do
					securecall(PRIVATE.FireCacheCallback, callback, itemID, itemName, ...)
				end
			end
		end

		PRIVATE.ProcessQueue = function()
			for index, itemID in ipairs(PRIVATE.CACHE_REQUESTS_QUEUE) do
				RequestLoadItemDataByID(itemID)
			end
			table.wipe(PRIVATE.CACHE_REQUESTS_QUEUE)
		end

		PRIVATE.RequestServerCache = function(itemID, callback, isInfoRequest)
			if type(callback) ~= "function" then
				callback = nil
			end

			if PRIVATE.CACHE_BLACKLIST[itemID]
			or (PRIVATE.CACHE_REQUESTS[itemID] and not callback)
			then
				return false
			end

			if IsItemDataCachedByID(itemID) then
				if callback then
					PRIVATE.FireCacheCallback(callback, itemID, GetItemInfoEx(itemID))
				end
				return false
			end

			if isInfoRequest then
				PRIVATE.CACHE_ITEM_INFO_REQUEST[itemID] = true
			end

			if not PRIVATE.CACHE_REQUESTS[itemID] then
				PRIVATE.CACHE_REQUESTS[itemID] = {callback}

				if PRIVATE.LOGGED_IN then
					RequestLoadItemDataByID(itemID)
				else
					tinsert(PRIVATE.CACHE_REQUESTS_QUEUE, itemID)
				end
			else
				if not tIndexOf(PRIVATE.CACHE_REQUESTS[itemID], callback) then
					tinsert(PRIVATE.CACHE_REQUESTS[itemID], callback)
				end
			end

			return true
		end
	end

	---@param item integer | string
	---@param callback? function
	---@return bool isRequestSent
	function C_Item.RequestServerCache(item, callback)
		item = PRIVATE.GetItemID(item, "RequestServerCache")
		if not item then
			return false
		end
		return PRIVATE.RequestServerCache(item, callback, false)
	end

	function C_Item.IsItemInfoLoaded(item)
		item = PRIVATE.GetItemID(item, "IsItemInfoLoaded")
		if not item then
			return false
		end
		if PRIVATE.CACHE_BLACKLIST[item] then
			return false
		end
		return IsItemDataCachedByID(item)
	end

	---@param item integer | string
	---@param randomPropertyID? integer | string | boolean
	---@param uniqueID? integer | string
	---@param enchantID? integer | string
	---@param jewelItemID1? integer | string
	---@param jewelItemID2? integer | string
	---@param jewelItemID3? integer | string
	---@param jewelItemID4? integer | string
	---@param linkLevel? integer | string
	---@return string itemName
	---@return string itemLink
	---@return integer itemRarity
	---@return integer itemLevel
	---@return integer itemMinLevel
	---@return string itemType
	---@return string itemSubType
	---@return integer itemStackCount
	---@return string itemEquipLoc
	---@return string itemTexture
	---@return integer vendorPrice
	---@return integer itemID
	---@return integer classID
	---@return integer subclassID
	---@return integer equipLocID
	function C_Item.GetItemInfoCache(item, randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel)
		item, randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel = PRIVATE.GetItemIDEx(item, "GetItemInfoCache", randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel)
		if not item then
			return
		end

		local cacheData = ItemsCache[item]
		if not cacheData then
			return
		end

		randomPropertyID	= PRIVATE.AssertNumValue(randomPropertyID, "GetItemInfoCache")
		uniqueID			= PRIVATE.AssertNumValue(uniqueID, "GetItemInfoCache")
		enchantID			= PRIVATE.AssertNumValue(enchantID, "GetItemInfoCache")
		jewelItemID1		= PRIVATE.AssertNumValue(jewelItemID1, "GetItemInfoCache")
		jewelItemID2		= PRIVATE.AssertNumValue(jewelItemID2, "GetItemInfoCache")
		jewelItemID3		= PRIVATE.AssertNumValue(jewelItemID3, "GetItemInfoCache")
		jewelItemID4		= PRIVATE.AssertNumValue(jewelItemID4, "GetItemInfoCache")
		linkLevel			= PRIVATE.AssertNumValue(linkLevel, "GetItemInfoCache")

		local itemName		= cacheData[PRIVATE.LOCALE_INDEX]
		local itemRarity	= cacheData[ITEM_CACHE_FIELD.RARITY]
		local itemMinLevel	= cacheData[ITEM_CACHE_FIELD.MINLEVEL]
		local classID		= cacheData[ITEM_CACHE_FIELD.TYPE]
		local subclassID	= cacheData[ITEM_CACHE_FIELD.SUBTYPE]
		local equipLocID	= cacheData[ITEM_CACHE_FIELD.EQUIPLOC]

		local link
		if randomPropertyID and randomPropertyID ~= 0 then
			local propertyName = GetItemRandomPropertyName(randomPropertyID)
			if propertyName then
				itemName = strformat(ITEM_SUFFIX_TEMPLATE, itemName, propertyName)
				link = PRIVATE.CreateItemLink(itemName, cacheData[ITEM_ID_FIELD], itemRarity, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, itemMinLevel)
			end
		end

		if not link and (uniqueID or enchantID or jewelItemID1 or jewelItemID2 or jewelItemID3 or jewelItemID4) then
			link = PRIVATE.CreateItemLink(itemName, cacheData[ITEM_ID_FIELD], itemRarity, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, itemMinLevel)
		end

		if not link and not cacheData.link then
			cacheData.link = PRIVATE.CreateItemLink(itemName, cacheData[ITEM_ID_FIELD], itemRarity, 0, 0, 0, 0, 0, 0, 0, itemMinLevel)
		end

		return itemName,
			link or cacheData.link,
			itemRarity,
			cacheData[ITEM_CACHE_FIELD.ILEVEL],
			itemMinLevel,
			_G["ITEM_CLASS_"..classID],
			_G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID],
			cacheData[ITEM_CACHE_FIELD.STACKCOUNT],
			SHARED_INVTYPE_BY_ID[equipLocID],
			"Interface\\Icons\\"..cacheData[ITEM_CACHE_FIELD.TEXTURE],
			cacheData[ITEM_CACHE_FIELD.VENDORPRICE],
			cacheData[ITEM_ID_FIELD],
			classID,
			subclassID,
			equipLocID
	end

	function C_Item.GetItemLinkCache(item, randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel)
		item, randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel = PRIVATE.GetItemIDEx(item, "GetItemLinkCache", randomPropertyID, uniqueID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, linkLevel)
		if not item then
			return
		end

		local cacheData = ItemsCache[item]
		if not cacheData then
			return
		end

		randomPropertyID	= PRIVATE.AssertNumValue(randomPropertyID, "GetItemLinkCache")
		uniqueID			= PRIVATE.AssertNumValue(uniqueID, "GetItemLinkCache")
		enchantID			= PRIVATE.AssertNumValue(enchantID, "GetItemLinkCache")
		jewelItemID1		= PRIVATE.AssertNumValue(jewelItemID1, "GetItemLinkCache")
		jewelItemID2		= PRIVATE.AssertNumValue(jewelItemID2, "GetItemLinkCache")
		jewelItemID3		= PRIVATE.AssertNumValue(jewelItemID3, "GetItemLinkCache")
		jewelItemID4		= PRIVATE.AssertNumValue(jewelItemID4, "GetItemLinkCache")
		linkLevel			= PRIVATE.AssertNumValue(linkLevel, "GetItemLinkCache")

		local itemName		= cacheData[PRIVATE.LOCALE_INDEX]
		local itemRarity	= cacheData[ITEM_CACHE_FIELD.RARITY]
		local itemMinLevel	= cacheData[ITEM_CACHE_FIELD.MINLEVEL]

		local link
		if randomPropertyID and randomPropertyID ~= 0 then
			local propertyName = GetItemRandomPropertyName(randomPropertyID)
			if propertyName then
				itemName = strformat(ITEM_SUFFIX_TEMPLATE, itemName, propertyName)
				link = PRIVATE.CreateItemLink(itemName, cacheData[ITEM_ID_FIELD], itemRarity, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, itemMinLevel)
			end
		end

		if not link and (uniqueID or enchantID or jewelItemID1 or jewelItemID2 or jewelItemID3 or jewelItemID4) then
			link = PRIVATE.CreateItemLink(itemName, cacheData[ITEM_ID_FIELD], itemRarity, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, itemMinLevel)
		end

		if not link and not cacheData.link then
			cacheData.link = PRIVATE.CreateItemLink(itemName, cacheData[ITEM_ID_FIELD], itemRarity, 0, 0, 0, 0, 0, 0, 0, itemMinLevel)
		end

		return link or cacheData.link
	end

	---@param item integer | string
	---@param skipClientCache? boolean
	---@param callback? function
	---@param noAdditionalData? boolean
	---@param noRequest? boolean
	---@return string itemName
	---@return string itemLink
	---@return integer itemRarity
	---@return integer itemLevel
	---@return integer itemMinLevel
	---@return string itemType
	---@return string itemSubType
	---@return integer itemStackCount
	---@return string itemEquipLoc
	---@return string itemTexture
	---@return integer vendorPrice
	---@return integer? itemID
	---@return integer? classID
	---@return integer? subclassID
	---@return integer? equipLocID
	function C_Item.GetItemInfo(item, skipClientCache, callback, noAdditionalData, noRequest)
		if not item then
			if IsInterfaceDevClient() then
				GMError("No item id or link was passed to C_Item.GetItemInfo")
			end
			return
		end

		local _itemID = PRIVATE.GetItemID(item, "GetItemInfo")
		if not _itemID then
			return
		end

		local cacheWasUsed
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID = GetItemInfoEx(item)

		if not itemName then
			if not noRequest then
				PRIVATE.RequestServerCache(_itemID, callback, true)
			end

			if not skipClientCache then
				itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID = C_Item.GetItemInfoCache(item)
				cacheWasUsed = true
			end
		end

		if itemID == 43308 or itemID == 43307 then
			local unitFaction = UnitFactionGroup("player")
			if itemID == 43308 then
				itemTexture = "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction
			elseif itemID == 43307 then
				itemTexture = "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction
			end
		end

		if noAdditionalData then
			return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice
		else
			return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice,
				itemID,
				classID or C_Item.GetItemClassID(itemType),
				subClassID or C_Item.GetItemSubClassID(classID, itemSubType),
				equipLocID or C_Item.GetItemEquipLocID(itemEquipLoc),
				cacheWasUsed or false
		end
	end

	function C_Item.GetRequiredPVPRating(item, honorPrice, arenaPrice)
		item = PRIVATE.GetItemID(item, "GetRequiredPVPRating")
		if not item then
			return Enum.ItemRequirementType.None, 0
		end

		local requirements = REQUIREMENT_ITEM_LIST[SERVER_ID] and REQUIREMENT_ITEM_LIST[SERVER_ID][item]
		if requirements then
			for i, requirement in ipairs(requirements) do
				if requirement[ITEM_REQUIREMENT_DATA.HONOR_PRICE] == honorPrice
				and requirement[ITEM_REQUIREMENT_DATA.ARENA_PRICE] == arenaPrice
				then
					return requirement[ITEM_REQUIREMENT_DATA.TYPE], requirement[ITEM_REQUIREMENT_DATA.REQUIRED_RATING]
				end
			end

			return Enum.ItemRequirementType.Removed, 0
		end

		return Enum.ItemRequirementType.None, 0
	end

	function C_Item.IsWeapon(item)
		item = PRIVATE.GetItemID(item, "IsWeapon")
		if not item then
			return
		end

		local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = GetItemInfoInstant(item)
		if not itemID then
			return
		end

		if classID == 2 or (classID == 4 and subClassID == 0) then
			return true
		end
		local equipLocID = C_Item.GetItemEquipLocID(itemEquipLoc)
		if equipLocID == 14 or equipLocID == 23 then
			return true
		end

		return false
	end

	function C_Item.GetItemLinkData(itemLink)
		if type(itemLink) ~= "string" or not strfind(itemLink, "item:", 1, true) then
			error([[Usage: C_Item.GetItemLinkData("itemlink")]], 2)
		end
		return PRIVATE.GetItemLinkData(itemLink)
	end

	function C_Item.HasPermanentEnchant(itemLink)
		if type(itemLink) ~= "string" or not strfind(itemLink, "item:", 1, true) then
			error([[Usage: C_Item.HasPermanentEnchant("itemlink")]], 2)
		end
		local itemID, enchantID, jewelItemID1, jewelItemID2, jewelItemID3, jewelItemID4, randomPropertyID, uniqueID, linkLevel = PRIVATE.GetItemLinkData(itemLink)
		return enchantID ~= 0
	end

	function C_Item.IsPermanentEnchant(item)
		item = PRIVATE.GetItemID(item, "IsPermanentEnchant")
		if item then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID, setID = GetItemInfoEx(item)
			if classID == 0 and subClassID == 6 then
				return true
			end
		end
		return false
	end

	do -- ItemGUID
		C_Item.GetItemLocationRaw = GetItemLocation
		C_Item.GetContainerItemGUID = GetContainerItemGUID
		C_Item.GetInventoryItemGUID = GetInventoryItemGUID
		C_Item.LockItemByGUID = LockItemByGUID
		C_Item.UnlockItemByGUID = UnlockItemByGUID
		C_Item.IsBoundByGUID = IsBoundByGUID

		function C_Item.GetItemLocation(itemGUID)
			local isInventory, slotIndex, bagID = GetItemLocation(itemGUID)
			if slotIndex then
				if isInventory then
					return ItemLocation:CreateFromEquipmentSlot(slotIndex)
				else
					return ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)
				end
			end
		end

		function C_Item.GetItemLinkByGUID(itemGUID)
			if type(itemGUID) ~= "string" then
				error([[Usage: C_Item.GetItemLinkByGUID("itemGUID")]], 2)
			end

			local isInventory, slotIndex, bagID = GetItemLocation(itemGUID)
			if slotIndex then
				if isInventory then
					return GetInventoryItemLink("player", slotIndex)
				else
					return GetContainerItemLink(bagID, slotIndex)
				end
			end
		end

		function C_Item.GetItemIDByGUID(itemGUID)
			if type(itemGUID) ~= "string" then
				error([[Usage: C_Item.GetItemIDByGUID("itemGUID")]], 2)
			end

			local isInventory, slotIndex, bagID = GetItemLocation(itemGUID)
			if slotIndex then
				if isInventory then
					return GetInventoryItemID("player", slotIndex)
				else
					return GetContainerItemID(bagID, slotIndex)
				end
			end
		end
	end

	do -- ItemLocation
		function C_Item.GetItemGUID(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: C_Item.GetItemGUID(itemLocation)", 2)
			end

			return PRIVATE.GetItemGUIDByLocation(itemLocation)
		end

		function C_Item.LockItem(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: C_Item.LockItem(itemLocation)", 2)
			end


			local guid = PRIVATE.GetItemGUIDByLocation(itemLocation)
			if guid then
				LockItemByGUID(guid)
			end
		end

		function C_Item.UnlockItem(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: C_Item.IsBound(itemLocation)", 2)
			end

			local guid = PRIVATE.GetItemGUIDByLocation(itemLocation)
			if guid then
				UnlockItemByGUID(guid)
			end
		end

		function C_Item.IsBound(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local isBound = C_Item.IsBound(itemLocation)", 2)
			end

			local guid = PRIVATE.GetItemGUIDByLocation(itemLocation)
			if guid then
				return IsBoundByGUID(guid)
			end
		end

		function C_Item.IsItemDataCached(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: C_Item.IsItemDataCached(itemLocation)", 2)
			end

			local itemID = PRIVATE.GetItemIDByLocation(itemLocation)
			if itemID then
				return IsItemDataCachedByID(itemID)
			end
			return false
		end

		function C_Item.RequestLoadItemData(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: C_Item.IsItemDataCached(itemLocation)", 2)
			end

			local itemID = PRIVATE.GetItemIDByLocation(itemLocation)
			if itemID then
				RequestLoadItemDataByID(itemID)
			end
		end

		function C_Item.DoesItemExist(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local itemExist = C_Item.DoesItemExist(itemLocation)", 2)
			end

			local itemID = PRIVATE.GetItemIDByLocation(itemLocation)
			return itemID --~- nil
		end

		function C_Item.GetItemID(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local itemID = C_Item.GetItemID(itemLocation)", 2)
			end

			return PRIVATE.GetItemIDByLocation(itemLocation)
		end

		function C_Item.GetItemLink(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local itemLink = C_Item.GetItemLink(itemLocation)", 2)
			end

			return PRIVATE.GetItemLinkByLocation(itemLocation)
		end

		function C_Item.GetItemName(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local itemName = C_Item.GetItemName(itemLocation)", 2)
			end

			local itemID = PRIVATE.GetItemIDByLocation(itemLocation)
			if itemID then
				local itemName = GetItemInfo(itemID)
				return itemName
			end
		end

		function C_Item.GetItemQuality(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local itemQuality = C_Item.GetItemQuality(itemLocation)", 2)
			end

			local itemID = PRIVATE.GetItemIDByLocation(itemLocation)
			if itemID then
				local _, _, itemQuality = GetItemInfo(itemID)
				return itemQuality
			end
		end

		function C_Item.GetItemIcon(itemLocation)
			if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
				error("Usage: local itemIcon = C_Item.GetItemIcon(itemLocation)", 2)
			end

			local itemID = PRIVATE.GetItemIDByLocation(itemLocation)
			if itemID then
				if itemLocation:IsBagAndSlot() then
					return GetItemIcon(itemID) or ICON_UNKNOWN
				else
					local _, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(itemID)
					return itemIcon or ICON_UNKNOWN
				end
			end
		end
	end

	_G.GetItemInfo = function(item)
		return C_Item.GetItemInfo(item, nil, nil, true)
	end
else
	local ALLOWED_REALMS = {}
	for realmKey, realmID in pairs(E_REALM_ID) do
		ALLOWED_REALMS[realmID] = true
	end

	function C_Item.HasItemInfoCache(item)
		item = PRIVATE.GetItemID(item, "GetItemInfoCache")
		if not item then
			return
		end

		local cacheData = ItemsCache[item]
		return cacheData ~= nil
	end

	function C_Item.GetItemLink(itemID)
		local realmID = GetServerID()
		if not realmID or not ALLOWED_REALMS[realmID] then
			realmID = E_REALM_ID.SCOURGE
		end
		return strformat("https://sirus.su/base/item/%d/%d", itemID, realmID)
	end

	function C_Item.GetItemInfoCache(item)
		item = PRIVATE.GetItemID(item, "GetItemInfoCache")
		if not item then
			local link
			if type(item) == "number" then
				link = C_Item.GetItemLink(item)
			end
			return UNKNOWN, link, 1, 0, 0, nil, nil, 0, nil, ICON_UNKNOWN, 0, 0, 0, 0
		end

		local cacheData = ItemsCache[item]
		if cacheData then
			local itemID		= cacheData[ITEM_ID_FIELD]
			local itemName		= cacheData[PRIVATE.LOCALE_INDEX]
			local itemRarity	= cacheData[ITEM_CACHE_FIELD.RARITY]
			local itemMinLevel	= cacheData[ITEM_CACHE_FIELD.MINLEVEL]
			local classID		= cacheData[ITEM_CACHE_FIELD.TYPE]
			local subclassID	= cacheData[ITEM_CACHE_FIELD.SUBTYPE]
			local equipLocID	= cacheData[ITEM_CACHE_FIELD.EQUIPLOC]

			if not cacheData.link then
				cacheData.link = C_Item.GetItemLink(itemID)
			end

			return itemName,
				cacheData.link,
				itemRarity,
				cacheData[ITEM_CACHE_FIELD.ILEVEL],
				itemMinLevel,
				_G["ITEM_CLASS_"..classID],
				_G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID],
				cacheData[ITEM_CACHE_FIELD.STACKCOUNT],
				SHARED_INVTYPE_BY_ID[equipLocID],
				"Interface\\Icons\\"..cacheData[ITEM_CACHE_FIELD.TEXTURE],
				cacheData[ITEM_CACHE_FIELD.VENDORPRICE],
				classID,
				subclassID,
				equipLocID
		end
	end
end

do
	if PRIVATE.IN_GLUE then
		local itemQuality = {
			[0] = {157, 157, 157, "|cff9d9d9d"},
			[1] = {255, 255, 255, "|cffffffff"},
			[2] = {30, 255, 0, "|cff1eff00"},
			[3] = {0, 112, 221, "|cff0070dd"},
			[4] = {163, 53, 238, "|cffa335ee"},
			[5] = {255, 128, 0, "|cffff8000"},
			[6] = {230, 204, 128, "|cffe6cc80"},
			[7] = {230, 204, 128, "|cffe6cc80"},
		}
		GetItemQualityColor = function(qualityIndex)
			if type(qualityIndex) ~= "number" then
				error("Usage: GetItemQualityColor(index)", 2)
			end
			if qualityIndex < 0 or qualityIndex > #itemQuality then
				qualityIndex = 1
			end
			local r, g, b, hex = unpack(itemQuality[qualityIndex])
			return r / 255, g / 255, b / 255, hex
		end
	else

	end

	for i = 0, 7 do
		local _, _, _, hex = GetItemQualityColor(i)
		PRIVATE.ITEM_QUALITY_HEX[i] = hex:sub(3)
	end

	local classID = 0
	local className = _G["ITEM_CLASS_" .. classID]
	while className do
		PRIVATE.ITEM_CLASS_MAP[className] = classID

		PRIVATE.ITEM_SUB_CLASS_MAP[classID] = {}

		local subclassID = 0
		local subclassName = _G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID]
		while subclassName do
			PRIVATE.ITEM_SUB_CLASS_MAP[classID][subclassName] = subclassID

			subclassID = subclassID + 1
			subclassName = _G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID]
		end

		classID = classID + 1
		className = _G["ITEM_CLASS_" .. classID]
	end

	PRIVATE.Initialize()
end