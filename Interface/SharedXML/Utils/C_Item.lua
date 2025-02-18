local _G = _G
local error = error
local pcall = pcall
local tonumber = tonumber
local type = type
local strformat, strmatch = string.format, string.match
local tIndexOf, tinsert, tremove = tIndexOf, table.insert, table.remove

local GetItemInfo = GetItemInfo

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

C_Item = {}

local GLUEXML = IsOnGlueScreen()
local LOCALE = GetLocale()
local LOCALE_INDEX = LOCALE == "ruRU" and ITEM_CACHE_FIELD.NAME_RURU or ITEM_CACHE_FIELD.NAME_ENGB

local function getItemID(item, funcName)
	if type(item) == "string" then
		if ItemsCache[item] then
			item = ItemsCache[item][ITEM_ID_FIELD]
		else
			item = tonumber(item) or tonumber(strmatch(item, "item:(%d+)"))
		end
	end
	if item then
		if type(item) ~= "number" then
			if funcName then
				error(string.format([[Usage: C_Item.%s(itemID|"name"|"itemlink")]], funcName), 3)
			end
		elseif item > 0 then
			return item
		end
	end
end

function C_Item.GetItemIDFromString(item)
	return getItemID(item)
end

---@param itemType string
---@return integer? itemClassID
function C_Item.GetItemClassID(itemType)
	return itemClassMap[itemType] or 0
end

---@param classID integer
---@param itemSubType string
---@return integer? itemSubClassID
function C_Item.GetItemSubClassID(classID, itemSubType)
	return itemSubClassMap[classID][itemSubType]
end

function C_Item.GetCreatedItemIDByItem(item)
	item = getItemID(item, "GetCreatedItem")
	if not item then
		return
	end
	return ITEMS_CREATE_HEIRLOOM[item]
end

---@param itemEquipLoc string
---@return integer? invEquipLocID
function C_Item.GetItemEquipLocID(itemEquipLoc)
	return itemInvTypeToID[itemEquipLoc] or 0
end

