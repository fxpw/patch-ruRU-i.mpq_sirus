GLUEDARK_DROPDOWNMENU_MAXLEVELS = 3;
GLUEDARK_DROPDOWNMENU_BUTTON_HEIGHT = 17;
GLUEDARK_DROPDOWNMENU_BORDER_HEIGHT = 6;
-- The current open menu
GLUEDARK_DROPDOWNMENU_OPEN_MENU = nil;
-- The current menu being initialized
GLUEDARK_DROPDOWNMENU_INIT_MENU = nil;
-- Current level shown of the open menu
GLUEDARK_DROPDOWNMENU_MENU_LEVEL = 1;
-- Current value of the open menu
GLUEDARK_DROPDOWNMENU_MENU_VALUE = nil;
-- Time to wait to hide the menu
GLUEDARK_DROPDOWNMENU_SHOW_TIME = 2;

function GlueDark_DropDownMenu_Initialize(frame, initFunction, displayMode, level)
	if ( frame:GetName() ~= GLUEDARK_DROPDOWNMENU_OPEN_MENU ) then
		GLUEDARK_DROPDOWNMENU_MENU_LEVEL = 1;
	end

	-- Set the frame that's being intialized
	GLUEDARK_DROPDOWNMENU_INIT_MENU = frame:GetName();

	-- Hide all the buttons
	local button, dropDownList;
	for i = 1, GLUEDARK_DROPDOWNMENU_MAXLEVELS, 1 do
		dropDownList = _G["GlueDark_DropDownList"..i];
		if ( i >= GLUEDARK_DROPDOWNMENU_MENU_LEVEL or frame:GetName() ~= GLUEDARK_DROPDOWNMENU_OPEN_MENU ) then
			dropDownList.numButtons = 0;
			dropDownList.maxWidth = 0;
			for j=1, dropDownList.maxButtons, 1 do
				button = _G["GlueDark_DropDownList"..i.."Button"..j];
				button:Hide();
			end
		end
	end
	frame:SetHeight(GLUEDARK_DROPDOWNMENU_BUTTON_HEIGHT * 2);

	-- Set the initialize function and call it. The initFunction populates the dropdown list.
	if ( initFunction ) then
		frame.initialize = initFunction;
		initFunction(frame, level);
	end

	-- Change appearance based on the displayMode
	if ( displayMode == "MENU" ) then
		frame.Left:Hide()
		frame.Middle:Hide()
		frame.Right:Hide()
		frame.Button:ClearAllPoints()
		frame.Button:SetPoint("LEFT", frame.Text, "LEFT", -9, 0)
		frame.Button:SetPoint("RIGHT", frame.Text, "RIGHT", 6, 0)
		frame.displayMode = "MENU";
	end
end

-- If dropdown is visible then see if its timer has expired, if so hide the frame
function GlueDark_DropDownMenu_OnUpdate(self, elapsed)
	if ( not self.showTimer or not self.isCounting ) then
		return;
	elseif ( self.showTimer < 0 ) then
		self:Hide();
		self.showTimer = nil;
		self.isCounting = nil;
	else
		self.showTimer = self.showTimer - elapsed;
	end
end

-- Start the countdown on a frame
function GlueDark_DropDownMenu_StartCounting(frame)
	if ( frame.parent ) then
		GlueDark_DropDownMenu_StartCounting(frame.parent);
	else
		frame.showTimer = GLUEDARK_DROPDOWNMENU_SHOW_TIME;
		frame.isCounting = 1;
	end
end

-- Stop the countdown on a frame
function GlueDark_DropDownMenu_StopCounting(frame)
	if ( frame.parent ) then
		GlueDark_DropDownMenu_StopCounting(frame.parent);
	else
		frame.isCounting = nil;
	end
end

