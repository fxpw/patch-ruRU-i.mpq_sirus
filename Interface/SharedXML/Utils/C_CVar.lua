local error = error
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local tonumber = tonumber
local tostring = tostring
local type = type
local bitband, bitbnot, bitbor, bitlshift = bit.band, bit.bnot, bit.bor, bit.lshift
local strformat, strsplit = string.format, string.split
local tconcat, twipe = table.concat, table.wipe

local ConsoleExec = ConsoleExec
--local FireCustomClientEvent = FireCustomClientEvent
local GetCVar = GetCVar
local IsDevClient = IsDevClient
local IsInterfaceDevClient = IsInterfaceDevClient
local RegisterCVar2 = RegisterCVar2
local SendServerMessage = SendServerMessage
local SetCVar = SetCVar
local geterrorhandler = geterrorhandler
local securecall = securecall

local IN_GLUE_STATE = IsOnGlueScreen()

local CVarFlags = {
	HIDE_IN_FRAME_STATE = 0x0,
	SHOW_IN_FRAME_STATE = 0x1,
	STORE_ACCOUNT_WIDE = 0x10,
	STORE_CHARATER_WIDE = 0x20,
	HIDE_IN_LOGS = 0x40,
}

local MigrationFlag = {
	GLUE_XML = 1,
	FRAME_XML = 2,
}

local EVENT_TRIGGER_CVAR = "readContest"

local PRIVATE = {
	DEBUG = false,
	PRESERVE_OLD = false,

	CALLBACKS_VALIDATION = {},
	CALLBACKS_POST = {},

	TRACKED_CVARS = {
		"autoDismountFlying",
		"dracthyrReturnMortalForm",
		"warmodePvpAssist",
		"blockGroupInvites",
		"blockGuildInvites",
		"autoAcceptGroupInvites",
	},
	CVAR_FORCE_VALUE = {
		showItemLevel = "1",
		projectedTextures = "1",
		previewTalents = "1",
		ffx = "1",
		ffxSpecial = "1",
	},
}

PRIVATE.Init = function()
	if PRIVATE.DEBUG and (IsDevClient() or IsInterfaceDevClient()) then
		SetCVar("cvarMigrationAW", 0)
		if not IN_GLUE_STATE then
			SetCVar("cvarMigrationCW", 0)
		end
		PRIVATE.PRESERVE_OLD = true
	end

	if IN_GLUE_STATE then
		PRIVATE.Upgrade()
	end
end

PRIVATE.PrintDebug = function(...)
	if PRIVATE.DEBUG and IsInterfaceDevClient() then
		printc(...)
	end
end

if IN_GLUE_STATE then
	PRIVATE.Upgrade = function()
		local migrationAW = GetCVarBitfield("cvarMigrationAW", MigrationFlag.GLUE_XML, true)
		if migrationAW then
			return
		end

		local STORAGE_CVAR = "readScanning"
		local DELIMITER = "|"

		local GLUE_CVARS = {
			"VERSION",
			"ENTRY_POINT",
			"REALM_ENTRY_POINT",
			"IGNORE_ADDON_VERSION",
			"AUTO_LOGIN",
			"HELPTIP_BITFIELD",
			"BOOST_ITEM_LEVLS",
		}

		local MIGRATION = {
			ENTRY_POINT = "entryPoint",
			REALM_ENTRY_POINT = "realmProxy",
			IGNORE_ADDON_VERSION = "ignoreAddonVersion",
			AUTO_LOGIN = "accountAutoLogin",
			HELPTIP_BITFIELD = "closedInfoFramesGlue",
			BOOST_ITEM_LEVLS = "boostItemLevels",
		}

		PRIVATE.PrintDebug("MIGRATION START: GLUE")
		local storage = GetCVar(STORAGE_CVAR)
		if storage and storage ~= "" and storage ~= "0" and storage ~= "1" and string.find(storage, DELIMITER, 1, true) then
			local values = {string.split(DELIMITER, storage)}
			local cvars = {}
			for i = 1, #GLUE_CVARS do
				if values[i] and values[i] ~= "" then
					local oldCVarName = GLUE_CVARS[i]
					cvars[oldCVarName] = values[i]
				end
			end

			for oldCVar, value in pairs(cvars) do
				local newCVar = MIGRATION[oldCVar]
				PRIVATE.PrintDebug("MIGRATION CVAR:", oldCVar, newCVar, value)
				if newCVar then
					if value ~= nil then
						PRIVATE.PrintDebug("MIGRATION SET NEW:", newCVar, value)
						SetCVar(newCVar, value)
					end
				end
			end

			if not PRIVATE.PRESERVE_OLD then
				SetCVar(STORAGE_CVAR, 0)
			end
		end
		PRIVATE.PrintDebug("MIGRATION END: GLUE")

		SetCVarBitfield("cvarMigrationAW", MigrationFlag.GLUE_XML, true)
	end