if not GLUEXML then
	C_Item.GetItemInfoRaw = GetItemInfo

	local itemCacheBlacklist = {}
	local itemCacheUnique = {}
	local itemCacheQueue = {}

	local SERVER_ID = GetServerID()

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
			FireCustomClientEvent("ITEM_DATA_LOAD_RESULT", true, itemID)
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
							FireCustomClientEvent("ITEM_DATA_LOAD_RESULT", false, itemID)
						end
					end
				end

				index = index - 1
			end
		end
	end)

	---@param item integer | string
	---@param callback? function
	function C_Item.RequestServerCache(item, callback)
		item = getItemID(item, "RequestServerCache")
		if not item then
			return
		end

		if itemCacheBlacklist[item] then
			return
		end

		TOOLTIP:SetHyperlink(strformat("item:%i", item))

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
				if not tIndexOf(itemCacheUnique[item], callback) then
					tinsert(itemCacheUnique[item], callback)
				end
			end
		end
	end

	function C_Item.IsItemInfoLoaded(item)
		item = getItemID(item, "IsItemInfoLoaded")
		if not item then
			return false
		end
		if itemCacheBlacklist[item] then
			return false
		end
		return GetItemInfo(item) ~= nil
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
			local itemName		= cacheData[LOCALE_INDEX]
			local itemRarity	= cacheData[ITEM_CACHE_FIELD.RARITY]
			local itemMinLevel	= cacheData[ITEM_CACHE_FIELD.MINLEVEL]
			local classID		= cacheData[ITEM_CACHE_FIELD.TYPE]
			local subclassID	= cacheData[ITEM_CACHE_FIELD.SUBTYPE]
			local equipLocID	= cacheData[ITEM_CACHE_FIELD.EQUIPLOC]

			if not cacheData.link then
				cacheData.link = strformat("|c%s|Hitem:%d:0:0:0:0:0:0:0:%d|h[%s]|h|r", itemQualityHexes[itemRarity] or "ffffffff", cacheData[ITEM_ID_FIELD], itemMinLevel, itemName)
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
				cacheData[ITEM_ID_FIELD],
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
		local cacheWasUsed

		if not itemName then
			if not noRequest then
				C_Item.RequestServerCache(item, callback)
				itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(item)
			end

			if not itemName and not skipClientCache then
				itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID = C_Item.GetItemInfoCache(item)
				cacheWasUsed = true
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
				subClassID = C_Item.GetItemSubClassID(classID, itemSubType)
				equipLocID = C_Item.GetItemEquipLocID(itemEquipLoc)
			end

			return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID, cacheWasUsed or false
		end
	end

	function C_Item.DoesItemExist(itemLocation)
		if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" then
			error("Usage: local itemExist = C_Item.DoesItemExist(itemLocation)", 2);
		end

		if itemLocation:IsValid() then
			return true;
		else
			return false;
		end
	end

	function C_Item.GetItemID(itemLocation)
		if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
			error("Usage: local itemID = C_Item.GetItemID(itemLocation)", 2);
		end

		if itemLocation:IsEquipmentSlot() then
			return GetInventoryItemID("player", itemLocation:GetEquipmentSlot());
		elseif itemLocation:IsBagAndSlot() then
			return GetContainerItemID(itemLocation:GetBagAndSlot());
		end
	end

	function C_Item.GetItemLink(itemLocation)
		if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
			error("Usage: local itemLink = C_Item.GetItemLink(itemLocation)", 2);
		end

		if itemLocation:IsEquipmentSlot() then
			return GetInventoryItemLink("player", itemLocation:GetEquipmentSlot());
		elseif itemLocation:IsBagAndSlot() then
			return GetContainerItemLink(itemLocation:GetBagAndSlot());
		end
	end

	function C_Item.GetItemQuality(itemLocation)
		if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
			error("Usage: local itemQuality = C_Item.GetItemQuality(itemLocation)", 2);
		end

		if itemLocation:IsEquipmentSlot() then
			local itemLink = GetInventoryItemLink("player", itemLocation:GetEquipmentSlot());
			if itemLink then
				local _, _, itemQuality = GetItemInfo(itemLink);
				return itemQuality;
			end
		elseif itemLocation:IsBagAndSlot() then
			local itemLink = GetContainerItemLink(itemLocation:GetBagAndSlot());
			if itemLink then
				local _, _, itemQuality = GetItemInfo(itemLink);
				return itemQuality;
			end
		end
	end

	function C_Item.GetItemIcon(itemLocation)
		if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
			error("Usage: local itemIcon = C_Item.GetItemIcon(itemLocation)", 2);
		end

		if itemLocation:IsEquipmentSlot() then
			local itemID = GetInventoryItemID("player", itemLocation:GetEquipmentSlot());
			if itemID then
				local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemID);
				return itemIcon;
			end
		elseif itemLocation:IsBagAndSlot() then
			local itemID = GetContainerItemID(itemLocation:GetBagAndSlot());
			if itemID then
				local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemID);
				return itemIcon;
			end
		end
	end

	function C_Item.GetItemName(itemLocation)
		if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
			error("Usage: local itemIcon = C_Item.GetItemName(itemLocation)", 2);
		end

		if itemLocation:IsEquipmentSlot() then
			local itemID = GetInventoryItemID("player", itemLocation:GetEquipmentSlot());
			if itemID then
				return (GetItemInfo(itemID));
			end
		elseif itemLocation:IsBagAndSlot() then
			local itemID = GetContainerItemID(itemLocation:GetBagAndSlot());
			if itemID then
				return (GetItemInfo(itemID));
			end
		end
	end

	function C_Item.GetRequiredPVPRating(item, honorPrice, arenaPrice)
		item = getItemID(item, "GetRequiredPVPRating")
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

	if IsInterfaceDevClient() then
		_G.GetItemInfoRaw = GetItemInfo
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
		item = getItemID(item, "GetItemInfoCache")
		if not item then
			return
		end

		local cacheData = ItemsCache[item]
		return cacheData ~= nil
	end

	function C_Item.GetItemLink(itemID)
		local realmID = GetServerID()
		if not ALLOWED_REALMS[realmID] then
			realmID = E_REALM_ID.SCOURGE
		end
		return strformat("https://sirus.su/base/item/%d/%d", itemID, realmID)
	end

	function C_Item.GetItemInfoCache(item)
		item = getItemID(item, "GetItemInfoCache")
		if not item then
			local link
			if type(item) == "number" then
				link = C_Item.GetItemLink(item)
			end
			return UNKNOWN, link, 1, 0, 0, nil, nil, 0, nil, [[Interface\ICONS\INV_Misc_QuestionMark]], 0, 0, 0, 0
		end

		local cacheData = ItemsCache[item]
		if cacheData then
			local itemID		= cacheData[ITEM_ID_FIELD]
			local itemName		= cacheData[LOCALE_INDEX]
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
	if GLUEXML then
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
	end

	for i = 0, 7 do
		local _, _, _, hex = GetItemQualityColor(i)
		itemQualityHexes[i] = hex:sub(3)
	end

	local classID = 0
	local className = _G["ITEM_CLASS_" .. classID]
	while className do
		itemClassMap[className] = classID

		itemSubClassMap[classID] = {}

		local subclassID = 0
		local subclassName = _G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID]
		while subclassName do
			itemSubClassMap[classID][subclassName] = subclassID

			subclassID = subclassID + 1
			subclassName = _G["ITEM_SUB_CLASS_" .. classID .. "_" .. subclassID]
		end

		classID = classID + 1
		className = _G["ITEM_CLASS_" .. classID]
	end

	if ItemsCache1 and not ItemsCache then
		ItemsCache = ItemsCache1
		ItemsCache1 = nil
	end

	if type(ItemsCache) == "table" then
		if type(ItemsCache2) == "table" then
			for itemID, itemData in pairs(ItemsCache2) do
				ItemsCache[itemID] = itemData
			end
			table.wipe(ItemsCache2)
			ItemsCache2 = nil
		end

		local namedItems = {}
		for itemID, itemData in pairs(ItemsCache) do
			itemData[ITEM_ID_FIELD] = itemID

			local itemName = itemData[LOCALE_INDEX]
			if itemName and itemName ~= "" then
				namedItems[itemName] = itemData
			end
		end

		setmetatable(ItemsCache, {__index = namedItems})
	else
		GMError("No ItemCache")
	end
end