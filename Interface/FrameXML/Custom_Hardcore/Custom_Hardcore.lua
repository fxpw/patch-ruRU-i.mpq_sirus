local C_HardcoreSecure = C_HardcoreSecure

UIPanelWindows["HardcoreFrame"] = { area = "left", pushable = 0, whileDead = 1, width = 830, xOffset = "15", yOffset = "-10"}

HardcoreMixin = {}

function Hardcore_TabOnClick(self)
	Adventure_TabOnClick(self)

	if self:GetID() ~= 3 then
		HardcoreFrame:PlayStartButton()
	end
end

local function HardcoreCloseButton_OnClick(self)
	UIPanelCloseButton_OnClick(self)

	HardcoreFrame:PlayStartButton()
end

function HardcoreMixin:OnLoad()
	self.CloseButton:SetScript("OnClick", HardcoreCloseButton_OnClick)

	self.TitleText:SetText(HARDCORE_CHALLENGES_TITLE)
	SetPortraitToTexture(self.portrait,"Interface\\ICONS\\Achievement_General_ClassicBattles_64")

	self.panels = {
		[1] = {
			name = "SuggestFrame",
			navBarData = {
				name = HEADHUNTING_HOME,
				OnClick = function()
					self:SetTopTab(1)
				end,
			}
		},
		[2] = {
			name = "ChallengeListFrame",
			navBarData = {
				name = HARDCORE_CHALLENGES_LIST,
				OnClick = function()
					self:SetTopTab(2)
				end,
			}
		},
		[3] = {
			name = "ParticipantsFrame",
			navBarData = {
				name = HARDCORE_CHALLENGES_PARTICIPANTS_LIST,
				OnClick = function()
					self:SetTopTab(3)
				end,
			}
		},
		[4] = {
			name = "LadderFrame",
			navBarData = {
				name = LADDER,
				OnClick = function()
					self:SetTopTab(4)
				end,
			}
		},
	}

	NavBar_Initialize(self.navBar, "NavButtonTemplate", self.panels[1].navBarData, self.navBar.home, self.navBar.overflow)

	self.inset.Bgs:SetAtlas("UI-EJ-Cataclysm")
	self.inset.Bgs:SetAtlas("UI-EJ-BattleforAzeroth")

	self.tab1:SetFrameLevel(1)
	self.tab2:SetFrameLevel(1)
	self.tab3:SetFrameLevel(1)

	self.maxTabWidth = (self:GetWidth() - 19) / 3

	PanelTemplates_SetNumTabs(self, 3)

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterCustomEvent("HARDCORE_SELECTED_CHALLENGE")
	self:RegisterCustomEvent("SERVICE_DATA_UPDATE")
	self:RegisterCustomEvent("CUSTOM_CHALLENGE_ACTIVATED")
	self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")
end

function HardcoreMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "CINEMATIC_STOP" then
		if event == "PLAYER_ENTERING_WORLD" then
			if C_Service.IsHardcoreCharacter() and not C_Service.HasActiveChallenges() then
				self:SetAttribute("UIPanelLayout-neverAllowOtherPanels", 1)
				self:SetAttribute("UIPanelLayout-disableClosePanel", 1)
			end

			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			self:RegisterEvent("CINEMATIC_START")

			self.ticker = C_Timer:NewTicker(1.5, function()
				self:UnregisterEvent("CINEMATIC_START")
				self:RegisterEvent("CINEMATIC_STOP")
				self:FirstShow()
			end, 1)

			return
		end

		self:FirstShow()

		self:UnregisterEvent(event)
	elseif event == "HARDCORE_SELECTED_CHALLENGE" then
		if not self.navBarChanged then
			self:UpdateNavBar()
		end
	elseif event == "CUSTOM_CHALLENGE_ACTIVATED" then
		UpdateMicroButtons()

		self:SetAttribute("UIPanelLayout-neverAllowOtherPanels", nil)
		self:SetAttribute("UIPanelLayout-disableClosePanel", nil)
	elseif event == "SERVICE_DATA_UPDATE"
	or (event == "CUSTOM_CHALLENGE_DEACTIVATED" and select(2, ...) ~= Enum.HardcoreDeathReason.FAILED_DEATH)
	then
		UpdateMicroButtons()

		self:UpdateBottomTabs()
	end
end

function HardcoreMixin:OnShow()
	SetParentFrameLevel(self.inset)
	SetParentFrameLevel(self.SuggestFrame)

	PanelTemplates_SetTab(self, 3)

	if not self:GetSelectedTopTab() then
		self:SetTopTab(1)
	end
end

function HardcoreMixin:FirstShow()
	if not C_Service.IsHardcoreEnabledOnRealm() or not C_Service.IsHardcoreCharacter() or UnitIsDeadOrGhost("player") then return end

	if not CinematicFrame:IsShown() and not C_Service.HasActiveChallenges() then
		ShowUIPanel(self)
		PanelTemplates_SetTab(self, 3)
		self:SetTopTab(2)
	end
end

function HardcoreMixin:UpdateBottomTabs()
	if not C_Service.IsRenegadeRealm() then
		PanelTemplates_HideTab(self, 2)
		HardcoreFrameTab3:SetPoint("LEFT", HardcoreFrameTab1, "RIGHT", -16, 0)
	end
	if not C_Service.IsHardcoreEnabledOnRealm() then
		PanelTemplates_HideTab(self, 3)
	end
end

function HardcoreMixin:SetTopTab(id)
	self.selectedTopTab = id
	self:UpdateTopTabs()
	self:UpdateNavBar()
end

function HardcoreMixin:GetSelectedTopTab()
	return self.selectedTopTab
end

function HardcoreMixin:UpdateTopTabs()
	if self.selectedTopTab then
		for index, panelData in ipairs(self.panels) do
			local tab = self.TopTabs[index]
			if tab then
				if tab.isDisabled then
					tab:Disable()
				elseif index == self.selectedTopTab then
					tab:SetSelect()
				else
					tab:SetDeselect()
				end
			end

			self[panelData.name]:SetShown(index == self.selectedTopTab)
		end
	end
end

local function SetSelectChallenge(self, index, navBar)
	C_Hardcore.SetSelectChallenge(index)
end

local function GetHardcoreChallengeList(self, index)
	local _, name = C_Hardcore.GetChallengeInfo(index)
	return name, SetSelectChallenge
end

function HardcoreMixin:UpdateNavBar()
	self.navBarChanged = true

	local selectedTopTab = self:GetSelectedTopTab()

	NavBar_Reset(self.navBar)
	CloseDropDownMenus()

	if selectedTopTab == 1 then
		self.navBarChanged = nil
		return
	end

	NavBar_AddButton(self.navBar, self.panels[selectedTopTab].navBarData)

	if selectedTopTab == 2 then
		self.navBarChanged = nil
		return
	end

	local selectedChallengeID = C_Hardcore.GetSelectedChallenge()
	if not selectedChallengeID then
		SetSelectChallenge(nil, 1)
		selectedChallengeID = C_Hardcore.GetSelectedChallenge()
	end

	if selectedChallengeID then
		local buttonData = {
			name = C_Hardcore.GetChallengeInfoByID(selectedChallengeID),
			listFunc = GetHardcoreChallengeList,
		}
		NavBar_AddButton(self.navBar, buttonData)
	end

	self.navBarChanged = nil
end

function HardcoreMixin:PlayStartButton()
	if C_Service.IsHardcoreCharacter() and not C_Service.HasActiveChallenges() then
		local collapsedChallenge = self.ChallengeListFrame.ScrollFrame.collapsedChallenge
		if collapsedChallenge then
			local buttons = self.ChallengeListFrame.ScrollFrame.buttons
			local button = buttons[collapsedChallenge]

			if button then
				button.InfoFrame.RightFrame.StartButton.Glow.AlphaAnim:Stop()
				button.InfoFrame.RightFrame.StartButton.Glow.AlphaAnim:Play()
			end
		end
	end
end

HardcorePanelTopTabButton = {}

function HardcorePanelTopTabButton:OnLoad()
	self:SetParentArray("TopTabs")

	self.storedHeight = self:GetHeight()
	self:SetHeight(self.storedHeight - 4)
	self:SetWidth(max(self:GetTextWidth() + 20, 70))

	self.selectedGlow:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

function HardcorePanelTopTabButton:OnClick(button)
	self:GetParent():SetTopTab(self:GetID())
end

function HardcorePanelTopTabButton:OnEnable()
	self.leftSelect:Hide()
	self.midSelect:Hide()
	self.rightSelect:Hide()
	self:SetHeight(self.storedHeight - 4)
