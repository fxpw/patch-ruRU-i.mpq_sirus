--	Filename:	Sirus_LossOfControl.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

MECHANIC_CHARM            = 1
MECHANIC_DISORIENTED      = 2
MECHANIC_DISARM           = 3
MECHANIC_DISTRACT         = 4
MECHANIC_FEAR             = 5
MECHANIC_GRIP             = 6
MECHANIC_ROOT             = 7
MECHANIC_SLOW_ATTACK      = 8
MECHANIC_SILENCE          = 9
MECHANIC_SLEEP            = 10
MECHANIC_SNARE            = 11
MECHANIC_STUN             = 12
MECHANIC_FREEZE           = 13
MECHANIC_KNOCKOUT         = 14
MECHANIC_BLEED            = 15
MECHANIC_BANDAGE          = 16
MECHANIC_POLYMORPH        = 17
MECHANIC_BANISH           = 18
MECHANIC_SHIELD           = 19
MECHANIC_SHACKLE          = 20
MECHANIC_MOUNT            = 21
MECHANIC_INFECTED         = 22
MECHANIC_TURN             = 23
MECHANIC_HORROR           = 24
MECHANIC_INVULNERABILITY  = 25
MECHANIC_INTERRUPT        = 26
MECHANIC_DAZE             = 27
MECHANIC_DISCOVERY        = 28
MECHANIC_IMMUNE_SHIELD    = 29
MECHANIC_SAPPED           = 30
MECHANIC_ENRAGED          = 31

local abilityNameTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 22.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 32.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}
local timeLeftTimings = {
	["RAID_NOTICE_MIN_HEIGHT"] = 20.0,
	["RAID_NOTICE_MAX_HEIGHT"] = 28.0,
	["RAID_NOTICE_SCALE_UP_TIME"] = 0.1,
	["RAID_NOTICE_SCALE_DOWN_TIME"] = 0.2,
}

local TEXT_OVERRIDE = {
	[33786] = LOSS_OF_CONTROL_DISPLAY_CYCLONE,
}

local TIME_LEFT_FRAME_WIDTH = 200
LOSS_OF_CONTROL_TIME_OFFSET = 6

local DISPLAY_TYPE_FULL = 2
local DISPLAY_TYPE_ALERT = 1
local DISPLAY_TYPE_NONE = 0

local ACTIVE_INDEX = 1

function LossOfControlFrame_AnimPlay( self )
	self.RedLineTop.Anim:Play()
	self.RedLineBottom.Anim:Play()
	self.Icon.Anim:Play()
end

function LossOfControlFrame_AnimStop( self )
	self.RedLineTop.Anim:Play()
	self.RedLineBottom.Anim:Play()
	self.Icon.Anim:Play()
end

function LossOfControlFrame_AnimIsPlaying( self )
	local isPlaying = false

	if self.RedLineTop.Anim:IsPlaying() then
		isPlaying = true
	end

	if self.RedLineBottom.Anim:IsPlaying() then
		isPlaying = true
	end

	if self.Icon.Anim:IsPlaying() then
		isPlaying = true
	end

	return isPlaying
end

local lossOfControlMechanicData = {
    [MECHANIC_CHARM]            = {LOCALE_SPELL_MECHANIC_CHARM, 8},
    [MECHANIC_DISORIENTED]      = {LOCALE_SPELL_MECHANIC_DISORIENTED, 5},
    [MECHANIC_DISARM]           = {LOCALE_SPELL_MECHANIC_DISARM, 2},
    [MECHANIC_DISTRACT]         = {LOCALE_SPELL_MECHANIC_DISTRACT, 0},
    [MECHANIC_FEAR]             = {LOCALE_SPELL_MECHANIC_FEAR, 6},
    [MECHANIC_GRIP]             = {LOCALE_SPELL_MECHANIC_GRIP, 0},
    [MECHANIC_ROOT]             = {LOCALE_SPELL_MECHANIC_ROOT, 1},
    [MECHANIC_SLOW_ATTACK]      = {LOCALE_SPELL_MECHANIC_SLOW_ATTACK, 0},
    [MECHANIC_SILENCE]          = {LOCALE_SPELL_MECHANIC_SILENCE, 4},
    [MECHANIC_SLEEP]            = {LOCALE_SPELL_MECHANIC_SLEEP, 4},
    [MECHANIC_SNARE]            = {LOCALE_SPELL_MECHANIC_SNARE, 0},
    [MECHANIC_STUN]             = {LOCALE_SPELL_MECHANIC_STUN, 7},
    [MECHANIC_FREEZE]           = {LOCALE_SPELL_MECHANIC_FREEZE, 7},
    [MECHANIC_KNOCKOUT]         = {LOCALE_SPELL_MECHANIC_KNOCKOUT, 7},
    [MECHANIC_BLEED]            = {LOCALE_SPELL_MECHANIC_BLEED, 0},
    [MECHANIC_BANDAGE]          = {LOCALE_SPELL_MECHANIC_BANDAGE, 0},
    [MECHANIC_POLYMORPH]        = {LOCALE_SPELL_MECHANIC_POLYMORPH, 5},
    [MECHANIC_BANISH]           = {LOCALE_SPELL_MECHANIC_BANISH, 1},
    [MECHANIC_SHIELD]           = {LOCALE_SPELL_MECHANIC_SHIELD, 0},
    [MECHANIC_SHACKLE]          = {LOCALE_SPELL_MECHANIC_SHACKLE, 1},
    [MECHANIC_MOUNT]            = {LOCALE_SPELL_MECHANIC_MOUNT, 0},
    [MECHANIC_INFECTED]         = {LOCALE_SPELL_MECHANIC_INFECTED, 0},
    [MECHANIC_TURN]             = {LOCALE_SPELL_MECHANIC_TURN, 6},
    [MECHANIC_HORROR]           = {LOCALE_SPELL_MECHANIC_HORROR, 6},
    [MECHANIC_INVULNERABILITY]  = {LOCALE_SPELL_MECHANIC_INVULNERABILITY, 0},
    [MECHANIC_INTERRUPT]        = {LOCALE_SPELL_MECHANIC_INTERRUPT, 0},
    [MECHANIC_DAZE]             = {LOCALE_SPELL_MECHANIC_DAZE, 0},
    [MECHANIC_DISCOVERY]        = {LOCALE_SPELL_MECHANIC_DISCOVERY, 0},
    [MECHANIC_IMMUNE_SHIELD]    = {LOCALE_SPELL_MECHANIC_IMMUNE_SHIELD, 0},
    [MECHANIC_SAPPED]           = {LOCALE_SPELL_MECHANIC_SAPPED, 7},
    [MECHANIC_ENRAGED]          = {LOCALE_SPELL_MECHANIC_ENRAGED, 0},
}

