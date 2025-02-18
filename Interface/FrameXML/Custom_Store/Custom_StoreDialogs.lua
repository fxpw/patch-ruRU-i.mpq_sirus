local C_StoreSecure = C_StoreSecure

StoreLinkDialogMixin = CreateFromMixins(StoreSubDialogMixin, StoreDialogCloseHandlingMixin)

function StoreLinkDialogMixin:OnLoad()
	StoreSubDialogMixin.OnLoad(self)

	self.ActionButton:Hide()
	self.CancelButton:SetText(CLOSE)

	self.EditBox:SetBlockChanges(true)
	self.EditBox:SetSelectOnBlock(true)
	self.EditBox:SetTextColor(1, 1, 1)
end

function StoreLinkDialogMixin:OnShow()
	self:UpdateRect()
	self.EditBox:HighlightText()
end

function StoreLinkDialogMixin:UpdateRect()
	if not self:IsVisible() then
		return
	end

	local height = 105 + self.CancelButton:GetHeight()

	if self.Title:IsShown() then
		height = height + self.Title:GetHeight() + 5
	end

	if self.Text:IsShown() then
		height = height + self.Text:GetHeight() + 5 + self.Divider:GetHeight() + 5
	end

	self:SetHeight(math.max(120, math.ceil(height)))
end

function StoreLinkDialogMixin:OnClose()
	C_StoreSecure.GetStoreFrame():HideLinkDialog()
end

function StoreLinkDialogMixin:SetTitle(title)
	if title and title ~= "" then
		self.Title:SetText(title)
		self.Title:Show()
	else
		self.Title:Hide()
	end
	self:UpdateRect()
end

function StoreLinkDialogMixin:SetText(text)
	if text and text ~= "" then
		self.Text:SetText(text)
		self.Text:Show()
		self.Divider:Show()
	else
		self.Divider:Hide()
		self.Text:Hide()
	end
	self:UpdateRect()
end

function StoreLinkDialogMixin:SetLink(link)
	self.EditBox:SetText(link)
end

function StoreLinkDialogMixin:CopyLink()
end

StoreAgreementMixin = CreateFromMixins(StoreDialogCloseHandlingMixin)

function StoreAgreementMixin:OnLoad()
	self:SetTitle(STORE_AGREEMENT_TITLE)

	self.Content.BackgroundTop:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom", true)
	self.Content.BackgroundTop:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom", true)
	self.Content.BackgroundBottom:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom", true)
	self.Content.BackgroundMiddle:SetAtlas("PKBT-Store-Background-Parchment-WornOut", true)

	self.Content.Scroll.ScrollBar:SetBackgroundShown(false)
	self.Content.Scroll.ScrollBar:SetScrollBarHideable(true)

	self.CloseButton:Hide()

	C_StoreSecure.GetStoreFrame():RegisterDialogWidget(self, Enum.StoreWidget.Agreement)
end

function StoreAgreementMixin:UpdateTextRect()
	local width = self.Content.Scroll:GetWidth()
	self.Content.Scroll.ScrollChildFrame:SetSize(width - 5, self.Content.Scroll:GetHeight())
	self.Content.Scroll.ScrollChildFrame:SetText("")
	self.Content.Scroll.ScrollChildFrame:SetText(self.text)
	self.Content.Scroll:UpdateScrollChildRect()
end

function StoreAgreementMixin:OnShow()
	self:UpdateTextRect()
	self.Content.Scroll:SetVerticalScroll(0)
end

function StoreAgreementMixin:ShowAgreement(text, onAgree, onRefuse)
	if not text or text == "" then
		self:Hide()
		return false
	end

	self.text = text

	self.onAgree = type(onAgree) == "function" and onAgree or nil
	self.onRefuse = type(onRefuse) == "function" and onRefuse or nil

	self.CloseButton:SetShown(self.onRefuse ~= nil)

	self:Show()
	return true
end

function StoreAgreementMixin:OnAgreeClick(button)
	self:Close()

	if type(self.onAgree) == "function" then
		local success, err = pcall(self.onAgree)
		if not success then
			geterrorhandler()(err)
		end
	end
end

function StoreAgreementMixin:OnRefuseClick(button)
	self:Close()

	if type(self.onRefuse) == "function" then
		local success, err = pcall(self.onRefuse)
		if not success then
			geterrorhandler()(err)
		end
	end
end

StoreReferralDialogMixin = CreateFromMixins(StoreDialogCloseHandlingMixin)

