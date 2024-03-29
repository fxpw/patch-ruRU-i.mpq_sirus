
MONEY_ICON_WIDTH = 19;
MONEY_ICON_WIDTH_SMALL = 13;

MONEY_BUTTON_SPACING = -4;
MONEY_BUTTON_SPACING_SMALL = -4;

MONEY_TEXT_VADJUST = 0;

COPPER_PER_SILVER = 100;
SILVER_PER_GOLD = 100;
COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD;

COIN_BUTTON_WIDTH = 32;

MoneyTypeInfo = { };
MoneyTypeInfo["PLAYER"] = {
	UpdateFunc = function(self)
		return (GetMoney() - GetCursorMoney() - GetPlayerTradeMoney());
	end,

	PickupFunc = function(self, amount)
		PickupPlayerMoney(amount);
	end,

	DropFunc = function(self)
		DropCursorMoney();
	end,

	collapse = 1,
	canPickup = 1,
	showSmallerCoins = "Backpack"
};
MoneyTypeInfo["STATIC"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
};
MoneyTypeInfo["AUCTION"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = "Backpack",
	fixedWidth = 1,
	collapse = 1,
	truncateSmallCoins = nil,
};
MoneyTypeInfo["PLAYER_TRADE"] = {
	UpdateFunc = function(self)
		return GetPlayerTradeMoney();
	end,

	PickupFunc = function(self, amount)
		PickupTradeMoney(amount);
	end,

	DropFunc = function(self)
		AddTradeMoney();
	end,

	collapse = 1,
	canPickup = 1,
};
MoneyTypeInfo["TARGET_TRADE"] = {
	UpdateFunc = function(self)
		if TradeFrame:IsShown() and GetTargetTradeMoney() > 10000 then
			TradeFrame_OnEvent(TradeFrame, "PLAYER_TRADE_MONEY_UPDATE")
		end
		return GetTargetTradeMoney();
	end,

	collapse = 1,
};
MoneyTypeInfo["SEND_MAIL"] = {
	UpdateFunc = function(self)
		return GetSendMailMoney();
	end,

	PickupFunc = function(self, amount)
		PickupSendMailMoney(amount);
	end,

	DropFunc = function(self)
		AddSendMailMoney();
	end,

	collapse = nil,
	canPickup = 1,
	showSmallerCoins = "Backpack",
};
MoneyTypeInfo["SEND_MAIL_COD"] = {
	UpdateFunc = function(self)
		return GetSendMailCOD();
	end,

	PickupFunc = function(self, amount)
		PickupSendMailCOD(amount);
	end,

	DropFunc = function(self)
		AddSendMailCOD();
	end,

	collapse = 1,
	canPickup = 1,
};
MoneyTypeInfo["GUILDBANK"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("GUILDBANK_UPDATE_MONEY");
	end,

	UpdateFunc = function(self)
		return (GetGuildBankMoney() - GetCursorMoney());
	end,

	PickupFunc = function(self, amount)
		PickupGuildBankMoney(amount);
	end,

	DropFunc = function(self)
		DropCursorMoney();
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};

MoneyTypeInfo["GUILDBANKWITHDRAW"] = {
	OnloadFunc = function(self)
		self:RegisterEvent("GUILDBANK_UPDATE_WITHDRAWMONEY");
	end,

	UpdateFunc = function(self)
		GuildBankFrame_UpdateWithdrawMoney();
		return nil;
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};

MoneyTypeInfo["GUILD_REPAIR"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,

	collapse = 1,
	showSmallerCoins = "Backpack",
};
MoneyTypeInfo["BLACKMARKET"] = {
	UpdateFunc = function(self)
		return self.staticMoney;
	end,
	showSmallerCoins = nil,
	fixedWidth = 1,
	collapse = 1,
};



function MoneyFrame_OnLoad (self)
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("PLAYER_TRADE_MONEY");
	self:RegisterEvent("TRADE_MONEY_CHANGED");
	self:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
	self:RegisterEvent("SEND_MAIL_COD_CHANGED");
	MoneyFrame_SetType(self, "PLAYER");
end

