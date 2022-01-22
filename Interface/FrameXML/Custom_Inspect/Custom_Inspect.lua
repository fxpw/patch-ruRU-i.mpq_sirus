--	Filename:	Sirus_Inspect.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

INSPECTFRAME_SUBFRAMES = { "InspectPaperDollFrame", "InspectPVPFrame", "InspectTalentFrame", "InspectGuildFrame" }
UIPanelWindows["InspectFrame"] = { area = "left", pushable = 0, xOffset = "15", yOffset = "-10", width = 378 }

local PVPStatsInfo = {}

function InspectFrame_OnLoad( self, ... )
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self.unit = nil

	PanelTemplates_SetNumTabs(self, 4)
	PanelTemplates_SetTab(self, 1)
end

function InspectFrame_OnUpdate(self)
	if ( not UnitIsVisible(self.unit) ) then
		HideUIPanel(InspectFrame)
	end
end

function InspectFrame_OnEvent(self, event, ...)
	if ( not self:IsShown() ) then
		return
	end
	if ( event == "PLAYER_TARGET_CHANGED" or event == "PARTY_MEMBERS_CHANGED" ) then
		if ( (event == "PLAYER_TARGET_CHANGED" and self.unit == "target") or
		     (event == "PARTY_MEMBERS_CHANGED" and self.unit ~= "target") ) then
			if ( CanInspect(self.unit) ) then
				InspectFrame_UnitChanged(self)
			else
				HideUIPanel(InspectFrame)
			end
		end
		return
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		local arg1 = ...
		if ( arg1 == self.unit ) then
			InspectFrameTitleText:SetText(UnitName(arg1))
		end
		return
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local arg1 = ...
		if ( arg1 == self.unit ) then
			SetPortraitTexture(InspectFramePortrait, arg1)
		end
		return
	end
end

function InspectFrame_UnitChanged(self)
	local unit = self.unit
	NotifyInspect(unit)
	InspectPaperDollFrame_OnShow(self)
	SetPortraitTexture(InspectFramePortrait, unit)
	InspectFrameTitleText:SetText(UnitName(unit))
	InspectFrame_UpdateTabs()
	ButtonFrameTemplate_HideButtonBar(InspectFrame)

	if PanelTemplates_GetSelectedTab(InspectFrame) == 3 or PanelTemplates_GetSelectedTab(InspectFrame) == 4 then
		ButtonFrameTemplate_ShowButtonBar(InspectFrame)
	end

	if ( InspectPVPFrame:IsShown() ) then
		InspectPVPFrame_OnShow()
	end

	ItemLevelMixIn:Request( unit )
	InspectPVPFrame_Update()

	InspectSwitchTabs(1)
	SendServerMessage("ACMSG_BG_STATS_REQUEST", UnitGUID(self.unit))

	if self.UpdateTimer then
		self.UpdateTimer:Cancel()
		self.UpdateTimer = nil
	end

	self.UpdateTimer = C_Timer:NewTicker(0.1, InspectPaperDollFrame_UpdateButtons, 5)
end

function InspectFrame_OnShow(self)
	if ( not self.unit ) then
		return
	end
	PlaySound("igCharacterInfoOpen")
	SetPortraitTexture(InspectFramePortrait, self.unit)
	InspectFrameTitleText:SetText(UnitName(self.unit))

	InspectPVPFrame_Update()
	SendServerMessage("ACMSG_BG_STATS_REQUEST", UnitGUID(self.unit))

	if self.UpdateTimer then
		self.UpdateTimer:Cancel()
		self.UpdateTimer = nil
	end

	self.UpdateTimer = C_Timer:NewTicker(0.1, InspectPaperDollFrame_UpdateButtons, 5)
end

function InspectFrame_OnHide(self)
	self.unit = nil
	PlaySound("igCharacterInfoClose")

	-- Clear the player being inspected
	ClearInspectPlayer()

	-- in the InspectTalentFrame_Update function, a default talent tab is selected smartly if there is no tab selected
	-- it actually ends up feeling natural to have this behavior happen every time the frame is shown
	PanelTemplates_SetTab(InspectTalentFrame, nil)

	if not self.UpdateTimer then
		self.UpdateTimer:Cancel()
		self.UpdateTimer = nil
	end
end

function InspectPaperDollFrame_OnLoad( self )
	self:RegisterEvent("UNIT_MODEL_CHANGED")
	self:RegisterEvent("UNIT_LEVEL")
end

function InspectPaperDollFrame_OnEvent(self, event, unit)
	if (InspectFrame:IsShown()) then
		if ( unit and unit == InspectFrame.unit ) then
			if ( event == "UNIT_MODEL_CHANGED" ) then
				InspectModelFrame:RefreshUnit()
			elseif ( event == "UNIT_LEVEL" ) then
				InspectPaperDollFrame_SetLevel()
			end
			return
		end
		InspectPaperDollFrame_SetLevel()
		InspectPaperDollFrame_UpdateButtons()
	end
end

function InspectPaperDollFrame_OnShow()
	ButtonFrameTemplate_HideButtonBar(InspectFrame)
	InspectModelFrame:SetUnit(InspectFrame.unit)
	InspectPaperDollFrame_SetLevel()
	InspectPaperDollFrame_UpdateButtons()

	SetPaperDollBackground(InspectModelFrame, InspectFrame.unit)
	InspectModelFrameBackgroundTopLeft:SetDesaturated(1)
	InspectModelFrameBackgroundTopRight:SetDesaturated(1)
	InspectModelFrameBackgroundBotLeft:SetDesaturated(1)
	InspectModelFrameBackgroundBotRight:SetDesaturated(1)

	ItemLevelMixIn:Request(InspectFrame.unit)
end

