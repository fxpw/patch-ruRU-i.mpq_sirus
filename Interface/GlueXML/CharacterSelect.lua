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

MOVING_TEXT_OFFSET = 12
DEFAULT_TEXT_OFFSET = 0
CHARACTER_BUTTON_HEIGHT = 56
CHARACTER_LIST_TOP = 690
AUTO_DRAG_TIME = 0.5

translationTable = {}
translationServerCache = {}

local messagesQueue = {}
local messageTimer = 0

function AddPacketMessage(str, ...)
    local temp = {} ;
    temp[1] = str;
    temp[2] = ...;
    table.insert(messagesQueue, temp)
end

function CharacterSelect_SaveCharacterOrder()
    if CharacterSelect.orderChanged and not CharacterSelect.lockCharacterMove then
    	CharacterSelect.lockCharacterMove = true

    	local cache = translationTable

    	if #translationServerCache > 0 then
    		cache = translationServerCache
    	end

       	SendPacket("001", unpack(cache))
    end
end


function CharacterSelect_OnLoad(self)
	if inRealmScourge() then
		AddPacketMessage("0")
	end

	self.forceCustomizationData = {}

	self:SetSequence(0);
	self:SetCamera(0);
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

	SetCharSelectModelFrame("CharacterSelect");

	self.overrideData = {}
    
    self.undeleteCurrentPage = 1

	Hook:RegisterCallback("CharacterSelect", "SERVICE_DATA_RECEIVED", function()
		local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")

		if forceChangeFactionEvent and forceChangeFactionEvent == -1 then
			WaitingDialogFrame:Hide()
		end
	end)
end

function CharacterSelect_OnShow()
	AccountLoginConnectionErrorFrame:Hide()

	CharacterSelect.overrideData = {}

	if not inRealmScourge() then
		-- C_SendOpcode(CMSG_SIRUS_BOOST_STATUS)
	end

	-- request account data times from the server (so we know if we should refresh keybindings, etc...)
	ReadyForAccountDataTimes()
	WaitingDialogFrame:Hide()
	CharSelectServicesFlowFrame:Hide()
	CharacterBoostBuyFrame:Hide()
	-- CharacterSelect.ServiceLoad = true
	CharacterSelect.AutoEnterWorld = false

	local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")
	local isNeedShowDialogWaitData = (forceChangeFactionEvent and forceChangeFactionEvent == -1) and not C_Service:GetAccountID()

	if isNeedShowDialogWaitData then
		WaitingDialogFrame:Show()
		WaitingDialogFrame.Text:SetText(SERVER_WAITING_DATA)
	else
		WaitingDialogFrame:Hide()
	end

	if #translationTable == 0 then
        for i = 1, 10 do
            table.insert(translationTable, i <= GetNumCharacters() and i or 0)
        end
    end

	UpdateAddonButton();

	local serverName, isPVP, isRP = GetServerName();
	local connected = IsConnectedToServer();
	local serverType = "";
	if ( serverName ) then
		if( not connected ) then
			serverName = serverName.."\n("..SERVER_DOWN..")";
		end
		if ( isPVP ) then
			if ( isRP ) then
				serverType = RPPVP_PARENTHESES;
			else
				serverType = PVP_PARENTHESES;
			end
		elseif ( isRP ) then
			serverType = RP_PARENTHESES;
		end
		CharSelectRealmName:SetText(serverName.." "..serverType);
		CharSelectRealmName:Show();
	else
		CharSelectRealmName:Hide();
	end

	if ( connected ) then
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
	CharacterBoostInfoFrame:Hide()

	if serverName == SHARED_SIRUS_REALM_NAME then
		CharacterSelectLogoFrameLogo:SetAtlas("ServerGameLogo-1")
	elseif serverName == SHARED_SCOURGE_REALM_NAME then
		CharacterSelectLogoFrameLogo:SetAtlas("ServerGameLogo-3")
	elseif serverName == SHARED_FROSTMOURNE_REALM_NAME then
		CharacterSelectLogoFrameLogo:SetAtlas("ServerGameLogo-3")
	elseif serverName == SHARED_NELTHARION_REALM_NAME then
		CharacterSelectLogoFrameLogo:SetAtlas("ServerGameLogo-2")
	elseif serverName == SHARED_ALGALON_REALM_NAME then
		CharacterSelectLogoFrameLogo:SetAtlas("ServerGameLogo-4")
	else
		CharacterSelectLogoFrameLogo:SetAtlas("ServerGameLogo-3")
	end
