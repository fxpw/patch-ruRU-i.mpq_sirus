UIPanelWindows["CUFProfilesFrame"] = { area = "center", pushable = 0, whileDead = 1 };

CUF_PROFILES = C_Cache("SIRUS_CUF_PROFILES", true);
local PROFILES;
local SAVED_PROFILE = { };

local MAX_CUF_PROFILES = 5;

local FLATTENDED_OPTIONS = {
	["locked"] = 0,
	["shown"] = 0,
	["keepGroupsTogether"] = 1,
	["horizontalGroups"] = 1,
	["sortBy"] = 1,
	["displayPowerBar"] = 1,
	["displayAggroHighlight"] = 1,
	["useClassColors"] = 1,
	["displayPets"] = 1,
	["displayRaidRoleGroupIcon"] = 1,
	["displayMainTankAndAssist"] = 1,
	["displayNonBossDebuffs"] = 1,
	["displayOnlyDispellableDebuffs"] = 1,
	["displayBorder"] = 1,
	["healthText"] = 1,
	["frameWidth"] = 1,
	["frameHeight"] = 1,
	["autoActivate2Players"] = 1,
	["autoActivate3Players"] = 1,
	["autoActivate5Players"] = 1,
	["autoActivate10Players"] = 1,
	["autoActivate15Players"] = 1,
	["autoActivate25Players"] = 1,
	["autoActivate40Players"] = 1,
	["autoActivatePvP"] = 1,
	["autoActivatePvE"] = 1,
	["rangeCheck"] = 1,
	["raidTargetIcon"] = 1,
};

local DEFAULT_PROFILE = {
	name = DEFAULT_CUF_PROFILE_NAME,
	isDynamic = true,

	shown = true,
	locked = true,
	keepGroupsTogether = false,
	horizontalGroups = false,
	sortBy = "group",
	displayPowerBar = false,
	displayAggroHighlight = true,
	useClassColors = true,
	displayPets = false,
	displayRaidRoleGroupIcon = false,
	displayMainTankAndAssist = true,
	displayNonBossDebuffs = true,
	displayOnlyDispellableDebuffs = false,
	displayBorder = true,
	healthText = "none",
	frameWidth = 72,
	frameHeight = 36,
	autoActivate2Players = false,
	autoActivate3Players = false,
	autoActivate5Players = false,
	autoActivate10Players = false,
	autoActivate15Players = false,
	autoActivate25Players = false,
	autoActivate40Players = false,
	autoActivatePvP = false,
	autoActivatePvE = false,
	rangeCheck = 3,
	raidTargetIcon = false,
};

function GetNumRaidProfiles()
	if ( not PROFILES ) then
		return 0;
	end

	return #PROFILES;
end

function GetRaidProfileName(index)
	if ( not PROFILES or not index ) then
		return;
	end

	if PROFILES[index] then
		return PROFILES[index].name;
	end
end

function RaidProfileExists(profile)
	if ( not PROFILES or not profile ) then
		return;
	end

	for _, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			return true;
		end
	end
end

function HasLoadedCUFProfiles()
	return PROFILES;
end

function RaidProfileHasUnsavedChanges()
	if ( not PROFILES ) then
		return;
	end

	if SAVED_PROFILE then
		for _, profileData in ipairs(PROFILES) do
			if ( profileData.name == SAVED_PROFILE.name ) then
				for option, noIgnore in pairs(FLATTENDED_OPTIONS) do
					if ( noIgnore == 1 and profileData[option] ~= SAVED_PROFILE[option] ) then
						return true;
					end
				end
			end
		end
	end
end

function RestoreRaidProfileFromCopy()
	if ( SAVED_PROFILE ) then
		for _, profileData in ipairs(PROFILES) do
			if ( profileData.name == SAVED_PROFILE.name ) then
				for option, noIgnore in pairs(FLATTENDED_OPTIONS) do
					if ( noIgnore == 1 and profileData[option] ~= SAVED_PROFILE[option] ) then
						profileData[option] = SAVED_PROFILE[option];
					end
				end
			end
		end
	end