function InspectFrame_Show( unit )
	HideUIPanel(InspectFrame)
	if ( CanInspect(unit, true) ) then
		NotifyInspect(unit)
		InspectFrame.unit = unit
		InspectSwitchTabs(1)
		ShowUIPanel(InspectFrame)
		InspectFrame_UpdateTabs()
	end
end

function InspectFrameTab_OnClick(self)
	PlaySound("igCharacterInfoTab")
	InspectSwitchTabs(self:GetID())
end

function InspectSwitchTabs(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]]
	local oldFrame = _G[INSPECTFRAME_SUBFRAMES[PanelTemplates_GetSelectedTab(InspectFrame)]]
	if ( newFrame ) then
		if ( oldFrame ) then
			oldFrame:Hide()
		end
		PanelTemplates_SetTab(InspectFrame, newID)
		ShowUIPanel(InspectFrame)
		newFrame:Show()

		InspectFrameInset:SetShown(newFrame ~= InspectPVPFrame)
	end
end

function InspectFrame_UpdateTabs()
	if ( not InspectFrame.unit ) then
		return
	end

	-- Talent tab
	local level = UnitLevel(InspectFrame.unit)
	if ( level > 0 and level < 10 ) then
		PanelTemplates_DisableTab(InspectFrame, 3)
		if ( PanelTemplates_GetSelectedTab(InspectFrame) == 3 ) then
			InspectSwitchTabs(1)
		end
	else
		PanelTemplates_EnableTab(InspectFrame, 3)
		InspectTalentFrame_UpdateTabs()
	end

	-- Guild tab
	local guildName = GetGuildInfo(InspectFrame.unit)
	if ( guildName and guildName ~= "" ) then
		PanelTemplates_EnableTab(InspectFrame, 4)
		SendAddonMessage("ACMSG_INSPECT_GUILD_INFO_REQUEST", UnitGUID(InspectFrame.unit), "WHISPER", UnitName("player"))
	else
		PanelTemplates_DisableTab(InspectFrame, 4)
		if ( PanelTemplates_GetSelectedTab(InspectFrame) == 4 ) then
			InspectSwitchTabs(1)
		end
	end

	InspectRatedBattleGrounds_OnShow(InspectPVPFrame.Service)
end

function InspectModelFrame_OnUpdate(self, elapsedTime)
	if ( InspectModelRotateLeftButton:GetButtonState() == "PUSHED" ) then
		self.rotation = self.rotation + (elapsedTime * 2 * PI * ROTATIONS_PER_SECOND)
		if ( self.rotation < 0 ) then
			self.rotation = self.rotation + (2 * PI)
		end
		self:SetRotation(self.rotation)
	end
	if ( InspectModelRotateRightButton:GetButtonState() == "PUSHED" ) then
		self.rotation = self.rotation - (elapsedTime * 2 * PI * ROTATIONS_PER_SECOND)
		if ( self.rotation > (2 * PI) ) then
			self.rotation = self.rotation - (2 * PI)
		end
		self:SetRotation(self.rotation)
	end
end

function InspectModelRotateLeftButton_OnClick()
	InspectModelFrame.rotation = InspectModelFrame.rotation - 0.03
	InspectModelFrame:SetRotation(InspectModelFrame.rotation)
	PlaySound("igInventoryRotateCharacter")
end

function InspectModelRotateRightButton_OnClick()
	InspectModelFrame.rotation = InspectModelFrame.rotation + 0.03
	InspectModelFrame:SetRotation(InspectModelFrame.rotation)
	PlaySound("igInventoryRotateCharacter")
end

function InspectPaperDollItemSlotButton_OnLoad( self, ... )
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")

	local slotName = self:GetName()
	local id
	local textureName
	local checkRelic
	id, textureName, checkRelic = GetInventorySlotInfo(strsub(slotName,8))
	self:SetID(id)
	local texture = _G[slotName.."IconTexture"]
	texture:SetTexture(textureName)
	self.backgroundTextureName = textureName
	self.checkRelic = checkRelic
end

function InspectPaperDollItemSlotButton_OnEvent(self, event, ...)
	if ( event == "UNIT_INVENTORY_CHANGED" ) then
		local arg1 = ...
		if ( arg1 == InspectFrame.unit ) then
			InspectPaperDollItemSlotButton_Update(self)
		end
		return
	end
end

function InspectPaperDollItemSlotButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, self:GetID()) ) then
		local text = _G[strupper(strsub(self:GetName(), 8))]
		if ( self.checkRelic and UnitHasRelicSlot(InspectFrame.unit) ) then
			text = _G["RELICSLOT"]
		end
		GameTooltip:SetText(text)
	end
	CursorUpdate(self)

	local itemLink = GetInventoryItemLink(InspectFrame.unit, self:GetID())
	local itemID = GetInventoryItemID(InspectFrame.unit, self:GetID())

	if itemLink and itemID then
		local _, link = GetItemInfo(itemID)
		if tonumber(string.match(itemLink, "item:(%d+)")) ~= itemID then
			GameTooltip:SetTransmogrifyItem(itemID)
		end
	end
end

function InspectPaperDollItemSlotButton_Update(button)
	local unit = InspectFrame.unit

	if unit then
		local link = GetInventoryItemLink(unit, button:GetID())
		local textureName = GetInventoryItemTexture(unit, button:GetID())

		local itemName, _, quality, _, _, _, _, _, _, texture = GetItemInfo(link)

		if not button:GetParent():GetParent().equipmentItemsList then
			button:GetParent():GetParent().equipmentItemsList = {}
		end

		button:GetParent():GetParent().equipmentItemsList[button:GetID()] = textureName and itemName

		if ( textureName ) then
			if link then
				SetItemButtonQuality(button, quality)
				SetItemButtonTexture(button, texture)
			end
			SetItemButtonCount(button, GetInventoryItemCount(unit, button:GetID()))
			button.hasItem = 1
		else
			local textureName = button.backgroundTextureName
			if ( button.checkRelic and UnitHasRelicSlot(unit) ) then
				textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp"
			end
			SetItemButtonQuality(button, nil)
			SetItemButtonTexture(button, textureName)
			SetItemButtonCount(button, 0)
			button.hasItem = nil
		end
		if ( GameTooltip:IsOwned(button) ) then
			if ( texture ) then
	            if ( not GameTooltip:SetInventoryItem(InspectFrame.unit, button:GetID()) ) then
					GameTooltip:SetText(_G[strupper(strsub(button:GetName(), 8))])
				end
			else
				GameTooltip:Hide()
			end
		end
	end
