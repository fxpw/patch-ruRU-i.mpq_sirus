--	Filename:	CharacterSelect.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

CHARACTER_SELECT_ROTATION_START_X = nil;
CHARACTER_SELECT_INITIAL_FACING = nil;

CHARACTER_ROTATION_CONSTANT = 0.6;

MAX_CHARACTERS_DISPLAYED = 10;
MAX_CHARACTERS_PER_REALM = 10;

DEFAULT_TEXT_OFFSET_X = 4
DEFAULT_TEXT_OFFSET_Y = 0

MOVING_TEXT_OFFSET_X = 12
MOVING_TEXT_OFFSET_Y = 0

CHARACTER_BUTTON_HEIGHT = 64
CHARACTER_LIST_TOP = 680
AUTO_DRAG_TIME = 0.5

BOOST_MAX_LEVEL = 80

translationTable = {}
translationServerCache = {}

CHARACTER_SELECT_LIST = {
	queued		= {},
	characters	= {page = 1, numPages = 1},
	deleted		= {page = 1, numPages = 0},
}
CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.characters

FACTION_OVERRIDE = {}
CHAR_SERVICES_DATA = {}

CHAR_DATA_TYPE = {
	FORCE_CUSTOMIZATION = 1,
	MAIL_COUNT = 2,
	ITEM_LEVEL = 3,
}

local SERVICE_BUTTON_ACTIVATION_DELAY = 0.400
local AWAIT_FIX_CHAR_INDEX

local SERVER_LOG = {
	DEFAULT = "ServerGameLogo-11",
	[SHARED_NELTHARION_REALM_NAME] = "ServerGameLogo-2",
	[SHARED_FROSTMOURNE_REALM_NAME] = "ServerGameLogo-3",
	[SHARED_SIRUS_REALM_NAME] = "ServerGameLogo-11",
	[SHARED_SCOURGE_REALM_NAME] = "ServerGameLogo-12",
	[SHARED_ALGALON_REALM_NAME] = "ServerGameLogo-13",
}

for serverName, logo in pairs(SERVER_LOG) do
	SERVER_LOG[string.format("Proxy %s", serverName)] = logo
end

function IsCharacterSelectInUndeleteMode()
	return CHARACTER_SELECT_LIST.current == CHARACTER_SELECT_LIST.deleted
end

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

	C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestBoostStatus)

	self.ServiceLoad = true

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

	Hook:RegisterCallback("CharacterSelect", "SERVICE_DATA_RECEIVED", function()
		local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")

		if forceChangeFactionEvent and forceChangeFactionEvent == -1 then
			GlueDialog:HideDialog("SERVER_WAITING")
		end
	end)
end

function CharacterSelect_OnShow()
	AccountLoginConnectionErrorFrame:Hide()

	table.wipe(FACTION_OVERRIDE)
	table.wipe(CHAR_SERVICES_DATA)

	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	ReadyForAccountDataTimes()
	GlueDialog:HideDialog("SERVER_WAITING")
	CharSelectServicesFlowFrame:Hide()
	CharacterBoostBuyFrame:Hide()
	-- CharacterSelect.ServiceLoad = true
	CharacterSelect.AutoEnterWorld = false

	local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")
	local isNeedShowDialogWaitData = (forceChangeFactionEvent and forceChangeFactionEvent == -1) and not C_Service:GetAccountID()

	if isNeedShowDialogWaitData then
		GlueDialog:ShowDialog("SERVER_WAITING")
	else
		GlueDialog:HideDialog("SERVER_WAITING")
	end

	if #translationTable == 0 then
        for i = 1, 10 do
            table.insert(translationTable, i <= GetNumCharacters() and i or 0)
        end
    end

	UpdateAddonButton();

	CharacterSelect_UpdateRealmButton()

	if IsConnectedToServer() then
		GetCharacterListUpdate();
	else
		UpdateCharacterList();
	end

	-- Gameroom billing stuff (For Korea and China only)
	if ( SHOW_GAMEROOM_BILLING_FRAME ) then
		local paymentPlan, hasFallBackBillingMethod, isGameRoom = GetBillingPlan();
		if ( paymentPlan == 0 ) then
			-- No payment plan
			GameRoomBillingFrame:Hide();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", CharacterSelectLogo, "BOTTOM", 0, -5);
		else
			local billingTimeLeft = GetBillingTimeRemaining();
			-- Set default text for the payment plan
			local billingText = _G["BILLING_TEXT"..paymentPlan];
			if ( paymentPlan == 1 ) then
				-- Recurring account
				billingTimeLeft = ceil(billingTimeLeft/(60 * 24));
				if ( billingTimeLeft == 1 ) then
					billingText = BILLING_TIME_LEFT_LAST_DAY;
				end
			elseif ( paymentPlan == 2 ) then
				-- Free account
				if ( billingTimeLeft < (24 * 60) ) then
					billingText = format(BILLING_FREE_TIME_EXPIRE, billingTimeLeft.." "..MINUTES_ABBR);
				end
			elseif ( paymentPlan == 3 ) then
				-- Fixed but not recurring
				if ( isGameRoom == 1 ) then
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = format(BILLING_FIXED_IGR, MinutesToTime(billingTimeLeft, 1));
					end
				else
					-- personal fixed plan
					if ( billingTimeLeft < (24 * 60) ) then
						billingText = BILLING_FIXED_LASTDAY;
					else
						billingText = format(billingText, MinutesToTime(billingTimeLeft));
					end
				end
			elseif ( paymentPlan == 4 ) then
				-- Usage plan
				if ( isGameRoom == 1 ) then
					-- game room usage plan
					if ( billingTimeLeft <= 600 ) then
						billingText = BILLING_GAMEROOM_EXPIRE;
					else
						billingText = BILLING_IGR_USAGE;
					end
				else
					-- personal usage plan
					if ( billingTimeLeft <= 30 ) then
						billingText = BILLING_TIME_LEFT_30_MINS;
					else
						billingText = format(billingText, billingTimeLeft);
					end
				end
			end
			-- If fallback payment method add a note that says so
			if ( hasFallBackBillingMethod == 1 ) then
				billingText = billingText.."\n\n"..BILLING_HAS_FALLBACK_PAYMENT;
			end
			GameRoomBillingFrameText:SetText(billingText);
			GameRoomBillingFrame:SetHeight(GameRoomBillingFrameText:GetHeight() + 26);
			GameRoomBillingFrame:Show();
			CharacterSelectRealmSplitButton:ClearAllPoints();
			CharacterSelectRealmSplitButton:SetPoint("TOP", GameRoomBillingFrame, "BOTTOM", 0, -10);
		end
	end

	if( IsTrialAccount() ) then
		CharacterSelectUpgradeAccountButton:Show();
	else
		CharacterSelectUpgradeAccountButton:Hide();
	end

	-- fadein the character select ui
	GlueFrameFadeIn(CharacterSelectUI, CHARACTER_SELECT_FADE_IN)

	RealmSplitCurrentChoice:Hide();
	RequestRealmSplitInfo();

	--Clear out the addons selected item
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, ALL);

	CharacterBoostButton:Show()

	CharacterSelectLogoFrameLogo:SetAtlas(SERVER_LOG[GetServerName()] or SERVER_LOG.DEFAULT)

	CharacterSelectCharacterFrame:Hide()
	CharacterSelectLeftPanel:Hide()
	CharacterSelectPlayerNameFrame:Hide()
	CharacterSelectBottomLeftPanel:Hide()
	CharSelectChangeRealmButton:Hide()
	CharSelectChangeListStateButton:Hide()
