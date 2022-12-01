local mountTypeStrings = {
	[1] = MOUNT_GROUND,
	[2] = MOUNT_FLY,
	[3] = MOUNT_WATER,
};

local SUB_CATEGORY_COLLECTIONS = -1;
local SUB_CATEGORY_FAVORITES = -2;

local categoryData = {
	{
		text = MY_COLLECTIONS,
		id = 0,
		sortID = SUB_CATEGORY_COLLECTIONS,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_01",
	},
	{
		text = FAVORITES,
		id = 0,
		sortID = SUB_CATEGORY_FAVORITES,
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
		func = function() MountJournal_SetDefaultCategory(true); end
	},
}

local CastSpellByID = CastSpellByID

SIRUS_MOUNTJOURNAL_PRODUCT_DATA = {}

local MOUNTJOURNAL_MOUNT_DATA_BY_HASH = {}
local MOUNTJOURNAL_MOUNT_SEARCH_DATA = {}
local MOUNTJOURNAL_MASTER_DATA = {}

STORE_PRODUCT_MONEY_ICON = {"coins", "mmotop", "refer", "loyal"}

local totalMounts
local mountDataBuffer = {}
local displayCategories = {}

local SUB_CATEGORY_FILTER;

local MOUNTJOURNAL_FILTER_COLLECTED;
local MOUNTJOURNAL_FILTER_NOT_COLLECTED;
local MOUNTJOURNAL_FILTER_TYPES = {};
local MOUNTJOURNAL_FILTER_SOURCES = 0;
local MOUNTJOURNAL_FILTER_FACTIONS = {};

local function keyConcat( a, b )
	return tostring(a) .. tostring(b)
end

function MountJournal_OnLoad( self, ... )
	totalMounts = #COLLECTION_MOUNTDATA

	local homeData = {
		name = CATEGORYES,
		OnClick = function()
			SUB_CATEGORY_FILTER = nil;
			MountJournal.selectCategoryID = nil
			if self.ListScrollFrame:IsShown() then
				self.ListScrollFrame:Hide()
				self.CategoryScrollFrame:Show()
			end
			MountJournal_UpdateCollectionList()
			NavBar_Reset(MountJournal.navBar)
		end,
	}

	self.navBar.home:SetText(CATEGORYES)
	NavBar_ReconsultationSize(self.navBar.home)
	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow)

	MountJournal_SetDefaultCategory();

	self.ListScrollFrame.update = MountJournal_UpdateMountList
	self.ListScrollFrame.scrollBar.doNotHide = true
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0)

	self.CategoryScrollFrame.update = MountJournal_UpdateCollectionList
	self.CategoryScrollFrame.scrollBar.doNotHide = true
	HybridScrollFrame_CreateButtons(self.CategoryScrollFrame, "CategoryListButtonTemplate", 0, 0, "TOP", "TOP", 0, 0, "TOP", "BOTTOM")

	self:RegisterEvent("COMPANION_LEARNED")
	self:RegisterEvent("COMPANION_UNLEARNED")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")

	UIDropDownMenu_Initialize(self.mountOptionsMenu, MountOptionsMenu_Init, "MENU")
end

function MountJournal_OnEvent( self, event, arg1, ... )
	if event == "PLAYER_LOGIN" then
		MountJournal_CreateData()
	elseif (event == "COMPANION_UPDATE" and (not arg1 or arg1 == "MOUNT")) or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" then
		mountDataBuffer = {}

		for i = 1, GetNumCompanions("MOUNT") do
			local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i)
			mountDataBuffer[keyConcat(creatureID, spellID)] = {creatureID = creatureID, creatureName = creatureName, spellID = spellID, icon = icon, active = active, mountIndex = i}
		end

		if event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" then
			MountJournal_CreateData()
		end

		if self:IsVisible() then
			MountJournal_UpdateFilter(true)
		end
	end
end

function MountJournal_UpdateCollectionList()
	local scrollFrame = MountJournal.CategoryScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	local categories = categoryData
	local element

	table.wipe(displayCategories)

	local selection = MountJournal.selectCategoryID
	local parent

	if selection then
		for _, category in ipairs(categories) do
			if category.id == selection then
				if parent ~= category.id and MountJournal.CategoryScrollFrame:IsShown() then
					NavBar_Reset(MountJournal.navBar)

					local buttonData = {
						id = category.id,
						name = category.text,
						OnClick = function(self)
							MountJournal.selectCategoryID = self.id
							if MountJournal.ListScrollFrame:IsShown() then
								MountJournal.ListScrollFrame:Hide()
								MountJournal.CategoryScrollFrame:Show()
							end
							NavBar_Reset(MountJournal.navBar)
							MountJournal_UpdateCollectionList()
						end
					}
					NavBar_AddButton(MountJournal.navBar, buttonData)
				end
				parent = category.id
			end
		end
	else
		if MountJournal.CategoryScrollFrame:IsShown() then
			NavBar_Reset(MountJournal.navBar)
		end
	end

	for _, category in next, categories do
		if not category.hidden then
			table.insert(displayCategories, category)
		elseif parent and category.parent == parent then
			category.collapsed = false
			table.insert(displayCategories, category)
		elseif parent and category.parent and category.parent == parent then
			category.hidden = false
			table.insert(displayCategories, category)
		end
	end

	local numCategories = #displayCategories
	local numButtons = #buttons

	local totalHeight = numCategories * buttons[1]:GetHeight()
	local displayedHeight = 0

	for i = 1, numButtons do
		element = displayCategories[i + offset]
		displayedHeight = displayedHeight + buttons[i]:GetHeight()

		if element then
			MountJournal_CategoryDisplayButton( buttons[i], element )
			if not element.func and selection and element.id == selection then
				buttons[i]:LockHighlight()
				buttons[i]:GetHighlightTexture():SetAlpha(0.7)
			else
				buttons[i]:UnlockHighlight()
				buttons[i]:GetHighlightTexture():SetAlpha(0.3)
			end

			buttons[i]:Show()
		else
			buttons[i].element = nil
			buttons[i]:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

	return displayCategories