else
	PRIVATE.OLD_CACHE = {
		C_CVAR_STORAGE = C_Cache("C_CVAR_STORAGE"),
		INTERFACE_OPTIONS_CACHE = C_Cache("INTERFACE_OPTIONS_CACHE"),
	}
	PRIVATE.MIGRATION_DATA = {}
	PRIVATE.MIGRATION = {
		C_CVAR_HIDE_HELPTIPS = "hideHelptips",
		C_CVAR_FLASH_CLIENT_ICON = "flashClientIcon",

		C_CVAR_CLOSED_INFO_FRAMES = "closedInfoFrames",
		C_CVAR_CLOSED_INFO_FRAMES_ACCOUNT_WIDE = "closedInfoFramesAccountWide",

		C_CVAR_WHISPER_MODE = "whisperMode",
		C_CVAR_STATUS_TEXT_DISPLAY = "statusTextDisplay",

		C_CVAR_BLOCK_GROUP_INVITES = "blockGroupInvites",
		C_CVAR_BLOCK_GUILD_INVITES = "blockGuildInvites",
		C_CVAR_AUTO_ACCEPT_GROUP_INVITES = "autoAcceptGroupInvites",
		C_CVAR_AUTOJOIN_TO_LFG = "lfgAutoJoinChannel",
		C_CVAR_SHOW_ACHIEVEMENT_TOOLTIP = "showAchievementTooltip",

		C_CVAR_AUCTION_HOUSE_DURATION_DROPDOWN = "auctionHouseDurationDropdown",

		C_CVAR_USE_COMPACT_PARTY_FRAMES = "useCompactPartyFrames",
		C_CVAR_USE_COMPACT_SOLO_FRAMES = "useCompactSoloFrames",
		C_CVAR_HIDE_PARTY_INTERFACE_IN_RAID = "hidePartyFramesInRaid",

		C_CVAR_SET_ACTIVE_CUF_PROFILE = "activeCUFProfile",

		C_CVAR_LAST_TRANSMOG_OUTFIT_ID = "lastTransmogOutfit",

		C_CVAR_WARDROBE_SHOW_COLLECTED = "wardrobeShowCollected",
		C_CVAR_WARDROBE_SHOW_UNCOLLECTED = "wardrobeShowUncollected",
		C_CVAR_WARDROBE_SOURCE_FILTERS = "wardrobeSourceFilters",

		C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS = "mountJournalGeneralFilters",
		C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER = "mountJournalAbilityFilters",
		C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER = "mountJournalSourcesFilter",
		C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER = "mountJournalTravelingMerchantFilter",
		C_CVAR_MOUNT_JOURNAL_FACTION_FILTER = "mountJournalFactionFilter",

		C_CVAR_PET_JOURNAL_TAB = "petJournalTab",
		C_CVAR_PET_JOURNAL_FILTERS = "petJournalFilters",
		C_CVAR_PET_JOURNAL_SOURCE_FILTERS = "petJournalSourceFilters",
		C_CVAR_PET_JOURNAL_TYPE_FILTERS = "petJournalTypeFilters",
		C_CVAR_PET_JOURNAL_EXPANSION_FILTERS = "petJournalExpansionFilters",
		C_CVAR_PET_JOURNAL_SORT = "petJournalSort",

		C_CVAR_TOY_BOX_COLLECTED_FILTERS = "toyBoxCollectedFilters",
		C_CVAR_TOY_BOX_SOURCE_FILTERS = "toyBoxSourceFilters",

		C_CVAR_HEIRLOOM_COLLECTED_FILTERS = "heirloomCollectedFilters",
		C_CVAR_HEIRLOOM_SOURCE_FILTERS = "heirloomSourceFilters",

		C_CVAR_ILLUSION_SHOW_COLLECTED = "illusionShowCollected",
		C_CVAR_ILLUSION_SHOW_UNCOLLECTED = "illusionShowUncollected",
		C_CVAR_ILLUSION_SOURCE_FILTERS = "illusionSourceFilters",

		C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS = "toastMaxDisplayed",
		C_CVAR_SHOW_TOASTS = "toastShowWindow",
		C_CVAR_SHOW_SOCIAL_TOAST = "toastShowSocial",
	--	C_CVAR_SHOW_HEAD_HUNTING_TOAST = "toastShowHeadHunting",
		C_CVAR_SHOW_BATTLE_PASS_TOAST = "toastShowBattlePass",
		C_CVAR_SHOW_AUCTION_HOUSE_TOAST = "toastShowAuctionHouse",
		C_CVAR_SHOW_CALL_OF_ADVENTURE_TOAST = "toastShowCallOfAdventure",
		C_CVAR_SHOW_MISC_TOAST = "toastShowMisc",

		C_CVAR_PLAY_TOAST_SOUND = "toastSoundEnabled",
		C_CVAR_SOCIAL_TOAST_SOUND = "toastSoundSocial",
		C_CVAR_HEAD_HUNTING_TOAST_SOUND = "toastSoundHeadHunting",
		C_CVAR_BATTLE_PASS_TOAST_SOUND = "toastSoundBattlePass",
		C_CVAR_AUCTION_HOUSE_TOAST_SOUND = "toastSoundAuctionHouse",
		C_CVAR_CALL_OF_ADVENTURE_TOAST_SOUND = "toastSoundCallOfAdventure",
		C_CVAR_MISC_TOAST_SOUND = "toastSoundMisc",
		C_CVAR_QUEUE_TOAST_SOUND = "toastSoundQueue",

		C_CVAR_LOSS_OF_CONTROL_SCALE = "lossOfControlScale",

		C_CVAR_ROULETTE_SKIP_ANIMATION = "rouletteSkipAnim",
		C_CVAR_ITEM_UPGRADE_LEFT_ITEM_LIST = "itemUpgradeLeftItems",

		C_CVAR_FL_GUILD_SETTINGS2 = "lfGuildSettings",
		C_CVAR_FL_GUILD_COMMENT = "lfGuildComment",

		C_CVAR_SHOW_HARDCORE_NOTIFICATION = "hardcoreNotification",
		C_CVAR_SHOW_HARDCORE_NOTIFICATION_LEVEL = "hardcoreNotificationLevel",
		C_CVAR_SHOW_HARDCORE_NOTIFICATION_SCALE = "hardcoreNotificationScale",
		C_CVAR_SHOW_HARDCORE_NOTIFICATION_SOUND = "hardcoreNotificationSound",

		C_CVAR_DRACTHYR_RETURN_MORTAL_FORM = "dracthyrReturnMortalForm",
		C_CVAR_WARMODE_PVP_ASSIST_ENABLED = "warmodePvpAssist",
		C_CVAR_LOOT_ALERT_THRESHOLD = "lootAlertThreshold",
	}

	PRIVATE.eventHandler = CreateFrame("Frame")
	PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGIN")
	PRIVATE.eventHandler:RegisterEvent("VARIABLES_LOADED")
	PRIVATE.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
	PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			PRIVATE.SendTrackedCVars()
		elseif event == "PLAYER_ENTERING_WORLD" then
			local isInitialLogin, isReloadingUI = ...
			if isInitialLogin then
				self.isInitialLogin = true
			end
			if isReloadingUI then
				self.isReloadingUI = true
			end
			self.PLAYER_ENTERING_WORLD = true
		elseif event == "VARIABLES_LOADED" then
			self.VARIABLES_LOADED = true

			local success, err = pcall(PRIVATE.EnforceCVars)
			if not success then
				geterrorhandler()(err)
			end
		end

		self:UnregisterEvent(event)

		if self.VARIABLES_LOADED and self.isInitialLogin then
			PRIVATE.Upgrade()
			FireCustomClientEvent("VARIABLES_LOADED_INITIAL")
		end
		if self.VARIABLES_LOADED and self.PLAYER_ENTERING_WORLD then
			PRIVATE.MIGRATION = nil
			PRIVATE.MIGRATION_DATA = nil

			FireCustomClientEvent("VARIABLES_LOADED_INFO", self.isInitialLogin, self.isReloadingUI)

			if not IsInterfaceDevClient() then
				PRIVATE.OLD_CACHE = nil
			end
		end
	end)

	PRIVATE.SendTrackedCVars = function()
		local msg = {}
		for index, cvar in ipairs(PRIVATE.TRACKED_CVARS) do
			msg[index] = strformat("%i:%s", index, tostring(GetCVar(cvar) or 0))
		end

		SendServerMessage("ACMSG_I_S", tconcat(msg, "|"))
	end

	PRIVATE.Upgrade = function()
		local migrationCW = GetCVarBitfield("cvarMigrationCW", MigrationFlag.FRAME_XML)
		if migrationCW then
			return
		end

		local migrationAW = GetCVarBitfield("cvarMigrationAW", MigrationFlag.FRAME_XML)

		local cvarCache = PRIVATE.GetCache("C_CVAR_STORAGE")
		if cvarCache then
			PRIVATE.PrintDebug("MIGRATION START: C_CVAR_STORAGE")
			for oldCVar, newCVar in pairs(PRIVATE.MIGRATION) do
				local value
				PRIVATE.PrintDebug("MIGRATION CVAR:", oldCVar, newCVar)
				if PRIVATE.MIGRATION_DATA[oldCVar] then
					local defaultValue, isGlobal = unpack(PRIVATE.MIGRATION_DATA[oldCVar])
					if not isGlobal
					or (isGlobal and not migrationAW)
					then
						local changed, oldValue = PRIVATE.GetCacheValue(cvarCache, oldCVar, defaultValue, isGlobal)
						if changed then
							value = oldValue
						end
					end

					if not PRIVATE.PRESERVE_OLD then
						PRIVATE.PrintDebug("MIGRATION REM OLD:", oldCVar, value)
						cvarCache:Set(oldCVar, nil)
					end
				end

				if value ~= nil then
					PRIVATE.PrintDebug("MIGRATION SET NEW:", newCVar, value)
					SetCVar(newCVar, value)
					PRIVATE.PrintDebug("MIGRATION CHECK:", newCVar, GetCVar(newCVar))
					FireCustomClientEvent("VARIABLE_MIGRATED", newCVar, value)
				end
			end
			PRIVATE.PrintDebug("MIGRATION END: C_CVAR_STORAGE")
		end

		local interfaceOptionsCache = PRIVATE.GetCache("INTERFACE_OPTIONS_CACHE", true)
		if interfaceOptionsCache then
			local changed, value = PRIVATE.GetCacheValue(interfaceOptionsCache, "LOSS_OF_CONTROL_TOGGLE", 1)
			if changed then
				SetCVar("lossOfControl", value)
				FireCustomClientEvent("VARIABLE_MIGRATED", "lossOfControl", value)
			end
			changed, value = PRIVATE.GetCacheValue(interfaceOptionsCache, "SPELL_OVERLAY_ART", 1)
			if changed then
				value = math.min(1, RoundToSignificantDigits(value, 3))
				SetCVar("spellActivationOverlayOpacity", value)
				FireCustomClientEvent("VARIABLE_MIGRATED", "spellActivationOverlayOpacity", value)
			end
			changed, value = PRIVATE.GetCacheValue(interfaceOptionsCache, "SPELL_OVERLAY_SPELL_HIGHLIGHT", 1)
			if changed then
				value = math.min(1, RoundToSignificantDigits(value, 3))
				SetCVar("spellActivationButtonOpacity", value)
				FireCustomClientEvent("VARIABLE_MIGRATED", "spellActivationOverlayOpacity", value)
			end
		end

		SetCVarBitfield("cvarMigrationAW", MigrationFlag.FRAME_XML, true)
		SetCVarBitfield("cvarMigrationCW", MigrationFlag.FRAME_XML, true)

		if not PRIVATE.PRESERVE_OLD then
			PRIVATE.ClearLoadedCaches()
		end
	end

	PRIVATE.GetCache = function(cacheName, isLocal)
		local cache = PRIVATE.OLD_CACHE[cacheName]
		if not cache then
			cache = C_Cache(cacheName, isLocal)
			PRIVATE.OLD_CACHE[cacheName] = cache
		end
		return cache
	end
	PRIVATE.GetCacheValue = function(cache, varName, defaultValue, isGlobal)
		local changed = false
		local value = cache:Get(varName, nil, 0, isGlobal)
		if value ~= nil and value ~= defaultValue then
			changed = true
		end
		return changed, value
	end
	PRIVATE.ClearLoadedCaches = function()
		for cacheName, cache in pairs(PRIVATE.OLD_CACHE) do
			cache:Clear()

			if _G[cacheName] == cache then
				_G[cacheName] = nil
			end
		end
	end

	PRIVATE.RegisterForMigration = function(name, defaultValue, isGlobal)
		PRIVATE.MIGRATION_DATA[name] = {defaultValue, isGlobal}
	end

	do -- register migration
		PRIVATE.RegisterForMigration("C_CVAR_AUTOJOIN_TO_LFG", "1")
		PRIVATE.RegisterForMigration("C_CVAR_LOSS_OF_CONTROL_SCALE", "1")
		PRIVATE.RegisterForMigration("C_CVAR_WHISPER_MODE", "inline")
		PRIVATE.RegisterForMigration("C_CVAR_STATUS_TEXT_DISPLAY", "NUMERIC")
		PRIVATE.RegisterForMigration("C_CVAR_HIDE_PARTY_INTERFACE_IN_RAID", "1")
		PRIVATE.RegisterForMigration("C_CVAR_USE_COMPACT_PARTY_FRAMES", "0")
		PRIVATE.RegisterForMigration("C_CVAR_USE_COMPACT_SOLO_FRAMES", "0")
		PRIVATE.RegisterForMigration("C_CVAR_SET_ACTIVE_CUF_PROFILE", "0")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_ACHIEVEMENT_TOOLTIP", "0")
		PRIVATE.RegisterForMigration("C_CVAR_AUTO_ACCEPT_GROUP_INVITES", "0")
		PRIVATE.RegisterForMigration("C_CVAR_BLOCK_GROUP_INVITES", "0")
		PRIVATE.RegisterForMigration("C_CVAR_BLOCK_GUILD_INVITES", "0")
		PRIVATE.RegisterForMigration("C_CVAR_AUCTION_HOUSE_DURATION_DROPDOWN", "1")
		PRIVATE.RegisterForMigration("C_CVAR_ROULETTE_SKIP_ANIMATION", 0)
		PRIVATE.RegisterForMigration("C_CVAR_FL_GUILD_SETTINGS2", 0)
		PRIVATE.RegisterForMigration("C_CVAR_FL_GUILD_COMMENT", "")
		PRIVATE.RegisterForMigration("C_CVAR_PET_JOURNAL_TAB", "1", true)
		PRIVATE.RegisterForMigration("C_CVAR_PET_JOURNAL_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_PET_JOURNAL_TYPE_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_PET_JOURNAL_SORT", "1", true)
		PRIVATE.RegisterForMigration("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER", "0", true)

		PRIVATE.RegisterForMigration("C_CVAR_WARDROBE_SHOW_COLLECTED", "1", true)
		PRIVATE.RegisterForMigration("C_CVAR_WARDROBE_SHOW_UNCOLLECTED", "1", true)
		PRIVATE.RegisterForMigration("C_CVAR_WARDROBE_SOURCE_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_LAST_TRANSMOG_OUTFIT_ID", "")

		PRIVATE.RegisterForMigration("C_CVAR_HIDE_HELPTIPS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_CLOSED_INFO_FRAMES", "0")
		PRIVATE.RegisterForMigration("C_CVAR_CLOSED_INFO_FRAMES_ACCOUNT_WIDE", "0", true)

		PRIVATE.RegisterForMigration("C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS", 1)
		PRIVATE.RegisterForMigration("C_CVAR_FLASH_CLIENT_ICON", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_TOASTS", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_SOCIAL_TOAST", "1")
	--	PRIVATE.RegisterForMigration("C_CVAR_SHOW_HEAD_HUNTING_TOAST", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_BATTLE_PASS_TOAST", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_AUCTION_HOUSE_TOAST", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_CALL_OF_ADVENTURE_TOAST", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_MISC_TOAST", "1")

		PRIVATE.RegisterForMigration("C_CVAR_PLAY_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SOCIAL_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_HEAD_HUNTING_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_BATTLE_PASS_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_QUEUE_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_AUCTION_HOUSE_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_CALL_OF_ADVENTURE_TOAST_SOUND", "1")
		PRIVATE.RegisterForMigration("C_CVAR_MISC_TOAST_SOUND", "1")

		PRIVATE.RegisterForMigration("C_CVAR_TOY_BOX_COLLECTED_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_TOY_BOX_SOURCE_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_HEIRLOOM_SOURCE_FILTERS", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_ILLUSION_SHOW_COLLECTED", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_ILLUSION_SHOW_UNCOLLECTED", "0", true)
		PRIVATE.RegisterForMigration("C_CVAR_ILLUSION_SOURCE_FILTERS", "0", true)

	--	PRIVATE.RegisterForMigration("C_CVAR_SHOW_HARDCORE_NOTIFICATION", C_Service.IsHardcoreCharacter() and "2" or "0")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_HARDCORE_NOTIFICATION","0")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_HARDCORE_NOTIFICATION_LEVEL", "2")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_HARDCORE_NOTIFICATION_SCALE", "1")
		PRIVATE.RegisterForMigration("C_CVAR_SHOW_HARDCORE_NOTIFICATION_SOUND", "1")

		PRIVATE.RegisterForMigration("C_CVAR_DRACTHYR_RETURN_MORTAL_FORM", "1")
		PRIVATE.RegisterForMigration("C_CVAR_ITEM_UPGRADE_LEFT_ITEM_LIST", "0")
		PRIVATE.RegisterForMigration("C_CVAR_WARMODE_PVP_ASSIST_ENABLED", "0")
		PRIVATE.RegisterForMigration("C_CVAR_LOOT_ALERT_THRESHOLD", "3")
	end
