local PRIVATE = {
	CHARACTERS_PER_PAGE = 10,
	SELECTED_CHARACTER_INDEX = 0,

	LIST_PLAYEBLE	= {page = 1, numPages = 1, numCharacters = 0, availablePages = 1, numDeathKnights = 0, numBoostedDeathKnights = 0},
	LIST_DELETED	= {page = 1, numPages = 0},
	LIST_QUEUED		= {},

	undeletePrice	= -1,
	newPagePrice	= -1,

	CHARACTER_SERVICE_DATA = {},

	PENDING_BOOST_DK_CHARACTER_ID = 0,
	PENDING_CHARACTER_FIX_ID = nil,
	PENDING_CHARACTER_HARDCORE_PROPOSAL = nil,
	PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLE = nil,
}
PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE

local CHARACTER_DATA_TYPE = {
	FLAGS = 0,
	MAIL_COUNT = 1,
	ITEM_LEVEL = 2,
	ZODIAC_SIGN_RACE_ID = 3,
	CHALLENGE_ID = 4,
}

local CHARACTER_FLAGS = {
	FORCE_CUSTOMIZATION	= 0x01,
	ALLOW_ZODIAC_CHANGE	= 0x02,
	HARDCORE_ENABLED	= 0x04,
	HARDCORE_PROPOSE	= 0x08,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("SET_GLUE_SCREEN")
PRIVATE.eventHandler:RegisterEvent("UPDATE_STATUS_DIALOG")
PRIVATE.eventHandler:RegisterEvent("SERVER_SPLIT_NOTICE")
PRIVATE.eventHandler:RegisterEvent("UPDATE_SELECTED_CHARACTER")
PRIVATE.eventHandler:RegisterCustomEvent("CHARACTER_CREATED")
PRIVATE.eventHandler:RegisterCustomEvent("CUSTOM_CHARACTER_SELECT_SHOWN")

PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "UPDATE_SELECTED_CHARACTER" then
		local index = ...
		PRIVATE.SELECTED_CHARACTER_INDEX = index
	elseif event == "CUSTOM_CHARACTER_SELECT_SHOWN" then
		table.wipe(PRIVATE.CHARACTER_SERVICE_DATA)
	elseif event == "CHARACTER_CREATED" then
		PRIVATE.LIST_PLAYEBLE.numCharacters = PRIVATE.LIST_PLAYEBLE.numCharacters + 1
		local listModeChanged = false
		FireCustomClientEvent("CUSTOM_CHARACTER_LIST_UPDATE", listModeChanged)
	elseif event == "SERVER_SPLIT_NOTICE" then
		local clientState, statePanding, msg = ...
		local prefix, content = string.split(":", msg, 2)

		if prefix == "ASMSG_ALLIED_RACES" then
			C_CharacterCreation.SetAlliedRacesData(C_Split(content, ":"))
		elseif prefix == "ASMSG_SERVICE_MSG" then
			C_CharacterCreation.SetAlliedRacesData(nil)
		elseif prefix == "SMSG_CHARACTERS_LIST_INFO" then
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

			FireCustomClientEvent("SERVICE_PRICE_INFO", PRIVATE.undeletePrice, PRIVATE.newPagePrice)
			FireCustomClientEvent("CUSTOM_CHARACTER_LIST_UPDATE", listModeChanged)

			GlueDialog:HideDialog("SERVER_WAITING")
		elseif prefix == "SMSG_CHARACTERS_LIST" then
			-- Fires right after page changed (only for playable list mode)
			if content == "OK" then
			elseif content == "ERROR" then
				GMError("Error while scrolling pages")
			end

			PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE
			GetCharacterListUpdate()
		elseif prefix == "SMSG_DELETED_CHARACTERS_LIST" then
			if content == "OK" then
				if next(PRIVATE.LIST_QUEUED) then
					PRIVATE.LIST_CURRENT = PRIVATE.LIST_QUEUED.list
					PRIVATE.LIST_CURRENT.page = PRIVATE.LIST_QUEUED.page
				else
					PRIVATE.LIST_CURRENT = PRIVATE.LIST_DELETED
					PRIVATE.LIST_CURRENT.page = 1
				end

				GetCharacterListUpdate()
			end

			PRIVATE.LIST_QUEUED.list = nil
			PRIVATE.LIST_QUEUED.page = nil
		elseif prefix == "ASMSG_CHAR_SERVICES" then
			local characterID, flags, mailCount, itemLevel, zodiacSignRaceID, challengeID = string.split(":", content)
			characterID = tonumber(characterID) + 1
			flags = tonumber(flags) or 0
			mailCount = tonumber(mailCount) or 0
			itemLevel = tonumber(itemLevel) or 0
			zodiacSignRaceID = tonumber(zodiacSignRaceID) or 0
			challengeID = tonumber(challengeID) or 0

			if not PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
				PRIVATE.CHARACTER_SERVICE_DATA[characterID] = {}
			end

			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS] = flags
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.MAIL_COUNT] = mailCount
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.ITEM_LEVEL] = itemLevel
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.ZODIAC_SIGN_RACE_ID] = zodiacSignRaceID
			PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.CHALLENGE_ID] = challengeID

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
				if PRIVATE.PENDING_CHARACTER_FIX_ID then
					FireCustomClientEvent("CUSTOM_CHARACTER_FIXED", PRIVATE.PENDING_CHARACTER_FIX_ID)
				end
			elseif content == "NOT_FOUND" then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_FIX_STATUS_2)
			elseif content == "INVALID_PARAMS" then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_FIX_STATUS_3)
			end

			PRIVATE.PENDING_CHARACTER_FIX_ID = nil
		end
	end
