--	Filename:	Sirus_PromoCode.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

PROMOCODE_ITEM_DATA = {}

local DEFAULT_WINDOW_HEIGHT = 280
local REWARD_BUTTON_HEIGHT = 62
local REWARD_BUTTON_MAX_DISPLAYED = 3

local PROMOCODE_CACHE = C_Cache("SIRUS_PROMOCODE_CACHE", false)

function GetPromoCodeRewardCount()
	return #PROMOCODE_ITEM_DATA
end

function PromoCodeFrame_OnLoad( self, ... )
	self.elapsed = 0
	self.offset = 0
end

local buttonShowData = {
	{0.150, {}},
	{0.250, {}},
	{0.400, {}}
}

function PromoCodeFrame_OnShow( self, ... )
	PROMOCODE_ITEM_DATA = {}

	PromoCodeFrame_ResetAnimation()

	for index, button in pairs(self.rewardButtons) do
		button:Hide()

		buttonShowData[index][2] = button
	end

	self.Container.PromoCodeEditBoxFrame:SetText("")
	self.ScrollFrame:Hide()

	self.ActionButton:SetText(PROMOCODE_SHOW_REWARD)
	self.ActionButton:Disable()
	self.ActionButton.tooltip = nil

	self:SetHeight(DEFAULT_WINDOW_HEIGHT)

	self.CloseButton:SetToplevel(true)
	self.CloseButton:SetFrameStrata("TOOLTIP")
	self.CloseButton:SetScript("OnClick", function(self, ...) HideUIPanel(self:GetParent()) end)

	self.WaitServerResponseFrame:Hide()

	self.promoCode = nil
	self.windowState = 1
	self.offset = 0

	local scrollbar = _G[PromoCodeFrame.ScrollFrame:GetName().."ScrollBar"]
	scrollbar:SetValue(self.offset)

	PromoCodePopupFrame:Hide()

	self.Container.PromoCodeEditBoxFrame:Show()
	self.header.description:Show()
	self.header.promoCodeActiveLabel:Hide()
	self.Container.databaseText:Hide()

	self.Container.PromoCodeEditBoxFrame:EnableKeyboard(true)
end

function PromoCodeFrame_OnHide( self, ... )
	PromoCodePopupFrame:Hide()
	PromoCodeErrorFrame:Hide()
end

local animationTime = 0.500
function PromoCodeFrame_OnUpdate( self, elapsed, ... )
	if not self.isAnimationEnd then
		local rewardCount = GetPromoCodeRewardCount()
		local rewardCountMax = rewardCount > REWARD_BUTTON_MAX_DISPLAYED and REWARD_BUTTON_MAX_DISPLAYED or rewardCount
		local isShowAnimation = PromoCodeFrame.isAnimationShow
		local heightCalc = (60 * rewardCountMax) + (3 * rewardCountMax)
		local height =  inBack(self.elapsed, 0, heightCalc, animationTime)
		local offset

		if isShowAnimation then
			offset = self.height + height
		else
			offset = self.height - height
		end

		if isShowAnimation then
			for i = 1, rewardCountMax do
				local button = buttonShowData[i]

				if button and not button[2]:IsShown() then
					if self.elapsed >= button[1] then
						button[2]:Show()
					end
				end
			end
		else
			for i = rewardCountMax, 1, -1 do
				local button = buttonShowData[i]
				local elapsed = 0.500 - self.elapsed

				if button and button[2]:IsShown() then
					if elapsed <= button[1] then
						button[2].animOut:Play()
					end
				end
			end
		end

		self:SetHeight(offset)

		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 0.500 then
			self.Container.PromoCodeEditBoxFrame:EnableKeyboard(false)

			if isShowAnimation then
				self.windowState = 2
				PromoCodeFrameActionButton:SetText(PROMOCODE_RECIVE_REWARD)
				self.ScrollFrame:SetShown(rewardCount > REWARD_BUTTON_MAX_DISPLAYED)
				self:SetHeight(self.height + heightCalc)
				PromoCodeFrame_UpdateRewardButtons()
			else
				self:SetHeight(self.height - heightCalc)
				self.Container.PromoCodeEditBoxFrame.animOut:Play()
				self.header.description.animOut:Play()
				self.ScrollFrame:Hide()
				PromoCodeFrameActionButton:SetText(CLOSE)

				PromoCodeFrame.windowState = 3
			end

			PromoCodeFrame_ResetAnimation()
		end
	end
