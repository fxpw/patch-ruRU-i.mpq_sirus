Enum = Enum or {};
Enum.TransmogModification = {Main = 0, Secondary = 1};
Enum.TransmogPendingType = {Apply = 0, Revert = 1, ToggleOn = 2, ToggleOff = 3};
Enum.TransmogType = {Appearance = 0, Illusion = 1};

TRANSMOG_INVALID_CODES = {
	"NO_ITEM",
	"NOT_SOULBOUND",
	"LEGENDARY",
	"ITEM_TYPE",
	"DESTINATION",
	"MISMATCH",
	"",		-- same item
	"",		-- invalid source
	"",		-- invalid source quality
	"CANNOT_USE",
	"SLOT_FOR_RACE",
}

local TRANSMOG_SLOTS = {
	[1] = "HEADSLOT",
	[3] = "SHOULDERSLOT",
	[4] = "SHIRTSLOT",
	[5] = "CHESTSLOT",
	[6] = "WAISTSLOT",
	[7] = "LEGSSLOT",
	[8] = "FEETSLOT",
	[9] = "WRISTSLOT",
	[10] = "HANDSSLOT",
	[15] = "BACKSLOT",
	[16] = "MAINHANDSLOT",
	[17] = "SECONDARYHANDSLOT",
	[18] = "RANGEDSLOT",
	[19] = "TABARDSLOT",
}

local TRANSMOGRIFY_INFO = {};
local PENDING_INFO = {};

