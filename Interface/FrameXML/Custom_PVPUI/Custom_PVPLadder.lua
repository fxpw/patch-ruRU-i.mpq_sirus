--	Filename:	Custom_PVPLadder.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

PVPLadderFrameMixin = {}

PVPLadderInfoFrameMixin = {
	replayData = {}
}

PVPLadderCategoryMixin = {
	categoryButtons = {},
	categoryData = {
		selectedCategory = nil
	}
}

PVPLadderTabsMixin = {
	tabButtons = {},
	tabData = {
		selectedRightTab = nil
	},
}

enum:E_LADDER_BRACKET {
	[0] = "ARENA_SOLO",
	[1] = "ARENA_2V2",
	[2] = "ARENA_1V1",
	[3] = "BATTLEGROUND",
	[4] = "RENEGADE",
}

UIPanelWindows["PVPLadderFrame"] = { area = "left",	pushable = 0, whileDead = 1, xOffset = "15", yOffset = "-10", width = 593, height = 428 }

local CACHE_TIME_TO_LIFE = 300

function PVPLadderFrameMixin:OnLoad()
	self:RegisterHookListener()

	self.factionIcons = {
		[PLAYER_FACTION_GROUP.Horde]    = "right",
		[PLAYER_FACTION_GROUP.Alliance] = "left",
		[PLAYER_FACTION_GROUP.Renegade] = "Renegade",
	}

	RaiseFrameLevelByThree(self.Shadows)

	local function UpdateFaction()
		SetPortraitToTexture(self.Art.portrait, PVPUIFRAME_PORTRAIT_DATA[C_Unit:GetFactionID("player")])
	end

	C_FactionManager:RegisterFactionOverrideCallback(UpdateFaction, true)

	self:ResetFrame()
end

function PVPLadderFrameMixin:OnShow()
	PanelTemplates_SetTab(self, 3)
	UpdateMicroButtons()

	if UnitLevel("player") < 15 then
		PanelTemplates_DisableTab(self, 1)
	else
		PanelTemplates_EnableTab(self, 1)
	end

	self:InitializeScrollFrame("PVPLadderScrollPlayerButtonTemplate")

	self.categoryButtons[self:GetSelectedCategory() and self:GetSelectedCategory() + 1 or 1]:Click()
end

function PVPLadderFrameMixin:OnHide()
	UpdateMicroButtons()
	LAST_FINDPARTY_FRAME = self
end

function PVPLadderFrameMixin:VARIABLES_LOADED()
	UpdatePVPTabs(self)
end

function PVPLadderFrameMixin:GetPlayerInfo( index )
	local selectedTab 		= self:GetSelectedTab()
	local selectedCategory 	= self:GetSelectedCategory()
	local data

	if selectedTab == 1 then
		local storage = C_CacheInstance:Get("ASMSG_PVP_LADDER_TOP", {}, CACHE_TIME_TO_LIFE)

		data = storage[selectedCategory]
	elseif selectedTab == 2 then
		if self.searchBuffer[selectedCategory] then
			self.topBuffer 	= {}
			data 			= self.searchBuffer[selectedCategory]
		end
	elseif selectedTab > 2 then
		local storage = C_CacheInstance:Get("ASMSG_PVP_LADDER_CLASS_TOP", {}, CACHE_TIME_TO_LIFE)
		local button  = self.tabButtons[selectedTab]

		if storage[selectedCategory] and storage[selectedCategory][button.buttonID] then
			data = storage[selectedCategory][button.buttonID]
		end
	end

	self.topBuffer = data or self.topBuffer

	if self.topBuffer[index] then
		local rank 			= self.topBuffer[index].rank
		local name 			= self.topBuffer[index].name
		local raceID 		= self.topBuffer[index].raceID
		local classID 		= self.topBuffer[index].classID
		local gender 		= self.topBuffer[index].gender
		local totalRating 	= self.topBuffer[index].totalRating
		local seasonGames 	= self.topBuffer[index].seasonGames
		local weekGames 	= self.topBuffer[index].weekGames
		local dayGames 		= self.topBuffer[index].dayGames
		local seasonWins 	= self.topBuffer[index].seasonWins
		local weekWins 		= self.topBuffer[index].weekWins
		local dayWins		= self.topBuffer[index].dayWins
		local teamID 		= self.topBuffer[index].teamID

		return rank, name, raceID, classID, gender, totalRating, seasonGames, weekGames, dayGames, seasonWins, weekWins, dayWins, teamID
	end
