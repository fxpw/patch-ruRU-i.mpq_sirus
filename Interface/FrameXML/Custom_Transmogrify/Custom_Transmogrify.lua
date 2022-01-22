--	Filename:	Sirus_Transmogrify.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local transmogrifyCancelSlotID = nil

local BUTTONS = {}
local TRANSMOGRIFY_DATA = {}
local TRANSMOGRIFY_COST = {
	{
		ilevel = 200,
		cost = 500000
	},
	{
		ilevel = 232,
		cost = 1000000
	},
	{
		ilevel = 251,
		cost = 1500000
	},
	{
		ilevel = 277,
		cost = 3000000
	},
	{
		ilevel = 290,
		cost = 5000000
	},
	{
		ilevel = 303,
		cost = 10000000
	}
}

local errorMessage = {
	"",
	TRANSMOGRIFY_ERROR_1,
	TRANSMOGRIFY_ERROR_2,
	TRANSMOGRIFY_ERROR_3,
	TRANSMOGRIFY_ERROR_4,
	TRANSMOGRIFY_ERROR_5,
	TRANSMOGRIFY_ERROR_6,
	TRANSMOGRIFY_ERROR_7,
	TRANSMOGRIFY_ERROR_8,
	TRANSMOGRIFY_ERROR_9,
	TRANSMOGRIFY_ERROR_10,
}

local TransmogrifyCost = {}


UIPanelWindows["TransmogrifyFrame"] = { area = "left", pushable = 0, whileDead = 1, xOffset = "15", yOffset = "-10", width = 354, height = 424 }

local transmogrifyTutorial = {}

function TransmogrifyFrame_OnLoad( self, ... )
	SetPortraitToTexture(TransmogrifyFrameArtPortrait, "Interface\\Icons\\INV_Arcane_Orb")

	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
end

function TransmogrifyFrame_OnShow( self, ... )
	TransmogrifyCost = {}

	if transmogrifyTutorial.Tutorial then
		NPE_TutorialPointerFrame:Hide(transmogrifyTutorial.Tutorial)
		transmogrifyTutorial.Tutorial = nil
	end

	if not NPE_TutorialPointerFrame:GetKey("TransmogrifyTutorial_1") then
		transmogrifyTutorial.Tutorial = NPE_TutorialPointerFrame:Show(TRANSMOGRIFY_FRAME_TUTORIAL_1, "LEFT", self.TutorialButton, 0, 0)
	end

	SendAddonMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST", nil, "WHISPER", UnitName("player"))
end

function TransmogrifyFrame_OnHide( self, ... )
	TRANSMOGRIFY_DATA = {}

	if transmogrifyTutorial.Tutorial then
		NPE_TutorialPointerFrame:Hide(transmogrifyTutorial.Tutorial)
		transmogrifyTutorial.Tutorial = nil
	end
end

function TransmogrifyFrame_OnEvent( self, event, slotid, ... )
	HideUIPanel(self)
end

