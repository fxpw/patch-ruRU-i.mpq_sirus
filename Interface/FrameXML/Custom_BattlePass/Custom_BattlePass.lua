local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetRemainingTime = GetRemainingTime

local PAGE_TYPE = {
	CARDS = 1,
	QUESTS = 2,
}

local DIALOG_TYPE = {
	Info = 1,
	QuestReplace = 2,
	PurchaseExperience = 3,
	PurchaseExperiencePost = 4,
	PurchasePremium = 5,
	ItemReward = 6,
	ItemAlert = 7,
}

local QUEST_TYPE = {
	[Enum.BattlePass.QuestType.Daily] = {
		questType = Enum.BattlePass.QuestType.Daily,
		template = "BattlePassQuestDailyTemplate",
		iconAtlas = "PKBT-BattlePass-Icon-QuestsType-Daily",
		label = BATTLEPASS_QUESTS_DAILY,
	},
	[Enum.BattlePass.QuestType.Weekly] = {
		questType = Enum.BattlePass.QuestType.Weekly,
		template = "BattlePassQuestWeeklyTemplate",
		iconAtlas = "PKBT-BattlePass-Icon-QuestsType-Weekly",
		label = BATTLEPASS_QUESTS_WEEKLY,
	},
}

local LEVEL_SHIELD_STATE_ATLAS = {
	[Enum.BattlePass.CardState.Default] = "PKBT-BattlePass-UI-CastingBar-Shield-Default",
	[Enum.BattlePass.CardState.LootAvailable] = "PKBT-BattlePass-UI-CastingBar-Shield-Active",
	[Enum.BattlePass.CardState.Looted] = "PKBT-BattlePass-UI-CastingBar-Shield-Disabled",
}

local ITEM_GROW_DIRECTION = {
	UP = {
		BOTTOM = "BOTTOM",
		BOTTOMLEFT = "BOTTOMLEFT",
		BOTTOMRIGHT = "BOTTOMRIGHT",
		TOP = "TOP",
		TOPLEFT = "TOPLEFT",
		TOPRIGHT = "TOPRIGHT",
	},
	DOWN = {
		BOTTOM = "TOP",
		BOTTOMLEFT = "TOPLEFT",
		BOTTOMRIGHT = "TOPRIGHT",
		TOP = "BOTTOM",
		TOPLEFT = "BOTTOMLEFT",
		TOPRIGHT = "BOTTOMRIGHT",
	},
}

BattlePassMixin = CreateFromMixins(TitledPanelMixin)

function BattlePassMixin:OnLoad()
	self.maxScale = 1
	self.selectedPageIndex = 0
	self.pages = {}
	self.pageButtons = {}
	self.dialogs = {}

	self.Inset.Top:SetAtlas("PKBT-BattlePass-Background-Top", true)
	self.Inset.Middle:SetAtlas("PKBT-BattlePass-Background-Middle", true)
	self.Inset.Bottom:SetAtlas("PKBT-BattlePass-Background-Bottom", true)

	self.Inset.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.Inset.VignetteBottomLeft:SetAtlas("PKBT-Vignette-Bronze-BottomLeft", true)
	self.Inset.VignetteBottomRight:SetAtlas("PKBT-Vignette-Bronze-BottomRight", true)

	self.Inset.ArtworkBottomLeft:SetAtlas("PKBT-BattlePass-Corner-Artwork", true)

	self.Inset.ShadowLeft:SetAtlas("PKBT-Background-Shadow-Large-Left", true)
	self.Inset.ShadowRight:SetAtlas("PKBT-Background-Shadow-Large-Right", true)

	local pageButtonDisabledColor = {1, 1, 1}
	self.TopPanel.RewardPageButton.noDisabledBackground = true
	self.TopPanel.RewardPageButton.noDesaturation = true
	self.TopPanel.RewardPageButton.disabledColor = pageButtonDisabledColor
	self.TopPanel.RewardPageButton:AddTextureAtlas("PKBT-BattlePass-Icon-Page-Rewards", true)
	self.TopPanel.RewardPageButton:AddText(BATTLEPASS_REWARDS_LABEL, nil, nil, "PKBT_Font_20")

	self.TopPanel.QuestPageButton.noDisabledBackground = true
	self.TopPanel.QuestPageButton.noDesaturation = true
	self.TopPanel.QuestPageButton.disabledColor = pageButtonDisabledColor
	self.TopPanel.QuestPageButton:AddTextureAtlas("PKBT-BattlePass-Icon-Page-Quests", true)
	self.TopPanel.QuestPageButton:AddText(BATTLEPASS_QUESTS_LABEL, nil, nil, "PKBT_Font_20")
	self.TopPanel.QuestPageButton.Notification:SetAtlas("PKBT-Icon-Notification", true)

	self.spinnerPool = CreateFramePool("Frame", self, "LoadingSpinnerTemplate")

	self:SetTitle(BATTLEPASS_TITLE)

	self.tutorialData = {
		FrameSize = {},
		FramePos = {x = 0, y = 0},
		[1] = {ButtonPos = {}, HighLightBox = {}, ToolTipDir = "DOWN", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_1},
		[2] = {ButtonPos = {}, HighLightBox = {}, ToolTipDir = "RIGHT", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_2},
		[3] = {ButtonPos = {}, HighLightBox = {}, ToolTipDir = "RIGHT", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_3},
		[4] = {ButtonPos = {}, HighLightBox = {}, ToolTipDir = "DOWN", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_4},
		[5] = {ButtonPos = {}, HighLightBox = {}, ToolTipDir = "DOWN", ToolTipText = BATTLEPASS_TUTORIAL_TEXT_5},
	}

	self:RegisterPageButton(self.TopPanel.RewardPageButton)
	self:RegisterPageButton(self.TopPanel.QuestPageButton)
	self:SetPage(PAGE_TYPE.CARDS)

	self:RegisterCustomEvent("BATTLEPASS_OPERATION_ERROR")
	self:RegisterCustomEvent("BATTLEPASS_EXPERIENCE_UPDATE")
	self:RegisterCustomEvent("BATTLEPASS_ITEM_PURCHASED")
	self:RegisterCustomEvent("BATTLEPASS_REWARD_ITEMS")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_LIST_UPDATE")
	self:RegisterCustomEvent("BATTLEPASS_POINTS_UPDATE")
end

function BattlePassMixin:OnEvent(event, ...)
	if event == "BATTLEPASS_OPERATION_ERROR" then
		local errorText = ...
		self:GetDialog(DIALOG_TYPE.Info):ShowDialog(BATTLEPASS_STATUS_ERROR, errorText)
	elseif event == "BATTLEPASS_EXPERIENCE_UPDATE" then
		local level, levelExp = ...
		self:LevelUpdate()
	elseif event == "BATTLEPASS_ITEM_PURCHASED" then
		local itemID, amount = ...
		if self:IsShown() then
			local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
			self:GetDialog(DIALOG_TYPE.PurchaseExperiencePost):ShowItemDialog(link, amount)
			self:GetDialog(DIALOG_TYPE.ItemAlert):SetItem(name, icon, amount)
		end
	elseif event == "BATTLEPASS_REWARD_ITEMS" then
		local items = ...
		if #items > 0 then
			self:GetDialog(DIALOG_TYPE.ItemReward):ShowItems(items)
		end
	elseif event == "BATTLEPASS_QUEST_LIST_UPDATE" then
		if self:IsShown() then
			self:QuestStatusUpdate()
		end
	elseif event == "BATTLEPASS_POINTS_UPDATE" then
		self:UpdateTutorialTexts()
	end
end

function BattlePassMixin:OnShow()
	C_BattlePass.RequestProductData()
	C_BattlePass.RequestQuests()
	self:LevelUpdate()
	self:QuestStatusUpdate()
	self:SetTutorialReminderShown(true)
end

function BattlePassMixin:OnHide()
	for _, dialog in ipairs(self.dialogs) do
		dialog:Hide()
	end

	self:ToggleBlockFrame(false)

	if DressUpFrame:GetParent() == self then
		DressUpFrame:Hide()
		DressUpFrame:SetParent(UIParent)
	end

	self:SetTutorialReminderShown(false)
	HelpPlate_Hide()
end

function BattlePassMixin:GetTopPanel()
	return self.TopPanel
end

function BattlePassMixin:GetContentPanel()
	return self.Content
end

function BattlePassMixin:RegisterPageWidget(pageWidget)
	local pageIndex = pageWidget:GetID()
	self.pages[pageIndex] = pageWidget
	pageWidget:SetShown(pageIndex == self.selectedPageIndex)
end

function BattlePassMixin:GetPage(index)
	return self.pages[index]
end

function BattlePassMixin:RegisterPageButton(pageButton)
	local pageIndex = pageButton:GetID()
	self.pageButtons[pageIndex] = pageButton
	pageButton:SetEnabled(pageIndex ~= self.selectedPageIndex)
end

function BattlePassMixin:GetPageButton(index)
	return self.pageButtons[index]
end

function BattlePassMixin:SetPage(index)
	if self.selectedPageIndex == index and self.pages[index]:IsShown() then
		return
	end

	self.selectedPageIndex = index

	for pageIndex, page in ipairs(self.pages) do
		if pageIndex ~= index then
			page:Hide()
		end
	end

	for pageIndex, pageButton in ipairs(self.pageButtons) do
		pageButton:SetEnabled(pageIndex ~= index)
	end

	if self.pages[index] then
		self.pages[index]:Show()
	end
end

