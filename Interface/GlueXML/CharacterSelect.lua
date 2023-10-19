local CHARACTER_SELECT_ROTATION_START_X = nil;
local CHARACTER_SELECT_INITIAL_FACING = nil;

local CHARACTER_ROTATION_CONSTANT = 0.6;

local DRAG_ACTIVE = false
local DRAG_BUTTON_INDEX = nil
local DRAG_HOLD_BUTTON = nil
local DRAG_HOLD_BUTTON_TIME = 0
local DRAG_HOLD_DELAY_TIME = 0.5

local DEFAULT_TEXT_OFFSET_X = 4
local DEFAULT_TEXT_OFFSET_Y = 0

local MOVING_TEXT_OFFSET_X = 12
local MOVING_TEXT_OFFSET_Y = 0

local DEFAULT_HC_ICON_OFFSET_X = 0
local DEFAULT_HC_ICON_OFFSET_Y = 5

local MOVING_HC_ICON_OFFSET_X = 8
local MOVING_HC_ICON_OFFSET_Y = 5

local translationTable = {}
local translationServerCache = {}

FACTION_OVERRIDE = {}

local SERVICE_BUTTON_ACTIVATION_DELAY = 0.400

function CharacterSelect_SaveCharacterOrder()
    if CharacterSelect.orderChanged and not CharacterSelect.lockCharacterMove then
    	CharacterSelect.lockCharacterMove = true

    	local cache = translationTable

    	if #translationServerCache > 0 then
    		cache = translationServerCache
    	end

		C_GluePackets:SendPacket(C_GluePackets.OpCodes.SendCharactersOrderSave, unpack(cache))
    end
end

function CharacterSelect_OnLoad(self)
	CharSelectChangeListStateButton:SetFrameLevel(self:GetFrameLevel() + 4)

	C_CharacterServices.RequestServiceInfo()

	self.createIndex = 0;
	self.selectedIndex = 0;
	self.selectLast = 0;
	self.currentModel = nil;
	self:RegisterEvent("ADDON_LIST_UPDATE");
	self:RegisterEvent("CHARACTER_LIST_UPDATE");
	self:RegisterEvent("UPDATE_SELECTED_CHARACTER");
	self:RegisterEvent("SELECT_LAST_CHARACTER");
	self:RegisterEvent("SELECT_FIRST_CHARACTER");
	self:RegisterEvent("SUGGEST_REALM");
	self:RegisterEvent("FORCE_RENAME_CHARACTER");
	self:RegisterEvent("SERVER_SPLIT_NOTICE")
	self:RegisterCustomEvent("SERVICE_DATA_UPDATE")
	self:RegisterCustomEvent("CUSTOM_CHARACTER_LIST_UPDATE")
	self:RegisterCustomEvent("CUSTOM_CHARACTER_INFO_UPDATE")
	self:RegisterCustomEvent("CUSTOM_CHARACTER_FIXED")
end

function CharacterSelect_OnShow()
	AccountLoginConnectionErrorFrame:Hide()

	FireCustomClientEvent("CUSTOM_CHARACTER_SELECT_SHOWN")
	table.wipe(FACTION_OVERRIDE)

	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	ReadyForAccountDataTimes()
	GlueDialog:HideDialog("SERVER_WAITING")
	CharSelectServicesFlowFrame:Hide()
	CharacterBoostBuyFrame:Hide()
	CharacterSelect.AutoEnterWorld = false

	local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")
	local isNeedShowDialogWaitData = (forceChangeFactionEvent and forceChangeFactionEvent == -1) and not C_Service.GetAccountID()

	if isNeedShowDialogWaitData then
		GlueDialog:ShowDialog("SERVER_WAITING")
	else
		GlueDialog:HideDialog("SERVER_WAITING")
	end

	if #translationTable == 0 then
		local numCharacters = C_CharacterList.GetNumCharactersOnPage()
		for i = 1, C_CharacterList.GetNumCharactersPerPage() do
			translationTable[i] = i <= numCharacters and i or 0
		end
	end

	UpdateAddonButton();

	CharacterSelect_UpdateRealmButton()

	if IsConnectedToServer() then
		if C_CharacterCreation.IsDressStateChangingBack() then
			C_CharacterCreation.QueueListUpdate()
		else
			GetCharacterListUpdate();
		end
	else
		UpdateCharacterList();
	end

	-- fadein the character select ui
	GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)

	RealmSplitCurrentChoice:Hide();
	RequestRealmSplitInfo();

	--Clear out the addons selected item
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, ALL);

	CharacterBoostButton:Show()

	CharacterSelectLogoFrameLogo:SetAtlas(C_RealmInfo.GetServerLogo(C_RealmInfo.GetServerIDByName(GetServerName())))

	CharacterSelectCharacterFrame:Hide()
	CharacterSelectLeftPanel:Hide()
	CharacterSelectPlayerNameFrame:Hide()
	CharacterSelectBottomLeftPanel:Hide()
	CharSelectChangeRealmButton:Hide()
	CharSelectChangeListStateButton:Hide()
end

function CharacterSelect_OnHide()
	GlueDialog:HideDialog("ADDON_INVALID_VERSION_DIALOG")
	CharacterSelect_CloseDropdowns()

	if DRAG_ACTIVE then
		DRAG_ACTIVE = false
		DRAG_HOLD_BUTTON = nil
		DRAG_HOLD_BUTTON_TIME = 0

		if DRAG_BUTTON_INDEX then
			_G["CharSelectCharacterButton"..DRAG_BUTTON_INDEX]:OnDragStop()
			DRAG_BUTTON_INDEX = nil
		end
	end

	C_CharacterList.ForceSetPlayableMode()

	CharacterDeleteDialog:Hide()
	CharacterRenameDialog:Hide()
	CharacterFixDialog:Hide()
	CharacterBoostBuyFrame:Hide()
	CharacterServicePagePurchaseFrame:Hide()
	CharacterServiceRestoreCharacterFrame:Hide()

	if ( DeclensionFrame ) then
		DeclensionFrame:Hide();
	end
	SERVER_SPLIT_STATE_PENDING = -1;

    SetSafeCVar("ForceChangeFactionEvent", -1)
	SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)

	CharacterSelect_UIResetAnim()
end

function CharacterSelect_OnUpdate(self, elapsed)
	local connected = IsConnectedToServer() == 1
	local serverName, isPVP, isRP = GetServerName()

	if connected ~= self.connected or serverName ~= self.serverName then
		self.connected = connected
		self.serverName = serverName

		if serverName then
			local serverType
			if isPVP then
				serverType = isRP and RPPVP_PARENTHESES or PVP_PARENTHESES
			elseif isRP then
				serverType = RP_PARENTHESES
			else
				serverType = ""
			end

			if connected then
				CharSelectChangeRealmButton:SetFormattedText("%s %s", serverName, serverType)
			else
				CharSelectChangeRealmButton:SetFormattedText("%s %s\n(%s)", serverName, serverType, SERVER_DOWN)
				UpdateCharacterSelectListView()
				CharacterSelectCharacterFrame:PlayAnim(true)
				if not CharacterSelectLeftPanel.isRevers then
					CharacterSelectLeftPanel:PlayAnim(true)
				end
				CharacterSelectPlayerNameFrame:PlayAnim(true)
			end

			CharSelectChangeRealmButton:SetWidth(math.max(160, math.floor(CharSelectChangeRealmButton:GetTextWidth() + 0.5) + 20))
		end
	end

	if DRAG_HOLD_BUTTON then
		DRAG_HOLD_BUTTON_TIME = DRAG_HOLD_BUTTON_TIME + elapsed
		if DRAG_HOLD_BUTTON_TIME >= DRAG_HOLD_DELAY_TIME then
			DRAG_HOLD_BUTTON:OnDragStart()
		end
	end

	if self.serviceButtonDelay then
		self.serviceButtonDelay = self.serviceButtonDelay - elapsed

		if self.serviceButtonDelay <= 0 then
			self.serviceButtonDelay = nil

			local button = CharacterSelectCharacterFrame.characterSelectButtons[CharacterSelect.selectedIndex]
			for _, serviceButton in ipairs(button.serviceButtons) do
				serviceButton:EnableMouse(true)
			end
		end
	end

	if ( SERVER_SPLIT_STATE_PENDING > 0 ) then
		CharacterSelectRealmSplitButton:Show();

		if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
			RealmSplit_SetChoiceText();
			RealmSplitPending:SetPoint("TOP", RealmSplitCurrentChoice, "BOTTOM", 0, -10);
		else
			RealmSplitPending:SetPoint("TOP", CharacterSelectRealmSplitButton, "BOTTOM", 0, 0);
			RealmSplitCurrentChoice:Hide();
		end

		if ( SERVER_SPLIT_STATE_PENDING > 1 ) then
			CharacterSelectRealmSplitButton:Disable();
			CharacterSelectRealmSplitButtonGlow:Hide();
			RealmSplitPending:SetText( SERVER_SPLIT_PENDING );
		else
			CharacterSelectRealmSplitButton:Enable();
			CharacterSelectRealmSplitButtonGlow:Show();
			local datetext = SERVER_SPLIT_CHOOSE_BY.."\n"..SERVER_SPLIT_DATE;
			RealmSplitPending:SetText( datetext );
		end

		if ( SERVER_SPLIT_SHOW_DIALOG and not GlueDialog:IsShown() ) then
			SERVER_SPLIT_SHOW_DIALOG = false;
			local dialogString = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
			if ( SERVER_SPLIT_CLIENT_STATE > 0 ) then
				local serverChoice = RealmSplit_GetFormatedChoice(SERVER_SPLIT_REALM_CHOICE);
				local stringWithDate = format(SERVER_SPLIT,SERVER_SPLIT_DATE);
				dialogString = stringWithDate.."\n\n"..serverChoice;
				GlueDialog:ShowDialog("SERVER_SPLIT_WITH_CHOICE", dialogString);
			else
				GlueDialog:ShowDialog("SERVER_SPLIT", dialogString);
			end
		end
	else
		CharacterSelectRealmSplitButton:Hide();
	end

	-- Account Msg stuff
	if ( (ACCOUNT_MSG_NUM_AVAILABLE > 0) and not GlueDialog:IsShown() ) then
		if ( ACCOUNT_MSG_HEADERS_LOADED ) then
			if ( ACCOUNT_MSG_BODY_LOADED ) then
				local dialogString = AccountMsg_GetHeaderSubject( ACCOUNT_MSG_CURRENT_INDEX ).."\n\n"..AccountMsg_GetBody();
				GlueDialog:ShowDialog("ACCOUNT_MSG", dialogString);
			end
		end
	end

    local factionEvent = GetSafeCVar("ForceChangeFactionEvent")
	if not GlueDialog:IsShown() and not GlueParent.dontShowInvalidVersionAddonDialog and (not factionEvent or factionEvent ~= 1) then
		if AddonList_HasNewVersion() then
			if C_GlueCVars.GetCVar("IGNORE_ADDON_VERSION") ~= "1" then
				if IsGMAccount(true) then
					GlueDialog:ShowDialog("ADDON_INVALID_VERSION_DIALOG_NSA")
				else
					GlueDialog:ShowDialog("ADDON_INVALID_VERSION_DIALOG")
				end
			else
				GlueParent.dontShowInvalidVersionAddonDialog = true
			end
		else
			C_GlueCVars.SetCVar("IGNORE_ADDON_VERSION", nil)
			GlueParent.dontShowInvalidVersionAddonDialog = true
		end
	end

	GlueDialog:CheckQueuedDialogs()