end)

PRIVATE.FireListUpdate = function(listModeChanged)
	-- Used in fallbacks to update button states
	FireCustomClientEvent("CUSTOM_CHARACTER_LIST_UPDATE", listModeChanged or false)
end

C_CharacterList = {}

function C_CharacterList.ForceSetPlayableMode(triggerEvent)
	PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE

	if triggerEvent then
		PRIVATE.FireListUpdate(PRIVATE.LIST_CURRENT ~= PRIVATE.LIST_PLAYEBLE)
	end
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

function C_CharacterList.GetNewPagePrice()
	return PRIVATE.newPagePrice
end

function C_CharacterList.GetCharacterIndexByID(index)
	return GetIndexFromCharID(index)
end

function C_CharacterList.GetCharacterIDByIndex(index)
	return GetCharIDFromIndex(index)
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
	or C_CharacterList.HasCharacterForcedCustomization(characterID)
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

function C_CharacterList.HasCharacterForcedCustomization(characterID)
	if PRIVATE.CHARACTER_SERVICE_DATA[characterID] then
		return bit.band(PRIVATE.CHARACTER_SERVICE_DATA[characterID][CHARACTER_DATA_TYPE.FLAGS], CHARACTER_FLAGS.FORCE_CUSTOMIZATION) ~= 0
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
		error(string.format("bad argument #1 to 'C_Service.IsChallengeActive' (table expected, got %s)", challengeID ~= nil and type(challengeID) or "no value"), 2)
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

	if C_CharacterList.IsInPlayableMode() then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterList, delta > 0 and 2 or 1)
	else
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, delta > 0 and 2 or 1)
	end
end

function C_CharacterList.EnterRestoreMode()
	if C_CharacterList.IsInPlayableMode() and PRIVATE.LIST_DELETED.numPages > 0 then
		PRIVATE.LIST_QUEUED.list = PRIVATE.LIST_DELETED
		PRIVATE.LIST_QUEUED.page = 1

		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterDeletedList, 0)
		GlueDialog:ShowDialog("SERVER_WAITING")
	else
		PRIVATE.FireListUpdate()
	end
end

function C_CharacterList.ExitRestoreMode()
	if not C_CharacterList.IsInPlayableMode() then
		PRIVATE.LIST_CURRENT = PRIVATE.LIST_PLAYEBLE

		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.AnnounceCharacterDeletedLeave)
		GlueDialog:ShowDialog("SERVER_WAITING")

		GetCharacterListUpdate()
	else
		PRIVATE.FireListUpdate()
	end
end

function C_CharacterList.IsNewPageServiceAvailable()
	if C_CharacterList.IsInPlayableMode()
	and C_CharacterList.GetNewPagePrice() >= 0
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

	GlueDialog:ShowDialog("SERVER_WAITING")
	PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL = characterID
	PRIVATE.PENDING_CHARACTER_HARDCORE_PROPOSAL_ENABLED = enable
	C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.CharacterHardcoreProposalAnswer, characterID, enable and 1 or 0)
end

function C_CharacterList.FixCharacter(characterID)
	if PRIVATE.PENDING_CHARACTER_FIX_ID or characterID <= 0 or characterID == select(2, C_CharacterList.GetPendingBoostDK()) then
		return
	end

	GlueDialog:ShowDialog("SERVER_WAITING")
	PRIVATE.PENDING_CHARACTER_FIX_ID = characterID
	C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.SendCharacterFix, characterID)
end