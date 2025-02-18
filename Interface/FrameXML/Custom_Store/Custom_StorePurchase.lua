local C_StorePublic = C_StorePublic
local C_StoreSecure = C_StoreSecure

local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient

local PRODUCT_TEMPLATE = {
	Default = {
		name = "Default",
		template = "StoreProductPurchaseTypeDefaultTemplate",
		width = 364,
		order = 0,
	},
	SimpleText = {
		name = "SimpleText",
		template = "StoreProductPurchaseTypeSimpleTextTemplate",
		width = 364,
		order = 0,
	},
	Subscription = {
		name = "Subscription",
		template = "StoreProductPurchaseTypeSubscriptionTemplate",
		width = 364,
		order = 0,
	},
	ItemList = {
		name = "ItemList",
		template = "StoreProductPurchaseTypeItemListTemplate",
		width = 580,
		order = 0,
	},
	ItemTooltip = {
		name = "ItemTooltip",
		template = "StoreProductPurchaseTypeItemTooltipTemplate",
		width = 580,
		order = 0,
	},
	Spec = {
		name = "Spec",
		template = "StoreProductPurchaseTypeSpecTemplate",
		width = 580,
		order = 0,
	},
}

local OPTION_TEMPLATE = {
	Gift = {
		name = "Gift",
		template = "StoreProductOptionGiftTemplate",
		order = 7,
	},
	CurrencySelector = {
		name = "CurrencySelector",
		template = "StoreProductOptionCurrencySelectorTemplate",
		order = 8,
	},
	Amount = {
		name = "Amount",
		template = "StoreProductOptionAmountTemplate",
		order = 9,
	},
}

local PRODUCT_FRAME_BASE_HEIGHT = 37
local PRODUCT_FRAME_OPTION_PADDING = 15
local PRODUCT_WIDGET_OFFSET_Y = -15

local PRODUCT_DEFAULT_CURRENCY_INDEX = 0

StoreProductPurchaseTypeBaseMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreProductPurchaseTypeBaseMixin:IsProductMasterWidget()
	return true
end

function StoreProductPurchaseTypeBaseMixin:GetTopPanel()
	return self.TopPanel
end

function StoreProductPurchaseTypeBaseMixin:GetOptionPanel()
	return self.OptionPanel
end

StoreProductOptionWidgetBaseMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreProductOptionWidgetBaseMixin:IsProductMasterWidget()
	return false
end

function StoreProductOptionWidgetBaseMixin:SetActive(state)
	self.__active = state
end

function StoreProductOptionWidgetBaseMixin:IsActive()
	return not not self.__active
end

function StoreProductOptionWidgetBaseMixin:Reset()
end

StoreProductPurchaseItemButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreProductPurchaseItemButtonMixin:OnLoad()
	self.Shine:SetAtlas("PKBT-Store-ItemShineBackdrop", true)
	self.Border:SetAtlas("PKBT-ItemBorder-Normal", true)
	self.UpdateTooltip = self.OnEnter
end

function StoreProductPurchaseItemButtonMixin:SetProduct(product)
	if product.itemID then
		local name, link, rarity, level, minLevel, itemType, itemSubType, stackCount, equipLoc, texture, vendorPrice = GetItemInfo(product.itemID)
		self.Name:SetText(name or UNKNOWN)
		self.Icon:SetTexture(texture or [[Interface\Icons\INV_Misc_QuestionMark]])
		self.Amount:SetText(product.amount and product.amount > 1 and product.amount or "")
		self.itemLink = link
		self.productID = product.productID
	else
		self.Name:SetText(product.name or UNKNOWN)
		self.Icon:SetTexture(product.icon or [[Interface\Icons\INV_Misc_QuestionMark]])
		self.Amount:SetText("")
		self.itemLink = nil
	end
end

function StoreProductPurchaseItemButtonMixin:OnEnter()
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		if self.productID and (IsGMAccount() or IsInterfaceDevClient()) then
			GameTooltip:AddDoubleLine("ProductID", self.productID, 0.44, 0.54, 0.68, 1, 1, 1)
			local flags, dynamicFlags = C_StoreSecure.GetProductFlags(self.productID)
			if flags then
				GameTooltip:AddDoubleLine("ProductFlags", string.format("0x%x", flags), 0.44, 0.54, 0.68, 1, 1, 1)
			end
			if dynamicFlags then
				GameTooltip:AddDoubleLine("ProductDynFlags", string.format("0x%x", dynamicFlags), 0.44, 0.54, 0.68, 1, 1, 1)
			end
		end
		GameTooltip:Show()
	end
	CursorUpdate(self)
end

function StoreProductPurchaseItemButtonMixin:OnLeave()
	if self.itemLink then
		GameTooltip_Hide()
	end
	ResetCursor()
end

function StoreProductPurchaseItemButtonMixin:OnClick(button)
--	local link = C_StoreSecure.GenerateProductHyperlink(item.productID)
	if self.itemLink then
		if IsAltKeyDown() and C_StoreSecure.AddProductItems(self.productID) then
			return
		end
		if IsModifiedClick("CHATLINK") then
			if ChatEdit_InsertLink(self.itemLink) then
				return true
			end
		end
		if IsModifiedClick("DRESSUP") then
			self:GetParent():GetOwner():DressUpItemLink(self.itemLink)
			return true
		end
	end
end

StoreProductPurchaseTypeDefaultMixin = CreateFromMixins(StoreProductPurchaseTypeBaseMixin)

function StoreProductPurchaseTypeDefaultMixin:OnLoad()
	Mixin(self.TopPanel, StoreProductOptionWidgetBaseMixin)
end

function StoreProductPurchaseTypeDefaultMixin:SetProduct(product)
	self.TopPanel.Item:SetProduct(product)
end

StoreProductPurchaseTypeSimpleTextMixin = CreateFromMixins(StoreProductPurchaseTypeBaseMixin)

function StoreProductPurchaseTypeSimpleTextMixin:OnLoad()
	Mixin(self.TopPanel, StoreProductOptionWidgetBaseMixin)
	Mixin(self.OptionPanel, StoreProductOptionWidgetBaseMixin)

	self.OptionPanel.Text:SetWidth(PRODUCT_TEMPLATE.SimpleText.width - 44)
end

function StoreProductPurchaseTypeSimpleTextMixin:OnShow()
	self.OptionPanel:SetHeight(self.OptionPanel.Text:GetHeight() + 30)
	self:GetOwner():UpdateFrameRect(true)
end

function StoreProductPurchaseTypeSimpleTextMixin:SetProduct(product)
	self.TopPanel.Item.Name:SetFormattedText(product.name)
	self.OptionPanel.Text:SetText(product.description)

	if product.atlas then
		self.TopPanel.Item.Icon:SetAtlas(product.atlas)
	else
		self.TopPanel.Item.Icon:SetTexture(product.icon or [[Interface\Icons\INV_Misc_QuestionMark]])
	end
end

StoreProductPurchaseTypeSubscriptionMixin = CreateFromMixins(StoreProductPurchaseTypeBaseMixin)

function StoreProductPurchaseTypeSubscriptionMixin:OnLoad()
	Mixin(self.TopPanel, StoreProductOptionWidgetBaseMixin)
	Mixin(self.OptionPanel, StoreProductOptionWidgetBaseMixin)

	self.OptionPanel.Text:SetWidth(PRODUCT_TEMPLATE.Subscription.width - 44)
end

function StoreProductPurchaseTypeSubscriptionMixin:OnShow()
	self.OptionPanel:SetHeight(self.OptionPanel.Text:GetHeight() + 30)
	self:GetOwner():UpdateFrameRect(true)