end

function CharacterSelect_OnKeyDown(self,key)
	if CharSelectServicesFlowFrame:IsShown()
	or GlueDialog:IsDialogShown("SERVER_WAITING")
	then
		return
	end

	if ( key == "ESCAPE" ) then
		if CharacterSelectCharacterFrame.DropDownMenu:IsShown() then
			CharacterSelectCharacterFrame.DropDownMenu:Hide()
		else
			CharacterSelect_Exit();
		end
	elseif ( key == "ENTER" ) then
		CharacterSelect_CloseDropdowns()
		CharacterSelect_EnterWorld();
	elseif ( key == "PRINTSCREEN" ) then
		CharacterSelect_CloseDropdowns()
		Screenshot();
	elseif ( key == "UP" or key == "LEFT" ) then
		local numChars = C_CharacterList.GetNumCharactersOnPage();
		if ( numChars > 1 ) then
			if ( CharacterSelect.selectedIndex > 1 ) then
				CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex - 1);
			else
				CharacterSelect_SelectCharacter(numChars);
			end
		end
	elseif ( key == "DOWN" or key == "RIGHT" ) then
		local numChars = C_CharacterList.GetNumCharactersOnPage();
		if ( numChars > 1 ) then
			if ( CharacterSelect.selectedIndex < numChars ) then
				CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex + 1);
			else
				CharacterSelect_SelectCharacter(1);
			end
		end
	end
end

enum:E_FORCE_CHANGE_FACTION_TEXT {
	[0] = FORCE_CHANGE_FACTION_EVENT_PANDA,
	[1] = FORCE_CHANGE_FACTION_EVENT_VULPERA,
	[2] = FORCE_CHANGE_FACTION_EVENT_COMMON
}

function UpdateCharacterSelectListView()
	local connected = IsConnectedToServer() == 1
	local numCharacters = C_CharacterList.GetNumCharactersOnPage()
	local inPlayableMode = C_CharacterList.IsInPlayableMode()

	if not connected then
		C_CharacterList.ForceSetPlayableMode()
		inPlayableMode = true
	end

	CharacterSelectOptionsButton:SetShown(inPlayableMode)
	CharSelectRestoreButton:SetShown(not inPlayableMode)

	local showBoostServicePanel = inPlayableMode and numCharacters > 0 --and C_CharacterServices.GetBoostStatus() ~= Enum.CharacterServices.BoostServiceStatus.Disabled
	CharacterBoostButton:SetShown(showBoostServicePanel)
	CharacterSelectLeftPanel.CharacterBoostInfoFrame:SetShown(showBoostServicePanel)

	if not inPlayableMode then
		CharSelectCreateCharacterMiddleButton:Hide()
		CharSelectCreateCharacterButton:Hide()
		CharSelectChangeListStateButton:Hide()

		CharSelectCharacterName:Show()
		CharacterSelectAddonsButton:Hide()

		CharacterSelect_UpdateRealmButton()
	else
		CharSelectCreateCharacterMiddleButton:SetShown(connected and numCharacters == 0)
		CharSelectCreateCharacterButton:SetShown(connected and numCharacters > 0)
		CharSelectChangeListStateButton:SetShown(connected)
		CharSelectChangeListStateButton:SetText(CHARACTER_SELECT_UNDELETED_CHARACTER)

		CharSelectCharacterName:SetShown(connected and numCharacters > 0)
		CharacterSelectAddonsButton:SetShown(connected and GetNumAddOns() > 0)

		CharSelectChangeRealmButton:Show()
		CharacterSelect_UIShowAnim()
	end

	CharacterSelect_UpdateEnterWorldButton()

	if CharacterSelect.UndeleteCharacterAlert then
		if CharacterSelect.UndeleteCharacterAlert == 1 then
			GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_UNDELETE_ALERT_1)
		else
			GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_UNDELETE_ALERT_2)
		end
		CharacterSelect.UndeleteCharacterAlert = nil
	end
end

function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		C_CharacterServices.RequestServiceInfo(true)
		UpdateAddonButton();
	elseif ( event == "CHARACTER_LIST_UPDATE" ) then
		if CHARACTER_CREATE_DRESS_STATE_QUEUED then
			return
		end

		do
			local numCharacters = C_CharacterList.GetNumCharactersOnPage()
			table.wipe(translationTable)

			for i = 1, C_CharacterList.GetNumCharactersPerPage() do
				translationTable[i] = i <= numCharacters and i or 0
			end

			CharacterSelect.orderChanged = nil
			table.wipe(translationServerCache)
		end

		UpdateCharacterList();

		if CharacterSelect.AutoEnterWorld then
			CharacterSelect_SelectCharacter(CharSelectServicesFlowFrame.selectedCharacterIndex, CharSelectServicesFlowFrame.selectedCharacterIndex)

			if GetCharIDFromIndex(CharacterSelect.selectedIndex) == CharSelectServicesFlowFrame.selectedCharacterIndex then
				C_CharacterList.EnterWorld()
				CharacterSelect.AutoEnterWorld = false
			end
		end

		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestCharacterListInfo)
		CharacterSelect_UpdateRealmButton()
		UpdateCharacterSelectListView()
		UpdateCharacterSelection()

		local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")

		if forceChangeFactionEvent and forceChangeFactionEvent ~= -1 then
			local factionText = E_FORCE_CHANGE_FACTION_TEXT[forceChangeFactionEvent]

			if factionText then
				CharacterSelectUI:Hide()
				GlueDialog:ShowDialog("SERVER_WAITING", factionText)

				C_Timer:After(3, function()
					C_CharacterList.EnterWorld()
				end)
			end

			SetSafeCVar("ForceChangeFactionEvent", -1)
		else
			CharacterSelectUI:Show()
		end

		FireCustomClientEvent("CHARACTER_LIST_UPDATE_DONE")
	elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		local index = ...;
		if ( index == 0 ) then
			CharSelectCharacterName:SetText("");
		else
			CharacterSelect.selectedIndex = GetIndexFromCharID(index);
		end
		UpdateCharacterSelection(self);
	elseif ( event == "SELECT_LAST_CHARACTER" ) then
		self.selectLast = 1;
	elseif ( event == "SELECT_FIRST_CHARACTER" ) then
		CharacterSelect_SelectCharacter(1, 1);
	elseif ( event == "SUGGEST_REALM" ) then
		local category, id = ...;
		local name = C_RealmList.GetRealmInfo(category, id);
		if ( name ) then
			SetGlueScreen("charselect");
			C_RealmList.ChangeRealm(category, id);
		else
			if ( RealmList:IsShown() ) then
				RealmListUpdate();
			else
				RealmList:Show();
			end
		end
	elseif ( event == "FORCE_RENAME_CHARACTER" ) then
		local message = ...;
		CharacterRenameDialog:Show();
		CharacterRenameDialog.Container.Title:SetText(_G[message]);
	elseif event == "SERVICE_DATA_UPDATE" then
		local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent")) or -1
		if forceChangeFactionEvent == -1 then
			GlueDialog:HideDialog("SERVER_WAITING")
		end
	elseif event == "CUSTOM_CHARACTER_LIST_UPDATE" then
		local listModeChanged = ...

		if CharacterSelectCharacterFrame:IsShown() ~= 1 and C_CharacterList.GetNumCharactersOnPage() == 0 then
			CharacterSelectCharacterFrame:PlayAnim()
		end

		CharacterSelect_UpdatePageButton()
		CharacterSelect_UpdateCharecterCreateButton()

		if listModeChanged then
			UpdateCharacterSelection()
			UpdateCharacterSelectListView()
		end

		CharSelectEnterWorldButton:SetEnabled(C_CharacterList.CanEnterWorld(GetCharIDFromIndex(CharacterSelect.selectedIndex)))
	elseif event == "CUSTOM_CHARACTER_INFO_UPDATE" then
		local characterID = ...
		if CharacterSelectCharacterFrame.characterSelectButtons[characterID] then
			CharacterSelectCharacterFrame.characterSelectButtons[characterID]:UpdateCharData()
		end
		if characterID == C_CharacterList.GetSelectedCharacter() then
			CharacterSelect_UpdateEnterWorldButton()
		end
	elseif event == "CUSTOM_CHARACTER_FIXED" then
		local characterID = ...
		if characterID ~= GetCharIDFromIndex(CharacterSelect.selectedIndex) then
			SelectCharacter(characterID)
		end

		CharacterSelect_EnterWorld()
	elseif ( event == "SERVER_SPLIT_NOTICE" ) then
		local msg = select(3, ...)
		local prefix, content = string.match(msg, "([^:]+):(.*)")

		if prefix == "SMSG_CHARACTERS_ORDER_SAVE" then
			if content == "OK" then
				local numCharacters = C_CharacterList.GetNumCharactersOnPage()
				table.wipe(translationServerCache)

				for i = 1, C_CharacterList.GetNumCharactersPerPage() do
					translationServerCache[i] = i <= numCharacters and i or 0
				end

				CharacterSelect.lockCharacterMove = false
			else
				GetCharacterListUpdate()
				CharacterSelect.lockCharacterMove = false
			end
		elseif prefix == "ASMSG_CHARACTER_OVERRIDE_TEAM" then
			local characterIndex, factionIndex = string.split(":", content)
			characterIndex = tonumber(characterIndex) + 1

			FACTION_OVERRIDE[characterIndex] = tonumber(factionIndex)

			if CharacterSelectCharacterFrame.characterSelectButtons[characterIndex] then
				CharacterSelectCharacterFrame.characterSelectButtons[characterIndex]:UpdateFaction()
			end
		end
	end
