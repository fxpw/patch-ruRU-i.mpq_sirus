--	Filename:	CharacterCreate.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

PAID_CHARACTER_CUSTOMIZATION = 1
PAID_RACE_CHANGE = 2
PAID_FACTION_CHANGE = 3
PAID_SERVICE_CHARACTER_ID = nil
PAID_SERVICE_TYPE = nil

local PAID_RACE_SERVICE_OVERRIDE_FACTIONS = {
	[FACTION_HORDE]		= PLAYER_FACTION_GROUP.Alliance,
	[FACTION_ALLIANCE]	= PLAYER_FACTION_GROUP.Horde,
}

local PAID_RACE_SERVICE_OVERRIDE_RACES = {
	[FACTION_ALLIANCE] = {
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= E_CHARACTER_RACES.RACE_PANDAREN_HORDE,
		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= E_CHARACTER_RACES.RACE_PANDAREN_HORDE,
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= E_CHARACTER_RACES.RACE_VULPERA_HORDE,
		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= E_CHARACTER_RACES.RACE_VULPERA_HORDE,
	},
	[FACTION_HORDE] = {
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE,
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE,
	}
}

local PAID_FACTION_SERVICE_OVERRIDE_RACES = {
	[FACTION_ALLIANCE] = {
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE,
		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE,
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE,
	},
	[FACTION_HORDE] = {
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= E_CHARACTER_RACES.RACE_PANDAREN_HORDE,
		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= E_CHARACTER_RACES.RACE_PANDAREN_HORDE,
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= E_CHARACTER_RACES.RACE_PANDAREN_HORDE,
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= E_CHARACTER_RACES.RACE_VULPERA_HORDE,
		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= E_CHARACTER_RACES.RACE_VULPERA_HORDE,
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= E_CHARACTER_RACES.RACE_VULPERA_HORDE,
	}
}

local PAID_SERVICE_ORIGINAL_FACTION = {
	[FACTION_HORDE]		= PLAYER_FACTION_GROUP.Horde,
	[FACTION_ALLIANCE]	= PLAYER_FACTION_GROUP.Alliance,
}

local PAID_SERVICE_ORIGINAL_RACE = {
	[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]		= E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL,
	[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]			= E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL,
	[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]		= E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
	[E_CHARACTER_RACES.RACE_VULPERA_HORDE]			= E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
}

local CAMERA_ZOOM_LEVEL_AMOUNT = 80

local TOOLTIP_MAX_CLASS_ABLILITIES = 5
local TOOLTIP_MAX_RACE_ABLILITIES_PASSIVE = 4
local TOOLTIP_MAX_RACE_ABLILITIES_ACTIVE = 3
local TOOLTIPS_EXPANDED = false

CharacterCreateMixin = CreateFromMixins(CharacterModelMixin)

enum:E_PAID_SERVICE {
	"CUSTOMIZATION",
	"CHANGE_RACE",
	"CHANGE_FACTION"
}

enum:E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE {
	"ACTIVE",
	"INACTIVE"
}

local pullButtonReset = function(framePool, frame)
	FramePool_HideAndClearAnchors(framePool, frame)
	frame:Enable()
end

function CharacterCreateMixin:OnLoad()
	self:RegisterHookListener()

	self.raceButtonPerLine = 5

	self.clientRaceData = {}
	self.clientClassData = {}

	self.allianceRaceButtonPool = CreateFramePool("CheckButton", self.AllianceRacesFrame, "CharacterCreateRaceButtonTemplate", pullButtonReset)
	self.hordeRaceButtonPool 	= CreateFramePool("CheckButton", self.HordeRacesFrame, "CharacterCreateRaceButtonTemplate", pullButtonReset)
	self.neutralRaceButtonPool 	= CreateFramePool("CheckButton", self.NeutralRacesFrame, "CharacterCreateRaceButtonTemplate", pullButtonReset)

	self.classButtonPool 		= CreateFramePool("CheckButton", self.ClassesFrame, "CharacterCreateClassButtonTemplate", pullButtonReset)

	self.genderButtonPool 		= CreateFramePool("CheckButton", self.GenderFrame, "CharacterCreateGenderButtonTemplate", pullButtonReset)

	self.NavigationFrame.CreateNameEditBox:SetPoint("BOTTOM", self.GenderFrame.CustomizationButton, "TOP", 0, 5)
end

function CharacterCreateMixin:OnShow()
	C_CharacterCreation.SetInCharacterCreate(true)

	if PAID_SERVICE_TYPE then
		C_CharacterCreation.CustomizeExistingCharacter(PAID_SERVICE_CHARACTER_ID)
		self.NavigationFrame.CreateNameEditBox:SetText(PaidChange_GetName() or "")
		self.NavigationFrame.CreateButton:SetText(CHARACTER_CREATE_ACCEPT)
	else
		C_CharacterCreation.ResetCharCustomize()
		self.NavigationFrame.CreateNameEditBox:SetText("")
		self.NavigationFrame.CreateButton:SetText(CHARACTER_CREATE)
	end

	self:UpdateBackground()

	if PAID_SERVICE_TYPE == PAID_FACTION_CHANGE and select(3, C_CharacterCreation.PaidChange_GetCurrentFaction()) == PLAYER_FACTION_GROUP.Neutral then
		self.NavigationFrame.CreateNameEditBox:SetAutoFocus(false)
		self.NavigationFrame.CreateNameEditBox:ClearFocus()
		self.GenderFrame.CustomizationButton:Hide()
		self.AllianceRacesFrame:Hide()
		self.HordeRacesFrame:Hide()

		PlaySound(SOUNDKIT.GS_TITLE_OPTIONS)
		self:RegisterCustomEvent("GLUE_CHARACTER_CREATE_FORCE_RACE_CHANGE")
		GlueDialog:ShowDialog("FORCE_CHOOSE_FACTION")

		return
	end

	self:CreateUpdateButtons()
	self.skipCustomizationConfirmation = false

	C_CharacterCreation.EnableMouseWheel(true)
end

function CharacterCreateMixin:OnHide()
	C_CharacterCreation.SetInCharacterCreate(false)
	PAID_SERVICE_TYPE = nil
	self.CustomizationFrame:Hide()
	self:ResetSelectRaceAndClassAnim()
	C_CharacterCreation.EnableMouseWheel(false)
end

function CharacterCreateMixin:OnEvent(event, ...)
	if event == "GLUE_CHARACTER_CREATE_FORCE_RACE_CHANGE" then
		self.NavigationFrame.CreateNameEditBox:SetAutoFocus(true)
		self.NavigationFrame.CreateNameEditBox:SetFocus()
		self.NavigationFrame.CreateNameEditBox:HighlightText(0, 0)
		self.GenderFrame.CustomizationButton:Show()
		self.AllianceRacesFrame:Show()
		self.HordeRacesFrame:Show()

		self:CreateUpdateButtons()
	end
