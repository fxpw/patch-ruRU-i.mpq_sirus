local ACHIEVEMENT_SEARCH_RESULTS = {};

local ACHIEVEMENT_SEARCH_TAB;
local ACHIEVEMENT_SEARCH_PROGRESS = 0;
local ACHIEVEMENT_SEARCH_TEXT = ""
local ACHIEVEMENT_SEARCH_COROUTINE_END_TIME = 0

local ACHIEVEMENT_SEARCH_CATEGORY_LIST = {
	[1] = {},
	[2] = {},
};

local searchCategoryInfo = {
	CategoryID = 1,
	NumAchievements = 2,
};

local ACHIEVEMENT_SEARCH_COROUTINE

function GetNumFilteredAchievements()
	return #ACHIEVEMENT_SEARCH_RESULTS;
end

function GetFilteredAchievementID(index)
	return ACHIEVEMENT_SEARCH_RESULTS[index];
end

local function AchievementSearchCoroutine()
	for _, categoryInfo in ipairs(ACHIEVEMENT_SEARCH_CATEGORY_LIST[ACHIEVEMENT_SEARCH_TAB]) do
		for index = 1, categoryInfo[searchCategoryInfo.NumAchievements] do
			if debugprofilestop() > ACHIEVEMENT_SEARCH_COROUTINE_END_TIME then
				coroutine.yield();
			end

			local id, name, _, _, _, _, _, description = GetAchievementInfo(categoryInfo[searchCategoryInfo.CategoryID], index);
			if string.find(string.lower(name), ACHIEVEMENT_SEARCH_TEXT, 1, true) or string.find(string.lower(description), ACHIEVEMENT_SEARCH_TEXT, 1, true) then
				ACHIEVEMENT_SEARCH_RESULTS[#ACHIEVEMENT_SEARCH_RESULTS + 1] = id;
			end

			ACHIEVEMENT_SEARCH_PROGRESS = ACHIEVEMENT_SEARCH_PROGRESS + 1;
		end
	end
end

function SetAchievementSearchString(searchText)
	ACHIEVEMENT_SEARCH_PROGRESS = 0;
	table.wipe(ACHIEVEMENT_SEARCH_RESULTS);

	searchText = string.lower(searchText);

	ACHIEVEMENT_SEARCH_COROUTINE = coroutine.create(AchievementSearchCoroutine);

	ACHIEVEMENT_SEARCH_TEXT = searchText;

	GetAchievementSearchProgress();

	return false;
end

function SwitchAchievementSearchTab(index)
	if index == 1 or index == 2 then
		if ACHIEVEMENT_SEARCH_TAB ~= index then
			table.wipe(ACHIEVEMENT_SEARCH_CATEGORY_LIST[index]);

			for i, categoryID in ipairs(index == 1 and GetCategoryList() or GetStatisticsCategoryList()) do
				ACHIEVEMENT_SEARCH_CATEGORY_LIST[index][i] = {categoryID, GetCategoryNumAchievements(categoryID)};
			end

			ACHIEVEMENT_SEARCH_TAB = index;

			AchievementFrame.searchBox.fullSearchFinished = false;

			SetAchievementSearchString(ACHIEVEMENT_SEARCH_TEXT);
		end
	end
end

function ClearAchievementSearchString()
	ACHIEVEMENT_SEARCH_TEXT = "";
end

function GetAchievementSearchProgress()
	if ACHIEVEMENT_SEARCH_COROUTINE then
		ACHIEVEMENT_SEARCH_COROUTINE_END_TIME = debugprofilestop() + 2

		coroutine.resume(ACHIEVEMENT_SEARCH_COROUTINE);
		if coroutine.status(ACHIEVEMENT_SEARCH_COROUTINE) == "dead" then
			ACHIEVEMENT_SEARCH_COROUTINE = nil;

			AchievementFrame.searchBox.fullSearchFinished = true;
			AchievementFrame_UpdateSearch();
		end
	end

	return ACHIEVEMENT_SEARCH_PROGRESS;
end

function GetAchievementSearchSize()
	if ACHIEVEMENT_SEARCH_TAB then
		local searchSize = 0

		for _, categoryInfo in ipairs(ACHIEVEMENT_SEARCH_CATEGORY_LIST[ACHIEVEMENT_SEARCH_TAB]) do
			searchSize = searchSize + (categoryInfo[searchCategoryInfo.NumAchievements] or 0)
		end

		return searchSize;
	end

	return 0;
end

local ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS = 5;
local ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX = ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS + 1;

local function GetSafeScrollChildBottom(scrollChild)
	return scrollChild:GetBottom() or 0;
end

function AchievementFrame_SelectStatisticByAchievementID(achievementID, isComparison)
	local achievementFunctions
	if ( isComparison ) then
		AchievementFrameTab_OnClick = AchievementFrameComparisonTab_OnClick;
		AchievementFrameComparisonStatsContainer:Show();
		AchievementFrameComparisonSummary:Hide();
		achievementFunctions = COMPARISON_STAT_FUNCTIONS;
	else
		AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick;
		AchievementFrameStats:Show();
		AchievementFrameSummary:Hide();
		achievementFunctions = STAT_FUNCTIONS;
	end

	AchievementFrameTab_OnClick(2);

	AchievementFrameCategories_ClearSelection();

	local category = GetAchievementCategory(achievementID);

	local parent;
	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == category ) then
			parent = entry.parent;
		end
	end

	for i, entry in next, ACHIEVEMENTUI_CATEGORIES do
		if ( entry.id == parent ) then
			entry.collapsed = false;
		elseif ( entry.parent == parent ) then
			entry.hidden = false;
		elseif ( entry.parent == true ) then
			entry.collapsed = true;
		elseif ( entry.parent ) then
			entry.hidden = true;
		end
	end

	achievementFunctions.selectedCategory = category;
	AchievementFrameCategories_Update();
	AchievementFrameCategoriesContainerScrollBar:SetValue(0);

	local shown = false;
	while ( not shown ) do
		for _, button in next, AchievementFrameCategoriesContainer.buttons do
			if ( button.categoryID == category and math.ceil(button:GetBottom()) >= math.ceil(GetSafeScrollChildBottom(AchievementFrameAchievementsContainerScrollChild)) ) then
				shown = true;
			end
		end

		if ( not shown ) then
			local _, maxVal = AchievementFrameCategoriesContainerScrollBar:GetMinMaxValues();
			if ( AchievementFrameCategoriesContainerScrollBar:GetValue() == maxVal ) then
				assert(false)
			elseif AchievementFrameCategoriesContainerScrollBar:IsVisible() then
				HybridScrollFrame_OnMouseWheel(AchievementFrameCategoriesContainer, -1);
			else
				break;
			end
		end
	end

	local container, child, scrollBar = AchievementFrameStatsContainer, AchievementFrameStatsContainerScrollChild, AchievementFrameStatsContainerScrollBar;
	if ( isComparison ) then
		container = AchievementFrameComparisonStatsContainer;
		child = AchievementFrameComparisonStatsContainerScrollChild;
		scrollBar = AchievementFrameComparisonStatsContainerScrollBar;
	end

	achievementFunctions.updateFunc();
	scrollBar:SetValue(0);

	shown = false;
	while ( not shown ) do
		for _, button in next, container.buttons do
			if ( button.id == achievementID and math.ceil(button:GetBottom()) >= math.ceil(GetSafeScrollChildBottom(child)) ) then
				if ( not isComparison ) then
					AchievementStatButton_OnClick(button);
				end

				-- We found the button! MAKE IT SHOWN ZOMG!
				shown = button;
			end
		end

		if ( shown and scrollBar:IsShown() ) then
			-- If we can, move the achievement we're scrolling to to the top of the screen.
			scrollBar:SetValue(scrollBar:GetValue() + container:GetTop() - shown:GetTop());
		elseif ( not shown ) then
			local _, maxVal = scrollBar:GetMinMaxValues();
			if ( scrollBar:GetValue() == maxVal ) then
				assert(false)
			elseif scrollBar:IsVisible() then
				HybridScrollFrame_OnMouseWheel(container, -1);
			else
				break;
			end
		end
	end
