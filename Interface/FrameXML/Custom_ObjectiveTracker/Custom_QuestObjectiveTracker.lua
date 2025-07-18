local settings = {
	headerText = TRACKER_HEADER_QUESTS,
	events = {"QUEST_LOG_UPDATE", "PLAYER_ENTERING_WORLD", "ITEM_PUSH", "ZONE_CHANGED_NEW_AREA", "WORLD_MAP_UPDATE", "QUEST_POI_UPDATE", "PLAYER_MONEY"},
	lineTemplate = "QuestObjectiveLineTemplate",
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	rightEdgeFrameSpacing = 2,
	-- for this module
	questItemButtonSettings = {
		template = "QuestObjectiveItemButtonTemplate",
		templateType = "Button",
		offsetX = 0,
		offsetY = 0,
	},
	timedQuest = {},
	numTimedQuests = 0,
	numPOINumeric = 0,
	numPOICompleteIn = 0,
	numPOICompleteOut = 0,
	collapseType = Enum.ObjectiveTrackerCollapsedStateType.QuestTracker
};

local TRACKING_QUESTS = {}

QuestObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

local SORT_PROXIMITY = 1
local SORT_DIFFICULTY_HIGH = 2
local SORT_DIFFICULTY_LOW = 3
local SORT_MANUAL = 0

local SORT_TYPE = 0
local UPDATE_RATE = 1

CURRENT_MAP_QUESTS = {}
LOCAL_MAP_QUESTS = {}
VISIBLE_WATCHES = {}

function QuestObjectiveTrackerMixin:InitModule()
	SetMapToCurrentZone()

	self:AddTag("quest");
	self:WatchMoney(false);

	self:SetSorting(tonumber(GetCVar("trackerSorting")) or 0)
end

function QuestObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "PLAYER_MONEY" then
		if self.watchMoney then
			self:MarkDirty()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		SetMapToCurrentZone()
	elseif event == "QUEST_LOG_UPDATE" then
		if ObjectiveTrackerManager:CanShowPOIs(self) then
			self:GetCurrentMapQuests()
		end
		self:MarkDirty()
	elseif event == "ITEM_PUSH" then
		self:MarkDirty()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		if not WorldMapFrame:IsShown() and ObjectiveTrackerManager:CanShowPOIs(self) then
			SetMapToCurrentZone()			-- update the zone to get the right POI numbers for the tracker
		end
	elseif event == "WORLD_MAP_UPDATE" or event == "QUEST_POI_UPDATE" and ObjectiveTrackerManager:CanShowPOIs(self) then
		self:GetCurrentMapQuests()
		self:MarkDirty()
	else
		self:MarkDirty()
	end
end

function QuestObjectiveTrackerMixin:OnUpdate(elapsed)
	if SORT_TYPE == SORT_PROXIMITY then
		self.updateTimer = self.updateTimer - elapsed
		if self.updateTimer <= 0 then
			if SortQuestWatches() then
				self:MarkDirty()
			end
			self.updateTimer = UPDATE_RATE
		end
	end
end

