local C_StoreSecure = C_StoreSecure

local VIEW_STATE = {
	ENTER_CODE		= 0,
	CLAIM_REWARDS	= 1,
	ACTIVATED		= 2,
}

PromoCodeMixin = {}

function PromoCodeMixin:OnLoad()
	self.BASE_HEIGHT = self:GetHeight()
	self.SCROLL_WIDTH = self.Content.Scroll:GetWidth()
	self.MAX_SCROLL_ITEMS = 3
	self.SCROLL_OFFSET_Y = 22
	self.BUTTON_OFFSET_Y = 9
	self.elapsed = 0
	self.state = VIEW_STATE.ENTER_CODE
	self.dirty = true

	self:SetTitle(STORE_PROMOCODE_TITLE)

	self.Content.BackgroundTop:SetAtlas("PKBT-Store-Background-DarkSandstone-Bottom", true)
	self.Content.BackgroundBottom:SetAtlas("PKBT-Tile-DarkSandstone-256")

	self.Content.BackgroundBottom:SetPoint("TOP", self.Content.Code, "BOTTOM", 0, 0)

	self.Content.Code.Background:SetAtlas("PKBT-Tile-Wood-128", true)

	self.Content.ShadowBottom:SetAtlas("PKBT-Panel-Shadow-Bottom", true)

	self.Content.Code.ShadowTop:SetAtlas("PKBT-WoodShadow-Top", true)
	self.Content.Code.ShadowBottom:SetAtlas("PKBT-WoodShadow-Top", true)
	self.Content.Code.ShadowBottom:SetSubTexCoord(0, 1, 1, 0)
	self.Content.Code.ShadowLeft:SetAtlas("PKBT-WoodShadow-Left", true)
	self.Content.Code.ShadowRight:SetAtlas("PKBT-WoodShadow-Left", true)
	self.Content.Code.ShadowRight:SetSubTexCoord(1, 0, 0, 1)

	self.Content.Code.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.Content.Code.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.Content.Code.VignetteBottomLeft:SetAtlas("PKBT-Vignette-Bronze-BottomLeft", true)
	self.Content.Code.VignetteBottomRight:SetAtlas("PKBT-Vignette-Bronze-BottomRight", true)

	self.Content.Code.DividerTop:SetAtlas("PKBT-Divider-Dark", true)
	self.Content.Code.DividerBottom:SetAtlas("PKBT-Divider-Dark", true)
	self.Content.Code.DividerBottom:SetSubTexCoord(0, 1, 1, 0)

	self.Content.Code.EditBox.Background:SetAtlas("PKBT-TitlePanel-Background-Center", true)

	self.Content.Code.EditBox.DecorTop:SetAtlas("PKBT-Panel-Gold-Deacor-Header", true)
	self.Content.Code.EditBox.DecorBottom:SetAtlas("PKBT-Panel-Gold-Deacor-Footer", true)

	self.Content.Code.EditBox.DecorLeft:SetAtlas("PKBT-Store-PromoDecor-Left", true)
	self.Content.Code.EditBox.DecorRight:SetAtlas("PKBT-Store-PromoDecor-Right", true)

	self.Content.Code.EditBox:SetMaxLetters(C_StoreSecure.GetPromoCodeMaxLenght())
	self.Content.Code.EditBox:SetCustomCharFilter(function(text)
		return text:upper():gsub("[^A-Z]+", "")
	end)
	self.Content.Code.EditBox.OnTextValueChanged = function(this, value, userInput)
		self:ValidateCode()
	end

	self.Content.Scroll.ScrollBar:SetBackgroundShown(false)
	self.Content.Scroll.ScrollBar.Show = function(this)
		local scrollFrame = this:GetParent()
		scrollFrame:SetPoint("RIGHT", -50, 0)
		local scrollWidth = self.SCROLL_WIDTH - 30
		scrollFrame.scrollChild:SetWidth(scrollWidth)

		for _, button in ipairs(scrollFrame.buttons) do
			button:SetWidth(scrollWidth)
		end
		getmetatable(this).__index.Show(this)
	end
	self.Content.Scroll.ScrollBar.Hide = function(this)
		local scrollFrame = this:GetParent()
		scrollFrame:SetPoint("RIGHT", -20, 0)
		local scrollWidth = self.SCROLL_WIDTH
		scrollFrame.scrollChild:SetWidth(scrollWidth)

		for _, button in ipairs(scrollFrame.buttons) do
			button:SetWidth(scrollWidth)
		end
		getmetatable(this).__index.Hide(this)
	end
	self.Content.Scroll.update = function(scrollFrame)
		self:UpdateItemList()
	end

	self.Content.Scroll.scrollBar = self.Content.Scroll.ScrollBar
	HybridScrollFrame_CreateButtons(self.Content.Scroll, "PromoCodeItemPlateTemplate", 0, 0, nil, nil, nil, -self.BUTTON_OFFSET_Y)

	self:RegisterCustomEvent("STORE_PROMOCODE_ITEMLIST")
	self:RegisterCustomEvent("STORE_PROMOCODE_REWARD_CLAIMED")
	self:RegisterCustomEvent("STORE_PROMOCODE_ERROR")
	self:RegisterCustomEvent("STORE_PROMOCODE_WAIT")
	self:RegisterCustomEvent("STORE_PROMOCODE_READY")
