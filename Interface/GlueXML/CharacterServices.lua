CharacterBoostStep = 1
local BOOST_SELECTED_PROFESSION_MAIN
local BOOST_SELECTED_PROFFESION_ADDITIONAL
local BOOST_SELECTED_SPEC_PVE
local BOOST_SELECTED_SPEC_PVP
local BOOST_SELECTED_FACTION

GlueDialogTypes["LOCK_BOOST_ENTER_WORLD"] = {
	text = CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		CharacterServiceBoostFlowFrame:Hide()
	end,
}

GlueDialogTypes["CHARACTER_SERVICES_NOT_ENOUGH_MONEY"] = {
	text = NOT_ENOUGH_BONUSES_TO_BUY_A_CHARACTER_BOOST,
	button1 = DONATE,
	button2 = CLOSE,
	OnAccept = function()
		C_CharacterServices.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end,
}

GlueDialogTypes["LOCK_GEAR_BOOST_ENTER_WORLD"] = {
	text = CHARACTER_SERVICES_DIALOG_GEAR_BOOST_ENTER_WORLD,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		CharacterServiceGearBoostFlowFrame:Hide()
	end,
}

GlueDialogTypes["CHARACTER_SERVICES_GEAR_BOOST_CONFIRM"] = {
	text = CHARACTER_GEAR_BOOST_CONFIRM_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(this)
		C_CharacterServices.BoostCharacterGear(unpack(this.data))
	end,
	OnCancel = function()
		CharacterServiceGearBoostFlowFrame:Hide()
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

function CharacterBoostButton_UpdateState(state)
	if state then
		CharacterBoostButton.tooltip = CHARACTER_BOOST_DISABLE_REALM
	else
		CharacterBoostButton.tooltip = nil
	end
	CharacterBoostButton:SetEnabled(not state)
end

function CharacterServices_StepSpec_OnLoad(self)
	local serviceOwner = self:GetParent():GetParent():GetParent()
	self.SpecButtons = {}
	for i = 1, 4 do
		self.SpecButtons[i] = self["SpecButton"..i]
		self.SpecButtons[i]:SetOwner(serviceOwner)
	end
end

function CharacterServices_StepFaction_OnLoad(self)
	local serviceOwner = self:GetParent():GetParent():GetParent()
	self.FactionButtons = {}
	for i = 1, 2 do
		self.FactionButtons[i] = self["FactionButton"..i]
		self.FactionButtons[i]:SetOwner(serviceOwner)
		self.FactionButtons[i].Icon:SetTexture(factionLogoTextures[i])
		self.FactionButtons[i].Name:SetText(factionLabels[i])
	end
end

CharacterServiceFlowMixin = CreateFromMixins(GlueEasingAnimMixin)

function CharacterServiceFlowMixin:OnLoad()
	self.TopShadow:SetVertexColor(0, 0, 0, 0.4)
	self.BottomShadow:SetVertexColor(0, 0, 0, 0.4)

	self:SetInitPosition()
end

function CharacterServiceFlowMixin:SetInitPosition()
	self.basePoint = {self:GetPoint()}
	self.startPoint = -(self:GetWidth() + 35)
	self.endPoint = self.basePoint[4]
	self.duration = 0.500
end

function CharacterServiceFlowMixin:OnShow()
	self:SetUIEnabled(false)
end

function CharacterServiceFlowMixin:OnHide()
	self:SetUIEnabled(true)

	BoostServiceSpecItemsFrame:Hide()
	UpdateAddonButton()
	UpdateCharacterSelection()
end

function CharacterServiceFlowMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:Hide()
		return true
	elseif key == "PRINTSCREEN" then
		Screenshot()
		return true
	end
end

function CharacterServiceFlowMixin:Close()
	self:Hide()
end

function CharacterServiceFlowMixin:SetPosition(easing, progress)
	local alpha = progress and (self.isRevers and (1 - progress) or progress) or (self.isRevers and 0 or 1)

	self:SetAlpha(alpha)

	if easing then
		self:ClearAndSetPoint(self.basePoint[1], easing, self.basePoint[5])
	else
		self:ClearAndSetPoint(self.basePoint[1], self.isRevers and self.startPoint or self.endPoint, self.basePoint[5])
	end
end

function CharacterServiceFlowMixin:SetTitle(title)
	self.TitleText:SetText(title)
end

function CharacterServiceFlowMixin:SetUIEnabled(enabled)
	CharSelectChangeListStateButton:SetEnabled(enabled and C_CharacterList.IsRestoreModeAvailable())
	CharacterBoostButton:SetShown(enabled)
	CharacterBoostRefundButton:SetShown(enabled and C_CharacterServices.IsBoostRefundAvailable())
	CharSelectEnterWorldButton:SetEnabled(enabled and not C_CharacterList.IsCharacterPendingBoostDK(GetCharIDFromIndex(CharacterSelect.selectedIndex)))
	CharSelectChangeRealmButton:SetEnabled(enabled)
	CharacterSelectAddonsButton:SetEnabled(enabled)
	CharacterSelectOptionsButton:SetEnabled(enabled)
	CharacterSelectSupportButton:SetEnabled(enabled)
	CharacterSelectBackButton:SetEnabled(enabled)
	CharSelectCharPagePurchaseButton:SetEnabled(enabled)

	if enabled then
		CharacterSelect_UpdateCharecterCreateButton()
		CharacterSelect_UpdatePageButton()
	else
		CharSelectCreateCharacterButton:Disable()
		CharSelectCharPageButtonPrev:Disable()
		CharSelectCharPageButtonNext:Disable()
	end
end

CharacterServiceBoostFlowMixin = CreateFromMixins(CharacterServiceFlowMixin)

function CharacterServiceBoostFlowMixin:OnLoad()
	CharacterServiceFlowMixin.OnLoad(self)

	self:SetTitle(CHARACTER_SERVICES_BOOST)

	SetClampedTextureRotation(self.GlowBox.GlowTopRight, 90)
	SetClampedTextureRotation(self.GlowBox.GlowBottomRight, 180)
	SetClampedTextureRotation(self.GlowBox.GlowBottomLeft, 270)

	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_STATUS_UPDATE")
	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_PURCHASE_STATUS")
	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_UTILIZATION_STATUS")
	self:RegisterCustomEvent("CHARACTER_SERVICES_BOOST_OPEN")
	self:RegisterCustomEvent("BOOST_SERVICE_NEW_STAGE")

	for i = 2, 4 do
		local f = self.Flow["step"..i]
		f.choose.StepLine:ClearAllPoints()
		f.choose.StepLine:SetPoint("TOP", self.Flow["step" .. (i - 1)].finish.StepBackdrop, "BOTTOM", 0, 20)
		f.choose.StepLine:SetPoint("BOTTOM", f.choose.StepBackdrop, "TOP", 1, -20)

		f.finish.StepLine:ClearAllPoints()
		f.finish.StepLine:SetPoint("TOP", self.Flow["step" .. (i - 1)].finish.StepBackdrop, "BOTTOM", 0, 20)
		f.finish.StepLine:SetPoint("BOTTOM", f.finish.StepBackdrop, "TOP", 1, -20)
	end
end

function CharacterServiceBoostFlowMixin:OnEvent(event, ...)
	if event == "CHARACTER_SERVICES_BOOST_OPEN" then
		local characterIndex = ...
		CharacterSelect_OpenBoost(characterIndex, true)
	elseif event == "CHARACTER_SERVICES_BOOST_STATUS_UPDATE" then
		local status = ...

		local isDisabled = status == Enum.CharacterServices.BoostServiceStatus.Disabled

		local statusFrame = CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status1

		CharacterBoostButton_UpdateState(isDisabled)
		CharacterBoostRefundButton:SetShown(C_CharacterServices.IsBoostRefundAvailable())

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
			local price, priceOriginal, discount = C_CharacterServices.GetBoostPrice()
			CharacterBoostButton.isBoostPVPEnabled = C_CharacterServices.IsBoostHasPVPEquipment()

			if status == Enum.CharacterServices.BoostServiceStatus.Purchased then
				CharacterBoostButton:SetText(CHARACTER_SERVICES_USE)
			else
				CharacterBoostButton:SetText(price == 0 and CHARACTER_SERVICES_FREE_USE or CHARACTER_SERVICES_BUY)
			end

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
				if price == 0 then
					CharacterBoostBuyFrame:SetPrice(0)
				else
					CharacterBoostBuyFrame:SetPrice(price, priceOriginal)
				end

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
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetFontObject("PKBT_Font_16")
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetText(CHARACTER_SERVICES_BOOST_FREE)
				else
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status1:SetText(CHARACTER_SERVICES_BOOST_PURCHASE_LABEL)
					CharacterSelectLeftPanel.CharacterBoostInfoFrame.Status2.Status2:SetFontObject("PKBT_Font_18")
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
			self:Show()
		end

		CharacterBoostBuyFrame:Hide()
		CharacterBoostRefundDialog:Hide()
	elseif event == "CHARACTER_SERVICES_BOOST_UTILIZATION_STATUS" then
		local success = ...

		if success then
			CharacterSelect.AutoEnterWorldCharacterIndex = self.selectedCharacterIndex
		end

		self:Hide()
	elseif event == "BOOST_SERVICE_NEW_STAGE" then
		local helpTipInfo = {
			text = BOOST_SERVICE_UPDATE_TIP,
			textJustifyH = "CENTER",
			textFontObject = "GlueDark_Font_14",
			checkCVars = false,
			cvarBitfield = "HELPTIP_BITFIELD",
			bitfieldFlag = 1,
			offsetX = 0,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
			extraWidth = 24,

			acknowledgeOnHide = false,
			onAcknowledgeCallback = function()
				C_CharacterServices.MarkBoostServiceItemStageSeen()
			end,
		}
		HelpTip:Show(CharacterBoostButton, helpTipInfo, CharacterBoostButton)
	end
end

function CharacterServiceBoostFlowMixin:OnShow()
	CharacterServiceFlowMixin.OnShow(self)

	CharacterBoostStep = 1
	BOOST_SELECTED_FACTION = nil
	self.selectedCharacterIndex = nil

	self:UpdateSteps()

	self.NextButton:Show()

	self.Flow.step1.choose.CreateNewCharacter:SetEnabled(C_CharacterList.IsInPlayableMode() and C_CharacterList.CanCreateCharacter() and (not C_CharacterList.HasPendingBoostDK() or IsGMAccount()))

	self.Flow.step1.choose:Show()
	self.Flow.step1.finish:Hide()

	self.Flow.step2:Hide()
	self.Flow.step2.choose:Show()
	self.Flow.step2.finish:Hide()

	self.Flow.step3:Hide()
	self.Flow.step3.choose:Show()
	self.Flow.step3.finish:Hide()

	self.Flow.step4:Hide()
	self.Flow.step4.choose:Show()
	self.Flow.step4.finish:Hide()

	self.Flow.step5:Hide()
	self.Flow.step5.choose:Show()
	self.Flow.step5.finish:Hide()

	self.GlowBox:Show()

	if not self:UpdateCharacterButtons(true) then
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

function CharacterServiceBoostFlowMixin:OnHide()
	CharacterServiceFlowMixin.OnHide(self)

	for _, button in ipairs(self.Flow.step3.choose.SpecButtons) do
		if button:GetChecked() then
			button:SetChecked(false)
		end
	end
	for _, button in ipairs(self.Flow.step4.choose.SpecButtons) do
		if button:GetChecked() then
			button:SetChecked(false)
		end
	end
	for _, button in ipairs(self.Flow.step5.choose.FactionButtons) do
		if button:GetChecked() then
			button:SetChecked(false)
		end
	end

	self:UpdateCharacterButtons(false)
end

function CharacterServiceBoostFlowMixin:OnKeyDown(key)
	if CharacterServiceFlowMixin.OnKeyDown(self, key) then
		return
	end
	if key == "ENTER" then
		self:NextStep()
	end
end

function CharacterServiceBoostFlowMixin:Close()
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)

	local pendingBoostCharacterListID, pendingBoostCharacterID, pendiongBoostCharacterPageIndex = C_CharacterList.GetPendingBoostDK()
	if pendingBoostCharacterListID ~= 0 and pendiongBoostCharacterPageIndex == C_CharacterList.GetCurrentPageIndex() and not IsGMAccount() then
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_BOOST_CANCEL_DEATH_KNIGHT)
	else
		self:Hide()
	end
