
local DEFAULT_FILTERS = {
	[Enum.AuctionHouseFilter.UncollectedOnly] = false,
	[Enum.AuctionHouseFilter.UsableOnly] = false,
	[Enum.AuctionHouseFilter.PoorQuality] = true,
	[Enum.AuctionHouseFilter.CommonQuality] = true,
	[Enum.AuctionHouseFilter.UncommonQuality] = true,
	[Enum.AuctionHouseFilter.RareQuality] = true,
	[Enum.AuctionHouseFilter.EpicQuality] = true,
	[Enum.AuctionHouseFilter.LegendaryQuality] = true,
};

AUCTION_HOUSE_FILTER_CATEGORY_STRINGS = {
	[Enum.AuctionHouseFilterCategory.Uncategorized] = "",
	[Enum.AuctionHouseFilterCategory.Equipment] = AUCTION_HOUSE_FILTER_CATEGORY_EQUIPMENT,
	[Enum.AuctionHouseFilterCategory.Rarity] = AUCTION_HOUSE_FILTER_CATEGORY_RARITY,
};

local function GetFilterCategoryName(category)
	return AUCTION_HOUSE_FILTER_CATEGORY_STRINGS[category] or "";
end

local function GetFilterName(filter)
	return AUCTION_HOUSE_FILTER_STRINGS[filter] or "";
end

local AUCTION_HOUSE_NUM_HISTORY_PREVIEWS = 10;


AuctionHouseSearchButtonMixin = {};

function AuctionHouseSearchButtonMixin:OnClick()
	self:GetParent():StartSearch();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseFavoritesSearchButtonMixin = CreateFromMixins(SquareIconButtonMixin);

local AUCTION_HOUSE_FAVORITES_SEARCH_BUTTON_CUSTOM_EVENTS = {
	"AUCTION_HOUSE_FAVORITES_UPDATED",
};

function AuctionHouseFavoritesSearchButtonMixin:OnLoad()
	local function FavoriteSearchOnClickHandler()
		self:GetParent():StartFavoritesSearch();
	end

	SquareIconButtonMixin.OnLoad(self);

	self:SetOnClickHandler(FavoriteSearchOnClickHandler);
	self.Icon:SetAtlas("auctionhouse-icon-favorite");
end

function AuctionHouseFavoritesSearchButtonMixin:OnShow()
	FrameUtil.RegisterFrameForCustomEvents(self, AUCTION_HOUSE_FAVORITES_SEARCH_BUTTON_CUSTOM_EVENTS);

	self:UpdateState();
end

function AuctionHouseFavoritesSearchButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForCustomEvents(self, AUCTION_HOUSE_FAVORITES_SEARCH_BUTTON_CUSTOM_EVENTS);
end

function AuctionHouseFavoritesSearchButtonMixin:OnEvent(event, ...)
	self:UpdateState();
end

function AuctionHouseFavoritesSearchButtonMixin:OnEnter()
	local hasFavorites = C_AuctionHouse.HasFavorites();
	self:SetTooltipInfo(AUCTION_HOUSE_FAVORITES_SEARCH_TOOLTIP_TITLE, not hasFavorites and AUCTION_HOUSE_FAVORITES_SEARCH_TOOLTIP_NO_FAVORITES or nil);

	SquareIconButtonMixin.OnEnter(self);
end

function AuctionHouseFavoritesSearchButtonMixin:UpdateState()
	local hasFavorites = C_AuctionHouse.HasFavorites();
	self:SetEnabled(hasFavorites);
	self.Icon:SetDesaturated(not hasFavorites);
end


AuctionHouseFilterButtonMixin = CreateFromMixins(UIMenuButtonStretchMixin);

local function AuctionHouseFilterDropDownMenu_Initialize(self)
	local filterButton = self:GetParent();

	local info = UIDropDownMenu_CreateInfo();
	info.text = AUCTION_HOUSE_FILTER_DROP_DOWN_LEVEL_RANGE;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = filterButton.LevelRangeFrame;
	UIDropDownMenu_AddButton(info);

	local filterGroups = C_AuctionHouse.GetFilterGroups();
	for i, filterGroup in ipairs(filterGroups) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = GetFilterCategoryName(filterGroup.category);
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);

		for j, filter in ipairs(filterGroup.filters) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = GetFilterName(filter);
			info.value = nil;
			info.isNotRadio = true;
			info.checked = filterButton.filters[filter];
			info.keepShownOnClick = 1;
			info.func = function(button)
				filterButton:ToggleFilter(filter);
			end
			UIDropDownMenu_AddButton(info);
		end

		if i ~= #filterGroups then
			UIDropDownMenu_AddSpace();
		end
	end
end

function AuctionHouseFilterButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown");

	self:Reset();
	UIDropDownMenu_SetInitializeFunction(self.DropDown, AuctionHouseFilterDropDownMenu_Initialize);
	UIDropDownMenu_SetDisplayMode(self.DropDown, "MENU");
end

