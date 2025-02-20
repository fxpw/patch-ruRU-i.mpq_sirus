MAX_TRADE_ITEMS = 7;
MAX_TRADABLE_ITEMS = 6;
TRADE_ENCHANT_SLOT = MAX_TRADE_ITEMS;

local AcceptTradeRaw = AcceptTrade

TradeFrameMixIn = {}

function TradeFrameMixIn:ResetLock()
	TradeFrameTradeButton:SetText(TRADE)
	self.LockTime = nil
end

function TradeFrameMixIn:GetLockTime()
	return self.LockTime
end

function TradeFrameMixIn:SetLockTime( time )
	if IsActiveBattlefieldArena() then
		return 0
	end
	if StaticPopup_Visible("CONFIRM_TRADE") then
		StaticPopup_Hide("CONFIRM_TRADE")
		CancelTradeAccept()
	end

	self.LockTime = time or 3
	return self.LockTime
end

function TradeFrameMixIn:OnUpdate( elapsed )
	if not self:GetLockTime() then
		return
	end

	local timeLeft = Round(self:SetLockTime(self:GetLockTime() - elapsed))


	if timeLeft > 0 then
		TradeFrameTradeButton:SetText(timeLeft)
		TradeFrameTradeButton:Disable()
	else
		TradeFrameTradeButton:Enable()
		self:ResetLock()
	end
end

StaticPopupDialogs["CONFIRM_TRADE"] = {
	text = "%s",
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		if TradeFrame:GetLockTime() then
			return
		end

		AcceptTradeRaw()
	end,
	OnCancel = function(self)
		CancelTradeAccept()
	end,
	timeout = 0,
	whileDead = 1
}

local AcceptTrade = function()
	if IsActiveBattlefieldArena() then
		AcceptTradeRaw()
		return
	end

	if TradeFrame:GetLockTime() then
		return
	end

	local playerData   = {}
	local targetData   = {}
	local playerBuffer = ""
	local targetBuffer = ""
	local triggerMoney = 1000000
	local triggerItem  = nil

	local playerMoney = GetPlayerTradeMoney()
	local targetMoney = GetTargetTradeMoney()

	for i = 1, MAX_TRADABLE_ITEMS do
		local itemLink = GetTradePlayerItemLink(i)

		if itemLink then
			local _, _, itemQuality = GetItemInfo(itemLink)
			local itemName, _, numItems = GetTradePlayerItemInfo(i)

			if itemQuality and itemQuality >= 3 then
				triggerItem = true
			end

			if not playerData[itemLink] then
				playerData[itemLink] = 0
			end

			playerData[itemLink] = playerData[itemLink] + numItems
		end
	end

	for i = 1, MAX_TRADABLE_ITEMS do
		local itemLink = GetTradeTargetItemLink(i)

		if itemLink then
			local _, _, itemQuality = GetItemInfo(itemLink)
			local itemName, _, numItems = GetTradeTargetItemInfo(i)

			if itemQuality and itemQuality >= 3 then
				triggerItem = true
			end

			if not targetData[itemLink] then
				targetData[itemLink] = 0
			end

			targetData[itemLink] = targetData[itemLink] + numItems
		end
	end

	for itemLink, numItems in pairs(playerData) do
		playerBuffer = playerBuffer .. string.format("%s x%d, ", itemLink, numItems)
	end

	for itemLink, numItems in pairs(targetData) do
		targetBuffer = targetBuffer .. string.format("%s x%d, ", itemLink, numItems)
	end

	playerBuffer = string.sub(playerBuffer, 1, -3) .. "."
	targetBuffer = string.sub(targetBuffer, 1, -3) .. "."

	if #playerBuffer < 3 then
		playerBuffer = string.format("%s.", RAID_TARGET_NONE)
	end

	if #targetBuffer < 3 then
		targetBuffer = string.format("%s.", RAID_TARGET_NONE)
	end

	local _, _, _, _, playerEnchantment = GetTradePlayerItemInfo(7)
	local _, _, _, _, _, targetEnchantment = GetTradeTargetItemInfo(7)

	if targetEnchantment then
		playerBuffer = playerBuffer .. string.format(TRADE_ENCHANT_ALERT_PLAYER, targetEnchantment)
	end

	if playerEnchantment then
		targetBuffer = targetBuffer .. string.format(TRADE_ENCHANT_ALERT_TARGET, GetTradePlayerItemLink(7), playerEnchantment)
	end


	if playerMoney >= triggerMoney or targetMoney >= triggerMoney or triggerItem or playerEnchantment or targetEnchantment then
		StaticPopup_Show("CONFIRM_TRADE", string.format(TRADE_CONFIRM, UnitName("NPC"), GetMoneyString(playerMoney), playerBuffer, GetMoneyString(targetMoney), targetBuffer))
	else
		AcceptTradeRaw()
	end
end