end

PRIVATE.GetTrackedCvarID = function(cvarName)
	for index, cvar in ipairs(PRIVATE.TRACKED_CVARS) do
		if cvar == cvarName then
			return index
		end
	end
end

PRIVATE.EnforceCVars = function()
	for cvar, forcedValue in pairs(PRIVATE.CVAR_FORCE_VALUE) do
		if GetCVar(cvar) ~= forcedValue then
			SetCVar(cvar, forcedValue)
		end
	end
end

PRIVATE.TriggerCVarEvent = function(scriptCVar, value)
	SetCVar(EVENT_TRIGGER_CVAR, value, scriptCVar)
	SetCVar(EVENT_TRIGGER_CVAR, "0")
end

PRIVATE.RegisterCVar = function(name, defaultValue, flags, callback)
	RegisterCVar2(name, defaultValue, flags)

	PRIVATE.CALLBACKS_VALIDATION[name] = type(callback) == "function" and callback or nil
	PRIVATE.CALLBACKS_POST[name] = type(callback) == "function" and callback or nil
end

PRIVATE.SetCVar = function(cvar, value, raiseEvent)
	if PRIVATE.CVAR_FORCE_VALUE[cvar] ~= nil and PRIVATE.CVAR_FORCE_VALUE[cvar] ~= tostring(value) then
		return
	end

	if not IN_GLUE_STATE then
		local trackedCVarID = PRIVATE.GetTrackedCvarID(cvar)
		if trackedCVarID then
			SendServerMessage("ACMSG_I_S", strformat("%i:%i", trackedCVarID, tonumber(value) or 0))
		end
	end

	if PRIVATE.CALLBACKS_VALIDATION[cvar] then
		local success, res, overrideValue = pcall(PRIVATE.CALLBACKS_VALIDATION[cvar], value)
		if success then
			if res then
				value = overrideValue
			else
				return
			end
		else
			geterrorhandler()(res)
		end
	end

	SetCVar(cvar, value, raiseEvent)

	if PRIVATE.CALLBACKS_POST[cvar] then
		local success, err = pcall(PRIVATE.CALLBACKS_POST[cvar], value)
		if not success then
			geterrorhandler()(err)
		end
	end
