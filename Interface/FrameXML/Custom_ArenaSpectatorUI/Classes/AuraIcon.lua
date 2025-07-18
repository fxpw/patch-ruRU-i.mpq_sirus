ezSpectator_AuraIcon = {}
ezSpectator_AuraIcon.__index = ezSpectator_AuraIcon

function ezSpectator_AuraIcon:Create(Parent, ParentFrame, Size)
    local self = {}
    setmetatable(self, ezSpectator_AuraIcon)

    self.Parent = Parent

    self.MainFrame = CreateFrame('Button', nil, ParentFrame)
    self.MainFrame:SetSize(Size, Size)
    self.MainFrame:Hide()

    self.MainFrame:EnableMouse(true)
	self.MainFrame:SetScript("OnMouseUp", function(this, button)
		if self.MainFrame:IsShown() then
			self.Parent.Tooltip:ShowSpell(self.MainFrame, self.spellID)
			if IsGMAccount() then
				self.Parent.Tooltip.TooltipFrame:AddLine(strconcat("CasterGUID: ", self.casterGUID), 0.4, 0.4, 0.4)
				self.Parent.Tooltip.TooltipFrame:Show()
			end
		end
	end)

    self.Cooldown = CreateFrame('Frame', nil, self.MainFrame, "CustomCooldownFrameTemplate")
	self.Cooldown:UseArenaSpectatorTimescale(true)
    self.Cooldown:SetAllPoints(self.MainFrame)

    self.Icon = self.MainFrame:CreateTexture(nil, 'BORDER')
    self.Icon:SetAllPoints(self.MainFrame)
    self.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    self.StackCount = self.MainFrame:CreateFontString(nil, 'OVERLAY')
    self.StackCount:SetFont('Interface\\CustomFonts\\DejaVuSansCondensed.ttf', 9, 'OUTLINE')
    self.StackCount:SetTextColor(1, 1, 1, 1)
    self.StackCount:SetPoint('BOTTOMLEFT', self.MainFrame, 'BOTTOMLEFT', 0, 1)

    self.OverlayFrame = CreateFrame('Frame', nil, self.MainFrame)
    self.OverlayFrame:SetFrameStrata('TOOLTIP')
    self.OverlayFrame:SetPoint('TOPLEFT', self.MainFrame, 'TOPLEFT', -2, 2)
    self.OverlayFrame:SetPoint('BOTTOMRIGHT', self.MainFrame, 'BOTTOMRIGHT', 2, -2)

    self.Overlay = self.OverlayFrame:CreateTexture(nil, 'OVERLAY')
	self.Overlay:SetAtlas("Custom-ArenaSpectator-AuraIcon-Border", true)
    self.Overlay:SetAllPoints(self.OverlayFrame)

    return self
end

function ezSpectator_AuraIcon:SetPoint(...)
	self.MainFrame:SetPoint(...)
end

function ezSpectator_AuraIcon:ClearAllPoints()
	self.MainFrame:ClearAllPoints()
end

function ezSpectator_AuraIcon:Hide()
	self.MainFrame:Hide()
	self:Reset()
end

function ezSpectator_AuraIcon:Reset()
	self.IsFree = true
	self.isDebuff = nil
	self.spellID = nil
	self.Cooldown:Clear()
	self.MainFrame:SetScript("OnUpdate", nil)
end

function ezSpectator_AuraIcon:SetAuraInfo(auraInfo, skipFadeAnimation)
	local spellIcon = select(3, GetSpellInfo(auraInfo.spellID))
	if not spellIcon then
		return
	end

	self.spellID = auraInfo.spellID
	self.casterGUID = auraInfo.casterGUID

	self.Icon:SetTexture(spellIcon)
	self.StackCount:SetText((auraInfo.stackCount > 1 and auraInfo.stackCount))

	if auraInfo.duration > 0 then
		self.Cooldown:SetCooldown(auraInfo.castTime, auraInfo.duration / 1000)
		self.Cooldown:Show()
	else
		self.Cooldown:Hide()
	end

	if auraInfo.isDebuff then
		local debuffTypeName = self.Parent.Data.DebuffList[auraInfo.debuffType]
		local debuffColor = debuffTypeName and self.Parent.Data.DebuffColor[debuffTypeName] or self.Parent.Data.DebuffColor.none

		self.Overlay:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b)

		if auraInfo.debuffType > 0 then
			self.OverlayFrame.ElapsedTick = 0
			self.OverlayFrame.IsRising = true
			self.OverlayFrame.CurrentAlpha = 1

			self.OverlayFrame:SetScript("OnUpdate", function(this, elapsed)
				this.ElapsedTick = this.ElapsedTick + elapsed

				if this.ElapsedTick > 0.01 then
					this.ElapsedTick = 0

					if this.IsRising then
						this.CurrentAlpha = this.CurrentAlpha - 0.07
						if this.CurrentAlpha < 0.2 then
							this.IsRising = false
						end
					else
						this.CurrentAlpha = this.CurrentAlpha + 0.07
						if this.CurrentAlpha > 1 then
							this.IsRising = true
						end
					end

					this:SetAlpha(this.CurrentAlpha)
				end
			end)
		end
	else
		self.Overlay:SetVertexColor(0, 0, 0)
		self.OverlayFrame:SetScript('OnUpdate', nil)
	end

	if self.IsFree and not skipFadeAnimation then
		self.IsFree = false
		self.MainFrame:SetAlpha(0)

		self.MainFrame.ElapsedTick = 0
		self.MainFrame:SetScript("OnUpdate", function(this, elapsed)
			this.ElapsedTick = this.ElapsedTick + elapsed

			if this.ElapsedTick > 0.01 then
				this.ElapsedTick = 0

				this:SetAlpha(this:GetAlpha() + 0.03)
				if this:GetAlpha() == 1 then
					this:SetScript("OnUpdate", nil)
				end
			end
		end)
	else
		self.MainFrame:SetAlpha(1)
	end

	self.MainFrame:Show()
end