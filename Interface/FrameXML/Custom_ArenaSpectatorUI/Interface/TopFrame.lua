ezSpectator_TopFrame = {}
ezSpectator_TopFrame.__index = ezSpectator_TopFrame

function ezSpectator_TopFrame:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_TopFrame)

    self.Parent = Parent

    self.TournamentStage = nil
    self.TournamentBOX = nil

	self.MainFrame = CreateFrame("Frame", "$parentTopFrameMainFrame", ArenaSpectatorFrame)
    self.MainFrame:SetFrameStrata('BACKGROUND')
	self.MainFrame:SetWidth(GetScreenWidth() / _ezSpectatorScale)
    self.MainFrame:SetHeight(35)
    self.MainFrame:SetScale(_ezSpectatorScale)
    self.MainFrame:SetPoint('TOP', 0, 0)

	self.ServerLogo = CreateFrame("Frame", nil, self.MainFrame)
    self.ServerLogo:SetFrameStrata('TOOLTIP')
	self.ServerLogo:SetPoint("TOPRIGHT", ArenaSpectatorFrame, "TOPRIGHT", -10, -10)
    self.ServerLogo:SetSize(128, 64)
    self.ServerLogo:SetScale(_ezSpectatorScale)

	self.ServerLogo.texture = self.ServerLogo:CreateTexture(nil, "BACKGROUND")
	self.ServerLogo.texture:SetAllPoints()
	self.ServerLogo.texture:SetAlpha(0.5)

    self.LeftTeam = ezSpectator_TeamFrame:Create(self.Parent, true, 'TOP', -290, -1)
    self.RightTeam = ezSpectator_TeamFrame:Create(self.Parent, false, 'TOP', 290, -1)

    self.TimeTextFrame = CreateFrame('Frame', nil, self.MainFrame)
    self.TimeTextFrame:SetFrameStrata('TOOLTIP')
    self.TimeTextFrame:SetSize(1, 1)
    self.TimeTextFrame:SetPoint('CENTER', self.MainFrame, 'CENTER', 0, 0)

    self.Time = self.TimeTextFrame:CreateFontString(nil, 'BACKGROUND', 'SystemFont_Shadow_Huge1')
    self.Time:SetPoint('CENTER', 0, 0)

    self.UpdateFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.UpdateFrame.Parent = self
	self.UpdateFrame:Hide()
	self.UpdateFrame:SetScript("OnUpdate", function(this, elapsed)
		if C_ArenaSpectator.IsInProgress() and not C_ArenaSpectator.IsPaused() then
			local fightTime = C_ArenaSpectator.GetFightTime()

			self.Time:SetText(self.Parent.Data:SecondsToTime(fightTime))
		end
	end)

    self.TournamentTextFrame = CreateFrame('Frame', nil, self.MainFrame)
    self.TournamentTextFrame:SetFrameStrata('TOOLTIP')
    self.TournamentTextFrame:SetSize(1, 1)
    self.TournamentTextFrame:SetPoint('CENTER', self.MainFrame, 'CENTER', 0, -48)

    self.TournamentInfo = self.TournamentTextFrame:CreateFontString(nil, 'BACKGROUND', 'SystemFont_Outline')
    self.TournamentInfo:SetPoint('CENTER', 0, 0)

    self.Report = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, 'LEFT', self.MainFrame, 'LEFT', 0, 0)
    self.Report:SetIcon('report')
    self.Report:SetAction(function()
        ArenaSpectatorFrame.ReportFrame:SetShown(not ArenaSpectatorFrame.ReportFrame:IsShown())
    end)
    self.Report:SetTooltip(ARENAREPLAY_REPORT, ARENAREPLAY_REPORT_DESC)

    self.Share = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, 'LEFT', self.Report.Normal, 'RIGHT', -3, 0)
    self.Share:SetIcon('share')
    self.Share:SetAction(function()
        ArenaSpectatorFrame.SharedReplay:SetShown(not ArenaSpectatorFrame.SharedReplay:IsShown())
    end)
    self.Share:SetTooltip(ARENAREPLAY_SHARED, ARENAREPLAY_SHARED_DESC)

    self.Reset = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, 'LEFT', self.Share.Normal, 'RIGHT', -3, 0)
    self.Reset:SetIcon('Refresh')
    self.Reset:SetAction(function()
		C_ArenaSpectator.SetUnitSpectation(UnitName("player"))
        self.Parent.Interface:ResetViewpoint()
    end)
    self.Reset:SetTooltip(ARENAREPLAY_REFRESH, ARENAREPLAY_REFRESH_DESC)

    self.Leave = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, 'LEFT', self.Reset.Normal, 'RIGHT', -3, 0)
    self.Leave:SetIcon('exit')
    self.Leave:SetAction(function()
        LeaveBattlefield()
    end)
    self.Leave:SetTooltip(ARENAREPLAY_EXIT, ARENAREPLAY_EXIT_DESC)

    self.Pause = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, "CENTER", 0, -40)
    self.Pause:SetIcon('pause')
    self.Pause:SetAction(function()
        self.Pause:Hide()
        self.Play:Show()
		C_ArenaSpectator.SetPaused(true)
    end)
    self.Pause:SetTooltip(ARENAREPLAY_PAUSE, ARENAREPLAY_PAUSE_DESC)

    self.Play = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, "CENTER", 0, -40)
    self.Play:Hide()
    self.Play:SetIcon('play')
    self.Play:SetAction(function()
        self.Play:Hide()
        self.Pause:Show()
		C_ArenaSpectator.SetPaused(false)
    end)
    self.Play:SetTooltip(ARENAREPLAY_PLAY, ARENAREPLAY_PLAY_DESC)

    self.Forward = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, 'LEFT', self.Play.Normal, 'RIGHT', 2, 0)
    self.Forward:SetIcon('forward')
    self.Forward:SetAction(function()
        ArenaSpectatorFrame:SpeedUp()
    end)
    self.Forward:SetTooltip(ARENAREPLAY_FORWARD, ARENAREPLAY_FORWARD_DESC)

    self.Backward = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, 'gold', 34 / _ezSpectatorScale, 'RIGHT', self.Play.Normal, 'LEFT', -2, 0)
    self.Backward:SetIcon('backward')
    self.Backward:SetAction(function()
        ArenaSpectatorFrame:SpeedDown()
    end)
    self.Backward:SetTooltip(ARENAREPLAY_BACKWARD, ARENAREPLAY_BACKWARD_DESC)


    self.SpeedIndicator = self.TournamentTextFrame:CreateFontString('ArenaSpectatorSpeedLabel', 'BACKGROUND', 'SystemFont_Outline')
    self.SpeedIndicator:SetPoint("BOTTOM", self.Play.Normal, "TOP", 0, 4)

    self:Hide()
    return self