end

function StoreProductPurchaseTypeSubscriptionMixin:SetProduct(product)
	local subscriptionDays = product.days

	if product.optionIndex ~= 3 then
		local subscriptionIndex = C_StoreSecure.GetSubscriptionIndexByID(product.subscriptionID)
		if subscriptionIndex then
			local days, isTrial, price, originalPrice, currencyType, productID = C_StoreSecure.GetSubscriptionOptionInfo(subscriptionIndex, product.optionIndex)
			if productID == product.productID then
				subscriptionDays = days
			end
		end
	end

	self.TopPanel.Item.Name:SetFormattedText(STORE_PRODUCT_PURCHASE_SUBSCRIPTION_NAME, product.name, subscriptionDays)

	if product.optionIndex == 3 then
		self.OptionPanel.Text:SetFormattedText(STORE_PRODUCT_PURCHASE_SUBSCRIPTION_DESCRIPTION_EXTRA, product.name)
	else
		self.OptionPanel.Text:SetFormattedText(STORE_PRODUCT_PURCHASE_SUBSCRIPTION_DESCRIPTION_DEFAULT, product.name)
	end

	if product.atlas then
		self.TopPanel.Item.Icon:SetAtlas(product.atlas)
	else
		self.TopPanel.Item.Icon:SetTexture(product.icon or [[Interface\Icons\INV_Misc_QuestionMark]])
	end
end

StoreProductPurchaseTypeItemListMixin = CreateFromMixins(StoreProductPurchaseTypeBaseMixin)

function StoreProductPurchaseTypeItemListMixin:OnLoad()
	Mixin(self.TopPanel, StoreProductOptionWidgetBaseMixin)
	Mixin(self.OptionPanel, StoreProductOptionWidgetBaseMixin)

	self.BUTTON_OFFSET_Y = 9
	self.dirty = true

	self.OptionPanel.Scroll.ScrollBar:SetBackgroundShown(false)
	self.OptionPanel.Scroll.update = function(scrollFrame)
		self:UpdateItemList()
	end
	self.OptionPanel.Scroll.ScrollBar.doNotHide = true
	self.OptionPanel.Scroll.scrollBar = self.OptionPanel.Scroll.ScrollBar
	HybridScrollFrame_CreateButtons(self.OptionPanel.Scroll, "StoreProductItemPlateTemplate", 0, 0, nil, nil, nil, -self.BUTTON_OFFSET_Y)

	self.OptionPanel.Reset = function()
		self:Reset()
	end
end

function StoreProductPurchaseTypeItemListMixin:SetProduct(product)
	self.TopPanel.Item:SetProduct(product)
	self.itemList = product.details and product.details.items
	self.dirty = true
	self:UpdateItemList()
end

function StoreProductPurchaseTypeItemListMixin:UpdateItemList()
	local scrollFrame = self.OptionPanel.Scroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local items = self.itemList[0]
	local numItems = #items
	local mouseFocus = GetMouseFocus()

	for index, button in ipairs(scrollFrame.buttons) do
		local itemIndex = index + offset
		if itemIndex <= numItems then
			button:SetOwner(self)
			button:SetID(itemIndex)

			local itemData = items[itemIndex]
			if itemData.isCurrency then
				local name, description, link, texture, iconAtlas = C_StorePublic.GetCurrencyInfo(itemData.itemID)
				local rarity = 1
				button:SetItem(name, link, rarity, texture, itemData.amount)
			else
				local name, link, rarity, _, _, _, _, _, _, texture = GetItemInfo(itemData.itemID)
				button:SetItem(name, link, rarity, texture, itemData.amount)
			end

			button:Show()

			if button == mouseFocus then
				button:OnEnter()
			end
		else
			button:Hide()
		end
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		local scrollHeight = buttonHeight * numItems + self.BUTTON_OFFSET_Y * (numItems - 1) + self.BUTTON_OFFSET_Y / 3
		HybridScrollFrame_Update(scrollFrame, scrollHeight, scrollFrame:GetHeight())
		self.dirty = nil
	end
end

function StoreProductPurchaseTypeItemListMixin:Reset()
	self.OptionPanel.Scroll.ScrollBar:SetValue(0)
end

StoreProductPurchaseTypeItemTooltipMixin = CreateFromMixins(StoreProductPurchaseTypeBaseMixin)

function StoreProductPurchaseTypeItemTooltipMixin:OnLoad()
	Mixin(self.TopPanel, StoreProductOptionWidgetBaseMixin)
	Mixin(self.OptionPanel, StoreProductOptionWidgetBaseMixin)

	self.topPanelHeightBase = self.TopPanel:GetHeight()
	self.topPanelHeight = self.topPanelHeightBase

	self.OptionPanel.ItemTooltip.owner = self
	self.OptionPanel.ItemTooltip:SetFrameStrata(self:GetFrameStrata())
	self.OptionPanel.ItemTooltip:SetPadding(16)
	self.OptionPanel.ItemTooltip:SetMinimumWidth(self.OptionPanel.ItemTooltip:GetWidth())

	self.OptionPanel.ItemTooltip.IconBorder:SetAtlas("PKBT-ItemBorder-Normal", true)

	self:ApplyColorToGlowNiceSlice(1, 0.82, 0, 0.5)
end

function StoreProductPurchaseTypeItemTooltipMixin:OnShow()
	local topPanelHeight = math.max(self.topPanelHeightBase, Round(self.TopPanel.Text:GetHeight() + self.TopPanel.Title:GetHeight() + 30))
	self.TopPanel:SetHeight(topPanelHeight)

	self.TopPanel.Text:SetPoint("CENTER", 0, -(7 + self.TopPanel.Title:GetHeight()) / 2)

	if self.topPanelHeight ~= topPanelHeight then
		self.topPanelHeight = topPanelHeight
		self:GetOwner():UpdateFrameRect(true)
	end

	self:UpdateTooltipRect()

	if self.OptionPanel.ItemTooltip.GlowNineSlice.Anim:IsPlaying() then
		self.OptionPanel.ItemTooltip.GlowNineSlice.Anim:Stop()
	end
	self.OptionPanel.ItemTooltip.GlowNineSlice.Anim:Play()
end

function StoreProductPurchaseTypeItemTooltipMixin:SetProduct(product)
	self.TopPanel.Title:SetText(product.details and product.details.title or "")
	self.TopPanel.Text:SetText(product.details and product.details.description or "")

	local itemData = product.details and product.details.items and product.details.items[0] and product.details.items[0][1]
	local itemID = itemData and itemData.itemID or product.itemID
	local amount = itemData and itemData.amount or 1

	local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)

	self.__ignoreTooltipUpdate = true
	self.itemLink = link
	self.OptionPanel.ItemTooltip:SetOwner(self, "ANCHOR_PRESERVE")
	self.OptionPanel.ItemTooltip:SetHyperlink(link)
	self.OptionPanel.ItemTooltip:Show()
	self.OptionPanel.ItemTooltip.Icon:SetTexture(texture or [[Interface\Icons\INV_Misc_QuestionMark]])
	self.OptionPanel.ItemTooltip.Amount:SetText(amount and amount > 1 and amount or "")
	self.__ignoreTooltipUpdate = nil

	self:UpdateTooltipRect()
end

function StoreProductPurchaseTypeItemTooltipMixin:Reset()
	self.OptionPanel.ItemTooltip:Clear()
end

