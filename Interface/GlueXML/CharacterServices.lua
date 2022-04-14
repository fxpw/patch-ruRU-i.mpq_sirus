--	Filename:	CharacterServices.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

-- Ебаная хуйня, срочно переписать, ужасный быдлокод, пиздец просто (с) Nyll

CharacterBoostStep = 1
local SelectMainProfession
local SelectAdditionalProffesion
local SelectCharacterSpec
local SelectCharacterPvPSpec
local SelectCharacterFaction = 0
local accountBonusCount = nil
local characterBoostPrice = nil

GlueDialogTypes["LOCK_BOOST_ENTER_WORLD"] = {
	text = CHARACTER_SERVICES_DIALOG_BOOST_ENTERWORLD,
	button1 = YES,
	button2 = NO,
	escapeHides = false,
	OnAccept = function ()
		CharSelectServicesFlowFrame:Hide()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CHARACTER_SERVICES_BOOST_CONFIRM"] = {
	text = CHARACTER_BOOST_CONFIRM_TEXT,
	button1 = YES,
	button2 = NO,
	escapeHides = false,
	OnAccept = function ()
		if inRealmScourge() then
			SendPacket("00", CharSelectServicesFlowFrame.CharSelect, SelectAdditionalProffesion, SelectMainProfession, SelectCharacterSpec, SelectCharacterPvPSpec, SelectCharacterFaction)
		else
			C_SendOpcode(CMSG_SIRUS_BOOST_CHARACTER, GetCharIDFromIndex(CharSelectServicesFlowFrame.CharSelect), SelectAdditionalProffesion, SelectMainProfession, SelectCharacterSpec, SelectCharacterPvPSpec, SelectCharacterFaction)
		end
		WaitingDialogFrame:Show()
		WaitingDialogFrame.Text:SetText(WAIT_SERVER_RESPONCE)
	end,
	OnCancel = function()
		CharSelectServicesFlowFrame:Hide()
	end,
}

GlueDialogTypes["BOOST_ERROR_NOT_ENOUGH_BONUES"] = {
	text = NOT_ENOUGH_BONUSES_TO_BUY_A_CHARACTER_BOOST,
	button1 = DONATE,
	button2 = CLOSE,
	escapeHides = false,
	OnAccept = function ()
		LaunchURL("https://sirus.su/user/pay#/?bonuses="..CharacterBoost_CalculatePayBonuses())
	end,
	OnCancel = function()
		-- printc("OnCancel")
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

function CharacterBoost_DisableCharacterSelect( index, bool )
	local button = _G["CharSelectCharacterButton"..index]
	local nameText = button.buttonText.name
	local infoText = button.buttonText.Info
	local locationText = button.buttonText.Location

	if bool then
		nameText:SetTextColor(0.30, 0.3, 0.31)
		infoText:SetTextColor(0.30, 0.3, 0.31)
		locationText:SetTextColor(0.30, 0.3, 0.31)
		button:Disable()
	else
		nameText:SetTextColor(1.0, 0.78, 0)
		infoText:SetTextColor(1, 1, 1)
		locationText:SetTextColor(0.5, 0.5, 0.5)
		button:Enable()
	end
end

function CharacterBoost_CharacterInit( bool )
	local numChars = GetNumCharacters()
	local characterLimit = min(numChars, MAX_CHARACTERS_DISPLAYED)
	for i=1, characterLimit, 1 do
		local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(i))
		local button = _G["CharSelectCharacterButton"..i]
		if bool then
			if level < 80 then
				CharacterBoost_DisableCharacterSelect(i, false)
				button.Arrow:Show()
				button.selection:Hide()
			else
				CharacterBoost_DisableCharacterSelect(i, true)
				button.selection:Hide()
			end
		else
			CharacterBoost_DisableCharacterSelect(i, false)
			button.Arrow:Hide()
		end
	end
	CharSelectServicesFlowFrame.GlowBox:SetHeight(58 * characterLimit)
	CharSelectServicesFlowFrame.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, 0.5, -60)
	CharSelectServicesFlowFrame.GlowBox:SetWidth(248)
end

