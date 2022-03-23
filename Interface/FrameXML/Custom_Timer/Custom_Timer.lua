--	Filename:	Sirus_Timer.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local TIMER_MINUTES_DISPLAY = "%d:%02d"
local TIMER_TYPE_PVP = 1
local TIMER_TYPE_CHALLENGE_MODE = 2

local TIMER_DATA = {
	{ mediumMarker = 11, largeMarker = 6, updateInterval = 10 },
	{ mediumMarker = 100, largeMarker = 100, updateInterval = 100 },
}

local TIMER_NUMBERS_SETS = {
	["BigGold"] = {
		texture = "Interface\\Timer\\BigTimerNumbers",
		w 		= 256, 
		h 		= 170, 
		texW 	= 1024, 
		texH 	= 512,
		numberHalfWidths = {35/128, 14/128, 33/128, 32/128, 36/128, 32/128, 33/128, 29/128, 31/128, 31/128,}
	}
}


function AnimationsToggle_FADEBARIN( self, isStop )
	if isStop then
		self.bar.fadeBarIn:Stop()
	else
		self.bar.fadeBarIn:Play()
	end
end

function AnimationsToggle_FADEBAROUT( self, isStop )
	if isStop then
		self.bar.fadeBarOut:Stop()
	else
		self.bar.fadeBarOut:Play()
	end
end

function AnimationsToggle_STARTNUMBERS( self, isStop )
	if isStop then
		self.digit1.startNumbers:Stop()
		self.digit2.startNumbers:Stop()
		self.glow1.startNumbers:Stop()
		self.glow2.startNumbers:Stop()
	else
		self.digit1.startNumbers:Play()
		self.digit2.startNumbers:Play()
		self.glow1.startNumbers:Play()
		self.glow2.startNumbers:Play()
	end
end

function AnimationsToggle_FACTIONANIM( self, isStop )
	if isStop then
		self.faction.factionAnim:Stop()
		self.factionGlow.factionAnim:Stop()
	else
		self.faction.factionAnim:Play()
		self.factionGlow.factionAnim:Play()
	end
end


function TimerTracker_OnLoad( self, ... )
	self.timerList = {}
	self.updateTime = 0

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
	-- self:RegisterAllEvents()
end

function StartTimer_OnLoad( self, ... )
	self.updateTime = 0
end

function StartTimer_OnShow(self)
	self.time = self.endTime - GetTime()
	if self.time <= 0 then
		self:Hide()
		self.isFree = true
	elseif self.digit1.startNumbers:IsPlaying() then
		AnimationsToggle_STARTNUMBERS(self, true)
		AnimationsToggle_STARTNUMBERS(self)
	end
end

function GetPlayerFactionGroup()
	local factionGroup = UnitFactionGroup("player")

	-- if ( not IsActiveBattlefieldArena() ) then
	-- 	factionGroup = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()]
	-- end
	
	return factionGroup
end

