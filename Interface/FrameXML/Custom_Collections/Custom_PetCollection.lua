local CastSpellByID = CastSpellByID;

local PET_BUTTON_HEIGHT = 46;
local SUMMON_RANDOM_FAVORITE_PET_SPELL = 317619;

function PetJournal_OnLoad(self)
	Hook:RegisterCallback("COLLECTION", "PET_JOURNAL_LIST_UPDATE", function()
		PetJournal_FullUpdate(PetJournal);
	end)

	self.ListScrollFrame.update = PetJournal_UpdatePetList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "CompanionListButtonTemplate", 44, 0);

	UIDropDownMenu_Initialize(self.PetOptionsMenu, PetOptionsMenu_Init, "MENU");
end

function PetJournal_OnShow(self)
	local frameLevel = self:GetFrameLevel();
	self.LeftInset:SetFrameLevel(frameLevel);
	self.RightInset:SetFrameLevel(frameLevel);

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\PetJournalPortrait");

	PetJournal_FullUpdate(self);
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
			local hash, petID, petIndex, isOwned, isFavorite, name, icon, petType, spellID = C_PetJournal.GetPetInfoByIndex(index);

			pet.Name:SetText(name);
			pet.Icon:SetTexture(icon);
			pet.PetTypeIcon:SetTexture(GetPetTypeTexture(petType));

			pet.DragButton.Favorite:SetShown(isFavorite);

			if isOwned then
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

			pet.hash = hash;
			pet.petID = petID;
			pet.owned = isOwned;
			pet.petIndex = petIndex;
			pet.isSummoned = isSummoned;
			pet.index = index;
			pet.spellID = spellID;
			pet:Show();

			pet.SelectedTexture:SetShown(PetJournal.selectedPetID == petID);
		else
			pet:Hide();
		end
	end

	local totalHeight = numPets * PET_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());

	if not showPets then
		PetJournal.selectedPetID = nil;
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
		if self.owned and type(self.petIndex) == "number" then
			PetJournal_ShowPetDropdown(self.petID, self.petIndex, self, 80, 20);
		end
	else
		PetJournal_SelectByPetID(self.petID);
	end
end

function MountListItem_OnDoubleClick(self, button)
	if type(self.petIndex) == "number" and button == "LeftButton" then
		if self.isSummoned then
			DismissCompanion("CRITTER");
		else
			CallCompanion("CRITTER", self.petIndex);
		end
	end
end

function PetJournalDragButton_OnEnter(self)
	local parent = self:GetParent()
	local spellID = parent.spellID;
	if type(spellID) ~= "number" then
		return;
	end

	if type(parent.petIndex) ~= "number" then
		self.Highlight:Hide();
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
		local petIndex = parent.petIndex;

		if parent.owned and type(petIndex) == "number" then
			PetJournal_ShowPetDropdown(parent.petID, parent.petIndex, self, 0, 0);
		end
	else
		PetJournalDragButton_OnDragStart(self);
	end
end

function PetJournalDragButton_OnDragStart(self)
	local petIndex = self:GetParent().petIndex;
	if type(petIndex) ~= "number" then
		return;
	end

	PickupCompanion("CRITTER", petIndex);
end

function PetJournalDragButton_OnEvent(self, event, ...)
	local petIndex = self:GetParent().petIndex;
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
	local _, petID = C_PetJournal.GetPetInfoByIndex(index);
	PetJournal_SetSelected(petID);
end

function PetJournal_SelectByPetID(petID)
	PetJournal_SetSelected(petID);
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
		local _, currentPetID = C_PetJournal.GetPetInfoByIndex(i);
		if currentPetID == petID then
			return i;
		end
	end
end

function PetJournal_SetSelected(selectedPetID)
	if PetJournal.selectedPetID ~= selectedPetID then
		PetJournal.selectedPetID = selectedPetID;
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

		local hash, petIndex, isFavorite, name, icon, petType, lootType, currency, price, creatureID, spellID, itemID, sourceText, descriptionText = C_PetJournal.GetPetInfoByPetID(PetJournal.selectedPetID);
		if IsGMAccount() then
			PetJournal.PetDisplay.ModelScene.DebugInfo:SetFormattedText("CreatureID: %s", creatureID);
			PetJournal.PetDisplay.ModelScene.DebugInfo:Show();
		else
			PetJournal.PetDisplay.ModelScene.DebugInfo:Hide();
		end
		PetJournal.PetDisplay.ModelScene.DebugFrame:SetShown(IsGMAccount());

		PetJournal.PetDisplay.InfoButton.Name:SetText(name);
		PetJournal.PetDisplay.InfoButton.Icon:SetTexture(icon);

		PetJournal.PetDisplay.InfoButton.Source:SetText(sourceText);
		PetJournal.PetDisplay.InfoButton.Lore:SetText(descriptionText);

		PetJournal.PetDisplay.ModelScene:SetCreature(creatureID);

		if lootType == 16 then
			PetJournal.PetDisplay.ModelScene.BuyFrame:SetShown(BattlePassFrame:GetEndTime() ~= 0 and not petIndex);
			PetJournal.PetDisplay.ModelScene.BuyFrame.BuyButton:SetText(GO_TO_BATTLE_BASS);
			PetJournal.PetDisplay.ModelScene.BuyFrame.BuyButton:SetEnabled(true);
			PetJournal.PetDisplay.ModelScene.BuyFrame.PriceText:SetText("");
			PetJournal.PetDisplay.ModelScene.BuyFrame.MoneyIcon:SetTexture("");
		elseif currency and currency ~= 0 then
			PetJournal.PetDisplay.ModelScene.BuyFrame:SetShown(not petIndex);

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
		local hash = C_PetJournal.GetPetInfoByPetID(PetJournal.selectedPetID);
		local _, _, name, icon, _, lootType, currency, price, productID = C_PetJournal.GetPetInfoByPetHash(hash);

		if name then
			if lootType == 16 then
				BattlePassFrame:Show();
			else
				local productData = {
					Texture = icon,
					Name = name,
					Price = price,
					ID = productID,
					currency = currency
				};

				StoreFrame_ProductBuyWithOpenPage(productData);
			end
		end
	end
