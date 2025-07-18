local settings = {
	-- KeyValues
	-- topModulePadding (0)		: padding between top of the container and the first module, affects contents height
	-- bottomModulePadding (10)	: spacing between last module and the background
	-- moduleSpacing (10)	: spacing between modules
	-- headerText ("")		: text for container's header, if it has one

	-- dynamic
	isCollapsed = false,	-- whether the container is collapsed, not showing any modules
	needsSorting = false,	-- will be set to true whenever a module is added or removed
	init = false,			-- when a container is first added, it will run Init()
	isForceCollapsed = false
};

ObjectiveTrackerContainerMixin = CreateFromMixins(DirtiableMixin, settings);

function ObjectiveTrackerContainerMixin:OnSizeChanged()
	RunNextFrame(function()
		self:Update()
	end)
end

function ObjectiveTrackerContainerMixin:OnShow()
	self:UpdateHeight();
end

function ObjectiveTrackerContainerMixin:OnAdded(backgroundAlpha)
	if not self.init then
		self.init = true;
		self:Init();

		if self.collapseType and GetCVarBitfield("objectiveTrackerCollapsedState", self.collapseType) then
			self:SetCollapsedForce(true)
		end
	end
	self:SetBackgroundAlpha(backgroundAlpha);
end

function ObjectiveTrackerContainerMixin:Init()
	if self.Header then
		self.Header.Text:SetText(self.headerText);
	end
end

function ObjectiveTrackerContainerMixin:GetAvailableHeight()
	if self.ScrollFrame then
		return 100000
	end
	return self:GetHeight() - self.topModulePadding;
end

function ObjectiveTrackerContainerMixin:Update(dirtyUpdate)
	if not self.modules then
		return;
	end

	if self.needsSorting then
		table.sort(self.modules, function(lhs, rhs)
			return lhs.uiOrder < rhs.uiOrder;
		end);
		self.needsSorting = false;
	end

	local prevModule = nil;
	local availableHeight = self:GetAvailableHeight();
	local contentsHeight = 0;

	-- first update the modules with priority
	for i, module in ipairs(self.modules) do
		if module.hasDisplayPriority then
			local heightUsed, isTruncated = module:Update(availableHeight, dirtyUpdate);
			if isTruncated then
				availableHeight = 0;
			elseif heightUsed > 0 then
				availableHeight = availableHeight - heightUsed;
			end
		end
	end

	for i, module in ipairs(self.modules) do
		if not module.hasDisplayPriority then
			module:Update(availableHeight, dirtyUpdate);
		end
		local heightUsed = module:GetContentsHeight();
		if heightUsed > 0 then
			if not module.hasDisplayPriority then
				availableHeight = availableHeight - heightUsed;
			end
			module:ClearAllPoints();
			if prevModule then
				module:SetPoint("TOP", prevModule, "BOTTOM", 0, -self.moduleSpacing);
				module:SetPoint("LEFT", self.ScrollFrame.ScrollChild, "LEFT", self.leftPadding + module.leftMargin, 0);
				contentsHeight = contentsHeight + heightUsed + self.moduleSpacing;
			else
				module:SetPoint("TOP", 0, 0);
				module:SetPoint("LEFT", self.ScrollFrame.ScrollChild, "LEFT", self.leftPadding + module.leftMargin, 0);
				contentsHeight = contentsHeight + heightUsed;
			end
			prevModule = module;
		end
		if module:IsTruncated() then
			availableHeight = 0;
		end
	end

	if self:IsCollapsed() then
		if not prevModule and self.collapseType then
			if self.isForceCollapsed then
				SetCVarBitfield("objectiveTrackerCollapsedState", self.collapseType, false)
			end
			self:SetCollapsedForce(false)
		else
			contentsHeight = 0
			ScrollFrame_OnScrollRangeChanged(self.ScrollFrame, 0, 0)
		end
	end

	self.ScrollFrame.ScrollChild:SetSize(self.ScrollFrame:GetWidth(), contentsHeight)
	self.ScrollFrame:UpdateScrollChildRect()

	if prevModule then
		if contentsHeight == 0 then
			self.NineSlice:SetPoint("BOTTOM", self.Header, "BOTTOM", 0, 1)
		elseif contentsHeight > self.ScrollFrame:GetHeight() then
			self.NineSlice:SetPoint("BOTTOM", self, "BOTTOM", 0, -(self.bottomModulePadding + 6))
		else
			self.NineSlice:SetPoint("BOTTOM", prevModule, "BOTTOM", 0, -(self.bottomModulePadding + 6))
		end
		self.NineSlice:Show();
		local wasShown = self.Header:IsShown();
		self:Show();
	else
		self:Hide();
	end

	if not self:IsUserPlaced() then
		UIParent_ManageFramePositions();
	end
