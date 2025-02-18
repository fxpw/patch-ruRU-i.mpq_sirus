local _G = _G
local error = error
local ipairs = ipairs
local pairs = pairs
local rawset = rawset
local type = type
local tonumber = tonumber
local mathrandom = math.random
local strformat, strlower, strsplit, strupper = string.format, string.lower, string.split, string.upper
local tIndexOf, tinsert, twipe = tIndexOf, table.insert, table.wipe

local ApplyBarberShopStyle = ApplyBarberShopStyle
local BarberShopReset = BarberShopReset
local CanAlterSkin = CanAlterSkin
local CancelBarberShop = CancelBarberShop
local GetBarberShopTotalCost = GetBarberShopTotalCost
local GetFacialHairCustomization = GetFacialHairCustomization
local GetHairCustomization = GetHairCustomization
local SetNextBarberShopStyle = SetNextBarberShopStyle
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitRace = UnitRace
local UnitSex = UnitSex

local Barbershop_Dress = Barbershop_Dress
local Barbershop_Undress = Barbershop_Undress
local C_Camera = C_Camera
local CopyTable = CopyTable
local FireCustomClientEvent = FireCustomClientEvent
local SendServerMessage = SendServerMessage
local geterrorhandler = geterrorhandler

local EMPTY_HAIR_COLOR = EMPTY_HAIR_COLOR
local ERR_NOT_ENOUGH_GOLD = ERR_NOT_ENOUGH_GOLD
local E_CHARACTER_RACES = E_CHARACTER_RACES
local E_SEX = E_SEX
local FACIAL_HAIR_FEATURES_EARS = FACIAL_HAIR_FEATURES_EARS
local SKIN_COLOR = SKIN_COLOR
local STATUS_MESSAGE_INVALID_PARAMETERS = STATUS_MESSAGE_INVALID_PARAMETERS
local S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC = S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC
local UNKNOWN = UNKNOWN

local PRIVATE = {
	ACTIVE = false,
	LOADED = false,
	LOADED_SEX = nil,
	USE_OLD_API = false,
	ACTIVE_MODE = nil,
	DRESSED = true,

	CUSTOMIZATION_OPTION_DISPLAY_MAP = {},
	CUSTOMIZATION_OPTIONS = {},
	CUSTOMIZATION_OPTION_ARRAYS = {},
	CUSTOMIZATION_OPTION_MAP = {},

	ORIGINAL_CUSTOMIZATION_DISPLAY_ID = nil,
	QUEUED_CUSTOMIZATION_DISPLAY_ID = nil,
	CURRENT_CUSTOMIZATION_DISPLAY_ID = nil,

	CURRENT_CUSTOMIZATION_OPTION = {},
	CURRENT_CUSTOMIZATION_TYPE = nil,

	CURRENT_COST = nil,
	IS_ALTERED_FORM_ENABLED = false,
}

local ANY_SEX_DISPLAY_ID = 2
local RACE_CUSTOMIZATION_TYPES = {
	DRACTHYR = {
		SOURCE = BARBERSHOP_DRACTHYR_DISPLAYS,
		DATA_INDEXES = {
			DISPLAY_ID	= 1,
			SEX			= 2,
			OPTION_1	= 3,	-- SKIN
			OPTION_2	= 4,	-- EYES
			OPTION_3	= 5,	-- HORNS_ARMOR
		},
		DATA_OPTION_INDEXES = {
			[1] = 3,
			[2] = 4,
			[3] = 5,
		},

		OPTIONS = {
			{id = 1, name = SKIN_COLOR, hidden = true},
			{id = 2, name = CUSTOMIZATION_OPTION_EYES_COLOR},
			{id = 3, name = CUSTOMIZATION_OPTION_HORNS_ARMOR},
		},

		DEFAULT_FORM = {id = 1, name = CUSTOMIZATION_FORM_VISAGE,	atlasSex = "raceicon-round-dracthyrvisage-%s"},
		ALTERED_FORM = {id = 2, name = CUSTOMIZATION_FORM_DRACTHYR,	atlasSex = "raceicon-round-dracthyr-%s"},
	},
}

