local tonumber = tonumber
local tinsert, tremove, tsort, twipe = table.insert, table.remove, table.sort, table.wipe

local GetCVar = GetCVar
local SetCVar = SetCVar
local GetCVarDefault = GetCVarDefault
local GetCVarBitfield = GetCVarBitfield
local SetCVarBitfield = SetCVarBitfield

Enum.CustomNPE_Type = {
	Default = 1,
	Repeatable = 2,
}

Enum.CustomNPE_Tutorial = Enum.CreateMirror({
	LFG_PVP_BG_Available = 0,
	LFG_PVE_Dungeon_Available = 1,
	LFG_PVE_DungeonHeroic_Available = 2,
	LFG_PVP_BattlePass_20 = 3,
	LFG_PVP_BattlePass_77 = 4,

	KnowledgeBaseNotification = 5,
	EncounterJournalNotification = 6,
	SuggestedContentNotification = 24,
	HeadHunterNotification = 7,
	FirstAchievementNotification = 8,

	NewSkillAvailable = 9,
	TalentAvailable = 10,
	TalentSummary = 11,
	LilyBagAvailable = 12,

	LookingForGuildAvailable = 13,
	FirstGuildJoined = 14,

	FirstProfessionLearned = 15,

	FirstMountLooted = 16,
	FirstPetLooted = 17,
	FirstToyLooted = 18,

	FirstMountLearned = 19,
	FirstPetLearned = 20,
	FirstToyLearned = 21,
	HeirloomLearned = 22,

	QuestMapAvailable = 23,

	TutorialHint_Reputaion = 32,
	TutorialHint_Currency = 33,
	TutorialHint_PVPUI = 34,
	TutorialHint_LookingForGuild = 35,
	TutorialHint_Knowledgebase = 36,
	TutorialHint_EncounterJournal = 37,
	TutorialHint_HeadHunting = 38,
	TutorialHint_Wardrobe = 39,
	TutorialHint_Collections = 40,
	TutorialHint_Store = 41,
	ForceResetImportantTutorials = 42,
})

Enum.CustomNPE_Hint = Enum.CreateMirror({
	LFG_PVP_NewBrawl_Changed = 1000,
	RidingSkillAvailable = 1001,
})

Enum.RadingSkillAvailable = {
	Mail = 0,
	Quest = 1,
	Item = 2,
}

local TUTORIAL_CVARS = {
	[0] = "tutorialsFlagged",
	[1] = "tutorialsFlagged2",
}

local PRIVATE = {
	TUTORIALS = {},
	HELP_TIPS = {},
	QUEUE_TUTORIALS = {},
	PROCESSING_QUEUE = {},
	USED_OWNERS = {},
	OWNER_REGISTRY = {},
	PUBLIC_CALLBACK_ID = {},
}

if IsInterfaceDevClient() then
	PRIVATE_TUTORIALS = PRIVATE
end

PRIVATE.customActionButtonPool = CreateFramePool("Button", UIParent, "TutorialCustomActionButtonTemplate")

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("VARIABLES_LOADED")
PRIVATE.eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LEVEL_UP")
PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.eventHandler:RegisterCustomEvent("BATTLEPASS_SEASON_UPDATE")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LEVEL_UP" then
		local level = ...
		PRIVATE.PLAYER_LEVEL = level
	elseif event == "BATTLEPASS_SEASON_UPDATE" then
		EventRegistry:TriggerEvent("BattlePass.SeasonUpdate", ...)
	elseif event == "CHAT_MSG_ADDON" then
		local prefix, msg, distribution, sender = ...
		if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
			return
		end

		if prefix == "ASMSG_RIDING_SKILL_AVAILABLE" then
			local actionType, id = string.split(":", msg)
			EventRegistry:TriggerEvent("RidingSkill.Available", tonumber(actionType), tonumber(id))
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" then
		if event == "PLAYER_ENTERING_WORLD" then
			local isInitialLogin, isReloadingUI = ...
			self.PLAYER_ENTERING_WORLD = true
			self:UnregisterEvent(event)
		elseif event == "VARIABLES_LOADED" then
			self.VARIABLES_LOADED = true
		end
		if self.PLAYER_ENTERING_WORLD and self.VARIABLES_LOADED then
			self:Show()
		end
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or 0) - elapsed
	if self.elapsed <= 0 then
		self.elapsed = 0.3
		if not PRIVATE.CINEMATIC and UIParent:IsVisible() then
			PRIVATE.Initialize()
			self:Hide()
		end
	end
end)

EventRegistry:RegisterCallback("CinematicFrame.CinematicStarting", function()
	PRIVATE.CINEMATIC = true
end, PRIVATE.PUBLIC_CALLBACK_ID)

EventRegistry:RegisterCallback("CinematicFrame.CinematicStopped", function()
	PRIVATE.CINEMATIC = false
	PRIVATE.eventHandler.elapsed = 0.3
	PRIVATE.eventHandler:Show()
end, PRIVATE.PUBLIC_CALLBACK_ID)

PRIVATE.Initialize = function()
	PRIVATE.INITIALIZED = true
	PRIVATE.TriggerForceReset()
	PRIVATE.TriggerTutorials()
	PRIVATE.TriggerHelpTips()
end

PRIVATE.GetTutorialCVarInfo = function(tutorialIndex)
	local cvarIndex = math.floor(tutorialIndex / 32)
	local bitIndex = math.fmod(tutorialIndex, 32)
	local cvarName = TUTORIAL_CVARS[cvarIndex]
	if not cvarName then
		GMError(string.format("No cvar for tutorial index %i", tutorialIndex))
	end
	return cvarName, bitIndex
end

PRIVATE.IsTutorialFlagged = function(tutorialIndex)
	local cvarName, bitIndex = PRIVATE.GetTutorialCVarInfo(tutorialIndex)
	if cvarName then
		return GetCVarBitfield(cvarName, bitIndex)
	end
end

PRIVATE.SetTutorialFlag = function(tutorialIndex, state)
	local cvarName, bitIndex = PRIVATE.GetTutorialCVarInfo(tutorialIndex)
	if cvarName then
		return SetCVarBitfield(cvarName, bitIndex, state)
	end
end

PRIVATE.TriggerForceReset = function()
	if not PRIVATE.IsTutorialFlagged(Enum.CustomNPE_Tutorial.ForceResetImportantTutorials) then
		local IMPORTANT_TUTORIALS = {
			Enum.CustomNPE_Tutorial.LFG_PVP_BattlePass_20,
			Enum.CustomNPE_Tutorial.LFG_PVP_BattlePass_77,
			Enum.CustomNPE_Tutorial.KnowledgeBaseNotification,
			Enum.CustomNPE_Tutorial.EncounterJournalNotification,
			Enum.CustomNPE_Tutorial.HeadHunterNotification,
			Enum.CustomNPE_Tutorial.LilyBagAvailable,
			Enum.CustomNPE_Tutorial.LookingForGuildAvailable,
			Enum.CustomNPE_Tutorial.FirstMountLooted,
			Enum.CustomNPE_Tutorial.FirstPetLooted,
			Enum.CustomNPE_Tutorial.FirstToyLooted,
			Enum.CustomNPE_Tutorial.FirstMountLearned,
			Enum.CustomNPE_Tutorial.FirstPetLooted,
			Enum.CustomNPE_Tutorial.FirstToyLooted,
			Enum.CustomNPE_Tutorial.HeirloomLearned,
			Enum.CustomNPE_Tutorial.TutorialHint_Reputaion,
			Enum.CustomNPE_Tutorial.TutorialHint_Currency,
			Enum.CustomNPE_Tutorial.TutorialHint_PVPUI,
			Enum.CustomNPE_Tutorial.TutorialHint_LookingForGuild,
			Enum.CustomNPE_Tutorial.TutorialHint_Knowledgebase,
			Enum.CustomNPE_Tutorial.TutorialHint_EncounterJournal,
			Enum.CustomNPE_Tutorial.TutorialHint_HeadHunting,
			Enum.CustomNPE_Tutorial.TutorialHint_Wardrobe,
			Enum.CustomNPE_Tutorial.TutorialHint_Collections,
			Enum.CustomNPE_Tutorial.TutorialHint_Store,
		}

		for index, tutorialIndex in ipairs(IMPORTANT_TUTORIALS) do
			PRIVATE.SetTutorialFlag(tutorialIndex, false)
		end

		PRIVATE.SetTutorialFlag(Enum.CustomNPE_Tutorial.ForceResetImportantTutorials, true)
	end
end

PRIVATE.TriggerTutorials = function(reset)
	for index, tutorial in ipairs(PRIVATE.TUTORIALS) do
		PRIVATE.TriggerTutorial(tutorial, reset)
	end
	PRIVATE.ProcessQueue(nil, true)
end

PRIVATE.TriggerHelpTips = function(reset)
	for id, helpTip in pairs(PRIVATE.HELP_TIPS) do
		PRIVATE.TriggerHelpTip(helpTip, reset)
	end
end

PRIVATE.TriggerTutorial = function(tutorial, reset)
	if (not tutorial.initialized or reset)
	and (tutorial.type == Enum.CustomNPE_Type.Repeatable or not PRIVATE.IsTutorialFlagged(tutorial.id))
	and tutorial:CanInitialize() then
		local success, err = pcall(tutorial.OnInitialize, tutorial, reset)
		if success then
			tutorial.initialized = true

			if not tutorial.callbackTriggerOnly then
				tutorial:QueueTrigger()
			end
		else
			geterrorhandler()(err)
		end
	end
end

PRIVATE.TriggerHelpTip = function(helpTip, reset)
	if (not helpTip.initialized or reset) and helpTip:CanInitialize() then
		local success, err = pcall(helpTip.OnInitialize, helpTip, reset)
		if success then
			helpTip.initialized = true
		else
			geterrorhandler()(err)
		end

		if not helpTip.callbackTriggerOnly then
			helpTip:Trigger()
		end
	end
end

PRIVATE.IsTutorialQueued = function(handler)
	for index, tutorial in ipairs(PRIVATE.QUEUE_TUTORIALS) do
		if tutorial.handler == handler then
			local ownerChanged = tutorial.owner ~= tutorial.handler.owner
			if ownerChanged then
				tutorial.owner = tutorial.handler.owner
			end
			return true, ownerChanged
		end
	end
	return false, false
end

PRIVATE.QueueTutorial = function(handler, ...)
	local isQueued, ownerChanged = PRIVATE.IsTutorialQueued(handler)
	if isQueued then
		return false, ownerChanged
	end

	if handler.owner then
		PRIVATE.OWNER_REGISTRY[handler.owner] = true
	end

	tinsert(PRIVATE.QUEUE_TUTORIALS, {
		handler = handler,
		name = handler.name,
		owner = handler.owner,
		args = {...},
	})

	return true, true
end

PRIVATE.DequeueTuturial = function(handler)
	for index, tutorial in ipairs(PRIVATE.QUEUE_TUTORIALS) do
		if tutorial.handler == handler then
			tutorial.handler.isShown = nil
			tremove(PRIVATE.QUEUE_TUTORIALS, index)
			return true
		end
	end
	return false
end

PRIVATE.ClearQueue = function()
	for index = 1, #PRIVATE.QUEUE_TUTORIALS do
		PRIVATE.QUEUE_TUTORIALS[index].handler.isShown = nil
		PRIVATE.QUEUE_TUTORIALS[index] = nil
	end
end

PRIVATE.IsOwnerEmpty = function(owner)
	if PRIVATE.USED_OWNERS[owner] then
		return false, PRIVATE.USED_OWNERS[owner]
	end
	for index, tutorial in ipairs(PRIVATE.QUEUE_TUTORIALS) do
		if tutorial.handler.isShown and tutorial.handler.owner == owner then
			return false, tutorial.handler.name
		end
	end
	return true
end

PRIVATE.ProcessQueue = function(owner, recurse)
	if owner ~= nil and PRIVATE.PROCESSING_QUEUE[owner] then
		return
	end

	if owner == nil then
		if recurse then
			for _owner in pairs(PRIVATE.OWNER_REGISTRY) do
				PRIVATE.ProcessQueue(_owner)
			end
			return
		else
			GMError("Attempt to process queue with empty owner")
			return
		end
	end

	if not PRIVATE.IsOwnerEmpty(owner) then
		return
	end

	PRIVATE.PROCESSING_QUEUE[owner] = true
	EventRegistry:TriggerEvent("TutorialManager.OwnerFreed", owner) -- process callbacks first

	if PRIVATE.USED_OWNERS[owner] then
		PRIVATE.PROCESSING_QUEUE[owner] = nil
		return
	end

	for index, tutorial in ipairs(PRIVATE.QUEUE_TUTORIALS) do
		if tutorial.handler.owner == owner and not tutorial.handler.isShown then
			local success, isShown = tutorial.handler:Trigger(unpack(tutorial.args))
			if success and isShown
			and tutorial.handler.owner == owner -- owner wasn't changed
			then
				PRIVATE.PROCESSING_QUEUE[owner] = nil
				return
			end
		end
	end

	PRIVATE.PROCESSING_QUEUE[owner] = nil
end

PRIVATE.GetTutorialHelpTipFramesByText = function(text)
	for frame in HelpTip.framePool:EnumerateActive() do
		if type(frame.info) == "table" and frame.info.customTutorialID then
			if frame.info.text == text then
				return frame
			end
		end
	end
