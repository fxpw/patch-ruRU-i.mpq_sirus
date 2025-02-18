local PRIVATE = {
	ACTIVE				= false,
	BOOST_MAX_LEVEL		= 80,

	BALANCE					= 0,
	FLAGS					= 0,
	BOOST_STATUS			= -1,
	BOOST_PRICE_BASE		= -1,
	BOOST_PRICE_DISCOUNTED	= -1,
	BOOST_SECONDS			= -1,
	BOOST_EXPIRE_AT			= -1,
	BOOST_SPEC_ITEMS		= {},

	BOOST_REFUND_TIMELEFT = 0,

	CHAR_RESTORE_PRICE	= -1,
	CHAR_LISTPAGE_PRICE	= -1,

	PENDING_BOOST_CHARACTER_INDEX = nil,

	AWAIT_BOOST_ITEMS_NEW_STAGE = nil,
	AWAIT_BOOST_ITEMS_CLASS_ID = nil,
	AWAIT_BOOST_ITEMS_QUEQUE = {},
	AWAIT_BOOST_ITEMS_MSG = {},
}

Enum.CharacterServices = {}

Enum.CharacterServices.Mode = {
	Boost			= 1,
	CharRestore		= 2,
	CharListPage	= 3,
	GearBoost		= 4,
}

Enum.CharacterServices.BoostServiceStatus = {
	Disabled	= -1,
	Available	= 0,
	Purchased	= 1,
}

Enum.CharacterServices.SpecType = {
	PVE = 1,
	PVP = 2,
}

local CHARACTER_SERVICE_FLAG = {
	BOOST_HAS_DISCOUNT		= 0x1,
	BOOST_PERSONAL_SALE		= 0x2,
	BOOST_HAS_PVP_SET		= 0x4,
	BOOST_CANCEL_AVAILABLE	= 0x8,
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
	INCORRECT_PARAMETERS	= 10,
	UNCONFIRMED_ACCOUNT		= 11,
	SERVICE_DISABLED		= 12,

	BOOST_CANCEL_INCORRECT_PARAMETERS		= 13,
	BOOST_CANCEL_NOT_AVAILABLE				= 14,
	BOOST_CANCEL_UNCONFIRMED_ACCOUNT		= 15,
	BOOST_CANCEL_ERR_GUILD_MASTER			= 16,
	BOOST_CANCEL_ERR_ARENA_CAPTAIN			= 17,
	BOOST_CANCEL_BOOST_ALREADY_PURCHASED	= 18,
	BOOST_CANCEL_CHARACTER_NOT_FOUND		= 19,
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
	IS_UNCONFIRMED			= 7,
	WRONG_INDEX				= 8,
	CHARACTER_LIMIT			= 9,
}

