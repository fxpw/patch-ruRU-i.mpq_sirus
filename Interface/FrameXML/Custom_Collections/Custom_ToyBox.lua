local TOYS_PER_PAGE = 18;

function ToyBox_OnLoad(self)
	self.autoPageToCollectedToyID = UIParent.autoPageToCollectedToyID or nil;
	self.newToys = {};

	ToyBox_UpdatePages();
	ToyBox_UpdateProgressBar(self);

	UIDropDownMenu_Initialize(self.ToyOptionsMenu, ToyBoxOptionsMenu_Init, "MENU");

	self:RegisterCustomEvent("TOYS_UPDATED");

	self.OnPageChanged = function()
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		ToyBox_UpdateButtons();
	end

	self.IconsFrame.Watermark:SetAtlas("collections-watermark-toy", true);

	self.FilterButton:SetResetFunction(ToyBoxFilterDropDown_ResetFilters);
end

function ToyBox_OnEvent(self, event, itemID, new)
	if event == "TOYS_UPDATED" then
		if new then
			self.newToys[itemID] = true;
			self.autoPageToCollectedToyID = itemID;

			if not CollectionsJournal:IsShown() then
				CollectionsJournal_SetTab(CollectionsJournal, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
			end
		end

		ToyBox_UpdatePages();
		ToyBox_UpdateProgressBar(self);
		ToyBox_UpdateButtons();
	end
end

function ToyBox_OnShow(self)
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\Trade_Archaeology_ChestofTinyGlassAnimals");
	C_ToyBox.ForceToyRefilter();

	ToyBox_UpdatePages();
	ToyBox_UpdateProgressBar(self);
	ToyBox_UpdateButtons();

	ToyBoxResetFiltersButton_UpdateVisibility();
	EventRegistry:TriggerEvent("ToyBox.OnShow")
end

function ToyBox_FindPageForToyID(toyID)
	for i = 1, C_ToyBox.GetNumFilteredToys() do
		if C_ToyBox.GetToyFromIndex(i) == toyID then
			return math.floor((i - 1) / TOYS_PER_PAGE) + 1;
		end
	end

	return nil;
end

function ToyBox_OnMouseWheel(self, value)
	ToyBox.PagingFrame:OnMouseWheel(value);
end

function ToyBoxOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.disabled = nil;

	local isFavorite = ToyBox.menuItemID and C_ToyBox.GetIsFavorite(ToyBox.menuItemID);

	if isFavorite then
		info.text = BATTLE_PET_UNFAVORITE;
		info.func = function()
			C_ToyBox.SetIsFavorite(ToyBox.menuItemID, false);
		end
	else
		info.text = BATTLE_PET_FAVORITE;
		info.func = function()
			C_ToyBox.SetIsFavorite(ToyBox.menuItemID, true);
		end
	end

	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;

	info.text = CANCEL;
	info.func = nil;
	UIDropDownMenu_AddButton(info, level);
end

function ToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)
	ToyBox.menuItemID = itemID;
	ToggleDropDownMenu(1, nil, ToyBox.ToyOptionsMenu, anchorTo, offsetX, offsetY);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function ToyBox_HideToyDropdown()
	if UIDropDownMenu_GetCurrentDropDown() == ToyBox.ToyOptionsMenu then
		HideDropDownMenu(1);
	end
end

function ToySpellButton_OnShow(self)
	self:RegisterEvent("TOYS_UPDATED");

	CollectionsSpellButton_OnShow(self);
end

function ToySpellButton_OnHide(self)
	CollectionsSpellButton_OnHide(self);

	self:UnregisterEvent("TOYS_UPDATED");
end

function ToySpellButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if GameTooltip:SetToyByItemID(self.itemID) then
		self.UpdateTooltip = ToySpellButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end

	local isNew = ToyBox.newToys[self.itemID] ~= nil;
	if isNew then
		ToyBox.newToys[self.itemID] = nil;
	end
end

function ToySpellButton_OnClick(self, button)
	if button == "LeftButton" then
		SecureActionButton_OnClick(self, button);
	elseif button == "RightButton" then
		if PlayerHasToy(self.itemID) then
			ToyBox_ShowToyDropdown(self.itemID, self, 0, 0);
		end
	end
end

function ToySpellButton_OnModifiedClick(self, button)
	if IsModifiedClick("CHATLINK") then
		if MacroFrame and MacroFrame:IsShown() then
			ChatEdit_InsertLink(GetSpellInfo(self.spellID));
		else
			local itemLink = C_ToyBox.GetToyLink(self.itemID);
			if itemLink then
				ChatEdit_InsertLink(itemLink);
			end
		end
	end
end

function ToySpellButton_OnDrag(self)
	local spellID = self:GetAttribute("spell");
	if spellID then
		local spellIndex = SpellBook_GetSpellIndex(spellID, BOOKTYPE_SPELL);
		if spellIndex then
			PickupSpell(spellIndex, BOOKTYPE_SPELL);
		end
	end
end