function SmallMoneyFrame_OnLoad(self, moneyType)
	--If there's a moneyType we'll use the new way of doing things, otherwise do things the old way
	if ( moneyType ) then
		local info = MoneyTypeInfo[moneyType];
		if ( info and info.OnloadFunc ) then
			--This way you can just register for the events that you care about
			--Should write OnloadFunc's for all money frames, but don't have time right now
			info.OnloadFunc(self);
			self.small = 1;
			MoneyFrame_SetType(self, moneyType);
		end
	else
		--The old sucky way of doing things
		self:RegisterEvent("PLAYER_MONEY");
		self:RegisterEvent("PLAYER_TRADE_MONEY");
		self:RegisterEvent("TRADE_MONEY_CHANGED");
		self:RegisterEvent("SEND_MAIL_MONEY_CHANGED");
		self:RegisterEvent("SEND_MAIL_COD_CHANGED");
		self.small = 1;
		MoneyFrame_SetType(self, "PLAYER");
	end
end

function MoneyFrame_OnEvent (self, event, ...)
	if ( not self.info or not self:IsVisible() ) then
		return;
	end

	local moneyType = self.moneyType;
	
	if ( event == "PLAYER_MONEY" and moneyType == "PLAYER" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "PLAYER_TRADE_MONEY" and (moneyType == "PLAYER" or moneyType == "PLAYER_TRADE") ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "TRADE_MONEY_CHANGED" and moneyType == "TARGET_TRADE" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "SEND_MAIL_MONEY_CHANGED" and (moneyType == "PLAYER" or moneyType == "SEND_MAIL") ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "SEND_MAIL_COD_CHANGED" and (moneyType == "PLAYER" or moneyType == "SEND_MAIL_COD") ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "GUILDBANK_UPDATE_MONEY" and moneyType == "GUILDBANK" ) then
		MoneyFrame_UpdateMoney(self);
	elseif ( event == "GUILDBANK_UPDATE_WITHDRAWMONEY" and moneyType == "GUILDBANKWITHDRAW" ) then
		MoneyFrame_UpdateMoney(self);
	end
end

function MoneyFrame_SetType(self, type)

	local info = MoneyTypeInfo[type];
	if ( not info ) then
		message("Invalid money type: "..type);
		return;
	end
	self.info = info;
	self.moneyType = type;
	local frameName = self:GetName();
	if ( info.canPickup ) then
		_G[frameName.."GoldButton"]:EnableMouse(true);
		_G[frameName.."SilverButton"]:EnableMouse(true);
		_G[frameName.."CopperButton"]:EnableMouse(true);
	else
		_G[frameName.."GoldButton"]:EnableMouse(false);
		_G[frameName.."SilverButton"]:EnableMouse(false);
		_G[frameName.."CopperButton"]:EnableMouse(false);
	end

	MoneyFrame_UpdateMoney(self);
end

-- Update the money shown in a money frame
function MoneyFrame_UpdateMoney(moneyFrame)
	assert(moneyFrame);

	if ( moneyFrame.info ) then
		local money = moneyFrame.info.UpdateFunc(moneyFrame);
		if ( money ) then
			MoneyFrame_Update(moneyFrame:GetName(), money);
		end
		if ( moneyFrame.hasPickup == 1 ) then
			UpdateCoinPickupFrame(money);
		end
	else
		message("Error moneyType not set");
	end
end

local function CreateMoneyButtonNormalTexture (button, iconWidth)
	local texture = button:CreateTexture();
	texture:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons");
	texture:SetWidth(iconWidth);
	texture:SetHeight(iconWidth);
	texture:SetPoint("RIGHT");
	button:SetNormalTexture(texture);
	
	return texture;
end

