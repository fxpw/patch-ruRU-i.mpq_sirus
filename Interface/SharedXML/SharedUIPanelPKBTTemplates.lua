Enum.ModelType = Enum.CreateMirror({
	M2 = 0,
	Unit = 1,
	Creature = 2,
	Item = 3,
	ItemSet = 4,
	Illusion = 5,
	ItemTransmog = 6,
})

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

PKBT_MaximizeMinimizeButton = {}

function PKBT_MaximizeMinimizeButton:SetMinimizeLook(state)
	if state then
		self:SetNormalAtlas("RedButton-Condense")
		self:SetPushedAtlas("RedButton-Condense-Pressed")
		self:SetDisabledAtlas("RedButton-Condense-disabled")
		self:SetHighlightAtlas("RedButton-Highlight")
	else
		self:SetNormalAtlas("RedButton-Expand")
		self:SetPushedAtlas("RedButton-Expand-Pressed")
		self:SetDisabledAtlas("RedButton-Expand-Disabled")
		self:SetHighlightAtlas("RedButton-Highlight")
	end
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

PKBT_ButtonGlowMixin = {}

function PKBT_ButtonGlowMixin:OnLoad()
	self.Left:SetAtlas("PKBT-Button-Glow-Left", true)
	self.Right:SetAtlas("PKBT-Button-Glow-Right", true)
	self.Center:SetAtlas("PKBT-Button-Glow-Center")
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
	self:OnEnterTooltip()
end

function PKBT_ButtonMultiWidgetMixin:OnLeave()
	PKBT_ButtonMixin.OnEnter(self)
	self.__isMouseOver = nil
	self:UpdateButton()
	self:OnLeaveTooltip()
end

function PKBT_ButtonMultiWidgetMixin:OnEnterTooltip()
	if self.disabledReason then
		self.tooltipShown = true
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(self.disabledReason, 1, 0.1, 0.1, true)
		GameTooltip:Show()
	end
end

function PKBT_ButtonMultiWidgetMixin:OnLeaveTooltip()
	if self.tooltipShown then
		self.tooltipShown = nil
		GameTooltip:Hide()
	end
end

function PKBT_ButtonMultiWidgetMixin:RefreshTooltip()
	self:OnLeaveTooltip()
	self:OnEnterTooltip()
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

function PKBT_ButtonMultiWidgetMixin:SetDisabledReason(reason)
	self.disabledReason = reason
end

PKBT_CurrencyMixin = {}

function PKBT_CurrencyMixin:OnEnter()
	if not self.tooltipDisabled and self.currencyType then
		if self.description then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if self.tooltipTitle then
				GameTooltip:AddLine(string.format("%s - %s", self.tooltipTitle, self.name))
			else
				GameTooltip:AddLine(self.name)
			end
			GameTooltip:AddLine(self.description, 1, 1, 1, true)
			GameTooltip:Show()
		elseif self.link then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.link)
			GameTooltip:Show()
		end
	end
end

function PKBT_CurrencyMixin:OnLeave()
	if not self.tooltipDisabled then
		GameTooltip:Hide()
	end
end

function PKBT_CurrencyMixin:UpdatePriceRect()
	local width = 0

	if self.Icon:IsShown() then
		width = width + self.Icon:GetWidth() + (self.offsetX or 5)
	end
	if self.Value:IsShown() then
		width = width + self.Value:GetStringWidth()
	end

	self:SetWidth(width)
end

function PKBT_CurrencyMixin:SetValue(amount, currencyType)
	local success = true
	if currencyType then
		success = self:SetCurrencyType(currencyType)
	end
	if success then
		self.Value:SetText(amount)
		self:UpdatePriceRect()
		if type(self.OnAmountChanged) == "function" then
			self.OnAmountChanged(self, amount)
		end
	end
end

function PKBT_CurrencyMixin:SetCurrencyType(currencyType)
	local isOnGlueScreen = IsOnGlueScreen()

	if isOnGlueScreen and currencyType then
		self.currencyType = currencyType
		self.Icon:SetAtlas(currencyType, false)
		self:Show()

		return true
	elseif not isOnGlueScreen and currencyType and C_StorePublic.IsValidCurrencyType(currencyType) then
		local name, description, link, texture, iconAtlas = C_StorePublic.GetCurrencyInfo(currencyType)
		self.currencyType = currencyType
		self.name = name
		self.description = description
		self.link = link

		if iconAtlas then
			self.Icon:SetAtlas(iconAtlas, false)
		else
			self.Icon:SetTexCoord(0, 1, 0, 1)
			self.Icon:SetTexture(texture or [[Interface\Icons\INV_Misc_QuestionMark]])
		end
		self:Show()

		return true
	else
		self.currencyType = nil
		self.name = nil
		self.description = nil
		self.link = nil
		self:Hide()

		return false
	end
end

function PKBT_CurrencyMixin:UpdateTextOffset()
	self.Value:ClearAllPoints()
	if self.invertSide then
		self.Value:SetPoint("RIGHT", self.Icon, "LEFT", -(self.offsetX or 5), 0)
	else
		self.Value:SetPoint("LEFT", self.Icon, "RIGHT", (self.offsetX or 5), 0)
	end
end

function PKBT_CurrencyMixin:SetInvertValueSide(state)
	self.invertSide = not not state

	self.Icon:ClearAllPoints()
	if self.invertSide then
		self.Icon:SetPoint("RIGHT", 0, 0)
	else
		self.Icon:SetPoint("LEFT", 0, 0)
	end
	self:UpdateTextOffset()
end

function PKBT_CurrencyMixin:SetTextOffset(offset)
	self.offsetX = type(offset) == "number" and offset or nil
	self:UpdateTextOffset()
end

function PKBT_CurrencyMixin:SetTextColor(color)
	if type(color) == "table" then
		self.Value:SetTextColor(unpack(color, 1, 3))
	else
		self.Value:SetTextColor(1, 0.82, 0)
	end
end

function PKBT_CurrencyMixin:SetIconSize(size)
	self:SetHeight(size or 26)
	self.Icon:SetSize(size or 26, size or 26)
end

function PKBT_CurrencyMixin:SetFontObject(fontObject)
	self.Value:SetFontObject(fontObject or "PKBT_Font_16")
end

function PKBT_CurrencyMixin:SetTooltipEnabled(state)
	self.tooltipDisabled = not state
	self:EnableMouse(state)
end

PKBT_BalanceMixin = CreateFromMixins(PKBT_CurrencyMixin)

function PKBT_BalanceMixin:OnLoad()
	self.Icon:SetSize(40, 40)
	self.Value:SetFontObject("PKBT_Font_20")
	self.tooltipTitle = STORE_BALANCE_LABEL
	self:RegisterCustomEvent("STORE_BALANCE_UPDATE")
end

function PKBT_BalanceMixin:OnShow()
	self:UpdateBalance()
end

function PKBT_BalanceMixin:OnEvent(event, ...)
	if event == "STORE_BALANCE_UPDATE" then
		if self:IsShown() then
			self:UpdateBalance()
		end
	end
end

function PKBT_BalanceMixin:UpdateBalance()
	if self.currencyType then
		local balance = C_StorePublic and C_StorePublic.GetBalance(self.currencyType) or 0
		self:SetValue(balance)
	end
end

function PKBT_BalanceMixin:SetCurrencyType(currencyType)
	local success = PKBT_CurrencyMixin.SetCurrencyType(self, currencyType)
	if success then
		self:UpdateBalance()
	end
end

PKBT_PriceMixin = CreateFromMixins(PKBT_CurrencyMixin)

function PKBT_PriceMixin:OnShow()
	self:UpdatePriceRect()
end

function PKBT_PriceMixin:SetPrice(price, originalPrice, currencyType)
	local success = self:SetCurrencyType(currencyType)
	if success and price ~= -1 then
		local isFree = price == 0

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

		self:UpdateColors()
	else
		self.value = -1
		self.originalPrice = 0

		self.Value:Hide()
		self.Icon:Hide()
		self.ValueOriginal:Hide()
		self.StrikeThrough:Hide()
	end

	self:UpdatePriceRect()

	return success
end

function PKBT_PriceMixin:HasDiscount()
	if self.value and self.value ~= -1 and self.originalPrice and self.originalPrice > 0 then
		return self.value ~= self.originalPrice
	end
	return false
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

function PKBT_PriceMixin:UpdateColors()
	if self:IsPriceDesaturated() then
		self.Value:SetTextColor(0.5, 0.5, 0.5)
		self.Icon:SetDesaturated(true)
	else
		self.Icon:SetDesaturated(false)
		if self.ValueOriginal:IsShown() then
			if self.value > self.originalPrice then
				self.Value:SetTextColor(self:GetMarkupColor())
			else
				self.Value:SetTextColor(self:GetDiscountColor())
			end
		else
			self.Value:SetTextColor(self:GetDefaultValueColor())
		end
	end