local function SetPending(transmogLocation, pendingInfo)
	local slotID = transmogLocation.slotID;
	local baseSourceID = GetInventoryItemID("player", slotID);
	local baseVisualID = baseSourceID and ITEM_MODIFIED_APPEARANCE_STORAGE[baseSourceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[baseSourceID][1] or 0;

	if pendingInfo.type == Enum.TransmogPendingType.Revert then
		PENDING_INFO[slotID] = PENDING_INFO[slotID] and table.wipe(PENDING_INFO[slotID]) or {};

		PENDING_INFO[slotID].transmogID = 0;
		PENDING_INFO[slotID].visualID = 0;
		PENDING_INFO[slotID].isPendingCollected = false;
		PENDING_INFO[slotID].canTransmogrify = false;
		PENDING_INFO[slotID].hasUndo = true;
		PENDING_INFO[slotID].cost = 0;
		PENDING_INFO[slotID].hasPending = true;
		PENDING_INFO[slotID].type = pendingInfo.type;
		PENDING_INFO[slotID].category = pendingInfo.category;
		PENDING_INFO[slotID].subCategory = pendingInfo.subCategory;

		local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
		eventTransmogLocation:Set(slotID, transmogLocation.type, transmogLocation.modification);
		return eventTransmogLocation, "clear";
	elseif pendingInfo.type == Enum.TransmogPendingType.Apply then
		local pendingSourceID = pendingInfo.transmogID;
		local pendingVisualID = pendingSourceID and ITEM_MODIFIED_APPEARANCE_STORAGE[pendingSourceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[pendingSourceID][1] or 0;

		local appliedSourceID = TRANSMOGRIFY_INFO[slotID] and TRANSMOGRIFY_INFO[slotID].transmogID;
		local appliedVisualID = appliedSourceID and ITEM_MODIFIED_APPEARANCE_STORAGE[appliedSourceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[appliedSourceID][1] or 0;

		PENDING_INFO[slotID] = PENDING_INFO[slotID] and table.wipe(PENDING_INFO[slotID]) or {};

		if pendingVisualID == baseVisualID then
			if appliedSourceID and appliedVisualID then
				PENDING_INFO[slotID].transmogID = 0;
				PENDING_INFO[slotID].visualID = 0;
				PENDING_INFO[slotID].isPendingCollected = false;
				PENDING_INFO[slotID].canTransmogrify = false;
				PENDING_INFO[slotID].hasUndo = true;
				PENDING_INFO[slotID].cost = 0;
				PENDING_INFO[slotID].hasPending = true;
				PENDING_INFO[slotID].type = Enum.TransmogPendingType.Revert;
				PENDING_INFO[slotID].category = pendingInfo.category;
				PENDING_INFO[slotID].subCategory = pendingInfo.subCategory;

				local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
				eventTransmogLocation:Set(slotID, transmogLocation.type, transmogLocation.modification);
				return eventTransmogLocation, "clear";
			else
				PENDING_INFO[slotID] = nil;

				local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
				eventTransmogLocation:Set(slotID, transmogLocation.type, transmogLocation.modification);
				return eventTransmogLocation, "clear";
			end
		elseif pendingVisualID ~= appliedVisualID then
			if IsStoreRefundableItem(pendingInfo.transmogID) then
				local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(pendingInfo.transmogID);
				PENDING_INFO[slotID].warning = {
					itemName = itemName,
					itemLink = itemLink,
					itemQuality = itemQuality,
					itemIcon = itemIcon,
					text = STORY_END_REFUND,
				};
			end

			PENDING_INFO[slotID].transmogID = pendingSourceID;
			PENDING_INFO[slotID].visualID = pendingVisualID;
			PENDING_INFO[slotID].type = pendingInfo.type;
			PENDING_INFO[slotID].category = pendingInfo.category;
			PENDING_INFO[slotID].subCategory = pendingInfo.subCategory;
			PENDING_INFO[slotID].transmogType = transmogLocation.type;
			PENDING_INFO[slotID].transmogModification = transmogLocation.modification;

			SendServerMessage("ACMSG_TRANSMOGRIFICATION_PREPARE_REQUEST", string.format("%d:%d", slotID, pendingInfo.transmogID));
		else
			PENDING_INFO[slotID] = nil;

			local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
			eventTransmogLocation:Set(slotID, transmogLocation.type, transmogLocation.modification);
			return eventTransmogLocation, "clear";
		end
	end
end

C_Transmog = {}

function C_Transmog.ApplyAllPending()
	local text = "";
	for slotID, pendingInfo in pairs(PENDING_INFO) do
		if pendingInfo.transmogID and pendingInfo.type == Enum.TransmogPendingType.Apply then
			text = text..slotID..":"..pendingInfo.transmogID..";";
		elseif pendingInfo.type == Enum.TransmogPendingType.Revert then
			text = text..slotID..":0;";
		end
	end
	SendAddonMessage("ACMSG_TRANSMOGRIFICATION_APPLY", text, "WHISPER", UnitName("player"));
end

function C_Transmog.CanTransmogItem()

end

function C_Transmog.CanTransmogItemWithItem()

end

function C_Transmog.ClearAllPending()
	table.wipe(PENDING_INFO);
end

function C_Transmog.ClearPending(transmogLocation)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" then
		error("Usage: C_Transmog.ClearPending(transmogLocation)", 2);
	end

	local pendingInfo = PENDING_INFO[transmogLocation.slotID]
	if pendingInfo then
		PENDING_INFO[transmogLocation.slotID] = nil;

		local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
		eventTransmogLocation:Set(transmogLocation.slotID, transmogLocation.type, transmogLocation.modification);
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, eventTransmogLocation, "clear");
	end
end

function C_Transmog.Close()
	table.wipe(TRANSMOGRIFY_INFO);
	table.wipe(PENDING_INFO);
end

function C_Transmog.GetApplyCost()
	local cost;
	for _, pendingInfo in pairs(PENDING_INFO) do
		cost = (cost or 0) + (pendingInfo.cost or 0);
	end
	return cost;
end

function C_Transmog.GetApplyWarnings()
	local warnings = {};

	for _, transmogInfo in pairs(PENDING_INFO) do
		local warning = transmogInfo.warning;
		if warning then
			warnings[#warnings + 1] = {
				itemName = warning.itemName,
				itemLink = warning.itemLink,
				itemQuality = warning.itemQuality,
				itemIcon = warning.itemIcon,
				text = warning.text,
			};
		end
	end

	return warnings;
end

function C_Transmog.GetPending(transmogLocation)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local pendingInfo = C_Transmog.GetPending(transmogLocation)", 2);
	end

	local pendingInfo = PENDING_INFO[transmogLocation.slotID];
	return pendingInfo and {
		type = pendingInfo.type,
		transmogID = pendingInfo.transmogID,
		category = pendingInfo.category,
		subCategory = pendingInfo.subCategory,
	};
end

function C_Transmog.GetSlotEffectiveCategory(transmogLocation)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local categoryID, subCategoryID = C_Transmog.GetSlotEffectiveCategory(transmogLocation)", 2);
	end

	local pendingInfo = PENDING_INFO[transmogLocation.slotID];
	if pendingInfo and pendingInfo.category then
		return pendingInfo.category, pendingInfo.subCategory;
	end

	local transmogInfo = TRANSMOGRIFY_INFO[transmogLocation.slotID];
	if transmogInfo and transmogInfo.category then
		return transmogInfo.category, transmogInfo.subCategory;
	end

	local itemID = GetInventoryItemID("player", transmogLocation.slotID);
	local categoryID, subCategoryID = GetItemModifiedAppearanceCategoryInfo(itemID);
	if categoryID ~= 0 then
		return categoryID, subCategoryID;
	end

	return 0, nil;
end

function C_Transmog.GetSlotForInventoryType(inventoryType)
	if type(inventoryType) == "string" then
		inventoryType = tonumber(inventoryType);
	end
	if type(inventoryType) ~= "number" then
		error("Usage: local slot = C_Transmog.GetSlotForInventoryType(inventoryType)", 2);
	end
end

local nonTransmogrifyInvType = {
	[0] = "",
	[2] = "INVTYPE_NECK",
	[11] = "INVTYPE_FINGER",
	[12] = "INVTYPE_TRINKET",
	[18] = "INVTYPE_BAG",
	[24] = "INVTYPE_AMMO",
	[27] = "INVTYPE_QUIVER",
	[28] = "INVTYPE_RELIC",
}

function C_Transmog.GetSlotInfo(transmogLocation)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = C_Transmog.GetSlotInfo(transmogLocation)", 2);
	end

	local texture = GetInventoryItemTexture("player", transmogLocation.slotID);
	local itemID = GetInventoryItemID("player", transmogLocation.slotID);
	if not texture then
		return false, false, false, false, 1, false, false, false;
	end

	local transmogInfo = TRANSMOGRIFY_INFO[transmogLocation.slotID];
	local isTransmogrified = transmogInfo and transmogInfo.isTransmogrified or false;

	local hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual = false, false, true, 0, false, false;

	local pendingInfo = PENDING_INFO[transmogLocation.slotID];
	if pendingInfo then
		hasPending = pendingInfo.hasPending;
		isPendingCollected = pendingInfo.isPendingCollected;
		canTransmogrify = pendingInfo.canTransmogrify;
		hasUndo = pendingInfo.hasUndo;
	else
		local itemCache = itemID and ItemsCache[itemID];
		if itemCache then
			local invType = itemCache[9];
			if nonTransmogrifyInvType[invType] or ((itemCache[3] < 2 or itemCache[3] > 5) and invType ~= 4) then
				canTransmogrify = false;
			else
				canTransmogrify = true;
			end
		else
			canTransmogrify = false;
		end
	end

	if hasPending then
		if canTransmogrify then
			texture = select(10, GetItemInfo(pendingInfo.transmogID));
		end
	elseif isTransmogrified then
		texture = select(10, GetItemInfo(transmogInfo.transmogID));
	end

	return isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture;
end

function C_Transmog.GetSlotUseError(transmogLocation)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local errorCode, errorString = C_Transmog.GetSlotUseError(transmogLocation)", 2);
	end
end

function C_Transmog.GetSlotVisualInfo(transmogLocation)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, isHideVisual, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation)", 2);
	end

	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, itemSubclass;
	local hasPendingUndo, isHideVisual = false, false;
	local itemID = GetInventoryItemID("player", transmogLocation.slotID);

	if itemID then
		baseSourceID = itemID;
		baseVisualID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][1] or 0;
		itemSubclass = ItemsCache[itemID] and ItemsCache[itemID][7] or 0;
	else
		baseSourceID = 0;
		baseVisualID = 0;
		itemSubclass = 0;
	end

	local appliedInfo = TRANSMOGRIFY_INFO[transmogLocation.slotID];
	if appliedInfo then
		appliedSourceID = appliedInfo.transmogID;
		appliedVisualID = appliedInfo.visualID;
	else
		appliedSourceID = 0;
		appliedVisualID = 0;
	end

	local pendingInfo = PENDING_INFO[transmogLocation.slotID];
	if pendingInfo then
		pendingSourceID = pendingInfo.transmogID;
		pendingVisualID = pendingInfo.visualID;
		hasPendingUndo = pendingInfo.hasUndo;
	else
		pendingSourceID = 0;
		pendingVisualID = 0;
	end

	return baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, isHideVisual, itemSubclass;
