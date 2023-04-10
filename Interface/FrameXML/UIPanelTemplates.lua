-- functions to manage tab interfaces where only one tab of a group may be selected

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

-- SquareButton template code
SQUARE_BUTTON_TEXCOORDS = {
	["UP"] = {     0.45312500,    0.64062500,     0.01562500,     0.20312500};
	["DOWN"] = {   0.45312500,    0.64062500,     0.20312500,     0.01562500};
	["LEFT"] = {   0.23437500,    0.42187500,     0.01562500,     0.20312500};
	["RIGHT"] = {  0.42187500,    0.23437500,     0.01562500,     0.20312500};
	["DELETE"] = { 0.01562500,    0.20312500,     0.01562500,     0.20312500};
};

function SquareButton_SetIcon(self, name)
	local coords = SQUARE_BUTTON_TEXCOORDS[strupper(name)];
	if coords then
		self.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
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

--Inline hyperlinks
function InlineHyperlinkFrame_OnEnter(self, _, link)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip:SetHyperlink(link);
end

function InlineHyperlinkFrame_OnLeave(self)
	GameTooltip:Hide();
end

function InlineHyperlinkFrame_OnClick(self, link, text, button)
	if ( self.hasIconHyperlinks ) then
		local fixedLink;
		local _, _, linkType, linkID = string.find(link, "([%a]+):([%d]+)");
		if ( linkType == "currency" ) then
			fixedLink = GetCurrencyLink(linkID);
		end

		if ( fixedLink ) then
			HandleModifiedItemClick(fixedLink);
			return;
		end
	end
	SetItemRef(link, text, button);
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

CurrencyHorizontalLayoutFrameMixin = {};

function CurrencyHorizontalLayoutFrameMixin:OnLoad()
	self.currencySpacing = self:GetAttribute("currencySpacing");
	self.quantitySpacing = self:GetAttribute("quantitySpacing");
	self.fixedHeight = self:GetAttribute("fixedHeight");
	self.spacing = self:GetAttribute("spacing");
	self.expand = self:GetAttribute("expand");
end

function CurrencyHorizontalLayoutFrameMixin:Clear()
	if self.quantityPool then
		self.quantityPool:ReleaseAll();
	end
	if self.iconPool then
		self.iconPool:ReleaseAll();
	end
	self.nextLayoutIndex = nil;
end

function CurrencyHorizontalLayoutFrameMixin:AddToLayout(region)
	if not self.nextLayoutIndex then
		self.nextLayoutIndex = 1;
	end
	region.layoutIndex = self.nextLayoutIndex;
	self.nextLayoutIndex = self.nextLayoutIndex + 1;
	region:Show();
	self:MarkDirty();
end

function CurrencyHorizontalLayoutFrameMixin:GetQuantityFontString()
	if not self.quantityPool then
		self.quantityPool = CreateFontStringPool(self, "ARTWORK", 0, (self.quantityFontObject or "GameFontHighlight"));
	end
	local fontString = self.quantityPool:Acquire();
	self:AddToLayout(fontString);
	return fontString;
end

function CurrencyHorizontalLayoutFrameMixin:GetIconFrame()
	if not self.iconPool then
		self.iconPool = CreateFramePool("Frame", self, "CurrencyLayoutFrameIconTemplate");
	end
	local frame = self.iconPool:Acquire();
	self:AddToLayout(frame);
	return frame;
end

function CurrencyHorizontalLayoutFrameMixin:CreateLabel(text, color, fontObject, spacing)
	if self.Label then
		return;
	end

	local label = self:CreateFontString(nil, "ARTWORK", fontObject or "GameFontHighlight");
	self.Label = label;
	label.layoutIndex = 0;
	label.rightPadding = spacing;
	label:SetHeight(self.fixedHeight);
	label:SetText(text);
	color = color or HIGHLIGHT_FONT_COLOR;
	label:SetTextColor(color:GetRGB());
	self:MarkDirty();
end

function CurrencyHorizontalLayoutFrameMixin:AddCurrency(currencyType, currencyID, overrideAmount, color)
	local _, itemIcon;
	if currencyType == "money" then
		itemIcon = [[Interface\MoneyFrame\UI-MoneyIcons]];
	else
		_, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(currencyID);
	end

	local amountString;
	if overrideAmount then
		amountString = overrideAmount;
	else
		if currencyType == "money" then
			amountString = floor(GetMoney() / (COPPER_PER_SILVER * SILVER_PER_GOLD));
		elseif currencyType == "currency" then
			amountString = GetCurrencyCount(currencyID);
		elseif currencyType == "item" then
			amountString = GetItemCount(currencyID)
		end
	end

	if itemIcon then
		local height = self.fixedHeight;
		-- quantity
		local fontString = self:GetQuantityFontString();
		fontString:SetHeight(height);
		fontString:SetText(amountString);
		color = color or HIGHLIGHT_FONT_COLOR;
		fontString:SetTextColor(color:GetRGB());
		-- icon
		local frame = self:GetIconFrame();
		frame:SetSize(height, height);
		frame.Icon:SetTexture(itemIcon);
		if currencyType == "money" then
			frame.Icon:SetTexCoord(0, 0.25, 0, 1);
		else
			frame.Icon:SetTexCoord(0, 1, 0, 1);
		end
		frame.id = currencyID;
		frame.type = currencyType;
		-- spacing
		fontString.rightPadding = self.quantitySpacing;
		if fontString.layoutIndex > 1  then
			fontString.leftPadding = self.currencySpacing;
		end
	end
end