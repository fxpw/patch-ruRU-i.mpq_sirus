local ipairs = ipairs
local tonumber = tonumber
local type = type
local bitband = bit.band
local strformat, strsplit = string.format, string.split
local tinsert, twipe = table.insert, table.wipe

local GetItemInfo = GetItemInfo

local FireClientEvent = FireClientEvent
local FireCustomClientEvent = FireCustomClientEvent
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx

local AUCTION_FIELD = {
	AUCTION_ID = 1,
	ITEM_ID = 2,
	ITEM_COUNT = 3,
	SELLER_NAME = 4,
	FLAGS = 5,
	TIMELEFT = 6,
	LAST_BET = 7,
}

local ITEM_FLAG = {
	PLAYER_HIGHEST_BID = 0x1,
	HOT_AUCTION = 0x2,
}

local PRIVATE = {
	ENABLED = false,
	AUCTION_BY_INDEX = {},
	AUCTION_BY_ID = {},
	HOT_AUCTION = nil,
}

function EventHandler:ASMSG_BLACK_MARKET_LIST(msg)
	PRIVATE.HOT_AUCTION = nil
	twipe(PRIVATE.AUCTION_BY_INDEX)
	twipe(PRIVATE.AUCTION_BY_ID)

	for index, auctionInfoStr in ipairs({StringSplitEx("|", msg)}) do
		local auctionID, itemID, itemCount, sellerName, lastBet, timeLeft, flags = strsplit(":", auctionInfoStr)
		auctionID = tonumber(auctionID)

		if auctionID then
			flags = tonumber(flags) or 0

			local auctionInfo = {
				[AUCTION_FIELD.AUCTION_ID]	= auctionID,
				[AUCTION_FIELD.ITEM_ID]		= tonumber(itemID),
				[AUCTION_FIELD.ITEM_COUNT]	= tonumber(itemCount) or 1,
				[AUCTION_FIELD.SELLER_NAME]	= sellerName,
				[AUCTION_FIELD.FLAGS]		= flags,
				[AUCTION_FIELD.TIMELEFT]	= tonumber(timeLeft),
				[AUCTION_FIELD.LAST_BET]	= tonumber(lastBet),
			}

			PRIVATE.AUCTION_BY_ID[auctionID] = auctionInfo
			tinsert(PRIVATE.AUCTION_BY_INDEX, auctionInfo)

			if bitband(flags, ITEM_FLAG.HOT_AUCTION) ~= 0 then
				PRIVATE.HOT_AUCTION = auctionInfo
			end
		end
	end

	PRIVATE.ENABLED = true
	FireCustomClientEvent("BLACK_MARKET_OPEN")
	FireCustomClientEvent("BLACK_MARKET_ITEM_UPDATE")
end

function EventHandler:ASMSG_BLACK_MARKET_BID_R(msg)
	local status = tonumber(msg)
	if status == 0 then
		-- success
	else
		local errorText = _G[strformat("BLACK_MARKET_ERROR_%d", status)]
		if not errorText then
			errorText = strformat("[BLACK_MARKET_BID_RESULT] Error code '%s'", status or "nil")
		end
		FireClientEvent("UI_ERROR_MESSAGE", errorText)
	end

	FireCustomClientEvent("BLACK_MARKET_BID_RESULT")
end

function EventHandler:ASMSG_BLACK_MARKET_CLOSE(msg)
	PRIVATE.Close()
end

PRIVATE.Close = function()
	FireCustomClientEvent("BLACK_MARKET_CLOSE")
end

PRIVATE.GetAuctionInfo = function(itemInfo)
	local auctionID = itemInfo[AUCTION_FIELD.AUCTION_ID]
	local quantity = itemInfo[AUCTION_FIELD.ITEM_COUNT]
	local sellerName = itemInfo[AUCTION_FIELD.SELLER_NAME]
	local flags = itemInfo[AUCTION_FIELD.FLAGS]
	local timeLeft = itemInfo[AUCTION_FIELD.TIMELEFT]
	local currBid = itemInfo[AUCTION_FIELD.LAST_BET]
	local minBid = currBid * 1.05
	local minIncrement = currBid * 0.05
	local youHaveHighBid = bitband(flags, ITEM_FLAG.PLAYER_HIGHEST_BID) ~= 0

	local usable = true
	local levelType = -1
	local numBids = -1

	local name, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(itemInfo[AUCTION_FIELD.ITEM_ID])

	return name or UNKNOWN, itemTexture or [[Interface\Icons\INV_Misc_QuestionMark]], quantity, itemSubType, usable, itemLevel, levelType, sellerName,
		minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, itemLink, auctionID, itemRarity or 4, flags
end

C_BlackMarket = {}

function C_BlackMarket.IsViewOnly()
	return not PRIVATE.ENABLED
end

function C_BlackMarket.Close()
	PRIVATE.Close()
end

function C_BlackMarket.RequestItems()
	FireCustomClientEvent("BLACK_MARKET_ITEM_UPDATE")
end

function C_BlackMarket.GetNumItems()
	return #PRIVATE.AUCTION_BY_INDEX
end

function C_BlackMarket.GetItemInfoByIndex(index)
	if type(index) ~= "number" then
		error(strformat("bad argument #1 to 'C_BlackMarket.GetItemInfoByIndex' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	elseif index < 0 or index > #PRIVATE.AUCTION_BY_INDEX then
		error(strformat("bad argument #1 to 'C_BlackMarket.GetItemInfoByIndex' (index %s out of range)", index), 2)
	end

	local auctionInfo = PRIVATE.AUCTION_BY_INDEX[index]
	if auctionInfo then
		return PRIVATE.GetAuctionInfo(auctionInfo)
	end
end

function C_BlackMarket.GetItemInfoByID(auctionID)
	if type(auctionID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BlackMarket.GetItemInfoByID' (number expected, got %s)", auctionID ~= nil and type(auctionID) or "no value"), 2)
	end

	local auctionInfo = PRIVATE.AUCTION_BY_ID[auctionID]
	if auctionInfo then
		return PRIVATE.GetAuctionInfo(auctionInfo)
	end
end

function C_BlackMarket.GetHotItem()
	local auctionInfo = PRIVATE.HOT_AUCTION
	if auctionInfo then
		return PRIVATE.GetAuctionInfo(auctionInfo)
	end
end

function C_BlackMarket.ItemPlaceBid(auctionID, bid)
	if type(auctionID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BlackMarket.ItemPlaceBid' (number expected, got %s)", auctionID ~= nil and type(auctionID) or "no value"), 2)
	elseif type(bid) ~= "number" then
		error(strformat("bad argument #2 to 'C_BlackMarket.ItemPlaceBid' (number expected, got %s)", bid ~= nil and type(bid) or "no value"), 2)
	end

	SendServerMessage("ACMSG_BLACK_MARKET_BID", auctionID, bid)
end