function MoneyFrame_Update(frameName, money, forceShow)
	local frame;
	if ( type(frameName) == "table" ) then
		frame = frameName;
		frameName = frame:GetName();
	else
		frame = _G[frameName];
	end
	
	local info = frame.info;
	if ( not info ) then
		message("Error moneyType not set");
	end

	-- Breakdown the money into denominations
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

	local goldButton = _G[frameName.."GoldButton"];
	local silverButton = _G[frameName.."SilverButton"];
	local copperButton = _G[frameName.."CopperButton"];

	local iconWidth = MONEY_ICON_WIDTH;
	local spacing = MONEY_BUTTON_SPACING;
	if ( frame.small ) then
		iconWidth = MONEY_ICON_WIDTH_SMALL;
		spacing = MONEY_BUTTON_SPACING_SMALL;
	end

	-- Set values for each denomination
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		if ( not frame.colorblind or not frame.vadjust or frame.vadjust ~= MONEY_TEXT_VADJUST ) then
			frame.colorblind = true;
			frame.vadjust = MONEY_TEXT_VADJUST;
			goldButton:SetNormalTexture("");
			silverButton:SetNormalTexture("");
			copperButton:SetNormalTexture("");
			_G[frameName.."GoldButtonText"]:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
			_G[frameName.."SilverButtonText"]:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
			_G[frameName.."CopperButtonText"]:SetPoint("RIGHT", 0, MONEY_TEXT_VADJUST);
		end
		goldButton:SetText(gold .. GOLD_AMOUNT_SYMBOL);
		goldButton:SetWidth(goldButton:GetTextWidth());
		goldButton:Show();
		silverButton:SetText(silver .. SILVER_AMOUNT_SYMBOL);
		silverButton:SetWidth(silverButton:GetTextWidth());
		silverButton:Show();
		copperButton:SetText(copper .. COPPER_AMOUNT_SYMBOL);
		copperButton:SetWidth(copperButton:GetTextWidth());
		copperButton:Show();
	else
		if ( frame.colorblind or not frame.vadjust or frame.vadjust ~= MONEY_TEXT_VADJUST ) then
			frame.colorblind = nil;
			frame.vadjust = MONEY_TEXT_VADJUST;
			local texture = CreateMoneyButtonNormalTexture(goldButton, iconWidth);
			texture:SetTexCoord(0, 0.25, 0, 1);
			texture = CreateMoneyButtonNormalTexture(silverButton, iconWidth);
			texture:SetTexCoord(0.25, 0.5, 0, 1);
			texture = CreateMoneyButtonNormalTexture(copperButton, iconWidth);
			texture:SetTexCoord(0.5, 0.75, 0, 1);
			_G[frameName.."GoldButtonText"]:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
			_G[frameName.."SilverButtonText"]:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
			_G[frameName.."CopperButtonText"]:SetPoint("RIGHT", -iconWidth, MONEY_TEXT_VADJUST);
		end
		goldButton:SetText(gold);
		goldButton:SetWidth(goldButton:GetTextWidth() + iconWidth);
		goldButton:Show();
		silverButton:SetText(silver);
		silverButton:SetWidth(silverButton:GetTextWidth() + iconWidth);
		silverButton:Show();
		copperButton:SetText(copper);
		copperButton:SetWidth(copperButton:GetTextWidth() + iconWidth);
		copperButton:Show();
	end
		
	-- Store how much money the frame is displaying
	frame.staticMoney = money;

	-- If not collapsable don't need to continue
	if ( not info.collapse ) then
		return;
	end

	local width = iconWidth;

	local showLowerDenominations, truncateCopper;
	if ( gold > 0 ) then
		width = width + goldButton:GetWidth();
		if ( info.showSmallerCoins ) then
			showLowerDenominations = 1;
		end
		if ( info.truncateSmallCoins ) then
			truncateCopper = 1;
		end
	else
		goldButton:Hide();
	end

	goldButton:ClearAllPoints();
	if ( silver > 0 or showLowerDenominations ) then
		-- Exception if showLowerDenominations and fixedWidth
		if ( showLowerDenominations and info.fixedWidth ) then
			silverButton:SetWidth(COIN_BUTTON_WIDTH);
		end
		
		width = width + silverButton:GetWidth();
		goldButton:SetPoint("RIGHT", frameName.."SilverButton", "LEFT", spacing, 0);
		if ( goldButton:IsShown() ) then
			width = width - spacing;
		end
		if ( info.showSmallerCoins ) then
			showLowerDenominations = 1;
		end
	else
		silverButton:Hide();
		goldButton:SetPoint("RIGHT", frameName.."SilverButton",	"RIGHT", 0, 0);
	end

	-- Used if we're not showing lower denominations
	silverButton:ClearAllPoints();
	if ( (copper > 0 or showLowerDenominations or info.showSmallerCoins == "Backpack" or forceShow) and not truncateCopper) then
		-- Exception if showLowerDenominations and fixedWidth
		if ( showLowerDenominations and info.fixedWidth ) then
			copperButton:SetWidth(COIN_BUTTON_WIDTH);
		end
		
		width = width + copperButton:GetWidth();
		silverButton:SetPoint("RIGHT", frameName.."CopperButton", "LEFT", spacing, 0);
		if ( silverButton:IsShown() or goldButton:IsShown() ) then
			width = width - spacing;
		end
	else
		copperButton:Hide();
		silverButton:SetPoint("RIGHT", frameName.."CopperButton", "RIGHT", 0, 0);
	end

	-- make sure the copper button is in the right place
	copperButton:ClearAllPoints();
	copperButton:SetPoint("RIGHT", frameName, "RIGHT", -13, 0);

	-- attach text now that denominations have been computed
	local prefixText = _G[frameName.."PrefixText"];
	if ( prefixText ) then
		if ( prefixText:GetText() and money > 0 ) then
			prefixText:Show();
			copperButton:ClearAllPoints();
			copperButton:SetPoint("RIGHT", frameName.."PrefixText", "RIGHT", width, 0);
			width = width + prefixText:GetWidth();
		else
			prefixText:Hide();
		end
	end
	local suffixText = _G[frameName.."SuffixText"];
	if ( suffixText ) then
		if ( suffixText:GetText() and money > 0 ) then
			suffixText:Show();
			suffixText:ClearAllPoints();
			suffixText:SetPoint("LEFT", frameName.."CopperButton", "RIGHT", 0, 0);
			width = width + suffixText:GetWidth();
		else
			suffixText:Hide();
		end
	end

	frame:SetWidth(width);
