do
	local tonumber = tonumber
	local unpack = unpack
	local bitband = bit.band
	local strsub = string.sub

	local LJ_BUFFER = {}

	local NO_CLASS_FILTER = 0
	local NO_SPEC_FILTER = 0

	local LJ_ITEMSET_REALM_FLAG = {
		[E_REALM_ID.SOULSEEKER]	= 0x1,
		[E_REALM_ID.SIRUS]		= 0x2,
		[E_REALM_ID.SCOURGE]	= 0x4,
		[E_REALM_ID.ALGALON]	= 0x8,
	}

	local function getPlayerFactionID()
		local factionGroup = UnitFactionGroup("player") or "NEUTRAL"
		if factionGroup == "Renegade" then
			return (C_FactionManager.GetFactionInfoOriginal())
		end
		return PLAYER_FACTION_GROUP[factionGroup]
	end

	local function filterByFaction(factionID, playerFactionID)
		if factionID == PLAYER_FACTION_GROUP.Neutral then
			return true
		elseif factionID == playerFactionID then
			return true
		end
		return false
	end

	local function filterByClassAndSpecFilters(classID, specID, classFilter, specFilter)
		if classFilter and specFilter then
			if specFilter == 3 then
				specFilter = 4
			end

			if classFilter == NO_CLASS_FILTER and specFilter == NO_SPEC_FILTER then
				return true
			elseif classFilter == classID and specFilter == NO_SPEC_FILTER then
				return true
			elseif classFilter == classID and bitband(specFilter, specID) == specFilter then
				return true
			end
		end

		return false
	end

	local function sortItemSets(a, b)
		if a[4] == b[4] then
			if a[6] ~= b[6] then
				return a[6]
			end
			return (tonumber(strsub(a[3], 3, -1) or 0)) > (tonumber(strsub(b[3], 3, -1) or 0))
		end
		return a[4] > b[4]
	end

	C_LootJournal = {}

	function C_LootJournal.GenerateLootData(classFilter, specFilter)
		table.wipe(LJ_BUFFER)

		local serverID = C_Service.GetRealmID()
		local playerFactionID = getPlayerFactionID()
		local itemSetSourceRealm = EJ_ITEMSET_SOURCE_REALM[serverID]

		for setIndex, itemSetData in pairs(EJ_ITEMSET_DATA) do
			local name, itemlevel, tierName, sourceID, classID, specID, isPVP, itemList, factionID, realmFlag = unpack(itemSetData, 1, 10)
			if not factionID then
				factionID = 0
			end

			if (realmFlag == 0 or (LJ_ITEMSET_REALM_FLAG[serverID] and bitband(realmFlag, LJ_ITEMSET_REALM_FLAG[serverID])) ~= 0)
			and filterByClassAndSpecFilters(classID, specID, classFilter or 0, specFilter or 0)
			and filterByFaction(factionID, playerFactionID)
			then
				if itemSetSourceRealm and itemSetSourceRealm[setIndex] then
					sourceID = itemSetSourceRealm[setIndex]
				end
				local sourceText = EJ_ITEMSET_SOURCE[sourceID] or ""

				local numItems = type(itemList) == "table" and #itemList or 0
				local items = {}

				for i = 1, numItems do
					local itemID = itemList[i]
					items[i] = {
						itemID = itemID,
						icon = GetItemIcon(itemID) or [[Interface\Icons\INV_Misc_QuestionMark]],
					}
				end

				LJ_BUFFER[#LJ_BUFFER + 1] = {setIndex, name, tierName or "", itemlevel, sourceText, isPVP == 1, items, numItems}
			end
		end

		table.sort(LJ_BUFFER, sortItemSets)

		return LJ_BUFFER
	end

	function C_LootJournal.GetNumItemSets()
		return #LJ_BUFFER
	end

	function C_LootJournal.GetItemSetInfo(index)
		if index and LJ_BUFFER[index] then
			return unpack(LJ_BUFFER[index])
		end
	end
end

local NO_SPEC_FILTER = 0;
local NO_CLASS_FILTER = 0;
local NO_INV_TYPE_FILTER = 0;

--===================================================================================================================================
LootJournalItemsMixin = { };

function LootJournalItemsMixin:OnLoad()
	self.Background:SetAtlas("loottab-background", true)
	self:SetView(LOOT_JOURNAL_ITEM_SETS);
	local _, _, classID = UnitClass("player");
	local specIndex = GetSpecializationIndex()
	local _, _, _, _, _, _, specNum = GetSpecializationInfoForClassID(classID, specIndex)
	self:SetClassAndSpecFilters(classID, specNum);
end

function LootJournalItemsMixin:SetClassAndSpecFilters(classID, specID)
	self.classFilter = classID;
	self.specFilter = specID;
end

function LootJournalItemsMixin:GetClassAndSpecFilters()
	return self.classFilter or NO_CLASS_FILTER, self.specFilter or NO_SPEC_FILTER;
end

function LootJournalItemsMixin:SetView(view)
	if ( self.view == view ) then
		return;
	end

	self.view = view;
	self.ItemSetsFrame:Show();
end

function LootJournalItemsMixin:GetActiveList()
	return self.ItemSetsFrame;
end

function LootJournalItemsMixin:Refresh()
	self:GetActiveList():Refresh();
end

function LootJournalItemButtonTemplate_OnEnter(self)
	local listFrame = self:GetParent();
	while ( listFrame and not listFrame.ShowItemTooltip ) do
		listFrame = listFrame:GetParent();
	end
	if ( listFrame ) then
		listFrame:ShowItemTooltip(self);
		self:SetScript("OnUpdate", LootJournalItemButton_OnUpdate);
		self.UpdateTooltip = LootJournalItemButtonTemplate_OnEnter;
	end
end

function LootJournalItemButtonTemplate_OnLeave(self)
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
	self:SetScript("OnUpdate", nil);
	ResetCursor();
end

function LootJournalItemButton_OnClick(self, button)
	if HandleModifiedItemClick(self.itemLink) then
		return
	end

	LootJournal_OpenItemByEntry(self.itemID)
end

--===================================================================================================================================
LootJournalItemSetsMixin = {}

local LJ_ITEMSET_X_OFFSET = 10;
local LJ_ITEMSET_Y_OFFSET = 10;
local LJ_ITEMSET_BUTTON_SPACING = 13;
local LJ_ITEMSET_BOTTOM_BUFFER = 4;

function LootJournalItemSetsMixin:Refresh()
	self.dirty = true;
	local offset = self.scrollBar:GetValue();
	if ( offset == 0 ) then
		self:UpdateList();
	else
		self.scrollBar:SetValue(0);
	end
	if ( self.ClassButton ) then
		self:UpdateClassButtonText();
	end
end

function LootJournalItemSetsMixin:GetClassAndSpecFilters()
	return self:GetParent():GetClassAndSpecFilters();
end

function LootJournalItemSetsMixin:UpdateClassButtonText()
end

function LootJournalItemSetsMixin:ShowItemTooltip(button)
	-- itemLink may not be available
	if not button.itemLink then
		GameTooltip:Hide()
		return
	end

	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(button.itemLink);

	if LootJournal_CanOpenItemByEntry(button.itemID) then
		GameTooltip:AddLine(LOOTJOURNAL_ITEM_CLICK_TO_OPEN_LOOT, 0, 0.8, 1)
	end

	self.tooltipItemID = button.itemID;
	GameTooltip:Show();
end

function LootJournalItemSetsMixin:CheckItemButtonTooltip(button)
	if ( GameTooltip:GetOwner() == button and self.tooltipItemID ~= button.itemID ) then
		self:ShowItemTooltip(button);
	end
end

function LootJournalItemSetsMixin:GetClassFilter()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	return classFilter;
end

function LootJournalItemSetsMixin:GetSpecFilter()
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	return specFilter;
end

function LootJournalItemSetsMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	local classFilter, specFilter = self:GetClassAndSpecFilters();
	if not self.classAndSpecFiltersSet or classFilter ~= newClassFilter or specFilter ~= newSpecFilter then
--[[
		-- if choosing just a class without a spec, pick a spec
		if newClassFilter ~= NO_CLASS_FILTER and newSpecFilter == NO_SPEC_FILTER then
			local _, _, classID = UnitClass("player");
			-- if player's class, choose active spec
			-- otherwise use 1st spec
			if classID == newClassFilter then
				local specIndex = GetSpecializationIndex()
				local _, _, _, _, _, _, specNum = GetSpecializationInfoForClassID(classID, specIndex)
				newSpecFilter = specNum
			else
				newSpecFilter = 1
			end
		end
--]]
		self:GetParent():SetClassAndSpecFilters(newClassFilter, newSpecFilter);
		self.scrollBar:SetValue(0);
		self:Refresh();
	end

	CloseDropDownMenus(1);
	self.classAndSpecFiltersSet = true;
end

do
	function LootJournalItemButton_OnUpdate(self)
		if GameTooltip:IsOwned(self) then
			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end
	end

	local function OpenClassFilterDropDown(self, level)
		if level then
			self:GetParent():GetActiveList():OpenClassFilterDropDown(level);
		end
	end

	function LootJournalItemsClassDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenClassFilterDropDown, "MENU");
	end

	local CLASS_DROPDOWN = 1;

	function LootJournalItemSetsMixin:OpenClassFilterDropDown(level)
		local filterClassID = self:GetClassFilter();
		local filterSpecID = self:GetSpecFilter();
		local classDisplayName, classTag, classID;

		local function SetClassAndSpecFilters(_, classFilter, specFilter)
			self:SetClassAndSpecFilters(classFilter, specFilter);
		end

		local info = UIDropDownMenu_CreateInfo();

		if UIDROPDOWNMENU_MENU_VALUE == CLASS_DROPDOWN then
			info.text = ALL_CLASSES;
			info.checked = filterClassID == NO_CLASS_FILTER;
			info.arg1 = NO_CLASS_FILTER;
			info.arg2 = NO_SPEC_FILTER;
			info.func = SetClassAndSpecFilters;
			UIDropDownMenu_AddButton(info, level);

			local numClasses = GetNumClasses();
			for i = 1, numClasses do
				classDisplayName, classTag, classID = GetClassInfo(i);
				if classID ~= 10 then
					info.text = classDisplayName;
					info.checked = filterClassID == classID;
					info.arg1 = classID;
					info.arg2 = NO_SPEC_FILTER;
					info.func = SetClassAndSpecFilters;
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end

		if level == 1 then
			info.text = CLASS;
			info.func =  nil;
			info.notCheckable = true;
			info.hasArrow = true;
			info.value = CLASS_DROPDOWN;
			UIDropDownMenu_AddButton(info, level);

			local classDisplayName, classTag, classID;
			if filterClassID ~= NO_CLASS_FILTER then
				classID = filterClassID;
				classDisplayName = GetClassInfo(classID)
			else
				classDisplayName, classTag, classID = UnitClass("player");
			end

			info.text = classDisplayName;
			info.notCheckable = true;
			info.arg1 = nil;
			info.arg2 = nil;
			info.func =  nil;
			info.hasArrow = false;
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = nil;
			for i = 1, GetNumSpecializationsForClassID(classID) do
				local _, specName, _, _, _, _, specNum = GetSpecializationInfoForClassID(classID, i)
				info.leftPadding = 10;
				info.text = specName;
				info.checked = filterSpecID == specNum;
				info.arg1 = classID;
				info.arg2 = specNum;
				info.func = SetClassAndSpecFilters;
				UIDropDownMenu_AddButton(info, level);
			end

			info.text = ALL_SPECS;
			info.leftPadding = 10;
			info.checked = (classID == filterClassID and filterSpecID == NO_SPEC_FILTER) or (filterClassID == NO_CLASS_FILTER and filterSpecID == NO_SPEC_FILTER);
			info.arg1 = classID;
			info.arg2 = NO_SPEC_FILTER;
			info.func = SetClassAndSpecFilters;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