local BOOST_REFUND_SECONDS = SECONDS_PER_DAY * 14
local BOOST_REFUND_PENALTY_SECONDS = SECONDS_PER_HOUR * 1
local BOOST_REFUND_PENALTY_PERCENTS = 75

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
		local clientState, statePending, msg = ...
		local prefix, content = string.split(":", msg, 2)

		if prefix == "SMSG_BOOST_STATUS" then
			local status, flags, balance, boostPrice, boostPriceDiscounted, seconds, expireAt,
				refundTimeLeft, refundPriceFull, refundPricePenalty = string.split(":", content)

			status = tonumber(status)
			balance = tonumber(balance) or 0
			flags = tonumber(flags) or 0

			PRIVATE.UPDATE_TIMESTAMP			= time()

			if not status then
				PRIVATE.ACTIVE					= false
				PRIVATE.FLAGS					= 0
				PRIVATE.BALANCE					= balance
				PRIVATE.BOOST_STATUS			= Enum.CharacterServices.BoostServiceStatus.Disabled
				PRIVATE.BOOST_PRICE_BASE		= -1
				PRIVATE.BOOST_PRICE_DISCOUNTED	= -1
				PRIVATE.BOOST_REFUND_TIMELEFT	= 0
				return
			end

			local balanceChanged = PRIVATE.BALANCE ~= balance

			PRIVATE.ACTIVE						= true
			PRIVATE.FLAGS						= flags
			PRIVATE.BALANCE						= balance
			PRIVATE.BOOST_STATUS				= status
			PRIVATE.BOOST_PRICE_BASE			= tonumber(boostPrice) or -1
			PRIVATE.BOOST_PRICE_DISCOUNTED		= tonumber(boostPriceDiscounted) or -1
			PRIVATE.BOOST_SECONDS				= tonumber(seconds) or -1
			PRIVATE.BOOST_EXPIRE_AT				= tonumber(expireAt) or -1
			PRIVATE.BOOST_REFUND_TIMELEFT		= tonumber(refundTimeLeft) or 0
			PRIVATE.BOOST_REFUND_PRICE_FULL		= tonumber(refundPriceFull) or 0
			PRIVATE.BOOST_REFUND_PRICE_PENALTY	= tonumber(refundPricePenalty) or 0

			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_STATUS_UPDATE", PRIVATE.BOOST_STATUS)

			if balanceChanged and balance then
				FireCustomClientEvent("ACCOUNT_BALANCE_UPDATE", balance)
			end
		elseif prefix == "SMSG_BUY_BOOST_RESULT" then
			local status = string.split(":", content, 1)
			status = tonumber(status)

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				C_CharacterServices.RequestBalance()
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_SERVICES_BUY_BOOST_RESULT)
			elseif status == SERVICE_RESULT_STATUS.NOT_ENOUGH_MONEY then
				GlueDialog:ShowDialog("CHARACTER_SERVICES_NOT_ENOUGH_MONEY", NOT_ENOUGH_BONUSES_TO_BUY_A_CHARACTER_BOOST)
			elseif status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST BUY ERROR: %d", status)
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			else
				GlueDialog:ShowDialog("OKAY_VOID", "[ERROR] SMSG_BUY_BOOST_RESULT: no error code")
			end

			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_PURCHASE_STATUS", status == SERVICE_RESULT_STATUS.SUCCESS)
		elseif prefix == "SMG_FINISH_BOOST_RESULT" then
			local status = string.split(":", content, 1)
			status = tonumber(status)

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				C_CharacterList.RequestCharacterListInfo()
				C_CharacterList.GetCharacterListUpdate()
			elseif status == SERVICE_RESULT_STATUS.NOT_AVAILABLE or status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status == SERVICE_RESULT_STATUS.SERVICE_DISABLED then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_BOOST_DISABLE_REALM)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST FINISH ERROR: %d", status)
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			else
				GlueDialog:ShowDialog("OKAY_VOID", "[ERROR] SMG_FINISH_BOOST_RESULT: no error code")
			end

			FireCustomClientEvent("CHARACTER_SERVICES_BOOST_UTILIZATION_STATUS", status == SERVICE_RESULT_STATUS.SUCCESS)
		elseif prefix == "SMSG_CHARACTERS_LIST_PURCHASE_RESULT" then
			local status = string.split(":", content, 1)
			status = tonumber(status)

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				GlueDialog:ShowDialog("SERVER_WAITING")
				C_CharacterList.RequestCharacterListInfo()
				C_CharacterServices.RequestBalance()
			elseif status == SERVICE_RESULT_STATUS.NOT_ENOUGH_MONEY then
				GlueDialog:ShowDialog("CHARACTER_SERVICES_NOT_ENOUGH_MONEY", CHARACTER_SERVICES_NOT_ENOUGH_MONEY)
			elseif status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status == SERVICE_RESULT_STATUS.SERVICE_DISABLED then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_SERVICES_DISABLED)
			elseif status then
				GlueDialog:ShowDialog("OKAY_VOID", string.format("LIST PAGE PURCHASE ERROR: %d", status))
			else
				GlueDialog:ShowDialog("OKAY_VOID", "[ERROR] SMSG_CHARACTERS_LIST_PURCHASE_RESULT: no error code")
			end
		elseif prefix == "SMSG_DELETED_CHARACTER_RESTORE" then
			local status, isRename = string.split(":", content)

			if status == SERVICE_RESTORE_STATUS.SUCCESS then
				CharacterSelect.UndeleteCharacterAlert = isRename ~= nil and 1 or 2
				C_CharacterList.GetCharacterListUpdate()
				C_CharacterServices.RequestBalance()
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
		elseif prefix == "SMSG_BSI" then	-- SMSG_BOOST_SERVICE_ITEMS
			local status, lastMSG, specInfo = string.split(":", content, 3)
			local classID = PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID

			if status == "0" then
				table.insert(PRIVATE.AWAIT_BOOST_ITEMS_MSG, specInfo)

				if lastMSG == "0" then
					return
				elseif lastMSG == "1" then
					specInfo = table.concat(PRIVATE.AWAIT_BOOST_ITEMS_MSG, "")
				else
					return
				end

				if specInfo ~= "" then
					local realmID = C_Service.GetRealmID()

					if not PRIVATE.BOOST_SPEC_ITEMS[realmID] then
						PRIVATE.BOOST_SPEC_ITEMS[realmID] = {}
					end
					if not PRIVATE.BOOST_SPEC_ITEMS[realmID][classID] then
						PRIVATE.BOOST_SPEC_ITEMS[realmID][classID] = {}
					else
						table.wipe(PRIVATE.BOOST_SPEC_ITEMS[realmID][classID])
					end

					for key, specType in pairs(Enum.CharacterServices.SpecType) do
						PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType] = {}
					end

					for index, specDataStr in ipairs({StringSplitEx(":", specInfo)}) do
						local specIndex, isPVP, itemList = StringSplitEx(";", specDataStr, 3)
						if itemList then
							local specType = isPVP == "1" and Enum.CharacterServices.SpecType.PVP or Enum.CharacterServices.SpecType.PVE
							specIndex = tonumber(specIndex) + 1
							PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType][specIndex] = {}

							for itemIndex, itemInfo in ipairs({StringSplitEx(",", itemList)}) do
								local itemID, amount = StringSplitEx("|", itemInfo)
								PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType][specIndex][itemIndex] = {
									itemID = tonumber(itemID) or 0,
									amount = tonumber(amount) or 0,
								}
							end
						end
					end
				end

				FireCustomClientEvent("BOOST_SERVICE_ITEMS_LOADED", classID)

				if PRIVATE.AWAIT_BOOST_ITEMS_NEW_STAGE == classID then
					PRIVATE.AWAIT_BOOST_ITEMS_NEW_STAGE = nil
					PRIVATE.CheckBoostServiceStage(classID)
				end
			else
				GMError(string.format("No info for classID %d", classID))
			end

			table.wipe(PRIVATE.AWAIT_BOOST_ITEMS_MSG)
			PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID = nil
			PRIVATE.RequestNextSpecItems()
		elseif prefix == "SMSG_SGBR" then	-- SMSG_SERVICE_GEAR_BOOST_RESULT
			local status = string.split(":", content, 1)
			status = tonumber(status)

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				C_CharacterList.GetCharacterListUpdate()
				C_CharacterServices.RequestBalance()
			elseif status == SERVICE_RESULT_STATUS.NOT_ENOUGH_MONEY then
				GlueDialog:ShowDialog("CHARACTER_SERVICES_NOT_ENOUGH_MONEY", CHARACTER_SERVICES_NOT_ENOUGH_MONEY)
			elseif status == SERVICE_RESULT_STATUS.NOT_AVAILABLE or status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status == SERVICE_RESULT_STATUS.SERVICE_DISABLED then
				GlueDialog:ShowDialog("OKAY_VOID", CHARACTER_BOOST_DISABLE_REALM)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST FINISH ERROR: %d", status)
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			else
				GlueDialog:ShowDialog("OKAY_VOID", "[ERROR] SMG_FINISH_BOOST_RESULT: no error code")
			end

			FireCustomClientEvent("CHARACTER_SERVICES_GEAR_BOOST_DONE", status == SERVICE_RESULT_STATUS.SUCCESS)
		elseif prefix == "SMSG_SBC" then	-- SMSG_SERVICE_BOOST_CANCEL
			local status = string.split(":", content, 1)
			status = tonumber(status)

			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				GlueDialog:ShowDialog("SERVER_WAITING")
				C_CharacterServices.RequestServiceInfo()
				C_CharacterList.GetCharacterListUpdate()
			elseif status == SERVICE_RESULT_STATUS.BOOST_CANCEL_UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST REVOCATION ERROR: %d", status)
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			else
				GlueDialog:ShowDialog("OKAY_VOID", "[ERROR] SMSG_SBC: no error code")
			end
		elseif prefix == "SMSG_SBR" then	-- SMSG_SERVICE_BOOST_REFUND
			local status = string.split(":", content, 1)
			status = tonumber(status)

			PRIVATE.BOOST_REFUND_AWAIT = nil
			GlueDialog:HideDialog("SERVER_WAITING")

			if status == SERVICE_RESULT_STATUS.SUCCESS then
				C_CharacterServices.RequestServiceInfo()
			--	C_CharacterServices.RequestBalance()
				FireCustomClientEvent("CHARACTER_SERVICES_BOOST_PURCHASE_STATUS", false)
			elseif status == SERVICE_RESULT_STATUS.UNCONFIRMED_ACCOUNT then
				GlueDialog:ShowDialog("OKAY_HTML", CHARACTER_SERVICES_DISABLE_SUSPECT_ACCOUNT)
			elseif status then
				local err = string.format("CHARACTER_SERVICES_BOOST_ERROR_%d", status)
				local errorText = _G[err] or string.format("BOOST REFUND ERROR: %d", status)
				GlueDialog:ShowDialog("OKAY_VOID", errorText)
			else
				GlueDialog:ShowDialog("OKAY_VOID", "[ERROR] SMSG_SBR: no error code")
			end
		end
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	self.nextUpdate = (self.nextUpdate or 0.2) - elapsed
	if self.nextUpdate > 0 then
		return
	else
		self.nextUpdate = 0.2 - self.nextUpdate
	end

	PRIVATE.GetBoostRefundTimeLeft() -- force update time
