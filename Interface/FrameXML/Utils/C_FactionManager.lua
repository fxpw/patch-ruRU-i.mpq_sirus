local issecure = issecure
local securecall = securecall

local secureCallbacks = {}
local addonCallbacks = {}

local ORIGINAL_FACTION_ID
local OVERRIDE_FACTION_ID

local function fireCallbackType(callbacks, secure)
	local index = 1
	local size = #callbacks
	while index <= size do
		local callback = callbacks[index]
		local hasArgs = type(callback) == "table"

		local success, err
		if secure then
			success, err = securecall(pcall, hasArgs and callback[1] or callback)
		else
			success, err = pcall(hasArgs and callback[1] or callback)
		end

		if not success then
			geterrorhandler()(err)
		end

		if hasArgs and callback[2] then
			table.remove(callbacks, index)
			size = size - 1
		else
			index = index + 1
		end
	end
end

local function fireCallbacks()
	fireCallbackType(secureCallbacks, true)
	fireCallbackType(addonCallbacks)
end

local function setOriginalFaction(factionID)
	ORIGINAL_FACTION_ID = factionID

	if not GetSafeCVar("originalFaction") then
		RegisterCVar("originalFaction", factionID)
	end

	SetSafeCVar("originalFaction", factionID)
end

local function setFactionOverride(factionID)
	OVERRIDE_FACTION_ID = factionID

	if not GetSafeCVar("factionOverride") then
		RegisterCVar("factionOverride", factionID)
	end

	SetSafeCVar("factionOverride", factionID)
end

local localizedFactionName = setmetatable({}, {
	__index = function(self, key)
		if key then
			local str = rawget(self, key)
			if not str then
				str = _G["FACTION_" .. string.upper(key)]
				if str then
					rawset(self, key, str)
				else
					return UNKNOWN
				end
			end
			return str
		else
			return UNKNOWN
		end
	end,
})

local function returnFactionInfo(factionID)
	local faction = PLAYER_FACTION_GROUP[factionID]
	return factionID, SERVER_PLAYER_FACTION_GROUP[faction], faction, localizedFactionName[faction]
end

---@class C_FactionManagerMixin : Mixin
C_FactionManagerMixin = {}

function C_FactionManagerMixin:OnLoad()
	self:RegisterEventListener()
	self:RegisterHookListener()
end

function C_FactionManagerMixin:PLAYER_ENTERING_WORLD()
	local inInstance, instanceType = IsInInstance()

	if inInstance == 1 and instanceType == "pvp" then
		OVERRIDE_FACTION_ID = nil
	end
end

function C_FactionManagerMixin:ASMSG_PLAYER_FACTION_CHANGE(msg)
	local originalFactionID, factionID = string.split(",", msg)
	setOriginalFaction(PLAYER_FACTION_GROUP[SERVER_PLAYER_FACTION_GROUP[tonumber(originalFactionID)]])
	setFactionOverride(PLAYER_FACTION_GROUP[SERVER_PLAYER_FACTION_GROUP[tonumber(factionID)]])
	fireCallbacks()
end

---@class C_FactionManager : C_FactionManagerMixin
C_FactionManager = CreateFromMixins(C_FactionManagerMixin)
C_FactionManager:OnLoad()


function C_FactionManager:RegisterFactionOverrideCallback(callback, isNeedRunning, persistent)
	C_FactionManager.RegisterCallback(callback, isNeedRunning, persistent)
end

---@param callback function
---@param shouldExecute boolean
---@param persistent boolean
function C_FactionManager.RegisterCallback(callback, shouldExecute, persistent)
	if type(callback) ~= "function" then
		error("Usage: C_FactionManager.RegisterCallback(callback, [shouldExecute, persistent])")
	end

	if shouldExecute then
		callback()
	end

	if not OVERRIDE_FACTION_ID then
		local callbackData = persistent and {callback, persistent} or callback

		if persistent then
			callbackData = {callback, persistent}
		else
			callbackData = callback
		end

		if issecure() then
			table.insert(secureCallbacks, callbackData)
		else
			table.insert(addonCallbacks, callbackData)
		end
	end
end

---@param callback function
function C_FactionManager.UnregisterCallback(callback)
	local callbacks = issecure() and secureCallbacks or addonCallbacks

	for i = 1, #callbacks do
		if type(callbacks[i]) == "table" and callbacks[i][1] == callback or callbacks[i] == callback then
			table.remove(callbacks, i)
			return
		end
	end
end

function C_FactionManager.GetOriginalFactionCVar()
	local cVarOriginalFaction = GetSafeCVar("originalFaction")

	cVarOriginalFaction = tonumber(cVarOriginalFaction or "-1")

	if cVarOriginalFaction == -1 then
		cVarOriginalFaction = nil
	end

	return cVarOriginalFaction
end

function C_FactionManager.GetFactionOverrideCVar()
	local cVarFactionOverride = GetSafeCVar("factionOverride")

	cVarFactionOverride = tonumber(cVarFactionOverride or "-1")

	if cVarFactionOverride == -1 then
		cVarFactionOverride = nil
	end

	return cVarFactionOverride
end

---@return integer factionID
function C_FactionManager.GetOriginalFaction()
	local cVarOriginalFaction = C_FactionManager.GetOriginalFactionCVar()
	return ORIGINAL_FACTION_ID or (cVarOriginalFaction and tonumber(cVarOriginalFaction))
end

---@return integer factionID
function C_FactionManager.GetFactionOverride()
	local cVarFactionOverride = C_FactionManager.GetFactionOverrideCVar()
	return OVERRIDE_FACTION_ID or (cVarFactionOverride and tonumber(cVarFactionOverride))
end

---@return integer factionID
---@return integer serverFactionID
---@return string factionName
---@return string factionNameLocalized
function C_FactionManager.GetFactionInfoOriginal()
	local race = UnitRace("player")
	local raceData = S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC[race]

	if raceData and raceData.raceID == E_CHARACTER_RACES.RACE_DRACTHYR then
		local factionID = C_FactionManager:GetOriginalFaction()
		if factionID then
			return returnFactionInfo(factionID)
		end
	end

	return returnFactionInfo(raceData.factionID)
end

---@return integer factionID
---@return integer serverFactionID
---@return string factionName
---@return string factionNameLocalized
function C_FactionManager.GetFactionInfoOverride()
	local factionID = C_FactionManager:GetFactionOverride()
	if factionID then
		return returnFactionInfo(factionID)
	end
end