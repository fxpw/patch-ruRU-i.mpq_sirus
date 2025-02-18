TIMER_MINUTES_DISPLAY = "%d:%02d"
TIMER_TYPE_SERVER_HANDLED = 0;
TIMER_TYPE_PVP = 1;
TIMER_TYPE_CHALLENGE_MODE = 2;
TIMER_TYPE_PLAYER_COUNTDOWN = 3;
TIMER_TYPE_ARENA = 4
TIMER_TYPE_MINIGAMES = 5;
TIMER_TYPE_MINIGAMES_SHORT = 6;

local TIMER_TYPE_SERVER_HANDLED = TIMER_TYPE_SERVER_HANDLED
local TIMER_TYPE_PLAYER_COUNTDOWN = TIMER_TYPE_PLAYER_COUNTDOWN

TIMER_DATA = {
	[0] = { updateInterval = 10 },
	[1] = { mediumMarker = 11, largeMarker = 6, updateInterval = 10 },
	[2] = { mediumMarker = 100, largeMarker = 100, updateInterval = 100 },
	[3] = { mediumMarker = 31, largeMarker = 11, updateInterval = 10, finishedSoundKitID = SOUNDKIT.UI_COUNTDOWN_FINISHED, bigNumberSoundKitID = SOUNDKIT.UI_COUNTDOWN_TIMER, mediumNumberFinishedSoundKitID = SOUNDKIT.UI_COUNTDOWN_MEDIUM_NUMBER_FINISHED, barShowSoundKitID = SOUNDKIT.UI_COUNTDOWN_BAR_STATE_STARTS, barHideSoundKitID = SOUNDKIT.UI_COUNTDOWN_BAR_STATE_FINISHED},
	[4] = { mediumMarker = 11, largeMarker = 6, updateInterval = 10 },
	[5] = { mediumMarker = 11, largeMarker = 6, updateInterval = 10 },
	[6] = { mediumMarker = 7, largeMarker = 7, updateInterval = 10 },
};

TIMER_SUBTYPE_DATA = {
	[0] = { timerType = TIMER_TYPE_PVP, totalTime = 120 },				-- Battleground
	[1] = { timerType = TIMER_TYPE_ARENA, totalTime = 60 },				-- Arena
	[2] = { timerType = TIMER_TYPE_MINIGAMES, totalTime = 30 },			-- Mini-games
	[3] = { timerType = TIMER_TYPE_MINIGAMES_SHORT, totalTime = 30 },	-- Mini-games
}

TIMER_NUMBERS_SETS = {};
TIMER_NUMBERS_SETS["BigGold"] = {
	texture = "Interface\\Timer\\BigTimerNumbers",
	w 		= 256,
	h 		= 170,
	texW 	= 1024,
	texH 	= 512,
	numberHalfWidths = {35/128, 14/128, 33/128, 32/128, 36/128, 32/128, 33/128, 29/128, 31/128, 31/128}
}

local function getBattlegroundTimerType()
	local timerType = tonumber(GetCVar("BattlegroundTimerType"))
	return timerType or 0
end

local soundTick
local function PlaySoundTick(soundkitID)
	if soundkitID == SOUNDKIT.UI_COUNTDOWN_TIMER or soundkitID == SOUNDKIT.UI_BATTLEGROUND_COUNTDOWN_TIMER then
		soundTick = not soundTick
		PlaySound(soundTick and SOUNDKIT.UI_COUNTDOWN_TIMER or SOUNDKIT.UI_BATTLEGROUND_COUNTDOWN_TIMER)
	else
		PlaySound(soundkitID)
	end
end

function TimerTracker_GetTimerTypeInfo(timerSubType)
	local info = TIMER_SUBTYPE_DATA[timerSubType];
	if info then
		return info.timerType, info.totalTime;
	else
		return 1, 60
	end
end

