local GetItemInfo = C_Item._GetItemInfo;

UIPanelWindows["WardrobeFrame"] = { area = "left", pushable = 0, xOffset = "15", yOffset = "-10", width = 965 };

local function GetPage(entryIndex, pageSize)
	return floor((entryIndex - 1) / pageSize) + 1;
end

WardrobeFrameMixin = {}

function WardrobeFrameMixin:OnLoad()
	SetPortraitToTexture(WardrobeFramePortrait, "Interface\\Icons\\INV_Arcane_Orb");
	WardrobeFrameTitleText:SetText(TRANSMOGRIFY);

	self:RegisterCustomEvent("TRANSMOGRIFY_OPEN");
	self:RegisterCustomEvent("TRANSMOGRIFY_CLOSE");
end

function WardrobeFrameMixin:OnShow()
	self:HidePointerTutorial();

	if not NPE_TutorialPointerFrame:GetKey("TransmogrifyTutorial_1") then
		self.pointerTutorial = NPE_TutorialPointerFrame:Show(TRANSMOGRIFY_FRAME_TUTORIAL_1, "LEFT", self.TutorialButton, 0, 0);
	end
end

function WardrobeFrameMixin:OnHide()
	self:HidePointerTutorial();
end

function WardrobeFrameMixin:OnEvent(event, ...)
	if event == "TRANSMOGRIFY_OPEN" then
		ShowUIPanel(self);
	elseif event == "TRANSMOGRIFY_CLOSE" then
		HideUIPanel(self);
	end
end

