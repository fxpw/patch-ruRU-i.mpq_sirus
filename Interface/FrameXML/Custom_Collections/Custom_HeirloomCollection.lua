local NO_CLASS_FILTER = 0;
local NO_SPEC_FILTER = 0;

local VIEW_MODE_FULL = 1; -- Shows everything and isn't filtered by class/spec
local VIEW_MODE_CLASS = 2; -- Only shows items valid for the selected class/spec

HeirloomsMixin = {};

function HeirloomsMixin:OnLoad()
	self.newHeirlooms = {};

	self.heirloomEntryFrames = {};
	self.heirloomHeaderFrames = {};

	self.heirloomLayoutData = {};
	self.itemIDsInCurrentLayout = {};

	self.numKnownHeirlooms = 0;
	self.numPossibleHeirlooms = 0;

	self:FullRefreshIfVisible();

	self:RegisterCustomEvent("HEIRLOOMS_UPDATED");

	self.FilterButton:SetResetFunction(function() self:ResetFilters() end);

	self.IconsFrame.Watermark:SetAtlas("collections-watermark-heirloom", true);
end

function HeirloomsMixin:OnEvent(event, ...)
	if event == "HEIRLOOMS_UPDATED" then
		self:OnHeirloomsUpdated(...);
	end
end

local function GetTalentTabIndex()
	local talents = C_Talent.GetSpecInfoCache();
	if talents and talents.activeTalentGroup then
		local maxTalents, maxTabID = 0;
		for tabID = 1, 3 do
			local count = talents.talentGroupData[talents.activeTalentGroup][tabID];
			if count > maxTalents then
				maxTalents = count;
				maxTabID = tabID;
			end
		end
		return maxTabID;
	end
end

local function GetTalentTabIndexInfo(tabIndex)
	local _, _, classID = UnitClass("player");
	local data = S_CALSS_SPECIALIZATION_DATA[classID] and S_CALSS_SPECIALIZATION_DATA[classID][tabIndex];
	if data then
		return data[1];
	end
	return 0;
end

function HeirloomsMixin:OnShow()
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\inv_misc_enggizmos_19");

	if self.filtersSet == nil then
--		if UnitLevel("player") >= 80 then
--			-- Default to full view for max level players
--			C_Heirloom.SetClassAndSpecFilters(NO_CLASS_FILTER, NO_SPEC_FILTER);
--		else
			-- Default to current class/spec view otherwise
			local _, _, classID = UnitClass("player");

			local specID;
			local tabIndex = GetTalentTabIndex();
			if tabIndex then
				specID = GetTalentTabIndexInfo(tabIndex);
			else
				specID = NO_SPEC_FILTER;
			end

			C_Heirloom.SetClassAndSpecFilters(classID, specID);
		end

		self:UpdateClassFilterDropDownText();
--	end

	if self.needsRefresh then
		self:RefreshView();
	end
end

function HeirloomsMixin:OnMouseWheel(delta)
	self.PagingFrame:OnMouseWheel(delta);
end

function HeirloomsJournal_UpdateButton(self)
	self:GetParent():GetParent():UpdateButton(self);
end

function HeirloomsJournalSpellButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHeirloomByItemID(self.itemID);

	self.UpdateTooltip = HeirloomsJournalSpellButton_OnEnter;

	if self:GetParent():GetParent():ClearNewStatus(self.itemID) then
		HeirloomsJournal_UpdateButton(self);
	end

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function HeirloomsJournalSpellButton_OnClick(self, button)
	if IsModifiedClick() then
		if IsModifiedClick("CHATLINK") then
			local itemLink = C_Heirloom.GetHeirloomLink(self.itemID);
			if ChatEdit_InsertLink(itemLink) then
				return;
			end
		end

		if IsModifiedClick("DRESSUP") then
			DressUpItemLink(self.itemID);
			return;
		end
	elseif button == "LeftButton" then
		SecureActionButton_OnClick(self, button);
	end
end

