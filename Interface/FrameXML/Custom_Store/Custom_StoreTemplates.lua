local assert = assert
local type = type
local strformat, strgsub, strlen, utf8gsub, utf8len, utf8sub = string.format, string.gsub, string.len, utf8.gsub, utf8.len, utf8.sub

local C_StorePublic = C_StorePublic
local C_StoreSecure = C_StoreSecure
local GetDressUpItemLinkInfo = GetDressUpItemLinkInfo
local IsModifiedClick = IsModifiedClick

local STORE_ERROR_LABEL = STORE_ERROR_LABEL
local STORE_PRODUCT_ROLLABLE_UNAVAILABLE = STORE_PRODUCT_ROLLABLE_UNAVAILABLE
local STORE_PRODUCT_UNAVAILABLE = STORE_PRODUCT_UNAVAILABLE
local ACCEPT = ACCEPT
local CLOSE = CLOSE

Enum.StoreDialogStyle = {
	Wood = 1,
	Paper = 2,
}

StorePurchaseGoldButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function StorePurchaseGoldButtonMixin:OnLoad()
	self:Reset()
end

function StorePurchaseGoldButtonMixin:OnEnter()
	if self:IsEnabled() ~= 1 then
		local balance = C_StoreSecure.GetBalance(self.currencyType)
		local errorText

		if self.currencyType == Enum.Store.CurrencyType.Bonus then
			errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_BONUS
		elseif self.currencyType == Enum.Store.CurrencyType.Vote then
			errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_VOTE
		elseif self.currencyType == Enum.Store.CurrencyType.Referral then
			errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_REFERRAL
		elseif self.currencyType == Enum.Store.CurrencyType.Loyality then
			errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_LOYALITY
		else
			errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_GENERIC
		end

		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(strformat(STORE_NOT_ENOUGHT_FOR_PURCHASE_BASE, errorText, balance), 1, 1, 1, 1)
		GameTooltip:Show()
	end
end

function StorePurchaseGoldButtonMixin:OnLeave()
	if self:IsEnabled() ~= 1 then
		GameTooltip:Hide()
	end
end

function StorePurchaseGoldButtonMixin:OnClick(button)
	if button == "LeftButton" then
		self:GetOwner():Purchase()
	end
end

function StorePurchaseGoldButtonMixin:Reset()
	self.currencyType = -1
	self.price = -1
end

function StorePurchaseGoldButtonMixin:SetPrice(currencyType, price)
	assert(type(currencyType) == "number")
	assert(Enum.Store.CurrencyType[currencyType] ~= nil)
	assert(type(price) == "number")

	self.currencyType = currencyType
	self.price = price

	self:CheckBalance()
end

function StorePurchaseGoldButtonMixin:CheckBalance()
	if self.currencyType == -1 or self.price == -1 then
		self:Disable()
		return
	end

	local balance = C_StoreSecure.GetBalance(self.currencyType)
	self:SetEnabled(balance >= self.price)
end

StorePageHeaderTemplate = {}

function StorePageHeaderTemplate:OnLoad()
	self.Background:SetAtlas("PKBT-Store-Header-Background", true)
end

function StorePageHeaderTemplate:SetLabel(label)
	self.Text:SetText(label or "")
end

StoreSpecialRibbonMixin = {}

function StoreSpecialRibbonMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-Sale-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-Sale-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-Sale-Background-Center")
end

function StoreSpecialRibbonMixin:SetDesaturated(desaturated)
	self.BackgroundLeft:SetDesaturated(desaturated)
	self.BackgroundRight:SetDesaturated(desaturated)
	self.BackgroundCenter:SetDesaturated(desaturated)
	if desaturated then
		self.Text:SetTextColor(0.5, 0.5, 0.5)
	else
		self.Text:SetTextColor(1, 1, 1)
	end
end

StoreBagCheckButtonMixin = {}

function StoreBagCheckButtonMixin:OnLoad()
	self:SetNormalAtlas("PKBT-Store-Bag-Portrait")
	self:SetPushedAtlas("PKBT-Store-Bag-Portrait-Pressed")
	self:SetDisabledAtlas("PKBT-Store-Bag-Portrait-Disabled")
	self:SetHighlightAtlas("PKBT-Store-Bag-Portrait-Highlight")
	self:SetCheckedAtlas("PKBT-Store-Bag-Portrait-Highlight")
end

StoreEquipmentButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreEquipmentButtonMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-Equipment-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-Equipment-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-Equipment-Background-Center")

	self.Highlight:SetAtlas("PKBT-Store-Equipment-Highlight", true)
	self.NewIcon:SetAtlas("PKBT-Icon-Notification", true)

	self.Icon.Border:SetAtlas("PKBT-ItemBorder-Equipment", true)
	self.Icon.Upgrade:SetAtlas("PKBT-Icon-Arrow", true)
end

function StoreEquipmentButtonMixin:OnClick(button)
	if self:IsEnabled() == 1 then
		self:GetOwner():SlotClick(button, self:GetID())
	end
end

function StoreEquipmentButtonMixin:OnEnter()
	self.Highlight:Show()
	self.Icon.Border:SetAtlas("PKBT-ItemBorder-Equipment-Highlight")
end

function StoreEquipmentButtonMixin:OnLeave()
	self.Highlight:Hide()
	self.Icon.Border:SetAtlas("PKBT-ItemBorder-Equipment")
end

function StoreEquipmentButtonMixin:OnEnable()
	self.Icon.Background:SetDesaturated(false)
	self:SetNewShown(self.hasNew and self:IsEnabled() == 1)
	self:SetUpgradeShown(self.hasUpgrade and self:IsEnabled() == 1)
end

function StoreEquipmentButtonMixin:OnDisable()
	self.Icon.Background:SetDesaturated(true)
	self:SetNewShown(false)
	self:SetUpgradeShown(false)
end

function StoreEquipmentButtonMixin:SetIconPosition(left)
	if left then
		self.ButtonText:ClearAllPoints()
		self.ButtonText:SetPoint("LEFT", 20, 0)
		self.ButtonText:SetJustifyH("LEFT")

		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("RIGHT", self, "LEFT", 10, 0)

		self.NewIcon:ClearAllPoints()
		self.NewIcon:SetPoint("TOPRIGHT", 14, 14)

		self.Highlight:ClearAllPoints()
		self.Highlight:SetPoint("LEFT", 3, 0)
		self.Highlight:SetSubTexCoord(0, 1, 0, 1)
	else
		self.ButtonText:ClearAllPoints()
		self.ButtonText:SetPoint("RIGHT", -20, 0)
		self.ButtonText:SetJustifyH("RIGHT")

		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("LEFT", self, "RIGHT", -10, 0)

		self.NewIcon:ClearAllPoints()
		self.NewIcon:SetPoint("TOPLEFT", -14, 14)

		self.Highlight:ClearAllPoints()
		self.Highlight:SetPoint("RIGHT", -3, 0)
		self.Highlight:SetSubTexCoord(1, 0, 0, 1)
	end
end

function StoreEquipmentButtonMixin:SetSlotInfo(slotID, name, icon)
	self.slotID = slotID
	self.ButtonText:SetText(name)
	self.Icon.Background:SetTexture(icon)
end

function StoreEquipmentButtonMixin:SetNew(hasNew)
	self.hasNew = hasNew
	self:SetNewShown(hasNew and self:IsEnabled() == 1)
end

