local min, max = math.min, math.max
local strformat = string.format

local UnitFactionGroup = UnitFactionGroup
local PlaySound = PlaySound

local C_StorePublic = C_StorePublic
local C_StoreSecure = C_StoreSecure
local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient

local OFFER_SCROLL_TIME = 8
local MAX_ALERT_FRAMES = 1
local TRANSMOG_REROLL_BUTTON_ON_MAIN_PAGE = false

local ALERT_QUEUE = {}

local POPUP = {
	REF_OWNER = "MainMenuBar",
	REF_OWNER_KEY = "Store_TutorialPoint",

	CURRENT_NPE_ID = nil,
	CURRENT_ID = nil,
	CURRENT_PRIORITY = nil,
	QUEUE = nil,
	BLOCK_RELEASE_NPE_ID = nil,
	OWNER_FREED_CALLBACK = nil,
}
POPUP.Release = function(force)
	local hasNPE = POPUP.CURRENT_NPE_ID ~= nil

	if hasNPE then
		NPE_TutorialPointerFrame:Hide(POPUP.CURRENT_NPE_ID)
	end

	POPUP.CURRENT_NPE_ID = nil
	POPUP.CURRENT_ID = nil
	POPUP.CURRENT_PRIORITY = nil

	if hasNPE or force then
		C_TutorialManager.ClearOwner(POPUP.REF_OWNER, POPUP.REF_OWNER_KEY)
	end
end
POPUP.OnClose = function()
	POPUP.Release()
end
POPUP.OnRelease = function(npeID)
	if POPUP.BLOCK_RELEASE_NPE_ID and POPUP.BLOCK_RELEASE_NPE_ID ~= npeID then
		POPUP.Release()
	end
end

Enum.StoreWidget = Enum.CreateMirror({
	ProductPurchase		= 0,
	Referral			= 1,
	PremiumPurchase		= 2,
	Agreement			= 3,
})

Enum.StoreViewMode = Enum.CreateMirror({
	ItemList	= 1,
	Refund		= 2,
})

local CATEGORY_OVERVIEW = {
	[Enum.Store.Category.Equipment] = true,
	[Enum.Store.Category.Subscriptions] = true,
	[Enum.Store.Category.Transmogrification] = true,
}

local CATEGORY_NO_SUBMENU = {
	[Enum.Store.Category.Equipment] = true,
	[Enum.Store.Category.Subscriptions] = true,
	[Enum.Store.Category.Transmogrification] = true,
}

local SUBSCRIPTION_TRACKED_PRIORITY = {
	Enum.Store.SubscriptionType.Julia,
	Enum.Store.SubscriptionType.StrategicPack,
	Enum.Store.SubscriptionType.AllInclusive,
	Enum.Store.SubscriptionType.Transmogrify,
	Enum.Store.SubscriptionType.Mounts,
	Enum.Store.SubscriptionType.Pets,
}

StoreMixin = CreateFromMixins(PortraitFrameMixin)

function StoreMixin:OnLoad()
	if self:GetName() ~= "StoreFrame" and StoreFrame == nil then
		StoreFrame = self
	end

	self.maxScale = 1 --0.75
	self.pages = {}
	self.dialogWidgets = {}
	self.viewWidgets = {}
	self.categoryButtons = {}

	self.selectedCategory = 0
	self.selectedSubCategory = 0

	self:GetTitleContainer():Hide()

	self.navPanelAtlas = C_Texture.GetAtlasInfo("PKBT-Store-Background-NavPanel")
	self:GetNavPanel().Background:SetAtlas("PKBT-Store-Background-NavPanel")

	self.DressUp.onClose = function(this)
		self:ToggleDressUp(false)
	end

	local premiumPanel = self:GetPremiumPanel()
	premiumPanel.Background:SetTexture(self.navPanelAtlas.filename)
	premiumPanel.Background:SetTexCoord(
		self.navPanelAtlas.leftTexCoord,
		self.navPanelAtlas.rightTexCoord,
		self.navPanelAtlas.topTexCoord,
		self.navPanelAtlas.topTexCoord + (self.navPanelAtlas.bottomTexCoord - self.navPanelAtlas.topTexCoord) * (premiumPanel:GetHeight() / self.navPanelAtlas.height)
	)

	Mixin(premiumPanel.Purchase, PKBT_OwnerMixin)
	premiumPanel.Purchase:SetOwner(self)
	premiumPanel.Purchase:AddTextureAtlas("PKBT-Icon-Crown", true, 60, 60, -16, 0)
	premiumPanel.Purchase:AddText(STORE_PURCHASE_PREMIUM, -10, 0, "PKBT_Font_18")
	premiumPanel.Purchase:SetPadding(28)

	self.dialogFramePool = CreateFramePool("Frame", self, "StoreGenericDialogTemplate")
	self.purchaseAlertPool = CreateFramePool("Button", self, "StorePurchaseAlertTemplate", nil, nil, function(this)
		this:SetParent(UIParent)
		this:SetFrameStrata("FULLSCREEN_DIALOG")
	end)

	C_StoreSecure.SetStoreFrame(self)

	self:RegisterCustomEvent("SERVICE_DATA_UPDATE")
	self:RegisterCustomEvent("STORE_AVAILABILITY_CHANGED")
	self:RegisterCustomEvent("CUSTOM_CHALLENGE_ACTIVATED")
	self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")

	self:RegisterCustomEvent("STORE_RELOADED")
	self:RegisterCustomEvent("STORE_ERROR")
	self:RegisterCustomEvent("STORE_BALANCE_UPDATE")
	self:RegisterCustomEvent("STORE_PREMIUM_UPDATE")
	self:RegisterCustomEvent("STORE_PREMIUM_PURCHASED")
	self:RegisterCustomEvent("STORE_CATEGORY_SELECTED")
	self:RegisterCustomEvent("STORE_CATEGORY_INFO_UPDATE")
	self:RegisterCustomEvent("STORE_CATEGORY_NEW_PRODUCTS")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_UPDATE")
	self:RegisterCustomEvent("STORE_RANDOM_ITEM_POLL_UPDATE")
	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_POPUP_SMALL_SHOW")
	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_POPUP_SMALL_HIDE")
	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_ALERT_LAST_HOUR")
	self:RegisterCustomEvent("STORE_PURCHASE_ERROR")
	self:RegisterCustomEvent("STORE_PURCHASE_COMPLETE")
	self:RegisterCustomEvent("STORE_SERVICE_DIALOG")
	self:RegisterCustomEvent("STORE_NEW_ITEMS_AVAILABLE")

	C_FactionManager:RegisterFactionOverrideCallback(function()
		self:UpdatePortraitFallback()
	end, true)

	if IsInterfaceDevClient() then
		OFFER_SCROLL_TIME = _G["DEV_STORE_OFFER_SCROLL_TIME"] or OFFER_SCROLL_TIME

		for categoryIndex in pairs(CATEGORY_NO_SUBMENU) do
			CATEGORY_NO_SUBMENU[categoryIndex] = false
		end
	end
end

function StoreMixin:OnShow()
	if not C_StorePublic.IsEnabled() then
		self:Hide()
		return
	end

	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")

	self:RequestData()

	self:HidePopup()
	self:UpdatePortrait()
	self:UpdateAccountInfo()

	self:UpdatePremium()
	self:UpdateBalance()
	self:UpdateVote()
	self:UpdateReferral()
	self:UpdateLoyality()

	if self.closeTimestamp and time() - self.closeTimestamp > 15 then
		C_StoreSecure.SetSelectedCategory(Enum.Store.Category.Main)
	else
		local categoryIndex, subCategoryIndex = C_StoreSecure.GetSelectedCategory()
		self:UpdateCategoryButtons(categoryIndex, subCategoryIndex)
		self:UpdateCategoryContent(categoryIndex, subCategoryIndex)
	end

	self:UpdateSubscriptionTracker()

	PlaySound(SOUNDKIT.UI_IG_STORE_WINDOW_OPEN_BUTTON)

	self:StopMicroButtonPulse()
	UpdateMicroButtons()

	EventRegistry:TriggerEvent("StoreFrame.OnShow")
end

function StoreMixin:OnHide()
	PlaySound(SOUNDKIT.UI_IG_STORE_WINDOW_CLOSE_BUTTON)

	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")

	self:HideLinkDialog()
	self:HideErrors(self)
	self:HideDialogs(self)

	local categoryIndex, subCategoryIndex = C_StoreSecure.GetSelectedCategory()
	if categoryIndex ~= Enum.Store.Category.Main then
		self.closeTimestamp = time()
	else
		self.closeTimestamp = nil
	end

	self.transmogInfoRequested = nil

	self:UpdateMicroButtonPulse()
	UpdateMicroButtons()

	EventRegistry:TriggerEvent("StoreFrame.OnHide")
end

function StoreMixin:OnEvent(event, ...)
	if event == "STORE_ERROR" or event == "STORE_PURCHASE_ERROR" then
		local errorText, debugInfo = ...
		self:ShowError(nil, errorText):SetDebugInfo(debugInfo)
	elseif event == "STORE_NEW_ITEMS_AVAILABLE" then
		self:ShowPopup(10, "STORE_NEW_ITEMS_AVAILABLE", STORE_NEW_ITEMS_AVAILABLE_TEXT, "DOWN", StoreMicroButton, 0, -5, nil, nil, nil, 255, POPUP.OnClose, POPUP.OnRelease)
	elseif event == "STORE_BALANCE_UPDATE" then
		self:UpdateBalance()
		self:UpdateVote()
		self:UpdateReferral()
		self:UpdateLoyality()
	elseif event == "STORE_PREMIUM_UPDATE" then
		self:UpdatePremium()
	elseif event == "STORE_PREMIUM_PURCHASED" then
		self:AddPurchaseAlert("Interface/Icons/VIP", STORE_PREMIUM_STATUS, STORE_DELIVERED_PREMIUM)
	elseif event == "STORE_CATEGORY_SELECTED" then
		local categoryIndex, subCategoryIndex = ...
		self:ToggleDressUp(false)
		self:UpdateCategoryButtons(categoryIndex, subCategoryIndex)
		self:UpdateCategoryContent(categoryIndex, subCategoryIndex)
		self:UpdateSubscriptionTracker()
		C_StoreSecure.SetCategoryRenewSeen(categoryIndex)

		if categoryIndex == Enum.Store.Category.Transmogrification then
			if not self.transmogInfoRequested then
				self.transmogInfoRequested = true
				RequestInventoryTransmogInfo(true)
			end
		end
	elseif event == "STORE_CATEGORY_INFO_UPDATE" then
		local categoryIndex, subCategoryIndex = ...
		if categoryIndex then
			self:UpdateCategoryButtonInfo(categoryIndex, subCategoryIndex)
		else
			self:UpdateCategoryButtons()
		end
	elseif event == "STORE_PRODUCT_LIST_UPDATE" then
		local categoryIndex, subCategoryIndex = ...
		local selectedCategoryIndex, selectedSubCategoryIndex = C_StoreSecure.GetSelectedCategory()

		if categoryIndex == selectedCategoryIndex
		and subCategoryIndex == selectedSubCategoryIndex
		then
			self:UpdateCategoryContent(categoryIndex, subCategoryIndex, true)
		end
	elseif event == "STORE_SPECIAL_OFFER_POPUP_SMALL_SHOW" then
		local newOfferPopupIndex = ...
		self:ShowOfferPopup(newOfferPopupIndex)
	elseif event == "STORE_SPECIAL_OFFER_POPUP_SMALL_HIDE" then
		local offerID = ...
		self:HideOfferPopup(offerID)
	elseif event == "STORE_SPECIAL_OFFER_ALERT_LAST_HOUR" then
		local offerIndex = ...
		self:OnOfferAlertLastHour(offerIndex)
	elseif event == "STORE_PURCHASE_COMPLETE" then
		local productID, itemID, wasGifted = ...
		if itemID then
			local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
			self:AddPurchaseAlert(texture, name, wasGifted and STORE_DELIVERED_PURCHASE_GIFT or STORE_DELIVERED_PURCHASE_SELF)
		end
	elseif event == "STORE_SERVICE_DIALOG" then
		local serviceName = ...
		StaticPopup_Show("STORE_SERVICE_DIALOG", serviceName)
	elseif event == "STORE_CATEGORY_NEW_PRODUCTS" then
		local categoryIndex = ...
		if categoryIndex == Enum.Store.Category.Collections then
			self:UpdateMicroButtonPulse()
		end
	elseif event == "STORE_RANDOM_ITEM_POLL_UPDATE" then
		local changed = ...
		if changed then
			self:UpdateMicroButtonPulse()
		end
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local unit = ...
		if self:IsShown() and UnitIsUnit(unit, "player") then
			self:UpdatePortrait()
		end
	elseif event == "STORE_AVAILABILITY_CHANGED"
	or event == "CUSTOM_CHALLENGE_ACTIVATED"
	or event == "CUSTOM_CHALLENGE_DEACTIVATED"
	then
		if C_StorePublic.IsEnabled() then
			self:UpdateMicroButtonPulse()
			self:ProcessPopupQueue()
		else
			self:StopMicroButtonPulse()
		end
	elseif event == "SERVICE_DATA_UPDATE" then
		if not C_StorePublic.IsEnabled() then
			self:StopMicroButtonPulse()
		end
	elseif event == "STORE_RELOADED" then
		self.dataReloaded = true
		if self:IsVisible() then
			self:RequestData()
		end
	end
end

function StoreMixin:RequestData()
	if not self.dataReloaded or not self:IsVisible() then
		return
	end

	self.dataReloaded = nil

	C_StoreSecure.RequestNewCategoryItems()
	C_StoreSecure.RequestNextSpecialOfferTime()
	C_StoreSecure.RequestNextTransmogOfferTime()
	C_StoreSecure.RequestSubscriptions()
end

function StoreMixin:UpdateMicroButtonPulse()
	if C_StorePublic.IsEnabled() and C_StoreSecure.IsAnyCategoryRenewed() then
		if StoreMicroButton:IsEnabled() == 1 and not tContains(PULSEBUTTONS, StoreMicroButton) then
			SetButtonPulse(StoreMicroButton, 60, 0.50)
		end
		if GameMenuButtonStore:IsEnabled() == 1 and not tContains(PULSEBUTTONS, GameMenuButtonStore) then
			SetButtonPulse(GameMenuButtonStore, 60, 0.50)
		end
	else
		self:StopMicroButtonPulse()
	end
end

function StoreMixin:StopMicroButtonPulse()
	ButtonPulse_StopPulse(StoreMicroButton)
	ButtonPulse_StopPulse(GameMenuButtonStore)
end

function StoreMixin:HideContentLayers()
	self.Content.NineSliceInset:Hide()
	self.Content.Background:Hide()
	self.Content.ShadowTop:Hide()
	self.Content.ShadowBottom:Hide()
	self.Content.ShadowLeft:Hide()
	self.Content.ShadowRight:Hide()
end

function StoreMixin:ShowContentLayers()
	self.Content.NineSliceInset:Show()
	self.Content.Background:Show()
	self.Content.ShadowTop:Show()
	self.Content.ShadowBottom:Show()
	self.Content.ShadowLeft:Show()
	self.Content.ShadowRight:Show()
end

function StoreMixin:UpdatePortrait()
	SetParentFrameLevel(self:GetAccountPanel().PortraitContainer, 25)
	self:SetPortraitToUnit("player")
end

function StoreMixin:UpdatePortraitFallback()
	local portrait = self:GetAccountPanel().PortraitContainer.PortraitFallback

	local _, race = UnitRace("player")
	local sex = UnitSex("player") or 3
	local faction = UnitFactionGroup("player")

	local atlas = string.format("RACE_ICON_ROUND_%s_%s_%s", string.upper(race), E_SEX[sex], string.upper(faction))
	if C_Texture.GetAtlasInfo(atlas) then
		portrait:SetAtlas(atlas)
	else
		portrait:SetTexture(nil)
	end
end

function StoreMixin:GetPortrait()
	return self:GetAccountPanel().PortraitContainer.Portrait
end

function StoreMixin:GetAccountPanel()
	return self.TopPanel.AccountPanel
end

function StoreMixin:GetBalancePanel()
	return self.TopPanel.BalancePanel
end

function StoreMixin:GetVotePanel()
	return self.TopPanel.VotePanel
end

function StoreMixin:GetReferralPanel()
	return self.TopPanel.ReferralPanel
end

function StoreMixin:GetLoyalityPanel()
	return self.TopPanel.LoyalityPanel
end

function StoreMixin:GetLeftPanel()
	return self.LeftPanel
end

function StoreMixin:GetNavPanel()
	return self.LeftPanel.NavPanel
end

function StoreMixin:GetPremiumPanel()
	return self.LeftPanel.PremiumPanel
end