Enum.CustomBarberShop = {
	UpdateStatus = {
		Success = 0,
		Error = 1,
	},
	SaveStatus = {
		Success = 0,
		Error = 1,
		NotEnoughMoney = 2,
	},
	Mode = {
		Default = 1,
		Advanced = 2,
	}
}

PRIVATE.EventHanlder = CreateFrame("Frame")
PRIVATE.EventHanlder:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.EventHanlder:RegisterEvent("BARBER_SHOP_OPEN")
PRIVATE.EventHanlder:RegisterEvent("BARBER_SHOP_CLOSE")
PRIVATE.EventHanlder:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, msg, distribution, sender = ...
		if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
			return
		end

		if prefix == "ASMSG_ACTIVATE_DRESSROOM" then
			local mode, displayID = strsplit("|", msg)
			mode = tonumber(mode)

			local modeChanged = not PRIVATE.ACTIVE or PRIVATE.AWAIT_MODE_CHANGE ~= mode
			PRIVATE.AWAIT_MODE_CHANGE = nil

			if PRIVATE.ACTIVE and not modeChanged and mode == PRIVATE.ACTIVE_MODE then
				FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODE_CHANGED")
				FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_READY")
				FireCustomClientEvent("CUSTOM_BARBER_SHOP_READY")
				return
			end

			if mode == Enum.CustomBarberShop.Mode.Default then
				local forceUpdateOptions

				if PRIVATE.ACTIVE and modeChanged then
					PRIVATE.Deactivate()
					forceUpdateOptions = true
				end

				local race = PRIVATE.GetPlayerRace()
				local raceData = RACE_CUSTOMIZATION_TYPES[race]
				if raceData then
					PRIVATE.CURRENT_CUSTOMIZATION_TYPE = raceData
				end

				PRIVATE.USE_OLD_API = true
				PRIVATE.ACTIVE_MODE = mode
				PRIVATE.ACTIVE = true

				FireCustomClientEvent("CUSTOM_BARBER_SHOP_ENTER", not PRIVATE.USE_OLD_API)
				if modeChanged then
					FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODE_CHANGED")
				end
				FireCustomClientEvent("CUSTOM_BARBER_SHOP_READY")

				if forceUpdateOptions then
					FireCustomClientEvent("CUSTOM_BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE")
				end
			elseif mode == Enum.CustomBarberShop.Mode.Advanced then
				displayID = tonumber(displayID)

				local forceUpdateOptions

				if PRIVATE.ACTIVE and modeChanged then
					forceUpdateOptions = true
				end

				PRIVATE.ORIGINAL_CUSTOMIZATION_DISPLAY_ID = displayID
				PRIVATE.USE_OLD_API = false
				PRIVATE.ACTIVE_MODE = mode
				PRIVATE.ACTIVE = true
				PRIVATE.IS_ALTERED_FORM_ENABLED = true

				local race = PRIVATE.GetPlayerRace()
				local raceData = RACE_CUSTOMIZATION_TYPES[race]
				if not raceData then
					geterrorhandler()(strformat("C_BarberShop: No customization data for [%s] race", race))
					return
				end

				PRIVATE.CURRENT_CUSTOMIZATION_TYPE = raceData

				local success = PRIVATE.LoadRaceData(raceData)
				if success then
					local customizationData = PRIVATE.CUSTOMIZATION_OPTION_DISPLAY_MAP[displayID]
					if not customizationData then
						PRIVATE.Exit()
						geterrorhandler()(strformat("C_BarberShop: No customization data for displayID [%i]", displayID))
						return
					end

					PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID = displayID

					twipe(PRIVATE.CURRENT_CUSTOMIZATION_OPTION)

					for optionIndex, dataIndex in ipairs(raceData.DATA_OPTION_INDEXES) do
						PRIVATE.CURRENT_CUSTOMIZATION_OPTION[optionIndex] = customizationData[dataIndex]
					end

					FireCustomClientEvent("CUSTOM_BARBER_SHOP_ENTER", not PRIVATE.USE_OLD_API)
					if modeChanged then
						FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODE_CHANGED")
					end
					FireCustomClientEvent("CUSTOM_BARBER_SHOP_READY")

					if forceUpdateOptions then
						FireCustomClientEvent("CUSTOM_BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE")
					end
				else
					PRIVATE.Exit()
					GMError(strformat("C_BarberShop: Unknown error while loading race data for [%s]", race))
				end
			else
				PRIVATE.Exit()
				geterrorhandler()(strformat("C_BarberShop: Unknown Barbershop mode %i", mode))
			end
		elseif prefix == "ASMSG_CLOSE_DRESSROOM" then
			PRIVATE.Exit(true)
		elseif prefix == "ASMSG_UPDATE_DRESSROOM" then
			if not PRIVATE.ACTIVE or PRIVATE.USE_OLD_API then return end

			local status, price = strsplit("|", msg)

			if tonumber(status) == Enum.CustomBarberShop.UpdateStatus.Error then
				UIErrorsFrame:AddMessage(STATUS_MESSAGE_INVALID_PARAMETERS, 1.0, 0.1, 0.1, 1.0);
			end

			if PRIVATE.QUEUED_CUSTOMIZATION_DISPLAY_ID then
				for optionIndex, dataIndex in ipairs(PRIVATE.CURRENT_CUSTOMIZATION_TYPE.DATA_OPTION_INDEXES) do
					PRIVATE.CURRENT_CUSTOMIZATION_OPTION[optionIndex] = PRIVATE.CUSTOMIZATION_OPTION_DISPLAY_MAP[PRIVATE.QUEUED_CUSTOMIZATION_DISPLAY_ID][dataIndex]
				end

				PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID = PRIVATE.QUEUED_CUSTOMIZATION_DISPLAY_ID
				PRIVATE.QUEUED_CUSTOMIZATION_DISPLAY_ID = nil
			end

			PRIVATE.CURRENT_COST = tonumber(price)

			FireCustomClientEvent("CUSTOM_BARBER_SHOP_UPDATE_DRESSROOM")
			FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_READY")
			FireCustomClientEvent("CUSTOM_BARBER_SHOP_READY")
		elseif prefix == "ASMSG_SAVE_DRESSROOM" then
			local status = tonumber(msg)

			if status == Enum.CustomBarberShop.SaveStatus.Error then
				UIErrorsFrame:AddMessage(STATUS_MESSAGE_INVALID_PARAMETERS, 1.0, 0.1, 0.1, 1.0);
			elseif status == Enum.CustomBarberShop.SaveStatus.NotEnoughMoney then
				UIErrorsFrame:AddMessage(ERR_NOT_ENOUGH_GOLD, 1.0, 0.1, 0.1, 1.0);
			elseif status == Enum.CustomBarberShop.SaveStatus.Success then
				PRIVATE.ORIGINAL_CUSTOMIZATION_DISPLAY_ID = PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID
				PRIVATE.Exit()
			end
		end
	elseif event == "BARBER_SHOP_OPEN" then
		C_Camera.SetCameraView(C_Camera.Presets.BarberShop)

		if not PRIVATE.DRESSED then
			Barbershop_Undress()
		end

		FireCustomClientEvent("CUSTOM_BARBER_SHOP_PRICE_CHANGED")
		FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_READY")
	elseif event == "BARBER_SHOP_CLOSE" then
		if PRIVATE.ACTIVE and PRIVATE.USE_OLD_API then	-- client forcefuly close by itself
			securecall(PRIVATE.HideDialogs)
			PRIVATE.Deactivate()

			SendServerMessage("ACMSG_DEACTIVATE_DRESSROOM")
			FireCustomClientEvent("CUSTOM_BARBER_SHOP_EXIT")
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		if PRIVATE.ACTIVE and not PRIVATE.USE_OLD_API then
			local unit = ...
			if UnitIsUnit(unit, "player") then
				C_Camera.SetCameraView(C_Camera.Presets.BarberShopAlt)

				self:UnregisterEvent(event)
				FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_READY")
			end
		else
			self:UnregisterEvent(event)
		end
	end