end

local function playPanelAnim(f, revers, finishCallback, resetAnimation)
	if (revers and f:IsShown()) or (not revers and not f:IsShown()) then
		f:PlayAnim(revers, finishCallback, resetAnimation)
	end
end

function CharacterSelect_UIShowAnim( revers, finishCallback )
	CharacterSelectBottomLeftPanel.startPoint = CharacterSelectAddonsButton:IsShown() and -175 or -150

	if C_CharacterList.GetNumCharactersOnPage() > 0 then
		playPanelAnim(CharacterSelectCharacterFrame, revers)
		playPanelAnim(CharacterSelectLeftPanel, revers)
		playPanelAnim(CharacterSelectPlayerNameFrame, revers)
	end

	playPanelAnim(CharSelectChangeRealmButton, revers)
	playPanelAnim(CharacterSelectBottomLeftPanel, revers, finishCallback)
end

function CharacterSelect_UIResetAnim()
	CharacterSelectCharacterFrame:Reset()
	CharacterSelectLeftPanel:Reset()
	CharacterSelectPlayerNameFrame:Reset()
	CharSelectChangeRealmButton:Reset()
	CharacterSelectBottomLeftPanel:Reset()

	CharacterSelectCharacterFrame:SetPosition(CharacterSelectCharacterFrame.startPoint)
	CharacterSelectLeftPanel:SetPosition(CharacterSelectLeftPanel.startPoint)
	CharacterSelectPlayerNameFrame:SetPosition(CharacterSelectPlayerNameFrame.startPoint)
	CharSelectChangeRealmButton:SetPosition(CharSelectChangeRealmButton.startPoint)
	CharacterSelectBottomLeftPanel:SetPosition(CharacterSelectBottomLeftPanel.startPoint)
end

function CharacterSelect_UpdateRealmButton()
	if C_CharacterList.IsInPlayableMode() and GetServerName() then
		playPanelAnim(CharSelectChangeRealmButton)
	else
		playPanelAnim(CharSelectChangeRealmButton, true, function()
			CharSelectChangeRealmButton:Hide()
		end, true)
	end
end

function CharSelectChangeListState_OnClick(self, button)
	CharacterSelect_CloseDropdowns()
	self:Disable()

	if C_CharacterList.IsInPlayableMode() then
		CharSelectCharPageButtonPrev:Disable()
		CharSelectCharPageButtonNext:Disable()

		C_CharacterList.EnterRestoreMode()
	else
		CharacterSelect_Exit()
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection()
	CharacterSelect_CloseDropdowns()

	local inPlayableMode = C_CharacterList.IsInPlayableMode()

	for i = 1, C_CharacterList.GetNumCharactersPerPage() do
		local button = _G["CharSelectCharacterButton"..i]
		button.selection:Hide()
		button.upButton:Hide()
		button.downButton:Hide()
		button.FactionEmblem:Show()

		if inPlayableMode and not CharSelectServicesFlowFrame:IsShown() then
			button:EnableDrag()
		else
			button:DisableDrag()
		end

		button:HideMoveButtons()

		if inPlayableMode then
			button:UpdatePaidServicerID()
		else
			button.PAIDButton:SetPAID(0)
		end
	end

	local index = CharacterSelect.selectedIndex;
	if ( (index > 0) and (index <= C_CharacterList.GetNumCharactersPerPage()) ) then
		button = _G["CharSelectCharacterButton"..index]
		if ( button ) then
			button.selection:Show()
			button:UpdateMouseOver()
		end
	end
end

function CharacterSelect_UpdateCharecterCreateButton()
	if C_CharacterList.CanCreateCharacter() and not CharSelectServicesFlowFrame:IsShown() then
		if C_CharacterList.GetNumCharactersOnPage() == C_CharacterList.GetNumCharactersPerPage() then
			CharacterSelect.createIndex = 0
			CharSelectCreateCharacterButton:SetID(0)
		end

		CharSelectCreateCharacterButton:Enable()
	else
		CharSelectCreateCharacterButton:Disable()
	end
end

function UpdateCharacterList( dontUpdateSelect )
	local inPlayableMode = C_CharacterList.IsInPlayableMode()
	local maxCharacters = C_CharacterList.GetNumCharactersPerPage()
	local numCharacters = C_CharacterList.GetNumCharactersOnPage()
	local index = 1;

	for i = 1, numCharacters do
		local characterID = GetCharIDFromIndex(i)
		local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(characterID)

		local button = _G["CharSelectCharacterButton"..index];
		if ( not name ) then
			button:SetText("ERROR - Tell Jeremy");
		else
			if ( not zone ) then
				zone = "";
			end

			name = inPlayableMode and name or (name .. DELETED)
			button.buttonText.name:SetText(name)

			button.PortraitFrame.LevelFrame.Level:SetText(level)

		--[[
			if( ghost ) then
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, class);
			else
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO, class);
			end
		--]]

			button.buttonText.Location:SetText(zone == "" and UNKNOWN_ZONE or zone);
		end

		button:SetCharacterInfo(characterID, name, race, class, level, zone, sex, ghost, PCC, PRC, PFC)
		button:UpdatePaidServicerID()
		button:UpdateCharData()
		button:UpdateFaction()
		button:Show()

		index = index + 1;
		if index > maxCharacters then
			break;
		end
	end

	CharacterSelect.createIndex = 0;

	local connected = IsConnectedToServer();
	while index <= maxCharacters do
		local button = _G["CharSelectCharacterButton"..index];
		if ( (CharacterSelect.createIndex == 0) and (numCharacters < C_CharacterList.GetNumCharactersPerPage()) ) then
			CharacterSelect.createIndex = index;
			if ( connected ) then
				--If can create characters position and show the create button
				CharSelectCreateCharacterButton:SetID(index);
			end
		end

		button:Hide();
		index = index + 1;
	end

	CharacterSelect_UpdateCharecterCreateButton()

	if ( numCharacters == 0 ) then
		CharacterSelect.selectedIndex = 0;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
		return;
	end

	if ( CharacterSelect.selectLast == 1 ) then
		CharacterSelect.selectLast = 0;
		CharacterSelect_SelectCharacter(numCharacters, 1);
		return;
	end

	if ( (CharacterSelect.selectedIndex == 0) or (CharacterSelect.selectedIndex > numCharacters) ) then
		CharacterSelect.selectedIndex = 1;
	end

	if not dontUpdateSelect then
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
	end
end

function CharacterSelect_TabResize(self)
	local buttonMiddle = _G[self:GetName().."Middle"];
	local buttonMiddleDisabled = _G[self:GetName().."MiddleDisabled"];
	local width = self:GetTextWidth() - 8;
	local leftWidth = _G[self:GetName().."Left"]:GetWidth();
	buttonMiddle:SetWidth(width);
	buttonMiddleDisabled:SetWidth(width);
	self:SetWidth(width + (2 * leftWidth));
end

function CharacterSelect_OpenCharacterCreate(paidServiceID, characterID, onShowAnim)
	if CharacterSelectBottomLeftPanel and CharacterSelectBottomLeftPanel:IsAnimPlaying() then
		return
	end

	CharacterSelectUI.Background.hideAnim:Play()
	CharacterSelect_UIShowAnim(true, function(this)
		if type(onShowAnim) == "function" then
			onShowAnim()
		end
		PlaySound("gsCharacterSelectionCreateNew");
		C_CharacterCreation.SetCreateScreen(paidServiceID, characterID)
	end)

	return true
end

