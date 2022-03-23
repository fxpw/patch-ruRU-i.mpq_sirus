--	Filename:	Sirus_TradeSkill.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/


TRADE_SKILLS_DISPLAYED = 25;
MAX_TRADE_SKILL_REAGENTS = 8;
TRADE_SKILL_HEIGHT = 16;
TRADE_SKILL_TEXT_WIDTH = 275;

TradeSkillTypePrefix = {
["optimal"] = " [+++] ",
["medium"] = " [++] ",
["easy"] = " [+] ",
["trivial"] = " ",
["header"] = " ",
}

TradeSkillTypeColor = { };
TradeSkillTypeColor["optimal"]	= { r = 1.00, g = 0.50, b = 0.25,	font = GameFontNormalLeftOrange };
TradeSkillTypeColor["medium"]	= { r = 1.00, g = 1.00, b = 0.00,	font = GameFontNormalLeftYellow };
TradeSkillTypeColor["easy"]		= { r = 0.25, g = 0.75, b = 0.25,	font = GameFontNormalLeftLightGreen };
TradeSkillTypeColor["trivial"]	= { r = 0.50, g = 0.50, b = 0.50,	font = GameFontNormalLeftGrey };
TradeSkillTypeColor["header"]	= { r = 1.00, g = 0.82, b = 0,		font = GameFontNormalLeft };

UIPanelWindows["TradeSkillFrame"] =	{ area = "left", pushable = 3, whileDead = 1, xOffset = "15", yOffset = "-10", showFailedFunc = "TradeSkillFrame_ShowFailed" };

CURRENT_TRADESKILL = "";

local CloseTradeSkill_old = CloseTradeSkill_old or CloseTradeSkill

function CloseTradeSkill()
	if TradeSkillFrame.minimalizeMode and MaximizeMinimizeFrame:IsShown() then
		SetCVar("miniTradeSkillFrame", 0)
	end

	HideUIPanel(TradeSkillFrame)
	CloseTradeSkill_old()
end

function TradeSkillFrame_Show()
	if ((AuctionFrame and AuctionFrame:IsShown() or (AuctionHouseFrame and AuctionHouseFrame:IsShown())) or GetMaxUIPanelsWidth() <= 1100) and MaximizeMinimizeFrame:IsShown() then
		SetCVar("miniTradeSkillFrame", 1)
		TradeSkillFrame.minimalizeMode = true
	end

	TradeSkillFrame_ToggleMode( GetCVarBool("miniTradeSkillFrame") )

	if not TradeSkillFrame:FixOpenPanel() then
		ShowUIPanel(TradeSkillFrame)
	end
	TradeSkillCreateButton:Disable();
	TradeSkillCreateAllButton:Disable();
	if ( GetTradeSkillSelectionIndex() == 0 ) then
		TradeSkillFrame_SetSelection(GetFirstTradeSkill());
	else
		TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex());
	end
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillListScrollFrameScrollBar:SetMinMaxValues(0, 0);
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	SetPortraitTexture(TradeSkillFramePortrait, "player");
	TradeSkillOnlyShowMakeable(TradeSkillFrameAvailableFilterCheckButton:GetChecked());
	TradeSkillFrame_Update();

	-- Moved to the bottom to prevent addons which hook it from blocking tradeskills
	CloseDropDownMenus();

	if TradeSkillFrame.isGuildOpen then
		TradeSkillFrame.RetrievingFrame:Show()
		TradeSkillFrame.isGuildOpen = false
	end
end