end

function HardcorePanelTopTabButton:OnDisable()
	self.leftSelect:Show()
	self.midSelect:Show()
	self.rightSelect:Show()
	self:SetHeight(self.storedHeight)
end

function HardcorePanelTopTabButton:SetSelect()
	self.ButtonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	self.selectedGlow:SetShown(true)
	self:SetEnabled(false)
end

function HardcorePanelTopTabButton:SetDeselect()
	self.ButtonText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	self.selectedGlow:SetShown(false)
	self:SetEnabled(true)
end

HardcoreSuggestFrameMixin = {}

function HardcoreSuggestFrameMixin:OnLoad()
	self.suggestions = {}

	self:RefreshDisplay()
end

function HardcoreSuggestFrameMixin:RefreshDisplay()
	C_Hardcore.GetSuggestions(self.suggestions)

	if #self.suggestions > 0 then
		local suggestion = self.Suggestion1
		local data = self.suggestions[1]

		suggestion.CenterDisplay.Title.Text:SetText(data.title)
		suggestion.CenterDisplay.Description.Text:SetText(data.description)
		SetPortraitToTexture(suggestion.Icon, data.iconPath)

		if data.buttonText and #data.buttonText > 0 then
			suggestion.CenterDisplay.SummaryFrame.Text:SetText(data.buttonText)
		end
	end

	if #self.suggestions > 1 then
		for i = 2, #self.suggestions do
			local suggestion = self["Suggestion"..i]
			if not suggestion then
				break
			end

			local data = self.suggestions[i]
			suggestion.CenterDisplay.Title.Text:SetText(data.title)
			suggestion.CenterDisplay.Description.Text:SetText(data.description ~= "" and data.description or " ")
			SetPortraitToTexture(suggestion.Icon, data.iconPath)

			if data.buttonText and #data.buttonText > 0 then
				suggestion.CenterDisplay.Button:SetText(data.buttonText)

				local btnWidth = max(suggestion.CenterDisplay.Button:GetTextWidth() + 42, 116)
				btnWidth = min(btnWidth, suggestion.CenterDisplay:GetWidth())
				suggestion.CenterDisplay.Button:SetWidth(btnWidth)
				suggestion.CenterDisplay.Button:Show()
			end
		end
	end
end

HardcoreChallengeInfoShadowMixin = {}

function HardcoreChallengeInfoShadowMixin:OnLoad()
	self.ShadowCornerTopLeft:SetAtlas("Custom-Challenges-Background-Shadow-CornerTopLeft", true)
	self.ShadowCornerBottomLeft:SetAtlas("Custom-Challenges-Background-Shadow-CornerBottomLeft", true)
	self.ShadowEdgeLeft:SetAtlas("Custom-Challenges-Background-Shadow-EdgeLeft", true)
	self.ShadowCornerTopRight:SetAtlas("Custom-Challenges-Background-Shadow-CornerTopRight", true)
	self.ShadowCornerBottomRight:SetAtlas("Custom-Challenges-Background-Shadow-CornerBottomRight", true)
	self.ShadowEdgeRight:SetAtlas("Custom-Challenges-Background-Shadow-EdgeRight", true)
	self.ShadowEdgeTop:SetAtlas("Custom-Challenges-Background-Shadow-EdgeTop", true)
	self.ShadowEdgeBottom:SetAtlas("Custom-Challenges-Background-Shadow-EdgeBottom", true)
end

HardcoreChallengeRewardButtonMixin = {}

function HardcoreChallengeRewardButtonMixin:OnLoad()
	self.IconBorder:SetAtlas("PKBT-ItemBorder")
end

function HardcoreChallengeRewardButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self.itemID then
		GameTooltip:SetHyperlink(string.format("item:%d", self.itemID))
	elseif self.achievementID then
		GameTooltip:SetHyperlink(string.format("achievement:%d:%s:0:0:0:0:0:0:0:0", self.achievementID, UnitGUID("player")))
	end
	GameTooltip:Show()
end

function HardcoreChallengeRewardButtonMixin:OnLeave()
	GameTooltip_Hide()
end

HardcoreChallengeInfoLeftFrameMixin = CreateFromMixins(HardcoreChallengeInfoShadowMixin)

local function IconButtonPool_ResetterFunc(framePool, frame)
	frame.itemID = nil
	frame.achievementID = nil
	frame:Hide()
	frame:ClearAllPoints()
end

function HardcoreChallengeInfoLeftFrameMixin:OnLoad()
	HardcoreChallengeInfoShadowMixin.OnLoad(self)

	self.ShadowCornerTopLeft:SetPoint("TOPLEFT", 0, -24)
	self.ShadowCornerTopRight:SetPoint("TOPRIGHT", 0, -24)

	self.Background:SetAtlas("Custom-Challenges-Challenge-Artwork-01", true)
	self.ShadowRight:SetAtlas("Custom-Challenges-Challenge-Artwork-Shadow", true)

	self.ScrollFrame.ScrollBar:SetBackgroundShown(false)

	self.iconButtonPool = CreateFramePool("Button", self.ScrollFrame.ScrollChild, "HardcoreChallengeIconButtonTemplate", IconButtonPool_ResetterFunc)
end

local htmlDotIcon = [[<img src='Interface/Scenarios/ScenarioIcon-Combat' align='left'/>]]
function HardcoreChallengeInfoLeftFrameMixin:OnTabChanged(tabID)
	local scrollChild = self.ScrollFrame.ScrollChild

	scrollChild.RewardText:SetShown(tabID == 1)

	self.iconButtonPool:ReleaseAll()

	if tabID == 1 then
		scrollChild.DescriptionText:SetText(C_Hardcore.GetChallengeDescriptionByID(self.challengeID))
		scrollChild.DescriptionText:Show()
		scrollChild.HTML:Hide()
		self:UpdateDescription()
	elseif tabID == 2 then
		local htmlContent = {}

		for _, restriction in ipairs(C_Hardcore.GetChallengeFeaturesByID(self.challengeID)) do
			table.insert(htmlContent, string.format("%s<p>|cff000000 |r|cff000000 |r|cff000000 |r|cff000000 |r|cff000000 |r<a href=\'desc:%s\'>%s</a></p>", htmlDotIcon, restriction.index, restriction.name))
		end
		for _, restriction in ipairs(C_Hardcore.GetChallengeFeatures1ByID(self.challengeID)) do
			table.insert(htmlContent, string.format("%s<p>|cff000000 |r|cff000000 |r|cff000000 |r|cff000000 |r|cff000000 |r<a href=\'desc:%s:1\'>%s</a></p>", htmlDotIcon, restriction.index, restriction.name))
		end

		scrollChild.HTML:SetText(string.format("<html><body>%s<br/></body></html>", table.concat(htmlContent, "<br/>")))
		scrollChild.HTML:Show()
		scrollChild.DescriptionText:Hide()
	elseif tabID == 3 then
		scrollChild.DescriptionText:SetText(C_Hardcore.GetChallengeFinishConditionsByID(self.challengeID))
		scrollChild.DescriptionText:Show()
		scrollChild.HTML:Hide()
	end

	self.activeTab = tabID
end

function HardcoreChallengeInfoLeftFrameMixin:Update(challengeID)
	self.challengeID = challengeID
end

local function GetAchievementTitle(rewardText)
	if rewardText and rewardText ~= "" then
		return string.match(rewardText, ACHIEVEMENT_REWARD_TITLE_PATTERN)
	end
end

function HardcoreChallengeInfoLeftFrameMixin:UpdateDescription()
	local scrollChild = self.ScrollFrame.ScrollChild

	local lastIconButton

	local rewards = C_Hardcore.GetChallengeRewardsByID(self.challengeID)
	for index, itemID in ipairs(rewards) do
		local rewardButton = self.iconButtonPool:Acquire()
		local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID)

		rewardButton.Icon:SetTexture(icon)
		rewardButton.Name:SetText(name)
		rewardButton.Name:SetTextColor(GetItemQualityColor(quality or 1))

		if index == 1 then
			rewardButton:SetPoint("TOPLEFT", self.ScrollFrame.ScrollChild.RewardText, "BOTTOMLEFT", 0, -10)
		else
			rewardButton:SetPoint("TOPLEFT", lastIconButton, "BOTTOMLEFT", 0, 0)
		end

		rewardButton.itemID = itemID
		rewardButton:Show()

		lastIconButton = rewardButton
	end

	local _, _, _, achievementID = C_Hardcore.GetChallengeInfoByID(self.challengeID)
	if achievementID then
		local achievementButton = self.iconButtonPool:Acquire()
		local _, name, _, _, _, _, _, _, _, icon, rewardText = GetAchievementInfo(achievementID)

		achievementButton.Icon:SetTexture(icon)

		local achievementTitle = GetAchievementTitle(rewardText)
		if achievementTitle then
			achievementButton.Name:SetFormattedText(HARDCORE_ACHIEVEMENT_TITLE_TEXT, name or "", achievementTitle)
		else
			achievementButton.Name:SetFormattedText(HARDCORE_ACHIEVEMENT_TEXT, name or "")
		end

		achievementButton.Name:SetTextColor(1, 1, 1, 1)

		achievementButton.achievementID = achievementID
		achievementButton:Show()

		if not lastIconButton then
			achievementButton:SetPoint("TOPLEFT", self.ScrollFrame.ScrollChild.RewardText, "BOTTOMLEFT", 0, -10)
		else
			achievementButton:SetPoint("TOPLEFT", lastIconButton, "BOTTOMLEFT", 0, 0)
		end
	end

	if #rewards == 0 and not achievementID then
		scrollChild.RewardText:Hide()
	end