end)

PRIVATE.GetBoostServicePrice = function()
	local price, priceOriginal

	if bit.band(PRIVATE.FLAGS, CHARACTER_SERVICE_FLAG.BOOST_HAS_DISCOUNT) ~= 0 then
		price = PRIVATE.BOOST_PRICE_DISCOUNTED
		priceOriginal = PRIVATE.BOOST_PRICE_BASE
	else
		price = PRIVATE.BOOST_PRICE_BASE
		priceOriginal = PRIVATE.BOOST_PRICE_BASE
	end

	return price, priceOriginal
end

PRIVATE.IsBoostServiceAvailable = function()
	if not PRIVATE.ACTIVE then
		return false
	end
	if PRIVATE.BOOST_STATUS == Enum.CharacterServices.BoostServiceStatus.Disabled
	or (PRIVATE.BOOST_STATUS == Enum.CharacterServices.BoostServiceStatus.Available and (not PRIVATE.BALANCE or PRIVATE.BOOST_PRICE_BASE == -1))
	then
		return false
	end
	return true
end

PRIVATE.IsGearBoostServiceAvailable = function()
	if PRIVATE.ACTIVE
	and PRIVATE.BOOST_STATUS ~= Enum.CharacterServices.BoostServiceStatus.Disabled
	and PRIVATE.BALANCE and PRIVATE.BOOST_PRICE_BASE ~= -1
	then
		return true
	end
	return false
