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

local TIME_LEFT_FRAME_WIDTH = 200;
LOSS_OF_CONTROL_TIME_OFFSET = 6;

local ALERT_FADE_DELAY = 1;
local ALERT_FADE_TIME = 0.5;

local DISPLAY_TYPE_FULL = 2;
local DISPLAY_TYPE_ALERT = 1;
local DISPLAY_TYPE_NONE = 0;

local ACTIVE_INDEX = 1;

local MECHANIC = {
	CHARM			= 1,
	DISORIENTED		= 2,
	DISARM			= 3,
	DISTRACT		= 4,
	FEAR			= 5,
	GRIP			= 6,
	ROOT			= 7,
	SLOW_ATTACK		= 8,
	SILENCE			= 9,
	SLEEP			= 10,
	SNARE			= 11,
	STUN			= 12,
	FREEZE			= 13,
	KNOCKOUT		= 14,
	BLEED			= 15,
	BANDAGE			= 16,
	POLYMORPH		= 17,
	BANISH			= 18,
	SHIELD			= 19,
	SHACKLE			= 20,
	MOUNT			= 21,
	INFECTED		= 22,
	TURN			= 23,
	HORROR			= 24,
	INVULNERABILITY	= 25,
	INTERRUPT		= 26,
	DAZE			= 27,
	DISCOVERY		= 28,
	IMMUNE_SHIELD	= 29,
	SAPPED			= 30,
	ENRAGED			= 31,
}

local MECHANIC_INFO = {
	[MECHANIC.CHARM]			= {LOCALE_SPELL_MECHANIC_CHARM, 8},
	[MECHANIC.DISORIENTED]		= {LOCALE_SPELL_MECHANIC_DISORIENTED, 5},
	[MECHANIC.DISARM]			= {LOCALE_SPELL_MECHANIC_DISARM, 2},
	[MECHANIC.DISTRACT]			= {LOCALE_SPELL_MECHANIC_DISTRACT, 0},
	[MECHANIC.FEAR]				= {LOCALE_SPELL_MECHANIC_FEAR, 6},
	[MECHANIC.GRIP]				= {LOCALE_SPELL_MECHANIC_GRIP, 0},
	[MECHANIC.ROOT]				= {LOCALE_SPELL_MECHANIC_ROOT, 1},
	[MECHANIC.SLOW_ATTACK]		= {LOCALE_SPELL_MECHANIC_SLOW_ATTACK, 0},
	[MECHANIC.SILENCE]			= {LOCALE_SPELL_MECHANIC_SILENCE, 4},
	[MECHANIC.SLEEP]			= {LOCALE_SPELL_MECHANIC_SLEEP, 4},
	[MECHANIC.SNARE]			= {LOCALE_SPELL_MECHANIC_SNARE, 0},
	[MECHANIC.STUN]				= {LOCALE_SPELL_MECHANIC_STUN, 7},
	[MECHANIC.FREEZE]			= {LOCALE_SPELL_MECHANIC_FREEZE, 7},
	[MECHANIC.KNOCKOUT]			= {LOCALE_SPELL_MECHANIC_KNOCKOUT, 7},
	[MECHANIC.BLEED]			= {LOCALE_SPELL_MECHANIC_BLEED, 0},
	[MECHANIC.BANDAGE]			= {LOCALE_SPELL_MECHANIC_BANDAGE, 0},
	[MECHANIC.POLYMORPH]		= {LOCALE_SPELL_MECHANIC_POLYMORPH, 5},
	[MECHANIC.BANISH]			= {LOCALE_SPELL_MECHANIC_BANISH, 1},
	[MECHANIC.SHIELD]			= {LOCALE_SPELL_MECHANIC_SHIELD, 0},
	[MECHANIC.SHACKLE]			= {LOCALE_SPELL_MECHANIC_SHACKLE, 1},
	[MECHANIC.MOUNT]			= {LOCALE_SPELL_MECHANIC_MOUNT, 0},
	[MECHANIC.INFECTED]			= {LOCALE_SPELL_MECHANIC_INFECTED, 0},
	[MECHANIC.TURN]				= {LOCALE_SPELL_MECHANIC_TURN, 6},
	[MECHANIC.HORROR]			= {LOCALE_SPELL_MECHANIC_HORROR, 6},
	[MECHANIC.INVULNERABILITY]	= {LOCALE_SPELL_MECHANIC_INVULNERABILITY, 0},
	[MECHANIC.INTERRUPT]		= {LOCALE_SPELL_MECHANIC_INTERRUPT, 0},
	[MECHANIC.DAZE]				= {LOCALE_SPELL_MECHANIC_DAZE, 0},
	[MECHANIC.DISCOVERY]		= {LOCALE_SPELL_MECHANIC_DISCOVERY, 0},
	[MECHANIC.IMMUNE_SHIELD]	= {LOCALE_SPELL_MECHANIC_IMMUNE_SHIELD, 0},
	[MECHANIC.SAPPED]			= {LOCALE_SPELL_MECHANIC_SAPPED, 7},
	[MECHANIC.ENRAGED]			= {LOCALE_SPELL_MECHANIC_ENRAGED, 0},
}

