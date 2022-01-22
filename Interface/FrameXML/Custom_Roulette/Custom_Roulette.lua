--	Filename:	Custom_Roulette.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

UIPanelWindows["Custom_RouletteFrame"] = { area = "center",	pushable = 0,	whileDead = 1 }

RouletteFrameMixin = {}

enum:E_ROULETTE_STAGE {
    "STOP",
    "STARTING",
    "PLAYING",
    "FINISH",
    "FINISHING",
    "FINISHED"
}

function RouletteFrameMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()

    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("VARIABLES_LOADED")

    self:SetScale(0.9)
    self.CloseButton:Hide()

    local nineSliceLayout = NineSliceUtil.GetLayout("Roulette")
    NineSliceUtil.ApplyLayout(self, nineSliceLayout)

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

    self.currencyFrameElapsed   = 0
    self.selectedCurrency       = 1

    self.marging                = 0
    self.blockSize              = math.floor(self.itemButtons[1]:GetWidth()) + self.marging
    self.totalSize              = self.blockSize * #self.itemButtons
    self.speedLimit             = 14

    self.ringOfLuckItemEntry    = 90860

    self.rewardDataAssociate =  {}
    self.rewardQualityMap    =  {}
    self.rewardButtons       = {}

    self.ToggleCurrencyFrame.currencyButtons[2].Text:SetFormattedText(STORE_PREMIUM_PRICE_FORMAT, 0)
end

---@param event string
function RouletteFrameMixin:OnEvent( event )
    if event == "CURRENCY_DISPLAY_UPDATE" then
        self.ToggleCurrencyFrame.currencyButtons[1].Text:SetFormattedText(ROULETTE_LUCKY_COIN_BUTTON_TEXT, 0)

        for i = 1, GetCurrencyListSize() do
            local _, _, _, _, _, count, _, _, itemID = GetCurrencyListInfo(i)

            if itemID == 280511 then
                self.ToggleCurrencyFrame.currencyButtons[1].Text:SetFormattedText(ROULETTE_LUCKY_COIN_BUTTON_TEXT, count)
                self.currentLuckiCoin = count

                self:UpdateSpinButton()
                break
            end
        end
    elseif event == "VARIABLES_LOADED" then
        if C_CacheInstance:Get("ASMSG_LOTTERY_REWARDS_LIST") then
            self:Initialize()
        end

        self.fastAnimation = C_CVar:GetValue("C_CVAR_ROULETTE_SKIP_ANIMATION") == 1
    end
end

function RouletteFrameMixin:UpdateSpinButton()
    local isEnabled = ((self:GetSelectedCurrency() == 2 and (self.currentBonuses and self.currentBonuses > 2)) or (self:GetSelectedCurrency() == 1 and (self.currentLuckiCoin and self.currentLuckiCoin > 0)))
    local color     = isEnabled and HIGHLIGHT_FONT_COLOR or CreateColor(0.8, 0.8, 0.8)

    self.SpinButton:SetEnabled(isEnabled)
    self.SpinButton.DisabledTexture:SetDesaturated(not isEnabled)
    self.SpinButton.Spin:SetTextColor(color.r, color.g, color.b)
    self.SpinButton.lockButton = not isEnabled
    self.SpinButton.PriceText:SetText(_G[string.format("ROULETTE_CURRENCY_PRICE_TITLE_%d", self:GetSelectedCurrency())])
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
    local startOffset       = selectedCurrency == 1 and 76 or -76
    local endOfset          = selectedCurrency == 1 and -76 or 76

    local xOffset = C_outCirc(self.currencyFrameElapsed, startOffset, endOfset, 0.300)

    self.ToggleCurrencyFrame.CurrencySelector:SetPoint("CENTER", xOffset, 0)

    self.currencyFrameElapsed = self.currencyFrameElapsed + elapsed

    if self.currencyFrameElapsed > 0.300 then
        self.toggleAnimation        = false
        self.currencyFrameElapsed   = 0

        self.ToggleCurrencyFrame.CurrencySelector:SetPoint("CENTER", endOfset, 0)
    end
