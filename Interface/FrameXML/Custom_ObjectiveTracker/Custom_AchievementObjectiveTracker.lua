local settings = {
	headerText = TRACKER_HEADER_ACHIEVEMENTS,
	events = {"TRACKED_ACHIEVEMENT_UPDATE", "ACHIEVEMENT_EARNED", "CRITERIA_DELETE"},
	timedCriteria = {},
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
	collapseType = Enum.ObjectiveTrackerCollapsedStateType.AchievementTracker
};

AchievementObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

local ARENA_CATEGORY = 165;
local MAX_CRITERIA_PER_ACHIEVEMENT = 5;
local TRACKING_ACHIEVEMENTS = {}

function AchievementObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "TRACKED_ACHIEVEMENT_UPDATE" then
		local achievementID, criteriaID, elapsed, duration = ...;
		if not elapsed or not duration then
			-- Don't do anything
		elseif elapsed >= duration then
			self.timedCriteria[criteriaID] = nil;
		else
			local now = GetTime()
			local timedCriteria = self.timedCriteria[criteriaID]
			if not timedCriteria then
				timedCriteria = {
					startTime = now - elapsed,
					achievementID = achievementID,
					duration = duration,
				}
				self.timedCriteria[criteriaID] = timedCriteria
			elseif math.ceil(now - timedCriteria.startTime) ~= elapsed then
				timedCriteria.startTime = now - elapsed
			end
		end
		self:MarkDirty();
	elseif event == "ACHIEVEMENT_EARNED" then
		local achievementID = ...;
		local block = self:GetExistingBlock(achievementID);
		if block then
			block:PlayTurnInAnimation();
		end
	elseif event == "CRITERIA_DELETE" then
		local achievementID = ...;
		local block = self:GetExistingBlock(achievementID);
		if block then
			self:MarkDirty();
		end
	end
end

function AchievementObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	local achievementID = block.id;
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local achievementLink = GetAchievementLink(achievementID);
		if achievementLink then
			ChatEdit_InsertLink(achievementLink);
		end
	elseif mouseButton ~= "RightButton" then
		CloseDropDownMenus();
		if not AchievementFrame then
			AchievementFrame_LoadUI();
		end
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			self:UntrackAchievement(achievementID);
		elseif not AchievementFrame:IsShown() then
			AchievementFrame_ToggleAchievementFrame();
			AchievementFrame_SelectAchievement(achievementID);
		else
			if AchievementFrameAchievements.selection ~= achievementID then
				AchievementFrame_SelectAchievement(achievementID);
			else
				AchievementFrame_ToggleAchievementFrame();
			end
		end
	else
		self:ToggleDropDown(block);
	end
end

function AchievementObjectiveTrackerMixin:InitDropDown(block)
	local _, achievementName, _, completed, _, _, _, _, _, icon = GetAchievementInfo(block.id);

	local info = UIDropDownMenu_CreateInfo();
	info.text = achievementName;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	info.text = OBJECTIVES_VIEW_ACHIEVEMENT;
	info.func = function() OpenAchievementFrameToAchievement(block.id); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = function() self:UntrackAchievement(block.id); end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function AchievementObjectiveTrackerMixin:UntrackAchievement(achievementID)
	RemoveTrackedAchievement(achievementID);
	if AchievementFrameAchievements_ForceUpdate then
		AchievementFrameAchievements_ForceUpdate();
	end
end

function AchievementObjectiveTrackerMixin:LayoutContents()
	local _, instanceType = IsInInstance()
	local displayOnlyArena = instanceType == "arena"

	local numTrackedAchievements = GetNumTrackedAchievements();
	local trackedAchievements = {GetTrackedAchievements()};

	if self.numTrackedAchievements ~= numTrackedAchievements then
		for _, achievementID in ipairs(trackedAchievements) do
			if not TRACKING_ACHIEVEMENTS[achievementID] then
				self:SetNeedsFanfare(achievementID)
				TRACKING_ACHIEVEMENTS[achievementID] = true
			end
		end
		for achievementID in pairs(TRACKING_ACHIEVEMENTS) do
			if not tContainsValue(trackedAchievements, achievementID) then
				TRACKING_ACHIEVEMENTS[achievementID] = nil
			end
		end
		self.numTrackedAchievements = numTrackedAchievements
	end

	local isFiltered = GetCVarBitfield("objectiveTrackerFilter", Enum.ObjectiveTrackerFilter.Achievements)

	for _, achievementID in ipairs(trackedAchievements) do
		local _, achievementName, _, completed, _, _, _, description, _, icon = GetAchievementInfo(achievementID);
		-- check filters
		local showAchievement = true;
		if displayOnlyArena then
			if GetAchievementCategory(achievementID) ~= ARENA_CATEGORY then
				showAchievement = false;
			end
		end

		if showAchievement then
			if isFiltered and not self.isFiltered then
				self.isFiltered = isFiltered
			end

			if not self:AddAchievement(achievementID, achievementName, description) then
				return;
			end
		end
	end
