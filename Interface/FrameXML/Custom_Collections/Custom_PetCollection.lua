local CastSpellByID = CastSpellByID;

local PET_BUTTON_HEIGHT = 46;
local SUMMON_RANDOM_FAVORITE_PET_SPELL = 317619;

function PetJournal_OnLoad(self)
	self:RegisterCustomEvent("PET_JOURNAL_LIST_UPDATE");

	self.ListScrollFrame.update = PetJournal_UpdatePetList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CompanionListButtonTemplate", 44, 0);

	UIDropDownMenu_Initialize(self.PetOptionsMenu, PetOptionsMenu_Init, "MENU");

	self.FilterButton:SetResetFunction(PetJournalFilterDropDown_ResetFilters);
end

function PetJournal_OnShow(self)
	local frameLevel = self:GetFrameLevel();
	self.LeftInset:SetFrameLevel(frameLevel);
	self.RightInset:SetFrameLevel(frameLevel);

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\PetJournalPortrait");

	PetJournal_FullUpdate(self);

	PetJournalResetFiltersButton_UpdateVisibility();
	EventRegistry:TriggerEvent("PetJournal.OnShow")
end

function PetJournal_OnEvent(self, event)
	if event == "PET_JOURNAL_LIST_UPDATE" then
		PetJournal_FullUpdate(self);
	end
end

function PetJournalSummonRandomFavoritePetButton_OnLoad(self)
	self.spellID = SUMMON_RANDOM_FAVORITE_PET_SPELL;
	local _, _, spellIcon = GetSpellInfo(self.spellID);
	self.IconTexture:SetTexture(spellIcon);
	self.SpellName:SetText(PET_JOURNAL_SUMMON_RANDOM_FAVORITE_PET);
	self:RegisterForDrag("LeftButton");
end

function PetJournalSummonRandomFavoritePetButton_OnShow(self)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	PetJournalSummonRandomFavoritePetButton_UpdateCooldown(self);
end

function PetJournalSummonRandomFavoritePetButton_OnHide(self)
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
end

function PetJournalSummonRandomFavoritePetButton_UpdateCooldown(self)
	local start, duration, enable = GetSpellCooldown(self.spellID);
	CooldownFrame_SetTimer(self.Cooldown, start, duration, enable);
end

function PetJournalSummonRandomFavoritePetButton_OnEvent(self, event, ...)
	if event == "SPELL_UPDATE_COOLDOWN" then
		PetJournalSummonRandomFavoritePetButton_UpdateCooldown(self);
		-- Update tooltip
		if GameTooltip:GetOwner() == self then
			PetJournalSummonRandomFavoritePetButton_OnEnter(self);
		end
	end
end

function PetJournalSummonRandomFavoritePetButton_OnClick(self)
	CastSpellByID(self.spellID);
end

function PetJournalSummonRandomFavoritePetButton_OnDragStart(self)
	local spellName = GetSpellInfo(self.spellID);
	PickupSpell(spellName);
end

function PetJournalSummonRandomFavoritePetButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID);
end

function PetJournalSummonRandomFavoritePetButton_OnLeave(self)
	GameTooltip:Hide();
end

function PetJournal_FullUpdate(self)
	if self:IsVisible() then
		PetJournal_UpdatePetList();

		if not self.selectedPetID then
			PetJournal_SelectByIndex(1);
		end

		PetJournal_UpdatePetDisplay();
		PetJournal_UpdateSummonButtonState();
	end
end

