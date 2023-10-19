--	Filename:	C_ConnectManager.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

---@class C_ConnectManagerMixin : Mixin
C_ConnectManagerMixin = {}

function C_ConnectManagerMixin:OnLoad()
    self:RegisterEventListener()
    self:RegisterHookListener()

    self.realmListStorage = {}
    self.realmListCollect = {}
    self.firstChange = true
end

function C_ConnectManagerMixin:SHOW_SERVER_ALERT(_, serverAlertText)
	local ipList, text = string.match(serverAlertText, ":{([^}]+)}:(.*)")
	local autologinAlert, alert = string.match(text, ":%[(.*)%]:(.*)")

    local s,e = string.find(alert, ".*<br/>")
    alert = string.sub(alert, 1, e + 1)

    if ipList then
        local splitData = C_Split(ipList, ", ")

        for _, ipStorage in pairs(splitData) do
            local realmData = C_Split(ipStorage, "|")

            table.insert(self.realmListStorage, realmData[1])

            table.insert(self.realmListCollect, {
                name = realmData[2],
                ip = realmData[1]
            })
        end

        AccountLoginUI_UpdateServerAlertText(alert.."</body></html>")

        AccountLoginChooseRealmDropDown:Init()
    else
        AccountLoginUI_UpdateServerAlertText(serverAlertText)
    end

	AccountLoginChooseRealmDropDown:SetShown(ipList)

	if AccountLogin:IsShown() then
		if autologinAlert and autologinAlert ~= "" then
			GlueDialog:ShowDialog("OKAY_SERVER_ALERT", autologinAlert)
		else
			AccountLogin_AutoLogin()
		end
	end
end

function C_ConnectManagerMixin:OPEN_STATUS_DIALOG(_, dialogKey)
    if dialogKey == "CONNECTION_HELP_HTML" then
        if not self:GetRealmList() then
			self:RestartGameState(dialogKey)
            return
        end

        if self.firstChange then
            self.firstChange = false
            self:SetRealmList()
        else
            self:RemoveCurrentRealmList()
        end

        StatusDialogClick()
		GlueDialog:HideDialog(dialogKey)
        AccountLogin_Login()
    end
end

function C_ConnectManagerMixin:GetAllRealmList()
    return self.realmListCollect or {}
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

function C_ConnectManagerMixin:RestartGameState(dialogKey)
    StatusDialogClick()
	GlueDialog:HideDialog(dialogKey)

    AccountLoginConnectionErrorFrame:Show()
end

---@class C_ConnectManager : C_ConnectManagerMixin
C_ConnectManager = CreateFromMixins(C_ConnectManagerMixin)
C_ConnectManager:OnLoad()