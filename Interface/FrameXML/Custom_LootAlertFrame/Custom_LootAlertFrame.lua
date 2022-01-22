--	Filename:	Custom_LootAlertFrame.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

LOOTALERT_NUM_BUTTONS = 4

LootAlertFrameMixIn = {}

LootAlertFrameMixIn.alertQueue = {}
LootAlertFrameMixIn.alertButton = {}

function LootAlertFrameMixIn:AddAlert( name, link, quality, texture, count, ignoreLevel, tooltipText )
	if Custom_RouletteFrame and Custom_RouletteFrame:IsShown() then
		LOOTALERT_NUM_BUTTONS = 3
	else
		LOOTALERT_NUM_BUTTONS = 4
	end

	if not ignoreLevel then
		if UnitLevel("player") < 80 then
			if quality < 2 then
				return
			end
		else
			if quality < 4 then
				return
			end
		end
	end

	table.insert(self.alertQueue, {name = name, link = link, quality = quality, texture = texture, count = count, tooltipText = tooltipText})
end

function LootAlertFrameMixIn:CreateAlert()
	if #self.alertQueue > 0 then
		for i = 1, LOOTALERT_NUM_BUTTONS do
			local button = self.alertButton[i]

			if button and not button:IsShown() then
				local data = table.remove(self.alertQueue, 1)

				button.data = data

				return button
			end
		end
	end

	return nil
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
	self:RegisterEvent("CHAT_MSG_LOOT")

	self.updateTime = 0.30

	Mixin(self, LootAlertFrameMixIn)
end

function LootAlertFrame_OnEvent( self, event, arg1 )
	if event == "CHAT_MSG_LOOT" then
		if S_IsDevClient and S_IsDevClient() then
			return
		end

		if string.find(arg1, string.Left(LOOT_ITEM_SELF, 21)) or string.find(arg1, string.Left(LOOT_ITEM_CREATED_SELF, 21)) then
			local itemEntry, count = string.match(arg1, "|Hitem:(%d+).*x(%d+)")

			if not itemEntry then
				itemEntry = string.match(arg1, "|Hitem:(%d+)")
			end

			if itemEntry then
				local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemEntry)

				if link then
					self:AddAlert(name, link, quality, texture, count)
				end
			end
		end
	end
end

function LootAlertFrame_OnUpdate( self, elapsed )
	self.updateTime = self.updateTime - elapsed

	if self.updateTime <= 0 then
		local alert = self:CreateAlert()

		if alert then
			alert:ClearAllPoints()
			alert:Show()
			alert.animIn:Play()

			self:AdjustAnchors()
		end

		self.updateTime = 0.30
	end
end

function LootAlertButtonTemplate_OnLoad( self )
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	table.insert(LootAlertFrameMixIn.alertButton, self)
end

function LootAlertButtonTemplate_OnShow( self )
	if not self.data then
		self:Hide()
		return
	end

	local data = self.data
	if data.name then
		local qualityColor = ITEM_QUALITY_COLORS[data.quality] or nil

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

		if LOOT_BORDER_BY_QUALITY[data.quality] then
			self.IconBorder:SetTexCoord(unpack(LOOT_BORDER_BY_QUALITY[data.quality]))
		end

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

	wipe(self.data)

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

--lua EventHandler:ASMSG_SHOW_LOOT_POPUP("-3:100|")

function EventHandler:ASMSG_SHOW_LOOT_POPUP( msg )
	local splitStorage = C_Split(msg, "|")

	for _, itemData in pairs(splitStorage) do
		local itemSplitData = C_Split(itemData, ":")

		local itemEntry = tonumber(itemSplitData[1])
		local itemCount = tonumber(itemSplitData[2])

		local name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(itemEntry)
		local unitFaction = UnitFactionGroup("player") or "Alliance"
		local tooltipText

		if itemEntry == -1 then
			name 		= HONOR_POINTS
			texture 	= "Interface\\ICONS\\PVPCurrency-Honor-"..unitFaction
			quality 	= LE_ITEM_QUALITY_EPIC
			tooltipText = TOOLTIP_HONOR_POINTS
		elseif itemEntry == -2 then
			name 		= ARENA_POINTS
			texture 	= "Interface\\ICONS\\PVPCurrency-Conquest-"..unitFaction
			quality 	= LE_ITEM_QUALITY_EPIC
			tooltipText = TOOLTIP_ARENA_POINTS
		elseif itemEntry == -3 then
			name 		= STORE_COINS_BUTTON_TOOLTIP_LABEL
			texture 	= "Interface\\Store\\coins"
			quality 	= LE_ITEM_QUALITY_LEGENDARY
			tooltipText = STORE_COINS_BUTTON_TOOLTIP
		elseif itemEntry == -4 then
			name 		= STORE_VOTE_COIN_LABEL
			texture 	= "Interface\\Store\\mmotop"
			quality 	= LE_ITEM_QUALITY_LEGENDARY
			tooltipText = STORE_MMOTOP_BUTTON_TOOLTIP
		end

		if name then
			LootAlertFrameMixIn:AddAlert(name, link, quality, texture, itemCount, true, tooltipText)
		end
	end
end