end

function CharacterSelect_OnHide()
	GlueDialog:HideDialog("ADDON_INVALID_VERSION_DIALOG")
	CharacterSelectCharacterFrame.DropDownMenu:Hide()

	CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.characters

	CharacterUndeleteDialog:Hide()
	CharacterDeleteDialog:Hide();
	CharacterRenameDialog:Hide();
	CharacterFixDialog:Hide()
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

	if self.pressDownButton then
		self.pressDownTime = self.pressDownTime + elapsed
		if self.pressDownTime >= AUTO_DRAG_TIME then
			CharacterSelectButton_OnDragStart(self.pressDownButton)
		end
	end

	if self.serviceButtonDelay then
		self.serviceButtonDelay = self.serviceButtonDelay - elapsed

		if self.serviceButtonDelay <= 0 then
			self.serviceButtonDelay = nil

			local button = CharacterSelectCharacterFrame.characterSelectButtons[self.selectedIndex]
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
				if IsGMAccount() then
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
	if CharacterUndeleteDialog:IsShown()
	or CharSelectServicesFlowFrame:IsShown()
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
		CharacterSelect_EnterWorld();
		CharacterSelectCharacterFrame.DropDownMenu:Hide()
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
		CharacterSelectCharacterFrame.DropDownMenu:Hide()
	elseif ( key == "UP" or key == "LEFT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex > 1 ) then
				CharacterSelect_SelectCharacter(self.selectedIndex - 1);
			else
				CharacterSelect_SelectCharacter(numChars);
			end
		end
	elseif ( key == "DOWN" or key == "RIGHT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex < GetNumCharacters() ) then
				CharacterSelect_SelectCharacter(self.selectedIndex + 1);
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
	local numCharacters = GetNumCharacters()
	local inCharactersView = not IsCharacterSelectInUndeleteMode()

	if not connected then
		CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.characters
		inCharactersView = true
	end

	CharacterSelectLeftPanel.Background:SetShown(inCharactersView and numCharacters > 0)
	CharacterSelectLeftPanel.Background2:SetShown(inCharactersView and numCharacters > 0)
	CharacterSelectLeftPanel.CharacterBoostInfoFrame:SetShown(inCharactersView and numCharacters > 0)
	CharacterBoostButton:SetShown(inCharactersView and numCharacters > 0)
	CharacterSelectOptionsButton:SetShown(inCharactersView)
	CharSelectRestoreButton:SetShown(not inCharactersView)

	if not inCharactersView then
		CharSelectCreateCharacterMiddleButton:Hide()
		CharSelectCreateCharacterButton:Hide()
		CharSelectChangeListStateButton:Hide()

		CharSelectCharacterName:Show()
		CharSelectEnterWorldButton:Hide()
		CharacterSelectAddonsButton:Hide()

		CharacterSelect_UpdateRealmButton()
	else
		CharSelectCreateCharacterMiddleButton:SetShown(connected and numCharacters == 0)
		CharSelectCreateCharacterButton:SetShown(connected and numCharacters > 0)
		CharSelectChangeListStateButton:SetShown(connected)
		CharSelectChangeListStateButton:SetText(CHARACTER_SELECT_UNDELETED_CHARACTER)

		CharSelectCharacterName:SetShown(connected and numCharacters > 0)
		CharSelectEnterWorldButton:SetShown(connected and numCharacters > 0)
		CharacterSelectAddonsButton:SetShown(connected)

		CharSelectChangeRealmButton:Show()
		CharacterSelect_UIShowAnim()
	end

	if CharacterSelect.UndeleteCharacterAlert then
		if CharacterSelect.UndeleteCharacterAlert == 1 then
			GlueDialog:ShowDialog("OKAY", CHARACTER_UNDELETE_ALERT_1)
		else
			GlueDialog:ShowDialog("OKAY", CHARACTER_UNDELETE_ALERT_2)
		end
		CharacterSelect.UndeleteCharacterAlert = nil
	end
end

function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestBoostStatus)
		UpdateAddonButton();
	elseif ( event == "CHARACTER_LIST_UPDATE" ) then
		local numCharacters = GetNumCharacters()

		if numCharacters then
			table.wipe(translationTable)

			for i = 1, 10 do
                table.insert(translationTable, i <= numCharacters and i or 0)
            end

			CharacterSelect.orderChanged = nil
		end

		table.wipe(translationServerCache)

		UpdateCharacterList();
		if CharacterSelect.AutoEnterWorld then
			CharacterSelect_SelectCharacter(CharSelectServicesFlowFrame.CharSelect, CharSelectServicesFlowFrame.CharSelect)
			if self.selectedIndex == CharSelectServicesFlowFrame.CharSelect then
				EnterWorld()
				CharacterSelect.AutoEnterWorld = false
			end
		end

		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterListInfo)
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
					EnterWorld()
				end)
			end

			SetSafeCVar("ForceChangeFactionEvent", -1)
		else
			CharacterSelectUI:Show()
		end
	elseif ( event == "UPDATE_SELECTED_CHARACTER" ) then
		local index = ...;
		if ( index == 0 ) then
			CharSelectCharacterName:SetText("");
		else
			self.selectedIndex = GetIndexFromCharID(index);
		end
		UpdateCharacterSelection(self);
	elseif ( event == "SELECT_LAST_CHARACTER" ) then
		self.selectLast = 1;
	elseif ( event == "SELECT_FIRST_CHARACTER" ) then
		CharacterSelect_SelectCharacter(1, 1);
	elseif ( event == "SUGGEST_REALM" ) then
		local category, id = ...;
		local name = GetRealmInfo(category, id);
		if ( name ) then
			SetGlueScreen("charselect");
			ChangeRealm(category, id);
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
	elseif ( event == "SERVER_SPLIT_NOTICE" ) then
		local msg = select(3, ...)
		local prefix, content = string.match(msg, "([^:]+):(.*)")

		if prefix == "SMSG_DELETED_CHARACTERS_LIST" then
			if content == "OK" then
				if next(CHARACTER_SELECT_LIST.queued) then
					CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.queued.list
					CHARACTER_SELECT_LIST.current.page = CHARACTER_SELECT_LIST.queued.page
				else
					CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.deleted
					CHARACTER_SELECT_LIST.current.page = 1
				end
				GetCharacterListUpdate()
			end

			CHARACTER_SELECT_LIST.queued.list = nil
			CHARACTER_SELECT_LIST.queued.page = nil
		elseif prefix == "SMSG_CHARACTERS_LIST" then
			CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.characters
			GetCharacterListUpdate()
		elseif prefix == "SMSG_CHARACTERS_LIST_INFO" then
			local deletedPages, characterPages, price, listState, currentPage = string.split(":", content)

			CHARACTER_SELECT_LIST.characters.numPages = math.min(tonumber(characterPages), 255)
			CHARACTER_SELECT_LIST.deleted.numPages = math.min(tonumber(deletedPages), 255)

			self.undeletePrice = tonumber(price)

			if next(CHARACTER_SELECT_LIST.queued) then
				CHARACTER_SELECT_LIST.queued.list = nil
				CHARACTER_SELECT_LIST.queued.page = nil
			end

			local stateChanged

			if listState == "1" then
				stateChanged = CHARACTER_SELECT_LIST.current ~= CHARACTER_SELECT_LIST.deleted
				CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.deleted
				CHARACTER_SELECT_LIST.current.page = tonumber(currentPage) or 1
			else
				stateChanged = CHARACTER_SELECT_LIST.current ~= CHARACTER_SELECT_LIST.characters
				CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.characters
				CHARACTER_SELECT_LIST.current.page = tonumber(currentPage) or 1
			end

			if CharacterSelectCharacterFrame:IsShown() ~= 1 and GetNumCharacters() == 0 then
				CharacterSelectCharacterFrame:PlayAnim()
			end

			CharacterSelect_UpdatePageButton()

			if stateChanged then
				UpdateCharacterSelection()
				UpdateCharacterSelectListView()
			end

			GlueDialog:HideDialog("SERVER_WAITING")
		elseif prefix == "SMSG_DELETED_CHARACTER_RESTORE" then
			local undeleteStatus, isRename = strsplit(":", content)
			isRename = isRename ~= nil

			CharacterUndeleteDialog:Hide()

			if undeleteStatus == "OK" then
				GetCharacterListUpdate()
				CharacterSelect.UndeleteCharacterAlert = isRename and 1 or 2
			elseif undeleteStatus == "ANOTHER_OPERATION" then
				GlueDialog:ShowDialog("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_1)
			elseif undeleteStatus == "INVALID_PARAMS" then
				GlueDialog:ShowDialog("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_2)
			elseif undeleteStatus == "MAX_CHARACTERS_REACHED" then
				GlueDialog:ShowDialog("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_3)
			elseif undeleteStatus == "CHARACTER_NOT_FOUND" then
				GlueDialog:ShowDialog("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_4)
			elseif undeleteStatus == "NOT_ENOUGH_BONUSES" then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_UNDELETE_STATUS_5)
			elseif undeleteStatus == "UNIQUE_CLASS_LIMIT" then
				GlueDialog:ShowDialog("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_6)
			end
		elseif prefix == "SMSG_CHARACTER_FIX" then
			GlueDialog:HideDialog("SERVER_WAITING")

			if content == "OK" then
				if AWAIT_FIX_CHAR_INDEX then
					if AWAIT_FIX_CHAR_INDEX ~= CharacterSelect.selectedIndex then
						SelectCharacter(AWAIT_FIX_CHAR_INDEX)
					end
					CharacterSelect_EnterWorld()
					return
				end
			elseif content == "NOT_FOUND" then
				GlueDialog:ShowDialog("OKAY", CHARACTER_FIX_STATUS_2)
			elseif content == "INVALID_PARAMS" then
				GlueDialog:ShowDialog("OKAY", CHARACTER_FIX_STATUS_3)
			end

			AWAIT_FIX_CHAR_INDEX = nil
		elseif prefix == "SMSG_CHARACTERS_ORDER_SAVE" then
			if content == "OK" then
				local numCharacters = GetNumCharacters()
				table.wipe(translationServerCache)

				for i = 1, 10 do
					table.insert(translationServerCache, i <= numCharacters and i or 0)
				end

				CharacterSelect.lockCharacterMove = false
			else
				GetCharacterListUpdate()
				CharacterSelect.lockCharacterMove = false
			end
		elseif prefix == "ASMSG_CHARACTER_OVERRIDE_TEAM" then
			local characterIndex, factionIndex = string.split(":", content)
			FACTION_OVERRIDE[tonumber(characterIndex) + 1] = tonumber(factionIndex)
		elseif prefix == "ASMSG_CHAR_SERVICES" then
			local characterID, forceCustomization, mailCount, itemLevel = string.split(":", content)
			characterID = tonumber(characterID) + 1
			forceCustomization = tonumber(forceCustomization)
			mailCount = tonumber(mailCount)
			itemLevel = tonumber(itemLevel)

			if not CHAR_SERVICES_DATA[characterID] then
				CHAR_SERVICES_DATA[characterID] = {}
			end

			CHAR_SERVICES_DATA[characterID][CHAR_DATA_TYPE.FORCE_CUSTOMIZATION] = forceCustomization or 0
			CHAR_SERVICES_DATA[characterID][CHAR_DATA_TYPE.MAIL_COUNT] = mailCount or 0
			CHAR_SERVICES_DATA[characterID][CHAR_DATA_TYPE.ITEM_LEVEL] = itemLevel or 0

			if CharacterSelectCharacterFrame.characterSelectButtons[characterID] then
				CharacterSelectCharacterFrame.characterSelectButtons[characterID]:UpdateCharData()
			end
		elseif prefix == "ASMSG_ALLIED_RACES" then
			C_CharacterCreation.SetAlliedRacesData(C_Split(content, ":"))
		elseif prefix == "ASMSG_SERVICE_MSG" then
			C_CharacterCreation.SetAlliedRacesData(nil)
		end
	end
end

local function playPanelAnim(f, revers, finishCallback, resetAnimation)
	if (revers and f:IsShown()) or (not revers and not f:IsShown()) then
		f:PlayAnim(revers, finishCallback, resetAnimation)
	end
end

function CharacterSelect_UIShowAnim( revers, finishCallback )
	local numCharacters = GetNumCharacters()

	if numCharacters > 0 then
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
	if not IsCharacterSelectInUndeleteMode() and GetServerName() then
		playPanelAnim(CharSelectChangeRealmButton)
	else
		playPanelAnim(CharSelectChangeRealmButton, true, function()
			CharSelectChangeRealmButton:Hide()
		end, true)
	end
end

function CharacterUndeleteConfirmationButton_OnClick( self, ... )
	if CharacterUndeleteDialog.characterSelect then
		self:Disable()
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.SendCharacterDeletedRestore, CharacterUndeleteDialog.characterSelect)
	else
		error("Unknown CharacterUndeleteDialog.characterSelect for CharacterUndeleteConfirmationButton, contact with Nyll")
	end
end

function CharacterUndeleteDialog_OnShow( self, ... )
	self.BuyButton:Enable()

	if CharacterSelect.undeletePrice == 0 then
		self.MoneyIcon:Hide()
		self.PricePreText:Hide()
		self.Price:SetFontObject("GlueDark_Font_Shadow_15")
		self.Price:SetTextColor(0.72549019607843, 1, 0.54509803921569)
		self.Price:SetText(CHARACTER_UNDELETE_FREE)
	else
		self.MoneyIcon:Show()
		self.PricePreText:Show()
		self.Price:SetFontObject("GlueDark_Font_Shadow_19")
		self.Price:SetTextColor(1, 1, 1)
		self.Price:SetText(CharacterSelect.undeletePrice)
	end

	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER)
end

function CharSelectChangeListState_OnClick(self, button)
	self:Disable()

	if IsCharacterSelectInUndeleteMode() then
		CharacterSelect_Exit()
	else
		CHARACTER_SELECT_LIST.queued.list = CHARACTER_SELECT_LIST.deleted
		CHARACTER_SELECT_LIST.queued.page = 1

		CharSelectCharPageButtonPrev:Disable()
		CharSelectCharPageButtonNext:Disable()

		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, 0)
		GlueDialog:ShowDialog("SERVER_WAITING")
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection()
	CharacterSelectCharacterFrame.DropDownMenu:Hide()

	local button
	for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
		button = _G["CharSelectCharacterButton"..i]
		button.selection:Hide()
		--button.UndeleteButton:Hide()
		button.upButton:Hide()
        button.downButton:Hide()
        button.FactionEmblem:Show()
		if IsCharacterSelectInUndeleteMode() or CharSelectServicesFlowFrame:IsShown() then
            CharacterSelectButton_DisableDrag(button)
        else
            CharacterSelectButton_EnableDrag(button)
        end

		CharacterSelectButton_HideMoveButtons(button)

		if IsCharacterSelectInUndeleteMode() then
			button.PAIDButton:SetPAID(4)
		else
			CharacterSelect_UpdatePAID(i)
		end
	end

	local index = CharacterSelect.selectedIndex;
	if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) ) then
		button = _G["CharSelectCharacterButton"..index]
		if ( button ) then
			button.selection:Show()
			if ( button:IsMouseOver() ) then
				button:OnEnter()
            end
		end
	end
