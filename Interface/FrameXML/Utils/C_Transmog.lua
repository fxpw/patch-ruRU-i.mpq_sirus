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

local function IsAtTransmogNPC()
	return WardrobeFrame and WardrobeFrame:IsShown();
end

local TRANSMOG_INFO = {
	Applied = {},
	Pending = {},

	Clear = function(self, name, slotID, transmogType)
		if slotID then
			if self[name][slotID] then
				if transmogType then
					if self[name][slotID][transmogType] then
						self[name][slotID][transmogType] = nil;
					end
				else
					self[name][slotID] = nil;
				end
			end
		else
			table.wipe(self[name]);
		end
	end,

	Get = function(self, name, slotID, transmogType, createOrWipeTable)
		if slotID then
			if createOrWipeTable then
				if not self[name][slotID] then
					self[name][slotID] = {};
				elseif not transmogType then
					table.wipe(self[name][slotID]);
				end
			end
			if transmogType then
				if createOrWipeTable then
					if not self[name][slotID][transmogType] then
						self[name][slotID][transmogType] = {};
					else
						table.wipe(self[name][slotID][transmogType]);
					end
				end

				return self[name] and self[name][slotID] and self[name][slotID][transmogType];
			else
				return self[name] and self[name][slotID];
			end
		else
			return self[name];
		end
	end,
};

local function GetTransmogSlotInfo(slotID, transmogType, ignoreItem)
	local baseSourceID, pendingSourceID, appliedSourceID, hasPendingUndo = 0, 0, 0;

	if transmogType == Enum.TransmogType.Appearance then
		if not ignoreItem then
			local itemID = GetInventoryItemID("player", slotID);
			if itemID then
				baseSourceID = itemID;
			end
		end

		local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogType);
		if pendingData then
			pendingSourceID = pendingData.transmogID;
			hasPendingUndo = pendingData.hasUndo;
		end

		local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogType);
		if appliedData then
			appliedSourceID = appliedData.transmogID;
		end
	else
		if not ignoreItem then
			local itemLink = GetInventoryItemLink("player", slotID);
			if itemLink then
				local enchantID = string.match(itemLink, "item:%d+:(%d+)");
				enchantID = tonumber(enchantID);
				if enchantID then
					baseSourceID = enchantID;
				end
			end
		end

		local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogType);
		if pendingData then
			pendingSourceID = pendingData.transmogID;
			hasPendingUndo = pendingData.hasUndo;
		end

		local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogType);
		if appliedData then
			appliedSourceID = appliedData.transmogID;
		end
	end

	if appliedSourceID == NO_TRANSMOG_SOURCE_ID then
		appliedSourceID = baseSourceID;
	end

	local selectedSourceID;
	if hasPendingUndo then
		selectedSourceID = REMOVE_TRANSMOG_ID;
	elseif pendingSourceID ~= REMOVE_TRANSMOG_ID then
		selectedSourceID = pendingSourceID;
	else
		selectedSourceID = appliedSourceID;
	end

	return selectedSourceID;
end

