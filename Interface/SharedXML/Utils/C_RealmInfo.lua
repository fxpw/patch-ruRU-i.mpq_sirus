E_REALM_ID = {
	LEGACY_X10	= 5,
	SCOURGE		= 9,
	FROSTMOURNE	= 16,
	NELTHARION	= 21,
	ALGALON		= 33,
	SIRUS		= 57,
	SOULSEEKER	= 42,
}

Enum.RealmType = {
	PVE = 0,
	PVP = 1,
	FFA = 2,
	WarMode = 3,
}

local REALM_LOGO_DEFAULT = "Custom-Realm-Logo-Sirus"
local REALM_INFO = {
	[E_REALM_ID.LEGACY_X10] = {
		name = "Legacy x10",
		listName = "Legacy x10 - 3.3.5а+",
		desc = REALM_LEGACY_X10_DESCRIPTION,
		type = Enum.RealmType.FFA,
		rates = 10,
		logo = "Custom-Realm-Logo-Sirus-Old",
		legacy = true,
	},
	[E_REALM_ID.NELTHARION] = {
		name = "Neltharion",
		listName = "Legacy x3 - 3.3.5a+",
		desc = REALM_NELTHARION_DESCRIPTION,
		type = Enum.RealmType.PVP,
		rates = 3,
		logo = "Custom-Realm-Logo-Neltharion",
		legacy = true,
	},
	[E_REALM_ID.FROSTMOURNE] = {
		name = "Frostmourne",
		listName = "Frostmourne x1 - 3.3.5a+",
		desc = REALM_FROSTMOURNE_DESCRIPTION,
		type = Enum.RealmType.PVE,
		rates = 1,
		logo = "Custom-Realm-Logo-Scourge",
		legacy = true,
	},
	[E_REALM_ID.SCOURGE] = {
		name = "Scourge",
		listName = "Scourge x2 - 3.3.5a+",
		desc = REALM_SCOURGE_DESCRIPTION,
		type = Enum.RealmType.WarMode,
		rates = 2,
		logo = "Custom-Realm-Logo-Scourge",
	},
	[E_REALM_ID.ALGALON] = {
		name = "Algalon",
		listName = "Algalon x4 - 3.3.5a",
		desc = REALM_ALGALON_DESCRIPTION,
		type = Enum.RealmType.PVP,
		rates = 4,
		logo = "Custom-Realm-Logo-Algalon",
		legacy = true,
	},
	[E_REALM_ID.SIRUS] = {
		name = "Sirus",
		listName = "Sirus x5 - 3.3.5a+",
		desc = REALM_SIRUS_DESCRIPTION,
		type = Enum.RealmType.PVP,
		rates = 5,
		logo = "Custom-Realm-Logo-Sirus",
	},
	[E_REALM_ID.SOULSEEKER] = {
		name = "Soulseeker",
		listName = "Soulseeker x1 - 3.3.5a+",
		desc = REALM_SOULSEEKER_DESCRIPTION,
		type = Enum.RealmType.PVP,
		rates = 1,
		logo = "Custom-Realm-Logo-Soulkepper",
	--	label = REALM_LABEL_NEW,
	},
}

C_RealmInfo = {}

if IsOnGlueScreen() then
	local REALM_NAME_ID = {}

	for id, realmInfo in pairs(REALM_INFO) do
		REALM_NAME_ID[realmInfo.listName] = id
		REALM_NAME_ID[("Proxy %s"):format(realmInfo.listName)] = id
		REALM_NAME_ID[("ProxyEU %s"):format(realmInfo.listName)] = id
	end

	function C_RealmInfo.GetServerIDByName(serverName)
		return REALM_NAME_ID[serverName]
	end

	function C_RealmInfo.GetServerListName(serverID)
		local realm = REALM_INFO[serverID]
		if realm then
			return realm.listName
		end
	end
end

function C_RealmInfo.GetServerLogo(serverID)
	local realm = REALM_INFO[serverID]
	if not realm or serverID == 0 then
		return REALM_LOGO_DEFAULT
	end
	return REALM_INFO[serverID].logo or REALM_LOGO_DEFAULT
end

function C_RealmInfo.GetServerInfo(serverID)
	local realm = REALM_INFO[serverID]
	if not realm then
		return
	end
	return realm.name, realm.desc, realm.rates, realm.type, realm.label, realm.legacy
end

function C_RealmInfo.IsLegacyRealm(serverID)
	local realm = REALM_INFO[serverID]
	if not realm then
		return false
	end
	return realm.legacy == true
end