end

function PromoCodeFrame_ResetAnimation()
	PromoCodeFrame.isAnimationEnd = true
	PromoCodeFrame.elapsed = 0

	PromoCodeFrame:SetScript("OnUpdate", nil)
end

function PromoCodeFrame_StartAnimation( animationType )
	if PromoCodeFrame.isAnimationEnd then
		PromoCodeFrame.isAnimationEnd = false
		PromoCodeFrame.elapsed = 0
		PromoCodeFrame.isAnimationShow = animationType
		PromoCodeFrame.height = PromoCodeFrame:GetHeight()

		PromoCodeFrame:SetScript("OnUpdate", PromoCodeFrame_OnUpdate)
	end
end

function PromoCodeFrameActionButton_OnClick( self, ... )
	if PromoCodeFrame.isAnimationEnd then
		if PromoCodeFrame.windowState == 1 then
			if not PromoCodePopupFrame:IsShown() then
				local promoCodeStorage = PROMOCODE_CACHE:Get("ACTIVE_PROMOCODE", {}, nil, true)
				local editBoxText = PromoCodeFrame.Container.PromoCodeEditBoxFrame:GetText()

				if not promoCodeStorage[tostring(editBoxText)] then
					PromoCodePopupFrame:Show()
				else
					PromoCodeFrameEditBox_EnterCode(PromoCodeFrame.Container.PromoCodeEditBoxFrame)
				end
			end
		elseif PromoCodeFrame.windowState == 2 then
			SendServerMessage("ACMSG_PROMOCODE_SUBMIT", PromoCodeFrame.promoCode)
		elseif PromoCodeFrame.windowState == 3 then
			HideUIPanel(PromoCodeFrame)
		end
	end
end

function PromoCodeFrameEditBox_EnterCode( self, ... )
	PromoCodeFrame.WaitServerResponseFrame:Show()
	PromoCodeFrame.promoCode = tostring(self:GetText())

	self:ClearFocus()
	
	SendServerMessage("ACMSG_PROMOCODE_REWARD", PromoCodeFrame.promoCode)

	local promoCodeStorage = PROMOCODE_CACHE:Get("ACTIVE_PROMOCODE", {}, nil, true)
	promoCodeStorage[PromoCodeFrame.promoCode] = PromoCodeFrame.promoCode

	PROMOCODE_CACHE:Set("ACTIVE_PROMOCODE", promoCodeStorage, nil, true)
end

function PromoCodeScrollFrame_OnVerticalScroll(self, offset)
	local scrollbar = _G[self:GetName().."ScrollBar"]
	scrollbar:SetValue(offset) 
	PromoCodeFrame.offset = floor((offset / REWARD_BUTTON_HEIGHT) + 0.5)
	PromoCodeFrame_UpdateRewardButtons()
end

local PromoCodeTemplate = {
	[1] = { -- Быстрый старт
		icon = "Interface\\ICONS\\UI_Promotion_CharacterBoost",
		name = PROMOCODE_FAST_LEVEL_BOOST,
	},
	[2] = { -- Золото
		icon = "Interface\\ICONS\\Inv_misc_coin_01",
		name = PROMOCODE_GOLD,
	}
}

