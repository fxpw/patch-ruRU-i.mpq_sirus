--	Filename:	Sirus_GuildSystem.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

UIPanelWindows["GuildFrame"] = { area = "left", pushable = 1, whileDead = 1, xOffset = "15", yOffset = "-10", width = 370, height = 424 }
GUILDS_SUBFRAMES = { "GuildRosterFrame", "GuildPerksFrame", "GuildRewardsFrame", "GuildInfoFrame" }

local GuildInvite = GuildInvite

local GUILD_LEVEL_DATA = {}
local GUILD_REPUTATION_DATA = {}
GUILD_CHARACTER_ILEVEL_DATA = {}
local GUILD_MEMBER_INFO_DATA = {}
local GUILD_MEMBER_INFO_BY_NAME_DATA = {}
local currentGuildView
local columnSortData = {}

local GuildRosterViewDropDown_OldValue

local GUILD_ROSTER_COLUMN_DATA = {
	level = { width = 32, text = REQ_LEVEL_ABBR, stringJustify="CENTER" },
	ilevel = { width = 38, text = ILEVEL_ABBR, sortType = "ilevel", stringJustify="CENTER" },
	class = { width = 32, text = CLASS_ABBR, hasIcon = true },
	name = { width = 81, text = NAME_ABBR, stringJustify="LEFT" },
	wideName = { width = 100, text = NAME_ABBR, sortType = "name", stringJustify="LEFT" },
	rank = { width = 76, text = RANK, stringJustify="LEFT" },
	note = { width = 76, text = LABEL_NOTE, stringJustify="LEFT" },
	online = { width = 76, text = LASTONLINE, stringJustify="LEFT" },
	zone = { width = 114, text = ZONE, stringJustify="LEFT" },
	bgrating = { width = 83, text = BG_RATING_ABBR, stringJustify="RIGHT" },
	arenarating = { width = 83, text = ARENA_RATING, stringJustify="RIGHT" },
	weeklyxp = { width = 144, text = GUILD_XP_WEEKLY, stringJustify="RIGHT", hasBar = true },
	totalxp = { width = 144, text = GUILD_XP_TOTAL, stringJustify="RIGHT", hasBar = true },
	achievement = { width = 144, text = ACHIEVEMENT_POINTS, stringJustify="RIGHT", sortType="achievementpoints", hasBar = true },
	skill = { width = 63, text = SKILL_ABBR, stringJustify="LEFT" },
}

local GUILD_ROSTER_COLUMNS = {
	playerStatus = { "level", "ilevel", "class", "wideName", "zone" },
	guildStatus = { "name", "rank", "note", "online" },
	weeklyxp = { "level", "class", "wideName", "weeklyxp" },
	totalxp = { "level", "class", "wideName", "totalxp" },
	pvp = { "level", "class", "name", "bgrating", "arenarating" },
	achievement = { "level", "class", "wideName", "achievement" },
	tradeskill = { "wideName", "zone", "skill" },
}

local GUILD_BUTTON_HEIGHT = 84;
local GUILD_COMMENT_HEIGHT = 50;
local GUILD_COMMENT_BORDER = 10;
local INTEREST_TYPES = {"QUEST", "DUNGEON", "RAID", "PVP", "RP"};

local GUILD_ROSTER_BUTTON_OFFSET = 2;
local GUILD_ROSTER_BUTTON_HEIGHT = 20;

StaticPopupDialogs["GUILD_REWARDS_CONFIRM_BUY"] = {
	text = CONFIRM_HIGH_COST_ITEM,
	button1 = BUY,
	button2 = CANCEL,
	OnAccept = function(self, data)
		SendAddonMessage("ACMSG_GUILD_GET_REPUTATION_REWARD", data.itemID, "WHISPER", UnitName("player"))
	end,
	OnShow = function(self, data)
		MoneyFrame_Update(self.moneyFrame, data.moneyCost)
	end,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
}

