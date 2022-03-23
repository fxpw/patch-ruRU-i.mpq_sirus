--	Filename:	Sirus_ChooseItem.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local CHOOSEITEM_DATA = {}

UIPanelWindows["ChooseItemFrame"] =	{ area = "center",	pushable = 0,	whileDead = 1, allowOtherPanels = 1 };

function QuestChoiceOption_OnLoad( self, ... )
	local _, classFileName = UnitClass("player")
	local color = RAID_CLASS_COLORS[classFileName]
	self.RoleBackground:SetVertexColor(color.r, color.g, color.b)
end

function ChooseItemFrame_OnShow( self, ... )
	local roleName = {
		"DAMAGER",
		"RANGEDAMAGER",
		"TANK",
		"HEALER"
	}

	local width = 380
	for i = 1, 4 do
		local data = CHOOSEITEM_DATA[i]
		local frame = _G["ChooseItemOption"..i]
		if data and frame then
			local function ItemInfoResponceCallback(itemName, _, itemRarity, _, _, _, _, _, _, itemTexture)
				local r, g, b = GetItemQualityColor(itemRarity)

				frame.Item.Name:SetText(itemName)
				frame.Item.Icon:SetTexture(itemTexture)
				frame.Item.IconBorder:SetVertexColor(r, g, b)

				frame.Item.Name:SetTextColor(r, g, b)
			end

			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(data.itemID, false, ItemInfoResponceCallback)

			if itemName then
				ItemInfoResponceCallback(itemName, _, itemRarity, _, _, _, _, _, _, itemTexture)
			else
				ItemInfoResponceCallback(TOOLTIP_UNIT_LEVEL_ILEVEL_LOADING_LABEL, _, 4, _, _, _, _, _, _, "Interface\\ICONS\\INV_Misc_QuestionMark")
			end

			frame.data = data

			if data.iconID and data.iconID ~= 0 then
				frame.RoleTexture:SetTexCoord(GetTexCoordsForRole(roleName[data.iconID]))
			end

			if (not data.itemCount or data.itemCount < 2) then
				frame.Item.Count:SetText()
			else
				frame.Item.Count:SetText(data.itemCount)
			end

			local name

			if data.specID == 0 then
				name = UnitClass("player")
			else
				name = GetTalentTabInfo(data.specID, "player")
			end

			frame.Header.Text:SetText(name)

			frame.Item.glow:Show()
			frame.Item.glow:SetVertexColor(r, g, b, 1)
			frame.Item.glow.animIn:Play()

			width = i == 1 and 380 or width + 230
			frame:Show()
		else
			frame:Hide()
		end
	end
	self:SetWidth(width)
end

function QuestChoiceOption_OnEnter( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	self = self:GetParent()
	GameTooltip:SetHyperlink("Hitem:"..self.data.itemID)
	GameTooltip:Show()
end

function QuestChoiceOption_OnClick( self, ... )
	self = self:GetParent()

	if ( self.data.itemID ) and IsModifiedClick() then
		local _, link = GetItemInfo(self.data.itemID)
		if HandleModifiedItemClick(link) then
			return
		end
	end
end

function QuestChoiceOpticonSelectButton_OnClick( self, ... )
	self = self:GetParent()
	SendAddonMessage("ACMSG_TRADE_TOKEN", string.format("%d:%d", self.data.tokenID, self.data.itemID), "WHISPER", UnitName("player"))
	HideUIPanel(ChooseItemFrame)
end

function EventHandler:ASMSG_SHOW_TOKEN_TRADE( msg )
	local data = {strsplit("|", msg)}
	local tokenID = data[1]

	table.wipe(CHOOSEITEM_DATA)

	for i = 2, #data do
		if data[i] then
			local specID, iconID, itemID, itemCount = string.match(data[i], "(%d+):(%d+):(%d+):?(%d*)")
			if specID and iconID and itemID and tokenID then
				CHOOSEITEM_DATA[i - 1] = {
					specID = tonumber(specID),
					iconID = tonumber(iconID),
					itemID = tonumber(itemID),
					tokenID = tonumber(tokenID),
					itemCount = tonumber(itemCount),
				}
			end
		end
	end

	ShowUIPanel(ChooseItemFrame)
end

function EventHandler:ASMSG_TRADE_TOKEN_RESPONSE( msg )
	local errorID = tonumber(msg)

	if errorID == 1 then
		UIErrorsFrame:AddMessage(CHOOSE_ITEM_ERROR_1, 1.0, 0.1, 0.1, 1.0)
	elseif errorID == 2 then
		UIErrorsFrame:AddMessage(CHOOSE_ITEM_ERROR_2, 1.0, 0.1, 0.1, 1.0)
	elseif errorID == 3 then
		UIErrorsFrame:AddMessage(CHOOSE_ITEM_ERROR_3, 1.0, 0.1, 0.1, 1.0)
	end
end