function PromoCodeFrame_UpdateRewardButtons()
	local rewardCount = GetPromoCodeRewardCount()
	local rewardCountMax = rewardCount > REWARD_BUTTON_MAX_DISPLAYED and REWARD_BUTTON_MAX_DISPLAYED or rewardCount
	
	for i = 1, rewardCountMax do
		local index = PromoCodeFrame.offset + i
		local button = PromoCodeFrame.rewardButtons[i]

		local itemData = PROMOCODE_ITEM_DATA[index]

		if itemData and button then
			local itemType, itemEntry, itemCount = unpack(itemData)
			local icon, name, link, quality

			if itemType == 0 then
				local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemEntry)

				icon 	= itemTexture
				name 	= itemName
				link 	= itemLink
				quality = itemQuality
			else
				local data = PromoCodeTemplate[itemType]

				if data then
					icon = data.icon
					name = data.name
				end
			end

			button.Icon:SetTexture(icon or "")
			button.Text:SetText(name or "")

			if quality then
				button.Text:SetTextColor(GetItemQualityColor(quality))
			else
				button.Text:SetTextColor(1, 1, 1)
			end

			if itemCount > 1 then
				button.Count:SetText(itemCount)
			else
				button.Count:SetText("")
			end

			button.link = link
		end
	end

	if rewardCount > REWARD_BUTTON_MAX_DISPLAYED then
		FauxScrollFrame_Update(PromoCodeFrame.ScrollFrame, rewardCount, REWARD_BUTTON_MAX_DISPLAYED, REWARD_BUTTON_HEIGHT, nil, nil, nil, nil, nil, nil, true)
	end

	if PromoCodeFrame.activeButton then
		PromoCodeLootButton_OnEnter(PromoCodeFrame.activeButton)
	end
end

function PromoCodeLootButton_OnEnter( self, ... )
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()

		self:GetParent().activeButton = self
	else
		if GameTooltip:IsShown() then
			GameTooltip_Hide()
		end
	end
end

function PromoCodePopupFrameAcceptButton_OnClick( self, ... )
	PromoCodeFrameEditBox_EnterCode(PromoCodeFrame.Container.PromoCodeEditBoxFrame)

	self:GetParent():Hide()
end

function PromoCodeShowErrorFrame( text )
	PromoCodeErrorFrame:Show()
	PromoCodeErrorFrame.Title:SetText(STORE_ERROR)
	PromoCodeErrorFrame.Description:SetText(text)
	PromoCodeErrorFrame.CloseButton:Hide()
end

function PromoCodeCacheRemove( promoCode )
	if not promoCode then
		return
	end

	local promoCodeStorage = PROMOCODE_CACHE:Get("ACTIVE_PROMOCODE", {}, nil, true)

	promoCodeStorage[promoCode] = nil
	PROMOCODE_CACHE:Set("ACTIVE_PROMOCODE", promoCodeStorage, nil, true)
end

function EventHandler:ASMSG_PROMOCODE_REWARD( msg )
	PROMOCODE_ITEM_DATA = {}

	PromoCodeFrame.WaitServerResponseFrame:Hide()

	local splitStorage = C_Split(msg, "|")
	local isCanActivatePromoCode = nil

	if #splitStorage > 1 then
		isCanActivatePromoCode = tonumber(table.remove(splitStorage, #splitStorage))

		for i = 1, #splitStorage do
			local splitData = splitStorage[i]

			if splitData then
				local itemData = C_Split(splitData, ":")
				PROMOCODE_ITEM_DATA[#PROMOCODE_ITEM_DATA + 1] = {tonumber(itemData[1]), tonumber(itemData[2]), tonumber(itemData[3])}
			end
		end
		PromoCodeFrame_StartAnimation(true)
	else
		local errorID = tonumber(msg)
		PromoCodeShowErrorFrame(_G["ASMSG_PROMOCODE_REWARD_ERROR"..errorID])

		PromoCodeCacheRemove(PromoCodeFrame.promoCode)
		return
	end

	PromoCodeFrame.ActionButton:SetEnabled(isCanActivatePromoCode == 1)

	if isCanActivatePromoCode ~= 1 then
		PromoCodeFrame.ActionButton.tooltip = PROMOCODE_ACTION_BUTTON_ERROR
	end
end

function EventHandler:ASMSG_PROMOCODE_SUBMIT( msg )
	local splitStorage = C_Split(msg, ":")
	PromoCodeCacheRemove(PromoCodeFrame.promoCode)

	if #splitStorage > 1 then
		PromoCodeFrame.Container.databaseText:SetText(splitStorage[2])
		PromoCodeFrame_StartAnimation(false)
	else
		local errorID = tonumber(msg)
		PromoCodeShowErrorFrame(_G["ASMSG_PROMOCODE_SUBMIT_EROR"..errorID])
		return
	end
end