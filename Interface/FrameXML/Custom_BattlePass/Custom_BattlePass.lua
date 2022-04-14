--	Filename:	Custom_BattlePass.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

enum:E_BATTLEPASS_REWARD_FLAGS {
    ["ONLY_ALLIANCE"]   = 1,
    ["ONLY_HORDE"]      = 2,
    ["ONLY_RENEGADE"]   = 4,
}

enum:E_BATTLEPASS_LEVEL_REWARDS {
    "TYPE",
    "ITEMENTRY",
    "ITEMCOUNT",
    "FLAGS"
}

enum:E_BATTLEPASS_REWARD_TYPE {
    [0] = "NORMAL",
    [1] = "PREMIUM"
}

enum:E_BATTLEPASS_INFO {
    "CURRENT_XP",
    "IS_PREMIUM",
    "DAY_XP",
    "END_TIME"
}

enum:E_BATTLEPASS_INFO_REWARD {
    "LEVEL",
    "TYPE"
}

enum:E_BATTLEPASS_SETTINGS {
    "DAY_AMOUNT",
    "POINTS_BG",
    "POINTS_ARENA",
}

BattlePassFrameMixin = {}

function BattlePassFrameMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()

    self.cards = { }
    self.maxCard = 6
    self.currentPage = 0
    self.newXP = 0

    self.Background:SetAtlas("BattlePass-Background")
    self.Border:SetAtlas("BattlePass-Background-Border")

    self.levelFramePool = CreateFramePool("FRAME", self, "BattlePassLevelFrameTemplate")

    self:CreateLevelCards()
end

function BattlePassFrameMixin:OnShow()
    if self.tutorial then
        NPE_TutorialPointerFrame:Hide(self.Tutorial)
        self.tutorial = nil
    end

    if not NPE_TutorialPointerFrame:GetKey("BattlePassTutorial_1") then
        self.tutorial = NPE_TutorialPointerFrame:Show(BATTLEPASS_TUTORIAL_1, "LEFT", self.TitleLeftFrame.TutorialButton, 0, 0)
    end

    local screenResolutions = {GetScreenResolutions()}

    if screenResolutions then
        local currentResolution = screenResolutions[GetCurrentResolution()]
        local resolution = C_Split(currentResolution, "x")

        local width = tonumber(resolution[1])
        local height = tonumber(resolution[2])

        if width / height > 4 / 3 then
            if width < 1600 then
                self:SetScale(0.9)
            else
                self:SetScale(1)
            end
        else
            self:SetScale(0.7)
        end
    end

    local currentLevel = self:GetLevelInfo()
    for page = 0, self:GetPageCount() do
        for index = 1, self.maxCard do
            local level = index + (self.maxCard - 1) * page

            local premiumCardData, normalCardData = self:GetCardLevelReward(level)
            local isRewardTakenPremium = self:IsRewardTaken(level, E_BATTLEPASS_REWARD_TYPE.PREMIUM)
            local isRewardTakenNormal = self:IsRewardTaken(level, E_BATTLEPASS_REWARD_TYPE.NORMAL)

            if currentLevel >= level and self.currentPage == 0 then
                if #premiumCardData > 0 then
                    if not isRewardTakenPremium and self:IsBuyPremium() then
                        self.currentPage = page + 1
                        break
                    end
                end
                if #normalCardData > 0 then
                    if not isRewardTakenNormal then
                        self.currentPage = page + 1
                        break
                    end
                end
            end
        end
    end

    if self.currentPage == 0 then
        self.currentPage = math.ceil(currentLevel / 5) + (currentLevel % 5 == 0 and 1 or 0)
    end

    self:UpdateLevelCards()

    self.PageFrame:UpdatePages()
    self.InfoRightFrame:UpdateInfo()
    self.InfoRightFrame.DualButtonFrame:UpdateInfo()
    self.TitleLeftFrame:UpdateInfo()

    StoreRequestBattlePass()
end

function BattlePassFrameMixin:OnHide()
    if self.tutorial then
        NPE_TutorialPointerFrame:Hide(self.tutorial)
        self.tutorial = nil
    end

    self.currentPage = 0
end

StaticPopupDialogs["BATTLEPASS_BUY_USE_CONFIRM"] = {
    text = BATTLEPASS_BUY_USE_CONFIRM,
    button1 = YES,
    button2 = NO,
    OnAccept = function (self)
        for i = 1, self.data.count do
            for containerID = 0, NUM_BAG_FRAMES do
                for slotID = 1, GetContainerNumSlots(containerID) do
                    if self.data.foundItem == GetContainerItemID(containerID, slotID) then
                        UseContainerItem(containerID, slotID)
                    end
                end
            end
        end

        --UseContainerItem(self.data.containerID, self.data.slotID)
    end,
    OnCancel = function () end,
    hideOnEscape = 1,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
}

function BattlePassFrameMixin:CHAT_MSG_LOOT(_, text)
    if not self:IsShown() then
        return
    end

    local itemEntry, count = string.match(text, "|Hitem:(%d+).*x(%d+)")
    if not count then
        itemEntry, count = string.match(text, "|Hitem:(%d+)"), 1
    end

    local foundItem

    itemEntry = tonumber(itemEntry)

    for category = 1, 2 do
        for _, data in pairs(STORE_PRODUCT_CACHE[1][101][category][0].data) do
            if itemEntry == data[2] then
                foundItem = itemEntry
                break
            end
        end
    end


    if foundItem then
        C_Timer:After(0.1, function()
            local dialog = StaticPopup_Show("BATTLEPASS_BUY_USE_CONFIRM", text)

            dialog.data = {
                foundItem = foundItem,
                count = count
            }
        end)
    end
end

function BattlePassFrameMixin:OnKeyDown( key )
    if key == "ESCAPE" then
        self:Hide()
        self.BuyOverlayFrame:Hide()
    elseif key == "PRINTSCREEN" then
        Screenshot()
    end
end

function BattlePassFrameMixin:OnMouseWheel( delta )
    local currentPage   = self:GetCurrentPage()
    local maxPage       = self:GetPageCount()

    if delta == -1 then
        if currentPage < maxPage then
            self.PageFrame.NextPageButton:Click()
        end
    else
        if currentPage > 1 then
            self.PageFrame.BackPageButton:Click()
        end
    end