end

function PVPLadderFrameMixin:GetNumPlayers()
	local selectedTab 		= self:GetSelectedTab()
	local selectedCategory 	= self:GetSelectedCategory()

	if selectedTab == 1 then
		local storage 	= C_CacheInstance:Get("ASMSG_PVP_LADDER_TOP", {}, CACHE_TIME_TO_LIFE)
		self.topBuffer 	= storage[selectedCategory] or self.topBuffer

		return tCount(self.topBuffer)
	elseif selectedTab == 2 then
		if self.searchBuffer[selectedCategory] then
			if self.searchData[selectedCategory] and self.searchData[selectedCategory].ttl and self.searchData[selectedCategory].ttl < time() then
				self.searchBuffer[selectedCategory] 	= nil
				self.searchData[selectedCategory].ttl 	= nil
			end

			return tCount(self.searchBuffer[selectedCategory]) or 0
		end
		return 0
	elseif selectedTab > 2 then
		local storage 		= C_CacheInstance:Get("ASMSG_PVP_LADDER_CLASS_TOP", {}, CACHE_TIME_TO_LIFE)
		local button  		= self.tabButtons[selectedTab]

		if storage[selectedCategory] and storage[selectedCategory][button.buttonID] then
			self.classBuffer = storage[selectedCategory][button.buttonID]
		else
			self.classBuffer = self.classBuffer
		end

		return tCount(self.classBuffer)
	end
end

function PVPLadderFrameMixin:UpdateSelfPlayerInfo()
	local storage 		= C_CacheInstance:Get("ASMSG_PVP_LADDER_PLAYER", {})
	local data 			= storage[self:GetSelectedCategory()]
	local frame   		= self.Container.RightContainer.BottomContainer

	if data then
		local raceInfo 		= C_CreatureInfo.GetRaceInfo(data.raceID)
		local factionInfo 	= C_CreatureInfo.GetFactionInfo(data.raceID)
		local classLocalizedName, classFileString = GetClassInfo(data.classID)

		frame.Number:SetText(data.rank)
		frame.PlayerName:SetText(data.name)
		frame.Rating:SetText(data.totalRating)

		frame.RaceIcon.Icon:SetTexture(string.format("Interface\\Custom_LoginScreen\\RaceIcon\\RACE_ICON_%s%s", string.upper(raceInfo.clientFileString), S_GENDER_FILESTRING[data.gender]))
		frame.RaceIcon.raceName = raceInfo.raceName

		frame.ClassIcon.Icon:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..string.upper(classFileString))
		frame.ClassIcon.classLocalizedName = classLocalizedName

		frame.FactionIcon.Icon:SetAtlas("objectivewidget-icon-"..self.factionIcons[data.teamID])
		frame.FactionIcon.factionName = _G["FACTION_"..string.upper(PLAYER_FACTION_GROUP[data.teamID])]
	end

	frame.Number:SetShown(data)
	frame.PlayerName:SetShown(data)
	frame.Rating:SetShown(data)
	frame.RaceIcon:SetShown(data)
	frame.ClassIcon:SetShown(data)
	frame.FactionIcon:SetShown(data)

	frame.PlayerNotRank:SetShown(not data)
	frame.Background:SetDesaturated(not data)
	frame.Border:SetDesaturated(not data)
end

function PVPLadderFrameMixin:ResetFrame( dontResetTab )
	self.topBuffer 		= {}
	self.classBuffer 	= {}
	self.searchBuffer 	= {}
	self.searchData  	= {}

	if not dontResetTab then
		self:SetSelectedTab(nil)
	end
end

function PVPLadderFrameMixin:ShowDetailsFrame( playerIndex )
	local selectedTab 		= self:GetSelectedTab()
	local selectedCategory 	= self:GetSelectedCategory()

	self.detailsPlayerIndex = playerIndex

	PVPLadderInfoFrame:ShowFrame(playerIndex)

	if selectedTab and selectedCategory then
		self:UpdateScrollFrame()
	end
end

function PVPLadderFrameMixin:GetDetailsPlayerIndex()
	return self.detailsPlayerIndex
end

function PVPLadderFrameMixin:InitializeScrollFrame( buttonTemplate )
	self.Container.RightContainer.CentralContainer.ScrollFrame.update = function() self:UpdateScrollFrame() end
	HybridScrollFrame_SetDoNotHideScrollBar(self.Container.RightContainer.CentralContainer.ScrollFrame, true)
	HybridScrollFrame_CreateButtons(self.Container.RightContainer.CentralContainer.ScrollFrame, buttonTemplate, 0, -2, nil, nil, nil, -2)