end

function HardcoreChallengeInfoLeftFrameMixin:Reset()
	self.iconButtonPool:ReleaseAll()
	self.activeTab = nil
	self.challengeID = nil
end

HardcoreChallengeInfoRightTabButtonMixin = {}

function HardcoreChallengeInfoRightTabButtonMixin:OnLoad()
	self:SetParentArray("Tabs")

	self.Right:SetAtlas("Custom-Challenges-Border-MiddleTabButton-Right", true)
	self.Center:SetAtlas("Custom-Challenges-Border-MiddleTabButton-Center", true)
	self.SelectedGlow:SetAtlas("Custom-Challenges-Border-MiddleTabButton-Right-Selected", true)
end

function HardcoreChallengeInfoRightTabButtonMixin:OnClick()
	self:GetParent():GetParent():SetSelectTab(self:GetID())
end

function HardcoreChallengeInfoRightTabButtonMixin:SetSelected(selected)
	self.SelectedGlow:SetShown(selected)
end

HardcoreChallengeInfoRightFrameMixin = CreateFromMixins(HardcoreChallengeInfoShadowMixin)

function HardcoreChallengeInfoRightFrameMixin:OnLoad()
	HardcoreChallengeInfoShadowMixin.OnLoad(self)

	self.StartButton.Glow.Left:SetAtlas("PKBT-Button-Glow-Left", true)
	self.StartButton.Glow.Right:SetAtlas("PKBT-Button-Glow-Right", true)
	self.StartButton.Glow.Center:SetAtlas("PKBT-Button-Glow-Center")

	self.Background:SetAtlas("Custom-Challenges-Background-WoodTile")
end

function HardcoreChallengeInfoRightFrameMixin:OnHide()
	HardcoreConfirmChallengeFrame:Hide()
end

function HardcoreChallengeInfoRightFrameMixin:Update(challengeID)
	self.challengeID = challengeID
	self.StartButton.challengeID = challengeID
	self.StartButton.disabledReason = nil

	if C_Service.IsHardcoreCharacter() then
		if C_Service.HasActiveChallenges() then
			if C_Service.IsChallengeActive(challengeID) then
				-- enable disable challenge
				if not UnitIsDeadOrGhost("player") then
					self.StartButton:Enable()
				else
					self.StartButton.disabledReason = 2
					self.StartButton:Disable()
				end
				self.StartButton:SetText(HARDCORE_CANCEL_CHALLENGE)
			else
				-- disable active challenge
				self.StartButton.disabledReason = 1
				self.StartButton:Disable()
				self.StartButton:SetText(HARDCORE_START_CHALLENGE)
			end
		else
			-- enable start challenge
			if UnitLevel("player") == 1 and not UnitIsDeadOrGhost("player") then
				self.StartButton:Enable()
			else
				self.StartButton.disabledReason = 3
				self.StartButton:Disable()
			end
			self.StartButton:SetText(HARDCORE_START_CHALLENGE)
		end
	else
		self.StartButton.disabledReason = 4
		self.StartButton:Disable()
		self.StartButton:SetText(HARDCORE_START_CHALLENGE)
	end
end

function HardcoreChallengeInfoRightFrameMixin:Reset()
	self.challengeID = nil
end

function HardcoreChallengeInfoRightFrameMixin:OnTabChanged(tabID)
	local selectedTabButton = nil
	for _, tabButton in ipairs(self.Tabs) do
		if tabButton:GetID() == tabID then
			tabButton:SetSelected(true)
			selectedTabButton = tabButton
		else
			tabButton:SetSelected(false)
		end
	end

	local infoFrame = self:GetParent()
	if selectedTabButton then
		infoFrame.Border.TabLeft:Show()
		infoFrame.Border.TabLeft:ClearAllPoints()
		infoFrame.Border.TabLeft:SetPoint("BOTTOMLEFT", 504, select(2, selectedTabButton:GetRect()) - select(2, infoFrame.Border.BridgeBottom:GetRect()) - 6)
	else
		infoFrame.Border.TabLeft:Hide()
	end
end

HardcoreChallengeInfoFrameMixin = {}

function HardcoreChallengeInfoFrameMixin:OnLoad()

end

function HardcoreChallengeInfoFrameMixin:SetSelectTab(tabID)
	if self.activeTab ~= tabID then
		self.LeftFrame:OnTabChanged(tabID)
		self.RightFrame:OnTabChanged(tabID)
		self.activeTab = tabID
	end
end

function HardcoreChallengeInfoFrameMixin:Update(challengeID)
	self.LeftFrame:Update(challengeID)
	self.RightFrame:Update(challengeID)

	self:SetSelectTab(1)
end

function HardcoreChallengeInfoFrameMixin:Reset()
	self.activeTab = nil
	self.LeftFrame:Reset()
	self.RightFrame:Reset()
end

local CHALLENGE_FRAME_INIT_XOFFSET = 4
local CHALLENGE_FRAME_INIT_YOFFSET = -12
local CHALLENGE_FRAME_COLLAPSED_HEIGHT = 82
local CHALLENGE_FRAME_EXPANDED_HEIGHT = 82 + 306 - 20

HardcoreChallengeFrameButtonMixin = {}

function HardcoreChallengeFrameButtonMixin:OnLoad()
	self.IconBorder:SetAtlas("PKBT-ItemBorder-Normal")
	self.LeftShadow:SetAtlas("Custom-Challenges-Challenge-Shadow-Left")

	self.BorderLeft:SetAtlas("Custom-Challenges-Challenge-Button-Left")
	self.BorderRight:SetAtlas("Custom-Challenges-Challenge-Button-Right")
	self.BorderMiddle:SetAtlas("Custom-Challenges-Challenge-Button-Middle")
end

function HardcoreChallengeFrameButtonMixin:OnClick()
	local frame = self:GetParent()
	local index = frame.index
	local scrollFrame = frame:GetOwner()

	HelpTip:Hide(scrollFrame)

	if scrollFrame.collapsedChallenge and not frame.isCollapsed then
		frame:Collapse()
		HybridScrollFrame_CollapseButton(scrollFrame)
		scrollFrame.collapsedChallenge = nil
	else
		scrollFrame.collapsedChallenge = index
		C_Hardcore.SetSelectChallenge(index)

		frame:Expand()
		HybridScrollFrame_ExpandButton(scrollFrame, (index - 1) * CHALLENGE_FRAME_COLLAPSED_HEIGHT, frame:GetHeight())
	end

	scrollFrame.update()
end

HardcoreChallengeFrameMixin = CreateFromMixins(PKBT_OwnerMixin)

function HardcoreChallengeFrameMixin:OnLoad()
	self.isCollapsed = true
end

function HardcoreChallengeFrameMixin:Collapse()
	if self.isCollapsed then return end

	self.InfoFrame:Hide()
	self.InfoFrame:Reset()
	self:SetHeight(CHALLENGE_FRAME_COLLAPSED_HEIGHT)

	self.isCollapsed = true
end

function HardcoreChallengeFrameMixin:Expand()
	if not self.isCollapsed then return end

	self.InfoFrame:Show()
	self:SetHeight(CHALLENGE_FRAME_EXPANDED_HEIGHT)
	self:Update()

	self.isCollapsed = nil
end

function HardcoreChallengeFrameMixin:Update()
	local id, name, icon = C_Hardcore.GetChallengeInfo(self.index)

	self.challengeID = id

	self.Button.Name:SetText(name)
	self.Button.Icon:SetTexture(icon)

	if self.InfoFrame then
		if not self.isCollapsed then
			self.InfoFrame:Update(id)
		end
	end