end

local function ExpToLevel( exp )
    local level = 0

    for i = 1, #BATTLEPASS_LEVELS - 1 do
        local xpMax = BATTLEPASS_LEVELS[i]

        if exp < xpMax then
            local _level = math.modf(level)
            return _level
        end
        level = level + 1
    end

    if (#BATTLEPASS_LEVELS - 1) == level then
        local remainExp = exp - BATTLEPASS_LEVELS[level]
        local overcapLevels = remainExp / BATTLEPASS_LEVELS[level + 1]

        level = level + overcapLevels
    end

    local _level = math.modf(level)
    return _level
end

local function ExpForLevel( level )
    local exp = 0
    local lastLevel = (#BATTLEPASS_LEVELS - 1)

    if level >= lastLevel then
        exp = BATTLEPASS_LEVELS[lastLevel]
        local remainingLevels = level - lastLevel
        exp = exp + BATTLEPASS_LEVELS[lastLevel + 1] * remainingLevels
    else
        exp = BATTLEPASS_LEVELS[level]
    end

    return exp
end

function BattlePassFrameMixin:HasNotReceivedRewards()
    local currentLevel = self:GetLevelInfo();
    local isBuyPremium = self:IsBuyPremium();

    if currentLevel == 0 then
        return false;
    end

    local foundCurLevel;
    for page = 0, self:GetPageCount() do
        for index = 1, self.maxCard do
            local level = index + (self.maxCard - 1) * page;
            local premiumCardData, normalCardData = self:GetCardLevelReward(level);

            if isBuyPremium and #premiumCardData > 0 and not self:IsRewardTaken(level, E_BATTLEPASS_REWARD_TYPE.PREMIUM) then
                return true;
            end

            if #normalCardData > 0 and not self:IsRewardTaken(level, E_BATTLEPASS_REWARD_TYPE.NORMAL) then
                return true;
            end

            if currentLevel == level then
                foundCurLevel = true;
                break;
            end
        end

        if foundCurLevel then
            break;
        end
    end

    return false;
end

function BattlePassFrameMixin:GetLevelInfoByXP( xp )
    local level = ExpToLevel( xp )

    if level == 0 then
        return 0, ExpForLevel(level + 1), xp
    end

    local curMax = ExpForLevel( level )
    local xpMax = ExpForLevel( level + 1) - curMax
    local curXP = xp - curMax

    return level, xpMax, curXP
end

function BattlePassFrameMixin:GetLevelCount()
    return #BATTLEPASS_LEVEL_REWARDS
end

function BattlePassFrameMixin:GetPageCount()
    local page = #BATTLEPASS_LEVEL_REWARDS / (self.maxCard - 1)
    local level = self:GetLevelInfo()

    if level >= #BATTLEPASS_LEVEL_REWARDS then
        page = page + ((level - #BATTLEPASS_LEVEL_REWARDS) / (self.maxCard - 1))
    end

    return page
end

function BattlePassFrameMixin:GetCurrentPage()
    return self.currentPage
end

local function ItemValidation( itemData )
    local factionTag    = UnitFactionGroup("player")
    local flags         = itemData[E_BATTLEPASS_LEVEL_REWARDS.FLAGS]

    if flags == 0 then
        return true
    end

    if bit.band(itemData[E_BATTLEPASS_LEVEL_REWARDS.FLAGS], E_BATTLEPASS_REWARD_FLAGS["ONLY_"..string.upper(factionTag)]) ~= 0 then
        return true
    end

    return false
end

function BattlePassFrameMixin:GetCardLevelReward( level )
    local data = BATTLEPASS_LEVEL_REWARDS[level] or BATTLEPASS_LEVEL_REWARDS[#BATTLEPASS_LEVEL_REWARDS]
    local premiumStorage = {}
    local normalStorage = {}

    if data then
        for _, itemData in pairs(data) do
            if ItemValidation(itemData) then
                if itemData[E_BATTLEPASS_LEVEL_REWARDS.TYPE] == E_BATTLEPASS_REWARD_TYPE.PREMIUM then
                    table.insert(premiumStorage, {
                        itemEntry = itemData[E_BATTLEPASS_LEVEL_REWARDS.ITEMENTRY],
                        itemCount = itemData[E_BATTLEPASS_LEVEL_REWARDS.ITEMCOUNT],
                    })
                else
                    table.insert(normalStorage, {
                        itemEntry = itemData[E_BATTLEPASS_LEVEL_REWARDS.ITEMENTRY],
                        itemCount = itemData[E_BATTLEPASS_LEVEL_REWARDS.ITEMCOUNT],
                    })
                end
            end
        end
    end

    return premiumStorage, normalStorage
end

function BattlePassFrameMixin:GetHighLevelCardReward()
    return self:GetCardLevelReward(self:GetLevelCount() - 1)
end

function BattlePassFrameMixin:CreateLevelCards()
    for i = 1, self.maxCard do
        local frame = self.levelFramePool:Acquire()
        self.cards[#self.cards + 1] = frame

        frame:SetPoint("CENTER", 0, 0)

        frame:Show()
        frame.index = i

        frame.PremiumCard:SetActive(false)
        frame.NormalCard:SetActive(false)
    end
end



function BattlePassFrameMixin:UpdateLevelCards()
    local currentLevel = self:GetLevelInfo()
    local activeCardCount = 0
    local buffer = {}

    for frame in self.levelFramePool:EnumerateActive() do
        frame.level = frame.index + (self.maxCard - 1) * (self:GetCurrentPage() - 1)

        frame.NormalCard.forceDisable = nil

        local isHighLevelCard = false

        if frame.level == self:GetLevelCount() - 1 then
            isHighLevelCard = true
        elseif frame.level ~= self:GetLevelCount() then
            isHighLevelCard = frame.index == self.maxCard and frame.level <= self:GetLevelCount()
        end

        frame.PremiumCard.level = frame.level
        frame.NormalCard.level = frame.level

        frame.PremiumCard:SetHighLevelCard(isHighLevelCard)
        frame.NormalCard:SetHighLevelCard(isHighLevelCard)

        if frame.PremiumCard:IsHighLevelCard() then
            local premiumCardData, normalCardData = self:GetHighLevelCardReward()

            frame.PremiumCard:SetRewards(premiumCardData)
            frame.NormalCard:SetRewards(normalCardData)
        else
            local premiumCardData, normalCardData = self:GetCardLevelReward(frame.level)

            frame.PremiumCard:SetRewards(premiumCardData)
            frame.NormalCard:SetRewards(normalCardData)

            frame.NormalCard.forceDisable = #normalCardData == 0
        end

        local isRewardTakenPremium = self:IsRewardTaken(frame.level, E_BATTLEPASS_REWARD_TYPE.PREMIUM)
        local isRewardTakenNormal = self:IsRewardTaken(frame.level, E_BATTLEPASS_REWARD_TYPE.NORMAL)

        if currentLevel >= frame.level then
            local isPremiumActive = self:IsBuyPremium() and frame.PremiumCard:GetRewardCount() > 0 and not isRewardTakenPremium
            local isNormalActive = frame.NormalCard:GetRewardCount() > 0 and not isRewardTakenNormal

            if frame.PremiumCard:IsHighLevelCard() then
                if currentLevel >= self:GetLevelCount() - 1 then
                    local _isRewardTakenPremium = self:IsRewardTaken(self:GetLevelCount() - 1, E_BATTLEPASS_REWARD_TYPE.PREMIUM)
                    local _isRewardTakenNormal = self:IsRewardTaken(self:GetLevelCount() - 1, E_BATTLEPASS_REWARD_TYPE.NORMAL)

                    local _isPremiumActive = self:IsBuyPremium() and frame.PremiumCard:GetRewardCount() > 0 and not _isRewardTakenPremium
                    local _isNormalActive = frame.NormalCard:GetRewardCount() > 0 and not _isRewardTakenNormal

                    frame.PremiumCard:SetActive(_isPremiumActive)
                    frame.NormalCard:SetActive(_isNormalActive)
                else
                    frame.PremiumCard:SetActive(false)
                    frame.NormalCard:SetActive(false)
                end
            else
                frame.PremiumCard:SetActive(isPremiumActive)
                frame.NormalCard:SetActive(isNormalActive)
            end
        else
            frame.PremiumCard:SetActive(false)
            frame.NormalCard:SetActive(false)
        end

        frame.RequiredLevel:SetLevel(frame.level, (frame.NormalCard:IsActive() or frame.PremiumCard:IsActive()))

        if self:IsBuyPremium() then
            if isHighLevelCard then
                frame.PremiumCard:SetComplete(isRewardTakenPremium and frame.level == self:GetLevelCount() - 1)
            else
                frame.PremiumCard:SetComplete(isRewardTakenPremium)
            end
        else
            frame.PremiumCard:SetDisable(true)
        end

        if frame.NormalCard.forceDisable then
            frame.NormalCard:SetDisable(true, true)
        else
            if isHighLevelCard then
                frame.NormalCard:SetComplete(isRewardTakenNormal and frame.level == self:GetLevelCount() - 1)
            else
                frame.NormalCard:SetComplete(isRewardTakenNormal)
            end
        end

        frame:Show()

        if frame.level then
            activeCardCount = activeCardCount + 1
            buffer[frame.index] = frame
        end
    end

    local size      = (200 / 2) * activeCardCount
    local offset    = 0

    for _, frame in pairs(buffer) do
        local xOffset = -size + 200 * offset + 100
        frame:ClearAndSetPoint("CENTER", xOffset, -12)

        offset = offset + 1
    end
end

function BattlePassFrameMixin:PrevPage()
    self.currentPage = self.currentPage - 1

    self:UpdateLevelCards()
end

function BattlePassFrameMixin:NextPage()
    self.currentPage = self.currentPage + 1

    self:UpdateLevelCards()
end

function BattlePassFrameMixin:GetLevelXP()
    return C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).levelXP or 0
end

function BattlePassFrameMixin:GetTotalXP()
    return C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).totalXP or 0
end

function BattlePassFrameMixin:IsBuyPremium()
    local isPremium = C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).isPremium
    return isPremium and isPremium == 1
end

function BattlePassFrameMixin:GetCapXP()
    return C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).dayXP or 0
end

function BattlePassFrameMixin:GetTakeRewardData()
    return C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).rewardData or {}
end

function BattlePassFrameMixin:GetEndTime()
    return C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).endTime or 0