end

function PromoCodeMixin:OnEvent(event, ...)
	if event == "STORE_PROMOCODE_ITEMLIST" then
		local code, canActivate = ...

		if canActivate then
			self.blockAction = nil
			self.Content.ActionButton.disabledTooltip = nil
		else
			self.blockAction = true
			self.Content.ActionButton.disabledTooltip = STORE_PROMOCODE_ACTION_BUTTON_ERROR
			self.Content.ActionButton:Disable()
		end

		self:SetState(VIEW_STATE.CLAIM_REWARDS)
		self.dirty = true
		self:UpdateItemList()

		if C_StoreSecure.GetNumPromoCodeItems(self:GetCode()) > 0 then
			self:Expand()
		else
			self:Colapse()
		end
	elseif event == "STORE_PROMOCODE_REWARD_CLAIMED" then
		local code, message = ...
		self:SetState(VIEW_STATE.ACTIVATED)
		self:ShowMessage(message)
		self:Colapse()
	elseif event == "STORE_PROMOCODE_WAIT" then
		self:DisableInput()
	elseif event == "STORE_PROMOCODE_READY" then
		self:EnableInput()
	elseif event == "STORE_PROMOCODE_ERROR" then
		local errorMessage = ...
		self:EnableInput(self:GetState() == VIEW_STATE.ENTER_CODE)
		C_StoreSecure.GetStoreFrame():ShowError(self, errorMessage)
	end
end

function PromoCodeMixin:OnShow()
	self.Content.Code.Message:SetWidth(self.Content.Code:GetWidth() - 100)
	self:Reset()
	self:ValidateCode()
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function PromoCodeMixin:GetState()
	return self.state
end

function PromoCodeMixin:SetState(state)
	if self.state == state then
		return
	end

	self.state = state

	if state == VIEW_STATE.ENTER_CODE then
		self.Content.TopText:SetText(STORE_PROMOCODE_TEXT)
		self.Content.ActionButton:SetText(STORE_PROMOCODE_ACTIVATE)
	elseif state == VIEW_STATE.CLAIM_REWARDS then
		self.Content.ActionButton:SetText(STORE_PROMOCODE_TAKE_ITEMS)
	elseif state == VIEW_STATE.ACTIVATED then
		self.Content.TopText.animNextText = STORE_PROMOCODE_ACTIVATED
		self.Content.ActionButton:SetText(CLOSE)
	end
end

function PromoCodeMixin:Reset()
	self:SetState(VIEW_STATE.ENTER_CODE)

	self.blockAction = nil
	self:ToggleBlockFrame(false)
	C_StoreSecure.GetStoreFrame():HideErrors(self)

	self.Content.Code.Message.FadeInAnim:Stop()
	self.Content.Code.EditBox.FadeOutAnim:Stop()
	self.Content.TopText.FadeOutAnim:Stop()

	self.Content.TopText:SetAlpha(1)
	self.Content.Code.Message:Hide()
	self.Content.Code.EditBox:SetText("")
	self.Content.Code.EditBox:SetAlpha(1)
	self.Content.Code.EditBox:Show()
	self.Content.ActionButton.disabledTooltip = nil

	self.Content.Scroll.ScrollBar:SetValue(0)

	self:StopAnimation()
	self:Colapse(true)
	self:EnableInput(true, true)
