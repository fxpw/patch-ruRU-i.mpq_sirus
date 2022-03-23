local BattlegroundStatus = {
	[-1] = "error",
	[0] = "none",
	[1] = "queued",
	[2] = "confirm",
	[3] = "active",
	[4] = "locked",
}

local BattlegroundTeamSize = {
	[1] = 3,
	[2] = 2,
	[3] = 3,
	[5] = 5,
	[6] = 1,
}

local BattlefieldStatusData = {
	Index = 1,
	StatusID = 2,
	MapName = 3,
	TypeID = 4,
	ArenaType = 5,
	IsArena = 6,
	IsRated = 7,
	MinLevel = 8,
	MaxLevel = 9,
	InstanceID = 10,
	Time1 = 11,
	Time2 = 12,
}

local WorldPVPStatusData = {
	Index = 1,
	StatusID = 2,
}

C_BattlefieldStatusManagerMixin = {}

function C_BattlefieldStatusManagerMixin:OnLoad()
	self:RegisterEventListener()

	self.statusData = {}
	self.bfStatusData = {}
end

function C_BattlefieldStatusManagerMixin:GetStatus(index)
	local status = self.statusData[index]
	if status then
		return status.status, status.mapName, status.instanceID, status.lowestlevel, status.highestlevel, status.teamSize, status.registeredMatch, status.isSoloq
	else
		return BattlegroundStatus[0], nil, nil, 0, 0, 0, 0, false
	end
end

function C_BattlefieldStatusManagerMixin:GetMaxID()
	return 8
end

function C_BattlefieldStatusManagerMixin:GetEstimatedWaitTime(index)
	return self.statusData[index] and self.statusData[index].estimatedWaitTime or 0
end

function C_BattlefieldStatusManagerMixin:GetTimeWaited(index)
	if self.statusData[index] and self.statusData[index].timeWaited then
		return (GetTime() - self.statusData[index].timeWaited) * 1000
	end
	return 0
end

function C_BattlefieldStatusManagerMixin:GetPortExpiration(index)
	if self.statusData[index] and self.statusData[index].portExpiration then
		return self.statusData[index].portExpiration - GetTime()
	end
	return 0
end

function C_BattlefieldStatusManagerMixin:GetInstanceExpiration()
	for index = 1, self:GetMaxID() do
		if self.statusData[index] and self.statusData[index].status == "active" and self.statusData[index].instanceExpiration then
			return (GetTime() - self.statusData[index].instanceExpiration) * 1000
		end
	end
	return 0
end

function C_BattlefieldStatusManagerMixin:ASMSG_BATTLEFIELD_STATUS(msg)
	local statusData = C_Split(msg, ":")

	local index = tonumber(statusData[BattlefieldStatusData.Index])
	local statusID = tonumber(statusData[BattlefieldStatusData.StatusID])

	if index and statusID then
		if statusID ~= 0 then
			local statusInfo = self.statusData[index] or {}

			local mapName = statusData[BattlefieldStatusData.MapName]
			local arenaType = tonumber(statusData[BattlefieldStatusData.ArenaType])
			local isArena = tonumber(statusData[BattlefieldStatusData.IsArena]) == 1
			local isRated = tonumber(statusData[BattlefieldStatusData.IsRated]) == 1

			if isArena and BattlegroundTeamSize[arenaType] then
				mapName = string.format(isRated and QUEUED_STATUS_ARENA_RATED or QUEUED_STATUS_ARENA_SKIRMISH, _G[string.format("QUEUED_STATUS_ARENA_TYPE_%d", arenaType)])
			end

			statusInfo.status = BattlegroundStatus[statusID] or BattlegroundStatus[-1]
			statusInfo.mapName = mapName ~= "" and mapName
			statusInfo.instanceID = tonumber(statusData[BattlefieldStatusData.InstanceID])
			statusInfo.lowestlevel = tonumber(statusData[BattlefieldStatusData.MinLevel]) or 0
			statusInfo.highestlevel = tonumber(statusData[BattlefieldStatusData.MaxLevel]) or 0
			statusInfo.teamSize = isArena and arenaType and BattlegroundTeamSize[arenaType] or 0
			statusInfo.registeredMatch = isRated
			statusInfo.isSoloq = isArena and isRated and arenaType == 6

			if statusID == 1 then
				statusInfo.estimatedWaitTime = tonumber(statusData[BattlefieldStatusData.Time1]) or 0
				statusInfo.timeWaited = GetTime() - ((tonumber(statusData[BattlefieldStatusData.Time2]) or 0) / 1000)
			elseif statusID == 2 then
				statusInfo.portExpiration = GetTime() + ((tonumber(statusData[BattlefieldStatusData.Time1]) or 0) / 1000)
			elseif statusID == 3 then
				statusInfo.portExpiration = nil
				local instanceExpiration = tonumber(statusData[BattlefieldStatusData.Time1]) or 0
				if instanceExpiration > 0 then
					statusInfo.instanceExpiration = GetTime() - (instanceExpiration / 1000)
				end
			end

			self.statusData[index] = statusInfo
		else
			if self.statusData[index] and self.statusData[index].canceled then
				UIErrorsFrame:AddMessage(ERR_PVP_LEFT_QUEUE, 1, 1, 0, 1)

				local info = ChatTypeInfo["SYSTEM"]
				DEFAULT_CHAT_FRAME:AddMessage(ERR_PVP_LEFT_QUEUE, info.r, info.g, info.b, info.id)
			end

			self.statusData[index] = nil
		end

		for _, frame in ipairs({GetFramesRegisteredForEvent("UPDATE_BATTLEFIELD_STATUS")}) do
			local onEventFunc = frame:GetScript("OnEvent")

			if onEventFunc then
				onEventFunc(frame, "UPDATE_BATTLEFIELD_STATUS", index)
			end
		end
	end