end

function SetFactionEmblem(button, factionInfo, raceInfo, characterID)
	if FACTION_OVERRIDE[characterID] then
		factionInfo = {}
		factionInfo.groupTag = SERVER_PLAYER_FACTION_GROUP[FACTION_OVERRIDE[characterID]]
	end

	local factionEmblem = button.FactionEmblem
	local atlasTag 		= factionInfo.groupTag ~= "Neutral" and factionInfo.groupTag

	if raceInfo and raceInfo.raceID == E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL then
		atlasTag = "Vulpera"
	end

	local _ , race, _, _, _, sex = GetCharacterInfo(characterID)
	local factionColor           = PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionInfo.groupTag]]

	button.PortraitFrame.Border:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	button.PortraitFrame.FactionBorder:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	button.PortraitFrame.LevelFrame.Border:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	button.selection:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	button.PAIDButton:SetColor(factionColor.r, factionColor.g, factionColor.b)

	local raceAtlas = string.format("RACE_ICON_%s_%s_%s", string.upper(raceInfo.clientFileString), E_SEX[sex or 0], string.upper(factionInfo.groupTag))
	if not S_ATLAS_STORAGE[raceAtlas] then
		raceAtlas = "RACE_ICON_HUMAN_MALE_HORDE"
	end

	button.PortraitFrame.Icon:SetAtlas(raceAtlas)

	local _factionInfo = C_CreatureInfo.GetFactionInfo( race )

	if _factionInfo.factionID == PLAYER_FACTION_GROUP.Horde then
		button.PortraitFrame.Icon:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
	end

	if atlasTag then
		factionEmblem:ClearAllPoints()
		factionEmblem:SetPoint("TOPRIGHT", atlasTag ~= "Alliance" and -30 or -26, -18)
		factionEmblem:SetAtlas(string.format("CharacterSelection_%s_Icon", atlasTag), true)
	end
	factionEmblem:SetShown(atlasTag)
