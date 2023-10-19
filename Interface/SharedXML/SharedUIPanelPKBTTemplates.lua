PKBT_OwnerMixin = {}

function PKBT_OwnerMixin:SetOwner(widget)
	if widget ~= nil and (type(widget) ~= "table" or not widget.GetObjectType) then
		error(string.format("bad argument #1 to 'obj:SetOwner(widget)' (widget expected, got %s)", widget ~= nil and type(widget) or "no value"), 2)
	end

	self.owner = widget

	if type(self.OnOwnerChanged) == "function" then
		self:OnOwnerChanged()
	end
end

function PKBT_OwnerMixin:GetOwner()
	return self.owner or self:GetParent() or (UIParent or GlueParent)
end

PKBT_PanelNoPortraitMixin = {}

function PKBT_PanelNoPortraitMixin:GetTitleContainer()
	return self.TitleContainer
end

function PKBT_PanelNoPortraitMixin:GetTitleText()
	return self.TitleContainer.TitleText
end

function PKBT_PanelNoPortraitMixin:SetTitleColor(color)
	self:GetTitleText():SetTextColor(color:GetRGBA())
end

function PKBT_PanelNoPortraitMixin:SetTitle(title)
	self:GetTitleText():SetText(title)
	self:GetTitleContainer():UpdateRect()
end

function PKBT_PanelNoPortraitMixin:SetTitleFormatted(fmt, ...)
	self:GetTitleText():SetFormattedText(fmt, ...)
end

PKBT_TitleMixin = {}

function PKBT_TitleMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-TitlePanel-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-TitlePanel-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-TitlePanel-Background-Center", true)

	self.ShadowLeft:SetAtlas("PKBT-TitlePanel-Shadow-Left", true)
	self.ShadowRight:SetAtlas("PKBT-TitlePanel-Shadow-Right", true)

	self.DecorTop:SetAtlas("PKBT-Panel-Gold-Deacor-Header", true)
	self.DecorBottom:SetAtlas("PKBT-Panel-Gold-Deacor-Footer", true)
end

function PKBT_TitleMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
	self:UpdateRect()
end

function PKBT_TitleMixin:UpdateRect()
	self:SetWidth(math.max(240, self.TitleText:GetStringWidth() + 78))
end

PKBT_DialogMixin = CreateFromMixins(TitledPanelMixin)

function PKBT_DialogMixin:OnLoad()
	self.NineSlice.DecorTop:SetAtlas("PKBT-Panel-Gold-Deacor-Header", true)
	self.NineSlice.DecorBottom:SetAtlas("PKBT-Panel-Gold-Deacor-Footer", true)
end

function PKBT_DialogMixin:GetTitleText()
	return self.NineSlice.TitleText
end

function PKBT_DialogMixin.onCloseCallback(closeButton)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	return true
end

PKBT_ButtonMixin = CreateFromMixins(ThreeSliceButtonMixin)

function PKBT_ButtonMixin:OnShow()
	self:UpdateButton()
end

function PKBT_ButtonMixin:OnEnable()
	self:UpdateButton()
end

function PKBT_ButtonMixin:OnDisable()
	self:UpdateButton()
end

function PKBT_ButtonMixin:GetCenterAtlasName()
	return self.atlasName.."-Center"
end

function PKBT_ButtonMixin:GetButtonStateExt(buttonState)
	if self:IsEnabled() ~= 1 then
		return "DISABLED"
	else
		return buttonState or self:GetButtonState()
	end
end

function PKBT_ButtonMixin:SetThreeSliceAtlas(atlasName)
	if self.atlasName ~= atlasName then
		self.atlasName = atlasName
		self:InitButton()
		self:UpdateButton()
	end
end

function PKBT_ButtonMixin:ShowSpinner()
	if not self.__spinner then
		self.__spinner = CreateFrame("Frame", "$parentSpinner", self, "PKBT_LoadingSpinnerTemplate")
		self.__spinner:SetPoint("CENTER", 0, 0)
	end

	local spinnderHeight = self:GetHeight() - 10
	self.__spinner:SetSize(spinnderHeight, spinnderHeight)
	self.__spinner:Show()

	if self.ButtonText then
		self.ButtonText:Hide()
	end
end

function PKBT_ButtonMixin:HideSpinner()
	if self.__spinner then
		self.__spinner:Hide()
	end
	if self.ButtonText then
		self.ButtonText:Show()
	end
end

PKBT_VirtualCheckButtonMixin = CreateFromMixins()

function PKBT_VirtualCheckButtonMixin:OnLoad()
	self.__isChecked = false
end

function PKBT_VirtualCheckButtonMixin:OnClick(button)
	if button == "LeftButton" and self:IsEnabled() == 1 then
		self:SetChecked(not self:GetChecked(), true)
	end
end

function PKBT_VirtualCheckButtonMixin:SetChecked(checked, userInput)
	checked = not not checked
	local changed = self.__isChecked ~= checked

	if changed then
		if self.__blockUserUncheck and userInput and not checked then
			if self.callUpdateOnBlock then
				if type(self.OnChecked) == "function" then
					self:OnChecked(self.__isChecked, userInput)
				end
			end
			getmetatable(self).__index.SetChecked(self, self.__isChecked)
			return
		end

		if self.__lockCheckedTextOffset then
			if checked then
				local x, y = self:GetPushedTextOffset()
				self.__pushedOffsetX = x
				self.__pushedOffsetY = y
				self:SetPushedTextOffset(0, 0)
			else
				self:SetPushedTextOffset(self.__pushedOffsetX, self.__pushedOffsetY)
				self.__pushedOffsetX = nil
				self.__pushedOffsetY = nil
			end
		end

		self.__isChecked = checked
		self:UpdateButton()

		if type(self.OnChecked) == "function" then
			self:OnChecked(checked, userInput)
		end
	end
end

function PKBT_VirtualCheckButtonMixin:SetBlockedUncheck(state)
	self.__blockUserUncheck = not not state
end

function PKBT_VirtualCheckButtonMixin:SetLockCheckedTextOffset(state)
	self.__lockCheckedTextOffset = not not state
end

function PKBT_VirtualCheckButtonMixin:GetChecked()
	return self.__isChecked
end

function PKBT_VirtualCheckButtonMixin:GetButtonStateExt(buttonState)
	if self:IsEnabled() ~= 1 then
		return "DISABLED"
	elseif self:IsMouseOver() then
		return "HIGHLIGHT"
	elseif self:GetChecked() then
		return "CHECKED"
	else
		return buttonState or self:GetButtonState()
	end
end

function PKBT_VirtualCheckButtonMixin:UpdateButton()
	getmetatable(self).__index.SetChecked(self, self.__isChecked)
end

PKBT_ThreeSliceVirtualCheckButtonMixin = CreateFromMixins(PKBT_ButtonMixin, PKBT_VirtualCheckButtonMixin)

function PKBT_ThreeSliceVirtualCheckButtonMixin:OnLoad()
	PKBT_VirtualCheckButtonMixin.OnLoad(self)
	PKBT_ButtonMixin.OnLoad(self)
end

function PKBT_ThreeSliceVirtualCheckButtonMixin:InitButton()
	self.leftAtlasInfo = C_Texture.GetAtlasInfo(self:GetLeftAtlasName())
	self.rightAtlasInfo = C_Texture.GetAtlasInfo(self:GetRightAtlasName())
end

function PKBT_ThreeSliceVirtualCheckButtonMixin:UpdateButton(buttonState)
	buttonState = self:GetButtonStateExt(buttonState)

	local atlasNamePostfix = ""
	if buttonState == "DISABLED" then
		atlasNamePostfix = "-Disabled"
	elseif buttonState == "HIGHLIGHT" then
		atlasNamePostfix = "-Highlight"
	elseif buttonState == "CHECKED" then
		atlasNamePostfix = "-Selected"
	elseif buttonState == "PUSHED" then
		atlasNamePostfix = "-Pressed"
	end

	local useAtlasSize = true
	self.Left:SetAtlas(self:GetLeftAtlasName()..atlasNamePostfix, useAtlasSize)
	self.Center:SetAtlas(self:GetCenterAtlasName()..atlasNamePostfix)
	self.Right:SetAtlas(self:GetRightAtlasName()..atlasNamePostfix, useAtlasSize)

	self:UpdateScale()
