local error = error
local pairs = pairs
local rawset = rawset
local time = time
local type = type
local unpack = unpack
local strformat = string.format

local issecure = issecure
local securecall = securecall

local GetSharedStorage = GetSharedStorage

local IsInterfaceDevClient = IsInterfaceDevClient

local IN_GLUE_STATE = IsOnGlueScreen()
local INSERT_SECURE_VARIABLE_ATTRIBUTE = "isv"

local USE_CVAR_STORAGE = not GetCVarBool("globalStorageNew")

local STORAGE_TYPE = {
	GLOBAL			= 0,
	INGAME			= 1,
	INGAME_TTL		= 2,
	INGAME_SECURE	= 3,
}

local PRIVATE = {
	STORAGE = GetSharedStorage(),
}

PRIVATE.Init = function()
	if USE_CVAR_STORAGE then
		PRIVATE.InitCVarStorage()
		PRIVATE.LoadCVarStorage()
	end

	for storageName, storageType in pairs(STORAGE_TYPE) do
		if not PRIVATE.STORAGE[storageType] then
			PRIVATE.STORAGE[storageType] = {}
		end
	end

	if IN_GLUE_STATE then
		table.wipe(PRIVATE.STORAGE[STORAGE_TYPE.INGAME])
		table.wipe(PRIVATE.STORAGE[STORAGE_TYPE.INGAME_TTL])
		table.wipe(PRIVATE.STORAGE[STORAGE_TYPE.INGAME_SECURE])
		PRIVATE.SetVariable(STORAGE_TYPE.GLOBAL, "initial", true)

		if not USE_CVAR_STORAGE then
			local showToolsUI = GetCVar("showToolsUI")
			if showToolsUI and showToolsUI ~= "" and showToolsUI ~= "-1" and showToolsUI ~= "0" and showToolsUI ~= "1" then
				SetCVar("showToolsUI", "-1")
			end
		end
	else
		PRIVATE.AttributeDelegate = CreateFrame("Frame")
		PRIVATE.AttributeDelegate:SetScript("OnAttributeChanged", function(this, attribute, value)
			if attribute == INSERT_SECURE_VARIABLE_ATTRIBUTE then
				local storageType, variable, varValue = securecall(unpack, value, 1, 3)
				rawset(PRIVATE.STORAGE[storageType], variable, varValue)
			end
		end)

		PRIVATE.initial = PRIVATE.GetVariable(STORAGE_TYPE.GLOBAL, "initial") or false
		PRIVATE.SetVariable(STORAGE_TYPE.GLOBAL, "initial", nil)

		_G.IsInitialLoad = function()
			return PRIVATE.initial or false
		end
	end

	if IsInterfaceDevClient() then
		PRIVATE_STORAGE = PRIVATE
	end
end

