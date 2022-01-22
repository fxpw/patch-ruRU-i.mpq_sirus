-- functions to manage tab interfaces where only one tab of a group may be selected

function PortraitFrameCloseButton_OnClick(self)
	if UIPanelWindows[self:GetParent():GetName()] then
		ToggleFrame(self:GetParent())
	else
		self:GetParent():Hide();
	end
end

-- functions to manage tab interfaces where only one tab of a group may be selected
function PanelTemplates_Tab_OnClick(self, frame)
	PanelTemplates_SetTab(frame, self:GetID())
end

function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

local function GetTabByIndex(frame, index)
	return frame.Tabs and frame.Tabs[index] or _G[frame:GetName().."Tab"..index];
end

function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = GetTabByIndex(frame, i);
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

function PanelTemplates_GetTabWidth(tab)
	local tabName = tab:GetName();

	local sideWidths = 2 * _G[tabName.."Left"]:GetWidth();
	return tab:GetTextWidth() + sideWidths;
end

function PanelTemplates_TabResize(tab, padding, absoluteSize, maxWidth, absoluteTextSize)
	local tabName = tab:GetName();

	local buttonMiddle = tab.Middle or tab.middleTexture or _G[tabName.."Middle"];
	local buttonMiddleDisabled = tab.MiddleDisabled or (tabName and _G[tabName.."MiddleDisabled"]);
	local left = tab.Left or tab.leftTexture or _G[tabName.."Left"];
	local sideWidths = 2 * left:GetWidth();
	local tabText = tab.Text or _G[tab:GetName().."Text"];
	local highlightTexture = tab.HighlightTexture or (tabName and _G[tabName.."HighlightTexture"]);

	local width, tabWidth;
	local textWidth;
	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize;
	else
		tabText:SetWidth(0);
		textWidth = tabText:GetWidth();
	end
	-- If there's an absolute size specified then use it
	if ( absoluteSize ) then
		if ( absoluteSize < sideWidths) then
			width = 1;
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths;
			tabWidth = absoluteSize
		end
		tabText:SetWidth(width);
	else
		-- Otherwise try to use padding
		if ( padding ) then
			width = textWidth + padding;
		else
			width = textWidth + 24;
		end
		-- If greater than the maxWidth then cap it
		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding;
			else
				width = maxWidth + 24;
			end
			tabText:SetWidth(width);
		else
			tabText:SetWidth(0);
		end
		tabWidth = width + sideWidths;
	end

	if ( buttonMiddle ) then
		buttonMiddle:SetWidth(width);
	end
	if ( buttonMiddleDisabled ) then
		buttonMiddleDisabled:SetWidth(width);
	end

	tab:SetWidth(tabWidth);

	if ( highlightTexture ) then
		highlightTexture:SetWidth(tabWidth);
	end
end

function PanelTemplates_ResizeTabsToFit(frame, maxWidthForAllTabs)
	local selectedIndex = PanelTemplates_GetSelectedTab(frame);
	if ( not selectedIndex ) then
		return;
	end

	local currentWidth = 0;
	local truncatedText = false;
	for i = 1, frame.numTabs do
		local tab = GetTabByIndex(frame, i);
		currentWidth = currentWidth + tab:GetWidth();
	end
	if ( not truncatedText and currentWidth <= maxWidthForAllTabs ) then
		return;
	end

	local currentTab = GetTabByIndex(frame, selectedIndex);
	PanelTemplates_TabResize(currentTab, 0);
	local availableWidth = maxWidthForAllTabs - currentTab:GetWidth();
	local widthPerTab = availableWidth / (frame.numTabs - 1);
	for i = 1, frame.numTabs do
		if ( i ~= selectedIndex ) then
			local tab = GetTabByIndex(frame, i);
			PanelTemplates_TabResize(tab, 0, widthPerTab);
		end
	end
end

function PanelTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function PanelTemplates_DisableTab(frame, index)
	GetTabByIndex(frame, index).isDisabled = 1;
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_EnableTab(frame, index)
	local tab = GetTabByIndex(frame, index);
	tab.isDisabled = nil;
	-- Reset text color
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	PanelTemplates_UpdateTabs(frame);
end

function PanelTemplates_HideTab(frame, index)
	local tab = GetTabByIndex(frame, index);
	tab:Hide();
end

function PanelTemplates_ShowTab(frame, index)
	local tab = GetTabByIndex(frame, index);
	tab:Show();
end

function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();

	local left = tab.Left or _G[name.."Left"];
	local middle = tab.Middle or _G[name.."Middle"];
	local right = tab.Right or _G[name.."Right"];
	left:Show();
	middle:Show();
	right:Show();
	--tab:UnlockHighlight();
	tab:Enable();
	local text = tab.Text or _G[name.."Text"];
	text:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2));

	local leftDisabled = tab.LeftDisabled or _G[name.."LeftDisabled"];
	local middleDisabled = tab.MiddleDisabled or _G[name.."MiddleDisabled"];
	local rightDisabled = tab.RightDisabled or _G[name.."RightDisabled"];
	leftDisabled:Hide();
	middleDisabled:Hide();
	rightDisabled:Hide();