end)

PRIVATE.HasAnyChanges = function()
	if not PRIVATE.ACTIVE then return end

	if PRIVATE.USE_OLD_API then
		return GetBarberShopTotalCost() ~= 0
	else
		if PRIVATE.ORIGINAL_CUSTOMIZATION_DISPLAY_ID and PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID then
			return PRIVATE.ORIGINAL_CUSTOMIZATION_DISPLAY_ID ~= PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID
		end
	end

	return false
end

PRIVATE.Deactivate = function()
	PRIVATE.ACTIVE = false
	PRIVATE.USE_OLD_API = false
	PRIVATE.ACTIVE_MODE = nil
	PRIVATE.IS_ALTERED_FORM_ENABLED = false
	PRIVATE.CURRENT_COST = nil
	PRIVATE.RESET_BLOCKED = nil

	PRIVATE.ORIGINAL_CUSTOMIZATION_DISPLAY_ID = nil
	PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID = nil
	PRIVATE.QUEUED_CUSTOMIZATION_DISPLAY_ID = nil
	twipe(PRIVATE.CURRENT_CUSTOMIZATION_OPTION)
end

PRIVATE.SetDisplayID = function(displayID)
	if type(displayID) ~= "number" then
		error("C_BarberShop: Attempt to set unknown customization type", 2)
	end

	if PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID == displayID then
		return
	end

	PRIVATE.QUEUED_CUSTOMIZATION_DISPLAY_ID = displayID
	FireCustomClientEvent("CUSTOM_BARBER_SHOP_AWAIT")
	FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_AWAIT")
	SendServerMessage("ACMSG_UPDATE_DRESSROOM", displayID)

	return true
