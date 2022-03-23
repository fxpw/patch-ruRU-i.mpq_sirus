--	Filename:	C_CVarMixin.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_CVarMixin = {}

function C_CVarMixin:OnLoad()
    self._cache = C_Cache("C_CVAR_STORAGE")
    self._defaultValue = {}
    self._globalValues = {}
end

function C_CVarMixin:SetValue( key, value, raiseEvent )
    self._cache:Set(key, value, 0, self._globalValues[key])

    if raiseEvent then
        for _, frame in pairs({GetFramesRegisteredForEvent("CVAR_UPDATE")}) do
            if frame then
                local onEventFunc = frame:GetScript("OnEvent")

                if onEventFunc then
                    onEventFunc(frame, "CVAR_UPDATE", raiseEvent, value)
                end
            end
        end
    end

    Hook:FireEvent("C_SETTINGS_UPDATE_STORAGE")
end

function C_CVarMixin:GetValue( key, defaultValue )
    return self._cache:Get(key, nil, 0, self._globalValues[key]) or ( defaultValue or self:GetDefaultValue(key) )
end

function C_CVarMixin:RegisterDefaultValue( key, value, global )
    self._defaultValue[key] = value

    if global then
        self._globalValues[key] = true
    end
end

function C_CVarMixin:GetDefaultValue( key )
    return self._defaultValue[key]
end

function C_CVarMixin:GetCVarBitfield(name, index)
	if type(name) == "number" then
		name = tostring(name);
	end
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(name) ~= "string" or type(index) ~= "number" then
		error("Usage: local value = C_CVar:GetCVarBitfield(name, index)", 2);
	end

    if self._defaultValue[name] then
		return bit.band(tonumber(self._cache:Get(name, nil, 0, self._globalValues[name]) or self._defaultValue[key]) or 0, bit.lshift(1, index - 1)) ~= 0;
	end
end

function C_CVarMixin:SetCVarBitfield(name, index, value, scriptCVar)
	if type(name) == "number" then
		name = tostring(name);
	end
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(name) ~= "string" or type(index) ~= "number" or type(value) ~= "boolean" then
		error("Usage: local success = C_CVar:SetCVarBitfield(name, index, value [, scriptCVar]", 2);
	end

	if self._defaultValue[name] then
		if self:GetCVarBitfield(name, index) == value then
			return false;
		end

		if value then
			self._cache:Set(name, bit.bor(tonumber(self._cache:Get(name, nil, 0, self._globalValues[name]) or self._defaultValue[key]) or 0, bit.lshift(1, index - 1)), 0, self._globalValues[name]);
		else
			self._cache:Set(name, bit.band(tonumber(self._cache:Get(name, nil, 0, self._globalValues[name]) or self._defaultValue[key]) or 0, bit.bnot(bit.lshift(1, index - 1))), 0, self._globalValues[name]);
		end

		if scriptCVar then
			local frames = {GetFramesRegisteredForEvent("CVAR_UPDATE")};
			for i = 1, #frames do
				local frame = frames[i];

				local onEventFunc = frame:GetScript("OnEvent");
				if onEventFunc then
					onEventFunc(frame, "CVAR_UPDATE", scriptCVar, value);
				end
			end
		end

		return true;
	end
end

---@class C_CVarMixin
C_CVar = CreateFromMixins(C_CVarMixin)
C_CVar:OnLoad()

-- Регистрация дефолтных значений.
C_CVar:RegisterDefaultValue("C_CVAR_AUTOJOIN_TO_LFG", "1")
C_CVar:RegisterDefaultValue("C_CVAR_SHOW_SOCIAL_TOAST", "1")
C_CVar:RegisterDefaultValue("C_CVAR_WHISPER_MODE", "inline")
C_CVar:RegisterDefaultValue("C_CVAR_STATUS_TEXT_DISPLAY", "NUMERIC")
C_CVar:RegisterDefaultValue("C_CVAR_SHOW_BATTLE_PASS_TOAST", "1")
C_CVar:RegisterDefaultValue("C_CVAR_SHOW_AUCTION_HOUSE_TOAST", "1")
C_CVar:RegisterDefaultValue("C_CVAR_SHOW_ACHIEVEMENT_TOOLTIP", "0")
C_CVar:RegisterDefaultValue("C_CVAR_BLOCK_GUILD_INVITES", "0")
C_CVar:RegisterDefaultValue("C_CVAR_AUCTION_HOUSE_DURATION_DROPDOWN", "1")
C_CVar:RegisterDefaultValue("C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS", 1)
C_CVar:RegisterDefaultValue("C_CVAR_ROULETTE_SKIP_ANIMATION", 0)
C_CVar:RegisterDefaultValue("C_CVAR_FL_GUILD_SETTINGS", 0)
C_CVar:RegisterDefaultValue("C_CVAR_FL_GUILD_COMMENT", "")
C_CVar:RegisterDefaultValue("C_CVAR_PET_JOURNAL_TAB", "1", true)
C_CVar:RegisterDefaultValue("C_CVAR_PET_JOURNAL_FILTERS", "0", true)
C_CVar:RegisterDefaultValue("C_CVAR_PET_JOURNAL_TYPE_FILTERS", "0", true)
C_CVar:RegisterDefaultValue("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", "0", true)
C_CVar:RegisterDefaultValue("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", "0", true)
C_CVar:RegisterDefaultValue("C_CVAR_PET_JOURNAL_SORT", "1", true)

C_CVar:RegisterDefaultValue("C_CVAR_WARDROBE_SHOW_COLLECTED", "1", true)
C_CVar:RegisterDefaultValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED", "1", true)
C_CVar:RegisterDefaultValue("C_CVAR_WARDROBE_SOURCE_FILTERS", "0", true)
C_CVar:RegisterDefaultValue("C_CVAR_LAST_TRANSMOG_OUTFIT_ID", "")

C_CVar:RegisterDefaultValue("C_CVAR_HIDE_HELPTIPS", "0", true)
C_CVar:RegisterDefaultValue("C_CVAR_CLOSED_INFO_FRAMES", "0")
C_CVar:RegisterDefaultValue("C_CVAR_CLOSED_INFO_FRAMES_ACCOUNT_WIDE", "0", true)
--C_CVar:RegisterDefaultValue("C_CVAR_SHOW_HEAD_HUNTING_TOAST", "1")