end

local RESET_ROTATION_TIME = 0.5
function CharacterCreateMixin:OnUpdate( elapsed )
	if self.rotationStartX then
		local x = GetCursorPosition()
		local diff = (x - self.rotationStartX) * 0.6
		self.rotationStartX = x
		C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetCharacterCreateFacing() + diff)
	elseif self.rotationResetStep then
		self.elapsed = self.elapsed + elapsed
		if self.elapsed < self.rotationResetTime then
			C_CharacterCreation.SetCharacterCreateFacing(self.rotationResetCur + self.rotationResetStep * self.elapsed)
		else
			self.elapsed = 0
			self.rotationResetTime = nil
			self.rotationResetCur = nil
			self.rotationResetStep = nil
			C_CharacterCreation.SetCharacterCreateFacing(C_CharacterCreation.GetDefaultCharacterCreateFacing())
		end
	end
end

function CharacterCreateMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		if self.CustomizationFrame:IsShown() and not (self.CustomizationFrame:IsAnimPlaying() and self.CustomizationFrame.isRevers) then
			self.CustomizationFrame:PlayToggleAnim()
			PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK)
		else
			self:BackToCharacterSelect()
		end
	elseif key == "ENTER" then
		self.NavigationFrame.CreateButton:Click()
	elseif key == "PRINTSCREEN" then
		Screenshot()
	end
end

function CharacterCreateMixin:OnMouseUp( button )
	if button == "LeftButton" then
		self.rotationStartX = nil
		self.rotationResetTime = nil
		self.rotationResetCur = nil
		self.rotationResetStep = nil
	elseif button == "RightButton" and not self.rotationStartX then
		local defaultDeg = C_CharacterCreation.GetDefaultCharacterCreateFacing()
		local deg = C_CharacterCreation.GetCharacterCreateFacing()
		if deg ~= defaultDeg then
			local change = (defaultDeg - deg + 540) % 360 - 180
			self.elapsed = 0
			self.rotationResetTime = math.abs(change / 180 * RESET_ROTATION_TIME)
			self.rotationResetCur = deg
			self.rotationResetStep = change / self.rotationResetTime
		end
	end
end

function CharacterCreateMixin:OnMouseDown( button )
	if button == "LeftButton" then
		self.rotationResetX = nil
		self.rotationResetCur = nil
		self.rotationStartX = GetCursorPosition()
	end
end

function CharacterCreateMixin:CreateUpdateButtons()
	self:BuildRaceData()
	self:CreateRaceButtons()
	self:UpdateRaceButtons()

	self:BuildClassData()
	self:CreateClassButtons()
	self:UpdateClassButtons()

	self:CreateGenderButtons()
	self:UpdateGenderButtons()

	self.Overlay.showAnim:Play()
	self:PlaySelectRaceAndClassAnim()
end

function CharacterCreateMixin:CreateGenderButtons()
	self.genderButtonPool:ReleaseAll()

	for _, genderID in ipairs(C_CharacterCreation.GetAvailableGenders()) do
		local button = self.genderButtonPool:Acquire()
		button.index = genderID
		button.Icon:SetAtlas("GLUE-GENDER-"..E_SEX[genderID])
		button:SetPoint(genderID == E_SEX.MALE and "LEFT" or "RIGHT", 0, 0)
		button:Show()
	end
end

function CharacterCreateMixin:BuildClassData()
	self.clientClassData = C_CharacterCreation.GetAvailableClasses()
end

function CharacterCreateMixin:CreateClassButtons()
	self.classButtonPool:ReleaseAll()

	local prevButton

	for _, data in ipairs(self.clientClassData) do
		if not data.disabled then
			local button = self.classButtonPool:Acquire()
			button.index = data.index
			button.Icon:SetAtlas("CIRCLE_CLASS_ICON_"..data.clientFileString)
			if not prevButton then
				button:SetPoint("LEFT", 47, 0)
			else
				button:SetPoint("LEFT", prevButton, "RIGHT", 15, 0)
			end
			button:Show()

			prevButton = button
		end
	end
end

function CharacterCreateMixin:GetClientRaceInfo( raceIndex )
	return self.clientRaceData[raceIndex]
end

function CharacterCreateMixin:BuildRaceData()
	self.clientRaceData = C_CharacterCreation.GetAvailableRaces()
end