end

function PVPLadderFrameMixin:UpdateScrollFrame( isHideSpinner )
	local scrollFrame = self.Container.RightContainer.CentralContainer.ScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local playerCount = self:GetNumPlayers()
	local detailsPlayerIndex = self:GetDetailsPlayerIndex()

	if isHideSpinner then
		self:HideLoadingSpinner()
	end

	if playerCount == 0 then
		if self:GetSelectedTab() == 2 then
			scrollFrame.TextLabelFrame.Text:SetText(PVP_LADDER_SEARCH_TUTORIAL)
		else
			scrollFrame.TextLabelFrame.Text:SetText(PVP_LADDER_SEARCH_NOT_RESULT)
		end
	end

	scrollFrame.TextLabelFrame:SetShown(playerCount == 0)

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if index <= playerCount then
			local rank, name, raceID, classID, gender, totalRating, _, _, _, _, _, _, teamID = self:GetPlayerInfo(index)
			local classLocalizedName, classFileString = GetClassInfo(classID)
			local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)
			local r, g, b = GetClassColor(classFileString)

			button.FontStringFrame.Number:SetText(rank)
			button.FontStringFrame.PlayerName:SetText(name)
			button.FontStringFrame.PlayerName:SetTextColor(r, g, b)

			button.RaceIcon.Icon:SetTexture(string.format("Interface\\Custom_LoginScreen\\RaceIcon\\RACE_ICON_%s%s", string.upper(raceInfo.clientFileString), S_GENDER_FILESTRING[gender]))
			button.RaceIcon.raceName = raceInfo.raceName

			button.ClassIcon.Icon:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..string.upper(classFileString))
			button.ClassIcon.classLocalizedName = classLocalizedName

			button.FactionIcon.Icon:SetAtlas("objectivewidget-icon-"..self.factionIcons[teamID])
			button.FactionIcon.factionName = _G["FACTION_"..string.upper(PLAYER_FACTION_GROUP[teamID])]

			button.FontStringFrame.Rating:SetText(totalRating)

			button.Background:SetShown(index % 2 ~= 0)

			button.index = index

			if detailsPlayerIndex and detailsPlayerIndex == index then
				button:LockHighlight()
			else
				button:UnlockHighlight()
			end

			button:Show()
		else
			button:Hide()
		end
	end

	local totalHeight = playerCount * buttons[1]:GetHeight() + (playerCount - 1) * 2
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
end

function PVPLadderFrameMixin:ShowLoadingSpinner()
	self.Container.RightContainer.CentralContainer.ScrollFrame.TextLabelFrame:Hide()
	self.Container.RightContainer.CentralContainer.ScrollFrame.Spinner:Show()
end

function PVPLadderFrameMixin:HideLoadingSpinner()
	self.Container.RightContainer.CentralContainer.ScrollFrame.Spinner:Hide()
end

function PVPLadderCategoryMixin:CategoryOnLoad()
	local icon 			= self:GetAttribute("icon")
	local iconAtlas 	= self:GetAttribute("iconAtlas")
	local buttonIndex 	= #self.categoryButtons + 1

	if icon then
		SetPortraitToTexture(self.Icon, "Interface\\Icons\\"..icon)
	end

	if iconAtlas then
		self.Icon:SetAtlas(iconAtlas)
	end

	self.buttonID 		= self:GetID()
	self.buttonIndex	= buttonIndex

	self.categoryButtons[buttonIndex] = self
end

function PVPLadderCategoryMixin:CategoryClick()
	if self:GetSelectedCategory() and self:GetSelectedCategory() == self.buttonID then
		return
	end

	self:SetSelectedCategory(self.buttonID)

	PVPLadderFrame:ShowDetailsFrame(nil)
	PVPLadderFrame:SetSelectedTab(nil)
	PVPLadderFrame.tabButtons[1]:Click()

	for _, button in pairs(self.categoryButtons) do
		if button.buttonID == self:GetSelectedCategory() then
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188)
		else
			button.Background:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
		end
	end
end

function PVPLadderCategoryMixin:SetSelectedCategory( index )
	self.categoryData.selectedCategory = index
end

function PVPLadderCategoryMixin:GetSelectedCategory()
	return self.categoryData.selectedCategory
end