function StoreEquipmentButtonMixin:SetUpgrage(hasUpgrade)
	self.hasUpgrade = hasUpgrade
	self:SetUpgradeShown(hasUpgrade and self:IsEnabled() == 1)
end

function StoreEquipmentButtonMixin:SetNewShown(shown)
	if shown then
		self.NewIcon:Show()
		if self.NewIcon.Anim:IsPlaying() then
			self.NewIcon.Anim:Stop()
		end
		self.NewIcon.Anim:Play()
	else
		self.NewIcon.Anim:Stop()
		self.NewIcon:Hide()
	end
end

function StoreEquipmentButtonMixin:SetUpgradeShown(shown)
	if shown then
		self.Icon.Upgrade:Show()
		if self.Icon.Upgrade.Anim:IsPlaying() then
			self.Icon.Upgrade.Anim:Stop()
		end
		self.Icon.Upgrade.Anim:Play()
	else
		self.Icon.Upgrade.Anim:Stop()
		self.Icon.Upgrade:Hide()
	end
end

StoreOfferTimerMixin = {}

function StoreOfferTimerMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-Timer-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-Timer-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-Timer-Background-Center")
end

StoreCollectionProductMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreCollectionProductMixin:OnLoad()
	self.Background:SetAtlas("PKBT-Store-Cards-Product-Collection-Background", true)
	self.New.Indicator:SetAtlas("PKBT-Icon-New-CornerTopRight-GreenW", true)
	self.Model.Name:SetWidth(self:GetWidth() - 30)
	self.Model.Name:SetPoint("TOP", self, "BOTTOM", 0, 78)
	self.ActionButton:SetMinWidth(140)
	self.ActionButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)

	self:RegisterCustomEvent("STORE_FAVORITE_UPDATE")
end

function StoreCollectionProductMixin:OnEvent(event, ...)
	if event == "STORE_FAVORITE_UPDATE" then
		if self.hasData then
			self:UpdateFavorite()
		end
	end
end

function StoreCollectionProductMixin:OnShow()
	SetParentFrameLevel(self.Special, 2)
	SetParentFrameLevel(self.New, 2)
	SetParentFrameLevel(self.FavoriteButton, 2)
	SetParentFrameLevel(self.ActionButton, 2)
end

function StoreCollectionProductMixin:OnEnter()
	if self.showFavoriteOnEnter then
		self.FavoriteButton:Show()
	end
end

function StoreCollectionProductMixin:OnLeave()
	if self.showFavoriteOnEnter and not self.FavoriteButton:IsMouseOverEx() then
		self.FavoriteButton:Hide()
	end
end

function StoreCollectionProductMixin:OnModelTypeChanged(modelType, modelID)
	if modelType == Enum.ModelType.M2 or modelType == Enum.ModelType.Creature then
		self.Model:SetPoint("BOTTOMRIGHT", -14, 32)
	elseif modelType == Enum.ModelType.Illusion then
		self.Model:SetPoint("BOTTOMRIGHT", -14, 14)
	end
end

function StoreCollectionProductMixin:SetProductID(productID)
	local product = C_StoreSecure.GetProductInfo(productID)

	self.productID = productID
	if product then
		self.hasData = true
		self:SetModel(product.modelType, product.modelID, C_StorePublic.GetPreferredModelFacing())
		self:SetName(GetItemInfo(product.itemID) or UNKNOWN)
		self:SetNew(product.isNew)
		self:SetPrice(product.price, product.originalPrice, product.currencyType)
		self:SetAvailable(not product.isUnavailable, product.isRollableUnavailable)
		self:UpdateFavorite()
	else
		self.hasData = nil
		self:SetNoData()
	end

	if self.ActionButton:IsMouseOverEx() then
		self.ActionButton:RefreshTooltip()
	end
end

function StoreCollectionProductMixin:SetModel(modelType, modelID, facing)
	self.Model:SetModelAuto(modelType, modelID, facing)
end

function StoreCollectionProductMixin:SetName(name)
	self.Model.Name:SetText(name)
end

function StoreCollectionProductMixin:SetNew(isNew)
	self.New:SetShown(isNew)
end

function StoreCollectionProductMixin:UpdateFavorite()
	if C_StoreSecure.IsFavoriteProductID(self.productID) then
		self.FavoriteButton:SetNormalAtlas("auctionhouse-icon-favorite", true)
		self.FavoriteButton:SetHighlightAtlas("auctionhouse-icon-favorite-off", true)
		self.FavoriteButton:Show()
		self.showFavoriteOnEnter = nil
	elseif C_StoreSecure.CanFavoriteProductID(self.productID) then
		self.FavoriteButton:SetNormalAtlas("auctionhouse-icon-favorite-off", true)
		self.FavoriteButton:SetHighlightAtlas("auctionhouse-icon-favorite", true)
		self.FavoriteButton:SetShown(self:IsMouseOverEx())
		self.showFavoriteOnEnter = true
	else
		self.FavoriteButton:Hide()
		self.showFavoriteOnEnter = nil
	end

	if self.FavoriteButton:IsMouseOverEx() then
		self:OnFavoriteEnter()
	end
end

function StoreCollectionProductMixin:SetPrice(price, originalPrice, currencyType)
	if originalPrice and originalPrice ~= price and originalPrice > 0 then
		self.Special.Text:SetFormattedText(STORE_DISCOUNT_AMOUNT_FORMAT, C_StoreSecure.GetDiscountForProductID(self.productID))
		self.Special:Show()
	else
		self.Special:Hide()
	end

	self.ActionButton:Show()
	self.ActionButton:HideSpinner()
	self.ActionButton:SetPrice(price, originalPrice, currencyType)
end

function StoreCollectionProductMixin:SetAvailable(isAvailable, isRollableUnavailable)
	if isAvailable then
		self.Model.Name:SetTextColor(1, 1, 1)
		self.New.Indicator:SetDesaturated(false)
		self.ActionButton:SetDisabledReason(nil)
		self.ActionButton:CheckBalance()
	else
		local reason = isRollableUnavailable and STORE_PRODUCT_ROLLABLE_UNAVAILABLE or STORE_PRODUCT_UNAVAILABLE
		self.Model.Name:SetTextColor(0.5, 0.5, 0.5)
		self.New.Indicator:SetDesaturated(true)
		self.ActionButton:Disable()
		self.ActionButton:SetDisabledReason(reason)
	end
end

function StoreCollectionProductMixin:SetNoData()
	self:SetName(UNKNOWN)
	self:SetNew(false)
	self.FavoriteButton:Hide()
	self.Model:ResetFull()
	self.Model:SetSpinnerShown(true)
	self.Special:Hide()
	self.ActionButton:ShowSpinner()
	self.ActionButton:Disable()
	self.ActionButton:Hide()
end

