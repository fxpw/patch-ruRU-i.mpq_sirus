local C_StoreSecure = C_StoreSecure

UIPanelWindows["Custom_RouletteFrame"] = { area = "center",	pushable = 0,	whileDead = 1 }

RouletteFrameMixin = {}

enum:E_ROULETTE_STAGE {
    "STOP",
    "STARTING",
    "PLAYING",
    "PREFINISH",
    "FINISHING",
    "FINISHED"
}

enum:E_ROULETTE_CURRENCY {
	"LUCKY_COIN",
	"BONUS",
}

local RING_ON_LUCK = 90860

function RouletteFrameMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()

    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterCustomEvent("STORE_BALANCE_UPDATE")

    self:SetScale(0.9)
    self.CloseButton:Hide()

    local nineSliceLayout = NineSliceUtil.GetLayout("Roulette")
    NineSliceUtil.ApplyLayout(self, nineSliceLayout)

	self.Background:SetAtlas("Roulette-Background", true)

    self.TopBorder:SetAtlas("Roulette-top-corner", true)
    self.BottomBorder:SetAtlas("Roulette-bottom-corner", true)
    self.LeftBorder:SetAtlas("Roulette-right-corner", true)
    self.RightBorder:SetAtlas("Roulette-right-corner", true)

    self.LeftBorder:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
    self.BottomBorder:SetSubTexCoord(0.0, 1.0, 1.0, 0.0)

    self.BottomBorder:ClearAllPoints()
    self.BottomBorder:SetPoint("BOTTOMLEFT", self.BotLeftCorner, "BOTTOMRIGHT", 0, 7.9)
    self.BottomBorder:SetPoint("BOTTOMRIGHT", self.BotRightCorner, "BOTTOMLEFT", 0.5, 0)

    self.TopBorder:ClearAllPoints()
    self.TopBorder:SetPoint("TOPLEFT", self.TopLeftCorner, "TOPRIGHT", -1, -8.8)
    self.TopBorder:SetPoint("TOPRIGHT", self.TopRightCorner, "TOPLEFT", 1, 0)

    self.LeftBorder:ClearAllPoints()
    self.LeftBorder:SetPoint("TOPLEFT", self.TopLeftCorner, "BOTTOMLEFT", 9, 0)
    self.LeftBorder:SetPoint("BOTTOMLEFT", self.BotLeftCorner, "TOPLEFT", 0, -1)

    self.RightBorder:ClearAllPoints()
    self.RightBorder:SetPoint("TOPRIGHT", self.TopRightCorner, "BOTTOMRIGHT", -8.6, 1)
    self.RightBorder:SetPoint("BOTTOMRIGHT", self.BotRightCorner, "TOPRIGHT", 0, 0)

	self.stage = E_ROULETTE_STAGE.STOP
	self.currencyFrameElapsed = 0
	self.selectedCurrency = 1

	self.marging = 0
	self.cardWidth = math.floor(self.itemButtons[1]:GetWidth()) + self.marging
	self.cardHolderWidth = self.cardWidth * #self.itemButtons

    self.rewardDataAssociate =  {}
    self.rewardQualityMap    =  {}
    self.rewardButtons       = {}

	self.ToggleCurrencyFrame.currencyButtons[2].Text:SetFormattedText(STORE_CURRENCY_BONUS_FORMAT, 0)
end

function RouletteFrameMixin:OnShow()
    Custom_RouletteFrame:SelectCurrency(E_ROULETTE_CURRENCY.LUCKY_COIN, true);
end

function RouletteFrameMixin:OnHide()
    self.confirmPlayWithBonuses = nil;
    StaticPopup_Hide("CONFIRM_ROULETTE_PLAY");
    self:Reset()
end