end

PRIVATE.StringToBoolean = function(stringToCheck, defaultReturn)
	stringToCheck = string.lower(stringToCheck)
	local firstChar = string.sub(stringToCheck, 1, 1)

	if firstChar == "0" or firstChar == "n" or firstChar == "f" or stringToCheck == "off" or stringToCheck == "disabled" then
		return false
	elseif firstChar == "1" or firstChar == "2" or firstChar == "3" or firstChar == "4" or firstChar == "5" or
			firstChar == "6" or firstChar == "7" or firstChar == "8" or firstChar == "9" or firstChar == "y" or
			firstChar == "t" or stringToCheck == "on" or stringToCheck == "enabled" then
		return true
	end

	return defaultReturn
end

PRIVATE.ValueToBoolean = function(valueToCheck, defaultValue, defaultReturn)
	if type(valueToCheck) == "nil" then
		return false
	elseif type(valueToCheck) == "boolean" then
		return valueToCheck
	elseif type(valueToCheck) == "number" then
		return valueToCheck ~= 0
	elseif type(valueToCheck) == "string" then
		return PRIVATE.StringToBoolean(valueToCheck, defaultReturn)
	else
		return defaultReturn
	end
end

_G.SetCVar = function(cvar, value, raiseEvent)
	securecall(PRIVATE.SetCVar, cvar, value, raiseEvent)