end

function AchievementFrame_HideSearchPreview()
	local searchPreviewContainer = AchievementFrame.searchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	searchPreviewContainer:Hide();

	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		searchPreviews[index]:Hide();
	end

	searchPreviewContainer.showAllSearchResults:Hide();
	AchievementFrame.searchProgressBar:Hide();
end

function AchievementFrame_UpdateSearchPreview()
	if ( not AchievementFrame.searchBox:HasFocus() or strlen(AchievementFrame.searchBox:GetText()) < MIN_CHARACTER_SEARCH) then
		AchievementFrame_HideSearchPreview();
		return;
	end

	AchievementFrame.searchBox.searchPreviewUpdateDelay = 0;

	if ( AchievementFrame.searchBox:GetScript("OnUpdate") == nil ) then
		AchievementFrame.searchBox:SetScript("OnUpdate", AchievementFrameSearchBox_OnUpdate);
	end
end

-- There is a delay before the search is updated to avoid a search progress bar if the search
-- completes within the grace period.
local ACHIEVEMENT_SEARCH_PREVIEW_UPDATE_DELAY = 0.3;
function AchievementFrameSearchBox_OnUpdate (self, elapsed)
	if ( self.fullSearchFinished ) then
		AchievementFrame_ShowSearchPreviewResults();
		self.searchPreviewUpdateDelay = 0;
		self:SetScript("OnUpdate", nil);
		return;
	end

	self.searchPreviewUpdateDelay = self.searchPreviewUpdateDelay + elapsed;

	if ( self.searchPreviewUpdateDelay > ACHIEVEMENT_SEARCH_PREVIEW_UPDATE_DELAY ) then
		self.searchPreviewUpdateDelay = 0;
		self:SetScript("OnUpdate", nil);

		if ( AchievementFrame.searchProgressBar:GetScript("OnUpdate") == nil ) then
			AchievementFrame.searchProgressBar:SetScript("OnUpdate", AchievementFrameSearchProgressBar_OnUpdate);

			local searchPreviewContainer = AchievementFrame.searchPreviewContainer;
			local searchPreviews = searchPreviewContainer.searchPreviews;
			for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
				searchPreviews[index]:Hide();
			end

			searchPreviewContainer.showAllSearchResults:Hide();

			searchPreviewContainer.borderAnchor:SetPoint("BOTTOM", 0, -5);
			searchPreviewContainer.background:Show();
			searchPreviewContainer:Show();

			AchievementFrame.searchProgressBar:Show();
			return;
		end
	end
