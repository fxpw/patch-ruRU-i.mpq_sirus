UIPanelWindows["ChooseItemFrame"] =	{ area = "center",	pushable = 0,	whileDead = 1, allowOtherPanels = 1, checkFit = 1, checkFitExtraWidth = 360 };

local TOKEN_INFO_LIST = {}

local roleNameToIconID = {
	"DAMAGER",
	"RANGEDAMAGER",
	"TANK",
	"HEALER"
}

function ChooseItemFrame_OnLoad(self)
	self.Options = {self.Option1, self.Option2, self.Option3, self.Option4}

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
--	self:RegisterEvent("PLAYER_DEAD")
	self:RegisterCustomEvent("TOKEN_CHOICE_UPDATE")
	self:RegisterCustomEvent("TOKEN_CHOICE_CLOSE")
end

function ChooseItemFrame_OnEvent(self, event, ...)
	if event == "TOKEN_CHOICE_UPDATE" then
		ShowUIPanel(self)
		ChooseItemFrame_Update(self)
	elseif (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" or event == "TOKEN_CHOICE_CLOSE") then
		HideUIPanel(self)
	end
end

function ChooseItemFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
end

function ChooseItemFrame_Update(self)
	local numTokens = #TOKEN_INFO_LIST
	if numTokens == 0 then
		HideUIPanel(self)
		return
	end

	for index = 1, numTokens do
		local tokenInfo = TOKEN_INFO_LIST[index]
		local frame = self.Options[index]
		if not frame then
			frame = CreateFrame("Frame", "ChooseItemOption"..index, ChooseItemFrame, "QuestChoiceOptionTemplate")
			if index == 1 then
				frame:SetPoint("LEFT", 64, 4)
			else
				frame:SetPoint("LEFT", self.Options[index - 1], "RIGHT", 24, 0)
			end
			self.Options[index] = frame
		end

		local function itemInfoResponceCallback(_, itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture)
			local r, g, b = GetItemQualityColor(itemRarity or LE_ITEM_QUALITY_EPIC)
			frame.Item.Name:SetText(itemName)
			frame.Item.Icon:SetTexture(itemTexture)
			frame.Item.IconBorder:SetVertexColor(r, g, b)
			frame.Item.glow:SetVertexColor(r, g, b)
			frame.Item.Name:SetTextColor(r, g, b)
			frame.itemLink = itemLink
		end

		local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(tokenInfo.itemID, false, itemInfoResponceCallback, true)

		if itemName then
			itemInfoResponceCallback(nil, itemName, nil, itemRarity, nil, nil, nil, nil, nil, nil, itemTexture)
		else
			itemInfoResponceCallback(nil, LOADING_LABEL, nil, 4, nil, nil, nil, nil, nil, nil, "Interface\\ICONS\\INV_Misc_QuestionMark")
		end

		frame.tokenInfo = tokenInfo
		frame.itemLink = itemLink

		if tokenInfo.iconID and tokenInfo.iconID ~= 0 then
			frame.RoleTexture:SetTexCoord(GetTexCoordsForRole(roleNameToIconID[tokenInfo.iconID]))
		else
			frame.RoleTexture:SetTexCoord(GetTexCoordsForRole("DAMAGER"))
		end

		frame.Item.Count:SetText(tokenInfo.itemCount > 1 and tokenInfo.itemCount or "")

		local name

		if tokenInfo.specID == 0 then
			name = UnitClass("player")
		else
			name = GetTalentTabInfo(tokenInfo.specID, "player")
		end

		frame.Header.Text:SetText(name)

		frame.Item.glow:Show()
		frame.Item.glow.animIn:Play()
		frame:Show()
	end

	for index = numTokens + 1, #self.Options do
		self.Options[index]:Hide()
	end

	self:SetWidth(64 * 2 + 210 * numTokens + 24 * (numTokens - 1))
	UpdateUIPanelPositions(self)
end

function QuestChoiceOption_OnLoad(self)
	local _, classFileName = UnitClass("player")
	self.RoleBackground:SetVertexColor(GetClassColorObj(classFileName):GetRGB())

	self.Item.UpdateTooltip = QuestChoiceOption_OnEnter
end

function QuestChoiceOption_OnEnter(self)
	local itemLink = self:GetParent().itemLink
	if itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end
end

function QuestChoiceOption_OnClick(self)
	local itemLink = self:GetParent().itemLink
	if itemLink and IsModifiedClick() then
		if HandleModifiedItemClick(itemLink) then
			return
		end
	end
end

function QuestChoiceOptionButton_OnClick(self, button)
	local tokenInfo = self:GetParent().tokenInfo
	if tokenInfo.itemGUID then
		SendServerMessage("ACMSG_UPGRADE_TOKEN", string.format("%d:%d:%s", tokenInfo.tokenID, tokenInfo.itemID, tokenInfo.itemGUID))
	else
		SendServerMessage("ACMSG_TRADE_TOKEN", string.format("%d:%d", tokenInfo.tokenID, tokenInfo.itemID))
	end
	HideUIPanel(ChooseItemFrame)
end

function EventHandler:ASMSG_SHOW_TOKEN_TRADE(msg)
	local tokenID, tokenInfoStr = string.split("|", msg, 2)
	tokenID = tonumber(tokenID)

	table.wipe(TOKEN_INFO_LIST)

	if tokenID then
		for index, tokenInfo in ipairs({StringSplitEx("|", tokenInfoStr)}) do
			local specID, iconID, itemID, itemCount = string.split(":", tokenInfo)
			if specID and iconID and itemID then
				TOKEN_INFO_LIST[index] = {
					specID = tonumber(specID),
					iconID = tonumber(iconID),
					itemID = tonumber(itemID),
					tokenID = tonumber(tokenID),
					itemCount = tonumber(itemCount) or 1,
				}
			end
		end
	end

	FireCustomClientEvent("TOKEN_CHOICE_UPDATE")
end

function EventHandler:ASMSG_SHOW_TOKEN_UPGRADE(msg)
	local tokenID, itemGUID, tokenInfoStr = string.split("|", msg, 3)
	tokenID = tonumber(tokenID)

	table.wipe(TOKEN_INFO_LIST)

	if tokenID and itemGUID then
		for index, tokenInfo in ipairs({StringSplitEx("|", tokenInfoStr)}) do
			local specID, iconID, itemID = string.split(":", tokenInfo)
			if specID and iconID and itemID then
				TOKEN_INFO_LIST[index] = {
					specID = tonumber(specID),
					iconID = tonumber(iconID),
					itemID = tonumber(itemID),
					tokenID = tonumber(tokenID),
					itemGUID = itemGUID,
					itemCount = 1,
				}
			end
		end
	end

	FireCustomClientEvent("TOKEN_CHOICE_UPDATE")
end

function EventHandler:ASMSG_TRADE_TOKEN_RESPONSE(msg)
	local errorID = tonumber(msg)
	if errorID == 0 then
--		FireCustomClientEvent("TOKEN_CHOICE_CLOSE")
	else
		local errorString = errorID and _G["CHOOSE_ITEM_ERROR_" .. errorID]
		if errorString then
			UIErrorsFrame:AddMessage(errorString, 1.0, 0.1, 0.1, 1.0)
		else
			GMError("[ASMSG_TRADE_TOKEN_RESPONSE]: Unknown error %s", errorID or "nil")
		end
	end
end

function EventHandler:ACMSG_UPGRADE_TOKEN_RESPONSE(msg)
	local errorID = tonumber(msg)
	if errorID == 0 then
--		FireCustomClientEvent("TOKEN_CHOICE_CLOSE")
	else
		local errorString = errorID and _G["TOKEN_UPGRAGE_ERROR_" .. errorID]
		if errorString then
			UIErrorsFrame:AddMessage(errorString, 1.0, 0.1, 0.1, 1.0)
		else
			GMError("[ACMSG_UPGRADE_TOKEN_RESPONSE]: Unknown error %s", errorID or "nil")
		end
	end
end