function CharacterSelect_SelectCharacter(characterIndex, noCreate)
	CharacterSelect_CloseDropdowns()

	if ( characterIndex == CharacterSelect.createIndex ) then
		if ( not noCreate ) then
			CharacterSelect_OpenCharacterCreate()
		end
	else
		local characterID = GetCharIDFromIndex(characterIndex)
		local name, race, class = GetCharacterInfo(characterID)

		if race then
			local RaceInfo 		= C_CreatureInfo.GetRaceInfo(race)
			local FactionInfo 	= C_CreatureInfo.GetFactionInfo(race)
			local ClassInfo 	= C_CreatureInfo.GetClassInfo(class)

			local factionTag 	= FactionInfo.groupTag
			local modelName 	= factionTag

			if RaceInfo.raceID == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
				if ClassInfo.classFile == "DEATHKNIGHT" then
					modelName = "Zandalar_DeathKnight"
				elseif FACTION_OVERRIDE[characterID] == SERVER_PLAYER_FACTION_GROUP.Alliance then
					modelName = "Zandalar_Alliance"
				else
					modelName = "Zandalar_Horde"
				end
			elseif ClassInfo.classFile == "DEATHKNIGHT" then
				if C_CharacterCreation.IsPandarenRace(RaceInfo.raceID) then
					modelName = "Pandaren_DeathKnight"
				else
					modelName = "DeathKnight"
				end
			elseif RaceInfo.raceID == E_CHARACTER_RACES.RACE_DRACTHYR then
				modelName = "Dracthyr"
			elseif C_CharacterCreation.IsPandarenRace(RaceInfo.raceID) then
				modelName = "Pandaren"
			elseif C_CharacterCreation.IsVulperaRace(RaceInfo.raceID) then
				modelName = "Vulpera"
			elseif FACTION_OVERRIDE[characterID] then
				if FACTION_OVERRIDE[characterID] == SERVER_PLAYER_FACTION_GROUP.Horde then
					modelName = "Horde"
				elseif FACTION_OVERRIDE[characterID] == SERVER_PLAYER_FACTION_GROUP.Alliance then
					modelName = "Alliance"
				end
			end

			name = GetClassColorObj(ClassInfo.classFile):WrapTextInColorCode(name)
			CharSelectCharacterName:SetText(name)

			CharacterModelManager.SetBackground(modelName)

			CharacterSelect.currentModel = GetSelectBackgroundModel(characterID);

			SelectCharacter(characterID);

			local forceCharCustomization = tonumber(GetSafeCVar("FORCE_CHAR_CUSTOMIZATION")) or -1
			if forceCharCustomization ~= -1 then
				if PAID_SERVICE_CHARACTER_ID ~= 0 then
					RunNextFrame(function()
						CharacterSelect_OpenCharacterCreate(E_PAID_SERVICE.CUSTOMIZATION, characterID)
					end)
					SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
					return
				end
			end

			CharacterSelect_UpdateEnterWorldButton()
		else
			CharacterModelManager.SetBackground("Alliance")
		end
	end
end

function CharacterSelect_UpdateEnterWorldButton()
	if C_CharacterList.IsInPlayableMode() and IsConnectedToServer() == 1 and C_CharacterList.GetNumCharactersOnPage() > 0 then
		CharSelectEnterWorldButton:Show()
	else
		CharSelectEnterWorldButton:Hide()
		return
	end

	local characterID = C_CharacterList.GetSelectedCharacter()
	if C_CharacterList.HasCharacterForcedCustomization(characterID) then
		CharSelectEnterWorldButton:SetText(COMPLETE_FORCED_CUSTOMIZATION)
	elseif C_CharacterList.HasCharacterHardcoreProposal(characterID) then
		CharSelectEnterWorldButton:SetText(COMPLETE_FORCED_CUSTOMIZATION)
	else
		CharSelectEnterWorldButton:SetText(ENTER_WORLD)
	end
	CharSelectEnterWorldButton:SetEnabled(C_CharacterList.CanEnterWorld(characterID))
end

function CharacterSelect_EnterWorld()
	if not C_CharacterList.IsInPlayableMode() or GlueDialog:IsDialogShown("SERVER_WAITING") then return end

	local characterID = GetCharIDFromIndex(CharacterSelect.selectedIndex)

	if C_CharacterList.HasCharacterForcedCustomization(characterID) then
		CharacterSelect_OpenCharacterCreate(E_PAID_SERVICE.CUSTOMIZATION, characterID)
		SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
		return
	elseif C_CharacterList.HasCharacterHardcoreProposal(characterID) then
		GlueDialog:ShowDialog("HARDCORE_PROPOSAL", nil, characterID)
		return
	end

	PlaySound("gsCharacterSelectionEnterWorld");
	StopGlueAmbience();

	if CharSelectServicesFlowFrame:IsShown() then
		CharacterServicesMaster_OnWorldEnterAttempt()
	elseif C_CharacterList.CanEnterWorld(characterID) then
		C_CharacterList.EnterWorld()
	end
end

function CharacterSelect_Exit()
	if GlueDialog:IsDialogShown("SERVER_WAITING") then return end

	if C_CharacterList.IsInPlayableMode() then
		CharacterSelect.lockCharacterMove = false
		PlaySound("gsCharacterSelectionExit");
		if not CharSelectServicesFlowFrame.LockEnterWorld then
			DisconnectFromServer();
			SetGlueScreen("login");
		end
	else
		CharSelectCharPageButtonPrev:Disable()
		CharSelectCharPageButtonNext:Disable()
		C_CharacterList.ExitRestoreMode()
	end
end

function CharacterSelect_AccountOptions()
	PlaySound("gsCharacterSelectionAcctOptions");
end

function CharacterSelect_TechSupport()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_ChangeRealm()
	PlaySound("gsCharacterSelectionDelCharacter");
	C_RealmList.RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = GetScaledCursorPosition();
		CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing();
	end

	CharacterSelect_CloseDropdowns()
end

function CharacterSelectFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = nil
	end
end

function CharacterSelectFrame_OnUpdate()
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local cursorPos = GetScaledCursorPosition();
		local diff = (cursorPos - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = cursorPos;
		SetCharacterSelectFacing(GetCharacterSelectFacing() + diff);
	end
end

function CharacterSelectRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() + CHARACTER_FACING_INCREMENT);
	end
end

function CharacterSelectRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterSelectFacing(GetCharacterSelectFacing() - CHARACTER_FACING_INCREMENT);
	end
end

function RealmSplit_GetFormatedChoice(formatText)
	local realmChoice
	if ( SERVER_SPLIT_CLIENT_STATE == 1 ) then
		realmChoice = SERVER_SPLIT_SERVER_ONE;
	else
		realmChoice = SERVER_SPLIT_SERVER_TWO;
	end
	return format(formatText, realmChoice);
end

function RealmSplit_SetChoiceText()
	RealmSplitCurrentChoice:SetText( RealmSplit_GetFormatedChoice(SERVER_SPLIT_CURRENT_CHOICE) );
	RealmSplitCurrentChoice:Show();
end

function MoveCharacter(originIndex, targetIndex, fromDrag)
	if CharacterSelect.lockCharacterMove then return end

    CharacterSelect.orderChanged = true
    if targetIndex < 1 then
        targetIndex = #translationTable
    elseif targetIndex > #translationTable then
        targetIndex = 1
    end
    if originIndex == CharacterSelect.selectedIndex then
        CharacterSelect.selectedIndex = targetIndex
    elseif targetIndex == CharacterSelect.selectedIndex then
        CharacterSelect.selectedIndex = originIndex
    end
    translationTable[originIndex], translationTable[targetIndex] = translationTable[targetIndex], translationTable[originIndex]
    translationServerCache[originIndex], translationServerCache[targetIndex] = translationServerCache[targetIndex], translationServerCache[originIndex]

    -- update character list
    if ( fromDrag ) then
		DRAG_BUTTON_INDEX = targetIndex

        local oldButton = _G["CharSelectCharacterButton"..originIndex]
        local currentButton = _G["CharSelectCharacterButton"..targetIndex]

        oldButton:SetAlpha(0.6)
        oldButton:UnlockHighlight()
		if C_CharacterList.IsHardcoreCharacter(oldButton.characterID) then
			oldButton.buttonText.HardcoreIcon:SetPoint("TOPLEFT", DEFAULT_HC_ICON_OFFSET_X, DEFAULT_HC_ICON_OFFSET_Y)
		else
			oldButton.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET_X, DEFAULT_TEXT_OFFSET_Y)
		end

        currentButton:SetAlpha(1)
        currentButton:LockHighlight()
		if C_CharacterList.IsHardcoreCharacter(currentButton.characterID) then
			currentButton.buttonText.HardcoreIcon:SetPoint("TOPLEFT", MOVING_HC_ICON_OFFSET_X, MOVING_HC_ICON_OFFSET_Y)
		else
			currentButton.buttonText.name:SetPoint("TOPLEFT", MOVING_TEXT_OFFSET_X, MOVING_TEXT_OFFSET_Y)
		end
     else
     	CharacterSelect_SaveCharacterOrder()
    end

    UpdateCharacterSelection(CharacterSelect)
    UpdateCharacterList( true )
end

-- translation functions
function GetCharIDFromIndex(index)
    return translationTable[index] or 0
end

function GetIndexFromCharID(charID)
    if not CharacterSelect.orderChanged then
        return charID
    end
    for index = 1, #translationTable do
        if translationTable[index] == charID then
            return index
        end
    end
    return 0;
end

function CharacterSelect_PrevPage(self, button)
	if C_CharacterList.GetCurrentPageIndex() <= 1 then return end

	CharacterSelect_CloseDropdowns()

	CharSelectChangeListStateButton:Disable()
	CharSelectCharPageButtonPrev:Disable()
	CharSelectCharPageButtonNext:Disable()

	C_CharacterList.ScrollListPage(-1)
end

function CharacterSelect_NextPage(self, button)
	if C_CharacterList.GetCurrentPageIndex() >= C_CharacterList.GetNumPages() then return end

	CharacterSelect_CloseDropdowns()

	CharSelectChangeListStateButton:Disable()
	CharSelectCharPageButtonPrev:Disable()
	CharSelectCharPageButtonNext:Disable()

	C_CharacterList.ScrollListPage(1)
end

CharacterSelectPagePurchaseButtonMixin = CreateFromMixins(GlueDark_ButtonMixin)

function CharacterSelectPagePurchaseButtonMixin:OnLoad()
	GlueDark_ButtonMixin.OnLoadStyle(self, true)
end

function CharacterSelectPagePurchaseButtonMixin:OnEnter()
	GlueTooltip:SetOwner(self)
	GlueTooltip:AddLine(CHARACTER_SERVICES_LISTPAGE_TITLE)
	GlueTooltip:Show()
end

function CharacterSelectPagePurchaseButtonMixin:OnLeave()
	GlueTooltip:Hide()
end

function CharacterSelectPagePurchaseButtonMixin:OnClick(button)
	CharacterServicePagePurchaseFrame:SetPrice(C_CharacterServices.GetListPagePrice())
	CharacterServicePagePurchaseFrame:SetAltDescription(C_CharacterList.GetNumAvailablePages() > 1)
	CharacterServicePagePurchaseFrame:Show()
