-- The default tooltip border color
--TOOLTIP_DEFAULT_COLOR = { r = 0.5, g = 0.5, b = 0.5 };
TOOLTIP_DEFAULT_COLOR = { r = 1, g = 1, b = 1 };
TOOLTIP_DEFAULT_BACKGROUND_COLOR = { r = 0.09, g = 0.09, b = 0.19 };
DEFAULT_TOOLTIP_POSITION = -13;

function GameTooltip_UnitColor(unit)
	local color
	if ( UnitPlayerControlled(unit) ) then
		if ( UnitCanAttack(unit, "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", unit) ) then
				color = TOOLTIP_DEFAULT_COLOR
			else
				color = FACTION_BAR_COLORS[2]
			end
		elseif ( UnitCanAttack("player", unit) ) then
			-- Players we can attack but which are not hostile are yellow
			color = FACTION_BAR_COLORS[4]
		elseif ( UnitIsPVP(unit) ) then
			-- Players we can assist but are PvP flagged are green
			color = FACTION_BAR_COLORS[6]
		else
			-- All other players are blue (the usual state on the "blue" server)
			color = TOOLTIP_DEFAULT_COLOR
		end
	else
		local reaction = UnitReaction(unit, "player");

		if reaction and FACTION_BAR_COLORS[reaction] then
			color = FACTION_BAR_COLORS[reaction]
		else
			color = TOOLTIP_DEFAULT_COLOR
		end
	end

	return color.r, color.g, color.b
end

