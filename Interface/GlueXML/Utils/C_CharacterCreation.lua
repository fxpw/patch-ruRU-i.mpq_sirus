local MODEL_FRAME
local IN_CHARACTER_CREATE = false

local SELECTED_SEX, SELECTED_RACE, SELECTED_CLASS

local ZOOM_TIME_SECONDS = 0.75
local CAMERA_ZOOM_LEVEL = 0
local CAMERA_ZOOM_MIN_LEVEL = 0
local CAMERA_ZOOM_MAX_LEVEL = 100
local CAMERA_ZOOM_LEVEL_AMOUNT = 20
local CAMERA_ZOOM_IN_PROGRESS = false

local PAID_OVERRIDE_CURRENT_RACE_INDEX

local CHARACTER_CREATE_CAMERA_ZOOMED_SETTINGS = {
	[E_SEX.MALE] = {
		[E_CHARACTER_RACES.RACE_HUMAN]					= {-6.300, 4.835, -0.800},
		[E_CHARACTER_RACES.RACE_DWARF]					= {-6.260, 4.820, -0.310},
		[E_CHARACTER_RACES.RACE_NIGHTELF]				= {-6.470, 4.950, -1.145},
		[E_CHARACTER_RACES.RACE_GNOME]					= {-6.000, 4.605, 0.250},
		[E_CHARACTER_RACES.RACE_DRAENEI]				= {-5.945, 4.550, -1.130},
		[E_CHARACTER_RACES.RACE_WORGEN]					= {-5.140, 3.955, -0.770},
		[E_CHARACTER_RACES.RACE_QUELDO]					= {-6.640, 4.955, -0.820},
		[E_CHARACTER_RACES.RACE_VOIDELF]				= {-6.610, 4.935, -0.825},
		[E_CHARACTER_RACES.RACE_DARKIRONDWARF]			= {-6.260, 4.820, -0.310},	-- RACE_DWARF
		[E_CHARACTER_RACES.RACE_LIGHTFORGED]			= {-5.945, 4.550, -1.130},	-- RACE_DRAENEI

		[E_CHARACTER_RACES.RACE_ORC]					= {-5.480, 4.018, -0.600},
		[E_CHARACTER_RACES.RACE_SCOURGE]				= {-6.640, 4.755, -0.475},
		[E_CHARACTER_RACES.RACE_TAUREN]					= {-5.320, 3.910, -0.410},
		[E_CHARACTER_RACES.RACE_TROLL] 					= {-5.650, 4.255, -0.800},
		[E_CHARACTER_RACES.RACE_GOBLIN]					= {-5.865, 4.320, 0.105},
		[E_CHARACTER_RACES.RACE_NAGA]					= {-5.900, 4.375, -0.690},
		[E_CHARACTER_RACES.RACE_BLOODELF]				= {-6.675, 4.835, -0.725},
		[E_CHARACTER_RACES.RACE_NIGHTBORNE]				= {-6.570, 4.880, -1.080},
		[E_CHARACTER_RACES.RACE_EREDAR]					= {-6.150, 4.565, -1.040},
		[E_CHARACTER_RACES.RACE_ZANDALARITROLL]			= {-6.010, 4.365, -0.980},

		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]		= {-4.470, 3.470, -0.400},
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]			= {-4.470, 3.470, -0.400},
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]		= {-4.470, 3.470, -0.400},

		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]		= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]			= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]		= {8.300, 0.105, -0.050},
	},
	[E_SEX.FEMALE] = {
		[E_CHARACTER_RACES.RACE_HUMAN]					= {-6.585, 5.039, -0.700},
		[E_CHARACTER_RACES.RACE_DWARF]					= {-6.285, 4.820, -0.275},
		[E_CHARACTER_RACES.RACE_NIGHTELF]				= {-6.555, 5.035, -1.015},
		[E_CHARACTER_RACES.RACE_GNOME]					= {-6.040, 4.635, 0.300},
		[E_CHARACTER_RACES.RACE_DRAENEI]				= {-6.485, 5.010, -1.070},
		[E_CHARACTER_RACES.RACE_WORGEN]					= {-5.940, 4.510, -1.060},
		[E_CHARACTER_RACES.RACE_QUELDO]					= {-6.770, 5.190, -0.700},
		[E_CHARACTER_RACES.RACE_VOIDELF]				= {-6.700, 5.140, -0.700},
		[E_CHARACTER_RACES.RACE_DARKIRONDWARF]			= {-6.285, 4.820, -0.275},	-- RACE_DWARF
		[E_CHARACTER_RACES.RACE_LIGHTFORGED]			= {-6.485, 5.010, -1.070},	-- RACE_DRAENEI

		[E_CHARACTER_RACES.RACE_ORC]					= {-6.535, 4.855, -0.695},
		[E_CHARACTER_RACES.RACE_SCOURGE]				= {-6.540, 4.825, -0.485},
		[E_CHARACTER_RACES.RACE_TAUREN]					= {-5.900, 4.360, -0.700},
		[E_CHARACTER_RACES.RACE_TROLL]					= {-6.485, 4.740, -1.010},
		[E_CHARACTER_RACES.RACE_GOBLIN]					= {-5.855, 4.358, 0.065},
		[E_CHARACTER_RACES.RACE_NAGA]					= {-6.105, 4.525, -0.690},
		[E_CHARACTER_RACES.RACE_BLOODELF]				= {-6.770, 5.043, -0.600},
		[E_CHARACTER_RACES.RACE_NIGHTBORNE]				= {-6.585, 4.810, -0.910},
		[E_CHARACTER_RACES.RACE_EREDAR]					= {-6.590, 4.944, -0.965},
		[E_CHARACTER_RACES.RACE_ZANDALARITROLL]			= {-6.370, 4.610, -0.940},

		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]		= {-4.470, 3.480, -0.305},
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]			= {-4.470, 3.480, -0.305},
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]		= {-4.470, 3.480, -0.305},

		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]		= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]			= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]		= {8.300, 0.105, -0.050},
	},
	["DEATHKNIGHT"] = {
		[E_SEX.MALE] = {
			[E_CHARACTER_RACES.RACE_HUMAN]				= {-3.800, 2.970, -0.388},
			[E_CHARACTER_RACES.RACE_DWARF]				= {-3.750, 2.935, -0.100},
			[E_CHARACTER_RACES.RACE_NIGHTELF]			= {-3.925, 3.056, -0.595},
			[E_CHARACTER_RACES.RACE_GNOME]				= {-3.590, 2.805, 0.235},
			[E_CHARACTER_RACES.RACE_DRAENEI]			= {-3.635, 2.835, -0.590},
			[E_CHARACTER_RACES.RACE_WORGEN]				= {-3.125, 2.457, -0.400},
			[E_CHARACTER_RACES.RACE_QUELDO]				= {-4.000, 3.040, -0.405},
			[E_CHARACTER_RACES.RACE_VOIDELF]			= {-3.975, 3.020, -0.405},
			[E_CHARACTER_RACES.RACE_DARKIRONDWARF]		= {-3.750, 2.935, -0.100},	-- RACE_DWARF
			[E_CHARACTER_RACES.RACE_LIGHTFORGED]		= {-3.635, 2.835, -0.590},	-- RACE_DRAENEI

			[E_CHARACTER_RACES.RACE_ORC]				= {-3.350, 2.598, -0.335},
			[E_CHARACTER_RACES.RACE_SCOURGE]			= {-4.015, 3.010, -0.260},
			[E_CHARACTER_RACES.RACE_TAUREN]				= {-3.285, 2.555, -0.225},
			[E_CHARACTER_RACES.RACE_TROLL]				= {-3.450, 2.736, -0.450},
			[E_CHARACTER_RACES.RACE_GOBLIN]				= {-3.565, 2.770, 0.080},
			[E_CHARACTER_RACES.RACE_NAGA]				= {-3.495, 2.730, -0.380},
			[E_CHARACTER_RACES.RACE_BLOODELF]			= {-4.000, 3.040, -0.405},
			[E_CHARACTER_RACES.RACE_NIGHTBORNE]			= {-3.950, 3.075, -0.615},
			[E_CHARACTER_RACES.RACE_EREDAR]				= {-3.700, 2.880, -0.595},
			[E_CHARACTER_RACES.RACE_ZANDALARITROLL]		= {-3.620, 2.770, -0.555},

			[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= {-3.260, 2.560, -0.290},
			[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= {-3.260, 2.560, -0.290},
			[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= {-3.260, 2.560, -0.290},

			[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= {-3.590, 2.795, 0.090},
		},
		[E_SEX.FEMALE] = {
			[E_CHARACTER_RACES.RACE_HUMAN]				= {-3.955, 3.079, -0.327},
			[E_CHARACTER_RACES.RACE_DWARF]				= {-3.770, 2.943, -0.080},
			[E_CHARACTER_RACES.RACE_NIGHTELF]			= {-3.960, 3.093, -0.520},
			[E_CHARACTER_RACES.RACE_GNOME]				= {-3.585, 2.805, 0.265},
			[E_CHARACTER_RACES.RACE_DRAENEI]			= {-3.910, 3.070, -0.550},
			[E_CHARACTER_RACES.RACE_WORGEN]				= {-3.630, 2.809, -0.555},
			[E_CHARACTER_RACES.RACE_QUELDO]				= {-4.095, 3.190, -0.335},
			[E_CHARACTER_RACES.RACE_VOIDELF]			= {-4.030, 3.145, -0.328},
			[E_CHARACTER_RACES.RACE_DARKIRONDWARF]		= {-3.770, 2.943, -0.080},	-- RACE_DWARF
			[E_CHARACTER_RACES.RACE_LIGHTFORGED]		= {-3.910, 3.070, -0.550},	-- RACE_DRAENEI

			[E_CHARACTER_RACES.RACE_ORC]				= {-3.925, 3.055, -0.385},
			[E_CHARACTER_RACES.RACE_SCOURGE]			= {-3.950, 3.055, -0.265},
			[E_CHARACTER_RACES.RACE_TAUREN]				= {-3.605, 2.805, -0.395},
			[E_CHARACTER_RACES.RACE_TROLL]				= {-3.895, 2.985, -0.575},
			[E_CHARACTER_RACES.RACE_GOBLIN]				= {-3.535, 2.775, 0.060},
			[E_CHARACTER_RACES.RACE_NAGA]				= {-3.675, 2.865, -0.375},
			[E_CHARACTER_RACES.RACE_BLOODELF]			= {-4.050, 3.156, -0.328},
			[E_CHARACTER_RACES.RACE_NIGHTBORNE]			= {-3.935, 3.014, -0.515},
			[E_CHARACTER_RACES.RACE_EREDAR]				= {-3.995, 3.136, -0.550},
			[E_CHARACTER_RACES.RACE_ZANDALARITROLL]		= {-3.850, 2.925, -0.540},

			[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= {-3.275, 2.575, -0.220},
			[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= {-3.275, 2.575, -0.220},
			[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= {-3.275, 2.575, -0.220},

			[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= {-3.590, 2.795, 0.090},
		}
	}
}

local ALL_RACES = {
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_HUMAN},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_DWARF},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_NIGHTELF},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_GNOME},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_DRAENEI},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_WORGEN},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_QUELDO},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_VOIDELF},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_DARKIRONDWARF},
	{factionID = PLAYER_FACTION_GROUP.Alliance, raceID = E_CHARACTER_RACES.RACE_LIGHTFORGED},

	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_ORC},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_SCOURGE},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_TAUREN},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_TROLL},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_GOBLIN},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_NAGA},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_BLOODELF},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_NIGHTBORNE},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_EREDAR},
	{factionID = PLAYER_FACTION_GROUP.Horde, raceID = E_CHARACTER_RACES.RACE_ZANDALARITROLL},

	{factionID = PLAYER_FACTION_GROUP.Neutral, raceID = E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE},
	{factionID = PLAYER_FACTION_GROUP.Neutral, raceID = E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL},
}
local ALLIED_RACES = {
	[E_CHARACTER_RACES.RACE_VOIDELF] = true,
	[E_CHARACTER_RACES.RACE_DARKIRONDWARF] = true,
	[E_CHARACTER_RACES.RACE_LIGHTFORGED] = true,
	[E_CHARACTER_RACES.RACE_NIGHTBORNE] = true,
	[E_CHARACTER_RACES.RACE_EREDAR] = true,
	[E_CHARACTER_RACES.RACE_ZANDALARITROLL] = true,
}
local NEUTRAL_RACES = {
	[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL] = true,
	[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL] = true,
	[E_CHARACTER_RACES.RACE_BLOODELF_DH] = true,
	[E_CHARACTER_RACES.RACE_NIGHTELF_DH] = true,
}
local VULPERA_RACES = {
	[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL] = true,
	[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE] = true,
	[E_CHARACTER_RACES.RACE_VULPERA_HORDE] = true,
}
local PANDAREN_RACES = {
	[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL] = true,
	[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE] = true,
	[E_CHARACTER_RACES.RACE_PANDAREN_HORDE] = true,
}
local OVERRIDE_RACEID = {
	[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL] = E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
	[E_CHARACTER_RACES.RACE_PANDAREN_HORDE] = E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE,
	[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE] = E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
	[E_CHARACTER_RACES.RACE_VULPERA_HORDE] = E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
}