end

function ListScrollFrame_OnShow(self)
	if not SUB_CATEGORY_FILTER then
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
		MountJournal.searchBox:SetText("")
		MountJournal.searchBox:ClearFocus()
		MountJournal.searchBox:EnableMouse(0)
	end
end

function MountJournal_SetDefaultCategory(notResetNavBar)
	SUB_CATEGORY_FILTER = nil;
	MountJournal.selectCategoryID = nil;

	MountJournal_SetDefaultFilters();

	if not notResetNavBar then
		NavBar_Reset(MountJournal.navBar);
		NavBar_AddButton(MountJournal.navBar, {
			name = ALL_MOUNTS
		});
	end
end

function MountJournal_CategoryDisplayButton( button, element )
	if ( not element ) then
		button.element = nil
		button:Hide()
		return
	end

	button.Background:SetVertexColor(0.8, 0.8, 0.8)

	if element.icon then
		button.Icon:SetTexture(element.icon)
	end

	if element.isCategory then
		-- button:SetWidth(250)
		button:SetSize(262, 62)
		button.Background:SetSize(262, 62)
		button:GetHighlightTexture():SetSize(262, 62)

		button.Background:SetTexCoord(0.00195313, 0.60742188, 0.00390625, 0.28515625)
		button:GetHighlightTexture():SetTexCoord(0.00195313, 0.60742188, 0.00390625, 0.28515625)

		button.categoryName:SetPoint("CENTER", 24, 0)
		button.categoryName:SetJustifyH("LEFT")
	else
		button:SetSize(230, 62)
		button.Background:SetSize(230, 62)
		button:GetHighlightTexture():SetSize(230, 62)

		button.Background:SetTexCoord(0, 0.53125, 0.76171875, 1)
		button:GetHighlightTexture():SetTexCoord(0, 0.53125, 0.76171875, 1)

		button.categoryName:SetPoint("CENTER", 0, 1)
		button.categoryName:SetJustifyH("LEFT")
	end

	button.categoryName:SetText(element.text)

	button.element = element

	button:Show()
end

function CategoryListButton_OnEnter( _, ... )
	-- body
end

function CategoryListButton_OnLeave( _, ... )
	-- body
end

function CategoryListButton_OnClick( button, ... )
	Categorylist_SelectButton( button )
	MountJournal_UpdateCollectionList()
end

function Categorylist_SelectButton( button )
	local id = button.element.id
	local data = button.element

	if data.func then
		MountJournal.selectCategoryID = nil
		data.func()

		MountJournal.ListScrollFrame:Show()
		MountJournal.CategoryScrollFrame:Hide()
		MountJournal_UpdateFilter()
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)

		NavBar_Reset(MountJournal.navBar)
		local buttonData = {
			name = data.text
		}
		NavBar_AddButton(MountJournal.navBar, buttonData)
		return
	end

	if data.sortID then
		SUB_CATEGORY_FILTER = data.sortID

		local buttonData = {
			name = data.text
		}
		NavBar_AddButton(MountJournal.navBar, buttonData)

		MountJournal.ListScrollFrame:Show()
		MountJournal.CategoryScrollFrame:Hide()
		MountJournal_UpdateFilter()
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
	end

	if not data.isCategory then
		return
	end

	if MountJournal.selectCategoryID == id then
		MountJournal.selectCategoryID = nil
		return
	end

	MountJournal.selectCategoryID = id
end

function MountJournal_OnShow( self, ... )
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	SetParentFrameLevel(self.LeftInset);
	SetParentFrameLevel(self.RightTopInset);
	SetParentFrameLevel(self.RightBottomInset);

	self.selectCategoryID = nil
	self.IsOpenStore = nil

	if CollectionsJournal.resetPositionTimer then
		CollectionsJournal.resetPositionTimer:Cancel()
		CollectionsJournal.resetPositionTimer = nil
	end

	for i = 1, 7 do
		local button = _G["MountJournalButtomFrameMountButtonColor"..i]
		button:Hide()
	end

	MountJournal.bottomFrame:SetShown(false)
	MountJournal.RightBottomInset:SetShown(false)

	for i = 1, #SIRUS_MOUNTJOURNAL_PRODUCT_DATA do
		local data = SIRUS_MOUNTJOURNAL_PRODUCT_DATA[i]
		if data and data.hash and MOUNTJOURNAL_MOUNT_DATA_BY_HASH and MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash] then
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].currency = tonumber(data.currency)
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].price = tonumber(data.price)
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].productID = tonumber(data.productID)
		end
	end

	MountJournal_CreateData()
	MountJournal_UpdateFilter(true)

	self.FilterButton:SetResetFunction(MountJournalFilterDropdown_ResetFilters);