function StoreCollectionProductMixin:OnActionClick(button)
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(self.productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreCollectionProductMixin:OnFavoriteClick(button)
	local isFavorite = C_StoreSecure.IsFavoriteProductID(self.productID)
	local success = C_StoreSecure.SetFavoriteProductID(self.productID, not isFavorite)
	if success then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
end

function StoreCollectionProductMixin:OnFavoriteEnter()
	GameTooltip:SetOwner(self.FavoriteButton, "ANCHOR_RIGHT")
	if C_StoreSecure.IsFavoriteProductID(self.productID) then
		GameTooltip:AddLine(STORE_FAVORITE_UNSET)
	else
		GameTooltip:AddLine(STORE_FAVORITE_SET)
	end
	GameTooltip:Show()
end

function StoreCollectionProductMixin:OnFavoriteLeave()
	GameTooltip:Hide()
end

StoreTransmogOfferButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreTransmogOfferButtonMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-ItemPlate-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-ItemPlate-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-ItemPlate-Background-Center")

	self.IconBorder:SetAtlas("PKBT-ItemBorder-Default", true)
	self.Price:SetOriginalOnTop(true)

	self.UpdateTooltip = self.OnEnter
end

function StoreTransmogOfferButtonMixin:OnShow()
	SetParentFrameLevel(self.Loading, 5)
end

function StoreTransmogOfferButtonMixin:OnHide()
	self.NineSliceHighlight:Hide()
end

function StoreTransmogOfferButtonMixin:OnEnter()
	if self:IsEnabled() == 1 then
		self.NineSliceHighlight:Show()
	end

	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
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
end

function StoreTransmogOfferButtonMixin:OnLeave()
	self.NineSliceHighlight:Hide()

	if self.itemLink then
		GameTooltip:Hide()
	end
end

function StoreTransmogOfferButtonMixin:OnClick(button)
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(self.productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreTransmogOfferButtonMixin:SetOfferIndex(offerIndex)
	local name, link, rarity, icon, amount, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetTransmogOfferInfo(offerIndex)

	self.productID = productID
	self.itemLink = link

	self.Name:SetText(name)
	self.Name:ClearAllPoints()
	self.Icon:SetTexture(icon)
	self.Amount:SetText(amount > 1 and amount or "")
	local r, g, b = GetItemQualityColor(rarity)
	self.IconBorder:SetVertexColor(r, g, b)

	if originalPrice and originalPrice ~= price and originalPrice > 0 then
		self.Name:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 12, -4)
		self.Special.Text:SetFormattedText(STORE_PRODUCT_DISCOUNT, C_StoreSecure.GetDiscountForProductID(productID))
		self.Special:Show()
	else
		self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 12, 0)
		self.Special:Hide()
	end

	self.Price:SetPrice(price, originalPrice, currencyType)
end

function StoreTransmogOfferButtonMixin:SetLoading(state)
	state = true
	self.Loading:SetShown(state)
	self:SetEnabled(not state)
end

StoreModelPanelMixin = CreateFromMixins(PKBT_DressUpBaseMixin)

function StoreModelPanelMixin:OnLoad()
	PKBT_DressUpBaseMixin.OnLoad(self)

	self.Background:SetAtlas("PKBT-Tile-DarkRock-256", true)

	self.ShadowLeft:SetAtlas("PKBT-Background-Shadow-Small-44-Left", true)
	self.ShadowRight:SetAtlas("PKBT-Background-Shadow-Small-44-Right", true)
	self.ShadowTop:SetAtlas("PKBT-Background-Shadow-Small-44-Top", true)
	self.ShadowBottom:SetAtlas("PKBT-Background-Shadow-Small-44-Bottom", true)
end

function StoreModelPanelMixin:OnShow()
	SetParentFrameLevel(self.Overlay, 2)
	SetParentFrameLevel(self.EquipmentToggle, 3)
	SetParentFrameLevel(self.AbilityOverlay, 3)
end

function StoreModelPanelMixin:Close()
	self:Hide()
	LootCasePreviewFrame:Hide()
end

StoreDressUpMixin = CreateFromMixins(PKBT_DressUpMixin, PKBT_CountdownThrottledBaseMixin)

function StoreDressUpMixin:OnLoad()
	PKBT_DressUpMixin.OnLoad(self)

	self.BackgroundAlt:SetAtlas("PKBT-Store-DressUp-Background-2", true)
	self.MinimizeButton:SetMinimizeLook(false)

	self.SetOverlay.Name:SetPoint("BOTTOM", self.SetOverlay.Items, "TOP", 0, 5)

	self.PurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)
	self.PurchaseButton:SetPadding(25)
	self.PurchaseButton:AddText(STORE_BUY)

	self.itemButtons = {}
	self.itemOffsetX = 5
	self.setItemIDs = {}

	self:SetNoDisplayDataMode(true)

	self.Model.OnPortraitCameraToggle = function(this, enabled)
		if self.modelType == Enum.ModelType.Item
		or self.modelType == Enum.ModelType.ItemSet
		then
			if enabled and self.allowPortraitCamera then
				self:SetPanningEnabled(true)
				return
			end
		end
		self:SetPanningEnabled(false)
	end
end

function StoreDressUpMixin:OnShow()
	PKBT_DressUpMixin.OnShow(self)

	SetParentFrameLevel(self.SetOverlay, 2)
	SetParentFrameLevel(self.AbilityOverlay, 3)
	SetParentFrameLevel(self.PurchaseButton, 4)

	self.SetOverlay.Name:SetWidth(self:GetWidth() - 25)
end

function StoreDressUpMixin:Close()
	if type(self.onClose) == "function" then
		local success, err = pcall(self.onClose, self)
		if not success then
			geterrorhandler(err)
			self:Hide()
		end
	else
		self:Hide()
	end
end

function StoreDressUpMixin:SetItem(itemLink, allowToHide, allowEquipmentToggle, allowPortraitCamera)
	if self.item == itemLink then
		return true
	end

	local modelType, modelID, canHaveAbilities
	local linkType, id, collectionID = GetDressUpItemLinkInfo(itemLink)
	if linkType == Enum.DressUpLinkType.Default then
		modelType = Enum.ModelType.Item
		modelID = itemLink
	elseif linkType == Enum.DressUpLinkType.Pet or linkType == Enum.DressUpLinkType.Mount then
		modelType = Enum.ModelType.Creature
		modelID = id
		if linkType == Enum.DressUpLinkType.Mount then
			canHaveAbilities = true
		end
	elseif linkType == Enum.DressUpLinkType.Illusion then
		modelType = Enum.ModelType.Illusion
		modelID = id
	else
		self:SetNoDisplayDataMode(true)
		return false
	end

	self:SetNoDisplayDataMode(false)

	self.item = itemLink
	self.modelType = modelType
	self.modelID = modelID
	self.allowEquipmentToggle = allowEquipmentToggle
	self.allowPortraitCamera = allowPortraitCamera
	self.showPurchaseButton = nil
	self.priceDirtyProductID = nil
	self.forceDressed = nil

	table.wipe(self.setItemIDs)
	self.setProducts = nil

	self.SetOverlay.Items:Hide()

	self.VignetteTopRight:SetShown(not allowToHide)
	self.MinimizeButton:SetShown(allowToHide)
	self.PurchaseButton:Hide()
	self:SetModel(self.modelType, self.modelID, true)

	local itemName = GetItemInfo(self.item)
	if itemName then
		self.SetOverlay.Name:SetText(itemName)
		self.SetOverlay.Name:Show()
	else
		self.SetOverlay.Name:Hide()
	end

	if canHaveAbilities then
		self.AbilityOverlay:SetItemAbilities(itemLink)
	else
		self.AbilityOverlay:ClearItemAbilities()
	end

	return true
end