end

function CharacterSelect_OnHide()
	CharacterUndeleteWindow:Hide()
	CharacterDeleteDialog:Hide();
	CharacterRenameDialog:Hide();
	if ( DeclensionFrame ) then
		DeclensionFrame:Hide();
	end
	SERVER_SPLIT_STATE_PENDING = -1;

    SetSafeCVar("ForceChangeFactionEvent", -1)
	SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
end

function CharacterSelect_OnUpdate(elapsed)
	if ( CharacterSelect.pressDownButton ) then
		CharacterSelect.pressDownTime = CharacterSelect.pressDownTime + elapsed
		if ( CharacterSelect.pressDownTime >= AUTO_DRAG_TIME ) then
			CharacterSelectButton_OnDragStart(CharacterSelect.pressDownButton)
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
				GlueDialog_Show("SERVER_SPLIT_WITH_CHOICE", dialogString);
			else
				GlueDialog_Show("SERVER_SPLIT", dialogString);
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
				GlueDialog_Show("ACCOUNT_MSG", dialogString);
			end
		end
	end

	if (#messagesQueue > 0) then
		if messageTimer <= GetTime() then
			local message = table.remove(messagesQueue, 1)
			SendPacket(message[1], message[2]);
			messageTimer = GetTime() + 0.1
		end
	end

    local factionEvent = GetSafeCVar("ForceChangeFactionEvent")
	if not GlueDialog:IsShown() and not GlueParent.dontShowInvalidVersionAddonDialog and (not factionEvent or factionEvent ~= 1) then
		if AddonList_HasNewVersion() then
			GlueDialog_Show("ADDON_INVALID_VERSION_DIALOG")
		end
	end
end

function CharacterSelect_OnKeyDown(self,key)
	if CharacterUndeleteWindow:IsShown() then return end
	if CharSelectServicesFlowFrame:IsShown() then return end
	if WaitingDialogFrame:IsShown() then return end
	if ( key == "ESCAPE" ) then
		CharacterSelect_Exit();
	elseif ( key == "ENTER" ) then
		CharacterSelect_EnterWorld();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	elseif ( key == "UP" or key == "LEFT" ) then
		local numChars = GetNumCharacters();
		if ( numChars > 1 ) then
			if ( self.selectedIndex > 1 ) then
				CharacterSelect_SelectCharacter(self.selectedIndex - 1);
			else
				CharacterSelect_SelectCharacter(numChars);
			end
		end
	elseif ( arg1 == "DOWN" or arg1 == "RIGHT" ) then
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

function CharacterSelect_OnEvent(self, event, ...)
	if ( event == "ADDON_LIST_UPDATE" ) then
		if inRealmScourge() then
			AddPacketMessage("0")
		end
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
		CharSelectCharacterName:SetText(GetCharacterInfo(GetCharIDFromIndex(self.selectedIndex)));
		if CharacterSelect.AutoEnterWorld then
			CharacterSelect_SelectCharacter(CharSelectServicesFlowFrame.CharSelect, CharSelectServicesFlowFrame.CharSelect)
			if self.selectedIndex == CharSelectServicesFlowFrame.CharSelect then
				EnterWorld()
				CharacterSelect.AutoEnterWorld = false
			end
		end

		if self.deletedLock then
			CharSelectCreateCharacterButton:Hide()
			CharSelectUndeleteCharacterButton:Hide()
			CharSelectChangeRealmButton:Hide()

			CharSelectUndeleteLabel:Show()
			CharSelectUndeleteCharacterCancelButton:Show()

			CharSelectEnterWorldButton:Disable()
			CharSelectFixButton:Disable()
			CharacterSelectAddonsButton:Disable()
			CharacterSelectBackButton:Disable()
			CharacterSelectDeleteButton:Disable()
			CharacterBoostButton:Disable()
		else
			if inRealmScourge() then
				AddPacketMessage("01")
			else
				-- C_SendOpcode(CMSG_SIRUS_DELETED_CHARACTER_INFO)
			end

			CharSelectCreateCharacterButton:Show()
			CharSelectUndeleteCharacterButton:Show()
			CharSelectChangeRealmButton:Show()

			CharSelectUndeleteLabel:Hide()
			CharSelectUndeleteCharacterCancelButton:Hide()

			CharSelectEnterWorldButton:SetEnabled(numCharacters > 0)
			CharSelectFixButton:SetEnabled(numCharacters > 0)
			CharacterSelectAddonsButton:Enable()
			CharacterSelectBackButton:Enable()
			CharacterSelectDeleteButton:SetEnabled(numCharacters > 0)
			CharacterBoostButton:SetEnabled(numCharacters > 0)

			for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
				button = _G["CharSelectCharacterButton"..i]
				if button then
					button.UndeleteButton:Hide()
				end
			end
		end

		if CharacterSelect.UndeleteCharacterAlert then
			if CharacterSelect.UndeleteCharacterAlert == 1 then
				GlueDialog_Show("OKAY", CHARACTER_UNDELETE_ALERT_1)
			else
				GlueDialog_Show("OKAY", CHARACTER_UNDELETE_ALERT_2)
			end
			CharacterSelect.UndeleteCharacterAlert = nil
		end
		UpdateCharacterSelection()

		local forceChangeFactionEvent = tonumber(GetSafeCVar("ForceChangeFactionEvent") or "-1")

		if forceChangeFactionEvent and forceChangeFactionEvent ~= -1 then
			local factionText = E_FORCE_CHANGE_FACTION_TEXT[forceChangeFactionEvent]

			if factionText then
				CharacterSelectUI:Hide()
				WaitingDialogFrame:Show()

				WaitingDialogFrame.Text:SetText(factionText)

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
			CharSelectCharacterName:SetText(GetCharacterInfo(index));
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
		CharacterRenameText1:SetText(_G[message]);
	elseif ( event == "SERVER_SPLIT_NOTICE" ) then
		local msg = select(3, ...)
		local prefix, content = string.match(msg, "(.-):(.*)")

		if prefix == "SMSG_DELETED_CHARACTERS_LIST" then
			self.deletedLock = true

			GetCharacterListUpdate()
        elseif  prefix == "SMSG_CHARACTERS_LIST" then
			GetCharacterListUpdate()
		elseif prefix == "SMSG_CHARACTERS_LIST_INFO" then
			local deletedCount, characterCount, price = strsplit(":", content)

			self.undeleteCurrentPage = 1
			self.undeletePrice = tonumber(price)
			self.undeleteMaxPage = min(tonumber(deletedCount), 255)
			self.charactersMaxPage = min(tonumber(characterCount), 255)
			CharSelectUndeleteCharacterButton:SetEnabled(self.undeleteMaxPage > 0)

            if CharacterSelect.charactersMaxPage > 1 then
                CharSelectUndeleteNextPageButton:Show()
                CharSelectUndeletePrevPageButton:Show()
            else
                CharSelectUndeleteNextPageButton:Hide()
                CharSelectUndeletePrevPageButton:Hide()
            end
		elseif prefix == "SMSG_DELETED_CHARACTER_RESTORE" then
			local undeleteStatus, isRename = strsplit(":", content)
			isRename = isset(isRename)

			CharacterUndeleteConfirmationFrame:Hide()

			if undeleteStatus == "OK" then
				GetCharacterListUpdate()
				CharacterSelect.UndeleteCharacterAlert = isRename and 1 or 2
			elseif undeleteStatus == "ANOTHER_OPERATION" then
				GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_1)
			elseif undeleteStatus == "INVALID_PARAMS" then
				GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_2)
			elseif undeleteStatus == "MAX_CHARACTERS_REACHED" then
				GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_3)
			elseif undeleteStatus == "CHARACTER_NOT_FOUND" then
				GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_4)
			elseif undeleteStatus == "NOT_ENOUGH_BONUSES" then
				GlueDialog_Show("OKAY_HTML", CHARACTER_UNDELETE_STATUS_5)
			elseif undeleteStatus == "UNIQUE_CLASS_LIMIT" then
				GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_UNDELETE_STATUS_6)
			end
		elseif prefix == "SMSG_CHARACTER_FIX" then
			WaitingDialogFrame:Hide()
			if content == "OK" then
				CharacterSelect_EnterWorld()
			elseif content == "NOT_FOUND" then
				GlueDialog_Show("OKAY", CHARACTER_FIX_STATUS_2)
			elseif content == "INVALID_PARAMS" then
				GlueDialog_Show("OKAY", CHARACTER_FIX_STATUS_3)
			end
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
			local overrideData 	= C_Split(content, ":")
			self.overrideData[tonumber(overrideData[1]) + 1] = tonumber(overrideData[2])
		elseif prefix == "ASMSG_CHAR_SERVICES" then
			local contentStorage = C_Split(content, ",")

			CharacterSelect.forceCustomizationData = {}

			for _, contentData in pairs(contentStorage) do
				local data = C_Split(contentData, ":")

				if data[1] and data[2] then
					CharacterSelect.forceCustomizationData[tonumber(data[1]) + 1] = tonumber(data[2])
				end
			end
		elseif prefix == "ASMSG_ALLIED_RACES" then
			local contentStorage = C_Split(content, ":")

			for _, data in pairs(contentStorage) do
				CharacterCreate.alliedRacesUnlock[tonumber(data)] = true
			end
		elseif prefix == "ASMSG_SERVICE_MSG" then
			CharacterCreate.alliedRacesUnlock = {}
			CharacterSelect.forceCustomizationData = {}
		end
	end