end

PRIVATE.CloseTutorialHelpTipFrames = function()
	for frame in HelpTip.framePool:EnumerateActive() do
		if type(frame.info) == "table" and frame.info.customTutorialID then
			frame:Close()
		end
	end
end

PRIVATE.SortTurorials = function(tutorialA, tutorialB)
	local priorityA = tutorialA.priority
	local priorityB = tutorialB.priority
	if priorityA and priorityB then
		return priorityA > priorityB
	elseif priorityA then
		return true
	elseif priorityB then
		return false
	end
	return false
end

PRIVATE.GetPlayerLevel = function()
	return PRIVATE.PLAYER_LEVEL or UnitLevel("player")
end

PRIVATE.GetQuestIDForIndex = function(questIndex)
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, displayQuestID = GetQuestLogTitle(questIndex)
	return questID
end

PRIVATE.GetQuestIndexByID = function(questID)
	for questIndex = 1, GetNumQuestLogEntries() do
		local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, _questID, displayQuestID = GetQuestLogTitle(questIndex)
		if not isHeader and _questID == questID then
			return questIndex
		end
	end
end

PRIVATE.FindItemInBagsByItemID = function(itemID, isRevers)
	local startIndex, endIndex, iterator
	if isRevers then
		startIndex = NUM_BAG_FRAMES
		endIndex = 0
		iterator = -1
	else
		startIndex = 0
		endIndex = NUM_BAG_FRAMES
		iterator = 1
	end
	for bagID = startIndex, endIndex, iterator do
		local slotID = PRIVATE.FindItemInBagIDByItemID(bagID, itemID, isRevers)
		if slotID then
			return bagID, slotID
		end
	end
end

PRIVATE.FindItemInBagIDByItemID = function(bagID, itemID, isRevers)
	local startIndex, endIndex, iterator
	if isRevers then
		startIndex = GetContainerNumSlots(bagID)
		endIndex = 1
		iterator = -1
	else
		startIndex = 1
		endIndex = GetContainerNumSlots(bagID)
		iterator = 1
	end
	for slotID = startIndex, endIndex, iterator do
		if GetContainerItemID(bagID, slotID) == itemID then
			return slotID
		end
	end
end

local BAG_BUTTONS = {
	[0] = "MainMenuBarBackpackButton",
	[1] = "CharacterBag0Slot",
	[2] = "CharacterBag1Slot",
	[3] = "CharacterBag2Slot",
	[4] = "CharacterBag3Slot",
}

PRIVATE.GetMenuBarBagButtonByBagID = function(bagID)
	if bagID and BAG_BUTTONS[bagID] then
		return _G[BAG_BUTTONS[bagID]]
	end
end

PRIVATE.GetMenuBarBagButtonContainingItemID = function(itemID)
	local bagID, slotID = PRIVATE.FindItemInBagsByItemID(itemID)
	if bagID and BAG_BUTTONS[bagID] then
		return _G[BAG_BUTTONS[bagID]], bagID, slotID
	end
end

PRIVATE.GetShownLFGFrame = function()
	if LFDParentFrame:IsShown() then
		return LFDParentFrame
	elseif PVPUIFrame:IsShown() then
		return PVPUIFrame
	elseif PVPLadderFrame:IsShown() then
		return PVPLadderFrame
	elseif RenegadeLadderFrame:IsShown() then
		return RenegadeLadderFrame
	end
end

PRIVATE.GetPVPTabButtonByID = function(id)
	local frame = PRIVATE.GetShownLFGFrame()
	if frame then
		return _G[string.format("%sTab%d", frame:GetName(), id)], frame
	end
end

C_TutorialManager = {}

function C_TutorialManager.IsTutorialFlagged(tutorialID)
	return PRIVATE.IsTutorialFlagged(tutorialID)
end

function C_TutorialManager.SetTutorialFlagged(tutorialID)
	return PRIVATE.SetTutorialFlag(tutorialID, true)
end

function C_TutorialManager.ResetTutorialFlag(tutorialID)
	if tutorialID == Enum.CustomNPE_Tutorial.ForceResetImportantTutorials then
		return false
	end
	PRIVATE.SetTutorialFlag(tutorialID, false)
end

function C_TutorialManager.ResetTutorials()
	for cvarIndex, cvarName in pairs(TUTORIAL_CVARS) do
		SetCVar(cvarName, GetCVarDefault(cvarName))
	end

	PRIVATE.SetTutorialFlag(Enum.CustomNPE_Tutorial.ForceResetImportantTutorials, true)

	PRIVATE.BLOCK_TRIGGER = true
	for index, tutorial in ipairs(PRIVATE.QUEUE_TUTORIALS) do
		if tutorial.handler.isShown then
			tutorial.handler:UnregisterCallbacks()
			pcall(tutorial.handler.CloseTips, tutorial.handler)
		end
	end
	twipe(PRIVATE.QUEUE_TUTORIALS)
	PRIVATE.BLOCK_TRIGGER = nil

	PRIVATE.ClearQueue()
	PRIVATE.CloseTutorialHelpTipFrames()

	PRIVATE.TriggerTutorials(true)
end

function C_TutorialManager.CanResetTutorials()
	for cvarIndex, cvarName in pairs(TUTORIAL_CVARS) do
		if GetCVar(cvarName) ~= GetCVarDefault(cvarName) then
			return true
		end
	end
	return false
end

function C_TutorialManager.ResetHelpTips()
	PRIVATE.TriggerHelpTips(true)
end

function C_TutorialManager.RegisterTutorial(id, handler, isRepeatable)
	assert(type(id) == "number")

	handler.id = id
	if isRepeatable then
		handler.name = Enum.CustomNPE_Hint[id]
		handler.type = Enum.CustomNPE_Type.Repeatable
	else
		handler.name = Enum.CustomNPE_Tutorial[id]
		handler.type = Enum.CustomNPE_Type.Default
	end

	tinsert(PRIVATE.TUTORIALS, handler)
	tsort(PRIVATE.TUTORIALS, PRIVATE.SortTurorials)

	if PRIVATE.INITIALIZED and not PRIVATE.BLOCK_TRIGGER then
		PRIVATE.TriggerTutorial(handler)
	end
end

function C_TutorialManager.IsActive()
	return true
end

function C_TutorialManager.IsOwnerEmpty(owner)
	assert(owner ~= nil)
	return PRIVATE.IsOwnerEmpty(owner)
end

function C_TutorialManager.MarkOwnerUsed(owner, handlerName)
	assert(owner ~= nil)
	assert(handlerName ~= nil)

	if not PRIVATE.IsOwnerEmpty(owner) then
		return false
	end

	PRIVATE.USED_OWNERS[owner] = handlerName

	return true
end

function C_TutorialManager.ClearOwner(owner, handlerName)
	assert(owner ~= nil)
	assert(handlerName ~= nil)

	if PRIVATE.USED_OWNERS[owner] and PRIVATE.USED_OWNERS[owner] == handlerName then
		PRIVATE.USED_OWNERS[owner] = nil
		PRIVATE.ProcessQueue(owner)
		return true
	end

	return false
end

TutorialPrototypeMixin = {}

function TutorialPrototypeMixin:OnInitialize(reset)
end

function TutorialPrototypeMixin:CanInitialize()
	return true
end

function TutorialPrototypeMixin:CanTrigger()
	return true
end

function TutorialPrototypeMixin:CanFinishPreemptively()
	return false
end

function TutorialPrototypeMixin:CheckConditions(...)
	return self:CanTrigger(...)
end

function TutorialPrototypeMixin:OnInitCallback(...)
	if self:CheckConditions(...) then
		self:UpdateProgress(...)
		self:QueueTrigger(...)
		return true
	end
end

function TutorialPrototypeMixin:UpdateProgress()
end

function TutorialPrototypeMixin:CloseTips()
end

function TutorialPrototypeMixin:GetTarget()
	return self.targetFrame
end

function TutorialPrototypeMixin:OnTrigger()
end

function TutorialPrototypeMixin:RegisterCallback(event, func, owner, ...)
	if not self.callbacks then
		self.callbacks = {}
	end
	self.callbacks[event] = func or true
	EventRegistry:RegisterCallback(event, func, self, ...)
end

function TutorialPrototypeMixin:UnregisterCallback(event, owner)
	if self.callbacks and self.callbacks[event] then
		self.callbacks[event] = nil
	end
	EventRegistry:UnregisterCallback(event, self)
end

function TutorialPrototypeMixin:RegisterFrameEventAndCallback(frameEvent, func, owner, ...)
	if not self.eventCallbacks then
		self.eventCallbacks = {}
	end
	if not self.eventCallbacks[frameEvent] then
		self.eventCallbacks[frameEvent] = func or true
		EventRegistry:RegisterFrameEventAndCallback(frameEvent, func, self, ...)
	end
end

function TutorialPrototypeMixin:UnregisterFrameEventAndCallback(frameEvent, owner)
	if self.eventCallbacks and self.eventCallbacks[frameEvent] then
		self.eventCallbacks[frameEvent] = nil
		EventRegistry:UnregisterFrameEventAndCallback(frameEvent, self)
	end
end

function TutorialPrototypeMixin:UnregisterCallbacks()
	if self.callbacks then
		for event, func in pairs(self.callbacks) do
			EventRegistry:UnregisterFrameEventAndCallback(event, self)
		end
	end
	if self.eventCallbacks then
		for frameEvent, func in pairs(self.eventCallbacks) do
			EventRegistry:UnregisterFrameEventAndCallback(frameEvent, self)
		end
	end
end

function TutorialPrototypeMixin:ReQueueTrigger(...)
	self.requeue = true
	self:QueueTrigger(...)
end

function TutorialPrototypeMixin:QueueTrigger(...)
	if not self:CanTrigger(...) then
		return
	end

	local success, ownerChanged = PRIVATE.QueueTutorial(self, ...)
	if not success then
		-- tutorial already in queue
		if not ownerChanged then
			return
		end
	end

	if not PRIVATE.INITIALIZED or PRIVATE.BLOCK_TRIGGER then
		return
	end

	if self.owner and not PRIVATE.IsOwnerEmpty(self.owner) then
		return
	end

	self:Trigger(...)

	return true
end

function TutorialPrototypeMixin:DeQueueTrigger(...)
	local success = PRIVATE.DequeueTuturial(self)
	if success then
		if self.owner then
			PRIVATE.ProcessQueue(self.owner)
		end
	end
	return success
end

function TutorialPrototypeMixin:Trigger(...)
	if not self:CanTrigger(...) then
		return false, false
	end

	if not PRIVATE.INITIALIZED or PRIVATE.BLOCK_TRIGGER then
		PRIVATE.QueueTutorial(self, ...)
		return false, false
	end

	if self.type ~= Enum.CustomNPE_Type.Repeatable and (GetCVar("showCustomTutorials") == "0" and not self.ignoreShowCVar) then
		self:FinishTutorial()
		return false, false
	end

	local success = self:OnTrigger(...)
	if success then
		self.requeue = nil
		self:OnTipShow()
	elseif self.requeue then
		self.requeue = nil
		PRIVATE.ProcessQueue(self.owner)
	else
		self.requeue = nil
		self:OnTipHide()
	end

	return true, success
end

function TutorialPrototypeMixin:FinishTutorial()
	self:SetTutorialFinishedFlag()
	self:UnregisterCallbacks()
	if not self.isShown then
		self:DeQueueTrigger()
	end
	if self.type == Enum.CustomNPE_Type.Repeatable then
		self:OnInitialize() -- reinit
	end
end

function TutorialPrototypeMixin:SetTutorialFinishedFlag()
	if self.id and self.type ~= Enum.CustomNPE_Type.Repeatable then
		C_TutorialManager.SetTutorialFlagged(self.id)
	end
end

function TutorialPrototypeMixin:ResetTutorialFlag()
	if self.id and self.type ~= Enum.CustomNPE_Type.Repeatable then
		C_TutorialManager.ResetTutorialFlag(self.id)
	end
end

function TutorialPrototypeMixin:OnTipShow()
	self.isShown = true
	if self.finishOnShow or self.callbackTriggerOnly then
		self:SetTutorialFinishedFlag()
	end
end

function TutorialPrototypeMixin:OnTipHide(acknowledged, callbackArg)
	self.isShown = nil
	self:DeQueueTrigger()
end

function TutorialPrototypeMixin:GenerateHelpTipInfo(info, noOnAcknowledge, noOnHide)
	if type(info) ~= "table" then
		info = {}
	end

	info.customTutorialID = self.name
	info.frameStrata = "FULLSCREEN"

	if not noOnAcknowledge then
		info.onAcknowledgeCallback = function()
			self:FinishTutorial()
		end
	end
	if not noOnHide then
		info.onHideCallback = function(acknowledged, callbackArg)
			self:OnTipHide()
		end
	end

	return info
end

TutorialCustomActionButtonMixin = {}

function TutorialCustomActionButtonMixin:OnClick(button)
	PlaySound("igMainMenuOptionCheckBoxOn")
	if type(self.onClick) == "function" then
		self.onClick(self, button)
	end
end