function TimerTracker_OnEvent(self, event, ...)
	if event == "START_TIMER" and not TimerTracker:IsShown() then
		local timerType, timeSeconds, totalTime  = ...
		local timer
		local numTimers = 0
		local isTimerRuning = false
		
		for a,b in pairs(self.timerList) do
			if b.type == timerType and not b.isFree then
				timer = b
				isTimerRuning = true
				break
			end
		end

		if isTimerRuning then
			-- don't interupt the final count down
			if not timer.digit1.startNumbers:IsPlaying() then
				timer.time = timeSeconds
			end
			
			local factionGroup = GetPlayerFactionGroup()

			if ( not timer.factionGroup or (timer.factionGroup ~= factionGroup) ) then
				if GetCVar("BattlegroundTimerType") == "0" then
					timer.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo")
					timer.factionGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo")
				else
					timer.faction:SetTexture("Interface\\Timer\\Countdown")
					timer.factionGlow:SetTexture("Interface\\Timer\\Countdown")

					timer.faction:SetTexCoord(0, 0.25, 0, 0.5)
					timer.factionGlow:SetTexCoord(0.25, 0.5, 0, 0.5)
				end

				timer.factionGroup = factionGroup
			end
		else
			for a,b in pairs(self.timerList) do
				if not timer and b.isFree then
					timer = b
				else
					numTimers = numTimers + 1
				end
			end
			
			
			if not timer then
				timer = CreateFrame("FRAME", self:GetName().."Timer"..(#self.timerList+1), UIParent, "StartTimerBar")
				self.timerList[#self.timerList+1] = timer
			end
			
			
			timer:ClearAllPoints()
			timer:SetPoint("TOP", 0, -155--[[ - (24*numTimers)]])
			
			timer.isFree = false
			timer.type = timerType
			timer.time = timeSeconds
			timer.endTime = GetTime() + timeSeconds
            timer.duration = timeSeconds
            timer.startValue = timeSeconds / totalTime
			timer.bar:Show()
			timer.bar:SetMinMaxValues(0, 1)
			timer.style = TIMER_NUMBERS_SETS["BigGold"]
			
			timer.digit1:SetTexture(timer.style.texture)
			timer.digit2:SetTexture(timer.style.texture)
			timer.digit1:SetSize(timer.style.w/2, timer.style.h/2)
			timer.digit2:SetSize(timer.style.w/2, timer.style.h/2)
			--This is to compensate texture size not affecting GetWidth() right away.
			-- print("========", timer.style.w/2, timer.style.w/2)
			timer.digit1.width, timer.digit2.width = timer.style.w/2, timer.style.w/2
			
			timer.digit1.glow = timer.glow1
			timer.digit2.glow = timer.glow2
			timer.glow1:SetTexture(timer.style.texture.."Glow")
			timer.glow2:SetTexture(timer.style.texture.."Glow")
			
			local factionGroup = GetPlayerFactionGroup()
			if ( factionGroup ) then
				if GetCVar("BattlegroundTimerType") == "0" then
					timer.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo")
					timer.factionGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo")
				else
					timer.faction:SetTexture("Interface\\Timer\\Countdown")
					timer.factionGlow:SetTexture("Interface\\Timer\\Countdown")

					timer.faction:SetTexCoord(0, 0.25, 0, 0.5)
					timer.factionGlow:SetTexCoord(0.25, 0.5, 0, 0.5)
				end
			end
			timer.factionGroup = factionGroup
			timer.updateTime = 0
			timer:SetScript("OnUpdate", StartTimer_BigNumberOnUpdate)
			timer:Show()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for a,timer in pairs(self.timerList) do
			timer.time = nil
			timer.type = nil
			timer.isFree = nil
			timer:SetScript("OnUpdate", nil)
			AnimationsToggle_FADEBAROUT(timer, true)
			AnimationsToggle_FADEBARIN(timer, true)
			AnimationsToggle_STARTNUMBERS(timer, true)
			AnimationsToggle_FACTIONANIM(timer, true)
			timer.bar:Hide()

			local _, instanceTyp = IsInInstance()

			if instanceTyp == "none" then
				if GetCVar("BattlegroundStartTimer") then
					SetCVar("BattlegroundStartTimer", 0)
				end
			end
		end
	elseif event == "PLAYER_ENTERING_BATTLEGROUND" then
		local cvarTime = GetCVar("BattlegroundStartTimer")
		if cvarTime then
			cvarTime = tonumber(cvarTime)
			if cvarTime > 0 then
				local times = cvarTime - time()
				if times > 0 then
					if GetCVar("BattlegroundTimerType") == "0" then
						TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, times, 120)
					else
						TimerTracker_OnEvent(TimerTracker, "START_TIMER", 1, times, 60)
					end
				end
			end
		end
	end
end

function StartTimer_BigNumberOnUpdate(self, elasped)
	self.time = self.endTime - GetTime()
	local minutes, seconds = floor(self.time/60), floor(mod(self.time, 60)) 
    self.updateTime = self.updateTime + elasped

	local timerType = GetCVar("BattlegroundTimerType");
	if timerType ~= "0" then
		ArenaPlayerReadyStatusButtonToggle(self.time, timerType)
	end

	if self.time < 12 then
		AnimationsToggle_FADEBAROUT(self)
		self.barShowing = false
		self.anchorCenter = false
		self:SetScript("OnUpdate", nil)
	elseif not self.barShowing then
		AnimationsToggle_FADEBARIN(self)
		self.barShowing = true
	end

	self.bar:SetValue(linear(self.updateTime, self.startValue, -self.startValue, self.duration))
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds))
end
function StartTimer_BarOnlyOnUpdate(self, elasped)
	self.time = self.endTime - GetTime()
	local minutes, seconds = floor(self.time/60), mod(self.time, 60)

	self.bar:SetValue(linear(self.updateTime, self.startValue, -self.startValue, self.duration))
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds))
	
	if self.time < 0 then
		self:SetScript("OnUpdate", nil)
		self.barShowing = false
		self.isFree = true
		self:Hide()
	end
	
	if not self.barShowing then
		AnimationsToggle_FADEBARIN(self)
		self.barShowing = true
	end
