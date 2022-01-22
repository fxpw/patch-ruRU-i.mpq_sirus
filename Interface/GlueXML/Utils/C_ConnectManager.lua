--	Filename:	C_ConnectManager.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_ConnectManagerMixin = {}

function C_ConnectManagerMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()

    self.realmListStorage = {}
end

function C_ConnectManagerMixin:SHOW_SERVER_ALERT(_, serverAlertText)
    local ipList, alert = string.match(serverAlertText, "%:%{(.*)%}%:(.*)")

    if ipList then
        self.realmListStorage = C_Split(ipList, ", ")

        AccountLoginUI_UpdateServerAlertText(alert..">")
    else
        AccountLoginUI_UpdateServerAlertText(serverAlertText)
    end
end

function C_ConnectManagerMixin:OPEN_STATUS_DIALOG(_, dialogKey)
    if dialogKey == "CONNECTION_HELP_HTML" then
        if not self:GetRealmList() then
            self:RestartGameState()
            return
        else
            self:SetRealmList()
            self:RemoveCurrentRealmList()
        end

        StatusDialogClick()
        GlueDialog:Hide()
        AccountLogin_Login()
    end
end

function C_ConnectManagerMixin:RemoveCurrentRealmList()
    table.remove(self.realmListStorage, 1)
end

function C_ConnectManagerMixin:GetRealmList()
    return self.realmListStorage[1]
end

function C_ConnectManagerMixin:SetRealmList()
    local realmList = self:GetRealmList()

    if realmList then
        SetCVar('realmList', realmList)
    end
end

function C_ConnectManagerMixin:RestartGameState()
    StatusDialogClick()
    GlueDialog:Hide()

    AccountLoginConnectionErrorFrame:Show()
end

---@class C_ConnectManagerMixin
C_ConnectManager = CreateFromMixins(C_ConnectManagerMixin)
C_ConnectManager:OnLoad()