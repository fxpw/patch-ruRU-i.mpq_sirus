local PRIVATE = {
	CHARACTERS_PER_PAGE = 10,
	SELECTED_CHARACTER_INDEX = 0,

	LIST_PLAYEBLE	= {page = 1, numPages = 1, numCharacters = 0, availablePages = 1, numDeathKnights = 0, numBoostedDeathKnights = 0},
	LIST_DELETED	= {page = 1, numPages = 0},
	LIST_QUEUED		= {},

	REALM_CONNECTED = false,

	undeletePrice	= -1,
	newPagePrice	= -1,

	CHARACTER_SERVICE_DATA = {},
	CHARACTER_FACTION_OVERRIDE = {},

	BOOST_MODE = {},

	PENDING_BOOST_DK_CHARACTER_ID = 0,
	PENDING_GHOST_WORKAROUNG = nil,
	PENDING_FIX_CHARACTER_INDEX = nil,
	PENDING_CHARACTER_HARDCORE_PROPOSAL = nil,
	PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLE = nil,
}
PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE

local CHARACTER_DATA_TYPE = {
	UPDATE_TIMESTAMP = 0,
	FLAGS = 1,
	MAIL_COUNT = 2,
	ITEM_LEVEL = 3,
	ZODIAC_SIGN_RACE_ID = 4,
	CHALLENGE_ID = 5,
	CATEGORY_SPELL_ID = 6,
	BOOST_CANCEL_TOTAL_TIMELEFT = 7,
	BOOST_CANCEL_INGAME_TIMELEFT = 8,
}

local CHARACTER_FLAGS = {
	FORCE_CUSTOMIZATION	= 0x01,
	ALLOW_ZODIAC_CHANGE	= 0x02,
	HARDCORE_ENABLED	= 0x04,
	HARDCORE_PROPOSE	= 0x08,
	FORCE_RENAME		= 0x10,
}

CHARACTER_CUSTOMIZE_FLAGS = {
	CUSTOMIZATION		= 0x1,
	CHANGE_FACTION		= 0x10000,
	CHANGE_RACE			= 0x100000,
}

local BOOST_MODE_FLAGS = {
	IN_BOOST_MODE	= 0x1,
	SELECTEBLE		= 0x2,
}

E_PAID_SERVICE = Enum.CreateMirror({
	NONE				= -1,
	RESTORE				= 0,
	CUSTOMIZATION		= 1,
	CHANGE_RACE			= 2,
	CHANGE_FACTION		= 3,
	CHANGE_ZODIAC		= 4,
	BOOST_SERVICE		= 5,
	BOOST_SERVICE_NEW	= 6,
	BOOST_CANCEL		= 7,
})