--[[
List of button attributes
======================================================
info.text = [STRING]				-- The text of the button
info.value = [ANYTHING]				-- The value that GLUEDARK_DROPDOWNMENU_MENU_VALUE is set to when the button is clicked
info.func = [function()]			-- The function that is called when you click the button
info.checked = [nil, 1]				-- Check the button
info.isTitle = [nil, 1]				-- If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, 1]			-- Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.hasArrow = [nil, 1]			-- Show the expand arrow for multilevel menus
info.hasColorSwatch = [nil, 1]		-- Show color swatch or not, for color selection
info.r = [1 - 255]					-- Red color value of the color swatch
info.g = [1 - 255]					-- Green color value of the color swatch
info.b = [1 - 255]					-- Blue color value of the color swatch
info.colorCode = [STRING]			-- "|cAARRGGBB" embedded hex value of the button text color. Only used when button is enabled
info.swatchFunc = [function()]		-- Function called by the color picker on color change
info.hasOpacity = [nil, 1]			-- Show the opacity slider on the colorpicker frame
info.opacity = [0.0 - 1.0]			-- Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
info.opacityFunc = [function()] 	-- Function called by the opacity slider when you change its value
info.cancelFunc = [function(previousValues)]	-- Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
info.notClickable = [nil, 1]		-- Disable the button and color the font white
info.notCheckable = [nil, 1]		-- Shrink the size of the buttons and don't display a check box
info.owner = [Frame]				-- Dropdown frame that "owns" the current dropdownlist
info.keepShownOnClick = [nil, 1]	-- Don't hide the dropdownlist after a button is clicked
info.tooltipTitle = [nil, STRING]	-- Title of the tooltip shown on mouseover
info.tooltipText = [nil, STRING]	-- Text of the tooltip shown on mouseover
info.justifyH = [nil, "CENTER"]		-- Justify button text
]]--

local GlueDark_DropDownMenu_ButtonInfo = {};

function GlueDark_DropDownMenu_CreateInfo()
	-- Reuse the same table to prevent memory churn
	local info = GlueDark_DropDownMenu_ButtonInfo;

	for k,v in pairs(info) do
		info[k] = nil;
	end

	return info;
end