end

function BattlePassFrameMixin:IsRewardTaken( level, cardType )
    for _, rewardData in ipairs(self:GetTakeRewardData()) do
        if rewardData.level == level and rewardData.cardType == cardType then
            return true
        end
    end
end

local function CalculateLevelXP( totalXP )
    local _, _, lvlXP = BattlePassFrame:GetLevelInfoByXP(totalXP)
    return lvlXP
end

function BattlePassFrameMixin:GetLevelInfo()
    local totalXP = self:GetTotalXP()
    local level, maxXP, lvlXP = self:GetLevelInfoByXP(totalXP)

    return level, lvlXP, totalXP, maxXP
end

function BattlePassFrameMixin:ASMSG_BATTLEPASS_EXP( msg )
    local infoData  = C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO")
    local xpData = C_Split(msg, ":")

    local newXP     = tonumber(xpData[1])
    local capXP     = tonumber(xpData[2])

    if infoData then
        infoData.totalXP    = infoData.totalXP + newXP
        infoData.dayXP      = capXP
        infoData.levelXP    = CalculateLevelXP(infoData.totalXP)

	    PVPQueueFrame.BattlePassToggleButton.LevelFrame.Level:SetText(ExpToLevel(infoData.totalXP))
    end

    self.newXP = self.newXP + newXP

    self.InfoRightFrame:UpdateInfo(self:IsShown())
    self:UpdateLevelCards()
end