end

function InspectPaperDollFrame_SetLevel()
	if (not InspectFrame.unit) then
		return
	end

	local unit, level = InspectFrame.unit, UnitLevel(InspectFrame.unit)

	local classDisplayName, class = UnitClass(InspectFrame.unit)
	local classColor = RAID_CLASS_COLORS[class]
	local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

	if ( level == -1 ) then
		level = "??"
	end

	InspectLevelText:SetFormattedText(INSPECT_PLAYER_TEXT, level, classColorString, classDisplayName)
end

function SetPaperDollBackground(model, unit)
	local texture = GetDressUpTexturePath(unit)
	local overlayAlpha = GetDressUpTextureAlpha(unit)

	model.BackgroundOverlay:SetAlpha(overlayAlpha)
	model.BackgroundTopLeft:SetTexture(texture..1)
	model.BackgroundTopRight:SetTexture(texture..2)
	model.BackgroundBotLeft:SetTexture(texture..3)
	model.BackgroundBotRight:SetTexture(texture..4)
end

function InspectPaperDollFrame_UpdateButtons()
	InspectPaperDollItemSlotButton_Update(InspectHeadSlot)
	InspectPaperDollItemSlotButton_Update(InspectNeckSlot)
	InspectPaperDollItemSlotButton_Update(InspectShoulderSlot)
	InspectPaperDollItemSlotButton_Update(InspectBackSlot)
	InspectPaperDollItemSlotButton_Update(InspectChestSlot)
	InspectPaperDollItemSlotButton_Update(InspectShirtSlot)
	InspectPaperDollItemSlotButton_Update(InspectTabardSlot)
	InspectPaperDollItemSlotButton_Update(InspectWristSlot)
	InspectPaperDollItemSlotButton_Update(InspectHandsSlot)
	InspectPaperDollItemSlotButton_Update(InspectWaistSlot)
	InspectPaperDollItemSlotButton_Update(InspectLegsSlot)
	InspectPaperDollItemSlotButton_Update(InspectFeetSlot)
	InspectPaperDollItemSlotButton_Update(InspectFinger0Slot)
	InspectPaperDollItemSlotButton_Update(InspectFinger1Slot)
	InspectPaperDollItemSlotButton_Update(InspectTrinket0Slot)
	InspectPaperDollItemSlotButton_Update(InspectTrinket1Slot)
	InspectPaperDollItemSlotButton_Update(InspectMainHandSlot)
	InspectPaperDollItemSlotButton_Update(InspectSecondaryHandSlot)
	InspectPaperDollItemSlotButton_Update(InspectRangedSlot)
end


function InspectPVPFrame_OnLoad(self)
	self:RegisterEvent("INSPECT_HONOR_UPDATE")

	PanelTemplates_SetNumTabs(self, 3)
	InspectPVPFrameTab_OnClick(InspectPVPFrameTab1)

	InspectFrameCloseButton:SetToplevel(true)
	InspectFrameCloseButton:SetFrameLevel(self.Service.Container:GetFrameLevel() + 10)
	InspectFrameCloseButton:SetFrameStrata("HIGH")
end

function InspectBattlegroundStatisticsScrollFrame_OnLoad(self)
	ScrollFrame_OnLoad(self)

	local scrollBar = _G[self:GetName().."ScrollBar"]
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -2, -16)
	scrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -2, 16)
end

function InspectBattlegroundStatisticsScrollFrame_OnShow(self)
	if not self.buttons then
		self.buttons = {}

		local numBattlegrounds = GetNumBattlegroundTypes()
		local buttonIndex = 0
		for i = 1, numBattlegrounds do
			local localizedName, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)

			if BattlegroundsData[BattleGroundID] and BattlegroundsData[BattleGroundID].statistics then
				buttonIndex = buttonIndex + 1

				local button = CreateFrame("Button", "InspectBattlegroundStatisticsScrollFrameButton"..buttonIndex, self.ScrollChild, "InspectBattlegroundStatisticsButtonTemplate")

				if buttonIndex == 1 then
					button:SetPoint("TOPLEFT", self.ScrollChild, "TOPLEFT", -1, 0)
				else
					button:SetPoint("TOP", self.buttons[buttonIndex - 1], "BOTTOM", 0, -4)
				end

				self.buttons[buttonIndex] = button
			end
		end
	end

	InspectBattlegroundStatisticsUpdate()
end

