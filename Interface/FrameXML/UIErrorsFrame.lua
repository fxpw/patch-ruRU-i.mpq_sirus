
function UIErrorsFrame_OnLoad(self)
	self:RegisterEvent("SYSMSG");
	self:RegisterEvent("UI_INFO_MESSAGE");
	self:RegisterEvent("UI_ERROR_MESSAGE");
end

function UIErrorsFrame_OnEvent(self, event, ...)
	if event == "SYSMSG" then
		local message, r, g, b = ...;
		self:AddMessage(message, r, g, b, 1.0);
	elseif event == "UI_INFO_MESSAGE" then
		local message = ...;
		self:AddMessage(message, 1.0, 1.0, 0.0, 1.0);
	elseif event == "UI_ERROR_MESSAGE" then
		local message = ...;
		self:AddMessage(message, 1.0, 0.1, 0.1, 1.0);
	end
end