end

function RefreshMoneyFrame(frameName, money, small, collapse, showSmallerCoins)
	--[[
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);

	local goldButton = _G[frameName.."GoldButton"];
	local silverButton = _G[frameName.."SilverButton"];
	local copperButton = _G[frameName.."CopperButton"];

	local iconWidth = MONEY_ICON_WIDTH;
	local spacing = MONEY_BUTTON_SPACING;
	if ( small > 0 ) then
		iconWidth = MONEY_ICON_WIDTH_SMALL;
		spacing = MONEY_BUTTON_SPACING_SMALL;
	end

	goldButton:SetText(gold);
	goldButton:SetWidth(goldButton:GetTextWidth() + iconWidth);
	goldButton:Show();
	silverButton:SetText(silver);
	silverButton:SetWidth(silverButton:GetTextWidth() + iconWidth);
	silverButton:Show();
	copperButton:SetText(copper);
	copperButton:SetWidth(copperButton:GetTextWidth() + iconWidth);
	copperButton:Show();

	local frame = _G[frameName];
	frame.staticMoney = money;

	if ( collapse == 0 ) then
		return;
	end

	local width = 13;
	local showLowerDenominations;
	if ( gold > 0 ) then
		width = width + goldButton:GetWidth();
		if ( showSmallerCoins ) then
			showLowerDenominations = 1;
		end
	else
		goldButton:Hide();
	end

	if ( silver > 0 or showLowerDenominations ) then
		width = width + silverButton:GetWidth();
		goldButton:SetPoint("RIGHT", frameName.."SilverButton", "LEFT", spacing, 0);
		if ( goldButton:IsShown() ) then
			width = width - spacing;
		end
		if ( showSmallerCoins ) then
			showLowerDenominations = 1;
		end
	else
		silverButton:Hide();
		goldButton:SetPoint("RIGHT", frameName.."SilverButton",	"RIGHT", 0, 0);
	end

	-- Used if we're not showing lower denominations
	if ( copper > 0 or showLowerDenominations or showSmallerCoins == "Backpack") then
		width = width + copperButton:GetWidth();
		silverButton:SetPoint("RIGHT", frameName.."CopperButton", "LEFT", spacing, 0);
		if ( silverButton:IsShown() ) then
			width = width - spacing;
		end
	else
		copperButton:Hide();
		silverButton:SetPoint("RIGHT", frameName.."CopperButton", "RIGHT", 0, 0);
	end

	frame:SetWidth(width);

	]]
end

function SetMoneyFrameColor(frameName, color)
	local moneyFrame = _G[frameName];
	if ( not moneyFrame ) then
		return;
	end
	local fontObject;
	if ( moneyFrame.small ) then
		if ( color == "yellow" ) then
			fontObject = NumberFontNormalRightYellow;
		elseif ( color == "red" ) then
			fontObject = NumberFontNormalRightRed;
		else
			fontObject = NumberFontNormalRight;
		end
	else
		if ( color == "yellow"  ) then
			fontObject = NumberFontNormalLargeRightYellow;
		elseif ( color == "red" ) then
			fontObject = NumberFontNormalLargeRightRed;
		else
			fontObject = NumberFontNormalLargeRight;
		end
	end
	
	local goldButton = _G[frameName.."GoldButton"];
	local silverButton = _G[frameName.."SilverButton"];
	local copperButton = _G[frameName.."CopperButton"];

	goldButton:SetNormalFontObject(fontObject);
	silverButton:SetNormalFontObject(fontObject);
	copperButton:SetNormalFontObject(fontObject);
