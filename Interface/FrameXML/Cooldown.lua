CustomCooldownFrameMixin = {}

function CustomCooldownFrameMixin:OnLoad()
	self.updateTime = 0.03
	self:Clear()
end

function CustomCooldownFrameMixin:OnEvent(event, ...)
	if event == "ARENA_SPECTATOR_PAUSE" or event == "ARENA_SPECTATOR_PLAYBACK_SPEED" then
		self:UpdateFrame()
	end
end

function CustomCooldownFrameMixin:OnUpdate(elapsed)
	if self:IsPaused() then
		return
	end

	self.elapsed = self.elapsed + elapsed

	if self.elapsed >= self.updateTime then
		self:UpdateFrame()
		self.elapsed = 0
	end
end

function CustomCooldownFrameMixin:UpdateFrame()
	if self.duration <= 0 then
		self:Clear()
		return
	end

	local progress = self:GetCooldownDuration() / self.duration
	if progress >= 1 then
		self:Clear()
		return
	end

	local atlasIndex
	if self.reverse then
		atlasIndex = math.max(0, math.min(Round(100 - progress * 100), 99))
	else
		atlasIndex = math.max(0, math.min(Round(progress * 100), 99))
	end
	self.Overlay:SetAtlas("CooldownTexture_"..atlasIndex)
end

function CustomCooldownFrameMixin:SetCooldown(start, duration, speed)
	local timer
	if self.isArenaSpectator then
		timer = C_ArenaSpectator.GetMatchTime() - start
	else
		timer = (GetTime() - start) * (speed or 1)
	end

	if timer >= duration then
		self:Clear()
		return
	end

	self.start 		= start
	self.duration 	= duration
	self.speed 		= speed or self.speed
	self.elapsed 	= 0

	self.Overlay:SetAtlas("CooldownTexture_0")
	self:Show()
end

function CustomCooldownFrameMixin:GetCooldownDuration()
	if self.isArenaSpectator then
		return C_ArenaSpectator.GetMatchTime() - self.start
	else
		return (GetTime() - self.start) * (self.speed or 1)
	end
end

function CustomCooldownFrameMixin:GetCooldownTimes()
	return self.start, self.duration
end

function CustomCooldownFrameMixin:Pause()
	self.paused = true
	self:UpdateFrame()
end

function CustomCooldownFrameMixin:Resume()
	self.paused = false
	self:UpdateFrame()
end

function CustomCooldownFrameMixin:IsPaused()
	if self.paused then
		return true
	elseif self.isArenaSpectator and C_ArenaSpectator.IsPaused() then
		return true
	end
	return false
end

function CustomCooldownFrameMixin:SetReverse(reverse)
	self.reverse = not not reverse
	self:UpdateFrame()
end

function CustomCooldownFrameMixin:GetReverse()
	return self.reverse
end

function CustomCooldownFrameMixin:Clear()
	self.elapsed 	= 0
	self.start 		= 0
	self.duration 	= 0
	self.speed 		= 1
	self.paused		= false
	self.Overlay:SetAtlas("CooldownTexture_0")
	self:Hide()
end

function CustomCooldownFrameMixin:UseArenaSpectatorTimescale(state)
	self.isArenaSpectator = not not state
	if self.isArenaSpectator then
		self:RegisterCustomEvent("ARENA_SPECTATOR_PAUSE")
		self:RegisterCustomEvent("ARENA_SPECTATOR_PLAYBACK_SPEED")
	else
		self:UnregisterCustomEvent("ARENA_SPECTATOR_PAUSE")
		self:UnregisterCustomEvent("ARENA_SPECTATOR_PLAYBACK_SPEED")
	end
	self:UpdateFrame()
end

function CooldownFrame_SetTimer(self, start, duration, enable)
	if type(enable) == "boolean" then
		enable = enable and 1 or 0
	end

	if ( start > 0 and duration > 0 and enable > 0) then
		self:SetCooldown(start, duration);
		self:Show();
	else
		self:Hide();
	end
end