end

function HardcoreChallengeFrameMixin:Reset()
	self.challengeID = nil
	if self.InfoFrame then
		self.InfoFrame:Reset()
	end
end

HardcoreChallengeListMixin = {}

function HardcoreChallengeListMixin:OnLoad()
	self.ScrollFrame.update = function() self:Refresh() end

	self.ScrollFrame.scrollBar.trackBG:Hide()
	HybridScrollFrame_CreateButtons(self.ScrollFrame, "HardcoreChallengeFrameTemplate", CHALLENGE_FRAME_INIT_XOFFSET, CHALLENGE_FRAME_INIT_YOFFSET)
	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true)

	for _, button in ipairs(self.ScrollFrame.buttons) do
		button:SetOwner(self.ScrollFrame)
	end

	self.ScrollFrame.collapsedChallenge = C_Hardcore.GetSelectedChallenge()

	self:RegisterCustomEvent("CUSTOM_CHALLENGE_ACTIVATED")
	self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")
end

function HardcoreChallengeListMixin:OnShow()
	self:Refresh()
end

function HardcoreChallengeListMixin:OnEvent(event)
	if event == "CUSTOM_CHALLENGE_ACTIVATED" or event == "CUSTOM_CHALLENGE_DEACTIVATED" then
		self:Refresh()
	end
end

function HardcoreChallengeListMixin:Refresh()
	local numChallenges = C_Hardcore.GetNumChallenges()

	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
	local buttonCount = #buttons

	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame)
	local displayedHeight = 0

	if C_Service.IsHardcoreCharacter() and not C_Service.HasActiveChallenges() and not C_Hardcore.GetSelectedChallenge() then
		local helpTipInfo = {
			text = HARDCORE_SELECT_CHALLENGE_HELPTIP_TEXT,
			textJustifyH = "CENTER",
			offsetX = 0,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
		}
		HelpTip:Show(self.ScrollFrame, helpTipInfo, HardcoreFrame.ChallengeListFrame.ScrollFrame.buttons[1])
	end

	local collapsedIndex = self.ScrollFrame.collapsedChallenge
	local extraHeight = self.ScrollFrame.largeButtonHeight or CHALLENGE_FRAME_COLLAPSED_HEIGHT

	for i = 1, buttonCount do
		local frame = buttons[i]
		local index = offset + i

		if index <= numChallenges then
			frame.index = index

			if index == collapsedIndex then
				frame:Expand()
			elseif not frame.isCollapsed then
				frame:Collapse()
			end

			frame:Update()

			frame:Show()

			displayedHeight = displayedHeight + frame:GetHeight()
		else
			frame:Reset()
			frame:Hide()
		end
	end

	local totalHeight = (numChallenges * CHALLENGE_FRAME_COLLAPSED_HEIGHT) + 12
	totalHeight = totalHeight + (extraHeight - CHALLENGE_FRAME_COLLAPSED_HEIGHT)

	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight)

	if collapsedIndex then
		self.ScrollFrame.collapsedChallenge = collapsedIndex
	else
		HybridScrollFrame_CollapseButton(self.ScrollFrame)
	end
end

HardcoreTableEntryButtonMixin = CreateFromMixins(TableBuilderCellMixin)

function HardcoreTableEntryButtonMixin:Populate(rowData, dataIndex)
	self.Background:SetShown(dataIndex % 2 ~= 0)
end

HardcoreTableCellStringMixin = CreateFromMixins(TableBuilderCellMixin)

function HardcoreTableCellStringMixin:Init(dataProviderKey)
	self.dataProviderKey = dataProviderKey
end

function HardcoreTableCellStringMixin:Populate(rowData, dataIndex)
	local value = rowData[self.dataProviderKey]
	self.Text:SetText(value or "?")
end

HardcoreTableIconCellStringMixin = CreateFromMixins(HardcoreTableCellStringMixin)

function HardcoreTableIconCellStringMixin:Populate(rowData, dataIndex)
	local classInfo = C_CreatureInfo.GetClassInfo(rowData.class or 1)

	SetPortraitToTexture(self.Icon, string.format("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_%s", string.upper(classInfo.classFile)))
end

HardcoreTableIconTextCellStringMixin = CreateFromMixins(HardcoreTableCellStringMixin)

function HardcoreTableIconTextCellStringMixin:Populate(rowData, dataIndex)
	local classInfo = C_CreatureInfo.GetClassInfo(rowData.class or 1)
	local raceInfo = C_CreatureInfo.GetRaceInfo(rowData.race or 1)

	local name = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(rowData.name or "?")
	self.Text:SetText(name)
	local raceIconAtlas = string.format("RACE_ICON_%s_%s", string.upper(raceInfo.clientFileString), S_GENDER_FILESTRING[rowData.gender == 0 and 0 or 1])
	self.Icon:SetAtlas(raceIconAtlas)
end

HardcoreTableLevelCellStringMixin = CreateFromMixins(HardcoreTableCellStringMixin)

function HardcoreTableLevelCellStringMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.level)
end

HardcoreLadderTableTimeCellStringMixin = CreateFromMixins(HardcoreTableCellStringMixin)

function HardcoreLadderTableTimeCellStringMixin:Populate(rowData, dataIndex)
	self.Text:SetText(SecondsToTime(rowData.time or 0))
end

HardcoreTableStatusCellStringMixin = CreateFromMixins(HardcoreTableCellStringMixin)

function HardcoreTableStatusCellStringMixin:Populate(rowData, dataIndex)
	if rowData.status == Enum.Hardcore.Status.Failed then
		self.Texture:SetTexture("Interface\\FriendsFrame\\StatusIcon-Offline")
		self.Text:SetText(HARDCORE_CHALLENGE_STATUS_1)
	elseif rowData.status == Enum.Hardcore.Status.InProgress then
		self.Texture:SetTexture("Interface\\FriendsFrame\\StatusIcon-Away")
		self.Text:SetText(HARDCORE_CHALLENGE_STATUS_2)
	elseif rowData.status == Enum.Hardcore.Status.Completed then
		self.Texture:SetTexture("Interface\\FriendsFrame\\StatusIcon-Online")
		self.Text:SetText(HARDCORE_CHALLENGE_STATUS_3)
	end
end

HardcoreTableHeaderStringMixin = CreateFromMixins(TableBuilderElementMixin)

function HardcoreTableHeaderStringMixin:OnLoad()
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("LEFT", self.Text, "RIGHT", 3, 0)
	self.Arrow:SetAtlas("auctionhouse-ui-sortarrow", true)

	self:SetParentArray("headers")
end

local SortOrderState = tInvert({
	"None",
	"PrimarySorted",
	"PrimaryReversed",
})

function HardcoreTableHeaderStringMixin:OnClick()
	for _, header in ipairs(self:GetParent().headers) do
		if header ~= self then
			header.sortState = SortOrderState.None
		end

		header:UpdateArrow()
	end
end

function HardcoreTableHeaderStringMixin:Init(headerText, sortIndex)
	self:SetText(headerText)

	self:SetEnabled(sortIndex ~= nil)
	self.sortIndex = sortIndex

	if sortIndex ~= nil then
		self:UpdateArrow()
	else
		self.Arrow:Hide()
	end
end

function HardcoreTableHeaderStringMixin:UpdateArrow()
	self:SetArrowState(self.sortState)
end

function HardcoreTableHeaderStringMixin:SetArrowState(sortOrderState)
	self.Arrow:SetShown(sortOrderState == SortOrderState.PrimarySorted or sortOrderState == SortOrderState.PrimaryReversed)
	self.Arrow:SetTexCoord(0.987305, 0.996094, 0.0253906, 0.0341797)

	if sortOrderState == AuctionHouseSortOrderState.PrimarySorted then
		self.Arrow:SetSubTexCoord(0, 1, 1, 0)
	elseif sortOrderState == AuctionHouseSortOrderState.PrimaryReversed then
		self.Arrow:SetSubTexCoord(0, 1, 0, 1)
	end
end

local function GetHeaderNameFromSortOrder(sortIndex)
	if sortIndex == Enum.Hardcore.SortOrder.Name then
		return HARDCORE_HEADER_COLUMN_PLAYER
	elseif sortIndex == Enum.Hardcore.SortOrder.Class then
		return HARDCORE_HEADER_COLUMN_CLASS
	elseif sortIndex == Enum.Hardcore.SortOrder.Level then
		return HARDCORE_HEADER_COLUMN_LEVEL
	elseif sortIndex == Enum.Hardcore.SortOrder.Time then
		return HARDCORE_HEADER_COLUMN_TIME
	elseif sortIndex == Enum.Hardcore.SortOrder.Status then
		return HARDCORE_HEADER_COLUMN_STATUS
	else
		return ""
	end
