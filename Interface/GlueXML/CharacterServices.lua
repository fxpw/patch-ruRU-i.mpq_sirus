--	Filename:	CharacterServices.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

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
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostCharacter, CharSelectServicesFlowFrame.CharSelect, SelectAdditionalProffesion, SelectMainProfession, SelectCharacterSpec, SelectCharacterPvPSpec, SelectCharacterFaction)
		GlueDialog:ShowDialog("SERVER_WAITING")
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

function CharacterBoost_CharacterInit(isBoostMode)
	local numChars = GetNumCharacters()
	local characterLimit = min(numChars, MAX_CHARACTERS_DISPLAYED)

	for i = 1, characterLimit do
		local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(i))
		local button = _G["CharSelectCharacterButton"..i]
		if isBoostMode then
			if level < BOOST_MAX_LEVEL then
				button:Enable()
				button:SetBoostMode(true, true)

				if CharacterSelect.selectedIndex == i then
					button:Click()
				end
			else
				button:Disable()
				button:SetBoostMode(true)
			end
		else
			button:Enable()
			button:SetBoostMode(false)
		end
	end

	if isBoostMode then
	--	CharSelectServicesFlowFrame.GlowBox:SetSize(310, (66 * characterLimit))
		CharSelectServicesFlowFrame.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, -10, 0)
	end
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
	CharSelectServicesFlowFrame.CharSelect = nil

	CharacterServicesMaster_UpdateSteps()

	CharSelectChangeListStateButton:Disable()
	CharacterBoostButton:Hide()
	CharSelectEnterWorldButton:Disable()
	CharSelectCreateCharacterButton:Disable()
	CharacterSelectAddonsButton:Hide()
	CharSelectChangeRealmButton:Disable()
	CharacterSelectBackButton:Disable()
	CharSelectCharPageButtonPrev:Disable()
	CharSelectCharPageButtonNext:Disable()

	self.NextButton:Show()

	self.CharacterServicesMaster.step1.choose.CreateNewCharacter:SetEnabled(not IsCharacterSelectInUndeleteMode())

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
		GlueDark_DropDownMenu_SetSelectedName(ChooseMainProffesionDropDown, nil)
		GlueDark_DropDownMenu_SetText(ChooseMainProffesionDropDown, MAIN_PROFESSION)
	end

	for i = 1, #AdditionalProffesionList do
		GlueDark_DropDownMenu_SetSelectedName(ChooseAdditionalProffesionDropDown, nil)
		GlueDark_DropDownMenu_SetText(ChooseAdditionalProffesionDropDown, SECONDARY_PROFESSION)
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
	if CHARACTER_SELECT_LIST.deleted.numPages > 0 then
		CharSelectChangeListStateButton:Enable()
	end
	if GetNumCharacters() > 0 then
		CharSelectCreateCharacterButton:Enable()
	end

	CharacterBoostButton:Show()
	CharSelectEnterWorldButton:Enable()
	UpdateAddonButton()
	CharSelectChangeRealmButton:Enable()
	CharacterSelectBackButton:Enable()
	UpdateCharacterSelection()

	CharacterBoost_CharacterInit(false)
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
			frame.CharacterServicesMaster.step1.finish.Character:SetFormattedText(CHARACTER_BOOST_CHARACTER_NAME, color, name)
			frame.CharacterServicesMaster.step1.finish.CharacterInfo:SetFormattedText(CHARACTER_BOOST_CHARACTER_INFO, level, color, class)

			for i=1, characterLimit, 1 do
				local button = _G["CharSelectCharacterButton"..i]
				button.Arrow:Hide()

				if i ~= frame.CharSelect then
					button:Disable()
				end
			end
			CharacterBoostStep = CharacterBoostStep + 1

			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
			frame.CharacterServicesMaster.step2:Show()
		else
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", "Персонаж не выбран")
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

			local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(CharSelectServicesFlowFrame.CharSelect));
			local classInfo = C_CreatureInfo.GetClassInfo(class)

			for i = 1, 3 do
				local button = frame.CharacterServicesMaster.step3.choose.SpecButtons[i]
				local spec = SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile][i]
				button.SpecName:SetText(spec.name)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-iconRole-"..spec.role) or "GlueDark-iconRole-DAMAGER")
				button.SpecIcon:SetTexture(spec.icon)
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
			end

			local button = frame.CharacterServicesMaster.step3.choose.SpecButtons[4];
			if classInfo.classFile == "DEATHKNIGHT" then
				local spec = SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile][4]
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

			local name, race, class, level = GetCharacterInfo(GetCharIDFromIndex(CharSelectServicesFlowFrame.CharSelect));
			local classInfo = C_CreatureInfo.GetClassInfo(class);

			for i = 1, 3 do
				local button = frame.CharacterServicesMaster.step4.choose.SpecButtons[i];
				local spec = SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile][i];
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
				if self.race == PANDAREN_ALLIANCE or self.race == RACE_VULPERA_NEUTRAL then
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

			if self.race == PANDAREN_ALLIANCE or self.race == RACE_VULPERA_NEUTRAL then
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
		local SelectFaction = (frame.CharacterServicesMaster.step5.choose.FactionButtons[1]:GetChecked()) and FACTION_HORDE or FACTION_ALLIANCE
		local CheckFaction = false

		for _, button in pairs(frame.CharacterServicesMaster.step5.choose.FactionButtons) do
			if button:GetChecked() then
				SelectCharacterFaction = button:GetID()
				CheckFaction = true
			end
		end
		if not CheckFaction then
			GlueDialog:ShowDialog("OKAY", CHOOSE_FACTION)
		else
			CheckFaction = false
			frame.CharacterServicesMaster.step5.choose:Hide()
			frame.CharacterServicesMaster.step5.finish:Show()
			frame.CharacterServicesMaster.step5.finish.Faction:SetText(SelectFaction)

			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			self:Hide()
			GlueDialog:ShowDialog("CHARACTER_SERVICES_BOOST_CONFIRM")
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
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT)
		LaunchURL("https://sirus.su/user/pay#/?bonuses="..CharacterBoost_CalculatePayBonuses())
	else
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
		CharacterBoostBuyFrame:Hide()
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostBuy)
		GlueDialog:ShowDialog("SERVER_WAITING")
	end
