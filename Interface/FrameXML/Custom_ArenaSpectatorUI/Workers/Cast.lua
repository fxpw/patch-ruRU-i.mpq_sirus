ezSpectator_CastWorker = {}
ezSpectator_CastWorker.__index = ezSpectator_CastWorker

function ezSpectator_CastWorker:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_CastWorker)

    self.Parent = Parent

    self.ControlIcon = nil
    self.Class = nil

	self.auraPriority = 0
	self.auraInfo = nil
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

function ezSpectator_CastWorker:BindIcon(IconClass)
    self.ControlIcon = IconClass
end

function ezSpectator_CastWorker:SetClass(Class, Size)
    Size = Size or 17

    self.CurrentAuraLevel = -1

    if Class then
        self.Class = Class
    end

    if self.Class then
        local OffsetTable = self.Parent.Data.ClassIconOffset[self.Class]
        if OffsetTable then
            self.ControlIcon:SetTexture('Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes', Size, false)
            local Left, Right, Top, Bottom = unpack(OffsetTable)
            Left = Left + (Right - Left) * 0.08
            Right = Right - (Right - Left) * 0.08
            Top = Top + (Bottom - Top) * 0.08
            Bottom = Bottom - (Bottom - Top) * 0.08

            self.ControlIcon.Icon.texture:SetTexCoord(Left, Right, Top, Bottom)
        end
    end
end

function ezSpectator_CastWorker:Reset()
	self:ResetIcon()
end

function ezSpectator_CastWorker:ResetIcon(iconSize)
	self.auraPriority = 0
	self.auraInfo = nil
	self.ControlIcon.Cooldown:Clear()
	self:SetClass(nil, iconSize)
--	self:DoAnimate(false)
end

function ezSpectator_CastWorker:Update(auraWidget, iconSize)
	iconSize = iconSize or 17

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
		self.ControlIcon:SetTexture(spellIcon or [[Interface\Icons\INV_Misc_QuestionMark]], iconSize, true)
		self.ControlIcon.Cooldown:SetCooldown(auraInfo.castTime, auraInfo.duration / 1000)
	--	self:DoAnimate(true)
	elseif self.auraInfo then
		self:ResetIcon(iconSize)
	end
end

function ezSpectator_CastWorker:DoAnimate(Value)
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