CHAR_CUSTOMIZE_MAX_SCALE = 0.75;

local showDebugTooltipInfo = false

CharCustomizeParentFrameBaseMixin = {};

function CharCustomizeParentFrameBaseMixin:SetCustomizationChoice(optionID, choiceID)
end

function CharCustomizeParentFrameBaseMixin:PreviewCustomizationChoice(optionID, choiceID)
end

function CharCustomizeParentFrameBaseMixin:ResetCustomizationPreview(clearSavedChoices)
end

function CharCustomizeParentFrameBaseMixin:MarkCustomizationChoiceAsSeen(choiceID)
end

function CharCustomizeParentFrameBaseMixin:MarkCustomizationOptionAsSeen(optionID)
end

function CharCustomizeParentFrameBaseMixin:SetViewingAlteredForm(viewingAlteredForm, resetCategory)
end

function CharCustomizeParentFrameBaseMixin:SetViewingShapeshiftForm(formID)
end

function CharCustomizeParentFrameBaseMixin:SetViewingChrModel(chrModelID)
end

function CharCustomizeParentFrameBaseMixin:SetModelDressState(dressedState)
end

function CharCustomizeParentFrameBaseMixin:RandomizeAppearance()
end

function CharCustomizeParentFrameBaseMixin:SetCharacterSex(sexID)
end

function CharCustomizeParentFrameBaseMixin:OnButtonClick()
end

CharCustomizeBaseButtonMixin = {};

function CharCustomizeBaseButtonMixin:OnBaseButtonClick()
	CharCustomizeFrame:OnButtonClick();
end

CharCustomizeFrameWithTooltipMixin = {};

function CharCustomizeFrameWithTooltipMixin:OnLoad()
	self.tooltipAnchor = self:GetAttribute("tooltipAnchor")
	self.tooltipXOffset = self:GetAttribute("tooltipXOffset")
	self.tooltipYOffset = self:GetAttribute("tooltipYOffset")
	self.tooltipMinWidth = self:GetAttribute("tooltipMinWidth")
	self.tooltipPadding = self:GetAttribute("tooltipPadding")

	if self.simpleTooltipLine then
		self:AddTooltipLine(self.simpleTooltipLine, HIGHLIGHT_FONT_COLOR);
	end
end

function CharCustomizeFrameWithTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
end

function CharCustomizeFrameWithTooltipMixin:AddTooltipLine(lineText, lineColor)
	if not self.tooltipLines then
		self.tooltipLines = {};
	end

	table.insert(self.tooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

function CharCustomizeFrameWithTooltipMixin:AddBlankTooltipLine()
	self:AddTooltipLine(" ");
end

function CharCustomizeFrameWithTooltipMixin:GetAppropriateTooltip()
	return CharCustomizeNoHeaderTooltip;
end

function CharCustomizeFrameWithTooltipMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == "ANCHOR_TOPRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_TOPLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function CharCustomizeFrameWithTooltipMixin:AddExtraStuffToTooltip()
end

function CharCustomizeFrameWithTooltipMixin:OnEnter()
	if self.tooltipLines then
		local tooltip = self:GetAppropriateTooltip();

		self:SetupAnchors(tooltip);

		if self.tooltipMinWidth then
			tooltip:SetMinimumWidth(self.tooltipMinWidth);
		end

		if self.tooltipPadding then
			tooltip:SetPadding(self.tooltipPadding, self.tooltipPadding, self.tooltipPadding, self.tooltipPadding);
		end

		for _, lineInfo in ipairs(self.tooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end

		self:AddExtraStuffToTooltip();

		tooltip:Show();
	end
end

function CharCustomizeFrameWithTooltipMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

CharCustomizeSmallButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeSmallButtonMixin:OnLoad()
	self.NormalTexture:SetAtlas("common-button-square-gray-up")
	self.PushedTexture:SetAtlas("common-button-square-gray-down")

	self.HighlightTexture:ClearAllPoints()
	self.HighlightTexture:SetPoint("TOPLEFT", self.Icon)
	self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.Icon)

	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	self.Icon:SetAtlas(self.iconAtlas);
	self.HighlightTexture:SetAtlas(self.iconAtlas);
end

function CharCustomizeSmallButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self.PushedTexture);
	end