function StoreProductPurchaseTypeItemTooltipMixin:ApplyColorToGlowNiceSlice(r, g, b, a)
	for _, region in ipairs({self.OptionPanel.ItemTooltip.GlowNineSlice:GetRegions()}) do
		region:SetVertexColor(r, g, b, a)
	end
end

function StoreProductPurchaseTypeItemTooltipMixin:CleanupTooltipText()
	local isSetItemLine

	for lineIndex = 1, self.OptionPanel.ItemTooltip:NumLines() do
		local line = _G[string.format("%sTextLeft%d", self.OptionPanel.ItemTooltip:GetName(), lineIndex)]
		if line then
			if isSetItemLine then
				line:Hide()
			else
				local text = line:GetText()
				if text and text ~= "" then
					local currentSetItems, totalSetItems = string.match(text, "%((%d+)/(%d+)%)$")
					if currentSetItems then
						isSetItemLine = lineIndex
						line:Hide()
					end
				end
			end
		end
	end

	if isSetItemLine then
		for lineIndex = isSetItemLine, math.max(1, isSetItemLine - 1), -1 do
			local line = _G[string.format("%sTextLeft%d", self.OptionPanel.ItemTooltip:GetName(), lineIndex)]
			if line then
				line:Hide()
			end
		end
	end
end

function StoreProductPurchaseTypeItemTooltipMixin:UpdateTooltipRect()
	self:CleanupTooltipText()
	self.OptionPanel.ItemTooltip:Show() -- force update tooltip rect
	self.OptionPanel:SetHeight(self.OptionPanel.ItemTooltip:GetHeight() + 15 * 2)
end

function StoreProductPurchaseTypeItemTooltipMixin:OnTooltipSizeChanged()
	if not self.__ignoreTooltipUpdate then
		self:UpdateTooltipRect()
		self:GetOwner():UpdateFrameRect(true)
	end
end

StoreProductPurchaseTypeSpecMixin = CreateFromMixins(StoreProductPurchaseTypeBaseMixin)

function StoreProductPurchaseTypeSpecMixin:OnLoad()
	Mixin(self.TopPanel, StoreProductOptionWidgetBaseMixin)
	Mixin(self.OptionPanel, StoreProductOptionWidgetBaseMixin)

	self.specButtons = {}
	self.BUTTON_OFFSET_Y = 9
	self.dirty = true
	self.selectedSpecIndex = 0

	self.topPanelHeightBase = self.TopPanel:GetHeight()
	self.topPanelHeight = self.topPanelHeightBase

	self.OptionPanel.Scroll.ScrollBar:SetBackgroundShown(false)
	self.OptionPanel.Scroll.update = function(scrollFrame)
		self:UpdateItemList()
	end
	self.OptionPanel.Scroll.ScrollBar.doNotHide = true
	self.OptionPanel.Scroll.scrollBar = self.OptionPanel.Scroll.ScrollBar
	HybridScrollFrame_CreateButtons(self.OptionPanel.Scroll, "StoreProductItemPlateTemplate", 0, 0, nil, nil, nil, -self.BUTTON_OFFSET_Y)

	self.OptionPanel.Reset = function()
		self:Reset()
	end

	self.TopPanel.Title:SetWidth(PRODUCT_TEMPLATE.Spec.width - 144)
	self.TopPanel.Text:SetWidth(PRODUCT_TEMPLATE.Spec.width - 144)
end

function StoreProductPurchaseTypeSpecMixin:OnShow()
	local topPanelHeight = math.max(self.topPanelHeightBase, Round(self.TopPanel.Text:GetHeight() + self.TopPanel.Title:GetHeight() + 30))
	self.TopPanel:SetHeight(topPanelHeight)

	self.TopPanel.Text:SetPoint("CENTER", 0, -(7 + self.TopPanel.Title:GetHeight()) / 2)

	if self.topPanelHeight ~= topPanelHeight then
		self.topPanelHeight = topPanelHeight
		self:GetOwner():UpdateFrameRect(true)
	end
end