end

function CharacterServiceBoostFlowMixin:UpdateSteps()
	if CharacterBoostButton.isBoostPVPEnabled then
		self.Flow.step5:SetPoint("TOP", 0, -340)
		self.Flow.step5.choose.StepNumber:SetAtlas("GlueDark-Glyph-FQTC-5")

		self.Flow.step5.choose.StepLine:ClearAllPoints()
		self.Flow.step5.choose.StepLine:SetPoint("TOP", self.Flow.step4.finish.StepBackdrop, "BOTTOM", 0, 20)
		self.Flow.step5.choose.StepLine:SetPoint("BOTTOM", self.Flow.step5.choose.StepBackdrop, "TOP", 1, -20)

		self.Flow.step5.finish.StepLine:ClearAllPoints()
		self.Flow.step5.finish.StepLine:SetPoint("TOP", self.Flow.step4.finish.StepBackdrop, "BOTTOM", 0, 20)
		self.Flow.step5.finish.StepLine:SetPoint("BOTTOM", self.Flow.step5.finish.StepBackdrop, "TOP", 1, -20)
	else
		self.Flow.step5:SetPoint("TOP", 0, -255)
		self.Flow.step5.choose.StepNumber:SetAtlas("GlueDark-Glyph-FQTC-4")

		self.Flow.step5.choose.StepLine:ClearAllPoints()
		self.Flow.step5.choose.StepLine:SetPoint("TOP", self.Flow.step3.finish.StepBackdrop, "BOTTOM", 0, 20)
		self.Flow.step5.choose.StepLine:SetPoint("BOTTOM", self.Flow.step5.choose.StepBackdrop, "TOP", 1, -20)

		self.Flow.step5.finish.StepLine:ClearAllPoints()
		self.Flow.step5.finish.StepLine:SetPoint("TOP", self.Flow.step3.finish.StepBackdrop, "BOTTOM", 0, 20)
		self.Flow.step5.finish.StepLine:SetPoint("BOTTOM", self.Flow.step5.finish.StepBackdrop, "TOP", 1, -20)
	end
end

function CharacterServiceBoostFlowMixin:PreviousStep()
end

function CharacterServiceBoostFlowMixin:NextStep()
	if CharacterBoostStep == 1 then
		local charSelected

		if self.selectedCharacterIndex then
			local characterID = GetCharIDFromIndex(self.selectedCharacterIndex)
			local name, race, class, level = GetCharacterInfo(characterID)

			if C_CharacterCreation.IsServicesAvailableForRace(E_PAID_SERVICE.BOOST_SERVICE, C_CreatureInfo.GetRaceInfo(race).raceID) then
				charSelected = true

				self.classInfo = C_CreatureInfo.GetClassInfo(class)

				if not C_CharacterServices.IsBoostClassSpecItemsLoaded(self.classInfo.classID) then
					C_CharacterServices.RequestSpecItems(self.classInfo.classID)
				end

				local factionOverrideID = C_CharacterList.GetCharacterFactionOverride(characterID)
				if factionOverrideID then
					self.factionID = factionOverrideID
				else
					local factionInfo = C_CreatureInfo.GetFactionInfo(race)
					self.factionID = factionInfo.factionID
				end

				local _, _, _, color = GetClassColor(self.classInfo.classFile)
				self.Flow.step1.finish.Character:SetFormattedText(CHARACTER_BOOST_CHARACTER_NAME, color, name)
				self.Flow.step1.finish.CharacterInfo:SetFormattedText(CHARACTER_BOOST_CHARACTER_INFO, level, color, class)

				self.Flow.step1.choose:Hide()
				self.Flow.step1.finish:Show()
				self.GlowBox:Hide()

				for characterIndex = 1, C_CharacterList.GetNumCharactersOnPage() do
					local button = _G["CharSelectCharacterButton"..characterIndex]
					button.Arrow:Hide()

					if characterIndex ~= self.selectedCharacterIndex then
						button:Disable()
					end
				end

				CharacterBoostStep = CharacterBoostStep + 1

				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
				self.Flow.step2:Show()
			end
		end

		if not charSelected then
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", CHARACTER_NOT_FOUND)
		end
	elseif CharacterBoostStep == 2 then
		BOOST_SELECTED_PROFESSION_MAIN = GlueDark_DropDownMenu_GetSelectedValue(ChooseMainProffesionDropDown)
		BOOST_SELECTED_PROFFESION_ADDITIONAL = GlueDark_DropDownMenu_GetSelectedValue(ChooseAdditionalProffesionDropDown)
		if BOOST_SELECTED_PROFESSION_MAIN and BOOST_SELECTED_PROFFESION_ADDITIONAL then
			self.Flow.step2.choose:Hide()
			self.Flow.step2.finish:Show()
			self.Flow.step2.finish.Proffesion:SetText(string.format("%s, %s",
				MainProffesionList[BOOST_SELECTED_PROFESSION_MAIN].text,
				AdditionalProffesionList[BOOST_SELECTED_PROFFESION_ADDITIONAL].text
				))
			CharacterBoostStep = CharacterBoostStep + 1

			local specs = C_CharacterServices.GetBoostCharacterSpecs(self.classInfo.classID, Enum.CharacterServices.SpecType.PVE)

			for specIndex, spec in ipairs(specs) do
				local button = self.Flow.step3.choose.SpecButtons[specIndex]
				button:SetOwner(self)
				button.Name:SetText(spec.name)
				button.Icon:SetTexture(spec.icon)
				button.Icon:SetDesaturated(spec.iconDesaturate)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-IconRole-"..spec.role) or "GlueDark-IconRole-DAMAGER")
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
				button:UpdateButtonInfo(self.classInfo.classID, Enum.CharacterServices.SpecType.PVE, specIndex)
				button:Show()
			end

			for i = #specs + 1, #self.Flow.step3.choose.SpecButtons do
				self.Flow.step3.choose.SpecButtons[i]:Hide()
			end

			PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
			self.Flow.step3:Show()
		else
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", CHOOSE_ALL_PROFESSION)
		end
	elseif CharacterBoostStep == 3 then
		local CheckedSpec = false

		for _, button in ipairs(self.Flow.step3.choose.SpecButtons) do
			if button:GetChecked() then
				CheckedSpec = true
				BOOST_SELECTED_SPEC_PVE = button:GetID()
				self.Flow.step3.finish.Spec:SetText(button.Name:GetText());
				break;
			end
		end

		if not CheckedSpec then
			GlueDialog:ShowDialog("OKAY", CHOOSE_SPECIALIZATION)
		else
			CheckedSpec = false
			self.Flow.step3.choose:Hide()
			self.Flow.step3.finish:Show()
			CharacterBoostStep = CharacterBoostStep + 1;

			local specs = C_CharacterServices.GetBoostCharacterSpecs(self.classInfo.classID, Enum.CharacterServices.SpecType.PVP)

			for specIndex, spec in ipairs(specs) do
				local button = self.Flow.step4.choose.SpecButtons[specIndex]
				button:SetOwner(self)
				button.Name:SetText(spec.name)
				button.Icon:SetTexture(spec.icon)
				button.Icon:SetDesaturated(spec.iconDesaturate)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-IconRole-"..spec.role) or "GlueDark-IconRole-DAMAGER")
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
				button:UpdateButtonInfo(self.classInfo.classID, Enum.CharacterServices.SpecType.PVP, specIndex)
				button:Show()
			end

			for i = #specs + 1, #self.Flow.step4.choose.SpecButtons do
				self.Flow.step3.choose.SpecButtons[i]:Hide()
			end

			if CharacterBoostButton.isBoostPVPEnabled then
				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
				self.Flow.step4.choose.SpecButtons[4]:Hide();
				self.Flow.step4:Show()
			else
				BOOST_SELECTED_SPEC_PVP = 1
				if self.factionID == PLAYER_FACTION_GROUP.Neutral then
					PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
					CharacterBoostStep = CharacterBoostStep + 1;
					self.Flow.step5:Show();
				else
					PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
					self:Hide()

					local characterID = GetCharIDFromIndex(self.selectedCharacterIndex)
					CharacterServiceBoostActivationDialog:ShowDialog(characterID)
				end
			end
		end
	elseif CharacterBoostStep == 4 then
		local CheckedSpec = false;

		for _, button in ipairs(self.Flow.step4.choose.SpecButtons) do
			if button:GetChecked() then
				CheckedSpec = true;
				BOOST_SELECTED_SPEC_PVP = button:GetID();
				self.Flow.step4.finish.Spec:SetText(button.Name:GetText());
				break;
			end
		end

		if not CheckedSpec then
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			GlueDialog:ShowDialog("OKAY", CHOOSE_PVP_SPECIALIZATION);
		else
			CheckedSpec = false
			self.Flow.step4.choose:Hide();
			self.Flow.step4.finish:Show();

			if self.factionID == PLAYER_FACTION_GROUP.Neutral then
				PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
				CharacterBoostStep = CharacterBoostStep + 1;
				self.Flow.step5:Show();
			else
				PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
				self:Hide()

				local characterID = GetCharIDFromIndex(self.selectedCharacterIndex)
				CharacterServiceBoostActivationDialog:ShowDialog(characterID)
			end
		end
	elseif CharacterBoostStep == 5 then
		local selectedFactionButton

		for _, button in ipairs(self.Flow.step5.choose.FactionButtons) do
			if button:GetChecked() then
				selectedFactionButton = button:GetID()
				break
			end
		end

		if selectedFactionButton then
			BOOST_SELECTED_FACTION = selectedFactionButton

			self.Flow.step5.choose:Hide()
			self.Flow.step5.finish:Show()
			self.Flow.step5.finish.Faction:SetText(selectedFactionButton == 1 and FACTION_HORDE or FACTION_ALLIANCE)

			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
			self:Hide()

			local characterID = GetCharIDFromIndex(self.selectedCharacterIndex)
			CharacterServiceBoostActivationDialog:ShowDialog(characterID)
		else
			GlueDialog:ShowDialog("OKAY", CHOOSE_FACTION)
		end
	end
