local PACKET_THROTTLE = 0.1

C_GluePackets = {}

C_GluePackets.OpCodes = {
	RequestBoostStatus				= "0",
	RequestBoostBuy					= "1",
	RequestBoostCharacter			= "00",
	RequestCharacterListInfo		= "01",
	RequestCharacterDeletedList		= "11",
	SendCharacterDeletedRestore		= "10",
	SendCharacterFix				= "000",
	SendCharactersOrderSave			= "001",
	AnnounceCharacterDeletedLeave	= "010",
	RequestCharacterList			= "100",
}

C_GluePackets.queue = {}
C_GluePackets.lastMessage = 0

C_GluePackets.eventHandler = CreateFrame("Frame", nil, GlueParent)
C_GluePackets.eventHandler:Hide()
C_GluePackets.eventHandler.sinceUpdate = 0

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

function C_GluePackets:SendPacketThrottled(opcode, ...)
	if #self.queue > 0 then
		self.queue[#self.queue + 1] = {opcode, ...}
	else
		local curTime = debugprofilestop()
		if (curTime - self.lastMessage) < PACKET_THROTTLE then
			self.queue[#self.queue + 1] = {opcode, ...}
			self.eventHandler.sinceUpdate = self.lastMessage - curTime
			self.eventHandler:Show()
		else
			self.lastMessage = curTime
			self:SendPacket(opcode, ...)
		end
	end
end

function C_GluePackets:SendPacket(opcode, ...)
	self.lastMessage = debugprofilestop()

--	printc("SendPacket", opcode, ..., self.lastMessage)

	SetRealmSplitState(2)
	SetRealmSplitState(2)
	for o = 1, string.len(opcode) do
		local subs = tostring(opcode):sub(o, o)
		local nSubs = tonumber(subs)

		if not nSubs then
			nSubs = 1
		end

		SetRealmSplitState(nSubs)
	end
	SetRealmSplitState(2)

	if select("#", ...) ~= 0 then
		local val = {...}
		local size = 4

		for v = 1, #val do
			local bits = toBits(val[v])
			for i = 0, size - #bits - 1 do
				SetRealmSplitState(0)
			end

			for s = 1, #bits do
				SetRealmSplitState(bits[s])
			end
		end
	end
end