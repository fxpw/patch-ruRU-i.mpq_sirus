UIPanelWindows["LootCasePreviewFrame"] = { area = "left", pushable = 7 };

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
	return itemID and C_Item.IsItemChest(itemID)
end

function LootCasePreviewMixin:SetPreview(itemID)
	if not self:IsPreview(itemID) then
		return;
	end

	local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID);

	self:SetPortraitToAsset(icon)

	local qualityColor = ITEM_QUALITY_COLORS[quality or 1];
	self.ItemName:SetText(name or UNKNOWN);
	self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b);

	self.itemID = itemID

	if not self:IsShown() then
		self:Show()
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
	if not self.itemID then
		return;
	end

	local scrollFrame = self.ScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local numItems = C_Item.GetNumItemChestItems(self.itemID)

	for index, button in ipairs(scrollFrame.buttons) do
		local itemIndex = index + offset
		if itemIndex <= numItems then
			local itemID, amount, amountRangeMax = C_Item.GetItemChestItemData(self.itemID, itemIndex)
			local name, itemLink, quality, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID, false, nil, true, true)

			button.itemLink = itemLink;

			button.Name:SetText(name or UNKNOWN);
			button.Icon:SetTexture(icon or "Interface\\ICONS\\INV_Misc_QuestionMark");

			if amountRangeMax and amountRangeMax ~= amount then
				button.Count:SetFormattedText("%d-%d", amount, amountRangeMax)
			elseif amount > 1 then
				button.Count:SetText(amount)
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

	HybridScrollFrame_Update(scrollFrame, (BUTTON_HEIGHT + BUTTON_SPACING) * numItems - BUTTON_SPACING, scrollFrame:GetHeight());
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