local MainProffesionList = {}
local AdditionalProffesionList = {}

function ChooseMainProffesionDropDown_OnClick( self )
	GlueDropDownMenu_SetSelectedValue(ChooseMainProffesionDropDown, self.value)
end

function ChooseAdditionalProffesionDropDown_OnClick( self )
	GlueDropDownMenu_SetSelectedValue(ChooseAdditionalProffesionDropDown, self.value)
end

 MainProffesionList[1] = {
 	["text"] = TRADESKILL_ALCHEMY,
	["value"] = 1,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[2] = {
 	["text"] = TRADESKILL_ENGINEERING,
	["value"] = 2,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[3] = {
 	["text"] = TRADESKILL_LEATHERWORKING,
	["value"] = 3,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[4] = {
 	["text"] = TRADESKILL_BLACKSMITHING,
	["value"] = 4,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[5] = {
 	["text"] = TRADESKILL_ENCHANTING,
	["value"] = 5,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[6] = {
 	["text"] = TRADESKILL_INSCRIPTION,
	["value"] = 6,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[7] = {
 	["text"] = TRADESKILL_JEWELCRAFTING,
	["value"] = 7,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }
 MainProffesionList[8] = {
 	["text"] = TRADESKILL_TAILORING,
	["value"] = 8,
 	["selected"] = selected,
 	func = ChooseMainProffesionDropDown_OnClick
 }

 AdditionalProffesionList[1] = {
 	["text"] = TRADESKILL_MINING,
	["value"] = 1,
 	["selected"] = selected,
 	func = ChooseAdditionalProffesionDropDown_OnClick
 }
 AdditionalProffesionList[2] = {
 	["text"] = TRADESKILL_HERBALISM,
	["value"] = 2,
 	["selected"] = selected,
 	func = ChooseAdditionalProffesionDropDown_OnClick
 }
 AdditionalProffesionList[3] = {
 	["text"] = TRADESKILL_SKINNING,
	["value"] = 3,
 	["selected"] = selected,
 	func = ChooseAdditionalProffesionDropDown_OnClick
 }

function CharacterServicesMasterMainDropDown_Initialize()
	local selectedValueMain = GlueDropDownMenu_GetSelectedValue(ChooseMainProffesionDropDown)

	for i = 1, #MainProffesionList do
		MainProffesionList[i].checked = (MainProffesionList[i].text == selectedValueMain)
		GlueDropDownMenu_AddButton(MainProffesionList[i])
	end
end

function CharacterServicesMasterAdditionalDropDown_Initialize()
	local selectedValueAdditional = GlueDropDownMenu_GetSelectedValue(ChooseAdditionalProffesionDropDown)

	for i = 1, #AdditionalProffesionList do
		AdditionalProffesionList[i].checked = (AdditionalProffesionList[i].text == selectedValueMain)
		GlueDropDownMenu_AddButton(AdditionalProffesionList[i])
	end
end

function CharacterServicesMaster_OnShow( self, ... )
	CharacterBoostStep = 1
	SelectCharacterFaction = 0
	CharSelectServicesFlowFrame.CharSelect = nil

	self.characterUndeleteStatus = CharSelectUndeleteCharacterButton:IsEnabled()
    self.characterCreateStatus   = CharSelectCreateCharacterButton:IsEnabled()

	CharSelectUndeleteCharacterButton:Disable()
	CharacterBoostButton:Hide()
	CharSelectEnterWorldButton:Disable()
	CharSelectCreateCharacterButton:Disable()
	CharacterSelectAddonsButton:Hide()
	CharSelectChangeRealmButton:Disable()
	CharacterSelectBackButton:Disable()
	CharacterSelectDeleteButton:Disable()
	self.NextButton:Show()

    self.CharacterServicesMaster.step1.choose.CreateNewCharacter:SetEnabled(self.characterCreateStatus == 1)

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

	CharacterBoost_CharacterInit(true)

	for i = 1, #MainProffesionList do
		GlueDropDownMenu_SetSelectedName(ChooseMainProffesionDropDown, nil)
		GlueDropDownMenu_SetText(MAIN_PROFESSION, ChooseMainProffesionDropDown)
	end

	for i = 1, #AdditionalProffesionList do
		GlueDropDownMenu_SetSelectedName(ChooseAdditionalProffesionDropDown, nil)
		GlueDropDownMenu_SetText(SECONDARY_PROFESSION, ChooseAdditionalProffesionDropDown)
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
	local numChars = GetNumCharacters()

	if self.characterUndeleteStatus == 1 then
		CharSelectUndeleteCharacterButton:Enable()
	end

    if self.characterCreateStatus == 1 then
        CharSelectCreateCharacterButton:Enable()
    end

	CharacterBoostButton:Show()
	CharSelectEnterWorldButton:Enable()
	UpdateAddonButton()
	CharSelectChangeRealmButton:Enable()
	CharacterSelectBackButton:Enable()
	CharacterSelectDeleteButton:Enable()
	UpdateCharacterSelection()

	CharacterBoost_CharacterInit(false)
end

function CharacterServicesMasterNextButton_OnClick( self, ... )
	local frame = self:GetParent()
	if CharacterBoostStep == 1 then
		if ( frame.CharSelect ) then
			local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(frame.CharSelect))
			self.race = race
			local numChars = GetNumCharacters()
			local characterLimit = min(numChars, MAX_CHARACTERS_DISPLAYED)

			frame.CharacterServicesMaster.step1.choose:Hide()
			frame.CharacterServicesMaster.step1.finish:Show()
			frame.GlowBox:Hide()

			local classInfo = C_CreatureInfo.GetClassInfo(class)
			local _, _, _, color = GetClassColor(classInfo.classFile)
			frame.CharacterServicesMaster.step1.finish.Character:SetFormattedText(CHARACTER_BOOST_CHARACTER_PATTERN, color, name, level, class)

			for i=1, characterLimit, 1 do
				local button = _G["CharSelectCharacterButton"..i]
				button.Arrow:Hide()

				if i ~= frame.CharSelect then
					CharacterBoost_DisableCharacterSelect(i, true)
				end
			end
			CharacterBoostStep = CharacterBoostStep + 1
			frame.CharacterServicesMaster.step2:Show()
		else
			GlueDialog_Show("OKAY", "Персонаж не выбран")
		end
	elseif CharacterBoostStep == 2 then
		SelectMainProfession = GlueDropDownMenu_GetSelectedValue(ChooseMainProffesionDropDown)
		SelectAdditionalProffesion = GlueDropDownMenu_GetSelectedValue(ChooseAdditionalProffesionDropDown)
		if SelectMainProfession and SelectAdditionalProffesion then
			frame.CharacterServicesMaster.step2.choose:Hide()
			frame.CharacterServicesMaster.step2.finish:Show()
			frame.CharacterServicesMaster.step2.finish.Proffesion:SetText(string.format("%s, %s",
				MainProffesionList[SelectMainProfession].text,
				AdditionalProffesionList[SelectAdditionalProffesion].text
				))
			CharacterBoostStep = CharacterBoostStep + 1

			local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(CharSelectServicesFlowFrame.CharSelect));
			local classInfo = C_CreatureInfo.GetClassInfo(class)

			for i = 1, 3 do
				local button = frame.CharacterServicesMaster.step3.choose.SpecButtons[i]
				local spec = SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile][i]
				button.SpecName:SetText(spec.name)
				button.RoleIcon:SetTexCoord(GetTexCoordsForRole(spec.role))
				button.SpecIcon:SetTexture(spec.icon)
			end

			local extraButton = frame.CharacterServicesMaster.step3.choose.SpecButtons[4];
			if classInfo.classFile == "DEATHKNIGHT" then
				extraButton.SpecName:SetText(ROLE_TANK);
				extraButton.RoleIcon:SetTexCoord(GetTexCoordsForRole("TANK"));
				extraButton.SpecIcon:SetTexture("Interface\\Icons\\spell_deathknight_bloodpresence");
				extraButton.SpecIcon:SetDesaturated(true);
				extraButton:Show();
			else
				extraButton:Hide();
			end

			frame.CharacterServicesMaster.step3:Show()
		else
			GlueDialog_Show("OKAY", CHOOSE_ALL_PROFESSION)
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
			GlueDialog_Show("OKAY", CHOOSE_SPECIALIZATION)
		else
			CheckedSpec = false
			frame.CharacterServicesMaster.step3.choose:Hide()
			frame.CharacterServicesMaster.step3.finish:Show()
			CharacterBoostStep = CharacterBoostStep + 1;

			local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(CharSelectServicesFlowFrame.CharSelect));
			local classInfo = C_CreatureInfo.GetClassInfo(class);

			for i = 1, 3 do
				local button = frame.CharacterServicesMaster.step4.choose.SpecButtons[i];
				local spec = SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile][i];
				button.SpecName:SetText(spec.name);
				button.RoleIcon:SetTexCoord(GetTexCoordsForRole(spec.role));
				button.SpecIcon:SetTexture(spec.icon);
			end

			if CharacterBoostButton.isBoostPVPEnabled then
				frame.CharacterServicesMaster.step4.choose.SpecButtons[4]:Hide();
				frame.CharacterServicesMaster.step4:Show()
			else
				SelectCharacterPvPSpec = 1
				if self.race == PANDAREN_ALLIANCE or self.race == RACE_VULPERA_NEUTRAL then
					CharacterBoostStep = CharacterBoostStep + 1;
					frame.CharacterServicesMaster.step5:Show();
				else
					self:Hide();
					GlueDialog_Show("CHARACTER_SERVICES_BOOST_CONFIRM");
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
			GlueDialog_Show("OKAY", CHOOSE_PVP_SPECIALIZATION);
		else
			CheckedSpec = false
			frame.CharacterServicesMaster.step4.choose:Hide();
			frame.CharacterServicesMaster.step4.finish:Show();

			if self.race == PANDAREN_ALLIANCE or self.race == RACE_VULPERA_NEUTRAL then
				CharacterBoostStep = CharacterBoostStep + 1;
				frame.CharacterServicesMaster.step5:Show();
			else
				self:Hide();
				GlueDialog_Show("CHARACTER_SERVICES_BOOST_CONFIRM");
			end
		end
	elseif CharacterBoostStep == 5 then
		local SelectFaction = (frame.CharacterServicesMaster.step5.choose.FactionButtons[1]:GetChecked()) and FACTION_HORDE or FACTION_ALLIANCE
		local CheckFaction = false

		for _, button in pairs(frame.CharacterServicesMaster.step5.choose.FactionButtons) do
			if button:GetChecked() then
				SelectCharacterFaction = button:GetID()
				CheckFaction = true
			end
		end
		if not CheckFaction then
			GlueDialog_Show("OKAY", CHOOSE_FACTION)
		else
			CheckFaction = false
			frame.CharacterServicesMaster.step5.choose:Hide()
			frame.CharacterServicesMaster.step5.finish:Show()
			frame.CharacterServicesMaster.step5.finish.Faction:SetText(SelectFaction)

			self:Hide()
			GlueDialog_Show("CHARACTER_SERVICES_BOOST_CONFIRM")
		end
	end
end

function CharacterServices_UpdateFactionButtons(parentFrame, owner)
	parentFrame.FactionButtons = {}
	for i = 1, 2 do
		parentFrame.FactionButtons[i] = CreateFrame("CheckButton", nil, parentFrame, "CharacterUpgradeSelectFactionRadioButtonTemplate")
		if i == 1 then
			parentFrame.FactionButtons[i]:SetPoint("LEFT", 50, -15)
		else
			parentFrame.FactionButtons[i]:SetPoint("LEFT", 50, -70)
		end
		parentFrame.FactionButtons[i]:SetID(i)


		local button = parentFrame.FactionButtons[i]
		button.owner = owner
		button.FactionIcon:SetTexture(factionLogoTextures[i])
		button.FactionName:SetText(factionLabels[i])
		button:SetChecked(0)
		button:Show()
	end
end

function CharacterServices_UpdateSpecButtons(parentFrame, owner)
	parentFrame.SpecButtons = {}
	for i = 1, 4 do
		parentFrame.SpecButtons[i] = CreateFrame("CheckButton", nil, parentFrame, "CharacterUpgradeSelectSpecRadioButtonTemplate")
		if i == 1 then
			parentFrame.SpecButtons[i]:SetPoint("LEFT", 50, -15)
		else
			parentFrame.SpecButtons[i]:SetPoint("TOP", parentFrame.SpecButtons[i - 1], "BOTTOM", 0, -35)
		end
		parentFrame.SpecButtons[i]:SetID(i)

		local button = parentFrame.SpecButtons[i]
		button.owner = owner
		button:SetChecked(0)
		button:Show()
	end
end

function CharacterBoost_CalculatePayBonuses()
	if accountBonusCount and characterBoostPrice then
		local requiredBonuses = characterBoostPrice - accountBonusCount

		requiredBonuses = requiredBonuses < 10 and 10 or requiredBonuses

		if requiredBonuses > 50 and requiredBonuses < 60 then
			requiredBonuses = 60
		elseif requiredBonuses > 100 and requiredBonuses < 120 then
			requiredBonuses = 120
		end

		return requiredBonuses or 0
	end
end

function CharacterBoostBuyFrameBuyButton_OnClick( self, ... )
	if self.NoBonus then
		CharacterBoostBuyFrame:Hide()
		LaunchURL("https://sirus.su/user/pay#/?bonuses="..CharacterBoost_CalculatePayBonuses())
	else
		if inRealmScourge() then
			SendPacket("1")
		else
			C_SendOpcode(CMSG_SIRUS_BOOST_BUY)
		end
		CharacterBoostBuyFrame:Hide()
		WaitingDialogFrame:Show()
		WaitingDialogFrame.Text:SetText(WAIT_SERVER_RESPONCE)
	end
end

function CharacterServicesMaster_OnEvent( self, event, ts, ss, body )
	local opcode, arg, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = strsplit(":", body)
	--          activ price balans sale nprice psale timer
	arg = tonumber(arg)
	arg2 = tonumber(arg2)
	arg3 = tonumber(arg3)
	arg4 = tonumber(arg4)
	arg5 = tonumber(arg5)
	arg6 = tonumber(arg6)
	arg7 = tonumber(arg7)
	arg8 = tonumber(arg8)
	arg9 = tonumber(arg9)

	-- printc("opcode", opcode, "activ:", arg,  "price:", arg2, "balans:", arg3, "sale:", arg4, "nprice:", arg5, "psale:", arg6, "timer:", arg7, "arg8:", arg8, arg9)

	if opcode and arg then
		if opcode == "SMSG_BOOST_STATUS" then
			local statusFrame = CharacterBoostButton.MainPanel.Status1

			CharacterBoostButton.isBoostDisable = arg == -1
			CharacterBoostButton_UpdateState(CharacterBoostButton.isBoostDisable)
			CharacterBoostButton.isBoostPVPEnabled = arg9 == 1

			CharacterBoostButton.MainPanel.Status1:SetShown(arg == 1)
			CharacterBoostButton.MainPanel.Status2:SetShown(arg ~= 1)

			statusFrame.Status:ClearAllPoints()

			if arg8 and arg8 > 0 then
				statusFrame.Status:SetPoint("TOP", statusFrame, "TOP", 0, -12)
			else
				statusFrame.Status:SetPoint("CENTER", 0, 0)
			end

			if arg ~= 1 and arg2 and arg3 then

				local cost = arg5 ~= 0 and arg5 or arg2
				local sale = math.floor(( 1 - (arg5 / arg2)) * 100)
				local tick = 0
				local ticktime = 7

				accountBonusCount = arg3
				characterBoostPrice = cost

				if arg4 == 1 and arg5 == 0 then
					CharacterBoostBuyFrame.Container.Cost:SetText(CHARACTER_SERVICES_BOOST_COST_FREE)
				else
					CharacterBoostBuyFrame.Container.Cost:SetFormattedText(CHARACTER_SERVICES_BOOST_COST, cost)
				end
				CharacterBoostBuyFrame.Container.MyBonus:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, arg3)
				CharacterBoostBuyFrame.Container.BuyButton:SetText(CHARACTER_SERVICES_BUY)
				CharacterBoostBuyFrame.Container.BuyButton.NoBonus = false

				if arg3 == 0 and not arg4 == 1 and not arg5 == 0 then
					CharacterBoostBuyFrame.Container.MyBonus:SetText(CHARACTER_SERVICES_YOU_DONT_HAVE_BONUS)
					CharacterBoostBuyFrame.Container.BuyButton:SetText(REPLENISH)
					CharacterBoostBuyFrame.Container.BuyButton.NoBonus = true
				elseif arg3 < arg2 and not arg4 == 1 and not arg5 == 0 then
					CharacterBoostBuyFrame.Container.MyBonus:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, arg3)
					CharacterBoostBuyFrame.Container.BuyButton:SetText(REPLENISH)
					CharacterBoostBuyFrame.Container.BuyButton.NoBonus = true
				end