function BattlePassFrameMixin:ASMSG_BATTLEPASS_INFO( msg )
    local infoStorage       = C_Split(msg, ":")

    local totalXP = tonumber(infoStorage[E_BATTLEPASS_INFO.CURRENT_XP])

    C_CacheInstance:Set("ASMSG_BATTLEPASS_INFO", {
        totalXP     = totalXP,
        levelXP     = CalculateLevelXP(totalXP),
        isPremium   = tonumber(infoStorage[E_BATTLEPASS_INFO.IS_PREMIUM]),
        dayXP       = tonumber(infoStorage[E_BATTLEPASS_INFO.DAY_XP]),
        endTime     = tonumber(infoStorage[E_BATTLEPASS_INFO.END_TIME]),
        rewardData  = {}
    })

    self.InfoRightFrame:UpdateInfo(self:IsShown())
    self.TitleLeftFrame:UpdateInfo()
    self:UpdateLevelCards()
    self.InfoRightFrame.DualButtonFrame:UpdateInfo()

    PVPQueueFrame.BattlePassToggleButton:Enable()
end

function BattlePassFrameMixin:ASMSG_BATTLEPASS_REWARDS_INFO( msg )
    local rewards = C_Split(msg, ";");

    local rewardData = C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).rewardData;

    if rewardData then
        for _, reward in ipairs(rewards) do
            local rewardInfo = C_Split(reward, ":");

            rewardData[#rewardData + 1] = {
                level       = tonumber(rewardInfo[E_BATTLEPASS_INFO_REWARD.LEVEL]),
                cardType    = tonumber(rewardInfo[E_BATTLEPASS_INFO_REWARD.TYPE])
            };
        end
    end

    self:UpdateLevelCards();
end

function BattlePassFrameMixin:ASMSG_BATTLEPASS_TAKE_REWARD( msg )
    local rewardData = C_CacheInstance:Get("ASMSG_BATTLEPASS_INFO", {}).rewardData

    if rewardData then
        local rewardInfo = C_Split(msg, ":")

        rewardData[#rewardData + 1] = {
            level       = tonumber(rewardInfo[E_BATTLEPASS_INFO_REWARD.LEVEL]),
            cardType    = tonumber(rewardInfo[E_BATTLEPASS_INFO_REWARD.TYPE])
        }
    end

    self:UpdateLevelCards()
end

function BattlePassFrameMixin:ASMSG_BATTLEPASS_SETTINGS( msg )
    local infoStorage       = C_Split(msg, ":")

    C_CacheInstance:Set("ASMSG_BATTLEPASS_SETTINGS", {
        dayAmount   	  = tonumber(infoStorage[E_BATTLEPASS_SETTINGS.DAY_AMOUNT]),
        totalAmount   	  = tonumber(infoStorage[E_BATTLEPASS_SETTINGS.DAY_AMOUNT]) * 3,
        pointsBG   		  = tonumber(infoStorage[E_BATTLEPASS_SETTINGS.POINTS_BG]),
        pointsArena   	  = tonumber(infoStorage[E_BATTLEPASS_SETTINGS.POINTS_ARENA]),
        pointsArena1vs1   = tonumber(infoStorage[E_BATTLEPASS_SETTINGS.POINTS_ARENA]) / 5,
    })
end

BattlePassTitleFrameTemplateMixin = {}

function BattlePassTitleFrameTemplateMixin:OnLoad()
    self.mainFrame = BattlePassFrame

    self.TitleTexture:SetAtlas("BattlePass-Title-ruRU")
    self.ShieldAndSwordTexture:SetAtlas("BattlePass-Title-Shield-And-Sword")
end

function BattlePassTitleFrameTemplateMixin:UpdateInfo()
    local endTime = self.mainFrame:GetEndTime()

    self.SeasonTimeLeft:SetFormattedText(BATTLEPASS_END_TIME, SecondsToTime(endTime, nil, 1))
end

BattlePassCardTemplateMixin = {}

function BattlePassCardTemplateMixin:OnLoad()
    self.cardType = self:GetAttribute("cardType")
    self.mainFrame = BattlePassFrame
    self.animData = {}
end

function BattlePassCardTemplateMixin:SetHighLevelCard( toggle )
    self.isHighLevelCard = toggle
    self:SetActive(false)

    self.Background:SetSize(218, 280)
end

function BattlePassCardTemplateMixin:IsHighLevelCard()
    return self.isHighLevelCard
end

function BattlePassCardTemplateMixin:IsActive()
    return self.isActive
end

function BattlePassCardTemplateMixin:SetActive( toggle )
    self.isActive = toggle

    if not self.isHighLevelCard then
        if toggle then
            self.Background:SetSize(218, 278)
        else
            self.Background:SetSize(200, 260)
        end
    end

    if self.isHighLevelCard then
        self.Background:SetAtlas("BattlePass-High-Level-Card-" .. self.cardType)
        self.Glow:SetAtlas("BattlePass-High-Level-Card-" .. self.cardType)
    else
        self.Background:SetAtlas("BattlePass-Card-" .. self.cardType .. (toggle and "-Highlight" or ""))
        self.Glow:SetAtlas("BattlePass-Card-" .. self.cardType .. (toggle and "-Highlight" or ""))
    end

    self.TakeRewardsButton:SetShown(toggle)

    if self.level and self.rewardCount and self.rewardCount > 0 and not self.animData[self.level] then
        local animPlayed

        if self.Glow.Anim:IsPlaying() then
            self.Glow.Anim:Stop()
        end

        if toggle then
            self.Glow.Anim:Play()
            animPlayed = true
        end

        self.animData[self.level] = animPlayed
    end
end

function BattlePassCardTemplateMixin:SetComplete( toggle )
    self.CompleteOverlay:SetShown(toggle)
    self.overlayAlpha = 1
    self.CompleteOverlay.Overlay:SetAlpha(self.overlayAlpha)
    self.CompleteOverlay.CheckMark:Show()
    self.CompleteOverlay.Lock:Hide()
    self.overlayToggle = toggle
    self.isComplete = toggle
end