function StoreProductPurchaseTypeSpecMixin:SetProduct(product)
	self.TopPanel.Title:SetText(product.details and product.details.title or "")
	self.TopPanel.Text:SetText(product.details and product.details.description or "")

	self.itemList = product.details and product.details.items

	local SPEC_BUTTON_OFFSET_X = -16

	local _, class = UnitClass("player")
	local playerSpecs = SHARED_CONSTANTS_SPECIALIZATION[class]
	local numSpecs = math.min(#self.itemList, #playerSpecs)

	for specIndex = 1, numSpecs do
		local specInfo = playerSpecs[specIndex]
		local specButton = self.specButtons[specIndex]
		if not specButton then
			specButton = CreateFrame("CheckButton", string.format("$parentSpecButton%u", specIndex), self.OptionPanel.SpecHolder, "StoreSpecButtonTemplate")
			specButton:SetOwner(self)
			specButton:SetID(specIndex)
			specButton:SetBlockedUncheck(true)

			if specIndex == 1 then
				specButton:SetPoint("LEFT", 0, 0)
			else
				specButton:SetPoint("LEFT", self.specButtons[specIndex - 1], "RIGHT", SPEC_BUTTON_OFFSET_X, 0)
			end

			self.specButtons[specIndex] = specButton
		end

		SetPortraitToTexture(specButton.Icon, specInfo and specInfo.icon or [[Interface\Icons\INV_Misc_QuestionMark]])
		specButton.Icon:SetDesaturated(specInfo and specInfo.iconDesaturate or false)
		specButton.specInfo = specInfo
		specButton:SetChecked(specIndex == 1)
		specButton:Show()
	end

	for specIndex = numSpecs + 1, #self.specButtons do
		self.specButtons[specIndex]:Hide()
		self.specButtons[specIndex]:SetChecked(false)
	end

	if numSpecs > 1 then
		self.OptionPanel.SpecHolder:SetWidth(self.specButtons[1]:GetWidth() * numSpecs + SPEC_BUTTON_OFFSET_X * (numSpecs - 1))
	end

	self:SelectSpecIndex(1, true)
end

function StoreProductPurchaseTypeSpecMixin:UpdateItemList()
	local scrollFrame = self.OptionPanel.Scroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local items = self.itemList[self.selectedSpecIndex or 1]
	local numItems = #items

	for index, button in ipairs(scrollFrame.buttons) do
		local itemIndex = index + offset
		if itemIndex <= numItems then
			local itemData = items[itemIndex]
			local name, link, rarity, _, _, _, _, _, _, texture = GetItemInfo(itemData.itemID)
			button:SetOwner(self)
			button:SetID(itemIndex)
			button:SetItem(name, link, rarity, texture, itemData.amount)
			button:Show()
		else
			button:Hide()
		end
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		local scrollHeight = buttonHeight * numItems + self.BUTTON_OFFSET_Y * (numItems - 1) + self.BUTTON_OFFSET_Y / 3
		HybridScrollFrame_Update(scrollFrame, scrollHeight, scrollFrame:GetHeight())
		self.dirty = nil
	end
end

function StoreProductPurchaseTypeSpecMixin:SelectSpecIndex(specIndex, force)
	if self.selectedSpecIndex == specIndex and not force then
		return
	end

	self.selectedSpecIndex = specIndex

	for index, specButton in ipairs(self.specButtons) do
		specButton:SetChecked(index == specIndex)
	end

	self.OptionPanel.Scroll.ScrollBar:SetValue(0)
	self:UpdateItemList()
end

function StoreProductPurchaseTypeSpecMixin:GetSelectedSpecIndex()
	return self.selectedSpecIndex
end

function StoreProductPurchaseTypeSpecMixin:Reset()
	self:SelectSpecIndex(1)
end

StoreSpecButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreSpecButtonMixin:OnLoad()
	PKBT_VirtualCheckButtonMixin.OnLoad(self)

	self:SetNormalAtlas("PKBT-Portrait-Ring-Silver-Default", true)
	self:SetHighlightAtlas("PKBT-Portrait-Ring-Silver-Highlight", true)
	self:SetDisabledAtlas("PKBT-Portrait-Ring-Silver-Default", true)
	self:GetDisabledTexture():SetVertexColor(0.5, 0.5, 0.5)
	self:SetCheckedAtlas("PKBT-Portrait-Ring-Silver-Selected", true)
end

function StoreSpecButtonMixin:OnChecked(checked, userInput)
	if checked and userInput then
		self:GetOwner():SelectSpecIndex(self:GetID())
	end
end

function StoreSpecButtonMixin:OnEnter()
	if self:IsEnabled() == 1 and self.specInfo then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(self.specInfo.name)
		GameTooltip:AddLine(self.specInfo.description, 1, 1, 1, true)
		GameTooltip:Show()
	end
end

function StoreSpecButtonMixin:OnLeave()
	GameTooltip:Hide()
end

StoreProductItemPlateMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreProductItemPlateMixin:OnLoad()
	self.Border:SetAtlas("PKBT-ItemBorder-Normal", true)
	self.UpdateTooltip = self.OnEnter
end

function StoreProductItemPlateMixin:OnEnter()
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", -20)
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end
	CursorUpdate(self)
end

function StoreProductItemPlateMixin:OnLeave()
	if self.itemLink then
		GameTooltip_Hide()
	end
	ResetCursor()
end

function StoreProductItemPlateMixin:OnClick(button)
	if self.itemLink then
		if IsAltKeyDown() and C_StoreSecure.AddItem(self.itemLink) then
			return
		end
		if IsModifiedClick("CHATLINK") then
			if ChatEdit_InsertLink(self.itemLink) then
				return true
			end
		end
	--	if IsModifiedClick("DRESSUP") then
			self:GetOwner():GetOwner():DressUpItemLink(self.itemLink)
			return true
	--	end
	end
end

function StoreProductItemPlateMixin:SetItem(name, itemLink, rarity, icon, amount)
	self.Name:SetText(name or UNKNOWN)
	self.Name:SetTextColor(GetItemQualityColor(rarity or 1))
	self.Icon:SetTexture(icon or [[Interface\Icons\INV_Misc_QuestionMark]])
	self.Amount:SetText(amount and amount > 1 and amount or "")
	self.itemLink = itemLink
end

StoreProductOptionGiftMixin = CreateFromMixins(StoreProductOptionWidgetBaseMixin)

function StoreProductOptionGiftMixin:OnLoad()
	self:SetHeight(self.CheckButton:GetHeight())

	self.CheckButton.OnChecked = function(this, checked)
		self:GetOwner().GiftPanel:SetShown(checked)
		self:GetOwner():Summery()
	end
end

function StoreProductOptionGiftMixin:OnShow()
	local width = self.CheckButton:GetWidth()
	local stringWidth = self.CheckButton.ButtonText:GetStringWidth() + 5
	self.CheckButton:ClearAllPoints()
	self.CheckButton:SetPoint("CENTER", -(math.ceil((width / 2 + stringWidth) / 2)), 0)
	self:SetWidth(width + stringWidth)
end

function StoreProductOptionGiftMixin:Reset()
	self.CheckButton:SetChecked(false)
	self:GetOwner().GiftPanel:Reset()
end

function StoreProductOptionGiftMixin:SetEnabled(state)
	self.CheckButton:SetEnabled(state)
end

function StoreProductOptionGiftMixin:SetChecked(state)
	self.CheckButton:SetChecked(state)
end

function StoreProductOptionGiftMixin:GetChecked()
	return self.CheckButton:GetChecked()
end

function StoreProductOptionGiftMixin:GetGiftInfo()
	return self:GetOwner().GiftPanel:GetGiftInfo()
end

StoreProductOptionCurrencySelectorMixin = CreateFromMixins(StoreProductOptionWidgetBaseMixin)

function StoreProductOptionCurrencySelectorMixin:OnLoad()
	self.currencyButtonPool = CreateFramePool("Frame", self, "StoreProductOptionCurrencyEntryTemplate")
	self.currencyButtonArray = {}
	self.currencyTypes = {}
	self.selectedIndex = PRODUCT_DEFAULT_CURRENCY_INDEX
end

function StoreProductOptionCurrencySelectorMixin:OnShow()
	self:UpdateRect()
end

function StoreProductOptionCurrencySelectorMixin:UpdateRect()
	local numButtons = self.currencyButtonPool:GetNumActive()
	if numButtons == 0 then
		self:SetHeight(0)
	else
		self:SetHeight(numButtons * self.currencyButtonPool:GetNextActive():GetHeight() + (numButtons - 1) * 12)
	end

	do -- price padding
		local maxWidth = 0
		for button in self.currencyButtonPool:EnumerateActive() do
			maxWidth = math.max(maxWidth, button.Price:GetWidth())
		end
		for button in self.currencyButtonPool:EnumerateActive() do
			local diff = math.floor(button.Price:GetWidth() - maxWidth)
			button.Price:SetPoint("RIGHT", diff, 0)
		end
	end
end

function StoreProductOptionCurrencySelectorMixin:ClearCurrencyList(updateRect)
	self.currencyButtonPool:ReleaseAll()
	table.wipe(self.currencyButtonArray)
	table.wipe(self.currencyTypes)
	self.selectedIndex = 1

	if updateRect then
		self:UpdateRect()
	end
end

function StoreProductOptionCurrencySelectorMixin:AddCurrency(price, originalPrice, currencyType)
	local currencyButton = self.currencyButtonPool:Acquire()
	local index = self.currencyButtonPool:GetNumActive()
	currencyButton:SetID(index)

	self.currencyButtonArray[index] = currencyButton
	self.currencyTypes[index] = currencyType

	if index == 1 then
		currencyButton:SetPoint("TOP", 0, 0)
	else
		currencyButton:SetPoint("TOP", self.currencyButtonArray[index - 1], "BOTTOM", 0, -12)
	end

	currencyButton:SetPoint("LEFT", 20, 0)
	currencyButton:SetPoint("RIGHT", -20, 0)

	local name, description, link, texture, iconAtlas = C_StorePublic.GetCurrencyInfo(currencyType)
	currencyButton.CheckButton:SetText(name)
	currencyButton.CheckButton:SetChecked(index == 1)
	currencyButton.Price:SetFreeText(STORE_PRICE_FREE)
	currencyButton.Price:SetPrice(price, originalPrice, currencyType)
	currencyButton:Show()
end

function StoreProductOptionCurrencySelectorMixin:UpdateCurrencyList(product)
	self:ClearCurrencyList()

	self:AddCurrency(product.price, product.originalPrice, product.currencyType)
	if product.altCurrencyType and product.altPrice then
		self:AddCurrency(product.altPrice, product.altOriginalPrice, product.altCurrencyType)
	end

	self:UpdateRect()
end

function StoreProductOptionCurrencySelectorMixin:SelectCurrencyIndex(currencyIndex)
	local changed = self.selectedIndex ~= currencyIndex
	self.selectedIndex = currencyIndex

	for currencyButton in self.currencyButtonPool:EnumerateActive() do
		currencyButton.CheckButton:SetChecked(currencyButton:GetID() == currencyIndex)
	end

	if changed then
		self:GetOwner():Summery()
	end
end

function StoreProductOptionCurrencySelectorMixin:GetCurrencyTypeIndex(currencyType)
	for currencyButton in self.currencyButtonPool:EnumerateActive() do
		if self:GetButtonCurrencyType(currencyButton:GetID()) == currencyType then
			return currencyButton:GetID()
		end
	end
end

function StoreProductOptionCurrencySelectorMixin:SetEnabledCurrencies(currencyType)
	for currencyButton in self.currencyButtonPool:EnumerateActive() do
		currencyButton.CheckButton:SetEnabled(currencyType == true or self:GetButtonCurrencyType(currencyButton:GetID()) == currencyType)
	end
end

function StoreProductOptionCurrencySelectorMixin:GetButtonCurrencyType(index)
	return self.currencyTypes[index]
end

function StoreProductOptionCurrencySelectorMixin:GetSelectedCurrencyIndex()
	return self.selectedIndex
end

function StoreProductOptionCurrencySelectorMixin:GetSelectedCurrencyType()
	return self:GetButtonCurrencyType(self.selectedIndex)
end

function StoreProductOptionCurrencySelectorMixin:Reset()
	local currencyIndex = PRODUCT_DEFAULT_CURRENCY_INDEX
	if IsInterfaceDevClient() then
		currencyIndex = 1
	end
	self:SelectCurrencyIndex(currencyIndex)
end

StoreProductOptionCurrencyEntryMixin = {}

function StoreProductOptionCurrencyEntryMixin:OnLoad()
--	self.CheckButton.ButtonText:SetFontObject("PKBT_Font_15")
--	self.CheckButton.ButtonText:SetMaxLines(2)

	do -- missing SetMaxLines workaround
		self.CheckButton.ButtonText:Hide()
		local name = self.CheckButton.ButtonText:GetName()
		if name then
			_G[name] = self.CheckButton.ButtonTextMaxLinesFix
		end
		self.CheckButton.ButtonText = self.CheckButton.ButtonTextMaxLinesFix
	end
end

function StoreProductOptionCurrencyEntryMixin:OnShow()
	local textWidth = (self.Price:GetLeft() or 0) - (self.CheckButton.ButtonText:GetLeft() or 0)
	self.CheckButton.ButtonText:SetWidth(math.max(math.min(textWidth, 250), 150))
end

function StoreProductOptionCurrencyEntryMixin:OnClick(button)
	self:GetParent():SelectCurrencyIndex(self:GetID())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

StoreProductOptionAmountMixin = CreateFromMixins(StoreProductOptionWidgetBaseMixin)

function StoreProductOptionAmountMixin:OnLoad()
	self:SetHeight(self.Amount:GetHeight())

	self.Label:SetPoint("RIGHT", self.Amount, "LEFT", -15, 0)

	self.Amount:SetNumberNoScript(0)
	self.Amount.limit = 1000
	self.Amount.minValue = 1
	self.Amount.maxValue = function()
		if C_StoreSecure.IsBonusReplenishmentAllowed() and self:GetOwner():CanReplenishCurrency() then
			return self.Amount.limit
		else
			return self:GetOwner():GetMaxSelectedAmount()
		end
	end

	self.Amount.OnTextValueChanged = function(this, value, userInput)
		self:GetOwner():Summery()
	end
end

function StoreProductOptionAmountMixin:OnShow()
	local stringWidth = self.Label:GetStringWidth() + 15
	self.Amount:SetPoint("CENTER", stringWidth / 2, 0)
	self:SetWidth(stringWidth + self.Amount:GetWidth())
end

function StoreProductOptionAmountMixin:SetAmount(amount)
	return self.Amount:SetNumber(amount)
end

function StoreProductOptionAmountMixin:GetAmount()
	return self.Amount:GetNumber()
end

function StoreProductOptionAmountMixin:Reset()
	self.Amount:SetNumberNoScript(1)
end

local sortWidgets = function(a, b)
	return a.template.order < b.template.order
end

StoreProductPurchaseDialogMixin = CreateFromMixins(StoreDialogCloseHandlingMixin)

function StoreProductPurchaseDialogMixin:OnLoad()
	self:SetTitle(STORE_PRODUCT_PURCHASE_TITLE)

	self.Content.BackgroundTop:SetAtlas("PKBT-Tile-Wood-128")
	self.Content.BackgroundBottom:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom-Rounded", true)

	self.Content.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.Content.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)

	self.Content.DividerTop:SetAtlas("PKBT-Divider-Dark", true)
	self.Content.DividerBottom:SetAtlas("PKBT-Divider-Dark", true)
	self.Content.DividerBottom:SetSubTexCoord(0, 1, 1, 0)

	self.Content.PurchaseButton:AddText(STORE_PRODUCT_PURCHASE_LABEL)
	self.Content.PurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), true)
	self.Content.PurchaseButton.Price:SetFreeText(string.format("|cff00ff00%s|r", STORE_PRICE_FREE))

	self.defaultPanelWidth = self:GetWidth() or 364
	self.templates = {}
	self.topPanelWidgets = {}
	self.optionPanelWidgets = {}

	self.ModelPanel.AbilityOverlay:SetBasePoint("BOTTOMRIGHT", 4, 0)
	self.ModelPanel.Overlay.EquipmentToggle:ClearAllPoints()
	self.ModelPanel.Overlay.EquipmentToggle:SetPoint("TOPRIGHT", 0, -30)

	C_StoreSecure.GetStoreFrame():RegisterDialogWidget(self, Enum.StoreWidget.ProductPurchase)
