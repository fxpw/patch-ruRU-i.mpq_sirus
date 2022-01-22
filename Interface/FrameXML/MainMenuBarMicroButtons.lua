function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	local prefix = "Interface\\Buttons\\UI-MicroButton-";
	self:SetNormalTexture(prefix..name.."-Up");
	self:SetPushedTexture(prefix..name.."-Down");
	self:SetDisabledTexture(prefix..name.."-Disabled");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
end

function MicroButtonTooltipText(text, action)
	if not action then
		return ""
	end

	if ( GetBindingKey(action) ) then
		return text.." "..NORMAL_FONT_COLOR_CODE.."("..GetBindingText(GetBindingKey(action), "KEY_")..")"..FONT_COLOR_CODE_CLOSE;
	else
		return text;
	end

end

function UpdateMicroButtons()
	local unitRace 		= UnitRace("player")
	local raceInfo 		= C_CreatureInfo.GetRaceInfo(unitRace)
	local isNeutral 	= raceInfo.raceID == E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL

	local playerLevel = UnitLevel("player");

	if ( CharacterFrame:IsShown() ) then
		CharacterMicroButton:SetButtonState("PUSHED", 1);
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton:SetButtonState("NORMAL");
		CharacterMicroButton_SetNormal();
	end

	if ( SpellBookFrame:IsShown() ) then
		SpellbookMicroButton:SetButtonState("PUSHED", 1);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

	if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() ) then
		TalentMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( playerLevel < TalentMicroButton.minLevel ) then
			TalentMicroButton:Disable();
		else
			TalentMicroButton:Enable();
			TalentMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( StoreFrame:IsShown() ) then
		StoreMicroButton:SetButtonState("PUSHED", 1);
	else
		StoreMicroButton:SetButtonState("NORMAL");
	end

	StoreMicroButton:SetEnabled(IsStoreEnable())
	if IsStoreEnable() then
		StoreMicroButton:SetAlpha(1)
	else
		StoreMicroButton:SetAlpha(0.5)
	end

	if ( QuestLogFrame:IsShown() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", 1);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end

	if ( ( GameMenuFrame:IsShown() )
		or ( InterfaceOptionsFrame:IsShown())
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", 1);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	if ( PVPUIFrame:IsShown() and (not PVPFrame_IsJustBG())) or (LFDParentFrame:IsShown()) or PVPLadderFrame:IsShown() or RenegadeLadderFrame:IsShown() then
		LFDMicroButtonAlert:Hide()
		LFDMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( playerLevel < LFDMicroButton.minLevel or isNeutral ) then
			LFDMicroButton.DisableReason = isNeutral and NEUTRAL_RACE_DISABLE_FEATURE
			LFDMicroButton:Disable();
		else
			LFDMicroButton:Enable();
			LFDMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( FriendsFrame:IsShown() ) then
		SocialsMicroButton:SetButtonState("PUSHED", 1);
	else
		SocialsMicroButton:SetButtonState("NORMAL");
	end

	if ( ( GuildFrame and GuildFrame:IsShown() ) or ( LookingForGuildFrame and LookingForGuildFrame:IsShown() ) ) then
		GuildMicroButton:SetButtonState("PUSHED", 1);
		GuildMicroButtonTabard:SetPoint("TOPLEFT", -1, -2)
		GuildMicroButtonTabard:SetAlpha(0.70)
	else
		if ( IsInGuild() ) then
			if GetGuildXP() and GetGuildReputation() and GetGuildNumPerks() > 0 and GetGuildNumRewards() > 0 then
				GuildMicroButton:Enable()
				GuildMicroButton.Spinner:Hide()
				GuildMicroButton:SetButtonState("NORMAL");
				GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, 0)
				GuildMicroButtonTabard:SetAlpha(1)
			else
				GuildMicroButton.Spinner:Show()
			end

			GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
			GuildMicroButton.newbieText = NEWBIE_TOOLTIP_GUILDTAB
		else
			GuildMicroButton:SetButtonState("NORMAL")
			GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, 0)
			GuildMicroButtonTabard:SetAlpha(1)
			GuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
			GuildMicroButton.newbieText = NEWBIE_TOOLTIP_LOOKINGFORGUILDTAB
		end
	end

	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		AchievementMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( HasCompletedAnyAchievement() and CanShowAchievementUI() ) then
			AchievementMicroButton:Enable();
			AchievementMicroButton:SetButtonState("NORMAL");
		else
			AchievementMicroButton:Disable();
		end
	end

	-- Keyring microbutton
	if ( IsBagOpen(KEYRING_CONTAINER) ) then
		KeyRingButton:SetButtonState("PUSHED", 1);
	else
		KeyRingButton:SetButtonState("NORMAL");
	end

	if ( CollectionsJournal:IsShown() ) then
		CollectionsMicroButton:SetButtonState("PUSHED", 1);
	else
		CollectionsMicroButton:SetButtonState("NORMAL");
	end

	if ( EncounterJournal:IsShown() ) then
		EncounterJournalMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( isNeutral ) then
			EncounterJournalMicroButton.DisableReason = NEUTRAL_RACE_DISABLE_FEATURE
			EncounterJournalMicroButton:Disable()
		else
			EncounterJournalMicroButton:Enable()
			EncounterJournalMicroButton:SetButtonState("NORMAL")
		end
	end

	-- EncounterJournalMicroButton:Disable()