function StoreMixin:ShowProductDressUp(parent, productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
	local success = self.DressUp:SetProduct(productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
	if success then
		self:ToggleDressUp(true, parent)
	end
end

function StoreMixin:ShowItemDressUp(parent, itemLink, allowToHide, allowEquipmentToggle, allowPortraitCamera)
	local success = self.DressUp:SetItem(itemLink, allowToHide, allowEquipmentToggle, allowPortraitCamera)
	if success then
		self:ToggleDressUp(true, parent)
	end
end

function StoreMixin:ToggleDressUp(state, parent)
	if state then
		self.DressUp:SetParent(parent)
		self.DressUp:SetPoint("TOPRIGHT", 0, 0)
		self.DressUp:SetPoint("BOTTOMRIGHT", 0, 0)
		self.DressUp:Show()
		SetParentFrameLevel(self.DressUp, 10)
	else
		self.DressUp:Hide()
	end
end

function StoreMixin:GetToastFrame()
	return StoreToastFrame
end

function StoreMixin:RegisterPageWidget(pageWidget)
	self.pages[pageWidget:GetID()] = pageWidget
end

function StoreMixin:GetPage(id)
	return self.pages[id]
end

function StoreMixin:GetSelectedPage()
	return self.pages[self.selectedCategory]
end

function StoreMixin:IsDialogShownWithParent(dialog, parent)
	return dialog:IsShown() and (not parent or dialog:GetParent() == parent)
end

function StoreMixin:HasShownDialogs(parent)
	for _, dialogWidget in pairs(self.dialogWidgets) do
		if self:IsDialogShownWithParent(dialogWidget, parent) then
			return true
		end
	end
	return false
end

function StoreMixin:HasShownLinkDialog(parent)
	return self:IsDialogShownWithParent(self.LinkDialog, parent)
end

function StoreMixin:GetBestDialogParent(parent, allowWorldFrame)
	if parent then
		return parent
	elseif self:IsShown() then
		return self
	elseif allowWorldFrame and not UIParent:IsShown() then
		return WorldFrame
	else
		return UIParent
	end
end

function StoreMixin:ShowProductPurchaseDialog(productID)
	self:ShowDialogWidget(Enum.StoreWidget.ProductPurchase, nil, function(dialog)
		local success = dialog:SetProductID(productID)
		return success
	end)
end

function StoreMixin:RegisterDialogWidget(dialogWidget, widgetType)
	assert(Enum.StoreWidget[widgetType] ~= nil)
	self.dialogWidgets[widgetType] = dialogWidget
	dialogWidget:SetParent(self)
end

function StoreMixin:ShowDialogWidget(widgetType, parent, preShowCallback)
	local widget = self.dialogWidgets[widgetType]
	assert(widget ~= nil)

	if not parent then
		parent = self:GetBestDialogParent(parent)
	end

	FrameUtil.SetParentMaintainRenderLayering(widget, parent)

	if type(preShowCallback) == "function" then
		local success = preShowCallback(widget)
		if not success then
			return widget, false
		end
	end

	widget.OnCloseCallback = function()
		HideUIPanel(widget)
		if not self:HasShownDialogs(parent) then
			self:ToggleBlockFrame(false)
		end
	end

	widget:Show()

	if parent == self then
		self:ToggleBlockFrame(true)
	end

	return widget, true
end

function StoreMixin:HideDialogWidget(widgetType, parent)
	local widget = self.dialogWidgets[widgetType]
	assert(widget ~= nil)
	widget:Hide()

	if not self:HasShownDialogs(self) then
		self:ToggleBlockFrame(false)
	end
end

function StoreMixin:HideDialogs(parent)
	for _, dialogWidget in pairs(self.dialogWidgets) do
		dialogWidget:Hide()
	end
	if not self:HasShownDialogs(parent) and not self:HasShownLinkDialog(parent) then
		self:ToggleBlockFrame(false)
	end
end

function StoreMixin:ToggleBlockFrame(toggle)
	if toggle and not self:IsShown() then
		return
	end

	self.BlockFrame:SetShown(toggle)

	if toggle then
		SetParentFrameLevel(self.BlockFrame, 20)
	end
end

function StoreMixin:ShowLinkDialog(parent, title, text, url)
	local frame = self.LinkDialog

	if not parent then
		parent = self:GetBestDialogParent(parent)
	end

	FrameUtil.SetParentMaintainRenderLayering(frame, parent)
	frame:SetTitle(title)
	frame:SetText(text)
	frame:SetLink(url)
	frame:Show()

	if parent == self then
		self:ToggleBlockFrame(true)
	end

	frame:Raise()

	return frame
end

function StoreMixin:HideLinkDialog(parent)
	if self:HasShownLinkDialog(parent) then
		self.LinkDialog:Hide()
	end
	if not self:HasShownDialogs(self) then
		self:ToggleBlockFrame(false)
	end
end

function StoreMixin:ShowError(parent, text, title, styleIndex, actionButtonText, actionButtonHandler, cancelButtonText, cancelButtonHandler)
	local frame = self.dialogFramePool:GetNextActive() or self.dialogFramePool:Acquire()

	if not parent then
		parent = self:GetBestDialogParent(parent)
	end

	if not styleIndex then
		styleIndex = parent.dialogStyle or Enum.StoreDialogStyle.Wood
	end

	if not cancelButtonHandler then
		cancelButtonHandler = function()
			if not self:HasShownDialogs(parent) then
				self:ToggleBlockFrame(false)
			end
			return true
		end
	end

	frame:SetParent(parent)
	frame:SetFrameStrata("DIALOG")
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", 0, 0)
	frame:ShowGenericDialog(styleIndex, title, text, actionButtonText, cancelButtonText, actionButtonHandler, cancelButtonHandler)

	if parent == self then
		self:ToggleBlockFrame(true)
	end

	return frame
end

function StoreMixin:HideErrors(parent)
	if parent then
		for frame in self.dialogFramePool:EnumerateActive() do
			if frame:GetParent() == parent then
				self.dialogFramePool:Release(frame)
			end
		end
	else
		self.dialogFramePool:ReleaseAll()
	end

	if not self:HasShownDialogs(parent) then
		self:ToggleBlockFrame(false)
	end
end

function StoreMixin:RegisterViewMode(viewWidget, viewModeType)
	assert(Enum.StoreViewMode[viewModeType] ~= nil)
	self.viewWidgets[viewModeType] = viewWidget
	viewWidget:SetParent(self)
end

function StoreMixin:GetViewMode(viewModeType)
	local widget = self.viewWidgets[viewModeType]
	assert(widget ~= nil)
	return widget
end

function StoreMixin:SetActiveViewMode(viewModeType)
	assert(self.viewWidgets[viewModeType] ~= nil)
	self.activeViewWidget = viewModeType
	self:HideContentLayers()
end

function StoreMixin:RemoveActiveViewMode(viewModeType)
	assert(self.viewWidgets[viewModeType] ~= nil)
	self.activeViewWidget = nil
	self:ShowContentLayers()
end

function StoreMixin:GetActiveViewMode()
	return self.activeViewWidget
end

function StoreMixin:AddPurchaseAlert(icon, title, description)
	if not icon or not title then
		return
	end

	if self.purchaseAlertPool:GetNumActive() < MAX_ALERT_FRAMES and #ALERT_QUEUE == 0 then
		self:ShowPurchaseAlert(icon, title, description)
	else
		table.insert(ALERT_QUEUE, {icon, title, description})
	end
end

function StoreMixin:ProcessAlertQueue()
	if self.purchaseAlertPool:GetNumActive() < MAX_ALERT_FRAMES and #ALERT_QUEUE > 0 then
		local alertData = table.remove(ALERT_QUEUE, 1)
		self:ShowPurchaseAlert(unpack(alertData))
	end
end

function StoreMixin:ShowPurchaseAlert(icon, title, description)
	local alert = self.purchaseAlertPool:Acquire()

	if not self.alertOnHideCallback then
		self.alertOnHideCallback = function(this)
			self.purchaseAlertPool:Release(this)
			this.onHideCallback = nil
			self:ProcessAlertQueue()
		end
	end

	alert.onHideCallback = self.alertOnHideCallback

	alert:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 128)
	alert:SetAlertInfo(icon, title, description)
	alert:Show()
end

function StoreMixin:ShowToast(title, description, creatureID)
	local toast = self:GetToastFrame()
	toast.Title:SetText(title)
	toast.Description:SetText(description)
	toast:Show()

	if creatureID then
		toast.Model:Show()
		toast.Model:SetCreatureModel(creatureID, C_StorePublic.GetPreferredModelFacing())
	else
		toast.Model:Hide()
	end
end

function StoreMixin:UpdateAccountInfo()
	local panel = self:GetAccountPanel()
	local accountName = C_StoreSecure.GetAccountInfo()
	panel:SetUserName(accountName)
end

function StoreMixin:UpdateBalance()
	local panel = self:GetBalancePanel()
	local amount = C_StoreSecure.GetBalance(Enum.Store.CurrencyType.Bonus)
	panel:SetValue(amount)
end

function StoreMixin:UpdateVote()
	local panel = self:GetVotePanel()
	local amount = C_StoreSecure.GetBalance(Enum.Store.CurrencyType.Vote)
	panel:SetValue(amount)
end

function StoreMixin:UpdateReferral()
	local panel = self:GetReferralPanel()
	local currentValue, minValue, maxValue = C_StoreSecure.GetReferralInfo()

	panel:SetStatusBarMinMax(minValue, maxValue)
	panel:SetStatusBarValue(currentValue)
end

function StoreMixin:UpdateLoyality()
	local panel = self:GetLoyalityPanel()
	local level, currentValue, minValue, maxValue = C_StoreSecure.GetLoyalityInfo()

	panel:SetStatusBarMinMax(minValue, maxValue)
	panel:SetStatusBarValue(currentValue)
	panel:SetValue(level)
end

function StoreMixin:UpdatePremium()
	local accountPanel = self:GetAccountPanel()
	accountPanel:SetPremiumTimeLeft(C_StoreSecure.GetPremiumTimeLeft())

	local navPanel = self:GetNavPanel()
	local premiumPanel = self:GetPremiumPanel()

	if C_StoreSecure.IsPremiumActive() then
		navPanel.Background:SetTexCoord(
			self.navPanelAtlas.leftTexCoord,
			self.navPanelAtlas.rightTexCoord,
			self.navPanelAtlas.topTexCoord,
			self.navPanelAtlas.bottomTexCoord
		)

		navPanel:SetPoint("TOPLEFT", 0, 0)
		premiumPanel:Hide()
	else
		navPanel.Background:SetTexCoord(
			self.navPanelAtlas.leftTexCoord,
			self.navPanelAtlas.rightTexCoord,
			self.navPanelAtlas.topTexCoord + (self.navPanelAtlas.bottomTexCoord - self.navPanelAtlas.topTexCoord) * ((premiumPanel:GetHeight() + 4) / self.navPanelAtlas.height),
			self.navPanelAtlas.bottomTexCoord
		)

		navPanel:SetPoint("TOPLEFT", premiumPanel, "BOTTOMLEFT", 0, -4)
		premiumPanel:Show()
	end
end

function StoreMixin:UpdateSubscriptionTracker()
	if C_StoreSecure.GetSelectedCategory() == Enum.Store.Category.Main then
		self:GetLeftPanel().SubscriptionTracker:UpdateSubscription()
	else
		self:GetLeftPanel().SubscriptionTracker:Hide()
	end
end

function StoreMixin:UpdateCategoryButtonInfo(categoryIndex, subCategoryIndex)
	if self.categoryButtons[categoryIndex] then
		self.categoryButtons[categoryIndex]:UpdateInfo()
	end
end

function StoreMixin:UpdateCategoryButtons(selectedCategoryIndex, selectedSubCategoryIndex)
	local OFFSET_FIRST = 15
	local PADDING = 10

	if not selectedCategoryIndex then
		selectedCategoryIndex, selectedSubCategoryIndex = C_StoreSecure.GetSelectedCategory()
	end

	local numCategories = C_StoreSecure.GetNumCategories()

	for index = 1, numCategories do
		local button = self.categoryButtons[index]
		if not button then
			button = CreateFrame("CheckButton", strformat("$parentCategoryButton%u", index), self:GetNavPanel(), "StoreCategoryButtonTemplate")
			button:SetOwner(self)
			button:SetID(index)
			button:SetBlockedUncheck(true)
			button:SetLockCheckedTextOffset(true)

			button:SetPoint("LEFT", PADDING, 0)
			button:SetPoint("RIGHT", -PADDING, 0)

			if index == 1 then
				button:SetPoint("TOP", 0, -OFFSET_FIRST)
			else
				button:SetPoint("TOP", self.categoryButtons[index - 1].SubCategoryMenu, "BOTTOM", 0, -PADDING)
			end

			self.categoryButtons[index] = button
		end

		button:SetChecked(index == selectedCategoryIndex)
		button:UpdateInfo()
		button:Show()
		button.SubCategoryMenu:UpdateSubCategories(selectedCategoryIndex, selectedSubCategoryIndex)
	end

	for index = #self.categoryButtons + 1, numCategories do
		self.categoryButtons[index]:Hide()
	end
end

function StoreMixin:UpdateSpecialOffers()
	self:GetPage(Enum.Store.Category.Main):UpdateSpecialOffers()
end

function StoreMixin:UpdateRecommendations()
	self:GetPage(Enum.Store.Category.Main):UpdateRecommendations()
end

function StoreMixin:UpdateCategoryContent(categoryIndex, subCategoryIndex, cacheReceived)
	if self.pages[self.selectedCategory] then
		self.pages[self.selectedCategory]:Hide()
	end

	self.selectedCategory = categoryIndex
	self.selectedSubCategory = subCategoryIndex
	self.pages[categoryIndex]:ShowSubCategoryPage(subCategoryIndex)
end

function StoreMixin:OnOfferAlertLastHour(offerIndex)
	local offerID, title = C_StoreSecure.GetSpecialOfferInfo(offerIndex)

	if StoreMicroButton:IsVisible() and StoreMicroButton:IsShown() then
		self:ShowPopup(100, "OFFER_ALERT_LAST_HOUR", string.format(STORE_SPECIAL_OFFER_POPUP_LESS_THAN_HOUR, title), "DOWN", StoreMicroButton, 0, -5, nil, nil, nil, nil, POPUP.OnClose, POPUP.OnRelease)
	else
		self:ShowToast(STPRE_TOAST_SPECIAL_OFFER_END_TITLE, title)
	end
end

function StoreMixin:ShowOfferPopup(offerPopupIndex)
	self:HidePopup()

	local offerID, text, modelInfo = C_StoreSecure.GetOfferPopupInfo(offerPopupIndex)

	if StoreMicroButton:IsVisible() and StoreMicroButton:IsEnabled() == 1 then
		local popupID = string.format("OfferPopup%i", offerID)
		if modelInfo then
			self:ShowPopup(90, popupID, text, "DOWN", StoreMicroButton, 0, -5, nil, nil, modelInfo, nil, POPUP.OnClose, POPUP.OnRelease)
		else
			self:ShowPopup(90, popupID, text, "DOWN", StoreMicroButton, 0, -5, nil, nil, nil, nil, POPUP.OnClose, POPUP.OnRelease)
		end
	else
		local creatureID = modelInfo and modelInfo[1]
		self:ShowToast(STORE_TOAST_SPECIAL_OFFER_TITLE, STORE_TOAST_SPECIAL_OFFER_BODY, creatureID)
	end
end

function StoreMixin:HideOfferPopup(offerID)
	local popupID = string.format("OfferPopup%i", offerID)
	self:HidePopup(popupID)
end

function StoreMixin:ShowPopup(priority, id, ...)
	if C_StorePublic.IsEnabled() then
		if not self:IsShown() and (not POPUP.CURRENT_NPE_ID or POPUP.CURRENT_PRIORITY < priority) then
			local isPriorityOverride = POPUP.CURRENT_NPE_ID and POPUP.CURRENT_PRIORITY < priority
			if C_TutorialManager.IsOwnerEmpty(POPUP.REF_OWNER) or isPriorityOverride then
				if isPriorityOverride then
					POPUP.BLOCK_RELEASE_NPE_ID = POPUP.CURRENT_NPE_ID
					NPE_TutorialPointerFrame:Hide(POPUP.CURRENT_NPE_ID)
					POPUP.BLOCK_RELEASE_NPE_ID = nil
				end

				POPUP.CURRENT_NPE_ID = NPE_TutorialPointerFrame:Show(...)
				if POPUP.CURRENT_NPE_ID and POPUP.CURRENT_NPE_ID ~= 0 then
					POPUP.CURRENT_PRIORITY = priority
					POPUP.CURRENT_ID = id
					C_TutorialManager.MarkOwnerUsed(POPUP.REF_OWNER, POPUP.REF_OWNER_KEY)
				else
					POPUP.CURRENT_PRIORITY = nil
					POPUP.CURRENT_ID = nil
					POPUP.CURRENT_NPE_ID = nil
				end
			else
				if POPUP.OWNER_FREED_CALLBACK then
					EventRegistry:UnregisterCallback("TutorialManager.OwnerFreed", self)
				end
				POPUP.OWNER_FREED_CALLBACK = true

				local args = {...}
				EventRegistry:RegisterCallback("TutorialManager.OwnerFreed", function(this, owner)
					if owner == POPUP.REF_OWNER then
						EventRegistry:UnregisterCallback("TutorialManager.OwnerFreed", this)
						POPUP.OWNER_FREED_CALLBACK = nil
						self:ShowPopup(priority, id, unpack(args))
					end
				end, self)
			end
		end
	else
		if not POPUP.QUEUE or POPUP.QUEUE.priority < priority then
			POPUP.QUEUE = {priority = priority, id = id, ...}
		end
	end
end

function StoreMixin:HidePopup(id)
	if id then
		if POPUP.QUEUE and POPUP.QUEUE.id == id then
			POPUP.QUEUE = nil
			return
		end

		if POPUP.CURRENT_ID and POPUP.CURRENT_ID ~= id then
			return
		end
	end

	POPUP.QUEUE = nil

	if POPUP.OWNER_FREED_CALLBACK then
		EventRegistry:UnregisterCallback("TutorialManager.OwnerFreed", self)
		POPUP.OWNER_FREED_CALLBACK = nil
	end

	POPUP.Release()
end

function StoreMixin:ProcessPopupQueue()
	if C_StorePublic.IsEnabled() and POPUP.QUEUE then
		self:ShowPopup(999, POPUP.QUEUE.id, unpack(POPUP.QUEUE))
		POPUP.QUEUE = nil
	end
end

function StoreMixin:OnPremiumPurchaseClick(button)
	self:ShowDialogWidget(Enum.StoreWidget.PremiumPurchase)
end

function StoreMixin:ShowProductCategory(productID, forcedCategoryIndex, forcedSubCategoryIndex)
	local product = C_StoreSecure.GetProductInfo(productID)
	if not product then
		if type(forcedCategoryIndex) == "number" then
			ShowUIPanel(self)
			C_StoreSecure.SetSelectedCategory(forcedCategoryIndex, forcedSubCategoryIndex)
		end
		return
	end

	ShowUIPanel(self)

	C_StoreSecure.SetSelectedCategory(forcedCategoryIndex or product.categoryID, forcedSubCategoryIndex or (product.subCategoryID ~= 0 and product.subCategoryID or nil))

	if product.categoryID ~= Enum.Store.Category.Subscriptions then
		self:ShowProductPurchaseDialog(productID)
		PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
	end
end

function StoreMixin:ProcessHyperlink(link)
	local categoryIndex, subCategoryIndex, productID = C_StoreSecure.GetProductHyperlinkInfo(link)
	if not categoryIndex then
		return
	end

	ShowUIPanel(self)

	C_StoreSecure.SetSelectedCategory(categoryIndex, subCategoryIndex ~= 0 and subCategoryIndex or nil)

	if productID and categoryIndex ~= Enum.Store.Category.Subscriptions then
		self:ShowProductPurchaseDialog(productID)
		PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
	end
end

StoreContentBackdropMixin = {}

function StoreContentBackdropMixin:OnLoad()
	self.Background:SetAtlas("PKBT-Tile-Obsidian-256", true)
	self.ShadowTop:SetAtlas("PKBT-Background-Shadow-Small-Top", true)
	self.ShadowBottom:SetAtlas("PKBT-Background-Shadow-Small-Bottom", true)
	self.ShadowLeft:SetAtlas("PKBT-Background-Shadow-Small-Left", true)
	self.ShadowRight:SetAtlas("PKBT-Background-Shadow-Small-Right", true)
end

StoreSubViewMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreSubViewMixin:RegisterViewMode(viewModeType)
	self:SetID(viewModeType)
	self:SetOwner(C_StoreSecure.GetStoreFrame())
	self:GetOwner():RegisterViewMode(self, viewModeType)
end

function StoreSubViewMixin:SetParentPage(page, dontShow)
	self:SetParent(page)
	if not dontShow then
		self:Show()
	end
end

function StoreSubViewMixin:OnShow()
	local owner = self:GetOwner()
	if owner then
		owner:SetActiveViewMode(self:GetID())
	end
	SetParentFrameLevel(self, 5)
end

function StoreSubViewMixin:OnHide()
	self:Hide()
	local owner = self:GetOwner()
	if owner then
		owner:RemoveActiveViewMode(self:GetID())
	end
end

StoreAccountPanelMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function StoreAccountPanelMixin:OnLoad()
	self.PortraitContainer.Ring:SetAtlas("PKBT-Portrait-Ring-Gold", true)
	self.InfoContainer.PremiumTimerIcon:SetAtlas("PKBT-Icon-Timer", true)

	self.InfoContainer.PremiumLabel:SetFormattedText("%s:", STORE_PREMIUM_LABEL)
end

function StoreAccountPanelMixin:SetUserName(name)
	self.InfoContainer.AccountName:SetText(name)
end

function StoreAccountPanelMixin:SetPremiumTimeLeft(timeLeft)
	self:SetTimeLeft(timeLeft)
end

function StoreAccountPanelMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.InfoContainer.PremiumTime:SetText(GetRemainingTime(timeLeft))
	else
		if C_StoreSecure.IsPremiumPermanent() then
			self.InfoContainer.PremiumTime:SetText(STORE_PREMIUM_PERMANENT)
		else
			self.InfoContainer.PremiumTime:SetText(STORE_PREMIUM_INACTIVE)
		end
	end
end

StoreAccountCurrencyPanelMixin = {}

function StoreAccountCurrencyPanelMixin:OnLoad()
	self.Divider:SetAtlas("PKBT-Store-MenuPanel-Divider", true)
	self.Icon:SetAtlas(self:GetAttribute("iconAtlas"))

	self.Button:AddTextureAtlas(self:GetAttribute("buttonIconAtlas"), false, 24, 24)
	self.Button:AddText(_G[self:GetAttribute("buttonText")])
	self.Button:SetPadding(15)

	self:Resize()
end

function StoreAccountCurrencyPanelMixin:SetValue(value)
	self.Value:SetText(tonumber(value) or 0)
	self:Resize()
end

function StoreAccountCurrencyPanelMixin:Resize()
	self:SetWidth(self.Icon:GetWidth() + 10 + self.Value:GetStringWidth() + 14 + self.Button:GetWidth())
end

function StoreAccountCurrencyPanelMixin:ActionClick()
end

StoreAccountBalancePanelMixin = CreateFromMixins(StoreAccountCurrencyPanelMixin)

function StoreAccountBalancePanelMixin:OnLoad()
	StoreAccountCurrencyPanelMixin.OnLoad(self)
	self.Divider:Show()
end

function StoreAccountBalancePanelMixin:ActionClick(button)
	C_StoreSecure.GetStoreFrame():ShowLinkDialog(nil, STORE_DONATE_DIALOG_TITLE, STORE_DONATE_DIALOG_TEXT, C_StoreSecure.GetDonationLink())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
end

StoreAccountVotePanelMixin = CreateFromMixins(StoreAccountCurrencyPanelMixin)

function StoreAccountVotePanelMixin:OnLoad()
	StoreAccountCurrencyPanelMixin.OnLoad(self)

	self.Divider:Show()
	self:SetID(Enum.Store.Category.Vote)
	self:RegisterCustomEvent("STORE_CATEGORY_SELECTED")
end

function StoreAccountVotePanelMixin:OnEvent(event, ...)
	if event == "STORE_CATEGORY_SELECTED" then
		local categoryIndex, subCategoryIndex = ...
		self.BrowseButton:SetChecked(categoryIndex == self:GetID() and subCategoryIndex == 0)
	end
end

function StoreAccountVotePanelMixin:Resize()
	self:SetWidth(self.Icon:GetWidth() + 10 + self.Value:GetStringWidth() + 14 + self.Button:GetWidth() + 3 + self.BrowseButton:GetWidth())
end

function StoreAccountVotePanelMixin:ActionClick()
	C_StoreSecure.GetStoreFrame():ShowLinkDialog(nil, STORE_VOTE_DIALOG_TITLE, STORE_VOTE_DIALOG_TEXT, C_StoreSecure.GetVoteLink())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
end

function StoreAccountVotePanelMixin:BrowseClick(button)
	self.BrowseButton:SetChecked(true)
	C_StoreSecure.GetStoreFrame():GetPage(self:GetID()):ShowSubCategoryPage(0)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

StoreAccountProgressPanelMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreAccountProgressPanelMixin:OnLoad()
	self.Divider:SetAtlas("PKBT-Store-MenuPanel-Divider", true)

	self.Label:SetPoint("BOTTOMLEFT", self.StatusBar, "TOPLEFT", -4, 7)
	self.Value:SetPoint("BOTTOMRIGHT", self.StatusBar, "TOPRIGHT", 4, 7)
	self.Label:SetFormattedText("%s:", _G[self:GetAttribute("label")])

	self:SetOwner(self:GetParent():GetParent())

	self:RegisterCustomEvent("STORE_CATEGORY_SELECTED")
end

function StoreAccountProgressPanelMixin:OnEvent(event, ...)
	if event == "STORE_CATEGORY_SELECTED" then
		local categoryIndex, subCategoryIndex = ...
		self.BrowseButton:SetChecked(categoryIndex == self:GetID() and subCategoryIndex == 0)
	end
end

function StoreAccountProgressPanelMixin:SetValue(value)
	if value then
		self.Value:SetText(value)
		self.Value:Show()
	else
		self.Value:Hide()
	end
end

function StoreAccountProgressPanelMixin:SetStatusBarValue(value)
	self.StatusBar:SetStatusBarValue(value)
end

function StoreAccountProgressPanelMixin:SetStatusBarMinMax(minValue, maxValue)
	self.StatusBar:SetStatusBarMinMax(minValue, maxValue)
end

function StoreAccountProgressPanelMixin:BrowseClick(button)
	self.BrowseButton:SetChecked(true)
	C_StoreSecure.GetStoreFrame():GetPage(self:GetID()):ShowSubCategoryPage(0)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function StoreAccountProgressPanelMixin:StatusBarEnter()
end

function StoreAccountProgressPanelMixin:StatusBarLeave()
end

StoreAccountLoyalityPanelMixin = CreateFromMixins(StoreAccountProgressPanelMixin)

function StoreAccountLoyalityPanelMixin:OnLoad()
	StoreAccountProgressPanelMixin.OnLoad(self)

	self.Divider:Show()
	self:SetID(Enum.Store.Category.Loyality)
end

StoreAccountReferralPanelMixin = CreateFromMixins(StoreAccountProgressPanelMixin)

function StoreAccountReferralPanelMixin:OnLoad()
	StoreAccountProgressPanelMixin.OnLoad(self)

	self.Divider:Show()
	self.AddButton:AddTextureAtlas("PKBT-Store-Icon-Referral-Add", true)
	self.AddButton:SetFixedWidth(45)
	self:SetID(Enum.Store.Category.Referral)
end

function StoreAccountReferralPanelMixin:OnAddClick(button)
	self:GetOwner():ShowDialogWidget(Enum.StoreWidget.Referral)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

StoreSubscriptionTrackerMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function StoreSubscriptionTrackerMixin:OnLoad()
	self.NextPackegeTimerIcon:SetAtlas("PKBT-Icon-Timer", true)

	self.itemButtons = {}

	self:RegisterCustomEvent("STORE_SUBSCRIPTION_LIST_UPDATE")
end

function StoreSubscriptionTrackerMixin:OnShow()
	SetParentFrameLevel(self, 2)
end

function StoreSubscriptionTrackerMixin:OnEvent(event, ...)
	if event == "STORE_SUBSCRIPTION_LIST_UPDATE" then
		if C_StoreSecure.GetStoreFrame():IsShown() then
			self:UpdateSubscription()
		end
	end
end

function StoreSubscriptionTrackerMixin:GetDesiredSubscriptionIndex()
	for index, subscriptionID in ipairs(SUBSCRIPTION_TRACKED_PRIORITY) do
		local subscriptionIndex = C_StoreSecure.GetSubscriptionIndexByID(subscriptionID)
		if subscriptionIndex then
			local state, upgradeTimeLeft, nextSupplyTimeLeft, remainingSupplyTimes = C_StoreSecure.GetSubscriptionState(subscriptionIndex)
			if nextSupplyTimeLeft > 0 then
				if state == Enum.Store.SubscriptionState.StandardActive
				or state == Enum.Store.SubscriptionState.ExtraActive
				or state == Enum.Store.SubscriptionState.TrialActive
				then
					return subscriptionIndex
				end
			end
		end
	end
end

function StoreSubscriptionTrackerMixin:UpdateSubscription()
	if C_StoreSecure.GetSelectedCategory() ~= Enum.Store.Category.Main
	or not C_StoreSecure.IsSubscriptionsLoaded()
	then
		self.subscriptionIndex = nil
		self:Hide()
		return
	end

	local subscriptionIndex = self:GetDesiredSubscriptionIndex()
	if not subscriptionIndex then
		self.subscriptionIndex = nil
		self:Hide()
		return
	end

	local subscriptionID, name, description, styleType, backgroundAtlas, bannerAtlas, artworkAtlas = C_StoreSecure.GetSubscriptionInfo(subscriptionIndex)
	local state, upgradeTimeLeft, nextSupplyTimeLeft, remainingSupplyTimes = C_StoreSecure.GetSubscriptionState(subscriptionIndex)

	self.Name:SetText(name)
	self.Artwork:SetAtlas(artworkAtlas)
	self:SetTimeLeft(nextSupplyTimeLeft, nil, self.OnPackageCountdownUpdate)
	self.subscriptionIndex = subscriptionIndex

	local itemList = C_StoreSecure.GetSubscriptionItems(subscriptionIndex, false)
	local numItems = #itemList

	for index = 1, numItems do
		local item = self.itemButtons[index]
		if not item then
			item = CreateFrame("Button", strformat("$parentItemButton%u", index), self, "StoreSubscriptionItemTemplate")
			item:SetID(index)
			item:SetOwner(self)
			item:SetSize(48, 48)
			item.IconGlow:Show()
			item.Amount:Hide()

			if index == 1 then
				item:SetPoint("LEFT", self.ItemHolder, "LEFT", 0, 0)
			else
				item:SetPoint("LEFT", self.itemButtons[index - 1], "RIGHT", 10, 0)
			end

			self.itemButtons[index] = item
		end

		local itemID, amount, isBonusItem = unpack(itemList[index])
		local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
		item.Icon:SetTexture(texture)
		item.link = link
		item:Show()
	end

	for index = numItems + 1, #self.itemButtons do
		self.itemButtons[index]:Hide()
	end

	if numItems > 0 then
		self.ItemHolder:SetWidth(self.itemButtons[1]:GetWidth() * numItems + 10 * (numItems - 1))
		self.ItemHolder:Show()
		self:SetHeight(320)
	else
		self.ItemHolder:Hide()
		self:SetHeight(260)
	end

	self:Show()
end

function StoreSubscriptionTrackerMixin:OnActionClick(button)
	if self.subscriptionIndex then
		local subscriptionIndex = C_StoreSecure.GetSubscriptionIndexByID(self.subscriptionIndex)
		if subscriptionIndex then
			C_StoreSecure.SetSelectedCategory(Enum.Store.Category.Subscriptions)
			C_StoreSecure.GetStoreFrame():GetPage(Enum.Store.Category.Subscriptions):ShowSubCategoryPage(subscriptionIndex)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
	end
end

function StoreSubscriptionTrackerMixin:OnPackageCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.NextPackegeTimerText:SetFormattedText(STORE_SUBSCRIPTION_NEXT_PACKAGE_TIMELEFT_SHORT, GetRemainingTime(timeLeft))
		self.NextPackegeTimerText:Show()
		self.NextPackegeTimerIcon:Show()
	else
		self.NextPackegeTimerText:Hide()
		self.NextPackegeTimerIcon:Hide()

		if timerFinished then
			self:UpdateSubscription()
		end
	end
end

StoreCategorySubMenuMixin = {}

function StoreCategorySubMenuMixin:OnLoad()
	self.baseHeight = 5
	self.subCategoryButtons = {}
end

function StoreCategorySubMenuMixin:OnShow()
	SetParentFrameLevel(self, -1)
end

function StoreCategorySubMenuMixin:OnHide()
	self:Close()
end

function StoreCategorySubMenuMixin:Close()
	for _, button in ipairs(self.subCategoryButtons) do
		button:Hide()
	end

	self:SetHeight(self.baseHeight)
end

function StoreCategorySubMenuMixin:UpdateSubCategories(selectedCategoryIndex, selectedSubCategoryIndex)
	local categoryIndex = self:GetParent():GetID()
	if categoryIndex ~= selectedCategoryIndex then
		self:Close()
		return
	end

	local numSubCategories = C_StoreSecure.GetNumSubCategories(categoryIndex)
	if numSubCategories == 0 or CATEGORY_NO_SUBMENU[selectedCategoryIndex] then
		self:Close()
		return
	end

	if not selectedSubCategoryIndex then
		selectedSubCategoryIndex = select(2, C_StoreSecure.GetSelectedCategory())
	end

	local OFFSET_Y = 10
	local PADDING = 2

	for index = 1, numSubCategories do
		local button = self.subCategoryButtons[index]
		if not button then
			button = CreateFrame("CheckButton", strformat("$parentSubCategoryButton%u", index), self, "StoreSubCategoryButtonTemplate")
			button:SetOwner(self:GetParent())
			button:SetID(index)
			button:SetBlockedUncheck(true)
			button:SetLockCheckedTextOffset(true)

			button:SetPoint("LEFT", PADDING, 0)
			button:SetPoint("RIGHT", -PADDING, 0)

			if index == 1 then
				button:SetPoint("TOP", 0, -(self.baseHeight + OFFSET_Y))
			else
				button:SetPoint("TOP", self.subCategoryButtons[index - 1], "BOTTOM", 0, -PADDING)
			end

			self.subCategoryButtons[index] = button
		end

		button:SetChecked(index == selectedSubCategoryIndex)
		button:UpdateInfo()
		button:Show()
	end

	for index = #self.subCategoryButtons + 1, numSubCategories do
		self.subCategoryButtons[index]:Hide()
	end

	self:SetHeight(self.baseHeight + (self.subCategoryButtons[1]:GetHeight() + PADDING) * numSubCategories - PADDING + OFFSET_Y * 2)
	self:Show()
end

StoreCategoryButtonProtoMixin = {}

function StoreCategoryButtonProtoMixin:UpdateState()
end

function StoreCategoryButtonProtoMixin:OnEnter()
	self:UpdateState()

	if self.reason and self:IsEnabled() ~= 1 then
		GameTooltip:SetOwner(self, self.tooltipAnchor or "ANCHOR_RIGHT")
		GameTooltip:AddLine(self.reason)
		GameTooltip:Show()
	end
end

function StoreCategoryButtonProtoMixin:OnLeave()
	self:UpdateState()

	if self.reason and self:IsEnabled() ~= 1 then
		GameTooltip:Hide()
	end
end

function StoreCategoryButtonProtoMixin:OnEnable()
	self:UpdateState()
end

function StoreCategoryButtonProtoMixin:OnDisable()
	self:UpdateState()
end

function StoreCategoryButtonProtoMixin:OnMouseDown()
	self:UpdateState()
end

function StoreCategoryButtonProtoMixin:OnMouseUp()
	self:UpdateState()
end

StoreCategoryButtonMixin = CreateFromMixins(PKBT_OwnerMixin, PKBT_ThreeSliceVirtualCheckButtonMixin, StoreCategoryButtonProtoMixin)

function StoreCategoryButtonMixin:OnLoad()
	PKBT_ThreeSliceVirtualCheckButtonMixin.OnLoad(self)

	self.NewIcon:SetAtlas("PKBT-Icon-Notification", true)
end

function StoreCategoryButtonMixin:UpdateInfo()
	local categoryIndex = self:GetID()
	local name, icon, isNew, enabled, reason = C_StoreSecure.GetCategoryInfo(categoryIndex)
	enabled = enabled and self:GetOwner():GetPage(categoryIndex) ~= nil

	self.callUpdateOnBlock = true
	self:SetText(name)
	self.Icon:SetTexture(icon)
	self.NewIcon:SetShown(enabled and isNew)
	self.reason = reason
	self:SetEnabled(enabled)
	self.Icon:SetDesaturated(not enabled)
end

function StoreCategoryButtonMixin:UpdateState()
	self:UpdateButton()
end

function StoreCategoryButtonMixin:OnChecked(checked, userInput)
	if checked and userInput then
		C_StoreSecure.SetSelectedCategory(self:GetID())
	end
end

function StoreCategoryButtonMixin:OnEnter()
	PKBT_ThreeSliceVirtualCheckButtonMixin.OnEnter(self)
	StoreCategoryButtonProtoMixin.OnEnter(self)
end

function StoreCategoryButtonMixin:OnLeave()
	PKBT_ThreeSliceVirtualCheckButtonMixin.OnLeave(self)
	StoreCategoryButtonProtoMixin.OnLeave(self)
end

function StoreCategoryButtonMixin:OnClick(button)
	if button == "LeftButton" and self:IsEnabled() == 1 then
		if not self:GetChecked() then
			self:SetChecked(true, true)
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		else
			local refundView = self:GetOwner():GetViewMode(Enum.StoreViewMode.Refund)
			if refundView:IsShown() then
				refundView:Hide()
			end

			local page = self:GetOwner():GetSelectedPage()
			if page and CATEGORY_OVERVIEW[page:GetID()] and page:GetSubCategoryIndex() ~= 0 then
			--	self:GetOwner():UpdateCategoryContent(page:GetID(), 0)
				C_StoreSecure.SetSelectedCategory(page:GetID(), 0)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end
		end
	end
end

StoreSubCategoryButtonMixin = CreateFromMixins(PKBT_OwnerMixin, PKBT_VirtualCheckButtonMixin, StoreCategoryButtonProtoMixin)

function StoreSubCategoryButtonMixin:OnLoad()
	PKBT_VirtualCheckButtonMixin.OnLoad(self)

	self.NewIcon:SetAtlas("PKBT-Icon-Notification", true)
end

function StoreSubCategoryButtonMixin:UpdateInfo()
	local categoryIndex = self:GetOwner():GetID()
	local subCategoryIndex = self:GetID()
	local name, icon, isNew, enabled, reason = C_StoreSecure.GetCategoryInfo(categoryIndex, subCategoryIndex)

	self:SetText(name)
	self.Icon:SetAtlas(icon)
	self.NewIcon:SetShown(enabled and isNew)
	self.reason = reason
	self:SetEnabled(enabled)
	self:UpdateState()
end

function StoreSubCategoryButtonMixin:OnChecked(checked, userInput)
	local categoryIndex = self:GetOwner():GetID()
	local subCategoryIndex = self:GetID()

	if checked and userInput then
		C_StoreSecure.SetSelectedCategory(categoryIndex, subCategoryIndex)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
end

function StoreSubCategoryButtonMixin:UpdateState()
	if self:IsEnabled() ~= 1 then
		self.Icon:SetVertexColor(0.553, 0.522, 0.494)
		self.ButtonText:SetTextColor(0.553, 0.522, 0.494)
	elseif self:IsMouseOver() then
		self.Icon:SetVertexColor(0.102, 1, 0.102)
		self.ButtonText:SetTextColor(0.102, 1, 0.102)
	elseif self:GetChecked() then
		self.Icon:SetVertexColor(1, 0.82, 0)
		self.ButtonText:SetTextColor(1, 0.82, 0)
	else
		self.Icon:SetVertexColor(1, 1, 1)
		self.ButtonText:SetTextColor(1, 1, 1)
	end
end

StoreCategoryPagesMixin = {}

function StoreCategoryPagesMixin:ShowSubCategoryPage(subCategoryIndex)
	self.subCategoryIndex = subCategoryIndex
	if not self:IsShown() then
		self:Show()
	elseif self.OnShow then
		self:OnShow()
	end
end

function StoreCategoryPagesMixin:SetSubCategoryIndex(index)
	self.subCategoryIndex = index
end

function StoreCategoryPagesMixin:GetSubCategoryIndex()
	return self.subCategoryIndex or 0
end

StorePageMainMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin)