end

PRIVATE.GetSuggestedBonusAmount = function(price)
	local value = price - PRIVATE.BALANCE

	if value > 50 and value < 60 then
		value = 60
	elseif value > 100 and value < 120 then
		value = 120
	end

	return value
end

PRIVATE.OpenBonusPurchaseWebPage = function(mode)
	local price

	if mode == Enum.CharacterServices.Mode.Boost or Enum.CharacterServices.Mode.GearBoost then
		price = PRIVATE.GetBoostServicePrice()
	elseif mode == Enum.CharacterServices.Mode.CharRestore then
		price = PRIVATE.CHAR_RESTORE_PRICE
	elseif mode == Enum.CharacterServices.Mode.CharListPage then
		price = PRIVATE.CHAR_LISTPAGE_PRICE
	end

	assert(price and price > 0)

	local value = PRIVATE.GetSuggestedBonusAmount(price)
	LaunchURL(string.format(DONATE_URL, math.max(10, value)))
end

PRIVATE.RequestSpecItems = function(classID)
	local realmID = C_Service.GetRealmID()

	if not (PRIVATE.BOOST_SPEC_ITEMS[realmID] and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID]) then
		if PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID then
			if PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID ~= classID
			and not tIndexOf(PRIVATE.AWAIT_BOOST_ITEMS_QUEQUE, classID)
			then
				table.insert(PRIVATE.AWAIT_BOOST_ITEMS_QUEQUE, classID)
			end
		else
			PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID = classID
			C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostSpecItems, classID)
		end

		return true
	end

	return false
