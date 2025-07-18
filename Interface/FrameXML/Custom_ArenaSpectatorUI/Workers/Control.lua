ezSpectator_ControlWorker = {}
ezSpectator_ControlWorker.__index = ezSpectator_ControlWorker

function ezSpectator_ControlWorker:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_ControlWorker)

    self.Parent = Parent

	self.iconSize = 17
	self.auraPriority = 0

    self.IsAnimated = false

    self.UpdateFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.UpdateFrame.Parent = self
    self.UpdateFrame.ElapsedTick = 0
    self.UpdateFrame.UpdateTick = 0.5
    self.UpdateFrame.IsRising = false
    self.UpdateFrame.CurrentAlpha = 1
	self.UpdateFrame:SetScript("OnUpdate", function(this, elapsed)
		this.ElapsedTick = this.ElapsedTick + elapsed

		if this.ElapsedTick > this.UpdateTick then
			this.ElapsedTick = 0
			this.UpdateTick = 0.01

			if self.IsAnimated and self.ControlIcon and self.ControlIcon.Backdrop:IsShown() then
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

				self.ControlIcon.Icon:SetAlpha(this.CurrentAlpha)
			end
		end
	end)

    return self
end

function ezSpectator_ControlWorker:BindIcon(IconClass)
    self.ControlIcon = IconClass
	self.ControlIcon.Reactor:SetScript("OnMouseUp", function(this, button)
		if self.zodiacID then
			local raceID, name, description, icon, atlas = C_ZodiacSign.GetZodiacSignInfo(self.zodiacID)
			if name then
				self.Parent.Tooltip:ShowText(this, name, description)
				if IsGMAccount() then
					self.Parent.Tooltip.TooltipFrame:AddLine(strconcat("ZodiacID: ", self.zodiacID), 0.4, 0.4, 0.4)
					self.Parent.Tooltip.TooltipFrame:Show()
				end
			end
		end
	end)
end

function ezSpectator_ControlWorker:SetClass(Class, iconSize)
	self.iconSize = iconSize or 17
	self.currentAuraPriority = 0

    if Class then
        self.Class = Class
    end

	if self.zodiacIcon then
		self.ControlIcon:SetTexture(self.zodiacIcon, self.iconSize, true)
		return
	end

    if self.Class then
        local OffsetTable = self.Parent.Data.ClassIconOffset[self.Class]
        if OffsetTable then
			self.ControlIcon:SetTexture('Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes', self.iconSize, false)
            local Left, Right, Top, Bottom = unpack(OffsetTable)
            Left = Left + (Right - Left) * 0.08
            Right = Right - (Right - Left) * 0.08
            Top = Top + (Bottom - Top) * 0.08
            Bottom = Bottom - (Bottom - Top) * 0.08

            self.ControlIcon.Icon.texture:SetTexCoord(Left, Right, Top, Bottom)
        end
    end
end

function ezSpectator_ControlWorker:SetZodiac(zodiacID)
	if zodiacID == 0 then
		self.zodiacID = nil
		self.zodiacIcon = nil

		if not self.auraInfo then
			self:SetClass(self.Class, self.iconSize)
		end
	else
		local raceID, name, description, icon, atlas = C_ZodiacSign.GetZodiacSignInfo(zodiacID)
		if icon then
			self.zodiacID = zodiacID
			self.zodiacIcon = icon

			if not self.auraInfo then
				self.ControlIcon:SetTexture(self.zodiacIcon, self.iconSize, true)
			end
		end
	end
end

function ezSpectator_ControlWorker:Reset()
	self.iconSize = 17
	self.zodiacID = nil
	self.zodiacIcon = nil
	self:ResetIcon()
end

function ezSpectator_ControlWorker:ResetIcon(iconSize)
	self.iconSize = iconSize or 17
	self.auraPriority = 0
	self.auraInfo = nil
	self.ControlIcon.Cooldown:Clear()
	self:SetClass(nil, iconSize)
--	self:DoAnimate(false)
end

function ezSpectator_ControlWorker:Update(auraWidget, iconSize)
	self.iconSize = iconSize or 17

	local priority, auraInfo = auraWidget:GetBestCrowdControlAura(self.auraPriority, self.auraInfo)
	if auraInfo then
		if self.auraInfo
		and self.auraInfo.spellID == auraInfo.spellID
		and self.auraInfo.casterGUID == auraInfo.casterGUID
		then
			-- same aura
			return
		end

		self.auraPriority = priority
		self.auraInfo = auraInfo

		local _, _, spellIcon = GetSpellInfo(auraInfo.spellID)
		self.ControlIcon:SetTexture(spellIcon or [[Interface\Icons\INV_Misc_QuestionMark]], self.iconSize, true)
		self.ControlIcon.Cooldown:SetCooldown(auraInfo.castTime, auraInfo.duration / 1000)
	--	self:DoAnimate(true)
	elseif self.auraInfo then
		self:ResetIcon(iconSize)
	end
end

function ezSpectator_ControlWorker:DoAnimate(Value)
    if not self.IsAnimated and Value then
        self.UpdateFrame.UpdateTick = 0.5
        self.UpdateFrame.IsRising = false
        self.UpdateFrame.CurrentAlpha = 1

        if self.ControlIcon.Backdrop:IsShown() then
            self.ControlIcon:SetCooldown(0, 0)
        end
    end

    self.IsAnimated = Value
    if not Value then
        self.ControlIcon.Icon:SetAlpha(1)
    end
end