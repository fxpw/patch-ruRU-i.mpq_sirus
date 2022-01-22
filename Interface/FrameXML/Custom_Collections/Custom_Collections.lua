--	Filename:	Sirus_Collections.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

UIPanelWindows["CollectionsJournal"] = { area = "left",	pushable = 0, whileDead = 1, xOffset = "15", yOffset = "-10", width = 703, height = 606 }

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
	end
end

function CollectionsJournal_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");

	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	PanelTemplates_SetNumTabs(self, 3);
end

function CollectionsJournal_OnEvent(self, event)
	if event == "VARIABLES_LOADED" then
		PanelTemplates_SetTab(self, tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_TAB")) or 1);
	end
end

function CollectionsJournal_OnShow(self)
	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();
	CollectionsJournal_UpdateSelectedTab(self);
end

function CollectionsJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end