UIPanelWindows["ItemUpgradeFrame"] = { area = "left", pushable = 0, xOffset = "15", yOffset = "-10", width = 538};

function ItemUpgradeFrame_Show()
	ShowUIPanel(ItemUpgradeFrame);
	if not ItemUpgradeFrame:IsShown() then
		C_ItemUpgrade.CloseItemUpgrade();
	end
end

function ItemUpgradeFrame_Hide()
	HideUIPanel(ItemUpgradeFrame);
end

local SHOW_LEFT_ITEMS;

local function GetNumUpgradeItems()
	local totalItems, upgradeItems = 0, 0;

	local function ItemLocationCallback(itemLocation)
		local canUpgrade, upgradeType = C_ItemUpgrade.CanUpgradeItem(itemLocation);
		if canUpgrade then
			if (upgradeType == Enum.ItemUpgradeType.Upgrade or upgradeType == Enum.ItemUpgradeType.Both) then
				upgradeItems = upgradeItems + 1;
			end
			totalItems = totalItems + 1;
		end
	end

	ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);

	return totalItems, upgradeItems;
end

ItemUpgradeMixin = {};

function ItemUpgradeMixin:OnLoad()
	SetPortraitToTexture(self.portrait, "Interface\\Icons\\UI_ItemUpgrade");

	self.Bg:Hide();
	self.TitleText:SetText(ITEM_UPGRADE);

	self.BottomBG:SetAtlas("itemupgrade_bottompanel", true);
	self.BottomBGFlash:SetAtlas("itemupgrade_bottompanel", true);
	self.TopBG:SetAtlas("itemupgrade_toppanel", true);

	self.UpgradeCostFrame.BGTex:SetAtlas("itemupgrade_totalcostbar", true);
	self.UpgradeCostFrame:CreateLabel(ITEM_UPGRADE_COST_LABEL, nil, nil, 5);

	self:RegisterCustomEvent("ITEM_UPGRADE_OPEN");
	self:RegisterCustomEvent("ITEM_UPGRADE_CLOSE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
end

function ItemUpgradeMixin:OnShow()
	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN);
	self:Update();

	ItemButtonUtil.OpenAndFilterBags(self);

	self:RegisterCustomEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:RegisterCustomEvent("GLOBAL_MOUSE_DOWN");
	self:RegisterCustomEvent("ITEM_UPGRADE_FAILED");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");

	self.FrameErrorText:ClearAllPoints();
	self.FrameErrorText:SetPoint("BOTTOM", self.UpgradeCostFrame, "TOP", 0, 12);
end

function ItemUpgradeMixin:OnHide()
	self:UnregisterCustomEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	self:UnregisterCustomEvent("GLOBAL_MOUSE_DOWN");
	self:UnregisterCustomEvent("ITEM_UPGRADE_FAILED");
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("PLAYER_MONEY");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");

	PlaySound(SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE);
	StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	C_ItemUpgrade.CloseItemUpgrade();
	ItemButtonUtil.CloseFilteredBags(self);
	EquipmentFlyout_Hide(self);
	self.upgradeAnimationsInProgress = false;
end

function ItemUpgradeMixin:UpdateIfTargetReached()
	if not self.tooltipReappearTimerInProgress then
		self:Update();
	end
end

function ItemUpgradeMixin:OnEvent(event, arg1)
	if event == "ITEM_UPGRADE_MASTER_SET_ITEM" then
		if not self.upgradeAnimationsInProgress then
			self:Update();
		end
		StaticPopup_Hide("CONFIRM_UPGRADE_ITEM");
	elseif event == "BAG_UPDATE" or event == "PLAYER_MONEY" or event == "CURRENCY_DISPLAY_UPDATE" then
		self:UpdateIfTargetReached();
	elseif event == "ITEM_UPGRADE_FAILED" or event == "DISPLAY_SIZE_CHANGED" or event == "ITEM_UPGRADE_SUCCESS" then
		self:Update();

		if event == "ITEM_UPGRADE_FAILED" then
			local errorID = arg1;
			if errorID then
				local errorText = _G[string.format("ITEM_UPGRADE_ERROR_%d", errorID)];
				if errorText then
					UIErrorsFrame:AddMessage(errorText, 1.0, 0.1, 0.1, 1.0);
				end
			end
		end
	elseif event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = arg1;
		local isRightButton = buttonName == "RightButton";

		local mouseFocus = GetMouseFocus();
		local flyoutSelected = not isRightButton and DoesAncestryInclude(EquipmentFlyout_GetFrame(), mouseFocus);
		if not flyoutSelected then
			EquipmentFlyout_Hide();
		end
	elseif event == "ITEM_UPGRADE_OPEN" then
		ItemUpgradeFrame_Show();
	elseif event == "ITEM_UPGRADE_CLOSE" then
		ItemUpgradeFrame_Hide();
	elseif event == "VARIABLES_LOADED" or event == "CVAR_UPDATE" then
		SHOW_LEFT_ITEMS = tonumber(C_CVar:GetValue("C_CVAR_ITEM_UPGRADE_LEFT_ITEM_LIST")) == 1;
	end
end

