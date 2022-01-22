local BASE_HEIGHT = 76;
local BUTTON_HEIGHT = 48;
local BUTTON_SPACING = 1;

LootCasePreviewButtonMixin = {};

function LootCasePreviewButtonMixin:OnLoad()
	self.Background:SetAtlas("PetList-ButtonBackground", true);
	self.HighlightTexture:SetAtlas("PetList-ButtonHighlight", true);
end

function LootCasePreviewButtonMixin:OnEvent()
	self:UpdateCursor();
end

function LootCasePreviewButtonMixin:OnEnter()
	self.HighlightTexture:Show();

	self:RegisterEvent("MODIFIER_STATE_CHANGED");

	self:UpdateCursor();

	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -213);
		GameTooltip:SetHyperlink(self.itemLink);
	end
end

function LootCasePreviewButtonMixin:OnLeave()
	self.HighlightTexture:Hide();

	self:UnregisterEvent("MODIFIER_STATE_CHANGED");

	ResetCursor();

	GameTooltip:Hide();
end

function LootCasePreviewButtonMixin:OnClick()
	if IsModifiedClick() and self.itemLink then
		HandleModifiedItemClick(self.itemLink);
	end
end

function LootCasePreviewButtonMixin:UpdateCursor()
	if IsModifiedClick("DRESSUP") and self.itemLink then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

LootCasePreviewMixin = {};

function LootCasePreviewMixin:IsPreview(itemID)
	return ITEMS_CHEST_LOOT and ITEMS_CHEST_LOOT[itemID];
end

function LootCasePreviewMixin:SetPreview(itemID)
	if not itemID or not ITEMS_CHEST_LOOT[itemID] then
		return;
	end

	self.previewData = ITEMS_CHEST_LOOT[itemID];

	local numGroup = 0;
	for index, itemData in ipairs(self.previewData) do
		if type(itemData) ~= "table" then
			numGroup = numGroup + 1;
			table.remove(self.previewData, index);
		end
	end

	self.numGroup = numGroup;

	local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID);

	PortraitFrameTemplate_SetPortraitToAsset(self, icon);

	local qualityColor = ITEM_QUALITY_COLORS[quality or 1];
	self.ItemName:SetText(name);
	self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b);

	if not self:IsShown() then
		ShowUIPanel(self);
	end

	self:SetPosition();
	self:UpdateScroll();
	self.ScrollFrame.scrollBar:SetValue(0);
end

function LootCasePreviewMixin:SetNumDisplayed(numDisplayed)
	if self.numDisplayed ~= numDisplayed then
		local scrollHeight = (BUTTON_HEIGHT + BUTTON_SPACING) * numDisplayed - BUTTON_SPACING;

		self:SetHeight(BASE_HEIGHT + scrollHeight);
		self.ScrollFrame:SetHeight(scrollHeight);

		HybridScrollFrame_CreateButtons(self.ScrollFrame, "LootCasePreviewButtonTemplate", 1, 0, nil, nil, nil, -1);

		self.numDisplayed = numDisplayed;
	end
end

function LootCasePreviewMixin:SetPosition()
	local x, y = GetCursorPosition();
	x = x / self:GetEffectiveScale();
	y = y / self:GetEffectiveScale();

	local posX = x - 35;
	local posY = y + 90;

	if posY < 405 then
		posY = 405;
	end

	self:ClearAllPoints();
	self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY);
	self:GetCenter();
	self:Raise();
end

function LootCasePreviewMixin:UpdateScroll()
	if not self.previewData then
		return;
	end

	local scrollFrame = self.ScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local index = offset + i;
		local button = buttons[i];

		local itemData = self.previewData[index];
		if itemData then
			local itemID, minCount, maxCount = unpack(itemData);
			local name, itemLink, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID);

			button.itemLink = itemLink;

			button.Icon:SetTexture(icon or "Interface\\ICONS\\INV_Misc_QuestionMark");
			button.Name:SetText(name);

			if minCount > 1 then
				if minCount == maxCount then
					button.Count:SetText(minCount);
				else
					button.Count:SetFormattedText("%d-%d", minCount, maxCount);
				end
			else
				button.Count:SetText("");
			end

			local qualityColor = ITEM_QUALITY_COLORS[quality or 1];
			button.Name:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b);

			if button.HighlightTexture:IsShown() then
				button:GetScript("OnEnter")(button);
			end

			button:Show();
		else
			button:Hide();
		end
	end

	HybridScrollFrame_Update(scrollFrame, (BUTTON_HEIGHT + BUTTON_SPACING) * #self.previewData - BUTTON_SPACING, scrollFrame:GetHeight());
end

function LootCasePreviewMixin:OnLoad()
	self.TitleText:SetPoint("LEFT", 66, 0);
	self.TitleText:SetPoint("RIGHT", -40, 0);

	self:RegisterForDrag("LeftButton");

	ButtonFrameTemplate_HideButtonBar(self);
	PortraitFrameTemplate_SetTitle(self, LOOT_CASE_PREVIEW_TITLE);

	self.ScrollFrame.update = function()
		self:UpdateScroll();
	end

	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

	self:SetNumDisplayed(5);
end