end

function StoreProductPurchaseDialogMixin:OnEvent(event, ...)
	if event == "STORE_PURCHASE_COMPLETE" then
		local productID, itemID = ...
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
		self:Close()
	elseif event == "STORE_PURCHASE_ERROR" then
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
	elseif event == "STORE_BALANCE_UPDATE" then
		self:Summery()
	elseif event == "STORE_PRODUCTS_CHANGED" or event == "STORE_PRODUCTS_REMOVED" then
		self:ValidateProduct()
	end
end

function StoreProductPurchaseDialogMixin:OnShow()
	self:RegisterCustomEvent("STORE_PURCHASE_ERROR")
	self:RegisterCustomEvent("STORE_PURCHASE_COMPLETE")
	self:RegisterCustomEvent("STORE_PRODUCTS_CHANGED")
	self:RegisterCustomEvent("STORE_PRODUCTS_REMOVED")
	self:RegisterCustomEvent("STORE_BALANCE_UPDATE")

	if C_StoreSecure.IsAwaitingPurchaseAnswer() then
		self.Content.PurchaseButton:ShowSpinner()
		self.Content.PurchaseButton:Disable()
	else
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
	end
end

function StoreProductPurchaseDialogMixin:OnHide()
	self:UnregisterCustomEvent("STORE_PURCHASE_ERROR")
	self:UnregisterCustomEvent("STORE_PURCHASE_COMPLETE")
	self:UnregisterCustomEvent("STORE_PRODUCTS_CHANGED")
	self:UnregisterCustomEvent("STORE_PRODUCTS_REMOVED")
	self:UnregisterCustomEvent("STORE_BALANCE_UPDATE")

	self:ResetOptions()
	self.ModelPanel:Close()
	self.product = nil
end

function StoreProductPurchaseDialogMixin:ResetOptions()
	for index, widget in ipairs(self.optionPanelWidgets) do
		widget:Reset()
	end
