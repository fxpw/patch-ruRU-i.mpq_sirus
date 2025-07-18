ObjectiveTrackerManager = {
	containers = { },
	moduleToContainerMap = { },
	backgroundAlpha = 0,
};

function ObjectiveTrackerManager:AssignModulesOrder(modules)
	for i, module in ipairs(modules) do
		module.uiOrder = i;
	end
end

function ObjectiveTrackerManager:AddContainer(container)
	self.containers[container] = true;
	-- pass current alpha to new container
	container:OnAdded(self.backgroundAlpha);
end

function ObjectiveTrackerManager:UpdateAll()
	for container in pairs(self.containers) do
		container:Update();
	end
end

function ObjectiveTrackerManager:UpdateModule(module)
	-- check that module is assigned
	local container = self:GetContainerForModule(module);
	if container then
		module:MarkDirty();
	end
end

function ObjectiveTrackerManager:GetContainerForModule(module)
	return self.moduleToContainerMap[module];
end

function ObjectiveTrackerManager:SetModuleContainer(module, container)
	if not self.containers[container] then
		return;
	end

	local oldContainer = self:GetContainerForModule(module);
	if oldContainer then
		oldContainer:RemoveModule(module);
	end
	self.moduleToContainerMap[module] = container;
	container:AddModule(module);
end

function ObjectiveTrackerManager:AcquireFrame(parent, template, templateType)
	if not self.poolCollection then
		self.poolCollection = CreateFramePoolCollection();
	end

	if not templateType then
		templateType = "Frame";
	end

	local pool = self.poolCollection:GetOrCreatePool(templateType, parent, template);
	local frame, isNew = pool:Acquire(template);
	if isNew then
		frame.template = template; -- stored so we can use it to free from the lookup later
	end
	return frame, isNew;
end

function ObjectiveTrackerManager:ReleaseFrame(frame)
	self.poolCollection:Release(frame);
end

function ObjectiveTrackerManager:ToggleDropDown(module, frame, handlerFunc)
	local dropDown = ObjectiveTrackerBlockDropDown;
	if not dropDown.initialize then
		UIDropDownMenu_Initialize(dropDown, nil, "MENU");
	end

	local container = self:GetContainerForModule(module);
	dropDown:SetParent(container);

	dropDown.initialize = handlerFunc;
	ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function ObjectiveTrackerManager:SetOpacity(opacity)
	self.backgroundAlpha = (opacity or 0) / 100;
	for container in pairs(self.containers) do
		container:SetBackgroundAlpha(self.backgroundAlpha);
	end
end

local minLineFontSize = 12;
local maxLineFontSize = 20;
local headerExtraSize = 2;

function ObjectiveTrackerManager:SetTextSize(textSize)
	if textSize < minLineFontSize or textSize > maxLineFontSize then
		return;
	end

	local lineFont = "ObjectiveTrackerFont"..textSize;
	local headerFont = "ObjectiveTrackerFont"..(textSize + headerExtraSize);
	ObjectiveTrackerLineFont:SetFontObject(lineFont);
	ObjectiveTrackerHeaderFont:SetFontObject(headerFont);
	self:UpdateAll();
end

-- questPOI cvar

function ObjectiveTrackerManager:UpdatePOIEnabled(enabled)
	self.questPOIEnabled = enabled;
	for module in pairs(self.questPOIEnabledModules) do
		module:MarkDirty();
	end
end

function ObjectiveTrackerManager:OnVariablesLoaded(...)
	local enabled = GetCVarBool("questPOI");
	if self.questPOIEnabled ~= enabled then
		self:UpdatePOIEnabled(enabled);
	end
end

function ObjectiveTrackerManager:CanShowPOIs(module)
	if self.questPOIEnabled == nil then
		self.questPOIEnabled = GetCVarBool("questPOI");
		self.questPOIEnabledModules = {};
		EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", self.OnVariablesLoaded, self);
		EventRegistry:RegisterFrameEventAndCallback("CVAR_UPDATE", self.OnVariablesLoaded, self);
	end

	if not self.questPOIEnabledModules[module] then
		self.questPOIEnabledModules[module] = true;
	end

	return self.questPOIEnabled;
end

function ObjectiveTrackerManager:EnumerateActiveBlocksByTag(tag, callback)
	local ContainerEnumerateActiveModuleBlocksByTag = function(module)
		if module:MatchesTag(tag) then
			module:EnumerateActiveBlocks(callback);
		end
	end

	for container in pairs(self.containers) do
		container:ForEachModule(ContainerEnumerateActiveModuleBlocksByTag);
	end
end

function ObjectiveTrackerManager:OnPlayerEnteringWorld(isInitialLogin, isReloadingUI)
	if not isInitialLogin and not isReloadingUI then
		return;
	end

	local orderedModules = {
		QuestObjectiveTracker,
		AchievementObjectiveTracker,
		BattlePassQuestTracker,
		ProfessionsRecipeTracker,
	};

	self:AssignModulesOrder(orderedModules);
	local mainTrackerFrame = ObjectiveTrackerFrame;
	self:AddContainer(mainTrackerFrame);
	for i, module in ipairs(orderedModules) do
		self:SetModuleContainer(module, mainTrackerFrame);
	end
end

EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED_INFO", ObjectiveTrackerManager.OnPlayerEnteringWorld, ObjectiveTrackerManager);
