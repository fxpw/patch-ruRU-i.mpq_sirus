local _G = _G;
local error = error;
local ipairs = ipairs;
local next = next;
local pairs = pairs;
local select = select;
local tonumber = tonumber;
local type = type;
local unpack = unpack;

local find = string.find;
local format = string.format;
local lower = string.lower;
local split = string.split;
local sub = string.sub;

local max = math.max;
local ceil = math.ceil;
local floor = math.floor;
local abs = math.abs;

local twipe = table.wipe;
local tinsert = table.insert;
local tconcat = table.concat;
local tremove = table.remove;

local ItemsCache = ItemsCache;
local GetItemInfo = C_Item._GetItemInfo;

Enum.AuctionHouseFilterCategory = {
	Uncategorized = 0,
	Equipment = 1,
	Rarity = 2,
};

Enum.AuctionStatus = {
	Active = 0,
	Sold = 1,
};

Enum.ItemCommodityStatus = {
	Unknown = 0,
	Item = 1,
	Commodity = 2,
};

Enum.AuctionHouseCommoditySortOrder = {
	UnitPrice = 0,
	Quantity = 1,
};

Enum.AuctionHouseFilter = {
	UncollectedOnly = 0,
	UsableOnly = 1,
	UpgradesOnly = 2,
	ExactMatch = 3,
	PoorQuality = 4,
	CommonQuality = 5,
	UncommonQuality = 6,
	RareQuality = 7,
	EpicQuality = 8,
	LegendaryQuality = 9,
};

Enum.AuctionHouseItemSortOrder = {
	Bid = 0,
	Buyout = 1,
};

Enum.AuctionHouseSortOrder = {
	Price = 0,
	Name = 1,
	Level = 2,
	Bid = 3,
	Buyout = 4,
	TimeRemaining = 5,
};

Enum.AuctionHouseTimeLeftBand = {
	Short = 0,
	Medium = 1,
	Long = 2,
	VeryLong = 3,
};

local AUCTION_HOUSE_ERROR = {
	OK                          = 0,
	INVENTORY                   = 1,
	DATABASE_ERROR              = 2,
	NOT_ENOUGH_MONEY            = 3,
	ITEM_NOT_FOUND              = 4,
	HIGHER_BID                  = 5,
	BID_INCREMENT               = 7,
	BID_OWN                     = 10,
	RESTRICTED_ACCOUNT_TRIAL    = 13,
	HAS_RESTRICTION             = 17,
	AH_BUSY                     = 18,
	AH_UNAVAILABLE              = 19,
	COMMODITY_PURCHASE_FAILED   = 21,
	ITEM_HAS_QUOTE              = 23,
};

local AUCTION_HOUSE_COMMAND = {
	SELL_ITEM = 0,
	CANCEL = 1,
	PLACE_BID = 2,
};

local BROWSE_QUERY_FILTER_MASK = {
	[Enum.AuctionHouseFilter.UncollectedOnly]       = 1,
	[Enum.AuctionHouseFilter.UsableOnly]            = 2,
	[Enum.AuctionHouseFilter.PoorQuality]           = 16,
	[Enum.AuctionHouseFilter.CommonQuality]         = 32,
	[Enum.AuctionHouseFilter.UncommonQuality]       = 64,
	[Enum.AuctionHouseFilter.RareQuality]           = 128,
	[Enum.AuctionHouseFilter.EpicQuality]           = 256,
	[Enum.AuctionHouseFilter.LegendaryQuality]      = 512,
};

local AUCTION_HOUSE_DURATION = {720, 1440, 2880};

local AUCTION_LIST_ITEMS_RESULT_DEFAULT = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
};

local AUCTION_LIST_ITEMS_RESULT_BY_ITEMID = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	ItemID = 23,
	ItemLevel = 24,
	ItemSuffix = 25,
};

local AUCTION_LIST_ITEMS_RESULT_OWNER = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	TimeLeftSeconds = 23,
};

local AUCTION_LIST_ITEMS_RESULT_OWNER_BY_ITEMID = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	TimeLeftSeconds = 23,
	ItemID = 24,
	ItemLevel = 25,
	ItemSuffix = 26,
};

local AUCTION_LIST_ITEMS_RESULT_BIDER = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	BiderGUID = 23,
	BidAmount = 24,
	BidderName = 25,
};

local AUCTION_LIST_ITEMS_RESULT_OWNER_BIDER = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	TimeLeftSeconds = 23,
	BiderGUID = 24,
	BidAmount = 25,
	BidderName = 26,
};

local AUCTION_LIST_ITEMS_RESULT_BIDER_BY_ITEMID = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	BiderGUID = 23,
	BidAmount = 24,
	BidderName = 25,
	ItemID = 26,
	ItemLevel = 27,
	ItemSuffix = 28,
};

local AUCTION_LIST_ITEMS_RESULT_OWNER_BIDER_BY_ITEMID = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	Unk3 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	TimeLeftSeconds = 23,
	BiderGUID = 24,
	BidAmount = 25,
	BidderName = 26,
	ItemID = 27,
	ItemLevel = 28,
	ItemSuffix = 29,
};

local AUCTION_LIST_COMMODITY_RESULT_BY_ITEMID = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	BuyoutAmount = 11,
	ItemID = 12,
	ItemLevel = 13,
	ItemSuffix = 14,
};

local AUCTION_LIST_COMMODITY_RESULT_OWNER_BY_ITEMID = {
	HasBidInfo = 1,
	HasAccountItem = 2,
	HasByItemID = 3,
	Quantity = 4,
	Flag = 5,
	AuctionID = 6,
	OwnerGUID = 7,
	OwnerName = 8,
	TimeLeft = 9,
	Unk2 = 10,
	BuyoutAmount = 11,
	TimeLeftSeconds = 12,
	ItemID = 13,
	ItemLevel = 14,
	ItemSuffix = 15,
};

local AUCTION_LIST_AUCTIONS_RESULT_BY_ITEMID = {
	Unk1 = 1,
	Unk2 = 2,
	Quantity = 3,
	Unk3 = 4,
	Unk4 = 5,
	AuctionID = 6,
	Unk5 = 7,
	Unk6 = 8,
	TimeLeft = 9,
	Unk7 = 10,
	Unk8 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	BiderGUID = 23,
	BidAmount = 24,
	Bidder = 25,
	ItemID = 26,
	ItemLevel = 27,
	ItemSuffix = 28,
};

local AUCTION_LIST_AUCTIONS_RESULT_OWNED_BY_ITEMID = {
	Unk1 = 1,
	Unk2 = 2,
	Unk3 = 3,
	Quantity = 4,
	Unk4 = 5,
	AuctionID = 6,
	Unk5 = 7,
	Unk6 = 8,
	TimeLeft = 9,
	Unk7 = 10,
	Unk8 = 11,
	EnchantID = 12,
	HasSocketedItem = 13,
	JewelID1 = 14,
	JewelID2 = 15,
	JewelID3 = 16,
	JewelID4 = 17,
	SuffixID = 18,
	UniqueID = 19,
	MinBid = 20,
	MinIncrement = 21,
	BuyoutAmount = 22,
	TimeLeftSeconds = 23,
	BiderGUID = 24,
	BidAmount = 25,
	Bidder = 26,
	ItemID = 27,
	ItemLevel = 28,
	ItemSuffix = 29,
};

local AUCTION_LIST_AUCTIONS_RESULT_OWNED_BY_COMMODITY = {
	Unk1 = 1,
	Unk2 = 2,
	Unk3 = 3,
	Quantity = 4,
	Unk4 = 5,
	AuctionID = 6,
	Unk5 = 7,
	Unk6 = 8,
	TimeLeft = 9,
	Unk7 = 10,
	BuyoutAmount = 11,
	TimeLeftSeconds = 12,
	BiderGUID = 13,
	BidAmount = 14,
	Bidder = 15,
	ItemID = 16,
	ItemLevel = 17,
	ItemSuffix = 18,
};

AuctionHouseUtil = {};

AuctionHouseBaseUtilMixin = {};

function AuctionHouseUtil:CreateBase()
	return CreateAndInitFromMixin(AuctionHouseBaseUtilMixin);
end

function AuctionHouseBaseUtilMixin:Init()
	self.sorts = {};
	self.offset = 0;

	self.fullResult = false;
	self.maxBid = 0;
	self.maxBuyout = 0;
end

function AuctionHouseBaseUtilMixin:Clear()
	self.offset = 0;
	self.fullResult = false;
	self.maxBid = 0;
	self.maxBuyout = 0;
end

function AuctionHouseBaseUtilMixin:SetSorts(sorts)
	self.sorts = CopyTable(sorts);
end

function AuctionHouseBaseUtilMixin:GetSorts()
	return self.sorts;
end

function AuctionHouseBaseUtilMixin:GetSortOrder()
	local sorts = self.sorts and (self.sorts.sorts or self.sorts);

	if not sorts or not sorts[1] then
		return 0;
	end

	return sorts[1].sortOrder or 0;
end

function AuctionHouseBaseUtilMixin:GetReverseSort()
	local sorts = self.sorts and (self.sorts.sorts or self.sorts);

	if not sorts or not sorts[1] then
		return 0;
	end

	return sorts[1].reverseSort and 1 or 0;
end

function AuctionHouseBaseUtilMixin:SetOffset(offset)
	self.offset = offset;
end

function AuctionHouseBaseUtilMixin:GetOffset()
	return self.offset;
end

function AuctionHouseBaseUtilMixin:SetFullResult(fullResult)
	self.fullResult = fullResult;
end

function AuctionHouseBaseUtilMixin:HasFullResults()
	return self.fullResult;
end

function AuctionHouseBaseUtilMixin:SetMaxBid(bid)
	self.maxBid = max(self.maxBid or 0, bid or 0);
end

function AuctionHouseBaseUtilMixin:GetMaxBid()
	return self.maxBid;
end

function AuctionHouseBaseUtilMixin:SetMaxBuyout(buyout)
	self.maxBuyout = max(self.maxBuyout or 0, buyout or 0);
end

function AuctionHouseBaseUtilMixin:GetMaxBuyout()
	return self.maxBuyout;
end

-- Item List Util
AuctionHouseItemsListUtilMixin = {};

function AuctionHouseItemsListUtilMixin:Init()
	self.itemList = {};
end

function AuctionHouseItemsListUtilMixin:Clear()
	twipe(self.itemList);
end