function BattlePassMixin:GetSelectedPage()
	return self.selectedPageIndex
end

function BattlePassMixin:ShowPage(index)
	self:SetPage(index)
	ShowUIPanel(self)
end

function BattlePassMixin:RegisterDialogWidget(dialogType, dialogWidget)
	self.dialogs[dialogType] = dialogWidget
end

function BattlePassMixin:GetDialog(index)
	return self.dialogs[index]
end

function BattlePassMixin:HideDialogs(dialogException)
	for _, dialog in pairs(self.dialogs) do
		if dialog ~= dialogException then
			dialog:Hide()
		end
	end
end

function BattlePassMixin:ToggleBlockFrame(toggle)
	self.BlockFrame:SetShown(toggle)

	if toggle then
		SetParentFrameLevel(self.BlockFrame, 10)
	end
end

function BattlePassMixin:LevelUpdate()
	local level, currentExp, expToLevel = C_BattlePass.GetLevelInfo()
	local experiencePanel = self:GetTopPanel().ExperiencePanel
	experiencePanel:SetProgress(currentExp, expToLevel)
	experiencePanel.LevelShield:SetLevel(level)

	local mainPage = self:GetPage(PAGE_TYPE.CARDS)
	mainPage.ExperienceStatusBar:SetLevel(level, currentExp, expToLevel)
end

function BattlePassMixin:QuestStatusUpdate()
	self.TopPanel.QuestPageButton.Notification:SetShown(C_BattlePass.HasCompleteQuests())
end

function BattlePassMixin:ShowCardWithItem(itemID)
	local level = C_BattlePass.GetLevelCardWithRewardItemID(itemID)
	if level then
		self:ShowPage(PAGE_TYPE.CARDS)

		local cardsPage = self:GetPage(PAGE_TYPE.CARDS)
		if not cardsPage:IsShown() then
			cardsPage:Show()
		end

		cardsPage:ScrollToLevel(level)
	end
end

function BattlePassMixin:SetTutorialReminderShown(shown)
	if self.tutorialReminder then
		NPE_TutorialPointerFrame:Hide(self.tutorialReminder)
		self.tutorialReminder = nil
	end

	if not shown then
		return
	end

	if not NPE_TutorialPointerFrame:GetKey("BattlePassTutorial_1") then
		self.tutorialReminder = NPE_TutorialPointerFrame:Show(BATTLEPASS_TUTORIAL_0, "LEFT", self.TopPanel.Tutorial, 0, 0)
	end
end

local function SetTutorialEntryRelatives(tutorialEntry, relative1, relative2)
	local topPanelLeft = relative1:GetLeft()
	local topPanelTop = relative1:GetTop()

	tutorialEntry.ButtonPos.x = topPanelLeft
	tutorialEntry.ButtonPos.y = topPanelTop

	tutorialEntry.HighLightBox.x = topPanelLeft
	tutorialEntry.HighLightBox.y = topPanelTop
	tutorialEntry.HighLightBox.width = relative2:GetRight() - topPanelLeft
	tutorialEntry.HighLightBox.height = topPanelTop - relative2:GetBottom()
end

function BattlePassMixin:UpdateTutorialPositions()
	local width, height = self.Inset:GetSize()
	self.tutorialData.FrameSize.width = width
	self.tutorialData.FrameSize.height = height
	self.tutorialData.FramePos.x = self.Inset:GetLeft()
	self.tutorialData.FramePos.y = self.Inset:GetTop()

	SetTutorialEntryRelatives(self.tutorialData[1], self.TopPanel.RewardPageButton, self.TopPanel.QuestPageButton)
	SetTutorialEntryRelatives(self.tutorialData[2], self.TopPanel.SeasonTimer, self.TopPanel.SeasonTimer)
	SetTutorialEntryRelatives(self.tutorialData[3], self.TopPanel.ExperiencePanel, self.TopPanel.ExperiencePanel)
	SetTutorialEntryRelatives(self.tutorialData[4], self.Content.MainPage.ScrollFrame, self.Content.MainPage.ScrollFrame)
	SetTutorialEntryRelatives(self.tutorialData[5], self.TopPanel.SeasonTimer, self.TopPanel.SeasonTimer)
end

function BattlePassMixin:UpdateTutorialTexts()
	local pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1 = C_BattlePass.GetSourceExperience()
	local maxLevel = C_BattlePass.GetMaxLevel()

	self.tutorialData[1].ToolTipText = string.format(BATTLEPASS_EXPERIENCE_INFO, pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1)
	self.tutorialData[4].ToolTipText = string.format(BATTLEPASS_TUTORIAL_TEXT_4, maxLevel)
	self.tutorialData[5].ToolTipText = string.format(BATTLEPASS_TUTORIAL_TEXT_5, maxLevel)
end

function BattlePassMixin:TutorialOnClick()
	if not HelpPlate_IsShowing(self.tutorialData) then
		self:UpdateTutorialPositions()
		self:UpdateTutorialTexts()
		HelpPlate_Show(self.tutorialData, self.Inset, self.TopPanel.Tutorial)
	else
		HelpPlate_Hide(true)
	end
end

function BattlePassMixin:TutorialOnEnter()
	if not NPE_TutorialPointerFrame:GetKey("BattlePassTutorial_1") then
		self:SetTutorialReminderShown(false)
		NPE_TutorialPointerFrame:SetKey("BattlePassTutorial_1", true)
	end

--	Main_HelpPlate_Button_ShowTooltip(self.TopPanel.Tutorial)

	GameTooltip:SetOwner(self.TopPanel.Tutorial, "ANCHOR_NONE")
	GameTooltip:SetMinimumWidth(350)
	GameTooltip:AddLine(BATTLEPASS_TITLE)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_1, 1, 1, 1, true)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_2, 1, 1, 1, true)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_3, 1, 1, 1, true)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_4, 1, 1, 1, true)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_5, 1, 1, 1, true)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_6, 1, 1, 1, true)
	GameTooltip:AddLine(BATTLEPASS_TUTORIAL_7, 1, 1, 1, true)
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("TOPLEFT", self.TopPanel.Tutorial, "TOPRIGHT", 5, 0)
	GameTooltip:Show()
end

function BattlePassMixin:TutorialOnLeave()
	GameTooltip:Hide()
end

BattlePassDialogMixin = CreateFromMixins(PKBT_DialogMixin)

function BattlePassDialogMixin:OnLoad()
	PKBT_DialogMixin.OnLoad(self)

	self.Background:SetTexture(0.110, 0.102, 0.098)
	self.Background:SetAlpha(0.95)
end

function BattlePassDialogMixin:OnShow()
	self:GetParent():ToggleBlockFrame(true)
end

function BattlePassDialogMixin:OnHide()
	self:GetParent():ToggleBlockFrame(false)
end

function BattlePassDialogMixin:OkClick(button)
end

function BattlePassDialogMixin:CancelClick(button)
	self:Hide()
end

BattlePassSeasonTimerMixin = CreateFromMixins(PKBT_CountdownThrottledBaseMixin)

function BattlePassSeasonTimerMixin:OnLoad()
	self.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)
end

function BattlePassSeasonTimerMixin:OnCountdownUpdate(timeLeft, isFinished)
	if timeLeft > 0 then
		self.TimeLeft:SetText(GetRemainingTime(timeLeft))
		self.TimeLeftLabel:Show()
		self.TimerIcon:Show()
	else
		self.TimeLeft:SetText(BATTLEPASS_SEASON_TIMELEFT_INACTIVE)
		self.TimeLeftLabel:Hide()
		self.TimerIcon:Hide()

		if isFinished then
		--	TODO request new season info from server?
		end
	end
end

BattlePassAnimatedGemMixin = {}

function BattlePassAnimatedGemMixin:OnShow()
	self.frameIndex = 1
	self.elapsed = 0 - math.random(0, 1500) * 0.001
	self.waitTime = nil
	self.Icon:SetAtlas(string.format("%s-%.2u", self.atlasName, self.frameIndex))
end

function BattlePassAnimatedGemMixin:OnUpdate(elapsed)
	if self.waitTime then
		self.waitTime = self.waitTime - elapsed

		if self.waitTime > 0 then
			return
		else
			self.elapsed = -self.waitTime - elapsed
			self.waitTime = nil
		end
	end

	self.elapsed = self.elapsed + elapsed

	if self.elapsed >= self.frameTime then
		self.elapsed = self.elapsed - self.frameTime

		if self.elapsed > 0.1 then
			self.elapsed = 0
		end

		if self.frameIndex == self.frames then
			self.frameIndex = 1
			self.waitTime = math.random(800, 2500) * 0.001 - self.elapsed
		else
			self.frameIndex = self.frameIndex + 1
		end

		self.Icon:SetAtlas(string.format("%s-%.2u", self.atlasName, self.frameIndex))
	end
end

function BattlePassAnimatedGemMixin:SetIconAtlas(atlasName, frames)
	self.frames = frames or 34
	self.atlasName = atlasName
	self.frameTime = 1 / self.frames
	self:Show()
end

BattlePassLevelGlyphsMixin = {}

function BattlePassLevelGlyphsMixin:OnLoad()
	self.Level:SetFontObject(_G[self:GetAttribute("fontTemplate")])
	self.Level:SetPoint("CENTER", -1, self:GetAttribute("offsetY") or 1)
end

function BattlePassLevelGlyphsMixin:SetLevel(level)
	self.Level:SetText(level)
end

BattlePassExperiencePanelMixin = CreateFromMixins(BattlePassLevelGlyphsMixin)

