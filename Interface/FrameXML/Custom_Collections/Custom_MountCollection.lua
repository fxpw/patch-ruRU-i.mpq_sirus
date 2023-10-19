local CastSpellByID = CastSpellByID;

local MOUNT_BUTTON_HEIGHT = 46;
local SUMMON_RANDOM_FAVORITE_MOUNT_SPELL = 305495;

local MOUNT_FACTION_TEXTURES = {
	[0] = "MountJournalIcons-Horde",
	[1] = "MountJournalIcons-Alliance"
};

local displayCategories = {};
local categoryData = {
	{
		text = MY_COLLECTIONS,
		id = 0,
		sortID = LE_MOUNT_JOURNAL_FILTER_COLLECTED,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_01",
	},
	{
		text = FAVORITES,
		id = 0,
		sortID = LE_MOUNT_JOURNAL_FILTER_FAVORITES,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_02",
	},
	{
		text = ALL_MOUNTS,
		id = 0,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_07",
		func = function()
			MountJournal_SetDefaultCategory(true);
		end
	},
};

function MountJournal_OnLoad(self)
	local homeData = {
		name = CATEGORYES,
		OnClick = function()
			C_MountJournal.ClearCategoryFilter();
			if self.ListScrollFrame:IsShown() then
				self.ListScrollFrame:Hide();
				self.CategoryScrollFrame:Show();
			end
			MountJournal_UpdateCollectionList();
			NavBar_Reset(MountJournal.navBar);
		end,
	};

	self.navBar.home:SetText(CATEGORYES);
	NavBar_ReconsultationSize(self.navBar.home);
	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);

	MountJournal_SetDefaultCategory();

	self.ListScrollFrame.update = MountJournal_UpdateMountList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0);

	self.CategoryScrollFrame.update = MountJournal_UpdateCollectionList;
	self.CategoryScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.CategoryScrollFrame, "CategoryListButtonTemplate", 0, 0, "TOP", "TOP", 0, 0, "TOP", "BOTTOM");

	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterCustomEvent("MOUNT_JOURNAL_SEARCH_UPDATED");

	UIDropDownMenu_Initialize(self.mountOptionsMenu, MountOptionsMenu_Init, "MENU")

	self.FilterButton:SetResetFunction(MountJournalFilterDropdown_ResetFilters);

	self.MountDisplay.ModelScene.abilitiesPool = CreateFramePool("Button", self.MountDisplay.ModelScene, "MountAbilityButtonTemplate");
end

function MountJournal_OnEvent(self, event, ...)
	if event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" or event == "COMPANION_UPDATE" then
		local companionType = ...;
		if not companionType or companionType == "MOUNT" then
			MountJournal_FullUpdate(self);
		end
	elseif event == "MOUNT_JOURNAL_SEARCH_UPDATED" then
		MountJournal_FullUpdate(self);
	end
end

function MountJournal_FullUpdate(self)
	if self:IsVisible() then
		MountJournal_UpdateMountList();
		MountJournal_UpdateMountDisplay();
	end
end

function MountJournal_OnShow(self)
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	SetParentFrameLevel(self.LeftInset);
	SetParentFrameLevel(self.RightTopInset);

	self.IsOpenStore = nil

	if CollectionsJournal.resetPositionTimer then
		CollectionsJournal.resetPositionTimer:Cancel()
		CollectionsJournal.resetPositionTimer = nil
	end

	MountJournal_FullUpdate(self);

	MountJournalResetFiltersButton_UpdateVisibility();
end

function MountJournal_OnHide(self)
	if not self.IsOpenStore then
		if CollectionsJournal.resetPositionTimer then
			CollectionsJournal.resetPositionTimer:Cancel();
			CollectionsJournal.resetPositionTimer = nil;
		end

		CollectionsJournal.resetPositionTimer = C_Timer:After(5, function()
			MountJournal_SetDefaultCategory();

			MountJournal_ClearSearch();
			MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1);
			MountJournal_Select(1);

			if CollectionsJournal.resetPositionTimer then
				CollectionsJournal.resetPositionTimer:Cancel();
				CollectionsJournal.resetPositionTimer = nil;
			end
		end)
	end