end

function AchievementObjectiveTrackerMixin:AddAchievement(achievementID, achievementName, description)
	local block = self:GetBlock(achievementID);
	block:SetHeader(achievementName);
	-- criteria
	local numCriteria = GetAchievementNumCriteria(achievementID);
	if numCriteria > 0 then
		local numShownCriteria = 0;
		for criteriaIndex = 1, numCriteria do
			local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, name, flags, assetID, quantityString, criteriaID = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
			if criteriaCompleted or (numShownCriteria > MAX_CRITERIA_PER_ACHIEVEMENT and not criteriaCompleted) then
				-- Do not display this one
			elseif numShownCriteria == MAX_CRITERIA_PER_ACHIEVEMENT and numCriteria > (MAX_CRITERIA_PER_ACHIEVEMENT + 1) then
				-- We ran out of space to display incomplete criteria >_<
				block:AddObjective("Extra", "...", nil, nil, OBJECTIVE_DASH_STYLE_HIDE);
				numShownCriteria = numShownCriteria + 1;
			else
				if description and bit.band(flags, ACHIEVEMENT_CRITERIA_PROGRESS_BAR) == ACHIEVEMENT_CRITERIA_PROGRESS_BAR then
					-- progress bar
					if string.find(strlower(quantityString), "interface\\moneyframe") then	-- no easy way of telling it's a money progress bar
						criteriaString = quantityString.."\n"..description;
					else
						-- remove spaces so it matches the quest look, x/y
						criteriaString = string.gsub(quantityString, " / ", "/").." "..description;
					end
				else
					-- regular criteria
					if criteriaString and quantity and totalQuantity and totalQuantity > 1 then
						criteriaString = string.format("%d / %d %s", quantity, totalQuantity, criteriaString)
					else
						-- criteriaString and dash are already set for regular criteria
						-- for meta criteria look up the achievement name
						if criteriaType == CRITERIA_TYPE_ACHIEVEMENT and assetID then
							_, criteriaString = GetAchievementInfo(assetID);
						end
					end
				end
				local line = block:AddObjective(criteriaIndex, criteriaString, nil, nil, OBJECTIVE_DASH_STYLE_SHOW);
				if self.timedCriteria[criteriaID] then
					local timedCriteria = self.timedCriteria[criteriaID]
					local elapsed = GetTime() - timedCriteria.startTime
					if elapsed <= timedCriteria.duration then
						block:AddTimerBar(timedCriteria.duration, timedCriteria.startTime)
					end
				end
				numShownCriteria = numShownCriteria + 1;
			end
		end
	else
		-- single criteria type of achievement
		-- check if we're supposed to show a timer bar for this
		local timerShown = false;
		local timerFailed = false;
		local timerCriteriaDuration = 0;
		local timerCriteriaStartTime = 0;
		for timedCriteriaID, timedCriteria in pairs(self.timedCriteria) do
			if timedCriteria.achievementID == achievementID then
				local elapsed = GetTime() - timedCriteria.startTime;
				if elapsed <= timedCriteria.duration then
					timerCriteriaDuration = timedCriteria.duration;
					timerCriteriaStartTime = timedCriteria.startTime;
					timerShown = true;
				else
					timerFailed = true;
				end
				break;
			end
		end
		local colorStyle = (not timerFailed) and OBJECTIVE_TRACKER_COLOR["Normal"] or OBJECTIVE_TRACKER_COLOR["Failed"];
		local line = block:AddObjective(1, description, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, colorStyle);
		if timerShown then
			block:AddTimerBar(timerCriteriaDuration, timerCriteriaStartTime);
		end
	end

	return self:LayoutBlock(block);
end
