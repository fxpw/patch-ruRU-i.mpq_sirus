local _G = _G
local error = error
local pcall = pcall
local tonumber = tonumber
local type = type
local strformat, strmatch = string.format, string.match
local tinsert, tremove = table.insert, table.remove

local GetItemInfo = GetItemInfo

local itemCacheBlacklist = {}
local itemCacheUnique = {}
local itemCacheQueue = {}

local itemQualityHexes = {}
local itemClassMap = {}
local itemSubClassMap = {}
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

enum:E_ITEM_INFO {
	"NAME_ENGB",
	"NAME_RURU",
	"RARITY",
	"ILEVEL",
	"MINLEVEL",
	"TYPE",
	"SUBTYPE",
	"STACKCOUNT",
	"EQUIPLOC",
	"TEXTURE",
	"VENDORPRICE"
}

C_Item = {}
C_Item.GetItemInfoRaw = GetItemInfo

local LOCALE = GetLocale()

local EVENT_HANDLER = CreateFrame("Frame")
local TOOLTIP = CreateFrame("GameTooltip")

local function runItemCallback(callback, ...)
	local ok, ret = pcall(callback, ...)
	if not ok then
		geterrorhandler()(ret)
	end
end

local function tryItemData(queueData, itemID, itemName, ...)
	if itemName then
		for i = 3, #queueData do
			runItemCallback(queueData[i], itemID, itemName, ...)
		end
		return true
	end
end

EVENT_HANDLER:SetScript("OnUpdate", function(this, elapsed)
	local index = #itemCacheQueue
	if index > 0 then
		local lastIndex = math.max(index - 450, 0)
		while index > lastIndex do
			local queueData = itemCacheQueue[index]
			local itemID = queueData[2]

			if tryItemData(queueData, itemID, GetItemInfo(itemID)) then
				itemCacheUnique[itemID] = nil
				tremove(itemCacheQueue, index)
			else
				queueData[1] = queueData[1] + elapsed
				if queueData[1] >= 1 then
					if queueData[0] < 62 then
						queueData[0] = queueData[0] + queueData[1]
						queueData[1] = 0
						TOOLTIP:SetHyperlink(strformat("item:%i", itemID))
					else
						itemCacheBlacklist[itemID] = true
						itemCacheUnique[itemID] = nil
						tremove(itemCacheQueue, index)
					end
				end
			end

			index = index - 1
		end
	end
end)

local function getItemID(item, funcName)
	if type(item) == "string" then
		if ItemsCache[item] then
			item = ItemsCache[item].itemID
		else
			item = tonumber(item) or tonumber(strmatch(item, "item:(%d+)"))
		end
	end
	if item then
		if type(item) ~= "number" then
			error(string.format([[Usage: C_Item.%s(itemID|"name"|"itemlink")]], funcName), 3)
		end
		if item > 0 then
			return item
		end
	end
end

---@param item integer | string
---@param callback? function
function C_Item.RequestServerCache(item, callback)
	item = getItemID(item, "RequestServerCache")
	if not item then
		return
	end

	TOOLTIP:SetHyperlink(strformat("item:%i", item))

	if itemCacheBlacklist[item] then
		return
	end

	if not itemCacheUnique[item] then
		local queueEntry

		if type(callback) == "function" then
			queueEntry = {[0] = 0, 0, item, callback}
		else
			queueEntry = {[0] = 0, 0, item}
		end

		itemCacheUnique[item] = queueEntry
		tinsert(itemCacheQueue, queueEntry)
	else
		local itemEntry = itemCacheUnique[item]
		local index = tIndexOf(itemCacheUnique, itemEntry)
		tremove(itemCacheUnique, index)
		tinsert(itemCacheUnique, itemEntry)

		itemEntry[1] = 0

		if type(callback) == "function" then
			tinsert(itemCacheUnique[item], callback)
		end
	end
end