end

function MountJournal_UpdateScrollPos(self, visibleIndex)
	local buttons = self.buttons
	local height = math.max(0, math.floor(self.buttonHeight * (visibleIndex - (#buttons)/2)))
	HybridScrollFrame_SetOffset(self, height)
	self.scrollBar:SetValue(height)
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournalListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numMounts = C_MountJournal.GetNumMounts();
	local numDisplayedMounts = C_MountJournal.GetNumDisplayedMounts();
	MountJournal.numOwned = 0;
	local showMounts = true;
	if numDisplayedMounts < 1 then
		MountJournal.MountDisplay.NoMounts:Show();
		MountJournal.MountDisplay.NoMountsTex:Show();
		showMounts = false;
	else
		MountJournal.MountDisplay.NoMounts:Hide();
		MountJournal.MountDisplay.NoMountsTex:Hide();
	end
	if numDisplayedMounts > 0 then
		MountJournal.MountDisplay.ModelScene:Show();
	else
		MountJournal.MountDisplay.ModelScene:Hide();
	end
	MountJournal.MountDisplay.ModelScene.InfoButton:SetShown(numDisplayedMounts > 0);
	MountJournal.MountDisplay.YesMountsTex:SetShown(numDisplayedMounts > 0);

	for i = 1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset
		if displayIndex <= numDisplayedMounts and showMounts then
			local index = displayIndex;
			local creatureName, spellID, icon, active, sourceType, isFavorite, isFactionSpecific, faction, isCollected, mountID, _, itemID = C_MountJournal.GetDisplayedMountInfo(index);

			button.name:SetText(creatureName);
			button.icon:SetTexture(icon);

			button.index = index;
			button.spellID = spellID;
			button.mountID = mountID;
			button.itemID = itemID;
			button.isCollected = isCollected;

			button.DragButton.ActiveTexture:SetShown(active);
			button:Show();

			if MountJournal.selectedItemID == itemID then
				button.selected = true;
				button.selectedTexture:Show();
			else
				button.selected = false;
				button.selectedTexture:Hide();
			end

			button:SetEnabled(true);
			button.unusable:Hide();
			button.iconBorder:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);

			if isCollected then
				button.DragButton:SetEnabled(true);
				button.name:SetFontObject("GameFontNormal");
				button.icon:SetAlpha(1.0);
				button.additionalText = nil;
			else
				button.icon:SetDesaturated(true);
				button.DragButton:SetEnabled(false);
				button.icon:SetAlpha(0.25);
				button.additionalText = nil;
				button.name:SetFontObject("GameFontDisable");
			end

			button.favorite:SetShown(isFavorite);

			if isFactionSpecific then
				button.factionIcon:SetAtlas(MOUNT_FACTION_TEXTURES[faction], true);
				button.factionIcon:Show();
			else
				button.factionIcon:Hide();
			end

			if button.showingTooltip then
				MountJournalMountButton_UpdateTooltip(button);
			end
		else
			button.name:SetText("");
			button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon");
			button.index = nil;
			button.spellID = 0;
			button.itemID = nil;
			button.mountID = nil;
			button.selected = false;
			button.unusable:Hide();
			button.DragButton.ActiveTexture:Hide();
			button.selectedTexture:Hide();
			button:SetEnabled(false);
			button.DragButton:SetEnabled(false);
			button.icon:SetDesaturated(true);
			button.icon:SetAlpha(0.5);
			button.favorite:Hide();
			button.factionIcon:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			button.iconBorder:Hide();
		end
	end

	local totalHeight = numDisplayedMounts * MOUNT_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	MountJournal.MountCount.Count:SetFormattedText("%d / %d", numMounts, numDisplayedMounts);
	if not showMounts then
		MountJournal.selectedItemID = nil;
		MountJournal.selectedMountID = nil;
	end
end

function MountJournal_UpdateMountDisplay(forceSceneChange)
	if MountJournal.selectedMountID then
		local creatureName, spellID, icon, active, sourceType, isFavorite, isFactionSpecific, faction, isCollected, mountID, creatureID, itemID, currency, price, _, priceText, descriptionText, holidayText = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);

		if MountJournal.MountDisplay.lastDisplayed ~= itemID or forceSceneChange then
			local isGMAccount = IsGMAccount()
			if isGMAccount then
				MountJournal.MountDisplay.ModelScene.DebugInfo:SetFormattedText("CreatureID: %s", creatureID);
				MountJournal.MountDisplay.ModelScene.DebugInfo:Show();
			else
				MountJournal.MountDisplay.ModelScene.DebugInfo:Hide();
			end
			MountJournal.MountDisplay.ModelScene.DebugFrame:SetShown(isGMAccount);

			MountJournal.MountDisplay.ModelScene.creatureID = creatureID;
			MountJournal.MountDisplay.ModelScene:Hide();
			MountJournal.MountDisplay.ModelScene:Show();

			MountJournal.MountDisplay.ModelScene.InfoButton.Icon:SetTexture(icon);
			MountJournal.MountDisplay.ModelScene.InfoButton.Name:SetText(creatureName);
			MountJournal.MountDisplay.ModelScene.InfoButton.Source:SetFormattedText("%s%s", holidayText ~= "" and string.format("%s\n", holidayText) or "", priceText);
			MountJournal.MountDisplay.ModelScene.InfoButton.Lore:SetText(descriptionText);

			if itemID then
				MountJournal.MountDisplay.ModelScene.EJFrame.OpenEJButton.itemID = itemID;
				MountJournal.MountDisplay.ModelScene.EJFrame:SetShown(LootJournal_CanOpenItemByEntry(itemID, true));
			else
				MountJournal.MountDisplay.ModelScene.EJFrame:Hide()
			end

			if sourceType == 9 then
				MountJournal.MountDisplay.ModelScene.buyFrame:SetShown(C_BattlePass.GetSeasonTimeLeft() ~= 0 and not isCollected);
				MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(GO_TO_BATTLE_BASS);
				MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetEnabled(true);
				MountJournal.MountDisplay.ModelScene.buyFrame.priceText:SetText("");
				MountJournal.MountDisplay.ModelScene.buyFrame.MoneyIcon:SetTexture("");
			elseif currency and currency ~= 0 then
				MountJournal.MountDisplay.ModelScene.buyFrame:SetShown(not isCollected);

				if currency == 4 then
					MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(PICK_UP);
				else
					MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(GO_TO_STORE);
				end

				MountJournal.MountDisplay.ModelScene.buyFrame.MoneyIcon:SetTexture("Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[currency]);
				MountJournal.MountDisplay.ModelScene.buyFrame.priceText:SetText(price);
			else
				MountJournal.MountDisplay.ModelScene.buyFrame:Hide();
			end

			MountJournal.MountDisplay.ModelScene.abilitiesPool:ReleaseAll();

			local abilities = C_MountJournal.GetMountAbilitiesInfoByID(MountJournal.selectedMountID);
			if abilities and #abilities > 0 then
				local firstButton;
				for _, abilityID in ipairs(abilities) do
					local abilityButton = MountJournal.MountDisplay.ModelScene.abilitiesPool:Acquire();
					abilityButton.abilityID = abilityID;
					abilityButton:Show();

					local _, abilityIcon = C_MountJournal.GetAbilityInfo(abilityID);
					abilityButton.creature:SetTexture(abilityIcon);
					if not firstButton then
						abilityButton:SetPoint("BOTTOMRIGHT", 5, 82);
					else
						abilityButton:SetPoint("BOTTOMRIGHT", firstButton, "TOPRIGHT", 0, -5);
					end
					firstButton = abilityButton;
				end
			end

			MountJournal.MountDisplay.lastDisplayed = itemID;
		end

		if active then
			MountJournal.MountButton:SetText(BINDING_NAME_DISMOUNT);
			MountJournal.MountButton:SetEnabled(isCollected);
		else
			MountJournal.MountButton:SetText(MOUNT);
			MountJournal.MountButton:SetEnabled(isCollected);
		end

		MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetShown(isCollected);
		if isCollected then
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetChecked(isFavorite);
		end
	else
		MountJournal.MountDisplay.ModelScene:Hide();
		MountJournal.MountButton:SetEnabled(false);
	end
end

function MountListDragButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local parent = self:GetParent()
	local spellID = parent.spellID
	if (spellID) then
		MountJournalMountButton_UpdateTooltip(parent)
		self.showingTooltip = true
	end
	if not parent.mountIndex then
		self.Highlight:Hide()
	end
end

function MountListDragButton_OnLeave(self)
	GameTooltip:Hide()
	self.showingTooltip = false
end

function MountListDragButton_OnDragStart(self)
	local companionIndex = C_MountJournal.GetMountCompanionIndex(self:GetParent().mountID);
	if companionIndex then
		PickupCompanion("MOUNT", companionIndex);
	end
end

function MountJournalMountButton_UpdateTooltip(self)
	if self.spellID then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetHyperlink(string.format("spell:%d", self.spellID));
		GameTooltip:Show();
	end
end

function MountListItem_OnDoubleClick(self, button)
	if button == "LeftButton" then
		MountJournalMountButton_UseMount(self.mountID);
	end
end

function MountJournal_Select(index)
	local mountID, _, itemID = select(10, C_MountJournal.GetDisplayedMountInfo(index));
	MountJournal_SetSelected(mountID, itemID);
end

function MountJournal_SelectByMountID(mountID)
	local itemID = select(12, C_MountJournal.GetMountInfoByID(mountID));
	MountJournal_SetSelected(mountID, itemID);
end

function MountJournal_GetMountButtonHeight()
	return MOUNT_BUTTON_HEIGHT;
end

function MountJournal_GetMountButtonByMountID(mountID)
	local scrollFrame = MountJournal.ListScrollFrame;
	local buttons = scrollFrame.buttons;

	for i = 1, #buttons do
		local button = buttons[i];
		if button.mountID == mountID then
			return button;
		end
	end
end

local function GetMountDisplayIndexByMountID(mountID)
	for i = 1, C_MountJournal.GetNumDisplayedMounts() do
		local _, _, _, _, _, _, _, _, _, currentMountID = C_MountJournal.GetDisplayedMountInfo(i);
		if currentMountID == mountID then
			return i;
		end
	end
	return nil;
end

function MountJournal_SetSelected(mountID, itemID)
	MountJournal.selectedItemID = itemID;
	MountJournal.selectedMountID = mountID;
	MountJournal_HideMountDropdown();
	MountJournal_UpdateMountList();
	MountJournal_UpdateMountDisplay();

	local inView = MountJournal_GetMountButtonByMountID(mountID) ~= nil;
	if not inView then
		local mountIndex = GetMountDisplayIndexByMountID(mountID);
		if mountIndex then
			HybridScrollFrame_ScrollToIndex(MountJournal.ListScrollFrame, mountIndex, MountJournal_GetMountButtonHeight);
		end
	end
end

function MountJournalMountButton_UseMount(mountID)
	local companionIndex = C_MountJournal.GetMountCompanionIndex(mountID);
	local _, _, _, active, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID);
	if companionIndex and isCollected then
		if active then
			DismissCompanion("MOUNT");
		else
			CallCompanion("MOUNT", companionIndex);
		end
	end
end

function MountJournalMountButton_OnClick(self)
	if MountJournal.selectedMountID then
		MountJournalMountButton_UseMount(MountJournal.selectedMountID);
	end
end

function MountListDragButton_OnClick(self, button)
	local parent = self:GetParent();
	if button ~= "LeftButton" then
		if parent.isCollected then
			MountJournal_ShowMountDropdown(parent.index, self, 0, 0);
		end
	elseif IsModifiedClick("CHATLINK") then
		local spellID = parent.spellID;
		local itemID = parent.itemID;

		if MacroFrame and MacroFrame:IsShown() then
			local spellName = GetSpellInfo(spellID);
			ChatEdit_InsertLink(spellName);
		elseif itemID then
			ChatEdit_InsertLink(string.format(COLLECTION_MOUNTS_HYPERLINK_FORMAT, itemID, GetSpellInfo(spellID) or ""));
		end
	else
		local companionIndex = C_MountJournal.GetMountCompanionIndex(parent.mountID);
		if companionIndex then
			PickupCompanion("MOUNT", companionIndex);
		end
	end
end

function MountListItem_OnClick(self, button)
	if button ~= "LeftButton" then
		if self.isCollected then
			MountJournal_ShowMountDropdown(self.index, self, 0, 0);
		end
	elseif IsModifiedClick("CHATLINK") then
		local spellID = self.spellID;
		local itemID = self.itemID;

		if MacroFrame and MacroFrame:IsShown() then
			local spellName = GetSpellInfo(spellID);
			ChatEdit_InsertLink(spellName);
		elseif itemID then
			ChatEdit_InsertLink(string.format(COLLECTION_MOUNTS_HYPERLINK_FORMAT, itemID, GetSpellInfo(spellID) or ""));
		end
	elseif self.itemID ~= MountJournal.selectedItemID then
		MountJournal_Select(self.index);

		MountJournal.searchBox:ClearFocus();
	end
end

function MountJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_MountJournal.SetSearch(self:GetText());

	if not MountJournal.selectedItemID then
		MountJournal_Select(1);
	end
end

function MountJournal_ClearSearch()
	MountJournal.searchBox:SetText("");
end

function MountJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MountJournalFilterDropDown_Initialize, "MENU");
end

function MountJournalFilterDropdown_ResetFilters()
	C_MountJournal.SetDefaultFilters();
	MountJournalFilterButton.ResetButton:Hide();
end

function MountJournalResetFiltersButton_UpdateVisibility()
	MountJournalFilterButton.ResetButton:SetShown(not C_MountJournal.IsUsingDefaultFilters());
end

function MountJournal_SetCollectedFilter(value)
	return C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, value);
