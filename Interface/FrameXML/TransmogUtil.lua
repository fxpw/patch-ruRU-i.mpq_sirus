NO_TRANSMOG_SOURCE_ID = 0
REMOVE_TRANSMOG_ID = 0

TransmogSlotOrder = {
	INVSLOT_HEAD,
	INVSLOT_SHOULDER,
	INVSLOT_BACK,
	INVSLOT_CHEST,
	INVSLOT_BODY,
	INVSLOT_TABARD,
	INVSLOT_WRIST,
	INVSLOT_HAND,
	INVSLOT_WAIST,
	INVSLOT_LEGS,
	INVSLOT_FEET,
	INVSLOT_MAINHAND,
	INVSLOT_OFFHAND,
	INVSLOT_RANGED,
};

ItemTransmogInfoMixin = {};

function ItemTransmogInfoMixin:Init(appearanceID)
	self.appearanceID = appearanceID;
end

function ItemTransmogInfoMixin:IsEqual(itemTransmogInfo)
	if not itemTransmogInfo then
		return false;
	end
	return self.appearanceID == itemTransmogInfo.appearanceID;
end

function ItemTransmogInfoMixin:Clear()
	self.appearanceID = NO_TRANSMOG_SOURCE_ID;
end

TransmogUtil = {};

function TransmogUtil.GetInfoForEquippedSlot(transmogLocation)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo, _, itemSubclass = C_Transmog.GetSlotVisualInfo(transmogLocation);
	if ( appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
		appliedSourceID = baseSourceID;
		appliedVisualID = baseVisualID;
	end
	local selectedSourceID, selectedVisualID;
	if pendingSourceID ~= REMOVE_TRANSMOG_ID then
		selectedSourceID = pendingSourceID;
		selectedVisualID = pendingVisualID;
	elseif hasPendingUndo then
		selectedSourceID = baseSourceID;
		selectedVisualID = baseVisualID;
	else
		selectedSourceID = appliedSourceID;
		selectedVisualID = appliedVisualID;
	end
	return appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID, itemSubclass;
end

-- populated when TRANSMOG_SLOTS transmoglocations are created
local slotIDToName = {};

function TransmogUtil.GetSlotID(slotName)
	local slotID = GetInventorySlotInfo(slotName);
	slotIDToName[slotID] = slotName;
	return slotID;
end

function TransmogUtil.GetSlotName(slotID)
	return slotIDToName[slotID];
end

local function GetSlotID(slotDescriptor)
	if type(slotDescriptor) == "string" then
		return TransmogUtil.GetSlotID(slotDescriptor);
	else
		return slotDescriptor;
	end
end

function TransmogUtil.CreateTransmogLocation(slotDescriptor, transmogType, modification)
	local slotID = GetSlotID(slotDescriptor);
	local transmogLocation = CreateFromMixins(TransmogLocationMixin);
	transmogLocation:Set(slotID, transmogType, modification);
	return transmogLocation;
end

function TransmogUtil.GetTransmogLocation(slotDescriptor, transmogType, modification)
	local slotID = GetSlotID(slotDescriptor);
	local lookupKey = TransmogUtil.GetTransmogLocationLookupKey(slotID, transmogType, modification);
	local transmogSlot = TRANSMOG_SLOTS[lookupKey];
	return transmogSlot and transmogSlot.location;
end

function TransmogUtil.GetCorrespondingHandTransmogLocation(transmogLocation)
	if transmogLocation:IsMainHand() then
		return TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
	elseif transmogLocation:IsOffHand() then
		return TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
	elseif transmogLocation:IsRanged() then
		return TransmogUtil.GetTransmogLocation("RANGEDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.None);
	end
end

function TransmogUtil.GetTransmogLocationLookupKey(slotID, transmogType, modification)
	return slotID * 100 + transmogType * 10 + modification;
end

function TransmogUtil.GetSetIcon(setID)
	local bestItemID;
	local bestSortOrder = 100;
	local sources = C_TransmogSets.GetSetSources(setID);
	if sources then
		for sourceID, collected in pairs(sources) do
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID);
			if sourceInfo then
				local sortOrder = EJ_GetInvTypeSortOrder(sourceInfo.invType);
				if sortOrder < bestSortOrder then
					bestSortOrder = sortOrder;
					bestItemID = sourceInfo.itemID;
				end
			end
		end
	end
	if bestItemID then
		return select(3, GetItemInfo(bestItemID));
	else
		return QUESTION_MARK_ICON;
	end
end

function TransmogUtil.CreateTransmogPendingInfo(pendingType, transmogID, category, subCategory)
	local pendingInfo = CreateFromMixins(TransmogPendingInfoMixin);
	pendingInfo:Init(pendingType, transmogID, category, subCategory);
	return pendingInfo;
end

function TransmogUtil.GetRelevantTransmogID(itemTransmogInfo, transmogLocation)
	if not itemTransmogInfo then
		return NO_TRANSMOG_VISUAL_ID;
	end
	if transmogLocation.type == Enum.TransmogType.Illusion then
		return itemTransmogInfo.illusionID;
	end
	if transmogLocation.modification == Enum.TransmogModification.Secondary then
		return itemTransmogInfo.secondaryAppearanceID;
	end
	return itemTransmogInfo.appearanceID;
end

function TransmogUtil.IsCategoryRangedWeapon(categoryID)
	return (categoryID == Enum.TransmogCollectionType.Bow) or (categoryID == Enum.TransmogCollectionType.Gun) or (categoryID == Enum.TransmogCollectionType.Crossbow);
end

function TransmogUtil.IsValidTransmogSlotID(slotID)
	local lookupKey = TransmogUtil.GetTransmogLocationLookupKey(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	return not not TRANSMOG_SLOTS[lookupKey];
end

function TransmogUtil.OpenCollectionToItem(sourceID)
	if TransmogUtil.OpenCollectionUI() then
		WardrobeCollectionFrame:GoToItem(sourceID);
	end
end

function TransmogUtil.OpenCollectionUI()
	if CollectionsJournal then
		if not CollectionsJournal:IsVisible() or not WardrobeCollectionFrame:IsVisible() then
			ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES);
		end
		return true;
	end
	return false;
end

TransmogPendingInfoMixin = {};

function TransmogPendingInfoMixin:Init(pendingType, transmogID, category, subCategory)
	self.type = pendingType;
	if pendingType ~= Enum.TransmogPendingType.Apply then
		transmogID = NO_TRANSMOG_VISUAL_ID;
	end
	self.transmogID = transmogID;
	self.category = category;
	self.subCategory = subCategory;
end

TransmogLocationMixin = {};

function TransmogLocationMixin:Set(slotID, transmogType, modification)
	self.slotID = slotID;
	self.type = transmogType;
	self.modification = modification;
end

function TransmogLocationMixin:IsAppearance()
	return self.type == Enum.TransmogType.Appearance;
end

function TransmogLocationMixin:IsIllusion()
	return self.type == Enum.TransmogType.Illusion;
end

function TransmogLocationMixin:GetSlotID()
	return self.slotID;
end

function TransmogLocationMixin:GetSlotName()
	return TransmogUtil.GetSlotName(self.slotID);
end

function TransmogLocationMixin:IsEitherHand()
	return self:IsMainHand() or self:IsOffHand() or self:IsRanged();
end

function TransmogLocationMixin:IsMainHand()
	local slotName = self:GetSlotName();
	return slotName == "MAINHANDSLOT";
end

function TransmogLocationMixin:IsOffHand()
	local slotName = self:GetSlotName();
	return slotName == "SECONDARYHANDSLOT";
end

function TransmogLocationMixin:IsRanged()
	local slotName = self:GetSlotName();
	return slotName == "RANGEDSLOT";
end

function TransmogLocationMixin:IsEqual(transmogLocation)
	if not transmogLocation then
		return false;
	end
	return self.slotID == transmogLocation.slotID and self.type == transmogLocation.type and self.modification == transmogLocation.modification;
end

function TransmogLocationMixin:GetArmorCategoryID()
	local transmogSlot = TRANSMOG_SLOTS[self:GetLookupKey()];
	return transmogSlot and transmogSlot.armorCategoryID;
end

function TransmogLocationMixin:GetLookupKey()
	return TransmogUtil.GetTransmogLocationLookupKey(self.slotID, self.type, self.modification);
end

TRANSMOG_SLOTS = {};

-- this will indirectly populate slotIDToName
do
	function Add(slotName, transmogType, modification, armorCategoryID)
		local location = TransmogUtil.CreateTransmogLocation(slotName, transmogType, modification);
		local lookupKey = location:GetLookupKey();
		TRANSMOG_SLOTS[lookupKey] = {location = location, armorCategoryID = armorCategoryID};
	end

	Add("HEADSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Head);
	Add("SHOULDERSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Shoulder);
	Add("BACKSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Back);
	Add("CHESTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Chest);
	Add("TABARDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Tabard);
	Add("SHIRTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Shirt);
	Add("WRISTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Wrist);
	Add("HANDSSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Hands);
	Add("WAISTSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Waist);
	Add("LEGSSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Legs);
	Add("FEETSLOT",				Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, Enum.TransmogCollectionType.Feet);
	Add("MAINHANDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, nil);
	Add("SECONDARYHANDSLOT",	Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, nil);
	Add("RANGEDSLOT",			Enum.TransmogType.Appearance,	Enum.TransmogModification.Main, nil);
	Add("MAINHANDSLOT",			Enum.TransmogType.Illusion,		Enum.TransmogModification.Main, nil);
	Add("SECONDARYHANDSLOT",	Enum.TransmogType.Illusion,		Enum.TransmogModification.Main, nil);
	Add("RANGEDSLOT",			Enum.TransmogType.Illusion,		Enum.TransmogModification.Main, nil);
end