function AuctionHouseItemsListUtilMixin:AddItem(item)
	self.itemList[#self.itemList + 1] = item;
	return item;
end

function AuctionHouseItemsListUtilMixin:GetItem(index)
	return self.itemList[index];
end

function AuctionHouseItemsListUtilMixin:GetItems()
	return self.itemList;
end

function AuctionHouseItemsListUtilMixin:GetNumItems()
	return #self.itemList;
end

-- Bucket List Util
AuctionHouseBucketListUtilMixin = {};

function AuctionHouseBucketListUtilMixin:Init()
	self.bucketList = {};
	self.bucketType = {};
end

function AuctionHouseBucketListUtilMixin:Clear()
	twipe(self.bucketList);
	twipe(self.bucketType);
end

function AuctionHouseBucketListUtilMixin:HasExistBucket(bucketType)
	return not not self.bucketType[bucketType];
end

function AuctionHouseBucketListUtilMixin:AddBucket(bucketType, bucketData)
	if not self.bucketType[bucketType] then
		local index = #self.bucketList + 1;
		self.bucketType[bucketType] = index;
		self.bucketList[index] = bucketData;
	end
end

function AuctionHouseBucketListUtilMixin:GetBucketByIndex(index)
	return self.bucketList[index];
end

function AuctionHouseBucketListUtilMixin:GetBucketByType(bucketType)
	return self.bucketType[bucketType] and self.bucketList[self.bucketType[bucketType]];
end

function AuctionHouseBucketListUtilMixin:GetNumBuckets()
	return #self.bucketList;
end

-- Browse Util
AuctionHouseBrowseUtilMixin = CreateFromMixins(AuctionHouseBaseUtilMixin, AuctionHouseItemsListUtilMixin);

function AuctionHouseBrowseUtilMixin:Init()
	AuctionHouseBaseUtilMixin.Init(self);
	AuctionHouseItemsListUtilMixin.Init(self);

	self.extraInfo = {};
end

function AuctionHouseBrowseUtilMixin:Clear()
	AuctionHouseBaseUtilMixin.Clear(self);
	AuctionHouseItemsListUtilMixin.Clear(self);
end

function AuctionHouseBrowseUtilMixin:GetFilterInfo()
	local filtersMask = 0;
	if next(self.sorts.filters) then
		for _, filter in pairs(self.sorts.filters) do
			filtersMask = filtersMask + (BROWSE_QUERY_FILTER_MASK[filter] or 0);
		end
	else
		filtersMask = 1008;
	end

	local classID, subClassID, itemInvType = 17, 21, 29;
	if self.sorts.itemClassFilters and self.sorts.itemClassFilters[1] then
		classID = self.sorts.itemClassFilters[1].classID;

		if #self.sorts.itemClassFilters > 1 then
			subClassID = self.sorts.itemClassFilters[#self.sorts.itemClassFilters].inventoryType and self.sorts.itemClassFilters[1].subClassID or 21;
		else
			subClassID = self.sorts.itemClassFilters[1].subClassID or 21;
			itemInvType = self.sorts.itemClassFilters[1].inventoryType or 29;
		end
	end

	return filtersMask, self.sorts.searchString and lower(self.sorts.searchString) or "", self.sorts.minLevel or 0, self.sorts.maxLevel or 0, classID, subClassID, itemInvType;
end

function AuctionHouseBrowseUtilMixin:SetExtraInfo(itemKey, extraInfo)
	self.extraInfo[itemKey.itemID] = extraInfo;
end

function AuctionHouseBrowseUtilMixin:GetExtraInfo(itemKey)
	return self.extraInfo[itemKey.itemID];
end

function AuctionHouseUtil:CreateBrowse()
	return CreateAndInitFromMixin(AuctionHouseBrowseUtilMixin);
end

-- Item Search Util
AuctionHouseItemSearchUtilMixin = CreateFromMixins(AuctionHouseBaseUtilMixin, AuctionHouseBucketListUtilMixin);

function AuctionHouseItemSearchUtilMixin:Init()
	AuctionHouseBaseUtilMixin.Init(self);
	AuctionHouseBucketListUtilMixin.Init(self);

	self.quantity = 0;
	self.separateOwnerItems = false;
	self.byItemID = false;
	self.isCommodity = false;
	self.isEquipment = false;
	self.results = {};
	self.searchResult = false;
end

function AuctionHouseItemSearchUtilMixin:Clear(resetResults)
	AuctionHouseBaseUtilMixin.Clear(self);
	AuctionHouseBucketListUtilMixin.Clear(self);

	self.quantity = 0;

	if resetResults then
		self.separateOwnerItems = false;
		self.byItemID = false;
	end

	self.isCommodity = false;
	self.isEquipment = false;
	twipe(self.results);
	self.searchResult = false;
end

function AuctionHouseItemSearchUtilMixin:SetQuantity(quantity)
	self.quantity = quantity;
end

function AuctionHouseItemSearchUtilMixin:GetQuantity()
	return self.quantity or 0;
end

function AuctionHouseItemSearchUtilMixin:SetSeparateOwnerItems(separateOwnerItems)
	self.separateOwnerItems = separateOwnerItems;
end

function AuctionHouseItemSearchUtilMixin:IsSeparateOwnerItems()
	return self.separateOwnerItems;
end

function AuctionHouseItemSearchUtilMixin:SetByItemID(byItemID)
	self.byItemID = byItemID;
end

function AuctionHouseItemSearchUtilMixin:IsByItemID()
	return self.byItemID;
end

function AuctionHouseItemSearchUtilMixin:SetCommodity(isCommodity)
	self.isCommodity = isCommodity;
end

function AuctionHouseItemSearchUtilMixin:IsCommodity()
	return self.isCommodity;
end

function AuctionHouseItemSearchUtilMixin:SetEquipment(isEquipment)
	self.isEquipment = isEquipment;
end

function AuctionHouseItemSearchUtilMixin:IsEquipment()
	return self.isEquipment;
end

function AuctionHouseItemSearchUtilMixin:AddResult(result)
	tinsert(self.results, result);
end

function AuctionHouseItemSearchUtilMixin:GetResult(index)
	return self.results and self.results[index];
end

function AuctionHouseItemSearchUtilMixin:GetNumResults()
	return self.results and #self.results or 0;
end

function AuctionHouseItemSearchUtilMixin:SetSearchResult(searchResult)
	self.searchResult = searchResult;
end

function AuctionHouseItemSearchUtilMixin:HasSearchResults()
	return self.searchResult;
end

function AuctionHouseItemSearchUtilMixin:RefreshResults(index)
	if not index or index == 0 then
		AuctionHouseBucketListUtilMixin.Clear(self);
	end

	local separateOwnerItems = self:IsSeparateOwnerItems();
	local isCommodity = self:IsCommodity();
	local isEquipment = self:IsEquipment();

	for i = (index or 0) + 1, self:GetNumResults() do
		local result = self:GetResult(i);

		local auctionID = result.auctionID;
		local buyoutAmount = result.buyoutAmount;
		local bidAmount = result.bidAmount;
		local isOwnerItem = result.isOwnerItem;
		local isAccountItem = result.isAccountItem;

		self:SetMaxBuyout(buyoutAmount or 0);

		if not isCommodity then
			self:SetMaxBid(bidAmount or 0);
		end

		local isSeparate = (not isCommodity and isEquipment) or (separateOwnerItems and isOwnerItem or bidAmount);
		if isSeparate or not self:HasExistBucket(buyoutAmount) then
			if isCommodity then
				self:AddBucket(isSeparate and auctionID or buyoutAmount, {
					itemID = result.itemID,
					quantity = result.quantity,
					unitPrice = buyoutAmount,
					auctionID = auctionID,
					owners = {result.owner},
					totalNumberOfOwners = 1,
					timeLeftSeconds	= result.timeLeftSeconds,
					numOwnerItems = (isOwnerItem or isAccountItem) and result.quantity or 0,
					containsOwnerItem = isOwnerItem,
					containsAccountItem = isAccountItem,
				});
			else
				self:AddBucket(isSeparate and auctionID or buyoutAmount, {
					itemKey = {itemID = result.itemID, itemLevel = result.itemLevel, itemSuffix = result.itemSuffix},
					owners = {result.owner},
					totalNumberOfOwners = 1,
					timeLeft = result.timeLeft,
					auctionID = auctionID,
					quantity = result.quantity,
					itemLink = result.itemLink,
					containsOwnerItem = isOwnerItem,
					containsAccountItem = isAccountItem,
					containsSocketedItem = result.isSocketedItem,
					bidder = result.bidder,
					minBid = result.minBid,
					bidAmount = result.bidAmount,
					buyoutAmount = result.buyoutAmount ~= 0 and result.buyoutAmount or nil,
					timeLeftSeconds = result.timeLeftSeconds,
				});
			end
		else
			local bucket = self:GetBucketByType(buyoutAmount);
			if bucket then
				bucket.quantity = bucket.quantity + result.quantity;

				if isOwnerItem or isAccountItem then
					if isCommodity then
						bucket.numOwnerItems = bucket.numOwnerItems + result.quantity;
					end

					if not bucket.containsOwnerItem or not bucket.containsAccountItem then
						if isOwnerItem and not bucket.containsOwnerItem then
							bucket.containsOwnerItem = isOwnerItem;
						end

						if isAccountItem and not bucket.containsAccountItem then
							bucket.containsAccountItem = isAccountItem;
						end

						if bucket.containsAccountItem or bucket.containsOwnerItem then
							tinsert(bucket.owners, 1, result.owner);
						end
					end
				else
					local foundOwner;
					for j = 1, #bucket.owners do
						if bucket.owners[j] == result.owner then
							foundOwner = true;
							break;
						end
					end

					if not foundOwner then
						tinsert(bucket.owners, result.owner);
					end
				end

				bucket.totalNumberOfOwners = #bucket.owners;
			end
		end
	end
end

-- Search Util
AuctionHouseSearchUtilMixin = {};

function AuctionHouseSearchUtilMixin:Init()
	self.items = {};
end

function AuctionHouseSearchUtilMixin:Clear()
	for itemID in pairs(self.items) do
		for itemSuffix in pairs(self.items[itemID]) do
			self.items[itemID][itemSuffix]:Clear(true);
		end
	end
end

function AuctionHouseSearchUtilMixin:GetItem(itemID, itemSuffix)
	itemSuffix = itemSuffix or 0;

	if not self.items[itemID] then
		self.items[itemID] = {};
	end

	if not self.items[itemID][itemSuffix] then
		self.items[itemID][itemSuffix] = CreateAndInitFromMixin(AuctionHouseItemSearchUtilMixin);
	end

	return self.items[itemID][itemSuffix];
end

function AuctionHouseSearchUtilMixin:HasSearchResults(itemKey)
	return self.searchResult[itemKey.itemID] and self.searchResult[itemKey.itemID][itemKey.itemSuffix];
end

function AuctionHouseUtil:CreateSearch()
	return CreateAndInitFromMixin(AuctionHouseSearchUtilMixin);
end

-- Auctions Util
AuctionHouseAuctionsUtilMixin = CreateFromMixins(AuctionHouseBaseUtilMixin, AuctionHouseItemsListUtilMixin, AuctionHouseBucketListUtilMixin);

function AuctionHouseAuctionsUtilMixin:Init()
	AuctionHouseBaseUtilMixin.Init(self);
	AuctionHouseItemsListUtilMixin.Init(self);
	AuctionHouseBucketListUtilMixin.Init(self);
end

function AuctionHouseAuctionsUtilMixin:Clear()
	AuctionHouseBaseUtilMixin.Clear(self);
	AuctionHouseItemsListUtilMixin.Clear(self);
	AuctionHouseBucketListUtilMixin.Clear(self);
end

function AuctionHouseUtil:CreateAuctions()
	return CreateAndInitFromMixin(AuctionHouseAuctionsUtilMixin);
end

-- Post Util
AuctionHousePostUtilMixin = {};

function AuctionHousePostUtilMixin:Init()

end

function AuctionHousePostUtilMixin:Clear()
	self.bid, self.buyout, self.duration, self.quantity, self.itemID = nil, nil, nil, nil, nil;
	self.multiSale = nil;
	self.progress = 0;
end

function AuctionHousePostUtilMixin:SetInfo(bid, buyout, duration, quantity, itemID)
	self.bid, self.buyout, self.duration, self.quantity, self.itemID = bid, buyout, duration, quantity, itemID;
end

function AuctionHousePostUtilMixin:GetInfo()
	return self.bid, self.buyout, self.duration, self.quantity, self.itemID;
end

function AuctionHousePostUtilMixin:SetMultiSale(multiSale)
	self.multiSale = multiSale;
end

function AuctionHousePostUtilMixin:IsMultiSelling()
	return self.multiSale;
end

function AuctionHousePostUtilMixin:SetProgress(progress)
	self.progress = (self.progress or 0) + progress;
end

function AuctionHousePostUtilMixin:GetProgress()
	return self.progress;
end

function AuctionHouseUtil:CreatePost()
	return CreateAndInitFromMixin(AuctionHousePostUtilMixin);
end

local ACTION_HOUSE_NPC_GUID;

local THROTTLED_MESSAGE_RESULT = {};
local THROTTLED_MESSAGE_QUEUE;
local THROTTLED_MESSAGE_DELAY;
local THROTTLED_MESSAGE_RESPONSE_RECEIVED = true;
local THROTTLED_MESSAGE_SYSTEM_READY = true;

local CheckThrottledMessage

local function SendServerThrottledMessage(func, ...)
	if not THROTTLED_MESSAGE_RESPONSE_RECEIVED then
		if THROTTLED_MESSAGE_QUEUE then
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED);
		end

		THROTTLED_MESSAGE_QUEUE = {func, ...};

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED);

		return;
	end

	THROTTLED_MESSAGE_SYSTEM_READY = false;

	if type(func) == "string" then
		SendServerMessage(func, ...);

		THROTTLED_MESSAGE_RESPONSE_RECEIVED = false;

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_SENT);

		if func == "ACMSG_AUCTION_SET_FAVORITE_ITEM" or func == "ACMSG_AUCTION_CANCEL_COMMODITIES_PURCHASE" then
			CheckThrottledMessage(300);
		end

		return;
	elseif type(func) == "function" and func(...) then
		THROTTLED_MESSAGE_RESPONSE_RECEIVED = false;

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_SENT);

		return;
	end

	if not THROTTLED_MESSAGE_SYSTEM_READY then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_SENT);

		THROTTLED_MESSAGE_RESPONSE_RECEIVED = true;
		THROTTLED_MESSAGE_SYSTEM_READY = true;

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_SYSTEM_READY);
	end
end

local timer = CreateFrame("Frame")
timer:SetScript("OnUpdate", function(_, elapsed)
	if THROTTLED_MESSAGE_DELAY then
		THROTTLED_MESSAGE_DELAY = THROTTLED_MESSAGE_DELAY - elapsed;

		if THROTTLED_MESSAGE_DELAY < 0 then
			timer:Hide();

			THROTTLED_MESSAGE_RESPONSE_RECEIVED = true;

			if not THROTTLED_MESSAGE_QUEUE then
				THROTTLED_MESSAGE_SYSTEM_READY = true;

				FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_SYSTEM_READY);
			else
				local currentQueuedMessage = THROTTLED_MESSAGE_QUEUE;
				THROTTLED_MESSAGE_QUEUE = nil;
				SendServerThrottledMessage(unpack(currentQueuedMessage));
			end
		end
	end
end)

function CheckThrottledMessage(desiredDelay)
	if not desiredDelay or desiredDelay <= 3000 then
		desiredDelay = 500;
	end

	if desiredDelay then
		THROTTLED_MESSAGE_DELAY = desiredDelay / 1000;

		timer:Show()
	end
end

local function delayedFramePool_OnRelease(framePool, frame)
	frame.args = nil;
	frame:SetScript("OnUpdate", nil);
	frame:Hide();
end

local delayedFramePool = CreateFramePool("Frame", nil, nil, delayedFramePool_OnRelease);

local function delayedFramePool_OnUpdate(self)
	if type(self.args) == "table" and #self.args > 0 then
		FireCustomClientEvent(unpack(self.args));
	end

	delayedFramePool:Release(self);
end

local function FireDelayedCustomClientEvent(...)
	local frame = delayedFramePool:Acquire();
	frame.args = {...};
	frame:SetScript("OnUpdate", delayedFramePool_OnUpdate);
	frame:Show();
end

local MAXIMUM_BID_PRICE = 2000000000;

local AUCTION_HOUSE_BIND_TYPES = {
	[ITEM_SOULBOUND] = 0,
	[ITEM_BIND_TO_ACCOUNT] = 0,
	[ITEM_BIND_ON_PICKUP] = 0,
	[ITEM_BIND_QUEST] = 0,
	[ITEM_BIND_ON_EQUIP] = 1,
	[ITEM_BIND_ON_USE] = 1,
	[ITEM_STARTS_QUEST] = 1,
};

local TIME_LEFT_BAND_INFO = {
	[0] = {min = 0,     max = 1800},
	[1] = {min = 1800,  max = 7200},
	[2] = {min = 7200,  max = 43200},
	[3] = {min = 43200, max = 172800},
}