end

function CreateNewRaidProfile(name, baseOnProfile)
	if ( not PROFILES or not name ) then
		return;
	end

	local profile
	if ( baseOnProfile and baseOnProfile ~= DEFAULTS ) then
		for _, profileData in ipairs(PROFILES) do
			if ( profileData.name == baseOnProfile ) then
				profile = CopyTable(profileData);
				break;
			end
		end
	else
		profile = CopyTable(DEFAULT_PROFILE);
	end

	profile.name = name;
	table.insert(PROFILES, profile);
end

function DeleteRaidProfile(profile)
	if ( not PROFILES or not profile ) then
		return;
	end

	if ( type(profile) == "number" ) then
		table.remove(PROFILES, profile);
	else
		for index, profileData in ipairs(PROFILES) do
			if ( profileData.name == profile ) then
				table.remove(PROFILES, index);
				break;
			end
		end
	end
end

function SaveRaidProfileCopy(profile)
	if ( not PROFILES or not profile ) then
		return;
	end

	for _, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			SAVED_PROFILE = CopyTable(profileData);
			break;
		end
	end
end

function SetRaidProfileOption(profile, optionName, value)
	if ( not PROFILES or not profile or not optionName ) then
		return;
	end

	for index, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			PROFILES[index][optionName] = value;
			break;
		end
	end
end

function GetRaidProfileOption(profile, optionName)
	if ( not PROFILES or not profile or not optionName ) then
		return;
	end

	for _, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			return profileData[optionName];
		end
	end
end

function GetRaidProfileFlattenedOptions(profile)
	if ( not PROFILES or not profile ) then
		return;
	end

	for _, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			local flattenedOptions = {};
			for option, value in pairs(profileData) do
				if FLATTENDED_OPTIONS[option] then
					flattenedOptions[option] = value;
				end
			end
			return flattenedOptions;
		end
	end
end

function SetRaidProfileSavedPosition(profile, isDynamic, topPoint, topOffset, bottomPoint, bottomOffset, leftPoint, leftOffset)
	if ( not PROFILES or not profile ) then
		return;
	end

	for _, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			profileData.isDynamic = isDynamic;
			profileData.topPoint = topPoint;
			profileData.topOffset = topOffset;
			profileData.topOffset = topOffset;
			profileData.bottomPoint = bottomPoint;
			profileData.bottomOffset = bottomOffset;
			profileData.leftPoint = leftPoint;
			profileData.leftOffset = leftOffset;
			break;
		end
	end
end

function GetRaidProfileSavedPosition(profile)
	if ( not PROFILES or not profile ) then
		return;
	end

	for _, profileData in ipairs(PROFILES) do
		if ( profileData.name == profile ) then
			return profileData.isDynamic, profileData.topPoint, profileData.topOffset, profileData.bottomPoint, profileData.bottomOffset, profileData.leftPoint, profileData.leftOffset;
		end
	end
end

function GetMaxNumCUFProfiles()
	return MAX_CUF_PROFILES;
end

function SetActiveRaidProfile(profile)
	C_CVar:SetValue("C_CVAR_SET_ACTIVE_CUF_PROFILE", profile);
end

function GetActiveRaidProfile()
	return C_CVar:GetValue("C_CVAR_SET_ACTIVE_CUF_PROFILE");
end

function CompactUnitFrameProfiles_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");

	--Get this working with the InterfaceOptions panel.
	self.name = COMPACT_UNIT_FRAME_PROFILES_LABEL;
	self.options = {
		C_CVAR_USE_COMPACT_PARTY_FRAMES = { text = "USE_RAID_STYLE_PARTY_FRAMES" },
	};

	BlizzardOptionsPanel_OnLoad(self, CompactUnitFrameProfiles_SaveChanges, CompactUnitFrameProfiles_CancelCallback, CompactUnitFrameProfiles_DefaultCallback, CompactUnitFrameProfiles_UpdateCurrentPanel);
	InterfaceOptions_AddCategory(self, false, 17);
end