end

function CharacterServiceBoostFlowMixin:UpdateCharacterButtons(isBoostMode)
	if not isBoostMode then
		for i = 1, C_CharacterList.GetNumCharactersPerPage() do
			local button = _G["CharSelectCharacterButton"..i]
			button:Enable()
			button:SetBoostMode(false)
		end

		return
	end

	local pendingBoostCharacterListID, pendingBoostCharacterID, pendiongBoostCharacterPageIndex = C_CharacterList.GetPendingBoostDK()
	if pendingBoostCharacterListID ~= 0 and pendingBoostCharacterID == 0 then
		self:Hide()
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
				self.NextButton:Click()
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

	self.GlowBox:SetPoint("TOP", CharacterSelectCharacterFrame, -10, 0)

	return true
end

function CharacterServiceBoostFlowMixin:OnClickSpecButton(this, button)
	PlaySound("igMainMenuOptionCheckBoxOn")

	if this:GetParent().selected == this:GetID() then
		this:SetChecked(true)
		return
	else
		this:GetParent().selected = this:GetID()
		this:SetChecked(true)
	end

	for _, button in ipairs(this:GetParent().SpecButtons) do
		if button:GetID() ~= this:GetID() then
			button:SetChecked(0)
		end
	end
end

function CharacterServiceBoostFlowMixin:OnClickFactionButton(this, button)
	PlaySound("igMainMenuOptionCheckBoxOn")

	if this:GetParent().selected == this:GetID() then
		this:SetChecked(true)
		return
	else
		this:GetParent().selected = this:GetID()
		this:SetChecked(true)
	end

	for _, buttonObj in ipairs(this:GetParent().FactionButtons) do
		if buttonObj:GetID() ~= this:GetID() then
			buttonObj:SetChecked(false)
		end
	end
end

function CharacterServiceBoostFlowMixin:OnWorldEnterAttempt()
	local characterID = GetCharIDFromIndex(CharacterSelect.selectedIndex)
	local _, _, class = GetCharacterInfo(characterID)
	local classInfo = C_CreatureInfo.GetClassInfo(class)

	if classInfo.classFile == "DEATHKNIGHT" and C_CharacterList.HasPendingBoostDK() then
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD_DEATH_KNIGHT)
	else
		GlueDialog:ShowDialog("LOCK_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_BOOST_ENTER_WORLD)
	end
end

function CharacterServiceBoostFlowMixin:CreateCharacter()
	local success = CharacterSelect_OpenCharacterCreate(E_PAID_SERVICE.BOOST_SERVICE_NEW, nil, function()
		self:Hide()
		self:Reset()
		CharacterSelectLeftPanel.CharacterBoostInfoFrame:Show()
		self:SetPoint(unpack(self.basePoint))
		self:SetAlpha(1)
	end)

	if success then
		CharacterSelectLeftPanel.CharacterBoostInfoFrame:Hide()
		self:PlayAnim(true)
	end
end

CharacterServiceGearBoostFlowMixin = CreateFromMixins(CharacterServiceFlowMixin)

function CharacterServiceGearBoostFlowMixin:OnLoad()
	CharacterServiceFlowMixin.SetInitPosition(self)

	self:SetScale(0.75)

	self.Background:SetAtlas("PKBT-Tile-Oribos-256", true)

	self.ShadowLeft:SetAtlas("PKBT-Background-Shadow-Small-44-Left", true)
	self.ShadowRight:SetAtlas("PKBT-Background-Shadow-Small-44-Right", true)
	self.ShadowTop:SetAtlas("PKBT-Background-Shadow-Small-44-Top", true)
	self.ShadowBottom:SetAtlas("PKBT-Background-Shadow-Small-44-Bottom", true)

	self.VignetteTopLeft:SetAtlas("GlueDark-Oribos-Corner-TopLeft", true)
	self.VignetteTopRight:SetAtlas("GlueDark-Oribos-Corner-TopRight", true)
	self.VignetteBottomLeft:SetAtlas("GlueDark-Oribos-Corner-BottomLeft", true)
	self.VignetteBottomRight:SetAtlas("GlueDark-Oribos-Corner-BottomRight", true)

	self.ServiceIcon.Border:SetAtlas("GlueDark-Ring-Silver", true)
	self.ServiceIcon.Icon:SetAtlas("GlueDark-Icon-Armor-Gold", true)

	self:SetTitle(RPE_GEAR_UPDATE)

	self.specPool = CreateFramePool("CheckButton", self.Flow, "CharacterUpgradeSelectSpecRadioButtonPKBTTemplate", function(framePool, frame)
		FramePool_HideAndClearAnchors(framePool, frame)
		frame:SetChecked(false)
	end)

	self.steps = {}

	local stepIndex = 1
	local step = self.Flow["Step"..stepIndex]
	while step do
		self.steps[stepIndex] = step
		step:SetID(stepIndex)
		stepIndex = stepIndex + 1
		step = self.Flow["Step"..stepIndex]
	end

	self.steps[1].Divider:SetAtlas("PKBT-Divider-Dark", true)
	self.steps[1].Divider:SetAlpha(0.5)

	Mixin(self.steps[2].EquipCheckButton, PKBT_OwnerMixin)
	self.steps[2].EquipCheckButton:SetOwner(self)
	self.steps[2].EquipCheckButton.ButtonText:SetText(RPE_EQUIP_ITEMS)
	self.steps[2].CharacterInfoBackground:SetAtlas("GlueDark-Sign", true)

	self.steps[2].Balance:SetPoint("BOTTOMLEFT", self.Flow.NineSliceInset, "BOTTOMLEFT", 10, -40)
	self.steps[2].Price:SetPoint("BOTTOMRIGHT", self.Flow.NineSliceInset, "BOTTOMRIGHT", -10, -40)

	self.specTypeButtons = {self.steps[2].SpecTypes.PVE, self.steps[2].SpecTypes.PVP}

	for index, specTypeButton in ipairs(self.specTypeButtons) do
		Mixin(specTypeButton, PKBT_OwnerMixin)
		specTypeButton:SetOwner(self)
		specTypeButton:SetID(index == 1 and Enum.CharacterServices.SpecType.PVE or Enum.CharacterServices.SpecType.PVP)
		specTypeButton.ButtonText:SetText(index == 1 and "PVE" or "PVP")
	end

	self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	self:RegisterCustomEvent("CHARACTER_SERVICES_GEAR_BOOST_DONE")
end

function CharacterServiceGearBoostFlowMixin:OnShow()
	CharacterServiceFlowMixin.OnShow(self)

	self:ResetState()
	self:OnDisplaySizeChanged()
	self:UpdateCharacterButtons(true)
	self:SetStep(1)
end

function CharacterServiceGearBoostFlowMixin:OnHide()
	CharacterServiceFlowMixin.OnHide(self)

	self:ResetState()
	self:UpdateCharacterButtons(false)
end

function CharacterServiceGearBoostFlowMixin:OnDisplaySizeChanged()
	local pveTextWidth = (self.steps[2].SpecTypes.PVE.ButtonText:GetStringWidth() + 5)
	self.steps[2].SpecTypes.PVE:SetHitRectInsets(0, -pveTextWidth, 0, 0)

	local pvpTextWidth = (self.steps[2].SpecTypes.PVP.ButtonText:GetStringWidth() + 5)
	self.steps[2].SpecTypes.PVP:SetHitRectInsets(0, -pvpTextWidth, 0, 0)
	self.steps[2].SpecTypes.PVP:SetPoint("BOTTOMRIGHT", -pvpTextWidth, 0)

	self.steps[2].SpecTypes:SetHeight(self.steps[2].SpecTypes.Title:GetHeight() + 10 + self.steps[2].SpecTypes.PVE:GetHeight())

	local equipTextWidth = (self.steps[2].EquipCheckButton.ButtonText:GetStringWidth() + 5)
	self.steps[2].EquipCheckButton:SetHitRectInsets(0, -equipTextWidth, 0, 0)
	self.steps[2].EquipCheckButton:SetPoint("TOP", self.steps[2].SpecHolder, "BOTTOM", self.steps[2].EquipCheckButton:GetWidth() + (5 - equipTextWidth) / 2, -15)
end

function CharacterServiceGearBoostFlowMixin:OnKeyDown(key)
	if CharacterServiceFlowMixin.OnKeyDown(self, key) then
		return
	end
	if key == "ENTER" then
		self:NextStep()
	end
end

function CharacterServiceGearBoostFlowMixin:OnEvent(event, ...)
	if event == "DISPLAY_SIZE_CHANGED" then
		if self:IsVisible() then
			self:OnDisplaySizeChanged()
		end
	elseif event == "CHARACTER_SERVICES_GEAR_BOOST_DONE" then
		local success = ...

		if success then
			CharacterSelect.AutoEnterWorldCharacterIndex = C_CharacterList.GetCharacterIndexByID(self.characterID)
		end

		self:Hide()
	end
end

function CharacterServiceGearBoostFlowMixin:ResetState()
	self.stepIndex = 1
	self.characterID = nil
	self.classID = nil
	self.selectedSpecType = Enum.CharacterServices.SpecType.PVE
	self.selectedSpecIndex = nil
	self.equipItems = true

	self.specPool:ReleaseAll()
	self:UpdateSpecTypeButtons()
	self.steps[2].EquipCheckButton:SetChecked(self.equipItems)
end

function CharacterServiceGearBoostFlowMixin:PreviousStep()
	if self.stepIndex > 1 then
		self:SetStep(self.stepIndex - 1)
	end
end

function CharacterServiceGearBoostFlowMixin:NextStep(isClick)
	if self:IsStepComplete() then
		if self.stepIndex < #self.steps then
			if isClick then
				PlaySound("igMainMenuOptionCheckBoxOn")
			end
			self:SetStep(self.stepIndex + 1)
		else
			self:Finish()
		end
	end
end

function CharacterServiceGearBoostFlowMixin:SetCharacterID(characterID)
	if not C_CharacterServices.CanBoostCharacterGear(characterID) then
		assert(false, "Can't boost that character")
		return
	end

	local name, race, class, level = GetCharacterInfo(characterID)
	local classInfo = C_CreatureInfo.GetClassInfo(class)

	self.characterID = characterID
	self.classID = classInfo.classID

	self:UpdateNextButton()
end

function CharacterServiceGearBoostFlowMixin:UpdateNextButton()
	self.NextButton:SetEnabled(self:IsStepComplete())

	if self.stepIndex == #self.steps then
		if C_CharacterServices.GetBalance() >= C_CharacterServices.GetBoostPrice() or IsGMAccount(true) then
			self.NextButton:SetText(CHARACTER_SERVICES_BUY)
		else
			self.NextButton:SetText(REPLENISH)
		end
	else
		self.NextButton:SetText(NEXT)
	end
end

function CharacterServiceGearBoostFlowMixin:IsStepComplete()
	if self.stepIndex == 1 then
		if not self.characterID or not C_CharacterServices.CanBoostCharacterGear(self.characterID) then
			return false, CHOOSE_CHARACTER_RIGHT
		end
	elseif self.stepIndex == 2 and not self.selectedSpecIndex then
		return false, RPE_NO_SPEC_SELECTED
	end
	return true
end

function CharacterServiceGearBoostFlowMixin:SetStep(stepIndex)
	self.stepIndex = stepIndex

	self.TitleText:SetShown(self.stepIndex == 1)
	self.steps[2].CharacterInfoBackground:SetShown(self.stepIndex == 2)
	self.BackButton:SetEnabled(self.stepIndex > 1)
	self:UpdateNextButton()

	for index, step in ipairs(self.steps) do
		step:SetShown(index == stepIndex)
	end

	local step = self.steps[self.stepIndex]

	if self.stepIndex == 1 then
		self.Flow.NineSliceInset:ClearAllPoints()
		self.Flow.NineSliceInset:SetPoint("TOPLEFT", step, "TOPLEFT", 0, 0)
		self.Flow.NineSliceInset:SetPoint("RIGHT", step, "RIGHT", 0, 0)
		self.Flow.NineSliceInset:SetPoint("BOTTOM", step.Line3, "BOTTOM", 0, -45)

		self.ServiceIcon.Icon:Show()
		self.ServiceIcon.Portrait:Hide()

		if C_CharacterServices.IsBoostHasPVPEquipment() then
			step.Line2.Text:SetText(RPE_INFO_TEXT2)
		else
			step.Line2.Text:SetText(RPE_INFO_TEXT2_NOPVP)
		end
	elseif self.stepIndex == 2 then
		self.Flow.NineSliceInset:ClearAllPoints()
		self.Flow.NineSliceInset:SetPoint("TOPLEFT", step, "TOPLEFT", 0, 0)
		self.Flow.NineSliceInset:SetPoint("RIGHT", step, "RIGHT", 0, 0)
		self.Flow.NineSliceInset:SetPoint("BOTTOM", step.EquipCheckButton, "BOTTOM", 0, -30)

		if not self.characterID then
			local characterID = C_CharacterList.GetSelectedCharacter()
			self:SetCharacterID(characterID)
		end

		assert(self.characterID and self.classID, "No selected character")

		self:UpdateCharacterButtons(true)
		self:UpdateSpecTypeButtons()

		do
			local name, race, class, level, zone, sex = GetCharacterInfo(self.characterID)
			local classInfo = C_CreatureInfo.GetClassInfo(self.classID)
			local _, _, _, color = GetClassColor(classInfo.classFile)

			local raceInfo = C_CreatureInfo.GetRaceInfo(race)

			local factionOverrideID, factionOverrideGroup = C_CharacterList.GetCharacterFactionOverride(self.characterID)
			local factionGroup

			if factionOverrideGroup then
				factionGroup = factionOverrideGroup
			else
				local factionInfo = C_CreatureInfo.GetFactionInfo(race)
				factionGroup = factionInfo.groupTag
			end

			local raceAtlas = string.format("RACE_ICON_ROUND_%s_%s_%s", string.upper(raceInfo.clientFileString), E_SEX[sex or 0], string.upper(factionGroup))
			if C_Texture.HasAtlasInfo(raceAtlas) then
				self.ServiceIcon.Portrait:SetAtlas(raceAtlas)
				self.ServiceIcon.Portrait:Show()
				self.ServiceIcon.Icon:Hide()
			else
				self.ServiceIcon.Icon:Show()
				self.ServiceIcon.Portrait:Hide()
			end
			step.CharacterName:SetText(string.format(RPE_CHARACTER_INFO, name, color, class))
		end

		local price, originalPrice, discount = C_CharacterServices.GetBoostPrice()
		step.Price:SetPrice(price or -1, originalPrice or -1, "PKBT-Icon-Currency-Bonus")

		self.specPool:ReleaseAll()

		local SPEC_OFFSET_Y = 35
		local SPEC_OFFSET_Y_FIRST = 40

		local changedSpecType = false
		local hasPVPEquipment = C_CharacterServices.IsBoostHasPVPEquipment()

		if hasPVPEquipment then
			step.SpecTypes:Show()
			step.SpecHolder:SetPoint("TOP", step.SpecTypes, "BOTTOM", 0, -25)
		else
			step.SpecTypes:Hide()
			step.SpecHolder:SetPoint("TOP", step.CharacterName, "BOTTOM", 0, -60)
		end

		do
			if self.selectedSpecType == Enum.CharacterServices.SpecType.PVE then
				step.SpecHolder.Title:SetText(CHOOSE_SPECIALIZATION)
			elseif self.selectedSpecType == Enum.CharacterServices.SpecType.PVP then
				step.SpecHolder.Title:SetText(CHOOSE_PVP_SPECIALIZATION)
			end

			local height = step.SpecHolder.Title:GetHeight()
			local lastButton

			for specIndex, spec in ipairs(C_CharacterServices.GetBoostCharacterSpecs(self.classID, self.selectedSpecType)) do
				local button = self.specPool:Acquire()
				button:SetOwner(self)
				button:SetParent(step.SpecHolder)
				button:SetID(specIndex)
				button.Name:SetText(spec.name)
				button.Icon:SetTexture(spec.icon)
				button.Icon:SetDesaturated(spec.iconDesaturate)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-IconRole-Alt-"..spec.role) or "GlueDark-IconRole-Alt-DAMAGER")
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description
				button:UpdateButtonInfo(self.classID, self.selectedSpecType, specIndex)

				if changedSpecType then
					button:SetChecked(false)
				end

				if lastButton then
					button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -SPEC_OFFSET_Y)
					height = height + SPEC_OFFSET_Y
				else
					local offsetX = button:GetWidth() + ((select(2, button:GetHitRectInsets()))) / 2
					button:SetPoint("TOPLEFT", -offsetX, -SPEC_OFFSET_Y_FIRST)
					height = height + SPEC_OFFSET_Y_FIRST
				end

				button:Show()

				height = height + button:GetHeight()
				lastButton = button
			end

			step.SpecHolder:SetHeight(height)
		end

		if changedSpecType then
			self.selectedSpecIndex = nil
			self:UpdateNextButton()
		end
	end