local AUCTION_HOUSE_ITEM_SUB_CLASSES = {
	[LE_ITEM_CLASS_CONSUMABLE] = {5, 1, 2, 3, 7, 6, 4, 8},
	[LE_ITEM_CLASS_CONTAINER] = {0, 1, 2, 3, 4, 5, 6, 7, 8},
	[LE_ITEM_CLASS_WEAPON] = {
		LE_ITEM_WEAPON_AXE1H, LE_ITEM_WEAPON_AXE2H, LE_ITEM_WEAPON_BOWS, LE_ITEM_WEAPON_GUNS, LE_ITEM_WEAPON_MACE1H, LE_ITEM_WEAPON_MACE2H,
		LE_ITEM_WEAPON_POLEARM, LE_ITEM_WEAPON_SWORD1H, LE_ITEM_WEAPON_SWORD2H, LE_ITEM_WEAPON_STAFF, LE_ITEM_WEAPON_UNARMED, LE_ITEM_WEAPON_GENERIC,
		LE_ITEM_WEAPON_DAGGER, LE_ITEM_WEAPON_THROWN, LE_ITEM_WEAPON_CROSSBOW, LE_ITEM_WEAPON_WAND, LE_ITEM_WEAPON_FISHINGPOLE
	},
	[LE_ITEM_CLASS_GEM] = {0, 1, 2, 3, 4, 5, 6, 7, 8},
	[LE_ITEM_CLASS_ARMOR] = {
		LE_ITEM_ARMOR_GENERIC, LE_ITEM_ARMOR_CLOTH, LE_ITEM_ARMOR_LEATHER, LE_ITEM_ARMOR_MAIL, LE_ITEM_ARMOR_PLATE, LE_ITEM_ARMOR_COSMETIC,
		LE_ITEM_ARMOR_SHIELD, LE_ITEM_ARMOR_LIBRAM, LE_ITEM_ARMOR_IDOL, LE_ITEM_ARMOR_TOTEM, LE_ITEM_ARMOR_SIGIL
	},
	[LE_ITEM_CLASS_AMMO] = {2, 3},
	[LE_ITEM_CLASS_TRADEGOODS] = {10, 5, 6, 7, 8, 9, 12, 4, 1, 3, 2, 13, 11, 14, 15},
	[LE_ITEM_CLASS_RECIPE] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
	[LE_ITEM_CLASS_QUIVER] = {2, 3},
	[LE_ITEM_CLASS_QUESTITEM] = {0},
	[LE_ITEM_CLASS_MISCELLANEOUS] = {LE_ITEM_MISCELLANEOUS_JUNK, LE_ITEM_MISCELLANEOUS_REAGENT, LE_ITEM_MISCELLANEOUS_MOUNT, LE_ITEM_MISCELLANEOUS_PET, LE_ITEM_MISCELLANEOUS_HOLIDAY, LE_ITEM_MISCELLANEOUS_OTHER},
	[LE_ITEM_CLASS_GLYPH] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 11},
	[8] = {0}, -- Toy
};

local AUCTION_FAVORITE_ITEMS = {};
local MAX_COUNT_FAVORITES_ITEMS = 100;
local HAS_FAVORITES_ITEMS_AVAILABLE = true;

local COMMODITY_QUOTE_TIME;

SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS = {};

local ITEMS_CACHE_NAME = GetLocale() == "ruRU" and 2 or 1;
local ITEMS_CACHE_RARITY = 3;
local ITEMS_CACHE_MINLEVEL = 5;
local ITEMS_CACHE_TYPE = 6;
local ITEMS_CACHE_SUBTYPE = 7;
local ITEMS_CACHE_STACK_COUNT = 8;
local ITEMS_CACHE_TEXTURE = 10;

local browse = AuctionHouseUtil:CreateBrowse();
local search = AuctionHouseUtil:CreateSearch();
local ownerAuction = AuctionHouseUtil:CreateAuctions();
local bids = AuctionHouseUtil:CreateAuctions();
local post = AuctionHouseUtil:CreatePost();

local scanTooltip = CreateFrame("GameTooltip", "AuctionHouseUtilScanTooltip");

C_AuctionHouse = {};

function C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity)
	if not itemID or not duration or not quantity then
		error("Usage: local depositCost = C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'CalculateCommodityDeposit' (outside of expected range -2147483648 to 2147483647 - Usage: local depositCost = C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity))", 2);
	end
	if type(duration) == "string" then
		duration = tonumber(duration);
	end
	if type(duration) ~= "number" then
		error("bad argument #2 to 'CalculateCommodityDeposit' (outside of expected range 0 to 4294967295 - Usage: local depositCost = C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity))", 2);
	end
	if type(quantity) == "string" then
		quantity = tonumber(quantity);
	end
	if type(quantity) ~= "number" then
		error("bad argument #3 to 'CalculateCommodityDeposit' (outside of expected range 0 to 4294967295 - Usage: local depositCost = C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity))", 2);
	end

	local sellPrice = select(11, GetItemInfo(itemID));
	if not sellPrice then
		return COPPER_PER_SILVER;
	end

	return (ceil(floor(max(0.15 * quantity * sellPrice, 100)) / COPPER_PER_SILVER) * COPPER_PER_SILVER) * (AUCTION_HOUSE_DURATION[duration or 1] / AUCTION_HOUSE_DURATION[1]);
end

function C_AuctionHouse.CalculateItemDeposit(item, duration, quantity)
	if not item or not duration or not quantity then
		error("Usage: local depositCost = C_AuctionHouse.CalculateItemDeposit(item, duration, quantity)", 2);
	end
	if type(item) ~= "table" then
		error("bad argument #1 to 'CalculateItemDeposit' (Usage: local depositCost = C_AuctionHouse.CalculateItemDeposit(item, duration, quantity))", 2);
	end
	if type(duration) == "string" then
		duration = tonumber(duration);
	end
	if type(duration) ~= "number" then
		error("bad argument #2 to 'CalculateItemDeposit' (outside of expected range 0 to 4294967295 - Usage: local depositCost = C_AuctionHouse.CalculateItemDeposit(item, duration, quantity))", 2);
	end
	if type(quantity) == "string" then
		quantity = tonumber(quantity);
	end
	if type(quantity) ~= "number" then
		error("bad argument #3 to 'CalculateItemDeposit' (outside of expected range 0 to 4294967295 - Usage: local depositCost = C_AuctionHouse.CalculateItemDeposit(item, duration, quantity))", 2);
	end

	local isValid = item:IsValid();
	if isValid then
		local sellPrice = select(11, GetItemInfo(isValid));
		if sellPrice then
			return (ceil(floor(max(0.15 * quantity * sellPrice, 100)) / COPPER_PER_SILVER) * COPPER_PER_SILVER) * (AUCTION_HOUSE_DURATION[duration or 1] / AUCTION_HOUSE_DURATION[1]);
		else
			return COPPER_PER_SILVER;
		end
	end

	return COPPER_PER_SILVER;
end

function C_AuctionHouse.CanCancelAuction(ownedAuctionID)
	if not ownerAuction then
		error("Usage: local canCancelAuction = C_AuctionHouse.CanCancelAuction(ownedAuctionID)", 2);
	end
	if type(ownedAuctionID) == "string" then
		ownedAuctionID = tonumber(ownedAuctionID);
	end
	if type(ownedAuctionID) ~= "number" then
		error("bad argument #1 to 'CanCancelAuction' (outside of expected range -2147483648 to 2147483647 - Usage: local canCancelAuction = C_AuctionHouse.CanCancelAuction(ownedAuctionID))", 2);
	end

	for ownedAuctionIndex = 1, ownerAuction:GetNumItems() do
		local ownedAuctionInfo = ownerAuction:GetItem(ownedAuctionIndex);
		if ownedAuctionInfo.auctionID == ownedAuctionID then
			return true;
		end
	end

	return false;
end

local function CancelAuction(ownedAuctionID)
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_REMOVE_ITEM", format("%s:%s", ACTION_HOUSE_NPC_GUID, ownedAuctionID));

		return true;
	end
end

function C_AuctionHouse.CancelAuction(ownedAuctionID)
	if not ownedAuctionID then
		error("Usage: C_AuctionHouse.CancelAuction(ownedAuctionID)", 2);
	end
	if type(ownedAuctionID) == "string" then
		ownedAuctionID = tonumber(ownedAuctionID);
	end
	if type(ownedAuctionID) ~= "number" then
		error("bad argument #1 to 'CancelAuction' (outside of expected range -2147483648 to 2147483647 - Usage: C_AuctionHouse.CancelAuction(ownedAuctionID))", 2);
	end

	SendServerThrottledMessage(CancelAuction, ownedAuctionID);
end

function C_AuctionHouse.CancelCommoditiesPurchase()
	SendServerMessage("ACMSG_AUCTION_CANCEL_COMMODITIES_PURCHASE", format("%s", ACTION_HOUSE_NPC_GUID));

	COMMODITY_QUOTE_TIME = nil;
end

function C_AuctionHouse.CancelSell()
	if post:IsMultiSelling() then
		post:Clear();

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_MULTISELL_FAILURE);
	end
end

function C_AuctionHouse.CloseAuctionHouse()
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_CLOSE", ACTION_HOUSE_NPC_GUID);
	end

	THROTTLED_MESSAGE_RESPONSE_RECEIVED = true;
	THROTTLED_MESSAGE_QUEUE = nil;
	THROTTLED_MESSAGE_SYSTEM_READY = true;
end

local function ConfirmCommoditiesPurchase(itemID, quantity)
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_CONFIRM_COMMODITIES_PURCHASE", format("%s:%d:%d", ACTION_HOUSE_NPC_GUID, itemID, quantity));

		return true;
	end
end

function C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity)
	if not itemID or not quantity then
		error("Usage: C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity)", 2);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'ConfirmCommoditiesPurchase' (outside of expected range -2147483648 to 2147483647 - Usage: C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity))", 2);
	end
	if type(quantity) ~= "number" then
		error("bad argument #2 to 'ConfirmCommoditiesPurchase' (outside of expected range 0 to 4294967295 - Usage: C_AuctionHouse.ConfirmCommoditiesPurchase(itemID, quantity))", 2);
	end

	SendServerThrottledMessage(ConfirmCommoditiesPurchase, itemID, quantity);
end

function C_AuctionHouse.FavoritesAreAvailable()
	return HAS_FAVORITES_ITEMS_AVAILABLE;
end

function C_AuctionHouse.GetAuctionItemSubClasses(classID)
	if not classID then
		error("Usage: local subClasses = C_AuctionHouse.GetAuctionItemSubClasses(classID)", 2);
	end
	if type(classID) == "string" then
		classID = tonumber(classID);
	end
	if type(classID) ~= "number" then
		error("bad argument #1 to 'GetAuctionItemSubClasses' (outside of expected range -2147483648 to 2147483647 - Usage: local subClasses = C_AuctionHouse.GetAuctionItemSubClasses(classID))", 2);
	end

	local subClasses = {};

	if AUCTION_HOUSE_ITEM_SUB_CLASSES[classID] then
		for index = 1, #AUCTION_HOUSE_ITEM_SUB_CLASSES[classID] do
			subClasses[index] = AUCTION_HOUSE_ITEM_SUB_CLASSES[classID][index];
		end
	end

	return subClasses;
end

local LOCKED_WITH_SPELL = string.gsub(LOCKED_WITH_SPELL, "%%s", "");

local function IsSellItemValid(bagID, slotID)
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
	scanTooltip:ClearLines();
	scanTooltip:SetBagItem(bagID, slotID);
	scanTooltip:Show();

	local obj = AuctionHouseUtilScanTooltipTextLeft1;
	if not obj then
		return false;
	end

	local text = obj:GetText();
	if text == RETRIEVING_ITEM_INFO then
		return false;
	end

	if AUCTION_HOUSE_BIND_TYPES[text] == 0 then
		return false;
	end

	local foundLockbox;

	local bindLines = ENABLE_COLORBLIND_MODE == "1" and 5 or 4;

	for i = 2, scanTooltip:NumLines() do
		obj = _G["AuctionHouseUtilScanTooltipTextLeft"..i];
		if not obj then
			return true;
		end

		text = obj:GetText();

		if text == LOCKED or text == ITEM_OPENABLE or string.find(text, LOCKED_WITH_SPELL) then
			if not foundLockbox then
				local itemID = GetContainerItemID(bagID, slotID);
				local itemCache = itemID and ItemsCache[itemID];

				if itemCache and itemCache[ITEMS_CACHE_TYPE] == 15 and itemCache[ITEMS_CACHE_SUBTYPE] == 0 then
					return true, true;
				end
			end

			foundLockbox = true;
		end

		if i <= bindLines and AUCTION_HOUSE_BIND_TYPES[text] == 0 then
			return false;
		end
	end

	return true;
end

function C_AuctionHouse.GetAvailablePostCount(item)
	if not item then
		error("Usage: local listCount = C_AuctionHouse.GetAvailablePostCount(item)", 2);
	end
	if type(item) ~= "table" then
		error("bad argument #1 to 'GetAvailablePostCount' (Usage: local listCount = C_AuctionHouse.GetAvailablePostCount(item))", 2);
	end

	local itemID = item:IsValid();
	if not itemID then
		return 1;
	end

	local postCount = 0;
	for bagID = 0, NUM_BAG_SLOTS do
		for slotID = 1, GetContainerNumSlots(bagID) do
			if itemID == GetContainerItemID(bagID, slotID) and IsSellItemValid(bagID, slotID) then
				local _, itemCount = GetContainerItemInfo(bagID, slotID);
				postCount = postCount + itemCount;
			end
		end
	end

	return postCount;
end

function C_AuctionHouse.GetBidInfo(bidIndex)
	if not bidIndex then
		error("Usage: local bid = C_AuctionHouse.GetBidInfo(bidIndex)", 2);
	end
	if type(bidIndex) == "string" then
		bidIndex = tonumber(bidIndex);
	end
	if type(bidIndex) ~= "number" then
		error("bad argument #1 to 'GetBidInfo' (outside of expected range 0 to 4294967295 - Usage: local bid = C_AuctionHouse.GetBidInfo(bidIndex))", 2);
	end

	local bidInfo = bids:GetItem(bidIndex);
	if bidInfo then
		return CopyTable(bidInfo);
	end
end