end

function GetCVarBitfield(name, index)
	if type(name) ~= "string" or type(index) ~= "number" then
		error("Usage: local value = GetCVarBitfield(name, index)", 2)
--	elseif index < 1 or index > 32 then
--		error("Index out of range", 2)
	end

	local value = GetCVar(name)
	if value then
		value = tonumber(value) or 0
		return bitband(value, bitlshift(1, index - 1)) ~= 0
	end
end

function SetCVarBitfield(name, index, value, scriptCvar)
	if type(name) ~= "string" or type(index) ~= "number" then
		error("Usage: local value = SetCVarBitfield(name, index)", 2)
--	elseif index < 1 or index > 32 then
--		error("Index out of range", 2)
	end

	local currentValue = tonumber(GetCVar(name)) or 0
	if PRIVATE.ValueToBoolean(value) then
		value = bitbor(currentValue, bitlshift(1, index - 1))
	else
		value = bitband(currentValue, bitbnot(bitlshift(1, index - 1)))
	end

	SetCVar(name, value, scriptCvar)
end

_G.ConsoleExec = function(cmd)
	if type(cmd) ~= "string" then
		error("Usage: ConsoleExec(\"console_command\")", 2)
	end

	ConsoleExec(cmd)

	local cvar, value = strsplit(" ", cmd)
	if cvar and value and PRIVATE.CVAR_FORCE_VALUE[cvar] and PRIVATE.CVAR_FORCE_VALUE[cvar] ~= value then
		SetCVar(cvar, PRIVATE.CVAR_FORCE_VALUE[cvar])
	end
