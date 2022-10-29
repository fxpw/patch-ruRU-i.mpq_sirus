UIPanelWindows["LookingForGuildFrame"] = { area = "left", pushable = 1, whileDead = 1, xOffset = "15", yOffset = "-10" };

local GUILD_CARDS_PER_PAGE = 3;
local REQUEST_TO_JOIN_HEIGHT = 350;
local REQUEST_TO_JOIN_TEXT_HEIGHT = 14;
local MAX_DESCRIPTION_HEIGHT = 150;

LookingForGuildMixin = {};

function LookingForGuildMixin:OnLoad()
	self.TabardBackground:Show();
	self.TabardBackground:SetTexCoord(0.63183594, 0.69238281, 0.61914063, 0.74023438);
	self.TabardBackground:SetVertexColor(0.5, 0.5, 0.5);

	self.TabardEmblem:Show();
	self.TabardEmblem:SetTexture("Interface\\PVPFrame\\PvPQueue");
	self.TabardEmblem:SetSize(47, 57);
	self.TabardEmblem:SetPoint("TOPLEFT", 1, 5);

	self.TabardBorder:Show();
	self.TabardBorder:SetTexCoord(0.63183594, 0.69238281, 0.74414063, 0.86523438);
	self.TabardBorder:SetVertexColor(0.25, 0.25, 0.25);

	LookingForGuildFrameTitleText:SetText(LOOKINGFORGUILD);

	self:RegisterEvent("PLAYER_GUILD_UPDATE");

	self:RegisterCustomEvent("LF_GUILD_BROWSE_UPDATED");
	self:RegisterCustomEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED");
	self:RegisterCustomEvent("LF_GUILD_MEMBERSHIP_LIST_CHANGED");
end

function LookingForGuildMixin:OnEvent(event, ...)
	if event == "PLAYER_GUILD_UPDATE" then
		if IsInGuild() and self:IsShown() then
			HideUIPanel(self);
		end
	elseif event == "LF_GUILD_BROWSE_UPDATED" then
		self.GuildCards:BuildCardList();
		self.GuildCards:RefreshLayout();
	elseif event == "LF_GUILD_MEMBERSHIP_LIST_UPDATED" then
		local numAppsLeft = ...;

		self.PendingGuildCards:BuildCardList();
		self.PendingGuildCards:RefreshLayout();

		self:UpdatePendingTab();
	elseif event == "LF_GUILD_MEMBERSHIP_LIST_CHANGED" then
		if self:IsShown() then
			RequestGuildMembershipList();
		end
	end
end

function LookingForGuildMixin:OnShow()
	local factionID = C_Unit:GetFactionID("player");
	if factionID and PVPFRAME_PRESTIGE_FACTION_ICONS[factionID] then
		self.TabardEmblem:SetTexCoord(unpack(PVPFRAME_PRESTIGE_FACTION_ICONS[factionID]));
	else
		self.TabardEmblem:SetTexCoord(unpack(PVPFRAME_PRESTIGE_FACTION_ICONS[PLAYER_FACTION_GROUP.Horde]));
	end

	RequestGuildMembershipList();

	UpdateMicroButtons();
	MicroButtonPulseStop(GuildMicroButton);

	self.selectedTab = 1;

	self:UpdateType();
end

function LookingForGuildMixin:OnHide()
	UpdateMicroButtons();
end

function LookingForGuildMixin:UpdatePendingTab()
	if self.PendingGuildCards.NumCards > 0 then
		self.PendingTab.tooltip = string.format(LOOKING_FOR_GUILD_PENDING_REQUESTS, self.PendingGuildCards.NumCards);
		self.PendingTab:Enable();
		self.PendingTab.Icon:SetDesaturated(false);
	else
		self.PendingTab.tooltip = string.format(LOOKING_FOR_GUILD_PENDING_REQUESTS, 0);
		self.PendingTab:Disable();
		self.PendingTab.Icon:SetDesaturated(true);
	end
end

