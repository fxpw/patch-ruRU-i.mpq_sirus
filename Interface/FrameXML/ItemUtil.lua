
ItemButtonUtil = {};

ItemButtonUtil.ItemContextEnum = {
	UpgradableItem = 1,
};

ItemButtonUtil.ItemContextMatchResult = {
	Match = 1,
	Mismatch = 2,
	DoesNotApply = 3,
};

local ItemButtonUtilRegistry = CreateFromMixins(CallbackRegistryMixin);
ItemButtonUtilRegistry:OnLoad();
ItemButtonUtilRegistry:GenerateCallbackEvents(
{
    "ItemContextChanged",
});

ItemButtonUtil.Event = ItemButtonUtilRegistry.Event;

function ItemButtonUtil.RegisterCallback(...)
	return ItemButtonUtilRegistry:RegisterCallback(...);
end

function ItemButtonUtil.UnregisterCallback(...)
	return ItemButtonUtilRegistry:UnregisterCallback(...);
end

function ItemButtonUtil.TriggerEvent(...)
	return ItemButtonUtilRegistry:TriggerEvent(...);
end

function ItemButtonUtil.GetItemContext()
	if ItemUpgradeFrame and ItemUpgradeFrame:IsShown() then
		return ItemButtonUtil.ItemContextEnum.UpgradableItem;
	end
	return nil;
end

function ItemButtonUtil.OpenAndFilterBags(frame)
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	BagSlotButton_UpdateAll();
end

function ItemButtonUtil.CloseFilteredBags(frame)
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	BagSlotButton_UpdateAll();
end

function ItemButtonUtil.HasItemContext()
	return ItemButtonUtil.GetItemContext() ~= nil;
end

function ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation)
	local itemContext = ItemButtonUtil.GetItemContext();
	if itemContext == nil then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end

	if C_Item.DoesItemExist(itemLocation) then
		-- Ideally we'd only have 1 context active at a time, perhaps with a priority system.
		if itemContext == ItemButtonUtil.ItemContextEnum.UpgradableItem then
			if C_ItemUpgrade.CanUpgradeItem(itemLocation) then
				return ItemButtonUtil.ItemContextMatchResult.Match;
			end
			return ItemButtonUtil.ItemContextMatchResult.Mismatch;
		else
			return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
		end
	end

	return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
end

function ItemButtonUtil.GetItemContextMatchResultForContainer(bagID)
	if ItemButtonUtil.GetItemContext() == nil then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end

	local itemLocation = ItemLocation:CreateEmpty();
	for slotIndex = 1, GetContainerNumSlots(bagID) do
		itemLocation:SetBagAndSlot(bagID, slotIndex);
		if ItemButtonUtil.GetItemContextMatchResultForItem(itemLocation) == ItemButtonUtil.ItemContextMatchResult.Match then
			return ItemButtonUtil.ItemContextMatchResult.Match;
		end
	end

	return ItemButtonUtil.ItemContextMatchResult.Mismatch;
end

ItemUtil = {};

function ItemUtil.PickupBagItem(itemLocation)
	local bag, slot = itemLocation:GetBagAndSlot();
	if bag and slot then
		PickupContainerItem(bag, slot);
	end
end

function ItemUtil.IteratePlayerInventory(callback)
	-- Only includes the backpack and primary 4 bag slots.
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local bagItem = ItemLocation:CreateFromBagAndSlot(bag, slot);
			if C_Item.DoesItemExist(bagItem) then
				if callback(bagItem) then
					return;
				end
			end
		end
	end
end

function ItemUtil.IteratePlayerInventoryAndEquipment(callback)
	ItemUtil.IteratePlayerInventory(callback);

	for i = EQUIPPED_FIRST, EQUIPPED_LAST do
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(i);
		if C_Item.DoesItemExist(itemLocation) then
			if callback(itemLocation) then
				return;
			end
		end
	end
end

function ItemUtil.CreateItemTransmogInfo(appearanceID, secondaryAppearanceID, illusionID)
	return CreateAndInitFromMixin(ItemTransmogInfoMixin, appearanceID, secondaryAppearanceID, illusionID);
end
