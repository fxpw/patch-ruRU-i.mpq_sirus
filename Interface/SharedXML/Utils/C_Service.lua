local SERVICE_DATA_INDEXES = {
	IS_GM		= 1,
	REALM_ID	= 2,
	ACCOUNT_ID	= 3,
	REALM_FLAG	= 4,
}

local REALM_FLAGS = {
	RENEGATE			= 0x01,
	XP					= 0x02,
	STORE				= 0x04,
	WAR_MOD				= 0x08,
	STRENGTHEN_STATS	= 0x10,
	SWITCH_WAR_MODE		= 0x20,
	ENABLE_BG_KICK		= 0x40,
}

---@class C_ServiceMixin : Mixin
C_ServiceMixin = {}

function C_ServiceMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()
end

function C_ServiceMixin:SERVER_SPLIT_NOTICE(_, _, _, msg)
    local messageData = C_Split(msg, ":")

    if messageData and messageData[1] == "ASMSG_SERVICE_MSG" then
        local serviceData = C_Split(messageData[2], "|")

        local isGM              = tonumber(serviceData[SERVICE_DATA_INDEXES.IS_GM])
        local realmID           = tonumber(serviceData[SERVICE_DATA_INDEXES.REALM_ID])
        local accountID         = tonumber(serviceData[SERVICE_DATA_INDEXES.ACCOUNT_ID])
        local realmFlag         = tonumber(serviceData[SERVICE_DATA_INDEXES.REALM_FLAG])

        C_CacheInstance:Set("C_SERVICE_IS_GM", isGM ~= 0)
        C_CacheInstance:Set("C_SERVICE_REALM_ID", realmID)
        C_CacheInstance:Set("C_SERVICE_ACCOUNT_ID", accountID)
        C_CacheInstance:Set("C_SERVICE_REALM_FLAG", realmFlag)

        Hook:FireEvent("SERVICE_DATA_RECEIVED", isGM, realmID, self:IsStoreEnabled(), accountID, self:IsRenegadeRealm())
    end
end

---@return boolean isGM
function C_ServiceMixin:IsGM()
    return C_CacheInstance:Get("C_SERVICE_IS_GM") or false
end

---@return boolean isStoreEnabled
function C_ServiceMixin:IsStoreEnabled()
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.STORE) ~= 0
end

---@return number realmID
function C_ServiceMixin:GetRealmID()
    return C_CacheInstance:Get("C_SERVICE_REALM_ID")
end

---@return number accountID
function C_ServiceMixin:GetAccountID()
    return C_CacheInstance:Get("C_SERVICE_ACCOUNT_ID")
end

---@return number realmFlag
function C_ServiceMixin:GetRealmFlag()
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG")
end

function C_ServiceMixin:IsRenegadeRealm()
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.RENEGATE) ~= 0
end

function C_ServiceMixin:IsLockRenegadeFeatures()
    return not self:IsRenegadeRealm()
end

function C_ServiceMixin:IsRefuseXPRateRealm()
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.XP) ~= 0
end

function C_ServiceMixin:IsLockRefuseXPRateFeature()
    return not self:IsRefuseXPRateRealm()
end

function C_ServiceMixin:IsWarModRealm()
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.WAR_MOD) ~= 0
end

function C_ServiceMixin:IsLockWarModFeature()
	return not self:IsWarModRealm()
end

function C_ServiceMixin:IsStrengthenStatsRealm()
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.STRENGTHEN_STATS) ~= 0
end

function C_ServiceMixin:IsLockStrengthenStatsFeature()
	return not self:IsStrengthenStatsRealm()
end

function C_ServiceMixin:IsSwitchWarModeRealm()
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.SWITCH_WAR_MODE) ~= 0
end

function C_ServiceMixin.IsBattlegroundKickEnabled()
	if IsGMAccount() then
		return true
	end
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), REALM_FLAGS.ENABLE_BG_KICK) ~= 0
end

function C_ServiceMixin:IsLockSwitchWarModeFeature()
	return not self:IsSwitchWarModeRealm()
end

function C_ServiceMixin:VARIABLES_LOADED()
    Hook:FireEvent("SERVICE_DATA_RECEIVED", self:IsGM(), self:GetRealmID(), self:IsStoreEnabled(), self:GetAccountID(), self:IsRenegadeRealm())
end

---@class C_Service : C_ServiceMixin
C_Service = CreateFromMixins(C_ServiceMixin)
C_Service:OnLoad()

function IsGMAccount(skipDevOverride)
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
	return C_Service:IsGM()
end

function GMError(err)
	if IsGMAccount(true) or IsInterfaceDevClient(true) then
		geterrorhandler()(strconcat("[GMError] ", err))
	end
end

function GetServerID()
    return C_Service:GetRealmID() or 0
end

function IsStoreEnable()
    return C_Service:IsStoreEnabled() or false
end

function GetAccountID()
    return C_Service:GetAccountID() or 0
end