function LookingForGuildMixin:ClearAllCardLists()
	self.PendingGuildCards:ClearCardList();
	self.GuildCards:ClearCardList();
end

function LookingForGuildMixin:UpdateType()
	self:UpdatePendingTab();

	self:GetDisplayModeBasedOnSelectedTab();
end

function LookingForGuildMixin:GetDisplayModeBasedOnSelectedTab()
	local isInGuild = IsInGuild();

	local isSearchTabSelected = self.selectedTab == 1;

	self.SearchTab:SetShown(not isInGuild);
	self.PendingTab:SetShown(not isInGuild);

	if not isInGuild then
		self.SearchTab:SetChecked(isSearchTabSelected);
		self.PendingTab:SetChecked(not isSearchTabSelected);
	end

	self.GuildCards:SetShown(isSearchTabSelected);
	self.PendingGuildCards:SetShown(not isSearchTabSelected);
	self.OptionsList:SetOptionsState(not isSearchTabSelected);

	self.InsetFrame.GuildDescription:SetText(LOOKING_FOR_GUILD_NO_OPTIONS_SELECTED_GUILD_MESSAGE);
end

LookingForGuildOptionsMixin = {};

function LookingForGuildOptionsMixin:OnLoad()
	UIDropDownMenu_SetWidth(self.FilterDropdown, 120);
	UIDropDownMenu_JustifyText(self.FilterDropdown, "LEFT");

	UIDropDownMenu_SetWidth(self.SizeDropdown, 80);

	self:UpdateRoles();
end

function LookingForGuildOptionsMixin:OnShow()
	self:RefreshRoleButtons();

	UIDropDownMenu_Initialize(self.FilterDropdown, LookingForGuildFilterDropdownInitialize);
	UIDropDownMenu_Initialize(self.SizeDropdown, LookingForGuildSizeDropdownInitialize);
end

function LookingForGuildOptionsMixin:UpdateRoleButton(button, enabled)
	button.Icon:SetDesaturated(not enabled);

	if enabled then
		button.CheckBox:Enable();
	else
		button.CheckBox:Disable();
	end
end

function LookingForGuildOptionsMixin:UpdateRoles()
	local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player");

	self:UpdateRoleButton(self.TankRoleFrame, canBeTank);
	self:UpdateRoleButton(self.HealerRoleFrame, canBeHealer);
	self:UpdateRoleButton(self.DpsRoleFrame, canBeDPS);
end

function LookingForGuildOptionsMixin:RefreshRoleButtons()
	self.TankRoleFrame.CheckBox:SetChecked(GetLookingForGuildSettingsByIndex(LFGUILD_PARAM_TANK));
	self.HealerRoleFrame.CheckBox:SetChecked(GetLookingForGuildSettingsByIndex(LFGUILD_PARAM_HEALER));
	self.DpsRoleFrame.CheckBox:SetChecked(GetLookingForGuildSettingsByIndex(LFGUILD_PARAM_DAMAGE));
end

function LookingForGuildOptionsMixin:SetOptionsState(shouldHide)
	self.TankRoleFrame:SetShown(not shouldHide);
	self.HealerRoleFrame:SetShown(not shouldHide);
	self.DpsRoleFrame:SetShown(not shouldHide);
	self.FilterDropdown:SetShown(not shouldHide);
	self.SizeDropdown:SetShown(not shouldHide);
	self.Search:SetShown(not shouldHide);
	self.SearchBox:SetShown(not shouldHide);

	self.PendingTextFrame:SetShown(shouldHide);
end