function PVPLadderTabsMixin:TabOnLoad()
	local icon 							= self:GetAttribute("icon")
	local localizedClassName, className = GetClassInfo(self:GetID())
	local buttonIndex 					= #self.tabButtons + 1

	if icon then
		self.Icon:SetTexture("Interface\\Icons\\"..icon)
	else
		self.Icon:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..string.upper(className))
	end

	self.localizedClassName = localizedClassName
	self.buttonID 			= self:GetID()
	self.buttonIndex 		= buttonIndex

	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 3)

	self.tabButtons[buttonIndex] = self
end

function PVPLadderTabsMixin:TabClick()
	if self:GetSelectedTab() and self:GetSelectedTab() == self.buttonIndex then
		self:SetChecked(true)
		return
	end

	PVPLadderFrame:ShowDetailsFrame(nil)
	PVPLadderFrame:ShowLoadingSpinner()
	self:SetSelectedTab(self.buttonIndex)

	local selectedTab 		= self:GetSelectedTab() or 1
	local selectedCategory 	= self:GetSelectedCategory()

	if selectedTab == 1 then
		local data = C_CacheInstance:Get("ASMSG_PVP_LADDER_TOP", {}, CACHE_TIME_TO_LIFE)

		if data[selectedCategory] and data[selectedCategory][1] then
			PVPLadderFrame:UpdateScrollFrame( true )
		else
			SendServerMessage("ACMSG_PVP_LADDER_GET_TOP", selectedCategory)
		end
	elseif selectedTab == 2 then
		PVPLadderFrame.Container.RightContainer.CentralContainer.ScrollFrame.TextLabelFrame.Text:SetText(PVP_LADDER_SEARCH_TUTORIAL)
		PVPLadderFrame:UpdateScrollFrame( true )
	elseif selectedTab > 2 then
		local data 		= C_CacheInstance:Get("ASMSG_PVP_LADDER_CLASS_TOP", {}, CACHE_TIME_TO_LIFE)
		local button  	= self.tabButtons[selectedTab]

		if data[selectedCategory] and (data[selectedCategory][button.buttonID] and data[selectedCategory][button.buttonID][1]) then
			PVPLadderFrame:UpdateScrollFrame( true )
		else
			SendServerMessage("ACMSG_PVP_LADDER_GET_CLASS_TOP", string.format("%d:%d", selectedCategory, self.buttonID))
		end
	end

	for _, button in pairs(self.tabButtons) do
		button:SetChecked(button.buttonIndex == selectedTab)
	end

	-- Ибо на EditBox не работает SetShown.

	if selectedTab == 2 then
		if PVPLadderFrame.searchData[selectedCategory] and PVPLadderFrame.searchData[selectedCategory].ttl then
			PVPLadderFrame.searchData[selectedCategory].ttl = nil
		end

		PVPLadderFrame.Container.RightContainer.TopContainer.SearchBox:SetText("")
		PVPLadderFrame.Container.RightContainer.TopContainer.SearchBox:Show()
		PVPLadderFrame.Container.RightContainer.TopContainer.SearchButton:Show()
	else
		PVPLadderFrame.searchData[selectedCategory] = {}
		PVPLadderFrame.searchData[selectedCategory].ttl = time() + 5
		PVPLadderFrame.Container.RightContainer.TopContainer.SearchBox:Hide()
		PVPLadderFrame.Container.RightContainer.TopContainer.SearchButton:Hide()
	end

	local text = self:GetAttribute("tooltipText") and _G[self:GetAttribute("tooltipText")] or self.localizedClassName
	PVPLadderFrame.Container.RightContainer.TopContainer.TitleFrame:SetShown(selectedTab ~= 2)
	PVPLadderFrame.Container.RightContainer.TopContainer.TitleFrame.TitleText:SetText(text)

	PVPLadderFrame:UpdateSelfPlayerInfo()
end

function PVPLadderTabsMixin:SetSelectedTab( index )
	self.tabData.selectedRightTab = index
end

function PVPLadderTabsMixin:GetSelectedTab()
	return self.tabData.selectedRightTab
end

function PVPLadderInfoFrameMixin:OnLoad()
	self:SetBorder("ButtonFrameTemplateNoPortrait")
	self:SetPortraitShown(false)

	self.closedUIPanels = {
		"PlayerTalentFrame",
		"CharacterFrame"
	}
end

function PVPLadderInfoFrameMixin:OnShow()
	for _, frame in pairs(self.closedUIPanels) do
		frame = _G[frame]

		if frame:IsShown() then
			HideUIPanel(frame)
		end
	end

	self:InitializeScrollFrame()
