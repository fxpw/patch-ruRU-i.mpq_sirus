_ezSpectatorScale = 1.15

ArenaSpectatorFrameMixin = {}

function ArenaSpectatorFrameMixin:OnLoad()
	local playbackSpeedMin, playbackSpeedMax = C_ArenaSpectator.GetPlaybackSpeedLimits()
	self.playbackSpeedStep = 0.25
	self.playbackSpeedMin = playbackSpeedMin
	self.playbackSpeedMax = math.min(playbackSpeedMax, IsGMAccount() and playbackSpeedMax or 2)

	self.SHOW_TEAM_SCORE = false
	self.HIDE_COOLDOWN_ANIMATION = false
	self.USE_PLAYER_OBJECT_POOLS = true
	self.DRAW_AURAS_FOR_SMALL_FRAMES = false

	self.NAMEPLATE_LEVEL = 0
	self.VIEWPOINT_ALPHA = 0.33
	self.VIEWPOINT_NAMEPLATE_ALPHA = 0.50

	self.Data = ezSpectator_DataWorker:Create(self)
	self.Interface = ezSpectator_InterfaceWorker:Create(self)
	self.Tooltip = ezSpectator_TooltipWorker:Create(self)

	self:RegisterCustomEvent("ARENA_SPECTATOR_UNIT_COMMAND")
	self:RegisterCustomEvent("ARENA_SPECTATOR_TEAM_COMMAND")
	self:RegisterCustomEvent("ARENA_SPECTATOR_MODE")
	self:RegisterCustomEvent("ARENA_SPECTATOR_MATCH_START")
	self:RegisterCustomEvent("ARENA_SPECTATOR_MATCH_END")
	self:RegisterCustomEvent("ARENA_SPECTATOR_PAUSE")
	self:RegisterCustomEvent("ARENA_SPECTATOR_PLAYBACK_SPEED")
	self:RegisterCustomEvent("ARENA_SPECTATOR_TOURNAMENT_STAGE")
	self:RegisterCustomEvent("ARENA_SPECTATOR_TOURNAMENT_INFO")
	self:RegisterCustomEvent("ARENA_SPECTATOR_SCORE")
	self:RegisterCustomEvent("REPLAY_INFO_RECIEVED")
end

function ArenaSpectatorFrameMixin:OnHide()
	self.ReportFrame:Hide()
	self.SharedReplay:Hide()
end

function ArenaSpectatorFrameMixin:OnEvent(event, ...)
	if event == "ARENA_SPECTATOR_UNIT_COMMAND" then
		self:ProcessUnitCommand(...)
	elseif event == "ARENA_SPECTATOR_TEAM_COMMAND" then
		self:ProcessTeamCommand(...)
	elseif event == "ARENA_SPECTATOR_PLAYBACK_SPEED" then
		local playbackSpeed = ...
		self:SetSpeed(playbackSpeed)
	elseif event == "ARENA_SPECTATOR_MODE" then
		local spectatorMode = ...
		if spectatorMode ~= Enum.ArenaSpectator.Mode.Disabled then
			local replayID = C_ArenaSpectator.GetLastReplayID()
			if replayID then
				C_ReplayInfo.RequestInfo(replayID)
			end
		end
		self.Interface:SetMode(spectatorMode)
	elseif event == "ARENA_SPECTATOR_MATCH_START" then
		self.Interface:SetMatchInProgress(true)
	elseif event == "ARENA_SPECTATOR_MATCH_END" then
		self.Interface:SetMatchInProgress(false)
	elseif event == "ARENA_SPECTATOR_PAUSE" then
		local isPaused = ...
		self.Interface:SetPaused(isPaused)
	elseif event == "ARENA_SPECTATOR_TOURNAMENT_STAGE" then
		local tournamentStage = ...
		self.Interface:SetStage(tournamentStage)
	elseif event == "ARENA_SPECTATOR_TOURNAMENT_INFO" then
		local tournamentInfo = ...
		self.Interface:SetBOX(tournamentInfo)
	elseif event == "ARENA_SPECTATOR_SCORE" then
		local winnerTeamID = ...
		self.Interface:ProcessWinner(winnerTeamID + 1)
	elseif event == "REPLAY_INFO_RECIEVED" then
		local success, replayID = ...
		if self.waitReplayID and self.waitReplayID == replayID then
			if success then
				ArenaSpectatorFrame:ShowReplayConfirmationWatch(replayID)
			else
				StaticPopup_Show("OKAY", ARENA_REPLAY_NOT_FOUND)
			end
		end
	end
end