function StoreDressUpMixin:SetProduct(productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
	if self.productID == productID then
		if self.priceDirtyProductID then
			local success = self.PurchaseButton:SetPrice(C_StoreSecure.GetProductPrice(self.priceDirtyProductID))
			self.PurchaseButton:SetShown(success and self.showPurchaseButton)
			self.priceDirtyProductID = nil
		end

		return true
	end

	local product = C_StoreSecure.GetProductInfo(productID)
	if not product then
		self:SetNoDisplayDataMode(true)
		return false
	end

	local modelType, modelID, abilityItem

	if product.setProducts then
		modelType = Enum.ModelType.ItemSet
		modelID = self.setItemIDs
	else
		local linkType, id, collectionID = GetDressUpItemLinkInfo(product.itemID)
		if linkType == Enum.DressUpLinkType.Default then
			modelType = Enum.ModelType.Item
			modelID = product.itemID
		elseif linkType == Enum.DressUpLinkType.Pet or linkType == Enum.DressUpLinkType.Mount then
			modelType = Enum.ModelType.Creature
			modelID = product.modelID
			if linkType == Enum.DressUpLinkType.Mount then
				abilityItem = product.itemID
			end
		elseif linkType == Enum.DressUpLinkType.Illusion then
			modelType = Enum.ModelType.Illusion
			modelID = product.modelID
		else
			self:SetNoDisplayDataMode(true)
			return false
		end
	end

	self:SetNoDisplayDataMode(false)

	self.productID = productID
	self.item = product.itemID
	self.modelType = modelType
	self.modelID = modelID
	self.allowEquipmentToggle = allowEquipmentToggle
	self.allowPortraitCamera = allowPortraitCamera
	self.showPurchaseButton = showPurchaseButton

	if product.isRollableUnavailable then
		self.disabledReason = STORE_PRODUCT_ROLLABLE_UNAVAILABLE
	elseif product.isUnavailable then
		self.disabledReason = STORE_PRODUCT_UNAVAILABLE
	else
		self.disabledReason = nil
	end

	if product.categoryID == Enum.Store.Category.Transmogrification and product.subCategoryID == 3 then
		self.forceDressed = true
	else
		self.forceDressed = nil
	end

	if self.modelType == Enum.ModelType.Default
	or self.modelType == Enum.ModelType.Item
	or self.modelType == Enum.ModelType.ItemSet
	then
		self.Background:Show()
		self.BackgroundAlt:Hide()
	else
		self.Background:Hide()
		self.BackgroundAlt:SetAtlas("PKBT-Store-DressUp-Background-6")
		self.BackgroundAlt:Show()
	end

	if product.setProducts then
		table.wipe(self.setItemIDs)

		for index, setItemData in ipairs(product.setProducts) do
			self.setItemIDs[index] = setItemData.itemID
		end

		self.setProducts = product.setProducts

		self.SetOverlay.Items:Show()

		for itemIndex, setProductInfo in ipairs(self.setProducts) do
			local button = self.itemButtons[itemIndex]
			if not button then
				button = CreateFrame("Button", strformat("$parentItemButton%u", itemIndex), self.SetOverlay.Items, "StoreDressUpSetItemTemplate")
				button:SetID(itemIndex)
				button:SetOwner(self)

				if itemIndex == 1 then
					button:SetPoint("TOPLEFT", 0, 0)
				else
					button:SetPoint("TOPLEFT", self.itemButtons[itemIndex - 1], "TOPRIGHT", self.itemOffsetX, 0)
				end

				self.itemButtons[itemIndex] = button
			end

			local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(setProductInfo.itemID)
			button.Icon:SetTexture(texture)
			button.link = link
			button:Show()
		end

		local numItems = #self.setProducts

		for itemIndex = numItems + 1, #self.itemButtons do
			self.itemButtons[itemIndex]:Hide()
		end

		if numItems > 0 then
			self.SetOverlay.Items:SetSize(self.itemButtons[1]:GetWidth() * numItems + self.itemOffsetX * (numItems - 1), self.itemButtons[1]:GetHeight())
		end
	else
		table.wipe(self.setItemIDs)
		self.setProducts = nil

		self.SetOverlay.Items:Hide()
	end

	self.VignetteTopRight:SetShown(not allowToHide)
	self.MinimizeButton:SetShown(allowToHide)
	self.PurchaseButton:SetDisabledReason(self.disabledReason)
	self.PurchaseButton:SetEnabled(self.disabledReason == nil)
	self.PurchaseButton:SetShown(showPurchaseButton)
	self:ShowItemSetModel(0)
	self.AbilityOverlay:SetItemAbilities(abilityItem)

	return true
end

function StoreDressUpMixin:ShowItemSetModel(modelIndex, preserveFacting, preservePosition)
	self.modelIndex = modelIndex

	if modelIndex == 0 then
		local product = C_StoreSecure.GetProductInfo(self.productID)

		local itemName = product and product.itemID and GetItemInfo(product.itemID)
		if itemName then
			self.SetOverlay.Name:SetText(itemName)
			self.SetOverlay.Name:Show()
		else
			self.SetOverlay.Name:Hide()
		end

		if self.setProducts then
			for index, button in ipairs(self.itemButtons) do
				button.selected = nil
				button.Icon:SetDesaturated(false)
			end
		end

		self:SetModel(self.modelType, self.modelID, true, preserveFacting, preservePosition)

		local success = self.PurchaseButton:SetPrice(C_StoreSecure.GetProductPrice(self.productID))
		self.PurchaseButton:SetShown(success and self.showPurchaseButton)
		if not success then
			self.priceDirtyProductID = self.productID
		end
	elseif self.setProducts and modelIndex <= #self.itemButtons then
		local itemProduct = self.setProducts[modelIndex]

		local itemName = itemProduct.itemID and GetItemInfo(itemProduct.itemID)
		if itemName then
			self.SetOverlay.Name:SetText(itemName)
			self.SetOverlay.Name:Show()
		else
			self.SetOverlay.Name:Hide()
		end

		for index, button in ipairs(self.itemButtons) do
			button.selected = index == modelIndex and true or nil
			button.Icon:SetDesaturated(index ~= modelIndex)
		end

		self:SetModel(Enum.ModelType.Item, itemProduct.itemID, true, preserveFacting, preservePosition)

		local success = self.PurchaseButton:SetPrice(C_StoreSecure.GetProductPrice(itemProduct.productID))
		self.PurchaseButton:SetShown(success and self.showPurchaseButton)
		if not success then
			self.priceDirtyProductID = itemProduct.productID
		end
	else
		self:SetModel(nil, nil)
		self.priceDirtyProductID = nil
	end
end

function StoreDressUpMixin:SetModel(modelType, modelID, undress, preserveFacting, preservePosition)
	if modelType == Enum.ModelType.Item
	or modelType == Enum.ModelType.ItemSet
	then
		if self.forceDressed then
			undress = false
		end
		self.Model:SetModelAuto(modelType, modelID, nil, nil, nil, nil, undress, preserveFacting, preservePosition)
		self:SetZoomEnabled(false)
		self:SetRotateEnabled(true)
		self:SetPanningEnabled(self.allowPortraitCamera and self:IsPortraitCamera())
		self:SetPlayerEquipmentToggleEnabled(not self.forceDressed and self.allowEquipmentToggle and modelType == Enum.ModelType.Item)
		self:SetPortraitCameraToggleEnabled(self.allowPortraitCamera)
		return true
	elseif modelType == Enum.ModelType.Creature then
		local facing = C_StorePublic.GetPreferredModelFacing()
		self.Model:SetModelAuto(Enum.ModelType.Creature, modelID, -facing)
		self:SetZoomEnabled(false)
		self:SetRotateEnabled(true)
		self:SetPanningEnabled(false)
		self:SetPlayerEquipmentToggleEnabled(false)
		self:SetPortraitCameraToggleEnabled(false)
		return true
	elseif modelType == Enum.ModelType.Illusion then
		self.Model:SetModelAuto(Enum.ModelType.Illusion, modelID)
		self:SetZoomEnabled(false)
		self:SetRotateEnabled(false)
		self:SetPanningEnabled(false)
		self:SetPlayerEquipmentToggleEnabled(false)
		self:SetPortraitCameraToggleEnabled(false)
		return true
	else
		self.Model:ResetFull()
		self:SetZoomEnabled(false)
		self:SetRotateEnabled(false)
		self:SetPanningEnabled(false)
		self:SetPlayerEquipmentToggleEnabled(false)
		self:SetPortraitCameraToggleEnabled(false)
		return false
	end
end

function StoreDressUpMixin:ResetModelSettings()
	self.productID = nil
	self.item = nil
	self.modelType = nil
	self.modelID = nil
	self.allowEquipmentToggle = nil
	self.allowPortraitCamera = nil
	self.showPurchaseButton = nil
	self.priceDirtyProductID = nil
	self.forceDressed = nil
	self.disabledReason = nil
	self.setProducts = nil
	self.PurchaseButton:SetDisabledReason(nil)
end

function StoreDressUpMixin:SetNoDisplayDataMode(isNoDisplayDataMode)
	self:ResetModelSettings()
	self.Background:SetShown(not isNoDisplayDataMode)
	self.BackgroundAlt:SetShown(isNoDisplayDataMode)
	self.NoProduct:SetShown(isNoDisplayDataMode)
	self.Model:SetShown(not isNoDisplayDataMode)
	self.Overlay:SetShown(not isNoDisplayDataMode)
	self.SetOverlay:SetShown(not isNoDisplayDataMode)
	self.AbilityOverlay:SetShown(not isNoDisplayDataMode)

	if not isNoDisplayDataMode then
		self.PurchaseButton:Hide()
	end
end

function StoreDressUpMixin:OnPurchaseClick(button)
	local productID
	if self.modelIndex == 0 then
		productID = self.productID
	else
		local itemProduct = self.setProducts[self.modelIndex]
		if itemProduct then
			productID = itemProduct.productID
		end
	end

	if productID then
		C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(productID)
		PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
	end
end

StoreMountAbilityOverlayMixin = {}

function StoreMountAbilityOverlayMixin:OnLoad()
	self.abilitiesPool = CreateFramePool("Button", self, "MountAbilityButtonTemplate")
	self.basePoint = "BOTTOMRIGHT"
	self.baseOffsetX = 0
	self.baseOffsetY = 80
end

function StoreMountAbilityOverlayMixin:SetBasePoint(point, offsetX, offsetY)
	self.basePoint = point
	self.baseOffsetX = offsetX
	self.baseOffsetY = offsetY
end

function StoreMountAbilityOverlayMixin:ClearItemAbilities(releasePool)
	if releasePool then
		self.abilitiesPool:ReleaseAll()
	end
	self:Hide()
end

function StoreMountAbilityOverlayMixin:SetItemAbilities(item)
	self.abilitiesPool:ReleaseAll()

	if not item then
		self:Hide()
		return false
	end

	local abilities = C_MountJournal.GetMountAbilitiesInfoByItemID(item)
	if abilities and #abilities > 0 then
		local lastButton
		for _, abilityID in ipairs(abilities) do
			local button = self.abilitiesPool:Acquire()
			button.abilityID = abilityID
			button:Show()

			local name, icon, description, specialText = C_MountJournal.GetAbilityInfo(abilityID)
			button.Icon:SetTexture(icon)

			if not lastButton then
				button:SetPoint(self.basePoint, self.baseOffsetX, self.baseOffsetY)
			else
				button:SetPoint("BOTTOMRIGHT", lastButton, "TOPRIGHT", 0, -6)
			end
			lastButton = button
		end

		self:Show()
		return true
	else
		self:Hide()
		return false
	end
end

StoreDressUpOfferMixin = CreateFromMixins(StoreDressUpMixin)

function StoreDressUpOfferMixin:OnLoad()
	StoreDressUpMixin.OnLoad(self)

	self.BackgroundAlt:SetAtlas("PKBT-Store-DressUp-Background-2", true)
	self.OfferOverlay.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)