function TimerTracker_OnLoad(self)
	self.timerList = {};
	self:RegisterCustomEvent("START_TIMER")
	self:RegisterCustomEvent("STOP_TIMER_OF_TYPE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
end

function StartTimer_OnLoad(self)
	self.updateTime = 0
	SetParentFrameLevel(self)

	self.fadeBarIn = CreateAnimationGroupOfGroups(self, self.bar.fadeBarIn)
	self.fadeBarOut = CreateAnimationGroupOfGroups(self, self.bar.fadeBarOut)
	self.GoTextureAnim = CreateAnimationGroupOfGroups(self, self.GoTexture.GoTextureAnim, self.GoTextureGlow.GoTextureAnim)
	self.startNumbers = CreateAnimationGroupOfGroups(self, self.digit1.startNumbers, self.digit2.startNumbers, self.glow1.startNumbers, self.glow2.startNumbers)
end

function StartTimer_OnShow(self)
	self.time = self.endTime - GetTime();
	if self.time <= 0 then
		FreeTimerTrackerTimer(self);
		self:Hide();
	elseif self.startNumbers:IsPlaying() then
		self.startNumbers:Stop();
		self.startNumbers:Play();
	end
end

function GetPlayerFactionGroup()
	local factionGroup = UnitFactionGroup("player");
--[[
	if ( not IsActiveBattlefieldArena()) then
		factionGroup = PLAYER_FACTION_GROUP[GetBattlefieldArenaFaction()];
	end
--]]

	return factionGroup
end

function FreeTimerTrackerTimer(timer)
	timer:SetScript("OnUpdate", nil);
	timer.fadeBarOut:Stop();
	timer.fadeBarIn:Stop();
	timer.startNumbers:Stop();
	timer.GoTextureAnim:Stop();
	timer.bar:Hide();
	timer.time = nil;
	timer.type = nil;
	timer.isFree = true;
	timer.barShowing = false;
end

function FreeAllTimerTrackerTimer()
	for _, timer in pairs(TimerTracker.timerList) do
		FreeTimerTrackerTimer(timer)
	end
end

function TimerTracker_OnEvent(self, event, ...)
	if event == "START_TIMER" then
		local timerType, timeSeconds, totalTime = ...;
		local timer;
		local numTimers = 0;
		local isTimerRunning = false;

		if timerType ~= TIMER_TYPE_PLAYER_COUNTDOWN and timerType ~= TIMER_TYPE_CHALLENGE_MODE and TimerTracker:IsShown() then
			return
		end

		for a,b in pairs(self.timerList) do
			if b.type == timerType and not b.isFree then
				timer = b;
				isTimerRunning = true;
				break;
			end
		end

		if isTimerRunning and timer.type ~= TIMER_TYPE_PLAYER_COUNTDOWN then
			-- don't interupt the final count down
			if not timer.startNumbers:IsPlaying() then
				timer.time = timeSeconds;
				timer.endTime = GetTime() + timeSeconds;
			end
		else
			for a,b in pairs(self.timerList) do
				if not timer and b.isFree then
					timer = b;
				else
					numTimers = numTimers + 1;
				end
			end

			if(timer and timer.type == TIMER_TYPE_PLAYER_COUNTDOWN) then
				FreeTimerTrackerTimer(timer);
			end

			if not timer then
				timer = CreateFrame("FRAME", self:GetName().."Timer"..(#self.timerList+1), UIParent, "StartTimerBar");
				self.timerList[#self.timerList+1] = timer;
			end

			timer:ClearAllPoints();
			timer:SetPoint("TOP", 0, -155 - (24*numTimers));

			timer.isFree = false;
			timer.type = timerType;
			timer.time = timeSeconds;
			timer.endTime = GetTime() + timeSeconds;
			timer.duration = timeSeconds
			timer.startValue = timeSeconds / totalTime
			timer.bar:SetMinMaxValues(0, totalTime);
			timer.bar:Show()
			timer.style = TIMER_NUMBERS_SETS["BigGold"];

			timer.digit1:SetTexture(timer.style.texture);
			timer.digit2:SetTexture(timer.style.texture);
			timer.digit1:SetSize(timer.style.w/2, timer.style.h/2);
			timer.digit2:SetSize(timer.style.w/2, timer.style.h/2);
			--This is to compensate texture size not affecting GetWidth() right away.
			timer.digit1.width, timer.digit2.width = timer.style.w/2, timer.style.w/2;

			timer.digit1.glow = timer.glow1;
			timer.digit2.glow = timer.glow2;
			timer.glow1:SetTexture(timer.style.texture.."Glow");
			timer.glow2:SetTexture(timer.style.texture.."Glow");

			timer.updateTime = TIMER_DATA[timer.type].updateInterval;
			timer:SetScript("OnUpdate", StartTimer_BigNumberOnUpdate);
			timer:Show();
		end
		StartTimer_SetGoTexture(timer);
	elseif event == "STOP_TIMER_OF_TYPE" then
		local timerType = ...;
		for a,timer in pairs(self.timerList) do
			if(timer.type == timerType) then
				FreeTimerTrackerTimer(timer);
				timer:Hide();

				if TIMER_DATA[timerType].readyButton then
					TimerTracker_ReadyStatusButton:Toggle(false)
					C_CacheInstance:Set("TimerTrackerReadyButtonState", {value = false})
				end
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		local hasPVPTimer
		for a,timer in pairs(self.timerList) do
			if(timer.type == TIMER_TYPE_PVP) then
				FreeTimerTrackerTimer(timer);
				hasPVPTimer = true
			end
		end
		if hasPVPTimer then
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
				local timeRemaining = cvarTime - time()
				if timeRemaining > 0 then
					local timerType, totalTime = TimerTracker_GetTimerTypeInfo(getBattlegroundTimerType())
					FireCustomClientEvent("START_TIMER", timerType, timeRemaining, totalTime)
				end
			end
		end
	end
end

function StartTimer_BigNumberOnUpdate(self, elapsed)
	self.time = self.endTime - GetTime();

	self.updateTime = self.updateTime - elapsed;
	local minutes, seconds = floor(self.time/60), floor(mod(self.time, 60));

	if TIMER_DATA[self.type].readyButton or self.type == TIMER_TYPE_ARENA or self.type == TIMER_TYPE_PVP or self.type == TIMER_TYPE_MINIGAMES then
		TimerTracker_ReadyStatusButton:Update(self.time, TIMER_DATA[self.type].mediumMarker);
	end

	if ( self.time < TIMER_DATA[self.type].mediumMarker ) then
		self.anchorCenter = false;
		if self.time < TIMER_DATA[self.type].largeMarker then
			StartTimer_SwitchToLargeDisplay(self);
		end
		self:SetScript("OnUpdate", nil);
		if ( self.barShowing ) then
			self.barShowing = false;
			self.fadeBarOut:Play();
			if (TIMER_DATA[self.type].barHideSoundKitID) then
				PlaySound(TIMER_DATA[self.type].barHideSoundKitID);
			end
		else
			self.bar:Hide()
			self.animationAdjust = true
			self.startNumbers:Play();
		end
	elseif not self.barShowing then
		self.fadeBarIn:Play();
		self.barShowing = true;
		if (TIMER_DATA[self.type].barShowSoundKitID) then
			PlaySound(TIMER_DATA[self.type].barShowSoundKitID);
		end
	elseif self.updateTime <= 0 then
		self.updateTime = TIMER_DATA[self.type].updateInterval;
	end

	self.bar:SetValue(self.time > 0 and self.time or 0.001)
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));
end

function StartTimer_BarOnlyOnUpdate(self, elapsed)
	self.time = self.endTime - GetTime();
	local minutes, seconds = floor(self.time/60), mod(self.time, 60);

	self.bar:SetValue(self.time > 0 and self.time or 0.001)
	self.bar.timeText:SetText(string.format(TIMER_MINUTES_DISPLAY, minutes, seconds));

	if self.time < 0 then
		self:SetScript("OnUpdate", nil)
		self.barShowing = false
		self.isFree = true
		self:Hide();
	end

	if not self.barShowing then
		self.fadeBarIn:Play();
		self.barShowing = true;
	end
end

function StartTimer_SetTexNumbers(self, ...)
	local digits = {...}
	local timeDigits = floor(self.time);
	local digit;
	local style = self.style;
	local i = 1;

	local texCoW = style.w/style.texW;
	local texCoH = style.h/style.texH;
	local l,r,t,b;
	local columns = floor(style.texW/style.w);
	local numberOffset = 0;
	local numShown = 0;

	if self.animationAdjust then
		local roundedTime = ceil(self.time)
		local diff = roundedTime - self.time

		if diff ~= 0 then
			timeDigits = roundedTime
			self.time = roundedTime
			self.animationReset = true

			for _, digitObj in ipairs(digits) do
				digitObj.startNumbers.ScaleOut:SetStartDelay(0.6 + diff)
				digitObj.startNumbers.AlphaOut:SetStartDelay(0.6 + diff)
			end
		end

		self.animationAdjust = nil
	elseif self.animationReset then
		for _, digitObj in ipairs(digits) do
			digitObj.startNumbers.ScaleOut:SetStartDelay(0.6)
			digitObj.startNumbers.AlphaOut:SetStartDelay(0.6)
		end

		self.animationReset = nil
	end

	while digits[i] do -- THIS WILL DISPLAY SECOND AS A NUMBER 2:34 would be 154
		if timeDigits > 0 then
			digit = mod(timeDigits, 10);

			digits[i].hw = style.numberHalfWidths[digit+1]*digits[i].width;
			numberOffset = numberOffset + digits[i].hw;

			l = mod(digit, columns) * texCoW;
			r = l + texCoW;
			t = floor(digit/columns) * texCoH;
			b = t + texCoH;

			digits[i]:SetTexCoord(l,r,t,b);
			digits[i].glow:SetTexCoord(l,r,t,b);

			timeDigits = floor(timeDigits/10);
			numShown = numShown + 1;
		else
			digits[i]:SetTexCoord(0,0,0,0);
			digits[i].glow:SetTexCoord(0,0,0,0);
		end
		i = i + 1;
	end

	if numberOffset > 0 then
		if(TIMER_DATA[self.type].bigNumberSoundKitID and numShown < TIMER_DATA[self.type].largeMarker ) then
			PlaySoundTick(TIMER_DATA[self.type].bigNumberSoundKitID);
		else
			PlaySoundTick(SOUNDKIT.UI_BATTLEGROUND_COUNTDOWN_TIMER)
		end

		digits[1]:ClearAllPoints();
		if self.anchorCenter then
			digits[1]:SetPoint("CENTER", UIParent, "CENTER", numberOffset - digits[1].hw, 0);
		else
			digits[1]:SetPoint("CENTER", self, "CENTER", numberOffset - digits[1].hw, 0);
		end

		for i=2,numShown do
			digits[i]:ClearAllPoints();
			digits[i]:SetPoint("CENTER", digits[i-1], "CENTER", -(digits[i].hw + digits[i-1].hw), 0)
			i = i + 1;
		end
	end
end

local GoTextureTypes = {
	None		= 0,
	FactionIcon	= 1,
	Arena		= 2,
	Challenges	= 3,
}

function StartTimer_SetGoTexture(timer)
	if ( timer.type == TIMER_TYPE_PVP or timer.type == TIMER_TYPE_ARENA ) then
		if timer.type ~= TIMER_TYPE_PVP then
			timer.GoTexture:SetAtlas("countdown-swords");
			timer.GoTextureGlow:SetAtlas("countdown-swords-glow");

			StartTimer_SwitchToLargeDisplay(timer);
		else
			local factionGroup = GetPlayerFactionGroup();
			if ( factionGroup and factionGroup ~= "Neutral" ) then
				timer.GoTexture:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo");
				timer.GoTexture:SetTexCoord(0, 1, 0, 1);
				timer.GoTextureGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo");
				timer.GoTextureGlow:SetTexCoord(0, 1, 0, 1);
			end
		end
	elseif ( timer.type == TIMER_TYPE_CHALLENGE_MODE ) then
		timer.GoTexture:SetTexture("Interface\\Timer\\Challenges-Logo");
		timer.GoTexture:SetTexCoord(0, 1, 0, 1);
		timer.GoTextureGlow:SetTexture("Interface\\Timer\\ChallengesGlow-Logo");
		timer.GoTextureGlow:SetTexCoord(0, 1, 0, 1);
	elseif (timer.type == TIMER_TYPE_PLAYER_COUNTDOWN) then
		timer.GoTexture:SetTexture("")
		timer.GoTextureGlow:SetTexture("")
	elseif (timer.type == TIMER_TYPE_SERVER_HANDLED) then
		local goTextureType = TIMER_DATA[timer.type].goTexture
		if goTextureType == GoTextureTypes.None then
			timer.GoTexture:SetTexture("")
			timer.GoTextureGlow:SetTexture("")
		elseif goTextureType == GoTextureTypes.FactionIcon then
			local factionGroup = GetPlayerFactionGroup();
			if ( factionGroup and factionGroup ~= "Neutral" ) then
				timer.GoTexture:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo");
				timer.GoTexture:SetTexCoord(0, 1, 0, 1);
				timer.GoTextureGlow:SetTexture("Interface\\Timer\\"..factionGroup.."Glow-Logo");
				timer.GoTextureGlow:SetTexCoord(0, 1, 0, 1);
			end
		elseif goTextureType == GoTextureTypes.Arena then
			timer.GoTexture:SetAtlas("countdown-swords");
			timer.GoTextureGlow:SetAtlas("countdown-swords-glow");
		elseif goTextureType == GoTextureTypes.Challenges then
			timer.GoTexture:SetTexture("Interface\\Timer\\Challenges-Logo");
			timer.GoTexture:SetTexCoord(0, 1, 0, 1);
			timer.GoTextureGlow:SetTexture("Interface\\Timer\\ChallengesGlow-Logo");
			timer.GoTextureGlow:SetTexCoord(0, 1, 0, 1);
		end
	end
end

function StartTimer_NumberAnimOnFinished(self)
	self.time = self.time - 1;
	if self.time > 0 then
		if self.time < TIMER_DATA[self.type].largeMarker then
			StartTimer_SwitchToLargeDisplay(self);
		end
		if self.digit2.startNumbers:IsPlaying() then
			self.digit2.startNumbers:Stop()
		end
		if self.glow2.startNumbers:IsPlaying() then
			self.glow2.startNumbers:Stop()
		end
		self.startNumbers:Play();
	else
		if(TIMER_DATA[self.type].finishedSoundKitID) then
			PlaySound(TIMER_DATA[self.type].finishedSoundKitID);
		else
			PlaySound("ui_battlegroundcountdown_end")
		end
		self:SetScript("OnUpdate", nil)
		self.isFree = true
		self.barShowing = false
		self.GoTextureAnim:Play();

		C_CacheInstance:Set("TimerTrackerReadyButtonState", {value = false})

		if self.type == TIMER_TYPE_SERVER_HANDLED then
			FlashClientIcon()
		end
	end
end

function StartTimer_SwitchToLargeDisplay(self)
	if not self.anchorCenter then
		self.anchorCenter = true;
		--This is to compensate texture size not affecting GetWidth() right away.
		self.digit1.width, self.digit2.width = self.style.w, self.style.w;
		self.digit1:SetSize(self.style.w, self.style.h);
		self.digit2:SetSize(self.style.w, self.style.h);

		if(TIMER_DATA[self.type].mediumNumberFinishedSoundKitID) then
			PlaySound(TIMER_DATA[self.type].mediumNumberFinishedSoundKitID);
		end
	end
end

TimerTrackerReadyButtonMixin = {}

function TimerTrackerReadyButtonMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function TimerTrackerReadyButtonMixin:OnEvent(event, ... )
	local _, instanceTyp = IsInInstance()
	if instanceTyp == "none" then
		self:Hide()
		C_CacheInstance:Set("TimerTrackerReadyButtonState", {value = false})
	end
end

function TimerTrackerReadyButtonMixin:OnShow()
	SetParentFrameLevel(self.Glow, -1)
	self.HighlightTexture:Hide()
	self:UpdateText(false)
end

function TimerTrackerReadyButtonMixin:OnHide()
	self.Selection:Hide()
	self.ReadyText:SetText("0 / 0")
end

function TimerTrackerReadyButtonMixin:OnClick(button)
	if not self.Selection.AnimOut:IsPlaying() and not self.AnimIn:IsPlaying() and not self.AnimOut:IsPlaying() then
		self.Selection.AnimOut:Stop()
		self.Selection.AnimIn:Stop()
		self.Selection:SetVertexColor(0, 1, 0)

		if self:GetChecked() then
			self.Selection:Show()
			self.Selection.AnimIn:Play()

			self.HighlightTexture:Hide()
		else
			self.Selection:Show()
			self.Selection:SetVertexColor(1, 0, 0)
			self.Selection.AnimOut:Play()
			self.Selection:SetAlpha(0.2)

			self.HighlightTexture:Show()
		end

		self.checked = self:GetChecked() == 1

		C_CacheInstance:Set("TimerTrackerReadyButtonState", {value = self.checked})
		SendServerMessage("ACMSG_ARENA_READY_STATUS", self.checked and 1 or 0)

		self:UpdateText(true)
	else
		self:SetChecked(self.checked)
	end
end

function TimerTrackerReadyButtonMixin:OnMouseDown(button)
	if self.Selection.AnimOut:IsPlaying() or self.AnimIn:IsPlaying() or self.AnimOut:IsPlaying() then
		return
	end

	self.ReadyText:SetPoint("CENTER", 1, 5)
end

function TimerTrackerReadyButtonMixin:OnMouseUp(button)
	self.ReadyText:SetPoint("CENTER", 0, 6)
end

function TimerTrackerReadyButtonMixin:UpdateText(forceUpdate)
	local state = C_CacheInstance:Get("TimerTrackerReadyButtonState")

	if state then
		local needAnimationText = self.checked ~= state.value

		if needAnimationText and not forceUpdate then
			self.ReadyText.AnimSwap:Play()
			self.ReadyTextDescription.AnimSwap:Play()
		end

		if state.value then
			if self.Glow.AlphaAnim:IsPlaying() then
				self.Glow.AlphaAnim:Stop()
			end
		else
			self.Glow.AlphaAnim:Play()
		end

		self.checked = state.value
		self:SetChecked(state.value)

		if not forceUpdate then
			if self:GetChecked() then
				self.Selection:Show()
				self.Selection:SetAlpha(0.2)
			else
				self.Selection:Hide()
			end
		end

		if state.value == true then
			local data = C_CacheInstance:Get("ASMSG_ARENA_READY_STATUS")

			if data and data.bracket and data.readyCount then
				self.ReadyText:SetFormattedText("%d / %d", data.readyCount, data.bracket)
				self.ReadyTextDescription:SetText(READY_ARENA_WAIT_PLAYER_LABEL)
			end
		else
			self.ReadyText:SetText(READY_LABEL)
			if C_MiniGames.GetActiveID() then
				self.ReadyTextDescription:SetText(READY_MINIGAME_DESCRIPTION_LABEL)
			else
				self.ReadyTextDescription:SetText(READY_ARENA_DESCRIPTION_LABEL)
			end
		end
	end
end

function TimerTrackerReadyButtonMixin:OnEnter()
	if self.Selection.AnimOut:IsPlaying() or self.AnimIn:IsPlaying() or self.AnimOut:IsPlaying() then
		return
	end

	if not self:GetChecked() then
		self.HighlightTexture:Show()
	else
		self.Selection:SetAlpha(0.3)
	end
end

function TimerTrackerReadyButtonMixin:OnLeave()
	self.HighlightTexture:Hide()
	self.Selection:SetAlpha(0.2)
end

function TimerTrackerReadyButtonMixin:Toggle(state)
	if not state then
		if self:IsShown() then
			self.AnimOut:Play()
		end

		return
	end

	local timerBar
	for _, timer in ipairs(TimerTracker.timerList) do
		if not timer.isFree then
			timerBar = timer
			break
		end
	end

	if timerBar then
		self:ClearAllPoints()
		self:SetPoint("TOP", timerBar, "BOTTOM", 1, 4)
		self:Show()
	end
end

function TimerTrackerReadyButtonMixin:Update(currentTime, fadeTime)
	fadeTime = fadeTime or 12;

	if currentTime > fadeTime and not self:IsShown() then
		self:Toggle(true)
		self.AnimIn:Play()
	elseif currentTime < fadeTime and self:IsShown() then
		self.AnimOut:Play()
	end
end

function EventHandler:ASMSG_ARENA_READY_STATUS(msg)
	local bracket, readyCount = string.split("|", msg)

	if readyCount then
		C_CacheInstance:Set("ASMSG_ARENA_READY_STATUS", {
			bracket = tonumber(bracket),
			readyCount = tonumber(readyCount)
		})
	end

	TimerTracker_ReadyStatusButton:UpdateText(true)
end

function EventHandler:ASMSG_EVENT_START_TIMER(msg)
	local timeRemainingMS, totalTimeMS, mediumMarker, largeMarker, goTexture, readyButton = string.split(":", msg)

	totalTimeMS = tonumber(totalTimeMS)

	if totalTimeMS <= 0 then
		FireCustomClientEvent("STOP_TIMER_OF_TYPE", TIMER_TYPE_SERVER_HANDLED)
		return
	end

	timeRemainingMS = tonumber(timeRemainingMS)
	mediumMarker = tonumber(mediumMarker)
	largeMarker = tonumber(largeMarker)

	local markeyTimeOffset = timeRemainingMS * 0.001 <= mediumMarker and 1 or 2

	TIMER_DATA[TIMER_TYPE_SERVER_HANDLED].mediumMarker = mediumMarker > 0 and (mediumMarker + markeyTimeOffset) or 0
	TIMER_DATA[TIMER_TYPE_SERVER_HANDLED].largeMarker = largeMarker > 0 and (largeMarker + markeyTimeOffset) or 0
	TIMER_DATA[TIMER_TYPE_SERVER_HANDLED].goTexture = tonumber(goTexture)
	TIMER_DATA[TIMER_TYPE_SERVER_HANDLED].readyButton = readyButton == "1"

	if readyButton == "1" then
		FlashClientIcon()
	else
		TimerTracker_ReadyStatusButton:Toggle(false)
	end

	FreeAllTimerTrackerTimer()
--	FireCustomClientEvent("STOP_TIMER_OF_TYPE", TIMER_TYPE_SERVER_HANDLED)
	FireCustomClientEvent("START_TIMER", TIMER_TYPE_SERVER_HANDLED, timeRemainingMS * 0.001, totalTimeMS * 0.001)
end

local TIMEOUT_LIST = {}
local COUNTDOUWN_TIMEOUT_SECONDS = 10
local COUNTDOUWN_TIMEOUT_MAX_COUNT = 5

do
	local isLeaderOrRaidOfficer = function(name)
		if UnitIsGroupLeader(name) then
			return true
		else
			local raidID = UnitInRaid(name)
			if raidID and select(2, GetRaidRosterInfo(raidID + 1)) > 0 then
				return true
			end
		end
		return false
	end

	local eventHandler = CreateFrame("Frame")
	eventHandler:Hide()
	eventHandler:RegisterEvent("CHAT_MSG_ADDON")
	eventHandler:SetScript("OnEvent", function(self, event, prefix, msg, distribution, sender)
		if event == "CHAT_MSG_ADDON" then
			if prefix == "START_TIMER_PLAYER_COUNTDOWN" then
				if (distribution == "RAID" or distribution == "PARTY") and isLeaderOrRaidOfficer(sender) then
					if not TIMEOUT_LIST[sender] or TIMEOUT_LIST[sender][2] < COUNTDOUWN_TIMEOUT_MAX_COUNT then
						local seconds = tonumber(msg)
						if seconds and seconds >= 3 then
							local _, instanceType = GetInstanceInfo()
							if instanceType == "pvp" or instanceType == "arena" then
								return
							end

							if not TIMEOUT_LIST[sender] then
								TIMEOUT_LIST[sender] = {0, 1}
								self:Show()
							else
								TIMEOUT_LIST[sender][2] = TIMEOUT_LIST[sender][2] + 1
							end

							FireCustomClientEvent("START_TIMER", TIMER_TYPE_PLAYER_COUNTDOWN, seconds, seconds)
						end
					end
				end
			elseif prefix == "STOP_TIMER_OF_TYPE" then
				if (distribution == "RAID" or distribution == "PARTY") and isLeaderOrRaidOfficer(sender) then
					if not TIMEOUT_LIST[sender] or TIMEOUT_LIST[sender][2] <= COUNTDOUWN_TIMEOUT_MAX_COUNT then
						if msg == "0" then
							local _, instanceType = GetInstanceInfo()
							if instanceType == "pvp" or instanceType == "arena" then
								return
							end

							if not TIMEOUT_LIST[sender] then
								TIMEOUT_LIST[sender] = {0, 1}
								self:Show()
							else
								TIMEOUT_LIST[sender][2] = TIMEOUT_LIST[sender][2] + 1
							end

							FireCustomClientEvent("STOP_TIMER_OF_TYPE", TIMER_TYPE_PLAYER_COUNTDOWN)
						end
					end
				end
			end
		end
	end)
	eventHandler:SetScript("OnUpdate", function(self, elapsed)
		for sender, timeoutData in pairs(TIMEOUT_LIST) do
			timeoutData[1] = timeoutData[1] + elapsed
			if timeoutData[1] >= COUNTDOUWN_TIMEOUT_SECONDS then
				TIMEOUT_LIST[sender] = nil
			end
		end
		if not next(TIMEOUT_LIST) then
			self:Hide()
		end
	end)
end

local getDistibutionChannel = function()
	if GetNumRaidMembers() > 0 then
		return "RAID"
	elseif GetNumPartyMembers() > 0 then
		return "PARTY"
	end
end

function TimerTracker_DoCountdown(seconds)
	if type(seconds) == "string" then
		seconds = tonumber(seconds)
	end
	if type(seconds) ~= "number" then
		error("Usage: C_PartyInfo_DoCountdown(seconds)", 2)
	end

	local playerName = UnitName("player")
	if seconds <= 0 and (not TIMEOUT_LIST[playerName] or TIMEOUT_LIST[playerName][2] < COUNTDOUWN_TIMEOUT_MAX_COUNT) then
		local distribution = getDistibutionChannel()
		if distribution then
			SendAddonMessage("STOP_TIMER_OF_TYPE", 0, distribution)
		else
			FireCustomClientEvent("STOP_TIMER_OF_TYPE", TIMER_TYPE_PLAYER_COUNTDOWN)
		end
	elseif seconds < 3 then
		return
	end

	if not IsPartyLeader() and not IsRaidLeader() and not IsRaidOfficer() and (GetNumRaidMembers() ~= 0 or GetNumPartyMembers() ~= 0) then
		return
	end

	local _, instanceType = GetInstanceInfo()
	if instanceType == "pvp" or instanceType == "arena" then
		return
	end

	if not TIMEOUT_LIST[playerName] or TIMEOUT_LIST[playerName][2] < COUNTDOUWN_TIMEOUT_MAX_COUNT then
		local distribution = getDistibutionChannel()
		if distribution then
			SendAddonMessage("START_TIMER_PLAYER_COUNTDOWN", seconds, distribution)
		else
			FireCustomClientEvent("START_TIMER", TIMER_TYPE_PLAYER_COUNTDOWN, seconds, seconds)
		end
	else
		UIErrorsFrame:AddMessage(ERR_GENERIC_THROTTLE, 1.0, 0.1, 0.1, 1.0)
	end
end