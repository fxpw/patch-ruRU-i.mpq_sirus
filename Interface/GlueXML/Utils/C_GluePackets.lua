local PACKET_THROTTLE = 0.3

C_GluePackets = {}

C_GluePackets.OpCodes = {
	RequestBoostStatus				= "0",
	RequestBoostBuy					= "101",
	RequestNewPagePurchase			= "0001",
	RequestBoostCharacter			= "00",
	RequestCharacterListInfo		= "01",
	RequestCharacterDeletedList		= "11",
	SendCharacterDeletedRestore		= "10",
	SendCharacterFix				= "000",
	SendCharactersOrderSave			= "001",
	AnnounceCharacterDeletedLeave	= "010",
	RequestCharacterList			= "100",
	SendCharacterCreationInfo		= "0010",
	SendCharacterCustomizationInfo	= "0011",
	CharacterHardcoreProposalAnswer	= "0100",
	RequestBoostSpecItems			= "0101",
	RequestBoostCharacterItems		= "0111",
	RequestBoostCancel				= "1000",
	RequestBoostRefund				= "1100",
}

C_GluePackets.queue = {}
C_GluePackets.lastMessage = 0

C_GluePackets.eventHandler = CreateFrame("Frame", nil, GlueParent)
C_GluePackets.eventHandler:Hide()
C_GluePackets.eventHandler:RegisterCustomEvent("CONNECTION_REALM_DISCONNECT")
C_GluePackets.eventHandler.sinceUpdate = 0

C_GluePackets.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CONNECTION_REALM_DISCONNECT" then
		C_GluePackets:ClearQueue()
	end
end)

C_GluePackets.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	self.sinceUpdate = self.sinceUpdate + elapsed
	if self.sinceUpdate >= PACKET_THROTTLE then
		C_GluePackets:SendNext()
		self.sinceUpdate = 0
	end
end)

function C_GluePackets:SendNext()
	if #self.queue > 0 then
		self:SendPacket(unpack(table.remove(self.queue, 1)))
	end
	if #self.queue == 0 then
		self.eventHandler:Hide()
	end
end

function C_GluePackets:ClearQueue()
	self.eventHandler:Hide()
	table.wipe(self.queue)
	GlueDialog:HideDialog("SERVER_WAITING")
end

function C_GluePackets:SendPacketThrottled(opcode, ...)
	if not IsConnectedToServer() then
		return false, false
	end

	if #self.queue > 0 then
		self.queue[#self.queue + 1] = {opcode, ...}
	else
		local curTime = debugprofilestop()
		if (curTime - self.lastMessage) < PACKET_THROTTLE then
			self.queue[#self.queue + 1] = {opcode, ...}
			self.eventHandler.sinceUpdate = self.lastMessage - curTime
			self.eventHandler:Show()
			return true, true
		else
			self.lastMessage = curTime
			self:SendPacket(opcode, ...)
			return true, false
		end
	end
end

local function reverse(t)
	local nt = {}
	local size = #t + 1
	for k, v in ipairs(t) do
		nt[size - k] = v
	end
	return nt
end

local function toBits(num)
	local t = {}
	while num > 0 do
		local rest = math.fmod(num, 2)
		t[#t + 1] = rest
		num = (num - rest) / 2
	end
	return reverse(t)
end

function C_GluePackets:SendBits(packet)
	for index, bit in ipairs(packet) do
		if not IsConnectedToServer() then
			self:ClearQueue()
			return false
		end
		SetRealmSplitState(bit)
	end
	return true
end

function C_GluePackets:SendPacket(opcode, ...)
	if not IsConnectedToServer() then
		self:ClearQueue()
		return false
	end

	self.lastMessage = debugprofilestop()

	local packet = {2, 2}

	for o = 1, string.len(opcode) do
		local subs = tostring(opcode):sub(o, o)
		local nSubs = tonumber(subs)

		if not nSubs then
			nSubs = 1
		end

		table.insert(packet, nSubs)
	end

	table.insert(packet, 2)

	if select("#", ...) ~= 0 then
		local val = {...}
		local size = 6

		for v = 1, #val do
			local bits = toBits(val[v])
			for i = 0, size - #bits - 1 do
				table.insert(packet, 0)
			end

			for i = 1, #bits do
				table.insert(packet, bits[i])
			end
		end
	end

	local success = self:SendBits(packet)
	return success
end

function C_GluePackets:SendPacketEx(opcode, onSuccessCallback, onErrorCallback, ...)
	local success = self:SendPacket(opcode, ...)
	local callback = success and onSuccessCallback or onErrorCallback
	if type(callback) then
		local suc, err = pcall(callback, opcode)
		if not suc then
			geterrorhandler()(err)
		end
	end
end