end

---@param currencyID number
function RouletteFrameMixin:SelectCurrency( currencyID )
    if self.selectedCurrency == currencyID or self.toggleAnimation then
        return
    end

    self.selectedCurrency   = currencyID
    self.toggleAnimation    = true

    self:UpdateSpinButton()
end

---@return number currencyID
function RouletteFrameMixin:GetSelectedCurrency()
    return self.selectedCurrency
end

function RouletteFrameMixin:Initialize()
    self.stage = E_ROULETTE_STAGE.STOP

    self.timer              = 0
    self.speed              = 0

    self.targetOffset       = 0
    self.targetTimer        = 0
    self.currentId          = 1
    self.targetId           = 0

    self.offset             = 0
    self.lastOffset         = 0

    self.items              = {}
    self.blackList          = {}
    self.itemsList          = {}
    self.indexes            = {}

    self.rewardCount        = 0
    self.rewardGem          = false


    self.winnerRewardData   = nil
    self.winnerButton       = nil

    self.rewardData = C_CacheInstance:Get("ASMSG_LOTTERY_REWARDS_LIST", {})

    local cardsPerLine = 7

    for index, data in pairs(self.rewardData) do
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

        self.rewardDataAssociate[string.format("%d:%d:%d", data.itemEntry, data.itemCountMin and data.itemCountMin or 0, data.isJackpot and 1 or 0)] = data

        self.indexes[data] = index
        self.itemsList[index] = data
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

