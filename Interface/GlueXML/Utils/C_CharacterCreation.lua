local MODEL_FRAME
local IN_CHARACTER_CREATE = false

local SELECTED_SEX, SELECTED_RACE, SELECTED_CLASS
local SELECTED_SIGN = 1

PAID_SERVICE_CHARACTER_ID = nil
PAID_SERVICE_TYPE = nil
local PAID_OVERRIDE_CURRENT_RACE_INDEX

local ZODIAC_SIGNS_ENABLED = true

local ZOOM_TIME_SECONDS = 0.75
local CAMERA_ZOOM_LEVEL = 0
local CAMERA_ZOOM_MIN_LEVEL = 0
local CAMERA_ZOOM_MAX_LEVEL = 100
local CAMERA_ZOOM_LEVEL_AMOUNT = 20
local CAMERA_ZOOM_IN_PROGRESS = false
local CAMERA_ZOOM_RESET_BLOCKED = false

local CHARACTER_CUSTOM_FLAG = 0
local CHARACTER_CREATE_DRESSED = true

local CHARACTER_CREATING_NAME

E_CHARACTER_CUSTOMIZATION = Enum.CreateMirror({
	"SKIN_COLOR",
	"FACE",
	"HAIR",
	"HAIR_COLOR",
	"FACIAL_HAIR",
--	"ARMOR_STYLE"
})

local CUSTOM_FLAGS = {
	HARDCORE = 0x1,
}

local INACCESSIBILITY_FLAGS = {
	CREATION			= 0x01,
	CREATION_DK			= 0x02,
	CUSTOMIZATION		= 0x04,
	FACTION_CHANGE		= 0x08,
	RACE_CHANGE			= 0x10,
	BOOST_SERVICE		= 0x20,
}

local RACE_INACCESSIBILITY = {
--	[E_CHARACTER_RACES.RACE_DRACTHYR] = INACCESSIBILITY_FLAGS.CREATION_DK + INACCESSIBILITY_FLAGS.FACTION_CHANGE + INACCESSIBILITY_FLAGS.RACE_CHANGE + INACCESSIBILITY_FLAGS.BOOST_SERVICE,
}

local CLASS_INACCESSIBILITY = {
	[CLASS_ID_DEMONHUNTER] = CLASS_DISABLE_REASON_DEMON_HUNTER
}