end

PRIVATE.GetPlayerSex = function()
	local sexID = UnitSex("player")
	if sexID then
		return sexID - 2
	end
end

PRIVATE.GetPlayerRace = function(returnRaceID)
	local raceLocalized, race = UnitRace("player")
	if race then
		if returnRaceID then
			local raceData = S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC[raceLocalized]
			return strupper(race), raceData and raceData.raceID or -1
		else
			return strupper(race)
		end
	end
end

PRIVATE.GetFormIcon = function(formData, sex)
	sex = sex or UnitSex("player")

	local icon, iconIsAtlas
	if formData.atlasSex then
		icon = strformat(formData.atlasSex, sex == 3 and "female" or "male")
		iconIsAtlas = true
	elseif formData.atlas then
		icon = formData.atlas
		iconIsAtlas = true
	else
		icon = formData.icon or [[interface\icons\inv_misc_questionmark]]
		iconIsAtlas = false
	end

	return icon, iconIsAtlas
end

PRIVATE.GetRaceNameIcon = function(race, sex)
	race = race or PRIVATE.GetPlayerRace()
	sex = sex or UnitSex("player")

	local name = _G["RACE_"..race]
	local iconIsAtlas = true
	local icon = strformat("raceicon-round-%s%s", strlower(race), sex == 3 and "female" or "male")

	return name, icon, iconIsAtlas
end

PRIVATE.GetCustomizationOptionNameOldAPI = function(optionIndex)
	local hairCustomization = GetHairCustomization()
	local raceInfo = C_CreatureInfo.GetRaceInfo(UnitRace("player"))

	if optionIndex == 1 then
		return _G["HAIR_"..hairCustomization.."_STYLE"]
	elseif optionIndex == 2 then
		if _G["HAIR_"..hairCustomization.."_COLOR"] == EMPTY_HAIR_COLOR
		or ((raceInfo.raceID == E_CHARACTER_RACES.RACE_PANDAREN_HORDE or raceInfo.raceID == E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE) and UnitSex("player") == E_SEX.MALE)
		then
			return nil
		else
			return _G["HAIR_"..hairCustomization.."_COLOR"]
		end
	elseif optionIndex == 3 then
		if (raceInfo.raceID == E_CHARACTER_RACES.RACE_NIGHTELF or raceInfo.raceID == E_CHARACTER_RACES.RACE_NIGHTELF_CREATURE) and UnitSex("player") == E_SEX.FEMALE then
			return FACIAL_HAIR_FEATURES_EARS
		else
			local facialHair = GetFacialHairCustomization()
			return _G["FACIAL_HAIR_"..facialHair]
		end
	elseif optionIndex == 4 and CanAlterSkin() then
		return SKIN_COLOR
	end

	return UNKNOWN