end

function PKBT_PriceMixin:SetDefaultValueColorOverride(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.__colorOverrideDefaultValueR = r
		self.__colorOverrideDefaultValueG = g
		self.__colorOverrideDefaultValueB = b
	else
		self.__colorOverrideDefaultValueR = nil
		self.__colorOverrideDefaultValueG = nil
		self.__colorOverrideDefaultValueB = nil
	end
end

function PKBT_PriceMixin:GetDefaultValueColor()
	if self.__colorOverrideDefaultValueR then
		return self.__colorOverrideDefaultValueR, self.__colorOverrideDefaultValueG, self.__colorOverrideDefaultValueB
	end
	return 1, 1, 1
end

function PKBT_PriceMixin:SetDiscountColorOverride(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.__colorOverrideDiscountR = r
		self.__colorOverrideDiscountG = g
		self.__colorOverrideDiscountB = b
	else
		self.__colorOverrideDiscountR = nil
		self.__colorOverrideDiscountG = nil
		self.__colorOverrideDiscountB = nil
	end
end

function PKBT_PriceMixin:GetDiscountColor()
	if self.__colorOverrideDiscountR then
		return self.__colorOverrideDiscountR, self.__colorOverrideDiscountG, self.__colorOverrideDiscountB
	end
	return 0.102, 1, 0.102
end

function PKBT_PriceMixin:SetMarkupColorOverride(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.__colorOverrideMarkupR = r
		self.__colorOverrideMarkupG = g
		self.__colorOverrideMarkupB = b
	else
		self.__colorOverrideMarkupR = nil
		self.__colorOverrideMarkupG = nil
		self.__colorOverrideMarkupB = nil
	end
end

function PKBT_PriceMixin:GetMarkupColor()
	if self.__colorOverrideMarkupR then
		return self.__colorOverrideMarkupR, self.__colorOverrideMarkupG, self.__colorOverrideMarkupB
	end
	return 0.3, 0.7, 1
end

function PKBT_PriceMixin:SetPriceDesaturated(desaturated)
	desaturated = not not desaturated

	if desaturated ~= self:IsPriceDesaturated() then
		self.__desaturated = desaturated
		self:UpdateColors()
	end
end

function PKBT_PriceMixin:IsPriceDesaturated()
	return not not self.__desaturated
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

PKBT_CurrencyListMixin = {}

function PKBT_CurrencyListMixin:OnLoad()
	self.currencyPool = CreateFramePool("Frame", self.ListHolder, "PKBT_CurrencyTemplate")
	self.activeCurrencies = {}
	self.offsetX = 5
end

function PKBT_CurrencyListMixin:OnShow()
	self:UpdateRect()
end

function PKBT_CurrencyListMixin:UpdateRect()
	local width = 0
	for index, currencyWidget in ipairs(self.activeCurrencies) do
		width = width + currencyWidget:GetWidth()
	end

	width = width + (#self.activeCurrencies - 1) * self.offsetX
	self:SetWidth(width > 0 and width + (self.additionalWidth or 0) or 1)

	if type(self.OnRectUpdate) == "function" then
		self.OnRectUpdate(self)
	end
end

function PKBT_CurrencyListMixin:Clear()
	self.currencyPool:ReleaseAll()
	table.wipe(self.activeCurrencies)
	self:SetWidth(1)
end

function PKBT_CurrencyListMixin:SetCurrency(currencyType, amount)
	self:Clear()
	self:AddCurrency(currencyType, amount)
end

function PKBT_CurrencyListMixin:AddCurrency(currencyType, amount, suppressRectUpdate)
	local currencyWidget = self.currencyPool:Acquire()

	local index = #self.activeCurrencies + 1
	if index == 1 then
		local baseOffsetX = self.additionalWidth and math.floor(self.additionalWidth / 2 + 0.5) or 0
		currencyWidget:SetPoint("LEFT", baseOffsetX, 0)
	else
		currencyWidget:SetPoint("LEFT", self.activeCurrencies[index - 1], "RIGHT", self.offsetX, 0)
	end

	currencyWidget:SetInvertValueSide(self.currencyInvertSide)
	currencyWidget:SetFontObject(self.currencyFontObject)
	currencyWidget:SetTextColor(self.currencyTextColor)
	currencyWidget:SetTextOffset(self.currencyTextOffsetX)
	currencyWidget:SetIconSize(self.currencySize, self.currencySize)
	currencyWidget:SetTooltipEnabled(not self.tooltipDisabled)
	currencyWidget:SetValue(amount, currencyType)
	currencyWidget:Show()
	self.activeCurrencies[index] = currencyWidget

	if not suppressRectUpdate then
		self:UpdateRect()
	end
end

local sortByCurrencyType = function(a, b)
	return a[1] < a[2]
end

function PKBT_CurrencyListMixin:SetCurrencyHashList(list)
	self:Clear()

	if not next(list) then
		self:UpdateRect()
		return
	end

	local currencyArray = {}
	for currencyType, amount in pairs(list) do
		table.insert(currencyArray, {currencyType, amount})
	end

	table.sort(currencyArray, sortByCurrencyType)

	for index, data in ipairs(currencyArray) do
		self:AddCurrency(data[1], data[2], true)
	end

	self:UpdateRect()
end

function PKBT_CurrencyListMixin:SetAdditionalWidth(width)
	self.additionalWidth = type(width) == "number" and width or nil
end

function PKBT_CurrencyListMixin:SetCurrencyOffset(offset)
	self.offsetX = type(offset) == "number" and offset or 5
end

function PKBT_CurrencyListMixin:SetCurrencyInvertValueSide(state)
	self.currencyInvertSide = not not state
end

function PKBT_CurrencyListMixin:SetCurrencyTextOffset(offset)
	self.currencyTextOffsetX = type(offset) == "number" and offset or nil
end

function PKBT_CurrencyListMixin:SetCurrencyTextColor(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.currencyTextColor = {r, g, b}
	else
		self.currencyTextColor = nil
	end
end

function PKBT_CurrencyListMixin:SetCurrencySize(size)
	self.currencySize = type(size) == "number" and size or nil
end

function PKBT_CurrencyListMixin:SetCurrencyFont(fontObject)
	self.currencyFontObject = type(fontObject) == "string" and fontObject or nil
end

function PKBT_CurrencyListMixin:SetCurrencyTooltipEnabled(state)
	self.tooltipDisabled = not state
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

PKBT_ButtonMultiWidgetPriceMixin = CreateFromMixins(PKBT_ButtonMultiWidgetMixin)

function PKBT_ButtonMultiWidgetPriceMixin:OnLoad()
	PKBT_ButtonMultiWidgetMixin.OnLoad(self)

	self.Price:SetDefaultValueColorOverride(1, 0.82, 0)

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
	self.Price:SetPriceDesaturated(false)
end

function PKBT_ButtonMultiWidgetPriceMixin:OnDisable()
	PKBT_ButtonMultiWidgetMixin.OnDisable(self)
	self.Price:SetPriceDesaturated(true)
end

function PKBT_ButtonMultiWidgetPriceMixin:OnEnterTooltip()
	PKBT_ButtonMultiWidgetMixin.OnEnterTooltip(self)

	if not self.tooltipShown and self:IsEnabled() ~= 1 then
		if self.Price.currencyType and self.Price.value then
			local balance = C_StorePublic and C_StorePublic.GetBalance(self.Price.currencyType) or 0
			if self.Price.value > balance then
				local errorText

				if self.Price.currencyType == Enum.Store.CurrencyType.Bonus then
					errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_BONUS
				elseif self.Price.currencyType == Enum.Store.CurrencyType.Vote then
					errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_VOTE
				elseif self.Price.currencyType == Enum.Store.CurrencyType.Referral then
					errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_REFERRAL
				elseif self.Price.currencyType == Enum.Store.CurrencyType.Loyality then
					errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_LOYALITY
				else
					errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_GENERIC
				end

				self.tooltipShown = true
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:AddLine(string.format(STORE_NOT_ENOUGHT_FOR_PURCHASE_BASE, errorText, balance), 1, 1, 1, true)
				GameTooltip:Show()
			end
		end
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

function PKBT_ButtonMultiWidgetPriceMixin:SetPrice(price, originalPrice, currencyType)
	local success = PKBT_PriceMixin.SetPrice(self.Price, price, originalPrice, currencyType)

	if price == -1 then
		self.Price:Hide()
	else
		self.Price:Show()
		self:CheckBalance()
	end

	self.__dirty = true
	self:UpdatePriceRect()
	self:UpdateButton()

	return success
end

function PKBT_ButtonMultiWidgetPriceMixin:HasDiscount()
	return self.Price:HasDiscount()
end

function PKBT_ButtonMultiWidgetPriceMixin:CheckBalance()
	if self.Price.currencyType and self.Price.value then
		local balance = C_StorePublic and C_StorePublic.GetBalance(self.Price.currencyType) or 0

		if self.__allowReplenishment and self.Price.currencyType == Enum.Store.CurrencyType.Bonus then
			self.PurchaseNote:SetShown(self.__showReplenishmentIcon and self.Price.value > balance and not C_Service.IsInGMMode())
			if not self.disabledReason then
				self:Enable()
			end
		else
			self.PurchaseNote:Hide()
			if not self.disabledReason then
				self:SetEnabled(self.Price.value <= balance or C_Service.IsInGMMode())
			end
		end
	else
		self.PurchaseNote:Hide()
		if not self.disabledReason then
			self:Enable()
		end
	end

	self.Price:SetPriceDesaturated(self:IsEnabled() ~= 1)
end

function PKBT_ButtonMultiWidgetPriceMixin:SetAllowReplenishment(state, showIcon)
	self.__allowReplenishment = not not state
	self.__showReplenishmentIcon = not not showIcon

	if self:IsVisible() then
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

function PKBT_CheckButtonBaseMixin:OnEnable()
	self.ButtonText:SetTextColor(1, 1, 1)
end

function PKBT_CheckButtonBaseMixin:OnDisable()
	self.ButtonText:SetTextColor(0.5, 0.5, 0.5)
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
	self:SetHighlightAtlas("PKBT-Checkbox-Highlight")
	self:SetCheckedAtlas("PKBT-Checkbox-Checked", true)
	self:SetDisabledCheckedAtlas("PKBT-Checkbox-Checked")
	self:GetDisabledCheckedTexture():SetDesaturated(true)
end

PKBT_RadioButtonMixin = CreateFromMixins(PKBT_CheckButtonBaseMixin)

function PKBT_RadioButtonMixin:OnLoad()
	PKBT_CheckButtonBaseMixin.OnLoad(self)
	self:SetNormalAtlas("PKBT-RadioButton-Default")
	self:SetPushedAtlas("PKBT-RadioButton-Default")
	self:SetHighlightAtlas("PKBT-RadioButton-Highlight")
	self:SetCheckedAtlas("PKBT-RadioButton-Checked", true)
	self:SetDisabledCheckedAtlas("PKBT-RadioButton-Disabled")
end

PKBT_SeparatorPikeHorizontalMixin = {}

function PKBT_SeparatorPikeHorizontalMixin:OnLoad()
	self.Left:SetAtlas("PKBT-Separator-Pike-Horizontal-Left", true)
	self.Right:SetAtlas("PKBT-Separator-Pike-Horizontal-Right", true)
	self.Center:SetAtlas("PKBT-Separator-Pike-Horizontal-Center", true)
end

PKBT_SeparatorPikeVerticalMixin = {}

function PKBT_SeparatorPikeVerticalMixin:OnLoad()
	self.Top:SetAtlas("PKBT-Separator-Pike-Vertical-Top", true)
	self.Bottom:SetAtlas("PKBT-Separator-Pike-Vertical-Bottom", true)
	self.Middle:SetAtlas("PKBT-Separator-Pike-Vertical-Middle", true)
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

PKBT_RefreshButtonMixin = {}

function PKBT_RefreshButtonMixin:OnLoad()
	self:SetNormalAtlas("PKBT-Icon-Refresh")
	self:SetPushedAtlas("PKBT-Icon-Refresh")
	self:SetDisabledAtlas("PKBT-Icon-Refresh")
	self:SetHighlightAtlas("PKBT-Icon-Refresh-Highlight")
	self:GetDisabledTexture():SetVertexColor(0.5, 0.5, 0.5)
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
		if IsMouseButtonDown then
			self.timeSinceLast = (self.timeToStart or -0.2)
			self:SetScript("OnUpdate", self.OnUpdate)
		end
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
		self.__scrollDisabled = nil
		self:UpdateAlpha(this:GetParent())
	end)
	self:GetParent().ScrollBar.ScrollDownButton:HookScript("OnDisable", function(this)
		self.__scrollDisabled = true
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

	if self.__scrollDisabled then
		self.Bottom:SetAlpha(0)
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
				if result and result ~= text then
					self:SetText(result)
				end
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
	self.__originalText = self:GetText()
end

function PKBT_EditBoxCodeMixin:OnTextChanged(userInput)
	if self.__ignoreTextChanged then
		return
	end

	local text = self:GetText()
	self.__originalText = text
	self.Instructions:SetShown(text == "")

	if type(self.OnTextValueChanged) == "function" then
		self.OnTextValueChanged(self, text, userInput)
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

PKBT_NumericEditBoxMixin = CreateFromMixins(PKBT_EditBoxMixin)

function PKBT_NumericEditBoxMixin:OnLoad()
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

function PKBT_NumericEditBoxMixin:OnTextChanged(userInput)
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

	if type(self.OnTextValueChanged) == "function" then
		self.OnTextValueChanged(self, value, userInput)
	end
end

function PKBT_NumericEditBoxMixin:SetNumberNoScript(number)
	self.__ignoreTextChanged = true
	self:SetNumber(number)
	self.__ignoreTextChanged = nil
end

PKBT_EditBoxMulilineCodeMixin = CreateFromMixins(PKBT_EditBoxCodeMixin)

function PKBT_EditBoxMulilineCodeMixin:OnTextChanged(userInput)
	PKBT_EditBoxCodeMixin.OnTextChanged(self, userInput)

	local scrollFrame = self:GetParent()
	if scrollFrame.CharCount:IsShown() then
		local limit = self:GetMaxLetters()
		if limit == 0 then
			scrollFrame.CharCount:SetText("")
		else
			scrollFrame.CharCount:SetText(limit - self:GetNumLetters())

			if scrollFrame.ScrollBar:IsShown() then
				scrollFrame.CharCount:SetPoint("BOTTOMRIGHT", -24, 2)
			else
				scrollFrame.CharCount:SetPoint("BOTTOMRIGHT", -1, 2)
			end
		end
	end
end

PKBT_EditBoxMulilineScrollMixin = CreateFromMixins(PKBT_EditBoxCodeMixin)

function PKBT_EditBoxMulilineScrollMixin:OnLoad()
	self.EditBox:SetWidth(self:GetWidth() - 24)
	self.EditBox.Instructions:SetPoint("TOPLEFT", 1, -1)
	self.EditBox.Instructions:SetWidth(self:GetWidth() - 2)

	self.scrollBarHideable = 1
	ScrollFrame_OnLoad(self)
	ScrollFrame_OnScrollRangeChanged(self)
	ScrollingEdit_SetCursorOffsets(self.EditBox, 0, 0)
end

function PKBT_EditBoxMulilineScrollMixin:OnShow()
	local _, _, width, height = self:GetRect()
	if not width then
		width = self:GetWidth()
	end
	if not height then
		height = self:GetHeight()
	end
	self:SetSize(width, height)
	self.EditBox:SetWidth((width or self:GetWidth()) - 24)
end

function PKBT_EditBoxMulilineScrollMixin:OnSizeChanged(width, height)
	self.EditBox:SetWidth(width - 24)
end

function PKBT_EditBoxMulilineScrollMixin:OnMouseUp(button)
	self.EditBox:SetFocus()
end

function PKBT_EditBoxMulilineScrollMixin:SetInstructions(instructions)
	self.EditBox:SetInstructions(instructions)
end

function PKBT_EditBoxMulilineScrollMixin:SetMaxLetters(letters)
	if type(letters) ~= "number" or letters < 0 then
		letters = 0
	end
	self.EditBox:SetMaxLetters(letters)
	self.CharCount:SetShown(letters > 0)
end

function PKBT_EditBoxMulilineScrollMixin:SetTransperentBackdrop(state)
	if state then
		NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PKBT_InputMultilineTransparent")
	else
		NineSliceUtil.ApplyLayoutByName(self.NineSlice, "PKBT_InputMultilineOpaque")
	end
end

PKBT_SimpleHTMLAsFontStringMixin = {}

function PKBT_SimpleHTMLAsFontStringMixin:OnLoadSimpleHTMLAsFontString()
	if not self:GetRegions() then
		getmetatable(self).__index.SetText(self, "") -- initialize font object region
	end
end

function PKBT_SimpleHTMLAsFontStringMixin:GetText()
	return self:GetRegions():GetText()
end

function PKBT_SimpleHTMLAsFontStringMixin:SetWidth(width)
	getmetatable(self).__index.SetWidth(self, width)
	self:GetRegions():SetWidth(width)
	self:SetHeight(self:GetRegions():GetHeight())
end

function PKBT_SimpleHTMLAsFontStringMixin:GetStringWidth()
	return self:GetRegions():GetStringWidth()
end

function PKBT_SimpleHTMLAsFontStringMixin:GetStringHeight()
	return self:GetRegions():GetStringHeight()
end

function PKBT_SimpleHTMLAsFontStringMixin:SetText(text)
	getmetatable(self).__index.SetText(self, text)
	self:SetHeight(self:GetRegions():GetHeight())
end

PKBT_CopyButtonMixin = {}

function PKBT_CopyButtonMixin:OnLoad()
	self:SetNormalAtlas("PKBT-Icon-Copy", true)
	self:SetPushedAtlas("PKBT-Icon-Copy-Pressed", true)
	self:SetHighlightAtlas("PKBT-Icon-Copy-Highlight", true)
	self:Disable()
end

function PKBT_CopyButtonMixin:GetEditBox()
	local editBox = self.editBox or self:GetParent()
	if type(editBox) == "table" and editBox:IsObjectType("EditBox") then
		return editBox
	end
end

function PKBT_CopyButtonMixin:UpdateEditBoxTextRect()
	local editBox = self:GetEditBox()
	if editBox then
		local leftHitRect, rightHitRect, topHitRect, bottomHitRect = editBox:GetHitRectInsets()
		local leftText, rightText, topText, bottomText = editBox:GetTextInsets()

		if self:IsEnabled() == 1 then
			local width = self:GetWidth()
			local _, _, _, offsetX = self:GetPoint(1)
			editBox:SetHitRectInsets(leftHitRect, width - offsetX + 4, topHitRect, bottomHitRect)
			editBox:SetTextInsets(leftText, width - offsetX + 4, topText, bottomText)
		else
			editBox:SetHitRectInsets(leftHitRect, leftHitRect, topHitRect, bottomHitRect)
			editBox:SetTextInsets(leftText, rightText, topText, bottomText)
		end
	end
end

function PKBT_CopyButtonMixin:OnEnable()
	self:UpdateEditBoxTextRect()
	self:Show()
end

function PKBT_CopyButtonMixin:OnDisable()
	self:UpdateEditBoxTextRect()
	self:Hide()
end

function PKBT_CopyButtonMixin:OnClick(button)
	local editBox = self:GetEditBox()
	if editBox then
		if type(editBox.OnCopyClick) == "function" then
			editBox.OnCopyClick(self, button)
		end
	end
end

PKBT_DropdownMenuMixin = {}

function PKBT_DropdownMenuMixin:OnLoad()
	self.Left:SetAtlas("PKBT-Input-Background-Left", true)
	self.Right:SetAtlas("PKBT-Input-Background-Right", true)
	self.Middle:SetAtlas("PKBT-Input-Background-Center", true)

	self.Button:SetNormalAtlas("PKBT-Arrow-Down", true)
	self.Button:SetDisabledAtlas("PKBT-Arrow-Down-Disabled", true)
--	self.Button:SetPushedAtlas("PKBT-Arrow-Down-Pushed", true)
	self.Button:SetHighlightAtlas("PKBT-Arrow-Down-Highlight", true)
end

function PKBT_DropdownMenuMixin:UpdateButtonHitRect()
	self.Button:SetHitRectInsets(-(self:GetWidth() - self.Button:GetWidth() - 13), -7, -2, -2)
end

function PKBT_DropdownMenuMixin:OnShow()
	self:UpdateButtonHitRect()
end

function PKBT_DropdownMenuMixin:OnSizeChanged(width, height)
	self:UpdateButtonHitRect()
end

PKBT_PaginatorMixin = {}

function PKBT_PaginatorMixin:OnLoad()
	self.__numPages = 1
	self.__currentPage = 1
end

function PKBT_PaginatorMixin:GetPage()
	return self.__currentPage, self.__numPages
end

function PKBT_PaginatorMixin:SetNumPages(numPages, skipCallback)
	local oldPage = self.__currentPage

	self.__numPages = type(numPages) == "number" and numPages > 0 and numPages or 1

	if self.__currentPage > self.__numPages then
		self.__currentPage = 1
	end

	self:UpdatePaginator(oldPage ~= self.__currentPage, skipCallback)
end

function PKBT_PaginatorMixin:SetPage(pageIndex)
	if pageIndex ~= self.currentPage and pageIndex > 0 and pageIndex <= self.__numPages then
		self.__currentPage = pageIndex
		self:UpdatePaginator(true)
	end
end

function PKBT_PaginatorMixin:PreviousPage(around)
	if self.__numPages <= 1 then
		return
	end

	if self.__currentPage == 1 then
		if not around then
			return
		end
		self.__currentPage = self.__numPages
	else
		self.__currentPage = self.__currentPage - 1
	end

	self:UpdatePaginator(true)
end

function PKBT_PaginatorMixin:NextPage(around)
	if self.__numPages <= 1 then
		return
	end

	if self.__currentPage == self.__numPages then
		if not around then
			return
		end
		self.__currentPage = 1
	else
		self.__currentPage = self.__currentPage + 1
	end

	self:UpdatePaginator(true)
end

function PKBT_PaginatorMixin:SetPageFormat(pageFormat)
	local oldFormat = self.__pageFormat
	self.__pageFormat = type(pageFormat) == "string" and pageFormat or nil

	if oldFormat ~= self.__pageFormat then
		self:UpdatePaginator()
	end
end

function PKBT_PaginatorMixin:UpdatePaginator(pageChanged, skipCallback)
	local currentPage, numPages = self:GetPage()
	if numPages > 1 then
		self.PageText:SetFormattedText(self.__pageFormat or "%u/%u", currentPage, numPages)
		self.PrevButton:SetEnabled(currentPage > 1)
		self.NextButton:SetEnabled(currentPage < numPages)
		self:Show()

		if pageChanged and not skipCallback and type(self.OnPageChanged) == "function" then
			self:OnPageChanged(currentPage, numPages)
		end
	else
		self:Hide()
	end
end

function PKBT_PaginatorMixin:OnPrevNextClick(button, delta)
	if delta > 0 then
		self:NextPage()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	elseif delta < 0 then
		self:PreviousPage()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
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

PKBT_ItemIconMixin = {}

function PKBT_ItemIconMixin:OnLoad()
	self.Border:SetAtlas("PKBT-ItemBorder-Default", true)
	self.BorderColored:SetAtlas("PKBT-ItemBorder-Normal", true)
end

function PKBT_ItemIconMixin:SetIcon(icon)
	self.Icon:SetTexture(icon)
end

function PKBT_ItemIconMixin:SetAmount(amount)
	if type(amount) == "number" and amount > 1 then
		self.Amount:SetText(amount)
	else
		self.Amount:SetText("")
	end
end

function PKBT_ItemIconMixin:SetQuality(qualityIndex)
	if type(qualityIndex) == "number" then
		self.BorderColored:SetVertexColor(GetItemQualityColor(qualityIndex))
		self.BorderColored:Show()
		self.Border:Hide()
	else
		self.BorderColored:Hide()
		self.Border:Show()
	end
end

PKBT_WardrobeButtonMixin = {}

function PKBT_WardrobeButtonMixin:OnLoad()
	self:SetHighlightAtlas("PKBT-Store-Icon-Wardrobe-White-Transparent")
end

function PKBT_WardrobeButtonMixin:UpdateState()
	local isEnabled = self:IsEnabled() == 1

	if self:GetChecked() then
		if isEnabled then
			self:SetNormalAtlas("PKBT-Store-Icon-Wardrobe-Colored")
		else
			self:SetNormalAtlas("PKBT-Store-Icon-Wardrobe-Colored-Transparent")
		end
	else
		if isEnabled then
			self:SetNormalAtlas("PKBT-Store-Icon-Wardrobe-White")
		else
			self:SetNormalAtlas("PKBT-Store-Icon-Wardrobe-White-Transparent")
		end
	end

	if isEnabled then
		if GetMouseFocus() == self then
			self:OnEnter()
		end
	else
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end
	end
end

function PKBT_WardrobeButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	if self:GetChecked() then
		GameTooltip:AddLine(PLAYER_EQUIPMENT_HIDE, 1, 1, 1)
	else
		GameTooltip:AddLine(PLAYER_EQUIPMENT_SHOW, 1, 1, 1)
	end
	GameTooltip:Show()
end

function PKBT_WardrobeButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function PKBT_WardrobeButtonMixin:OnShow()
	self:UpdateState()
end

function PKBT_WardrobeButtonMixin:OnClick(button)
	self:UpdateState()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function PKBT_WardrobeButtonMixin:SetChecked(state)
	getmetatable(self).__index.SetChecked(self, state)
	self:UpdateState()
end

function PKBT_WardrobeButtonMixin:Enable(state)
	getmetatable(self).__index.Enable(self, state)
	self:UpdateState()
end

function PKBT_WardrobeButtonMixin:Disable(state)
	getmetatable(self).__index.Disable(self, state)
	self:UpdateState()
end

PKBT_MagnifierButtonMixin = {}

function PKBT_MagnifierButtonMixin:OnLoad()
	self:SetNormalAtlas("store-icon-magnifyingglass")
	self:SetHighlightAtlas("store-icon-magnifyingglass")
	self:SetCheckedAtlas("store-icon-magnifyingglass")
end

function PKBT_MagnifierButtonMixin:OnClick(button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

local TRANSMOG_CREATURE_ID = 413
local ModelLoadHandler = CreateFrame("Frame")
if not IsOnGlueScreen() then
	local TOOLTIP = CreateFrame("GameTooltip")
	TOOLTIP:AddFontStrings(TOOLTIP:CreateFontString(), TOOLTIP:CreateFontString())

	ModelLoadHandler.modelQueue = {}
	ModelLoadHandler:Hide()
	ModelLoadHandler:SetScript("OnUpdate", function(self, elapsed)
		local index = 1
		local queueLen = #self.modelQueue
		local modelData = self.modelQueue[index]
		while modelData and index <= queueLen do
			local modelType, modelID = modelData[2], modelData[3]
			local link = self:GetModelCacheHyperlink(modelType, modelID)
			if link then
				TOOLTIP:SetOwner(WorldFrame, "ANCHOR_NONE")
				TOOLTIP:SetHyperlink(link)

				if TOOLTIP:IsShown() then
					queueLen = queueLen - 1
					table.remove(self.modelQueue, index)
					if modelData[4] then
						local success, err = pcall(modelData[4], modelData[1], modelType, modelID)
						if not success then
							geterrorhandler()(err)
						end
					end
				else
					index = index + 1
				end
			else
				table.remove(self.modelQueue, index)
				if modelData[5] then
					local success, err = pcall(modelData[5], modelData[1], modelType, modelID)
					if not success then
						geterrorhandler()(err)
					end
				end
			end

			modelData = self.modelQueue[index]
		end

		if #self.modelQueue == 0 then
			self:Hide()
		end
	end)

	function ModelLoadHandler:GetModelCacheHyperlink(modelType, modelID)
		if modelType == Enum.ModelType.Creature then
			return string.format("unit:0xF5300%05X000000", modelID)
		elseif modelType == Enum.ModelType.Illusion
		or modelType == Enum.ModelType.ItemTransmog
		then
			return string.format("unit:0xF5300%05X000000", TRANSMOG_CREATURE_ID)
		elseif modelType == Enum.ModelType.Unit then
			local guid = UnitGUID(modelID)
			if guid then
				return string.format("unit:%s", guid)
			end
		end
	end

	function ModelLoadHandler:IsInvalidOrCacheLoaded(modelType, modelID)
		local link = self:GetModelCacheHyperlink(modelType, modelID)
		if link then
			TOOLTIP:SetOwner(WorldFrame, "ANCHOR_NONE")
			TOOLTIP:SetHyperlink(link)
			return TOOLTIP:IsShown() == 1
		end
		return true
	end

	function ModelLoadHandler:QueueModel(model, modelType, modelID, successCallback, errorCallback)
		local found
		for index, modelRequest in ipairs(self.modelQueue) do
			if modelRequest[1] == model and (successCallback == nil or modelRequest[4] == successCallback) then
				modelRequest[2] = modelType
				modelRequest[3] = modelID
				modelRequest[4] = successCallback
				modelRequest[5] = errorCallback
				found = true
				break
			end
		end
		if not found then
			table.insert(self.modelQueue, {model, modelType, modelID, successCallback, errorCallback})
		end
		self:Show()
		return true
	end

	function ModelLoadHandler:UnqueueModel(model, successCallback)
		local removed
		for index, modelRequest in ipairs(self.modelQueue) do
			if modelRequest[1] == model and (successCallback == nil or modelRequest[4] == successCallback) then
				table.remove(self.modelQueue, index)
				removed = true
				break
			end
		end
		if removed and #self.modelQueue == 0 then
			self:Hide()
		end
		return removed
	end
end

local TRANSMOG_SLOT_ITEM = {110000, 110001, 110002, 110003, 110004}
local ITEM_WEAPON_EQUIP_LOC_IDS = {[13] = true, [14] = true, [15] = true, [17] = true, [21] = true, [22] = true, [25] = true, [26] = true}

PKBT_ModelMixin = {}

function PKBT_ModelMixin:OnEvent(event, ...)
	if event == "UNIT_MODEL_CHANGED" then
		local unit = ...
		if self:IsShown() then
			if (not self.undress and (self.modelType == Enum.ModelType.Item or self.modelType == Enum.ModelType.ItemSet) and unit == "player")
			or (self.modelType == Enum.ModelType.Unit and self.guid == UnitGUID(unit))
			then
				self:UpdateModelPreset()
			end
		end
	elseif event == "ITEM_DATA_LOAD_RESULT" then
		local success, itemID = ...
		if itemID == self.awaitItemDataID then
			if success then
				self.needsReload = true
				self:UpdateModelPreset()
			end
			self:UnregisterCustomEvent(event)
		end
	end
end

function PKBT_ModelMixin:OnShow()
	if self.modelType == Enum.ModelType.Creature
	or self.modelType == Enum.ModelType.Illusion
	or self.modelType == Enum.ModelType.ItemTransmog
	then
		RunNextFrame(function()
			self.needsReload = true
			self:UpdateModelPreset()
		end)
	end

	self:UpdateModelPreset()
end

function PKBT_ModelMixin:OnHide()
	self:DisablePortraitCamera()
	self.needsReload = true
end

function PKBT_ModelMixin:OnUpdateModel()
	if self.reloadOnFirstUpdate then
		self.reloadOnFirstUpdate = nil
		RunNextFrame(function()
			self.needsReload = true
			self.LoadingSpinner:Hide()
			self:UpdateModelPreset()
		end)
	end

	if self.modelType == Enum.ModelType.Illusion
	or self.modelType == Enum.ModelType.ItemTransmog
	then
		self:SetSequence(self.animId or 3)
	elseif self.portraitCamera and self.freezeSequence then
		if self.modelType == Enum.ModelType.Item
		or self.modelType == Enum.ModelType.ItemSet
		or self.modelType == Enum.ModelType.Unit
		then
			self:SetSequence(self.animId or 3)
		end
	end
end

function PKBT_ModelMixin:ResetFull(preserveFacting, preservePosition)
	self:ResetModelData(preserveFacting, preservePosition)
	self:ResetModel()
end

function PKBT_ModelMixin:ResetModelData(preserveFacting, preservePosition)
	if self.queued then
		self.queued = nil
		ModelLoadHandler:UnqueueModel(self)
	end
	self.modelType = nil
	self.modelID = nil
	self.guid = nil
	self.facing = nil
	self.undress = nil
	self.baseItemOverrideID = nil
	self.portraitCamera = nil
	self.freezeSequence = nil
	self.awaitItemDataID = nil
	self.needsReload = nil
	self.reloadOnFirstUpdate = nil
	self:ResetBasePositionOverride()

	if not preserveFacting then
		self.preservedFacing = nil
		self.rotation = self.defaultRotation
	end
	if not preservePosition then
		self.basePositionOffsetX = nil
		self.basePositionOffsetY = nil
		self.basePositionOffsetZ = nil

		self.preservedPosition = nil
		self.zoomLevel = self.minZoom
		self.preservedPortraitCamera = nil
		self.preservedFreezeSequence = nil
		self.preservedBasePositionOverrideX = nil
		self.preservedBasePositionOverrideY = nil
		self.preservedBasePositionOverrideZ = nil
	end

	self:UnregisterEvent("UNIT_MODEL_CHANGED")
	self:UnregisterCustomEvent("ITEM_DATA_LOAD_RESULT")
	self.LoadingSpinner:Hide()
end

function PKBT_ModelMixin:ResetModel()
	self:SetPosition(0, 0, 0)
	self:SetFacing(0)
	self:ClearModel()
	self.LoadingSpinner:Hide()
end

function PKBT_ModelMixin:SetSpinnerShown(shown)
	self.LoadingSpinner:SetShown(shown)
end

function PKBT_ModelMixin:FireModelTypeChanged()
	local parent = self:GetParent()
	local handler = parent.OnModelTypeChanged
	if type(handler) == "function" then
		local success, err = pcall(handler, parent, self.modelType, self.modelID)
		if not success then
			geterrorhandler()(err)
		end
	end
end

function PKBT_ModelMixin:SetM2Model(model, facing, posOffsetX, posOffsetY, posOffsetZ)
	local modelType = self.modelType
	self:ResetFull()
	self.modelType = Enum.ModelType.M2
	self.modelID = model
	self.facing = facing
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:UpdateModelPreset()
end

function PKBT_ModelMixin:SetUnitModel(unit, facing, posOffsetX, posOffsetY, posOffsetZ)
	local modelType = self.modelType
	self:ResetFull()
	self.modelType = Enum.ModelType.Unit
	self.modelID = unit
	self.facing = facing
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	self.guid = UnitGUID(unit)
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:UpdateModelPreset()
	self:RegisterEvent("UNIT_MODEL_CHANGED")
end

function PKBT_ModelMixin:SetCreatureModel(creatureID, facing, posOffsetX, posOffsetY, posOffsetZ)
	local modelType = self.modelType
	self:ResetFull()
	self.modelType = Enum.ModelType.Creature
	self.modelID = creatureID
	self.facing = facing
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:UpdateModelPreset()
end

function PKBT_ModelMixin:SetItemDressUp(itemLink, facing, posOffsetX, posOffsetY, posOffsetZ, undress, preserveFacting, preservePosition)
	local modelType = self.modelType
	self:PreserveCameraSettings(preserveFacting, preservePosition)
	self:ResetFull(preserveFacting, preservePosition)
	self.modelType = Enum.ModelType.Item
	self.modelID = itemLink
	self.facing = facing
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	self.undress = not not undress
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:UpdateModelPreset()
end

function PKBT_ModelMixin:SetItemSetDressUp(itemLinkArray, facing, posOffsetX, posOffsetY, posOffsetZ, undress, preserveFacting, preservePosition)
	local modelType = self.modelType
	self:PreserveCameraSettings(preserveFacting, preservePosition)
	self:ResetFull(preserveFacting, preservePosition)
	self.modelType = Enum.ModelType.ItemSet
	self.modelID = itemLinkArray
	self.facing = facing
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	self.undress = not not undress
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:UpdateModelPreset()
end

function PKBT_ModelMixin:SetItemTransmogModel(itemID, posOffsetX, posOffsetY, posOffsetZ)
	local modelType = self.modelType
	self:ResetFull()
	self.modelType = Enum.ModelType.ItemTransmog
	self.modelID = itemID
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	self.needsReload = true
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:UpdateModelPreset()
end

function PKBT_ModelMixin:SetIllusionModel(illusionProductID, posOffsetX, posOffsetY, posOffsetZ, baseItemOverrideID)
	local modelType = self.modelType
	self:ResetFull()
	self.modelType = Enum.ModelType.Illusion
	self.modelID = illusionProductID
	self.basePositionOffsetX = posOffsetX
	self.basePositionOffsetY = posOffsetY
	self.basePositionOffsetZ = posOffsetZ
	self.baseItemOverrideID = baseItemOverrideID
	self.needsReload = true
	if modelType ~= self.modelType then
		self:FireModelTypeChanged()
	end
	self:UpdateModelPreset()
end

function PKBT_ModelMixin:SetModelAuto(modelType, modelID, facing, posOffsetX, posOffsetY, posOffsetZ, ...)
	if not Enum.ModelType[modelType] or not modelID then
		self:ResetFull()
		GMError(string.format("No model type [%s] or model id [%s]", Enum.ModelType[modelType] or "nil", modelID or "nil"))
		return
	end

	assert(Enum.ModelType[modelType])

	if modelType == Enum.ModelType.Creature then
		self:SetCreatureModel(modelID, facing, posOffsetX, posOffsetY, posOffsetZ, ...)
	elseif modelType == Enum.ModelType.Illusion then
		self:SetIllusionModel(modelID, posOffsetX, posOffsetY, posOffsetZ, ...)
	elseif modelType == Enum.ModelType.Item then
		self:SetItemDressUp(modelID, facing, posOffsetX, posOffsetY, posOffsetZ, ...)
	elseif modelType == Enum.ModelType.ItemSet then
		self:SetItemSetDressUp(modelID, facing, posOffsetX, posOffsetY, posOffsetZ, ...)
	elseif modelType == Enum.ModelType.ItemTransmog then
		self:SetItemTransmogModel(modelID, posOffsetX, posOffsetY, posOffsetZ, ...)
	elseif modelType == Enum.ModelType.Unit then
		self:SetUnitModel(modelID, facing, posOffsetX, posOffsetY, posOffsetZ, ...)
	elseif modelType == Enum.ModelType.M2 then
		self:SetM2Model(modelID, facing, posOffsetX, posOffsetY, posOffsetZ, ...)
	end
end

function PKBT_ModelMixin:PreserveCameraSettings(preserveFacting, preservePosition)
	if preserveFacting then
		self:PreserveFacing()
	end
	if preservePosition then
		self:PreservePosition()
	end
end

function PKBT_ModelMixin:PreserveFacing()
	self.preservedFacing = self:GetFacing()
end

function PKBT_ModelMixin:PreservePosition()
	local posX, posY, posZ = self:GetPosition()
	if posX ~= 0 or posX ~= 0 or posZ ~= 0 then
		self.preservedPosition = {posX, posY, posZ}
		self.preservedPortraitCamera = self.portraitCamera
		self.preservedFreezeSequence = self.freezeSequence
		self.preservedBasePositionOverrideX = self.basePositionOverrideX
		self.preservedBasePositionOverrideY = self.basePositionOverrideY
		self.preservedBasePositionOverrideZ = self.basePositionOverrideZ
	else
		self:RemovePreservedPosition()
	end
end

function PKBT_ModelMixin:RestorePreservedPosition()
	if self:HasPreservedPosition() then
		self:SetPosition(self.preservedPosition[1] or 0, self.preservedPosition[2] or 0, self.preservedPosition[3] or 0)
		self.portraitCamera = self.preservedPortraitCamera
		self.freezeSequence = self.preservedFreezeSequence
		self.basePositionOverrideX = self.preservedBasePositionOverrideX
		self.basePositionOverrideY = self.preservedBasePositionOverrideY
		self.basePositionOverrideZ = self.preservedBasePositionOverrideZ
	end
end

function PKBT_ModelMixin:RemovePreservedPosition()
	self.preservedPosition = nil
	self.zoomLevel = self.minZoom
	self.preservedPortraitCamera = nil
	self.preservedFreezeSequence = nil
end

function PKBT_ModelMixin:HasPreservedPosition()
	return not not self.preservedPosition
end

function PKBT_ModelMixin:TogglePlayerEquipment(state)
	if self.modelType == Enum.ModelType.Item then
		state = not state
		if self.undress ~= state then
			self.undress = state
			self.needsReload = true
			self:PreserveFacing()
			self:PreservePosition()
			self:UpdateModelPreset()
		end
	end
end

function PKBT_ModelMixin:IsPlayerEquipmentShown()
	return not self.undress
end

function PKBT_ModelMixin:DisablePortraitCamera()
	if self:IsPortraitCamera() then
		self:RemovePreservedPosition()
		self.portraitCamera = nil
		self.freezeSequence = nil

		self.rotation = 0
		self:ResetBasePositionOverride()

		self:SetFacing(0, 0, 0)
		self:SetPosition(0, 0, 0)

		if type(self.OnPortraitCameraToggle) == "function" then
			local success, err = pcall(self.OnPortraitCameraToggle, self, false)
			if not success then
				geterrorhandler()(err)
			end
		end
	end
end

function PKBT_ModelMixin:SetPositionAsBaseOverride()
	local x, y, z = self:GetPosition()
	self.basePositionOverrideX = x
	self.basePositionOverrideY = y
	self.basePositionOverrideZ = z
end

function PKBT_ModelMixin:ResetBasePositionOverride()
	self.basePositionOverrideX = nil
	self.basePositionOverrideY = nil
	self.basePositionOverrideZ = nil
end

function PKBT_ModelMixin:TogglePortraitCamera(state)
	state = not not state
	if self:IsPortraitCamera() ~= state then
		if self.modelType == Enum.ModelType.Item
		or self.modelType == Enum.ModelType.ItemSet
		or self.modelType == Enum.ModelType.Unit
		then
			if state then
				local cameraID
				if self.modelType == Enum.ModelType.Unit then
					cameraID = GetUICameraIDByType(20, self.modelID)
				else
					cameraID = GetUICameraIDByType(20)
				end
				if cameraID then
					self.portraitCamera = state
					self.freezeSequence = true

					self.rotation = 0

					Model_ApplyUICamera(self, cameraID, nil, nil, nil)

					self:SetPositionAsBaseOverride()
					self:PreserveFacing()
					self:PreservePosition()

					if type(self.OnPortraitCameraToggle) == "function" then
						local success, err = pcall(self.OnPortraitCameraToggle, self, true)
						if not success then
							geterrorhandler()(err)
						end
					end
				else
					self:DisablePortraitCamera()
				end
			else
				self:DisablePortraitCamera()
			end
		end
	end
end

function PKBT_ModelMixin:IsPortraitCamera()
	return self.portraitCamera and true or false
end

local function GetBestIllusionWeaponAppearance(...)
	for i = 1, select("#", ...) do
		local itemID = select(i, ...)
		if itemID then
			local visualID = C_TransmogCollection.GetItemVisualID(itemID)
			if visualID and C_TransmogCollection.CanEnchantAppearance(visualID) then
				return itemID
			end
		end
	end
end

local function GetIllusionInfoByEntry(entry, baseItemOverrideID)
	local _, enchantID = C_TransmogCollection.GetIllusionInfoByItemID(entry)
	if enchantID then
		local itemID = GetBestIllusionWeaponAppearance(baseItemOverrideID, GetInventoryTransmogID("player", 16), GetInventoryItemID("player", 16))
		if not itemID then
			itemID = C_TransmogCollection.GetFallbackWeaponAppearance()
		end

		if itemID then
			return itemID, enchantID, string.format("item:%d:%d", itemID, enchantID)
		end
	end
end

function PKBT_ModelMixin:OnModelLoaded(modelType, modelID)
	self.queued = nil
	if self.modelType == modelType and self.modelID == modelID then
		if self.modelType == Enum.ModelType.Creature
		or self.modelType == Enum.ModelType.Illusion
		or self.modelType == Enum.ModelType.ItemTransmog
		then
			self.reloadOnFirstUpdate = true
		end

		self.LoadingSpinner:Hide()
		self:UpdateModelPreset()
	end
end

function PKBT_ModelMixin:OnModelError(modelType, modelID)
	self.queued = nil
	if self.modelType == modelType and self.modelID == modelID then
		self.LoadingSpinner:Hide()
		self:Hide()
		GMError(string.format("%s: Model cannot be loaded [%s] [%s]", self:GetName() or tostring(self), Enum.ModelType[modelType] or modelType or "nil", modelID or "nil"))
	end
end

function PKBT_ModelMixin:OnModelPresetDone()
	self.preservedFacing = nil
	self.preservedPosition = nil

	if type(self.OnModelPresetApplied) == "function" then
		local success, err = pcall(self.OnModelPresetApplied, self)
		if not success then
			geterrorhandler()(err)
		end
	end
end

function PKBT_ModelMixin:UpdateModelPreset()
	if not self:IsVisible() then
		self.needsReload = true
		return
	end

	if self.needsReload then
		self:ResetModel()
	end

	if self.modelType == Enum.ModelType.Creature then
		self:SetCreature(self.modelID)

		if self:GetModel() == self then
			if ModelLoadHandler:IsInvalidOrCacheLoaded(self.modelType, self.modelID) then
				self:OnModelError(self.modelType, self.modelID)
			else
				self.LoadingSpinner:Show()
				self.queued = ModelLoadHandler:QueueModel(self, self.modelType, self.modelID, self.OnModelLoaded, self.OnModelError)
			end
		else
			if self:HasPreservedPosition() then
				self:RestorePreservedPosition()
			else
				self:SetPosition(self.basePositionOffsetX or 0, self.basePositionOffsetY or 0, self.basePositionOffsetZ or 0)
			end
			self:SetFacing(self.preservedFacing or self.facing or 0)
			self:OnModelPresetDone()
		end
	elseif self.modelType == Enum.ModelType.Illusion then
		local itemID, enchantID, dressUpLink = GetIllusionInfoByEntry(self.modelID, self.baseItemOverrideID)
		if itemID and enchantID and dressUpLink then
			DummyWardrobeUnitModel:Dress()
			self:Undress()

			self:SetCreature(TRANSMOG_CREATURE_ID)

			if self:GetModel() == self then
				if ModelLoadHandler:IsInvalidOrCacheLoaded(self.modelType, self.modelID) then
					self:OnModelError(self.modelType, self.modelID)
				else
					self.LoadingSpinner:Show()
					self.queued = ModelLoadHandler:QueueModel(self, self.modelType, self.modelID, self.OnModelLoaded, self.OnModelError)
				end
			else
				if not C_Item.IsItemInfoLoaded(dressUpLink) and self.awaitItemDataID ~= itemID then
					self.awaitItemDataID = itemID
					self:RegisterCustomEvent("ITEM_DATA_LOAD_RESULT")
					C_Item.RequestServerCache(dressUpLink)
				end

				if self:HasPreservedPosition() then
					self:RestorePreservedPosition()
				else
					local cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(itemID)
					Model_ApplyUICamera(self, cameraID, self.basePositionOffsetX or 1, self.basePositionOffsetY or 1, self.basePositionOffsetZ or 0.8)
				end
				if self.preservedFacing then
					self:SetFacing(self.preservedFacing)
				end

				self:TryOn(dressUpLink)
				self:SetModelScale(1)
				self:OnModelPresetDone()
			end
		else
			self:OnModelError(self.modelType, self.modelID)
		end
	elseif self.modelType == Enum.ModelType.ItemTransmog then
		local itemLink, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice, itemID, classID, subClassID, equipLocID = C_Item.GetItemInfo(self.modelID)
		if itemLink then
			if ITEM_WEAPON_EQUIP_LOC_IDS[equipLocID] then
				DummyWardrobeUnitModel:Dress()
				self:Undress()

				self:SetCreature(TRANSMOG_CREATURE_ID)

				if self:GetModel() == self then
					if ModelLoadHandler:IsInvalidOrCacheLoaded(self.modelType, self.modelID) then
						self:OnModelError(self.modelType, self.modelID)
					else
						self.LoadingSpinner:Show()
						self.queued = ModelLoadHandler:QueueModel(self, self.modelType, self.modelID, self.OnModelLoaded, self.OnModelError)
					end
				else
					if self:HasPreservedPosition() then
						self:RestorePreservedPosition()
					else
						local cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(self.modelID)
						Model_ApplyUICamera(self, cameraID, self.basePositionOffsetX or 1, self.basePositionOffsetY or 1, self.basePositionOffsetZ or 0.8)
					end
					if self.preservedFacing then
						self:SetFacing(self.preservedFacing)
					end

					self:TryOn(self.modelID)
					self:SetModelScale(1)
					self:OnModelPresetDone()
				end
			else
				self:SetUnit("player")
				self:Undress()

				for index, specialItemID in ipairs(TRANSMOG_SLOT_ITEM) do
					self:TryOn(specialItemID)
				end

				if self:HasPreservedPosition() then
					self:RestorePreservedPosition()
				else
					local cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(self.modelID)
					Model_ApplyUICamera(self, cameraID, self.basePositionOffsetX or 0.8, self.basePositionOffsetY or 0.8, self.basePositionOffsetZ or 1.05)
				end
				if self.preservedFacing then
					self:SetFacing(self.preservedFacing)
				end

				self:TryOn(self.modelID)
				self:SetModelScale(1)
				self:OnModelPresetDone()
			end
		else
			self:OnModelError(self.modelType, self.modelID)
		end
	elseif self.modelType == Enum.ModelType.Item then
		self:SetUnit("player")
		if self.undress then
			self:Undress()
		end
		if self:HasPreservedPosition() then
			self:RestorePreservedPosition()
		else
			self:SetPosition(self.basePositionOffsetX or 0, self.basePositionOffsetY or 0, self.basePositionOffsetZ or 0)
		end
		self:SetFacing(self.preservedFacing or self.facing or 0)
		self:TryOn(self.modelID)
		self:OnModelPresetDone()
	elseif self.modelType == Enum.ModelType.ItemSet then
		self:SetUnit("player")
		if self.undress then
			self:Undress()
		end
		if self:HasPreservedPosition() then
			self:RestorePreservedPosition()
		else
			self:SetPosition(self.basePositionOffsetX or 0, self.basePositionOffsetY or 0, self.basePositionOffsetZ or 0)
		end
		self:SetFacing(self.preservedFacing or self.facing or 0)
		for index, itemLink in ipairs(self.modelID) do
			self:TryOn(itemLink)
		end
		self:OnModelPresetDone()
	elseif self.modelType == Enum.ModelType.Unit then
		self:SetUnit(self.modelID)

		if self:GetModel() == self then
			if ModelLoadHandler:IsInvalidOrCacheLoaded(self.modelType, self.modelID) then
				self:OnModelError(self.modelType, self.modelID)
			else
				self.LoadingSpinner:Show()
				self.queued = ModelLoadHandler:QueueModel(self, self.modelType, self.modelID, self.OnModelLoaded, self.OnModelError)
			end
		else
			if self:HasPreservedPosition() then
				self:RestorePreservedPosition()
			else
				self:SetPosition(self.basePositionOffsetX or 0, self.basePositionOffsetY or 0, self.basePositionOffsetZ or 0)
			end
			self:SetFacing(self.preservedFacing or self.facing or 0)
			self:OnModelPresetDone()
		end
	elseif self.modelType == Enum.ModelType.M2 then
		self:SetModel(self.modelID)
		if self:HasPreservedPosition() then
			self:RestorePreservedPosition()
		else
			self:SetPosition(self.basePositionOffsetX or 0, self.basePositionOffsetY or 0, self.basePositionOffsetZ or 0)
		end
		self:SetFacing(self.preservedFacing or self.facing or 0)
		self:OnModelPresetDone()
	end

	self.needsReload = nil
end

PKBT_DressUpBaseMixin = CreateFromMixins(PKBT_OwnerMixin)

function PKBT_DressUpBaseMixin:OnLoad()
	self.Overlay.MouseInstruction.MouseRotate:SetAtlas("PKBT-Icon-Mouse-Rotate", true)
	self.Overlay.MouseInstruction.MouseZoom:SetAtlas("PKBT-Icon-Mouse-Zoom", true)
	self.Overlay.MouseInstruction.MousePanning:SetAtlas("PKBT-Icon-Mouse-Rotate", true)
	self.Overlay.MouseInstruction.MousePanning:SetSubTexCoord(1, 0, 0, 1)

	self.Overlay:EnableMouseWheel(false)

	self.Overlay.MouseInstruction.options = {
		self.Overlay.MouseInstruction.MouseZoom,
		self.Overlay.MouseInstruction.MouseRotate,
		self.Overlay.MouseInstruction.MousePanning,
	}

	SharedXML_Model_OnLoad(self.Model, MODELFRAME_MAX_ZOOM * 2, MODELFRAME_MIN_ZOOM, 0)
end

function PKBT_DressUpBaseMixin:OnShow()
	SetParentFrameLevel(self.Overlay, 2)
	self:UpdatePlayerEquipmentState()
	self:UpdatePortraitCameraState()
end

function PKBT_DressUpBaseMixin:OnHide()
	if self.Model.panning then
		SharedXML_Model_StopPanning(self.Model)
	end
	self.Model.mouseDown = false
end

function PKBT_DressUpBaseMixin:OnOverlayMouseUp(button)
	if button == "RightButton" and self.Model.panning then
		SharedXML_Model_StopPanning(self.Model)
	elseif self.Model.mouseDown then
		self.Model.onMouseUpFunc(self.Model, button)
	end

	if self.Model.onMouseUpCallback then
		self.Model.onMouseUpCallback(self.Model, button)
	end
end

function PKBT_DressUpBaseMixin:OnOverlayMouseDown(button)
	if button == "RightButton" then
		if self.modelPanningEnabled and not self.Model.mouseDown then
			SharedXML_Model_StartPanning(self.Model)
		end
	else
		SharedXML_Model_OnMouseDown(self.Model, button)
	end
end

function PKBT_DressUpBaseMixin:OnOverlayMouseWheel(delta)
	SharedXML_Model_OnMouseWheel(self.Model, delta)
end

function PKBT_DressUpBaseMixin:SetRotateEnabled(state)
	self.Overlay.MouseInstruction.MouseRotate:SetShown(state)
	self.Overlay.MouseInstruction.MouseRotateText:SetShown(state)
	self.modelRotateEnabled = state
	self.Overlay:EnableMouse(state)
	self:UpdateMouseInstruction()
end

function PKBT_DressUpBaseMixin:SetZoomEnabled(state)
	self.Overlay.MouseInstruction.MouseZoom:SetShown(state)
	self.Overlay.MouseInstruction.MouseZoomText:SetShown(state)
	self.modelZoomEnabled = state
	self.Overlay:EnableMouseWheel(state)
	self:UpdateMouseInstruction()
end

function PKBT_DressUpBaseMixin:SetPanningEnabled(state)
	self.Overlay.MouseInstruction.MousePanning:SetShown(state)
	self.Overlay.MouseInstruction.MousePanningText:SetShown(state)
	self.modelPanningEnabled = state
	if not state then
		SharedXML_Model_StopPanning(self.Model)
	end
	self:UpdateMouseInstruction()
end

function PKBT_DressUpBaseMixin:UpdateMouseInstruction()
	local width = 0
	local lastOption

	for index, option in ipairs(self.Overlay.MouseInstruction.options) do
		if option:IsShown() then
			if not lastOption then
				option:SetPoint("BOTTOMLEFT", 0, 0)
			else
				option:SetPoint("BOTTOMLEFT", lastOption, "BOTTOMRIGHT", 35, 0)
				width = width + 35
			end
			width = width + option:GetWidth()
			lastOption = option
		end
	end

	self.Overlay.MouseInstruction:SetWidth(width)
end

function PKBT_DressUpBaseMixin:SetPlayerEquipmentToggleEnabled(state)
	self.Overlay.EquipmentToggle:SetShown(state)
	self:UpdatePlayerEquipmentState()
end

function PKBT_DressUpBaseMixin:UpdatePlayerEquipmentState()
	self.Overlay.EquipmentToggle:SetChecked(self.Model:IsPlayerEquipmentShown())
end

function PKBT_DressUpBaseMixin:TogglePlayerEquipment(state)
	self.Model:TogglePlayerEquipment(state)
	self:UpdatePlayerEquipmentState()
end

function PKBT_DressUpBaseMixin:SetPortraitCameraToggleEnabled(state)
	self.Overlay.PortraitCameraToggle:SetShown(state)
	self:UpdatePortraitCameraState()
end

function PKBT_DressUpBaseMixin:IsPortraitCamera()
	return self.Model:IsPortraitCamera()
end

function PKBT_DressUpBaseMixin:UpdatePortraitCameraState()
	self.Overlay.PortraitCameraToggle:SetChecked(self.Model:IsPortraitCamera())
end

function PKBT_DressUpBaseMixin:TogglePortraitCamera(state)
	self.Model:TogglePortraitCamera(state)
	self:UpdatePortraitCameraState()
end

function PKBT_DressUpBaseMixin:SetModel(modelType, modelID)
	if modelType == Enum.ModelType.Item
	or modelType == Enum.ModelType.ItemSet
	then
		self.Model:SetModelAuto(modelType, modelID)
		self:SetZoomEnabled(true)
		self:SetRotateEnabled(true)
		self:SetPanningEnabled(true)
		self:SetPlayerEquipmentToggleEnabled(modelType == Enum.ModelType.Item)
		self:SetPortraitCameraToggleEnabled(false)
		return true
	elseif modelType == Enum.ModelType.Creature then
		local facing = C_StorePublic and C_StorePublic.GetPreferredModelFacing() or math.rad(25)
		self.Model:SetModelAuto(modelType, modelID, facing)
		self:SetZoomEnabled(false)
		self:SetRotateEnabled(true)
		self:SetPanningEnabled(false)
		self:SetPlayerEquipmentToggleEnabled(false)
		self:SetPortraitCameraToggleEnabled(false)
		return true
	elseif modelType == Enum.ModelType.Illusion
	or modelType == Enum.ModelType.ItemTransmog
	then
		self.Model:SetModelAuto(modelType, modelID)
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

function PKBT_DressUpBaseMixin:DressUpItemLink(link)
	local linkType, id, collectionID = GetDressUpItemLinkInfo(link)

	if linkType == Enum.DressUpLinkType.Default then
		return self:SetModel(Enum.ModelType.Item, id)
	elseif linkType == Enum.DressUpLinkType.Pet or linkType == Enum.DressUpLinkType.Mount then
		return self:SetModel(Enum.ModelType.Creature, id)
	elseif linkType == Enum.DressUpLinkType.Illusion then
		id = tonumber(strmatch(link, "item:(%d+)"))
		return self:SetModel(Enum.ModelType.Illusion, id)
	elseif linkType == Enum.DressUpLinkType.LootCase then
		LootCasePreviewFrame:SetPreview(id)
		LootCasePreviewFrame:Show()
		return false
	end

	return false
end

PKBT_DressUpMixin = CreateFromMixins(PKBT_DressUpBaseMixin)

function PKBT_DressUpMixin:OnLoad()
	PKBT_DressUpBaseMixin.OnLoad(self)

	self.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.VignetteBottomLeft:SetAtlas("PKBT-Vignette-Bronze-BottomLeft", true)
	self.VignetteBottomRight:SetAtlas("PKBT-Vignette-Bronze-BottomRight", true)

	self.Model:SetPoint("TOPLEFT", 3, -153)
	self.Model:SetPoint("BOTTOMRIGHT", -3, 3)
end

function PKBT_DressUpMixin:OnShow()
	PKBT_DressUpBaseMixin.OnShow(self)

	if not self.initialized then
		local _, class = UnitClass("player")
		self.Background:SetAtlas(strconcat("dressingroom-background-", string.lower(class)), true)
		self.initialized = true
	end
end