function GlueDark_DropDownMenu_AddButton(info, level)
	--[[
	Might to uncomment this if there are performance issues
	if ( not GLUEDARK_DROPDOWNMENU_OPEN_MENU ) then
		return;
	end
	]]
	if ( not level ) then
		level = 1;
	end

	local listFrame = _G["GlueDark_DropDownList"..level];
	local listFrameName = listFrame:GetName();
	local index = listFrame.numButtons + 1;
	local width;

	-- If too many levels error out
	if ( level > GLUEDARK_DROPDOWNMENU_MAXLEVELS ) then
		message("Too many levels in GlueDark_DropDownMenu: "..GLUEDARK_DROPDOWNMENU_OPEN_MENU);
		return;
	end

	-- If not enough buttons then create one!
	if ( index > listFrame.maxButtons ) then
		CreateFrame("BUTTON", listFrameName .. "Button" .. index, listFrame, "GlueDark_DropDownMenuButtonTemplate"):SetID(index);
		listFrame.maxButtons = index;
	end

	-- Set the number of buttons in the listframe
	listFrame.numButtons = index;

	local button = _G[listFrameName.."Button"..index];
	local normalText = button.NormalText;
	-- This button is used to capture the mouse OnEnter/OnLeave events if the dropdown button is disabled, since a disabled button doesn't receive any events
	-- This is used specifically for drop down menu time outs
	local invisibleButton = button.InvisibleButton

	-- Default settings
	button:SetDisabledFontObject(GlueDark_DropDownMenuButtonTextDisabled);
	invisibleButton:Hide();
	button:Enable();

	-- If not clickable then disable the button and set it white
	if ( info.notClickable ) then
		info.disabled = 1;
		button:SetDisabledFontObject(GlueDark_DropDownMenuButtonText);
	end

	-- Set the text color and disable it if its a title
	if ( info.isTitle ) then
		info.disabled = 1;
		button:SetDisabledFontObject(GlueDark_DropDownMenuButtonTextBold);
	end

	-- Disable the button if disabled and turn off the colorCode
	if ( info.disabled ) then
		button:Disable();
		invisibleButton:Show();
		info.colorCode = nil;
	end

	-- Configure button
	if ( info.text ) then
		if ( info.colorCode ) then
			button:SetText(info.colorCode..info.text.."|r");
		else
			button:SetText(info.text);
		end
		-- Determine the maximum width of a button
		width = normalText:GetWidth() + 60;
		-- Add padding if has and expand arrow or color swatch
		if ( info.hasArrow or info.hasColorSwatch ) then
			width = width + 50 - 30;
		end
		if ( info.notCheckable ) then
			width = width - 30;
		end
		if ( width > listFrame.maxWidth ) then
			listFrame.maxWidth = width;
		end
		-- Check to see if there is a replacement font
		if ( info.fontObject ) then
			button:SetNormalFontObject(info.fontObject);
			button:SetHighlightFontObject(info.fontObject);
		else
			button:SetNormalFontObject(GlueDark_DropDownMenuButtonText);
			button:SetHighlightFontObject(GlueDark_DropDownMenuButtonText);
		end
	else
		button:SetText("");
	end

	-- Pass through attributes
	button.func = info.func;
	button.owner = info.owner;
	button.hasOpacity = info.hasOpacity;
	button.opacity = info.opacity;
	button.opacityFunc = info.opacityFunc;
	button.cancelFunc = info.cancelFunc;
	button.swatchFunc = info.swatchFunc;
	button.keepShownOnClick = info.keepShownOnClick;
	button.tooltipTitle = info.tooltipTitle;
	button.tooltipText = info.tooltipText;

	if ( info.value ) then
		button.value = info.value;
	elseif ( info.text ) then
		button.value = info.text;
	else
		button.value = nil;
	end

	-- Show the expand arrow if it has one
	if ( info.hasArrow ) then
		_G[listFrameName.."Button"..index.."ExpandArrow"]:Show();
	else
		_G[listFrameName.."Button"..index.."ExpandArrow"]:Hide();
	end
	button.hasArrow = info.hasArrow;

	-- If not checkable move everything over to the left to fill in the gap where the check would be
	local xPos = 4;
	local yPos = -((button:GetID() - 1) * GLUEDARK_DROPDOWNMENU_BUTTON_HEIGHT) - GLUEDARK_DROPDOWNMENU_BORDER_HEIGHT;
	normalText:ClearAllPoints();
	if ( info.notCheckable ) then
		if ( info.justifyH and info.justifyH == "CENTER" ) then
			normalText:SetPoint("CENTER", button, "CENTER", -7, -1);
		else
			normalText:SetPoint("LEFT", button, "LEFT", 0, -1);
		end
		xPos = xPos + 10;
	else
	--	xPos = xPos + 12;
		normalText:SetPoint("LEFT", button, "LEFT", 27, -1);
	end

	-- Adjust offset if displayMode is menu
	local frame = _G[GLUEDARK_DROPDOWNMENU_OPEN_MENU];
	if ( frame and frame.displayMode == "MENU" ) then
		if ( not info.notCheckable ) then
			xPos = xPos + 3;
			normalText:SetPoint("LEFT", button, "LEFT", 5, 0);
		end
	end

	-- If no open frame then set the frame to the currently initialized frame
	if ( not frame ) then
		frame = _G[GLUEDARK_DROPDOWNMENU_INIT_MENU];
	end

	button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xPos, yPos);

	-- See if button is selected by id or name
	if ( frame ) then
		if ( GlueDark_DropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == GlueDark_DropDownMenu_GetSelectedName(frame) ) then
				info.checked = 1;
			end
		elseif ( GlueDark_DropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == GlueDark_DropDownMenu_GetSelectedID(frame) ) then
				info.checked = 1;
			end
		elseif ( GlueDark_DropDownMenu_GetSelectedValue(frame) ) then
			if ( button.value == GlueDark_DropDownMenu_GetSelectedValue(frame) ) then
				info.checked = 1;
			end
		end
	end

	-- Show the check if checked
	if ( info.checked ) then
		button:LockHighlight();
		_G[listFrameName.."Button"..index.."Check"]:Show();
	else
		button:UnlockHighlight();
		_G[listFrameName.."Button"..index.."Check"]:Hide();
	end
	button.checked = info.checked;

	-- If has a colorswatch, show it and vertex color it
	local colorSwatch = _G[listFrameName.."Button"..index.."ColorSwatch"];
	if ( info.hasColorSwatch ) then
		_G["GlueDark_DropDownList"..level.."Button"..index.."ColorSwatch".."NormalTexture"]:SetVertexColor(info.r, info.g, info.b);
		button.r = info.r;
		button.g = info.g;
		button.b = info.b;
		colorSwatch:Show();
	else
		colorSwatch:Hide();
	end

	-- Set the height of the listframe
	listFrame:SetHeight((index * GLUEDARK_DROPDOWNMENU_BUTTON_HEIGHT) + (GLUEDARK_DROPDOWNMENU_BORDER_HEIGHT * 2));

	button:SetFrameLevel(button:GetParent():GetFrameLevel() + 2)
	button:Show();