function BattlePassExperiencePanelMixin:OnLoad()
	self.StatusBar.BarTexture:SetAtlas("PKBT-StatusBar-Texture-Blue")
	self.GemIcon:SetIconAtlas("PKBT-BattlePass-Icon-Gem-Sapphire-Animated")
	self.LevelShield.Shield:SetAtlas("PKBT-BattlePass-UI-CastingBar-Shield-Default")
	self.LevelShield.Shield:SetSize(60, 60)

	self.StatusBar.Left:Hide()
	self.StatusBar.Right:Hide()
	self.StatusBar.Center:ClearAllPoints()
	self.StatusBar.Center:SetPoint("TOPLEFT", 0, 7)
	self.StatusBar.Center:SetPoint("BOTTOMRIGHT", 5, -7)
end

function BattlePassExperiencePanelMixin:OnShow()
	SetParentFrameLevel(self.LevelShield, 2)
end

function BattlePassExperiencePanelMixin:SetProgress(value, maxValue)
	self.StatusBar:SetStatusBarMinMax(0, maxValue)
	self.StatusBar:SetStatusBarValue(value)
end

function BattlePassExperiencePanelMixin:PurchaseClick(button)
	self:GetParent():GetParent():GetDialog(DIALOG_TYPE.PurchaseExperience):Show()
end

function BattlePassExperiencePanelMixin:StatusBarOnEnter(button)
	local pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1 = C_BattlePass.GetSourceExperience()

	GameTooltip:SetOwner(self.StatusBar, "ANCHOR_TOP", 0, 10)
	GameTooltip:AddLine(BATTLEPASS_EXPERIENCE_LABEL)
	GameTooltip:AddLine(string.format(BATTLEPASS_EXPERIENCE_INFO, pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1), 1, 1, 1)
	GameTooltip:Show()
end

function BattlePassExperiencePanelMixin:StatusBarOnLeave(button)
	GameTooltip:Hide()
end

local CARD_WIDTH = 212
local CARD_INIT_OFFSET_X = 44
local CARD_OFFSET_X = -6
local EXPERIENCE_SCROLL_PADDING = 6

BattlePassMainPageMixin = {}

function BattlePassMainPageMixin:OnLoad()
	self.cardFrames = {}

	self.PurchasePremiumButton:AddTextureAtlas("PKBT-Icon-Crown", true, nil, nil, -20, 0)
	self.PurchasePremiumButton:AddText(BATTLEPASS_PURCHASE_PREMIUM, -12, 0, "PKBT_Font_18")
	self.PurchasePremiumButton:SetPadding(28)

	self.PurchasePremiumButton.Glow.Left:SetAtlas("PKBT-Button-Glow-Left", true)
	self.PurchasePremiumButton.Glow.Right:SetAtlas("PKBT-Button-Glow-Right", true)
	self.PurchasePremiumButton.Glow.Center:SetAtlas("PKBT-Button-Glow-Center")

	self.PremiumActiveIcon:SetAtlas("PKBT-Icon-Crown", true)

	self.ExperienceStatusBar = self.ExperienceScrollFrame.ScrollChild.ExperienceStatusBar

	self.mainFrame = self:GetParent():GetParent()
	self.mainFrame:RegisterPageWidget(self)

	self.ScrollFrame.ScrollBar.stepSize = (CARD_WIDTH + CARD_OFFSET_X) / 5
	self.ScrollFrame.ScrollBar.updateInterval = 0.01
	self.ScrollFrame.ScrollBar.doNotHide = true
	self.ScrollFrame.update = function()
		self:OnScrollUpdate()
	end
	self.ScrollFrame.scrollObjectWidth = function(cardIndex)
		if cardIndex == 1 then
			return CARD_INIT_OFFSET_X + CARD_WIDTH + CARD_OFFSET_X
		else
			return CARD_WIDTH + CARD_OFFSET_X
		end
	end

	self.ShieldScrollFrame.OnHorizontalScroll = function() end
	self.ShieldScrollFrame:CreateButtons("BattlePassLevelShieldScrollTemplate", "$parentLevelShield%u", CARD_INIT_OFFSET_X, 0, "LEFT", "LEFT", CARD_OFFSET_X, 0, "LEFT", "RIGHT")
	self.shields = self.ShieldScrollFrame.buttons

	self.ScrollFrame:CreateButtons("BattlePassLevelCardTemplate", "$parentLevelCard%u", CARD_INIT_OFFSET_X, 0, "TOPLEFT", "TOPLEFT", CARD_OFFSET_X, 0, "TOPLEFT", "TOPRIGHT")
	self.cards = self.ScrollFrame.buttons

	self.elapsed = 0
	self.animGlowTime = 2

	self:RegisterCustomEvent("BATTLEPASS_ACCOUNT_UPDATE")
	self:RegisterCustomEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
	self:RegisterCustomEvent("BATTLEPASS_CARD_UPDATE")
end

function BattlePassMainPageMixin:OnShow()
	self.mainFrame.Inset.ArtworkBottomLeft:Show()
	self.mainFrame.Inset.VignetteBottomLeft:Show()

	SetParentFrameLevel(self.ExperienceScrollFrame, 2)
	SetParentFrameLevel(self.ShieldScrollFrame, 3)

	self:UpdatePremium()
	self:UpdateSeasonTimer()
	self:UpdateCards()

	self:ScrollToCurrentLevel()
end

function BattlePassMainPageMixin:OnEvent(event, ...)
	if not self:IsShown() then
		return
	end

	if event == "BATTLEPASS_ACCOUNT_UPDATE" then
		self:UpdatePremium()
		self:UpdateSeasonTimer()
	elseif event == "BATTLEPASS_CARD_UPDATE_BUCKET" then
		self:UpdateCards()
	elseif event == "BATTLEPASS_CARD_UPDATE" then
		local level, rewardType = ...
		self:UpdateCards()
	end
end

function BattlePassMainPageMixin:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed >= self.animGlowTime then
		self.elapsed = self.elapsed - self.animGlowTime
	end

	local alpha
	local halfTime = self.animGlowTime / 2
	if self.elapsed < halfTime then
		alpha = inOutQuad(self.elapsed, 0, 1, halfTime)
	else
		alpha = outQuad(self.elapsed - halfTime, 1, -1, halfTime)
	end

	for _, card in ipairs(self.cards) do
		if card.sholdGlow then
			card.FreeFrame.BackgroundGlow:SetAlpha(alpha)
			card.PremiumFrame.BackgroundGlow:SetAlpha(alpha)
		end
	end
end

function BattlePassMainPageMixin:PurchasePremiumClick(button)
	self.mainFrame:HideDialogs()
	self.mainFrame:GetDialog(DIALOG_TYPE.PurchasePremium):Show()
end

function BattlePassMainPageMixin:UpdatePremium()
	local isActive = C_BattlePass.IsPremiumActive()

	self.PurchasePremiumButton:SetShown(not isActive)
	self.PremiumActiveText:SetShown(isActive)
	self.PremiumActiveIcon:SetShown(isActive)
end

function BattlePassMainPageMixin:UpdateSeasonTimer()
	self.mainFrame.TopPanel.SeasonTimer:SetTimeLeft(C_BattlePass.GetSeasonTimeLeft())
	self.mainFrame.TopPanel.SeasonTimer:Show()
end

function BattlePassMainPageMixin:UpdateCards()
	self:OnScrollUpdate()
end

function BattlePassMainPageMixin:ScrollToLevel(level)
	self.ScrollFrame:ScrollToIndex(level, self.ScrollFrame.scrollObjectWidth)
end

function BattlePassMainPageMixin:ScrollToCurrentLevel()
	local level = C_BattlePass.GetLevelInfo()
	self:ScrollToLevel(level + 1)
end

function BattlePassMainPageMixin:OnScrollUpdate()
	local offset = self.ScrollFrame:GetOffset()
	local numLevelCards = C_BattlePass.GetNumLevelCards()

	for index, card in ipairs(self.ScrollFrame.buttons) do
		local cardIndex = offset + index
		local shield = self.shields[index]

		if cardIndex <= numLevelCards then
			local level, freeState, premiumState, shieldState, freeItems, premiumItems = C_BattlePass.GetLevelCardRewardInfo(cardIndex)

			card:SetID(cardIndex)
			card:SetState(freeState, premiumState)

			card.itemPool:ReleaseAll()
			card:SetFreeRewardItems(freeItems, freeState)
			card:SetPremiumRewardItems(premiumItems, premiumState)
			card:Show()

			shield.Shield:SetAtlas(LEVEL_SHIELD_STATE_ATLAS[shieldState], true)
			shield:SetLevel(level)
			shield:Show()
		else
			card:Hide()
			shield:Hide()
		end
	end

	if not self.upToDateRect or self.numLevelCards ~= numLevelCards then
		local totalWidth = CARD_INIT_OFFSET_X * 2 + (CARD_WIDTH + CARD_OFFSET_X) * numLevelCards - CARD_OFFSET_X
		self.ScrollFrame:Update(totalWidth)
		self.ShieldScrollFrame:Update(totalWidth)
		self.numLevelCards = numLevelCards
		self.upToDateRect = true
	end
end

function BattlePassMainPageMixin:OnHorizontalScroll(offset, scrollWidth)
	self.ShieldScrollFrame:SetOffset(offset)
	self.ExperienceScrollFrame:SetHorizontalScroll(self.ScrollFrame.ScrollBar:GetValue())