end

PRIVATE.RequestNextSpecItems = function()
	if #PRIVATE.AWAIT_BOOST_ITEMS_QUEQUE ~= 0 then
		local classID = table.remove(PRIVATE.AWAIT_BOOST_ITEMS_QUEQUE, 1)
		PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID = classID
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostSpecItems, classID)
	else
		PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID = nil
	end
end

PRIVATE.CheckBoostServiceStage = function(classID)
	local pveAvgItemLevel, pvpAvgItemLevel = C_CharacterServices.GetBoostClassMaxAvgItemLevel(classID)
	local avgItemLevel = math.ceil(pveAvgItemLevel)

	local realmID = C_Service.GetRealmID()
	local value = C_GlueCVars.GetCVar("BOOST_ITEM_LEVLS")
	local valueChanged
	local notSeen

	if value == "" then
		local newValue = string.format("%d:%d:0", realmID, avgItemLevel)
		C_GlueCVars.SetCVar("BOOST_ITEM_LEVLS", newValue)
		valueChanged = true
	else
		local valueFound
		local newValue = string.gsub(value, "(%d+)(:)(%d+)(:)(%d)", function(varRealmID, delimiter, varAvgItemLevel, _, state)
			if not valueFound and tonumber(varRealmID) == realmID then
				valueFound = true

				if state == "0" then
					notSeen = true
				elseif tonumber(varAvgItemLevel) ~= avgItemLevel then
					valueChanged = true
					return realmID, delimiter, avgItemLevel, delimiter, 0
				end
			end
		end)

		if not valueFound then
			valueChanged = true
			newValue = string.format("%s;%d:%d:0", newValue, realmID, avgItemLevel)
		end

		if valueChanged then
			C_GlueCVars.SetCVar("BOOST_ITEM_LEVLS", newValue)
		end
	end

	if valueChanged or notSeen then
		FireCustomClientEvent("BOOST_SERVICE_NEW_STAGE")
	end
end

PRIVATE.MarkBoostServiceItemStageSeen = function()
	local realmID = C_Service.GetRealmID()
	local value = C_GlueCVars.GetCVar("BOOST_ITEM_LEVLS")
	local pattern = string.format("(%d:%%d+:)%%d+", realmID)
	local newValue = string.gsub(value, pattern, function(res)
		return strconcat(res, "1")
	end)
	C_GlueCVars.SetCVar("BOOST_ITEM_LEVLS", newValue)
end

PRIVATE.GetBoostRefundTimeLeft = function(characterID)
	local dataTimestamp = PRIVATE.UPDATE_TIMESTAMP
	if dataTimestamp then
		local totalTimeLeft = PRIVATE.BOOST_REFUND_TIMELEFT
		if totalTimeLeft > 0 then
			local secondsLeft = math.max(0, totalTimeLeft - (time() - dataTimestamp))
			if secondsLeft == 0 then
				PRIVATE.BOOST_REFUND_TIMELEFT = 0
				FireCustomClientEvent("CHARACTER_SERVICES_BOOST_STATUS_UPDATE", PRIVATE.BOOST_STATUS) -- fire event to remove non-available service
				return 0
			end
			return secondsLeft
		end
	end
	return 0
end

PRIVATE.IsBoostRefundAvailable = function()
	return PRIVATE.IsBoostServiceAvailable() and PRIVATE.GetBoostRefundTimeLeft() > 0
end

C_CharacterServices = {}

function C_CharacterServices.RequestServiceInfo(throttled)
	if throttled then
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestBoostStatus)
	else
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostStatus)
	end
end

function C_CharacterServices.RequestBalance()
	C_CharacterServices.RequestServiceInfo(false)
end

function C_CharacterServices.GetAccountName()
	return GetCVar("accountName")
end

function C_CharacterServices.GetBalance()
	return PRIVATE.BALANCE or 0
end

function C_CharacterServices.IsBoostServiceAvailable()
	return PRIVATE.IsBoostServiceAvailable()
