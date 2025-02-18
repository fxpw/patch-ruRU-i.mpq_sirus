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

local scanTooltip = CreateFrame("GameTooltip", "TransmogScanTooltip");
scanTooltip:AddFontStrings(
	scanTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
	scanTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);

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

local REFUND_TYPE = {
	Store = 1,
	Merchant = 2,
}

local function IsMerchantRefundableItem(itemID, slotID)
	if slotID then
		local money, honorPoints, arenaPoints, itemCount, refundSec = GetContainerItemPurchaseInfo(0, slotID, 1);
		if not (not refundSec or (honorPoints == 0 and arenaPoints == 0 and itemCount == 0 and money == 0)) then
			return true;
		end
	else
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				if GetContainerItemID(bag, slot) == itemID then
					local money, honorPoints, arenaPoints, itemCount, refundSec = GetContainerItemPurchaseInfo(bag, slot);
					if not (not refundSec or (honorPoints == 0 and arenaPoints == 0 and itemCount == 0 and money == 0)) then
						return true;
					end
				end
			end
		end
	end
end

local BIND_TRADE_TIME_REMAINING = string.gsub(BIND_TRADE_TIME_REMAINING, "%%s", "(.+)");

function IsBoundTradeableItem(slotID)
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
	scanTooltip:SetInventoryItem("player", slotID);
	scanTooltip:Show();
	for i = ENABLE_COLORBLIND_MODE == "1" and 3 or 2, scanTooltip:NumLines() do
		local obj = _G["TransmogScanTooltipTextLeft"..i];
		if not obj then
			break;
		end

		local text = obj:GetText();
		if text and text ~= " " and string.find(text, BIND_TRADE_TIME_REMAINING) then
			return true;
		end
	end

	return false;
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
				baseVisualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(itemID))
			end

			if transmogID then
				pendingSourceID = transmogID;
				pendingVisualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(pendingSourceID))
			end

			local appliedData = TRANSMOG_INFO:Get("Applied", slotID, transmogType);
			if appliedData then
				appliedSourceID = appliedData.transmogID;
				appliedVisualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(appliedSourceID))
			end
		else
			baseSourceID = 0;
			baseVisualID = 0;

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

			local isRefundableItemType, isRefundableItemID, isBoundTradeableSlotID;

			if isAppearance then
				if pendingSourceID and pendingSourceID ~= 0 then
					if IsMerchantRefundableItem(pendingSourceID) then
						isRefundableItemType, isRefundableItemID = REFUND_TYPE.Merchant, pendingSourceID
					end
				end
				if baseSourceID and baseSourceID ~= 0 then
					if IsBoundTradeableItem(slotID) then
						isBoundTradeableSlotID = slotID;
					elseif not isRefundableItemType and IsMerchantRefundableItem(baseSourceID, slotID) then
						isRefundableItemType, isRefundableItemID = REFUND_TYPE.Merchant, baseSourceID
					end
				end
			else
				local itemID = GetTransmogSlotInfo(slotID, Enum.TransmogType.Appearance)
				if itemID and itemID ~= 0 then
					if IsMerchantRefundableItem(itemID) then
						isRefundableItemType, isRefundableItemID = REFUND_TYPE.Merchant, itemID
					end
				end
			end

			if isBoundTradeableSlotID then
				local itemIcon = GetInventoryItemTexture("player", isBoundTradeableSlotID);
				if itemIcon then
					local itemName, itemLink, itemQuality = GetItemInfo(GetInventoryItemID("player", isBoundTradeableSlotID));
					pendingData.warning = {
						itemName = itemName,
						itemLink = itemLink,
						itemQuality = itemQuality,
						itemIcon = itemIcon,
						text = TRANSMOG_END_BOUND_TRADEABLE,
					};
				end
			elseif isRefundableItemType and isRefundableItemID then
				local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(isRefundableItemID);
				pendingData.warning = {
					itemName = itemName,
					itemLink = itemLink,
					itemQuality = itemQuality,
					itemIcon = itemIcon,
					text = isRefundableItemType == REFUND_TYPE.Store and STORE_END_REFUND or MERCHANT_END_REFUND,
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

		FireCustomClientEvent("TRANSMOGRIFY_UPDATE", CreateAndSetFromMixin(TransmogLocationMixin, transmogLocation.slotID, transmogLocation.type, transmogLocation.modification), "clear");
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
	local categoryID, subCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(itemID);
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
			baseVisualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(itemID));
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
			appliedVisualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(transmogID));
		end
	else
		baseSourceID = 0;
		baseVisualID = 0;

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

	FireCustomClientEvent("TRANSMOGRIFY_UPDATE");