local oldModeValue
function TradeSkillFrame_ToggleMode( value )
	local self = TradeSkillFrame
	local numTradeSkills = GetNumTradeSkills()

	if value then
		self:SetSize(340, 496)

		self.RecipeInset:SetSize(325, 205)

		TradeSkillListScrollFrame:SetSize(300, 200)

		self.DetailsInset:SetSize(306, 184)
		self.DetailsInset:ClearAllPoints()
		self.DetailsInset:SetPoint("TOP", TradeSkillListScrollFrame, "BOTTOM", 0, -5)

		TradeSkillDetailScrollFrame:SetSize(300, 180)
		TradeSkillDetailScrollFrame:ClearAllPoints()
		TradeSkillDetailScrollFrame:SetPoint("TOPLEFT", self.DetailsInset, 2, 0)

		TradeSkillDetailScrollFrame.Background:SetSize(298, 178)
		TradeSkillDetailScrollFrame.Background:ClearAllPoints()
		TradeSkillDetailScrollFrame.Background:SetPoint("TOPLEFT", 4, -4)

		TradeSkillDetailScrollFrame.ScrollBar:SetAlpha(0.8)

		TradeSkillDetailScrollChildFrame:SetSize(300, 200)

		TradeSkillCancelButton:ClearAllPoints()
		TradeSkillCancelButton:SetPoint("TOPRIGHT", TradeSkillDetailScrollFrame, "BOTTOMRIGHT", 25, -3)

		TradeSkillCreateAllButton:ClearAllPoints()
		TradeSkillCreateAllButton:SetPoint("TOPLEFT", TradeSkillDetailScrollFrame, "BOTTOMLEFT", -2, -3)

		TradeSkillSkillIcon:SetSize(38, 38)
		TradeSkillSkillIcon.IconBorder:SetSize(38, 38)
		TradeSkillSkillIcon.ResultBorder:SetSize(42, 42)

		TradeSkillDescription:ClearAllPoints()
		TradeSkillDescription:SetPoint("TOPLEFT", 8, -70)

		TradeSkillRankFrame:SetSize(230, 14)
		TradeSkillRankFrame:ClearAllPoints()
		TradeSkillRankFrame:SetPoint("TOP", 10, -33)

		self.SearchBox:SetSize(138, 20)

		for i = 12, 25 do
			local skillButton = _G["TradeSkillSkill"..i]

			if skillButton then
				skillButton:Hide()
			end
		end

		TRADE_SKILLS_DISPLAYED = 12

		MaximizeMinimizeFrame.MaximizeButton:Show()
		MaximizeMinimizeFrame.MinimizeButton:Hide()
	else
		self:SetSize(670, 496)

		self.RecipeInset:SetSize(325, 410)
		TradeSkillListScrollFrame:SetSize(300, 405)

		self.DetailsInset:SetSize(335, 390)
		self.DetailsInset:ClearAllPoints()
		self.DetailsInset:SetPoint("TOPRIGHT", -6, -80)

		TradeSkillDetailScrollFrame:SetSize(300, 385)
		TradeSkillDetailScrollFrame:ClearAllPoints()
		TradeSkillDetailScrollFrame:SetPoint("TOPRIGHT", -32, -83)

		TradeSkillDetailScrollFrame.Background:SetSize(310, 383)
		TradeSkillDetailScrollFrame.Background:ClearAllPoints()
		TradeSkillDetailScrollFrame.Background:SetPoint("TOPLEFT", -5, 0)

		TradeSkillDetailScrollFrame.ScrollBar:SetAlpha(0.4)

		TradeSkillDetailScrollChildFrame:SetSize(300, 378)

		TradeSkillCancelButton:ClearAllPoints()
		TradeSkillCancelButton:SetPoint("TOPRIGHT", TradeSkillDetailScrollFrame, "BOTTOMRIGHT", 22, -3)

		TradeSkillCreateAllButton:ClearAllPoints()
		TradeSkillCreateAllButton:SetPoint("TOPLEFT", TradeSkillDetailScrollFrame, "BOTTOMLEFT", -5, -3)

		TradeSkillSkillIcon:SetSize(47, 47)
		TradeSkillSkillIcon.IconBorder:SetSize(47, 47)
		TradeSkillSkillIcon.ResultBorder:SetSize(51, 51)

		TradeSkillDescription:ClearAllPoints()
		TradeSkillDescription:SetPoint("TOPLEFT", 8, -85)

		TradeSkillRankFrame:SetSize(547, 14)
		TradeSkillRankFrame:ClearAllPoints()
		TradeSkillRankFrame:SetPoint("TOP", 20, -33)

		for i = 12, 25 do
			local skillButton = _G["TradeSkillSkill"..i]

			if skillButton then
				skillButton:Show()
			end
		end

		TRADE_SKILLS_DISPLAYED = 25

		MaximizeMinimizeFrame.MaximizeButton:Hide()
		MaximizeMinimizeFrame.MinimizeButton:Show()
	end

	TradeSkillFrame_Update()
	UpdateUIPanelPositions(self)
end

function TradeSkillFrame_Hide()
	HideUIPanel(TradeSkillFrame);
end

function TradeSkillFrame_ShowFailed(self)
	CloseTradeSkill();
	HideUIPanel(TradeSkillFrame)
end

local LEARNED_TAB = 1
local UNLEARNED_TAB = 2

function TradeSkillFrame_OnLoad(self)
	self:RegisterEvent("TRADE_SKILL_UPDATE");
	self:RegisterEvent("TRADE_SKILL_FILTER_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UPDATE_TRADESKILL_RECAST");

	self.minimalizeMode = false

	PanelTemplates_SetNumTabs(self, 2)
	PanelTemplates_DisableTab(self, 2)
	TradeSkillRecipeList_OnLearnedTabClicked(self)

	RaiseFrameLevel(self.UnlearnedTab)
	RaiseFrameLevel(self.LearnedTab)

	self.UnlearnedTab:ClearAllPoints()
	self.UnlearnedTab:SetPoint("LEFT", self.LearnedTab, "RIGHT", 0, 0)

	UIDropDownMenu_Initialize(self.FilterDropDown, TradeSkillFilterDropDownInit, "MENU")
	UIDropDownMenu_Initialize(self.LinkToDropDown, TradeSkillLinkToDropDownInit, "MENU")