do	-- TutorialHints
	PRIVATE.ShowTutorialHint = function(tutorialHandler)
		local helpPlateButton = tutorialHandler:GetHelpTipButton()
		if helpPlateButton and helpPlateButton:IsVisible() then
			HelpPlate_ShowTutorialPrompt(helpPlateButton:GetParent(), helpPlateButton)
			return true
		end
		return false
	end

	local TutorialHintPrototypeMixin = CreateFromMixins(TutorialPrototypeMixin)
	do
		TutorialHintPrototypeMixin.finishOnShow = true

		function TutorialHintPrototypeMixin:OnInitialize()
			assert(self.triggerCallbackName)
			self:RegisterCallback(self.triggerCallbackName, self.Trigger, self)
		end

		function TutorialHintPrototypeMixin:OnTrigger()
			local success = PRIVATE.ShowTutorialHint(self)
			if success then
				self:UnregisterCallback(self.triggerCallbackName, self)
			end
			return success
		end
	end

	local TutorialHint_Reputaion = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_Reputaion.triggerCallbackName = "ReputationFrame.OnShow"

		function TutorialHint_Reputaion:CanTrigger()
			return ReputationFrame:IsVisible()
		end

		function TutorialHint_Reputaion:GetHelpTipButton()
			return ReputationFrame.TutorialButton
		end
	end

	local TutorialHint_Currency = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_Currency.triggerCallbackName = "TokenFrame.OnShow"

		function TutorialHint_Currency:CanTrigger()
			return TokenFrame:IsVisible()
		end

		function TutorialHint_Currency:GetHelpTipButton()
			return TokenFrame.TutorialButton
		end
	end

	local TutorialHint_PVPUI = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		function TutorialHint_PVPUI:CanTrigger()
			return PRIVATE.GetShownLFGFrame() ~= nil
		end

		function TutorialHint_PVPUI:GetHelpTipButton()
			local helpTipButtons = {
				-- LFDQueueParentFrame
				"LFDQueueParentFrameTutorialButton",
				-- PVPUIFrame
				"RatedBattlegroundFrameTutorialButton",
				"ConquestFrameTutorialButton",
				"PVPHonorFrameTutorialButton",
				-- PVPLadderFrame
				"PVPLadderFrameTutorialButton",
				-- RenegadeLadderFrame
				"RenegadeLadderFrameTutorialButton",
			}
			for i, buttonName in ipairs(helpTipButtons) do
				local button = _G[buttonName]
				if type(button) == "table" and button:IsVisible() then
					return button
				end
			end
		end

		function TutorialHint_PVPUI:OnInitialize()
			self:RegisterCallback("LFDQueueFrame.OnShow", self.Trigger, self)
			self:RegisterCallback("PVPUIFrame.OnShow", self.Trigger, self)
			self:RegisterCallback("PVPLadderFrame.OnShow", self.Trigger, self)
			self:RegisterCallback("RenegadeLadderFrame.OnShow", self.Trigger, self)
		end

		function TutorialHint_PVPUI:OnTrigger()
			local success = PRIVATE.ShowTutorialHint(self)
			if success then
				self:UnregisterCallback("LFDQueueFrame.OnShow", self)
				self:UnregisterCallback("PVPUIFrame.OnShow", self)
				self:UnregisterCallback("PVPLadderFrame.OnShow", self)
				self:UnregisterCallback("RenegadeLadderFrame.OnShow", self)
			end
			return success
		end
	end

	local TutorialHint_LookingForGuild = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_LookingForGuild.triggerCallbackName = "LookingForGuild.OnShow"

		function TutorialHint_LookingForGuild:CanTrigger()
			return LookingForGuildFrame:IsShown()
		end

		function TutorialHint_LookingForGuild:GetHelpTipButton()
			return LookingForGuildFrameTutorialButton
		end
	end

	local TutorialHint_Knowledgebase = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_Knowledgebase.triggerCallbackName = "HelpFrame.OnShow"

		function TutorialHint_Knowledgebase:CanTrigger()
			return HelpFrame:IsShown()
		end

		function TutorialHint_Knowledgebase:GetHelpTipButton()
			return HelpFrame.TutorialButton
		end
	end

	local TutorialHint_EncounterJournal = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_EncounterJournal.triggerCallbackName = "EncounterJournal.OnShow"

		function TutorialHint_EncounterJournal:CanTrigger()
			return EncounterJournal:IsShown()
		end

		function TutorialHint_EncounterJournal:GetHelpTipButton()
			return EncounterJournal.TutorialButton
		end
	end

	local TutorialHint_HeadHunting = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_HeadHunting.triggerCallbackName = "HeadHuntingFrame.OnShow"

		function TutorialHint_HeadHunting:CanTrigger()
			return HeadHuntingFrame:IsShown()
		end

		function TutorialHint_HeadHunting:GetHelpTipButton()
			return HeadHuntingFrame.TutorialButton
		end
	end

	local TutorialHint_Wardrobe = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_Wardrobe.triggerCallbackName = "WardrobeFrame.OnShow"

		function TutorialHint_Wardrobe:CanTrigger()
			return WardrobeFrame:IsShown()
		end

		function TutorialHint_Wardrobe:GetHelpTipButton()
			return WardrobeFrame.TutorialButton
		end
	end

	local TutorialHint_Collections = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		function TutorialHint_Collections:CanTrigger()
			return CollectionsJournal:IsShown()
		end

		function TutorialHint_Collections:GetHelpTipButton()
			return WardrobeCollectionFrame:IsShown() and WardrobeCollectionFrame.TutorialButton
				or ToyBox:IsShown() and ToyBox.TutorialButton
				or HeirloomsJournal:IsShown() and HeirloomsJournal.TutorialButton
		end

		function TutorialHint_Collections:OnInitialize()
			self:RegisterCallback("WardrobeCollectionFrame.OnShow", self.Trigger, self)
			self:RegisterCallback("ToyBox.OnShow", self.Trigger, self)
			self:RegisterCallback("HeirloomsJournal.OnShow", self.Trigger, self)
		end

		function TutorialHint_Collections:OnTrigger()
			local success = PRIVATE.ShowTutorialHint(self)
			if success then
				self:UnregisterCallback("WardrobeCollectionFrame.OnShow", self)
				self:UnregisterCallback("ToyBox.OnShow", self)
				self:UnregisterCallback("HeirloomsJournal.OnShow", self)
			end
			return success
		end
	end

	local TutorialHint_Store = CreateFromMixins(TutorialHintPrototypeMixin)
	do
		TutorialHint_Store.triggerCallbackName = "StoreFrame.OnShow"

		function TutorialHint_Store:CanTrigger()
			return StoreFrame:IsShown()
		end

		function TutorialHint_Store:GetHelpTipButton()
			return StoreFrame.TutorialButton
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_Reputaion, TutorialHint_Reputaion)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_Currency, TutorialHint_Currency)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_PVPUI, TutorialHint_PVPUI)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_LookingForGuild, TutorialHint_LookingForGuild)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_Knowledgebase, TutorialHint_Knowledgebase)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_EncounterJournal, TutorialHint_EncounterJournal)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_HeadHunting, TutorialHint_HeadHunting)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_Wardrobe, TutorialHint_Wardrobe)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_Collections, TutorialHint_Collections)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TutorialHint_Store, TutorialHint_Store)
end

do	-- SpellbookMicroButton
	local NewSkillAvailable = CreateFromMixins(TutorialPrototypeMixin)
	do
		NewSkillAvailable.owner = "MainMenuBar"
		NewSkillAvailable.closeCallbackName = "SpellBookFrame.OnShow"

		function NewSkillAvailable:CanTrigger()
			if self:GetTarget():IsShown() and not SpellBookFrame:IsShown() then
				local level = PRIVATE.GetPlayerLevel()
				return level > 1 and level < 80 and GetCurrentLevelSpells(level) ~= nil
			end
		end

		function NewSkillAvailable:GetTipText()
			return HELPTIP_NEW_SKILL_AVAILABLE
		end

		function NewSkillAvailable:GetTarget()
			return SpellbookMicroButton
		end

		function NewSkillAvailable:CloseTips(isCallback)
			HelpTip:Hide(UIParent, self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function NewSkillAvailable:OnInitialize()
			self:RegisterFrameEventAndCallback("PLAYER_LEVEL_UP", self.OnInitCallback, self)
		end

		function NewSkillAvailable:OnInitCallback(...)
			if not IsLevelDataSpellsLoaded() then
				self:RegisterCallback("LevelUpSpells.Received", self.OnInitCallback, self, ...)
				return
			end

			self:UnregisterCallback("LevelUpSpells.Received", self)

			if self:CanTrigger(...) then
				self:QueueTrigger(...)
				return true
			end
		end

		function NewSkillAvailable:OnTrigger()
			self:UnregisterFrameEventAndCallback("PLAYER_LEVEL_UP", self)

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			})

			self:CloseTips()
			self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget())
			return success
		end
	end

	local FirstProfessionLearned = CreateFromMixins(TutorialPrototypeMixin)
	do
		FirstProfessionLearned.owner = "MainMenuBar"
		FirstProfessionLearned.initCallback = "SKILL_LINES_CHANGED"
		FirstProfessionLearned.finishCallback = "SpellBookFrame.SetTab"
		FirstProfessionLearned.progressCallback = "SpellBookFrame.OnShow"
		FirstProfessionLearned.progressRollbackCallback = "SpellBookFrame.OnHide"

		local tutorialHintInfo = {
			[1] = {
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Center,
			},
			[2] = {
				targetPoint = HelpTip.Point.BottomEdgeCenter,
				alignment = HelpTip.Alignment.Center,
			},
		}

		function FirstProfessionLearned:CanInitialize()
			return GetNumProfessions() == 0
		end

		function FirstProfessionLearned:CanTrigger()
			return GetNumProfessions() > 0 and self:GetTarget():IsShown() and not (SpellBookFrame:IsShown() and SpellBookFrame.bookType == "professions")
		end

		function FirstProfessionLearned:CanFinishPreemptively()
			return SpellBookFrame:IsVisible() and SpellBookFrame.bookType == "professions"
		end

		function FirstProfessionLearned:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
			HelpTip:Hide(UIParent, self:GetTipText(2))
		end

		function FirstProfessionLearned:GetTipText(index)
			if index == 2 then
				return HELPTIP_FIRST_PROFESSION_LEARNED_STEP2
			end
			return HELPTIP_FIRST_PROFESSION_LEARNED
		end

		function FirstProfessionLearned:GetTarget(index)
			if index == 2 then
				return SpellBookFrameTabButton2
			end
			return SpellbookMicroButton
		end

		function FirstProfessionLearned:OnInitialize()
			self.tutorialIndex = 1
			self.owner = nil

			local onLoadTriggerSuccess = self:OnInitCallback()
			if onLoadTriggerSuccess then
				return
			end

			self:RegisterFrameEventAndCallback(self.initCallback, self.OnInitCallback, self)
		end

		function FirstProfessionLearned:UpdateProgress(preserveStepIndex)
			local isSpellBookShown = SpellBookFrame:IsShown()
			if isSpellBookShown then
				self.owner = "SpellBookFrame"
			else
				self.owner = "MainMenuBar"
			end
			if not preserveStepIndex then
				self.tutorialIndex = isSpellBookShown and 2 or 1
			end
		end

		function FirstProfessionLearned:OnTrigger(...)
			if self:CanFinishPreemptively() then
				self:FinishTutorial()
				return
			end

			self:UnregisterFrameEventAndCallback(self.initCallback, self)
			self:UpdateProgress()

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(...)
				return
			end

			if SpellBookFrame:IsShown() then
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
				self:RegisterCallback(self.progressRollbackCallback, self.ProgressHelpTips, self, self.progressRollbackCallback)
			else
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
				self:RegisterCallback(self.progressCallback, self.ProgressHelpTips, self, self.progressCallback)
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(self.tutorialIndex),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = tutorialHintInfo[self.tutorialIndex].targetPoint,
				alignment = tutorialHintInfo[self.tutorialIndex].alignment,
			})

			self:CloseTips()

			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget(self.tutorialIndex))
			return success
		end

		function FirstProfessionLearned:ProgressHelpTips(event, ...)
			self:CloseTips()

			if event == self.finishCallback then
				local tabID = ...
				if tabID ~= "professions" then
					return
				end

				self:FinishTutorial()

				return
			elseif event == self.progressRollbackCallback then
				local forceReset
				if not self.isShown then
					local success = self:DeQueueTrigger()
					forceReset = success
				end
				if self.tutorialIndex > 1 or forceReset then -- reset
					self:ResetTutorialFlag()
					self:UpdateProgress()
					self:ReQueueTrigger(event, ...)
					return
				end
			elseif event == self.progressCallback then
				if SpellBookFrame.bookType == "professions" then
					self:ProgressHelpTips(self.finishCallback, SpellBookFrame.bookType)
					return
				else
					self.tutorialIndex = 2
				end
			end

			self:UpdateProgress(true)
			self:QueueTrigger(event, ...)
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstProfessionLearned, FirstProfessionLearned)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.NewSkillAvailable, NewSkillAvailable)
end