function TransmogrifyFrameTutorialButton_OnEnter( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetText(TRANSMOGRIFY_FRAME_HELP_TOOLTIP_HEAD, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	GameTooltip:AddLine(TRANSMOGRIFY_FRAME_HELP_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	GameTooltip:Show()

	if not NPE_TutorialPointerFrame:GetKey("TransmogrifyTutorial_1") then
		if transmogrifyTutorial.Tutorial then
			NPE_TutorialPointerFrame:Hide(transmogrifyTutorial.Tutorial)
			transmogrifyTutorial.Tutorial = nil
		end

		NPE_TutorialPointerFrame:SetKey("TransmogrifyTutorial_1", true)
	end
end

function TransmogrifySlotButton_OnLoad( self, ... )
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:RegisterForDrag("LeftButton")

	RaiseFrameLevelByTwo(self)
end

function TransmogrifySlotButton_OnShow( self, ... )
	local slotName = strsub(self:GetName(), 18)
	local id, textureName = GetInventorySlotInfo(slotName)

	self:GetParent().cost = 0
	self:GetParent().numChanges = 0

	self.id = id
	self.itemID = GetInventoryItemID("player", id)
	self.defaultTexture = textureName
	self.icon:SetTexture(textureName)
	self.verticalFlyout = VERTICAL_FLYOUTS[id]

	BUTTONS[id] = self

	TransmogrifySlotButtonUpdate(self)
end

function TransmogrifySlotButton_OnEvent( self, ... )
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWITEMFLYOUT") and self:IsMouseOver() ) then
			TransmogrifySlotButton_OnEnter(self)
		end
	end
end


function TransmogrifySlotButton_OnClick( self, button, _itemID )
	if ( button == "LeftButton" ) then
		local cursorItem, cursorItemID = GetCursorInfo()
		local itemID = not _itemID and cursorItem == "item" and cursorItemID or _itemID

		if itemID then
			if IsStoreRefundableItem(itemID) or (self.itemID and IsStoreRefundableItem(self.itemID)) then
				local dialog = StaticPopup_Show("STORY_END_REFUND")
				dialog.data = self.id..":"..itemID
				return
			end

			SendAddonMessage("ACMSG_TRANSMOGRIFICATION_PREPARE_REQUEST", self.id..":"..itemID, "WHISPER", UnitName("player"))
		end
		ClearCursor()
	elseif ( button == "RightButton" ) then
		if self.isUndo then
			SendAddonMessage("ACMSG_TRANSMOGRIFICATION_REMOVE", self.id, "WHISPER", UnitName("player"))
			transmogrifyCancelSlotID = self.id
		elseif self.isPending then
			ClearTransmogrifySlot(self)
		end
		self.UndoButton:Hide()
	end
end

function TransmogrifySlotButton_OnEnter( self, ... )
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self.UndoButton:SetShown(self.isUndo and not self.PendingFrame:IsShown())
	self.PendingFrame.undo:SetShown(self.isPending)

	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link)

		if self.isPending or self.isUndo then
			GameTooltip:AddLine(TRANSMOGRIFY_PEDING_TOOLTIP, BLUEHELP_FONT_COLOR.r, BLUEHELP_FONT_COLOR.g, BLUEHELP_FONT_COLOR.b, true)
		end

		GameTooltip:Show()
		if self.data and self.data.TransmogrifyItemID then
			GameTooltip:SetTransmogrifyItem(self.data.TransmogrifyItemID)
		end
	end
end

function TransmogrifySlotButtonUpdate( self )
	self.link = GetInventoryItemLink("player", self.id)
	self.itemTexture = GetInventoryItemTexture("player", self.id)

	if TRANSMOGRIFY_DATA[self.id] then
		local data = TRANSMOGRIFY_DATA[self.id]
		local texture = select(10, GetItemInfo(data.TransmogrifyItemID))

		self.data = data

		if data.isTransmogrified then
			self.isUndo = true
		else
			self.isPending = true
		end

		self.icon:SetTexture(texture)
	else
		self.icon:SetTexture(self.itemTexture or self.defaultTexture)
		self.noItem:SetShown(not self.itemTexture)
	end

	self:SetEnabled(self.itemTexture)
	self.icon:SetDesaturated(not TRANSMOGRIFY_DATA[self.id])
	self.PendingFrame:SetShown(TRANSMOGRIFY_DATA[self.id] and not TRANSMOGRIFY_DATA[self.id].isTransmogrified)
	self.altTexture:SetShown(TRANSMOGRIFY_DATA[self.id] and TRANSMOGRIFY_DATA[self.id].isTransmogrified)

	TransmogrifyFrame_UpdateApplyButton( self )
end

function ClickTransmogrifySlot( self, itemID )
	local _, _, _, ilvl = GetItemInfo(self.link)
	local cost = 0

	TRANSMOGRIFY_DATA[self.id] = {
		isTransmogrified = false,
		TransmogrifyItemID = itemID
	}

	TransmogrifyModelFrame:TryOn(itemID)
	ClearCursor()

	for _, slotCost in pairs(TransmogrifyCost) do
		cost = cost + slotCost
	end

	self:GetParent().cost = cost
	self:GetParent().numChanges = self:GetParent().numChanges + 1

	TransmogrifySlotButtonUpdate(self)
	-- TransmogrifySlotButton_OnEnter(self)
end

function ClearTransmogrifySlot( self )
	transmogrifyCancelSlotID = nil

	local _, _, _, ilvl = GetItemInfo(self.link)
	local cost = 0

	if self.isUndo or self.isPending then
		TransmogrifyModelFrame:Dress()

		TRANSMOGRIFY_DATA[self.id] = nil
		self.isUndo = false
		self.isPending = false
		self.data = nil

		TransmogrifyCost[self.id] = nil

		for _, slotCost in pairs(TransmogrifyCost) do
			cost = cost + slotCost
		end

		self:GetParent().cost = cost
		self:GetParent().numChanges = self:GetParent().numChanges > 0 and self:GetParent().numChanges - 1 or 0

		for _, button in pairs(BUTTONS) do
			if button.data and button.data.TransmogrifyItemID then
				TransmogrifyModelFrame:TryOn(button.data.TransmogrifyItemID)
			end
		end

		TransmogrifySlotButtonUpdate(self)
		TransmogrifySlotButton_OnEnter(self)
	end
end

function TransmogrifyFrame_UpdateApplyButton( self )
	local canApply

	if ( self:GetParent().cost > GetMoney() ) then
		SetMoneyFrameColor("TransmogrifyMoneyFrame", "red")
	else
		SetMoneyFrameColor("TransmogrifyMoneyFrame")
		if (self:GetParent().numChanges > 0 ) then
			canApply = true
		end
	end

	MoneyFrame_Update("TransmogrifyMoneyFrame", self:GetParent().cost)
	TransmogrifyApplyButton:SetEnabled(canApply)
end

function ApplyTransmogrifications( self, ... )
	local msg = ""

	for _, button in pairs(BUTTONS) do
		if button.data and not button.data.isTransmogrified then
			msg = msg..button.id..":"..button.data.TransmogrifyItemID..";"
		end
	end

	SendAddonMessage("ACMSG_TRANSMOGRIFICATION_APPLY", msg, "WHISPER", UnitName("player"))
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_OPEN( msg )
	for _, block in pairs({strsplit(";", msg)}) do
		local slot, id = strsplit(":", block)
		if slot and id then
			slot = tonumber(slot)
			id = tonumber(id)

			TRANSMOGRIFY_DATA[slot] = {
				isTransmogrified = true,
				TransmogrifyItemID = id,
			}
		end
	end

	ShowUIPanel(TransmogrifyFrame)
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_MENU_CLOSE( msg )
	HideUIPanel(TransmogrifyFrame)
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_REMOVE_RESPONSE( msg )
	C_Timer:After(0.1, function()
		ClearTransmogrifySlot(BUTTONS[transmogrifyCancelSlotID])
		TransmogrifyModelFrame:RefreshUnit()
	end)
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_PREPARE_RESPONSE( msg )
	local slotID, transmogrifyEntry, transmogrifyResult, transmogrifyCost = strsplit(":", msg)
	local owner = GameTooltip:GetOwner()

	slotID = tonumber(slotID)
	transmogrifyEntry = tonumber(transmogrifyEntry)
	transmogrifyResult = tonumber(transmogrifyResult)
	transmogrifyCost = tonumber(transmogrifyCost)

	TransmogrifyCost[slotID] = transmogrifyCost


	if transmogrifyResult == 0 then
		ClickTransmogrifySlot(BUTTONS[slotID], transmogrifyEntry)
	else
		local error = _G["TRANSMOGRIFY_ERROR_"..transmogrifyResult]
		if error then
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0)
		end
	end

	if owner and owner == BUTTONS[slotID] then
		GameTooltip:Hide()
		TransmogrifySlotButton_OnEnter(owner)
	end
end

function EventHandler:ASMSG_TRANSMOGRIFICATION_APPLY_RESPONSE( msg )
	msg = tonumber(msg)
	if msg == 0 then
		for _, button in pairs(BUTTONS) do
			if button.data and not button.data.isTransmogrified then
				button.PendingFrame:Hide()
				button.AnimationFrame:Show()

				button:GetParent().cost = 0
				button:GetParent().numChanges = 0

				TRANSMOGRIFY_DATA[button.id].isTransmogrified = true

				TransmogrifyFrame_UpdateApplyButton( button )
			end
		end
	else
		local error = _G["TRANSMOGRIFY_ERROR_"..msg]
		if error then
			UIErrorsFrame:AddMessage(error, 1.0, 0.1, 0.1, 1.0)
		end
	end
end



TransmogrifySlotButtonMixin = {}

function TransmogrifySlotButtonMixin:OnLoad()
	TransmogrifySlotButton_OnLoad(self)

	self.flyoutFrame = self:GetParent().FlyoutFrame
end

function TransmogrifySlotButtonMixin:OnShow()
	TransmogrifySlotButton_OnShow(self)

	self.PopoutButton:SetDisplay(isOneOf(self.id, 16, 17, 18), false)
end

function TransmogrifySlotButtonMixin:OnUpdate()
	self:UpdateFlyout()
end

function TransmogrifySlotButtonMixin:OnEnter()
	TransmogrifySlotButton_OnEnter(self)

	self:UpdateFlyout()

	local _, numItems = self.flyoutFrame:BuildData(self)

	self.numBuildItems = numItems

	if numItems == 0 then
		return
	end

	self.PopoutButton:Show()
end

function TransmogrifySlotButtonMixin:OnLeave()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")

	self.PendingFrame.undo:Hide()

	GameTooltip:Hide()

	if (self.UndoButton:IsMouseOver() and self.UndoButton:IsShown()) or self.PopoutButton:IsMouseOver() then
		return
	end

	self.UndoButton:Hide()

	if not self.flyoutFrame:IsShown() then
		self.PopoutButton:Hide()
	end
end

function TransmogrifySlotButtonMixin:UpdateFlyout()
	if self.link and (self.numBuildItems and self.numBuildItems > 0) then
		if IsModifiedClick("SHOWITEMFLYOUT") then
			if self:IsMouseOver() then
				if not self.flyoutFrame:IsShown() then
					self.flyoutFrame:SetOwnerSlot(self)
					self.flyoutFrame:UpdateContent()

					self.flyoutFrame:SetShown(self.flyoutFrame:GetNumItems() > 0)
				else
					if self.flyoutFrame:GetOwnerSlot() ~= self then
						self.flyoutFrame:SetOwnerSlot(self)
						self.flyoutFrame:UpdateContent()
					end
				end

				self.flyoutFrame.forceShow = false
			end
		else
			if not self.flyoutFrame.forceShow then
				self.flyoutFrame:Hide()
			end
		end
	end
end

TransmogrifyFlyoutFrameMixin = {}

function TransmogrifyFlyoutFrameMixin:OnLoad()
	self.maxItemButtons 		= 20
	self.maxItemButtonsPerRow 	= 5

	self:SetBackdropBorderColor(0.45,0.35,0.26)

	self.itemButtons = CreateFramePool("BUTTON", self, "TransmogirfyFlyoutButtonTemplate")
end

local function isVerticalCheck( slotID )
	return isOneOf(slotID, 16, 17, 18)
end

function TransmogrifyFlyoutFrameMixin:OnShow()
	local ownerSlot = self:GetOwnerSlot()

	ownerSlot.PopoutButton:SetDisplay(isVerticalCheck(ownerSlot.id), true)
	ownerSlot.PopoutButton:Show()
end

function TransmogrifyFlyoutFrameMixin:OnHide()
	self.forceShow = nil

	local ownerSlot = self:GetOwnerSlot()

	ownerSlot.PopoutButton:SetDisplay(isVerticalCheck(ownerSlot.id), false)

	if not ownerSlot:IsMouseOver() then
		ownerSlot.PopoutButton:Hide()
	end
end

function TransmogrifyFlyoutFrameMixin:BuildData( ownerSlot )
	local slotID 				= ownerSlot.id
	local itemsForSlotSource 	= GetInventoryItemsForSlot(slotID)
	local itemsForSlotSorted 	= {}
	local equipedItemEntry 		= tonumber(string.match(ownerSlot.link, "|Hitem:(%d+)") or -1)

	for itemLication, itemEntry in pairs(itemsForSlotSource) do
		if (itemLication - slotID) ~= ITEM_INVENTORY_LOCATION_PLAYER and equipedItemEntry ~= itemEntry then
			table.insert(itemsForSlotSorted, itemLication)
		end
	end

	table.sort(itemsForSlotSorted)

	for i = self.maxItemButtons + 1, #itemsForSlotSorted do
		itemsForSlotSorted[i] = nil
	end

	local buffer = {}
	local numItems = 0
	for _, itemLication in pairs(itemsForSlotSorted) do
		local entry, _, texture, _, _, _, _, _, _, _, enable = EquipmentManager_GetItemInfoByLocation(itemLication)

		if enable == 1 then
			local _, _, quality = GetItemInfo(entry)

			if quality <= 4 and not buffer[entry] then
				numItems = numItems + 1

				buffer[entry] = {
					entry = entry,
					texture = texture,
					quality = quality
				}
			end
		end
	end

	return buffer, numItems
end

function TransmogrifyFlyoutFrameMixin:UpdateContent()
	local ownerSlot = self:GetOwnerSlot()

	if not ownerSlot then
		return
	end

	local oldOwnerSlot = self:GetOldOwnerSlot()

	if oldOwnerSlot then
		oldOwnerSlot.PopoutButton:SetDisplay(isVerticalCheck(oldOwnerSlot.id), false)

		if oldOwnerSlot ~= ownerSlot and oldOwnerSlot.PopoutButton:IsShown() then
			oldOwnerSlot.PopoutButton:Hide()
		end
	end

	local data, numItems = self:BuildData(ownerSlot)

	self.itemsForSlot 	= data
	self.numItems 		= numItems

	if self:IsShown() and self.numItems == 0 then
		self:Hide()
		return
	end

	if self.numItems > 0 then
		ownerSlot.PopoutButton:SetDisplay(isVerticalCheck(slotID), true)
	else
		ownerSlot.PopoutButton:Hide()
	end

	self:CreateButtons()
end

function TransmogrifyFlyoutFrameMixin:GetNumItems()
	return self.numItems
end

function TransmogrifyFlyoutFrameMixin:GetOldOwnerSlot()
	return self.oldOwnerSlot
end

function TransmogrifyFlyoutFrameMixin:SetOldOwnerSlot( slot )
	self.oldOwnerSlot = slot
end

function TransmogrifyFlyoutFrameMixin:SetOwnerSlot( slot )
	self:SetOldOwnerSlot(self.ownerSlot)

	self.ownerSlot = slot

	self:SetFrameLevel(self:GetOwnerSlot():GetFrameLevel() + 20)

	if isOneOf(slot.id, 16, 17, 18) then
		self:ClearAndSetPoint("TOPLEFT", slot, "BOTTOMLEFT", -4, -10)
	else
		self:ClearAndSetPoint("TOPLEFT", slot, "TOPRIGHT", 10, 4)
	end

end

function TransmogrifyFlyoutFrameMixin:GetOwnerSlot()
	return self.ownerSlot
end

function TransmogrifyFlyoutFrameMixin:CreateButtons()
	local buttons 	= {}

	self.itemButtons:ReleaseAll()

	for _, itemData in pairs(self.itemsForSlot) do
		local button = self.itemButtons:Acquire()

		local numButtons 	= #buttons
		local position 		= numButtons / self.maxItemButtonsPerRow

		if math.floor(position) == position then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 12, -12 - (49) * position);
		else
			button:SetPoint("TOPLEFT", buttons[numButtons], "TOPRIGHT", 12, 0);
		end

		SetItemButtonTexture(button, itemData.texture)

		button.entry = itemData.entry

		button:Show()
		buttons[numButtons + 1] = button
	end

	local numButtons = #buttons
	local numRows = math.ceil(numButtons / self.maxItemButtonsPerRow)
	local height = numRows * 50 + 10
	local width = min(258, numButtons * 50 + 10)

	self:SetSize(width, height)
