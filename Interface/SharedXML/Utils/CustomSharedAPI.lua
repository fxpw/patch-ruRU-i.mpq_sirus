local IsOnGlueScreen = IsOnGlueScreen

local GetPhysicalScreenSize = GetPhysicalScreenSize
function GetDefaultScale()
	if IsOnGlueScreen() then
		return 1
	else
		local physicalWidth, physicalHeight = GetPhysicalScreenSize()
		return 768.0 / physicalHeight
	end
end

local FlashClientIcon = FlashClientIcon
_G.FlashClientIcon = function()
	if type(FlashClientIcon) == "function" then
		if IsOnGlueScreen() or C_CVar:GetValue("C_CVAR_FLASH_CLIENT_ICON") == "1" then
			FlashClientIcon()
		end
	end
end

do	-- GetCharacterCategoryInfoBySpell
	local CATEGORY_SPELL_ID = {
		[90036] = {0, 0}, [302100] = {0, 1}, [302101] = {0, 2}, [302102] = {0, 3}, [302103] = {0, 4}, [302104] = {0, 5}, [302105] = {0, 6}, [302106] = {0, 7}, [302107] = {0, 8},
		[90028] = {1, 0}, [90029] = {1, 1}, [90030] = {1, 2}, [90031] = {1, 3}, [90032] = {1, 4}, [90033] = {1, 5}, [90034] = {1, 6}, [90035] = {1, 7},
		[90021] = {2, 0}, [90022] = {2, 1}, [90023] = {2, 2}, [90024] = {2, 3}, [90025] = {2, 4}, [90026] = {2, 5}, [90027] = {2, 6},
		[90015] = {3, 0}, [90016] = {3, 1}, [90017] = {3, 2}, [90018] = {3, 3}, [90019] = {3, 4}, [90020] = {3, 5},
		[90010] = {4, 0}, [90011] = {4, 1}, [90012] = {4, 2}, [90013] = {4, 3}, [90014] = {4, 4},
		[90006] = {5, 0}, [90007] = {5, 1}, [90008] = {5, 2}, [90009] = {5, 3},
		[90003] = {6, 0}, [90004] = {6, 1}, [90005] = {6, 2},
		[90001] = {7, 0}, [90002] = {7, 1},
	}

	local CATEGORY_ICON = {
		[0] = [[Interface\Icons\Custom_Category_OOC_1]],
		[1] = [[Interface\Icons\Custom_Category_1]],
		[2] = [[Interface\Icons\Custom_Category_2]],
		[3] = [[Interface\Icons\Custom_Category_3]],
		[4] = [[Interface\Icons\Custom_Category_4]],
		[5] = [[Interface\Icons\Custom_Category_5]],
		[6] = [[Interface\Icons\Custom_Category_6]],
		[7] = [[Interface\Icons\Custom_Category_7]],
	}

	function GetCharacterCategoryInfoBySpell(spellID)
		local category = CATEGORY_SPELL_ID[spellID]
		if category then
			local categoryIndex, categoryLevel = unpack(category, 1, 2)
			local icon = CATEGORY_ICON[categoryIndex] or [[Interface\Icons\INV_Misc_QuestionMark]]

			local name
			if categoryIndex == 0 then
				name = string.format(CHARACTER_CATEGORY_OOC, string.rep(CHARACTER_CATEGORY_LEVEL_MARK, categoryLevel))
			else
				name = string.format(CHARACTER_CATEGORY_FORMAT, categoryIndex, string.rep(CHARACTER_CATEGORY_LEVEL_MARK, categoryLevel))
			end

			return categoryIndex, categoryLevel, name, icon
		end
	end
end

do -- GetTextureSize
	local FRAME
	function GetTextureSize(texture)
		if type(texture) ~= "string" then
			error(string.format("bad argument #1 to 'GetTextureSize' (string expected, got %s)", texture ~= nil and type(texture) or "no value"), 2)
		end

		if not FRAME then
			FRAME = CreateFrame("Frame")
			FRAME:Hide()
			FRAME.t = FRAME:CreateTexture()
		end

		local success = FRAME.t:SetTexture(texture)
		if success then
			local width, height = FRAME.t:GetSize()
			FRAME.t:SetTexture(nil)
			return width, height
		end
	end
end