end

function PKBT_ThreeSliceVirtualCheckButtonMixin:OnEnter()
	self:UpdateButton()
	PKBT_ButtonMixin.OnEnter(self)
end

function PKBT_ThreeSliceVirtualCheckButtonMixin:OnLeave()
	self:UpdateButton()
	PKBT_ButtonMixin.OnLeave(self)
end

PKBT_ButtonMultiWidgetControllerMixin = {}

function PKBT_ButtonMultiWidgetControllerMixin:OnShow()
	local parent = self:GetParent()
	parent:UpdateHolderRect()
	parent:UpdateButton()
end

PKBT_ButtonMultiWidgetMixin = CreateFromMixins(PKBT_ButtonMixin)

function PKBT_ButtonMultiWidgetMixin:OnLoad()
	PKBT_ButtonMixin.OnLoad(self)
	self.__fontStringPoolCollection = CreateFontStringPoolCollection()
	self.__texturePool = CreateTexturePool(self.WidgetHolder, "ARTWORK")
	self.__activeObjects = {}
	self.__persistantObjectsPre = {}
	self.__persistantObjectsPost = {}
	self.__padding = 20
	self.__offsetX = 3

	Mixin(self.Controller, PKBT_ButtonMultiWidgetControllerMixin)
	self.Controller:SetScript("OnShow", self.Controller.OnShow)
end

function PKBT_ButtonMultiWidgetMixin:OnEnter()
	PKBT_ButtonMixin.OnEnter(self)
	self.__isMouseOver = true
	self:UpdateButton()
end

function PKBT_ButtonMultiWidgetMixin:OnLeave()
	PKBT_ButtonMixin.OnEnter(self)
	self.__isMouseOver = nil
	self:UpdateButton()
end

function PKBT_ButtonMultiWidgetMixin:OnMouseDown(button)
	PKBT_ButtonMixin.OnMouseDown(self, button)
	if self:IsEnabled() == 1 then
		local offsetX, offsetY = self:GetPushedTextOffset()
		self.WidgetHolder:SetPoint("CENTER", offsetX, offsetY)
	end
end

function PKBT_ButtonMultiWidgetMixin:OnMouseUp(button)
	PKBT_ButtonMixin.OnMouseUp(self, button)
	self.WidgetHolder:SetPoint("CENTER", 0, 0)
end

function PKBT_ButtonMultiWidgetMixin:SetPadding(padding)
	self.__padding = padding or 15
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:Show()
	if self:IsShown() then
		self.__dirty = true
		self:UpdateHolderRect()
	else
		getmetatable(self).__index.Show(self)
	end
end

function PKBT_ButtonMultiWidgetMixin:GetPadding()
	return self.__padding
end

function PKBT_ButtonMultiWidgetMixin:SetMinWidth(width)
	self.__minWidth = width
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:SetMaxWidth(width)
	self.__maxWidth = width
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:SetFixedWidth(width)
	self.__fixedWidth = width
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:GetFixedWidth()
	return self.__fixedWidth
end

function PKBT_ButtonMultiWidgetMixin:UpdateButton(buttonState)
	if not self:IsVisible() then
		return
	end

	buttonState = self:GetButtonStateExt(buttonState)

	if self.WidgetHolder:IsShown() then
		for _, obj in ipairs(self.__persistantObjectsPre) do
			self:UpdateWidgetState(obj, buttonState)
		end
		for _, obj in ipairs(self.__activeObjects) do
			self:UpdateWidgetState(obj, buttonState)
		end
		for _, obj in ipairs(self.__persistantObjectsPost) do
			self:UpdateWidgetState(obj, buttonState)
		end
	end

	if buttonState == "DISABLED" and self.noDisabledBackground then
		local useAtlasSize = true
		self.Left:SetAtlas(self:GetLeftAtlasName(), useAtlasSize)
		self.Center:SetAtlas(self:GetCenterAtlasName())
		self.Right:SetAtlas(self:GetRightAtlasName(), useAtlasSize)

		ThreeSliceButtonMixin.UpdateScale(self)
	else
		ThreeSliceButtonMixin.UpdateButton(self, buttonState)
	end
end

function PKBT_ButtonMultiWidgetMixin:UpdateWidgetState(obj, buttonState)
	if self.disableStateChange then
		return
	end

	if obj:IsObjectType("FontString") then
		if buttonState == "DISABLED" then
			if not self.noDisabledColor then
				if self.disabledColor then
					obj:SetTextColor(unpack(self.disabledColor, 1, 3))
				else
					obj:SetTextColor(0.5, 0.5, 0.5)
				end
			end
		else
			if self.__isMouseOver then
				if not self.noHighlightColor then
					if self.highlightColor then
						obj:SetTextColor(unpack(self.highlightColor, 1, 3))
					else
						obj:SetTextColor(1, 1, 1)
					end
				end
			else
				if self.highlightColor then
					obj:SetTextColor(unpack(self.highlightColor, 1, 3))
				else
					obj:SetTextColor(1, 0.82, 0)
				end
			end
		end
	elseif not self.noDesaturation and obj:IsObjectType("Texture") then
		obj:SetDesaturated(buttonState == "DISABLED")
	end
end

function PKBT_ButtonMultiWidgetMixin:UpdateWidgetPosition(obj, currentWidth)
	if not obj:IsShown() then
		return currentWidth
	end

	local objWidth
	if obj:IsShown() then
		if obj:IsObjectType("FontString") then
			objWidth = obj:GetStringWidth()
		else
			objWidth = obj:GetWidth()
		end
	end

	local offsetX
	if currentWidth == 0 and obj.offsetX >= 0 then
		offsetX = 0
	else
		offsetX = obj.offsetX
	end

	obj:ClearAllPoints()
	obj:SetPoint("LEFT", self.WidgetHolder, "LEFT", (currentWidth == 0 and 0 or currentWidth) + offsetX, obj.offsetY)

	return currentWidth + objWidth + offsetX
end

function PKBT_ButtonMultiWidgetMixin:UpdateHolderRect()
	if not self.__dirty then
		return
	end

	self.__dirty = nil

	local holderWidth = 0
	for _, obj in ipairs(self.__persistantObjectsPre) do
		holderWidth = self:UpdateWidgetPosition(obj, holderWidth)
	end
	for _, obj in ipairs(self.__activeObjects) do
		holderWidth = self:UpdateWidgetPosition(obj, holderWidth)
	end
	for _, obj in ipairs(self.__persistantObjectsPost) do
		holderWidth = self:UpdateWidgetPosition(obj, holderWidth)
	end

	local spinnerShown = self.__spinner and self.__spinner:IsShown()
	if spinnerShown then
		local spinnderHeight = self:GetHeight() - 10
		self.__spinner:SetSize(spinnderHeight, spinnderHeight)
	end

	if holderWidth ~= 0 then
		self.WidgetHolder:SetWidth(holderWidth)
		self.WidgetHolder:SetShown(not spinnerShown)
	else
		self.WidgetHolder:Hide()
	end

	local buttonWidth = holderWidth + self.__padding * 2
	if self.__minWidth or self.__maxWidth then
		if self.__maxWidth then
			buttonWidth = math.min(self.__maxWidth, buttonWidth)
		end
		if self.__minWidth then
			buttonWidth = math.max(self.__minWidth, buttonWidth)
		end
		self:SetWidth(buttonWidth)
	else
		self:SetWidth(math.max(60, self.__fixedWidth ~= 0 and self.__fixedWidth or buttonWidth))
	end
end

