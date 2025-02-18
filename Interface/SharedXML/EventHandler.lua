local securecall = securecall
local ipairs = ipairs
local next = next
local type = type
local strsplit = string.split

local ExecuteFrameScript = ExecuteFrameScript
local GetFramesRegisteredForEvent = GetFramesRegisteredForEvent
local UnitName = UnitName
local UnitTokenFromGUID = UnitTokenFromGUID

local REGISTERED_CUSTOM_EVENTS = {}

local function SecureNext(elements, key)
	return securecall(next, elements, key)
end

function FireClientEvent(event, ...)
	for _, frame in SecureNext, {GetFramesRegisteredForEvent(event)} do
		securecall(ExecuteFrameScript, frame, "OnEvent", event, ...)
	end
end

function FireCustomClientEvent(event, ...)
	if REGISTERED_CUSTOM_EVENTS[event] then
		for frame in SecureNext, REGISTERED_CUSTOM_EVENTS[event] do
			securecall(ExecuteFrameScript, frame, "OnEvent", event, ...)
		end
	end
end

local eventRegistrar = CreateFrame("Frame")
eventRegistrar:SetScript("OnAttributeChanged", function(this, name, value)
	if name == "1" then
		if not REGISTERED_CUSTOM_EVENTS[value] then
			REGISTERED_CUSTOM_EVENTS[value] = {}
		end
		REGISTERED_CUSTOM_EVENTS[value][this:GetAttribute("f")] = true
	elseif name == "0" then
		if REGISTERED_CUSTOM_EVENTS[value] then
			REGISTERED_CUSTOM_EVENTS[value][this:GetAttribute("f")] = nil
		end
	end
end)

function RegisterCustomEvent(self, event)
	eventRegistrar:SetAttribute("f", self)
	eventRegistrar:SetAttribute("1", event)
end

function UnregisterCustomEvent(self, event)
	eventRegistrar:SetAttribute("f", self)
	eventRegistrar:SetAttribute("0", event)
end

function FireCustomClientUnitGroupEvent(event, unitGUID, ...)
	if event and REGISTERED_CUSTOM_EVENTS[event] and unitGUID then
		local units = {UnitTokenFromGUID(unitGUID)}
		if #units > 0 then
			for frame in SecureNext, REGISTERED_CUSTOM_EVENTS[event] do
				for _, unit in ipairs(units) do
					securecall(ExecuteFrameScript, frame, "OnEvent", event, unit, ...)
				end
			end
		end
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