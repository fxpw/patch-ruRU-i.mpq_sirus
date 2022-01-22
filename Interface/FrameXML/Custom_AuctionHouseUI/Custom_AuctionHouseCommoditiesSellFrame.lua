
AuctionHouseCommoditiesSellFrameMixin = CreateFromMixins(AuctionHouseSellFrameMixin);

local COMMODITIES_SELL_FRAME_CUSTOM_EVENTS = {
	"COMMODITY_SEARCH_RESULTS_UPDATED",
};

function AuctionHouseCommoditiesSellFrameMixin:OnLoad()
	AuctionHouseSellFrameMixin.OnLoad(self);
end

function AuctionHouseCommoditiesSellFrameMixin:Init()
	if self.isInitialized then
		return;
	end

	self.isInitialized = true;

	self:SetSearchContext(AuctionHouseSearchContext.SellCommodities);

	local commoditiesSellList = self:GetCommoditiesSellList();
	commoditiesSellList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithLink(self, self.OnAuctionSelected));

	commoditiesSellList:RefreshScrollFrame();
end

function AuctionHouseCommoditiesSellFrameMixin:OnShow()
	AuctionHouseSellFrameMixin.OnShow(self);

	FrameUtil.RegisterFrameForCustomEvents(self, COMMODITIES_SELL_FRAME_CUSTOM_EVENTS);

	self.PriceInput.PerItemPostfix:Show();

	-- We need to use a separate Init instead of OnLoad to avoid load order problems.
	self:Init();
end

function AuctionHouseCommoditiesSellFrameMixin:OnHide()
	AuctionHouseSellFrameMixin.OnHide(self);

	FrameUtil.UnregisterFrameForCustomEvents(self, COMMODITIES_SELL_FRAME_CUSTOM_EVENTS);
end

function AuctionHouseCommoditiesSellFrameMixin:OnEvent(event, ...)
	AuctionHouseSellFrameMixin.OnEvent(self, event, ...);

	if event == "COMMODITY_SEARCH_RESULTS_UPDATED" then
		self:UpdatePriceSelection();
	end
end

function AuctionHouseCommoditiesSellFrameMixin:UpdatePriceSelection()
	self:ClearSearchResultPrice();
	
	if self:GetUnitPrice() == self:GetDefaultPrice() then
		local itemLocation = self:GetItem();
		if itemLocation and itemLocation:IsValid() then
			local firstSearchResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemLocation:IsValid(), 1);
			if firstSearchResult then
				self:GetCommoditiesSellList():SetSelectedEntry(firstSearchResult);
			end
		end
	end
end

function AuctionHouseCommoditiesSellFrameMixin:OnAuctionSelected(commoditySearchResult)
	self.PriceInput:SetAmount(commoditySearchResult.unitPrice);
	self:SetSearchResultPrice(commoditySearchResult.unitPrice);
end

function AuctionHouseCommoditiesSellFrameMixin:GetUnitPrice()
	local unitPrice = self.PriceInput:GetAmount();
	return unitPrice;
end

function AuctionHouseCommoditiesSellFrameMixin:GetDepositAmount()
	local item = self:GetItem();
	if not item then
		return 0;
	end

	local itemID = item:IsValid();
	if itemID then
		local duration = self:GetDuration();
		local quantity = self:GetQuantity();
		local deposit = C_AuctionHouse.CalculateCommodityDeposit(itemID, duration, quantity);
		return deposit;
	else
		return 0;
	end
end

function AuctionHouseCommoditiesSellFrameMixin:GetTotalPrice()
	return self:GetQuantity() * self:GetUnitPrice();
end

function AuctionHouseCommoditiesSellFrameMixin:CanPostItem()
	local canPostItem, reasonTooltip = AuctionHouseSellFrameMixin.CanPostItem(self);
	if not canPostItem then
		return canPostItem, reasonTooltip;
	end
	
	local unitPrice = self:GetUnitPrice();
	if unitPrice == 0 then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_PRICE;
	elseif unitPrice > MAXIMUM_BID_PRICE then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_MAX_PRICE;
	end

	return true, nil;
end

function AuctionHouseCommoditiesSellFrameMixin:PostItem()
	if not self:CanPostItem() then
		return;
	end

	local item = self:GetItem();
	local duration = self:GetDuration();
	local quantity = self:GetQuantity();
	local unitPrice = self:GetUnitPrice();
	C_AuctionHouse.PostCommodity(item, duration, quantity, unitPrice);

	local fromItemDisplay = nil;
	local refreshListWithPreviousItem = true;
	self:SetItem(nil, fromItemDisplay, refreshListWithPreviousItem);
end

function AuctionHouseCommoditiesSellFrameMixin:SetItem(itemLocation, fromItemDisplay, refreshListWithPreviousItem)
	local previousItemLocation = self:GetItem();
	
	AuctionHouseSellFrameMixin.SetItem(self, itemLocation, fromItemDisplay);

	local itemKey = itemLocation and C_AuctionHouse.GetItemKeyFromItem(itemLocation) or nil;
	if refreshListWithPreviousItem then
		local previousItemKey = previousItemLocation and C_AuctionHouse.GetItemKeyFromItem(previousItemLocation) or nil;
		if previousItemKey then
			itemKey = previousItemKey;
		end
	end

	if itemKey then
		self:GetAuctionHouseFrame():QueryItem(self:GetSearchContext(), itemKey);
	end

	self:UpdatePriceSelection();

	if itemLocation and itemLocation:IsBagAndSlot() then
		local bagID, slotID = itemLocation:GetBagAndSlot()
		if bagID and slotID then
			self.QuantityInput:SetQuantity(select(2, GetContainerItemInfo(bagID, slotID)) or 1);

			-- Hack fix for a spacing problem: Without this line, the edit box would be scrolled to
			-- the left and the text would not be visible. This seems to be a problem with setting
			-- the text on the edit box and showing it in the same frame.
			self.QuantityInput.InputBox:SetCursorPosition(0);
		end
	end

	self:GetCommoditiesSellList():SetItemID(itemKey and itemKey.itemID or nil);
end

function AuctionHouseCommoditiesSellFrameMixin:GetCommoditiesSellList()
	local commoditiesSellList = self:GetAuctionHouseFrame():GetCommoditiesSellListFrames();
	return commoditiesSellList;
end

function AuctionHouseCommoditiesSellFrameMixin:GetCommoditiesSellListFrames()
	return self:GetAuctionHouseFrame():GetCommoditiesSellListFrames();
end