function GameTooltip_SetDefaultAnchor(tooltip, parent)
	tooltip:SetOwner(parent, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
	tooltip.default = 1;
end

function GameTooltip_OnLoad(self)
	self.updateTooltip = TOOLTIP_UPDATE_TIME;
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.statusBar2 = _G[self:GetName().."StatusBar2"];
	self.statusBar2Text = _G[self:GetName().."StatusBar2Text"];
end

function GameTooltip_OnTooltipAddMoney(self, cost, maxcost)
	if self.isToyByItemID then
		return;
	end

	if( not maxcost ) then --We just have 1 price to display
		SetTooltipMoney(self, cost, nil, string.format("%s:", SELL_PRICE));
	else
		self:AddLine(string.format("%s:", SELL_PRICE), 1.0, 1.0, 1.0);
		local indent = string.rep(" ",4)
		SetTooltipMoney(self, cost, nil, string.format("%s%s:", indent, MINIMUM));
		SetTooltipMoney(self, maxcost, nil, string.format("%s%s:", indent, MAXIMUM));
	end
end

function SetTooltipMoney(frame, money, type, prefixText, suffixText)
	frame:AddLine(" ", 1.0, 1.0, 1.0);
	local numLines = frame:NumLines();
	if ( not frame.numMoneyFrames ) then
		frame.numMoneyFrames = 0;
	end
	if ( not frame.shownMoneyFrames ) then
		frame.shownMoneyFrames = 0;
	end
	local name = frame:GetName().."MoneyFrame"..frame.shownMoneyFrames+1;
	local moneyFrame = _G[name];
	if ( not moneyFrame ) then
		frame.numMoneyFrames = frame.numMoneyFrames+1;
		moneyFrame = CreateFrame("Frame", name, frame, "TooltipMoneyFrameTemplate");
		name = moneyFrame:GetName();
		MoneyFrame_SetType(moneyFrame, "STATIC");
	end
	_G[name.."PrefixText"]:SetText(prefixText);
	_G[name.."SuffixText"]:SetText(suffixText);
	if ( type ) then
		MoneyFrame_SetType(moneyFrame, type);
	end
	--We still have this variable offset because many AddOns use this function. The money by itself will be unaligned if we do not use this.
	local xOffset;
	if ( prefixText ) then
		xOffset = 4;
	else
		xOffset = 0;
	end
	moneyFrame:SetPoint("LEFT", frame:GetName().."TextLeft"..numLines, "LEFT", xOffset, 0);
	moneyFrame:Show();
	if ( not frame.shownMoneyFrames ) then
		frame.shownMoneyFrames = 1;
	else
		frame.shownMoneyFrames = frame.shownMoneyFrames+1;
	end
	MoneyFrame_Update(moneyFrame:GetName(), money);
	local moneyFrameWidth = moneyFrame:GetWidth();
	if ( frame:GetMinimumWidth() < moneyFrameWidth ) then
		frame:SetMinimumWidth(moneyFrameWidth);
	end
	frame.hasMoney = 1;
end

function GameTooltip_ClearMoney(self)
	if ( not self.shownMoneyFrames ) then
		return;
	end

	local moneyFrame;
	for i=1, self.shownMoneyFrames do
		moneyFrame = _G[self:GetName().."MoneyFrame"..i];
		if(moneyFrame) then
			moneyFrame:Hide();
			MoneyFrame_SetType(moneyFrame, "STATIC");
		end
	end
	self.shownMoneyFrames = nil;
end

function GameTooltip_InsertFrame(tooltipFrame, frame)
	local textSpacing = 2;
	local textHeight = _G[tooltipFrame:GetName().."TextLeft2"]:GetHeight();
	local numLinesNeeded = math.ceil(frame:GetHeight() / (textHeight + textSpacing));
	local currentLine = tooltipFrame:NumLines();
	for i = 1, numLinesNeeded do
		tooltipFrame:AddLine(" ");
	end
	frame:SetParent(tooltipFrame);
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", tooltipFrame:GetName().."TextLeft"..(currentLine + 1), "TOPLEFT", 0, 0);
	if ( not tooltipFrame.insertedFrames ) then
		tooltipFrame.insertedFrames = { };
	end
	local frameWidth = frame:GetWidth();
	if ( tooltipFrame:GetMinimumWidth() < frameWidth ) then
		tooltipFrame:SetMinimumWidth(frameWidth);
	end
	frame:Show();
	tinsert(tooltipFrame.insertedFrames, frame);
	-- return space taken so inserted frame can resize if needed
	return (numLinesNeeded * textHeight) + (numLinesNeeded - 1) * textSpacing;
end

function GameTooltip_ClearInsertedFrames(self)
	if ( self.insertedFrames ) then
		for i = 1, #self.insertedFrames do
			self.insertedFrames[i]:SetParent(nil);
			self.insertedFrames[i]:Hide();
		end
	end
	self.insertedFrames = nil;
end

function GameTooltip_ClearStatusBars(self)
	if ( not self.shownStatusBars ) then
		return;
	end
	local statusBar;
	for i=1, self.shownStatusBars do
		statusBar = _G[self:GetName().."StatusBar"..i];
		if ( statusBar ) then
			statusBar:Hide();
		end
	end
	self.shownStatusBars = 0;
end

function GameTooltip_OnHide(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
	self.default = nil;
	GameTooltip_ClearMoney(self);
	GameTooltip_ClearStatusBars(self);
	if ( self.shoppingTooltips ) then
		for _, frame in pairs(self.shoppingTooltips) do
			frame:Hide();
		end
	end

	self.TransmogText1:Hide()
	self.TransmogText2:Hide()

	GameTooltip_FixLinePosition(self)
	GameTooltip_ClearInsertedFrames(GameTooltip)

	self.comparing = false;
	self.merchantSlotIndex = nil
end

function GameTooltip_OnUpdate(self, elapsed)
	-- Only update every TOOLTIP_UPDATE_TIME seconds
	self.updateTooltip = self.updateTooltip - elapsed;
	if ( self.updateTooltip > 0 ) then
		return;
	end
	self.updateTooltip = TOOLTIP_UPDATE_TIME;

	local owner = self:GetOwner();
	if ( owner and owner.UpdateTooltip ) then
		owner:UpdateTooltip();
	end

	GameTooltip_FixLinePosition(self)
end

function GameTooltip_OnTooltipSetUnit(self)
	if self:IsUnit("mouseover") then
		_G[self:GetName().."TextLeft1"]:SetTextColor(GameTooltip_UnitColor("mouseover"));
	end

	local name, unit = self:GetUnit()
	if unit and UnitIsPlayer(unit) then
		local zodiacID, zodiacName, zodiacDescription, zodiacIcon, zodiacAtlas = C_Unit.GetZodiacByDebuff(unit)
		if zodiacName then
			for lineIndex = 1, GameTooltip:NumLines() do
				local line = _G["GameTooltipTextLeft"..lineIndex]
				local lineText = line:GetText()
				if lineText and string.find(lineText, TOOLTIP_UNIT_ZODIAC_LABEL) then
					line:SetText(string.gsub(lineText, TOOLTIP_UNIT_ZODIAC_LABEL, zodiacName))
					break
				end
			end
		end
	end
end

function GameTooltip_OnTooltipSetItem(self)
	if IsModifiedClick("COMPAREITEMS") or (GetCVarBool("alwaysCompareItems") and not self:IsEquippedItem()) then
		GameTooltip_ShowCompareItem(self, 1);
	end
end

function GameTooltip_FixLinePosition( self )
	if self.TransmogText1:IsShown() then
		self.TextLeft2:ClearAllPoints()
		if self.TransmogText2:IsShown() then
			self.TextLeft2:SetPoint("TOPLEFT", self.TransmogText2, "BOTTOMLEFT", 0, -2)
		else
			self.TextLeft2:SetPoint("TOPLEFT", self.TransmogText1, "BOTTOMLEFT", 0, -2)
		end
	else
		if self.TextLeft2:GetText() ~= DAMAGE_SCHOOL2 then
			self.TextLeft2:ClearAllPoints()
			self.TextLeft2:SetPoint("TOPLEFT", self.TextLeft1, "BOTTOMLEFT", 0, -2)
		end
	end
end

function GameTooltip_AddNewbieTip(frame, normalText, r, g, b, newbieText, noNormalText)
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, frame);
		if ( normalText ) then
			GameTooltip:SetText(normalText, r, g, b);
			GameTooltip:AddLine(newbieText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		else
			GameTooltip:SetText(newbieText, r, g, b, 1, 1);
		end
		GameTooltip:Show();
	else
		if ( not noNormalText ) then
			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
			GameTooltip:SetText(normalText, r, g, b);
		end
	end
end

function GameTooltip_ShowCompareItem(self, shift)
	if ( not self ) then
		self = GameTooltip;
	end
	local item, link = self:GetItem();
	if ( not link ) then
		return;
	end

	local shoppingTooltip1, shoppingTooltip2, shoppingTooltip3 = unpack(self.shoppingTooltips);

	local item1 = nil;
	local item2 = nil;
	local item3 = nil;
	local side = "left";
	if ( shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self) ) then
		item1 = true;
	end
	if ( shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self) ) then
		item2 = true;
	end
	if ( shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self) ) then
		item3 = true;
	end

	-- find correct side
	local rightDist = 0;
	local leftPos = self:GetLeft();
	local rightPos = self:GetRight();
	if ( not rightPos ) then
		rightPos = 0;
	end
	if ( not leftPos ) then
		leftPos = 0;
	end

	rightDist = GetScreenWidth() - rightPos;

	if (leftPos and (rightDist < leftPos)) then
		side = "left";
	else
		side = "right";
	end

	-- see if we should slide the tooltip
	if ( self:GetAnchorType() and self:GetAnchorType() ~= "ANCHOR_PRESERVE" ) then
		local totalWidth = 0;
		if ( item1  ) then
			totalWidth = totalWidth + shoppingTooltip1:GetWidth();
		end
		if ( item2  ) then
			totalWidth = totalWidth + shoppingTooltip2:GetWidth();
		end
		if ( item3  ) then
			totalWidth = totalWidth + shoppingTooltip3:GetWidth();
		end

		if ( (side == "left") and (totalWidth > leftPos) ) then
			self:SetAnchorType(self:GetAnchorType(), (totalWidth - leftPos), 0);
		elseif ( (side == "right") and (rightPos + totalWidth) >  GetScreenWidth() ) then
			self:SetAnchorType(self:GetAnchorType(), -((rightPos + totalWidth) - GetScreenWidth()), 0);
		end
	end

	-- anchor the compare tooltips
	if ( item3 ) then
		shoppingTooltip3:SetOwner(self, "ANCHOR_NONE");
		shoppingTooltip3:ClearAllPoints();
		if ( side and side == "left" ) then
			shoppingTooltip3:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -10);
		else
			shoppingTooltip3:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
		end
		shoppingTooltip3:SetHyperlinkCompareItem(link, 3, shift, self);
		shoppingTooltip3:Show();
	end

	if ( item1 ) then
		if( item3 ) then
			shoppingTooltip1:SetOwner(shoppingTooltip3, "ANCHOR_NONE");
		else
			shoppingTooltip1:SetOwner(self, "ANCHOR_NONE");
		end
		shoppingTooltip1:ClearAllPoints();
		if ( side and side == "left" ) then
			if( item3 ) then
				shoppingTooltip1:SetPoint("TOPRIGHT", shoppingTooltip3, "TOPLEFT", 0, 0);
			else
				shoppingTooltip1:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, -10);
			end
		else
			if( item3 ) then
				shoppingTooltip1:SetPoint("TOPLEFT", shoppingTooltip3, "TOPRIGHT", 0, 0);
			else
				shoppingTooltip1:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -10);
			end
		end
		shoppingTooltip1:SetHyperlinkCompareItem(link, 1, shift, self);
		shoppingTooltip1:Show();

		if ( item2 ) then
			shoppingTooltip2:SetOwner(shoppingTooltip1, "ANCHOR_NONE");
			shoppingTooltip2:ClearAllPoints();
			if ( side and side == "left" ) then
				shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", 0, 0);
			else
				shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 0, 0);
			end
			shoppingTooltip2:SetHyperlinkCompareItem(link, 2, shift, self);
			shoppingTooltip2:Show();
		end
	end