function StorePageMainMixin:OnLoad()
	self.SpecialPanel.Banner.Background:SetTexture([[Interface\Custom\StoreBanner\default]])
	self.SpecialPanel.Banner.Background:SetTexCoord(0, 0.570312, 0, 1)

	self:SetID(Enum.Store.Category.Main)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StorePageMainMixin:OnShow()
	self.SpecialPanel.OfferAnnouncement:UpdateTimer()
	self:UpdateSpecialOffers(true)
	self:UpdateRecommendations()
end

function StorePageMainMixin:UpdateSpecialOffers(resetPage)
	if C_StoreSecure.IsSpecialOfferLoaded() and C_StoreSecure.GetNumSpecialOffers() > 0 then
		self.SpecialPanel.Banner.Offer:Show()
		self.SpecialPanel.Banner.Offer:Refresh(resetPage)
	else
		self.SpecialPanel.Banner.Offer:Hide()
	end
end

function StorePageMainMixin:UpdateRecommendations()
	self.RecommendationPanel:UpdateRecommendations()
end

StoreSpecialOfferMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function StoreSpecialOfferMixin:OnLoad()
	self.currentIndex = 0
	self.offerScenes = {}

	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_UPDATE")
--	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_LIST_WAIT")
--	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_LIST_READY")
end