end

function MountJournal_OnHide( self, ... )
	if not self.IsOpenStore then
		if CollectionsJournal.resetPositionTimer then
			CollectionsJournal.resetPositionTimer:Cancel()
			CollectionsJournal.resetPositionTimer = nil
		end

		CollectionsJournal.resetPositionTimer = C_Timer:After(5, function()
			MountJournal_SetDefaultCategory()

			MountJournal.searchBox:SetText("")
			MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
			MountJournal_UpdateFilter()
			MountJournal_Select(1)

			if CollectionsJournal.resetPositionTimer then
				CollectionsJournal.resetPositionTimer:Cancel()
				CollectionsJournal.resetPositionTimer = nil
			end
		end)
	end
end

function MountJournal_OnSearchTextChanged( self, ... )
	SearchBoxTemplate_OnTextChanged( self )
	MountJournal_UpdateFilter()

	if not MountJournal.selectedItemID then
		MountJournal_Select(1)
	end
end

local function MountJournal_CheckSubCategoryFilter(data)
	if SUB_CATEGORY_FILTER == SUB_CATEGORY_COLLECTIONS then
		if data.mountIndex then
			return true;
		end
	elseif SUB_CATEGORY_FILTER == SUB_CATEGORY_FAVORITES then
		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[data.hash] then
			return true;
		end
	else
		return SUB_CATEGORY_FILTER == data.subCategoryID;
	end

	return false;
end

local SOURCE_TYPES = {
	[1] = 1, [2] = 1, [3] = 1,
	[8] = 2, [12] = 2,
	[6] = 3, [13] = 3,
	[9] = 4,
	[7] = 5,
	[10] = 7, [11] = 7, [14] = 7,
	[15] = 8,
	[16] = 9,
	[17] = 10,
};

local function MountJournal_CheckFilter(data, hasHiddenType, hasHiddenSource, hasHiddenFaction)
	if MOUNTJOURNAL_FILTER_COLLECTED and data.mountIndex or MOUNTJOURNAL_FILTER_NOT_COLLECTED and not data.mountIndex then
		return false;
	end

	if hasHiddenType then
		if data.inhabitType == 0 then
			return false;
		elseif bit.band(data.inhabitType, 1) ~= 0 then
			if MOUNTJOURNAL_FILTER_TYPES[1] then
				return false;
			end
		elseif bit.band(data.inhabitType, 2) ~= 0 then
			if MOUNTJOURNAL_FILTER_TYPES[2] then
				return false;
			end
		elseif bit.band(data.inhabitType, 4) ~= 0 then
			if MOUNTJOURNAL_FILTER_TYPES[3] then
				return false;
			end
		end
	end

	if hasHiddenSource then
		local sourceFlag = data.lootType ~= 0 and bit.lshift(1, ((data.currency ~= 0 and data.lootType ~= 15 and 7 or SOURCE_TYPES[data.lootType]) or 1) - 1) or 0;
		if data.holidayText ~= "" then
			sourceFlag = bit.bor(sourceFlag, bit.lshift(1, 6 - 1));
		end

		if bit.band(MOUNTJOURNAL_FILTER_SOURCES, sourceFlag) == sourceFlag then
			return false;
		end
	end

	if hasHiddenFaction then
		if data.factionSide == 0 then
			if MOUNTJOURNAL_FILTER_FACTIONS[3] then
				return false;
			end
		elseif bit.band(data.factionSide, 1) ~= 0 then
			if MOUNTJOURNAL_FILTER_FACTIONS[1] then
				return false;
			end
		elseif bit.band(data.factionSide, 2) ~= 0 then
			if MOUNTJOURNAL_FILTER_FACTIONS[2] then
				return false;
			end
		elseif bit.band(data.factionSide, 4) ~= 0 then
			if MOUNTJOURNAL_FILTER_FACTIONS[4] then
				return false;
			end
		end
	end

	return true;
end

