
function SetItemButtonQuality(button, quality)
	if button:GetAttribute("useCircularIconBorder") then
		button.IconBorder:Show();

		if quality == Enum.ItemQuality.Poor then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-gray");
		elseif quality == Enum.ItemQuality.Common then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-white");
		elseif quality == Enum.ItemQuality.Uncommon then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-green");
		elseif quality == Enum.ItemQuality.Rare then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-blue");
		elseif quality == Enum.ItemQuality.Epic then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-purple");
		elseif quality == Enum.ItemQuality.Legendary then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-orange");
		elseif quality == Enum.ItemQuality.Artifact then
			button.IconBorder:SetAtlas("auctionhouse-itemicon-border-artifact");
		else
			button.IconBorder:Hide();
		end

		return;
	end

	if quality then
		if BAG_ITEM_QUALITY_COLORS[quality] then
			if button.IconBorder then
				button.IconBorder:Show();
				button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			end
		else
			button.IconBorder:Hide();
		end
	else
		button.IconBorder:Hide();
	end
end

function SetItemButtonCount(button, count)
	if ( not button ) then
		return;
	end

	if ( not count ) then
		count = 0;
	end

	button.count = count;
	local countString = button.Count or _G[button:GetName().."Count"];
	if ( count > 1 or (button.isBag and count > 0) ) then
		if ( count > (button.maxDisplayCount or 9999) ) then
			count = "*";
		end
		countString:SetText(count);
		countString:Show();
	else
		countString:Hide();
	end
end

function SetItemButtonStock(button, numInStock)
	if ( not button ) then
		return;
	end

	if ( not numInStock ) then
		numInStock = "";
	end

	button.numInStock = numInStock;
	if ( numInStock > 0 ) then
		_G[button:GetName().."Stock"]:SetFormattedText(MERCHANT_STOCK, numInStock);
		_G[button:GetName().."Stock"]:Show();
	else
		_G[button:GetName().."Stock"]:Hide();
	end
end

function SetItemButtonTexture(button, texture)
	if ( not button ) then
		return;
	end

	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	if ( texture ) then
		icon:Show();
	else
		icon:Hide();
	end

	if button:GetAttribute("useCircularIconBorder") then
		SetPortraitToTexture(icon, texture);
	else
		SetPortraitToTexture(icon, "");
		icon:SetTexture(texture);
	end
end

function SetItemButtonTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	icon:SetVertexColor(r, g, b);
end

function SetItemButtonDesaturated(button, desaturated, r, g, b)
	if ( not button ) then
		return;
	end
	local icon = button.Icon or button.icon or _G[button:GetName().."IconTexture"];
	if ( not icon ) then
		return;
	end
	local shaderSupported = icon:SetDesaturated(desaturated);

	if ( not desaturated ) then
		r = 1.0;
		g = 1.0;
		b = 1.0;
	elseif ( not r or not shaderSupported ) then
		r = 0.5;
		g = 0.5;
		b = 0.5;
	end

	icon:SetVertexColor(r, g, b);
end

function SetItemButtonNormalTextureVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	_G[button:GetName().."NormalTexture"]:SetVertexColor(r, g, b);
end

function SetItemButtonNameFrameVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	local nameFrame = button.NameFrame or _G[button:GetName().."NameFrame"];
	nameFrame:SetVertexColor(r, g, b);
end

function SetItemButtonSlotVertexColor(button, r, g, b)
	if ( not button ) then
		return;
	end

	_G[button:GetName().."SlotTexture"]:SetVertexColor(r, g, b);
end

function HandleModifiedItemClick(link)
	if ( IsModifiedClick("CHATLINK") ) then
		if ( ChatEdit_InsertLink(link) ) then
			return true;
		end
	end
	if ( IsModifiedClick("DRESSUP") ) then
		DressUpItemLink(link);
		return true;
	end
	return false;
end

ItemButtonMixin = {};

function ItemButtonMixin:OnItemContextChanged()
	self:UpdateItemContextMatching();
end

function ItemButtonMixin:PostOnShow()
	self:UpdateItemContextMatching();

	local hasFunctionSet = self.GetItemContextMatchResult ~= nil;
	if hasFunctionSet then
		ItemButtonUtil.RegisterCallback(ItemButtonUtil.Event.ItemContextChanged, self.OnItemContextChanged, self);
	end