function StoreSpecialOfferMixin:OnShow()
	SetParentFrameLevel(self.ActionButton, 5)
end

function StoreSpecialOfferMixin:OnEvent(event, ...)
	if event == "STORE_SPECIAL_OFFER_UPDATE" then
		local offerID, rangeChanged = ...
		self:Refresh(false, offerID)
	end
end

function StoreSpecialOfferMixin:Refresh(resetPage, offerID)
	local numOffers = C_StoreSecure.GetNumSpecialOffers()
	local currentIndex, numPages = self.Paginator:GetPage()

	if currentIndex == 0 and numOffers > 0 then
		self.Paginator:SetNumPages(numOffers)
	else
		self.Paginator:SetNumPages(numOffers, true)

		if numOffers > 0 then
			if resetPage then
				self:SetOfferIndex(1, true)
				self.Paginator:SetPage(1)
			else
				local newIndex = self.offerID and C_StoreSecure.GetSpecialOfferIndexByID(self.offerID)
				if not newIndex then
					newIndex = 1
				end

				currentIndex, numPages = self.Paginator:GetPage()

				if currentIndex == newIndex then
					self:SetOfferIndex(currentIndex, true)
				else
					self.Paginator:SetPage(newIndex)
				end
			end
		else
			self.currentIndex = 0
		end
	end

	self.Paginator:ResetScrollTimer()
	self:SetShown(numOffers ~= 0)
end

function StoreSpecialOfferMixin:SetOfferIndex(index, refresh)
	if index == self.currentIndex and not refresh then
		return
	end

	self.currentIndex = index
	self:UpdateOfferInfo()
end

function StoreSpecialOfferMixin:UpdateOfferInfo()
	if self.currentIndex == 0 then
		return
	end

	local offerID, title, name, description, remainingTime, price, discountPrice, currencyType, productID, isFreeSubscribe, isNew = C_StoreSecure.GetSpecialOfferInfo(self.currentIndex)
	local style = C_StoreSecure.GetSpecialOfferStyleInfo(self.currentIndex)

	self.offerID = offerID
	self.productID = productID
	self.isFreeSubscribe = isFreeSubscribe

	if self:IsVisible() then
		C_StoreSecure.ClearOfferNewFlag(self.currentIndex)
	end

	self.Background:SetTexture(style.background)
	self.Background:SetTexCoord(unpack(style.backgroundTexCoords))

	self.Info.ShadowBackground:SetShown(not style.NoSideBG)

	self.Info.Title:SetText(title)
	self.Info.Title:SetTextColor(unpack(style.TitleColor))

	if remainingTime == -1 then
		self:CancelCountdown()
		self.Info.TimerLabel:Hide()
		self.Info.Timer:Hide()
	else
		self:SetTimeLeft(remainingTime)
		self.Info.Timer:SetTextColor(unpack(style.TimerColor))
		self.Info.TimerLabel:Show()
		self.Info.Timer:Show()
	end

	self.Info.Name:SetText(name)
	self.Info.Name:SetTextColor(unpack(style.NameColor))

	local fontFile, fontHeight, fontFlags = self.Info.Name:GetFont()
	self.Info.Name:SetFont(fontFile, style.NameHeight or 20, fontFlags)

	self.Info.Description:SetText(description)
	self.Info.Description:SetTextColor(unpack(style.DescriptionColor))

	if self.activeScene then
		self.activeScene:Hide()
	end

	if style.SceneInfo then
		if not self.offerScenes[offerID] then
			self.offerScenes[offerID] = self:CreateOfferScene(style.SceneInfo, offerID)
		end
		self.offerScenes[offerID]:Show()
		self.activeScene = self.offerScenes[offerID]
	end
end

function StoreSpecialOfferMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.Info.Timer:SetText(GetRemainingTime(timeLeft))

		if timeLeft < 3600 then
			self.Info.Timer:SetTextColor(1, 1, 1)
		end
	elseif timerFinished then
		self:Refresh()
	end
end

function StoreSpecialOfferMixin:CreateOfferScene(sceneInfo, sceneID)
	local scene = CreateFrame("Frame", string.format("$parentScene%u", sceneID), self.ModelScene)
	scene:SetAllPoints(true)
	scene:Hide()

	scene.sceneID = sceneID
	scene.sceneInfo = sceneInfo
	scene.models = {}

	for index, modelInfo in ipairs(sceneInfo) do
		local creatureID, width, height, anchorPoint, rotation, scale, position, light, raceID = unpack(modelInfo)

		local frameType = raceID and "DressUpModel" or "PlayerModel"
		local model = CreateFrame(frameType, string.format("$parentModel%u", index), scene, "StoreSpecialOfferModelTemplate")
		model:SetID(index)
		model:SetSize(width or self.ModelScene:GetWidth(), height or self.ModelScene:GetHeight())

		if anchorPoint then
			local point, relativeTo, relativePoint, x, y = unpack(anchorPoint)
			if type(relativeTo) == "number" then
				model:SetPoint(point, scene.models[index] or self.ModelScene, relativePoint, x, y)
			else
				model:SetPoint(point, relativeTo or self.ModelScene, relativePoint, x, y)
			end
		else
			model:SetPoint("CENTER", 0, 0)
		end

		model.LoadingSpinner:SetAlpha(0)
		model:SetSettings(scale, position, light)
		model:SetCreatureModel(creatureID, math.rad(rotation))

		scene.models[index] = model
	end

	return scene
end

function StoreSpecialOfferMixin:OnActionClick(button)
	if self.isFreeSubscribe then
		C_StoreSecure.SetSelectedCategory(Enum.Store.Category.Subscriptions, 0)
	else
		C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(self.productID)
	end
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

StoreSpecialOfferModelMixin = CreateFromMixins(PKBT_ModelMixin)

function StoreSpecialOfferModelMixin:SetSettings(scale, position, light)
	scale = tonumber(scale)
	self.scale = type(scale) == "number" and scale or nil
	self.position = type(position) == "table" and position or nil
	self.light = type(light) == "table" and light or nil
end

function StoreSpecialOfferModelMixin:OnModelPresetApplied()
	self:SetModelScale(self.scale or 1)

	if self.position then
		self:SetPosition(unpack(self.position, 1, 3))
	end

	if self.light then
		self:SetLight(unpack(self.light))
	end
end

StoreSpecialOfferPaginatorMixin = CreateFromMixins(PKBT_PaginatorMixin)

function StoreSpecialOfferPaginatorMixin:OnLoad()
	PKBT_PaginatorMixin.OnLoad(self)

	self.NextButton:ClearAllPoints()
	self.NextButton:SetPoint("RIGHT")
	self.PrevButton:SetPoint("RIGHT", self.NextButton, "LEFT", -5, 0)
	self.PageText:ClearAllPoints()
	self.PageText:SetPoint("RIGHT", self.PrevButton, "LEFT", -5, 0)

	self.elapsed = 0
end

function StoreSpecialOfferPaginatorMixin:OnShow()
	self.elapsed = 0
	SetParentFrameLevel(self, 5)
end

function StoreSpecialOfferPaginatorMixin:OnUpdate(elapsed)
	local parent = self:GetParent()
	if parent:IsMouseOver() then
		self.elapsed = 0
		return
	end

	self.elapsed = self.elapsed + elapsed

	if self.elapsed >= OFFER_SCROLL_TIME then
		self.elapsed = 0
		self:NextPage(true)
	end
end

function StoreSpecialOfferPaginatorMixin:ResetScrollTimer()
	self.elapsed = 0
end

function StoreSpecialOfferPaginatorMixin:OnPageChanged(currentPage, numPages)
	if numPages > 1 then
		self.elapsed = 0
		self:SetWidth(self.PageText:GetStringWidth() + 72)
	end

	self:GetParent():SetOfferIndex(currentPage)
end

StoreOfferAnnouncementMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function StoreOfferAnnouncementMixin:OnLoad()
	self.Artwork:SetAtlas("PKBT-Store-Artwork-Offer", true)
	self.HeaderText:SetText(STORE_NEXT_OFFER_SOON)
	self.Ribbon:SetText(STORE_NEXT_OFFER_UPDATE)

	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_NEXT_TIMER_READY")
--	self:RegisterCustomEvent("STORE_SPECIAL_OFFER_NEXT_TIMER_WAIT")
end

function StoreOfferAnnouncementMixin:OnShow()
	SetParentFrameLevel(self.Ribbon, 2)
end

function StoreOfferAnnouncementMixin:OnEvent(event, ...)
	if event == "STORE_SPECIAL_OFFER_NEXT_TIMER_READY" then
		self:UpdateTimer()
	end
end

function StoreOfferAnnouncementMixin:UpdateTimer()
	local timeLeft = C_StoreSecure.GetNextSpecialOfferTimeLeft()

	self:SetTimeLeft(timeLeft)

	if timeLeft == 0 and C_StoreSecure.IsNextSpecialOfferLoaded() then
		C_StoreSecure.RequestNextSpecialOfferTime()
	end
end

function StoreOfferAnnouncementMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.Timer.Value:SetText(GetRemainingTime(timeLeft))
		self:Show()
	else
		self:Hide()

		if timerFinished then
			C_StoreSecure.RequestNextSpecialOfferTime()
		end
	end
end

StoreRecommendationPanelMixin = {}

function StoreRecommendationPanelMixin:OnLoad()
	self.Paginator.Background:SetAtlas("PKBT-Store-Pagination-Arrow-Background", true)
	self.Paginator:SetPageFormat(STORE_PAGE_FORMAT)
	self.Paginator.OnPageChanged = function(this, currentPage, numPages)
		self:UpdateRecommendations()
	end

	self.cardPoolCollection = CreateFramePoolCollection()
	self.cardHorizontalPool = self.cardPoolCollection:CreatePool("Button", self, "StoreRecommendationHorizontalTemplate")
	self.cardVerticalPool = self.cardPoolCollection:CreatePool("Button", self, "StoreRecommendationVerticalTemplate")

	self:RegisterCustomEvent("STORE_RECOMMENDATION_UPDATE")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_RENEW")

	self.cardSpace = 8
	self.sortedProductIndexes = {}
	self.dirty = true
end

function StoreRecommendationPanelMixin:OnEvent(event, ...)
	if event == "STORE_RECOMMENDATION_UPDATE" then
		self.dirty = true
		if self:IsVisible() then
			self:UpdateRecommendations()
		end
	elseif event == "STORE_PRODUCT_LIST_RENEW" then
		local categoryIndex, subCategoryIndex = ...
		if categoryIndex == Enum.Store.Category.Main then
			self.dirty = true
			if self:IsVisible() then
				self:UpdateRecommendations()
			end
		end
	end
end

function StoreRecommendationPanelMixin:OnShow()
	self.Paginator:SetPage(1)
end

function StoreRecommendationPanelMixin:OnMouseWheel(delta)
	if delta > 0 then
		self.Paginator:PreviousPage()
	else
		self.Paginator:NextPage()
	end
end

function StoreRecommendationPanelMixin:SortProductIndexes()
	if not self.dirty and #self.sortedProductIndexes == C_StoreSecure.GetNumRecommendations() then
		return
	end

	table.wipe(self.sortedProductIndexes)
	self.dirty = nil

	local pageSlotsLeft = self.cardSpace
	local skipped = {}
	local page = 1

	for itemIndex = 1, C_StoreSecure.GetNumRecommendations() do
		local name, itemLink, rarity, icon, artwork, modelType, modelID, amount, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetRecommendationInfo(itemIndex)
		local slots
		if modelType == Enum.ModelType.Creature then
			slots = 2
		else
			slots = 1
		end
		if pageSlotsLeft >= slots then
			if not self.sortedProductIndexes[page] then
				self.sortedProductIndexes[page] = {}
			end

			pageSlotsLeft = pageSlotsLeft - slots
			table.insert(self.sortedProductIndexes[page], itemIndex)

			if pageSlotsLeft == 0 then
				pageSlotsLeft = self.cardSpace
				page = page + 1

				if #skipped > 0 then
					if not self.sortedProductIndexes[page] then
						self.sortedProductIndexes[page] = {}
					end

					for i = 1, #skipped do
						pageSlotsLeft = pageSlotsLeft - skipped[i][2]
						table.insert(self.sortedProductIndexes[page], skipped[i][1])
						skipped[i] = nil
					end
				end
			end
		else
			table.insert(skipped, {itemIndex, slots})
		end
	end

	if #skipped > 0 then
		if pageSlotsLeft < skipped[1][2] then
			page = page + 1
		end

		if not self.sortedProductIndexes[page] then
			self.sortedProductIndexes[page] = {}
		end
		for i = 1, #skipped do
			pageSlotsLeft = pageSlotsLeft - skipped[i][2]
			table.insert(self.sortedProductIndexes[page], skipped[i][1])
			skipped[i] = nil
		end
	end

	self.Paginator:SetNumPages(#self.sortedProductIndexes, true)
end

function StoreRecommendationPanelMixin:UpdateRecommendations()
	self:SortProductIndexes()

	local currentPage, numPages = self.Paginator:GetPage()
	self.cardPoolCollection:ReleaseAll()

	if not self.sortedProductIndexes[currentPage] then
		return
	end

	local lastCard

	for index, productIndex in ipairs(self.sortedProductIndexes[currentPage]) do
		local name, itemLink, rarity, icon, artwork, modelType, modelID, amount, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetRecommendationInfo(productIndex)

		local template
		if modelType == Enum.ModelType.Creature then
			template = "StoreRecommendationHorizontalTemplate"
		else
			template = "StoreRecommendationVerticalTemplate"
		end

		local card = self.cardPoolCollection:Acquire(template)
		card:SetID(productIndex)
		card:SetOwner(self)

		if index == 1 then
			card:SetPoint("LEFT", -1, 30)
		else
			card:SetPoint("TOPLEFT", lastCard, "TOPRIGHT", 16, 0)
		end

		card:UpdateProduct()
		card:Show()

		lastCard = card
	end
end

StoreRecommendationMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreRecommendationMixin:OnLoad()
	self.PurchaseButton:SetFixedWidth(120)
	self.PurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)
	self.UpdateTooltip = self.OnEnter
end

function StoreRecommendationMixin:OnShow()
	SetParentFrameLevel(self.Overlay, 2)
	SetParentFrameLevel(self.Special, 3)
	SetParentFrameLevel(self.PurchaseButton, 3)
	SetParentFrameLevel(self.DetailsButton, 3)
end

function StoreRecommendationMixin:OnEnter()
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

	CursorUpdate(self)
end

function StoreRecommendationMixin:OnLeave()
	if self.itemLink then
		GameTooltip_Hide()
	end
	ResetCursor()
end