end

HardcoreTableBuilderMixin = {}

function HardcoreTableBuilderMixin:AddColumnInternal(sortIndex, headerTemplate, cellTemplate, ...)
	local column = self:AddColumn()
	if sortIndex then
		column:ConstructHeader("Button", headerTemplate or "HardcoreTableHeaderStringTemplate", GetHeaderNameFromSortOrder(sortIndex), sortIndex)
	end
	column:ConstructCells("Frame", cellTemplate or "HardcoreTableCellTemplate", ...)
	return column
end

function HardcoreTableBuilderMixin:AddUnsortableColumnInternal(headerText, headerTemplate, cellTemplate, ...)
	local column = self:AddColumn()
	local sortIndex = nil
	column:ConstructHeader("Button", headerTemplate or "HardcoreTableHeaderStringTemplate", headerText, sortIndex)
	column:ConstructCells("Frame", cellTemplate or "HardcoreTableCellTemplate", ...)
	return column
end

function HardcoreTableBuilderMixin:AddFixedWidthColumn(padding, width, leftCellPadding, rightCellPadding, sortIndex, headerTemplate, cellTemplate, ...)
	local column = self:AddColumnInternal(sortIndex, headerTemplate, cellTemplate, ...)
	column:SetFixedConstraints(width, padding)
	column:SetCellPadding(leftCellPadding, rightCellPadding)
	return column
end

function HardcoreTableBuilderMixin:AddFillColumn(padding, fillCoefficient, leftCellPadding, rightCellPadding, sortIndex, headerTemplate, cellTemplate, ...)
	local column = self:AddColumnInternal(sortIndex, headerTemplate, cellTemplate, ...)
	column:SetFillConstraints(fillCoefficient, padding)
	column:SetCellPadding(leftCellPadding, rightCellPadding)
	return column
end

HardcoreTableBuilder = {}

function HardcoreTableBuilder.GetDefaultLayout(frame, isParticipants)
	if isParticipants then
		local function LayoutTableBuilder(tableBuilder)
			tableBuilder:SetColumnHeaderOverlap(2)
			tableBuilder:SetHeaderContainer(frame.HeaderContainer)

			tableBuilder:AddFillColumn(0, 1, 10, 0, Enum.Hardcore.SortOrder.Name, "HardcoreParticipantsTableHeaderStringTemplate", "HardcoreTableIconTextCellTemplate")
			tableBuilder:AddFixedWidthColumn(0, 64, -2, 0, Enum.Hardcore.SortOrder.Class, "HardcoreParticipantsTableHeaderStringTemplate", "HardcoreTableIconCellTemplate")
			tableBuilder:AddFixedWidthColumn(0, 80, 5, 0, Enum.Hardcore.SortOrder.Level, "HardcoreParticipantsTableHeaderStringTemplate", "HardcoreTableLevelCellTemplate")
		end

		return LayoutTableBuilder
	else
		local function LayoutTableBuilder(tableBuilder)
			tableBuilder:SetColumnHeaderOverlap(2)
			tableBuilder:SetHeaderContainer(frame.HeaderContainer)

			tableBuilder:AddFillColumn(0, 1, 10, 0, Enum.Hardcore.SortOrder.Name, "HardcoreLadderTableHeaderStringTemplate", "HardcoreTableIconTextCellTemplate")
			tableBuilder:AddFixedWidthColumn(0, 64, -2, 0, Enum.Hardcore.SortOrder.Class, "HardcoreLadderTableHeaderStringTemplate", "HardcoreTableIconCellTemplate")
			tableBuilder:AddFixedWidthColumn(0, 80, 5, 0, Enum.Hardcore.SortOrder.Level, "HardcoreLadderTableHeaderStringTemplate", "HardcoreTableLevelCellTemplate")
			tableBuilder:AddFixedWidthColumn(0, 120, 5, 0, Enum.Hardcore.SortOrder.Time, "HardcoreLadderTableHeaderStringTemplate", "HardcoreTableTimeCellTemplate")
			tableBuilder:AddFixedWidthColumn(0, 100, 0, 0, Enum.Hardcore.SortOrder.Status, "HardcoreLadderTableHeaderStringTemplate", "HardcoreTableStatusCellTemplate")
		end

		return LayoutTableBuilder
	end
end

HardcoreParticipantsTableHeaderStringMixin = CreateFromMixins(HardcoreTableHeaderStringMixin)

function HardcoreParticipantsTableHeaderStringMixin:Init(headerText, sortIndex)
	self:SetText(headerText)

	self:SetEnabled(sortIndex ~= nil)
	self.sortIndex = sortIndex

	if sortIndex ~= nil then
		local challengeID = C_Hardcore.GetSelectedChallenge()
		if challengeID then
			local currentSortIndex, reverseSort = C_Hardcore.GetSortParticipants(challengeID)
			if currentSortIndex == self.sortIndex then
				self.sortState = not reverseSort and SortOrderState.PrimarySorted or SortOrderState.PrimaryReversed
			end
		end

		self:UpdateArrow()
	else
		self.Arrow:Hide()
	end
end

function HardcoreParticipantsTableHeaderStringMixin:OnClick(button)
	if self.sortIndex then
		local challengeID = C_Hardcore.GetSelectedChallenge()
		if challengeID then
			local _, reverseSort = C_Hardcore.GetSortParticipants(challengeID)
			C_Hardcore.SetSortParticipants(challengeID, self.sortIndex, not reverseSort)
			self.sortState = reverseSort and SortOrderState.PrimarySorted or SortOrderState.PrimaryReversed

			HardcoreTableHeaderStringMixin.OnClick(self, button)
		end
	end
end

HardcoreParticipantsMixin = {}

function HardcoreParticipantsMixin:OnLoad()
	self.ScrollFrame.scrollBar.trackBG:Hide()

	self.ScrollFrame.update = function() self:Refresh() end

	HybridScrollFrame_CreateButtons(self.ScrollFrame, "HardcoreTableEntryButtonTemplate", 0, -2, nil, nil, nil, -2)
	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true)

	self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.ScrollFrame), HardcoreTableBuilderMixin)

	UIDropDownMenu_SetInitializeFunction(self.FilterDropDown, function(_, level) self:FilterDropDownInit(level) end)
	UIDropDownMenu_SetDisplayMode(self.FilterDropDown, "MENU")
	self.FilterButton:SetResetFunction(function() self:ResetFilters() end)

	self:RegisterCustomEvent("HARDCORE_SELECTED_CHALLENGE")
	self:RegisterCustomEvent("HARDCORE_PARTICIPANTS_UPDATE")
end

function HardcoreParticipantsMixin:OnShow()
	self:SetDataProvider()
	self:Refresh()
end

function HardcoreParticipantsMixin:OnEvent(event)
	if not self:IsShown() then return end

	if event == "HARDCORE_SELECTED_CHALLENGE" or event == "HARDCORE_PARTICIPANTS_UPDATE" then
		self:SetDataProvider()
		self:Refresh()
	end
end

function HardcoreParticipantsMixin:SetDataProvider()
	local challengeID = C_Hardcore.GetSelectedChallenge()

	if self.challengeID ~= challengeID then
		local function GetEntry(index)
			return C_Hardcore.GetParticipantsEntry(challengeID, index)
		end

		self.tableBuilder:Reset()
		self.tableBuilder:SetDataProvider(GetEntry)
		self.tableBuilder:SetTableWidth(self.ScrollFrame:GetWidth())
		HardcoreTableBuilder.GetDefaultLayout(self, true)(self.tableBuilder)
		self.tableBuilder:Arrange()

		self.challengeID = challengeID
	end
end

function HardcoreParticipantsMixin:Refresh()
	if not self.challengeID then
		self.ScrollFrame:Hide()
		return
	end

	self.ScrollFrame:Show()

	local numEntries = C_Hardcore.GetNumParticipantsEntries(self.challengeID)

	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
	local buttonCount = #buttons
	local buttonHeight = buttons[1]:GetHeight()

	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame)
	local populateCount = math.min(buttonCount, numEntries)
	self.tableBuilder:Populate(offset, populateCount)

	for i = 1, buttonCount do
		buttons[i]:SetShown(i <= numEntries)
	end

	local totalHeight = numEntries * buttonHeight
	local displayedHeight = populateCount * buttonHeight
	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight)
end

