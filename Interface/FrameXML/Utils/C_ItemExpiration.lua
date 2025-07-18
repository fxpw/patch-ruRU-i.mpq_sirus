local error = error
local ipairs = ipairs
local type = type
local strformat = string.format
local tinsert, tremove, tsort, twipe = table.insert, table.remove, table.sort, table.wipe

local GetCVarBool = GetCVarBool
local GetContainerItemGUID = GetContainerItemGUID
local GetContainerNumSlots = GetContainerNumSlots
local GetInventoryItemGUID = GetInventoryItemGUID
local GetItemExpirationTimeLeft = GetItemExpirationTimeLeft
local GetItemLocation = GetItemLocation

local C_Item = C_Item
local C_Timer = C_Timer
local FireCustomClientEvent = FireCustomClientEvent
local IsInterfaceDevClient = IsInterfaceDevClient
local RunNextFrame = RunNextFrame

local INVSLOT_FIRST_EQUIPPED = INVSLOT_FIRST_EQUIPPED or 1
local INVSLOT_LAST_EQUIPPED = INVSLOT_LAST_EQUIPPED or 19

local NEAR_EXPIRATION_TIME = SECONDS_PER_DAY * 2
local NUM_BAG_FRAMES = 4

local PRIVATE = {
	ITEMS = {},
}