end

function PromoCodeMixin:ToggleBlockFrame(toggle)
	if toggle and not self:IsShown() then
		return
	end

	self.BlockFrame:SetShown(toggle)

	if toggle then
		SetParentFrameLevel(self.BlockFrame, 5)
	end
end

function PromoCodeMixin:SetCode(code)
	self.Content.Code.EditBox:SetText(code)
end

function PromoCodeMixin:GetCode()
	return self.Content.Code.EditBox:GetText()
end

function PromoCodeMixin:IsCodeValid(code)
	return C_StoreSecure.IsCorrectPromoCodeFormat(code)
end

function PromoCodeMixin:ValidateCode()
	self.Content.ActionButton:SetEnabled(self:IsCodeValid(self:GetCode()))
end

function PromoCodeMixin:OnActionClick(button)
	if self.Content.ActionButton:IsEnabled() ~= 1 then
		return
	end

	if self.state == VIEW_STATE.ENTER_CODE then
		local onAccept = function(dialog)
			self:DisableInput(true)
			self:ToggleBlockFrame(false)
			local success = C_StoreSecure.ActivatePromoCode(self:GetCode())
			if success then
				PlaySound(SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON)
			else
				self:EnableInput(true)
			end
			return true
		end
		local onCancel = function(dialog)
			self:EnableInput(true)
			self:ToggleBlockFrame(false)
			return true
		end

		self:DisableInput(true)
		self:ToggleBlockFrame(true)

		C_StoreSecure.GetStoreFrame():ShowError(self,
			STORE_PROMOCODE_POPUP_FASTEN_DESC, STORE_PROMOCODE_POPUP_FASTEN_HEAD, Enum.StoreDialogStyle.Wood,
			YES, onAccept,
			nil, onCancel
		)
	elseif self.state == VIEW_STATE.CLAIM_REWARDS then
		C_StoreSecure.ClaimPromoCodeRewards(self:GetCode())
		PlaySound(SOUNDKIT.UI_IG_STORE_CONFIRM_PURCHASE_BUTTON)
	elseif self.state == VIEW_STATE.ACTIVATED then
		HideUIPanel(self)
	end
end

function PromoCodeMixin:DisableInput(disableCodeBox, force)
	if self:IsAnimationPlaying() and not force then
		return
	end

	if disableCodeBox then
		self.Content.Code.EditBox:Disable()
	end
	self.Content.ActionButton:ShowSpinner()
	self.Content.ActionButton:Disable()
end

function PromoCodeMixin:EnableInput(enableCodeBox, force)
	if self:IsAnimationPlaying() and not force then
		return
	end

	if enableCodeBox then
		self.Content.Code.EditBox:Enable()
	end
	self.Content.ActionButton:HideSpinner()
	if not self.blockAction then
		self.Content.ActionButton:Enable()
	end
end

local ANIMATION_DURATION = 0.500
local ANIMATION_SCROLL_DURATION = 0.150
local ANIMATION_SCROLL_START = ANIMATION_DURATION - ANIMATION_SCROLL_DURATION

function PromoCodeMixin:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed

	local numItems = C_StoreSecure.GetNumPromoCodeItems(self:GetCode())
	local numScrollItems = math.min(self.MAX_SCROLL_ITEMS, numItems)
	local buttonHeight = self.Content.Scroll.buttons[1]:GetHeight()
	local scrollHeight = (buttonHeight * numScrollItems) + (self.SCROLL_OFFSET_Y + self.BUTTON_OFFSET_Y * (numScrollItems - 1)) + 2
	local animElapsed = math.min(self.elapsed, ANIMATION_DURATION)
	local progressHeight = inBack(animElapsed, 0, scrollHeight, ANIMATION_DURATION, 1.5)

	if self.animExpand then
		self:SetHeight(self.BASE_HEIGHT + progressHeight)
	else
		self:SetHeight(self.BASE_HEIGHT + scrollHeight - progressHeight)
	end

	if numItems > self.MAX_SCROLL_ITEMS then
		local scrollAlpha = self.animExpand and 0 or 1
		if animElapsed >= ANIMATION_SCROLL_START then
			if self.animExpand then
				scrollAlpha = (animElapsed - ANIMATION_SCROLL_START) / ANIMATION_SCROLL_DURATION
			else
				scrollAlpha = 1 - (animElapsed - ANIMATION_SCROLL_START) / ANIMATION_SCROLL_DURATION
			end
		end

		self.Content.Scroll.ScrollBar:SetAlpha(scrollAlpha)
	end

	if self.elapsed >= ANIMATION_DURATION then
		self:StopAnimation()

		if self.animColapse then
			self.Content.Scroll:Hide()
		end
	end
