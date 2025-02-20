EXPANSION_LEVEL = GetExpansionLevel(); --This doesn't change while logged in, so we just need to do it once.

LFD_MAX_REWARDS = 2;

NUM_LFD_CHOICE_BUTTONS = 15;
TYPEID_DUNGEON = 1;
TYPEID_HEROIC_DIFFICULTY = 5;
TYPEID_RANDOM_DUNGEON = 6;

NUM_LFD_MEMBERS = 5;

LFD_STATISTIC_CHANGE_TIME = 10; --In secs.

LFD_PROPOSAL_FAILED_CLOSE_TIME = 5;

LFD_NUM_ROLES = 3;

LFD_MAX_SHOWN_LEVEL_DIFF = 15;

local NUM_STATISTIC_TYPES = 1;

local groupFrames = {"LFDQueueParentFrame", "MiniGamesParentFrame"}

-------------------------------------
-----------LFD Frame--------------
-------------------------------------

--General functions
function LFDFrame_OnLoad(self)
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW");
	self:RegisterEvent("LFG_ROLE_CHECK_HIDE");
	self:RegisterEvent("LFG_BOOT_PROPOSAL_UPDATE");
	self:RegisterEvent("VOTE_KICK_REASON_NEEDED");
	self:RegisterEvent("LFG_ROLE_UPDATE");
	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO");
	self:RegisterEvent("LFG_OPEN_FROM_GOSSIP");
	self:RegisterEvent("GOSSIP_CLOSED");
	self:RegisterEvent("VARIABLES_LOADED");

	self:RegisterCustomEvent("UPDATE_AVAILABLE_MINI_GAMES");
	self:RegisterCustomEvent("AJ_ACTION_PVE_LFG")

	LFDQueueParentFrame.Inset:SetPoint("TOPLEFT", LFDQueueParentFrame, "BOTTOMLEFT", 2, 284)
	LFDQueueParentFrame.Inset:SetPoint("BOTTOMRIGHT", LFDQueueParentFrame, "BOTTOMRIGHT", -2, 26)

	SetPortraitToTexture(LFDParentFrame.Art.portrait, "Interface\\LFGFrame\\UI-LFG-PORTRAIT")
	LFDParentFrame.Art.TitleText:SetText(LOOK_FOR_GROUP)

	RaiseFrameLevelByTwo(self.Shadows)

	SetPortraitToTexture(self.groupButton1.icon, "Interface\\Icons\\INV_Helmet_08")
	self.groupButton1.name:SetText(LOOKING_FOR_DUNGEON)
	self.groupButton1.bg:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188)

	self.groupButton2:SetEnabled(false);
	SetPortraitToTexture(self.groupButton2.icon, "Interface\\Icons\\inv_misc_toy_07")
	self.groupButton2.name:SetText(MINI_GAMES)
	self.groupButton2.name:SetTextColor(0.6, 0.6, 0.6);
	self.groupButton2.icon:SetDesaturated(true);
	self.groupButton2.ring:SetDesaturated(true);
	self.groupButton2.bg:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188)
end

function GroupFinderFrameGroupButton_OnClick(self, button)
	GroupFinderFrameGroupButton_SetGroupTabIndex(self:GetID())
end

function GroupFinderFrameGroupButton_SetGroupTabIndex(tabIndex)
	local frame = _G[groupFrames[tabIndex]]
	if frame and LFDParentFrame.selection ~= frame then
		LFDFrame_ShowGroupFrame(frame)
	end
end

function LFDFrame_OnEvent(self, event, ...)
	if ( event == "LFG_PROPOSAL_UPDATE" ) then
		LFDDungeonReadyPopup_Update();
	elseif ( event == "LFG_PROPOSAL_SHOW" ) then
		LFDDungeonReadyPopup.closeIn = nil;
		LFDDungeonReadyPopup:SetScript("OnUpdate", nil);
		LFDDungeonReadyStatus_ResetReadyStates();
		StaticPopupSpecial_Show(LFDDungeonReadyPopup);
		LFDSearchStatus:Hide();
		PlaySound("ReadyCheck");
		FlashClientIcon();
	elseif ( event == "LFG_PROPOSAL_FAILED" ) then
		LFDDungeonReadyPopup_OnFail();
	elseif ( event == "LFG_PROPOSAL_SUCCEEDED" ) then
		LFGDebug("Proposal Hidden: Proposal succeeded.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	elseif ( event == "LFG_ROLE_CHECK_SHOW" ) then
		StaticPopupSpecial_Show(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_ROLE_CHECK_HIDE" ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
		LFDQueueFrameSpecificList_Update();
	elseif ( event == "LFG_BOOT_PROPOSAL_UPDATE" ) then
		local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft, reason = GetLFGBootProposal();
		if ( voteInProgress and not didVote and targetName ) then
			local inInstance, instanceType = IsInInstance()
			local targetNameColored = GetClassColoredTextForUnit(targetName, targetName)
			if instanceType == "pvp" then
				if C_Service.IsBattlegroundKickEnabled() then
					if InCombatLockdown() then
						FireCustomClientEvent("SHOW_TOAST", 8, 0, "achievement_general_classicbattles", TOAST_CS_VOTE_KICK_BG_TITLE, TOAST_CS_VOTE_KICK_BG_BODY)
					else
						StaticPopup_Show("VOTE_BOOT_PLAYER_PVP", targetNameColored, reason, targetName)
					end
				end
			else
				StaticPopup_Show("VOTE_BOOT_PLAYER", targetNameColored, reason);
			end
		else
			StaticPopup_Hide("VOTE_BOOT_PLAYER");
			StaticPopup_Hide("VOTE_BOOT_PLAYER_PVP")
		end
	elseif ( event == "VOTE_KICK_REASON_NEEDED" ) then
		local targetName = ...;
		StaticPopup_Show("VOTE_BOOT_REASON_REQUIRED", targetName, nil, targetName);
	elseif ( event == "LFG_ROLE_UPDATE" ) then
		LFG_UpdateRoleCheckboxes();
	elseif ( event == "LFG_UPDATE_RANDOM_INFO" ) then
		if ( not LFDQueueFrame.type or (type(LFDQueueFrame.type) == "number" and not IsLFGDungeonJoinable(LFDQueueFrame.type)) ) then
			LFDQueueFrame.type = GetRandomDungeonBestChoice();
			UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
		end
		--If we still don't have a value, we should go to specific.
		if ( not LFDQueueFrame.type ) then
			LFDQueueFrame.type = "specific";
			UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
			LFDQueueFrame_SetTypeSpecificDungeon();
		elseif ( LFDQueueFrameRandom:IsShown() ) then
			LFDQueueFrameRandom_UpdateFrame();
		end
	elseif ( event == "LFG_OPEN_FROM_GOSSIP" ) then
		local dungeonID = ...;
		LFDParentFrame.fromGossip = true;
		ShowUIPanel(LFDParentFrame);
		LFDQueueFrame_SetType(dungeonID);
	elseif ( event == "GOSSIP_CLOSED" ) then
		if ( LFDParentFrame.fromGossip ) then
			HideUIPanel(LFDParentFrame);
		end
	elseif event == "VARIABLES_LOADED" then
		UpdatePVPTabs(self)
	elseif event == "UPDATE_AVAILABLE_MINI_GAMES" then
		local isAvailableMiniGames = C_MiniGames.GetNumGames() > 0;

		self.groupButton2:SetEnabled(isAvailableMiniGames);
		self.groupButton2.icon:SetDesaturated(not isAvailableMiniGames);
		self.groupButton2.ring:SetDesaturated(not isAvailableMiniGames);

		if isAvailableMiniGames then
			self.groupButton2.name:SetTextColor(1.0, 0.82, 0);
		else
			self.groupButton2.name:SetTextColor(0.6, 0.6, 0.6);
		end
	elseif event == "AJ_ACTION_PVE_LFG" then
		local desiredViewType, lfgDungeonID = ...

		if not self:IsShown() then
			ShowUIPanel(self)
		end

		local categoryIndex = desiredViewType == "pve-lfg-minigame" and 2 or 1

		GroupFinderFrameGroupButton_SetGroupTabIndex(categoryIndex)

		if desiredViewType == "pve-lfg-dungeon" then
			if lfgDungeonID ~= 0 and IsLFGDungeonJoinable(lfgDungeonID) then
				local name, typeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(lfgDungeonID)
				if name then
					local level = UnitLevel("player")
					if level >= minLevel and level <= maxLevel and EXPANSION_LEVEL >= expansionLevel then
						LFDQueueFrame_SetType(lfgDungeonID)
					end
				end
			end
		elseif desiredViewType == "pve-lfg-minigame" then
			if lfgDungeonID ~= 0 then
				for index = 1, C_MiniGames.GetNumGames() do
					if C_MiniGames.GetGameIDFromIndex(index) == lfgDungeonID then
						MiniGamesParentFrame:SetSelectedGame(lfgDungeonID)
						break
					end
				end
			end
		end

		return
	end
	LFDQueueFrame_UpdatePortrait();
end

function LFDFrame_OnShow(self)
	LFDFrame_UpdateBackfill(true);
	PanelTemplates_SetTab(self, 1)
	UpdateMicroButtons()

	LFDFrame_ShowGroupFrame();

	if UnitLevel("player") < 15 then
		HideUIPanel(self)
		ShowUIPanel(PVPUIFrame)
		PanelTemplates_DisableTab(self, 1)
	else
		PanelTemplates_EnableTab(self, 1)
	end

	EventRegistry:TriggerEvent("LFDParentFrame.OnShow")
end

function LFDFrame_OnHide(self)
	if ( self.fromGossip ) then
		CloseGossip();
		self.fromGossip = false;
	end

	LAST_FINDPARTY_FRAME = self

	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonTank, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonHealer, nil);
	LFG_SetRoleIconIncentive(LFDQueueFrameRoleButtonDPS, nil);

	EventRegistry:TriggerEvent("LFDParentFrame.OnHide")
end

function LFDFrame_ShowGroupFrame(frame)
	frame = frame or LFDParentFrame.selection or LFDQueueParentFrame;
	for index, frameName in pairs(groupFrames) do
		local groupFrame = _G[frameName];
		if groupFrame == frame then
			LFDFrame_SelectGroupButton(index);
		else
			groupFrame:Hide();
		end
	end
	frame:Show();
	LFDParentFrame.selection = frame;
end

function LFDFrame_SelectGroupButton(index)
	for i = 1, #groupFrames do
		local button = LFDParentFrame["groupButton"..i];
		if i == index then
			button.bg:SetTexCoord(0.00390625, 0.87890625, 0.59179688, 0.66992188);
		else
			button.bg:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813);
		end
	end

	LFDParentFrame.selectionIndex = index