end

function GlueDark_DropDownMenu_Refresh(frame, useValue)
	local button, checked, checkImage;

	-- Just redraws the existing menu
	local listFrame = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL];
	for i=1, listFrame.maxButtons do
		button = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL.."Button"..i];
		checked = nil;
		-- See if checked or not
		if ( GlueDark_DropDownMenu_GetSelectedName(frame) ) then
			if ( button:GetText() == GlueDark_DropDownMenu_GetSelectedName(frame) ) then
				checked = 1;
			end
		elseif ( GlueDark_DropDownMenu_GetSelectedID(frame) ) then
			if ( button:GetID() == GlueDark_DropDownMenu_GetSelectedID(frame) ) then
				checked = 1;
			end
		elseif ( GlueDark_DropDownMenu_GetSelectedValue(frame) ) then
			if ( button.value == GlueDark_DropDownMenu_GetSelectedValue(frame) ) then
				checked = 1;
			end
		end

		-- If checked show check image
		checkImage = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"];
		if ( checked ) then
			if ( useValue ) then
				GlueDark_DropDownMenu_SetText(frame, button.value);
			else
				GlueDark_DropDownMenu_SetText(frame, button:GetText());
			end
			button:LockHighlight();
			checkImage:Show();
		else
			button:UnlockHighlight();
			checkImage:Hide();
		end
	end
end

function GlueDark_DropDownMenu_SetSelectedName(frame, name, useValue)
	frame.selectedName = name;
	frame.selectedID = nil;
	frame.selectedValue = nil;
	GlueDark_DropDownMenu_Refresh(frame, useValue);
end

function GlueDark_DropDownMenu_SetSelectedValue(frame, value, useValue)
	-- useValue will set the value as the text, not the name
	frame.selectedName = nil;
	frame.selectedID = nil;
	frame.selectedValue = value;
	GlueDark_DropDownMenu_Refresh(frame, useValue);
end

function GlueDark_DropDownMenu_SetSelectedID(frame, id, useValue)
	frame.selectedID = id;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	GlueDark_DropDownMenu_Refresh(frame, useValue);
end

function GlueDark_DropDownMenu_GetSelectedName(frame)
	return frame.selectedName;
end

function GlueDark_DropDownMenu_GetSelectedID(frame)
	if ( frame.selectedID ) then
		return frame.selectedID;
	else
		-- If no explicit selectedID then try to send the id of a selected value or name
		local button;

		local listFrame = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL];
		for i=1, listFrame.maxButtons do
			button = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL.."Button"..i];
			-- See if checked or not
			if ( GlueDark_DropDownMenu_GetSelectedName(frame) ) then
				if ( button:GetText() == GlueDark_DropDownMenu_GetSelectedName(frame) ) then
					return i;
				end
			elseif ( GlueDark_DropDownMenu_GetSelectedValue(frame) ) then
				if ( button.value == GlueDark_DropDownMenu_GetSelectedValue(frame) ) then
					return i;
				end
			end
		end
	end
end

function GlueDark_DropDownMenu_GetSelectedValue(frame)
	return frame.selectedValue;
end

function GlueDark_DropDownMenuButton_OnClick(self)
	local func = self.func;
	if ( func ) then
		func(self);
	else
		return;
	end

	if ( self.keepShownOnClick ) then
		if ( self.checked ) then
			self.Check:Hide()
			self.checked = nil;
		else
			self.Check:Show()
			self.checked = 1;
		end
	else
		self:GetParent():Hide();
	end
	PlaySound("UChatScrollButton");