end

function CharCustomizeSmallButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER");
end

function CharCustomizeSmallButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
	self:OnBaseButtonClick()
end

CharCustomizeResetCameraButtonMixin = {};

function CharCustomizeResetCameraButtonMixin:OnLoad()
	self.layoutIndex = self:GetAttribute("layoutIndex")
	self.iconAtlas = self:GetAttribute("iconAtlas")

	CharCustomizeSmallButtonMixin.OnLoad(self)
end

CharCustomizeRandomizeAppearanceButtonMixin = {};

function CharCustomizeRandomizeAppearanceButtonMixin:OnLoad()
	self.iconAtlas = self:GetAttribute("iconAtlas")
	self.tooltipAnchor = self:GetAttribute("tooltipAnchor")
	self.tooltipXOffset = self:GetAttribute("tooltipXOffset")
	self.tooltipYOffset = self:GetAttribute("tooltipYOffset")
	self.simpleTooltipLine = nil

	CharCustomizeSmallButtonMixin.OnLoad(self)
end

function CharCustomizeRandomizeAppearanceButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);
	CharCustomizeFrame:RandomizeAppearance();
end

CharCustomizeClickOrHoldButtonMixin = {};

function CharCustomizeClickOrHoldButtonMixin:OnLoad()
	self.holdWaitTimeSeconds = self:GetAttribute("holdWaitTimeSeconds")

	CharCustomizeSmallButtonMixin.OnLoad(self)
end

function CharCustomizeClickOrHoldButtonMixin:OnHide()
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

function CharCustomizeClickOrHoldButtonMixin:DoClickAction()
end

function CharCustomizeClickOrHoldButtonMixin:DoHoldAction(elapsed)
end

function CharCustomizeClickOrHoldButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);

	if not self.wasHeld then
		self:DoClickAction();
	end
end

function CharCustomizeClickOrHoldButtonMixin:OnUpdate(elapsed)
	if self.waitTimerSeconds then
		self.waitTimerSeconds = self.waitTimerSeconds - elapsed;
		if self.waitTimerSeconds >= 0 then
			return;
		else
			-- waitTimerSeconds is now negative, so add it to elapsed to remove any leftover wait time
			elapsed = elapsed + self.waitTimerSeconds;
			self.waitTimerSeconds = nil;
		end
	end

	self.wasHeld = true;
	self:DoHoldAction(elapsed);
end

function CharCustomizeClickOrHoldButtonMixin:OnMouseDown()
	CharCustomizeSmallButtonMixin.OnMouseDown(self);
	self.wasHeld = false;
	self.waitTimerSeconds = self.holdWaitTimeSeconds;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function CharCustomizeClickOrHoldButtonMixin:OnMouseUp()
	CharCustomizeSmallButtonMixin.OnMouseUp(self);
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

CharCustomizeMaskedButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeMaskedButtonMixin:OnLoad()
	self.disabledOverlayAlpha = self:GetAttribute("disabledOverlayAlpha")
	self.newTagYOffset = self:GetAttribute("newTagYOffset")

	self.CheckedTexture:SetAtlas("charactercreate-ring-select")
	self.NormalTexture:SetDrawLayer("BACKGROUND")
	self.PushedTexture:SetDrawLayer("BACKGROUND")

	CharCustomizeFrameWithTooltipMixin.OnLoad(self);

	local hasRingSizes = self.ringWidth and self.ringHeight;
	if hasRingSizes then
		self.Ring:SetAtlas(self.ringAtlas);
		self.Ring:SetSize(self.ringWidth, self.ringHeight);
	else
		self.Ring:SetAtlas(self.ringAtlas, true);
	end

	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha);
	self.CheckedTexture:SetSize(self.checkedTextureSize, self.checkedTextureSize);

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1);
		self.PushedTexture:SetTexCoord(1, 0, 0, 1);
	end
end

function CharCustomizeMaskedButtonMixin:SetIconAtlas(atlas)
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);
end