end

-- If the searcher does not finish within the update delay then a search progress bar is displayed that
-- will fill until the search is finished and then display the search preview results.
function AchievementFrameSearchProgressBar_OnUpdate(self, elapsed)
	local _, maxValue = self:GetMinMaxValues();
	local actualProgress = GetAchievementSearchProgress() / GetAchievementSearchSize() * maxValue;

	if ( actualProgress >= maxValue ) then
		self:SetScript("OnUpdate", nil);
		self:SetValue(0);
		AchievementFrame_ShowSearchPreviewResults();
	else
		self:SetValue(actualProgress);
	end
end

function AchievementFrame_ShowSearchPreviewResults()
	AchievementFrame.searchProgressBar:Hide();

	local numResults = GetNumFilteredAchievements();

	if ( numResults > 0 ) then
		AchievementFrame_SetSearchPreviewSelection(1);
	end

	local searchPreviewContainer = AchievementFrame.searchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	local lastButton;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		local searchPreview = searchPreviews[index];
		if ( index <= numResults ) then
			local achievementID = GetFilteredAchievementID(index);
			local _, name, _, _, _, _, _, description, _, icon = GetAchievementInfo(achievementID);
			searchPreview.name:SetText(name);
			searchPreview.icon:SetTexture(icon);
			searchPreview.achievementID = achievementID;
			searchPreview:Show();
			lastButton = searchPreview;
		else
			searchPreview.achievementID = nil;
			searchPreview:Hide();
		end
	end

	if ( numResults > 5 ) then
		searchPreviewContainer.showAllSearchResults:Show();
		lastButton = searchPreviewContainer.showAllSearchResults;
		searchPreviewContainer.showAllSearchResults.text:SetText(string.format(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults));
	else
		searchPreviewContainer.showAllSearchResults:Hide();
	end

	if (lastButton) then
		searchPreviewContainer.borderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -8);
		searchPreviewContainer.background:Hide();
		searchPreviewContainer:Show();
	else
		searchPreviewContainer:Hide();
	end
