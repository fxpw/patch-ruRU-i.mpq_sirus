--	Filename:	OptionsSelect.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

function OptionsSelectFrame_OnLoad(self)
	self.Container.Background:SetVertexColor(0.9, 0.9, 0.9)
	self.Container.BottomShadow:SetVertexColor(0, 0, 0, 0.3)
end

function OptionsSelectFrame_Hide()
	PlaySound("gsLoginChangeRealmCancel");
	OptionsSelectFrame:Hide();
end

function OptionsSelectFrame_OnKeyDown(self, key)
	if key == "ESCAPE" then
		OptionsSelectFrame_Hide()
	elseif key == "PRINTSCREEN" then
		Screenshot()
	end
end

function OptionsSelectFrame_VideoOptionsButton_OnClick()
	PlaySound("igMainMenuOption")
	VideoOptionsFrame.lastFrame = OptionsSelectFrame
	VideoOptionsFrame:Show()
end

function OptionsSelectFrame_AudioOptionsButton_OnClick()
	PlaySound("igMainMenuOption")
	AudioOptionsFrame.lastFrame = OptionsSelectFrame
	AudioOptionsFrame:Show()
end

function OptionsSelectResetSettingsButton_OnClick_Reset(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	GlueDialog:ShowDialog("RESET_SERVER_SETTINGS");
end

function OptionsSelectResetSettingsButton_OnClick_Cancel(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	GlueDialog:ShowDialog("CANCEL_RESET_SETTINGS");
end