function HardcoreParticipantsMixin:ResetFilters()
	C_Hardcore.SetParticipantsDefaultFilters()
	self.FilterButton.ResetButton:Hide()
	self.SearchFrame:Reset()
	self.LevelRangeFrame:Reset()
	self:Refresh()
end

function HardcoreParticipantsMixin:UpdateResetFiltersButtonVisibility()
	self.FilterButton.ResetButton:SetShown(not C_Hardcore.IsUsingParticipantsDefaultFilters())
end

function HardcoreParticipantsMixin:SetAllStatusChecked(checked)
	C_Hardcore.SetAllParticipantsStatusFilters(checked)
	UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
end

function HardcoreParticipantsMixin:SetAllClassChecked(checked)
	C_Hardcore.SetAllParticipantsClassFilters(checked)
	UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
end

function HardcoreParticipantsMixin:FilterDropDownInit(level)
	local filterSystem = {
		onUpdate = function() self:UpdateResetFiltersButtonVisibility() end,
		filters = {
			{ type = FilterComponent.Title, text = HARDCORE_CHALLENGE_FILTER_SEARCH },
			{ type = FilterComponent.CustomFrame, key = "SearchFrame" },
			{ type = FilterComponent.Space },
			{ type = FilterComponent.Title, text = HARDCORE_CHALLENGE_FILTER_LEVEL },
			{ type = FilterComponent.CustomFrame, key = "LevelRangeFrame" },
			{ type = FilterComponent.Space },
			{ type = FilterComponent.Submenu, text = HARDCORE_CHALLENGE_FILTER_CLASS, value = 1, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() self:SetAllClassChecked(true) end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() self:SetAllClassChecked(false) end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_Hardcore.SetParticipantsClassFilter,
						  isSet = C_Hardcore.IsParticipantsClassChecked,
						  numFilters = GetNumClasses,
						  filterValidation = C_Hardcore.IsValidParticipantsClassFilter,
						  nameFunction = GetClassInfo,
						},
					},
				},
			},
		}
	}

	FilterDropDownSystem.Initialize(self, filterSystem, level)
end

HardcoreParticipantsSearchFrameMixin = CreateFromMixins(UIDropDownCustomMenuEntryMixin)

function HardcoreParticipantsSearchFrameMixin:Reset()
	self.SearchBox:SetText("")
end

function HardcoreParticipantsSearchFrameMixin:OnTextChanged()
	C_Hardcore.SetParticipantsSearch(self.SearchBox:GetText() or "")
end

HardcoreParticipantsLevelRangeFrameMixin = CreateFromMixins(UIDropDownCustomMenuEntryMixin)

function HardcoreParticipantsLevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("")
	self.MaxLevel:SetText("")
end

function HardcoreParticipantsLevelRangeFrameMixin:OnTextChanged()
	local minLevel, maxLevel = self.MinLevel:GetNumber(), self.MaxLevel:GetNumber()

	if maxLevel ~= 0 and minLevel > maxLevel then
		self.MinLevel:SetNumber(maxLevel)
	end

	C_Hardcore.SetParticipantsLevelFilter(self.MinLevel:GetNumber(), self.MaxLevel:GetNumber())
end

HardcoreLadderTableHeaderStringMixin = CreateFromMixins(HardcoreTableHeaderStringMixin)

function HardcoreLadderTableHeaderStringMixin:Init(headerText, sortIndex)
	self:SetText(headerText)

	self:SetEnabled(sortIndex ~= nil)
	self.sortIndex = sortIndex

	if sortIndex ~= nil then
		local challengeID = C_Hardcore.GetSelectedChallenge()
		if challengeID then
			local currentSortIndex, reverseSort = C_Hardcore.GetSortLeaderboard(challengeID)
			if currentSortIndex == self.sortIndex then
				self.sortState = not reverseSort and SortOrderState.PrimarySorted or SortOrderState.PrimaryReversed
			end
		end

		self:UpdateArrow()
	else
		self.Arrow:Hide()
	end
end

function HardcoreLadderTableHeaderStringMixin:OnClick(button)
	if self.sortIndex then
		local challengeID = C_Hardcore.GetSelectedChallenge()
		if challengeID then
			local _, reverseSort = C_Hardcore.GetSortLeaderboard(challengeID)
			C_Hardcore.SetSortLeaderboard(challengeID, self.sortIndex, not reverseSort)
			self.sortState = reverseSort and SortOrderState.PrimarySorted or SortOrderState.PrimaryReversed

			HardcoreTableHeaderStringMixin.OnClick(self, button)
		end
	end
end

HardcoreLadderMixin = {}

function HardcoreLadderMixin:OnLoad()
	self.ScrollFrame.scrollBar.trackBG:Hide()

	self.ScrollFrame.update = function() self:Refresh() end

	HybridScrollFrame_CreateButtons(self.ScrollFrame, "HardcoreTableEntryButtonTemplate", 0, -2, nil, nil, nil, -2)
	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true)

	self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.ScrollFrame), HardcoreTableBuilderMixin)

	UIDropDownMenu_SetInitializeFunction(self.FilterDropDown, function(_, level) self:FilterDropDownInit(level) end)
	UIDropDownMenu_SetDisplayMode(self.FilterDropDown, "MENU")
	self.FilterButton:SetResetFunction(function() self:ResetFilters() end)

	self:RegisterCustomEvent("HARDCORE_SELECTED_CHALLENGE")
	self:RegisterCustomEvent("HARDCORE_LADDER_UPDATE")
end

function HardcoreLadderMixin:OnShow()
	self:SetDataProvider()
	self:Refresh()
end

function HardcoreLadderMixin:OnEvent(event)
	if not self:IsShown() then return end

	if event == "HARDCORE_SELECTED_CHALLENGE" or event == "HARDCORE_LADDER_UPDATE" then
		self:UpdateResetFiltersButtonVisibility()

		self:SetDataProvider()
		self:Refresh()
	end
end

function HardcoreLadderMixin:SetDataProvider()
	local challengeID = C_Hardcore.GetSelectedChallenge()

	if self.challengeID ~= challengeID then
		local function GetEntry(index)
			return C_Hardcore.GetLeaderboardEntry(challengeID, index)
		end

		self.tableBuilder:Reset()
		self.tableBuilder:SetDataProvider(GetEntry)
		self.tableBuilder:SetTableWidth(self.ScrollFrame:GetWidth())
		HardcoreTableBuilder.GetDefaultLayout(self)(self.tableBuilder)
		self.tableBuilder:Arrange()

		self.challengeID = challengeID
	end
end

function HardcoreLadderMixin:Refresh()
	if not self.challengeID then
		self.ScrollFrame:Hide()
		return
	end

	self.ScrollFrame:Show()

	local numEntries = C_Hardcore.GetNumLeaderboardEntries(self.challengeID)

	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
	local buttonCount = #buttons
	local buttonHeight = buttons[1]:GetHeight()

	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame)
	local populateCount = math.min(buttonCount, numEntries)
	self.tableBuilder:Populate(offset, populateCount)

	for i = 1, buttonCount do
		buttons[i]:SetShown(i <= numEntries)
	end

	local totalHeight = numEntries * (buttonHeight + 2)
	local displayedHeight = populateCount * (buttonHeight + 2)
	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight)
end

function HardcoreLadderMixin:ResetFilters()
	C_Hardcore.SetLeaderboardDefaultFilters()
	self.FilterButton.ResetButton:Hide()
	self.SearchFrame:Reset()
	self.LevelRangeFrame:Reset()
	self:Refresh()
end

function HardcoreLadderMixin:UpdateResetFiltersButtonVisibility()
	self.FilterButton.ResetButton:SetShown(not C_Hardcore.IsUsingLeaderboardDefaultFilters())
end

function HardcoreLadderMixin:SetAllStatusChecked(checked)
	C_Hardcore.SetAllLeaderboardStatusFilters(checked)
	UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
end

function HardcoreLadderMixin:SetAllClassChecked(checked)
	C_Hardcore.SetAllLeaderboardClassFilters(checked)
	UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL)
end

