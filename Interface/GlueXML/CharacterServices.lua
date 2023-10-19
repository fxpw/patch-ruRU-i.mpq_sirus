CharacterBoostStep = 1
local SelectMainProfession
local SelectAdditionalProffesion
local SelectCharacterSpec
local SelectCharacterPvPSpec
local SelectCharacterFaction = 0

GlueDialogTypes["LOCK_BOOST_ENTER_WORLD"] = {
	text = CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		CharSelectServicesFlowFrame:Hide()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CHARACTER_SERVICES_BOOST_CONFIRM"] = {
	text = CHARACTER_BOOST_CONFIRM_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		C_CharacterServices.BoostCharacter(CharSelectServicesFlowFrame.selectedCharacterIndex, SelectMainProfession, SelectAdditionalProffesion, SelectCharacterSpec, SelectCharacterPvPSpec, SelectCharacterFaction)
	end,
	OnCancel = function()
		CharSelectServicesFlowFrame:Hide()
	end,
}

GlueDialogTypes["CHARACTER_SERVICES_NOT_ENOUGH_MONEY"] = {
	button1 = DONATE,
	button2 = CLOSE,
	OnAccept = function()
		C_CharacterServices.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end,
}

local factionLogoTextures = {
	[1]	= "Interface\\Icons\\Inv_Misc_Tournaments_banner_Orc",
	[2]	= "Interface\\Icons\\Achievement_PVP_A_A",
}

local factionLabels = {
	[1] = FACTION_HORDE,
	[2] = FACTION_ALLIANCE,
}

function CharacterServicesMaster_CharacterInit(isBoostMode)
	if not isBoostMode then
		for i = 1, C_CharacterList.GetNumCharactersOnPage() do
			local button = _G["CharSelectCharacterButton"..i]
			button:Enable()
			button:SetBoostMode(false)
		end

		return
	end

	local pendingBoostCharacterListID, pendingBoostCharacterID, pendiongBoostCharacterPageIndex = C_CharacterList.GetPendingBoostDK()
	if pendingBoostCharacterListID ~= 0 and pendingBoostCharacterID == 0 then
		CharSelectServicesFlowFrame:Hide()
		GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_SERVICES_DIALOG_BOOST_NO_CHARACTERS_AVAILABLE_DEATH_KNIGHT)
		return false
	end

	local selectedCharacterIndex

	for characterIndex = 1, C_CharacterList.GetNumCharactersOnPage() do
		local button = _G["CharSelectCharacterButton"..characterIndex]

		local characterID = GetCharIDFromIndex(characterIndex)
		local name, race, class, level = GetCharacterInfo(characterID)

		local canBoost
		if not C_CharacterList.IsHardcoreCharacter(characterID) then
			if characterID == pendingBoostCharacterID
			or (pendingBoostCharacterListID == 0 and C_CharacterServices.IsBoostAvailableForLevel(level) and C_CharacterCreation.IsServicesAvailableForRace(E_PAID_SERVICE.BOOST_SERVICE, C_CreatureInfo.GetRaceInfo(race).raceID))
			then
				canBoost = true
			end
		end

		if canBoost then
			button:Enable()
			button:SetBoostMode(true, true)

			if CharacterSelect.selectedIndex == characterIndex or characterID == pendingBoostCharacterID then
				button:Click()
				CharSelectServicesFlowFrame.NextButton:Click()
				selectedCharacterIndex = characterIndex
			end
		else
			button:Disable()
			button:SetBoostMode(true)
		end
	end

	if selectedCharacterIndex then
		for characterIndex = 1, C_CharacterList.GetNumCharactersOnPage() do
			if characterIndex ~= selectedCharacterIndex then
				local button = _G["CharSelectCharacterButton"..characterIndex]
				button:Disable()
				button:SetBoostMode(true)
			end
		end
	end

	CharSelectServicesFlowFrame.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, -10, 0)

	return true
end

local MainProffesionList = {}
local AdditionalProffesionList = {}

function ChooseMainProffesionDropDown_OnClick( self )
	GlueDark_DropDownMenu_SetSelectedValue(ChooseMainProffesionDropDown, self.value)
end

function ChooseAdditionalProffesionDropDown_OnClick( self )
	GlueDark_DropDownMenu_SetSelectedValue(ChooseAdditionalProffesionDropDown, self.value)
