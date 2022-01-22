--	Filename:	Sirus_BlackMarket.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/


C_BlackMarket = {}

UIPanelWindows["BlackMarketFrame"] = { area = "doublewide", pushable = 0, width = 890, xOffset = "15", yOffset = "-10"}

StaticPopupDialogs["BID_BLACKMARKET"] = {
	text = BLACK_MARKET_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		SendServerMessage("ACMSG_BLACK_MARKET_BID", string.format("%d:%d", self.data.auctionID, self.data.bid))
	end,
	OnCancel = function() BlackMarketFrameBidButton:Enable() end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

function C_BlackMarket.GetNumItems()
	return #C_BlackMarket.itemDataByIndex
end

function C_BlackMarket.GetItemInfoByIndex( index )
	if not index then
		return nil
	end

	if C_BlackMarket.itemDataByIndex[index] then
		return unpack(C_BlackMarket.itemDataByIndex[index])
	end

	return nil
end

function C_BlackMarket.GetItemInfoByID( marketID )
	if not marketID then
		return nil
	end

	if C_BlackMarket.itemDataByID[marketID] then
		return unpack(C_BlackMarket.itemDataByID[marketID])
	end

	return nil
end

function C_BlackMarket.GetHotItem()
	if C_BlackMarket.itemHotData then
		return unpack(C_BlackMarket.itemHotData)
	end

	return nil
end

function BlackMarketFrame_OnLoad( self, ... )
	self.Artwork.Title:SetText(BLACK_MARKET_TITLE)
	self.Inset.NoItems:SetText(BLACK_MARKET_NO_ITEMS)

	self.MoneyFrameBorder:SetFrameLevel(self.art:GetFrameLevel() + 1)
	self.BidButton:SetFrameLevel(self.art:GetFrameLevel() + 1)

	self.HotDeal:SetPoint("TOPRIGHT", self.art.TopRightCorner, -33, -122)
	self.ColumnName:SetPoint("TOPLEFT", self.art.TopLeftCorner, "BOTTOMLEFT", 32, -20)

	BlackMarketScrollFrame.update = BlackMarketScrollFrame_Update
	BlackMarketScrollFrame.scrollBar.doNotHide = true
	BlackMarketScrollFrame.scrollBar.trackBG:SetVertexColor(0, 0, 0, 0.4)
	HybridScrollFrame_CreateButtons(BlackMarketScrollFrame, "BlackMarketItemTemplate", 5, -5)

	MoneyInputFrame_SetGoldOnly(BlackMarketBidPrice, true)

	BlackMarketBidPrice.gold:SetWidth(80)
	BlackMarketBidPrice.gold:SetMaxLetters(8)
	BlackMarketBidPrice.onValueChangedFunc = BlackMarketFrame_UpdateBidButton
end

function BlackMarketFrame_OnShow( self, ... )
	self.HotDeal:Hide()
	MoneyInputFrame_SetCopper(BlackMarketBidPrice, 0)

	-- if( C_BlackMarket.IsViewOnly() ) then
	-- 	BlackMarketFrame.BidButton:Hide()
	-- 	BlackMarketBidPrice:Hide()
	-- 	BlackMarketMoneyFrame:Hide()
	-- 	BlackMarketFrame.MoneyFrameBorder:Hide()
	-- else
		BlackMarketFrame.BidButton:Show()
		BlackMarketBidPrice:Show()
		BlackMarketMoneyFrame:Show()
		BlackMarketFrame.MoneyFrameBorder:Show()
	-- end

	BlackMarketFrame.BidButton:Disable()
	PlaySound("AuctionWindowOpen")

	BlackMarketScrollFrame_Update()
end

function BlackMarketFrame_OnHide( self, ... )
	PlaySound("AuctionWindowClose")
end

function BlackMarketScrollFrame_Update()
	local scrollFrame = BlackMarketScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index

	local numItems = C_BlackMarket.GetNumItems()

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if index <= numItems then
			local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetItemInfoByIndex(index)

			if name then
				button.Name:SetText(name)
				button.Item.IconTexture:SetTexture(texture)

				-- if ( not usable ) then
					-- button.Item.IconTexture:SetVertexColor(1.0, 0.1, 0.1)
				-- else
					button.Item.IconTexture:SetVertexColor(1.0, 1.0, 1.0)
				-- end

				SetItemButtonQuality(button.Item, quality, link)

				if (quality and quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
					button.Name:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
				else
					button.Name:SetTextColor(1.0, 0.82, 0)
				end

				button.Item.Count:SetText(quantity)
				button.Item.Count:SetShown(quantity > 1)
				button.Type:SetText(itemType)
				button.Seller:SetText(sellerName)
				button.Level:SetText(level)

				local bidAmount = currBid
				local minNextBid = math.floor((currBid + minIncrement) / 10000 + 0.5) * 10000
				if ( currBid == 0 ) then
					bidAmount = minBid
					minNextBid = minBid
				end
				MoneyFrame_Update(button.CurrentBid, bidAmount)

				button.minNextBid = minNextBid
				button.YourBid:SetShown(youHaveHighBid)

				button.TimeLeft.Text:SetText(_G["AUCTION_TIME_LEFT"..timeLeft])
				button.TimeLeft.tooltip = _G["AUCTION_TIME_LEFT"..timeLeft.."_DETAIL"]

				button.itemLink = link
				button.marketID = marketID
				if ( marketID == BlackMarketFrame.selectedMarketID ) then
					button.Selection:Show()
				else
					button.Selection:Hide()
				end

				button:Show()
			end
		else
			button:Hide()
		end
	end

	local totalHeight = numItems * scrollFrame.buttonHeight
	local displayedHeight = numButtons * scrollFrame.buttonHeight
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end

function BlackMarketFrame_UpdateBidButton()
	local enabled = false
	if ( BlackMarketFrame.selectedMarketID ) then
		local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetItemInfoByID(BlackMarketFrame.selectedMarketID)
		if ( timeLeft > 0 and not youHaveHighBid and GetMoney() >= MoneyInputFrame_GetCopper(BlackMarketBidPrice) ) then
			enabled = true
		end
	end
	BlackMarketFrame.BidButton:SetEnabled(enabled)
end

function BlackMarketItem_OnClick(self, button, down)
	MoneyInputFrame_SetCopper(BlackMarketBidPrice, self.minNextBid)
	BlackMarketFrame.selectedMarketID = self.marketID
	BlackMarketScrollFrame_Update()
end

function BlackMarketFrame_UpdateHotItem(self)
	local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetHotItem()
	if ( name ) then
		self.HotDeal.Name:SetText(name)

		self.HotDeal.Item.IconTexture:SetTexture(texture)
		if ( not usable ) then
			self.HotDeal.Item.IconTexture:SetVertexColor(1.0, 0.1, 0.1)
		else
			self.HotDeal.Item.IconTexture:SetVertexColor(1.0, 1.0, 1.0)
		end

		SetItemButtonQuality(self.HotDeal.Item, quality, link)

		if (quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
			self.HotDeal.Name:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
		else
			self.HotDeal.Name:SetTextColor(1.0, 0.82, 0)
		end

		self.HotDeal.Item.Count:SetText(quantity)
		self.HotDeal.Item.Count:SetShown(quantity > 1)

		self.HotDeal.Type:SetText(itemType)

		self.HotDeal.Seller:SetText(sellerName)

		if (level > 1) then
			self.HotDeal.Level:SetText(level)
		else
			self.HotDeal.Level:SetText("")
		end

		local bidAmount = currBid
		if ( currBid == 0 ) then
			bidAmount = minBid
		end
		MoneyFrame_Update(HotItemCurrentBidMoneyFrame, bidAmount)

		self.HotDeal.TimeLeft.Text:SetFormattedText(BLACK_MARKET_HOT_ITEM_TIME_LEFT, _G["AUCTION_TIME_LEFT"..timeLeft])
		self.HotDeal.TimeLeft.tooltip = _G["AUCTION_TIME_LEFT"..timeLeft.."_DETAIL"]
		self.HotDeal.itemLink = link
		self.HotDeal.selectedMarketID = marketID
		self.HotDeal.BlackMarketHotItemBidPrice.YourBid:SetShown(youHaveHighBid)
		self.HotDeal:Show()
	end
end

function BlackMarketBid_OnClick(self, button, down)
	if (BlackMarketFrame.selectedMarketID) then
		BlackMarketFrame_ConfirmBid(BlackMarketFrame.selectedMarketID)
	end
	self:Disable()
end

function BlackMarketFrame_ConfirmBid(auctionID)
	local bid = MoneyInputFrame_GetCopper(BlackMarketBidPrice)
	local name, texture, quantity, _, _, _, _, _, _, _, _, _, _, _, link, _, quality = C_BlackMarket.GetItemInfoByID(auctionID)
	local r, g, b = GetItemQualityColor(quality)
	local data = {	["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1},
					["link"] = link, ["count"] = quantity,
					["bid"] = bid, ["auctionID"] = auctionID,
	}
	StaticPopup_Show("BID_BLACKMARKET", GetMoneyString(bid), nil, data)
end

function BlackMarketItem_OnEnter(self)
	local parent = self:GetParent()
	parent:LockHighlight()
	if ( parent.itemLink ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(parent.itemLink)
	else
		GameTooltip:Hide()
	end
end

function EventHandler:ASMSG_BLACK_MARKET_LIST( msg )
	local listData = {strsplit("|", msg)}

	C_BlackMarket.itemDataByIndex = {}
	C_BlackMarket.itemDataByID = {}
	C_BlackMarket.itemHotData = {}

	for i = 1, #listData do
		local id, itemEntry, itemCount, creatureName, lastBet, timeLeft, flags = string.match(listData[i], "(%d+):(%d+):(%d+):(.-):(%d+):(%d+):(%d+)")
		if id then
			id 				= tonumber(id)
			itemEntry 		= tonumber(itemEntry)
			itemCount 		= tonumber(itemCount)
			creatureName 	= creatureName
			lastBet 		= tonumber(lastBet)
			timeLeft 		= tonumber(timeLeft)
			flags 			= tonumber(flags)

			local _name, _link, _quality, _iLevel, _reqLevel, _class, _subclass, _maxStack, _equipSlot, _texture, _vendorPrice = GetItemInfo(itemEntry)

			local name 				= _name
			local texture 			= _texture
			local quantity 			= itemCount
			local itemType			= _subclass
			local usable 			= true
			local level 			= _iLevel
			local levelType 		= -1
			local sellerName 		= creatureName
			local minBid 			= (lastBet * 1.05)
			local minIncrement 		= (lastBet * 0.05)
			local currBid 			= lastBet
			local youHaveHighBid 	= bit.band(flags, 1) ~= 0
			local numBids 			= -1
			local timeLeft 			= timeLeft
			local link 				= _link
			local marketID 			= id
			local quality 			= _quality
			local flag 				= flags
			local isHot				= bit.band(flags, 2) ~= 0

			local data = {name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality, flag}

			if isHot then
				C_BlackMarket.itemHotData = data
			end

			table.insert(C_BlackMarket.itemDataByIndex, data)
			C_BlackMarket.itemDataByID[marketID] = data
		end
	end

	local numItems = C_BlackMarket.GetNumItems()
	BlackMarketFrame.Inset.NoItems:SetShown(not numItems or numItems <= 0)

	if not BlackMarketFrame:IsShown() then
		ShowUIPanel(BlackMarketFrame)
	end

	BlackMarketScrollFrame_Update()
	BlackMarketFrame_UpdateHotItem(BlackMarketFrame)
	BlackMarketFrame_UpdateBidButton()
end

function EventHandler:ASMSG_BLACK_MARKET_CLOSE( msg )
	if BlackMarketFrame:IsShown() then
		HideUIPanel(BlackMarketFrame)
	end
end

function EventHandler:ASMSG_BLACK_MARKET_BID_R( msg )
	local errorString = ""

	msg = tonumber(msg)

	if msg == 1 then
		errorString = BLACK_MARKET_ERROR_1
	elseif msg == 2 then
		errorString = BLACK_MARKET_ERROR_2
	elseif msg == 3 then
		errorString = BLACK_MARKET_ERROR_3
	elseif msg == 4 then
		errorString = BLACK_MARKET_ERROR_4
	elseif msg == 5 then
		errorString = BLACK_MARKET_ERROR_5
	elseif msg == 6 then
		errorString = BLACK_MARKET_ERROR_6
	end

	UIErrorsFrame:AddMessage(errorString, 1.0, 0.1, 0.1, 1.0)
	BlackMarketFrameBidButton:Enable()
	BlackMarketFrame_UpdateBidButton()
end