function StoreReferralDialogMixin:OnLoad()
	self:SetTitle(STORE_REFERRAL_TITLE)

	self.Background:SetAtlas("PKBT-Tile-DarkRock-256", true)

	self.Content.ShadowTop:SetAtlas("PKBT-Background-Shadow-Large-Top")
	self.Content.VignetteTopLeft:SetAtlas("PKBT-Vignette-Silver-TopLeft", true)
	self.Content.VignetteTopRight:SetAtlas("PKBT-Vignette-Silver-TopRight", true)
	self.Content.VignetteBottomLeft:SetAtlas("PKBT-Vignette-Silver-BottomLeft", true)
	self.Content.VignetteBottomRight:SetAtlas("PKBT-Vignette-Silver-BottomRight", true)

	self.Content.Step3.ArtworkNineSlice.Arrow:Hide()

	C_StoreSecure.GetStoreFrame():RegisterDialogWidget(self, Enum.StoreWidget.Referral)
end

function StoreReferralDialogMixin:OnHide()
	C_StoreSecure.GetStoreFrame():HideLinkDialog()
end

function StoreReferralDialogMixin:OnInviteClick(button)
	C_StoreSecure.GetStoreFrame():ShowLinkDialog(self, STORE_REFERRAL_TITLE, STORE_REFERRAL_INVITE_TEXT, C_StoreSecure.GetReferralLink())
end

function StoreReferralDialogMixin:OnInfoClick(button)
	C_StoreSecure.GetStoreFrame():ShowLinkDialog(self, STORE_REFERRAL_TITLE, STORE_REFERRAL_INFO_TEXT, C_StoreSecure.GetReferralExternalInfoLink())
end

StoreReferralDialogStepMixin = {}

function StoreReferralDialogStepMixin:OnLoad()
	self.ArtworkNineSlice.NumberBorder:SetAtlas("PKBT-Store-Referral-Sphere", true)
	self.ArtworkNineSlice.Number:SetAtlas(string.format("PKBT-Store-Glyph-Gold-%u", self:GetID()), true)
	self.ArtworkNineSlice.Arrow:SetAtlas("PKBT-Store-Referral-Arrow", true)

	self.ArtworkNineSlice.Artwork:SetAtlas(self:GetAttribute("atlasName"), true)
	self.Label:SetText(_G[self:GetAttribute("label")])
	self.Text:SetText(_G[self:GetAttribute("text")])

	self.Label:SetPoint("TOP", self.ArtworkNineSlice, "BOTTOM", 0, -20)
end

StorePremiumPurchaseDialogMixin = CreateFromMixins(StoreDialogCloseHandlingMixin)

function StorePremiumPurchaseDialogMixin:OnLoad()
	self:SetTitle(STORE_PREMIUM_TITLE)

	self.Content.BackgroundTop:SetAtlas("PKBT-Tile-Wood-128", true)

	self.Content.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.Content.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.Content.ArtworkBottomLeft:SetAtlas("PKBT-Store-Artwork-Hero-BottomLeft", true)
	self.Content.ArtworkBottomRight:SetAtlas("PKBT-Store-Artwork-Hero-BottomRight", true)
	self.Content.Divider:SetAtlas("PKBT-Divider-Dark", true)

	self.Content.PurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), true)
	self.Content.PurchaseButton:AddText(STORE_PURCHASE_PREMIUM_ALT)

	self.bonusList = {}
	self.optionList = {}
	self.selectedOptionIndex = 1

	self:RegisterCustomEvent("STORE_PREMIUM_PURCHASED")
	self:RegisterCustomEvent("STORE_PREMIUM_PURCHASE_FAILED")
	self:RegisterCustomEvent("STORE_PURCHASE_ERROR")

	C_StoreSecure.GetStoreFrame():RegisterDialogWidget(self, Enum.StoreWidget.PremiumPurchase)
end

function StorePremiumPurchaseDialogMixin:OnEvent(event, ...)
	if event == "STORE_PREMIUM_PURCHASED" then
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
		self:Close()
	elseif event == "STORE_PREMIUM_PURCHASE_FAILED"
	or event == "STORE_PURCHASE_ERROR"
	then
		self.Content.PurchaseButton:HideSpinner()
		self.Content.PurchaseButton:CheckBalance()
	end
end

function StorePremiumPurchaseDialogMixin:OnShow()
	self:Reset()
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StorePremiumPurchaseDialogMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
end

function StorePremiumPurchaseDialogMixin:Reset()
	self.selectedOptionIndex = 1
	self:UpdateOptionList()
	self.Content.PurchaseButton:HideSpinner()
	self:UpdatePrice()