end

function CharacterBoostBuyFrame_OnLoad(self)
	local resetFunc = function(this, obj)
		obj:Hide()
		obj:ClearAllPoints()
		obj:SetAlpha(1)
	end

	self.texturePool = CreateTexturePool(self.Container, "ARTWORK", nil, "GlueDark_fqtcAngled0", resetFunc)

	local PRICE_WIDTH, PRICE_HEIGHT								= 21, 32
	local PRICE_WS_WIDTH, PRICE_WS_HEIGHT						= 17, 26
	local PRICE_SALE_WIDTH, PRICE_SALE_HEIGHT					= 11, 16
	local PRICE_PADDING_X, PRICE_PADDING_Y						= -1, 1
	local PRICE_WS_BASE_OFFSET_X, PRICE_WS_BASE_OFFSET_Y		= -21, 0
	local PRICE_SALE_BASE_OFFSET_X, PRICE_SALE_BASE_OFFSET_Y	= 38, 5

	self.SetPrice = function(this, price, oldPrice)
		if oldPrice == price then
			oldPrice = nil
		end

		price = tostring(price)
		this.texturePool:ReleaseAll()

		if price == "" or price == "0" or price == "nil" then
			this.Container.NoPrice:Show()
			this.Container.CurrencyIconPrice:Hide()
			this.Container.StrikeThrough:Hide()
			this.Container.BuyButton:SetText(CHARACTER_SERVICES_USE)
			return
		else
			this.Container.NoPrice:Hide()
			this.Container.CurrencyIconPrice:Show()
			this.Container.BuyButton:SetText(CHARACTER_SERVICES_BUY)
		end

		local haveOldPrice, firstTexture, prevTexture
		local length

		while price do
			length = string.len(price)
			for i = 1, length do
				local number = string.sub(price, i, i)
				local texture = this.texturePool:Acquire()
				texture:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-fqtcAngled"..number], 3, 6))

				if haveOldPrice then
					texture:SetSize(PRICE_SALE_WIDTH, PRICE_SALE_HEIGHT)
					texture:SetAlpha(0.8)
				elseif oldPrice then
					texture:SetSize(PRICE_WS_WIDTH, PRICE_WS_HEIGHT)
				else
					texture:SetSize(PRICE_WIDTH, PRICE_HEIGHT)
				end

				if i == 1 then
					firstTexture = texture

					if haveOldPrice then	-- preSale price position
						texture:SetPoint("CENTER", this.Container.SaleBackdrop, "CENTER", PRICE_SALE_BASE_OFFSET_X + -(math.ceil((length * (PRICE_SALE_WIDTH + PRICE_PADDING_X) - PRICE_PADDING_X) / 2)), PRICE_SALE_BASE_OFFSET_Y + length * -PRICE_PADDING_Y)
					elseif oldPrice then	-- sale price position
						texture:SetPoint("CENTER", this.Container.SaleBackdrop, "CENTER", PRICE_WS_BASE_OFFSET_X + (math.ceil((length * (-PRICE_WS_WIDTH + PRICE_PADDING_X) - PRICE_PADDING_X) / 2)), PRICE_WS_BASE_OFFSET_Y + length * -PRICE_PADDING_Y)
					else					-- price position
						texture:SetPoint("CENTER", this.Container.SaleBackdrop, "CENTER", math.ceil(length * (-PRICE_WIDTH + PRICE_PADDING_X) / 2), length * -PRICE_PADDING_Y)
					end
				else
					texture:SetPoint("BOTTOMLEFT", prevTexture, "BOTTOMRIGHT", PRICE_PADDING_X, PRICE_PADDING_Y)
				end

				texture:Show()
				prevTexture = texture
			end

			if not haveOldPrice then
				price = oldPrice and tostring(oldPrice) or nil
				haveOldPrice = price and true or false
			else
				break
			end
		end

		if haveOldPrice then
			this.Container.CurrencyIconPrice:SetPoint("CENTER", "$parentSaleBackdrop", 4, 0)

			this.Container.StrikeThrough:SetRotation(math.rad(4 + length * 2))
			this.Container.StrikeThrough:ClearAllPoints()
			this.Container.StrikeThrough:SetPoint("BOTTOMLEFT", firstTexture, "BOTTOMLEFT", 0, PRICE_SALE_HEIGHT / 2 - 15)
			this.Container.StrikeThrough:SetPoint("BOTTOMRIGHT", prevTexture, "BOTTOMRIGHT", 2, PRICE_SALE_HEIGHT / 2 - 3)
			this.Container.StrikeThrough:Show()
		else
			this.Container.CurrencyIconPrice:SetPoint("CENTER", "$parentSaleBackdrop", 30, 2)
			this.Container.StrikeThrough:Hide()
		end
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

	CharacterServicesMaster_UpdateSteps()

	self:RegisterEvent("SERVER_SPLIT_NOTICE")