end

function MountJournal_GetCollectedFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED);
end

function MountJournal_SetNotCollectedFilter(value)
	C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, value);
end

function MountJournal_GetNotCollectedFilter()
	return C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
end

function MountJournal_SetAllAbilityFilters(value)
	C_MountJournal.SetAllAbilityFilters(value);
	UIDropDownMenu_Refresh(MountJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, 2);
end

function MountJournal_SetAllSourceFilters(value)
	C_MountJournal.SetAllSourceFilters(value);
	C_MountJournal.SetAllTravelingMerchantFilters(value);
	UIDropDownMenu_Refresh(MountJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, 2);
end


function MountJournal_SetAllFactionFilters(value)
	C_MountJournal.SetAllFactionFilters(value);
	UIDropDownMenu_Refresh(MountJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, 2);
end

function MountJournalFilterDropDown_Initialize(self, level)
	local filterSystem = {
		onUpdate = MountJournalResetFiltersButton_UpdateVisibility,
		filters = {
			{ type = FilterComponent.Checkbox, text = COLLECTED, set = MountJournal_SetCollectedFilter, isSet = MountJournal_GetCollectedFilter },
			{ type = FilterComponent.Checkbox, text = NOT_COLLECTED, set = MountJournal_SetNotCollectedFilter, isSet = MountJournal_GetNotCollectedFilter },
			{ type = FilterComponent.Submenu, text = COLLECTION_MOUNT_ABILITIES, value = 1, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() MountJournal_SetAllAbilityFilters(true); end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() MountJournal_SetAllAbilityFilters(false); end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_MountJournal.SetAbilityFilter,
						  isSet = C_MountJournal.IsAbilityChecked,
						  numFilters = C_MountJournal.GetNumMountAbilities,
						  filterValidation = C_MountJournal.IsValidAbilityFilter,
						  globalPrepend = "COLLECTION_MOUNT_ABILITY_",
						},
					},
				},
			},
			{ type = FilterComponent.Submenu, text = SOURCES, value = 2, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() MountJournal_SetAllSourceFilters(true); end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() MountJournal_SetAllSourceFilters(false); end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_MountJournal.SetSourceFilter,
						  isSet = C_MountJournal.IsSourceChecked,
						  numFilters = C_PetJournal.GetNumPetSources,
						  filterValidation = C_MountJournal.IsValidSourceFilter,
						  globalPrepend = "COLLECTION_PET_SOURCE_",
						},
						{ type = FilterComponent.Submenu, text = COLLECTION_TRAVELING_MERCHANTS, value = 9, childrenInfo = {
								filters = {
									{ type = FilterComponent.DynamicFilterSet,
									  buttonType = FilterComponent.Checkbox,
									  set = C_MountJournal.SetTravelingMerchantFilter,
									  isSet = C_MountJournal.IsTravelingMerchantChecked,
									  numFilters = C_MountJournal.GetNumTravelingMerchantFilters,
									  filterValidation = C_MountJournal.IsValidTravelingMerchantFilter,
									  globalPrepend = "COLLECTION_TRAVELING_MERCHANT_",
									},
								},
							},
						},
					},
				},
			},
			{ type = FilterComponent.Submenu, text = FACTION, value = 3, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() MountJournal_SetAllFactionFilters(true); end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() MountJournal_SetAllFactionFilters(false); end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_MountJournal.SetFactionFilter,
						  isSet = C_MountJournal.IsFactionChecked,
						  numFilters = function () return 4; end,
						  filterValidation = C_MountJournal.IsValidFactionFilter,
						  globalPrepend = "COLLECTION_MOUNT_FACTION_",
						},
					},
				},
			},
		},
	};

	FilterDropDownSystem.Initialize(self, filterSystem, level);