end

function LFDQueueFrame_UpdatePortrait()
	local mode, submode = GetLFGMode();
	if ( mode == "queued" or mode == "rolecheck" ) then
		-- EyeTemplate_StartAnimating(LFDParentFramePortrait);
	else
		-- EyeTemplate_StopAnimating(LFDParentFramePortrait);
	end
end

--Backfill option
function LFDFrame_UpdateBackfill(forceUpdate)
	if ( CanPartyLFGBackfill() ) then
		local name, lfgID, typeID = GetPartyLFGBackfillInfo();
		LFDQueueFramePartyBackfillDescription:SetFormattedText(LFG_OFFER_CONTINUE, HIGHLIGHT_FONT_COLOR_CODE..name.."|r");
		local mode, subMode = GetLFGMode();
		if ( (forceUpdate or not LFDQueueFrame:IsVisible()) and mode ~= "queued" ) then
			LFDQueueFramePartyBackfill:Show();
		end
	else
		LFDQueueFramePartyBackfill:Hide();
	end
end

--Role-related functions

function LFDQueueFrame_SetRoles()
	SetLFGRoles(LFDQueueFrameRoleButtonLeader.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonTank.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonHealer.checkButton:GetChecked(),
		LFDQueueFrameRoleButtonDPS.checkButton:GetChecked());

	LFGFrame_SendUpdateCurrentRoles();
end

function LFDFrameRoleCheckButton_OnClick(self)
	LFDQueueFrame_SetRoles();
end

--Role-check popup functions
function LFDRoleCheckPopupAccept_OnClick()
	PlaySound("igCharacterInfoTab");
	local oldLeader = GetLFGRoles();
	SetLFGRoles(oldLeader,
		LFDRoleCheckPopupRoleButtonTank.checkButton:GetChecked(),
		LFDRoleCheckPopupRoleButtonHealer.checkButton:GetChecked(),
		LFDRoleCheckPopupRoleButtonDPS.checkButton:GetChecked());
	if ( CompleteLFGRoleCheck(true) ) then
		StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	end
end

function LFDRoleCheckPopupDecline_OnClick()
	PlaySound("igCharacterInfoTab");
	StaticPopupSpecial_Hide(LFDRoleCheckPopup);
	CompleteLFGRoleCheck(false);
end

function LFDRoleCheckPopup_Update()
	LFGDungeonList_Setup();

	LFG_UpdateRoleCheckboxes();

	local inProgress, slots, members = GetLFGRoleUpdate();

	local displayName;
	if ( slots == 1 ) then
		local dungeonType, dungeonID = GetLFGRoleUpdateSlot(1);
		if ( dungeonType == TYPEID_RANDOM_DUNGEON ) then
			displayName = A_RANDOM_DUNGEON;
		elseif ( dungeonType == TYPEID_HEROIC_DIFFICULTY ) then
			displayName = format(HEROIC_PREFIX, select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID)));
		else
			displayName = select(LFG_RETURN_VALUES.name, GetLFGDungeonInfo(dungeonID));
		end
	else
		displayName = MULTIPLE_DUNGEONS;
	end
	displayName = NORMAL_FONT_COLOR_CODE..displayName.."|r";

	LFDRoleCheckPopupDescriptionText:SetFormattedText(QUEUED_FOR, displayName);

	LFDRoleCheckPopupDescription:SetWidth(LFDRoleCheckPopupDescriptionText:GetWidth()+10);
	LFDRoleCheckPopupDescription:SetHeight(LFDRoleCheckPopupDescriptionText:GetHeight());
end

function LFDRoleCheckPopupDescription_OnEnter(self)
	local inProgress, slots, members = GetLFGRoleUpdate();

	if ( slots <= 1 ) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip:AddLine(QUEUED_FOR_SHORT);

	for i=1, slots do
		local dungeonType, dungeonID = GetLFGRoleUpdateSlot(i);
		local displayName;
		if ( dungeonType == TYPEID_HEROIC_DIFFICULTY ) then
			displayName = format(HEROIC_PREFIX, LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.name]);
		else
			displayName = LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.name];
		end
		GameTooltip:AddLine("    "..displayName);
	end
	GameTooltip:Show();
end

function LFDFrameRoleCheckButton_OnEnter(self)
	if ( self.checkButton:IsEnabled() == 1 ) then
		self.checkButton:LockHighlight();
	end
end

--List functions
function LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, submode)
	local info = LFGGetDungeonInfoByID(dungeonID);
	button.id = dungeonID;
	if ( LFGIsIDHeader(dungeonID) ) then
		local name = info[LFG_RETURN_VALUES.name];

		button.instanceName:SetText(name);
		button.instanceName:SetFontObject(QuestDifficulty_Header);
		button.instanceName:SetPoint("RIGHT", button, "RIGHT", 0, 0);
		button.level:Hide();

		if ( info[LFG_RETURN_VALUES.typeID] == TYPEID_HEROIC_DIFFICULTY ) then
			button.heroicIcon:Show();
			button.instanceName:SetPoint("LEFT", button.heroicIcon, "RIGHT", 0, 1);
		else
			button.heroicIcon:Hide();
			button.instanceName:SetPoint("LEFT", 40, 0);
		end

		button.expandOrCollapseButton:Show();
		local isCollapsed = LFGCollapseList[dungeonID];
		button.isCollapsed = isCollapsed;
		if ( isCollapsed ) then
			button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
		else
			button.expandOrCollapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP");
		end
	else
		local name =  info[LFG_RETURN_VALUES.name];
		local minLevel, maxLevel = info[LFG_RETURN_VALUES.minLevel], info[LFG_RETURN_VALUES.maxLevel];
		local minRecLevel, maxRecLevel = info[LFG_RETURN_VALUES.minRecLevel], info[LFG_RETURN_VALUES.maxRecLevel];
		local recLevel = info[LFG_RETURN_VALUES.recLevel];

		button.instanceName:SetText(name);
		button.instanceName:SetPoint("RIGHT", button.level, "LEFT", -10, 0);

		button.heroicIcon:Hide();
		button.instanceName:SetPoint("LEFT", 40, 0);

		if ( minLevel == maxLevel ) then
			button.level:SetText(format(LFD_LEVEL_FORMAT_SINGLE, minLevel));
		else
			button.level:SetText(format(LFD_LEVEL_FORMAT_RANGE, minLevel, maxLevel));
		end
		button.level:Show();
		local difficultyColor = GetQuestDifficultyColor(recLevel);
		button.level:SetFontObject(difficultyColor.font);

		if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFD_IsEmpowered()) then
			button.instanceName:SetFontObject(QuestDifficulty_Header);
		else
			button.instanceName:SetFontObject(difficultyColor.font);
		end


		button.expandOrCollapseButton:Hide();

		button.isCollapsed = false;
	end

	if ( LFGLockList[dungeonID] ) then
		button.enableButton:Hide();
		button.lockedIndicator:Show();
	else
		button.enableButton:Show();
		button.lockedIndicator:Hide();
	end

	local enableState= LFGEnabledList;
	if ( mode == "queued" or mode == "listed" ) then
		enableState = LFGQueuedForList[dungeonID];
	else
		enableState = LFGEnabledList[dungeonID];
	end

	if ( enableState == 1 ) then	--Some are checked, some aren't.
		button.enableButton:SetCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Up");
		button.enableButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-MultiCheck-Disabled");
	else
		button.enableButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
		button.enableButton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
	end
	button.enableButton:SetChecked(enableState and enableState ~= 0);

	if ( mode == "rolecheck" or mode == "queued" or mode == "listed" or not LFD_IsEmpowered() ) then
		button.enableButton:Disable();
	else
		button.enableButton:Enable();
	end
end

function LFDQueueFrameSpecificList_Update()
	if ( LFGDungeonList_Setup() ) then
		return;	--Setup will update the list.
	end
	FauxScrollFrame_Update(LFDQueueFrameSpecificListScrollFrame, LFDGetNumDungeons(), NUM_LFD_CHOICE_BUTTONS, 16);

	local offset = FauxScrollFrame_GetOffset(LFDQueueFrameSpecificListScrollFrame);

	local areButtonsBig = not LFDQueueFrameSpecificListScrollFrame:IsShown();

	local mode, subMode = GetLFGMode();

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton"..i];
		local dungeonID = LFDDungeonList[i+offset];
		if ( dungeonID ) then
			button:Show();
			if ( areButtonsBig ) then
				button:SetWidth(315);
			else
				button:SetWidth(295);
			end
			LFDQueueFrameSpecificListButton_SetDungeon(button, dungeonID, mode, subMode);
		else
			button:Hide();
		end
	end
end

