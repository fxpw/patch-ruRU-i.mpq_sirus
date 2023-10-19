local CREATED_FRAMES = 4;
local MAX_UNSCALED_FRAMES = 4;
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

	local numData = #CHOOSEITEM_DATA;

	local width = 64 * 2;
	for i = 1, numData do
		local data = CHOOSEITEM_DATA[i]
		local frame = _G["ChooseItemOption"..i]
		if data then
			if not frame then
				frame = CreateFrame("Frame", "ChooseItemOption"..i, ChooseItemFrame, "QuestChoiceOptionTemplate");
				frame:SetPoint("LEFT", _G["ChooseItemOption"..(i - 1)], "RIGHT", 24, 0);
				CREATED_FRAMES = CREATED_FRAMES + 1;
			end

			local function ItemInfoResponceCallback(_, itemName, _, itemRarity, _, _, _, _, _, _, itemTexture)
				local r, g, b = GetItemQualityColor(itemRarity)

				frame.Item.Name:SetText(itemName)
				frame.Item.Icon:SetTexture(itemTexture)
				frame.Item.IconBorder:SetVertexColor(r, g, b)
				frame.Item.glow:SetVertexColor(r, g, b)

				frame.Item.Name:SetTextColor(r, g, b)
			end

			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(data.itemID, false, ItemInfoResponceCallback)

			if itemName then
				ItemInfoResponceCallback(nil, itemName, nil, itemRarity, nil, nil, nil, nil, nil, nil, itemTexture)
			else
				ItemInfoResponceCallback(nil, TOOLTIP_UNIT_LEVEL_ILEVEL_LOADING_LABEL, nil, 4, nil, nil, nil, nil, nil, nil, "Interface\\ICONS\\INV_Misc_QuestionMark")
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
			frame.Item.glow.animIn:Play()

			width = width + (i == 1 and 210 or 234)
			frame:Show()
		elseif frame then
			frame:Hide()
		end
	end

	for i = numData + 1, CREATED_FRAMES do
		_G["ChooseItemOption"..i]:Hide();
	end

	self:SetWidth(width);

	if numData > MAX_UNSCALED_FRAMES then
		self:SetScale(1 - ((numData - MAX_UNSCALED_FRAMES) * 0.155));
	else
		self:SetScale(1);
	end
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
	if self.data.itemGUID then
		SendServerMessage("ACMSG_UPGRADE_TOKEN", string.format("%d:%d:%s", self.data.tokenID, self.data.itemID, self.data.itemGUID))
	else
		SendServerMessage("ACMSG_TRADE_TOKEN", string.format("%d:%d", self.data.tokenID, self.data.itemID))
	end
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

function EventHandler:ASMSG_SHOW_TOKEN_UPGRADE(msg)
	local data = {strsplit("|", msg)};
	local tokenID, itemGUID = data[1], data[2];

	table.wipe(CHOOSEITEM_DATA);

	for i = 3, #data do
		if data[i] then
			local specID, iconID, itemID = string.match(data[i], "(%d+):(%d+):(%d+)")
			if specID and iconID and itemID and tokenID then
				CHOOSEITEM_DATA[i - 2] = {
					specID = tonumber(specID),
					iconID = tonumber(iconID),
					itemID = tonumber(itemID),
					tokenID = tonumber(tokenID),
					itemGUID = itemGUID,
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

function EventHandler:ACMSG_UPGRADE_TOKEN_RESPONSE(msg)
	local errorID = tonumber(msg);

	if errorID and errorID ~= 0 then
		local errorString = _G["TOKEN_UPGRAGE_ERROR_" .. errorID];

		if errorString then
			UIErrorsFrame:AddMessage(errorString, 1.0, 0.1, 0.1, 1.0);
		end
	end
end