end

function GameTooltip_ShowStatusBar(self, min, max, value, text)
	self:AddLine(" ", 1.0, 1.0, 1.0);
	local numLines = self:NumLines();
	if ( not self.numStatusBars ) then
		self.numStatusBars = 0;
	end
	if ( not self.shownStatusBars ) then
		self.shownStatusBars = 0;
	end
	local index = self.shownStatusBars+1;
	local name = self:GetName().."StatusBar"..index;
	local statusBar = _G[name];
	if ( not statusBar ) then
		self.numStatusBars = self.numStatusBars+1;
		statusBar = CreateFrame("StatusBar", name, self, "TooltipStatusBarTemplate");
	end
	if ( not text ) then
		text = "";
	end
	_G[name.."Text"]:SetText(text);
	statusBar:SetMinMaxValues(min, max);
	statusBar:SetValue(value);
	statusBar:Show();
	statusBar:SetPoint("LEFT", self:GetName().."TextLeft"..numLines, "LEFT", 0, -2);
	statusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0);
	statusBar:Show();
	self.shownStatusBars = index;
	self:SetMinimumWidth(140);
end

function GameTooltip_Hide()
	-- Used for XML OnLeave handlers
	GameTooltip:Hide();
end

function GameTooltip_HideResetCursor()
	GameTooltip:Hide();
	ResetCursor();