function LFDList_SetHeaderCollapsed(headerID, isCollapsed)
	SetLFGHeaderCollapsed(headerID, isCollapsed);
	LFGCollapseList[headerID] = isCollapsed;
	for _, dungeonID in pairs(LFDDungeonList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFGCollapseList[dungeonID] = isCollapsed;
		end
	end
	LFDQueueFrame_Update();
end

function LFDQueueFrame_QueueForInstanceIfEnabled(queueID)
	if ( not LFGIsIDHeader(queueID) and LFGEnabledList[queueID] and not LFGLockList[queueID] ) then
		local info = LFGGetDungeonInfoByID(queueID);
		SetLFGDungeon(queueID);
		return true;
	end
	return false;
end

function LFDQueueFrame_Join()
	if ( LFDQueueFrame.type == "specific" ) then	--Random queue
		ClearAllLFGDungeons();
		for _, queueID in pairs(LFDDungeonList) do
			LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		for _, queueID in pairs(LFDHiddenByCollapseList) do
			LFDQueueFrame_QueueForInstanceIfEnabled(queueID);
		end
		JoinLFG();
	else
		ClearAllLFGDungeons();
		SetLFGDungeon(LFDQueueFrame.type);
		JoinLFG();
	end
end

function LFDQueueFrameDungeonChoiceEnableButton_OnClick(self, button)
	local parent = self:GetParent();
	local dungeonID = parent.id;
	local isChecked = self:GetChecked();

	PlaySound(isChecked and "igMainMenuOptionCheckBoxOff" or "igMainMenuOptionCheckBoxOff");
	if ( LFGIsIDHeader(dungeonID) ) then
		LFDList_SetHeaderEnabled(dungeonID, isChecked);
	else
		LFDList_SetDungeonEnabled(dungeonID, isChecked);
		LFGListUpdateHeaderEnabledAndLockedStates(LFDDungeonList, LFGEnabledList, LFGLockList, LFDHiddenByCollapseList);
	end
	LFDQueueFrameSpecificList_Update();
end

function LFDList_SetDungeonEnabled(dungeonID, isEnabled)
	SetLFGDungeonEnabled(dungeonID, isEnabled);
	LFGEnabledList[dungeonID] = not not isEnabled; --Change to true/false.
end

function LFDList_SetHeaderEnabled(headerID, isEnabled)
	for _, dungeonID in pairs(LFDDungeonList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	for _, dungeonID in pairs(LFDHiddenByCollapseList) do
		if ( LFGGetDungeonInfoByID(dungeonID)[LFG_RETURN_VALUES.groupID] == headerID ) then
			LFDList_SetDungeonEnabled(dungeonID, isEnabled);
		end
	end
	LFGEnabledList[headerID] = not not isEnabled; --Change to true/false.
end

function LFDQueueFrameDungeonListButton_OnEnter(self)
	local dungeonID = self.id;
	if ( self.lockedIndicator:IsShown() ) then
		if ( LFGIsIDHeader(dungeonID) ) then
			--GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			--GameTooltip:AddLine(YOU_MAY_NOT_QUEUE_FOR_CATEGORY, 1.0, 1.0, 1.0);
			--GameTooltip:Show();
		else
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:AddLine(YOU_MAY_NOT_QUEUE_FOR_DUNGEON, 1.0, 1.0, 1.0);
			for i=1, GetLFDLockPlayerCount() do
				local playerName, lockedReason = GetLFDLockInfo(dungeonID, i);
				if ( lockedReason ~= 0 ) then
					local who;
					if ( i == 1 ) then
						who = "SELF_";
					else
						who = "OTHER_";
					end
					GameTooltip:AddLine(format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName));
				end
			end
			GameTooltip:Show();
		end
	end
end

function LFDQueueFrameExpandOrCollapseButton_OnClick(self, button)
	local parent = self:GetParent();
	LFDList_SetHeaderCollapsed(parent.id, not parent.isCollapsed);
end

--Ready popup functions

function LFDDungeonReadyPopup_OnFail()
	PlaySound("LFG_Denied");
	if ( LFDDungeonReadyDialog:IsShown() ) then
		LFGDebug("Proposal Hidden: Proposal failed.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	elseif ( LFDDungeonReadyPopup:IsShown() ) then
		LFDDungeonReadyPopup.closeIn = LFD_PROPOSAL_FAILED_CLOSE_TIME;
		LFDDungeonReadyPopup:SetScript("OnUpdate", LFDDungeonReadyPopup_OnUpdate);
	end
end

function LFDDungeonReadyPopup_OnUpdate(self, elapsed)
	self.closeIn = self.closeIn - elapsed;
	if ( self.closeIn < 0 ) then	--We remove the OnUpdate and closeIn OnHide
		LFGDebug("Proposal Hidden: Failure close timer expired.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
	end
end

function LFDDungeonReadyPopup_Update()
	local proposalExists, typeID, id, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader = GetLFGProposal();

	if ( not proposalExists ) then
		LFGDebug("Proposal Hidden: No proposal exists.");
		StaticPopupSpecial_Hide(LFDDungeonReadyPopup);
		return;
	end

	LFDDungeonReadyPopup.dungeonID = id;

	if ( hasResponded ) then
		LFDDungeonReadyStatus:Show();
		LFDDungeonReadyDialog:Hide();

		for i=1, numMembers do
			LFDDungeonReadyStatus_UpdateIcon(_G["LFDDungeonReadyStatusPlayer"..i]);
		end
		for i=numMembers+1, NUM_LFD_MEMBERS do
			_G["LFDDungeonReadyStatusPlayer"..i]:Hide();
		end

		if ( not LFDDungeonReadyPopup:IsShown() or StaticPopup_IsLastDisplayedFrame(LFDDungeonReadyPopup) ) then
			LFDDungeonReadyPopup:SetHeight(LFDDungeonReadyStatus:GetHeight());
		end
	else
		LFDDungeonReadyDialog:Show();
		LFDDungeonReadyStatus:Hide();

		local LFDDungeonReadyDialog = LFDDungeonReadyDialog; --Make a local copy.

		if ( typeID == TYPEID_RANDOM_DUNGEON ) then
			LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-RANDOMDUNGEON");

			LFDDungeonReadyDialog.label:SetText(RANDOM_DUNGEON_IS_READY);

			LFDDungeonReadyDialog.instanceInfo:Hide();

			if ( completedEncounters > 0 ) then
				LFDDungeonReadyDialog.randomInProgress:Show();
				LFDDungeonReadyPopup:SetHeight(223);
				LFDDungeonReadyDialog.background:SetTexCoord(0, 1, 0, 1);
			else
				LFDDungeonReadyDialog.randomInProgress:Hide();
				LFDDungeonReadyPopup:SetHeight(193);
				LFDDungeonReadyDialog.background:SetTexCoord(0, 1, 0, 118/128);
			end
		else
			LFDDungeonReadyDialog.randomInProgress:Hide();
			LFDDungeonReadyPopup:SetHeight(223);
			LFDDungeonReadyDialog.background:SetTexCoord(0, 1, 0, 1);
			texture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-"..texture;
			if ( not LFDDungeonReadyDialog.background:SetTexture(texture) ) then	--We haven't added this texture yet. Default to the Deadmines.
				LFDDungeonReadyDialog.background:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-Deadmines");	--DEBUG FIXME Default probably shouldn't be Deadmines
			end

			LFDDungeonReadyDialog.label:SetText(SPECIFIC_DUNGEON_IS_READY);
			LFDDungeonReadyDialog_UpdateInstanceInfo(name, completedEncounters, totalEncounters);
			LFDDungeonReadyDialog.instanceInfo:Show();
		end


		LFDDungeonReadyDialogRoleIconTexture:SetTexCoord(GetTexCoordsForRole(role));
		LFDDungeonReadyDialogRoleLabel:SetText(_G[role]);
		if ( isLeader ) then
			LFDDungeonReadyDialogRoleIconLeaderIcon:Show();
		else
			LFDDungeonReadyDialogRoleIconLeaderIcon:Hide();
		end

		LFDDungeonReadyDialog_UpdateRewards(id);
	end
end

function LFDDungeonReadyDialog_UpdateRewards(dungeonID)
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID);

	local numRandoms = 4 - GetNumPartyMembers();
	local moneyAmount = moneyBase + moneyVar * numRandoms;
	local experienceGained = experienceBase + experienceVar * numRandoms;

	local rewardsOffset = 0;

	if ( moneyAmount > 0 or experienceGained > 0 ) then --hasMiscReward ) then
		LFDDungeonReadyDialogReward_SetMisc(LFDDungeonReadyDialogRewardsFrameReward1);
		rewardsOffset = 1;
	end

	if ( moneyAmount == 0 and experienceGained == 0 and numRewards == 0 ) then
		LFDDungeonReadyDialogRewardsFrameLabel:Hide();
	else
		LFDDungeonReadyDialogRewardsFrameLabel:Show();
	end


	for i = 1, numRewards do
		local frameID = (i + rewardsOffset);
		local frame = _G["LFDDungeonReadyDialogRewardsFrameReward"..frameID];
		if ( not frame ) then
			frame = CreateFrame("FRAME", "LFDDungeonReadyDialogRewardsFrameReward"..frameID, LFDDungeonReadyDialogRewardsFrame, LFDDungeonReadyRewardTemplate);
			frame:SetID(frameID);
			LFD_MAX_REWARDS = frameID;
		end
		LFDDungeonReadyDialogReward_SetReward(frame, dungeonID, i)
	end

	local usedButtons = numRewards + rewardsOffset;
	--Hide the unused ones
	for i = usedButtons + 1, LFD_MAX_REWARDS do
		_G["LFDDungeonReadyDialogRewardsFrameReward"..i]:Hide();
	end

	if ( usedButtons > 0 ) then
		--Set up positions
		local positionPerIcon = 1/(2 * usedButtons) * LFDDungeonReadyDialogRewardsFrame:GetWidth();
		local iconOffset = 2 * positionPerIcon - LFDDungeonReadyDialogRewardsFrameReward1:GetWidth();
		LFDDungeonReadyDialogRewardsFrameReward1:SetPoint("CENTER", LFDDungeonReadyDialogRewardsFrame, "LEFT", positionPerIcon, 5);
		for i = 2, usedButtons do
			_G["LFDDungeonReadyDialogRewardsFrameReward"..i]:SetPoint("LEFT", "LFDDungeonReadyDialogRewardsFrameReward"..(i - 1), "RIGHT", iconOffset, 0);
		end
	end
end

function LFDDungeonReadyDialogReward_SetMisc(button)
	SetPortraitToTexture(button.texture, "Interface\\Icons\\inv_misc_coin_02");
	button.rewardID = 0;
	button:Show();
end

function LFDDungeonReadyDialogReward_SetReward(button, dungeonID, rewardIndex)
	local name, texturePath, quantity = GetLFGDungeonRewardInfo(dungeonID, rewardIndex);
	if ( texturePath and button and button.texture ) then	--Otherwise, we may be waiting on the item data to come from the server.
		SetPortraitToTexture(button.texture, texturePath);
	end
	button.rewardID = rewardIndex;
	button:Show();
end

function LFDDungeonReadyDialogReward_OnEnter(self, dungeonID)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.rewardID == 0 ) then
		GameTooltip:AddLine(REWARD_ITEMS_ONLY);
		local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(LFDDungeonReadyPopup.dungeonID);
		local numRandoms = 4 - GetNumPartyMembers();
		local moneyAmount = moneyBase + moneyVar * numRandoms;
		local experienceGained = experienceBase + experienceVar * numRandoms;

		if ( experienceGained > 0 ) then
			GameTooltip:AddLine(string.format(GAIN_EXPERIENCE, experienceGained));
		end
		if ( moneyAmount > 0 ) then
			SetTooltipMoney(GameTooltip, moneyAmount, nil);
		end
	else
		GameTooltip:SetLFGDungeonReward(LFDDungeonReadyPopup.dungeonID, self.rewardID);
	end
	GameTooltip:Show();