function BattlePassCardTemplateMixin:SetDisable( toggle, isHideLock )
    self.CompleteOverlay:SetShown(toggle)
    self.overlayAlpha = isHideLock and 1 or 0.3
    self.CompleteOverlay.Overlay:SetAlpha(self.overlayAlpha)
    self.CompleteOverlay.CheckMark:Hide()
    self.CompleteOverlay.Lock:SetShown(not isHideLock)
    self.overlayToggle = toggle
    self.isHideLock = isHideLock
end

function BattlePassCardTemplateMixin:OnEnter()
    if not self.overlayToggle and not self.isHideLock then
        return
    end

    self.CompleteOverlay.BuyPremiumButton:SetShown(not self.isHideLock and self.cardType == "Premium" and not self.isComplete)
    --self.CompleteOverlay.Overlay:SetAlpha(1)
end

function BattlePassCardTemplateMixin:OnLeave(isForce)
    if not isForce then
        if not self.overlayToggle or (self.CompleteOverlay.BuyPremiumButton:IsMouseOver()) then
            return
        end
    end

    self.CompleteOverlay.BuyPremiumButton:Hide()
    self.CompleteOverlay.Overlay:SetAlpha(self.overlayAlpha or 0.3)
end

function BattlePassCardTemplateMixin:TakeRewards()
    SendServerMessage("ACMSG_BATTLEPASS_TAKE_REWARD", string.format("%s:%s", self:GetParent().level, self:GetID() == 1 and 0 or 1))
end

function BattlePassCardTemplateMixin:GetRewardCount()
    return self.rewardCount
end

function BattlePassCardTemplateMixin:SetRewards( items )
    for i = 1, #self.rewardButtons do
        local itemEntry = items[i] and items[i].itemEntry
        local itemCount = items[i] and items[i].itemCount
        local rewardButton = self.rewardButtons[i]

        rewardButton:SetItem(itemEntry or 0, itemCount or 0)
        rewardButton:SetShown(itemEntry)
    end

    local itemsCount = #items
    local offset = self.rewardButtons[1]:GetParent().cardType == "Premium" and 42 or 22
    local offset2 = self.rewardButtons[1]:GetParent().cardType == "Premium" and -22 or -42

    if itemsCount == 1 then
        self.rewardButtons[1]:ClearAndSetPoint("CENTER", 0, 0)
    elseif itemsCount == 2 then
        self.rewardButtons[1]:ClearAndSetPoint("CENTER", 0, offset)
        self.rewardButtons[2]:ClearAndSetPoint("CENTER", 0, offset2)
    elseif itemsCount == 3 then
        self.rewardButtons[1]:ClearAndSetPoint("CENTER", -32, offset)
        self.rewardButtons[2]:ClearAndSetPoint("CENTER", 32, offset)
        self.rewardButtons[3]:ClearAndSetPoint("CENTER", 0, offset2)
    end

    self.rewardCount = itemsCount
end

BattlePassItemTemplateMixin = {}

function BattlePassItemTemplateMixin:OnLoad()
    self:SetParentArray("rewardButtons")
end

function BattlePassItemTemplateMixin:OnClick()
    if self.itemEntry and IsModifiedClick() then
        local _, link = GetItemInfo(self.itemEntry)
	    if link then
		    HandleModifiedItemClick(link)
	    end
    end
end

function BattlePassItemTemplateMixin:OnShow()
    local cardType = self:GetParent().cardType

    if cardType then
        self.Border:SetAtlas("BattlePass-Item-Border-"..cardType)
        self:SetHighlightAtlas("BattlePass-Item-Border-"..cardType)
    end
end

function BattlePassItemTemplateMixin:OnEnter()
    self:GetParent():OnEnter()

    if self.itemEntry then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
        GameTooltip:SetHyperlink("Hitem:"..self.itemEntry)
        GameTooltip:Show()
    end
end

function BattlePassItemTemplateMixin:SetItem( itemEntry, count )
    local function ItemInfoResponceCallback( _, _, _, _, _, _, _, _, _, itemTexture )
        self.Icon:SetTexture(itemTexture)
    end

    local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemEntry, false, ItemInfoResponceCallback)

    if itemTexture then
        ItemInfoResponceCallback(_, _, _, _, _, _, _, _, _, itemTexture)
    else
        ItemInfoResponceCallback(_, _, _, _, _, _, _, _, _, "Interface\\ICONS\\INV_Misc_QuestionMark")
    end

    self.Count:SetShown(count > 1)
    self.Count:SetText(count)

    self.itemEntry = itemEntry
end

BattlePassDualButtonTemplateMixin = {}

function BattlePassDualButtonTemplateMixin:OnLoad()
    self.mainFrame = BattlePassFrame

    self.RightHighLight:SetAtlas("BattlePass-Dual-Button-Highlight-Premium")
    self.LeftHighLight:SetAtlas("BattlePass-Dual-Button-Highlight-Normal")
end

function BattlePassDualButtonTemplateMixin:UpdateInfo()
    if self.mainFrame:IsBuyPremium() then
        self.backgroundAtlas = "BattlePass-Dual-Button-Right-Disable"
        self.RightButton:Disable()
    else
        self.backgroundAtlas = "BattlePass-Dual-Button"
        self.RightButton:Enable()
    end

    self.Background:SetAtlas(self.backgroundAtlas)
end

function BattlePassDualButtonTemplateMixin:OnClick( buttonID )
    self.mainFrame.BuyOverlayFrame:ShowFrame(buttonID)
end

function BattlePassDualButtonTemplateMixin:OnMouseDown( buttonID )
    if self.RightButton:IsEnabled() == 0 and self.RightButton:GetID() == buttonID then
        return
    end

    if self.RightButton:IsEnabled() == 0 then
        self.Background:SetAtlas("BattlePass-Dual-Button-Down-Left-Right-Disable")
    else
        self.Background:SetAtlas("BattlePass-Dual-Button-Down-" .. (buttonID == 1 and "Left" or "Right"))
    end
end

function BattlePassDualButtonTemplateMixin:OnMouseUp( _ )
    self.Background:SetAtlas(self.backgroundAtlas)
end

BattlePassLevelProgressBarTemplateMixin = {}