local ALLIED_RACES_UNLOCK = {}
local AVAILABLE_RACES = {}

for _, raceData in ipairs(ALL_RACES) do
	local raceID = OVERRIDE_RACEID[raceData.raceID] or raceData.raceID
	AVAILABLE_RACES[raceID] = true
end

enum:E_CHARACTER_CUSTOMIZATION {
	"SKIN_COLOR",
	"FACE",
	"HAIR",
	"HAIR_COLOR",
	"FACIAL_HAIR",
--	"ARMOR_STYLE"
}

local eventHandler = CreateFrame("Frame")
eventHandler:Hide()
eventHandler:RegisterCustomEvent("GLUE_CHARACTER_CREATE_BACKGROUND_UPDATE")
eventHandler:RegisterCustomEvent("GLUE_CHARACTER_CREATE_VISIBILITY_CHANGED")
eventHandler:SetScript("OnEvent", function(self)
	self:Hide()
	CAMERA_ZOOM_LEVEL = 0
	CAMERA_ZOOM_IN_PROGRESS = false
end)

local function stopZooming()
	if CAMERA_ZOOM_IN_PROGRESS then
		CAMERA_ZOOM_IN_PROGRESS = nil
		eventHandler.elapsed = 0
		FireCustomClientEvent("GLUE_CHARACTER_CREATE_ZOOM_DONE")
	end
