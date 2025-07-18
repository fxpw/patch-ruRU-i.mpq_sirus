local function GetQuestID(block)
	return math.abs(block.id)
end

local function IsQuestBlock(block)
	return block.id < 0
end

local settings = {
	headerText = BATTLEPASS_TRACKER_HEADER_QUEST,
	events = { "TRACKED_BATTLEPASS_QUEST_UPDATE", "BATTLEPASS_QUEST_LIST_UPDATE", "BATTLEPASS_QUEST_UPDATE", "BATTLEPASS_QUEST_DATA_UPDATE", "BATTLEPASS_QUEST_DONE", "BATTLEPASS_QUEST_CANCELED", "BATTLEPASS_QUEST_REPLACED" },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
	collapseType = Enum.ObjectiveTrackerCollapsedStateType.BattlePassTracker,
}

BattlePassQuestTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings)

function BattlePassQuestTrackerMixin:OnEvent(event, ...)
	if event == "TRACKED_BATTLEPASS_QUEST_UPDATE" then
		local questID, added = ...
		if added then
			self:SetNeedsFanfare(questID)
		end
		self:MarkDirty()
	elseif event == "BATTLEPASS_QUEST_UPDATE" then
		local questType, questIndex = ...
		local questID = C_BattlePass.GetQuestID(questType, questIndex)
		if questID then
			local block = self:GetExistingBlock(questID)
			if block then
				self:MarkDirty()
			end
		end
	elseif event == "BATTLEPASS_QUEST_LIST_UPDATE"
	or event == "BATTLEPASS_QUEST_DATA_UPDATE"
	or event == "BATTLEPASS_QUEST_DONE"
	or event == "BATTLEPASS_QUEST_CANCELED"
	then
		self:MarkDirty()
	end
end

function BattlePassQuestTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = C_BattlePass.GetQuestLinkByID(GetQuestID(block))
		if link then
			ChatEdit_InsertLink(link)
		end
	elseif mouseButton ~= "RightButton" then
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			local track = false
			C_BattlePass.SetQuestTrackedByID(GetQuestID(block), track)
		else
			if not IsQuestBlock(block) then
				local questID = GetQuestID(block)
				if C_BattlePass.HasQuest(questID) then
					C_BattlePass.OpenQuest(questID)
				end
			end
		end
	else
		self:ToggleDropDown(block)
	end
end

function BattlePassQuestTrackerMixin:InitDropDown(block)
	local info = UIDropDownMenu_CreateInfo()
	info.text = BATTLEPASS_UNTRACK_QUEST
	info.func = function()
		local track = false
		C_BattlePass.SetQuestTrackedByID(GetQuestID(block), track)
	end
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

function BattlePassQuestTrackerMixin:CanUpdate()
	return C_BattlePass.IsQuestListLoaded()
end

function BattlePassQuestTrackerMixin:LayoutContents()
	self:AddQuests()
end

function BattlePassQuestTrackerMixin:AddQuests()
	for _, questID in ipairs(C_BattlePass.GetQuestTracked()) do
		if not self:AddQuest(questID) then
			return false
		end
	end
	return true
end

function BattlePassQuestTrackerMixin:AddQuest(questID)
	local name, description, rewardAmount, progressValue, progressMaxValue, isPercents = C_BattlePass.GetQuestInfoID(questID)
	local isComplete = C_BattlePass.IsQuestCompleteByID(questID)

	local blockID = questID
	local block = self:GetBlock(blockID)
	block:SetHeader(name)

	if isComplete then
		local line = block:AddObjective(1, BATTLEPASS_QUEST_COMPLETED, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"])
		line.Icon:SetAtlas("UI-QuestTracker-Tracker-Check", false)
		line.Icon:SetShown(true)
	else
		local text
		if isPercents then
			text = description
		else
			if progressValue == 0 and progressMaxValue == 1 then
				text = description
			else
				local valueText = string.format(BATTLEPASS_TRACKER_CRITERIA_COUNT_FORMAT, progressValue, progressMaxValue)
				text = string.format("%s %s", valueText, description)
			end
		end

		local line = block:AddObjective(1, text, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, OBJECTIVE_TRACKER_COLOR["Normal"])
		line.Icon:SetShown(false)

		if isPercents then
			local progressBar = block:AddProgressBar(blockID)
			progressBar.Bar:SetMinMaxValues(0, 100)
			progressBar.Bar:SetValue(progressValue)
			progressBar.Bar.Label:SetFormattedText(PERCENTAGE_STRING, progressValue)
		end
	end

	return self:LayoutBlock(block)
end