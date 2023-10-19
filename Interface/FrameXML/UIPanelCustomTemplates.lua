function TutorialHelpBoxAlertTemplate_OnShow( self, ... )
	if self.Parent then
		self:SetParent(self.Parent)
	end

	if self.Anchors then
		self:ClearAllPoints()
		self:SetPoint(self.Anchors[1], self.Anchors[2], self.Anchors[3], self.Anchors[4], self.Anchors[5])
	end

	self.Text:SetSpacing(4)
	self.Text:SetText(self.text or "")
	self:SetHeight(self.Text:GetHeight() + 42)

	if self.AnchorsArray then
		self.Arrow:ClearAllPoints()
		self.Arrow:SetPoint(self.AnchorsArray[1], self, self.AnchorsArray[2], self.AnchorsArray[3], self.AnchorsArray[4])

		SetClampedTextureRotation(self.Arrow.Arrow, self.AnchorsArray[5])
	end
end

StorePopupFrameTemplateMixin = {};

function StorePopupFrameTemplateMixin:OnLoad()
	self.baseHeight = 360
	self.editBox = self.Content.SectionMiddle.EditBoxFrame.EditBox
end

function StorePopupFrameTemplateMixin:SetSettings(settings)
	if not settings then return end

	self.Title:SetText(settings.titleText)

	self.Button1:SetText(settings.button1Text or BUY)

	if settings.button2Text then
		self.Button2:SetText(settings.button2Text)

		self.Button1:ClearAllPoints()
		self.Button1:SetPoint("BOTTOM", -75, 17)

		self.Button2:ClearAllPoints()
		self.Button2:SetPoint("BOTTOM", 75, 17)

		self.Button2:Show()
	else
		self.Button2:Hide()

		self.Button1:ClearAllPoints()
		self.Button1:SetPoint("BOTTOM", 0, 17)
	end

	self.Content.SectionTop.Text:SetText(settings.textTop)

	self.Content.SectionMiddle.Text:SetText(settings.textMiddle or "")
	self.Content.SectionMiddle.Text:SetShown(settings.textMiddle ~= nil)

	self.Content.SectionBottom.Price:SetText(settings.priceValue)

	if settings.editBoxInstructions then
		self.Content.SectionMiddle.EditBoxFrame.instructions = settings.editBoxInstructions
		self.Content.SectionMiddle.EditBoxFrame.EditBox.Instructions:SetText(settings.editBoxInstructions)
	else
		self.Content.SectionMiddle.EditBoxFrame.instructions = SHOP_POPUP_EDITBOX_INSTRUCTION
		self.Content.SectionMiddle.EditBoxFrame.EditBox.Instructions:SetText(SHOP_POPUP_EDITBOX_INSTRUCTION)
	end

	self.Content.SectionMiddle.EditBoxFrame.EditBox.multiLine = settings.editBoxMultiLine and true or false

	self.Popup_OnShow = settings.Popup_OnShow
	self.Popup_OnHide = settings.Popup_OnHide
	self.Button1_OnClick = settings.Button1_OnClick
	self.Button2_OnClick = settings.Button2_OnClick
	self.EditBox_OnTextChanged = settings.EditBox_OnTextChanged

	self.Button1.Button_OnClick = settings.Button1_OnClick
	self.Button1.TooltipText = settings.button1TooltipText
	self.Button1.DisabledTooltipText = settings.button1DisabledTooltipText

	self.Button2.Button_OnClick = settings.Button2_OnClick
	self.Button2.TooltipText = settings.button2TooltipText
	self.Button2.DisabledTooltipText = settings.button2DisabledTooltipText
end

function StorePopupFrameTemplateMixin:OnShow()
	self:Unblock()
	self:UpdateBalance()

	if self.Content.SectionMiddle.Text:IsShown() then
		self.Content.SectionMiddle.Text:SetWidth(self.Content.SectionMiddle:GetWidth() - 70)	-- Force recalculate text rect
		self:SetHeight(self.baseHeight + self.Content.SectionMiddle.Text:GetHeight() + 15)
	else
		self:SetHeight(self.baseHeight)
	end

	if self.Popup_OnShow then
		self.Popup_OnShow(self)
	end
end

function StorePopupFrameTemplateMixin:OnHide()
	self.editBox:SetText("")

	if self.Popup_OnHide then
		self.Popup_OnHide(self)
	end
end

function StorePopupFrameTemplateMixin:UpdateBalance()
	self.Content.SectionBottom.Balance:SetFormattedText(SHOP_POPUP_BALANCE, Store_GetBalance(Enum.Store.CurrencyType.Bonus))
end

function StorePopupFrameTemplateMixin:Block()
	SetParentFrameLevel(self.BlockingFrame, 10)
	self.BlockingFrame:Show()
end

function StorePopupFrameTemplateMixin:Unblock()
	self.BlockingFrame:Hide()
end

StorePopupButtonTemplateMixin = {}

function StorePopupButtonTemplateMixin:OnLoad()
	self.PopupFrame = self:GetParent()
end