function CardRightClickOptionsMenuInitialize(self, level)
	local cardFrame = self:GetParent();
	local cardIndex = cardFrame.cardIndex;
	if not cardIndex then
		return;
	end

	local isPendingCard = cardFrame:GetParent().isPendingCards;

	local info = UIDropDownMenu_CreateInfo();
	info.text = not isPendingCard and GetRecruitingGuildInfo(cardIndex) or GetGuildMembershipRequestInfo(cardIndex);
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, level);

	if isPendingCard then
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE;
		info.text = LOOKING_FOR_GUILD_CANCEL_APPLICATION;
		info.isTitle = false;
		info.notCheckable = true;
		info.disabled = nil;
		info.func = function() CancelGuildMembershipRequest(cardIndex); end
		UIDropDownMenu_AddButton(info, level);
	else
		info.colorCode = HIGHLIGHT_FONT_COLOR_CODE;
		info.text = TALENT_GET_URL_ADRESS_DROPDOWN_TITLE;
		info.isTitle = false;
		info.notCheckable = true;
		info.disabled = nil;
		info.func = function() StaticPopup_Show("LOOKING_FOR_GUILD_URL", GUILD_RECRUITING_URL_TEXT, nil, string.format("https://sirus.su/base/guilds/%d/%d", C_Service:GetRealmID(), GetRecruitingGuildID(cardIndex) or 0)); end
		UIDropDownMenu_AddButton(info, level);
	end
end

LookingForGuildCardMixin = {};