end

function C_Transmog.IsAtTransmogNPC()
	return WardrobeFrame and WardrobeFrame:IsShown();
end

function C_Transmog.LoadOutfit(outfitID)
	local itemTransmogInfoList = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] and SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].itemList;
	if itemTransmogInfoList then
		for slotID, transmogID in pairs(itemTransmogInfoList) do
			if transmogID ~= NO_TRANSMOG_SOURCE_ID then
				local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, transmogID);
				SetPending(TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main), pendingInfo);
			end
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE);
end

function C_Transmog.SetPending(transmogLocation, pendingInfo)
	if not transmogLocation or type(transmogLocation.slotID) ~= "number" or not pendingInfo or type(pendingInfo.transmogID) ~= "number" then
		error("Usage: C_Transmog.SetPending(transmogLocation, pendingInfo)", 2);
	end

	local location, action = SetPending(transmogLocation, pendingInfo);
	if location and action then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, location, action);
	end
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_OPEN(msg)
	SendServerMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST");

	for _, block in pairs({strsplit(";", msg)}) do
		local slotID, transmogID = strsplit(":", block);
		slotID = tonumber(slotID);
		transmogID = tonumber(transmogID);

		if slotID and TRANSMOG_SLOTS[slotID] and transmogID then
			local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID];
			local category, subCategory = GetItemModifiedAppearanceCategoryInfo(transmogID, true);

			if sourceInfo then
				TRANSMOGRIFY_INFO[slotID] = {
					isTransmogrified = true,
					slotID = slotID,
					transmogID = transmogID,
					visualID = sourceInfo[1];
					category = category;
					subCategoryID = subCategory;
				};
			end
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_OPEN);
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_CLOSE(msg)
	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_CLOSE);
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_PREPARE_RESPONSE(msg)
	local slotID, transmogID, errorType, cost = strsplit(":", msg);
	slotID = tonumber(slotID);
	transmogID = tonumber(transmogID);
	errorType = tonumber(errorType);

	if slotID and transmogID and PENDING_INFO[slotID] then
		if errorType == 0 then
			PENDING_INFO[slotID].transmogID = transmogID;
			PENDING_INFO[slotID].visualID = ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID] and ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID][1] or 0;

			PENDING_INFO[slotID].isPendingCollected = true;
			PENDING_INFO[slotID].canTransmogrify = true;
			PENDING_INFO[slotID].hasPending = true;
			PENDING_INFO[slotID].hasUndo = false;
			PENDING_INFO[slotID].errorType = errorType;
			PENDING_INFO[slotID].cost = tonumber(cost) or 0;

			local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
			eventTransmogLocation:Set(slotID, PENDING_INFO[slotID].transmogType, PENDING_INFO[slotID].transmogModification);
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, eventTransmogLocation, "set");
		else
			local error = _G["TRANSMOGRIFY_ERROR_"..errorType];
			if error then
				UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
			end

			local transmogType = PENDING_INFO[slotID].transmogType or 0;
			local transmogModification = PENDING_INFO[slotID].transmogModification or 0;

			PENDING_INFO[slotID] = nil;

			local eventTransmogLocation = CreateFromMixins(TransmogLocationMixin);
			eventTransmogLocation:Set(slotID, transmogType, transmogModification);
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, eventTransmogLocation, "clear");
		end
	end
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_APPLY_RESPONSE(msg)
	msg = tonumber(msg);

	if msg == 0 then
		for slotID, transmogInfo in pairs(PENDING_INFO) do
			if transmogInfo.type == Enum.TransmogPendingType.Apply then
				TRANSMOGRIFY_INFO[slotID] = TRANSMOGRIFY_INFO[slotID] or {};
				TRANSMOGRIFY_INFO[slotID].isTransmogrified = true;
				TRANSMOGRIFY_INFO[slotID].slotID = slotID;
				TRANSMOGRIFY_INFO[slotID].transmogID = transmogInfo.transmogID;
				TRANSMOGRIFY_INFO[slotID].visualID = ITEM_MODIFIED_APPEARANCE_STORAGE[transmogInfo.transmogID] and ITEM_MODIFIED_APPEARANCE_STORAGE[transmogInfo.transmogID][1] or 0;
			elseif transmogInfo.type == Enum.TransmogPendingType.Revert then
				TRANSMOGRIFY_INFO[slotID] = nil;
			end

			local slotDescriptor = TRANSMOG_SLOTS[slotID];
			if slotDescriptor then
				local transmogLocation = TransmogUtil.CreateTransmogLocation(slotDescriptor, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);

				FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_SUCCESS, transmogLocation);
			end
		end

		table.wipe(PENDING_INFO);
	else
		local error = _G["TRANSMOGRIFY_ERROR_"..msg];
		if error then
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