local PAID_SERVICE_INFO = {
	[E_PAID_SERVICE.RESTORE]			= {text = PAID_CHARACTER_RESTORE_TOOLTIP,	iconAtlas = "Glue-VAS-Restore"},
	[E_PAID_SERVICE.CUSTOMIZATION]		= {text = PAID_CHARACTER_CUSTOMIZE_TOOLTIP,	iconAtlas = "Glue-VAS-AppearanceChange"},
	[E_PAID_SERVICE.CHANGE_RACE]		= {text = PAID_RACE_CHANGE_TOOLTIP,			iconAtlas = "Glue-VAS-RaceChange"},
	[E_PAID_SERVICE.CHANGE_FACTION]		= {text = PAID_FACTION_CHANGE_TOOLTIP,		iconAtlas = "Glue-VAS-FactionChange"},
	[E_PAID_SERVICE.CHANGE_ZODIAC]		= {text = PAID_ZODIAC_CHANGE_TOOLTIP,		iconAtlas = "Glue-VAS-ZodiacChange"},
	[E_PAID_SERVICE.BOOST_CANCEL]		= {text = PAID_BOOST_CANCEL_TOOLTIP,	iconAtlas = "Glue-VAS-BoostCancel", hasTimer = true},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:RegisterEvent("SERVER_SPLIT_NOTICE")
PRIVATE.eventHandler:RegisterEvent("CHARACTER_LIST_UPDATE")
PRIVATE.eventHandler:RegisterEvent("UPDATE_SELECTED_CHARACTER")
PRIVATE.eventHandler:RegisterEvent("OPEN_STATUS_DIALOG")
PRIVATE.eventHandler:RegisterCustomEvent("CHARACTER_CREATED")
PRIVATE.eventHandler:RegisterCustomEvent("CUSTOM_CHARACTER_SELECT_SHOWN")
PRIVATE.eventHandler:RegisterCustomEvent("CONNECTION_REALM_DISCONNECT")

PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "UPDATE_SELECTED_CHARACTER" then
		local index = ...
		PRIVATE.SELECTED_CHARACTER_INDEX = index

		if PRIVATE.PENDING_GHOST_WORKAROUNG then
			PRIVATE.PENDING_GHOST_WORKAROUNG = nil

			GlueFFXModel.ghostBugWorkaround = true
			GlueFFXModel:Hide()
			GlueFFXModel:Show()
			GlueFFXModel.ghostBugWorkaround = nil
		end
	elseif event == "CHARACTER_LIST_UPDATE" then
		if PRIVATE.AWAIT_CHARACTER_LIST_UPDATE then
			PRIVATE.AWAIT_CHARACTER_LIST_UPDATE = nil
			C_CharacterList.RequestCharacterListInfo()
		end
	elseif event == "OPEN_STATUS_DIALOG" then
		local dialogType, dialogText, data = ...
		if dialogText == CHAR_DELETE_IN_PROGRESS and IsConnectedToServer() then
			PRIVATE.AWAIT_CHARACTER_LIST_UPDATE = true
		end
	elseif event == "CONNECTION_REALM_DISCONNECT" then
		PRIVATE.AWAIT_CHARACTER_LIST_UPDATE = nil
		PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL = nil
		PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED = nil
		PRIVATE.PENDING_FIX_CHARACTER_INDEX = nil
	elseif event == "CUSTOM_CHARACTER_SELECT_SHOWN" then
		table.wipe(PRIVATE.CHARACTER_SERVICE_DATA)
		table.wipe(PRIVATE.CHARACTER_FACTION_OVERRIDE)
	elseif event == "CHARACTER_CREATED" then
		PRIVATE.LIST_PLAYEBLE.numCharacters = PRIVATE.LIST_PLAYEBLE.numCharacters + 1
		local listModeChanged = false
		FireCustomClientEvent("CUSTOM_CHARACTER_LIST_UPDATE", listModeChanged)
	elseif event == "SERVER_SPLIT_NOTICE" then
		local clientState, statePending, msg = ...
		local prefix, content = string.split(":", msg, 2)

		if prefix == "SMSG_CHARACTERS_LIST_INFO" then
			local deletedPages, characterPages, undeletePrice, listState, currentPage, newPagePrice, numCharacters,
			availablePages, numDeletedCharacters, numDeathKnights, pendingDeathKnightBoost, numBoostedDeathKnights = string.split(":", content)

			PRIVATE.LIST_PLAYEBLE.numPages = math.min(tonumber(characterPages), 255)
			PRIVATE.LIST_DELETED.numPages = math.min(tonumber(deletedPages), 255)

			PRIVATE.LIST_PLAYEBLE.numCharacters = tonumber(numCharacters) or 0
			PRIVATE.LIST_PLAYEBLE.availablePages = tonumber(availablePages) or 1
			PRIVATE.LIST_PLAYEBLE.numDeathKnights = tonumber(numDeathKnights) or 0
			PRIVATE.LIST_PLAYEBLE.numBoostedDeathKnights = tonumber(numBoostedDeathKnights) or 0

			PRIVATE.LIST_DELETED.numCharacters = tonumber(numDeletedCharacters) or 0

			PRIVATE.undeletePrice = tonumber(undeletePrice) or -1
			PRIVATE.newPagePrice = tonumber(newPagePrice) or -1
			PRIVATE.PENDING_BOOST_DK_CHARACTER_ID = tonumber(pendingDeathKnightBoost) or 0

			if next(PRIVATE.LIST_QUEUED) then
				PRIVATE.LIST_QUEUED.list = nil
				PRIVATE.LIST_QUEUED.page = nil
			end

			local listModeChanged

			if listState == "1" then
				listModeChanged = PRIVATE.LIST_CURRENT ~= PRIVATE.LIST_DELETED
				PRIVATE.LIST_CURRENT = PRIVATE.LIST_DELETED
				PRIVATE.LIST_CURRENT.page = tonumber(currentPage) or 1
			else
				listModeChanged = PRIVATE.LIST_CURRENT ~= PRIVATE.LIST_PLAYEBLE
				PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE
				PRIVATE.LIST_CURRENT.page = tonumber(currentPage) or 1
			end

			PRIVATE.AWAIT_CHARACTER_LIST_PAGE_CHANGE = nil

			-- scroll the list if there are no characters on the current page
			if not PRIVATE.AWAIT_CHARACTER_LIST_UPDATE
			and C_CharacterList.GetNumCharactersOnPage() == 0
			and C_CharacterList.GetNumPlayableCharacters() > 0
			and C_CharacterList.GetCurrentPageIndex() > 1
			then
				C_CharacterList.ScrollListPage(-1)
				return
			end

			GlueDialog:HideDialog("SERVER_WAITING")

			FireCustomClientEvent("SERVICE_PRICE_INFO", PRIVATE.undeletePrice, PRIVATE.newPagePrice)
			FireCustomClientEvent("CUSTOM_CHARACTER_LIST_UPDATE", listModeChanged)
		elseif prefix == "SMSG_CHARACTERS_LIST" then
			-- Fires right after page changed (only for playable list mode)
			if content == "OK" then
			elseif content == "ERROR" then
				GMError("Error while scrolling pages")
			end

			PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE
			C_CharacterList.GetCharacterListUpdate()
		elseif prefix == "SMSG_DELETED_CHARACTERS_LIST" then
			if content == "OK" then
				if next(PRIVATE.LIST_QUEUED) then
					PRIVATE.LIST_CURRENT = PRIVATE.LIST_QUEUED.list
					PRIVATE.LIST_CURRENT.page = PRIVATE.LIST_QUEUED.page
				else
					PRIVATE.LIST_CURRENT = PRIVATE.LIST_DELETED
					PRIVATE.LIST_CURRENT.page = 1
				end

				C_CharacterList.GetCharacterListUpdate()
			end

			PRIVATE.LIST_QUEUED.list = nil
			PRIVATE.LIST_QUEUED.page = nil
		elseif prefix == "ASMSG_CHARACTER_OVERRIDE_TEAM" then
			local characterID, factionID = string.split(":", content)
			characterID = tonumber(characterID) + 1

			PRIVATE.CHARACTER_FACTION_OVERRIDE[characterID] = tonumber(factionID)

			FireCustomClientEvent("CHARACTER_FACTION_UPDATE", characterID)
		elseif prefix == "ASMSG_CHAR_SERVICES" then
			local characterID, flags, mailCount, itemLevel, zodiacSignRaceID, challengeID, categorySpellID, boostCancelTotalTimeLeft, boostCancelIngameTimeLeft = string.split(":", content)
			characterID = tonumber(characterID) + 1
			flags = tonumber(flags) or 0
			mailCount = tonumber(mailCount) or 0
			itemLevel = tonumber(itemLevel) or 0
			zodiacSignRaceID = tonumber(zodiacSignRaceID) or 0
			challengeID = tonumber(challengeID) or 0
			categorySpellID = tonumber(categorySpellID) or 0
			boostCancelTotalTimeLeft = tonumber(boostCancelTotalTimeLeft) or 0
			boostCancelIngameTimeLeft = tonumber(boostCancelIngameTimeLeft) or 0

			if not PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
				PRIVATE.CHARACTER_SERVICE_DATA[characterID] = {}
			end

			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.UPDATE_TIMESTAMP] = time()
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS] = flags
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.MAIL_COUNT] = mailCount
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.ITEM_LEVEL] = itemLevel
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.ZODIAC_SIGN_RACE_ID] = zodiacSignRaceID
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.CHALLENGE_ID] = challengeID
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.CATEGORY_SPELL_ID] = categorySpellID
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.BOOST_CANCEL_TOTAL_TIMELEFT] = boostCancelTotalTimeLeft
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.BOOST_CANCEL_INGAME_TIMELEFT] = boostCancelIngameTimeLeft

			FireCustomClientEvent("CUSTOM_CHARACTER_INFO_UPDATE", characterID)
		elseif prefix == "SMSG_PROPOSE_HARDCORE" then
			local status = tonumber(content)
			if status == 0 then
				GlueDialog:HideDialog("SERVER_WAITING")

				local characterID = PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL
				local serviceData = PRIVATE.CHARACTER_SERVICE_DATA[characterID]

				if serviceData and serviceData[CHARACTER_DATA_TYPE.FLAGS] then
					serviceData[CHARACTER_DATA_TYPE.FLAGS] = bit.band(serviceData[CHARACTER_DATA_TYPE.FLAGS], bit.bnot(CHARACTER_FLAGS.HARDCORE_PROPOSE))

					if PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED then
						serviceData[CHARACTER_DATA_TYPE.FLAGS] = bit.bor(serviceData[CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.HARDCORE_ENABLED)
					else
						serviceData[CHARACTER_DATA_TYPE.FLAGS] = bit.band(serviceData[CHARACTER_DATA_TYPE.FLAGS], bit.bnot(CHARACTER_FLAGS.HARDCORE_ENABLED))
					end
				end

				PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL = nil
				PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED = nil
				FireCustomClientEvent("CUSTOM_CHARACTER_INFO_UPDATE", characterID)
			else
				GlueDialog:HideDialog("SERVER_WAITING")

				local characterID = PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL
				PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL = nil
				PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED = nil

				local characterIndex = C_CharacterList.GetCharacterListIndex(characterID)
				local errorText = string.format("SMSG_PROPOSE_HARDCORE: error #%s for character #%d", status or "NONE", characterIndex)
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			end
		elseif prefix == "SMSG_CHARACTER_FIX" then
			GlueDialog:HideDialog("SERVER_WAITING")

			if content == "OK" then
				if PRIVATE.PENDING_FIX_CHARACTER_INDEX then
					FireCustomClientEvent("CUSTOM_CHARACTER_FIXED", PRIVATE.PENDING_FIX_CHARACTER_INDEX)
				end
			elseif content == "NOT_FOUND" then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_FIX_STATUS_2)
			elseif content == "INVALID_PARAMS" then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_FIX_STATUS_3)
			end

			PRIVATE.PENDING_FIX_CHARACTER_INDEX = nil
		end
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	do -- connection
		local connected = IsConnectedToServer() == 1
		if connected ~= PRIVATE.REALM_CONNECTED then
			PRIVATE.REALM_CONNECTED = connected
			if connected then
				FireCustomClientEvent("CONNECTION_REALM_CONNECT")
			else
				FireCustomClientEvent("CONNECTION_REALM_DISCONNECT")
			end
		end

		local realmName, isPVP, isRP, isDown = GetServerName()
		if realmName ~= PRIVATE.REALM_NAME then
			local oldRealmName = PRIVATE.REALM_NAME
			PRIVATE.REALM_NAME = realmName
			FireCustomClientEvent("CONNECTION_REALM_CHANGED", realmName, oldRealmName)
		end
	end

	self.nextUpdate = (self.nextUpdate or 0.2) - elapsed
	if self.nextUpdate > 0 then
		return
	else
		self.nextUpdate = 0.2 - self.nextUpdate
	end

	for characterID, characterInfo in pairs(PRIVATE.CHARACTER_SERVICE_DATA) do
		PRIVATE.GetBoostCancelTimeLeft(characterID) -- force update time
	end