local TEXT_MIN_HEIGHT = 12
local TEXT_MAX_HEIGHT = 14
local TEXT_SCALE_UP_TIME = 0.2
local TEXT_SCALE_DOWN_TIME = 0.4
local TEXT_ANIM_TIME = 0.6
function ItemUpgradeMixin:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed < TEXT_ANIM_TIME then
		if self.elapsed <= TEXT_SCALE_UP_TIME then
			local newHeight = floor(TEXT_MIN_HEIGHT + ((TEXT_MAX_HEIGHT - TEXT_MIN_HEIGHT) * self.elapsed / TEXT_SCALE_UP_TIME))
			self.FrameErrorText:SetTextHeight(newHeight)
			self.FrameErrorText:SetWidth(440 * ((newHeight - TEXT_MIN_HEIGHT) / TEXT_MIN_HEIGHT + 1))
		elseif self.elapsed <= TEXT_SCALE_DOWN_TIME then
			local newHeight = floor(TEXT_MAX_HEIGHT - ((TEXT_MAX_HEIGHT- TEXT_MIN_HEIGHT) * (self.elapsed - TEXT_SCALE_UP_TIME) / (TEXT_SCALE_DOWN_TIME - TEXT_SCALE_UP_TIME)))
			self.FrameErrorText:SetTextHeight(newHeight)
			self.FrameErrorText:SetWidth(440 * ((newHeight - TEXT_MIN_HEIGHT) / TEXT_MIN_HEIGHT + 1))
		end
	else
		self.FrameErrorText:SetWidth(440)
		self.FrameErrorText:SetTextHeight(12)

		self.elapsed = 0
		self:SetScript("OnUpdate", nil)
	end
end

function ItemUpgradeMixin:OnConfirm()
	self:PlayUpgradedCelebration();
	C_ItemUpgrade.UpgradeItem(self.targetUpgradeItem);
end

function ItemUpgradeMixin:Update()
	self.upgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();

	if not self.upgradeInfo then
		self:UpdateButtonAndArrowStates(true, false);
		self.ItemInfo:Setup(self.upgradeInfo);

		local numUpgradeItems = GetNumUpgradeItems();
		if SHOW_LEFT_ITEMS and numUpgradeItems > 1 then
			self.UpgradeItemButton:SetNormalTexture("");
			self.UpgradeItemButton:SetPushedTexture("");

			local itemsToUpgrade = {};
			local function ItemLocationCallback(itemLocation)
				local canUpgrade, upgradeType = C_ItemUpgrade.CanUpgradeItem(itemLocation);
				if canUpgrade then
					itemsToUpgrade[#itemsToUpgrade + 1] = itemLocation;
				end
			end
			ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);

			self.LeftPagingFrame:Clear();
			self.LeftItemsListPreviewFrame:Clear();
			self.LeftItemsListPreviewFrame:Setup(itemsToUpgrade);
			self.MissingDescription:Hide();
		else
			self.UpgradeItemButton:SetNormalAtlas("itemupgrade_greenplusicon");
			self.UpgradeItemButton:SetPushedAtlas("itemupgrade_greenplusicon_pressed");

			self.LeftPagingFrame:Hide();
			self.LeftItemsListPreviewFrame:Hide();
			self.MissingDescription:Show();
		end

		SetItemButtonTexture(self.UpgradeItemButton, nil);
		SetItemButtonQuality(self.UpgradeItemButton, nil);
		SetItemButtonTextureVertexColor(self.UpgradeItemButton, 1.0, 1.0, 1.0);
		self.LeftItemPreviewFrame:Hide();
		self.RightItemPreviewFrame.ReappearAnim:Stop();
		self.RightItemPreviewFrame:Hide();
		self.RightPagingFrame:Hide();
		self.RightItemsListPreviewFrame:Hide();
		self.UpgradeCostFrame:Hide();
		self.FrameErrorText:Hide();
		self.Arrow:Hide();
		self.upgradeAnimationsInProgress = false;
		self.targetUpgradeItem = nil;
		return;
	end

	self.LeftPagingFrame:Hide();
	self.LeftItemsListPreviewFrame:Hide();

	self.UpgradeItemButton:SetNormalTexture("");
	self.UpgradeItemButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
	self.UpgradeItemButton.PushedTexture:SetTexCoord(1, 0, 1, 0);

	local numTargetItems = #self.upgradeInfo.upgradeInfos;
	if numTargetItems == 1 then
		self.targetUpgradeItem = 1;
	else
		local selectedItem = C_ItemUpgrade.GetItemUpgradeItemSelection();
		if selectedItem and selectedItem > 0 and selectedItem <= numTargetItems then
			self.targetUpgradeItem = selectedItem;
		else
			self.targetUpgradeItem = nil;
		end
	end

	self.currentUpgradeInfo = self.upgradeInfo;
	self.targetUpgradeInfo = self.targetUpgradeItem and self.upgradeInfo.upgradeInfos[self.targetUpgradeItem];

	self.upgradeInfo.itemQualityColor = ITEM_QUALITY_COLORS[self.upgradeInfo.displayQuality].color;
	self.upgradeInfo.targetQualityColor = self.targetUpgradeInfo and ITEM_QUALITY_COLORS[self.targetUpgradeInfo.displayQuality].color;

	SetItemButtonTexture(self.UpgradeItemButton, self.upgradeInfo.icon);
	SetItemButtonQuality(self.UpgradeItemButton, self.upgradeInfo.displayQuality);

	self.MissingDescription:Hide();
	self:PopulatePreviewFrames();
end