end

function CharacterSelect_UpdatePageButton()
	CharSelectChangeListStateButton:SetEnabled(not C_CharacterList.IsInPlayableMode() or C_CharacterList.IsRestoreModeAvailable())

	local numPages = C_CharacterList.GetNumPages()
	local isNewPageSuggested = C_CharacterServices.IsNewPageServiceAvailable()

	CharSelectCharPagePurchaseButton:SetShown(isNewPageSuggested)

	CharSelectCharPageButtonPrev:SetShown(numPages > 1)
	CharSelectCharPageButtonNext:SetShown(numPages > 1 and not isNewPageSuggested)

	if numPages > 1 then
		local currentPage = C_CharacterList.GetCurrentPageIndex()
		CharSelectCharPageButtonPrev:SetEnabled(currentPage > 1)
		CharSelectCharPageButtonNext:SetEnabled(currentPage < numPages)
	end
end

function CharacterSelect_RestoreButton_OnClick()
	CharacterServiceRestoreCharacterFrame:SetPurchaseArgs(CharacterSelect.selectedIndex)
	CharacterServiceRestoreCharacterFrame:SetPrice(C_CharacterServices.GetCharacterRestorePrice())
	CharacterServiceRestoreCharacterFrame:Show()
end

function CharacterSelect_FixCharacter(characterIndex)
	local characterID = GetCharIDFromIndex(characterIndex or CharacterSelect.selectedIndex)

	if characterID == 0 then
		error(string.format("Incorrect characterIndex [%s]", characterID), 2)
	end

	if C_CharacterList.IsCharacterPendingBoostDK(characterID) then
		return
	end

	local name, _, class, level = GetCharacterInfo(characterID)
	local classInfo = C_CreatureInfo.GetClassInfo(class)
	class = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(class).."|cffFFFFFF"

	CharacterFixDialog.Container.Character:SetFormattedText(CONFIRM_CHAR_DELETE2, name, level, class);

	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER)
	CharacterFixDialog.characterID = characterID
	CharacterFixDialog:Show()
end

function CharacterSelect_FixCharacter_OnLoad(self)
	self.Container.InfoIcon.InfoHeader = CHARACTER_FIX_HELP_HEAD
	self.Container.InfoIcon.InfoText = CHARACTER_FIX_HELP_TEXT
end

function CharacterSelect_FixCharacter_OnHide(self)
	self.characterID = nil
end

function CharacterSelect_FixCharacter_OKButton_OnClick(self)
	local dialog = self:GetParent():GetParent()
	local characterID = dialog.characterID
	dialog:Hide()
	C_CharacterList.FixCharacter(characterID)
end

function CharacterSelect_Delete(characterIndex)
	local characterID = GetCharIDFromIndex(characterIndex or CharacterSelect.selectedIndex)

	if characterID == 0 then
		error(string.format("Incorrect characterID [%s]", characterID), 2)
	end

	local name, _, class, level = GetCharacterInfo(characterID)
	local classInfo = C_CreatureInfo.GetClassInfo(class)
	if classInfo.classFile == "DEATHKNIGHT" then
		if C_CharacterList.HasPendingBoostDK() and not C_CharacterList.IsCharacterPendingBoostDK(characterID) then
			GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_DELETE_BLOCKED_BOOST_DEATH_KNIGHT)
			return
		end
	end

	class = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(class).."|cffFFFFFF"

	CharacterDeleteDialog.Container.Character:SetFormattedText(CONFIRM_CHAR_DELETE2, name, level, class);
	CharacterDeleteDialog.Container.OKButton:Disable();
	CharacterDeleteDialog.Container.EditBox:SetText("");

	PlaySound("gsCharacterSelectionDelCharacter");
	CharacterDeleteDialog.characterID = characterID
	CharacterDeleteDialog:Show();
end

function CharacterDeleteDialog_OnHide(self)
	self.characterID = nil
end

function CharacterDeleteDialog_OKButton_OnClick(self)
	local dialog = self:GetParent():GetParent()
	local characterID = dialog.characterID
	dialog:Hide()
	PlaySound("gsTitleOptionOK");
	DeleteCharacter(characterID)
end

function CharacterSelect_OpenBoost(characterIndex, animated)
	CharacterSelect_CloseDropdowns()

	local characterID = GetCharIDFromIndex(characterIndex or CharacterSelect.selectedIndex)

	if characterID == 0 then
		error(string.format("Incorrect characterIndex [%s]", characterID), 2)
	end

	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
	C_CharacterServices.RequestServiceInfo()

	if not CharSelectServicesFlowFrame:IsShown() and C_CharacterServices.GetBoostStatus() == Enum.CharacterServices.BoostServiceStatus.Purchased then
		if animated then
			CharSelectServicesFlowFrame:PlayAnim()
		else
			CharSelectServicesFlowFrame:Show()
		end
	elseif not CharacterBoostBuyFrame:IsShown() and C_CharacterServices.GetBoostStatus() == Enum.CharacterServices.BoostServiceStatus.Available then
		CharacterBoostBuyFrame:Show()
	end
end

function CharacterSelect_CloseDropdowns()
	CharacterSelectCharacterFrame.DropDownMenu:Hide()
end

CharacterSelectPAIDButtonMixin = {}

local PAID_OPTIONS_INFO = {
	[0] = {icon = "PAID_CIRCLE_UNDELETE", text = PAID_CHARACTER_RESTORE_TOOLTIP},
	{icon = "PAID_CIRCLE_CUSTOMIZE", text = PAID_CHARACTER_CUSTOMIZE_TOOLTIP},
	{icon = "PAID_CIRCLE_RACE", text = PAID_RACE_CHANGE_TOOLTIP},
	{icon = "PAID_CIRCLE_FACTION", text = PAID_FACTION_CHANGE_TOOLTIP},
	{text = PAID_ZODIAC_CHANGE_TOOLTIP},
}

function CharacterSelectPAIDButtonMixin:OnLoad()
	self.buttonW = self.Icon:GetWidth()
	self.buttonH = self.Icon:GetHeight()

	self:SetFrameLevel(self:GetParent().PortraitFrame:GetFrameLevel() + 5)

	self.Border:SetAtlas("UI-Frame-jailerstower-Portrait-border")
	self.Border2:SetAtlas("UI-Frame-jailerstower-Portrait")
	self.Border3:SetAtlas("UI-Frame-jailerstower-Portrait")
end

function CharacterSelectPAIDButtonMixin:SetColor( r, g, b )
	self.Border:SetVertexColor(r, g, b)
	self.Border2:SetVertexColor(r, g, b)
	self.Border3:SetVertexColor(r, g, b)
end

function CharacterSelectPAIDButtonMixin:SetPAID(paID)
	self.paID = paID
	self:SetShown(paID)
	self:UpdateIcon()
end

function CharacterSelectPAIDButtonMixin:UpdateIcon()
	if PAID_OPTIONS_INFO[self.paID] then
		if self.paID == 4 then
			local raceID = C_CharacterList.GetCharacterZodiacRaceID(self:GetParent().characterID)
			local zodiacRaceID, name, description, icon, atlas, available = C_CharacterCreation.GetZodiacSignInfoByRaceID(raceID ~= 0 and raceID or 1)
			self.Icon:SetAtlas(atlas.."-Small")
		else
			self.Icon:SetAtlas(PAID_OPTIONS_INFO[self.paID].icon)
		end
	end
end

function CharacterSelectPAIDButtonMixin:OnEnable()
	self.Icon:SetVertexColor(1, 1, 1)
end

function CharacterSelectPAIDButtonMixin:OnDisable()
	self.Icon:SetVertexColor(0.3, 0.3, 0.3)
end

function CharacterSelectPAIDButtonMixin:OnMouseDown()
	if self:IsEnabled() ~= 1 then return end
	self.Icon:SetSize(self.buttonH - 1, self.buttonW - 1)
end

function CharacterSelectPAIDButtonMixin:OnMouseUp()
	if self:IsEnabled() ~= 1 then return end
	self.Icon:SetSize(self.buttonH + 1, self.buttonW + 1)
end

function CharacterSelectPAIDButtonMixin:OnClick()
	CharacterSelect_CloseDropdowns()

	if self.paID == 0 then
		CharacterServiceRestoreCharacterFrame:SetPurchaseArgs(self:GetParent():GetID())
		CharacterServiceRestoreCharacterFrame:SetPrice(C_CharacterServices.GetCharacterRestorePrice())
		CharacterServiceRestoreCharacterFrame:Show()
		return
	end

	CharacterSelect_OpenCharacterCreate(self.paID, GetCharIDFromIndex(self:GetParent():GetID()))
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function CharacterSelectPAIDButtonMixin:OnEnter()
	for i = 2, 3 do
		self["Border"..i].HideAnim:Stop()
		self["Border"..i]:Show()

		self["Border"..i].Anim:Play()
		self["Border"..i].ShowAnim:Play()
	end

	if PAID_OPTIONS_INFO[self.paID] then
		GlueTooltip:SetOwner(self, "ANCHOR_LEFT", 7, -7)
		GlueTooltip:SetText(PAID_OPTIONS_INFO[self.paID].text)
		GlueTooltip:Show()
	end
end

function CharacterSelectPAIDButtonMixin:OnLeave()
	for i = 2, 3 do
		self["Border"..i].HideAnim:Play()
		self["Border"..i].ShowAnim:Stop()
	end

	GlueTooltip:Hide()
end

CharacterSelectUIMixin = {}

function CharacterSelectUIMixin:OnLoad()
	CharSelectChangeListStateButton:Disable()
end

function CharacterSelectUIMixin:OnMouseDown( button )
	CharacterSelectFrame_OnMouseDown(button)
end

function CharacterSelectUIMixin:OnMouseUp( button )
	CharacterSelectFrame_OnMouseUp(button)