function C_AuctionHouse.GetBidType(bidTypeIndex)
	if not bidTypeIndex then
		error("Usage: local typeItemKey = C_AuctionHouse.GetBidType(bidTypeIndex)", 2);
	end
	if type(bidTypeIndex) == "string" then
		bidTypeIndex = tonumber(bidTypeIndex);
	end
	if type(bidTypeIndex) ~= "number" then
		error("bad argument #1 to 'GetBidType' (outside of expected range 0 to 4294967295 - Usage: local typeItemKey = C_AuctionHouse.GetBidType(bidTypeIndex))", 2);
	end

	local bidType = bids:GetBucketByIndex(bidTypeIndex);
	if bidType then
		return CopyTable(bidType);
	end
end

function C_AuctionHouse.GetBrowseResults()
	return CopyTable(browse:GetItems());
end

function C_AuctionHouse.GetCancelCost(ownedAuctionID)
	if type(ownedAuctionID) == "string" then
		ownedAuctionID = tonumber(ownedAuctionID);
	end
	if type(ownedAuctionID) ~= "number" then
		error("Usage: local cancelCost = C_AuctionHouse.GetCancelCost(ownedAuctionID)", 2);
	end

	for ownedAuctionIndex = 1, ownerAuction:GetNumItems() do
		local ownedAuctionInfo = ownerAuction:GetItem(ownedAuctionIndex);
		if ownedAuctionInfo.auctionID == ownedAuctionID then
			local bidder = ownedAuctionInfo.bidder;
			local cost = bidder and bidder ~= "" and ownedAuctionInfo.bidAmount;
			return cost and cost * 0.05 or 0;
		end
	end

	return 0;
end

function C_AuctionHouse.GetCommoditySearchResultInfo(itemID, commoditySearchResultIndex)
	if not itemID or not commoditySearchResultIndex then
		error("Usage: local result = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, commoditySearchResultIndex)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'GetCommoditySearchResultInfo' (outside of expected range -2147483648 to 2147483647 - Usage: local result = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, commoditySearchResultIndex))", 2);
	end
	if type(commoditySearchResultIndex) == "string" then
		commoditySearchResultIndex = tonumber(commoditySearchResultIndex);
	end
	if type(commoditySearchResultIndex) ~= "number" then
		error("bad argument #2 to 'GetCommoditySearchResultInfo' (outside of expected range 0 to 4294967295 - Usage: local result = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, commoditySearchResultIndex))", 2);
	end

	local commoditySearchResultInfo = search:GetItem(itemID):GetBucketByIndex(commoditySearchResultIndex);
	if commoditySearchResultInfo then
		return CopyTable(commoditySearchResultInfo);
	end
end

function C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID)
	if not itemID then
		error("Usage: local totalQuantity = C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'GetCommoditySearchResultsQuantity' (outside of expected range -2147483648 to 2147483647 - Usage: local totalQuantity = C_AuctionHouse.GetCommoditySearchResultsQuantity(itemID))", 2);
	end

	return search:GetItem(itemID):GetQuantity();
end