PRIVATE.InitCVarStorage = function()
	local pcall = pcall
	local loadstring = loadstring
	local strconcat, strlower = strconcat, string.lower
	local twipe = table.wipe

	local GetCVar = GetCVar
	local SetCVar = SetCVar

	local STORAGE_CVAR_NAME = "globalStorage"
	local STORAGE_DEFAULT_VALUE = "return {}"
	RegisterCVar2(STORAGE_CVAR_NAME, STORAGE_DEFAULT_VALUE, 0x80)

	PRIVATE.STORAGE = {}
	PRIVATE.CVAR_STORAGE_INITIALIZED = true

	PRIVATE.CVAR_STORAGE_EVENT_HANDLER = CreateFrame("Frame")
	if IN_GLUE_STATE then
		PRIVATE.CVAR_STORAGE_EVENT_HANDLER:RegisterEvent("FRAMES_LOADED")
	else
		PRIVATE.CVAR_STORAGE_EVENT_HANDLER:RegisterEvent("VARIABLES_LOADED")
		PRIVATE.CVAR_STORAGE_EVENT_HANDLER:RegisterEvent("PLAYER_LOGOUT")
	end
	PRIVATE.CVAR_STORAGE_EVENT_HANDLER:SetScript("OnEvent", function(this, event, ...)
		if event == "FRAMES_LOADED" then
			SetCVar(STORAGE_CVAR_NAME, STORAGE_DEFAULT_VALUE)
		elseif event == "PLAYER_LOGOUT" then
			if not PRIVATE.CVAR_STORAGE_SAVED then
				SetCVar(STORAGE_CVAR_NAME, STORAGE_DEFAULT_VALUE)
			end
		elseif event == "VARIABLES_LOADED" then
			PRIVATE.LoadCVarStorage()
		end
	end)

	PRIVATE.TableCopyUnique = function(to, from)
		for key, value in pairs(from) do
			if to[key] == nil then
				to[key] = value
			elseif type(value) == "table" and type(to[key]) == "table" then
				PRIVATE.TableCopyUnique(to[key], value)
			end
		end
	end

	PRIVATE.LoadCVarStorage = function()
		local success, result = pcall(function()
			local storageStr = GetCVar(STORAGE_CVAR_NAME)
			if not storageStr or storageStr == "" then
				storageStr = STORAGE_DEFAULT_VALUE
			end
			return loadstring(strconcat("return (function() ", storageStr, " end)()"))()
		end)

		if success then
			if PRIVATE.CVAR_STORAGE_INITIALIZED then
				twipe(PRIVATE.STORAGE)
				PRIVATE.CVAR_STORAGE_INITIALIZED = nil
			end

			PRIVATE.TableCopyUnique(PRIVATE.STORAGE, result)
		elseif IsInterfaceDevClient() then
			GMError(strformat("[C_GlobalStorage] Error while loading old storage: %s", result))
		end
	end

	PRIVATE.SaveCVarStorage = function()
		local storageStr = securecall(DataDumper, PRIVATE.STORAGE)
		SetCVar(STORAGE_CVAR_NAME, storageStr)
		PRIVATE.CVAR_STORAGE_SAVED = true
	end

	do -- hooks
		if IN_GLUE_STATE then
			local EnterWorld = EnterWorld
			_G.EnterWorld = function()
				securecall(PRIVATE.SaveCVarStorage)
				EnterWorld()
			end
		else
			local CONSOLE_COMMANDS_SAVE = {
				reloadui = true,
				logout = true,
			--	quit = true,
			}

			local ConsoleExec = ConsoleExec
			_G.ConsoleExec = function(command)
				if type(command) == "string" and CONSOLE_COMMANDS_SAVE[strlower(command)] then
					securecall(PRIVATE.SaveCVarStorage)
				end
				ConsoleExec(command)
			end

			local CancelLogout = CancelLogout
			_G.CancelLogout = function()
				PRIVATE.CVAR_STORAGE_SAVED = nil
				CancelLogout()
			end

			local Logout = Logout
			_G.Logout = function()
				securecall(PRIVATE.SaveCVarStorage)
				Logout()
			end
		end

		local ReloadUI = ReloadUI
		_G.ReloadUI = function()
			securecall(PRIVATE.SaveCVarStorage)
			ReloadUI()
		end

		local RestartGx = RestartGx
		_G.RestartGx = function()
			securecall(PRIVATE.SaveCVarStorage)
			RestartGx()
		end
	end
end

PRIVATE.SetVariable = function(storageType, variable, value)
	if IN_GLUE_STATE or issecure() then
		PRIVATE.STORAGE[storageType][variable] = value
	else
		PRIVATE.AttributeDelegate:SetAttribute(INSERT_SECURE_VARIABLE_ATTRIBUTE, {storageType, variable, value})
	end
end

PRIVATE.GetVariable = function(storageType, variable)
	local storage = PRIVATE.STORAGE[storageType]
	return storage[variable]
end

PRIVATE.GetOrCreateVariable = function(storageType, variable, defaultValue)
	local storage = PRIVATE.STORAGE[storageType]
	if storage[variable] == nil and defaultValue ~= nil then
		PRIVATE.SetVariable(storageType, variable, defaultValue)
		return defaultValue
	end
	return storage[variable]
end

PRIVATE.SetVariableWithTTL = function(storageType, variable, value, ttl)
	local storage = PRIVATE.STORAGE[storageType]

	if value ~= nil then
		local var = storage[variable]
		if not var then
			var = {}
			storage[variable] = var
		end

		var.ttl = ttl and (ttl + time()) or 0
		var.value = value

		value = var
	end

	PRIVATE.SetVariable(storageType, variable, value)
end

PRIVATE.GetVariableWithTTL = function(storageType, variable)
	local storage = PRIVATE.STORAGE[storageType]
	local var = storage[variable]
	if not var then
		return
	end

	if var.ttl ~= 0 and var.ttl < time() then
		storage[variable] = nil
		return nil, true
	end

	return var.value
end

PRIVATE.GetOrCreateVariableWithTTL = function(storageType, variable, defaultValue, ttl)
	local skipWipe = not not defaultValue
	local value, expiredTTL = PRIVATE.GetVariableWithTTL(storageType, variable, skipWipe)
	if expiredTTL or (value == nil and defaultValue ~= nil) then
		PRIVATE.SetVariableWithTTL(storageType, variable, defaultValue, ttl)
		return defaultValue, expiredTTL
	end
	return value, expiredTTL
end

PRIVATE.UpdateVariableTTL = function(storageType, variable, ttl)
	local storage = PRIVATE.STORAGE[storageType]
	if storage[variable] then
		storage[variable].ttl = ttl and (ttl + time()) or 0
	end
end

PRIVATE.AssertType = function(funcName, argN, varType, variable, offset)
	if type(variable) ~= varType then
		error(strformat("bad argument #%d to '%s' (%s expected, got %s)", argN, funcName, varType, variable ~= nil and type(variable) or "no value"), 3 + (offset or 0))
	end