end

local function resetModelSettings()
	CAMERA_ZOOM_LEVEL = 0

	if eventHandler:IsShown() then
		eventHandler:Hide()
	else
		stopZooming()
	end
end

C_CharacterCreation = {}

function C_CharacterCreation.IsRaceAvailable(raceID)
	if AVAILABLE_RACES[raceID] then
		if C_CharacterCreation.IsAlliedRace(raceID) then
			return C_CharacterCreation.IsAlliedRacesUnlocked()
		end
		return true
	end
	return false
end

function C_CharacterCreation.IsAlliedRace(raceID)
	return ALLIED_RACES[raceID]
end

function C_CharacterCreation.IsNeutralRace(raceID)
	return NEUTRAL_RACES[raceID]
end

function C_CharacterCreation.IsVulperaRace(raceID)
	return VULPERA_RACES[raceID]
end

function C_CharacterCreation.IsPandarenRace(raceID)
	return PANDAREN_RACES[raceID]
end

function C_CharacterCreation.SetCharCustomizeFrame(frame)
	if type(frame) ~= "table" or not frame.GetObjectType then
		error("Attempt to find 'this' in non-framescript object", 2)
	elseif frame:GetObjectType() ~= "Model" then
		error(string.format("Incorrect object type '%s' (Model object expected)", frame:GetObjectType()), 2)
	end

	MODEL_FRAME = frame
	SetCharCustomizeFrame(frame:GetName())
