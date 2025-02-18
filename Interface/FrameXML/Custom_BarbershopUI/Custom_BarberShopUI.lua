BarberShopMixin = CreateFromMixins(CharCustomizeParentFrameBaseMixin);

function BarberShopMixin:OnLoad()
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_ENTER")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_EXIT")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_MODE_CHANGED")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_AWAIT")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_READY")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_MODEL_AWAIT")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_MODEL_READY")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_APPEARANCE_APPLIED")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_UPDATE_DRESSROOM")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE")
	self:RegisterCustomEvent("CUSTOM_BARBER_SHOP_PRICE_CHANGED")

	self.TopBackgroundOverlay:SetAtlas("charactercreate-vignette-top")
	self.LeftBackgroundOverlay:SetAtlas("charactercreate-vignette-sides")
	self.RightBackgroundOverlay:SetAtlas("charactercreate-vignette-sides")
	self.RightBackgroundOverlay:SetSubTexCoord(1, 0, 0, 1)

	self.PriceFrame:SetScale(1.5)

	CharCustomizeFrame:AttachToParentFrame(self);

	self.retainedFrames = {}
	self.specialPopupFrames = {}

	hooksecurefunc("StaticPopupSpecial_Show", function(frame)
		self.specialPopupFrames[frame] = true
		if self:IsShown() then
			self:AddOverlayFrame(frame)
		end
	end)
end

function BarberShopMixin:SetScale(scale)
	CharCustomizeFrame:SetScale(scale)
end

function BarberShopMixin:OnEvent(event, ...)
	if event == "CUSTOM_BARBER_SHOP_ENTER" then
		local isRandomAvailable = ...
		self.isRandomAvailable = isRandomAvailable

		ShowUIPanel(self, true)
	elseif event == "CUSTOM_BARBER_SHOP_EXIT" then
		if self:IsVisible() then
			HideUIPanel(self)
		end
	elseif event == "CUSTOM_BARBER_SHOP_MODE_CHANGED" then
		CharCustomizeFrame:UpdateDressStateButton()
		CharCustomizeFrame:SetViewingAlteredForm(C_BarberShop.IsViewingAlteredForm(), true)
		CharCustomizeFrame:UpdateAlteredFormButtons()
	elseif event == "CUSTOM_BARBER_SHOP_AWAIT" then
	--	CharCustomizeFrame:SetEnabledOptionsButtons(false)
	elseif event == "CUSTOM_BARBER_SHOP_MODEL_AWAIT" then
		CharCustomizeFrame:SetEnabledAlteredFormsButtons(false)
	elseif event == "CUSTOM_BARBER_SHOP_READY" then
	--	CharCustomizeFrame:SetEnabledOptionsButtons(true)
	elseif event == "CUSTOM_BARBER_SHOP_MODEL_READY" then
		CharCustomizeFrame:SetEnabledAlteredFormsButtons(true)
	elseif event == "CUSTOM_BARBER_SHOP_APPEARANCE_APPLIED" then
		self:Cancel();
		PlaySound(SOUNDKIT.BARBERSHOP_HAIRCUT);
	elseif event == "CUSTOM_BARBER_SHOP_UPDATE_DRESSROOM" then
		self:UpdateButtons();
	elseif event == "CUSTOM_BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE" then
		self:UpdateCharCustomizationFrame();
	elseif event == "CUSTOM_BARBER_SHOP_PRICE_CHANGED" then
		self:UpdateButtons();
	end
end

function BarberShopMixin:AddOverlayFrame(frame)
	self.retainedFrames[frame] = {frame:GetParent(), frame:GetFrameStrata()}
	frame:SetParent(self.OverlayFrameHolder)
end

function BarberShopMixin:RestoreOverlayFrames()
	for frame, info in pairs(self.retainedFrames) do
		frame:SetParent(info[1])
		frame:SetFrameStrata(info[2])
		self.retainedFrames[frame] = nil
	end
end