end

function CharacterSelect_UpdatePAID(index)
	local _, _, _, _, _, _, _, PCC, PRC, PFC = GetCharacterInfo(GetCharIDFromIndex(index))
	local button = _G["CharSelectCharacterButton"..index]

	if PFC then
		button.PAIDButton:SetPAID(PAID_FACTION_CHANGE)
	elseif PRC then
		button.PAIDButton:SetPAID(PAID_RACE_CHANGE)
	elseif PCC then
		button.PAIDButton:SetPAID(PAID_CHARACTER_CUSTOMIZATION)
	else
		button.PAIDButton:Hide()
	end
end

function UpdateCharacterList( dontUpdateSelect )
	local inDeletedView = IsCharacterSelectInUndeleteMode()
	local numChars = GetNumCharacters();
	local index = 1;

	for i=1, numChars, 1 do
		local name, race, class, level, zone, _, ghost,_ ,_ ,_ = GetCharacterInfo(GetCharIDFromIndex(i));
		local raceInfo                                         = C_CreatureInfo.GetRaceInfo( race )
		local factionInfo                                      = C_CreatureInfo.GetFactionInfo( race )

		local button                                           = _G["CharSelectCharacterButton"..index];
		if ( not name ) then
			button:SetText("ERROR - Tell Jeremy");
		else
			if ( not zone ) then
				zone = "";
			end

			local classInfo = C_CreatureInfo.GetClassInfo(class)

			name = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(name)
			name = inDeletedView and (name .. DELETED) or name
			button.buttonText.name:SetText(name);

			button.PortraitFrame.LevelFrame.Level:SetText(level)

			--if( ghost ) then
			--	_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, class);
			--else
			--	_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO, class);
			--end

			button.buttonText.Location:SetText(zone == "" and UNKNOWN_ZONE or zone);
		end

		SetFactionEmblem(button, factionInfo, raceInfo, GetCharIDFromIndex(i))

		button.charLevel = level
		button.index = i
		button:Show()

		button:UpdateCharData()
		CharacterSelect_UpdatePAID(i)

		index = index + 1;
		if ( index > MAX_CHARACTERS_DISPLAYED ) then
			break;
		end
	end

	CharacterSelect.createIndex = 0;
	CharSelectCreateCharacterButton:Disable();

	local connected = IsConnectedToServer();
	for _ =index, MAX_CHARACTERS_DISPLAYED, 1 do
		local button = _G["CharSelectCharacterButton"..index];
		if ( (CharacterSelect.createIndex == 0) and (numChars < MAX_CHARACTERS_PER_REALM) ) then
			CharacterSelect.createIndex = index;
			if ( connected ) then
				--If can create characters position and show the create button
				CharSelectCreateCharacterButton:SetID(index);
				--CharSelectCreateCharacterButton:SetPoint("TOP", button, "TOP", 0, -5);
				CharSelectCreateCharacterButton:Enable();
			end
		end
		button:Hide();
		index = index + 1;
	end

	if (IsGMAccount() and numChars == MAX_CHARACTERS_PER_REALM) then
		CharacterSelect.createIndex = 0
		CharSelectCreateCharacterButton:SetID(0);
		CharSelectCreateCharacterButton:Enable();
	end

	if ( numChars == 0 ) then
		CharacterSelect.selectedIndex = 0;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
		return;
	end

	if ( CharacterSelect.selectLast == 1 ) then
		CharacterSelect.selectLast = 0;
		CharacterSelect_SelectCharacter(numChars, 1);
		return;
	end

	if ( (CharacterSelect.selectedIndex == 0) or (CharacterSelect.selectedIndex > numChars) ) then
		CharacterSelect.selectedIndex = 1;
	end

	if not dontUpdateSelect then
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
	end
end

function CharacterSelectButton_OnClick(self)
	UpdateCharacterSelection()
	local id = self:GetID();
	CharSelectServicesFlowFrame.CharSelect = id

	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
end

function CharacterSelectButton_OnDoubleClick(self, button)
	if button == "RightButton" then
		return
	end

	local id = self:GetID();
	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
	CharacterSelect_EnterWorld();
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