end

function ObjectiveTrackerContainerMixin:AddModule(module)
	-- init on first module added
	if not self.modules then
		self.modules = { };
		local dirtyUpdate = true;
		self:SetDirtyMethod(GenerateClosure(self.Update, self, dirtyUpdate));
	end

	if self:HasModule(module) then
		return;
	end

	table.insert(self.modules, module);
	self.needsSorting = true;
	module:SetContainer(self);
	self:MarkDirty();
end

function ObjectiveTrackerContainerMixin:RemoveModule(module)
	if self:HasModule(module) then
		tDeleteItem(self.modules, module);
		self.needsSorting = true;
		self:MarkDirty();
	end
end

function ObjectiveTrackerContainerMixin:HasModule(module)
	return tContains(self.modules, module);
end

function ObjectiveTrackerContainerMixin:GetHeightToModule(targetModule)
	if not self:HasModule(targetModule) then
		return 0;
	end

	local height = self.topModulePadding;

	for i, module in ipairs(self.modules) do
		if module == targetModule then
			break;
		end
		local moduleHeight = module:GetContentsHeight();
		if moduleHeight > 0 and height > 0 then
			height = height + self.moduleSpacing;
		end
		height = height + moduleHeight;
	end

	return height;
end

function ObjectiveTrackerContainerMixin:SetBackgroundAlpha(alpha)
	self.NineSlice:SetAlpha(alpha);
end

function ObjectiveTrackerContainerMixin:ToggleCollapsed()
	return self:SetCollapsed(not self:IsCollapsed());
end

function ObjectiveTrackerContainerMixin:SetCollapsed(collapsed)
	self.isCollapsed = collapsed;
	-- update the header
	self.Header:SetCollapsed(collapsed);
	self:Update();
	return collapsed
end

function ObjectiveTrackerContainerMixin:SetCollapsedForce(collapsed)
	self.isCollapsed = collapsed
	-- update the header
	self.Header:SetCollapsed(collapsed)
	self.isForceCollapsed = collapsed
end

function ObjectiveTrackerContainerMixin:IsCollapsed()
	return self.isCollapsed;
end

function ObjectiveTrackerContainerMixin:UpdateHeight()
	if self:IsUserPlaced() then
		local height = 0;
		if self.modules then
			for i, module in ipairs(self.modules) do
				if module.mustFit then
					height = height + module:GetContentsHeight();
				end
			end
		end

		local newHeight = math.max(self.editModeHeight or 800, height);
		self:SetHeight(newHeight);
		return;
	end

	local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(1);
	if offsetY then
		local parentHeight = self:GetParent():GetHeight();
		local setHeight = parentHeight + offsetY;
		setHeight = math.max(setHeight, 20);
		self:SetHeight(setHeight);
	end
end

function ObjectiveTrackerContainerMixin:ForceExpand()
	if self:IsCollapsed() then
		self:ToggleCollapsed();
	else
		-- One of its modules may be requesting this as a result of the module's own ForceExpand
		-- function. If the tracker is already expanded, it needs an immediate update so the module
		-- has the correct layout.
		self:Update();
	end
end

function ObjectiveTrackerContainerMixin:ForEachModule(callback)
	for i, module in ipairs(self.modules) do
		callback(module);
	end
end

-- *****************************************************************************************************
-- ***** HEADER
-- *****************************************************************************************************

ObjectiveTrackerContainerHeaderMixin = {};

function ObjectiveTrackerContainerHeaderMixin:OnLoad()
	self.Background:SetAtlas("UI-QuestTracker-Primary-Objective-Header", true)

	self.MinimizeButton:SetScript("OnClick", GenerateClosure(self.OnToggle, self));
	local collapsed = false;
	self:SetCollapsed(collapsed);
end

function ObjectiveTrackerContainerHeaderMixin:OnToggle()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	-- container is in charge of state
	local container = self:GetParent();
	local collapsed = container:ToggleCollapsed();
	if container.collapseType then
		SetCVarBitfield("objectiveTrackerCollapsedState", container.collapseType, collapsed)
	end
end

function ObjectiveTrackerContainerHeaderMixin:SetCollapsed(collapsed)
	local normalTexture = self.MinimizeButton:GetNormalTexture();
	local pushedTexture = self.MinimizeButton:GetPushedTexture();

	if collapsed then
		normalTexture:SetAtlas("UI-QuestTrackerButton-Expand-All", true);
		pushedTexture:SetAtlas("UI-QuestTrackerButton-Expand-All-Pressed", true);
	else
		normalTexture:SetAtlas("UI-QuestTrackerButton-Collapse-All", true);
		pushedTexture:SetAtlas("UI-QuestTrackerButton-Collapse-All-Pressed", true);
	end
end