end

function PVPLadderInfoFrameMixin:OnHide()
	PVPLadderFrame:ShowDetailsFrame(nil)
end

function PVPLadderInfoFrameMixin:RequestInfo(name)
	self:ShowLoadingSpinner()

	self.replayData = {
		[0] = {},
		[1] = {},
		[2] = {},
		[3] = {},
	}
	self.requestForPlayer = name
	SendServerMessage("ACMSG_AR_LAST_REPLAYS", name)
end

function PVPLadderInfoFrameMixin:GetPlayerWithRequest()
	return self.requestForPlayer
end

function PVPLadderInfoFrameMixin:GetReplayInfo( replayIndex )
	local data = self.replayData[PVPLadderFrame:GetSelectedCategory() or 0][replayIndex]

	if not data then
		return
	end

	local replayID 		= data.replayID
	local bracket 		= data.bracket
	local winnerTeam 	= data.winnerTeam
	local playerTeam 	= data.playerTeam
	local team1Rating 	= data.team1Rating
	local team2Rating 	= data.team2Rating
	local team1Players 	= self.replayData[PVPLadderFrame:GetSelectedCategory() or 0][replayIndex].players[1]
	local team2Players 	= self.replayData[PVPLadderFrame:GetSelectedCategory() or 0][replayIndex].players[2]

	return replayID, bracket, winnerTeam, playerTeam, team1Rating, team2Rating, team1Players, team2Players
end

function PVPLadderInfoFrameMixin:GetReplayCount()
	return self.replayData[PVPLadderFrame:GetSelectedCategory() or 0] and #self.replayData[PVPLadderFrame:GetSelectedCategory() or 0] or 0
end

function PVPLadderInfoFrameMixin:ShowFrame( playerIndex )
	if not playerIndex then
		self.index = playerIndex
		self:Hide()

		return
	end

	local rank, name, raceID, classID, gender, totalRating, seasonGames, weekGames, dayGames, seasonWins, weekWins, dayWins = PVPLadderFrame:GetPlayerInfo(playerIndex)
	local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)

	self:RequestInfo(name)

	if self:IsShown() then
		self:UpdateScrollFrame()
	end

	self.TopContainer.StatisticsFrame.PlayerName:SetText(name)
	self.TopContainer.StatisticsFrame.PlayerRace:SetText(raceInfo.raceName)
	self.TopContainer.StatisticsFrame.PlayerRating:SetText(totalRating)

	self.TopContainer.StatisticsFrame.Season:SetFormattedText("|cff00FF00%d|cffFFFFFF/|cffFF0000%d", seasonWins, (seasonGames - seasonWins))
	self.TopContainer.StatisticsFrame.Week:SetFormattedText("|cff00FF00%d|cffFFFFFF/|cffFF0000%d", weekWins, (weekGames - weekWins))
	self.TopContainer.StatisticsFrame.Day:SetFormattedText("|cff00FF00%d|cffFFFFFF/|cffFF0000%d", dayWins, (dayGames - dayWins))

	local winsProc = math.min(math.Round(seasonWins / seasonGames * 100), 100)
	local color = winsProc < 50 and "|cffFF0000" or "|cff00FF00"

	self.TopContainer.StatisticsFrame.AllWinsProc:SetFormattedText(color.."%d%%", winsProc)

	PortraitFrameTemplate_SetTitle(self, name)

	self.index = playerIndex
	ShowUIPanel(self)
end

local BRACKET1_BUTTON_HEIGHT = 48
local BRACKET2_BUTTON_HEIGHT = 68
local BRACKET3_BUTTON_HEIGHT = 88
local BRACKET_BUTTON_OFFSET = 4
local BRACKET_LIST_PADDING = 2

function PVPLadderInfoFrameMixin:InitializeScrollFrame()
	self.CentralContainer.ScrollFrame.update = function() self:UpdateScrollFrame() end
	self.CentralContainer.ScrollFrame.dynamic = function(...) return self:CalculateScrollOffset(...) end
	HybridScrollFrame_SetDoNotHideScrollBar(self.CentralContainer.ScrollFrame, true)
	HybridScrollFrame_CreateButtons(self.CentralContainer.ScrollFrame, "PVPLadderInfoScrollPlayerButtonTemplate", 0, -BRACKET_LIST_PADDING, nil, nil, nil, -BRACKET_BUTTON_OFFSET)

	self:UpdateScrollFrame()
