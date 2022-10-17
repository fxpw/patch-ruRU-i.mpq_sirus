MAX_NUM_GLUE_DIALOG_BUTTONS = 3;

GlueDialogTypes = { };

GlueDialogTypes["SYSTEM_INCOMPATIBLE_SSE"] = {
	text = SYSTEM_INCOMPATIBLE_SSE,
	button1 = OKAY,
	html = 1,
	showAlert = 1,
	escapeHides = true,
	OnAccept = function ()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CANCEL_RESET_SETTINGS"] = {
	text = CANCEL_RESET_SETTINGS,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function ()
		AccountLoginUIResetFrame:Hide();
		-- Switch the reset settings button back to reset mode
		OptionsSelectResetSettingsButton:SetText(RESET_SETTINGS);
		OptionsSelectResetSettingsButton:SetScript("OnClick", OptionsSelectResetSettingsButton_OnClick_Reset);
		SetClearConfigData(false);
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["RESET_SERVER_SETTINGS"] = {
	text = RESET_SERVER_SETTINGS,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function ()
		AccountLoginUIResetFrame:Show();
		-- Switch the reset settings button to cancel mode
		OptionsSelectResetSettingsButton:SetText(CANCEL_RESET);
		OptionsSelectResetSettingsButton:SetScript("OnClick", OptionsSelectResetSettingsButton_OnClick_Cancel);
		SetClearConfigData(true);
	end,
	OnCancel = function ()
	end,
}

GlueDialogTypes["CONFIRM_RESET_VIDEO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button2 = CURRENT_SETTINGS,
	button3 = CANCEL,
	showAlert = 1,
	OnAccept = function ()
		VideoOptionsFrame_SetAllToDefaults();
	end,
	OnCancel = function ()
		VideoOptionsFrame_SetCurrentToDefaults();
	end,
	OnAlt = function() end,
	escapeHides = true,
}

GlueDialogTypes["CONFIRM_RESET_AUDIO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button2 = CURRENT_SETTINGS,
	button3 = CANCEL,
	showAlert = 1,
	OnAccept = function ()
		AudioOptionsFrame_SetAllToDefaults();
	end,
	OnCancel = function ()
		AudioOptionsFrame_SetCurrentToDefaults();
	end,
	OnAlt = function() end,
	escapeHides = true,
}

GlueDialogTypes["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
}

GlueDialogTypes["REALM_IS_FULL"] = {
	text = REALM_IS_FULL_WARNING,
	button1 = YES,
	button2 = NO,
	showAlert = 1,
	OnAccept = function()
		SetGlueScreen("charselect");
		ChangeRealm(RealmList.selectedCategory , RealmList.currentRealm);
	end,
	OnCancel = function()
		CharacterSelect_ChangeRealm();
	end,
}

GlueDialogTypes["SUGGEST_REALM"] = {
	text = format(SUGGESTED_REALM_TEXT,"UNKNOWN REALM"),
	button1 = ACCEPT,
	button2 = VIEW_ALL_REALMS,
	OnShow = function()
		GlueDialogText:SetFormattedText(SUGGESTED_REALM_TEXT, RealmWizard.suggestedRealmName);
	end,
	OnAccept = function()
		SetGlueScreen("charselect");
		ChangeRealm(RealmWizard.suggestedCategory, RealmWizard.suggestedID);
	end,
	OnCancel = function()
		SetGlueScreen("charselect");
		CharacterSelect_ChangeRealm();
	end,
}

GlueDialogTypes["DISCONNECTED"] = {
	text = DISCONNECTED,
	button1 = OKAY,
	button2 = nil,
	OnShow = function()
		RealmList:Hide();
		SecurityMatrixLoginFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["PARENTAL_CONTROL"] = {
	text = AUTH_PARENTAL_CONTROL,
	button1 = MANAGE_ACCOUNT,
	button2 = OKAY,
	OnShow = function()
		RealmList:Hide();
		SecurityMatrixLoginFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
		LaunchURL(AUTH_NO_TIME_URL);
	end,
	OnCancel = function()
		StatusDialogClick();
	end,
}

GlueDialogTypes["INVALID_NAME"] = {
	text = CHAR_CREATE_INVALID_NAME,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CANCEL"] = {
	text = "",
	button1 = CANCEL,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["QUEUED_WITH_FCM"] = {
	text = "",
	button1 = CANCEL,
	button2 = QUEUE_FCM_BUTTON,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
		LaunchURL(QUEUE_FCM_URL)
	end,
}

GlueDialogTypes["OKAY"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_HTML"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	html = 1,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_HTML_EXIT"] = {
	text = "",
	button1 = OKAY,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["CONFIRM_PAID_SERVICE"] = {
	text = CONFIRM_PAID_SERVICE,
	button1 = DONE,
	button2 = CANCEL,
	OnAccept = function()
		CreateCharacter(CharacterCreateNameEdit:GetText());
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_WITH_URL"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	OnAccept = function()
		LaunchURL(_G[GlueDialog.data]);
	end,
	OnCancel = function()
		StatusDialogClick();
	end,
}

GlueDialogTypes["CONNECTION_HELP"] = {
	text = "",
	button1 = OKAY,
	OnCancel = function()
	end,
}

GlueDialogTypes["CONNECTION_HELP_HTML"] = {
	text = "",
	button1 = OKAY,
	html = 1,
	OnCancel = function()
	end,
}

GlueDialogTypes["CLIENT_ACCOUNT_MISMATCH"] = {
	button1 = RETURN_TO_LOGIN,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		SetGlueScreen("login");
	end,
	OnCancel = function()
		PlaySound("gsTitleQuit");
		QuitGame();
	end,
}

GlueDialogTypes["CLIENT_TRIAL"] = {
	text = CLIENT_TRIAL,
	button1 = RETURN_TO_LOGIN,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		SetGlueScreen("login");
	end,
	OnCancel = function()
		PlaySound("gsTitleQuit");
		QuitGame();
	end,
}

GlueDialogTypes["SCANDLL_DOWNLOAD"] = {
	text = "",
	button1 = QUIT,
	button2 = nil,
	OnAccept = function()
		AccountLogin_Exit();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["SCANDLL_ERROR"] = {
	text = "",
	button1 = SCANDLL_BUTTON_CONTINUEANYWAY,
	button2 = QUIT,
	OnAccept = function()
		GlueDialog:Hide();
		ScanDLLContinueAnyway();
		-- AccountLoginUI:Show();
	end,
	OnCancel = function()
		-- Opposite semantics
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SCANDLL_HACKFOUND"] = {
	text = "",
	button1 = SCANDLL_BUTTON_CONTINUEANYWAY,
	button2 = QUIT,
	html = 1,
	showAlert = 1,
	OnAccept = function()
		local formatString = _G["SCANDLL_MESSAGE_"..AccountLogin.hackType.."FOUND_CONFIRM"];
		GlueDialog:ShowDialog("SCANDLL_HACKFOUND_CONFIRM", format(formatString, AccountLogin.hackName, AccountLogin.hackURL));
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SCANDLL_HACKFOUND_NOCONTINUE"] = {
	text = "",
	button1 = QUIT,
	button2 = nil,
	html = 1,
	showAlert = 1,
	OnAccept = function()
		AccountLogin_Exit();
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SCANDLL_HACKFOUND_CONFIRM"] = {
	text = "",
	button1 = SCANDLL_BUTTON_CONTINUEANYWAY,
	button2 = QUIT,
	html = 1,
	showAlert = 1,
	OnAccept = function()
		GlueDialog:Hide();
		ScanDLLContinueAnyway();
		-- AccountLoginUI:Show();
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SERVER_SPLIT"] = {
	text = SERVER_SPLIT,
	button1 = SERVER_SPLIT_SERVER_ONE,
	button2 = SERVER_SPLIT_SERVER_TWO,
	button3 = SERVER_SPLIT_NOT_NOW,
	escapeHides = true;

	OnAccept = function()
		SetStateRequestInfo( 1 );
	end,
	OnCancel = function()
		SetStateRequestInfo( 2 );
	end,
	OnAlt = function()
		SetStateRequestInfo( 0 );
	end,
}

GlueDialogTypes["SERVER_SPLIT_WITH_CHOICE"] = {
	text = SERVER_SPLIT,
	button1 = SERVER_SPLIT_SERVER_ONE,
	button2 = SERVER_SPLIT_SERVER_TWO,
	button3 = SERVER_SPLIT_DONT_CHANGE,
	escapeHides = true;

	OnAccept = function()
		SetStateRequestInfo( 1 );
	end,
	OnCancel = function()
		SetStateRequestInfo( 2 );
	end,
	OnAlt = function()
		SetStateRequestInfo( 0 );
	end,
}

GlueDialogTypes["ACCOUNT_MSG"] = {
	text = "",
	button1 = OKAY,
	button2 = ACCOUNT_MESSAGE_BUTTON_READ,
	html = 1,
	escapeHides = true,

	OnShow = function()
		StatusDialogClick();
	end,
	OnAccept = function()
		ACCOUNT_MSG_NUM_AVAILABLE = ACCOUNT_MSG_NUM_AVAILABLE - 1;
		if ( ACCOUNT_MSG_NUM_AVAILABLE > 0 ) then
			ACCOUNT_MSG_CURRENT_INDEX = AccountMsg_GetIndexNextUnreadMsg(ACCOUNT_MSG_CURRENT_INDEX);
			ACCOUNT_MSG_BODY_LOADED = false;
			AccountMsg_LoadBody( ACCOUNT_MSG_CURRENT_INDEX );
		end
		StatusDialogClick();
	end,
	OnCancel = function()
		AccountMsg_SetMsgRead(ACCOUNT_MSG_CURRENT_INDEX);
		ACCOUNT_MSG_NUM_AVAILABLE = ACCOUNT_MSG_NUM_AVAILABLE - 1;
		if ( ACCOUNT_MSG_NUM_AVAILABLE > 0 ) then
			ACCOUNT_MSG_CURRENT_INDEX = AccountMsg_GetIndexNextUnreadMsg(ACCOUNT_MSG_CURRENT_INDEX);
			ACCOUNT_MSG_BODY_LOADED = false;
			AccountMsg_LoadBody( ACCOUNT_MSG_CURRENT_INDEX );
		end
		StatusDialogClick();
	end,
}

GlueDialogTypes["DECLINE_FAILED"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
		DeclensionFrame:Show();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["REALM_LOCALE_WARNING"] = {
	text = REALM_TYPE_LOCALE_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["REALM_TOURNAMENT_WARNING"] = {
	text = REALM_TYPE_TOURNAMENT_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CONFIRM_LAUNCH_UPLOAD_ADDON_URL"] = {
	text = CONFIRM_LAUNCH_UPLOAD_ADDON_URL,
	button1 = OKAY,
	button2 = CANCEL,
	html = 1,
	cover = true,
	escapeHides = true,
	OnAccept = function()
		local url = AddonList.openURL
		if url then
			LaunchURL(url)
		end
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["ADDON_INVALID_VERSION_DIALOG"] = {
	text = ADDON_INVALID_VERSION_DIALOG,
	button1 = ADDON_INVALID_VERSION_OKAY_HIDE,
	button2 = ADDONS,
	ignoreKeys = true,
	OnAccept = function()
		GlueParent.dontShowInvalidVersionAddonDialog = true
	end,
	OnCancel = function()
		GlueParent.dontShowInvalidVersionAddonDialog = true
		AddonList:Show()
	end,
}

GlueDialogTypes["ADDON_INVALID_VERSION_DIALOG_NSA"] = {
	text = ADDON_INVALID_VERSION_DIALOG,
	button1 = ADDON_INVALID_VERSION_OKAY_HIDE,
	button2 = ADDONS,
	button3 = NEVER_SHOW_AGAIN,
	ignoreKeys = true,
	OnShow = function(this)
		this.button3Width = this.Container.Button3:GetWidth()
		local newWidth = math.max(this.button3Width, math.floor(this.Container.Button3:GetTextWidth() + 0.5) + 15)
		this.Container.Button3:SetWidth(newWidth)
		this.Container.Button2:SetPoint("BOTTOM", this.Container, "BOTTOM", (this.button3Width - newWidth) / 2, 25)
	end,
	OnHide = function(this)
		this.Container.Button3:SetWidth(this.button3Width or 130)
		this.button3Width = nil
	end,
	OnAccept = function()
		GlueParent.dontShowInvalidVersionAddonDialog = true
	end,
	OnCancel = function()
		GlueParent.dontShowInvalidVersionAddonDialog = true
		AddonList:Show()
	end,
	OnAlt = function()
		C_GlueCVars.SetCVar("IGNORE_ADDON_VERSION", "1")
		GlueParent.dontShowInvalidVersionAddonDialog = true
	end,
}

GlueDialogTypes["CONFIRM_PAID_FACTION_CHANGE"] = {
	text = CONFIRM_PAID_FACTION_CHANGE,
	button1 = DONE,
	button2 = CANCEL,
	OnAccept = function()
		CreateCharacter(CharacterCreateNameEdit:GetText());
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CONFIRM_CHARACTER_CREATE"] = {
--	text = CONFIRM_CHARACTER_CREATE,
	button1 = CHARACTER_CREATE,
	button2 = CANCEL,
	escapeHides = true,
	enableEnter = true,
	OnShow = function(dialog)
		if dialog.data[2] then
			dialog.Container.Button1:SetText(dialog.data[2])
		end
	end,
	OnAccept = function(dialog)
		C_CharacterCreation.CreateCharacter(dialog.data[1])
	end,
}

GlueDialogTypes["CONFIRM_CHARACTER_CREATE_CUSTOMIZATION"] = {
--	text = CONFIRM_CHARACTER_CREATE_CUSTOMIZATION,
	button1 = CHARACTER_CREATE,
	button2 = CANCEL,
	button3 = CHARACTER_CREATE_CUSTOMIZATION_LABEL,
	escapeHides = true,
	enableEnter = true,
	OnShow = function(dialog)
		if dialog.data[2] then
			dialog.Container.Button1:SetText(dialog.data[2])
		end
	end,
	OnAccept = function(dialog)
		C_CharacterCreation.CreateCharacter(dialog.data[1])
	end,
	OnAlt = function()
		CharacterCreate.GenderFrame.CustomizationButton:Click()
	end,
}

GlueDialogTypes["FORCE_CHOOSE_FACTION"] = {
	text = CHOOSE_FACTION,
	button1 = FACTION_ALLIANCE,
	button2 = FACTION_HORDE,
	ignoreKeys = true,
	OnAccept = function()
		C_CharacterCreation.PaidChange_ChooseFaction(PLAYER_FACTION_GROUP.Alliance, true)
	end,
	OnCancel = function()
		C_CharacterCreation.PaidChange_ChooseFaction(PLAYER_FACTION_GROUP.Horde, true)
	end,
}

GlueDialogTypes["SERVER_WAITING"] = {
	text = WAIT_SERVER_RESPONCE,
	ignoreKeys = true,
	spinner = true,
}

GlueDialogTypes["ADDONS_OUT_OF_DATE"] = {
	text = ADDONS_OUT_OF_DATE,
	button1 = DISABLE_ADDONS,
	button2 = LOAD_ADDONS,
	OnAccept = function()
		GlueDialog:QueueDialog("CONFIRM_DISABLE_ADDONS")
	end,
	OnCancel = function()
		GlueDialog:QueueDialog("CONFIRM_LOAD_ADDONS")
	end,
}

GlueDialogTypes["CONFIRM_LOAD_ADDONS"] = {
	text = CONFIRM_LOAD_ADDONS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		SetAddonVersionCheck(0);
	end,
	OnCancel = function()
		GlueDialog:QueueDialog("ADDONS_OUT_OF_DATE");
	end,
}

GlueDialogTypes["CONFIRM_DISABLE_ADDONS"] = {
	text = CONFIRM_DISABLE_ADDONS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		AddonList_DisableOutOfDate()
	end,
	OnCancel = function()
		GlueDialog:QueueDialog("ADDONS_OUT_OF_DATE")
	end,
}

GlueDialogTypes["CONFIRM_LAUNCH_ADDON_URL"] = {
	text = CONFIRM_LAUNCH_UPLOAD_ADDON_URL,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		local url = AddonList.openURL
		if url then
			LaunchURL(url)
		end
	end
}

GlueDialogTypes["OKAY_REALM_DOWN"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
		StatusDialogClick()
		if RealmList:IsShown() then
			RealmListUpdate()
		else
			RequestRealmList(1)
		end
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_VOID"] = {
	button1 = OKAY,
	showAlert = 1,
}

local DELAYED_DIALOGUES = {
	[CHAR_LIST_RETRIEVING] = true,
}

local REALM_DOWN_DIALOGUES = {
	[REALM_LIST_REALM_NOT_FOUND] = true,
}

local DIALOG_BACKGROUND_OFFSET_X = 100
local DIALOG_BACKGROUND_OFFSET_Y = 32
local DIALOG_BUTTON_OFFSET_X = 15
local DIALOG_BUTTON_OFFSET_Y = 10
local DIALOG_BUTTON_OFFSET_BOTTOM = 5
local DIALOG_EDITBOX_OFFSET_Y = -5

GlueDialogMixin = {}

function GlueDialogMixin:OnLoad()
	self:RegisterHookListener()

	self:EnableMouseWheel(true)

	self.queuedDialogs = {}

	self.Container.Spinner.AnimFrame.Anim:Play()
	self.Container.HTML:SetTextColor(1, 1, 1)

	self.Container.alertWidth = 640
	self.Container.origWidth = self.Container:GetWidth()
	self.Container.Text.origWidth = self.Container.Text:GetWidth()
end

function GlueDialogMixin:OPEN_STATUS_DIALOG(event, which, text, data)
	if self.dialogTimer then
		self.dialogTimer:Cancel()
		self.dialogTimer = nil
	end

	if DELAYED_DIALOGUES[text] then
		self.dialogTimer = C_Timer:NewTicker(0.5, function()
			self:ShowDialog(which, text, data)
		end, 1)
	elseif which == "OKAY" and REALM_DOWN_DIALOGUES[text] then
		self:ShowDialog("OKAY_REALM_DOWN", text, data)
	else
		self:ShowDialog(which, text, data)
	end
end

function GlueDialogMixin:UPDATE_STATUS_DIALOG(event, text, buttonText)
	if not text or text == "" then return end

	local info = GlueDialogTypes[self.which]

	local textHeight

	if info and info.html then
		self.Container.HTML:SetText(text)
		textHeight = select(4, self.Container.HTML:GetBoundsRect())
	else
		self.Container.Text:SetText(text)
		textHeight = self.Container.Text:GetHeight()
	end

	if buttonText then
		self.Container.Button1:SetText(buttonText)
		textHeight = textHeight + DIALOG_BUTTON_OFFSET_Y + DIALOG_BUTTON_OFFSET_BOTTOM + self.Container.Button1:GetHeight()
	elseif info and info.button1 then
		self.Container.Button1:SetText(info.button1)
		textHeight = textHeight + DIALOG_BUTTON_OFFSET_Y + DIALOG_BUTTON_OFFSET_BOTTOM + self.Container.Button1:GetHeight()
	end

	self.Container:SetHeight(textHeight + DIALOG_BACKGROUND_OFFSET_Y * 2)
end

function GlueDialogMixin:CLOSE_STATUS_DIALOG(...)
	if self.dialogTimer then
		self.dialogTimer:Cancel()
		self.dialogTimer = nil
	end

	self:Hide()
end

function GlueDialogMixin:QueueDialog(which, text, data)
	table.insert(self.queuedDialogs, {which = which, text = text, data = data})
end

function GlueDialogMixin:CheckQueuedDialogs()
	if #self.queuedDialogs > 0 and not self:IsShown() then
		self:ShowDialog(self.queuedDialogs[1].which, self.queuedDialogs[1].text, self.queuedDialogs[1].data);
		table.remove(self.queuedDialogs, 1);
	end
end

function GlueDialogMixin:ShowDialog(which, text, data)
	local dialogInfo = GlueDialogTypes[which]
	-- Pick a free dialog to use
	if self:IsShown() then
		if self.which ~= which then -- We don't actually want to hide, we just want to redisplay?
			if GlueDialogTypes[self.which].OnHide then
				GlueDialogTypes[self.which].OnHide(self)
			end

			self:Hide()
		end
	end

	self.Container:ClearAllPoints()
	if dialogInfo.anchorPoint then
		self.Container:SetPoint(dialogInfo.anchorPoint, dialogInfo.anchorOffsetX or 0, dialogInfo.anchorOffsetY or 0)
	else
		self.Container:SetPoint("CENTER", 0, 35)
	end

	self.data = data

	local glueText
	if dialogInfo.html then
		glueText = self.Container.HTML
		self.Container.HTML:Show()
		self.Container.Text:Hide()
	else
		glueText = self.Container.Text
		self.Container.HTML:Hide()
		self.Container.Text:Show()
	end

	if dialogInfo.infoIcon then
		self.Container.InfoIcon:ClearAllPoints()
		self.Container.InfoIcon:SetPoint("TOPRIGHT", glueText, 25, 0)
		self.Container.InfoIcon:Show()
	else
		self.Container.InfoIcon:Hide()
	end

	-- Set the text of the dialog
	glueText:SetText(text or dialogInfo.text)

	-- set the optional title
	self.Container.Title:Hide()
	glueText:ClearAllPoints()
	glueText:SetPoint("TOP", 0, -32)

	-- Set the buttons of the dialog
	if dialogInfo.button3 then
		self.Container.Button1:ClearAllPoints()
		self.Container.Button2:ClearAllPoints()
		self.Container.Button3:ClearAllPoints()

		if dialogInfo.displayVertical then
			self.Container.Button3:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, DIALOG_BUTTON_OFFSET_BOTTOM + DIALOG_BACKGROUND_OFFSET_Y)
			self.Container.Button2:SetPoint("BOTTOM", self.Container.Button3, "TOP", 0, DIALOG_BUTTON_OFFSET_Y)
			self.Container.Button1:SetPoint("BOTTOM", self.Container.Button2, "TOP", 0, DIALOG_BUTTON_OFFSET_Y)
		else
			self.Container.Button2:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, DIALOG_BUTTON_OFFSET_BOTTOM + DIALOG_BACKGROUND_OFFSET_Y)
			self.Container.Button1:SetPoint("RIGHT", self.Container.Button2, "LEFT", -DIALOG_BUTTON_OFFSET_X, 0)
			self.Container.Button3:SetPoint("LEFT", self.Container.Button2, "RIGHT", DIALOG_BUTTON_OFFSET_X, 0)
		end

		self.Container.Button1:SetText(dialogInfo.button1)
		self.Container.Button1:Show()
		self.Container.Button2:SetText(dialogInfo.button2)
		self.Container.Button2:Show()
		self.Container.Button3:SetText(dialogInfo.button3)
		self.Container.Button3:Show()
	elseif dialogInfo.button2 then
		self.Container.Button1:ClearAllPoints()
		self.Container.Button2:ClearAllPoints()

		if dialogInfo.displayVertical then
			self.Container.Button2:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, DIALOG_BUTTON_OFFSET_BOTTOM + DIALOG_BACKGROUND_OFFSET_Y)
			self.Container.Button1:SetPoint("BOTTOM", self.Container.Button2, "TOP", 0, DIALOG_BUTTON_OFFSET_Y)
		else
			self.Container.Button1:SetPoint("BOTTOMRIGHT", self.Container, "BOTTOM", -6, DIALOG_BUTTON_OFFSET_BOTTOM + DIALOG_BACKGROUND_OFFSET_Y)
			self.Container.Button2:SetPoint("LEFT", self.Container.Button1, "RIGHT", DIALOG_BUTTON_OFFSET_X, 0)
		end

		self.Container.Button1:SetText(dialogInfo.button1)
		self.Container.Button1:Show()
		self.Container.Button2:SetText(dialogInfo.button2)
		self.Container.Button2:Show()
		self.Container.Button3:Hide()
	elseif dialogInfo.button1 then
		self.Container.Button1:ClearAllPoints()
		self.Container.Button1:SetPoint("BOTTOM", self.Container, "BOTTOM", 0, DIALOG_BUTTON_OFFSET_BOTTOM + DIALOG_BACKGROUND_OFFSET_Y)
		self.Container.Button1:SetText(dialogInfo.button1)
		self.Container.Button1:Show()
		self.Container.Button2:Hide()
		self.Container.Button3:Hide()
	else
		self.Container.Button1:Hide()
		self.Container.Button2:Hide()
		self.Container.Button3:Hide()
	end

	-- Set the miscellaneous variables for the dialog
	self.which = which
	self.data = data

	-- Show or hide the alert icon
	if dialogInfo.showAlert then
		self.Container:SetWidth(self.Container.alertWidth)
		self.Container.AlertIcon:Show()
	else
		self.Container:SetWidth(self.Container.origWidth)
		self.Container.AlertIcon:Hide()
	end

	self.Container.Text:SetWidth(self.Container.Text.origWidth)

	-- Editbox setup
	if dialogInfo.hasEditBox then
		self.Container.EditBox:Show()
		if dialogInfo.maxLetters then
			self.Container.EditBox:SetMaxLetters(dialogInfo.maxLetters)
		end
		if dialogInfo.maxBytes then
			self.Container.EditBox:SetMaxBytes(dialogInfo.maxBytes)
		end
	else
		self.Container.EditBox:Hide()
	end

	-- Spinner setup
	self.Container.Spinner:SetShown(dialogInfo.spinner)

	-- Get the width of the text to aid in determining the width of the dialog
	local textWidth = 0
	if dialogInfo.html then
		textWidth = select(3, self.Container.HTML:GetBoundsRect())
	else
		textWidth = self.Container.Text:GetWidth()
	end

	-- size the width first
	if dialogInfo.displayVertical then
		local backgroundWidth = math.max(self.Container.Button1:GetWidth(), textWidth)
		self.Container:SetWidth(backgroundWidth + DIALOG_BACKGROUND_OFFSET_X * 2)
	elseif dialogInfo.button3 then
		local displayWidth = DIALOG_BACKGROUND_OFFSET_X * 3 + DIALOG_BUTTON_OFFSET_X * 2 + self.Container.Button1:GetWidth() + self.Container.Button2:GetWidth() + self.Container.Button3:GetWidth()
		self.Container:SetWidth(displayWidth)
		self.Container.Text:SetWidth(displayWidth - DIALOG_BACKGROUND_OFFSET_X * 3)
	end

	-- Get the height of the string
	local _, textHeight
	if dialogInfo.html then
		_, _, _, textHeight = self.Container.HTML:GetBoundsRect()
	else
		textHeight = self.Container.Text:GetHeight()
	end

	-- now size the dialog box height
	local displayHeight = textHeight + DIALOG_BACKGROUND_OFFSET_Y * 2
	if dialogInfo.displayVertical then
		if dialogInfo.button1 then
			displayHeight = displayHeight + DIALOG_BUTTON_OFFSET_Y + DIALOG_BUTTON_OFFSET_BOTTOM + self.Container.Button1:GetHeight()
			if dialogInfo.button2 then
				displayHeight = displayHeight + DIALOG_BUTTON_OFFSET_Y + self.Container.Button2:GetHeight()
				if dialogInfo.button3 then
					displayHeight = displayHeight + DIALOG_BUTTON_OFFSET_Y + self.Container.Button3:GetHeight()
				end
			end
		end
	elseif dialogInfo.button1 then
		displayHeight = displayHeight + DIALOG_BUTTON_OFFSET_Y + DIALOG_BUTTON_OFFSET_BOTTOM + self.Container.Button1:GetHeight()
	end

	if dialogInfo.hasEditBox then
		displayHeight = displayHeight + DIALOG_BUTTON_OFFSET_Y + self.Container.EditBox:GetHeight()
	end

	if dialogInfo.spinner then
		displayHeight = displayHeight + self.Container.Spinner:GetHeight()
	end

	self.Container:SetHeight(math.floor(displayHeight + 0.5))

	self:Show()
end

function GlueDialogMixin:HideDialog(which, text)
	if (which and self.which ~= which)
	or (text and self.Container.Text:GetText() ~= text)
	then
		return false
	end

	self:Hide()

	return true
end

function GlueDialogMixin:IsDialogShown(which, text)
	if (which and self.which ~= which)
	or (text and self.Container.Text:GetText() ~= text)
	then
		return false
	end

	return self:IsShown() == 1
end

function GlueDialogMixin:OnShow()
	self:Raise()
	local onShow = GlueDialogTypes[self.which].OnShow
	if onShow then
		onShow(self)
	end
	if GlueDialogTypes[self.which].cover then
		GlueParent_AddModalFrame(GlueDialog)
	end
end

function GlueDialogMixin:OnHide()
	self.Container.InfoIcon.InfoHeader = nil
	self.Container.InfoIcon.InfoText = nil

	if self.which then
		local dialogInfo = GlueDialogTypes[self.which]

		if dialogInfo then
			if dialogInfo.OnHide then
				dialogInfo.OnHide(self)
			end
		end
	end

	if GlueDialogTypes[self.which].cover then
		GlueParent_RemoveModalFrame(GlueDialog)
	end

--	PlaySound("igMainMenuClose")
end

function GlueDialogMixin:OnKeyDown(key)
	if key == "PRINTSCREEN" then
		Screenshot()
		return
	end

	local info = GlueDialogTypes[self.which]
	if info and info.ignoreKeys then return end

	if key == "ESCAPE" then
		if info.escapeHides then
			self:Hide()
		elseif self.Container.Button3:IsShown() then
			self.Container.Button3:Click()
		elseif self.Container.Button2:IsShown() then
			self.Container.Button2:Click()
		else
			self.Container.Button1:Click()
		end

		if info.hideSound then
			PlaySound(info.hideSound)
		end
	elseif key == "ENTER" then
		if not self.Container.Button3:IsShown() or info.enableEnter then
			self.Container.Button1:Click()
		end

		if info.hideSound then
			PlaySound(info.hideSound)
		end
	end
end

GlueDialogEditBoxMixin = {}

function GlueDialogEditBoxMixin:OnLoad()
	self.dialog = self:GetParent():GetParent()
end

function GlueDialogEditBoxMixin:OnEnterPressed()
	self.dialog:OnKeyDown("ENTER")
end

function GlueDialogEditBoxMixin:OnEscapePressed()
	self.dialog:OnKeyDown("ESCAPE")
end

GlueDialogButtonMixin = {}

function GlueDialogButtonMixin:OnLoad()
	self.dialog = self:GetParent():GetParent()
	self:SetParentArray("buttons")

--	if self:IsEnabled() ~= 1 then
--		self:SetAlpha(0.5)
--	end
end

function GlueDialogButtonMixin:OnClick()
	self.dialog:Hide()

	local id = self:GetID()
	if id == 1 then
		local OnAccept = GlueDialogTypes[self.dialog.which].OnAccept
		if OnAccept then
			OnAccept(self.dialog)
		end
	elseif id == 2 then
		local OnCancel = GlueDialogTypes[self.dialog.which].OnCancel
		if OnCancel then
			OnCancel(self.dialog)
		end
	elseif id == 3 then
		local OnAlt = GlueDialogTypes[self.dialog.which].OnAlt
		if OnAlt then
			OnAlt(self.dialog)
		end
	end

	PlaySound("gsTitleOptionOK")
end