-- [[ Generic Audio Options Panel ]] --

function AudioOptionsPanel_CheckButton_OnClick (checkButton)
	BlizzardOptionsPanel_CheckButton_OnClick(checkButton);

	if checkButton.restart then
		AudioOptionsFrame_AudioRestart();
	end
end

local function AudioOptionsPanel_RequiresRestartCallback(self, control)
	if control.restart then
		AudioOptionsFrame.audioRestart = true;
	end
end

local function AudioOptionsPanel_RefreshControlCallback(self, control)
	control.oldValue = control.value;
end

local function AudioOptionsPanel_Okay (self)
	BlizzardOptionsPanel_Okay(self, AudioOptionsPanel_RequiresRestartCallback);
end

local function AudioOptionsPanel_Cancel (self)
	BlizzardOptionsPanel_Cancel(self, AudioOptionsPanel_RequiresRestartCallback);
end

local function AudioOptionsPanel_Default (self)
	BlizzardOptionsPanel_Default(self, AudioOptionsPanel_RequiresRestartCallback);
end

local function AudioOptionsPanel_Refresh (self)
	BlizzardOptionsPanel_Refresh(self, AudioOptionsPanel_RefreshControlCallback);
end


-- [[ Sound Options Panel ]] --

SoundPanelOptions = {
	Sound_EnableErrorSpeech = { text = "ENABLE_ERROR_SPEECH" },
	Sound_EnableMusic = { text = "ENABLE_MUSIC" },
	Sound_EnableAmbience = { text = "ENABLE_AMBIENCE" },
	Sound_EnableSFX = { text = "ENABLE_SOUNDFX" },
	Sound_EnableAllSound = { text = "ENABLE_SOUND" },
	Sound_ListenerAtCharacter = { text = "ENABLE_SOUND_AT_CHARACTER" },
	Sound_EnableEmoteSounds = { text = "ENABLE_EMOTE_SOUNDS" },
	Sound_EnablePetSounds = { text = "ENABLE_PET_SOUNDS" },
	Sound_ZoneMusicNoDelay = { text = "ENABLE_MUSIC_LOOPING" },
	Sound_EnableSoundWhenGameIsInBG = { text = "ENABLE_BGSOUND" },
	Sound_EnableReverb = { text = "ENABLE_REVERB" },
	Sound_EnableHardware = { text = "ENABLE_HARDWARE" },
	Sound_EnableSoftwareHRTF = { text = "ENABLE_SOFTWARE_HRTF" },
	Sound_EnableDSPEffects = { text = "ENABLE_DSP_EFFECTS" },
	Sound_SFXVolume = { text = "SOUND_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.001, },
	Sound_MusicVolume = { text = "MUSIC_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.001, },
	Sound_AmbienceVolume = { text = "AMBIENCE_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.001, },
	Sound_MasterVolume = { text = "MASTER_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.001, },
	Sound_NumChannels = { text = "SOUND_CHANNELS", minValue = 32, maxValue = 64, valueStep = 32, },
	Sound_OutputQuality = { text = "SOUND_QUALITY", minValue = 0, maxValue = 2, valueStep = 1 },
}

function AudioOptionsSoundPanel_OnLoad (self)
	self.name = SOUND_LABEL;
	self.options = SoundPanelOptions;
	BlizzardOptionsPanel_OnLoad(self, AudioOptionsPanel_Okay, AudioOptionsPanel_Cancel, AudioOptionsPanel_Default, AudioOptionsPanel_Refresh);
	OptionsFrame_AddCategory(AudioOptionsFrame, self);
end

function AudioOptionsSoundPanelHardwareDropDown_OnLoad (self)
	self.cvar = "Sound_OutputDriverIndex";

	local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
	local deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(selectedDriverIndex);
	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = selectedDriverIndex;
	self.restart = true;

	UIDropDownMenu_SetWidth(self, 136);
	UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
	UIDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);

	self.SetValue = function (self, value)
		self.newValue = value;
		BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
	end

	self.GetValue = function (self)
		return self.newValue or self.value;
	end

	self.RefreshValue = function (self)
		local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		local deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(selectedDriverIndex);
		self.newValue = selectedDriverIndex;

		UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
		UIDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);
	end
end

function AudioOptionsSoundPanelHardwareDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local num = Sound_GameSystem_GetNumOutputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		info.text = Sound_GameSystem_GetOutputDriverNameByIndex(index);
		info.value = index;
		info.checked = nil;
		if (selectedValue and index == selectedValue) then
			UIDropDownMenu_SetText(self, info.text);
			info.checked = 1;
		else
			info.checked = nil;
		end
		info.func = AudioOptionsSoundPanelHardwareDropDown_OnClick;

		UIDropDownMenu_AddButton(info);
	end
end

function AudioOptionsSoundPanelHardwareDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsSoundPanelHardwareDropDown;
	UIDropDownMenu_SetSelectedValue(dropdown, value);

	local prevValue = dropdown:GetValue();
	dropdown:SetValue(value);
	if ( dropdown.restart and prevValue ~= value ) then
		AudioOptionsFrame_AudioRestart();
	end
end