do
	local function OpenCollectedFilterDropDown(self, level)
		if level then
			self:GetParent():OpenCollectedFilterDropDown(level);
		end
	end

	function HeirloomsJournalCollectedFilterDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenCollectedFilterDropDown, "MENU");
		if HeirloomsJournal.UpdateResetFiltersButtonVisibility then
			HeirloomsJournal:UpdateResetFiltersButtonVisibility();
		end
	end
end

do
	local function OpenClassFilterDropDown(self, level)
		if level then
			self:GetParent():OpenClassFilterDropDown(level);
		end
	end

	function HeirloomsJournalClassFilterDropDown_OnLoad(self)
		UIDropDownMenu_Initialize(self, OpenClassFilterDropDown);
		UIDropDownMenu_SetWidth(self, 140);
	end
end

function HeirloomsMixin:OnHeirloomsUpdated(itemID, new)
	if itemID then
		-- Single item update
		if new then
			self.newHeirlooms[itemID] = true;
			self.autoPageToCollectedHeirloom = itemID;

			if self.itemIDsInCurrentLayout[itemID] then
				self.numKnownHeirlooms = self.numKnownHeirlooms + 1;
				self:UpdateProgressBar();
			end

			self:FullRefreshIfVisible();
		else
			self:RefreshViewIfVisible();
		end
	else
		-- Full update
		self:FullRefreshIfVisible();
	end
end

function HeirloomsMixin:ClearNewStatus(itemID)
	if self.newHeirlooms[itemID] then
		self.newHeirlooms[itemID] = nil;
		return true;
	end
	return false;
end

function HeirloomsMixin:SetFindPageForHeirloomePage(autoPageToCollectedHeirloom)
	self.autoPageToCollectedHeirloom = autoPageToCollectedHeirloom;
end

function HeirloomsMixin:FullRefreshIfVisible()
	self.needsDataRebuilt = true;
	self:RefreshViewIfVisible();
end

function HeirloomsMixin:RefreshViewIfVisible()
	if self:IsVisible() then
		self:RefreshView();
	else
		self.needsRefresh = true;
	end
end

