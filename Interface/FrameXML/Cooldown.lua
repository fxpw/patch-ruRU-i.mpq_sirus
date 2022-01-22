CustomCooldownFrameMixin = {}

function CustomCooldownFrameMixin:OnLoad()
	self.Overlay:SetAtlas("CooldownTexture_0")

	self.speed 		= 1
	self.elapsed 	= 0
	self.timer 		= 0
	self.duration 	= 0
end

function CustomCooldownFrameMixin:OnUpdate( diff )
	self.elapsed = self.elapsed + diff

	if self.elapsed >= 0.1 and self.duration > 0 then
		local speed = self.isArenaSpectator and ArenaSpectatorFrame:GetSpeed() or self.speed

		self.timer = self.timer + self.elapsed * speed

		local proc =  self.timer / self.duration * 100

		if proc > 100 then
			self.duration = 0
		end

		self.Overlay:SetAtlas("CooldownTexture_"..math.min(math.Round(proc), 99))

		self.elapsed = 0
	end
end

function CustomCooldownFrameMixin:SetCooldown( duration, speed, isArenaSpectator )
	self.timer 				= 0
	self.elapsed 			= 0
	self.isArenaSpectator 	= isArenaSpectator
	self.speed 				= speed or self.speed
	self.duration 			= duration

	self.Overlay:SetAtlas("CooldownTexture_0")
end

function CustomCooldownFrameMixin:Pause()
	-- body
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