function HardcoreLadderMixin:FilterDropDownInit(level)
	local filterSystem = {
		onUpdate = function() self:UpdateResetFiltersButtonVisibility() end,
		filters = {
			{ type = FilterComponent.Title, text = HARDCORE_CHALLENGE_FILTER_SEARCH },
			{ type = FilterComponent.CustomFrame, key = "SearchFrame" },
			{ type = FilterComponent.Space },
			{ type = FilterComponent.Title, text = HARDCORE_CHALLENGE_FILTER_LEVEL },
			{ type = FilterComponent.CustomFrame, key = "LevelRangeFrame" },
			{ type = FilterComponent.Space },
			{ type = FilterComponent.Submenu, text = HARDCORE_CHALLENGE_FILTER_STATUS, value = 1, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() self:SetAllStatusChecked(true) end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() self:SetAllStatusChecked(false) end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_Hardcore.SetLeaderboardStatusFilter,
						  isSet = C_Hardcore.IsLeaderboardStatusChecked,
						  numFilters = C_Hardcore.GetNumLeaderboardStatusFilters,
						  filterValidation = C_Hardcore.IsValidLeaderboardStatusFilter,
						  globalPrepend = "HARDCORE_CHALLENGE_STATUS_",
						},
					},
				},
			},
			{ type = FilterComponent.Submenu, text = HARDCORE_CHALLENGE_FILTER_CLASS, value = 2, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() self:SetAllClassChecked(true) end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() self:SetAllClassChecked(false) end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_Hardcore.SetLeaderboardClassFilter,
						  isSet = C_Hardcore.IsLeaderboardClassChecked,
						  numFilters = GetNumClasses,
						  filterValidation = C_Hardcore.IsValidLeaderboardClassFilter,
						  nameFunction = GetClassInfo,
						},
					},
				},
			},
		}
	}

	FilterDropDownSystem.Initialize(self, filterSystem, level)
end

HardcoreLadderSearchFrameMixin = CreateFromMixins(UIDropDownCustomMenuEntryMixin)

function HardcoreLadderSearchFrameMixin:Reset()
	self.SearchBox:SetText("")
end

function HardcoreLadderSearchFrameMixin:OnTextChanged()
	C_Hardcore.SetLeaderboardSearch(self.SearchBox:GetText() or "")
end

HardcoreLadderLevelRangeFrameMixin = CreateFromMixins(UIDropDownCustomMenuEntryMixin)

function HardcoreLadderLevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("")
	self.MaxLevel:SetText("")
end

function HardcoreLadderLevelRangeFrameMixin:OnTextChanged()
	local minLevel, maxLevel = self.MinLevel:GetNumber(), self.MaxLevel:GetNumber()

	if maxLevel ~= 0 and minLevel > maxLevel then
		self.MinLevel:SetNumber(maxLevel)
	end

	C_Hardcore.SetLeaderboardLevelFilter(self.MinLevel:GetNumber(), self.MaxLevel:GetNumber())
end

HardcoreConfirmChallengeMixin = {}

function HardcoreConfirmChallengeMixin:OnLoad()
	self.ShadowCornerTopRight:SetPoint("TOPLEFT", 2, -36)
	self.ShadowCornerTopRight:SetPoint("TOPRIGHT", -1, -36)

	self.Background:SetAtlas("PKBT-Tile-Wood-128")
	self.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.BottomShadow:SetAtlas("PKBT-Background-Shadow-Small-Bottom", true)

	self.DeclineButton:SetThreeSliceAtlas("PKBT-128-BlueButton")

	self.Text:ClearAllPoints()
	self.Text:SetPoint("CENTER", HardcoreFrame)

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", self.Text, -46, 68)
	self:SetPoint("BOTTOMRIGHT", self.Text, 46, -98)

	self.EditBox:SetCustomCharFilter(function(text)
		return text:upper()
	end)
end

function HardcoreConfirmChallengeMixin:OnHide()
	self.EditBox:Hide()
	self.EditBox:SetText("")
end

function HardcoreConfirmChallengeMixin:Toggle(shown, challengeID)
	self:SetShown(shown)

	local name = C_Hardcore.GetChallengeInfoByID(challengeID)

	local isChallengeActive = C_Service.IsChallengeActive(challengeID)
	self.isChallengeActive = isChallengeActive

	if not isChallengeActive then
		self.Text:SetFormattedText(HARDCORE_START_CHALLENGE_TEXT, name)
	else
		self.Text:SetFormattedText(HARDCORE_CANCEL_CHALLENGE_TEXT, name)
	end

	self.EditBox:SetShown(isChallengeActive)
	self:SetPoint("BOTTOMRIGHT", self.Text, 46, not isChallengeActive and -98 or -158)

	self:UpdateAccept()
end

function HardcoreConfirmChallengeMixin:Accept()
	local challengeIndex = C_Hardcore.GetSelectedChallenge()
	if challengeIndex then
		local challengeID = C_Hardcore.GetChallengeInfo(challengeIndex)
		if challengeID then
			if C_Service.IsChallengeActive(challengeID) then
				C_HardcoreSecure.CancelChallenge(challengeID)
			else
				C_HardcoreSecure.StartChallenge(challengeID)
			end

			self:Hide()
		end
	end
end

function HardcoreConfirmChallengeMixin:UpdateAccept()
	if self.isChallengeActive then
		self.AcceptButton:SetEnabled(ConfirmationEditBoxMatches(self.EditBox, CONFIRM_TEXT_AGREE))
	else
		self.AcceptButton:Enable()
	end
end

HardcoreStaticPopupMixin = {}

function HardcoreStaticPopupMixin:OnLoad()
	self.Background:SetAtlas("PKBT-Tile-Wood-128")
	self.VignetteTopLeft:SetAtlas("PKBT-Vignette-Bronze-TopLeft", true)
	self.VignetteTopRight:SetAtlas("PKBT-Vignette-Bronze-TopRight", true)
	self.BottomShadow:SetAtlas("PKBT-Background-Shadow-Small-Bottom", true)

	self.Valkyr:SetAtlas("Custom-Challenges-Artwork-Valkyr", true)
	self.Valkyr:SetParent(self.NineSlice)

	self.Button2:AddText(HARDCORE_CHARACTER_SAVE)
	self.Button2:SetFixedWidth(220)
	self.Button2:SetPadding(28)

	self:RegisterCustomEvent("DEATH_RECAP_REGISTERED")
end

function HardcoreStaticPopupMixin:OnEvent(event, ...)
	if event == "DEATH_RECAP_REGISTERED" then
		local recapID = ...
		self:UpdateDeathRecapButton()
	end
end

function HardcoreStaticPopupMixin:OnShow()
	local _, _, _, _, _, price = C_Hardcore.GetChallengeInfoByID(1)
	if price then
		self.Button2:SetPrice(price, price, Enum.Store.CurrencyType.Bonus)
	end
	self:UpdateDeathRecapButton()
end

function HardcoreStaticPopupMixin:OnHide()
	self.OverlayFrame:Hide()
	self.ConfirmFrame:Hide()
end

function HardcoreStaticPopupMixin:ShowConfirm()
	self.OverlayFrame:Show()
	self.ConfirmFrame:Show()
end

function HardcoreStaticPopupMixin:UpdateDeathRecapButton()
	self.Button1.HelpPlateButton:SetEnabled(not DeathRecapFrame:IsDeathLogEmpty())
end

HardcoreStaticPopupConfirmMixin = {}

function HardcoreStaticPopupConfirmMixin:OnLoad()
	self.OverlayFrame = self:GetParent().OverlayFrame

	self.Background:SetTexture(0.110, 0.102, 0.098)
	self.Background:SetAlpha(0.95)
end

function HardcoreStaticPopupConfirmMixin:OnShow()
	SetParentFrameLevel(self.OverlayFrame, 4)
	SetParentFrameLevel(self, 5)
end

function HardcoreStaticPopupConfirmMixin:OnHide()
	self.OverlayFrame:Hide()
end

function HardcoreStaticPopupConfirmMixin:Okay()
	C_HardcoreSecure.SaveCharacter()

	StaticPopupSpecial_Hide(self:GetParent())
end

HardcoreLossBannerMixin = {}

function HardcoreLossBannerMixin:OnLoad()
	self.BannerTop:SetAtlas("BossBanner-BgBanner-Top", true)
	self.BannerTopGlow:SetAtlas("BossBanner-BgBanner-Top", true)
	self.BannerBottom:SetAtlas("BossBanner-BgBanner-Bottom", true)
	self.BannerBottomGlow:SetAtlas("BossBanner-BgBanner-Bottom", true)
	self.BannerMiddle:SetAtlas("BossBanner-BgBanner-Mid", true)
	self.BannerMiddleGlow:SetAtlas("BossBanner-BgBanner-Mid", true)
	self.SkullCircle:SetAtlas("BossBanner-SkullCircle", true)
	self.BottomFillagree:SetAtlas("BossBanner-BottomFillagree", true)
	self.SkullSpikes:SetAtlas("BossBanner-SkullSpikes", true)
	self.RightFillagree:SetAtlas("BossBanner-RightFillagree", true)
	self.LeftFillagree:SetAtlas("BossBanner-LeftFillagree", true)
	self.Overlay.FlashBurst:SetAtlas("BossBanner-RedLightning", true)
	self.Overlay.FlashBurstLeft:SetAtlas("BossBanner-RedLightning", true)
	self.Overlay.FlashBurstCenter:SetAtlas("BossBanner-RedLightning", true)
	self.Overlay.RedFlash:SetAtlas("BossBanner-RedFlash", true)

	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterCustomEvent("HARDCORE_DEATH")