end

GameTooltipMixin = {}

function GameTooltipMixin:OnLoad()
	GameTooltip_OnLoad(self)
	self.shoppingTooltips = { ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 }

	hooksecurefunc(GameTooltip, "SetInventoryItem", function(this, unit, slotID)
		this:InventoryItemOnShow(unit, slotID)
	end)
end

function GameTooltipMixin:SetToyByItemID(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end

	if type(itemID) ~= "number" then
		return false;
	end

	self.isToyByItemID = true;
	self:SetHyperlink(string.format("item:%d", itemID));
	self.isToyByItemID = nil;

	return true;
end

function GameTooltipMixin:SetHeirloomByItemID(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end

	if type(itemID) ~= "number" then
		return false;
	end

	self.isHeirloomItemID = true;
	self:SetHyperlink(string.format("item:%d", itemID));
	self.isHeirloomItemID = nil;

	return true;
end

function GameTooltipMixin:InventoryItemOnShow(unit, slotID)
	if unit == "player" then
		local transmogID = GetInventoryTransmogID(unit, slotID);

		if transmogID then
			self:SetTransmogrifyItem(transmogID)
		end
	end
end

function GameTooltipMixin:SetTransmogrifyItem(transmogID, hasPending, hasUndo)
	local lastTransmogText, transmogTextHeight

	if not self.TransmogText1:IsShown() and not self.TransmogText2:IsShown() then
		if hasUndo then
			self.TransmogText1:Show()
			self.TransmogText1:SetText(TRANSMOGRIFY_TOOLTIP_REVERT)

			lastTransmogText = self.TransmogText1
			transmogTextHeight = self.TransmogText1:GetHeight() + 2
		elseif transmogID then
			local name = GetItemInfo(transmogID)
			if name then
				self.TransmogText1:Show()
				self.TransmogText2:Show()
				if hasPending then
					self.TransmogText1:SetText(WILL_BE_TRANSMOGRIFIED_HEADER)
				else
					self.TransmogText1:SetText(TRANSMOGRIFIED_HEADER)
				end
				self.TransmogText2:SetText(name)

				lastTransmogText = self.TransmogText2
				transmogTextHeight = self.TransmogText1:GetHeight() + self.TransmogText2:GetHeight() + 4
			end
		end
	end

	if lastTransmogText and transmogTextHeight then
		self.TextLeft2:ClearAllPoints()
		self.TextLeft2:SetPoint("TOPLEFT", lastTransmogText, "BOTTOMLEFT", 0, -2)

		self:SetHeight(self:GetHeight() + transmogTextHeight)

		Hook:FireEvent("TRANSMOGRIFY_ITEM_UPDATE", self, transmogID)
	end
end

local function GameTooltip_OnToyByItemID(self, itemID)
	if not self.isToyByItemID or not itemID then
		return;
	end

	local _, spellID, _, _, _, descriptionText, priceText, holidayText = C_ToyBox.GetToyInfo(itemID);
	if spellID then
		if PlayerHasToy(itemID) then
			local name, rank = GetSpellInfo(spellID);
			local start, duration = GetSpellCooldown(name, rank);

			if start and start > 0 and duration and duration > 0 then
				local time = duration - (GetTime() - start);
				GameTooltip_AddHighlightLine(self, string.format(ITEM_COOLDOWN_TIME, SecondsToTime(time, time >= 60)), 1);
			end
		end

		if descriptionText ~= "" then
			GameTooltip_AddBlankLineToTooltip(self);
			GameTooltip_AddNormalLine(self, descriptionText, 1);
		end

		local addBlankLine = true;
		if holidayText ~= "" then
			addBlankLine = false;
			GameTooltip_AddBlankLineToTooltip(self);
			GameTooltip_AddHighlightLine(self, holidayText, 1);
		end

		if priceText ~= "" then
			if addBlankLine then
				GameTooltip_AddBlankLineToTooltip(self);
			end
			GameTooltip_AddHighlightLine(self, priceText, 1);
		end

		self:Show();
	end

	self.isToyByItemID = nil;
end

local function GameTooltip_OnHeirloomByItemID(self, itemID)
	if not self.isHeirloomItemID or not itemID then
		return;
	end

	local spellID = C_Heirloom.GetHeirloomSpellID(itemID);
	if spellID then
		if C_Heirloom.PlayerHasHeirloom(itemID) then
			local name, rank = GetSpellInfo(spellID);
			local start, duration = GetSpellCooldown(name, rank);

			if start and start > 0 and duration and duration > 0 then
				local time = duration - (GetTime() - start);
				GameTooltip_AddHighlightLine(self, string.format(ITEM_COOLDOWN_TIME, SecondsToTime(time, time >= 60)), 1);
			end
		end

		local _, _, _, descriptionText, priceText = C_Heirloom.GetHeirloomInfo(itemID);

		if descriptionText ~= "" then
			GameTooltip_AddBlankLineToTooltip(self);
			GameTooltip_AddNormalLine(self, descriptionText, 1);
		end

		if priceText ~= "" then
			GameTooltip_AddBlankLineToTooltip(self);
			GameTooltip_AddHighlightLine(self, priceText, 1);
		end

		self:Show();
	end

	self.isHeirloomItemID = nil;
end

EQUIPMENT_SET_LAST_TOOLTIP = {}

GameTooltip_SetScript("OnSetSpell", function(self, ...)
	local _, _, spellID = self:GetSpell()

	if spellID and spellID == 1804 then
		local currentSkillRank, maxSkillRank

		for i = 1, GetNumSkillLines() do
			local skillName, _, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)

			if skillName == SKILL_NAME_LOCKPICKING then
				currentSkillRank = skillRank
				maxSkillRank = skillMaxRank
				break
			end
		end

		if currentSkillRank and maxSkillRank then
			local currenBarValue = (currentSkillRank / maxSkillRank) * 100

			GameTooltip_InsertFrame(GameTooltip, SpellTooltipStatusBar)

			SpellTooltipStatusBar.Bar:SetValue(currenBarValue)
			SpellTooltipStatusBar.Bar.Label:SetFontObject("GameFontNormal")
			SpellTooltipStatusBar.Bar.Label:SetFormattedText("%d / %d", currentSkillRank, maxSkillRank)

			SpellTooltipStatusBar.Bar.LeftDivider:Hide()
			SpellTooltipStatusBar.Bar.RightDivider:Hide()
		end
	end
end)

local equipSetsItemColor = CreateColor(0.999, 0.999, 0.592, 0.999)
local grayTextColor = CreateColor(0.501, 0.501, 0.501, 0.999)
local greenTextColor = CreateColor(0, 0.999, 0, 0.999)
local setItemNameBlacklist = {}

GameTooltip_SetScript("OnSetItem", function(self)
	local tooltipName = self:GetName()
	local owner = self:GetOwner()
	local itemName, itemLink = self:GetItem()
	local itemID = itemLink and tonumber(string.match(itemLink, ":(%d+)"))

	local lineWasAdded
	local showAppearanceLine = false

	if itemID then
		local _, canCollect = C_TransmogCollection.PlayerCanCollectSource(itemID);
		if canCollect and not C_TransmogCollection.IsCollectedSource(itemID) then
			showAppearanceLine = true
		end
	end

	if tooltipName then
		local setTextChecked
		local startEquipmentSetLine, endEquipmentSetLine
		local currentSetItems, totalSetItems
		local setNumItems = 0

		if itemName and owner and owner.containerID then
			if not EQUIPMENT_SET_LAST_TOOLTIP[owner.containerID] then
				EQUIPMENT_SET_LAST_TOOLTIP[owner.containerID] = {}
			end

			local slotID = owner.slotID or -1

			EQUIPMENT_SET_LAST_TOOLTIP[owner.containerID][slotID] = {}

			for i = 1, self:NumLines() do
				local line = _G[tooltipName.."TextLeft"..i]
				local text = line:GetText()

				if text then
					local sets = string.match(text, EQUIPMENT_SETS_PATTERN)

					if sets then
						local setsStorage 	= C_Split(sets, ", ")
						EQUIPMENT_SET_LAST_TOOLTIP[owner.containerID][slotID] = setsStorage
						break
					end
				end
			end
		end

		for i = 1, self:NumLines() do
			local line = _G[tooltipName.."TextLeft"..i]

			if line then
				local text = line:GetText()

				if not totalSetItems then
					currentSetItems, totalSetItems = string.match(text, "%((%d+)/(%d+)%)$")

					if totalSetItems then
						currentSetItems = tonumber(currentSetItems)
						totalSetItems = tonumber(totalSetItems)

						startEquipmentSetLine = i + 1
						endEquipmentSetLine = i + totalSetItems
						table.wipe(setItemNameBlacklist)
					end
				end

				do -- set items
					if (startEquipmentSetLine and endEquipmentSetLine) and WithinRange(i, startEquipmentSetLine, endEquipmentSetLine) then
						local setItemName = string.match(text, "%s+(.*)")

						if setItemName then
							local equipmentItemsList = owner and owner.paperDoll and owner.paperDoll.equipmentItemsList or PaperDollFrame.equipmentItemsList
							if equipmentItemsList then
								setItemName = setItemName:lower()
								if equipmentItemsList[setItemName] and not setItemNameBlacklist[setItemName] then
									setItemNameBlacklist[setItemName] = true
									setNumItems = setNumItems + 1
									line:SetTextColor(equipSetsItemColor.r, equipSetsItemColor.g, equipSetsItemColor.b)
								else
									line:SetTextColor(grayTextColor.r, grayTextColor.g, grayTextColor.b)
								end
							end
						end
					end

					if not setTextChecked and endEquipmentSetLine and i >= endEquipmentSetLine then
						if setNumItems > currentSetItems and setNumItems <= totalSetItems then
							local setHeaderLine = _G[tooltipName.."TextLeft"..(startEquipmentSetLine - 1)]
							setHeaderLine:SetText(setHeaderLine:GetText():gsub("%((%d+)/(%d+)%)$", string.format("(%i/%s)", setNumItems, "%2")))
						end
						setTextChecked = true
					end
				end

				if string.match(text, EQUIPMENT_SET_PATTERN) then -- set bonus
					local numRequiredSetItems = tonumber(string.match(text, ITEM_SET_BONUS_GRAY_PATTERN))

					if not numRequiredSetItems and setNumItems > 0 then
						line:SetTextColor(greenTextColor.r, greenTextColor.g, greenTextColor.b)
					elseif numRequiredSetItems and setNumItems >= numRequiredSetItems then
						line:SetTextColor(greenTextColor.r, greenTextColor.g, greenTextColor.b)
					else
						line:SetTextColor(grayTextColor.r, grayTextColor.g, grayTextColor.b)
					end
				end

				if string.find(text, CHARACTER_LINK_ITEM_LEVEL_TOOLTIP) then
					line:SetTextColor(1.0, 0.82, 0, 1)
				end

				local rbgTitle = string.match(text, string.sub(LOCKED_WITH_SPELL, 1, -3).."(.*)")
				if rbgTitle then
					local rankID = GetRatedBattlegroundRankByTitle(rbgTitle)

					if rankID then
						line:SetFormattedText(TOOLTIP_RBG_NEEDRANK, rbgTitle, rankID)

						if not self.merchantSlotIndex then
							line:SetText("")
						end
					end
				elseif text == TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN then
					showAppearanceLine = false
				elseif self.merchantSlotIndex and (string.match(text, ITEM_REQ_ARENA_RATING_PATTERN) or string.match(text, ITEM_REQ_ARENA_RATING_3V3_PATTERN)) then
					local honorPoints, arenaPoints = GetMerchantItemCostInfo(self.merchantSlotIndex)
					local requirementType, requiredRating = C_Item.GetRequiredPVPRating(itemLink, honorPoints, arenaPoints)

					if requirementType == Enum.ItemRequirementType.Removed then
						line:SetText("")
					elseif requirementType ~= Enum.ItemRequirementType.None then
						local rating
						if requirementType == Enum.ItemRequirementType.Battleground then
							rating = select(5, GetRatedBattlegroundRankInfo())
							line:SetFormattedText(ITEM_REQ_ARENA_RATING_3V3, requiredRating)
						elseif requirementType == Enum.ItemRequirementType.Arena then
							rating = math.max(GetArenaRating(1), GetArenaRating(2))
							line:SetFormattedText(ITEM_REQ_ARENA_RATING, requiredRating)
						end

						if rating >= requiredRating then
							line:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
						else
							line:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
						end
					end
				end
			end
		end
	end

	if itemID then
		GameTooltip_OnToyByItemID(self, itemID)
		GameTooltip_OnHeirloomByItemID(self, itemID)

		if C_BattlePass.IsExperienceItem(itemID) then
			local itemExperience = C_BattlePass.GetExperienceItemExpAmount(itemID)
			if itemExperience > 0 then
				local level, levelExp, levelUpExp = C_BattlePass.GetLevelInfo()

				if levelExp + itemExperience >= levelUpExp then
					local newLevel = C_BattlePass.CalculateAddedExperience(itemExperience)
					self:AddLine(string.format(BATTLEPASS_ITEM_ADD_LEVELS, newLevel - level), 0.53, 0.67, 1)
				else
					self:AddLine(string.format(BATTLEPASS_ITEM_EXP_TO_LEVEL, levelUpExp - levelExp), 0.53, 0.67, 1)
				end

				lineWasAdded = true
			end
		end
	end

	if showAppearanceLine then
		self:AddLine(TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN, 0.53, 0.67, 1)
		lineWasAdded = true
	end

	if lineWasAdded then
		self:Show()
	end
end)