end

function LFDDungeonReadyDialog_UpdateInstanceInfo(name, completedEncounters, totalEncounters)
	local instanceInfoFrame = LFDDungeonReadyDialogInstanceInfoFrame;
	instanceInfoFrame.name:SetFontObject(GameFontNormalLarge);
	instanceInfoFrame.name:SetText(name);
	if ( instanceInfoFrame.name:GetWidth() + 20 > LFDDungeonReadyDialog:GetWidth() ) then
		instanceInfoFrame.name:SetFontObject(GameFontNormal);
	end

	instanceInfoFrame.statusText:SetFormattedText(BOSSES_KILLED, completedEncounters, totalEncounters);
end

function LFDDungeonReadyDialogInstanceInfo_OnEnter(self)
	local numBosses = select(8, GetLFGProposal());
	local isHoliday = select(12, GetLFGProposal());

	if ( numBosses == 0 or isHoliday) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip:AddLine(BOSSES)
	for i=1, numBosses do
		local bossName, texture, isKilled = GetLFGProposalEncounter(i);
		if ( isKilled ) then
			GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		else
			GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
		end
	end
	GameTooltip:Show();
end

function LFDDungeonReadyStatus_ResetReadyStates()
	for i=1, NUM_LFD_MEMBERS do
		local button = _G["LFDDungeonReadyStatusPlayer"..i];
		button.readyStatus = "unknown";
	end
end

function LFDDungeonReadyStatus_UpdateIcon(button)
	local isLeader, role, level, responded, accepted, name, class = GetLFGProposalMember(button:GetID());

	button.texture:SetTexCoord(GetTexCoordsForRole(role));

	if ( not responded ) then
		button.statusIcon:SetTexture(READY_CHECK_WAITING_TEXTURE);
	elseif ( accepted ) then
		if ( button.readyStatus ~= "accepted" ) then
			button.readyStatus = "accepted";
			PlaySound("LFG_RoleCheck");
		end
		button.statusIcon:SetTexture(READY_CHECK_READY_TEXTURE);
	else
		button.statusIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
	end

	button:Show();
end

function LFDQueueFrameTypeDropDown_SetUp(self)
	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, LFDQueueFrameTypeDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, LFDQueueFrame.type);
end

local function isRandomDungeonDisplayable(id)
	local name, typeID, minLevel, maxLevel, _, _, _, expansionLevel = GetLFGDungeonInfo(id);
	local myLevel = UnitLevel("player");
	return myLevel >= minLevel and myLevel <= maxLevel and EXPANSION_LEVEL >= expansionLevel;
end

function LFDQueueFrameTypeDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = SPECIFIC_DUNGEONS;
	info.value = "specific";
	info.func = LFDQueueFrameTypeDropDownButton_OnClick;
	info.checked = LFDQueueFrame.type == info.value;
	UIDropDownMenu_AddButton(info);

	for i=1, GetNumRandomDungeons() do
		local id, name, _, _, _, _, _, _, _, groupID = GetLFGRandomDungeonInfo(i);
		local isAvailable = IsLFGDungeonJoinable(id);
		if ( isRandomDungeonDisplayable(id) ) then
			if ( isAvailable ) then
				info.text = name;
				info.value = id;
				info.isTitle = nil;
				info.func = LFDQueueFrameTypeDropDownButton_OnClick;
				info.disabled = nil;
				info.checked = (LFDQueueFrame.type == info.value);

				info.tooltipWhileDisabled = nil
				local dungeonIDs = LFGGetDungeonListByHeaderID(groupID)
				if dungeonIDs then
					local names = {}
					for _, dungeonID in ipairs(dungeonIDs) do
						local dungeonInfo = LFGGetDungeonInfoByID(dungeonID)
						local color
						if LFGLockList[dungeonID] then
							color = "|cff808080"
						else
							local difficultyColor = GetQuestDifficultyColor(dungeonInfo[LFG_RETURN_VALUES.recLevel])
							color = string.format("|cff%.2x%.2x%.2x", difficultyColor.r*255, difficultyColor.g*255, difficultyColor.b*255)
						end
						table.insert(names, string.format("%s%s|r", color, dungeonInfo[LFG_RETURN_VALUES.name]))
					end

					if #names > 0 then
						info.tooltipOnButton = 1
						info.tooltipTitle = LFD_DUNGEON_RANDOM_TOOLTIP_HEADER
						info.tooltipText = table.concat(names, "\n")
					else
						info.tooltipOnButton = nil
						info.tooltipTitle = nil
						info.tooltipText = nil
					end
				else
					info.tooltipOnButton = nil
					info.tooltipTitle = nil
					info.tooltipText = nil
				end

				UIDropDownMenu_AddButton(info);
			else
				info.text = name;
				info.value = id;
				info.isTitle = nil;
				info.func = nil;
				info.disabled = 1;
				info.checked = nil;
				info.tooltipWhileDisabled = 1;
				info.tooltipOnButton = 1;
				info.tooltipTitle = YOU_MAY_NOT_QUEUE_FOR_THIS;
				info.tooltipText = LFDConstructDeclinedMessage(id);
				UIDropDownMenu_AddButton(info);
			end
		end
	end
end

function LFDQueueFrameTypeDropDownButton_OnClick(self)
	LFDQueueFrame_SetType(self.value);
end

function LFDQueueFrame_SetType(value)	--"specific" for the list or the record id for a single dungeon
	LFDQueueFrame.type = value;
	UIDropDownMenu_SetSelectedValue(LFDQueueFrameTypeDropDown, value);

	if ( value == "specific" ) then
		LFDQueueFrame_SetTypeSpecificDungeon();
	else
		LFDQueueFrame_SetTypeRandomDungeon();
		LFDQueueFrameRandom_UpdateFrame();
	end
end

function LFDQueueFrame_SetTypeRandomDungeon()
	LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER")
	LFDQueueFrameSpecific:Hide();
	LFDQueueFrameRandom:Show();
end

function LFDQueueFrame_SetTypeSpecificDungeon()
	LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-DUNGEONWALL");
	LFDQueueFrameRandom:Hide();
	LFDQueueFrameSpecific:Show();
end

function LFDConstructDeclinedMessage(dungeonID)
	local returnVal;
	for i=1, GetLFDLockPlayerCount() do
		local playerName, lockedReason = GetLFDLockInfo(dungeonID, i);
		if ( lockedReason ~= 0 ) then
			local who;
			if ( i == 1 ) then
				who = "SELF_";
			else
				who = "OTHER_";
			end
			if ( returnVal ) then
				returnVal = returnVal.."\n"..format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName);
			else
				returnVal = format(_G["INSTANCE_UNAVAILABLE_"..who..(LFG_INSTANCE_INVALID_CODES[lockedReason] or "OTHER")], playerName);
			end
		end
	end
	return returnVal;
end

