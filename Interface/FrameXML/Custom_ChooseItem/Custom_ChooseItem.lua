UIPanelWindows["ChooseItemFrame"] = { area = "center", pushable = 0, whileDead = 1, allowOtherPanels = 1, checkFit = 1, checkFitExtraWidth = 360 }

ChooseItemFrameMixin = {}

function ChooseItemFrameMixin:OnLoad()
	self.itemOptions = {}

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
--	self:RegisterEvent("PLAYER_DEAD")
	self:RegisterCustomEvent("TOKEN_CHOICE_UPDATE")
	self:RegisterCustomEvent("TOKEN_CHOICE_CLOSE")
end

function ChooseItemFrameMixin:OnEvent(event, ...)
	if event == "TOKEN_CHOICE_UPDATE" then
		ShowUIPanel(self)
		self:Update()
	elseif (event == "PLAYER_DEAD" or event == "PLAYER_ENTERING_WORLD" or event == "TOKEN_CHOICE_CLOSE") then
		HideUIPanel(self)
	end
end

function ChooseItemFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
end

function ChooseItemFrameMixin:Update()
	local numTokens = GetNumItemChoiceOptions()
	if numTokens == 0 then
		HideUIPanel(self)
		return
	end

	for index = 1, numTokens do
		local frame = self.itemOptions[index]
		if not frame then
			frame = CreateFrame("Frame", "ChooseItemOption"..index, self, "ChooseItemOptionTemplate")
			frame:SetID(index)
			if index == 1 then
				frame:SetPoint("LEFT", 64, 4)
			else
				frame:SetPoint("LEFT", self.itemOptions[index - 1], "RIGHT", 24, 0)
			end
			self.itemOptions[index] = frame
		end

		frame:UpdateOption()

		frame.Item.glow:Show()
		frame.Item.glow.animIn:Play()
		frame:Show()
	end

	for index = numTokens + 1, #self.itemOptions do
		self.itemOptions[index]:Hide()
	end

	self:SetWidth(64 * 2 + 210 * numTokens + 24 * (numTokens - 1))
	UpdateUIPanelPositions(self)
end

ChooseItemOptionMixin = {}

function ChooseItemOptionMixin:OnLoad()
	local _, classFileName = UnitClass("player")
	self.RoleBackground:SetVertexColor(GetClassColorObj(classFileName):GetRGB())

	self.SpecBorder:SetAtlas("PKBT-Portrait-Ring-Gold")

	self.Item.UpdateTooltip = self.OnEnter
end

function ChooseItemOptionMixin:OnItemEnter(this)
	local itemLink = self.itemLink
	if itemLink then
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end
end

function ChooseItemOptionMixin:OnItemClick(button)
	local itemLink = self.itemLink
	if itemLink and IsModifiedClick() then
		if HandleModifiedItemClick(itemLink) then
			return
		end
	end
end

function ChooseItemOptionMixin:UpdateOption()
	local itemID, itemCount, specID, role = GetItemChoiceOptionInfo(self:GetID())

	local optionTitle

	if specID == 0 then
		optionTitle = UnitClass("player")
		self.RoleTexture:SetTexCoord(GetTexCoordsForRole(role))
		self.RoleTexture:Show()

		self.SpecIcon:Hide()
		self.SpecBorder:Hide()
		self.SpecRoleIcon:Hide()
	else
		local name, icon, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(specID, "player")
		optionTitle = name

		self.RoleTexture:Hide()

		self.SpecIcon:SetTexCoord(0, 1, 0, 1)
		SetPortraitToTexture(self.SpecIcon, icon)
		self.SpecIcon:Show()
		self.SpecBorder:Show()

		self.SpecRoleIcon:SetTexCoord(GetTexCoordsForRole(role))
		self.SpecRoleIcon:Show()
	end

	self.Header.Text:SetText(optionTitle)

	local function itemInfoResponceCallback(_, itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture)
		local r, g, b = GetItemQualityColor(itemRarity or LE_ITEM_QUALITY_EPIC)
		self.Item.Name:SetText(itemName)
		self.Item.Icon:SetTexture(itemTexture)
		self.Item.IconBorder:SetVertexColor(r, g, b)
		self.Item.glow:SetVertexColor(r, g, b)
		self.Item.Name:SetTextColor(r, g, b)
		self.itemLink = itemLink
	end

	local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemID, false, itemInfoResponceCallback, true)

	if itemName then
		itemInfoResponceCallback(nil, itemName, nil, itemRarity, nil, nil, nil, nil, nil, nil, itemTexture)
	else
		itemInfoResponceCallback(nil, LOADING_LABEL, nil, 4, nil, nil, nil, nil, nil, nil, "Interface\\ICONS\\INV_Misc_QuestionMark")
	end

	self.Item.Count:SetText(itemCount > 1 and itemCount or "")
	self.itemLink = itemLink
end

function ChooseItemOptionMixin:Activate(button)
	SendItemChoiceResponse(self:GetID())
	HideUIPanel(self:GetParent())
end

local TOKEN_INFO_LIST = {}

local sortTokens = function(a, b)
	if a.specID ~= b.specID then
		return a.specID < b.specID
	end
	return a.tokenID < b.tokenID
end