function InspectBattlegroundStatisticsUpdate()
	local scrollFrame = InspectBattlegroundStatisticsScrollFrame
	local buttons = scrollFrame.buttons
	local numButtons = #buttons

	local numBattlegrounds = GetNumBattlegroundTypes()
	local buttonCount = 0

	local numCollapsed = 0
	local collapsedButtonHeight = 0
	local unitGUID = UnitGUID(InspectFrame.unit)

	for i = 1, numBattlegrounds do
		local localizedName, canEnter, isHoliday, isRandom, BattleGroundID = GetBattlegroundInfo(i)

		if BattlegroundsData[BattleGroundID] and ( BattlegroundsData[BattleGroundID].statistics ) then
			buttonCount = buttonCount + 1

			if buttonCount > 0 and buttonCount <= numButtons then
				local button = buttons[buttonCount]
				local bgData = BattlegroundsData[BattleGroundID]
				local bgStatistics = BattlegroundsData[BattleGroundID].statistics
				local atlasInfo = C_Texture.GetAtlasInfo(bgData.backgroundAtlas)
				local bgCoords = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord}
				local numStatistics = GetNumBattlegroundStatustics(BattleGroundID)
				local recordWin, recordLose = GetBattlegroundRecordStatistics(BattleGroundID, unitGUID)

				button.bgID = BattleGroundID
				button.isCollapsed = bgStatistics.isCollapsed
				button.buttonID = buttonCount

				button.BattlegroundName:SetText(localizedName)
				button.BattleRecord:SetFormattedText("%d - %d", recordWin or 0, recordLose or 0)

				button.TogglePlus:SetShown(bgStatistics.isCollapsed)
				button.ToggleMinus:SetShown(not bgStatistics.isCollapsed)

				button.BattleRecordLabel:SetShown(button.isCollapsed)
				button.BattleRecord:SetShown(button.isCollapsed)

				button.TodayLabel:SetShown(not button.isCollapsed)
				button.LifetimeLabel:SetShown(not button.isCollapsed)

				for b = 1, 10 do
					button.StipButton[b]:Hide()
				end

				button.Background:SetAtlas(bgData.backgroundAtlas)

				if not bgStatistics.isCollapsed then
					for t = 1, numStatistics do
						local title, week, season = GetBattlegroundStatistics(BattleGroundID, t, unitGUID)
						local stripFrame 		  = button.StipButton[t]

						stripFrame.Title:SetText(title)
						stripFrame.Today:SetText(week)
						stripFrame.Lifetime:SetText(season)

						stripFrame:SetShown(title)
					end

					local height = (18 * (numStatistics)) + 47
					--local coef 	 = ((height + 6) / 300) * (bgCoords[4] - bgCoords[3])

					button:SetHeight(height)
					--button.Background:SetTexCoord(bgCoords[1], bgCoords[2], bgCoords[3], bgCoords[3] + coef)

					numCollapsed = numCollapsed + 1
					collapsedButtonHeight = collapsedButtonHeight + height

					-- MountJournal_UpdateScrollPos(scrollFrame, buttonCount)
				else
					local coef = ((42) / 300) * (bgCoords[4] - bgCoords[3])

					button:SetHeight(42)
					button.Background:SetTexCoord(bgCoords[1], bgCoords[2], bgCoords[3], bgCoords[3] + coef)
				end

				button:Show()
			end
		end
	end

	buttonCount = max(buttonCount, 0)
	for i = buttonCount + 1, numButtons do
		buttons[i]:Hide()
	end
end

local InspectPVPFrame_SubFrame = {"Service", "Rating", "Ladder"}

function InspectPVPFrameTab_OnClick( self, ... )
	local tabID = self:GetID()

	for i = 1, 3 do
		local frame = _G["InspectPVPFrame"..InspectPVPFrame_SubFrame[i]]

		if frame then
			frame:Hide()
		end
	end

	InspectPVPFrame.ToggleStatisticsButton:SetShown(tabID == 1)
	InspectPVPFrame.Statistics:Hide()

	local frame = _G["InspectPVPFrame"..InspectPVPFrame_SubFrame[tabID]]

	if frame then
		frame:Show()
	end

	PanelTemplates_SetTab(InspectPVPFrame, tabID)
end

function ToggleStatisticsButton_OnClick( self, ... )
	self:GetParent().Statistics:SetShown(not self:GetParent().Statistics:IsShown())
	self:GetParent().Service:SetShown(not self:GetParent().Service:IsShown())

	StatisticsButtonUpdateState()
end

function StatisticsButtonUpdateState()
	if not InspectPVPFrame.Statistics:IsShown() then
		InspectPVPFrame.ToggleStatisticsButton:UnlockHighlight()
	else
		InspectPVPFrame.ToggleStatisticsButton:LockHighlight()
	end
end

function InspectPVPFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_HONOR_UPDATE" ) then
		InspectPVPFrame_Update()
	end
end

function InspectPVPFrame_OnShow()
	InspectPVPFrameTab_OnClick(InspectPVPFrameTab1)
	ButtonFrameTemplate_HideButtonBar(InspectFrame)
	InspectPVPFrame_Update()
	if ( not HasInspectHonorData() ) then
		RequestInspectHonorData()
	else
		InspectPVPFrame_Update()
	end
end

function InspectPVPFrame_SetFaction()
	local factionGroup = UnitFactionGroup(InspectFrame.unit)
	if ( factionGroup == "Alliance" ) then
		InspectPVPFrameFaction:SetTexCoord(0.69433594, 0.74804688, 0.60351563, 0.72851563)
	else
		InspectPVPFrameFaction:SetTexCoord(0.63867188, 0.69238281, 0.60351563, 0.73242188)
	end
end

function InspectPVPFrame_Update()
	for i=1, MAX_ARENA_TEAMS do
		GetInspectArenaTeamData(i)
	end
	InspectPVPFrame_SetFaction()
	InspectPVPTeam_Update()

	local todayHK, todayHonor, yesterdayHK, yesterdayHonor, lifetimeHK, lifetimeRank = GetInspectHonorData()

	InspectPVPFrame.Rating.Container.KillsToDay:SetText(todayHK)
	InspectPVPFrame.Rating.Container.KillsYesterDay:SetText(yesterdayHK)

	InspectPVPFrame.Rating.Container.HonorToDay:SetText(todayHonor)
	InspectPVPFrame.Rating.Container.HonorYesterDay:SetText(yesterdayHonor)

	InspectPVPFrame.Rating.Container.TotalHK:SetText(lifetimeHK)
end