--Random frame functions
NUM_LFD_RANDOM_REWARD_FRAMES = 1;
function LFDQueueFrameRandom_UpdateFrame()
	local parentName = "LFDQueueFrameRandomScrollFrameChildFrame"
	local parentFrame = _G[parentName];

	local dungeonID = LFDQueueFrame.type;

	if ( not dungeonID ) then	--We haven't gotten info on available dungeons yet.
		return;
	end

	local holiday;
	local difficulty;
	local dungeonDescription;
	local textureFilename;
	local dungeonName, _,_,_,_,_,_,_,_,textureFilename,difficulty,_,dungeonDescription, isHoliday = GetLFGDungeonInfo(dungeonID);
	local isHeroic = difficulty > 0;
	local doneToday, moneyBase, moneyVar, experienceBase, experienceVar, numRewards = GetLFGDungeonRewards(dungeonID);
	local numRandoms = 4 - GetNumPartyMembers();
	local moneyAmount = moneyBase + moneyVar * numRandoms;
	local experienceGained = experienceBase + experienceVar * numRandoms;


	local backgroundTexture;
	if ( isHeroic ) then
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-HEROIC";
	elseif ( isHoliday ) then
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-HOLIDAY-BACKGROUND-"..textureFilename;
	else
		backgroundTexture = "Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER";
	end

	if ( not LFDQueueFrameBackground:SetTexture(backgroundTexture) ) then
		LFDQueueFrameBackground:SetTexture("Interface\\LFGFrame\\UI-LFG-BACKGROUND-QUESTPAPER");
	end

	local lastFrame = parentFrame.rewardsLabel;
	if ( isHoliday ) then
		if ( doneToday ) then
			parentFrame.rewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION2);
		else
			parentFrame.rewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION1);
		end
		parentFrame.title:SetText(dungeonName);
		parentFrame.description:SetText(dungeonDescription);
	else
		if ( doneToday ) then
			parentFrame.rewardsDescription:SetText(LFD_RANDOM_REWARD_EXPLANATION2);
		else
			parentFrame.rewardsDescription:SetText(LFD_RANDOM_REWARD_EXPLANATION1);
		end
		parentFrame.title:SetText(LFG_TYPE_RANDOM_DUNGEON);
		parentFrame.description:SetText(LFD_RANDOM_EXPLANATION);
	end

	for i=1, numRewards do
		local frame = _G[parentName.."Item"..i];
		if ( not frame ) then
			frame = CreateFrame("Button", parentName.."Item"..i, _G[parentName], "LFDRandomDungeonLootTemplate");
			frame:SetID(i);
			NUM_LFD_RANDOM_REWARD_FRAMES = i;
			if ( mod(i, 2) == 0 ) then
				frame:SetPoint("LEFT", parentName.."Item"..(i-1), "RIGHT", 0, 0);
			else
				frame:SetPoint("TOPLEFT", parentName.."Item"..(i-2), "BOTTOMLEFT", 0, -5);
			end
		end

		local name, texture, numItems = GetLFGDungeonRewardInfo(dungeonID, i);

		_G[parentName.."Item"..i.."Name"]:SetText(name);
		SetItemButtonTexture(frame, texture);
		SetItemButtonCount(frame, numItems);
		frame:Show();
		lastFrame = frame;
	end
	for i=numRewards+1, NUM_LFD_RANDOM_REWARD_FRAMES do
		_G[parentName.."Item"..i]:Hide();
	end

	if ( numRewards > 0 or ((moneyVar == 0 and experienceVar == 0) and (moneyAmount > 0 or experienceGained > 0)) ) then
		parentFrame.rewardsLabel:Show();
		parentFrame.rewardsDescription:Show();
		lastFrame = parentFrame.rewardsDescription;
	else
		parentFrame.rewardsLabel:Hide();
		parentFrame.rewardsDescription:Hide();
	end

	if ( numRewards > 0 ) then
		lastFrame = _G[parentName.."Item"..(numRewards - mod(numRewards+1, 2))];
	end

	if ( moneyVar > 0 or experienceVar > 0 ) then
		parentFrame.pugDescription:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);
		parentFrame.pugDescription:Show();
		lastFrame = parentFrame.pugDescription;
	else
		parentFrame.pugDescription:Hide();
	end

	if ( moneyAmount > 0 ) then
		MoneyFrame_Update(parentFrame.moneyFrame, moneyAmount);
		parentFrame.moneyLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 20, -10);
		parentFrame.moneyLabel:Show();
		parentFrame.moneyFrame:Show()

		parentFrame.xpLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);

		lastFrame = parentFrame.moneyLabel;
	else
		parentFrame.moneyLabel:Hide();
		parentFrame.moneyFrame:Hide();

	end

	if ( experienceGained > 0 ) then
		parentFrame.xpAmount:SetText(experienceGained);

		if ( lastFrame == parentFrame.moneyLabel ) then
			parentFrame.xpLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -5);
		else
			parentFrame.xpLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 20, -10);
		end
		parentFrame.xpLabel:Show();
		parentFrame.xpAmount:Show();

		lastFrame = parentFrame.xpLabel;
	else
		parentFrame.xpLabel:Hide();
		parentFrame.xpAmount:Hide();
	end

	parentFrame.spacer:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10);
end

function LFDQueueFrameRandomCooldownFrame_OnLoad(self)
	self:SetFrameLevel(11);	--This value also needs to be set when SetParent is called in LFDQueueFrameRandomCooldownFrame_Update.

	self:RegisterEvent("PLAYER_ENTERING_WORLD");	--For logging in/reloading ui
	self:RegisterEvent("UNIT_AURA");	--The cooldown is still technically a debuff
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
end

function LFDQueueFrameRandomCooldownFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event ~= "UNIT_AURA" or arg1 == "player" or (arg1 and strsub(arg1, 1, 5) == "party") ) then
		LFDQueueFrameRandomCooldownFrame_Update();
	end
end

function LFDQueueFrameRandomCooldownFrame_Update()
	local cooldownFrame = LFDQueueFrameCooldownFrame;
	local shouldShow = false;
	local hasDeserter = false; --If we have deserter, we want to show this over the specific frame as well as the random frame.

	local deserterExpiration = GetLFGDeserterExpiration();

	local myExpireTime;
	if ( deserterExpiration ) then
		myExpireTime = deserterExpiration;
		hasDeserter = true;
	else
		myExpireTime = GetLFGRandomCooldownExpiration();
	end

	cooldownFrame.myExpirationTime = myExpireTime;

	for i = 1, GetNumPartyMembers() do
		local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i];
		local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i];
		nameLabel:Show();
		statusLabel:Show();

		local _, classFilename = UnitClass("party"..i);
		local classColor = classFilename and RAID_CLASS_COLORS[classFilename] or NORMAL_FONT_COLOR;
		nameLabel:SetFormattedText("|cff%.2x%.2x%.2x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, UnitName("party"..i));

		if ( UnitHasLFGDeserter("party"..i) ) then
			statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", DESERTER);
			shouldShow = true;
			hasDeserter = true;
		elseif ( UnitHasLFGRandomCooldown("party"..i) ) then
			statusLabel:SetFormattedText(RED_FONT_COLOR_CODE.."%s|r", ON_COOLDOWN);
			shouldShow = true;
		else
			statusLabel:SetFormattedText(GREEN_FONT_COLOR_CODE.."%s|r", READY);
		end
	end
	for i = GetNumPartyMembers() + 1, MAX_PARTY_MEMBERS do
		local nameLabel = _G["LFDQueueFrameCooldownFrameName"..i];
		local statusLabel = _G["LFDQueueFrameCooldownFrameStatus"..i];
		nameLabel:Hide();
		statusLabel:Hide();
	end

	if ( GetNumPartyMembers() == 0 ) then
		cooldownFrame.description:SetPoint("TOP", 0, -85);
	else
		cooldownFrame.description:SetPoint("TOP", 0, -30);
	end

	if ( hasDeserter ) then
		cooldownFrame:SetParent(LFDQueueFrame);
		cooldownFrame:SetFrameLevel(11);	--Setting a new parent changes the frame level, so we need to move it back to what we set in OnLoad.
	else
		cooldownFrame:SetParent(LFDQueueFrameRandom);	--If nobody has deserter, the dungeon cooldown only prevents us from queueing for random.
		cooldownFrame:SetFrameLevel(11);
	end

	if ( myExpireTime and GetTime() < myExpireTime ) then
		shouldShow = true;
		if ( deserterExpiration ) then
			cooldownFrame.description:SetText(LFG_DESERTER_YOU);
		else
			cooldownFrame.description:SetText(LFG_RANDOM_COOLDOWN_YOU);
		end
		cooldownFrame.time:SetText(SecondsToTime(ceil(myExpireTime - GetTime())));
		cooldownFrame.time:Show();

		cooldownFrame:SetScript("OnUpdate", LFDQueueFrameRandomCooldownFrame_OnUpdate);
	else
		if ( hasDeserter ) then
			cooldownFrame.description:SetText(LFG_DESERTER_OTHER);
		else
			cooldownFrame.description:SetText(LFG_RANDOM_COOLDOWN_OTHER);
		end
		cooldownFrame.time:Hide();

		cooldownFrame:SetScript("OnUpdate", nil);
	end

	if ( shouldShow ) then
		cooldownFrame:Show();
	else
		cooldownFrame:Hide();
	end
end

function LFDQueueFrameRandomCooldownFrame_OnUpdate(self, elapsed)
	local timeRemaining = self.myExpirationTime - GetTime();
	if ( timeRemaining > 0 ) then
		self.time:SetText(SecondsToTime(ceil(timeRemaining)));
	else
		LFDQueueFrameRandomCooldownFrame_Update();
	end
end

--Queued status functions

local NUM_TANKS = 1;
local NUM_HEALERS = 1;
local NUM_DAMAGERS = 3;

function LFDSearchStatus_OnEvent(self, event, ...)
	if ( event == "LFG_QUEUE_STATUS_UPDATE" ) then
		LFDSearchStatus_Update();
	end
end

function LFDSearchStatusPlayer_SetFound(button, isFound)
	if ( isFound ) then
		SetDesaturation(button.texture, false);
		button.cover:Hide();
	else
		SetDesaturation(button.texture, true);
		button.cover:Show();
	end
end

function LFDSearchStatus_UpdateRoles()
	local leader, tank, healer, damage = GetLFGRoles();
	local currentIcon = 1;
	if ( tank ) then
		local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
		icon:SetTexCoord(GetTexCoordsForRole("TANK"));
		icon:Show();
		currentIcon = currentIcon + 1;
	end
	if ( healer ) then
		local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
		icon:SetTexCoord(GetTexCoordsForRole("HEALER"));
		icon:Show();
		currentIcon = currentIcon + 1;
	end
	if ( damage ) then
		local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
		icon:SetTexCoord(GetTexCoordsForRole("DAMAGER"));
		icon:Show();
		currentIcon = currentIcon + 1;
	end
	for i=currentIcon, LFD_NUM_ROLES do
		_G["LFDSearchStatusRoleIcon"..i]:Hide();
	end
	local extraWidth = 27*(currentIcon-1);
	LFDSearchStatusLookingFor:SetPoint("BOTTOM", -extraWidth/2, 14);
end

local embeddedTankIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:20:20:0:5:64:64:0:19:22:41|t";
local embeddedHealerIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:20:20:0:5:64:64:20:39:1:20|t";
local embeddedDamageIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:20:20:0:5:64:64:20:39:22:41|t";

function LFDSearchStatus_Update()
	local LFDSearchStatus = LFDSearchStatus;
	local hasData,  leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats();

	LFDSearchStatus_UpdateRoles();

	if ( not hasData ) then
		LFDSearchStatus:SetHeight(145);
		LFDSearchStatusPlayer_SetFound(LFDSearchStatusTank1, false)
		LFDSearchStatusPlayer_SetFound(LFDSearchStatusHealer1, false);
		for i=1, NUM_DAMAGERS do
			LFDSearchStatusPlayer_SetFound(_G["LFDSearchStatusDamage"..i], false);
		end
		LFDSearchStatus.statistic:Hide();
		LFDSearchStatus.elapsedWait:SetFormattedText(TIME_IN_QUEUE, LESS_THAN_ONE_MINUTE);

		LFDSearchStatus:SetScript("OnUpdate", nil);
		return;
	end

--	if ( instancetype == TYPEID_HEROIC_DIFFICULTY ) then
--		instanceName = format(HEROIC_PREFIX, instanceName);
--	end

	--This won't work if we decide the makeup is, say, 3 healers, 1 damage, 1 tank.
	LFDSearchStatusPlayer_SetFound(LFDSearchStatusTank1, (tankNeeds == 0))
	LFDSearchStatusPlayer_SetFound(LFDSearchStatusHealer1, (healerNeeds == 0));
	for i=1, NUM_DAMAGERS do
		LFDSearchStatusPlayer_SetFound(_G["LFDSearchStatusDamage"..i], i <= (NUM_DAMAGERS - dpsNeeds));
	end

	LFDSearchStatus.queuedTime = queuedTime;
	local elapsedTime = GetTime() - queuedTime;
	LFDSearchStatus.elapsedWait:SetFormattedText(TIME_IN_QUEUE, (elapsedTime >= 60) and SecondsToTime(elapsedTime) or LESS_THAN_ONE_MINUTE);
	LFDSearchStatus.elapsedWait:Show();

	if ( myWait == -1 ) then
		LFDSearchStatus.statistic:Hide();
		LFDSearchStatus:SetHeight(145);
	else
		LFDSearchStatus.statistic:Show();
		LFDSearchStatus:SetHeight(170);
		LFDSearchStatus.statistic:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT, myWait == -1 and TIME_UNKNOWN or SecondsToTime(myWait, false, false, 1));
	end
	LFDSearchStatus:SetScript("OnUpdate", LFDSearchStatus_OnUpdate);