end

PRIVATE.UnloadRaceData = function()
	PRIVATE.LOADED = nil
	PRIVATE.LOADED_SEX = nil

	twipe(PRIVATE.CUSTOMIZATION_OPTION_DISPLAY_MAP)
	twipe(PRIVATE.CUSTOMIZATION_OPTIONS)
	twipe(PRIVATE.CUSTOMIZATION_OPTION_ARRAYS)
	twipe(PRIVATE.CUSTOMIZATION_OPTION_MAP)
end

PRIVATE.LoadRaceData = function(raceData, reload)
	if not PRIVATE.ACTIVE then return end

	local playerSexID = PRIVATE.GetPlayerSex()

	if not reload and PRIVATE.LOADED and PRIVATE.LOADED_SEX == PRIVATE.GetPlayerSex() then
		return true
	end

	PRIVATE.UnloadRaceData()

	local dataIndexes = raceData.DATA_INDEXES
	local numOptions = #raceData.DATA_OPTION_INDEXES

	for optionIndex = 1, numOptions do
		PRIVATE.CUSTOMIZATION_OPTIONS[optionIndex] = {}
		PRIVATE.CUSTOMIZATION_OPTION_ARRAYS[optionIndex] = {}
	end

	for srcOptionIndex, srcOptionData in ipairs(raceData.SOURCE) do
		if srcOptionData[dataIndexes.SEX] == playerSexID or srcOptionData[dataIndexes.SEX] == ANY_SEX_DISPLAY_ID then
			local displayID = srcOptionData[raceData.DATA_INDEXES.DISPLAY_ID]

			PRIVATE.CUSTOMIZATION_OPTION_DISPLAY_MAP[displayID] = srcOptionData

			local optionMap = PRIVATE.CUSTOMIZATION_OPTION_MAP

			for optionIndex, dataIndex in ipairs(raceData.DATA_OPTION_INDEXES) do
				local optionValue = srcOptionData[dataIndex]
				optionMap[optionValue] = optionMap[optionValue] or {}

				if optionIndex == numOptions then
					optionMap[optionValue] = displayID
				else
					optionMap = optionMap[optionValue] -- recurse
				end

				if not PRIVATE.CUSTOMIZATION_OPTIONS[optionIndex][optionValue] then
					PRIVATE.CUSTOMIZATION_OPTIONS[optionIndex][optionValue] = true
					tinsert(PRIVATE.CUSTOMIZATION_OPTION_ARRAYS[optionIndex], optionValue)
				end
			end
		end
	end

	PRIVATE.LOADED = true
	PRIVATE.LOADED_SEX = playerSexID

	return true
end

PRIVATE.HideDialogs = function()
	StaticPopup_Hide("BARBER_SHOP_MODE_CHANGE_WARNING")
end

PRIVATE.Exit = function(noExitRequest)
	if not PRIVATE.ACTIVE then return end

	securecall(PRIVATE.HideDialogs)

	if PRIVATE.USE_OLD_API then
		PRIVATE.ACTIVE = false
		PRIVATE.ACTIVE_MODE = nil
		PRIVATE.USE_OLD_API = false
		CancelBarberShop()
	else
		PRIVATE.Deactivate()
	end

	PRIVATE.DRESSED = true

	C_Camera.SetCameraView(C_Camera.Presets.View2)

	if not noExitRequest then
		SendServerMessage("ACMSG_DEACTIVATE_DRESSROOM")
	end
	FireCustomClientEvent("CUSTOM_BARBER_SHOP_EXIT")
end

_G.CancelBarberShop = function()
	PRIVATE.Exit()
end

C_BarberShop = {}

---@return boolean isActive
function C_BarberShop.IsActive()
	return PRIVATE.ACTIVE
end