function InspectPVPTeam_Update()
	for i = 1, 3 do
		local button = _G["InspectPVPTeam"..i]
		local id = button:GetID()
		local pvpStats = PVPStatsInfo[id]

		if pvpStats and button then
			button.Data.TeamSize:SetText(_G["ARENA_INSPECT_BRECKET_"..id])
			button.Data.Games:SetText(pvpStats.seasonGames)
			button.Data.Wins:SetText(pvpStats.seasonWins)
			button.Data.Lose:SetText(pvpStats.seasonGames - pvpStats.seasonWins)
			button.Data.Rating:SetText(pvpStats.pvpRating)
		end
	end
end


local talentSpecInfoCache = {}

function InspectTalentFrameTalent_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local link = GetTalentLink(PanelTemplates_GetSelectedTab(InspectTalentFrame), self:GetID(),
			InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup)
		if ( link ) then
			ChatEdit_InsertLink(link)
		end
	end
end

function InspectTalentFrameTalent_OnEvent(self, event, ...)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(InspectTalentFrame), self:GetID(),
			InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup)
	end
end

function InspectTalentFrameTalent_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetTalent(PanelTemplates_GetSelectedTab(InspectTalentFrame), self:GetID(),
		InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup)
end

function InspectTalentFrame_UpdateTabs()
	local numTabs = GetNumTalentTabs(InspectTalentFrame.inspect)
	local selectedTab = PanelTemplates_GetSelectedTab(InspectTalentFrame)
	local tab
	for i = 1, MAX_TALENT_TABS do
		tab = _G["InspectTalentFrameTab"..i]
		if ( tab ) then
			talentSpecInfoCache[i] = talentSpecInfoCache[i] or { }
			if ( i <= numTabs ) then
				-- local id, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked = GetTalentTabInfo(i, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup)
				local name, iconTexture, pointsSpent = GetTalentTabInfo(i, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup)
				if ( i == selectedTab ) then
					-- If tab is the selected tab set the points spent info
					InspectTalentFrameSpentPointsText:SetFormattedText(MASTERY_POINTS_SPENT, name, HIGHLIGHT_FONT_COLOR_CODE..pointsSpent..FONT_COLOR_CODE_CLOSE)
					InspectTalentFrame.pointsSpent = pointsSpent
					InspectTalentFrame.previewPointsSpent = 999
				end
				tab:SetText(name)
				PanelTemplates_TabResize(tab, -10)
				tab:Show()
			else
				tab:Hide()
				talentSpecInfoCache[i].name = nil
			end
		end
	end
end

function InspectTalentFrame_Update()
	InspectTalentFrame.talentGroup = GetActiveTalentGroup(InspectTalentFrame.inspect)
	InspectTalentFrame.unit = InspectFrame.unit

	-- update spec info first
	TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache, InspectTalentFrame.inspect, InspectTalentFrame.pet, InspectTalentFrame.talentGroup)

	-- update tabs

	-- select a tab if one is not already selected
	if ( not PanelTemplates_GetSelectedTab(InspectTalentFrame) ) then
		-- if there is a primary tab then we'll prefer that one
		if ( talentSpecInfoCache.primaryTabIndex > 0 ) then
			PanelTemplates_SetTab(InspectTalentFrame, talentSpecInfoCache.primaryTabIndex)
		else
			PanelTemplates_SetTab(InspectTalentFrame, DEFAULT_TALENT_TAB)
		end
	end
	InspectTalentFrame_UpdateTabs()

	-- update parent tabs
	PanelTemplates_UpdateTabs(InspectFrame)

	-- Update talents
	TalentFrame_Update(InspectTalentFrame)
end

function InspectTalentFrame_OnLoad(self)
	self.inspect = true
	self.talentButtonSize = 30;
	self.initialOffsetX = 62;
	self.initialOffsetY = 12;
	self.buttonSpacingX = 56;
	self.buttonSpacingY = 46;
	self.arrowInsetX = 2;
	self.arrowInsetY = 2;

	TalentFrame_Load(self)

	local button
	for i = 1, MAX_NUM_TALENTS do
		button = _G["InspectTalentFrameTalent"..i]
		if ( button ) then
			button:SetScript("OnClick",	InspectTalentFrameTalent_OnClick)
			button:SetScript("OnEvent", InspectTalentFrameTalent_OnEvent)
			button:SetScript("OnEnter", InspectTalentFrameTalent_OnEnter)
		end
	end

	-- setup tabs
	PanelTemplates_SetNumTabs(self, MAX_TALENT_TABS)
	PanelTemplates_UpdateTabs(self)
end

function InspectTalentFrame_OnShow()
	InspectTalentFrame:RegisterEvent("INSPECT_TALENT_READY")
	ButtonFrameTemplate_ShowButtonBar(InspectFrame)
	InspectTalentFrame_Update()
end

function InspectTalentFrame_OnHide()
	InspectTalentFrame:UnregisterEvent("INSPECT_TALENT_READY")
	wipe(talentSpecInfoCache)
end

function InspectTalentFrame_OnEvent(self, event, ...)
	if ( event == "INSPECT_TALENT_READY" ) then
		InspectTalentFrame_Update()
	end
end

function InspectTalentFrameDownArrow_OnClick(self)
	local parent = self:GetParent()
	parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2))
	PlaySound("UChatScrollButton")
	UIFrameFlashStop(InspectTalentFrameScrollButtonOverlay)
end

function InspectTalentFramePointsBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(TALENT_POINTS)
	local pointsColor
	for index, info in ipairs(talentSpecInfoCache) do
		if ( info.name ) then
			if ( talentSpecInfoCache.primaryTabIndex == index ) then
				pointsColor = GREEN_FONT_COLOR
			else
				pointsColor = HIGHLIGHT_FONT_COLOR
			end
			GameTooltip:AddDoubleLine(
				info.name,
				info.pointsSpent,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
				pointsColor.r, pointsColor.g, pointsColor.b,
				1
			)
		end
	end

	GameTooltip:Show()