end

function AltCurrencyFrame_Update(frameName, texture, cost)
	local iconWidth;
	local button = _G[frameName];
	local buttonTexture = _G[frameName.."Texture"];
	button:SetText(cost);
	buttonTexture:SetTexture(texture);
	iconWidth = MONEY_ICON_WIDTH_SMALL;
	buttonTexture:SetPoint("LEFT", _G[frameName.."Text"], "RIGHT", 0, 0);
	buttonTexture:SetWidth(iconWidth);
	buttonTexture:SetHeight(iconWidth);
	button:SetWidth(button:GetTextWidth() + MONEY_ICON_WIDTH_SMALL);
end

function AltCurrencyFrame_PointsUpdate(frameName, honor, arena)
	local buttonHonor = _G[frameName.."Honor"];
	if ( honor and honor > 0 ) then
		buttonHonor.pointType = HONOR_POINTS;
		local factionGroup = UnitFactionGroup("player");
		local honorTexture = "Interface\\PVPFrame\\PVPCurrency-Honor1-"..factionGroup;
		-- if ( factionGroup ) then
		-- 	honorTexture = "Interface\\TargetingFrame\\UI-PVP-"..factionGroup;
		-- end
		AltCurrencyFrame_Update( frameName.."Honor", honorTexture, honor );
		buttonHonor:Show();
	else
		buttonHonor:Hide();
	end
	
	local buttonArena = _G[frameName.."Arena"];
	if ( arena and arena > 0 ) then
		buttonHonor.pointType = ARENA_POINTS;
		local englishFaction = UnitFactionGroup("player")
		AltCurrencyFrame_Update( frameName.."Arena", "Interface\\PVPFrame\\PVPCurrency-Conquest1-"..englishFaction, arena );
		if ( honor and honor > 0 ) then
			buttonArena:SetPoint("LEFT", buttonHonor, "RIGHT", 0, 0);
		else
			buttonArena:SetPoint("LEFT", frameName, "LEFT", 13, 0);
		end
		buttonArena:Show();
		return buttonArena;
	else
		buttonArena:Hide();
	end
	return buttonHonor;
end

function GetDenominationsFromCopper(money)
	return GetCoinText(money, " ");
end

function GetMoneyString(money)
	local goldString, silverString, copperString;
	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
	
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		goldString = gold..GOLD_AMOUNT_SYMBOL;
		silverString = silver..SILVER_AMOUNT_SYMBOL;
		copperString = copper..COPPER_AMOUNT_SYMBOL;
	else
		goldString = format(GOLD_AMOUNT_TEXTURE, gold, 0, 0);
		silverString = format(SILVER_AMOUNT_TEXTURE, silver, 0, 0);
		copperString = format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
	end
	
	local moneyString = "";
	local separator = "";	
	if ( gold > 0 ) then
		moneyString = goldString;
		separator = " ";
	end
	if ( silver > 0 ) then
		moneyString = moneyString..separator..silverString;
		separator = " ";
	end
	if ( copper > 0 or moneyString == "" ) then
		moneyString = moneyString..separator..copperString;
	end
	
	return moneyString;
end


-- Tex coords for Interface\MoneyFrame\UI-MoneyIcons
local TextureType = {
	File = 1,
	Atlas = 2,
};

MoneyDenominationDisplayType = {
	Copper = { TextureType.File, [[Interface\MoneyFrame\UI-MoneyIcons]], 0.5, 0.75, 0, 1, },
	Silver = { TextureType.File, [[Interface\MoneyFrame\UI-MoneyIcons]], 0.25, 0.5, 0, 1, },
	Gold = { TextureType.File, [[Interface\MoneyFrame\UI-MoneyIcons]], 0, 0.25, 0, 1, },
	AuctionHouseCopper = { TextureType.Atlas, "auctionhouse-icon-coin-copper" },
	AuctionHouseSilver = { TextureType.Atlas, "auctionhouse-icon-coin-silver" },
	AuctionHouseGold = { TextureType.Atlas, "auctionhouse-icon-coin-gold" },
};

