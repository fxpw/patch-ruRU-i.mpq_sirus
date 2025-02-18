UIPanelButtonChallengeStateHandlerMixin = {}

function UIPanelButtonChallengeStateHandlerMixin:OnLoad()
	self.isDisabled = false
	self.featureFlag = tonumber(self:GetParent():GetAttribute("featureFlag"))
	self.featureFlag1 = tonumber(self:GetParent():GetAttribute("featureFlag1"))

	if self.featureFlag or self.featureFlag1 then
		self:RegisterCustomEvent("CUSTOM_CHALLENGE_ACTIVATED")
		self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")
	end

	self:UpdateState()
end

function UIPanelButtonChallengeStateHandlerMixin:OnEvent(event, ...)
	if event == "CUSTOM_CHALLENGE_ACTIVATED" or (event == "CUSTOM_CHALLENGE_DEACTIVATED" and select(2, ...) ~= Enum.HardcoreDeathReason.FAILED_DEATH) then
		self:UpdateState()
	end
end

function UIPanelButtonChallengeStateHandlerMixin:OnShow()
	self:UpdateState()
end

function UIPanelButtonChallengeStateHandlerMixin:OnHide()
	self:UpdateState()
end

function UIPanelButtonChallengeStateHandlerMixin:UpdateState()
	if self.featureFlag and C_Hardcore.IsFeatureAvailable(self.featureFlag)
		or self.featureFlag1 and C_Hardcore.IsFeature1Available(self.featureFlag1)
	then
		self:SetDisable()
	elseif self:IsDisabled() then
		self:SetEnable()
	end
end

function UIPanelButtonChallengeStateHandlerMixin:SetEnable()
	local button = self:GetParent()

	button.SetEnabled = nil
	button.Enable = nil
	button.Disable = nil
	button.SetScript = nil

	if self.originalIsEnabled then
		button:Enable()
	end

	if self.motionScriptsWhileDisabled then
		button:SetMotionScriptsWhileDisabled(false)
	end

	self.isDisabled = false
end

function UIPanelButtonChallengeStateHandlerMixin:SetDisable()
	if self.isDisabled then
		return
	end

	local button = self:GetParent()

	self.isDisabled = true

	if button:IsEnabled() == 1 then
		self.originalIsEnabled = true
	end

	if not button:GetMotionScriptsWhileDisabled() then
		button:SetMotionScriptsWhileDisabled(true)
		self.motionScriptsWhileDisabled = false
	end

	if button.pulseDuration then
		ButtonPulse_StopPulse(button)
	end

	button:Disable()

	button.Disable = function(this)
		self.originalIsEnabled = false
		getmetatable(this).__index.Disable(this)
	end
	button.SetEnabled = function(this, isEnabled)
		self.originalIsEnabled = isEnabled
		getmetatable(this).__index.SetEnabled(this, false)
	end
	button.Enable = function(this)
		self.originalIsEnabled = true
		getmetatable(this).__index.Disable(this)
	end
end

function UIPanelButtonChallengeStateHandlerMixin:IsDisabled()
	return self.isDisabled
end