end

function CharacterSelectUIMixin:OnUpdate()
	CharacterSelectFrame_OnUpdate()
end

CharacterSelectCharacterMixin = CreateFromMixins(GlueEasingAnimMixin)

function CharacterSelectCharacterMixin:Init()
	self.startPoint = 300
	self.endPoint = 0
	self.duration = 0.500
end

function CharacterSelectCharacterMixin:SetPosition(easing, progress)
	local alpha = progress and (self.isRevers and (1 - progress) or progress) or (self.isRevers and 0 or 1)

	self:SetAlpha(alpha)
	CharSelectCharPageButtonPrev:SetAlpha(alpha)
	CharSelectCharPageButtonNext:SetAlpha(alpha)
	CharSelectCreateCharacterButton:SetAlpha(alpha)

	if easing then
		self:ClearAndSetPoint("RIGHT", easing, 0)
	else
		self:ClearAndSetPoint("RIGHT", self.isRevers and self.startPoint or self.endPoint, 0)
	end
end

CharacterSelectLeftPanelMixin = CreateFromMixins(GlueEasingAnimMixin)

function CharacterSelectLeftPanelMixin:Init()
	self.startPoint = -300
	self.endPoint = 0
	self.duration = 0.500
end

function CharacterSelectLeftPanelMixin:SetPosition(easing, progress)
	if progress then
		self:SetAlpha(self.isRevers and (1 - progress) or progress)
	else
		self:SetAlpha(self.isRevers and 0 or 1)
	end
	if easing then
		self:ClearAndSetPoint("TOPLEFT", easing, -40)
	else
		self:ClearAndSetPoint("TOPLEFT", self.isRevers and self.startPoint or self.endPoint, -40)
	end
end

CharSelectChangeRealmButtonMixin = CreateFromMixins(GlueEasingAnimMixin)

function CharSelectChangeRealmButtonMixin:Init()
	self.startPoint = 40
	self.endPoint = -8
	self.duration = 0.500
end

function CharSelectChangeRealmButtonMixin:SetPosition(easing)
	if easing then
		self:ClearAndSetPoint("TOP", 0, easing)
	else
		self:ClearAndSetPoint("TOP", 0, self.isRevers and self.startPoint or self.endPoint)
	end
end

function CharSelectChangeRealmButtonMixin:OnClick(button)
	CharacterSelect_CloseDropdowns()
	CharacterSelect_ChangeRealm()
end

CharacterSelectBottomLeftPanelMixin = CreateFromMixins(GlueEasingAnimMixin)

function CharacterSelectBottomLeftPanelMixin:Init()
	self.startPoint = -150
	self.endPoint = 23
	self.duration = 0.500
end

function CharacterSelectBottomLeftPanelMixin:SetPosition(easing, progress)
	if progress then
		CharSelectCreateCharacterMiddleButton:SetAlpha(self.isRevers and (1 - progress) or progress)
	else
		CharSelectCreateCharacterMiddleButton:SetAlpha(self.isRevers and 0 or 1)
	end
	if easing then
		self:ClearAndSetPoint("BOTTOMLEFT", 70, easing)
	else
		self:ClearAndSetPoint("BOTTOMLEFT", 70, self.isRevers and self.startPoint or self.endPoint)
	end
end

CharacterSelectPlayerNameFrameMixin = CreateFromMixins(GlueEasingAnimMixin)

function CharacterSelectPlayerNameFrameMixin:Init()
	self.startPoint = -100
	self.endPoint = 0
	self.duration = 0.500
end

function CharacterSelectPlayerNameFrameMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("BOTTOM", 0, easing)
	else
		self:ClearAndSetPoint("BOTTOM", 0, self.isRevers and self.startPoint or self.endPoint)
	end
end

CharacterSelectButtonMixin = {}

function CharacterSelectButtonMixin:OnLoad()
	self:SetParentArray("characterSelectButtons")

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterForDrag("LeftButton")

	self.Background:SetAtlas("jailerstower-animapowerlist-dropdown-closedbg")
	self.selection:SetAtlas("jailerstower-animapowerlist-dropdown-closedbg2")

	self.HighlightTexture:SetAtlas("jailerstower-animapowerlist-dropdown-closedbg")

	self.PortraitFrame.Border:SetAtlas("UI-Frame-jailerstower-Portrait")
	self.PortraitFrame.FactionBorder:SetAtlas("UI-Frame-jailerstower-Portrait-border")

	self.PortraitFrame.LevelFrame.Border:SetAtlas("UI-Frame-jailerstower-Portrait")

	self.buttonText.HardcoreIcon.Icon:SetAtlas("Custom-Challenges-Icon-Hardcore")
end

function CharacterSelectButtonMixin:UpdateCharacterInfo()
	local characterID = GetCharIDFromIndex(self:GetID())
	self:SetCharacterInfo(characterID, GetCharacterInfo(characterID))
end

function CharacterSelectButtonMixin:SetCharacterInfo(characterID, name, race, class, level, zone, sex, ghost, PCC, PRC, PFC)
	if self.class ~= class then
		self.classColor = GetClassColorObj(C_CreatureInfo.GetClassInfo(class).classFile)
		self:UpdateNameColor()
	end

	self.characterID = characterID
	self.race = race
	self.class = class
	self.level = level
	self.sex = sex
	self.PCC = PCC
	self.PRC = PRC
	self.PFC = PFC
end

function CharacterSelectButtonMixin:UpdateNameColor()
	self.buttonText.name:SetTextColor(self.classColor.r or 1, self.classColor.g or 1, self.classColor.b or 1)
end

function CharacterSelectButtonMixin:ClearCharacterInfo()
	self.characterID = nil
	self.race = nil
	self.class = nil
	self.level = nil
	self.sex = nil
	self.PCC = nil
	self.PRC = nil
	self.PFC = nil
end

function CharacterSelectButtonMixin:OnShow()
	SetParentFrameLevel(self.PortraitFrame.MailIcon, 1)
end

function CharacterSelectButtonMixin:OnHide()
	self:ClearCharacterInfo()
end

function CharacterSelectButtonMixin:OnEnable()
	self.PortraitFrame.Icon:SetVertexColor(1, 1, 1)
	self.PortraitFrame.LevelFrame.Level:SetTextColor(1, 1, 1)
	self.PortraitFrame.MailIcon:Enable()
	self.buttonText.HardcoreIcon:Enable()

	self:UpdateNameColor()
--	self.buttonText.Info:SetTextColor(1, 1, 1)
	self.buttonText.Location:SetTextColor(0.5, 0.5, 0.5)

	self.PAIDButton:Enable()
	self.PaidZodiacButton:Enable()
	self.PortraitFrame:Enable()
end

function CharacterSelectButtonMixin:OnDisable()
	self:HideMoveButtons()

	self.PortraitFrame.Icon:SetVertexColor(0.3, 0.3, 0.3)
	self.PortraitFrame.LevelFrame.Level:SetTextColor(0.3, 0.3, 0.3)
	self.PortraitFrame.MailIcon:Disable()
	self.buttonText.HardcoreIcon:Disable()

	self.buttonText.name:SetTextColor(0.3, 0.3, 0.3)
--	self.buttonText.Info:SetTextColor(0.3, 0.3, 0.3)
	self.buttonText.Location:SetTextColor(0.3, 0.3, 0.3)

	self.PAIDButton:Disable()
	self.PaidZodiacButton:Disable()
	self.PortraitFrame:Disable()
end

function CharacterSelectButtonMixin:OnMouseDown(button)
	if self:IsEnabled() ~= 1 or button == "RightButton" then
		return
	end

	DRAG_HOLD_BUTTON = self
	DRAG_HOLD_BUTTON_TIME = 0
end

function CharacterSelectButtonMixin:OnMouseUp(button)
	if self:IsEnabled() ~= 1 then
		return
	end
	self:OnDragStop()
end

function CharacterSelectButtonMixin:OnClick(button)
	if button == "RightButton" then
		if C_CharacterList.IsInPlayableMode() and not self:IsInBoostMode() then
			self:GetParent().DropDownMenu:Toggle(self, not self:GetParent().DropDownMenu:IsShown())
		end
	else
		self:GetParent().DropDownMenu:Hide()

		UpdateCharacterSelection()

		local characterIndex = self:GetID()
		CharSelectServicesFlowFrame.selectedCharacterIndex = characterIndex

		if characterIndex ~= CharacterSelect.selectedIndex then
			CharacterSelect_SelectCharacter(characterIndex)
		end
	end
end

function CharacterSelectButtonMixin:OnDoubleClick(button)
	if button == "RightButton" then
		return
	end

	local characterIndex = self:GetID()
	if characterIndex ~= CharacterSelect.selectedIndex then
		CharacterSelect_SelectCharacter(characterIndex)
	end

	CharacterSelect_EnterWorld()
end

function CharacterSelectButtonMixin:OnEnter()
	if self.selection:IsShown() then
		self:ShowMoveButtons()
	end

	if not DRAG_ACTIVE then
		self.buttonText.ItemLevel:Show()
		self.buttonText.Location:Hide()
	end
end

function CharacterSelectButtonMixin:OnLeave()
	for _, button in ipairs(self.serviceButtons) do
		if button:IsMouseOver() then
			return
		end
	end

	if self.upButton:IsShown() and not (self.upButton:IsMouseOver() or self.downButton:IsMouseOver()) then
		self:HideMoveButtons()
	end

	self.buttonText.Location:Show()
	self.buttonText.ItemLevel:Hide()
end