function PetJournal_UpdatePetList()
	local scrollFrame = PetJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local petButtons = scrollFrame.buttons;
	local showPets, pet, index = true;

	local numPets, numOwned = C_PetJournal.GetNumPets();
	if numPets < 1 then
		showPets = false;
	end
	PetJournal.PetCount.Count:SetFormattedText("%d / %d", numOwned, numPets);

	local summonedPetID = C_PetJournal.GetSummonedPetID();

	for i = 1, #petButtons do
		pet = petButtons[i];
		index = offset + i;

		if index <= numPets and showPets then
			local name, spellID, icon, petType, active, _, isFavorite, isCollected, petID, _, itemID = C_PetJournal.GetPetInfoByIndex(index);

			pet.Name:SetText(name);
			pet.Icon:SetTexture(icon);
			pet.PetTypeIcon:SetTexture(GetPetTypeTexture(petType));

			pet.DragButton.Favorite:SetShown(isFavorite);

			if isCollected then
				pet.Icon:SetDesaturated(false);
				pet.Name:SetFontObject("GameFontNormal");
				pet.PetTypeIcon:SetDesaturated(false);

				local _, errorType = C_PetJournal.GetPetSummonInfo(petID);
				if errorType and errorType ~= 0 then
					pet.Background:SetVertexColor(1, 0, 0);
					pet.Icon:SetVertexColor(150/255, 50/255, 50/255);
				else
					pet.Background:SetVertexColor(1, 1, 1);
					pet.Icon:SetVertexColor(1, 1, 1);
				end
			else
				pet.Icon:SetDesaturated(true);
				pet.Name:SetFontObject("GameFontDisable");
				pet.PetTypeIcon:SetDesaturated(true);

				pet.Background:SetVertexColor(1, 1, 1);
				pet.Icon:SetVertexColor(1, 1, 1);
			end

			local isSummoned = petID and petID == summonedPetID;
			pet.DragButton.ActiveTexture:SetShown(isSummoned);

			pet.petID = petID;
			pet.isCollected = isCollected;
			pet.isSummoned = isSummoned;
			pet.index = index;
			pet.spellID = spellID;
			pet:Show();

			pet.SelectedTexture:SetShown(PetJournal.selectedItemID == itemID);
		else
			pet:Hide();
		end
	end

	local totalHeight = numPets * PET_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());

	if not showPets then
		PetJournal.selectedPetID = nil;
		PetJournal.selectedItemID = nil;
		PetJournal_UpdatePetDisplay();
	end
end

function PetJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_PetJournal.SetSearchFilter(self:GetText());
end

function PetJournalListItem_OnClick(self, button)
	if IsModifiedClick("CHATLINK") then
		local spellID = self.spellID;

		if type(spellID) == "number" then
			if MacroFrame and MacroFrame:IsShown() then
				ChatEdit_InsertLink(GetSpellInfo(spellID));
			else
				ChatEdit_InsertLink(C_PetJournal.GetPetLink(self.petID));
			end
		end
	elseif button == "RightButton" then
		if self.isCollected then
			local petIndex = C_PetJournal.GetPetCompanionIndex(self.petID);
			if petIndex then
				PetJournal_ShowPetDropdown(self.petID, petIndex, self, 80, 20);
			end
		end
	else
		PetJournal_SelectByPetID(self.petID);
	end
end

function MountListItem_OnDoubleClick(self, button)
	if self.isCollected and button == "LeftButton" then
		if self.isSummoned then
			DismissCompanion("CRITTER");
		else
			local petIndex = C_PetJournal.GetPetCompanionIndex(self.petID);
			if petIndex then
				CallCompanion("CRITTER", petIndex);
			end
		end
	end
end

function PetJournalDragButton_OnEnter(self)
	local parent = self:GetParent()
	local spellID = parent.spellID;
	if type(spellID) ~= "number" then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(string.format("spell:%d", spellID));
	GameTooltip:Show();
end

function PetJournalDragButton_OnClick(self, button)
	if IsModifiedClick("CHATLINK") then
		local spellID = self:GetParent().spellID;

		if type(spellID) == "number" then
			if MacroFrame and MacroFrame:IsShown() then
				ChatEdit_InsertLink(GetSpellInfo(spellID));
			else
				ChatEdit_InsertLink(C_PetJournal.GetPetLink(self:GetParent().petID));
			end
		end
	elseif button == "RightButton" then
		local parent = self:GetParent();
		local petIndex = C_PetJournal.GetPetCompanionIndex(parent.petID);

		if parent.isCollected and petIndex then
			PetJournal_ShowPetDropdown(parent.petID, petIndex, self, 0, 0);
		end
	else
		PetJournalDragButton_OnDragStart(self);
	end
end

