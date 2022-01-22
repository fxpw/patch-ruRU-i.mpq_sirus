--	Filename:	Sirus_ItemLevel.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

ItemLevelMixIn = {}
ItemLevelMixIn.Cache = {}
ItemLevelMixIn.Colors = {
	[1] = CreateColor(0.65882, 0.65882, 0.65882),
	[2] = CreateColor(0.08235, 0.70196, 0),
	[3] = CreateColor(0, 0.56863, 0.94902),
	[4] = CreateColor(0.78431, 0.27059, 0.98039),
	[5] = CreateColor(1, 0.50196, 0),
	[6] = CreateColor(1, 0, 0),
}

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

function ItemLevelMixIn:GetColor( itemLevel )
	local color

	if C_InRange(itemLevel, 0, 100) then
		color = self.Colors[1]
	elseif C_InRange(itemLevel, 100, 150) then
		color = self.Colors[1]
	elseif C_InRange(itemLevel, 150, 185) then
		color = self.Colors[2]
	elseif C_InRange(itemLevel, 185, 200) then
		color = self.Colors[3]
	elseif C_InRange(itemLevel, 200, 277) then
		color = self.Colors[4]
	elseif C_InRange(itemLevel, 277, 296) then
		color = self.Colors[5]
	elseif itemLevel >= 297 then
		color = self.Colors[6]
	end

	return color
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
			local color = self:GetColor(itemLevel)
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

						if lineText and string.find(lineText, TOOLTIP_UNIT_LEVEL_ILEVEL_LOADING_LABEL) then
							line:SetText(string.gsub(lineText, TOOLTIP_UNIT_LEVEL_ILEVEL_LOADING_LABEL, color:WrapTextInColorCode(itemLevel)))
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