function StoreRecommendationMixin:OnClick(button)
	if IsAltKeyDown() and C_StoreSecure.AddProductItems(self.productID) then
		return
	end
	if IsModifiedClick("DRESSUP") then
		local allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton = true, true, false, true
		C_StoreSecure.GetStoreFrame():ShowProductDressUp(self:GetOwner():GetParent(), self.productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
	elseif IsModifiedClick("CHATLINK") then
	--	local link = C_StoreSecure.GenerateProductHyperlink(item.productID)
		if self.itemLink and ChatEdit_InsertLink(self.itemLink) then
			return true;
		end
	end
end

function StoreRecommendationMixin:SetModel(modelType, modelID, facing)
	self.Model:SetModelAuto(modelType, modelID, facing or C_StorePublic.GetPreferredModelFacing())
end

function StoreRecommendationMixin:DetailsOnClick(button)
end

function StoreRecommendationMixin:OnPurchaseClick(button)
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(self.productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreRecommendationMixin:UpdateProduct()
end

StoreRecommendationVerticalMixin = CreateFromMixins(StoreRecommendationMixin)

function StoreRecommendationVerticalMixin:OnLoad()
	StoreRecommendationMixin.OnLoad(self)

	self.Overlay.Shadow:SetAtlas("PKBT-Store-Cards-Product-Frame-Vertical-Shadow", true)
	self.Overlay.Border:SetAtlas("PKBT-Store-Cards-Product-Frame-Vertical-Border", true)
	self.Overlay.Name:SetWidth(self:GetWidth() - 30)

	self.Item.IconShadow:SetAtlas("PKBT-Store-Product-Item-Shadow", true)
	self.Item.Border:SetAtlas("PKBT-ItemBorder-Normal", true)

	self.PurchaseButton:SetOriginalOnTop(true)
end

function StoreRecommendationVerticalMixin:OnModelTypeChanged(modelType, modelID)
	if modelType == Enum.ModelType.Illusion then
		self.Model:SetPoint("BOTTOMRIGHT", -7, 14)
	else
		self.Model:SetPoint("BOTTOMRIGHT", -7, 32)
	end
end

function StoreRecommendationVerticalMixin:UpdateProduct()
	local name, itemLink, rarity, icon, artwork, modelType, modelID, amount, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetRecommendationInfo(self:GetID())

	self.productID = productID
	self.itemLink = itemLink

	if artwork then
		self.Background:SetTexture(artwork)
		self.Background:ClearAllPoints()
		self.Background:SetPoint("TOPLEFT", 5, -6)
		self.Background:SetPoint("BOTTOMRIGHT", -5, 6)
	else
		self.Background:SetAtlas("PKBT-Store-Cards-Product-Frame-Vertical-Background", true)
		self.Background:ClearAllPoints()
		self.Background:SetPoint("CENTER", 0, 0)
	end

	if modelType == Enum.ModelType.Illusion
	or modelType == Enum.ModelType.ItemTransmog
	then
		self.Item:Hide()
		self.Model:SetModelAuto(modelType, modelID)
		self.Model:Show()
	else
		self.Model:Hide()
		self.Model:ResetFull()
		self.Item.Icon:SetTexture(icon)
		self.Item.Amount:SetText(amount > 1 and amount or "")
		self.Item:Show()
	end

	self.Overlay.Name:SetText(name)

	if originalPrice and originalPrice ~= price and originalPrice > 0 then
		self.Special.Text:SetFormattedText(STORE_DISCOUNT_AMOUNT_FORMAT, C_StoreSecure.GetDiscountForProductID(productID))
		self.Special:Show()
	else
		self.Special:Hide()
	end

	self.PurchaseButton:SetPrice(price, originalPrice, currencyType)
--	self.PurchaseButton:SetShown(not altCurrencyType)
--	self.DetailsButton:SetShown(altCurrencyType)
end

StoreRecommendationHorizontalMixin = CreateFromMixins(StoreRecommendationMixin)

function StoreRecommendationHorizontalMixin:OnLoad()
	StoreRecommendationMixin.OnLoad(self)

	self.Overlay.Shadow:SetAtlas("PKBT-Store-Cards-Product-Frame-Horizontal-Shadow", true)
	self.Overlay.Border:SetAtlas("PKBT-Store-Cards-Product-Frame-Horizontal-Border", true)
	self.Overlay.Name:SetWidth(self:GetWidth() - 60)
end

function StoreRecommendationHorizontalMixin:UpdateProduct()
	local name, itemLink, rarity, icon, artwork, modelType, modelID, amount, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetRecommendationInfo(self:GetID())

	self.productID = productID
	self.itemLink = itemLink

	if artwork then
		self.Background:SetTexture(artwork)
		self.Background:ClearAllPoints()
		self.Background:SetPoint("TOPLEFT", 5, -6)
		self.Background:SetPoint("BOTTOMRIGHT", -5, 6)
	else
		self.Background:SetAtlas("PKBT-Store-Cards-Product-Frame-Horizontal-Background", true)
		self.Background:ClearAllPoints()
		self.Background:SetPoint("CENTER", 0, 0)
	end

	self.Model:SetModelAuto(modelType, modelID, C_StorePublic.GetPreferredModelFacing())
	self.Model:Show()

	self.Overlay.Name:SetText(name)

	if originalPrice and originalPrice ~= price and originalPrice > 0 then
		self.Special.Text:SetFormattedText(STORE_DISCOUNT_AMOUNT_FORMAT, C_StoreSecure.GetDiscountForProductID(productID))
		self.Special:Show()
	else
		self.Special:Hide()
	end

	self.PurchaseButton:SetPrice(price, originalPrice, currencyType)

	if false and altCurrencyType then
		self.DetailsButton:Show()
		self.DetailsButton:SetPoint("BOTTOMLEFT", 15, -30)
		self.PurchaseButton:ClearAllPoints()
		self.PurchaseButton:SetPoint("BOTTOMRIGHT", -15, -30)
		self.PurchaseButton:Show()
	else
		self.DetailsButton:Hide()
		self.PurchaseButton:ClearAllPoints()
		self.PurchaseButton:SetPoint("BOTTOM", 0, -30)
		self.PurchaseButton:Show()
	end
end

StorePageLoyalityMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin)

function StorePageLoyalityMixin:OnLoad()
	self:SetID(Enum.Store.Category.Loyality)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StorePageLoyalityMixin:OnShow()
	local subCategoryIndex = self:GetSubCategoryIndex()
	local itemListView = self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList)
	itemListView:SetParentPage(self)
	itemListView:SetViewCategory(self:GetID(), subCategoryIndex)
end

StorePageReferralMixin = CreateFromMixins(StorePageLoyalityMixin)

function StorePageReferralMixin:OnLoad()
	self:SetID(Enum.Store.Category.Referral)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

StorePageVoteMixin = CreateFromMixins(StorePageLoyalityMixin)

function StorePageVoteMixin:OnLoad()
	self:SetID(Enum.Store.Category.Vote)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

StorePageEquipmentMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin)

function StorePageEquipmentMixin:OnLoad()
	self.PaperDoll.ShadowTop:SetAtlas("PKBT-Background-Shadow-Large-Top", true)
	self.PaperDoll.ShadowBottom:SetAtlas("PKBT-Background-Shadow-Large-Bottom", true)
	self.PaperDoll.ShadowLeft:SetAtlas("PKBT-Background-Shadow-Large-Left", true)
	self.PaperDoll.ShadowRight:SetAtlas("PKBT-Background-Shadow-Large-Right", true)
	self.PaperDoll.ShadowBottom:Hide()

	self.PaperDoll.Ribbon:SetText(STORE_SELECT_SLOT)

	self.slotButtons = {}
	self.itemLevelsDirty = true

	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterCustomEvent("STORE_REFUND_LIST_UPDATE")
--	self:RegisterCustomEvent("STORE_EQUIPMENT_ITEM_LEVELS_WAIT")
	self:RegisterCustomEvent("STORE_EQUIPMENT_ITEM_LEVELS_READY")
	self:RegisterCustomEvent("STORE_EQUIPMENT_ITEM_LEVELS_OUTDATE")

	self:SetID(Enum.Store.Category.Equipment)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StorePageEquipmentMixin:OnEvent(event, ...)
	if not self:IsVisible() then
		return
	end

	if event == "UNIT_MODEL_CHANGED" then
		local unit = ...
		if unit == "player" then
			self.PaperDoll.Model:SetUnit("player")
		end
	elseif event == "STORE_REFUND_LIST_UPDATE" then
		self:UpdateRefundButton()
	elseif event == "PLAYER_EQUIPMENT_CHANGED"
	or event == "STORE_EQUIPMENT_ITEM_LEVELS_READY"
	or event == "STORE_EQUIPMENT_ITEM_LEVELS_WAIT"
	then
		self:UpdateSlots()
	elseif event == "STORE_EQUIPMENT_ITEM_LEVELS_OUTDATE" then
		if self:IsShown() then
			C_StoreSecure.RequestEquipmentItemLevels()
		else
			self.equipmentItemLevelDirty = true
		end
	end
end

function StorePageEquipmentMixin:OnShow()
	if self.itemLevelsDirty then
		self.itemLevelsDirty = nil
		C_StoreSecure.RequestEquipmentItemLevels()
	end

	local subCategoryIndex = self:GetSubCategoryIndex()

	self.PaperDoll:SetShown(subCategoryIndex == 0)

	if subCategoryIndex == 0 then
		if not self.initialized then
			if UnitFactionGroup("player") == "Horde" then
				self.PaperDoll.Background:SetAtlas("PKBT-Store-Equipment-Background-BloodElf")
			else
				self.PaperDoll.Background:SetAtlas("PKBT-Store-Equipment-Background-Dragon")
			end
			self.initialized = true
		end

		self.PaperDoll.Model:SetUnit("player")

		self:UpdateRefundButton()
		self:UpdateSlots()

		C_StoreSecure.RequestRefundList()
	else
		local itemListView = self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList)
		itemListView:SetParentPage(self)
		itemListView:SetViewCategory(self:GetID(), subCategoryIndex)
	end
end

function StorePageEquipmentMixin:UpdateRefundButton()
	self.PaperDoll.Refund:SetShown(C_StoreSecure.GetNumRefundProducts() ~= 0)
end

function StorePageEquipmentMixin:UpdateSlots()
	local BUTTON_PADDING = 15

	for index = 1, C_StoreSecure.GetNumEquipmentSlots() do
		local slot = self.slotButtons[index]
		if not slot then
			slot = CreateFrame("Button", strformat("$parentSlotButton%u", index), self.PaperDoll, "StoreEquipmentButtonTemplate")
			slot:SetOwner(self)
			slot:SetID(index)

			local slotID, name, icon = C_StoreSecure.GetEquipmentSlotInfo(index)
			slot:SetSlotInfo(slotID, name, icon)

			slot:SetIconPosition(index <= 6 or index == 14 or index == 15)

			if index <= 6 then
				if index == 1 then
					slot:SetPoint("TOPRIGHT", self.PaperDoll.Model, "TOPLEFT", 0, 0)
				else
					slot:SetPoint("TOPLEFT", self.slotButtons[index - 1], "BOTTOMLEFT", 0, -BUTTON_PADDING)
				end
			elseif index <= 12 then
				if index == 7 then
					slot:SetPoint("TOPLEFT", self.PaperDoll.Model, "TOPRIGHT", 0, 0)
				else
					slot:SetPoint("TOPLEFT", self.slotButtons[index - 1], "BOTTOMLEFT", 0, -BUTTON_PADDING)
				end
			elseif index == 13 then
				slot:SetPoint("TOP", self.PaperDoll.Model, "BOTTOM", -((slot:GetWidth() + slot.Icon:GetWidth()) + 50), 30)
			elseif index == 14 then
				slot:SetPoint("TOP", self.PaperDoll.Model, "BOTTOM", slot.Icon:GetWidth() / 2, 30)
			elseif index == 15 then
				slot:SetPoint("TOP", self.PaperDoll.Model, "BOTTOM", ((slot:GetWidth() + slot.Icon:GetWidth()) + 50), 30)
			end

			self.slotButtons[index] = slot
		end

		slot:SetNew(C_StoreSecure.HasEquipmentSlotNewItems(index))
		slot:SetUpgrage(C_StoreSecure.HasEquipmentSlotUpgradeItems(index))
	end
end

function StorePageEquipmentMixin:SlotClick(button, slotID)
	self:ShowSubCategoryPage(slotID)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function StorePageEquipmentMixin:OnBrowseAllClick(button)
	local itemListView = self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList)
	itemListView:SetParentPage(self)
	itemListView:SetViewCategory(self:GetID(), 0)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function StorePageEquipmentMixin:OnOpenRefundClick(button)
	self:GetOwner():GetViewMode(Enum.StoreViewMode.Refund):SetParentPage(self)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

StoreRefundViewMixin = CreateFromMixins(StoreSubViewMixin)

function StoreRefundViewMixin:OnLoad()
	self.Background:SetAtlas("PKBT-Tile-Obsidian-256", true)
	self.BackgroundBottom:SetAtlas("PKBT-Tile-Wood-128")

	self.VignetteBottomLeft:SetAtlas("PKBT-Vignette-Bronze-BottomLeft", true)
	self.VignetteBottomRight:SetAtlas("PKBT-Vignette-Bronze-BottomRight", true)

	self.PageHeader:SetLabel(STORE_PRODUCT_REFUND_TITLE)

	self:RegisterCustomEvent("STORE_REFUND_LIST_UPDATE")
	self:RegisterCustomEvent("STORE_REFUND_LIST_WAIT")
	self:RegisterCustomEvent("STORE_REFUND_ERROR")
	self:RegisterCustomEvent("STORE_REFUND_SUCCESS")
	self:RegisterCustomEvent("STORE_REFUND_WAIT")
	self:RegisterCustomEvent("STORE_REFUND_READY")

	self.BUTTON_OFFSET_Y = 9

	self.selectionDict = {}

	self.Scroll.ScrollBar:SetBackgroundShown(false)
	self.Scroll.update = function(scrollFrame)
		self:UpdateProductList()
	end
	self.Scroll.ScrollBar.doNotHide = true
	self.Scroll.scrollBar = self.Scroll.ScrollBar
	HybridScrollFrame_CreateButtons(self.Scroll, "StoreRefundProductPlateTemplate", 0, 0, nil, nil, nil, -self.BUTTON_OFFSET_Y)

	self.RefundAmount.CurrencyList.OnRectUpdate = function(this, value)
		local width = self.RefundAmount.Label:GetStringWidth() + this:GetWidth() + 10
		self.RefundAmount:SetWidth(width)
		self.RefundAmount:SetPoint("BOTTOM", self.RefundButton, "TOP", -(this:GetWidth() + 10) / 2, 15)
	end

	self:RegisterViewMode(Enum.StoreViewMode.Refund)
end

function StoreRefundViewMixin:OnEvent(event, ...)
	if event == "STORE_REFUND_LIST_UPDATE" then
		if self:IsShown() then
			self.dirty = true
			self:ClearSelection()
			self:UpdateProductList()
			self.Loading:Hide()
		end
	elseif event == "STORE_REFUND_LIST_WAIT" then
		if self:IsShown() then
			self.Loading:Show()
		end
	elseif event == "STORE_REFUND_ERROR" then
		local errorText = ...
		self:GetOwner():ShowError(self, errorText)
	elseif event == "STORE_REFUND_SUCCESS" then
		local currencyTypes = ...
		for index, currencyType in ipairs(currencyTypes) do
			local name, description, link, texture, iconAtlas = C_StorePublic.GetCurrencyInfo(currencyType)
			if texture or iconAtlas then
				self:GetOwner():AddPurchaseAlert(iconAtlas or texture, name, STORE_DELIVERED_REFUND)
			end
		end
	elseif event == "STORE_REFUND_WAIT" then
		self.RefundButton:ShowSpinner()
		self.RefundButton:Disable()
	elseif event == "STORE_REFUND_READY" then
		self.RefundButton:HideSpinner()
		self:Summery()
	end
end

function StoreRefundViewMixin:OnShow()
	StoreSubViewMixin.OnShow(self)

	C_StoreSecure.RequestRefundList()

	SetParentFrameLevel(self.Loading, 10)
	self.Loading:SetShown(C_StoreSecure.IsAwaitingRefundList())

	if C_StoreSecure.IsAwaitingRefundAnswer() then
		self.RefundButton:ShowSpinner()
		self.RefundButton:Disable()
	else
		self.RefundButton:HideSpinner()
	end

	self.dirty = true
	self:ClearSelection()
	self.Scroll.ScrollBar:SetValue(0)
	self:UpdateProductList()
end

function StoreRefundViewMixin:OnHide()
	StoreSubViewMixin.OnHide(self)
end

function StoreRefundViewMixin:ClearSelection(skipVisualUpdate)
	table.wipe(self.selectionDict)

	if not skipVisualUpdate then
		if not self.dirty then
			for index, button in ipairs(self.Scroll.buttons) do
				if button:IsShown() then
					button:SetSelected(false)
				end
			end
		end

		self:Summery()
	end

	self.RefundAmount.CurrencyList:SetCurrency(Enum.Store.CurrencyType.Bonus, 0)
	self.RefundButton:Disable()
end

function StoreRefundViewMixin:SetSelectedProduct(index, state)
	self.selectionDict[index] = state
	self:Summery()
end

function StoreRefundViewMixin:UpdateProductList()
	local scrollFrame = self.Scroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local numRefundProducts = C_StoreSecure.GetNumRefundProducts()

	for index, button in ipairs(scrollFrame.buttons) do
		local productIndex = index + offset
		if productIndex <= numRefundProducts then
			button:SetOwner(self)
			button:SetID(productIndex)
			button:UpdateProductInfo()
			button:SetChecked(self.selectionDict[productIndex])
			button:Show()
		else
			button:Hide()
		end
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		local scrollHeight = buttonHeight * numRefundProducts + self.BUTTON_OFFSET_Y * (numRefundProducts - 1) + self.BUTTON_OFFSET_Y / 3
		HybridScrollFrame_Update(scrollFrame, scrollHeight, scrollFrame:GetHeight())
		self.dirty = nil
	end
end

function StoreRefundViewMixin:Summery()
	local numSelected = 0
	local currencyList = {}

	for index, selected in pairs(self.selectionDict) do
		if selected then
			local itemLink, amount, purchaseDate, remainingTime, penalty, price, originalPrice, currencyType = C_StoreSecure.GetRefundProductInfo(index)
			numSelected = numSelected + 1

			if currencyList[currencyType] then
				currencyList[currencyType] = currencyList[currencyType] + price
			else
				currencyList[currencyType] = price
			end
		end
	end

	if next(currencyList) then
		self.RefundAmount.CurrencyList:SetCurrencyHashList(currencyList)
	else
		self.RefundAmount.CurrencyList:SetCurrency(Enum.Store.CurrencyType.Bonus, 0)
	end
	self.RefundButton:SetEnabled(not C_StoreSecure.IsAwaitingRefundAnswer() and numSelected ~= 0)
end

function StoreRefundViewMixin:OnRefundClick(button)
	local selectedProducts = {}
	for index, selected in pairs(self.selectionDict) do
		if selected then
			table.insert(selectedProducts, index)
		end
	end

	if #selectedProducts ~= 0 then
		C_StoreSecure.RefundProductIndexes(unpack(selectedProducts))
		PlaySound(SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON)
	end
end

StoreRefundProductPlateMixin = CreateFromMixins(PKBT_OwnerMixin, PKBT_CountdownThrottledBaseMixin)

function StoreRefundProductPlateMixin:OnLoad()
	self.Price:SetOriginalOnTop(true)
	self.selected = false
	self.CheckButton.OnChecked = function(this, checked)
		self:OnChecked(checked)
	end
	self.UpdateTooltip = self.OnEnter
end