end

function PetJournalFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, PetJournalFilterDropDown_Initialize, "MENU");
end

function PetJournalFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	if level == 1 then
		info.text = COLLECTED
		info.func = 	function(_, _, _, value)
			C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, value);
		end
		info.checked = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);

		info.disabled = nil;

		info.text = NOT_COLLECTED;
		info.func = 	function(_, _, _, value)
			C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value);
		end
		info.checked = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED);
		info.isNotRadio = true;
		UIDropDownMenu_AddButton(info, level);

		info.checked = 	nil;
		info.isNotRadio = nil;
		info.func =  nil;
		info.hasArrow = true;
		info.notCheckable = true;

		info.text = PET_FAMILIES;
		info.value = 1;
		UIDropDownMenu_AddButton(info, level);

		info.text = SOURCES;
		info.value = 2;
		UIDropDownMenu_AddButton(info, level);

		info.text = EXPANSION_FILTER_TEXT;
		info.value = 3;
		UIDropDownMenu_AddButton(info, level);

		info.text = STORE_TRANSMOGRIFY_FILTER_SORT_TITLE;
		info.value = 4;
		UIDropDownMenu_AddButton(info, level);

	else --if level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL;
			info.func = function()
				C_PetJournal.SetAllPetTypesChecked(true);
				UIDropDownMenu_Refresh(PetJournalFilterDropDown, 1, 2);
			end
			UIDropDownMenu_AddButton(info, level);

			info.text = UNCHECK_ALL;
			info.func = function()
				C_PetJournal.SetAllPetTypesChecked(false);
				UIDropDownMenu_Refresh(PetJournalFilterDropDown, 1, 2);
			end
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = false;
			local numTypes = C_PetJournal.GetNumPetTypes();
			for i = 1,numTypes do
				info.text = _G["COLLECTION_PET_NAME_"..i];
				info.func = function(_, _, _, value)
					C_PetJournal.SetPetTypeFilter(i, value);
				end
				info.checked = function() return C_PetJournal.IsPetTypeChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL;
			info.func = function()
				C_PetJournal.SetAllPetSourcesChecked(true);
				UIDropDownMenu_Refresh(PetJournalFilterDropDown, 2, 2);
			end
			UIDropDownMenu_AddButton(info, level);

			info.text = UNCHECK_ALL;
			info.func = function()
				C_PetJournal.SetAllPetSourcesChecked(false);
				UIDropDownMenu_Refresh(PetJournalFilterDropDown, 2, 2);
			end
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = false;
			local numSources = C_PetJournal.GetNumPetSources();
			for i = 1,numSources do
				info.text = _G["COLLECTION_PET_SOURCE_"..i];
				info.func = function(_, _, _, value)
					C_PetJournal.SetPetSourceChecked(i, value);
				end
				info.checked = function() return C_PetJournal.IsPetSourceChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 3 then
			info.hasArrow = false;
			info.isNotRadio = true;
			info.notCheckable = true;

			info.text = CHECK_ALL;
			info.func = function()
				C_PetJournal.SetAllPetExpansionsChecked(true);
				UIDropDownMenu_Refresh(PetJournalFilterDropDown, 2, 2);
			end
			UIDropDownMenu_AddButton(info, level);

			info.text = UNCHECK_ALL;
			info.func = function()
				C_PetJournal.SetAllPetExpansionsChecked(false);
				UIDropDownMenu_Refresh(PetJournalFilterDropDown, 2, 2);
			end
			UIDropDownMenu_AddButton(info, level);

			info.notCheckable = false;
			local numExpansions = C_PetJournal.GetNumPetExpansions();
			for i = 1,numExpansions do
				info.text = string.format("World of Warcraft: %s", S_EXPANSION_DATA[i - 1]);
				info.func = function(_, _, _, value)
					C_PetJournal.SetPetExpansionChecked(i, value);
				end
				info.checked = function() return C_PetJournal.IsPetExpansionChecked(i) end;
				UIDropDownMenu_AddButton(info, level);
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 4 then
			info.hasArrow = false;
			info.isNotRadio = nil;
			info.notCheckable = nil;
			info.keepShownOnClick = nil;

			info.text = NAME;
			info.func = function()
				C_PetJournal.SetPetSortParameter(LE_SORT_BY_NAME);
				PetJournal_UpdatePetList();
			end
			info.checked = function() return C_PetJournal.GetPetSortParameter() == LE_SORT_BY_NAME end;
			UIDropDownMenu_AddButton(info, level);

			info.text = TYPE;
			info.func = function()
				C_PetJournal.SetPetSortParameter(LE_SORT_BY_PETTYPE);
				PetJournal_UpdatePetList();
			end
			info.checked = function() return C_PetJournal.GetPetSortParameter() == LE_SORT_BY_PETTYPE end;
			UIDropDownMenu_AddButton(info, level);
		end
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