end

function CharacterServicesMaster_OnEvent( self, event, ts, ss, body )
	local opcode, status, content = string.split(":", body, 3)
	status = tonumber(status)

	if opcode and status then
		if opcode == "SMSG_BOOST_STATUS" then
			local boostPrice, balance, haveDiscount, newPrice, isPersonalSale, seconds, expireAt, isPVP = string.split(":", content)

			boostPrice = tonumber(boostPrice)
			balance = tonumber(balance)
			haveDiscount = tonumber(haveDiscount) == 1
			newPrice = tonumber(newPrice)
			isPersonalSale = tonumber(isPersonalSale) == 1
			seconds = tonumber(seconds)
			expireAt = tonumber(expireAt)
			isPVP = tonumber(isPVP) == 1

			local statusFrame = CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1

			CharacterBoostButton.isBoostDisable = status == -1
			CharacterBoostButton_UpdateState(CharacterBoostButton.isBoostDisable)
			CharacterBoostButton.isBoostPVPEnabled = isPVP

			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1:SetShown(status ~= 0)
			CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2:SetShown(status == 0 and boostPrice and balance)

			statusFrame.CharacterBoost:ClearAllPoints()
			statusFrame.Status:ClearAllPoints()

			if expireAt and expireAt > 0 then
				statusFrame.CharacterBoost:SetPoint("TOP", 0, 0)
				statusFrame.Status:SetPoint("BOTTOM", 0, 15)
			else
				statusFrame.CharacterBoost:SetPoint("TOP", 0, -5)
				statusFrame.Status:SetPoint("BOTTOM", 0, 5)
			end

			if status == 0 and boostPrice and balance then
				local cost = newPrice ~= 0 and newPrice or boostPrice
				local discountAmount = math.floor(( 1 - (newPrice / boostPrice)) * 100)

				accountBonusCount = balance
				characterBoostPrice = cost

				if haveDiscount and newPrice == 0 then
					CharacterBoostBuyFrame:SetPrice(0) -- CHARACTER_SERVICES_BOOST_COST_FREE
				else
					CharacterBoostBuyFrame:SetPrice(cost, boostPrice)
				end

				local actualPrice = newPrice > 0 and newPrice or boostPrice

				if actualPrice ~= 0 and balance < actualPrice and not C_Service:IsGM() then
					CharacterBoostBuyFrame.Container.BuyButton:SetText(REPLENISH)
					CharacterBoostBuyFrame.Container.BuyButton.NoBonus = true
				else
					CharacterBoostBuyFrame.Container.BuyButton:SetText(CHARACTER_SERVICES_BUY)
					CharacterBoostBuyFrame.Container.BuyButton.NoBonus = false
				end

				CharacterBoostBuyFrame.Container.MyBonus:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, balance)