local PLAYER_CLASS = select(2, UnitClass("player"))
local CLASS_MECHANIC_FILTER = {
	MAGE = {
		[MECHANIC.DISARM] = true,
	},
	WARLOCK = {
		[MECHANIC.DISARM] = true,
	},
	DRUID = {
		[MECHANIC.DISARM] = true,
	},
	ROGUE = {
		[MECHANIC.SILENCE] = true,
	},
	PRIEST = {
		[MECHANIC.DISARM] = true,
	},
}

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

local MECHANIC_OVERRIDE = {
	[47700] = MECHANIC.STUN,
}

local lossOfControlData = {}
local tempLossOfControlData = {}

function LossOfControlFrame_OnLoad(self)
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("VARIABLES_LOADED");

	self.AnimPlay = LossOfControlFrame_AnimPlay
	self.AnimStop = LossOfControlFrame_AnimStop
	self.AnimIsPlaying = LossOfControlFrame_AnimIsPlaying

	self.TimeLeft.baseNumberWidth = self.TimeLeft.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	self.TimeLeft.secondsWidth = self.TimeLeft.SecondsText:GetStringWidth();

	LossOfControlFrame_OnEvent(self, "UNIT_AURA", "player")
end

local function sortData(a, b)
	if a.priority ~= b.priority then
		return a.priority > b.priority;
	end

	return a.expirationTime > b.expirationTime;
end

function LossOfControlFrame_UpdateData()
	table.wipe(lossOfControlData)

	for _, spellData in pairs(tempLossOfControlData) do
		table.insert(lossOfControlData, spellData)
	end

	table.sort(lossOfControlData, sortData);

	local isEnable = S_INTERFACE_OPTIONS_CACHE:Get("LOSS_OF_CONTROL_TOGGLE", 1)
	local eventIndex = #lossOfControlData

	if isEnable and isEnable == 0 or eventIndex == 0 then
		return
	end

	local self = LossOfControlFrame
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(eventIndex)

	if displayType == DISPLAY_TYPE_ALERT then
		if ( not self:IsShown() or priority > self.priority or ( priority == self.priority and timeRemaining and ( not self.TimeLeft.timeRemaining or timeRemaining > self.TimeLeft.timeRemaining ) ) ) then
			LossOfControlFrame_SetUpDisplay(self, true, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType);
		end
		return;
	end
	if ( eventIndex == ACTIVE_INDEX ) then
		self.fadeDelayTime = nil;
		self.fadeTime = nil;
		LossOfControlFrame_SetUpDisplay(self, true);
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