end)

PRIVATE.FireListUpdate = function(listModeChanged)
	-- Used in fallbacks to update button states
	FireCustomClientEvent("CUSTOM_CHARACTER_LIST_UPDATE", listModeChanged or false)
end

PRIVATE.GetCharacterFactionOverride = function(characterID)
	if PRIVATE.CHARACTER_FACTION_OVERRIDE[characterID] then
		local serverFactionOverrideID = PRIVATE.CHARACTER_FACTION_OVERRIDE[characterID]
		local factionOverrideGroup = SERVER_PLAYER_FACTION_GROUP[serverFactionOverrideID]
		local factionOverrideID = PLAYER_FACTION_GROUP[factionOverrideGroup]
		return factionOverrideID, factionOverrideGroup
	end
end

PRIVATE.GetBoostCancelTimeLeft = function(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		local dataTimestamp = PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.UPDATE_TIMESTAMP]
		if dataTimestamp then
			local totalTimeLeft = PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.BOOST_CANCEL_TOTAL_TIMELEFT]
			if totalTimeLeft and totalTimeLeft > 0 then
				local secondsLeft = math.max(0, totalTimeLeft - (time() - dataTimestamp))
				local ingameTimeLeft = math.max(0, PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.BOOST_CANCEL_INGAME_TIMELEFT])

				if secondsLeft == 0 or ingameTimeLeft == 0 then
					PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.BOOST_CANCEL_TOTAL_TIMELEFT] = 0
					PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.BOOST_CANCEL_INGAME_TIMELEFT] = 0
					FireCustomClientEvent("CUSTOM_CHARACTER_INFO_UPDATE", characterID) -- fire event to remove non-available service
					return 0, 0
				end

				return secondsLeft, ingameTimeLeft
			end
		end
	end
	return 0, 0