local function SetPending(transmogLocation, pendingInfo)
	local slotID = transmogLocation.slotID;
	local transmogType = transmogLocation.type;
	local transmogID = pendingInfo.transmogID;

	local isAppearance = transmogLocation:IsAppearance();

	if pendingInfo.type == Enum.TransmogPendingType.Revert then
		local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogType, true);
		pendingData.transmogID = 0;
		pendingData.visualID = 0;
		pendingData.isPendingCollected = false;
		pendingData.canTransmogrify = true;
		pendingData.hasUndo = true;
		pendingData.cost = 0;
		pendingData.hasPending = true;
		pendingData.pendingType = pendingInfo.type;
		pendingData.category = pendingInfo.category;
		pendingData.subCategory = pendingInfo.subCategory;

		return CreateAndSetFromMixin(TransmogLocationMixin, slotID, transmogType, transmogLocation.modification), "clear";
	elseif pendingInfo.type == Enum.TransmogPendingType.Apply then
		local baseSourceID, baseVisualID, pendingSourceID, pendingVisualID, appliedSourceID, appliedVisualID = 0, 0, 0, 0, 0, 0;

		if isAppearance then
			local itemID = GetInventoryItemID("player", slotID);
			if itemID then
				baseSourceID = itemID;
				baseVisualID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][1] or 0;
			end

			if transmogID then
				pendingSourceID = transmogID;
				pendingVisualID = ITEM_MODIFIED_APPEARANCE_STORAGE[pendingSourceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[pendingSourceID][1] or 0;
			end

			local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogType);
			if appliedData then
				appliedSourceID = appliedData.transmogID;
				appliedVisualID = ITEM_MODIFIED_APPEARANCE_STORAGE[appliedSourceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[appliedSourceID][1] or 0;
			end
		else
			local itemLink = GetInventoryItemLink("player", slotID);
			if itemLink then
				local enchantID = string.match(itemLink, "item:%d+:(%d+)");
				enchantID = tonumber(enchantID);
				if enchantID then
					baseSourceID = enchantID;
					baseVisualID = enchantID;
				end
			end

			if transmogID then
				pendingSourceID = transmogID;
				pendingVisualID = transmogID;
			end

			local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogType);
			if appliedData then
				appliedSourceID = appliedData.transmogID;
				appliedVisualID = appliedData.transmogID;
			end
		end

		if pendingVisualID == baseVisualID then
			if appliedSourceID and appliedSourceID ~= 0 and appliedVisualID then
				local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogType, true);
				pendingData.transmogID = 0;
				pendingData.visualID = 0;
				pendingData.isPendingCollected = false;
				pendingData.canTransmogrify = true;
				pendingData.hasUndo = true;
				pendingData.cost = 0;
				pendingData.hasPending = true;
				pendingData.pendingType = Enum.TransmogPendingType.Revert;
				pendingData.category = pendingInfo.category;
				pendingData.subCategory = pendingInfo.subCategory;

				return CreateAndSetFromMixin(TransmogLocationMixin, slotID, transmogType, transmogLocation.modification), "clear";
			else
				TRANSMOG_INFO:Clear("Pending", slotID, transmogType);

				return CreateAndSetFromMixin(TransmogLocationMixin, slotID, transmogType, transmogLocation.modification), "clear";
			end
		elseif pendingVisualID ~= appliedVisualID then
			local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogType, true);

			if isAppearance and IsStoreRefundableItem(pendingSourceID) then
				local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(pendingSourceID);
				pendingData.warning = {
					itemName = itemName,
					itemLink = itemLink,
					itemQuality = itemQuality,
					itemIcon = itemIcon,
					text = STORY_END_REFUND,
				};
			end

			pendingData.hasPending = false;
			pendingData.transmogID = pendingSourceID;
			pendingData.visualID = pendingVisualID;
			pendingData.pendingType = pendingInfo.type;
			pendingData.category = pendingInfo.category;
			pendingData.subCategory = pendingInfo.subCategory;
			pendingData.transmogType = transmogType;
			pendingData.transmogModification = transmogLocation.modification;

			if not isAppearance then
				SendServerMessage("ACMSG_TRANSMOGRIFICATION_PREPARE_REQUEST", string.format("%d:%d:%d", slotID, GetTransmogSlotInfo(slotID, Enum.TransmogType.Appearance), pendingSourceID));
			else
				SendServerMessage("ACMSG_TRANSMOGRIFICATION_PREPARE_REQUEST", string.format("%d:%d:%d", slotID, pendingSourceID, GetTransmogSlotInfo(slotID, Enum.TransmogType.Illusion, true)));
			end
		else
			TRANSMOG_INFO:Clear("Pending", slotID, transmogType);

			return CreateAndSetFromMixin(TransmogLocationMixin, slotID, transmogType, transmogLocation.modification), "clear";
		end
	end