end

 MainProffesionList[1] = {
 	["text"] = TRADESKILL_ALCHEMY,
	["value"] = 1,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[2] = {
 	["text"] = TRADESKILL_ENGINEERING,
	["value"] = 2,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[3] = {
 	["text"] = TRADESKILL_LEATHERWORKING,
	["value"] = 3,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[4] = {
 	["text"] = TRADESKILL_BLACKSMITHING,
	["value"] = 4,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[5] = {
 	["text"] = TRADESKILL_ENCHANTING,
	["value"] = 5,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[6] = {
 	["text"] = TRADESKILL_INSCRIPTION,
	["value"] = 6,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[7] = {
 	["text"] = TRADESKILL_JEWELCRAFTING,
	["value"] = 7,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[8] = {
 	["text"] = TRADESKILL_TAILORING,
	["value"] = 8,
 	["selected"] = false,
 	func = ChooseMainProffesionDropDown_OnClick
 }

 AdditionalProffesionList[1] = {
 	["text"] = TRADESKILL_MINING,
	["value"] = 1,
 	["selected"] = false,
 	func = ChooseAdditionalProffesionDropDown_OnClick
 }
 AdditionalProffesionList[2] = {
 	["text"] = TRADESKILL_HERBALISM,
	["value"] = 2,
 	["selected"] = false,
 	func = ChooseAdditionalProffesionDropDown_OnClick
 }
 AdditionalProffesionList[3] = {
 	["text"] = TRADESKILL_SKINNING,
	["value"] = 3,
 	["selected"] = false,
 	func = ChooseAdditionalProffesionDropDown_OnClick
 }

function CharacterServicesMasterMainDropDown_Initialize()
	local selectedValueMain = GlueDark_DropDownMenu_GetSelectedValue(ChooseMainProffesionDropDown)

	for i = 1, #MainProffesionList do
		MainProffesionList[i].checked = (MainProffesionList[i].text == selectedValueMain)
		GlueDark_DropDownMenu_AddButton(MainProffesionList[i])
	end
end

function CharacterServicesMasterAdditionalDropDown_Initialize()
	local selectedValueAdditional = GlueDark_DropDownMenu_GetSelectedValue(ChooseAdditionalProffesionDropDown)

	for i = 1, #AdditionalProffesionList do
		AdditionalProffesionList[i].checked = (AdditionalProffesionList[i].text == selectedValueAdditional)
		GlueDark_DropDownMenu_AddButton(AdditionalProffesionList[i])
	end
end

function CharacterServicesMaster_OnShow( self, ... )
	CharacterBoostStep = 1
	SelectCharacterFaction = 0
	CharSelectServicesFlowFrame.selectedCharacterIndex = nil

	CharacterServicesMaster_UpdateSteps()

	CharSelectChangeListStateButton:Disable()
	CharacterBoostButton:Hide()
	CharSelectEnterWorldButton:Disable()
	CharSelectCreateCharacterButton:Disable()
	CharSelectChangeRealmButton:Disable()
	CharacterSelectAddonsButton:Disable()
	CharacterSelectOptionsButton:Disable()
	CharacterSelectSupportButton:Disable()
	CharacterSelectBackButton:Disable()
	CharSelectCharPageButtonPrev:Disable()
	CharSelectCharPageButtonNext:Disable()
	CharSelectCharPagePurchaseButton:Disable()

	self.NextButton:Show()

	self.CharacterServicesMaster.step1.choose.CreateNewCharacter:SetEnabled(C_CharacterList.IsInPlayableMode() and C_CharacterList.CanCreateCharacter() and (not C_CharacterList.HasPendingBoostDK() or IsGMAccount()))

	self.CharacterServicesMaster.step1.choose:Show()
	self.CharacterServicesMaster.step1.finish:Hide()

	self.CharacterServicesMaster.step2:Hide()
	self.CharacterServicesMaster.step2.choose:Show()
	self.CharacterServicesMaster.step2.finish:Hide()

	self.CharacterServicesMaster.step3:Hide()
	self.CharacterServicesMaster.step3.choose:Show()
	self.CharacterServicesMaster.step3.finish:Hide()

	self.CharacterServicesMaster.step4:Hide()
	self.CharacterServicesMaster.step4.choose:Show()
	self.CharacterServicesMaster.step4.finish:Hide()

	self.CharacterServicesMaster.step5:Hide()
	self.CharacterServicesMaster.step5.choose:Show()
	self.CharacterServicesMaster.step5.finish:Hide()
	self.GlowBox:Show()

	if not CharacterServicesMaster_CharacterInit(true) then
		return
	end

	for i = 1, #MainProffesionList do
		GlueDark_DropDownMenu_SetSelectedName(ChooseMainProffesionDropDown, nil)
		GlueDark_DropDownMenu_SetText(ChooseMainProffesionDropDown, MAIN_PROFESSION)
	end

	for i = 1, #AdditionalProffesionList do
		GlueDark_DropDownMenu_SetSelectedName(ChooseAdditionalProffesionDropDown, nil)
		GlueDark_DropDownMenu_SetText(ChooseAdditionalProffesionDropDown, SECONDARY_PROFESSION)
	end
end

function CharacterServicesMaster_CreateCharacter(self)
	local success = CharacterSelect_OpenCharacterCreate(E_PAID_SERVICE.BOOST_SERVICE_NEW, nil, function()
		CharSelectServicesFlowFrame:Hide()
		CharSelectServicesFlowFrame:Reset()
		CharacterSelectLeftPanel.CharacterBoostInfoFrame:Show()
		CharSelectServicesFlowFrame:SetPoint(unpack(CharSelectServicesFlowFrame.basePoint))
		CharSelectServicesFlowFrame:SetAlpha(1)
	end)

	if success then
		CharacterSelectLeftPanel.CharacterBoostInfoFrame:Hide()
		CharSelectServicesFlowFrame:PlayAnim(true)
	end
end

function CharacterUpgradeSelectFactionRadioButton_OnClick(self, button, down)
	PlaySound("igMainMenuOptionCheckBoxOn")
	local owner = self.owner

	if owner then
		if owner.selected == self:GetID() then
			self:SetChecked(true)
			return
		else
			owner.selected = self:GetID()
			self:SetChecked(true)
		end

		if owner.factionButtonClickedCallback then
			owner.factionButtonClickedCallback()
		end
	end

	for _, button in ipairs(self:GetParent().FactionButtons) do
		if button:GetID() ~= self:GetID() then
			button:SetChecked(false)
		end
	end
end

function CharacterUpgradeSelectSpecRadioButton_OnClick(self, button, down)
	PlaySound("igMainMenuOptionCheckBoxOn")
	local owner = self.owner

	if owner then
		if owner.selected == self:GetID() then
			self:SetChecked(true)
			return
		else
			owner.selected = self:GetID()
			self:SetChecked(true)
		end

		if owner.factionButtonClickedCallback then
			owner.factionButtonClickedCallback()
		end
	end

	for _, button in ipairs(self:GetParent().SpecButtons) do
		if button:GetID() ~= self:GetID() then
			button:SetChecked(0)
		end
	end
end

function CharacterServicesMaster_OnHide( self, ... )
	for _, button in ipairs(self.CharacterServicesMaster.step3.choose.SpecButtons) do
		if button:GetChecked() then
			button:SetChecked(false)
		end
	end
	for _, button in ipairs(self.CharacterServicesMaster.step4.choose.SpecButtons) do
		if button:GetChecked() then
			button:SetChecked(false)
		end
	end
	for _, button in ipairs(self.CharacterServicesMaster.step5.choose.FactionButtons) do
		if button:GetChecked() then
			button:SetChecked(false)
		end
	end

	if C_CharacterList.IsRestoreModeAvailable() then
		CharSelectChangeListStateButton:Enable()
	end

	CharacterBoostButton:Show()
	CharSelectEnterWorldButton:SetEnabled(not C_CharacterList.IsCharacterPendingBoostDK(GetCharIDFromIndex(CharacterSelect.selectedIndex)))
	CharSelectChangeRealmButton:Enable()
	CharacterSelectAddonsButton:Enable()
	CharacterSelectOptionsButton:Enable()
	CharacterSelectSupportButton:Enable()
	CharacterSelectBackButton:Enable()
	CharSelectCharPagePurchaseButton:Enable()

	CharacterSelect_UpdateCharecterCreateButton()
	CharacterSelect_UpdatePageButton()
	UpdateAddonButton()
	UpdateCharacterSelection()

	CharacterServicesMaster_CharacterInit(false)
end

function CharacterServicesMaster_OnKeyDown(self, key)
	if key == "ESCAPE" then
		self:Hide()
	elseif key == "ENTER" then
		CharacterServicesMasterNextButton_OnClick(self.NextButton)
	elseif key == "PRINTSCREEN" then
		Screenshot()
	end
end

function CharacterServicesMasterNextButton_OnClick( self, ... )
	local frame = self:GetParent()
	if CharacterBoostStep == 1 then
		local charSelected

		if ( CharSelectServicesFlowFrame.selectedCharacterIndex ) then
			local characterID = GetCharIDFromIndex(CharSelectServicesFlowFrame.selectedCharacterIndex)
			local name, race, class, level = GetCharacterInfo(characterID)

			if C_CharacterCreation.IsServicesAvailableForRace(E_PAID_SERVICE.BOOST_SERVICE, C_CreatureInfo.GetRaceInfo(race).raceID) then
				charSelected = true

				if FACTION_OVERRIDE[characterID] then
					self.factionID = PLAYER_FACTION_GROUP[SERVER_PLAYER_FACTION_GROUP[FACTION_OVERRIDE[characterID]]]
				else
					local factionInfo = C_CreatureInfo.GetFactionInfo(race)
					self.factionID = factionInfo.factionID
				end

				self.classInfo = C_CreatureInfo.GetClassInfo(class)

				local _, _, _, color = GetClassColor(self.classInfo.classFile)
				frame.CharacterServicesMaster.step1.finish.Character:SetFormattedText(CHARACTER_BOOST_CHARACTER_NAME, color, name)
				frame.CharacterServicesMaster.step1.finish.CharacterInfo:SetFormattedText(CHARACTER_BOOST_CHARACTER_INFO, level, color, class)

				frame.CharacterServicesMaster.step1.choose:Hide()
				frame.CharacterServicesMaster.step1.finish:Show()
				frame.GlowBox:Hide()

				for characterIndex = 1, C_CharacterList.GetNumCharactersOnPage() do
					local button = _G["CharSelectCharacterButton"..characterIndex]
					button.Arrow:Hide()

					if characterIndex ~= CharSelectServicesFlowFrame.selectedCharacterIndex then
						button:Disable()
					end
				end

				CharacterBoostStep = CharacterBoostStep + 1

				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
				frame.CharacterServicesMaster.step2:Show()
			end
		end

		if not charSelected then
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", CHARACTER_NOT_FOUND)
		end
	elseif CharacterBoostStep == 2 then
		SelectMainProfession = GlueDark_DropDownMenu_GetSelectedValue(ChooseMainProffesionDropDown)
		SelectAdditionalProffesion = GlueDark_DropDownMenu_GetSelectedValue(ChooseAdditionalProffesionDropDown)
		if SelectMainProfession and SelectAdditionalProffesion then
			frame.CharacterServicesMaster.step2.choose:Hide()
			frame.CharacterServicesMaster.step2.finish:Show()
			frame.CharacterServicesMaster.step2.finish.Proffesion:SetText(string.format("%s, %s",
				MainProffesionList[SelectMainProfession].text,
				AdditionalProffesionList[SelectAdditionalProffesion].text
				))
			CharacterBoostStep = CharacterBoostStep + 1

			for i = 1, 3 do
				local button = frame.CharacterServicesMaster.step3.choose.SpecButtons[i]
				local spec = SHARED_CONSTANTS_SPECIALIZATION[self.classInfo.classFile][i]
				button.SpecName:SetText(spec.name)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-iconRole-"..spec.role) or "GlueDark-iconRole-DAMAGER")
				button.SpecIcon:SetTexture(spec.icon)
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
			end

			local button = frame.CharacterServicesMaster.step3.choose.SpecButtons[4];
			if self.classInfo.classFile == "DEATHKNIGHT" or self.classInfo.classFile == "DRUID" then
				local spec = SHARED_CONSTANTS_SPECIALIZATION[self.classInfo.classFile][4]
				button.SpecName:SetText(spec.name)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-iconRole-"..spec.role) or "GlueDark-iconRole-TANK")
				button.SpecIcon:SetTexture(spec.icon or "Interface\\Icons\\Ability_druid_catform")
				button.SpecIcon:SetDesaturated(spec.iconDesaturate)
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
				button:Show()
			else
				button:Hide()
			end

			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
			frame.CharacterServicesMaster.step3:Show()
		else
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", CHOOSE_ALL_PROFESSION)
		end
	elseif CharacterBoostStep == 3 then
		local CheckedSpec = false

		for _, button in ipairs(frame.CharacterServicesMaster.step3.choose.SpecButtons) do
			if button:GetChecked() then
				CheckedSpec = true
				SelectCharacterSpec = button:GetID()
				frame.CharacterServicesMaster.step3.finish.Spec:SetText(button.SpecName:GetText());
				break;
			end
		end

		if not CheckedSpec then
			GlueDialog:ShowDialog("OKAY", CHOOSE_SPECIALIZATION)
		else
			CheckedSpec = false
			frame.CharacterServicesMaster.step3.choose:Hide()
			frame.CharacterServicesMaster.step3.finish:Show()
			CharacterBoostStep = CharacterBoostStep + 1;

			for i = 1, 3 do
				local button = frame.CharacterServicesMaster.step4.choose.SpecButtons[i];
				local spec = SHARED_CONSTANTS_SPECIALIZATION[self.classInfo.classFile][i];
				button.SpecName:SetText(spec.name);
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-iconRole-"..spec.role) or "GlueDark-iconRole-DAMAGER")
				button.SpecIcon:SetTexture(spec.icon);
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
			end

			if CharacterBoostButton.isBoostPVPEnabled then
				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
				frame.CharacterServicesMaster.step4.choose.SpecButtons[4]:Hide();
				frame.CharacterServicesMaster.step4:Show()
			else
				SelectCharacterPvPSpec = 1
				if self.factionID == PLAYER_FACTION_GROUP.Neutral then
					PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
					CharacterBoostStep = CharacterBoostStep + 1;
					frame.CharacterServicesMaster.step5:Show();
				else
					PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
					self:Hide();
					GlueDialog:ShowDialog("CHARACTER_SERVICES_BOOST_CONFIRM");
				end
			end
		end
	elseif CharacterBoostStep == 4 then
		local CheckedSpec = false;

		for _, button in ipairs(frame.CharacterServicesMaster.step4.choose.SpecButtons) do
			if button:GetChecked() then
				CheckedSpec = true;
				SelectCharacterPvPSpec = button:GetID();
				frame.CharacterServicesMaster.step4.finish.Spec:SetText(button.SpecName:GetText());
				break;
			end
		end

		if not CheckedSpec then
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", CHOOSE_PVP_SPECIALIZATION);
		else
			CheckedSpec = false
			frame.CharacterServicesMaster.step4.choose:Hide();
			frame.CharacterServicesMaster.step4.finish:Show();

			if self.factionID == PLAYER_FACTION_GROUP.Neutral then
				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
				CharacterBoostStep = CharacterBoostStep + 1;
				frame.CharacterServicesMaster.step5:Show();
			else
				PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
				self:Hide();
				GlueDialog:ShowDialog("CHARACTER_SERVICES_BOOST_CONFIRM");
			end
		end
	elseif CharacterBoostStep == 5 then
		local selectedFactionButton

		for _, button in ipairs(frame.CharacterServicesMaster.step5.choose.FactionButtons) do
			if button:GetChecked() then
				selectedFactionButton = button:GetID()
				break
			end
		end

		if selectedFactionButton then
			SelectCharacterFaction = selectedFactionButton

			frame.CharacterServicesMaster.step5.choose:Hide()
			frame.CharacterServicesMaster.step5.finish:Show()
			frame.CharacterServicesMaster.step5.finish.Faction:SetText(selectedFactionButton == 1 and FACTION_HORDE or FACTION_ALLIANCE)

			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			self:Hide()

			GlueDialog:ShowDialog("CHARACTER_SERVICES_BOOST_CONFIRM")
		else
			GlueDialog:ShowDialog("OKAY", CHOOSE_FACTION)
		end
	end
end

function CharacterServices_StepSpec_OnLoad(self)
	self.SpecButtons = {}
	for i = 1, 4 do
		self.SpecButtons[i] = self["SpecButton"..i]
		self.SpecButtons[i].owner = self
	end
end

function CharacterServices_StepFaction_OnLoad(self)
	self.FactionButtons = {}
	for i = 1, 2 do
		self.FactionButtons[i] = self["FactionButton"..i]
		self.FactionButtons[i].owner = self
		self.FactionButtons[i].FactionIcon:SetTexture(factionLogoTextures[i])
		self.FactionButtons[i].FactionName:SetText(factionLabels[i])
	end
end

function CharacterServicesMaster_UpdateSteps()
	if CharacterBoostButton.isBoostPVPEnabled then
		CharacterServicesMaster.step5:SetPoint("TOP", 0, -340)
		CharacterServicesMaster.step5.choose.StepNumber:SetAtlas("GlueDark-fqtc5")

		CharacterServicesMaster.step5.choose.StepLine:ClearAllPoints()
		CharacterServicesMaster.step5.choose.StepLine:SetPoint("TOP", CharacterServicesMaster.step4.finish.StepBackdrop, "BOTTOM", 0, 20)
		CharacterServicesMaster.step5.choose.StepLine:SetPoint("BOTTOM", CharacterServicesMaster.step5.choose.StepBackdrop, "TOP", 1, -20)

		CharacterServicesMaster.step5.finish.StepLine:ClearAllPoints()
		CharacterServicesMaster.step5.finish.StepLine:SetPoint("TOP", CharacterServicesMaster.step4.finish.StepBackdrop, "BOTTOM", 0, 20)
		CharacterServicesMaster.step5.finish.StepLine:SetPoint("BOTTOM", CharacterServicesMaster.step5.finish.StepBackdrop, "TOP", 1, -20)
	else
		CharacterServicesMaster.step5:SetPoint("TOP", 0, -255)
		CharacterServicesMaster.step5.choose.StepNumber:SetAtlas("GlueDark-fqtc4")

		CharacterServicesMaster.step5.choose.StepLine:ClearAllPoints()
		CharacterServicesMaster.step5.choose.StepLine:SetPoint("TOP", CharacterServicesMaster.step3.finish.StepBackdrop, "BOTTOM", 0, 20)
		CharacterServicesMaster.step5.choose.StepLine:SetPoint("BOTTOM", CharacterServicesMaster.step5.choose.StepBackdrop, "TOP", 1, -20)

		CharacterServicesMaster.step5.finish.StepLine:ClearAllPoints()
		CharacterServicesMaster.step5.finish.StepLine:SetPoint("TOP", CharacterServicesMaster.step3.finish.StepBackdrop, "BOTTOM", 0, 20)
		CharacterServicesMaster.step5.finish.StepLine:SetPoint("BOTTOM", CharacterServicesMaster.step5.finish.StepBackdrop, "TOP", 1, -20)
	end
end

function CharacterServicesMaster_OnLoad(self)
	self.BottomShadow:SetVertexColor(0, 0, 0, 0.4)

	for i = 2, 4 do
		local f = self.CharacterServicesMaster["step"..i]
		f.choose.StepLine:ClearAllPoints()
		f.choose.StepLine:SetPoint("TOP", self.CharacterServicesMaster["step" .. (i - 1)].finish.StepBackdrop, "BOTTOM", 0, 20)
		f.choose.StepLine:SetPoint("BOTTOM", f.choose.StepBackdrop, "TOP", 1, -20)

		f.finish.StepLine:ClearAllPoints()
		f.finish.StepLine:SetPoint("TOP", self.CharacterServicesMaster["step" .. (i - 1)].finish.StepBackdrop, "BOTTOM", 0, 20)
		f.finish.StepLine:SetPoint("BOTTOM", f.finish.StepBackdrop, "TOP", 1, -20)
	end

	do
		Mixin(self, GlueEasingAnimMixin)
		self.basePoint = {self:GetPoint()}
		self.startPoint = -(self:GetWidth() + 35)
		self.endPoint = self.basePoint[4]
		self.duration = 0.500

		self.SetPosition = function(this, easing, progress)
			local alpha = progress and (this.isRevers and (1 - progress) or progress) or (this.isRevers and 0 or 1)

			this:SetAlpha(alpha)

			if easing then
				this:ClearAndSetPoint(self.basePoint[1], easing, self.basePoint[5])
			else
				this:ClearAndSetPoint(self.basePoint[1], this.isRevers and this.startPoint or this.endPoint, self.basePoint[5])
			end
		end
	end

	CharacterServicesMaster_UpdateSteps()

	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_STATUS_UPDATE")
	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_PURCHASE_STATUS")
	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_UTILIZATION_STATUS")
	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_OPEN")
end

function CharacterServicesMaster_OnEvent(self, event, ...)
	if event == "CHARACTER_SERVICES_BOOST_OPEN" then
		local characterIndex = ...
		CharacterSelect_OpenBoost(characterIndex, true)
	elseif event == "CHARACTER_SERVICES_BOOST_STATUS_UPDATE" then
		local status = ...

		local isDisabled = status == Enum.CharacterServices.BoostServiceStatus.Disabled

		local statusFrame = CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1

		CharacterBoostButton_UpdateState(isDisabled)

		if isDisabled then
			if CharacterBoostButton.ticker then
				CharacterBoostButton.ticker:Cancel()
				CharacterBoostButton.ticker = nil
			end

			CharacterBoostButton:SetText(CHARACTER_SERVICES_BUY)

			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1.Status:SetText(UNAVAILABLE)
			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1.Status:SetTextColor(1, 0, 0)
			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1:Show()
			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2:Hide()

			CharacterSelect.AllowService = false
		else
			CharacterBoostButton.isBoostPVPEnabled = C_CharacterServices.IsBoostHasPVPEquipment()
			CharacterBoostButton:SetText(status == Enum.CharacterServices.BoostServiceStatus.Purchased and CHARACTER_SERVICES_USE or CHARACTER_SERVICES_BUY)

			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1:SetShown(status == Enum.CharacterServices.BoostServiceStatus.Purchased)
			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2:SetShown(status == Enum.CharacterServices.BoostServiceStatus.Available)

			local seconds, expireAt = C_CharacterServices.GetBoostTimeleft()

			statusFrame.CharacterBoost:ClearAllPoints()
			statusFrame.Status:ClearAllPoints()

			if expireAt > 0 then
				statusFrame.CharacterBoost:SetPoint("TOP", 0, 0)
				statusFrame.Status:SetPoint("BOTTOM", 0, 15)
			else
				statusFrame.CharacterBoost:SetPoint("TOP", 0, -5)
				statusFrame.Status:SetPoint("BOTTOM", 0, 5)
			end

			if status == Enum.CharacterServices.BoostServiceStatus.Purchased then
				statusFrame.TimeRemaning:SetShown(expireAt and expireAt > 0)

				if expireAt and expireAt > 0 then
					statusFrame.TimeRemaning.Timestamp = time() + expireAt

					local remaningTime = statusFrame.TimeRemaning.Timestamp - time()

					statusFrame.TimeRemaning:SetFormattedText(TIME_REMANING, GetRemainingTime(remaningTime, true))

					if statusFrame.TimeRemaning.Timer then
						statusFrame.TimeRemaning.Timer:Cancel()
						statusFrame.TimeRemaning.Timer = nil
					end

					if remaningTime <= 86400 then
						statusFrame.TimeRemaning.Timer = C_Timer:NewTicker(1, function()
							local remaningTime2 = statusFrame.TimeRemaning.Timestamp - time()
							statusFrame.TimeRemaning:SetFormattedText(TIME_REMANING, GetRemainingTime(remaningTime2, true))
						end)
					end
				end

				CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1.Status:SetText(AVAILABLE)
				CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1.Status:SetTextColor(0, 1, 0)

				CharacterSelect.AllowService = true
			else
				local balance = C_CharacterServices.GetBalance()
				local price, priceOriginal, discount = C_CharacterServices.GetBoostPrice()

				if price == 0 then
					CharacterBoostBuyFrame:SetPrice(0)
				else
					CharacterBoostBuyFrame:SetPrice(price, priceOriginal)
				end

				CharacterBoostBuyFrame:UpdateBalance()

				if CharacterBoostButton.ticker then
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end

				if seconds < SECONDS_PER_DAY then
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetTextColor(1, 0, 0)
				else
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetTextColor(1, 1, 1)
				end

				if price ~= priceOriginal then
					local isPersonalSale = C_CharacterServices.IsBoostPersonal()
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(isPersonalSale and CHARACTER_SERVICES_PERSONAL_OFFER or CHARACTER_SERVICES_SPECIAL_OFFER)

					local tick = 0
					local ticktime = 7

					CharacterBoostButton.ticker = C_Timer:NewTicker(1, function()
						if CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:IsVisible() then
							seconds = seconds - 1
							tick = tick + 1

							if tick >= 0 and tick <= ticktime then
								CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(isPersonalSale and CHARACTER_SERVICES_PERSONAL_OFFER or CHARACTER_SERVICES_SPECIAL_OFFER)

								if tick >= ticktime then
									CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1.Anim:Play()
								end
							elseif tick >= ticktime and tick <= ticktime * 2 then
								CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetRemainingTime(seconds)

								if tick >= ticktime * 2 then
									tick = 0
									CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1.Anim:Play()
								end
							end
						else
							CharacterBoostButton.ticker:Cancel()
							CharacterBoostButton.ticker = nil
						end
					end, seconds)

					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_DISCOUNT, discount)
				end

				if price == 0 then
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(CHARACTER_SERVICES_VIP_GIFT)
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetText(CHARACTER_SERVICES_BOOST_FREE)
				else
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(CHARACTER_SERVICES_BUYBOOST)
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_COST, price)
				end

				CharacterSelect.AllowService = false
			end
		end
	elseif event == "CHARACTER_SERVICES_BOOST_PURCHASE_STATUS" then
		local success = ...

		if success then
			if CharacterBoostButton.ticker then
				CharacterBoostButton.ticker:Cancel()
				CharacterBoostButton.ticker = nil
			end

			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1:Show()
			CharSelectServicesFlowFrame:Show()
		end

		CharacterBoostBuyFrame:Hide()
	elseif event == "CHARACTER_SERVICES_BOOST_UTILIZATION_STATUS" then
		local success = ...

		if success then
			CharacterSelect.AutoEnterWorld = true
		end

		self:Hide()
	end
end

function CharacterServicesMaster_HidePanel(self)
	local pendingBoostCharacterListID, pendingBoostCharacterID, pendiongBoostCharacterPageIndex = C_CharacterList.GetPendingBoostDK()
	if pendingBoostCharacterListID ~= 0 and pendiongBoostCharacterPageIndex == C_CharacterList.GetCurrentPageIndex() and not IsGMAccount() then
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_BOOST_CANCEL_DEATH_KNIGHT)
	else
		self:Hide()
	end
end

function CharacterServicesMaster_OnWorldEnterAttempt()
	local characterID = GetCharIDFromIndex(CharacterSelect.selectedIndex)
	local _, _, class = GetCharacterInfo(characterID)
	local classInfo = C_CreatureInfo.GetClassInfo(class)

	if classInfo.classFile == "DEATHKNIGHT" and C_CharacterList.HasPendingBoostDK() then
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD_DEATH_KNIGHT)
	else
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD)
	end
end

function CharacterBoostButton_UpdateState( state )
	if state then
		local serverName, isPVP, isRP = GetServerName()
		CharacterBoostButton.tooltip = string.format(CHARACTER_BOOST_DISABLE_REALM, serverName)
	else
		CharacterBoostButton.tooltip = nil
	end
	CharacterBoostButton:SetEnabled(not state)
end

CharacterServiceDialogPriceMixin = {}
function CharacterServiceDialogPriceMixin:OnLoad()
	self.texturePool = CreateTexturePool(self.Container, "ARTWORK", nil, "GlueDark_fqtcAngled0", function(this, obj)
		obj:Hide()
		obj:ClearAllPoints()
		obj:SetAlpha(1)
	end)

	self.Container.TopShadow:SetVertexColor(0, 0, 0, 0.7)
	self.Container.Balance:SetPoint("TOP", self.Container.BuyButton, "BOTTOM", -11, -8)

	self.Container.Title:SetText(self:GetAttributeGlobalString("Title"))
	self.Container.PreDescription:SetText(self:GetAttributeGlobalString("PreDescription"))
	self.Container.Description:SetText(self:GetAttributeGlobalString("Description"))
	self.Container.Warning:SetText(self:GetAttributeGlobalString("WarningHTML"))

	local artworkAtlas = self:GetAttribute("ArtworkAtlas")
	if artworkAtlas then
		self.Container.Artwork:SetAtlas(artworkAtlas)
	else
		self.Container.Artwork:Hide()
	end

	self:RegisterCustomEvent("ACCOUNT_BALANCE_UPDATE")
end

function CharacterServiceDialogPriceMixin:OnEvent(event, ...)
	if event == "ACCOUNT_BALANCE_UPDATE" then
		self:UpdateBalance()
	end
end

function CharacterServiceDialogPriceMixin:OnShow()
	self:UpdateBalance()
end

function CharacterServiceDialogPriceMixin:GetAttributeGlobalString(attribute, fallback)
	local str = self:GetAttribute(attribute)
	if not str or str == "" then
		return fallback or ""
	end
	return _G[str] or fallback or ""
end

function CharacterServiceDialogPriceMixin:UpdateBalance()
	local balance = C_CharacterServices.GetBalance()

	self.Container.Balance:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, balance)

	if self.price then
		if self.price == 0 then
			self.Container.BuyButton:SetText(self:GetAttributeGlobalString("FreeUseText", CHARACTER_SERVICES_FREE_USE))
		elseif balance >= self.price or IsGMAccount(true) then
			self.Container.BuyButton:SetText(self:GetAttributeGlobalString("PurchaseText", CHARACTER_SERVICES_BUY))
		else
			self.Container.BuyButton:SetText(REPLENISH)
		end
	end
end

function CharacterServiceDialogPriceMixin:SetPrice(price, priceBase)
	local PRICE_WIDTH, PRICE_HEIGHT								= 21, 32
	local PRICE_WS_WIDTH, PRICE_WS_HEIGHT						= 17, 26
	local PRICE_SALE_WIDTH, PRICE_SALE_HEIGHT					= 11, 16
	local PRICE_PADDING_X, PRICE_PADDING_Y						= -1, 1
	local PRICE_WS_BASE_OFFSET_X, PRICE_WS_BASE_OFFSET_Y		= -21, 0
	local PRICE_SALE_BASE_OFFSET_X, PRICE_SALE_BASE_OFFSET_Y	= 38, 5

	if priceBase == price then
		priceBase = nil
	end

	price = tostring(price)
	self.price = tonumber(price)

	if self.OnPriceChanged then
		self:OnPriceChanged(self.price)
	end

	self.texturePool:ReleaseAll()

	if not self.price or self.price <= 0 then
		self.Container.Balance:Hide()
		self.Container.BalanceCurrencyIcon:Hide()
		self.Container.NoPrice:Show()
		self.Container.PriceCurrencyIcon:Hide()
		self.Container.StrikeThrough:Hide()
		return
	else
		self.Container.Balance:Show()
		self.Container.BalanceCurrencyIcon:Show()
		self.Container.NoPrice:Hide()
		self.Container.PriceCurrencyIcon:Show()
	end

	local haveBasePrice, firstTexture, prevTexture
	local length

	while price do
		length = string.len(price)
		for i = 1, length do
			local number = string.sub(price, i, i)
			local texture = self.texturePool:Acquire()
			texture:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-fqtcAngled"..number], 3, 6))

			if haveBasePrice then
				texture:SetSize(PRICE_SALE_WIDTH, PRICE_SALE_HEIGHT)
				texture:SetAlpha(0.8)
			elseif priceBase then
				texture:SetSize(PRICE_WS_WIDTH, PRICE_WS_HEIGHT)
			else
				texture:SetSize(PRICE_WIDTH, PRICE_HEIGHT)
			end

			if i == 1 then
				firstTexture = texture

				if haveBasePrice then	-- preSale price position
					texture:SetPoint("CENTER", self.Container.SaleBackdrop, "CENTER", PRICE_SALE_BASE_OFFSET_X + -(math.ceil((length * (PRICE_SALE_WIDTH + PRICE_PADDING_X) - PRICE_PADDING_X) / 2)), PRICE_SALE_BASE_OFFSET_Y + length * -PRICE_PADDING_Y)
				elseif priceBase then	-- sale price position
					texture:SetPoint("CENTER", self.Container.SaleBackdrop, "CENTER", PRICE_WS_BASE_OFFSET_X + (math.ceil((length * (-PRICE_WS_WIDTH + PRICE_PADDING_X) - PRICE_PADDING_X) / 2)), PRICE_WS_BASE_OFFSET_Y + length * -PRICE_PADDING_Y)
				else					-- price position
					texture:SetPoint("CENTER", self.Container.SaleBackdrop, "CENTER", math.ceil(length * (-PRICE_WIDTH + PRICE_PADDING_X) / 2), length * -PRICE_PADDING_Y)
				end
			else
				texture:SetPoint("BOTTOMLEFT", prevTexture, "BOTTOMRIGHT", PRICE_PADDING_X, PRICE_PADDING_Y)
			end

			texture:Show()
			prevTexture = texture
		end

		if not haveBasePrice then
			price = priceBase and tostring(priceBase) or nil
			haveBasePrice = price and true or false
		else
			break
		end
	end

	if haveBasePrice then
		self.Container.PriceCurrencyIcon:SetPoint("CENTER", "$parentSaleBackdrop", 4, 0)

		self.Container.StrikeThrough:SetRotation(math.rad(4 + length * 2))
		self.Container.StrikeThrough:ClearAllPoints()
		self.Container.StrikeThrough:SetPoint("BOTTOMLEFT", firstTexture, "BOTTOMLEFT", 0, PRICE_SALE_HEIGHT / 2 - 15)
		self.Container.StrikeThrough:SetPoint("BOTTOMRIGHT", prevTexture, "BOTTOMRIGHT", 2, PRICE_SALE_HEIGHT / 2 - 3)
		self.Container.StrikeThrough:Show()
	else
		self.Container.PriceCurrencyIcon:SetPoint("CENTER", "$parentSaleBackdrop", 30, 2)
		self.Container.StrikeThrough:Hide()
	end
end

function CharacterServiceDialogPriceMixin:SetPurchaseArgs(...)
	self.purchaseArgs = {...}
end

CharacterServiceBoostPurchaseMixin = CreateFromMixins(CharacterServiceDialogPriceMixin)

function CharacterServiceBoostPurchaseMixin:OnLoad()
	CharacterServiceDialogPriceMixin.OnLoad(self)
end

function CharacterServiceBoostPurchaseMixin:Purchase()
	if C_CharacterServices.GetBalance() >= C_CharacterServices.GetBoostPrice() or IsGMAccount(true) then
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
		self:Hide()
		C_CharacterServices.PurchaseBoost()
	else
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT)
		self:Hide()
		C_CharacterServices.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end
