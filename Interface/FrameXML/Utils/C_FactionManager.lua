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

		if not hasArgs or not callback[2] then
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
		RegisterCVar("originalFaction", "")
	end

	SetSafeCVar("originalFaction", factionID)
end

local function setFactionOverride(factionID)
	OVERRIDE_FACTION_ID = factionID

	if not GetSafeCVar("factionOverride") then
		RegisterCVar("factionOverride", "")
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
	EventRegistry:TriggerEvent("PlayerFaction.Update")
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

	local callbackData
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

	if shouldExecute then
		local success, err = securecall(pcall, callback)
		if not success then
			geterrorhandler()(err)
		end
	end
end

---@param callback function
function C_FactionManager.UnregisterCallback(callback)
	local callbacks = issecure() and secureCallbacks or addonCallbacks

	for i = 1, #callbacks do
		if callbacks[i] == callback or (type(callbacks[i]) == "table" and callbacks[i][1] == callback) then
			table.remove(callbacks, i)
			return
		end
	end
end

function C_FactionManager.IsFactionDataAvailable()
	if GetSafeCVar("originalFaction", "") ~= "" and GetSafeCVar("factionOverride", "") ~= "" then
		return true
	end
	return false
end

function C_FactionManager.GetOriginalFactionCVar()
	local factionID = GetSafeCVar("originalFaction", "")
	if factionID == "" then
		return
	end
	return tonumber(factionID)
end

function C_FactionManager.GetFactionOverrideCVar()
	local factionID = GetSafeCVar("factionOverride", "")
	if factionID == "" then
		return
	end
	return tonumber(factionID)
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
	local _, _, raceID = UnitRace("player")

	if raceID == E_CHARACTER_RACES.RACE_DRACTHYR then
		local factionID = C_FactionManager.GetOriginalFaction()
		if factionID then
			return returnFactionInfo(factionID)
		end
	end

	local raceData = S_CHARACTER_RACES_INFO[raceID]
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

local FireClientEvent = FireClientEvent
C_FactionManager.RegisterCallback(function()
	FireClientEvent("UNIT_FACTION", "player")
end, false, true)