function LootJournalItemSetsMixin:OnLoad()
	self.scrollBar.trackBG:Hide();
	self.update = LootJournalItemSetsMixin.UpdateList;
	HybridScrollFrame_CreateButtons(self, "LootJournalItemSetButtonTemplate", LJ_ITEMSET_X_OFFSET, -LJ_ITEMSET_Y_OFFSET, "TOPLEFT", nil, nil, -LJ_ITEMSET_BUTTON_SPACING);
end

function LootJournalItemSetsMixin:OnShow()
	if not self.init then
		self.init = true;
		self:Refresh();
	end
end

local function onItemLoaded(itemID)
	local self = EncounterJournal.LootJournalItems.ItemSetsFrame
	for i = 1, #self.buttons do
		local itemButtons = self.buttons[i].ItemButtons;
		for j = 1, #itemButtons do
			if ( itemButtons[j].itemID == itemID ) then
				self:ConfigureItemButton(itemButtons[j]);
				return;
			end
		end
	end
end

function LootJournalItemSetsMixin:ConfigureItemButton(button)
	local _, itemLink, itemQuality, _, _, _, _, _, _, icon = C_Item.GetItemInfo(button.itemID, false, onItemLoaded, true);
	button.itemLink = itemLink;
	itemQuality = itemQuality or Enum.ItemQuality.Epic;	-- sets are most likely rare
	if ( itemQuality == Enum.ItemQuality.Uncommon ) then
		button.Border:SetAtlas("loottab-set-itemborder-green", true);
	elseif ( itemQuality == Enum.ItemQuality.Rare ) then
		button.Border:SetAtlas("loottab-set-itemborder-blue", true);
	elseif ( itemQuality == Enum.ItemQuality.Epic ) then
		button.Border:SetAtlas("loottab-set-itemborder-purple", true);
	end

	button.Icon:SetTexture(icon or "Interface\\ICONS\\temp")

	button:GetParent().SetName:SetTextColor(GetItemQualityColor(itemQuality));
	self:CheckItemButtonTooltip(button);