end

function MountJournalSummonRandomFavoriteButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_MOUNT_SPELL;
	local _, _, spellIcon = GetSpellInfo(self.spellID);
	self.texture:SetTexture(spellIcon);
	self:RegisterForDrag("LeftButton");
end

function MountJournalSummonRandomFavoriteButton_OnClick(self)
	CastSpellByID(self.spellID)
end

function MountJournalSummonRandomFavoriteButton_OnDragStart(self)
	local spellname = GetSpellInfo(self.spellID);
	PickupSpell(spellname);
end

function MountJournalSummonRandomFavoriteButton_OnEnter( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("spell:"..self.spellID)
end

function MountOptionsMenu_Init(self, level)
	if not MountJournal.menuMountIndex then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	local _, _, _, active, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(MountJournal.menuMountID);
	if active then
		info.text = BINDING_NAME_DISMOUNT;
	else
		info.text = MOUNT;
		info.disabled = not isCollected;
	end

	info.func = function()
		MountJournalMountButton_UseMount(MountJournal.menuMountID);
	end

	UIDropDownMenu_AddButton(info, level);

	info.disabled = nil;
	local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(MountJournal.menuMountIndex);
	if isFavorite then
		info.text = DELETE_FAVORITE;
		info.func = function()
			C_MountJournal.SetIsFavorite(MountJournal.menuMountIndex, false);
		end
	else
		info.text = COMMUNITIES_LIST_DROP_DOWN_FAVORITE;
		info.func = function()
			C_MountJournal.SetIsFavorite(MountJournal.menuMountIndex, true);
		end
	end

	if canFavorite then
		info.disabled = false;
	else
		info.disabled = true;
	end

	UIDropDownMenu_AddButton(info, level);

	info.disabled = nil;
	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function MountJournal_ShowMountDropdown(index, anchorTo, offsetX, offsetY)
	if not index then
		return;
	end

	if index then
		MountJournal.menuMountIndex = index;
		MountJournal.menuMountID = select(10, C_MountJournal.GetDisplayedMountInfo(MountJournal.menuMountIndex));
	else
		return;
	end

	ToggleDropDownMenu(1, nil, MountJournal.mountOptionsMenu, anchorTo, offsetX, offsetY);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function MountJournal_HideMountDropdown()
	if UIDropDownMenu_GetCurrentDropDown() == MountJournal.mountOptionsMenu then
		HideDropDownMenu(1);
	end
end

function FavoriteButton_OnClick(self, button)
	if MountJournal.selectedMountID then
		MountJournal_SetSelected(MountJournal.selectedMountID, MountJournal.selectedItemID);

		local scrollButton = MountJournal_GetMountButtonByMountID(MountJournal.selectedMountID);
		if scrollButton then
			local isFavorite, canFavorite = C_MountJournal.GetIsFavorite(scrollButton.index);
			if canFavorite then
				if isFavorite then
					C_MountJournal.SetIsFavorite(scrollButton.index, false);
				else
					C_MountJournal.SetIsFavorite(scrollButton.index, true);
				end
			end
		end
	end
end

function MountJournalBuyButton_OnClick(self, button)
	MountJournal.IsOpenStore = true;

	HideUIPanel(CollectionsJournal);
--	ShowUIPanel(StoreFrame);

	if CollectionsJournal.resetPositionTimer then
		CollectionsJournal.resetPositionTimer:Cancel();
		CollectionsJournal.resetPositionTimer = nil;
	end

	CollectionsJournal.resetPositionTimer = C_Timer:After(30, function()
		MountJournal_SetDefaultCategory();

		MountJournal_ClearSearch();
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1);
		MountJournal_Select(1);

		MountJournal.IsOpenStore = false;
		if CollectionsJournal.resetPositionTimer then
			CollectionsJournal.resetPositionTimer:Cancel();
			CollectionsJournal.resetPositionTimer = nil;
		end
	end);

	if MountJournal.selectedMountID then
		local creatureName, _, icon, _, sourceType, _, _, _, _, _, _, itemID, currency, price, productID = C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID);

		if sourceType == 9 then
			BattlePassFrame:ShowCardWithItem(itemID);
		else
			local productData = {
				Texture = icon,
				Name = creatureName,
				Price = price,
				ID = productID,
				currency = currency
			};

			StoreFrame_ProductBuyWithOpenPage(productData);
		end
	end