function ItemUpgradeMixin:UpdateButtonAndArrowStates(buttonDisabled, canUpgrade)
	self.pendingButtonEnable = false;

	local isReappearAnimPlaying = self.RightItemPreviewFrame.ReappearAnim:IsPlaying();

	if buttonDisabled then
		self.UpgradeButton:SetEnabled(false);
	elseif not isReappearAnimPlaying then
		self.UpgradeButton:SetEnabled(true);
	else
		self.pendingButtonEnable = true;
	end

	if not canUpgrade then
		self.Arrow:Hide();

		self.UpgradeButton.EnhancementIcon:Hide();
	elseif not isReappearAnimPlaying then
		self.Arrow.arrow.Anim.Translation:SetOffset(25 * self:GetEffectiveScale(), 0);
		if self.Arrow.arrow.Anim:IsPlaying() then
			self.Arrow.arrow.Anim:Stop();
		end
		self.Arrow.arrow.Anim:Play();
		self.Arrow:Show();
	end

	if canUpgrade then
		local texture = self.upgradeInfo.isSaveEnchants and "Interface//CURSOR//Crosshair//Reforge" or "Interface//CURSOR//Crosshair//UnableReforge"
		self.UpgradeButton.EnhancementIcon.IconGlow:SetTexture(texture);
		self.UpgradeButton.EnhancementIcon.Icon:SetTexture(texture);
		self.UpgradeButton.EnhancementIcon:Show();

		if self.UpgradeButton.EnhancementIcon.IconGlow.Anim:IsPlaying() then
			self.UpgradeButton.EnhancementIcon.IconGlow.Anim:Stop()
		end
		self.UpgradeButton.EnhancementIcon.IconGlow.Anim:Play()
	end
end

function ItemUpgradeMixin:PopulatePreviewFrames()
	local failureMessage = self.targetUpgradeInfo and self.targetUpgradeInfo.failureMessage;
	local canUpgradeItem = self.upgradeInfo.itemUpgradeable and not failureMessage;
	local showRightPreview = self.upgradeInfo.itemUpgradeable and self.targetUpgradeItem;
	local canItemsSelection = self.upgradeInfo.canItemsSelection;

	local buttonDisabledState = true;

	if canUpgradeItem then
		buttonDisabledState = not showRightPreview;

		if not showRightPreview then
			buttonDisabledState = canItemsSelection;
		end

		self.FrameErrorText:Hide();
	elseif showRightPreview then
		self.FrameErrorText:Hide();
	else
		self.FrameErrorText:SetText(failureMessage);
		self.FrameErrorText:Show();
	end

	if failureMessage then
		SetItemButtonTextureVertexColor(self.UpgradeItemButton, 0.5, 0, 0);

		self.FrameErrorText:SetText(failureMessage);
		self.FrameErrorText:Show();
	else
		SetItemButtonTextureVertexColor(self.UpgradeItemButton, 1.0, 1.0, 1.0);

		self.FrameErrorText:Hide();
	end

	if self.FrameErrorText:IsShown() then
		self.elapsed = 0
		self:SetScript("OnUpdate", self.OnUpdate)
	else
		self:SetScript("OnUpdate", nil)
	end

	self.ItemInfo:Setup(self.upgradeInfo);

	self.LeftItemPreviewFrame:GeneratePreviewTooltip(false, nil);

	if showRightPreview then
		self.RightPagingFrame:Hide();
		self.RightItemsListPreviewFrame:Hide();

		self.RightItemPreviewFrame:GeneratePreviewTooltip(true, nil);

		if self.RightItemPreviewFrame:GetHeight() > self.LeftItemPreviewFrame:GetHeight() then
			self.LeftItemPreviewFrame:SetHeight(self.RightItemPreviewFrame:GetHeight());
		end
	else
		self.RightPagingFrame:Clear();
		self.RightItemsListPreviewFrame:Clear();
		self.RightItemsListPreviewFrame:Setup(self.upgradeInfo.upgradeInfos);

		self:UpdateButtonAndArrowStates(buttonDisabledState, not canItemsSelection);

		self.RightItemPreviewFrame.ReappearAnim:Stop();
		self.RightItemPreviewFrame:Hide();

		self.UpgradeCostFrame:Hide();
		self.upgradeAnimationsInProgress = false;

		if canItemsSelection then
			return;
		end
	end

	if self.upgradeAnimationsInProgress then
		self.RightItemPreviewFrame:Show();
		self.RightItemPreviewFrame.ReappearAnim:Play();
	end

	self.UpgradeCostFrame:Clear();

	local costTable = self:GetUpgradeCostTable();
	if (showRightPreview or (canUpgradeItem and not canItemsSelection)) and costTable then
		for _, cost in ipairs(costTable) do
			if cost.type == "money" then
				if cost.cost > floor(GetMoney() / (COPPER_PER_SILVER * SILVER_PER_GOLD)) then
					buttonDisabledState = true;
					self.UpgradeCostFrame:AddCurrency(cost.type, nil, cost.cost, RED_FONT_COLOR);
				else
					self.UpgradeCostFrame:AddCurrency(cost.type, nil, cost.cost);
				end
			elseif cost.type == "currency" then
				if cost.cost > GetCurrencyCount(cost.itemID) then
					buttonDisabledState = true;
					self.UpgradeCostFrame:AddCurrency(cost.type, cost.itemID, cost.cost, RED_FONT_COLOR);
				else
					self.UpgradeCostFrame:AddCurrency(cost.type, cost.itemID, cost.cost);
				end
			elseif cost.type == "item" then
				if cost.cost > GetItemCount(cost.itemID) then
					buttonDisabledState = true;
					self.UpgradeCostFrame:AddCurrency(cost.type, cost.itemID, cost.cost, RED_FONT_COLOR);
				else
					self.UpgradeCostFrame:AddCurrency(cost.type, cost.itemID, cost.cost);
				end
			end
		end

		self.UpgradeCostFrame:Show();
	end

	self:UpdateButtonAndArrowStates(buttonDisabledState, showRightPreview or (canUpgradeItem and not canItemsSelection));