function CharCustomizeMaskedButtonMixin:SetEnabledState(enabled)
	local buttonEnableState = enabled or self.allowSelectionOnDisable;
	self:SetEnabled(buttonEnableState);

	local normalTex = self:GetNormalTexture();
	if normalTex then
		normalTex:SetDesaturated(not enabled);
	end

	local pushedTex = self:GetPushedTexture();
	if pushedTex then
		pushedTex:SetDesaturated(not enabled);
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and "" or "-disabled"));

	self.DisabledOverlay:SetShown(not enabled);
end

function CharCustomizeMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.Ring:SetPoint("CENTER", self, "CENTER", 1, -1);
	end
end

function CharCustomizeMaskedButtonMixin:OnMouseUp(button)
	if button == "RightButton" and self.expandedTooltipFrame then
		self.tooltipsExpanded = not self.tooltipsExpanded;
		if GetMouseFocus() == self then
			self:OnEnter();
		end
	end

	self.CheckedTexture:SetPoint("CENTER");
	self.Ring:SetPoint("CENTER");
end

function CharCustomizeMaskedButtonMixin:OnClick(button)
	CharCustomizeBaseButtonMixin.OnBaseButtonClick(self)
end

function CharCustomizeMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		self.HighlightTexture:SetAtlas("charactercreate-ring-select");
		self.HighlightTexture:SetPoint("TOPLEFT", self.CheckedTexture);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.CheckedTexture);
	else
		self.HighlightTexture:SetAtlas(self.ringAtlas);
		self.HighlightTexture:SetPoint("TOPLEFT", self.Ring);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.Ring);
	end
end

CharCustomizeAlteredFormButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeAlteredFormButtonMixin:OnLoad()
	self.ringAtlas = self:GetAttribute("ringAtlas")
	self.ringWidth = self:GetAttribute("ringWidth")
	self.ringHeight = self:GetAttribute("ringHeight")
	self.checkedTextureSize = self:GetAttribute("checkedTextureSize")
	self.disabledOverlayAlpha = self:GetAttribute("disabledOverlayAlpha")
	self.tooltipYOffset = self:GetAttribute("tooltipYOffset")
	self.flipTextures = self:GetAttribute("flipTextures")

	CharCustomizeMaskedButtonMixin.OnLoad(self)
end

function CharCustomizeAlteredFormButtonMixin:SetupAlteredFormButton(raceData, isSelected, isAlteredForm, layoutIndex)
	self.layoutIndex = layoutIndex;
	self.isAlteredForm = isAlteredForm;
	self.isSelected = isSelected;

	self:SetIconAtlas(raceData.createScreenIconAtlas);

	self:ClearTooltipLines();
	self:AddTooltipLine(CHARACTER_FORM:format(raceData.name));

	self:SetChecked(isSelected);

	self:UpdateHighlightTexture();
end

function CharCustomizeAlteredFormButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeAlteredFormButtonMixin:OnClick(button)
	CharCustomizeMaskedButtonMixin.OnClick(self, button)

	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);

	CharCustomizeFrame:SetViewingAlteredForm(self.isAlteredForm);
	CharCustomizeFrame:UpdateAlteredFormButtons()
end

CharCustomizeCategoryButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeCategoryButtonMixin:OnLoad()
	self.ringAtlas = self:GetAttribute("ringAtlas")
	self.ringWidth = self:GetAttribute("ringWidth")
	self.ringHeight = self:GetAttribute("ringHeight")
	self.checkedTextureSize = self:GetAttribute("checkedTextureSize")
	self.tooltipAnchor = self:GetAttribute("tooltipAnchor")
	self.tooltipXOffset = self:GetAttribute("tooltipXOffset")
	self.tooltipYOffset = self:GetAttribute("tooltipYOffset")
	self.newTagYOffset = self:GetAttribute("newTagYOffset")

	CharCustomizeMaskedButtonMixin.OnLoad(self)
end