end

function AchievementFrameSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	if ( strlen(self:GetText()) >= MIN_CHARACTER_SEARCH ) then
		AchievementFrame.searchBox.fullSearchFinished = SetAchievementSearchString(self:GetText());
		if ( not AchievementFrame.searchBox.fullSearchFinished ) then
			AchievementFrame_UpdateSearchPreview();
		else
			AchievementFrame_ShowSearchPreviewResults();
		end
	else
		AchievementFrame_HideSearchPreview();
	end
end

function AchievementFrameSearchBox_OnLoad(self)
	SearchBoxTemplate_OnLoad(self);
	self.HasStickyFocus = function()
		local ancestry = self:GetParent().searchPreviewContainer;
		return DoesAncestryInclude(ancestry, GetMouseFocus());
	end
end

function AchievementFrameSearchBox_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 7);
	AchievementFrame_SetSearchPreviewSelection(1);
	self.fullSearchFinished = false;
	self.searchPreviewUpdateDelay = 0;
end

function AchievementFrameSearchBox_OnEnterPressed(self)
	-- If the search is not finished yet we have to wait to show the full search results.
	if ( not self.fullSearchFinished or strlen(self:GetText()) < MIN_CHARACTER_SEARCH ) then
		return;
	end

	local searchPreviewContainer = AchievementFrame.searchPreviewContainer;
	if ( self.selectedIndex == ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX ) then
		if ( searchPreviewContainer.showAllSearchResults:IsShown() ) then
			searchPreviewContainer.showAllSearchResults:Click();
		end
	else
		local preview = searchPreviewContainer.searchPreviews[self.selectedIndex];
		if ( preview:IsShown() ) then
			preview:Click();
		end
	end
end

function AchievementFrameSearchBox_OnFocusLost(self)
	SearchBoxTemplate_OnEditFocusLost(self);
	AchievementFrame_HideSearchPreview();
end

function AchievementFrameSearchBox_OnFocusGained(self)
	SearchBoxTemplate_OnEditFocusGained(self);
	AchievementFrame.searchResults:Hide();
	AchievementFrame_UpdateSearchPreview();
end

function AchievementFrame_SetSearchPreviewSelection(selectedIndex)
	local searchPreviewContainer = AchievementFrame.searchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	local numShown = 0;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		local searchPreview = searchPreviews[index];
		searchPreview.selectedTexture:Hide();

		if ( searchPreview:IsShown() ) then
			numShown = numShown + 1;
		end
	end

	if ( searchPreviewContainer.showAllSearchResults:IsShown() ) then
		numShown = numShown + 1;
	end

	searchPreviewContainer.showAllSearchResults.selectedTexture:Hide();

	if ( numShown <= 0 ) then
		-- Default to the first entry.
		selectedIndex = 1;
	else
		selectedIndex = (selectedIndex - 1) % numShown + 1;
	end

	AchievementFrame.searchBox.selectedIndex = selectedIndex;

	if ( selectedIndex == ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX ) then
		searchPreviewContainer.showAllSearchResults.selectedTexture:Show();
	else
		searchPreviewContainer.searchPreviews[selectedIndex].selectedTexture:Show();
	end