function EventHandler:ASMSG_SHOW_TOKEN_TRADE(msg)
	local tokenID, tokenInfoStr = string.split("|", msg, 2)
	tokenID = tonumber(tokenID)

	table.wipe(TOKEN_INFO_LIST)

	if tokenID then
		for index, tokenInfo in ipairs({StringSplitEx("|", tokenInfoStr)}) do
			local specID, roleID, itemID, itemCount = string.split(":", tokenInfo)
			if specID and roleID and itemID then
				TOKEN_INFO_LIST[index] = {
					tokenID = tonumber(tokenID),
					specID = tonumber(specID),
					roleID = tonumber(roleID),
					itemID = tonumber(itemID),
					itemCount = tonumber(itemCount) or 1,
				}
			end
		end

		table.sort(TOKEN_INFO_LIST, sortTokens)
	end

	FireCustomClientEvent("TOKEN_CHOICE_UPDATE")
end

function EventHandler:ASMSG_SHOW_TOKEN_UPGRADE(msg)
	local tokenID, itemGUID, tokenInfoStr = string.split("|", msg, 3)
	tokenID = tonumber(tokenID)

	table.wipe(TOKEN_INFO_LIST)

	if tokenID and itemGUID then
		for index, tokenInfo in ipairs({StringSplitEx("|", tokenInfoStr)}) do
			local specID, roleID, itemID = string.split(":", tokenInfo)
			if specID and roleID and itemID then
				TOKEN_INFO_LIST[index] = {
					tokenID = tonumber(tokenID),
					specID = tonumber(specID),
					roleID = tonumber(roleID),
					itemID = tonumber(itemID),
					itemGUID = itemGUID,
					itemCount = 1,
				}
			end
		end

		table.sort(TOKEN_INFO_LIST, sortTokens)
	end

	FireCustomClientEvent("TOKEN_CHOICE_UPDATE")
end

function EventHandler:ASMSG_TRADE_TOKEN_RESPONSE(msg)
	local errorID = tonumber(msg)
	if errorID == 0 then
		table.wipe(TOKEN_INFO_LIST)
		FireCustomClientEvent("TOKEN_CHOICE_CLOSE")
	else
		local errorString = errorID and _G["CHOOSE_ITEM_ERROR_" .. errorID]
		if errorString then
			FireClientEvent("UI_ERROR_MESSAGE", errorString)
		else
			GMError(string.format("[ASMSG_TRADE_TOKEN_RESPONSE]: Unknown error %s", errorID or "nil"))
		end
	end
end

function EventHandler:ACMSG_UPGRADE_TOKEN_RESPONSE(msg)
	local errorID = tonumber(msg)
	if errorID == 0 then
		table.wipe(TOKEN_INFO_LIST)
		FireCustomClientEvent("TOKEN_CHOICE_CLOSE")
	else
		local errorString = errorID and _G["TOKEN_UPGRAGE_ERROR_" .. errorID]
		if errorString then
			FireClientEvent("UI_ERROR_MESSAGE", errorString)
		else
			GMError(string.format("[ACMSG_UPGRADE_TOKEN_RESPONSE]: Unknown error %s", errorID or "nil"))
		end
	end
end

local ROLE_ID_TO_NAME = {
	[1] = "DAMAGER",
	[2] = "RANGEDAMAGER",
	[3] = "TANK",
	[4] = "HEALER"
}

function GetNumItemChoiceOptions()
	return #TOKEN_INFO_LIST
end

function GetItemChoiceOptionInfo(optionIndex)
	if type(optionIndex) ~= "number" then
		error(string.format("bad argument #1 to 'GetItemChoiceOptionInfo' (number expected, got %s)", optionIndex ~= nil and type(optionIndex) or "no value"), 2)
	elseif optionIndex < 0 or optionIndex > #TOKEN_INFO_LIST then
		error(string.format("bad argument #1 to 'GetItemChoiceOptionInfo' (index %s out of range)", optionIndex), 2)
	end

	local optionInfo = TOKEN_INFO_LIST[optionIndex]
	if optionInfo then
		local role
		if optionInfo.roleID and optionInfo.roleID ~= 0 then
			role = ROLE_ID_TO_NAME[optionInfo.roleID]
		else
			role = "DAMAGER"
		end

		return optionInfo.itemID, optionInfo.itemCount, optionInfo.specID, role
	end
end

function SendItemChoiceResponse(optionIndex)
	if type(optionIndex) ~= "number" then
		error(string.format("bad argument #1 to 'SendItemChoiceResponse' (number expected, got %s)", optionIndex ~= nil and type(optionIndex) or "no value"), 2)
	elseif optionIndex < 0 or optionIndex > #TOKEN_INFO_LIST then
		error(string.format("bad argument #1 to 'SendItemChoiceResponse' (index %s out of range)", optionIndex), 2)
	end

	local optionInfo = TOKEN_INFO_LIST[optionIndex]
	if optionInfo and not optionInfo.AWAIT_RESPONSE then
		optionInfo.AWAIT_RESPONSE = true

		if optionInfo.itemGUID then
			SendServerMessage("ACMSG_UPGRADE_TOKEN", string.format("%d:%d:%s", optionInfo.tokenID, optionInfo.itemID, optionInfo.itemGUID))
		else
			SendServerMessage("ACMSG_TRADE_TOKEN", string.format("%d:%d", optionInfo.tokenID, optionInfo.itemID))
		end

		return true
	end

	return false
end