end

function TradeSkillRecipeList_OnLearnedTabClicked( self, ... )
	PanelTemplates_SetTab(self, LEARNED_TAB)
end

function TradeSkillRecipeList_OnUnlearnedTabClicked( self, ... )
	PanelTemplates_SetTab(self, UNLEARNED_TAB)
end

function TradeSkillFrame_OnEvent(self, event, ...)
	if ( not TradeSkillFrame:IsShown() ) then
		return;
	end
	if ( event == "TRADE_SKILL_UPDATE" or event == "TRADE_SKILL_FILTER_UPDATE" ) then
		TradeSkillCreateButton:Disable();
		TradeSkillCreateAllButton:Disable();
		if ( (event ~= "TRADE_SKILL_FILTER_UPDATE") and (GetTradeSkillSelectionIndex() > 1) and (GetTradeSkillSelectionIndex() <= GetNumTradeSkills()) ) then
			TradeSkillFrame_SetSelection(GetTradeSkillSelectionIndex());
		else
			TradeSkillFrame_SetSelection(GetFirstTradeSkill());
			FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
			TradeSkillListScrollFrameScrollBar:SetValue(0);
		end
		TradeSkillFrame_Update();
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local arg1 = ...;
		if ( arg1 == "player" ) then
			SetPortraitTexture(TradeSkillFramePortrait, "player");
		end
	elseif ( event == "UPDATE_TRADESKILL_RECAST" ) then
		TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
	end
end

function TradeSkillFrame_Update()
	local numTradeSkills = GetNumTradeSkills();
	local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
	local name, rank, maxRank = GetTradeSkillLine();

	if ( CURRENT_TRADESKILL ~= name ) then
		StopTradeSkillRepeat();
		if ( CURRENT_TRADESKILL ~= "" ) then
			-- To fix problem with switching between two tradeskills
			UIDropDownMenu_Initialize(TradeSkillInvSlotDropDown, TradeSkillInvSlotDropDown_Initialize);
			UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, 1);

			UIDropDownMenu_Initialize(TradeSkillSubClassDropDown, TradeSkillSubClassDropDown_Initialize);
			UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, 1);
		end
		CURRENT_TRADESKILL = name;
	end

	-- If no tradeskills
	if ( numTradeSkills == 0 ) then
		TradeSkillFrameTitleText:SetFormattedText(TRADE_SKILL_TITLE, GetTradeSkillLine());
		TradeSkillSkillName:Hide();
--		TradeSkillSkillLineName:Hide();
		TradeSkillSkillIcon:Hide();
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
		TradeSkillCollapseAllButton:Disable();
		for i=1, MAX_TRADE_SKILL_REAGENTS, 1 do
			_G["TradeSkillReagent"..i]:Hide();
		end
	else
		TradeSkillSkillName:Show();