function StorePopupButtonTemplateMixin:OnClick(button)
	if self.Button_OnClick then
		self.Button_OnClick(self, button)
	end
end

function StorePopupButtonTemplateMixin:OnEnter()
	if self:IsEnabled() == 1 then
		if self.TooltipText then
			GameTooltip:SetOwner(self, "TOP")
			GameTooltip:SetText(self.TooltipText)
			GameTooltip:Show()
		end
	else
		if self.DisabledTooltipText then
			GameTooltip:SetOwner(self, "TOP")
			GameTooltip:SetText(self.DisabledTooltipText)
			GameTooltip:Show()
		end
	end
end

function StorePopupButtonTemplateMixin:OnLeave()
	if self:IsEnabled() == 1 then
		if self.TooltipText then
			GameTooltip:Hide()
		end
	else
		if self.DisabledTooltipText then
			GameTooltip:Hide()
		end
	end
end

StorePopupFrameTemplateEditBoxMixin = {}

function StorePopupFrameTemplateEditBoxMixin:OnLoad()
	self.EditBox:SetFontObject("GameFontHighlight")
	self.EditBox.Instructions:SetFontObject("GameFontHighlight")
	self.maxLetters = 255
	self.instructions = SHOP_POPUP_EDITBOX_INSTRUCTION
	InputScrollFrame_OnLoad(self)

	self.PopupFrame = self:GetParent():GetParent():GetParent()
	self.EditBox.PopupFrame = self.PopupFrame

	self.EditBox:HookScript("OnTextChanged", function(this, userInput)
		if not this.multiLine then
			local text = this:GetText()
			if text then
				local x
				text, x = text:gsub("\n", " ")
				if x then
					this:SetText(text)
				end
			end
		end

		if self.PopupFrame.EditBox_OnTextChanged then
			self.PopupFrame.EditBox_OnTextChanged(this, userInput)
		end
	end)
end

function CreateStorePopup(name, settings)
	local f = CreateFrame("Frame", name, UIParent, "StorePopupFrameTemplate")
	f:SetSettings(settings)
	return f
end

UIPanelButtonChallengeStateHandlerMixin = {}

function UIPanelButtonChallengeStateHandlerMixin:OnLoad()
	self.isDisabled = false
	self.featureFlag = tonumber(self:GetParent():GetAttribute("featureFlag"))
	self.featureFlag1 = tonumber(self:GetParent():GetAttribute("featureFlag1"))

	if self.featureFlag or self.featureFlag1 then
		self:RegisterCustomEvent("CUSTOM_CHALLENGE_ACTIVATED")
		self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")
	end

	self:UpdateState()
end

function UIPanelButtonChallengeStateHandlerMixin:OnEvent(event, ...)
	if event == "CUSTOM_CHALLENGE_ACTIVATED" or (event == "CUSTOM_CHALLENGE_DEACTIVATED" and select(2, ...) ~= Enum.HardcoreDeathReason.FAILED_DEATH) then
		self:UpdateState()
	end
end

function UIPanelButtonChallengeStateHandlerMixin:OnShow()
	self:UpdateState()
end

function UIPanelButtonChallengeStateHandlerMixin:OnHide()
	self:UpdateState()
end

function UIPanelButtonChallengeStateHandlerMixin:UpdateState()
	if self.featureFlag and C_Hardcore.IsFeatureAvailable(self.featureFlag)
		or self.featureFlag1 and C_Hardcore.IsFeature1Available(self.featureFlag1)
	then
		self:SetDisable()
	elseif self:IsDisabled() then
		self:SetEnable()
	end
end

function UIPanelButtonChallengeStateHandlerMixin:SetEnable()
	local button = self:GetParent()

	button.SetEnabled = nil
	button.Enable = nil
	button.Disable = nil
	button.SetScript = nil

	if self.originalIsEnabled then
		button:Enable()
	end

	if self.motionScriptsWhileDisabled then
		button:SetMotionScriptsWhileDisabled(false)
	end

	self.isDisabled = false
end

function UIPanelButtonChallengeStateHandlerMixin:SetDisable()
	if self.isDisabled then
		return
	end

	local button = self:GetParent()

	self.isDisabled = true

	if button:IsEnabled() == 1 then
		self.originalIsEnabled = true
	end

	if not button:GetMotionScriptsWhileDisabled() then
		button:SetMotionScriptsWhileDisabled(true)
		self.motionScriptsWhileDisabled = false
	end

	if button.pulseDuration then
		ButtonPulse_StopPulse(button)
	end

	button:Disable()

	button.Disable = function(this)
		self.originalIsEnabled = false
		getmetatable(this).__index.Disable(this)
	end
	button.SetEnabled = function(this, isEnabled)
		self.originalIsEnabled = isEnabled
		getmetatable(this).__index.SetEnabled(this, false)
	end
	button.Enable = function(this)
		self.originalIsEnabled = true
		getmetatable(this).__index.Disable(this)
	end
end

function UIPanelButtonChallengeStateHandlerMixin:IsDisabled()
	return self.isDisabled
end