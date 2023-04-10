local PRIVATE = {
	ACTIVE				= false,
	BOOST_SERVICE_MAX_LEVEL = 80,

	BALANCE				= -1,
	BOOST_STATUS		= -1,
	BOOST_PRICE			= -1,
	BOOST_PRICE_BASE	= -1,
	BOOST_PERSONAL_SALE	= false,
	BOOST_SECONDS		= -1,
	BOOST_EXPIRE_AT		= -1,

	CHAR_RESTORE_PRICE	= -1,
	CHAR_LISTPAGE_PRICE	= -1,

	PENDING_BOOST_CHARACTER_INDEX = nil,
}

Enum.CharacterServices = {}

Enum.CharacterServices.Mode = {
	Boost			= 1,
	CharRestore		= 2,
	CharListPage	= 3,
}

Enum.CharacterServices.BoostServiceStatus = {
	Disabled	= -1,
	Available	= 0,
	Purchased	= 1,
}

local SERVICE_RESULT_STATUS = {
	SUCCESS					= 0,
	NOT_ENOUGH_MONEY		= 1,
	ALREADY_LEVEL_80		= 2,
	WRONG_PROFESSION		= 3,
	WRONG_SPECIALIZATION	= 4,
	WRONG_FACTION			= 5,
	NOT_AVAILABLE			= 6,
	ALREADY_BUYED			= 7,
	CHARACTER_NOT_FOUND		= 8,
	ALREADY_BOOSTED			= 9,
	UNCONFIRMED_ACCOUNT		= 11,
	SERVICE_DISABLED		= 12,
}