end

function HardcoreLossBannerMixin:OnEvent(event, ...)
	if event == "VARIABLES_LOADED" then
		self:SetScale(tonumber(C_CVar:GetValue("C_CVAR_SHOW_HARDCORE_NOTIFICATION_SCALE")) or 1)
	elseif event == "HARDCORE_DEATH" then
		if C_CVar:GetValue("C_CVAR_SHOW_HARDCORE_NOTIFICATION") == "0" then
			return
		end

		local name, race, gender, class, level, zone, reason, npc, npcLevel = ...

		local levelFilter = C_CVar:GetValue("C_CVAR_SHOW_HARDCORE_NOTIFICATION_LEVEL")
		if levelFilter == "3" and level < 60
		or levelFilter == "2" and level < 20
		or levelFilter == "1" and level < 10
		then
			return
		end

		local raceInfo = C_CreatureInfo.GetRaceInfo(E_CHARACTER_RACES[E_CHARACTER_RACES_DBC[race]])
		local _, classFileName = GetClassInfo(class)
		if raceInfo and classFileName then
			local classColorString = select(4, GetClassColor(classFileName))
			local playSound = C_CVar:GetValue("C_CVAR_SHOW_HARDCORE_NOTIFICATION_SOUND") == "1"

			if C_CVar:GetValue("C_CVAR_SHOW_HARDCORE_NOTIFICATION") == "2" then
				local data = {playSound = playSound}

				if reason == Enum.Hardcore.DeathSouce.NPC then
					if npc and npcLevel then
						data.title = string.format(HARDCORE_LOSS_BANNER_TEXT_NPC, classColorString, name, raceInfo.raceName:lower(), level, npc, npcLevel, zone)
					else
						data.title = string.format(HARDCORE_LOSS_BANNER_TEXT_PVP, classColorString, name, raceInfo.raceName:lower(), level, zone)
					end
				else
					local reasonText = C_Hardcore.GetEnviromentalDamageText(reason)
					data.title = string.format(HARDCORE_LOSS_BANNER_TEXT, classColorString, name, raceInfo.raceName:lower(), level, reasonText:lower(), zone)
				end

				self:PlayBanner(data)
			elseif C_CVar:GetValue("C_CVAR_SHOW_HARDCORE_NOTIFICATION") == "1" then
				local text, sound

				if reason == Enum.Hardcore.DeathSouce.NPC then
					if npc and npcLevel then
						text = string.format(HARDCORE_LOSS_TOAST_TEXT_NPC, classColorString, name, raceInfo.raceName:lower(), level, zone)
					else
						text = string.format(HARDCORE_LOSS_TOAST_TEXT_PVP, classColorString, name, raceInfo.raceName:lower(), level, zone)
					end
				else
					local reasonText = C_Hardcore.GetEnviromentalDamageText(reason)
					text = string.format(HARDCORE_LOSS_TOAST_TEXT, classColorString, name, raceInfo.raceName:lower(), level, reasonText:lower(), zone)
				end

				if playSound then
					sound = SOUNDKIT.UI_PERSONAL_LOOT_BANNER
				end

				FireCustomClientEvent("SHOW_TOAST", E_TOAST_CATEGORY.INTERFACE_HANDLED, 0, "ability_rogue_sealfate", HARDCORE_TOAST_LABEL, text, sound)
			end
		end
	end
end

function HardcoreLossBannerMixin:PlayBanner(data)
	self:StopBanner()

	self.Title:SetText(data.title)

	if self.Title:IsTruncated() then
		local baseHeight, lineHeight, baseLines = 156, 17, 2

		for _ = 1, 5 do
			baseLines = baseLines + 1
			baseHeight = baseHeight + lineHeight

			self:SetHeight(baseHeight)
			self.Title:SetHeight(baseLines * lineHeight)

			if not self.Title:IsTruncated() then
				break
			end
		end
	end

	local scale = self:GetEffectiveScale()
	local fillagreeScale = 0.5
	self.RightFillagree:SetPoint("CENTER", self.SkullCircle, "CENTER", 10, 6)
	self.RightFillagree.AnimIn.Translation:SetOffset(37 * scale * fillagreeScale, 0)
	self.LeftFillagree:SetPoint("CENTER", self.SkullCircle, "CENTER", -10, 6)
	self.LeftFillagree.AnimIn.Translation:SetOffset(-(37 * scale * fillagreeScale), 0)
	self.Overlay.FlashBurst.AnimIn.Translation:SetOffset(10 * scale, 0)
	self.Overlay.FlashBurstLeft.AnimIn.Translation:SetOffset(-(10 * scale), 0)
	self.SkullCircle.AnimIn:Play()
	self.BannerTop.AnimIn:Play()
	self.BannerBottom.AnimIn:Play()
	self.BannerMiddle.AnimIn:Play()
	self.BottomFillagree.AnimIn:Play()
	self.SkullSpikes.AnimIn:Play()
	self.RightFillagree.AnimIn:Play()
	self.LeftFillagree.AnimIn:Play()
	self.BannerTopGlow.AnimIn:Play()
	self.BannerBottomGlow.AnimIn:Play()
	self.BannerMiddleGlow.AnimIn:Play()
	self.Title.AnimIn:Play()
	self.Overlay.RedFlash.AnimIn:Play()
	self.Overlay.FlashBurst.AnimIn:Play()
	self.Overlay.FlashBurstLeft.AnimIn:Play()
	self.Overlay.FlashBurstCenter.AnimIn:Play()
	self:Show()

	if data.playSound then
		PlaySound(SOUNDKIT.UI_PERSONAL_LOOT_BANNER)
	end

	self.AnimOutTimer = C_Timer:NewTicker(data.timeToHold or 8, GenerateClosure(self.PerformAnimOut, self), 1)
end

function HardcoreLossBannerMixin:StopBanner()
	self:SetHeight(156)
	self.Title:SetHeight(34)

	if self.AnimOutTimer then
		self.AnimOutTimer:Cancel()
		self.AnimOutTimer = nil
	end

	self.SkullCircle.AnimIn:Stop()
	self.BannerTop.AnimIn:Stop()
	self.BannerBottom.AnimIn:Stop()
	self.BannerMiddle.AnimIn:Stop()
	self.BottomFillagree.AnimIn:Stop()
	self.SkullSpikes.AnimIn:Stop()
	self.RightFillagree.AnimIn:Stop()
	self.LeftFillagree.AnimIn:Stop()
	self.BannerTopGlow.AnimIn:Stop()
	self.BannerBottomGlow.AnimIn:Stop()
	self.BannerMiddleGlow.AnimIn:Stop()
	self.Title.AnimIn:Stop()
	self.Overlay.RedFlash.AnimIn:Stop()
	self.Overlay.FlashBurst.AnimIn:Stop()
	self.Overlay.FlashBurstLeft.AnimIn:Stop()
	self.Overlay.FlashBurstCenter.AnimIn:Stop()
	self:Hide()
end

function HardcoreLossBannerMixin:PerformAnimOut()
	self.AnimOut:Play()
end

function HardcoreLossBannerMixin:GetTestText()
	local name = UnitName("player")
	local _, classFileName = UnitClass("player")
	local race = UnitRace("player")
	local level = UnitLevel("player")
	local zone = GetZoneText()
	local classColorString = select(4, GetClassColor(classFileName))
	return string.format(HARDCORE_LOSS_TOAST_TEXT_NPC, classColorString, name, race:lower(), level, zone)
end

function HardcoreLossBannerMixin:TestFrame()
	if self:IsShown() then
		if self.AnimOut:IsPlaying() then
			self.AnimOut:Stop()
			self:PlayBanner({title = self:GetTestText()})
		else
			if self.AnimOutTimer then
				self.AnimOutTimer:Cancel()
			end
			self.AnimOutTimer = C_Timer:NewTicker(3, GenerateClosure(self.PerformAnimOut, self), 1)
		end
	else
		self:PlayBanner({title = self:GetTestText()})
	end
end

function HardcoreLossBanner_OnAnimOutFinished(self)
	local banner = self:GetParent()
	banner:Hide()
end