end

C_CharacterList = {}

function C_CharacterList.ForceSetPlayableMode(triggerEvent)
	PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE

	if triggerEvent then
		PRIVATE.FireListUpdate(PRIVATE.LIST_CURRENT ~= PRIVATE.LIST_PLAYEBLE)
	end
end

function C_CharacterList.GetCharacterListUpdate()
	PRIVATE.AWAIT_CHARACTER_LIST_UPDATE = true
	GetCharacterListUpdate()
end

function C_CharacterList.RequestCharacterListInfo()
	C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestCharacterListInfo)
end

function C_CharacterList.GetNumCharactersOnPage()
	return GetNumCharacters() or 0
end

function C_CharacterList.GetNumCharactersPerPage()
	return PRIVATE.CHARACTERS_PER_PAGE
end

function C_CharacterList.GetNumPages()
	return PRIVATE.LIST_CURRENT.numPages
end

function C_CharacterList.GetCurrentPageIndex()
	return PRIVATE.LIST_CURRENT.page
end

function C_CharacterList.GetNumPlayableCharacters()
	return PRIVATE.LIST_PLAYEBLE.numCharacters
end

function C_CharacterList.GetNumAvailablePages()
	return PRIVATE.LIST_PLAYEBLE.availablePages
end

function C_CharacterList.GetCharacterIndexByID(id)
	return GetIndexFromCharID(id)