function LossOfControlAddOrUpdateDebuff( spellID, name, icon, duration, expirationTime, mechanicID )
	local startTime = GetTime()
	local mechanicName, priority = unpack(MECHANIC_INFO[mechanicID], 1, 2)

	tempLossOfControlData[spellID] = {
		locType 		= mechanicID,
		spellID 		= spellID,
		text 			= mechanicName or name,
		name 			= name,
		iconTexture 	= icon,
		startTime 		= startTime,
		duration 		= duration,
		priority 		= priority or 0,
		expirationTime  = expirationTime or 0,
		displayType 	= DISPLAY_TYPE_FULL,
	}

	LossOfControlFrame_UpdateData()
end

function LossOfControlRemoveDebuff( spellID )
	tempLossOfControlData[spellID] = nil
	LossOfControlFrame_UpdateData()
end

local auraTrackerStorage = {}
function LossOfControlFrame_OnEvent(self, event, unit)
	if event == "VARIABLES_LOADED" then
		LossOfControlFrame_SetScale(self, tonumber(C_CVar:GetValue("C_CVAR_LOSS_OF_CONTROL_SCALE")) or 1);
	elseif event == "UNIT_AURA" and unit == "player" then
		for auraIndex = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3 = UnitAura("player", auraIndex, "HARMFUL")

			if name and spellID then
				local mechanicID = MECHANIC_OVERRIDE[spellID] or LOSS_OF_CONTROL_SPELL_DATA[spellID]
				if mechanicID and not (CLASS_MECHANIC_FILTER[PLAYER_CLASS] and CLASS_MECHANIC_FILTER[PLAYER_CLASS][mechanicID]) then
					local hasAura = auraTrackerStorage[spellID] and auraTrackerStorage[spellID][1]

					if hasAura == nil then
						LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime, mechanicID)
					else
						local saveDuration = auraTrackerStorage[spellID][2] - GetTime()
						local newBuffDuation = expirationTime - GetTime()

						if newBuffDuation > saveDuration then
							LossOfControlAddOrUpdateDebuff(spellID, name, icon, duration, expirationTime, mechanicID)
						end
					end

					auraTrackerStorage[spellID] = {false, expirationTime}
				end
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
--	RaidNotice_UpdateSlot(self.AbilityName, abilityNameTimings, elapsed);
--	RaidNotice_UpdateSlot(self.TimeLeft.NumberText, timeLeftTimings, elapsed);
--	RaidNotice_UpdateSlot(self.TimeLeft.SecondsText, timeLeftTimings, elapsed);

	-- handle alert fade timing
	if(self.fadeDelayTime) then
		self.fadeDelayTime = self.fadeDelayTime - elapsed;
		if(self.fadeDelayTime < 0) then
			self.fadeDelayTime = nil;
		end
	end

	if(self.fadeTime and not self.fadeDelayTime) then
		self.fadeTime = self.fadeTime - elapsed;
		self:SetAlpha(Saturate(self.fadeTime / ALERT_FADE_TIME));
		if ( self.fadeTime < 0 ) then
			self:Hide();
		else
			-- no need to do any other work
			return;
		end
	else
		self:SetAlpha(1.0);
	end
	LossOfControlFrame_UpdateDisplay(self);
end

function LossOfControlFrame_OnHide(self)
	self.fadeTime = nil;
	self.fadeDelayTime = nil;
	self.priority = nil;
end

