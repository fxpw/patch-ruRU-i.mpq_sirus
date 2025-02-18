local STORAGE_CVAR = "readScanning"
local STORAGE_VERSION = "1"
local DELIMITER = "|"

C_GlueCVars = {}

enum:E_GLUE_CVARS {
	"VERSION",
	"ENTRY_POINT",
	"REALM_ENTRY_POINT",
	"IGNORE_ADDON_VERSION",
	"AUTO_LOGIN",
	"HELPTIP_BITFIELD",
	"BOOST_ITEM_LEVLS",
}

local DEFAULT_VALUES = {
}

local function validateCVarName(cvarName, silent)
	if type(cvarName) == "number" and cvarName <= #E_GLUE_CVARS then
		cvarName = E_GLUE_CVARS[cvarName]
	end

	if not E_GLUE_CVARS[cvarName] then
		if silent then
			return false
		else
			error(string.format("Unknown custom cvar '%s'", tostring(cvarName)), 3)
		end
	end

	return cvarName
end

local function getCVarValues(createNew)
	local cvarValue = GetCVar(STORAGE_CVAR)
	if (cvarValue == "0" or cvarValue == "1") then
		if createNew then
			local values = {}
			for i = 1, #E_GLUE_CVARS do
				if i == 1 then
					values[i] = STORAGE_VERSION
				else
					values[i] = DEFAULT_VALUES[E_GLUE_CVARS[i]] or ""
				end
			end
			return values
		else
			return ""
		end
	end

	local values = {string.split(DELIMITER, cvarValue)}
	for i = #values + 1, #E_GLUE_CVARS do
		values[i] = DEFAULT_VALUES[E_GLUE_CVARS[i]] or ""
	end

--	if values[1] ~= STORAGE_VERSION then
--		-- upgrade
--	end

	return values
end

function C_GlueCVars.HasCVar(cvarName)
	return validateCVarName(cvarName, true) ~= false
end

function C_GlueCVars.GetCVarDefault(cvarName)
	cvarName = validateCVarName(cvarName)
	return DEFAULT_VALUES[cvarName] or ""
end

function C_GlueCVars.GetCVar(cvarName)
	cvarName = validateCVarName(cvarName)

	local values = getCVarValues()
	if not values then
		return ""
	end

	return values[E_GLUE_CVARS[cvarName]]
end

function C_GlueCVars.SetCVar(cvarName, value)
	cvarName = validateCVarName(cvarName)

	local values = getCVarValues(true)
	local cvarIndex = E_GLUE_CVARS[cvarName]
	values[cvarIndex] = value ~= nil and tostring(value) or ""

	local newValues = table.concat(values, DELIMITER, 1, #E_GLUE_CVARS)

	SetCVar(STORAGE_CVAR, newValues)
end

function C_GlueCVars.GetCVarBitfield(cvarName, index)
	if type(cvarName) ~= "string" or type(index) ~= "number" then
		error("Usage: local success = C_GlueCVars:SetCVarBitfield(name, index, value", 2)
	end

	cvarName = validateCVarName(cvarName)

	local values = getCVarValues()
	if not values then
		return
	end

	local value = values[E_GLUE_CVARS[cvarName]]
	if not value or value == "0" then
		return
	end

	return tonumber(value)
end

function C_GlueCVars.SetCVarBitfield(cvarName, index, value)
	if type(cvarName) ~= "string" or type(index) ~= "number" then
		error("Usage: local success = C_GlueCVars:SetCVarBitfield(name, index, value", 2)
	end

	value = not not value

	cvarName = validateCVarName(cvarName)

	local values = getCVarValues(true)
	local cvarIndex = E_GLUE_CVARS[cvarName]
	local currentValue = tonumber(values[cvarIndex]) or 0

	if value then
		value = bit.bor(currentValue, bit.lshift(1, index - 1))
	else
		value = bit.band(currentValue, bit.bnot(bit.lshift(1, index - 1)))
	end

	values[cvarIndex] = value ~= nil and tostring(value) or ""

	local newValues = table.concat(values, DELIMITER, 1, #E_GLUE_CVARS)
	SetCVar(STORAGE_CVAR, newValues)

	return true
end