end

function InspectGuildFrame_OnShow()
	ButtonFrameTemplate_ShowButtonBar(InspectFrame)
end

local BackgroundColors = {
	[PLAYER_FACTION_GROUP.Horde] = CreateColor(1, 0, 0),
	[PLAYER_FACTION_GROUP.Alliance] = CreateColor(0.3, 0.3, 1),
	[PLAYER_FACTION_GROUP.Renegade] = CreateColor(1, 0.67, 0.05),
}

function InspectRatedBattleGrounds_OnShow( self, ... )
	if not InspectFrame.unit then
		return
	end

	local currTitle, currRankID, currRankIconCoord, currRating, weekWins, weekGames, totalWins, totalGames, laurelCoord = GetUnitRatedBattlegroundRankInfo(InspectFrame.unit)
	local factionID = C_Unit:GetFactionID(InspectFrame.unit)

	if factionID then
		self.Container.LaurelBackground:SetTexCoord(unpack(PVPFRAME_PRESTIGE_LARGE_BACKGROUNDS[factionID]))
	end

	local bColor = BackgroundColors[factionID]

	if bColor then
		self.Inset.Bgs:SetVertexColor(bColor.r, bColor.g, bColor.b)
	end

	if currRankID == 0 and factionID then
		self.Container.RankIcon:ClearAllPoints()
		self.Container.RankIcon:SetPoint("CENTER", self.Container.Laurel, 0, 2)
		self.Container.RankIcon:SetTexture("Interface\\PVPFrame\\PvPQueue")
		self.Container.RankIcon:SetSize(86, 106)

		self.Container.RankIcon:SetTexCoord(unpack(PVPFRAME_PRESTIGE_FACTION_ICONS[factionID]))
	else
		self.Container.RankIcon:ClearAllPoints()
		self.Container.RankIcon:SetPoint("CENTER", self.Container.Laurel, -2, 3)
		self.Container.RankIcon:SetTexture("Interface\\PVPFrame\\PvPPrestigeIcons")
		self.Container.RankIcon:SetSize(64, 64)
	end

	if currRankIconCoord then
		self.Container.RankIcon:SetTexCoord(unpack(currRankIconCoord))
	end

	if laurelCoord then
		self.Container.Laurel:SetTexCoord(unpack(laurelCoord))
	end

	self.Container.WeekWins:SetText(weekWins)
	self.Container.SezonWins:SetText(totalWins)
	self.Container.WeekGames:SetText(weekGames)
	self.Container.SezonGames:SetText(totalGames)
	self.Container.WeekProc:SetText(weekGames == 0 and "0%" or math.ceil(weekWins / weekGames * 100).."%")
	self.Container.SezonProc:SetText(totalGames == 0 and "0%" or math.ceil(totalWins / totalGames * 100).."%")

	self.Container.YouRating:SetFormattedText(RATED_BATTLEGROUND_INSPECT_RATING, currRating == 0 and "-" or currRating, currRankID)

	-- self.Container.CurrentRank:SetText(currRankID == 0 and "-" or currRankID)
	self.Container.CurrentRankLabel:SetText(not currTitle and RATED_BATTLEGROUND_NORANK or currTitle)

	-- self.Container.Rating:SetText(currRating)
end

function InspectPVPTeam_OnEnter( self, ... )
	local tooltip = ConquestTooltip
	local buttonID = self:GetID()
	local pvpStats = PVPStatsInfo[buttonID]

	tooltip.TodayBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, pvpStats and pvpStats.TodayWins or 0)
	tooltip.TodayGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, pvpStats and pvpStats.TodayGames or 0)
	tooltip.WeeklyBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, pvpStats and pvpStats.weekWins or 0)
	tooltip.WeeklyGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, pvpStats and pvpStats.weekGames or 0)
	tooltip.SeasonBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, pvpStats and pvpStats.seasonWins or 0)
	tooltip.SeasonGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, pvpStats and pvpStats.seasonGames or 0)

	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
	tooltip:Show()
end

function RatedBattlegroundTeam_OnEnter( self, ... )
	local tooltip = InspectRatedBattlegroundTooltip
	local currRating, weekWins, weekGames, totalWins, totalGames = GetUnitRatedBattlegroundInfo(InspectFrame.unit)

	tooltip.WeeklyBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, weekWins)
	tooltip.WeeklyGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, weekGames)

	tooltip.SeasonBest:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKWINS, totalWins)
	tooltip.SeasonGamesPlayed:SetFormattedText(RATED_BATTLEGROUND_TOOLTIP_WEEKGAME, totalGames)

	tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
	tooltip:Show()
end

function InspectPaperDollViewButton_OnLoad(self)
	self:SetWidth(30 + self:GetFontString():GetStringWidth());
end

local transmogrifySlotButton = {
	"InspectHeadSlot",
	"InspectShoulderSlot",
	"InspectBackSlot",
	"InspectChestSlot",
	"InspectShirtSlot",
	"InspectTabardSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
	"InspectRangedSlot",
}

function InspectPaperDollViewButton_OnClick(self)
	local unit = InspectFrame.unit

	if not unit then
		return
	end

	DressUpModel:Undress()

	for _, slotName in pairs(transmogrifySlotButton) do
		local slotButton = _G[slotName]
		local itemID = GetInventoryItemID(unit, slotButton:GetID())
		local _, itemLink = GetItemInfo(itemID)
		DressUpItemLink(itemLink)
	end
end

InspectLadderMixin = {
	statsData = {},
	replayStorage = {},
	tabButtons = {},
	selectedRightTab = nil
}

function InspectLadderMixin:OnShow()
	for i = 0, 3 do
		if self.replayData[i] and #self.replayData[i] > 0 then
			self:TabClick(self.tabButtons[i + 1])
			return
		end
	end
	self:TabClick(self.tabButtons[1])