end

function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();

	local left = tab.Left or _G[name.."Left"];
	local middle = tab.Middle or _G[name.."Middle"];
	local right = tab.Right or _G[name.."Right"];
	left:Hide();
	middle:Hide();
	right:Hide();
	--tab:LockHighlight();
	tab:Disable();
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	local text = tab.Text or _G[name.."Text"];
	text:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), (tab.selectedTextY or -3));

	local leftDisabled = tab.LeftDisabled or _G[name.."LeftDisabled"];
	local middleDisabled = tab.MiddleDisabled or _G[name.."MiddleDisabled"];
	local rightDisabled = tab.RightDisabled or _G[name.."RightDisabled"];
	leftDisabled:Show();
	middleDisabled:Show();
	rightDisabled:Show();
end

function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	local left = tab.Left or _G[name.."Left"];
	local middle = tab.Middle or _G[name.."Middle"];
	local right = tab.Right or _G[name.."Right"];
	left:Show();
	middle:Show();
	right:Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledFontObject(GameFontDisableSmall);
	local leftDisabled = tab.LeftDisabled or _G[name.."LeftDisabled"];
	local middleDisabled = tab.MiddleDisabled or _G[name.."MiddleDisabled"];
	local rightDisabled = tab.RightDisabled or _G[name.."RightDisabled"];
	leftDisabled:Hide();
	middleDisabled:Hide();
	rightDisabled:Hide();
end