end

function BattlePassMainPageMixin:OnScrollRangeChanged(xrange, yrange)
	local numLevelCards = C_BattlePass.GetNumLevelCards()

	local cardsWidth = (CARD_WIDTH + CARD_OFFSET_X) * numLevelCards - CARD_OFFSET_X
	self.ExperienceStatusBar:SetWidth(cardsWidth - EXPERIENCE_SCROLL_PADDING * 2)
	self.ExperienceScrollFrame.ScrollChild:SetSize(CARD_INIT_OFFSET_X * 2 + cardsWidth, self.ScrollFrame.ScrollChild:GetHeight())
	self.ExperienceScrollFrame:SetVerticalScroll(0)
	self.ExperienceScrollFrame:UpdateScrollChildRect()
end

BattlePassStatusBarAnim = {}

function BattlePassStatusBarAnim:OnLoad()
	self.elapsed = 0
	self.animTime = 30

	if self.BarTexture and self.barTextureAtlas then
		self.BarTexture:SetAtlas(self.barTextureAtlas, true)
		self.BarTexture.atlasInfo = C_Texture.GetAtlasInfo(self.barTextureAtlas)
	end

	if self.Overlay and self.overlayAtlas then
		self.Overlay:SetAtlas(self.overlayAtlas, true)
		self.Overlay.atlasInfo = C_Texture.GetAtlasInfo(self.overlayAtlas)

		self.Overlay:ClearAllPoints()
		self.Overlay:SetPoint("TOPLEFT", 0, 0)
		self.Overlay:SetPoint("BOTTOMRIGHT", self:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end
end

function BattlePassStatusBarAnim:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > (self.animTime or 1) then
		self.elapsed = self.elapsed - (self.animTime or 1)
	end

	local progress = self.elapsed / (self.animTime or 1)

	if self.BarTexture and self.BarTexture.atlasInfo then
		self.BarTexture:SetTexCoord(0 + progress, 1 + progress, self.BarTexture.atlasInfo.topTexCoord, self.BarTexture.atlasInfo.bottomTexCoord)
		self.BarTexture:SetHorizTile(true)
	end

	if self.Overlay and self.Overlay.atlasInfo then
		self.Overlay:SetTexCoord(0 + progress, 1 + progress, self.Overlay.atlasInfo.topTexCoord, self.Overlay.atlasInfo.bottomTexCoord)
		self.Overlay:SetHorizTile(true)
	end
end

function BattlePassStatusBarAnim:ToggleStatusBarAnimation(state)
	if state and ((self.BarTexture and self.barTextureAtlas) or (self.Overlay and self.overlayAtlas)) then
		self:SetScript("OnUpdate", self.OnUpdate)
	else
		self:SetScript("OnUpdate", nil)
	end
end

BattlePassExperienceStatusBarMixin = CreateFromMixins(BattlePassStatusBarAnim)

function BattlePassExperienceStatusBarMixin:OnLoad()
	self.Left:SetAtlas("PKBT-BattlePass-StatusBar-Level-Progress-Background-Left", true)
	self.Right:SetAtlas("PKBT-BattlePass-StatusBar-Level-Progress-Background-Right", true)
	self.Center:SetAtlas("PKBT-BattlePass-StatusBar-Level-Progress-Background-Center")

	self.barTextureAtlas = "PKBT-BattlePass-StatusBar-Level-Progress-Texture"
--	self.overlayAtlas = "PKBT-BattlePass-StatusBar-Texture-Overlay"
	self.animTime = 60
	BattlePassStatusBarAnim.OnLoad(self)

	self.cardShields = {}
	self.valueMult = 100
	self.showLevelProgress = false
	self:ToggleStatusBarAnimation(true)
end

function BattlePassExperienceStatusBarMixin:SetLevel(level, currentExp, expToLevel)
	local numLevelCards = C_BattlePass.GetNumLevelCards()
	local maxValue = numLevelCards * self.valueMult - math.ceil(numLevelCards / 10)
	self:SetMinMaxValues(0, maxValue)

	if level == 0 then
		self:SetValue(0)
	elseif level == numLevelCards then
		local _, maxValue = self:GetMinMaxValues()
		self:SetValue(maxValue)
	else
		local offset = math.ceil(level / 10)
		if self.showLevelProgress then
			self:SetValue(level * self.valueMult - 50 - offset + 100 * currentExp / expToLevel)
		else
			self:SetValue(level * self.valueMult - 50 - offset)
		end
	end
end

BattlePassLevelCardMixin = {}

function BattlePassLevelCardMixin:OnLoad()
	self.itemPool = CreateFramePool("Button", self, "BattlePassLevelCardItemTemplate")

	self.mainPageFrame = self:GetParent():GetParent():GetParent()

	self.FreeFrame.BackgroundGlow:SetAtlas("PKBT-BattlePass-Card-Bottom-Active", true)
	self.PremiumFrame.BackgroundGlow:SetAtlas("PKBT-BattlePass-Card-Top-Active", true)
end

function BattlePassLevelCardMixin:OnHide()
	self.sholdGlow = nil
end

function BattlePassLevelCardMixin:ActionClick(rewardType, button)
	if rewardType == Enum.BattlePass.RewardType.Free then
		C_BattlePass.TakeLevelReward(self:GetID(), rewardType)
	elseif rewardType == Enum.BattlePass.RewardType.Premium then
		if C_BattlePass.IsPremiumActive() then
			C_BattlePass.TakeLevelReward(self:GetID(), rewardType)
		else
			self.mainPageFrame.mainFrame:HideDialogs()
			self.mainPageFrame.mainFrame:GetDialog(DIALOG_TYPE.PurchasePremium):Show()
		end
	end
end

function BattlePassLevelCardMixin:SetState(freeState, premiumState)
	self.sholdGlow = freeState == Enum.BattlePass.CardState.LootAvailable or premiumState == Enum.BattlePass.CardState.LootAvailable

	if freeState == Enum.BattlePass.CardState.Looted then
		self.FreeFrame.Background:SetAtlas("PKBT-BattlePass-Card-Bottom-Disabled", true)
		self.FreeFrame.BackgroundGlow:Hide()
		self.FreeFrame.ActionButton:SetText(BATTLEPASS_REWARD_RECEIVED)
		self.FreeFrame.ActionButton:Disable()
		self.FreeFrame.ActionButton:Show()
	else
		self.FreeFrame.Background:SetAtlas("PKBT-BattlePass-Card-Bottom", true)

		if freeState == Enum.BattlePass.CardState.LootAvailable then
			self.FreeFrame.BackgroundGlow:Show()
			self.FreeFrame.ActionButton:SetText(BATTLEPASS_LEVEL_REWARD_TAKE)
			self.FreeFrame.ActionButton:Enable()
			self.FreeFrame.ActionButton:Show()
		else
			self.FreeFrame.BackgroundGlow:Hide()
			self.FreeFrame.ActionButton:Hide()
		end
	end

	if premiumState == Enum.BattlePass.CardState.Looted then
		self.PremiumFrame.Background:SetAtlas("PKBT-BattlePass-Card-Top-Disabled", true)
		self.PremiumFrame.BackgroundGlow:Hide()
		self.PremiumFrame.ActionButton:SetText(BATTLEPASS_REWARD_RECEIVED)
		self.PremiumFrame.ActionButton:Disable()
		self.PremiumFrame.ActionButton:Show()
	else
		self.PremiumFrame.Background:SetAtlas("PKBT-BattlePass-Card-Top", true)

		if premiumState == Enum.BattlePass.CardState.LootAvailable then
			self.PremiumFrame.BackgroundGlow:Show()
			self.PremiumFrame.ActionButton:SetText(BATTLEPASS_LEVEL_REWARD_TAKE)
			self.PremiumFrame.ActionButton:Enable()
			self.PremiumFrame.ActionButton:Show()
		else
			self.PremiumFrame.BackgroundGlow:Hide()
			self.PremiumFrame.ActionButton:Hide()
		end
	end
end

function BattlePassLevelCardMixin:SetRewardItems(items, holder, state, isPremium)
	local points = ITEM_GROW_DIRECTION[isPremium and "UP" or "DOWN"]
	local numItems = #items

	self.items = items

	for itemIndex, itemData in ipairs(items) do
		local itemButton = self.itemPool:Acquire()

		itemButton:SetItem(itemData.itemID, itemData.amount, state, isPremium)
		itemButton:SetParent(holder)

		if numItems == 1 then
			itemButton:SetPoint("CENTER", 0, 0)
		elseif numItems == 2 then
			if itemIndex == 1 then
				itemButton:SetPoint(points.BOTTOM, 0, 0)
			else
				itemButton:SetPoint(points.TOP, 0, 0)
			end
		else
			if itemIndex == 1 then
				itemButton:SetPoint(points.BOTTOMLEFT, 0, 0)
			elseif itemIndex == 2 then
				itemButton:SetPoint(points.BOTTOMRIGHT, 0, 0)
			else
				if numItems == 3 then
					itemButton:SetPoint(points.TOP, 0, 0)
				elseif itemIndex == 3 then
					itemButton:SetPoint(points.TOPLEFT, 0, 0)
				else
					itemButton:SetPoint(points.TOPRIGHT, 0, 0)
				end
			end
		end

		itemButton:Show()
	end
end

function BattlePassLevelCardMixin:SetFreeRewardItems(items, state)
	local isPremium = false
	self:SetRewardItems(items, self.FreeFrame.ItemHolder, state, isPremium)
end

function BattlePassLevelCardMixin:SetPremiumRewardItems(items, state)
	local isPremium = true
	self:SetRewardItems(items, self.PremiumFrame.ItemHolder, state, isPremium)
end

BattlePassLevelCardItemMixin = {}

function BattlePassLevelCardItemMixin:OnLoad()
	self.Highlight:SetAtlas("PKBT-ItemBorder-Highlight", true)

	self.UpdateTooltip = self.OnEnter
end

function BattlePassLevelCardItemMixin:OnEnter()
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end
	CursorUpdate(self)
end

function BattlePassLevelCardItemMixin:OnLeave()
	if self.itemLink then
		GameTooltip_Hide()
	end
	ResetCursor()
end

function BattlePassLevelCardItemMixin:OnClick(button)
	if self.itemLink then
		HandleModifiedItemClick(self.itemLink)
	end
end

function BattlePassLevelCardItemMixin:SetItem(itemLink, amount, state, isPremium)
	local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemLink)
	self.itemLink = link
	self.hasItem = link ~= nil
	self.Icon:SetTexture(texture)

	if amount > 1 then
		if state == Enum.BattlePass.CardState.Looted then
			self.Amount:SetTextColor(0.5, 0.5, 0.5)
		else
			self.Amount:SetTextColor(1, 1, 1)
		end

		self.Amount:SetText(amount)
		self.Amount:Show()
	else
		self.Amount:Hide()
	end

	if state == Enum.BattlePass.CardState.Looted then
		self.Icon:SetVertexColor(0.5, 0.5, 0.5)
		self.Border:SetAtlas("PKBT-ItemBorder", true)
	else
		self.Icon:SetVertexColor(1, 1, 1)

		if state == Enum.BattlePass.CardState.LootAvailable then
			if isPremium then
				self.Border:SetAtlas("PKBT-ItemBorder-Gold", true)
			else
				self.Border:SetAtlas("PKBT-ItemBorder-Silver", true)
			end
		else
			self.Border:SetAtlas("PKBT-ItemBorder", true)
		end
	end