--		TradeSkillSkillLineName:Show();
		TradeSkillSkillIcon:Show();
		TradeSkillCollapseAllButton:Enable();
	end
	-- ScrollFrame update
	FauxScrollFrame_Update(TradeSkillListScrollFrame, numTradeSkills, TRADE_SKILLS_DISPLAYED, TRADE_SKILL_HEIGHT, nil, nil, nil, TradeSkillHighlightFrame, 298, 316, true );

	TradeSkillHighlightFrame:Hide();
	local skillName, skillType, numAvailable, isExpanded, altVerb;
	local skillIndex, skillButton, skillButtonText, skillButtonCount;
	local nameWidth, countWidth;

	local skillNamePrefix = " ";
	for i=1, TRADE_SKILLS_DISPLAYED, 1 do
		skillIndex = i + skillOffset;
		skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(skillIndex);
		skillButton = _G["TradeSkillSkill"..i];
		skillButtonText = _G["TradeSkillSkill"..i.."Text"];
		skillButtonCount = _G["TradeSkillSkill"..i.."Count"];
		if ( skillIndex <= numTradeSkills ) then
			-- Set button widths if scrollbar is shown or hidden
			if ( TradeSkillListScrollFrame:IsShown() ) then
				skillButton:SetWidth(293);
			else
				skillButton:SetWidth(323);
			end
			local color = TradeSkillTypeColor[skillType];
			if ( color ) then
				skillButton:SetNormalFontObject(color.font);
				skillButtonCount:SetVertexColor(color.r, color.g, color.b);
				skillButton.r = color.r;
				skillButton.g = color.g;
				skillButton.b = color.b;
			end

			if ( ENABLE_COLORBLIND_MODE == "1" ) then
				skillNamePrefix = TradeSkillTypePrefix[skillType] or " ";
			end

			skillButton:SetID(skillIndex);
			skillButton:Show();
			-- Handle headers
			if ( skillType == "header" ) then
				skillButton:SetText(skillName);
				skillButtonText:SetWidth(TRADE_SKILL_TEXT_WIDTH);
				skillButtonCount:SetText("");
				if ( isExpanded ) then
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
				_G["TradeSkillSkill"..i.."Highlight"]:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				_G["TradeSkillSkill"..i]:UnlockHighlight();
			else
				if ( not skillName ) then
					return;
				end
				skillButton:SetNormalTexture("");
				_G["TradeSkillSkill"..i.."Highlight"]:SetTexture("");
				if ( numAvailable <= 0 ) then
					skillButton:SetText(skillNamePrefix..skillName);
					skillButtonText:SetWidth(TRADE_SKILL_TEXT_WIDTH);
					skillButtonCount:SetText(skillCountPrefix);
				else
					skillName = skillNamePrefix..skillName;
					skillButtonCount:SetText("["..numAvailable.."]");
					TradeSkillFrameDummyString:SetText(skillName);
					nameWidth = TradeSkillFrameDummyString:GetWidth();
					countWidth = skillButtonCount:GetWidth();
					skillButtonText:SetText(skillName);
					if ( nameWidth + 2 + countWidth > TRADE_SKILL_TEXT_WIDTH ) then
						skillButtonText:SetWidth(TRADE_SKILL_TEXT_WIDTH-2-countWidth);
					else
						skillButtonText:SetWidth(0);
					end
				end

				-- Place the highlight and lock the highlight state
				if ( GetTradeSkillSelectionIndex() == skillIndex ) then
					TradeSkillHighlightFrame:SetPoint("TOPLEFT", "TradeSkillSkill"..i, "TOPLEFT", 0, 0);
					TradeSkillHighlightFrame:Show();
					skillButtonCount:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
					skillButton:LockHighlight();
					skillButton.isHighlighted = true;
				else
					skillButton:UnlockHighlight();
					skillButton.isHighlighted = false;
				end
			end

		else
			skillButton:Hide();
		end
	end

	-- Set the expand/collapse all button texture
	local numHeaders = 0;
	local notExpanded = 0;
	for i=1, numTradeSkills, 1 do
		local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(i);
		if ( skillName and skillType == "header" ) then
			numHeaders = numHeaders + 1;
			if ( not isExpanded ) then
				notExpanded = notExpanded + 1;
			end
		end
		if ( GetTradeSkillSelectionIndex() == i ) then
			-- Set the max makeable items for the create all button
			TradeSkillFrame.numAvailable = math.abs(numAvailable);
		end
	end
	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( notExpanded ~= numHeaders ) then
		TradeSkillCollapseAllButton.collapsed = nil;
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	else
		TradeSkillCollapseAllButton.collapsed = 1;
		TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	end
end

