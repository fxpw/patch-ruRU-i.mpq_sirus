ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 16;

function C_GetAddOnInfo( addonIndex )
	if not addonIndex then
		return
	end

	local buffer = {}

	for i = 1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build = GetAddOnInfo(i)

		if name then
			buffer[#buffer + 1] = {name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build, i}
		end
	end

	table.sort(buffer, function(a, b)
		if a[8] and not b[8] then
			return true
		end
		if not a[8] and b[8] then
			return false
		end

		if a[2] and b[2] then
			return a[2] < b[2]
		else
			return a[1] < b[1]
		end
	end)

	if buffer[addonIndex] then
		return unpack(buffer[addonIndex])
	end
end

function UpdateAddonButton()
	if ( GetNumAddOns() > 0 ) then
		-- Check to see if any of them are out of date and not disabled
		if ( IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog ) then
			AddonDialog_Show("ADDONS_OUT_OF_DATE");
			HasShownAddonOutOfDateDialog = true;
		end

		local hasNewVersion = AddonList_HasNewVersion()
		CharacterSelectAddonsButton.AttentionOverlay:SetShown(hasNewVersion)
		CharacterSelectAddonsButton:Show();
	else
		CharacterSelectAddonsButton:Hide();
	end

	for i = 1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason, security, newVersion, needUpdate, major, minor, build = GetAddOnInfo(i)

		if name and newVersion then
			DisableAddOn(nil, i)
		end
	end

	AddonList_OnOk()
end

function AddonList_OnLoad(self)
	self.offset = 0;
end

function AddonList_Update()
	local numEntrys = GetNumAddOns();
	local addonIndex;
	local button, checkbox, string, status, urlButton, securityIcon, versionButton;

	-- Get the character from the current list (nil is all characters)
	local character = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( character == ALL ) then
		character = nil;
	end

	for i=1, MAX_ADDONS_DISPLAYED do
		addonIndex = AddonList.offset + i;
		button = _G["AddonListEntry"..i];
		if ( addonIndex > numEntrys ) then
			button:Hide();
		else
			local name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build, index = C_GetAddOnInfo(addonIndex)
			local checkboxState = GetAddOnEnableState(character, index)
			local enabled = checkboxState > 0
			local titleColor = {}

			TriStateCheckbox_SetState(checkboxState, button.StatusCheckBox)

			if checkboxState == 1 then
				button.StatusCheckBox.tooltip = ENABLED_FOR_SOME
			else
				button.StatusCheckBox.tooltip = nil
			end

			if (loadable or (enabled and (reason == "DEP_DEMAND_LOADED" or reason == "DEMAND_LOADED"))) then
				titleColor = {1.0, 0.78, 0.0}
			elseif enabled and reason ~= "DEP_DISABLED" then
				titleColor = {1.0, 0.1, 0.1}
			else
				titleColor = {0.5, 0.5, 0.5}
			end

			if title then
				button.Title:SetText(title)
			else
				button.Title:SetText(name)
			end

			if (not loadable and reason) and not newVersion then
				if reason == "BANNED" then
					button.Status:SetText(ADDON_BANNED_TOOLTIP)
					TriStateCheckbox_SetState(0, button.StatusCheckBox)
				else
					button.Status:SetText(_G["ADDON_"..reason])
				end
			else
				button.Status:SetText("")
			end

			if newVersion then
				titleColor = {1.0, 0.1, 0.1}

				button.BackgroundLeft:SetVertexColor(1, 0, 0)
				button.BackgroundRight:SetVertexColor(1, 0, 0)

				button.BackgroundLeft:SetAlpha(0.4)
				button.BackgroundRight:SetAlpha(0.4)

				DisableAddOn(nil, index)
			else
				button.BackgroundLeft:SetVertexColor(0.91, 0.78, 0.53)
				button.BackgroundRight:SetVertexColor(0.91, 0.78, 0.53)

				button.BackgroundLeft:SetAlpha(0.25)
				button.BackgroundRight:SetAlpha(0.25)

				button.BackgroundLeftHighlight:Hide()
				button.BackgroundRightHighlight:Hide()
			end

			button.DownloadButton:SetShown(newVersion)
			button.StatusCheckBox:SetShown(not newVersion)
			button.UpdateLabel:SetShown(newVersion)

			button.StatusCheckBox:SetEnabled(reason ~= "BANNED")

			button.Title:SetTextColor(unpack(titleColor))

			button.newVersion = newVersion
			button.url = url

			button:SetID(index)
			button:Show();
		end
	end

	FauxScrollFrame_Update(AddonList.Container.ScrollArtFrame.ScrollFrame, numEntrys, MAX_ADDONS_DISPLAYED, ADDON_BUTTON_HEIGHT, nil, nil, nil, nil, nil, nil, true)
end

function AddonTooltip_BuildDeps(...)
	local deps = "";
	for i=1, select("#", ...) do
		if ( i == 1 ) then
			deps = ADDON_DEPENDENCIES .. select(i, ...);
		else
			deps = deps..", "..select(i, ...);
		end
	end
	return deps;
end

function AddonTooltip_Update(owner)
	AddonTooltip.owner = owner;
	local name, title, notes,_,_,_, security = GetAddOnInfo(owner:GetID());
	if ( security == "BANNED" ) then
		AddonTooltipTitle:SetText(ADDON_BANNED_TOOLTIP);
		AddonTooltipNotes:SetText("");
		AddonTooltipDeps:SetText("");
	else
		if ( title ) then
			AddonTooltipTitle:SetText(title);
		else
			AddonTooltipTitle:SetText(name);
		end
		AddonTooltipNotes:SetText(notes);
		AddonTooltipDeps:SetText(AddonTooltip_BuildDeps(GetAddOnDependencies(owner:GetID())));
	end

	local titleHeight = AddonTooltipTitle:GetHeight();
	local notesHeight = AddonTooltipNotes:GetHeight();
	local depsHeight = AddonTooltipDeps:GetHeight();
	AddonTooltip:SetHeight(10+titleHeight+2+notesHeight+2+depsHeight+10);
end

function AddonList_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		AddonList_OnCancel();
	elseif ( key == "ENTER" ) then
		AddonList_OnOk();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function AddonList_Enable(index, enabled)
	local character = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	if ( character == ALL ) then
		character = nil;
	end
	if ( enabled ) then
		EnableAddOn(character, index);
	else
		DisableAddOn(character, index);
	end
	AddonList_Update();
end

function AddonList_OnOk()
	PlaySound("gsLoginChangeRealmOK");
	SaveAddOns();
	AddonList:Hide();
end

function AddonList_OnCancel()
	PlaySound("gsLoginChangeRealmCancel");
	ResetAddOns();
	AddonList:Hide();
end

function AddonListScrollFrame_OnVerticalScroll(self, offset)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	AddonList.offset = floor((offset / ADDON_BUTTON_HEIGHT) + 0.5);
	AddonList_Update();
	if ( AddonTooltip:IsShown() ) then
		AddonTooltip_Update(AddonTooltip.owner);
		AddonTooltip:Show()
	end
end

function AddonList_OnShow()
	AddonList_Update();
end

function AddonList_HasOutOfDate()
	local hasOutOfDate = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason = GetAddOnInfo(i);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			hasOutOfDate = true;
			break;
		end
	end
	return hasOutOfDate;
end

function AddonList_SetSecurityIcon(texture, index)
	local width = 64;
	local height = 16;
	local iconWidth = 16;
	local increment = iconWidth/width;
	local left = (index - 1) * increment;
	local right = index * increment;
	texture:SetTexCoord( left, right, 0, 1.0);
end

function AddonList_DisableOutOfDate()
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason = GetAddOnInfo(i);
		if ( enabled and not loadable and reason == "INTERFACE_VERSION" ) then
			DisableAddOn(i);
		end
	end
end

function AddonList_HasNewVersion()
	local hasNewVersion = false;
	for i=1, GetNumAddOns() do
		local name, title, notes, url, loadable, reason, security, newVersion = GetAddOnInfo(i);
		if ( newVersion ) then
			hasNewVersion = true;
			break;
		end
	end
	return hasNewVersion;
end

AddonDialogTypes = { };

AddonDialogTypes["ADDONS_OUT_OF_DATE"] = {
	text = ADDONS_OUT_OF_DATE,
	button1 = DISABLE_ADDONS,
	button2 = LOAD_ADDONS,
	OnAccept = function()
		AddonDialog_Show("CONFIRM_DISABLE_ADDONS");
	end,
	OnCancel = function()
		AddonDialog_Show("CONFIRM_LOAD_ADDONS");
	end,
}

AddonDialogTypes["CONFIRM_LOAD_ADDONS"] = {
	text = CONFIRM_LOAD_ADDONS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		SetAddonVersionCheck(0);
	end,
	OnCancel = function()
		AddonDialog_Show("ADDONS_OUT_OF_DATE");
	end,
}

AddonDialogTypes["CONFIRM_DISABLE_ADDONS"] = {
	text = CONFIRM_DISABLE_ADDONS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		AddonList_DisableOutOfDate();
	end,
	OnCancel = function()
		AddonDialog_Show("ADDONS_OUT_OF_DATE");
	end,
}

AddonDialogTypes["CONFIRM_LAUNCH_ADDON_URL"] = {
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

function AddonDialog_Show(which, arg1)
	-- Set the text of the dialog
	if ( arg1 ) then
		AddonDialogText:SetFormattedText(AddonDialogTypes[which].text, arg1);
	else
		AddonDialogText:SetText(AddonDialogTypes[which].text);
	end

	-- Set the buttons of the dialog
	if ( AddonDialogTypes[which].button2 ) then
		AddonDialogButton1:ClearAllPoints();
		AddonDialogButton1:SetPoint("BOTTOMRIGHT", "AddonDialogBackground", "BOTTOM", -6, 16);
		AddonDialogButton2:ClearAllPoints();
		AddonDialogButton2:SetPoint("LEFT", "AddonDialogButton1", "RIGHT", 13, 0);
		AddonDialogButton2:SetText(AddonDialogTypes[which].button2);
		AddonDialogButton2:Show();
	else
		AddonDialogButton1:ClearAllPoints();
		AddonDialogButton1:SetPoint("BOTTOM", "AddonDialogBackground", "BOTTOM", 0, 16);
		AddonDialogButton2:Hide();
	end

	AddonDialogButton1:SetText(AddonDialogTypes[which].button1);

	-- Set the miscellaneous variables for the dialog
	AddonDialog.which = which;

	-- Finally size and show the dialog
	AddonDialogBackground:SetHeight(16 + AddonDialogText:GetHeight() + 8 + AddonDialogButton1:GetHeight() + 16);
	AddonDialog:Show();
end

function AddonDialog_OnClick(index)
	AddonDialog:Hide();
	if ( index == 1 ) then
		local OnAccept = AddonDialogTypes[AddonDialog.which].OnAccept;
		if ( OnAccept ) then
			OnAccept();
		end
	else
		local OnCancel = AddonDialogTypes[AddonDialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel();
		end
	end
end

function AddonDialog_OnKeyDown(key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	if ( key == "ESCAPE" ) then
		if ( AddonDialogButton2:IsShown() ) then
			AddonDialogButton2:Click();
		else
			AddonDialogButton1:Click();
		end
	elseif (key == "ENTER" ) then
		AddonDialogButton1:Click();
	end
end

function AddonListCharacterDropDown_OnClick(self)
	GlueDropDownMenu_SetSelectedValue(AddonCharacterDropDown, self.value);
	AddonList_Update();
end

function AddonListCharacterDropDown_Initialize()
	local selectedValue = GlueDropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	local info = GlueDropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = ALL;
	info.func = AddonListCharacterDropDown_OnClick;
	if ( not selectedValue ) then
		info.checked = 1;
	end
	GlueDropDownMenu_AddButton(info);

	for i=1, GetNumCharacters() do
		info.text = GetCharacterInfo(i);
		info.value = GetCharacterInfo(i);
		info.func = AddonListCharacterDropDown_OnClick;
		if ( selectedValue == info.value ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		GlueDropDownMenu_AddButton(info);
	end
end