end

function GlueDark_HideDropDownMenu(level)
	local listFrame = _G["GlueDark_DropDownList"..level];
	listFrame:Hide();
end

function GlueDark_ToggleDropDownMenu(self, level, value, dropDownFrame, anchorName, xOffset, yOffset)
	if ( not level ) then
		level = 1;
	end
	GLUEDARK_DROPDOWNMENU_MENU_LEVEL = level;
	GLUEDARK_DROPDOWNMENU_MENU_VALUE = value;
	local listFrame = _G["GlueDark_DropDownList"..level];
	local tempFrame;
	local point, relativePoint, relativeTo;
	if ( not dropDownFrame ) then
		tempFrame = self:GetParent();
	else
		tempFrame = dropDownFrame;
	end
	if ( listFrame:IsShown() and (GLUEDARK_DROPDOWNMENU_OPEN_MENU == tempFrame:GetName()) ) then
		listFrame:Hide();
	else
		-- Set the dropdownframe scale
		local uiScale = 1.0;
		listFrame:SetScale(uiScale);

		-- Hide the listframe anyways since it is redrawn OnShow()
		listFrame:Hide();

		-- Frame to anchor the dropdown menu to
		local anchorFrame;

		-- Display stuff
		-- Level specific stuff
		if ( level == 1 ) then
			if ( not dropDownFrame ) then
				dropDownFrame = self:GetParent();
			end
			GLUEDARK_DROPDOWNMENU_OPEN_MENU = dropDownFrame:GetName();
			listFrame:ClearAllPoints();
			-- If there's no specified anchorName then use left side of the dropdown menu
			if ( not anchorName ) then
				-- See if the anchor was set manually using setanchor
				if ( dropDownFrame.xOffset ) then
					xOffset = dropDownFrame.xOffset;
				end
				if ( dropDownFrame.yOffset ) then
					yOffset = dropDownFrame.yOffset;
				end
				if ( dropDownFrame.point ) then
					point = dropDownFrame.point;
				end
				if ( dropDownFrame.relativeTo ) then
					relativeTo = dropDownFrame.relativeTo;
				else
					relativeTo = GLUEDARK_DROPDOWNMENU_OPEN_MENU.."Left";
				end
				if ( dropDownFrame.relativePoint ) then
					relativePoint = dropDownFrame.relativePoint;
				end
			elseif ( anchorName == "cursor" ) then
				relativeTo = "GlueParent";
				local cursorX, cursorY = GetCursorPosition();
				cursorX = cursorX/uiScale;
				cursorY = cursorY/uiScale;

				if ( not xOffset ) then
					xOffset = 0;
				end
				if ( not yOffset ) then
					yOffset = 0;
				end
				xOffset = cursorX + xOffset;
				yOffset = cursorY + yOffset;
			else
				relativeTo = anchorName;
			end
			if ( not xOffset or not yOffset ) then
				xOffset = 1.42;
				yOffset = 0.71;
			end
			if ( not point ) then
				point = "TOPLEFT";
			end
			if ( not relativePoint ) then
				relativePoint = "BOTTOMLEFT";
			end
			listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
		else
			if ( not dropDownFrame ) then
				dropDownFrame = _G[GLUEDARK_DROPDOWNMENU_OPEN_MENU];
			end
			listFrame:ClearAllPoints();
			-- If this is a dropdown button, not the arrow anchor it to itself
			if ( strsub(self:GetParent():GetName(), 0,12) == "GlueDark_DropDownList" and strlen(self:GetParent():GetName()) == 13 ) then
				anchorFrame = self:GetName();
			else
				anchorFrame = self:GetParent():GetName();
			end
			listFrame:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 0, 0);
		end

		-- Change list box appearance depending on display mode
		if ( dropDownFrame and dropDownFrame.displayMode == "MENU" ) then
			listFrame.Backdrop:Hide()
			listFrame.NineSlice:Hide()
			listFrame.MenuBackdrop:Show()
		else
			listFrame.Backdrop:Show();
			listFrame.NineSlice:Show()
			listFrame.MenuBackdrop:Hide();
		end

		listFrame.displayMode = dropDownFrame and dropDownFrame.displayMode or self.displayMode
		GlueDark_DropDownMenu_Initialize((dropDownFrame or self), dropDownFrame.initialize, nil, level);
		-- If no items in the drop down don't show it
		if ( listFrame.numButtons == 0 ) then
			return;
		end

		-- Check to see if the dropdownlist is off the screen, if it is anchor it to the top of the dropdown button
		listFrame:Show();
		local x, y = listFrame:GetCenter();

		-- If level 1 can only go off the bottom of the screen
		if ( level == 1 ) then
			local anchorPoint = "TOPLEFT";

			listFrame:ClearAllPoints();
			if ( anchorName == "cursor" ) then
				listFrame:SetPoint(anchorPoint, relativeTo, "BOTTOMLEFT", xOffset, yOffset);
			else
				listFrame:SetPoint(anchorPoint, relativeTo, relativePoint, xOffset, yOffset);
			end
		else