function BattlePassLevelProgressBarTemplateMixin:OnLoad()
    self.mainFrame = BattlePassFrame

    self.Background:SetAtlas("BattlePass-ProgressBar-Overlay-Small")
    self.Progress:SetAtlas("BattlePass-ProgressBar-Small-1")
end

function BattlePassLevelProgressBarTemplateMixin:GetCurrentValue()
    return self.currentValue or 0
end

function BattlePassLevelProgressBarTemplateMixin:SetValue( currentValue, maxValue, capValue )
    local MAX_BAR = self:GetWidth() - 4
    local progress = math.min(MAX_BAR * currentValue / maxValue, MAX_BAR)

    self.Progress:SetWidth(progress + 1)

    if ( capValue + currentValue >= maxValue ) then
        capValue = maxValue - currentValue
    end

    local capWidth = MAX_BAR * capValue / maxValue
    if ( capWidth > 0 ) then
        self.CapProgress:SetWidth(capWidth)
        self.CapProgress:Show()
    else
        self.CapProgress:Hide()
    end

    if ( progress > MAX_BAR - 4 ) then
        self.Shadow:Hide()
    else
        self.Shadow:Show()
    end

    self.currentValue = currentValue

    self:GetParent().XP:SetFormattedText(BATTLEPASS_EXP, currentValue, maxValue)
end

function BattlePassLevelProgressBarTemplateMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    if self.mainFrame:GetLevelInfo() >= (#BATTLEPASS_LEVELS - 1) then
        GameTooltip:SetText(BATTLEPASS_MAX_LEVEL_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine(BATTLEPASS_MAX_LEVEL, nil, nil, nil, 1)
    else
        GameTooltip:SetText(BATTLEPASS_DAY_LIMIT_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine(string.format(BATTLEPASS_DAY_LIMIT, self.mainFrame:GetCapXP()), nil, nil, nil, 1)
    end
    GameTooltip:Show()
end

function BattlePassLevelProgressBarTemplateMixin:OnLeave()
    GameTooltip:Hide()
end

BattlePassChestLevelFrameTemplateMixin = {}

function BattlePassChestLevelFrameTemplateMixin:OnLoad()
    self.Chest:SetAtlas("BattlePass-Chest-OverLevel")
end

BattlePassPageButtonTemplateMixin = {}

function BattlePassPageButtonTemplateMixin:OnLoad()
    self.isReverseTexture = self:GetAttribute("isReverseTexture")

    self:SetNormalAtlas("BattlePass-Page-Button")
    self:SetHighlightAtlas("BattlePass-Page-Button")
    self:SetDisabledAtlas("BattlePass-Page-Button-Disable")

    if self.isReverseTexture then
        self:GetNormalTexture():SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
        self:GetHighlightTexture():SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
        self:GetDisabledTexture():SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
    end

    self:SetParentArray("pageButtons")
end

function BattlePassPageButtonTemplateMixin:OnClick()
    self:GetParent():ChangePage(self.isReverseTexture)
end

BattlePassPageFrameTemplateMixin = {}

function BattlePassPageFrameTemplateMixin:OnLoad()
    self.mainFrame = BattlePassFrame
end

function BattlePassPageFrameTemplateMixin:ChangePage( isBack )
    self.mainFrame.currentPage = isBack and self.mainFrame.currentPage - 1 or self.mainFrame.currentPage + 1
    self:UpdatePages()
end

function BattlePassPageFrameTemplateMixin:UpdatePages()
    local currentPage = self.mainFrame:GetCurrentPage()
    local pageCount = self.mainFrame:GetPageCount()

    self.Pages:SetFormattedText(BATTLEPASS_PAGES, currentPage, pageCount + 1)

    self.pageButtons[1]:SetEnabled(currentPage > 1)
    self.pageButtons[2]:SetEnabled(currentPage < pageCount)

    self.mainFrame:UpdateLevelCards()
end

BattlePassRequiredLevelTemplateMixin = {}

function BattlePassRequiredLevelTemplateMixin:OnLoad()
    self.mainFrame = BattlePassFrame

    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 30)

    self:SetActive(false)
end

function BattlePassRequiredLevelTemplateMixin:SetLevel( level, isActive )
    if tostring(level):sub(1, 1) == "1" then
        self.TextInactive:ClearAndSetPoint("CENTER", -1, 0)
        self.TextActive:ClearAndSetPoint("CENTER", -1, 0)
    else
        self.TextInactive:ClearAndSetPoint("CENTER", 0, 0)
        self.TextActive:ClearAndSetPoint("CENTER", 0, 0)
    end

    self.TextInactive:SetText(level)
    self.TextActive:SetText(level)

    self:SetActive(isActive)
end

function BattlePassRequiredLevelTemplateMixin:SetActive( toggle )
    if toggle then
        self:SetSize(66, 72)
    else
        self:SetSize(50, 56)
    end

    self.TextActive:SetShown(toggle)
    self.TextInactive:SetShown(not toggle)

    if self:GetParent().NormalCard then
        if self:GetParent().NormalCard:IsHighLevelCard() then
            self:SetSize(180, 62)

            self.Background:SetAtlas("BattlePass-High-Level-Background")

            self.TextInactive:Hide()
            self.TextActive:Show()

            self.TextActive:SetFormattedText(BATTLEPASS_HIGHLEVEL_LABEL, self.mainFrame:GetLevelCount() - 1)
            self.TextActive:SetSize(160, 20)
        else
            self.Background:SetAtlas("BattlePass-".. (toggle and "Active" or "Inactive") .."-Level-Background")
            self.TextActive:SetSize(60, 20)
        end
    end
end

BattlePassInfoFrameTemplateMixin = {}

function BattlePassInfoFrameTemplateMixin:OnLoad()
    self.mainFrame  = BattlePassFrame
    self.elapsed    = 0
    self.easing     = 0
end

function BattlePassInfoFrameTemplateMixin:UpdateInfo( rerenderProgressBar )
    local level, levelXP, totalXP, maxLevelXP = self.mainFrame:GetLevelInfo()

    self.CurrentAndMaxLevel:SetFormattedText(BATTLEPASS_LEVEL, level)
    self.CurrentAndMaxLevel:SetShown(level > 0)
    self.LevelLabel:SetShown(level > 0)

    if rerenderProgressBar then
        self.newXP                      = totalXP
        self.oldXP                      = totalXP - self.mainFrame.newXP
        self.progressBarCurrentValue    = 0
        self.elapsed                    = 0
        self.runAnimation               = true
    else
        self.ProgressBar:SetValue(levelXP, maxLevelXP, self.mainFrame:GetCapXP())
    end
end

function BattlePassInfoFrameTemplateMixin:OnUpdate( elapsed )
    if not self.runAnimation then
        return
    end

    self.elapsed = self.elapsed + elapsed

    local neededXP = self.newXP - self.oldXP

    self.easing = outQuint(self.elapsed, self.progressBarCurrentValue, neededXP, 1)

    local level, maxLevelXP, levelXP = self.mainFrame:GetLevelInfoByXP(self.oldXP + self.easing)

    self.CurrentAndMaxLevel:SetFormattedText(BATTLEPASS_LEVEL, level)
    self.ProgressBar:SetValue(levelXP, maxLevelXP, self.mainFrame:GetCapXP())

    if self.elapsed > 1 then
        self.easing             = 0
        self.elapsed            = 0
        self.mainFrame.newXP    = 0
        self.runAnimation       = false

        self.CurrentAndMaxLevel:SetFormattedText(BATTLEPASS_LEVEL, level)
        self.CurrentAndMaxLevel:SetShown(level > 0)
        self.LevelLabel:SetShown(level > 0)

        self.ProgressBar:SetValue(levelXP, maxLevelXP, self.mainFrame:GetCapXP())
    end
end

BattlePassSelectXPButtonTemplateMixin = {}

function BattlePassSelectXPButtonTemplateMixin:OnLoad()
    self.description = _G[self:GetAttribute("description")] or self:GetAttribute("description")

    self:SetParentArray("XPButtons")

    SetPortraitToTexture(self.Icon, "Interface\\ICONS\\INV_Glove_Plate_PVPWarrior_C_01")
end

function BattlePassSelectXPButtonTemplateMixin:OnEnter()
    self.IconBorderHighLight:Show()

    if self.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.itemLink)
        GameTooltip:Show()
    end
end

function BattlePassSelectXPButtonTemplateMixin:OnLeave()
    self.IconBorderHighLight:Hide()
    GameTooltip:Hide()
end

function BattlePassSelectXPButtonTemplateMixin:OnMouseDown()
    self.Icon:ClearAndSetPoint("CENTER", -1, -1)
end

function BattlePassSelectXPButtonTemplateMixin:OnMouseUp()
    self.Icon:ClearAndSetPoint("CENTER", 0, 0)
end

function BattlePassSelectXPButtonTemplateMixin:OnClick()
    for _, button in pairs(self:GetParent().XPButtons) do
        button:SetChecked(button == self)
    end

    self:GetParent().Desc:SetText(_G["BATTLEPASS_XP_ITEM_DESCRIPTION_"..self.itemEntry] or "desc")
    self:GetParent().ItemName:SetText(self.itemName:gsub(BATTLEPASS_TRIM_XP_ITEM_NAME, ""))

    self:GetParent().itemEntry  = self.itemEntry
    self:GetParent().storeID    = self.storeID
    self:GetParent().price      = self.price

    self:GetParent().MultipleBuyFrame.EditBox:SetText(1)
    self:GetParent().MultipleBuyFrame.EditBox:Update()
end

function BattlePassSelectXPButtonTemplateMixin:SetupItem( storeID, itemEntry, price, discount, discountedPrice )
    local function ItemInfoResponceCallback( itemName, itemLink, _, _, _, _, _, _, _, itemTexture )
        self.itemName = itemName
        self.itemLink = itemLink

        SetPortraitToTexture(self.Icon, itemTexture)
    end

    local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemEntry, false, ItemInfoResponceCallback)

    if itemName then
        ItemInfoResponceCallback(itemName, itemLink, _, _, _, _, _, _, _, itemTexture)
    else
        ItemInfoResponceCallback("loading..", "Hitem:1", _, _, _, _, _, _, _, "Interface\\ICONS\\INV_Misc_QuestionMark")
    end

	if discountedPrice and discount then
		self.NormalPrice:Hide()
		self.SalePrice:Show()
		self.Strikethrough:Show()
		self.CurrentPrice:Show()

		self.CurrentPrice:SetText(price)
		self.SalePrice:SetText(discountedPrice)

		self.price = discountedPrice
	else
		self.NormalPrice:Show()
		self.SalePrice:Hide()
		self.Strikethrough:Hide()
		self.CurrentPrice:Hide()

		self.NormalPrice:SetText(price)

		self.price = discountedPrice
	end

    self.storeID    = storeID
    self.itemEntry  = itemEntry
