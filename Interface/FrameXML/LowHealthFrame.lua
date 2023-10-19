LOWHEALTH_MIN_ALPHA = 0.4;
LOWHEALTH_MAX_ALPHA = 0.9;

LowHealthFrameMixin = {};

LOW_HEALTH_FRAME_STATE_DISABLED = 0;
LOW_HEALTH_FRAME_STATE_FULLSCREEN = 1;
LOW_HEALTH_FRAME_STATE_LOW_HEALTH = 2;

function LowHealthFrameMixin:OnLoad()
	self.inCombat = false;

	self:EvaluateVisibleState();

	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
end

function LowHealthFrameMixin:OnEvent(event, ...)
	local arg1 = ...;
	if event == "PLAYER_REGEN_DISABLED" then
		self:SetInCombat(true);
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:SetInCombat(false);
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.playerEntered = true;
	elseif event == "VARIABLES_LOADED" then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
	end

	if event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" then
		if self.playerEntered and self.varsLoaded then
			self:EvaluateVisibleState();
		end
	end
end

function LowHealthFrameMixin:DetermineFlashState()
	if UnitIsGhost("player") or UnitIsDead("player") then
		return LOW_HEALTH_FRAME_STATE_DISABLED;
	end

	if ( CinematicFrame and CinematicFrame:IsShown() ) then
		return LOW_HEALTH_FRAME_STATE_DISABLED;
	end

	if ( MovieFrame and MovieFrame:IsShown() ) then
		return LOW_HEALTH_FRAME_STATE_DISABLED;
	end

	-- flash if we're in combat and can't see the world
	if self.inCombat then
		if GetCVarBool("screenEdgeFlash") and GetUIPanel("fullscreen") then
			return LOW_HEALTH_FRAME_STATE_FULLSCREEN;
		end
	end

	return LOW_HEALTH_FRAME_STATE_DISABLED;
end

function LowHealthFrameMixin:EvaluateVisibleState()
	local healthState = self:DetermineFlashState();
	if healthState == LOW_HEALTH_FRAME_STATE_DISABLED then
		CombatFeedback_StopFullscreenStatus();
	elseif healthState == LOW_HEALTH_FRAME_STATE_FULLSCREEN then
		CombatFeedback_StartFullscreenStatus();
	else
		error("Unknown Low Health Frame State");
	end
end

function LowHealthFrameMixin:SetInCombat(inCombat)
	if self.inCombat ~= inCombat then
		self.inCombat = inCombat;
		if ( self.inCombat ) then
			FlashClientIcon();
		end
		self:EvaluateVisibleState();
	end
end

function CombatFeedback_StartFullscreenStatus()
	LowHealthFrame_StartFlashing(0.7, 0.7);
end

function CombatFeedback_StopFullscreenStatus()
	LowHealthFrame_StopFlashing();
end

function LowHealthFrame_StartFlashing(fadeInTime, fadeOutTime, flashDuration, flashInHoldTime, flashOutHoldTime)
	-- Time it takes to fade in a flashing frame
	LowHealthFrame.fadeInTime = fadeInTime;
	-- Time it takes to fade out a flashing frame
	LowHealthFrame.fadeOutTime = fadeOutTime;
	-- How long to keep the frame flashing
	LowHealthFrame.flashDuration = flashDuration;
	-- How long to hold the faded in state
	LowHealthFrame.flashInHoldTime = flashInHoldTime;
	-- How long to hold the faded out state
	LowHealthFrame.flashOutHoldTime = flashOutHoldTime;

	LowHealthFrame.flashMode = "IN";
	LowHealthFrame.flashTimer = 0;				-- timer for the current flash mode
	LowHealthFrame.flashDurationTimer = 0;		-- timer for the entire flash

	LowHealthFrame:SetAlpha(LOWHEALTH_MIN_ALPHA);
	LowHealthFrame:Show();

	LowHealthFrame:SetScript("OnUpdate", LowHealthFrame_OnUpdate);
end

function LowHealthFrame_OnUpdate(self, elapsed)
	self.flashDurationTimer = self.flashDurationTimer + elapsed;
	-- If flashDuration is exceeded
	if ( self.flashDuration and (self.flashDurationTimer > self.flashDuration) ) then
		LowHealthFrame_StopFlashing();
	else
		if ( self.flashMode == "IN" ) then
			local alpha = LOWHEALTH_MIN_ALPHA + (LOWHEALTH_MAX_ALPHA - LOWHEALTH_MIN_ALPHA) * (self.flashTimer / self.fadeOutTime);
			self:SetAlpha(alpha);

			if ( self.flashTimer >= self.fadeInTime ) then
				if ( self.flashInHoldTime and self.flashInHoldTime > 0 ) then
					self.flashMode = "IN_HOLD";
				else
					self.flashMode = "OUT";
				end
				self.flashTimer = 0;
			else
				self.flashTimer = self.flashTimer + elapsed;
			end
		elseif ( self.flashMode == "IN_HOLD" ) then
			self:SetAlpha(LOWHEALTH_MAX_ALPHA);

			if ( self.flashTimer >= self.flashInHoldTime ) then
				self.flashMode = "OUT";
				self.flashTimer = 0;
			else
				self.flashTimer = self.flashTimer + elapsed;
			end
		elseif ( self.flashMode == "OUT" ) then
			local alpha = LOWHEALTH_MAX_ALPHA + (LOWHEALTH_MIN_ALPHA - LOWHEALTH_MAX_ALPHA) * (self.flashTimer / self.fadeOutTime);
			self:SetAlpha(alpha);

			if ( self.flashTimer >= self.fadeOutTime ) then
				if ( self.flashOutHoldTime and self.flashOutHoldTime > 0 ) then
					self.flashMode = "OUT_HOLD";
				else
					self.flashMode = "IN";
				end
				self.flashTimer = 0;
			else
				self.flashTimer = self.flashTimer + elapsed;
			end
			self:SetAlpha(alpha);
		elseif ( self.flashMode == "OUT_HOLD" ) then
			self:SetAlpha(LOWHEALTH_MIN_ALPHA);

			self.flashTimer = self.flashTimer + elapsed;
			if ( self.flashTimer >= self.flashOutHoldTime ) then
				self.flashMode = "IN";
				self.flashTimer = 0;
			else
				self.flashTimer = self.flashTimer + elapsed;
			end
		end
	end

	if ( not GetUIPanel("fullscreen") ) then
		-- this feature is only supposed to be seen when the screen is covered
		-- also, alpha is set to 0 so OnUpdate can be called
		self:SetAlpha(0.0);
	end
end

function LowHealthFrame_StopFlashing()
	if ( LowHealthFrame:IsShown() ) then
		LowHealthFrame:SetScript("OnUpdate", nil);
		LowHealthFrame:Hide();
	end
end