local lastID
function TradeSkillFrame_SetSelection(id)
	if not id then
		return
	end

	local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(id);
	local creatable = 1;
	if ( not skillName ) then
		creatable = nil;
	end
	TradeSkillHighlightFrame:Show();
	if ( skillType == "header" ) then
		TradeSkillHighlightFrame:Hide();
		if ( isExpanded ) then
			CollapseTradeSkillSubClass(id);
		else
			ExpandTradeSkillSubClass(id);
		end
		return;
	end
	TradeSkillFrame.selectedSkill = id;
	SelectTradeSkill(id);
	if ( GetTradeSkillSelectionIndex() > GetNumTradeSkills() ) then
		return;
	end
	local color = TradeSkillTypeColor[skillType];
	if ( color ) then
		TradeSkillHighlight:SetVertexColor(color.r, color.g, color.b);
	end

	-- General Info
	local skillLineName, skillLineRank, skillLineMaxRank = GetTradeSkillLine();
	TradeSkillFrameTitleText:SetFormattedText(TRADE_SKILL_TITLE, skillLineName);
	-- Set statusbar info
	TradeSkillRankFrame:SetStatusBarColor(0.0, 0.0, 1.0, 0.5);
	TradeSkillRankFrameBackground:SetVertexColor(0.0, 0.0, 0.75, 0.5);
	TradeSkillRankFrame:SetMinMaxValues(0, skillLineMaxRank);
	TradeSkillRankFrame:SetValue(skillLineRank);
	TradeSkillRankFrameSkillRank:SetText(skillLineRank.."/"..skillLineMaxRank);

	TradeSkillSkillName:SetText(skillName);
	if ( GetTradeSkillCooldown(id) ) then
		TradeSkillSkillCooldown:SetText(COOLDOWN_REMAINING.." "..SecondsToTime(GetTradeSkillCooldown(id)));
	else
		TradeSkillSkillCooldown:SetText("");
	end
	TradeSkillSkillIcon:SetNormalTexture(GetTradeSkillIcon(id));
	local minMade,maxMade = GetTradeSkillNumMade(id);
	if ( maxMade > 1 ) then
		if ( minMade == maxMade ) then
			TradeSkillSkillIconCount:SetText(minMade);
		else
			TradeSkillSkillIconCount:SetText(minMade.."-"..maxMade);
		end
		if ( TradeSkillSkillIconCount:GetWidth() > 39 ) then
			TradeSkillSkillIconCount:SetText("~"..floor((minMade + maxMade)/2));
		end
	else
		TradeSkillSkillIconCount:SetText("");
	end

	-- Reagents

	local numReagents = GetTradeSkillNumReagents(id);
	if(numReagents > 0) then
		TradeSkillReagentLabel:Show();
	else
		TradeSkillReagentLabel:Hide();
	end
	for i=1, numReagents, 1 do
		local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(id, i);
		local reagent = _G["TradeSkillReagent"..i]
		local name = _G["TradeSkillReagent"..i.."Name"];
		local count = _G["TradeSkillReagent"..i.."Count"];
		if ( not reagentName or not reagentTexture ) then
			reagent:Hide();
		else
			reagent:Show();
			SetItemButtonTexture(reagent, reagentTexture);
			name:SetText(reagentName);
			-- Grayout items
			if ( playerReagentCount < reagentCount ) then
				SetItemButtonTextureVertexColor(reagent, 0.5, 0.5, 0.5);
				name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				creatable = nil;
			else
				SetItemButtonTextureVertexColor(reagent, 1.0, 1.0, 1.0);
				name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			end
			if ( playerReagentCount >= 100 ) then
				playerReagentCount = "*";
			end
			count:SetText(playerReagentCount.." /"..reagentCount);
		end
	end
	-- Place reagent label
	local reagentToAnchorTo = numReagents;
	if ( (numReagents > 0) and (mod(numReagents, 2) == 0) ) then
		reagentToAnchorTo = reagentToAnchorTo - 1;
	end

	for i=numReagents + 1, MAX_TRADE_SKILL_REAGENTS, 1 do
		_G["TradeSkillReagent"..i]:Hide();
	end

	local spellFocus = BuildColoredListString(GetTradeSkillTools(id));
	if ( spellFocus ) then
		TradeSkillRequirementLabel:Show();
		TradeSkillRequirementText:SetText(spellFocus);
	else
		TradeSkillRequirementLabel:Hide();
		TradeSkillRequirementText:SetText("");
	end

	-- print(spellFocus)

	if ( creatable ) then
		TradeSkillCreateButton:Enable();
		TradeSkillCreateAllButton:Enable();
	else
		TradeSkillCreateButton:Disable();
		TradeSkillCreateAllButton:Disable();
	end

	local descriptionText = GetTradeSkillDescription(id)

	TradeSkillRequirementLabel:ClearAllPoints()

	if ( descriptionText and descriptionText ~= "" ) then
		TradeSkillDescription:SetText(GetTradeSkillDescription(id))
		TradeSkillRequirementLabel:SetPoint("TOPLEFT", "TradeSkillDescription", "BOTTOMLEFT", 0, -14);
		-- print(321)
	else
		TradeSkillDescription:SetText(" ");
		TradeSkillRequirementLabel:SetPoint("TOPLEFT", 8, -85);
		-- print(123)
	end

	-- Reset the number of items to be created
	-- TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount());
	if lastID ~= id then
		TradeSkillInputBox:SetNumber(GetTradeskillRepeatCount())
		lastID = id
	end

	--Hide inapplicable buttons if we are inspecting. Otherwise show them
	if ( IsTradeSkillLinked() ) then
		TradeSkillCreateButton:Hide();
		TradeSkillCreateAllButton:Hide();
		-- TradeSkillDecrementButton:Hide();
		TradeSkillInputBox:Hide();
		-- TradeSkillIncrementButton:Hide();
		TradeSkillLinkButton:Hide();
		-- TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotLeft]]);
		-- TradeSkillFrameBottomRightTexture:SetTexture([[Interface\PaperDollInfoFrame\SkillFrame-BotRight]]);
	else
		--Change button names and show/hide them depending on if this tradeskill creates an item or casts something
		if ( not altVerb ) then
			--Its an item with 'Create'
			TradeSkillCreateAllButton:Show();
			-- TradeSkillDecrementButton:Show();
			TradeSkillInputBox:Show();
			-- TradeSkillIncrementButton:Show();

			-- TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\TradeSkillFrame\UI-TradeSkill-BotLeft]]);
			-- TradeSkillFrameBottomRightTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotRight]])
		else
			--Its something else
			TradeSkillCreateAllButton:Hide();
			-- TradeSkillDecrementButton:Hide()
			TradeSkillInputBox:Hide();
			-- TradeSkillIncrementButton:Hide();

			-- TradeSkillFrameBottomLeftTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotLeft]]);
			-- TradeSkillFrameBottomRightTexture:SetTexture([[Interface\ClassTrainerFrame\UI-ClassTrainer-BotRight]]);
		end
		if ( GetTradeSkillListLink() ) then
			TradeSkillLinkButton:Show();
		else
			TradeSkillLinkButton:Hide();
		end
		TradeSkillCreateButton:SetText(altVerb or CREATE);
		TradeSkillCreateButton:Show();
    end