do	-- TalentMicroButton
	local TalentAvailable = CreateFromMixins(TutorialPrototypeMixin)
	do
		TalentAvailable.owner = "MainMenuBar"
		TalentAvailable.closeCallbackName = "PlayerTalentFrame.OnShow"

		function TalentAvailable:CanTrigger()
			return GetUnspentTalentPoints() > 0 and self:GetTarget():IsShown() and not PlayerTalentFrame:IsShown()
		end

		function TalentAvailable:GetTipText()
			return HELPTIP_TALENT_AVAILABLE
		end

		function TalentAvailable:GetTarget()
			return TalentMicroButton
		end

		function TalentAvailable:CloseTips(isCallback)
			HelpTip:Hide(UIParent, self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function TalentAvailable:OnInitialize()
			self:RegisterFrameEventAndCallback("CHARACTER_POINTS_CHANGED", self.OnInitCallback, self)
		end

		function TalentAvailable:OnTrigger(...)
			if not self:CheckConditions(...) then
				return
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			})

			self:UnregisterFrameEventAndCallback("CHARACTER_POINTS_CHANGED", self)
			self:CloseTips()
			self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget())
			return success
		end
	end

	local TalentSummary = CreateFromMixins(TutorialPrototypeMixin)
	do
		TalentSummary.owner = "TalentFrame"
		TalentSummary.callbackTriggerOnly = true

		function TalentSummary:CanTrigger()
			return self:GetTarget():IsVisible() and PlayerTalentFrame:IsShown()
		end

		function TalentSummary:GetTipText()
			return HELPTIP_TALENT_SUMMARY
		end

		function TalentSummary:GetTarget()
			return PlayerTalentFrameToggleSummariesButton
		end

		function TalentSummary:CloseTips(isCallback)
			HelpTip:Hide(UIParent, self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback("PlayerTalentFrame.OnHide", self)
				self:UnregisterCallback("PlayerTalentFrame.Summary", self)
			end
		end

		function TalentSummary:OnInitialize()
			self:RegisterCallback("PlayerTalentFrame.OnShow", self.OnInitCallback, self)
		end

		function TalentSummary:OnTrigger()
			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			})

			self:UnregisterCallback("PlayerTalentFrame.OnShow", self)
			self:CloseTips()
			self:RegisterCallback("PlayerTalentFrame.OnHide", self.CloseTips, self, true)
			self:RegisterCallback("PlayerTalentFrame.Summary", self.CloseTips, self, true)
			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget())
			return success
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TalentAvailable, TalentAvailable)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.TalentSummary, TalentSummary)
end

do	-- AchievementMicroButton
	local FirstAchievementNotification = CreateFromMixins(TutorialPrototypeMixin)
	do
		FirstAchievementNotification.owner = "MainMenuBar"
		FirstAchievementNotification.closeCallbackName = "AchievementFrame.OnShow"
		FirstAchievementNotification.callbackTriggerOnly = true

		function FirstAchievementNotification:CanTrigger()
			return HasCompletedAnyAchievement() and CanShowAchievementUI() and (not AchievementFrame or not AchievementFrame:IsShown())
		end

		function FirstAchievementNotification:GetTipText()
			return HELPTIP_ACHIEVEMENT_NOTIFICATION
		end

		function FirstAchievementNotification:GetTarget()
			return AchievementMicroButton
		end

		function FirstAchievementNotification:CloseTips(isCallback)
			HelpTip:Hide(UIParent, self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function FirstAchievementNotification:OnInitialize()
			self:RegisterFrameEventAndCallback("ACHIEVEMENT_EARNED", self.OnInitCallback, self)
		end

		function FirstAchievementNotification:OnTrigger()
			if not HasCompletedAnyAchievement() or not CanShowAchievementUI() then
				return
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			})

			self:UnregisterFrameEventAndCallback("ACHIEVEMENT_EARNED", self)
			self:CloseTips()
			self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget())
			return success
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstAchievementNotification, FirstAchievementNotification)
end

do	-- GuildMicroButton
	local LookingForGuildAvailable = CreateFromMixins(TutorialPrototypeMixin)
	do
		LookingForGuildAvailable.owner = "MainMenuBar"
		LookingForGuildAvailable.closeCallbackName = "LookingForGuild.OnShow"

		local TARGET_LEVEL = 15

		function LookingForGuildAvailable:CanTrigger()
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL and not IsInGuild() and self:GetTarget():IsShown() and not LookingForGuildFrame:IsShown()
				and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
				and not C_Hardcore.IsFeature1Available(Enum.Hardcore.Features1.GUILD)
		end

		function LookingForGuildAvailable:GetTipText()
			return HELPTIP_MICRO_MENU_GUILD
		end

		function LookingForGuildAvailable:GetTarget()
			return GuildMicroButton
		end

		function LookingForGuildAvailable:CloseTips(isCallback)
			HelpTip:Hide(UIParent, self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function LookingForGuildAvailable:OnInitialize()
			if not C_FactionManager.IsFactionDataAvailable() then
				self:RegisterCallback("PlayerFaction.Update", self.OnInitCallback, self, "PlayerFaction.Update")
			end
			self:RegisterFrameEventAndCallback("PLAYER_LEVEL_UP", self.OnInitCallback, self, "PLAYER_LEVEL_UP")
		end

		function LookingForGuildAvailable:OnTrigger(...)
			if not self:CheckConditions(...) then
				return
			end

			self:UnregisterCallback("PlayerFaction.Update", self)
			self:UnregisterFrameEventAndCallback("PLAYER_LEVEL_UP", self)

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			})

			self:CloseTips()
			self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget())
			return success
		end
	end

	local FirstGuildJoined = CreateFromMixins(TutorialPrototypeMixin)
	do
		FirstGuildJoined.owner = "MainMenuBar"
		FirstGuildJoined.closeCallbackName = "GuildFrame.OnShow"
		FirstGuildJoined.callbackTriggerOnly = true

		function FirstGuildJoined:CanTrigger()
			return IsInGuild() and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
				and not C_Hardcore.IsFeature1Available(Enum.Hardcore.Features1.GUILD)
		end

		function FirstGuildJoined:GetTipText()
			return HELPTIP_GUILD_JOINED
		end

		function FirstGuildJoined:GetTarget()
			return GuildMicroButton
		end

		function FirstGuildJoined:CloseTips(isCallback)
			HelpTip:Hide(UIParent, self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function FirstGuildJoined:OnInitialize()
			if not C_FactionManager.IsFactionDataAvailable() then
				self:RegisterCallback("PlayerFaction.Update", self.OnInitCallback, self, "PlayerFaction.Update")
			end
			self:RegisterCallback("GuildEvent.Joined", self.OnInitCallback, self, "GuildEvent.Joined")
		end

		function FirstGuildJoined:OnTrigger(...)
			if not self:CheckConditions(...) then
				return
			end

			self:UnregisterCallback("PlayerFaction.Update", self)
			self:UnregisterCallback("GuildEvent.Joined", self)

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			})

			self:CloseTips()
			self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget())
			return success
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LookingForGuildAvailable, LookingForGuildAvailable)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstGuildJoined, FirstGuildJoined)
end