function PKBT_ButtonMultiWidgetMixin:ClearObjects()
	self.WidgetHolder:Hide()
	self.__fontStringPoolCollection:ReleaseAll()
	self.__texturePool:ReleaseAll()
	for _, obj in ipairs(self.__activeObjects) do
		obj:ClearAllPoints()
		obj:Hide()
	end
	table.wipe(self.__activeObjects)
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:ClearPersistantPreObjects()
	for _, obj in ipairs(self.__persistantObjectsPre) do
		obj:ClearAllPoints()
		obj:Hide()
	end
	table.wipe(self.__persistantObjectsPre)
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:ClearPersistantPostObjects()
	for _, obj in ipairs(self.__persistantObjectsPost) do
		obj:ClearAllPoints()
		obj:Hide()
	end
	table.wipe(self.__persistantObjectsPost)
	self.__dirty = true
end

function PKBT_ButtonMultiWidgetMixin:AddText(text, offsetX, offsetY, template)
	local pool = self.__fontStringPoolCollection:GetOrCreatePool(self.WidgetHolder, "ARTWORK", nil, template or "PKBT_Button_Font_15")
	local obj = pool:Acquire()
	table.insert(self.__activeObjects, obj)
	self.__dirty = true

	obj:SetText(text)
	obj.offsetX = tonumber(offsetX) or self.__offsetX
	obj.offsetY = tonumber(offsetY) or 0
	obj:Show()

	return obj
end

function PKBT_ButtonMultiWidgetMixin:AddTexture(texture, width, height, offsetX, offsetY)
	local obj = self.__texturePool:Acquire()
	table.insert(self.__activeObjects, obj)
	self.__dirty = true

	obj:SetTexture(texture)
	obj:SetSize(width or self:GetHeight(), height or self:GetHeight())
	obj.offsetX = tonumber(offsetX) or self.__offsetX
	obj.offsetY = tonumber(offsetY) or 0
	obj:Show()

	return obj
end

function PKBT_ButtonMultiWidgetMixin:AddTextureAtlas(atlasName, useAtlasSize, overrideWidth, overrideHeight, offsetX, offsetY)
	local obj = self.__texturePool:Acquire()
	table.insert(self.__activeObjects, obj)
	self.__dirty = true

	obj:SetAtlas(atlasName, useAtlasSize)
	if overrideWidth then
		obj:SetWidth(overrideWidth)
	elseif not useAtlasSize then
		obj:SetWidth(self:GetHeight() - self.__padding)
	end
	if overrideHeight then
		obj:SetHeight(overrideHeight)
	elseif not useAtlasSize then
		obj:SetHeight(self:GetHeight() - self.__padding)
	end

	obj.offsetX = tonumber(offsetX) or self.__offsetX
	obj.offsetY = tonumber(offsetY) or 0
	obj:Show()

	return obj
end

function PKBT_ButtonMultiWidgetMixin:AddFrame(obj, offsetX, offsetY)
	table.insert(self.__activeObjects, obj)
	self.__dirty = true

	obj:SetParent(self.WidgetHolder)
	obj.offsetX = tonumber(offsetX) or self.__offsetX
	obj.offsetY = tonumber(offsetY) or 0
	obj:Show()

	return obj
end

function PKBT_ButtonMultiWidgetMixin:MoveToPersistantPre(obj, index)
	local found
	for i, object in ipairs(self.__activeObjects) do
		if object == object then
			table.remove(self.__activeObjects, i)
			found = true
		end
	end

	if found then
		if not index or index > #self.__persistantObjectsPre then
			table.insert(self.__persistantObjectsPre, obj)
		else
			table.insert(self.__persistantObjectsPre, index, obj)
		end
		self.__dirty = true
	end

	return found or false
end

function PKBT_ButtonMultiWidgetMixin:MoveToPersistantPost(obj, index)
	local found
	for i, object in ipairs(self.__activeObjects) do
		if object == object then
			table.remove(self.__activeObjects, i)
			found = true
		end
	end

	if found then
		if not index or index > #self.__persistantObjectsPost then
			table.insert(self.__persistantObjectsPost, obj)
		else
			table.insert(self.__persistantObjectsPost, index, obj)
		end
		self.__dirty = true
	end

	return found or false
end

function PKBT_ButtonMultiWidgetMixin:ShowSpinner()
	PKBT_ButtonMixin.ShowSpinner(self)
	self.WidgetHolder:Hide()
end

function PKBT_ButtonMultiWidgetMixin:HideSpinner()
	PKBT_ButtonMixin.HideSpinner(self)
	if self.__spinner then
		self.WidgetHolder:Show()
	end
end

local CURRENCY_ICONS = {
	[0] = "PKBT-Icon-Currency-Gold",
	[1] = "PKBT-Icon-Currency-Bonus",
	[2] = "PKBT-Icon-Currency-Loyality",
	[3] = "PKBT-Icon-Currency-Vote",
	[4] = "PKBT-Icon-Currency-Referral",
}

PKBT_PriceMixin = {}

function PKBT_PriceMixin:OnShow()
	self:UpdatePriceRect()
end

function PKBT_PriceMixin:SetPrice(price, originalPrice, currencyType)
	if price ~= -1 then
		local isFree = price == 0
		self.currencyType = currencyType
		self.value = price
		self.originalPrice = originalPrice

		self.Value:Show()

		if isFree then
			self.Value:SetText(self.__freeText or STORE_BUY_FREE)
			self.Value:SetPoint("LEFT", 0, 0)
			self.Icon:Hide()
			self.ValueOriginal:Hide()
			self.StrikeThrough:Hide()
		else
			self.Value:SetText(price)
			self.Icon:SetAtlas(CURRENCY_ICONS[currencyType], false)
			self.Icon:Show()

			if not self.__originalPriceHidden and originalPrice and originalPrice > 0 and originalPrice ~= price then
				self.ValueOriginal:SetText(originalPrice)
				self.ValueOriginal:Show()
				self.StrikeThrough:Show()
				self:UpdateOriginalRect()
			else
				self.ValueOriginal:Hide()
				self.StrikeThrough:Hide()
				self.Value:SetPoint("LEFT", self.Icon, "RIGHT", 3, 0)
			end
		end
	else
		self.value = -1
		self.originalPrice = 0

		self.Value:Hide()
		self.Icon:Hide()
		self.ValueOriginal:Hide()
		self.StrikeThrough:Hide()
	end

	self:UpdatePriceRect()
end

function PKBT_PriceMixin:UpdateOriginalRect()
	if self.ValueOriginal:IsShown() then
		local originalValueWidth = self.ValueOriginal:GetStringWidth()
		self.StrikeThrough:SetWidth(originalValueWidth + 4)

		if self.__originalOnTop then
			local diff = originalValueWidth - self.Value:GetStringWidth()
			if diff > 0 then
				self.__originalOnTopOffsetX = math.ceil(diff) * 2 + 1
			else
				self.__originalOnTopOffsetX = 0
			end

			self.Value:SetPoint("LEFT", self.Icon, "RIGHT", 3 + math.floor(self.__originalOnTopOffsetX / 2 + 0.5), -(self.ValueOriginal:GetHeight() / 2) - 1)
			self.ValueOriginal:ClearAllPoints()
			self.ValueOriginal:SetPoint("BOTTOM", self.Value, "TOP", 0, 2)
		else
			self.ValueOriginal:ClearAllPoints()
			self.ValueOriginal:SetPoint("LEFT", self.Icon, "RIGHT", 4, -1)
			self.Value:SetPoint("LEFT", self.Icon, "RIGHT", 6 + originalValueWidth, 0)
		end
	end
end

function PKBT_PriceMixin:UpdatePriceRect()
	local width = 0

	if self.value and self.value ~= -1 then
		if self.Icon:IsShown() then
			width = width + self.Icon:GetWidth() + 3
		end

		if self.__originalOnTop then
			width = width + (self.__originalOnTopOffsetX or 0)
		elseif self.ValueOriginal:IsShown() then
			width = width + self.ValueOriginal:GetStringWidth() + 3
		end

		if self.Value:IsShown() then
			width = width + self.Value:GetStringWidth()
		end
	end

	self:SetWidth(width)
end

PKBT_ButtonMultiWidgetPriceContollerMixin = {}