end

function StorePremiumPurchaseDialogMixin:UpdateOptionList()
	local BONUS_OFFSET_X = 20
	local numBonuses = C_StoreSecure.GetNumPremiumBonuses()
	for index = 1, numBonuses do
		local bonus = self.bonusList[index]
		if not bonus then
			bonus = CreateFrame("Frame", string.format("$parentBonus%u", index), self.Content, "StorePremiumBonusTemplate")
			self.bonusList[index] = bonus
		end

		local text, atlas = C_StoreSecure.GetPremiumBonusInfo(index)
		bonus.Icon:SetAtlas(atlas, true)
		bonus.Text:SetText(text)
		bonus:Show()

		if index == 1 then
			bonus:SetPoint("TOP", self.Content.BonusListLabel, "BOTTOM", -((bonus:GetWidth() + 20) * (numBonuses - 1) / 2), -30)
		else
			bonus:SetPoint("TOPLEFT", self.bonusList[index - 1], "TOPRIGHT", BONUS_OFFSET_X, 0)
		end
	end

	for index = numBonuses + 1, #self.bonusList do
		self.bonusList[index]:Hide()
	end

	local numPremiumOptions = C_StoreSecure.GetNumPremiumOptions()
	for optionIndex = 1, numPremiumOptions do
		local text, discountText, price, originalPrice, currencyType = C_StoreSecure.GetPremiumOptionInfo(optionIndex)

		local option = self.optionList[optionIndex]
		if not option then
			option = CreateFrame("CheckButton", string.format("$parentOption%u", optionIndex), self.Content, "StorePremiumOptionTemplate")
			option:SetOwner(self)
			option:SetID(optionIndex)

			if optionIndex == 1 then
				option:SetPoint("TOP", self.Content.OptionLabel, "BOTTOM", -150, -35)
			else
				option:SetPoint("TOPLEFT", self.optionList[optionIndex - 1], "BOTTOMLEFT", 0, -15)
			end

			self.optionList[optionIndex] = option
		end

		option:SetText(text)
		option.DiscountText:SetText(discountText)
		option.Price:SetPrice(price, originalPrice, currencyType)
		option:SetChecked(optionIndex == self.selectedOptionIndex)
		option:Show()
	end

	for optionIndex = numPremiumOptions + 1, #self.optionList do
		self.optionList[optionIndex]:Hide()
	end
end

function StorePremiumPurchaseDialogMixin:UpdatePrice()
	local _, _, price, originalPrice, currencyType = C_StoreSecure.GetPremiumOptionInfo(self.selectedOptionIndex)
	self.Content.PurchaseButton:SetPrice(price, originalPrice, currencyType)
end

function StorePremiumPurchaseDialogMixin:SetSelectedOption(index)
	local changed = self.selectedOptionIndex ~= index
	self.selectedOptionIndex = index

	for optionIndex, option in ipairs(self.optionList) do
		option:SetChecked(optionIndex == index)
	end

	if changed then
		self:UpdatePrice()
	end
end

function StorePremiumPurchaseDialogMixin:OnPurchaseClick(button)
	local _, _, price, originalPrice, currencyType = C_StoreSecure.GetPremiumOptionInfo(self.selectedOptionIndex)
	local balance = C_StoreSecure.GetBalance(currencyType)
	if price > balance and not C_Service.IsInGMMode() then
		if currencyType == Enum.Store.CurrencyType.Bonus then
			C_StoreSecure.GetStoreFrame():ShowLinkDialog(nil, STORE_DONATE_DIALOG_TITLE, STORE_DONATE_DIALOG_TEXT, C_StoreSecure.GenerateDonationLinkForAmount(price - balance))
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			return
		else
			C_StoreSecure.GenerateBalanceError(Enum.Store.ProductType.Item, currencyType, string.join(".", "PREMPD", self.selectedOptionIndex or " "))
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			return
		end
	end

	self.Content.PurchaseButton:ShowSpinner()
	self.Content.PurchaseButton:Disable()
	C_StoreSecure.PurchasePremiumOption(self.selectedOptionIndex)
end

StorePremiumOptionMixin = CreateFromMixins(PKBT_OwnerMixin)

function StorePremiumOptionMixin:OnLoad()
	PKBT_RadioButtonMixin.OnLoad(self)
end

function StorePremiumOptionMixin:OnClick(button)
	self:GetOwner():SetSelectedOption(self:GetID())
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end