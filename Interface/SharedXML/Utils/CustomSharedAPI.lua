local IsOnGlueScreen = IsOnGlueScreen

local GetScreenHeight = GetScreenHeight
function GetDefaultScale()
	return 768 / GetScreenHeight()
end

local FlashClientIcon = FlashClientIcon
_G.FlashClientIcon = function()
	if type(FlashClientIcon) == "function" then
		if IsOnGlueScreen() or C_CVar:GetValue("C_CVAR_FLASH_CLIENT_ICON") == "1" then
			FlashClientIcon()
		end
	end
end