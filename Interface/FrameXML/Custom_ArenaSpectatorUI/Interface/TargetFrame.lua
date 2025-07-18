ezSpectator_TargetFrame = {}
ezSpectator_TargetFrame.__index = ezSpectator_TargetFrame

function ezSpectator_TargetFrame:Create(Parent, ...)
    local self = {}
    setmetatable(self, ezSpectator_TargetFrame)

    self.Parent = Parent

    self.Backdrop = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.Backdrop:SetFrameLevel(1)
    self.Backdrop:SetFrameStrata('BACKGROUND')
    self.Backdrop:SetSize(224, 58)
    self.Backdrop:SetScale(0.5 * _ezSpectatorScale)
    self.Backdrop:SetPoint(...)

	self.Backdrop.texture = self.Backdrop:CreateTexture(nil, "BACKGROUND")
	self.Backdrop.texture:SetAllPoints()
	self.Backdrop.texture:SetAtlas("Custom-ArenaSpectator-TargetFrame-Backdrop", true)

    self.Normal = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.Normal:SetFrameLevel(1)
    self.Normal:SetFrameStrata('LOW')
    self.Normal:SetSize(224, 58)
    self.Normal:SetScale(0.5 * _ezSpectatorScale)
    self.Normal:SetPoint(...)

	self.Normal.texture = self.Normal:CreateTexture(nil, "BACKGROUND")
	self.Normal.texture:SetAllPoints()
	self.Normal.texture:SetAtlas("Custom-ArenaSpectator-TargetFrame-Normal", true)

    self.HealthBar = ezSpectator_HealthBar:Create(self.Parent, false, false, 8 * 1, 103, 18,  _ezSpectatorScale, 'TOPLEFT', self.Normal, 'TOPLEFT', 4, -5)

    return self
end

function ezSpectator_TargetFrame:SetPoint(...)
    self.Backdrop:ClearAllPoints()
    self.Normal:ClearAllPoints()

    self.Backdrop:SetPoint(...)
    self.Normal:SetPoint(...)
end

function ezSpectator_TargetFrame:Hide()
    self.Backdrop:Hide()
    self.Normal:Hide()
    self.HealthBar:Hide()
end

function ezSpectator_TargetFrame:Show()
	if self.unitObject then
        self.Backdrop:Show()
        self.Normal:Show()
        self.HealthBar:Show()
	end
end

function ezSpectator_TargetFrame:Reset()
	self.unitObject = nil
	self:Hide()
end

function ezSpectator_TargetFrame:SetAlpha(Value)
    self.Backdrop:SetAlpha(Value)
    self.Normal:SetAlpha(Value)
    self.HealthBar:SetAlpha(Value)
end

function ezSpectator_TargetFrame:GetUnit()
	return self.unitObject
end

function ezSpectator_TargetFrame:SetUnit(unitObject)
	local isSameUnit

	if self.unitObject then
		if not self.unitObject.IsDead and self.unitObject ~= self.Parent.Interface.Viewpoint then
			self.unitObject.SmallFrame:SetAlpha(1)
		end

		if self.unitObject == unitObject then
			isSameUnit = true
		end
	end

	if not isSameUnit then
		self.unitObject = unitObject
		self.HealthBar:ResetAnimation()
	end
    self:Update(true)
end

function ezSpectator_TargetFrame:Update(LockAnimation)
	if self.Parent.Interface.Viewpoint and self.Parent.Interface.Viewpoint.TargetObject and (C_ArenaSpectator.IsInProgress() or C_ArenaSpectator.IsInPreparation()) then
		self.Parent.Interface.Viewpoint.TargetObject.SmallFrame:SetAlpha(self.Parent.VIEWPOINT_ALPHA)
	end

	if self.unitObject and self.unitObject:IsReady() then
		self.HealthBar:SetNickname(self.unitObject.Nickname)
		self.HealthBar:SetClass(self.unitObject.Class)
		self.HealthBar:SetMaxValue(self.unitObject.MaxHealth)
		self.HealthBar:SetValue(self.unitObject.Health, LockAnimation)
        self:Show()
    else
        self:Hide()
    end
end