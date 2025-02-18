local ipairs = ipairs
local tonumber = tonumber
local twipe = table.wipe

local GetContainerItemID = GetContainerItemID

local NEW_ITEMS = {}

C_NewItems = {}

function C_NewItems.IsNewItem(containerIndex, slotIndex)
	if NEW_ITEMS[containerIndex] and NEW_ITEMS[containerIndex][slotIndex] then
		return true
	end
	return false
end

function C_NewItems.RemoveNewItem(containerIndex, slotIndex)
	if NEW_ITEMS[containerIndex] and NEW_ITEMS[containerIndex][slotIndex] then
		NEW_ITEMS[containerIndex][slotIndex] = nil
	end
end

function C_NewItems.ClearAll()
	twipe(NEW_ITEMS)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ITEM_LOCKED")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", function(_, event, bagID, ...)
	if event == "ITEM_LOCKED" then
		local slotID = ...
		if slotID and NEW_ITEMS[bagID] then
			NEW_ITEMS[bagID][slotID] = nil
		end
	elseif event == "BAG_UPDATE" then
		if NEW_ITEMS[bagID] then
			for slotID in pairs(NEW_ITEMS[bagID]) do
				if not GetContainerItemID(bagID, slotID) then
					NEW_ITEMS[bagID][slotID] = nil
				end
			end
		end
	end
end)

function EventHandler:ASMSG_GLOW_ITEM(msg)
	for _, newItem in ipairs({StringSplitEx(";", msg)}) do
		local bagID, slotID = StringSplitEx(":", newItem)
		bagID, slotID = tonumber(bagID), tonumber(slotID) + 1

		if bagID == 0 then
			slotID = slotID - 23
		end

		if not NEW_ITEMS[bagID] then
			NEW_ITEMS[bagID] = {}
		end

		NEW_ITEMS[bagID][slotID] = true
	end
end