function OpenCharacterCreate()
	if CharacterSelectBottomLeftPanel and CharacterSelectBottomLeftPanel:IsAnimPlaying() then
		return
	end

	CharacterSelectUI.Background.hideAnim:Play()
	CharacterSelect_UIShowAnim(true, function(this)
		local ghostSelected = CharacterSelect.selectedIndex and select(7, GetCharacterInfo(CharacterSelect.selectedIndex)) == true
		if ghostSelected then
			GlueFFXModel:Hide()
		end

		SetGlueScreen("charcreate")

		if ghostSelected then
			GlueFFXModel:Show()
		end
	end)
end

function CharacterSelect_SelectCharacter(id, noCreate)
	CharacterSelectCharacterFrame.DropDownMenu:Hide()

	if ( id == CharacterSelect.createIndex ) then
		if ( not noCreate ) then
			PlaySound("gsCharacterSelectionCreateNew");
			OpenCharacterCreate()
		end
	else
		id = GetCharIDFromIndex(id)

		local name, race, class = GetCharacterInfo(id)

		if race then
			local RaceInfo 		= C_CreatureInfo.GetRaceInfo(race)
			local FactionInfo 	= C_CreatureInfo.GetFactionInfo(race)
			local ClassInfo 	= C_CreatureInfo.GetClassInfo(class)

			local factionTag 	= FactionInfo.groupTag
			local modelName 	= factionTag

			local facingDeg = 0

			if RaceInfo.raceID == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
				if ClassInfo.classFile == "DEATHKNIGHT" then
					modelName = "Zandalar_DeathKnight"
				elseif FACTION_OVERRIDE[id] == SERVER_PLAYER_FACTION_GROUP.Alliance then
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
			elseif C_CharacterCreation.IsPandarenRace(RaceInfo.raceID) then
				modelName = "Pandaren"
			elseif C_CharacterCreation.IsVulperaRace(RaceInfo.raceID) then
				modelName = "Vulpera"
			elseif FACTION_OVERRIDE[id] then
				if FACTION_OVERRIDE[id] == SERVER_PLAYER_FACTION_GROUP.Horde then
					modelName = "Horde"
				elseif FACTION_OVERRIDE[id] == SERVER_PLAYER_FACTION_GROUP.Alliance then
					modelName = "Alliance"
				end
			end

			name = GetClassColorObj(ClassInfo.classFile):WrapTextInColorCode(name)
			CharSelectCharacterName:SetText(name)

			CharacterModelMixin.SetBackground(CharacterSelect, modelName)

			CharacterSelect.currentModel = GetSelectBackgroundModel(id);

			SelectCharacter(id);

			local forceCharCustomization = tonumber(GetSafeCVar("FORCE_CHAR_CUSTOMIZATION") or "-1")

			if forceCharCustomization and forceCharCustomization ~= -1 then
				PAID_SERVICE_CHARACTER_ID = id

				if PAID_SERVICE_CHARACTER_ID ~= 0 then
					PAID_SERVICE_TYPE = PAID_CHARACTER_CUSTOMIZATION

					C_Timer:After(0.01, function() SetGlueScreen("charcreate") end)
					SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
				end
			end

			if CHAR_SERVICES_DATA[id] and CHAR_SERVICES_DATA[id][CHAR_DATA_TYPE.FORCE_CUSTOMIZATION] == 1 then
				CharSelectEnterWorldButton:SetText("Завершить настройку")
			else
				CharSelectEnterWorldButton:SetText(ENTER_WORLD)
			end
		else
			CharacterModelMixin.SetBackground(CharacterSelect, "Alliance")
		end
	end
end

function CharacterSelect_EnterWorld()
	if IsCharacterSelectInUndeleteMode() or GlueDialog:IsDialogShown("SERVER_WAITING") then return end

	if CharacterSelect.selectedIndex then
		local charID = GetCharIDFromIndex(CharacterSelect.selectedIndex)
		if CHAR_SERVICES_DATA[charID] and CHAR_SERVICES_DATA[charID][CHAR_DATA_TYPE.FORCE_CUSTOMIZATION] == 1 then
			PAID_SERVICE_CHARACTER_ID = charID
			PAID_SERVICE_TYPE = PAID_CHARACTER_CUSTOMIZATION

			SetGlueScreen("charcreate")
			SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
			return
		end
	end

	PlaySound("gsCharacterSelectionEnterWorld");
	StopGlueAmbience();
	if CharSelectServicesFlowFrame:IsShown() then
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD")
	else
		EnterWorld();
	end
end

function CharacterSelect_Exit()
	if GlueDialog:IsDialogShown("SERVER_WAITING") then return end

	if IsCharacterSelectInUndeleteMode() then
		CHARACTER_SELECT_LIST.current = CHARACTER_SELECT_LIST.characters
		CharSelectCharPageButtonPrev:Disable()
		CharSelectCharPageButtonNext:Disable()
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.AnnounceCharacterDeletedLeave)
		GlueDialog:ShowDialog("SERVER_WAITING")
		GetCharacterListUpdate()
	else
		CharacterSelect.lockCharacterMove = false
		PlaySound("gsCharacterSelectionExit");
		if not CharSelectServicesFlowFrame.LockEnterWorld then
			DisconnectFromServer();
			SetGlueScreen("login");
		end
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
	RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
	CharacterSelectCharacterFrame.DropDownMenu:Hide()
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
		CHARACTER_SELECT_INITIAL_FACING = GetCharacterSelectFacing();
	end
end

function CharacterSelectFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_SELECT_ROTATION_START_X = nil
	end
end