function EditBox_HandleTabbing(self, tabList)
	local editboxName = self:GetName();
	local index;
	for i=1, #tabList do
		if ( editboxName == tabList[i] ) then
			index = i;
			break;
		end
	end
	if ( IsShiftKeyDown() ) then
		index = index - 1;
	else
		index = index + 1;
	end

	if ( index == 0 ) then
		index = #tabList;
	elseif ( index > #tabList ) then
		index = 1;
	end

	local target = tabList[index];
	_G[target]:SetFocus();
end

function EditBox_OnTabPressed(self)
	if ( self.previousEditBox and IsShiftKeyDown() ) then
		self.previousEditBox:SetFocus();
	elseif ( self.nextEditBox ) then
		self.nextEditBox:SetFocus();
	end
end

function EditBox_ClearFocus (self)
	self:ClearFocus();
end

function EditBox_SetFocus (self)
	self:SetFocus();
end

function EditBox_HighlightText (self)
	self:HighlightText();
end

function EditBox_ClearHighlight (self)
	self:HighlightText(0, 0);
end

UIFrameCache = CreateFrame("FRAME");
local caches = {};
function UIFrameCache:New (frameType, baseName, parent, template)
	if ( self ~= UIFrameCache ) then
		error("Attempt to run factory method on class member");
	end

	local frameCache = {};

	setmetatable(frameCache, self);
	self.__index = self;

	frameCache.frameType = frameType;
	frameCache.baseName = baseName;
	frameCache.parent = parent;
	frameCache.template = template;
	frameCache.frames = {};
	frameCache.usedFrames = {};
	frameCache.numFrames = 0;

	tinsert(caches, frameCache);

	return frameCache;
end

function UIFrameCache:GetFrame ()
	local frame = self.frames[1];
	if ( frame ) then
		tremove(self.frames, 1);
		tinsert(self.usedFrames, frame);
		return frame;
	end

	frame = CreateFrame(self.frameType, self.baseName .. self.numFrames + 1, self.parent, self.template);
	frame.frameCache = self;
	self.numFrames = self.numFrames + 1;
	tinsert(self.usedFrames, frame);
	return frame;
end

function UIFrameCache:ReleaseFrame (frame)
	for k, v in next, self.frames do
		if ( v == frame ) then
			return;
		end
	end

	for k, v in next, self.usedFrames do
		if ( v == frame ) then
			tinsert(self.frames, frame);
			tremove(self.usedFrames, k);
			break;
		end
	end
end

-- positionFunc = Callback to determine the visible buttons.
--		arguments: scroll value
--		must return: index of the topmost visible button (or nil if there are no buttons)
--					 the total height used by all buttons prior to topmost
--					 the total height of all the buttons
-- buttonFunc = Callback to configure each button
--		arguments: button, button index, first button
--			NOTE: first button is true if this is the first button in a rendering pass. For scrolling optimization, positionFunc may be called without subsequent calls to buttonFunc.
--		must return: height of button
function DynamicScrollFrame_CreateButtons(self, buttonTemplate, minButtonHeight, buttonFunc, positionFunc)
	if ( self.buttons ) then
		return;
	end

	local scrollChild = self.scrollChild;
	local scrollHeight = self:GetHeight();
	local buttonName = self:GetName().."Button";
	local buttons = { };
	local numButtons;

	local button = CreateFrame("BUTTON", buttonName.."1", scrollChild, buttonTemplate);
	button:SetPoint("TOPLEFT", 0, 0);
	tinsert(buttons, button);
	numButtons = math.ceil(scrollHeight / minButtonHeight) + 3;
	for i = 2, numButtons do
		button = CreateFrame("BUTTON", buttonName..i, scrollChild, buttonTemplate);
		button:SetPoint("TOPLEFT", buttons[i-1], "BOTTOMLEFT", 0, 0);
		tinsert(buttons, button);
	end
	self.buttons = buttons;
	self.numButtons = numButtons;
	self.usedButtons = 0;
	self.buttonFunc = buttonFunc;
	self.positionFunc = positionFunc;
	self.scrollHeight = scrollHeight;
	-- optimization vars
	self.lastOffset = -1;
	self.topIndex = -1;
	self.nextButtonOffset = -1;
end

function DynamicScrollFrame_OnVerticalScroll(self, offset)
	offset = math.floor(offset + 0.5);
	if ( offset ~= self.lastOffset ) then
		local scrollBar = self.scrollBar;
		local min, max = scrollBar:GetMinMaxValues();
		scrollBar:SetValue(offset);
		if ( offset == 0 ) then
			_G[scrollBar:GetName().."ScrollUpButton"]:Disable();
		else
			_G[scrollBar:GetName().."ScrollUpButton"]:Enable();
		end
		if ( offset == math.floor(max + 0.5) ) then
			_G[scrollBar:GetName().."ScrollDownButton"]:Disable();
		else
			_G[scrollBar:GetName().."ScrollDownButton"]:Enable();
		end
		self.lastOffset = offset;
		DynamicScrollFrame_Update(self, offset, true);
	end
end

function DynamicScrollFrame_Update(self, scrollValue, isScrollUpdate)
	if ( not self.positionFunc ) then
		return;
	end
	if ( not scrollValue ) then
		scrollValue = floor(self.scrollBar:GetValue() + 0.5);
	end
	local buttonIndex = 0;
	local buttons = self.buttons;
	local topIndex, heightUsed, totalHeight = self.positionFunc(scrollValue);
	if ( topIndex ) then
		if ( isScrollUpdate and self.topIndex == topIndex and ( self.nextButtonOffset == 0 or scrollValue < self.nextButtonOffset ) ) then
			return;
		end
		self.allowedRange = totalHeight - self.scrollHeight;		-- temp fix to jitter scroll (see task 39261)
		self.topIndex = topIndex;
		local button;
		local buttonFunc = self.buttonFunc;
		local buttonHeight;
		local visibleRange = scrollValue + self.scrollHeight;
		if ( topIndex > 1 ) then
			buttons[1]:SetHeight(heightUsed);
			buttons[1]:Show();
			buttonIndex = 1;
		end
		for dataIndex = topIndex, topIndex + self.numButtons - 1 do
			buttonIndex = buttonIndex + 1;
			button = buttons[buttonIndex];
			buttonHeight = buttonFunc(button, dataIndex, (dataIndex == topIndex));
			button:SetHeight(buttonHeight);
			heightUsed = heightUsed + buttonHeight;
			if ( heightUsed >= totalHeight ) then
				self.nextButtonOffset = 0;
				break;
			elseif ( heightUsed >= visibleRange ) then
				buttonIndex = buttonIndex + 1;
				button = buttons[buttonIndex];
				button:SetHeight(totalHeight - heightUsed);
				button:Show();
				self.nextButtonOffset = floor(scrollValue + heightUsed - visibleRange);
				break;
			end
		end
	end
	for i = buttonIndex + 1, self.numButtons do
		buttons[i]:Hide();
	end
	self.usedButtons = buttonIndex;
end

function DynamicScrollFrame_UnlockAllHighlights(self)
	local buttons = self.buttons;
	for i = 1, self.usedButtons do
		buttons[i]:UnlockHighlight();
	end
end

function UIPanelCloseButton_OnClick(self)
	local parent = self:GetParent();
	if parent then
		if parent.onCloseCallback then
			parent.onCloseCallback(self);
		else
			HideUIPanel(parent);
		end
	end
end

ButtonWithDisableMixin = {};

function ButtonWithDisableMixin:SetDisableTooltip(tooltipTitle, tooltipText)
	self.disableTooltipTitle = tooltipTitle;
	self.disableTooltipText = tooltipText;
	self:SetEnabled(tooltipTitle == nil);
end

function ButtonWithDisableMixin:OnEnter()
	if self.disableTooltipTitle and self:IsEnabled() == 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local wrap = true;
		GameTooltip_SetTitle(GameTooltip, self.disableTooltipTitle, RED_FONT_COLOR, wrap);

		if self.disableTooltipText then
			GameTooltip_AddNormalLine(GameTooltip, self.disableTooltipText, wrap);
		end

		GameTooltip:Show();
	end
end