do	-- LFDMicroButton
	local LFG_PVP_BG_Available = CreateFromMixins(TutorialPrototypeMixin)
	do
		LFG_PVP_BG_Available.priority = 810
		LFG_PVP_BG_Available.registerFactionUpdate = true
	--	LFG_PVP_BG_Available.registerBattlePassUpdate = nil
		LFG_PVP_BG_Available.initEventCallback = "PLAYER_LEVEL_UP"
		LFG_PVP_BG_Available.finishCallback = "PVPHonorFrame.OnShow"
		LFG_PVP_BG_Available.progressCallback_step1_1 = "LFDParentFrame.OnShow"
		LFG_PVP_BG_Available.progressCallback_step1_2 = "PVPUIFrame.OnShow"
		LFG_PVP_BG_Available.progressCallback_step1_3 = "PVPLadderFrame.OnShow"
		LFG_PVP_BG_Available.progressCallback_step1_4 = "RenegadeLadderFrame.OnShow"
		LFG_PVP_BG_Available.progressCallback_step2_1 = "PVPUIFrame.OnShow"
		LFG_PVP_BG_Available.progressCallback_step2_2 = "LFDFrame.TabChanged"
		LFG_PVP_BG_Available.progressRollbackCallback_step2_1 = "LFDParentFrame.OnHide"
		LFG_PVP_BG_Available.progressRollbackCallback_step2_2 = "PVPUIFrame.OnHide"
		LFG_PVP_BG_Available.progressRollbackCallback_step2_3 = "PVPLadderFrame.OnHide"
		LFG_PVP_BG_Available.progressRollbackCallback_step2_4 = "RenegadeLadderFrame.OnHide"
		LFG_PVP_BG_Available.progressRollbackCallback_step3 = "PVPUIFrame.OnHide"

		local TARGET_LEVEL = 10
		local MAX_LEVEL = 80
		local LFG_TAB_ID = 2

		function LFG_PVP_BG_Available:CanInitialize()
			return PRIVATE.GetPlayerLevel() <= MAX_LEVEL
		end

		function LFG_PVP_BG_Available:CanTrigger()
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL and self:GetTarget():IsShown()
				and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
				and not C_Hardcore.IsFeature1Available(Enum.Hardcore.Features1.BATTLEGROUND)
		end

		function LFG_PVP_BG_Available:CanFinishPreemptively()
			return PVPHonorFrame:IsVisible()
		end

		function LFG_PVP_BG_Available:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
		end

		function LFG_PVP_BG_Available:GetTipText(index)
			return HELPTIP_MICRO_MENU_LFD_BATTLGROUND
		end

		function LFG_PVP_BG_Available:GetTarget(index)
			if index == 3 then
				return PVPQueueFrameCategoryButton3
			elseif index == 2 then
				return PRIVATE.GetPVPTabButtonByID(LFG_TAB_ID)
			end
			return LFDMicroButton
		end

		function LFG_PVP_BG_Available:GetTargetPoint(index)
			if index == 3 then
				return HelpTip.Point.RightEdgeCenter
			elseif index == 2 then
				return HelpTip.Point.BottomEdgeCenter
			end
			return HelpTip.Point.TopEdgeCenter
		end

		function LFG_PVP_BG_Available:GetAlignmentPoint(index)
			return HelpTip.Alignment.Center
		end

		function LFG_PVP_BG_Available:UpdateProgress()
			local tutorialIndex = self.tutorialIndex
			if PRIVATE.GetShownLFGFrame() then
				if not PVPUIFrame:IsShown() then
					self.owner = "LFGFrameTab"
					self.tutorialIndex = 2
				else
					self.owner = "PVPUIFrameTab"
					self.tutorialIndex = 3
				end
			else
				self.owner = "MainMenuBar"
				self.tutorialIndex = 1
			end

			self:UpdateProgressCallbacks()
		end

		function LFG_PVP_BG_Available:UpdateProgressCallbacks()
			if self.finishCallback then
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
			end
		--	if self.tutorialIndex == 3 then
				-- select honor tab
				self:RegisterCallback(self.progressRollbackCallback_step3, self.ProgressHelpTips, self, self.progressRollbackCallback_step3)
		--	elseif self.tutorialIndex == 2 then
				-- select pvp tab
				self:RegisterCallback(self.progressCallback_step2_1, self.ProgressHelpTips, self, self.progressCallback_step2_1)
				self:RegisterCallback(self.progressCallback_step2_2, self.ProgressHelpTips, self, self.progressCallback_step2_2)
				self:RegisterCallback(self.progressRollbackCallback_step2_1, self.ProgressHelpTips, self, self.progressRollbackCallback_step2_1)
				self:RegisterCallback(self.progressRollbackCallback_step2_2, self.ProgressHelpTips, self, self.progressRollbackCallback_step2_2)
				self:RegisterCallback(self.progressRollbackCallback_step2_3, self.ProgressHelpTips, self, self.progressRollbackCallback_step2_3)
				self:RegisterCallback(self.progressRollbackCallback_step2_4, self.ProgressHelpTips, self, self.progressRollbackCallback_step2_4)
				self:RegisterCallback(self.progressRollbackCallback_step2_4, self.ProgressHelpTips, self, self.progressRollbackCallback_step2_4)
		--	elseif self.tutorialIndex == 1 then
				-- open lfg frame
				self:RegisterCallback(self.progressCallback_step1_1, self.ProgressHelpTips, self, self.progressCallback_step1_1)
				self:RegisterCallback(self.progressCallback_step1_2, self.ProgressHelpTips, self, self.progressCallback_step1_2)
				self:RegisterCallback(self.progressCallback_step1_3, self.ProgressHelpTips, self, self.progressCallback_step1_3)
				self:RegisterCallback(self.progressCallback_step1_4, self.ProgressHelpTips, self, self.progressCallback_step1_4)
		--	end
		end

		function LFG_PVP_BG_Available:OnInitialize()
			self.tutorialIndex = 1
			self.owner = nil

			if self.initializedCallbacks then
				self:UnregisterCallbacks()
			else
				self.initializedCallbacks = true
			end

			if self.registerFactionUpdate and not C_FactionManager.IsFactionDataAvailable() then
				self:RegisterCallback("PlayerFaction.Update", self.OnInitCallback, self, "PlayerFaction.Update")
			end
			if self.registerBattlePassUpdate then
				self:RegisterCallback("BattlePass.SeasonUpdate", self.OnInitCallback, self, "BattlePass.SeasonUpdate")
			end

			if self.initCallback then
				self:RegisterCallback(self.initCallback, self.OnInitCallback, self, self.initCallback)
			end
			if self.initEventCallback then
				self:RegisterFrameEventAndCallback(self.initEventCallback, self.OnInitCallback, self, self.initEventCallback)
			end
		end

		function LFG_PVP_BG_Available:OnTriggerUnregisterInitCallbacks()
			if self.registerFactionUpdate then
				self:UnregisterCallback("PlayerFaction.Update", self)
			end
			if self.registerBattlePassUpdate then
				self:UnregisterCallback("BattlePass.SeasonUpdate", self)
			end
			if self.type ~= Enum.CustomNPE_Type.Repeatable then
				if self.initCallback then
					self:UnregisterCallback(self.initCallback, self)
				end
				if self.initEventCallback then
					self:UnregisterFrameEventAndCallback("PLAYER_LEVEL_UP", self)
				end
			end
		end

		function LFG_PVP_BG_Available:OnTrigger(...)
			if not self:CheckConditions(...) then
				return
			end

			if self:CanFinishPreemptively() then
				self:FinishTutorial()
				return
			end

			self:OnTriggerUnregisterInitCallbacks()
			self:UpdateProgress()

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(...)
				return
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(self.tutorialIndex),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = self:GetTargetPoint(self.tutorialIndex),
				alignment = self:GetAlignmentPoint(self.tutorialIndex),
			})

			self:CloseTips()

			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget(self.tutorialIndex))
			return success
		end

		function LFG_PVP_BG_Available:IsRollbackEvent(event)
			if event == self.progressRollbackCallback_step2_1 or event == self.progressRollbackCallback_step2_2
			or event == self.progressRollbackCallback_step2_3 or event == self.progressRollbackCallback_step2_4
			or event == self.progressRollbackCallback_step3
			then
				return true
			end
		end

		function LFG_PVP_BG_Available:ProgressHelpTips(event, ...)
			self:CloseTips()

			if event == self.finishCallback then
				self:FinishTutorial()
				return
			elseif self:IsRollbackEvent(event) then
				local forceReset
				if not self.isShown then
					local success = self:DeQueueTrigger()
					forceReset = success
				end
				if self.tutorialIndex > 1 or forceReset then -- reset
					self:ResetTutorialFlag()
					self:UpdateProgress()
					self:ReQueueTrigger(event, ...)
					return
				end
			end

			self:UpdateProgress()
			self:QueueTrigger(event, ...)
		end
	end

	local LFG_PVE_Dungeon_Available = CreateFromMixins(LFG_PVP_BG_Available)
	do
		LFG_PVE_Dungeon_Available.priority = 820
		LFG_PVE_Dungeon_Available.finishCallback = "LFDParentFrame.OnShow"
		LFG_PVE_Dungeon_Available.progressCallback_step2_1 = "LFDParentFrame.OnShow"
		LFG_PVE_Dungeon_Available.progressRollbackCallback_step3 = "LFDParentFrame.OnHide"

		local TARGET_LEVEL = 15
		local MAX_LEVEL = 79
		local LFG_TAB_ID = 1

		function LFG_PVE_Dungeon_Available:CanInitialize()
			return PRIVATE.GetPlayerLevel() <= MAX_LEVEL
		end

		function LFG_PVE_Dungeon_Available:CanTrigger()
			local level = PRIVATE.GetPlayerLevel()
			return level >= TARGET_LEVEL and level <= MAX_LEVEL and self:GetTarget(1):IsShown()
				and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
				and not C_Hardcore.IsFeature1Available(Enum.Hardcore.Features1.DUNGEON_AVAILABLE)
		end

		function LFG_PVE_Dungeon_Available:CanFinishPreemptively()
			return LFDQueueParentFrame:IsVisible()
		end

		function LFG_PVE_Dungeon_Available:GetTipText()
			return HELPTIP_MICRO_MENU_LFD_DUNGEON
		end

		function LFG_PVE_Dungeon_Available:GetTarget(index)
			if index == 3 then
				return LFDParentFrameGroupButton1
			elseif index == 2 then
				return PRIVATE.GetPVPTabButtonByID(LFG_TAB_ID)
			end
			return LFDMicroButton
		end

		function LFG_PVE_Dungeon_Available:GetTargetPoint(index)
			if index == 4 then
				return HelpTip.Point.RightEdgeCenter
			elseif index == 3 then
				return HelpTip.Point.RightEdgeCenter
			elseif index == 2 then
				return HelpTip.Point.BottomEdgeCenter
			end
			return LFG_PVP_BG_Available.GetTargetPoint(self, index)
		end

		function LFG_PVE_Dungeon_Available:GetAlignmentPoint(index)
			if index == 2 then
				return HelpTip.Alignment.Left
			end
			return HelpTip.Alignment.Center
		end

		function LFG_PVE_Dungeon_Available:UpdateProgress()
			local tutorialIndex = self.tutorialIndex
			if PRIVATE.GetShownLFGFrame() then
				if not LFDParentFrame:IsVisible() then
					self.owner = "LFGFrameTab"
					self.tutorialIndex = 2
				else
					self.owner = "PVEUIFrameTab"
					self.tutorialIndex = 3
				end
			else
				self.owner = "MainMenuBar"
				self.tutorialIndex = 1
			end

			self:UpdateProgressCallbacks()
		end
	end

	local LFG_PVE_DungeonHeroic_Available = CreateFromMixins(LFG_PVE_Dungeon_Available)
	do
		LFG_PVE_DungeonHeroic_Available.priority = 821
		LFG_PVE_DungeonHeroic_Available.finishCallback = nil
		LFG_PVE_DungeonHeroic_Available.progressCallback_step4 = "LFDQueueFrame.OnShow"
		LFG_PVE_DungeonHeroic_Available.progressRollbackCallback_step4 = "LFDQueueFrame.OnHide"

		local TARGET_LEVEL = 80
		local LFG_TAB_ID = 1

		function LFG_PVE_DungeonHeroic_Available:CanInitialize()
			return true
		end

		function LFG_PVE_DungeonHeroic_Available:CanTrigger()
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL and self:GetTarget(1):IsShown()
			--	and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
		end

		function LFG_PVE_DungeonHeroic_Available:CanFinishPreemptively()
			return false
		end

		function LFG_PVE_DungeonHeroic_Available:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
			HelpTip:Hide(UIParent, self:GetTipText(4))
		end

		function LFG_PVE_DungeonHeroic_Available:GetTipText(index)
			if index == 4 then
				return HELPTIP_MICRO_MENU_LFD_DUNGEON_HEROIC_DROPDOWN
			end
			return HELPTIP_MICRO_MENU_LFD_DUNGEON_HEROIC
		end

		function LFG_PVE_DungeonHeroic_Available:GetTarget(index)
			if index == 4 then
				return LFDQueueFrameTypeDropDown.Button
			elseif index == 3 then
				return LFDParentFrameGroupButton1
			elseif index == 2 then
				return PRIVATE.GetPVPTabButtonByID(LFG_TAB_ID)
			end
			return LFDMicroButton
		end

		function LFG_PVE_DungeonHeroic_Available:UpdateProgress()
			local tutorialIndex = self.tutorialIndex
			if PRIVATE.GetShownLFGFrame() then
				if not LFDParentFrame:IsVisible() then
					self.owner = "LFGFrameTab"
					self.tutorialIndex = 2
				elseif not LFDQueueParentFrame:IsVisible() then
					self.owner = "PVEUIFrameTab"
					self.tutorialIndex = 3
				else
					self.owner = "PVEUIFrame"
					self.tutorialIndex = 4
				end
			else
				self.owner = "MainMenuBar"
				self.tutorialIndex = 1
			end

			self:UpdateProgressCallbacks()
		end

		function LFG_PVE_DungeonHeroic_Available:IsRollbackEvent(event)
			if event == self.progressRollbackCallback_step4 then
				return true
			end
			return LFG_PVE_Dungeon_Available.IsRollbackEvent(self, event)
		end

		function LFG_PVE_DungeonHeroic_Available:UpdateProgressCallbacks()
			if self.tutorialIndex == 4 then
				self:RegisterCallback(self.progressCallback_step4, self.ProgressHelpTips, self, self.progressCallback_step4)
				self:RegisterCallback(self.progressRollbackCallback_step4, self.ProgressHelpTips, self, self.progressRollbackCallback_step4)
			end
			return LFG_PVE_Dungeon_Available.UpdateProgressCallbacks(self)
		end
	end

	local LFG_PVP_BattlePass_20 = CreateFromMixins(LFG_PVP_BG_Available)
	do
		LFG_PVP_BattlePass_20.registerBattlePassUpdate = true
		LFG_PVP_BattlePass_20.finishCallback = "BattlePassFrame.OnShow"
		LFG_PVP_BattlePass_20.priority = 840

		local LFG_TAB_ID = 2
		local TARGET_LEVEL = 20
		local MAX_LEVEL = 76

		function LFG_PVP_BattlePass_20:CanInitialize()
			return PRIVATE.GetPlayerLevel() <= MAX_LEVEL
		end

		function LFG_PVP_BattlePass_20:CanTrigger()
			local level = PRIVATE.GetPlayerLevel()
			return level >= TARGET_LEVEL and level <= MAX_LEVEL and C_BattlePass.IsActiveOrHasRewards() and self:GetTarget(1):IsShown()
				and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
				and not C_Hardcore.IsFeature1Available(Enum.Hardcore.Features1.DUNGEON_AVAILABLE)
		end

		function LFG_PVP_BattlePass_20:CanFinishPreemptively()
			return BattlePassFrame:IsVisible()
		end

		function LFG_PVP_BattlePass_20:GetTipText()
			return HELPTIP_BATTLEPASS_AVAILABLE
		end

		function LFG_PVP_BattlePass_20:GetTarget(index)
			if index == 3 then
				return PVPQueueFrameBattlePassToggleButton
			elseif index == 2 then
				return PRIVATE.GetPVPTabButtonByID(LFG_TAB_ID)
			end
			return LFDMicroButton
		end
	end

	local LFG_PVP_BattlePass_77 = CreateFromMixins(LFG_PVP_BattlePass_20)
	do
		LFG_PVP_BattlePass_77.priority = 841
		local TARGET_LEVEL = 77

		function LFG_PVP_BattlePass_77:CanInitialize()
			return true
		end

		function LFG_PVP_BattlePass_77:CanTrigger(...)
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL and C_BattlePass.IsActiveOrHasRewards() and self:GetTarget():IsShown()
				and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
		end
	end

	local LFG_PVP_Brawl_Changed = CreateFromMixins(LFG_PVP_BG_Available)
	do
		LFG_PVP_Brawl_Changed.priority = 830
		LFG_PVP_Brawl_Changed.callbackTriggerOnly = true
		LFG_PVP_Brawl_Changed.registerFactionUpdate = nil
		LFG_PVP_Brawl_Changed.initEventCallback = nil
		LFG_PVP_Brawl_Changed.initCallback = "Brawl.Changed"

		local TARGET_LEVEL = 80

		function LFG_PVP_Brawl_Changed:CanInitialize()
			return true
		end

		function LFG_PVP_Brawl_Changed:CanTrigger()
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL and self:GetTarget(1):IsShown()
		end

		function LFG_PVP_Brawl_Changed:CloseTips()
			if self.brawlText then
				HelpTip:Hide(UIParent, self.brawlText)
			end
			if self.oldBrawlText then
				HelpTip:Hide(UIParent, self.oldBrawlText)
				self.oldBrawlText = nil
			end
		end

		function LFG_PVP_Brawl_Changed:GetTipText(index)
			return self.brawlText
		end

		function LFG_PVP_Brawl_Changed:OnInitCallback(event, brawlID, ...)
			if event == self.initCallback then
				self.oldBrawlID = self.brawlID
				self.brawlID = brawlID
				self.oldBrawlText = self.brawlText

				local brawlName = GetBattlegroundInfoByID(brawlID)
				if brawlName then
					self.brawlText = string.format(HELPTIP_NEW_BRAWL_AVAILABLE, brawlName)
				else
					GMError(string.format("[Tutorial] Brawl has no name! (%s)", string.join(", ", event or "nil", brawlID or "nil")))
					-- no text, skip tutorial
					return
				end
			end
			return TutorialPrototypeMixin.OnInitCallback(self, event, ...)
		end

		function LFG_PVP_Brawl_Changed:OnTrigger(...)
			if self.oldBrawlText then
				HelpTip:Hide(UIParent, self.oldBrawlText)
				self.oldBrawlText = nil
			end

			if not self.brawlText then
				return
			end

			return LFG_PVP_BG_Available.OnTrigger(self, ...)
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LFG_PVP_BG_Available, LFG_PVP_BG_Available)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LFG_PVE_Dungeon_Available, LFG_PVE_Dungeon_Available)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LFG_PVE_DungeonHeroic_Available, LFG_PVE_DungeonHeroic_Available)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LFG_PVP_BattlePass_20, LFG_PVP_BattlePass_20)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LFG_PVP_BattlePass_77, LFG_PVP_BattlePass_77)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Hint.LFG_PVP_NewBrawl_Changed, LFG_PVP_Brawl_Changed, true)
end

