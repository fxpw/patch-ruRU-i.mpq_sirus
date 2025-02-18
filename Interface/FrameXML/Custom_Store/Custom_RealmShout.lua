local C_StoreSecure = C_StoreSecure

StoreRealmShoutMixin = {}

function StoreRealmShoutMixin:OnLoad()
	self:SetTitle(STORE_REALM_SHOUT_TITLE)

	self.Content.BackgroundTop:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom", true)
	self.Content.BackgroundBottom:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom", true)
	self.Content.BackgroundMiddle:SetAtlas("PKBT-Store-Background-Parchment-WornOut", true)

	self.Content.ShadowBottom:SetAtlas("PKBT-Panel-Shadow-Bottom", true)

	self.Content.EditBoxScroll.DecorTop:SetAtlas("PKBT-Paper-Decor-Top", true)
	self.Content.EditBoxScroll:SetMaxLetters(C_StoreSecure.GetRealmShoutTextMaxLetters())
	self.Content.EditBoxScroll:SetInstructions(STORE_REALM_SHOUT_INSTRUCTION)
	self.Content.EditBoxScroll.EditBox:SetBlockNewLines(true)
	self.Content.EditBoxScroll.EditBox:SetBlockMultipleSpaces(true)
	self.Content.EditBoxScroll.ScrollBar:SetBackgroundShown(false)
	self.Content.EditBoxScroll.ScrollBar:SetScrollBarHideable(true)

	self.Content.EditBoxScroll.EditBox.OnTextValueChanged = function(this, text, userInput)
		self:Validate()
	end

	self.Content.PurchaseButton:AddText(STORE_REALM_SHOUT_PURCHASE)
end

function StoreRealmShoutMixin:OnShow()
	local price, originalPrice, currencyType = C_StoreSecure.GetRealmShoutPrice()
	self.Content.Balance:SetCurrencyType(currencyType)
	self.Content.PurchaseButton:SetPrice(price, originalPrice, currencyType)
	self:Validate()
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreRealmShoutMixin:OnHide()
	self:Reset()
end

function StoreRealmShoutMixin:Reset()
	self:EnableInput()
	self:ToggleBlockFrame(false)
	self.Content.EditBoxScroll.EditBox:SetText("")
	self:Validate()
end

function StoreRealmShoutMixin:ToggleBlockFrame(toggle)
	if toggle and not self:IsShown() then
		return
	end

	self.BlockFrame:SetShown(toggle)

	if toggle then
		SetParentFrameLevel(self.BlockFrame, 5)
	end
end

function StoreRealmShoutMixin:DisableInput()
	self.Content.EditBoxScroll.EditBox:Disable()
end

function StoreRealmShoutMixin:EnableInput()
	self.Content.EditBoxScroll.EditBox:Enable()
end

function StoreRealmShoutMixin:IsValidate()
	local text = self.Content.EditBoxScroll.EditBox:GetText()
	if text then
		text = string.trim(text)
		return C_StoreSecure.IsRealmShoutTextValid(text)
	end
	return false
end

function StoreRealmShoutMixin:Validate()
	if self:IsValidate() then
		if C_StoreSecure.IsRealmShoutAvailable() then
			self.Content.PurchaseButton:CheckBalance()
		else
			self.Content.PurchaseButton:Disable()
		end
		self.Content.PreviewButton:Enable()
	else
		self.Content.PurchaseButton:Disable()
		self.Content.PreviewButton:Disable()
	end
end

function StoreRealmShoutMixin:OnPurchaseClick(button)
	if self:IsValidate() then
		self:ShowConfirmationDialog()
	end
end

function StoreRealmShoutMixin:OnPreviewClick(button)
	if self:IsValidate() then
		local text = string.trim(self.Content.EditBoxScroll.EditBox:GetText())
		C_StoreSecure.PreviewRealmShout(text)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
end

function StoreRealmShoutMixin:ShowConfirmationDialog()
	local text = string.trim(self.Content.EditBoxScroll.EditBox:GetText())
	self:DisableInput()
	self:ToggleBlockFrame(true)

	local onAccept = function(dialog)
		C_StoreSecure.PurchaseRealmShout(text)
		self:Reset()
		PlaySound(SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON)
		return true
	end

	local onCancel = function(dialog)
		self:EnableInput()
		self:ToggleBlockFrame(false)
		return true
	end

	C_StoreSecure.GetStoreFrame():ShowError(self,
		STORE_SHOUT_MESSAGE_CONFIRMATION, STORE_ATTENTION_LABEL, Enum.StoreDialogStyle.Wood,
		YES, onAccept,
		nil, onCancel
	)
end