end

function C_Transmog.SetPending(transmogLocation, pendingInfo)
	if type(transmogLocation) ~= "table" or type(transmogLocation.slotID) ~= "number" or type(pendingInfo) ~= "table" or type(pendingInfo.transmogID) ~= "number" then
		error("Usage: C_Transmog.SetPending(transmogLocation, pendingInfo)", 2);
	end

	local location, action = SetPending(transmogLocation, pendingInfo);
	if location and action then
		FireCustomClientEvent("TRANSMOGRIFY_UPDATE", location, action);
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
	return CreateAndInitFromMixin(ItemTransmogInfoMixin, GetInventoryItemID("player", itemLocation:GetEquipmentSlot()) or 0, 0);
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
				local visualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(transmogID))
				if visualID ~= 0 then
					local category, subCategory = C_TransmogCollection.GetAppearanceSourceInfo(transmogID);

					local appliedAppearanceData = TRANSMOG_INFO:Get("Applied", slotID, Enum.TransmogType.Appearance, true);
					appliedAppearanceData.isTransmogrified = true;
					appliedAppearanceData.slotID = slotID;
					appliedAppearanceData.transmogID = transmogID;
					appliedAppearanceData.visualID = visualID;
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

	FireCustomClientEvent("TRANSMOGRIFY_OPEN");
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_CLOSE(msg)
	FireCustomClientEvent("TRANSMOGRIFY_CLOSE");
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
			pendingData.visualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(transmogID))
			pendingData.isPendingCollected = true;
			pendingData.canTransmogrify = true;
			pendingData.hasPending = true;
			pendingData.hasUndo = false;
			pendingData.errorType = errorType;
			pendingData.cost = transmogCost;

			FireCustomClientEvent("TRANSMOGRIFY_UPDATE", CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Appearance, 0), "set");
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

			FireCustomClientEvent("TRANSMOGRIFY_UPDATE", CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Illusion, 0), "set");
		end
	else
		local error = _G["TRANSMOGRIFY_ERROR_"..errorType];
		if error then
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0);
		end

		if slotID then
			TRANSMOG_INFO:Clear("Pending", slotID, Enum.TransmogType.Appearance);
			FireCustomClientEvent("TRANSMOGRIFY_UPDATE", CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Appearance, 0), "clear");
			TRANSMOG_INFO:Clear("Pending", slotID, Enum.TransmogType.Illusion);
			FireCustomClientEvent("TRANSMOGRIFY_UPDATE", CreateAndSetFromMixin(TransmogLocationMixin, slotID, Enum.TransmogType.Illusion, 0), "clear");
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
							appliedData.visualID = select(3, C_TransmogCollection.GetAppearanceSourceInfo(pendingData.transmogID))
						else
							appliedData.visualID = pendingData.transmogID;
						end
					end
				elseif pendingData.pendingType == Enum.TransmogPendingType.Revert then
					TRANSMOG_INFO:Clear("Applied", slotID, transmogType);
				end

				FireCustomClientEvent("TRANSMOGRIFY_SUCCESS", CreateAndSetFromMixin(TransmogLocationMixin, slotID, transmogType, Enum.TransmogModification.Main));
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