end

function MountJournal_UpdateCollectionList()
	local scrollFrame = MountJournal.CategoryScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	table.wipe(displayCategories)

	local parentCategoryID;
	local selectedCategoryID = C_MountJournal.GetCategoryFilter();

	if selectedCategoryID then
		for _, category in ipairs(categoryData) do
			if category.id == selectedCategoryID then
				if parentCategoryID ~= category.id and MountJournal.CategoryScrollFrame:IsShown() then
					NavBar_Reset(MountJournal.navBar);

					local buttonData = {
						id = category.id,
						name = category.text,
						OnClick = function(self)
							C_MountJournal.SetCategoryFilter(self.id);

							if MountJournal.ListScrollFrame:IsShown() then
								MountJournal.ListScrollFrame:Hide()
								MountJournal.CategoryScrollFrame:Show()
							end
							NavBar_Reset(MountJournal.navBar)
							MountJournal_UpdateCollectionList()
						end
					};
					NavBar_AddButton(MountJournal.navBar, buttonData);
				end

				parentCategoryID = category.id;
			end
		end
	else
		if MountJournal.CategoryScrollFrame:IsShown() then
			NavBar_Reset(MountJournal.navBar);
		end
	end

	for _, category in next, categoryData do
		if not category.hidden then
			table.insert(displayCategories, category);
		elseif parentCategoryID and category.parent == parentCategoryID then
			category.collapsed = false;
			table.insert(displayCategories, category);
		elseif parentCategoryID and category.parent and category.parent == parentCategoryID then
			category.hidden = false;
			table.insert(displayCategories, category);
		end
	end

	local numCategories = #displayCategories;
	local numButtons = #buttons;

	local totalHeight = numCategories * buttons[1]:GetHeight();
	local displayedHeight = 0;

	for i = 1, numButtons do
		local button = buttons[i];
		local element = displayCategories[i + offset];
		displayedHeight = displayedHeight + button:GetHeight();

		if element then
			MountJournal_CategoryDisplayButton(button, element);

			if not element.func and selectedCategoryID and element.id == selectedCategoryID then
				button:LockHighlight();
				button:GetHighlightTexture():SetAlpha(0.7);
			else
				button:UnlockHighlight();
				button:GetHighlightTexture():SetAlpha(0.3);
			end

			button:Show();
		else
			button.element = nil;
			button:Hide();
		end
	end

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	return displayCategories;
end

