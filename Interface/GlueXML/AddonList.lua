ADDON_BUTTON_HEIGHT = 16;
MAX_ADDONS_DISPLAYED = 16;

local addonList = {}

function C_GetAddOnInfo(addonIndex)
	if not addonIndex then return end

	local numAddons = GetNumAddOns()
	if not addonList or addonList.numAddons ~= numAddons then
		table.wipe(addonList)
		addonList.numAddons = numAddons

		for i = 1, numAddons do
			local name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build = GetAddOnInfo(i)

			if name then
				addonList[#addonList + 1] = {name, title, newVersion, i}
			end
		end

		table.sort(addonList, function(a, b)
			if a[3] and not b[3] then
				return true
			end
			if not a[3] and b[3] then
				return false
			end

			if a[2] and b[2] then
				return a[2] < b[2]
			else
				return a[1] < b[1]
			end
		end)
	end

	if addonList[addonIndex] then
		local name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build = GetAddOnInfo(addonList[addonIndex][4])
		return name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build, addonList[addonIndex][4]
	end
end

function UpdateAddonButton()
	if ( GetNumAddOns() > 0 ) then
		-- Check to see if any of them are out of date and not disabled
		if ( IsAddonVersionCheckEnabled() and AddonList_HasOutOfDate() and not HasShownAddonOutOfDateDialog ) then
			GlueDialog:QueueDialog("ADDONS_OUT_OF_DATE")
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
	self.Container.TopShadow:SetVertexColor(0, 0, 0, 0.25)
end

function AddonList_Update()
	local numEntrys = GetNumAddOns();
	local addonIndex;
	local button, checkbox, string, status, urlButton, securityIcon, versionButton;

	-- Get the character from the current list (nil is all characters)
	local character = GlueDark_DropDownMenu_GetSelectedValue(AddonCharacterDropDown);
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
				titleColor = {1.0, 1.0, 1.0}
			elseif enabled and reason ~= "DEP_DISABLED" then
				titleColor = {0.58984375, 0.2578125, 0.2578125}
			else
				titleColor = {0.4765625, 0.4765625, 0.4765625}
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

				button.Background:SetVertexColor(0.58984375, 0.2578125, 0.2578125)
				button.Background:SetAlpha(0.4)

				DisableAddOn(nil, index)
			else
				button.Background:SetVertexColor(0.91, 0.78, 0.53)
				button.Background:SetAlpha(0.25)
				button.BackgroundHighlight:Hide()
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
	local deps
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

		deps = AddonTooltip_BuildDeps(GetAddOnDependencies(owner:GetID()))
		AddonTooltipDeps:SetText(deps);

		if owner.newVersion then
			AddonTooltipInfo:ClearAllPoints()
			AddonTooltipInfo:SetPoint("TOPLEFT", (deps and deps ~= "") and AddonTooltipDeps or AddonTooltipNotes, "BOTTOMLEFT", 0, -2)
			AddonTooltipInfo:SetText(ADDON_CLICK_TO_OPEN_UPDATE_PAGE, 1.0, 1.0, 1.0);
			AddonTooltipInfo:Show()
		else
			AddonTooltipInfo:Hide()
		end
	end

	local titleHeight = AddonTooltipTitle:GetHeight();
	local notesHeight = (notes and notes ~= "") and (AddonTooltipNotes:GetHeight() + 2) or 0;
	local depsHeight = (deps and deps ~= "") and (AddonTooltipDeps:GetHeight() + 2) or 0;
	local infoHeight = owner.newVersion and (AddonTooltipInfo:GetHeight() + 2) or 0
	AddonTooltip:SetHeight(10+titleHeight+2+notesHeight+depsHeight+infoHeight+10);
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
	local character = GlueDark_DropDownMenu_GetSelectedValue(AddonCharacterDropDown);
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

function AddonListCharacterDropDown_OnClick(self)
	GlueDark_DropDownMenu_SetSelectedValue(AddonCharacterDropDown, self.value);
	AddonList_Update();
end

function AddonListCharacterDropDown_Initialize()
	local selectedValue = GlueDark_DropDownMenu_GetSelectedValue(AddonCharacterDropDown);
	local info = GlueDark_DropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = ALL;
	info.func = AddonListCharacterDropDown_OnClick;
	if ( not selectedValue ) then
		info.checked = 1;
	end
	GlueDark_DropDownMenu_AddButton(info);

	for i=1, GetNumCharacters() do
		info.text = GetCharacterInfo(i);
		info.value = GetCharacterInfo(i);
		info.func = AddonListCharacterDropDown_OnClick;
		if ( selectedValue == info.value ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		GlueDark_DropDownMenu_AddButton(info);
	end
end