end

-- compare 2 strings finding numeric differences
-- return the text of the 2nd string with (+x) after each number that is higher than in the 1st string
function ItemUpgradeMixin:GetUpgradeText(string1, string2)
	local output = "";
	local index2 = 1;	-- where we're at in string2

	local start1, end1, substring1 = string.find(string1, "([%d,%.]+)");
	local start2, end2, substring2 = string.find(string2, "([%d,%.]+)");
	while start1 and start2 do
		output = output..string.sub(string2, index2, start2 - 1);

		local diff;
		if substring1 ~= substring2 then
			-- need to remove , and . because of locale
			local temp1 = gsub(substring1, "[,%.]", "");
			local temp2 = gsub(substring2, "[,%.]", "");
			local number1 = tonumber(temp1);
			local number2 = tonumber(temp2);
			if number1 and number2 and number2 > number1 then
				diff = number2 - number1;
			end
		end

		if diff then
			output = output..string.format("|cff20ff20%s (+%d)|r", substring2, diff);
		else
			output = output..substring2;
		end

		index2 = end2 + 1;

		start1, end1, substring1 = string.find(string1, "([%d,%.]+)", end1 + 1);
		start2, end2, substring2 = string.find(string2, "([%d,%.]+)", end2 + 1);
	end
	output = output .. string.sub(string2, index2, string.len(string2));
	return output;
end

function ItemUpgradeMixin:GetUpgradeCostTable()
	if #self.upgradeInfo.upgradeInfos > 1 and not C_ItemUpgrade.CanItemUpgradeItemsSelection() then
		return self.upgradeInfo.upgradeInfos[1].costsToUpgrade;
	elseif self.targetUpgradeInfo and self.targetUpgradeInfo.costsToUpgrade then
		return self.targetUpgradeInfo.costsToUpgrade;
	end
	return {};
end

function ItemUpgradeMixin:GetUpgradeCostString()
	local currencyStringTable = {};

	for _, cost in ipairs(self:GetUpgradeCostTable()) do
		local hasEnough = true;
		if cost.type == "money" then
			hasEnough = cost.cost <= floor(GetMoney() / (COPPER_PER_SILVER * SILVER_PER_GOLD));
		elseif cost.type == "currency" then
			hasEnough = cost.cost <= GetCurrencyCount(cost.itemID);
		elseif cost.type == "item" then
			hasEnough = cost.cost <= GetItemCount(cost.itemID);
		end

		if not hasEnough then
			table.insert(currencyStringTable, GetCurrencyString(cost.type, cost.itemID, cost.cost, RED_FONT_COLOR_CODE));
		else
			table.insert(currencyStringTable, GetCurrencyString(cost.type, cost.itemID, cost.cost));
		end
	end

	return table.concat(currencyStringTable, " ");
end

local tooltipReappearWaitTime = 1.5;

function ItemUpgradeMixin:PlayUpgradedCelebration()
	self.upgradeAnimationsInProgress = true;

	self.LeftItemPreviewFrame:GeneratePreviewTooltip(true, nil);

	local qualityColor = self.upgradeInfo.targetQualityColor or self.upgradeInfo.itemQualityColor;
	local displayQuality = self.targetUpgradeInfo and self.targetUpgradeInfo.displayQuality or self.upgradeInfo.displayQuality;

	self.ItemInfo.ItemName:SetText(qualityColor:WrapTextInColorCode(self.upgradeInfo.name));
	SetItemButtonQuality(self.UpgradeItemButton, displayQuality);

	if self.LeftItemPreviewFrame.GlowNineSlice.Anim:IsPlaying() then
		self.LeftItemPreviewFrame.GlowNineSlice.Anim:Stop();
	end
	self.LeftItemPreviewFrame.GlowNineSlice.Anim:Play();
	self.RightItemPreviewFrame:Hide();
	self.Arrow:Hide();
	if self.BottomBGFlash.Anim:IsPlaying() then
		self.BottomBGFlash.Anim:Stop();
	end
	self.BottomBGFlash.Anim:Play();

	self.tooltipReappearTimerInProgress = true;
	C_Timer:After(tooltipReappearWaitTime, GenerateClosure(self.OnTooltipReappearTimerComplete, self));
end

function ItemUpgradeMixin:OnTooltipReappearTimerComplete()
	self.tooltipReappearTimerInProgress = false;
	self:UpdateIfTargetReached();
end

function ItemUpgradeMixin:OnTooltipReappearComplete()
	self.Arrow.arrow.Anim.Translation:SetOffset(25 * self:GetEffectiveScale(), 0);
	if self.Arrow.arrow.Anim:IsPlaying() then
		self.Arrow.arrow.Anim:Stop();
	end
	self.Arrow.arrow.Anim:Play();
	self.Arrow:Show();

	if self.pendingButtonEnable then
		self.UpgradeButton:SetEnabled(true);
	end

	self.upgradeAnimationsInProgress = false;
end

ItemUpgradeButtonMixin = {};