end

function LFDSearchStatus_OnUpdate(self, elapsed)
	local elapsedTime = GetTime() - self.queuedTime;
	self.elapsedWait:SetFormattedText(TIME_IN_QUEUE, (elapsedTime >= 60) and SecondsToTime(elapsedTime) or LESS_THAN_ONE_MINUTE);
end

function LFDQueueFrameFindGroupButton_Update()
	local mode, subMode = GetLFGMode();
	if ( mode == "queued" or mode == "rolecheck" or mode == "proposal") then
		LFDQueueFrameFindGroupButton:SetText(LEAVE_QUEUE);
	else
		if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
			LFDQueueFrameFindGroupButton:SetText(JOIN_AS_PARTY);
		else
			LFDQueueFrameFindGroupButton:SetText(FIND_A_GROUP);
		end
	end

	if C_Unit.IsNeutral("player") then
		LFDQueueFrameFindGroupButton:Disable();
	elseif ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "listed"  ) then --During the proposal, they must use the proposal buttons to leave the queue.
		if ( mode == "queued" or mode =="proposal" or mode == "rolecheck" or not LFDQueueFramePartyBackfill:IsVisible() ) then
			LFDQueueFrameFindGroupButton:Enable();
		else
			LFDQueueFrameFindGroupButton:Disable();
		end
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Enable();
	else
		LFDQueueFrameFindGroupButton:Disable();
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton:Disable();
	end

	if ( LFD_IsEmpowered() and mode ~= "proposal" and mode ~= "queued" ) then
		LFDQueueFramePartyBackfillBackfillButton:Enable();
	else
		LFDQueueFramePartyBackfillBackfillButton:Disable();
	end
end

LFDHiddenByCollapseList = {};
function LFDQueueFrame_Update()
	local enableList;

	local mode, submode = GetLFGMode();

	if ( LFD_IsEmpowered() and mode ~= "queued") then
		enableList = LFGEnabledList;
	else
		enableList = LFGQueuedForList;
	end

	LFDDungeonList = GetLFDChoiceOrder(LFDDungeonList);

	LFGQueueFrame_UpdateLFGDungeonList(LFDDungeonList, LFDHiddenByCollapseList, LFGLockList, LFGDungeonInfo, enableList, LFGCollapseList, LFD_CURRENT_FILTER);

	LFDQueueFrameSpecificList_Update();
end

function LFDList_DefaultFilterFunction(dungeonID)
	local info = LFGGetDungeonInfoByID(dungeonID)
	local hasHeader = info[LFG_RETURN_VALUES.groupID] ~= 0;
	local sufficientExpansion = EXPANSION_LEVEL >= info[LFG_RETURN_VALUES.expansionLevel];
	local level = UnitLevel("player");
	local sufficientLevel = level >= info[LFG_RETURN_VALUES.minLevel] and level <= info[LFG_RETURN_VALUES.maxLevel];
	return (hasHeader and sufficientExpansion and sufficientLevel) and
		( level - LFD_MAX_SHOWN_LEVEL_DIFF <= info[LFG_RETURN_VALUES.recLevel] or (LFGLockList and not LFGLockList[dungeonID]));	--If the server tells us we can join, who are we to complain?
end

LFD_CURRENT_FILTER = LFDList_DefaultFilterFunction

function MiniGameReadyDialogReward_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if self.money and self.money > 0 then
		GameTooltip:AddLine(REWARD_ITEMS_ONLY);

		SetTooltipMoney(GameTooltip, self.money, nil);
	elseif self.itemLink then
		GameTooltip:SetHyperlink(self.itemLink);
	elseif self.currency and self.currency > 0 then
		local name, description, link, texture, iconAtlas = C_StorePublic.GetCurrencyInfo(Enum.Store.CurrencyType.BattlePassExp)
		local markup
		if texture then
			markup = CreateTextureMarkup(texture, 64, 64, 16, 16, 0, 0, 0, 0)
		elseif iconAtlas then
			markup = CreateAtlasMarkup(iconAtlas, 16, 16)
		end
		if markup then
			GameTooltip:AddLine(REWARD_ITEMS_ONLY);
			GameTooltip:AddLine(string.format("%d %s", self.currency, markup), 1, 1, 1);
		end
	end
	GameTooltip:Show();
end

MiniGamesFrameMixin = {}

function MiniGamesFrameMixin:OnLoad()
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterCustomEvent("UPDATE_MINI_GAMES_STATUS");
	self:RegisterCustomEvent("UPDATE_MINI_GAME");
	self:RegisterCustomEvent("MINI_GAME_INVITE");
	self:RegisterCustomEvent("MINI_GAME_INVITE_STATUS");
	self:RegisterCustomEvent("MINI_GAME_INVITE_ACCEPT");
	self:RegisterCustomEvent("MINI_GAME_INVITE_ABADDON");

	self.gameButtonPool = CreateFramePool("Button", self.TopInset.ScrollFrame, "MiniGameButtonTemplate");
	self.items = {};
	self.lootPool = CreateFramePool("Button", self.BottomInset.ScrollFrame.ChildFrame, "MiniGameLootTemplate");

	self:UpdateGames();
	self:UpdateFindGroupButton();

	self.helpPlate = {
		FramePos = { x = -224, y = -24 },
		FrameSize = { width = 595, height = 402 },
		[1] = { ButtonPos = { x = 192, y = -116 }, HighLightBox = { x = 4, y = -96, width = 212, height = 84 }, ToolTipDir = "DOWN", ToolTipText = HEPLPLATE_MINIGAMESFRAME_TUTORIAL_1 },
		[2] = { ButtonPos = { x = 192, y = -206 }, HighLightBox = { x = 4, y = -186, width = 212, height = 84 }, ToolTipDir = "DOWN", ToolTipText = HEPLPLATE_MINIGAMESFRAME_TUTORIAL_2 },
		[3] = { ButtonPos = { x = 368, y = -30 }, HighLightBox = { x = 232, y = -4, width = 320, height = 102 }, ToolTipDir = "UP", ToolTipText = HEPLPLATE_MINIGAMESFRAME_TUTORIAL_3 },
	}
end

function MiniGamesFrameMixin:OnShow()
	self:UpdateGames();

	local numGames = C_MiniGames.GetNumGames();
	if numGames > 0 then
		self:SetSelectedGame(self.selectedGameID or C_MiniGames.GetGameIDFromIndex(1));
	end
end