--[[
				if boostPrice == 0 then
					CharacterBoostButton:Hide()
					return
				end
]]
				if CharacterBoostButton.ticker then
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end

				if seconds < 86400 then
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetTextColor(1, 0, 0)
				else
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetTextColor(1, 1, 1)
				end

				if newPrice > 0 then
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

					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_DISCOUNT, discountAmount)
				end

				if newPrice == 0 and haveDiscount then
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(CHARACTER_SERVICES_VIP_GIFT)
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetText(CHARACTER_SERVICES_BOOST_FREE)
				elseif status ~= 1 and newPrice == 0 and not haveDiscount then
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(CHARACTER_SERVICES_BUYBOOST)
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetFormattedText(CHARACTER_SERVICES_COST, cost)
				end

				CharacterSelect.AllowService = false
			elseif status == 1 then
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
			else -- status == -1
				if CharacterBoostButton.ticker then
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end

				CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1.Status:SetText(UNAVAILABLE)
				CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1.Status:SetTextColor(1, 0, 0)

				CharacterSelect.AllowService = false
			end

			CharacterBoostButton:SetText(CharacterSelect.AllowService and CHARACTER_SERVICES_USE or CHARACTER_SERVICES_BUY)
		elseif opcode == "SMSG_BUY_BOOST_RESULT" then
			GlueDialog:HideDialog("SERVER_WAITING")

			if status == 0 then
				C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostStatus)

				if CharacterBoostButton.ticker then
					CharacterBoostButton.ticker:Cancel()
					CharacterBoostButton.ticker = nil
				end

				CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1:Show()
				CharacterBoostBuyFrame:Hide()

				if not CharSelectServicesFlowFrame:IsShown() then
					CharSelectServicesFlowFrame:Show()
				end

				GlueDialog:ShowDialog("OKAY", CHARACTER_SERVICES_BUY_BOOST_RESULT)
			elseif status == 1 then
				CharacterBoostBuyFrame:Hide()
				GlueDialog:ShowDialog("BOOST_ERROR_NOT_ENOUGH_BONUES")
			elseif status == 11 then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_BOOST_DISABLE_SUSPECT_ACCOUNT)
			elseif status then
				local errorText = _G[string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)]
				if errorText then
					GlueDialog:ShowDialog("OKAY", errorText)
				end
			end
		elseif opcode == "SMG_FINISH_BOOST_RESULT" then
			GlueDialog:HideDialog("SERVER_WAITING")

			if status == 0 then
				CharSelectServicesFlowFrame:Hide()
				GetCharacterListUpdate()
				CharacterSelect.AutoEnterWorld = true
			elseif status == 6 or status == 11 then
				GlueDialog:ShowDialog("OKAY", CHARACTER_BOOST_DISABLE_SUSPECT_ACCOUNT)
				CharSelectServicesFlowFrame:Hide()
			elseif status == 12 then
				GlueDialog:ShowDialog("OKAY", CHARACTER_BOOST_DISABLE_REALM)
				CharSelectServicesFlowFrame:Hide()
			else
				GlueDialog:ShowDialog("OKAY", CHARACTER_SERVICES_BOOST_ERROR .. status)
				CharSelectServicesFlowFrame:Hide()
			end
		end
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
	CharacterSelectLeftPanel.CharacterBoostInfoFrame:SetShown(not state)
end