end

C_Transmog = {}

function C_Transmog.ApplyAllPending()
	local text = "";

	for slotID, transmogData in pairs(TRANSMOG_INFO:Get("Pending")) do
		local itemID, enchantID;
		for transmogType, pendingInfo in pairs(transmogData) do
			if pendingInfo.hasPending then
				if transmogType == Enum.TransmogType.Appearance then
					itemID = pendingInfo.transmogID;
				elseif transmogType == Enum.TransmogType.Illusion then
					enchantID = pendingInfo.transmogID;
				end
			end
		end

		if enchantID and (slotID == 16 or slotID == 17) then
			if not itemID then
				itemID = GetTransmogSlotInfo(slotID, Enum.TransmogType.Appearance);
			end

			text = text..slotID..":"..(itemID or 0)..":"..(enchantID or 0)..";";
		elseif itemID then
			text = text..slotID..":"..(itemID or 0)..";";
		end
	end

	SendServerMessage("ACMSG_TRANSMOGRIFICATION_APPLY", text);
end

function C_Transmog.CanTransmogItem()

end

function C_Transmog.CanTransmogItemWithItem()

end

function C_Transmog.ClearAllPending()
	TRANSMOG_INFO:Clear("Pending");
end

function C_Transmog.ClearPending(transmogLocation)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" then
		error("Usage: C_Transmog.ClearPending(transmogLocation)", 2);
	end

	local pendingData = TRANSMOG_INFO:Get("Pending", transmogLocation.slotID, transmogLocation.type);
	if pendingData then
		TRANSMOG_INFO:Clear("Pending", transmogLocation.slotID, transmogLocation.type);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, CreateAndSetFromMixin(TransmogLocationMixin, transmogLocation.slotID, transmogLocation.type, transmogLocation.modification), "clear");
	end
end

function C_Transmog.Close()
	TRANSMOG_INFO:Clear("Applied");
	TRANSMOG_INFO:Clear("Pending");
end

function C_Transmog.GetApplyCost()
	local cost;

	for _, transmogData in pairs(TRANSMOG_INFO:Get("Pending")) do
		for _, pendingInfo in pairs(transmogData) do
			if pendingInfo.transmogID then
				cost = (cost or 0) + (pendingInfo.cost or 0);
			end
		end
	end

	return cost;
end

function C_Transmog.GetApplyWarnings()
	local warnings = {};

	for _, transmogData in pairs(TRANSMOG_INFO:Get("Pending")) do
		for _, pendingInfo in pairs(transmogData) do
			local warning = pendingInfo.warning;
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
	end

	return warnings;
end

function C_Transmog.GetPending(transmogLocation)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local pendingInfo = C_Transmog.GetPending(transmogLocation)", 2);
	end

	local pendingData = TRANSMOG_INFO:Get("Pending", transmogLocation.slotID, transmogLocation.type);
	if pendingData then
		return {
			type = pendingData.pendingType,
			transmogID = pendingData.transmogID,
			category = pendingData.category,
			subCategory = pendingData.subCategory,
		}
	end
end