---@return boolean? success
function C_BarberShop.ResetCustomizationChoices()
	if not PRIVATE.ACTIVE or not PRIVATE.HasAnyChanges() then return end

	securecall(PRIVATE.HideDialogs)

	if PRIVATE.USE_OLD_API then
		BarberShopReset()
		FireCustomClientEvent("CUSTOM_BARBER_SHOP_UPDATE_DRESSROOM")
		FireCustomClientEvent("CUSTOM_BARBER_SHOP_PRICE_CHANGED")
	else
		PRIVATE.CURRENT_COST = nil
		return PRIVATE.SetDisplayID(PRIVATE.ORIGINAL_CUSTOMIZATION_DISPLAY_ID)
	end
end

---@return boolean? success
function C_BarberShop.RandomizeCustomizationChoices()
	if not PRIVATE.ACTIVE then return end

	if PRIVATE.USE_OLD_API then
		return false
	else
		local randomDisplayData = PRIVATE.CUSTOMIZATION_OPTION_MAP
		for index, optionData in ipairs(PRIVATE.CURRENT_CUSTOMIZATION_TYPE.OPTIONS) do
			if optionData.hidden then
				randomDisplayData = randomDisplayData[PRIVATE.CURRENT_CUSTOMIZATION_OPTION[index]] -- recurse
			else
				local currentIndex = PRIVATE.CURRENT_CUSTOMIZATION_OPTION[index]
				local optionArray = PRIVATE.CUSTOMIZATION_OPTION_ARRAYS[index]
				local entryIndex

				if #optionArray > 1 then
					entryIndex = mathrandom(1, #optionArray)

					while entryIndex == currentIndex do
						entryIndex = mathrandom(1, #optionArray)
					end
				else
					entryIndex = currentIndex
				end

				local customizationID = optionArray[entryIndex]
				randomDisplayData = randomDisplayData[customizationID] -- recurse
			end
		end

		return PRIVATE.SetDisplayID(randomDisplayData)
	end
end

---@param optionID number
---@param choiceID number
---@return boolean? success
function C_BarberShop.SetCustomizationChoice(optionID, choiceID)
	if type(optionID) ~= "number" then
		error(strformat("Bad argument #1 to 'C_BarberShop.SetCustomizationChoice' (number expected, got %s)", optionID ~= nil and type(optionID) or "no value"), 2)
	elseif type(choiceID) ~= "number" then
		error(strformat("Bad argument #2 to 'C_BarberShop.SetCustomizationChoice' (number expected, got %s)", choiceID ~= nil and type(choiceID) or "no value"), 2)
	end

	if not PRIVATE.ACTIVE or PRIVATE.USE_OLD_API then return end

	local optionIDFound
	local displayData = PRIVATE.CUSTOMIZATION_OPTION_MAP
	for index, optionData in ipairs(PRIVATE.CURRENT_CUSTOMIZATION_TYPE.OPTIONS) do
		if optionData.id == optionID then
			if optionData.hidden then
				error("C_BarberShop.SetCustomizationChoice(optionID, choiceID): Unknown optionID", 2)
			end

			displayData = displayData[choiceID] -- recurse
			optionIDFound = true

			if not displayData then
				error("C_BarberShop.SetCustomizationChoice(optionID, choiceID): Unknown choiceID", 2)
			end
		else
			displayData = displayData[PRIVATE.CURRENT_CUSTOMIZATION_OPTION[index]] -- recurse
		end
	end

	if not optionIDFound then
		error("C_BarberShop.SetCustomizationChoice(optionID, choiceID): Unknown optionID", 2)
	end

	return PRIVATE.SetDisplayID(displayData)
end

---@param optionID number
---@param offset number
function C_BarberShop.ScrollCustomizationType(optionID, offset)
	if type(optionID) ~= "number" then
		error(strformat("Bad argument #1 to 'C_BarberShop.ScrollCustomizationType' (number expected, got %s)", optionID ~= nil and type(optionID) or "no value"), 2)
	elseif type(offset) ~= "number" then
		error(strformat("Bad argument #2 to 'C_BarberShop.ScrollCustomizationType' (number expected, got %s)", offset ~= nil and type(offset) or "no value"), 2)
	end

	if not PRIVATE.ACTIVE or offset == 0 then return end

	if PRIVATE.USE_OLD_API then
		if offset > 0 then
			SetNextBarberShopStyle(optionID)
		elseif offset < 0 then
			SetNextBarberShopStyle(optionID, 1)
		end

		if optionID == 4 then
			PRIVATE.RESET_BLOCKED = true
		end

		FireCustomClientEvent("CUSTOM_BARBER_SHOP_PRICE_CHANGED")
	else
		local index = tIndexOf(PRIVATE.CUSTOMIZATION_OPTION_ARRAYS[optionID], PRIVATE.CURRENT_CUSTOMIZATION_OPTION[optionID])
		local nextIndex = index + offset

		local numCustomizations = #PRIVATE.CUSTOMIZATION_OPTION_ARRAYS[optionID]
		if nextIndex > numCustomizations then
			nextIndex = 1
		elseif nextIndex < 1 then
			nextIndex = numCustomizations
		end

		local customizationID = PRIVATE.CUSTOMIZATION_OPTION_ARRAYS[optionID][nextIndex]
		C_BarberShop.SetCustomizationChoice(optionID, customizationID)
	end
end

local optionCacheOldAPI = setmetatable({}, {
	__index = function(self, optionIndex)
		local optionName = PRIVATE.GetCustomizationOptionNameOldAPI(optionIndex)
		rawset(self, optionIndex, optionName)
		return optionName
	end
})

---@return table categories
function C_BarberShop.GetAvailableCustomizations()
	if not PRIVATE.ACTIVE then
		return {}
	end

	if PRIVATE.USE_OLD_API then
		local options = {}

		local maxOptions = CanAlterSkin() and 4 or 3

		for optionIndex = 1, maxOptions do
			local name = optionCacheOldAPI[optionIndex]
			if name then
				tinsert(options, {
					id = optionIndex,
					name = name,
				})
			end
		end

		return {options = options}
	else
		local options = {}

		if PRIVATE.CURRENT_CUSTOMIZATION_TYPE.OPTIONS then
			options = {}

			for _, optionData in pairs(PRIVATE.CURRENT_CUSTOMIZATION_TYPE.OPTIONS) do
				if not optionData.hidden then
					tinsert(options, CopyTable(optionData))
				end
			end
		end

		return {options = options}
	end
end

---@return boolean isViewingAlteredForm
function C_BarberShop.IsViewingAlteredForm()
	return PRIVATE.IS_ALTERED_FORM_ENABLED
end

---@return number cost
function C_BarberShop.GetCurrentCost()
	if PRIVATE.USE_OLD_API then
		return GetBarberShopTotalCost()
	else
		return PRIVATE.CURRENT_COST or 0
	end
end

---@return boolean hasChanges
function C_BarberShop.HasAnyChanges()
	return PRIVATE.HasAnyChanges()
end

---@return boolean success
function C_BarberShop.ApplyCustomizationChoices()
	if not PRIVATE.ACTIVE then return end

	securecall(PRIVATE.HideDialogs)

	if PRIVATE.USE_OLD_API then
		PRIVATE.RESET_BLOCKED = nil
		ApplyBarberShopStyle()
		FireCustomClientEvent("CUSTOM_BARBER_SHOP_APPEARANCE_APPLIED")
	else
		FireCustomClientEvent("CUSTOM_BARBER_SHOP_AWAIT")
		FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_AWAIT")
		SendServerMessage("ACMSG_SAVE_DRESSROOM", PRIVATE.CURRENT_CUSTOMIZATION_DISPLAY_ID)
	end

	return true
end

function C_BarberShop.Cancel()
	PRIVATE.Exit()
end

---@return table characterData
function C_BarberShop.GetCurrentCharacterData()
	if not PRIVATE.ACTIVE then
		return {}
	end

	local sex = UnitSex("player")
	local race, raceID = PRIVATE.GetPlayerRace()
	local characterData = {sex = sex}

	if PRIVATE.CURRENT_CUSTOMIZATION_TYPE then
		local defaultFormData = PRIVATE.CURRENT_CUSTOMIZATION_TYPE.DEFAULT_FORM
		if defaultFormData then
			local icon, iconIsAtlas = PRIVATE.GetFormIcon(defaultFormData, sex)

			local raceData = {
				name = defaultFormData.name,
				fileName = race,
				createScreenIconAtlas = icon,
				iconIsAtlas = iconIsAtlas,
			}

			local alteredForm = PRIVATE.CURRENT_CUSTOMIZATION_TYPE.ALTERED_FORM
			if alteredForm then
				icon, iconIsAtlas = PRIVATE.GetFormIcon(alteredForm, sex)

				local alternateFormRaceData = {
					raceID = raceID,
					name = alteredForm.name,
					fileName = race,
					createScreenIconAtlas = icon,
					iconIsAtlas = iconIsAtlas,
				}

				raceData.alternateFormRaceData = alternateFormRaceData
			end

			characterData.raceData = raceData
		end
	else
		local name, icon, iconIsAtlas = PRIVATE.GetRaceNameIcon(race, sex)

		local raceData = {
			raceID = raceID,
			name = name,
			fileName = race,
			createScreenIconAtlas = icon,
			iconIsAtlas = iconIsAtlas,
		}

		characterData.raceData = raceData
	end

	return characterData
end

---@param isViewingAlteredForm boolean?
---@param ignoreChanges boolean?
function C_BarberShop.SetViewingAlteredForm(isViewingAlteredForm, ignoreChanges)
	if not PRIVATE.ACTIVE or PRIVATE.AWAIT_MODE_CHANGE then
		return false
	end

	isViewingAlteredForm = not not isViewingAlteredForm

	if not PRIVATE.CURRENT_CUSTOMIZATION_TYPE.ALTERED_FORM or PRIVATE.IS_ALTERED_FORM_ENABLED == isViewingAlteredForm then
		return false
	end

	if not ignoreChanges and PRIVATE.HasAnyChanges() then
		securecall(StaticPopup_Show, "BARBER_SHOP_MODE_CHANGE_WARNING", nil, nil, isViewingAlteredForm)
		return false
	end

	local alteredFormID = isViewingAlteredForm and PRIVATE.CURRENT_CUSTOMIZATION_TYPE.ALTERED_FORM.id or PRIVATE.CURRENT_CUSTOMIZATION_TYPE.DEFAULT_FORM.id

	securecall(PRIVATE.HideDialogs)
	PRIVATE.IS_ALTERED_FORM_ENABLED = isViewingAlteredForm
	FireCustomClientEvent("CUSTOM_BARBER_SHOP_AWAIT")
	FireCustomClientEvent("CUSTOM_BARBER_SHOP_MODEL_AWAIT")
	PRIVATE.EventHanlder:RegisterEvent("UNIT_MODEL_CHANGED")

	PRIVATE.AWAIT_MODE_CHANGE = PRIVATE.ACTIVE_MODE
	PRIVATE.ACTIVE_MODE = alteredFormID
	PRIVATE.USE_OLD_API = alteredFormID == Enum.CustomBarberShop.Mode.Default

	SendServerMessage("ACMSG_ACTIVATE_DRESSROOM", alteredFormID)

	return true
end

function C_BarberShop.CanChangeDressState()
	if not PRIVATE.ACTIVE or PRIVATE.IS_ALTERED_FORM_ENABLED then
		return false
	end
	return true
end

function C_BarberShop.GetDressState()
	return PRIVATE.DRESSED
end

function C_BarberShop.ToggleDressState(state)
	if not PRIVATE.ACTIVE or PRIVATE.AWAIT_MODE_CHANGE then
		return false
	end

	state = not not state
	if PRIVATE.DRESSED == state then
		return false
	end

	PRIVATE.DRESSED = state
	if state then
		Barbershop_Dress()
	else
		Barbershop_Undress()
	end

	return true
end

function C_BarberShop.IsResetAvailable()
	if not PRIVATE.ACTIVE or PRIVATE.AWAIT_MODE_CHANGE then
		return false
	end

	if PRIVATE.USE_OLD_API then
		return not PRIVATE.RESET_BLOCKED
	else
		return true
	end
end