local CHARACTER_CREATE_CAMERA_ZOOMED_SETTINGS = {
	[E_SEX.MALE] = {
		[E_CHARACTER_RACES.RACE_HUMAN]					= {-6.525, 5.000, -0.810},
		[E_CHARACTER_RACES.RACE_DWARF]					= {-6.260, 4.820, -0.310},
		[E_CHARACTER_RACES.RACE_NIGHTELF]				= {-6.470, 4.950, -1.145},
		[E_CHARACTER_RACES.RACE_GNOME]					= {-6.000, 4.605, 0.250},
		[E_CHARACTER_RACES.RACE_DRAENEI]				= {-5.945, 4.550, -1.130},
		[E_CHARACTER_RACES.RACE_WORGEN]					= {-5.140, 3.955, -0.770},
		[E_CHARACTER_RACES.RACE_QUELDO]					= {-6.640, 4.955, -0.820},
		[E_CHARACTER_RACES.RACE_VOIDELF]				= {-6.610, 4.935, -0.825},
		[E_CHARACTER_RACES.RACE_DARKIRONDWARF]			= {-6.260, 4.820, -0.310},	-- RACE_DWARF
		[E_CHARACTER_RACES.RACE_LIGHTFORGED]			= {-5.945, 4.550, -1.130},	-- RACE_DRAENEI

		[E_CHARACTER_RACES.RACE_ORC]					= {-5.670, 4.170, -0.860},
		[E_CHARACTER_RACES.RACE_SCOURGE]				= {-6.640, 4.755, -0.475},
		[E_CHARACTER_RACES.RACE_TAUREN]					= {-5.320, 3.910, -0.410},
		[E_CHARACTER_RACES.RACE_TROLL] 					= {-5.650, 4.255, -0.800},
		[E_CHARACTER_RACES.RACE_GOBLIN]					= {-5.865, 4.320, 0.115},
		[E_CHARACTER_RACES.RACE_NAGA]					= {-5.900, 4.375, -0.690},
		[E_CHARACTER_RACES.RACE_BLOODELF]				= {-6.675, 4.835, -0.725},
		[E_CHARACTER_RACES.RACE_NIGHTBORNE]				= {-6.570, 4.880, -1.080},
		[E_CHARACTER_RACES.RACE_EREDAR]					= {-6.150, 4.565, -1.040},
		[E_CHARACTER_RACES.RACE_ZANDALARITROLL]			= {-6.270, 4.570, -0.790},

		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]		= {-4.470, 3.470, -0.400},
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]			= {-4.470, 3.470, -0.400},
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]		= {-4.470, 3.470, -0.400},

		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]		= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]			= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]		= {8.300, 0.105, -0.050},

		[E_CHARACTER_RACES.RACE_DRACTHYR]				= {-8.630, 6.270, -1.245},
	},
	[E_SEX.FEMALE] = {
		[E_CHARACTER_RACES.RACE_HUMAN]					= {-6.700, 5.125, -0.700},
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
		[E_CHARACTER_RACES.RACE_GOBLIN]					= {-5.855, 4.355, 0.065},
		[E_CHARACTER_RACES.RACE_NAGA]					= {-6.105, 4.525, -0.690},
		[E_CHARACTER_RACES.RACE_BLOODELF]				= {-6.770, 5.043, -0.600},
		[E_CHARACTER_RACES.RACE_NIGHTBORNE]				= {-6.585, 4.810, -0.910},
		[E_CHARACTER_RACES.RACE_EREDAR]					= {-6.590, 4.944, -0.965},
		[E_CHARACTER_RACES.RACE_ZANDALARITROLL]			= {-6.590, 4.780, -0.765},

		[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]		= {-4.470, 3.480, -0.305},
		[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]			= {-4.470, 3.480, -0.305},
		[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]		= {-4.470, 3.480, -0.305},

		[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]		= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_HORDE]			= {8.300, 0.105, -0.050},
		[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]		= {8.300, 0.105, -0.050},

		[E_CHARACTER_RACES.RACE_DRACTHYR]				= {-8.700, 6.500, -1.060},
	},
	["DEATHKNIGHT"] = {
		[E_SEX.MALE] = {
			[E_CHARACTER_RACES.RACE_HUMAN]				= {-3.940, 3.070, -0.397},
			[E_CHARACTER_RACES.RACE_DWARF]				= {-3.750, 2.935, -0.100},
			[E_CHARACTER_RACES.RACE_NIGHTELF]			= {-3.925, 3.056, -0.595},
			[E_CHARACTER_RACES.RACE_GNOME]				= {-3.590, 2.805, 0.235},
			[E_CHARACTER_RACES.RACE_DRAENEI]			= {-3.635, 2.835, -0.590},
			[E_CHARACTER_RACES.RACE_WORGEN]				= {-3.125, 2.457, -0.390},
			[E_CHARACTER_RACES.RACE_QUELDO]				= {-4.000, 3.040, -0.405},
			[E_CHARACTER_RACES.RACE_VOIDELF]			= {-3.975, 3.020, -0.405},
			[E_CHARACTER_RACES.RACE_DARKIRONDWARF]		= {-3.750, 2.935, -0.100},	-- RACE_DWARF
			[E_CHARACTER_RACES.RACE_LIGHTFORGED]		= {-3.635, 2.835, -0.590},	-- RACE_DRAENEI

			[E_CHARACTER_RACES.RACE_ORC]				= {-3.430, 2.665, -0.485},
			[E_CHARACTER_RACES.RACE_SCOURGE]			= {-4.015, 3.010, -0.260},
			[E_CHARACTER_RACES.RACE_TAUREN]				= {-3.285, 2.555, -0.225},
			[E_CHARACTER_RACES.RACE_TROLL]				= {-3.450, 2.736, -0.450},
			[E_CHARACTER_RACES.RACE_GOBLIN]				= {-3.565, 2.770, 0.090},
			[E_CHARACTER_RACES.RACE_NAGA]				= {-3.495, 2.730, -0.380},
			[E_CHARACTER_RACES.RACE_BLOODELF]			= {-4.000, 3.040, -0.405},
			[E_CHARACTER_RACES.RACE_NIGHTBORNE]			= {-3.950, 3.075, -0.615},
			[E_CHARACTER_RACES.RACE_EREDAR]				= {-3.700, 2.880, -0.595},
			[E_CHARACTER_RACES.RACE_ZANDALARITROLL]		= {-3.790, 2.900, -0.445},

			[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= {-3.260, 2.560, -0.290},
			[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= {-3.260, 2.560, -0.290},
			[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= {-3.260, 2.560, -0.290},

			[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= {-3.590, 2.795, 0.090},

			[E_CHARACTER_RACES.RACE_DRACTHYR]			= {-4.000, 3.040, -0.405},	-- RACE_BLOODELF
		},
		[E_SEX.FEMALE] = {
			[E_CHARACTER_RACES.RACE_HUMAN]				= {-4.020, 3.127, -0.330},
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
			[E_CHARACTER_RACES.RACE_GOBLIN]				= {-3.535, 2.770, 0.060},
			[E_CHARACTER_RACES.RACE_NAGA]				= {-3.675, 2.865, -0.375},
			[E_CHARACTER_RACES.RACE_BLOODELF]			= {-4.050, 3.156, -0.328},
			[E_CHARACTER_RACES.RACE_NIGHTBORNE]			= {-3.935, 3.014, -0.515},
			[E_CHARACTER_RACES.RACE_EREDAR]				= {-3.995, 3.136, -0.550},
			[E_CHARACTER_RACES.RACE_ZANDALARITROLL]		= {-3.950, 3.007, -0.430},

			[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE]	= {-3.275, 2.575, -0.220},
			[E_CHARACTER_RACES.RACE_PANDAREN_HORDE]		= {-3.275, 2.575, -0.220},
			[E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL]	= {-3.275, 2.575, -0.220},

			[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE]	= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_HORDE]		= {-3.590, 2.795, 0.090},
			[E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL]	= {-3.590, 2.795, 0.090},

			[E_CHARACTER_RACES.RACE_DRACTHYR]			= {-4.020, 3.127, -0.330},	-- RACE_HUMAN
		}
	}
}

if IsInterfaceDevClient(true) then
	_G.CHARACTER_CREATE_CAMERA_ZOOMED_SETTINGS = CHARACTER_CREATE_CAMERA_ZOOMED_SETTINGS
end

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

	{factionID = PLAYER_FACTION_GROUP.Neutral, raceID = E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL},
	{factionID = PLAYER_FACTION_GROUP.Neutral, raceID = E_CHARACTER_RACES.RACE_DRACTHYR},
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
	[E_CHARACTER_RACES.RACE_DRACTHYR] = true,
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
	[E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE] = E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL,
	[E_CHARACTER_RACES.RACE_PANDAREN_HORDE] = E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL,
	[E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE] = E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
	[E_CHARACTER_RACES.RACE_VULPERA_HORDE] = E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL,
}

local ALLIED_RACES_UNLOCK = {}
local AVAILABLE_RACES = {}

for _, raceData in ipairs(ALL_RACES) do
	local raceID = OVERRIDE_RACEID[raceData.raceID] or raceData.raceID
	AVAILABLE_RACES[raceID] = true
end

local ZODIAC_STATUS = {
	SUCCESS = 0,
	UNAVAILABLE = 1,
}

local CUSTOM_FLAG_STATUS = {
	SUCCESS = 0,
	UNAVAILABLE = 1,
}

local CUSTOMIZATION_ZODIAC_STATUS = {
	SUCCESS = 0,
	INVALID_PARAMETERS = 1,
	CHARACTER_NOT_FOUND = 2,
	RACE_LOCKED = 3,
	INVALID_RACE_ID = 4,
	INTERNAL_ERROR = 5,
}

local eventHandler = CreateFrame("Frame")
eventHandler:Hide()
eventHandler:RegisterEvent("UPDATE_STATUS_DIALOG")
eventHandler:RegisterEvent("SERVER_SPLIT_NOTICE")
eventHandler:RegisterCustomEvent("GLUE_CHARACTER_CREATE_BACKGROUND_UPDATE")
eventHandler:RegisterCustomEvent("GLUE_CHARACTER_CREATE_VISIBILITY_CHANGED")
eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "GLUE_CHARACTER_CREATE_BACKGROUND_UPDATE" or event == "GLUE_CHARACTER_CREATE_VISIBILITY_CHANGED" then
		if CAMERA_ZOOM_RESET_BLOCKED then return end

		self:Hide()
		CAMERA_ZOOM_LEVEL = 0
		CAMERA_ZOOM_IN_PROGRESS = false
	elseif event == "UPDATE_STATUS_DIALOG" then
		local text = ...
		if text == CHAR_CREATE_SUCCESS then
			local characterListIndex = C_CharacterList.GetNumPlayableCharacters() + 1
			local characterIndex = characterListIndex % C_CharacterList.GetNumCharactersPerPage()
			local isBoostedCreation = PAID_SERVICE_TYPE == E_PAID_SERVICE.BOOST_SERVICE_NEW

			if characterIndex == 0 then
				characterIndex = C_CharacterList.GetNumCharactersPerPage()
			end

			FireCustomClientEvent("CHARACTER_CREATED", characterIndex, characterListIndex, isBoostedCreation, CHARACTER_CREATING_NAME)
		end
	elseif event == "SERVER_SPLIT_NOTICE" then
		local msg = select(3, ...)
		local prefix, content = string.split(":", msg, 2)

		if prefix == "ASMSG_ALLIED_RACES" then
			for _, raceID in ipairs({StringSplitEx(":", content)}) do
				ALLIED_RACES_UNLOCK[tonumber(raceID)] = true
			end
		elseif prefix == "ASMSG_SERVICE_MSG" then
			table.wipe(ALLIED_RACES_UNLOCK)
		elseif prefix == "SMSG_CHARACTER_CREATION_INFO" then
			local zodiacSignStatus, customFlagStatus = string.split(":", content)
			zodiacSignStatus = tonumber(zodiacSignStatus) or 0
			customFlagStatus = tonumber(customFlagStatus) or 0

			GlueDialog:HideDialog("SERVER_WAITING")

			if zodiacSignStatus == ZODIAC_STATUS.SUCCESS
			and customFlagStatus == CUSTOM_FLAG_STATUS.SUCCESS
			then
				CreateCharacter(CHARACTER_CREATING_NAME)
			else
				local zodiacErrorText
				local customFlagErrorText

				if zodiacSignStatus ~= ZODIAC_STATUS.SUCCESS then
					local err = string.format("CHARACTER_CREATION_INFO_ZODIAC_SIGN_ERROR_%d", zodiacSignStatus)
					zodiacErrorText = _G[err] or string.format("CHARACTER_CREATION_INFO: zodiac sign error #%s", zodiacSignStatus)
				end

				if customFlagStatus ~= CUSTOM_FLAG_STATUS.SUCCESS then
					local err = string.format("CHARACTER_CREATION_INFO_CUSTOM_FLAG_ERROR_%d", customFlagStatus)
					customFlagErrorText = _G[err] or string.format("CHARACTER_CREATION_INFO: flag error #%s", customFlagStatus)
				end

				local errorText
				if zodiacErrorText and customFlagErrorText then
					errorText = string.join("\n", zodiacErrorText, customFlagErrorText)
				else
					errorText = zodiacErrorText or customFlagErrorText
				end

				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			end
		elseif prefix == "SMSG_CHARACTER_ZODIAC" then
			local status = tonumber(content)

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == CUSTOMIZATION_ZODIAC_STATUS.SUCCESS then
				SetGlueScreen("charselect")
			else
				local errorText = _G[string.format("CUSTOMIZATION_ZODIAC_STATUS_%i", status)]
				if errorText then
					GlueDialog:ShowDialog("OKAY_VOID", errorText)
				else
					GlueDialog:ShowDialog("OKAY_VOID", string.format("[ERROR] SMSG_CHARACTER_ZODIAC: error %s", status))
				end
			end
		elseif prefix == "SMSG_CHARACTER_CREATION_STATUS" then
			local status = tonumber(content)
			local errorText = _G[string.format("CHARACTER_CREATION_STATUS_%i", status)]
			if errorText then
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			else
				GlueDialog:ShowDialog("OKAY_VOID", string.format("[ERROR] SMSG_CHARACTER_CREATION_STATUS: error %s", status))
			end
		end
	end
end)