end

function C_CharacterServices.GetBoostStatus()
	if not PRIVATE.IsBoostServiceAvailable() then
		return Enum.CharacterServices.BoostServiceStatus.Disabled
	end
	return PRIVATE.BOOST_STATUS
end

function C_CharacterServices.IsBoostAvailableForLevel(characterLevel)
	return characterLevel < PRIVATE.BOOST_MAX_LEVEL and C_CharacterServices.GetBoostStatus() ~= Enum.CharacterServices.BoostServiceStatus.Disabled
end

function C_CharacterServices.IsBoostHasPVPEquipment()
	if PRIVATE.IsBoostServiceAvailable() then
		return bit.band(PRIVATE.FLAGS, CHARACTER_SERVICE_FLAG.BOOST_HAS_PVP_SET) ~= 0
	end
	return false
end

function C_CharacterServices.IsBoostPersonal()
	if not PRIVATE.IsBoostServiceAvailable() then return end
	return bit.band(PRIVATE.FLAGS, CHARACTER_SERVICE_FLAG.BOOST_PERSONAL_SALE) ~= 0
end

function C_CharacterServices.GetBoostPrice()
	if not PRIVATE.IsBoostServiceAvailable() then return end

	local price, priceOriginal = PRIVATE.GetBoostServicePrice()
	local discount

	if price ~= priceOriginal then
		discount = math.floor((1 - (price / priceOriginal)) * 100)
	end

	return price, priceOriginal, discount or 0
end

function C_CharacterServices.GetBoostTimeleft()
	if not PRIVATE.IsBoostServiceAvailable() then return end
	return PRIVATE.BOOST_SECONDS, PRIVATE.BOOST_EXPIRE_AT
end

function C_CharacterServices.GetCharacterRestorePrice()
	return PRIVATE.CHAR_RESTORE_PRICE or -1
end

function C_CharacterServices.GetListPagePrice()
	return PRIVATE.CHAR_LISTPAGE_PRICE or -1
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

	if PRIVATE.BALANCE >= PRIVATE.GetBoostServicePrice() or IsGMAccount(true) then
		GlueDialog:ShowDialog("SERVER_WAITING")
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestBoostBuy)
	else
		PRIVATE.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end
end

function C_CharacterServices.PurchaseRestoreCharacter(characterID)
	if not PRIVATE.ACTIVE then return end

	if PRIVATE.BALANCE >= PRIVATE.CHAR_RESTORE_PRICE or IsGMAccount(true) then
		GlueDialog:ShowDialog("SERVER_WAITING")
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.SendCharacterDeletedRestore, characterID)
	else
		PRIVATE.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.CharRestore)
	end
end

function C_CharacterServices.PurchaseCharacterListPage()
	if not C_CharacterServices.IsNewPageServiceAvailable() then
		return
	end

	if PRIVATE.BALANCE >= PRIVATE.CHAR_LISTPAGE_PRICE
	or PRIVATE.CHAR_LISTPAGE_PRICE == -1
	or IsGMAccount(true)
	then
		GlueDialog:ShowDialog("SERVER_WAITING")
		C_GluePackets:SendPacketThrottled(C_GluePackets.OpCodes.RequestNewPagePurchase)
	else
		PRIVATE.OpenBonusPurchaseWebPage(Enum.CharacterServices.Mode.Boost)
	end
end

function C_CharacterServices.BoostCharacter(characterID, mainProfessionIndex, secondProfessionIndex, specIndex, pvpSpecIndex, factionIndex)
	local characterIndex = C_CharacterList.GetCharacterIndexByID(characterID)
	GlueDialog:ShowDialog("SERVER_WAITING")
	C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostCharacter, characterIndex, secondProfessionIndex, mainProfessionIndex, specIndex, pvpSpecIndex, factionIndex)
end

function C_CharacterServices.GetBoostCharacterSpecs(classID, specType)
	local classInfo = C_CreatureInfo.GetClassInfo(classID)

	if specType == Enum.CharacterServices.SpecType.PVE then
		return SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile]
	else
		local specs = {}
		for specIndex, spec in ipairs(SHARED_CONSTANTS_SPECIALIZATION[classInfo.classFile]) do
			if specIndex ~= 4 then
				specs[specIndex] = spec
			end
		end
		return specs
	end