function BarberShopMixin:OnShow()
	self.OverlayFrameHolder:SetScale(UIParent:GetScale())

	self.oldErrorFramePointInfo = {UIErrorsFrame:GetPoint(1)};

	UIErrorsFrame:SetParent(self.OverlayFrameHolder);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:ClearAllPoints();
	UIErrorsFrame:SetPoint("TOP", 0, -100);
	UIErrorsFrame:Clear()

	self:AddOverlayFrame(ActionStatus)
	self:AddOverlayFrame(StaticPopup1)
	self:AddOverlayFrame(StaticPopup2)
	self:AddOverlayFrame(StaticPopup3)
	self:AddOverlayFrame(StaticPopup4)

	for frame in pairs(self.specialPopupFrames) do
		if frame:IsShown() then
			self:AddOverlayFrame(frame)
		end
	end

	local currentCharacterData = C_BarberShop.GetCurrentCharacterData();
	if currentCharacterData then
		CharCustomizeFrame:SetSelectedData(currentCharacterData.raceData, currentCharacterData.sex, C_BarberShop.IsViewingAlteredForm());
	end

	local reset = true;
	self:UpdateCharCustomizationFrame(reset);

	PlaySound(SOUNDKIT.BARBERSHOP_SIT);
end

function BarberShopMixin:OnHide()
	UIErrorsFrame:SetParent(UIParent);
	UIErrorsFrame:SetFrameStrata("DIALOG");
	UIErrorsFrame:ClearAllPoints();
	UIErrorsFrame:SetPoint(unpack(self.oldErrorFramePointInfo));

	self:RestoreOverlayFrames()
end

function BarberShopMixin:OnKeyDown(key)
	local keybind = GetBindingFromClick(key);
	if key == "ESCAPE" then
		C_BarberShop.Cancel();
	elseif keybind == "TOGGLEMUSIC" or keybind == "TOGGLESOUND" or keybind == "SCREENSHOT" then
		RunBinding(keybind);
	end
end

function BarberShopMixin:Cancel()
	HideUIPanel(self);
	C_BarberShop.Cancel();
end

function BarberShopMixin:Reset()
	C_BarberShop.ResetCustomizationChoices();
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:ApplyChanges()
	C_BarberShop.ApplyCustomizationChoices();
end

function BarberShopMixin:UpdateButtons()
	local currentCost = C_BarberShop.GetCurrentCost();
	local hasEnoughMoney = currentCost <= 0 or GetMoney() >= currentCost;
	local copperCost = currentCost % 100;
	if copperCost > 0 then
		-- Round any copper cost up to the next silver
		currentCost = currentCost - copperCost + 100;
	end

	self.PriceFrame:SetAmount(currentCost);

	local hasAnyChanges = C_BarberShop.HasAnyChanges();
	self.AcceptButton:SetEnabled(hasAnyChanges and hasEnoughMoney);
	self.ResetButton:SetEnabled(hasAnyChanges and C_BarberShop.IsResetAvailable());
end

function BarberShopMixin:UpdateCharCustomizationFrame(alsoReset)
	local customizationCategoryData = C_BarberShop.GetAvailableCustomizations();
	if not customizationCategoryData then
		-- This means we are calling GetAvailableCustomizations when there is no character component set up. Do nothing
		return;
	end

	if alsoReset then
		CharCustomizeFrame:Reset();
	end

	CharCustomizeFrame:SetCustomizations(customizationCategoryData, self.isRandomAvailable);

	self:UpdateButtons();
end

function BarberShopMixin:SetCustomizationChoice(optionID, choiceID)
	C_BarberShop.SetCustomizationChoice(optionID, choiceID);

	-- When a customization choice is made, that may force other options to change (if the current choices are no longer valid)
	-- So grab all the latest data and update CharCustomizationFrame
	self:UpdateCharCustomizationFrame();
end

function BarberShopMixin:SetViewingAlteredForm(viewingAlteredForm, resetCategory)
	local success = C_BarberShop.SetViewingAlteredForm(viewingAlteredForm);
--	self:UpdateCharCustomizationFrame(resetCategory);
	return success
end

function BarberShopMixin:SetViewingShapeshiftForm(formID)
	C_BarberShop.SetViewingShapeshiftForm(formID);
end

function BarberShopMixin:SetViewingChrModel(chrModelID)
	C_BarberShop.SetViewingChrModel(chrModelID);
end

function BarberShopMixin:RandomizeAppearance()
	C_BarberShop.RandomizeCustomizationChoices();
	self:UpdateCharCustomizationFrame();
end

BarberShopButtonMixin = {};

function BarberShopButtonMixin:OnLoad()
	self.barberShopOnClickMethod = self:GetAttribute("barberShopOnClickMethod")
	self.barberShopFunction = self:GetAttribute("barberShopFunction")
end

function BarberShopButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if self.barberShopOnClickMethod then
		CustomBarberShopFrame[self.barberShopOnClickMethod](CustomBarberShopFrame);
	elseif self.barberShopFunction then
		C_BarberShop[self.barberShopFunction]();
	end
end