local function stopZooming()
	if not CAMERA_ZOOM_IN_PROGRESS or CAMERA_ZOOM_RESET_BLOCKED then return end

	CAMERA_ZOOM_IN_PROGRESS = false
	eventHandler.elapsed = 0
	FireCustomClientEvent("GLUE_CHARACTER_CREATE_ZOOM_DONE")
end

local function resetModelSettings()
	if CAMERA_ZOOM_RESET_BLOCKED then return end

	CAMERA_ZOOM_LEVEL = 0

	if eventHandler:IsShown() then
		eventHandler:Hide()
	else
		stopZooming()
	end
end

C_CharacterCreation = {}

function C_CharacterCreation.IsRaceAvailable(raceID, skipRaceOverride)
	if not skipRaceOverride and OVERRIDE_RACEID[raceID] then
		raceID = OVERRIDE_RACEID[raceID]
	end
	if AVAILABLE_RACES[raceID] then
		if C_CharacterCreation.IsAlliedRace(raceID) then
			if C_CharacterCreation.IsAlliedRacesUnlocked(raceID) then
				return true
			else
				local raceFile = S_CHARACTER_RACES_INFO[raceID].clientFileString
				local disableReason = RACE_UNAVAILABLE
				local disableReasonInfo = string.format("%s - %s", ALLIED_RACE_DISABLE, _G[string.format("ALLIED_RACE_DISABLE_REASON_%s", raceFile:upper())] or "MISSING")
				return false, disableReason, disableReasonInfo
			end
		end
		return true
	end
	return false, RACE_UNAVAILABLE
