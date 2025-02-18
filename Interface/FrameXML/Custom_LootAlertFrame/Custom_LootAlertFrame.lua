LOOTALERT_NUM_BUTTONS = 4

local ignoreQualityCheck = {
	[150732] = true,
}

LootAlertFrameMixIn = {}

LootAlertFrameMixIn.alertQueue = {}
LootAlertFrameMixIn.alertButton = {}

function LootAlertFrameMixIn:AddAlert( itemID, name, link, quality, texture, count, skipQualityCheck, tooltipText )
 	if not skipQualityCheck and (itemID and not ignoreQualityCheck[itemID]) then
		local alertThreshold = tonumber(C_CVar:GetValue("C_CVAR_LOOT_ALERT_THRESHOLD")) or 0
		if alertThreshold == -1 or alertThreshold > quality then
			return
		end
	end

	if Custom_RouletteFrame and Custom_RouletteFrame:IsShown() then
		LOOTALERT_NUM_BUTTONS = 3
	else
		LOOTALERT_NUM_BUTTONS = 4
	end

	table.insert(self.alertQueue, {name = name, link = link, quality = quality, texture = texture, count = count, tooltipText = tooltipText})
	self:Show()
end

function LootAlertFrameMixIn:CreateAlert()
	if #self.alertQueue > 0 then
		for i = 1, LOOTALERT_NUM_BUTTONS do
			local button = self.alertButton[i]

			if button and not button:IsShown() then
				button.data = table.remove(self.alertQueue, 1)
				return button
			end
		end
	end
end

function LootAlertFrameMixIn:AdjustAnchors()
	local previousButton

	for i = 1, LOOTALERT_NUM_BUTTONS do
		local button = self.alertButton[i]

		button:ClearAllPoints()

		if button and button:IsShown() then
			if button.waitAndAnimOut:GetProgress() <= 0.74 then
				if not previousButton or previousButton == button then
					if DungeonCompletionAlertFrame1:IsShown() then
						button:SetPoint("BOTTOM", DungeonCompletionAlertFrame1, "TOP", 0, 0)
					else
						button:SetPoint("CENTER", DungeonCompletionAlertFrame1, "CENTER", 0, 0)
					end
				else
					button:SetPoint("BOTTOM", previousButton, "TOP", 0, 4)
				end
			end

			previousButton = button
		end
	end
end

function LootAlertFrame_OnLoad( self )
	self:RegisterCustomEvent("PLAYER_LOOT_ITEM")

	self.updateTime = 0.30

	Mixin(self, LootAlertFrameMixIn)
end

function LootAlertFrame_OnEvent(self, event, itemID, amount, lootEventType)
	if event == "PLAYER_LOOT_ITEM" then
		if IsDevClient()
		or lootEventType == Enum.PlayerLootEventType.Pushed
		or BattlePassFrame:IsShown() and C_BattlePass.IsBattlePassItem(itemID)
		then
			return
		end

		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID)
		if link then
			self:AddAlert(itemID, name, link, quality, texture, amount)
		end
	end
end

function LootAlertFrame_OnUpdate( self, elapsed )
	self.updateTime = self.updateTime - elapsed

	if self.updateTime <= 0 then
		local alert = self:CreateAlert()

		if alert then
			alert:Show()
			alert.animIn:Play()
			self:AdjustAnchors()
		end

		self.updateTime = 0.30

		if #self.alertQueue == 0 then
			self:Hide()
		end
	end
end

function LootAlertButtonTemplate_OnLoad( self )
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self.glow:SetAtlas("loottoast-glow", true)
	table.insert(LootAlertFrameMixIn.alertButton, self)
end

function LootAlertButtonTemplate_OnShow( self )
	if not self.data then
		self:Hide()
		return
	end

	local data = self.data
	if data.name then
		local qualityColor = ITEM_QUALITY_COLORS[data.quality] or ITEM_QUALITY_COLORS[Enum.ItemQuality.Common]

		if data.count then
			self.Count:SetText(data.count)
		else
			self.Count:SetText(" ")
		end

		self.Icon:SetTexture(data.texture)
		self.ItemName:SetText(data.name)

		if qualityColor then
			self.ItemName:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
		end

		self.IconBorder:SetAtlas(LOOT_BORDER_BY_QUALITY[data.quality] or LOOT_BORDER_BY_QUALITY[Enum.ItemQuality.Common])

		self.hyperLink 		= data.link
		self.tooltipText 	= data.tooltipText
		self.name 			= data.name

		self.glow.animIn:Play()
		self.shine.animIn:Play()
	end
end

function LootAlertButtonTemplate_OnHide( self )
	self:Hide()
	self.animIn:Stop()
	self.waitAndAnimOut:Stop()

	self.glow.animIn:Stop()
	self.shine.animIn:Stop()

	if self.data then
		wipe(self.data)
	end

	LootAlertFrameMixIn:AdjustAnchors()
end

function LootAlertButtonTemplate_OnClick( self, button )
	if button == "RightButton" then
		self:Hide()
	else
		if HandleModifiedItemClick(self.hyperLink) then
			return
		end
	end
end

function LootAlertButtonTemplate_OnEnter( self )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -6)
	if self.tooltipText then
		GameTooltip:SetText(self.name, 1, 1, 1)
		GameTooltip:AddLine(self.tooltipText, nil, nil, nil, 1)
	else
		GameTooltip:SetHyperlink(self.hyperLink)
	end
	GameTooltip:Show()
end

local onItemCacheRecieved = function(itemCount, itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice)
	LootAlertFrame:AddAlert(itemID, itemName, itemLink, itemRarity, itemTexture, itemCount, true)
end

function EventHandler:ASMSG_SHOW_LOOT_POPUP( msg )
	local splitStorage = C_Split(msg, "|")

	for _, itemData in pairs(splitStorage) do
		local itemSplitData = C_Split(itemData, ":")

		local itemID = tonumber(itemSplitData[1])
		local itemCount = tonumber(itemSplitData[2])

		if itemID and BattlePassFrame:IsShown() and C_BattlePass.IsBattlePassItem(itemID) then
			return
		end

		local name, link, quality, texture, tooltipText, _

		if itemID == -1 then
			local unitFaction = UnitFactionGroup("player") or "Alliance"
			name 		= HONOR_POINTS
			texture 	= "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction
			quality 	= LE_ITEM_QUALITY_EPIC
			tooltipText = TOOLTIP_HONOR_POINTS
		elseif itemID == -2 then
			local unitFaction = UnitFactionGroup("player") or "Alliance"
			name 		= ARENA_POINTS
			texture 	= "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction
			quality 	= LE_ITEM_QUALITY_EPIC
			tooltipText = TOOLTIP_ARENA_POINTS
		elseif itemID == -3 then
			name 		= STORE_CURRENCY_BONUS_LABEL
			texture 	= "Interface\\Store\\coins"
			quality 	= LE_ITEM_QUALITY_LEGENDARY
			tooltipText = STORE_CURRENCY_BONUS_DESCRIPTION
		elseif itemID == -4 then
			name 		= STORE_CURRENCY_VOTE_LABEL
			texture 	= "Interface\\Store\\mmotop"
			quality 	= LE_ITEM_QUALITY_LEGENDARY
			tooltipText = STORE_CURRENCY_VOTE_DESCRIPTION
		else
			name, link, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemID, false, nil, true, true)
		end

		if name then
			LootAlertFrame:AddAlert(itemID, name, link, quality, texture, itemCount, true, tooltipText)
		else
			C_Item.RequestServerCache(itemID, function(...)
				onItemCacheRecieved(itemCount, ...)
			end)
		end
	end
end