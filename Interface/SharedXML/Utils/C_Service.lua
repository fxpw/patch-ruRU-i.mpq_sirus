local bitband, bitbnot = bit.band, bit.bnot
local tonumber = tonumber
local strconcat, strsplit = strconcat, string.split

local C_CacheInstance = C_CacheInstance
local FireCustomClientEvent = FireCustomClientEvent
local IsInterfaceDevClient = IsInterfaceDevClient
local IsOnGlueScreen = IsOnGlueScreen
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitName = UnitName

local ERROR_MESSAGE_GM_ON = ERROR_MESSAGE_GM_ON
local ERROR_MESSAGE_GM_OFF = ERROR_MESSAGE_GM_OFF

local REALM_FLAGS = {
	RENEGATE			= 0x01,
	ENABLE_X1			= 0x02,
	STORE				= 0x04,
	WARMODE				= 0x08,
	BONUS_STATS			= 0x10,
	WARMODE_SWITCH		= 0x20,
	BG_KICK				= 0x40,
	HARDCORE			= 0x80,
}

local CLIENT_PLAYER_FLAGS = {
	HARDCORE			= 0x01,
}

local ENABLE_X1_RATE_STATUS = {
	SUCCESS						= 0,
	FEATURE_DISABLED_ON_REALM	= 1,
	LEVEL_CLASS_OUT_OF_LIMIT	= 2,
	ALREADY_ENABLED				= 3,
}

local CHALLENGE_DISABLE_REASON = {
	COMPLETE			= 0,
	RESTORE				= 1,
	DEACTIVATED			= 2,
	FAILED_DEATH		= 3,
}
Enum.HardcoreDeathReason = CopyTable(CHALLENGE_DISABLE_REASON)

local PRIVATE = {}
PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()

if IsOnGlueScreen() then
	_G.CLIENT_PLAYER_FLAGS = CLIENT_PLAYER_FLAGS
	PRIVATE.eventHandler:RegisterEvent("SERVER_SPLIT_NOTICE")
else
	PRIVATE.eventHandler:RegisterEvent("VARIABLES_LOADED")
	PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")
	PRIVATE.eventHandler:RegisterEvent("UI_ERROR_MESSAGE")
	PRIVATE.eventHandler:RegisterEvent("PLAYER_DEAD")
	PRIVATE.eventHandler:RegisterEvent("PLAYER_LEVEL_UP")
end

PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "SERVER_SPLIT_NOTICE" then
		local clientState, statePanding, msg = ...
		local prefix, content = strsplit(":", msg, 2)

		if prefix == "ASMSG_SERVICE_MSG" then
			local isGM, realmID, accountID, realmFlag, realmStage = strsplit("|", content)

			C_CacheInstance:Set("C_SERVICE_IS_GM", tonumber(isGM) ~= 0)
			C_CacheInstance:Set("C_SERVICE_REALM_ID", tonumber(realmID))
			C_CacheInstance:Set("C_SERVICE_ACCOUNT_ID", tonumber(accountID))
			C_CacheInstance:Set("C_SERVICE_REALM_FLAG", tonumber(realmFlag))
			C_CacheInstance:Set("C_SERVICE_REALM_STAGE", tonumber(realmStage))
			C_CacheInstance:Set("C_SERVICE_IS_GM_MODE", nil)

			FireCustomClientEvent("SERVICE_DATA_UPDATE")
		end
	elseif event == "CHAT_MSG_ADDON" then
		local prefix, msg, distribution, sender = ...
		if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
			return
		end

		if prefix == "ASMSG_ENABLE_X1_RATE" then
			local status = tonumber(msg)
			if status == ENABLE_X1_RATE_STATUS.SUCCESS
			or (status == ENABLE_X1_RATE_STATUS.ALREADY_ENABLED and not C_CacheInstance:Get("ASMSG_ENABLE_X1_RATE"))
			then
				C_CacheInstance:Set("ASMSG_ENABLE_X1_RATE", true)
				FireCustomClientEvent("SERVICE_RATE_UPDATE")
			end
		elseif prefix == "ASMSG_HARDCORE_CHALLENGE_ACTIVATE"
		or prefix == "ASMSG_REMOVE_HARDCORE"
		then
			local status, challengeID, isRestore = string.split(":", msg)
			status = tonumber(status)
			challengeID = tonumber(challengeID)

			if status == 0 then
				if challengeID then
					if prefix == "ASMSG_HARDCORE_CHALLENGE_ACTIVATE" then
						PRIVATE.ChallengeModeEnable(challengeID)
					elseif isRestore == "1" then
						PRIVATE.ChallengeModeDisable(CHALLENGE_DISABLE_REASON.RESTORE)
					else
						PRIVATE.ChallengeModeDisable(CHALLENGE_DISABLE_REASON.DEACTIVATED)
					end
				else
					GMError(string.format("%s: no challenge id", prefix))
				end
			else
				local errorText = status and _G[string.format("HARDCORE_REMOVE_ERROR_TEXT_%s", status)]
				if errorText then
					if IsGMAccount() then
						errorText = string.format("[%s][ERRCODE=%u] %s", prefix, status, errorText)
					end
					UIErrorsFrame:AddMessage(errorText, 1.0, 0.1, 0.1, 1.0)
				else
					GMError(string.format("%s: error code %s", prefix, status or "nil"))
				end
			end
		end
	elseif event == "UI_ERROR_MESSAGE" then
		local msg = ...
		if msg == ERROR_MESSAGE_GM_ON then
			if not C_CacheInstance:Get("C_SERVICE_IS_GM_MODE") then
				C_CacheInstance:Set("C_SERVICE_IS_GM_MODE", true)
				FireCustomClientEvent("SERVICE_STATE_UPDATE", true)
			end
		elseif msg == ERROR_MESSAGE_GM_OFF then
			if C_CacheInstance:Get("C_SERVICE_IS_GM_MODE") then
				C_CacheInstance:Set("C_SERVICE_IS_GM_MODE", nil)
				FireCustomClientEvent("SERVICE_STATE_UPDATE", false)
			end
		end
	elseif event == "PLAYER_DEAD" then
		if PRIVATE.GetPlayerFlag(CLIENT_PLAYER_FLAGS.HARDCORE) ~= 0 then
			PRIVATE.ChallengeModeDisable(CHALLENGE_DISABLE_REASON.FAILED_DEATH)
		end
	elseif event == "PLAYER_LEVEL_UP" then
		local level = ...
		if level == 80 and PRIVATE.GetPlayerFlag(CLIENT_PLAYER_FLAGS.HARDCORE) ~= 0 then
			PRIVATE.ChallengeModeDisable(CHALLENGE_DISABLE_REASON.COMPLETE)
		end
	elseif event == "VARIABLES_LOADED" then
		FireCustomClientEvent("SERVICE_DATA_UPDATE")
	end