function CompactUnitFrameProfiles_OnEvent(self, event, ...)
	--Do normal BlizzardOptionsPanel code too.
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "VARIABLES_LOADED" ) then
		self.variablesLoaded = true;
		self:UnregisterEvent(event);

		PROFILES = CUF_PROFILES:Get("PROFILES")
		if not PROFILES then
			CUF_PROFILES:Set("PROFILES", {CopyTable(DEFAULT_PROFILE)})
			SetActiveRaidProfile(DEFAULT_CUF_PROFILE_NAME)
			PROFILES = CUF_PROFILES:Get("PROFILES")
		end

		CompactUnitFrameProfiles_ValidateProfilesLoaded(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then	--Check for zoning
		CompactUnitFrameProfiles_CheckAutoActivation();
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		CompactUnitFrameProfiles_CheckAutoActivation();
	end
end

function CompactUnitFrameProfiles_ValidateProfilesLoaded(self)
	if ( HasLoadedCUFProfiles() and self.variablesLoaded ) then
		if ( RaidProfileExists(GetActiveRaidProfile()) ) then
			CompactUnitFrameProfiles_ActivateRaidProfile(GetActiveRaidProfile());
		elseif ( GetNumRaidProfiles() == 0 ) then	--If we don't have any profiles, we need to create a new one.
			CompactUnitFrameProfiles_ResetToDefaults();
		else
			CompactUnitFrameProfiles_ActivateRaidProfile(GetRaidProfileName(1));
		end
	end
end

function CompactUnitFrameProfiles_DefaultCallback(self)
	InterfaceOptionsPanel_Default(self);
	CompactUnitFrameProfiles_ResetToDefaults();
end

function CompactUnitFrameProfiles_ResetToDefaults()
	local profiles = {};
	for i=1, GetNumRaidProfiles() do
		tinsert(profiles, GetRaidProfileName(i));
	end
	for i=1, #profiles do
		DeleteRaidProfile(profiles[i]);
	end
	CreateNewRaidProfile(DEFAULT_CUF_PROFILE_NAME);
	CompactUnitFrameProfiles_ActivateRaidProfile(DEFAULT_CUF_PROFILE_NAME);
end

function CompactUnitFrameProfiles_SaveChanges(self)
	SaveRaidProfileCopy(self.selectedProfile);	--Save off the current version in case we cancel.
	CompactUnitFrameProfiles_UpdateManagementButtons();
end

function CompactUnitFrameProfiles_CancelCallback(self)
	InterfaceOptionsPanel_Cancel(self);
	CompactUnitFrameProfiles_CancelChanges(self);
end

function CompactUnitFrameProfiles_CancelChanges(self)
	InterfaceOptionsPanel_Cancel(self);
	RestoreRaidProfileFromCopy();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
	CompactUnitFrameProfiles_ApplyCurrentSettings();
end

function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_SetUp(self)
	UIDropDownMenu_SetWidth(self, 190);
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_Initialize);
end


function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = DEFAULTS;
	info.value = nil;
	info.func = CompactUnitFrameProfilesNewProfileDialogBaseProfileSelectorButton_OnClick;
	info.checked = CompactUnitFrameProfiles.newProfileDialog.baseProfile == info.value;
	UIDropDownMenu_AddButton(info);

	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		info.text = name;
		info.value = name;
		info.func = CompactUnitFrameProfilesNewProfileDialogBaseProfileSelectorButton_OnClick;
		info.checked = CompactUnitFrameProfiles.newProfileDialog.baseProfile == info.value;
		UIDropDownMenu_AddButton(info);
	end
end

function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelectorButton_OnClick(self)
	CompactUnitFrameProfiles.newProfileDialog.baseProfile = self.value;
	UIDropDownMenu_SetSelectedValue(CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector, self.value);
end

function CompactUnitFrameProfilesProfileSelector_SetUp(self)
	UIDropDownMenu_SetWidth(self, 190);
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesProfileSelector_Initialize);
end

