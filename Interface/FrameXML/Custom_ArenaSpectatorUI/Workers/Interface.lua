ezSpectator_InterfaceWorker = {}
ezSpectator_InterfaceWorker.__index = ezSpectator_InterfaceWorker

function ezSpectator_InterfaceWorker:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_InterfaceWorker)

    self.Parent = Parent
    self.Viewpoint = nil

    self.TopFrame = ezSpectator_TopFrame:Create(self.Parent)

    self.Reactor = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.Reactor.Parent = self

	self.Nameplates = ezSpectator_Nameplates:Create(self.Parent)

	self.inactivePlayerObjects = {}

	self.Players = {}
	self.Teams = {[1] = {}, [2] = {}}

    return self
end

function ezSpectator_InterfaceWorker:Reset()
	for playerName, playerObject in pairs(self.Players) do
		playerObject.SmallFrame.CastFrame:Hide()
		playerObject:Reset()
		playerObject:Hide()
		table.insert(self.inactivePlayerObjects, playerObject)
		self.Players[playerName] = nil
	end

	table.wipe(self.Teams[1])
	table.wipe(self.Teams[2])
end

function ezSpectator_InterfaceWorker:GetPlayerObject(playerName)
	local playerObject = self.Players[playerName]
	if not playerObject then
		return self:AcquirePlayerObject(playerName)
	end
	return playerObject
end

function ezSpectator_InterfaceWorker:AcquirePlayerObject(playerName)
	local playerObject
	local numInactiveObjects = #self.inactivePlayerObjects

	if self.Parent.USE_PLAYER_OBJECT_POOLS and numInactiveObjects > 0 then
		playerObject = self.inactivePlayerObjects[numInactiveObjects]
		self.inactivePlayerObjects[numInactiveObjects] = nil
	else
		playerObject = ezSpectator_PlayerWorker:Create(self.Parent)
	end

	self.Players[playerName] = playerObject

	playerObject:SetNickname(playerName)
	playerObject:Hide()

	return playerObject
end

function ezSpectator_InterfaceWorker:SetMode(spectatorMode)
	local isDisabled = spectatorMode == Enum.ArenaSpectator.Mode.Disabled

	UIParent:SetShown(isDisabled)
	ArenaSpectatorFrame:SetShown(not isDisabled)
	self.TopFrame:SetShown(not isDisabled)
	self.Nameplates:SetScanEnabled(not isDisabled)
	self:SetMatchInProgress(not isDisabled and C_ArenaSpectator.IsInProgress())

	self:ResetViewpoint()

	if isDisabled then
		self:Reset()
	end
end

function ezSpectator_InterfaceWorker:SetTeamName(TeamID, Value)
    if not TeamID then
        return
    end

    Value = Value:sub(2, -2)
    if TeamID == 1 then
        self.Teams[TeamID].Name = Value
        self.TopFrame.LeftTeam:SetName(Value)
    end

    if TeamID == 2 then
        self.Teams[TeamID].Name = Value
        self.TopFrame.RightTeam:SetName(Value)
    end
end

function ezSpectator_InterfaceWorker:SetTeamColor(TeamID, Value)
    if not TeamID then
        return
    end

    if TeamID == 1 then
        self.Teams[TeamID].Color = Value
        self.TopFrame.LeftTeam:SetColor(Value)
    end

    if TeamID == 2 then
        self.Teams[TeamID].Color = Value
        self.TopFrame.RightTeam:SetColor(Value)
    end
end

function ezSpectator_InterfaceWorker:SetTeamScore(TeamID, Value)
    if not TeamID then
        return
    end

    if TeamID == 1 then
        self.Teams[TeamID].Score = Value
        self.TopFrame.LeftTeam:SetScore(Value)
    end

    if TeamID == 2 then
        self.Teams[TeamID].Score = Value
        self.TopFrame.RightTeam:SetScore(Value)
    end
end

function ezSpectator_InterfaceWorker:SetStage(Value)
    self.TopFrame:SetStage(Value)
    self.TopFrame:UpdateTournamentTextFrame()
end

function ezSpectator_InterfaceWorker:SetBOX(Value)
    self.TopFrame:SetBOX(Value)
    self.TopFrame:UpdateTournamentTextFrame()
end

function ezSpectator_InterfaceWorker:SetMatchInProgress(IsInProgress)
	self.TopFrame:SetMatchInProgress(IsInProgress)
end

function ezSpectator_InterfaceWorker:SetPaused(isPaused)
	self.TopFrame.Play:SetShown(isPaused)
	self.TopFrame.Pause:SetShown(not isPaused)
end

function ezSpectator_InterfaceWorker:GetTeam(teamID)
	if teamID == 1 then
		return self.TopFrame.LeftTeam
	elseif teamID == 2 then
		return self.TopFrame.RightTeam
	end
end

function ezSpectator_InterfaceWorker:UpdateTargets()
	for playerName, playerObject in pairs(self.Players) do
		if not playerObject.IsDead and playerObject:IsReady() then
			playerObject.SmallFrame.Target:Update()
		else
			playerObject.SmallFrame.Target:Hide()
		end
	end
end

function ezSpectator_InterfaceWorker:UpdateTeams()
	if not C_ArenaSpectator.IsInProgress() and not C_ArenaSpectator.IsInPreparation() then
        return
    end

    local LeftMax, LeftVal, RightMax, RightVal = 0, 0, 0, 0

	for playerName, playerObject in pairs(self.Players) do
		if playerObject and playerObject:IsReady() then
			if playerObject.Team == 1 then
				LeftMax = LeftMax + playerObject.MaxHealth
				LeftVal = LeftVal + playerObject.Health
			end

			if playerObject.Team == 2 then
				RightMax = RightMax + playerObject.MaxHealth
				RightVal = RightVal + playerObject.Health
			end
		end
	end

    self.TopFrame.LeftTeam.HealthBar:SetMaxValue(LeftMax)
    self.TopFrame.LeftTeam.HealthBar:SetValue(LeftVal)

    self.TopFrame.RightTeam.HealthBar:SetMaxValue(RightMax)
    self.TopFrame.RightTeam.HealthBar:SetValue(RightVal)
end

function ezSpectator_InterfaceWorker:ProcessWinner(winnerTeamID)
	for playerName, playerObject in pairs(self.Players) do
		playerObject:SetWinner(winnerTeamID == playerObject.Team)
	end
end

function ezSpectator_InterfaceWorker:ResetViewpoint()
	self.Viewpoint = nil

	for playerName, playerObject in pairs(self.Players) do
		if not playerObject.IsDead then
			playerObject.SmallFrame:SetAlpha(1)
		end

		playerObject.PlayerFrame:Hide()
		playerObject.VictimFrame:Hide()
	end
end

function ezSpectator_InterfaceWorker:ResetVictims()
	for playerName, playerObject in pairs(self.Players) do
		playerObject.VictimFrame:Hide()
	end
end