end

BattlePassQuestPageMixin = {}

function BattlePassQuestPageMixin:OnLoad()
	self.questHolders = {}

	self.mainFrame = self:GetParent():GetParent()
	self.mainFrame:RegisterPageWidget(self)

	self:RegisterEvent("PLAYER_MONEY")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_LIST_UPDATE")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_UPDATE")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_UPDATE_TEXT")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_ACTION_AWAIT")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_REPLACED")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_REPLACE_FAILED")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_DONE")
	self:RegisterCustomEvent("BATTLEPASS_QUEST_REWARD_FAILED")
end

function BattlePassQuestPageMixin:OnEvent(event, ...)
	if not self:IsShown() then
		return
	end

	if event == "PLAYER_MONEY" then
		self:UpdateQuestHolders()

		local dialog = self:GetParent():GetParent():GetDialog(DIALOG_TYPE.QuestReplace)
		if dialog:IsShown() then
			dialog.OkButton:SetEnabled(C_BattlePass.CanReplaceQuest(dialog.questType, dialog.questIndex))
		end
	elseif event == "BATTLEPASS_QUEST_LIST_UPDATE" then
		self:UpdateQuestHolders()
	elseif event == "BATTLEPASS_QUEST_UPDATE"
	or event == "BATTLEPASS_QUEST_UPDATE_TEXT"
	then
		local questType, questIndex = ...

		local questHolder = self.questHolders[questType]
		if questHolder then
			local questFrame = questHolder.questFrames[questIndex]
			if questFrame and questFrame:IsShown() then
				questHolder:UpdateQuest(questIndex, event == "BATTLEPASS_QUEST_UPDATE_TEXT")
				return
			end

			questHolder:UpdateQuests()
			return
		end

		self:UpdateQuestHolders()
	elseif event == "BATTLEPASS_QUEST_REPLACED"
	or event == "BATTLEPASS_QUEST_REPLACE_FAILED"
	or event == "BATTLEPASS_QUEST_ACTION_AWAIT"
	then
		local questType, questIndex = ...

		local questHolder = self.questHolders[questType]
		if questHolder then
			questHolder:UpdateQuest(questIndex, nil, event == "BATTLEPASS_QUEST_REPLACED")
		end
	elseif event == "BATTLEPASS_QUEST_DONE" then
		local questType, questIndex = ...
		self.questHolders[questType]:UpdateQuests()
	elseif event == "BATTLEPASS_QUEST_REWARD_FAILED" then
		local questType, questIndex = ...

		local questHolder = self.questHolders[questType]
		if questHolder then
			local questFrame = questHolder.questFrames[questIndex]
			if questFrame and questFrame:IsShown() then
				questHolder:UpdateQuest(questIndex)
			end
		end
	end
end

function BattlePassQuestPageMixin:OnShow()
	self.mainFrame.Inset.ArtworkBottomLeft:Hide()
	self.mainFrame.Inset.VignetteBottomLeft:Hide()

	self.mainFrame.TopPanel.SeasonTimer:Hide()

	self:UpdateQuestHolders()
end

function BattlePassQuestPageMixin:UpdateQuestHolders()
	local height = 0
	local lastHolder

	for questType, questHolderInfo in ipairs(QUEST_TYPE) do
		local questHolder = self.questHolders[questType]
		if not questHolder then
			questHolder = CreateFrame("Frame", string.format("$parentQuestHolder%u", questType), self.ScrollFrame.ScrollChild, "BattlePassQuestsHolderTemplate")
			questHolder.mainFrame = self.mainFrame
			questHolder:SetOwner(self)
			questHolder:SetType(questType)
			questHolder.label = questHolderInfo.label
			questHolder.Header:SetLabel(questHolderInfo.label)
			questHolder.Header:SetIcon(questHolderInfo.iconAtlas)
			self.questHolders[questType] = questHolder
		end

		local holderHeight = questHolder:UpdateQuests()

		if holderHeight > 0 then
			questHolder:ClearAllPoints()
			if lastHolder then
				questHolder:SetPoint("TOPLEFT", lastHolder, "BOTTOMLEFT", 0, -40)
			else
				questHolder:SetPoint("TOPLEFT", 0, 0)
			end

			questHolder:SetPoint("TOP", 0, 0)
			questHolder:Show()

			lastHolder = questHolder
			height = height + holderHeight
		else
			questHolder:Hide()
		end
	end

	self.ScrollFrame.ScrollChild:SetSize(self.ScrollFrame:GetWidth(), height)
	self.ScrollFrame:UpdateScrollChildRect()
end

BattlePassQuestHeaderMixin = {}

function BattlePassQuestHeaderMixin:OnLoad()
	self.TimerIcon:SetAtlas("PKBT-Icon-Timer", true)
end

function BattlePassQuestHeaderMixin:SetIcon(atlasName)
	self.Icon:SetAtlas(atlasName, true)
end

function BattlePassQuestHeaderMixin:SetLabel(text)
	self.Label:SetText(text)
end

local QUEST_PER_ROW = 2
local QUEST_ENTRY_OFFSET_HEADER_X = 5
local QUEST_ENTRY_OFFSET_X = 22
local QUEST_ENTRY_OFFSET_Y = 36

BattlePassQuestHolderMixin = CreateFromMixins(PKBT_OwnerMixin, PKBT_CountdownThrottledBaseMixin)

function BattlePassQuestHolderMixin:OnLoad()
	self.questFrames = {}
	self:RegisterCustomEvent("BATTLEPASS_QUEST_RESET_TIMER_UPDATE")
end

function BattlePassQuestHolderMixin:OnEvent(event, ...)
	if event == "BATTLEPASS_QUEST_RESET_TIMER_UPDATE" then
		self:SetTimeLeft(C_BattlePass.GetQuestTypeTimeLeft(self.api.questType))
	end
end

function BattlePassQuestHolderMixin:SetType(apiType)
	self:SetID(apiType)
	self.api = QUEST_TYPE[apiType]
end

function BattlePassQuestHolderMixin:OnCountdownUpdate(timeLeft, isFinished)
	if timeLeft > 0 then
		local remainingTime = GetRemainingTime(timeLeft)
		self.Header.TimeLeft:SetText(remainingTime)
		self.NoQuestTimer:SetFormattedText(BATTLEPASS_QUEST_NO_AVAILABLE, self.label, remainingTime)
	else
		self.Header.TimeLeft:SetText(BATTLEPASS_QUEST_TIMELEFT_UNAVAILABLE)
		self.NoQuestTimer:SetText(BATTLEPASS_QUEST_TIMELEFT_UNAVAILABLE)

		if isFinished then
			C_BattlePass.RequestQuests()
		end
	end
end