function TradeFrame_OnLoad(self)
	Mixin(self, TradeFrameMixIn)

	self:RegisterEvent("TRADE_CLOSED");
	self:RegisterEvent("TRADE_SHOW");
	self:RegisterEvent("TRADE_UPDATE");
	self:RegisterEvent("TRADE_TARGET_ITEM_CHANGED");
	self:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED");
	self:RegisterEvent("TRADE_ACCEPT_UPDATE");
	self:RegisterEvent("TRADE_POTENTIAL_BIND_ENCHANT");
	self:RegisterEvent("TRADE_MONEY_CHANGED")
end

function TradeFrame_OnUpdate( self, elapsed )
	self:OnUpdate(elapsed)
end

function TradeFrame_OnShow(self)
	self.acceptState = 0;
	TradeFrameTradeButton.enabled = TradeFrameTradeButton:IsEnabled();
	TradeFrame_UpdateMoney();
end

function TradeFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "TRADE_SHOW" or event == "TRADE_UPDATE" ) then
		ShowUIPanel(self, 1);
		if ( not self:IsShown() ) then
			CloseTrade();
			return;
		end

		TradeFrameTradeButton_Enable();
		TradeFrame_Update();

		if event == "TRADE_SHOW" and (GetPlayerTradeMoney() > 0 or GetTargetTradeMoney() > 0 or GetTradePlayerItemInfo(1)) then
			self:SetLockTime()
		else
			self:ResetLock()
		end
	elseif ( event == "TRADE_CLOSED" ) then
		HideUIPanel(self);
		self:ResetLock()
		StaticPopup_Hide("TRADE_POTENTIAL_BIND_ENCHANT");
		StaticPopup_Hide("CONFIRM_TRADE")
	elseif ( event == "TRADE_TARGET_ITEM_CHANGED" ) then
		TradeFrame_UpdateTargetItem(arg1);
		self:SetLockTime()
	elseif ( event == "TRADE_PLAYER_ITEM_CHANGED" ) then
		TradeFrame_UpdatePlayerItem(arg1);
		self:SetLockTime()
	elseif ( event == "TRADE_ACCEPT_UPDATE" ) then
		TradeFrame_SetAcceptState(arg1, arg2);
	elseif ( event == "TRADE_POTENTIAL_BIND_ENCHANT" ) then
		-- leaving this commented here so people know how to interpret arg1
		--local canBecomeBound = arg1;
		if ( arg1 ) then
			StaticPopup_Show("TRADE_POTENTIAL_BIND_ENCHANT");
		else
			StaticPopup_Hide("TRADE_POTENTIAL_BIND_ENCHANT");
		end
	elseif event == "TRADE_MONEY_CHANGED" then
		self:SetLockTime()
	end
end

function TradeFrame_Update()
	SetPortraitTexture(TradeFramePlayerPortrait, "player");
	SetPortraitTexture(TradeFrameRecipientPortrait, "NPC");
	TradeFramePlayerNameText:SetText(UnitName("player"));
	TradeFrameRecipientNameText:SetText(UnitName("NPC"));
	for i=1, MAX_TRADE_ITEMS, 1 do
		TradeFrame_UpdateTargetItem(i);
		TradeFrame_UpdatePlayerItem(i);
	end
	TradeHighlightRecipient:Hide();
	TradeHighlightPlayer:Hide();
	TradeHighlightPlayerEnchant:Hide();
	TradeHighlightRecipientEnchant:Hide();
end

function TradeFrame_UpdatePlayerItem(id)
	local name, texture, numItems, isUsable, enchantment = GetTradePlayerItemInfo(id);
	local _, _, quality = GetItemInfo(GetTradePlayerItemLink(id))
	local buttonText = _G["TradePlayerItem"..id.."Name"];

	-- See if its the enchant slot
	if ( id == TRADE_ENCHANT_SLOT ) then
		if ( name ) then
			if ( enchantment ) then
				buttonText:SetText(GREEN_FONT_COLOR_CODE..enchantment..FONT_COLOR_CODE_CLOSE);
			else
				buttonText:SetText(HIGHLIGHT_FONT_COLOR_CODE..TRADEFRAME_NOT_MODIFIED_TEXT..FONT_COLOR_CODE_CLOSE);
			end
		else
			buttonText:SetText("");
		end
	else
		buttonText:SetText(name);
		if ( quality ) then
			buttonText:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b)
		else
			buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	end
	local tradeItemButton = _G["TradePlayerItem"..id.."ItemButton"];
	SetItemButtonTexture(tradeItemButton, texture);
	SetItemButtonCount(tradeItemButton, numItems);
	SetItemButtonQuality(tradeItemButton, quality);
	if ( texture ) then
		tradeItemButton.hasItem = 1;
	else
		tradeItemButton.hasItem = nil;
	end
end