end

function CharacterUndeleteConfirmationButton_OnClick( self, ... )
	if CharacterSelect.selectedIndex then
		self:Disable()
		if inRealmScourge() then
			AddPacketMessage("10", CharacterSelect.selectedIndex)
		else
			-- C_SendOpcode(CMSG_SIRUS_DELETED_CHARACTER_RESTORE, CharacterSelect.selectedIndex)
		end
	else
		error("Unknown CharacterSelect.selectedIndex for CharacterUndeleteConfirmationButton, contact with Nyll")
	end
end

function CharacterUndeleteConfirmationFrame_OnShow( self, ... )
	self.BuyButton:Enable()

	self.NoticeFrame.MoneyIcon:SetShown(CharacterSelect.undeletePrice ~= 0)
	self.NoticeFrame.TotalLabel:SetShown(CharacterSelect.undeletePrice ~= 0)

	if CharacterSelect.undeletePrice == 0 then
		self.NoticeFrame.Price:ClearAllPoints()
		self.NoticeFrame.Price:SetPoint("BOTTOM", 0, 26)
		self.NoticeFrame.Price:SetFontObject("Shared_GameFontNormalLarge")
		self.NoticeFrame.Price:SetTextColor(0, 1, 0)
	else
		self.NoticeFrame.Price:ClearAllPoints()
		self.NoticeFrame.Price:SetPoint("BOTTOMRIGHT", -50, 20)
		self.NoticeFrame.Price:SetFontObject("GameFontNormalShadowHuge2")
		self.NoticeFrame.Price:SetTextColor(1.0, 0.82, 0)
	end

	self.NoticeFrame.Price:SetText(CharacterSelect.undeletePrice == 0 and CHARACTER_UNDELETE_FREE or CharacterSelect.undeletePrice)