function PetJournalDragButton_OnDragStart(self)
	local petIndex = C_PetJournal.GetPetCompanionIndex(self:GetParent().petID);
	if not petIndex then
		return;
	end

	PickupCompanion("CRITTER", petIndex);
end

function PetJournalDragButton_OnEvent(self, event, ...)
	local petIndex = C_PetJournal.GetPetCompanionIndex(self:GetParent().petID);
	if event == "SPELL_UPDATE_COOLDOWN" and type(petIndex) == "number" then
		local start, duration, enable = GetCompanionCooldown("CRITTER", petIndex);
		if start and duration and enable then
			CooldownFrame_SetTimer(self.Cooldown, start, duration, enable);
		end
	end
end

function PetJournal_ShowPetDropdown(petID, petIndex, anchorTo, offsetX, offsetY)
	PetJournal.menuPetID = petID;
	PetJournal.menuPetIndex = petIndex;
	ToggleDropDownMenu(1, nil, PetJournal.PetOptionsMenu, anchorTo, offsetX, offsetY);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function PetJournal_SelectByIndex(index)
	local _, _, _, _, _, _, _, _, petID, _, itemID = C_PetJournal.GetPetInfoByIndex(index);
	PetJournal_SetSelected(petID, itemID);
end

function PetJournal_SelectByPetID(petID)
	local itemID = select(11, C_PetJournal.GetPetInfoByPetID(petID));
	PetJournal_SetSelected(petID, itemID);
end

function PetJournal_GetPetButtonHeight()
	return PET_BUTTON_HEIGHT;
end

function PetJournal_GetPetButtonByPetID(petID)
	local buttons = PetJournal.ListScrollFrame.buttons;

	for i = 1, #buttons do
		local button = buttons[i];
		if button.petID == petID then
			return button;
		end
	end
end

local function GetPetDisplayIndexByPetID(petID)
	for i = 1, C_PetJournal.GetNumPets() do
		local currentPetID = select(9, C_PetJournal.GetPetInfoByIndex(i));
		if currentPetID == petID then
			return i;
		end
	end
end

function PetJournal_SetSelected(selectedPetID, selectedItemID)
	if PetJournal.selectedPetID ~= selectedPetID or (selectedItemID and PetJournal.selectedItemID ~= selectedItemID) then
		PetJournal.selectedPetID = selectedPetID;
		PetJournal.selectedItemID = selectedItemID;
		PetJournal_UpdatePetDisplay();
		PetJournal_UpdatePetList();

		local inView = PetJournal_GetPetButtonByPetID(selectedPetID) ~= nil;
		if not inView then
			local petIndex = GetPetDisplayIndexByPetID(selectedPetID);
			if petIndex then
				HybridScrollFrame_ScrollToIndex(PetJournal.ListScrollFrame, petIndex, PetJournal_GetPetButtonHeight);
			end
		end
	end

	PetJournal_UpdateSummonButtonState();
end