end

function C_CharacterList.GetCharacterIDByIndex(index)
	return GetCharIDFromIndex(index)
end

function C_CharacterList.SaveCharacterOrder(orderTable)
	assert(type(orderTable) == "table")
	C_GluePackets:SendPacket(C_GluePackets.OpCodes.SendCharactersOrderSave, unpack(orderTable))
end

function C_CharacterList.GetSelectedCharacter()
	local characterID = PRIVATE.SELECTED_CHARACTER_INDEX
	local characterIndex = C_CharacterList.GetCharacterIDByIndex(characterID)
	return characterID, characterIndex
end

function C_CharacterList.CanCreateCharacter()
	if IsGMAccount() then
		return true
	end

	if C_CharacterList.IsInPlayableMode() then
		if C_CharacterList.GetNumCharactersOnPage() < C_CharacterList.GetNumCharactersPerPage()
		or math.ceil((PRIVATE.LIST_PLAYEBLE.numCharacters + 1) / C_CharacterList.GetNumCharactersPerPage()) <= C_CharacterList.GetNumAvailablePages()
		then
			return true
		end
	end

	return false
end

function C_CharacterList.CanCreateDeathKnight()
	local deathKnightLimit = PRIVATE.LIST_PLAYEBLE.numDeathKnights - PRIVATE.LIST_PLAYEBLE.numBoostedDeathKnights
	return (deathKnightLimit < PRIVATE.LIST_PLAYEBLE.availablePages and PRIVATE.PENDING_BOOST_DK_CHARACTER_ID == 0) or IsGMAccount()
end

function C_CharacterList.HasPendingBoostDK()
	return PRIVATE.PENDING_BOOST_DK_CHARACTER_ID ~= 0
end

function C_CharacterList.GetPendingBoostDK()
	local characterID, pageIndex

	if PRIVATE.PENDING_BOOST_DK_CHARACTER_ID > 10 then
		pageIndex = math.ceil(PRIVATE.PENDING_BOOST_DK_CHARACTER_ID / C_CharacterList.GetNumCharactersPerPage())
		if pageIndex == C_CharacterList.GetCurrentPageIndex() then
			characterID = PRIVATE.PENDING_BOOST_DK_CHARACTER_ID - (pageIndex - 1) * C_CharacterList.GetNumCharactersPerPage()
		else
			characterID = 0
		end
	else
		pageIndex = 1
		if pageIndex == C_CharacterList.GetCurrentPageIndex() then
			characterID = PRIVATE.PENDING_BOOST_DK_CHARACTER_ID
		else
			characterID = 0
		end
	end

	return PRIVATE.PENDING_BOOST_DK_CHARACTER_ID, characterID, pageIndex