end)

PRIVATE.GetRealmFlag = function(flag)
	local realmFlag = C_CacheInstance:Get("C_SERVICE_REALM_FLAG")
	if realmFlag then
		return bitband(realmFlag, flag)
	end
	return 0
end

PRIVATE.GetPlayerFlag = function(flag)
	local playerFlag = C_CacheInstance:Get("C_SERVICE_PLAYER_FLAG")
	if playerFlag then
		return bitband(playerFlag, flag)
	end
	return 0
end

PRIVATE.ChallengeModeEnable = function(challengeID)
	C_CacheInstance:Set("C_SERVICE_CHALLENGE_ID", challengeID)
	FireCustomClientEvent("CUSTOM_CHALLENGE_ACTIVATED", challengeID)
end

PRIVATE.ChallengeModeDisable = function(reason)
	if reason == CHALLENGE_DISABLE_REASON.COMPLETE
	or reason == CHALLENGE_DISABLE_REASON.RESTORE
	then
		local playerFlag = C_CacheInstance:Get("C_SERVICE_PLAYER_FLAG")
		if playerFlag then
			C_CacheInstance:Set("C_SERVICE_PLAYER_FLAG", bitband(playerFlag, bitbnot(CLIENT_PLAYER_FLAGS.HARDCORE)))
		end
	end

	local challengeID = C_CacheInstance:Get("C_SERVICE_CHALLENGE_ID")
	C_CacheInstance:Set("C_SERVICE_CHALLENGE_ID", 0)
	FireCustomClientEvent("CUSTOM_CHALLENGE_DEACTIVATED", challengeID, reason)
end

PRIVATE.IsGMAccount = function(skipDevOverride)
	if not skipDevOverride then
		if IsOnGlueScreen() then
			if DEV_GLUE_DISABLE_GM then
				return false
			end
		else
			if DEV_GAME_DISABLE_GM then
				return false
			end
		end
	end
	return C_CacheInstance:Get("C_SERVICE_IS_GM") or false
end

PRIVATE.GetAccountID = function()
	return C_CacheInstance:Get("C_SERVICE_ACCOUNT_ID") or 0
end

PRIVATE.GetRealmID = function()
	return C_CacheInstance:Get("C_SERVICE_REALM_ID") or 0
end

PRIVATE.GetRealmStage = function()
	return C_CacheInstance:Get("C_SERVICE_REALM_STAGE") or 0
end

PRIVATE.IsStoreEnabled = function()
	return PRIVATE.GetRealmFlag(REALM_FLAGS.STORE) ~= 0