local lossOfControlData = {}
local tempLossOfControlData = {}

function LossOfControlFrame_OnLoad(self)
	self:RegisterEvent("UNIT_AURA")

	self.AnimPlay = LossOfControlFrame_AnimPlay
	self.AnimStop = LossOfControlFrame_AnimStop
	self.AnimIsPlaying = LossOfControlFrame_AnimIsPlaying

	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth()

	LossOfControlFrame_OnEvent(self, "UNIT_AURA", "player")
end

function LossOfControlFrame_UpdateData()
	lossOfControlData = {}

	for _, spellData in pairs(tempLossOfControlData) do
		table.insert(lossOfControlData, spellData)
	end

	local self = LossOfControlFrame
	local eventIndex = #lossOfControlData
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(eventIndex)
	local isEnable = S_INTERFACE_OPTIONS_CACHE:Get("LOSS_OF_CONTROL_TOGGLE", 1)

	if isEnable and isEnable == 0 then
		return
	end

	if displayType == DISPLAY_TYPE_ALERT then
		if ( not self:IsShown() or priority > self.priority or ( priority == self.priority and timeRemaining and ( not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining ) ) ) then
			LossOfControlFrame_SetUpDisplay(self, true, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
		end
		return
	end
	if eventIndex == ACTIVE_INDEX then
		self.fadeTime = nil
		LossOfControlFrame_SetUpDisplay(self, true)
	end
end

function LossOfControlGetEventInfo( index )
	if not index then
		return nil
	end

	local data = lossOfControlData[index]

	if not data then
		return nil
	end

	local locType 		= data.locType
	local spellID 		= data.spellID
	local text 			= data.text
	local iconTexture 	= data.iconTexture
	local startTime 	= data.startTime
	local timeRemaining = data.expirationTime ~= 0 and data.expirationTime - GetTime() or nil
	local duration 		= data.duration
	local lockoutSchool = "lockoutSchool"
	local priority 		= data.priority
	local displayType 	= data.displayType

	return locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType
end

function LossOfControlAddOrUpdateDebuff( spellID, name, icon, duration, expirationTime )
	local LOCSpellMechanic = LOSS_OF_CONTROL_SPELL_DATA[spellID]

	if LOCSpellMechanic then
		local startTime = GetTime()
		local priority = lossOfControlMechanicData[LOCSpellMechanic][2] or 0
		local text = lossOfControlMechanicData[LOCSpellMechanic][1] or name

		tempLossOfControlData[spellID] = {
			locType 		= LOCSpellMechanic,
			spellID 		= spellID,
			text 			= text,
			name 			= name,
			iconTexture 	= icon,
			startTime 		= startTime,
			duration 		= duration,
			priority 		= priority,
			expirationTime  = expirationTime,
			displayType 	= DISPLAY_TYPE_FULL -- TEMP (maby)
		}

		LossOfControlFrame_UpdateData()
	end
end

function LossOfControlRemoveDebuff( spellID )
	tempLossOfControlData[spellID] = nil
	LossOfControlFrame_UpdateData()
end

local auraTrackerStorage = {}
function LossOfControlFrame_OnEvent(self, event, unit)
	if event == "UNIT_AURA" and unit == "player" then
		for auraIndex = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3 = UnitAura("player", auraIndex, "HARMFUL")

			if name and spellID then
				local hasAura = auraTrackerStorage[spellID] and auraTrackerStorage[spellID][1]

				if hasAura == nil then
					LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime)
				else
					local saveDuration = auraTrackerStorage[spellID][2] - GetTime()
					local newBuffDuation = expirationTime - GetTime()

					if newBuffDuation > saveDuration then
						LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime)
					end
				end

				auraTrackerStorage[spellID] = {false, expirationTime}
			end
		end

		for spellID, auraData in pairs(auraTrackerStorage) do
			if not auraData[1] then
				auraTrackerStorage[spellID][1] = true
			else
				LossOfControlRemoveDebuff(spellID)
				auraTrackerStorage[spellID] = nil
			end
		end
	end