function C_Transmog.GetSlotEffectiveCategory(transmogLocation)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local categoryID, subCategoryID = C_Transmog.GetSlotEffectiveCategory(transmogLocation)", 2);
	end

	if transmogLocation:IsIllusion() then
		return nil, nil;
	end

	local slotID = transmogLocation.slotID;

	local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogLocation.type);
	if pendingData and pendingData.category then
		return pendingData.category, pendingData.subCategory;
	end

	local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogLocation.type);
	if appliedData and appliedData.category then
		return appliedData.category, appliedData.subCategory;
	end

	local itemID = GetInventoryItemID("player", slotID);
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
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = C_Transmog.GetSlotInfo(transmogLocation)", 2);
	end

	local slotID = transmogLocation.slotID;
	local isAppearance = transmogLocation:IsAppearance();

	local itemID = GetInventoryItemID("player", transmogLocation.slotID);
	if not itemID then
		return false, false, false, false, 1, false, false, false;
	end

	if not isAppearance then
		-- TODO: canTransmogrify for illusion
	end

	local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogLocation.type);
	local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogLocation.type);

	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = false, false, false, true, 0, false, false;

	if appliedData then
		isTransmogrified = true;
	end

	if pendingData then
		hasPending = pendingData.hasPending;
		isPendingCollected = pendingData.isPendingCollected;
		canTransmogrify = pendingData.canTransmogrify;
		hasUndo = pendingData.hasUndo;
	else
		local itemName, _, itemRarity, _, _, _, _, _, _, _, _, _, _, _, equipLocID = C_Item.GetItemInfo(itemID, nil, nil, nil, true);
		if itemName then
			if nonTransmogrifyInvType[equipLocID] or ((itemRarity < 2 --[[or itemRarity > 5]]) and equipLocID ~= 4 and equipLocID ~= 19) then
				canTransmogrify = false;
			else
				canTransmogrify = true;
			end
		else
			canTransmogrify = false;
		end
	end

	if isAppearance then
		texture = GetInventoryItemTexture("player", slotID);

		if hasPending then
			if hasUndo then
				texture = GetInventoryItemTexture("player", slotID);
			elseif canTransmogrify then
				texture = select(10, GetItemInfo(pendingData.transmogID));
			end
		elseif isTransmogrified then
			texture = select(10, GetItemInfo(appliedData.transmogID));
		end
	else
		-- TODO: texture for illusion
	end

	return isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture;
end

function C_Transmog.GetSlotUseError(transmogLocation)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local errorCode, errorString = C_Transmog.GetSlotUseError(transmogLocation)", 2);
	end
end

function C_Transmog.GetSlotVisualInfo(transmogLocation)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" then
		error("Usage: local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, isHideVisual, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation)", 2);
	end

	local slotID = transmogLocation.slotID;
	local isAppearance = transmogLocation:IsAppearance();

	local baseSourceID, baseVisualID, pendingSourceID, pendingVisualID, appliedSourceID, appliedVisualID, itemSubclass;
	local hasPendingUndo, isHideVisual = false, false;

	if isAppearance then
		local itemID = GetInventoryItemID("player", slotID);
		if itemID then
			baseSourceID = itemID;
			baseVisualID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][1] or 0;
			itemSubclass = select(14, C_Item.GetItemInfo(itemID));
		end

		if IsAtTransmogNPC() then
			local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogLocation.type);
			if appliedData then
				appliedSourceID = appliedData.transmogID;
				appliedVisualID = appliedData.visualID;
			end
		else
			local transmogID = GetInventoryTransmogID("player", slotID) or 0;
			appliedSourceID = transmogID;
			appliedVisualID = ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID] and ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID][1] or 0;
		end
	else
		local itemLink = GetInventoryItemLink("player", slotID);
		if itemLink then
			local enchantID = string.match(itemLink, "item:%d+:(%d+)");
			enchantID = tonumber(enchantID);
			if enchantID then
				baseSourceID = enchantID;
				baseVisualID = enchantID;
			end
		end

		local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogLocation.type);
		if appliedData then
			appliedSourceID = appliedData.transmogID;
			appliedVisualID = appliedData.transmogID;
		end
	end

	local pendingData = TRANSMOG_INFO:Get("Pending", slotID, transmogLocation.type);
	if pendingData then
		hasPendingUndo = pendingData.hasUndo;
		pendingSourceID = pendingData.transmogID;
		if isAppearance then
			pendingVisualID = pendingData.visualID;
			itemSubclass = select(14, C_Item.GetItemInfo(pendingData.transmogID));
		else
			pendingVisualID = pendingData.transmogID;
		end
	end

	return baseSourceID or 0, baseVisualID or 0, appliedSourceID or 0, appliedVisualID or 0, pendingSourceID or 0, pendingVisualID or 0, hasPendingUndo, isHideVisual, itemSubclass or 0;