function ArenaSpectatorFrameMixin:GetPlayerObject(playerName)
	return self.Interface:GetPlayerObject(playerName)
end

function ArenaSpectatorFrameMixin:ProcessUnitCommand(command, playerName, ...)
	local value = ...

	if command == "AUR" then
		self:GetPlayerObject(playerName):SetAura(...)
	elseif command == "SPE" then
		local spellID, castTime = ...
		self:GetPlayerObject(playerName):SetCast(spellID, castTime)
	elseif command == "CDN" then
		local spellID, cooldownTime = ...
		self:GetPlayerObject(playerName):SetAbilityCooldown(spellID, cooldownTime)
	elseif command == "CHP" then
		self:GetPlayerObject(playerName):SetHealth(value)
	elseif command == "MHP" then
		self:GetPlayerObject(playerName):SetMaxHealth(value)
	elseif command == "CPW" then
		self:GetPlayerObject(playerName):SetPower(value)
	elseif command == "MPW" then
		self:GetPlayerObject(playerName):SetMaxPower(value)
	elseif command == "PWT" then
		self:GetPlayerObject(playerName):SetPowerType(value)
	elseif command == "TRG" then
		self:GetPlayerObject(playerName):SetTarget(value)
	elseif command == "CLA" then
		self:GetPlayerObject(playerName):SetClass(value)
	elseif command == "TAL" then
		self:GetPlayerObject(playerName):SetSpec(value)
	elseif command == "TEM" then
		self:GetPlayerObject(playerName):SetTeam(value)
	elseif command == "STA" then
		self:GetPlayerObject(playerName):SetStatus(value)
	elseif command == "LEV" then
		self:GetPlayerObject(playerName):SetHidden(value)
	else
		return
	end

	self.Interface:UpdateTeams()
	self.Interface:UpdateTargets()
end

function ArenaSpectatorFrameMixin:ProcessTeamCommand(command, teamID, ...)
	if command == "NAM" then
		local teamName = ...
		self.Interface:SetTeamName(teamID, teamName)
	elseif command == "COL" then
		local color = ...
		self.Interface:SetTeamColor(teamID, color)
	elseif command == "SRC" then
		local score = ...
		self.Interface:SetTeamScore(teamID, score)
	else
		return
	end

	self.Interface:UpdateTeams()
	self.Interface:UpdateTargets()
end

function ArenaSpectatorFrameMixin:CanSpeedUp()
	return C_ArenaSpectator.GetPlaybackSpeed() < self.playbackSpeedMax
end

function ArenaSpectatorFrameMixin:CanSpeedDown()
	return C_ArenaSpectator.GetPlaybackSpeed() > self.playbackSpeedStep
end

function ArenaSpectatorFrameMixin:SpeedUp()
	if not self:CanSpeedUp() then
		return
	end

	local speed = C_ArenaSpectator.GetPlaybackSpeed()
	local step = self.playbackSpeedStep * (IsShiftKeyDown() and 2 or 1)
	if speed < self.playbackSpeedStep then
		speed = step
	else
		speed = math.min(self.playbackSpeedMax, speed + step)
	end

	C_ArenaSpectator.SetPlaybackSpeed(speed)
end

function ArenaSpectatorFrameMixin:SpeedDown()
	if not self:CanSpeedDown() then
		return
	end

	local speed = C_ArenaSpectator.GetPlaybackSpeed()
	local step = self.playbackSpeedStep * (IsShiftKeyDown() and 2 or 1)
	if speed > self.playbackSpeedStep then
		speed = math.max(self.playbackSpeedStep, speed - step)
		C_ArenaSpectator.SetPlaybackSpeed(speed)
	end
end

function ArenaSpectatorFrameMixin:SetSpeed(speed)
	ArenaSpectatorSpeedLabel:SetFormattedText("x%s", speed)
end

function ArenaSpectatorFrameMixin:WatchReplayAtHyperlink(link)
	local linkType, replayID = string.split(":", link)
	replayID = tonumber(replayID)
	if replayID then
		self:ShowReplayConfirmationWatch(replayID)
	end
end

function ArenaSpectatorFrameMixin:ShowReplayConfirmationWatch(replayID)
	if C_ReplayInfo.GetReplayInfo(replayID) then
		self.waitReplayID = nil
		StaticPopup_Show("ARENA_REPLAY_CONFIRMATION_WATCH", nil, nil, replayID)
	else
		self.waitReplayID = replayID
		C_ReplayInfo.RequestInfo(replayID)
	end
end