function BattlePassQuestHolderMixin:UpdateQuests()
	self:SetTimeLeft(C_BattlePass.GetQuestTypeTimeLeft(self.api.questType))

	local numQuests = C_BattlePass.GetNumQuests(self.api.questType)
	if numQuests == 0 then
		local height = self.Header:GetHeight() + QUEST_ENTRY_OFFSET_HEADER_X + 130
		self:SetHeight(height)
		self.NoQuestTimer:Show()

		for _, questFrame in ipairs(self.questFrames) do
			questFrame:Hide()
		end

		return height
	end

	self.NoQuestTimer:Hide()

	for questIndex = 1, numQuests do
		local questFrame = self.questFrames[questIndex]
		if not questFrame then
			questFrame = CreateFrame("Frame", string.format("$parentQuestFrame%u", questIndex), self, self.api.template)
			questFrame.mainFrame = self.mainFrame
			self.questFrames[questIndex] = questFrame
		end

		questFrame:SetID(questIndex)
		self:UpdateQuest(questIndex)

		if questIndex == 1 then
			questFrame:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -QUEST_ENTRY_OFFSET_HEADER_X)
		elseif questIndex % QUEST_PER_ROW ~= 0 then
			questFrame:SetPoint("TOPLEFT", self.questFrames[questIndex - QUEST_PER_ROW], "BOTTOMLEFT", 0, -QUEST_ENTRY_OFFSET_Y)
		else
			questFrame:SetPoint("TOPLEFT", self.questFrames[questIndex - 1], "TOPRIGHT", QUEST_ENTRY_OFFSET_X, 0)
		end

		questFrame:Show()
	end

	for i = numQuests + 1, #self.questFrames do
		self.questFrames[i]:Hide()
	end

	local questEntryHeight = self.questFrames[1]:GetHeight()
	local questEntryRows = math.ceil(numQuests / QUEST_PER_ROW)
	local height = self.Header:GetHeight() + QUEST_ENTRY_OFFSET_HEADER_X + questEntryHeight * questEntryRows + QUEST_ENTRY_OFFSET_Y * (questEntryRows - 1)
	self:SetHeight(height)

	return height
end

function BattlePassQuestHolderMixin:UpdateQuest(questIndex, isTextUpdate, wasReplaced)
	local name, description, rewardAmount, progressValue, progressMaxValue, isPercents = C_BattlePass.GetQuestInfo(self.api.questType, questIndex)
	local questFrame = self.questFrames[questIndex]
	questFrame.Progress.Name:SetText(name)
	questFrame.Progress.Description:SetText(description)
	questFrame.Reward.Value:SetText(rewardAmount)

	if not isTextUpdate then
		questFrame:SetProgress(progressValue, progressMaxValue, isPercents, wasReplaced)
	end
end

BattlePassQuestMixin = {}

function BattlePassQuestMixin:OnLoad()
	self.buttonDefaultAtlas = "PKBT-128-RedButton"
	self.buttonReplaceAtlas = "PKBT-128-BlueButton"

	self.Reward.Icon:ClearAllPoints()
	self.Reward.Icon:SetPoint("TOP", 0, 0)
	self.Reward.Icon:SetSize(50, 50)

	Mixin(self.Progress.StatusBar, BattlePassStatusBarAnim)
	self.Progress.StatusBar.overlayAtlas = "PKBT-BattlePass-StatusBar-Texture-Overlay"
	self.Progress.StatusBar.BarTexture:SetAtlas("PKBT-BattlePass-StatusBar-Texture-2")
	self.Progress.StatusBar.Glow:SetAtlas("PKBT-BattlePass-StatusBar-Texture-2")
	BattlePassStatusBarAnim.OnLoad(self.Progress.StatusBar)

	self.ActionButton:SetFixedWidth(117)

	self.elapsed = 0
	self.animGlowTime = 1
	self.animHoldTime = 1
end

function BattlePassQuestMixin:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed < self.animGlowTime then
		self.NineSliceGlow:SetBorderAlpha(inOutQuad(self.elapsed, 0, 1, self.animGlowTime / 2))
	else
		self.NineSliceGlow:SetBorderAlpha(0)

		if self.pulseOnce then
			self.pulseOnce = nil
			self.elapsed = 0
			self:SetScript("OnUpdate", nil)
			return
		end

		if self.elapsed > (self.animGlowTime + self.animHoldTime) then
			self.elapsed = self.elapsed - (self.animGlowTime + self.animHoldTime)
		end
	end
end

function BattlePassQuestMixin:ToggleGlowAnim(state)
	if state then
		if self.Progress.StatusBar.Glow.AlphaAnim:IsPlaying() then
			self.Progress.StatusBar.Glow.AlphaAnim:Stop()
		end
		self.Progress.StatusBar.Glow.AlphaAnim:Play()
		self.elapsed = 0
		self:SetScript("OnUpdate", self.OnUpdate)
		self.Progress.StatusBar.BarTexture:SetAtlas("PKBT-BattlePass-StatusBar-Texture-1")
	else
		self.Progress.StatusBar.Glow.AlphaAnim:Stop()
		self:SetScript("OnUpdate", nil)
		self.NineSliceGlow:SetBorderAlpha(0)
		self.elapsed = 0
		self.Progress.StatusBar.BarTexture:SetAtlas("PKBT-StatusBar-Green")
	end
end

function BattlePassQuestMixin:PulseOnce()
	self.pulseOnce = true
	self.elapsed = 0
	self:SetScript("OnUpdate", self.OnUpdate)
end

function BattlePassQuestMixin:SetProgress(value, maxValue, isPercents, wasReplaced)
	self.Progress.StatusBar:SetStatusBarMinMax(0, maxValue)
	self.Progress.StatusBar:SetStatusBarValue(value, isPercents)

	local isComplete = C_BattlePass.IsQuestComplete(self.questType, self:GetID())
	local isAwaiting = C_BattlePass.IsAwaitingQuestAction(self.questType, self:GetID())

	if isComplete then
		self.Progress.StatusBar.Value:SetText(BATTLEPASS_QUEST_COMPLETED)
		self.Progress.Status:SetAtlas("PKBT-BattlePass-Quest-Status-Complete", true)
	else
		self.Progress.Status:SetAtlas("PKBT-BattlePass-Quest-Status-InProgress", true)
	end

	self.Progress.StatusBar:ToggleStatusBarAnimation(isComplete)
	self.Progress.StatusBar.Overlay:SetShown(isComplete)
	self.Progress.StatusBar.Glow:SetShown(isComplete)
	self:ToggleGlowAnim(isComplete)

	if not isComplete and wasReplaced then
		self:PulseOnce()
	end

	self:UpdateActionButton(isComplete, isAwaiting)
end

function BattlePassQuestMixin:UpdateActionButton(isComplete, isAwaiting)
	if isAwaiting then
		self.ActionButton:ShowSpinner()
		self.ActionButton:Disable()
		self.ActionButton:Show()
	elseif isComplete then
		self.ActionButton:HideSpinner()
		self.ActionButton:ClearObjects()
		self.ActionButton:AddText(BATTLEPASS_QUEST_REWARD_TAKE)

		if self.ActionButton:IsShown() then
			self.ActionButton:UpdateHolderRect()
		end

		if self.ActionButton.atlasName ~= self.buttonDefaultAtlas then
			self.ActionButton.atlasName = self.buttonDefaultAtlas
			self.ActionButton:SetHighlightAtlas(self.ActionButton.atlasName.."-Highlight")
			self.ActionButton:UpdateButton()
		end

		self.ActionButton:Enable()
		self.ActionButton:Show()
		self.Progress.StatusBar:SetWidth(386)
	elseif C_BattlePass.IsQuestReplaceAllowed(self.questType, self:GetID()) then
		self.ActionButton:HideSpinner()
		self.ActionButton:ClearObjects()
		self.ActionButton:AddTextureAtlas("PKBT-Icon-Refresh", true)
		self.ActionButton:AddText(BATTLEPASS_QUEST_CHANGE)

		if self.ActionButton:IsShown() then
			self.ActionButton:UpdateHolderRect()
		end

		if self.ActionButton.atlasName ~= self.buttonReplaceAtlas then
			self.ActionButton.atlasName = self.buttonReplaceAtlas
			self.ActionButton:SetHighlightAtlas(self.ActionButton.atlasName.."-Highlight")
			self.ActionButton:UpdateButton()
		end

		self.ActionButton:SetEnabled(C_BattlePass.CanReplaceQuest(self.questType, self:GetID()))
		self.ActionButton:Show()
		self.Progress.StatusBar:SetWidth(386)
	else
		self.ActionButton:Hide()
		self.Progress.StatusBar:SetWidth(510)
	end
end

function BattlePassQuestMixin:ActionClick(button)
	if C_BattlePass.IsQuestComplete(self.questType, self:GetID()) then
		C_BattlePass.CollectQuestReward(self.questType, self:GetID())
	elseif C_BattlePass.CanReplaceQuest(self.questType, self:GetID()) then
		self.mainFrame:GetDialog(DIALOG_TYPE.QuestReplace):ShowReplaceDialog(self.questType, self:GetID())
	end
end

function BattlePassQuestMixin:ActionOnEnter()
	if self.ActionButton:IsEnabled() ~= 1 and not C_BattlePass.IsQuestComplete(self.questType, self:GetID()) and not C_BattlePass.CanReplaceQuest(self.questType, self:GetID()) then
		local price = C_BattlePass.GetQuestReplacePrice(self.questType, self:GetID())
		GameTooltip:SetOwner(self.ActionButton, "ANCHOR_RIGHT")
		GameTooltip:AddLine(BATTLEPASS_QUEST_REPLACE_NOT_ENOUGHT_MONEY)
		GameTooltip:AddLine(string.format(BATTLEPASS_QUEST_REPLACE_PRICE, GetMoneyString(price)), 1, 1, 1)
		GameTooltip:Show()
	end
end

function BattlePassQuestMixin:ActionOnLeave()
	GameTooltip:Hide()
end

BattlePassQuestDailyMixin = CreateFromMixins(BattlePassQuestMixin)