--[[
			-- Determine whether the menu is off the screen or not
			local offscreenY, offscreenX;
			if ( (y - listFrame:GetHeight()/2) < 0 ) then
				offscreenY = 1;
			end
			if ( listFrame:GetRight() > GetScreenWidth() ) then
				offscreenX = 1;
			end
--]]
			local anchorPoint, relativePoint, offsetX, offsetY;
--[[
			if ( offscreenY and offscreenX ) then
				anchorPoint = "BOTTOMRIGHT";
				relativePoint = "BOTTOMLEFT";
				offsetX = -11;
				offsetY = -14;
			elseif ( offscreenY ) then
				anchorPoint = "BOTTOMLEFT";
				relativePoint = "BOTTOMRIGHT";
				offsetX = 0;
				offsetY = -14;
			elseif ( offscreenX ) then
				anchorPoint = "TOPRIGHT";
				relativePoint = "TOPLEFT";
				offsetX = -11;
				offsetY = 14;
			else
-]]
				anchorPoint = "TOPLEFT";
				relativePoint = "TOPRIGHT";
				offsetX = 0;
				offsetY = 14;
--			end

			listFrame:ClearAllPoints();
			listFrame:SetPoint(anchorPoint, anchorFrame, relativePoint, offsetX, offsetY);
		end
	end
end

function GlueDark_CloseDropDownMenus(level)
	if ( not level ) then
		level = 1;
	end
	for i=level, GLUEDARK_DROPDOWNMENU_MAXLEVELS do
		_G["GlueDark_DropDownList"..i]:Hide();
	end
end

function GlueDark_DropDownMenu_SetWidth(frame, width, fullWidthButtonHitRect)
	frame.Middle:SetWidth(width)
	frame:SetWidth(width + 25 + 25);
	frame.Text:SetWidth(width)
	frame.fullWidthButtonHitRect = fullWidthButtonHitRect
	if fullWidthButtonHitRect then
		frame.Button:SetHitRectInsets(-(width + 11), -1, -3, -3)
	else
		frame.Button:SetHitRectInsets(0, 0, 0, 0)
	end
	frame.noResize = 1;
end

function GlueDark_DropDownMenu_SetButtonWidth(frame, width)
	if ( width == "TEXT" ) then
		width = frame.Text:GetWidth()
	end

	frame.Button:SetWidth(width)
	frame.noResize = 1;
end

function GlueDark_DropDownMenu_SetText(frame, text)
	frame.Text:SetText(text)
end

function GlueDark_DropDownMenu_GetText(frame)
	return frame.Text:GetText()
end

function GlueDark_DropDownMenu_ClearAll(frame)
	-- Previous code refreshed the menu quite often and was a performance bottleneck
	frame.selectedID = nil;
	frame.selectedName = nil;
	frame.selectedValue = nil;
	GlueDark_DropDownMenu_SetText(frame, "");

	local button, checkImage;

	local listFrame = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL];
	for i=1, listFrame.maxButtons do
		button = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL.."Button"..i];
		button:UnlockHighlight();

		checkImage = _G["GlueDark_DropDownList"..GLUEDARK_DROPDOWNMENU_MENU_LEVEL.."Button"..i.."Check"];
		checkImage:Hide();
	end