end

function C_CharacterList.IsCharacterPendingBoostDK(characterID)
	if characterID == 0 or PRIVATE.PENDING_BOOST_DK_CHARACTER_ID == 0 then
		return false
	end

	if PRIVATE.PENDING_BOOST_DK_CHARACTER_ID < 10 then
		return characterID == PRIVATE.PENDING_BOOST_DK_CHARACTER_ID
	else
		local pendingCharacterID, pendingCharacterID, pendingCharacterPageIndex = C_CharacterList.GetPendingBoostDK()
		return characterID == pendingCharacterID and pendingCharacterPageIndex == C_CharacterList.GetCurrentPageIndex()
	end
end

function C_CharacterList.GetCharacterListIndex(characterID)
	return (C_CharacterList.GetCurrentPageIndex() - 1) * C_CharacterList.GetNumCharactersPerPage() + characterID
end

function C_CharacterList.DeleteCharacter(characterID)
	if characterID < 1
	or characterID > C_CharacterList.GetNumCharactersOnPage()
	or not C_CharacterList.IsInPlayableMode()
	then
		return
	end

	local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(characterID)
	if ghost and C_CharacterList.GetNumPlayableCharacters() == 1 then
		PRIVATE.PENDING_GHOST_WORKAROUNG = true
	end

	DeleteCharacter(characterID)
end

function C_CharacterList.CanEnterWorld(characterID)
	if PRIVATE.PENDING_BOOST_DK_CHARACTER_ID > 0 then
		return PRIVATE.PENDING_BOOST_DK_CHARACTER_ID ~= C_CharacterList.GetCharacterListIndex(characterID)
	end
	return true
end

function C_CharacterList.EnterWorld(characterID)
	if not characterID then
		characterID = C_CharacterList.GetSelectedCharacter()
	end

	if C_CharacterList.HasCharacterForcedCustomization(characterID)
	or C_CharacterList.HasCharacterHardcoreProposal(characterID)
--	or C_CharacterList.HasCharacterForcedRename(characterID) -- client will prompt dialog after EnterWorld
	then
		return
	end

	if C_CharacterList.CanEnterWorld(characterID) then
		local flag = 0
		local challengeID = 0

		if C_CharacterList.IsHardcoreCharacter(characterID) then
			flag = bit.bor(flag, CLIENT_PLAYER_FLAGS.HARDCORE)
			challengeID = C_CharacterList.GetActiveChallengeID(characterID)
		end

		C_CacheInstance:Set("C_SERVICE_PLAYER_FLAG", flag)
		C_CacheInstance:Set("C_SERVICE_CHALLENGE_ID", challengeID)
		EnterWorld()
	end
end

function C_CharacterList.IsRestoreModeAvailable()
	return PRIVATE.LIST_DELETED.numPages > 0
end

function C_CharacterList.IsInPlayableMode()
	return PRIVATE.LIST_CURRENT == PRIVATE.LIST_PLAYEBLE
end

function C_CharacterList.GetCharacterMailCount(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.MAIL_COUNT] or 0
	end
	return 0
end

function C_CharacterList.GetCharacterItemLevel(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.ITEM_LEVEL] or 0
	end
	return 0
end

function C_CharacterList.GetCharacterFactionOverride(characterID)
	local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(characterID)
	if name then
		return PRIVATE.GetCharacterFactionOverride(characterID)
	end
end

function C_CharacterList.GetCharacterFaction(characterID)
	local name, race, class, level, zone, sex, ghost, PCC, PRC, PFC = GetCharacterInfo(characterID)
	if name then
		local factionInfo = C_CreatureInfo.GetFactionInfo(race)
		local originalFactionID = factionInfo.factionID
		local originalFactionGroup = factionInfo.groupTag

		local factionID, factionGroup = PRIVATE.GetCharacterFactionOverride(characterID)
		if not factionID then
			factionGroup = originalFactionGroup
			factionID = originalFactionID
		end

		return factionID, factionGroup, originalFactionID, originalFactionGroup
	end
end