MONEY_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE = {
	[MoneyDenominationDisplayType.Copper] = COPPER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.Silver] = SILVER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.Gold] = GOLD_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.AuctionHouseCopper] = COPPER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.AuctionHouseSilver] = SILVER_AMOUNT_SYMBOL,
	[MoneyDenominationDisplayType.AuctionHouseGold] = GOLD_AMOUNT_SYMBOL,
};

MoneyDenominationDisplayMixin = {};

function MoneyDenominationDisplayMixin:OnLoad()
	self.amount = 0;
	
	if self.displayType == nil then
		error("A money denomination display needs a type. Add a KeyValue entry, displayType = MoneyDenominationDisplayType.[Copper|Silver|Gold|AuctionHouseCopper|AuctionHouseSilver|AuctionHouseGold].");
		return;
	end

	self:UpdateDisplayType();
end

function MoneyDenominationDisplayMixin:SetDisplayType(displayType)
	self.displayType = displayType;
	self:UpdateDisplayType();
end

function MoneyDenominationDisplayMixin:UpdateDisplayType()
	local textureType, fileOrAtlas, l, r, b, t = unpack(self.displayType);

	if textureType == TextureType.Atlas then
		self.Icon:SetAtlas(fileOrAtlas);
		self.Icon:SetSize(12,14);
	else
		self.Icon:SetTexture(fileOrAtlas);
		self.Icon:SetSize(13,13);
		self.Icon:SetTexCoord(l or 0, r or 1, b or 0, t or 1);
	end

	self:UpdateWidth();
end

function MoneyDenominationDisplayMixin:SetFontObject(fontObject)
	self.Text:SetFontObject(fontObject);
	self:UpdateWidth();
end

function MoneyDenominationDisplayMixin:GetFontObject()
	return self.Text:GetFontObject();
end

function MoneyDenominationDisplayMixin:SetFontAndIconDisabled(disabled)
	self:SetFontObject(disabled and PriceFontGray or PriceFontWhite);
	self.Icon:SetAlpha(disabled and 0.5 or 1);
end

function MoneyDenominationDisplayMixin:SetForcedHidden(forcedHidden)
	self.forcedHidden = forcedHidden;
	self:SetShown(self:ShouldBeShown());
end

function MoneyDenominationDisplayMixin:IsForcedHidden()
	return self.forcedHidden;
end

function MoneyDenominationDisplayMixin:SetShowsZeroAmount(showsZeroAmount)
	self.showsZeroAmount = showsZeroAmount;
	self:SetShown(self:ShouldBeShown());
end

function MoneyDenominationDisplayMixin:ShowsZeroAmount()
	return self.showsZeroAmount;
end

function MoneyDenominationDisplayMixin:ShouldBeShown()
	return not self:IsForcedHidden() and self.amount ~= nil and (self.amount > 0 or self:ShowsZeroAmount());
end

function MoneyDenominationDisplayMixin:SetAmount(amount)
	self.amount = amount;

	local shouldBeShown = self:ShouldBeShown();
	self:SetShown(shouldBeShown);
	if not shouldBeShown then
		return;
	end

	local amountText = amount;

	local colorblindMode = ENABLE_COLORBLIND_MODE == "1";
	if colorblindMode then
		amountText = amountText..MONEY_DENOMINATION_SYMBOLS_BY_DISPLAY_TYPE[self.displayType];
	end

	self.Text:SetText(amountText);
	self.Icon:SetShown(not colorblindMode);

	self:UpdateWidth();
end

function MoneyDenominationDisplayMixin:UpdateWidth()
	local iconWidth = self.Icon:IsShown() and self.Icon:GetWidth() or 0;
	local iconSpacing = 2;
	self.Text:SetPoint("RIGHT", -(iconWidth + iconSpacing), 0);
	self:SetWidth(self.Text:GetStringWidth() + iconWidth + iconSpacing);
end


MoneyDisplayFrameMixin = {};

local DENOMINATION_DISPLAY_WIDTH = 36; -- Space for two characters and an anchor offset.

