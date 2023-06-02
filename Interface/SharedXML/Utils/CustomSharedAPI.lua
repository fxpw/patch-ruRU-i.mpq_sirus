local GetScreenHeight = GetScreenHeight
function GetDefaultScale()
	return 768 / GetScreenHeight()
end

local FlashClientIcon = FlashClientIcon
_G.FlashClientIcon = function()
	if type(FlashClientIcon) == "function" then
		FlashClientIcon()
	end
end