end

function CharacterServiceGearBoostFlowMixin:Finish()
	assert(self.characterID, "No character selected")
	assert(self.selectedSpecIndex, "No spec selected")

	if C_CharacterServices.GetBalance() >= C_CharacterServices.GetBoostPrice() or IsGMAccount(true) then
		local name, race, class, level = GetCharacterInfo(self.characterID)
		local classInfo = C_CreatureInfo.GetClassInfo(self.classID)
		local _, _, _, color = GetClassColor(classInfo.classFile)

		local data = {self.characterID, self.selectedSpecType, self.selectedSpecIndex, self.equipItems}
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
		GlueDialog:ShowDialog("CHARACTER_SERVICES_GEAR_BOOST_CONFIRM", string.format(CHARACTER_GEAR_BOOST_CONFIRM_TEXT, color, name), data)
	else
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT)
		GlueDialog:ShowDialog("CHARACTER_SERVICES_NOT_ENOUGH_MONEY", CHARACTER_SERVICES_NOT_ENOUGH_MONEY)
	end
end

function CharacterServiceGearBoostFlowMixin:UpdateCharacterButtons(isBoostMode)
	if not isBoostMode then
		for i = 1, C_CharacterList.GetNumCharactersPerPage() do
			local button = _G["CharSelectCharacterButton"..i]
			button:Enable()
			button:SetBoostMode(false)
		end
		return
	end

	for characterIndex = 1, C_CharacterList.GetNumCharactersOnPage() do
		local button = _G["CharSelectCharacterButton"..characterIndex]
		local characterID = GetCharIDFromIndex(characterIndex)

		if C_CharacterServices.CanBoostCharacterGear(characterID)
		and (not self.characterID or self.characterID == characterID)
		then
			button:Enable()
			button:SetBoostMode(true, true)

			if self.characterID == characterID then
				button.selection:Show()
			end
		else
			button:Disable()
			button:SetBoostMode(true)
		end
	end
end

function CharacterServiceGearBoostFlowMixin:UpdateSpecTypeButtons()
	for _, specTypeButton in ipairs(self.specTypeButtons) do
		specTypeButton:SetChecked(specTypeButton:GetID() == self.selectedSpecType)
	end
end

function CharacterServiceGearBoostFlowMixin:OnWorldEnterAttempt()
	GlueDialog:ShowDialog("LOCK_GEAR_BOOST_ENTER_WORLD", CHARACTER_SERVICES_DIALOG_GEAR_BOOST_ENTER_WORLD)
end

function CharacterServiceGearBoostFlowMixin:OnEnterNextButton(this)
	local complete, errorText = self:IsStepComplete()
	if not complete then
		GlueTooltip:SetOwner(this, "ANCHOR_TOP", 0, 5)
		GlueTooltip:AddLine(errorText, 1, 0, 0)
		GlueTooltip:Show()
	end
end

function CharacterServiceGearBoostFlowMixin:OnLeaveNextButton(this)
	GlueTooltip:Hide()
end

function CharacterServiceGearBoostFlowMixin:OnClickSpecButton(this, button)
	if not this:GetChecked() and self.selectedSpecIndex == this:GetID() then
		this:SetChecked(true)
		return
	end

	PlaySound("igMainMenuOptionCheckBoxOn")

	for specButton in self.specPool:EnumerateActive() do
		if specButton ~= this then
			specButton:SetChecked(false)
		end
	end

	self.selectedSpecIndex = this:GetID()

	self:UpdateNextButton()
end

function CharacterServiceGearBoostFlowMixin:OnClickSpecTypeCheckBox(this, button)
	PlaySound("igMainMenuOptionCheckBoxOn")

	self.selectedSpecType = this:GetID()
	self:SetStep(2)
	self:UpdateNextButton()
end

function CharacterServiceGearBoostFlowMixin:OnClickEquipCheckButton(this, button)
	PlaySound("igMainMenuOptionCheckBoxOn")
	self.equipItems = this:GetChecked() == 1
end

function CharacterServiceGearBoostFlowMixin:OnEnterEquipCheckButton(this)
	GlueTooltip:SetOwner(this, "ANCHOR_RIGHT", 0, 5)
	GlueTooltip:SetMaxWidth(350)
	GlueTooltip:AddLine(RPE_EQUIP_ITEMS_TOOLTIP, 1, 1, 1)
	GlueTooltip:Show()
end

function CharacterServiceGearBoostFlowMixin:OnLeaveEquipCheckButton(this)
	GlueTooltip:Hide()
end

CharacterServicePriceMixin = {}

function CharacterServicePriceMixin:OnLoad()
	self.texturePool = CreateTexturePool(self, "ARTWORK", nil, "GlueDark-Glyph-FQTC-Angled-0", function(this, obj)
		obj:Hide()
		obj:ClearAllPoints()
		obj:SetAlpha(1)
	end)
end