end

function StoreDressUpOfferMixin:OnShow()
	StoreDressUpMixin.OnShow(self)

	SetParentFrameLevel(self.OfferOverlay, 2)
end

function StoreDressUpOfferMixin:OnHide()
	self.OfferOverlay:Hide()
	self:CancelCountdown()
end

function StoreDressUpOfferMixin:ShowItemSetModel(modelIndex, preserveFacting, preservePosition)
	StoreDressUpMixin.ShowItemSetModel(self, modelIndex, preserveFacting, preservePosition)

	self.Header:SetShown(self.Model:GetModel() ~= nil and self.PurchaseButton:HasDiscount())
end

function StoreDressUpOfferMixin:SetOfferCountdown(timeLeft)
	self:SetTimeLeft(timeLeft)
end

function StoreDressUpOfferMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 then
		self.OfferOverlay.Timer:SetText(GetRemainingTime(timeLeft))
		self.OfferOverlay:Show()
	else
		self.OfferOverlay:Hide()

		if timerFinished then
			local parent = self:GetParent()
			local onFinish = parent.OnItemSetOfferCountdownFinish
			if type(onFinish) == "function" then
				onFinish(parent)
			end
		end
	end
end

StoreDressUpSetItemMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreDressUpSetItemMixin:OnEnter()
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end
end

function StoreDressUpSetItemMixin:OnLeave()
	if self.link then
		GameTooltip:Hide()
	end
end

function StoreDressUpSetItemMixin:OnClick(button)
	if IsAltKeyDown() and C_StoreSecure.AddItem(self.link) then
		return
	end
	if IsModifiedClick("CHATLINK") then
		if self.link then
			ChatEdit_InsertLink(self.link)
		end
	else
		if self.selected then
			self.selected = nil
			self:GetOwner():ShowItemSetModel(0, true, true)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		else
			self.selected = true
			self:GetOwner():ShowItemSetModel(self:GetID(), true, true)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end
end

StoreAnnonceBlockMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function StoreAnnonceBlockMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-AnnonceBlockTop-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-AnnonceBlockTop-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-AnnonceBlockTop-Center")

	self.Countdown.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)
end

function StoreAnnonceBlockMixin:OnHide()
	self:CancelCountdown()
end

function StoreAnnonceBlockMixin:SetHeader(text)
	self.Header:SetText(text)
end

function StoreAnnonceBlockMixin:SetAnnonceCountdown(timeLeft)
	self:SetTimeLeft(timeLeft)
end

function StoreAnnonceBlockMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 then
		self.Countdown.Timer:SetText(GetRemainingTime(timeLeft))
		self.Countdown:Show()
	else
		self.Countdown:Hide()

		if timerFinished then
			if type(self.OnCountdownFinish) == "function" then
				self.OnCountdownFinish(self)
			end
		end
	end
end

StoreDialogCloseHandlingMixin = {}