function HeirloomsMixin:RebuildLayoutData()
	if not self.needsDataRebuilt then
		return;
	end

	self.needsDataRebuilt = false;

	self.heirloomLayoutData = {};
	self.itemIDsInCurrentLayout = {};

	self.numKnownHeirlooms = 0;
	self.numPossibleHeirlooms = 0;

	local equipBuckets = self:SortHeirloomsIntoEquipmentBuckets();
	self:SortEquipBucketsIntoPages(equipBuckets);
	self.PagingFrame:SetMaxPages(math.max(#self.heirloomLayoutData, 1));
end

local function GetHeirloomCategoryFromInvType(invType)
	if invType == "INVTYPE_HEAD" then
		return HEIRLOOMS_CATEGORY_HEAD;
	elseif invType == "INVTYPE_SHOULDER" then
		return HEIRLOOMS_CATEGORY_SHOULDER;
	elseif invType == "INVTYPE_CHEST" or invType == "INVTYPE_ROBE" then
		return HEIRLOOMS_CATEGORY_CHEST;
	elseif invType == "INVTYPE_HAND" then
		return HEIRLOOMS_CATEGORY_HAND;
	elseif invType == "INVTYPE_WRIST" then
		return HEIRLOOMS_CATEGORY_WRIST;
	elseif invType == "INVTYPE_LEGS" then
		return HEIRLOOMS_CATEGORY_LEGS;
	elseif invType == "INVTYPE_WAIST" then
		return HEIRLOOMS_CATEGORY_WAIST;
	elseif invType == "INVTYPE_FEET" then
		return HEIRLOOMS_CATEGORY_FEET;
	elseif invType == "INVTYPE_CLOAK" then
		return HEIRLOOMS_CATEGORY_BACK;
	elseif invType == "INVTYPE_WEAPON" or invType == "INVTYPE_SHIELD" or invType == "INVTYPE_RANGED" or invType == "INVTYPE_RANGED" or invType == "INVTYPE_2HWEAPON" or invType == "INVTYPE_RELIC"
		or invType == "INVTYPE_WEAPONMAINHAND" or invType == "INVTYPE_WEAPONOFFHAND" or invType == "INVTYPE_HOLDABLE" or invType == "INVTYPE_THROWN" or invType == "INVTYPE_RANGEDRIGHT" then
		return HEIRLOOMS_CATEGORY_WEAPON;
	elseif invType == "INVTYPE_FINGER" or invType == "INVTYPE_TRINKET" or invType == "INVTYPE_NECK" then
		return HEIRLOOMS_CATEGORY_TRINKETS_RINGS_AND_NECKLACES;
	end

	return nil;
end

function HeirloomsMixin:DetermineViewMode()
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	if classFilter == NO_CLASS_FILTER and specFilter == NO_SPEC_FILTER then
		return VIEW_MODE_FULL;
	end

	return VIEW_MODE_CLASS;
end

function HeirloomsMixin:SortHeirloomsIntoEquipmentBuckets()
	-- Sort them into equipment buckets
	local equipBuckets = {};
	for i = 1, C_Heirloom.GetNumDisplayedHeirlooms() do
		local itemID = C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(i);

		local name, itemEquipLoc, itemTexture = C_Heirloom.GetHeirloomInfo(itemID);
		local category = GetHeirloomCategoryFromInvType(itemEquipLoc);
		if category then
			if not equipBuckets[category] then
				equipBuckets[category] = {};
			end

			table.insert(equipBuckets[category], itemID);

			-- Count this heirloom as long as it has a category and matches the class/spec filter, other filters should not affect the count
			if C_Heirloom.PlayerHasHeirloom(itemID) then
				self.numKnownHeirlooms = self.numKnownHeirlooms + 1;
			end

			self.numPossibleHeirlooms = self.numPossibleHeirlooms + 1;

			self.itemIDsInCurrentLayout[itemID] = true;
		end
	end

	return equipBuckets;
end

-- Each heirloom button entry dimension
local BUTTON_WIDTH = 208;
local BUTTON_HEIGHT = 50;

-- Padding around each heirloom button
local BUTTON_PADDING_X = 0;
local BUTTON_PADDING_Y = 16;

-- The total height of a heirloom header
local HEADER_HEIGHT = 24 + 13;

-- Y padding before the first header of a page
local FIRST_HEADER_Y_PADDING = 0;
-- Y padding before additional headers after the first header of a page
local ADDITIONAL_HEADER_Y_PADDING = 16;

-- Max height of a page before starting a new page, when the view mode is in "all classes"
local VIEW_MODE_FULL_PAGE_HEIGHT = 370;
-- Max height of a page before starting a new page, when the view mode is in "specific class"
local VIEW_MODE_CLASS_PAGE_HEIGHT = 380;
-- Max width of a page before starting a new row
local PAGE_WIDTH = 625;

-- The starting X offset of a page
local START_OFFSET_X = 40;
-- The starting Y offset of a page
local START_OFFSET_Y = -25;

-- Additional Y offset of a page when the view mode is in "all classes"
local VIEW_MODE_FULL_ADDITIONAL_Y_OFFSET = 0;
-- Additional Y offset of a page when the view mode is in "specific class"
local VIEW_MODE_CLASS_ADDITIONAL_Y_OFFSET = 9;

local ITEM_EQUIP_SLOT_SORT_ORDER = {
	HEIRLOOMS_CATEGORY_HEAD,
	HEIRLOOMS_CATEGORY_SHOULDER,
	HEIRLOOMS_CATEGORY_BACK,
	HEIRLOOMS_CATEGORY_CHEST,
	HEIRLOOMS_CATEGORY_HAND;
	HEIRLOOMS_CATEGORY_WRIST,
	HEIRLOOMS_CATEGORY_LEGS,
	HEIRLOOMS_CATEGORY_WAIST,
	HEIRLOOMS_CATEGORY_FEET,
	HEIRLOOMS_CATEGORY_WEAPON,
	HEIRLOOMS_CATEGORY_TRINKETS_RINGS_AND_NECKLACES,
}

local NEW_ROW_OPCODE = -1; -- Used to indicate that the layout should move to the next row

function HeirloomsMixin:SortEquipBucketsIntoPages(equipBuckets)
	if not next(equipBuckets) then
		return;
	end

	local viewMode = self:DetermineViewMode();

	local currentPage = {};
	local pageHeight = viewMode == VIEW_MODE_FULL and VIEW_MODE_FULL_PAGE_HEIGHT or VIEW_MODE_CLASS_PAGE_HEIGHT
	local heightLeft = pageHeight;
	local widthLeft = PAGE_WIDTH;

	for _, itemEquipLoc in ipairs(ITEM_EQUIP_SLOT_SORT_ORDER) do
		local equipBucket = equipBuckets[itemEquipLoc];

		if equipBucket then
			if viewMode == VIEW_MODE_FULL then -- Only headers in full mode
				if heightLeft < HEADER_HEIGHT + BUTTON_PADDING_Y + BUTTON_HEIGHT then
					-- Not enough room to add the upcoming header for this bucket, move to next page
					table.insert(self.heirloomLayoutData, currentPage);
					heightLeft = pageHeight;
					currentPage = {};
				end

				-- Add header
				table.insert(currentPage, itemEquipLoc);
				if #currentPage > 1 then
					heightLeft = heightLeft - ADDITIONAL_HEADER_Y_PADDING - BUTTON_HEIGHT - BUTTON_PADDING_Y;
				else
					heightLeft = heightLeft - FIRST_HEADER_Y_PADDING;
				end

				widthLeft = PAGE_WIDTH;
				heightLeft = heightLeft - HEADER_HEIGHT;
			end

			-- Add buttons
			for i, itemID in ipairs(equipBucket) do
				if widthLeft < BUTTON_WIDTH + BUTTON_PADDING_X then
					-- Not enough room for another entry, try going to a new row
					widthLeft = PAGE_WIDTH;

					if heightLeft < BUTTON_HEIGHT + BUTTON_PADDING_Y then
						-- Not enough room for another row of entries, move to next page
						table.insert(self.heirloomLayoutData, currentPage);

						heightLeft = pageHeight - HEADER_HEIGHT;
						currentPage = {};
					else
						-- Room for another row
						table.insert(currentPage, NEW_ROW_OPCODE);
						heightLeft = heightLeft - BUTTON_HEIGHT - BUTTON_PADDING_Y;
					end
				end

				widthLeft = widthLeft - BUTTON_WIDTH - BUTTON_PADDING_X;
				table.insert(currentPage, itemID);
			end
		end
	end

	table.insert(self.heirloomLayoutData, currentPage);
end

function HeirloomsMixin:AcquireFrame(framePool, numInUse, frameType, name, template)
	if not framePool[numInUse] then
		framePool[numInUse] = CreateFrame(frameType, name, self.IconsFrame, template);
	end
	return framePool[numInUse];
end

local function ActivatePooledFrames(framePool, numEntriesInUse)
	for i = 1, numEntriesInUse do
		framePool[i]:Show();
	end

	for i = numEntriesInUse + 1, #framePool do
		framePool[i]:Hide();
	end
end

function HeirloomsMixin:LayoutCurrentPage()
	local pageLayoutData = self.heirloomLayoutData[self.PagingFrame:GetCurrentPage()];

	local numEntriesInUse = 0;
	local numHeadersInUse = 0;

	if pageLayoutData then
		local offsetX = START_OFFSET_X;
		local offsetY = START_OFFSET_Y;
		if self:DetermineViewMode() == VIEW_MODE_FULL then
			offsetY = offsetY + VIEW_MODE_FULL_ADDITIONAL_Y_OFFSET;
		else
			offsetY = offsetY + VIEW_MODE_CLASS_ADDITIONAL_Y_OFFSET;
		end

		for i, layoutData in ipairs(pageLayoutData) do
			if layoutData == NEW_ROW_OPCODE then
				assert(i ~= 1); -- Never want to start a new row first thing on a page, something is wrong with the page creator
				offsetX = START_OFFSET_X;
				offsetY = offsetY - BUTTON_HEIGHT - BUTTON_PADDING_Y;
			elseif type(layoutData) == "string" then
				-- Header
				numHeadersInUse = numHeadersInUse + 1;
				local header = self:AcquireFrame(self.heirloomHeaderFrames, numHeadersInUse, "FRAME", "HeirloomHeaderFrame"..numHeadersInUse, "HeirloomHeaderTemplate");
				header.Text:SetText(layoutData);

				if i > 1 then
					-- Additional headers on the same page should have additional spacing between the sections
					offsetY = offsetY - ADDITIONAL_HEADER_Y_PADDING - BUTTON_HEIGHT - BUTTON_PADDING_Y;
				else
					offsetY = offsetY - FIRST_HEADER_Y_PADDING;
				end
				header:SetPoint("TOP", self.IconsFrame, "TOP", 0, offsetY);

				offsetX = START_OFFSET_X;
				offsetY = offsetY - HEADER_HEIGHT;
			else
				-- Entry
				numEntriesInUse = numEntriesInUse + 1;
				local entry = self:AcquireFrame(self.heirloomEntryFrames, numEntriesInUse, "CHECKBUTTON", "HeirloomSpellButton"..numEntriesInUse, "HeirloomSpellButtonTemplate");
				local spellID = C_Heirloom.GetHeirloomSpellID(layoutData);
				entry.itemID = layoutData;
				entry.spellID = spellID;

				if entry:IsVisible() then
					-- If the button was already visible (going to a new page and being reused) we have to update the button immediately instead of deferring the update through the OnShown
					self:UpdateButton(entry);
				end

				if i == 1 then
					-- Continuation of a section from a previous page
					-- Move everything down as if there was a header
					offsetY = offsetY - HEADER_HEIGHT;
				end

				entry:SetPoint("TOPLEFT", self.IconsFrame, "TOPLEFT", offsetX, offsetY);

				offsetX = offsetX + BUTTON_WIDTH + BUTTON_PADDING_X;
			end
		end
	end

	ActivatePooledFrames(self.heirloomEntryFrames, numEntriesInUse);
	ActivatePooledFrames(self.heirloomHeaderFrames, numHeadersInUse);
end

function HeirloomsMixin:FindPageForHeirloom()
	for i = 1, #self.heirloomLayoutData do
		local pageToCheck = ((self.PagingFrame:GetCurrentPage() - 1) + (i - 1)) % #self.heirloomLayoutData + 1;

		local pageLayoutData = self.heirloomLayoutData[pageToCheck];
		if pageLayoutData then
			for _, layoutData in ipairs(pageLayoutData) do
				if layoutData ~= NEW_ROW_OPCODE and type(layoutData) ~= "string" then
					if self.autoPageToCollectedHeirloom and self.autoPageToCollectedHeirloom == layoutData then
						return pageToCheck;
					end
				end
			end
		end
	end

	return nil;
end

function HeirloomsMixin:RefreshView()
	self.needsRefresh = false;

	self:RebuildLayoutData();

	if self.autoPageToCollectedHeirloom then
		local closestUpgradeablePage = self:FindPageForHeirloom();
		if closestUpgradeablePage then
			self.PagingFrame:SetCurrentPage(closestUpgradeablePage);
		else
			local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
			if classFilter ~= NO_CLASS_FILTER or specFilter ~= NO_SPEC_FILTER then
				local oldClassFilter = classFilter;
				local oldSpecFilter = specFilter;

				C_Heirloom.SetClassAndSpecFilters(NO_CLASS_FILTER, NO_SPEC_FILTER);

				self.needsDataRebuilt = true;
				self:RebuildLayoutData();

				closestUpgradeablePage = self:FindPageForHeirloom();
				if closestUpgradeablePage then
					self.PagingFrame:SetCurrentPage(closestUpgradeablePage);
					self:UpdateClassFilterDropDownText();
				else
					C_Heirloom.SetClassAndSpecFilters(oldClassFilter, oldSpecFilter);

					self.needsDataRebuilt = true;
					self:RebuildLayoutData();
				end
			end
		end

		self.autoPageToCollectedHeirloom = nil;
	end

	self:LayoutCurrentPage();
	self:UpdateProgressBar();
end

function HeirloomsMixin:UpdateButton(button)
	local name, itemEquipLoc, itemTexture = C_Heirloom.GetHeirloomInfo(button.itemID);

	button.IconTexture:SetTexture(itemTexture);
	button.IconTextureUncollected:SetTexture(itemTexture);
	button.IconTextureUncollected:SetDesaturated(true);

	button.Name:SetText(name);

	local isNew = self.newHeirlooms[button.itemID];
	button.New:SetShown(isNew);
	button.NewGlow:SetShown(isNew);

	if C_Heirloom.PlayerHasHeirloom(button.itemID) then
		button.IconTexture:Show();
		button.IconTextureUncollected:Hide();
		button.Name:SetTextColor(1, 0.82, 0, 1);
		button.Name:SetShadowColor(0, 0, 0, 1);

		button.SlotFrameCollected:Show();
		button.SlotFrameUncollected:Hide();
		button.SlotFrameUncollectedInnerGlow:Hide();

		button:SetAttribute("type", "spell");
		button:SetAttribute("spell", button.spellID);
	else
		button.IconTexture:Hide();
		button.IconTextureUncollected:Show();
		button.Name:SetTextColor(0.33, 0.27, 0.20, 1);
		button.Name:SetShadowColor(0, 0, 0, 0.33);

		button.SlotFrameCollected:Hide();
		button.SlotFrameUncollected:Show();
		button.SlotFrameUncollectedInnerGlow:Show();

		button:SetAttribute("type", nil);
		button:SetAttribute("spell", nil);
	end

	CollectionsSpellButton_UpdateCooldown(button);
end

function HeirloomsMixin:UpdateProgressBar()
	local maxProgress, currentProgress = self.numPossibleHeirlooms, self.numKnownHeirlooms;
	self.ProgressBar:SetMinMaxValues(0, maxProgress);
	self.ProgressBar:SetValue(currentProgress);

	self.ProgressBar.Text:SetFormattedText(HEIRLOOMS_PROGRESS_FORMAT, currentProgress, maxProgress);
end

function HeirloomsMixin:OnPageChanged(userAction)
	PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	if userAction then
		self:RefreshViewIfVisible();
	end
end

function HeirloomsMixin:SetCollectedHeirloomFilter(checked)
	C_Heirloom.SetCollectedHeirloomFilter(checked);
	self:FullRefreshIfVisible();
end

function HeirloomsMixin:SetUncollectedHeirloomFilter(checked)
	C_Heirloom.SetUncollectedHeirloomFilter(checked);
	self:FullRefreshIfVisible();
end

function HeirloomsMixin:SetSourceChecked(source, checked)
	if self:IsSourceChecked(source) ~= checked then
		C_Heirloom.SetHeirloomSourceFilter(source, checked);

		self:FullRefreshIfVisible();
	end
end

function HeirloomsMixin:IsSourceChecked(source)
	return C_Heirloom.GetHeirloomSourceFilter(source);
end

function HeirloomsMixin:SetAllSourcesChecked(checked)
	C_HeirloomInfo.SetAllSourceFilters(checked);

	self:FullRefreshIfVisible();
	UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function HeirloomsMixin:ResetFilters()
	C_HeirloomInfo.SetDefaultFilters();
	self.FilterButton.ResetButton:Hide();

	self:FullRefreshIfVisible();
end

function HeirloomsMixin:UpdateResetFiltersButtonVisibility()
	self.FilterButton.ResetButton:SetShown(not C_HeirloomInfo.IsUsingDefaultFilters());
end

function HeirloomsMixin:OpenCollectedFilterDropDown(level)
	local filterSystem = {
		onUpdate = function() self:UpdateResetFiltersButtonVisibility() end,
		filters = {
			{ type = FilterComponent.Checkbox, text = COLLECTED, set = function(value) HeirloomsJournal:SetCollectedHeirloomFilter(value) end, isSet = C_Heirloom.GetCollectedHeirloomFilter },
			{ type = FilterComponent.Checkbox, text = NOT_COLLECTED, set = function(value) HeirloomsJournal:SetUncollectedHeirloomFilter(value) end, isSet = C_Heirloom.GetUncollectedHeirloomFilter },
			{ type = FilterComponent.Submenu, text = SOURCES, value = 1, childrenInfo = {
				filters = {
					{ type = FilterComponent.TextButton,
					  text = CHECK_ALL,
					  set = function() self:SetAllSourcesChecked(true);	end,
					},
					{ type = FilterComponent.TextButton,
					  text = UNCHECK_ALL,
					  set = function() self:SetAllSourcesChecked(false); end,
					},
					{ type = FilterComponent.DynamicFilterSet,
					  buttonType = FilterComponent.Checkbox,
					  set = function(filter, value)	self:SetSourceChecked(filter, value); end,
					  isSet = function(source) return self:IsSourceChecked(source); end,
					  numFilters = C_PetJournal.GetNumPetSources,
					  filterValidation = C_HeirloomInfo.IsHeirloomSourceValid,
					  globalPrepend = "COLLECTION_PET_SOURCE_",
					},
				},
			},
		},
		}
	};

	FilterDropDownSystem.Initialize(self, filterSystem, level);
end

function HeirloomsMixin:GetClassFilter()
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	return classFilter;
end

function HeirloomsMixin:GetSpecFilter()
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	return specFilter;
end

function HeirloomsMixin:SetClassAndSpecFilters(newClassFilter, newSpecFilter)
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();
	if not self.filtersSet or classFilter ~= newClassFilter or specFilter ~= newSpecFilter then
		C_Heirloom.SetClassAndSpecFilters(newClassFilter, newSpecFilter);

		self.PagingFrame:SetCurrentPage(1);
		self:UpdateClassFilterDropDownText();
		self:FullRefreshIfVisible();
	end

	CloseDropDownMenus(1);
	self.filtersSet = true;
end

function HeirloomsMixin:UpdateClassFilterDropDownText()
	local text;
	local classFilter, specFilter = C_Heirloom.GetClassAndSpecFilters();

	if classFilter == NO_CLASS_FILTER then
		text = ALL_CLASSES;
	else
		local classInfo = C_CreatureInfo.GetClassInfo(classFilter);
		if not classInfo then
			return;
		end

		local classColorStr = RAID_CLASS_COLORS[classInfo.classFile].colorStr;
		if specFilter == NO_SPEC_FILTER then
			text = string.format(HEIRLOOMS_CLASS_FILTER_FORMAT, classColorStr, classInfo.className);
		else
			local specName = GetSpecializationNameForSpecID(specFilter);
			text = string.format(HEIRLOOMS_CLASS_SPEC_FILTER_FORMAT, classColorStr, classInfo.className, specName);
		end
	end

	UIDropDownMenu_SetText(self.ClassDropDown, text);
end

do
	local CLASS_DROPDOWN = 1;

	function HeirloomsMixin:OpenClassFilterDropDown(level)
		local filterClassID = self:GetClassFilter();
		local filterSpecID = self:GetSpecFilter();

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

			for i = 1, GetNumClasses() do
				if i ~= 10 then
					local classDisplayName, _, classID = GetClassInfo(i);
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

			local _, classDisplayName, classID;
			if filterClassID ~= NO_CLASS_FILTER then
				classID = filterClassID;

				local classInfo = C_CreatureInfo.GetClassInfo(filterClassID);
				if classInfo then
					classDisplayName = classInfo.className;
				end
			else
				classDisplayName, _, classID = UnitClass("player");
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
				local specID, specName = GetSpecializationInfoForClassID(classID, i);
				info.leftPadding = 10;
				info.text = specName;
				info.checked = filterSpecID == specID;
				info.arg1 = classID;
				info.arg2 = specID;
				info.func = SetClassAndSpecFilters;
				UIDropDownMenu_AddButton(info, level);
			end

			info.text = ALL_SPECS;
			info.leftPadding = 10;
			info.checked = classID == filterClassID and filterSpecID == NO_SPEC_FILTER;
			info.arg1 = classID;
			info.arg2 = NO_SPEC_FILTER;
			info.func = SetClassAndSpecFilters;
			UIDropDownMenu_AddButton(info, level);
		end
	end
end

function HeirloomsJournalSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_Heirloom.SetSearch(self:GetText());
	HeirloomsJournal:FullRefreshIfVisible();
end