function CompactUnitFrameProfilesProfileSelector_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		info.text = name;
		info.func = CompactUnitFrameProfilesProfileSelectorButton_OnClick;
		info.value = name;
		info.checked = CompactUnitFrameProfiles.selectedProfile == name;
		UIDropDownMenu_AddButton(info);
	end

	info.text = NEW_COMPACT_UNIT_FRAME_PROFILE;
	info.func = CompactUnitFrameProfiles_NewProfileButtonClicked;
	info.value = nil;
	info.checked = false;
	info.notCheckable = true;
	info.disabled = GetNumRaidProfiles() >= GetMaxNumCUFProfiles();
	UIDropDownMenu_AddButton(info);
end

function CompactUnitFrameProfilesProfileSelectorButton_OnClick(self)
	if ( RaidProfileHasUnsavedChanges() ) then
		CompactUnitFrameProfiles_ConfirmUnsavedChanges("select", self.value);
	else
		CompactUnitFrameProfiles_ActivateRaidProfile(self.value);
	end
end

function CompactUnitFrameProfiles_NewProfileButtonClicked()
	if ( RaidProfileHasUnsavedChanges() ) then
		CompactUnitFrameProfiles_ConfirmUnsavedChanges("new");
	else
		CompactUnitFrameProfiles_ShowNewProfileDialog();
	end
end

function CompactUnitFrameProfiles_ActivateRaidProfile(profile)
	CompactUnitFrameProfiles.selectedProfile = profile;
	SaveRaidProfileCopy(profile);	--Save off the current version in case we cancel.
	SetActiveRaidProfile(profile);
	UIDropDownMenu_SetSelectedValue(CompactUnitFrameProfilesProfileSelector, profile);
	UIDropDownMenu_SetText(CompactUnitFrameProfilesProfileSelector, profile);
	UIDropDownMenu_SetSelectedValue(CompactRaidFrameManagerDisplayFrameProfileSelector, profile);
	UIDropDownMenu_SetText(CompactRaidFrameManagerDisplayFrameProfileSelector, profile);

	CompactUnitFrameProfiles_HidePopups();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
	CompactUnitFrameProfiles_ApplyCurrentSettings();
end

function CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_ApplyProfile(GetActiveRaidProfile());
end


function CompactUnitFrameProfiles_UpdateCurrentPanel()
	InterfaceOptionsPanel_Refresh(CompactUnitFrameProfiles);
	local panel = CompactUnitFrameProfiles.optionsFrame;
	for i=1, #panel.optionControls do
		panel.optionControls[i]:updateFunc();
	end
	CompactUnitFrameProfiles_UpdateManagementButtons();
	CompactUnitFrameProfile_UpdateAutoActivationDisabledLabel();
end

function CompactUnitFrameProfiles_CreateProfile(profileName)
	CreateNewRaidProfile(profileName, CompactUnitFrameProfiles.newProfileDialog.baseProfile);
	CompactUnitFrameProfiles_ActivateRaidProfile(profileName);
end

function CompactUnitFrameProfiles_UpdateNewProfileCreateButton()
	local button = CompactUnitFrameProfiles.newProfileDialog.createButton;
	local text = strtrim(CompactUnitFrameProfiles.newProfileDialog.editBox:GetText());

	if ( text == "" or RaidProfileExists(text) or strlower(text) == strlower(DEFAULTS) ) then
		button:Disable();
	else
		button:Enable();
	end
end

function CompactUnitFrameProfiles_HideNewProfileDialog()
	CompactUnitFrameProfiles.newProfileDialog:Hide();
end

function CompactUnitFrameProfiles_ShowNewProfileDialog()
	UIDropDownMenu_SetSelectedValue(CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector, nil);
	UIDropDownMenu_SetText(CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector, DEFAULTS);
	CompactUnitFrameProfiles.newProfileDialog.baseProfile = nil;
	CompactUnitFrameProfiles.newProfileDialog:Show();
	CompactUnitFrameProfiles.newProfileDialog.editBox:SetText("");
	CompactUnitFrameProfiles.newProfileDialog.editBox:SetFocus();
	CompactUnitFrameProfiles_UpdateNewProfileCreateButton();
