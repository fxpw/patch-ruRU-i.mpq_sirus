ezSpectator_SpellIcon = {}
ezSpectator_SpellIcon.__index = ezSpectator_SpellIcon

function ezSpectator_SpellIcon:Create(Parent, ParentFrame)
    local self = {}
    setmetatable(self, ezSpectator_SpellIcon)

    self.Parent = Parent

	self.fadeDelay = 0.33

    self.Normal = CreateFrame('Frame', nil, ParentFrame)
    self.Normal:SetFrameStrata('MEDIUM')
    self.Normal:SetSize(32, 32)
    self.Normal:SetScale(1)
	self.Normal:Hide()

	self.Normal.texture = self.Normal:CreateTexture(nil, "BACKGROUND")
	self.Normal.texture:SetAllPoints()
	self.Normal.texture:SetAtlas("Custom-ArenaSpectator-SpellIcon-Normal", true)

    self.Normal:EnableMouse(true)
	self.Normal:SetScript("OnMouseUp", function(this, button)
		if button == "LeftButton" then
			self.Parent.Tooltip:ShowSpell(this, self.spellID)
		end
	end)

	self.Normal.elapsed = 0
	self.Normal:SetScript("OnUpdate", function(this, elapsed)
		if C_ArenaSpectator.IsPaused() then
			return
		end

		this.elapsed = this.elapsed + elapsed * C_ArenaSpectator.GetPlaybackSpeed()

		if this.elapsed >= 0.03 then
			this.elapsed = 0

			local alpha = this:GetAlpha() - 0.01
			if alpha <= 0 then
				self:Reset()
			else
				this:SetAlpha(alpha)
			end
		end
	end)

    self.IconFrame = CreateFrame('Frame', nil, self.Normal)
    self.IconFrame:SetFrameStrata('LOW')
    self.IconFrame:SetSize(22, 22)
    self.IconFrame:SetScale(1)
    self.IconFrame:SetPoint('CENTER', self.Normal, 'CENTER', 0, 0)

    self.Icon = self.IconFrame:CreateTexture(nil, 'BORDER')
    self.Icon:SetAllPoints(self.IconFrame)
    self.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    return self
end

function ezSpectator_SpellIcon:Reset()
	self.spellID = nil
	self.spellIcon = nil
	self.Normal:SetAlpha(0)
	self.Normal.fadeEndTime = 0
	self.Normal.elapsed = 0
	self.Normal:Hide()
end

function ezSpectator_SpellIcon:SetSpell(spellID, spellIcon, alpha)
	if not spellIcon then
		return
	end

	self.spellID = spellID
	self.spellIcon = spellIcon

	self.Icon:SetTexture(spellIcon)
	self.Normal:SetAlpha(alpha)

	self.Normal.elapsed = -self.fadeDelay
	self.Normal:Show()
end