function CharacterSelectFrame_OnUpdate()
	if ( CHARACTER_SELECT_ROTATION_START_X ) then
		local x = GetCursorPosition();
		local diff = (x - CHARACTER_SELECT_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT;
		CHARACTER_SELECT_ROTATION_START_X = GetCursorPosition();
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

function CharacterSelect_ManageAccount()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(AUTH_NO_TIME_URL);
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

function CharacterSelect_PaidServiceOnClick(self,_ ,_ ,service)
	PAID_SERVICE_CHARACTER_ID = GetCharIDFromIndex(self:GetID());
	PAID_SERVICE_TYPE = service;
	PlaySound("gsCharacterSelectionCreateNew");
	SetGlueScreen("charcreate");
end

function CharacterSelectButton_HideMoveButtons(self)
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

function CharacterSelectButton_ShowMoveButtons(self)
	if IsCharacterSelectInUndeleteMode() or CharSelectServicesFlowFrame:IsShown() then return end
	local numCharacters = GetNumCharacters()

	if not CharacterSelect.draggedIndex then
		for index, serviceButton in ipairs(self.serviceButtons) do
			if index ~= 3 or (self.charLevel < BOOST_MAX_LEVEL and not CharacterBoostButton.isBoostDisable) then
				serviceButton:Show()
			end
		end

		self.buttonText.Location:Hide()
		self.upButton:Show()
		self.upButton.normalTexture:SetPoint("CENTER", 0, 0)
		self.upButton.highlightTexture:SetPoint("CENTER", 0, 0)
		self.downButton:Show()
		self.downButton.normalTexture:SetPoint("CENTER", 0, 0)
		self.downButton.highlightTexture:SetPoint("CENTER", 0, 0)

		self.FactionEmblem:Hide()

		if self.index == 1 then
			self.upButton:Disable()
			self.upButton:SetAlpha(0.35)
		else
			self.upButton:Enable()
			self.upButton:SetAlpha(1)
		end

		if self.index == numCharacters then
			self.downButton:Disable()
			self.downButton:SetAlpha(0.35)
		else
			self.downButton:Enable()
			self.downButton:SetAlpha(1)
		end

		local charData = CHAR_SERVICES_DATA[GetCharIDFromIndex(self:GetID())]
		if charData and charData[CHAR_DATA_TYPE.ITEM_LEVEL] then
			self.buttonText.ItemLevel:Show()
			self.buttonText.Location:Hide()
		end
	end
end

function CharacterSelectButton_OnDragUpdate(self)
    if not CharacterSelect.draggedIndex then
        CharacterSelectButton_OnDragStop(self)
        return
    end
    local _, cursorY = GetCursorPosition()

    if cursorY <= CHARACTER_LIST_TOP then
        local buttonIndex = floor((CHARACTER_LIST_TOP - cursorY) / CHARACTER_BUTTON_HEIGHT) + 1
        local button = _G["CharSelectCharacterButton"..buttonIndex]

        if button and button.index ~= CharacterSelect.draggedIndex and button:IsShown() then
            if ( button.index > CharacterSelect.draggedIndex ) then
                MoveCharacter(CharacterSelect.draggedIndex, CharacterSelect.draggedIndex + 1, true)
            else
                MoveCharacter(CharacterSelect.draggedIndex, CharacterSelect.draggedIndex - 1, true)
            end
        end
    end
end

function CharacterSelectButton_OnDragStart(self)
	if IsCharacterSelectInUndeleteMode() or CharSelectServicesFlowFrame:IsShown() or CharacterSelect.lockCharacterMove then return end

    if GetNumCharacters() > 1 then
		if not CharacterSelect.draggedIndex then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end

        CharacterSelect.pressDownButton = nil
        CharacterSelect.draggedIndex = self:GetID()
        self:SetScript("OnUpdate", CharacterSelectButton_OnDragUpdate)
        for index = 1, MAX_CHARACTERS_DISPLAYED do
            local button = _G["CharSelectCharacterButton"..index]
            if button ~= self then
                button:SetAlpha(0.6)
            end
        end

        self:LockHighlight()
		CharacterSelectCharacterFrame.DropDownMenu:Hide()
		CharacterSelectButton_HideMoveButtons(self)
    end
end

function CharacterSelectButton_OnDragStop(self)
	if CharacterSelect.draggedIndex then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
	
	local stopIndex
	CharacterSelect.draggedIndex = nil
	CharacterSelect.pressDownButton = nil

    self:SetScript("OnUpdate", nil)
    for index = 1, MAX_CHARACTERS_DISPLAYED do
        local button = _G["CharSelectCharacterButton"..index]
        button:SetAlpha(1)
        button:UnlockHighlight()
		button.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET_X, DEFAULT_TEXT_OFFSET_Y)
        if button:IsMouseOver() then
        	stopIndex = button:GetID()
        end
        if button.selection:IsShown() and button:IsMouseOver() then
        	stopIndex = button:GetID()
			button:OnEnter()
        end
    end

    if self:GetID() ~= stopIndex then
    	CharacterSelect_SaveCharacterOrder()
    end
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
        CharacterSelect.draggedIndex = targetIndex

        local oldButton = _G["CharSelectCharacterButton"..originIndex]
        local currentButton = _G["CharSelectCharacterButton"..targetIndex]

        oldButton:SetAlpha(0.6)
        oldButton:UnlockHighlight()
        oldButton.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET_X, DEFAULT_TEXT_OFFSET_Y)

        currentButton:SetAlpha(1)
        currentButton:LockHighlight()
        currentButton.buttonText.name:SetPoint("TOPLEFT", MOVING_TEXT_OFFSET_X, MOVING_TEXT_OFFSET_Y)
     else
     	CharacterSelect_SaveCharacterOrder()
    end

    UpdateCharacterSelection(CharacterSelect)
    UpdateCharacterList( true )
end

function CharacterSelectButton_DisableDrag(button)
    button:SetScript("OnMouseDown", nil)
    button:SetScript("OnMouseUp", nil)
    button:SetScript("OnDragStart", nil)
    button:SetScript("OnDragStop", nil)
end

function CharacterSelectButton_EnableDrag(button)
    button:SetScript("OnDragStart", CharacterSelectButton_OnDragStart)
    button:SetScript("OnDragStop", CharacterSelectButton_OnDragStop)
    button:SetScript("OnMouseDown", function(self)
        CharacterSelect.pressDownButton = self
        CharacterSelect.pressDownTime = 0
    end)
    button:SetScript("OnMouseUp", CharacterSelectButton_OnDragStop)
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

function CharacterSelect_PrevPage(self, ...)
	local targetPage = CHARACTER_SELECT_LIST.current.page - 1
	if targetPage < 1 then return end

	CHARACTER_SELECT_LIST.queued.list = CHARACTER_SELECT_LIST.current
	CHARACTER_SELECT_LIST.queued.page = targetPage

	GlueDialog:ShowDialog("SERVER_WAITING")

	CharSelectChangeListStateButton:Disable()
	CharSelectCharPageButtonPrev:Disable()
	CharSelectCharPageButtonNext:Disable()

	if IsCharacterSelectInUndeleteMode() then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, 1)
	else
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterList, 1)
	end
end

function CharacterSelect_NextPage(self, ...)
	local targetPage = CHARACTER_SELECT_LIST.current.page + 1
	if targetPage > CHARACTER_SELECT_LIST.current.numPages then return end

	CHARACTER_SELECT_LIST.queued.list = CHARACTER_SELECT_LIST.current
	CHARACTER_SELECT_LIST.queued.page = targetPage

	GlueDialog:ShowDialog("SERVER_WAITING")

	CharSelectChangeListStateButton:Disable()
	CharSelectCharPageButtonPrev:Disable()
	CharSelectCharPageButtonNext:Disable()

	if IsCharacterSelectInUndeleteMode() then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, 2)
	else
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterList, 2)
	end
end

function CharacterSelect_UpdatePageButton()
	CharSelectChangeListStateButton:SetEnabled(IsCharacterSelectInUndeleteMode() and true or CHARACTER_SELECT_LIST.deleted.numPages > 0)
	CharSelectCharPageButtonPrev:SetShown(CHARACTER_SELECT_LIST.current.numPages > 1)
	CharSelectCharPageButtonNext:SetShown(CHARACTER_SELECT_LIST.current.numPages > 1)
	if CHARACTER_SELECT_LIST.current.numPages > 1 then
		CharSelectCharPageButtonPrev:SetEnabled(CHARACTER_SELECT_LIST.current.page > 1)
		CharSelectCharPageButtonNext:SetEnabled(CHARACTER_SELECT_LIST.current.page < CHARACTER_SELECT_LIST.current.numPages)
	end
end

function CharacterSelect_RestoreButton_OnClick()
	if not CharacterUndeleteDialog:IsShown() then
		CharacterUndeleteDialog.characterSelect = CharacterSelect.selectedIndex
		CharacterUndeleteDialog:Show()
	end
end