function CharacterCreateMixin:CreateRaceButtons()
	self.allianceRaceButtonPool:ReleaseAll()
	self.hordeRaceButtonPool:ReleaseAll()
	self.neutralRaceButtonPool:ReleaseAll()

	local buffer = {}

	for index, data in ipairs(C_CharacterCreation.GetAvailableRacesForCreation()) do
		local button

		local isNeutralFaction = data.factionID == PLAYER_FACTION_GROUP.Neutral or not not PAID_SERVICE_ORIGINAL_RACE[data.raceID]

		local factionID = isNeutralFaction and PLAYER_FACTION_GROUP.Neutral or data.factionID

		if factionID == PLAYER_FACTION_GROUP.Alliance then
			button = self.allianceRaceButtonPool:Acquire()
		elseif factionID == PLAYER_FACTION_GROUP.Horde then
			button = self.hordeRaceButtonPool:Acquire()
		elseif factionID == PLAYER_FACTION_GROUP.Neutral then
			button = self.neutralRaceButtonPool:Acquire()

			if PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_RACE or PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_FACTION then
				local faction = C_CharacterCreation.PaidChange_GetCurrentFaction()

				local overrideRaceID
				local overrideFactionID

				if PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_FACTION then
					overrideRaceID = PAID_RACE_SERVICE_OVERRIDE_RACES[faction] and PAID_RACE_SERVICE_OVERRIDE_RACES[faction][data.raceID]
					overrideFactionID = PAID_RACE_SERVICE_OVERRIDE_FACTIONS[faction]
				else
					overrideRaceID = PAID_FACTION_SERVICE_OVERRIDE_RACES[faction] and PAID_FACTION_SERVICE_OVERRIDE_RACES[faction][data.raceID]
					overrideFactionID = PAID_SERVICE_ORIGINAL_FACTION[faction]
				end

				if overrideRaceID and overrideFactionID then
					data.raceID = overrideRaceID
					data.factionID = overrideFactionID
				end
			else
				local raceID = PAID_SERVICE_ORIGINAL_RACE[data.raceID]
				if raceID then
					data.raceID = raceID
					data.factionID = PLAYER_FACTION_GROUP.Neutral
				end
			end
		end

		if not buffer[factionID] then
			buffer[factionID] = {}
		end

		table.insert(buffer[factionID], button)

		local buttonCount = #buffer[factionID]

		if mod(buttonCount - 1, self.raceButtonPerLine) == 0 then
			if buttonCount == 1 then
				if factionID == PLAYER_FACTION_GROUP.Alliance then
					button:SetPoint("TOPLEFT", 40, -40)
				elseif factionID == PLAYER_FACTION_GROUP.Horde then
					button:SetPoint("TOPRIGHT", -40, -40)
				else
					button:SetPoint("LEFT", 0, 0)
				end
			else
				if factionID == PLAYER_FACTION_GROUP.Alliance then
					button:SetPoint("LEFT", buffer[factionID][buttonCount - self.raceButtonPerLine], "RIGHT", 26, -30)
				elseif factionID == PLAYER_FACTION_GROUP.Horde then
					button:SetPoint("RIGHT", buffer[factionID][buttonCount - self.raceButtonPerLine], "LEFT", -26, -30)
				end
			end
		else
			if factionID == PLAYER_FACTION_GROUP.Neutral then
				button:SetPoint("LEFT", buffer[factionID][buttonCount - 1], "RIGHT", 40, 0)
			else
				button:SetPoint("TOP", buffer[factionID][buttonCount - 1], "BOTTOM", 0, -30)
			end
		end

		button.data = data

		if C_CharacterCreation.IsAlliedRace(data.raceID) then
			button.alliedRace = true
			button.AlliedBorder1:Show()
			button.AlliedBorder1.Anim.Rotation:SetDegrees((index % 2 == 0) and -360 or 360)
			button.AlliedBorder1.Anim:Play()
			button.AlliedBorder2:Show()
			button.AlliedBorder2.Anim:Play()
			button.AlliedBorder2.Pulse:Play()
		else
			button.alliedRace = nil
			button.AlliedBorder1.Anim:Stop()
			button.AlliedBorder1:Hide()
			button.AlliedBorder2.Anim:Stop()
			button.AlliedBorder2.Pulse:Stop()
			button.AlliedBorder2:Hide()
		end

		button:Show()

		if IsInterfaceDevClient() then
			button.ArtFrame.RaceID:SetText(data.raceID)
		end
	end
end

local function updateButtonMacro( frame, onlyDeselected, ignoredButton )
	if onlyDeselected then
		if frame ~= ignoredButton then
			frame:SetChecked(false)
			frame:UpdateChecked()
		end
	else
		frame:UpdateButton()
	end
end

function CharacterCreateMixin:UpdateRaceButtons( onlyDeselected, ignoredButton )
	for frame in self.allianceRaceButtonPool:EnumerateActive() do
		updateButtonMacro(frame, onlyDeselected, ignoredButton)
	end
	for frame in self.hordeRaceButtonPool:EnumerateActive() do
		updateButtonMacro(frame, onlyDeselected, ignoredButton)
	end
	for frame in self.neutralRaceButtonPool:EnumerateActive() do
		updateButtonMacro(frame, onlyDeselected, ignoredButton)
	end
end

function CharacterCreateMixin:UpdateClassButtons( onlyDeselected, ignoredButton )
	for frame in self.classButtonPool:EnumerateActive() do
		updateButtonMacro(frame, onlyDeselected, ignoredButton)
	end
end

function CharacterCreateMixin:UpdateGenderButtons( onlyDeselected, ignoredButton )
	for frame in self.genderButtonPool:EnumerateActive() do
		updateButtonMacro(frame, onlyDeselected, ignoredButton)
	end
end

function CharacterCreateMixin:PlaySelectRaceAndClassAnim( isReverce, callback )
	self.AllianceRacesFrame:PlayAnim(isReverce, callback)
	self.HordeRacesFrame:PlayAnim(isReverce)
	self.NeutralRacesFrame:PlayAnim(isReverce)
	self.ClassesFrame:PlayAnim(isReverce)
	self.GenderFrame:PlayAnim(isReverce)
end

function CharacterCreateMixin:ResetSelectRaceAndClassAnim()
	self.AllianceRacesFrame:Reset()
	self.HordeRacesFrame:Reset()
	self.NeutralRacesFrame:Reset()
	self.ClassesFrame:Reset()
	self.GenderFrame:Reset()
end

function CharacterCreateMixin:BackToCharacterSelect()
	self.BlockingFrame:Show()
	self.Overlay.hideAnim:Play()
	PlaySound("gsCharacterCreationCancel")
	self:PlaySelectRaceAndClassAnim(true, function ()
		self.BlockingFrame:Hide()
		SetGlueScreen("charselect")
	end)
end

function CharacterCreateMixin:UpdateBackground()
	CharacterModelMixin.SetBackground(self, C_CharacterCreation.GetSelectedModelName())
end

CharacterCreateRaceButtonMixin = {}

function CharacterCreateRaceButtonMixin:OnLoad()
	self.mainFrame = CharacterCreate

	self.Border:SetAtlas("UI-Frame-jailerstower-Portrait")
	self.FactionBorder:SetAtlas("UI-Frame-jailerstower-Portrait-border")
	self.ArtFrame.CheckedTexture:SetAtlas("charactercreate-ring-select")
	self.ArtFrame.HighlightTexture:SetAtlas("UI-Frame-jailerstower-Portrait-border")
	self.ArtFrame.Border2:SetAtlas("UI-Frame-jailerstower-Portrait")
	self.ArtFrame.Border3:SetAtlas("UI-Frame-jailerstower-Portrait")

	self.AlliedBorder1:SetAtlas("services-ring-large-glowpulse")
	self.AlliedBorder2:SetAtlas("Roulette-item-jackpot-light-center")
end

function CharacterCreateRaceButtonMixin:UpdateChecked()
	self.ArtFrame.CheckedTexture:SetShown(self:GetChecked())
end

function CharacterCreateRaceButtonMixin:OnMouseDown(button)
	if self:IsEnabled() == 1 then
		self.Icon:SetPoint("CENTER", 1, -1)
		self.Border:SetPoint("CENTER", 1, -1)
		self.FactionBorder:SetPoint("CENTER", 1, -1)
		self.ArtFrame:SetPoint("TOPLEFT", 1, -1)
		self.ArtFrame:SetPoint("BOTTOMRIGHT", 1, -1)
	end
end

