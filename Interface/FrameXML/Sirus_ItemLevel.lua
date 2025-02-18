ItemLevelMixIn = {}
ItemLevelMixIn.Cache = {}

function ItemLevelMixIn:Request( unit, ignoreCache )
	if not unit then
		return
	end

	if ignoreCache or (not self.waitResponse and self:CanRequest(unit)) then
		self.unit = unit
		self.guid = UnitGUID(self.unit)

		SendServerMessage("ACMSG_AVERAGE_ITEM_LEVEL_REQUEST", self.guid)

		self.waitResponse = true
	end
end

function ItemLevelMixIn:CanRequest( unit )
	if not UnitIsPlayer(unit) then
		return false
	end

	local guid = UnitGUID(unit)
	local playerGUID = UnitGUID("player")

	if not self.Cache[guid] then
		return true
	end

	if ((time() - self.Cache[guid].timestamp) >= 15) and guid ~= playerGUID then
		self:Update(unit)
		return true
	else
		self:Update(unit)
		return false
	end
end

function ItemLevelMixIn:GetItemLevel( GUID )
	if not GUID then
		return
	end

	if self.Cache[GUID] then
		return self.Cache[GUID].itemLevel
	end

	return nil
end

function ItemLevelMixIn:Update( unit )
	local UNIT = unit or self.unit
	local GUID = unit and UnitGUID(unit) or self.guid

	if UNIT and GUID then
		local itemLevel = self:GetItemLevel(GUID)
		if itemLevel and itemLevel ~= -1 then
			local color = GetItemLevelColor(itemLevel)
			if UNIT == "player" then
				CharacterItemLevelFrame.ilvltext:SetTextColor(color.r, color.g, color.b)
				CharacterItemLevelFrame.ilvltext:SetText(itemLevel)
				CharacterItemLevelFrame.ilevel = itemLevel
			else
				if InspectFrame and InspectFrame:IsShown() and CanInspect(UNIT) then
					if GUID == UnitGUID(InspectFrame.unit) then
						InspectItemLevelFrame.ilvltext:SetTextColor(color.r, color.g, color.b)
						InspectItemLevelFrame.ilvltext:SetText(itemLevel)
						InspectItemLevelFrame.ilevel = UnitItemLevel
					end
				end
			end

			local _, tooltipUNIT = GameTooltip:GetUnit()
			if tooltipUNIT then
				if GUID == UnitGUID(tooltipUNIT) then
					for lineID = 1, GameTooltip:NumLines() do
						local line = _G["GameTooltipTextLeft"..lineID]
						local lineText = line:GetText()

						if lineText and string.find(lineText, TOOLTIP_UNIT_ITEM_LEVEL_LABEL) then
							line:SetText(string.gsub(lineText, TOOLTIP_UNIT_ITEM_LEVEL_LABEL, strconcat("%1: ", color:WrapTextInColorCode(itemLevel))))
							break
						end
					end
				end
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local _, unit = self:GetUnit()

	if unit then
		if UnitIsEnemy("player", unit) then
			for lineID = 1, self:NumLines() do
				local line = _G["GameTooltipTextLeft"..lineID]
				local lineText = line:GetText()

				if line and lineText then
					local originalText = string.match(lineText, TOOLTIP_UNIT_LEVEL_RACE_CLASS_TYPE_PATTERN)

					if originalText then
						line:SetText(originalText)
					end
				end
			end

			return
		end
	end

	ItemLevelMixIn:Request(unit)
end)

function EventHandler:ASMSG_AVERAGE_ITEM_LEVEL_RESPONSE( msg )
	ItemLevelMixIn.Cache[ItemLevelMixIn.guid] = {
		itemLevel = tonumber(msg),
		timestamp = time()
	}

	ItemLevelMixIn:Update()
	ItemLevelMixIn.waitResponse = false
end