function C_AuctionHouse.GetExtraBrowseInfo(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local extraInfo = C_AuctionHouse.GetExtraBrowseInfo(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return browse:GetExtraInfo(itemKey);
end

function C_AuctionHouse.GetFilterGroups()
	return {
		{
			filters = {
				Enum.AuctionHouseFilter.UncollectedOnly,
				Enum.AuctionHouseFilter.UsableOnly
			},
			category = 0
		},
		{
			filters = {
				Enum.AuctionHouseFilter.PoorQuality,
				Enum.AuctionHouseFilter.CommonQuality,
				Enum.AuctionHouseFilter.UncommonQuality,
				Enum.AuctionHouseFilter.RareQuality,
				Enum.AuctionHouseFilter.EpicQuality,
				Enum.AuctionHouseFilter.LegendaryQuality
			},
			category = 1
		}
	};
end

function C_AuctionHouse.GetItemCommodityStatus(item)
	if not item then
		error("Usage: local isCommodity = C_AuctionHouse.GetItemCommodityStatus(item)", 2);
	end
	if type(item) ~= "table" then
		error("bad argument #1 to 'GetItemCommodityStatus' (Usage: local isCommodity = C_AuctionHouse.GetItemCommodityStatus(item))", 2);
	end

	local bagID, slotID = item:GetBagAndSlot();
	if bagID and slotID then
		local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(GetContainerItemID(bagID, slotID))
		return itemStackCount and (itemStackCount > 1 and 2 or 1) or 0
	end

	if item:IsEquipmentSlot() then
		return 1;
	end

	return 0;
end

function C_AuctionHouse.GetItemKeyFromItem(item)
	if not item then
		error("Usage: local itemKey = C_AuctionHouse.GetItemKeyFromItem(item)", 2);
	end
	if type(item) ~= "table" then
		error("bad argument #1 to 'GetItemKeyFromItem' (Usage: local itemKey = C_AuctionHouse.GetItemKeyFromItem(item))", 2);
	end

	local bagID, slotID = item:GetBagAndSlot();
	if bagID and slotID then
		local itemID = GetContainerItemID(bagID, slotID);
		if itemID then
			local _, itemLevel, itemSuffix;
			_, _, _, itemLevel = GetItemInfo(itemID);

			local itemLink = GetContainerItemLink(bagID, slotID);
			if itemLink then
				_, _, _, _, _, _, _, _, _, _, itemSuffix = find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
			end

			return {
				itemID = itemID,
				itemLevel = itemLevel or 0,
				itemSuffix = tonumber(itemSuffix) or 0,
			};
		end
	end

	local equipmentSlotIndex = item:GetEquipmentSlot();
	if equipmentSlotIndex then
		local itemID = GetInventoryItemID("player", equipmentSlotIndex);
		if itemID then
			local _, itemLevel, itemSuffix;
			_, _, _, itemLevel = GetItemInfo(itemID);

			local itemLink = GetInventoryItemLink("player", equipmentSlotIndex);
			if itemLink then
				_, _, _, _, _, _, _, _, _, _, itemSuffix = find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");
			end

			return {
				itemID = itemID,
				itemLevel = itemLevel or 0,
				itemSuffix = tonumber(itemSuffix) or 0,
			};
		end
	end
end

local ITEM_KEY_INFO = {};

local function GetItemKeyInfo(itemKey, restrictQualityToFilter)
	local itemID = itemKey.itemID;
	local itemSuffix = itemKey.itemSuffix or 0;

	if not ITEM_KEY_INFO[itemID] then ITEM_KEY_INFO[itemID] = {}; end
	if not ITEM_KEY_INFO[itemID][itemSuffix] then ITEM_KEY_INFO[itemID][itemSuffix] = {}; end

	local itemLink = itemSuffix == 0 and format("item:%d", itemID) or format("item:%d:%d:::::%d", itemID, itemKey.enchantID or 0, itemKey.enchantID and (itemKey.uniqueID or -itemSuffix) or 0);
	local itemName, _, itemRarity, _, itemMinLevel, itemType, _, itemStackCount, _, itemTexture = GetItemInfo(itemLink);

	if not itemName then
		local itemCache = ItemsCache[itemID];
		if itemCache then
			itemName = itemCache[ITEMS_CACHE_NAME];
			itemRarity = itemCache[ITEMS_CACHE_RARITY];
			itemMinLevel = itemCache[ITEMS_CACHE_MINLEVEL];
			itemType = _G[format("ITEM_CLASS_%d", itemCache[ITEMS_CACHE_TYPE])];
			itemStackCount = itemCache[ITEMS_CACHE_STACK_COUNT];
			itemTexture = format("Interface/ICONS/%s", itemCache[ITEMS_CACHE_TEXTURE]);
		else
			itemName, itemRarity, itemMinLevel, itemType, itemStackCount, itemTexture = "", 1, "", "", 0, "Interface\\ICONS\\INV_Misc_QuestionMark";
		end

		scanTooltip:SetHyperlink(itemLink);
	end

	local itemKeyInfo = ITEM_KEY_INFO[itemID][itemSuffix];
	if itemKeyInfo.itemName ~= itemName then
		itemKeyInfo.itemName = itemName or "";
		itemKeyInfo.isCommodity = itemStackCount and itemStackCount > 1;
		itemKeyInfo.isEquipment = itemType and (ITEM_CLASS_2 == itemType or ITEM_CLASS_4 == itemType);
		itemKeyInfo.iconFileID = itemTexture or "Interface\\ICONS\\INV_Misc_QuestionMark";
		itemKeyInfo.quality = itemRarity or 1;
		itemKeyInfo.itemMinLevel = itemMinLevel or 1;
	end

	return itemKeyInfo;
end

function C_AuctionHouse.GetItemKeyInfo(itemKey, restrictQualityToFilter)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey [, restrictQualityToFilter])", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return GetItemKeyInfo(itemKey, restrictQualityToFilter);
end

function C_AuctionHouse.GetItemSearchResultInfo(itemKey, itemSearchResultIndex)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") or type(itemSearchResultIndex) ~= "number" then
		error("Usage: local result = C_AuctionHouse.GetItemSearchResultInfo(itemKey, itemSearchResultIndex)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	local itemSearchResultInfo = search:GetItem(itemKey.itemID, itemKey.itemSuffix):GetBucketByIndex(itemSearchResultIndex);
	if itemSearchResultInfo then
		return CopyTable(itemSearchResultInfo);
	end
end

function C_AuctionHouse.GetItemSearchResultsQuantity(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local totalQuantity = C_AuctionHouse.GetItemSearchResultsQuantity(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return search:GetItem(itemKey.itemID, itemKey.itemSuffix):GetQuantity();
end

function C_AuctionHouse.GetMaxBidItemBid()
	return bids:GetMaxBid();
end

function C_AuctionHouse.GetMaxBidItemBuyout()
	return bids:GetMaxBuyout();
end

function C_AuctionHouse.GetMaxCommoditySearchResultPrice(itemID)
	if not itemID then
		error("Usage: local maxUnitPrice = C_AuctionHouse.GetMaxCommoditySearchResultPrice(itemID)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'GetMaxCommoditySearchResultPrice' (outside of expected range -2147483648 to 2147483647 - Usage: local maxUnitPrice = C_AuctionHouse.GetMaxCommoditySearchResultPrice(itemID))", 2);
	end

	return search:GetItem(itemID):GetMaxBuyout(itemID);
end

function C_AuctionHouse.GetMaxItemSearchResultBid(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local maxBid = C_AuctionHouse.GetMaxItemSearchResultBid(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return search:GetItem(itemKey.itemID, itemKey.itemSuffix):GetMaxBid();
end

function C_AuctionHouse.GetMaxItemSearchResultBuyout(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local maxBuyout = C_AuctionHouse.GetMaxItemSearchResultBuyout(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return search:GetItem(itemKey.itemID, itemKey.itemSuffix):GetMaxBuyout(itemKey);
end

function C_AuctionHouse.GetMaxOwnedAuctionBid()
	return ownerAuction:GetMaxBid();
end

function C_AuctionHouse.GetMaxOwnedAuctionBuyout()
	return ownerAuction:GetMaxBuyout();
end

function C_AuctionHouse.GetNumBidTypes()
	return bids:GetNumBuckets();
end

function C_AuctionHouse.GetNumBids()
	return bids:GetNumItems();
end

function C_AuctionHouse.GetNumCommoditySearchResults(itemID)
	if not itemID then
		error("Usage: local maxBid = C_AuctionHouse.GetMaxItemSearchResultBid(itemKey)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'GetNumCommoditySearchResults' (outside of expected range -2147483648 to 2147483647 - Usage: local numSearchResults = C_AuctionHouse.GetNumCommoditySearchResults(itemID))", 2);
	end

	return search:GetItem(itemID):GetNumBuckets();
end

function C_AuctionHouse.GetNumItemSearchResults(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local numItemSearchResults = C_AuctionHouse.GetNumItemSearchResults(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return search:GetItem(itemKey.itemID, itemKey.itemSuffix):GetNumBuckets();
end

function C_AuctionHouse.GetNumOwnedAuctionTypes()
	return ownerAuction:GetNumBuckets();
end

function C_AuctionHouse.GetNumOwnedAuctions()
	return ownerAuction:GetNumItems();
end

function C_AuctionHouse.GetNumReplicateItems()

end

function C_AuctionHouse.GetOwnedAuctionInfo(ownedAuctionIndex)
	if not ownedAuctionIndex then
		error("Usage: local ownedAuction = C_AuctionHouse.GetOwnedAuctionInfo(ownedAuctionIndex)")
	end
	if type(ownedAuctionIndex) == "string" then
		ownedAuctionIndex = tonumber(ownedAuctionIndex);
	end
	if type(ownedAuctionIndex) ~= "number" then
		error("bad argument #1 to 'GetOwnedAuctionInfo' (outside of expected range 0 to 4294967295 - Usage: local ownedAuction = C_AuctionHouse.GetOwnedAuctionInfo(ownedAuctionIndex))", 2);
	end

	local ownedAuctionInfo = ownerAuction:GetItem(ownedAuctionIndex);
	if ownedAuctionInfo then
		return CopyTable(ownedAuctionInfo);
	end
end

function C_AuctionHouse.GetOwnedAuctionType(ownedAuctionTypeIndex)
	if not ownedAuctionTypeIndex then
		error("Usage: local typeItemKey = C_AuctionHouse.GetOwnedAuctionType(ownedAuctionTypeIndex)")
	end
	if type(ownedAuctionTypeIndex) == "string" then
		ownedAuctionTypeIndex = tonumber(ownedAuctionTypeIndex);
	end
	if type(ownedAuctionTypeIndex) ~= "number" then
		error("bad argument #1 to 'GetOwnedAuctionType' (outside of expected range 0 to 4294967295 - Usage: local typeItemKey = C_AuctionHouse.GetOwnedAuctionType(ownedAuctionTypeIndex))", 2);
	end

	local ownedAuctionType = ownerAuction:GetBucketByIndex(ownedAuctionTypeIndex);
	if ownedAuctionType then
		return CopyTable(ownedAuctionType);
	end
end

function C_AuctionHouse.GetQuoteDurationRemaining()
	if COMMODITY_QUOTE_TIME then
		local queryTime = COMMODITY_QUOTE_TIME - GetTime();
		if queryTime > 0 then
			return floor(queryTime);
		else
			COMMODITY_QUOTE_TIME = nil;

			return 0;
		end
	end
	return 0;
end

function C_AuctionHouse.GetReplicateItemInfo(index)

end

function C_AuctionHouse.GetReplicateItemLink(index)

end

function C_AuctionHouse.GetReplicateItemTimeLeft(index)

end

function C_AuctionHouse.GetTimeLeftBandInfo(timeLeftBand)
	if not timeLeftBand then
		error("Usage: local timeLeftMinSeconds, timeLeftMaxSeconds = C_AuctionHouse.GetTimeLeftBandInfo(timeLeftBand)", 2);
	end
	if type(timeLeftBand) == "string" then
		timeLeftBand = tonumber(timeLeftBand);
	end
	if type(timeLeftBand) ~= "number" then
		error("bad argument #1 to 'GetTimeLeftBandInfo' (Usage: local timeLeftMinSeconds, timeLeftMaxSeconds = C_AuctionHouse.GetTimeLeftBandInfo(timeLeftBand))", 2);
	end

	if TIME_LEFT_BAND_INFO[timeLeftBand] then
		return TIME_LEFT_BAND_INFO[timeLeftBand].min, TIME_LEFT_BAND_INFO[timeLeftBand].max;
	end
end

function C_AuctionHouse.HasFavorites()
	return next(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS);
end

function C_AuctionHouse.HasFullBidResults()
	return bids:HasFullResults();
end

function C_AuctionHouse.HasFullBrowseResults()
	return browse:HasFullResults();
end

function C_AuctionHouse.HasFullCommoditySearchResults(itemID)
	if not itemID then
		error("Usage: local hasFullResults = C_AuctionHouse.HasFullCommoditySearchResults(itemID)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'HasFullCommoditySearchResults' (outside of expected range -2147483648 to 2147483647 - Usage: local hasFullResults = C_AuctionHouse.HasFullCommoditySearchResults(itemID))", 2);
	end

	return search:GetItem(itemID):HasFullResults();
end

function C_AuctionHouse.HasFullItemSearchResults(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local hasFullResults = C_AuctionHouse.HasFullItemSearchResults(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return search:GetItem(itemKey.itemID, itemKey.itemSuffix):HasFullResults();
end

function C_AuctionHouse.HasFullOwnedAuctionResults()
	return ownerAuction:HasFullResults();
end

function C_AuctionHouse.HasMaxFavorites()
	return tCount(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS) == MAX_COUNT_FAVORITES_ITEMS;
end

function C_AuctionHouse.HasSearchResults(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local hasSearchResults = C_AuctionHouse.HasSearchResults(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return search:GetItem(itemKey.itemID, itemKey.itemSuffix):HasSearchResults(itemKey);
end

function C_AuctionHouse.IsFavoriteItem(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and not itemKey.itemID) then
		error("Usage: local isFavorite = C_AuctionHouse.IsFavoriteItem(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	return AUCTION_FAVORITE_ITEMS[itemKey.itemID] and AUCTION_FAVORITE_ITEMS[itemKey.itemID][itemKey.itemSuffix or 0] and true or false;
end

function C_AuctionHouse.IsSellItemValid(item)
	if not item then
		error("Usage: local valid = C_AuctionHouse.IsSellItemValid(item [, displayError])", 2);
	end
	if type(item) ~= "table" then
		error("bad argument #1 to 'IsSellItemValid' (Usage: local valid = C_AuctionHouse.IsSellItemValid(item [, displayError]))", 2);
	end

	if not item:IsBagAndSlot() then
		return false;
	end

	return IsSellItemValid(item:GetBagAndSlot());
end

function C_AuctionHouse.IsThrottledMessageSystemReady()
	return THROTTLED_MESSAGE_SYSTEM_READY;
end

local function MakeItemKey(itemID, itemLevel, itemSuffix)
	itemSuffix = itemSuffix or 0;

	local keyInfo = ITEM_KEY_INFO[itemID] and ITEM_KEY_INFO[itemID][itemSuffix];

	return {
		itemID = itemID,
		itemLevel = (itemLevel or keyInfo and keyInfo.isEquipment and select(4, GetItemInfo(itemID))) or 0,
		itemSuffix = itemSuffix,
	};
end

function C_AuctionHouse.MakeItemKey(itemID, itemLevel, itemSuffix)
	if not itemID then
		error("Usage: local itemKey = C_AuctionHouse.MakeItemKey(itemID [, itemLevel, itemSuffix, battlePetSpeciesID])", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'MakeItemKey' (outside of expected range 0 to 4294967295 - Usage: local itemKey = C_AuctionHouse.MakeItemKey(itemID [, itemLevel, itemSuffix]))", 2);
	end
	if type(itemLevel) == "string" then
		itemLevel = tonumber(itemLevel);
	end
	if itemLevel and type(itemLevel) ~= "number" then
		error("bad argument #2 to 'MakeItemKey' (outside of expected range 0 to 4294967295 - Usage: local itemKey = C_AuctionHouse.MakeItemKey(itemID [, itemLevel, itemSuffix]))", 2);
	end
	if type(itemSuffix) == "string" then
		itemSuffix = tonumber(itemSuffix);
	end
	if itemSuffix and type(itemSuffix) ~= "number" then
		error("bad argument #3 to 'MakeItemKey' (outside of expected range 0 to 4294967295 - Usage: local itemKey = C_AuctionHouse.MakeItemKey(itemID [, itemLevel, itemSuffix]))", 2);
	end

	return MakeItemKey(itemID, itemLevel, itemSuffix);
end

local function PlaceBid(auctionID, bidAmount)
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_PLACE_BID", format("%s:%s:%d", ACTION_HOUSE_NPC_GUID, auctionID, bidAmount));

		return true;
	end
end

function C_AuctionHouse.PlaceBid(auctionID, bidAmount)
	if not auctionID or not bidAmount then
		error("Usage: C_AuctionHouse.PlaceBid(auctionID, bidAmount)", 2);
	end
	if type(auctionID) == "string" then
		auctionID = tonumber(auctionID);
	end
	if type(auctionID) ~= "number" then
		error("bad argument #1 to 'PlaceBid' (outside of expected range -2147483648 to 2147483647 - Usage: C_AuctionHouse.PlaceBid(auctionID, bidAmount))", 2);
	end
	if type(bidAmount) == "string" then
		bidAmount = tonumber(bidAmount);
	end
	if type(bidAmount) ~= "number" then
		error("bad argument #2 to 'PlaceBid' (Usage: C_AuctionHouse.PlaceBid(auctionID, bidAmount))", 2);
	end

	SendServerThrottledMessage(PlaceBid, auctionID, bidAmount);
end

local function PostCommodity(item, duration, quantity, unitPrice)
	if ACTION_HOUSE_NPC_GUID then
		unitPrice, duration = unitPrice or 0, AUCTION_HOUSE_DURATION[duration or 1];

		if unitPrice > MAXIMUM_BID_PRICE then
			unitPrice = MAXIMUM_BID_PRICE;
		end

		local bagID, slotID = item:GetBagAndSlot();
		local itemID = GetContainerItemID(bagID, slotID);

		if itemID then
			ClickAuctionSellItemButton();
			ClearCursor();

			SendServerMessage("ACMSG_AUCTION_SELL_COMMODITY", format("%s:%s:%d:%d:%d", ACTION_HOUSE_NPC_GUID, unitPrice, duration, itemID, quantity));
		end

		return true;
	end
end

function C_AuctionHouse.PostCommodity(item, duration, quantity, unitPrice)
	if type(item) == "table" and item:IsBagAndSlot() then
		SendServerThrottledMessage(PostCommodity, item, duration, quantity, unitPrice);
	end
end

local function PostItem(item, duration, quantity, bid, buyout)
	if ACTION_HOUSE_NPC_GUID then
		bid, buyout, duration = bid or 0, buyout or 0, AUCTION_HOUSE_DURATION[duration or 1];

		if bid > MAXIMUM_BID_PRICE then
			bid = MAXIMUM_BID_PRICE;
		end

		if buyout > MAXIMUM_BID_PRICE or buyout == 0 and bid == MAXIMUM_BID_PRICE then
			buyout = MAXIMUM_BID_PRICE;
		end

		local bagID, slotID = item:GetBagAndSlot();
		local itemID = GetContainerItemID(bagID, slotID);

		post:Clear();

		if itemID then
			post:SetInfo(bid, buyout, duration, quantity, itemID);

			local isMultiSale = quantity > 1;
			post:SetMultiSale(isMultiSale);

			ClickAuctionSellItemButton();
			ClearCursor();

			SendServerMessage("ACMSG_AUCTION_SELL_ITEM", format("%s:%s:%s:%s:%s:%s:%d", ACTION_HOUSE_NPC_GUID, bid, buyout, duration, bagID, slotID, 1));

			if isMultiSale then
				FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_MULTISELL_START, quantity);
			end
		end

		return true;
	end
end

function C_AuctionHouse.PostItem(item, duration, quantity, bid, buyout)
	if type(item) == "table" and item:IsBagAndSlot() then
		SendServerThrottledMessage(PostItem, item, duration, quantity, bid, buyout);
	end
end

local function QueryBids(sorts, auctionIDs)
	if ACTION_HOUSE_NPC_GUID then
		bids:Clear();
		bids:SetSorts(sorts);

		local auctions = "";
		for _, auctionID in pairs(auctionIDs) do
			auctions = format("%s:%s", auctions, auctionID);
		end

		SendServerMessage("ACMSG_AUCTION_LIST_BIDDED_ITEMS", format("%s:%d:%d:%d%s", ACTION_HOUSE_NPC_GUID, bids:GetOffset(), bids:GetSortOrder(), bids:GetReverseSort(), auctions));

		return true;
	end
end

function C_AuctionHouse.QueryBids(sorts, auctionIDs)
	if type(sorts) ~= "table" then
		error(format("attempt to index a %s value", type(sorts)), 2);
	end
	if type(auctionIDs) ~= "table" then
		error(format("attempt to index a %s value", type(auctionIDs)), 2);
	end

	bids:SetFullResult(false);

	SendServerThrottledMessage(QueryBids, sorts, auctionIDs);
end

local function QueryOwnedAuctions(sorts)
	if ACTION_HOUSE_NPC_GUID then
		ownerAuction:Clear();
		ownerAuction:SetSorts(sorts);

		SendServerMessage("ACMSG_AUCTION_LIST_OWNED_ITEMS", format("%s:%d:%d:%d", ACTION_HOUSE_NPC_GUID, ownerAuction:GetOffset(), ownerAuction:GetSortOrder(), ownerAuction:GetReverseSort()));

		return true;
	end
end

function C_AuctionHouse.QueryOwnedAuctions(sorts)
	if type(sorts) ~= "table" then
		error(format("attempt to index a %s value", type(sorts)), 2);
	end

	SendServerThrottledMessage(QueryOwnedAuctions, sorts);
end

local function RefreshCommoditySearchResults(itemID, item)
	if ACTION_HOUSE_NPC_GUID then
		item:Clear();

		SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_BUCKET_KEY", format("%s:%d:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), item:GetSortOrder(), item:GetReverseSort(), itemID, 0, 0));

		FireDelayedCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_SEARCH_RESULTS_UPDATED, itemID);

		return true;
	end
end

function C_AuctionHouse.RefreshCommoditySearchResults(itemID)
	if not itemID then
		error("Usage: C_AuctionHouse.RefreshCommoditySearchResults(itemID)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'RefreshCommoditySearchResults' (outside of expected range -2147483648 to 2147483647 - Usage: C_AuctionHouse.RefreshCommoditySearchResults(itemID))", 2);
	end

	local item = search:GetItem(itemID);
	item:Clear();

	SendServerThrottledMessage(RefreshCommoditySearchResults, itemID, item);
end

local function RefreshItemSearchResults(itemKey, item)
	if ACTION_HOUSE_NPC_GUID then
		item:Clear();

		if item:IsByItemID() then
			SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_ITEM_ID", format("%s:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), itemKey.itemID, abs(itemKey.itemSuffix or 0), item:GetSortOrder(), item:GetReverseSort()));
		else
			SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_BUCKET_KEY", format("%s:%d:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), item:GetSortOrder(), item:GetReverseSort(), itemKey.itemID, itemKey.itemLevel, abs(itemKey.itemSuffix or 0)));
		end

		FireDelayedCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.ITEM_SEARCH_RESULTS_UPDATED, {itemID = itemKey.itemID, itemLevel = itemKey.itemLevel, itemSuffix = itemKey.itemSuffix});

		return true;
	end
end

function C_AuctionHouse.RefreshItemSearchResults(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: C_AuctionHouse.RefreshItemSearchResults(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	local item = search:GetItem(itemKey.itemID, itemKey.itemSuffix);
	item:Clear();

	SendServerThrottledMessage(RefreshItemSearchResults, itemKey, item);
end

local function ReplicateItems()
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_REPLICATE_ITEMS", format("%s:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, 0, 0, 0, 0));

		return true;
	end
end

function C_AuctionHouse.ReplicateItems()
	SendServerThrottledMessage(ReplicateItems);
end

local function RequestMoreCommoditySearchResults(itemID, item)
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_BUCKET_KEY", format("%s:%d:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), item:GetSortOrder(), item:GetReverseSort(), itemID, 0, 0));

		return true;
	end
end

function C_AuctionHouse.RequestMoreCommoditySearchResults(itemID)
	if not itemID then
		error("Usage: local hasFullResults = C_AuctionHouse.RequestMoreCommoditySearchResults(itemID)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'RequestMoreCommoditySearchResults' (outside of expected range -2147483648 to 2147483647 - Usage: local hasFullResults = C_AuctionHouse.RequestMoreCommoditySearchResults(itemID))", 2);
	end

	local item = search:GetItem(itemID);
	local numResults = item:GetNumResults();
	local hasFullResults = item:HasFullResults();

	if item:GetOffset() ~= numResults and not hasFullResults then
		item:SetOffset(numResults);

		SendServerThrottledMessage(RequestMoreCommoditySearchResults, itemID, item);
	end

	return false;
end

local function RequestMoreItemSearchResults(itemKey, item)
	if ACTION_HOUSE_NPC_GUID then

		if item:IsByItemID() then
			SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_ITEM_ID", format("%s:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), itemKey.itemID, abs(itemKey.itemSuffix or 0), item:GetSortOrder(), item:GetReverseSort()));
		else
			SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_BUCKET_KEY", format("%s:%d:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), item:GetSortOrder(), item:GetReverseSort(), itemKey.itemID, itemKey.itemLevel, abs(itemKey.itemSuffix or 0)));
		end

		return true;
	end