end

function LossOfControlFrame_OnUpdate(self, elapsed)
	-- handle alert type
	if( self.fadeTime ) then
		self.fadeTime = self.fadeTime - elapsed
		self:SetAlpha(max(self.fadeTime*2, 0.0))
		if ( self.fadeTime < 0 ) then
			self:Hide()
		else
			-- no need to do any other work
			return
		end
	else
		self:SetAlpha(1.0)
	end
	LossOfControlFrame_UpdateDisplay(self)
end

function LossOfControlFrame_OnHide(self)
	self.fadeTime = nil
	self.priority = nil
end

function TestLOC()
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX)
	LossOfControlFrame_SetUpDisplay(LossOfControlFrame, true, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
end

function LossOfControlFrame_SetUpDisplay(self, animate, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
	if ( not locType ) then
		locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX)
	end
	if ( text and displayType ~= DISPLAY_TYPE_NONE ) then
		-- ability name
		text = TEXT_OVERRIDE[spellID] or text
		if ( locType == "SCHOOL_INTERRUPT" ) then
			-- Replace text with school-specific lockout text
			if(lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, GetSchoolString(lockoutSchool))
			end
		end
		self.AbilityName:SetText(text)
		-- icon
		self.Icon:SetTexture(iconTexture)
		-- time
		local timeLeftFrame = self.TimeLeft
		if ( displayType == DISPLAY_TYPE_ALERT ) then
			timeRemaining = duration
			-- CooldownFrame_Clear(self.Cooldown)
		elseif ( not startTime ) then
			-- CooldownFrame_Clear(self.Cooldown)
		else
			CooldownFrame_SetTimer(self.Cooldown, startTime, duration, true)
		end
		LossOfControlTimeLeftFrame_SetTime(timeLeftFrame, timeRemaining)
		-- align stuff
		local abilityWidth = self.AbilityName:GetWidth()
		local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth))
		local xOffset = (abilityWidth - longestTextWidth) / 2 + 27
		self.AbilityName:SetPoint("CENTER", xOffset, 11)
		self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0)
		-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
		xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2
		timeLeftFrame:SetPoint("CENTER", xOffset, -12)
		-- show
		if ( animate ) then
			if ( displayType == DISPLAY_TYPE_ALERT ) then
				self.fadeTime = 1.5
			end
			self:AnimStop()
			self.AbilityName.scrollTime = 0
			self.TimeLeft.NumberText.scrollTime = 0
			self.TimeLeft.SecondsText.scrollTime = 0
			self.Cooldown:Hide()
			self:AnimPlay()
			PlaySound(SOUNDKIT.UI_LOSS_OF_CONTROL_START)
		end
		self.priority = priority
		self.spellID = spellID
		self.startTime = startTime
		self:Show()
	end
end

function LossOfControlFrame_UpdateDisplay(self)
	-- if displaying an alert, wait for it to go away on its own
	if ( self.fadeTime ) then
		return
	end

	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX)
	if ( text and displayType == DISPLAY_TYPE_FULL ) then
		if ( spellID ~= self.spellID or startTime ~= self.startTime ) then
			LossOfControlFrame_SetUpDisplay(self, false, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
		end
		if ( not self:AnimIsPlaying() and startTime ) then
			CooldownFrame_SetTimer(self.Cooldown, startTime, duration, true, true)
		end
		LossOfControlTimeLeftFrame_SetTime(self.TimeLeft, timeRemaining)
	else
		self:Hide()
	end
end

function LossOfControlTimeLeftFrame_SetTime(self, timeRemaining)
	if( timeRemaining ) then
		if ( timeRemaining >= 10 ) then
			self.NumberText:SetFormattedText("%d", timeRemaining)
		elseif (timeRemaining < 9.95) then -- From 9.95 to 9.99 it will print 10.0 instead of 9.9
			self.NumberText:SetFormattedText("%.1F", timeRemaining)
		end
		self:SetShown(timeRemaining > 0)
		self.timeRemaining = timeRemaining
		self.numberWidth = self.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET
	else
		self:Hide()
		self.numberWidth = 0
	end
end