end

function CharacterSelectUndeleteButton_OnEnter( self, ... )
	GlueTooltip_SetOwner(self, nil, nil, nil, nil, "TOPLEFT")
	GlueTooltip_SetText(CHARACTER_UNDELETE, GlueTooltip, 1.0, 1.0, 1.0)
end

function CharSelectUndeleteCharacterButton_OnEnter( self, ... )
	GlueTooltip_SetOwner(self)

	if self:IsEnabled() ~= 0 then
		self.Highlight:Show()
		GlueTooltip_SetText(CHARACTER_UNDELETE, GlueTooltip, 1.0, 1.0, 1.0)
	else
		GlueTooltip_SetText(CHARACTER_UNDELETE_NOT_CHARACTER, GlueTooltip, 1.0, 1.0, 1.0)
	end
end

function CharSelectUndeleteCharacterButton_OnClick( self, ... )
	if inRealmScourge() then
		AddPacketMessage("11", 0)
	else
		-- C_SendOpcode(CMSG_SIRUS_DELETED_CHARACTER_LIST)
	end
end

function CharacterSelect_UpdateModel(self)
	UpdateSelectionCustomizationScene();
	self:AdvanceTime();
end

function UpdateCharacterSelection(self)
	local button
	for i=1, MAX_CHARACTERS_DISPLAYED, 1 do
		button = _G["CharSelectCharacterButton"..i]
		button.selection:Hide()
		button.UndeleteButton:Hide()
		button.upButton:Hide()
		button.CharacterFixButton:Hide()
        button.downButton:Hide()
        button.FactionEmblem:Show()
        if (CharSelectUndeleteCharacterCancelButton:IsShown() or CharacterSelect.deletedLock) or CharSelectServicesFlowFrame:IsShown() then
            CharacterSelectButton_DisableDrag(button)
        else
            CharacterSelectButton_EnableDrag(button)
        end
	end

	local index = CharacterSelect.selectedIndex;
	if ( (index > 0) and (index <= MAX_CHARACTERS_DISPLAYED) ) then
		button = _G["CharSelectCharacterButton"..index]
		if ( button ) then
			button.selection:Show()
			if ( button:IsMouseOver() ) then
                CharacterSelectButton_ShowMoveButtons(button)
            end
			if CharSelectUndeleteCharacterCancelButton:IsShown() or CharacterSelect.deletedLock then
				button.UndeleteButton:Show()
			end
		end
	end