function CharacterCreateRaceButtonMixin:OnMouseUp(button)
	self.Icon:SetPoint("CENTER", 0, 0)
	self.Border:SetPoint("CENTER", 0, 0)
	self.FactionBorder:SetPoint("CENTER", 0, 0)
	self.ArtFrame:SetPoint("TOPLEFT", 0, 0)
	self.ArtFrame:SetPoint("BOTTOMRIGHT", 0, 0)

	if button == "LeftButton" then
		if self:IsEnabled() == 1 or self.alliedRaceLocked then
			PlaySound("gsCharacterCreationClass")

			local isSet = C_CharacterCreation.SetSelectedRace(self.index)
			if not isSet then return end

			self:SetChecked(true)

			self.mainFrame:UpdateRaceButtons( true, self )
			self:UpdateChecked()

			self.mainFrame:UpdateClassButtons()
			self.mainFrame:UpdateBackground()
			self.mainFrame.CustomizationFrame:UpdateCustomizationButtonFrame(true)
			self.mainFrame.skipCustomizationConfirmation = self.mainFrame.CustomizationFrame:IsShown()

			local enabled = self:IsEnabled() == 1
			self.mainFrame.NavigationFrame.CreateButton:SetEnabled(enabled)
			self.mainFrame.NavigationFrame.CreateNameEditBox:SetShown(enabled)
			self.mainFrame.NavigationFrame.RandomNameButton:SetShown(enabled)
		end
	elseif button == "RightButton" and self:IsMouseOver() and self.tooltip then
		TOOLTIPS_EXPANDED = not TOOLTIPS_EXPANDED
		CharCreateRaceButtonTemplate_OnEnter(self)
	end
end

function CharacterCreateRaceButtonMixin:OnEnter()
	for i = 2, 3 do
		self.ArtFrame["Border"..i].HideAnim:Stop()
		self.ArtFrame["Border"..i]:Show()

		self.ArtFrame["Border"..i].Anim:Play()
		self.ArtFrame["Border"..i].ShowAnim:Play()
	end

	self.ArtFrame.HighlightTexture:Show()

	if self:IsEnabled() == 1 then
		self.tooltip = true
	elseif PAID_SERVICE_TYPE == E_PAID_SERVICE.CUSTOMIZATION then
		self.tooltip = nil
	elseif C_CharacterCreation.IsAlliedRace(self.index) then
		if PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_FACTION or PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_RACE then
			local currentFaction = C_CharacterCreation.PaidChange_GetCurrentFaction()
			local factionID = S_CHARACTER_RACES_INFO[self.index].factionID

			if PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_FACTION then
				self.tooltip = factionID == PAID_RACE_SERVICE_OVERRIDE_FACTIONS[currentFaction]
			else
				self.tooltip = factionID == PAID_SERVICE_ORIGINAL_FACTION[currentFaction]
			end
		else
			self.tooltip = true
		end
	end

	if self.tooltip then
		CharCreateRaceButtonTemplate_OnEnter(self)
	end
end

function CharacterCreateRaceButtonMixin:OnLeave()
	for i = 2, 3 do
		self.ArtFrame["Border"..i].HideAnim:Play()
		self.ArtFrame["Border"..i].ShowAnim:Stop()
	end

	self.ArtFrame.HighlightTexture:Hide()

	if self.tooltip then
		self.tooltip = nil
		CharCreateRaceButtonTemplate_OnLeave(self)
	end
end

function CharacterCreateRaceButtonMixin:OnDisable()
	self.FactionBorder:SetDesaturated(true)
	self.ArtFrame.HighlightTexture:SetDesaturated(true)
	self.ArtFrame.Border2:SetDesaturated(true)
	self.ArtFrame.Border3:SetDesaturated(true)
	self.Icon:SetDesaturated(true)
	self.alliedRaceDisabled = C_CharacterCreation.IsAlliedRace(self.index)
end

function CharacterCreateRaceButtonMixin:OnEnable()
	self.FactionBorder:SetDesaturated(false)
	self.ArtFrame.HighlightTexture:SetDesaturated(false)
	self.ArtFrame.Border2:SetDesaturated(false)
	self.ArtFrame.Border3:SetDesaturated(false)
	self.Icon:SetDesaturated(false)
	self.alliedRaceDisabled = nil
end

function CharacterCreateRaceButtonMixin:UpdateButton()
	local clientData = self.mainFrame:GetClientRaceInfo(self.data.raceID)
	local factionColor = PLAYER_FACTION_COLORS[self.data.factionID]

	self.Border:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.FactionBorder:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.ArtFrame.Border2:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)
	self.ArtFrame.Border3:SetVertexColor(factionColor.r, factionColor.g, factionColor.b)

	if C_CharacterCreation.IsPandarenRace(clientData.index) or C_CharacterCreation.IsVulperaRace(clientData.index) then
		self.data.name = _G[string.upper(clientData.clientFileString)]
	else
		self.data.name = clientData.name
	end

	self.data.clientFileString = clientData.clientFileString

	local atlas = string.format("RACE_ICON_%s_%s_%s", string.upper(clientData.clientFileString), E_SEX[C_CharacterCreation.GetSelectedSex()], string.upper(PLAYER_FACTION_GROUP[self.data.factionID]))

	if not S_ATLAS_STORAGE[atlas] then
		atlas = "RACE_ICON_HUMAN_MALE_HORDE"
	end

	self.Icon:SetAtlas(atlas)

	self.index = clientData.index

	local allow = false
	local alliedRaceLocked

	if PAID_SERVICE_TYPE then
		local faction = C_CharacterCreation.PaidChange_GetCurrentFaction()

		if C_CharacterCreation.IsNeutralRace(self.index) then
			allow = false
		elseif PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_RACE then
			allow = (faction == C_CharacterCreation.GetFactionForRace(self.index) or self.index == C_CharacterCreation.PaidChange_GetCurrentRaceIndex())
		elseif PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_FACTION then
			allow = (faction ~= C_CharacterCreation.GetFactionForRace(self.index) or self.index == C_CharacterCreation.PaidChange_GetCurrentRaceIndex())
		elseif PAID_SERVICE_TYPE == E_PAID_SERVICE.CUSTOMIZATION then
			allow = self.index == C_CharacterCreation.PaidChange_GetCurrentRaceIndex()
		end
	else
		allow = true
	end

	if allow and C_CharacterCreation.IsAlliedRace(self.index) and not C_CharacterCreation.IsAlliedRacesUnlocked(self.index) then
		allow = false
		alliedRaceLocked = true
	end

	self.alliedRaceGMAllowed = not C_CharacterCreation.IsAlliedRacesUnlockedRaw(self.index)
	self.alliedRaceLocked = alliedRaceLocked
	self:SetEnabled(allow)

	self:SetChecked(C_CharacterCreation.GetSelectedRace() == self.index)
	self:UpdateChecked()
end