function MountJournal_UpdateScrollPos(self, visibleIndex)
	local buttons = self.buttons
	local height = math.max(0, math.floor(self.buttonHeight * (visibleIndex - (#buttons)/2)))
	HybridScrollFrame_SetOffset(self, height)
	self.scrollBar:SetValue(height)
end

local realmFilterData = {
	[E_REALM_ID.FROSTMOURNE] = 1,
	[E_REALM_ID.SCOURGE] = 2,
	[E_REALM_ID.NELTHARION] = 4,
	[E_REALM_ID.LEGACY_X10] = 8,
}

function MountJournal_CreateData()
	local defaultMountData = {}

	table.wipe(MOUNTJOURNAL_MOUNT_DATA_BY_HASH)
	table.wipe(MOUNTJOURNAL_MOUNT_SEARCH_DATA)

	for i = 1, GetNumCompanions("MOUNT") do
		local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i)
		if creatureID then
			defaultMountData[keyConcat(creatureID, spellID)] = {creatureID = creatureID, creatureName = creatureName, spellID = spellID, icon = icon, active = active, mountIndex = i}
		end
	end

	for i = 1, #COLLECTION_MOUNTDATA do
		local data = COLLECTION_MOUNTDATA[i]

		if data then
			if data.flags and data.flags ~= 0 then
				local realmFlag = realmFilterData[C_Service:GetRealmID()]

				if realmFlag then
					if bit.band(data.flags, realmFlag) == data.flags then
						table.remove(COLLECTION_MOUNTDATA, i)
					end
				end
			end

			if not data.spellName then
				local spellName,_ , texture,_ ,_ ,_ ,_ ,_ ,_ = GetSpellInfo(data.spellID)

				data.spellName                               = spellName
				data.spellTexture                            = texture
			end

			if not data.mountIndex then
				local defaultData = defaultMountData[keyConcat(data.creatureID, data.spellID)]

				if defaultData then
					data.mountActive = defaultData.active
					data.mountIndex = defaultData.mountIndex
				end
			end
		end
	end

	MountJournal_UpdateSort()
	MountJournal_GenerateSearchData()
end

function MountJournal_GenerateSearchData()
	for i = 1, #COLLECTION_MOUNTDATA do
		local data = COLLECTION_MOUNTDATA[i]

		if data then
			table.insert(MOUNTJOURNAL_MOUNT_SEARCH_DATA, {name = string.upper( data.spellName or UNKNOWN ), hash = data.hash, creatureID = data.creatureID, spellID = data.spellID})
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash] = data
		end
	end
end

function MountJournal_UpdateFilter(doNotUpdateScroll)
	local text = string.upper( MountJournal.searchBox:GetText() )
	local textCount = MountJournal.searchBox:GetNumLetters()
	local sourceData = MOUNTJOURNAL_MOUNT_SEARCH_DATA
	text = textCount > 1 and text or ""

	table.wipe(MOUNTJOURNAL_MASTER_DATA)

	local hasHiddenType = next(MOUNTJOURNAL_FILTER_TYPES);
	local hasHiddenSource = MOUNTJOURNAL_FILTER_SOURCES ~= 0;
	local hasHiddenFaction = next(MOUNTJOURNAL_FILTER_FACTIONS);

	for i = 1, #sourceData do
		local data = sourceData[i]

		if SUB_CATEGORY_FILTER then
			if MountJournal_CheckSubCategoryFilter(MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash]) then
				if mountDataBuffer[keyConcat(data.creatureID, data.spellID)] then
					local mountData = mountDataBuffer[keyConcat(data.creatureID, data.spellID)]
					MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].mountIndex = mountData.mountIndex
					MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].mountActive = mountData.active
				end

				table.insert(MOUNTJOURNAL_MASTER_DATA, data)
			end
		else
			if string.find(data.name, text, 1, true) then
				if MountJournal_CheckFilter(MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash], hasHiddenType, hasHiddenSource, hasHiddenFaction) then
					if mountDataBuffer[keyConcat(data.creatureID, data.spellID)] then
						local mountData = mountDataBuffer[keyConcat(data.creatureID, data.spellID)]
						MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].mountIndex = mountData.mountIndex
						MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].mountActive = mountData.active
					end

					table.insert(MOUNTJOURNAL_MASTER_DATA, data)
				end
			end
		end
	end

	if textCount > 1 and not doNotUpdateScroll then
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
	end

	MountJournal_UpdateMountList()
end

function MountJournal_UpdateSort()
	table.sort(COLLECTION_MOUNTDATA, function(a, b)
		if a.mountIndex and not b.mountIndex then
			return true
		end
		if not a.mountIndex and b.mountIndex then
			return false
		end
		if a.mountIndex and b.mountIndex then
			if SIRUS_MOUNTJOURNAL_FAVORITE_PET[a.hash] and not SIRUS_MOUNTJOURNAL_FAVORITE_PET[b.hash] then
				return true
			end
			if not SIRUS_MOUNTJOURNAL_FAVORITE_PET[a.hash] and SIRUS_MOUNTJOURNAL_FAVORITE_PET[b.hash] then
				return false
			end
		end

		if a.spellName and b.spellName then
			return a.spellName < b.spellName
		end
	end)
end

function MountJournal_ClearSearch( _, ... )
	-- body
end

