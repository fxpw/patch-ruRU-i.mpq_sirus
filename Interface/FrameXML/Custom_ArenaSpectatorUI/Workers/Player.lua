ezSpectator_PlayerWorker = {}
ezSpectator_PlayerWorker.__index = ezSpectator_PlayerWorker

local FACTION_OVERRIDE_BY_DEBUFFS = FACTION_OVERRIDE_BY_DEBUFFS
local S_CATEGORY_SPELL_ID = S_CATEGORY_SPELL_ID
local S_VIP_STATUS_DATA = S_VIP_STATUS_DATA
local S_PREMIUM_SPELL_ID = S_PREMIUM_SPELL_ID
local ZODIAC_DEBUFFS = ZODIAC_DEBUFFS

function ezSpectator_PlayerWorker:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_PlayerWorker)

    self.Parent = Parent
    self.IsHealer = false

    self.SmallFrame = ezSpectator_SmallFrame:Create(self.Parent, self)
    self.SmallFrame:Hide()
	self.SmallFrame.SpellFrame = ezSpectator_SpellFrame:Create(self.Parent, 3)

    self.SmallControlWorker = ezSpectator_ControlWorker:Create(self.Parent)
    self.SmallControlWorker:BindIcon(self.SmallFrame.ControlIcon)

	self.PlayerFrame = ezSpectator_BindFrame:Create(self.Parent, self, false)
	self.PlayerFrame:SetPoint("BOTTOMRIGHT", ArenaSpectatorFrame, "BOTTOM", -10, 20)
    self.PlayerFrame:Hide()
	self.PlayerFrame.AuraFrame:SetAlignment(true, false)
--	self.PlayerFrame.AuraFrame:SetShowBuffs(false)
	self.PlayerFrame.SpellFrame = ezSpectator_SpellFrame:Create(self.Parent, 4)
	self.PlayerFrame.SpellFrame:SetPoint("TOPRIGHT", self.PlayerFrame.Normal, "TOPLEFT", 0, -19)
	self.PlayerFrame.SpellFrame:SetAlignment(false)

    self.PlayerControlWorker = ezSpectator_ControlWorker:Create(self.Parent)
    self.PlayerControlWorker:BindIcon(self.PlayerFrame.ControlIcon)

	self.VictimFrame = ezSpectator_BindFrame:Create(self.Parent, self, true)
	self.VictimFrame:SetPoint("BOTTOMLEFT", ArenaSpectatorFrame, "BOTTOM", 10, 20)
    self.VictimFrame:Hide()
	self.VictimFrame.AuraFrame:SetAlignment(false, false)
--	self.PlayerFrame.AuraFrame:SetShowBuffs(false)
	self.VictimFrame.SpellFrame = ezSpectator_SpellFrame:Create(self.Parent, 4)
	self.VictimFrame.SpellFrame:SetPoint("TOPLEFT", self.VictimFrame.Normal, "TOPRIGHT", 0, -19)
	self.VictimFrame.SpellFrame:SetAlignment(true)

    self.VictimControlWorker = ezSpectator_ControlWorker:Create(self.Parent)
    self.VictimControlWorker:BindIcon(self.VictimFrame.ControlIcon)

    self.CastQueue = ezSpectator_DataStack:Create('FIFO')

	self.SpellCooldown = ezSpectator_CooldownFrame:Create(self.Parent)
	self.SpellCooldown:SetDisplaySettings(6, 3)
	self.SpellCooldown:Hide()

	self:Reset()

    return self
end

function ezSpectator_PlayerWorker:Hide()
    self.SmallFrame:Hide()
    self.PlayerFrame:Hide()
    self.VictimFrame:Hide()
	self.SpellCooldown:Hide()
end

function ezSpectator_PlayerWorker:Show()
    self.SmallFrame:Show()
end

function ezSpectator_PlayerWorker:IsShown()
    return self.SmallFrame.Backdrop:IsShown()
end

