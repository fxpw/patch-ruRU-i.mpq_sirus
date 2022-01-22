--	Filename:	GameMenuFrame.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

function GameMenuFrame_OnShow(self)
	UpdateMicroButtons();
	Disable_BagButtons();
	VoiceChat_Toggle();

	if IsStoreEnable() then
		GameMenuButtonStore:SetText(GAMEMENU_STORE)
	end

	GameMenuButtonStore:SetEnabled(IsStoreEnable())

	GameMenuFrame_UpdateVisibleButtons(self);
end

function GameMenuFrame_UpdateVisibleButtons(self)
	local height = 314;
	GameMenuButtonUIOptions:SetPoint("TOP", GameMenuButtonAudioOptions, "BOTTOM", 0, -1);

	local buttonToReanchor = GameMenuButtonWhatsNew;
	local reanchorYOffset = -1;

	if ( true ) then
		GameMenuButtonWhatsNew:Hide();
		height = height - 20;
		buttonToReanchor = GameMenuButtonOptions;
		reanchorYOffset = -16;
	else
		GameMenuButtonWhatsNew:Show();
		GameMenuButtonOptions:SetPoint("TOP", GameMenuButtonWhatsNew, "BOTTOM", 0, -16);
	end

	height = height + 20;
	GameMenuButtonStore:Show();
	buttonToReanchor:SetPoint("TOP", GameMenuButtonPromoCodes, "BOTTOM", 0, reanchorYOffset);

	-- if ( not GameMenuButtonRatings:IsShown() and GetNumAddOns() == 0 ) then
	-- 	GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -16);
	-- else
	-- 	if ( GetNumAddOns() ~= 0 ) then
	-- 		height = height + 20;
	-- 		GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -16);
	-- 	end

	-- 	if ( GameMenuButtonRatings:IsShown() ) then
	-- 		height = height + 20;
	-- 		GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonRatings, "BOTTOM", 0, -16);
	-- 	end
	-- end

	GameMenuButtonLogout:SetPoint("TOP", GameMenuButtonMacros, "BOTTOM", 0, -16);

	height = height + 20
	self:SetHeight(height);
end