end

PRIVATE.RegisterCVar("cvarMigrationAW", 0, CVarFlags.SHOW_IN_FRAME_STATE)
PRIVATE.RegisterCVar("globalStorageNew", 1, CVarFlags.SHOW_IN_FRAME_STATE)
PRIVATE.RegisterCVar("hideHelptips", 0, CVarFlags.STORE_ACCOUNT_WIDE)
PRIVATE.RegisterCVar("flashClientIcon", 0, CVarFlags.STORE_ACCOUNT_WIDE)

if IN_GLUE_STATE then -- register state cvars
	PRIVATE.RegisterCVar("Sound_EnableGluaMusic", 1, CVarFlags.HIDE_IN_LOGS)
	PRIVATE.RegisterCVar("accountAutoLogin", "", CVarFlags.HIDE_IN_FRAME_STATE)
	PRIVATE.RegisterCVar("entryPoint", "", CVarFlags.HIDE_IN_FRAME_STATE)
	PRIVATE.RegisterCVar("realmProxy", "", CVarFlags.HIDE_IN_FRAME_STATE)
	PRIVATE.RegisterCVar("ignoreAddonVersion", "", CVarFlags.HIDE_IN_LOGS)
	PRIVATE.RegisterCVar("boostItemLevels", "", CVarFlags.HIDE_IN_LOGS)
	PRIVATE.RegisterCVar("closedInfoFramesGlue", "", CVarFlags.HIDE_IN_LOGS)