function RouletteFrameMixin:OnUpdate()
    if self.stage == E_ROULETTE_STAGE.STOP then
        return
    end

    for _ = 1, self:isAnimationSkipped() and 30 or 2 do
        if self.stage == E_ROULETTE_STAGE.STARTING then
            if self.speed < self.speedLimit then
                self.speed = (self.speed + 0.1) * 1.025
            else
                self.speed = self.speedLimit
                self:ChangeStage(E_ROULETTE_STAGE.PLAYING)
            end
        elseif self.stage == E_ROULETTE_STAGE.FINISH then
            local rndState = math.random(0, 10)

            if C_InRange(rndState, 0, 3) then
                self.targetOffset = math.random(-420, 0) / 1000
            elseif C_InRange(rndState, 4, 6) then
                self.targetOffset = math.random(-420, 420) / 1000
            elseif C_InRange(rndState, 7, 10) then
                self.targetOffset = math.random(0, 420) / 1000
            end

            self.targetTimer = (math.floor(self.timer / self.totalSize) + 2) * self.totalSize
            self.targetId = self.currentId + math.abs(math.floor(((self.targetTimer - self.timer) / self.totalSize) * #self.itemButtons))
            self.targetTimer = self.targetTimer + self.targetOffset * self.blockSize + self.blockSize / 2
            self.randomSpeed = math.random(500, 600) / 100

            self:ChangeStage(E_ROULETTE_STAGE.FINISHING)
        elseif self.stage == E_ROULETTE_STAGE.FINISHING then
            if self.timer < self.targetTimer then
                local dist = self.targetTimer - self.timer
                local offset = dist / (self.speedLimit * self.randomSpeed)

                self.speed = math.min(offset + 0.1, self.speedLimit)
            else
                self.speed = 0
                self.timer = self.targetTimer

                self:ChangeStage(E_ROULETTE_STAGE.FINISHED)
            end
        end

        if GetFramerate() > 60 then
            self.timer = self.timer + self.speed / (GetFramerate() / 60)
        else
            self.timer = self.timer + self.speed
        end

        self.lastOffset = self.offset
        self.offset = (self.timer % self.blockSize)

        if self.stage ~= E_ROULETTE_STAGE.FINISHED then
            if self.lastOffset > self.offset then
                self.currentId = self.currentId + 1

                local item = self:GetRandomReward()

                if self.stage == E_ROULETTE_STAGE.FINISHING then
                    local targetId = self.targetId - self.currentId

                    if targetId == 3 then
                        if not self.winnerRewardData then
                            UIErrorsFrame:AddMessage(ROULETTE_ERROR_UNKNOWN, color.r, color.g, color.b)

                            HideUIPanel(self)
                        end

                        item = self.winnerRewardData
                    end
                end

                table.remove(self.items, 1)
                table.insert(self.items, item)

                for i=1, #self.itemButtons do
                    local rewardData    = self.items[i]
                    local button        = self.itemButtons[i]

                    if self.winnerRewardData == rewardData then
                        self.winnerButton = button
                    end

                    button:SetItem(rewardData)
                end
            end
        end

        self.itemButtons[1]:SetPoint("LEFT", -self.offset, 0)
    end
end

function RouletteFrameMixin:Start()
    if self.stage == E_ROULETTE_STAGE.STOP or self.stage == E_ROULETTE_STAGE.FINISHED then
        self.timer = (self.timer % self.blockSize)

        self.currentId = 1

        self:ChangeStage(E_ROULETTE_STAGE.STARTING)
    end
end

function RouletteFrameMixin:Stop()
    if self.stage == E_ROULETTE_STAGE.PLAYING then
        self:ChangeStage(E_ROULETTE_STAGE.FINISH)
    end
end

function RouletteFrameMixin:Reset()
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
        if GetInventoryItemID("player", i) == self.ringOfLuckItemEntry then
            self.ringOfLuckEquipment = true
            break
        end
    end

    local selectedCurrency = self:GetSelectedCurrency()
    SendServerMessage("ACMSG_LOTTERY_PLAY", selectedCurrency == 1 and 1 or 0)

    if self.winnerButton then
        self.winnerButton:HideWinnerEffect()
    end
end

---@return boolean ringOfLuckEquipment
function RouletteFrameMixin:IsRingOfLuckEquipment()
    return isset(self.ringOfLuckEquipment)
end

---@param newStage number
function RouletteFrameMixin:ChangeStage(newStage, skipFinishingEffect)
    self.stage = newStage

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

---@param bonus number
function RouletteFrameMixin:PLAYER_BALANCE_UPDATE( bonus )
    self.ToggleCurrencyFrame.currencyButtons[2].Text:SetFormattedText(STORE_PREMIUM_PRICE_FORMAT, bonus)
    self.currentBonuses = bonus

    self:UpdateSpinButton()
end

function RouletteFrameMixin:ASMSG_LOTTERY_OPEN()
    if not self:IsShown() then
        ShowUIPanel(self)
    end
end

enum:E_LOTTERY_CLOSE_ERRORS {
    ROULETTE_ERROR_SUSPECT,
    ROULETTE_ERROR_OUT_RANGE,
    ROULETTE_ERROR_NOT_ENOUGHT_BONUSES,
    ROULETTE_ERROR_NOT_ENOUGHT_LUCKY_COINS
}

function RouletteFrameMixin:ASMSG_LOTTERY_CLOSE( msg )
    local errorMsg  = E_LOTTERY_CLOSE_ERRORS[tonumber(msg)]
    local color     = RED_FONT_COLOR

    if errorMsg then
        UIErrorsFrame:AddMessage(errorMsg, color.r, color.g, color.b)
    end

    if self:IsShown() then
        HideUIPanel(self)
    end
end

enum:E_LOTTERY_LOTTERY_REWARD {
    "ENTRY",
    "MIN",
    "ISJACKPOT"
}

enum:E_LOTTERY_REWARDS_LIST {
    "ENTRY",
    "MIN",
    "MAX",
    "ISJACKPOT",
    "QUALITY"
}

function RouletteFrameMixin:ASMSG_LOTTERY_REWARD(msg)
    local rewardData = C_Split(msg, ":")

    if rewardData and #rewardData == 3 then
        self.winnerRewardData = {
            itemEntry      = tonumber(rewardData[E_LOTTERY_LOTTERY_REWARD.ENTRY]),
            itemCountMin   = tonumber(rewardData[E_LOTTERY_LOTTERY_REWARD.MIN]),
            isJackpot      = tonumber(rewardData[E_LOTTERY_LOTTERY_REWARD.ISJACKPOT]) ~= 0,
            quality        = Custom_RouletteFrame.rewardDataAssociate[msg] and Custom_RouletteFrame.rewardDataAssociate[msg].quality or 1
        }

        if self:IsShown() then
            self:Start()
        end
    end
end

function RouletteFrameMixin:ASMSG_LOTTERY_REWARDS_LIST(msg)
    local splitData = C_Split(msg, "|")
    local buffer    = {}

    for _, data in pairs(splitData) do
        local rewardData = C_Split(data, ",")
        local itemEntry  = rewardData[E_LOTTERY_REWARDS_LIST.ENTRY]

        C_Item:RequestServerCache(itemEntry)

        table.insert(buffer, {
            itemEntry      = tonumber(itemEntry),
            itemCountMin   = tonumber(rewardData[E_LOTTERY_REWARDS_LIST.MIN]),
            itemCountMax   = tonumber(rewardData[E_LOTTERY_REWARDS_LIST.MAX]),
            isJackpot      = tonumber(rewardData[E_LOTTERY_REWARDS_LIST.ISJACKPOT]) ~= 0,
            quality        = tonumber(rewardData[E_LOTTERY_REWARDS_LIST.QUALITY]),
        })
    end

    table.sort(buffer, function(a, b)
        return a.quality < b.quality
    end)

    C_CacheInstance:Set("ASMSG_LOTTERY_REWARDS_LIST", buffer)

    self:Initialize()
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
        local function ItemInfoResponceCallback( itemName, itemLink, _, _, _, _, _, _, _, itemTexture )
            self.itemLink = itemLink

            self.OverlayFrame.ChildFrame.ItemName:SetText(itemName)
            SetPortraitToTexture(self.OverlayFrame.ChildFrame.Icon, itemTexture)
        end

        self:SetQuality(itemInfo.quality)

        if itemInfo.itemEntry == -1 or itemInfo.itemEntry == -2 then
            local function UpdateFaction()
                local unitFaction   = UnitFactionGroup("player")

                if itemInfo.itemEntry == -1 then
                    SetPortraitToTexture(self.OverlayFrame.ChildFrame.Icon, "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction)
                else
                    SetPortraitToTexture(self.OverlayFrame.ChildFrame.Icon, "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction)
                end
            end

            C_FactionManager:RegisterFactionOverrideCallback(UpdateFaction, true)

            self.itemLink       = nil
            self.tooltipHeader  = itemInfo.itemEntry == -1 and HONOR_POINTS or ARENA_POINTS
            self.tooltipText    = itemInfo.itemEntry == -1 and TOOLTIP_HONOR_POINTS or TOOLTIP_ARENA_POINTS

            self.OverlayFrame.ChildFrame.ItemName:SetText(itemInfo.itemEntry == -1 and HONOR_POINTS or ARENA_POINTS)
        else
            local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemInfo.itemEntry, false, ItemInfoResponceCallback)

            if itemName then
                ItemInfoResponceCallback(itemName, itemLink, _, _, _, _, _, _, _, itemTexture)
            else
                ItemInfoResponceCallback("loading..", "Hitem:1", _, _, _, _, _, _, _, "Interface\\ICONS\\INV_Misc_QuestionMark")
            end
        end

        self:SetJackpot(itemInfo.isJackpot)

        if itemInfo.itemCountMax then
            if itemInfo.itemCountMin == itemInfo.itemCountMax then
                self.OverlayFrame.ChildFrame.ItemCount:SetText(itemInfo.itemCountMin)
            else
                self.OverlayFrame.ChildFrame.ItemCount:SetText(itemInfo.itemCountMin.. " - " ..itemInfo.itemCountMax)
            end
        else
            self.OverlayFrame.ChildFrame.ItemCount:SetText(itemInfo.itemCountMin)
        end

        self.OverlayFrame.ChildFrame.ItemCount:SetShown(itemInfo.itemCountMin and itemInfo.itemCountMin > 1)
    end
end