function LookingForGuildCardMixin:OnLoad()
	local parent = self:GetParent();
	if not parent.Cards then
		parent.Cards = {};
	end
	parent.Cards[#parent.Cards + 1] = self;

	self.CardBackground:SetAtlas("guildfinder-card", true);
	self.GuildBannerBackground:SetAtlas("guildfinder-card-guildbanner-background");
	self.GuildBannerShadow:SetAtlas("guildfinder-card-guildbanner-shadow");
	self.GuildBannerBorder:SetAtlas("guildfinder-card-guildbanner-border");

	self.MemberIcon:SetAtlas("groupfinder-waitdot");

	UIDropDownMenu_Initialize(self.RightClickDropdown, CardRightClickOptionsMenuInitialize, "MENU");
end

function LookingForGuildCardMixin:OnMouseDown(button)
	if button == "RightButton" then
		ToggleDropDownMenu(1, nil, self.RightClickDropdown, self, 100, 0);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function LookingForGuildCardMixin:OnLeave()
	GameTooltip:Hide();
end

function LookingForGuildCardMixin:RequestToJoinClub()
	self:GetParent():GetParent().RequestToJoinFrame.card = self;
	self:GetParent():GetParent().RequestToJoinFrame.isLinkedPosting = false;
	self:GetParent():GetParent().RequestToJoinFrame:Initialize();
end

function LookingForGuildCardMixin:UpdateCard()
	local isPendingCard = self:GetParent().isPendingCards;

	local name, level, numMembers, comment, requestPending;
	local timeSince, timeLeft, declined;
	local emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor;
	local bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage;

	if not isPendingCard then
		name, level, numMembers, comment, requestPending = GetRecruitingGuildInfo(self.cardIndex);
		emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = GetRecruitingGuildTabardInfo(self.cardIndex);
		bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage = GetRecruitingGuildSettings(self.cardIndex);
	else
		name, level, numMembers, comment, timeSince, timeLeft, declined = GetGuildMembershipRequestInfo(self.cardIndex);
		emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = GetGuildMembershipRequestTabardInfo(self.cardIndex);
		bQuest, bDungeon, bRaid, bPvP, bRP, bWeekdays, bWeekends, bTank, bHealer, bDamage = GetGuildMembershipRequestSettings(self.cardIndex);
	end

	if not name then
		return;
	end

	self.Name:SetText(name);
	self.Description:SetText(comment:gsub("\n", ""));
	self.MemberCount:SetText(numMembers);

	if emblemStyle then
		SetLargeGuildTabardTextures(self.GuildBannerEmblemLogo, emblemStyle);

		if emblemBackgroundColor and SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor] then
			self.GuildBannerBackground:SetVertexColor(RGB255To1(unpack(SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColor])));
		end

		if emblemColor and SHARED_TABARD_EMBLEM_COLOR[emblemColor] then
			self.GuildBannerEmblemLogo:SetVertexColor(RGB255To1(unpack(SHARED_TABARD_EMBLEM_COLOR[emblemColor])));
		end

		if emblemBorderStyle and SHARED_TABARD_BORDER_COLOR[emblemBorderStyle] then
			if emblemBorderColor and SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor] then
				self.GuildBannerBorder:SetVertexColor(RGB255To1(unpack(SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColor])));
			end
		else
			if emblemBorderColor and SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor] then
				self.GuildBannerBorder:SetVertexColor(RGB255To1(unpack(SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColor])));
			end
		end
	end

	local focusString = {};
	if bQuest then focusString[#focusString + 1] = GUILD_INTEREST_QUEST; end
	if bDungeon then focusString[#focusString + 1] = GUILD_INTEREST_DUNGEON; end
	if bRaid then focusString[#focusString + 1] = GUILD_INTEREST_RAID; end
	if bPvP then focusString[#focusString + 1] = GUILD_INTEREST_PVP; end
	if bRP then focusString[#focusString + 1] = GUILD_INTEREST_RP; end

	if #focusString > 0 then
		self.Focus:SetFormattedText(LOOKING_FOR_GUILD_FOCUS_STRING, table.concat(focusString, ", "));
		self.Focus:Show();
	else
		self.Focus:Hide();
	end

	if requestPending then
		self.RequestJoin:Hide();
		self.RequestStatus:Show();
		self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		self.RequestStatus:SetText(GUILD_MEMBERSHIP_REQUEST_SENT);
	elseif timeLeft then
		self.RequestJoin:Hide();
		self.RequestStatus:Show();
		self.RequestStatus:SetTextColor(GREEN_FONT_COLOR:GetRGB());

		local daysLeft = floor(timeLeft / 86400); -- seconds in a day
		if daysLeft < 1 then
			self.RequestStatus:SetText(GUILD_FINDER_LAST_DAY_LEFT);
		else
			self.RequestStatus:SetFormattedText(GUILD_FINDER_DAYS_LEFT, daysLeft);
		end
	else
		self.RequestJoin:SetShown(not IsInGuild());
		self.RequestStatus:Hide();
	end

	self.RemoveButton:SetShown(isPendingCard);
end

function LookingForGuildCardMixin:OnEnter()
	local isPendingCard = self:GetParent().isPendingCards;

	local name, level, numMembers, comment;
	local _, bTank, bHealer, bDamage, bMorning, bDay, bEvening, bNight;

	if not isPendingCard then
		name, level, numMembers, comment, requestPending = GetRecruitingGuildInfo(self.cardIndex);
		_, _, _, _, _, bWeekdays, bWeekends, bTank, bHealer, bDamage, bMorning, bDay, bEvening, bNight = GetRecruitingGuildSettings(self.cardIndex);
	else
		name, level, numMembers, comment, timeSince, timeLeft, declined = GetGuildMembershipRequestInfo(self.cardIndex);
		_, _, _, _, _, _, _, bTank, bHealer, bDamage, bMorning, bDay, bEvening, bNight = GetGuildMembershipRequestSettings(self.cardIndex);
	end

	if not name then
		return;
	end

	GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT", 10, -250);
	GameTooltip_AddColoredLine(GameTooltip, name, GREEN_FONT_COLOR);
	GameTooltip_AddNormalLine(GameTooltip, LOOKING_FOR_GUILD_GUILD_LEVEL:format(level));
	GameTooltip_AddNormalLine(GameTooltip, LOOKING_FOR_GUILD_ACTIVE_MEMBERS:format(numMembers));

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	GameTooltip_AddNormalLine(GameTooltip, LOOKING_FOR_GUILD_FINDER_LOOKING_FOR);

	if bTank then GameTooltip_AddHighlightLine(GameTooltip, TANK); end
	if bHealer then GameTooltip_AddHighlightLine(GameTooltip, HEALER); end
	if bDamage then GameTooltip_AddHighlightLine(GameTooltip, DAMAGER); end

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	GameTooltip_AddNormalLine(GameTooltip, GUILD_ACTIVITY_TIME);

	if bMorning or bDay or bEvening or bNight then
		if bMorning then GameTooltip_AddHighlightLine(GameTooltip, GUILD_ACTIVITY_TIME_MORNING); end
		if bDay then GameTooltip_AddHighlightLine(GameTooltip, GUILD_ACTIVITY_TIME_DAY); end
		if bEvening then GameTooltip_AddHighlightLine(GameTooltip, GUILD_ACTIVITY_TIME_EVENING); end
		if bNight then GameTooltip_AddHighlightLine(GameTooltip, GUILD_ACTIVITY_TIME_NIGHT); end
	else
		GameTooltip_AddHighlightLine(GameTooltip, LOOKING_FOR_GUILD_ANY_FLAG);
	end

	if not isPendingCard then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);

		GameTooltip_AddNormalLine(GameTooltip, GUILD_AVAILABILITY);

		if bWeekdays or bWeekends then
			if bWeekdays then GameTooltip_AddHighlightLine(GameTooltip, GUILD_AVAILABILITY_WEEKDAYS); end
			if bWeekends then GameTooltip_AddHighlightLine(GameTooltip, GUILD_AVAILABILITY_WEEKENDS); end
		else
			GameTooltip_AddHighlightLine(GameTooltip, LOOKING_FOR_GUILD_ANY_FLAG);
		end
	end

	if comment ~= "" then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, COMMENT);
		GameTooltip_AddHighlightLine(GameTooltip, string.format("\"%s\"", comment));
	end

	GameTooltip:Show();
end

LookingForGuildCardsBaseMixin = {};

function LookingForGuildCardsBaseMixin:ClearCardList()
	self.NumCards = 0;
	self.numPages = 0;
	self.pageNumber = 1;
end

function LookingForGuildCardsBaseMixin:OnLoad()
	self.NumCards = 0;
	self.numPages = 1;
	self.pageNumber = 1;
end

function LookingForGuildCardsBaseMixin:OnShow()
	self:RefreshLayout(self.pageNumber);
end

function LookingForGuildCardsBaseMixin:OnHide()
	self.pageNumber = 1;
end

function LookingForGuildCardsBaseMixin:OnMouseWheel(delta)
	local nextPageValue = self.pageNumber + 1;
	local previousPageValue = self.pageNumber - 1;

	if delta < 0 and previousPageValue > 0 then
		self:PagePrevious();
	elseif delta > 0 and nextPageValue <= self.numPages then
		self:PageNext();
	end
end

function LookingForGuildCardsBaseMixin:PageNext()
	self.pageNumber = self.pageNumber + 1;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CloseDropDownMenus();
	self:RefreshLayout(self.pageNumber);
end

function LookingForGuildCardsBaseMixin:PagePrevious()
	self.pageNumber = self.pageNumber - 1;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	CloseDropDownMenus();
	self:RefreshLayout(self.pageNumber);
end

function LookingForGuildCardsBaseMixin:HideCardList()
	for i = 1, #self.Cards do
		self.Cards[i]:Hide();
	end
end

function LookingForGuildCardsBaseMixin:RefreshLayout(cardPage)
	if not self:IsShown() then
		return;
	end

	if not cardPage then
		cardPage = 1;
	end

	self.showingCards = false;

	local numCardsTotal = self.NumCards;

	for i = 1, #self.Cards do
		local cardIndex = (cardPage - 1) * GUILD_CARDS_PER_PAGE + i;

		if cardIndex <= numCardsTotal then
			self.Cards[i].cardIndex = cardIndex;

			self.Cards[i]:UpdateCard();
			self.Cards[i]:Show();

			if self.Cards[i]:IsMouseOver() then
				self.Cards[i]:OnEnter();
			end

			self.showingCards = true;
		else
			self.Cards[i].cardIndex = nil;
			self.Cards[i]:Hide();
		end
	end

	local parent = self:GetParent();
	parent.InsetFrame.GuildDescription:SetShown(not self.showingCards);

	if self.showingCards then
		if self.numPages <= 1 then
			self.PreviousPage:Hide();
			self.NextPage:Hide();
		else
			self.PreviousPage:Show();
			self.NextPage:Show();
		end
	else
		if self.isPendingCards then
			parent.selectedTab = 1;
			parent:GetDisplayModeBasedOnSelectedTab();
		end

		self.PreviousPage:Hide();
		self.NextPage:Hide();
	end

	if cardPage <= 1 then
		self.PreviousPage:SetEnabled(false);
	else
		self.PreviousPage:SetEnabled(true);
	end

	if cardPage < self.numPages then
		self.NextPage:SetEnabled(true);
	else
		self.NextPage:SetEnabled(false);
	end
end

LookingForGuildCardsMixin = CreateFromMixins(LookingForGuildCardsBaseMixin);
function LookingForGuildCardsMixin:OnLoad()
	LookingForGuildCardsBaseMixin.OnLoad(self);

	self.isPendingCards = false;
end

function LookingForGuildCardsMixin:BuildCardList()
	local totalSize = GetNumRecruitingGuilds();
	self.numPages = 0;
	self.NumCards = totalSize;

	if totalSize == 0 then
		self:GetParent().InsetFrame.GuildDescription:SetText(LOOKING_FOR_GUILD_SEARCH_NOTHING_FOUND);
	else
		self.numPages = math.ceil(totalSize / GUILD_CARDS_PER_PAGE); --Need to get the number of pages
	end
end

LookingForPendingCardsMixin = CreateFromMixins(LookingForGuildCardsBaseMixin);
function LookingForPendingCardsMixin:OnLoad()
	LookingForGuildCardsBaseMixin.OnLoad(self);

	self.isPendingCards = true;
end

function LookingForPendingCardsMixin:BuildCardList()
	local totalSize = GetNumGuildMembershipRequests();
	self.numPages = 0;
	self.NumCards = totalSize;
	self.numPages = math.ceil(totalSize / GUILD_CARDS_PER_PAGE);
end

LookingForGuildRequestToJoinMixin = {};

function LookingForGuildRequestToJoinMixin:OnShow()

end

function LookingForGuildRequestToJoinMixin:OnHide()
	self.MessageFrame.MessageScroll.EditBox:SetText("");
end

function LookingForGuildRequestToJoinMixin:ApplyButtonOnEnter()
	GameTooltip:SetOwner(self.Apply, "ANCHOR_LEFT", 0, -65);
end

function LookingForGuildRequestToJoinMixin:ApplyButtonOnLeave()
	GameTooltip:Hide();
end

function LookingForGuildRequestToJoinMixin:ApplyToClub()
	local editbox = self.MessageFrame.MessageScroll.EditBox;
	RequestGuildMembership(self.cardIndex, editbox:GetText():gsub("\n",""));
end

function LookingForGuildRequestToJoinMixin:Initialize()
	self.cardIndex = self.card.cardIndex;

	if not self.cardIndex then
		return;
	end

	local name, level, numMembers, comment, requestPending = GetRecruitingGuildInfo(self.cardIndex);
	self.GuildName:SetText(name);
	self.GuildDescription:SetText(comment:gsub("\n", ""));

	local extraFrameHeight = 0;
	local usedHeight = self.GuildDescription:GetHeight();
	local extraHeight = (MAX_DESCRIPTION_HEIGHT - usedHeight);

	self:SetHeight((REQUEST_TO_JOIN_HEIGHT + extraFrameHeight) - extraHeight);

	self.GuildDescription:ClearAllPoints();
	self.GuildDescription:SetPoint("BOTTOM", self.GuildName, "BOTTOM", 0, -(usedHeight + 2));

	self.MessageFrame:ClearAllPoints();
	self.MessageFrame:SetPoint("BOTTOM", self.GuildDescription, "BOTTOM", 0, -85);

	self:Show();
end

local function LookingForGuildFilterUpdateDropdownText(self, text, evalValue, value, allowMultipleSelection)
	if allowMultipleSelection then
		local selectedCount = GetLookingForGuildFlagsSelectedCount();
		if selectedCount > 1 then
			UIDropDownMenu_SetText(self, LOOKING_FOR_GUILD_MULTIPLE_CHECKED);
		elseif selectedCount == 0 then
			UIDropDownMenu_SetText(self, LOOKING_FOR_GUILD_ANY_FLAG);
		else
			UIDropDownMenu_Refresh(self);
		end
	elseif evalValue and value ~= self.selectedValue then
		UIDropDownMenu_SetText(self, text);
		self.selectedValue = value;
	elseif not evalValue and value == self.selectedValue then
		UIDropDownMenu_SetText(self, LOOKING_FOR_GUILD_ANY_FLAG);
		self.selectedValue = nil;
	elseif not self.selectedValue then
		UIDropDownMenu_SetText(self, LOOKING_FOR_GUILD_ANY_FLAG);
	end
end

local function LookingForGuildFilterSetDropdownInfoForPreferences(self, info, value, text, allowMultipleSelection)
	LookingForGuildFilterUpdateDropdownText(self, text, GetLookingForGuildSettingsByIndex(value), value, allowMultipleSelection);

	info.checked = function() return GetLookingForGuildSettingsByIndex(value) end;
	info.func = function()
		local newValue = not GetLookingForGuildSettingsByIndex(value);
		SetLookingForGuildSettings(value, newValue);
		LookingForGuildFilterUpdateDropdownText(self, text, newValue, value, allowMultipleSelection);
	end
end

function LookingForGuildFocusDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.minWidth = 130;
	local allowMultipleSelection = true;

	info.text = GUILD_INTEREST_QUEST;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_QUESTS, GUILD_INTEREST_QUEST, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_DUNGEON;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_DUNGEONS, GUILD_INTEREST_DUNGEON, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_RAID;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_RAIDS, GUILD_INTEREST_RAID, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_PVP;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_PVP, GUILD_INTEREST_PVP, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_INTEREST_RP;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_RP, GUILD_INTEREST_RP, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);
end

function LookingForGuildAvailabilityDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.minWidth = 130;
	local allowMultipleSelection = true;

	info.text = GUILD_AVAILABILITY_WEEKDAYS;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_WEEKDAYS, GUILD_AVAILABILITY_WEEKDAYS, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_AVAILABILITY_WEEKENDS;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_WEEKENDS, GUILD_AVAILABILITY_WEEKENDS, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);
end

function LookingForGuildActivityTimeDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.minWidth = 130;
	local allowMultipleSelection = true;

	info.text = GUILD_ACTIVITY_TIME_MORNING;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_MORNING, GUILD_ACTIVITY_TIME_MORNING, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_ACTIVITY_TIME_DAY;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_DAY, GUILD_ACTIVITY_TIME_DAY, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_ACTIVITY_TIME_EVENING;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_EVENING, GUILD_ACTIVITY_TIME_EVENING, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_ACTIVITY_TIME_NIGHT;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_NIGHT, GUILD_ACTIVITY_TIME_NIGHT, allowMultipleSelection);
	UIDropDownMenu_AddButton(info);
end

function LookingForGuildFilterDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.text = GUILD_INTEREST;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	LookingForGuildFocusDropdownInitialize(self);

	info.text = GUILD_AVAILABILITY;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	LookingForGuildAvailabilityDropdownInitialize(self);

	info.text = GUILD_ACTIVITY_TIME;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	LookingForGuildActivityTimeDropdownInitialize(self);
end

function LookingForGuildSizeDropdownInitialize(self)
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.keepShownOnClick = true;

	info.text = GUILD_SMALL;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_SMALL, info.text);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_MEDIUM;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_MEDIUM, info.text);
	UIDropDownMenu_AddButton(info);

	info.text = GUILD_LARGE;
	LookingForGuildFilterSetDropdownInfoForPreferences(self, info, LFGUILD_PARAM_LARGE, info.text);
	UIDropDownMenu_AddButton(info);
end

function LookingForGuildFrame_Toggle()
	if LookingForGuildFrame:IsShown() then
		HideUIPanel(LookingForGuildFrame);
	else
		ShowUIPanel(LookingForGuildFrame);
	end
end