end

function SetFactionEmblem(button, factionInfo, raceInfo, characterID)
	if CharacterSelect.overrideData[characterID] then
		factionInfo = {}
		factionInfo.groupTag = SERVER_PLAYER_FACTION_GROUP[CharacterSelect.overrideData[characterID]]
	end

	local factionEmblem = button.FactionEmblem
	local atlasTag 		= factionInfo.groupTag ~= "Neutral" and factionInfo.groupTag

	if raceInfo and raceInfo.raceID == E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL then
		atlasTag = "Vulpera"
	end

	if atlasTag then
		factionEmblem:ClearAllPoints()
		factionEmblem:SetPoint("TOPRIGHT", atlasTag ~= "Alliance" and -49 or -46, -8)
		factionEmblem:SetAtlas(string.format("CharacterSelection_%s_Icon", atlasTag), true)
	end
	factionEmblem:SetShown(atlasTag)
end

function UpdateCharacterList()
	local numChars = GetNumCharacters();
	local index = 1;
	local coords;
	for i=1, numChars, 1 do
		local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(GetCharIDFromIndex(i));
		local raceInfo 		= C_CreatureInfo.GetRaceInfo( race )
		local factionInfo 	= C_CreatureInfo.GetFactionInfo( race )

		local button = _G["CharSelectCharacterButton"..index];
		if ( not name ) then
			button:SetText("ERROR - Tell Jeremy");
		else
			if ( not zone ) then
				zone = "";
			end

			local classInfo = C_CreatureInfo.GetClassInfo(class)

			class = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(class)

			name = CharacterSelect.deletedLock and name.. DELETED or name

			_G["CharSelectCharacterButton"..index.."ButtonTextName"]:SetText(name);
			if( ghost ) then
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO_GHOST, level, class);
			else
				_G["CharSelectCharacterButton"..index.."ButtonTextInfo"]:SetFormattedText(CHARACTER_SELECT_INFO, level, class);
			end
			_G["CharSelectCharacterButton"..index.."ButtonTextLocation"]:SetText(zone);
		end

		SetFactionEmblem(button, factionInfo, raceInfo, GetCharIDFromIndex(i))

		button.index = i
		button:Show()

		-- setup paid service buttons
		_G["CharSelectCharacterCustomize"..index]:Hide();
		_G["CharSelectRaceChange"..index]:Hide();
		_G["CharSelectFactionChange"..index]:Hide();
		if ( PFC ) then
			_G["CharSelectFactionChange"..index]:Show();
		elseif ( PRC ) then
			_G["CharSelectRaceChange"..index]:Show();
		elseif ( PCC ) then
			local charID = GetCharIDFromIndex(i)
			_G["CharSelectCharacterCustomize"..index]:SetShown(CharacterSelect.forceCustomizationData[charID] ~= 1);
		end

		button.selection:SetVertexColor(1, 1, 1, 0.40)

		index = index + 1;
		if ( index > MAX_CHARACTERS_DISPLAYED ) then
			break;
		end
	end

	CharacterSelect.createIndex = 0;
	CharSelectCreateCharacterButton:Disable();

	local connected = IsConnectedToServer();
	for i=index, MAX_CHARACTERS_DISPLAYED, 1 do
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
		_G["CharSelectCharacterCustomize"..index]:Hide();
		_G["CharSelectFactionChange"..index]:Hide();
		_G["CharSelectRaceChange"..index]:Hide();
		button:Hide();
		index = index + 1;
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
    
    if (IsGMAccount() and numChars == MAX_CHARACTERS_PER_REALM) then
        CharacterSelect.createIndex = 0
        --If can create characters position and show the create button
        CharSelectCreateCharacterButton:SetID(0);
        --CharSelectCreateCharacterButton:SetPoint("TOP", button, "TOP", 0, -5);
        CharSelectCreateCharacterButton:Enable();
    end

	CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);
end