end

function TradeSkillSkillButton_OnClick(self, button)
	if ( button == "LeftButton" ) then
		TradeSkillFrame_SetSelection(self:GetID());
		TradeSkillFrame_Update();
	end
end

function TradeSkillFilter_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self)
	local text = self:GetText();

	if ( text == SEARCH ) then
		SetTradeSkillItemNameFilter("");
		return;
	end

	local minLevel, maxLevel;
	local approxLevel = strmatch(text, "^~(%d+)");
	if ( approxLevel ) then
		minLevel = approxLevel - 2;
		maxLevel = approxLevel + 2;
	else
		minLevel, maxLevel = strmatch(text, "^(%d+)%s*-*%s*(%d*)$");
	end
	if ( minLevel ) then
		if ( maxLevel == "" or maxLevel < minLevel ) then
			maxLevel = minLevel;
		end
		SetTradeSkillItemNameFilter(nil);
		SetTradeSkillItemLevelFilter(minLevel, maxLevel);
	else
		SetTradeSkillItemLevelFilter(0, 0);
		SetTradeSkillItemNameFilter(text);
	end
end

function TradeSkillCollapseAllButton_OnClick(self)
	if (self.collapsed) then
		self.collapsed = nil;
		ExpandTradeSkillSubClass(0);
	else
		self.collapsed = 1;
		TradeSkillListScrollFrameScrollBar:SetValue(0);
		CollapseTradeSkillSubClass(0);
	end
end

function TradeSkillSubClassDropDown_OnLoad(self)
	SetTradeSkillSubClassFilter(0, 1, 1);
	UIDropDownMenu_Initialize(self, TradeSkillSubClassDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 120);
	UIDropDownMenu_SetSelectedID(self, 1);
end

function TradeSkillSubClassDropDown_Initialize()
	TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses());
end

function TradeSkillFilterFrame_LoadSubClasses(...)
	local selectedID = UIDropDownMenu_GetSelectedID(TradeSkillSubClassDropDown);
	local numSubClasses = select("#", ...);
	local allChecked = GetTradeSkillSubClassFilter(0);

	-- the first button in the list is going to be an "all subclasses" button
	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL_SUBCLASSES;
	info.func = TradeSkillSubClassDropDownButton_OnClick;
	-- select this button if nothing else was selected
	info.checked = allChecked and (selectedID == nil or selectedID == 1);
	UIDropDownMenu_AddButton(info);
	if ( info.checked ) then
		UIDropDownMenu_SetText(TradeSkillSubClassDropDown, ALL_SUBCLASSES);
	end

	local checked;
	for i=1, select("#", ...), 1 do
		-- if there are no filters then don't check any individual subclasses
		if ( allChecked ) then
			checked = nil;
		else
			checked = GetTradeSkillSubClassFilter(i);
			if ( checked ) then
				UIDropDownMenu_SetText(TradeSkillSubClassDropDown, select(i, ...));
			end
		end
		info.text = select(i, ...);
		info.func = TradeSkillSubClassDropDownButton_OnClick;
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function TradeSkillInvSlotDropDown_OnLoad(self)
	SetTradeSkillInvSlotFilter(0, 1, 1);
	UIDropDownMenu_Initialize(self, TradeSkillInvSlotDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 120);
	UIDropDownMenu_SetSelectedID(self, 1);
end

function TradeSkillInvSlotDropDown_Initialize()
	TradeSkillFilterFrame_LoadInvSlots(GetTradeSkillInvSlots());
end

function TradeSkillFilterFrame_LoadInvSlots(...)
	UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, nil);
	local allChecked = GetTradeSkillInvSlotFilter(0);
	local info = UIDropDownMenu_CreateInfo();
	local filterCount = select("#", ...);
	info.text = ALL_INVENTORY_SLOTS;
	info.func = TradeSkillInvSlotDropDownButton_OnClick;
	info.checked = allChecked;
	UIDropDownMenu_AddButton(info);
	local checked;
	for i=1, filterCount, 1 do
		if ( allChecked and filterCount > 1 ) then
			checked = nil;
			UIDropDownMenu_SetText(TradeSkillInvSlotDropDown, ALL_INVENTORY_SLOTS);
		else
			checked = GetTradeSkillInvSlotFilter(i);
			if ( checked ) then
				UIDropDownMenu_SetText(TradeSkillInvSlotDropDown, select(i, ...));
			end
		end
		info.text = select(i, ...);
		info.func = TradeSkillInvSlotDropDownButton_OnClick;
		info.checked = checked;

		UIDropDownMenu_AddButton(info);
	end