function CharCustomizeCategoryButtonMixin:SetCategory(categoryData, selectedCategoryID)
	self.categoryData = categoryData;
	self.categoryID = categoryData.id;
	self.layoutIndex = categoryData.orderIndex;

	self:ClearTooltipLines();

	if showDebugTooltipInfo then
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end

	local selected = false;
	if categoryData.chrModelID then
		if CharCustomizeFrame.viewingChrModelID then
			selected = categoryData.chrModelID == CharCustomizeFrame.viewingChrModelID;
		else
			selected = categoryData.chrModelID == CharCustomizeFrame.firstChrModelID;
		end
	else
		selected = selectedCategoryID == categoryData.id;
	end
	if selected then
		self:SetChecked(true);
		self:SetIconAtlas(categoryData.selectedIcon);
	else
		self:SetChecked(false);
		self:SetIconAtlas(categoryData.icon);
	end

	self:UpdateHighlightTexture();
end

function CharCustomizeCategoryButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCustomizeFrame:SetSelectedCategory(self.categoryData);
end

CharCustomizeShapeshiftFormButtonMixin = CreateFromMixins(CharCustomizeCategoryButtonMixin);

function CharCustomizeShapeshiftFormButtonMixin:OnLoad()
	self.ringAtlas = self:GetAttribute("ringAtlas")
	self.ringWidth = self:GetAttribute("ringWidth")
	self.ringHeight = self:GetAttribute("ringHeight")
	self.checkedTextureSize = self:GetAttribute("checkedTextureSize")
	self.tooltipYOffset = self:GetAttribute("tooltipYOffset")

	CharCustomizeMaskedButtonMixin.OnLoad(self)
end

function CharCustomizeShapeshiftFormButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeShapeshiftFormButtonMixin:SetCategory(categoryData, selectedCategoryID)
	CharCustomizeCategoryButtonMixin.SetCategory(self, categoryData, selectedCategoryID);

	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end
end

CharCustomizeRidingDrakeButtonMixin = CreateFromMixins(CharCustomizeCategoryButtonMixin);

function CharCustomizeRidingDrakeButtonMixin:OnLoad()
	self.ringAtlas = self:GetAttribute("ringAtlas")
	self.ringWidth = self:GetAttribute("ringWidth")
	self.ringHeight = self:GetAttribute("ringHeight")
	self.checkedTextureSize = self:GetAttribute("checkedTextureSize")
	self.tooltipYOffset = self:GetAttribute("tooltipYOffset")

	CharCustomizeMaskedButtonMixin.OnLoad(self)
end

function CharCustomizeRidingDrakeButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeRidingDrakeButtonMixin:SetCategory(categoryData, selectedCategoryID)
	CharCustomizeCategoryButtonMixin.SetCategory(self, categoryData, selectedCategoryID);
	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end
end

CharCustomizeOptionSelectionFrameMixin = {}

function CharCustomizeOptionSelectionFrameMixin:OnLoad()
	self.parent = self:GetParent()

	self.Background:SetAtlas("charactercreate-customize-dropdownbox")
	self.Highlight:SetAtlas("charactercreate-customize-dropdownbox-open")

	self.IncrementButton:SetNormalAtlas("charactercreate-customize-nextbutton")
	self.IncrementButton:SetPushedAtlas("charactercreate-customize-nextbutton-down")
	self.IncrementButton:SetDisabledAtlas("charactercreate-customize-nextbutton-disabled")

	self.DecrementButton:SetNormalAtlas("charactercreate-customize-backbutton")
	self.DecrementButton:SetPushedAtlas("charactercreate-customize-backbutton-down")
	self.DecrementButton:SetDisabledAtlas("charactercreate-customize-backbutton-disabled")

	local xOffset = self.incrementOffsetX or 4;
	self.IncrementButton:SetPoint("LEFT", self, "RIGHT", xOffset, 0);
	self.IncrementButton:SetScript("OnClick", GenerateClosure(self.OnIncrementClicked, self));

	xOffset = self.decrementOffsetX or -5;
	self.DecrementButton:SetPoint("RIGHT", self, "LEFT", xOffset, 0);
	self.DecrementButton:SetScript("OnClick", GenerateClosure(self.OnDecrementClicked, self));
end