function LossOfControlFrame_SetUpDisplay(self, animate, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
	if ( not locType ) then
		locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX);
	end
	if ( text and displayType ~= DISPLAY_TYPE_NONE ) then
		-- ability name
		text = TEXT_OVERRIDE[spellID] or text;
		if ( locType == "SCHOOL_INTERRUPT" ) then
			-- Replace text with school-specific lockout text
			if(lockoutSchool and lockoutSchool ~= 0) then
				text = string.format(LOSS_OF_CONTROL_DISPLAY_INTERRUPT_SCHOOL, GetSchoolString(lockoutSchool));
			end
		end
		self.AbilityName:SetText(text);
		-- icon
		self.Icon:SetTexture(iconTexture);
		-- time
		local timeLeftFrame = self.TimeLeft;
		if ( displayType == DISPLAY_TYPE_ALERT ) then
			timeRemaining = duration;
		--	CooldownFrame_Clear(self.Cooldown);
		elseif ( not startTime ) then
		--	CooldownFrame_Clear(self.Cooldown);
		else
			CooldownFrame_SetTimer(self.Cooldown, startTime, duration, true);
		end
		LossOfControlTimeLeftFrame_SetTime(timeLeftFrame, timeRemaining);
		-- align stuff
		local abilityWidth = self.AbilityName:GetWidth();
		local longestTextWidth = max(abilityWidth, (timeLeftFrame.numberWidth + timeLeftFrame.secondsWidth));
		local xOffset = (abilityWidth - longestTextWidth) / 2 + 27;
		self.AbilityName:SetPoint("CENTER", xOffset, 11);
		self.Icon:SetPoint("CENTER", -((6 + longestTextWidth) / 2), 0);
		-- left-align the TimeLeft frame with the ability name using a center anchor (will need center for "animating" via frame scaling - NYI)
		xOffset = xOffset + (TIME_LEFT_FRAME_WIDTH - abilityWidth) / 2;
		timeLeftFrame:SetPoint("CENTER", xOffset, -12);
		-- show
		if ( animate ) then
			if ( displayType == DISPLAY_TYPE_ALERT ) then
				self.fadeDelayTime = ALERT_FADE_DELAY;
				self.fadeTime = ALERT_FADE_TIME;
			end
			self:AnimStop();
			self.AbilityName.scrollTime = 0;
			self.TimeLeft.NumberText.scrollTime = 0;
			self.TimeLeft.SecondsText.scrollTime = 0;
			self.Cooldown:Hide();
			self:AnimPlay();
			PlaySound(SOUNDKIT.UI_LOSS_OF_CONTROL_START);
		end
		self.priority = priority;
		self.spellID = spellID;
		self.startTime = startTime;
		self:Show();
	end
end

function LossOfControlFrame_UpdateDisplay(self)
	-- if displaying an alert, wait for it to go away on its own
	if ( self.fadeTime ) then
		return;
	end

	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = LossOfControlGetEventInfo(ACTIVE_INDEX)
	if ( text and displayType == DISPLAY_TYPE_FULL ) then
		if ( spellID ~= self.spellID or startTime ~= self.startTime ) then
			LossOfControlFrame_SetUpDisplay(self, false, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
		end
		if ( not self:AnimIsPlaying() and startTime ) then
			CooldownFrame_SetTimer(self.Cooldown, startTime, duration, true, true);
		end
		LossOfControlTimeLeftFrame_SetTime(self.TimeLeft, timeRemaining);
	else
		self:Hide();
	end
end

function LossOfControlTimeLeftFrame_SetTime(self, timeRemaining)
	if( timeRemaining ) then
		if ( timeRemaining >= 10 ) then
			self.NumberText:SetFormattedText("%d", timeRemaining);
		elseif (timeRemaining < 9.95) then -- From 9.95 to 9.99 it will print 10.0 instead of 9.9
			self.NumberText:SetFormattedText("%.1F", timeRemaining);
		end
		self:SetShown(timeRemaining > 0)
		self.timeRemaining = timeRemaining;
		self.numberWidth = self.NumberText:GetStringWidth() + LOSS_OF_CONTROL_TIME_OFFSET;
	else
		self:Hide();
		self.numberWidth = 0;
	end
end

function LossOfControlFrame_SetScale(self, scale)
	self:SetScale(scale or 1);
	LossOfControlFrame_SetUpDisplay(self, false);
end