end

function C_AuctionHouse.RequestMoreItemSearchResults(itemKey)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: local hasFullResults = C_AuctionHouse.RequestMoreItemSearchResults(itemKey)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	local item = search:GetItem(itemKey.itemID, itemKey.itemSuffix);
	local numResults = item:GetNumResults();
	local hasFullResults = item:HasFullResults();

	if item:GetOffset() ~= numResults and not hasFullResults then
		item:SetOffset(numResults);

		SendServerThrottledMessage(RequestMoreItemSearchResults, itemKey, item);
	end

	return false;
end

function C_AuctionHouse.RequestOwnedAuctionBidderInfo(auctionID)
	print("RequestOwnedAuctionBidderInfo", auctionID);
end

local function SearchForFavorites(sorts)
	if ACTION_HOUSE_NPC_GUID then
		search:Clear();
		browse:Clear();
		browse:SetSorts(sorts);

		local itemKeysString = "";
		for _, itemKey in pairs(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS) do
			itemKeysString = format("%s:%d:%d:%d", itemKeysString, itemKey.itemID, itemKey.itemLevel or 0, abs(itemKey.itemSuffix or 0));
			if #itemKeysString > 900 then
				break;
			end
		end

		if itemKeysString ~= "" then
			SendServerMessage("ACMSG_AUCTION_LIST_BUCKETS_BY_BUCKET_KEYS", format("%s:%d:%d%s", ACTION_HOUSE_NPC_GUID, browse:GetSortOrder(), browse:GetReverseSort(), itemKeysString));

			return true;
		end
	end
end

function C_AuctionHouse.SearchForFavorites(sorts)
	if type(sorts) ~= "table" then
		error(format("attempt to index a %s value", type(sorts)), 2);
	end

	browse:SetFullResult(false);

	SendServerThrottledMessage(SearchForFavorites, sorts);
end

local function SearchForItemKeys(itemKeys, sorts)
	if ACTION_HOUSE_NPC_GUID then
		browse:Clear();
		browse:SetSorts(sorts);

		local itemKeysString = "";
		for _, itemKey in ipairs(itemKeys) do
			itemKeysString = format("%s:%d:%d:%d", itemKeysString, itemKey.itemID, itemKey.itemLevel or 0, abs(itemKey.itemSuffix or 0));
			if #itemKeysString > 900 then
				break;
			end
		end

		if itemKeysString ~= "" then
			SendServerMessage("ACMSG_AUCTION_LIST_BUCKETS_BY_BUCKET_KEYS", format("%s:%d:%d%s", ACTION_HOUSE_NPC_GUID, browse:GetSortOrder(), browse:GetReverseSort(), itemKeysString));

			return true;
		end
	end
end

function C_AuctionHouse.SearchForItemKeys(itemKeys, sorts)
	if type(itemKeys) ~= "table" then
		error(format("attempt to index a %s value", type(itemKeys)), 2);
	end
	if type(sorts) ~= "table" then
		error(format("attempt to index a %s value", type(sorts)), 2);
	end

	browse:SetFullResult(false);

	SendServerThrottledMessage(SearchForItemKeys, itemKeys, sorts);
end

local function SendBrowseQuery(query)
	if ACTION_HOUSE_NPC_GUID then
		search:Clear();
		browse:Clear();
		browse:SetSorts(query);

		local filtersMask, searchString, minLevel, maxLevel, classID, subClassID, itemInvType = browse:GetFilterInfo();

		SendServerMessage("ACMSG_AUCTION_BROWSE_QUERY", format("%s|%d|%d|%s|%d|%d|%d|%d|%d|%d|%d", ACTION_HOUSE_NPC_GUID, filtersMask, browse:GetOffset(), searchString, minLevel, maxLevel, classID, subClassID, itemInvType, browse:GetSortOrder(), browse:GetReverseSort()));

		return true;
	end
end

function C_AuctionHouse.SendBrowseQuery(query)
	if type(query) ~= "table" then
		error(format("attempt to index a %s value", type(query)), 2);
	end

	browse:SetFullResult(false);

	SendServerThrottledMessage(SendBrowseQuery, query);
end

local function RequestMoreBrowseResults()
	if ACTION_HOUSE_NPC_GUID then
		local numItems = browse:GetNumItems();
		if browse:GetOffset() ~= numItems and not browse:HasFullResults() then
			browse:SetOffset(numItems);

			local filtersMask, searchString, minLevel, maxLevel, classID, subClassID, itemInvType = browse:GetFilterInfo();

			SendServerMessage("ACMSG_AUCTION_BROWSE_QUERY", format("%s|%d|%d|%s|%d|%d|%d|%d|%d|%d|%d", ACTION_HOUSE_NPC_GUID, filtersMask, browse:GetOffset(), searchString, minLevel, maxLevel, classID, subClassID, itemInvType, browse:GetSortOrder(), browse:GetReverseSort()));

			return true;
		end
	end
end

function C_AuctionHouse.RequestMoreBrowseResults()
	SendServerThrottledMessage(RequestMoreBrowseResults);
end

local function SendSearchQuery(itemKey, sorts, separateOwnerItems, item)
	if ACTION_HOUSE_NPC_GUID then
		item:Clear();
		item:SetSorts(sorts);
		item:SetSeparateOwnerItems(separateOwnerItems);

		local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
		local itemLevel = itemKeyInfo and itemKeyInfo.isCommodity and 0 or itemKey.itemLevel;

		SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_BUCKET_KEY", format("%s:%d:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), item:GetSortOrder(), item:GetReverseSort(), itemKey.itemID, itemLevel, abs(itemKey.itemSuffix or 0)));

		return true;
	end
end

function C_AuctionHouse.SendSearchQuery(itemKey, sorts, separateOwnerItems)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") or type(sorts) ~= "table" then
		error("Usage: C_AuctionHouse.SendSearchQuery(itemKey, sorts, separateOwnerItems)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	local item = search:GetItem(itemKey.itemID, itemKey.itemSuffix);
	item:Clear();
	item:SetFullResult(false);

	SendServerThrottledMessage(SendSearchQuery, itemKey, sorts, separateOwnerItems, item);
end

local function SendSellSearchQuery(itemKey, sorts, separateOwnerItems, item)
	if ACTION_HOUSE_NPC_GUID then
		item:Clear();
		item:SetSorts(sorts);
		item:SetSeparateOwnerItems(separateOwnerItems);
		item:SetByItemID(true);

		SendServerMessage("ACMSG_AUCTION_LIST_ITEMS_BY_ITEM_ID", format("%s:%d:%d:%d:%d:%d", ACTION_HOUSE_NPC_GUID, item:GetOffset(), itemKey.itemID, abs(itemKey.itemSuffix or 0), item:GetSortOrder(), item:GetReverseSort()));

		return true;
	end
end

function C_AuctionHouse.SendSellSearchQuery(itemKey, sorts, separateOwnerItems)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") or type(sorts) ~= "table" then
		error("Usage: C_AuctionHouse.SendSellSearchQuery(itemKey, sorts, separateOwnerItems)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	local item = search:GetItem(itemKey.itemID, itemKey.itemSuffix);
	item:Clear();
	item:SetFullResult(false);

	SendServerThrottledMessage(SendSellSearchQuery, itemKey, sorts, separateOwnerItems, item);
end

function C_AuctionHouse.SetFavoriteItem(itemKey, setFavorite)
	local itemKeyType = type(itemKey);
	if itemKeyType == "string" or (itemKeyType == "table" and type(itemKey.itemID) ~= "number") then
		error("Usage: C_AuctionHouse.SetFavoriteItem(itemKey, setFavorite)", 2);
	elseif itemKeyType ~= "table" then
		error(format("attempt to index a %s value", itemKeyType), 2);
	end

	if ACTION_HOUSE_NPC_GUID then
		local favoriteIndex;

		if setFavorite then
			local foundEmptyFavorite;
			for index = 1, MAX_COUNT_FAVORITES_ITEMS do
				if not SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS[index] then
					foundEmptyFavorite = index;
					break;
				end
			end

			if foundEmptyFavorite then
				SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS[foundEmptyFavorite] = itemKey;
				favoriteIndex = foundEmptyFavorite;
			end
		else
			for index, favoriteKey in pairs(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS) do
				if favoriteKey.itemID == itemKey.itemID and favoriteKey.itemSuffix == itemKey.itemSuffix then
					SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS[index] = nil;
					favoriteIndex = index;
					break;
				end
			end
		end

		if favoriteIndex then
			if not AUCTION_FAVORITE_ITEMS[itemKey.itemID] then AUCTION_FAVORITE_ITEMS[itemKey.itemID] = {}; end
			AUCTION_FAVORITE_ITEMS[itemKey.itemID][itemKey.itemSuffix] = setFavorite;

			SendServerThrottledMessage("ACMSG_AUCTION_SET_FAVORITE_ITEM", format("%s:%d:%d:%d:%d", setFavorite and 0 or 1, favoriteIndex, itemKey.itemID, itemKey.itemLevel or 0, abs(itemKey.itemSuffix or 0)));

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_FAVORITES_UPDATED);
		end
	end
end

local function StartCommoditiesPurchase(itemID, quantity)
	if ACTION_HOUSE_NPC_GUID then
		SendServerMessage("ACMSG_AUCTION_GET_COMMODITY_QUOTE", format("%s:%d:%d", ACTION_HOUSE_NPC_GUID, itemID, quantity));

		return true;
	end
end

function C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity)
	if not itemID or not quantity then
		error("Usage: C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity)", 2);
	end
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("bad argument #1 to 'StartCommoditiesPurchase' (outside of expected range -2147483648 to 2147483647 - Usage: C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity))", 2);
	end
	if type(quantity) == "string" then
		quantity = tonumber(quantity);
	end
	if type(quantity) ~= "number" then
		error("bad argument #2 to 'StartCommoditiesPurchase' (outside of expected range 0 to 4294967295 - Usage: C_AuctionHouse.StartCommoditiesPurchase(itemID, quantity))", 2);
	end

	SendServerThrottledMessage(StartCommoditiesPurchase, itemID, quantity);
end

AH_CACHE = C_Cache("AUCTION_HOUSE_CACHE", true);

local frame = CreateFrame("Frame");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("BANKFRAME_OPENED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_TALENT_UPDATE");
frame:SetScript("OnEvent", function(self, event)
	if event == "VARIABLES_LOADED" then
		AH_CACHE:Set("FAVORITE_ITEMS", nil); -- Remove later, unused

		for _, itemKey in pairs(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS) do
			if not AUCTION_FAVORITE_ITEMS[itemKey.itemID] then AUCTION_FAVORITE_ITEMS[itemKey.itemID] = {}; end
			AUCTION_FAVORITE_ITEMS[itemKey.itemID][itemKey.itemSuffix or 0] = true;
		end

		g_activeBidAuctionIDs = AH_CACHE:Get("BID_AUCTION_IDS") or AH_CACHE:Get("BID_AUCTION_IDS", {});

		AUCTION_HOUSE_CACHE.SortsBySearchContext = AUCTION_HOUSE_CACHE.SortsBySearchContext or {};
		g_auctionHouseSortsBySearchContext = AUCTION_HOUSE_CACHE.SortsBySearchContext;

		scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
		scanTooltip:AddFontStrings(
				scanTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
				scanTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
		);
	elseif event == "BANKFRAME_OPENED" then
		if AuctionHouseFrame:IsShown() then
			HideUIPanel(AuctionHouseFrame);
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		frame:RegisterEvent("COMMENTATOR_ENTER_WORLD");
		frame:UnregisterEvent(event);
	elseif event == "COMMENTATOR_ENTER_WORLD" then
		table.wipe(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS);
		frame:UnregisterEvent(event);
	elseif event == "PLAYER_TALENT_UPDATE" then
		frame:UnregisterEvent("COMMENTATOR_ENTER_WORLD");
		frame:UnregisterEvent(event);
	end
end);

local function CreateItemLink(itemKey, enchantID, jewelID1, jewelID2, jewelID3, jewelID4, suffixID, uniqueID)
	if type(itemKey) ~= "table" or type(itemKey.itemID) ~= "number" then
		return "";
	end

	local itemKeyInfo = GetItemKeyInfo(itemKey);
	local r, g, b = GetItemQualityColor(itemKeyInfo.quality or 1);

	return format("|cff%02x%02x%02x|Hitem:%s:%s:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r", r * 255, g * 255, b * 255, itemKey.itemID, enchantID or "0", jewelID1 or "0", jewelID2 or "0", jewelID3 or "0", jewelID4 or "0", suffixID or "0", uniqueID or "0", itemKeyInfo.itemMinLevel or "0", itemKeyInfo.itemName or "")
end