end

function InspectLadderMixin:TabOnLoad( button )
	local iconAtlas 	= button:GetAttribute("icon")
	local buttonIndex 	= #self.tabButtons + 1

	if iconAtlas then
		button.Icon:SetAtlas(iconAtlas)
	end

	button:SetFrameLevel(self:GetFrameLevel() + 3)

	button.ID 						= button:GetID()
	button.buttonIndex 				= buttonIndex
	self.tabButtons[buttonIndex] 	= button
end

function InspectLadderMixin:TabClick( button )
	self:SetSelectedTab(button.ID)
	self:UpdatePlayerInfo()
	self:UpdateScrollFrame()

	for _, btn in pairs(self.tabButtons) do
		btn:SetChecked(btn.buttonIndex == button.buttonIndex)
	end
end

function InspectLadderMixin:SetSelectedTab( index )
	self.selectedRightTab = index
end

function InspectLadderMixin:GetSelectedTab()
	return self.selectedRightTab
end

function InspectLadderMixin:GetPlayerWithRequest()
	return InspectFrame.unit and UnitName(InspectFrame.unit) or 0
end

function InspectLadderMixin:GetReplayCount()
	return self.replayData[self:GetSelectedTab() or 0] and #self.replayData[self:GetSelectedTab() or 0] or 0
end

function InspectLadderMixin:GetReplayInfo( replayIndex )
	local data = self.replayData[self:GetSelectedTab() or 0][replayIndex]

	if not data then
		return
	end

	local replayID 		= data.replayID
	local bracket 		= data.bracket
	local winnerTeam 	= data.winnerTeam
	local playerTeam 	= data.playerTeam
	local team1Rating 	= data.team1Rating
	local team2Rating 	= data.team2Rating
	local team1Players 	= self.replayData[self:GetSelectedTab() or 0][replayIndex].players[1]
	local team2Players 	= self.replayData[self:GetSelectedTab() or 0][replayIndex].players[2]

	return replayID, bracket, winnerTeam, playerTeam, team1Rating, team2Rating, team1Players, team2Players
end

function InspectLadderMixin:UpdatePlayerInfo()
	local selectedTab 	= self:GetSelectedTab() or 1
	local data 			= self.statsData[selectedTab]

	if data then
		local raceInfo = C_CreatureInfo.GetRaceInfo(data.raceID)

		self.TopContainer.StatisticsFrame.Statistics.PlayerName:SetText(data.name)
		self.TopContainer.StatisticsFrame.Statistics.PlayerRace:SetText(raceInfo.raceName)
		self.TopContainer.StatisticsFrame.Statistics.PlayerRating:SetText(data.totalRating)

		self.TopContainer.StatisticsFrame.Statistics.Season:SetFormattedText("|cff00FF00%d|cffFFFFFF/|cffFF0000%d", data.seasonWins, (data.seasonGames - data.seasonWins))
		self.TopContainer.StatisticsFrame.Statistics.Week:SetFormattedText("|cff00FF00%d|cffFFFFFF/|cffFF0000%d", data.weekWins, (data.weekGames - data.weekWins))
		self.TopContainer.StatisticsFrame.Statistics.Day:SetFormattedText("|cff00FF00%d|cffFFFFFF/|cffFF0000%d", data.dayWins, (data.dayGames - data.dayWins))

		local winsProc = math.min(math.Round(data.seasonWins / data.seasonGames * 100), 100)
		local color = winsProc < 50 and "|cffFF0000" or "|cff00FF00"

		self.TopContainer.StatisticsFrame.Statistics.AllWinsProc:SetFormattedText(color.."%d%%", math.min(math.Round(data.seasonWins / data.seasonGames * 100), 100))
	end

	self.TopContainer.StatisticsFrame.Statistics:SetShown(data)
	self.TopContainer.StatisticsFrame.NoData:SetShown(not data)
end

function EventHandler:ASMSG_INSPECT_GUILD_INFO_RESPONSE( msg )
	if not InspectFrame.unit then
		return
	end
	local guildName, _, _ = GetGuildInfo(InspectFrame.unit)
	local factionName = UnitFactionGroup(InspectFrame.unit) == "Alliance" and FACTION_ALLIANCE or FACTION_HORDE
	local level, memberCount, emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor, factionID = strsplit(":", msg)

	level = tonumber(level)
	memberCount = tonumber(memberCount)
	emblemStyle = tonumber(emblemStyle)
	emblemColor = tonumber(emblemColor)
	emblemBorderStyle = tonumber(emblemBorderStyle)
	emblemBorderColor = tonumber(emblemBorderColor)
	emblemBackgroundColor = tonumber(emblemBackgroundColor)
	factionID = isset(factionID) and SERVER_PLAYER_TEAM_TO_GAME_FACTION[tonumber(factionID)]

	InspectGuildFrame.guildName:SetText(guildName)
	InspectGuildFrame.guildLevel:SetFormattedText(INSPECT_GUILD_LEVEL, level, factionID and _G["FACTION_"..string.upper(PLAYER_FACTION_GROUP[factionID])] or factionName)
	InspectGuildFrame.guildNumMembers:SetFormattedText(INSPECT_GUILD_ONLINE, memberCount)

	if SHARED_TABARD_EMBLEM_COLOR[emblemColor] then
		InspectGuildFrameEmblem:SetVertexColor(rgb(unpack(SHARED_TABARD_EMBLEM_COLOR[emblemColor])))
	end

	if SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor] then
		InspectGuildFrameBanner:SetVertexColor(rgb(unpack(SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor])))
	end

	if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle] then
		if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor] then
			InspectGuildFrameBannerBorder:SetVertexColor(rgb(unpack(SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor])))
		end
	else
		if SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor] then
			InspectGuildFrameBannerBorder:SetVertexColor(rgb(unpack(SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor])))
		end
	end

	SetLargeGuildTabardTextures(InspectGuildFrameEmblem, emblemStyle)