CharacterCreateClassButtonMixin = {}

function CharacterCreateClassButtonMixin:OnLoad()
	self.mainFrame = CharacterCreate

	self.Border:SetAtlas("charactercreate-ring-metaldark")
	self.HighlightTexture:SetAtlas("charactercreate-ring-metallight")
	self.CheckedTexture:SetAtlas("charactercreate-ring-select")
end

function CharacterCreateClassButtonMixin:OnEnter()
	self.HighlightTexture:Show()

	self.tooltip = self:IsEnabled() == 1
	if self.tooltip then
		CharCreateClassButtonTemplate_OnEnter(self)
	end
end

function CharacterCreateClassButtonMixin:OnLeave()
	self.HighlightTexture:Hide()

	if self.tooltip then
		self.tooltip = nil
		CharCreateClassButtonTemplate_OnLeave(self)
	end
end

function CharacterCreateClassButtonMixin:UpdateChecked()
	self.CheckedTexture:SetShown(self:GetChecked())
end

function CharacterCreateClassButtonMixin:OnDisable()
	self.Icon:SetDesaturated(true)
	self.Border:SetDesaturated(true)
	self.HighlightTexture:SetDesaturated(true)
	self.CheckedTexture:SetDesaturated(true)
end

function CharacterCreateClassButtonMixin:OnEnable()
	self.Icon:SetDesaturated(false)
	self.Border:SetDesaturated(false)
	self.HighlightTexture:SetDesaturated(false)
	self.CheckedTexture:SetDesaturated(false)
end

function CharacterCreateClassButtonMixin:OnMouseDown(button)
	if self:IsEnabled() == 1 then
		self.Icon:SetPoint("CENTER", 1, -1)
		self.Border:SetPoint("CENTER", 1, -1)
		self.HighlightTexture:SetPoint("CENTER", 1, -1)
		self.CheckedTexture:SetPoint("CENTER", 1, -1)
	end
end

function CharacterCreateClassButtonMixin:OnMouseUp(button)
	self.Icon:SetPoint("CENTER", 0, 0)
	self.Border:SetPoint("CENTER", 0, 0)
	self.HighlightTexture:SetPoint("CENTER", 0, 0)
	self.CheckedTexture:SetPoint("CENTER", 0, 0)

	if button == "LeftButton" then
		if self:IsEnabled() == 1 then
			PlaySound("gsCharacterCreationClass")

			local isSet = C_CharacterCreation.SetSelectedClass(self.index)
			if not isSet then return end

			self:SetChecked(true)

			self.mainFrame:UpdateClassButtons( true, self )
			self:UpdateChecked()

			self.mainFrame:UpdateBackground()
			self.mainFrame.CustomizationFrame:UpdateCustomizationButtonFrame(true)
			self.mainFrame.skipCustomizationConfirmation = self.mainFrame.CustomizationFrame:IsShown()
		end
	elseif button == "RightButton" and self:IsMouseOver() and self.tooltip then
		TOOLTIPS_EXPANDED = not TOOLTIPS_EXPANDED
		CharCreateClassButtonTemplate_OnEnter(self)
	end
end

function CharacterCreateClassButtonMixin:UpdateButton()
	local _, _, classID = C_CharacterCreation.GetSelectedClass()

	local clientClassData = self.index and self.mainFrame.clientClassData[self.index]
	if clientClassData then
		self.name = clientClassData.name
		self.clientFileString = clientClassData.clientFileString
	end

	if PAID_SERVICE_TYPE then
		self:SetEnabled(self.index == classID)
	else
		self:SetEnabled(C_CharacterCreation.IsRaceClassValid(C_CharacterCreation.GetSelectedRace(), self.index))
	end


	self:SetChecked(classID == self.index)
	self:UpdateChecked()
end

CharacterCreateGenderButtonMixin = {}

function CharacterCreateGenderButtonMixin:OnLoad()
	self.mainFrame = CharacterCreate

	self.Border:SetAtlas("charactercreate-ring-metaldark")
	self.HighlightTexture:SetAtlas("charactercreate-ring-metallight")
	self.CheckedTexture:SetAtlas("charactercreate-ring-select")
end

function CharacterCreateGenderButtonMixin:OnMouseDown(button)
	if self:IsEnabled() == 1 then
		self.Icon:SetPoint("CENTER", 1, -1)
		self.Border:SetPoint("CENTER", 1, -1)
		self.HighlightTexture:SetPoint("CENTER", 1, -1)
		self.CheckedTexture:SetPoint("CENTER", 1, -1)
	end
end

function CharacterCreateGenderButtonMixin:OnMouseUp(button)
	self.Icon:SetPoint("CENTER", 0, 0)
	self.Border:SetPoint("CENTER", 0, 0)
	self.HighlightTexture:SetPoint("CENTER", 0, 0)
	self.CheckedTexture:SetPoint("CENTER", 0, 0)

	if button == "LeftButton" then
		PlaySound("gsCharacterCreationClass")

		local isSet = C_CharacterCreation.SetSelectedSex(self.index)
		if not isSet then return end

		self:SetChecked(true)

		self.mainFrame:UpdateGenderButtons( true, self )
		self:UpdateChecked()

		self.mainFrame:BuildRaceData()
		self.mainFrame:UpdateRaceButtons()
		self.mainFrame:BuildClassData()
		self.mainFrame:UpdateClassButtons()

		self.mainFrame.CustomizationFrame:UpdateCustomizationButtonFrame(true)
		self.mainFrame.skipCustomizationConfirmation = self.mainFrame.CustomizationFrame:IsShown()

		C_CharacterCreation.ZoomCamera(0, nil, true)
	end
end

function CharacterCreateGenderButtonMixin:OnEnter()
	self.HighlightTexture:Show()

	GlueTooltip_SetOwner(self, GlueTooltip, 0, 0, "BOTTOM", "TOP")
	GlueTooltip_SetText(_G[E_SEX[self.index]], GlueTooltip, 1, 1, 1)
end

function CharacterCreateGenderButtonMixin:OnLeave()
	self.HighlightTexture:Hide()

	GlueTooltip:Hide()
end

function CharacterCreateGenderButtonMixin:UpdateChecked()
	self.CheckedTexture:SetShown(self:GetChecked())
end

function CharacterCreateGenderButtonMixin:UpdateButton()
	self:SetChecked(C_CharacterCreation.GetSelectedSex() == self.index)
	self:UpdateChecked()
end

CharacterCreateAllianceRacesFrameMixin = {}

function CharacterCreateAllianceRacesFrameMixin:Init()
	self.startPoint = -400
	self.endPoint = 10
	self.duration = 0.500
end

function CharacterCreateAllianceRacesFrameMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("TOPLEFT", easing, -70)
	else
		self:ClearAndSetPoint("TOPLEFT", self.isRevers and self.startPoint or self.endPoint, -70)
	end
end

CharacterCreateHordeRacesFrameMixin = {}

function CharacterCreateHordeRacesFrameMixin:Init()
	self.startPoint = 400
	self.endPoint = -10
	self.duration = 0.500
end

function CharacterCreateHordeRacesFrameMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("TOPRIGHT", easing, -70)
	else
		self:ClearAndSetPoint("TOPRIGHT", self.isRevers and self.startPoint or self.endPoint, -70)
	end
end

CharacterCreateNeutralRacesFrameMixin = {}

function CharacterCreateNeutralRacesFrameMixin:Init()
	self.startPoint = 100
	self.endPoint = -30
	self.duration = 0.500
end

function CharacterCreateNeutralRacesFrameMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("TOP", 0, easing)
	else
		self:ClearAndSetPoint("TOP", 0, self.isRevers and self.startPoint or self.endPoint)
	end
end

CharacterCreateClassesFrameMixin = {}

function CharacterCreateClassesFrameMixin:Init()
	self.startPoint = -80
	self.endPoint = 10
	self.duration = 0.500
end

function CharacterCreateClassesFrameMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("BOTTOM", 0, easing)
	else
		self:ClearAndSetPoint("BOTTOM", 0, 10)
	end
end

CharacterCreateGenderFrameMixin = {}

function CharacterCreateGenderFrameMixin:Init()
	self.startPoint = 20
	self.endPoint = 70
	self.duration = 0.500
end

function CharacterCreateGenderFrameMixin:SetPosition( easing )
	if easing then
		self:ClearAndSetPoint("BOTTOM", 0, easing)
	else
		self:ClearAndSetPoint("BOTTOM", 0, self.isRevers and self.startPoint or self.endPoint)
	end
end

CharacterCreateInteractiveButtonAlphaAnimMixin = {}

function CharacterCreateInteractiveButtonAlphaAnimMixin:InitAlpha()
	self.initMinAlpha 	= 0.4
	self.initMaxAlpha 	= 1

	self.elapsed 		= 0
	self.animationTime 	= 0.4

	self.startAlpha 	= nil
	self.endAlpha 		= nil
end

function CharacterCreateInteractiveButtonAlphaAnimMixin:InFade()
	self.startAlpha 	= self.initMinAlpha
	self.endAlpha 		= self.initMaxAlpha
end

function CharacterCreateInteractiveButtonAlphaAnimMixin:OutFade()
	self.startAlpha 	= self.initMaxAlpha
	self.endAlpha 		= self.initMinAlpha
end

function CharacterCreateInteractiveButtonAlphaAnimMixin:UpdateAlpha( elapsed )
	if not self.startAlpha or not self.endAlpha then
		return
	end

	self.elapsed = self.elapsed + elapsed

	local easing 	= C_outCirc(self.elapsed, self.startAlpha, self.endAlpha, self.animationTime)

	self:SetAlpha(easing)

	if self.elapsed > self.animationTime then
		self:SetAlpha(self.endAlpha)

		self.elapsed 		= 0
		self.animationState = nil

		self.startAlpha 	= nil
		self.endAlpha 		= nil
	end
end

CharacterCreateCustomizationButtonMixin = {}

function CharacterCreateCustomizationButtonMixin:OnLoad()
	self.parentFrame = self:GetParent():GetParent()
end

function CharacterCreateCustomizationButtonMixin:OnClick()
	self.parentFrame.CustomizationFrame:PlayToggleAnim()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK)
end

CharacterCreateCustomizationFrameMixin = {}

function CharacterCreateCustomizationFrameMixin:OnLoad()
	self.parentFrame = self:GetParent()
	self.customizationButtonFramePool = CreateFramePool("Frame", self, "CharacterCreateCustomizationButtonFrameTemplate")

	self.sourceXOffset = 200
	self.startPoint = -200
	self.endPoint = self.sourceXOffset
	self.duration = 0.500
end

function CharacterCreateCustomizationFrameMixin:SetPosition(easing, progress)
	if easing then
		self.parentFrame.CustomizationVignette:SetAlpha(self.isRevers and ((1 - progress) * 0.75) or (progress * 0.75))
		self:SetAlpha(self.isRevers and (1 - progress) or progress)
		self:SetPoint("LEFT", easing, 200)
	else
		self.parentFrame.CustomizationVignette:SetAlpha(self.isRevers and 0 or 0.75)
		self:SetAlpha(self.isRevers and 0 or 1)
		self:SetPoint("LEFT", self.isRevers and self.startPoint or self.sourceXOffset, 200)
	end
end

function CharacterCreateCustomizationFrameMixin:UpdateCustomizationButtonFrame(selectedChanged)
	if selectedChanged and not self:IsShown() == 1 then return end

	self.customizationButtonFramePool:ReleaseAll()

	local prevFrame

	for _, style in ipairs(C_CharacterCreation.GetAvailableCustomizations()) do
		local frame = self.customizationButtonFramePool:Acquire()

		if not prevFrame then
			frame:SetPoint("LEFT", 0, 200)
		else
			frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -20)
		end

		prevFrame = frame

		frame.CustomizationIndex = style.orderIndex
		frame.CustomizationName:SetText(style.name)
		frame:Show()
	end

	self.RandomizeCustomizationButton:ClearAndSetPoint("TOP", prevFrame, "BOTTOM", 0, -40)
end

local function CustomizationButtonChangeState(framePool, state)
	for frame in framePool:EnumerateActive() do
		if state == E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.INACTIVE then
			if frame:IsEnabled() == 1 then
				frame.animDisable = true
			end

			frame:Disable()
			frame:OutFade()
		elseif state == E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE then
			frame:SetEnabled(frame.animDisable)
			frame.animDisable = false

			frame:InFade()
		end
	end
end

function CharacterCreateCustomizationFrameMixin:PlayToggleAnim()
	self.show = not self.show

	if self.show then
		self:Show()
		self.sourceXOffset = not IsWideScreen() and 100 or 200
		self.endPoint = self.sourceXOffset

		self:UpdateCustomizationButtonFrame()
		self:AnimOnShow()
	else
		self:AnimOnHide()
	end
end