function StoreRefundProductPlateMixin:OnEnter()
	self.Background:SetTexture(0.157, 0.157, 0.157)

	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end
end

function StoreRefundProductPlateMixin:OnLeave()
	self.Background:SetTexture(0.059, 0.059, 0.059)
	GameTooltip:Hide()
end

function StoreRefundProductPlateMixin:OnClick(button)
	local checked = not self.CheckButton:GetChecked()
	self.CheckButton:SetChecked(checked)

	if checked then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
end

function StoreRefundProductPlateMixin:OnChecked(checked)
	self:GetOwner():SetSelectedProduct(self:GetID(), checked)

	if checked then
--		NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PKBT_ItemPlateHighlight")
	else
--		NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PKBT_ItemPlate")
	end
end

function StoreRefundProductPlateMixin:SetChecked(state)
	self.CheckButton:SetChecked(state)
end

function StoreRefundProductPlateMixin:GetChecked()
	return not not self.CheckButton:GetChecked()
end

function StoreRefundProductPlateMixin:UpdateProductInfo()
	local itemLink, amount, purchaseDate, remainingTime, penalty, price, originalPrice, currencyType = C_StoreSecure.GetRefundProductInfo(self:GetID())
	local name, link, rarity, level, minLevel, itemType, itemSubType, stackCount, equipLoc, icon, vendorPrice = GetItemInfo(itemLink)

	self.Item:SetIcon(icon)
	self.Item:SetAmount(amount)

	self.Name:SetText(name)
	self.Name:SetTextColor(GetItemQualityColor(rarity))
	self.PurchaseDate:SetFormattedText(STORE_PRODUCT_REFUND_PURCHASE_DATE, date("%d.%m.%Y", purchaseDate))
	self.Penalty:SetFormattedText(STORE_PRODUCT_REFUND_PURCHASE_PENALTY, penalty)
	self.link = itemLink

	self.Price:SetPrice(price, originalPrice, currencyType)
	self:SetCountdown(remainingTime)
end

function StoreRefundProductPlateMixin:OnCountdownUpdate(timeLeft, isFinished)
	self.TimeLeft:SetFormattedText(STORE_PRODUCT_REFUND_PURCHASE_TIMELEFT, GetRemainingTime(timeLeft))
	if isFinished then
		self:GetOwner():UpdateProductList()
	end
end

StorePageCollectionsMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin)

function StorePageCollectionsMixin:OnLoad()
	self.RefreshFrame.RefreshButton:AddTextureAtlas("PKBT-Icon-Refresh", true)
	self.RefreshFrame.RefreshButton:AddText(STORE_REFRESH_PRODUCTS)

	Mixin(self.RefreshFrame, PKBT_CountdownThrottledBaseMixin)

	self.Paginator.Background:SetAtlas("PKBT-Store-Pagination-Arrow-Background", true)
	self.Paginator:SetPageFormat(STORE_PAGE_FORMAT)
	self.Paginator.OnPageChanged = function(this, currentPage, numPages)
		self:UpdateProducts()
	end

	self.RefreshFrame:SetScript("OnShow", function(this)
		self:UpdateRefreshTimer()
	end)

	self.tabButtons = {}
	self.productButtons = {}
	self.productsPerRow = 5
	self.numRows = 2

	self:RegisterCustomEvent("STORE_PRODUCT_LIST_UPDATE")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_LOADING")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_RENEW")
	self:RegisterCustomEvent("STORE_RANDOM_ITEM_POLL_UPDATE")

	self:SetID(Enum.Store.Category.Collections)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StorePageCollectionsMixin:OnEvent(event, ...)
	if not self:IsVisible() then
		return
	end

	if event == "STORE_PRODUCT_LIST_LOADING" then
		local categoryIndex, subCategoryIndex = ...
		if self.categoryIndex == categoryIndex and self.subCategoryIndex == subCategoryIndex then
			self.Loading:Show()
		end
	elseif event == "STORE_PRODUCT_LIST_UPDATE"
	or event == "STORE_PRODUCT_LIST_RENEW"
	then
		local categoryIndex, subCategoryIndex = ...
		if categoryIndex == self:GetID() then
			if not subCategoryIndex or subCategoryIndex == self:GetSubCategoryIndex() then
				self:UpdateProducts()
			end
		end
	elseif event == "STORE_RANDOM_ITEM_POLL_UPDATE" then
		self:UpdateRefreshTimer()
	end
end

function StorePageCollectionsMixin:OnShow()
	if not self.initialized then
		local name = C_StoreSecure.GetCategoryInfo(self:GetID())
		self.PageHeader:SetLabel(name)
		self.initialized = true
	end

	SetParentFrameLevel(self.Loading, 10)
	self.Loading:Show()

	local _, selectedSubCategoryIndex = C_StoreSecure.GetSelectedCategory()
	self:SetSubCategory(selectedSubCategoryIndex)
	self.Paginator:SetPage(1)
end

function StorePageCollectionsMixin:OnHide()
	self.Loading:Hide()
end

function StorePageCollectionsMixin:OnMouseWheel(delta)
	if delta > 0 then
		self.Paginator:PreviousPage()
	else
		self.Paginator:NextPage()
	end
end

function StorePageCollectionsMixin:UpdateRefreshTimer()
	local timeLeft, isRefreshAvailable = C_StoreSecure.GetCollectionRefreshTimeLeft(self:GetSubCategoryIndex())
	if timeLeft > 0 then
		self.RefreshFrame.RefreshButton:SetEnabled(isRefreshAvailable)
	else
		self.RefreshFrame.RefreshButton:Disable()
	end
	self.RefreshFrame:SetTimeLeft(timeLeft, nil, self.OnRefreshCountdownUpdate)
end

function StorePageCollectionsMixin.OnRefreshCountdownUpdate(this, timeLeft, timerFinished)
	if timeLeft > 0 then
		this.Timer:SetText(GetRemainingTime(timeLeft))
		this:Show()
	else
		this:Hide()

		if timerFinished then
			this:GetParent():UpdateProducts()
		end
	end
end

function StorePageCollectionsMixin:CanRefreshList()
	return C_StoreSecure.GetCollectionRefreshTimeLeft(self:GetSubCategoryIndex()) ~= -1
end

function StorePageCollectionsMixin:AttachRefreshFrame()
	if self:CanRefreshList() then
		local numProducts = C_StoreSecure.GetNumCollectionProducts(self:GetSubCategoryIndex())
		local productsPerPage = self.productsPerRow * self.numRows - 1

		if numProducts == 0 then
			self.RefreshFrame:ClearAllPoints()
			self.RefreshFrame:SetPoint("CENTER", 0, 0)
			self.RefreshFrame:Show()
			return
		elseif self.productsPerRow % 2 == 1 then
			local centerButtonIndex = math.ceil(self.productsPerRow / 2)
			local centerButton = self.productButtons[centerButtonIndex]
			if centerButton and centerButton:IsShown() then
				local currentPage, numPages = self.Paginator:GetPage()

				if numProducts == self.productsPerRow
				or (currentPage == numPages and (numProducts - productsPerPage) % self.productsPerRow == 0)
				then
					self.RefreshFrame:ClearAllPoints()
					self.RefreshFrame:SetPoint("TOP", centerButton, "BOTTOM", 0, -25)
					self.RefreshFrame:Show()
					return
				end
			end
		end

		local lastButtonIndex

		if numProducts <= productsPerPage then
			lastButtonIndex = numProducts
		else
			lastButtonIndex = productsPerPage
		end

		for index = lastButtonIndex, 1, -1 do
			local button = self.productButtons[index]
			if button and button:IsShown() then
				self.RefreshFrame:ClearAllPoints()
				if index % self.productsPerRow == 0 then
					self.RefreshFrame:SetPoint("TOPLEFT", self.productButtons[1], "BOTTOMLEFT", 0, -25)
				else
					self.RefreshFrame:SetPoint("TOPLEFT", self.productButtons[index], "TOPRIGHT", 10, 0)
				end
				self.RefreshFrame:Show()

				return
			end
		end
	end

	self.RefreshFrame:Hide()
end

function StorePageCollectionsMixin:SetSubCategory(subCategoryIndex)
	self:SetSubCategoryIndex(subCategoryIndex)

	local categoryIndex = self:GetID()
	local numSubCategories = C_StoreSecure.GetNumSubCategories(categoryIndex)

	for index = 1, numSubCategories do
		local button = self.tabButtons[index]
		if not button then
			button = CreateFrame("Button", strformat("$parentTabButton%u", index), self, "StoreCategoryTabTemplate")
			button:SetID(index)
			button:SetIconSize(18)

			if index == 1 then
				button:SetPoint("TOPLEFT", self.PageHeader, "BOTTOMLEFT", 20, 0)
			else
				button:SetPoint("TOPLEFT", self.tabButtons[index - 1], "TOPRIGHT", -6, 0)
			end

			self.tabButtons[index] = button
		end

		local name, icon, isNew, enabled, reason = C_StoreSecure.GetCategoryInfo(categoryIndex, index)

		button.categoryIndex = categoryIndex
		button:SetText(name)
		button:SetIcon(icon, true, false)
		button:SetEnabled(enabled)
		button.reason = reason

		button:SetSelected(index == subCategoryIndex)
		button:UpdateState()
		button:Show()
	end

	for index = numSubCategories + 1, #self.tabButtons do
		self.tabButtons[index]:Hide()
	end

	self:UpdateProducts()
end

function StorePageCollectionsMixin:UpdateProducts()
	local subCategoryIndex = self:GetSubCategoryIndex()
	local numProducts = C_StoreSecure.GetNumCollectionProducts(subCategoryIndex)

	local productsPerPage = self.productsPerRow * self.numRows
	if self:CanRefreshList() then
		productsPerPage = productsPerPage - 1
	end

	self.Paginator:SetNumPages(math.ceil(numProducts / productsPerPage), true)
	local currentPage, numPages = self.Paginator:GetPage()
	self.Paginator:SetShown(numPages > 1)

	local offset = (currentPage - 1) * productsPerPage

	for index = 1, productsPerPage do
		local productIndex = index + offset
		local button = self.productButtons[index]

		if productIndex <= numProducts then
			if not button then
				button = CreateFrame("Button", strformat("$parentProduct%u", index), self, "StoreCollectionProductTemplate")
				button:SetOwner(self)

				if index == 1 then
					button:SetPoint("TOPLEFT", 20, -120)
				elseif index % self.productsPerRow == 1 then
					button:SetPoint("TOPLEFT", self.productButtons[index - self.productsPerRow], "BOTTOMLEFT", 0, -25)
				else
					button:SetPoint("TOPLEFT", self.productButtons[index - 1], "TOPRIGHT", 10, 0)
				end

				self.productButtons[index] = button
			end

			local productID = C_StoreSecure.GetCollectionProductID(subCategoryIndex, productIndex)

			button:SetID(productIndex)
			button:SetProductID(productID)
			button:Show()
		elseif button then
			button:Hide()
		end
	end

	for index = productsPerPage + 1, #self.productButtons do
		self.productButtons[index]:Hide()
	end

	self:AttachRefreshFrame()
	self.Loading:SetShown(not C_StoreSecure.IsCategoryProductsLoaded(self:GetID(), subCategoryIndex))
end

function StorePageCollectionsMixin:OnReRollClick(button)
	local productID = C_StoreSecure.GetRefreshCollectionProductID(self:GetSubCategoryIndex())
	assert(productID, "No product id for category refresh")
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

StorePageCollectionsTabMixin = CreateFromMixins(PKBT_TabButtonWithIconMixin, StoreCategoryButtonProtoMixin)

function StorePageCollectionsTabMixin:OnClick(button)
	if not self:IsSelected() then
		C_StoreSecure.SetSelectedCategory(self.categoryIndex, self:GetID())
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
end

function StorePageCollectionsTabMixin:OnMouseDown(button)
	PKBT_TabButtonWithIconMixin.OnMouseDown(self, button)
	StoreCategoryButtonProtoMixin.OnMouseDown(self, button)
end

function StorePageCollectionsTabMixin:OnMouseUp(button)
	PKBT_TabButtonWithIconMixin.OnMouseUp(self, button)
	StoreCategoryButtonProtoMixin.OnMouseUp(self, button)
end

function StorePageCollectionsTabMixin:UpdateState()
	if self:IsEnabled() ~= 1 then
		self.Icon:SetVertexColor(0.553, 0.522, 0.494)
		self.ButtonText:SetTextColor(0.553, 0.522, 0.494)
	elseif self:IsSelected() then
		self.Icon:SetVertexColor(1, 0.82, 0)
		self.ButtonText:SetTextColor(1, 0.82, 0)
	else
		self.Icon:SetVertexColor(1, 1, 1)
		self.ButtonText:SetTextColor(1, 1, 1)
	end
end

StoreSpecialPageServicesMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin)

function StoreSpecialPageServicesMixin:OnLoad()
	self:SetID(Enum.Store.Category.SpecialServices)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StoreSpecialPageServicesMixin:OnShow()
	self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList):SetParentPage(self)
	local _, subCategoryIndex = C_StoreSecure.GetSelectedCategory()
	self:SetSubCategory(subCategoryIndex)
end

function StoreSpecialPageServicesMixin:SetSubCategory(subCategoryIndex)
	self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList):SetViewCategory(self:GetID(), subCategoryIndex)
end

StorePageSubscriptionsMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin)

function StorePageSubscriptionsMixin:OnLoad()
	self.subscriptionPanels = {}
	self.subscriptionsPerRow = 3
	self.FRAME_PADDING = 30

	self:RegisterCustomEvent("STORE_SUBSCRIPTION_LIST_LOADING")
	self:RegisterCustomEvent("STORE_SUBSCRIPTION_LIST_UPDATE")

	self:SetID(Enum.Store.Category.Subscriptions)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StorePageSubscriptionsMixin:OnShow()
	SetParentFrameLevel(self.Loading, 10)
	self:SetViewIndex(self:GetSubCategoryIndex())
end

function StorePageSubscriptionsMixin:OnEvent(event, ...)
	if event == "STORE_SUBSCRIPTION_LIST_UPDATE" then
		if self:GetSubCategoryIndex() == 0 then
			self:UpdateSubscriptions()
		else
			local subscriptionID = self.ViewDetailsFrame.subscriptionID
			local subscriptionIndex = subscriptionID and C_StoreSecure.GetSubscriptionIndexByID(subscriptionID)
			if subscriptionIndex == self:GetSubCategoryIndex() then
				self:UpdateViewDetails()
			else
				self:SetSubCategoryIndex(0)
			end
		end
	elseif event == "STORE_SUBSCRIPTION_LIST_LOADING" then
		local isLoading = ...
		self.Loading:SetShown(isLoading)
	end
end

function StorePageSubscriptionsMixin:SetSubCategoryIndex(subCategoryIndex)
	StoreCategoryPagesMixin.SetSubCategoryIndex(self, subCategoryIndex)
	self:SetViewIndex(subCategoryIndex)
end

function StorePageSubscriptionsMixin:SetViewIndex(subCategoryIndex)
	if not subCategoryIndex then
		subCategoryIndex = self:GetSubCategoryIndex()
	end

	self.Loading:SetShown(not C_StoreSecure.IsSubscriptionsLoaded())
	self.ListScrollFrame:SetShown(subCategoryIndex == 0)
	self.ViewDetailsFrame:SetShown(subCategoryIndex ~= 0)

	if subCategoryIndex == 0 then
		self.PageHeader:SetLabel(STORE_SUBSCRIPTIONS_TITLE)
		self:UpdateSubscriptions()
		self.ViewDetailsFrame.subscriptionID = nil
	else
		C_StoreSecure.SetSelectedCategory(self:GetID(), subCategoryIndex)
		self:UpdateViewDetails()
	end
end

function StorePageSubscriptionsMixin:UpdateViewDetails()
	self.ViewDetailsFrame:SetSubscriptionIndex(self:GetSubCategoryIndex())
end

function StorePageSubscriptionsMixin:UpdateSubscriptions()
	local numSubscriptions = C_StoreSecure.GetNumSubscriptions()
	for index = 1, numSubscriptions do
		local panel = self.subscriptionPanels[index]
		if not panel then
			panel = CreateFrame("Button", strformat("$parentSubscription%u", index), self.ListScrollFrame.ScrollChild, "StoreSubscriptionPanelTemplate")
			panel:SetOwner(self)
			panel:SetID(index)

			if index == 1 then
				panel:SetPoint("TOPLEFT", self.FRAME_PADDING, -self.FRAME_PADDING)
			elseif index % self.subscriptionsPerRow == 1 then
				panel:SetPoint("TOPLEFT", self.subscriptionPanels[index - self.subscriptionsPerRow], "BOTTOMLEFT", 0, -self.FRAME_PADDING)
			else
				panel:SetPoint("TOPLEFT", self.subscriptionPanels[index - 1], "TOPRIGHT", self.FRAME_PADDING, 0)
			end

			self.subscriptionPanels[index] = panel
		end

		panel:UpdateSubscriptionInfo()
		panel:Show()
	end

	for index = numSubscriptions + 1, #self.subscriptionPanels do
		self.subscriptionPanels[index]:Hide()
	end

	if numSubscriptions > 0 then
		local numRows = math.ceil(numSubscriptions / self.subscriptionsPerRow)
		self.ListScrollFrame.ScrollChild:SetSize(self.ListScrollFrame:GetWidth(), (self.subscriptionPanels[1]:GetHeight() + self.FRAME_PADDING) * numRows + self.FRAME_PADDING)
		self.ListScrollFrame:UpdateScrollChildRect()
	end
end

local SUBSCRIPTION_STYLE_TYPE = {
	[1] = "Bronze",
	[2] = "Silver",
	[3] = "MetalBlack",
}

StoreSubscriptionPanelMixin = CreateFromMixins(PKBT_OwnerMixin, PKBT_CountdownThrottledBaseMixin)

function StoreSubscriptionPanelMixin:OnLoad()
	self.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)

	self.PurchaseButton:SetMinWidth(120)
	self.PurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)
	self.PurchaseButton.Price:SetFreeText(STORE_BUY_FREE_TRIAL)

	self.PurchaseButton.Glow.Left:SetAtlas("PKBT-Button-Glow-Left", true)
	self.PurchaseButton.Glow.Right:SetAtlas("PKBT-Button-Glow-Right", true)
	self.PurchaseButton.Glow.Center:SetAtlas("PKBT-Button-Glow-Center")

	self.itemButtons = {}
	self.ITEM_PADDING = 10

	Mixin(self.NineSliceBorder, NineSlicePanelMixin)
end