else
	PRIVATE.RegisterCVar("cvarMigrationCW", 0, CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("latestSplashScreen", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("closedInfoFrames", "", CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("closedInfoFramesAccountWide", "", CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("showCustomTutorials", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("tutorialsFlagged", "", CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("tutorialsFlagged2", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("whisperMode", "inline", CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("statusTextDisplay", "NUMERIC", CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("ActionButtonUseKeyDown", 1, CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("blockGroupInvites", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("blockGuildInvites", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("autoAcceptGroupInvites", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("lfgAutoJoinChannel", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("showAchievementTooltip", 0, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("itemExpirationReminder", 1, CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("auctionHouseDurationDropdown", 1, CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("hidePartyFramesInRaid", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("useCompactPartyFrames", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("useCompactSoloFrames", 0, CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("activeCUFProfile", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("lastTransmogOutfit", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("wardrobeShowCollected", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("wardrobeShowUncollected", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("wardrobeSourceFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""

	PRIVATE.RegisterCVar("mountJournalGeneralFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("mountJournalAbilityFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("mountJournalSourcesFilter", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("mountJournalTravelingMerchantFilter", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("mountJournalFactionFilter", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""

	PRIVATE.RegisterCVar("petJournalTab", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("petJournalFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("petJournalSourceFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("petJournalTypeFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("petJournalExpansionFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("petJournalSort", 1, CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("toyBoxCollectedFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("toyBoxSourceFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""

	PRIVATE.RegisterCVar("heirloomCollectedFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""
	PRIVATE.RegisterCVar("heirloomSourceFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""

	PRIVATE.RegisterCVar("illusionShowCollected", 0, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("illusionShowUncollected", 0, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("illusionSourceFilters", 0, CVarFlags.STORE_ACCOUNT_WIDE) -- ""

	PRIVATE.RegisterCVar("toastMaxDisplayed", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastShowWindow", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastShowSocial", 1, CVarFlags.STORE_ACCOUNT_WIDE)
--	PRIVATE.RegisterCVar("toastShowHeadHunting", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastShowBattlePass", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastShowAuctionHouse", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastShowCallOfAdventure", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastShowMisc", 1, CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("toastSoundEnabled", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundSocial", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundHeadHunting", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundBattlePass", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundAuctionHouse", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundCallOfAdventure", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundMisc", 1, CVarFlags.STORE_ACCOUNT_WIDE)
	PRIVATE.RegisterCVar("toastSoundQueue", 1, CVarFlags.STORE_ACCOUNT_WIDE)

	PRIVATE.RegisterCVar("showBuffFrameAuraCategory", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("showBuffFrameAuraVIP", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("showBuffFrameAuraFaction", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("showBuffFrameAuraZodiac", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("showBuffFrameAuraPremium", 1, CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("objectiveTrackerCollapsedState", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("objectiveTrackerHeight", 600, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("objectiveTrackerTextSize", 12, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("objectiveTrackerBackgroundOpacity", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("trackedBattlePassQuests", "", CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("trackedProfessionRecipes", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("lossOfControl", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("lossOfControlScale", 1, CVarFlags.STORE_CHARATER_WIDE)

--	PRIVATE.RegisterCVar("displaySpellActivationOverlays", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("spellActivationOverlayOpacity", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("spellActivationButtonOpacity", 1, CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("rouletteSkipAnim", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("itemUpgradeLeftItems", 0, CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("lfGuildSettings", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("lfGuildComment", "", CVarFlags.STORE_CHARATER_WIDE)

--	PRIVATE.RegisterCVar("hardcoreNotification", C_Service.IsHardcoreCharacter() and 2 or 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("hardcoreNotification", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("hardcoreNotificationLevel", 2, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("hardcoreNotificationScale", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("hardcoreNotificationSound", 1, CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("lastSeenBrawlID", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("dracthyrReturnMortalForm", 1, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("warmodePvpAssist", 0, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("lootAlertThreshold", 3, CVarFlags.STORE_CHARATER_WIDE)
	PRIVATE.RegisterCVar("customNPETutorials", "", CVarFlags.STORE_CHARATER_WIDE)

	PRIVATE.RegisterCVar("toastPoint", "", CVarFlags.STORE_CHARATER_WIDE)
end

do
	if IsInterfaceDevClient() then
		PRIVATE_CVAR = PRIVATE
	end
	PRIVATE.Init()
end