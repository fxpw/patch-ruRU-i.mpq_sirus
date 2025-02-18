GLUETOOLTIP_NUM_LINES = 7;
GLUETOOLTIP_HPADDING = 20;
GLUETOOLTIP_UPDATE_TIME = 0.2

function GlueTooltip_OnLoad(self)
	self.Clear = GlueTooltip_Clear;
	self.SetFont = GlueTooltip_SetFont;
	self.AddLine = GlueTooltip_AddLine;
	self.SetText = GlueTooltip_SetText;
	self.SetOwner = GlueTooltip_SetOwner;
	self.GetOwner = GlueTooltip_GetOwner;
	self.IsOwned = GlueTooltip_IsOwned;
	self.SetMinimumWidth = GlueTooltip_SetMinimumWidth;
	self.SetMaxWidth = GlueTooltip_SetMaxWidth;
	self.SetPadding = GlueTooltip_SetPadding;
	self:SetBackdropBorderColor(1.0, 1.0, 1.0);
	self:SetBackdropColor(0, 0, 0);
	self.defaultColor = NORMAL_FONT_COLOR;
	self.updateTooltip = GLUETOOLTIP_UPDATE_TIME;
	self.numCreatedLines = GLUETOOLTIP_NUM_LINES

	GlueTooltip_OnTooltipSetDefaultAnchor(self)
end

function GlueTooltip_OnHide(self)
	self:Clear();
	self.owner = nil;
end

function GlueTooltip_OnUpdate(self, elapsed)
	-- Only update every GLUETOOLTIP_UPDATE_TIME seconds
	self.updateTooltip = self.updateTooltip - elapsed;
	if ( self.updateTooltip > 0 ) then
		return;
	end
	self.updateTooltip = GLUETOOLTIP_UPDATE_TIME;

	local owner = self:GetOwner();
	if ( owner and owner.UpdateTooltip ) then
		owner:UpdateTooltip();
	end
end

-- mimic what tooltip does ingame
local tooltipAnchorPointMapping = {
	["ANCHOR_LEFT"] =			{ myPoint = "BOTTOMRIGHT",	ownerPoint = "TOPLEFT" },
	["ANCHOR_RIGHT"] = 			{ myPoint = "BOTTOMLEFT", 	ownerPoint = "TOPRIGHT" },
	["ANCHOR_BOTTOMLEFT"] = 	{ myPoint = "TOPRIGHT", 	ownerPoint = "BOTTOMLEFT" },
	["ANCHOR_BOTTOM"] = 		{ myPoint = "TOP", 			ownerPoint = "BOTTOM" },
	["ANCHOR_BOTTOMRIGHT"] =	{ myPoint = "TOPLEFT", 		ownerPoint = "BOTTOMRIGHT" },
	["ANCHOR_TOPLEFT"] = 		{ myPoint = "BOTTOMLEFT", 	ownerPoint = "TOPLEFT" },
	["ANCHOR_TOP"] = 			{ myPoint = "BOTTOM", 		ownerPoint = "TOP" },
	["ANCHOR_TOPRIGHT"] = 		{ myPoint = "BOTTOMRIGHT", 	ownerPoint = "TOPRIGHT" },
};

function GlueTooltip_SetOwner(self, owner, anchor, xOffset, yOffset)
	if ( not self or not owner) then
		return;
	end
	self.owner = owner;
	anchor = anchor or "ANCHOR_LEFT";
	xOffset = xOffset or 0;
	yOffset = yOffset or 0;

	self:Clear()
	self:ClearAllPoints();

	if anchor == "ANCHOR_NONE" then
		GlueTooltip_OnTooltipSetDefaultAnchor(self)
	else
		local points = tooltipAnchorPointMapping[anchor];
		self:SetPoint(points.myPoint, owner, points.ownerPoint, xOffset, yOffset);
	end
end

function GlueTooltip_GetOwner(self)
	return self.owner;
end

function GlueTooltip_IsOwned(self, frame)
	return self:GetOwner() == frame;
end

function GlueTooltip_SetText(self, text, r, g, b, a, wrap)
	self:Clear();
	self:AddLine(text, r, g, b, a, wrap);
end

function GlueTooltip_SetFont(self, font)
	for i = 1, self.numCreatedLines do
		local textString = _G[self:GetName().."TextLeft"..i];
		textString:SetFontObject(font);
		textString = _G[self:GetName().."TextRight"..i];
		textString:SetFontObject(font);
	end
end

function GlueTooltip_Clear(self)
	for i = 1, self.numCreatedLines do
		local textString = _G[self:GetName().."TextLeft"..i];
		textString:SetText("");
		textString:Hide();
		textString:SetWidth(0);
		textString = _G[self:GetName().."TextRight"..i];
		textString:SetText("");
		textString:Hide();
		textString:SetWidth(0);
	end
	self:SetWidth(1);
	self:SetHeight(1);
	self.__minWidth = nil
	self.__maxWidth = nil

	GlueTooltip_OnTooltipCleared(self)
end

function GlueTooltip_SetMinimumWidth(self, width)
	if type(width) == "number" then
		self.__minWidth = width
	end
