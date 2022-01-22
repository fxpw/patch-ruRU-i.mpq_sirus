--	Filename:	C_Item.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_ItemMixin = {}

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

function C_ItemMixin:Init()
    self.cacheTooltip   = CreateFrame("GameTooltip")
    self.updateFrame    = CreateFrame("Frame")
    self._GetItemInfo   = GetItemInfo

    local function OnUpdate()
        self:OnUpdate()
    end

    self.updateFrame:SetScript("OnUpdate", OnUpdate)

    self.itemCacheQueue = {}

    if ItemsCache then
        local addedCache = {}
        for itemEntry, itemData in pairs(ItemsCache) do
            xpcall(function()
                if not itemData.itemEntry then
                    itemData.itemEntry = itemEntry
                    addedCache[ itemData[self:GetLocaleIndex()] ] = itemData
                end
            end, function(...)
                printec(...)
                return
            end)
        end

        for k,v in pairs(addedCache) do
            ItemsCache[k] = v
        end
    else
        printec("--- No ItemCache")
    end
end

function C_ItemMixin:OnUpdate()
    if #self.itemCacheQueue == 0 then
        return
    end

    for i = #self.itemCacheQueue, 1, -1 do
        local callbackData = self.itemCacheQueue[i]

        if callbackData then
            local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = self._GetItemInfo(callbackData.itemEntry)

            if itemName then
                callbackData.func(itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, callbackData.itemEntry)
                table.remove(self.itemCacheQueue, i)
            end
        end
    end
end

function C_ItemMixin:GetLocaleIndex()
    return GetLocale() == "ruRU" and E_ITEM_INFO.NAME_RURU or E_ITEM_INFO.NAME_ENGB
end

---@param itemEntry number | string
---@param callbackFunc function
function C_ItemMixin:RequestServerCache( itemEntry, callbackFunc )
    itemEntry = tonumber(itemEntry)

    if itemEntry then
        if callbackFunc then
            table.insert(self.itemCacheQueue, {itemEntry = itemEntry, func = callbackFunc})
        end

        self.cacheTooltip:SetHyperlink("Hitem:"..itemEntry)
    end
end

---@param itemIdentifier number | string
---@return table itemData
function C_ItemMixin:GetItemInfoFromCache( itemIdentifier )
    assert(itemIdentifier, "C_ItemMixin.GetItemInfoFromCache: Не найден itemIdentifier")

    local identifier    = tonumber(itemIdentifier) or tonumber(string.match(itemIdentifier, "Hitem:(%d+)")) or itemIdentifier
    local cacheData     = ItemsCache[identifier]
    local itemData      = {}

    if cacheData and cacheData.itemEntry then
        itemData.name           = cacheData[self:GetLocaleIndex()]
        itemData.rarity         = cacheData[E_ITEM_INFO.RARITY]
        itemData.iLevel         = cacheData[E_ITEM_INFO.ILEVEL]
        itemData.mLevel         = cacheData[E_ITEM_INFO.MINLEVEL]
        itemData.type           = _G["ITEM_CLASS_"..cacheData[E_ITEM_INFO.TYPE]]
        itemData.subType        = _G[string.format("ITEM_SUB_CLASS_%d_%d", cacheData[E_ITEM_INFO.TYPE], cacheData[E_ITEM_INFO.SUBTYPE])]
        itemData.stackCount     = cacheData[E_ITEM_INFO.STACKCOUNT]
        itemData.equipLoc       = SHARED_INVTYPE_BY_ID[cacheData[E_ITEM_INFO.EQUIPLOC]]
        itemData.vendorPrice    = cacheData[E_ITEM_INFO.VENDORPRICE]
        itemData.texture        = "Interface\\Icons\\"..cacheData[E_ITEM_INFO.TEXTURE]

        local r, g, b = GetItemQualityColor(itemData.rarity)
        itemData.link = CreateColor(r, g, b):WrapTextInColorCode(string.format("|Hitem:%d:0:0:0:0:0:0:0:%d|h[%s]|h", cacheData.itemEntry, itemData.mLevel, itemData.name))

        return itemData
    end
end

---@param itemIdentifier  number | string
---@param skipClientCache boolean
---@param callbackFunc function
---@return string itemName
---@return string itemLink
---@return number itemRarity
---@return number itemLevel
---@return number itemMinLevel
---@return string itemType
---@return string itemSubType
---@return number itemStackCount
---@return string itemEquipLoc
---@return string itemTexture
---@return number vendorPrice
function C_ItemMixin:GetItemInfo( itemIdentifier, skipClientCache, callbackFunc )
    if not itemIdentifier then
        return
    end

    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = self._GetItemInfo(itemIdentifier)

    if not itemName then
        self:RequestServerCache(itemIdentifier, callbackFunc)

        itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = self._GetItemInfo(itemIdentifier)

        if (not skipClientCache and GetServerID() ~= REALM_ID_SIRUS) and not itemName then
            local cacheData = C_ItemMixin:GetItemInfoFromCache(itemIdentifier)

            if cacheData then
                itemName        = cacheData.name
                itemLink        = cacheData.link
                itemRarity      = cacheData.rarity
                itemLevel       = cacheData.iLevel
                itemMinLevel    = cacheData.mLevel
                itemType        = cacheData.type
                itemSubType     = cacheData.subType
                itemStackCount  = cacheData.stackCount
                itemEquipLoc    = cacheData.equipLoc
                itemTexture     = cacheData.texture
                vendorPrice     = cacheData.vendorPrice
            end
        end
    end

    local unitFaction = UnitFactionGroup("player")

    if unitFaction and itemLink then
        local itemEntry = string.match(itemLink, "|Hitem:(%d+)")

        if itemEntry then
            itemEntry = tonumber(itemEntry)

            if itemEntry == 43308 then
                itemTexture = "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction
            elseif itemEntry == 43307 then
                itemTexture = "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction
            end
        end
    end

    return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice
end

---@class C_ItemMixin
C_Item = CreateFromMixins(C_ItemMixin)
C_Item:Init()

function GetItemInfo( itemIdentifier, skipClientCache, callbackFunc )
    return C_Item:GetItemInfo( itemIdentifier, skipClientCache, callbackFunc )
end