--[[
				if arg2 == 0 then
					CharacterBoostButton:Hide()
					return
				end
]]
				if CharacterBoostButton.ticker then
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end

				if arg7 < 86400 then
					CharacterBoostButton.MainPanel.Status2.Status1:SetTextColor(1, 0, 0)
				else
					CharacterBoostButton.MainPanel.Status2.Status1:SetTextColor(1, 1, 1)
				end

				if arg5 > 0 then
					if arg6 == 0 then
						CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_SPECIAL_OFFER)
					elseif arg6 == 1 then
						CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_PERSONAL_OFFER)
					end
					CharacterBoostButton.ticker = C_Timer:NewTicker(1, function()
						if CharacterBoostButton.MainPanel.Status2.Status1:IsVisible() then
							arg7 = arg7 - 1
							tick = tick + 1

							if tick >= 0 and tick <= ticktime then
								if arg6 == 0 then
									CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_SPECIAL_OFFER)
								elseif arg6 == 1 then
									CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_PERSONAL_OFFER)
								end
								if tick >= ticktime then
									CharacterBoostButton.MainPanel.Status2.Status1.Anim:Play()
								end
							elseif tick >= ticktime and tick <= ticktime * 2 then
								CharacterBoostButton.MainPanel.Status2.Status1:SetRemainingTime(arg7)
								if tick >= ticktime * 2 then
									tick = 0
									CharacterBoostButton.MainPanel.Status2.Status1.Anim:Play()
								end
							end

						else
							CharacterBoostButton.ticker:Cancel()
							CharacterBoostButton.ticker = nil
						end
					end, arg7)
					CharacterBoostButton.MainPanel.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_DISCOUNT, sale)
				end

				if arg5 == 0 and arg4 == 1 then
					CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_VIP_GIFT)
					CharacterBoostButton.MainPanel.Status2.Status2:SetText(CHARACTER_SERVICES_BOOST_FREE)
				end


				if arg ~= 1 and arg5 == 0 and arg4 ~= 1 then
					CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_BUY)
					CharacterBoostButton.MainPanel.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_COST, cost)
				end
				CharacterSelect.AllowService = false
			elseif arg == 1 then
				statusFrame.TimeRemaning:SetShown(arg8 and arg8 > 0)

				if arg8 and arg8 > 0 then
					statusFrame.TimeRemaning.Timestamp = time() + arg8

					local remaningTime = statusFrame.TimeRemaning.Timestamp - time()

					statusFrame.TimeRemaning:SetFormattedText(TIME_REMANING, GetRemainingTime(remaningTime, true))

					if statusFrame.TimeRemaning.Timer then
						statusFrame.TimeRemaning.Timer:Cancel()
						statusFrame.TimeRemaning.Timer = nil
					end

					if remaningTime <= 86400 then
						statusFrame.TimeRemaning.Timer = C_Timer:NewTicker(1, function()
							local remaningTime = statusFrame.TimeRemaning.Timestamp - time()
							statusFrame.TimeRemaning:SetFormattedText(TIME_REMANING, GetRemainingTime(remaningTime, true))
						end)
					end
				end

				CharacterSelect.AllowService = true
			end
		elseif opcode == "SMSG_BUY_BOOST_RESULT" then
			if arg == 0 then
				SendPacket("0")

				if CharacterBoostButton.ticker then
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end

				CharacterBoostButton.MainPanel.Status1:Show()
				CharacterBoostBuyFrame:Hide()
				if not CharSelectServicesFlowFrame:IsShown() then
					CharSelectServicesFlowFrame:Show()
				end
				GlueDialog_Show("OKAY", CHARACTER_SERVICES_BUY_BOOST_RESULT)
			elseif arg == 1 then
				CharacterBoostBuyFrame:Hide()
				GlueDialog_Show("BOOST_ERROR_NOT_ENOUGH_BONUES")
			elseif arg == 11 then
				GlueDialog_Show("OKAY_HTML", CHARACTER_BOOST_DISABLE_SUSPECT_ACCOUNT)
			elseif arg then
				local errorText = _G[string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", arg)]
				if errorText then
					GlueDialog_Show("OKAY", errorText)
				end
			end
			WaitingDialogFrame:Hide()
		elseif opcode == "SMG_FINISH_BOOST_RESULT" then
			if arg == 0 then
				WaitingDialogFrame:Hide()
				CharSelectServicesFlowFrame:Hide()
				GetCharacterListUpdate()
				CharacterSelect.AutoEnterWorld = true
			elseif arg == 6 or arg == 11 then
				GlueDialog_Show("OKAY_HTML", CHARACTER_BOOST_DISABLE_SUSPECT_ACCOUNT)
				WaitingDialogFrame:Hide()
				CharSelectServicesFlowFrame:Hide()
			elseif arg == 12 then
				GlueDialog_Show("OKAY", CHARACTER_BOOST_DISABLE_REALM)
				WaitingDialogFrame:Hide()
				CharSelectServicesFlowFrame:Hide()
			else
				GlueDialog_Show("OKAY", CHARACTER_SERVICES_BOOST_ERROR .. arg)
				WaitingDialogFrame:Hide()
				CharSelectServicesFlowFrame:Hide()
			end
		end
	end
end

function CharacterBoostButton_OnShow( self, ... )
	self.Chains1:SetDesaturated(1)
	self.Chains2:SetDesaturated(1)
	self.Border:SetDesaturated(1)
end

function CharacterBoostButton_UpdateState( state )
	if state then
		local serverName, isPVP, isRP = GetServerName()
		CharacterBoostButton.tooltip = string.format(CHARACTER_BOOST_DISABLE_REALM, serverName)
	else
		CharacterBoostButton.tooltip = nil
	end
	CharacterBoostButton:SetEnabled(not state)
	CharacterBoostButton.MainPanel:SetShown(not state)
end

function EventHandler:SMSG_SIRUS_BOOST_STATUS(active, boostPrice, balance, haveDiscount, newPrice, isPersonal, seconds)
    CharacterBoostButton.MainPanel.Status1:SetShown(active)
	CharacterBoostButton.MainPanel.Status2:SetShown(not active)

	if not active and boostPrice and balance then
		local cost = newPrice ~= 0 and newPrice or boostPrice
		local sale = math.floor(( 1 - (newPrice / boostPrice)) * 100)
		local tick = 0
		local ticktime = 7

		if haveDiscount == 1 and newPrice == 0 then
			CharacterBoostBuyFrame.Container.Cost:SetText(CHARACTER_SERVICES_BOOST_COST_FREE)
		else
			CharacterBoostBuyFrame.Container.Cost:SetFormattedText(CHARACTER_SERVICES_BOOST_COST, cost)
		end

		CharacterBoostBuyFrame.Container.MyBonus:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, balance)
		CharacterBoostBuyFrame.Container.BuyButton:SetText(CHARACTER_SERVICES_BUY)
		CharacterBoostBuyFrame.Container.BuyButton.NoBonus = false

		if balance == 0 and not haveDiscount == 1 and not newPrice == 0 then
			CharacterBoostBuyFrame.Container.MyBonus:SetText(CHARACTER_SERVICES_YOU_DONT_HAVE_BONUS)
			CharacterBoostBuyFrame.Container.BuyButton:SetText(REPLENISH)
			CharacterBoostBuyFrame.Container.BuyButton.NoBonus = true
		elseif balance < boostPrice and not haveDiscount == 1 and not newPrice == 0 then
			CharacterBoostBuyFrame.Container.MyBonus:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, balance)
			CharacterBoostBuyFrame.Container.BuyButton:SetText(REPLENISH)
			CharacterBoostBuyFrame.Container.BuyButton.NoBonus = true
		end

		if boostPrice == 0 then
			CharacterBoostButton:Hide()
			return
		end

		if CharacterBoostButton.ticker then
			CharacterBoostButton.ticker:Cancel()
			CharacterBoostButton.ticker = nil
		end

		if seconds < 86400 then
			CharacterBoostButton.MainPanel.Status2.Status1:SetTextColor(1, 0, 0)
		else
			CharacterBoostButton.MainPanel.Status2.Status1:SetTextColor(1, 1, 1)
		end

		if newPrice > 0 then
			if isPersonal == 0 then
				CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_SPECIAL_OFFER)
			elseif isPersonal == 1 then
				CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_PERSONAL_OFFER)
			end
			CharacterBoostButton.ticker = C_Timer:NewTicker(1, function()
				if CharacterBoostButton.MainPanel.Status2.Status1:IsVisible() then
					seconds = seconds - 1
					tick = tick + 1

					if tick >= 0 and tick <= ticktime then
						if isPersonal == 0 then
							CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_SPECIAL_OFFER)
						elseif isPersonal == 1 then
							CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_PERSONAL_OFFER)
						end
						if tick >= ticktime then
							CharacterBoostButton.MainPanel.Status2.Status1.Anim:Play()
						end
					elseif tick >= ticktime and tick <= ticktime * 2 then
						CharacterBoostButton.MainPanel.Status2.Status1:SetRemainingTime(seconds)
						if tick >= ticktime * 2 then
							tick = 0
							CharacterBoostButton.MainPanel.Status2.Status1.Anim:Play()
						end
					end

				else
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end
			end, seconds)
			CharacterBoostButton.MainPanel.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_DISCOUNT, sale)
		end

		if newPrice == 0 and haveDiscount == 1 then
			CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_VIP_GIFT)
			CharacterBoostButton.MainPanel.Status2.Status2:SetText(CHARACTER_SERVICES_BOOST_FREE)
		end


		if not active and newPrice == 0 and haveDiscount ~= 1 then
			CharacterBoostButton.MainPanel.Status2.Status1:SetText(CHARACTER_SERVICES_BUY)
			CharacterBoostButton.MainPanel.Status2.Status2:SetText(CHARACTER_SERVICES_199_BONUS)
		end
		CharacterSelect.AllowService = false
	elseif active then
		CharacterSelect.AllowService = true
	end