function StoreDialogCloseHandlingMixin.onCloseCallback(this)
	if type(this.OnClose) == "function" then
		this:OnClose()
	elseif type(this:GetParent().OnClose) == "function" then
		this:GetParent():OnClose()
	end
end

function StoreDialogCloseHandlingMixin:OnClose()
	if type(self.OnCloseCallback) == "function" then
		local success, res = pcall(self.OnCloseCallback)
		if not success then
			geterrorhandler()(res)
			return false
		end
		return res
	end
end

function StoreDialogCloseHandlingMixin:Close()
	self:Hide()
	self:OnClose()
end

StoreSubDialogMixin = {}

function StoreSubDialogMixin:OnLoad()
	self.Background:SetAtlas("PKBT-Tile-Parchment-128", true)
	self.ShadowTop:SetAtlas("PKBT-Store-Background-Parchment-Shadow-Top", true)
	self.ShadowBottom:SetAtlas("PKBT-Store-Background-Parchment-Shadow-Bottom", true)
	self.Divider:SetAtlas("PKBT-Divider-Paper", true)
end

function StoreSubDialogMixin:OnActionClick(button)
end

function StoreSubDialogMixin:OnCancelClick(button)
	if type(self.onCloseCallback) == "function" then
		self.onCloseCallback(self, button)
	else
		self:Hide()
	end
end

StoreGenericDialogMixin = {}

function StoreGenericDialogMixin:OnLoad()
	self.Divider:SetAtlas("PKBT-Divider-Paper", true)
	self.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.IconShadow:SetAtlas("PKBT-IconShadow", true)
	self.Icon:SetAtlas("PKBT-Icon-Alert", true)
end

function StoreGenericDialogMixin:OnHide()
	self.__actionClickHandler = nil
	self.__cancelButtonHandler = nil
end

function StoreGenericDialogMixin:SetStyle(styleIndex, showDivider)
	if styleIndex == Enum.StoreDialogStyle.Paper then
		self.linkColor = "003ACC"
		self.TextContent:SetPoint("TOP", self.Divider, "BOTTOM", 0, -10)
		self.TextContent:SetHyperlinkFormat("|cff%s|H%s|h[%s]|h|r", self.linkColor)

		self.BackgroundTile:SetAtlas("PKBT-Tile-Parchment-128", true)
		self.BackgroundShadowTop:SetAtlas("PKBT-Store-Background-Parchment-Shadow-Top", true)
		self.BackgroundShadowBottom:SetAtlas("PKBT-Store-Background-Parchment-Shadow-Bottom", true)

		self.BackgroundTile:Show()
		self.Background:Hide()
		self.BackgroundShadowTop:Show()
		self.BackgroundShadowBottom:Show()

		self.VignetteTopLeft:Hide()
		self.VignetteTopRight:Hide()
		self.Divider:SetShown(showDivider)
		self.IconShadow:Hide()

		NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PKBT_PanelMetalBorder")
		self.Title:SetFontObject("PKBT_Font_30_NoShadow")
		self.TextContent:SetFontObject("PKBT_Font_15_NoShadow")
		self.Title:SetTextColor(0.160, 0.074, 0.043)
		self.TextContent:SetTextColor(0.160, 0.074, 0.043)
	else--if styleIndex == Enum.StoreDialogStyle.Wood then
		self.linkColor = "ffd200"
		self.TextContent:SetPoint("TOP", self.Title, "BOTTOM", 0, -22)
		self.TextContent:SetHyperlinkFormat("|cff%s|H%s|h[%s]|h|r", self.linkColor)

		self.BackgroundTile:SetAtlas("PKBT-Tile-Wood-128", true)
		self.Background:Hide()
		self.BackgroundTile:Show()
		self.BackgroundShadowTop:Hide()
		self.BackgroundShadowBottom:Hide()

		self.VignetteTopLeft:Show()
		self.VignetteTopRight:Show()
		self.Divider:Hide()
		self.IconShadow:Show()

		NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PKBT_PanelNoPortraitSlim")
		self.Title:SetFontObject("PKBT_Font_30")
		self.TextContent:SetFontObject("PKBT_Font_15")
		self.Title:SetTextColor(1, 0.82, 0)
		self.TextContent:SetTextColor(1, 1, 1)
	end
end

function StoreGenericDialogMixin:SetIconAtlas(atlasName, useAtlasSize, overrideWidth, overrideHeight)
	self.Icon:SetAtlas(atlasName, useAtlasSize)

	if overrideWidth then
		self.Icon:SetWidth(overrideWidth)
	elseif not useAtlasSize then
		self.Icon:SetWidth(self:GetHeight())
	end
	if overrideHeight then
		self.Icon:SetHeight(overrideHeight)
	elseif not useAtlasSize then
		self.Icon:SetHeight(self:GetHeight())
	end
end

function StoreGenericDialogMixin:SetDebugInfo(debugInfo)
	if debugInfo then
		self.DebugInfo:SetText(tostring(debugInfo))
	else
		self.DebugInfo:SetText("")
	end
end

function StoreGenericDialogMixin:HandleClick(button, handler)
	local continueHide = true
	if type(handler) == "function" then
		local success, res = pcall(handler, self, button)
		if success then
			continueHide = res
		else
			geterrorhandler()(res)
		end
	end
	if continueHide then
		HideUIPanel(self)
	end
end

function StoreGenericDialogMixin:OnActionClick(button)
	self:HandleClick(button, self.__actionClickHandler)
end

function StoreGenericDialogMixin:OnCancelClick(button)
	self:HandleClick(button, self.__cancelButtonHandler)
end

function StoreGenericDialogMixin:FormatLink(text)
	local fmt = string.format("%%1|cff%1$s|Hurl:%%2|h[%%2]|h|r", self.linkColor)
	text = string.gsub(text, "(.*)(https?://[^%s]+)", fmt)
	return text
end

function StoreGenericDialogMixin:ShowGenericDialog(styleIndex, title, text, actionButtonText, cancelButtonText, actionButtonHandler, cancelButtonHandler)
	self:SetStyle(styleIndex, text ~= nil)
	self.Title:SetText(title or STORE_ERROR_LABEL)
	self.TextContent:SetText(self:FormatLink(text))
	self.TextContent:GetRegions():SetJustifyH("CENTER")
	self.TextContent:SetWidth(self:GetWidth() - 40)
	self.ActionButton:SetText(actionButtonText or ACCEPT)
	self.CancelButton:SetText(cancelButtonText or CLOSE)
	self:SetDebugInfo(nil)

	if type(actionButtonHandler) == "function" then
		self.__actionClickHandler = actionButtonHandler
		self.ActionButton:Show()
		self.ActionButton:SetPoint("BOTTOM", -82, 40)
		self.CancelButton:SetPoint("BOTTOM", 82, 40)
	else
		self.__actionClickHandler = nil
		self.ActionButton:Hide()
		self.CancelButton:SetPoint("BOTTOM", 0, 40)
	end

	if type(cancelButtonHandler) == "function" then
		self.__cancelButtonHandler = cancelButtonHandler
	else
		self.__cancelButtonHandler = nil
	end

	self:SetHeight(300 + self.TextContent:GetHeight())
	self:Show()
end

function StoreGenericDialogMixin:OnHyperlinkClick(this, link, text, button)
	if button ~= "LeftButton" then return end

	local linkType, linkData = string.split(":", link, 2)
	if linkType == "url" then
		C_StoreSecure.GetStoreFrame():ShowLinkDialog(self:GetParent(), nil, nil, linkData)
	else
		GMError(string.format("[STORE_DIALOG] Unknown hyperlink type [%s] for link \"%s\"", tostring(linkType), tostring(linkData)))
	end