local TradeSkillMap = {171, 164, 333, 202, 182, 773, 755, 165, 186, 393, 197}
local TradeSkillData = {
	[171] = {headerName = TRADESKILL_ALCHEMY, 			iconTexture = "trade_alchemy", 					isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[164] = {headerName = TRADESKILL_BLACKSMITHING, 	iconTexture = "trade_blacksmithing", 			isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[333] = {headerName = TRADESKILL_ENCHANTING, 		iconTexture = "trade_engraving", 				isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[202] = {headerName = TRADESKILL_ENGINEERING, 		iconTexture = "trade_engineering", 				isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[182] = {headerName = TRADESKILL_HERBALISM, 		iconTexture = "trade_herbalism", 				isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[773] = {headerName = TRADESKILL_INSCRIPTION, 		iconTexture = "inv_inscription_tradeskill01", 	isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[755] = {headerName = TRADESKILL_JEWELCRAFTING, 	iconTexture = "inv_misc_gem_01", 				isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[165] = {headerName = TRADESKILL_LEATHERWORKING, 	iconTexture = "trade_leatherworking", 			isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[186] = {headerName = TRADESKILL_MINING, 			iconTexture = "trade_mining", 					isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[393] = {headerName = TRADESKILL_SKINNING, 			iconTexture = "inv_misc_pelt_wolf_01", 			isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
	[197] = {headerName = TRADESKILL_TAILORING, 		iconTexture = "trade_tailoring", 				isCollapsed = true, numVisible = 0, numPlayers = 0, numOnline = 0, players = {}},
}

local PH_GuildChallengeData = {
	[1] = {
		current = 4,
		max = 25,
		gold = 0,
		exp = 1000,
		buildPoint = 100
	},
	[2] = {
		current = 5,
		max = 5,
		gold = 0,
		exp = 1517,
		buildPoint = 30
	},
	[3] = {
		current = 0,
		max = 2,
		gold = 1000,
		exp = 0,
		buildPoint = 10
	},
	[4] = {
		current = 0,
		max = 1,
		gold = 4211,
		exp = 0,
		buildPoint = 25
	},
}

function GetGuildChallengeInfo( index )
	if PH_GuildChallengeData[index] then
		local data = PH_GuildChallengeData[index]
		return index, data.current, data.max, data.gold, data.exp, data.buildPoint
	end

	return nil
end

local TradeSkillbuffer = {}
local playersOnline = {}
function GenerateGuildTradeSkillInfo()
	playersOnline = {}
	TradeSkillbuffer = {}

	for skillID, data in pairs(TradeSkillData) do
		if data then
			data.numPlayers = 0
			data.numOnline = 0

			local numPlayers = tCount(data.players) or 0

			TradeSkillbuffer[#TradeSkillbuffer + 1] = {skillID, data.isCollapsed, data.iconTexture, data.headerName, data.numOnline, data.numVisible, numPlayers, playerName, class, online, zone, skill, classFileName}

			for _, player in pairs(data.players) do
				if GUILD_MEMBER_INFO_BY_NAME_DATA[player.name] then
					local playerName, playerRank, playerRankIndex, playerLevel, playerClass, playerZone, playerNote, playerOfficernote, playerOnline = unpack(GUILD_MEMBER_INFO_BY_NAME_DATA[player.name])

					if playerOnline then
						if not playersOnline[skillID] then
							playersOnline[skillID] = 0
						end

						playersOnline[skillID] = playersOnline[skillID] + 1
					end

					if data.isCollapsed == false then
						local classFileName = GetClassFile(playerClass)
						TradeSkillbuffer[#TradeSkillbuffer + 1] = {skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, playerClass, playerOnline, playerZone, player.currentSkill, classFileName}
					end
				end
			end
		end
	end

	GuildRoster_UpdateTradeSkills()
end

function GetGuildTradeSkillInfo( index )
	if not index then
		return
	end

	local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, class, online, zone, skill, classFileName

	if TradeSkillbuffer[index] then
		skillID 		= TradeSkillbuffer[index][1]
		isCollapsed 	= TradeSkillbuffer[index][2]
		if TradeSkillbuffer[index][3] then
			iconTexture 	= "Interface\\ICONS\\"..TradeSkillbuffer[index][3]
		end
		headerName 		= TradeSkillbuffer[index][4]
		numOnline 		= playersOnline[skillID] or 0
		numVisible 		= TradeSkillbuffer[index][6]
		numPlayers 		= TradeSkillbuffer[index][7]
		playerName 		= TradeSkillbuffer[index][8]
		class 			= TradeSkillbuffer[index][9]
		online 			= TradeSkillbuffer[index][10]
		zone 			= TradeSkillbuffer[index][11]
		skill 			= TradeSkillbuffer[index][12]
		classFileName	= TradeSkillbuffer[index][13]
	end

	return skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, class, online, zone, skill, classFileName
end

function GetNumGuildTradeSkill()
	return #TradeSkillbuffer == 0 and 11 or #TradeSkillbuffer
end

function GetGuildMemberRecipes( playerName, skillID )
	if TradeSkillData[skillID] then
		if TradeSkillData[skillID].players[playerName] then
			local data = TradeSkillData[skillID].players[playerName]
			TradeSkillFrame.isGuildOpen = true
			ItemRefTooltip:SetHyperlink(string.format("trade:%d:%d:%d:%X:%s", data.spellID, data.currentSkill, data.nextSkill, data.GUID, data.hash))
		end
	end
end

function GuildFrame_OnLoad( self, ... )
	GuildFrame_TabClicked(1)

	local guildName = GetGuildInfo("player")
	GuildFrameTitleText:SetText(guildName)

	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:RegisterEvent("GUILD_MOTD")
	self:RegisterEvent("PLAYER_LOGIN")

	Hook:RegisterCallback("GUILD", "ASMSG_GUILD_TEAM", GuildFrame_UpdateFactionIcon)
end

function GuildFrame_OnShow( self, ... )
	local level, experience, nextLevelxperience, remaining = GetGuildXP()
	local onlinePlayer, totalPlayer = GetGuildOnline()

	GuildFrame_TabClicked(1)
	UpdateMicroButtons()
	MicroButtonPulseStop(GuildMicroButton)

	self.needUpdateTradeSkill = true
	GuildRosterViewDropDown_OldValue = nil

	GuildLevelFrameText:SetText(level)
	GuildRosterFrameMembersCount:SetFormattedText("%s / %s", onlinePlayer, totalPlayer)

	GuildFrame_UpdateFactionIcon()
	GuildRoster_SetView()
	UIDropDownMenu_SetText(GuildRosterViewDropdown, PLAYER_STATUS)

	if not self.isGuildRecruitmentSettings then
		RequestGuildRecruitmentSettings();

		self.isGuildRecruitmentSettings = true;
	end

	PlaySound("igCharacterInfoOpen")
end

function GuildFrame_UpdateFactionIcon()
	local playerFactionTag = UnitFactionGroup("player")
	local factionTag = C_CacheInstance:Get("ASMSG_GUILD_TEAM", playerFactionTag)
	GuildFactionFrame.Icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionTag)
end

function GuildFrame_RegisterPopup(frame)
	tinsert(GUILDFRAME_POPUPS, frame:GetName())
end

function GuildTextEditFrame_OnLoad(self)
	GuildFrame_RegisterPopup(self);
	GuildTextEditBox:SetTextInsets(4, 0, 4, 4);
	GuildTextEditBox:SetSpacing(2);
end

function GuildFrame_OnEvent( self, event, ... )
	if event == "PLAYER_GUILD_UPDATE" then
		if ( IsInGuild() ) then
			local guildName = GetGuildInfo("player")
			GuildFrameTitleText:SetText(guildName)

			GuildInfoFrame_UpdatePermissions()
		else
			local button = GuildMicroButton
			button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-GUILD-Up")
			button:SetPushedTexture("Interface\\Buttons\\UI-MicroButton-GUILD-Down")
			button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-GUILD-Disabled")
			GuildMicroButtonTabard:Hide()

			if ( self:IsShown() ) then
				HideUIPanel(self)
			end
		end
	elseif event == "GUILD_MOTD" then
		GuildInfoMOTD:SetText(..., true)
	elseif event == "PLAYER_LOGIN" then
		if IsInGuild() then
			SendAddonMessage("ACMSG_GUILD_EMBLEM_REQUEST", nil, "WHISPER", UnitName("player"))
			SendAddonMessage("ACMSG_GUILD_ILVLS_REQUEST", nil, "WHISPER", UnitName("player"))
		end
	end
end

function GuildFrame_OnHide( self, ... )
	UpdateMicroButtons()

	GuildMemberDetailFrame:Hide()
	GuildControlPopupFrame:Hide()
	GuildLogFrame:Hide()
	GuildTextEditFrame:Hide()

	self.needUpdateTradeSkill = true
	GuildRosterViewDropDown_OldValue = nil

	PlaySound("igCharacterInfoClose")
end

function GuildFrame_Toggle()
	if IsInGuild() then
		if GetGuildXP() and GetGuildReputation() and GetGuildNumPerks() > 0 and GetGuildNumRewards() > 0 then
			if ( GuildFrame:IsShown() ) then
				HideUIPanel(GuildFrame)
			else
				ShowUIPanel(GuildFrame)
				GuildFrame_TabClicked(1)
			end
		end
	end
end

function GuildFrame_TabClicked( newID )
	local level, experience, nextLevelxperience, remaining = GetGuildXP()
	local reputationRank, reputationMin, reputationMax = GetGuildReputation()

	GUILD_LEVEL_DATA = {
		level 				= level,
		experience 			= experience,
		nextLevelxperience 	= nextLevelxperience,
		remaining 			= remaining,
	}

	GUILD_REPUTATION_DATA = {
		reputationRank 	= reputationRank,
		reputationMin 	= reputationMin,
		reputationMax 	= reputationMax,
	}

	local newFrame = _G[GUILDS_SUBFRAMES[newID]]
	local oldFrame = _G[GUILDS_SUBFRAMES[GuildFrame.selectedTab or 1]]
	if ( newFrame ) then
		if ( oldFrame ) then
			oldFrame:Hide()
		end

		ShowUIPanel(GuildFrame)
		newFrame:Show()
		GuildXPFrame:Show()
		GuildMemberDetailFrame:Hide()
		GuildControlPopupFrame:Hide()
		GuildLogFrame:Hide()
		GuildTextEditFrame:Hide()

		if newID == 1 then
			GuildXPFrame:Hide()
			GuildFrameInset:SetPoint("TOPLEFT", 4, -90)
			GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26)
			GuildRoster()
			GuildRoster_Update()
		elseif newID == 2 then
			local data = GUILD_LEVEL_DATA

			ButtonFrameTemplate_HideButtonBar(GuildFrame)
			GuildFrameInset:SetPoint("TOPLEFT", 4, -65)
			GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44)

			GuildBar_SetProgress(GuildXPBar, data.experience, data.nextLevelxperience, data.remaining)
			GuildXPFrame.Text:SetFormattedText(GUILD_LEVEL, data.level or 1);
			GuildPerks_Update()
		elseif newID == 3 then
			local data = GUILD_REPUTATION_DATA

			ButtonFrameTemplate_HideButtonBar(GuildFrame)
			GuildFrameInset:SetPoint("TOPLEFT", 4, -65)
			GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 44)

			GuildBar_SetProgress(GuildXPBar, data.reputationMin, data.reputationMax, 0)
			GuildXPFrame.Text:SetText(GUILD_REPUTATION)
			GuildRewards_Update()
		elseif newID == 4 then
			ButtonFrameTemplate_ShowButtonBar(GuildFrame)
			GuildFrameInset:SetPoint("TOPLEFT", 4, -65)
			GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26)
			GuildXPFrame:Hide()
			if GuildMicroButtonHelpBox:IsShown() then
				GuildMicroButtonHelpBox:Hide()
			end
		end
	end

	for i = 1, 4 do
		local tab = _G["GuildFrameRightTab"..i]

		if tab then
			tab:SetChecked(tab:GetID() == newID)
		end
	end

	GuildFrame.selectedTab = newID
end

function GuildRosterButton_SetStringText(buttonString, text, isOnline, class)
	buttonString:SetText(text)
	if ( isOnline ) then
		if ( class ) then
			local classColor = RAID_CLASS_COLORS[class]
			buttonString:SetTextColor(classColor.r, classColor.g, classColor.b)
		else
			buttonString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	else
		buttonString:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
end

function GuildRosterFrame_OnLoad( self, ... )
	GuildRosterContainer.update = GuildRoster_Update
	HybridScrollFrame_CreateButtons(GuildRosterContainer, "GuildRosterButtonTemplate", 0, 0, "TOPLEFT", "TOPLEFT", 0, -2, "TOP", "BOTTOM")
	GuildRosterContainerScrollBar.doNotHide = true
	GuildRosterShowOfflineButton:SetChecked(GetGuildRosterShowOffline())

	self:RegisterEvent("GUILD_ROSTER_UPDATE")

	GuildRoster_SetView()
	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView)
end

function GuildRosterFrame_OnEvent( self, event, ... )
	if ( not self:IsShown() ) then
		return
	end

	if event == "GUILD_ROSTER_UPDATE" then
		local arg1 = ...
		if ( arg1 ) then
			GuildRoster()
		end
		GUILD_MEMBER_INFO_DATA = {}
		GUILD_MEMBER_INFO_BY_NAME_DATA = {}

		local numcharacter = GetNumGuildMembers()

		for i = 1, numcharacter do
			local name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i)
			local category = GetGuildCharacterCategory(name)
			local lastonline = GuildFrame_GetLastOnline(i)

			if not name then
				break
			end

			table.insert(GUILD_MEMBER_INFO_DATA, { name, rank, rankIndex, level, class, zone, note, officernote, online, category, i, lastonline })
			GUILD_MEMBER_INFO_BY_NAME_DATA[name] = GUILD_MEMBER_INFO_DATA[i]
		end

		if GuildMemberDetailFrame:IsVisible() then
			GuildMemberDetailSetInfo()
		end

		if columnSortData and columnSortData[1] and columnSortData[2] then
			GuildRoster_SortByColumn( columnSortData[1], columnSortData[2] )
		end
		GuildRoster_Update()
		GuildInfoFrame_UpdatePermissions()
		GuildInfoFrame_UpdateText()
	end
end

function GuildRosterFrame_OnShow( self, ... )
	GuildRoster_Update()
end

function GuildFramePopup_Show(frame)
	local name = frame:GetName()
	for index, value in ipairs(GUILDFRAME_POPUPS) do
		if ( name ~= value ) then
			if _G[value] then
				_G[value]:Hide()
			end
		end
	end
	frame:Show()
end

function GuildRosterTradeSkillHeader_OnClick(self)
	TradeSkillData[self.skillID].isCollapsed = not self.collapsed
	GenerateGuildTradeSkillInfo() -- ¯\_(ツ)_/¯
end

function GuildRosterButton_OnClick( self, button, ... )
	CloseDropDownMenus()
	if currentGuildView == "tradeskill" then
		local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, class, online, zone, skill, classFileName = GetGuildTradeSkillInfo(self.guildIndex)
		if ( button == "LeftButton" ) then
			-- if TradeSkillFrame and TradeSkillFrame:IsShown() then
			-- HideUIPanel(TradeSkillFrame)
			-- else
			GetGuildMemberRecipes(playerName, skillID)
			-- end
		else
			FriendsFrame_ShowDropdown(playerName, online)
		end
	else
		if ( button == "LeftButton" ) then
			if ( GuildMemberDetailFrame:IsShown() and self.guildIndex == GuildFrame.selectedGuildMember ) then
				GuildFrame.selectedGuildMember = 0

				SetGuildRosterSelection(0)
				GuildMemberDetailFrame:Hide()
			else
				GuildFrame.selectedGuildMember = self.guildIndex
				GuildFrame.selectedGuildMemberName = self.name

				SetGuildRosterSelection(self.guildIndex)
				GuildFramePopup_Show(GuildMemberDetailFrame)
				CloseDropDownMenus()

				GuildMemberDetailSetInfo()
			end
			GuildRoster_Update()
		else
			local guildIndex = self.guildIndex
			if not GUILD_MEMBER_INFO_DATA[guildIndex] then
				return
			end
			local name, rank, rankIndex, level, class, zone, note, officernote, online, categoryID = unpack(GUILD_MEMBER_INFO_DATA[guildIndex])
			FriendsFrame_ShowDropdown(name, online)
		end
	end
end

function GuildRosterButton_OnEnter( self, ... )
	if ( self.online and currentGuildView ~= "tradeskill" ) then
		GameTooltip_AddNewbieTip(self, GUILD_MEMBER_OPTIONS, 1.0, 1.0, 1.0, GUILD_HELP_1, 1)
		if self.categoryName then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(self.categoryName, 1, 1, 1, true)
			GameTooltip:AddLine(PLAYER_CATEGORY_HELP_1)
			GameTooltip:Show()
		end
	end
end

function GuildMemberDetailSetInfo()
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
	local maxRankIndex = GuildControlGetNumRanks() - 1

	if not GUILD_MEMBER_INFO_BY_NAME_DATA[GuildFrame.selectedGuildMemberName] then
		return
	end

	local name, rank, rankIndex, level, class, zone, note, officernote, online, _, index = unpack(GUILD_MEMBER_INFO_BY_NAME_DATA[GuildFrame.selectedGuildMemberName])

	GuildFrame.selectedGuildMemberIndex = index

	GuildMemberDetailName:SetText(name)
	GuildMemberDetailLevel:SetFormattedText(FRIENDS_LEVEL_TEMPLATE_2, level, class)
	GuildMemberDetailZoneText:SetText(zone)
	GuildMemberDetailRankText:SetText(rank)

	if ( online ) then
		GuildMemberDetailOnlineText:SetText(GUILD_ONLINE_LABEL)
	else
		GuildMemberDetailOnlineText:SetText(GuildFrame_GetLastOnline(index))
	end

	if ( CanEditPublicNote() ) then
		PersonalNoteText:SetTextColor(1.0, 1.0, 1.0)
		if ( (not note) or (note == "") ) then
			note = GUILD_NOTE_EDITLABEL
		end
	else
		PersonalNoteText:SetTextColor(0.65, 0.65, 0.65)
	end

	GuildMemberNoteBackground:EnableMouse(CanEditPublicNote())
	PersonalNoteText:SetText(note)

	if ( ( CanGuildPromote() and rankIndex > guildRankIndex + 1 ) or ( CanGuildDemote() and rankIndex < maxRankIndex and rankIndex > guildRankIndex ) ) then
		GuildMemberDetailRankLabel:SetHeight(20)
		GuildMemberRankDropdown:Show();
		UIDropDownMenu_SetText(GuildMemberRankDropdown, rank)

		if not GuildMemberRankDropdown.newRankIndex or GuildMemberRankDropdown.newRankIndex == rankIndex + 1 then
			UIDropDownMenu_EnableDropDown(GuildMemberRankDropdown)
			GuildMemberRankDropdown.newRankIndex = nil
		end
	else
		GuildMemberDetailRankLabel:SetHeight(0)
		GuildMemberRankDropdown:Hide()
	end

	if ( CanViewOfficerNote() ) then
		if ( CanEditOfficerNote() ) then
			if ( (not officernote) or (officernote == "") ) then
				officernote = GUILD_OFFICERNOTE_EDITLABEL
			end
			OfficerNoteText:SetTextColor(1.0, 1.0, 1.0)
		else
			OfficerNoteText:SetTextColor(0.65, 0.65, 0.65)
		end
		GuildMemberOfficerNoteBackground:EnableMouse(CanEditOfficerNote())
		OfficerNoteText:SetText(officernote)

		GuildMemberDetailOfficerNoteLabel:Show()
		GuildMemberOfficerNoteBackground:Show()
		GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_OFFICER_HEIGHT + GuildMemberDetailRankLabel:GetHeight())
	else
		GuildMemberDetailOfficerNoteLabel:Hide()
		GuildMemberOfficerNoteBackground:Hide()
		GuildMemberDetailFrame:SetHeight(GUILD_DETAIL_NORM_HEIGHT + GuildMemberDetailRankLabel:GetHeight())
	end

	if ( CanGuildRemove() and ( rankIndex >= 1 ) and ( rankIndex > guildRankIndex ) ) then
		GuildMemberRemoveButton:Enable()
	else
		GuildMemberRemoveButton:Disable()
	end
	if ( (UnitName("player") == name) or (not online) or isMobile ) then
		GuildMemberGroupInviteButton:Disable()
	else
		GuildMemberGroupInviteButton:Enable()
	end
end

function GuildMemberRankDropdown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildMemberRankDropdown_Initialize)
	UIDropDownMenu_SetWidth(GuildMemberRankDropdown, 159 - GuildMemberDetailRankLabel:GetWidth())
	UIDropDownMenu_JustifyText(GuildMemberRankDropdown, "LEFT")
end

function GuildMemberRankDropdown_Initialize(self)
	local numRanks = GuildControlGetNumRanks()
	local name, _, memberRankIndex = nil, nil, 0

	if GuildFrame.selectedGuildMemberName and GUILD_MEMBER_INFO_BY_NAME_DATA[GuildFrame.selectedGuildMemberName] then
		name, _, memberRankIndex = unpack(GUILD_MEMBER_INFO_BY_NAME_DATA[GuildFrame.selectedGuildMemberName])
	end

	memberRankIndex = memberRankIndex + 1
	local _, _, userRankIndex = GetGuildInfo("player")
	userRankIndex = userRankIndex + 1

	local highestRank = userRankIndex + 1
	if not ( CanGuildPromote() ) then
		highestRank = memberRankIndex
	end
	local lowestRank = numRanks
	if not ( CanGuildDemote() ) then
		lowestRank = memberRankIndex
	end

	for listRank = highestRank, lowestRank do
		local info = UIDropDownMenu_CreateInfo()
		info.text = GuildControlGetRankName(listRank)
		info.func = GuildMemberRankDropdown_OnClick
		info.checked = listRank == memberRankIndex
		info.value = listRank
		info.arg1 = listRank
		UIDropDownMenu_AddButton(info)
	end
end

function GuildMemberRankDropdown_OnClick(_, newRankIndex)
	local name, _, rankIndex = unpack(GUILD_MEMBER_INFO_BY_NAME_DATA[GuildFrame.selectedGuildMemberName])
	rankIndex = rankIndex + 1

	if ( rankIndex ~= newRankIndex ) then
		for i = 1, math.abs(rankIndex - newRankIndex) do
			if rankIndex > newRankIndex then
				GuildPromote(name)
			else
				GuildDemote(name)
			end
		end

		GuildMemberRankDropdown.newRankIndex = newRankIndex
		UIDropDownMenu_DisableDropDown(GuildMemberRankDropdown)
	end
end

function GuildRosterSortOnLoad( self, ... )
	self.sortIndex = {}
end

function Guild_TimeConvert(year, month, day, hour, isOnline)
	local lastOnline
	if ( (year == 0) or (year == nil) ) then
		if ( (month == 0) or (month == nil) ) then
			if ( (day == 0) or (day == nil) ) then
				if ( (hour == 0) or (hour == nil) ) then
					if ( isOnline ) then
						lastOnline = 0
					else
						lastOnline = 60
					end
				else
					lastOnline = hour * 3600
				end
			else
				lastOnline = day * 86400
			end
		else
			lastOnline = month * 2592000
		end
	else
		lastOnline = year * 31536000
	end
	return lastOnline
end

function GuildRoster_SortByColumn( sortType, sortIndex )
	if ( sortType ) then
		if sortType == "level" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				if sortIndex[sortType] then
					if a[10] and b[10] then
						return a[10] < b[10]
					else
						return a[4] < b[4]
					end
				else
					if a[10] and b[10] then
						return a[10] > b[10]
					else
						return a[4] > b[4]
					end
				end
			end)
		elseif sortType == "ilevel" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				local _a = GUILD_CHARACTER_ILEVEL_DATA[string.upper(a[1])] or -1
				local _b = GUILD_CHARACTER_ILEVEL_DATA[string.upper(b[1])] or -1

				if _a and _b then
					if sortIndex[sortType] then
						return _a < _b
					else
						return _a > _b
					end
				end
			end)
		elseif sortType == "class" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				if sortIndex[sortType] then
					return a[5] < b[5]
				else
					return a[5] > b[5]
				end
			end)
		elseif sortType == "name" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				if sortIndex[sortType] then
					return a[1] < b[1]
				else
					return a[1] > b[1]
				end
			end)
		elseif sortType == "zone" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				if sortIndex[sortType] then
					return a[6] < b[6]
				else
					return a[6] > b[6]
				end
			end)
		elseif sortType == "note" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				if sortIndex[sortType] then
					return a[7] < b[7]
				else
					return a[7] > b[7]
				end
			end)
		elseif sortType == "rank" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				if sortIndex[sortType] then
					return a[3] < b[3]
				else
					return a[3] > b[3]
				end
			end)
		elseif sortType == "online" then
			table.sort(GUILD_MEMBER_INFO_DATA, function(a, b)
				local a_year, a_month, a_day, a_hour = GetGuildRosterLastOnline(a[11])
				local b_year, b_month, b_day, b_hour = GetGuildRosterLastOnline(b[11])

				local a_time = Guild_TimeConvert(a_year, a_month, a_day, a_hour, a[9])
				local b_time = Guild_TimeConvert(b_year, b_month, b_day, b_hour, b[9])

				if a_time and b_time then
					if sortIndex[sortType] then
						return a_time < b_time
					else
						return a_time > b_time
					end
				end
			end)
		end
		columnSortData = {sortType, sortIndex}
		GuildRoster_Update()
	end
