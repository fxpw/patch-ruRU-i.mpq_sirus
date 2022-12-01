local STORAGE_CVAR = "readScanning"
local STORAGE_VERSION = "1"

C_GlueCVars = {}

enum:E_GLUE_CVARS {
	"VERSION",
	"ENTRY_POINT",
	"REALM_ENTRY_POINT",
	"IGNORE_ADDON_VERSION",
	"AUTO_LOGIN",
}

local function validateCVarName(cvarName)
	if type(cvarName) == "number" and cvarName <= #E_GLUE_CVARS then
		cvarName = E_GLUE_CVARS[cvarName]
	end

	if not E_GLUE_CVARS[cvarName] then
		error(string.format("Unknown custom cvar '%s'", tostring(cvarName)), 3)
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
					values[i] = ""
				end
			end
			return values
		else
			return ""
		end
	end

	local values = {string.split("|", cvarValue)}
	for i = #values + 1, #E_GLUE_CVARS do
		values[i] = ""
	end

--	if values[1] ~= STORAGE_VERSION then
--		-- upgrade
--	end

	return values
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

	local newValues = table.concat(values, "|", 1, #E_GLUE_CVARS)

	SetCVar(STORAGE_CVAR, newValues)
end