local pcall = pcall
local type = type
local mathfloor = math.floor
local strformat, strmatch = string.format, string.match
local tinsert = table.insert

local UnitName = UnitName

local IsDevClient = IsDevClient
local IsGMAccount = IsGMAccount
local SendServerMessage = SendServerMessage

local COUNTER_CHAR = {
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
	"k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
	"u", "v", "w", "x", "y", "z",

	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
	"K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
	"U", "V", "W", "X", "Y", "Z"
}
local COUNTER_CHAR_COUNT = #COUNTER_CHAR

local OPCODE = {
	OK = "o",
	FAILED = "f",
	ACKNOWLEDGED = "a",
	SYS_MESSAGE = "m",
}

local PRIVATE = {
	CAN_USE_API = false,
	COMMAND_COUNT = 0,
	BUFFER = {},
	CALLBACKS = {},
}

PRIVATE.EventHandler = CreateFrame("Frame")
PRIVATE.EventHandler:Hide()
PRIVATE.EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.EventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.EventHandler:SetScript("OnEvent", function(this, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		local isInitialLogin, isReloadingUI = ...
		SendServerMessage("TrinityCore", "p0000")
	elseif event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...

		if prefix == "TrinityCore" and sender == UnitName("player") then
			if message == "a0000" then
				PRIVATE.CAN_USE_API = true
			end
			if PRIVATE.CAN_USE_API then
				PRIVATE.HandleAnswer(message)
			end
		end
	end
end)

PRIVATE.HandleAnswer = function(message)
	local opcode, counter, text = strmatch(message, "^([afom])([0-9A-z][0-9A-z][0-9A-z][0-9A-z])(.*)$")

	if not opcode or not counter then
		if IsGMAccount() or IsDevClient() then
			print(strformat("Unknown message %s - unknown opcode or server error?", message))
		end
		return
	end

	if not PRIVATE.CALLBACKS[counter] then
		return
	end

	if opcode == OPCODE.ACKNOWLEDGED then
		if not PRIVATE.BUFFER[counter] then
			PRIVATE.BUFFER[counter] = {}
		end
	elseif opcode == OPCODE.SYS_MESSAGE then
		if PRIVATE.BUFFER[counter] then
			tinsert(PRIVATE.BUFFER[counter], text)
		end
	elseif opcode == OPCODE.OK or opcode == OPCODE.FAILED then
		if PRIVATE.BUFFER[counter] then
			local success, err = pcall(PRIVATE.CALLBACKS[counter], PRIVATE.BUFFER[counter])
			if not success then
				geterrorhandler()(err)
			end
			PRIVATE.CALLBACKS[counter] = nil
			PRIVATE.BUFFER[counter] = nil
		end
	end
end

PRIVATE.GetCommandCounter = function()
	local numCounterChars = COUNTER_CHAR_COUNT
	local counter = PRIVATE.COMMAND_COUNT

	local char4 = counter % numCounterChars
	counter = mathfloor(counter / numCounterChars)
	local char3 = counter % numCounterChars
	counter = mathfloor(counter / numCounterChars)
	local char2 = counter % numCounterChars
	counter = mathfloor(counter / numCounterChars)
	local char1 = counter % numCounterChars

	return strformat("%s%s%s%s", COUNTER_CHAR[char1 + 1], COUNTER_CHAR[char2 + 1], COUNTER_CHAR[char3 + 1], COUNTER_CHAR[char4 + 1])
end

TrinityCoreAPI = {}

function TrinityCoreAPI.SendCommand(command, callback)
	if not PRIVATE.CAN_USE_API then
		return
	end

	local counter = PRIVATE.GetCommandCounter()
	if type(callback) == "function" then
		PRIVATE.CALLBACKS[counter] = callback
	end

	SendServerMessage("TrinityCore", strformat("i%s%s", counter, command))
	PRIVATE.COMMAND_COUNT = PRIVATE.COMMAND_COUNT + 1
end

-- backward compatibility
TrinityCoreMixIn = {
--	CommandCounter = function(self)
--		return PRIVATE.GetCommandCounter()
--	end,
	SendCommand = function(self, command, callback)
		return TrinityCoreAPI.SendCommand(command, callback)
	end,
}