function ArenaSpectatorFrameMixin:SharedDropDownOnLoad()
	UIDropDownMenu_Initialize(self.SharedReplay.DropDownMenu, function(_, level) self:SharedDropDownInit(level) end, "MENU")
	UIDropDownMenu_SetText(self.SharedReplay.DropDownMenu, CHOOSE_CHANNEL)
	UIDropDownMenu_JustifyText(self.SharedReplay.DropDownMenu, "LEFT", 10, 0)
	self.sharedChannel = nil
end

function ArenaSpectatorFrameMixin:SharedDropDownInit(level)
	if level then
		local dropDownList = "DropDownList"..level
		_G[dropDownList.."MenuBackdrop"]:Hide()
		_G[dropDownList.."ArenaSpectatorBackdrop"]:Show()
	end

	local info = UIDropDownMenu_CreateInfo()
	local channels = {GetChannelList()}

	info.text = TRADESKILL_POST
	info.isTitle = true
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)

	info.isTitle = nil
	info.notCheckable = true
	info.func = function(_, channel, channelName)
		self:SharedDropDownSetChannel(channel, channelName)
	end

	info.text = GUILD
	info.arg1 = SLASH_GUILD1
	info.arg2 = GUILD
	info.disabled = not IsInGuild()
	UIDropDownMenu_AddButton(info)

	info.text = PARTY
	info.arg1 = SLASH_PARTY1
	info.arg2 = PARTY
	info.disabled = GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0
	UIDropDownMenu_AddButton(info)

	info.text = RAID
	info.disabled = GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0
	info.arg1 = SLASH_RAID1
	info.arg2 = RAID
	UIDropDownMenu_AddButton(info)

	info.disabled = false

	for i = 1, #channels, 2 do
		local name = Chat_GetChannelShortcutName(channels[i])
		info.text = name
		info.arg1 = "/"..channels[i]
		info.arg2 = name
		UIDropDownMenu_AddButton(info)
	end

	UIDropDownMenu_AddSeparator()

	local info = UIDropDownMenu_CreateInfo()
	info.text = OTHER
	info.isTitle = true
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)
	info.isTitle = nil

	info.text = TALENT_GET_HYPERLINK_DROPDOWN_TITLE
	info.disabled = false
	info.func = function()
		self:Hide()
		UIParent:Show()
		ArenaSpectatorResumeReplay:Show()

		C_ArenaSpectator.SetPaused(true)
		StaticPopup_Show("ARENA_REPLAY_INGAMELINK_POPUP")
	end
	UIDropDownMenu_AddButton(info)
end

function ArenaSpectatorFrameMixin:SharedDropDownSetChannel(channel, channelName)
	self.sharedChannel = channel
	UIDropDownMenu_SetText(self.SharedReplay.DropDownMenu, channelName)
end

function ArenaSpectatorFrameMixin:SharedGetChannel()
	return self.sharedChannel
end

function ArenaSpectatorFrameMixin:GenerateReplayHyperlink(isEscape)
	local lastReplayID = C_ArenaSpectator.GetLastReplayID()
	if lastReplayID then
		local replayID, bracketID, bracketName, bracketSize, winnerTeamID, team1Rating, team2Rating = C_ReplayInfo.GetReplayInfo(lastReplayID)
		if replayID then
			local link = string.format(ARENA_REPLAY_HYPERLINK, replayID, replayID, bracketName)
			if isEscape then
				link = string.gsub(link, "|", "||")
			end
			return link
		end
	end
end

function ArenaSpectatorFrameMixin:SendSharedReplay()
	local channel = self:SharedGetChannel()
	local hyperlink = self:GenerateReplayHyperlink()

	if not channel or not hyperlink then
		return
	end

	local message = self.SharedReplay.EditBoxFrame.MessageFrame.EditBox:GetText()

	if C_ArenaSpectator.IsPaused() then
		self:SetSharedReplay(channel, hyperlink, message)
	else
		C_ArenaSpectator.SetPaused(true)

		EventRegistry:RegisterFrameEventAndCallback("ARENA_SPECTATOR_PAUSE", function(owner, isPaused)
			self:SetSharedReplay(channel, hyperlink, message)
			EventRegistry:UnregisterFrameEventAndCallback("ARENA_SPECTATOR_PAUSE", owner)
		end, "ArenaSpectatorFrame")
	end
end

function ArenaSpectatorFrameMixin:SetSharedReplay(channel, hyperlink, message)
	self:Hide()
	UIParent:Show()
	ArenaSpectatorResumeReplay:Show()
	ChatFrame_OpenChat(string.format("%s %s %s", channel, hyperlink, message or " "), DEFAULT_CHAT_FRAME)
end