end

function LootJournalItemSetsMixin:UpdateList()
	if ( self.dirty ) then
		C_LootJournal.GenerateLootData(self:GetClassAndSpecFilters())
		self.dirty = nil;
	end

	local buttons = self.buttons;
	local offset = HybridScrollFrame_GetOffset(self);

	local numSets = C_LootJournal.GetNumItemSets()

	for i = 1, #buttons do
		local button = buttons[i];
		local index = offset + i;
		if ( index <= numSets ) then
			local setIndex, name, tierName, itemlevel, sourceText, isPVP, items, numItems = C_LootJournal.GetItemSetInfo(index)

			button:Show();
			button.SetName:SetText(name);
			button.ItemLevel:SetFormattedText(EJ_SET_ITEM_LEVEL, tierName, itemlevel);
			button.PVPIcon:SetShown(isPVP);

			button.setIndex = setIndex
			button.tooltipText = sourceText
			button:CheckItemButtonTooltip()

			for j = 1, numItems do
				local itemButton = button.ItemButtons[j];
				if ( not itemButton ) then
					itemButton = CreateFrame("BUTTON", string.format("$parentItemButton%i", j), button, "LootJournalItemSetItemButtonTemplate");
					button[string.format("$parentItemButton%i", j)] = itemButton
					itemButton:SetPoint("LEFT", button.ItemButtons[j-1], "RIGHT", 5, 0);
				end
				itemButton.Icon:SetTexture(items[j].icon);
				itemButton.itemID = items[j].itemID;
				itemButton:Show();
				self:ConfigureItemButton(itemButton);
			end
			for j = numItems + 1, #button.ItemButtons do
				button.ItemButtons[j].itemID = nil;
				button.ItemButtons[j]:Hide();
			end
		else
			button:Hide();
		end
	end

	local totalHeight = numSets * buttons[1]:GetHeight() + (numSets - 1) * LJ_ITEMSET_BUTTON_SPACING + LJ_ITEMSET_Y_OFFSET + LJ_ITEMSET_BOTTOM_BUFFER
	HybridScrollFrame_Update(self, totalHeight, self:GetHeight());
end

LootJournalItemSetButtonMixin = {}

function LootJournalItemSetButtonMixin:OnEnter()
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(LOOTJOURNAL_SOURCE_TOOLTIP_HEAD, 1, 1, 1)
		GameTooltip:AddLine(self.tooltipText, nil, nil, nil, 1)
		self.tooltipSetIndex = self.setIndex
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end
end

function LootJournalItemSetButtonMixin:CheckItemButtonTooltip()
	if ( GameTooltip:GetOwner() == self and self.tooltipSetIndex ~= self.setIndex ) then
		self:OnEnter();
	end
end