end

function C_Transmog.IsAtTransmogNPC()
	return IsAtTransmogNPC();
end

function C_Transmog.LoadOutfit(outfitID)
	local itemTransmogInfoList = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] and SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].itemList;
	if itemTransmogInfoList then
		for slotID, transmogID in pairs(itemTransmogInfoList) do
			if transmogID ~= NO_TRANSMOG_SOURCE_ID then
				SetPending(TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main), TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, transmogID));
			end
		end
	end

	local enchantTransmogInfoList = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] and SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].enchantList;
	if enchantTransmogInfoList then
		for slotID, transmogID in pairs(enchantTransmogInfoList) do
			if transmogID ~= NO_TRANSMOG_SOURCE_ID then
				SetPending(TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Illusion, Enum.TransmogModification.Main), TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, transmogID));
			end
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE);
end

function C_Transmog.SetPending(transmogLocation, pendingInfo)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" or type(pendingInfo) ~= "table" or type(pendingInfo.transmogID) ~= "number" then
		error("Usage: C_Transmog.SetPending(transmogLocation, pendingInfo)", 2);
	end

	local location, action = SetPending(transmogLocation, pendingInfo);
	if location and action then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, location, action);
	end
end

function C_Item.GetAppliedItemTransmogInfo(itemLocation)
	local appliedSourceID, appliedIllusionID;

	local slotID = itemLocation:GetEquipmentSlot();
	if slotID then
		local appliedAppearanceData = TRANSMOG_INFO:Get("Applied", slotID, Enum.TransmogType.Appearance);
		local appliedIllusionData = TRANSMOG_INFO:Get("Applied", slotID, Enum.TransmogType.Illusion);

		if appliedAppearanceData then
			appliedSourceID = appliedAppearanceData.transmogID;
		end

		if appliedIllusionData then
			appliedIllusionID = appliedIllusionData.transmogID;
		end
	end

	return CreateAndInitFromMixin(ItemTransmogInfoMixin, appliedSourceID or 0, appliedIllusionID or 0);
end