end

function StoreGenericDialogMixin:ShowHyperlinkTooltip(this, link, data, isHyperlink)
	if not data then
		GMError(string.format("[STORE_DIALOG] No link data for \"%s\"", link), 2)
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 10, 10)
	if isHyperlink then
		GameTooltip:SetHyperlink(data)
	else
		GameTooltip:AddLine(data, 1, 1, 1)
	end
	GameTooltip:Show()
end

function StoreGenericDialogMixin:OnHyperlinkEnter(this, link, text)
	local linkType, linkData = string.split(":", link, 2)
	if linkType == "url" then
		self:ShowHyperlinkTooltip(this, link, linkData, false)
		SetCursor("Interface/Cursor/Cast")
	end
end

function StoreGenericDialogMixin:OnHyperlinkLeave(this, link, text)
	ResetCursor()
	GameTooltip:Hide()
end

StoreGiftPanelMixin = {}

function StoreGiftPanelMixin:OnLoad()
	self.BackgroundTop:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom-Rounded", true)
	self.DividerTop:SetAtlas("PKBT-Divider-Dark", true)

	self.ShadowTop:SetAtlas("PKBT-Store-Paper-Shadow-Top", true)
	self.ShadowBottom:SetAtlas("PKBT-Store-Paper-Shadow-Bottom", true)

	self.NameEditBox:SetFontObject("PKBT_Font_14")
	self.NameEditBox.Instructions:SetFontObject("PKBT_Font_14")
	self.NameEditBox:SetInstructions(STORE_PRODUCT_PURCHASE_OPTION_GIFT_NAME_INSTRUCTIONS)

	self.TextEditBoxScroll:SetTransperentBackdrop(true)
	self.TextEditBoxScroll.ScrollBar:SetScrollBarHideable(true)
	self.TextEditBoxScroll.ScrollBar:SetBackgroundShown(false)

	self.TextEditBoxScroll.EditBox:SetFontObject("PKBT_Font_14")
	self.TextEditBoxScroll.EditBox.Instructions:SetFontObject("PKBT_Font_14")
	self.TextEditBoxScroll:SetMaxLetters(C_StoreSecure.GetGiftTextMaxLetters())
	self.TextEditBoxScroll:SetInstructions(STORE_PRODUCT_PURCHASE_OPTION_GIFT_TEXT_INSTRUCTIONS)

	self.NameEditBox:SetBlockWhitespaces(true)
	self.NameEditBox:SetCustomCharFilter(function(text)
		local isUTF
		if utf8len(text) ~= strlen(text) then
			isUTF = strlen(utf8sub(text, 1, 1)) ~= 1 -- no language mixing
		end
		return isUTF and utf8gsub(text, "[^А-яЁё]", "") or strgsub(text, "[^A-z]", "")
	end)
	self.NameEditBox.OnTextValueChanged = function(this, value, userInput)
		self:GetParent():ValidateOptions()
	end

	self.TextEditBoxScroll.EditBox.OnTextValueChanged = function(this, value, userInput)
		self:GetParent():ValidateOptions()
	end

	self.NameEditBox.nextEditBox = self.TextEditBoxScroll.EditBox
	self.TextEditBoxScroll.EditBox.nextEditBox = self.NameEditBox

	self.dropdownInitFunction = function(dropdown, level, menuList)
		local setValue = function(ddButton, this, value, checked)
			UIDropDownMenu_SetSelectedID(dropdown, ddButton:GetID())
			self:SetMailStyle(ddButton:GetID())
			self:GetParent():ValidateOptions()
		end
		local isChecked = function(ddButton)
			return self.selectedStyleIndex == ddButton.arg2
		end
		for styleIndex = 1, C_StoreSecure.GetNumPurchaseGiftOptions() do
			local id, name, textureLeft, textureRight = C_StoreSecure.GetPurchaseGiftOption(styleIndex)
			local info = UIDropDownMenu_CreateInfo()
			info.padding = 8
			info.text = name
			info.checked = isChecked
			info.func = setValue
			info.arg1 = dropdown
			info.arg2 = styleIndex
			UIDropDownMenu_AddButton(info)
		end
	end
	UIDropDownMenu_SetInitializeFunction(self.StyleDropdown, self.dropdownInitFunction)
end

function StoreGiftPanelMixin:OnShow()
	if not self.selectedStyleIndex then
		self:SetMailStyle(1, true)
	end
	UIDropDownMenu_Initialize(self.StyleDropdown, self.dropdownInitFunction)
end

function StoreGiftPanelMixin:SetMailStyle(styleIndex, reset)
	if self.selectedStyleIndex ~= styleIndex then
		local id, name, textureLeft, textureRight = C_StoreSecure.GetPurchaseGiftOption(styleIndex)
		self.BackgroundMailLeft:SetTexture(textureLeft)
		self.BackgroundMailRight:SetTexture(textureRight)

		if not reset then
			self.selectedStyleIndex = styleIndex
			UIDropDownMenu_SetSelectedID(self.StyleDropdown, styleIndex)
		end
	end

	if reset then
		self.selectedStyleIndex = nil
		UIDropDownMenu_SetSelectedID(self.StyleDropdown, nil)
		UIDropDownMenu_SetText(self.StyleDropdown, string.format("|cff595959%s|r", STORE_PRODUCT_PURCHASE_OPTION_GIFT_CHOOSE_STYLE))
	end
end

function StoreGiftPanelMixin:IsInputValid()
	if not self.selectedStyleIndex then
		return false, STORE_GIFT_ERROR_NO_STYLE
	end

	local name = string.trim(self.NameEditBox:GetText())
	local nameLen = utf8.len(name)
	if nameLen == 0 then
		return false, STORE_GIFT_ERROR_NO_RECEIVER_NAME
	elseif nameLen < 2 or nameLen > 12 then
		return false, string.format(STORE_GIFT_ERROR_RECEIVER_NAME_LENGTH, 2, 12)
	end

	local text = string.trim(self.TextEditBoxScroll.EditBox:GetText())
	local textLen = utf8.len(text)
	if textLen < 3 or textLen > C_StoreSecure.GetGiftTextMaxLetters() then
		return false, string.format(STORE_GIFT_ERROR_RECEIVER_TEXT_LENGTH, 3, C_StoreSecure.GetGiftTextMaxLetters())
	end

	return true
end

function StoreGiftPanelMixin:Reset()
	self.NameEditBox:SetText("")
	self.TextEditBoxScroll.EditBox:SetText("")
	self:SetMailStyle(1, true)
end

function StoreGiftPanelMixin:GetGiftInfo()
	local style = self.selectedStyleIndex
	local name = string.trim(self.NameEditBox:GetText())
	local text = string.trim(self.TextEditBoxScroll.EditBox:GetText())
	return style, name, text
end

StorePurchaseAlertMixin = {}

function StorePurchaseAlertMixin:OnShow()
	self.AnimIn:Play()
--	self.WaitAndAnimOut:Play()

	self.Glow:Show()
	self.Glow.AnimIn:Play()

	self.Shine:Show()
	self.Shine.AnimIn:Play()

	PlaySound(SOUNDKIT.UI_IG_STORE_PURCHASE_DELIVERED_TOAST_01)