end

function GuildRoster_SetView(view)
	if ( not view or not GUILD_ROSTER_COLUMNS[view] ) then
		view = "playerStatus"
	end

	local numColumns = #GUILD_ROSTER_COLUMNS[view]
	local stringsInfo = { }
	local stringOffset = 0
	local haveIcon, haveBar

	for columnIndex = 1, 5 do
		local columnButton = _G["GuildRosterColumnButton"..columnIndex]
		local columnType = GUILD_ROSTER_COLUMNS[view][columnIndex]
		if ( columnType ) then
			local columnData = GUILD_ROSTER_COLUMN_DATA[columnType]
			columnButton:SetText(columnData.text)
			if columnType == "zone" then
				columnData.width = view == "tradeskill" and 129 or 114
			elseif columnType == "wideName" then
				columnData.width = view == "tradeskill" and 110 or 81
			end
			WhoFrameColumn_SetWidth(columnButton, columnData.width)
			columnButton:Show()
			if ( columnData.sortType ) then
				columnButton.sortType = columnData.sortType
			else
				columnButton.sortType = columnType
			end
			columnButton.sortIndex[columnButton.sortType] = true
			if ( columnData.hasIcon ) then
				haveIcon = true
			else
				columnData["stringOffset"] = stringOffset
				table.insert(stringsInfo, columnData)
			end
			stringOffset = stringOffset + columnData.width - 2
			haveBar = haveBar or columnData.hasBar
		else
			columnButton:Hide()
		end
	end

	local buttons = GuildRosterContainer.buttons
	local button, fontString
	for buttonIndex = 1, #buttons do
		button = buttons[buttonIndex]
		for stringIndex = 1, 4 do
			fontString = button["string"..stringIndex]
			local stringData = stringsInfo[stringIndex]
			if ( stringData ) then
				fontString:SetPoint("LEFT", stringData.stringOffset + 6, 0)
				fontString:SetWidth(stringData.width - 14)
				fontString:SetJustifyH(stringData.stringJustify)
				fontString:Show()
			else
				fontString:Hide()
			end
		end

		if ( haveIcon ) then
			button.icon:Show()
		else
			button.icon:Hide()
		end
		if ( haveBar ) then
			button.barLabel:Show()
		else
			button.barLabel:Hide()
			button.barTexture:Hide()
		end
	end
	currentGuildView = view