end

function PromoCodeMixin:IsAnimationPlaying()
	return self.animExpand or self.animColapse
end

function PromoCodeMixin:StopAnimation()
	self.animExpand = nil
	self.animColapse = nil
	self.elapsed = 0
	self:SetScript("OnUpdate", nil)
	self:EnableInput()
end

function PromoCodeMixin:Expand(skipAnimation)
	if self.expanded or self.animExpand then
		return
	end

	self:DisableInput()

	self.Content.Scroll:Show()
	self.Content.Scroll.ScrollBar:SetAlpha(0)

	self.expanded = true

	if skipAnimation then
		self:OnUpdate(ANIMATION_DURATION)
	else
		self.animExpand = true
		self:SetScript("OnUpdate", self.OnUpdate)
		self:OnUpdate(0)
	end
end

function PromoCodeMixin:Colapse(skipAnimation)
	if not self.expanded or self.animColapse then
		return
	end

	self:DisableInput()

	self.expanded = nil

	if skipAnimation then
		self:OnUpdate(ANIMATION_DURATION)
		self.Content.Scroll:Hide()
	else
		self.animColapse = true
		self:SetScript("OnUpdate", self.OnUpdate)
		self:OnUpdate(0)
	end
end

function PromoCodeMixin:ShowMessage(message)
	self.Content.Code.Message:SetText(message)
	self.Content.Code.Message:Show()
	self.Content.Code.Message.FadeInAnim:Play()
	self.Content.Code.EditBox.FadeOutAnim:Play()
	self.Content.TopText.FadeOutAnim:Play()
end

function PromoCodeMixin:UpdateItemList()
	local scrollFrame = self.Content.Scroll
	local numItems = C_StoreSecure.GetNumPromoCodeItems(self:GetCode())

	if numItems == 0 then
		self:Colapse()
		scrollFrame:Hide()
		return
	end

	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for index, button in ipairs(scrollFrame.buttons) do
		local itemIndex = index + offset
		if itemIndex <= numItems then
			local name, link, rarity, icon, amount = C_StoreSecure.GetPromoCodeItemsInfo(self:GetCode(), itemIndex)
			button:SetOwner(self)
			button:SetID(itemIndex)
			button:SetItem(name, link, rarity, icon, amount)
			button:Show()
		else
			button:Hide()
		end
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		local scrollHeight = buttonHeight * numItems + self.BUTTON_OFFSET_Y * (numItems - 1) + -self.BUTTON_OFFSET_Y / 3
		HybridScrollFrame_Update(scrollFrame, scrollHeight, scrollFrame:GetHeight())
		self.dirty = nil
	end
end

PromoCodeItemPlateMixin = CreateFromMixins(PKBT_OwnerMixin)

function PromoCodeItemPlateMixin:OnLoad()
	self.UpdateTooltip = self.OnEnter
end

function PromoCodeItemPlateMixin:OnEnter()
	self.Background:SetTexture(0.157, 0.157, 0.157)

	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end

	CursorUpdate(self)
end

function PromoCodeItemPlateMixin:OnLeave()
	self.Background:SetTexture(0.059, 0.059, 0.059)
	if self.itemLink then
		GameTooltip_Hide()
	end
	ResetCursor()
end

function PromoCodeItemPlateMixin:OnClick(button)
	if self.itemLink then
		HandleModifiedItemClick(self.itemLink)
	end
end

function PromoCodeItemPlateMixin:SetItem(name, itemLink, rarity, icon, amount)
	self.Item:SetIcon(icon)
	self.Item:SetAmount(amount)
	self.Name:SetText(name)
	self.Name:SetTextColor(GetItemQualityColor(rarity))
	self.itemLink = itemLink
	self.hasItem = itemLink ~= nil
end