function QuestObjectiveTrackerMixin:OnHeaderFilterButtonClick(button, mouseButton)
	local dropDown = self.Header.FilterDropDown
	if not dropDown.initialize then
		UIDropDownMenu_Initialize(dropDown, nil, "MENU")
	end

	dropDown.initialize = GenerateClosure(self.InitFilterDropDown, self)
	ToggleDropDownMenu(1, nil, dropDown, button, 15, 15)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function QuestObjectiveTrackerMixin:InitFilterDropDown()
	local info = UIDropDownMenu_CreateInfo()
	-- sort label
	info.text = TRACKER_SORT_LABEL
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	-- sort: proximity
	info = UIDropDownMenu_CreateInfo()
	info.checked = SORT_TYPE == SORT_PROXIMITY
	info.text = TRACKER_SORT_PROXIMITY
	info.tooltipTitle = TRACKER_SORT_PROXIMITY
	info.tooltipText = TOOLTIP_TRACKER_SORT_PROXIMITY
	info.func = function() self:SetSorting(SORT_PROXIMITY) end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	-- sort: difficulty high
	info = UIDropDownMenu_CreateInfo()
	info.checked = SORT_TYPE == SORT_DIFFICULTY_HIGH
	info.text = TRACKER_SORT_DIFFICULTY_HIGH
	info.tooltipTitle = TRACKER_SORT_DIFFICULTY_HIGH
	info.tooltipText = TOOLTIP_TRACKER_SORT_DIFFICULTY_HIGH
	info.func = function() self:SetSorting(SORT_DIFFICULTY_HIGH) end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	-- sort: difficulty low
	info = UIDropDownMenu_CreateInfo()
	info.checked = SORT_TYPE == SORT_DIFFICULTY_LOW
	info.text = TRACKER_SORT_DIFFICULTY_LOW
	info.tooltipTitle = TRACKER_SORT_DIFFICULTY_LOW
	info.tooltipText = TOOLTIP_TRACKER_SORT_DIFFICULTY_LOW
	info.func = function() self:SetSorting(SORT_DIFFICULTY_LOW) end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	-- sort: manual
	info = UIDropDownMenu_CreateInfo()
	info.checked = SORT_TYPE == SORT_MANUAL
	info.text = TRACKER_SORT_MANUAL
	info.tooltipTitle = TRACKER_SORT_MANUAL
	info.tooltipText = TOOLTIP_TRACKER_SORT_MANUAL
	info.func = function() self:SetSorting(SORT_MANUAL) end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

function QuestObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local questLink = GetQuestLink(GetQuestIndexForWatch(block.index))
		if questLink then
			ChatEdit_InsertLink(questLink)
		end
	elseif mouseButton ~= "RightButton" then
		CloseDropDownMenus()
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			self:StopTrackingQuest(block.index)
		else
			local questLogIndex = GetQuestIndexForWatch(block.index)
			ExpandQuestHeader(GetQuestSortIndex(questLogIndex))
			-- you have to call GetQuestIndexForWatch again because ExpandQuestHeader will sort the indices
			QuestLog_OpenToQuest(questLogIndex)
		end
	else
		self:ToggleDropDown(block)
	end
end

function QuestObjectiveTrackerMixin:InitDropDown(block)
	local index = block.index

	local info = UIDropDownMenu_CreateInfo()
	local questLogIndex = GetQuestIndexForWatch(index)
	info.text = GetQuestLogTitle(questLogIndex)
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1

	info.text = OBJECTIVES_VIEW_IN_QUESTLOG
	info.func = function() self:OpenQuestLog(index, true) end
	info.noClickSound = 1
	info.checked = false
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info.text = OBJECTIVES_STOP_TRACKING
	info.func = function() self:StopTrackingQuest(index) end
	info.checked = false
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	if GetQuestLogPushable(GetQuestIndexForWatch(index)) and (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1) then
		info.text = SHARE_QUEST
		info.func = function() self:ShareQuest(index) end
		info.checked = false
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	end

	if ObjectiveTrackerManager:CanShowPOIs(self) then
		info.text = OBJECTIVES_SHOW_QUEST_MAP
		info.func = function() self:OpenMapToQuest(index) end
		info.checked = false
		info.noClickSound = 1
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	end

	local numVisibleWatches = #VISIBLE_WATCHES
	if numVisibleWatches > 1 then
		local visibleIndex = self:GetVisibleIndex(questLogIndex)
		if visibleIndex > 1 then
			info.text = TRACKER_SORT_MANUAL_UP
			info.func = function() self:MoveQuest(questLogIndex, -1) end
			info.checked = false
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
			info.text = TRACKER_SORT_MANUAL_TOP
			info.func = function() self:MoveQuest(questLogIndex, -100) end
			info.checked = false
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
		end
		if visibleIndex < numVisibleWatches then
			info.text = TRACKER_SORT_MANUAL_DOWN
			info.func = function() self:MoveQuest(questLogIndex, 1) end
			info.checked = false
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
			info.text = TRACKER_SORT_MANUAL_BOTTOM
			info.func = function() self:MoveQuest(questLogIndex, 100) end
			info.checked = false
			UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
		end
	end