end

BattlePassBuyOverlayFrameMixin = {}

function BattlePassBuyOverlayFrameMixin:OnLoad()
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 50)

    self.ConfirmationFrame.CloseButton:SetScript("OnClick", function()
        self:Hide()
    end)
end

function BattlePassBuyOverlayFrameMixin:ShowFrame( categoryID )
    self.ConfirmationFrame.MultipleBuyFrame:SetShown(categoryID == 1)

    self.categoryID = categoryID
    self:Show()
end

function BattlePassBuyOverlayFrameMixin:OnShow()
    if STORE_PRODUCT_CACHE and STORE_PRODUCT_CACHE[1] then
        if STORE_PRODUCT_CACHE[1][101][self.categoryID] then
            local index = 0

            local productCount  = tCount(STORE_PRODUCT_CACHE[1][101][self.categoryID][0].data)
            local size          = (112 / 2) * productCount
            local offset        = 0

            local sortedTable = {}
            for id in pairs(STORE_PRODUCT_CACHE[1][101][self.categoryID][0].data) do
                table.insert(sortedTable, id)
            end
            table.sort(sortedTable)

            for _, id in ipairs(sortedTable) do
                index = index + 1

                local itemButton = self.ConfirmationFrame.XPButtons[index]

                local data = STORE_PRODUCT_CACHE[1][101][self.categoryID][0].data[id]
                if itemButton and data then
                    itemButton:SetupItem(data[1], data[2], data[4], data[6], data[7])

                    local xOffset = -size + 112 * offset + 60
                    itemButton:ClearAndSetPoint("CENTER", xOffset, 0)

                    offset = offset + 1

                    itemButton:Show()
                else
                    break
                end
            end

            for i = index + 1, #self.ConfirmationFrame.XPButtons do
                local itemButton = self.ConfirmationFrame.XPButtons[i]

                if itemButton then
                    itemButton:Hide()
                end
            end

            self.ConfirmationFrame.XPButtons[self.ConfirmationFrame.XPButtons[2]:IsShown() and 2 or 1]:Click()
        end
    end