end

function AcheivementFullSearchResultsButton_OnLoad(self)
	self.normalTexture:SetDrawLayer("BACKGROUND");
	self.pushedTexture:SetDrawLayer("BACKGROUND");
end

function AcheivementFullSearchResultsButton_OnClick(self)
	if (self.achievementID) then
		AchievementFrame_SelectSearchItem(self.achievementID);
		AchievementFrame.searchResults:Hide();
	end
end

function AchievementFrame_ShowFullSearch()
	AchievementFrame_UpdateFullSearchResults();

	if ( GetNumFilteredAchievements() == 0 ) then
		AchievementFrame.searchResults:Hide();
		return;
	end

	AchievementFrame_HideSearchPreview();
	AchievementFrame.searchBox:ClearFocus();
	AchievementFrame.searchResults:Show();
end

function AchievementFrame_UpdateFullSearchResults()
	local numResults = GetNumFilteredAchievements();

	local scrollFrame = AchievementFrame.searchResults.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local results = scrollFrame.buttons;
	local result, index;

	for i = 1,#results do
		result = results[i];
		index = offset + i;
		if ( index <= numResults ) then
			local achievementID = GetFilteredAchievementID(index);
			local _, name, _, completed, _, _, _, description, _, icon, _, _, _, _ = GetAchievementInfo(achievementID);

			result.name:SetText(name);
			result.icon:SetTexture(icon);
			result.achievementID = achievementID;

			if ( completed ) then
				result.resultType:SetText(ACHIEVEMENTFRAME_FILTER_COMPLETED);
			else
				result.resultType:SetText(ACHIEVEMENTFRAME_FILTER_INCOMPLETE);
			end

			local categoryID = GetAchievementCategory(achievementID);
			local categoryName, parentCategoryID = GetCategoryInfo(categoryID);
			path = categoryName;
			while ( not (parentCategoryID == -1) ) do
				categoryName, parentCategoryID = GetCategoryInfo(parentCategoryID);
				path = categoryName.." > "..path;
			end

			result.path:SetText(path);

			result:Show();
		else
			result:Hide();
		end
	end

	local totalHeight = numResults * 49;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 270);

	AchievementFrame.searchResults.titleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, AchievementFrame.searchBox:GetText(), numResults));
end

function AchievementFrame_SelectSearchItem(id)
	local flags = select(9, GetAchievementInfo(id));
	if ( bit.band(flags, ACHIEVEMENT_FLAGS_STATISTIC) == ACHIEVEMENT_FLAGS_STATISTIC ) then
		AchievementFrame_SelectStatisticByAchievementID(id, AchievementFrameComparison:IsShown());
	else
		AchievementFrame_SelectAchievement(id, true, AchievementFrameComparison:IsShown());
	end
end

function AchievementSearchPreviewButton_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function AchievementSearchPreviewButton_OnLoad(self)
	self.normalTexture:SetDrawLayer("BACKGROUND");
	self.pushedTexture:SetDrawLayer("BACKGROUND");

	self:SetParentArray("searchPreviews");

	local searchPreviewContainer = AchievementFrame.searchPreviewContainer;
	local searchPreviews = searchPreviewContainer.searchPreviews;
	for index = 1, ACHIEVEMENT_FRAME_NUM_SEARCH_PREVIEWS do
		if ( searchPreviews[index] == self ) then
			self.previewIndex = index;
			break;
		end
	end
end

function AchievementSearchPreviewButton_OnEnter(self)
	AchievementFrame_SetSearchPreviewSelection(self.previewIndex);