function MountJournal_UpdateDefaultMountList()
	local creatureData = {}
	local activeData = {}

	for i = 1, GetNumCompanions("MOUNT") do
		local creatureID,_ ,_ ,_ , active = GetCompanionInfo("MOUNT", i)
		if creatureID then
			table.insert(creatureData, creatureID)
		end
		if active then
			table.insert(activeData, creatureID)
		end
	end

	return creatureData, activeData
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournalListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	local showMounts = true
	local numMounts = #MOUNTJOURNAL_MASTER_DATA

	MountJournal.numOwned = 0

	MountJournal.MountDisplay.NoMounts:SetShown(numMounts < 1)
	MountJournal.MountDisplay.NoMountsTex:SetShown(numMounts < 1)

	if numMounts > 0 then
		MountJournal.MountDisplay.ModelScene:Show()
	else
		MountJournal.MountDisplay.ModelScene:Hide()
	end
	MountJournal.MountDisplay.ModelScene.InfoButton:SetShown(numMounts > 0)
	MountJournal.MountDisplay.YesMountsTex:SetShown(numMounts > 0)

	showMounts = numMounts < 1 and 0 or 1

	for i = 1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset

		if displayIndex <= numMounts and showMounts == 1 and MOUNTJOURNAL_MASTER_DATA[displayIndex] then
			local data = MOUNTJOURNAL_MOUNT_DATA_BY_HASH[MOUNTJOURNAL_MASTER_DATA[displayIndex].hash]
			local index = displayIndex

			button.index = index
			button.hash = data.hash
			button.spellID = data.spellID
			button.creatureID = data.creatureID
			button.itemID = data.itemID
			button.mountIndex = nil
			button.data = data

			button.name:SetText(data.spellName)
			button.icon:SetTexture(data.spellTexture)

			button.DragButton.ActiveTexture:SetShown(data.mountActive)
			button:Show()

			if MountJournal.selectedItemID == data.itemID then
				button.selected = true
				button.selectedTexture:Show()
			else
				button.selected = false
				button.selectedTexture:Hide()
			end

			button:SetEnabled(true)
			button.unusable:Hide()
			button.iconBorder:Hide()
			button.background:SetVertexColor(1, 1, 1, 1)

			if data.mountIndex then
				button.mountIndex = data.mountIndex

				button.additionalText = nil
				button.icon:SetDesaturated(false)
				button.icon:SetAlpha(1.0)
				button.name:SetFontObject("GameFontNormal")
			else
				button.icon:SetDesaturated(true)
				button.icon:SetAlpha(0.25)
				button.additionalText = nil
				button.name:SetFontObject("GameFontDisable")
			end

			button.favorite:SetShown(not not SIRUS_MOUNTJOURNAL_FAVORITE_PET[data.hash])
			button.MountJournalIcons_Horde:SetShown(data.factionSide and data.factionSide == 2)
			button.MountJournalIcons_Alliance:SetShown(data.factionSide and data.factionSide == 1)

			if ( button.showingTooltip ) then
				MountJournalMountButton_UpdateTooltip(button)
			end

		else
			button.name:SetText("")
			button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon")
			button.index = nil
			button.spellID = 0
			button.itemID = nil
			button.selected = false
			button.unusable:Hide()
			button.DragButton.ActiveTexture:Hide()
			button.selectedTexture:Hide()
			button:SetEnabled(false)
			button.DragButton:SetEnabled(false)
			button.icon:SetDesaturated(true)
			button.icon:SetAlpha(0.5)
			button.favorite:Hide()
			button.MountJournalIcons_Horde:Hide()
			button.MountJournalIcons_Alliance:Hide()
			button.background:SetVertexColor(1, 1, 1, 1)
			button.iconBorder:Hide()
		end
	end

	local totalHeight = numMounts * 46
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
	MountJournal.MountCount.Count:SetText(string.format("%d / %d", GetNumCompanions("MOUNT"), totalMounts))
	if ( not showMounts ) then
		MountJournal.selectedItemID = nil
		MountJournal.selectedMountID = nil
	end
end

function MountListDragButton_OnClick( self, button, ... )
	local parent = self:GetParent()
	local spellID = parent.spellID;
	local itemID = parent.itemID;

	if ( button ~= "LeftButton" ) then
		if parent.mountIndex then
			MountJournal_ShowMountDropdown(parent.mountIndex, self, 0, 0)
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(spellID)
			ChatEdit_InsertLink(spellName)
		elseif itemID then
			ChatEdit_InsertLink(string.format(COLLECTION_MOUNTS_HYPERLINK_FORMAT, itemID, GetSpellInfo(spellID) or ""));
		end
	else
		if parent.mountIndex then
			PickupCompanion( "MOUNT", parent.mountIndex )
		end
	end
end