end


function GuildRosterViewDropdown_OnLoad(self)
	UIDropDownMenu_Initialize(self, GuildRosterViewDropdown_Initialize)
	UIDropDownMenu_SetWidth(GuildRosterViewDropdown, 150)
end

function GuildRosterViewDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo()
	info.func = GuildRosterViewDropdown_OnClick

	info.text = PLAYER_STATUS
	info.value = "playerStatus"
	UIDropDownMenu_AddButton(info)
	info.text = GUILD_STATUS
	info.value = "guildStatus"
	UIDropDownMenu_AddButton(info)
	info.text = TRADE_SKILLS
	info.value = "tradeskill"
	UIDropDownMenu_AddButton(info)

	UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView)
end

function GuildRosterViewDropdown_OnClick(self)
	if self.value == "tradeskill" and self.value ~= GuildRosterViewDropDown_OldValue and GuildFrame.needUpdateTradeSkill then
		GuildFrame.needUpdateTradeSkill = false

		for skillID, data in pairs(TradeSkillData) do
			data.isCollapsed = true
			data.numVisible = 0
			data.numPlayers = 0
			data.numOnline = 0

			TradeSkillData[skillID].players = {}
		end

		SendServerMessage("ACMSG_GUILD_TRADE_SKILL_LIST")
	else
		GuildRoster_SetView(self.value)
		GuildRoster()

		GuildRoster_Update()
		UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView)
	end

	GuildRosterViewDropDown_OldValue = self.value
end

function GuildRoster_Update()
	local scrollFrame = GuildRosterContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index, class
	local totalMembers = GetNumGuildMembers()
	local selectedGuildMember = GetGuildRosterSelection()
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player")
	local maxRankIndex = GuildControlGetNumRanks() - 1

	if ( currentGuildView == "tradeskill" ) then
		GenerateGuildTradeSkillInfo()
		GuildRoster_UpdateTradeSkills()
		return
	end

	if not GuildRosterFrame:IsVisible() then return end

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if ( index <= totalMembers ) then
			if not GUILD_MEMBER_INFO_DATA[index] then
				return
			end
			local name, rank, rankIndex, level, class, zone, note, officernote, online, categoryID, _, lastOnline = unpack(GUILD_MEMBER_INFO_DATA[index])
			button.guildIndex = index
			local displayedName = name
			local classFile = "PRIEST"
			button.online = online
			button.name = name

			button.header:Hide()

			for classfileMale, classlocaleMale in pairs(LOCALIZED_CLASS_NAMES_MALE) do
				if classfileMale and classlocaleMale == class then
					classFile = classfileMale
					break
				end
			end

			for classfileFemale, classlocaleFemale in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
				if classfileFemale and classlocaleFemale == class then
					classFile = classfileFemale
					break
				end
			end

			if ( currentGuildView == "playerStatus" ) then
				GuildRosterButton_SetStringText(button.string1, level, online)
				GuildRosterButton_SetStringText(button.string4, zone, online)
				button.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFile]))
				GuildRosterButton_SetStringText(button.string3, displayedName, online, classFile)

				if GUILD_CHARACTER_ILEVEL_DATA and GUILD_CHARACTER_ILEVEL_DATA[string.upper(name)] then
					if online then
						local color = ItemLevelMixIn:GetColor(GUILD_CHARACTER_ILEVEL_DATA[string.upper(name)])
						GuildRosterButton_SetStringText(button.string2, color:WrapTextInColorCode(GUILD_CHARACTER_ILEVEL_DATA[string.upper(name)]), online)
					else
						GuildRosterButton_SetStringText(button.string2, GUILD_CHARACTER_ILEVEL_DATA[string.upper(name)], online)
					end
					button.ilvl = GUILD_CHARACTER_ILEVEL_DATA[string.upper(name)]
				else
					GuildRosterButton_SetStringText(button.string2, "-", online)
				end

				if categoryID and categoryID ~= 0 then
					button.string1:Hide()
					button.CategoryIcon:Show()

					local categoryName, _, categoryIcon = GetSpellInfo(categoryID)
					button.categoryName = categoryName

					button.CategoryIcon:SetTexture(categoryIcon)
					button.CategoryIcon:SetDesaturated(not online)
				else
					button.categoryName = nil
					button.string1:Show()
					button.CategoryIcon:Hide()
				end
			elseif ( currentGuildView == "guildStatus" ) then
				GuildRosterButton_SetStringText(button.string1, displayedName, online, classFile)
				GuildRosterButton_SetStringText(button.string2, rank, online)
				GuildRosterButton_SetStringText(button.string3, note, online)
				button.CategoryIcon:Hide()

				if ( online ) then
					GuildRosterButton_SetStringText(button.string4, GUILD_ONLINE_LABEL, online)
				else
					GuildRosterButton_SetStringText(button.string4, lastOnline, online)
				end
			end

			if ( mod(index, 2) == 0 ) then
				button.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688)
			else
				button.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500)
			end

			if GetGuildRosterSelection() == index then
				button:LockHighlight()
			else
				button:UnlockHighlight()
			end

			button:Show()
		else
			button:Hide()
		end
	end

	local totalHeight = totalMembers * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end

function GuildRoster_UpdateTradeSkills()
	local scrollFrame = GuildRosterContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index, class
	local numTradeSkill = GetNumGuildTradeSkill()

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if ( index <= numTradeSkill ) then
			button.guildIndex = index
			local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, class, online, zone, skill, classFileName = GetGuildTradeSkillInfo(index)
			local _numOnline = GetGuildRosterShowOffline() and numPlayers or numOnline
			button.online = online

			if ( headerName ) then
				GuildRosterButton_SetStringText(button.string1, headerName, 1)
				GuildRosterButton_SetStringText(button.string2, "", 1)
				GuildRosterButton_SetStringText(button.string3, numOnline, 1)

				button.header:Show()
				button:UnlockHighlight()
				button.header.icon:SetTexture(iconTexture)
				button.header.name:SetFormattedText(GUILD_TRADESKILL_HEADER, headerName, numOnline)

				button.header.collapsed = isCollapsed

				if ( _numOnline == 0 ) then
					button.header:Disable()
					button.header.icon:SetDesaturated(true)
					button.header.collapsedIcon:Hide()
					button.header.expandedIcon:Hide()

					button.header.name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
					button.header.leftEdge:SetVertexColor(0.75, 0.75, 0.75)
					button.header.rightEdge:SetVertexColor(0.75, 0.75, 0.75)
					button.header.middle:SetVertexColor(0.75, 0.75, 0.75)
				else
					button.header:Enable()
					button.header.icon:SetDesaturated(false)

					button.header.name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
					button.header.leftEdge:SetVertexColor(1, 1, 1)
					button.header.rightEdge:SetVertexColor(1, 1, 1)
					button.header.middle:SetVertexColor(1, 1, 1)
					if ( isCollapsed ) then
						button.header.collapsedIcon:Show()
						button.header.expandedIcon:Hide()
					else
						button.header.expandedIcon:Show()
						button.header.collapsedIcon:Hide()
					end
				end
				button.header.skillID = skillID
				button:Show()
			elseif ( playerName ) then
				GuildRosterButton_SetStringText(button.string1, playerName, online, classFileName)
				GuildRosterButton_SetStringText(button.string2, isMobile and REMOTE_CHAT or zone, online)
				if skill then
					GuildRosterButton_SetStringText(button.string3, "["..skill.."]", online)
				end
				button.header:Hide()
				button:Show()
			else
				button:Hide()
			end
			if ( mod(index, 2) == 0 ) then
				button.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688)
			else
				button.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500)
			end
			button.CategoryIcon:Hide()
		else
			button:Hide()
		end
	end

	local totalHeight = numTradeSkill * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	local displayedHeight = numButtons * (GUILD_ROSTER_BUTTON_HEIGHT + GUILD_ROSTER_BUTTON_OFFSET);
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end

function GuildInfoHeaderFrame_OnEnter( self, ... )
	local min, max = 3000, 10000
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(GUILDFRAME_HEAD_BUILD_TEXT_TOOLTIP_HEAD)
	GameTooltip:AddLine(GUILDFRAME_HEAD_BUILD_TEXT_TOOLTIP1, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(GUILDFRAME_HEAD_BUILD_TEXT_TOOLTIP2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
	GameTooltip:Show()
end

function GuildXPBar_OnLoad( self, ... )
	local MAX_BAR = GuildXPBar:GetWidth()
	local space = MAX_BAR / 5
	local offset = space - 3
	GuildXPBarArtDivider1:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0)
	offset = offset + space
	GuildXPBarArtDivider2:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0)
	offset = offset + space - 1
	GuildXPBarArtDivider3:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0)
	offset = offset + space - 1
	GuildXPBarArtDivider4:SetPoint("LEFT", GuildXPBarLeft, "LEFT", offset, 0)
end

function GuildXPBar_OnEnter( self, ... )
	local tabID = GuildFrame.selectedTab or 1

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	if tabID == 2 then
		local data = GUILD_LEVEL_DATA
		local percentTotal = tostring(math.ceil((data.experience / data.nextLevelxperience) * 100))

		GameTooltip:SetText(COMBAT_GUILD_XP_GAIN)
		GameTooltip:AddLine(GUILD_XP_HELP_1, 1, 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(GUILD_EXPERIENCE_CAP, 1, 1, 1, 1)

		if data.remaining > 0 then
			local maxExp = 60000
			GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, data.experience, data.nextLevelxperience, percentTotal))
			local percentDaily = tostring(math.ceil(((maxExp - data.remaining) / maxExp) * 100))
			GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_DAILY, maxExp - data.remaining, maxExp, percentDaily))
		else
			GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, data.experience, data.nextLevelxperience, percentTotal))
		end
	elseif tabID == 3 then
		local data = GUILD_REPUTATION_DATA
		local factionStandingtext = GetText("FACTION_STANDING_LABEL"..GUILD_REPUTATION_DATA.reputationRank + 1, UnitSex("player"))

		GameTooltip:SetText(GUILD_REPUTATION)
		GameTooltip:AddLine(GUILD_REPUTATION_HELP_1, 1, 1, 1, 1)
		GameTooltip:AddLine(string.format(GUILD_EXPERIENCE_CURRENT, data.reputationMin, data.reputationMax, tostring(math.ceil((data.reputationMin / data.reputationMax) * 100))))
		GameTooltip:AddLine(string.format(GUILD_REPUTATION_COUNT, factionStandingtext))
	end

	GameTooltip:Show()