function CharacterSelectButton_OnClick(self)
	UpdateCharacterSelection()
	local id = self:GetID();
	CharSelectServicesFlowFrame.CharSelect = id

	if ( id ~= CharacterSelect.selectedIndex ) then
		CharacterSelect_SelectCharacter(id);
	end
end

function CharacterSelectButton_OnDoubleClick(self)
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

function CharacterSelect_SetBackgroundModel( modelName )
	SetCharSelectBackground("Interface\\GLUES\\Models\\UI_BLOODELF\\UI_BLOODELF.m2")

	CharacterSelect:SetCamera(0)
	SetCharSelectBackground(string.formatx("Interface\\GLUES\\Models\\UI_$1\\UI_$1.m2", modelName))

	local cameraSettings = CHARACTER_SELECT_CAMERA_SETTINGS[modelName]

	assert(cameraSettings, "CharacterSelect_SelectCharacter: не найдены настройки камеры для модели "..modelName)

	CharacterSelect:SetPosition(unpack(cameraSettings))

	local lightSettings = CHARACTER_CREATE_MODEL_LIGHT[modelName]

	assert(lightSettings, "C_CharacterCreation.SetBackgroundModel: Не найдены настройки света для модели "..modelName)

	CharacterSelect:ResetLights()

	for _, func in pairs({CharacterSelect.AddCharacterLight, CharacterSelect.AddLight, CharacterSelect.AddPetLight}) do
		func(CharacterSelect, LIGHT_LIVE, 1, 0, unpack(lightSettings))
	end
end

function CharacterSelect_SelectCharacter(id, noCreate)
	if ( id == CharacterSelect.createIndex ) then
		if ( not noCreate ) then
			PlaySound("gsCharacterSelectionCreateNew");
			SetGlueScreen("charcreate");
		end
	else
		id = GetCharIDFromIndex(id)

		local _, race, class = GetCharacterInfo(id)

		if race then
			local RaceInfo 		= C_CreatureInfo.GetRaceInfo(race)
			local FactionInfo 	= C_CreatureInfo.GetFactionInfo(race)
			local ClassInfo 	= C_CreatureInfo.GetClassInfo(class)

			local factionTag 	= FactionInfo.groupTag
			local modelName 	= factionTag

			if ClassInfo.classFile == "DEATHKNIGHT" then
				modelName = "DeathKnight"
			elseif isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) then
				modelName = "Vulpera"
				C_Timer:After(0.01, function() SetCharacterSelectFacing(-215) end)
			elseif isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_PANDAREN_HORDE, E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE) then
				modelName = "Pandaren"
			end

			if (isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) and classFileName == "DEATHKNIGHT") or not isOneOf(RaceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) then
				C_Timer:After(0.01, function() SetCharacterSelectFacing(0) end)
			end

			CharacterSelect_SetBackgroundModel(modelName)

			CharacterSelect.currentModel = GetSelectBackgroundModel(id);

			SelectCharacter(id);

			local forceCharCustomization = tonumber(GetSafeCVar("FORCE_CHAR_CUSTOMIZATION") or "-1")

			if forceCharCustomization and forceCharCustomization ~= -1 then
				PAID_SERVICE_CHARACTER_ID = id

				if PAID_SERVICE_CHARACTER_ID ~= 0 then
					PAID_SERVICE_TYPE = PAID_CHARACTER_CUSTOMIZATION
					CharacterCreateFrame.forceCustomization = true

					C_Timer:After(0.01, function() SetGlueScreen("charcreate") end)
					SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
				end
			end

			if CharacterSelect.forceCustomizationData[id] == 1 then
				CharSelectEnterWorldButton:SetText("Завершить настройку")
			else
				CharSelectEnterWorldButton:SetText(ENTER_WORLD)
			end
		else
			CharacterSelect_SetBackgroundModel("Alliance")
		end
	end
end

function CharacterDeleteDialog_OnShow()
	local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(CharacterSelect.selectedIndex));
	local classInfo = C_CreatureInfo.GetClassInfo(class)

	class = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(class).."|cffFFFFFF"

	CharacterDeleteText1:SetFormattedText(CONFIRM_CHAR_DELETE, name, level, class);
	CharacterDeleteBackground:SetHeight(16 + CharacterDeleteText1:GetHeight() + CharacterDeleteText2:GetHeight() + 23 + CharacterDeleteEditBox:GetHeight() + 8 + CharacterDeleteButton1:GetHeight() + 16);
	CharacterDeleteButton1:Disable();