end

function CompactUnitFrameProfiles_ConfirmProfileDeletion(profile)
	CompactUnitFrameProfiles.deleteProfileDialog.profile = profile;
	CompactUnitFrameProfiles.deleteProfileDialog.label:SetFormattedText(CONFIRM_COMPACT_UNIT_FRAME_PROFILE_DELETION, profile);
	CompactUnitFrameProfiles.deleteProfileDialog:Show();
end

function CompactUnitFrameProfiles_UpdateManagementButtons()
	if ( GetNumRaidProfiles() <= 1 ) then
		CompactUnitFrameProfilesDeleteButton:Disable();
	else
		CompactUnitFrameProfilesDeleteButton:Enable();
	end

	if ( RaidProfileHasUnsavedChanges() ) then
		CompactUnitFrameProfilesSaveButton:Enable();
	else
		CompactUnitFrameProfilesSaveButton:Disable();
	end
end

function CompactUnitFrameProfiles_ConfirmUnsavedChanges(action, profileArg)
	CompactUnitFrameProfiles.unsavedProfileDialog.action = action;
	CompactUnitFrameProfiles.unsavedProfileDialog.profile = profileArg;
	CompactUnitFrameProfiles.unsavedProfileDialog.label:SetFormattedText(CONFIRM_COMPACT_UNIT_FRAME_PROFILE_UNSAVED_CHANGES, CompactUnitFrameProfiles.selectedProfile);
	CompactUnitFrameProfiles.unsavedProfileDialog:Show();
end

function CompactUnitFrameProfiles_AfterConfirmUnsavedChanges()
	local action = CompactUnitFrameProfiles.unsavedProfileDialog.action;
	local profileArg = CompactUnitFrameProfiles.unsavedProfileDialog.profile;
	if ( action == "select" ) then
		CompactUnitFrameProfiles_ActivateRaidProfile(profileArg);
	elseif ( action == "new" ) then
		CompactUnitFrameProfiles_ShowNewProfileDialog();
	end
end

function CompactUnitFrameProfiles_HidePopups()
	CompactUnitFrameProfiles.newProfileDialog:Hide();
	CompactUnitFrameProfiles.deleteProfileDialog:Hide();
	CompactUnitFrameProfiles.unsavedProfileDialog:Hide();
	CompactUnitFrameProfiles.restoredProfileDialog:Hide();
end

local autoActivateGroupSizes = { 2, 3, 5, 10, 15, 25, 40 };
local countMap = {};	--Maps number of players to the category. (For example, so that AQ20 counts as a 25-man.)
for i, autoActivateGroupSize in ipairs(autoActivateGroupSizes) do
	local groupSizeStart = i > 1 and (autoActivateGroupSizes[i - 1] + 1) or 1;
	for groupSize = groupSizeStart, autoActivateGroupSize do
		countMap[groupSize] = autoActivateGroupSize;
	end
end

function CompactUnitFrameProfiles_GetAutoActivationState()
	local name, instanceType, _, _, maxPlayers = GetInstanceInfo();
	if ( not name ) then	--We don't have info.
		return false;
	end

	local numPlayers, profileType, enemyType;

	if ( instanceType == "party" or instanceType == "raid" ) then
		numPlayers = maxPlayers > 0 and countMap[maxPlayers] or 5;
		profileType = instanceType;
		enemyType = "PvE";
	elseif ( instanceType == "arena" ) then
		numPlayers = countMap[GetNumPartyMembers()];
		profileType = instanceType;
		enemyType = "PvP";
	elseif ( instanceType == "pvp" ) then
		numPlayers = countMap[maxPlayers];
		profileType = instanceType;
		enemyType = "PvP";
	else
		numPlayers = countMap[math.max(GetNumRaidMembers(), GetNumPartyMembers())];
		profileType = "world";
		enemyType = "PvE";
	end

	if ( not numPlayers ) then
		return false;
	end

	return true, numPlayers, profileType, enemyType;