function MountJournal_ShowMountDropdown( index, anchorTo, offsetX, offsetY )
	if not index then
		return
	end

	MountJournal.menuMountID = anchorTo.creatureID
	MountJournal.menuData = anchorTo.data

	ToggleDropDownMenu(1, nil, MountJournal.mountOptionsMenu, anchorTo, offsetX, offsetY)
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function MountOptionsMenu_Init(_ ,level, ... )
	if not MountJournal.menuData then
		return
	end

	local info = UIDropDownMenu_CreateInfo()
	local data = MountJournal.menuData

	info.notCheckable = true
	info.text = data.mountActive and BINDING_NAME_DISMOUNT or MOUNT
	info.func = function()
		if data.mountIndex then
			if data.mountActive then
				DismissCompanion("MOUNT")
			else
				CallCompanion("MOUNT", data.mountIndex)
			end
		end
	end
	UIDropDownMenu_AddButton(info, level)

	if data.mountIndex then
		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[data.hash] then
			info.text = DELETE_FAVORITE
			info.func = function() SendServerMessage("ACMSG_C_R_F", string.format("%d|%s", CHAR_COLLECTION_MOUNT, data.hash)) end
		else
			info.text = COMMUNITIES_LIST_DROP_DOWN_FAVORITE
			info.func = function() SendServerMessage("ACMSG_C_A_F", string.format("%d|%s", CHAR_COLLECTION_MOUNT, data.hash)) end
		end
		UIDropDownMenu_AddButton(info, level)
	end

	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function MountJournalMountButton_UpdateTooltip( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink("spell:"..self.spellID)
	GameTooltip:Show()
end

function MountListItem_OnClick( self, button, ... )
	if ( button ~= "LeftButton" ) then
		if self.mountIndex then
			MountJournal_ShowMountDropdown(self.mountIndex, self, 0, 0)
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local spellID = self.spellID;
		local itemID = self.itemID;

		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(spellID)
			ChatEdit_InsertLink(spellName)
		elseif itemID then
			ChatEdit_InsertLink(string.format(COLLECTION_MOUNTS_HYPERLINK_FORMAT, itemID, GetSpellInfo(spellID) or ""));
		end
	elseif ( self.spellID ~= MountJournal.selectedItemID ) then
		MountJournal_Select(self.index)
		MountJournal.searchBox:ClearFocus()
	end
end

function MountListItem_OnDoubleClick( self, button, ... )
	if self.mountIndex and button == "LeftButton" then
		if self.data.mountActive then
			DismissCompanion("MOUNT")
		else
			CallCompanion("MOUNT", self.mountIndex)
		end
	end
end

function MountJournal_UpdateMountDisplay()
	local data = MountJournal.data

	MountJournal.bottomFrame:SetShown(#data.colorData > 0)
	MountJournal.RightBottomInset:SetShown(#data.colorData > 0)

	if IsGMAccount() then
		MountJournal.MountDisplay.ModelScene.DebugInfo:SetFormattedText("CreatureID: %s", data.creatureID);
		MountJournal.MountDisplay.ModelScene.DebugInfo:Show();
	else
		MountJournal.MountDisplay.ModelScene.DebugInfo:Hide();
	end
	MountJournal.MountDisplay.ModelScene.DebugFrame:SetShown(IsGMAccount());

	MountJournal.MountDisplay.ModelScene.creatureID = data.creatureID

	local insetPointY = #data.colorData > 0 and 80 or 0
	MountJournal.RightTopInset:ClearAllPoints()
	MountJournal.RightTopInset:SetPoint("TOPRIGHT", -6, -60)
	MountJournal.RightTopInset:SetPoint("BOTTOMLEFT", MountJournal.LeftInset, "BOTTOMRIGHT", 20, insetPointY)

	if data.factionSide == 1 then
		data.priceText = data.priceText:gsub("-Team.", "-Alliance.")
	elseif data.factionSide == 2 then
		data.priceText = data.priceText:gsub("-Team.", "-Horde.")
	else
		local faction = UnitFactionGroup("player")
		data.priceText = data.priceText:gsub("-Team.", "-"..faction..".")
	end

	MountJournal.MountDisplay.ModelScene.InfoButton.Icon:SetTexture(data.spellTexture)
	MountJournal.MountDisplay.ModelScene.InfoButton.Name:SetText(data.spellName)
	MountJournal.MountDisplay.ModelScene.InfoButton.Source:SetFormattedText("%s%s", data.holidayText ~= "" and string.format("%s\n", data.holidayText) or "", data.priceText)
	MountJournal.MountDisplay.ModelScene.InfoButton.Lore:SetText(data.descriptionText)

	MountJournal.MountDisplay.ModelScene:Hide()
	MountJournal.MountDisplay.ModelScene:Show()

	if data.lootType == 16 then
		MountJournal.MountDisplay.ModelScene.buyFrame:SetShown(BattlePassFrame:GetEndTime() ~= 0 and not data.mountIndex)
		MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(GO_TO_BATTLE_BASS)
		MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetEnabled(true)
		MountJournal.MountDisplay.ModelScene.buyFrame.priceText:SetText("")
		MountJournal.MountDisplay.ModelScene.buyFrame.MoneyIcon:SetTexture("")
	elseif data.currency and data.currency ~= 0 then
		MountJournal.MountDisplay.ModelScene.buyFrame:SetShown(not data.mountIndex)

		if data.currency == 4 then
			MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(PICK_UP)
		else
			MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(GO_TO_STORE)
		end

		MountJournal.MountDisplay.ModelScene.buyFrame.MoneyIcon:SetTexture("Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[data.currency])
		MountJournal.MountDisplay.ModelScene.buyFrame.priceText:SetText(data.price)
	else
		MountJournal.MountDisplay.ModelScene.buyFrame:Hide()
	end

	if data.itemID then
		local canOpened = LootJournal_CanOpenItemByEntry(data.itemID, true)

		MountJournal.MountDisplay.ModelScene.EJFrame.OpenEJButton.itemID = data.itemID
		MountJournal.MountDisplay.ModelScene.EJFrame:SetShown(canOpened)
	else
		MountJournal.MountDisplay.ModelScene.EJFrame:Hide()
	end

	MountJournal.MountButton:SetEnabled(data.mountIndex)

	MountJournal_UpdateFavoriteData()
end

function MountJournal_UpdateFavoriteData()
	local data = MountJournal.data
	if data then
		MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetShown(data.mountIndex)

		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[data.hash] then
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetChecked(true)
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton.isFavorite = true
		else
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetChecked(false)
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton.isFavorite = false
		end
	end
end

function FavoriteButton_OnClick(_ , ... )
	local data = MountJournal.data

	if SIRUS_MOUNTJOURNAL_FAVORITE_PET[data.hash] then
		SendServerMessage("ACMSG_C_R_F", string.format("%d|%s", CHAR_COLLECTION_MOUNT, data.hash));
	else
		SendServerMessage("ACMSG_C_A_F", string.format("%d|%s", CHAR_COLLECTION_MOUNT, data.hash));
	end
end

function MountJournalMountButton_OnClick(_ , ... )
	local data = MountJournal.data

	if data.mountIndex then
		if data.mountActive then
			DismissCompanion("MOUNT")
		else
			CallCompanion("MOUNT", data.mountIndex)
		end
	end
end

function MountJournalBuyButton_OnClick(_ , ... )
	MountJournal.IsOpenStore = true

	HideUIPanel(CollectionsJournal)
	-- ShowUIPanel(StoreFrame)

	if CollectionsJournal.resetPositionTimer then
		CollectionsJournal.resetPositionTimer:Cancel()
		CollectionsJournal.resetPositionTimer = nil
	end

	CollectionsJournal.resetPositionTimer = C_Timer:After(30, function()
		MountJournal_SetDefaultCategory()

		MountJournal.searchBox:SetText("")
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
		MountJournal_UpdateFilter()
		MountJournal_Select(1)

		MountJournal.IsOpenStore = false
		if CollectionsJournal.resetPositionTimer then
			CollectionsJournal.resetPositionTimer:Cancel()
			CollectionsJournal.resetPositionTimer = nil
		end
	end)

	local data = MountJournal.data

	if data.lootType == 16 then
		BattlePassFrame:Show()
	else
		local productData = {
			Texture = data.spellTexture,
			Name = data.spellName,
			Price = data.price,
			ID = data.productID,
			currency = data.currency
		}

		-- _G["StoreMoneyButton"..data.currency]:Click()

		-- StoreFrame_ProductBuy(productData)

		StoreFrame_ProductBuyWithOpenPage(productData)
	end
end

function MountJournal_Select( index )
	if MOUNTJOURNAL_MASTER_DATA[index] and MOUNTJOURNAL_MOUNT_DATA_BY_HASH[MOUNTJOURNAL_MASTER_DATA[index].hash] then
		local data = MOUNTJOURNAL_MOUNT_DATA_BY_HASH[MOUNTJOURNAL_MASTER_DATA[index].hash]
		if MountJournal.selectedItemID ~= data.itemID then
			MountJournal.selectedItemID = data.itemID
			MountJournal.selectedMountID = data.creatureID
			MountJournal.data = data
			MountJournal_HideMountDropdown()
			MountJournal_UpdateMountList()
			MountJournal_UpdateMountDisplay()
		end
	end
end

function MountJournal_HideMountDropdown()
	if UIDropDownMenu_GetCurrentDropDown() == MountJournal.mountOptionsMenu then
		HideDropDownMenu(1)
	end
end

function MountJournalSummonRandomFavoriteButton_OnLoad( self, ... )
	self.spellID           = 305495
	local _ ,_ , spellIcon = GetSpellInfo(self.spellID)
	self.texture:SetTexture(spellIcon)
	self:RegisterForDrag("LeftButton")
end

function MountJournalSummonRandomFavoriteButton_OnClick(self,_ , ... )
	CastSpellByID(self.spellID)
end

function MountJournalSummonRandomFavoriteButton_OnDragStart( self, ... )
	local spellname = GetSpellInfo(self.spellID)
	PickupSpell(spellname)
end

function MountJournalSummonRandomFavoriteButton_OnEnter( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("spell:"..self.spellID)
end

function MountJournalFilterDropDown_OnLoad( self, ... )
	UIDropDownMenu_Initialize(self, MountJournalFilterDropDown_Initialize, "MENU")
end

function MountJournalFilterDropdown_ResetFilters()
	MountJournal_SetDefaultFilters();
	MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1);
	MountJournal_UpdateFilter();
	MountJournalFilterButton.ResetButton:Hide();
end

function MountJournalResetFiltersButton_UpdateVisibility()
	MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1);
	MountJournal_UpdateFilter();

	MountJournalFilterButton.ResetButton:SetShown(not MountJournal_IsUsingDefaultFilters());
end

function MountJournal_SetDefaultFilters()
	MOUNTJOURNAL_FILTER_COLLECTED = nil;
	MOUNTJOURNAL_FILTER_NOT_COLLECTED = nil;
	table.wipe(MOUNTJOURNAL_FILTER_TYPES);
	MOUNTJOURNAL_FILTER_SOURCES = 0;
	table.wipe(MOUNTJOURNAL_FILTER_FACTIONS);
end

function MountJournal_IsUsingDefaultFilters()
	if MOUNTJOURNAL_FILTER_COLLECTED or MOUNTJOURNAL_FILTER_NOT_COLLECTED then
		return false;
	end
	if next(MOUNTJOURNAL_FILTER_TYPES) or MOUNTJOURNAL_FILTER_SOURCES ~= 0 or next(MOUNTJOURNAL_FILTER_FACTIONS) then
		return false;
	end
	return true;
end

function MountJournal_SetCollectedFilter(value)
	MOUNTJOURNAL_FILTER_COLLECTED = not value;
end

function MountJournal_GetCollectedFilter()
	return not MOUNTJOURNAL_FILTER_COLLECTED;
end

function MountJournal_SetNotCollectedFilter(value)
	MOUNTJOURNAL_FILTER_NOT_COLLECTED = not value;
end

function MountJournal_GetNotCollectedFilter()
	return not MOUNTJOURNAL_FILTER_NOT_COLLECTED;
end

function MountJournal_SetTypeFilter(i, value)
	MOUNTJOURNAL_FILTER_TYPES[i] = not value and true or nil;
end

function MountJournal_GetTypeFilter(i)
	return not MOUNTJOURNAL_FILTER_TYPES[i];
end

function MountJournal_SetSourceFilter(i, value)
	value = not value

	if value then
		MOUNTJOURNAL_FILTER_SOURCES = bit.bor(MOUNTJOURNAL_FILTER_SOURCES, bit.lshift(1, i - 1));
	else
		MOUNTJOURNAL_FILTER_SOURCES = bit.band(MOUNTJOURNAL_FILTER_SOURCES, bit.bnot(bit.lshift(1, i - 1)));
	end
end

function MountJournal_GetSourceFilter(i)
	if bit.band(MOUNTJOURNAL_FILTER_SOURCES, bit.lshift(1, i - 1)) ~= 0 then
		return false;
	end
	return true;
end

function MountJournal_SetAllSourceFilters(value)
	for i = 1, C_PetJournal.GetNumPetSources() do
		MountJournal_SetSourceFilter(i, value);
	end
	UIDropDownMenu_Refresh(MountJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function MountJournal_SetFactionFilter(i, value)
	MOUNTJOURNAL_FILTER_FACTIONS[i] = not value and true or nil;
end

function MountJournal_GetFactionFilter(i)
	return not MOUNTJOURNAL_FILTER_FACTIONS[i];
end

function MountJournal_SetAllFactionFilters(value)
	for i = 1, 4 do
		MOUNTJOURNAL_FILTER_FACTIONS[i] = not value and true or nil;
	end
	UIDropDownMenu_Refresh(MountJournalFilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL);
end

function MountJournalFilterDropDown_Initialize(self, level)
	local filterSystem = {
		onUpdate = MountJournalResetFiltersButton_UpdateVisibility,
		filters = {
			{ type = FilterComponent.Checkbox, text = COLLECTED, set = MountJournal_SetCollectedFilter, isSet = MountJournal_GetCollectedFilter },
			{ type = FilterComponent.Checkbox, text = NOT_COLLECTED, set = MountJournal_SetNotCollectedFilter, isSet = MountJournal_GetNotCollectedFilter },
			{ type = FilterComponent.CustomFunction, customFunc = MountJournal_AddInMountTypes, },
			{ type = FilterComponent.Submenu, text = SOURCES, value = 1, childrenInfo = {
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
						  set = MountJournal_SetSourceFilter,
						  isSet = MountJournal_GetSourceFilter,
						  numFilters = C_PetJournal.GetNumPetSources,
						  globalPrepend = "COLLECTION_PET_SOURCE_",
						},
					},
				},
			},
			{ type = FilterComponent.Submenu, text = FACTION, value = 2, childrenInfo = {
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
						  set = MountJournal_SetFactionFilter,
						  isSet = MountJournal_GetFactionFilter,
						  numFilters = function () return 4; end,
						  globalPrepend = "COLLECTION_MOUNT_FACTION_",
						},
					},
				},
			},
		},
	};

	FilterDropDownSystem.Initialize(self, filterSystem, level);