end

function PVPLadderInfoFrameMixin:CalculateScrollOffset(offset)
	local usedHeight = 0

	for i = 1, self:GetReplayCount() do
		local replayID, bracket, winnerTeam, playerTeam, team1Rating, team2Rating, team1Players, team2Players = self:GetReplayInfo(i)
		local height

		if bracket == 1 then
			height = BRACKET1_BUTTON_HEIGHT + BRACKET_BUTTON_OFFSET
		elseif bracket == 2 then
			height = BRACKET2_BUTTON_HEIGHT + BRACKET_BUTTON_OFFSET
		else
			height = BRACKET3_BUTTON_HEIGHT + BRACKET_BUTTON_OFFSET
		end
		if ( usedHeight + height >= offset ) then
			return i - 1, offset - usedHeight
		else
			usedHeight = usedHeight + height
		end
	end
	return 0, 0
end

function PVPLadderInfoFrameMixin:ShowLoadingSpinner()
	self.CentralContainer.ScrollFrame.Spinner:Show()
	self.CentralContainer.ScrollFrame.TextLabelFrame:Hide()
end

function PVPLadderInfoFrameMixin:HideLoadingSpinner()
	self.CentralContainer.ScrollFrame.Spinner:Hide()
end

function PVPLadderInfoFrameMixin:UpdateScrollFrame()
	local scrollFrame = self.CentralContainer.ScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local buttonCount = -offset
	local button, index
	local replayCount = self:GetReplayCount()
	local displayedHeight = 0

	if scrollFrame.Spinner:IsShown() then
		return
	end

	scrollFrame.TextLabelFrame:SetShown(replayCount == 0)

	if self == PVPLadderInfoFrame and PVPLadderFrame:GetSelectedCategory() == 3 then
		scrollFrame.TextLabelFrame.Text:SetText(PVP_LADDER_INFO_BATTLEGROUND_DISABLE)
		scrollFrame.TextLabelFrame:Show()
		replayCount = 0
	else
		scrollFrame.TextLabelFrame.Text:SetText(PVP_LADDER_SEARCH_NOT_RESULT)
	end

	local totalHeight = replayCount * (BRACKET2_BUTTON_HEIGHT + BRACKET_BUTTON_OFFSET) + BRACKET_LIST_PADDING * 2

	for i = 1, replayCount do
		local replayID, bracket, winnerTeam, playerTeam, team1Rating, team2Rating, team1Players, team2Players = self:GetReplayInfo(i)
		if bracket == 3 then
			totalHeight = totalHeight + BRACKET3_BUTTON_HEIGHT - BRACKET2_BUTTON_HEIGHT
		end
	end

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if index <= replayCount then
			local replayID, bracket, winnerTeam, playerTeam, team1Rating, team2Rating, team1Players, team2Players = self:GetReplayInfo(index)
			local resultLabel = {[0] = button.ResultLeft, [1] = button.ResultRight}

			button.RatingLeft:SetText(team1Rating)
			button.RatingRight:SetText(team2Rating)

			if winnerTeam == 2 then
				button.ResultLeft:SetText(VICTORY_TEXT2)
				button.ResultLeft:SetTextColor(1, 0.82, 0)

				button.ResultRight:SetText(VICTORY_TEXT2)
				button.ResultRight:SetTextColor(1, 0.82, 0)
			else
				resultLabel[0]:SetText(WIN)
				resultLabel[0]:SetTextColor(0, 1, 0)
				resultLabel[1]:SetText(LOSS)
				resultLabel[1]:SetTextColor(1, 0, 0)
			end

			for i = 0, 1 do
				if winnerTeam == 2 or i == playerTeam then
					resultLabel[i]:Show()
				else
					resultLabel[i]:Hide()
				end
			end

			for i = 1, bracket do
				local leftPlayerFrame 	= button.playerLeftButtons[i]
				local leftPlayer 		= team1Players[i]

				local rightPlayerFrame 	= button.playerRightButtons[i]
				local rightPlayer 		= team2Players[i]


				if leftPlayer then
					leftPlayerFrame.PlayerName:SetText(leftPlayer.name)
					leftPlayerFrame.ClassIcon.Icon:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..leftPlayer.classFileString)
					leftPlayerFrame.ClassIcon.className = leftPlayer.className
				end

				leftPlayerFrame:SetShown(leftPlayer)

				if rightPlayer then
					rightPlayerFrame.PlayerName:SetText(rightPlayer.name)
					rightPlayerFrame.ClassIcon.Icon:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..rightPlayer.classFileString)
					rightPlayerFrame.ClassIcon.className = rightPlayer.className
				end

				rightPlayerFrame:SetShown(rightPlayer)
			end

			button:SetHeight(bracket == 1 and BRACKET1_BUTTON_HEIGHT or bracket == 2 and BRACKET2_BUTTON_HEIGHT or BRACKET3_BUTTON_HEIGHT)

			button.PlayerLeft2:SetShown(bracket ~= 1)
			button.PlayerRight2:SetShown(bracket ~= 1)
			button.PlayerLeft3:SetShown(bracket == 3)
			button.PlayerRight3:SetShown(bracket == 3)

			button.replayID = replayID

			button:Show()
		else
			button:Hide()
		end

		displayedHeight = displayedHeight + buttons[i]:GetHeight()
	end

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end