function ItemUpgradeButtonMixin:OnClick()
	self:SetEnabled(false);
	local upgradeInfo = ItemUpgradeFrame.upgradeInfo;

	local function StaticPopupItemOnEnter(itemFrame)
		GameTooltip:SetOwner(itemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetUpgradeItem();
		GameTooltip:Show();
	end

	local data = {
		texture = upgradeInfo.icon,
		name = upgradeInfo.name,
		color = {upgradeInfo.itemQualityColor:GetRGBA()},
		link = C_ItemUpgrade.GetItemHyperlink(),
		itemFrameOnEnter = StaticPopupItemOnEnter,
	};

	StaticPopup_Show("CONFIRM_UPGRADE_ITEM", ItemUpgradeFrame:GetUpgradeCostString(), "", data);
end

ItemUpgradeItemButtonMixin = {};

function ItemUpgradeItemButtonMixin:OnLoad()
	local parent = self:GetParent();
	if not parent.Buttons then
		parent.Buttons = {};
	end
	parent.Buttons[#parent.Buttons + 1] = self;

	self.HighlightTexture:SetAtlas("PetList-ButtonHighlight")
end

function ItemUpgradeItemButtonMixin:OnClick(button)
	if self.id then
		C_ItemUpgrade.SetItemUpgradeItemSelection(self.id);
	elseif self.itemLocation then
		C_ItemUpgrade.SetItemUpgradeFromLocation(self.itemLocation);
	end
end

function ItemUpgradeItemButtonMixin:OnEnter()
	if self.itemID then
		GameTooltip:SetOwner(self.IconFrame, "ANCHOR_RIGHT");
		C_ItemUpgrade.SetUpgradeItemListTooltip(self.index);
	elseif self.numItems then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(string.format(UPGRADE_RANDOM_ITEM_NUM_ITEMS, self.numItems), 1, 1, 1);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(UPGRADE_RANDOM_ITEM_TO_GO_ITEM, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, 1);
		GameTooltip:Show();
	elseif self.itemLocation then
		local itemLink = C_Item.GetItemLink(self.itemLocation);
		if itemLink then
			GameTooltip:SetOwner(self.IconFrame, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(itemLink);
			GameTooltip:Show();
		end
	end
end

function ItemUpgradeItemButtonMixin:OnLeave()
	GameTooltip:Hide();
end

local ITEMS_LIST_PER_PAGE = 4;

ItemUpgradeItemsListPreviewFrameMixin = {};

function ItemUpgradeItemsListPreviewFrameMixin:OnLoad()
	local parent = self:GetParent();
	local pagingFrame = parent[self:GetAttribute("PagingFrameKey")]
	self.PagingFrame = pagingFrame;
	pagingFrame.ListFrame = self;
end

function ItemUpgradeItemsListPreviewFrameMixin:Clear()
	self.itemsListInfos = nil;

	for i = 1, #self.Buttons do
		self.Buttons[i]:Hide();
	end
end

function ItemUpgradeItemsListPreviewFrameMixin:Setup(itemsListInfos)
	if not itemsListInfos or #itemsListInfos == 0 then
		self:Clear();
		self:Hide();
		return;
	end

	self.itemsListInfos = itemsListInfos;

	if self.PagingFrame then
		self.PagingFrame:SetMaxPages(ceil(#itemsListInfos / ITEMS_LIST_PER_PAGE));
	end

	if self.Update then
		self:Update();
	end

	self:Show();
end

ItemUpgradeLeftItemsListPreviewFrameMixin = CreateFromMixins(ItemUpgradeItemsListPreviewFrameMixin);

function ItemUpgradeLeftItemsListPreviewFrameMixin:Update()
	if not self.itemsListInfos then
		return;
	end

	local itemIndex = (self.PagingFrame:GetCurrentPage() - 1) * ITEMS_LIST_PER_PAGE;

	for i = 1, ITEMS_LIST_PER_PAGE do
		local index = itemIndex + i;
		local itemLocation = self.itemsListInfos[index];

		local button = self.Buttons[i];

		if itemLocation and C_Item.DoesItemExist(itemLocation) then
			local itemName = C_Item.GetItemName(itemLocation);
			local itemIcon = C_Item.GetItemIcon(itemLocation);
			local itemQuality = C_Item.GetItemQuality(itemLocation) or 1;

			local itemQualityColor = ITEM_QUALITY_COLORS[itemQuality].color;

			button.Name:SetText(itemQualityColor:WrapTextInColorCode(itemName));

			button.IconFrame.Icon:SetTexture(itemIcon);
			SetItemButtonQuality(button.IconFrame, itemQuality);

			button.IconFrame.RoleIcon:Hide();
			button.IconFrame.SpecIcon:Hide();
			button.CostText:Hide();

			local _, upgradeType = C_ItemUpgrade.CanUpgradeItem(itemLocation);
			button.IconFrame.UpgradeIcon:SetShown(upgradeType == Enum.ItemUpgradeType.Upgrade or upgradeType == Enum.ItemUpgradeType.Both);

			if GameTooltip:GetOwner() == button.IconFrame then
				button:GetScript("OnEnter")(button);
			end

			button.itemLocation = itemLocation;

			button:Show();
		else
			button.itemLocation = nil;

			button:Hide();
		end
	end

	self.PagingFrame:Update();
end

ItemUpgradeRightItemsListPreviewFrameMixin = CreateFromMixins(ItemUpgradeItemsListPreviewFrameMixin);

local roleNameToIconID = {
	"DAMAGER",
	"RANGEDAMAGER",
	"TANK",
	"HEALER"
};

function ItemUpgradeRightItemsListPreviewFrameMixin:Update()
	if not self.itemsListInfos then
		return;
	end

	local canItemsSelection = C_ItemUpgrade.CanItemUpgradeItemsSelection();
	local selectedItem = C_ItemUpgrade.GetItemUpgradeItemSelection();
	local canShowCostText = canItemsSelection and not selectedItem;

	local itemIndex = (self.PagingFrame:GetCurrentPage() - 1) * ITEMS_LIST_PER_PAGE;

	for i = 1, ITEMS_LIST_PER_PAGE do
		local index = itemIndex + i;
		local targetItemInfo = self.itemsListInfos[index];

		local button = self.Buttons[i];

		if targetItemInfo then
			local itemQualityColor = ITEM_QUALITY_COLORS[targetItemInfo.displayQuality].color;

			if C_Service:IsGM() then
				button.Name:SetFormattedText("%s (%s)", itemQualityColor:WrapTextInColorCode(targetItemInfo.name), targetItemInfo.realmFlag);
			else
				button.Name:SetText(itemQualityColor:WrapTextInColorCode(targetItemInfo.name));
			end

			button.IconFrame.Icon:SetTexture(targetItemInfo.icon);
			SetItemButtonQuality(button.IconFrame, targetItemInfo.displayQuality);

			if targetItemInfo.failureMessage then
				SetItemButtonTextureVertexColor(button.IconFrame, 0.5, 0, 0);
			else
				SetItemButtonTextureVertexColor(button.IconFrame, 1.0, 1.0, 1.0);
			end

			if targetItemInfo.iconID and targetItemInfo.iconID ~= 0 then
				button.IconFrame.RoleIcon:SetTexCoord(GetTexCoordsForRole(roleNameToIconID[targetItemInfo.iconID]));
				button.IconFrame.RoleIcon:Show();
			else
				button.IconFrame.RoleIcon:Hide();
			end

			if targetItemInfo.specID and targetItemInfo.specID ~= 0 then
				local _, icon = GetTalentTabInfo(targetItemInfo.specID);
				button.IconFrame.SpecIcon.Texture:SetTexture(icon);
				button.IconFrame.SpecIcon:Show();
			else
				button.IconFrame.SpecIcon:Hide();
			end

			button.IconFrame.UpgradeIcon:SetShown(targetItemInfo.itemLevelIncrement > 0);

			if canShowCostText then
				local costsString = {};
				for costIndex, cost in ipairs(targetItemInfo.costsToUpgrade) do
					costsString[costIndex] = GetCurrencyString(cost.type, cost.itemID, cost.cost);
				end

				button.CostText:SetText(table.concat(costsString, "  "));
			else
				button.CostText:SetText("");
			end

			button:SetEnabled(canItemsSelection);

			button.index = index;
			button.id = targetItemInfo.index;
			button.itemID = targetItemInfo.itemID;
			button.numItems = targetItemInfo.numItems;

			if GameTooltip:GetOwner() == button.IconFrame then
				button:GetScript("OnEnter")(button);
			end

			button:Show();
		else
			button:Hide();
		end
	end

	self.PagingFrame:Update();
end

ItemUpgradePagingFrameMixin = {};

function ItemUpgradePagingFrameMixin:OnLoad()
	self.maxPages = 1;
	self.currentPage = 1;
end

function ItemUpgradePagingFrameMixin:Clear()
	self.maxPages = 1;
	self.currentPage = 1;

	self:Hide();
end

function ItemUpgradePagingFrameMixin:SetMaxPages(maxPages)
	maxPages = math.max(maxPages, 1);
	if self.maxPages == maxPages then
		return;
	end
	self.maxPages = maxPages;

	if self.maxPages < self.currentPage then
		self.currentPage = self.maxPages;
	end
end

function ItemUpgradePagingFrameMixin:GetMaxPages()
	return self.maxPages;
end

function ItemUpgradePagingFrameMixin:SetCurrentPage(page)
	page = Clamp(page, 1, self.maxPages);
	if self.currentPage ~= page then
		self.currentPage = page;

		if self.ListFrame and self.ListFrame.Update then
			self.ListFrame:Update();
		end

		if self.Update then
			self:Update();
		end
	end
end

function ItemUpgradePagingFrameMixin:GetCurrentPage()
	return self.currentPage;
end

function ItemUpgradePagingFrameMixin:NextPage()
	self:SetCurrentPage(self.currentPage + 1, true);
end

function ItemUpgradePagingFrameMixin:PreviousPage()
	self:SetCurrentPage(self.currentPage - 1, true);
end

function ItemUpgradePagingFrameMixin:SetShownBackButton(shown)
	if shown then
		self.NextPageButton:ClearAllPoints();
		self.NextPageButton:SetPoint("RIGHT", self.BackButton, "LEFT", -3, 0);
		self:SetWidth(84);
	else
		self.NextPageButton:ClearAllPoints();
		self.NextPageButton:SetPoint("RIGHT", self, 0, 0);
		self:SetWidth(55);
	end

	self.BackButton:SetShown(shown);
end

function ItemUpgradePagingFrameMixin:Update()
	self.PrevPageButton:SetShown(self.maxPages > 1);
	self.NextPageButton:SetShown(self.maxPages > 1);

	if self.currentPage <= 1 then
		self.PrevPageButton:Disable();
	else
		self.PrevPageButton:Enable();
	end
	if self.currentPage >= self.maxPages then
		self.NextPageButton:Disable();
	else
		self.NextPageButton:Enable();
	end

	self:Show();
end

function ItemUpgradePagingFrameMixin:OnMouseWheel(delta)
	if delta > 0 then
		self:PreviousPage();
	else
		self:NextPage();
	end
end

ItemUpgradeLeftPagingFrameMixin = CreateFromMixins(ItemUpgradePagingFrameMixin);

function ItemUpgradeLeftPagingFrameMixin:OnLoad()
	self:SetShownBackButton(false);
end

ItemUpgradeRightPagingFrameMixin = CreateFromMixins(ItemUpgradePagingFrameMixin);

function ItemUpgradeRightPagingFrameMixin:Update()
	local selectedItem = C_ItemUpgrade.GetItemUpgradeItemSelection();
	self:SetShownBackButton(selectedItem and selectedItem < 0);

	ItemUpgradePagingFrameMixin.Update(self);
end

ItemUpgradePreviewMixin = {};

function ItemUpgradePreviewMixin:OnLoad()

end

function ItemUpgradePreviewMixin:OnShow()
	if self.GlowNineSlice.Anim then
		self.GlowNineSlice.Anim:Stop();
		self.GlowNineSlice:SetAlpha(0);
	end
end

function ItemUpgradePreviewMixin:OnEnter()
	if self.truncated then
		ItemUpgradeFrame.ItemHoverPreviewFrame:GeneratePreviewTooltip(self.isUpgrade, self);
	end
end

function ItemUpgradePreviewMixin:OnLeave()
	ItemUpgradeFrame.ItemHoverPreviewFrame:Hide();
end

local MAX_TOOLTIP_TRUNCATION_HEIGHT = 195;
local TOOLTIP_MIN_WIDTH = 226;
local TOOLTIP_LINE_HEIGHT = 17;
local TOOLTIP_LINE_SPACING = 5;

function ItemUpgradePreviewMixin:GeneratePreviewTooltip(isUpgrade, parentFrame)
	local upgradeInfo = ItemUpgradeFrame.upgradeInfo;
	local currentItemLevel = C_ItemUpgrade.GetItemUpgradeCurrentLevel();
	local upgradeLevelInfo = isUpgrade and ItemUpgradeFrame.targetUpgradeInfo or ItemUpgradeFrame.currentUpgradeInfo;

	if parentFrame then
		self:SetOwner(parentFrame, "ANCHOR_NONE");
		self:SetPoint("LEFT", parentFrame, "RIGHT", 0, 0);
	else
		self:SetOwner(ItemUpgradeFrame, "ANCHOR_PRESERVE");
	end

	self:SetMinimumWidth(TOOLTIP_MIN_WIDTH, 1);

	local itemQualityColor = isUpgrade and upgradeInfo.targetQualityColor or upgradeInfo.itemQualityColor;

	GameTooltip_AddDisabledLine(self, isUpgrade and ITEM_UPGRADE_NEXT_UPGRADE or ITEM_UPGRADE_CURRENT);
	GameTooltip_AddColoredLine(self, upgradeLevelInfo.name, itemQualityColor);

	self:Show();

	self:ApplyColorToGlowNiceSlice(itemQualityColor);

	local itemLevelUpgraded = isUpgrade and (upgradeLevelInfo.itemLevelIncrement > 0);
	if itemLevelUpgraded then
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_ITEM_LEVEL_BONUS_STAT_FORMAT:format(currentItemLevel + upgradeLevelInfo.itemLevelIncrement, upgradeLevelInfo.itemLevelIncrement), false);
	else
		GameTooltip_AddNormalLine(self, ITEM_UPGRADE_ITEM_LEVEL_STAT_FORMAT:format(currentItemLevel), false);
	end

	-- Stats ----------------------------------------------------------------------------------------------
	for _, statLine in ipairs(upgradeLevelInfo.stats) do
		if statLine.active then
			GameTooltip_AddHighlightLine(self, statLine.displayString, false);
		end
	end

	local isShownHelpTip = not parentFrame and isUpgrade and C_ItemUpgrade.CanItemUpgradeItemsSelection();

	local effectText = nil;
	for index = 1, C_ItemUpgrade.GetNumItemUpgradeEffects() do
		local originalText, upgradeText = C_ItemUpgrade.GetItemUpgradeEffect(index);
		if isUpgrade and originalText and upgradeText then
			effectText = ItemUpgradeFrame:GetUpgradeText(originalText, upgradeText);
			break;
		elseif originalText then
			effectText = originalText;
			break;
		end
	end

	local bigText;
	if not parentFrame then
		bigText = isUpgrade and ItemUpgradeFrame.RightPreviewBigText or ItemUpgradeFrame.LeftPreviewBigText;
		bigText:Hide();
	end

	if effectText then
		GameTooltip_AddBlankLineToTooltip(self);
	end

	self.truncated = false;

	if effectText then
		if bigText then
			self:Show();

			bigText:ClearAllPoints();
			bigText:SetPoint("TOP", self, "TOP", 0, 0);

			local maxTooltipHeight = MAX_TOOLTIP_TRUNCATION_HEIGHT;
			if not isShownHelpTip then
				maxTooltipHeight = maxTooltipHeight + 28;
			end

			local tooltipHeight = self:GetHeight();
			local maxTextHeight = maxTooltipHeight - tooltipHeight;
			bigText:SetHeight(0);
			bigText:SetText(effectText);

			if bigText:GetHeight() > maxTextHeight then
				self.truncated = true;

				bigText:SetHeight(maxTextHeight);

				GameTooltip_InsertFrame(self, bigText);

				self:Show();

				local diffTooltipHeight = self:GetHeight() - tooltipHeight;
				if diffTooltipHeight < maxTextHeight then
					bigText:SetHeight(diffTooltipHeight);
				end
			else
				GameTooltip_AddHighlightLine(self, effectText, true);
			end
		else
			GameTooltip_AddHighlightLine(self, effectText, true);
		end
	end

	if (not isUpgrade and SHOW_LEFT_ITEMS) or isShownHelpTip then
		GameTooltip_AddBlankLineToTooltip(self);
		GameTooltip_AddDisabledLine(self, ITEM_UPGRADE_RIGHT_CLICK_RETURN_TO_ITEM_LIST);
	end

	self:Show();
end

function ItemUpgradePreviewMixin:ApplyColorToGlowNiceSlice(color)
	if self.GlowNineSlice then
		for _, region in ipairs({self.GlowNineSlice:GetRegions()}) do
			region:SetVertexColor(color:GetRGBA());
		end
	end
end

LeftItemUpgradePreviewMixin = CreateFromMixins(ItemUpgradePreviewMixin);

function LeftItemUpgradePreviewMixin:OnLoad()
	ItemUpgradePreviewMixin.OnLoad(self);

	self.isUpgrade = false;
end

function LeftItemUpgradePreviewMixin:OnMouseUp(button)
	if button == "RightButton" and SHOW_LEFT_ITEMS then
		C_ItemUpgrade.ClearItemUpgrade();
	end
end

RightItemUpgradePreviewMixin = CreateFromMixins(ItemUpgradePreviewMixin);

function RightItemUpgradePreviewMixin:OnLoad()
	ItemUpgradePreviewMixin.OnLoad(self);

	self.isUpgrade = true;
end

function RightItemUpgradePreviewMixin:OnMouseUp(button)
	if button == "RightButton" then
		if C_ItemUpgrade.CanItemUpgradeItemsSelection() then
			C_ItemUpgrade.SetItemUpgradeItemSelection(nil);
		end
	end
end

ItemUpgradeSlotMixin = {};

function ItemUpgradeSlotMixin:OnLoad()
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");

	self.ButtonFrame:SetAtlas("itemupgrade_slotborder", true);

	local function SetUpgradeableItemCallback(button)
		local location = button:GetItemLocation();
		C_ItemUpgrade.SetItemUpgradeFromLocation(location);
	end

	-- itemSlot is required by the API, but unused in this context.
	local function GetUpgradeableItemsCallback(itemSlot, resultsTable)
		self:GetItemUpgradeItemsCallBack(resultsTable);
	end

	--Using parent for the API
	self:GetParent().flyoutSettings = {
		customFlyoutOnUpdate = nop,
		hasPopouts = true,
		parent = self:GetParent():GetParent(),
		anchorX = 20,
		anchorY = -8,
		useItemLocation = true,
		hideFlyoutHighlight = true,
		alwaysHideOnClick = true,
		getItemsFunc = GetUpgradeableItemsCallback,
		onClickFunc = SetUpgradeableItemCallback,
	};
end

function ItemUpgradeSlotMixin:GetItemUpgradeItemsCallBack(resultsTable)
	local function ItemLocationCallback(itemLocation)
		local canUpgrade, upgradeType = C_ItemUpgrade.CanUpgradeItem(itemLocation);
		if canUpgrade and (upgradeType == Enum.ItemUpgradeType.Upgrade or upgradeType == Enum.ItemUpgradeType.Both) then
			resultsTable[itemLocation] = C_Item.GetItemLink(itemLocation);
		end
	end

	ItemUtil.IteratePlayerInventoryAndEquipment(ItemLocationCallback);
end

function ItemUpgradeSlotMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local itemLink = C_ItemUpgrade.GetItemHyperlink();
	if itemLink then
		GameTooltip:SetHyperlink(itemLink);
	end
	GameTooltip:Show();
end

function ItemUpgradeSlotMixin:OnLeave()
	GameTooltip:Hide();
end

function ItemUpgradeSlotMixin:OnClick(buttonName)
	if buttonName == "RightButton" then
		C_ItemUpgrade.ClearItemUpgrade();
	else
		local cursorItem = C_Cursor.GetCursorItem();
		if cursorItem then
			if C_ItemUpgrade.CanUpgradeItem(C_Cursor.GetCursorItem()) then
				C_ItemUpgrade.SetItemUpgradeFromCursorItem();
				ClearCursor();
			end
		else
			if not SHOW_LEFT_ITEMS then
				EquipmentFlyout_Show(self);
			end
		end
	end

	if GameTooltip:GetOwner() == self then
		self:GetScript("OnEnter")(self);
	end
end

function ItemUpgradeSlotMixin:OnDrag()
	local cursorItem = C_Cursor.GetCursorItem();
	if cursorItem then
		C_ItemUpgrade.SetItemUpgradeFromCursorItem();
		GameTooltip:Hide();
	end
end

ItemUpgradeItemInfoMixin = CreateFromMixins(ResizeLayoutMixin);

function ItemUpgradeItemInfoMixin:Setup(upgradeInfo)
	if not upgradeInfo then
		self.MissingItemText:Show();
		self.MissingItemText:SetFormattedText(UPGRADE_MISSING_ITEM, select(2, GetNumUpgradeItems()));

		self.ItemName:Hide();
	else
		self.MissingItemText:Hide();

		self.ItemName:SetText(upgradeInfo.itemQualityColor:WrapTextInColorCode(upgradeInfo.name));
		self.ItemName:Show();
	end

	self:MarkDirty();
end