end

function GlueDark_DropDownMenu_JustifyText(frame, justification)
	frame.Text:SetJustifyH(justification)
	frame.Text:ClearAllPoints()
	if ( justification == "LEFT" ) then
		frame.Text:SetPoint("LEFT", frame.Left, "LEFT", 5, 0)
	elseif ( justification == "RIGHT" ) then
		frame.Text:SetPoint("RIGHT", frame.Right, "RIGHT", -43, 0)
	elseif ( justification == "CENTER" ) then
		frame.Text:SetPoint("CENTER", frame.Middle, "CENTER", -1, 0)
	end
end

function GlueDark_DropDownMenu_SetAnchor(self, xOffset, yOffset, point, relativeTo, relativePoint)
	self.xOffset = xOffset;
	self.yOffset = yOffset;
	self.point = point;
	self.relativeTo = relativeTo;
	self.relativePoint = relativePoint;
end

function GlueDark_DropDownMenu_GetCurrentDropDown(self)
	if ( GLUEDARK_DROPDOWNMENU_OPEN_MENU ) then
		return _G[GLUEDARK_DROPDOWNMENU_OPEN_MENU];
	end

	-- If no dropdown then use this
	return self;
end

function GlueDark_DropDownMenuButton_GetChecked(self)
	return self.Check:IsShown()
end

function GlueDark_DropDownMenuButton_GetName(self)
	return self.NormalText:GetText()
end

function GlueDark_DropDownMenuButton_OpenColorPicker(self, button)
	CloseMenus();
	if ( not button ) then
		button = self;
	end
	GLUEDARK_DROPDOWNMENU_MENU_VALUE = button.value;
	ColorPickerFrame.func = button.swatchFunc;
	ColorPickerFrame.hasOpacity = button.hasOpacity;
	ColorPickerFrame.opacityFunc = button.opacityFunc;
	ColorPickerFrame.opacity = button.opacity;
	ColorPickerFrame:SetColorRGB(button.r, button.g, button.b);
	ColorPickerFrame.previousValues = {r = button.r, g = button.g, b = button.b, opacity = button.opacity};
	ColorPickerFrame.cancelFunc = button.cancelFunc;
	ShowUIPanel(ColorPickerFrame);
end

function GlueDark_DropDownMenu_DisableButton(level, id)
	_G["GlueDark_DropDownList"..level.."Button"..id]:Disable();
end

function GlueDark_DropDownMenu_EnableButton(level, id)
	_G["GlueDark_DropDownList"..level.."Button"..id]:Enable();
end

function GlueDark_DropDownMenu_SetButtonText(level, id, text, colorCode)
	local button = _G["GlueDark_DropDownList"..level.."Button"..id];
	if ( colorCode ) then
		button:SetText(colorCode..text.."|r");
	else
		button:SetText(text);
	end
end

