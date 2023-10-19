--	Filename:	SpectatorInterface.lua
--	Project:	Sirus Game Interface
--	Author:		loTEDve ezwow

ArenaSpectatorFrameMixin = {}

function ArenaSpectatorFrameMixin:OnLoad()
	self.replaySpeed 	= 1
	self.replayWatchID 	= 0
	self.replayData 	= {}

	self.bracketString 	= {
		[0] = BRACKET_SOLO,
		[1] = "2x2",
		[2] = "3x3",
		[3] = "5x5",
		[5] = "1x1"
	}
end

function ArenaSpectatorFrameMixin:OnHide()
	self.ReportFrame:Hide()
	self.SharedReplay:Hide()
end

function ArenaSpectatorFrameMixin:GetSpeed()
	return self.replaySpeed
end

function ArenaSpectatorFrameMixin:SpeedUp()
	local currentSpeed = self:GetSpeed()

	if currentSpeed < 2 then
		self:SetSpeed(currentSpeed + 0.25)
	end
end

function ArenaSpectatorFrameMixin:SpeedDown()
	local currentSpeed = self:GetSpeed()

	if currentSpeed > 0.25 then
		self:SetSpeed(currentSpeed - 0.25)
	end
end

function ArenaSpectatorFrameMixin:SetSpeed( speed, isSkippedServerMessage )
	self.replaySpeed = speed

	if not isSkippedServerMessage then
		SendServerMessage("ACMSG_AR_SPEED", self.replaySpeed)
	end

	ArenaSpectatorSpeedLabel:SetText("x"..self.replaySpeed)
end

function ArenaSpectatorFrameMixin:WatchReplay( replayID )
	SendServerMessage("ACMSG_AR_WATCH", replayID)
	self.replayWatchID = replayID
end

function ArenaSpectatorFrameMixin:WatchReplayAtHyperlink(link)
	local linkType, replayID = string.split(":", link)
	self:ShowReplayConfirmationWatch(tonumber(replayID))
end

function ArenaSpectatorFrameMixin:ShowReplayConfirmationWatch( replayID, isServerResponce )
	if isServerResponce and replayID ~= self.waitReplayData then
		return
	end

	local _, bracketID, bracketString, winnerTeam, team1Rating, team2Rating, team1Players, team2Players = self:GetReplayInfo(replayID)

	if bracketString then
		local dialog = StaticPopup_Show("ARENA_REPLAY_CONFIRMATION_WATCH", nil, nil, {replayID, bracketID, bracketString, winnerTeam, team1Rating, team2Rating, team1Players, team2Players})
		dialog.data  = replayID

		self.waitReplayData = nil
	else
		SendServerMessage("ACMSG_AR_GET_META_INFO", replayID)
		self.waitReplayData = replayID
	end
end

function ArenaSpectatorFrameMixin:GetWatchReplayID()
	return self.replayWatchID
end

function ArenaSpectatorFrameMixin:SharedDropDownOnLoad()
	UIDropDownMenu_Initialize(self.SharedReplay.DropDownMenu, function(_, level) self:SharedDropDownInit(level) end, "MENU")
	UIDropDownMenu_SetText(self.SharedReplay.DropDownMenu, CHOOSE_CHANNEL)
	UIDropDownMenu_JustifyText(self.SharedReplay.DropDownMenu, "LEFT", 10, 0)
	self.sharedChannel = nil
end

function ArenaSpectatorFrameMixin:SharedDropDownInit( level )
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
		ezSpectatorResumeReplay:Show()

		self:SetSpeed(0.01)
		StaticPopup_Show("ARENA_REPLAY_INGAMELINK_POPUP")
	end
	UIDropDownMenu_AddButton(info)
end

function ArenaSpectatorFrameMixin:SharedDropDownSetChannel( channel, channelName )
	self.sharedChannel = channel
	UIDropDownMenu_SetText(self.SharedReplay.DropDownMenu, channelName)
end

function ArenaSpectatorFrameMixin:SharedGetChannel()
	return self.sharedChannel
end

function ArenaSpectatorFrameMixin:GetReplayInfo( replayID )
	if not self.replayData or not self.replayData[replayID] then
		return
	end

	local bracketID 	= self.replayData[replayID].bracketID
	local bracketString = self.bracketString[bracketID]
	local winnerTeam 	= self.replayData[replayID].winnerTeam
	local team1Rating 	= self.replayData[replayID].team1Rating
	local team2Rating 	= self.replayData[replayID].team2Rating
	local team1Players 	= self.replayData[replayID].players[1]
	local team2Players 	= self.replayData[replayID].players[2]

	return replayID, bracketID, bracketString, winnerTeam, team1Rating, team2Rating, team1Players, team2Players
end

function ArenaSpectatorFrameMixin:GenerateReplayHyperlink( isEscape )
	local replayID, bracketID, bracketString, winnerTeam, team1Rating, team2Rating, team1Players, team2Players = self:GetReplayInfo(self:GetWatchReplayID())

	return string.format(isEscape and ARENA_REPLAY_ESCAPE_HYPERLINK or ARENA_REPLAY_HYPERLINK, replayID, replayID, bracketString)
end

function ArenaSpectatorFrameMixin:SendSharedReplay()
	local message 	= self.SharedReplay.EditBoxFrame.MessageFrame.EditBox:GetText()
	local channel 	= self:SharedGetChannel()
	local hyperlink = self:GenerateReplayHyperlink()

	if not channel or not hyperlink then
		return
	end

	self:Hide()
	UIParent:Show()
	ezSpectatorResumeReplay:Show()

	self:SetSpeed(0.01)

	ChatFrame_OpenChat(string.format("%s %s %s", channel, hyperlink, message or " "), DEFAULT_CHAT_FRAME)
end

function EventHandler:ASMSG_AR_SEND_META_INFO(msg)
	if msg == "" then
		StaticPopup_Show("OKAY", ARENA_REPLAY_NOT_FOUND)
		return
	end

	local bracketID, _, matchData = string.split("|", msg)
	local replayID, team1Data, team2Data, winnerTeam, ratingData = string.split(":", matchData, 5)
	local team1Rating, team2Rating = string.split(",", ratingData)

	replayID = tonumber(replayID)

	local replayData = {
		replayID = replayID,
		bracketID = tonumber(bracketID),
		winnerTeam = tonumber(winnerTeam),

		team1Rating = tonumber(team1Rating),
		team2Rating = tonumber(team2Rating),

		players = {
			[1] = {},
			[2] = {},
		}
	}

	for teamIndex, teamData in ipairs({team1Data, team2Data}) do
		local players = {string.split(",", teamData)}
		for i = 1, #players, 2 do
			local name = players[i]
			local classID = tonumber(players[i + 1])
			local className, classFileString = GetClassInfo(classID ~= 0 and classID or 1)

			table.insert(replayData.players[teamIndex], {
				name 			= name,
				className 		= className,
				classFileString = classFileString,
			})
		end
	end

	ArenaSpectatorFrame.replayData[replayID] = replayData
	ArenaSpectatorFrame:ShowReplayConfirmationWatch(replayID, true)
end