end

function StorePurchaseAlertMixin:OnHide()
	self.AnimIn:Stop()
	self.WaitAndAnimOut:Stop()

	self.Glow:Hide()
	self.Glow.AnimIn:Stop()

	self.Shine:Hide()
	self.Shine.AnimIn:Stop()

	if type(self.onHideCallback) == "function" then
		local success, err = pcall(self.onHideCallback, self)
		if not success then
			geterrorhandler()(err)
		end
	end
end

function StorePurchaseAlertMixin:OnEnter()
	self.WaitAndAnimOut:Stop()
	self.WaitAndAnimOut:Play()
	self:SetAlpha(1)
end

function StorePurchaseAlertMixin:OnClick(button)
	self:Hide()
end

function StorePurchaseAlertMixin:SetAlertInfo(icon, title, description)
	if type(icon) == "string" and C_Texture.HasAtlasInfo(icon) then
		self.Icon:SetAtlas(icon)
	else
		self.Icon:SetTexCoord(0, 1, 0, 1)
		self.Icon:SetTexture(icon or "Interface/Icons/INV_Misc_QuestionMark")
	end
	self.Title:SetText(title or "")
	self.Description:SetText(description or STORE_DELIVERED_PURCHASE_SELF)
end

StoreToastMixin = {}

function StoreToastMixin:OnLoad()
	self.Model.LoadingSpinner:SetAlpha(0)
end

function StoreToastMixin:OnShow()
	PlaySound("RaidBossEmoteWarning")
	self.AnimIn:Play()
	self.Glow.AnimIn:Play()
end

function StoreToastMixin:OnClick(button)
	self:Hide()

	local enabled, loading, reson = C_StorePublic.IsEnabled()
	if enabled and not loading then
		ShowUIPanel(C_StoreSecure.GetStoreFrame())
	end
end

function StoreToastMixin:OnMouseDown(button)
	if self:IsEnabled() == 1 then
		self.Icon:SetPoint("LEFT", 7, -2)
		self.IconHighlight:SetPoint("LEFT", 7, -2)
		self.Title:SetPoint("TOPLEFT", 51, -14)
		self.Title:SetPoint("RIGHT", -20, 0)
		self.Description:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -4)
	end
end

function StoreToastMixin:OnMouseUp(button)
	if self:IsEnabled() == 1 then
		self.Icon:SetPoint("LEFT", 8, 0)
		self.IconHighlight:SetPoint("LEFT", 8, 0)
		self.Title:SetPoint("TOPLEFT", 52, -12)
		self.Title:SetPoint("RIGHT", -20, 0)
		self.Description:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -4)
	end
end

local CAT_PICK_SIDE = {
	BOTTOMLEFT = 0,
	BOTTOMRIGHT = 1,
	TOPLEFT = 2,
	TOPRIGHT = 3,
	NUM_SIDES = 4,
}

local CAT_SIDE_MULT = {
	{
		[CAT_PICK_SIDE.BOTTOMLEFT]	= {1, 1},
		[CAT_PICK_SIDE.BOTTOMRIGHT]	= {-1, 1},
		[CAT_PICK_SIDE.TOPLEFT]		= {1, -1},
		[CAT_PICK_SIDE.TOPRIGHT]	= {-1, -1},
	}
}

local CAT_SIDE_SEQUENCE = {
	{
		{{130, -20}, {150, 0}},
		{{150, -200}, {75, -40}},
		{{75, -200}},
	},
}

StoreFrustratedCatAnimationMixin = {}

function StoreFrustratedCatAnimationMixin:OnLoad()
	self.Cat = self.Scroll.Cat
	self.Cat.Texture:SetAtlas("PKBT-Store-Artwork-Cat-Surprise", true)
	self.Cat:SetSize(self.Cat.Texture:GetSize())

	self.PathAnims = {
		self.Cat.PickAnim.ResetPath,
		self.Cat.PickAnim.InPath,
		self.Cat.PickAnim.RepickPath,
		self.Cat.PickAnim.OutPath,
	}

	self.pickSide = 0
end

function StoreFrustratedCatAnimationMixin:OnShow()
	local _, _, width = self:GetRect()
	self.NoItemText:SetWidth(width * 0.8)

	self:SetPickSide(CAT_PICK_SIDE.BOTTOMLEFT)
end

function StoreFrustratedCatAnimationMixin:OnHide()
	if self.Cat.PickAnim:IsPlaying() then
		self.Cat.PickAnim:Stop()
	end
end

function StoreFrustratedCatAnimationMixin:SetPickSide(pickSide)
	self.Cat.Texture:SetAtlas("PKBT-Store-Artwork-Cat-Surprise")
	self.Cat:ClearAllPoints()

	local scale = self.Cat:GetEffectiveScale()
	local sequenceIndex = math.random(1, #CAT_SIDE_SEQUENCE)
	local sequence = CAT_SIDE_SEQUENCE[sequenceIndex]

	local multX, multY = unpack(CAT_SIDE_MULT[sequenceIndex][pickSide], 1, 2)
	local baseOffsetX = -(self.Cat:GetWidth())
	local baseOffsetY = 0

	if pickSide == CAT_PICK_SIDE.BOTTOMLEFT then
		self.Cat:SetPoint("BOTTOMLEFT", 0, 0)
		self.Cat.Texture:SetSubTexCoord(0, 1, 0, 1)
	elseif pickSide == CAT_PICK_SIDE.BOTTOMRIGHT then
		self.Cat:SetPoint("BOTTOMRIGHT", 0, 0)
		self.Cat.Texture:SetSubTexCoord(1, 0, 0, 1)
	elseif pickSide == CAT_PICK_SIDE.TOPLEFT then
		self.Cat:SetPoint("TOPLEFT", 0, 0)
		self.Cat.Texture:SetSubTexCoord(0, 1, 1, 0)
	elseif pickSide == CAT_PICK_SIDE.TOPRIGHT then
		self.Cat:SetPoint("TOPRIGHT", 0, 0)
		self.Cat.Texture:SetSubTexCoord(1, 0, 1, 0)
	end

	for index, pathAnim in ipairs(self.PathAnims) do
		if index == 1 then
			self:SetControlPointCurve({{baseOffsetX * scale, baseOffsetY * scale}}, multX, multY, pathAnim:GetControlPoints())
		else
			local curve = sequence[index - 1]
			self:SetControlPointCurve(curve, multX, multY, pathAnim:GetControlPoints())
		end
	end

	self.Cat.PickAnim:Play()
	self.Cat:Show()
end

function StoreFrustratedCatAnimationMixin:SetControlPointCurve(curve, multX, multY, ...)
	for index = 1, select("#", ...) do
		local controlPoint = select(index, ...)
		local curveOffsetX, curveOffsetY = unpack(curve[index], 1, 2)
		controlPoint:SetOffset(curveOffsetX * multX, curveOffsetY * multY)
	end
end

function StoreFrustratedCatAnimationMixin:OnPickDone()
	self.Cat:Hide()
	self.Cat:SetAlpha(0)

	local numSides = CAT_PICK_SIDE.NUM_SIDES
	local rnMax = numSides * 10
	local rn = math.random(0, rnMax) % numSides
	if numSides > 1 and rn == self.pickSide then
		while rn == self.pickSide do
			rn = math.random(0, rnMax) % numSides
		end
	end

	self.pickSide = rn
	self:SetPickSide(self.pickSide)
end