---@param event string
function RouletteFrameMixin:OnEvent(event, ...)
    if event == "CURRENCY_DISPLAY_UPDATE" then
		local amount = GetItemCount(280511)
		if self.currentLuckiCoin ~= amount then
			self.currentLuckiCoin = amount
			self.ToggleCurrencyFrame.currencyButtons[1].Text:SetFormattedText(ROULETTE_LUCKY_COIN_BUTTON_TEXT, amount)
			self:UpdateSpinButton()
		end
	elseif event == "STORE_BALANCE_UPDATE" then
		local bonus = C_StoreSecure.GetBalance(Enum.Store.CurrencyType.Bonus)
		if self.currentBonuses ~= bonus then
			self.currentBonuses = bonus
			self.ToggleCurrencyFrame.currencyButtons[2].Text:SetFormattedText(STORE_CURRENCY_BONUS_FORMAT, bonus)
			self:UpdateSpinButton()
		end
    elseif event == "VARIABLES_LOADED" then
		local info = C_CacheInstance:Get("ASMSG_LOTTERY_INFO")
		if info and #info > 0 then
            self:Initialize()
        end

        self.fastAnimation = C_CVar:GetValue("C_CVAR_ROULETTE_SKIP_ANIMATION") == 1
    end
end

function RouletteFrameMixin:HasItems()
	return self.rewardData and #self.rewardData > 0
end

function RouletteFrameMixin:UpdateSpinButton()
	if not self:HasItems() then
		self.SpinButton:SetEnabled(false)
		return
	end

	local selectedCurrency = self:GetSelectedCurrency()
	local isEnabled, rollPrice

	if selectedCurrency == E_ROULETTE_CURRENCY.LUCKY_COIN then
		self.SpinButton.PriceText:SetText(_G[string.format("ROULETTE_CURRENCY_PRICE_TITLE_%d", selectedCurrency)])
		rollPrice = 1
		isEnabled = self.currentLuckiCoin and self.currentLuckiCoin >= rollPrice
	elseif selectedCurrency == E_ROULETTE_CURRENCY.BONUS then
		self.SpinButton.PriceText:SetFormattedText(_G[string.format("ROULETTE_CURRENCY_PRICE_TITLE_%d", selectedCurrency)], self.bonusPrice or 999)
		rollPrice = self.bonusPrice or 999
		isEnabled = C_Service.IsInGMMode() or (self.currentBonuses and self.currentBonuses >= rollPrice)
	end

	local color = isEnabled and HIGHLIGHT_FONT_COLOR or CreateColor(0.8, 0.8, 0.8)
    self.SpinButton:SetEnabled(isEnabled)
    self.SpinButton.DisabledTexture:SetDesaturated(not isEnabled)
    self.SpinButton.Spin:SetTextColor(color.r, color.g, color.b)
    self.SpinButton.lockButton = not isEnabled
end

---@param pieceName string
---@return table pieceObject
function RouletteFrameMixin:GetNineSlicePiece( pieceName )
    if pieceName == "TopLeftCorner" then
        return self.TopLeftCorner
    elseif pieceName == "TopRightCorner" then
        return self.TopRightCorner
    elseif pieceName == "BottomLeftCorner" then
        return self.BotLeftCorner
    elseif pieceName == "BottomRightCorner" then
        return self.BotRightCorner
    end
end