function PKBT_ButtonMultiWidgetPriceContollerMixin:OnShow()
	local parent = self:GetParent()
	parent:UpdatePriceRect()
	parent:UpdateHolderRect()
	parent:UpdateButton()
end

function PKBT_ButtonMultiWidgetPriceContollerMixin:OnEvent(event, ...)
	local parent = self:GetParent()
	if event == "SERVICE_STATE_UPDATE" or event == "STORE_BALANCE_UPDATE" then
		if parent:IsShown() and parent.Price.currencyType == Enum.Store.CurrencyType.Bonus
		and parent.Price.value and parent.Price.value > 0
		then
			parent:CheckBalance()
		end
	end
end

function PKBT_PriceMixin:SetFreeText(text)
	self.__freeText = type(text) == "string" and text or nil
end

function PKBT_PriceMixin:SetOriginalPriceHidden(state)
	self.__originalPriceHidden = not not state
	if self.currencyType and self.value ~= -1 and self.ValueOriginal:IsShown() then
		self:UpdateOriginalRect()
		self:UpdatePriceRect()
	end
end

function PKBT_PriceMixin:SetOriginalOnTop(state)
	self.__originalOnTop = not not state
	if self.currencyType and self.value ~= -1 and self.ValueOriginal:IsShown() then
		self:UpdateOriginalRect()
		self:UpdatePriceRect()
	end
end

function PKBT_PriceMixin:SetCurrencyHelpTipEnabled(state)
	self.__tooltipEnabled = not not state
	self:SetScript("OnEnter", self.__tooltipEnabled and self.OnEnter or nil)
	self:SetScript("OnLeave", self.__tooltipEnabled and self.OnLeave or nil)
end

PKBT_ButtonMultiWidgetPriceMixin = CreateFromMixins(PKBT_ButtonMultiWidgetMixin)

function PKBT_ButtonMultiWidgetPriceMixin:OnLoad()
	PKBT_ButtonMultiWidgetMixin.OnLoad(self)

	self.PurchaseNote.Icon:SetAtlas("PKBT-Icon-Notification-White", true)
	self.PurchaseNote.Icon:SetVertexColor(0.961, 0.141, 0.141)

	self:AddFrame(self.Price):Hide()
	self:MoveToPersistantPost(self.Price)

	Mixin(self.Controller, PKBT_ButtonMultiWidgetPriceContollerMixin)
	self.Controller:SetScript("OnShow", self.Controller.OnShow)
	self.Controller:SetScript("OnEvent", self.Controller.OnEvent)
	self.Controller:RegisterCustomEvent("SERVICE_STATE_UPDATE")
	self.Controller:RegisterCustomEvent("STORE_BALANCE_UPDATE")
end

function PKBT_ButtonMultiWidgetPriceMixin:OnEnable()
	PKBT_ButtonMultiWidgetMixin.OnEnable(self)
	self:UpdatePriceColor()
end

function PKBT_ButtonMultiWidgetPriceMixin:OnDisable()
	PKBT_ButtonMultiWidgetMixin.OnDisable(self)
	self:UpdatePriceColor()
end

function PKBT_ButtonMultiWidgetPriceMixin:OnEnter()
	PKBT_ButtonMultiWidgetMixin.OnEnter(self)

	if self:IsEnabled() ~= 1 then
		if self.Price.currencyType and self.Price.value then
			local balance = Store_GetBalance(self.Price.currencyType)
			if self.Price.value > balance then
				self.Price.tooltip = true
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:AddLine(string.format(STORE_NOT_ENOUGHT_CURRENCY, balance))
				GameTooltip:Show()
			end
		end
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:OnLeave()
	PKBT_ButtonMultiWidgetMixin.OnLeave(self)

	if self.Price.tooltip then
		GameTooltip:Hide()
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:UpdatePriceRect()
	PKBT_PriceMixin.UpdatePriceRect(self.Price)

	if self:IsShown() then
		self:UpdateHolderRect()
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:SetOriginalPriceHidden(state)
	PKBT_PriceMixin.SetOriginalPriceHidden(self.Price, state)
	self.__dirty = true

	if self:IsShown() then
		self:UpdateHolderRect()
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:SetOriginalOnTop(state)
	PKBT_PriceMixin.SetOriginalOnTop(self.Price, state)
	self.__dirty = true

	if self:IsShown() then
		self:UpdateHolderRect()
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:UpdatePriceColor()
	if self:IsEnabled() ~= 1 then
		self.Price.Value:SetTextColor(0.5, 0.5, 0.5)
		self.Price.Icon:SetDesaturated(true)
	else
		self.Price.Icon:SetDesaturated(false)
		if self.Price.ValueOriginal:IsShown() then
			self.Price.Value:SetTextColor(0.102, 1, 0.102)
		else
			self.Price.Value:SetTextColor(1, 0.82, 0)
		end
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:SetPrice(price, originalPrice, currencyType)
	PKBT_PriceMixin.SetPrice(self.Price, price, originalPrice, currencyType)

	if price == -1 then
		self.Price:Hide()
	else
		self.Price:Show()
		self:UpdatePriceColor()
		self:CheckBalance()
	end

	self.__dirty = true
	self:UpdatePriceRect()
	self:UpdateButton()
end

function PKBT_ButtonMultiWidgetPriceMixin:CheckBalance()
	if self.Price.currencyType and self.Price.value then
		local balance = Store_GetBalance(self.Price.currencyType)

		if self.__allowReplenishment and self.Price.currencyType == Enum.Store.CurrencyType.Bonus then
			self.PurchaseNote:SetShown(self.__showReplenishmentIcon and self.Price.value > balance and not C_Service.IsInGMMode())
			self:Enable()
		else
			self.PurchaseNote:Hide()
			self:SetEnabled(self.Price.value <= balance or C_Service.IsInGMMode())
		end
	else
		self.PurchaseNote:Hide()
		self:Enable()
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:SetAllowReplenishment(state, showIcon)
	self.__allowReplenishment = not not state
	self.__showReplenishmentIcon = not not showIcon

	if self:IsShown() then
		self:CheckBalance()
	end
end

function PKBT_ButtonMultiWidgetPriceMixin:OnNoteEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(STORE_NOT_ENOUGH_CURRENCY_REPLENISH, 1, 1, 1)
	GameTooltip:Show()
end

function PKBT_ButtonMultiWidgetPriceMixin:OnNoteLeave()
	GameTooltip:Hide()
end

PKBT_CheckButtonBaseMixin = {}

function PKBT_CheckButtonBaseMixin:OnLoad()
	self:SetText(getmetatable(self).__index.GetText(self))
end

function PKBT_CheckButtonBaseMixin:OnShow()
	self:UpdateHitRect()
end

function PKBT_CheckButtonBaseMixin:SetText(text)
	self.ButtonText:SetText(text)
	self:UpdateHitRect()
end

function PKBT_CheckButtonBaseMixin:GetText()
	return self.ButtonText:GetText()
end

function PKBT_CheckButtonBaseMixin:UpdateHitRect()
	self:SetHitRectInsets(0, -(5 + self.ButtonText:GetStringWidth()), -4, -4)
end

function PKBT_CheckButtonBaseMixin:OnClick(button, userInput)
	if self:IsEnabled() == 1 then
		if type(self.OnChecked) == "function" then
			self:OnChecked(not not self:GetChecked(), userInput or false)
		end
	end
end

function PKBT_CheckButtonBaseMixin:SetChecked(checked)
	checked = not not checked
	if (not not self:GetChecked()) == checked then
		return
	end

	getmetatable(self).__index.SetChecked(self, checked)

	if type(self.OnChecked) == "function" then
		self:OnChecked(checked, false)
	end
end

PKBT_CheckButtonMixin = CreateFromMixins(PKBT_CheckButtonBaseMixin)