local ITEM_DATA_FIELD = {
	GUID				= 1,
	EXPIRATION_TIMELEFT	= 2,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.eventHandler:RegisterEvent("BAG_UPDATE")
PRIVATE.eventHandler:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
PRIVATE.eventHandler:RegisterEvent("ITEM_EXPIRATION_TIME_UPDATE")
PRIVATE.eventHandler:SetScript("OnEvent", function(this, event, ...)
	if event == "ITEM_EXPIRATION_TIME_UPDATE" then
		local itemGUID, expirationTimeLeft = ...
		PRIVATE.OnItemExpirationTimeUpdate(itemGUID, expirationTimeLeft)
	elseif event == "BAG_UPDATE" then
		local bagID = ...
		RunNextFrame(PRIVATE.UpdateExpirationItems)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local slotIndex, hasItem = ...
		RunNextFrame(PRIVATE.UpdateExpirationItems)
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isInitialLogin, isReloadingUI = ...
		if isInitialLogin then
			PRIVATE.QUEUE_REMINDER = true
			PRIVATE.QueueReminder()
		end

		RunNextFrame(PRIVATE.UpdateExpirationItems)
	end
end)

PRIVATE.Initialize = function()
	if IsInterfaceDevClient() then
		PRIVATE_IE = PRIVATE
	end
end

PRIVATE.SortByExpiration = function(a, b)
	if a[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT] ~= b[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT] then
		return a[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT] < b[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT]
	end
	return a[ITEM_DATA_FIELD.GUID] < b[ITEM_DATA_FIELD.GUID]
end

PRIVATE.GetCachedItem = function(itemGUID)
	for index, itemData in ipairs(PRIVATE.ITEMS) do
		if itemData[ITEM_DATA_FIELD.GUID] == itemGUID then
			return itemData, index
		end
	end
end

PRIVATE.OnItemExpirationTimeUpdate = function(itemGUID, expirationTimeLeft)
	if expirationTimeLeft > 0 then
		local isInventory, slotIndex, bagID = GetItemLocation(itemGUID)
		if slotIndex
		and (isInventory or bagID >= 0) -- skip bank
		then
			local itemData, index = PRIVATE.GetCachedItem(itemGUID)
			local itemID = C_Item.GetItemIDByGUID(itemGUID)
			if itemID and not C_Item.IsItemExpirationBlacklisted(itemID) then
				if itemData then
					itemData[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT] = expirationTimeLeft
				else
					itemData = {
						[ITEM_DATA_FIELD.GUID]					= itemGUID,
						[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT]	= expirationTimeLeft,
					}

					tinsert(PRIVATE.ITEMS, itemData)
				end

				tsort(PRIVATE.ITEMS, PRIVATE.SortByExpiration)
				PRIVATE.QueueReminder()
				FireCustomClientEvent("CONTAINER_ITEM_EXPIRATION_UPDATE")
			end
		end
	else
		local itemData, index = PRIVATE.GetCachedItem(itemGUID)
		if index then
			tremove(PRIVATE.ITEMS, index)
			FireCustomClientEvent("CONTAINER_ITEM_EXPIRATION_UPDATE")
		end
	end
end

PRIVATE.UpdateExpirationItems = function()
	twipe(PRIVATE.ITEMS)

	for slotIndex = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemGUID = GetInventoryItemGUID("player", slotIndex)
		if itemGUID then
			local itemID = C_Item.GetItemIDByGUID(itemGUID)
			if itemID and not C_Item.IsItemExpirationBlacklisted(itemID) then
				local hasExpiration, expirationTimeLeft = GetItemExpirationTimeLeft(itemGUID)
				if hasExpiration and expirationTimeLeft > 0 then
					tinsert(PRIVATE.ITEMS, {
						[ITEM_DATA_FIELD.GUID]					= itemGUID,
						[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT]	= expirationTimeLeft,
					})
				end
			end
		end
	end

	for bagID = 0, NUM_BAG_FRAMES do
		for slotIndex = 1, GetContainerNumSlots(bagID) do
			local itemGUID = GetContainerItemGUID(bagID, slotIndex)
			if itemGUID then
				local itemID = C_Item.GetItemIDByGUID(itemGUID)
				if itemID and not C_Item.IsItemExpirationBlacklisted(itemID) then
					local hasExpiration, expirationTimeLeft = GetItemExpirationTimeLeft(itemGUID)
					if hasExpiration and expirationTimeLeft > 0 then
						tinsert(PRIVATE.ITEMS, {
							[ITEM_DATA_FIELD.GUID]					= itemGUID,
							[ITEM_DATA_FIELD.EXPIRATION_TIMELEFT]	= expirationTimeLeft,
						})
					end
				end
			end
		end
	end

	tsort(PRIVATE.ITEMS, PRIVATE.SortByExpiration)

	FireCustomClientEvent("CONTAINER_ITEM_EXPIRATION_UPDATE")
end

PRIVATE.CanShowReminder = function()
	if not GetCVarBool("itemExpirationReminder") then
		return false
	end
	return true
end

PRIVATE.QueueReminder = function()
	if PRIVATE.TIMER then
		PRIVATE.TIMER:Cancel()
		PRIVATE.TIMER = nil
	end

	if (not PRIVATE.QUEUE_REMINDER or #PRIVATE.ITEMS == 0)
	or not PRIVATE.CanShowReminder()
	then
		return
	end

	PRIVATE.TIMER = C_Timer:After(1, PRIVATE.FireReminder)
end

PRIVATE.FireReminder = function()
	PRIVATE.TIMER = nil

	if PRIVATE.CanShowReminder() then
		PRIVATE.QUEUE_REMINDER = nil

		if PRIVATE.HasNearExpiredItems() then
			FireCustomClientEvent("CONTAINER_ITEM_EXPIRATION_REMIND")
		end
	end
end

PRIVATE.HasNearExpiredItems = function()
	for index, itemInfo in ipairs(PRIVATE.ITEMS) do
		local hasExpiration, expirationTimeLeft = GetItemExpirationTimeLeft(itemInfo[ITEM_DATA_FIELD.GUID])
		if expirationTimeLeft <= NEAR_EXPIRATION_TIME then
			return true
		end
	end
	return false
end

PRIVATE.Initialize()

C_ItemExpiration = {}

function C_ItemExpiration.HasNearExpiredItems()
	return PRIVATE.HasNearExpiredItems()
end

function C_ItemExpiration.GetNumExpirationItems()
	return #PRIVATE.ITEMS
end

function C_ItemExpiration.GetExpirationItemInfo(index)
	if type(index) ~= "number" then
		error(strformat("bad argument #1 to 'C_ItemExpiration.GetExpirationItemSlot' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	elseif index < 0 or index > #PRIVATE.ITEMS then
		error(strformat("bad argument #1 to 'C_ItemExpiration.GetExpirationItemSlot' (index %s out of range)", index), 2)
	end

	local itemData = PRIVATE.ITEMS[index]
	if itemData then
		local itemGUID = itemData[ITEM_DATA_FIELD.GUID]
		local hasExpiration, expirationTimeLeft = GetItemExpirationTimeLeft(itemGUID)
		return itemGUID, expirationTimeLeft
	end
end