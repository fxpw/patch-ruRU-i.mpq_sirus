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

local titles = {
	[1] = MOUNTS,
	[2] = PETS,
	[3] = WARDROBE,
	[4] = TOY_BOX,
	[5] = HEIRLOOMS,
};

local function GetTitleText(titleIndex)
	return titles[titleIndex] or "";
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selected = CollectionsJournal_GetTab(self);

	MountJournal:SetShown(selected == 1);
	PetJournal:SetShown(selected == 2);
	WardrobeCollectionFrame:SetShown(selected == 3);
	ToyBox:SetShown(selected == 4);
	HeirloomsJournal:SetShown(selected == 5);
	-- don't touch the wardrobe frame if it's used by the transmogrifier
	if WardrobeCollectionFrame:GetParent() == self or not WardrobeCollectionFrame:GetParent():IsShown() then
		if selected == 3 then
			HideUIPanel(WardrobeFrame);
			WardrobeCollectionFrame:SetContainer(self);
		else
			WardrobeCollectionFrame:Hide();
		end
	end

	CollectionsJournalTitleText:SetText(GetTitleText(selected));

	EventRegistry:TriggerEvent("CollectionsJournal.SetTab", selected)
end

function CollectionsJournal_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	PanelTemplates_SetNumTabs(self, 5);
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
	EventRegistry:TriggerEvent("CollectionsJournal.OnShow")
end

function CollectionsJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	EventRegistry:TriggerEvent("CollectionsJournal.OnHide")
end