function ezSpectator_PlayerWorker:Reset()
	self.CastQueue:Reset()
	self.SmallFrame:Reset()
	self.PlayerFrame:Reset()
	self.VictimFrame:Reset()

	self.NameplateObject = nil
	self.TargetObject = nil
	self.TeamFrame = nil

	self.isHidden = false
	self.IsDead = false

	self.IsNicknameSet = false
	self.Nickname = nil

	self.IsClassSet = false
	self.Class = nil

	self.IsMaxHealthSet = false
	self.MaxHealth = nil

	self.IsHealthSet = false
	self.Health = nil

	self.IsMaxPowerSet = false
	self.IsPowerTypeSet = false
	self.IsPowerSet = false

	self.IsTeamSet = false
	self.Team = nil
end

function ezSpectator_PlayerWorker:ShowOnDataReady()
	if not self:IsShown() and self:IsReady() then
		self:Show()
	end
end

function ezSpectator_PlayerWorker:IsReady()
	if self.isHidden then
		return false
	end

	return self.IsTeamSet and self.IsNicknameSet and self.IsClassSet and self.IsPowerTypeSet and self.IsMaxHealthSet and self.IsMaxPowerSet and self.IsHealthSet and self.IsPowerSet
end

function ezSpectator_PlayerWorker:GetSpecData(specIndex)
	if not self.Class or not specIndex or specIndex == 0 then
		return ""
	end

	local specID, name, description, icon, roleFlag, isRecommended, specNum = GetSpecializationInfoForClassID(tonumber(self.Class), specIndex)
	return name, icon, bit.band(roleFlag, S_SPECIALIZATION_ROLE_HEAL_FLAG)
end

function ezSpectator_PlayerWorker:SetNickname(Nickname)
	if self.isHidden then
		return
	end

    self.Nickname = Nickname
    self.IsNicknameSet = true

    self.SmallFrame.HealthBar:SetNickname(Nickname)
    self.PlayerFrame.HealthBar:SetNickname(Nickname)
    self.VictimFrame.HealthBar:SetNickname(Nickname)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetClass(Class)
	if self.isHidden then
		return
	end

    self.Class = Class
    self.IsClassSet = true

    self.SmallControlWorker:SetClass(Class)
    self.PlayerControlWorker:SetClass(Class)
    self.VictimControlWorker:SetClass(Class)

    self.SmallFrame.HealthBar:SetClass(Class)
    self.PlayerFrame.HealthBar:SetClass(Class)
    self.VictimFrame.HealthBar:SetClass(Class)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetPowerType(Power)
	if self.isHidden then
		return
	end

    self.IsPowerTypeSet = true
    self.SmallFrame.PowerBar:SetPowerType(Power)
    self.PlayerFrame.PowerBar:SetPowerType(Power)
    self.VictimFrame.PowerBar:SetPowerType(Power)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetMaxHealth(Value)
	if self.isHidden then
		return
	end

    self.MaxHealth = Value
    self.IsMaxHealthSet = true

    self.SmallFrame.HealthBar:SetMaxValue(Value)
    self.PlayerFrame.HealthBar:SetMaxValue(Value)
    self.VictimFrame.HealthBar:SetMaxValue(Value)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetMaxPower(Value)
	if self.isHidden then
		return
	end

    self.IsMaxPowerSet = true
    self.SmallFrame.PowerBar:SetMaxValue(Value)
    self.PlayerFrame.PowerBar:SetMaxValue(Value)
    self.VictimFrame.PowerBar:SetMaxValue(Value)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetHealth(Value)
	if self.isHidden then
		return
	end

    self.Health = Value
    self.IsHealthSet = true

    self.SmallFrame.HealthBar:SetValue(Value)
    self.PlayerFrame.HealthBar:SetValue(Value)
    self.VictimFrame.HealthBar:SetValue(Value)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetPower(Value)
	if self.isHidden then
		return
	end

    self.IsPowerSet = true
    self.SmallFrame.PowerBar:SetValue(Value)
    self.PlayerFrame.PowerBar:SetValue(Value)
    self.VictimFrame.PowerBar:SetValue(Value)

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetCast(spellID, castTime)
	if self.isHidden or not spellID or not castTime then
		return false
	end

	if (self.Parent.Data.Trinkets[spellID] ~= nil) then
		local now = C_ArenaSpectator.GetMatchTime()
		local cooldownTime = self.Parent.Data.Trinkets[spellID]

		self.SmallFrame.SpellFrame:LogSpellCast(spellID)
		self.SmallFrame.TrinketIcon:SetCooldown(now, cooldownTime)

		self.PlayerFrame.SpellFrame:LogSpellCast(spellID)
		self.PlayerFrame.TrinketIcon:SetCooldown(now, cooldownTime)

		self.VictimFrame.SpellFrame:LogSpellCast(spellID)
		self.VictimFrame.TrinketIcon:SetCooldown(now, cooldownTime)
		return true
	end

	if castTime == Enum.ArenaSpectator.CastType.Success then
		self.SmallFrame.SpellFrame:LogSpellCast(spellID)
		self.PlayerFrame.SpellFrame:LogSpellCast(spellID)
		self.VictimFrame.SpellFrame:LogSpellCast(spellID)
	end

	local IsCastState = self.Parent.Data.CastInfo[castTime] ~= nil

	if self.SmallFrame:IsCastProgressing() and not IsCastState then
		if spellID and castTime then
			local castInfo = {}
			castInfo.spellID = spellID
			castInfo.castTime = castTime
			castInfo.startTime = C_ArenaSpectator.GetMatchTime()

			self.CastQueue:Push(castInfo)
		end

		return false
	else
		local castElapsed = 0
		if not IsCastState then
			local castInfo = self.CastQueue:Pop()
			if castInfo then
				spellID = castInfo.spellID
				castTime = castInfo.castTime
				castElapsed = (C_ArenaSpectator.GetMatchTime() - castInfo.startTime)
			end
		end

		self.SmallFrame.CastFrame:ShowCast(spellID, castTime, castElapsed)
		self.PlayerFrame.CastFrame:ShowCast(spellID, castTime, castElapsed)
		self.VictimFrame.CastFrame:ShowCast(spellID, castTime, castElapsed)

		if self.NameplateObject then
			self.NameplateObject:ShowCast(spellID, castTime, castElapsed)
		end

		return true
	end