function AuctionHouseFilterButtonMixin:OnClick()
	local level = 1;
	local value = nil;
	ToggleDropDownMenu(1, nil, self.DropDown, self, 9, 3);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function AuctionHouseFilterButtonMixin:ToggleFilter(filter)
	self.filters[filter] = not self.filters[filter];

	self:GetParent():OnFilterToggled();
end

function AuctionHouseFilterButtonMixin:Reset()
	self.filters = CopyTable(DEFAULT_FILTERS);
	self.LevelRangeFrame:Reset();
	self.ClearFiltersButton:Hide();
end

function AuctionHouseFilterButtonMixin:GetFilters()
	return self.filters;
end

function AuctionHouseFilterButtonMixin:CalculateFiltersArray()
	local filtersArray = {};
	for key, value in pairs(self.filters) do
		if value then
			table.insert(filtersArray, key);
		end
	end
	return filtersArray;
end

function AuctionHouseFilterButtonMixin:GetLevelRange()
	return self.LevelRangeFrame:GetLevelRange();
end


AuctionHouseLevelRangeEditBoxMixin = {};

function AuctionHouseLevelRangeEditBoxMixin:OnTextChanged()
	self:GetParent():OnLevelRangeChanged();
end


AuctionHouseLevelRangeFrameMixin = CreateFromMixins(UIDropDownCustomMenuEntryMixin);

function AuctionHouseLevelRangeFrameMixin:OnLoad()
	self.MinLevel.nextEditBox = self.MaxLevel;
	self.MaxLevel.nextEditBox = self.MinLevel;
end

function AuctionHouseLevelRangeFrameMixin:OnHide()
	self:FixLevelRange();
end

function AuctionHouseLevelRangeFrameMixin:SetLevelRangeChangedCallback(levelRangeChangedCallback)
	self.levelRangeChangedCallback = levelRangeChangedCallback;
end

function AuctionHouseLevelRangeFrameMixin:OnLevelRangeChanged()
	if self.levelRangeChangedCallback then
		self.levelRangeChangedCallback();
	end
end

function AuctionHouseLevelRangeFrameMixin:FixLevelRange()
	local minLevel = self.MinLevel:GetNumber();
	local maxLevel = self.MaxLevel:GetNumber();

	if maxLevel ~= 0 and minLevel > maxLevel then
		self.MinLevel:SetNumber(maxLevel);
	end
end

function AuctionHouseLevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("");
	self.MaxLevel:SetText("");
end

function AuctionHouseLevelRangeFrameMixin:GetLevelRange()
	return self.MinLevel:GetNumber(), self.MaxLevel:GetNumber();
end


AuctionHouseClearFiltersButtonMixin = {};

function AuctionHouseClearFiltersButtonMixin:OnClick()
	self:GetParent():Reset();
end


AuctionHouseSearchBoxMixin = {};

function AuctionHouseSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	if self.clearButton then
		self.clearButton:SetScript("OnClick", function()
			PlaySound("igMainMenuOptionCheckBoxOn");
			self:SetText("");
			if not self:HasFocus() then
				EditBox_SetFocus(self);
			end
			SearchBoxTemplate_OnEditFocusGained(self);
		end);

		self.HasStickyFocus = function()
			local historyPreview = self:GetHistoryPreview();

			if historyPreview then
				return DoesAncestryInclude(self, GetMouseFocus()) or DoesAncestryInclude(historyPreview, GetMouseFocus());
			end

			return DoesAncestryInclude(self, GetMouseFocus());
		end
	end
end

function AuctionHouseSearchBoxMixin:OnEnterPressed()
	local historyPreview = self:GetHistoryPreview();
	if historyPreview then
		local preview = historyPreview.buttons[historyPreview.selectedIndex];
		if preview and preview:IsShown() then
			preview:Click();
		end
	end

	EditBox_ClearFocus(self);
	self:GetParent():StartSearch();
end

function AuctionHouseSearchBoxMixin:OnTabPressed()
	local historyPreview = self:GetHistoryPreview();
	if historyPreview then
		if IsShiftKeyDown() then
			historyPreview:SetSelection(historyPreview.selectedIndex - 1);
		else
			historyPreview:SetSelection(historyPreview.selectedIndex + 1);
		end
	end
end

function AuctionHouseSearchBoxMixin:OnEditFocusLost()
	local historyPreview = self:GetHistoryPreview();
	if historyPreview then
		historyPreview:Hide();
	end
end

function AuctionHouseSearchBoxMixin:OnEditFocusGained()
	SearchBoxTemplate_OnEditFocusGained(self);

	local historyPreview = self:GetHistoryPreview();
	if historyPreview then
		historyPreview:ShowResults(self:GetText());
	end
end

function AuctionHouseSearchBoxMixin:OnTextChanged(userInput)
	local text = self:GetText();
	if (not self:HasFocus() or not userInput) and text == "" then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide()
	else
		self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.clearButton:Show();
	end

	InputBoxInstructions_OnTextChanged(self);

	local historyPreview = self:GetHistoryPreview();
	if historyPreview and self:HasFocus() then
		historyPreview:ShowResults(text);
	end
end

function AuctionHouseSearchBoxMixin:Reset()
	self:SetText("");
end