end

CharacterServiceRestoreCharacterMixin = CreateFromMixins(CharacterServiceDialogPriceMixin)

function CharacterServiceRestoreCharacterMixin:OnLoad()
	CharacterServiceDialogPriceMixin.OnLoad(self)

	self.Container.Artwork:SetSize(273, 244)
	self.Container.Artwork:SetPoint("TOPRIGHT", -15, -80)

	self.Container.Description:SetPoint("TOPLEFT", 18, -103)
	self.Container.Warning:SetPoint("TOP", self.Container.Description, "BOTTOM", 0, -30)
end

function CharacterServiceRestoreCharacterMixin:OnPriceChanged(price)
	if price == 0 then
		self.Container.Description:SetWidth(300)
		self.Container.Warning:Show()
	else
		self.Container.Description:SetWidth(280)
		self.Container.Warning:Hide()
	end
end

function CharacterServiceRestoreCharacterMixin:Purchase()
	if C_CharacterServices.GetBalance() >= C_CharacterServices.GetCharacterRestorePrice() or IsGMAccount(true) then
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_DEL_CHARACTER)
		self:Hide()
		C_CharacterServices.PurchaseRestoreCharacter(unpack(self.purchaseArgs))
	else
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT)
		self:Hide()
		C_CharacterServices.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.CharRestore)
	end