local AUCTION_FAVORITE_LIST_MSG = {};
function EventHandler:ASMSG_AUCTION_FAVORITE_LIST(msg)
	local _, _, hasResults = find(msg, ",(%d)$");
	if hasResults then
		AUCTION_FAVORITE_LIST_MSG[#AUCTION_FAVORITE_LIST_MSG + 1] = msg;

		local stringResult = tconcat(AUCTION_FAVORITE_LIST_MSG);
		twipe(AUCTION_FAVORITE_LIST_MSG);

		local favorites = C_Split(stringResult, ",");
		favorites[#favorites] = nil;

		for _, favoriteString in pairs(favorites) do
			local id, itemID, itemLevel, itemSuffix = split(":", favoriteString);
			id, itemID, itemLevel, itemSuffix = tonumber(id), tonumber(itemID), tonumber(itemLevel), tonumber(itemSuffix) or 0;
			if id and itemID then
				SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS[id] = {
					itemID = itemID,
					itemLevel = itemLevel or 0,
					itemSuffix = itemSuffix,
				};

				if not AUCTION_FAVORITE_ITEMS[itemID] then AUCTION_FAVORITE_ITEMS[itemID] = {}; end
				AUCTION_FAVORITE_ITEMS[itemID][itemSuffix] = true;
			end
		end
	else
		AUCTION_FAVORITE_LIST_MSG[#AUCTION_FAVORITE_LIST_MSG + 1] = msg;
	end
end

function EventHandler:ASMSG_AUCTION_LIST_BUCKETS_RESULT(msg)
	local _, _, hasMoreResults, browseMode, desiredDelay = find(msg, ",?(%d+):(%d+):(%d+)$");

	if hasMoreResults and browseMode and desiredDelay then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;

		local stringResult = tconcat(THROTTLED_MESSAGE_RESULT);
		twipe(THROTTLED_MESSAGE_RESULT);

		local browseResults = C_Split(stringResult, ",");
		browseResults[#browseResults] = nil;

		local hasFullResults = browse:HasFullResults();
		local moreResults = browse:GetOffset() ~= 0 and {};

		local browseResult, itemID, itemLevel, itemSuffix, enchantID, uniqueID, minPrice, extraInfo, totalQuantity, containsOwnerItem;
		for i = 1, #browseResults do
			browseResult = browseResults[i];
			itemID, itemLevel, itemSuffix, enchantID, uniqueID, minPrice, extraInfo, totalQuantity, containsOwnerItem = split(":", browseResult);
			itemID, itemSuffix, enchantID, uniqueID, minPrice, totalQuantity = tonumber(itemID), tonumber(itemSuffix) or 0, tonumber(enchantID), tonumber(uniqueID), tonumber(minPrice), tonumber(totalQuantity);

			if not ITEM_KEY_INFO[itemID] then ITEM_KEY_INFO[itemID] = {}; end
			if not ITEM_KEY_INFO[itemID][itemSuffix] then ITEM_KEY_INFO[itemID][itemSuffix] = {}; end

			local itemKey = {
				itemID = itemID,
				itemLevel = tonumber(itemLevel),
				itemSuffix = itemSuffix,
				enchantID = enchantID ~= 0 and enchantID or nil,
				uniqueID = uniqueID ~= 0 and uniqueID or nil
			};

			browse:SetExtraInfo(itemKey, tonumber(extraInfo));

			local lastItem = browse:AddItem({
				itemKey = itemKey,
				minPrice = minPrice,
				totalQuantity = totalQuantity,
				containsOwnerItem = containsOwnerItem == "1",
			});

			if moreResults then
				moreResults[#moreResults + 1] = CopyTable(lastItem);
			end
		end

		twipe(browseResults);

		if browseMode == "1" and not hasFullResults then
			for _, key in pairs(SIRUS_AUCTION_HOUSE_FAVORITE_ITEMS) do
				local foundBrowseResult;

				for index = 1, browse:GetNumItems() do
					local itemKey = browse:GetItem(index).itemKey;
					if itemKey.itemID == key.itemID and itemKey.itemSuffix == key.itemSuffix then
						foundBrowseResult = true;
						break;
					end
				end

				if not foundBrowseResult then
					browse:AddItem({
						itemKey = {
							itemID = key.itemID,
							itemLevel = key.itemLevel,
							itemSuffix = key.itemSuffix
						},
						minPrice = 0,
						totalQuantity = 0,
					});
				end
			end
		end

		browse:SetFullResult(hasMoreResults == "0");

		if moreResults then
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_BROWSE_RESULTS_ADDED, moreResults);
		else
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_BROWSE_RESULTS_UPDATED);
		end

		CheckThrottledMessage(tonumber(desiredDelay));
	else
		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;
	end
end

local PLAYER_NAME = UnitName("player");

function EventHandler:ASMSG_AUCTION_LIST_ITEMS_RESULT(msg)
	local startResult, endResult, hasMoreResults, totalItemsCount = find(msg, ",?:?(%d+):(%d*)$");

	if startResult and endResult and hasMoreResults and totalItemsCount then
		msg = sub(msg, -endResult, startResult - 1);

		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;

		local stringResult = tconcat(THROTTLED_MESSAGE_RESULT);
		twipe(THROTTLED_MESSAGE_RESULT);

		local _, endSringResult, desiredDelay, itemID, itemLevel, itemSuffix, listType = find(stringResult, "^(%d+):(%d+):(%d+):(%d*):?(%d*):?");
		itemID, itemLevel, itemSuffix = tonumber(itemID), tonumber(itemLevel) or 0, tonumber(itemSuffix) or 0;

		if endSringResult and itemID then
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

			stringResult = sub(stringResult, endSringResult + 1);

			local listItemsResult = C_Split(stringResult, ",");

			local itemKey = {
				itemID = itemID,
				itemLevel = itemLevel,
				itemSuffix = itemSuffix,
			};

			local keyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);

			local item = search:GetItem(itemID, itemSuffix);

			local moreResults = item:GetOffset() ~= 0;

			item:SetQuantity(tonumber(totalItemsCount));

			item:SetFullResult(listType == "" or hasMoreResults == "0");
			item:SetSearchResult(true);

			if listType and listType ~= "" then
				item:SetCommodity(listType == "1");
			else
				if keyInfo then
					item:SetCommodity(keyInfo.isCommodity);
				end
			end

			item:SetEquipment(keyInfo and keyInfo.isEquipment);

			local numResults = item:GetNumResults();

			local itemResult, itemData, numData, itemEnum;

			if listType == "1" then -- isCommodity
				for i = 1, #listItemsResult do
					itemResult = listItemsResult[i];
					itemData = {split(":", itemResult)};
					numData = #itemData;

					if numData == 14 then
						itemEnum = AUCTION_LIST_COMMODITY_RESULT_BY_ITEMID;
					elseif numData == 15 then
						itemEnum = AUCTION_LIST_COMMODITY_RESULT_OWNER_BY_ITEMID;
					else
						itemEnum = AUCTION_LIST_COMMODITY_RESULT_BY_ITEMID;
					end

					local ownerName = itemData[itemEnum.OwnerName];
					if ownerName == PLAYER_NAME then ownerName = "player"; end

					item:AddResult({
						itemID = itemID,
						quantity = tonumber(itemData[itemEnum.Quantity]),
						buyoutAmount = tonumber(itemData[itemEnum.BuyoutAmount]) or 0,
						auctionID = tonumber(itemData[itemEnum.AuctionID]),
						owner = ownerName,
						timeLeft = tonumber(itemData[itemEnum.TimeLeft]),
						isOwnerItem = ownerName == "player",
						isAccountItem = itemData[itemEnum.HasAccountItem] == "0",
						timeLeftSeconds	= tonumber(itemData[itemEnum.TimeLeftSeconds]),
					});
				end

				item:RefreshResults(numResults);

				if moreResults then
					FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_SEARCH_RESULTS_ADDED, itemID);
				else
					FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_SEARCH_RESULTS_UPDATED, itemID);
				end
			elseif listType == "2" then
				for i = 1, #listItemsResult do
					itemResult = listItemsResult[i];
					itemData = {split(":", itemResult)};
					numData = #itemData;

					if numData == 22 then
						itemEnum = AUCTION_LIST_ITEMS_RESULT_DEFAULT;
					elseif numData == 23 then
						itemEnum = AUCTION_LIST_ITEMS_RESULT_OWNER;
					elseif numData == 25 then
						if tonumber(itemData[numData]) then
							itemEnum = AUCTION_LIST_ITEMS_RESULT_BY_ITEMID;
						else
							itemEnum = AUCTION_LIST_ITEMS_RESULT_BIDER;
						end
					elseif numData == 26 then
						if tonumber(itemData[numData]) then
							itemEnum = AUCTION_LIST_ITEMS_RESULT_OWNER_BY_ITEMID;
						else
							itemEnum = AUCTION_LIST_ITEMS_RESULT_OWNER_BIDER;
						end
					elseif numData == 28 then
						itemEnum = AUCTION_LIST_ITEMS_RESULT_BIDER_BY_ITEMID;
					elseif numData == 29 then
						itemEnum = AUCTION_LIST_ITEMS_RESULT_OWNER_BIDER_BY_ITEMID;
					else
						itemEnum = AUCTION_LIST_ITEMS_RESULT_DEFAULT;
						error("Error parsing Item Results "..itemData, 2)
					end

					local resultItemSuffix = tonumber(itemData[itemEnum.ItemSuffix]);

					local bidAmount;
					local minBid, buyoutAmount = tonumber(itemData[itemEnum.MinBid]), tonumber(itemData[itemEnum.BuyoutAmount]);

					if itemData[itemEnum.HasBidInfo] == "1" then
						if minBid and minBid > 0 then
							bidAmount = minBid;
							minBid = bidAmount + tonumber(itemData[itemEnum.MinIncrement]);
						else
							minBid = nil;
						end
					else
						bidAmount = tonumber(itemData[itemEnum.BidAmount]);
						minBid = bidAmount + tonumber(itemData[itemEnum.MinIncrement]);
					end

					local ownerName = itemData[itemEnum.OwnerName];
					if ownerName == PLAYER_NAME then ownerName = "player"; end

					if itemSuffix == 0 and resultItemSuffix then
						local resultItem = search:GetItem(itemID, resultItemSuffix);
						resultItem:SetMaxBuyout(buyoutAmount or 0);
						resultItem:SetMaxBid(bidAmount or 0);
					end

					item:AddResult({
						itemID = itemID,
						itemLevel = tonumber(itemData[itemEnum.ItemLevel]) or itemLevel,
						itemSuffix = resultItemSuffix or itemSuffix,
						owner = ownerName,
						timeLeft = tonumber(itemData[itemEnum.TimeLeft]),
						auctionID = tonumber(itemData[itemEnum.AuctionID]),
						quantity = tonumber(itemData[itemEnum.Quantity]),
						itemLink = CreateItemLink(itemKey, itemData[itemEnum.EnchantID], itemData[itemEnum.JewelID1], itemData[itemEnum.JewelID2], itemData[itemEnum.JewelID3], itemData[itemEnum.JewelID4], itemData[itemEnum.SuffixID], itemData[itemEnum.UniqueID]),
						isOwnerItem = ownerName == "player",
						isAccountItem = itemData[itemEnum.HasAccountItem] == "0",
						isSocketedItem = itemData[itemEnum.HasSocketedItem] == "1",
						bidder = itemData[itemEnum.BidderName],
						minBid = minBid,
						bidAmount = bidAmount,
						buyoutAmount = buyoutAmount ~= 0 and buyoutAmount or nil,
						timeLeftSeconds	= tonumber(itemData[itemEnum.TimeLeftSeconds]),
					});
				end

				item:RefreshResults(numResults);

				if moreResults then
					FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.ITEM_SEARCH_RESULTS_ADDED, {itemID = itemID, itemLevel = itemLevel, itemSuffix = itemSuffix});
				else
					FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.ITEM_SEARCH_RESULTS_UPDATED, {itemID = itemID, itemLevel = itemLevel, itemSuffix = itemSuffix});
				end
			else
				if keyInfo and keyInfo.isCommodity then
					FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_SEARCH_RESULTS_UPDATED, itemID);
				else
					FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.ITEM_SEARCH_RESULTS_UPDATED, {itemID = itemID, itemLevel = itemLevel, itemSuffix = itemSuffix});
				end
			end
		else

		end

		CheckThrottledMessage(tonumber(desiredDelay));
	else
		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;
	end
end

function EventHandler:ASMSG_AUCTION_GET_COMMODITY_QUOTE_RESULT(msg)
	local price, numPrice, time, delayNextAction = split(":", msg);
	price, numPrice, time = tonumber(price), tonumber(numPrice), tonumber(time);

	if price and numPrice and time then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_PRICE_UPDATED, price / numPrice, price);

		COMMODITY_QUOTE_TIME = GetTime() + (time / 1000);
	else
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_PRICE_UNAVAILABLE);
	end

	if not delayNextAction and not price and not time and numPrice then
		delayNextAction = numPrice;
	end

	CheckThrottledMessage(tonumber(delayNextAction));
end

