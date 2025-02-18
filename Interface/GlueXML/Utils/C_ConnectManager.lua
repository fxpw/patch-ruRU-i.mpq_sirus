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
	local entryIPList, autologinAlert, alertHTML = string.match(serverAlertText, ":{([^}]*)}:%s*:%[(.*)%]:(.*)$")

	table.wipe(self.realmListStorage)
	table.wipe(self.realmListCollect)

	if entryIPList then
		for _, entryStr in ipairs(C_Split(entryIPList, ", ")) do
			local entryIP, entryName = string.split("|", entryStr)
			table.insert(self.realmListStorage, entryIP)
			table.insert(self.realmListCollect, {
				name = entryName,
				ip = entryIP,
			})
		end

		FireCustomClientEvent("SERVER_ALERT_UPDATE", alertHTML)
	else
		FireCustomClientEvent("SERVER_ALERT_UPDATE", serverAlertText)
	end

	FireCustomClientEvent("CONNECTION_LIST_UPDATE")
	FireCustomClientEvent("CONNECTION_AUTOLOGIN_READY", autologinAlert ~= "" and autologinAlert or nil)
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
		FireCustomClientEvent("CONNECTION_AUTOLOGIN_READY")
    end
end

function C_ConnectManagerMixin:GetAllRealmList()
	return self.realmListCollect
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
	FireCustomClientEvent("CONNECTION_ERROR")
end

---@class C_ConnectManager : C_ConnectManagerMixin
C_ConnectManager = CreateFromMixins(C_ConnectManagerMixin)
C_ConnectManager:OnLoad()