end

function C_CharacterServices.RequestSpecItems(classID)
	return PRIVATE.RequestSpecItems(classID)
end

function C_CharacterServices.IsBoostClassSpecItemsLoading(classID)
	return PRIVATE.AWAIT_BOOST_ITEMS_CLASS_ID == classID or tIndexOf(PRIVATE.AWAIT_BOOST_ITEMS_QUEQUE, classID) ~= nil
end

function C_CharacterServices.IsBoostClassSpecItemsLoaded(classID)
	local realmID = C_Service.GetRealmID()
	if PRIVATE.BOOST_SPEC_ITEMS[realmID]
	and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID]
	then
		return true
	end
	return false
end

function C_CharacterServices.GetBoostClassSpecAvgItemLevel(classID, specType, specIndex)
	local items

	local realmID = C_Service.GetRealmID()
	if PRIVATE.BOOST_SPEC_ITEMS[realmID]
	and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID]
	and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType]
	then
		items = PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType][specIndex]
	end

	if items and #items > 0 then
		if items.avgItemLevel then
			return items.avgItemLevel
		end

		local itemLevelTotal = 0
		local itemAmountTotal = 0
		for index, itemData in ipairs(items) do
			local name, link, quality, itemLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice, itemClassID, subclassID, equipLocID = C_Item.GetItemInfoCache(itemData.itemID)
			if name and itemLevel and itemClassID ~= 6 then
				itemLevelTotal = itemLevelTotal + itemLevel
				itemAmountTotal = itemAmountTotal + 1
			end
		end
		items.avgItemLevel = math.floor(itemLevelTotal / itemAmountTotal)
		return items.avgItemLevel
	end
	return 0
end

function C_CharacterServices.GetBoostClassMaxAvgItemLevel(classID)
	local specTypes

	local realmID = C_Service.GetRealmID()
	if PRIVATE.BOOST_SPEC_ITEMS[realmID]
	and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID]
	then
		specTypes = PRIVATE.BOOST_SPEC_ITEMS[realmID][classID]
	end

	if specTypes and #specTypes > 0 then
		if specTypes.pveAvgItemLevel then
			return specTypes.pveAvgItemLevel, specTypes.pvpAvgItemLevel
		end

		local pveAvgItemLevel = 0
		local pvpAvgItemLevel = 0

		for specType, specArray in ipairs(specTypes) do
			for specIndex, items in ipairs(specArray) do
				local itemLevelTotal = 0
				local itemAmountTotal = 0
				for index, itemData in ipairs(items) do
					local name, link, quality, itemLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice, itemClassID, subclassID, equipLocID = C_Item.GetItemInfoCache(itemData.itemID)
					if name and itemLevel and itemClassID ~= 6 then
						itemLevelTotal = itemLevelTotal + itemLevel
						itemAmountTotal = itemAmountTotal + 1
					end
				end

				items.avgItemLevel = itemLevelTotal / itemAmountTotal

				if specType == Enum.CharacterServices.SpecType.PVE then
					pveAvgItemLevel = math.max(pveAvgItemLevel, items.avgItemLevel)
				elseif specType == Enum.CharacterServices.SpecType.PVP then
					pvpAvgItemLevel = math.max(pvpAvgItemLevel, items.avgItemLevel)
				end
			end
		end

		specTypes.pveAvgItemLevel = math.floor(pveAvgItemLevel)
		specTypes.pvpAvgItemLevel = math.floor(pvpAvgItemLevel)
		return specTypes.pveAvgItemLevel, specTypes.pvpAvgItemLevel
	end
	return 0, 0
end

function C_CharacterServices.GetBoostClassSpecItems(classID, specType, specIndex)
	local realmID = C_Service.GetRealmID()
	if PRIVATE.BOOST_SPEC_ITEMS[realmID]
	and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID]
	and PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType]
	then
		local items = {}
		for index, item in ipairs(PRIVATE.BOOST_SPEC_ITEMS[realmID][classID][specType][specIndex]) do
			local name, link, quality, itemLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice, itemClassID, subclassID, equipLocID = C_Item.GetItemInfoCache(item.itemID)
			if itemClassID ~= 6 then
				table.insert(items, CopyTable(item))
			end
		end
		return items
	end
	return {}