function BattlePassQuestDailyMixin:OnLoad()
	BattlePassQuestMixin.OnLoad(self)

	self.Background:SetAtlas("PKBT-BattlePass-Quest-Background-Rhodium")
	self.VignetteLeft:SetAtlas("PKBT-BattlePass-Quest-Vignette-Rhodium-Left", true)
	self.VignetteRight:SetAtlas("PKBT-BattlePass-Quest-Vignette-Rhodium-Right", true)

	self.NineSliceGlow.DecoreTop:SetAtlas("PKBT-Panel-Rhodium-Deacor-Footer", true)
	self.NineSliceGlow.DecoreTop:SetSubTexCoord(0, 1, 1, 0)
	self.NineSliceGlow.DecoreBottom:SetAtlas("PKBT-Panel-Rhodium-Deacor-Footer", true)

	self.Reward:SetIconAtlas("PKBT-BattlePass-Icon-Gem-Sapphire-Animated")

	self.questType = Enum.BattlePass.QuestType.Daily
end

BattlePassQuestWeeklyMixin = CreateFromMixins(BattlePassQuestMixin)

function BattlePassQuestWeeklyMixin:OnLoad()
	BattlePassQuestMixin.OnLoad(self)

	self.Background:SetAtlas("PKBT-BattlePass-Quest-Background-Bronze")
	self.VignetteLeft:SetAtlas("PKBT-BattlePass-Quest-Vignette-Bronze-Left", true)
	self.VignetteRight:SetAtlas("PKBT-BattlePass-Quest-Vignette-Bronze-Right", true)

	self.NineSliceGlow.DecoreTop:SetAtlas("PKBT-BattlePass-Quest-Decor-Bronze-Header", true)
	self.NineSliceGlow.DecoreBottom:SetAtlas("PKBT-BattlePass-Quest-Decor-Bronze-Footer", true)

	self.Reward:SetIconAtlas("PKBT-BattlePass-Icon-Gem-Emerald-Animated")

	self.questType = Enum.BattlePass.QuestType.Weekly
end

BattlePassQuestReplacetDialogMixin = CreateFromMixins(BattlePassDialogMixin)

function BattlePassQuestReplacetDialogMixin:OnLoad()
	BattlePassDialogMixin.OnLoad(self)

	self:SetTitle(BATTLEPASS_QUEST_REPLACE)
	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.QuestReplace, self)
end

function BattlePassQuestReplacetDialogMixin:OnHide()
	BattlePassDialogMixin.OnHide(self)
	self.questType = nil
	self.questIndex = nil
end

function BattlePassQuestReplacetDialogMixin:ShowReplaceDialog(questType, questIndex)
	local name, description = C_BattlePass.GetQuestInfo(questType, questIndex)
	local price = C_BattlePass.GetQuestReplacePrice(questType, questIndex)
	self.OkButton:SetEnabled(C_BattlePass.CanReplaceQuest(questType, questIndex))
	self.Text:SetWidth(self:GetWidth() - 40)
	if price > 0 then
		self.Text:SetFormattedText(BATTLEPASS_QUEST_REPLACE_BODY, description, GetMoneyString(price))
	else
		self.Text:SetFormattedText(BATTLEPASS_QUEST_REPLACE_BODY_FREE, description)
	end
	self.questType = questType
	self.questIndex = questIndex
	self:Show()
	self:SetHeight(145 + self.Text:GetHeight())
end

function BattlePassQuestReplacetDialogMixin:OkClick(button)
	C_BattlePass.ReplaceQuest(self.questType, self.questIndex)
	self:Hide()
end

BattlePassPurchasePremiumDialogMixin = CreateFromMixins(PKBT_DialogMixin)

function BattlePassPurchasePremiumDialogMixin:OnLoad()
	self:SetTitle(BATTLEPASS_PURCHASE_TITLE)
	self.Background:SetAtlas("PKBT-BattlePass-Background-Premium", true)
	self.BodyText:SetWidth(self:GetWidth() - 230)

	self.PurchaseButton:AddText(BATTLEPASS_PURCHASE_PREMIUM)

	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.PurchasePremium, self)
end

function BattlePassPurchasePremiumDialogMixin:OnShow()
	local price, originalPrice, currenyIndex = C_BattlePass.GetPremiumPrice()
	self.PurchaseButton:SetPrice(price, originalPrice, currenyIndex)
	self.price = price
	self.currenyIndex = currenyIndex

	self:GetParent():ToggleBlockFrame(true)
end

function BattlePassPurchasePremiumDialogMixin:OnHide()
	self:GetParent():ToggleBlockFrame(false)
end

function BattlePassPurchasePremiumDialogMixin:PurchaseOnClick(button)
	self:Hide()
	C_BattlePass.PurchasePremium()
end

BattlePassPurchaseExperienceDialogMixin = CreateFromMixins(PKBT_DialogMixin)

function BattlePassPurchaseExperienceDialogMixin:OnLoad()
	self:SetTitle(BATTLEPASS_PURCHASE_TITLE)

	self.Background:SetAtlas("PKBT-BattlePass-Background-Experience", true)

	self.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)

	self.Ribbon:SetText(BATTLEPASS_PURCHASE_EXPERIENCE_RIBBON_LABEL)

	local textWidth = self:GetWidth() - 100
	self.BodyExperienceText:SetWidth(textWidth)
	self.BodyLevelText:SetWidth(textWidth)

	self.experienceIconMarkup = CreateAtlasMarkup("PKBT-BattlePass-Icon-Gem-Sapphire", 21, 21, 0, 0, 2048, 2048)
	self.optionButtons = {}

	self.OptionAmount.minValue = 1
	self.OptionAmount.maxValue = function()
		return self:GetMaxSelectedAmount()
	end

	self.OptionAmount.OnValueChanged = function(value, userInput)
		self:Summery()
	end

	self.selectedOptionIndex = 1
	self.OptionAmount:SetTextNoScript(1)

	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.PurchaseExperience, self)
end

function BattlePassPurchaseExperienceDialogMixin:OnShow()
	self:GetParent():ToggleBlockFrame(true)

	self:SetSelectedOption(1)
	self.OptionAmount:SetText(1)

	self:UpdateOptions()
	self:Summery()
end

function BattlePassPurchaseExperienceDialogMixin:OnHide()
	self:GetParent():ToggleBlockFrame(false)
end

function BattlePassPurchaseExperienceDialogMixin:PurchaseOnClick()
	C_BattlePass.PurchaseExperience(self.selectedOptionIndex, self.OptionAmount:GetNumber())
	self:Hide()
end

function BattlePassPurchaseExperienceDialogMixin:UpdateOptions()
	if self.upToDate then
		return
	end

	local BUTTON_OFFSET_X = 36

	local numOptions = C_BattlePass.GetNumExperiencePurchaseOptions()
	for optionIndex = 1, numOptions do
		local optionButton = self.optionButtons[optionIndex]
		if not optionButton then
			optionButton = CreateFrame("CheckButton", string.format("$parentOptionCheckButton%u", optionIndex), self.OptionContainer, "BattlePassExperienceOptionTemplate")
			optionButton:SetID(optionIndex)

			if optionIndex == 1 then
				optionButton:SetPoint("LEFT", 0, 0)
			else
				optionButton:SetPoint("LEFT", self.optionButtons[optionIndex - 1], "RIGHT", BUTTON_OFFSET_X, 0)
			end

			self.optionButtons[optionIndex] = optionButton
		end

		optionButton:UpdateInfo()
		optionButton:SetChecked(optionIndex == self.selectedOptionIndex)
		optionButton:SetEnabled(optionIndex ~= self.selectedOptionIndex)
		optionButton:Show()
	end

	for optionIndex = numOptions + 1, #self.optionButtons do
		self.optionButtons[optionIndex]:Hide()
	end

	if numOptions > 0 then
		self.OptionContainer:SetWidth((self.optionButtons[1]:GetWidth() or 0) * numOptions + BUTTON_OFFSET_X * (numOptions - 1))
	end

	self.upToDate = true
end

function BattlePassPurchaseExperienceDialogMixin:SetSelectedOption(optionIndex)
	for index, optionButton in ipairs(self.optionButtons) do
		optionButton:SetChecked(optionIndex == index)
		optionButton:SetEnabled(optionIndex ~= index)
	end

	self.selectedOptionIndex = optionIndex
	self.OptionAmount:SetText(1)

	self:Summery()
end

function BattlePassPurchaseExperienceDialogMixin:SetOptionAmount(count)
	self.OptionAmount:SetText(math.max(1, count))
	self:Summery()
end

function BattlePassPurchaseExperienceDialogMixin:Summery()
	local option = C_BattlePass.GetExperiencePurchaseOptionInfo(self.selectedOptionIndex)
	if not option then
		self.PurchaseButton:Hide()
		self.OptionAmount:Hide()
		return
	end

	local amount = math.max(1, self.OptionAmount:GetNumber())

	do	-- Text
		local totalExperience = option.experience * amount
		local level = C_BattlePass.GetLevelInfo()
		local newLevel = C_BattlePass.CalculateAddedExperience(totalExperience)

		self.BodyExperienceText:SetFormattedText(BATTLEPASS_PURCHASE_EXPERIENCE_TEXT_BODY, self.experienceIconMarkup, totalExperience)
		self.BodyLevelText:SetFormattedText(BATTLEPASS_PURCHASE_EXPERIENCE_TEXT_BODY_LEVEL, newLevel - level)
	end

	do	-- Balance
		local balance = Store_GetBalance(option.currencyType)
		local price = option.price * amount

		self.PurchaseButton:SetPrice(price, option.originalPrice, option.currencyType)
		self.PurchaseButton:Show()

		self.OptionAmount.IncrementButton:SetEnabled(option.price * (amount + 1) <= balance)
		self.OptionAmount:Show()
	end