end

local timerTick = false
function StartTimer_SetTexNumbers(self, ...)
	local digits = {...}
	local timeDigits = floor(self.time)
	local digit
	local style = self.style
	local i = 1
	
	local texCoW = style.w/style.texW
	local texCoH = style.h/style.texH
	local l,r,t,b
	local columns = floor(style.texW/style.w)
	local numberOffset = 0
	local numShown = 0

	while digits[i] do
		if timeDigits > 0 then
			digit = mod(timeDigits, 10)
			
			digits[i].hw = style.numberHalfWidths[digit+1]*digits[i].width
			numberOffset  = numberOffset + digits[i].hw
			
			l = mod(digit, columns) * texCoW
			r = l + texCoW
			t = floor(digit/columns) * texCoH
			b = t + texCoH

			digits[i]:SetTexCoord(l,r,t,b)
			digits[i].glow:SetTexCoord(l,r,t,b)
			
			timeDigits = floor(timeDigits/10)	
			numShown = numShown + 1			
		else
			digits[i]:SetTexCoord(0,0,0,0)
			digits[i].glow:SetTexCoord(0,0,0,0)
		end
		i = i + 1
	end
	
	if numberOffset > 0 then
		timerTick = not timerTick
		if timerTick then
			PlaySound("ui_battlegroundcountdown_timer")
		else
			PlaySound("ui_battlegroundcountdown_timer2")
		end
		
		for j = 1, #digits do
			digits[j]:ClearAllPoints()

			if self.anchorCenter then
				digits[j]:SetPoint("CENTER", UIParent, 0, 0)
			else
				digits[j]:SetPoint("CENTER", self, "CENTER", numberOffset - digits[1].hw, 0)
			end
		end
		
		for i = 2, numShown do
			digits[i]:ClearAllPoints()
			digits[i]:SetPoint("CENTER", digits[i-1], "CENTER", -(digits[i].hw + digits[i-1].hw), 0)
			i = i + 1
		end
	end
end

function StartTimer_NumberAnimOnFinished(self)
	self.time = self.time - 1
	if self.time > 1 then
		if self.time < 6 then
			if not self.anchorCenter then
				self.anchorCenter = true

				self.digit1.width, self.digit2.width = self.style.w, self.style.w
				self.digit1:SetSize(self.style.w, self.style.h)
				self.digit2:SetSize(self.style.w, self.style.h)
			end
		end
	
		AnimationsToggle_STARTNUMBERS(self)
	else
		self.isFree = true
		-- PlaySoundKitID(25478)
		PlaySound("ui_battlegroundcountdown_end")
		AnimationsToggle_FACTIONANIM(self)
	end
end


function StartTimer_StopAllTimers()
	for a,timer in pairs(TimerTracker.timerList) do
		timer.time = nil
		timer.type = nil
		timer.isFree = nil
		timer:SetScript("OnUpdate", nil)
		AnimationsToggle_FADEBAROUT(timer, true)
		AnimationsToggle_FADEBARIN(timer, true)
		AnimationsToggle_STARTNUMBERS(timer, true)
		AnimationsToggle_FACTIONANIM(timer, true)
		timer.bar:Hide()
	end
end