end

local checkAutoActivationTimer;
function CompactUnitFrameProfiles_CheckAutoActivation()
	--We only want to adjust the profile when you 1) Zone or 2) change specs. We don't want to automatically
	--change the profile when you are in the uninstanced world.
	if ( GetNumPartyMembers() == 0 ) then
		CompactUnitFrameProfiles_SetLastActivationType(nil, nil, nil);
		return;
	end

	local success, numPlayers, activationType, enemyType = CompactUnitFrameProfiles_GetAutoActivationState();

	if ( not success ) then
		--We didn't have all the relevant info yet. Update again soon.
		if ( checkAutoActivationTimer ) then
			checkAutoActivationTimer:Cancel();
		end
		checkAutoActivationTimer = C_Timer:NewTicker(3, CompactUnitFrameProfiles_CheckAutoActivation, 1);
		return;
	else
		if ( checkAutoActivationTimer ) then
			checkAutoActivationTimer:Cancel();
			checkAutoActivationTimer = nil;
		end
	end

	local lastActivationType, lastNumPlayers, lastEnemyType = CompactUnitFrameProfiles_GetLastActivationType();

	if ( lastActivationType == activationType and lastNumPlayers == numPlayers and lastEnemyType == enemyType ) then
		--If we last auto-adjusted for this same thing, we don't change. (In case they manually changed the profile.)
		return;
	end

	if ( CompactUnitFrameProfiles_ProfileMatchesAutoActivation(GetActiveRaidProfile(), numPlayers, enemyType) ) then
		CompactUnitFrameProfiles_SetLastActivationType(activationType, numPlayers, enemyType);
	else
		for i=1, GetNumRaidProfiles() do
			local profile = GetRaidProfileName(i);
			if ( CompactUnitFrameProfiles_ProfileMatchesAutoActivation(profile, numPlayers, enemyType) ) then
				CompactUnitFrameProfiles_ActivateRaidProfile(profile);
				CompactUnitFrameProfiles_SetLastActivationType(activationType, numPlayers, enemyType);
			end
		end
	end
end

function CompactUnitFrameProfiles_SetLastActivationType(activationType, numPlayers, enemyType)
	CompactUnitFrameProfiles.lastActivationType = activationType;
	CompactUnitFrameProfiles.lastNumPlayers = numPlayers;
	CompactUnitFrameProfiles.lastEnemyType = enemyType;
end

function CompactUnitFrameProfiles_GetLastActivationType()
	return CompactUnitFrameProfiles.lastActivationType, CompactUnitFrameProfiles.lastNumPlayers, CompactUnitFrameProfiles.lastEnemyType;
end

function CompactUnitFrameProfiles_ProfileMatchesAutoActivation(profile, numPlayers, enemyType)
	return GetRaidProfileOption(profile, "autoActivate"..numPlayers.."Players") and
			GetRaidProfileOption(profile, "autoActivate"..enemyType);
end


function CompactUnitFrameProfile_UpdateAutoActivationDisabledLabel()
	local profile = GetActiveRaidProfile();
	local hasGroupSize = false;
	for i=1, #autoActivateGroupSizes do
		if ( GetRaidProfileOption(profile, "autoActivate"..autoActivateGroupSizes[i].."Players") ) then
			hasGroupSize = true;
			break;
		end
	end

	local hasEnemyType = false;
	if ( GetRaidProfileOption(profile, "autoActivatePvP") or GetRaidProfileOption(profile, "autoActivatePvE") ) then
		hasEnemyType = true;
	end

	if hasGroupSize == hasEnemyType then
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:Hide();
	elseif ( not hasGroupSize ) then
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:SetText(AUTO_ACTIVATE_PROFILE_NO_SIZE);
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:Show();
	elseif ( not hasEnemyType ) then
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:SetText(AUTO_ACTIVATE_PROFILE_NO_ENEMYTYPE);
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:Show();
	end
end


--------------------------------------------------------------
-----------------UI Option Templates---------------------
--------------------------------------------------------------