end

function StoreProductPurchaseDialogMixin:GetWidgetObject(template)
	if not self.templates[template.name] then
		local frame = CreateFrame("Frame", string.format("$parent%s", template.name), self.Content, template.template)
		frame.template = CopyTable(template)
		frame:SetOwner(self)

		if frame:IsProductMasterWidget() then
			local topPanel = frame:GetTopPanel()
			local optionPanel = frame:GetOptionPanel()
			if topPanel then
				topPanel:SetOwner(self)
				topPanel:SetParent(self.Content.TopPanel)
				topPanel.template = CopyTable(template)
				topPanel.template.isOption = false
			end
			if optionPanel then
				optionPanel:SetOwner(self)
				optionPanel:SetParent(self.Content.OptionPanel)
				optionPanel.template = CopyTable(template)
				optionPanel.template.isOption = true
			end
		else
			frame:SetParent(self.Content.OptionPanel)
			frame.template.isOption = true
		end

		self.templates[template.name] = frame
	end

	return self.templates[template.name]
end

function StoreProductPurchaseDialogMixin:GetProductWidgetTemplate(product)
	if product.productType == Enum.Store.ProductType.Subscription then
		return PRODUCT_TEMPLATE.Subscription
	elseif product.productType == Enum.Store.ProductType.RenewProductList then
		return PRODUCT_TEMPLATE.SimpleText
	elseif product.hasSpecOptions then
		return PRODUCT_TEMPLATE.Spec
	elseif type(product.details) == "table" and type(product.details.items) == "table" and product.details.items[0] and #product.details.items[0] > 0 then
		if #product.details.items[0] == 1 then
			return PRODUCT_TEMPLATE.ItemTooltip
		else
			return PRODUCT_TEMPLATE.ItemList
		end
	end
	return PRODUCT_TEMPLATE.Default
end

function StoreProductPurchaseDialogMixin:GetProductWidgetObject(product)
	local productTemplate = self:GetProductWidgetTemplate(product)
	return self:GetWidgetObject(productTemplate)
end

function StoreProductPurchaseDialogMixin:ClearWidgetsFromList(list, reset)
	for index = 1, #list do
		local widget = list[index]
		widget:SetActive(false)
		widget:Hide()
		if reset and type(widget.Reset) == "function" then
			widget:Reset()
		end
		list[index] = nil
	end
end

function StoreProductPurchaseDialogMixin:ClearWidgets()
	self.desiredPanelWidth = nil
	self:ClearWidgetsFromList(self.topPanelWidgets)
	self:ClearWidgetsFromList(self.optionPanelWidgets, true)
	self.dirty = true
end

function StoreProductPurchaseDialogMixin:AddWidget(widget)
	local target = widget.template.isOption and self.optionPanelWidgets or self.topPanelWidgets
	table.insert(target, widget)
	widget:Reset()
	widget:SetActive(true)
	widget:Show()
	self.dirty = true
end

function StoreProductPurchaseDialogMixin:AddProductWidgets(widgetHandlerFrame)
	local topPanel = widgetHandlerFrame:GetTopPanel()
	if topPanel then
		self:AddWidget(topPanel)
	end

	local optionPanel = widgetHandlerFrame:GetOptionPanel()
	if optionPanel then
		self:AddWidget(optionPanel)
	end

	if widgetHandlerFrame.template.width then
		if self.desiredPanelWidth then
			self.desiredPanelWidth = math.max(self.desiredPanelWidth, widgetHandlerFrame.template.width)
		else
			self.desiredPanelWidth = widgetHandlerFrame.template.width
		end
	end

	widgetHandlerFrame:Show()
end

function StoreProductPurchaseDialogMixin:SetProductID(productID)
	self.blockSummery = true

	self:ClearWidgets()

	local product = C_StoreSecure.GetProductInfo(productID)
	if not product then
		return false
	end

	if product.isUnavailable then
		if product.isRollableUnavailable then
			GMError(string.format("[STORE_PURCHASE] Product [%d] has ROLLABLE_UNAVAILABLE flag and can not be purchased", product.productID or -1))
		else
			GMError(string.format("[STORE_PURCHASE] Product [%d] is not available and can not be purchased", product.productID or -1))
		end
		return false
	end

	self.productID = productID
	self.product = product

	local productWidget = self:GetProductWidgetObject(product)
	productWidget:SetProduct(product)

	self:AddProductWidgets(productWidget)

	if product.isGiftable then
		local giftWidget = self:GetWidgetObject(OPTION_TEMPLATE.Gift)
		if product.noPurchaseCanGift then
			giftWidget:SetChecked(true)
			giftWidget:SetEnabled(false)
		end
		self:AddWidget(giftWidget)
	end

	if product.altCurrencyType and not product.noPurchaseCanGift then
		local currencySelector = self:GetWidgetObject(OPTION_TEMPLATE.CurrencySelector)
		currencySelector:UpdateCurrencyList(product)
		self:AddWidget(currencySelector)
	end

	if product.canBuyMultiple then
		local amountWidget = self:GetWidgetObject(OPTION_TEMPLATE.Amount)
		amountWidget:SetAmount(1)
		self:AddWidget(amountWidget)
	end

	do -- footer
		local hasProductDeliveryHint = true
		if product.productType == Enum.Store.ProductType.RenewProductList then
			hasProductDeliveryHint = false
		end

		if hasProductDeliveryHint and product.refundNotice then
			self.Content.HintText:SetPoint("TOP", self.Content.RefundNotice, "BOTTOM", 0, -10)
		elseif hasProductDeliveryHint then
			self.Content.HintText:SetPoint("TOP", self.Content.BackgroundBottom, 0, -18)
		elseif product.refundNotice then
			self.Content.RefundNotice:SetPoint("TOP", self.Content.BackgroundBottom, 0, -18)
		end

		self.Content.RefundNotice:SetText(product.refundNotice or "")
		self.Content.RefundNotice:SetShown(product.refundNotice)
		self.Content.HintText:SetShown(hasProductDeliveryHint)
	end

	self:UpdateFrameRect()
	self:UpdateDebugInfo()

	self.blockSummery = nil
	self:Summery()

	if product.categoryID == Enum.Store.Category.Collections then
		self.ModelPanel.CloseButton:Hide()
		self.ModelPanel:SetModel(product.modelType, product.modelID)
		self.ModelPanel:Show()

		local linkType, id, collectionID = GetDressUpItemLinkInfo(product.itemID)
		if linkType == Enum.DressUpLinkType.Mount then
			self.ModelPanel.AbilityOverlay:SetItemAbilities(product.itemID)
		else
			self.ModelPanel.AbilityOverlay:ClearItemAbilities()
		end
	elseif product.categoryID == Enum.Store.Category.Transmogrification then
		if product.setProducts then
			local setItemIDs = {}
			for index, setItemData in ipairs(product.setProducts) do
				setItemIDs[index] = setItemData.itemID
			end
			self.ModelPanel.CloseButton:Hide()
			self.ModelPanel:SetModel(Enum.ModelType.ItemSet, setItemIDs, true)
			self.ModelPanel.AbilityOverlay:ClearItemAbilities()
			self.ModelPanel:Show()
		else
			self.ModelPanel.CloseButton:Hide()
			self.ModelPanel:SetModel(Enum.ModelType.Item, product.itemID)
			self.ModelPanel.AbilityOverlay:ClearItemAbilities()
			self.ModelPanel:Show()
		end
	else
		local success = self:TryAnyProductModel()
		if not success then
			self.ModelPanel.CloseButton:Show()
			self.ModelPanel.AbilityOverlay:ClearItemAbilities()
			self.ModelPanel:Close()
		end
	end

	return true