function ListScrollFrame_OnShow(self)
	if not C_MountJournal.GetCategoryFilter() then
		MountJournal_FilterToggle(true)
	end
	MountJournal.LeftInset.Bgs:SetVertexColor(1, 1, 1, 1)
end

function CategoryScrollFrame_OnShow(self)
	MountJournal_FilterToggle(false)
	MountJournal.LeftInset.Bgs:SetVertexColor(1, 0, 0, 0.9)
end

function MountJournal_FilterToggle(value)
	if value then
		MountJournal.FilterButton:Enable()
		MountJournal.searchBox:EnableMouse(1)
	else
		MountJournal.FilterButton:Disable()
		MountJournal_ClearSearch();
		MountJournal.searchBox:ClearFocus()
		MountJournal.searchBox:EnableMouse(0)
	end
end

function MountJournal_SetDefaultCategory(notResetNavBar)
	C_MountJournal.ClearCategoryFilter();

	if not notResetNavBar then
		NavBar_Reset(MountJournal.navBar);
		NavBar_AddButton(MountJournal.navBar, {
			name = ALL_MOUNTS
		});
	end
end

function MountJournal_CategoryDisplayButton(button, element)
	if not element then
		button.element = nil;
		button:Hide();
		return;
	end

	button.Background:SetVertexColor(0.8, 0.8, 0.8);

	if element.icon then
		button.Icon:SetTexture(element.icon);
	end

	if element.isCategory then