function CharacterSelectButtonMixin:OnDragStart(button)
	if not C_CharacterList.IsInPlayableMode() or CharSelectServicesFlowFrame:IsShown() or CharacterSelect.lockCharacterMove then return end

	if C_CharacterList.GetNumCharactersOnPage() > 1 then
		if not DRAG_ACTIVE then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			DRAG_ACTIVE = true
		end

		DRAG_HOLD_BUTTON = nil
		DRAG_BUTTON_INDEX = self:GetID()
		self:SetScript("OnUpdate", self.OnDragUpdate)
		for index = 1, C_CharacterList.GetNumCharactersPerPage() do
			local charButton = _G["CharSelectCharacterButton"..index]
			if charButton ~= self then
				charButton:SetAlpha(0.6)
			end
		end

		self.PortraitFrame:HideZodiacSign()
		self:HideMoveButtons()
		self:LockHighlight()
		CharacterSelect_CloseDropdowns()
	end
end

function CharacterSelectButtonMixin:OnDragStop()
	if not C_CharacterList.IsInPlayableMode() or CharSelectServicesFlowFrame:IsShown() or CharacterSelect.lockCharacterMove then return end

	if DRAG_ACTIVE then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		DRAG_ACTIVE = false
	end

	DRAG_BUTTON_INDEX = nil
	DRAG_HOLD_BUTTON = nil

	self:OnLeave()
	self:SetScript("OnUpdate", nil)

	local stopIndex
	for index = 1, C_CharacterList.GetNumCharactersPerPage() do
		local button = _G["CharSelectCharacterButton"..index]
		button:SetAlpha(1)
		button:UnlockHighlight()
		button:UpdateMouseOver()

		if C_CharacterList.IsHardcoreCharacter(button.characterID) then
			button.buttonText.HardcoreIcon:SetPoint("TOPLEFT", DEFAULT_HC_ICON_OFFSET_X, DEFAULT_HC_ICON_OFFSET_Y)
		else
			button.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET_X, DEFAULT_TEXT_OFFSET_Y)
		end

		if button.selection:IsShown() or button:IsMouseOver() then
			stopIndex = button:GetID()
		end
	end

	if self:GetID() ~= stopIndex then
		CharacterSelect_SaveCharacterOrder()
	end
end

function CharacterSelectButtonMixin:OnDragUpdate(elapsed)
	if DRAG_ACTIVE then
		local draggedButton = _G["CharSelectCharacterButton"..DRAG_BUTTON_INDEX]
		local _, bottomOffset, _, buttonHeight = draggedButton:GetRect()

		local _, cursorY = GetScaledCursorPosition()
		if cursorY < bottomOffset then
			if DRAG_BUTTON_INDEX < C_CharacterList.GetNumCharactersOnPage() then
				MoveCharacter(DRAG_BUTTON_INDEX, DRAG_BUTTON_INDEX + 1, true)
			end
		elseif cursorY > bottomOffset + buttonHeight then
			if DRAG_BUTTON_INDEX > 1 then
				MoveCharacter(DRAG_BUTTON_INDEX, DRAG_BUTTON_INDEX - 1, true)
			end
		end
	else
		self:OnDragStop()
	end
end

function CharacterSelectButtonMixin:EnableDrag()
	self:SetScript("OnDragStart", self.OnDragStart)
	self:SetScript("OnDragStop", self.OnDragStop)
	self:SetScript("OnMouseUp", self.OnDragStop)
	self:SetScript("OnMouseDown", self.OnMouseDown)
end

function CharacterSelectButtonMixin:DisableDrag()
	self:SetScript("OnDragStart", nil)
	self:SetScript("OnDragStop", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnMouseDown", nil)
end

function CharacterSelectButtonMixin:ShowMoveButtons()
	if not C_CharacterList.IsInPlayableMode() or CharSelectServicesFlowFrame:IsShown() then return end

	if not DRAG_ACTIVE and self.level then
		local characterIndex = self:GetID()
		local characterID = GetCharIDFromIndex(characterIndex)
		local isPendingDK = C_CharacterList.IsCharacterPendingBoostDK(characterID)

		self.serviceButtons[1]:Show()
		self.serviceButtons[2]:SetShown(not isPendingDK)
		self.serviceButtons[3]:SetShown(C_CharacterServices.IsBoostAvailableForLevel(self.level) and not C_CharacterList.IsHardcoreCharacter(characterID))
		self.serviceButtons[3]:SetPoint("RIGHT", isPendingDK and self.serviceButtons[1] or self.serviceButtons[2], "LEFT", -4, 0)

		self.buttonText.Location:Hide()
		self.upButton:Show()
		self.upButton.normalTexture:SetPoint("CENTER", 0, 0)
		self.upButton.highlightTexture:SetPoint("CENTER", 0, 0)
		self.downButton:Show()
		self.downButton.normalTexture:SetPoint("CENTER", 0, 0)
		self.downButton.highlightTexture:SetPoint("CENTER", 0, 0)

		self.FactionEmblem:Hide()

		if characterIndex == 1 then
			self.upButton:Disable()
			self.upButton:SetAlpha(0.35)
		else
			self.upButton:Enable()
			self.upButton:SetAlpha(1)
		end

		if characterIndex == C_CharacterList.GetNumCharactersOnPage() then
			self.downButton:Disable()
			self.downButton:SetAlpha(0.35)
		else
			self.downButton:Enable()
			self.downButton:SetAlpha(1)
		end

		self.buttonText.ItemLevel:Show()
		self.buttonText.Location:Hide()
	end
end

function CharacterSelectButtonMixin:HideMoveButtons()
	self.buttonText.Location:Show()
	self.upButton:Hide()
	self.downButton:Hide()
	self.FactionEmblem:Show()

	for _, serviceButton in ipairs(self.serviceButtons) do
		serviceButton:Hide()
	end

	self.buttonText.Location:Show()
	self.buttonText.ItemLevel:Hide()
end

function CharacterSelectButtonMixin:UpdateMouseOver()
	if self:IsEnabled() == 1 then
		if self.PortraitFrame:IsMouseOver() then
			self.PortraitFrame:OnEnter()
		elseif self:IsMouseOver() then
			self:OnEnter()
		end
	end
end

function CharacterSelectButtonMixin:OnEnterHardcoreIcon(this)
	self:OnEnter()
	GlueTooltip:SetOwner(this)
	GlueTooltip:AddLine(CHARACTER_INFO_HARDCORE_LABEL)
	GlueTooltip:Show()
end

function CharacterSelectButtonMixin:OnLeaveHardcoreIcon(this)
	self:OnLeave()
	GlueTooltip:Hide()
end

function CharacterSelectButtonMixin:SetBoostMode(state, selectable)
	if state then
		self.selection:Hide()
	end

	self.PAIDButton:SetEnabled(not state)
	self.PaidZodiacButton:SetEnabled(not state)
	self.PortraitFrame.MailIcon:SetEnabled(not state)

	self.Arrow:SetShown(state and selectable)

	self.inBoostMode = state
end

function CharacterSelectButtonMixin:IsInBoostMode()
	return self.inBoostMode
end

local itemLevelColors = {
	[1] = CreateColor(0.65882, 0.65882, 0.65882),
	[2] = CreateColor(0.08235, 0.70196, 0),
	[3] = CreateColor(0, 0.56863, 0.94902),
	[4] = CreateColor(0.78431, 0.27059, 0.98039),
	[5] = CreateColor(1, 0.50196, 0),
	[6] = CreateColor(1, 0, 0),
}
local function getItemLevelColor(itemLevel)
	if WithinRange(itemLevel, 0, 100) then
		return itemLevelColors[1]
	elseif WithinRange(itemLevel, 100, 150) then
		return itemLevelColors[1]
	elseif WithinRange(itemLevel, 150, 185) then
		return itemLevelColors[2]
	elseif WithinRange(itemLevel, 185, 200) then
		return itemLevelColors[3]
	elseif WithinRange(itemLevel, 200, 277) then
		return itemLevelColors[4]
	elseif WithinRange(itemLevel, 277, 296) then
		return itemLevelColors[5]
	else
		return itemLevelColors[6]
	end
end

function CharacterSelectButtonMixin:UpdateCharData()
	self.PortraitFrame.MailIcon:SetShown(C_CharacterList.GetCharacterMailCount(self.characterID) > 0)

	if C_CharacterList.IsHardcoreCharacter(self.characterID) then
		self.buttonText.HardcoreIcon:Show()
		self.buttonText.name:ClearAllPoints()
		self.buttonText.name:SetPoint("LEFT", self.buttonText.HardcoreIcon, "RIGHT", -2, -1)
	else
		self.buttonText.HardcoreIcon:Hide()
		self.buttonText.name:ClearAllPoints()
		self.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET_X, DEFAULT_TEXT_OFFSET_Y)
	end

	local itemLevel = C_CharacterList.GetCharacterItemLevel(self.characterID)
	local itemLevelShown

	local color = getItemLevelColor(itemLevel)
	self.buttonText.ItemLevel:SetFormattedText("%s |c%s%i|r", CHARACTER_ITEM_LEVEL, color:GenerateHexColor(), itemLevel)

	if C_CharacterList.CanCharacterChangeZodiac(self.characterID) then
		self.PaidZodiacButton:Show()
		self.PaidZodiacButton:UpdateIcon(4)
	else
		self.PaidZodiacButton:Hide()
	end

	local zodiacSignRaceID = C_CharacterList.GetCharacterZodiacRaceID(self.characterID)
	if zodiacSignRaceID and zodiacSignRaceID ~= 0 then
		local zodiacRaceID, name, description, icon, atlas = C_ZodiacSign.GetZodiacSignInfo(zodiacSignRaceID)
		self.PortraitFrame.ZodiacSign.name = name
		self.PortraitFrame.ZodiacSign:SetAtlas(atlas)
	else
		self.PortraitFrame.ZodiacSign.name = nil
		self.PortraitFrame:HideZodiacSign()
	end

	if not DRAG_ACTIVE then
		local isMouseOver = self:IsMouseOver()
		self.buttonText.Location:SetShown(not isMouseOver)
		self.buttonText.ItemLevel:SetShown(isMouseOver)
	end
end

