--	Filename:	TrinityCoreAPI.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

TrinityCoreMixIn = {}

TrinityCoreMixIn.canUseAPI = false
TrinityCoreMixIn.commandCount = 0
TrinityCoreMixIn.counterChar = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
TrinityCoreMixIn.callback = {}
TrinityCoreMixIn.reeciveBuffer = {}

function TrinityCoreMixIn:CommandCounter()
	local char4, char3, char2, char1
	local counter = self.commandCount
	local numCounterChars = #self.counterChar

	char4 = counter % numCounterChars
	counter = math.floor(counter / numCounterChars)
	char3 = counter % numCounterChars
	counter = math.floor(counter / numCounterChars)
	char2 = counter % numCounterChars
	counter = math.floor(counter / numCounterChars)
	char1 = counter % numCounterChars

	return string.format("%s%s%s%s", self.counterChar[char1 + 1], self.counterChar[char2 + 1], self.counterChar[char3 + 1], self.counterChar[char4 + 1])
end

function TrinityCoreMixIn:SendCommand( command, callback )
	if not self.canUseAPI then
		return
	end

	local counter = self:CommandCounter()

	SendServerMessage("TrinityCore", string.format("i%s%s", counter, command))
	self.callback[counter] = callback

	self.commandCount = self.commandCount + 1
end

Hook:RegisterCallback("TrinityCoreMixIn", {"PLAYER_ENTERING_WORLD", "CHAT_MSG_ADDON"}, function(event, prefix, message, _, sender)
	if event == "PLAYER_ENTERING_WORLD" then
		SendServerMessage("TrinityCore", "p0000")
	elseif event == "CHAT_MSG_ADDON" then
		if prefix == "TrinityCore" and sender == UnitName("player") then
			if message == "a0000" then
				TrinityCoreMixIn.canUseAPI = true
			end

			if TrinityCoreMixIn.canUseAPI then
				local op, counter, text = message:match("^([afom])([0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z])(.*)$")

				if not op then
					printf("Unknown message %s - unknown opcode or server error?", message)
				end

				if not TrinityCoreMixIn.callback[counter] then
					return
				end

				if op == "a" then
					if not TrinityCoreMixIn.reeciveBuffer[counter] then
						TrinityCoreMixIn.reeciveBuffer[counter] = {}
					end
				elseif op == "m" and TrinityCoreMixIn.reeciveBuffer[counter] then
					table.insert(TrinityCoreMixIn.reeciveBuffer[counter], text)
				elseif (op == "o" or op == "f") and TrinityCoreMixIn.reeciveBuffer[counter] then
					TrinityCoreMixIn.callback[counter]( TrinityCoreMixIn.reeciveBuffer[counter] )
					TrinityCoreMixIn.callback[counter] = nil
    				TrinityCoreMixIn.reeciveBuffer[counter] = nil
				end
			end
		end
	end
end)