end

function ezSpectator_TopFrame:Hide()
    self.MainFrame:Hide()
    self.LeftTeam:Hide()
    self.RightTeam:Hide()
    self.ServerLogo:Hide()
    self.TournamentInfo:SetText('')

    self.Play:Hide()
    self.Pause:Show()
end

function ezSpectator_TopFrame:Show()
    self.MainFrame:Show()
    self.LeftTeam:Show()
    self.RightTeam:Show()
	self.ServerLogo.texture:SetAtlas(C_RealmInfo.GetServerLogo(GetServerID()))
    self.ServerLogo:Show()
	if C_ArenaSpectator.IsTournament() then
        self.TournamentStage = nil
        self.TournamentBOX = nil
    end
end

function ezSpectator_TopFrame:SetShown(shown)
	if shown then
		self:Show()
	else
		self:Hide()
	end
end

function ezSpectator_TopFrame:SetMatchInProgress(isInProgress)
	if not isInProgress then
		self.Time:SetText("00:00")
	end
	self.UpdateFrame:SetShown(isInProgress)
end

function ezSpectator_TopFrame:SetStage(Value)
    self.TournamentStage = self.Parent.Data.TournamentStages[Value]
end

function ezSpectator_TopFrame:SetBOX(Value)
    self.TournamentBOX = Value
end

function ezSpectator_TopFrame:UpdateTournamentTextFrame()
    if self.TournamentStage and self.TournamentBOX then
        self.TournamentInfo:SetText(self.TournamentStage .. ' (BO' .. self.TournamentBOX .. ')')
    end
end