do	-- CollectionsMicroButton
	local COLLECTION_TABS = {
		[1] = CollectionsJournalTab1,
		[2] = CollectionsJournalTab2,
		[3] = CollectionsJournalTab3,
		[4] = CollectionsJournalTab4,
		[5] = CollectionsJournalTab5,
	}

	local CollectionTutorialMixin = CreateFromMixins(TutorialPrototypeMixin)
	do
		CollectionTutorialMixin.closeCallbackName = "CollectionsJournal.SetTab"
		CollectionTutorialMixin.closeTabCallbackName = "CollectionsJournal.OnHide"
		CollectionTutorialMixin.owner = "MainMenuBar"
	--	CollectionTutorialMixin.collectionTabID = 1
	--	CollectionTutorialMixin.initCallback = "COMPANION_LEARNED"

		local tutorialHintInfo = {
			[1] = {
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Right,
			},
			[2] = {
				targetPoint = HelpTip.Point.BottomEdgeCenter,
				alignment = HelpTip.Alignment.Left,
			},
		}

		function CollectionTutorialMixin:CanFinishPreemptively()
			if CollectionsJournal:IsVisible()
			and PanelTemplates_GetSelectedTab(CollectionsJournal) == self.collectionTabID
			then
				return true
			end
		end

		function CollectionTutorialMixin:GetTarget(index)
			if index == 2 then
				return COLLECTION_TABS[self.collectionTabID]
			end
			return CollectionsMicroButton
		end

		function CollectionTutorialMixin:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
			HelpTip:Hide(UIParent, self:GetTipText(2))
		end

		function CollectionTutorialMixin:OnInitialize()
			self.tutorialIndex = 1
			self.owner = nil

			local onLoadTriggerSuccess = self:TryTriggerOnLoad()
			if onLoadTriggerSuccess then
				return
			end

			self:RegisterCallback(self.initCallback, self.OnInitCallback, self)
		end

		function CollectionTutorialMixin:TryTriggerOnLoad()
			return false
		end

		function CollectionTutorialMixin:GetOwnerByState(state)
			if state then
				return "CollectionsJournal"
			else
				return "MainMenuBar"
			end
		end

		function CollectionTutorialMixin:UpdateProgress(preserveStepIndex)
			local isCollectionsShown = CollectionsJournal:IsShown()
			self.owner = self:GetOwnerByState(isCollectionsShown)
			if not preserveStepIndex then
				self.tutorialIndex = isCollectionsShown and 2 or 1
			end
		end

		function CollectionTutorialMixin:OnTrigger(...)
			if self:CanFinishPreemptively() then
				self:FinishTutorial()
				return
			end

			self:UnregisterCallback(self.initCallback, self)
			self:UpdateProgress()

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(...)
				return
			end

			local isCollectionsShown = CollectionsJournal:IsShown()
			if isCollectionsShown then
				local collectionSelectedTab = PanelTemplates_GetSelectedTab(CollectionsJournal)
				if collectionSelectedTab ~= self.collectionTabID then
					self.tutorialIndex = 2
					self:RegisterCallback(self.closeTabCallbackName, self.ProgressHelpTips, self, self.closeTabCallbackName)
					self:RegisterCallback(self.closeCallbackName, self.ProgressHelpTips, self, self.closeCallbackName)
				else
					self:FinishTutorial()
					return
				end
			else
				self:RegisterCallback(self.closeCallbackName, self.ProgressHelpTips, self, self.closeCallbackName)
				PanelTemplates_SetTab(CollectionsJournal, self.collectionTabID)
			end

			local finishOnClose = self.tutorialIndex == 2
			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(self.tutorialIndex),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = tutorialHintInfo[self.tutorialIndex].targetPoint,
				alignment = tutorialHintInfo[self.tutorialIndex].alignment,
			}, not finishOnClose)

			self:CloseTips()

			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget(self.tutorialIndex))
			return success
		end

		function CollectionTutorialMixin:ProgressHelpTips(event, tabID, ...)
			self:CloseTips()

			if event == self.closeTabCallbackName then
				local forceReset
				if not self.isShown then
					local success = self:DeQueueTrigger()
					forceReset = success
				end
				if self.tutorialIndex > 1 or forceReset then -- reset
					self:ResetTutorialFlag()
					self:UpdateProgress()
					self:ReQueueTrigger(event, tabID, ...)
					return
				else -- progress
					self.tutorialIndex = 2
				end
			end

			if tabID == self.collectionTabID or not CollectionsJournal:IsShown() then
				self:FinishTutorial()
				return
			end

			self:UpdateProgress(true)
			self:QueueTrigger(event, tabID)
		end
	end

	local FirstMountLearned = CreateFromMixins(CollectionTutorialMixin)
	do
		FirstMountLearned.collectionTabID = 1
		FirstMountLearned.initCallback = "COMPANION_LEARNED"
		FirstMountLearned.priority = 105

		function FirstMountLearned:CanInitialize()
			return GetNumCompanions("MOUNT") == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function FirstMountLearned:CanTrigger(...)
			if self.tutorialIndex == 1 then
				return GetNumCompanions("MOUNT") > 0 and self:GetTarget():IsShown()
			elseif self.tutorialIndex == 2 then
				local tabID = ...
				return tabID ~= self.collectionTabID
			end
		end

		function FirstMountLearned:GetTipText(step)
			if step == 2 then
				return HELPTIP_COLLECTION_MOUNT_CHANGE_TAB
			end
			return HELPTIP_FIRST_MOUNT_LEARNED
		end

		function FirstMountLearned:TryTriggerOnLoad()
			if PRIVATE.GetPlayerLevel() == 1 and self:CanTrigger() then
				self:UpdateProgress()
				self:QueueTrigger()
				return true
			end
		end
	end

	local FirstPetLearned = CreateFromMixins(CollectionTutorialMixin)
	do
		FirstPetLearned.collectionTabID = 2
		FirstPetLearned.initCallback = "COMPANION_LEARNED"
		FirstMountLearned.priority = 104

		function FirstPetLearned:CanInitialize()
			return GetNumCompanions("CRITTER") == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function FirstPetLearned:CanTrigger(...)
			if self.tutorialIndex == 1 then
				return GetNumCompanions("CRITTER") > 0 and self:GetTarget(1):IsShown()
			elseif self.tutorialIndex == 2 then
				local tabID = ...
				return tabID ~= self.collectionTabID
			end
		end

		function FirstPetLearned:GetTipText(step)
			if step == 2 then
				return HELPTIP_COLLECTION_PET_CHANGE_TAB
			end
			return HELPTIP_FIRST_PET_LEARNED
		end

		function FirstPetLearned:TryTriggerOnLoad()
			if PRIVATE.GetPlayerLevel() == 1 and self:CanTrigger() then
				self:UpdateProgress()
				self:QueueTrigger()
				return true
			end
		end
	end

	local FirstToyLearned = CreateFromMixins(CollectionTutorialMixin)
	do
		FirstToyLearned.collectionTabID = 4
		FirstToyLearned.initCallback = "Toys.Updated"
		FirstToyLearned.priority = 103

		function FirstToyLearned:CanInitialize()
			return C_ToyBox.GetNumLearnedDisplayedToys() == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function FirstToyLearned:CanTrigger(arg1, arg2)
			if self.tutorialIndex == 1 and arg2 then
				return C_ToyBox.GetNumLearnedDisplayedToys() > 0 and self:GetTarget(1):IsShown()
			elseif self.tutorialIndex == 2 then
				return arg1 ~= self.collectionTabID
			end
		end

		function FirstToyLearned:GetTipText(step)
			if step == 2 then
				return HELPTIP_COLLECTION_TOY_CHANGE_TAB
			end
			return HELPTIP_FIRST_TOY_LEARNED
		end

		function FirstToyLearned:TryTriggerOnLoad()
			if PRIVATE.GetPlayerLevel() == 1 and self:CanTrigger(nil, true) then
				self:UpdateProgress()
				self:QueueTrigger(nil, true)
				return true
			end
		end
	end

	local HeirloomLearned = CreateFromMixins(CollectionTutorialMixin)
	do
		HeirloomLearned.collectionTabID = 5
		HeirloomLearned.initCallback = "Heirloom.Updated"
		HeirloomLearned.priority = 950

		function HeirloomLearned:CanInitialize()
			local _, _, classID = UnitClass("player")
			return C_Heirloom.GetNumLearnedHeirloomsForClass(classID) == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function HeirloomLearned:CanTrigger(arg1, arg2)
			if self.tutorialIndex == 1 and arg2 then
				local _, _, classID = UnitClass("player")
				return C_Heirloom.GetNumLearnedHeirloomsForClass(classID) > 0 and self:GetTarget(1):IsVisible()
			elseif self.tutorialIndex == 2 then
				return arg1 ~= self.collectionTabID
			end
		end

		function HeirloomLearned:GetTipText(step)
			if step == 2 then
				return HELPTIP_COLLECTION_HEIRLOOM_CHANGE_TAB
			end
			return HELPTIP_FIRST_HEIRLOOM_LEARNED
		end

		function HeirloomLearned:TryTriggerOnLoad()
			if PRIVATE.GetPlayerLevel() == 1 and self:CanTrigger(nil, true) then
				self:UpdateProgress()
				self:QueueTrigger(nil, true)
				return true
			end
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstMountLearned, FirstMountLearned)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstPetLearned, FirstPetLearned)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstToyLearned, FirstToyLearned)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.HeirloomLearned, HeirloomLearned)
end