---@param item integer | string
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
function C_Item.GetItemInfoCache(item)
	item = getItemID(item, "GetItemInfoCache")
	if not item then
		return
	end

	local cacheData = ItemsCache[item]
	if cacheData then
		local itemName		= cacheData[C_Item.GetLocaleIndex()]
		local itemRarity	= cacheData[E_ITEM_INFO.RARITY]
		local itemMinLevel	= cacheData[E_ITEM_INFO.MINLEVEL]
		local classID		= cacheData[E_ITEM_INFO.TYPE]
		local subclassID	= cacheData[E_ITEM_INFO.SUBTYPE]
		local equipLocID	= cacheData[E_ITEM_INFO.EQUIPLOC]

		if not cacheData.link then
			cacheData.link = strformat("|c%s|Hitem:%d:0:0:0:0:0:0:0:%d|h[%s]|h|r", itemQualityHexes[itemRarity] or "ffffffff", cacheData.itemID, itemMinLevel, itemName)
		end

		return itemName,
			cacheData.link,
			itemRarity,
			cacheData[E_ITEM_INFO.ILEVEL],
			itemMinLevel,
			_G["ITEM_CLASS_"..classID],
			_G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID],
			cacheData[E_ITEM_INFO.STACKCOUNT],
			SHARED_INVTYPE_BY_ID[equipLocID],
			"Interface\\Icons\\"..cacheData[E_ITEM_INFO.TEXTURE],
			cacheData[E_ITEM_INFO.VENDORPRICE],
			cacheData.itemID,
			classID,
			subclassID,
			equipLocID
	end
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
		return
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
	local itemID, classID, subClassID, equipLocID

	if not itemName then
		if not noRequest then
			C_Item.RequestServerCache(item, callback)
			itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
		end

		if not itemName and not skipClientCache and GetServerID() ~= REALM_ID_SIRUS then
			itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID = C_Item.GetItemInfoCache(item)
		end
	end

	if itemLink then
		itemID = itemID or tonumber(strmatch(itemLink, "item:(%d+)"))

		if itemID and (itemID == 43308 or itemID == 43307) then
			local unitFaction = UnitFactionGroup("player")
			if itemID == 43308 then
				itemTexture = "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction
			elseif itemID == 43307 then
				itemTexture = "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction
			end
		end
	end

	if noAdditionalData then
		return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice
	else
		if not classID then
			classID = C_Item.GetItemClassID(itemType)
			subClassID = C_Item.GetItemSubClassID(itemSubType)
			equipLocID = C_Item.GetItemEquipLocID(itemEquipLoc)
		end

		return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID
	end
end

function C_Item.GetLocaleIndex()
	return LOCALE == "ruRU" and E_ITEM_INFO.NAME_RURU or E_ITEM_INFO.NAME_ENGB
end

---@param itemType string
---@return integer? itemClassID
function C_Item.GetItemClassID(itemType)
	return itemClassMap[itemType]
end

---@param itemSubType string
---@return integer? itemSubClassID
function C_Item.GetItemSubClassID(itemSubType)
	return itemSubClassMap[itemSubType]
end

---@param itemEquipLoc string
---@return integer? invEquipLocID
function C_Item.GetItemEquipLocID(itemEquipLoc)
	return itemInvTypeToID[itemEquipLoc]
end

do
	for i = 0, 7 do
		local _, _, _, hex = GetItemQualityColor(i)
		itemQualityHexes[i] = hex:sub(3)
	end

	local classID = 0
	local className = _G["ITEM_CLASS_" .. classID]
	while className do
		itemClassMap[className] = classID

		local subclassID = 0
		local subclassName = _G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID]
		while subclassName do
			itemSubClassMap[subclassName] = subclassID

			subclassID = subclassID + 1
			subclassName = _G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID]
		end

		classID = classID + 1
		className = _G["ITEM_CLASS_" .. classID]
	end

	if ItemsCache then
		local namedItems = {}
		local localeIndex = C_Item.GetLocaleIndex()
		for itemID, itemData in pairs(ItemsCache) do
			itemData.itemID = itemID

			local itemName = itemData[localeIndex]
			if itemName and itemName ~= "" then
				namedItems[itemName] = itemData
			end
		end
		for itemName, itemData in pairs(namedItems) do
			ItemsCache[itemName] = itemData
			namedItems[itemName] = nil
		end
	else
		GMError("No ItemCache")
	end
end

_G.GetItemInfo = function(item)
	return C_Item.GetItemInfo(item, nil, nil, true)
end