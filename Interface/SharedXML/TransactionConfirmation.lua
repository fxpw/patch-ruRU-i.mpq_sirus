local IsInterfaceDevClient = IsInterfaceDevClient
local ScreenshotStore = ScreenshotStore

local TRANSACTION_CONFIRMATION_TIME = 3

EventRegistry:RegisterFrameEventAndCallback("STORE_API_LOADED", function(owner, ...)
	TRANSACTION_CONFIRMATION_TIME = C_StoreSecure.GetPurchaseDelayTime()
	EventRegistry:UnregisterFrameEventAndCallback("STORE_API_LOADED", owner)
end, "TransactionConfirmation")

TransactionConfirmationMixin = {}

function TransactionConfirmationMixin:Enable()
	if self:IsConfirmationTimerActive() then
		self.queuedButtonState = true
	else
		getmetatable(self).__index.Enable(self)
	end
end

function TransactionConfirmationMixin:Disable()
	if self:IsConfirmationTimerActive() then
		self.queuedButtonState = false
	else
		getmetatable(self).__index.Disable(self)
	end
end

function TransactionConfirmationMixin:SetEnabled(enabled)
	if self:IsConfirmationTimerActive() then
		self.queuedButtonState = enabled
	else
		getmetatable(self).__index.SetEnabled(self, enabled)
	end
end

function TransactionConfirmationMixin:ConfirmationControllerOnEvent(event)
	if event == "SCREENSHOT_STORE_SUCCEEDED" then
		if self.confirmFunction then
			self.confirmFunction(true)
		end
	elseif event == "SCREENSHOT_STORE_FAILED" then
		if self.confirmFunction then
			self.confirmFunction(false)
		end
	end

	self.ConfirmationController:UnregisterEvent("SCREENSHOT_STORE_SUCCEEDED")
	self.ConfirmationController:UnregisterEvent("SCREENSHOT_STORE_FAILED")
end

function TransactionConfirmationMixin:ConfirmationControllerOnUpdate(elapsed)
	self.confirmationTimer = (self.confirmationTimer or 0) - elapsed

	if self.confirmationTimer > 0 then
		if not self.hideTimerText then
			self:GetConfirmationTextObject():SetText(math.ceil(self.confirmationTimer))
		end
	else
		self:StopConfirmationTimer()
	end
end

function TransactionConfirmationMixin:ConfirmationControllerOnHide()
	if self:IsConfirmationTimerActive() then
		self:StopConfirmationTimer()
	end
end

function TransactionConfirmationMixin:StartConfirmationTimer(setDisabled, confirmationTime)
	if IsInterfaceDevClient() then
		if self.onConfirmationTimerDone then
			self.onConfirmationTimerDone()
		end
		return
	end

	if setDisabled then
		if self.queuedButtonState == nil then
			self.queuedButtonState = self:IsEnabled() == 1
		end
		getmetatable(self).__index.Disable(self)
	else
		self.queuedButtonState = nil
	end

	self.confirmationTimer = confirmationTime or TRANSACTION_CONFIRMATION_TIME

	if self.confirmationTimer > 0 then
		self:ConfirmationControllerOnUpdate(0)
		self.ConfirmationController:SetScript("OnUpdate", function(this, elapsed)
			self:ConfirmationControllerOnUpdate(elapsed)
		end)
	elseif self.confirmationTimer then
		self:StopConfirmationTimer()
	end
end

function TransactionConfirmationMixin:StopConfirmationTimer()
	self.ConfirmationController:SetScript("OnUpdate", nil)
	self.confirmationTimer = nil

	if self.queuedButtonState ~= nil then
		getmetatable(self).__index.SetEnabled(self, self.queuedButtonState)
		self.queuedButtonState = nil
	end

	if self.onConfirmationTimerDone then
		self.onConfirmationTimerDone()
	end
end

function TransactionConfirmationMixin:TakeConfirmationScreenshot(confirmFunction, skipScreenshot)
	if skipScreenshot or IsInterfaceDevClient() then
		if confirmFunction then
			confirmFunction()
		end
		return
	end

	self.confirmFunction = confirmFunction

	self.ConfirmationController:RegisterEvent("SCREENSHOT_STORE_SUCCEEDED")
	self.ConfirmationController:RegisterEvent("SCREENSHOT_STORE_FAILED")

	ScreenshotStore()
end

function TransactionConfirmationMixin:SetConfirmationTimerDone(timerDoneFunction)
	self.onConfirmationTimerDone = timerDoneFunction
end

function TransactionConfirmationMixin:SetConfirmationTextObject(obj)
	assert(obj == nil or (type(obj) == "table" and type(obj.GetObjectType) == "function"))
	self.confirmationTextObject = obj
end

function TransactionConfirmationMixin:GetConfirmationTextObject()
	return self.confirmationTextObject or self
end

function TransactionConfirmationMixin:SetConfirmationShownTimerText(shown)
	self.hideTimerText = not shown
end

function TransactionConfirmationMixin:IsConfirmationTimerActive()
	return (self.confirmationTimer or 0) > 0
end