function CompactUnitFrameProfilesOption_OnLoad(self)
	if ( not self:GetParent().optionControls ) then
		self:GetParent().optionControls = {};
	end
	tinsert(self:GetParent().optionControls, self);
end

-------------------------
----Dropdown--------
-------------------------
-- Required key/value pairs:
-- .optionName - String, name of option
-- .options - Array, array of possible options
-- Required strings:
-- COMPACT_UNIT_FRAME_PROFILE_<OPTION_NAME>
-- COMPACT_UNIT_FRAME_PROFILE_<OPTION_NAME>_<OPTION_VALUE>
function CompactUnitFrameProfilesDropdown_InitializeWidget(self, optionName, options, updateFunc)
	self.optionName = optionName;
	self.options = options;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	self.updateFunc = updateFunc or CompactUnitFrameProfilesDropdown_Update;
	CompactUnitFrameProfilesOption_OnLoad(self);
end

function CompactUnitFrameProfilesDropdown_OnShow(self)
	UIDropDownMenu_SetWidth(self, self.width or 160);
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesDropdown_Initialize);
	CompactUnitFrameProfilesDropdown_Update(self);
end

function CompactUnitFrameProfilesDropdown_Update(self)
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesDropdown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName));
end

function CompactUnitFrameProfilesDropdown_Initialize(dropDown)
	local info = UIDropDownMenu_CreateInfo();

	local currentValue = GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, dropDown.optionName);
	for i=1, #dropDown.options do
		local id = dropDown.options[i];
		local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s_%s", strupper(dropDown.optionName), strupper(id));
		info.text = _G[tag] or "Need string: "..tag;
		info.func = CompactUnitFrameProfilesDropdownButton_OnClick;
		info.arg1 = dropDown;
		info.value = id;
		info.checked = currentValue == id;
		UIDropDownMenu_AddButton(info);
	end
end

function CompactUnitFrameProfilesDropdownButton_OnClick(button, dropDown)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, dropDown.optionName, button.value);
	UIDropDownMenu_SetSelectedValue(dropDown, button.value);
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

------------------------------
----------Slider-------------
------------------------------
function CompactUnitFrameProfilesSlider_InitializeWidget(self, optionName, minText, maxText, updateFunc)
	self.optionName = optionName;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	if ( minText ) then
		self.minLabel:SetText(minText);
	end
	if ( maxText ) then
		self.maxLabel:SetText(maxText);
	end
	self.updateFunc = updateFunc or CompactUnitFrameProfilesSlider_Update;
	CompactUnitFrameProfilesOption_OnLoad(self);
end

function CompactUnitFrameProfilesSlider_Update(self)
	local currentValue = GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName);
	self:SetValue(currentValue);
end

function CompactUnitFrameProfilesSlider_OnValueChanged(self, value)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, value);
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

-------------------------------
-------Check Button---------
-------------------------------
function CompactUnitFrameProfilesCheckButton_InitializeWidget(self, optionName, updateFunc)
	self.optionName = optionName;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	self.updateFunc = updateFunc or CompactUnitFrameProfilesCheckButton_Update;
	CompactUnitFrameProfilesOption_OnLoad(self);
end

function CompactUnitFrameProfilesCheckButton_Update(self)
	local currentValue = GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName);
	self:SetChecked(currentValue);
end

function CompactUnitFrameProfilesCheckButton_OnClick(self)
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, self:GetChecked() == 1);
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

-------------------------------------------------------------
-----------------Applying of Options----------------------
-------------------------------------------------------------

function CompactUnitFrameProfiles_ApplyProfile(profile)
	local settings = GetRaidProfileFlattenedOptions(profile);

	for settingName, value in pairs(settings) do
		local func = CUFProfileActionTable[settingName];
		if ( func ) then
			func(value);
		end
	end

	--Refresh all frames to make sure the changes stick.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", DefaultCompactUnitFrameSetup);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "mini", DefaultCompactMiniFrameSetup);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "mini", CompactUnitFrame_UpdateAll);
	--CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "group", CompactRaidGroup_UpdateLayout);	--UpdateBorder calls UpdateLayout.

	--Update the borders on the group frames.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "group", CompactRaidGroup_UpdateBorder);

	--Update the position of the container.
	CompactRaidFrameManager_ResizeFrame_LoadPosition(CompactRaidFrameManager);

	--Update the container in case sizes and such changed.
	CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