end

function AchievementSearchPreviewButton_OnClick(self)
	if ( self.achievementID ) then
		AchievementFrame_SelectSearchItem(self.achievementID);
		AchievementFrame.searchResults:Hide();
		AchievementFrame_HideSearchPreview();
		AchievementFrame.searchBox:ClearFocus();
	end
end

function AchievementFrameShowAllSearchResults_OnEnter()
	AchievementFrame_SetSearchPreviewSelection(ACHIEVEMENT_FRAME_SHOW_ALL_RESULTS_INDEX);
end

function AchievementFrame_UpdateSearch()
	if ( AchievementFrame.searchResults:IsShown() ) then
		AchievementFrame_UpdateFullSearchResults();
	else
		AchievementFrame_UpdateSearchPreview();
	end
end

local init = false
function InitCustonAchievementUI()
	if init then
		return;
	end

	AchievementFrameHeader:CreateTexture("$parentLeftDDLInset", "BORDER", "CustomAchievementHeaderLeftDDLInset");

	AchievementFrameHeaderRightDDLInset:ClearAllPoints();
	AchievementFrameHeaderRightDDLInset:SetPoint("TOPLEFT", 112, -56);

	AchievementFrameFilterDropDown:ClearAllPoints();
	AchievementFrameFilterDropDown:SetPoint("TOPLEFT", 148, 10);

	CreateFrame("EditBox", "$parentSearchBox", AchievementFrame, "CustomAchievementSearchBox");
	CreateFrame("Frame", "$parentSearchPreviewContainer", AchievementFrame, "CustomAchievementSearchPreviewContainer");
	CreateFrame("StatusBar", "$parentSearchProgressBar", AchievementFrame, "CustomAchievementSearchProgressBar");
	CreateFrame("Frame", "$parentSearchResults", AchievementFrame, "CustomAchievementSearchResults");

	AchievementFrame:HookScript("OnHide", function(self)
		AchievementFrame_HideSearchPreview();
		self.searchResults:Hide();
		self.searchBox:SetText("");
	end);

	local old_AchievementFrameBaseTab_OnClick = AchievementFrameBaseTab_OnClick;
	function AchievementFrameBaseTab_OnClick(id)
		AchievementFrame.searchResults:Hide();
		old_AchievementFrameBaseTab_OnClick(id);
		SwitchAchievementSearchTab(id);
	end

	local old_AchievementFrameComparisonTab_OnClick = AchievementFrameComparisonTab_OnClick;
	function AchievementFrameComparisonTab_OnClick(id)
		AchievementFrame.searchResults:Hide();
		old_AchievementFrameComparisonTab_OnClick(id);
		SwitchAchievementSearchTab(id);
	end

	function AchievementFrameComparison_UpdateStatusBars(id)
		if not id then
			return;
		end

		local numAchievements, numCompleted = GetCategoryNumAchievements(id);
		local name = GetCategoryInfo(id);

		if id == ACHIEVEMENT_COMPARISON_SUMMARY_ID then
			name = ACHIEVEMENT_SUMMARY_CATEGORY;
		end

		local statusBar = AchievementFrameComparisonSummaryPlayerStatusBar;
		statusBar:SetMinMaxValues(0, numAchievements);
		statusBar:SetValue(numCompleted);
		statusBar.title:SetText(string.format(ACHIEVEMENTS_COMPLETED_CATEGORY, name));
		statusBar.text:SetText(numCompleted.."/"..numAchievements);

		local friendCompleted = GetComparisonCategoryNumAchievements(id);

		statusBar = AchievementFrameComparisonSummaryFriendStatusBar;
		statusBar:SetMinMaxValues(0, numAchievements);
		statusBar:SetValue(friendCompleted);
		statusBar.text:SetText(friendCompleted.."/"..numAchievements);
	end

	init = true;
end