end

function MountJournal_AddInMountTypes(level)
	for i = 1, #mountTypeStrings do
		local set = function(_, _, _, value)
			MountJournal_SetTypeFilter(i, value);
			MountJournalResetFiltersButton_UpdateVisibility();
		end

		local isSet = function() return MountJournal_GetTypeFilter(i) end;
		FilterDropDownSystem.AddCheckBoxButton(mountTypeStrings[i], set, isSet, level);
	end
end

function MountColorButton_OnEnter( self, ... )
	self.BorderHighlight:Show()

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")

	if GameTooltip:SetHyperlink("spell:"..self.colorData.spellID) then
		self.UpdateTooltip = MountColorButton_OnEnter
	else
		self.UpdateTooltip = nil
	end

	GameTooltip:Show()
end

function MountColorButton_OnLeave( self, ... )
	self.BorderHighlight:Hide()
	GameTooltip:Hide()
end

function MountColorButton_OnClick( self, ... )
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

function EventHandler:ASMSG_COLLECTION_MOUNT_IN_SHOP( msg )
	table.wipe(SIRUS_MOUNTJOURNAL_PRODUCT_DATA)

	if msg then
		local blockData = {strsplit("|", msg)}

		for i = 1, #blockData do
			if blockData[i] then
				local hash, currency, price, productID = strsplit(",", blockData[i])
				if hash and productID and price then
					table.insert(SIRUS_MOUNTJOURNAL_PRODUCT_DATA, {hash = hash, currency = currency, price = price, productID = productID})
				end
			end
		end
	end
end