local SERVICE_RESTORE_STATUS = {
	SUCCESS					= "OK",
	ANOTHER_OPERATION		= 1,
	INVALID_PARAMS			= 2,
	MAX_CHARACTERS_REACHED	= 3,
	CHARACTER_NOT_FOUND		= 4,
	NOT_ENOUGH_BONUSES		= 5,
	UNIQUE_CLASS_LIMIT		= 6,
	IS_SUSPECT				= 7,
	WRONG_INDEX				= 8,
	CHARACTER_LIMIT			= 9,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("SERVER_SPLIT_NOTICE")
PRIVATE.eventHandler:RegisterCustomEvent("SERVICE_PRICE_INFO")
PRIVATE.eventHandler:RegisterCustomEvent("CHARACTER_CREATED")
PRIVATE.eventHandler:RegisterCustomEvent("CHARACTER_LIST_UPDATE_DONE")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "SERVICE_PRICE_INFO" then
		local characterRestorePrice, listPagePrice = ...

		PRIVATE.CHAR_RESTORE_PRICE = characterRestorePrice
		PRIVATE.CHAR_LISTPAGE_PRICE = listPagePrice

	elseif event == "CHARACTER_LIST_UPDATE_DONE" then
		if PRIVATE.PENDING_BOOST_CHARACTER_INDEX then
			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_OPEN", PRIVATE.PENDING_BOOST_CHARACTER_INDEX)
			PRIVATE.PENDING_BOOST_CHARACTER_INDEX = nil
		end
	elseif event == "CHARACTER_CREATED" then
		local characterIndex, characterListIndex, isBoostedCreation, characterName = ...
		if isBoostedCreation then
			PRIVATE.PENDING_BOOST_CHARACTER_INDEX = characterIndex
		end
	elseif event == "SERVER_SPLIT_NOTICE" then
		local clientState, statePanding, msg = ...
		local prefix, content = string.split(":", msg, 2)

		if prefix == "SMSG_BOOST_STATUS" then
			local status, boostPrice, balance, haveDiscount, newPrice, isPersonalSale, seconds, expireAt, isPVP = string.split(":", content)

			status = tonumber(status)
			if not status then
				return
			end

			balance = tonumber(balance)
			local balanceChanged = PRIVATE.BALANCE ~= balance

			PRIVATE.ACTIVE					= true
			PRIVATE.BALANCE					= balance
			PRIVATE.BOOST_STATUS			= status
			PRIVATE.BOOST_PRICE_BASE		= tonumber(boostPrice)
			PRIVATE.BOOST_PRICE				= tonumber(haveDiscount) == 1 and tonumber(newPrice) or PRIVATE.BOOST_PRICE_BASE
			PRIVATE.BOOST_PERSONAL_SALE		= tonumber(isPersonalSale) == 1
			PRIVATE.BOOST_SECONDS			= tonumber(seconds)
			PRIVATE.BOOST_EXPIRE_AT			= tonumber(expireAt)
			PRIVATE.BOOST_IS_PVP			= tonumber(isPVP) == 1

			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_STATUS_UPDATE", PRIVATE.BOOST_STATUS)

			if balanceChanged and balance then
				FireCustomClientEvent("ACCOUNT_BALANCE_UPDATE", balance)
			end
		elseif prefix == "SMSG_BUY_BOOST_RESULT" then
			local status = string.split(":", content, 1)

			status = tonumber(status)
			if not status then
				return
			end

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostStatus)
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_SERVICES_BUY_BOOST_RESULT)
			elseif status == SERVICE_RESULT_STATUS.NOT_ENOUGH_MONEY then
				GlueDialog:ShowDialog("CHARACTER_SERVICES_NOT_ENOUGH_MONEY", NOT_ENOUGH_BONUSES_TO_BUY_A_CHARACTER_BOOST)
			elseif status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST BUY ERROR: %d", status)
				if errorText then
					GlueDialog:ShowDialog("OKAY_VOID", errorText)
				end
			end

			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_PURCHASE_STATUS", status == SERVICE_RESULT_STATUS.SUCCESS)
		elseif prefix == "SMG_FINISH_BOOST_RESULT" then
			local status = string.split(":", content, 1)

			status = tonumber(status)
			if not status then
				return
			end

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				GetCharacterListUpdate()
			elseif status == SERVICE_RESULT_STATUS.NOT_AVAILABLE or status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status == SERVICE_RESULT_STATUS.SERVICE_DISABLED then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_BOOST_DISABLE_REALM)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST FINISH ERROR: %d", status)
				if errorText then
					GlueDialog:ShowDialog("OKAY_VOID", errorText)
				end
			end

			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_UTILIZATION_STATUS", status == SERVICE_RESULT_STATUS.SUCCESS)
		elseif prefix == "SMSG_CHARACTERS_LIST_PURCHASE_RESULT" then
			local status = string.split(":", content, 1)

			status = tonumber(status)
			if not status then
				return
			end

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				GlueDialog:ShowDialog("SERVER_WAITING")
				C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestCharacterListInfo)
			elseif status == SERVICE_RESULT_STATUS.NOT_ENOUGH_MONEY then
				GlueDialog:ShowDialog("CHARACTER_SERVICES_NOT_ENOUGH_MONEY", CHARACTER_SERVICES_NOT_ENOUGH_MONEY)
			elseif status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status == SERVICE_RESULT_STATUS.SERVICE_DISABLED then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_SERVICES_DISABLED)
			else
				GlueDialog:ShowDialog("OKAY_VOID", string.format("LIST PAGE PURCHASE ERROR: %d", status))
			end
		elseif prefix == "SMSG_DELETED_CHARACTER_RESTORE" then
			local status, isRename = strsplit(":", content)

			if status == SERVICE_RESTORE_STATUS.SUCCESS then
				GetCharacterListUpdate()
				CharacterSelect.UndeleteCharacterAlert = isRename ~= nil and 1 or 2
			else
				local errorIndex = SERVICE_RESTORE_STATUS[status]
				if errorIndex then
					local errorText = _G[string.format("CHARACTER_UNDELETE_STATUS_%i", errorIndex)]
					if errorIndex == SERVICE_RESTORE_STATUS.NOT_ENOUGH_BONUSES then
						GlueDialog:ShowDialog("OKAY_HTML", errorText)
					else
						GlueDialog:ShowDialog("OKAY_VOID", errorText)
					end
				else
					GlueDialog:ShowDialog("OKAY_VOID", string.format("SERVICE CHARACTER RESTORE ERROR: %s", status))
				end
			end
		end
	end
end)

PRIVATE.IsBoostServiceAvailable = function()
	if not PRIVATE.ACTIVE then
		return false
	end
	if PRIVATE.BOOST_STATUS == Enum.CharacterServices.BoostServiceStatus.Available and (not PRIVATE.BALANCE or not PRIVATE.BOOST_PRICE_BASE) then
		return false
	end
	return true
end

PRIVATE.GetSuggestedBonusAmount = function(price)
	local value = price - PRIVATE.BALANCE

	if value < 10 then
		value = 10
	elseif value > 50 and value < 60 then
		value = 60
	elseif value > 100 and value < 120 then
		value = 120
	end

	return value
end

PRIVATE.OpenBonusPurchaseWebPage = function(mode)
	local price

	if mode == Enum.CharacterServices.Mode.Boost then
		price = PRIVATE.BOOST_PRICE
	elseif mode == Enum.CharacterServices.Mode.CharRestore then
		price = PRIVATE.CHAR_RESTORE_PRICE
	elseif mode == Enum.CharacterServices.Mode.CharListPage then
		price = PRIVATE.CHAR_LISTPAGE_PRICE
	end

	assert(price and price > 0)

	local value = PRIVATE.GetSuggestedBonusAmount(price)
	LaunchURL(string.format("https://sirus.su/pay?bonuses=%u", value))