function CharCustomizeOptionSelectionFrameMixin:OnIncrementClicked(button, buttonName, down)
	self:Increment();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CharCustomizeOptionSelectionFrameMixin:OnDecrementClicked(button, buttonName, down)
	self:Decrement();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function CharCustomizeOptionSelectionFrameMixin:OnEnter()
	if self.parent.OnEnter then
		self.parent:OnEnter();
	end
end

function CharCustomizeOptionSelectionFrameMixin:OnLeave()
	if self.parent.OnLeave then
		self.parent:OnLeave();
	end
end

function CharCustomizeOptionSelectionFrameMixin:SetEnabled(enabled)
--	self.DecrementButton:SetEnabled(enabled)
--	self.IncrementButton:SetEnabled(enabled)
end

function CharCustomizeOptionSelectionFrameMixin:Increment()
	C_BarberShop.ScrollCustomizationType(self.categoryID, 1)
end

function CharCustomizeOptionSelectionFrameMixin:Decrement()
	C_BarberShop.ScrollCustomizationType(self.categoryID, -1)
end

CharCustomizeMixin = {}

function CharCustomizeMixin:OnLoad()
--	self.pools = CreateFramePoolCollection();
--	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeShapeshiftFormButtonTemplate");
--	self.pools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeRidingDrakeButtonTemplate");

	self.optionPool = CreateFramePool("BUTTON", self.Options, "CharCustomizeOptionSelectionFrameTemplate");

	-- Keep the altered forms buttons in a different pool because we only want to release those when we enter this screen
	self.alteredFormsPools = CreateFramePoolCollection();
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormButtonTemplate");
	self.alteredFormsPools:CreatePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormSmallButtonTemplate");
end

function CharCustomizeMixin:AttachToParentFrame(parentFrame)
	self.parentFrame = parentFrame;
	self:SetParent(parentFrame);
end

function CharCustomizeMixin:OnButtonClick()
	self.parentFrame:OnButtonClick();
end

function CharCustomizeMixin:Reset()
	self.selectedCategoryData = nil;
end

function CharCustomizeMixin:GetAlteredFormsButtonPool()
	if self.hasShapeshiftForms then
		return self.alteredFormsPools:GetPool("CharCustomizeAlteredFormSmallButtonTemplate");
	else
		return self.alteredFormsPools:GetPool("CharCustomizeAlteredFormButtonTemplate");
	end
end

function CharCustomizeMixin:UpdateAlteredFormButtons()
	self.alteredFormsPools:ReleaseAll();

	local buttonPool = self:GetAlteredFormsButtonPool();
	if self.selectedRaceData.alternateFormRaceData and self.selectedRaceData.alternateFormRaceData.createScreenIconAtlas then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingShapeshiftForm and not self.viewingAlteredForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();

		local alteredForm = buttonPool:Acquire();
		local alteredFormSelected = not self.viewingShapeshiftForm and self.viewingAlteredForm;
		alteredForm:SetupAlteredFormButton(self.selectedRaceData.alternateFormRaceData, alteredFormSelected, true, 0);
		alteredForm:Show();
	elseif self.hasShapeshiftForms then
		local normalForm = buttonPool:Acquire();
		local normalFormSelected = not self.viewingShapeshiftForm;
		normalForm:SetupAlteredFormButton(self.selectedRaceData, normalFormSelected, false, -1);
		normalForm:Show();
	end

	self.AlteredForms:Layout();
end

function CharCustomizeMixin:SetSelectedData(selectedRaceData, selectedSexID, viewingAlteredForm)
	self.selectedRaceData = selectedRaceData;
	self.selectedSexID = selectedSexID;
	self.viewingAlteredForm = viewingAlteredForm;
	self.viewingShapeshiftForm = nil;
	self.viewingChrModelID = nil;
end

function CharCustomizeMixin:SetViewingAlteredForm(viewingAlteredForm, isEventUpdate)
	self.viewingAlteredForm = viewingAlteredForm;

	if self.viewingShapeshiftForm then
		self:ClearViewingShapeshiftForm();
	end

	if self.viewingChrModelID then
		self:ClearViewingChrModel();
	end

	if not isEventUpdate then
		local resetCategory = true;
		local success = self.parentFrame:SetViewingAlteredForm(viewingAlteredForm, resetCategory);
		if not success then
			self.viewingAlteredForm = C_BarberShop.IsViewingAlteredForm()
		end
	end
