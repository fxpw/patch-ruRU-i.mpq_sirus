ezSpectator_CastFrame = {}
ezSpectator_CastFrame.__index = ezSpectator_CastFrame

local CAST_TIMEOUT = 0.2

function ezSpectator_CastFrame:Create(parent, parentFrame, ...)
    local self = {}
    setmetatable(self, ezSpectator_CastFrame)

	self.Parent = parent
	self.parentFrame = parentFrame

    self.MainFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
	self.MainFrame:Hide()

    self.Backdrop = CreateFrame('Frame', nil, self.MainFrame)
    self.Backdrop:SetFrameLevel(1)
    self.Backdrop:SetFrameStrata('BACKGROUND')
    self.Backdrop:SetSize(191, 24)
    self.Backdrop:SetScale(_ezSpectatorScale)
    self.Backdrop:SetPoint(...)

	self.Backdrop.texture = self.Backdrop:CreateTexture(nil, "BACKGROUND")
	self.Backdrop.texture:SetAllPoints()
	self.Backdrop.texture:SetAtlas("Custom-ArenaSpectator-CastFrame-Backdrop", true)

    self.Normal = CreateFrame('Frame', nil, self.MainFrame)
    self.Normal:SetFrameLevel(1)
    self.Normal:SetFrameStrata('LOW')
    self.Normal:SetSize(191, 24)
    self.Normal:SetScale(_ezSpectatorScale)
    self.Normal:SetPoint(...)

	self.Normal.texture = self.Normal:CreateTexture(nil, "BACKGROUND")
	self.Normal.texture:SetAllPoints()
	self.Normal.texture:SetAtlas("Custom-ArenaSpectator-CastFrame-Normal", true)

    self.Glow = CreateFrame('Frame', nil, self.MainFrame)
    self.Glow:SetFrameLevel(1)
    self.Glow:SetFrameStrata('TOOLTIP')
    self.Glow:SetSize(191, 24)
    self.Glow:SetScale(_ezSpectatorScale)
    self.Glow:SetPoint(...)

	self.Glow.texture = self.Glow:CreateTexture(nil, "BACKGROUND")
	self.Glow.texture:SetAllPoints()
	self.Glow.texture:SetAtlas("Custom-ArenaSpectator-CastFrame-Glow", true)

    self.CastBar = ezSpectator_CastBar:Create(self.Parent, self.MainFrame, 177, 11, _ezSpectatorScale, 'TOPLEFT', self.Normal, 'TOPLEFT', 7, -6)

	self.elapsedThrottle = 0
	self.elapsedCast = 0
	self.elapsedTimeout = 0

    self.UpdateFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
	self.UpdateFrame:Hide()
	self.UpdateFrame:SetScript("OnUpdate", function(this, elapsed)
		if self.spellID and not C_ArenaSpectator.IsPaused() then
			self.elapsedThrottle = self.elapsedThrottle + (elapsed * C_ArenaSpectator.GetPlaybackSpeed())
			if self.elapsedThrottle > 0.01 then
				if self.isCasting then
					self.elapsedCast = self.elapsedCast + self.elapsedThrottle
					local isCasting = self.CastBar:SetValue(self.elapsedCast * 1000)
					if not isCasting then
						self.isCasting = nil
					end
				end

				if not self.isCasting and not self.castEndType then
					self.elapsedTimeout = self.elapsedTimeout + self.elapsedThrottle
					if self.elapsedTimeout >= CAST_TIMEOUT then
						self.castEndType = Enum.ArenaSpectator.CastType.Success
						self.CastBar:SetValue(self.castEndType)
						self:StartGlowAnim()
					end
				end

				self.elapsedThrottle = 0

				local glowAlpha = self.Glow:GetAlpha()
				local newGlowAlpha = glowAlpha + (self.glowIn and 0.025 or -0.025)

				if glowAlpha >= 1 then
					glowAlpha = 1
					self.glowIn = nil
				end
				if newGlowAlpha > 0 then
					self.Glow:SetAlpha(newGlowAlpha)
				else
					if not self.isCasting then
						self:Reset()
					end
				end
			end
		end
	end)

    return self
end

function ezSpectator_CastFrame:Show()
	self.MainFrame:Show()
end

function ezSpectator_CastFrame:Hide()
	self.MainFrame:Hide()
end

function ezSpectator_CastFrame:SetAlpha(Value)
	self.MainFrame:SetAlpha(Value)
end

function ezSpectator_CastFrame:Reset()
	self.spellID = nil
	self.spellCastTime = nil
	self.glowIn = nil
	self.isCasting = nil
	self.castEndType = nil

	self.elapsedThrottle = 0
	self.elapsedTimeout = 0
	self.elapsedCast = 0

	self.UpdateFrame:Hide()
	self.Glow:SetAlpha(0)
	self:Hide()
end

function ezSpectator_CastFrame:GetSpell()
	return self.spellID
end

function ezSpectator_CastFrame:IsInProgressMode()
	return self.isCasting
end

function ezSpectator_CastFrame:CheckState()
	if self.spellID and self.parentFrame:IsShown() then
		self:Show()
	else
		self:Hide()
	end
end

function ezSpectator_CastFrame:ForceCastEnd()
	if self.spellID and self.isCasting then
		self.isCasting = nil
	end
end

function ezSpectator_CastFrame:StartGlowAnim()
	local r, g, b = self.CastBar.ProgressBar.texture:GetVertexColor()
	self.Glow.texture:SetVertexColor(r, g, b, 0.75)
	self.Glow:SetAlpha(0)
	self.glowIn = true
end

function ezSpectator_CastFrame:ShowCast(spellID, castTime, castElapsed)
	if self.Parent.Data.CastBlacklist[spellID] then
		self:ForceCastEnd()
		return
	end

	local spellName, _, _, _, _, _, spellCastTime = GetSpellInfo(spellID)

	if spellCastTime and spellCastTime > 0 and castTime and castTime > 0 then
		self.spellID = spellID
		self.elapsedThrottle = 0
		self.elapsedTimeout = 0
		self.elapsedCast = castElapsed
		self.spellCastTime = spellCastTime

		self.isCasting = self.CastBar:SetCastType(castTime, spellName or UNKNOWN)
		if not self.isCasting then
			self.castEndType = castTime
			self:StartGlowAnim()
		end

		self.UpdateFrame:Show()
		self:CheckState()
	else
		self:ForceCastEnd()
	end
end