---@return table itemInfo
function RouletteFrameMixin:GetRandomReward()
    if #self.blackList > 5 then
        local reward = table.remove(self.blackList, 1)
        local isGem  = reward == self.rewardData[#self.rewardData]
        local index = isGem and #self.itemsList or math.random(#self.itemsList - 1)
        table.insert(self.itemsList, index, reward)
    end

    self.rewardCount = self.rewardCount + 1
    if self.rewardCount >= 20 and self.rewardGem or self.rewardGem then
        self.rewardCount = 0
        self.rewardGem = false
    end

    local rnd = math.random(#self.itemsList)
    local rndIdx = self.initialization and 0 or ((self:IsRingOfLuckEquipment() and 2 or 4) - self.rewardCount / 10)

    if rndIdx > 0 then
        for _ = 1, math.floor(rndIdx) do
            rnd = math.random(1, rnd)
        end
    elseif not self.initialization then
        rnd = math.random(math.min(math.max(1, math.abs(rndIdx * 10)), #self.itemsList), #self.itemsList)
    end

    local reward = table.remove(self.itemsList, rnd)
    local isGem  = reward == self.rewardData[#self.rewardData]

    if isGem then
        table.insert(self.blackList, 1, reward)
    else
        table.insert(self.blackList, reward)
    end

    if reward == self.rewardData[#self.rewardData] then
        self.rewardGem = true
    end

    return reward
end

---@param elapsed number
function RouletteFrameMixin:CurrencyFrameUpdate( elapsed )
    if not self.toggleAnimation then
        return
    end

    local selectedCurrency  = self:GetSelectedCurrency()
    local startOffset       = selectedCurrency == E_ROULETTE_CURRENCY.LUCKY_COIN and 76 or -76
    local endOfset          = selectedCurrency == E_ROULETTE_CURRENCY.LUCKY_COIN and -76 or 76

	self.currencyFrameElapsed = self.currencyFrameElapsed + elapsed

    local xOffset = C_outCirc(self.currencyFrameElapsed, startOffset, endOfset, 0.300)

    self.ToggleCurrencyFrame.CurrencySelector:SetPoint("CENTER", xOffset, 0)

	if self.currencyFrameElapsed >= 0.300 then
        self.toggleAnimation        = false
        self.currencyFrameElapsed   = 0

        self.ToggleCurrencyFrame.CurrencySelector:SetPoint("CENTER", endOfset, 0)
    end
end

---@param currencyID number
function RouletteFrameMixin:SelectCurrency(currencyID, skipAnimation)
    if self.selectedCurrency == currencyID or self.toggleAnimation then
        return
    end

    if currencyID == E_ROULETTE_CURRENCY.LUCKY_COIN then
        StaticPopup_Hide("CONFIRM_ROULETTE_PLAY");

    elseif currencyID == E_ROULETTE_CURRENCY.BONUS then
        if not self.confirmPlayWithBonuses then
            StaticPopup_Show("CONFIRM_ROULETTE_PLAY", self.bonusPrice or 999, self.currentBonuses or 0, currencyID);
            return;
        end
    end

    self.selectedCurrency = currencyID;

    if skipAnimation then
        self.ToggleCurrencyFrame.CurrencySelector:SetPoint("CENTER", currencyID == E_ROULETTE_CURRENCY.LUCKY_COIN and -76 or 76, 0);
    else
        self.toggleAnimation = true;
    end
    self:UpdateSpinButton();
end

---@return number currencyID
function RouletteFrameMixin:GetSelectedCurrency()
    return self.selectedCurrency
end

function RouletteFrameMixin:Initialize()
    self.stage = E_ROULETTE_STAGE.STOP

	self.elapsed = 0
	self.speedFactor = 0
	self.totalOffset = 0
	self.rewardCardOffset = 0
	self.currentCardID = 0
	self.rewardCardID = 0

	self.accelerationTime = 0.5
	self.maxSpeedPixelPerSecond = 2000

    self.items              = {}
    self.blackList          = {}
    self.itemsList          = {}
    self.indexes            = {}

    self.rewardCount        = 0
    self.rewardGem          = false


    self.winnerRewardData   = nil
    self.winnerButton       = nil

	self.rewardData = C_CacheInstance:Get("ASMSG_LOTTERY_INFO", {})

    local cardsPerLine = 7

    for index, data in pairs(self.rewardData) do
		if index == 0 then
			self.bonusPrice = data
		else
			if index >= 15 then
				break
			end

			self.rewardButtons[index] = self.rewardButtons[index] or CreateFrame("Button", "RouletteRewardButton"..index, self.RewardItemsFrame, "Custom_RouletteRewardButtonTemplate")

			if index == 1 then
				self.rewardButtons[index]:SetPoint("TOPLEFT", 10, -48)
			elseif mod(index - 1, cardsPerLine) == 0 then
				self.rewardButtons[index]:SetPoint("TOP", self.rewardButtons[index - cardsPerLine], "BOTTOM", 0, -12)
			else
				self.rewardButtons[index]:SetPoint("LEFT", self.rewardButtons[index - 1], "RIGHT", 12, 0)
			end

			self.rewardButtons[index]:SetItem(data)
			self.rewardButtons[index]:SetShown(data)

			self.rewardDataAssociate[string.format("%d:%d:%d", data.itemID, data.amountMin and data.amountMin or 0, data.isJackpot and 1 or 0)] = data

			self.indexes[data] = index
			self.itemsList[index] = data
		end
    end

    self.initialization = true

    for i=1, #self.itemButtons do
        self.items[i] = self:GetRandomReward()
        self.itemButtons[i]:SetItem(self.items[i])
    end

    self.initialization = false

    self.itemButtons[1]:SetPoint("LEFT", 0, 0)
end

---@return boolean isFastAnimation
function RouletteFrameMixin:isAnimationSkipped()
    return self.fastAnimation
end

---@param state boolean
function RouletteFrameMixin:SetFastAnimationState( state )
    self.fastAnimation = state
end

function RouletteFrameMixin:OnUpdate(elapsed)
	if self.stage == E_ROULETTE_STAGE.STOP or self.stage == E_ROULETTE_STAGE.FINISHED then
		return
	end

	local timeMult = self:isAnimationSkipped() and 15 or 1
	self.elapsed = self.elapsed + elapsed * timeMult

	if self.stage == E_ROULETTE_STAGE.STARTING then
		self.speedFactor = self.elapsed / self.accelerationTime

		if self.speedFactor >= 1 then
			self.speedFactor = 1
			self:ChangeStage(E_ROULETTE_STAGE.PLAYING)
		end
	elseif self.stage == E_ROULETTE_STAGE.PREFINISH then
		local rndState = math.random(0, 100)
		local rndRewardOffset
		local screenDistanceMult

		if rndState <= 30 then
			rndRewardOffset = math.random(-420, 0) / 1000
		elseif rndState <= 70 then
			rndRewardOffset = math.random(-420, 420) / 1000
		else
			rndRewardOffset = math.random(0, 420) / 1000
		end

		if GetFramerate() >= 60 then
			if self:isAnimationSkipped() then
				screenDistanceMult = math.random(14, 20)
			else
				screenDistanceMult = math.random(8, 18)
			end
		else
			if self:isAnimationSkipped() then
				screenDistanceMult = math.random(14, 20)
			else
				screenDistanceMult = math.random(8, 16)
			end
		end

		local speedScreenRatio = self.cardHolderWidth / self.maxSpeedPixelPerSecond
		local rewardScreenDistance = math.floor(speedScreenRatio * screenDistanceMult)
		local baseRewardOffset = (math.floor(self.totalOffset / self.cardHolderWidth) + rewardScreenDistance) * self.cardHolderWidth

		self.rewardCardID = self.currentCardID + math.abs(math.floor((baseRewardOffset - self.totalOffset) / self.cardHolderWidth * #self.itemButtons))
		self.rewardCardOffset = baseRewardOffset + rndRewardOffset * self.cardWidth + self.cardWidth / 2
		self.rewardCardDistance = self.rewardCardOffset - self.totalOffset

		self:ChangeStage(E_ROULETTE_STAGE.FINISHING)
	end
	if self.stage == E_ROULETTE_STAGE.FINISHING then
		local rewardDistanceLeft = self.rewardCardOffset - self.totalOffset + 8
		local distLeftProgress = outSine(rewardDistanceLeft, 0, 1, self.rewardCardDistance)
		self.speedFactor = distLeftProgress * timeMult
	end

	local pixelsPerSecond = self.maxSpeedPixelPerSecond * self.speedFactor
	local tickOffset = (elapsed * pixelsPerSecond)
	local newOffset = self.totalOffset + tickOffset
	local done

	if self.stage == E_ROULETTE_STAGE.FINISHING and newOffset >= self.rewardCardOffset then
		newOffset = self.rewardCardOffset
		done = true
	end

	local currentOffset = self.totalOffset
	local buttonOffset = newOffset % self.cardWidth
	local lastButtonID = math.floor(currentOffset / self.cardWidth)
	local currentButtonID = math.floor(newOffset / self.cardWidth)

	self.totalOffset = newOffset
	self.itemButtons[1]:SetPoint("LEFT", -buttonOffset, 0)

	if lastButtonID ~= currentButtonID then
		local invert = lastButtonID > currentButtonID
		local diff = invert and (lastButtonID - currentButtonID) or (currentButtonID - lastButtonID)
		local iter = invert and -1 or 1

		for i = 1, diff do
			self.currentCardID = self.currentCardID + iter

			local item

			if self.stage == E_ROULETTE_STAGE.FINISHING then
				if self.rewardCardID - self.currentCardID == 3 then
					if self.winnerRewardData then
						item = self.winnerRewardData
					else
						local color = RED_FONT_COLOR
						UIErrorsFrame:AddMessage(ROULETTE_ERROR_UNKNOWN, color.r, color.g, color.b)
						HideUIPanel(self)
						return
					end
				end
			end

			if not item then
				item = self:GetRandomReward()
			end

			if invert then
				table.remove(self.items)
				table.insert(self.items, 1, item)
			else
				table.remove(self.items, 1)
				table.insert(self.items, item)
			end
		end

		for index, button in ipairs(self.itemButtons) do
			local rewardData = self.items[index]
			if self.winnerRewardData == rewardData then
				self.winnerButton = button
			end

			button:SetID(currentButtonID - 5 + index)
			button:SetItem(rewardData)
		end
	end

	if done then
		self:ChangeStage(E_ROULETTE_STAGE.FINISHED)
	end
end

function RouletteFrameMixin:Start()
    if self.stage == E_ROULETTE_STAGE.STOP or self.stage == E_ROULETTE_STAGE.FINISHED then
		self.totalOffset = (self.totalOffset % self.cardWidth)
		self.elapsed = (self.elapsed % 1)
		self.speedFactor = 0

		self.currentCardID = self.totalOffset > 0 and 1 or 0

        self:ChangeStage(E_ROULETTE_STAGE.STARTING)
    end
end

function RouletteFrameMixin:Stop()
    if self.stage == E_ROULETTE_STAGE.PLAYING then
        self:ChangeStage(E_ROULETTE_STAGE.PREFINISH)
    end
end

function RouletteFrameMixin:Reset()
	if not self:HasItems() then
		return
	end

    if self.requestReward then
        self:UpdateSpinButton()
        self.requestReward = false
    else
        C_Timer:After(2, function()
            self:ChangeStage(E_ROULETTE_STAGE.FINISHED, true)
        end)
    end

    self:Initialize()
end

function RouletteFrameMixin:SpinButtonOnClick()
    for i = 11, 12 do
		if GetInventoryItemID("player", i) == RING_ON_LUCK then
            self.ringOfLuckEquipment = true
            break
        end
    end

    if self.winnerButton then
        self.winnerButton:HideWinnerEffect()
    end

	local selectedCurrency = self:GetSelectedCurrency()
	SendServerMessage("ACMSG_LOTTERY_PLAY", selectedCurrency == E_ROULETTE_CURRENCY.LUCKY_COIN and 1 or 0)
end

---@return boolean ringOfLuckEquipment
function RouletteFrameMixin:IsRingOfLuckEquipment()
	return self.ringOfLuckEquipment
end

---@param newStage number
function RouletteFrameMixin:ChangeStage(newStage, skipFinishingEffect)
    self.stage = newStage

	self.SkipAnimation:SetEnabled(self.stage == E_ROULETTE_STAGE.STOP or self.stage == E_ROULETTE_STAGE.FINISHED)

    if self.stage == E_ROULETTE_STAGE.STARTING then
        self.WinnerEffectFrame:StopAnim()

        self.SpinButton:Disable()
        self.requestReward = false

    elseif self.stage == E_ROULETTE_STAGE.PLAYING then
        if not self:isAnimationSkipped() then
            C_Timer:After(math.random(1,2), function() self:Stop() end)
        else
            self:Stop()
        end
    elseif self.stage == E_ROULETTE_STAGE.FINISHED then
        SendServerMessage("ACMSG_LOTTERY_REWARD")
        self.requestReward = true

        if not skipFinishingEffect then
            self.WinnerEffectFrame:ClearAllPoints()
            self.WinnerEffectFrame:SetPoint(self.winnerButton:GetPoint())
            self.WinnerEffectFrame:SetFrameLevel(self.winnerButton:GetFrameLevel() - 1)

            self.WinnerEffectFrame:PlayAnim()

            local color = self.winnerButton.color
            self.WinnerEffectFrame.CrestSparks:SetVertexColor(color.r, color.g, color.b)
            self.WinnerEffectFrame.CrestSparks2:SetVertexColor(color.r, color.g, color.b)

            self.winnerButton:ShowWinnerEffect()
        end
        self:UpdateSpinButton()
    end
end

local CLOSE_STATUS = {
	ROULETTE_ERROR_SUSPECT,
	ROULETTE_ERROR_OUT_RANGE,
	ROULETTE_ERROR_NOT_ENOUGHT_BONUSES,
	ROULETTE_ERROR_NOT_ENOUGHT_LUCKY_COINS
}

function RouletteFrameMixin:ASMSG_LOTTERY_OPEN()
	ShowUIPanel(self)
end

function RouletteFrameMixin:ASMSG_LOTTERY_CLOSE(msg)
	local errorMsg = CLOSE_STATUS[tonumber(msg)]

	if errorMsg then
		UIErrorsFrame:AddMessage(errorMsg, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	end

	HideUIPanel(self)
end

function RouletteFrameMixin:ASMSG_LOTTERY_REWARD(msg)
	local itemID, amount, isJackpot = string.split(":", msg)
	local quality = Custom_RouletteFrame.rewardDataAssociate[msg] and Custom_RouletteFrame.rewardDataAssociate[msg].quality or 1

	if isJackpot then
		self.winnerRewardData = {
			itemID = tonumber(itemID),
			amount = tonumber(amount),
			quality = quality,
			isJackpot = isJackpot == "1",
		}

		if self:IsShown() then
			self:Start()
		end
	end
end

local sortByQuality = function(a, b)
	return a.quality < b.quality
end

function RouletteFrameMixin:ASMSG_LOTTERY_INFO(msg)
	local bonusPrice, itemListStr = string.split("|", msg, 2)

	if itemListStr == "" then
		return
	end

	local itemList = {}

	for index, itemStr in ipairs({string.split("|", (itemListStr:gsub("|$", "")))}) do
		local itemID, amountMin, amountMax, isJackpot, quality = string.split(",", itemStr)
		itemID = tonumber(itemID)

		local name = C_Item.GetItemInfoRaw(itemID)
		if not name then
			C_Item.RequestServerCache(itemID)
		end

		table.insert(itemList, {
			itemID		= itemID,
			amountMin	= tonumber(amountMin),
			amountMax	= tonumber(amountMax),
			isJackpot	= isJackpot == "1",
			quality		= tonumber(quality) or 1,
		})
	end

	table.sort(itemList, sortByQuality)

	self.bonusPrice = tonumber(bonusPrice)
	itemList[0] = self.bonusPrice

	C_CacheInstance:Set("ASMSG_LOTTERY_INFO", itemList)

	if #itemList > 0 then
		self:Initialize()
	end
end

RouletteItemButtonMixin = {}

function RouletteItemButtonMixin:OnLoad()
    self.Background:SetAtlas("Roulette-item-background")
    self.BorderOverlay:SetAtlas("Roulette-item-frame")
end

function RouletteItemButtonMixin:ShowWinnerEffect()
    self.BorderOverlay:Show()
    self.BorderOverlay.Light:Play()

    self.OverlayFrame.ChildFrame.JackpotCircleLight3:Show()
    self.OverlayFrame.ChildFrame.JackpotCircleLight3.Light:Play()

    self.OverlayFrame.ChildFrame.IconBorderOverlay:Show()
    self.OverlayFrame.ChildFrame.IconBorderOverlay.Light:Play()
end

function RouletteItemButtonMixin:HideWinnerEffect()
    self.BorderOverlay:Hide()
    self.BorderOverlay.Light:Stop()

    self.OverlayFrame.ChildFrame.JackpotCircleLight3:Hide()
    self.OverlayFrame.ChildFrame.JackpotCircleLight3.Light:Stop()

    self.OverlayFrame.ChildFrame.IconBorderOverlay:Hide()
    self.OverlayFrame.ChildFrame.IconBorderOverlay.Light:Stop()
end

---@param quality number
function RouletteItemButtonMixin:SetQuality( quality )
    local color = BAG_ITEM_QUALITY_COLORS[quality]

    if self.Border then
        self.Border:SetVertexColor(color.r, color.g, color.b)
    end

    self.Background:SetVertexColor(color.r, color.g, color.b)
    self.BorderOverlay:SetVertexColor(color.r, color.g, color.b)
    self.OverlayFrame.ChildFrame.IconBorder:SetVertexColor(color.r, color.g, color.b)
    self.OverlayFrame.ChildFrame.IconBorderOverlay:SetVertexColor(color.r, color.g, color.b)
    self.OverlayFrame.ChildFrame.JackpotLight:SetVertexColor(color.r, color.g, color.b)

    self.OverlayFrame.ChildFrame.JackpotCircleLight1:SetVertexColor(color.r, color.g, color.b)
    self.OverlayFrame.ChildFrame.JackpotCircleLight2:SetVertexColor(color.r, color.g, color.b)
    self.OverlayFrame.ChildFrame.JackpotCircleLight3:SetVertexColor(color.r, color.g, color.b)

    self.OverlayFrame.ChildFrame.QualityLight:SetVertexColor(color.r, color.g, color.b)

    self.color = color
end

---@param isJackpot boolean
function RouletteItemButtonMixin:SetJackpot( isJackpot )
    self.OverlayFrame.ChildFrame.JackpotLight:SetShown(isJackpot)
    self.OverlayFrame.ChildFrame.JackpotCircleLight1:SetShown(isJackpot)
    self.OverlayFrame.ChildFrame.JackpotCircleLight2:SetShown(isJackpot)
end

---@param itemInfo table
function RouletteItemButtonMixin:SetItem( itemInfo )
    if itemInfo then
        self:SetQuality(itemInfo.quality)

        if itemInfo.itemID == -1 or itemInfo.itemID == -2 then
            local function updateFaction()
                local unitFaction   = UnitFactionGroup("player")

                if itemInfo.itemID == -1 then
                    SetPortraitToTexture(self.OverlayFrame.ChildFrame.Icon, "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction)
                else
                    SetPortraitToTexture(self.OverlayFrame.ChildFrame.Icon, "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction)
                end
            end

            C_FactionManager:RegisterFactionOverrideCallback(updateFaction, true)

            self.itemLink       = nil
            self.tooltipHeader  = itemInfo.itemID == -1 and HONOR_POINTS or ARENA_POINTS
            self.tooltipText    = itemInfo.itemID == -1 and TOOLTIP_HONOR_POINTS or TOOLTIP_ARENA_POINTS

            self.OverlayFrame.ChildFrame.ItemName:SetText(itemInfo.itemID == -1 and HONOR_POINTS or ARENA_POINTS)
        else
			local function itemInfoResponceCallback(_, itemName, itemLink, _, _, _, _, _, _, _, itemTexture)
				self.itemLink = itemLink

				self.OverlayFrame.ChildFrame.ItemName:SetText(itemName)
				SetPortraitToTexture(self.OverlayFrame.ChildFrame.Icon, itemTexture)
			end

			local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemInfo.itemID, false, itemInfoResponceCallback, true)

            if itemName then
				itemInfoResponceCallback(nil, itemName, itemLink, nil, nil, nil, nil, nil, nil, nil, itemTexture)
            else
				itemInfoResponceCallback(nil, LOADING_LABEL, "Hitem:1", nil, nil, nil, nil, nil, nil, nil, "Interface\\ICONS\\INV_Misc_QuestionMark")
            end
        end

        self:SetJackpot(itemInfo.isJackpot)

        if itemInfo.amountMax then
            if itemInfo.amountMin == itemInfo.amountMax then
                self.OverlayFrame.ChildFrame.ItemCount:SetText(itemInfo.amountMin)
            else
                self.OverlayFrame.ChildFrame.ItemCount:SetFormattedText("%s - %s", itemInfo.amountMin, itemInfo.amountMax)
            end
        else
            self.OverlayFrame.ChildFrame.ItemCount:SetText(itemInfo.amountMin or itemInfo.amount)
        end

		local amount = itemInfo.amountMin or itemInfo.amount
        self.OverlayFrame.ChildFrame.ItemCount:SetShown(amount and amount > 1)
    end
end