end

function CharCustomizeMixin:ClearViewingShapeshiftForm()
	local noShapeshiftForm = nil;
	self:SetViewingShapeshiftForm(noShapeshiftForm);
end

function CharCustomizeMixin:SetViewingShapeshiftForm(formID)
	if self.viewingShapeshiftForm ~= formID then
		self.viewingShapeshiftForm = formID;
		self.parentFrame:SetViewingShapeshiftForm(formID);
	end
end

function CharCustomizeMixin:ClearViewingChrModel()
	local noModelID = nil;
	self:SetViewingChrModel(noModelID);
end

function CharCustomizeMixin:SetViewingChrModel(chrModelID)
	if self.viewingChrModelID ~= chrModelID then
		self.viewingChrModelID = chrModelID;
		self.parentFrame:SetViewingChrModel(chrModelID);
	end
end

function CharCustomizeMixin:SetCustomizations(categories, isRandomAvailable)
	self.categories = categories;
	self.isRandomAvailable = isRandomAvailable
	self:SetSelectedCategory();
end

function CharCustomizeMixin:SetEnabledOptionsButtons(state)
	for option in self.optionPool:EnumerateActive() do
		option.DecrementButton:SetEnabled(state)
		option.IncrementButton:SetEnabled(state)
	end
end

function CharCustomizeMixin:SetEnabledAlteredFormsButtons(state)
	for form in self.alteredFormsPools:EnumerateActive() do
		form:SetEnabled(state)
	end
end

function CharCustomizeMixin:UpdateOptionButtons(forceReset)
	self.hasShapeshiftForms = false;
	self.hasChrModels = false;	-- nothing using this right now, tracking it anyway
	self.firstChrModelID = nil;

	self.optionPool:ReleaseAll();

	self.categories = self.categories or C_BarberShop.GetAvailableCustomizations()

	if self.categories.options then
		for index, optionData in ipairs(self.categories.options) do
			local optionFrame = self.optionPool:Acquire();
			-- This is only to guarantee that the frame has a resolvable rect prior to layout. Intended to disappear
			-- in a future version of LayoutFrame.
			optionFrame:SetPoint("TOPLEFT");

			optionFrame.Label:SetText(optionData.name)
			optionFrame.categoryID = optionData.id;

			-- Just set layoutIndex on the option and add it to optionsToSetup for now.
			-- Setup will be called on each one, but it needs to happen after self.Options:Layout() is called
			optionFrame.layoutIndex = index;

			optionFrame:Show();
		end
	end

	self.Options:Layout();

	self:UpdateAlteredFormButtons();

	if self.isRandomAvailable then
		self.RandomizeAppearanceButton:SetPoint("BOTTOMRIGHT", self.Options, "TOPRIGHT", 0, 10);
		self.RandomizeAppearanceButton:Show()
	else
		self.RandomizeAppearanceButton:Hide()
	end
end

function CharCustomizeMixin:SetSelectedCategory(categoryData, keepState)
--	if categoryData.chrModelID then
--		self:SetViewingChrModel(categoryData.chrModelID);
--	elseif categoryData.spellShapeshiftFormID or self.viewingShapeshiftForm then
--		self:SetViewingShapeshiftForm(categoryData.spellShapeshiftFormID);
--	end

	self.selectedCategoryData = categoryData;
	self:UpdateOptionButtons(not keepState);
end

function CharCustomizeMixin:RandomizeAppearance()
	self.parentFrame:RandomizeAppearance();
end

function CharCustomizeMixin:UpdateDressStateButton()
	self.DressStateButton:SetShown(C_BarberShop.CanChangeDressState())
	self.DressStateButton:SetChecked(C_BarberShop.GetDressState())
end

function CharCustomizeMixin:ToggleDressState(button)
	C_BarberShop.ToggleDressState(not C_BarberShop.GetDressState())
end