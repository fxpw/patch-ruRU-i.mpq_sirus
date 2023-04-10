--	Filename:	C_Service.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

enum:E_SERVICE_DATA {
    "IS_GM",
    "REALM_ID",
    "ACCOUNT_ID",
    "REALM_FLAG"
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

        local isGM              = tonumber(serviceData[E_SERVICE_DATA.IS_GM])
        local realmID           = tonumber(serviceData[E_SERVICE_DATA.REALM_ID])
        local accountID         = tonumber(serviceData[E_SERVICE_DATA.ACCOUNT_ID])
        local realmFlag         = tonumber(serviceData[E_SERVICE_DATA.REALM_FLAG])

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
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), C_SERVICE_FLAG_STORE) ~= 0
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
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), C_SERVICE_FLAG_RENEGATE) ~= 0
end

function C_ServiceMixin:IsLockRenegadeFeatures()
    return not self:IsRenegadeRealm()
end

function C_ServiceMixin:IsRefuseXPRateRealm()
    return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), C_SERVICE_FLAG_XP) ~= 0
end

function C_ServiceMixin:IsLockRefuseXPRateFeature()
    return not self:IsRefuseXPRateRealm()
end

function C_ServiceMixin:IsWarModRealm()
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), C_SERVICE_FLAG_WAR_MOD) ~= 0
end

function C_ServiceMixin:IsLockWarModFeature()
	return not self:IsWarModRealm()
end

function C_ServiceMixin:IsStrengthenStatsRealm()
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), C_SERVICE_FLAG_STRENGTHEN_STATS) ~= 0
end

function C_ServiceMixin:IsLockStrengthenStatsFeature()
	return not self:IsStrengthenStatsRealm()
end

function C_ServiceMixin:IsSwitchWarModeRealm()
	return C_CacheInstance:Get("C_SERVICE_REALM_FLAG") and bit.band(C_CacheInstance:Get("C_SERVICE_REALM_FLAG"), C_SERVICE_FLAG_IS_SWITCH_WAR_MODE) ~= 0
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
	if IsGMAccount(true) or IsInterfaceDevClient() then
		geterrorhandler()(err)
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