function MiniGamesFrameMixin:OnEvent(event, ...)
	if event == "PARTY_MEMBERS_CHANGED" or event == "UPDATE_MINI_GAMES_STATUS" then
		self:UpdateFindGroupButton();
	elseif event == "UPDATE_MINI_GAME" then
		local miniGameID = ...;

		if self:IsShown() then
			self:UpdateGames();

			if self.selectedGameID == miniGameID then
				self:SetSelectedGame(miniGameID);
			end
		end

		if MiniGameReadyDialog:IsShown() and MiniGameReadyDialog.miniGameID == miniGameID then
			MiniGameReadyPopup:UpdateInstance(miniGameID);
			MiniGameReadyPopup:UpdateRewards(miniGameID);
		end
	elseif event == "MINI_GAME_INVITE" then
		local miniGameID, inviteID, remainingTime = ...;

		if miniGameID and inviteID then
			MiniGameReadyPopup:ShowReadyDialog(inviteID, miniGameID);
		end
	elseif event == "MINI_GAME_INVITE_STATUS" then
		local isPlayerReady, acceptedPlayers, maxPlayers = ...;

		if isPlayerReady and acceptedPlayers and maxPlayers then
			MiniGameReadyPopup:ShowReadyStatus(acceptedPlayers, maxPlayers);
		end
	elseif event == "MINI_GAME_INVITE_ACCEPT" or event == "MINI_GAME_INVITE_ABADDON" then
		StaticPopupSpecial_Hide(MiniGameReadyPopup);
	end
end

function MiniGamesFrameMixin:JoinMiniGame()
	if self.selectedGameID then
		if self.FindGroupButton.queueIndex then
			C_MiniGames.QueueLeave(self.FindGroupButton.queueIndex);
		else
			local isGroup = (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0) and (IsPartyLeader() or IsRaidLeader());
			C_MiniGames.QueueJoin(self.selectedGameID, isGroup);
		end
	end
end

function MiniGamesFrameMixin:UpdateFindGroupButton()
	local foundQueue;

	for i = 1, C_MiniGames.GetMaxQueues() do
		local status, _, miniGameID = C_MiniGames.GetQueueInfo(i);

		if status == "queued" and self.selectedGameID and miniGameID == self.selectedGameID then
			self.FindGroupButton:SetText(LEAVE_QUEUE);
			self.FindGroupButton.queueIndex = i;
			foundQueue = true;
			break;
		end
	end

	if not foundQueue then
		self.FindGroupButton.queueIndex = nil;

		if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
			if IsPartyLeader() or IsRaidLeader() then
				self.FindGroupButton:SetText(JOIN_AS_PARTY);
			else
				self.FindGroupButton:SetText(FIND_A_MINI_GAME);
			end
		else
			self.FindGroupButton:SetText(FIND_A_MINI_GAME);
		end
	end
end

function MiniGamesFrameMixin:SetMinMaxValues(minValue, maxValue)
	self.minValue = minValue;
	self.maxValue = maxValue;
end

function MiniGamesFrameMixin:GetMinMaxValues()
	return self.minValue or 0, self.maxValue or 0;
end

function MiniGamesFrameMixin:SetValue(value)
	self.value = Clamp(value, self.minValue, self.maxValue);
--	self.TopInset.ScrollFrame:SetHorizontalScroll(self.value);
end

function MiniGamesFrameMixin:GetValue()
	return self.value or 0;
end

function MiniGamesFrameMixin:SetSelectedGame(miniGameID)
	for button in self.gameButtonPool:EnumerateActive() do
		button.Selected:SetShown(button:GetID() == miniGameID)
	end

	if not C_MiniGames.IsValidGameID(miniGameID) then
		return
	end

	self.selectedGameID = miniGameID;

	local name, description, icon, background, objective, minPlayers, maxPlayers, gameName, mapAreaID = C_MiniGames.GetGameInfo(miniGameID);
	if not name then
		return;
	end

	self.BottomInset.Background:SetTexture(background);

	local scrollFrame = self.BottomInset.ScrollFrame;
	local scrollChild = scrollFrame.ChildFrame;
	scrollChild.Title:SetText(name);
	scrollChild.Description:SetText(description);

	if minPlayers and maxPlayers then
		scrollChild.NumPlayers:SetFormattedText(LFD_NUM_PLAYERS_FORMAT_RANGE, minPlayers, maxPlayers)
		scrollChild.NumPlayers:Show()
	else
		scrollChild.NumPlayers:Hide()
	end

	table.wipe(self.items);

	self.lootPool:ReleaseAll();

	local doneToday, money, rewards = C_MiniGames.GetGameRewards(miniGameID);
	local pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1, pointsMiniGame = C_BattlePass.GetSourceExperience()
	local numRewards = rewards and #rewards or 0;

	local lastFrame = scrollChild.Description;

	scrollChild.RewardsLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10);

	if doneToday then
		scrollChild.RewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION2);
	else
		if gameName == "FROZEN_SNOWMAN_LAIR_SURVIVAL" then
			scrollChild.RewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION_SURVIVAL);
		elseif gameName == "FROZEN_SNOWMAN_LAIR_SURVIVAL_HARD" then
			scrollChild.RewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION_HARDCORE);
		else
			scrollChild.RewardsDescription:SetText(LFD_HOLIDAY_REWARD_EXPLANATION1);
		end
	end

	lastFrame = scrollChild.RewardsLabel;

	if numRewards > 0 then
		for index, rewardInfo in ipairs(rewards) do
			local itemID = rewardInfo.itemID;

			local frame = self.lootPool:Acquire();

			if index == 1 then
				frame:SetPoint("TOPLEFT", scrollChild.RewardsDescription, "BOTTOMLEFT", 0, -10);
			elseif mod(index, 2) == 0 then
				frame:SetPoint("LEFT", self.items[index - 1], "RIGHT", 0, 0);
			else
				frame:SetPoint("TOPLEFT", self.items[index - 2], "BOTTOMLEFT", 0, -5);
			end

			local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemID);

			frame.Name:SetText(itemName);
			SetItemButtonTexture(frame, itemIcon);
			SetItemButtonCount(frame, rewardInfo.itemCount);

			frame.itemID = itemID;
			frame.itemLink = itemLink;
			frame:Show();

			self.items[index] = frame;
		end
	end

	if numRewards > 0 or money > 0 or pointsMiniGame > 0 then
		scrollChild.RewardsLabel:Show();
		scrollChild.RewardsDescription:Show();
		lastFrame = scrollChild.RewardsDescription;
	else
		scrollChild.RewardsLabel:Hide();
		scrollChild.RewardsDescription:Hide();
	end

	if numRewards > 0 then
		lastFrame = self.items[numRewards - mod(numRewards + 1, 2)];
	end

	if money > 0 then
		MoneyFrame_Update(scrollChild.MoneyFrame, money);
		scrollChild.MoneyLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 20, -10);
		scrollChild.MoneyLabel:Show();
		scrollChild.MoneyFrame:Show();
		lastFrame = scrollChild.MoneyLabel;
	else
		scrollChild.MoneyLabel:Hide();
		scrollChild.MoneyFrame:Hide();
	end

	if pointsMiniGame > 0 then
		local hasMoneyReward = money > 0
		scrollChild.CurrencyLabel:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", hasMoneyReward and 0 or 20, hasMoneyReward and -5 or -10)
		scrollChild.CurrencyLabel:Show()
		scrollChild.CurrencyFrame:SetValue(pointsMiniGame, Enum.Store.CurrencyType.BattlePassExp)
		scrollChild.CurrencyFrame:Show()
		lastFrame = scrollChild.CurrencyFrame
	else
		scrollChild.CurrencyLabel:Hide()
		scrollChild.CurrencyFrame:Hide()
	end

	scrollChild.Spacer:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10);

	self:UpdateFindGroupButton();
end

function MiniGamesFrameMixin:UpdateGames()
	local numGames = C_MiniGames.GetNumGames();

	self.gameButtonPool:ReleaseAll();

	local lastGameButton;
	local width = 0
	for i = 1, numGames do
		local gameButton = self.gameButtonPool:Acquire();

		if i == 1 then
			gameButton:SetPoint("LEFT", self.TopInset.ScrollFrame.ButtonHolder, 4, 0);
		--	gameButton:SetPoint("CENTER", self.TopInset.ScrollFrame.ButtonHolder, -((numGames - 1) * (72 + 8) * 0.5), 0);
			width = width + 4
		else
			gameButton:SetPoint("LEFT", lastGameButton, "RIGHT", 8, 0);
			width = width + 8
		end
		width = width + gameButton:GetWidth()

		local miniGameID = C_MiniGames.GetGameIDFromIndex(i);
		local name, _, icon = C_MiniGames.GetGameInfo(miniGameID);
		SetPortraitToTexture(gameButton.Icon, icon);

		gameButton.name = name;
		gameButton:SetID(miniGameID);
		gameButton:Show();

		lastGameButton = gameButton;
	end

	self.TopInset.ScrollFrame.ButtonHolder:SetWidth(width)

	local maxValue = (numGames - 4) * (72 + 8);
	if numGames < 4 then
		local value = maxValue * 0.5;
		self:SetMinMaxValues(value, value);
		self:SetValue(value);
	else
		self:SetMinMaxValues(0, maxValue);
		self:SetValue(0);
	end
end

LFDReadyPopupMixin = {}

function LFDReadyPopupMixin:OnEvent(event, ...)
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
		self.EnterButton:SetEnabled(event == "PLAYER_REGEN_ENABLED")
	end
end

function LFDReadyPopupMixin:OnShow()
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self.EnterButton:SetEnabled(not InCombatLockdown())
end

function LFDReadyPopupMixin:OnHide()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	self:UnregisterEvent("PLAYER_REGEN_DISABLED");
end

MiniGameReadyPopupMixin = {}

function MiniGameReadyPopupMixin:OnShow()
	PlaySound("ReadyCheck");
	FlashClientIcon();
end

function MiniGameReadyPopupMixin:OnHide()
	self.inviteID = nil;
	self.miniGameID = nil;
end