end

function C_CharacterCreation.IsAlliedRace(raceID)
	return ALLIED_RACES[raceID]
end

function C_CharacterCreation.IsNeutralBaseRace(raceID)
	return NEUTRAL_RACES[raceID] or VULPERA_RACES[raceID] or PANDAREN_RACES[raceID]
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

function C_CharacterCreation.SetCreateScreen(paidServiceID, characterID)
	if GetCurrentGlueScreenName() == "charcreate" then return end

	local selectedCharacterID = C_CharacterList.GetSelectedCharacter()
	local isSelectedCharacterGhost = selectedCharacterID ~= 0 and select(7, GetCharacterInfo(selectedCharacterID)) == true

	if isSelectedCharacterGhost then
		GlueFFXModel.ghostBugWorkaround = true
		GlueFFXModel:Hide()
	end

	if paidServiceID then
		PAID_SERVICE_TYPE = paidServiceID

		if paidServiceID ~= E_PAID_SERVICE.BOOST_SERVICE_NEW and paidServiceID ~= E_PAID_SERVICE.BOOST_SERVICE then
			C_CharacterCreation.CustomizeExistingCharacter(characterID)
		end
	end

	SetGlueScreen("charcreate")

	if isSelectedCharacterGhost then
		GlueFFXModel:Show()
		GlueFFXModel.ghostBugWorkaround = nil
	end
end