end

function C_CharacterCreation.GetCharCustomizeFrame()
	return MODEL_FRAME
end

function C_CharacterCreation.SetInCharacterCreate(state)
	IN_CHARACTER_CREATE = state and true or false
	PAID_OVERRIDE_CURRENT_RACE_INDEX = nil
	FireCustomClientEvent("GLUE_CHARACTER_CREATE_VISIBILITY_CHANGED", IN_CHARACTER_CREATE)
end

function C_CharacterCreation.IsInCharacterCreate()
	return IN_CHARACTER_CREATE
end

function C_CharacterCreation.SetModelAlpha(alpha)
	return MODEL_FRAME:SetAlpha(alpha)
end

function C_CharacterCreation.GetModelAlpha()
	return MODEL_FRAME:GetAlpha()
end

function C_CharacterCreation.SetCharacterCreateFacing(degrees)
	return SetCharacterCreateFacing(degrees)
end

function C_CharacterCreation.GetCharacterCreateFacing()
	return GetCharacterCreateFacing()
end

function C_CharacterCreation.GetDefaultCharacterCreateFacing()
	return 0
end

function C_CharacterCreation.IsModelShown()
	return MODEL_FRAME:IsShown() == 1
end

function C_CharacterCreation.ResetCharCustomize()
	ResetCharCustomize()

	SELECTED_SEX = GetSelectedSex()
	SELECTED_RACE = GetSelectedRace()
	SELECTED_CLASS = select(3, GetSelectedClass())

	local changed
	while not C_CharacterCreation.IsRaceAvailable(SELECTED_RACE) do
		SELECTED_RACE = ALL_RACES[math.random(1, #ALL_RACES)].raceID
		changed = true
	end

	if changed then
		SetSelectedRace(SELECTED_RACE)
		SELECTED_RACE = GetSelectedRace()
	end

	resetModelSettings()
end

function C_CharacterCreation.CustomizeExistingCharacter(paidServiceCharacterID)
	CustomizeExistingCharacter(paidServiceCharacterID)

	SELECTED_SEX = GetSelectedSex()
	SELECTED_RACE = GetSelectedRace()
	SELECTED_CLASS = select(3, GetSelectedClass())

	resetModelSettings()
end

function C_CharacterCreation.GenerateRandomName()
	return GetRandomName()
end

function C_CharacterCreation.CreateCharacter(name)
	return CreateCharacter(name)
end

function C_CharacterCreation.IsAlliedRacesUnlocked(raceID)
	return IsGMAccount() or ALLIED_RACES_UNLOCK[raceID] or false
end

function C_CharacterCreation.IsAlliedRacesUnlockedRaw(raceID)
	return ALLIED_RACES_UNLOCK[raceID] or false
end

function C_CharacterCreation.SetAlliedRacesData(unlockData)
	if not unlockData then
		table.wipe(ALLIED_RACES_UNLOCK)
		return
	end

	for _, raceID in ipairs(unlockData) do
		ALLIED_RACES_UNLOCK[tonumber(raceID)] = true
	end
end

function C_CharacterCreation.GetAvailableRacesForCreation()
	return CopyTable(ALL_RACES)
end

function C_CharacterCreation.GetAvailableRaces()
	local t = {GetAvailableRaces()}
	local races = {}
	local index = 0

	for i = 1, #t, 3 do
		index = index + 1
		races[#races + 1] = {
			index = index,
			name = t[i] or "~name~",
			clientFileString = t[i+1],
		}
	end

	return races
end

function C_CharacterCreation.GetAvailableClasses()
	local t = {GetAvailableClasses()}
	local classes = {}
	local index = 0

	for i = 1, #t, 3 do
		index = index + 1
		classes[#classes + 1] = {
			index = index,
			name = t[i] or "~name~",
			clientFileString = t[i+1],
			disabled = index == 10
		}
	end

	return classes
end

function C_CharacterCreation.GetAvailableGenders()
	return {E_SEX.MALE, E_SEX.FEMALE}
end

function C_CharacterCreation.GetFactionForRace(raceID)
	local factionLocalized, faction = GetFactionForRace(raceID)
	return factionLocalized, faction, SERVER_PLAYER_FACTION_GROUP[faction]
end

function C_CharacterCreation.IsRaceClassValid(raceID, classID)
	return IsRaceClassValid(raceID, classID)
end

function C_CharacterCreation.SetSelectedRace(raceID)
	if SELECTED_RACE == raceID then return end

	SetSelectedRace(raceID)
	SELECTED_RACE = GetSelectedRace()

	resetModelSettings()

	return true
end

function C_CharacterCreation.GetSelectedRace()
	return GetSelectedRace()
end

function C_CharacterCreation.SetSelectedClass(classID)
	if SELECTED_CLASS == classID then return end

	SetSelectedClass(classID)
	SELECTED_CLASS = select(3, GetSelectedClass())

	resetModelSettings()

	return true
end

function C_CharacterCreation.GetSelectedClass()
	return GetSelectedClass()
end

function C_CharacterCreation.SetSelectedSex(sexID)
	if SELECTED_SEX == sexID then return end

	SetSelectedSex(sexID)
	SELECTED_SEX = GetSelectedSex()

	return true
end

function C_CharacterCreation.GetSelectedSex()
	return GetSelectedSex()
end

function C_CharacterCreation.RandomizeCharCustomization()
	RandomizeCharCustomization()
end

function C_CharacterCreation.SetCustomizationChoice(optionID, delta)
	CycleCharCustomization(optionID, delta)
end

function C_CharacterCreation.GetAvailableCustomizations()
	local styles = {}

	local facialHair = GetFacialHairCustomization()
	local hair = GetHairCustomization()

	for i = 1, #E_CHARACTER_CUSTOMIZATION do
		local name

		if facialHair ~= "NONE" and i == E_CHARACTER_CUSTOMIZATION.FACIAL_HAIR then
			name = _G["FACIAL_HAIR_"..facialHair]
		else
			if i == E_CHARACTER_CUSTOMIZATION.HAIR then
				name = _G["HAIR_"..hair.."_STYLE"]
			elseif i == E_CHARACTER_CUSTOMIZATION.HAIR_COLOR then
				if hair ~= "VULPERA" then
					name = _G["HAIR_"..hair.."_COLOR"]
				end
			else
				name = _G["CHAR_CUSTOMIZATION"..i.."_DESC"]
			end
		end

		if name then
			styles[#styles + 1] = {orderIndex = i, name = name}
		end
	end

	return styles
end

function C_CharacterCreation.SetCharCustomizeBackground(modelName)
	SetCharCustomizeBackground(modelName)
end

function C_CharacterCreation.GetCreateBackgroundModel()
	return GetCreateBackgroundModel()
end

function C_CharacterCreation.GetSelectedModelName(ignoreOverirde)
	local raceID = C_CharacterCreation.GetSelectedRace()
	local _, className = C_CharacterCreation.GetSelectedClass()

	if className == "DEATHKNIGHT" then
		if raceID == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
			return "Zandalar_DeathKnight"
		elseif C_CharacterCreation.IsPandarenRace(raceID) then
			return "Pandaren_DeathKnight"
		else
			return "DeathKnight"
		end
	elseif C_CharacterCreation.IsVulperaRace(raceID) then
		return "Vulpera"
	elseif C_CharacterCreation.IsPandarenRace(raceID) then
		return "Pandaren"
	end

	if not ignoreOverirde and PAID_SERVICE_TYPE and C_CharacterCreation.GetSelectedRace() == C_CharacterCreation.PaidChange_GetCurrentRaceIndex() then
		local _, _, factionID = C_CharacterCreation.PaidChange_GetCurrentFaction()
		if factionID == SERVER_PLAYER_FACTION_GROUP.Horde then
			if raceID == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
				return "Zandalar_Horde"
			end
			return "Horde"
		elseif factionID == SERVER_PLAYER_FACTION_GROUP.Alliance then
			if raceID == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
				return "Zandalar_Alliance"
			end
			return "Alliance"
		end
	elseif raceID == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
		if PAID_SERVICE_TYPE and select(3, C_CharacterCreation.PaidChange_GetCurrentFaction()) == SERVER_PLAYER_FACTION_GROUP.Alliance then
			return "Zandalar_Alliance"
		end
		return "Zandalar_Horde"
	end

	local factionInfo = S_CHARACTER_RACES_INFO[raceID]
	assert(factionInfo, "C_CharacterCreation.GetSelectedModelName: No info for raceID " .. raceID)

	return PLAYER_FACTION_GROUP[factionInfo.factionID]
end

eventHandler:SetScript("OnHide", stopZooming)
eventHandler:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed < self.duration then
		local xOffset = C_outCirc(self.elapsed, self.startPosition[1], self.endPosition[1], self.duration)
		local yOffset = C_outCirc(self.elapsed, self.startPosition[2], self.endPosition[2], self.duration)
		local zOffset = C_outCirc(self.elapsed, self.startPosition[3], self.endPosition[3], self.duration)

		MODEL_FRAME:SetPosition(xOffset, yOffset, zOffset)
		FireCustomClientEvent("GLUE_CHARACTER_CREATE_ZOOM_UPDATE")
	else
		MODEL_FRAME:SetPosition(self.endPosition[1], self.endPosition[2], self.endPosition[3])
		FireCustomClientEvent("GLUE_CHARACTER_CREATE_ZOOM_UPDATE")
		self:Hide()
	end
end)

local zoomOnMouseWheel = function(self, delta)
	C_CharacterCreation.ZoomCamera(delta > 0 and CAMERA_ZOOM_LEVEL_AMOUNT or -CAMERA_ZOOM_LEVEL_AMOUNT, ZOOM_TIME_SECONDS, true)
end

function C_CharacterCreation.EnableMouseWheel(state)
	if state then
		MODEL_FRAME:EnableMouseWheel(true)
		MODEL_FRAME:SetScript("OnMouseWheel", zoomOnMouseWheel)
	else
		MODEL_FRAME:EnableMouseWheel(false)
		MODEL_FRAME:SetScript("OnMouseWheel", nil)
	end
end

function C_CharacterCreation.GetCameraSettingsDefault()
	local modelName = C_CharacterCreation.GetSelectedModelName()

	if C_CharacterCreation.GetSelectedRace() == E_CHARACTER_RACES.RACE_ZANDALARITROLL then
		if select(2, C_CharacterCreation.GetSelectedClass()) == "DEATHKNIGHT" then
			modelName = "Zandalar_DeathKnight"
		elseif PAID_SERVICE_TYPE and select(3, C_CharacterCreation.PaidChange_GetCurrentFaction()) == SERVER_PLAYER_FACTION_GROUP.Alliance then
			modelName = "Zandalar_Alliance"
		else
			modelName = "Zandalar_Horde"
		end
	end

	local cameraSettings = CHARACTER_CAMERA_SETTINGS[modelName]

	assert(cameraSettings, "C_CharacterCreation.GetCameraSettingsDefault: не найдены настройки камеры для модели " .. tostring(modelName))

	return cameraSettings
end

function C_CharacterCreation.GetCameraSettingsZoomed(sexID, raceID, className)
	sexID = sexID or C_CharacterCreation.GetSelectedSex()
	raceID = raceID or C_CharacterCreation.GetSelectedRace()
	className = className or select(2, C_CharacterCreation.GetSelectedClass())

	local settings = CHARACTER_CREATE_CAMERA_ZOOMED_SETTINGS
	local camera

	if className == "DEATHKNIGHT" then
		if settings[className][sexID] and settings[className][sexID][raceID] then
			camera = settings[className][sexID][raceID]
		end
	elseif settings[sexID] and settings[sexID][raceID] then
		camera = settings[sexID][raceID]
	end

	if not camera then
		error(string.format("C_CharacterCreation.GetCameraSettingsZoomed: No camera info (Race=%s) (Sex=%s) (Class=%s) ", tostring(E_CHARACTER_RACES[raceID]), tostring(E_SEX[sexID]), className), 2)
	end

	if PAID_SERVICE_TYPE and C_CharacterCreation.GetSelectedRace() == C_CharacterCreation.PaidChange_GetCurrentRaceIndex() then
		local modelName = C_CharacterCreation.GetSelectedModelName()
		local defaultModelName = C_CharacterCreation.GetSelectedModelName(true)
		if modelName ~= defaultModelName then
			return {
				[1] = camera[1] + CHARACTER_CAMERA_SETTINGS[modelName][1] - CHARACTER_CAMERA_SETTINGS[defaultModelName][1],
				[2] = camera[2] + CHARACTER_CAMERA_SETTINGS[modelName][2] - CHARACTER_CAMERA_SETTINGS[defaultModelName][2],
				[3] = camera[3] + CHARACTER_CAMERA_SETTINGS[modelName][3] - CHARACTER_CAMERA_SETTINGS[defaultModelName][3],
			}
		end
	end

	return camera
end

local getCameraZoomPosition = function(zoomLevel)
	local startPosition = {MODEL_FRAME:GetPosition()}
	local endPosition

	if zoomLevel <= CAMERA_ZOOM_MIN_LEVEL then
		endPosition = C_CharacterCreation.GetCameraSettingsDefault()
	elseif zoomLevel >= CAMERA_ZOOM_MAX_LEVEL then
		endPosition = C_CharacterCreation.GetCameraSettingsZoomed()
	else
		local zoomedSettings = C_CharacterCreation.GetCameraSettingsZoomed()
		local defaultCamera = C_CharacterCreation.GetCameraSettingsDefault()
		local diff = zoomLevel / CAMERA_ZOOM_MAX_LEVEL

		endPosition = {
			(defaultCamera[1] + (zoomedSettings[1] - defaultCamera[1]) * diff),
			(defaultCamera[2] + (zoomedSettings[2] - defaultCamera[2]) * diff),
			(defaultCamera[3] + (zoomedSettings[3] - defaultCamera[3]) * diff),
		}
	end

	return startPosition, endPosition
end

function C_CharacterCreation.SetCameraZoomLevel(zoomLevel, keepCustomZoom)
	if not C_CharacterCreation.IsModelShown() or not C_CharacterCreation.IsInCharacterCreate() then return end

	zoomLevel = zoomLevel and math.min(CAMERA_ZOOM_MAX_LEVEL, math.max(CAMERA_ZOOM_MIN_LEVEL, zoomLevel)) or 0
	if zoomLevel == CAMERA_ZOOM_LEVEL then return end

	if CAMERA_ZOOM_IN_PROGRESS then
		eventHandler:Hide()
	end

	local _, endPosition = getCameraZoomPosition(zoomLevel)
	MODEL_FRAME:SetPosition(endPosition[1], endPosition[2], endPosition[3])

	CAMERA_ZOOM_LEVEL = zoomLevel

	return true
end

function C_CharacterCreation.ZoomCamera(zoomAmount, zoomTime, force)
	if (CAMERA_ZOOM_IN_PROGRESS and not force)
	or not C_CharacterCreation.IsModelShown()
	or not C_CharacterCreation.IsInCharacterCreate()
	then
		return
	end

	local zoomLevel = CAMERA_ZOOM_LEVEL + zoomAmount
	zoomLevel = math.min(CAMERA_ZOOM_MAX_LEVEL, math.max(CAMERA_ZOOM_MIN_LEVEL, zoomLevel))

	if (zoomLevel == CAMERA_ZOOM_LEVEL and not force)
	or (CAMERA_ZOOM_IN_PROGRESS and not force)
	then
		return
	end

	if zoomTime == 0 then
		return C_CharacterCreation.SetCameraZoomLevel(zoomLevel, force)
	end

	local startPosition, endPosition = getCameraZoomPosition(zoomLevel)

	eventHandler.startPosition = startPosition
	eventHandler.endPosition = endPosition
	eventHandler.duration = zoomTime or ZOOM_TIME_SECONDS
	eventHandler.elapsed = 0
	eventHandler:Show()

	CAMERA_ZOOM_IN_PROGRESS = true
	CAMERA_ZOOM_LEVEL = zoomLevel

	return true
end

function C_CharacterCreation.GetCurrentCameraZoom()
	return CAMERA_ZOOM_LEVEL
end

function C_CharacterCreation.IsZoomInProgress()
	return CAMERA_ZOOM_IN_PROGRESS ~= nil
end

function C_CharacterCreation.GetMaxCameraZoom()
	return CAMERA_ZOOM_MAX_LEVEL
end



function C_CharacterCreation.PaidChange_GetCurrentRaceIndex()
	return PAID_OVERRIDE_CURRENT_RACE_INDEX or PaidChange_GetCurrentRaceIndex()
end

function C_CharacterCreation.PaidChange_GetCurrentFaction()
	if FACTION_OVERRIDE[PAID_SERVICE_CHARACTER_ID] and not PAID_OVERRIDE_CURRENT_RACE_INDEX then
		local factionID = FACTION_OVERRIDE[PAID_SERVICE_CHARACTER_ID]
		local faction = SERVER_PLAYER_FACTION_GROUP[factionID]

		if PLAYER_FACTION_GROUP[faction] == PLAYER_FACTION_GROUP.Renegade then
			return C_CharacterCreation.GetFactionForRace(C_CharacterCreation.PaidChange_GetCurrentRaceIndex())
		end

		local factionLocalized = _G[string.upper(faction)]
		return factionLocalized, faction, factionID
	end
	return C_CharacterCreation.GetFactionForRace(C_CharacterCreation.PaidChange_GetCurrentRaceIndex())
end

function C_CharacterCreation.PaidChange_ChooseFaction(factionID, reverse)
	local raceID = C_CharacterCreation.GetSelectedRace()

	if reverse then
		isHorde = factionID ~= PLAYER_FACTION_GROUP.Horde
	else
		isHorde = factionID == PLAYER_FACTION_GROUP.Horde
	end

	if C_CharacterCreation.IsVulperaRace(raceID) then
		PAID_OVERRIDE_CURRENT_RACE_INDEX = isHorde and E_CHARACTER_RACES.RACE_VULPERA_HORDE or E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE
		C_CharacterCreation.SetSelectedRace(PAID_OVERRIDE_CURRENT_RACE_INDEX)
	elseif C_CharacterCreation.IsPandarenRace(raceID) then
		PAID_OVERRIDE_CURRENT_RACE_INDEX = isHorde and E_CHARACTER_RACES.RACE_PANDAREN_HORDE or E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE
		C_CharacterCreation.SetSelectedRace(PAID_OVERRIDE_CURRENT_RACE_INDEX)
	else
		PAID_OVERRIDE_CURRENT_RACE_INDEX = nil
	end

	if PAID_OVERRIDE_CURRENT_RACE_INDEX then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.GLUE_CHARACTER_CREATE_FORCE_RACE_CHANGE, PAID_OVERRIDE_CURRENT_RACE_INDEX)
	end
end