function MiniGameReadyPopupMixin:UpdateInstance(miniGameID)
	local name, _, icon, _, objective = C_MiniGames.GetGameInfo(miniGameID);
	MiniGameReadyDialog.GoalLabel:SetText(objective);

	MiniGameReadyDialog.InstanceInfo.Name:SetText(name);

	SetPortraitToTexture(MiniGameReadyDialog.InstanceIcon.Texture, icon);
end

function MiniGameReadyPopupMixin:UpdateRewards(miniGameID)
	MiniGameReadyDialog.RewardsFrame.rewardPool:ReleaseAll();

	local doneToday, money, rewards = C_MiniGames.GetGameRewards(miniGameID);
	local pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1, pointsMiniGame = C_BattlePass.GetSourceExperience()

	local lastFrame;
	local hasMoney = money > 0 and 1 or 0;
	local hasPoints = pointsMiniGame > 0 and 1 or 0

	local positionPerIcon = 1 / (2 * (#rewards + hasMoney + hasPoints)) * 72;
	local iconOffset = 2 * positionPerIcon - 36;

	if hasMoney > 0 then
		local frame = MiniGameReadyDialog.RewardsFrame.rewardPool:Acquire();
		frame:SetPoint("CENTER", MiniGameReadyDialog.RewardsFrame, "LEFT", positionPerIcon, 5);

		SetPortraitToTexture(frame.Texture, "Interface\\Icons\\inv_misc_coin_02");

		frame.itemID = nil;
		frame.itemLink = nil;
		frame.money = money;
		frame:Show();

		lastFrame = frame;
	end

	MiniGameReadyDialog.RewardsFrame.Label:SetShown(money > 0 or #rewards > 0);

	for index, rewardInfo in ipairs(rewards) do
		local itemID = rewardInfo.itemID;

		local frame = MiniGameReadyDialog.RewardsFrame.rewardPool:Acquire();
		frame:SetPoint("LEFT", lastFrame, "RIGHT", iconOffset, 0);

		local _, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemID);
		SetPortraitToTexture(frame.Texture, itemIcon);

		frame.itemID = itemID;
		frame.itemLink = itemLink;
		frame.money = nil;
		frame:Show();

		lastFrame = frame;
	end

	if pointsMiniGame > 0 then
		local frame = MiniGameReadyDialog.RewardsFrame.rewardPool:Acquire();
		frame:SetPoint("LEFT", lastFrame, "RIGHT", iconOffset, 0)

		local name, description, link, texture, iconAtlas = C_StorePublic.GetCurrencyInfo(Enum.Store.CurrencyType.BattlePassExp)
		if texture then
			SetPortraitToTexture(frame.Texture, texture)
		else
			frame.Texture:SetAtlas(iconAtlas)
		end

		frame.itemID = nil
		frame.itemLink = nil
		frame.currency = pointsMiniGame
		frame:Show()

		lastFrame = frame
	end
end

function MiniGameReadyPopupMixin:ShowReadyDialog(inviteID, miniGameID)
	StaticPopupSpecial_Show(self);
	MiniGameReadyStatus:Hide();
	MiniGameReadyDialog:Show();
	MiniGameReadyDialog.inviteID = inviteID;
	MiniGameReadyDialog.miniGameID = miniGameID;
	self:UpdateInstance(miniGameID);
	self:UpdateRewards(miniGameID);
end

function MiniGameReadyPopupMixin:ShowReadyStatus(acceptedPlayers, maxPlayers)
	StaticPopupSpecial_Show(self);
	MiniGameReadyDialog:Hide();
	MiniGameReadyStatus:Show();
	MiniGameReadyStatus.Roleless.Ready.Count:SetFormattedText("%d / %d", acceptedPlayers, maxPlayers);
end

MiniGamesBannerMixin = {};

function MiniGamesBannerMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterCustomEvent("MINI_GAME_LOST");
	self:RegisterCustomEvent("MINI_GAME_WON");
end

function MiniGamesBannerMixin:OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:RegisterEvent("WORLD_MAP_UPDATE");
	elseif event == "WORLD_MAP_UPDATE" then
		self:UnregisterEvent(event);

		if not self:IsShown() then
			return;
		end

		local miniGameID = C_MiniGames.GetActiveID();
		if miniGameID then
			local currentMapAreaID = GetCurrentMapAreaID();
			local _, _, _, _, _, _, _, _, mapAreaID = C_MiniGames.GetGameInfo(miniGameID);
			if currentMapAreaID == mapAreaID then
				return;
			end
		end

		self:StopBanner();
	elseif event == "MINI_GAME_LOST" then
		self:PlayBanner({title = LOSS, isRedBanner = true});
	elseif event == "MINI_GAME_WON" then
		self:PlayBanner({title = WIN, isRedBanner = false});
	end
end

function MiniGamesBannerMixin:PlayBanner(data)
	self:StopBanner();

	self.Title:SetText(data.title);
	local isRedBanner = data.isRedBanner;
	if isRedBanner then
		self.Title:SetTextColor(1, 0, 0, 1);
	else
		self.Title:SetTextColor(207 / 255, 168 / 255, 22 / 255, 1);
	end

	local bannerAtlas = isRedBanner and "BossBannerRed" or "BossBannerYellow";
	self.BannerTop:SetAtlas(strconcat(bannerAtlas, "-BgBanner-Top"), true);
	self.BannerTopGlow:SetAtlas(strconcat(bannerAtlas, "-BgBanner-Top"), true);
	self.BannerBottom:SetAtlas(strconcat(bannerAtlas, "-BgBanner-Bottom"), true);
	self.BannerBottomGlow:SetAtlas(strconcat(bannerAtlas, "-BgBanner-Bottom"), true);
	self.BannerMiddle:SetAtlas(strconcat(bannerAtlas, "-BgBanner-Mid"), true);
	self.BannerMiddleGlow:SetAtlas(strconcat(bannerAtlas, "-BgBanner-Mid"), true);
	self.SkullCircle:SetAtlas(strconcat(bannerAtlas, "-SkullCircle"), true);
	self.BottomFillagree:SetAtlas(strconcat(bannerAtlas, "-BottomFillagree"), true);
	self.SkullSpikes:SetAtlas(strconcat(bannerAtlas, "-SkullSpikes"), true);
	self.RightFillagree:SetAtlas(strconcat(bannerAtlas, "-RightFillagree"), true);
	self.LeftFillagree:SetAtlas(strconcat(bannerAtlas, "-LeftFillagree"), true);
	self.Overlay.FlashBurst:SetAtlas(strconcat(bannerAtlas, "-RedLightning"), true);
	self.Overlay.FlashBurstLeft:SetAtlas(strconcat(bannerAtlas, "-RedLightning"), true);
	self.Overlay.FlashBurstCenter:SetAtlas(strconcat(bannerAtlas, "-RedLightning"), true);
	self.Overlay.RedFlash:SetAtlas(strconcat(bannerAtlas, "-RedFlash"), true);

	local scale = self:GetEffectiveScale();
	local fillagreeScale = 0.5;
	self.RightFillagree:SetPoint("CENTER", self.SkullCircle, "CENTER", 10, 6);
	self.RightFillagree.AnimIn.Translation:SetOffset(37 * scale * fillagreeScale, 0);
	self.LeftFillagree:SetPoint("CENTER", self.SkullCircle, "CENTER", -10, 6);
	self.LeftFillagree.AnimIn.Translation:SetOffset(-(37 * scale * fillagreeScale), 0);
	self.Overlay.FlashBurst.AnimIn.Translation:SetOffset(10 * scale, 0);
	self.Overlay.FlashBurstLeft.AnimIn.Translation:SetOffset(-(10 * scale), 0);
	self.SkullCircle.AnimIn:Play();
	self.BannerTop.AnimIn:Play();
	self.BannerBottom.AnimIn:Play();
	self.BannerMiddle.AnimIn:Play();
	self.BottomFillagree.AnimIn:Play();
	self.SkullSpikes.AnimIn:Play();
	self.RightFillagree.AnimIn:Play();
	self.LeftFillagree.AnimIn:Play();
	self.BannerTopGlow.AnimIn:Play();
	self.BannerBottomGlow.AnimIn:Play();
	self.BannerMiddleGlow.AnimIn:Play();
	self.Title.AnimIn:Play();
	self.Overlay.RedFlash.AnimIn:Play();
	self.Overlay.FlashBurst.AnimIn:Play();
	self.Overlay.FlashBurstLeft.AnimIn:Play();
	self.Overlay.FlashBurstCenter.AnimIn:Play();
	self:Show();

	self.AnimOutTimer = C_Timer:NewTicker(data.timeToHold or 8, GenerateClosure(self.PerformAnimOut, self), 1);
end

function MiniGamesBannerMixin:StopBanner()
	if self.AnimOutTimer then
		self.AnimOutTimer:Cancel();
		self.AnimOutTimer = nil;
	end

	self.SkullCircle.AnimIn:Stop();
	self.BannerTop.AnimIn:Stop();
	self.BannerBottom.AnimIn:Stop();
	self.BannerMiddle.AnimIn:Stop();
	self.BottomFillagree.AnimIn:Stop();
	self.SkullSpikes.AnimIn:Stop();
	self.RightFillagree.AnimIn:Stop();
	self.LeftFillagree.AnimIn:Stop();
	self.BannerTopGlow.AnimIn:Stop();
	self.BannerBottomGlow.AnimIn:Stop();
	self.BannerMiddleGlow.AnimIn:Stop();
	self.Title.AnimIn:Stop();
	self.Overlay.RedFlash.AnimIn:Stop();
	self.Overlay.FlashBurst.AnimIn:Stop();
	self.Overlay.FlashBurstLeft.AnimIn:Stop();
	self.Overlay.FlashBurstCenter.AnimIn:Stop();
	self:Hide();
end

function MiniGamesBannerMixin:PerformAnimOut()
    self.AnimOut:Play();
end

function MiniGamesBanner_OnAnimOutFinished(self)
	local banner = self:GetParent();
	banner:Hide();
end