end

TransmogirfyFlyoutButtonMixin = {}

function TransmogirfyFlyoutButtonMixin:OnEnter()
	if self.entry then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink("Hitem:"..self.entry)
		GameTooltip:Show()
	end
end

function TransmogirfyFlyoutButtonMixin:OnClick()
	self:GetParent():Hide()

	local slotItemID = self:GetParent():GetOwnerSlot().itemID
	local slotID, itemID = self:GetParent():GetOwnerSlot().id, self.entry

	if IsStoreRefundableItem(itemID) or (slotItemID and IsStoreRefundableItem(slotItemID)) then
		local dialog = StaticPopup_Show("STORY_END_REFUND")
		dialog.data = slotID..":"..itemID
		return
	end

	SendServerMessage("ACMSG_TRANSMOGRIFICATION_PREPARE_REQUEST", string.format("%d:%d", slotID, itemID))
end

TransmogrifySlotPopoutButtonMixin = {}

function TransmogrifySlotPopoutButtonMixin:OnLoad()
	self.slot = self:GetParent()
end

function TransmogrifySlotPopoutButtonMixin:OnClick()
	self.slot.flyoutFrame:SetOwnerSlot(self.slot)
	self.slot.flyoutFrame:UpdateContent()

	local toggler = (not self.slot.flyoutFrame:IsShown()) and self.slot.flyoutFrame:GetNumItems() > 0

	self.slot.flyoutFrame.forceShow = toggler
	self.slot.flyoutFrame:SetShown(toggler)
end

function TransmogrifySlotPopoutButtonMixin:SetDisplay( isVertical, isReversed )
	self.isVertical = self.isVertical or isVertical

	if self.isVertical then
		self:ClearAndSetPoint("TOP", self:GetParent(), "BOTTOM", 0, 2)
		self:SetSize(36, 16)

		if isReversed then
			self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0, 0.5)
			self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 0.5, 1)
		else
			self:GetNormalTexture():SetTexCoord(0.15625, 0.84375, 0.5, 0)
			self:GetHighlightTexture():SetTexCoord(0.15625, 0.84375, 1, 0.5)
		end
	else
		if isReversed then
			self:GetNormalTexture():SetTexCoord(0.15625, 0, 0.84375, 0, 0.15625, 0.5, 0.84375, 0.5)
			self:GetHighlightTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 1, 0.84375, 1)
		else
			self:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
			self:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)
		end
	end
end