end

function C_BattlefieldStatusManagerMixin:ASMSG_BATTLEFIELD_STATUS_FAKE(msg)
	if msg == "1" then
		if not self.tempStatusData then
			self.tempStatusData = self.statusData
			self.statusData = {}
		end
	elseif msg == "0" then
		if self.tempStatusData then
			self.statusData = self.tempStatusData
			self.tempStatusData = nil
		end
	end

	for _, frame in ipairs({GetFramesRegisteredForEvent("UPDATE_BATTLEFIELD_STATUS")}) do
		local onEventFunc = frame:GetScript("OnEvent")

		if onEventFunc then
			onEventFunc(frame, "UPDATE_BATTLEFIELD_STATUS", index)
		end
	end
end

function C_BattlefieldStatusManagerMixin:ASMSG_BATTLEFIELD_QUEUE_ACCEPT(msg)

end

function C_BattlefieldStatusManagerMixin:ASMSG_BATTLEFIELD_QUEUE_LEAVE(msg)

end

function C_BattlefieldStatusManagerMixin:ASMSG_BF_QUEUE_STATUS(msg)
	local statusData = C_Split(msg, ",")

	local index = tonumber(statusData[WorldPVPStatusData.Index])
	local statusID = tonumber(statusData[WorldPVPStatusData.StatusID])
	if index and statusID then
		if statusID ~= 0 then
			self.bfStatusData[index] = BattlegroundStatus[statusID]
		else
			self.bfStatusData[index] = nil
		end

		for _, frame in ipairs({GetFramesRegisteredForEvent("UPDATE_BATTLEFIELD_STATUS")}) do
			local onEventFunc = frame:GetScript("OnEvent")

			if onEventFunc then
				onEventFunc(frame, "UPDATE_BATTLEFIELD_STATUS", index)
			end
		end
	end
end

C_BattlefieldStatusManager = CreateFromMixins(C_BattlefieldStatusManagerMixin)
C_BattlefieldStatusManager:OnLoad()

function GetMaxBattlefieldID()
	return C_BattlefieldStatusManager:GetMaxID()
end

function GetBattlefieldStatus(index)
	return C_BattlefieldStatusManager:GetStatus(index)
end

function LeaveBattlefield()
	SendServerMessage("ACMSG_BATTLEFIELD_LEAVE")
end

function AcceptBattlefieldPort(index, accept)
	if not accept or accept == 0 then
		local statusInfo = C_BattlefieldStatusManager.statusData[index]

		if statusInfo then
			if statusInfo.status == "confirm" and statusInfo.teamSize ~= 0 then
				return;
			end

			statusInfo.canceled = true
		end

		SendServerMessage("ACMSG_BATTLEFIELD_QUEUE_LEAVE", index)
	else
		SendServerMessage("ACMSG_BATTLEFIELD_QUEUE_ACCEPT", index)
	end
end

function GetBattlefieldEstimatedWaitTime(index)
	return C_BattlefieldStatusManager:GetEstimatedWaitTime(index)
end

function GetBattlefieldTimeWaited(index)
	return C_BattlefieldStatusManager:GetTimeWaited(index)
end

function GetBattlefieldPortExpiration(index)
	return C_BattlefieldStatusManager:GetPortExpiration(index)
end

function GetBattlefieldInstanceExpiration()
	return C_BattlefieldStatusManager:GetInstanceExpiration()
end

function GetBFQueueStatus(index)
	return C_BattlefieldStatusManager.bfStatusData[index]
end