end

function EventHandler:ASMSG_PVP_STATS_INSPECT( msg )
	local splitData = C_Split(msg, "|")
	PVPStatsInfo = {}

	for _, splittedMSG in pairs(splitData) do
		local splitData = C_Split(splittedMSG, ":")

		local pvpType = tonumber(splitData[1])
		local pvpRating = tonumber(splitData[2])
		local seasonGames = tonumber(splitData[3])
		local seasonWins = tonumber(splitData[4])
		local weekGames = tonumber(splitData[5])
		local weekWins = tonumber(splitData[6])
		local TodayGames = tonumber(splitData[7])
		local TodayWins = tonumber(splitData[8])

		PVPStatsInfo[pvpType] = {
			pvpType = pvpType,
			pvpRating = pvpRating,
			seasonGames = seasonGames,
			seasonWins = seasonWins,
			weekGames = weekGames,
			weekWins = weekWins,
			TodayGames = TodayGames,
			TodayWins = TodayWins
		}
	end
end

function EventHandler:ASMSG_PVP_LADDER_PLAYER_INSPECT( msg )
	local playerData 		= C_Split(msg, "|")
	local selectedCategory 	= tonumber(table.remove(playerData, 1))

	InspectPVPFrame.Ladder.statsData[selectedCategory] = nil

	if playerData[1] then
		local playerInfo 	= C_Split(playerData[1], ":")

		local rank 			= tonumber(playerInfo[1])
		local name 			= playerInfo[2]
		local raceID 		= tonumber(playerInfo[3])
		local classID 		= tonumber(playerInfo[4])
		local gender 		= tonumber(playerInfo[5])
		local totalRating 	= tonumber(playerInfo[6])
		local seasonGames 	= tonumber(playerInfo[7])
		local seasonWins 	= tonumber(playerInfo[8])
		local weekGames 	= tonumber(playerInfo[9])
		local weekWins 		= tonumber(playerInfo[10])
		local dayGames 		= tonumber(playerInfo[11])
		local dayWins 		= tonumber(playerInfo[12])

		if rank and name then
			InspectPVPFrame.Ladder.statsData[selectedCategory] = {
				rank 		= rank,
				name 		= name,
				raceID 		= raceID,
				classID 	= classID,
				gender 		= gender,
				totalRating = totalRating,
				seasonGames = seasonGames,
				seasonWins 	= seasonWins,
				weekGames 	= weekGames,
				weekWins 	= weekWins,
				dayGames 	= dayGames,
				dayWins 	= dayWins,
			}
		end
	end

	InspectPVPFrame.Ladder:UpdatePlayerInfo()
end

local bracketOverride = {
	[0] = 3,
	[1] = 2,
	[2] = 1,
	[3] = 5
}

function EventHandler:ASMSG_AR_LAST_INSPECT_REPLAYS( msg )
	local replayStorage 	= C_Split(msg, "|")
	local bracketID		 	= tonumber(table.remove(replayStorage, 1))

	if bracketID == 5 then
		bracketID = 2
	end

	local playerWithRequest = InspectPVPFrame.Ladder:GetPlayerWithRequest()

	InspectPVPFrame.Ladder.replayData[bracketID] = {}

	if replayStorage then
		for index, replayMsg in pairs(replayStorage) do
			local replayData 	= C_Split(replayMsg, ":")
			local replayID 		= tonumber(table.remove(replayData, 1))
			local winnerTeam 	= tonumber(table.remove(replayData, 3))

			local winTeam 	= 1
			local lossTeam 	= 2

			if winnerTeam ~= 2 then
				if winnerTeam == 1 then
					winTeam 	= 1
					lossTeam 	= 2
				else
					winTeam 	= 2
					lossTeam 	= 1
				end
			end

			local team1Data 	= C_Split(replayData[winTeam], ",")
			local team2Data 	= C_Split(replayData[lossTeam], ",")
			local rating 		= C_Split(replayData[3], ",")

			InspectPVPFrame.Ladder.replayData[bracketID][index] = {
				replayID 	= replayID,
				winnerTeam 	= winnerTeam,
				bracket 	= bracketOverride[bracketID],
				team1Rating = rating[winTeam],
				team2Rating = rating[lossTeam],
			}

			InspectPVPFrame.Ladder.replayData[bracketID][index].players = {
				[1] = {},
				[2] = {}
			}

			for i = 1, #team1Data, 2 do
				local team1PlayerName 						= team1Data[i]
				local team1ClassID 							= max(1, team1Data[i + 1])
				local team1ClassName, team1ClassFileString 	= GetClassInfo(tonumber(team1ClassID))

				local team2PlayerName 						= team2Data[i]
				local team2ClassID 							= max(1, team2Data[i + 1])
				local team2ClassName, team2ClassFileString 	= GetClassInfo(tonumber(team2ClassID))

				table.insert(InspectPVPFrame.Ladder.replayData[bracketID][index].players[1], {
					name 			= team1PlayerName,
					className 		= team1ClassName,
					classFileString = team1ClassFileString
				})

				table.insert(InspectPVPFrame.Ladder.replayData[bracketID][index].players[2], {
					name 			= team2PlayerName,
					className 		= team2ClassName,
					classFileString = team2ClassFileString
				})

				if playerWithRequest then
					if playerWithRequest == team1PlayerName then
						InspectPVPFrame.Ladder.replayData[bracketID][index].playerTeam = 0
					elseif playerWithRequest == team2PlayerName then
						InspectPVPFrame.Ladder.replayData[bracketID][index].playerTeam = 1
					end
				end
			end
		end
	end

	InspectPVPFrame.Ladder:HideLoadingSpinner()
	InspectPVPFrame.Ladder:UpdateScrollFrame()
end