function PKBT_CheckButtonMixin:OnLoad()
	PKBT_CheckButtonBaseMixin.OnLoad(self)
	self:SetNormalAtlas("PKBT-Checkbox-Default")
	self:SetPushedAtlas("PKBT-Checkbox-Default")
	self:SetDisabledAtlas("PKBT-Checkbox-Default")
	self:GetDisabledTexture():SetDesaturated(true)
	self:SetHighlightAtlas("PKBT-Checkbox-Highlight")
	self:SetCheckedTexture("")
	self:GetCheckedTexture():SetAtlas("PKBT-Checkbox-Checked", true)
end

PKBT_RibbonMixin = {}

function PKBT_RibbonMixin:OnLoad()
	self.Left:SetAtlas("PKBT-Ribbon-Left", true)
	self.Right:SetAtlas("PKBT-Ribbon-Right", true)
	self.Center:SetAtlas("PKBT-Ribbon-Center", true)
end

function PKBT_RibbonMixin:SetText(text)
	self.Text:SetText(text)
end

PKBT_StatusBarMixin = {}

function PKBT_StatusBarMixin:OnLoad()
	self.Left:SetAtlas("PKBT-StatusBar-Background-Left", true)
	self.Right:SetAtlas("PKBT-StatusBar-Background-Right", true)
	self.Center:SetAtlas("PKBT-StatusBar-Background-Center")
	self.BarTexture:SetAtlas(self:GetAttribute("BarTexture") or "PKBT-StatusBar-Texture")

	self.value = self:GetValue()
	self.minValue, self.maxValue = self:GetMinMaxValues()
	self.Value:SetFormattedText("%u/%u", self.value, self.maxValue)
end

function PKBT_StatusBarMixin:OnEnter()
	local parent = self:GetParent()
	if type(parent.StatusBarEnter) == "function" then
		parent:StatusBarEnter()
	end
end

function PKBT_StatusBarMixin:OnLeave()
	local parent = self:GetParent()
	if type(parent.StatusBarLeave) == "function" then
		parent:StatusBarLeave()
	end
end

function PKBT_StatusBarMixin:SetStatusBarValue(value, isPercents)
	self.value = math.max(math.min(value, self.maxValue), self.minValue)
	self:SetValue(self.value)
	if self.maxValue == 0 then
		self.Value:SetFormattedText("%u", self.value)
	elseif isPercents then
		self.Value:SetFormattedText("%u%%", self.value)
	else
		self.Value:SetFormattedText("%u/%u", self.value, self.maxValue)
	end
end

function PKBT_StatusBarMixin:SetStatusBarMinMax(minValue, maxValue)
	self.minValue = minValue
	self.maxValue = maxValue
	self:SetMinMaxValues(minValue, maxValue)
end

PKBT_TabButtonMixin = {}

function PKBT_TabButtonMixin:OnLoad()
	self.Left:SetAtlas("PKBT-Tab-Background-Left", true)
	self.Right:SetAtlas("PKBT-Tab-Background-Right", true)
	self.Center:SetAtlas("PKBT-Tab-Background-Center")

	self.LeftHighlight:SetAtlas("PKBT-Tab-Background-Left", true)
	self.RightHighlight:SetAtlas("PKBT-Tab-Background-Right", true)
	self.CenterHighlight:SetAtlas("PKBT-Tab-Background-Center")

	self.PADDING = 20
	self.selected = false
end

function PKBT_TabButtonMixin:SetText(text)
	self.ButtonText:SetText(text)
	self:Resize()
end

function PKBT_TabButtonMixin:Resize()
	if self.autoWidth then
		self:SetWidth(self.ButtonText:GetStringWidth() + self.PADDING * 2)
	elseif self.fixedWidth then
		self:SetWidth(self.fixedWidth)
	end
end

function PKBT_TabButtonMixin:SetSelected(selected)
	selected = not not selected
	if self.selected ~= selected then
		self.selected = selected
		if selected then
			self.Left:SetAtlas("PKBT-Tab-Background-Left-Selected", true)
			self.Right:SetAtlas("PKBT-Tab-Background-Right-Selected", true)
			self.Center:SetAtlas("PKBT-Tab-Background-Center-Selected")
			self:SetHeight(44)
			self.ButtonText:SetPoint("CENTER", 0, 2)
			self:SetPushedTextOffset(0, 0)
		else
			self.Left:SetAtlas("PKBT-Tab-Background-Left", true)
			self.Right:SetAtlas("PKBT-Tab-Background-Right", true)
			self.Center:SetAtlas("PKBT-Tab-Background-Center")
			self:SetHeight(38)
			self.ButtonText:SetPoint("CENTER", 0, 6)
			self:SetPushedTextOffset(2, -1)
		end
	end
end

function PKBT_TabButtonMixin:IsSelected()
	return self.selected
end

PKBT_TabButtonWithIconMixin = CreateFromMixins(PKBT_TabButtonMixin)

function PKBT_TabButtonWithIconMixin:OnLoad()
	PKBT_TabButtonMixin.OnLoad(self)

	self.ICON_OFFSET = 5
	self.Icon:SetPoint("RIGHT", self.ButtonText, "LEFT", -self.ICON_OFFSET, 0)
end

function PKBT_TabButtonWithIconMixin:Resize()
	if self.autoWidth and self.Icon:IsShown() then
		self:SetWidth(self.Icon:GetWidth() + self.ICON_OFFSET + self.ButtonText:GetStringWidth() + self.PADDING * 2)
	else
		PKBT_TabButtonMixin.Resize(self)
		self:UpdateTextPosition()
	end
end

function PKBT_TabButtonWithIconMixin:UpdateTextPosition()
	if self.Icon:IsShown() then
		if self:IsSelected() then
			self.ButtonText:SetPoint("CENTER", (math.floor((self.Icon:GetWidth() + self.ICON_OFFSET) / 2)), 2)
		else
			self.ButtonText:SetPoint("CENTER", (math.floor((self.Icon:GetWidth() + self.ICON_OFFSET) / 2)), 6)
		end
	else
		if self:IsSelected() then
			self.ButtonText:SetPoint("CENTER", 0, 2)
		else
			self.ButtonText:SetPoint("CENTER", 0, 6)
		end
	end
end

function PKBT_TabButtonWithIconMixin:SetSelected(selected)
	PKBT_TabButtonMixin.SetSelected(self, selected)

	if self.Icon:IsShown() then
		self:UpdateTextPosition()
	end
end

function PKBT_TabButtonWithIconMixin:SetIcon(texture, isAtlas, useAtlasSize)
	if not texture then
		self.Icon:Hide()
		self.ButtonText:SetPoint("CENTER", 0, 0)
		self:Resize()
	elseif isAtlas then
		self.Icon:SetAtlas(texture, useAtlasSize)
		self.Icon:Show()
		self.ButtonText:SetPoint("CENTER", math.floor(self.Icon:GetWidth() + self.ICON_OFFSET / 2), 0)
		self:Resize()
	else
		self.Icon:SetTexture(texture)
		self.Icon:Show()
	end
end

function PKBT_TabButtonWithIconMixin:SetIconSize(size)
	self.Icon:SetSize(size, size)
end

function PKBT_TabButtonWithIconMixin:OnMouseDown(button)
	if self:IsEnabled() == 1 and not self:IsSelected() then
		self.Icon:SetPoint("RIGHT", self.ButtonText, "LEFT", -self.ICON_OFFSET + 2, -1)
	end
end

function PKBT_TabButtonWithIconMixin:OnMouseUp(button)
	if self:IsEnabled() == 1 then
		self.Icon:SetPoint("RIGHT", self.ButtonText, "LEFT", -self.ICON_OFFSET, 0)
	end
end

PKBT_UIPanelScrollBarMixin = {}

function PKBT_UIPanelScrollBarMixin:OnLoad()
	self.Top:SetAtlas("PKBT-ScrollBar-Vertical-Background-Top", true)
	self.Bottom:SetAtlas("PKBT-ScrollBar-Vertical-Background-Bottom", true)
	self.Middle:SetAtlas("PKBT-ScrollBar-Vertical-Background-Middle")

	self.ThumbTextureTop:SetAtlas("PKBT-ScrollBar-Vertical-Thumb-Top", true)
	self.ThumbTextureBottom:SetAtlas("PKBT-ScrollBar-Vertical-Thumb-Bottom", true)
	self.ThumbTextureMiddle:SetAtlas("PKBT-ScrollBar-Vertical-Thumb-Middle", true)

	self.ThumbTextureTop:SetPoint("TOP", self.ThumbTexture, "TOP", 0, 0)
	self.ThumbTextureBottom:SetPoint("BOTTOM", self.ThumbTexture, "BOTTOM", 0, 0)