function MoneyDisplayFrameMixin:OnLoad()
	self.CopperDisplay:SetShowsZeroAmount(true);
	self.SilverDisplay:SetShowsZeroAmount(true);

	if self:GetAttribute("hideCopper") then
		self.CopperDisplay:SetForcedHidden(true);
	end

	if self:GetAttribute("useAuctionHouseIcons") then
		self.CopperDisplay:SetDisplayType(MoneyDenominationDisplayType.AuctionHouseCopper);
		self.SilverDisplay:SetDisplayType(MoneyDenominationDisplayType.AuctionHouseSilver);
		self.GoldDisplay:SetDisplayType(MoneyDenominationDisplayType.AuctionHouseGold);
	end

	self:UpdateAnchoring();
end

function MoneyDisplayFrameMixin:SetFontAndIconDisabled(disabled)
	self.CopperDisplay:SetFontAndIconDisabled(disabled);
	self.SilverDisplay:SetFontAndIconDisabled(disabled);
	self.GoldDisplay:SetFontAndIconDisabled(disabled);

	if self:GetAttribute("resizeToFit") then
		self:UpdateWidth();
	end
end

function MoneyDisplayFrameMixin:SetFontObject(fontObject)
	self.CopperDisplay:SetFontObject(fontObject);
	self.SilverDisplay:SetFontObject(fontObject);
	self.GoldDisplay:SetFontObject(fontObject);

	if self:GetAttribute("resizeToFit") then
		self:UpdateWidth();
	end
end

function MoneyDisplayFrameMixin:GetFontObject()
	return self.CopperDisplay:GetFontObject();
end

function MoneyDisplayFrameMixin:UpdateAnchoring()
	self.CopperDisplay:ClearAllPoints();
	self.SilverDisplay:ClearAllPoints();
	self.GoldDisplay:ClearAllPoints();

	if self:GetAttribute("leftAlign") then
		self.GoldDisplay:SetPoint("LEFT");

		if self.GoldDisplay:ShouldBeShown() then
			self.SilverDisplay:SetPoint("RIGHT", self.GoldDisplay, "RIGHT", DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.SilverDisplay:SetPoint("LEFT", self.GoldDisplay, "LEFT");
		end
		
		if self.SilverDisplay:ShouldBeShown() then
			self.CopperDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT", DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.CopperDisplay:SetPoint("LEFT", self.SilverDisplay, "LEFT");
		end
	else
		self.CopperDisplay:SetPoint("RIGHT");

		if self.CopperDisplay:ShouldBeShown() then
			self.SilverDisplay:SetPoint("RIGHT", -DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.SilverDisplay:SetPoint("RIGHT", self.CopperDisplay, "RIGHT");
		end
		
		if self.SilverDisplay:ShouldBeShown() then
			self.GoldDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT", -DENOMINATION_DISPLAY_WIDTH, 0);
		else
			self.GoldDisplay:SetPoint("RIGHT", self.SilverDisplay, "RIGHT");
		end
	end
end

function MoneyDisplayFrameMixin:SetAmount(rawCopper)
	self.rawCopper = rawCopper;
	
	local gold = floor(rawCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((rawCopper - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(rawCopper, COPPER_PER_SILVER);
	self.GoldDisplay:SetAmount(gold);
	self.SilverDisplay:SetAmount(silver);
	self.CopperDisplay:SetAmount(copper);

	if self:GetAttribute("resizeToFit") then
		self:UpdateWidth();
	else
		self:UpdateAnchoring();
	end
end

function MoneyDisplayFrameMixin:UpdateWidth()
	local width = 0;
	local goldDisplayed = self.GoldDisplay:IsShown()
	if goldDisplayed then
		width = width + self.GoldDisplay:GetWidth();
	end

	local silverDisplayed = self.SilverDisplay:IsShown();
	if silverDisplayed then
		if goldDisplayed then
			width = width + DENOMINATION_DISPLAY_WIDTH;
		else
			width = width + self.SilverDisplay:GetWidth();
		end
	end

	if self.CopperDisplay:IsShown() then
		if goldDisplayed or silverDisplayed then
			width = width + DENOMINATION_DISPLAY_WIDTH;
		else
			width = width + self.CopperDisplay:GetWidth();
		end
	end

	self:SetWidth(width);
end

function MoneyDisplayFrameMixin:GetAmount()
	return self.rawCopper;
end

function MoneyDisplayFrameMixin:SetResizeToFit(resizeToFit)
	self:SetAttribute("resizeToFit", resizeToFit)
end
