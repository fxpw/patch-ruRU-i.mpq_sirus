local securecall = securecall
local ipairs = ipairs
local next = next
local type = type
local strsplit = string.split
local twipe = table.wipe

local ExecuteFrameScript = ExecuteFrameScript
local GetFramesRegisteredForEvent = GetFramesRegisteredForEvent
local UnitName = UnitName

local function SecureNext(elements, key)
	return securecall(next, elements, key)
end

function FireClientEvent(event, ...)
	for _, frame in SecureNext, {GetFramesRegisteredForEvent(event)} do
		securecall(ExecuteFrameScript, frame, "OnEvent", event, ...)
	end
end

function FireCustomClientEvent(eventID, ...)
	local eventName = type(eventID) == "number" and E_CLIEN_CUSTOM_EVENTS[eventID] or eventID;

	if eventName and REGISTERED_CUSTOM_EVENTS[eventName] then
		for frame in SecureNext, REGISTERED_CUSTOM_EVENTS[eventName] do
			securecall(ExecuteFrameScript, frame, "OnEvent", eventName, ...)
		end
	end
end

local UNIT_LIST = {}
local function UpdateValidUnitList(unitName, isGroupCheck)
	local skipNGTarget, skipNGFocus

	if UnitExists(unitName) then
		local isPlayer = UnitIsUnit("player", unitName)

		if isPlayer then
			UNIT_LIST[#UNIT_LIST + 1] = "player"
		end

		if GetNumRaidMembers() > 0 then
			local raidID = UnitInRaid(unitName)
			if raidID then
				UNIT_LIST[#UNIT_LIST + 1] = "raid"..(raidID + 1)
			end
		end

		if not isPlayer and GetNumPartyMembers() > 0 then
			for i = 1, 4 do
				if UnitIsUnit("party"..i, unitName) then
					UNIT_LIST[#UNIT_LIST + 1] = "party"..i
				end
			end
		end

		if UnitIsUnit("target", unitName) then
			UNIT_LIST[#UNIT_LIST + 1] = "target"
			skipNGTarget = true
		end

		if UnitIsUnit("focus", unitName) then
			UNIT_LIST[#UNIT_LIST + 1] = "focus"
			skipNGFocus = true
		end
	end

	if not isGroupCheck then
		if not skipNGTarget and UnitExists("target") and UnitIsPlayer("target") and UnitCanCooperate("player", "target") and UnitName("target") == unitName then
			UNIT_LIST[#UNIT_LIST + 1] = "target"
		end

		if not skipNGFocus and UnitExists("focus") and UnitIsPlayer("focus") and UnitCanCooperate("player", "focus") and UnitName("focus") == unitName then
			UNIT_LIST[#UNIT_LIST + 1] = "focus"
		end
	end
end

function FireCustomClientUnitNameGroupEvent(event, unitName, ...)
	if event and REGISTERED_CUSTOM_EVENTS[event] then
		UpdateValidUnitList(unitName, true)

		for frame in SecureNext, REGISTERED_CUSTOM_EVENTS[event] do
			for _, unit in ipairs(UNIT_LIST) do
				securecall(ExecuteFrameScript, frame, "OnEvent", event, unit, ...)
			end
		end

		twipe(UNIT_LIST)
	end
end

local handleServerEventMessage = function(eventID, ...)
	if eventID then
		eventID = tonumber(eventID)
		if E_DEFAULT_CLIENT_EVENTS[eventID] then
			FireClientEvent(E_DEFAULT_CLIENT_EVENTS[eventID], ...)
		end
	end
end

EventHandler = setmetatable(
	{
		events = {},		-- Original events
		listeners = {},		-- New tables for handling events outside og EventHandler
		RegisterListener = function(self, listener)
			self.listeners[listener] = true
		end,
		Handle = function(self, opcode, message, unk, sender)
			if sender == UnitName("player") then
				if opcode == "ASMSG_FIRE_CLIENT_EVENT" and message then
					handleServerEventMessage(strsplit(":", message))
				end

				for listener in SecureNext, self.listeners do
					if listener[opcode] then
						securecall(listener[opcode], listener, message)
					end
				end

				if self.events[opcode] then
					securecall(self.events[opcode], self, message)
				end
			end
		end
	},
	{
		__newindex = function(self, key, value)
			if type(value) == "function" then
				self.events[key] = value
			end
			rawset(self, key, value)
		end
	}
)

local EventHandlerFrame = CreateFrame("Frame")
EventHandlerFrame:RegisterEvent("CHAT_MSG_ADDON")
EventHandlerFrame:SetScript("OnEvent", function(self, event, opcode, message, unk, sender)
	EventHandler:Handle(opcode, message, unk, sender)
end)

function C_OnReceiveOpcodeHandler(opcode, ...)
    local args = {...}
    xpcall(function()
        EventHandler:Handle(opcode, nil, unpack(args))
    end, function(err)
        geterrorhandler()(err)
    end)
end
