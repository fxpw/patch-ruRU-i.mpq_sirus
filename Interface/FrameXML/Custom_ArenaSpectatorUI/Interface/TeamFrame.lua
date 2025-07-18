ezSpectator_TeamFrame = {}
ezSpectator_TeamFrame.__index = ezSpectator_TeamFrame

function ezSpectator_TeamFrame:Create(Parent, IsLeft, ...)
    local self = {}
    setmetatable(self, ezSpectator_TeamFrame)

    IsLeft = not IsLeft

    self.Parent = Parent

    self.Normal = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.Normal:SetFrameStrata('LOW')
    self.Normal:SetSize(482, 44)
    self.Normal:SetScale(0.75 * _ezSpectatorScale)
    self.Normal:SetPoint(...)

	self.Normal.texture = self.Normal:CreateTexture(nil, "BACKGROUND")
	self.Normal.texture:SetAllPoints()
	self.Normal.texture:SetAtlas("Custom-ArenaSpectator-TeamFrame-Normal", true)

    self.HealthBar = ezSpectator_HealthBar:Create(self.Parent, IsLeft, false, 12 * _ezSpectatorScale, 462, 24, 0.75 * _ezSpectatorScale, 'TOPLEFT', self.Normal, 'TOPLEFT', 10, -9)

	if not self.Parent.SHOW_TEAM_SCORE then
		self.Normal:Hide()
		self.HealthBar:Hide()
	end

    return self
end

function ezSpectator_TeamFrame:Hide()
    self.Normal:Hide()
    self.HealthBar:Hide()
end

function ezSpectator_TeamFrame:Show()
	if self.Parent.SHOW_TEAM_SCORE then
		self.Normal:Show()
		self.HealthBar:Show()
	end
end

function ezSpectator_TeamFrame:SetName(Value)
    self.HealthBar:SetNickname(Value)
end

function ezSpectator_TeamFrame:SetColor(Value)
    if Value == 'gold' then
        self.HealthBar.Backdrop.texture:SetVertexColor(0.9, 0.9, 0)
        self.HealthBar.ProgressBar.texture:SetVertexColor(0.9, 0.9, 0)
        self.HealthBar.Spark.texture:SetVertexColor(0.9, 0.9, 0)
    else
        self.HealthBar.Backdrop.texture:SetVertexColor(0, 0.75, 0)
        self.HealthBar.ProgressBar.texture:SetVertexColor(0, 0.75, 0)
        self.HealthBar.Spark.texture:SetVertexColor(0, 0.75, 0)
    end
end

function ezSpectator_TeamFrame:SetScore(Value)
    self.HealthBar:SetDescription(Value)
end