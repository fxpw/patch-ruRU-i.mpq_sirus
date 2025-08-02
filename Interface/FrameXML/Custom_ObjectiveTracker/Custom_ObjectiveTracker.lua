local DEFAULT_OPACITY = 0
local MAX_OPACITY = 100

local DEFAULT_TEXT_SIZE = 12
local MAX_TEXT_SIZE = 20

ObjectiveTrackerFrameMixin = {};

function ObjectiveTrackerFrameMixin:OnLoad()
	self.topPadding = 0
	self.leftPadding = 84
	self.topModulePadding = 38
	self.bottomModulePadding = 0
	self.moduleSpacing = 10
	self.headerText = TRACKER_ALL_OBJECTIVES
	self.collapseType = Enum.ObjectiveTrackerCollapsedStateType.Main
	self.hasFilters = true

	self.ScrollFrame.scrollBarHideable = true
	self.ScrollFrame:SetPoint("TOPLEFT", self.Header, -self.leftPadding, -self.topModulePadding)

	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("VARIABLES_LOADED");
end

function ObjectiveTrackerFrameMixin:OnEvent(event, ...)
	if event == "VARIABLES_LOADED" then
		self:UpdateOpacity()
		self:UpdateTextSize()
		self:UpdateHeaderAlpha()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		RunNextFrame(function()
			self:Update()
		end)
	end
end

function ObjectiveTrackerFrameMixin:OnMouseWheel(value)
	if value > 0 then
		self.ScrollFrame.ScrollBar:SetValue(self.ScrollFrame.ScrollBar:GetValue() - (self.moduleSpacing * 5))
	else
		self.ScrollFrame.ScrollBar:SetValue(self.ScrollFrame.ScrollBar:GetValue() + (self.moduleSpacing * 5))
	end
end

function ObjectiveTrackerFrameMixin:OnDragStart()
	self:StartMoving()
	self:UpdateHeight()
end

function ObjectiveTrackerFrameMixin:OnDragStop()
	self:StopMovingOrSizing()
	self:UpdateHeight()
end

function ObjectiveTrackerFrameMixin:UpdateHeight()
	self.editModeHeight = tonumber(GetCVar("objectiveTrackerHeight")) or 800
	ObjectiveTrackerContainerMixin.UpdateHeight(self)
end

function ObjectiveTrackerFrameMixin:UpdateOpacity()
	local opacity = tonumber(GetCVar("objectiveTrackerBackgroundOpacity")) or DEFAULT_TEXT_SIZE
	opacity = math.max(DEFAULT_OPACITY, math.min(MAX_OPACITY, opacity))
	if self.opacity ~= opacity then
		ObjectiveTrackerManager:SetOpacity(opacity)
		self.opacity = opacity
	end
end

function ObjectiveTrackerFrameMixin:UpdateTextSize()
	local textSize = tonumber(GetCVar("objectiveTrackerTextSize")) or DEFAULT_TEXT_SIZE
	textSize = math.max(DEFAULT_TEXT_SIZE, math.min(MAX_TEXT_SIZE, textSize))
	if self.trackerTextSize ~= textSize then
		ObjectiveTrackerManager:SetTextSize(textSize)
		self.trackerTextSize = textSize
	end
end
function ObjectiveTrackerFrameMixin:UpdateHeaderAlpha()
	local headerAlpha = tonumber(GetCVar("objectiveTrackerHeaderAlpha")) or 1
	headerAlpha = math.max(0, math.min(1, headerAlpha))
	if self.headerAlpha ~= headerAlpha then
		ObjectiveTrackerManager:SetHeaderAlpha(headerAlpha)
		self.headerAlpha = headerAlpha
	end
end

local function SetObjectiveTrackerFilterCompletedQuests(checked)
	SetCVarBitfield("objectiveTrackerFilter", Enum.ObjectiveTrackerFilter.CompletedQuests, not checked)
	ObjectiveTrackerFrame:Update()
end
local function SetObjectiveTrackerFilterRemoteZones(checked)
	SetCVarBitfield("objectiveTrackerFilter", Enum.ObjectiveTrackerFilter.RemoteZones, not checked)
	ObjectiveTrackerFrame:Update()
end
local function SetObjectiveTrackerFilterAchievements(checked)
	SetCVarBitfield("objectiveTrackerFilter", Enum.ObjectiveTrackerFilter.Achievements, not checked)
	ObjectiveTrackerFrame:Update()
end
local function SetObjectiveTrackerFilterBattlePass(checked)
	SetCVarBitfield("objectiveTrackerFilter", Enum.ObjectiveTrackerFilter.BattlePass, not checked)
	ObjectiveTrackerFrame:Update()
end
local function SetObjectiveTrackerFilterProfessions(checked)
	SetCVarBitfield("objectiveTrackerFilter", Enum.ObjectiveTrackerFilter.Professions, not checked)
	ObjectiveTrackerFrame:Update()
end

local function GetObjectiveTrackerFilter(filter)
	return not GetCVarBitfield("objectiveTrackerFilter", filter)
end

function ObjectiveTrackerFrameFilterDropDown_Initialize(self, level)
	local filterSystem = {
		filters = {
			{ type = FilterComponent.Checkbox, text = TRACKER_FILTER_COMPLETED_QUESTS, filter = Enum.ObjectiveTrackerFilter.CompletedQuests, set = SetObjectiveTrackerFilterCompletedQuests, isSet = GetObjectiveTrackerFilter, },
			{ type = FilterComponent.Checkbox, text = TRACKER_FILTER_REMOTE_ZONES, filter = Enum.ObjectiveTrackerFilter.RemoteZones, set = SetObjectiveTrackerFilterRemoteZones, isSet = GetObjectiveTrackerFilter, },
			{ type = FilterComponent.Checkbox, text = TRACKER_FILTER_ACHIEVEMENTS, filter = Enum.ObjectiveTrackerFilter.Achievements, set = SetObjectiveTrackerFilterAchievements, isSet = GetObjectiveTrackerFilter, },
			{ type = FilterComponent.Checkbox, text = TRACKER_FILTER_BATTLEPASS, filter = Enum.ObjectiveTrackerFilter.BattlePass, set = SetObjectiveTrackerFilterBattlePass, isSet = GetObjectiveTrackerFilter, },
			{ type = FilterComponent.Checkbox, text = TRACKER_FILTER_PROFESSIONS, filter = Enum.ObjectiveTrackerFilter.Professions, set = SetObjectiveTrackerFilterProfessions, isSet = GetObjectiveTrackerFilter, },
		},
	}

	FilterDropDownSystem.Initialize(self, filterSystem, level)
end