function CharacterServicePriceMixin:SetPrice(price, originalPrice)
	self.price = tonumber(price) or 0
	self.originalPrice = tonumber(originalPrice) or self.price

	if type(self.OnPriceChanged) == "function" then
		self.OnPriceChanged(self.price, self.originalPrice)
	end

	self.texturePool:ReleaseAll()

	if self.price <= 0 then
		self.NoPrice:Show()
		self.PriceCurrencyIcon:Hide()
		self.StrikeThrough:Hide()
	else
		self.NoPrice:Hide()
		self.PriceCurrencyIcon:Show()
		self:DrawPrice()
	end
end

function CharacterServicePriceMixin:DrawPrice()
	local PRICE_WIDTH, PRICE_HEIGHT								= 21, 32
	local PRICE_WS_WIDTH, PRICE_WS_HEIGHT						= 17, 26
	local PRICE_SALE_WIDTH, PRICE_SALE_HEIGHT					= 11, 16
	local PRICE_PADDING_X, PRICE_PADDING_Y						= -1, 1
	local PRICE_WS_BASE_OFFSET_X, PRICE_WS_BASE_OFFSET_Y		= -21, 0
	local PRICE_SALE_BASE_OFFSET_X, PRICE_SALE_BASE_OFFSET_Y	= 38, 5

	local isOriginalPricePass, firstTexture, prevTexture
	local length

	local hasOriginalPrice = self.price ~= self.originalPrice

	local priceStr = tostring(self.price)
	while priceStr do
		length = string.len(priceStr)
		for i = 1, length do
			local number = string.sub(priceStr, i, i)
			local texture = self.texturePool:Acquire()
			texture:SetAtlas("GlueDark-Glyph-FQTC-Angled-"..number)

			if isOriginalPricePass then
				texture:SetSize(PRICE_SALE_WIDTH, PRICE_SALE_HEIGHT)
				texture:SetAlpha(0.8)
			elseif hasOriginalPrice then
				texture:SetSize(PRICE_WS_WIDTH, PRICE_WS_HEIGHT)
			else
				texture:SetSize(PRICE_WIDTH, PRICE_HEIGHT)
			end

			if isOriginalPricePass then
				texture:SetVertexColor(1, 1, 1)
			else
				if self.price < self.originalPrice then
					texture:SetVertexColor(self:GetDiscountColor())
				elseif self.price > self.originalPrice then
					texture:SetVertexColor(self:GetMarkupColor())
				else
					texture:SetVertexColor(self:GetDefaultValueColor())
				end
			end

			if i == 1 then
				firstTexture = texture

				if isOriginalPricePass then		-- preSale price position
					texture:SetPoint("CENTER", self.Background, "CENTER", PRICE_SALE_BASE_OFFSET_X + -(math.ceil((length * (PRICE_SALE_WIDTH + PRICE_PADDING_X) - PRICE_PADDING_X) / 2)), PRICE_SALE_BASE_OFFSET_Y + length * -PRICE_PADDING_Y)
				elseif hasOriginalPrice then	-- sale price position
					texture:SetPoint("CENTER", self.Background, "CENTER", PRICE_WS_BASE_OFFSET_X + (math.ceil((length * (-PRICE_WS_WIDTH + PRICE_PADDING_X) - PRICE_PADDING_X) / 2)), PRICE_WS_BASE_OFFSET_Y + length * -PRICE_PADDING_Y)
				else							-- price position
					texture:SetPoint("CENTER", self.Background, "CENTER", math.ceil(length * (-PRICE_WIDTH + PRICE_PADDING_X) / 2), length * -PRICE_PADDING_Y)
				end
			else
				texture:SetPoint("BOTTOMLEFT", prevTexture, "BOTTOMRIGHT", PRICE_PADDING_X, PRICE_PADDING_Y)
			end

			texture:Show()
			prevTexture = texture
		end

		if not isOriginalPricePass and hasOriginalPrice then
			priceStr = tostring(self.originalPrice)
			isOriginalPricePass = true
		else
			break
		end
	end

	if hasOriginalPrice then
		self.PriceCurrencyIcon:SetPoint("CENTER", self.Background, 4, 0)

		self.StrikeThrough:SetRotation(math.rad(4 + length * 2))
		self.StrikeThrough:ClearAllPoints()
		self.StrikeThrough:SetPoint("BOTTOMLEFT", firstTexture, "BOTTOMLEFT", 0, PRICE_SALE_HEIGHT / 2 - 15)
		self.StrikeThrough:SetPoint("BOTTOMRIGHT", prevTexture, "BOTTOMRIGHT", 2, PRICE_SALE_HEIGHT / 2 - 3)
		self.StrikeThrough:Show()
	else
		self.PriceCurrencyIcon:SetPoint("CENTER", self.Background, 30, 2)
		self.StrikeThrough:Hide()
	end
end

function CharacterServicePriceMixin:GetPrice()
	return self.price
end

function CharacterServicePriceMixin:GetOriginalPrice()
	return self.originalPrice or self.price
end

function CharacterServicePriceMixin:SetDefaultValueColorOverride(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.__colorOverrideDefaultValueR = r
		self.__colorOverrideDefaultValueG = g
		self.__colorOverrideDefaultValueB = b
	else
		self.__colorOverrideDefaultValueR = nil
		self.__colorOverrideDefaultValueG = nil
		self.__colorOverrideDefaultValueB = nil
	end
end

function CharacterServicePriceMixin:GetDefaultValueColor()
	if self.__colorOverrideDefaultValueR then
		return self.__colorOverrideDefaultValueR, self.__colorOverrideDefaultValueG, self.__colorOverrideDefaultValueB
	end
	return 1, 1, 1
end

function CharacterServicePriceMixin:SetDiscountColorOverride(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.__colorOverrideDiscountR = r
		self.__colorOverrideDiscountG = g
		self.__colorOverrideDiscountB = b
	else
		self.__colorOverrideDiscountR = nil
		self.__colorOverrideDiscountG = nil
		self.__colorOverrideDiscountB = nil
	end
end

function CharacterServicePriceMixin:GetDiscountColor()
	if self.__colorOverrideDiscountR then
		return self.__colorOverrideDiscountR, self.__colorOverrideDiscountG, self.__colorOverrideDiscountB
	end
	return 0.102, 1, 0.102
end

function CharacterServicePriceMixin:SetMarkupColorOverride(r, g, b)
	if type(r) == "number" and type(g) == "number" and type(b) == "number" then
		self.__colorOverrideMarkupR = r
		self.__colorOverrideMarkupG = g
		self.__colorOverrideMarkupB = b
	else
		self.__colorOverrideMarkupR = nil
		self.__colorOverrideMarkupG = nil
		self.__colorOverrideMarkupB = nil
	end
end

function CharacterServicePriceMixin:GetMarkupColor()
	if self.__colorOverrideMarkupR then
		return self.__colorOverrideMarkupR, self.__colorOverrideMarkupG, self.__colorOverrideMarkupB
	end
	return 0.3, 0.7, 1
end

CharacterServiceDialogPriceMixin = {}

function CharacterServiceDialogPriceMixin:OnLoad()
	self.BlockingFrame:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 0, 0)
	self.BlockingFrame:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", 0, 0)

	self.TopShadow:SetVertexColor(0, 0, 0, 0.7)

	self.Description:SetFontObject(self:GetAttribute("DescriptionFontObject") or "GlueDark_Font_Shadow_13")
	self.Warning:SetFontObject(self:GetAttribute("WarningFontObject") or "GlueDark_Font_Shadow_14")

	self.Title:SetText(self:GetAttributeGlobalString("Title"))
	self.PreDescription:SetText(self:GetAttributeGlobalString("PreDescription"))
	self.Description:SetText(self:GetAttributeGlobalString("Description"))
	self.Warning:SetText(self:GetAttributeGlobalString("WarningHTML"))

	local artworkAtlas = self:GetAttribute("ArtworkAtlas")
	if artworkAtlas then
		self.Artwork:SetAtlas(artworkAtlas)
	else
		self.Artwork:Hide()
	end

	self.Price.OnPriceChanged = function(price, originalPrice)
		self:OnPriceChanged(price, originalPrice)
	end

	self:RegisterCustomEvent("ACCOUNT_BALANCE_UPDATE")
end

function CharacterServiceDialogPriceMixin:OnEvent(event, ...)
	if event == "ACCOUNT_BALANCE_UPDATE" then
		if self:IsShown() then
			self:UpdateBalance()
		end
	end
end

function CharacterServiceDialogPriceMixin:OnShow()
	if self:GetFrameLevel() < 2 then
		self:SetFrameLevel(2)
	end
	self.BlockingFrame:SetFrameLevel(self:GetFrameLevel() - 1)
	self:UpdateContent()
end

function CharacterServiceDialogPriceMixin:GetAttributeGlobalString(attribute, fallback)
	local str = self:GetAttribute(attribute)
	if not str or str == "" then
		return fallback or ""
	end
	return _G[str] or fallback or ""
end

function CharacterServiceDialogPriceMixin:Close()
	self:Hide()
	if type(self.OnClose) == "function" then
		self:OnClose()
	end
end

function CharacterServiceDialogPriceMixin:UpdateContent()
	self:UpdateBalance()
end

function CharacterServiceDialogPriceMixin:UpdateBalance()
	self.Balance:UpdateBalance()
	self:UpdatePurchaseButton()
end

function CharacterServiceDialogPriceMixin:UpdatePurchaseButton()
	local price = self.Price:GetPrice()
	if price then
		local balance = C_CharacterServices.GetBalance()
		if self.Price:GetPrice() == 0 then
			self.PurchaseButton:SetText(self:GetAttributeGlobalString("FreeUseText", CHARACTER_SERVICES_FREE_USE))
		elseif balance >= price or IsGMAccount(true) then
			self.PurchaseButton:SetText(self:GetAttributeGlobalString("PurchaseText", CHARACTER_SERVICES_BUY))
		else
			self.PurchaseButton:SetText(REPLENISH)
		end
	end
end

function CharacterServiceDialogPriceMixin:SetPrice(price, originalPrice)
	self.Price:SetPrice(price, originalPrice)
	self:UpdatePurchaseButton()
end

function CharacterServiceDialogPriceMixin:OnPriceChanged(price, originalPrice)
	self.Balance:SetShown(price > 0)
end

function CharacterServiceDialogPriceMixin:SetPurchaseArgs(...)
	self.purchaseArgs = {...}
end

CharacterServiceBalanceMixin = {}

function CharacterServiceBalanceMixin:OnLoad()
	self.CurrencyIcon:SetAtlas("PKBT-Icon-Currency-Bonus")

	self:RegisterCustomEvent("ACCOUNT_BALANCE_UPDATE")
end

function CharacterServiceBalanceMixin:OnEvent(event, ...)
	if event == "ACCOUNT_BALANCE_UPDATE" then
		if self:IsVisible() then
			self:UpdateBalance()
		end
	end
end

function CharacterServiceBalanceMixin:OnShow()
	self:UpdateBalance()
end

function CharacterServiceBalanceMixin:UpdateBalance()
	local balance = C_CharacterServices.GetBalance()
	self.Balance:SetFormattedText(CHARACTER_SERVICES_YOU_HAVE_BONUS, balance)
	self:UpdateRect()
end

function CharacterServiceBalanceMixin:UpdateRect()
	self:SetWidth(self.Balance:GetStringWidth() + 4 + self.CurrencyIcon:GetWidth())
end

CharacterServiceBalancePKBTMixin = CreateFromMixins(CharacterServiceBalanceMixin)

function CharacterServiceBalancePKBTMixin:UpdateBalance()
	local balance = C_CharacterServices.GetBalance()
	self.Balance:SetText(balance)
	self:UpdateRect()
end

function CharacterServiceBalancePKBTMixin:UpdateRect()
	self:SetWidth(self.Label:GetStringWidth() + 4 + self.CurrencyIcon:GetWidth() + 4 + self.Balance:GetStringWidth())
end

CharacterServiceBoostPurchaseMixin = CreateFromMixins(CharacterServiceDialogPriceMixin)

function CharacterServiceBoostPurchaseMixin:OnLoad()
	CharacterServiceDialogPriceMixin.OnLoad(self)

	self.Artwork:SetPoint("TOPRIGHT", -20, -62)
end

function CharacterServiceBoostPurchaseMixin:Preview()
	PlaySound("igMainMenuOptionCheckBoxOn")
	BoostServiceItemBrowserFrame:Show()
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

CharacterServiceBoostRefundMixin = CreateFromMixins(CharacterServiceDialogPriceMixin)

function CharacterServiceBoostRefundMixin:OnLoad()
	CharacterServiceDialogPriceMixin.OnLoad(self)

	self.Description:SetWidth(260)
	self.Artwork:SetPoint("TOPRIGHT", -20, -62)
	self.PurchaseButton:SetText(CHARACTER_SERVICES_BOOST_REFUND_ACTION)

	self.Warning:ClearAllPoints()
--	self.Warning:SetPoint("CENTER", self.Description, "CENTER", 0, 0)
	self.Warning:SetPoint("BOTTOM", self.TimerHolder, "TOP", 0, 10)

	self.Price:Hide()
	self.Balance:Hide()

	self.RefundAmount.CurrencyIcon:SetAtlas("PKBT-Icon-Currency-Bonus")
end

function CharacterServiceBoostRefundMixin:OnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed < 0.2 then
		return
	end

	self.timeLeft = math.max(0, self.timeLeft - self.elapsed)
	self.timeLeftFullPrice = math.max(0, self.timeLeftFullPrice - self.elapsed)
	self.elapsed = 0

	if self.timeLeft > 0 then
		self:UpdateTimers()
	else
		self:UpdateContent()
	end
end

function CharacterServiceBoostRefundMixin:UpdateTimers()
	self.TimerHolder.FullPriceTimeLeft:SetText(self.timeLeftFullPrice > 0 and GetRemainingTime(math.ceil(self.timeLeftFullPrice)) or RED_FONT_COLOR:WrapTextInColorCode(UNAVAILABLE))
	self.TimerHolder.PenaltyTimeLeft:SetText(self.timeLeft > 0 and GetRemainingTime(math.ceil(self.timeLeft)) or RED_FONT_COLOR:WrapTextInColorCode(UNAVAILABLE))

	local refunAmount = self.timeLeftFullPrice > 0 and self.priceFull or self.pricePenalty
	self.RefundAmount.Text:SetFormattedText(CHARACTER_SERVICES_BOOST_REFUND_AMOUNT, refunAmount)
	self.RefundAmount:SetWidth(self.RefundAmount.Text:GetStringWidth() + 4 + self.RefundAmount.CurrencyIcon:GetWidth())
	self.RefundAmount:SetShown(self.timeLeft > 0)

	self.PurchaseButton:SetEnabled(self.timeLeft > 0)
end

function CharacterServiceBoostRefundMixin:UpdateTimerHolderRect()
	local labelWidth = math.max(self.TimerHolder.FullPriceLabel:GetStringWidth(), self.TimerHolder.PenaltyLabel:GetStringWidth())
	local timerWidth = math.max(self.TimerHolder.FullPriceTimeLeft:GetStringWidth(), self.TimerHolder.PenaltyTimeLeft:GetStringWidth())
	self.TimerHolder:SetWidth(labelWidth + 20 + timerWidth)
end

function CharacterServiceBoostRefundMixin:UpdateContent()
	CharacterServiceDialogPriceMixin.UpdateContent(self)

	local timeLeft, timeLeftFullPrice, priceFull, pricePenalty, penaltyPercents = C_CharacterServices.GetBoostRefundInfo()

	self.priceFull = priceFull
	self.pricePenalty = pricePenalty
	self.timeLeft = timeLeft or 0
	self.timeLeftFullPrice = timeLeftFullPrice or 0

	self.Description:SetFormattedText(CHARACTER_SERVICES_BOOST_REFUND_DESCRIPTION, penaltyPercents)
	self.TimerHolder.PenaltyLabel:SetFormattedText(CHARACTER_SERVICES_BOOST_REFUND_TIMELEFT_PENALTY, penaltyPercents)

	self:SetScript("OnUpdate", self.timeLeft > 0 and self.OnUpdate or nil)
	self:UpdateTimers()
	self:UpdateTimerHolderRect()
end

function CharacterServiceBoostRefundMixin:UpdateBalance()
end

function CharacterServiceBoostRefundMixin:Purchase()
	local timeLeft, timeLeftFullPrice, priceFull, pricePenalty, penaltyPercents = C_CharacterServices.GetBoostRefundInfo()
	if timeLeft > 0 then
		PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT)
		CharacterBoostRefundConfirmationDialog:SetParentDialog(self)
		CharacterBoostRefundConfirmationDialog:ShowDialog()
	else
		self:UpdateContent()
	end