end

function CharacterSelect_EnterWorld()
	if CharSelectUndeleteCharacterCancelButton:IsShown() then return end
	if WaitingDialogFrame:IsShown() then return end

	if CharacterSelect.selectedIndex then
		local charID = GetCharIDFromIndex(CharacterSelect.selectedIndex)
		if CharacterSelect.forceCustomizationData[charID] == 1 then
			PAID_SERVICE_CHARACTER_ID = charID
			PAID_SERVICE_TYPE = PAID_CHARACTER_CUSTOMIZATION
			CharacterCreateFrame.forceCustomization = true

			SetGlueScreen("charcreate")
			SetSafeCVar("FORCE_CHAR_CUSTOMIZATION", -1)
			return
		end
	end

	PlaySound("gsCharacterSelectionEnterWorld");
	StopGlueAmbience();
	if CharSelectServicesFlowFrame:IsShown() then
		GlueDialog_Show("LOCK_BOOST_ENTER_WORLD")
	else
		EnterWorld();
	end
end

function CharacterSelect_Exit()
	CharacterSelect.lockCharacterMove = false
	if WaitingDialogFrame:IsShown() then return end
	PlaySound("gsCharacterSelectionExit");
	if not CharSelectServicesFlowFrame.LockEnterWorld then
		DisconnectFromServer();
		SetGlueScreen("login");
	end
end

function CharacterSelect_AccountOptions()
	PlaySound("gsCharacterSelectionAcctOptions");
end

function CharacterSelect_TechSupport()
	PlaySound("gsCharacterSelectionAcctOptions");
	LaunchURL(TECH_SUPPORT_URL);
end

function CharacterSelect_Delete()
	PlaySound("gsCharacterSelectionDelCharacter");
	if ( CharacterSelect.selectedIndex > 0 ) then
		CharacterDeleteDialog:Show();
	end
end

function CharacterSelect_ChangeRealm()
	PlaySound("gsCharacterSelectionDelCharacter");
	RequestRealmList(1);
end

function CharacterSelectFrame_OnMouseDown(button)
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

function CharacterSelect_PaidServiceOnClick(self, button, down, service)
	PAID_SERVICE_CHARACTER_ID = GetCharIDFromIndex(self:GetID());
	PAID_SERVICE_TYPE = service;
	PlaySound("gsCharacterSelectionCreateNew");
	SetGlueScreen("charcreate");
end

function CharacterSelectButton_HideMoveButtons( self )
	self.upButton:Hide()
	self.downButton:Hide()
	self.CharacterFixButton:Hide()
	self.FactionEmblem:Show()
end

function CharacterSelectButton_ShowMoveButtons(button)
    if (CharSelectUndeleteCharacterCancelButton:IsShown() or CharacterSelect.deletedLock) or CharSelectServicesFlowFrame:IsShown() then return end
    local numCharacters = GetNumCharacters()

    if not CharacterSelect.draggedIndex then
        button.upButton:Show()
        button.upButton.normalTexture:SetPoint("CENTER", 0, 0)
        button.upButton.highlightTexture:SetPoint("CENTER", 0, 0)
        button.downButton:Show()
        button.downButton.normalTexture:SetPoint("CENTER", 0, 0)
        button.downButton.highlightTexture:SetPoint("CENTER", 0, 0)

        button.CharacterFixButton:Show()
        button.FactionEmblem:Hide()

        if button.index == 1 then
            button.upButton:Disable()
            button.upButton:SetAlpha(0.35)
        else
            button.upButton:Enable()
            button.upButton:SetAlpha(1)
        end

        if button.index == numCharacters then
            button.downButton:Disable()
            button.downButton:SetAlpha(0.35)
        else
            button.downButton:Enable()
            button.downButton:SetAlpha(1)
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
	if (CharSelectUndeleteCharacterCancelButton:IsShown() or CharacterSelect.deletedLock) or CharSelectServicesFlowFrame:IsShown() or CharacterSelect.lockCharacterMove then return end

    if GetNumCharacters() > 1 then
        CharacterSelect.pressDownButton = nil
        CharacterSelect.draggedIndex = self:GetID()
        self:SetScript("OnUpdate", CharacterSelectButton_OnDragUpdate)
        for index = 1, MAX_CHARACTERS_DISPLAYED do
            local button = _G["CharSelectCharacterButton"..index]
            if button ~= self then
                button:SetAlpha(0.6)
            end
        end
        self.buttonText.name:SetPoint("TOPLEFT", MOVING_TEXT_OFFSET, -5)
        self:LockHighlight()
        self.upButton:Hide()
        self.downButton:Hide()

        self.CharacterFixButton:Hide()
        self.FactionEmblem:Show()
    end