function EventHandler:ASMSG_PVP_LADDER_TOP( msg )
	local playerData 		= C_Split(msg, "|")
	local selectedCategory 	= tonumber(table.remove(playerData, 1))

	if selectedCategory == E_LADDER_BRACKET.RENEGADE then
		Hook:FireEvent("RENEGADE_LADDER_TOP", playerData)
		return
	end

	if #playerData > 0 then
		for _, playerString in pairs(playerData) do
			local playerInfo = C_Split(playerString, ":")
			local storage = C_CacheInstance:Get("ASMSG_PVP_LADDER_TOP", {}, CACHE_TIME_TO_LIFE)

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
			local teamID 		= tonumber(playerInfo[13])

			teamID = SERVER_FACTION_TO_GAME_FACTION[teamID]

			if rank and name then
				if not storage[selectedCategory] then
					storage[selectedCategory] = {}
				end

				storage[selectedCategory][#storage[selectedCategory] + 1] = {
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
					teamID 		= teamID
				}
			end
		end
	else
		PVPLadderFrame:ResetFrame(true)
		C_CacheInstance:Set("ASMSG_PVP_LADDER_TOP", {}, CACHE_TIME_TO_LIFE)
	end

	PVPLadderFrame:UpdateScrollFrame( true )
end

function EventHandler:ASMSG_PVP_LADDER_CLASS_TOP( msg )
	-- print("ASMSG_PVP_LADDER_CLASS_TOP", msg)
	local playerData 		= C_Split(msg, "|")
	local selectedCategory 	= tonumber(table.remove(playerData, 1))
	local _classID 			= tonumber(table.remove(playerData, 1))

	if selectedCategory == E_LADDER_BRACKET.RENEGADE then
		Hook:FireEvent("RENEGADE_LADDER_CLASS_TOP", playerData)
		return
	end

	local storage

	if #playerData > 0 then
		for _, playerString in pairs(playerData) do
			local playerInfo = C_Split(playerString, ":")
			storage 		 = C_CacheInstance:Get("ASMSG_PVP_LADDER_CLASS_TOP", {}, CACHE_TIME_TO_LIFE)

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
			local teamID 		= tonumber(playerInfo[13])

			teamID = SERVER_FACTION_TO_GAME_FACTION[teamID]

			if rank and name then
				if not storage[selectedCategory] then
					storage[selectedCategory] = {}
				end

				if not storage[selectedCategory][classID] then
					storage[selectedCategory][classID] = {}
				end

				storage[selectedCategory][classID][#storage[selectedCategory][classID] + 1] = {
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
					teamID 		= teamID
				}
			end
		end
	else
		PVPLadderFrame:ResetFrame(true)
		local data = C_CacheInstance:Get("ASMSG_PVP_LADDER_CLASS_TOP", {}, CACHE_TIME_TO_LIFE)

		if data[selectedCategory] and data[selectedCategory][_classID] then
			data[selectedCategory][_classID] = nil
		end
	end

	PVPLadderFrame:UpdateScrollFrame( true )
end