end

function StoreProductPurchaseDialogMixin:TryAnyProductModel()
	if not self.product then
		return false
	end

	local productTemplate = self:GetProductWidgetTemplate(self.product)
	if productTemplate == PRODUCT_TEMPLATE.Default then
		if self.product.itemID then
			local name, link, rarity, _, _, _, _, _, _, texture = GetItemInfo(self.product.itemID)
			if link then
				local success = self:DressUpItemLink(link)
				if success then
					return true
				end
			end
		end
	elseif productTemplate == PRODUCT_TEMPLATE.ItemList
	or productTemplate == PRODUCT_TEMPLATE.ItemTooltip
	or productTemplate == PRODUCT_TEMPLATE.Spec
	then
		local itemListIndex = 0
		if productTemplate == PRODUCT_TEMPLATE.Spec then
			if self.product.hasSpecOptions then
				local productWidget = self:GetProductWidgetObject(self.product)
				itemListIndex = productWidget:GetSelectedSpecIndex()
				return true
			end
		end

		local itemList = type(self.product.details) == "table" and type(self.product.details.items) == "table" and self.product.details.items[itemListIndex]
		if type(itemList) == "table" then
			for index, itemData in ipairs(itemList) do
				local name, link, rarity, _, _, _, _, _, _, texture = GetItemInfo(itemData.itemID)
				if link then
					local success = self:DressUpItemLink(link)
					if success then
						return true
					end
				end
			end
		end
	end

	return false
end

function StoreProductPurchaseDialogMixin:ValidateProduct()
	if not self.productID then
		return
	end

	if not C_StoreSecure.HasProductID(self.productID) then
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
		self:Close()
		return
	end

	local product = C_StoreSecure.GetProductInfo(self.productID)
	if not product then
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
		self:Close()
		return
	end

	if self.product and tCompare(self.product, product, 10) then
		return
	end

	self:SetProductID(self.productID) -- full update because of mismatch in product info
end

function StoreProductPurchaseDialogMixin:UpdateWidgetPoints(widgetList, offsetY, paddingY)
	for index, widget in ipairs(widgetList) do
		widget:ClearAllPoints()
		if index == 1 then
			widget:SetPoint("TOPLEFT", 0, -(paddingY or 0))
			widget:SetPoint("TOPRIGHT", 0, -(paddingY or 0))
		else
			widget:SetPoint("TOPLEFT", widgetList[index - 1], "BOTTOMLEFT", 0, widget.template.offsetY or offsetY or 0)
			widget:SetPoint("TOPRIGHT", widgetList[index - 1], "BOTTOMRIGHT", 0, widget.template.offsetY or offsetY or 0)
		end
		widget:Show()
	end
end

function StoreProductPurchaseDialogMixin:GetWidgetPanelHeight(widgetList, offsetY, paddingY)
	local height = 0
	if paddingY and #widgetList > 0 then
		height = height + paddingY * 2
	end
	for index, widget in ipairs(widgetList) do
		height = height + widget:GetHeight() + math.abs(index > 1 and (widget.template.offsetY or offsetY) or 0)
	end
	return height
end

function StoreProductPurchaseDialogMixin:GetFooterPanelHeight()
	local height = 24 + self.Content.PurchaseButton:GetHeight() + 25
	if self.Content.HintText:IsShown() then
		height = height + 10 + self.Content.HintText:GetHeight()
	end
	if self.Content.RefundNotice:IsShown() then
		height = height + 10 + self.Content.RefundNotice:GetHeight()
	end
	return height
end

function StoreProductPurchaseDialogMixin:UpdateFrameRect(force)
	if not self.dirty and not force then return end

	self.dirty = nil

	table.sort(self.topPanelWidgets, sortWidgets)
	table.sort(self.optionPanelWidgets, sortWidgets)

	self:UpdateWidgetPoints(self.topPanelWidgets, PRODUCT_WIDGET_OFFSET_Y)
	self:UpdateWidgetPoints(self.optionPanelWidgets, PRODUCT_WIDGET_OFFSET_Y, PRODUCT_FRAME_OPTION_PADDING)

	local topPanelHeight = self:GetWidgetPanelHeight(self.topPanelWidgets, PRODUCT_WIDGET_OFFSET_Y)
	local optionPanelHeight = self:GetWidgetPanelHeight(self.optionPanelWidgets, PRODUCT_WIDGET_OFFSET_Y, PRODUCT_FRAME_OPTION_PADDING)
	local footerPanelHeight = self:GetFooterPanelHeight()

	topPanelHeight = math.max(75, topPanelHeight)
	self.Content.BackgroundTop:SetHeight(topPanelHeight)

	footerPanelHeight = math.max(101, footerPanelHeight)
	self.Content.BackgroundBottom:SetHeight(footerPanelHeight)

	self:SetWidth(self.desiredPanelWidth or self.defaultPanelWidth)
	self:SetHeight(math.ceil(PRODUCT_FRAME_BASE_HEIGHT + topPanelHeight + optionPanelHeight + footerPanelHeight))
end

function StoreProductPurchaseDialogMixin:OnPurchaseClick(button)
	local options = {}

	local amountWidget = self:GetWidgetObject(OPTION_TEMPLATE.Amount)
	if amountWidget:IsActive() then
		options.amount = amountWidget:GetAmount()
	end

	do -- check balance
		local price, originalPrice, currencyType, currencyOptionIndex = self:GetPriceForSelectedCurrency()
		if options.amount then
			price = price * options.amount
		end

		local balance = C_StoreSecure.GetBalance(currencyType)
		if price > balance and not C_Service.IsInGMMode() then
			if currencyType == Enum.Store.CurrencyType.Bonus then
				C_StoreSecure.GetStoreFrame():ShowLinkDialog(nil, STORE_DONATE_DIALOG_TITLE, STORE_DONATE_DIALOG_TEXT, C_StoreSecure.GenerateDonationLinkForAmount(price - balance))
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				return
			else
				C_StoreSecure.GenerateBalanceError(Enum.Store.ProductType.Item, currencyType, string.join(".", "PRODPD", self.productID or " "))
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				return
			end
		end
	end

	local currencyWidget = self:GetWidgetObject(OPTION_TEMPLATE.CurrencySelector)
	if self.product.altCurrencyType and self.product.altPrice and currencyWidget:IsActive() then
		local currencyOptionIndex = currencyWidget:GetSelectedCurrencyType()
		if currencyOptionIndex and currencyOptionIndex ~= Enum.Store.CurrencyType.Bonus then
			options.useAltCurrency = true
		end
	end

	if self.product.hasSpecOptions then
		local productWidget = self:GetProductWidgetObject(self.product)
		options.specIndex = productWidget:GetSelectedSpecIndex()
	end

	local giftWidget = self:GetWidgetObject(OPTION_TEMPLATE.Gift)
	if giftWidget:IsActive() and giftWidget:GetChecked() then
		local style, name, text = giftWidget:GetGiftInfo()
		options.isGift = true
		options.giftStationeryType = style
		options.giftCharacterName = name
		options.giftMessage = text
	end

	local success = C_StoreSecure.PurchaseProduct(self.product.productID, options)
	if success then
		self.Content.PurchaseButton:ShowSpinner()
		self.Content.PurchaseButton:Disable()
		PlaySound(SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON)
	end
end

function StoreProductPurchaseDialogMixin:OnCancelClick(button)
	self:Close()
