--	Filename:	CharacterCreate.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

-- CHARACTER_FACING_INCREMENT = 2
MAX_RACES = C_CharacterCreation.GetNumAvailableRaces()
MAX_CLASSES_PER_RACE = 11
NUM_CHAR_CUSTOMIZATIONS = 5
MIN_CHAR_NAME_LENGTH = 2
CHARACTER_CREATE_ROTATION_START_X = nil
CHARACTER_CREATE_INITIAL_FACING = nil
NUM_PREVIEW_FRAMES = 14
PANDAREN_RACE_ID = 7
local featureIndex = 1
local FeatureType = 1

PAID_CHARACTER_CUSTOMIZATION = 1
PAID_RACE_CHANGE = 2
PAID_FACTION_CHANGE = 3
PAID_SERVICE_CHARACTER_ID = nil
PAID_SERVICE_TYPE = nil

PREVIEW_FRAME_HEIGHT = 130
PREVIEW_FRAME_X_OFFSET = 19
PREVIEW_FRAME_Y_OFFSET = -7

FACTION_BACKDROP_COLOR_TABLE = {
	["Alliance"] = {0.5, 0.5, 0.5, 0.09, 0.09, 0.19, 0, 0, 0.2, 0.29, 0.33, 0.91},
	["Horde"] = {0.5, 0.2, 0.2, 0.19, 0.05, 0.05, 0.2, 0, 0, 0.90, 0.05, 0.07},
	["Player"] = {0.2, 0.5, 0.2, 0.05, 0.2, 0.05, 0.05, 0.2, 0.05, 1, 1, 1},
}
FRAMES_TO_BACKDROP_COLOR = {
	"CharacterCreateCharacterRace",
	"CharacterCreateCharacterClass",
--	"CharacterCreateCharacterFaction",
	"CharacterCreateNameEdit",
}
RACE_ICON_TCOORDS = {
	["HUMAN_MALE"]		= {0, 0.125, 0, 0.125},
	["DWARF_MALE"]		= {0.125, 0.25, 0, 0.125},
	["GNOME_MALE"]		= {0.25, 0.375, 0, 0.125},
	["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.125},
	["GOBLIN_MALE"]		= {0.625, 0.75, 0.125, 0.25},

	["TAUREN_MALE"]		= {0, 0.125, 0.125, 0.25},
	["SCOURGE_MALE"]	= {0.125, 0.25, 0.125, 0.25},
	["TROLL_MALE"]		= {0.25, 0.375, 0.125, 0.25},
	["ORC_MALE"]		= {0.375, 0.5, 0.125, 0.25},

	["HUMAN_FEMALE"]	= {0, 0.125, 0.25, 0.375},
	["DWARF_FEMALE"]	= {0.125, 0.25, 0.25, 0.375},
	["GNOME_FEMALE"]	= {0.25, 0.375, 0.25, 0.375},
	["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.25, 0.375},
	["GOBLIN_FEMALE"]	= {0.625, 0.75, 0.375, 0.5},

	["TAUREN_FEMALE"]	= {0, 0.125, 0.375, 0.5},
	["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.375, 0.5},
	["TROLL_FEMALE"]	= {0.25, 0.375, 0.375, 0.5},
	["ORC_FEMALE"]		= {0.375, 0.5, 0.375, 0.5},

	["BROKEN_MALE"]		= {0.875, 1, 0.125, 0.25},
	["BROKEN_FEMALE"]	= {0.875, 1, 0.375, 0.5},

	["NAGA_MALE"]		= {0.875, 1, 0, 0.125},
	["NAGA_FEMALE"]		= {0.875, 1, 0.25, 0.375},

	["PANDAREN_MALE"]	= {0.75, 0.875, 0, 0.125},
	["PANDAREN_FEMALE"]	= {0.75, 0.875, 0.25, 0.375},

	["WORGEN_MALE"]		= {0, 0.125, 0.5, 0.625},
	["WORGEN_FEMALE"]	= {0.125, 0.25, 0.5, 0.625},

	["BLOODELF_MALE"]	= {0.5, 0.625, 0.125, 0.25},
	["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.375, 0.5},

	["QUELDO_MALE"]		= {0.875, 1, 0.125, 0.25},
	["QUELDO_FEMALE"]	= {0.875, 1, 0.375, 0.5},

	["PANDAREN_MALE"]	= {0.75, 0.875, 0, 0.125},
	["PANDAREN_FEMALE"]	= {0.75, 0.875, 0.25, 0.375},

	["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.125},
	["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.25, 0.375},

	["DH_NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.125},
	["DH_NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.25, 0.375},

	["DH_BLOODELF_MALE"]	= {0.5, 0.625, 0.125, 0.25},
	["DH_BLOODELF_FEMALE"]	= {0.5, 0.625, 0.375, 0.5},
}
CLASS_ICON_TCOORDS = {
	["WARRIOR"]	= {1024, 1024, 80, 55, 164, 146},
	["MAGE"]	= {1024, 1024, 398, 223, 164, 146},
	["ROGUE"]	= {1024, 1024, 558, 55, 164, 146},
	["DRUID"]	= {1024, 1024, 238, 391, 164, 146},
	["HUNTER"]	= {1024, 1024, 398, 55, 164, 146},
	["SHAMAN"]	= {1024, 1024, 238, 223, 164, 146},
	["PRIEST"]	= {1024, 1024, 558, 391, 164, 146},
	["WARLOCK"]	= {1024, 1024, 558, 223, 164, 146},
	["PALADIN"]	= {1024, 1024, 238, 55, 164, 146},
	["DEATHKNIGHT"]	= {1024, 1024, 80, 223, 164, 146},
	["DEMONHUNTER"]	= {1024, 1024, 398, 391, 164, 146},
}
MODEL_CAMERA_CONFIG = {
	[2] = {
		["Draenei"] = { tx = 0.191, ty = -0.015, tz = 2.302, cz = 2.160, distance = 1.116, light =  0.80 },
		["NightElf"] = { tx = 0.095, ty = -0.008, tz = 2.240, cz = 2.045, distance = 0.830, light =  0.85 },
		["Naga"] = { tx = 0.095, ty = -0.008, tz = 2.240, cz = 2.045, distance = 0.830, light =  0.85 },
		["Scourge"] = { tx = 0.094, ty = -0.172, tz = 1.675, cz = 1.478, distance = 0.691, light =  0.80 },
		["Orc"] = { tx = 0.346, ty = -0.001, tz = 1.878, cz = 1.793, distance = 1.074, light =  0.80 },
		["Gnome"] = { tx = 0.051, ty = 0.015, tz = 0.845, cz = 0.821, distance = 0.821, light =  0.85 },
		["Dwarf"] = { tx = 0.037, ty = 0.009, tz = 1.298, cz = 1.265, distance = 0.839, light =  0.85 },
		["Tauren"] = { tx = 0.516, ty = -0.003, tz = 1.654, cz = 1.647, distance = 1.266, light =  0.80 },
		["Troll"] = { tx = 0.402, ty = 0.016, tz = 2.076, cz = 1.980, distance = 0.943, light =  0.75 },
		["BloodElf"] = { tx = 0.009, ty = -0.120, tz = 1.914, cz = 1.712, distance = 0.727, light =  0.80 },
		["Queldo"] = { tx = 0.009, ty = -0.120, tz = 1.914, cz = 1.712, distance = 0.727, light =  0.80 },
		["Human"] = { tx = 0.055, ty = 0.006, tz = 1.863, cz = 1.749, distance = 0.714, light =  0.75 },
		["Pandaren"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
		["Goblin"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
		["Worgen"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
	},
	[3] = {
		["Draenei"] = { tx = 0.155, ty = 0.009, tz = 2.177, cz = 1.971, distance = 0.734, light =  0.75 },
		["NightElf"] = { tx = 0.071, ty = 0.034, tz = 2.068, cz = 2.055, distance = 0.682, light =  0.85 },
		["Naga"] = { tx = 0.071, ty = 0.034, tz = 2.068, cz = 2.055, distance = 0.682, light =  0.85 },
		["Scourge"] = { tx = 0.198, ty = 0.001, tz = 1.669, cz = 1.509, distance = 0.563, light =  0.75 },
		["Orc"] = { tx = -0.069, ty = -0.007, tz = 1.863, cz = 1.718, distance = 0.585, light =  0.75 },
		["Gnome"] = { tx = 0.031, ty = 0.009, tz = 0.787, cz = 0.693, distance = 0.726, light =  0.85 },
		["Dwarf"] = { tx = -0.060, ty = -0.010, tz = 1.326, cz = 1.343, distance = 0.720, light =  0.80 },
		["Tauren"] = { tx = 0.337, ty = -0.008, tz = 1.918, cz = 1.855, distance = 0.891, light =  0.75 },
		["Troll"] = { tx = 0.031, ty = -0.082, tz = 2.226, cz = 2.248, distance = 0.674, light =  0.75 },
		["BloodElf"] = { tx = -0.072, ty = 0.009, tz = 1.789, cz = 1.792, distance = 0.717, light =  0.80 },
		["Queldo"] = { tx = -0.072, ty = 0.009, tz = 1.789, cz = 1.792, distance = 0.717, light =  0.80 },
		["Human"] = { tx = -0.044, ty = -0.015, tz = 1.755, cz = 1.689, distance = 0.612, light =  0.75 },
		["Pandaren"] = { tx = 0.122, ty = -0.002, tz = 1.999, cz = 1.925, distance = 1.065, light =  0.90 },
		["Goblin"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
		["Worgen"] = { tx = 0.046, ty = -0.020, tz = 2.125, cz = 2.201, distance = 1.240, light =  0.90 },
	}
}

BANNER_DEFAULT_TEXTURE_COORDS = {0.109375, 0.890625, 0.201171875, 0.80078125}
BANNER_DEFAULT_SIZE = {200, 308}

function CharacterCustomizeScreenShow()
	CharCreateClassFrame:Hide()
	CharCreateRaceFrame:Hide()
	CharacterCreateTOPBalka:Hide()

	CharCreateCustomizationFrame:Show()
	CharacterCreateRandomNames:Show()
	CharacterCreateNameEdit:Show()

	CharCreateNextButtons:SetPoint("RIGHT", CharCreateClassFrame, -60, -10)
	CharCreateBackButtons:SetPoint("LEFT", CharCreateClassFrame, 60, -10)

	CharCreateMaleButton:SetPoint("TOP", CharCreateCustomizationFrame, -19, 1)
	CharCreateFemaleButton:SetPoint("TOP", CharCreateCustomizationFrame, 19.5, 1)
end

function CharacterCreateScreenShow()
    CharCreateBackButtons:Show()
	CharCreateClassFrame:Show()
	CharCreateRaceFrame:Show()
	CharacterCreateTOPBalka:Show()

	CharCreateCustomizationFrame:Hide()
	CharacterCreateRandomNames:Hide()
	CharacterCreateNameEdit:Hide()
	-- CharCreateCustomizationFrameTopBalka:Hide()

	CharCreateNextButtons:SetPoint("RIGHT", CharCreateClassFrame, -60, 60)
	CharCreateBackButtons:SetPoint("LEFT", CharCreateClassFrame, 60, 60)

	CharCreateMaleButton:SetPoint("TOP", CharCreateClassFrame, -18.7, -16)
	CharCreateFemaleButton:SetPoint("TOP", CharCreateClassFrame, 18, -16)

	CharCreateMaleButton:SetSize(43, 43)
	CharCreateFemaleButton:SetSize(43, 43)

	CharCreateCustomizationFrame:SetAlpha(1)
	CharacterCreateRandomNames:SetAlpha(1)
	CharacterCreateNameEdit:SetAlpha(1)
	CharCreateNextButtons:SetAlpha(1)
	CharCreateBackButtons:SetAlpha(1)
	CharCreateMaleButton:SetAlpha(1)
	CharCreateFemaleButton:SetAlpha(1)
end

CHAR_CUSTOMIZE_HAIR_COLOR = 4

function RaceIDToFactionColor( id )
	local Alliance = {1, 2, 3, 4, 5, 6, 8}
	local Horde = {10, 11, 12, 14, 13, 16, 15}

	for _, r_AID in pairs(Alliance) do
		if r_AID == id then
			return {26 / 255, 144 / 255, 240 / 255, "Alliance"}
		end
	end

	for _, r_HID in pairs(Horde) do
		if r_HID == id then
			return {255 / 255, 0, 0, "Horde"}
		end
	end

	if id == 7 or id == 17 then
		return {1, 1, 1}
	end
end

function CharacterCreate_OnLoad(self)
	self:RegisterEvent("RANDOM_CHARACTER_NAME_RESULT")

	self.faceZoom = false
	modelZoomX, modelZoomY, modelZoomZ = 0, 0, 0

	CharacterCreate.numRaces = 0
	CharacterCreate.selectedRace = 0
	CharacterCreate.numClasses = 0
	CharacterCreate.selectedClass = 0
	CharacterCreate.selectedGender = 0

	SetCharCustomizeFrame("CharacterCreate")

	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		_G["CharCreateCustomizationButton"..i].text:SetText(_G["CHAR_CUSTOMIZATION"..i.."_DESC"])
	end

	-- Color edit box backdrop
	local backdropColor = FACTION_BACKDROP_COLOR_TABLE["Alliance"]
	CharacterCreateNameEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
	CharacterCreateNameEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])

	CharacterCreateFrame.state = "CLASSRACE"

	CharCreatePreviewFrame.previews = { }
end

function CharCustomizeButtonClick(id)
	CycleCharCustomization(id, 1)
end

function CharacterCreate_OnShow()
	CharacterCreate.lastSelectedRaceButton 	= nil
	CharacterCreate.lastSelectedClassButton = nil
	CharacterCreate.faceZoom 				= false

	if PAID_SERVICE_TYPE then
		CustomizeExistingCharacter( PAID_SERVICE_CHARACTER_ID )
		CharacterCreateNameEdit:SetText( PaidChange_GetName() )
	else
		ResetCharCustomize()
		CharacterCreateNameEdit:SetText("")
	end

	CharacterCreateEnumerateRaces()
--	CharacterCreateEnumerateClasses(GetAvailableClasses())

	if GetSelectedSex() == E_SEX.MALE then
		CharCreateMaleButton:Click()
	else
		CharCreateFemaleButton:Click()
	end

	CharacterChangeFixup()

	if CharacterCreateFrame.forceCustomization then
		CharacterCreate_Forward()
	end
end

function CharacterCreate_OnHide()
	CharacterCreateFrame.forceCustomization = nil
	PAID_SERVICE_CHARACTER_ID = nil
	PAID_SERVICE_TYPE = nil
	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) then
		CharacterCreate_Back()
	end
	CharCreatePreviewFrame.rebuildPreviews = true
    CharCreateBackButtons:Show()
end

function CharacterCreate_OnEvent(event, arg1, arg2, arg3)
	if ( event == "RANDOM_CHARACTER_NAME_RESULT" ) then
		if ( arg1 == 0 ) then
			-- Failed.  Generate a random name locally.
			CharacterCreateNameEdit:SetText(GenerateRandomName())
		else
			-- Succeeded.  Use what the server sent.
			CharacterCreateNameEdit:SetText(arg2)
		end
		CharacterCreateRandomName:Enable()
		CharCreateOkayButton:Enable()
		PlaySound("gsCharacterCreationLook")
	end
end

function CharacterCreateFrame_OnMouseDown(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition()
		CHARACTER_CREATE_INITIAL_FACING = GetCharacterCreateFacing()
	end
end

function CharacterCreateFrame_OnMouseUp(button)
	if ( button == "LeftButton" ) then
		CHARACTER_CREATE_ROTATION_START_X = nil
	end
end

function CharacterCreateFrame_OnUpdate(self, elapsed)
	if ( CHARACTER_CREATE_ROTATION_START_X ) then
		local x = GetCursorPosition()
		local diff = (x - CHARACTER_CREATE_ROTATION_START_X) * CHARACTER_ROTATION_CONSTANT
		CHARACTER_CREATE_ROTATION_START_X = GetCursorPosition()
		SetCharacterCreateFacing(GetCharacterCreateFacing() + diff)
	end
	CharacterCreateWhileMouseDown_Update(elapsed)
end

function CharacterCreateEnumerateRaces()
	CharacterCreate.numRaces = C_CharacterCreation.GetNumAvailableRaces()

	for i = 1, CharacterCreate.numRaces do
		local button = CharacterCreate.raceButtons[i]

		if button then
			local RaceInfo = C_CharacterCreation.GetRaceInfo(i)

			button.index 		= RaceInfo.raceIndex
			button.raceInfo 	= RaceInfo

			button.nameFrame.text:SetText(RaceInfo.raceName)

			button:GetNormalTexture():SetTexture(RaceInfo.iconTexture)
			button:GetPushedTexture():SetTexture(RaceInfo.iconTexture)

			button:Enable()
			SetButtonDesaturated(button)

			button:SetShown(not button:GetAttribute("IsDevShow") or (button:GetAttribute("IsDevShow") and IsDevClient()))
		end
	end

	if not CharacterCreate.lastSelectedRaceButton and not PAID_SERVICE_TYPE then
		_G["CharCreateRaceButton1"]:Click()
	end
end

local ClassBGColor = {
	["DEMONHUNTER"] = {0.64, 0.19, 0.79},
	["DRUID"] = {1.00, 0.49, 0.04},
	["HUNTER"] = {0.67, 0.83, 0.45},
	["DEATHKNIGHT"] = {0.77, 0.12, 0.23},
	["PALADIN"] = {0.96, 0.55, 0.73},
	["ROGUE"] = {1.00, 0.96, 0.41},
	["PRIEST"] = {1.00, 1.00, 1.00},
	["MAGE"] = {0.41, 0.80, 0.94},
	["SHAMAN"] = {0.0, 0.44, 0.87},
	["WARLOCK"] = {0.58, 0.51, 0.79},
	["WARRIOR"] = {0.78, 0.61, 0.43}
}

local classAssocData = {}
function CharacterCreateEnumerateClasses(...)
	CharacterCreate.numClasses = select("#", ...)/3
	if ( CharacterCreate.numClasses > MAX_CLASSES_PER_RACE ) then
		message("Too many classes!  Update MAX_CLASSES_PER_RACE")
		return
	end
	-- local coords
	local index = 1
	local button
	for i=1, select("#", ...), 3 do
		_G["CharCreateClassButton"..index.."NormalTexture"]:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..select(i + 1, ...))
		_G["CharCreateClassButton"..index.."PushedTexture"]:SetTexture("Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..select(i + 1, ...))

		button = _G["CharCreateClassButton"..index]
		button:Show()
		if ( select(i+2, ...) == 1 ) then
			if (IsRaceClassValid(GetSelectedRace(), index)) then
				button:Enable()
				SetButtonDesaturated(button)
				button.tooltip = select(i, ...)
				button.Tcolor = ClassBGColor[select(i + 1, ...)]
				button.IsDisable = false
				button.ename = select(i+1, ...)
			else
				button:Disable()
				SetButtonDesaturated(button, 1)
				button.tooltip = select(i, ...)
				button.Tcolor = ClassBGColor[select(i + 1, ...)]
				button.IsDisable = true
				button.ename = select(i+1, ...)
			end
		else
			button:Disable()
			SetButtonDesaturated(button, 1)
			button.tooltip = _G[strupper(select(i+1, ...).."_".."DISABLED")]
		end
		classAssocData[select(i, ...)] = index
		index = index + 1
	end

	if not CharacterCreate.lastSelectedClassButton and not PAID_SERVICE_TYPE then
		_G["CharCreateClassButton1"]:Click()
	end
end

function SetCharacterClass(id)
	CharacterCreate.selectedClass = id
	C_CharacterCreation.SetBackgroundModel()

	for i=1, CharacterCreate.numClasses, 1 do
		local button = _G["CharCreateClassButton"..i]
		if ( i == id ) then
			button:SetChecked(1)
		else
			button:SetChecked(0)
			button.selection:Hide()
		end
	end
end

function CharacterCreate_OnChar()
end

function CharacterCreate_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		CharacterCreate_Back()
	elseif ( key == "ENTER" ) then
		CharacterCreate_Forward()
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot()
	end
end

function CharacterCreate_Finish()
	PlaySound("gsCharacterCreationCreateChar")

	if ( PAID_SERVICE_TYPE ) then
		if PAID_SERVICE_TYPE == PAID_FACTION_CHANGE then
			GlueDialog_Show("CONFIRM_PAID_FACTION_CHANGE")
		else
			GlueDialog_Show("CONFIRM_PAID_SERVICE")
		end
	else
		CharCreateNextButtons:Disable()
		C_Timer:After(0.200, function() CharCreateNextButtons:Enable() end)
		CreateCharacter(CharacterCreateNameEdit:GetText())
	end
end

function CharacterCreate_Back()
	if CharacterCreateFrame.forceCustomization then
		PlaySound("gsCharacterCreationCancel")
		CHARACTER_SELECT_BACK_FROM_CREATE = true
		SetGlueScreen("charselect")
		return
	end

	C_CharacterCreation.FaceZoomOut()

	if ( CharacterCreateFrame.state == "CUSTOMIZATION" ) and CharCreateBackButtons:IsShown() then
		PlaySound("gsCharacterCreationCancel")
		CharacterCreateFrame.state = "CLASSRACE"
		CharacterCreateScreenShow()
		return
	end

    if not CharCreateBackButtons:IsShown() then
        CharacterCreateFrame.state = "CLASSRACE"
        CharacterCreateScreenShow()
    end

	PlaySound("gsCharacterCreationCancel")
	CHARACTER_SELECT_BACK_FROM_CREATE = true
	SetGlueScreen("charselect")
end

local function ChooseFaction( factionID )
	local raceInfo = C_CharacterCreation.GetRaceInfo( C_CharacterCreation.GetSelectedRace() )

	if isOneOf(raceInfo.raceID, E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE, E_CHARACTER_RACES.RACE_VULPERA_HORDE) or CharacterCreateFrame.IsNeutralVulpera then
		if factionID == 0 then
			C_CharacterCreation.SetSelectedRace(18, true)
		else
			C_CharacterCreation.SetSelectedRace(17, true)
		end
	elseif isOneOf(raceInfo.raceID, E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE, E_CHARACTER_RACES.RACE_PANDAREN_HORDE) then
		if factionID == 0 then
			C_CharacterCreation.SetSelectedRace(21, true)
		else
			C_CharacterCreation.SetSelectedRace(15, true)
		end
	end

    CreateCharacter(CharacterCreateNameEdit:GetText())
end

GlueDialogTypes["CHOOSE_FACTION"] = {
	text = CHOOSE_FACTION,
	button1 = FACTION_ALLIANCE,
	button2 = FACTION_HORDE,
	escapeHides = true,
	OnAccept = function()
		ChooseFaction(1)
	end,
	OnCancel = function()
		ChooseFaction(0)
	end,
}

function CharacterCreate_Forward()
	if ( CharacterCreateFrame.state == "CLASSRACE" ) then
		CharacterCreateFrame.state = "CUSTOMIZATION"
		PlaySound("gsCharacterSelectionCreateNew")
		CharacterCustomizeScreenShow()
		if PAID_SERVICE_TYPE == PAID_FACTION_CHANGE then
            local raceButtonID = C_CharacterCreation.GetAssociateRaces(PaidChange_GetCurrentRaceIndex())
			local raceInfo = C_CharacterCreation.GetRaceInfo(raceButtonID)

			if isOneOf(raceInfo.raceID,
				E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
				E_CHARACTER_RACES.RACE_PANDAREN_HORDE,
				E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE,
				E_CHARACTER_RACES.RACE_VULPERA_HORDE) then

				--GlueDialog_Show("CHOOSE_FACTION" -- Временно нет необходимости в этом.
			end
		end
	else
		CharacterCreate_Finish()
	end
end

function CharCreateCustomizationFrame_OnShow ()
	-- check each button and hide it if there are no values select
	local resize = 0
	local lastGood = 0
	local isSkinVariantHair = false --GetSkinVariationIsHairColor(CharacterCreate.selectedRace)
	local isDefaultSet = 0
	local checkedButton = 1

	-- check if this was set, if not, default to 1
	if ( CharacterCreateFrame.customizationType == 0 or CharacterCreateFrame.customizationType == nil ) then
		CharacterCreateFrame.customizationType = 1
	end
	for i=1, NUM_CHAR_CUSTOMIZATIONS, 1 do
		if ( ( 5 <= 1 ) or ( isSkinVariantHair and i == CHAR_CUSTOMIZE_HAIR_COLOR ) ) then
			resize = resize + 1
			_G["CharCreateCustomizationButton"..i]:Hide()
		else
			-- this must be done since a selected button can 'disappear' when swapping genders
			if ( isDefaultSet == 0 and CharacterCreateFrame.customizationType == i) then
				isDefaultSet = 1
				checkedButton = i
			end
			-- set your anchor to be the last good, this currently means button 1 HAS to be shown
			if (i > 1) then
				_G["CharCreateCustomizationButton"..i]:SetPoint( "TOP",_G["CharCreateCustomizationButton"..lastGood]:GetName() , "BOTTOM")
			end
			lastGood = i
		end
	end

	if (isDefaultSet == 0) then
		CharacterCreateFrame.customizationType = lastGood
		checkedButton = lastGood
	end

	if (resize > 0) then
	-- we need to resize and remap the banner texture
		local buttonx, buttony = CharCreateCustomizationButton1:GetSize()
		local screenamount = resize*buttony
		local frameX, frameY = CharCreateCustomizationFrameBanner:GetSize()
		local pctShrink = .2*resize
		local uvXDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[2] - BANNER_DEFAULT_TEXTURE_COORDS[1]
		local uvYDefaultSize = BANNER_DEFAULT_TEXTURE_COORDS[4] - BANNER_DEFAULT_TEXTURE_COORDS[3]
		local newYUV = pctShrink*uvYDefaultSize + BANNER_DEFAULT_TEXTURE_COORDS[3]
		-- end coord stay the same
		CharCreateCustomizationFrameBanner:SetTexCoord(BANNER_DEFAULT_TEXTURE_COORDS[1], BANNER_DEFAULT_TEXTURE_COORDS[2], newYUV, BANNER_DEFAULT_TEXTURE_COORDS[4])
		CharCreateCustomizationFrameBanner:SetSize(frameX, frameY - screenamount)
	end
end

function CharacterClass_OnClick(self, id)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass")
		local _,_,currClass = GetSelectedClass()

		if ( currClass ~= id ) then
			CharacterCreate.lastSelectedClassButton = id

			SetSelectedClass(id)
			SetCharacterClass(id)
			-- CharacterChangeFixup()
		else
			self:SetChecked(1)
		end
	else
		self:SetChecked(0)
	end
end

function CharacterRace_OnClick(self)
	if( self:IsEnabled() ) then
		PlaySound("gsCharacterCreationClass")
		if not CharacterCreate.lastSelectedRaceButton or CharacterCreate.lastSelectedRaceButton ~= self.index then
			C_CharacterCreation.SetSelectedRace( self:GetID() )

			local _,_,classIndex = GetSelectedClass()
			if ( PAID_SERVICE_TYPE ) then
				classIndex = PaidChange_GetCurrentClassIndex()
				SetSelectedClass(classIndex)
			end

			CharacterCreate.lastSelectedRaceButton = self.index

			SetCharacterCreateFacing(0)
			CharacterCreate_UpdateHairCustomization()
			-- CharacterChangeFixup()
		else
			self:SetChecked(1)
		end
	else
		self:SetChecked(0)
	end
end

function CharacterCustomization_Left(id)
	PlaySound("gsCharacterCreationLook")
	if isOneOf(id, 2, 3, 4, 5) then
		C_CharacterCreation.FaceZoomIn()
	else
		C_CharacterCreation.FaceZoomOut()
	end
	CycleCharCustomization(id, -1)
end

function CharacterCustomization_Right(id)
	PlaySound("gsCharacterCreationLook")
	if isOneOf(id, 2, 3, 4, 5) then
		C_CharacterCreation.FaceZoomIn()
	else
		C_CharacterCreation.FaceZoomOut()
	end
	CycleCharCustomization(id, 1)
end

function CharacterCreate_GenerateRandomName(button)
	button:Disable()
	CharacterCreateNameEdit:SetText("...")
	RequestRandomName()
end

function CharacterCreate_Randomize()
	PlaySound("gsCharacterCreationLook")
	RandomizeCharCustomization()
end

function CharacterCreateRotateRight_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() + CHARACTER_FACING_INCREMENT)
	end
end

function CharacterCreateRotateLeft_OnUpdate(self)
	if ( self:GetButtonState() == "PUSHED" ) then
		SetCharacterCreateFacing(GetCharacterCreateFacing() - CHARACTER_FACING_INCREMENT)
	end
end

function CharacterCreate_UpdateHairCustomization()
	if not _G["HAIR_"..GetHairCustomization().."_STYLE"] or _G["HAIR_"..GetHairCustomization().."_STYLE"] == "" then
		CharCreateCustomizationButton3:Hide()
		CharCreateCustomizationButton4:SetPoint("TOP", CharCreateCustomizationButton2, "BOTTOM", 0, -20)
	else
		CharCreateCustomizationButton3:Show()
		CharCreateCustomizationButton3.text:SetText(_G["HAIR_"..GetHairCustomization().."_STYLE"])
		CharCreateCustomizationButton4:SetPoint("TOP", CharCreateCustomizationButton3, "BOTTOM", 0, -20)
	end

	if not _G["HAIR_"..GetHairCustomization().."_COLOR"] or _G["HAIR_"..GetHairCustomization().."_COLOR"] == "" or _G["HAIR_"..GetHairCustomization().."_COLOR"] == HAIR_VULPERA_COLOR then
		CharCreateCustomizationButton4:Hide()
		if CharCreateCustomizationButton3:IsShown() then
			CharCreateCustomizationButton5:SetPoint("TOP", CharCreateCustomizationButton3, "BOTTOM", 0, -20)
		else
			CharCreateCustomizationButton5:SetPoint("TOP", CharCreateCustomizationButton2, "BOTTOM", 0, -20)
		end
	else
		CharCreateCustomizationButton4:Show()
		CharCreateCustomizationButton4.text:SetText(_G["HAIR_"..GetHairCustomization().."_COLOR"])
		CharCreateCustomizationButton5:SetPoint("TOP", CharCreateCustomizationButton4, "BOTTOM", 0, -20)
	end

	if not _G["FACIAL_HAIR_"..GetFacialHairCustomization()] or _G["FACIAL_HAIR_"..GetFacialHairCustomization()] == "" then
		CharCreateCustomizationButton5:Hide()
	else
		CharCreateCustomizationButton5:Show()
		CharCreateCustomizationButton5.text:SetText(_G["FACIAL_HAIR_"..GetFacialHairCustomization()])
	end
end

function SetButtonDesaturated(button, desaturated)
	if ( not button ) then
		return
	end
	local icon = button:GetNormalTexture()
	if ( not icon ) then
		return
	end

	icon:SetDesaturated(desaturated)
end

function GetFlavorText(tagname, sex)
	local primary, secondary
	if ( sex == E_SEX.MALE ) then
		primary = ""
		secondary = "_FEMALE"
	else
		primary = "_FEMALE"
		secondary = ""
	end
	local text = _G[tagname..primary]
	if ( (text == nil) or (text == "") ) then
		text = _G[tagname..secondary]
	end
	return text
end

local function disabledButton( button, toggle, isAlliedRace )
	button:SetEnabled(not toggle)
	button:SetChecked(false)
	button.alliedRaceDisabled = isAlliedRace and toggle or nil
	SetButtonDesaturated(button, toggle)
end

enum: E_ALLIED_RACE_ID_TO_INDEX {
	[17] = E_CHARACTER_RACES.RACE_VOIDELF,
	[18] = E_CHARACTER_RACES.RACE_NIGHTBORNE,
}

function CharacterChangeFixup( dontAutoSelectRace )
	if PAID_SERVICE_TYPE then
		local raceButtonID = C_CharacterCreation.GetAssociateRaces(PaidChange_GetCurrentRaceIndex())
		local classButtonID = PaidChange_GetCurrentClassIndex()

        if not raceButtonID or raceButtonID == 0 then -- ХОТФИКС потом обязательно убрать
            raceButtonID = 16
        end

		CharCreateClassFrame:SetAlpha(0.5)

		local raceButton 	= _G["CharCreateRaceButton"..raceButtonID]
		local classButton 	= _G["CharCreateClassButton"..classButtonID]

		assert(raceButton, "CharacterChangeFixup: не найдена кнопка рассы по ID "..raceButtonID)
		assert(classButton, "CharacterChangeFixup: не найдена кнопка класса по ID "..classButtonID)

        if not dontAutoSelectRace then
            raceButton:Click()
        end

        classButton:Click()

		for buttonID, button in pairs(CharacterCreate.classButtons) do
			button:SetEnabled(buttonID == classButtonID)
			button:SetChecked(buttonID == classButtonID)
			SetButtonDesaturated(button, buttonID ~= classButtonID)
		end

		local factionTag = raceButton.raceInfo.FactionInfo.groupTag

        if C_CharacterCreation.GetSelectedRace() ~= raceButtonID then
            raceButtonID = C_CharacterCreation.GetSelectedRace()
        end

		for buttonID, button in pairs(CharacterCreate.raceButtons) do
			if buttonID == raceButtonID then
				button:SetEnabled(true)
				button:SetChecked(true)
			else
				local allow = false

				if PAID_SERVICE_TYPE == PAID_FACTION_CHANGE then
					allow = button.raceInfo.FactionInfo.groupTag ~= factionTag

                    -- Хардкод скрытие кнопок при смене фракции
                    CharCreateRaceButton17:SetShown(factionTag == "Horde") -- Вульпер Альянс
                    CharCreateRaceButton15:SetShown(factionTag == "Horde") -- Пандарен Альянс

                    CharCreateRaceButton18:SetShown(factionTag == "Alliance") -- Вульпер Орда
                    CharCreateRaceButton21:SetShown(factionTag == "Alliance") -- Пандарен Орда

                    if factionTag == "Neutral" then
                        CharacterCreateFrame.state = "CUSTOMIZATION"
                        PlaySound("gsCharacterSelectionCreateNew")
                        CharacterCustomizeScreenShow()
                        CharCreateBackButtons:Hide()

                        GlueDialog_Show("CHOOSE_FACTION")
                    end

                    CharacterCreateFrame.IsNeutralVulpera = factionTag == "Neutral"
				elseif PAID_SERVICE_TYPE == PAID_RACE_CHANGE then
					local ovverideData = CharacterSelect.overrideData[PAID_SERVICE_CHARACTER_ID]

					if C_Service:IsLockRenegadeFeatures() then
						allow = button.raceInfo.FactionInfo.groupTag == factionTag
					else
						if ovverideData then
							local ovverideFactionTag = SERVER_PLAYER_FACTION_GROUP[ovverideData]

							if PLAYER_FACTION_GROUP[ovverideFactionTag] == PLAYER_FACTION_GROUP.Renegade then
								allow = button.raceInfo.FactionInfo.groupTag == factionTag
							else
								allow = button.raceInfo.FactionInfo.groupTag == ovverideFactionTag
								factionTag = ovverideFactionTag
							end
						end
					end

                    CharCreateRaceButton17:SetShown(factionTag == "Alliance") -- Вульпер Альянс
                    CharCreateRaceButton15:SetShown(factionTag == "Alliance") -- Пандарен Альянс

                    CharCreateRaceButton18:SetShown(factionTag == "Horde") -- Вульпер Орда
                    CharCreateRaceButton21:SetShown(factionTag == "Horde") -- Пандарен Орда
				end

				if isOneOf(button.raceInfo.raceID,
					E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
					E_CHARACTER_RACES.RACE_BLOODELF_DH,
					E_CHARACTER_RACES.RACE_NIGHTELF_DH) then

					allow = false
				end

				if isOneOf(button.raceInfo.raceID, E_CHARACTER_RACES.RACE_NIGHTBORNE, E_CHARACTER_RACES.RACE_VOIDELF, E_CHARACTER_RACES.RACE_DARKIRONDWARF, E_CHARACTER_RACES.RACE_EREDAR) then
					if raceButtonID == button.raceInfo.raceID then
						allow = true
					elseif not IsGMAccount() and allow and CharacterCreate.alliedRacesUnlock and not CharacterCreate.alliedRacesUnlock[button.raceInfo.raceID] then
						allow = not allow
					end
				end

				button:SetEnabled(allow)
				button:SetChecked(false)
				SetButtonDesaturated(button, not allow)
			end
		end
	else
        CharCreateRaceButton16:Show()

        CharCreateRaceButton17:Hide()
        CharCreateRaceButton18:Hide()
        CharCreateRaceButton21:Hide()

		if not IsGMAccount() then
			if CharacterCreate.alliedRacesUnlock then
				disabledButton(CharCreateRaceButton22, not CharacterCreate.alliedRacesUnlock[E_CHARACTER_RACES.RACE_VOIDELF], true)
				disabledButton(CharCreateRaceButton23, not CharacterCreate.alliedRacesUnlock[E_CHARACTER_RACES.RACE_NIGHTBORNE], true)
				disabledButton(CharCreateRaceButton24, not CharacterCreate.alliedRacesUnlock[E_CHARACTER_RACES.RACE_DARKIRONDWARF])
				disabledButton(CharCreateRaceButton25, not CharacterCreate.alliedRacesUnlock[E_CHARACTER_RACES.RACE_EREDAR])
			else
				disabledButton(CharCreateRaceButton22, true, true)
				disabledButton(CharCreateRaceButton23, true, true)
				disabledButton(CharCreateRaceButton24, true)
				disabledButton(CharCreateRaceButton25, true)
			end
		end

		CharCreateClassFrame:SetAlpha(1)
	end
end

function CharCreate_ChangeFeatureVariation(delta)
	local numVariations = 8--GetNumFeatureVariations()
	local startIndex = featureIndex--GetSelectedFeatureVariation()
	local endIndex = startIndex + delta
	if ( endIndex < 1 or endIndex > numVariations ) then
		return
	end
	PlaySound("gsCharacterCreationClass")
	featureIndex = endIndex
	CharCreatePreviewFrame_SelectFeatureVariation(endIndex)
end

function CharCreatePreviewFrameButton_OnClick(self)
	PlaySound("gsCharacterCreationClass")
	CharCreatePreviewFrame_SelectFeatureVariation(self.index)
end

function CharCreatePreviewFrame_SelectFeatureVariation(endIndex)
	local self = CharCreatePreviewFrame
	if ( self.animating ) then
		if ( not self.queuedIndex ) then
			self.queuedIndex = endIndex
		end
	else
		local startIndex = featureIndex--GetSelectedFeatureVariation()
		--SelectFeatureVariation(endIndex)
		for i=1,endIndex do
			CycleCharCustomization(FeatureType, 1)
		end
		CharCreatePreviewFrame_UpdateStyleButtons()
		featureIndex = endIndex
		CharCreatePreviewFrame_StartAnimating(startIndex, endIndex)
	end
end

function CharCreatePreviewFrame_StartAnimating(startIndex, endIndex)
	local self = CharCreatePreviewFrame
	if ( self.animating ) then
		return
	else
		self.startIndex = startIndex
		self.currentIndex = startIndex
		self.endIndex = endIndex
		self.queuedIndex = nil
		self.direction = 1
		if ( self.startIndex > self.endIndex ) then
			self.direction = -1
		end
		self.movedTotal = 0
		self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT
		self.animating = true
	end
end

function CharCreatePreviewFrame_StopAnimating()
	local self = CharCreatePreviewFrame
	if ( self.animating ) then
		self.animating = false
	end
end

local ANIMATION_SPEED = 5
function CharCreatePreviewFrame_OnUpdate(self, elapsed)
	if ( self.animating ) then
		local moveIncrement = PREVIEW_FRAME_HEIGHT * elapsed * ANIMATION_SPEED
		self.movedTotal = self.movedTotal + moveIncrement
		self.scrollFrame:SetVerticalScroll((self.startIndex - 1) * PREVIEW_FRAME_HEIGHT + self.movedTotal * self.direction)
		self.moveUntilUpdate = self.moveUntilUpdate - moveIncrement
		if ( self.moveUntilUpdate <= 0 ) then
			self.currentIndex = self.currentIndex + self.direction
			self.moveUntilUpdate = PREVIEW_FRAME_HEIGHT
			-- reset movedTotal to account for rounding errors
			self.movedTotal = abs(self.startIndex - self.currentIndex) * PREVIEW_FRAME_HEIGHT
			-- CharCreate_DisplayPreviewModels(self.currentIndex)
		end
		if ( self.currentIndex == self.endIndex ) then
			self.animating = false
			-- CharCreate_DisplayPreviewModels()
			if ( self.queuedIndex ) then
				local newIndex = self.queuedIndex
				self.queuedIndex = nil
				--SelectFeatureVariation(newIndex)
				featureIndex = newIndex
				CycleCharCustomization(FeatureType, featureIndex)
				CharCreatePreviewFrame_UpdateStyleButtons()
				CharCreatePreviewFrame_StartAnimating(self.endIndex, newIndex)
			end
		end
	end
end

function CharCreatePreviewFrame_UpdateStyleButtons()
	local selectionIndex = math.random(1,5)--GetSelectedFeatureVariation()
	local numVariations = 8--GetNumFeatureVariations()
	if ( selectionIndex == 1 ) then
		CharCreateStyleUpButton:Enable()
		CharCreateStyleUpButton.arrow:SetDesaturated(true)
	else
		CharCreateStyleUpButton:Enable()
		CharCreateStyleUpButton.arrow:SetDesaturated(false)
	end
	if ( selectionIndex == numVariations ) then
		CharCreateStyleDownButton:Disable()
		CharCreateStyleDownButton.arrow:SetDesaturated(true)
	else
		CharCreateStyleDownButton:Disable(true)
		CharCreateStyleDownButton.arrow:SetDesaturated(false)
	end
end

local TotalTime = 0
local KeepScrolling = nil
local TIME_TO_SCROLL = 0.5
function CharacterCreateWhileMouseDown_OnMouseDown(direction)
	TIME_TO_SCROLL = 0.5
	TotalTime = 0
	KeepScrolling = direction
end
function CharacterCreateWhileMouseDown_OnMouseUp()
	KeepScrolling = nil
end
function CharacterCreateWhileMouseDown_Update(elapsed)
	if ( KeepScrolling ) then
		TotalTime = TotalTime + elapsed
		if ( TotalTime >= TIME_TO_SCROLL ) then
			CharCreate_ChangeFeatureVariation(KeepScrolling)
			TIME_TO_SCROLL = 0.25
			TotalTime = 0
		end
	end
end

function CharCreateRaceButtonTemplate_OnEnter( self, ... )
	if self.raceInfo then
		local factionTag 	= self.raceInfo.FactionInfo.groupTag
		local factionID  	= PLAYER_FACTION_GROUP[factionTag]
		local tooltipHeight = 0

		assert(factionID, "CharCreateRaceButtonTemplate_OnEnter: Не найлена фракция по ключу "..factionTag)

		local factionColor 		= PLAYER_FACTION_COLORS[factionID] or CreateColor(1, 1, 1)
		local raceFileString 	= string.upper(self.raceInfo.clientFileString)

		GlueRaceTooltip:SetBackdropBorderColor(factionColor.r, factionColor.g, factionColor.b)

		GlueRaceTooltip.Warning1:SetShown(self.alliedRaceDisabled)

		if self.alliedRaceDisabled then
			GlueRaceTooltip.Description1:ClearAndSetPoint("TOPLEFT", GlueRaceTooltip.Warning1, "BOTTOMLEFT", 0, -3)

			local text = _G["ALLIED_RACE_DISABLE_REASON_"..string.upper(self.raceInfo.clientFileString)]

			if text then
				GlueRaceTooltip.Warning1:SetText(text)
				GlueRaceTooltip.Warning1:SetWidth(GlueRaceTooltip:GetWidth() - 20)
			else
				GlueRaceTooltip.Description1:ClearAndSetPoint("TOPLEFT", GlueRaceTooltip.Header1, "BOTTOMLEFT", 0, -3)
				GlueRaceTooltip.Warning1:Hide()
			end
		else
			GlueRaceTooltip.Description1:ClearAndSetPoint("TOPLEFT", GlueRaceTooltip.Header1, "BOTTOMLEFT", 0, -3)
		end

		if GlueRaceTooltip.Warning1:IsShown() then
			tooltipHeight = tooltipHeight + GlueRaceTooltip.Warning1:GetHeight() + 5
		end

		GlueRaceTooltip.Header1:SetText(self.raceInfo.raceName)
		GlueRaceTooltip.Header2:SetText(SPELLS)
		GlueRaceTooltip.Description1:SetText(_G[string.format("CHARACTER_CREATE_INFO_RACE_%s_DESC", raceFileString)])
		GlueRaceTooltip.Description2:SetText(SPELLS_HELP_1)
		GlueRaceTooltip.Description3:SetText(SPELLS_PASSIVE)
		GlueRaceTooltip.Description4:SetText(SPELLS_ACTIVE)

		GlueRaceTooltip:ClearAllPoints()

		if factionTag == "Alliance" then
			GlueRaceTooltip:SetPoint("RIGHT", CharacterCreateFlagAlliance, 301, 0)
		elseif factionTag == "Horde" then
			GlueRaceTooltip:SetPoint("LEFT", CharacterCreateFlagHorde, -300, 0)
		else
			GlueRaceTooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
		end

		for i = 1, 7 do
			local headerLine 			= _G["GlueRaceTooltipHeader"..i]
			local descriptionLine 		= _G["GlueRaceTooltipDescription"..i]
			local spellNameLine 		= _G["GlueRaceTooltipSpellName"..i]
			local spellDescriptionLine 	= _G["GlueRaceTooltipSpellDescription"..i]

			if headerLine then
				headerLine:SetWidth(GlueRaceTooltip:GetWidth() - 20)
				tooltipHeight = tooltipHeight + headerLine:GetHeight() + 5

				GlueRaceTooltip:SetWidth(max(GlueRaceTooltip:GetWidth(), headerLine:GetWidth() + 20))

				headerLine:Show()
			end

			if descriptionLine then
				descriptionLine:SetWidth(GlueRaceTooltip:GetWidth() - 20)
				tooltipHeight = tooltipHeight + descriptionLine:GetHeight() + 5

				GlueRaceTooltip:SetWidth(max(GlueRaceTooltip:GetWidth(), descriptionLine:GetWidth() + 20))

				descriptionLine:Show()
			end

			if spellNameLine then
				local spellName = _G[string.format("CHARACTER_CREATE_INFO_RACE_%s_SPELL%d", raceFileString, i)]

				spellNameLine:SetText(spellName or "")

				spellNameLine:SetWidth(GlueRaceTooltip:GetWidth() - 20)
				tooltipHeight = tooltipHeight + spellNameLine:GetHeight() + 5

				GlueRaceTooltip:SetWidth(max(GlueRaceTooltip:GetWidth(), spellNameLine:GetWidth() + 20))

				spellNameLine:Show()
			end

			if spellDescriptionLine then
				local spellDesc = _G[string.format("CHARACTER_CREATE_INFO_RACE_%s_SPELL%d_DESC", raceFileString, i)]

				spellDescriptionLine:SetText(spellDesc or "")

				spellDescriptionLine:SetWidth(GlueRaceTooltip:GetWidth() - 20)
				tooltipHeight = tooltipHeight + spellDescriptionLine:GetHeight() + 5

				GlueRaceTooltip:SetWidth(max(GlueRaceTooltip:GetWidth(), spellDescriptionLine:GetWidth() + 20))

				spellDescriptionLine:Show()
			end
		end

		GlueRaceTooltip:SetHeight(tooltipHeight)
		GlueRaceTooltip:Show()
	end
end

function CharCreateClassButtonTemplate_OnEnter( self, ... )
	if ( self.tooltip ) then
		local height = 18
		local classTag = string.upper(self.ename)

		if not classTag then
			return
		end

		if self.Tcolor then
			GlueClassTooltip:SetBackdropBorderColor(self.Tcolor[1], self.Tcolor[2], self.Tcolor[3])
		end
		GlueClassTooltip:ClearAllPoints()
		GlueClassTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
		GlueClassTooltip:Show()

		if self.IsDisable then
			GlueClassTooltip.Warning1:SetText(RACE_CLASS_ERROR)
			if self.tooltip == DEMON_HUNTER then
				GlueClassTooltip.Warning1:SetText(DEMON_HUNTER_DISABLE)
			end
		end
		GlueClassTooltip.Header1:SetText(self.tooltip)
		GlueClassTooltip.Role1:SetText(_G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_ROLE", classTag)])
		GlueClassTooltip.Description1:SetText(_G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_DESC", classTag)])
		GlueClassTooltip.Header2:SetText(SPELL_EXAMPLE)
		GlueClassTooltip.Description2:SetText(SPELLS_PASSIVE)
		GlueClassTooltip.Description3:SetText(SPELLS_ACTIVE)

		for h = 1, 2 do
			local Headerline = _G["GlueClassTooltipHeader"..h]

			if ( Headerline ) then
				Headerline:Show()
			end

			if ( Headerline:IsShown() ) then
				Headerline:SetWidth(GlueClassTooltip:GetWidth() - 20)
				height = height + Headerline:GetHeight() + 5

				GlueClassTooltip:SetWidth(max(GlueClassTooltip:GetWidth(), Headerline:GetWidth() + 20))
			end
		end

		for d = 1, 1 do
			local Warningline = _G["GlueClassTooltipWarning"..d]

			if ( Warningline and self.IsDisable ) then
				Warningline:Show()
			else
				Warningline:Hide()
			end

			if ( Warningline:IsShown() ) then
				Warningline:SetWidth(GlueClassTooltip:GetWidth() - 20)
				height = height + Warningline:GetHeight() + 5

				GlueClassTooltip:SetWidth(max(GlueClassTooltip:GetWidth(), Warningline:GetWidth() + 20))
			end
		end

		for d = 1, 1 do
			local Roleline = _G["GlueClassTooltipRole"..d]

			if _G["GlueClassTooltipWarning1"]:IsShown() then
				Roleline:SetPoint("TOPLEFT", _G["GlueClassTooltipWarning1"], "BOTTOMLEFT", 0, -3)
			else
				Roleline:SetPoint("TOPLEFT", _G["GlueClassTooltipHeader1"], "BOTTOMLEFT", 0, -3)
			end

			if ( Roleline ) then
				Roleline:Show()
			end

			if ( Roleline:IsShown() ) then
				Roleline:SetWidth(GlueClassTooltip:GetWidth() - 20)
				height = height + Roleline:GetHeight() + 4.5

				GlueClassTooltip:SetWidth(max(GlueClassTooltip:GetWidth(), Roleline:GetWidth() + 20))
			end
		end

		for d = 1, 3 do
			local Descriptionline = _G["GlueClassTooltipDescription"..d]

			if ( Descriptionline ) then
				Descriptionline:Show()
			end

			if ( Descriptionline:IsShown() ) then
				Descriptionline:SetWidth(GlueClassTooltip:GetWidth() - 20)
				height = height + Descriptionline:GetHeight() + 4.5

				GlueClassTooltip:SetWidth(max(GlueClassTooltip:GetWidth(), Descriptionline:GetWidth() + 20))
			end
		end

		for s = 1, 5 do
			local SpellNameline = _G["GlueClassTooltipSpellName"..s]
			SpellNameline:SetText(_G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_SPELL%d", classTag, s)])

			if ( SpellNameline ) then
				SpellNameline:Show()
			end

			if ( SpellNameline:IsShown() ) then
				SpellNameline:SetWidth(GlueClassTooltip:GetWidth() - 20)
				height = height + SpellNameline:GetHeight() + 4.5

				GlueClassTooltip:SetWidth(max(GlueClassTooltip:GetWidth(), SpellNameline:GetWidth() + 20))
			end
		end

		for sd = 1, 5 do
			local SpellDescriptionline = _G["GlueClassTooltipSpellDescription"..sd]
			SpellDescriptionline:SetText(_G[string.format("CHARACTER_CREATE_INFO_CLASS_%s_SPELL%d_DESC", classTag, sd)])

			if ( SpellDescriptionline ) then
				SpellDescriptionline:Show()
			end

			if ( SpellDescriptionline:IsShown() ) then
				SpellDescriptionline:SetWidth(GlueClassTooltip:GetWidth() - 20)
				height = height + SpellDescriptionline:GetHeight() + 4.5

				GlueClassTooltip:SetWidth(max(GlueClassTooltip:GetWidth(), SpellDescriptionline:GetWidth() + 20))
			end
		end
		GlueClassTooltip:SetHeight(height)
	end
end