end

function ezSpectator_PlayerWorker:SetTeam(teamID)
	if self.isHidden or not teamID or self.IsTeamSet then
		return
	end

	if teamID == 67 then
		teamID = 1
		self.TeamFrame = self.Parent.Interface:GetTeam(teamID)
	elseif teamID == 469 then
		teamID = 2
		self.TeamFrame = self.Parent.Interface:GetTeam(teamID)
	else
		self.TeamFrame = nil
		return
	end

	self.Team = teamID
	self.IsTeamSet = true

	table.insert(self.Parent.Interface.Teams[teamID], self)
	self:SetPosition(teamID, #self.Parent.Interface.Teams[teamID])

	self:ShowOnDataReady()
end

function ezSpectator_PlayerWorker:SetPosition(teamID, playerIndex)
	if self.isHidden then
		return
	end

	local offsetY = ((playerIndex - 1) * 180 + 125) * -1

	self.SmallFrame.teamID = teamID or -1

	self.SmallFrame:ClearAllPoints()
	self.SmallFrame.SpellFrame:ClearAllPoints()
	self.SpellCooldown.MainFrame:ClearAllPoints()

	if teamID == 1 then
		self.SmallFrame:SetPoint("TOPLEFT", ArenaSpectatorFrame, "TOPLEFT", 0, offsetY)
		self.SmallFrame.SpellFrame:SetPoint("TOPLEFT", self.SmallFrame.Normal, "TOPRIGHT", 0, -19)
		self.SpellCooldown.MainFrame:SetPoint("TOPLEFT", self.SmallFrame.Normal, "BOTTOMLEFT", 2, -12)

		if self.Parent.DRAW_AURAS_FOR_SMALL_FRAMES then
			self.SmallFrame.AuraFrame:SetAlignment(true, true)
		end
	elseif teamID == 2 then
		self.SmallFrame:SetPoint("TOPRIGHT", ArenaSpectatorFrame, "TOPRIGHT", 0, offsetY)
		self.SmallFrame.SpellFrame:SetPoint("TOPRIGHT", self.SmallFrame.Normal, "TOPLEFT", 0, -19)
		self.SpellCooldown.MainFrame:SetPoint("TOPRIGHT", self.SmallFrame.Normal, "BOTTOMRIGHT", -2, -12)

		if self.Parent.DRAW_AURAS_FOR_SMALL_FRAMES then
			self.SmallFrame.AuraFrame:SetAlignment(false, true)
		end
	end

	self.SmallFrame.SpellFrame:SetAlignment(teamID == 1)
	self.SpellCooldown:SetAlignment(teamID == 1)
	self.SpellCooldown:Show()
end

function ezSpectator_PlayerWorker:SetStatus(Value)
	if self.isHidden then
		return
	end

    self.IsDead = Value == 0

    if Value == 0 then
        self:SetHealth(0)
        self:SetPower(0)

        self.SmallFrame:SetAlpha(0.5)
        self.SmallFrame.HealthBar:SetOverride(ARENA_SPECTATOR_PLAYER_DEAD)
		if self.Parent.DRAW_AURAS_FOR_SMALL_FRAMES then
			self.SmallFrame.AuraFrame:Hide()
		end

        self.PlayerFrame:SetAlpha(0.5)
        self.PlayerFrame.HealthBar:SetOverride(ARENA_SPECTATOR_PLAYER_DEAD)
        self.PlayerFrame.AuraFrame:Hide()

        self.VictimFrame:SetAlpha(0.5)
        self.VictimFrame.HealthBar:SetOverride(ARENA_SPECTATOR_PLAYER_DEAD)
        self.VictimFrame.AuraFrame:Hide()
    end

    if Value == 1 then
        self.SmallFrame:SetAlpha(1)
        self.SmallFrame.HealthBar:SetOverride(nil)

        self.PlayerFrame:SetAlpha(1)
        self.PlayerFrame.HealthBar:SetOverride(nil)

        self.VictimFrame:SetAlpha(1)
        self.VictimFrame.HealthBar:SetOverride(nil)

        if self:IsReady() then
			if self.Parent.DRAW_AURAS_FOR_SMALL_FRAMES then
				self.SmallFrame.AuraFrame:Show()
			end
            self.PlayerFrame.AuraFrame:Show()
            self.VictimFrame.AuraFrame:Show()
        end
    end
end

function ezSpectator_PlayerWorker:SetTarget(targetName)
	if self.isHidden then
		return
	end

	local targetObject = self.Parent.Interface.Players[targetName]
	if targetObject then
		self.TargetObject = targetObject
		self.SmallFrame.Target:SetUnit(targetObject)
	end

	if self.TargetObject and self.PlayerFrame:IsShown() then
        self.Parent.Interface:ResetVictims()
		self.TargetObject.VictimFrame:Show()
    end
end

function ezSpectator_PlayerWorker:SetSpec(specIndex)
	if self.isHidden then
		return
	end

	local SpecName, SpecIcon, IsHealer = self:GetSpecData(specIndex)
    self.IsHealer = IsHealer

    self.SmallFrame.HealthBar:SetDescription(SpecName)
    self.PlayerFrame.HealthBar:SetDescription(SpecName)
    self.VictimFrame.HealthBar:SetDescription(SpecName)

    self.SmallFrame.SpecIcon:SetTexture(SpecIcon or "Interface\\ICONS\\INV_Misc_QuestionMark", 17, true)
    self.PlayerFrame.SpecIcon:SetTexture(SpecIcon or "Interface\\ICONS\\INV_Misc_QuestionMark", 17, true)
    self.VictimFrame.SpecIcon:SetTexture(SpecIcon or "Interface\\ICONS\\INV_Misc_QuestionMark", 17, true)
end

function ezSpectator_PlayerWorker:SetAura(spellID, isRemoved, ...)
	if self.isHidden then
		return
	end

	if self.Parent.Data.AuraBlockList[spellID] then
		return
	end

	if ZODIAC_DEBUFFS[spellID] then
		local zodiacID
		if isRemoved then
			zodiacID = 0
		else
			zodiacID = ZODIAC_DEBUFFS[spellID]
		end

		self.SmallControlWorker:SetZodiac(zodiacID)
		self.PlayerControlWorker:SetZodiac(zodiacID)
		self.VictimControlWorker:SetZodiac(zodiacID)
		return
	end

	if FACTION_OVERRIDE_BY_DEBUFFS[spellID]
	or S_CATEGORY_SPELL_ID[spellID]
	or S_VIP_STATUS_DATA[spellID]
	or S_PREMIUM_SPELL_ID[spellID]
	then
		return
	end

	if not isRemoved and self.Parent.Data.AuraCooldown[spellID] then
		self:SetAbilityCooldown(spellID, self.Parent.Data.AuraCooldown[spellID])
	end

	if self.Parent.DRAW_AURAS_FOR_SMALL_FRAMES then
		self.SmallFrame.AuraFrame:SetAura(spellID, isRemoved, ...)
	end
	self.PlayerFrame.AuraFrame:SetAura(spellID, isRemoved, ...)
	self.VictimFrame.AuraFrame:SetAura(spellID, isRemoved, ...)

	self.SmallControlWorker:Update(self.PlayerFrame.AuraFrame)
    self.PlayerControlWorker:Update(self.PlayerFrame.AuraFrame)
    self.VictimControlWorker:Update(self.VictimFrame.AuraFrame)

	if self.NameplateObject then
		self.NameplateObject:SetAura()
	end
end

function ezSpectator_PlayerWorker:SetHidden(isLocked)
	self.isHidden = isLocked
end

function ezSpectator_PlayerWorker:SetWinner(IsWinner)
    if IsWinner then
        self.SmallFrame:SetAlpha(1)
        self.SmallFrame.HealthBar:SetOverride(ARENA_REPLAY_WIN)

        self.PlayerFrame:SetAlpha(1)
        self.PlayerFrame.HealthBar:SetOverride(ARENA_REPLAY_WIN)

        self.VictimFrame:SetAlpha(1)
        self.VictimFrame.HealthBar:SetOverride(ARENA_REPLAY_WIN)
    else
		local isHidden = self.isHidden
		self.isHidden = false

        self:SetHealth(0)
        self:SetPower(0)

		self.isHidden = isHidden

        self.SmallFrame:SetAlpha(0.5)
        self.SmallFrame.HealthBar:SetOverride(ARENA_REPLAY_LOSE)

        self.PlayerFrame:SetAlpha(0.5)
        self.PlayerFrame.HealthBar:SetOverride(ARENA_REPLAY_LOSE)

        self.VictimFrame:SetAlpha(0.5)
        self.VictimFrame.HealthBar:SetOverride(ARENA_REPLAY_LOSE)
    end
end

function ezSpectator_PlayerWorker:SetNameplate(nameplateObject)
	self.NameplateObject = nameplateObject
end

function ezSpectator_PlayerWorker:GetNameplate()
	return self.NameplateObject
end

function ezSpectator_PlayerWorker:SetAbilityCooldown(spellID, cooldownTime)
	self.SpellCooldown:StartCooldown(self.Nickname, spellID, cooldownTime)
end

function ezSpectator_PlayerWorker:BindViewpoint()
	C_ArenaSpectator.SetUnitSpectation(self.Nickname)
    self.Parent.Interface:ResetViewpoint()

    self.Parent.Interface.Viewpoint = self
	self.SmallFrame:SetAlpha(self.Parent.VIEWPOINT_ALPHA)

    self.PlayerFrame:Show()
    self:SetTarget(nil)
end