function StoreSubscriptionPanelMixin:DetailsOnClick(button)
	self:GetOwner():ShowSubCategoryPage(self:GetID())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function StoreSubscriptionPanelMixin:PurchaseOnClick(this, button)
	if this.productID then
		C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(this.productID)
	else
		local days, isTrial, price, originalPrice, currencyType, productID = C_StoreSecure.GetSubscriptionOptionInfo(self:GetID(), this.optionIndex)
		if isTrial then
			self.PurchaseButton:ShowSpinner()
			self.PurchaseButton:Disable()
			C_StoreSecure.PurchaseSubcription(self:GetID(), this.optionIndex)
		else
			C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(productID)
		end
	end
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreSubscriptionPanelMixin:SetStyle(styleType)
	local styleName = SUBSCRIPTION_STYLE_TYPE[styleType]

	self.NineSliceBorder:SetAttribute("layoutType", strformat("PKBT_Panel%sBorder", styleName))
	NineSlicePanelMixin.OnLoad(self.NineSliceBorder)

	self.NineSliceBorder.Title.Left:SetAtlas(strformat("PKBT-Panel-%s-Header-Left", styleName), true)
	self.NineSliceBorder.Title.Right:SetAtlas(strformat("PKBT-Panel-%s-Header-Right", styleName), true)
	self.NineSliceBorder.Title.Center:SetAtlas(strformat("PKBT-Panel-%s-Header-Center", styleName))
	self.NineSliceBorder.Title.Left:SetSize(83, 35)
	self.NineSliceBorder.Title.Right:SetSize(83, 35)
end

function StoreSubscriptionPanelMixin:UpdateSubscriptionInfo()
	local subscriptionID, name, description, styleType, backgroundAtlas, bannerAtlas, artworkAtlas = C_StoreSecure.GetSubscriptionInfo(self:GetID())
	local state, upgradeTimeLeft, nextSupplyTimeLeft, remainingSupplyTimes = C_StoreSecure.GetSubscriptionState(self:GetID())
	local itemList = C_StoreSecure.GetSubscriptionItems(self:GetID(), false)

	local numItems = #itemList
	for index = 1, numItems do
		local item = self.itemButtons[index]
		if not item then
			item = CreateFrame("Button", strformat("$parentItemButton%u", index), self, "StoreSubscriptionItemTemplate")
			item:SetID(index)
			item:SetOwner(self)

			if index == 1 then
				item:SetPoint("LEFT", self.ItemHolder, "LEFT", 0, 0)
			else
				item:SetPoint("LEFT", self.itemButtons[index - 1], "RIGHT", self.ITEM_PADDING, 0)
			end

			self.itemButtons[index] = item
		end

		local itemID, amount, isBonus = unpack(itemList[index])
		local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)

		item.Icon:SetTexture(texture)
		item.Amount.Value:SetText(amount)
		item.link = link
		item:Show()
	end

	for index = numItems + 1, #self.itemButtons do
		self.itemButtons[index]:Hide()
	end

	if numItems > 0 then
		self.ItemHolder:SetWidth(self.itemButtons[1]:GetWidth() * numItems + self.ITEM_PADDING * (numItems - 1))
	end

	self:SetStyle(styleType)

	self.NineSliceBorder.Title.maxWidth = self:GetWidth() - 60
	self.NineSliceBorder.Title:SetText(name)

	self.Background:SetAtlas(bannerAtlas)

	if state == Enum.Store.SubscriptionState.InactiveTrialAvailable then
		local days, isTrial, price, originalPrice, currencyType, productID = C_StoreSecure.GetSubscriptionOptionInfo(self:GetID(), 1)
		self.PurchaseButton:SetPrice(price, originalPrice, Enum.Store.CurrencyType.Bonus)
		self.PurchaseButton.optionIndex = 0
		self.PurchaseButton:Show()

		self.DetailsButton:ClearAllPoints()
		self.DetailsButton:SetPoint("LEFT", self.ButtonHolder, "LEFT", 0, 0)
	else
		self.PurchaseButton.optionIndex = nil
		self.PurchaseButton:Hide()

		self.DetailsButton:ClearAllPoints()
		self.DetailsButton:SetPoint("CENTER", self.ButtonHolder, "CENTER", 0, 0)
	end

	if state == Enum.Store.SubscriptionState.Inactive
	or state == Enum.Store.SubscriptionState.InactiveTrialAvailable
	then
		self.InfoText:SetPoint("TOP", 0, -45)
		self.InfoText:SetFormattedText("%s:", STORE_SUBSCRIPTION_INFO)
		self.InfoText:SetTextColor(1, 1, 1)
		self.TimerIcon:Hide()

		self:SetNextSupplyCountdown(0)

		self.PurchaseButton.Glow.AlphaAnim:Stop()
		self.PurchaseButton.Glow:Hide()
	else
		self.InfoText:SetPoint("TOP", 0, -34)
		self.InfoText:SetText(STORE_SUBSCRIPTION_RENEW)
		self.InfoText:SetTextColor(1, 1, 1)
		self.TimerIcon:Show()

		if self.PurchaseButton.Glow.AlphaAnim:IsPlaying() then
			self.PurchaseButton.Glow.AlphaAnim:Stop()
		end
		self.PurchaseButton.Glow.AlphaAnim:Play()
		self.PurchaseButton.Glow:Show()

		self:SetNextSupplyCountdown(nextSupplyTimeLeft)
	end

	self.PurchaseButton:Enable()
	self.PurchaseButton:HideSpinner()
	self.ButtonHolder:SetWidth(self.DetailsButton:GetWidth() + 10 + self.PurchaseButton:GetWidth())
end

function StoreSubscriptionPanelMixin:SetNextSupplyCountdown(timeLeft)
	self:SetTimeLeft(timeLeft)
end

function StoreSubscriptionPanelMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.SupplyCountdown:SetText(GetRemainingTime(timeLeft))
		self.SupplyCountdown:Show()
	else
		self.SupplyCountdown:Hide()

		self.InfoText:SetPoint("TOP", 0, -45)
		self.InfoText:SetFormattedText("%s:", STORE_SUBSCRIPTION_INFO)
		self.InfoText:SetTextColor(1, 1, 1)
		self.TimerIcon:Hide()

		if timerFinished then
			self:UpdateSubscriptionInfo()
		end
	end
end

StoreSubscriptionTitleMixin = {}

function StoreSubscriptionTitleMixin:OnShow()
	self:UpdateSize()
end

function StoreSubscriptionTitleMixin:UpdateSize()
	self:SetWidth(min(max(self.Text:GetStringWidth() + 100, self.minWidth or 0), self.maxWidth or math.huge))
end

function StoreSubscriptionTitleMixin:SetText(...)
	self.Text:SetText(...)
	self:UpdateSize()
end

function StoreSubscriptionTitleMixin:SetFormattedText(...)
	self.Text:SetFormattedText(...)
	self:UpdateSize()
end

StoreSubscriptionItemMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreSubscriptionItemMixin:OnLoad()
	self.IconGlow:SetAtlas("PKBT-ItemBorder-Gold")

	self.Amount.Left:SetAtlas("PKBT-Input-Digit-Background-Left", true)
	self.Amount.Right:SetAtlas("PKBT-Input-Digit-Background-Right", true)
	self.Amount.Center:SetAtlas("PKBT-Input-Digit-Background-Center", true)
end

function StoreSubscriptionItemMixin:OnClick(button)
	if IsAltKeyDown() and C_StoreSecure.AddItem(self.link) then
		return
	end
	if self.link then
		if IsModifiedClick("DRESSUP") then
			local allowToHide, allowEquipmentToggle, allowPortraitCamera = true, true, false
			C_StoreSecure.GetStoreFrame():ShowItemDressUp(self:GetOwner(), self.link, allowToHide, allowEquipmentToggle, allowPortraitCamera)
		elseif IsModifiedClick("CHATLINK") then
			if ChatEdit_InsertLink(self.link) then
				return true
			end
		end
	end
end

function StoreSubscriptionItemMixin:OnEnter()
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end
end

function StoreSubscriptionItemMixin:OnLeave()
	GameTooltip:Hide()
end

StoreSubscriptionViewDetailsMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function StoreSubscriptionViewDetailsMixin:OnLoad()
	self.UpgradeTimerIcon:SetAtlas("PKBT-Icon-Timer", true)

	self.UpgradeTimerText:SetPoint("LEFT", self:GetParent().HeaderText, "RIGHT", 60, -1)

	self.SubscriptionFrame.Background:SetAtlas("PKBT-Store-Subscription-Pack-Background")

	self.SubscriptionFrame.ShadowTopLeft:SetAtlas("PKBT-Vignette-Shadow-TopLeft", true)
	self.SubscriptionFrame.ShadowTopRight:SetAtlas("PKBT-Vignette-Shadow-TopRight", true)
	self.SubscriptionFrame.ShadowBottomLeft:SetAtlas("PKBT-Vignette-Shadow-BottomLeft", true)
	self.SubscriptionFrame.ShadowBottomRight:SetAtlas("PKBT-Vignette-Shadow-BottomRight", true)

	self.SubscriptionFrame.NineSliceBorder.Title.maxWidth = self.SubscriptionFrame:GetWidth() - 60
	self.SubscriptionFrame.NineSliceBorder.Title:SetText(STORE_SUBSCRIPTION_INFO)

	self.SubscriptionFrame.NineSliceBorder.UpgradeBonus:SetScale(0.65)
	self.SubscriptionFrame.NineSliceBorder.UpgradeBonus.Artwork:SetAtlas("PKBT-Store-Subscription-Pack-Special-Button", true)
	self.SubscriptionFrame.NineSliceBorder.UpgradeBonus.Glow:SetAtlas("PKBT-ItemBorder-Gold-Glow")

	self.SubscriptionFrame.NextPackegeTimerIcon:SetAtlas("PKBT-Icon-Timer", true)

	self.UpgradeMultiplierInactiveIcon:SetAtlas("PKBT-Icon-Help-i", true)
	self.UpgradeMultiplierInactiveText:SetPoint("TOP", self.UpgradePurchaseButton, "BOTTOM", math.ceil(self.UpgradeMultiplierInactiveIcon:GetWidth() / 2), -10)

	self.UpgradePurchaseButton:SetFixedWidth(360)
	self.UpgradePurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)
	self.UpgradePurchaseButton:AddText(STORE_SUBSCRIPTION_EXTRA_UPGRADE, nil, nil, "PKBT_Font_18")

	Mixin(self.SubscriptionFrame, PKBT_CountdownThrottledBaseMixin)
	Mixin(self.SubscriptionFrame.NineSliceBorder, NineSlicePanelMixin)

	self.itemButtons = {}
	self.subscriptionOptionsButtons = {}

	self.subscriptionIndex = 0
end

function StoreSubscriptionViewDetailsMixin:OnShow()
	SetParentFrameLevel(self.SubscriptionFrame.NineSliceBorder, 1)
	SetParentFrameLevel(self.SubscriptionFrame.NineSliceBorder.Title, 2)
	SetParentFrameLevel(self.SubscriptionFrame.NineSliceBorder.UpgradeBonus, 2)
	SetParentFrameLevel(self.SubscriptionFrame.NineSliceGlow, 2)
end

function StoreSubscriptionViewDetailsMixin:SetSubscriptionIndex(index)
	self.subscriptionIndex = index
	self:UpdateAll()
end

function StoreSubscriptionViewDetailsMixin:GetSubscriptionIndex()
	return self.subscriptionIndex
end

function StoreSubscriptionViewDetailsMixin:UpdateAll()
	self:UpdateView()
	self:UpdateState()
end

function StoreSubscriptionViewDetailsMixin:SetStyle(styleType)
	local styleName = SUBSCRIPTION_STYLE_TYPE[styleType]

	self.SubscriptionFrame.NineSliceBorder.Title.Left:SetAtlas(strformat("PKBT-Panel-%s-Header-Left", styleName), true)
	self.SubscriptionFrame.NineSliceBorder.Title.Right:SetAtlas(strformat("PKBT-Panel-%s-Header-Right", styleName), true)
	self.SubscriptionFrame.NineSliceBorder.Title.Center:SetAtlas(strformat("PKBT-Panel-%s-Header-Center", styleName))
	self.SubscriptionFrame.NineSliceBorder.Title.Left:SetSize(83, 35)
	self.SubscriptionFrame.NineSliceBorder.Title.Right:SetSize(83, 35)

	self.SubscriptionFrame.NineSliceBorder.Title.DecorTop:SetAtlas(strformat("PKBT-Panel-%s-Deacor-Header", styleName), true)
	self.SubscriptionFrame.NineSliceBorder.Title.DecorBottom:SetAtlas(strformat("PKBT-Panel-%s-Deacor-Footer", styleName), true)

	self.SubscriptionFrame.NineSliceBorder.DecorFooter:SetAtlas(strformat("PKBT-Panel-%s-Deacor-Header", styleName), true)
	self.SubscriptionFrame.NineSliceBorder.DecorFooter:SetSubTexCoord(0, 1, 1, 0)
end

function StoreSubscriptionViewDetailsMixin:UpdateState()
	local subscriptionIndex = self:GetSubscriptionIndex()

	local upgradeMultiplier, upgradeCurrency, upgradePrice, upgradeOriginalPrice, upgradeProductID = C_StoreSecure.GetSubscriptionUpgradeInfo(subscriptionIndex)
	local state, upgradeTimeLeft, nextSupplyTimeLeft, remainingSupplyTimes = C_StoreSecure.GetSubscriptionState(subscriptionIndex)

	local numSubscriptionOptions = C_StoreSecure.GetNumSubscriptionOptions(subscriptionIndex)
	for optionIndex = 1, numSubscriptionOptions do
		local button = self.subscriptionOptionsButtons[optionIndex]
		if not button then
			button = CreateFrame("Button", strformat("$parentPurchaseButton%u", optionIndex), self, "PKBT_RedButtonMultiWidgetPriceTemplate")
			button:SetID(optionIndex)
			button:SetHeight(72)
			button:SetFixedWidth(360)
			button:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)
			button.Price:SetFreeText("")

			button:SetScript("OnClick", function(this, b)
				self:PurchaseOnClick(this, b)
			end)

			self.subscriptionOptionsButtons[optionIndex] = button

			if optionIndex ~= 1 then
				button:SetPoint("TOP", self.subscriptionOptionsButtons[optionIndex - 1], "BOTTOM", 0, -10)
			end
		end

		if optionIndex == 1 then
			local offsetY
			if state == Enum.Store.SubscriptionState.StandardActive then
				offsetY = -55
			elseif state == Enum.Store.SubscriptionState.InactiveTrialAvailable then
				offsetY = -160
			else
				offsetY = -110
			end
			button:SetPoint("TOP", self.SubscriptionFrame, "BOTTOM", 0, offsetY)
		end

		local days, isTrial, price, originalPrice, currencyType, productID = C_StoreSecure.GetSubscriptionOptionInfo(subscriptionIndex, optionIndex)
		button:ClearObjects()
		if isTrial then
			button:AddText(STORE_TRY_FOR_FREE, nil, nil, "PKBT_Font_18")
		elseif state == Enum.Store.SubscriptionState.Inactive then
			button:AddText(strformat(STORE_SUBSCRIPTION_PURCHASE_DAYS, days), nil, nil, "PKBT_Font_18")
		else
			button:AddText(strformat(STORE_SUBSCRIPTION_PURCHASE_EXTEND_DAYS, days), nil, nil, "PKBT_Font_18")
		end
		button:SetPrice(price, originalPrice, currencyType)
		button.productID = productID
		button:Show()
	end

	for index = numSubscriptionOptions + 1, #self.subscriptionOptionsButtons do
		self.subscriptionOptionsButtons[index]:Hide()
	end

	if state == Enum.Store.SubscriptionState.ExtraActive then
		self.SubscriptionFrame.UpgradeMultiplierActiveText:SetFormattedText(STORE_SUBSCRIPTION_EXTRA_MULT_ACTIVE, upgradeMultiplier)
		self.SubscriptionFrame.UpgradeMultiplierActiveText:Show()

		self.UpgradeMultiplierInactiveText:Hide()
		self.UpgradeMultiplierInactiveIcon:Hide()

		self.SubscriptionFrame.NineSliceGlow:Show()
		self.SubscriptionFrame.NineSliceGlow.AlphaAnim:Stop()
		self.SubscriptionFrame.NineSliceGlow.AlphaAnim:Play()

		if upgradeMultiplier > 1 then
			self.SubscriptionFrame.NineSliceBorder.UpgradeBonus:Show()
			self.SubscriptionFrame.NineSliceBorder.UpgradeBonus.Glow.AlphaAnim:Stop()
			self.SubscriptionFrame.NineSliceBorder.UpgradeBonus.Glow.AlphaAnim:Play()
		else
			self.SubscriptionFrame.NineSliceBorder.UpgradeBonus:Hide()
		end

		self.SubscriptionFrame.NineSliceBorder.UpgradeBonus.Multiplier:SetAtlas("PKBT-Store-Subscription-Pack-Special-x2", true)

		self.UpgradePurchaseButton.productID = nil
		self.UpgradePurchaseButton:Hide()
	else
		self.SubscriptionFrame.UpgradeMultiplierActiveText:Hide()
		self.SubscriptionFrame.NineSliceBorder.UpgradeBonus:Hide()

		self.SubscriptionFrame.NineSliceGlow:Hide()
		self.SubscriptionFrame.NineSliceGlow.AlphaAnim:Stop()

		self.SubscriptionFrame.NineSliceBorder.UpgradeBonus:Hide()
		self.SubscriptionFrame.NineSliceBorder.UpgradeBonus.Glow.AlphaAnim:Stop()

		if state == Enum.Store.SubscriptionState.StandardActive then
			self.UpgradePurchaseButton:SetPoint("TOP", self.subscriptionOptionsButtons[numSubscriptionOptions], "BOTTOM", 0, -10)
			self.UpgradePurchaseButton:SetPrice(upgradePrice, upgradeOriginalPrice, upgradeCurrency)
			self.UpgradePurchaseButton.productID = upgradeProductID
			self.UpgradePurchaseButton:Show()

			if upgradeMultiplier > 1 then
				self.UpgradeMultiplierInactiveText:SetFormattedText(STORE_SUBSCRIPTION_EXTRA_MULT_INACTIVE, upgradeMultiplier)
				self.UpgradeMultiplierInactiveText:Show()
				self.UpgradeMultiplierInactiveIcon:Show()
			else
				self.UpgradeMultiplierInactiveText:Hide()
				self.UpgradeMultiplierInactiveIcon:Hide()
			end
		else
			self.UpgradePurchaseButton.productID = nil
			self.UpgradePurchaseButton:Hide()

			self.UpgradeMultiplierInactiveText:Hide()
			self.UpgradeMultiplierInactiveIcon:Hide()
		end
	end

	self:SetTimeLeft(upgradeTimeLeft, nil, self.OnUpgradeCountdownUpdate)
	self.SubscriptionFrame:SetTimeLeft(nextSupplyTimeLeft, nil, self.OnPackageCountdownUpdate)
	self.SubscriptionFrame.TotalPackegeLeftText:SetFormattedText(STORE_SUBSCRIPTION_AMOUNT_PACKAGE_LEFT, remainingSupplyTimes)