end

function GuildRewardsButton_OnEnter( self )
	GuildRewardsFrame.activeButton = self
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 28, 0)
	GameTooltip:SetHyperlink("item:"..self.itemID)
	if ( self.reputationID > GUILD_REPUTATION_DATA.reputationRank ) then
		local factionStandingtext = GetText("FACTION_STANDING_LABEL"..self.reputationID + 1, UnitSex("player"))
		GameTooltip:AddLine(" ", 1, 0, 0, 1)
		GameTooltip:AddLine(string.format(REQUIRES_GUILD_FACTION_TOOLTIP, factionStandingtext), 1, 0, 0, 1)
	end
	GameTooltip:Show()
end

function GuildBar_SetProgress(bar, currentValue, maxValue, capValue)
	local MAX_BAR = bar:GetWidth() - 4
	local progress = min(MAX_BAR * currentValue / maxValue, MAX_BAR)
	local capAtEdge
	bar.progress:SetWidth(progress + 1)
	if ( capValue + currentValue >= maxValue ) then
		capValue = maxValue - currentValue
		capAtEdge = true
	end
	local capWidth = MAX_BAR * capValue / maxValue
	if ( capWidth > 0 ) then
		bar.cap:SetWidth(capWidth)
		bar.cap:Show()
		-- don't show cap marker if cap goes all the way to the end
		if ( capAtEdge ) then
			bar.capMarker:Hide()
		else
			bar.capMarker:Show()
		end
	else
		bar.cap:Hide()
		bar.capMarker:Hide()
	end
	-- hide shadow on progress bar near the right edge
	if ( progress > MAX_BAR - 4 ) then
		bar.shadow:Hide()
	else
		bar.shadow:Show()
	end

	GuildXPBarArtText:SetText(currentValue.." / "..maxValue)
	currentValue = TextStatusBar_CapDisplayOfNumericValue(currentValue)
	maxValue = TextStatusBar_CapDisplayOfNumericValue(maxValue)
end

function GuildPerksFrame_OnLoad( self, ... )
	GuildPerksContainer.update = GuildPerks_Update
	HybridScrollFrame_CreateButtons(GuildPerksContainer, "GuildPerksButtonTemplate", 8, 0, "TOPLEFT", "TOPLEFT", 0, 0, "TOP", "BOTTOM")
end

function GuildRewardsFrame_OnLoad( self, ... )
	GuildRewardsContainer.update = GuildRewards_Update
	HybridScrollFrame_CreateButtons(GuildRewardsContainer, "GuildRewardsButtonTemplate", 1, 0)
	GuildRewardsContainerScrollBar.doNotHide = true
end

function GuildRewards_Update()
	local scrollFrame = GuildRewardsContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local playerMoney = GetMoney()
	local numRewards = GetGuildNumRewards()
	local gender = UnitSex("player")

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if GetGuildRewards(index) then
			local itemID, reputationID, moneyCost  = GetGuildRewards(index)
			local itemName, _, _, _, _, _, _, _, _, iconTexture = GetItemInfo(itemID)

			if itemName then
				button.name:SetText(itemName)
				button.icon:SetTexture(iconTexture)
				button:Show()

				if ( moneyCost and moneyCost > 0 ) then
					MoneyFrame_Update(button.money:GetName(), moneyCost)
					if ( playerMoney >= moneyCost ) then
						SetMoneyFrameColor(button.money:GetName(), "white")
					else
						SetMoneyFrameColor(button.money:GetName(), "red")
					end
					button.money:Show()
				else
					button.money:Hide()
				end

				button.achievementID = nil
				button.icon:SetDesaturated(0)
				button.name:SetFontObject(GameFontNormal)

				if ( GUILD_REPUTATION_DATA.reputationRank and reputationID > GUILD_REPUTATION_DATA.reputationRank ) then
					local factionStandingtext = GetText("FACTION_STANDING_LABEL"..reputationID + 1, gender)
					button.subText:SetFormattedText(REQUIRES_GUILD_FACTION, factionStandingtext)
					button.subText:Show()
					button.disabledBG:Show()
					button.icon:SetVertexColor(1, 0, 0)
				else
					button.subText:Hide()
					button.disabledBG:Hide()
					button.icon:SetVertexColor(1, 1, 1)
				end

				button.reputationID = reputationID
				button.itemID = itemID
				button.moneyCost = moneyCost
				button.index = index
			else
				button:Hide()
			end
		else
			button:Hide()
		end
	end

	local totalHeight = numRewards * (47 + 0)
	local displayedHeight = numButtons * (47 + 0)
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

	if ( GuildRewardsFrame.activeButton ) then
		GuildRewardsButton_OnEnter(GuildRewardsFrame.activeButton)
	end
end

function GuildPerks_Update()
	local scrollFrame = GuildPerksContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local numPerks = GetGuildNumPerks()
	local guildLevel = GUILD_LEVEL_DATA.level

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i
		if ( index <= numPerks ) then
			local spellID, spellLevel = GetGuildPerks(index)
			local name, _, iconTexture = GetSpellInfo(spellID)

			button.name:SetText(name)
			button.level:SetFormattedText(FLOOR_NUMBER, spellLevel)
			button.icon:SetTexture(iconTexture)
			button.spellID = spellID
			button:Show()

			if ( guildLevel and spellLevel > guildLevel ) then
				button:EnableDrawLayer("BORDER")
				button:DisableDrawLayer("BACKGROUND")
				button.icon:SetDesaturated(1)
				button.name:SetFontObject(GameFontNormalLeftGrey)
				button.lock:Show()
				button.level:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				button:EnableDrawLayer("BACKGROUND")
				button:DisableDrawLayer("BORDER")
				button.icon:SetDesaturated(0)
				button.name:SetFontObject(GameFontHighlight)
				button.lock:Hide()
				button.level:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			end
		else
			button:Hide()
		end
	end

	local totalHeight = numPerks * scrollFrame.buttonHeight
	local displayedHeight = numButtons * scrollFrame.buttonHeight
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

	if ( scrollFrame.activeButton ) then
		GuildPerksButton_OnEnter(scrollFrame.activeButton)
	end
end

function GuildPerksButton_OnEnter(self)
	GuildPerksContainer.activeButton = self
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 36, 0)
	GameTooltip:SetHyperlink(GetSpellLink(self.spellID))
end

function GuildRewardsButton_OnClick( self, ... )
	if ( IsModifiedClick("CHATLINK") ) then
		GuildFrame_LinkItem(_, self.itemID)
		return
	end

	if ( GUILD_REPUTATION_DATA.reputationRank and self.reputationID <= GUILD_REPUTATION_DATA.reputationRank ) then
		local _, link = GetItemInfo(self.itemID)
		local dialog = StaticPopup_Show("GUILD_REWARDS_CONFIRM_BUY", link, 1, {itemID = self.itemID, moneyCost = self.moneyCost})
	else
		UIErrorsFrame:AddMessage(GUILD_ERROR_NEED_REPUTATION .. GetText("FACTION_STANDING_LABEL"..self.reputationID + 1, UnitSex("player")), 1.0, 0.1, 0.1, 1.0)
	end
end