function CharacterSelectButtonMixin:UpdateFaction()
	if not self.race then
		return
	end

	local raceInfo = C_CreatureInfo.GetRaceInfo(self.race)

	local factionInfo = C_CreatureInfo.GetFactionInfo(self.race)
	local factionID = factionInfo.factionID
	local factionGroup

	if FACTION_OVERRIDE[self.characterID] then
		factionGroup = SERVER_PLAYER_FACTION_GROUP[FACTION_OVERRIDE[self.characterID]]
	else
		factionGroup = factionInfo.groupTag
	end

	local factionColor = PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionGroup]]

	self.PortraitFrame.Border:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.PortraitFrame.FactionBorder:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.PortraitFrame.LevelFrame.Border:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.selection:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.PAIDButton:SetColor(factionColor.r, factionColor.g, factionColor.b)
	self.PaidZodiacButton:SetColor(factionColor.r, factionColor.g, factionColor.b)

	local raceAtlas = string.format("RACE_ICON_%s_%s_%s", string.upper(raceInfo.clientFileString), E_SEX[self.sex or 0], string.upper(factionGroup))
	self.PortraitFrame.Icon:SetAtlas(S_ATLAS_STORAGE[raceAtlas] and raceAtlas or "RACE_ICON_HUMAN_MALE_HORDE")

	if factionID == PLAYER_FACTION_GROUP.Horde then
		self.PortraitFrame.Icon:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
	end

	local atlasTag

	if factionGroup ~= "Neutral" then
		atlasTag = factionGroup
	elseif raceInfo.raceID == E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL then
		atlasTag = "Vulpera"
	elseif raceInfo.raceID == E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL then
		atlasTag = "Pandaren"
	elseif raceInfo.raceID == E_CHARACTER_RACES.RACE_DRACTHYR then
		atlasTag = "Dracthyr"
	end

	if atlasTag then
		self.FactionEmblem:SetAtlas(string.format("CharacterSelect-FactionIcon-%s", atlasTag))
		self.FactionEmblem:Show()
	else
		self.FactionEmblem:Hide()
	end
end

function CharacterSelectButtonMixin:UpdatePaidServicerID()
	if self.PFC then
		self.PAIDButton:SetPAID(E_PAID_SERVICE.CHANGE_FACTION)
	elseif self.PRC then
		self.PAIDButton:SetPAID(E_PAID_SERVICE.CHANGE_RACE)
	elseif self.PCC then
		self.PAIDButton:SetPAID(E_PAID_SERVICE.CUSTOMIZATION)
	else
		self.PAIDButton:Hide()
	end
end

CharacterSelectButtonPortraitMixin = {}

function CharacterSelectButtonPortraitMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterForDrag("LeftButton")
end

function CharacterSelectButtonPortraitMixin:OnDisable()
	self:HideZodiacSign()
end

function CharacterSelectButtonPortraitMixin:OnEnter()
	if not DRAG_ACTIVE then
		if self.ZodiacSign.name then
			self.Icon:Hide()
			self.ZodiacBackground:Show()
			self.ZodiacSign:Show()

			GlueTooltip:SetOwner(self, "ANCHOR_LEFT")
			GlueTooltip:AddLine(self.ZodiacSign.name)
			GlueTooltip:Show()
		end
	end
end

function CharacterSelectButtonPortraitMixin:OnLeave()
	GlueTooltip:Hide()
	self.Icon:Show()
	self.ZodiacBackground:Hide()
	self.ZodiacSign:Hide()
end

function CharacterSelectButtonPortraitMixin:HideZodiacSign()
	if self:IsMouseOver() then
		GlueTooltip:Hide()
		self.Icon:Show()
		self.ZodiacBackground:Hide()
		self.ZodiacSign:Hide()
	end
end

CharacterSelectButtonMailMixin = {}

function CharacterSelectButtonMailMixin:OnLoad()
	self.charButton = self:GetParent():GetParent()
end

function CharacterSelectButtonMailMixin:OnEnter()
	self.charButton:OnEnter()

	GlueTooltip:SetOwner(self)
	GlueTooltip:SetText(string.format(UNREAD_MAILS, C_CharacterList.GetCharacterMailCount(GetCharIDFromIndex(self.charButton:GetID()))))
	GlueTooltip:Show()
end

function CharacterSelectButtonMailMixin:OnLeave()
	GlueTooltip:Hide()
	self.charButton:OnLeave()
end

function CharacterSelectButtonMailMixin:OnEnable()
	self.Icon:SetVertexColor(1, 1, 1)
end

function CharacterSelectButtonMailMixin:OnDisable()
	self.Icon:SetVertexColor(0.5, 0.5, 0.5)
end

CharacterSelectButtonDropDownMenuMixin = {}

function CharacterSelectButtonDropDownMenuMixin:OnLoad()
	self.buttonSettings = {
		{
			icon = "CharacterSelect-Service-Fix-Normal",
			text = CHARACTER_SELECT_FIX_CHARACTER_BUTTON,
			func = function(this, owner)
				CharacterSelect_FixCharacter(owner:GetID())
			end
		},
		{
			icon = "CharacterSelect-Service-Delete-Normal",
			text = DELETE_CHARACTER,
			func = function(this, owner)
				CharacterSelect_Delete(owner:GetID())
			end
		},
		{
			icon = "CharacterSelect-Service-Boost-Normal",
			text = CHARACTER_SERVICES_BUYBOOST,
			func = function(this, owner)
				CharacterSelect_OpenBoost(owner:GetID())
			end
		},
	}

	self.buttonsPool = CreateFramePool("Button", self, "CharacterSelectButtonDropDownMenuButtonTemplate")
end

function CharacterSelectButtonDropDownMenuMixin:Toggle( owner, show )
	if self.owner ~= owner then
		self.owner = owner
		show = true
	end

	if show then
		self:UpdateButtons()
		self:ClearAllPoints()

		if owner.index == C_CharacterList.GetNumCharactersPerPage() then
			self:SetPoint("BOTTOMRIGHT", owner, "BOTTOMLEFT", -10, 0)
		else
			self:SetPoint("RIGHT", owner, "LEFT", -10, 0)
		end
	end

	self:SetShown(show)
end

function CharacterSelectButtonDropDownMenuMixin:UpdateButtons()
	local BUTTON_HEIGHT = 30
	local BUTTON_OFFSET_Y = -6

	local previous

	self.buttonsPool:ReleaseAll()

	for index, settings in ipairs(self.buttonSettings) do
		local skipOption
		if (index == 1 and C_CharacterList.IsCharacterPendingBoostDK(GetCharIDFromIndex(self.owner:GetID())))
		or (index == 3 and not (self.owner.level and C_CharacterServices.IsBoostAvailableForLevel(self.owner.level) and not C_CharacterList.IsHardcoreCharacter(GetCharIDFromIndex(self.owner:GetID()))))
		then
			skipOption = true
		end

		if not skipOption then
			local button = self.buttonsPool:Acquire()

			if not previous then
				button:SetPoint("TOP", 0, 0)
			else
				button:SetPoint("TOP", previous, "BOTTOM", 0, BUTTON_OFFSET_Y)
			end

			button.Text:SetText(settings.text)
			button.Icon:SetAtlas(settings.icon)
			button.clickFunc = settings.func
			button:Show()

			previous = button
		end
	end

	local numButtons = self.buttonsPool:GetNumActive()
	self:SetHeight(numButtons * BUTTON_HEIGHT + (numButtons - 1) * -BUTTON_OFFSET_Y)
end

CharacterSelectButtonDropDownMenuButtonMixin = {}

function CharacterSelectButtonDropDownMenuButtonMixin:OnLoad()
	self.NormalTexture:SetAtlas("UI-Frame-jailerstower-PendingButton")
	self.HighlightTexture:SetAtlas("UI-Frame-jailerstower-PendingButtonHighlight")
end

function CharacterSelectButtonDropDownMenuButtonMixin:OnClick()
	if self.clickFunc then
		self.clickFunc(self, self:GetParent().owner)
	end

	self:GetParent():Hide()
end

CharacterSelectServiceButtonMixin = {}

function CharacterSelectServiceButtonMixin:OnLoad()
	self.normalTextureAtlas = self:GetAttribute("normalTextureAtlas")
	self.pushedTextureAtlas = self:GetAttribute("pushedTextureAtlas")
	self.highlightTextureAtlas = self:GetAttribute("highlightTextureAtlas")

	self.NormalTexture:SetAtlas(self.normalTextureAtlas)
	self.PushedTexture:SetAtlas(self.pushedTextureAtlas)
	self.HighlightTexture:SetAtlas(self.highlightTextureAtlas)

	self:SetParentArray("serviceButtons")
end

function CharacterSelectServiceButtonMixin:OnClick()
	local id = self:GetID()
	local parent = self:GetParent()
	if id == 1 then
		CharacterSelect_FixCharacter(parent:GetID())
	elseif id == 2 then
		CharacterSelect_Delete(parent:GetID())
	elseif id == 3 then
		CharacterSelect_OpenBoost(parent:GetID())
	end

	CharacterSelect_CloseDropdowns()
	parent:HideMoveButtons()
	parent.buttonText.Location:Show()
	parent.buttonText.ItemLevel:Hide()
end

function CharacterSelectServiceButtonMixin:OnShow()
	CharacterSelect.serviceButtonDelay = SERVICE_BUTTON_ACTIVATION_DELAY
	self:EnableMouse(false)
end

function CharacterSelectServiceButtonMixin:OnHide()
	CharacterSelect.serviceButtonDelay = nil
end

CharSelectPageShadowButtonTemplateMixin = {}

function CharSelectPageShadowButtonTemplateMixin:OnLoad()
	self.normalTextureH = self:GetAttribute("normalTextureSizeH")
	self.normalTextureW = self:GetAttribute("normalTextureSizeW")
	self.pushedTextureAtlas = self:GetAttribute("pushedTextureAtlas")

	self.PushedTexture:SetAtlas(self.pushedTextureAtlas)
	self.PushedTexture:SetSize(self.normalTextureH, self.normalTextureW)
end