--		button:SetWidth(250);
		button:SetSize(262, 62);
		button.Background:SetSize(262, 62);
		button:GetHighlightTexture():SetSize(262, 62);

		button.Background:SetTexCoord(0.00195313, 0.60742188, 0.00390625, 0.28515625);
		button:GetHighlightTexture():SetTexCoord(0.00195313, 0.60742188, 0.00390625, 0.28515625);

		button.categoryName:SetPoint("CENTER", 24, 0);
		button.categoryName:SetJustifyH("LEFT");
	else
		button:SetSize(230, 62);
		button.Background:SetSize(230, 62);
		button:GetHighlightTexture():SetSize(230, 62);

		button.Background:SetTexCoord(0, 0.53125, 0.76171875, 1);
		button:GetHighlightTexture():SetTexCoord(0, 0.53125, 0.76171875, 1);

		button.categoryName:SetPoint("CENTER", 0, 1);
		button.categoryName:SetJustifyH("LEFT");
	end

	button.categoryName:SetText(element.text);
	button.element = element;
	button:Show();
end

function CategoryListButton_OnClick(button)
	Categorylist_SelectButton(button);
	MountJournal_UpdateCollectionList();
end

function Categorylist_SelectButton(button)
	local id = button.element.id;
	local data = button.element;

	if data.func then
		C_MountJournal.ClearCategoryFilter();

		data.func()

		MountJournal.ListScrollFrame:Show()
		MountJournal.CategoryScrollFrame:Hide()
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)

		NavBar_Reset(MountJournal.navBar)
		local buttonData = {
			name = data.text
		};
		NavBar_AddButton(MountJournal.navBar, buttonData);
		return;
	end

	if data.sortID then
		C_MountJournal.SetCategoryFilter(data.sortID);

		local buttonData = {
			name = data.text
		};
		NavBar_AddButton(MountJournal.navBar, buttonData);

		MountJournal.ListScrollFrame:Show();
		MountJournal.CategoryScrollFrame:Hide();
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1);
	end

	if not data.isCategory then
		return;
	end

	if C_MountJournal.GetCategoryFilter() == id then
		C_MountJournal.ClearCategoryFilter();
		return;
	end
end

function MountColorButton_OnEnter(self)
	self.BorderHighlight:Show()

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")

	if GameTooltip:SetHyperlink("spell:"..self.colorData.spellID) then
		self.UpdateTooltip = MountColorButton_OnEnter
	else
		self.UpdateTooltip = nil
	end

	GameTooltip:Show()
end

function MountColorButton_OnLeave(self)
	self.BorderHighlight:Hide()
	GameTooltip:Hide()
end

function MountColorButton_OnClick(self)
	self.CheckGlow:Show()
	self.LockIcon.CheckGlow:Show()

	for i = 1, 7 do
		local button = _G["MountJournalButtomFrameMountButtonColor"..i]
		if button and button:GetID() ~= self:GetID() then
			button.CheckGlow:Hide()
			button.LockIcon.CheckGlow:Hide()
		end
	end
end