function GuildChallengeFrame_OnEnter( self, ... )
	if self.index then
		local index, current, max, gold, exp, buildPoint = GetGuildChallengeInfo(self.index)

		if index then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(_G["GUILD_CHALLENGE_LABEL"..index])
			GameTooltip:AddLine(_G["GUILD_CHALLENGE_TOOLTIP"..index], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(GUILD_CHALLENGE_REWARD, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
			GameTooltip:AddLine(string.format(GUILD_CHALLENGE_REWARD_BUILD_POINTS, buildPoint), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
			if gold ~= 0 then
				local goldString = GetMoneyString(gold * COPPER_PER_SILVER * SILVER_PER_GOLD)
				GameTooltip:AddLine(goldString, 1, 1, 1, true)
			elseif exp ~= 0 then
				GameTooltip:AddLine(string.format(GUILD_CHALLENGE_REWARD_GUILD_EXP, exp), 1, 1, 1, true)
			end
			GameTooltip:Show()
		end
	end
end

function GuildInfoFrame_UpdateChallenge()
	for i = 1, 4 do
		local frame = _G["GuildInfoFrameInfoChallenge"..i]

		if frame then
			local index, current, max, gold, exp = GetGuildChallengeInfo(i)

			if current == max then
				frame.count:Hide()
				frame.check:Show()
				frame.label:SetTextColor(0.1, 1, 0.1)
			else
				frame.count:Show()
				frame.count:SetFormattedText(GUILD_CHALLENGE_PROGRESS_FORMAT, current, max)
				frame.check:Hide()
				frame.label:SetTextColor(1, 1, 1)
			end

			frame.index = i
		end
	end
end

function GuildInfoFrame_OnLoad(self)
	PanelTemplates_SetNumTabs(self, 3);

	--	self:RegisterEvent("LF_GUILD_POST_UPDATED");
	--	self:RegisterEvent("LF_GUILD_RECRUITS_UPDATED");
	--	self:RegisterEvent("LF_GUILD_RECRUIT_LIST_CHANGED");

end

function GuildInfoFrame_OnEvent(self, event, arg1)
	if ( event == "LF_GUILD_POST_UPDATED" ) then
		local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
		-- interest
		GuildRecruitmentQuestButton:SetChecked(bQuest);
		GuildRecruitmentDungeonButton:SetChecked(bDungeon);
		GuildRecruitmentRaidButton:SetChecked(bRaid);
		GuildRecruitmentPvPButton:SetChecked(bPvP);
		GuildRecruitmentRPButton:SetChecked(bRP);
		-- availability
		GuildRecruitmentWeekdaysButton:SetChecked(bWeekdays);
		GuildRecruitmentWeekendsButton:SetChecked(bWeekends);
		-- roles
		GuildRecruitmentTankButton.checkButton:SetChecked(bTank);
		GuildRecruitmentHealerButton.checkButton:SetChecked(bHealer);
		GuildRecruitmentDamagerButton.checkButton:SetChecked(bDamage);
		-- level
		if ( bMaxLevel ) then
			GuildRecruitmentLevelButton_OnClick(2);
		else
			GuildRecruitmentLevelButton_OnClick(1);
		end
		-- comment
		GuildRecruitmentCommentEditBox:SetText(GetGuildRecruitmentComment());
		GuildRecruitmentListGuildButton_Update();
	elseif ( event == "LF_GUILD_RECRUITS_UPDATED" ) then
		GuildInfoFrameApplicants_Update();
	elseif ( event == "LF_GUILD_RECRUIT_LIST_CHANGED" ) then
		RequestGuildApplicantsList();
	end
end

function GuildInfoFrame_OnShow(self)
	RequestGuildApplicantsList();
end

function GuildInfoFrame_Update()
	local selectedTab = PanelTemplates_GetSelectedTab(GuildInfoFrame);
	if ( selectedTab == 1 ) then
		GuildInfoFrameInfo:Show();
		GuildInfoFrameRecruitment:Hide();
		GuildInfoFrameApplicants:Hide();
	elseif ( selectedTab == 2 ) then
		GuildInfoFrameInfo:Hide();
		GuildInfoFrameRecruitment:Show();
		GuildInfoFrameApplicants:Hide();
	else
		GuildInfoFrameInfo:Hide();
		GuildInfoFrameRecruitment:Hide();
		GuildInfoFrameApplicants:Show();
	end
end

function GuildInfoFrameInfo_OnLoad( self, ... )
	-- local CHALLENGE_SECTIONS = { "GuildInfoChallengesDungeon", "GuildInfoChallengesRaid", "GuildInfoChallengesRatedBG" }

	local fontString = GuildInfoEditMOTDButton:GetFontString()
	GuildInfoEditMOTDButton:SetHeight(fontString:GetHeight() + 4)
	GuildInfoEditMOTDButton:SetWidth(fontString:GetWidth() + 4)
	fontString = GuildInfoEditDetailsButton:GetFontString()
	GuildInfoEditDetailsButton:SetHeight(fontString:GetHeight() + 4)
	GuildInfoEditDetailsButton:SetWidth(fontString:GetWidth() + 4)

	GuildInfoFrame_UpdateChallenge()

	-- GuildInfoFrameHeader1Label:SetText(GUILD_FRAME_CHALLENGES)
	-- GuildInfoChallenges:Show()
	-- GuildInfoChallengesDungeonTexture:Show()
	-- GuildInfoChallengesRaidTexture:Show()
	-- GuildInfoChallengesRatedBGTexture:Show()

	-- for _, frame in pairs(CHALLENGE_SECTIONS) do
	-- _G[frame.."Count"]:SetFormattedText("%d / %d", 0, 7)
	-- end
end

function GuildInfoFrameInfo_OnShow( self, ... )
	GuildInfoFrame_UpdatePermissions()
	GuildInfoFrame_UpdateText()

	if SIRUS_GUILD_RENAME and SIRUS_GUILD_RENAME[1] then
		GuildFrame_RenameButtonToggle(SIRUS_GUILD_RENAME[1])
	end
end

function GuildInfoFrame_UpdatePermissions()
	if ( CanEditMOTD() ) then
		GuildInfoEditMOTDButton:Show();
	else
		GuildInfoEditMOTDButton:Hide();
	end
	if ( CanEditGuildInfo() ) then
		GuildInfoEditDetailsButton:Show();
	else
		GuildInfoEditDetailsButton:Hide();
	end
	local guildInfoFrame = GuildInfoFrame;
	if ( IsGuildLeader() ) then
		GuildControlButton:Enable();
		GuildInfoFrameTab2:Show();
		GuildInfoFrameTab3:SetPoint("LEFT", GuildInfoFrameTab2, "RIGHT");
	else
		GuildControlButton:Disable();
		GuildInfoFrameTab2:Hide();
		GuildInfoFrameTab3:SetPoint("LEFT", GuildInfoFrameTab1, "RIGHT");
	end
	if ( CanGuildInvite() ) then
		GuildAddMemberButton:Enable();
		-- show the recruitment tabs
		if ( not guildInfoFrame.tabsShowing ) then
			guildInfoFrame.tabsShowing = true;
			GuildInfoFrameTab1:Show();
			GuildInfoFrameTab3:Show();
			GuildInfoFrameTab3:SetText(GUILDINFOTAB_APPLICANTS_NONE);
			PanelTemplates_SetTab(guildInfoFrame, 1);
			PanelTemplates_UpdateTabs(guildInfoFrame);
			RequestGuildApplicantsList();
		end
	else
		GuildAddMemberButton:Disable();
		-- hide the recruitment tabs
		if ( guildInfoFrame.tabsShowing ) then
			guildInfoFrame.tabsShowing = nil;
			GuildInfoFrameTab1:Hide();
			GuildInfoFrameTab3:Hide();
			if ( PanelTemplates_GetSelectedTab(guildInfoFrame) ~= 1 ) then
				PanelTemplates_SetTab(guildInfoFrame, 1);
				GuildInfoFrame_Update();
			end
		end
	end
end

function GuildPerksButton_OnDragStart( self, ... )
	if self.spellID then
		local name = GetSpellInfo(self.spellID)

		if not IsPassiveSpell(name) then
			PickupSpell(name)
		end
	end
end

function GuildInfoFrame_UpdateText(infoText)
	GuildInfoMOTD:SetText(GetGuildRosterMOTD(), true) --Extra argument ignores markup.
	if ( infoText ) then
		GuildInfoFrame.cachedInfoText = infoText
		GuildInfoFrame.cacheExpiry = GetTime() + 10
	else
		if ( not GuildInfoFrame.cacheExpiry or GetTime() > GuildInfoFrame.cacheExpiry ) then
			GuildInfoFrame.cachedInfoText = GetGuildInfoText()
		end
	end
	GuildInfoDetails:SetText(GuildInfoFrame.cachedInfoText)
	GuildInfoDetailsFrame:SetVerticalScroll(0)
	GuildInfoDetailsFrameScrollBarScrollUpButton:Disable()
end

function GuildInfoFrameRecruitment_OnLoad(self)
	GuildRecruitmentInterestFrameText:SetText(GUILD_INTEREST);
	GuildRecruitmentInterestFrame:SetHeight(63);
	GuildRecruitmentAvailabilityFrameText:SetText(GUILD_AVAILABILITY);
	GuildRecruitmentAvailabilityFrame:SetHeight(43);
	GuildRecruitmentRolesFrameText:SetText(CLASS_ROLES);
	GuildRecruitmentRolesFrame:SetHeight(80);
	GuildRecruitmentLevelFrameText:SetText(GUILD_RECRUITMENT_LEVEL);
	GuildRecruitmentLevelFrame:SetHeight(43);
	GuildRecruitmentCommentFrame:SetHeight(72);

	-- defaults until data is retrieved
	GuildRecruitmentLevelAnyButton:SetChecked(1);
	GuildRecruitmentListGuildButton:Disable();
end

function GuildRecruitmentLevelButton_OnClick(index, userClick)
	local param;
	if ( index == 1 ) then
		GuildRecruitmentLevelAnyButton:SetChecked(1);
		GuildRecruitmentLevelMaxButton:SetChecked(nil);
		param = LFGUILD_PARAM_ANY_LEVEL;
	elseif ( index == 2 ) then
		GuildRecruitmentLevelAnyButton:SetChecked(nil);
		GuildRecruitmentLevelMaxButton:SetChecked(1);
		param = LFGUILD_PARAM_MAX_LEVEL;
	end
	if ( userClick ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		SetGuildRecruitmentSettings(param, true);
	end
end

function GuildRecruitmentRoleButton_OnClick(self)
	local checked = self:GetChecked();
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	SetGuildRecruitmentSettings(self:GetParent().param, checked);
	GuildRecruitmentListGuildButton_Update();
end

function GuildRecruitmentListGuildButton_Update()
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
	-- need to have at least 1 interest, 1 time, and 1 role checked to be able to list
	if ( bQuest or bDungeon or bRaid or bPvP or bRP ) and ( bWeekdays or bWeekends ) and ( bTank or bHealer or bDamage ) then
		GuildRecruitmentListGuildButton:Enable();
	else
		GuildRecruitmentListGuildButton:Disable();
		-- delist if already listed
		if ( bListed ) then
			bListed = false;
			SetGuildRecruitmentSettings(LFGUILD_PARAM_LOOKING, false);
		end
	end
	GuildRecruitmentListGuildButton_UpdateText(bListed);
end

function GuildRecruitmentListGuildButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, bAnyLevel, bMaxLevel, bListed = GetGuildRecruitmentSettings();
	bListed = not bListed;
	if ( bListed and GuildRecruitmentCommentEditBox:HasFocus() ) then
		GuildRecruitmentComment_SaveText();
	end
	SetGuildRecruitmentSettings(LFGUILD_PARAM_LOOKING, bListed);
	GuildRecruitmentListGuildButton_UpdateText(bListed);
end

function GuildRecruitmentListGuildButton_UpdateText(listed)
	if ( listed ) then
		GuildRecruitmentListGuildButton:SetText(GUILD_CLOSE_RECRUITMENT);
	else
		GuildRecruitmentListGuildButton:SetText(GUILD_OPEN_RECRUITMENT);
	end
end

function GuildRecruitmentComment_SaveText(self)
	self = self or GuildRecruitmentCommentEditBox;
	SetGuildRecruitmentComment(self:GetText():gsub("\n", ""));
	self:ClearFocus();
end

function GuildRecruitmentCheckButton_OnEnter(self)
	local interestType = INTEREST_TYPES[self:GetID()];
	if ( interestType ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(_G["GUILD_INTEREST_"..interestType]);
		GameTooltip:AddLine(_G["GUILD_INTEREST_"..interestType.."_TOOLTIP"], 1, 1, 1, 1, 1);
		GameTooltip:Show();
	end
end

function GuildInfoFrameApplicants_OnLoad(self)
	GuildInfoFrameApplicantsContainer.update = GuildInfoFrameApplicants_Update;
	HybridScrollFrame_CreateButtons(GuildInfoFrameApplicantsContainer, "GuildRecruitmentApplicantTemplate", 0, 0);

	GuildInfoFrameApplicantsContainerScrollBar.Show =
	function (self)
		GuildInfoFrameApplicantsContainer:SetWidth(304);
		for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
			button:SetWidth(301);
			button.fullComment:SetWidth(223);
		end
		getmetatable(self).__index.Show(self);
	end
	GuildInfoFrameApplicantsContainerScrollBar.Hide =
	function (self)
		GuildInfoFrameApplicantsContainer:SetWidth(320);
		for _, button in next, GuildInfoFrameApplicantsContainer.buttons do
			button:SetWidth(320);
			button.fullComment:SetWidth(242);
		end
		getmetatable(self).__index.Hide(self);
	end
end

function GuildRecruitmentInviteButton_OnClick(self, button)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local name = GetGuildApplicantInfo(GetGuildApplicantSelection());
	if ( name ) then
		GuildInvite(name);
	end
end

function GuildInfoFrameApplicants_OnShow(self)
	GuildInfoFrameApplicants_Update();

	if not self.dropDownInitialize then
		UIDropDownMenu_Initialize(GuildRecruitmentDropDown, GuildRecruitmentDropDown_Initialize, "MENU");
		self.dropDownInitialize = true;
	end
end

function GuildInfoFrameApplicants_Update()
	local scrollFrame = GuildInfoFrameApplicantsContainer;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	local button, index;
	local numApplicants = GetNumGuildApplicants();
	local selection = GetGuildApplicantSelection();

	if ( numApplicants == 0 ) then
		GuildInfoFrameTab3:SetText(GUILDINFOTAB_APPLICANTS_NONE);
	else
		GuildInfoFrameTab3:SetFormattedText(GUILDINFOTAB_APPLICANTS, numApplicants);
	end
	PanelTemplates_TabResize(GuildInfoFrameTab3, 0);

	for i = 1, numButtons do
		button = buttons[i];
		index = offset + i;
		local name, level, class, _, _, _, _, _, _, _, isTank, isHealer, isDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(index);
		if ( name ) then
			button.name:SetText(name);
			button.levelFrame.level:SetText(level);
			button.comment:SetText(comment);
			button.fullComment:SetText(comment);
			button.classFrame.class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
			-- time left
			local daysLeft = floor(timeLeft / 86400); -- seconds in a day
			if ( daysLeft < 1 ) then
				button.timeLeft:SetText(GUILD_FINDER_LAST_DAY_LEFT);
			else
				button.timeLeft:SetFormattedText(GUILD_FINDER_DAYS_LEFT, daysLeft);
			end
			-- roles
			if ( isTank ) then
				button.tankTex:SetAlpha(1);
			else
				button.tankTex:SetAlpha(0.2);
			end
			if ( isHealer ) then
				button.healerTex:SetAlpha(1);
			else
				button.healerTex:SetAlpha(0.2);
			end
			if ( isDamage ) then
				button.damageTex:SetAlpha(1);
			else
				button.damageTex:SetAlpha(0.2);
			end
			-- selection
			local buttonHeight = GUILD_BUTTON_HEIGHT;
			if ( index == selection ) then
				button.selectedTex:Show();
				local commentHeight = button.fullComment:GetHeight();
				if ( commentHeight > GUILD_COMMENT_HEIGHT ) then
					buttonHeight = GUILD_BUTTON_HEIGHT + commentHeight - GUILD_COMMENT_HEIGHT + GUILD_COMMENT_BORDER;
				end
			else
				button.selectedTex:Hide();
			end

			button:SetHeight(buttonHeight);
			button:Show();
			button.index = index;
		else
			button:Hide();
		end
	end

	if ( not selection ) then
		HybridScrollFrame_CollapseButton(scrollFrame);
	end

	local totalHeight = numApplicants * GUILD_BUTTON_HEIGHT;
	if ( scrollFrame.largeButtonHeight ) then
		totalHeight = totalHeight + (scrollFrame.largeButtonHeight - GUILD_BUTTON_HEIGHT);
	end
	local displayedHeight = numApplicants * GUILD_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	if ( selection and selection > 0 ) then
		GuildRecruitmentInviteButton:Enable();
		GuildRecruitmentDeclineButton:Enable();
		GuildRecruitmentMessageButton:Enable();
	else
		GuildRecruitmentInviteButton:Disable();
		GuildRecruitmentDeclineButton:Disable();
		GuildRecruitmentMessageButton:Disable();
	end
end

function GuildRecruitmentApplicant_OnClick(self, button)
	if ( button == "LeftButton" ) then
		SetGuildApplicantSelection(self.index);
		local commentHeight = self.fullComment:GetHeight();
		if ( commentHeight > GUILD_COMMENT_HEIGHT ) then
			local buttonHeight = GUILD_BUTTON_HEIGHT + commentHeight - GUILD_COMMENT_HEIGHT + GUILD_COMMENT_BORDER;
			self:SetHeight(buttonHeight);
			HybridScrollFrame_ExpandButton(GuildInfoFrameApplicantsContainer, ((self.index - 1) * GUILD_BUTTON_HEIGHT), buttonHeight);
		else
			HybridScrollFrame_CollapseButton(GuildInfoFrameApplicantsContainer);
		end
		GuildInfoFrameApplicants_Update();
	elseif ( button == "RightButton" ) then
		local dropDown = GuildRecruitmentDropDown;
		if ( dropDown.index ~= self.index ) then
			CloseDropDownMenus();
		end
		dropDown.index = self.index;
		ToggleDropDownMenu(1, nil, dropDown, "cursor", 1, -1);
	end
end

function GuildRecruitmentApplicant_ShowTooltip(self)
	local name, level, class, bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage, comment, timeSince, timeLeft = GetGuildApplicantInfo(self.index);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(name);
	local buf = "";
	-- interests
	if ( bQuest ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_QUEST; end
	if ( bDungeon ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_DUNGEON; end
	if ( bRaid ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_RAID; end
	if ( bPvP ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_PVP; end
	if ( bRP ) then buf = buf.."\n"..QUEST_DASH..GUILD_INTEREST_RP; end
	GameTooltip:AddLine(GUILD_INTEREST..HIGHLIGHT_FONT_COLOR_CODE..buf);
	-- availability
	buf = "";
	if ( bWeekdays ) then buf = buf.."\n"..QUEST_DASH..GUILD_AVAILABILITY_WEEKDAYS; end
	if ( bWeekends ) then buf = buf.."\n"..QUEST_DASH..GUILD_AVAILABILITY_WEEKENDS; end
	GameTooltip:AddLine(GUILD_AVAILABILITY..HIGHLIGHT_FONT_COLOR_CODE..buf);

	GameTooltip:Show();
end

-- GetRealmID

function GuildRecruitmentDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo();
	local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildApplicantInfo(GuildRecruitmentDropDown.index);
	if not name then
		name = UNKNOWN;
	end
	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	info.func = GuildRecruitmentDropDown_OnClick;

	info.text = INVITE;
	info.arg1 = "invite";
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = WHISPER;
	info.arg1 = "whisper";
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = ADD_FRIEND;
	info.arg1 = "addfriend";
	if ( name ~= UNKNOWN and GetFriendInfo(name) ) then
		info.disabled = 1;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = TALENT_GET_URL_ADRESS_DROPDOWN_TITLE;
	info.arg1 = "url";
	info.disabled = not guid and 1 or nil;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = DECLINE;
	info.arg1 = "decline";
	info.disabled = nil;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function GuildRecruitmentDropDown_OnClick(button, action)
	local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildApplicantInfo(GuildRecruitmentDropDown.index);
	if ( not name ) then
		return;
	end
	if ( action == "invite" ) then
		GuildInvite(name);
	elseif ( action == "whisper" ) then
		ChatFrame_SendTell(name);
	elseif ( action == "addfriend" ) then
		AddOrRemoveFriend(name);
	elseif ( action == "url" ) then
		StaticPopup_Show("GUILD_RECRUITMENT_URL", nil, nil, string.format("https://sirus.su/base/character/%d/%d", C_Service:GetRealmID(), guid or 0));
	elseif ( action == "decline" ) then
		DeclineGuildApplicant(GuildRecruitmentDropDown.index);
	end
end

function GuildFramePopup_Toggle(frame)
	if ( frame:IsShown() ) then
		frame:Hide()
	else
		GuildFramePopup_Show(frame)
	end
end

function GuildFrame_RenameButtonToggle( toggle )
	if not GuildInfoFrame:IsShown() then
		return
	end

	GuildInfoDetailsFrame:ClearAllPoints()
	GuildInfoFrameInfoArtBackground:ClearAllPoints()

	GuildRenameButton:SetShown(toggle)

	if toggle then
		-- GuildInfoDetailsFrame:SetSize(284, 54)
		GuildInfoDetailsFrame:SetSize(284, 148)
		GuildInfoDetailsFrame:SetPoint("TOPLEFT", GuildInfoFrameInfoHeader3, "BOTTOMLEFT", 14, 0)

		GuildInfoFrameInfoArtBackground:SetPoint("TOPRIGHT", GuildInfoFrameInfo, "TOPRIGHT", -3, -4)
		GuildInfoFrameInfoArtBackground:SetPoint("BOTTOMLEFT", GuildInfoFrameInfo, "BOTTOMLEFT", 4, 29.5)

		GuildFrameInset:SetPoint("TOPLEFT", 4, -65)
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 56)
	else
		-- GuildInfoDetailsFrame:SetSize(284, 78)
		GuildInfoDetailsFrame:SetSize(284, 185)
		GuildInfoDetailsFrame:SetPoint("TOPLEFT", GuildInfoFrameInfoHeader3, "BOTTOMLEFT", 14, -1)

		GuildInfoFrameInfoArtBackground:SetPoint("TOPRIGHT", GuildInfoFrameInfo, "TOPRIGHT", -3, -4)
		GuildInfoFrameInfoArtBackground:SetPoint("BOTTOMLEFT", GuildInfoFrameInfo, "BOTTOMLEFT", 4, 3)

		GuildFrameInset:SetPoint("TOPLEFT", 4, -65)
		GuildFrameInset:SetPoint("BOTTOMRIGHT", -7, 26)
	end
end

function GuildLogFrame_OnLoad(self)
	GuildFrame_RegisterPopup(self)
	GuildLogHTMLFrame:SetSpacing(2)
	ScrollBar_AdjustAnchors(GuildLogScrollFrameScrollBar, 0, -2)
	self:RegisterEvent("GUILD_EVENT_LOG_UPDATE")
end

function GuildLogFrame_Update()
	local numEvents = GetNumGuildEvents()
	local type, player1, player2, rank, year, month, day, hour
	local msg
	local buffer = ""
	for i = numEvents, 1, -1 do
		type, player1, player2, rank, year, month, day, hour = GetGuildEventInfo(i)
		if ( not player1 ) then
			player1 = UNKNOWN
		end
		if ( not player2 ) then
			player2 = UNKNOWN
		end
		if ( type == "invite" ) then
			msg = format(GUILDEVENT_TYPE_INVITE, player1, player2)
		elseif ( type == "join" ) then
			msg = format(GUILDEVENT_TYPE_JOIN, player1)
		elseif ( type == "promote" ) then
			msg = format(GUILDEVENT_TYPE_PROMOTE, player1, player2, rank)
		elseif ( type == "demote" ) then
			msg = format(GUILDEVENT_TYPE_DEMOTE, player1, player2, rank)
		elseif ( type == "remove" ) then
			msg = format(GUILDEVENT_TYPE_REMOVE, player1, player2)
		elseif ( type == "quit" ) then
			msg = format(GUILDEVENT_TYPE_QUIT, player1)
		end
		if ( msg ) then
			buffer = buffer..msg.."|cff009999   "..format(GUILD_BANK_LOG_TIME, RecentTimeDate(year, month, day, hour)).."|r|n"
		end
	end
	GuildLogHTMLFrame:SetText(buffer)
end

function GuildTextEditFrame_Show(editType)
	if ( editType == "motd" ) then
		GuildTextEditFrame:SetHeight(162)
		GuildTextEditBox:SetMaxLetters(128)
		GuildTextEditBox:SetText(GetGuildRosterMOTD())
		GuildTextEditFrameTitle:SetText(GUILD_DAY_MESSAGE)
		GuildTextEditBox:SetScript("OnEnterPressed", GuildTextEditFrame_OnAccept)
	elseif ( editType == "info" ) then
		GuildTextEditFrame:SetHeight(295)
		GuildTextEditBox:SetMaxLetters(500)
		GuildTextEditBox:SetText(GuildInfoFrame.cachedInfoText)
		GuildTextEditFrameTitle:SetText(GUILD_INFO_EDITLABEL)
		GuildTextEditBox:SetScript("OnEnterPressed", nil)
	end
	GuildTextEditFrame.type = editType
	GuildFramePopup_Show(GuildTextEditFrame)
	GuildTextEditBox:SetCursorPosition(0)
	GuildTextEditBox:SetFocus()
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function GuildTextEditFrame_OnAccept()
	if ( GuildTextEditFrame.type == "motd" ) then
		GuildSetMOTD(GuildTextEditBox:GetText())
	elseif ( GuildTextEditFrame.type == "info" ) then
		local infoText = GuildTextEditBox:GetText()
		GuildInfoFrame_UpdateText(infoText)
		SetGuildInfoText(infoText)
	end
	GuildTextEditFrame:Hide()
end

function GuildFrame_LinkItem(button, itemID, itemLink)
	local _
	if ( not itemLink ) then
		_, itemLink = GetItemInfo(itemID)
	end
	if ( itemLink ) then
		if ( ChatEdit_GetActiveWindow() ) then
			ChatEdit_InsertLink(itemLink)
		else
			ChatFrame_OpenChat(itemLink)
		end
	end
end

PLAYER_GUILD_EMBLEM_DATA = {}

function EventHandler:ASMSG_PLAYER_GUILD_EMBLEM_INFO( msg )
	local emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = strsplit(":", msg)

	if emblemStyle and emblemColor and emblemBorderStyle and emblemBorderColor and emblemBackgroundColor then
		emblemStyle = tonumber(emblemStyle)
		emblemColor = tonumber(emblemColor)
		emblemBorderStyle = tonumber(emblemBorderStyle)
		emblemBorderColor = tonumber(emblemBorderColor)
		emblemBackgroundColor = tonumber(emblemBackgroundColor)

		PLAYER_GUILD_EMBLEM_DATA = {
			emblemStyle 			= emblemStyle,
			emblemColor 			= emblemColor,
			emblemBorderStyle 		= emblemBorderStyle,
			emblemBorderColor 		= emblemBorderColor,
			emblemBackgroundColor 	= emblemBackgroundColor,
		}

		local button = GuildMicroButton
		local tabard = GuildMicroButtonTabard
		button:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
		button:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down")
		tabard:Show()

		if SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor] then
			tabard.background:SetVertexColor(rgb(unpack(SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor])))
			GuildFrameTabardBackground:SetVertexColor(rgb(unpack(SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor])))
		end

		if SHARED_TABARD_EMBLEM_COLOR[emblemColor] then
			tabard.emblem:SetVertexColor(rgb(unpack(SHARED_TABARD_EMBLEM_COLOR[emblemColor])))
			GuildFrameTabardEmblem:SetVertexColor(rgb(unpack(SHARED_TABARD_EMBLEM_COLOR[emblemColor])))
		end

		if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle] then
			if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor] then
				GuildFrameTabardBorder:SetVertexColor(rgb(unpack(SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor])))
			end
		else
			if SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor] then
				GuildFrameTabardBorder:SetVertexColor(rgb(unpack(SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor])))
			end
		end

		GuildFrameTabardBackground:Show()
		GuildFrameTabardEmblem:Show()
		GuildFrameTabardBorder:Show()
		SetSmallGuildTabardTextures(tabard.emblem, emblemStyle)
		SetLargeGuildTabardTextures(GuildFrameTabardEmblem, emblemStyle)
	end