function AuctionHouseSearchBoxMixin:GetSearchString()
	return self:GetText();
end

function AuctionHouseSearchBoxMixin:GetHistoryPreview()
	return self:GetParent().SearchHistory;
end

AuctionHouseSearchHistoryMixin = {};

function AuctionHouseSearchHistoryMixin:OnLoad()
	self.buttons = {};
	self.buttonPool = CreateFramePool("Button", self, "AuctionHouseSearchHistoryButton");

	self:ReleaseButtons();
end

function AuctionHouseSearchHistoryMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 11);
end

function AuctionHouseSearchHistoryMixin:OnHide()
	for index = 1, AUCTION_HOUSE_NUM_HISTORY_PREVIEWS do
		self.buttons[index]:Hide();
	end
end

function AuctionHouseSearchHistoryMixin:ReleaseButtons()
	table.wipe(self.buttons);
	self.buttonPool:ReleaseAll();
	for i = 1, AUCTION_HOUSE_NUM_HISTORY_PREVIEWS do
		local button = self.buttonPool:Acquire();
		button:SetID(i);

		if i == 1 then
			button:SetPoint("TOPLEFT");
		else
			button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT");
		end

		self.buttons[i] = button;
	end
end

function AuctionHouseSearchHistoryMixin:GetSearchBox()
	return self:GetParent().SearchBox;
end

function AuctionHouseSearchHistoryMixin:SetSelection(selectedIndex)
	local numShown = 0;
	for index = 1, AUCTION_HOUSE_NUM_HISTORY_PREVIEWS do
		local button = self.buttons[index];
		button.SelectedTexture:Hide();

		if button:IsShown() then
			numShown = numShown + 1;
		end
	end

	if numShown == 0 or selectedIndex > numShown then
		selectedIndex = 0;
	end

	self.selectedIndex = selectedIndex;
	if selectedIndex > 0 then
		self.buttons[selectedIndex].SelectedTexture:Show();
	end
end

function AuctionHouseSearchHistoryMixin:ShowResults(text)
	text = text or "";

	local historyResults = C_AuctionHouse.GetSearchHistory(text);
	local numHistoryResults = #historyResults;

	if numHistoryResults > 0 then
		self:SetSelection(0);
	else
		self:Hide();
		return;
	end

	local lastButton;

	for index = 1, AUCTION_HOUSE_NUM_HISTORY_PREVIEWS do
		local button = self.buttons[index];

		if index <= numHistoryResults then
			button.Text:SetText(historyResults[index]);
			button:Show();
			lastButton = button;
		else
			button:Hide();
		end
	end

	if lastButton then
		self:Show();
		self.BorderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -8);
		self.Background:Hide();
	else
		self:Hide();
	end
end

AuctionHouseSearchHistoryButtonMixin = {};

function AuctionHouseSearchHistoryButtonMixin:OnClick()
	if AuctionHouseFrame:SetSearchText(self.Text:GetText()) then
		AuctionHouseFrame.SearchBar:StartSearch();
		AuctionHouseFrame.SearchBar.SearchBox:ClearFocus();
	end
end

function AuctionHouseSearchHistoryButtonMixin:OnEnter()
	local historyPreview = self:GetParent();
	historyPreview:SetSelection(self:GetID());
end

AuctionHouseSearchBarMixin = CreateFromMixins(AuctionHouseSystemMixin);

function AuctionHouseSearchBarMixin:OnLoad()
	local function LevelRangeChangedCallback()
		self:OnLevelRangeChanged();
	end

	self.FilterButton.LevelRangeFrame:SetLevelRangeChangedCallback(LevelRangeChangedCallback)
end

function AuctionHouseSearchBarMixin:OnShow()
	self.SearchBox:Reset();
	self.FilterButton:Reset();
end

function AuctionHouseSearchBarMixin:OnFilterToggled()
	self:UpdateClearFiltersButton();
end

function AuctionHouseSearchBarMixin:OnLevelRangeChanged()
	self:UpdateClearFiltersButton();
end

function AuctionHouseSearchBarMixin:UpdateClearFiltersButton()
	local areFiltersDefault = tCompare(self.FilterButton:GetFilters(), DEFAULT_FILTERS);
	local minLevel, maxLevel = self:GetLevelFilterRange();
	self.FilterButton.ClearFiltersButton:SetShown(not areFiltersDefault or minLevel ~= 0 or maxLevel ~= 0);
end

function AuctionHouseSearchBarMixin:SetSearchText(searchText)
	self.SearchBox:SetText(searchText);
end

function AuctionHouseSearchBarMixin:GetLevelFilterRange()
	return self.FilterButton:GetLevelRange();
end

function AuctionHouseSearchBarMixin:StartSearch()
	local searchString = self.SearchBox:GetSearchString();
	local minLevel, maxLevel = self:GetLevelFilterRange();
	local filtersArray = self.FilterButton:CalculateFiltersArray();
	self:GetAuctionHouseFrame():SendBrowseQuery(searchString, minLevel, maxLevel, filtersArray);
end

function AuctionHouseSearchBarMixin:StartFavoritesSearch()
	self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllFavorites);
end