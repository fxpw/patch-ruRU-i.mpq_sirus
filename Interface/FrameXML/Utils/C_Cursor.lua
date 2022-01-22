local BAG_OR_SLOT_INDEX;
local SLOT_INDEX;

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("ITEM_LOCK_CHANGED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

eventFrame:SetScript("OnEvent", function(self, event, bagOrSlotIndex, slotIndex)
	if event == "PLAYER_ENTERING_WORLD" then
		if not BAG_OR_SLOT_INDEX and GetCursorInfo() == "item" then
			for slotID = 1, 19 do
				if IsInventoryItemLocked(slotID) then
					BAG_OR_SLOT_INDEX = slotID;
					return;
				end
			end

			for bagID = 0, NUM_BAG_SLOTS do
				for slotID = 1, GetContainerNumSlots(bagID) do
					local _, _, locked = GetContainerItemInfo(bagID, slotID);
					if locked then
						BAG_OR_SLOT_INDEX = bagID;
						SLOT_INDEX = slotID;
						return;
					end
				end
			end

			ClearCursor();
		end
	elseif event == "ITEM_LOCK_CHANGED" then
		if GetCursorInfo() == "item" then
			BAG_OR_SLOT_INDEX = bagOrSlotIndex;
			SLOT_INDEX = slotIndex;

			self:RegisterEvent("CURSOR_UPDATE");
		else
			self:UnregisterEvent("CURSOR_UPDATE");

			BAG_OR_SLOT_INDEX = nil;
			SLOT_INDEX = nil;
		end
	elseif GetCursorInfo() ~= "item" then
		self:UnregisterEvent("CURSOR_UPDATE");

		BAG_OR_SLOT_INDEX = nil;
		SLOT_INDEX = nil;
	end
end)

C_Cursor = {};

function C_Cursor.GetCursorItem()
	if BAG_OR_SLOT_INDEX then
		if SLOT_INDEX then
			return ItemLocation:CreateFromBagAndSlot(BAG_OR_SLOT_INDEX, SLOT_INDEX);
		else
			return ItemLocation:CreateFromEquipmentSlot(BAG_OR_SLOT_INDEX);
		end
	end
end