end

function EventHandler:ASMSG_GUILD_INVITE_REQUEST( msg )
	local guildLevel, emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = strsplit(":", msg)

	if guildLevel and emblemStyle and emblemColor and emblemBorderStyle and emblemBorderColor and emblemBackgroundColor then

		guildLevel = tonumber(guildLevel)
		emblemStyle = tonumber(emblemStyle)
		emblemColor = tonumber(emblemColor)
		emblemBorderStyle = tonumber(emblemBorderStyle)
		emblemBorderColor = tonumber(emblemBorderColor)
		emblemBackgroundColor = tonumber(emblemBackgroundColor)

		if SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor] then
			GuildInviteFrameTabardBackground:SetVertexColor(rgb(unpack(SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor])))
		end

		if SHARED_TABARD_EMBLEM_COLOR[emblemColor] then
			GuildInviteFrameTabardEmblem:SetVertexColor(rgb(unpack(SHARED_TABARD_EMBLEM_COLOR[emblemColor])))
		end

		if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle] then
			if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor] then
				GuildInviteFrameTabardArtTabardBorder:SetVertexColor(rgb(unpack(SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor])))
			end
		else
			if SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor] then
				GuildInviteFrameTabardArtTabardBorder:SetVertexColor(rgb(unpack(SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor])))
			end
		end

		GuildInviteFrameLevelNumber:SetText(guildLevel)
		SetLargeGuildTabardTextures(GuildInviteFrameTabardEmblem, emblemStyle)
	end