function EventHandler:ASMSG_AUCTION_LIST_OWNED_ITEMS_RESULT(msg)
	local _, _, hasMoreResults, desiredDelay = find(msg, ",?(%d+):(%d+)$");

	if hasMoreResults and desiredDelay then
		ownerAuction:SetFullResult(hasMoreResults == "0");

		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;

		local stringResult = tconcat(THROTTLED_MESSAGE_RESULT);
		twipe(THROTTLED_MESSAGE_RESULT);

		local ownedItemsResult = C_Split(stringResult, ",");
		ownedItemsResult[#ownedItemsResult] = nil;

		for i = 1, #ownedItemsResult do
			local ownedItemResult = ownedItemsResult[i];
			local itemData = {split(":", ownedItemResult)};
			local numData = #itemData;

			local itemEnum;
			if numData == 18 then
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_OWNED_BY_COMMODITY;
			elseif numData == 29 then
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_OWNED_BY_ITEMID;
			else
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_BY_ITEMID;
				error("Error parsing owner Item Results "..itemData, 2)
			end

			local itemID, itemLevel, itemSuffix = tonumber(itemData[itemEnum.ItemID]) or 0, tonumber(itemData[itemEnum.ItemLevel]) or 0, tonumber(itemData[itemEnum.ItemSuffix]) or 0;

			local itemKey = {
				itemID = itemID,
				itemLevel = itemLevel,
				itemSuffix = itemSuffix
			};

			local minBid = tonumber(itemData[itemEnum.MinBid]);
			local bidAmount = tonumber(itemData[itemEnum.BidAmount]);
			local buyoutAmount = tonumber(itemData[itemEnum.BuyoutAmount]) or 0;
			local bidder = itemData[itemEnum.Bidder];

			if not minBid or minBid == 0 then
				bidAmount = nil;
			elseif bidAmount and minBid > bidAmount then
				bidAmount = minBid;
			end

			ownerAuction:SetMaxBid(bidAmount or 0);
			ownerAuction:SetMaxBuyout(buyoutAmount);

			local bucketType = itemSuffix ~= 0 and (itemID..":"..itemSuffix) or itemID;
			ownerAuction:AddBucket(bucketType, itemKey);

			ownerAuction:AddItem({
				auctionID = tonumber(itemData[itemEnum.AuctionID]),
				itemKey = itemKey,
				itemLink = CreateItemLink(itemKey, itemData[itemEnum.EnchantID], itemData[itemEnum.JewelID1], itemData[itemEnum.JewelID2], itemData[itemEnum.JewelID3], itemData[itemEnum.JewelID4], itemData[itemEnum.SuffixID], itemData[itemEnum.UniqueID]),
				status = 0,
				quantity = tonumber(itemData[itemEnum.Quantity]),
				timeLeftSeconds = tonumber(itemData[itemEnum.TimeLeftSeconds]),
				timeLeft = tonumber(itemData[itemEnum.TimeLeft]),
				bidAmount = bidAmount,
				buyoutAmount = buyoutAmount ~= 0 and buyoutAmount or nil,
				bidder = bidder ~= "" and bidder or nil,
			});
		end

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.OWNED_AUCTIONS_UPDATED);

		CheckThrottledMessage(tonumber(desiredDelay));
	else
		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;
	end
end

function EventHandler:ASMSG_AUCTION_LIST_BIDDED_ITEMS_RESULT(msg)
	local _, _, hasMoreResults, desiredDelay = find(msg, ",?(%d+):(%d+)$");

	if hasMoreResults and desiredDelay then
		bids:SetFullResult(hasMoreResults == "0");

		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;

		local stringResult = tconcat(THROTTLED_MESSAGE_RESULT);
		twipe(THROTTLED_MESSAGE_RESULT);

		local bidsResult = C_Split(stringResult, ",");
		bidsResult[#bidsResult] = nil;

		for i = 1, #bidsResult do
			local bidResult = bidsResult[i];
			local itemData = {split(":", bidResult)};
			local numData = #itemData;

			local itemEnum;
			if numData == 18 then
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_OWNED_BY_COMMODITY;
			elseif numData == 28 then
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_BY_ITEMID;
			elseif numData == 29 then
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_OWNED_BY_ITEMID;
			else
				itemEnum = AUCTION_LIST_AUCTIONS_RESULT_BY_ITEMID;
				error("Error parsing bid Item Results "..itemData, 2)
			end

			local itemID, itemLevel, itemSuffix = tonumber(itemData[itemEnum.ItemID]) or 0, tonumber(itemData[itemEnum.ItemLevel]) or 0, tonumber(itemData[itemEnum.ItemSuffix]) or 0;

			local itemKey = {
				itemID = itemID,
				itemLevel = itemLevel,
				itemSuffix = itemSuffix
			};

			local minBid = tonumber(itemData[itemEnum.MinBid]);
			local bidAmount = tonumber(itemData[itemEnum.BidAmount]);
			local buyoutAmount = tonumber(itemData[itemEnum.BuyoutAmount]) or 0;
			local bidder = itemData[itemEnum.Bidder];

			if not minBid or minBid == 0 then
				bidAmount = nil;
			elseif bidAmount and minBid > bidAmount then
				bidAmount = minBid;
			end

			bids:SetMaxBid(bidAmount or 0);
			bids:SetMaxBuyout(buyoutAmount);

			local bucketType = itemSuffix ~= 0 and (itemID..":"..itemSuffix) or itemID;
			bids:AddBucket(bucketType, itemKey);

			bids:AddItem({
				auctionID = tonumber(itemData[itemEnum.AuctionID]),
				itemKey = itemKey,
				itemLink = CreateItemLink(itemKey, itemData[itemEnum.EnchantID], itemData[itemEnum.JewelID1], itemData[itemEnum.JewelID2], itemData[itemEnum.JewelID3], itemData[itemEnum.JewelID4], itemData[itemEnum.SuffixID], itemData[itemEnum.UniqueID]),
				quantity = tonumber(itemData[itemEnum.Quantity]),
				timeLeftSeconds = tonumber(itemData[itemEnum.TimeLeftSeconds]),
				timeLeft = tonumber(itemData[itemEnum.TimeLeft]),
				bidAmount = bidAmount,
				buyoutAmount = buyoutAmount ~= 0 and buyoutAmount or nil,
				bidder = bidder ~= "" and bidder or nil,
			});
		end

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.BIDS_UPDATED);

		CheckThrottledMessage(tonumber(desiredDelay));
	else
		THROTTLED_MESSAGE_RESULT[#THROTTLED_MESSAGE_RESULT + 1] = msg;
	end
end

local function PostMultiSaleItem(bid, buyout, duration, postBagID, postSlodID)
	SendServerThrottledMessage("ACMSG_AUCTION_SELL_ITEM", format("%s:%s:%s:%s:%s:%s:%d", ACTION_HOUSE_NPC_GUID, bid, buyout, duration, postBagID, postSlodID, 1));

	return true;
end

function EventHandler:ASMSG_AUCTION_COMMAND_RESULT(msg)
	local auctionID, auctionCommand, errorCode, delayNextAction, inventoryEquipError = split(":", msg);
	auctionID, auctionCommand, errorCode = tonumber(auctionID), tonumber(auctionCommand), tonumber(errorCode);

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

	if errorCode == AUCTION_HOUSE_ERROR.OK then
		if auctionCommand == AUCTION_HOUSE_COMMAND.SELL_ITEM then
			if auctionID then
				if ACTION_HOUSE_NPC_GUID and post:IsMultiSelling() then
					local bid, buyout, duration, quantity, itemID = post:GetInfo();
					if itemID then
						post:SetProgress(1);

						local progress = post:GetProgress();

						FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_MULTISELL_UPDATE, progress, quantity);

						local postBagID, postSlodID;

						for bagID = 0, NUM_BAG_SLOTS do
							for slotID = 1, GetContainerNumSlots(bagID) do
								if itemID == GetContainerItemID(bagID, slotID) then
									if IsSellItemValid(bagID, slotID) then
										postBagID, postSlodID = bagID, slotID;
										break;
									end
								end
							end
						end

						if postBagID and postSlodID and progress < quantity then
							SendServerThrottledMessage(PostMultiSaleItem, bid, buyout, duration, postBagID, postSlodID);
						else
							post:Clear();

							if progress ~= quantity then
								FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_MULTISELL_FAILURE);
							end
						end
					end
				end

				FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_AUCTION_CREATED, auctionID);

				SendChatMessageType(ERR_AUCTION_STARTED, "SYSTEM");
			end
		elseif auctionCommand == AUCTION_HOUSE_COMMAND.CANCEL then
			SendChatMessageType(ERR_AUCTION_REMOVED, "SYSTEM");

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_CANCELED, auctionID);
		elseif auctionCommand == AUCTION_HOUSE_COMMAND.PLACE_BID then

		end
	else
		if errorCode == AUCTION_HOUSE_ERROR.INVENTORY then

		elseif errorCode == AUCTION_HOUSE_ERROR.DATABASE_ERROR then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.NOT_ENOUGH_MONEY then
			UIErrorsFrame:AddMessage(ERR_NOT_ENOUGH_GOLD, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.ITEM_NOT_FOUND then
			UIErrorsFrame:AddMessage(ERR_ITEM_NOT_FOUND, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.HIGHER_BID then
			UIErrorsFrame:AddMessage(ERR_AUCTION_HIGHER_BID, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.BID_INCREMENT then
			UIErrorsFrame:AddMessage(ERR_AUCTION_BID_INCREMENT, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.BID_OWN then
			UIErrorsFrame:AddMessage(ERR_AUCTION_BID_OWN, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.AH_BUSY then
			UIErrorsFrame:AddMessage(ERR_AUCTION_HOUSE_BUSY, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.AH_UNAVAILABLE then
			UIErrorsFrame:AddMessage(ERR_AUCTION_HOUSE_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
		elseif errorCode == AUCTION_HOUSE_ERROR.COMMODITY_PURCHASE_FAILED then
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_PURCHASE_FAILED);
		elseif errorCode == AUCTION_HOUSE_ERROR.ITEM_HAS_QUOTE then
			UIErrorsFrame:AddMessage(ERR_AUCTION_ITEM_HAS_QUOTE, 1.0, 0.1, 0.1, 1.0);
		end

		if post:IsMultiSelling() then
			post:Clear();

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_MULTISELL_FAILURE);
		end
	end

	CheckThrottledMessage(tonumber(delayNextAction), errorCode);
end

function EventHandler:ASMSG_AUCTION_WON_NOTIFICATION(msg)
	local auctionID, itemID, itemSuffix, itemCount = split(":", msg);
	auctionID, itemID, itemSuffix, itemCount = tonumber(auctionID), tonumber(itemID), tonumber(itemSuffix), tonumber(itemCount) or 1;

	local itemKey = C_AuctionHouse.MakeItemKey(itemID, nil, itemSuffix);
	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
	if itemKeyInfo then
		if itemKeyInfo.isCommodity then
			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_CANCELED, auctionID);

			SendChatMessageType(format(ERR_AUCTION_COMMODITY_WON_S, itemKeyInfo.itemName, itemCount), "SYSTEM");

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.COMMODITY_PURCHASE_SUCCEEDED, itemKey.itemID, itemCount);
		else
			SendChatMessageType(format(ERR_AUCTION_WON_S, itemKeyInfo.itemName), "SYSTEM");

			local item = search:GetItem(itemID, itemSuffix);
			local itemsResult = item.results;
			local numItemsResult = #itemsResult;

			if numItemsResult > 0 then
				local index = 1;
				while index <= numItemsResult do
					local result = itemsResult[index];

					if result.auctionID == auctionID then
						tremove(itemsResult, index);
						item:RefreshResults(0);
						FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.ITEM_SEARCH_RESULTS_UPDATED, itemKey, numItemsResult > 1 and (itemsResult[numItemsResult == index and (index - 1) or index].auctionID) or nil);
						break;
					else
						index = index + 1;
					end
				end
			end

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_CANCELED, auctionID);
		end
	end
end

function EventHandler:ASMSG_AUCTION_CLOSED_NOTIFICATION(msg)
	local auctionID, _, itemID, itemSuffix, _, _, isSold = split(":", msg);

	local itemKey = C_AuctionHouse.MakeItemKey(tonumber(itemID), nil, tonumber(itemSuffix));
	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
	if itemKeyInfo then
		if isSold == "1" then
			SendChatMessageType(format(ERR_AUCTION_SOLD_S, itemKeyInfo.itemName), "SYSTEM");
		else
			SendChatMessageType(format(ERR_AUCTION_EXPIRED_S, itemKeyInfo.itemName), "SYSTEM");
		end

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_CANCELED, tonumber(auctionID));
	end
end

function EventHandler:ASMSG_AUCTION_OWNER_BID_NOTIFICATION(msg)
	local auctionID = split(":", msg);
	auctionID = tonumber(auctionID);

	if auctionID and not tContains(g_activeBidAuctionIDs, auctionID) then
		tinsert(g_activeBidAuctionIDs, auctionID);
	end

	SendChatMessageType(ERR_AUCTION_BID_PLACED, "SYSTEM");

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.BIDS_UPDATED);
end

function EventHandler:ASMSG_AUCTION_OUTBID_NOTIFICATION(msg)
	local _, itemID, itemSuffix = split(":", msg);

	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo({itemID = tonumber(itemID), itemSuffix = tonumber(itemSuffix)});
	if itemKeyInfo then
		SendChatMessageType(format(AUCTION_OUTBID_MAIL_SUBJECT, itemKeyInfo.itemName), "SYSTEM");
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.BIDS_UPDATED);
end

function EventHandler:ASMSG_AUCTION_REPLICATE_RESPONSE(msg)
	local _, _, unk1, desiredDelay = find(msg, "(%d*):?(%d+)$");

	if unk1 ~= "" then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.REPLICATE_ITEM_LIST_UPDATE);
	end

	CheckThrottledMessage(tonumber(desiredDelay));
end

function EventHandler:ASMSG_AUCTION_HOUSE_STATUS(msg)
	local npcGUID, status = split(":", msg);

	if status == "2" then
		StaticPopup_Show("AUCTION_HOUSE_DISABLED");

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_DISABLED);
	elseif status == "3" then
		ACTION_HOUSE_NPC_GUID = npcGUID;

		local minimalizeMode = GetCVarBool("miniTradeSkillFrame");
		if not minimalizeMode and (TradeSkillFrame and TradeSkillFrame:IsShown()) then
			TradeSkillFrame.minimalizeMode = true;
			SetCVar("miniTradeSkillFrame", 1);

			TradeSkillFrame_ToggleMode(true);
		end

		ShowUIPanel(AuctionHouseFrame);

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_SHOW);
	else
		ACTION_HOUSE_NPC_GUID = nil;
		HideUIPanel(AuctionHouseFrame);

		if TradeSkillFrame.minimalizeMode then
			TradeSkillFrame.minimalizeMode = false;
			SetCVar("miniTradeSkillFrame", 0);

			if TradeSkillFrame and TradeSkillFrame:IsShown() then
				TradeSkillFrame_ToggleMode(false);
			end
		end

		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.AUCTION_HOUSE_CLOSED);
	end
end