function GlueDark_DropDownMenu_DisableDropDown(dropDown)
	local label = _G[dropDown:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	dropDown.Text:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	dropDown.Button:Disable()
	dropDown.isDisabled = 1;
end

function GlueDark_DropDownMenu_EnableDropDown(dropDown)
	local label = _G[dropDown:GetName().."Label"];
	if ( label ) then
		label:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	dropDown.Text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	dropDown.Button:Enable();
	dropDown.isDisabled = nil;
end

function GlueDark_DialogFrame_OnKeyDown(self, key)
	if key == "ESCAPE" then
		self:Hide()
	elseif key == "PRINTSCREEN" then
		Screenshot()
	elseif key == "ENTER" then
		if self.Container and self.Container.OKButton and self.Container.OKButton:IsEnabled() == 1 then
			self.Container.OKButton:Click()
		end
	end
end

GlueDark_ButtonMixin = {}

local buttonMixinScripts = {
	"OnShow",
	"OnEnable",
	"OnDisable",
	"OnEnter",
	"OnLeave",
}

function GlueDark_ButtonMixin:OnLoadStyle(hookScripts)
	self._buttonColor = {0.47450980392157, 0.050980392156863, 0.07843137254902}
	self._buttonTextColor = {0.92549019607843, 0.75686274509804, 0}
	self._buttonDisableColor = {0.286, 0.306, 0.322}
	self._buttonDisableTextColor = {0.45490196078431, 0.46274509803922, 0.47058823529412}
	self._buttonHoverColor = {}

	for i = 1, 3 do
		self._buttonHoverColor[i] = self._buttonColor[i] * 1.25
	end

	self.Left:SetVertexColor(unpack(self._buttonColor))
	self.Middle:SetVertexColor(unpack(self._buttonColor))
	self.Right:SetVertexColor(unpack(self._buttonColor))

	self.ButtonText:SetTextColor(unpack(self._buttonTextColor))

	self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledLeft"], 3, 6))
	self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledMiddle"], 3, 6))
	self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledRight"], 3, 6))

	if hookScripts then
		for _, scriptName in ipairs(buttonMixinScripts) do
			local script = self:GetScript(scriptName)
			if not script or script ~= GlueDark_ButtonMixin[scriptName] then
				self:HookScript(scriptName, GlueDark_ButtonMixin[scriptName])
			end
		end
	end
end

function GlueDark_ButtonMixin:OnShow()
	if self:IsEnabled() == 1 then
		self.Left:SetVertexColor(unpack(self._buttonColor))
		self.Middle:SetVertexColor(unpack(self._buttonColor))
		self.Right:SetVertexColor(unpack(self._buttonColor))

		self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Left"], 3, 6))
		self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Middle"], 3, 6))
		self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Right"], 3, 6))
	else
		self.Left:SetVertexColor(unpack(self._buttonDisableColor))
		self.Middle:SetVertexColor(unpack(self._buttonDisableColor))
		self.Right:SetVertexColor(unpack(self._buttonDisableColor))

		self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledLeft"], 3, 6))
		self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledMiddle"], 3, 6))
		self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledRight"], 3, 6))
	end
end

function GlueDark_ButtonMixin:OnEnable()
	self.Left:SetVertexColor(unpack(self._buttonColor))
	self.Middle:SetVertexColor(unpack(self._buttonColor))
	self.Right:SetVertexColor(unpack(self._buttonColor))

	self.ButtonText:SetTextColor(unpack(self._buttonTextColor))

	self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Left"], 3, 6))
	self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Middle"], 3, 6))
	self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Right"], 3, 6))
end

function GlueDark_ButtonMixin:OnDisable()
	self.Left:SetVertexColor(unpack(self._buttonDisableColor))
	self.Middle:SetVertexColor(unpack(self._buttonDisableColor))
	self.Right:SetVertexColor(unpack(self._buttonDisableColor))

	self.ButtonText:SetTextColor(unpack(self._buttonDisableTextColor))

	self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledLeft"], 3, 6))
	self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledMiddle"], 3, 6))
	self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-DisabledRight"], 3, 6))
end

function GlueDark_ButtonMixin:OnEnter()
	if self:IsEnabled() == 1 then
		self.Left:SetVertexColor(unpack(self._buttonHoverColor))
		self.Middle:SetVertexColor(unpack(self._buttonHoverColor))
		self.Right:SetVertexColor(unpack(self._buttonHoverColor))

		self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-HoverLeft"], 3, 6))
		self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-HoverMiddle"], 3, 6))
		self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2-HoverRight"], 3, 6))
	end
end

function GlueDark_ButtonMixin:OnLeave()
	if self:IsEnabled() == 1 then
		self.Left:SetVertexColor(unpack(self._buttonColor))
		self.Middle:SetVertexColor(unpack(self._buttonColor))
		self.Right:SetVertexColor(unpack(self._buttonColor))

		self.Left:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Left"], 3, 6))
		self.Middle:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Middle"], 3, 6))
		self.Right:SetTexCoord(unpack(S_ATLAS_STORAGE["GlueDark-buttonBright2Right"], 3, 6))
	end
end