end

function PKBT_UIPanelScrollBarMixin:OnSizeChanged(width, height)
	self:UpdateThumbSize(width, height)
end

function PKBT_UIPanelScrollBarMixin:OnMinMaxChanged(minValue, maxValue)
	self:UpdateThumbSize(nil, nil, minValue, maxValue)
end

function PKBT_UIPanelScrollBarMixin:UpdateThumbSize(width, height, minValue, maxValue)
	if not minValue or not maxValue then
		minValue, maxValue = self:GetMinMaxValues()
	end
	if minValue == 0 and maxValue == 0 then
		self.ThumbTexture:SetHeight(self:GetHeight())
	elseif maxValue ~= 0 then
		if not height then
			height = self:GetHeight()
		end
		local parentHeight = self:GetParent():GetHeight()
		local visibleHeight = parentHeight / (maxValue + parentHeight) * height
		self.ThumbTexture:SetHeight(math.min(math.max(27, visibleHeight), height * 0.5))
	elseif height then
		self.ThumbTexture:SetHeight(height)
	end
end

function PKBT_UIPanelScrollBarMixin:SetScrollBarHideable(state)
	state = not not state
	self:GetParent().scrollBarHideable = state
end

function PKBT_UIPanelScrollBarMixin:SetBackgroundShown(state)
	self.Top:SetShown(state)
	self.Bottom:SetShown(state)
	self.Middle:SetShown(state)
end

PKBT_MinimalScrollBarButtonMixin = {}

function PKBT_MinimalScrollBarButtonMixin:OnLoad()
	local direction = self:GetAttribute("direction")
	self:SetNormalAtlas(string.format("PKBT-ScrollBar-Slim-Button-%s", direction), true)
	self:SetPushedAtlas(string.format("PKBT-ScrollBar-Slim-Button-%s-Pressed", direction), true)
	self:SetDisabledAtlas(string.format("PKBT-ScrollBar-Slim-Button-%s", direction), true)
	self:SetHighlightAtlas(string.format("PKBT-ScrollBar-Slim-Button-%s-Highlight", direction), true)
	self:GetDisabledTexture():SetVertexColor(0.5, 0.5, 0.5)
	self:Disable()
	self:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
	self.parentScrollBar = self:GetParent()
	self.parentScrollFrame = self.parentScrollBar:GetParent()
	self.direction = direction == "Left" and 1 or -1
end

function PKBT_MinimalScrollBarButtonMixin:OnClick(button, down)
	if down then
		self.timeSinceLast = (self.timeToStart or -0.2)
		self:SetScript("OnUpdate", self.OnUpdate)
		self.parentScrollFrame:OnMouseWheel(self.direction)
		PlaySound("UChatScrollButton")
	else
		self:SetScript("OnUpdate", nil)
	end
end

function PKBT_MinimalScrollBarButtonMixin:OnUpdate(elapsed)
	self.timeSinceLast = self.timeSinceLast + elapsed

	if self.timeSinceLast >= (self.parentScrollBar.updateInterval or 0.08) then
		if not IsMouseButtonDown("LeftButton") then
			self:SetScript("OnUpdate", nil)
		else
			self.parentScrollFrame:OnMouseWheel(self.direction, (self.parentScrollBar.stepSize or self.parentScrollFrame.buttonWidth / 3))
			self.timeSinceLast = 0
		end
	end
end

PKBT_MinimalScrollBarHorizontalMixin = {}

function PKBT_MinimalScrollBarHorizontalMixin:OnLoad()
	self.Left:SetAtlas("PKBT-ScrollBar-Slim-Horizontal-Background-Left", true)
	self.Right:SetAtlas("PKBT-ScrollBar-Slim-Horizontal-Background-Right", true)
	self.Center:SetAtlas("PKBT-ScrollBar-Slim-Horizontal-Background-Center")

	self.ThumbLeft:SetAtlas("PKBT-ScrollBar-Slim-Horizontal-Background-Thumb-Left", true)
	self.ThumbRight:SetAtlas("PKBT-ScrollBar-Slim-Horizontal-Background-Thumb-Right", true)
	self.ThumbCenter:SetAtlas("PKBT-ScrollBar-Slim-Horizontal-Background-Thumb-Center")

	self.ThumbLeft:SetPoint("LEFT", self.ThumbTexture, "LEFT", 0, 0)
	self.ThumbRight:SetPoint("RIGHT", self.ThumbTexture, "RIGHT", 0, 0)
	self.ThumbCenter:SetPoint("TOPLEFT", self.ThumbLeft, "TOPRIGHT", 0, 0)
	self.ThumbCenter:SetPoint("BOTTOMRIGHT", self.ThumbRight, "BOTTOMLEFT", 0, 0)
end

function PKBT_MinimalScrollBarHorizontalMixin:OnValueChanged(value)
	local parent = self:GetParent()
	parent:SetOffset(value)
	parent:UpdateButtonStates(value)
end

PKBT_MinimalHorizontalScrollMixin = {}

function PKBT_MinimalHorizontalScrollMixin:OnScrollRangeChanged(xrange, yrange)
	local parent = self:GetParent()
	if type(parent.OnScrollRangeChanged) == "function" then
		parent:OnScrollRangeChanged(xrange, yrange)
	end
end

function PKBT_MinimalHorizontalScrollMixin:OnHorizontalScroll(offset, scrollWidth)
	local parent = self:GetParent()
	if type(parent.OnHorizontalScroll) == "function" then
		parent:OnHorizontalScroll(offset, scrollWidth)
	end
end

function PKBT_MinimalHorizontalScrollMixin:OnMouseWheel(delta, stepSize)
	if not self.ScrollBar:IsVisible() or not self.ScrollBar:IsEnabled() then
		return
	end

	local minVal, maxVal = 0, self.range
	stepSize = stepSize or self.stepSize or self.buttonWidth
	if delta > 0 then
		self.ScrollBar:SetValue(math.max(minVal, self.ScrollBar:GetValue() - stepSize))
	else
		self.ScrollBar:SetValue(math.min(maxVal, self.ScrollBar:GetValue() + stepSize))
	end
end

function PKBT_MinimalHorizontalScrollMixin:UpdateButtonStates(value)
	if not value then
		value = self.ScrollBar:GetValue()
	end

	self.ScrollBar.ScrollLeftButton:Enable()
	self.ScrollBar.ScrollRightButton:Enable()

	local minVal, maxVal = self.ScrollBar:GetMinMaxValues()
	if value >= maxVal then
		self.ScrollBar.ThumbTexture:Show()
		if self.ScrollBar.ScrollRightButton then
			self.ScrollBar.ScrollRightButton:Disable()
		end
	end
	if value <= minVal then
		self.ScrollBar.ThumbTexture:Show()
		if self.ScrollBar.ScrollLeftButton then
			self.ScrollBar.ScrollLeftButton:Disable()
		end
	end
end

function PKBT_MinimalHorizontalScrollMixin:Update(totalWidth, displayedWidth)
	local range = floor(totalWidth - self:GetWidth() + 0.5)
	if range > 0 and self.ScrollBar then
		local minVal, maxVal = self.ScrollBar:GetMinMaxValues()
		if math.floor(self.ScrollBar:GetValue()) >= math.floor(maxVal) then
			self.ScrollBar:SetMinMaxValues(0, range)
			if range < maxVal then
				if math.floor(self.ScrollBar:GetValue()) ~= math.floor(range) then
					self.ScrollBar:SetValue(range)
				else
					self:SetOffset(range)
				end
			end
		else
			self.ScrollBar:SetMinMaxValues(0, range)
		end
		self.ScrollBar:Enable()
		self:UpdateButtonStates()
		self.ScrollBar:Show()
	elseif self.ScrollBar then
		self.ScrollBar:SetValue(0)
		if self.ScrollBar.doNotHide then
			self.ScrollBar:Disable()
			self.ScrollBar.ScrollLeftButton:Disable()
			self.ScrollBar.ScrollRightButton:Disable()
			self.ScrollBar.ThumbTexture:Hide()
		else
			self.ScrollBar:Hide()
		end
	end

	self.range = range
	self.totalWidth = totalWidth
	self.ScrollChild:SetWidth(displayedWidth or self:GetWidth())
	self:UpdateScrollChildRect()