end

CharacterServiceRestoreCharacterMixin = CreateFromMixins(CharacterServiceDialogPriceMixin)

function CharacterServiceRestoreCharacterMixin:OnLoad()
	CharacterServiceDialogPriceMixin.OnLoad(self)

	self.Description:SetWidth(280)
	self.Description:SetPoint("TOPLEFT", 18, -113)
	self.Warning:SetPoint("TOP", self.Description, "BOTTOM", 0, -30)

	self.Price:ClearAllPoints()
	self.Price:SetPoint("CENTER", self.Description, "CENTER", 0, 0)
	self.Price:SetPoint("BOTTOM", 0, 30)
end

function CharacterServiceRestoreCharacterMixin:OnPriceChanged(price, originalPrice)
	CharacterServiceDialogPriceMixin.OnPriceChanged(self, price, originalPrice)

	if price == 0 then
		self.Description:SetWidth(300)
		self.Warning:Show()
	else
		self.Description:SetWidth(280)
		self.Warning:Hide()
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

	self.Artwork:SetPoint("TOPRIGHT", -20, -66)
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
		self.Description:SetPoint("TOPLEFT", 18, -108)
		self.Description:SetText(CHARACTER_SERVICES_LISTPAGE_DESCRIPTION_ALT)
		self.Warning:Show()
	else
		self.Description:SetPoint("TOPLEFT", 18, -83)
		self.Description:SetText(CHARACTER_SERVICES_LISTPAGE_DESCRIPTION)
		self.Warning:Hide()
	end
end

BoostServiceItemBrowserMixin = {}

function BoostServiceItemBrowserMixin:OnLoad()
	self.specPool = CreateFramePool("Button", self.Container.SpecHolder, "CharacterServiceSpecButtonTemplate")

	self.classButtons = {}
	self.stepIndex = 1

	self.BUTTON_PADDING = 10
end

function BoostServiceItemBrowserMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local button = ...
		if button == "RightButton" and self.stepIndex > 1 then
			PlaySound("igMainMenuOptionCheckBoxOn")
			self:SetStep(self.stepIndex - 1)
		end
	end
end

function BoostServiceItemBrowserMixin:OnShow()
	self:RegisterEvent("GLOBAL_MOUSE_DOWN")
	self:SetStep(1)
end

function BoostServiceItemBrowserMixin:OnHide()
	self:RegisterEvent("GLOBAL_MOUSE_DOWN")
	self.classID = nil
	self.specIndex = nil
	self.specType = nil
end

function BoostServiceItemBrowserMixin:Close()
	self:Hide()
end

function BoostServiceItemBrowserMixin:OnClickBack()
	PlaySound("igMainMenuOptionCheckBoxOn")

	if self.stepIndex > 1 then
		self:SetStep(self.stepIndex - 1)
	else
		self:Hide()
	end
end

function BoostServiceItemBrowserMixin:SetStep(stepIndex)
	self.stepIndex = stepIndex

	self.Container.BackButton:SetText(self.stepIndex > 1 and BACK or CLOSE)

	self.Container.Separator:SetShown(self.stepIndex > 1)
	self.Container.Description:SetShown(self.stepIndex > 1)

	self.Container.ClassHolder:SetShown(self.stepIndex == 1)
	self.Container.SpecHolder:SetShown(self.stepIndex == 2)
	self.Container.Items:SetShown(self.stepIndex == 3)

	if self.stepIndex == 1 then
		self.Container.Title:SetText(BOOST_PREVIEW_SELECT_CLASS)

		self.classID = nil

		if not self.classList then
			self.classList = {}

			for classID, classData in pairs(S_CLASS_SORT_ORDER) do
				if classID ~= CLASS_ID_DEMONHUNTER then
					table.insert(self.classList, classData)
				end
			end

			table.sort(self.classList, function(a, b)
				return a[4] < b[4]
			end)
		end

		local CONTAINER_WIDTH = self.Container.ClassHolder:GetWidth()

		for index, classData in ipairs(self.classList) do
			local button = self.classButtons[index]
			if not button then
				local flag, className, classID, localizedClassNameMale, localizedClassNameFemale = unpack(classData)
				button = CreateFrame("Button", string.format("$parentClassButton%u", index), self.Container.ClassHolder, "CharacterServiceClassButtonTemplate", classID)
				button:SetOwner(self)
				button:SetWidth(CONTAINER_WIDTH / 2 - self.BUTTON_PADDING)
				button.Name:SetText(localizedClassNameMale)
				button.Icon:SetTexture(string.format([[Interface\Custom\ClassIcon\CLASS_ICON_%s]], className))

				if index == 1 then
					button:SetPoint("TOPLEFT", self.BUTTON_PADDING, -self.BUTTON_PADDING)
				elseif index % 5 == 1 then
					button:SetPoint("TOPLEFT", CONTAINER_WIDTH / 2, -self.BUTTON_PADDING)
				else
					button:SetPoint("TOPLEFT", self.classButtons[index - 1], "BOTTOMLEFT", 0, -self.BUTTON_PADDING)
				end

				self.classButtons[index] = button
			end

			button:Show()
		end
	elseif self.stepIndex == 2 then
		self.Container.Title:SetText(BOOST_PREVIEW_SELECT_SPEC)

		local classInfo = C_CreatureInfo.GetClassInfo(self.classID)
		local r, g, b, hex = GetClassColor(classInfo.classFile)
		self.Container.Description:SetFormattedText("|c%s%s|r", hex, classInfo.localizeName.male)

		self.specIndex = nil
		self.specType = nil

		self.specPool:ReleaseAll()

		local CONTAINER_WIDTH = self.Container.SpecHolder:GetWidth()
		self.Container.SpecHolder.PVE:SetWidth(CONTAINER_WIDTH / 2)
		self.Container.SpecHolder.PVP:SetWidth(CONTAINER_WIDTH / 2)

		local specTypes = {}

		if C_CharacterServices.IsBoostHasPVPEquipment() then
			specTypes = {Enum.CharacterServices.SpecType.PVE, Enum.CharacterServices.SpecType.PVP}
			self.Container.SpecHolder.PVP.NotAvailable:Hide()
		else
			specTypes = {Enum.CharacterServices.SpecType.PVE}
			self.Container.SpecHolder.PVP.NotAvailable:Show()
		end

		for specTypeIndex, specType in ipairs(specTypes) do
			local specs = C_CharacterServices.GetBoostCharacterSpecs(self.classID, specType)
			local lastButton

			for specIndex, spec in ipairs(specs) do
				local button = self.specPool:Acquire()
				button:SetOwner(self)
				button:SetWidth(CONTAINER_WIDTH / 2 - self.BUTTON_PADDING)
				button.Name:SetText(spec.name)
				button.Icon:SetTexture(spec.icon)
				button.Icon:SetDesaturated(spec.iconDesaturate)
				button.RoleIcon:SetAtlas(spec.role and ("GlueDark-IconRole-"..spec.role) or "GlueDark-IconRole-DAMAGER")
				button.HelpButton.InfoHeader = spec.name
				button.HelpButton.InfoText = spec.description

				button.HelpButton:Hide()
				button.ItemBrowse:EnableMouse(false)
				button.ItemBrowse.noItemBrowseArrow = true

				button:UpdateButtonInfo(self.classID, specType, specIndex)

				if lastButton then
					button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -self.BUTTON_PADDING)
				elseif specTypeIndex == 1 then
					button:SetPoint("TOPLEFT", self.Container.SpecHolder.PVE, "TOPLEFT", self.BUTTON_PADDING, -28)
				elseif specTypeIndex == 2 then
					button:SetPoint("TOPLEFT", self.Container.SpecHolder.PVP, "TOPLEFT", 0, -28)
				end

				button:Show()
				lastButton = button
			end
		end
	elseif self.stepIndex == 3 then
		local specs = C_CharacterServices.GetBoostCharacterSpecs(self.classID, self.specType)
		local spec = specs[self.specIndex]

		local classInfo = C_CreatureInfo.GetClassInfo(self.classID)
		local r, g, b, hex = GetClassColor(classInfo.classFile)

		self.Container.Title:SetText(self.specType == Enum.CharacterServices.SpecType.PVE and BOOST_SPEC_ITEMS_PVE or BOOST_SPEC_ITEMS_PVP)
		self.Container.Description:SetFormattedText("|c%s%s|r - %s", hex, classInfo.localizeName.male, spec.name)

		self.Container.Items:ShowSpecItems(self.classID, self.specType, self.specIndex)
	end
