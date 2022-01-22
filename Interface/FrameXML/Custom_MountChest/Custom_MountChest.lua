--	Filename:	Custom_MountChest.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

UIPanelWindows["Custom_MountChestFrame"] = { area = "center",	pushable = 0,	whileDead = 1 }

MountChestFrameMixin = {}

function MountChestFrameMixin:OnLoad()
    self:RegisterEventListener()

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

    self.cards          = {}
    self.cardsMarging   = 6
    self.cardsWidth     = 90
    self.cardsHeight    = 100
    self.cardsCountW    = 6
    self.cardsCountH    = 5

    self.initialization = false

    ---- TEMP
    --self:SetShown(IsNyllClient())
    --
    --for i = 1, 30 do
    --    local mountData = COLLECTION_MOUNTDATA[math.random(#COLLECTION_MOUNTDATA)]
    --    table.insert(LOTTERY_MOUNT_CHEST, {mountData.spellID, mountData.creatureID})
    --end
end

---@param pieceName string
---@return table pieceObject
function MountChestFrameMixin:GetNineSlicePiece( pieceName )
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

enum:E_LOTTERY_MOUNT_CHEST {
    "ITEM_ID",
    "SPELL_ID",
    "CREATURE_ID"
}

function MountChestFrameMixin:Reset()
    local disabledCards = C_CacheInstance:Get("ASMSG_LOTTERY_MOUNT_CHEST_INFO", {})

    for y = self.cardsCountH, 1, -1 do
        for x = 1, self.cardsCountW do
            local px = (x - self.cardsCountW / 2 - 0.5) * (self.cardsWidth + self.cardsMarging)
            local py = (y - self.cardsCountH / 2 - 0.40) * (self.cardsHeight + self.cardsMarging)
            local pi = x + (self.cardsCountH - y) * self.cardsCountW

            self.cards[pi] = self.cards[pi] or CreateFrame("Button", "MountChestCard"..pi, self, "Custom_MountChestCardTemplate")
            self.cards[pi]:SetSize(self.cardsWidth, self.cardsHeight)

            self.cards[pi]:SetPoint("CENTER", px, py)

            self.cards[pi].WinnerLight:Hide()
            self.cards[pi].WinnerLight2:Hide()
            self.cards[pi].NameArtFrame:Hide()

            self.cards[pi].isWinner = false

            self.cards[pi].ArtFrame.Border:SetVertexColor(1, 1, 1)

            local mountData = LOTTERY_MOUNT_CHEST[pi]

            if mountData then
                local spellName = GetSpellInfo(mountData[E_LOTTERY_MOUNT_CHEST.SPELL_ID])
                self.cards[pi].Model:SetCreature(mountData[E_LOTTERY_MOUNT_CHEST.CREATURE_ID])
                self.cards[pi].NameFrame.Name:SetText(spellName)
                self.cards[pi].NameArtFrame.Name:SetText(spellName)
            end

            self.cards[pi]:SetDisabledCard(disabledCards[pi])

            self.cards[pi].HideDisabledCard:Stop()
            self.cards[pi].ArtFrame.HideDisabledCard:Stop()
            self.cards[pi].ArtFrame.BorderGlow:Hide()
            self.cards[pi].ArtFrame.BorderGlow.Glow:Stop()
            self.cards[pi].HideCard:Stop()
            self.cards[pi].CrestSparks.Anim:Stop()
            self.cards[pi].CrestSparks2.Anim:Stop()
            self.cards[pi].WinnerLight:Hide()
            self.cards[pi].WinnerLight.Anim:Stop()
            self.cards[pi].WinnerLight2:Hide()
            self.cards[pi].WinnerLight2.Anim:Stop()
            self.cards[pi].NameArtFrame:Hide()
            self.cards[pi].NameArtFrame.Anim:Stop()

            self.cards[pi].elapsed = 0

            self.cards[pi]:SetFrameLevel(30)
            self.cards[pi]:SetShown(mountData)
        end
    end

    self.animationStage = 0
    self.cardsBuffer    = {}

    self.TakeButton:SetEnabled(tCount(disabledCards) < tCount(LOTTERY_MOUNT_CHEST))
    self.TakeButton.Text:SetText(MOUNT_CHEST_TAKE_LABEL)
    self.TakeButton.isCloseButton = false
end

---@param animationStage number
function MountChestFrameMixin:SetAnimationStage( animationStage )
    if animationStage == 1 and self.animationStage ~= animationStage then
        for index, card in pairs(self.cards) do
            if not card.isDisabled and index ~= self:GetWinnerID() then
                table.insert(self.cardsBuffer, card)
            elseif index ~= self:GetWinnerID() then
                card.HideDisabledCard:Play()
                card.ArtFrame.HideDisabledCard:Play()
            end
        end

        self.animationStage = animationStage

        if #self.cardsBuffer == 0 then
            self:SetAnimationStage(4)
        else
            if #self.cardsBuffer >= (#self.cards - 1) then
                self:SetAnimationStage(2)
            end
        end
    elseif animationStage == 2 and self.animationStage ~= animationStage then
        for _, card in pairs(self.cardsBuffer) do
            card.ArtFrame.BorderGlow:Show()
            card.ArtFrame.BorderGlow.Glow:Play()
        end

        self.animationStage = animationStage
    elseif animationStage == 3 and self.animationStage ~= animationStage then
        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end

        self.timer = C_Timer:NewTicker(0.2, function()
            local card = table.remove(self.cardsBuffer, math.random(1, #self.cardsBuffer))
            card.HideCard:Play()

            if #self.cardsBuffer == 0 then
                self:SetAnimationStage(4)
            end
        end, #self.cardsBuffer)

        self.animationStage = animationStage
    elseif animationStage == 4 and self.animationStage ~= animationStage then
        if not self:GetWinnerID() then
            return
        end

        local card = self.cards[self:GetWinnerID()]
        local _, _, _, xOffset, yOffset = card:GetPoint()

        card.winnerXOffset  = xOffset
        card.winnerYOffset  = yOffset

        card.isWinner       = true

        self.animationStage = animationStage
    end
end

---@param index number
function MountChestFrameMixin:SetWinnerID( index )
    self.serverWinnerID = tonumber(index)
end

---@return number serverWinnerID
function MountChestFrameMixin:GetWinnerID()
    return self.serverWinnerID
end

CustomMountChestCardMixin = {}

function CustomMountChestCardMixin:OnLoad()
    self.sizeChangeW = 31
    self.sizeChangeH = 35

    self.elapsed     = 0

    self.ArtFrame.Border:SetAtlas("Roulette-item-frame")
    self.ArtFrame.BorderGlow:SetAtlas("Roulette-item-frame")

    self.CrestSparks:SetAtlas("Artifacts-Anim-Sparks", true)
    self.CrestSparks2:SetAtlas("Artifacts-Anim-Sparks", true)

    self.WinnerLight:SetAtlas("Roulette-item-jackpot-light-center")
    self.WinnerLight2:SetAtlas("Roulette-item-jackpot-light-center")

    self.WinnerLight:SetVertexColor(1, 0.50196, 0)
    self.WinnerLight2:SetVertexColor(1, 0.50196, 0)

    self.CrestSparks:SetVertexColor(1, 0.50196, 0)
    self.CrestSparks2:SetVertexColor(1, 0.50196, 0)

    self:SetParentArray("cards")
end

---@param elapsed number
function CustomMountChestCardMixin:OnUpdate( elapsed )
    if self:GetParent().animationStage == 4 and self.winnerXOffset and self.winnerYOffset then
        local xOffset       = C_inOutSine(self.elapsed, self.winnerXOffset, 0, 0.500)
        local yOffset       = C_inOutSine(self.elapsed, self.winnerYOffset, 0, 0.500)
        local sizeOffset    = C_inOutSine(self.elapsed, 0, 200, 0.500)

        local colorG        = C_inOutSine(self.elapsed, 1, 0.50196, 0.500)
        local colorB        = C_inOutSine(self.elapsed, 1, 0, 0.500)

        self.ArtFrame.Border:SetVertexColor(1, colorG, colorB)

        self:SetPoint("CENTER", xOffset, yOffset)
        self:SetSize(90 * (1 + sizeOffset / 100), 100 * (1 + sizeOffset / 100))

        self.elapsed = self.elapsed + elapsed

        if self.elapsed >= 0.500 then
            self:SetPoint("CENTER", 0, 0)

            self.CrestSparks.Anim:Play()
            self.CrestSparks2.Anim:Play()

            self.WinnerLight:Show()
            self.WinnerLight.Anim:Play()

            self.WinnerLight2:Show()
            self.WinnerLight2.Anim:Play()

            self.NameArtFrame:Show()
            self.NameArtFrame.Anim:Play()

            SendServerMessage("ACMSG_LOTTERY_MOUNT_CHEST_REWARD")

            self:GetParent().TakeButton:Enable()
            self:GetParent().TakeButton.Text:SetText(CLOSE)
            self:GetParent().TakeButton.isCloseButton = true

            self.elapsed = 0
            self:GetParent().animationStage = 0
        end
    end
end

function CustomMountChestCardMixin:OnEnter()
    if self.isWinner then
        return
    end

    self:SizeUp()
    self:FrameLevelUp()

    self.NameFrame:Show()
end

function CustomMountChestCardMixin:OnLeave()
    if self.isWinner then
        return
    end

    self:SizeDopwn()
    self:FrameLevelDown()

    self.NameFrame:Hide()
end

function CustomMountChestCardMixin:SizeUp()
    local w, h = self:GetSize()
    self:SetSize(w + self.sizeChangeW, h + self.sizeChangeH)
end

function CustomMountChestCardMixin:SizeDopwn()
    local w, h = self:GetSize()
    self:SetSize(w - self.sizeChangeW, h - self.sizeChangeH)
end

function CustomMountChestCardMixin:FrameLevelUp()
    self:SetFrameLevel(self:GetFrameLevel() + 10)
end

function CustomMountChestCardMixin:FrameLevelDown()
    self:SetFrameLevel(self:GetFrameLevel() - 10)
end

---@param isDisabled boolean
function CustomMountChestCardMixin:SetDisabledCard( isDisabled )
    self.isDisabled = isDisabled

    self.Background:SetDesaturated(isDisabled)
    self.ArtFrame.Border:SetDesaturated(isDisabled)

    self.Model:SetAlpha(isDisabled and 0.5 or 1)

    self.DisableFrame:SetShown(isDisabled)

    self:SetEnabled(not isDisabled)
end

function MountChestFrameMixin:ASMSG_LOTTERY_MOUNT_CHEST_INFO( msg )
    local disableCards = C_Split(msg, ",")

    local buffer = {}

    for _, cards in pairs(disableCards) do
        buffer[tonumber(cards)] = true
    end

    C_CacheInstance:Set("ASMSG_LOTTERY_MOUNT_CHEST_INFO", buffer)

    if not self:IsShown() then
        ShowUIPanel(self)
    end

    self:Reset()
end

function MountChestFrameMixin:ASMSG_LTTERY_MOUNT_CHEST_RESULT( msg )
    if not self:IsShown() then
        ShowUIPanel(self)
    end

    self:SetWinnerID(msg)
    self:SetAnimationStage(1)
end