function ToySpellButton_UpdateButton(self)
	local itemIndex = (ToyBox.PagingFrame:GetCurrentPage() - 1) * TOYS_PER_PAGE + self:GetID();
	local itemID, spellID = C_ToyBox.GetToyFromIndex(itemIndex);
	self.itemID = itemID;
	self.spellID = spellID;

	if self.itemID == -1 then
		self:SetAttribute("type", nil);
		self:SetAttribute("spell", nil);
		self:Hide();
		return;
	end

	self:Show();

	local _, _, toyName, icon, isFavorite = C_ToyBox.GetToyInfo(self.itemID);
	if itemID == nil or toyName == nil then
		return;
	end

	if string.len(toyName) == 0 then
		toyName = itemID;
		self:SetAttribute("type", nil);
		self:SetAttribute("spell", nil);
	else
		self:SetAttribute("type", "spell");
		self:SetAttribute("spell", spellID);
	end

	if not ToyBox.newToys[self.itemID] then
		self.New:Hide();
		self.NewGlow:Hide();
	else
		self.New:Show();
		self.NewGlow:Show();
	end

	if PlayerHasToy(self.itemID) then
		self.IconTexture:SetTexture(icon);
		self.IconTexture:Show();
		self.IconTextureUncollected:Hide();
		self.Name:SetTextColor(1, 0.82, 0, 1);
		self.Name:SetShadowColor(0, 0, 0, 1);
		self.SlotFrameCollected:Show();
		self.SlotFrameUncollected:Hide();
		self.SlotFrameUncollectedInnerGlow:Hide();
	else
		self.IconTexture:Hide();
		self.IconTextureUncollected:SetTexture(icon);
		self.IconTextureUncollected:SetDesaturated(true);
		self.IconTextureUncollected:Show();
		self.Name:SetTextColor(0.33, 0.27, 0.20, 1);
		self.Name:SetShadowColor(0, 0, 0, 0.33);
		self.SlotFrameCollected:Hide();
		self.SlotFrameUncollected:Show();
		self.SlotFrameUncollectedInnerGlow:Show();
	end

	if C_ToyBox.GetIsFavorite(itemID) then
		self.CooldownWrapper.SlotFavorite:Show();
	else
		self.CooldownWrapper.SlotFavorite:Hide();
	end

	CollectionsSpellButton_UpdateCooldown(self);

	self.Name:SetText(toyName);
end

function ToyBox_UpdateButtons()
	for i = 1, TOYS_PER_PAGE do
	    local button = ToyBox.IconsFrame["SpellButton"..i];
		ToySpellButton_UpdateButton(button);
	end
end

function ToyBox_UpdatePages()
	local maxPages = 1 + math.floor(math.max((C_ToyBox.GetNumFilteredToys() - 1), 0) / TOYS_PER_PAGE);
	ToyBox.PagingFrame:SetMaxPages(maxPages);

	if ToyBox.autoPageToCollectedToyID then
		local toyPage = ToyBox_FindPageForToyID(ToyBox.autoPageToCollectedToyID);
		if toyPage then
			ToyBox.PagingFrame:SetCurrentPage(toyPage);
		end
		ToyBox.autoPageToCollectedToyID = nil;
	end
end

function ToyBox_UpdateProgressBar(self)
	local maxProgress = C_ToyBox.GetNumTotalDisplayedToys();
	local currentProgress = C_ToyBox.GetNumLearnedDisplayedToys();

	self.ProgressBar:SetMinMaxValues(0, maxProgress);
	self.ProgressBar:SetValue(currentProgress);

	self.ProgressBar.Text:SetFormattedText(TOY_PROGRESS_FORMAT, currentProgress, maxProgress);
end

function ToyBox_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	local oldText = ToyBox.searchString;
	ToyBox.searchString = self:GetText();

	if oldText ~= ToyBox.searchString then
		C_ToyBox.SetFilterString(ToyBox.searchString);
	end
end

function ToyBoxFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, ToyBoxFilterDropDown_Initialize, "MENU");
end

function ToyBoxFilterDropDown_ResetFilters()
	C_ToyBoxInfo.SetDefaultFilters();
	ToyBox.FilterButton.ResetButton:Hide();
end

function ToyBoxResetFiltersButton_UpdateVisibility()
	ToyBox.FilterButton.ResetButton:SetShown(not C_ToyBoxInfo.IsUsingDefaultFilters());
end

function ToyBoxFilterDropDown_SetAllSourceTypeFilters(value)
	C_ToyBox.SetAllSourceTypeFilters(value);
	UIDropDownMenu_Refresh(ToyBoxFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function ToyBoxFilterDropDown_Initialize(self, level)
	local filterSystem = {
		onUpdate = ToyBoxResetFiltersButton_UpdateVisibility,
		filters = {
			{ type = FilterComponent.Checkbox, text = COLLECTED, set = C_ToyBox.SetCollectedShown, isSet = C_ToyBox.GetCollectedShown },
			{ type = FilterComponent.Checkbox, text = NOT_COLLECTED, set = C_ToyBox.SetUncollectedShown, isSet = C_ToyBox.GetUncollectedShown },
			{ type = FilterComponent.Submenu, text = SOURCES, value = 1, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() ToyBoxFilterDropDown_SetAllSourceTypeFilters(true); end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() ToyBoxFilterDropDown_SetAllSourceTypeFilters(false); end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_ToyBox.SetSourceTypeFilter,
						  isSet = C_ToyBox.IsSourceTypeFilterChecked,
						  numFilters = C_PetJournal.GetNumPetSources,
						  filterValidation = C_ToyBoxInfo.IsToySourceValid,
						  globalPrepend = "COLLECTION_PET_SOURCE_",
						},
					},
				},
			},
		},
	};

	FilterDropDownSystem.Initialize(self, filterSystem, level);
end