end

PRIVATE.IsRateX1Enabled = function()
	return C_CacheInstance:Get("ASMSG_ENABLE_X1_RATE") or false
end

PRIVATE.CanChangeExpRate = function()
	return PRIVATE.GetRealmFlag(REALM_FLAGS.ENABLE_X1) ~= 0
end

PRIVATE.CanEnableRateX1 = function()
	if not PRIVATE.CanChangeExpRate()
	or PRIVATE.IsRateX1Enabled()
	or (C_Service.IsHardcoreCharacter() and not C_Service.HasActiveChallenges())
	then
		return false
	end

	local level = UnitLevel("player")
	local _, class = UnitClass("player")
	if class == "DEATHKNIGHT" then
		return level <= 58
	else
		return level < 10
	end
end

C_Service = {}

function C_Service.GetAccountID()
	return PRIVATE.GetAccountID()
end

function C_Service.GetRealmID()
	return PRIVATE.GetRealmID()
end

function C_Service.GetRealmStage()
	return PRIVATE.GetRealmStage()
end

function C_Service.IsStoreEnabled()
	return PRIVATE.IsStoreEnabled()
end

function C_Service.IsRenegadeRealm()
	return PRIVATE.GetRealmFlag(REALM_FLAGS.RENEGATE) ~= 0
end

function C_Service.IsStrengthenStatsRealm()
	return PRIVATE.GetRealmFlag(REALM_FLAGS.BONUS_STATS) ~= 0
end

function C_Service.IsWarModRealm()
	return PRIVATE.GetRealmFlag(REALM_FLAGS.WARMODE) ~= 0
end

function C_Service.CanChangeWarMode()
	if PRIVATE.GetRealmFlag(REALM_FLAGS.WARMODE) ~= 0 then
		return PRIVATE.GetRealmFlag(REALM_FLAGS.WARMODE_SWITCH) ~= 0
	end
	return false
end

function C_Service.IsBattlegroundKickEnabled()
	if IsGMAccount() then
		return true
	end
	return PRIVATE.GetRealmFlag(REALM_FLAGS.BG_KICK) ~= 0
end

--[[
function C_Service.CanChangeExpRate()
	return PRIVATE.CanChangeExpRate()
end

function C_Service.IsRateX1Enabled()
	return PRIVATE.IsRateX1Enabled()
end
--]]

function C_Service.CanEnableRateX1()
	return PRIVATE.CanEnableRateX1()
end

function C_Service.RequestRateX1()
	if PRIVATE.CanEnableRateX1() then
		SendServerMessage("ACMSG_ENABLE_X1_RATE")
	end
end

function C_Service.IsHardcoreEnabledOnRealm()
	return PRIVATE.GetRealmFlag(REALM_FLAGS.HARDCORE) ~= 0
end

function C_Service.IsHardcoreCharacter()
	if IsOnGlueScreen() then
		return C_CharacterList.IsHardcoreCharacter()
	else
		return PRIVATE.GetPlayerFlag(CLIENT_PLAYER_FLAGS.HARDCORE) ~= 0
	end
end

function C_Service.HasActiveChallenges()
	if IsOnGlueScreen() then
		return C_CharacterList.GetActiveChallengeID() ~= 0
	else
		local challengeID = C_CacheInstance:Get("C_SERVICE_CHALLENGE_ID")
		if challengeID then
			return challengeID ~= 0
		end
		return false
	end
end

function C_Service.IsChallengeActive(challengeID)
	if type(challengeID) ~= "number" then
		error(string.format("bad argument #1 to 'C_Service.IsChallengeActive' (table expected, got %s)", challengeID ~= nil and type(challengeID) or "no value"), 2)
	end

	if IsOnGlueScreen() then
		return C_CharacterList.IsChallengeActive(nil, challengeID)
	else
		return C_CacheInstance:Get("C_SERVICE_CHALLENGE_ID") == challengeID
	end
end

function C_Service.IsGMAccount(skipDevOverride)
	return PRIVATE.IsGMAccount(skipDevOverride)
end

function C_Service.IsInGMMode()
	return PRIVATE.IsGMAccount(true) and C_CacheInstance:Get("C_SERVICE_IS_GM_MODE") or false
end

function GMError(err)
	if PRIVATE.IsGMAccount(true) or IsInterfaceDevClient(true) then
		geterrorhandler()(strconcat("[GMError] ", err))
	end
end

function IsGMAccount(skipDevOverride)
	return PRIVATE.IsGMAccount(skipDevOverride)
end

function GetServerID()
	return PRIVATE.GetRealmID()
end

function GetAccountID()
	return PRIVATE.GetAccountID()
end