function CharacterCreateCustomizationFrameMixin:AnimOnShow()
	self:PlayAnim(false)

	CustomizationButtonChangeState(self.parentFrame.classButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.INACTIVE)
	CustomizationButtonChangeState(self.parentFrame.allianceRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.INACTIVE)
	CustomizationButtonChangeState(self.parentFrame.hordeRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.INACTIVE)
	CustomizationButtonChangeState(self.parentFrame.neutralRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.INACTIVE)

	self.parentFrame:PlaySelectRaceAndClassAnim(true, function()
		self.parentFrame.AllianceRacesFrame:Hide()
		self.parentFrame.HordeRacesFrame:Hide()
		self.parentFrame.NeutralRacesFrame:Hide()
		self.parentFrame.ClassesFrame:Hide()
	end)

	self.parentFrame.GenderFrame.CustomizationButton:SetText(CHARACTER_CREATE_RACE_LABEL)

	C_CharacterCreation.ZoomCamera(CAMERA_ZOOM_LEVEL_AMOUNT - C_CharacterCreation.GetCurrentCameraZoom(), nil, true)
end

function CharacterCreateCustomizationFrameMixin:AnimOnHide()
	self:PlayAnim(true, function()
		self:Hide()
	end)

	self.parentFrame:PlaySelectRaceAndClassAnim(false, function()
		self.parentFrame.AllianceRacesFrame:Show()
		self.parentFrame.HordeRacesFrame:Show()
		self.parentFrame.NeutralRacesFrame:Show()
		self.parentFrame.ClassesFrame:Show()
	end)

	CustomizationButtonChangeState(self.parentFrame.classButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
	CustomizationButtonChangeState(self.parentFrame.allianceRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
	CustomizationButtonChangeState(self.parentFrame.hordeRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
	CustomizationButtonChangeState(self.parentFrame.neutralRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)

	self.parentFrame.GenderFrame.CustomizationButton:SetText(CHARACTER_CREATE_CUSTOMIZATION_LABEL)

	C_CharacterCreation.ZoomCamera(C_CharacterCreation.GetMaxCameraZoom() * -1, nil, true)
end

function CharacterCreateCustomizationFrameMixin:OnShow()
	self.parentFrame.skipCustomizationConfirmation = true
end

function CharacterCreateCustomizationFrameMixin:OnHide()
	self:Reset()

	if self.show then
		self.show = false

		self:SetPoint("LEFT", self.startPoint, 200)
		self:SetAlpha(0)
		self.parentFrame.CustomizationVignette:SetAlpha(0)

		CustomizationButtonChangeState(self.parentFrame.classButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
		CustomizationButtonChangeState(self.parentFrame.allianceRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
		CustomizationButtonChangeState(self.parentFrame.hordeRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
		CustomizationButtonChangeState(self.parentFrame.neutralRaceButtonPool, E_CHARACTER_CREATE_CUSTOMIZATION_BUTTON_STATE.ACTIVE)
	end
end

CharacterCreateCustomizationButtonFrameTemplateMixin = {}

function CharacterCreateCustomizationButtonFrameTemplateMixin:OnLoad()
	self.Background:SetAtlas("Glue-Shadow-Button-Normal")
end

CharacterCreateNavigationFrameMixin = {}

function CharacterCreateNavigationFrameMixin:OnLoad()
	self:RegisterHookListener()

	self.sourceYOffset = 0
end

function CharacterCreateNavigationFrameMixin:FRAMES_LOADED()
	self.sourceYOffset = not IsWideScreen() and 58 or 0
	self.endPoint = self.sourceYOffset

	self:SetPoint("BOTTOMLEFT", 0, self.sourceYOffset)
	self:SetPoint("BOTTOMRIGHT", 0, 0)
end

CharacterCreateCircleShadowButtonTemplateMixin = {}

function CharacterCreateCircleShadowButtonTemplateMixin:OnLoad()
	self.normalTextureH = self:GetAttribute("normalTextureSizeH")
	self.normalTextureW = self:GetAttribute("normalTextureSizeW")

	self.PushedTexture:SetSize(self.normalTextureH, self.normalTextureW)
end

function CharCreateRaceButtonTemplate_OnEnter(self)
	if not self.data then return end

	local factionID = self.data.factionID
	if not factionID or not PLAYER_FACTION_GROUP[factionID] then
		error(string.format("CharCreateRaceButtonTemplate_OnEnter: Unknown faction (%i, %i, %i)", self.index, factionID or -1, PAID_SERVICE_TYPE or -1), 1)
	end

	local factionColor = PLAYER_FACTION_COLORS[factionID] or CreateColor(1, 1, 1)
	local raceFileString = string.upper(self.data.clientFileString)

	local tooltip = GlueRaceTooltip
	local alliedRaceText

	if self.alliedRace then
		if self.alliedRaceDisabled or self.alliedRaceGMAllowed then
			alliedRaceText = _G[string.format("ALLIED_RACE_DISABLE_REASON_%s", raceFileString)]
		else
			alliedRaceText = _G[string.format("ALLIED_RACE_UNLOCKED_%s", raceFileString)] or string.format(_G["ALLIED_RACE_UNLOCKED"], self.data.name)
		end
	end

	tooltip:Hide()
	tooltip:SetBackdropBorderColor(factionColor.r, factionColor.g, factionColor.b)

	local tooltipHeight = 10

	tooltip.Header:SetText(self.data.name)
	tooltip.Description:SetText(_G[string.format("CHARACTER_CREATE_INFO_RACE_%s_DESC", raceFileString)])

	tooltip.Header:SetWidth(tooltip:GetWidth() - 20)
	tooltip:SetWidth(math.max(tooltip:GetWidth(), tooltip.Header:GetWidth() + 20))

	tooltip.Description:SetWidth(tooltip:GetWidth() - 20)
	tooltip:SetWidth(math.max(tooltip:GetWidth(), tooltip.Description:GetWidth() + 20))

	tooltipHeight = tooltipHeight + tooltip.Description:GetHeight() + tooltip.Header:GetHeight() + 30

	if TOOLTIPS_EXPANDED then
		local abilities = {}
		local abilitiesPassive = {}

		for abilityIndex = 1, TOOLTIP_MAX_RACE_ABLILITIES_PASSIVE do
			local ability = _G[string.format("CHARACTER_CREATE_INFO_RACE_%s_SPELL_PASSIVE%i_DESC_SHORT", raceFileString, abilityIndex)]
			if ability then
				local icon, desc = string.match(ability, "([^|]*)|(.+)")
				abilitiesPassive[#abilitiesPassive + 1] = {
					icon = string.format("Interface/Icons/%s", icon or "INV_Misc_QuestionMark"),
					description = desc,
				}
			end
		end

		for abilityIndex = 1, TOOLTIP_MAX_RACE_ABLILITIES_ACTIVE do
			local ability = _G[string.format("CHARACTER_CREATE_INFO_RACE_%s_SPELL_ACTIVE%i_DESC_SHORT", raceFileString, abilityIndex)]
			if ability then
				local icon, desc = string.match(ability, "([^|]*)|(.+)")
				abilities[#abilities + 1] = {
					icon = string.format("Interface/Icons/%s", icon or "INV_Misc_QuestionMark"),
					description = desc,
				}
			end
		end

		tooltip.PassiveList:SetupAbilties(abilitiesPassive)
		tooltip.PassiveList:Show()
		tooltip.AbilityList:SetupAbilties(abilities)
		tooltip.AbilityList:Show()

		tooltip.ClickInfo:SetText(RIGHT_CLICK_FOR_LESS)
		tooltip.ClickInfo:SetPoint("TOPLEFT", alliedRaceText and tooltip.Warning or tooltip.AbilityList, "BOTTOMLEFT", 0, -15)

		tooltipHeight = tooltipHeight + tooltip.PassiveList:GetHeight() + 15 + tooltip.AbilityList:GetHeight() + tooltip.ClickInfo:GetHeight() + 20
	else
		tooltip.PassiveList:Hide()
		tooltip.AbilityList:Hide()
		tooltip.ClickInfo:SetText(RIGHT_CLICK_FOR_MORE)
		tooltip.ClickInfo:SetPoint("TOPLEFT", alliedRaceText and tooltip.Warning or tooltip.Description, "BOTTOMLEFT", 0, -15)

		tooltipHeight = tooltipHeight + tooltip.ClickInfo:GetHeight() + 5
	end

	if alliedRaceText then
		tooltip.Warning:SetText(alliedRaceText)
		tooltip.Warning:SetWidth(tooltip:GetWidth() - 20)
		tooltip.Warning:SetPoint("TOPLEFT", tooltip.AbilityList:IsShown() and tooltip.AbilityList or tooltip.Description, "BOTTOMLEFT", 0, -15)
		tooltip.Warning:Show()

		tooltipHeight = tooltipHeight + tooltip.Warning:GetHeight() + 15
	else
		tooltip.Warning:Hide()
	end

	if self:GetParent() == self.mainFrame.AllianceRacesFrame then
		tooltip:ClearAndSetPoint("LEFT", self.mainFrame.AllianceRacesFrame, "RIGHT", 0, 0)
	elseif self:GetParent() == self.mainFrame.HordeRacesFrame then
		tooltip:ClearAndSetPoint("RIGHT", self.mainFrame.HordeRacesFrame, "LEFT", 0, 0)
	else
		tooltip:ClearAndSetPoint("TOP", self, "BOTTOM", 0, -10)
	end

	tooltip:SetHeight(tooltipHeight)
	tooltip:Show()
end

function CharCreateRaceButtonTemplate_OnLeave(self)
	GlueRaceTooltip:Hide()
end

function CharCreateClassButtonTemplate_OnEnter(self)
	if not self.name then return end

	local classTag = self.clientFileString and string.upper(self.clientFileString)
	if not classTag then return end

	local tooltip = GlueClassTooltip
	tooltip:Hide()

	if self.Tcolor then
		tooltip:SetBackdropBorderColor(self.Tcolor[1], self.Tcolor[2], self.Tcolor[3])
	end

	local tooltipHeight = 10

	tooltip.Header:SetText(self.name)
	tooltip.Description:SetText(_G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_DESC", classTag)])
	tooltip.Role:SetText(_G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_ROLE", classTag)])

	tooltip.Header:SetWidth(tooltip:GetWidth() - 20)
	tooltip:SetWidth(math.max(tooltip:GetWidth(), tooltip.Header:GetWidth() + 20))

	tooltip.Description:SetWidth(tooltip:GetWidth() - 20)
	tooltip:SetWidth(math.max(tooltip:GetWidth(), tooltip.Description:GetWidth() + 20))

	tooltip.Role:SetWidth(tooltip:GetWidth() - 20)
	tooltip:SetWidth(math.max(tooltip:GetWidth(), tooltip.Role:GetWidth() + 20))

	tooltipHeight = tooltipHeight + tooltip.Header:GetHeight() + tooltip.Description:GetHeight() + tooltip.Role:GetHeight() + 40

	if TOOLTIPS_EXPANDED then
		local abilities = {}

		for abilityIndex = 1, TOOLTIP_MAX_CLASS_ABLILITIES do
			local ability = _G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_SPELL%i_DESC_SHORT", classTag, abilityIndex)]
			if ability then
				local icon, desc = string.match(ability, "([^|]*)|(.+)")
				abilities[#abilities + 1] = {
					icon = string.format("Interface/Icons/%s", icon or "INV_Misc_QuestionMark"),
					description = desc,
				}
			end
		end

		tooltip.AbilityList:SetupAbilties(abilities)
		tooltip.AbilityList:Show()

		tooltip.ClickInfo:SetText(RIGHT_CLICK_FOR_LESS)
		tooltip.ClickInfo:SetPoint("TOPLEFT", self:IsEnabled() ~= 1 and tooltip.Warning or tooltip.AbilityList, "BOTTOMLEFT", 0, -15)

		tooltipHeight = tooltipHeight + tooltip.AbilityList:GetHeight() + tooltip.ClickInfo:GetHeight() + 20
	else
		tooltip.AbilityList:Hide()
		tooltip.ClickInfo:SetText(RIGHT_CLICK_FOR_MORE)
		tooltip.ClickInfo:SetPoint("TOPLEFT", self:IsEnabled() ~= 1 and tooltip.Warning or tooltip.Role, "BOTTOMLEFT", 0, -15)

		tooltipHeight = tooltipHeight + tooltip.ClickInfo:GetHeight() + 5
	end

	if self:IsEnabled() ~= 1 then
		tooltip.Warning:SetText(self.name == DEMON_HUNTER and DEMON_HUNTER_DISABLE or RACE_CLASS_ERROR)
		tooltip.Warning:SetWidth(tooltip:GetWidth() - 20)
		tooltip:SetWidth(math.max(tooltip:GetWidth(), tooltip.Warning:GetWidth() + 20))
		tooltip.Warning:SetPoint("TOPLEFT", tooltip.AbilityList:IsShown() and tooltip.AbilityList or tooltip.Role, "BOTTOMLEFT", 0, -15)
		tooltip.Warning:Show()

		tooltipHeight = tooltipHeight + tooltip.Warning:GetHeight() + 15
	else
		tooltip.Warning:Hide()
	end

	tooltip:SetHeight(tooltipHeight)
	tooltip:ClearAllPoints()
	tooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
	tooltip:Show()
end

function CharCreateClassButtonTemplate_OnLeave(self)
	GlueClassTooltip:Hide()
end