end

function QuestObjectiveTrackerMixin:OnBlockHeaderEnter(block)
	EventRegistry:TriggerEvent("OnQuestBlockHeader.OnEnter", block, block.id, false);
end

function QuestObjectiveTrackerMixin:OnBlockHeaderLeave(block)
	GameTooltip:Hide();
end

function QuestObjectiveTrackerMixin:OnFreeBlock(block)
	block.ItemButton = nil;
end

function QuestObjectiveTrackerMixin:BuildQuestTimers(...)
	local questTimers = select("#", ...)

	table.wipe(self.timedQuest)
	for index = 1, questTimers do
		local questLogIndex = GetQuestIndexForTimer(index)
		self.timedQuest[questLogIndex] = select(index, ...)
	end

	self.numTimedQuests = questTimers
end

function QuestObjectiveTrackerMixin:BuildQuestWatchInfos()
	self.playerMoney = GetMoney()

	self.numPOINumeric = 0
	self.numPOICompleteIn = 0
	self.numPOICompleteOut = 0

	local numVisible = 0

	local infos = {};
	local trackedQuests = {}
	for index = 1, GetNumQuestWatches() do
		local questLogIndex = GetQuestIndexForWatch(index)
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(questLogIndex)

		table.insert(trackedQuests, questID)

		if not TRACKING_QUESTS[questID] then
			TRACKING_QUESTS[questID] = true
			self:SetNeedsFanfare(questID)
		end

		if self:ShouldDisplayQuest() then
			table.insert(infos, index);
			numVisible = numVisible + 1;
			table.insert(VISIBLE_WATCHES, numVisible, questLogIndex) -- save the quest log index because watch order can change after dropdown is opened
		end
	end

	for questID in pairs(TRACKING_QUESTS) do
		if not tContainsValue(trackedQuests, questID) then
			TRACKING_QUESTS[questID] = nil
		end
	end

	return infos
end

function QuestObjectiveTrackerMixin:EnumQuestWatchData(func)
	local infos = self:BuildQuestWatchInfos();
	for _, index in ipairs(infos) do
		if not func(self, index) then
			return;
		end
	end
end