function C_CharacterList.GetCharacterCustomizationList(characterID)
	if not C_CharacterList.IsInPlayableMode() then
		return {}
	end

	local customizations = {}

	local customizationFlags = CharCustomization_GetFlags(characterID)
	if customizationFlags and customizationFlags ~= 0 then
		if bit.band(customizationFlags, CHARACTER_CUSTOMIZE_FLAGS.CUSTOMIZATION) ~= 0 then
			table.insert(customizations, E_PAID_SERVICE.CUSTOMIZATION)
		end
		if bit.band(customizationFlags, CHARACTER_CUSTOMIZE_FLAGS.CHANGE_RACE) ~= 0 then
			table.insert(customizations, E_PAID_SERVICE.CHANGE_RACE)
		end
		if bit.band(customizationFlags, CHARACTER_CUSTOMIZE_FLAGS.CHANGE_FACTION) ~= 0 then
			table.insert(customizations, E_PAID_SERVICE.CHANGE_FACTION)
		end
	end

	if C_CharacterList.CanCharacterChangeZodiac(characterID) then
		table.insert(customizations, E_PAID_SERVICE.CHANGE_ZODIAC)
	end

	if C_CharacterList.HasBoostCancel(characterID) then
		table.insert(customizations, E_PAID_SERVICE.BOOST_CANCEL)
	end

	return customizations
end

function C_CharacterList.CanCharacterChangeZodiac(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return bit.band(PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.ALLOW_ZODIAC_CHANGE) ~= 0
	end
	return false
end

function C_CharacterList.GetCharacterZodiacRaceID(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		local dbcRaceID = PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.ZODIAC_SIGN_RACE_ID]
		if dbcRaceID then
			return E_CHARACTER_RACES[E_CHARACTER_RACES_DBC[dbcRaceID]]
		end
	end
	return 0
end

function C_CharacterList.GetCharacterCategorySpellID(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		local categorySpellID = PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.CATEGORY_SPELL_ID]
		if categorySpellID ~= 0 then
			return categorySpellID
		end
	end
end

function C_CharacterList.HasCharacterForcedCustomization(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return bit.band(PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.FORCE_CUSTOMIZATION) ~= 0
	end
	return false
end

function C_CharacterList.HasCharacterForcedRename(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return bit.band(PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.FORCE_RENAME) ~= 0
	end
	return false
end

function C_CharacterList.HasCharacterHardcoreProposal(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return bit.band(PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.HARDCORE_PROPOSE) ~= 0
	end
	return false
end

function C_CharacterList.IsHardcoreCharacter(characterID)
	if not characterID then
		characterID = C_CharacterList.GetSelectedCharacter()
	end
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return bit.band(PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.HARDCORE_ENABLED) ~= 0
	end
	return false
end

function C_CharacterList.GetActiveChallengeID(characterID)
	if not characterID then
		characterID = C_CharacterList.GetSelectedCharacter()
	end
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.CHALLENGE_ID]
	end
	return 0
end

function C_CharacterList.IsChallengeActive(characterID, challengeID)
	if type(challengeID) ~= "number" then
		error(string.format("bad argument #1 to 'C_Service.IsChallengeActive' (number expected, got %s)", challengeID ~= nil and type(challengeID) or "no value"), 2)
	end

	if not characterID then
		characterID = C_CharacterList.GetSelectedCharacter()
	end
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.CHALLENGE_ID] ~= challengeID
	end
	return false
end

function C_CharacterList.ScrollListPage(delta)
	if PRIVATE.AWAIT_CHARACTER_LIST_PAGE_CHANGE then
		return
	end

	delta = math.modf(delta)

	if delta > 1 then
		delta = 1
	elseif delta < -1 then
		delta = -1
	elseif delta == 0 then
		PRIVATE.FireListUpdate()
		return
	end

	PRIVATE.LIST_QUEUED.list = PRIVATE.LIST_CURRENT
	PRIVATE.LIST_QUEUED.page = PRIVATE.LIST_CURRENT.page + delta

	GlueDialog:ShowDialog("SERVER_WAITING")

	PRIVATE.AWAIT_CHARACTER_LIST_PAGE_CHANGE = true

	if C_CharacterList.IsInPlayableMode() then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterList, delta > 0 and 2 or 1)
	else
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, delta > 0 and 2 or 1)
	end
end

function C_CharacterList.HasMaxLevelNonHardcoreCharacterOnPage()
	for characterID = 1, C_CharacterList.GetNumCharactersOnPage() do
		local name, race, class, level = GetCharacterInfo(characterID)
		if level >= 80 and not C_CharacterList.IsHardcoreCharacter(characterID) then
			return true
		end
	end
	return false