end

function MicroButtonPulse(self, duration)
	UIFrameFlash(self.Flash, 1.0, 1.0, duration or -1, false, 0, 0, "microbutton");
end

function MicroButtonPulseStop(self)
	UIFrameFlashStop(self.Flash);
end

function AchievementMicroButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		AchievementMicroButton.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	else
		UpdateMicroButtons();
	end
end

function GuildMicroButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		if ( IsInGuild() ) then
			self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB");
		else
			self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB");
		end
	elseif ( event == "PLAYER_GUILD_UPDATE" ) then
		UpdateMicroButtons();
	end
end

function CharacterMicroButton_OnLoad(self)
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up");
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER;
end

function CharacterMicroButton_OnEvent(self, event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SetPortraitTexture(MicroButtonPortrait, unit);
		end
		return;
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		SetPortraitTexture(MicroButtonPortrait, "player");
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	elseif event == "PLAYER_LEVEL_UP" then
		local level = ...

		if not LFDMicroButton:IsShown() or not LFDMicroButton:IsVisible() then
			return
		end

		if level == 10 then
			LFDMicroButtonAlert.Text:SetText(MICRO_MENU_LFD_ALERT1)
			LFDMicroButtonAlert:Show()
		elseif level == 15 then
			LFDMicroButtonAlert.Text:SetText(MICRO_MENU_LFD_ALERT2)
			LFDMicroButtonAlert:Show()
		end
	end
end

function CharacterMicroButton_SetPushed()
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
end

function CharacterMicroButton_SetNormal()
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", 1);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
end

--Talent button specific functions
function TalentMicroButton_OnEvent(self, event, ...)
	if ( event == "PLAYER_LEVEL_UP" ) then
		local level = ...;
		UpdateMicroButtons();
		if ( not CharacterFrame:IsShown() and level >= SHOW_TALENT_LEVEL) then
			SetButtonPulse(self, 60, 1);
		end
	elseif ( event == "UNIT_LEVEL" or event == "PLAYER_ENTERING_WORLD" ) then
		UpdateMicroButtons();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

--Micro Button alerts
function MicroButtonAlert_SetText(self, text)
	self.Text:SetText(text or "")
end

function MicroButtonAlert_OnLoad(self)
	if self.MicroButton then
		self:SetPoint("BOTTOM", self.MicroButton, "TOP", 0, 0)
	end
	self.Text:SetSpacing(4)
	MicroButtonAlert_SetText(self, self.label)
end

function MicroButtonAlert_OnShow(self)
	self:SetHeight(self.Text:GetHeight() + 42)
end

function MicroButtonAlert_OnHide(self)
	-- g_visibleMicroButtonAlerts[self] = nil;
	-- MainMenuMicroButton_UpdateAlertsEnabled(self)
end

function MicroButtonAlert_CreateAlert(parent, tutorialIndex, text, anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)
	local alert = CreateFrame("Frame", nil, parent, "MicroButtonAlertTemplate")
	alert.tutorialIndex = tutorialIndex

	alert:SetPoint(anchorPoint, anchorRelativeTo, anchorRelativePoint, anchorOffsetX, anchorOffsetY)

	MicroButtonAlert_SetText(alert, text)
	return alert
end

Hook:RegisterCallback("MICRO_BUTTONS", "SERVICE_DATA_RECEIVED", UpdateMicroButtons)