function CharacterSelect_FixCharacter(characterIndex)
	characterIndex = GetCharIDFromIndex(characterIndex or CharacterSelect.selectedIndex)

	if characterIndex == 0 then
		error("Incorrect characterIndex [%s]", tostring(characterIndex), 2)
	end

	local name, _, class, level = GetCharacterInfo(characterIndex);
	local classInfo = C_CreatureInfo.GetClassInfo(class)
	class = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(class).."|cffFFFFFF"

	CharacterFixDialog.Container.Character:SetFormattedText(CONFIRM_CHAR_DELETE2, name, level, class);

	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER)
	CharacterFixDialog.characterIndex = characterIndex or CharacterSelect.selectedIndex
	CharacterFixDialog:Show()
end

function CharacterSelect_FixCharacter_OnLoad(self)
	self.Container.InfoIcon.InfoHeader = CHARACTER_FIX_HELP_HEAD
	self.Container.InfoIcon.InfoText = CHARACTER_FIX_HELP_TEXT
end

function CharacterSelect_FixCharacter_OnHide(self)
	self.characterIndex = nil
end

function CharacterSelect_FixCharacter_OKButton_OnClick(self)
	local dialog = self:GetParent():GetParent()
	local characterIndex = dialog.characterIndex
	dialog:Hide()
	GlueDialog:ShowDialog("SERVER_WAITING")
	AWAIT_FIX_CHAR_INDEX = characterIndex
	C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.SendCharacterFix, characterIndex)
end

function CharacterSelect_Delete(characterIndex)
	characterIndex = GetCharIDFromIndex(characterIndex or CharacterSelect.selectedIndex)

	if characterIndex == 0 then
		error("Incorrect characterIndex [%s]", tostring(characterIndex), 2)
	end

	local name, _, class, level = GetCharacterInfo(characterIndex);
	local classInfo = C_CreatureInfo.GetClassInfo(class)
	class = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(class).."|cffFFFFFF"

	CharacterDeleteDialog.Container.Character:SetFormattedText(CONFIRM_CHAR_DELETE2, name, level, class);
	CharacterDeleteDialog.Container.OKButton:Disable();
	CharacterDeleteDialog.Container.EditBox:SetText("");

	PlaySound("gsCharacterSelectionDelCharacter");
	CharacterDeleteDialog.characterIndex = characterIndex
	CharacterDeleteDialog:Show();
end

function CharacterDeleteDialog_OnHide(self)
	self.characterIndex = nil
end

function CharacterDeleteDialog_OKButton_OnClick(self)
	local dialog = self:GetParent():GetParent()
	local characterIndex = dialog.characterIndex
	dialog:Hide()
	PlaySound("gsTitleOptionOK");
	DeleteCharacter(characterIndex);
end

function CharacterSelect_OpenBoost(characterIndex)
	characterIndex = GetCharIDFromIndex(characterIndex or CharacterSelect.selectedIndex)

	if characterIndex == 0 then
		error("Incorrect characterIndex [%s]", tostring(characterIndex), 2)
	end

	CharacterSelect.ServiceLoad = false

	C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostStatus)
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)

	if not CharSelectServicesFlowFrame:IsShown() and not CharacterSelect.ServiceLoad and CharacterSelect.AllowService then
		CharSelectServicesFlowFrame:Show()

		local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(characterIndex))
		if level < BOOST_MAX_LEVEL then
			_G["CharSelectCharacterButton"..characterIndex]:Click()
			CharSelectServicesFlowFrame.NextButton:Click()
		end
	elseif not CharacterBoostBuyFrame:IsShown() and not CharacterSelect.ServiceLoad and not CharacterSelect.AllowService then
		CharacterBoostBuyFrame:Show()
	end
end

CharacterSelectPAIDButtonMixin = {}

local PAID_OPTIONS_INFO = {
	{icon = "PAID_CIRCLE_CUSTOMIZE", text = PAID_CHARACTER_CUSTOMIZE_TOOLTIP},
	{icon = "PAID_CIRCLE_RACE", text = PAID_RACE_CHANGE_TOOLTIP},
	{icon = "PAID_CIRCLE_FACTION", text = PAID_FACTION_CHANGE_TOOLTIP},
	{icon = "PAID_CIRCLE_UNDELETE", text = PAID_CHARACTER_RESTORE_TOOLTIP},
}

function CharacterSelectPAIDButtonMixin:OnLoad()
	self.buttonW = self:GetWidth()
	self.buttonH = self:GetHeight()

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

function CharacterSelectPAIDButtonMixin:SetPAID( paID )
	self:SetShown(paID)

	self.paID = paID

	if PAID_OPTIONS_INFO[paID] then
		self.Icon:SetAtlas(PAID_OPTIONS_INFO[paID].icon)
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
	if self.paID == 4 then
		if not CharacterUndeleteDialog:IsShown() then
			CharacterUndeleteDialog.characterSelect = self:GetParent():GetID()
			CharacterUndeleteDialog:Show()
		end
		return
	end

	PAID_SERVICE_CHARACTER_ID = GetCharIDFromIndex(self:GetParent():GetID())
	PAID_SERVICE_TYPE = self.paID

	PlaySound("gsCharacterSelectionCreateNew")
	SetGlueScreen("charcreate")
end

function CharacterSelectPAIDButtonMixin:OnEnter()
	for i = 2, 3 do
		self["Border"..i].HideAnim:Stop()
		self["Border"..i]:Show()

		self["Border"..i].Anim:Play()
		self["Border"..i].ShowAnim:Play()
	end

	if PAID_OPTIONS_INFO[self.paID] then
		GlueTooltip_SetOwner(self, GlueTooltip, 7, -7, "BOTTOMRIGHT", "TOPLEFT")
		GlueTooltip_SetText(PAID_OPTIONS_INFO[self.paID].text, GlueTooltip)
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

CharacterSelectCharacterMixin = {}

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

CharacterSelectLeftPanelMixin = {}

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

CharSelectChangeRealmButtonMixin = {}

function CharSelectChangeRealmButtonMixin:Init()
	self.startPoint = 40
	self.endPoint = -8
	self.duration = 0.500
end

function CharSelectChangeRealmButtonMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("TOP", 0, easing)
	else
		self:ClearAndSetPoint("TOP", 0, self.isRevers and self.startPoint or self.endPoint)
	end
end

CharacterSelectBottomLeftPanelMixin = {}

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

CharacterSelectPlayerNameFrameMixin = {}

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
	self.Background:SetAtlas("jailerstower-animapowerlist-dropdown-closedbg")
	self.selection:SetAtlas("jailerstower-animapowerlist-dropdown-closedbg2")

	self.HighlightTexture:SetAtlas("jailerstower-animapowerlist-dropdown-closedbg")

	self:SetParentArray("characterSelectButtons")

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterForDrag("LeftButton")
end

function CharacterSelectButtonMixin:OnEnable()
	self.PortraitFrame.Icon:SetVertexColor(1, 1, 1)
	self.PortraitFrame.LevelFrame.Level:SetTextColor(1, 1, 1)
	self.PortraitFrame.MailIcon:Enable()

	self.buttonText.name:SetTextColor(1, 0.78, 0)
--	self.buttonText.Info:SetTextColor(1, 1, 1)
	self.buttonText.Location:SetTextColor(0.5, 0.5, 0.5)

	self.PAIDButton:Enable()
end