end

function C_CharacterList.EnterRestoreMode()
	if C_CharacterList.IsInPlayableMode() and PRIVATE.LIST_DELETED.numPages > 0 then
		PRIVATE.LIST_QUEUED.list = PRIVATE.LIST_DELETED
		PRIVATE.LIST_QUEUED.page = 1

		GlueDialog:ShowDialog("SERVER_WAITING")
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, 0)
	else
		PRIVATE.FireListUpdate()
	end
end

function C_CharacterList.ExitRestoreMode()
	if not C_CharacterList.IsInPlayableMode() then
		PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE

		GlueDialog:ShowDialog("SERVER_WAITING")
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.AnnounceCharacterDeletedLeave)

		C_CharacterList.GetCharacterListUpdate()
	else
		PRIVATE.FireListUpdate()
	end
end

function C_CharacterList.IsNewPageServiceAvailable()
	if C_CharacterList.IsInPlayableMode()
	and (C_CharacterServices.GetListPagePrice() >= 0 or (C_CharacterServices.GetListPagePrice() == -1 and C_CharacterList.GetNumAvailablePages() == 1))
	and C_CharacterList.GetCurrentPageIndex() == C_CharacterList.GetNumAvailablePages()
	and C_CharacterList.GetNumCharactersOnPage() == C_CharacterList.GetNumCharactersPerPage()
	then
		return true
	end

	return false
end

function C_CharacterList.SendHardcoreProposalAnswer(characterID, enable)
	if PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL or characterID <= 0 or not C_CharacterList.HasCharacterHardcoreProposal(characterID) then
		return
	end

	local characterIndex = C_CharacterList.GetCharacterIndexByID(characterID)
	PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL = characterID
	PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED = enable

	local onError = function(opcode)
		PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL = nil
		PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED = nil
	end

	GlueDialog:ShowDialog("SERVER_WAITING")
	C_GluePackets:SendPacketEx(C_GluePackets.OpCodes.CharacterHardcoreProposalAnswer, nil, onError, characterIndex, enable and 1 or 0)
end

function C_CharacterList.FixCharacter(characterID)
	if PRIVATE.PENDING_FIX_CHARACTER_INDEX or characterID <= 0 or characterID == select(2, C_CharacterList.GetPendingBoostDK()) then
		return
	end

	local characterIndex = C_CharacterList.GetCharacterIndexByID(characterID)
	PRIVATE.PENDING_FIX_CHARACTER_INDEX = characterID

	local onError = function(opcode)
		PRIVATE.PENDING_FIX_CHARACTER_INDEX = nil
	end

	GlueDialog:ShowDialog("SERVER_WAITING")
	C_GluePackets:SendPacketEx(C_GluePackets.OpCodes.SendCharacterFix, nil, onError, characterIndex)
end

function C_CharacterList.SetCharacterInBoostMode(characterID, inBoostMode, isSelectable)
	local flag = 0
	if inBoostMode then
		flag = flag + BOOST_MODE_FLAGS.IN_BOOST_MODE
	end
	if isSelectable then
		flag = flag + BOOST_MODE_FLAGS.SELECTEBLE
	end

	PRIVATE.BOOST_MODE[characterID] = flag
	FireCustomClientEvent("CHARACTER_LIST_BOOST_MODE_CHANGED", characterID)
end

function C_CharacterList.IsCharacterInBoostMode(characterID)
	local flag = PRIVATE.BOOST_MODE[characterID] or 0
	if flag == 0 then
		return false, false
	end

	local inBoostMode = bit.band(flag, BOOST_MODE_FLAGS.IN_BOOST_MODE) ~= 0
	local isSelectable = bit.band(flag, BOOST_MODE_FLAGS.SELECTEBLE) ~= 0
	return inBoostMode, isSelectable
end

function C_CharacterList.HasBoostCancel(characterID)
	return PRIVATE.GetBoostCancelTimeLeft(characterID) > 0
end

function C_CharacterList.GetBoostCancelTimeLeft(characterID)
	return PRIVATE.GetBoostCancelTimeLeft(characterID)
end

function C_CharacterList.GetPaidServiceInfo(paidServiceID)
	local service = PAID_SERVICE_INFO[paidServiceID]
	if not paidServiceID then
		return
	end
	return service.text, service.iconAtlas, service.hasTimer
end