end

PRIVATE.CopyTable = function(settings, shallow)
	local copy = {}
	for k, v in pairs(settings) do
		if type(v) == "table" and not shallow then
			copy[k] = PRIVATE.CopyTable(v)
		else
			copy[k] = v
		end
	end
	return copy
end

PRIVATE.Init()

C_GlobalStorageSecure = {}

function C_GlobalStorageSecure.SetGlobalVar(variable, value)
	PRIVATE.AssertType("C_GlobalStorageSecure.SetGlobalVar", 1, "string", variable)
	PRIVATE.SetVariable(STORAGE_TYPE.GLOBAL, variable, value)
end

function C_GlobalStorageSecure.GetGlobalVar(variable)
	PRIVATE.AssertType("C_GlobalStorageSecure.GetGlobalVar", 1, "string", variable)
	return PRIVATE.GetVariable(STORAGE_TYPE.GLOBAL, variable)
end

function C_GlobalStorageSecure.GetOrCreateGlobalVar(variable, defaultValue)
	PRIVATE.AssertType("C_GlobalStorageSecure.GetOrCreateGlobalVar", 1, "string", variable)
	return PRIVATE.GetOrCreateVariable(STORAGE_TYPE.GLOBAL, variable, defaultValue)
end

if not IN_GLUE_STATE then
	function C_GlobalStorageSecure.SetVar(variable, value)
		PRIVATE.AssertType("C_GlobalStorageSecure.SetVar", 1, "string", variable)
		PRIVATE.SetVariable(STORAGE_TYPE.INGAME_SECURE, variable, value)
	end

	function C_GlobalStorageSecure.GetVar(variable)
		PRIVATE.AssertType("C_GlobalStorageSecure.GetVar", 1, "string", variable)
		return PRIVATE.GetVariable(STORAGE_TYPE.INGAME_SECURE, variable)
	end
end

C_GlobalStorage = {}

function C_GlobalStorage.GetGlobalVar(variable)
	PRIVATE.AssertType("C_GlobalStorage.GetGlobalVar", 1, "string", variable)
	local value = PRIVATE.GetVariable(STORAGE_TYPE.GLOBAL, variable)
	if type(value) == "table" then
		return PRIVATE.CopyTable(value)
	end
	return PRIVATE.GetVariable(STORAGE_TYPE.GLOBAL, variable)
end

function C_GlobalStorage.SetVar(variable, value)
	PRIVATE.AssertType("C_GlobalStorage.SetVar", 1, "string", variable)
	PRIVATE.SetVariable(STORAGE_TYPE.INGAME, variable, value)
end

function C_GlobalStorage.GetVar(variable)
	PRIVATE.AssertType("C_GlobalStorage.GetVar", 1, "string", variable)
	return PRIVATE.GetVariable(STORAGE_TYPE.INGAME, variable)
end

function C_GlobalStorage.GetOrCreateVar(variable, defaultValue)
	PRIVATE.AssertType("C_GlobalStorage.GetOrCreateVar", 1, "string", variable)
	return PRIVATE.GetOrCreateVariable(STORAGE_TYPE.INGAME, variable, defaultValue)
end

function C_GlobalStorage.SetTTLVar(variable, value, ttl)
	PRIVATE.AssertType("C_GlobalStorage.SetTTLVar", 1, "string", variable)
--	PRIVATE.AssertType("C_GlobalStorage.SetTTLVar", 3, "number", ttl)
	PRIVATE.SetVariableWithTTL(STORAGE_TYPE.INGAME_TTL, variable, value, ttl)
end

function C_GlobalStorage.GetTTLVar(variable)
	PRIVATE.AssertType("C_GlobalStorage.GetTTLVar", 1, "string", variable)
	return PRIVATE.GetVariableWithTTL(STORAGE_TYPE.INGAME_TTL, variable)
end

function C_GlobalStorage.GetOrCreateTTLVar(variable, defaultValue, ttl)
	PRIVATE.AssertType("C_GlobalStorage.GetOrCreateTTLVar", 1, "string", variable)
--	PRIVATE.AssertType("C_GlobalStorage.GetOrCreateTTLVar", 3, "number", ttl)
	return PRIVATE.GetOrCreateVariableWithTTL(STORAGE_TYPE.INGAME_TTL, variable, defaultValue, ttl)
end

function C_GlobalStorage.UpdateVarTTL(variable, ttl)
	PRIVATE.AssertType("C_GlobalStorage.UpdateVarTTL", 1, "string", variable)
	PRIVATE.AssertType("C_GlobalStorage.UpdateVarTTL", 2, "number", ttl)
	PRIVATE.UpdateVariableTTL(STORAGE_TYPE.INGAME_TTL, variable, ttl)
end