function EventHandler:ASMSG_PVP_LADDER_PLAYER( msg )
	-- print("ASMSG_PVP_LADDER_PLAYER", msg)
	local storage 			= {}
	local playerData 		= C_Split(msg, "|")
	local selectedCategory 	= tonumber(table.remove(playerData, 1))

	if selectedCategory == E_LADDER_BRACKET.RENEGADE then
		Hook:FireEvent("RENEGADE_LADDER_PLAYER", playerData)
		return
	end

	if playerData[1] then
		local playerInfo 		= C_Split(playerData[1], ":")

		storage 	 = C_CacheInstance:Get("ASMSG_PVP_LADDER_PLAYER", {})

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
		local teamID 		= tonumber(playerInfo[13])

		teamID = SERVER_FACTION_TO_GAME_FACTION[teamID]

		if rank and name then
			storage[selectedCategory] = {
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
				teamID 		= teamID
			}

			PVPLadderFrame:UpdateSelfPlayerInfo()
		end
	else
		storage = C_CacheInstance:Get("ASMSG_PVP_LADDER_PLAYER", {}, CACHE_TIME_TO_LIFE)
		storage[selectedCategory] = nil
	end
end

function EventHandler:ASMSG_PVP_LADDER_SEARCH_RESULT( msg )
	-- print("ASMSG_PVP_LADDER_SEARCH_RESULT", msg)

	local textLabel = PVPLadderFrame.Container.RightContainer.CentralContainer.ScrollFrame.TextLabelFrame.Text

	local playerData 		= C_Split(msg, "|")
	local selectedCategory 	= tonumber(table.remove(playerData, 1))

	if selectedCategory == E_LADDER_BRACKET.RENEGADE then
		Hook:FireEvent("RENEGADE_LADDER_SEARCH_RESULT", playerData)
		return
	end

	PVPLadderFrame.Container.RightContainer.TopContainer.SearchButton:StartDelay()

	PVPLadderFrame.searchBuffer[selectedCategory] = {}

	if msg == "-1" then
		textLabel:SetText(PVP_LADDER_SEARCH_INVALID_PARAMS)
		PVPLadderFrame:UpdateScrollFrame( true )
	elseif msg == "-2" then
		textLabel:SetText(PVP_LADDER_SEARCH_DELAY)
		PVPLadderFrame:UpdateScrollFrame( true )
	else
		if #playerData == 0 then
			textLabel:SetText(PVP_LADDER_SEARCH_NOT_RESULT)
			PVPLadderFrame:UpdateScrollFrame( true )
			return
		end
	end

	for _, playerString in pairs(playerData) do
		local playerInfo = C_Split(playerString, ":")

		if #playerInfo >= 1 then
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
			local teamID 		= tonumber(playerInfo[13])

			teamID = SERVER_FACTION_TO_GAME_FACTION[teamID]

			if rank and name then
				PVPLadderFrame.searchBuffer[selectedCategory][#PVPLadderFrame.searchBuffer[selectedCategory] + 1] = {
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
					teamID 		= teamID
				}
			end
		end
	end

	PVPLadderFrame:UpdateScrollFrame( true )
end

local bracketOverride = {
	[0] = 3,
	[1] = 2,
	[2] = 1,
	[3] = 5
}

function EventHandler:ASMSG_AR_LAST_REPLAYS( msg )
	if not msg then
		return
	end

	local replayStorage 	= C_Split(msg, "|")
	local bracketID		 	= tonumber(table.remove(replayStorage, 1))

	if bracketID == 5 then
		bracketID = 2
	end

	local playerWithRequest = PVPLadderInfoFrame:GetPlayerWithRequest()

	PVPLadderInfoFrame.replayData[bracketID] = {}

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

			PVPLadderInfoFrame.replayData[bracketID][index] = {
				replayID 	= replayID,
				winnerTeam 	= winnerTeam,
				bracket 	= bracketOverride[bracketID],
				team1Rating = rating[winTeam],
				team2Rating = rating[lossTeam],
			}

			PVPLadderInfoFrame.replayData[bracketID][index].players = {
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

				table.insert(PVPLadderInfoFrame.replayData[bracketID][index].players[1], {
					name 			= team1PlayerName,
					className 		= team1ClassName,
					classFileString = team1ClassFileString
				})

				table.insert(PVPLadderInfoFrame.replayData[bracketID][index].players[2], {
					name 			= team2PlayerName,
					className 		= team2ClassName,
					classFileString = team2ClassFileString
				})

				if playerWithRequest then
					if playerWithRequest == team1PlayerName then
						PVPLadderInfoFrame.replayData[bracketID][index].playerTeam = 0
					elseif playerWithRequest == team2PlayerName then
						PVPLadderInfoFrame.replayData[bracketID][index].playerTeam = 1
					end
				end
			end
		end
	end

	PVPLadderInfoFrame:HideLoadingSpinner()
	PVPLadderInfoFrame:UpdateScrollFrame()
end