end

function PKBT_MinimalHorizontalScrollMixin:GetOffset()
	return math.floor(self.offset or 0), (self.offset or 0)
end

function PKBT_MinimalHorizontalScrollMixin:SetOffset(offset)
	local element, scrollWidth
	local offsetNoInitX = offset - self.initialOffsetX

	if offsetNoInitX > self.buttonWidth then
		element = offsetNoInitX / self.buttonWidth
		local overflow = element - math.floor(element)
		scrollWidth = (overflow * self.buttonWidth) + self.initialOffsetX
	else
		element = 0
		scrollWidth = offset
	end

	if self.update and math.floor(self.offset or 0) ~= math.floor(element) then
		self.offset = element
		self:update()
	else
		self.offset = element
	end

	self:SetHorizontalScroll(scrollWidth)
	self:OnHorizontalScroll(offset, scrollWidth)
end

function PKBT_MinimalHorizontalScrollMixin:SetDoNotHideScrollBar(doNotHide)
	if not self.ScrollBar or self.ScrollBar.doNotHide == doNotHide then
		return
	end

	self.ScrollBar.doNotHide = doNotHide
	self:Update(self.totalWidth or 0, self.ScrollChild:GetWidth())
end

function PKBT_MinimalHorizontalScrollMixin:CreateButtons(buttonTemplate, buttonNameFormat, initialOffsetX, initialOffsetY, initialPoint, initialRelative, offsetX, offsetY, point, relativePoint)
	offsetX = offsetX or 0
	offsetY = offsetY or 0

	local parentName = self:GetName()
	local buttonWidth

	self.initialOffsetX = initialOffsetX or 0

	local buttons = self.buttons
	if buttons then
		buttonWidth = buttons[1]:GetWidth()
	else
		local button = CreateFrame("BUTTON", parentName and string.format(buttonNameFormat or "$parentButton%u", 1) or nil, self.ScrollChild, buttonTemplate)
		buttonWidth = button:GetWidth()
		button:SetPoint(initialPoint or "TOPLEFT", self.ScrollChild, initialRelative or "TOPLEFT", self.initialOffsetX, initialOffsetY or 0)
		buttons = {}
		tinsert(buttons, button)
	end

	self.buttonWidth = math.floor(buttonWidth + offsetX + .5)

	local numButtons = math.ceil(self:GetWidth() / self.buttonWidth) + 1

	for i = #buttons + 1, numButtons do
		local button = CreateFrame("BUTTON", parentName and string.format(buttonNameFormat or "$parentButton%u", i) or nil, self.ScrollChild, buttonTemplate)
		button:SetPoint(point or "TOPLEFT", buttons[i - 1], relativePoint or "TOPRIGHT", offsetX, offsetY)
		tinsert(buttons, button)
	end

	local scrollWidth = numButtons * self.buttonWidth + initialOffsetX * 2 - offsetX

	self.ScrollChild:SetSize(scrollWidth, self:GetHeight())
	self:SetVerticalScroll(0)
	self:UpdateScrollChildRect()

	self.buttons = buttons
	if self.ScrollBar then
		self.ScrollBar:SetMinMaxValues(0, scrollWidth)
		self.ScrollBar:SetValueStep(0.005)
		self.ScrollBar.buttonWidth = self.buttonWidth
		self.ScrollBar:SetValue(0)
	end
end

function PKBT_MinimalHorizontalScrollMixin:GetButtons()
	return self.buttons
end

function PKBT_MinimalHorizontalScrollMixin:ScrollToIndex(index, getWidthFunc)
	local totalWidth = 0
	local scrollFrameWidth = self:GetWidth()
	for i = 1, index do
		local entryWidth = getWidthFunc(i)
		if i == index then
			local offset = 0
			if totalWidth + entryWidth > scrollFrameWidth then
				if entryWidth > scrollFrameWidth then
					offset = totalWidth
				else
					local diff = scrollFrameWidth - entryWidth
					offset = totalWidth - diff / 2
				end

				local valueStep = self.ScrollBar:GetValueStep()
				offset = offset + valueStep - math.fmod(offset, valueStep)

				if offset > totalWidth then
					offset = offset - valueStep
				end
			end

			self.ScrollBar:SetValue(offset)
			break
		end
		totalWidth = totalWidth + entryWidth
	end
end

function PKBT_MinimalHorizontalScrollMixin:Disable()
	self.ScrollBar:Disable()
	self.ScrollBar.ScrollLeftButton:Disable()
	self.ScrollBar.ScrollRightButton:Disable()
end

PKBT_ScrollShadowMixin = {}

function PKBT_ScrollShadowMixin:OnLoad()
	self.Top:SetAtlas("PKBT-Background-Shadow-Small-Bottom", true)
	self.Top:SetSubTexCoord(0, 1, 1, 0)
	self.Bottom:SetAtlas("PKBT-Background-Shadow-Small-Bottom", true)

	self:GetParent().ScrollBar:HookScript("OnValueChanged", function(this, value)
		self:UpdateAlpha(this, value)
	end)
	self:GetParent().ScrollBar:HookScript("OnMinMaxChanged", function(this)
		self:UpdateAlpha(this)
	end)
	self:GetParent().ScrollBar.ScrollDownButton:HookScript("OnEnable", function(this)
		self:UpdateAlpha(this:GetParent())
	end)
	self:GetParent().ScrollBar.ScrollDownButton:HookScript("OnDisable", function(this)
		self.Bottom:SetAlpha(0)
	end)
end

function PKBT_ScrollShadowMixin:OnShow()
	self:UpdateFrameLevel()
	self:UpdateAlpha()
end

function PKBT_ScrollShadowMixin:SetFrameLevelOffset(offset)
	self.__frameLevelOffset = type(offset) == "number" and offset or nil
	if self:IsShown() then
		self:UpdateFrameLevel()
	end
end

function PKBT_ScrollShadowMixin:SetEnabled(enabled)
	enabled = not not enabled
	self.__disabled = not enabled
	if enabled then
		self:UpdateAlpha()
	else
		self.Top:SetAlpha(0)
		self.Bottom:SetAlpha(0)
	end
end

function PKBT_ScrollShadowMixin:UpdateFrameLevel()
	SetParentFrameLevel(self, self.__frameLevelOffset or 5)
end

function PKBT_ScrollShadowMixin:UpdateAlpha(scrollBar, value)
	if not self:IsShown() or self.__disabled then
		return
	end

	if not scrollBar then
		scrollBar = self:GetParent().ScrollBar
	end
	if not value then
		value = scrollBar:GetValue() or 0
	end

	local minValue, maxValue = scrollBar:GetMinMaxValues()
	local topHeight = self.Top:GetHeight()
	local bottomHeight = self.Bottom:GetHeight()

	if value == 0 then
		self.Top:SetAlpha(0)
	elseif (value - minValue >= topHeight) then
		self.Top:SetAlpha(1)
	else
		self.Top:SetAlpha((value - minValue) / topHeight)
	end

	if (value - maxValue) == 0 then
		self.Bottom:SetAlpha(0)
	elseif (value + bottomHeight <= maxValue) then
		self.Bottom:SetAlpha(1)
	else
		self.Bottom:SetAlpha((maxValue - value) / bottomHeight)
	end
end

PKBT_EditBoxCodeMixin = {}