end

BattlePassMultipleBuyEditBoxMixin = {}

function BattlePassMultipleBuyEditBoxMixin:OnLoad()
    self:SetText(1)
end

function BattlePassMultipleBuyEditBoxMixin:Update()
    local confirmFrame = self:GetParent():GetParent()
    local text = tonumber(self:GetText())

    if not text or text < 1 then
        self:SetText(1)
        confirmFrame.buyCount = 1
        return
    end

    confirmFrame.NoticeFrame.Price:SetText((confirmFrame.price or 0) * text)
    confirmFrame.buyCount = text

    NumericInputSpinner_OnTextChanged(self)
end

BattlePassBuyFrameBuyButtonMixin = {}

function BattlePassBuyFrameBuyButtonMixin:OnClick()
    local parent = self:GetParent()

    parent:GetParent():Hide()

    SendServerMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:%d:0:0:0", parent.storeID, parent.buyCount or 1))
end

BattlePassTutorialButtonMixin = {}

function BattlePassTutorialButtonMixin:OnLoad()
    self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS")

    self.mainFrame = BattlePassFrame

    self.helpPlateData = {
        FrameSize = { },
        FramePos = { x = 150, y = 0 },
        [1] = { ButtonPos = { }, HighLightBox = { width = 465, height = 130 }, ToolTipDir = "DOWN", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_1 },
        [2] = { ButtonPos = { }, HighLightBox = { width = 996, height = 258 }, ToolTipDir = "RIGHT", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_2 },
        [3] = { ButtonPos = { }, HighLightBox = { width = 996, height = 258 }, ToolTipDir = "RIGHT", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_3 },
        [4] = { ButtonPos = { }, HighLightBox = { width = 200, height = 258 }, ToolTipDir = "DOWN", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_4 },
        [5] = { ButtonPos = { }, HighLightBox = { width = 200, height = 258 }, ToolTipDir = "DOWN", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_5 },
    }
end

function BattlePassTutorialButtonMixin:UpdateHelpPlateData()
    local width, height = self.mainFrame:GetSize()
    local x = self.mainFrame.InfoRightFrame:GetLeft() - 140
    local y = self.mainFrame.InfoRightFrame:GetTop() - height
    local x2 = self.mainFrame.cards[1].PremiumCard:GetLeft() - 150
    local y2 = self.mainFrame.cards[1].PremiumCard:GetTop() - height
    local x3 = self.mainFrame.cards[6].PremiumCard:GetLeft() - 150
    local y3 = self.mainFrame.cards[6].NormalCard:GetTop() - height

    self.helpPlateData.FrameSize.width = width
    self.helpPlateData.FrameSize.height = height

    self.helpPlateData[1].ButtonPos.x = x
    self.helpPlateData[1].ButtonPos.y = y
    self.helpPlateData[1].HighLightBox.x = x
    self.helpPlateData[1].HighLightBox.y = y

    self.helpPlateData[2].ButtonPos.x = x2
    self.helpPlateData[2].ButtonPos.y = y2
    self.helpPlateData[2].HighLightBox.x = x2
    self.helpPlateData[2].HighLightBox.y = y2

    self.helpPlateData[3].ButtonPos.x = x2
    self.helpPlateData[3].ButtonPos.y = y3
    self.helpPlateData[3].HighLightBox.x = x2
    self.helpPlateData[3].HighLightBox.y = y3

    self.helpPlateData[4].ButtonPos.x = x3
    self.helpPlateData[4].ButtonPos.y = y2
    self.helpPlateData[4].HighLightBox.x = x3
    self.helpPlateData[4].HighLightBox.y = y2

    self.helpPlateData[5].ButtonPos.x = x3
    self.helpPlateData[5].ButtonPos.y = y3
    self.helpPlateData[5].HighLightBox.x = x3
    self.helpPlateData[5].HighLightBox.y = y3
end

function BattlePassTutorialButtonMixin:OnEvent()
    if ( self:IsShown() and self.helpPlateData and HelpPlate_IsShowing(self.helpPlateData) ) then
        self:UpdateHelpPlateData()
        HelpPlate_Show( self.helpPlateData, self.mainFrame, self )
    end
end

function BattlePassTutorialButtonMixin:OnClick()
    if ( self.helpPlateData and not HelpPlate_IsShowing(self.helpPlateData) ) then
        self:UpdateHelpPlateData()
		
		local infoData  = C_CacheInstance:Get("ASMSG_BATTLEPASS_SETTINGS")
		
		self.helpPlateData[1].ToolTipText = string.format(BATTLEPASS_TUTORIAL_TEXT_1, infoData.pointsBG, infoData.pointsArena, infoData.pointsArena1vs1, infoData.dayAmount, infoData.totalAmount, infoData.dayAmount)

        HelpPlate_Show( self.helpPlateData, self.mainFrame, self )
    else
        HelpPlate_Hide(true)
    end
end

function BattlePassTutorialButtonMixin:OnEnter()
    Main_HelpPlate_Button_ShowTooltip(self);

    if not NPE_TutorialPointerFrame:GetKey("BattlePassTutorial_1") then
        if self.mainFrame.tutorial then
            NPE_TutorialPointerFrame:Hide(self.mainFrame.tutorial)
            self.mainFrame.tutorial = nil
        end

        NPE_TutorialPointerFrame:SetKey("BattlePassTutorial_1", true)
    end
end