end

function StoreProductPurchaseDialogMixin:ValidateOptions()
	local canGift = true
	local giftWidget = self:GetWidgetObject(OPTION_TEMPLATE.Gift)

	local currencyWidget = self:GetWidgetObject(OPTION_TEMPLATE.CurrencySelector)
	if self.product.noPurchaseCanGift then
		if giftWidget:IsActive() then
			giftWidget:SetChecked(true)
			if currencyWidget:IsActive() then
				local bonusCurrencyIndex = currencyWidget:GetCurrencyTypeIndex(Enum.Store.CurrencyType.Bonus)
				if bonusCurrencyIndex then
					currencyWidget:SelectCurrencyIndex(bonusCurrencyIndex)
				end
				currencyWidget:SetEnabledCurrencies(Enum.Store.CurrencyType.Bonus)
			end
		end
	elseif self.product.altCurrencyType and self.product.altPrice and currencyWidget:IsActive() then
		local currencyOptionIndex = currencyWidget:GetSelectedCurrencyIndex()
		if giftWidget:IsActive() then
			if giftWidget:GetChecked() then
				if currencyOptionIndex == 0 then
					giftWidget:SetChecked(false)
					canGift = false
				elseif currencyOptionIndex == 1 then
					currencyWidget:SetEnabledCurrencies(Enum.Store.CurrencyType.Bonus)
					canGift = true
				else
					-- fail safe reset
					local bonusCurrencyIndex = currencyWidget:GetCurrencyTypeIndex(Enum.Store.CurrencyType.Bonus)
					if bonusCurrencyIndex then
						currencyWidget:SelectCurrencyIndex(bonusCurrencyIndex)
						currencyWidget:SetEnabledCurrencies(Enum.Store.CurrencyType.Bonus)
						canGift = true
					else
						giftWidget:SetChecked(false)
						currencyWidget:SetEnabledCurrencies(true)
						canGift = false
					end
				end
			else
				currencyWidget:SetEnabledCurrencies(true)
				canGift = currencyOptionIndex == 1
			end
		end
	end

	if giftWidget:IsActive() then
		giftWidget:SetEnabled(canGift and not self.product.noPurchaseCanGift)
	end

	if not self.purchasedDisabledReason then
		local isGiftFeildsValid, invalidReason = self:IsGiftFieldsValid()
		if canGift and not isGiftFeildsValid then
			self.Content.PurchaseButton:Disable()
			self.Content.PurchaseButton:SetDisabledReason(invalidReason)
		else
			self.Content.PurchaseButton:SetDisabledReason(nil)
		end
	end

	self.Content.PurchaseButton:CheckBalance()
end

function StoreProductPurchaseDialogMixin:IsGiftFieldsValid()
	local giftWidget = self:GetWidgetObject(OPTION_TEMPLATE.Gift)
	if not giftWidget:IsActive() or not giftWidget:GetChecked() then
		return true
	end
	return self.GiftPanel:IsInputValid()
end

function StoreProductPurchaseDialogMixin:DressUpItemLink(link)
	local success = self.ModelPanel:DressUpItemLink(link)
	self.ModelPanel:SetShown(success)

	local hasAbilities = false
	local abilitiesHandled = false

	if success then
		local linkType, id, collectionID = GetDressUpItemLinkInfo(link)
		if linkType == Enum.DressUpLinkType.Mount then
			hasAbilities = self.ModelPanel.AbilityOverlay:SetItemAbilities(link)
			abilitiesHandled = true
		end
	end

	if not abilitiesHandled then
		self.ModelPanel.AbilityOverlay:ClearItemAbilities()
	end

	return success, hasAbilities
end

function StoreProductPurchaseDialogMixin:UpdateDebugInfo()
	if self.productID and (IsGMAccount() or IsInterfaceDevClient()) then
		local flags, dynamicFlags = C_StoreSecure.GetProductFlags(self.productID)
		local timestamp = time(date("!*t")) / 10
		self.Content.DebugInfo:SetFormattedText("%d.%x.%x.%x", self.productID, flags or 0, dynamicFlags or 0, timestamp)
	else
		self.Content.DebugInfo:SetText("")
	end
end

function StoreProductPurchaseDialogMixin:CanReplenishCurrency()
	local price, originalPrice, currencyType, currencyOptionIndex = self:GetPriceForSelectedCurrency()
	return C_StoreSecure.CanReplenishCurrency(currencyType)
end

function StoreProductPurchaseDialogMixin:GetMaxSelectedAmount()
	local price, originalPrice, currencyType, currencyOptionIndex = self:GetPriceForSelectedCurrency()
	local balance = C_StoreSecure.GetBalance(currencyType)
	local amount = math.floor(balance / price)
	return amount
end

function StoreProductPurchaseDialogMixin:GetPriceForSelectedCurrency()
	local price, originalPrice, currencyType
	local currencyOptionIndex

	local currencyWidget = self:GetWidgetObject(OPTION_TEMPLATE.CurrencySelector)
	if self.product.altCurrencyType and self.product.altPrice and currencyWidget:IsActive() then
		currencyOptionIndex = currencyWidget:GetSelectedCurrencyIndex()
		if currencyOptionIndex == 1 then
			price, originalPrice, currencyType = self.product.price, self.product.originalPrice, self.product.currencyType
		elseif currencyOptionIndex ~= 0 then
			price, originalPrice, currencyType = self.product.altPrice, self.product.altOriginalPrice, self.product.altCurrencyType
		end
	else
		currencyOptionIndex = 1
		price, originalPrice, currencyType = self.product.price, self.product.originalPrice, self.product.currencyType
	end

	local giftWidget = self:GetWidgetObject(OPTION_TEMPLATE.Gift)
	if price and currencyOptionIndex ~= 0
	and (currencyType == Enum.Store.CurrencyType.Bonus)
	and giftWidget:IsActive() and giftWidget:GetChecked()
	then
		price, originalPrice = C_StoreSecure.GetProductGiftPrice(self.productID, currencyType)
	end

	return price, originalPrice, currencyType, currencyOptionIndex
end

function StoreProductPurchaseDialogMixin:Summery()
	if self.blockSummery then
		return
	end

	local price, originalPrice, currencyType, currencyOptionIndex = self:GetPriceForSelectedCurrency()

	if currencyOptionIndex ~= 0 then
		local balance = C_StoreSecure.GetBalance(currencyType)
		local amount

		local amountWidget = self:GetWidgetObject(OPTION_TEMPLATE.Amount)
		if amountWidget:IsActive() then
			amount = amountWidget:GetAmount()
			if currencyType == Enum.Store.CurrencyType.Bonus and C_StoreSecure.IsBonusReplenishmentAllowed() then
				amountWidget.Amount.IncrementButton:SetEnabled(amount < amountWidget.Amount.limit)
			else
				amountWidget.Amount.IncrementButton:SetEnabled(amount < amountWidget.Amount.limit and price * (amount + 1) <= balance)
			end
		else
			amount = 1
		end

		self.Content.PurchaseButton:SetPrice(price * amount, originalPrice * amount, currencyType)
		self.purchasedDisabledReason = nil
	else
		self.Content.PurchaseButton:SetPrice(-1)
		self.Content.PurchaseButton:Disable()
		self.purchasedDisabledReason = STORE_PRODUCT_PURCHASE_CURRENCY_NOT_SELECTED
	end

	self.Content.PurchaseButton:SetDisabledReason(self.purchasedDisabledReason)
	self.Content.PurchaseButton:Show()

	self:ValidateOptions()
end