function PetJournal_UpdatePetDisplay()
	if PetJournal.selectedPetID then
		PetJournal.PetDisplay.ModelScene:Show();
		PetJournal.PetDisplay.InfoButton:Show();

		local name, spellID, icon, petType, active, sourceType, isFavorite, isCollected, petID, creatureID, itemID, currency, price, _, priceText, descriptionText, holidayText = C_PetJournal.GetPetInfoByPetID(PetJournal.selectedPetID);
		PetJournal.PetDisplay.InfoButton.Name:SetText(name);
		PetJournal.PetDisplay.InfoButton.Icon:SetTexture(icon);

		PetJournal.PetDisplay.InfoButton.Source:SetText(priceText);
		PetJournal.PetDisplay.InfoButton.Source:SetFormattedText("%s%s", holidayText ~= "" and string.format("%s\n", holidayText) or "", priceText);
		PetJournal.PetDisplay.InfoButton.Lore:SetText(descriptionText);

		PetJournal.PetDisplay.ModelScene:SetCreature(creatureID);

		if sourceType == 16 then
			PetJournal.PetDisplay.ModelScene.BuyFrame:SetShown(C_BattlePass.GetSeasonTimeLeft() > 0 and not isCollected);
			PetJournal.PetDisplay.ModelScene.BuyFrame.BuyButton:SetText(GO_TO_BATTLE_BASS);
			PetJournal.PetDisplay.ModelScene.BuyFrame.BuyButton:SetEnabled(true);
			PetJournal.PetDisplay.ModelScene.BuyFrame.PriceText:SetText("");
			PetJournal.PetDisplay.ModelScene.BuyFrame.MoneyIcon:SetTexture("");
		elseif currency and currency ~= 0 then
			PetJournal.PetDisplay.ModelScene.BuyFrame:SetShown(not isCollected);

			if currency == 4 then
				PetJournal.PetDisplay.ModelScene.BuyFrame.BuyButton:SetText(PICK_UP);
			else
				PetJournal.PetDisplay.ModelScene.BuyFrame.BuyButton:SetText(GO_TO_STORE);
			end

			PetJournal.PetDisplay.ModelScene.BuyFrame.MoneyIcon:SetTexture("Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[currency]);
			PetJournal.PetDisplay.ModelScene.BuyFrame.PriceText:SetText(price);
		else
			PetJournal.PetDisplay.ModelScene.BuyFrame:Hide();
		end

		if itemID then
			local canOpened = LootJournal_CanOpenItemByEntry(itemID, true);

			PetJournal.PetDisplay.ModelScene.EJFrame.OpenEJButton.itemID = itemID;
			PetJournal.PetDisplay.ModelScene.EJFrame:SetShown(canOpened);
		else
			PetJournal.PetDisplay.ModelScene.EJFrame:Hide();
		end

		PetJournal.PetDisplay.InfoButton.FavoriteButton:SetChecked(isFavorite and true or false);
	else
		PetJournal.PetDisplay.ModelScene:Hide();
		PetJournal.PetDisplay.InfoButton:Hide();
	end
end

function PetJournal_UpdateSummonButtonState()
	local petID = PetJournal.selectedPetID;

	PetJournal.SummonButton:SetEnabled(petID and C_PetJournal.PetIsSummonable(petID));

	if petID and petID == C_PetJournal.GetSummonedPetID() then
		PetJournal.SummonButton:SetText(PET_DISMISS);
	else
		PetJournal.SummonButton:SetText(SUMMON);
	end
end

function GetPetTypeTexture(petType)
	if PET_TYPE_SUFFIX[petType] then
		return "Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType];
	else
		return "Interface\\PetBattles\\PetIcon-NO_TYPE";
	end
end

function PetJournalBuyButton_OnClick()
	HideUIPanel(CollectionsJournal);

	if PetJournal.selectedPetID then
		local name, _, icon, _, _, sourceType, _, _, _, _, itemID, currencyType, price, productID = C_PetJournal.GetPetInfoByPetID(PetJournal.selectedPetID);

		if name then
			if sourceType == 16 then
				BattlePassFrame:ShowCardWithItem(itemID);
			elseif currencyType and currencyType ~= 0 then
				local categoryIndex, subCategoryIndex = C_StoreSecure.GetVirtualCategoryByRemoteID(currencyType, 0, 0)
				StoreFrame:ShowProductCategory(productID, categoryIndex, subCategoryIndex)
			end
		end
	end
end

function PetJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PetJournalFilterDropDown_Initialize, "MENU");
end

function PetJournalFilterDropDown_ResetFilters()
	C_PetJournal.SetDefaultFilters();
	PetJournal.FilterButton.ResetButton:Hide();
end

function PetJournalResetFiltersButton_UpdateVisibility()
	PetJournal.FilterButton.ResetButton:SetShown(not C_PetJournal.IsUsingDefaultFilters());
end

function PetJournalFilterDropDown_SetCollectedFilter(value)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, value);
end

function PetJournalFilterDropDown_GetCollectedFilter()
	return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED);
end

function PetJournalFilterDropDown_SetNotCollectedFilter(value)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value);
end

function PetJournalFilterDropDown_GetNotCollectedFilter()
	return C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED);
end