function QuestObjectiveTrackerMixin:DoQuestObjectives(block, questCompleted, isExistingBlock, useFullHeight)
	local questLogIndex = GetQuestIndexForWatch(block.index)

	local objectiveCompleting = false;
	local numObjectives = GetNumQuestLeaderBoards(questLogIndex);

	for objectiveIndex = 1, numObjectives do
		local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questLogIndex);
		if text and text ~= "" then
			local line = block:GetExistingLine(objectiveIndex);
			if questCompleted then
				-- only process existing lines that have not faded
				if line and line.state ~= ObjectiveTrackerAnimLineState.Faded then
					line = block:AddObjective(objectiveIndex, text, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
					-- don't do anything else if a line is either COMPLETING or FADING, the anims' OnFinished will continue the process
					if not line.state or line.state == ObjectiveTrackerAnimLineState.Present then
						-- this objective wasn't marked finished
						line:SetState(ObjectiveTrackerAnimLineState.Completing);
					end
				end
			else
				if not finished then
					if not objectiveCompleting then
						text = self:ReverseQuestObjective(text, objectiveType);
						-- new objectives need to animate in
						line = block:AddObjective(objectiveIndex, text, nil, useFullHeight);
						-- some quest objectives can be undone
						if line.state == ObjectiveTrackerAnimLineState.Completed then
							line:SetState(ObjectiveTrackerAnimLineState.Present);
						end
					end
				else
					if line and line.state == ObjectiveTrackerAnimLineState.Faded then
						-- don't show this anymore
					elseif line then
						line = block:AddObjective(objectiveIndex, text, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
						if not line.state or line.state == ObjectiveTrackerAnimLineState.Present then
							-- complete this
							line:SetState(ObjectiveTrackerAnimLineState.Completing);
						end
					else
						line = block:AddObjective(objectiveIndex, text, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
						line:SetState(ObjectiveTrackerAnimLineState.Completed);
					end
				end
				if line then
					if line.state == ObjectiveTrackerAnimLineState.Completing then
						objectiveCompleting = true;
					end
				end
			end
		end
	end

	if questCompleted and not objectiveCompleting then
		block:ForEachUsedLine(function(line, objectiveKey)
			if line.state == ObjectiveTrackerAnimLineState.Completed then
				line:SetState(ObjectiveTrackerAnimLineState.Fading);
			end
		end);
	end
	return objectiveCompleting;
end

function QuestObjectiveTrackerMixin:UpdateSingle(index)
	local questLogIndex = GetQuestIndexForWatch(index)
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(questLogIndex)
	local requiredMoney = GetQuestLogRequiredMoney(questLogIndex)
	local numObjectives = GetNumQuestLeaderBoards(questLogIndex)

	local questFailed = false;
	if isComplete and isComplete < 0 then
		isComplete = false;
		questFailed = true;
	elseif numObjectives == 0 and self.playerMoney >= requiredMoney then
		isComplete = true;
	end

	local useFullHeight = true; -- Always use full height of the block for the quest tracker.
	local block, isExistingBlock = self:GetBlock(questID);
	block.index = index

	local link, item, charges = GetQuestLogSpecialItemInfo(questLogIndex)
	if item and not isComplete then
		block.ItemButton = block:AddRightEdgeFrame(self.questItemButtonSettings, questLogIndex);
	end

	block:SetHeader(title);

	if requiredMoney > 0 then
		self:WatchMoney(true);
	end

	if isComplete then
		local objectiveCompleting = self:DoQuestObjectives(block, isComplete, isExistingBlock, useFullHeight);
		if not objectiveCompleting then
			local completionText = GetQuestLogCompletionText(questLogIndex);
			if completionText and completionText ~= "" then
				local forceCompletedToUseFullHeight = true;
				block:AddObjective("QuestComplete", completionText, nil, forceCompletedToUseFullHeight, OBJECTIVE_DASH_STYLE_HIDE);
			else
				block:AddObjective("QuestComplete", QUEST_WATCH_QUEST_READY, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Complete"]);
			end
		end
	elseif questFailed then
		block:AddObjective("Failed", FAILED, nil, useFullHeight, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Failed"]);
	else
		self:DoQuestObjectives(block, isComplete, isExistingBlock, useFullHeight);

		if requiredMoney > self.playerMoney then
			local text = GetMoneyString(self.playerMoney).." / "..GetMoneyString(requiredMoney);
			block:AddObjective("Money", text, nil, useFullHeight);
		end
	end

	if ObjectiveTrackerManager:CanShowPOIs(self) then
		local poiButton
		if CURRENT_MAP_QUESTS[questID] then
			if isComplete then
				self.numPOICompleteIn = self.numPOICompleteIn + 1
				poiButton = QuestPOI_DisplayButton("QuestObjectiveTrackerContentsFrame", QUEST_POI_COMPLETE_IN, self.numPOICompleteIn, questID)
			else
				self.numPOINumeric = self.numPOINumeric + 1
				poiButton = QuestPOI_DisplayButton("QuestObjectiveTrackerContentsFrame", QUEST_POI_NUMERIC, self.numPOINumeric, questID)
			end
		elseif isComplete then
			self.numPOICompleteOut = self.numPOICompleteOut + 1
			poiButton = QuestPOI_DisplayButton("QuestObjectiveTrackerContentsFrame", QUEST_POI_COMPLETE_OUT, self.numPOICompleteOut, questID)
		end
		if poiButton then
			poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", 0, 5)
		end
	end

	local questTimeLeft = self.timedQuest[questLogIndex]
	if questTimeLeft then
		local line = block:AddObjective("QuestTime", string.format(TRACKER_QUEST_TIMERS_FORMAT, SecondsToTime(questTimeLeft)), nil, useFullHeight)
		line:SetCountdown(questTimeLeft, 1)
	end

	return self:LayoutBlock(block);
end

function QuestObjectiveTrackerMixin:WatchMoney(watch)
	if self.watchMoney ~= watch then
		self.watchMoney = watch;
		self.playerMoney = GetMoney();
	end
end

function QuestObjectiveTrackerMixin:LayoutContents()
	table.wipe(VISIBLE_WATCHES)

	local _, instanceType = IsInInstance();
	if instanceType == "arena" then
		-- no quests in arena
		return;
	end

	-- if autoquests ran out of space, we're done
	if self:HasSkippedBlocks() then
		return;
	end

	local selectedQuestID
	if WorldMapFrame and WorldMapFrame:IsShown() then
		selectedQuestID = WORLDMAP_SETTINGS.selectedQuestId
	else
		table.wipe(LOCAL_MAP_QUESTS)
		LOCAL_MAP_QUESTS["zone"] = GetCurrentMapZone()
		for id in pairs(CURRENT_MAP_QUESTS) do
			LOCAL_MAP_QUESTS[id] = true
		end
	end

	self:BuildQuestTimers(GetQuestTimers())
	self:WatchMoney(false);
	self:EnumQuestWatchData(self.UpdateSingle);

	QuestPOI_HideButtons("QuestObjectiveTrackerContentsFrame", QUEST_POI_NUMERIC, self.numPOINumeric + 1)
	QuestPOI_HideButtons("QuestObjectiveTrackerContentsFrame", QUEST_POI_COMPLETE_IN, self.numPOICompleteIn + 1)
	QuestPOI_HideButtons("QuestObjectiveTrackerContentsFrame", QUEST_POI_COMPLETE_OUT, self.numPOICompleteOut + 1)

	if selectedQuestID then
		QuestPOI_SelectButtonByQuestId("QuestObjectiveTrackerContentsFrame", selectedQuestID, true)
	end
end

function QuestObjectiveTrackerMixin:ShouldDisplayQuest()
	return true;
end

function QuestObjectiveTrackerMixin:ReverseQuestObjective(text, objectiveType)
	if objectiveType == "spell" then
		return text
	end
	local _, _, arg1, arg2 = string.find(text, "(.*):%s(.*)")
	if arg1 and arg2 then
		return arg2.." "..arg1
	else
		return text
	end
end

function QuestObjectiveTrackerMixin:GetCurrentMapQuests()
	local numQuests = QuestMapUpdateAllQuests()
	table.wipe(CURRENT_MAP_QUESTS)
	for i = 1, numQuests do
		local questId = QuestPOIGetQuestIDByVisibleIndex(i)
		CURRENT_MAP_QUESTS[questId] = i
	end
end

function QuestObjectiveTrackerMixin:OpenQuestLog(questIndex, keepOpen)
	ExpandQuestHeader(GetQuestIndexForWatch(questIndex))
	-- you have to call GetQuestIndexForWatch again because ExpandQuestHeader will sort the indices
	QuestLog_OpenToQuest(GetQuestIndexForWatch(questIndex), keepOpen)
end

function QuestObjectiveTrackerMixin:StopTrackingQuest(questIndex)
	RemoveQuestWatch(GetQuestIndexForWatch(questIndex))
	self:MarkDirty()
	QuestLog_Update()
end

function QuestObjectiveTrackerMixin:ShareQuest(questIndex)
	QuestLogPushQuest(GetQuestIndexForWatch(questIndex))
end

function QuestObjectiveTrackerMixin:OpenMapToQuest(questIndex)
	local index = GetQuestIndexForWatch(questIndex)
	local questID = select(9, GetQuestLogTitle(index))
	WorldMap_OpenToQuest(questID)
end

function QuestObjectiveTrackerMixin:SetSorting(sortType)
	SORT_TYPE = sortType
	SetCVar("trackerSorting", sortType)

	if SORT_TYPE ~= SORT_MANUAL then
		SortQuestWatches()
		self:MarkDirty()

		if SORT_TYPE == SORT_PROXIMITY then
			self.updateTimer = UPDATE_RATE
			self:SetScript("OnUpdate", self.OnUpdate)
		else
			self:SetScript("OnUpdate", nil)
		end
	else
		self:SetScript("OnUpdate", nil)
	end
end

function QuestObjectiveTrackerMixin:GetVisibleIndex(questLogIndex)
	for i = 1, #VISIBLE_WATCHES do
		if VISIBLE_WATCHES[i] == questLogIndex then
			return i
		end
	end
end

function QuestObjectiveTrackerMixin:MoveQuest(questLogIndex, numMoves)
	if SORT_TYPE ~= SORT_MANUAL then
		self:SetSorting(SORT_MANUAL)
		UIErrorsFrame:AddMessage(TRACKER_SORT_MANUAL_WARNING, 1.0, 1.0, 0.0, 1.0)
	end
	local numVisibleWatches = #VISIBLE_WATCHES
	local indexStart = self:GetVisibleIndex(questLogIndex)
	local indexEnd = indexStart + numMoves
	if indexEnd < 1 then
		indexEnd = 1
	elseif indexEnd > numVisibleWatches then
		indexEnd = numVisibleWatches
	end
	ShiftQuestWatches(GetQuestWatchIndex(questLogIndex), GetQuestWatchIndex(VISIBLE_WATCHES[indexEnd]))
	self:MarkDirty()
end

-- *****************************************************************************************************
-- ***** QUEST LINE
-- *****************************************************************************************************

QuestObjectiveLineMixin = CreateFromMixins(ObjectiveTrackerAnimLineMixin, PKBT_CountdownThrottledBaseMixin);

-- overrides base
function QuestObjectiveLineMixin:OnGlowAnimFinished()
	if self.state == ObjectiveTrackerAnimLineState.Completing then
		self.state = ObjectiveTrackerAnimLineState.Completed;
		self:UpdateModule();
	else
		ObjectiveTrackerAnimLineMixin.OnGlowAnimFinished(self);
	end
end

function QuestObjectiveLineMixin:OnCountdownUpdate(timeLeft, isFinished)
	if not isFinished then
		local block = self.parentBlock
		local textHeight = block:SetStringText(self.Text, string.format(TRACKER_QUEST_TIMERS_FORMAT, SecondsToTime(timeLeft)), true, self.Text.colorStyle)
		local height = self.overrideHeight or textHeight
		if Round(block.textHeight) ~= Round(height) then
			self:UpdateModule()
		end
	end
end

function QuestObjectiveLineMixin:OnFree(block)
	ObjectiveTrackerAnimLineMixin.OnFree(self)

	self:CancelCountdown()
end

-- *****************************************************************************************************
-- ***** QUEST POI
-- *****************************************************************************************************

function QuestObjectiveTrackerPOI_OnClick(self)
	if WorldMapFrame:IsShown() then
		if WORLDMAP_SETTINGS.selectedQuestId == self.questId then
			HideUIPanel(WorldMapFrame)
			return;
		end
		PlaySound("igMainMenuOptionCheckBoxOn")
	end
	WorldMap_OpenToQuest(self.questId)
end