end

function BoostServiceItemBrowserMixin:OnClickClassButton(this, button)
	self.classID = this:GetID()

	if not C_CharacterServices.IsBoostClassSpecItemsLoaded(self.classID) then
		C_CharacterServices.RequestSpecItems(self.classID)
	end

	PlaySound("igMainMenuOptionCheckBoxOn")
	self:SetStep(2)
end

function BoostServiceItemBrowserMixin:OnClickSpecButton(this, button)
	self.specType = this.specType
	self.specIndex = this.specIndex

	PlaySound("igMainMenuOptionCheckBoxOn")
	self:SetStep(3)
end

CharacterServiceIconButtonMixin = CreateFromMixins(PKBT_OwnerMixin)

function CharacterServiceIconButtonMixin:OnEnter()
	if not self:IsObjectType("CheckButton") then
		self.Name:SetVertexColor(1, 1, 1)
	end
end

function CharacterServiceIconButtonMixin:OnLeave()
	if not self:IsObjectType("CheckButton") then
		self.Name:SetVertexColor(1, 0.82, 0)
	end
end

function CharacterServiceIconButtonMixin:OnClick(button)
end

CharacterUpgradeSelectClassButtonMixin = CreateFromMixins(CharacterServiceIconButtonMixin)

function CharacterUpgradeSelectClassButtonMixin:OnClick(button)
	self:GetOwner():OnClickClassButton(self, button)
end

CharacterServiceSpecButtonMixin = CreateFromMixins(CharacterServiceIconButtonMixin)

function CharacterServiceSpecButtonMixin:OnLoad()
	self:RegisterCustomEvent("BOOST_SERVICE_ITEMS_LOADED")
end

function CharacterServiceSpecButtonMixin:OnShow()
	if not C_CharacterServices.IsBoostClassSpecItemsLoaded(self.classID) then
		self:RegisterCustomEvent("BOOST_SERVICE_ITEMS_LOADED")
	end
	self:UpdateRect()
end

function CharacterServiceSpecButtonMixin:OnHide()
	self:UnregisterCustomEvent("BOOST_SERVICE_ITEMS_LOADED")
end

function CharacterServiceSpecButtonMixin:OnEvent(event, ...)
	if event == "BOOST_SERVICE_ITEMS_LOADED" then
		local classID = ...
		if self.classID == classID and self:IsVisible() then
			self:UpdateItemLevel()
		end
	end
end

function CharacterServiceSpecButtonMixin:OnClick(button)
	self:GetOwner():OnClickSpecButton(self, button)
end

function CharacterServiceSpecButtonMixin:OnUpdate(elapsed)
	self.loadingElapsed = (self.loadingElapsed or 0) + elapsed
	if self.loadingElapsed >= 0.3 then
		self.loadingElapsed = self.loadingElapsed - 0.3
		self.loadingStep = (self.loadingStep + 1) % 4
		self.ItemBrowse.Text:SetFormattedText("%s%s", LOADING_DATA_LABEL, string.rep(".", self.loadingStep))
	end
end

function CharacterServiceSpecButtonMixin:ToggleLoadingAnimation(enable)
	self.loadingElapsed = 0
	self.loadingStep = 0
	if enable then
		self.ItemBrowse.Text:SetText(LOADING_DATA_LABEL)
	end
	self:SetScript("OnUpdate", enable and self.OnUpdate or nil)
end

function CharacterServiceSpecButtonMixin:UpdateButtonInfo(classID, specType, specIndex)
	self.classID = classID
	self.specType = specType
	self.specIndex = specIndex

	if classID then
		self.Name:SetPoint("LEFT", self.IconBorder, "RIGHT", 10, 10)
		self.ItemBrowse:Show()
		self:UpdateItemLevel()
	else
		self.Name:SetPoint("LEFT", self.IconBorder, "RIGHT", 10, 0)
		self.ItemBrowse:Hide()
	end
end

function CharacterServiceSpecButtonMixin:UpdateItemLevel()
	if C_CharacterServices.IsBoostClassSpecItemsLoaded(self.classID) then
		local avgItemLevel = C_CharacterServices.GetBoostClassSpecAvgItemLevel(self.classID, self.specType, self.specIndex)
		self:ToggleLoadingAnimation(false)
		if self.ItemBrowse.noItemBrowseArrow then
			self.ItemBrowse.Text:SetFormattedText(string.format(BOOST_SERVICE_BROWSE_ITEMS, avgItemLevel))
		else
			self.ItemBrowse.Text:SetFormattedText("> %s", string.format(BOOST_SERVICE_BROWSE_ITEMS, avgItemLevel))
		end
		self.ItemBrowse:Enable()
	else
		self:ToggleLoadingAnimation(true)
		self.ItemBrowse.Text:SetText(LOADING_DATA_LABEL)
		self.ItemBrowse:Disable()
	end
	self:UpdateRect()
end

function CharacterServiceSpecButtonMixin:UpdateRect()
end

function CharacterServiceSpecButtonMixin:ItemButtonOnClick(button)
	PlaySound("igMainMenuOptionCheckBoxOn")
	BoostServiceSpecItemsFrame:ShowSpecItems(self.classID, self.specType, self.specIndex)
end

function CharacterServiceSpecButtonMixin:ItemButtonOnEnter(button)
	self:LockHighlight()
	self.ItemBrowse.Text:SetTextColor(0.1, 1, 0.1)
end

function CharacterServiceSpecButtonMixin:ItemButtonOnLeave(button)
	self:UnlockHighlight()
	self.ItemBrowse.Text:SetTextColor(1, 1, 1)
end

CharacterUpgradeSelectSpecRadioButtonMixin = CreateFromMixins(CharacterServiceSpecButtonMixin)

function CharacterUpgradeSelectSpecRadioButtonMixin:OnLoad()
	CharacterServiceSpecButtonMixin.OnLoad(self)
	self.Icon:SetPoint("LEFT", self, "RIGHT", 10, 0)
end

function CharacterUpgradeSelectSpecRadioButtonMixin:UpdateRect()
	self.ItemBrowse:SetSize(self.ItemBrowse.Text:GetStringWidth(), self.ItemBrowse.Text:GetHeight())
end

function CharacterUpgradeSelectSpecRadioButtonMixin:ItemButtonOnClick(button)
	PlaySound("igMainMenuOptionCheckBoxOn")
	BoostServiceSpecItemsFrame:ShowSpecItems(self.classID, self.specType, self.specIndex)
end

CharacterUpgradeSelectFactionRadioButtonMixin = CreateFromMixins(CharacterServiceSpecButtonMixin)

function CharacterUpgradeSelectFactionRadioButtonMixin:OnLoad()
	CharacterServiceSpecButtonMixin.OnLoad(self)
	self.Icon:SetPoint("LEFT", self, "RIGHT", 10, 0)
end

function CharacterUpgradeSelectFactionRadioButtonMixin:OnClick(button)
	self:GetOwner():OnClickFactionButton(self, button)
end

CharacterServiceSpecButtonPKBTMixin = CreateFromMixins(CharacterServiceSpecButtonMixin)

function CharacterServiceSpecButtonPKBTMixin:OnLoad()
	CharacterServiceSpecButtonMixin.OnLoad(self)
	self.HelpButton:ClearAllPoints()
	self.HelpButton:SetPoint("LEFT", self, "RIGHT")
	self.HelpButton:SetSize(30, 30)
	self.HelpButton.Icon:SetAtlas("PKBT-Icon-Help-i", true)
end

CharacterUpgradeSelectSpecRadioButtonPKBTMixin = CreateFromMixins(PKBT_RadioButtonMixin, CharacterUpgradeSelectSpecRadioButtonMixin, CharacterServiceSpecButtonPKBTMixin)

function CharacterUpgradeSelectSpecRadioButtonPKBTMixin:OnLoad()
	PKBT_RadioButtonMixin.OnLoad(self)
	CharacterServiceSpecButtonPKBTMixin.OnLoad(self)

	self:SetHitRectInsets(0, -220, -17, -17)
	self.Icon:SetPoint("LEFT", self, "RIGHT", 10, 0)

	self.IconBorder:SetAtlas("PKBT-ItemBorder-Default", true)
	self.IconBorder:SetAllPoints(self.Icon)
end

function CharacterUpgradeSelectSpecRadioButtonPKBTMixin:UpdateRect()
	CharacterUpgradeSelectSpecRadioButtonMixin.UpdateRect(self)

	local l, r, t, b = self:GetHitRectInsets()
	self.HelpButton:SetPoint("LEFT", self, "RIGHT", -r, 0)
