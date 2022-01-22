--	Filename:	C_FactionManager.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

enum:E_PLAYER_FACTION_CHANGE {
    "ORIGINAL_FACTION_ID",
    "FACTION_ID"
}

C_FactionManagerMixin = {}

function C_FactionManagerMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()

    self.originalFactionID = nil
    self.factionOverride = nil
    self.callbackFunc = {}
end

function C_FactionManagerMixin:SetOriginalFaction( factionID )
    self.originalFactionID = factionID

    if not GetSafeCVar("originalFaction") then
        RegisterCVar("originalFaction", factionID)
    end

    SetSafeCVar("originalFaction", factionID)
end

function C_FactionManagerMixin:GetOriginalFactionCVar()
    local cVarOriginalFaction = GetSafeCVar("originalFaction")

    cVarOriginalFaction = tonumber(cVarOriginalFaction or "-1")

    if cVarOriginalFaction == -1 then
        cVarOriginalFaction = nil
    end

    return cVarOriginalFaction
end

function C_FactionManagerMixin:GetOriginalFaction()
    local cVarOriginalFaction = self:GetOriginalFactionCVar()
    return self.originalFactionID or (cVarOriginalFaction and tonumber(cVarOriginalFaction))
end

---@param factionID number
function C_FactionManagerMixin:SetFactionOverride( factionID )
    self.factionOverride = factionID

    if not GetSafeCVar("factionOverride") then
        RegisterCVar("factionOverride", factionID)
    end

    SetSafeCVar("factionOverride", factionID)

    self:RunFactionOverrideCallback()
end

function C_FactionManagerMixin:PLAYER_ENTERING_WORLD()
    local inInstance, instanceType = IsInInstance()

    if inInstance == 1 and instanceType == "pvp" then
        self.factionOverride = nil
    end
end

function C_FactionManagerMixin:GetFactionOverrideCVar()
    local cVarFactionOverride = GetSafeCVar("factionOverride")

    cVarFactionOverride = tonumber(cVarFactionOverride or "-1")

    if cVarFactionOverride == -1 then
        cVarFactionOverride = nil
    end

    return cVarFactionOverride
end

---@return number factionOverride
function C_FactionManagerMixin:GetFactionOverride()
    local cVarFactionOverride = self:GetFactionOverrideCVar()
    return self.factionOverride or (cVarFactionOverride and tonumber(cVarFactionOverride))
end

---@param func function
---@param isNeedRunning boolean
function C_FactionManagerMixin:RegisterFactionOverrideCallback( func, isNeedRunning, dontRemove )
    if func and isNeedRunning then
        func()
    end

    if not self.factionOverride then
        table.insert(self.callbackFunc, {func = func, dontRemove = dontRemove})
    end
end

function C_FactionManagerMixin:RunFactionOverrideCallback()
    if self.callbackFunc and #self.callbackFunc > 0 then
        for i = #self.callbackFunc, 1, -1 do
            local data = self.callbackFunc[i]

            if data then
                xpcall(function()
                    data.func()

                    if not data.dontRemove then
                        table.remove(self.callbackFunc, i)
                    end
                end, function(err)
                    _ERRORMESSAGE(err)
                end)
            end
        end
    end
end

function C_FactionManagerMixin:ASMSG_PLAYER_FACTION_CHANGE(msg)
    local msgStorage        = C_Split(msg, ",")
    local originalFactionID = PLAYER_FACTION_GROUP[SERVER_PLAYER_FACTION_GROUP[tonumber(msgStorage[E_PLAYER_FACTION_CHANGE.ORIGINAL_FACTION_ID])]]
    local factionID         = PLAYER_FACTION_GROUP[SERVER_PLAYER_FACTION_GROUP[tonumber(msgStorage[E_PLAYER_FACTION_CHANGE.FACTION_ID])]]

    self:SetOriginalFaction(originalFactionID)
    self:SetFactionOverride(factionID)
end

---@class C_FactionManagerMixin
C_FactionManager = CreateFromMixins(C_FactionManagerMixin)
C_FactionManager:OnLoad()