function TradeFrame_UpdateTargetItem(id)
	local name, texture, numItems, _, isUsable, enchantment = GetTradeTargetItemInfo(id);
	local _, _, quality = GetItemInfo(GetTradeTargetItemLink(id))
	local buttonText = _G["TradeRecipientItem"..id.."Name"];
	local tradeItemButton = _G["TradeRecipientItem"..id.."ItemButton"];
	local tradeItem = _G["TradeRecipientItem"..id];
	-- See if its the enchant slot
	if ( id == TRADE_ENCHANT_SLOT ) then
		if ( name ) then
			if ( enchantment ) then
				buttonText:SetText(GREEN_FONT_COLOR_CODE..enchantment..FONT_COLOR_CODE_CLOSE);
			else
				buttonText:SetText(HIGHLIGHT_FONT_COLOR_CODE..TRADEFRAME_NOT_MODIFIED_TEXT..FONT_COLOR_CODE_CLOSE);
			end
		else
			buttonText:SetText("");
		end

	else
		buttonText:SetText(name);
		if ITEM_QUALITY_COLORS[quality] then
			buttonText:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b)
		end
	end

	local tradeItem = _G["TradeRecipientItem"..id];
	SetItemButtonTexture(tradeItemButton, texture);
	SetItemButtonCount(tradeItemButton, numItems);
	if ( isUsable or not name ) then
		SetItemButtonTextureVertexColor(tradeItemButton, 1.0, 1.0, 1.0);
		SetItemButtonNameFrameVertexColor(tradeItem, 1.0, 1.0, 1.0);
		SetItemButtonSlotVertexColor(tradeItem, 1.0, 1.0, 1.0);
	else
		SetItemButtonTextureVertexColor(tradeItemButton, 0.9, 0, 0);
		SetItemButtonNameFrameVertexColor(tradeItem, 0.9, 0, 0);
		SetItemButtonSlotVertexColor(tradeItem, 1.0, 0, 0);
	end

	SetItemButtonQuality(tradeItemButton, quality)

	if name then
		tradeItem.HighlightTexture.Anim:Play()
	else
		tradeItem.HighlightTexture.Anim:Stop()
	end
end

function TradeFrame_SetAcceptState(playerState, targetState)
	TradeFrame.acceptState = playerState;
	if ( playerState == 1 ) then
		TradeHighlightPlayer:Show();
		TradeHighlightPlayerEnchant:Show();
		TradeFrameTradeButton_Disable();
	else
		TradeHighlightPlayer:Hide();
		TradeHighlightPlayerEnchant:Hide();
		TradeFrameTradeButton_Enable();
	end
	if ( targetState == 1 ) then
		TradeHighlightRecipient:Show();
		TradeHighlightRecipientEnchant:Show();
	else
		TradeHighlightRecipient:Hide();
		TradeHighlightRecipientEnchant:Hide();
	end
end

function TradeFrameCancelButton_OnClick()
	if ( TradeFrame.acceptState == 1 ) then
		CancelTradeAccept();
	else
		HideUIPanel(TradeFrame);
	end
end

function TradeFrame_OnHide()
	CloseTrade();
	MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, 0);
end

function TradeFrame_OnMouseUp()
	if ( GetCursorMoney() > 0 ) then
		AddTradeMoney();
	elseif ( CursorHasItem() ) then
		local slot = TradeFrame_GetAvailableSlot();
		if ( slot ) then
			ClickTradeButton(slot);
		end
	else
		MoneyInputFrame_ClearFocus(TradePlayerInputMoneyFrame);
	end
end

function TradeFrame_UpdateMoney()
	local copper = MoneyInputFrame_GetCopper(TradePlayerInputMoneyFrame);

	if copper > 0 or GetPlayerTradeMoney() ~= 0 then
		TradeFrame:SetLockTime()
	end

	if ( copper > GetMoney() - GetCursorMoney() ) then
		copper = GetPlayerTradeMoney();
		MoneyInputFrame_SetCopper(TradePlayerInputMoneyFrame, copper);
		--MoneyInputFrame_SetTextColor(TradePlayerInputMoneyFrame, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		TradeFrameTradeButton_Disable();
	else
		--MoneyInputFrame_SetTextColor(TradePlayerInputMoneyFrame, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		TradeFrameTradeButton_Enable();
	end
	SetTradeMoney(copper);
end

function TradeFrame_GetAvailableSlot()
	local tradeItemButton;
	for i=1, MAX_TRADABLE_ITEMS do
		tradeItemButton = _G["TradePlayerItem"..i.."ItemButton"];
		if ( not tradeItemButton.hasItem ) then
			return i;
		end
	end
	return nil;
end

function TradeFrameTradeButton_Enable()
	if TradeFrame:GetLockTime() then
		return
	end

	local self = TradeFrameTradeButton;
	if ( StaticPopup_Visible("TRADE_POTENTIAL_BIND_ENCHANT") ) then
		self.enabled = true;
	else
		self:Enable();
	end
end

function TradeFrameTradeButton_Disable()
	if TradeFrame:GetLockTime() then
		return
	end

	local self = TradeFrameTradeButton;
	if ( StaticPopup_Visible("TRADE_POTENTIAL_BIND_ENCHANT") ) then
		self.enabled = false;
	else
		self:Disable();
	end
end

function TradeFrameTradeButton_SetToEnabledState()
	if TradeFrame:GetLockTime() then
		return
	end

	local self = TradeFrameTradeButton;
	if ( self.enabled ) then
		self:Enable();
	else
		self:Disable();
	end
end

function TradeFrameTradeButton_OnClick( self, ... )
	AcceptTrade()
end