end

function ItemButtonMixin:PostOnHide()
	ItemButtonUtil.UnregisterCallback(ItemButtonUtil.Event.ItemContextChanged, self);
end

function ItemButtonMixin:SetMatchesSearch(matchesSearch)
	self.matchesSearch = matchesSearch;
	self:UpdateItemContextOverlay(self);
end

function ItemButtonMixin:GetMatchesSearch()
	return self.matchesSearch;
end

function ItemButtonMixin:UpdateItemContextMatching()
	local hasFunctionSet = self.GetItemContextMatchResult ~= nil;
	if hasFunctionSet then
		self.itemContextMatchResult = self:GetItemContextMatchResult();
	else
		self.itemContextMatchResult = ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end

	self:UpdateItemContextOverlay(self);
end

function ItemButtonMixin:UpdateItemContextOverlay()
	local matchesSearch = self.matchesSearch == nil or self.matchesSearch;
	local contextApplies = self.itemContextMatchResult ~= ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	local matchesContext = self.itemContextMatchResult == ItemButtonUtil.ItemContextMatchResult.Match;

	if self.ItemContextOverlay then
		if not matchesSearch or (contextApplies and not matchesContext) then
			self.ItemContextOverlay.Texture:SetTexture(0, 0, 0, 0.8);
			self.ItemContextOverlay:SetAllPoints(true);
			self.ItemContextOverlay:Show();
		else
			self.ItemContextOverlay:Hide();
		end
	end
end

function ItemButtonMixin:Reset()
	self:SetItemButtonCount(nil);
	SetItemButtonTexture(self, nil);
	SetItemButtonQuality(self, nil, nil);

	self.itemLink = nil;
	self:SetItemSource(nil);
end

function ItemButtonMixin:SetItemSource(itemLocation)
	self.itemLocation = itemLocation;
end

function ItemButtonMixin:SetItemLocation(itemLocation)
	self:SetItemSource(itemLocation);

	if itemLocation == nil or not C_Item.DoesItemExist(itemLocation) then
		self:SetItemInternal(nil);
		return itemLocation == nil;
	end

	return self:SetItemInternal(C_Item.GetItemLink(itemLocation));
end

-- item must be an itemID, item link or an item name.
function ItemButtonMixin:SetItem(item)
	self:SetItemSource(nil);
	return self:SetItemInternal(item);
end

function ItemButtonMixin:SetItemInternal(item)
	self.item = item;

	if not item then
		self:Reset();
		return true;
	end

	local itemLink, itemQuality, itemIcon = self:GetItemInfo();
	self.itemLink = itemLink;

	SetItemButtonTexture(self, itemIcon);
	SetItemButtonQuality(self, itemQuality, itemLink);
	return true;
end

function ItemButtonMixin:GetItemInfo()
	local itemLocation = self:GetItemLocation();
	if itemLocation then
		local itemLink = C_Item.GetItemLink(itemLocation);
		local itemQuality = C_Item.GetItemQuality(itemLocation);
		local itemIcon = C_Item.GetItemIcon(itemLocation);
		return itemLink, itemQuality, itemIcon;
	else
		local _, itemLink, itemQuality, _, _, _, _, _, _, itemIcon = GetItemInfo(self:GetItem());
		return itemLink, itemQuality, itemIcon;
	end
end

function ItemButtonMixin:GetItemID()
	local itemLink = self:GetItemLink();
	if not itemLink then
		return nil;
	end

	local itemID = tonumber(strmatch(itemLink, "item:(%d+)"));
	return itemID;
end

function ItemButtonMixin:GetItem()
	return self.item;
end

function ItemButtonMixin:GetItemLink()
	return self.itemLink;
end

function ItemButtonMixin:GetItemLocation()
	return self.itemLocation;
end

function ItemButtonMixin:SetItemButtonCount(count)
	SetItemButtonCount(self, count);
end

function ItemButtonMixin:GetItemButtonCount()
	return GetItemButtonCount(self);
end
--[[
function ItemButtonMixin:SetAlpha(alpha)
	self.icon:SetAlpha(alpha);
	self.IconBorder:SetAlpha(alpha);
	self.ItemContextOverlay:SetAlpha(alpha);
	self.Stock:SetAlpha(alpha);
	self.Count:SetAlpha(alpha);
end
]]