end

function C_CharacterServices.IsGearBoostServiceAvailable()
	return PRIVATE.IsGearBoostServiceAvailable()
end

function C_CharacterServices.CanBoostCharacterGear(characterID)
	if not PRIVATE.IsGearBoostServiceAvailable()
	or C_CharacterList.IsHardcoreCharacter(characterID)
	then
		return false
	end

	local pendingBoostCharacterListID, pendingBoostCharacterID, pendiongBoostCharacterPageIndex = C_CharacterList.GetPendingBoostDK()
	if characterID == pendingBoostCharacterID then
		return false
	end

	local name, race, class, level = GetCharacterInfo(characterID)
	if level < 80 then
		return false
	end

	return true
end

function C_CharacterServices.BoostCharacterGear(characterID, specType, specIndex, equipItems)
	assert(PRIVATE.IsGearBoostServiceAvailable(), "Gear Boost service unavailable")
	assert(type(characterID) == "number", "characterID not number")
	assert(type(specType) == "number", "specType not number")
	assert(type(specIndex) == "number", "specIndex not number")

	local characterIndex = C_CharacterList.GetCharacterIndexByID(characterID)
	GlueDialog:ShowDialog("SERVER_WAITING")
	C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostCharacterItems, characterIndex, specType, specIndex, equipItems and 1 or 0)
end

function C_CharacterServices.CheckBoostServiceItemStage()
	if not PRIVATE.IsBoostServiceAvailable() then
		return
	end

	local classID = CLASS_ID_MAGE
	if C_CharacterServices.IsBoostClassSpecItemsLoaded(classID) then
		PRIVATE.CheckBoostServiceStage(classID)
	else
		PRIVATE.AWAIT_BOOST_ITEMS_NEW_STAGE = classID
		if not C_CharacterServices.IsBoostClassSpecItemsLoading(classID) then
			PRIVATE.RequestSpecItems(classID)
		end
	end
end

function C_CharacterServices.MarkBoostServiceItemStageSeen()
	PRIVATE.MarkBoostServiceItemStageSeen()
end

function C_CharacterServices.IsBoostCancelAvailable()
	return bit.band(PRIVATE.FLAGS, CHARACTER_SERVICE_FLAG.BOOST_CANCEL_AVAILABLE) ~= 0
end

function C_CharacterServices.RequestBoostCancel(characterID)
	assert(type(characterID) == "number", "characterID not number")
	if C_CharacterList.HasBoostCancel(characterID) then
		local characterIndex = C_CharacterList.GetCharacterIndexByID(characterID)
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostCancel, characterIndex)
		GlueDialog:ShowDialog("SERVER_WAITING")
	end
end

function C_CharacterServices.IsBoostRefundAvailable()
	return PRIVATE.IsBoostRefundAvailable()
end

function C_CharacterServices.GetBoostRefundInfo()
	if not PRIVATE.IsBoostRefundAvailable() then
		return 0, 0, 0, 0, BOOST_REFUND_PENALTY_PERCENTS
	end

	local timeLeft = PRIVATE.GetBoostRefundTimeLeft()
	local penaltyTime = BOOST_REFUND_SECONDS - BOOST_REFUND_PENALTY_SECONDS
	local priceFull = PRIVATE.BOOST_REFUND_PRICE_FULL or 0
	local pricePenalty = PRIVATE.BOOST_REFUND_PRICE_PENALTY or 0
	local timeLeftNextPenalty

	if timeLeft > penaltyTime then
		timeLeftNextPenalty = timeLeft - penaltyTime
	else
		timeLeftNextPenalty = 0
	end

	return timeLeft, timeLeftNextPenalty, priceFull, pricePenalty, BOOST_REFUND_PENALTY_PERCENTS
end

function C_CharacterServices.RequestBoostRefund()
	if PRIVATE.IsBoostRefundAvailable() and not PRIVATE.BOOST_REFUND_AWAIT then
		PRIVATE.BOOST_REFUND_AWAIT = true
		GlueDialog:ShowDialog("SERVER_WAITING")
		C_GluePackets:SendPacket(C_GluePackets.OpCodes.RequestBoostRefund)
	end
end