end

C_CharacterServices = {}

function C_CharacterServices.RequestServiceInfo(throttled)
	if throttled then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestBoostStatus)
	else
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostStatus)
	end
end

function C_CharacterServices.GetAccountName()
	if not PRIVATE.ACTIVE then return end
	return GetCVar("accountName")
end

function C_CharacterServices.GetBalance()
	if not PRIVATE.ACTIVE then return end
	return PRIVATE.BALANCE
end

function C_CharacterServices.GetBoostStatus()
	if not PRIVATE.IsBoostServiceAvailable() then
		return Enum.CharacterServices.BoostServiceStatus.Disabled
	end
	return PRIVATE.BOOST_STATUS
end

function C_CharacterServices.IsBoostAvailableForLevel(characterLevel)
	return characterLevel < PRIVATE.BOOST_SERVICE_MAX_LEVEL and C_CharacterServices.GetBoostStatus() ~= Enum.CharacterServices.BoostServiceStatus.Disabled
end

function C_CharacterServices.IsBoostHasPVPEquipment()
	if not PRIVATE.IsBoostServiceAvailable() then return end
	return PRIVATE.BOOST_IS_PVP
end

function C_CharacterServices.IsBoostPersonal()
	if not PRIVATE.IsBoostServiceAvailable() then return end
	return PRIVATE.BOOST_PERSONAL_SALE
end

function C_CharacterServices.GetBoostPrice()
	if not PRIVATE.IsBoostServiceAvailable() then return end
	local price = PRIVATE.BOOST_PRICE or -1
	local priceOriginal = PRIVATE.BOOST_PRICE_BASE or -1

	local discount
	if price ~= priceOriginal then
		discount = math.floor((1 - (price / priceOriginal)) * 100)
	end

	return price, priceOriginal, discount or 0
end

function C_CharacterServices.GetBoostTimeleft()
	if not PRIVATE.IsBoostServiceAvailable() then return end
	return PRIVATE.BOOST_SECONDS or -1, PRIVATE.BOOST_EXPIRE_AT or -1
end

function C_CharacterServices.GetCharacterRestorePrice()
	if not PRIVATE.ACTIVE then return end
	return PRIVATE.CHAR_RESTORE_PRICE or - 1
end

function C_CharacterServices.GetListPagePrice()
	if not PRIVATE.ACTIVE then return end
	return PRIVATE.CHAR_LISTPAGE_PRICE or - 1
end

function C_CharacterServices.IsNewPageServiceAvailable()
	return C_CharacterList.IsNewPageServiceAvailable()
end

function C_CharacterServices.OpenBonusPurchaseWebPage(mode)
	if not PRIVATE.ACTIVE then return end
	PRIVATE.OpenBonusPurchaseWebPage(mode)
end

function C_CharacterServices.PurchaseBoost()
	if not PRIVATE.ACTIVE then return end

	if PRIVATE.BALANCE >= PRIVATE.BOOST_PRICE or IsGMAccount(true) then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestBoostBuy)
		GlueDialog:ShowDialog("SERVER_WAITING")
	else
		PRIVATE.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end
end

function C_CharacterServices.PurchaseRestoreCharacter(characterIndex)
	if not PRIVATE.ACTIVE then return end

	if PRIVATE.BALANCE >= PRIVATE.CHAR_RESTORE_PRICE or IsGMAccount(true) then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.SendCharacterDeletedRestore, characterIndex)
		GlueDialog:ShowDialog("SERVER_WAITING")
	else
		PRIVATE.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.CharRestore)
	end
end

function C_CharacterServices.PurchaseCharacterListPage()
	if not PRIVATE.ACTIVE then return end

	if PRIVATE.BALANCE >= PRIVATE.CHAR_LISTPAGE_PRICE or IsGMAccount(true) then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestNewPagePurchase)
		GlueDialog:ShowDialog("SERVER_WAITING")
	else
		PRIVATE.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end
end

function C_CharacterServices.BoostCharacter(characterIndex, mainProfessionIndex, secondProfessionIndex, specIndex, pvpSpecIndex, factionIndex)
	C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostCharacter, characterIndex, secondProfessionIndex, mainProfessionIndex, specIndex, pvpSpecIndex, factionIndex)
	GlueDialog:ShowDialog("SERVER_WAITING")
end