do	-- EncounterJournalMicroButton
	local HeadHunterNotification = CreateFromMixins(TutorialPrototypeMixin)
	do
		HeadHunterNotification.owner = "MainMenuBar"
		HeadHunterNotification.initCallback = "PLAYER_LEVEL_UP"
		HeadHunterNotification.initCallback2 = "DeathRecap.DeathByOtherPlayer"
		HeadHunterNotification.finishCallback = "HeadHuntingFrame.OnShow"
		HeadHunterNotification.progressCallback = "EncounterJournal.OnShow"
		HeadHunterNotification.progressCallback2 = "HardcoreFrame.OnShow"
		HeadHunterNotification.progressRollbackCallback = "EncounterJournal.OnHide"
		HeadHunterNotification.progressRollbackCallback2 = "HardcoreFrame.OnHide"

		local TARGET_LEVEL = 25

		local tutorialHintInfo = {
			[1] = {
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Right,
			},
			[2] = {
				targetPoint = HelpTip.Point.BottomEdgeCenter,
				alignment = HelpTip.Alignment.Center,
			},
		}

		function HeadHunterNotification:CanInitialize()
			return not C_Service.IsHardcoreCharacter()
		end

		function HeadHunterNotification:CanTrigger()
			return C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
		end

		function HeadHunterNotification:CanFinishPreemptively()
			return HeadHuntingFrame:IsVisible()
		end

		function HeadHunterNotification:CheckConditions(event)
			local inInstance, instanceType = IsInInstance()
			if instanceType ~= "none" then
				return
			end
			if event ~= "DeathRecap.DeathByOtherPlayer" and PRIVATE.GetPlayerLevel() < TARGET_LEVEL then
				return
			end
			return true
		end

		function HeadHunterNotification:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
			HelpTip:Hide(UIParent, self:GetTipText(2))
		end

		function HeadHunterNotification:GetTipText(index)
			if index == 2 then
				return HELPTIP_HEAD_HUNTING_TAB_NOTIFICATION
			end
			return HELPTIP_HEAD_HUNTING_NOTIFICATION
		end

		function HeadHunterNotification:GetTarget(index)
			if index == 2 then
				return HardcoreFrame:IsShown() and HardcoreFrameTab2 or EncounterJournalTab2
			end
			return EncounterJournalMicroButton
		end

		function HeadHunterNotification:OnInitialize()
			self.tutorialIndex = 1
			self.owner = nil

			local onLoadTriggerSuccess = self:OnInitCallback()
			if onLoadTriggerSuccess then
				return
			end

			if not C_FactionManager.IsFactionDataAvailable() then
				self:RegisterCallback("PlayerFaction.Update", self.OnInitCallback, self, "PlayerFaction.Update")
			end
			self:RegisterFrameEventAndCallback(self.initCallback, self.OnInitCallback, self, self.initCallback)
			self:RegisterCallback(self.initCallback2, self.OnInitCallback, self, self.initCallback2)
		end

		function HeadHunterNotification:UpdateProgress(preserveStepIndex)
			local isJournalShown = EncounterJournal:IsShown() or HardcoreFrame:IsShown()
			if isJournalShown then
				self.owner = "EncounterJournal"
			else
				self.owner = "MainMenuBar"
			end
			if not preserveStepIndex then
				self.tutorialIndex = isJournalShown and 2 or 1
			end
		end

		function HeadHunterNotification:OnTrigger(event)
			if not self:CheckConditions(event) then
				return
			end

			if self:CanFinishPreemptively() then
				self:FinishTutorial()
				return
			end

			self:UnregisterCallback("PlayerFaction.Update", self)
			self:UnregisterFrameEventAndCallback(self.initCallback, self)
			self:UnregisterCallback(self.initCallback2, self)

			self:UpdateProgress()

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(event)
				return
			end

			local isJournalShown = EncounterJournal:IsShown() or HardcoreFrame:IsShown()
			if isJournalShown then
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
				self:RegisterCallback(self.progressRollbackCallback, self.ProgressHelpTips, self, self.progressRollbackCallback)
				self:RegisterCallback(self.progressRollbackCallback2, self.ProgressHelpTips, self, self.progressRollbackCallback2)
			else
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
				self:RegisterCallback(self.progressCallback, self.ProgressHelpTips, self, self.progressCallback)
				self:RegisterCallback(self.progressCallback2, self.ProgressHelpTips, self, self.progressCallback2)
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(self.tutorialIndex),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = tutorialHintInfo[self.tutorialIndex].targetPoint,
				alignment = tutorialHintInfo[self.tutorialIndex].alignment,
			})

			self:CloseTips()

			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget(self.tutorialIndex))
			return success
		end

		function HeadHunterNotification:ProgressHelpTips(event, ...)
			self:CloseTips()

			if event == self.finishCallback then
				self:FinishTutorial()
				return
			elseif event == self.progressRollbackCallback or event == self.progressRollbackCallback2 then
				if IsAdventureTabSwitching() then
					return
				end

				local forceReset
				if not self.isShown then
					local success = self:DeQueueTrigger()
					forceReset = success
				end
				if self.tutorialIndex > 1 or forceReset then -- reset
					self:ResetTutorialFlag()
					self:UpdateProgress()
					self:ReQueueTrigger(event, ...)
					return
				end
			elseif event == self.progressCallback or event == self.progressCallback2 then
				self.tutorialIndex = 2
			end

			self:UpdateProgress(true)
			self:QueueTrigger(event, ...)
		end
	end

	local EncounterJournalTutorialMixin = CreateFromMixins(TutorialPrototypeMixin)
	do
		EncounterJournalTutorialMixin.owner = "MainMenuBar"
		EncounterJournalTutorialMixin.closeCallbackName = "EncounterJournal.SetTab"
		EncounterJournalTutorialMixin.closeTabCallbackName = "EncounterJournal.OnHide"
		EncounterJournalTutorialMixin.initCallback = "PLAYER_LEVEL_UP"
		EncounterJournalTutorialMixin.callbackTriggerOnly = true
	--	EncounterJournalTutorialMixin.tabID = 1

		local tutorialHintInfo = {
			[1] = {
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Right,
				offsetX = 0,
			},
			[2] = {
				targetPoint = HelpTip.Point.RightEdgeCenter,
				alignment = HelpTip.Alignment.Right,
				offsetX = 10,
			},
		}

		function EncounterJournalTutorialMixin:CanFinishPreemptively()
			if EncounterJournal:IsVisible()
			and EncounterJournal.instanceSelect.selectedTab == self.tabID
			then
				return true
			end
		end

		function EncounterJournalTutorialMixin:GetTarget(index)
			if index == 2 then
				for tabIndex, tab in ipairs(EncounterJournal.instanceSelect.Tabs) do
					if tab.id == self.tabID then
						return tab
					end
				end
				return
			end
			return EncounterJournalMicroButton
		end

		function EncounterJournalTutorialMixin:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
			HelpTip:Hide(UIParent, self:GetTipText(2))
		end

		function EncounterJournalTutorialMixin:OnInitialize()
			self.tutorialIndex = 1
			self.owner = nil

			local onLoadTriggerSuccess = self:TryTriggerOnLoad()
			if onLoadTriggerSuccess then
				return
			end

			self:RegisterFrameEventAndCallback(self.initCallback, self.OnInitCallback, self)
		end

		function EncounterJournalTutorialMixin:TryTriggerOnLoad()
			if self:CanTrigger() then
				self:UpdateProgress()
				self:QueueTrigger()
				return true
			end
		end

		function EncounterJournalTutorialMixin:GetOwnerByState(state)
			if state then
				return "EncounterJournal"
			else
				return "MainMenuBar"
			end
		end

		function EncounterJournalTutorialMixin:UpdateProgress(preserveStepIndex)
			local isCollectionsShown = EncounterJournal:IsShown()
			self.owner = self:GetOwnerByState(isCollectionsShown)
			if not preserveStepIndex then
				self.tutorialIndex = isCollectionsShown and 2 or 1
			end
		end

		function EncounterJournalTutorialMixin:OnTrigger(...)
			if self:CanFinishPreemptively() then
				self:FinishTutorial()
				return
			end

			self:UnregisterFrameEventAndCallback(self.initCallback, self)
			self:UpdateProgress()

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(...)
				return
			end

			local isFrameShown = EncounterJournal:IsShown()
			if isFrameShown then
				local selectedTab = EncounterJournal.instanceSelect.selectedTab
				if selectedTab ~= self.tabID then
					self.tutorialIndex = 2
					self:RegisterCallback(self.closeTabCallbackName, self.ProgressHelpTips, self, self.closeTabCallbackName)
					self:RegisterCallback(self.closeCallbackName, self.ProgressHelpTips, self, self.closeCallbackName)
				else
					self:FinishTutorial()
					return
				end
			else
				self:RegisterCallback(self.closeCallbackName, self.ProgressHelpTips, self, self.closeCallbackName)
				EJ_ContentTab_Select(self.tabID)
			end

			local finishOnClose = self.tutorialIndex == 2
			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(self.tutorialIndex),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = tutorialHintInfo[self.tutorialIndex].targetPoint,
				alignment = tutorialHintInfo[self.tutorialIndex].alignment,
				offsetX = tutorialHintInfo[self.tutorialIndex].offsetX,
			}, not finishOnClose)

			self:CloseTips()

			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget(self.tutorialIndex))
			return success
		end

		function EncounterJournalTutorialMixin:ProgressHelpTips(event, tabID, ...)
			if event == self.closeCallbackName and not EncounterJournal:IsShown() then
				return
			end

			self:CloseTips()

			if event == self.closeTabCallbackName then
				local forceReset
				if not self.isShown then
					local success = self:DeQueueTrigger()
					forceReset = success
				end
				if self.tutorialIndex > 1 or forceReset then -- reset
					self:ResetTutorialFlag()
					self:UpdateProgress()
					self:ReQueueTrigger(event, tabID, ...)
					return
				else -- progress
					self.tutorialIndex = 2
				end
			end

			if tabID == self.tabID or not EncounterJournal:IsShown() then
				self:FinishTutorial()
				return
			end

			self:UpdateProgress(true)
			self:QueueTrigger(event, tabID)
		end
	end

	local EncounterJournalNotification = CreateFromMixins(EncounterJournalTutorialMixin)
	do
		EncounterJournalNotification.initCallback = "LFG_COMPLETION_REWARD"
		EncounterJournalNotification.tabID = 2

		function EncounterJournalNotification:CanTrigger()
			return self.LFG_COMPLETION_REWARD and C_FactionManager.IsFactionDataAvailable() and not C_Unit.IsNeutral("player")
		end

		function EncounterJournalNotification:GetTipText(step)
			return HELPTIP_MICRO_MENU_ENCOUNTER_JOURNAL
		end

		function EncounterJournalNotification:OnInitialize()
			if not C_FactionManager.IsFactionDataAvailable() then
				self:RegisterCallback("PlayerFaction.Update", self.OnInitCallback, self, "PlayerFaction.Update")
			end
			EncounterJournalTutorialMixin.OnInitialize(self)
		end

		function EncounterJournalNotification:OnInitCallback(event, ...)
			if event == "LFG_COMPLETION_REWARD" then
				self.LFG_COMPLETION_REWARD = true
			end
			return EncounterJournalTutorialMixin.OnInitCallback(self, event, ...)
		end
	end

	local SuggestedContentNotification = CreateFromMixins(EncounterJournalTutorialMixin)
	do
		SuggestedContentNotification.tabID = 1
		SuggestedContentNotification.ignoreShowCVar = true

		local TARGET_LEVEL = 10

		function SuggestedContentNotification:CanTrigger()
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL
		end

		function SuggestedContentNotification:GetTipText(step)
			if step == 2 then
				return HELPTIP_MICRO_MENU_ENCOUNTER_JOURNAL_SUGGESTED_CONTENT_CHANGE_TAB
			end
			return HELPTIP_MICRO_MENU_ENCOUNTER_JOURNAL_SUGGESTED_CONTENT
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.HeadHunterNotification, HeadHunterNotification)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.EncounterJournalNotification, EncounterJournalNotification)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.SuggestedContentNotification, SuggestedContentNotification)
end

do	-- MainMenuMicroButton
	local KnowledgeBaseNotification = CreateFromMixins(TutorialPrototypeMixin)
	do
		KnowledgeBaseNotification.owner = "MainMenuBar"
		KnowledgeBaseNotification.initCallback = "PLAYER_LEVEL_UP"
		KnowledgeBaseNotification.finishCallback = "HelpFrame.OnShow"
		KnowledgeBaseNotification.progressCallback = "GameMenuFrame.OnShow"
		KnowledgeBaseNotification.progressRollbackCallback = "GameMenuFrame.OnHide"

		local tutorialHintInfo = {
			[1] = {
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Right,
			},
			[2] = {
				targetPoint = HelpTip.Point.RightEdgeCenter,
				alignment = HelpTip.Alignment.Center,
			},
		}

		local TARGET_LEVEL = 5

		function KnowledgeBaseNotification:CanTrigger()
			return PRIVATE.GetPlayerLevel() >= TARGET_LEVEL and self:GetTarget():IsShown() and not HelpFrame:IsShown()
		end

		function KnowledgeBaseNotification:CanFinishPreemptively()
			return HelpFrame:IsVisible()
		end

		function KnowledgeBaseNotification:CloseTips()
			HelpTip:Hide(UIParent, self:GetTipText(1))
			HelpTip:Hide(UIParent, self:GetTipText(2))
		end

		function KnowledgeBaseNotification:GetTipText(index)
			if index == 2 then
				return HELPTIP_KNOWLEDGEBASE_NOTIFICATION_2
			end
			return HELPTIP_KNOWLEDGEBASE_NOTIFICATION
		end

		function KnowledgeBaseNotification:GetTarget(index)
			if index == 2 then
				return GameMenuButtonHelp
			end
			return MainMenuMicroButton
		end

		function KnowledgeBaseNotification:OnInitialize()
			self.tutorialIndex = 1
			self.owner = nil

			local onLoadTriggerSuccess = self:OnInitCallback()
			if onLoadTriggerSuccess then
				return
			end

			self:RegisterFrameEventAndCallback(self.initCallback, self.OnInitCallback, self)
		end

		function KnowledgeBaseNotification:UpdateProgress(preserveStepIndex)
			local isGameMenuFrameShown = GameMenuFrame:IsShown()
			if isGameMenuFrameShown then
				self.owner = "GameMenu"
			else
				self.owner = "MainMenuBar"
			end
			if not preserveStepIndex then
				self.tutorialIndex = isGameMenuFrameShown and 2 or 1
			end
		end

		function KnowledgeBaseNotification:OnTrigger(...)
			if self:CanFinishPreemptively() then
				self:FinishTutorial()
				return
			end

			self:UnregisterFrameEventAndCallback(self.initCallback, self)
			self:UpdateProgress()

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(...)
				return
			end

			if GameMenuFrame:IsShown() then
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
				self:RegisterCallback(self.progressRollbackCallback, self.ProgressHelpTips, self, self.progressRollbackCallback)
			else
				self:RegisterCallback(self.finishCallback, self.ProgressHelpTips, self, self.finishCallback)
				self:RegisterCallback(self.progressCallback, self.ProgressHelpTips, self, self.progressCallback)
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(self.tutorialIndex),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = tutorialHintInfo[self.tutorialIndex].targetPoint,
				alignment = tutorialHintInfo[self.tutorialIndex].alignment,
			})

			self:CloseTips()

			local success = HelpTip:Show(UIParent, helpTipInfo, self:GetTarget(self.tutorialIndex))
			return success
		end

		function KnowledgeBaseNotification:ProgressHelpTips(event, ...)
			self:CloseTips()

			if event == self.finishCallback then
				self:FinishTutorial()
				return
			elseif event == self.progressRollbackCallback then
				local forceReset
				if not self.isShown then
					local success = self:DeQueueTrigger()
					forceReset = success
				end
				if self.tutorialIndex > 1 or forceReset then -- reset
					self:ResetTutorialFlag()
					self:UpdateProgress()
					self:ReQueueTrigger(event, ...)
					return
				end
			elseif event == self.progressCallback then
				self.tutorialIndex = 2
			end

			self:UpdateProgress(true)
			self:QueueTrigger(event, ...)
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.KnowledgeBaseNotification, KnowledgeBaseNotification)
end