end

function GlueTooltip_SetMaxWidth(self, width)
	if type(width) == "number" then
		self.__maxWidth = width
	end
end

function GlueTooltip_AddLine(self, text, r, g, b, a, wrap, indentedWordWrap)
	r = r or self.defaultColor.r;
	g = g or self.defaultColor.g;
	b = b or self.defaultColor.b;
	a = a or 1;
	indentedWordWrap = indentedWordWrap or false;
	-- find a free line
	local freeLine;
	for i = 1, self.numCreatedLines do
		local line = _G[self:GetName().."TextLeft"..i];
		if ( not line:IsShown() ) then
			freeLine = line;
			break;
		end
	end

	if not freeLine then
		local nextLineNumber = self.numCreatedLines + 1
		local previousLine = _G[self:GetName().."TextLeft"..self.numCreatedLines]
		local fontObject = previousLine:GetFontObject():GetName()
		local leftLine = self:CreateFontString(self:GetName().."TextLeft"..nextLineNumber, "ARTWORK", fontObject)
		local rightLine = self:CreateFontString(self:GetName().."TextRight"..nextLineNumber, "ARTWORK", fontObject)

		leftLine:SetJustifyH("LEFT")
		rightLine:SetJustifyH("RIGHT")

		leftLine:SetPoint("TOPLEFT", previousLine, "BOTTOMLEFT", 0, -2)
		rightLine:SetPoint("RIGHT", leftLine, "LEFT", 40, 0)

		self.numCreatedLines = nextLineNumber
		freeLine = leftLine
	end

	freeLine:SetTextColor(r, g, b, a);
	freeLine:SetText(text);
	freeLine:Show();
	freeLine:SetWidth(0);
	freeLine:SetIndentedWordWrap(indentedWordWrap);

	local wrapWidth = 230;
	local padding = self.__padding or 0
	if (wrap and freeLine:GetWidth() > wrapWidth) then
		-- Trim the right edge so that there isn't extra space after wrapping
		if self.__maxWidth then
			wrapWidth = math.min(wrapWidth + padding, self.__maxWidth + padding)
		end
		if self.__minWidth then
			wrapWidth = math.max(wrapWidth, self.__minWidth)
		end
		freeLine:SetWidth(wrapWidth);
		self:SetWidth(max(self:GetWidth(), wrapWidth + GLUETOOLTIP_HPADDING));
	else
		if self.__maxWidth then
			wrapWidth = max(self:GetWidth() + padding, math.min(freeLine:GetWidth() + padding, self.__maxWidth + padding))
		else
			wrapWidth = max(self:GetWidth() + padding, freeLine:GetWidth() + padding)
		end
		if self.__minWidth then
			wrapWidth = math.max(wrapWidth, self.__minWidth)
		end
		self:SetWidth(wrapWidth + GLUETOOLTIP_HPADDING);
	end

	-- Compute height and update width of text lines
	local height = 18;
	for i = 1, self.numCreatedLines do
		-- Update width of all lines
		local line = _G[self:GetName().."TextLeft"..i];
		local rightLine = _G[self:GetName().."TextRight"..i];
		if (not rightLine:IsShown()) then
			line:SetWidth(self:GetWidth()-GLUETOOLTIP_HPADDING);
		end

		-- Update the height of the frame
		if ( line:IsShown() ) then
			height = height + line:GetHeight() + 2;
		end
	end
	self:SetHeight(height);
end

function GlueTooltip_SetPadding(self, padding)
	self.__padding = padding or 0
end

function GlueTooltip_OnTooltipCleared(self)
	if type(self.OnTooltipCleared) == "function" then
		local success, err = pcall(self.OnTooltipCleared, self)
		if not success then
			geterrorhandler()(err)
		end
	end
end

function GlueTooltip_OnTooltipSetDefaultAnchor(self)
	if type(self.OnTooltipSetDefaultAnchor) == "function" then
		local success, err = pcall(self.OnTooltipSetDefaultAnchor, self)
		if not success then
			geterrorhandler()(err)
		end
	end
end

CharacterCreateAbilityListMixin = {}

function CharacterCreateAbilityListMixin:OnLoad()
	self.buttonPool = CreateFramePool("FRAME", self, "CharacterCreateFrameAbilityTemplate");
end

function CharacterCreateAbilityListMixin:SetupAbilties(abilities)
	self.buttonPool:ReleaseAll()

	for index, abilityInfo in ipairs(abilities) do
		local button = self.buttonPool:Acquire()
		button:SetupAbilties(abilityInfo, index)
		button:Show()
	end

	self:Layout()
end

CharacterCreateFrameAbilityMixin = {};

function CharacterCreateFrameAbilityMixin:OnLoad()
	self.IconOverlay:SetAtlas("dressingroom-itemborder-gray")
end

function CharacterCreateFrameAbilityMixin:SetupAbilties(abilityData, index)
	self.abilityData = abilityData
	self.layoutIndex = index + 1

	if not self.Icon:SetTexture(abilityData.icon) then
		self.Icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
	end
	self.Text:SetText(abilityData.description)

	self:Layout()
end