end

function EventHandler:SMSG_SIRUS_BOOST_BUY(status)
	if status == 0 then
		C_SendOpcode(CMSG_SIRUS_BOOST_STATUS)

		if CharacterBoostButton.ticker then
			CharacterBoostButton.ticker:Cancel()
			CharacterBoostButton.ticker = nil
		end

		CharacterBoostButton.MainPanel.Status1:Show()
		CharacterBoostBuyFrame:Hide()

		if not CharSelectServicesFlowFrame:IsShown() then
			CharSelectServicesFlowFrame:Show()
		end

		GlueDialog_Show("OKAY", CHARACTER_SERVICES_BUY_BOOST_RESULT)
	elseif status == 1 then
		CharacterBoostBuyFrame:Hide()
		GlueDialog_Show("BOOST_ERROR_NOT_ENOUGH_BONUES")
	end
	WaitingDialogFrame:Hide()
end

function EventHandler:SMSG_SIRUS_BOOST_CHARACTER(status)
	if status == 0 then
		WaitingDialogFrame:Hide()
		CharSelectServicesFlowFrame:Hide()
		GetCharacterListUpdate()
		CharacterSelect.AutoEnterWorld = true
	else
		GlueDialog_Show("OKAY", CHARACTER_SERVICES_BOOST_ERROR .. status)
		WaitingDialogFrame:Hide()
		CharSelectServicesFlowFrame:Hide()
	end
end