do	-- MenuBarBackpackButton
	local MenuBarBagTemplate = CreateFromMixins(TutorialPrototypeMixin)
	do
		MenuBarBagTemplate.owner = "MenuBarBag"
		MenuBarBagTemplate.closeCallbackName = "ContainerFrame.OnShow"
		MenuBarBagTemplate.callbackTriggerOnly = true
		MenuBarBagTemplate.finishOnShow = true

		function MenuBarBagTemplate:CanTrigger()
			return self:GetTarget():IsShown()
		end

		function MenuBarBagTemplate:GetTarget()
			return MainMenuBarBackpackButton
		end

		function MenuBarBagTemplate:CloseTips(isCallback, bagID)
			if not self.bagID or self.bagID == bagID then
				self.bagID = nil
				HelpTip:Hide(UIParent, self:GetTipText())
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function MenuBarBagTemplate:CheckBag(bagID)
			local slotID, isBugUpdateTrigger
			if bagID then
				isBugUpdateTrigger = true
				slotID = PRIVATE.FindItemInBagIDByItemID(bagID, self.itemID, true)
			else
				bagID, slotID = PRIVATE.FindItemInBagsByItemID(self.itemID, true)
			end

			if slotID then
				local itemID = self.itemID
				self.itemID = nil
				self:UnregisterFrameEventAndCallback("BAG_UPDATE", self)

				local bagButton = PRIVATE.GetMenuBarBagButtonByBagID(bagID)
				if bagButton then
					self.bagID = bagID
					self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
					local success = HelpTip:Show(UIParent, self.helpTipInfo, bagButton)
					if success then
						if isBugUpdateTrigger or not C_TutorialManager.IsOwnerEmpty(self.owner) then
							self:QueueTrigger(itemID)
						else
							self:OnTipShow()
						end
					end
					return success
				else
					self:FinishTutorial()
				end
			end
		end
	end

	local LilyBagAvailable = CreateFromMixins(MenuBarBagTemplate)
	do
		local MIN_LEVEL = 5
		local MAX_LEVEL = 40
		local MOD_LEVEL = 5
		local lilyItemIDs = {
			[131204] = 5, [131208] = 10, [131209] = 15, [131206] = 20,
			[131210] = 25, [131212] = 30, [131214] = 35, [131215] = 40,
		}

		LilyBagAvailable.callbackTriggerOnly = nil
		LilyBagAvailable.finishOnShow = nil

		function LilyBagAvailable:CanInitialize()
			return PRIVATE.GetPlayerLevel() <= MAX_LEVEL
		end

		function LilyBagAvailable:CheckConditions(event)
			local level = PRIVATE.GetPlayerLevel()
			if level >= MAX_LEVEL or level % MOD_LEVEL == 0 or (not event and level >= MIN_LEVEL) then
				local itemID, button, bagID, slotID = self:GetAvailableItemID(level)
				if button and button:IsShown() then
					local containerFrame = _G["ContainerFrame"..(bagID + 1)]
					if containerFrame and not containerFrame:IsShown() then
						return true
					end
				end
			end
		end

		function LilyBagAvailable:GetAvailableItemID(maxLevel)
			for itemID, level in pairs(lilyItemIDs) do
				if level <= maxLevel then
					local button, bagID, slotID = PRIVATE.GetMenuBarBagButtonContainingItemID(itemID)
					if button then
						return itemID, button, bagID, slotID
					end
				end
			end
		end

		function LilyBagAvailable:GetTipText()
			return HELPTIP_LILY_BAG_AVAILABLE
		end

		function LilyBagAvailable:OnInitialize()
			self:RegisterFrameEventAndCallback("PLAYER_LEVEL_UP", self.OnInitCallback, self, "PLAYER_LEVEL_UP")
		end

		function LilyBagAvailable:OnTrigger(event)
			if not self:CheckConditions(event) then
				return
			end

			local shouldFinish
			local level = PRIVATE.GetPlayerLevel()
			if level >= MAX_LEVEL then
				self:UnregisterFrameEventAndCallback("PLAYER_LEVEL_UP", self)
				shouldFinish = true
			end

			self:CloseTips()

			local itemID, button, bagID, slotID = self:GetAvailableItemID(level)
			if button then
				self.bagID = bagID

				local helpTipInfo = self:GenerateHelpTipInfo({
					text = self:GetTipText(),
					textJustifyH = "CENTER",
					buttonStyle = HelpTip.ButtonStyle.Close,
					targetPoint = HelpTip.Point.TopEdgeCenter,
					alignment = HelpTip.Alignment.Left,
					offsetY = 24,
				}, not shouldFinish)

				self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
				local success = HelpTip:Show(UIParent, helpTipInfo, button)
				return success
			end
		end
	end

	local FirstMountLooted = CreateFromMixins(MenuBarBagTemplate)
	do
		function FirstMountLooted:CanInitialize()
			return GetNumCompanions("MOUNT") == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function FirstMountLooted:GetTipText()
			return HELPTIP_MOUNT_IN_BAGS_AVAILABLE
		end

		function FirstMountLooted:OnInitialize()
			self.helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Left,
				offsetY = 24,
			})
			self:RegisterCallback("PlayerLootItem", self.OnInitCallback, self)
		end

		function FirstMountLooted:OnInitCallback(itemID)
			local name = C_MountJournal.GetMountFromItem(itemID)
			if name then
				self:QueueTrigger(itemID)
				return true
			end
		end

		function FirstMountLooted:OnTrigger(itemID)
			self.itemID = itemID
			self:UnregisterCallback("PlayerLootItem", self)
			self:CloseTips()

			local success = self:CheckBag()
			if not success then
				self:RegisterFrameEventAndCallback("BAG_UPDATE", self.CheckBag, self)
			end
			return success
		end
	end

	local FirstPetLooted = CreateFromMixins(MenuBarBagTemplate)
	do
		function FirstPetLooted:CanInitialize()
			return GetNumCompanions("CRITTER") == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function FirstPetLooted:GetTipText()
			return HELPTIP_PET_IN_BAGS_AVAILABLE
		end

		function FirstPetLooted:OnInitialize()
			self.helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Left,
				offsetY = 24,
			})
			self:RegisterCallback("PlayerLootItem", self.OnInitCallback, self)
		end

		function FirstPetLooted:OnInitCallback(itemID)
			local name = C_PetJournal.GetPetInfoByItemID(itemID)
			if name then
				self:QueueTrigger(itemID)
				return true
			end
		end

		function FirstPetLooted:OnTrigger(itemID)
			self.itemID = itemID
			self:UnregisterCallback("PlayerLootItem", self)
			self:CloseTips()

			local success = self:CheckBag()
			if not success then
				self:RegisterFrameEventAndCallback("BAG_UPDATE", self.CheckBag, self)
			end
			return success
		end
	end

	local FirstToyLooted = CreateFromMixins(MenuBarBagTemplate)
	do
		function FirstToyLooted:CanInitialize()
			return C_ToyBox.GetNumLearnedDisplayedToys() == 0 or PRIVATE.GetPlayerLevel() == 1
		end

		function FirstToyLooted:GetTipText()
			return HELPTIP_TOY_IN_BAGS_AVAILABLE
		end

		function FirstToyLooted:OnInitialize()
			self.helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
				alignment = HelpTip.Alignment.Left,
				offsetY = 24,
			})
			self:RegisterCallback("PlayerLootItem", self.OnInitCallback, self)
		end

		function FirstToyLooted:OnInitCallback(itemID)
			local name = C_ToyBox.GetToyInfo(itemID)
			if name then
				self:QueueTrigger(itemID)
				return true
			end
		end

		function FirstToyLooted:OnTrigger(itemID)
			self.itemID = itemID
			self:UnregisterCallback("PlayerLootItem", self)
			self:CloseTips()

			local success = self:CheckBag()
			if not success then
				self:RegisterFrameEventAndCallback("BAG_UPDATE", self.CheckBag, self)
			end
			return success
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.LilyBagAvailable, LilyBagAvailable)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstMountLooted, FirstMountLooted)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstPetLooted, FirstPetLooted)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.FirstToyLooted, FirstToyLooted)
end

do	-- Other
	local QuestMapAvailable = CreateFromMixins(TutorialPrototypeMixin)
	do
		QuestMapAvailable.owner = "QuestLog"
		QuestMapAvailable.closeCallbackName = "QuestLogFrameShowMapButton.OnClick"

		function QuestMapAvailable:CanTrigger()
			return QuestLogFrame:IsShown() and QuestLogFrameShowMapButton:IsVisible() and QuestLogFrameShowMapButton:IsEnabled() == 1
		end

		function QuestMapAvailable:GetTipText()
			return HELPTIP_QUEST_MAP
		end

		function QuestMapAvailable:GetTarget()
			return QuestLogFrameShowMapButton
		end

		function QuestMapAvailable:CloseTips(isCallback)
			HelpTip:Hide(self:GetTarget(), self:GetTipText())
			if isCallback then
				self:FinishTutorial()
			else
				self:UnregisterCallback(self.closeCallbackName, self)
			end
		end

		function QuestMapAvailable:OnInitialize()
			self:RegisterCallback("QuestLogFrameShowMapButton.OnShow", self.OnInitCallback, self)
		end

		function QuestMapAvailable:OnTrigger()
			if not self:CanTrigger() then
				return
			end

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeRight,
				alignment = HelpTip.Alignment.Right,
				offsetX = -32,
				offsetY = 8,
			})

			self:CloseTips()
			self:RegisterCallback(self.closeCallbackName, self.CloseTips, self, true)
			local success = HelpTip:Show(self:GetTarget(), helpTipInfo, self:GetTarget())
			return success
		end
	end

	local RidingSkillAvailable = CreateFromMixins(TutorialPrototypeMixin)
	do
		RidingSkillAvailable.callbackTriggerOnly = true
		RidingSkillAvailable.priority = 500

		function RidingSkillAvailable:GetTipText()
			return HELPTIP_RIDING_SKILL_AVAILABLE
		end

		function RidingSkillAvailable:CloseTips(isCallback, event)
			if event == "QuestLogDetailFrame.OnShow" then
				local selectedQuestID = PRIVATE.GetQuestIDForIndex(GetQuestLogSelection())
				if selectedQuestID ~= self.id then
					return
				end
			end

			self.owner = nil
			HelpTip:Hide(UIParent, self:GetTipText())
			self:UnregisterCallback("MiniMapMailFrame.OnEnter", self)
			self:UnregisterCallback("ContainerFrame.OnShow", self)
			self:UnregisterCallback("QuestLogFrame.OnShow", self)
			self:UnregisterCallback("QuestLogDetailFrame.OnShow", self)
		end

		function RidingSkillAvailable:OnInitialize()
			self.owner = nil
			self:RegisterCallback("RidingSkill.Available", self.OnInitCallback, self)
		end

		function RidingSkillAvailable:OnInitCallback(actionType, id)
			self:UpdateProgress(actionType)
			self:QueueTrigger(actionType, id)
			return true
		end

		function RidingSkillAvailable:GetOwnerByActionType(actionType)
			if actionType == Enum.RadingSkillAvailable.Item then
				return "MenuBarBag"
			elseif actionType == Enum.RadingSkillAvailable.Quest then
				return "MainMenuBar"
			elseif actionType == Enum.RadingSkillAvailable.Mail then
				return "MiniMapFrame"
			end
		end

		function RidingSkillAvailable:UpdateProgress(actionType)
			self.owner = self:GetOwnerByActionType(actionType)
		end

		function RidingSkillAvailable:OnTrigger(actionType, id)
		--	self:UnregisterCallback("RidingSkill.Available", self)

			self:UpdateProgress(actionType)

			if not self.owner then
				GMError(string.format("RidingSkillAvailable unhandled actionType: %s %s", tostring(actionType), tostring(id)))
				return
			end

			if not C_TutorialManager.IsOwnerEmpty(self.owner) then
				self:ReQueueTrigger(actionType, id)
				return
			end

			self:CloseTips()

			self.actionType = actionType
			self.id = id

			local helpTipInfo = self:GenerateHelpTipInfo({
				text = self:GetTipText(),
				textJustifyH = "CENTER",
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			}, true)

			if actionType == Enum.RadingSkillAvailable.Item then
				local button, bagID = PRIVATE.GetMenuBarBagButtonContainingItemID(id)
				if button then
					self.targetFrame = MainMenuBarBackpackButton
					self.bagID = bagID
					helpTipInfo.alignment = HelpTip.Alignment.Left
					helpTipInfo.offsetY = 24
					self:RegisterCallback("ContainerFrame.OnShow", self.CloseTips, self, true, "ContainerFrame.OnShow")
					local success = HelpTip:Show(UIParent, helpTipInfo, button)
					return success
				end
			elseif actionType == Enum.RadingSkillAvailable.Quest then
				C_Timer:After(0.5, function()
					local questIndex = PRIVATE.GetQuestIndexByID(id)
					if questIndex then
						local actionButton = PRIVATE.customActionButtonPool:Acquire()
						actionButton:SetText(SHOW)
						actionButton.onClick = function(thisButton, button)
							QuestLog_OpenToQuest(questIndex, true)
						end

						self.targetFrame = QuestLogMicroButton
						helpTipInfo.alignment = HelpTip.Alignment.Center
						helpTipInfo.appendFrame = actionButton
						helpTipInfo.appendFrameYOffset = -10

						self:RegisterCallback("QuestLogFrame.OnShow", self.CloseTips, self, true, "QuestLogFrame.OnShow")
						self:RegisterCallback("QuestLogDetailFrame.OnShow", self.CloseTips, self, true, "QuestLogDetailFrame.OnShow")
						local success = HelpTip:Show(UIParent, helpTipInfo, self.targetFrame)
						if success then
							self:OnTipShow()
						end
						return success
					end
				end)
			elseif actionType == Enum.RadingSkillAvailable.Mail then
				self.targetFrame = MiniMapMailFrame
				helpTipInfo.targetPoint = HelpTip.Point.LeftEdgeCenter
				helpTipInfo.alignment = HelpTip.Alignment.Right
				self:RegisterCallback("MiniMapMailFrame.OnEnter", self.CloseTips, self, true, "MiniMapMailFrame.OnEnter")
				local success = HelpTip:Show(UIParent, helpTipInfo, self.targetFrame)
				return success
			end
		end
	end

	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Tutorial.QuestMapAvailable, QuestMapAvailable)
	C_TutorialManager.RegisterTutorial(Enum.CustomNPE_Hint.RidingSkillAvailable, RidingSkillAvailable, true)
end