end

function TradeSkillFilterFrame_InvSlotName(...)
	for i=1, select("#", ...), 1 do
		if ( GetTradeSkillInvSlotFilter(i) ) then
			return select(i, ...);
		end
	end
end

function TradeSkillSubClassDropDownButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(TradeSkillSubClassDropDown, self:GetID());
	SetTradeSkillSubClassFilter(self:GetID() - 1, 1, 1);
	if ( self:GetID() ~= 1 ) then
		if ( TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots()) ~= TradeSkillInvSlotDropDown.selected ) then
			SetTradeSkillInvSlotFilter(0, 1, 1);
			UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, 1);
			UIDropDownMenu_SetText(TradeSkillInvSlotDropDown, ALL_INVENTORY_SLOTS);
		end
	end
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillFrame_Update();
end

function TradeSkillInvSlotDropDownButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(TradeSkillInvSlotDropDown, self:GetID());
	SetTradeSkillInvSlotFilter(self:GetID() - 1, 1, 1);
	TradeSkillInvSlotDropDown.selected = TradeSkillFilterFrame_InvSlotName(GetTradeSkillInvSlots());
	TradeSkillListScrollFrameScrollBar:SetValue(0);
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0);
	TradeSkillFrame_Update();
end

function TradeSkillFrameIncrement_OnClick()
	if ( TradeSkillInputBox:GetNumber() < 100 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() + 1);
	end
end

function TradeSkillFrameDecrement_OnClick()
	if ( TradeSkillInputBox:GetNumber() > 0 ) then
		TradeSkillInputBox:SetNumber(TradeSkillInputBox:GetNumber() - 1);
	end
end

function TradeSkillItem_OnEnter(self)
	if ( TradeSkillFrame.selectedSkill ~= 0 ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetTradeSkillItem(TradeSkillFrame.selectedSkill);
	end
	CursorUpdate(self);
end

function TradeSkillLinkButton_OnClick( self, ... )
	local link = GetTradeSkillListLink()
	ChatFrame_OpenChat(link)
end

local showOnlyMakableRecipes = false
function SetOnlyShowMakeableRecipes( toggle )
	showOnlyMakableRecipes = toggle
	TradeSkillOnlyShowMakeable(showOnlyMakableRecipes)
end

function GetOnlyShowMakeableRecipes()
	return showOnlyMakableRecipes
end

function ToggleTradeSkillSubClassesFilter( toggle, index )
	if not index then
		for i = 1, #{GetTradeSkillSubClasses()} do
			SetTradeSkillSubClassFilter(i, toggle and 1 or 0)
		end

		CloseDropDownMenus()
	else
		SetTradeSkillSubClassFilter(index, toggle and 1 or 0)
	end

	TradeSkillListScrollFrameScrollBar:SetValue(0)
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0)
	TradeSkillFrame_Update()
end

function ToggleTradeSkillInvSlotsFilter( toggle, index )
	if not index then
		for i = 1, #{GetTradeSkillInvSlots()} do
			SetTradeSkillInvSlotFilter(i, toggle and 1 or 0)
		end

		CloseDropDownMenus()
	else
		SetTradeSkillInvSlotFilter(index, toggle and 1 or 0)
	end

	TradeSkillListScrollFrameScrollBar:SetValue(0)
	FauxScrollFrame_SetOffset(TradeSkillListScrollFrame, 0)
	TradeSkillFrame_Update()
end

function TradeSkillFrameLinkToButton_OnClick( self, ... )
	local link = GetTradeSkillListLink()

	if link then
		if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
			local text = MacroFrameText:GetText() .. link
			if strlenutf8(text) <= MacroFrameText:GetMaxLetters() then
				MacroFrameText:Insert(link)
			end
		else
			local activeEditBox = ChatEdit_GetActiveWindow()
			if activeEditBox then
				ChatEdit_InsertLink(link)
			else
				ToggleDropDownMenu(1, nil, self:GetParent().LinkToDropDown, self, 25, 25)
			end
		end
	end
end