function PetJournalFilterDropDown_SetAllPetTypes(value)
	C_PetJournal.SetAllPetTypesChecked(value);
	UIDropDownMenu_Refresh(PetJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function PetJournalFilterDropDown_SetAllPetSources(value)
	C_PetJournal.SetAllPetSourcesChecked(value);
	UIDropDownMenu_Refresh(PetJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function PetJournalFilterDropDown_Initialize(self, level)
	local filterSystem = {
		onUpdate = PetJournalResetFiltersButton_UpdateVisibility,
		filters = {
			{ type = FilterComponent.Checkbox, text = COLLECTED, set= PetJournalFilterDropDown_SetCollectedFilter, isSet = PetJournalFilterDropDown_GetCollectedFilter, },
			{ type = FilterComponent.Checkbox, text = NOT_COLLECTED, set = PetJournalFilterDropDown_SetNotCollectedFilter, isSet = PetJournalFilterDropDown_GetNotCollectedFilter, },
			{ type = FilterComponent.Submenu, text = PET_FAMILIES, value = 1, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() PetJournalFilterDropDown_SetAllPetTypes(true); end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() PetJournalFilterDropDown_SetAllPetTypes(false); end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_PetJournal.SetPetTypeFilter,
						  isSet = C_PetJournal.IsPetTypeChecked,
						  numFilters = C_PetJournal.GetNumPetTypes,
						  globalPrepend = "COLLECTION_PET_NAME_",
						},
					},
				},
			},
			{ type = FilterComponent.Submenu, text = SOURCES, value = 2, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton,
						  text = CHECK_ALL,
						  set = function() PetJournalFilterDropDown_SetAllPetSources(true); end,
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() PetJournalFilterDropDown_SetAllPetSources(false); end,
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox,
						  set = C_PetJournal.SetPetSourceChecked,
						  isSet = C_PetJournal.IsPetSourceChecked,
						  numFilters = C_PetJournal.GetNumPetSources,
						  globalPrepend = "COLLECTION_PET_SOURCE_",
						},
					},
				},
			},
			{ type = FilterComponent.Submenu, text = TRANSMOGRIFY_FILTER_SORT_TITLE, value = 3, childrenInfo = {
					filters = {
						{ type = FilterComponent.CustomFunction, customFunc = PetJournalFilterDropDown_AddInSortParameters, },
					},
				},
			},
		},
	};

	FilterDropDownSystem.Initialize(self, filterSystem, level);
end

function PetJournalFilterDropDown_AddInSortParameters(filterSystem, level)
	local sortParameters = {
		{ text = NAME, parameter = LE_SORT_BY_NAME, },
		{ text = TYPE, parameter = LE_SORT_BY_PETTYPE, },
	};

	for index, sortParameter in ipairs(sortParameters) do
		local setSelected = function()
			C_PetJournal.SetPetSortParameter(sortParameter.parameter);
		end
		local isSelected = function() return C_PetJournal.GetPetSortParameter() == sortParameter.parameter end;
		FilterDropDownSystem.AddRadioButtonToFilterSystem(filterSystem, sortParameter.text, setSelected, isSelected, level);
	end
end

function PetOptionsMenu_Init(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	info.text = SUMMON;
	if PetJournal.menuPetID and C_PetJournal.GetSummonedPetID() == PetJournal.menuPetID then
		info.text = PET_DISMISS;
	end
	info.func = function() C_PetJournal.SummonPetByPetID(PetJournal.menuPetID); end
	if PetJournal.menuPetID and not C_PetJournal.PetIsSummonable(PetJournal.menuPetID) then
		info.disabled = true;
	end
	UIDropDownMenu_AddButton(info, level);
	info.disabled = nil;

	if PetJournal.menuPetIndex then
		local isFavorite = PetJournal.menuPetID and C_PetJournal.PetIsFavorite(PetJournal.menuPetID);
		if isFavorite then
			info.text = DELETE_FAVORITE;
			info.func = function()
				C_PetJournal.SetFavorite(PetJournal.menuPetID, false);
			end
		else
			info.text = ADD_TO_FAVORITE;
			info.func = function()
				C_PetJournal.SetFavorite(PetJournal.menuPetID, true);
			end
		end
		UIDropDownMenu_AddButton(info, level);
	end

	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end