local function CompactUnitFrameProfiles_GenerateRaidManagerSetting(optionName)
	return function(value)
		CompactRaidFrameManager_SetSetting(optionName, value);
	end
end

local function CompactUnitFrameProfiles_GenerateOptionSetter(optionName, optionTarget)
	return function(value)
		if ( optionTarget == "normal" or optionTarget == "all" ) then
			DefaultCompactUnitFrameOptions[optionName] = value;
		end
		if ( optionTarget == "mini" or optionTarget == "all" ) then
			DefaultCompactMiniFrameOptions[optionName] = value;
		end
	end
end

local function CompactUnitFrameProfiles_GenerateSetUpOptionSetter(optionName, optionTarget)
	return function(value)
		if ( optionTarget == "normal" or optionTarget == "all" ) then
			DefaultCompactUnitFrameSetupOptions[optionName] = value;
		end
		if ( optionTarget == "mini" or optionTarget == "all" ) then
			DefaultCompactMiniFrameSetUpOptions[optionName] = value;
		end
	end
end

CUFProfileActionTable = {
	--Settings
	keepGroupsTogether = CompactUnitFrameProfiles_GenerateRaidManagerSetting("KeepGroupsTogether"),
	sortBy = CompactUnitFrameProfiles_GenerateRaidManagerSetting("SortMode"),
	displayPets = CompactUnitFrameProfiles_GenerateRaidManagerSetting("DisplayPets"),
	displayRaidRoleGroupIcon = CompactUnitFrameProfiles_GenerateOptionSetter("displayRaidRoleGroupIcon", "normal"),
	displayMainTankAndAssist = CompactUnitFrameProfiles_GenerateRaidManagerSetting("DisplayMainTankAndAssist"),
	displayPowerBar = CompactUnitFrameProfiles_GenerateSetUpOptionSetter("displayPowerBar", "normal"),
	displayAggroHighlight = CompactUnitFrameProfiles_GenerateOptionSetter("displayAggroHighlight", "all"),
	displayNonBossDebuffs = CompactUnitFrameProfiles_GenerateOptionSetter("displayNonBossDebuffs", "normal"),
	displayOnlyDispellableDebuffs = CompactUnitFrameProfiles_GenerateOptionSetter("displayOnlyDispellableDebuffs", "normal"),
	useClassColors = CompactUnitFrameProfiles_GenerateOptionSetter("useClassColors", "normal"),
	horizontalGroups = CompactUnitFrameProfiles_GenerateRaidManagerSetting("HorizontalGroups");
	healthText = CompactUnitFrameProfiles_GenerateOptionSetter("healthText", "normal"),
	rangeCheck = CompactUnitFrameProfiles_GenerateOptionSetter("rangeCheck", "all"),
	raidTargetIcon = CompactUnitFrameProfiles_GenerateOptionSetter("raidTargetIcon", "all"),
	frameWidth = CompactUnitFrameProfiles_GenerateSetUpOptionSetter("width", "all");
	frameHeight = 	function(value)
		DefaultCompactUnitFrameSetupOptions.height = value;
		DefaultCompactMiniFrameSetUpOptions.height = value / 2;
	end,
	displayBorder = function(value)
		RAID_BORDERS_SHOWN = value;
		DefaultCompactUnitFrameSetupOptions.displayBorder = value;
		DefaultCompactMiniFrameSetUpOptions.displayBorder = value;
		CompactRaidFrameManager_SetSetting("ShowBorders", value);
	end,

	--State
	locked = CompactUnitFrameProfiles_GenerateRaidManagerSetting("Locked"),
	shown = CompactUnitFrameProfiles_GenerateRaidManagerSetting("IsShown"),
}