end

function BattlePassPurchaseExperienceDialogMixin:GetMaxSelectedAmount()
	local option = C_BattlePass.GetExperiencePurchaseOptionInfo(self.selectedOptionIndex)
	if not option then
		return 0
	end
	local balance = Store_GetBalance(option.currencyType)
	local amount = math.modf(balance / option.price)
	return amount
end

BattlePassExperienceOptionMixin = CreateFromMixins(BattlePassAnimatedGemMixin)

function BattlePassExperienceOptionMixin:OnLoad()
	self.CheckedTexture:SetDrawLayer("BACKGROUND")

	self.Experience.Left:SetAtlas("PKBT-Input-Digit-Background-Left", true)
	self.Experience.Right:SetAtlas("PKBT-Input-Digit-Background-Right", true)
	self.Experience.Center:SetAtlas("PKBT-Input-Digit-Background-Center", true)

	self.iconOffsetX = math.abs(select(4, self.Price.Icon:GetPoint()))
end

function BattlePassExperienceOptionMixin:OnEnter()
	self.HighlightTexture:Show()
end

function BattlePassExperienceOptionMixin:OnLeave()
	self.HighlightTexture:Hide()
end

function BattlePassExperienceOptionMixin:OnClick(button)
	if self:GetChecked() then
		self:GetParent():GetParent():SetSelectedOption(self:GetID())

		if self:IsMouseOver() then
			self:OnEnter()
		end
	end
end

function BattlePassExperienceOptionMixin:UpdateInfo()
	local option = C_BattlePass.GetExperiencePurchaseOptionInfo(self:GetID())

	self.CheckedTexture:SetAtlas(option.checkedAtlas, true)
	self.HighlightTexture:SetAtlas(option.highlightAtlas, true)
	self:SetIconAtlas(option.iconAnimAtlas)

	self.Experience.Amount:SetFormattedText(BATTLEPASS_PURCHASE_EXPERIENCE_FORMAT, option.experience)
	self.Experience:SetWidth(math.max(70, self.Experience.Amount:GetStringWidth() + 20))

	self.Price.Icon:SetAtlas(option.currencyAtlas)
	self.Price.Amount:SetText(option.price)

	local iconWidth = self.Price.Icon:GetWidth() + self.iconOffsetX
	self.Price.Amount:SetPoint("BOTTOM", iconWidth / 2, 0)
	self.Price:SetWidth(self.Price.Amount:GetStringWidth() + iconWidth)
end

BattlePassInfoDialogMixin = CreateFromMixins(BattlePassDialogMixin)

function BattlePassInfoDialogMixin:OnLoad()
	BattlePassDialogMixin.OnLoad(self)

	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.Info, self)
end

function BattlePassInfoDialogMixin:ShowDialog(title, text)
	self:SetTitle(title)
	self.Text:SetWidth(self:GetWidth() - 40)
	self.Text:SetText(text)
	self:Show()
	self:SetHeight(145 + self.Text:GetHeight())
end

BattlePassPurchasePostDialogMixin = CreateFromMixins(BattlePassDialogMixin)

function BattlePassPurchasePostDialogMixin:OnLoad()
	BattlePassDialogMixin.OnLoad(self)

	self:SetTitle(BATTLEPASS_PURCHASE_SUCCESSFUL)
	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.PurchaseExperiencePost, self)
end

function BattlePassPurchasePostDialogMixin:ShowItemDialog(itemName, amount)
	self.Text:SetFormattedText(BATTLEPASS_PURCHASE_SUCCESSFUL_DIALOG, itemName)
	self:Show()
end

function BattlePassPurchasePostDialogMixin:OkClick(button)
	C_BattlePass.UsePurchasedItem()
	self:Hide()
end

BattlePassItemRewardFrameMixin = CreateFromMixins(PKBT_DialogMixin)

function BattlePassItemRewardFrameMixin:OnLoad()
	PKBT_DialogMixin.OnLoad(self)

	self.Background:SetTexture(0.110, 0.102, 0.098)
	self.Background:SetAlpha(0.95)

	self:SetTitle(BATTLEPASS_REWARD_TITLE)

	self.itemButtons = {}

	self.elapsed = 0
	self.animInOutTime = 0.5
	self.animHoldTime = 1.5

	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.ItemReward, self)
end

function BattlePassItemRewardFrameMixin:OnHide()
	self.elapsed = 0
end

function BattlePassItemRewardFrameMixin:OnUpdate(elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed <= self.animInOutTime then
		self:SetAlpha(outCubic(self.elapsed, 0, 1, self.animInOutTime))
	elseif self:IsMouseOver() then
		self.elapsed = self.animInOutTime
		self:SetAlpha(1)
	else
		local outDelay = self.animInOutTime + self.animHoldTime
		if self.elapsed <= outDelay then
			self:SetAlpha(1)
		elseif self.elapsed < outDelay + self.animInOutTime then
			self:SetAlpha(linear(self.elapsed - outDelay, 1, -1, self.animInOutTime))
		else
			self:Hide()
		end
	end
end

function BattlePassItemRewardFrameMixin:ShowItems(items)
	local BUTTON_FIRST_OFFSET_X = 14
	local BUTTON_FIRST_OFFSET_Y = 49
	local BUTTON_OFFSET_Y = 8

	local numItems = #items

	for index, itemData in ipairs(items) do
		local itemButton = self.itemButtons[index]
		if not itemButton then
			itemButton = CreateFrame("Frame", string.format("$parentItemPlate%u", index), self, "BattlePassItemPlateTemplate")

			if index == 1 then
				itemButton:SetPoint("TOPLEFT", BUTTON_FIRST_OFFSET_X, -BUTTON_FIRST_OFFSET_Y)
			else
				itemButton:SetPoint("TOPLEFT", self.itemButtons[index - 1], "BOTTOMLEFT", 0, -BUTTON_OFFSET_Y)
			end

			self.itemButtons[index] = itemButton
		end

		itemButton:SetItem(itemData.itemID, itemData.amount)
		itemButton:Show()
	end

	for index = numItems + 1, #self.itemButtons do
		self.itemButtons[index]:Hide()
	end

	if numItems > 0 then
		self:SetHeight(52 + self.itemButtons[1]:GetHeight() * numItems + 8 * (numItems - 1) + 10)

		if self:IsShown() then
			if self.elapsed > self.animInOutTime then
				self.elapsed = self.animInOutTime
				self:SetAlpha(1)
			end
		else
			self:Show()
		end
	else
		self:Hide()
	end
end

BattlePassItemPlateMixin = {}

function BattlePassItemPlateMixin:OnLoad()
	self.IconBorder:SetAtlas("PKBT-ItemBorder", true)
	self.IconHighlight:SetAtlas("PKBT-ItemBorder-Highlight", true)

	self.UpdateTooltip = self.OnEnter
end

function BattlePassItemPlateMixin:OnEnter()
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end
	CursorUpdate(self)
end

function BattlePassItemPlateMixin:OnLeave()
	if self.itemLink then
		GameTooltip_Hide()
	end
	ResetCursor()
end

function BattlePassItemPlateMixin:OnClick()
	if self.itemLink then
		HandleModifiedItemClick(self.itemLink)
	end
end

function BattlePassItemPlateMixin:SetItem(itemID, amount)
	local name, itemLink, rarity, _, _, _, _, _, _, icon = GetItemInfo(itemID)
	self.Icon:SetTexture(icon)
	self.Name:SetText(name)
	self.Name:SetTextColor(GetItemQualityColor(rarity))
	self.itemLink = itemLink
	self.hasItem = itemLink ~= nil

	if amount > 1 then
		self.Amount:SetText(amount)
		self.Amount:Show()
	else
		self.Amount:Hide()
	end
end

BattlePassAlertFrameMixin = {}

function BattlePassAlertFrameMixin:OnLoad()
	self:RegisterForClicks("RightButtonUp")

	self.Background:SetAtlas("PKBT-BattlePass-Alert-Background", true)
	self.IconBorder:SetAtlas("PKBT-ItemBorder", true)
	self.Glow:SetAtlas("loottoast-glow")

	self.queue = {}

	self:GetParent():RegisterDialogWidget(DIALOG_TYPE.ItemAlert, self)
end

function BattlePassAlertFrameMixin:OnShow()
	self.animIn:Play()
	self.Glow.animIn:Play()
	self.Shine.animIn:Play()
end

function BattlePassAlertFrameMixin:OnHide()
	self.animIn:Stop()
	self.waitAndAnimOut:Stop()

	self.Glow.animIn:Stop()
	self.Shine.animIn:Stop()

	if #self.queue ~= 0 then
		C_Timer:After(0.3, function()
			self:SetItem(unpack(table.remove(self.queue, 1)))
		end)
	end
end

function BattlePassAlertFrameMixin:OnClick(button)
	if button == "RightButton" then
		self:Hide()
	end
end

function BattlePassAlertFrameMixin:SetItem(itemName, icon, amount)
	if self:IsShown() or #self.queue ~= 0 then
		table.insert(self.queue, {itemName, icon, amount})
		return
	end

	self.ItemName:SetText(itemName)
	self.ItemIcon:SetTexture(icon)

	if amount > 1 then
		self.Amount:SetText(amount)
		self.Amount:Show()
	else
		self.Amount:Hide()
	end

	self:Show()
end