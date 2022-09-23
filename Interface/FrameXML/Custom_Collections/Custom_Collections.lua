--	Filename:	Sirus_Collections.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

UIPanelWindows["CollectionsJournal"] = { area = "left",	pushable = 0, whileDead = 1, xOffset = "15", yOffset = "-10", width = 703, height = 606 }

local tutorialPointer;

function CollectionsJournal_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	C_CVar:SetValue("C_CVAR_PET_JOURNAL_TAB", tostring(tab));
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_GetTab(self)
	return PanelTemplates_GetSelectedTab(self);
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selected = CollectionsJournal_GetTab(self);

	MountJournal:SetShown(selected == 1);
	PetJournal:SetShown(selected == 2);
	WardrobeCollectionFrame:SetShown(selected == 3);
	ToyBox:SetShown(selected == 4);
	-- don't touch the wardrobe frame if it's used by the transmogrifier
	if WardrobeCollectionFrame:GetParent() == self or not WardrobeCollectionFrame:GetParent():IsShown() then
		if selected == 3 then
			HideUIPanel(WardrobeFrame);
			WardrobeCollectionFrame:SetContainer(self);
		else
			WardrobeCollectionFrame:Hide();
		end
	end

	if selected == 1 then
		CollectionsJournalTitleText:SetText(MOUNTS);
	elseif selected == 2 then
		CollectionsJournalTitleText:SetText(PETS);
	elseif selected == 3 then
		CollectionsJournalTitleText:SetText(WARDROBE);
	elseif selected == 4 then
		CollectionsJournalTitleText:SetText(TOY_BOX);
	end

	local tutorialTab = CollectionsMicroButton.TutorialFrameTab;
	if tutorialTab and self:IsShown() then
		if CollectionsMicroButton.TutorialFrame then
			NPE_TutorialPointerFrame:Hide(CollectionsMicroButton.TutorialFrame);
			CollectionsMicroButton.TutorialFrame = nil;
		end
		if tutorialPointer then
			NPE_TutorialPointerFrame:Hide(tutorialPointer);
			tutorialPointer = nil;
		end

		if tutorialTab == 1 and not NPE_TutorialPointerFrame:GetKey("CollectionsJournal_Mount") then
			if selected == 1 then
				NPE_TutorialPointerFrame:SetKey("CollectionsJournal_Mount", true);
			else
				tutorialPointer = NPE_TutorialPointerFrame:Show(COLLECTIONS_JOURNAL_TUTORIAL_MOUNT_1, "RIGHT", CollectionsJournalTab1, 0, 0);
			end
		elseif tutorialTab == 2 and not NPE_TutorialPointerFrame:GetKey("CollectionsJournal_Pet") then
			if selected == 2 then
				NPE_TutorialPointerFrame:SetKey("CollectionsJournal_Pet", true);
			else
				tutorialPointer = NPE_TutorialPointerFrame:Show(COLLECTIONS_JOURNAL_TUTORIAL_PET_1, "RIGHT", CollectionsJournalTab2, 0, 0);
			end
		elseif tutorialTab == 4 and not NPE_TutorialPointerFrame:GetKey("CollectionsJournal_Toy") then
			if selected == 4 then
				NPE_TutorialPointerFrame:SetKey("CollectionsJournal_Toy", true);
			else
				tutorialPointer = NPE_TutorialPointerFrame:Show(COLLECTIONS_JOURNAL_TUTORIAL_TOY_1, "RIGHT", CollectionsJournalTab4, 0, 0);
			end
		end
	end
end

function CollectionsJournal_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	PanelTemplates_SetNumTabs(self, 4);
end

function CollectionsJournal_OnEvent(self, event)
	if event == "VARIABLES_LOADED" then
		PanelTemplates_SetTab(self, tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_TAB")) or 1);
	end
end

function CollectionsJournal_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();
	MicroButtonPulseStop(CollectionsMicroButton);
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end