function TradeSkillLinkToDropDownInit( self, level )
	local info = UIDropDownMenu_CreateInfo()
	local channels = {GetChannelList()}

	info.text = TRADESKILL_POST
	info.isTitle = true
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)

	info.isTitle = nil
	info.notCheckable = true
	info.func = function(_, channel)
		local link = GetTradeSkillListLink()

		if link then
			ChatFrame_OpenChat(channel.." "..link, DEFAULT_CHAT_FRAME)
		end
	end

	info.text = GUILD
	info.arg1 = SLASH_GUILD1
	info.disabled = not IsInGuild()
	UIDropDownMenu_AddButton(info)

	info.text = PARTY
	info.arg1 = SLASH_PARTY1
	info.disabled = GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0
	UIDropDownMenu_AddButton(info)

	info.text = RAID
	info.disabled = GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0
	info.arg1 = SLASH_RAID1
	UIDropDownMenu_AddButton(info)

	info.disabled = false

	for i = 1, #channels, 2 do
		local name = Chat_GetChannelShortcutName(channels[i])
		info.text = name
		info.arg1 = "/"..channels[i]
		UIDropDownMenu_AddButton(info)
	end
end

function TradeSkillFilterDropDownInit( self, level )
	local info = UIDropDownMenu_CreateInfo()

	if level == 1 then
		info.text = CRAFT_IS_MAKEABLE
		info.func = function()
			SetOnlyShowMakeableRecipes(not GetOnlyShowMakeableRecipes())
		end
		info.checked = GetOnlyShowMakeableRecipes()
		info.keepShownOnClick = true
		info.isNotRadio = true
		UIDropDownMenu_AddButton(info, level)

		info.checked = 	nil
		info.isNotRadio = nil
		info.func = nil
		info.notCheckable = true
		info.keepShownOnClick = true
		info.hasArrow = true

		info.text = ALL_SUBCLASSES
		info.value = 1
		UIDropDownMenu_AddButton(info, level)

		info.text = ALL_INVENTORY_SLOTS
		info.value = 2
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		info.hasArrow = false
		info.isNotRadio = true
		info.notCheckable = true
		info.keepShownOnClick = true

		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			local data = {GetTradeSkillSubClasses()}

			info.notCheckable = true

			info.text = CHECK_ALL
			info.func = function()
				ToggleTradeSkillSubClassesFilter(true)
			end
			UIDropDownMenu_AddButton(info, level)

			info.text = UNCHECK_ALL
			info.func = function()
				ToggleTradeSkillSubClassesFilter(false)
			end
			UIDropDownMenu_AddButton(info, level)

			info.notCheckable = false

			for i = 1, #data do
				local text = data[i]

				if text then
					info.text = text
					info.checked = GetTradeSkillSubClassFilter(i)
					info.func = function(self)
						local index = self:GetID() - 2
						ToggleTradeSkillSubClassesFilter(self.checked, index)
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
			local data = {GetTradeSkillInvSlots()}
			local allChecked = GetTradeSkillInvSlotFilter(0)

			info.notCheckable = true

			info.text = CHECK_ALL
			info.func = function()
				ToggleTradeSkillInvSlotsFilter(true)
			end
			UIDropDownMenu_AddButton(info, level)

			info.text = UNCHECK_ALL
			info.func = function()
				ToggleTradeSkillInvSlotsFilter(false)
			end
			UIDropDownMenu_AddButton(info, level)

			info.notCheckable = false

			for i = 1, #data do
				local text = data[i]

				if text then
					info.text = text
					info.checked = allChecked or GetTradeSkillInvSlotFilter(i)
					info.func = function(self)
						local index = self:GetID() - 2
						ToggleTradeSkillInvSlotsFilter(self.checked, index)
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
end

local TIME_BETWEEN_DOTS_SEC = .2;
function TradeSkillOnRetrievingFrameUpdate(self, elapsed)
	if self.RetrievingFrame.timeUntilNextDotSecs then
		self.RetrievingFrame.timeUntilNextDotSecs = self.RetrievingFrame.timeUntilNextDotSecs - elapsed;
	else
		self.RetrievingFrame.timeUntilNextDotSecs = TIME_BETWEEN_DOTS_SEC;
	end

	if self.RetrievingFrame.timeUntilNextDotSecs <= 0 then
		local dotCount = ((self.RetrievingFrame.dotCount or 0) + 1) % 4;

		self.RetrievingFrame.Dots:SetText(("."):rep(dotCount));
		self.RetrievingFrame.dotCount = dotCount;
		self.RetrievingFrame.timeUntilNextDotSecs = self.RetrievingFrame.timeUntilNextDotSecs + TIME_BETWEEN_DOTS_SEC;

		if self.RetrievingFrame.dotCount == 3 then
			self.RetrievingFrame:Hide()
		end
	end
end

function ClassTrainerSkillButton_OnClick( ... )
	-- body
end

------------Debug - waiting for hardcoded func------------

function TradeSkillCreatesItem(index)
	local link = GetTradeSkillItemLink(index)
	if ( string.sub(link,13,17) == "item:" ) then
		return true
	else
		return false
	end
end