function PKBT_EditBoxCodeMixin:OnChar(char)
	if self.__blockChanges then
		self:SetText(self.__originalText)
		if self.__autoSelectOnBlock then
			self:HighlightText()
		end
	else
		if self.__filterFunction then
			local text = self:GetText()
			local success, result = pcall(self.__filterFunction, text)
			if success then
				self:SetText(result or text)
			else
				geterrorhandler()(result)
			end
		end
		if self.__noNewLine then
			self:SetText(self:GetText():gsub("[\n\r]", ""))
		end
		if self.__noWhitespace then
			self:SetText(self:GetText():gsub("%s", ""))
		elseif self.__noMultipleSpaces then
			self:SetText(self:GetText():gsub("%s%s+", " "))
		end
	end
end

function PKBT_EditBoxCodeMixin:OnTabPressed()
	InputScrollFrame_OnTabPressed(self)
end

function PKBT_EditBoxCodeMixin:OnEscapePressed()
	self:ClearFocus()
end

function PKBT_EditBoxCodeMixin:OnTextSet()
	if self.__blockChanges then
		self.__originalText = self:GetText()
	end
end

function PKBT_EditBoxCodeMixin:OnTextChanged(userInput)
	if self.__ignoreTextChanged then
		return
	end

	local text = self:GetText()
	self.Instructions:SetShown(text == "")

	if type(self.OnValueChanged) == "function" then
		self.OnValueChanged(text, userInput)
	end
end

function PKBT_EditBoxCodeMixin:SetTextNoScript(text)
	self.__ignoreTextChanged = true
	self:SetText(text)
	self.__ignoreTextChanged = nil
end

function PKBT_EditBoxCodeMixin:SetBlockChanges(state)
	self.__blockChanges = not not state
	self.__originalText = self:GetText()
end

function PKBT_EditBoxCodeMixin:SetSelectOnBlock(state)
	self.__autoSelectOnBlock = not not state
end

function PKBT_EditBoxCodeMixin:SetBlockNewLines(state)
	self.__noNewLine = not not state
	if self.__noNewLine then
		self:OnChar("")
	end
end

function PKBT_EditBoxCodeMixin:SetBlockMultipleSpaces(state)
	self.__noMultipleSpaces = not not state
	if self.__noMultipleSpaces then
		self:OnChar("")
	end
end

function PKBT_EditBoxCodeMixin:SetBlockWhitespaces(state)
	self.__noWhitespace = not not state
	if self.__noWhitespace then
		self:OnChar("")
	end
end

function PKBT_EditBoxCodeMixin:SetCustomCharFilter(filterFunction)
	self.__filterFunction = type(filterFunction) == "function" and filterFunction or nil
	if self.__filterFunction then
		self:OnChar("")
	end
end

function PKBT_EditBoxCodeMixin:SetInstructions(instructions)
	assert(instructions == nil or type(instructions) == "string")
	self.Instructions:SetText(instructions)
end

PKBT_EditBoxMixin = CreateFromMixins(PKBT_EditBoxCodeMixin)

function PKBT_EditBoxMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Input-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Input-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Input-Background-Center", true)

	self.Instructions:SetFontObject("PKBT_Font_16")
	self.Instructions:ClearAllPoints()
	self.Instructions:SetPoint("LEFT", 9, -2)
end

PKBT_EditBoxAltMixin = CreateFromMixins(PKBT_EditBoxCodeMixin)

function PKBT_EditBoxAltMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-InputAlt-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-InputAlt-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-InputAlt-Background-Center", true)

	self.Instructions:ClearAllPoints()
	self.Instructions:SetPoint("LEFT", 9, -2)
end

PKBT_MultiBuyEditBoxMixin = CreateFromMixins(PKBT_EditBoxMixin)

function PKBT_MultiBuyEditBoxMixin:OnLoad()
	PKBT_EditBoxMixin.OnLoad(self)

	self.DecrementButton:SetNormalAtlas("PKBT-Icon-Minus")
	self.DecrementButton:SetDisabledAtlas("PKBT-Icon-Minus-Disabled")
	self.DecrementButton:SetPushedAtlas("PKBT-Icon-Minus-Pressed")
	self.DecrementButton:SetHighlightAtlas("PKBT-Icon-PlusMinus-Highlight")

	self.IncrementButton:SetNormalAtlas("PKBT-Icon-Plus")
	self.IncrementButton:SetDisabledAtlas("PKBT-Icon-Plus-Disabled")
	self.IncrementButton:SetPushedAtlas("PKBT-Icon-Plus-Pressed")
	self.IncrementButton:SetHighlightAtlas("PKBT-Icon-PlusMinus-Highlight")
end

function PKBT_MultiBuyEditBoxMixin:OnTextChanged(userInput)
	if self.__ignoreTextChanged then
		return
	end

	local value = self:GetNumber() or 0

	if userInput then
		local originalValue = value

		if type(self.maxValue) == "number" then
			value = math.min(self.maxValue, value)
		elseif type(self.maxValue) == "function" then
			value = math.min(self.maxValue(), value)
		end

		if type(self.minValue) == "number" then
			value = math.max(self.minValue, value)
		elseif type(self.minValue) == "function" then
			value = math.max(self.minValue(), value)
		end

		if value ~= originalValue then
			self:SetText(value)
			return
		end
	end

	if not self.minValue
	or (type(self.minValue) == "number" and self.minValue < value)
	or (type(self.minValue) == "function" and self.minValue() < value)
	then
		self.DecrementButton:Enable()
	else
		self.DecrementButton:Disable()
	end

	if not self.maxValue
	or (type(self.maxValue) == "number" and self.maxValue > value)
	or (type(self.maxValue) == "function" and self.maxValue() > value)
	then
		self.IncrementButton:Enable()
	else
		self.IncrementButton:Disable()
	end

	if type(self.OnValueChanged) == "function" then
		self.OnValueChanged(value, userInput)
	end
end

function PKBT_MultiBuyEditBoxMixin:SetTextNoScript(text)
	self.__ignoreTextChanged = true
	self:SetText(text)
	self.__ignoreTextChanged = nil
end
PKBT_CountdownThrottledBaseMixin = {}

function PKBT_CountdownThrottledBaseMixin:OnCountdownUpdate(timeLeft, isFinished)
end

function PKBT_CountdownThrottledBaseMixin:SetCountdown(timeLeft, throttleSec, customUpdateHandler, ceilTime)
	if type(timeLeft) == "number" and timeLeft > 0 then
		self.__timeLeft = timeLeft
		self.__throttleSec = throttleSec or 0.1
		self.__elapsed = 0
		self.__ceilTime = ceilTime
		self:SetScript("OnUpdate", self.OnUpdate)
	else
		self:CancelCountdown()
	end

	if type(customUpdateHandler) == "function" then
		self.__customUpdateHandler = customUpdateHandler
	else
		self.__customUpdateHandler = nil
	end

	local handler = self.__customUpdateHandler or self.OnCountdownUpdate
	handler(self, ceilTime and math.ceil(self.__timeLeft) or self.__timeLeft, false)
end

function PKBT_CountdownThrottledBaseMixin:SetTimeLeft(timeLeft, throttleSec, customUpdateHandler)
	self:SetCountdown(timeLeft, throttleSec, customUpdateHandler, true)
end

function PKBT_CountdownThrottledBaseMixin:CancelCountdown()
	self.__timeLeft = 0
	self:SetScript("OnUpdate", nil)
end

function PKBT_CountdownThrottledBaseMixin:OnUpdate(elapsed)
	self.__elapsed = self.__elapsed + elapsed

	if self.__elapsed >= self.__throttleSec then
		self.__timeLeft = self.__timeLeft - self.__elapsed
		self.__elapsed = 0

		local handler = self.__customUpdateHandler or self.OnCountdownUpdate

		if self.__timeLeft <= 0 then
			self.__timeLeft = 0
			self:SetScript("OnUpdate", nil)
			handler(self, self.__timeLeft, true)
		else
			handler(self, self.__ceilTime and math.ceil(self.__timeLeft) or self.__timeLeft, false)
		end
	end
end