end

CharacterServicePagePurchaseMixin = CreateFromMixins(CharacterServiceDialogPriceMixin)

function CharacterServicePagePurchaseMixin:OnLoad()
	CharacterServiceDialogPriceMixin.OnLoad(self)

	self.Container.Artwork:SetSize(291, 254)
	self.Container.Artwork:SetPoint("TOPRIGHT", -10, -80)
end

function CharacterServicePagePurchaseMixin:Purchase()
	if C_CharacterServices.GetBalance() >= C_CharacterServices.GetListPagePrice() or IsGMAccount(true) then
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
		self:Hide()
		C_CharacterServices.PurchaseCharacterListPage()
	else
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT)
		self:Hide()
		C_CharacterServices.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.CharListPage)
	end
end

function CharacterServicePagePurchaseMixin:SetAltDescription(isAlt)
	if isAlt then
		self.Container.Description:SetPoint("TOPLEFT", 18, -108)
		self.Container.Description:SetText(CHARACTER_SERVICES_LISTPAGE_DESCRIPTION_ALT)
		self.Container.Warning:Show()
	else
		self.Container.Description:SetPoint("TOPLEFT", 18, -83)
		self.Container.Description:SetText(CHARACTER_SERVICES_LISTPAGE_DESCRIPTION)
		self.Container.Warning:Hide()
	end
end