end

local itemInvTypeSorted = {
	INVTYPE_HEAD			= 1,
	INVTYPE_NECK			= 2,
	INVTYPE_SHOULDER		= 3,
	INVTYPE_CLOAK			= 4,
	INVTYPE_BODY			= 5,
	INVTYPE_CHEST			= 6,
	INVTYPE_ROBE			= 7,
	INVTYPE_TABARD			= 8,
	INVTYPE_WRIST			= 9,
	INVTYPE_HAND			= 10,
	INVTYPE_WAIST			= 11,
	INVTYPE_LEGS			= 12,
	INVTYPE_FEET			= 13,
	INVTYPE_FINGER			= 14,
	INVTYPE_TRINKET			= 15,
	INVTYPE_WEAPON			= 16,
	INVTYPE_2HWEAPON		= 17,
	INVTYPE_WEAPONMAINHAND	= 18,
	INVTYPE_WEAPONOFFHAND	= 19,
	INVTYPE_SHIELD			= 20,
	INVTYPE_HOLDABLE		= 21,
	INVTYPE_RANGEDRIGHT		= 22,
	INVTYPE_RANGED			= 23,
	INVTYPE_THROWN			= 24,
	INVTYPE_RELIC			= 25,
	INVTYPE_AMMO			= 26,
	INVTYPE_BAG				= 27,
	INVTYPE_QUIVER			= 28,
}

BoostServiceSpecItemScrollMixin = {}

function BoostServiceSpecItemScrollMixin:OnLoad()
	self:RegisterCustomEvent("BOOST_SERVICE_ITEMS_LOADED")

	self.Scroll.ScrollBar:SetPoint("TOPLEFT", self.Scroll, "TOPRIGHT", 5, -14)
	self.Scroll.ScrollBar:SetPoint("BOTTOMLEFT", self.Scroll, "BOTTOMRIGHT", 5, 14)

	self.Scroll.update = function(scrollFrame)
		self:OnItemScrollUpdate()
	end
	self.Scroll.scrollBar = self.Scroll.ScrollBar
	HybridScrollFrame_SetDoNotHideScrollBar(self.Scroll, true)
	HybridScrollFrame_CreateButtons(self.Scroll, "BoostServiceSpecItemButtonTemplate", 0, 0)

	self.Loading.Spinner.AnimFrame.Anim:Play()
	self.Loading.Spinner.Text:SetText(BOOST_SPEC_ITEMS_LOADING)
	self.Loading.Spinner.Text:Show()
end

function BoostServiceSpecItemScrollMixin:OnEvent(event, ...)
	if event == "BOOST_SERVICE_ITEMS_LOADED" then
		local classID = ...
		if self:IsVisible() and self.classID == classID then
			self:UpdateSpecItems()
			self:OnItemScrollUpdate()
		end
	end
end

function BoostServiceSpecItemScrollMixin:OnShow()
	SetParentFrameLevel(self.Loading, 5)
	self.dirty = true
	self:OnItemScrollUpdate()
end

function BoostServiceSpecItemScrollMixin:Clear()
	for index, button in ipairs(self.Scroll.buttons) do
		button:Hide()
	end
	self.Scroll.ScrollBar:SetValue(0)
end

function BoostServiceSpecItemScrollMixin:OnHide()
	self:Clear()
	self.classID = nil
	self.specType = nil
	self.specIndex = nil
	self.items = nil
	self.dirty = nil
end

function BoostServiceSpecItemScrollMixin:ShowSpecItems(classID, specType, specIndex)
	self.classID = classID
	self.specType = specType
	self.specIndex = specIndex

	self:UpdateSpecItems()
	self:OnItemScrollUpdate()
end

function BoostServiceSpecItemScrollMixin:UpdateSpecItems()
	self.items = C_CharacterServices.GetBoostClassSpecItems(self.classID, self.specType, self.specIndex)
	self.dirty = true

	for index, item in ipairs(self.items) do
		local name, link, quality, itemLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice, itemClassID, subclassID, equipLocID = C_Item.GetItemInfoCache(item.itemID)
		item.name = name
		item.equipLocID = itemInvTypeSorted[equipSlot]
	end

	table.sort(self.items, function(a, b)
		if a.equipLocID and b.equipLocID and a.equipLocID ~= b.equipLocID then
			return a.equipLocID < b.equipLocID
		elseif a.name and b.name and a.name ~= b.name then
			return a.name < b.name
		end

		return a.itemID < b.itemID
	end)
end

function BoostServiceSpecItemScrollMixin:OnItemScrollUpdate()
	if not self.items then
		return
	end

	local scrollFrame = self.Scroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local numItems = #self.items

	for index, button in ipairs(scrollFrame.buttons) do
		local itemIndex = index + offset
		if itemIndex <= numItems then
			local item = self.items[itemIndex]
			button:SetID(itemIndex)
			button:SetItem(item.itemID, item.amount)
			button:Show()
			if button:IsMouseOver() then
				button:OnEnter()
			end
		else
			button:Hide()
		end
	end

	if #self.items == 0
	and not C_CharacterServices.IsBoostClassSpecItemsLoaded(self.classID)
	and C_CharacterServices.IsBoostClassSpecItemsLoading(self.classID)
	then
		self.Loading:Show()
	else
		self.Loading:Hide()
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		local scrollHeight = buttonHeight * numItems
		HybridScrollFrame_Update(scrollFrame, scrollHeight, scrollFrame:GetHeight())
		self.dirty = nil
	end
end

BoostServiceSpecItemsMixin = {}

function BoostServiceSpecItemsMixin:OnShow()
	SetParentFrameLevel(self.Container.CloseButton, 5)
end

function BoostServiceSpecItemsMixin:ShowSpecItems(classID, specType, specIndex)
	local specs = C_CharacterServices.GetBoostCharacterSpecs(classID, specType)
	local spec = specs[specIndex]

	local classInfo = C_CreatureInfo.GetClassInfo(classID)
	local r, g, b, hex = GetClassColor(classInfo.classFile)

	self.Container.Title:SetFormattedText("|c%s%s|r - %s", hex, classInfo.localizeName.male, spec.name)
	self.Container.Description:SetText(specType == Enum.CharacterServices.SpecType.PVE and BOOST_SPEC_ITEMS_PVE or BOOST_SPEC_ITEMS_PVP)

	self.Container.Items:ShowSpecItems(classID, specType, specIndex)
	self:Show()
end

BoostServiceSpecItemButtonMixin = {}

function BoostServiceSpecItemButtonMixin:OnLoad()
	self.IconBorder:SetAtlas("PKBT-ItemBorder-Default", true)
end

function BoostServiceSpecItemButtonMixin:OnShow()
	self:UpdateRect()
end

function BoostServiceSpecItemButtonMixin:OnEnter()
	if self.itemID and self:IsVisible() then
		local name, link, quality, itemLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice, classID, subclassID, equipLocID = C_Item.GetItemInfoCache(self.itemID)
		local r, g, b = GetItemQualityColor(quality or 1)
		GlueTooltip:SetOwner(self, "ANCHOR_LEFT")
		GlueTooltip:SetMaxWidth(300)
		GlueTooltip:AddLine(name, r, g, b)
		if C_Item.HasItemInfoCache(self.itemID) then
			GlueTooltip:AddLine(_G[equipSlot], 1, 1, 1)
			GlueTooltip:AddLine(string.format(ITEM_LEVEL, itemLevel), 1, 1, 1)
		end
		GlueTooltip:AddLine("")
		GlueTooltip:AddLine(BOOST_SPEC_ITEMS_CLICK_TIP, 0, 0.8, 1)

		if IsGMAccount() then
			GlueTooltip:AddLine("")
			GlueTooltip:AddLine(string.format("ItemID: |cffFFFFFF%d|r", self.itemID), 0.5, 0.5, 0.5)
			GlueTooltip:AddLine(string.format("Icon: |cffFFFFFF%s|r", icon), 0.5, 0.5, 0.5)
		end

		GlueTooltip:Show()
	end
end

function BoostServiceSpecItemButtonMixin:OnLeave()
	GlueTooltip:Hide()
end

function BoostServiceSpecItemButtonMixin:OnClick(button)
	if self.link then
		LaunchURL(self.link)
	end
end

function BoostServiceSpecItemButtonMixin:UpdateRect()
	self.Name:SetWidth(self:GetWidth() - self.Icon:GetWidth() - 15)

	local offsetY = math.max(self.SlotType:GetHeight() + self.ItemLevel:GetHeight())
	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 5, offsetY / 2)
end

function BoostServiceSpecItemButtonMixin:SetItem(itemID, amount)
	local name, link, quality, itemLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice, classID, subclassID, equipLocID = C_Item.GetItemInfoCache(itemID)
	self.Name:SetText(name)
	self.Icon:SetTexture(icon)

	local r, g, b = GetItemQualityColor(quality)
	self.Name:SetTextColor(r, g, b)
	self.IconBorder:SetVertexColor(r, g, b)

	if amount > 1 then
		self.Amount:SetText(amount)
		self.Amount:Show()
	else
		self.Amount:Hide()
	end

	self.SlotType:SetText(_G[equipSlot])
	self.ItemLevel:SetFormattedText(ITEM_LEVEL_COLORED, GetItemLevelColor(itemLevel):GenerateHexColor(), itemLevel)

	self.itemID = itemID
	self.link = link or C_Item.GetItemLink(itemID)

	self:UpdateRect()
end

CharacterServiceSubFrameMixin = {}

function CharacterServiceSubFrameMixin:OnLoad()
	self.Background:SetAtlas("characterupdate_line-item-bg")
	self.Bullet:SetAtlas("characterupdate_arrow-bullet-point", true)
	local text = self:GetAttribute("text")
	if text then
		self.Text:SetText(_G[text] or text)
	end
end

CharacterServiceSubFrameRombMixin = {}

function CharacterServiceSubFrameRombMixin:OnLoad()
	self.Bullet:SetAtlas("GlueDark-Icon-Romb", true)
	local text = self:GetAttribute("text")
	if text then
		self.Text:SetText(_G[text] or text)
	end
end

CharacterServiceBoostActivationDialogMixin = CreateFromMixins(CharacterActionDialogMixin)

function CharacterServiceBoostActivationDialogMixin:UpdateContainer()
	CharacterActionDialogMixin.UpdateContainer(self)

	if not C_CharacterServices.IsBoostCancelAvailable() then
		self.Warning:Hide()
	end
end

function CharacterServiceBoostActivationDialogMixin:OnAccept()
	if self.characterID then
		C_CharacterServices.BoostCharacter(self.characterID,
			BOOST_SELECTED_PROFESSION_MAIN,
			BOOST_SELECTED_PROFFESION_ADDITIONAL,
			BOOST_SELECTED_SPEC_PVE,
			BOOST_SELECTED_SPEC_PVP,
			BOOST_SELECTED_FACTION or 0
		)
		return true
	end
end

function CharacterServiceBoostActivationDialogMixin:OnCancel()
	CharacterServiceBoostFlowFrame:Hide()
end