end

function CharacterSelectButton_OnDragStop(self)
	local stopIndex
	CharacterSelect.draggedIndex = nil
	CharacterSelect.pressDownButton = nil

    self:SetScript("OnUpdate", nil)
    for index = 1, MAX_CHARACTERS_DISPLAYED do
        local button = _G["CharSelectCharacterButton"..index]
        button:SetAlpha(1)
        button:UnlockHighlight()
        button.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET, -5)
        if button:IsMouseOver() then
        	stopIndex = button:GetID()
        end
        if button.selection:IsShown() and button:IsMouseOver() then
        	stopIndex = button:GetID()
            CharacterSelectButton_ShowMoveButtons(button)
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
        oldButton.buttonText.name:SetPoint("TOPLEFT", DEFAULT_TEXT_OFFSET, -5)

        currentButton:SetAlpha(1)
        currentButton:LockHighlight()
        currentButton.buttonText.name:SetPoint("TOPLEFT", MOVING_TEXT_OFFSET, -5)
     else
     	CharacterSelect_SaveCharacterOrder()
    end

    UpdateCharacterSelection(CharacterSelect)
    UpdateCharacterList()
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

function CharacterUndelete_PrevPage( self, ... )
	CharacterSelect.undeleteCurrentPage = CharacterSelect.undeleteCurrentPage - 1
    
    if CharacterSelect.deletedLock == true then
        AddPacketMessage("11", 1)
    else
        AddPacketMessage("100", 1)
    end
	CharacterUndelete_UpdatePageButton()
end

function CharacterUndelete_NextPage( self, ... )
	CharacterSelect.undeleteCurrentPage = CharacterSelect.undeleteCurrentPage + 1

    if CharacterSelect.deletedLock == true then
        AddPacketMessage("11", 2)
    else
        AddPacketMessage("100", 2)
    end
	CharacterUndelete_UpdatePageButton()
end

function CharacterUndelete_UpdatePageButton()
    if CharacterSelect.deletedLock == true then
        CharSelectUndeleteNextPageButton:SetEnabled(CharacterSelect.undeleteMaxPage and (CharacterSelect.undeleteCurrentPage < CharacterSelect.undeleteMaxPage))
        CharSelectUndeletePrevPageButton:SetEnabled(CharacterSelect.undeleteCurrentPage > 1)
    else
        CharSelectUndeleteNextPageButton:SetEnabled(CharacterSelect.charactersMaxPage and (CharacterSelect.undeleteCurrentPage < CharacterSelect.charactersMaxPage))
        CharSelectUndeletePrevPageButton:SetEnabled(CharacterSelect.undeleteCurrentPage > 1)
    end
end

function EventHandler:SMSG_SIRUS_DELETED_CHARACTER_INFO( present, price )
	CharSelectUndeleteCharacterButton:SetEnabled(present == 1)
	CharacterSelect.undeletePrice = price
end

function EventHandler:SMSG_SIRUS_DELETED_CHARACTER_LIST( status )
	CharacterSelect.deletedLock = true
	GetCharacterListUpdate()
end

function EventHandler:SMSG_SIRUS_CHARACTER_LIST( status )
	GetCharacterListUpdate()
end

function EventHandler:SMSG_SIRUS_DELETED_CHARACTER_RESTORE( status )
	local isRename = status == 1

	CharacterUndeleteConfirmationFrame:Hide()

	if status == 0 then
		GetCharacterListUpdate()
		CharacterSelect.UndeleteCharacterAlert = isRename and 1 or 2
	elseif status == 1 then
		GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_DELETE_RESTORE_ERROR_1)
	elseif status == 2 then
		GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_DELETE_RESTORE_ERROR_2)
	elseif status == 3 then
		GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_DELETE_RESTORE_ERROR_3)
	elseif status == 4 then
		GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_DELETE_RESTORE_ERROR_4)
	elseif status == 5 then
		GlueDialog_Show("OKAY_HTML", CHARACTER_DELETE_RESTORE_ERROR_5)
	elseif status == 6 then
		GlueDialog_Show("CLIENT_RESTART_ALERT", CHARACTER_DELETE_RESTORE_ERROR_6)
	end
end