function WardrobeFrameMixin:ShowPointerTutorial()
	GameTooltip:SetOwner(self.TutorialButton, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:SetText(TRANSMOGRIFY_FRAME_HELP_TOOLTIP_HEAD, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	GameTooltip:AddLine(TRANSMOGRIFY_FRAME_HELP_TOOLTIP, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:Show();

	if not NPE_TutorialPointerFrame:GetKey("TransmogrifyTutorial_1") then
		self:HidePointerTutorial();
		NPE_TutorialPointerFrame:SetKey("TransmogrifyTutorial_1", true);
	end
end

function WardrobeFrameMixin:HidePointerTutorial()
	if self.pointerTutorial then
		NPE_TutorialPointerFrame:Hide(self.pointerTutorial);
		self.pointerTutorial = nil;
	end
end

TransmogFrameMixin = {};

function TransmogFrameMixin:OnLoad()
	local _, fileName = UnitRace("player");
	if fileName == "Scourge" then
		fileName = "undead";
	elseif fileName == "Naga" then
		fileName = "orc";
	elseif fileName == "Queldo" then
		fileName = "bloodelf";
	end
	self.BG:SetAtlas(string.format("transmog-background-race-%s", string.lower(fileName)));

	self.MoneyFrame:SetPoint("RIGHT", self.MoneyRight, 6, 0);

	self:RegisterCustomEvent("TRANSMOGRIFY_UPDATE");
	self:RegisterCustomEvent("TRANSMOGRIFY_SUCCESS");
end

function TransmogFrameMixin:OnEvent(event, ...)
	if event == "TRANSMOGRIFY_UPDATE" then
		self:MarkDirty();
	elseif event == "TRANSMOGRIFY_SUCCESS" then
		local transmogLocation = ...;
		local slotButton = self:GetSlotButton(transmogLocation);
		if slotButton then
			slotButton:OnTransmogrifySuccess();
		end
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		if C_Transmog.IsAtTransmogNPC() then
			HideUIPanel(WardrobeFrame);
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		local unit = ...;
		if unit == "player" then
			self:RefreshPlayerModel();
		end
	end
end

function TransmogFrameMixin:OnShow()
	HideUIPanel(CollectionsJournal);
	WardrobeCollectionFrame:SetContainer(WardrobeFrame);

	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:RegisterEvent("UNIT_MODEL_CHANGED");

	self:RefreshPlayerModel();
end

function TransmogFrameMixin:OnHide()
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	C_Transmog.Close();
end

function TransmogFrameMixin:MarkDirty()
	self.dirty = true;
end

function TransmogFrameMixin:OnUpdate()
	if self.dirty then
		self:Update();
	end
end

function TransmogFrameMixin:SelectSlotButton(slotButton, fromOnClick)
	if self.selectedSlotButton then
		self.selectedSlotButton:SetSelected(false);
	end
	self.selectedSlotButton = slotButton;
	if slotButton then
		slotButton:SetSelected(true);
		if fromOnClick and WardrobeCollectionFrame.activeFrame ~= WardrobeCollectionFrame.ItemsCollectionFrame then
			WardrobeCollectionFrame:ClickTab(WardrobeCollectionFrame.ItemsTab);
		end
		if WardrobeCollectionFrame.activeFrame == WardrobeCollectionFrame.ItemsCollectionFrame then
			local _, _, selectedSourceID = TransmogUtil.GetInfoForEquippedSlot(slotButton.transmogLocation);
			local forTransmog = true;
			local effectiveCategory, effectiveSubCategory = C_Transmog.GetSlotEffectiveCategory(slotButton.transmogLocation);
			WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(selectedSourceID, slotButton.transmogLocation, true, forTransmog, effectiveCategory, effectiveSubCategory);
			WardrobeCollectionFrame.ItemsCollectionFrame:SetTransmogrifierAppearancesShown(true);
		end
	else
		WardrobeCollectionFrame.ItemsCollectionFrame:SetTransmogrifierAppearancesShown(false);
	end
end

function TransmogFrameMixin:GetSelectedTransmogLocation()
	if self.selectedSlotButton then
		return self.selectedSlotButton.transmogLocation;
	end
	return nil;
end

function TransmogFrameMixin:RefreshPlayerModel()
	self.ModelFrame:SetUnit("player");
	self:Update();
end

function TransmogFrameMixin:Update()
	self.dirty = false;

	WardrobeTransmogFrame.ModelFrame:Dress()

	for i, slotButton in ipairs(self.SlotButtons) do
		slotButton:Update();
	end
	for i, slotButton in ipairs(self.SlotButtons) do
		slotButton:RefreshItemModel();
	end

	self:UpdateApplyButton();
	self.OutfitDropDown:UpdateSaveButton();

	if not self.selectedSlotButton or not self.selectedSlotButton:IsEnabled() then
		-- select first valid slot or clear selection
		local validSlotButton;
		for i, slotButton in ipairs(self.SlotButtons) do
			if slotButton:IsEnabled() and slotButton.transmogLocation:IsAppearance() then
				validSlotButton = slotButton;
				break;
			end
		end
		self:SelectSlotButton(validSlotButton);
	else
		self:SelectSlotButton(self.selectedSlotButton);
	end
end

function TransmogFrameMixin:SetPendingTransmog(transmogID, category, subCategory)
	if self.selectedSlotButton then
		local transmogLocation = self.selectedSlotButton.transmogLocation;
		local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, transmogID, category, subCategory);
		C_Transmog.SetPending(transmogLocation, pendingInfo);
	end
end

function TransmogFrameMixin:UpdateApplyButton()
	local cost = C_Transmog.GetApplyCost();
	local canApply;
	if cost and cost > GetMoney() then
		SetMoneyFrameColor("WardrobeTransmogFrameMoneyFrame", "red");
	else
		SetMoneyFrameColor("WardrobeTransmogFrameMoneyFrame");
		if cost then
			canApply = true;
		end
	end
	MoneyFrame_Update("WardrobeTransmogFrameMoneyFrame", cost or 0, true);	-- always show 0 copper
	self.ApplyButton:SetEnabled(canApply);
	self.ModelFrame.ClearAllPendingButton:SetShown(canApply);
end

function TransmogFrameMixin:GetSlotButton(transmogLocation)
	for i, slotButton in ipairs(self.SlotButtons) do
		if slotButton.transmogLocation:IsEqual(transmogLocation) then
			return slotButton;
		end
	end
end

function TransmogFrameMixin:ApplyPending(lastAcceptedWarningIndex)
	if lastAcceptedWarningIndex == 0 or not self.applyWarningsTable then
		self.applyWarningsTable = C_Transmog.GetApplyWarnings();
	end
	self.redoApply = nil;
	if self.applyWarningsTable and lastAcceptedWarningIndex < #self.applyWarningsTable then
		lastAcceptedWarningIndex = lastAcceptedWarningIndex + 1;
		local r, g, b = GetItemQualityColor(self.applyWarningsTable[lastAcceptedWarningIndex].itemQuality or 1);
		local data = {
			["name"] = self.applyWarningsTable[lastAcceptedWarningIndex].itemName,
			["link"] = self.applyWarningsTable[lastAcceptedWarningIndex].itemLink,
			["texture"] = self.applyWarningsTable[lastAcceptedWarningIndex].itemIcon,
			["color"] = {r, g, b, 1},
			["useLinkForItemInfo"] = true,
			["warningIndex"] = lastAcceptedWarningIndex;
		};
		StaticPopup_Show("TRANSMOG_APPLY_WARNING", self.applyWarningsTable[lastAcceptedWarningIndex].text, nil, data);
		self:UpdateApplyButton();
		-- return true to keep static popup open when chaining warnings
		return true;
	else
		local success = C_Transmog.ApplyAllPending();
		if success then
			self:OnTransmogApplied();
			self.applyWarningsTable = nil;
		else
			-- it's retrieving item info
			self.redoApply = true;
		end
		return false;
	end
end

function TransmogFrameMixin:OnTransmogApplied()
	local dropDown = self.OutfitDropDown;
	if dropDown.selectedOutfitID and dropDown:IsOutfitDressed() then
		dropDown:OnOutfitApplied(dropDown.selectedOutfitID);
	end
end

WardrobeOutfitMixin = CreateFromMixins(WardrobeOutfitDropDownMixin, WardrobeOutfitFrameMixin);

function WardrobeOutfitMixin:OnHide()
	WardrobeOutfitDropDownMixin.OnHide(self);
	WardrobeOutfitFrameMixin.OnHide(self);
end

function WardrobeOutfitMixin:OnOutfitApplied(outfitID)
	self:SaveLastOutfit(outfitID);
end

function WardrobeOutfitMixin:LoadOutfit(outfitID)
	if not outfitID then
		return;
	end
	C_Transmog.LoadOutfit(outfitID);
end

function WardrobeOutfitMixin:GetItemTransmogInfoList()
	local parent = self:GetParent();
	local itemTransmogInfoList = {};
	for i = 1, #TransmogSlotOrder do
		local slotID = TransmogSlotOrder[i];
		itemTransmogInfoList[slotID] = CreateAndInitFromMixin(ItemTransmogInfoMixin, parent.SlotIDToButton[slotID] and parent.SlotIDToButton[slotID]:GetEffectiveTransmogID() or 0);
	end
	return itemTransmogInfoList;
end

function WardrobeOutfitMixin:GetLastOutfitID()
	return tonumber(C_CVar:GetValue("C_CVAR_LAST_TRANSMOG_OUTFIT_ID"));
end

TransmogSlotButtonMixin = {};

function TransmogSlotButtonMixin:OnLoad()
	local slot = string.format("%sSLOT", string.upper(string.sub(self:GetName() or "", 22, -7)));
	local slotID, textureName = GetInventorySlotInfo(slot);
	self.slot = slot;
	self.slotID = slotID;
	self.transmogLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
	if self.transmogLocation:IsAppearance() then
		self.Icon:SetTexture(textureName);
	else
		self.Icon:SetTexture(ENCHANT_EMPTY_SLOT_FILEDATAID);
	end
--	self.itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID);

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	local parent = self:GetParent();
	if not parent.SlotButtons then
		parent.SlotButtons = {};
	end
	if not parent.SlotIDToButton then
		parent.SlotIDToButton = {};
	end
	parent.SlotButtons[#parent.SlotButtons + 1] = self;
	parent.SlotIDToButton[slotID] = self;
end

function TransmogSlotButtonMixin:OnClick(mouseButton)
	local isTransmogrified, hasPending, _, _, _, hasUndo = C_Transmog.GetSlotInfo(self.transmogLocation);
	-- save for sound to play on TRANSMOGRIFY_UPDATE event
	self.hadUndo = hasUndo;
	if mouseButton == "RightButton" then
		if hasPending or hasUndo then
			C_Transmog.ClearPending(self.transmogLocation);
			self:OnUserSelect();
		elseif isTransmogrified then
			local newPendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Revert);
			C_Transmog.SetPending(self.transmogLocation, newPendingInfo);
			self:OnUserSelect();
		end
	else
		self:OnUserSelect();
	end
	if self.UndoButton then
		self.UndoButton:Hide();
	end
	self:OnEnter();
end

function TransmogSlotButtonMixin:OnUserSelect()
	local fromOnClick = true;
	self:GetParent():SelectSlotButton(self, fromOnClick);
end

function TransmogSlotButtonMixin:OnEnter()
	local isTransmogrified, hasPending, _, _, _, hasUndo = C_Transmog.GetSlotInfo(self.transmogLocation);

	if self.transmogLocation:IsIllusion() then

	else
		if self.UndoButton and isTransmogrified and not (hasPending or hasUndo) then
			self.UndoButton:Show();
		end

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 14, 0);
		if not canTransmogrify and not hasUndo then
			GameTooltip:SetText(_G[self.slot]);
			--[[
			local tag = TRANSMOG_INVALID_CODES[cannotTransmogrifyReason];
			local errorMsg;
			if tag == "CANNOT_USE" then
				local errorCode, errorString = C_Transmog.GetSlotUseError(self.transmogLocation);
				errorMsg = errorString;
			else
				errorMsg = tag and _G["TRANSMOGRIFY_INVALID_"..tag];
			end
			if errorMsg then
				GameTooltip:AddLine(errorMsg, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
			end
			]]
			GameTooltip:Show();
		else
		--	GameTooltip:SetTransmogrifyItem(self.transmogLocation);
		end
	end
--	self.UpdateTooltip = GenerateClosure(self.OnEnter, self);
end

function TransmogSlotButtonMixin:OnLeave()
	if self.UndoButton and not self.UndoButton:IsMouseOver() then
		self.UndoButton:Hide();
	end
	GameTooltip:Hide();
--	self.UpdateTooltip = nil;
end

function TransmogSlotButtonMixin:OnShow()
	self:Update();
end

function TransmogSlotButtonMixin:OnHide()
	self.priorTransmogID = nil;
end

function TransmogSlotButtonMixin:SetSelected(selected)
	self.SelectedTexture:SetShown(selected);
end

function TransmogSlotButtonMixin:OnTransmogrifySuccess()
	self:Animate();
	self:GetParent():MarkDirty();
	self.priorTransmogID = nil;
end

function TransmogSlotButtonMixin:Animate()
	-- don't do anything if already animating;
	if self.AnimFrame:IsShown() then
		return;
	end
	local isTransmogrified = C_Transmog.GetSlotInfo(self.transmogLocation);
	if isTransmogrified then
		self.AnimFrame.Transition:Show();
	else
		self.AnimFrame.Transition:Hide();
	end
	self.AnimFrame:Show();
end

function TransmogSlotButtonMixin:OnAnimFinished()
	self.AnimFrame:Hide();
	self:Update();
end

function TransmogSlotButtonMixin:Update()
	if not self:IsShown() then
		return;
	end

	local isTransmogrified, hasPending, isPendingCollected, canTransmogrify, cannotTransmogrifyReason, hasUndo, isHideVisual, texture = C_Transmog.GetSlotInfo(self.transmogLocation);
	local hasChange = (hasPending and canTransmogrify) or hasUndo;

	if self.transmogLocation:IsAppearance() then
		if canTransmogrify or hasChange then
			self.Icon:SetTexture(texture);
			self.NoItemTexture:Hide();
		else
			local tag = TRANSMOG_INVALID_CODES[cannotTransmogrifyReason];
			if tag  == "NO_ITEM" or tag == "SLOT_FOR_RACE" then
				local _, defaultTexture = GetInventorySlotInfo(self.slot);
				self.Icon:SetTexture(defaultTexture);
			else
				self.Icon:SetTexture(texture);
			end
			self.NoItemTexture:Show();
		end
	else
		-- check for weapons lacking visual attachments
		local sourceID = self.dependencySlot:GetEffectiveTransmogID();
		if sourceID ~= NO_TRANSMOG_VISUAL_ID and not WardrobeCollectionFrame.ItemsCollectionFrame:CanEnchantSource(sourceID) then
			-- clear anything in the enchant slot, otherwise cost and Apply button state will still reflect anything pending
			C_Transmog.ClearPending(self.transmogLocation);
			isTransmogrified = false;	-- handle legacy, this weapon could have had an illusion applied previously
			canTransmogrify = false;
			self.invalidWeapon = true;
		else
			self.invalidWeapon = false;
		end

		if hasPending or hasUndo or canTransmogrify then
			self.Icon:SetTexture(texture or ENCHANT_EMPTY_SLOT_FILEDATAID);
			self.NoItemTexture:Hide();
		else
			self.Icon:SetColorTexture(0, 0, 0);
			self.NoItemTexture:Show();
		end
	end
	self:SetEnabled(canTransmogrify or hasUndo);

	-- show transmogged border if the item is transmogrified and doesn't have a pending transmogrification or is animating
	local showStatusBorder;
	if hasPending then
		showStatusBorder = hasUndo or (isPendingCollected and canTransmogrify);
	else
		showStatusBorder = isTransmogrified and not hasChange and not self.AnimFrame:IsShown();
	end
	self.StatusBorder:SetShown(showStatusBorder);

	-- show ants frame is the item has a pending transmogrification and is not animating
	if hasChange and (hasUndo or isPendingCollected) and not self.AnimFrame:IsShown() then
		self.PendingFrame:Show();
		if hasUndo then
			self.PendingFrame.Undo:Show();
		else
			self.PendingFrame.Undo:Hide();
		end
	else
		self.PendingFrame:Hide();
	end

	if isHideVisual and not hasUndo then
		if self.HiddenVisualIcon then
			self.HiddenVisualCover:Show();
			self.HiddenVisualIcon:Show();
		end
		local baseTexture = GetInventoryItemTexture("player", self.transmogLocation.slotID);
		self.Icon:SetTexture(baseTexture);
	else
		if self.HiddenVisualIcon then
			self.HiddenVisualCover:Hide();
			self.HiddenVisualIcon:Hide();
		end
	end
end

function TransmogSlotButtonMixin:GetEffectiveTransmogID()
	local appliedSourceID, _, selectedSourceID = TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
	local pendingInfo = C_Transmog.GetPending(self.transmogLocation);

	if pendingInfo then
		if pendingInfo.type == Enum.TransmogPendingType.Revert or pendingInfo.type == Enum.TransmogPendingType.Apply then
			return selectedSourceID;
		elseif pendingInfo.type == Enum.TransmogPendingType.ToggleOff then
			return NO_TRANSMOG_VISUAL_ID;
		end
	end

	return appliedSourceID;
end

function TransmogSlotButtonMixin:RefreshItemModel()
	local appearanceID = self:GetEffectiveTransmogID();
	if appearanceID ~= NO_TRANSMOG_VISUAL_ID then
		local canTryOn = true;

		if self.transmogLocation:IsEitherHand() then
			local selectedTransmogLocation = self:GetParent():GetSelectedTransmogLocation();

			if selectedTransmogLocation then
				if selectedTransmogLocation:IsRanged() then
					if not self.transmogLocation:IsRanged() then
						canTryOn = false;
					end
				else
					if self.transmogLocation:IsRanged() then
						canTryOn = false;
					end
				end
			else
				if self.transmogLocation:IsRanged() then
					canTryOn = false;
				end
			end
		end

--[[
		if self.transmogLocation:IsRanged() then
			local _, hasPending = C_Transmog.GetSlotInfo(self.transmogLocation);
			if not hasPending then
--				local categoryID, subCategoryID = C_Transmog.GetSlotEffectiveCategory(self.transmogLocation);
--				local activeCategoryID = WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory();

				canTryOn = false;
			end
		end
]]

		if canTryOn then
			WardrobeTransmogFrame.ModelFrame:TryOn(appearanceID);
		end
	end
end

-- Collections
local TAB_ITEMS = 1;

local WARDROBE_MODEL_SETUP = {
	["HEADSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = false, FEETSLOT = false, HEADSLOT = false},
	["SHOULDERSLOT"]	= {CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["BACKSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["CHESTSLOT"]		= {CHESTSLOT = false, HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["TABARDSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["SHIRTSLOT"]		= {CHESTSLOT = false, HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["WRISTSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["HANDSSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = false, LEGSSLOT = true,  FEETSLOT = true,  HEADSLOT = true},
	["WAISTSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
	["LEGSSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = false, FEETSLOT = true,  HEADSLOT = true},
	["FEETSLOT"]		= {CHESTSLOT = true,  HANDSSLOT = true,  LEGSSLOT = true,  FEETSLOT = false, HEADSLOT = true},
};

local WARDROBE_MODEL_SETUP_GEAR = {
	["CHESTSLOT"] = 110001,
	["LEGSSLOT"] = 110003,
	["FEETSLOT"] = 110004,
	["HANDSSLOT"] = 110002,
	["HEADSLOT"] = 110000,
};

local COLLECTION_FRAMES = {
	"ItemsCollectionFrame",
};

WardrobeCollectionFrameMixin = {}

function WardrobeCollectionFrameMixin:SetContainer(parent)
	self:SetParent(parent);
	self:ClearAllPoints();

	if parent == CollectionsJournal then
		self:SetPoint("TOPLEFT", CollectionsJournal);
		self:SetPoint("BOTTOMRIGHT", CollectionsJournal);
		self.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -238, -85);
		self.ItemsCollectionFrame.SlotsFrame:Show();
		self.ItemsCollectionFrame.OverlayFrame.BGCornerTopLeft:Hide();
		self.ItemsCollectionFrame.OverlayFrame.BGCornerTopRight:Hide();
		self.ItemsCollectionFrame.WeaponDropDown:SetPoint("TOPRIGHT", -6, -22);
		self.ItemsCollectionFrame.NoValidItemsLabel:Hide();
		self.FilterButton:SetText(FILTER);
		self.ItemsTab:SetPoint("TOPLEFT", 58, -28);
		self:SetTab(self.selectedCollectionTab);
	elseif parent == WardrobeFrame then
		self:SetPoint("TOPRIGHT", 0, 0);
		WardrobeCollectionFrame:SetSize(662, 606);
		self.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -235, -71);
		self.ItemsCollectionFrame.SlotsFrame:Hide();
		self.ItemsCollectionFrame.OverlayFrame.BGCornerTopLeft:Show();
		self.ItemsCollectionFrame.OverlayFrame.BGCornerTopRight:Show();
		self.ItemsCollectionFrame.WeaponDropDown:SetPoint("TOPRIGHT", -32, -25);
		self.FilterButton:SetText(SOURCES);
		self.ItemsTab:SetPoint("TOPLEFT", 8, -28);
		self:SetTab(self.selectedTransmogTab);
	end
	self:Show();
end

function WardrobeCollectionFrameMixin:ClickTab(tab)
	self:SetTab(tab:GetID());
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function WardrobeCollectionFrameMixin:SetTab(tabID)
	PanelTemplates_SetTab(self, tabID);
	local atTransmogrifier = C_Transmog.IsAtTransmogNPC();
	if atTransmogrifier then
		self.selectedTransmogTab = tabID;
	else
		self.selectedCollectionTab = tabID;
	end
	if tabID == TAB_ITEMS then
		self.activeFrame = self.ItemsCollectionFrame;
		self.ItemsCollectionFrame:Show();
		self.SearchBox:ClearAllPoints();
		self.SearchBox:SetPoint("TOPRIGHT", -107, -35);
		self.SearchBox:SetWidth(115);
		local enableSearchAndFilter = self.ItemsCollectionFrame.transmogLocation and self.ItemsCollectionFrame.transmogLocation:IsAppearance();
		self.SearchBox:EnableMouse(enableSearchAndFilter);
		self.FilterButton:Show();
		self.FilterButton:SetEnabled(enableSearchAndFilter);
	end
end

function WardrobeCollectionFrameMixin:GetActiveTab()
	if C_Transmog.IsAtTransmogNPC() then
		return self.selectedTransmogTab;
	else
		return self.selectedCollectionTab;
	end
end

function WardrobeCollectionFrameMixin:OnLoad()
	PanelTemplates_SetNumTabs(self, TAB_ITEMS);
	PanelTemplates_SetTab(self, TAB_ITEMS);
	self.selectedCollectionTab = TAB_ITEMS;
	self.selectedTransmogTab = TAB_ITEMS;

	self.ContentFrames = {};

	for i, frameName in ipairs(COLLECTION_FRAMES) do
		self.ContentFrames[i] = self[frameName];
	end

	for _, itemID in pairs(WARDROBE_MODEL_SETUP_GEAR) do
		local itemName = GetItemInfo(itemID);
		if not itemName then
			C_Item.cacheTooltip:SetHyperlink(string.format("item:%d", itemID));
		end
	end
end

function WardrobeCollectionFrameMixin:OnEvent(event, ...)
	if event == "TRANSMOG_COLLECTION_ITEM_UPDATE" then
		if self.tooltipContentFrame then
			self.tooltipContentFrame:RefreshAppearanceTooltip();
		end
		if self.ItemsCollectionFrame:IsShown() then
			self.ItemsCollectionFrame:ValidateChosenVisualSources();
		end
	elseif event == "UNIT_MODEL_CHANGED" then
		local unit = ...;
		if unit == "player" then

		end
	elseif event == "UPDATE_FLOATING_CHAT_WINDOWS" then
		self:RefreshCameras();
	elseif event == "TRANSMOG_SEARCH_UPDATED" then
		local searchType, category, subCategory = ...;
		if searchType == self:GetSearchType() then
			self.activeFrame:OnSearchUpdate(category, subCategory);
		end
	end
end

function WardrobeCollectionFrameMixin:OnShow()
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_chest_cloth_17");

	self:RegisterEvent("UNIT_MODEL_CHANGED");
	self:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS");

	self:RegisterCustomEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
	self:RegisterCustomEvent("TRANSMOG_SEARCH_UPDATED");

	if C_Transmog.IsAtTransmogNPC() then
		self:SetTab(self.selectedTransmogTab);
	else
		self:SetTab(self.selectedCollectionTab);
	end
	self:UpdateTabButtons();
end

function WardrobeCollectionFrameMixin:OnHide()
	self:UnregisterEvent("UNIT_MODEL_CHANGED");
	self:UnregisterEvent("UPDATE_FLOATING_CHAT_WINDOWS");

	self:UnregisterCustomEvent("TRANSMOG_SEARCH_UPDATED");

	self.jumpToVisualID = nil;
	for _, frame in ipairs(self.ContentFrames) do
		frame:Hide();
	end
end

function WardrobeCollectionFrameMixin:OpenTransmogLink(link)
	if not CollectionsJournal:IsVisible() or not self:IsVisible() then
		ToggleCollectionsJournal(3);
	end

	local linkType, collectionType, id = strsplit(":", link);

	if linkType == "collection" and collectionType == CHAR_COLLECTION_APPEARANCE then
		local sourceID = tonumber(id);
		self:SetTab(TAB_ITEMS);
		-- For links a base appearance is fine
		local categoryID, subCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(categoryID, subCategoryID);
		if slot then
			local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
			self.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
		end
	end
end

function WardrobeCollectionFrameMixin:GoToItem(sourceID)
	self:SetTab(TAB_ITEMS);
	local categoryID, subCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
	local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(categoryID, subCategoryID);
	if slot then
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
		self.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
	end
end

function WardrobeCollectionFrameMixin:UpdateTabButtons()
	-- sets tab
--	self.SetsTab.FlashFrame:SetShown(C_TransmogSets.GetLatestSource() ~= NO_TRANSMOG_SOURCE_ID and not C_Transmog.IsAtTransmogNPC());
end

function WardrobeCollectionFrameMixin:SetAppearanceTooltip(contentFrame, sources, primarySourceID)
	self.tooltipContentFrame = contentFrame;
	local selectedIndex = self.tooltipSourceIndex;
	local showUseError = true;
	self.tooltipSourceIndex, self.tooltipCycle = CollectionWardrobeUtil.SetAppearanceTooltip(GameTooltip, sources, primarySourceID, selectedIndex, showUseError)
end

function WardrobeCollectionFrameMixin:HideAppearanceTooltip()
	self.tooltipContentFrame = nil;
	self.tooltipCycle = nil;
	self.tooltipSourceIndex = nil;
	GameTooltip:Hide();
end

function WardrobeCollectionFrameMixin:UpdateUsableAppearances()
	if not self.updateUsableAppearances then
		C_TransmogCollection.UpdateUsableAppearances();
		self.updateUsableAppearances = true;
	end
end

function WardrobeCollectionFrameMixin:RefreshCameras()
	for _, frame in ipairs(self.ContentFrames) do
		if frame.RefreshCameras then
			frame:RefreshCameras();
		end
	end
end

function WardrobeCollectionFrameMixin:GetAppearanceNameTextAndColor(appearanceInfo)
	return CollectionWardrobeUtil.GetAppearanceNameTextAndColor(appearanceInfo);
end

function WardrobeCollectionFrameMixin:GetAppearanceSourceTextAndColor(appearanceInfo)
	return CollectionWardrobeUtil.GetAppearanceSourceTextAndColor(appearanceInfo);
end

function WardrobeCollectionFrameMixin:UpdateProgressBar(value, max)
	self.ProgressBar:SetMinMaxValues(0, max);
	self.ProgressBar:SetValue(value);
	self.ProgressBar.Text:SetFormattedText("%d/%d", value, max);
end

function WardrobeCollectionFrameMixin:SwitchSearchCategory()
	if self.ItemsCollectionFrame.transmogLocation:IsIllusion() then
		self:ClearSearch();
		self.SearchBox:EnableMouse(false);
		self.FilterButton:Disable();
		return;
	end
	self.SearchBox:EnableMouse(true);
	self.FilterButton:Enable();
	if self.SearchBox:GetText() ~= "" then
		C_TransmogCollection.SetSearch(self:GetSearchType(), self.SearchBox:GetText());
	end
end

function WardrobeCollectionFrameMixin:SetSearch(text)
	if text == "" then
		C_TransmogCollection.ClearSearch(self:GetSearchType());
	else
		C_TransmogCollection.SetSearch(self:GetSearchType(), text);
	end
end

function WardrobeCollectionFrameMixin:ClearSearch(searchType)
	self.SearchBox:SetText("");
	C_TransmogCollection.ClearSearch(searchType or self:GetSearchType());
end

function WardrobeCollectionFrameMixin:GetSearchType()
	return self.activeFrame.searchType;
end

WardrobeItemsCollectionMixin = {};

local spacingNoSmallButton = 2;
local defaultSectionSpacing = 12;

function WardrobeItemsCollectionMixin:CreateSlotButtons()
	local itemsSlots = {"HEAD", "SHOULDER", "BACK", "CHEST", "SHIRT", "TABARD", "WRIST", defaultSectionSpacing, "HANDS", "WAIST", "LEGS", "FEET", defaultSectionSpacing, "MAINHAND", "SECONDARYHAND", "RANGED"};
	local parentFrame = self.SlotsFrame;
	local lastButton;
	local xOffset = spacingNoSmallButton;
	for i = 1, #itemsSlots do
		local value = tonumber(itemsSlots[i]);
		if value then
			-- this is a spacer
			xOffset = value;
		else
			local slotString = itemsSlots[i];
			local button = CreateFrame("Button", "$parentSlotButton"..i, parentFrame, "WardrobeSlotButtonTemplate");
			parentFrame.Buttons[#parentFrame.Buttons + 1] = button;
			button.NormalTexture:SetAtlas("transmog-nav-slot-"..string.lower(slotString), true);
			button.Highlight:SetAtlas("bags-roundhighlight");
			button.SelectedTexture:SetAtlas("transmog-nav-slot-selected", true);
			if lastButton then
				button:SetPoint("LEFT", lastButton, "RIGHT", xOffset, 0);
			else
				button:SetPoint("TOPLEFT");
			end
			button.slot = slotString.."SLOT";
			xOffset = spacingNoSmallButton;
			lastButton = button;
			button.transmogLocation = TransmogUtil.GetTransmogLocation(button.slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
		end
	end
end

function WardrobeItemsCollectionMixin:OnLoad()
	self.searchType = Enum.TransmogSearchType.Items;
	self.SlotsFrame.Buttons = {};

	self:CreateSlotButtons();
	self.OverlayFrame.BGCornerTopLeft:Hide();
	self.OverlayFrame.BGCornerTopRight:Hide();

	self.chosenVisualSources = {};

	self.NUM_ROWS = 3;
	self.NUM_COLS = 6;
	self.PAGE_SIZE = self.NUM_ROWS * self.NUM_COLS;

	UIDropDownMenu_Initialize(self.RightClickDropDown, nil, "MENU");
	self.RightClickDropDown.initialize = WardrobeCollectionFrameRightClickDropDown_Init;

	self:RegisterCustomEvent("TRANSMOG_COLLECTION_UPDATED");
end

function WardrobeItemsCollectionMixin:OnShow()
	self:CheckLatestAppearance();

	local needsUpdate = false;	-- we don't need to update if we call :SetActiveSlot as that will do an update
	if self.jumpToLatestCategoryID and (self.jumpToLatestCategoryID ~= self.activeCategory or self.jumpToLatestSubCategoryID ~= self.activeSubCategory) and not C_Transmog.IsAtTransmogNPC() then
		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(self.jumpToLatestCategoryID);
		-- The model got reset from OnShow, which restored all equipment.
		-- But ChangeModelsSlot tries to be smart and only change the difference from the previous slot to the current slot, so some equipment will remain left on.
		-- This is only set for new apperances, base transmogLocation is fine
		if slot then
			local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.None);
			local ignorePreviousSlot = true;
			self:SetActiveSlot(transmogLocation, self.jumpToLatestCategoryID, self.jumpToLatestSubCategoryID, ignorePreviousSlot);
		end
		self.jumpToLatestCategoryID = nil;
		self.jumpToLatestSubCategoryID = nil;
	elseif self.transmogLocation then
		-- redo the model for the active slot
		self:ChangeModelsSlot(self.transmogLocation);
		needsUpdate = true;
	else
		local transmogLocation = TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
		self:SetActiveSlot(transmogLocation);
	end

	if needsUpdate then
		WardrobeCollectionFrame:UpdateUsableAppearances();
		self:RefreshVisualsList();
		self:UpdateItems();
		self:UpdateWeaponDropDown();
	end
end

function WardrobeItemsCollectionMixin:OnHide()
	self.visualsList = nil;
	self.filteredVisualsList = nil;
end

function WardrobeItemsCollectionMixin:OnMouseWheel(delta)
	self.PagingFrame:OnMouseWheel(delta);
end

function WardrobeItemsCollectionMixin:OnEvent(event, ...)
	if event == "TRANSMOG_COLLECTION_UPDATED" then
		self:CheckLatestAppearance(true);
		self:ValidateChosenVisualSources();
		if self:IsVisible() then
			self:RefreshVisualsList();
			self:UpdateItems();
		end
		WardrobeCollectionFrame:UpdateTabButtons();
	end
end

function WardrobeItemsCollectionMixin:CheckLatestAppearance(changeTab)
	local latestAppearanceID, latestAppearanceCategoryID, latestAppearanceSubCategoryID = C_TransmogCollection.GetLatestAppearance();
	if self.latestAppearanceID ~= latestAppearanceID then
		self.latestAppearanceID = latestAppearanceID;
		self.jumpToLatestAppearanceID = latestAppearanceID;
		self.jumpToLatestCategoryID = latestAppearanceCategoryID;
		self.jumpToLatestSubCategoryID = latestAppearanceSubCategoryID;

		if changeTab and not CollectionsJournal:IsShown() then
			CollectionsJournal_SetTab(CollectionsJournal, 3);
		end
	end
end

function WardrobeItemsCollectionMixin:ChangeModelsSlot(newTransmogLocation, oldTransmogLocation)
	local oldSlot = oldTransmogLocation and oldTransmogLocation:GetSlotName();
	local newSlot = newTransmogLocation:GetSlotName();

	local undressSlot, reloadModel;
	if not newTransmogLocation:IsEitherHand() then
		if oldTransmogLocation and oldTransmogLocation:IsEitherHand() then
			reloadModel = true;
		end

		local newSlotIsArmor = newTransmogLocation:GetArmorCategoryID();
		if newSlotIsArmor then
			undressSlot = true;
		end
	else
		if oldTransmogLocation and not oldTransmogLocation:IsEitherHand() then
			reloadModel = true;
		end
	end

	if not oldTransmogLocation and not reloadModel then
		reloadModel = true;
	end

	for i = 1, #self.Models do
		local model = self.Models[i];

		if reloadModel then
			model:Reload(newSlot, true);
		elseif undressSlot then
			model:EquipTransmogGear(newSlot);
		end
		model.visualInfo = nil;
	end
	self.illusionWeaponVisualID = nil;
end

function WardrobeItemsCollectionMixin:RefreshCameras()
	if self:IsShown() then
		self:OnUnitModelChangedEvent();
	end
end

function WardrobeItemsCollectionMixin:OnUnitModelChangedEvent()
	self:ChangeModelsSlot(self.transmogLocation);
	self:UpdateItems();
end

function WardrobeItemsCollectionMixin:GetActiveSlot()
	return self.transmogLocation and self.transmogLocation:GetSlotName();
end

function WardrobeItemsCollectionMixin:GetActiveCategory()
	return self.activeCategory, self.activeSubCategory;
end

function WardrobeItemsCollectionMixin:IsValidArmorSubCategoryForSlot(categoryID, subCategoryID)
	local name = C_TransmogCollection.GetSubCategoryInfo(categoryID, subCategoryID);
	if name then
		if C_Transmog.IsAtTransmogNPC() then
--			local equippedItemID = GetInventoryItemID("player", self.transmogLocation:GetSlotID());
			return true;
		else
			return true;
		end
	end
	return false;
end

function WardrobeItemsCollectionMixin:IsValidWeaponCategoryForSlot(categoryID)
	local name, isWeapon, _, canMainHand, canOffHand, canRanged = C_TransmogCollection.GetCategoryInfo(categoryID);
	if name and isWeapon then
		if (self.transmogLocation:IsMainHand() and canMainHand) or (self.transmogLocation:IsOffHand() and canOffHand) or (self.transmogLocation:IsRanged() and canRanged) then
			if C_Transmog.IsAtTransmogNPC() then
				local equippedItemID = GetInventoryItemID("player", self.transmogLocation:GetSlotID());
				return C_TransmogCollection.IsCategoryValidForItem(categoryID, nil, equippedItemID);
			else
				return true;
			end
		end
	end
	return false;
end

function WardrobeItemsCollectionMixin:SetActiveSlot(transmogLocation, category, subCategory, ignorePreviousSlot)
	local previousTransmogLocation;
	if not ignorePreviousSlot then
		previousTransmogLocation = self.transmogLocation;
	end
	local slotChanged = not previousTransmogLocation or not previousTransmogLocation:IsEqual(transmogLocation);

	self.transmogLocation = transmogLocation;

	-- figure out a category
	if not category then
		if self.transmogLocation:IsAppearance() then
			local useLastWeaponCategory = self.transmogLocation:IsEitherHand() and self.lastWeaponCategory and self:IsValidWeaponCategoryForSlot(self.lastWeaponCategory);
			if useLastWeaponCategory then
				category = self.lastWeaponCategory;
			else
				local _, _, selectedSourceID = self:GetActiveSlotInfo();
				if selectedSourceID ~= NO_TRANSMOG_SOURCE_ID then
					category, subCategory = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
					if not self:IsValidWeaponCategoryForSlot(category) then
						category = nil;
					end
				end
			end
			if not category then
				if self.transmogLocation:IsEitherHand() then
					-- find the first valid weapon category
					for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
						if self:IsValidWeaponCategoryForSlot(categoryID) then
							category = categoryID;
							break;
						end
					end
				else
					category = self.transmogLocation:GetArmorCategoryID();
					for subCategoryID = (LAST_TRANSMOG_COLLECTION_SUB_CATEGORY - 1), FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY, -1 do
						if self:IsValidArmorSubCategoryForSlot(category, subCategoryID) then
							subCategory = subCategoryID;
							break;
						end
					end
				end
			end
		end
	end

	if not category then
		category, subCategory = 0, nil;
	end

	if slotChanged then
		self:ChangeModelsSlot(transmogLocation, previousTransmogLocation);
	end
	-- set only if category is different or slot is different
	if (category ~= self.activeCategory or subCategory ~= self.activeSubCategory) or slotChanged then
		CloseDropDownMenus();
		self:SetActiveCategory(category, subCategory);
	end
end

function WardrobeItemsCollectionMixin:SetTransmogrifierAppearancesShown(hasAnyValidSlots)
	self.NoValidItemsLabel:SetShown(not hasAnyValidSlots);
	C_TransmogCollection.SetCollectedShown(hasAnyValidSlots);
end

function WardrobeItemsCollectionMixin:UpdateWeaponDropDown()
	local dropdown = self.WeaponDropDown;
	local name, isWeapon;
	if self.transmogLocation:IsAppearance() then
		name, isWeapon = C_TransmogCollection.GetCategoryInfo(self.activeCategory);
	end
	if not isWeapon then
		dropdown:Show();
		name = C_TransmogCollection.GetSubCategoryInfo(self.activeCategory, self.activeSubCategory)
		UIDropDownMenu_SetSelectedValue(dropdown, self.activeSubCategory);
		UIDropDownMenu_SetText(dropdown, name);
		local validCategories = WardrobeCollectionFrameWeaponDropDown_Init(dropdown);
		if validCategories > 1 then
			UIDropDownMenu_EnableDropDown(dropdown);
		else
			UIDropDownMenu_DisableDropDown(dropdown);
		end
	else
		dropdown:Show();
		UIDropDownMenu_SetSelectedValue(dropdown, self.activeCategory);
		UIDropDownMenu_SetText(dropdown, name);
		local validCategories = WardrobeCollectionFrameWeaponDropDown_Init(dropdown);
		if validCategories > 1 then
			UIDropDownMenu_EnableDropDown(dropdown);
		else
			UIDropDownMenu_DisableDropDown(dropdown);
		end
	end
end

function WardrobeItemsCollectionMixin:SetActiveCategory(category, subCategory)
	local previousCategory = self.activeCategory;
	local previousSubCategory = self.activeSubCategory;
	self.activeCategory = category;
	self.activeSubCategory = subCategory;
	if (previousCategory ~= category or previousSubCategory ~= subCategory) and self.transmogLocation:IsAppearance() then
		C_TransmogCollection.SetSearchAndFilterCategory(category, subCategory);
		local _, isWeapon = C_TransmogCollection.GetCategoryInfo(category);
		if isWeapon then
			self.lastWeaponCategory = category;
		end
		self:RefreshVisualsList();
	else
		self:RefreshVisualsList();
		self:UpdateItems();
	end
	self:UpdateWeaponDropDown();

	local slotButtons = self.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		button.SelectedTexture:SetShown(button.transmogLocation:IsEqual(self.transmogLocation));
	end

	local resetPage = false;
	local switchSearchCategory = false;

	if C_Transmog.IsAtTransmogNPC() then
		self.jumpToVisualID = select(4, self:GetActiveSlotInfo());
		resetPage = true;
	end

	if previousCategory ~= category or previousSubCategory ~= subCategory then
		resetPage = true;
		switchSearchCategory = true;
	end

	if resetPage then
		self:ResetPage();
	end
	if switchSearchCategory then
		self:GetParent():SwitchSearchCategory();
	end
end

function WardrobeItemsCollectionMixin:ResetPage()
	local page = 1;
	local selectedVisualID = NO_TRANSMOG_VISUAL_ID;
	if self.jumpToVisualID then
		selectedVisualID = self.jumpToVisualID;
		self.jumpToVisualID = nil;
	elseif self.jumpToLatestAppearanceID and not C_Transmog.IsAtTransmogNPC() then
		selectedVisualID = self.jumpToLatestAppearanceID;
		self.jumpToLatestAppearanceID = nil;
	end
	if selectedVisualID and selectedVisualID ~= NO_TRANSMOG_VISUAL_ID then
		local visualsList = self:GetFilteredVisualsList();
		for i = 1, #visualsList do
			if visualsList[i].visualID == selectedVisualID then
				page = GetPage(i, self.PAGE_SIZE);
				break;
			end
		end
	end
	self.PagingFrame:SetCurrentPage(page);
	self:UpdateItems();
end

function WardrobeItemsCollectionMixin:FilterVisuals()
	local isAtTransmogrifier = C_Transmog.IsAtTransmogNPC();
	local visualsList = self.visualsList;
	local filteredVisualsList = {};
	for i = 1, #visualsList do
		if isAtTransmogrifier then
			if (visualsList[i].isUsable and visualsList[i].isCollected) or visualsList[i].alwaysShowItem then
				tinsert(filteredVisualsList, visualsList[i]);
			end
		else
			if not visualsList[i].isHideVisual then
				tinsert(filteredVisualsList, visualsList[i]);
			end
		end
	end
	self.filteredVisualsList = filteredVisualsList;
end

local function WardrobeItemsCollection_SortVisuals(source1, source2)
	if source1.isCollected ~= source2.isCollected then
		return source1.isCollected;
	end
	if source1.isUsable ~= source2.isUsable then
		return source1.isUsable;
	end
	if source1.isFavorite ~= source2.isFavorite then
		return source1.isFavorite;
	end
	if source1.isHideVisual ~= source2.isHideVisual then
		return source1.isHideVisual;
	end
	if source1.hasActiveRequiredHoliday ~= source2.hasActiveRequiredHoliday then
		return source1.hasActiveRequiredHoliday;
	end
	if source1.uiOrder and source2.uiOrder then
		return source1.uiOrder > source2.uiOrder;
	end
	return source1.sourceID > source2.sourceID;
end

function WardrobeItemsCollectionMixin:SortVisuals()
	table.sort(self.filteredVisualsList, WardrobeItemsCollection_SortVisuals);
end

function WardrobeItemsCollectionMixin:GetActiveSlotInfo()
	return TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
end

function WardrobeItemsCollectionMixin:UpdateItems()
	local changeModel = false;
	local isAtTransmogrifier = C_Transmog.IsAtTransmogNPC();

	local _, baseVisualID, appliedVisualID, pendingVisualID, hasPendingUndo;
	local effectiveCategory, effectiveSubCategory;
	local showUndoIcon;
	if isAtTransmogrifier then
		if self.transmogLocation:IsMainHand() then
			effectiveCategory, effectiveSubCategory = C_Transmog.GetSlotEffectiveCategory(self.transmogLocation);
		end
		_, baseVisualID, _, appliedVisualID, _, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(self.transmogLocation);
		if appliedVisualID ~= NO_TRANSMOG_VISUAL_ID then
			if hasPendingUndo then
				pendingVisualID = baseVisualID;
				showUndoIcon = true;
			end
			-- current border (yellow) should only show on untransmogrified items
			baseVisualID = nil;
		end
		-- hide current border (yellow) or current-transmogged border (purple) if there's something pending
		if pendingVisualID ~= NO_TRANSMOG_VISUAL_ID then
			baseVisualID = nil;
			appliedVisualID = nil;
		end
	end

	local matchesCategory = not effectiveCategory or (effectiveCategory == self.activeCategory and effectiveSubCategory == self.activeSubCategory);

	local pendingTransmogModelFrame;
	local indexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE;
	for i = 1, self.PAGE_SIZE do
		local model = self.Models[i];
		local index = i + indexOffset;
		local visualInfo = self.filteredVisualsList[index];
		if visualInfo then
			model:Show();

			if visualInfo ~= model.visualInfo or changeModel then
				local sourceID = self:GetAnAppearanceSourceFromVisual(visualInfo.visualID, nil);
				model:SetItemAppearance(sourceID);
			end
			model.visualInfo = visualInfo;

			-- state at the transmogrifier
			local transmogStateAtlas;
			if visualInfo.visualID == appliedVisualID and matchesCategory then
				transmogStateAtlas = "transmog-wardrobe-border-current-transmogged";
			elseif visualInfo.visualID == baseVisualID then
				transmogStateAtlas = "transmog-wardrobe-border-current";
			elseif visualInfo.visualID == pendingVisualID and matchesCategory then
				transmogStateAtlas = "transmog-wardrobe-border-selected";
				pendingTransmogModelFrame = model;
			end
			if transmogStateAtlas then
				model.Overlay.TransmogStateTexture:SetAtlas(transmogStateAtlas, true);
				model.Overlay.TransmogStateTexture:Show();
			else
				model.Overlay.TransmogStateTexture:Hide();
			end

			-- border
			if not visualInfo.isCollected then
				model.Overlay.Border:SetAtlas("transmog-wardrobe-border-uncollected");
			elseif not visualInfo.isUsable then
				model.Overlay.Border:SetAtlas("transmog-wardrobe-border-unusable");
			else
				model.Overlay.Border:SetAtlas("transmog-wardrobe-border-collected");
			end

			if C_TransmogCollection.IsNewAppearance(visualInfo.visualID) then
				model.Overlay.NewString:Show();
				model.Overlay.NewGlow:Show();
			else
				model.Overlay.NewString:Hide();
				model.Overlay.NewGlow:Hide();
			end
			-- favorite
			model.Overlay.FavoriteIcon:SetShown(visualInfo.isCollected and visualInfo.isFavorite);
			-- hide visual option
			model.Overlay.HideVisualIcon:SetShown(isAtTransmogrifier and visualInfo.isHideVisual);

			if GameTooltip:GetOwner() == model then
				model:OnEnter();
			end
		else
			model:Hide();
			model.visualInfo = nil;
		end
	end
	if pendingTransmogModelFrame then
		self.PendingTransmogFrame:SetParent(pendingTransmogModelFrame);
		self.PendingTransmogFrame:SetFrameLevel(pendingTransmogModelFrame:GetFrameLevel() + 2);
		self.PendingTransmogFrame:SetPoint("CENTER");
		self.PendingTransmogFrame:Show();

		if self.PendingTransmogFrame.visualID ~= pendingVisualID then
			self.PendingTransmogFrame.WispInfo = self.PendingTransmogFrame.WispInfo or {
				{name = "Wisp1", offsetX = -70, offsetY = 0},
				{name = "Wisp2", offsetX = 70, offsetY = 0},
				{name = "Wisp3", offsetX = 0, offsetY = 90},
				{name = "Wisp4", offsetX = 0, offsetY = -90},
				{name = "Wisp5", offsetX = -70, offsetY = 0},
				{name = "Wisp6", offsetX = 70, offsetY = 0},
				{name = "Wisp7", offsetX = 0, offsetY = 90},
				{name = "Wisp8", offsetX = 0, offsetY = -90},
				{name = "Wisp9", offsetX = -70, offsetY = 0},
				{name = "Wisp10", offsetX = 70, offsetY = 0},
				{name = "Wisp11", offsetX = 0, offsetY = 90},
				{name = "Wisp12", offsetX = 0, offsetY = -90},
			};

			local scale = UIParent:GetScale();
			for _, wispInfo in ipairs(self.PendingTransmogFrame.WispInfo) do
				self.PendingTransmogFrame[wispInfo.name].Anim.Translation:SetOffset(wispInfo.offsetX * scale, wispInfo.offsetY * scale);
				self.PendingTransmogFrame[wispInfo.name].Anim:Stop();
				self.PendingTransmogFrame[wispInfo.name].Anim:Play();
			end

			self.PendingTransmogFrame.GlowFrame.Anim:Stop();
			self.PendingTransmogFrame.GlowFrame.Anim:Play();
			self.PendingTransmogFrame.Smoke1.Anim:Stop();
			self.PendingTransmogFrame.Smoke1.Anim:Play();
			self.PendingTransmogFrame.Smoke2.Anim:Stop();
			self.PendingTransmogFrame.Smoke2.Anim:Play();
			self.PendingTransmogFrame.Smoke3.Anim:Stop();
			self.PendingTransmogFrame.Smoke3.Anim:Play();
			self.PendingTransmogFrame.Smoke4.Anim:Stop();
			self.PendingTransmogFrame.Smoke4.Anim:Play();
		end
		self.PendingTransmogFrame.UndoIcon:SetShown(showUndoIcon);
		self.PendingTransmogFrame.visualID = pendingVisualID;
	else
		self.PendingTransmogFrame:Hide();
	end

	-- progress bar
	self:UpdateProgressBar();
end

function WardrobeItemsCollectionMixin:UpdateProgressBar()
	local collected = C_TransmogCollection.GetCategoryCollectedCount(self.activeCategory, self.activeSubCategory);
	local total = C_TransmogCollection.GetCategoryTotal(self.activeCategory, self.activeSubCategory);

	self:GetParent():UpdateProgressBar(collected, total);
end

function WardrobeItemsCollectionMixin:RefreshVisualsList()
	local exclusion;
	local activeSlot = self:GetActiveSlot();
	if activeSlot == "MAINHANDSLOT" then
		exclusion = LE_ITEM_FILTER_TYPE_OFF_HAND;
	elseif activeSlot == "SECONDARYHANDSLOT" then
		exclusion = LE_ITEM_FILTER_TYPE_MAIN_HAND;
	end
	self.visualsList = C_TransmogCollection.GetCategoryAppearances(self.activeCategory, self.activeSubCategory, exclusion);

	self:FilterVisuals();
	self:SortVisuals();
	self.PagingFrame:SetMaxPages(ceil(#self.filteredVisualsList / self.PAGE_SIZE));
end

function WardrobeItemsCollectionMixin:GetFilteredVisualsList()
	return self.filteredVisualsList;
end

function WardrobeItemsCollectionMixin:GetAnAppearanceSourceFromVisual(visualID, mustBeUsable)
	local sourceID = self:GetChosenVisualSource(visualID);
	if sourceID == NO_TRANSMOG_VISUAL_ID then
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(visualID, self.activeCategory, self.activeSubCategory);
		for i = 1, #sources do
			-- first 1 if it doesn't have to be usable
			if not mustBeUsable or self:IsAppearanceUsableForActiveCategory(sources[i]) then
				sourceID = sources[i].sourceID;
				break;
			end
		end
	end
	return sourceID;
end

function WardrobeItemsCollectionMixin:SelectVisual(visualID)
	if not C_Transmog.IsAtTransmogNPC() then
		return;
	end

	local sourceID;
	if self.transmogLocation:IsAppearance() then
		sourceID = self:GetAnAppearanceSourceFromVisual(visualID, true);
	else
		local visualsList = self:GetFilteredVisualsList();
		for i = 1, #visualsList do
			if visualsList[i].visualID == visualID then
				sourceID = visualsList[i].sourceID;
				break;
			end
		end
	end
	WardrobeTransmogFrame:SetPendingTransmog(sourceID, self.activeCategory, self.activeSubCategory);
end

function WardrobeCollectionFrame_OpenTransmogLink(link)
	if not CollectionsJournal:IsVisible() or not WardrobeCollectionFrame:IsVisible() then
		ToggleCollectionsJournal(3);
	end

	local linkType, collectionType, id = strsplit(":", link);

	if linkType == "collection" and collectionType == CHAR_COLLECTION_APPEARANCE then
		local sourceID = tonumber(id);
		WardrobeCollectionFrame_SetTab(TAB_ITEMS);
		-- For links a base appearance is fine
		local categoryID, subCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
		local slot = CollectionWardrobeUtil.GetSlotFromCategoryID(categoryID, subCategoryID);
		if slot then
			local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.None);
			WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(sourceID, transmogLocation);
		end
	end
end

-- TODO
function WardrobeItemsCollectionMixin:GoToSourceID(sourceID, transmogLocation, forceGo, forTransmog, overrideCategoryID, overrideSubCategoryID)
	local categoryID, subCategoryID, visualID;
	if transmogLocation:IsAppearance() then
		categoryID, subCategoryID, visualID = C_TransmogCollection.GetAppearanceSourceInfo(sourceID);
	end
	if overrideCategoryID then
		categoryID = overrideCategoryID;
	end
	if overrideSubCategoryID then
		subCategoryID = overrideSubCategoryID;
	end
	if visualID or forceGo then
		self.jumpToVisualID = visualID;
		if (self.activeCategory ~= categoryID or self.activeSubCategory ~= subCategoryID) or not self.transmogLocation:IsEqual(transmogLocation) then
			self:SetActiveSlot(transmogLocation, categoryID, subCategoryID);
		else
			if not self.filteredVisualsList then
				self:RefreshVisualsList();
			end
			self:ResetPage();
		end
	end
end

function WardrobeItemsCollectionMixin:SetAppearanceTooltip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	self.tooltipVisualID = frame.visualInfo.visualID;
	self:RefreshAppearanceTooltip();

	if WardrobeCollectionFrame.tooltipCycle then
		SetOverrideBindingClick(frame, true, "TAB", frame:GetName(), "TAB");
		SetOverrideBindingClick(frame, true, "SHIFT-TAB", frame:GetName(), "SHIFT-TAB");
	end
end

function WardrobeItemsCollectionMixin:RefreshAppearanceTooltip(sources)
	if not self.tooltipVisualID then
		return;
	end
	sources = sources or CollectionWardrobeUtil.GetSortedAppearanceSources(self.tooltipVisualID, self.activeCategory, self.activeSubCategory);
	local chosenSourceID = self:GetChosenVisualSource(self.tooltipVisualID);
	self:GetParent():SetAppearanceTooltip(self, sources, chosenSourceID);
end

function WardrobeItemsCollectionMixin:ClearAppearanceTooltip(frame)
	self.tooltipVisualID = nil;
	self:GetParent():HideAppearanceTooltip();
	ClearOverrideBindings(frame);
end

function WardrobeItemsCollectionMixin:OnPageChanged(userAction)
	if userAction then
		self:UpdateItems();
	end
end

function WardrobeItemsCollectionMixin:OnSearchUpdate(category, subCategory)
	if category ~= self.activeCategory or subCategory ~= self.activeSubCategory then
		return;
	end

	self:RefreshVisualsList();
	if C_Transmog.IsAtTransmogNPC() and WardrobeCollectionFrameSearchBox:GetText() == "" then
		local _, _, selectedSourceID = TransmogUtil.GetInfoForEquippedSlot(self.transmogLocation);
		local categoryID, subCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
		local activeCategory, activeSubCategory = self:GetActiveCategory();
		if categoryID == activeCategory and subCategoryID == activeSubCategory then
			WardrobeCollectionFrame.ItemsCollectionFrame:GoToSourceID(selectedSourceID, self.transmogLocation, true);
		else
			self:UpdateItems();
		end
	else
		self:UpdateItems();
	end
end

function WardrobeItemsCollectionMixin:IsAppearanceUsableForActiveCategory(appearanceInfo)
	return CollectionWardrobeUtil.IsAppearanceUsable(appearanceInfo);
end

function WardrobeItemsCollectionMixin:GetChosenVisualSource(visualID)
	return self.chosenVisualSources[visualID] or 0;
end

function WardrobeItemsCollectionMixin:SetChosenVisualSource(visualID, sourceID)
	self.chosenVisualSources[visualID] = sourceID;
end

function WardrobeItemsCollectionMixin:ValidateChosenVisualSources()
	for visualID, sourceID in pairs(self.chosenVisualSources) do
		if sourceID ~= NO_TRANSMOG_VISUAL_ID then
			local keep = false;
			local sources = C_TransmogCollection.GetAppearanceSources(visualID, self.activeCategory, self.activeSubCategory);
			if sources then
				for i = 1, #sources do
					if sources[i].sourceID == sourceID then
						if sources[i].isCollected and not sources[i].useError then
							keep = true;
						end
						break;
					end
				end
			end
			if not keep then
				self.chosenVisualSources[visualID] = NO_TRANSMOG_VISUAL_ID;
			end
		end
	end
end

-- Models
local SetSequence; -- Cache widget api
local lightValues = {enabled = 1, omni = 0, dirX = -1, dirY = 1, dirZ = -1, ambIntensity = 1.05, ambR = 1, ambG = 1, ambB = 1, dirIntensity = 0, dirR = 1, dirG = 1, dirB = 1};

WardrobeItemsModelMixin = {};

function WardrobeItemsModelMixin:OnLoad()
	if not SetSequence then
		SetSequence = self.SetSequence
	end

	self:SetLight(lightValues.enabled, lightValues.omni,
			lightValues.dirX, lightValues.dirY, lightValues.dirZ,
			lightValues.ambIntensity, lightValues.ambR, lightValues.ambG, lightValues.ambB,
			lightValues.dirIntensity, lightValues.dirR, lightValues.dirG, lightValues.dirB);

	self.Overlay.Border:SetAtlas("transmog-wardrobe-border-collected", true);
	self.Overlay.Highlight:SetAtlas("transmog-wardrobe-border-highlighted", true);

	self.Overlay.NewGlow:SetAtlas("collections-newglow");
	self.Overlay.FavoriteIcon:SetAtlas("collections-icon-favorites", true);
	self.Overlay.HideVisualIcon:SetAtlas("transmog-icon-hidden", true);

	local parent = self:GetParent();
	if not parent.Models then
		parent.Models = {};
	end

	parent.Models[#parent.Models + 1] = self;
end

function WardrobeItemsModelMixin:OnMouseDown(button)
	local itemsCollectionFrame = self:GetParent();
	if IsModifiedClick("CHATLINK") then
		local link;
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(self.visualInfo.visualID, itemsCollectionFrame:GetActiveCategory());
		if WardrobeCollectionFrame.tooltipSourceIndex then
			local index = CollectionWardrobeUtil.GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex, #sources);
			link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID));
		end
		if link then
			HandleModifiedItemClick(link);
		end
		return;
	elseif IsModifiedClick("DRESSUP") then
		local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(self.visualInfo.visualID, itemsCollectionFrame:GetActiveCategory());
		local index = CollectionWardrobeUtil.GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex or 1, #sources);
		local sourceUD = sources[index].sourceID;

		if sourceUD then
			DressUpItemLink(sourceUD);
		end
		return;
	end

	if button == "LeftButton" then
		CloseDropDownMenus();
		self:GetParent():SelectVisual(self.visualInfo.visualID);
	elseif button == "RightButton" then
		local dropDown = self:GetParent().RightClickDropDown;
		if dropDown.activeFrame ~= self then
			CloseDropDownMenus();
		end
		if not self.visualInfo.isCollected or self.visualInfo.isHideVisual or itemsCollectionFrame.transmogLocation:IsIllusion() then
			return;
		end
		dropDown.activeFrame = self;
		ToggleDropDownMenu(1, nil, dropDown, self, -6, -3);
	elseif button == "TAB" or button == "SHIFT-TAB" then
		if WardrobeCollectionFrame.tooltipCycle then
			if button == "SHIFT-TAB" then
				WardrobeCollectionFrame.tooltipSourceIndex = WardrobeCollectionFrame.tooltipSourceIndex - 1;
			else
				WardrobeCollectionFrame.tooltipSourceIndex = WardrobeCollectionFrame.tooltipSourceIndex + 1;
			end
			local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(self.visualInfo.visualID, itemsCollectionFrame:GetActiveCategory());
			self:GetParent():RefreshAppearanceTooltip(sources);

			local index = CollectionWardrobeUtil.GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex or 1, #sources);
			local sourceUD = sources[index].sourceID;

			if sourceUD then
				self:SetItemAppearance(sourceUD);
			end
		end
	end
end

function WardrobeItemsModelMixin:OnEnter()
	self.Overlay.Highlight:Show();

	if not self.visualInfo then
		return;
	end
	self:SetScript("OnUpdate", self.OnUpdate);
	local itemsCollectionFrame = self:GetParent();
	if C_TransmogCollection.IsNewAppearance(self.visualInfo.visualID) then
		C_TransmogCollection.ClearNewAppearance(self.visualInfo.visualID);
		if itemsCollectionFrame.jumpToLatestAppearanceID == self.visualInfo.visualID then
			itemsCollectionFrame.jumpToLatestAppearanceID = nil;
			itemsCollectionFrame.jumpToLatestCategoryID  = nil;
		end
		self.Overlay.NewString:Hide();
		self.Overlay.NewGlow:Hide();
	end
	itemsCollectionFrame:SetAppearanceTooltip(self);
end

function WardrobeItemsModelMixin:OnLeave()
	self.Overlay.Highlight:Hide();

	self:SetScript("OnUpdate", nil);
	ResetCursor();
	self:GetParent():ClearAppearanceTooltip(self);
end

function WardrobeItemsModelMixin:OnUpdateModel()
	SetSequence(self, self.animId or 3);

	if self.queuedSourceID then
		local itemName = GetItemInfo(self.queuedSourceID);
		if itemName then
			self:SetItemAppearance(self.queuedSourceID);
			self.queuedSourceID = nil;
		end
	end
end

function WardrobeItemsModelMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function WardrobeItemsModelMixin:SetItemAppearance(sourceID)
	if type(sourceID) ~= "number" then
		return;
	end

	local activeSlot = self:GetParent():GetActiveSlot();
	local isWeapon = activeSlot == "MAINHANDSLOT" or activeSlot == "SECONDARYHANDSLOT" or activeSlot == "RANGEDSLOT";
	if isWeapon then
		DummyWardrobeUnitModel:Dress();
		self:Undress();
	end

	local cameraID = C_TransmogCollection.GetAppearanceCameraIDBySource(sourceID);
	if self.cameraID ~= cameraID then
		Model_ApplyUICamera(self, cameraID);
		self.cameraID = cameraID;
	end

	local name = GetItemInfo(sourceID);
	if not name then
		if not isWeapon then
			self:EquipTransmogGear(activeSlot);
		end

		C_Item.cacheTooltip:SetHyperlink(string.format("item:%d", sourceID));
		self.OverlayBackground:Show();
		self.LoadingFrame:Show();
		self.queuedSourceID = sourceID;
		return;
	end

	self.OverlayBackground:Hide();
	self.LoadingFrame:Hide();
	self.queuedSourceID = nil;
	self:TryOn(sourceID);
end

function WardrobeItemsModelMixin:EquipTransmogGear(activeSlot)
	if activeSlot and WARDROBE_MODEL_SETUP[activeSlot] then
		self:Undress();

		for slot, equip in pairs(WARDROBE_MODEL_SETUP[activeSlot]) do
			if equip then
				self:TryOn(WARDROBE_MODEL_SETUP_GEAR[slot]);
			end
		end
	end
end

function WardrobeItemsModelMixin:Reload(reloadSlot, refreshModel)
	if self:IsShown() then
		if refreshModel then
			self:SetPosition(0, 0, 0);
			self:ClearModel();

			if reloadSlot == "MAINHANDSLOT" or reloadSlot == "SECONDARYHANDSLOT" or reloadSlot == "RANGEDSLOT" then
				self:SetCreature(413);
			else
				self:SetUnit("player");
			end

--			self:SetPosition(0, 0, 0);
--			self:RefreshUnit();
		end

		self:EquipTransmogGear(reloadSlot);

		self.cameraID = nil;
		self.needsReload = nil;
	else
		self.needsReload = true;
	end
end

function WardrobeItemsModelMixin:OnShow()
	if self.needsReload then
		self:Reload(self:GetParent():GetActiveSlot(), true);
	end
end

function WardrobeItemsModelMixin:OnHide()
	self.needsReload = true;
end

-- Sub Category DropDown
function WardrobeCollectionFrameSubCategoryDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeCollectionFrameSubCategoryDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function WardrobeCollectionFrameSubCategoryDropDown_Init(self)
	local transmogLocation = WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation;
	if not transmogLocation then
		return;
	end
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.func = WardrobeCollectionFrameWeaponDropDown_OnClick;
	local equippedItemID = GetInventoryItemID("player", transmogLocation:GetSlotID());
	local checkCategory = equippedItemID and C_Transmog.IsAtTransmogNPC();
	if checkCategory then
		-- if the equipped item cannot be transmogrified, relax restrictions
		local _, _, _, canTransmogrify, _, hasUndo = C_Transmog.GetSlotInfo(transmogLocation);
		if not canTransmogrify and not hasUndo then
			checkCategory = false;
		end
	end
	local buttonsAdded = 0;

	local armorCategoryID = transmogLocation:GetArmorCategoryID();
	if armorCategoryID then
		for subCategoryID = FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY, LAST_TRANSMOG_COLLECTION_SUB_CATEGORY do
			local name = C_TransmogCollection.GetSubCategoryInfo(armorCategoryID, subCategoryID);
			if name then
				if not checkCategory or C_TransmogCollection.IsCategoryValidForItem(armorCategoryID, subCategoryID, equippedItemID) then
					info.text = name;
					info.arg1 = armorCategoryID;
					info.arg2 = subCategoryID;
					info.value = subCategoryID;
					if info.value == selectedValue then
						info.checked = 1;
					else
						info.checked = nil;
					end
					UIDropDownMenu_AddButton(info);
					buttonsAdded = buttonsAdded + 1;
				end
			end
		end
	else
		local isForMainHand = transmogLocation:IsMainHand();
		local isForOffHand = transmogLocation:IsOffHand();
		local isForRanged = transmogLocation:IsRanged();
		for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
			local name, isWeapon, _, canMainHand, canOffHand, canRanged = C_TransmogCollection.GetCategoryInfo(categoryID);
			if name and isWeapon then
				if (isForMainHand and canMainHand) or (isForOffHand and canOffHand) or (isForRanged and canRanged) then
					if not checkCategory or C_TransmogCollection.IsCategoryValidForItem(categoryID, nil, equippedItemID) then
						info.text = name;
						info.arg1 = categoryID;
						info.value = categoryID;
						if info.value == selectedValue then
							info.checked = 1;
						else
							info.checked = nil;
						end
						UIDropDownMenu_AddButton(info);
						buttonsAdded = buttonsAdded + 1;
					end
				end
			end
		end
	end

	return buttonsAdded;
end

function WardrobeCollectionFrameSubCategoryDropDown_OnClick(self, category, subCategoryID)
	local activeCategory, activeSubCategory = WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory();
	if category and category ~= activeCategory or subCategoryID ~= activeSubCategory then
		CloseDropDownMenus();
		WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveCategory(category, subCategoryID);
	end
end

function WardrobeCollectionFrameRightClickDropDown_Init(self)
	local appearanceID = self.activeFrame.visualInfo.visualID;
	local info = UIDropDownMenu_CreateInfo();
	-- Set Favorite
	if C_TransmogCollection.GetIsAppearanceFavorite(appearanceID) then
		info.text = BATTLE_PET_UNFAVORITE;
		info.arg1 = appearanceID;
		info.arg2 = 0;
	else
		info.text = BATTLE_PET_FAVORITE;
		info.arg1 = appearanceID;
		info.arg2 = 1;
	end
	info.notCheckable = true;
	info.func = function(_, visualID, value) WardrobeCollectionFrameModelDropDown_SetFavorite(visualID, value); end;
	UIDropDownMenu_AddButton(info);
	-- Cancel
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = CANCEL;
	UIDropDownMenu_AddButton(info);

	local headerInserted = false;
	local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(appearanceID, WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory());
	local chosenSourceID = WardrobeCollectionFrame.ItemsCollectionFrame:GetChosenVisualSource(appearanceID);
	info.func = WardrobeCollectionFrameModelDropDown_SetSource;
	for i = 1, #sources do
		if sources[i].isCollected and WardrobeCollectionFrame.ItemsCollectionFrame:IsAppearanceUsableForActiveCategory(sources[i]) then
			if not headerInserted then
				headerInserted = true;
				-- space
				info.text = " ";
				info.disabled = true;
				UIDropDownMenu_AddButton(info);
				info.disabled = nil;
				-- header
				info.text = WARDROBE_TRANSMOGRIFY_AS;
				info.isTitle = true;
				info.colorCode = NORMAL_FONT_COLOR_CODE;
				UIDropDownMenu_AddButton(info);
				info.isTitle = nil;
				-- turn off notCheckable
				info.notCheckable = nil;
			end
			local name, nameColor = WardrobeCollectionFrame:GetAppearanceNameTextAndColor(sources[i]);
			info.text = name;
			info.colorCode = nameColor:GenerateHexColorMarkup();
			info.disabled = nil;
			info.arg1 = appearanceID;
			info.arg2 = sources[i].sourceID;
			-- choose the 1st valid source if one isn't explicitly chosen
			if chosenSourceID == NO_TRANSMOG_VISUAL_ID then
				chosenSourceID = sources[i].sourceID;
			end
			info.checked = (chosenSourceID == sources[i].sourceID);
			UIDropDownMenu_AddButton(info);
		end
	end
end

function WardrobeCollectionFrameModelDropDown_SetSource(self, visualID, sourceID)
	WardrobeCollectionFrame.ItemsCollectionFrame:SetChosenVisualSource(visualID, sourceID);
	WardrobeCollectionFrame.ItemsCollectionFrame:SelectVisual(visualID);
end

function WardrobeCollectionFrameModelDropDown_SetFavorite(visualID, value, confirmed)
	local set = (value == 1);
	--[[
	if set and not confirmed then
		local allSourcesConditional = true;
		local sources = C_TransmogCollection.GetAppearanceSources(visualID, WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory());
		for i, sourceInfo in ipairs(sources) do
			local info = C_TransmogCollection.GetAppearanceInfoBySource(sourceInfo.sourceID);
			if info.sourceIsCollectedPermanent then
				allSourcesConditional = false;
				break;
			end
		end
		if allSourcesConditional then
			StaticPopup_Show("TRANSMOG_FAVORITE_WARNING", nil, nil, visualID);
			return;
		end
	end
	]]
	C_TransmogCollection.SetIsAppearanceFavorite(visualID, set);
end

-- Weapon DropDown
function WardrobeCollectionFrameWeaponDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeCollectionFrameWeaponDropDown_Init);
	UIDropDownMenu_SetWidth(self, 140);
end

function WardrobeCollectionFrameWeaponDropDown_Init(self)
	local transmogLocation = WardrobeCollectionFrame.ItemsCollectionFrame.transmogLocation;
	if not transmogLocation then
		return;
	end
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	info.func = WardrobeCollectionFrameWeaponDropDown_OnClick;
	local equippedItemID = GetInventoryItemID("player", transmogLocation:GetSlotID());
	local checkCategory = equippedItemID and C_Transmog.IsAtTransmogNPC();
	if checkCategory then
		-- if the equipped item cannot be transmogrified, relax restrictions
		local _, _, _, canTransmogrify, _, hasUndo = C_Transmog.GetSlotInfo(transmogLocation);
		if not canTransmogrify and not hasUndo then
			checkCategory = false;
		end
	end
	local buttonsAdded = 0;
	local armorCategoryID = transmogLocation:GetArmorCategoryID();
	if armorCategoryID then
		for subCategoryID = FIRST_TRANSMOG_COLLECTION_SUB_CATEGORY, LAST_TRANSMOG_COLLECTION_SUB_CATEGORY do
			local name = C_TransmogCollection.GetSubCategoryInfo(armorCategoryID, subCategoryID);
			if name then
				if not checkCategory or C_TransmogCollection.IsCategoryValidForItem(armorCategoryID, subCategoryID, equippedItemID) then
					info.text = name;
					info.arg1 = armorCategoryID;
					info.arg2 = subCategoryID;
					info.value = subCategoryID;
					if info.value == selectedValue then
						info.checked = 1;
					else
						info.checked = nil;
					end
					UIDropDownMenu_AddButton(info);
					buttonsAdded = buttonsAdded + 1;
				end
			end
		end
	else
		local isForMainHand = transmogLocation:IsMainHand();
		local isForOffHand = transmogLocation:IsOffHand();
		local isForRanged = transmogLocation:IsRanged();
		for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
			local name, isWeapon, _, canMainHand, canOffHand, canRanged = C_TransmogCollection.GetCategoryInfo(categoryID);
			if name and isWeapon then
				if (isForMainHand and canMainHand) or (isForOffHand and canOffHand) or (isForRanged and canRanged) then
					if not checkCategory or C_TransmogCollection.IsCategoryValidForItem(categoryID, nil, equippedItemID) then
						info.text = name;
						info.arg1 = categoryID;
						info.value = categoryID;
						if info.value == selectedValue then
							info.checked = 1;
						else
							info.checked = nil;
						end
						UIDropDownMenu_AddButton(info);
						buttonsAdded = buttonsAdded + 1;
					end
				end
			end
		end
	end
	return buttonsAdded;
end

function WardrobeCollectionFrameWeaponDropDown_OnClick(self, category, subCategoryID)
	local activeCategory, activeSubCategory = WardrobeCollectionFrame.ItemsCollectionFrame:GetActiveCategory();
	if category and category ~= activeCategory or subCategoryID ~= activeSubCategory then
		CloseDropDownMenus();
		WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveCategory(category, subCategoryID);
	end
end

-- Searching
WardrobeCollectionFrameSearchBoxMixin = {};

function WardrobeCollectionFrameSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);
end

function WardrobeCollectionFrameSearchBoxMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);
	WardrobeCollectionFrame:SetSearch(self:GetText());
end

function WardrobeCollectionFrameSearchBoxMixin:OnEnter()
	if not self:IsMouseEnabled() then
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 0);
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:SetText(WARDROBE_NO_SEARCH);
	end
end

-- Filter
function WardrobeFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WardrobeFilterDropDown_Initialize, "MENU");
end

function WardrobeFilterDropDown_Initialize(self, level)
	if not WardrobeCollectionFrame.activeFrame then
		return;
	end

	if WardrobeCollectionFrame:GetSearchType() == Enum.TransmogSearchType.Items then
		WardrobeFilterDropDown_InitializeItems(self, level);
	end
end

function WardrobeFilterDropDown_InitializeItems(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;
	local atTransmogrifier = C_Transmog.IsAtTransmogNPC();

	if level == 1 and not atTransmogrifier then
		info.text = COLLECTED
		info.func = function(_, _, _, value)
			C_TransmogCollection.SetCollectedShown(value);
		end
		info.checked = C_TransmogCollection.GetCollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		info.text = NOT_COLLECTED
		info.func = function(_, _, _, value)
			C_TransmogCollection.SetUncollectedShown(value);
		end
		info.checked = C_TransmogCollection.GetUncollectedShown();
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level)
		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;
		info.text = SOURCES
		info.value = 1;
		UIDropDownMenu_AddButton(info, level)
	else
		if level == 2 or atTransmogrifier then
			local refreshLevel = atTransmogrifier and 1 or 2;
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;
			info.text = CHECK_ALL
			info.func = function()
				C_TransmogCollection.SetAllSourceTypeFilters(true);
				UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
			end
			UIDropDownMenu_AddButton(info, level)
			info.text = UNCHECK_ALL
			info.func = function()
				C_TransmogCollection.SetAllSourceTypeFilters(false);
				UIDropDownMenu_Refresh(WardrobeFilterDropDown, 1, refreshLevel);
			end
			UIDropDownMenu_AddButton(info, level)
			info.notCheckable = false;
			local numSources = C_TransmogCollection.GetNumTransmogSources();
			for i = 1, numSources do
				info.text = _G["TRANSMOG_SOURCE_"..i];
				info.func = function(_, _, _, value)
					C_TransmogCollection.SetSourceTypeFilter(i, value);
				end
				info.checked = function() return not C_TransmogCollection.IsSourceTypeFilterChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		end
	end
end