end

function StoreSubscriptionViewDetailsMixin:OnUpgradeCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.UpgradeTimerText:SetFormattedText(STORE_SUBSCRIPTION_EXTRA_TIMELEFT, GetRemainingTime(timeLeft))
		self.UpgradeTimerText:Show()
		self.UpgradeTimerIcon:Show()
	else
		self.UpgradeTimerText:Hide()
		self.UpgradeTimerIcon:Hide()

		if timerFinished then
			self:UpdateState()
		end
	end
end

function StoreSubscriptionViewDetailsMixin.OnPackageCountdownUpdate(this, timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		this.NextPackegeTimerText:SetFormattedText(STORE_SUBSCRIPTION_NEXT_PACKAGE_TIMELEFT, GetRemainingTime(timeLeft))
		this.NextPackegeTimerText:Show()
		this.NextPackegeTimerIcon:Show()
		this.TotalPackegeLeftText:Show()
	else
		this.NextPackegeTimerText:Hide()
		this.NextPackegeTimerIcon:Hide()
		this.TotalPackegeLeftText:Hide()

		if timerFinished then
			this:GetParent():UpdateAll()
		end
	end
end

function StoreSubscriptionViewDetailsMixin:UpdateView()
	local subscriptionIndex = self:GetSubscriptionIndex()
	local subscriptionID, name, description, styleType, backgroundAtlas, bannerAtlas, artworkAtlas = C_StoreSecure.GetSubscriptionInfo(subscriptionIndex)
	local itemList = C_StoreSecure.GetSubscriptionItems(subscriptionIndex, true)

	local state, upgradeTimeLeft, nextSupplyTimeLeft, remainingSupplyTimes = C_StoreSecure.GetSubscriptionState(subscriptionIndex)
	local hasBonusItem

	self.subscriptionID = subscriptionID
	self:GetParent().PageHeader:SetLabel(name)

	local numItems = #itemList
	local itemPadding = 0

	for index = 1, numItems do
		local item = self.itemButtons[index]
		if not item then
			item = CreateFrame("Button", strformat("$parentItemButton%u", index), self.SubscriptionFrame, "StoreSubscriptionViewItemTemplate")
			item:SetID(index)
			item:SetOwner(self)

			if index == 1 then
				item:SetPoint("LEFT", self.SubscriptionFrame.ItemHolder, "LEFT", 0, 0)
			end

			self.itemButtons[index] = item
		end

		if index ~= 1 then
			if itemPadding == 0 then
				itemPadding = item.Name:GetWidth() - item:GetWidth() + 4
			end
			item:SetPoint("LEFT", self.itemButtons[index - 1], "RIGHT", itemPadding, 0)
		end

		local itemID, amount, isBonusItem = unpack(itemList[index])
		local itemName, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)

		item.Name:SetText(itemName)
		item.Icon:SetTexture(texture)
		item.IconGlow:SetShown(isBonusItem)
		item.BonusText:SetShown(isBonusItem)
		item.Amount.Value:SetText(amount)
		item.link = link
		item:Show()

		if isBonusItem then
			hasBonusItem = true
		end
	end

	for index = numItems + 1, #self.itemButtons do
		self.itemButtons[index]:Hide()
	end

	if numItems > 0 then
		self.SubscriptionFrame.ItemHolder:SetWidth(self.itemButtons[1]:GetWidth() * numItems + itemPadding * (numItems - 1))
	end

	if hasBonusItem and upgradeTimeLeft and upgradeTimeLeft > 0 then
		self.SubscriptionFrame.ItemHolder:SetPoint("CENTER", 0, -2)
	else
		self.SubscriptionFrame.ItemHolder:SetPoint("CENTER", 0, 7)
	end

	self:SetStyle(styleType)
	self.Description:SetText(description)

	if C_Texture.HasAtlasInfo(backgroundAtlas) then
		self.Background:SetAtlas(backgroundAtlas, true)
		self.Background:Show()
	else
		self.Background:Hide()
	end
end

function StoreSubscriptionViewDetailsMixin:PurchaseOnClick(this, button)
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(this.productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreSubscriptionViewDetailsMixin:UpgradePurchaseOnClick(this, button)
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(this.productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

StorePageTransmogrificationMixin = CreateFromMixins(PKBT_OwnerMixin, StoreCategoryPagesMixin, PKBT_CountdownThrottledBaseMixin)

function StorePageTransmogrificationMixin:OnLoad()
	self.List.PageHeader.Background:SetSubTexCoord(0, 1, 1, 0)

	self.List.PageHeader.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)
	self.List.OfferHeader.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)

	self.List.RefreshButton:SetParent(self.List.PageHeader)
	self.List.RefreshButton:AddTextureAtlas("PKBT-Icon-Refresh", true)
	self.List.RefreshButton:AddText(STORE_REFRESH_PRODUCTS)

	self.List.Separator:SetParent(self.List.Scroll.ScrollChild)

	Mixin(self.List.OfferHeader, PKBT_OwnerMixin, PKBT_CountdownThrottledBaseMixin)
	self.List.OfferHeader:SetOwner(self)
	self.List.OfferHeader:SetParent(self.List.Scroll.ScrollChild)

	self.List.OfferHeader.OnCountdownUpdate = function(this, timeLeft, timerFinished)
		if timeLeft > 0 and not timerFinished then
			self.List.OfferHeader.Timer:SetFormattedText(STORE_REFRESH_PRODUCTS_INFO_SHORT_FORMAT, GetRemainingTime(timeLeft))
			self.List.OfferHeader.Timer:Show()
			self.List.OfferHeader.TimerIcon:Show()
		else
			self.List.OfferHeader.Timer:Hide()
			self.List.OfferHeader.TimerIcon:Hide()

			if timerFinished then
				C_StoreSecure.RequestNextTransmogOfferTime()
				self:UpdateOfferInfo()
			end
		end
	end

	self.OfferDressUp:SetOwner(self)
	self.OfferDressUp:SetRotateEnabled(true)
--	self.OfferDressUp:SetZoomEnabled(true)
--	self.OfferDressUp:SetPanningEnabled(true)

	self.subCategoryButtons = {}
	self.offerButtons = {}
	self.setOfferButtons = {}

	if not TRANSMOG_REROLL_BUTTON_ON_MAIN_PAGE then
		self.List.RefreshButton:Hide()
	end

	self:RegisterCustomEvent("STORE_RANDOM_ITEM_POLL_UPDATE")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_RENEW")
	self:RegisterCustomEvent("STORE_TRANSMOG_OFFER_UPDATE")
	self:RegisterCustomEvent("STORE_TRANSMOG_OFFER_RENEW")
	self:RegisterCustomEvent("STORE_TRANSMOG_OFFER_NEXT_TIMER_READY")
	self:RegisterCustomEvent("STORE_TRANSMOG_OFFER_NEXT_TIMER_WAIT")

	self:SetID(Enum.Store.Category.Transmogrification)
	self:SetOwner(self:GetParent():GetParent())
	self:GetOwner():RegisterPageWidget(self)
end

function StorePageTransmogrificationMixin:OnEvent(event, ...)
	if not self:IsVisible() then
		return
	end

	if event == "STORE_RANDOM_ITEM_POLL_UPDATE" then
		if self:GetSubCategoryIndex() == 0 then
			self:UpdateTransmogRefreshTimer()
		end
	elseif event == "STORE_PRODUCT_LIST_RENEW" then
		local categoryIndex, subCategoryIndex = ...
		if categoryIndex == Enum.Store.Category.Transmogrification then
			self:UpdateOfferInfo()
		end
	elseif event == "STORE_TRANSMOG_OFFER_UPDATE"
	or event == "STORE_TRANSMOG_OFFER_RENEW"
	or event == "STORE_TRANSMOG_OFFER_NEXT_TIMER_READY"
	or event == "STORE_TRANSMOG_OFFER_NEXT_TIMER_WAIT"
	then
		self:UpdateOfferInfo()
	end
end

function StorePageTransmogrificationMixin:OnShow()
	local subCategoryIndex = self:GetSubCategoryIndex()

	self.List:SetShown(subCategoryIndex == 0)
	self.OfferDressUp:SetShown(subCategoryIndex == 0)
	self:GetOwner():HideContentLayers()

	if subCategoryIndex == 0 then
		if not self.initialized then
			local name, icon, isNew, enabled, reason = C_StoreSecure.GetCategoryInfo(self:GetID())
			self.List.PageHeader:SetLabel(name)

			self.initialized = true
		end

		self.List.Scroll:SetVerticalScroll(0)

		self:UpdateTransmogRefreshTimer()
		self:UpdateOfferInfo()
	else
		local itemListView = self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList)
		itemListView:SetParentPage(self)
		itemListView:SetViewCategory(self:GetID(), subCategoryIndex)
	end
end

function StorePageTransmogrificationMixin:OnHide()
	self:GetOwner():ShowContentLayers()
end

function StorePageTransmogrificationMixin:UpdateOfferInfo()
	self:UpdateTransmogOfferRefreshTimer()
	self:UpdateOffers()
	self:UpdateItemSetOffer()
end

function StorePageTransmogrificationMixin:UpdateTransmogRefreshTimer()
	local timeLeft, isRefreshAvailable = C_StoreSecure.GetTransmogRefrestTimeLeft()
	if timeLeft > 0 then
		self.List.RefreshButton:SetEnabled(isRefreshAvailable)
	else
		self.List.RefreshButton:Disable()
	end
	self:SetTimeLeft(isRefreshAvailable and timeLeft or 0)
end

function StorePageTransmogrificationMixin:UpdateTransmogOfferRefreshTimer()
	local transmogOfferTimeLeft = C_StoreSecure.GetNextTransmogOfferTimeLeft()
	self.List.OfferHeader:SetTimeLeft(transmogOfferTimeLeft or 0)
end

function StorePageTransmogrificationMixin:OnReRollClick(button)
	local productID = C_StoreSecure.GetRefreshTransmogProductID()
	assert(productID, "No product id for category refresh")
	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StorePageTransmogrificationMixin:OnCountdownUpdate(timeLeft, timerFinished)
	if timeLeft > 0 and not timerFinished then
		self.List.PageHeader.Timer:SetFormattedText(STORE_REFRESH_PRODUCTS_INFO_SHORT_FORMAT, GetRemainingTime(timeLeft))
		self.List.PageHeader.Timer:Show()
		self.List.PageHeader.TimerIcon:Show()
	else
		self.List.PageHeader.Timer:Hide()
		self.List.PageHeader.TimerIcon:Hide()
	end
end

local TRANSMOG_SCROLL_PADDING = 25

local TRANSMOG_TYPES_PER_ROW = 2
local TRANSMOG_TYPES_OFFSET_X = 20
local TRANSMOG_TYPES_OFFSET_Y = 20

local TRANSMOG_OFFERS_PER_ROW = 2
local TRANSMOG_OFFERS_OFFSET_X = 20
local TRANSMOG_OFFERS_OFFSET_Y = 0

local TRANSMOG_SEPARATOR_OFFSET_Y = 25

function StorePageTransmogrificationMixin:UpdateOffers()
	local numTransmogSubCategories = C_StoreSecure.GetNumTransmogSubCategories()
	for transmogTypeIndex = 1, numTransmogSubCategories do
		local button = self.subCategoryButtons[transmogTypeIndex]
		if not button then
			button = CreateFrame("Frame", strformat("$parentSubCategoryButton%u", transmogTypeIndex), self.List.Scroll.ScrollChild, "StoreTransmogSubCategoryButtonTemplate")
			button:SetOwner(self)
			button:SetID(transmogTypeIndex)
			button:UpdateInfo()

			if transmogTypeIndex == 1 then
				button:SetPoint("TOPLEFT", TRANSMOG_SCROLL_PADDING, -TRANSMOG_SCROLL_PADDING)
			elseif transmogTypeIndex % TRANSMOG_TYPES_PER_ROW == 1 then
				button:SetPoint("TOPLEFT", self.subCategoryButtons[transmogTypeIndex - TRANSMOG_TYPES_PER_ROW], "BOTTOMLEFT", 0, -TRANSMOG_TYPES_OFFSET_Y)
			else
				button:SetPoint("TOPLEFT", self.subCategoryButtons[transmogTypeIndex - 1], "TOPRIGHT", TRANSMOG_TYPES_OFFSET_X, 0)
			end

			self.subCategoryButtons[transmogTypeIndex] = button
		end

		button:Show()
	end

	for transmogTypeIndex = numTransmogSubCategories + 1, #self.subCategoryButtons do
		self.subCategoryButtons[transmogTypeIndex]:Hide()
	end

	local categoryIndex = self:GetID()
	local subCategoryIndex = self:GetSubCategoryIndex()
	local isLoading = not C_StoreSecure.IsCategoryProductsLoaded(categoryIndex, subCategoryIndex)

	local numTransmogOffers = C_StoreSecure.GetNumTransmogOffers()
	for transmogOfferIndex = 1, numTransmogOffers do
		local button = self.offerButtons[transmogOfferIndex]
		if not button then
			button = CreateFrame("Button", strformat("$parentTransmogOfferButton%u", transmogOfferIndex), self.List.Scroll.ScrollChild, "StoreTransmogOfferButtonTemplate")
			button:SetOwner(self)
			button:SetID(transmogOfferIndex)

			if transmogOfferIndex == 1 then
				button:SetPoint("LEFT", TRANSMOG_SCROLL_PADDING, 0)
			elseif transmogOfferIndex % TRANSMOG_OFFERS_PER_ROW == 1 then
				button:SetPoint("TOPLEFT", self.offerButtons[transmogOfferIndex - TRANSMOG_OFFERS_PER_ROW], "BOTTOMLEFT", 0, TRANSMOG_OFFERS_OFFSET_Y)
			else
				button:SetPoint("TOPLEFT", self.offerButtons[transmogOfferIndex - 1], "TOPRIGHT", TRANSMOG_OFFERS_OFFSET_X, 0)
			end

			self.offerButtons[transmogOfferIndex] = button
		end

		if transmogOfferIndex == 1 then
			button:SetPoint("TOP", self.List.OfferHeader, "BOTTOM", 0, -TRANSMOG_SEPARATOR_OFFSET_Y)
		end

		button:SetOfferIndex(transmogOfferIndex)
	--	button:SetLoading(isLoading) -- layering limitation
		button:Show()
	end

	local height = TRANSMOG_SCROLL_PADDING * 2

	if numTransmogSubCategories > 0 and numTransmogOffers > 0 then
		height = height + self.List.Separator:GetHeight() + TRANSMOG_SEPARATOR_OFFSET_Y * 2
		self.List.Separator:SetPoint("TOP", self.subCategoryButtons[numTransmogSubCategories], "BOTTOM", 0, -TRANSMOG_SEPARATOR_OFFSET_Y)
		self.List.Separator:Show()
	else
		self.List.Separator:Hide()
	end

	if numTransmogOffers > 0 then
		if numTransmogSubCategories > 0 then
			self.List.OfferHeader:SetPoint("TOP", self.List.Separator, "BOTTOM", 0, -TRANSMOG_SEPARATOR_OFFSET_Y + 5)
		else
			self.List.OfferHeader:SetPoint("TOP", -TRANSMOG_SEPARATOR_OFFSET_Y)
		end
		self.List.OfferHeader:Show()
	else
		self.List.OfferHeader:Hide()
	end

	if numTransmogSubCategories > 0 then
		local numRows = math.ceil(numTransmogSubCategories / TRANSMOG_TYPES_PER_ROW)
		height = height + (self.subCategoryButtons[1]:GetHeight() + TRANSMOG_TYPES_OFFSET_Y) * numRows - TRANSMOG_TYPES_OFFSET_Y
	end
	if numTransmogOffers > 0 then
		local numRows = math.ceil(numTransmogOffers / TRANSMOG_OFFERS_PER_ROW)
		height = height + (self.offerButtons[1]:GetHeight() + TRANSMOG_TYPES_OFFSET_Y) * numRows - TRANSMOG_TYPES_OFFSET_Y
	end

	self.List.Scroll.ScrollChild:SetSize(self.List.Scroll:GetWidth(), height)
	self.List.Scroll:UpdateScrollChildRect()
end

function StorePageTransmogrificationMixin:UpdateItemSetOffer()
	local name, link, rarity, icon, amount, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetTransomgItemSetOffer()
	if productID then
		local transmogOfferTimeLeft = C_StoreSecure.GetNextTransmogOfferTimeLeft()
		self.OfferDressUp:SetOfferCountdown(transmogOfferTimeLeft or 0)

		if not transmogOfferTimeLeft or transmogOfferTimeLeft > 0 then
			local allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton = false, true, true, true
			self.OfferDressUp:SetProduct(productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
			self.OfferDressUp.Header:SetShown(price ~= originalPrice and price < originalPrice)
		end
	else
		self.OfferDressUp:SetOfferCountdown(0)
		self.OfferDressUp:ShowItemSetModel(0)
	end
end

function StorePageTransmogrificationMixin:OnItemSetOfferCountdownFinish()
	self.OfferDressUp:ShowItemSetModel(0)
	C_StoreSecure.RequestNextTransmogOfferTime()
end

function StorePageTransmogrificationMixin:SetSubCategory(subCategoryIndex)
	self:GetOwner():GetViewMode(Enum.StoreViewMode.ItemList):SetViewCategory(self:GetID(), subCategoryIndex)
end

StoreTransmogSubCategoryButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreTransmogSubCategoryButtonMixin:OnLoad()
	self.NewIcon:SetAtlas("PKBT-Icon-Notification", true)
	self.NewIcon:SetPoint("LEFT", self.ActionButton, "RIGHT", 9, 0)
	self.ActionButton:SetPoint("CENTER", self.ActionButton:GetWidth() / 2, -30)
	self.Name:SetPoint("BOTTOM", self.ActionButton, "TOP", 0, 10)
end

function StoreTransmogSubCategoryButtonMixin:UpdateInfo()
	local name, icon, isNew, enabled, reason = C_StoreSecure.GetCategoryInfo(Enum.Store.Category.Transmogrification, self:GetID())
	local artworkAtlas = C_StoreSecure.GetTransmogSubCategoryArtwork(self:GetID())
	self.Name:SetText(name)
	self.Artwork:SetAtlas(artworkAtlas, true)
	self.ActionButton:SetEnabled(enabled)
	self.NewIcon:SetShown(isNew)
	self.reason = reason
end

function StoreTransmogSubCategoryButtonMixin:OnActionClick(button)
	self:GetOwner():ShowSubCategoryPage(self:GetID())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end