function CharacterSelectButtonMixin:OnDisable()
	self.PortraitFrame.Icon:SetVertexColor(0.3, 0.3, 0.3)
	self.PortraitFrame.LevelFrame.Level:SetTextColor(0.3, 0.3, 0.31)
	self.PortraitFrame.MailIcon:Disable()

	self.buttonText.name:SetTextColor(0.3, 0.3, 0.31)
--	self.buttonText.Info:SetTextColor(0.3, 0.3, 0.31)
	self.buttonText.Location:SetTextColor(0.3, 0.3, 0.31)

	self.PAIDButton:Disable()
end

function CharacterSelectButtonMixin:OnDragStart()
	CharacterSelectButton_OnDragStart(self)
end

function CharacterSelectButtonMixin:OnDragStop()
	CharacterSelectButton_OnDragStop(self)
end

function CharacterSelectButtonMixin:OnMouseDown( button )
	if button == "RightButton" then
		return
	end

	CharacterSelect.pressDownButton = self
	CharacterSelect.pressDownTime = 0
end

function CharacterSelectButtonMixin:OnMouseUp()
	CharacterSelectButton_OnDragStop(self)
end

function CharacterSelectButtonMixin:OnClick( button )
	if button == "RightButton" then
		if not self:IsInBoostMode() and not IsCharacterSelectInUndeleteMode() then
			self:GetParent().DropDownMenu:Toggle(self, not self:GetParent().DropDownMenu:IsShown())
		end
	else
		self:GetParent().DropDownMenu:Hide()
		CharacterSelectButton_OnClick(self)
	end
end

function CharacterSelectButtonMixin:OnDoubleClick( button )
	CharacterSelectButton_OnDoubleClick( self, button )
end

function CharacterSelectButtonMixin:OnEnter()
	if self.selection:IsShown() then
		CharacterSelectButton_ShowMoveButtons(self)
	end

	self.buttonText.ItemLevel:Show()
	self.buttonText.Location:Hide()
end

function CharacterSelectButtonMixin:OnLeave()
	for _, button in ipairs(self.serviceButtons) do
		if button:IsMouseOver() then
			return
		end
	end

	if self.upButton:IsShown() and not (self.upButton:IsMouseOver() or self.downButton:IsMouseOver()) then
		CharacterSelectButton_HideMoveButtons(self)
	end

	self.buttonText.Location:Show()
	self.buttonText.ItemLevel:Hide()
end

function CharacterSelectButtonMixin:SetBoostMode(state, selectable)
	if state then
		self.selection:Hide()
		self.PAIDButton:Disable()
		self.PortraitFrame.MailIcon:Disable()
	else
		self.PAIDButton:Enable()
		self.PortraitFrame.MailIcon:Enable()
	end

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
	if C_InRange(itemLevel, 0, 100) then
		return itemLevelColors[1]
	elseif C_InRange(itemLevel, 100, 150) then
		return itemLevelColors[1]
	elseif C_InRange(itemLevel, 150, 185) then
		return itemLevelColors[2]
	elseif C_InRange(itemLevel, 185, 200) then
		return itemLevelColors[3]
	elseif C_InRange(itemLevel, 200, 277) then
		return itemLevelColors[4]
	elseif C_InRange(itemLevel, 277, 296) then
		return itemLevelColors[5]
	else
		return itemLevelColors[6]
	end
end

function CharacterSelectButtonMixin:UpdateCharData()
	local charData = CHAR_SERVICES_DATA[GetCharIDFromIndex(self:GetID())]

	self.PortraitFrame.MailIcon:SetShown(charData and charData[CHAR_DATA_TYPE.MAIL_COUNT] and charData[CHAR_DATA_TYPE.MAIL_COUNT] > 0)

	local itemLevelShown

	if charData and charData[CHAR_DATA_TYPE.ITEM_LEVEL] then
		local color = getItemLevelColor(charData[CHAR_DATA_TYPE.ITEM_LEVEL])
		self.buttonText.ItemLevel:SetFormattedText("%s |cff%2x%2x%2x%i", CHARACTER_ITEM_LEVEL, color.r * 255, color.g * 255, color.b * 255, charData[CHAR_DATA_TYPE.ITEM_LEVEL])

		if self:IsMouseOver() then
			self.buttonText.Location:Hide()
			self.buttonText.ItemLevel:Show()
			itemLevelShown = true
		end
	end

	if not itemLevelShown then
		self.buttonText.Location:Show()
		self.buttonText.ItemLevel:Hide()
	end
end

CharacterSelectButtonMailMixin = {}

function CharacterSelectButtonMailMixin:OnLoad()
	self.charButton = self:GetParent():GetParent()
end

function CharacterSelectButtonMailMixin:OnEnter()
	self.charButton:OnEnter()

	local charData = CHAR_SERVICES_DATA[GetCharIDFromIndex(self.charButton:GetID())]
	GlueTooltip_SetOwner(self, GlueTooltip, 0, 0, "BOTTOMRIGHT", "TOPLEFT")
	GlueTooltip_SetText(string.format(UNREAD_MAILS, charData[CHAR_DATA_TYPE.MAIL_COUNT]), GlueTooltip)
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
			text = "Исправление персонажа",
			func = function(this, owner)
				CharacterSelect_FixCharacter(owner:GetID())
			end
		},
		{
			icon = "CharacterSelect-Service-Delete-Normal",
			text = "Удаление персонажа",
			func = function(this, owner)
				CharacterSelect_Delete(owner:GetID())
			end
		},
		{
			icon = "CharacterSelect-Service-Boost-Normal",
			text = "Быстрый старт",
			func = function(this, owner)
				CharacterSelect_OpenBoost(owner:GetID())
			end
		},
	}

	self.buttonsPool = CreateFramePool("Button", self, "CharacterSelectButtonDropDownMenuButtonTemplate")
end

function CharacterSelectButtonDropDownMenuMixin:Toggle( owner, toggle )
	if owner ~= self.owner then
		self:Hide()
		toggle = true
	end

	self.owner = owner

	if toggle then
		self:ClearAllPoints()
		if owner.index == MAX_CHARACTERS_DISPLAYED then
			self:SetPoint("BOTTOMRIGHT", owner, "BOTTOMLEFT", -10, 0)
		else
			self:SetPoint("RIGHT", owner, "LEFT", -10, 0)
		end
	end

	self:SetShown(toggle)
end

function CharacterSelectButtonDropDownMenuMixin:OnShow()
	local showBoostButton = self.owner.charLevel < BOOST_MAX_LEVEL and not CharacterBoostButton.isBoostDisable
	local previous

	for index, settings in pairs(self.buttonSettings) do
		local button = self.buttonsPool:Acquire()

		if index == 1 then
			button:SetPoint("TOP", 0, 0)
		else
			button:SetPoint("TOP", previous, "BOTTOM", 0, -6)
		end

		button.Text:SetText(settings.text)
		button.Icon:SetAtlas(settings.icon)
		button.clickFunc = settings.func

		previous = button

		button:SetShown(index ~= 3 or showBoostButton)
	end

	self:SetHeight(showBoostButton and 102 or 66)
end

function CharacterSelectButtonDropDownMenuMixin:OnHide()
	self.buttonsPool:ReleaseAll()
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

	CharacterSelectButton_HideMoveButtons(parent)
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