function C_CharacterCreation.SetInCharacterCreate(state)
	IN_CHARACTER_CREATE = state and true or false

	if not IN_CHARACTER_CREATE then
		CAMERA_ZOOM_RESET_BLOCKED = false
		PAID_SERVICE_CHARACTER_ID = nil
		PAID_SERVICE_TYPE = nil
		PAID_OVERRIDE_CURRENT_RACE_INDEX = nil
		CHARACTER_CREATING_NAME = nil

		SELECTED_SIGN = 1
		CHARACTER_CUSTOM_FLAG = 0

		if not CHARACTER_CREATE_DRESSED then
			CHARACTER_CREATE_DRESSED = true
			CharCustomization_Dress()
		end

		local defaultFacing = C_CharacterCreation.GetDefaultCharacterCreateFacing()
		if GetCharacterCreateFacing() ~= defaultFacing then
			SetCharacterCreateFacing(defaultFacing)
		end
	end

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

	local changedRace, changedClass

	while not C_CharacterCreation.IsRaceAvailable(SELECTED_RACE, true) or not C_CharacterCreation.IsRaceClassValid(SELECTED_RACE, SELECTED_CLASS) do
		SELECTED_RACE = ALL_RACES[math.random(1, #ALL_RACES)].raceID
		changedRace = true
	end

	while not C_CharacterCreation.IsClassValid(SELECTED_CLASS) do
		SELECTED_CLASS = math.random(1, #S_CLASS_SORT_ORDER)
		changedClass = true
	end

	if changedRace then
		SetSelectedRace(SELECTED_RACE)
		SELECTED_RACE = GetSelectedRace()
	end

	if changedClass then
		SetSelectedClass(SELECTED_CLASS)
		SELECTED_CLASS = select(3, GetSelectedClass())
	end

	C_CharacterCreation.SetSelectedZodiacSignByRaceID(SELECTED_RACE)

	resetModelSettings()
end

function C_CharacterCreation.CustomizeExistingCharacter(paidServiceCharacterID)
	CustomizeExistingCharacter(paidServiceCharacterID)
	PAID_SERVICE_CHARACTER_ID = paidServiceCharacterID

	SELECTED_SEX = GetSelectedSex()
	SELECTED_RACE = GetSelectedRace()
	SELECTED_CLASS = select(3, GetSelectedClass())
	local paidZodiacRaceID = C_CharacterCreation.PaidChange_GetZodiacRaceID()
	C_CharacterCreation.SetSelectedZodiacSignByRaceID(paidZodiacRaceID ~= 0 and paidZodiacRaceID or SELECTED_RACE)

	resetModelSettings()
end

function C_CharacterCreation.GenerateRandomName()
	return GetRandomName()
end

function C_CharacterCreation.CreateCharacter(name)
	CHARACTER_CREATE_DRESSED = true

	if type(PAID_SERVICE_CHARACTER_ID) == "number" and PAID_SERVICE_CHARACTER_ID > 0 and PAID_SERVICE_CHARACTER_ID < 10 then
		local lastSelectedIndex = tonumber(GetCVar("lastCharacterIndex"))
		if not lastSelectedIndex or PAID_SERVICE_CHARACTER_ID ~= GetCharIDFromIndex(lastSelectedIndex + 1) then
			SetCVar("lastCharacterIndex", PAID_SERVICE_CHARACTER_ID - 1)
		end
	end

	CHARACTER_CREATING_NAME = name

	if C_CharacterCreation.PaidChange_IsActive(true) then
		if C_CharacterList.HasCharacterForcedCustomization(PAID_SERVICE_CHARACTER_ID) then
			local customizationFlags = CharCustomization_GetFlags(PAID_SERVICE_CHARACTER_ID)
			if customizationFlags and bit.band(customizationFlags, CHARACTER_CUSTOMIZE_FLAGS.CUSTOMIZATION) ~= 0 then
				CreateCharacter(CHARACTER_CREATING_NAME, CHARACTER_CUSTOMIZE_FLAGS.CUSTOMIZATION)
				return
			end
		end

		if C_CharacterCreation.PaidChange_CanChangeZodiac() then
			local zodiacRaceID = C_ZodiacSign.GetZodiacSignInfoByIndex(SELECTED_SIGN)
			if zodiacRaceID then
				if zodiacRaceID ~= C_CharacterCreation.PaidChange_GetZodiacRaceID() then
					local characterIndex = C_CharacterList.GetCharacterIndexByID(PAID_SERVICE_CHARACTER_ID)
					local signDBCRaceID = E_CHARACTER_RACES_DBC[E_CHARACTER_RACES[zodiacRaceID]]
					GlueDialog:ShowDialog("SERVER_WAITING", CHAR_ZODIAC_IN_PROGRESS)
					C_GluePackets:SendPacket(C_GluePackets.OpCodes.SendCharacterCustomizationInfo, characterIndex, signDBCRaceID or 0)
				else
					GlueDialog:ShowDialog("OKAY_VOID", CUSTOMIZATION_ZODIAC_ALREADY_SELECTED)
				end
			else
				GlueDialog:ShowDialog("OKAY_VOID", CUSTOMIZATION_ZODIAC_NOT_FOUND)
			end
		else
			local customizationFlag
			if PAID_SERVICE_TYPE == E_PAID_SERVICE.CUSTOMIZATION then
				customizationFlag = CHARACTER_CUSTOMIZE_FLAGS.CUSTOMIZATION
			elseif PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_RACE then
				customizationFlag = CHARACTER_CUSTOMIZE_FLAGS.CHANGE_RACE
			elseif PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_FACTION then
				customizationFlag = CHARACTER_CUSTOMIZE_FLAGS.CHANGE_FACTION
			end

			CreateCharacter(CHARACTER_CREATING_NAME, customizationFlag)
		end
	else
		if C_CharacterCreation.IsZodiacSignsEnabled() or CHARACTER_CUSTOM_FLAG ~= 0 then
			local signDBCRaceID
			local zodiacRaceID = C_ZodiacSign.GetZodiacSignInfoByIndex(SELECTED_SIGN)
			if zodiacRaceID then
				signDBCRaceID = E_CHARACTER_RACES_DBC[E_CHARACTER_RACES[zodiacRaceID]]
			end
			GlueDialog:ShowDialog("SERVER_WAITING", CHAR_CREATE_IN_PROGRESS)
			C_GluePackets:SendPacket(C_GluePackets.OpCodes.SendCharacterCreationInfo, signDBCRaceID or 0, CHARACTER_CUSTOM_FLAG or 0)
		else
			CreateCharacter(CHARACTER_CREATING_NAME)
		end
	end
end

function C_CharacterCreation.SetDressState(state)
	state = not not state
	if state == CHARACTER_CREATE_DRESSED then return end

	if state then
		CharCustomization_Dress()
	else
		CharCustomization_Undress()
	end

	CHARACTER_CREATE_DRESSED = state
	FireCustomClientEvent("GLUE_CHARACTER_CREATE_DRESS_STATE_UPDATE", state)
end

function C_CharacterCreation.IsDressed()
	return CHARACTER_CREATE_DRESSED
end

function C_CharacterCreation.CanCreateHardcoreCharacter()
	return C_Service.IsHardcoreEnabledOnRealm()
end

function C_CharacterCreation.SetHardcoreFlag(state)
	if C_CharacterCreation.CanCreateHardcoreCharacter() then
		if state then
			CHARACTER_CUSTOM_FLAG = bit.bor(CHARACTER_CUSTOM_FLAG, CUSTOM_FLAGS.HARDCORE)
		else
			CHARACTER_CUSTOM_FLAG = bit.bxor(CHARACTER_CUSTOM_FLAG, CUSTOM_FLAGS.HARDCORE)
		end

		FireCustomClientEvent("GLUE_CHARACTER_CREATE_UPDATE_CLASSES")
	end
end

function C_CharacterCreation.GetHardcoreFlag()
	if C_CharacterCreation.CanCreateHardcoreCharacter() then
		return bit.band(CHARACTER_CUSTOM_FLAG, CUSTOM_FLAGS.HARDCORE) ~= 0
	else
		return false
	end
end

function C_CharacterCreation.IsAlliedRacesUnlocked(raceID, skipGMCheck)
	if not skipGMCheck and IsGMAccount() then
		return true
	end
	return ALLIED_RACES_UNLOCK[raceID] or false
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
	local classInfo = {GetAvailableClasses()}
	local classes = {}
	local classID = 0

	for i = 1, #classInfo, 3 do
		classID = classID + 1

		local hidden
		if classID == CLASS_ID_DEMONHUNTER then
			hidden = true
		end

		if not hidden then
			classes[#classes + 1] = {
				classID = classID,
				name = classInfo[i] or classInfo[i + 1] or string.format("[%i] NO CLASS NAME", classID),
				clientFileString = classInfo[i + 1],
			}
		end
	end

	return classes
end

function C_CharacterCreation.GetAvailableGenders()
	return {E_SEX.MALE, E_SEX.FEMALE}
end

function C_CharacterCreation.GetFactionForRace(raceID)
	local factionLocalized, faction = GetFactionForRace(raceID)
	return factionLocalized, faction, SERVER_PLAYER_FACTION_GROUP[faction], PLAYER_FACTION_GROUP[faction]
end

function C_CharacterCreation.IsRaceClassValid(raceID, classID)
	local valid, disabledReason = C_CharacterCreation.IsClassValid(classID)
	if not valid then
		return false, disabledReason
	end

	if RACE_INACCESSIBILITY[raceID] and not IsGMAccount() then
		if bit.band(RACE_INACCESSIBILITY[raceID], INACCESSIBILITY_FLAGS.CREATION) ~= 0 then
			return false, string.format(RACE_DISABLE_REASON_REALM, _G[S_CHARACTER_RACES_INFO[raceID].raceName])
		elseif classID == CLASS_ID_DEATHKNIGHT and bit.band(RACE_INACCESSIBILITY[raceID], INACCESSIBILITY_FLAGS.CREATION_DK) ~= 0 then
			return false, RACE_DISABLE_REASON_REALM_DEATH_KNIGHT
		end
	end

	if IsRaceClassValid(raceID, classID) ~= 1 then
		return false, RACE_DISABLE_CLASS_COMBINATION
	end

	return true, nil
end

function C_CharacterCreation.IsClassValid(classID)
	if C_CharacterCreation.PaidChange_IsActive() then
		return true
	end

	local disabledReason

	if CLASS_INACCESSIBILITY[classID] then
		disabledReason = CLASS_INACCESSIBILITY[classID]
	elseif classID == CLASS_ID_DEATHKNIGHT and not C_CharacterList.CanCreateDeathKnight() then
		disabledReason = CLASS_DISABLE_REASON_DEATH_KNIGHT
	elseif classID == CLASS_ID_DEATHKNIGHT and C_CharacterCreation.GetHardcoreFlag() then
		disabledReason = CLASS_DISABLE_REASON_DEATH_KNIGHT_HARDCORE
	end

	return disabledReason == nil, disabledReason
end

function C_CharacterCreation.SetSelectedRace(raceID)
	if SELECTED_RACE == raceID then return end

	SetSelectedRace(raceID)
	SELECTED_RACE = GetSelectedRace()
	C_CharacterCreation.SetSelectedZodiacSignByRaceID(SELECTED_RACE)

	if not C_CharacterCreation.IsRaceClassValid(raceID, SELECTED_CLASS) then
		while true do
			local classID = math.random(1, S_MAX_CLASSES)

			if classID ~= SELECTED_CLASS
			and not CLASS_INACCESSIBILITY[classID]
			and C_CharacterCreation.IsRaceClassValid(raceID, classID)
			then
				SetSelectedClass(classID)
				SELECTED_CLASS = classID
				break
			end
		end
	end

	if C_CharacterCreation.PaidChange_GetCurrentRaceIndex() == SELECTED_RACE then
		if SELECTED_SEX ~= GetSelectedSex() then
			SetSelectedSex(SELECTED_SEX)
		end
	end

	resetModelSettings()

	if not CHARACTER_CREATE_DRESSED then
		CharCustomization_Undress()
	end

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

	if not CHARACTER_CREATE_DRESSED then
		CharCustomization_Undress()
	end

	return true
end

function C_CharacterCreation.GetSelectedClass()
	return GetSelectedClass()
end

function C_CharacterCreation.SetSelectedSex(sexID)
	if SELECTED_SEX == sexID then return end

	SetSelectedSex(sexID)
	SELECTED_SEX = GetSelectedSex()

	if not CHARACTER_CREATE_DRESSED then
		CharCustomization_Undress()
	end

	return true
end

function C_CharacterCreation.GetSelectedSex()
	return GetSelectedSex()
end

function C_CharacterCreation.RandomizeCharCustomization()
	RandomizeCharCustomization()

	if not CHARACTER_CREATE_DRESSED then
		CharCustomization_Undress()
	end
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
			if SELECTED_RACE == E_CHARACTER_RACES.RACE_NIGHTELF and SELECTED_SEX == E_SEX.FEMALE then
				name = FACIAL_HAIR_FEATURES_EARS
			elseif SELECTED_RACE == E_CHARACTER_RACES.RACE_DRACTHYR then
				if SELECTED_SEX == E_SEX.MALE then
					name = FACIAL_HAIR_DRACTHYR
				else
					name = FACIAL_HAIR_FEATURES_HORNS
				end
			else
				name = _G["FACIAL_HAIR_"..facialHair]
			end
		else
			if i == E_CHARACTER_CUSTOMIZATION.SKIN_COLOR and SELECTED_RACE == E_CHARACTER_RACES.RACE_DRACTHYR then
				name = SKIN_COLOR_DRACTHYR
			elseif i == E_CHARACTER_CUSTOMIZATION.SKIN_COLOR and SELECTED_RACE == E_CHARACTER_RACES.RACE_ZANDALARITROLL and SELECTED_SEX == E_SEX.MALE then
				name = SKIN_COLOR_ZANDALARITROLL
			elseif i == E_CHARACTER_CUSTOMIZATION.FACE and SELECTED_RACE == E_CHARACTER_RACES.RACE_DRACTHYR then
				name = FACIAL_FACE_DRACTHYR
			elseif i == E_CHARACTER_CUSTOMIZATION.HAIR then
				name = _G["HAIR_"..hair.."_STYLE"]
			elseif i == E_CHARACTER_CUSTOMIZATION.HAIR_COLOR then
				if hair == "VULPERA"
				or (C_CharacterCreation.IsPandarenRace(SELECTED_RACE) and SELECTED_SEX == E_SEX.MALE)
				then
					name = HAIR_NORMAL_EYES_COLOR
				else
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

function C_CharacterCreation.IsZodiacSignsEnabled()
	return ZODIAC_SIGNS_ENABLED
end

function C_CharacterCreation.CanChangeZodiacSign()
	if C_CharacterCreation.PaidChange_IsActive(true) then
		return C_CharacterCreation.PaidChange_CanChangeZodiac()
	end
	return true
end

function C_CharacterCreation.GetSelectedZodiacSign()
	return SELECTED_SIGN or 1
end

function C_CharacterCreation.SetSelectedZodiacSign(signIndex)
	if type(signIndex) ~= "number" then
		error(string.format("bad argument #1 to 'C_CharacterCreation.SetSelectedZodiacSign' (number expected, got %s)", type(signIndex)), 2)
	elseif signIndex <= 0 and signIndex > C_ZodiacSign.GetNumZodiacSigns() then
		error(string.format("Zodiac sign id out or range `%s`", signIndex), 2)
	end

	if signIndex ~= SELECTED_SIGN then
		SELECTED_SIGN = signIndex
		FireCustomClientEvent("GLUE_CHARACTER_CREATE_ZODIAC_SELECTED", signIndex)
	end
end

function C_CharacterCreation.SetSelectedZodiacSignByRaceID(raceID)
	if type(raceID) ~= "number" then
		error(string.format("bad argument #1 to 'C_CharacterCreation.SetSelectedZodiacSignByRaceID' (number expected, got %s)", type(raceID)), 2)
	end

	if OVERRIDE_RACEID[raceID] then
		raceID = OVERRIDE_RACEID[raceID]
	end

	local index = C_ZodiacSign.GetZodiacSignIndexByRaceID(raceID)
	if index then
		SELECTED_SIGN = index
		FireCustomClientEvent("GLUE_CHARACTER_CREATE_ZODIAC_SELECTED", index)
		return
	end

	error(string.format("Zodiac sign with race id `%d` not found", raceID), 2)
end

function C_CharacterCreation.GetNumZodiacSigns()
	return C_ZodiacSign.GetNumZodiacSigns()
end

function C_CharacterCreation.IsSignAvailable(signIndex)
	if type(signIndex) ~= "number" then
		error(string.format("bad argument #1 to 'C_CharacterCreation.IsSignAvailable' (number expected, got %s)", type(signIndex)), 2)
	elseif signIndex <= 0 and signIndex > C_ZodiacSign.GetNumZodiacSigns() then
		error(string.format("Zodiac sign id out or range `%s`", signIndex), 2)
	end

	local zodiacRaceID, name, description, icon, atlas = C_ZodiacSign.GetZodiacSignInfoByIndex(signIndex)

	if C_CharacterCreation.PaidChange_CanChangeZodiac() and zodiacRaceID == C_CharacterCreation.PaidChange_GetZodiacRaceID() then
		return false, ZODIAC_SIGN_DISABLE, CUSTOMIZATION_ZODIAC_ALREADY_SELECTED
	end

	local isAvailable, disableReason, disableReasonInfo = C_CharacterCreation.IsRaceAvailable(zodiacRaceID)
	if not isAvailable then
		local raceFile = S_CHARACTER_RACES_INFO[zodiacRaceID].clientFileString
		local requirement = _G[string.format("ALLIED_RACE_DISABLE_REASON_%s", raceFile:upper())] or "MISSING"
		disableReason = ZODIAC_SIGN_DISABLE
		disableReasonInfo = string.format("%s - %s", string.format(ALLIED_RACE_SIGN_DISABLE, name), requirement)
	end

	return isAvailable, disableReason, disableReasonInfo
end

function C_CharacterCreation.GetZodiacSignInfo(signIndex)
	if type(signIndex) ~= "number" then
		error(string.format("bad argument #1 to 'C_CharacterCreation.GetZodiacSignInfo' (number expected, got %s)", type(signIndex)), 2)
	elseif signIndex <= 0 and signIndex > C_ZodiacSign.GetNumZodiacSigns() then
		error(string.format("Zodiac sign id out or range `%s`", signIndex), 2)
	end

	local zodiacRaceID, name, description, icon, atlas = C_ZodiacSign.GetZodiacSignInfoByIndex(signIndex)
	local available = C_CharacterCreation.IsRaceAvailable(zodiacRaceID)
	return zodiacRaceID, name, description, icon, atlas, available
end

function C_CharacterCreation.GetZodiacSignInfoByRaceID(raceID)
	if type(raceID) ~= "number" then
		error(string.format("bad argument #1 to 'C_CharacterCreation.GetZodiacSignInfoByRaceID' (number expected, got %s)", type(raceID)), 2)
	elseif raceID <= 0 and raceID > C_ZodiacSign.GetNumZodiacSigns() then
		error(string.format("Zodiac sign id out or range `%s`", raceID), 2)
	end

	if OVERRIDE_RACEID[raceID] then
		raceID = OVERRIDE_RACEID[raceID]
	end

	local index = C_ZodiacSign.GetZodiacSignIndexByRaceID(raceID)
	if index then
		return C_CharacterCreation.GetZodiacSignInfo(index)
	end

	error(string.format("Zodiac sign with race id `%d` not found", raceID), 2)
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
	elseif raceID == E_CHARACTER_RACES.RACE_DRACTHYR then
		return "Dracthyr"
	elseif C_CharacterCreation.IsVulperaRace(raceID) then
		return "Vulpera"
	elseif C_CharacterCreation.IsPandarenRace(raceID) then
		return "Pandaren"
	end

	if not ignoreOverirde and C_CharacterCreation.PaidChange_IsActive(true) and C_CharacterCreation.GetSelectedRace() == C_CharacterCreation.PaidChange_GetCurrentRaceIndex() then
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
		if C_CharacterCreation.PaidChange_IsActive(true) and select(3, C_CharacterCreation.PaidChange_GetCurrentFaction()) == SERVER_PLAYER_FACTION_GROUP.Alliance then
			return "Zandalar_Alliance"
		end
		return "Zandalar_Horde"
	end

	local factionInfo = S_CHARACTER_RACES_INFO[raceID]
	if type(factionInfo) ~= "table" then
		error(string.format("C_CharacterCreation.GetSelectedModelName: No faction info for raceID [%s]", raceID), 2)
	end

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
		elseif C_CharacterCreation.PaidChange_IsActive(true) and select(3, C_CharacterCreation.PaidChange_GetCurrentFaction()) == SERVER_PLAYER_FACTION_GROUP.Alliance then
			modelName = "Zandalar_Alliance"
		else
			modelName = "Zandalar_Horde"
		end
	end

	local cameraSettings = CHARACTER_CAMERA_SETTINGS[modelName]
	if type(cameraSettings) ~= "table" then
		error(string.format("C_CharacterCreation.GetCameraSettingsDefault(): No camera settings was found for model [%s]", tostring(modelName)), 2)
	end

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

	if C_CharacterCreation.PaidChange_IsActive(true) and C_CharacterCreation.GetSelectedRace() == C_CharacterCreation.PaidChange_GetCurrentRaceIndex() then
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
	return CAMERA_ZOOM_IN_PROGRESS
end

function C_CharacterCreation.GetMaxCameraZoom()
	return CAMERA_ZOOM_MAX_LEVEL
end

function C_CharacterCreation.SetCameraPosition(cameraPosition)
	return MODEL_FRAME:SetPosition(unpack(cameraPosition, 1, 3))
end

function C_CharacterCreation.GetCameraPosition()
	return {MODEL_FRAME:GetPosition()}
end

function C_CharacterCreation.SetBlockCameraReset(isBlocked)
	CAMERA_ZOOM_RESET_BLOCKED = not not isBlocked
end



function C_CharacterCreation.PaidChange_IsActive(ignoreBoostNewCharater)
	if PAID_SERVICE_TYPE ~= nil then
		if ignoreBoostNewCharater then
			return PAID_SERVICE_TYPE ~= E_PAID_SERVICE.BOOST_SERVICE_NEW
		else
			return true
		end
	end
	return false
end

function C_CharacterCreation.PaidChange_GetName()
	return PaidChange_GetName() or ""
end

function C_CharacterCreation.PaidChange_GetCurrentClassIndex()
	return PaidChange_GetCurrentClassIndex()
end

function C_CharacterCreation.PaidChange_GetCurrentRaceIndex()
	return PAID_OVERRIDE_CURRENT_RACE_INDEX or PaidChange_GetCurrentRaceIndex()
end

function C_CharacterCreation.PaidChange_GetPreviousRaceIndex()
	return PaidChange_GetPreviousRaceIndex()
end

function C_CharacterCreation.PaidChange_GetCurrentFaction()
	local factionOverrideID, factionOverrideGroup = C_CharacterList.GetCharacterFactionOverride(PAID_SERVICE_CHARACTER_ID)
	if factionOverrideID and not PAID_OVERRIDE_CURRENT_RACE_INDEX then
		if PLAYER_FACTION_GROUP[factionOverrideGroup] == PLAYER_FACTION_GROUP.Renegade then
			return C_CharacterCreation.GetFactionForRace(C_CharacterCreation.PaidChange_GetCurrentRaceIndex())
		end

		local factionLocalized = _G[string.upper(factionOverrideGroup)]
		return factionLocalized, factionOverrideGroup, factionOverrideID, PLAYER_FACTION_GROUP[factionOverrideGroup]
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
		FireCustomClientEvent("GLUE_CHARACTER_CREATE_FORCE_RACE_CHANGE", PAID_OVERRIDE_CURRENT_RACE_INDEX)
	end
end

function C_CharacterCreation.IsServicesAvailableForRace(serviceType, raceID)
	assert(serviceType, "IsServicesAvailableForRace: no service type")
	assert(raceID, "IsServicesAvailableForRace: no race id")

	if serviceType == E_PAID_SERVICE.BOOST_SERVICE_NEW then
		return true
	end

	if RACE_INACCESSIBILITY[raceID] and not IsGMAccount() then
		if serviceType == E_PAID_SERVICE.CUSTOMIZATION then
			return bit.band(RACE_INACCESSIBILITY[raceID], INACCESSIBILITY_FLAGS.CUSTOMIZATION) == 0
		elseif serviceType == E_PAID_SERVICE.CHANGE_RACE then
			return bit.band(RACE_INACCESSIBILITY[raceID], INACCESSIBILITY_FLAGS.RACE_CHANGE) == 0
		elseif serviceType == E_PAID_SERVICE.CHANGE_FACTION then
			return bit.band(RACE_INACCESSIBILITY[raceID], INACCESSIBILITY_FLAGS.FACTION_CHANGE) == 0
		elseif serviceType == E_PAID_SERVICE.BOOST_SERVICE then
			return bit.band(RACE_INACCESSIBILITY[raceID], INACCESSIBILITY_FLAGS.BOOST_SERVICE) == 0
		end
	end

	return true
end

function C_CharacterCreation.PaidChange_CanChangeZodiac()
	if C_CharacterCreation.IsZodiacSignsEnabled() and C_CharacterCreation.PaidChange_IsActive(true) and PAID_SERVICE_TYPE == E_PAID_SERVICE.CHANGE_ZODIAC and PAID_SERVICE_CHARACTER_ID then
		return C_CharacterList.CanCharacterChangeZodiac(PAID_SERVICE_CHARACTER_ID)
	end
	return false
end

function C_CharacterCreation.PaidChange_GetZodiacRaceID()
	if C_CharacterCreation.PaidChange_CanChangeZodiac() then
		return C_CharacterList.GetCharacterZodiacRaceID(PAID_SERVICE_CHARACTER_ID)
	end
	return 0
end