end

function EventHandler:ASMSG_GUILD_PLAYERS_ILVL( msg )
	for name, ilvl in string.gmatch(string.upper(msg), "(.-):(%d+)|") do
		GUILD_CHARACTER_ILEVEL_DATA[name] = tonumber(ilvl)
	end
end

function EventHandler:ASMSG_GUILD_RENAME_RESPONSE( msg )
	msg = tonumber(msg)

	if msg == 0 then
		StaticPopup_Show("SIRUS_RENAME_GUILD_COMPLETE")
	elseif msg then
		StaticPopup_Show("SIRUS_RENAME_GUILD_ERROR", _G["GUILD_RENAME_ERROR_"..msg])
	end
end

function EventHandler:ASMSG_GUILD_TRADE_SKILL_INFO( msg )
	local splitData = C_Split(msg, ":")

	for k, v in pairs(splitData) do
		local skillID = TradeSkillMap[k]
		local value = tonumber(v)
		if skillID and value ~= 0 then
			if not TradeSkillData[skillID] then
				TradeSkillData[skillID] = {}
			end

			for k, v in pairs(TradeSkillData) do
				v.isCollapsed = true
				v.numVisible = 0
				v.numPlayers = 0
				v.numOnline = 0
			end

			TradeSkillData[skillID].players = {}
			SendServerMessage("ACMSG_GUILD_TRADE_SKILL_LIST", skillID)
		end
	end
end

local tradeskillSpell = {
	[171] = { {75, 2259}, {150, 3101}, {225, 3464}, {300, 11611}, {375, 28596}, {450, 51304} },
	[164] = { {75, 2018}, {150, 3100}, {225, 3538}, {300, 9785}, {375, 29844}, {450, 51300} },
	[333] = { {75, 7411}, {150, 7412}, {225, 7413}, {300, 13920}, {375, 28029}, {450, 51313} },
	[202] = { {75, 4036}, {150, 4037}, {225, 4038}, {300, 12656}, {375, 30350}, {450, 51306} },
	[182] = { {75, 2366}, {150, 2368}, {225, 3570}, {300, 11993}, {375, 28695}, {450, 50300} },
	[773] = { {75, 45357}, {150, 45358}, {225, 45359}, {300, 45360}, {375, 45361}, {450, 45363} },
	[755] = { {75, 25229}, {150, 25230}, {225, 28894}, {300, 28895}, {375, 28897}, {450, 51311} },
	[165] = { {75, 2108}, {150, 3104}, {225, 3811}, {300, 10662}, {375, 32549}, {450, 51302} },
	[186] = { {75, 2575}, {150, 2576}, {225, 3564}, {300, 10248}, {375, 29354}, {450, 50310} },
	[393] = { {75, 8613}, {150, 8617}, {225, 8618}, {300, 10768}, {375, 32678}, {450, 50305} },
	[197] = { {75, 3908}, {150, 3909}, {225, 3910}, {300, 12180}, {375, 26790}, {450, 51309} }
}

function GetSpellBySkillValue(skillId, value)
	if tradeskillSpell[skillId] then
		local oldValue = 0
		local spellId = nil
		for k,v in pairs(tradeskillSpell[skillId]) do
			if C_InRange(value, oldValue, v[1]) then
				spellId = v[2]
			end
			oldValue = v[1]
		end
		return spellId
	end
end

function EventHandler:ASMSG_GUILD_TRADE_SKILL_LIST( msg )
	local splitData = C_Split( msg, "=" )

	if splitData[2] and splitData[2] ~= "" then
		local playerData = C_Split( splitData[2], "|" )

		splitData[1] = tonumber(splitData[1])

		for _, playerMSG in pairs(playerData) do
			local name, currentSkill, nextSkill, GUID, hash = unpack( C_Split( playerMSG, ":" ) )

			currentSkill 	= tonumber(currentSkill)
			nextSkill 		= tonumber(nextSkill)
			GUID 			= tonumber(GUID)

			local spellID = GetSpellBySkillValue(splitData[1], currentSkill)
			TradeSkillData[splitData[1]].players[name] = {name = name, currentSkill = currentSkill, nextSkill = nextSkill, GUID = GUID, hash = hash, spellID = spellID}
		end

		GuildRoster_SetView("tradeskill")
		GuildRoster()

		UIDropDownMenu_SetSelectedValue(GuildRosterViewDropdown, currentGuildView)
		GenerateGuildTradeSkillInfo()
	end
end

function EventHandler:ASMSG_GUILD_TEAM( msg )
	C_CacheInstance:Set("ASMSG_GUILD_TEAM", SERVER_PLAYER_FACTION_GROUP[tonumber(msg)])
	Hook:FireEvent("ASMSG_GUILD_TEAM")
end