function C_Item.GetBaseItemTransmogInfo(itemLocation)
	local slotID = itemLocation:GetEquipmentSlot();

	local baseSourceID = GetInventoryItemID("player", slotID);

	local itemLink = GetInventoryItemLink("player", slotID);
	if itemLink then
		local enchantID = string.match(itemLink, "item:%d+:(%d+)");
		enchantID = tonumber(enchantID);
		if enchantID then
			baseIllusionID = enchantID;
		end
	end

	return CreateAndInitFromMixin(ItemTransmogInfoMixin, baseSourceID or 0, baseIllusionID or 0);
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_OPEN(msg)
	SendServerMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST");

	for _, block in ipairs({strsplit(";", msg)}) do
		local slotID, transmogID, enchantID = strsplit(":", block);
		slotID = tonumber(slotID);
		transmogID = tonumber(transmogID);
		enchantID = tonumber(enchantID);

		if slotID then
			if transmogID and transmogID ~= 0 then
				local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID];
				local category, subCategory = GetItemModifiedAppearanceCategoryInfo(transmogID, true);

				if sourceInfo then
					local appliedAppearanceData = TRANSMOG_INFO:Get("Applied", slotID, Enum.TransmogType.Appearance, true);
					appliedAppearanceData.isTransmogrified = true;
					appliedAppearanceData.slotID = slotID;
					appliedAppearanceData.transmogID = transmogID;
					appliedAppearanceData.visualID = sourceInfo[1];
					appliedAppearanceData.category = category;
					appliedAppearanceData.subCategoryID = subCategory;
				end
			end

			if enchantID and enchantID ~= 0 then
				local appliedIllusionData = TRANSMOG_INFO:Get("Applied", slotID, Enum.TransmogType.Illusion, true);
				appliedIllusionData.isTransmogrified = true;
				appliedIllusionData.slotID = slotID;
				appliedIllusionData.transmogID = enchantID;
				appliedIllusionData.visualID = enchantID;
			end
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_OPEN);
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_CLOSE(msg)
	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_CLOSE);
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_PREPARE_RESPONSE(msg)
	local slotID, transmogID, enchantID, errorType, transmogCost, enchantCost = strsplit(":", msg);
	slotID = tonumber(slotID);
	transmogID = tonumber(transmogID);
	enchantID = tonumber(enchantID);
	errorType = tonumber(errorType);
	transmogCost = tonumber(transmogCost) or 0;
	enchantCost = tonumber(enchantCost) or 0;

	if errorType == 0 then
		local pendingData = TRANSMOG_INFO:Get("Pending", slotID, Enum.TransmogType.Appearance);
		if pendingData and not pendingData.hasPending then
			pendingData.transmogID = transmogID;
			pendingData.visualID = ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID] and ITEM_MODIFIED_APPEARANCE_STORAGE[transmogID][1] or 0;
			pendingData.isPendingCollected = true;
			pendingData.canTransmogrify = true;
			pendingData.hasPending = true;
			pendingData.hasUndo = false;
			pendingData.errorType = errorType;
			pendingData.cost = transmogCost;

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Appearance, 0), "set");
		end

		pendingData = TRANSMOG_INFO:Get("Pending", slotID, Enum.TransmogType.Illusion);
		if pendingData and not pendingData.hasPending then
			pendingData.transmogID = enchantID;
			pendingData.visualID = enchantID;
			pendingData.isPendingCollected = true;
			pendingData.canTransmogrify = true;
			pendingData.hasPending = true;
			pendingData.hasUndo = false;
			pendingData.errorType = errorType;
			pendingData.cost = enchantCost;

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Illusion, 0), "set");
		end
	else
		local error = _G["TRANSMOGRIFY_ERROR_"..errorType];
		if error then
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
		end

		if slotID then
			TRANSMOG_INFO:Clear("Pending", slotID, Enum.TransmogType.Appearance);
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Appearance, 0), "clear");
			TRANSMOG_INFO:Clear("Pending", slotID, Enum.TransmogType.Illusion);
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_UPDATE, CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Illusion, 0), "clear");
		end
	end
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_APPLY_RESPONSE(msg)
	msg = tonumber(msg);

	if msg == 0 then
		for slotID, transmogData in pairs(TRANSMOG_INFO:Get("Pending")) do
			for transmogType, pendingData in pairs(transmogData) do
				if pendingData.pendingType == Enum.TransmogPendingType.Apply then
					if pendingData.transmogID and pendingData.transmogID ~= NO_TRANSMOG_SOURCE_ID then
						local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogType, true);
						appliedData.isTransmogrified = true;
						appliedData.slotID = slotID;
						appliedData.transmogID = pendingData.transmogID;
						if transmogType == Enum.TransmogType.Appearance then
							appliedData.visualID = ITEM_MODIFIED_APPEARANCE_STORAGE[pendingData.transmogID] and ITEM_MODIFIED_APPEARANCE_STORAGE[pendingData.transmogID][1] or 0;
						else
							appliedData.visualID = pendingData.transmogID;
						end
					end
				elseif pendingData.pendingType == Enum.TransmogPendingType.Revert then
					TRANSMOG_INFO:Clear("Applied", slotID, transmogType);
				end

				FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOGRIFY_SUCCESS, CreateAndSetFromMixin(TransmogLocationMixin, slotID, transmogType, Enum.TransmogModification.Main));
			end
		end

		TRANSMOG_INFO:Clear("Pending");


	else
		local error = _G["TRANSMOGRIFY_ERROR_"..msg];
		if error then
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
		end
	end
end

