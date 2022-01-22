ALLIEDRACES_DATA = {
	[E_CHARACTER_RACES.RACE_NIGHTBORNE] = { -- Nightborne
		maleModelID = 70170,
		femaleModelID = 70171,
		maleName = RACE_NIGHTBORNE,
		femaleName = RACE_NIGHTBORNE_FEMALE,
		crestAtlas = "AlliedRace-Crest-Nightborne",
		modelBackgroundAtlas = "AlliedRace-UnlockingFrame-ModelBackground-Nightborne",
		raceFileString = "Nightborne",
		bannerColor = {r = 0.77, g = 0.54, b = 1},
		allDisplayInfo = {316423, 316425, 316428, 316430, 316431, 316432},
	},
	[E_CHARACTER_RACES.RACE_VOIDELF] = { -- Voidelf
		maleModelID = 70172,
		femaleModelID = 70173,
		maleName = RACE_VOIDELF,
		femaleName = RACE_VOIDELF_FEMALE,
		crestAtlas = "AlliedRace-Crest-Voidelf",
		modelBackgroundAtlas = "AlliedRace-UnlockingFrame-ModelBackground-Voidelf",
		raceFileString = "VoidElf",
		bannerColor = {r = 0.50, g = 0.01, b = 0.71},
		allDisplayInfo = {316358, 316360, 316363, 316366, 316367, 316368},
	},
	[E_CHARACTER_RACES.RACE_EREDAR] = { -- Eredar
		maleModelID = 81753,
		femaleModelID = 81754,
		maleName = RACE_EREDAR,
		femaleName = RACE_EREDAR_FEMALE,
		crestAtlas = "AlliedRace-Crest-Eredar",
		modelBackgroundAtlas = "AlliedRace-UnlockingFrame-ModelBackground-Eredar",
		raceFileString = "Eredar",
		bannerColor = {r = 0.08, g = 0.71, b = 0.10},
		allDisplayInfo = {316458, 316459, 316461, 316464, 316465, 316466},
	},
	[E_CHARACTER_RACES.RACE_DARKIRONDWARF] = { -- DarkIronDwarf
		maleModelID = 81751,
		femaleModelID = 81752,
		maleName = RACE_DARKIRONDWARF,
		femaleName = RACE_DARKIRONDWARF_FEMALE,
		crestAtlas = "AlliedRace-Crest-DarkIronDwarf",
		modelBackgroundAtlas = "AlliedRace-UnlockingFrame-ModelBackground-DarkIronDwarf",
		raceFileString = "DarkIronDwarf",
		bannerColor = {r = 1, g = 0.54, b = 0},
		allDisplayInfo = {316152, 316153, 316157, 316160, 316161, 316162},
	},
}

C_AlliedRaces = {}

function C_AlliedRaces.GetAllRacialAbilitiesFromID(raceID)
	return ALLIEDRACES_DATA[raceID] and ALLIEDRACES_DATA[raceID].allDisplayInfo
end

function C_AlliedRaces.GetRaceInfoByID(raceID)
	return ALLIEDRACES_DATA[raceID]
end

UIPanelWindows["AlliedRacesFrame"] = { area = "left", pushable = 1, whileDead = 1, xOffset = "15", yOffset = "-10" };

AlliedRacesFrameMixin = { };

function AlliedRacesFrameMixin:UpdatedBannerColor(bannerColor)
	self.Banner:SetVertexColor(bannerColor.r, bannerColor.g, bannerColor.b);
end

function AlliedRacesFrameMixin:SetFrameText(name, description)
	self.TitleText:SetText(name);
	self.RaceInfoFrame.AlliedRacesRaceName:SetText(name);
	self.RaceInfoFrame.ScrollFrame.Child.RaceDescriptionText:SetText(description);
end

function AlliedRacesFrameMixin:SetupAbilityPool(index, spellID)
	local name, rank, icon = GetSpellInfo(spellID);
	local childFrame = self.RaceInfoFrame.ScrollFrame.Child;
	local abilityButton = self.abilityPool:Acquire();

	if (index == 1) then
		abilityButton:SetPoint("TOPLEFT", childFrame.RacialTraitsLabel, "BOTTOMLEFT", -7, -19);
	else
		abilityButton:SetPoint("TOP", self.lastAbility, "BOTTOM", 0, -9);
	end

	local spellType = string.match(rank, "%(?(P[Vv][EP])%)?$");
	abilityButton.Text:ClearAllPoints();
	if (spellType) then
		abilityButton.Text:SetPoint("TOPLEFT", abilityButton.Icon, "TOPRIGHT", 10, 0);
		abilityButton.RankText:SetText(spellType);
	else
		abilityButton.Text:SetPoint("LEFT", abilityButton.Icon, "RIGHT", 10, 0);
		abilityButton.RankText:SetText("");
	end
	abilityButton.Text:SetText(name);
	abilityButton.Icon:SetTexture(icon);
	abilityButton.spellID = spellID;
	abilityButton:Show();

	return abilityButton;
end

function AlliedRacesFrameMixin:RacialAbilitiesData(raceID)
	local racialAbilities = C_AlliedRaces.GetAllRacialAbilitiesFromID(raceID);
	if (not racialAbilities) then
		return;
	end

	self.abilityPool:ReleaseAll();
	for i, spellID in ipairs(racialAbilities) do
		self.lastAbility = self:SetupAbilityPool(i, spellID);
	end
end

function AlliedRacesFrameMixin:LoadRaceData(raceID)
	local raceInfo = C_AlliedRaces.GetRaceInfoByID(raceID);
	if (not raceInfo) then
		return;
	end

	self.raceID = raceID;
	self:SetModelFrameBackground(raceInfo.modelBackgroundAtlas);
	if (UnitSex("player") == 2) then
		self:SetRaceNameForGender("male");
		self:UpdateModel(raceInfo.maleModelID);
		self.ModelFrame.AlliedRacesMaleButton:SetChecked(true);
		self.ModelFrame.AlliedRacesFemaleButton:SetChecked(false);
	else
		self:SetRaceNameForGender("female");
		self:UpdateModel(raceInfo.femaleModelID);
		self.ModelFrame.AlliedRacesMaleButton:SetChecked(false);
		self.ModelFrame.AlliedRacesFemaleButton:SetChecked(true);
	end
	self.ModelFrame.AlliedRacesFemaleButton.FemaleModelID = raceInfo.femaleModelID;
	self.ModelFrame.AlliedRacesFemaleButton.raceName = raceInfo.femaleName;
	self.ModelFrame.AlliedRacesMaleButton.MaleModelID = raceInfo.maleModelID;
	self.ModelFrame.AlliedRacesFemaleButton.raceName = raceInfo.maleName;

	self.portrait:SetAtlas(raceInfo.crestAtlas);
	self:UpdatedBannerColor(raceInfo.bannerColor);
	self:RacialAbilitiesData(raceID);
end

function AlliedRacesFrameMixin:SetRaceNameForGender(gender)
	local raceInfo = C_AlliedRaces.GetRaceInfoByID(self.raceID);
	if not raceInfo then
		return;
	end

	local raceName;
	if gender == "female" then
		raceName = raceInfo.femaleName;
	else
		raceName = raceInfo.maleName;
	end

	local fileString = raceInfo.raceFileString;
	fileString = strupper(fileString);

	self:SetFrameText(raceName, _G["RACE_INFO_"..fileString]);
end

function AlliedRacesFrameMixin:SetModelFrameBackground(backgroundAtlas)
	self.ModelFrame.ModelBackground:SetAtlas(backgroundAtlas, true);
end

function AlliedRacesFrameMixin:UpdateModel(modelID)
	self.ModelFrame:SetPosition(0, 0, 0);
	self.ModelFrame.zoomLevel = self.ModelFrame.minZoom;
	self.ModelFrame.modelID = modelID;
	self:SetScript("OnUpdate", self.SetCreatureDelayed);
end

function AlliedRacesFrameMixin:SetCreatureDelayed()
	self.ModelFrame:SetCreature(self.ModelFrame.modelID);
	self:SetScript("OnUpdate", nil);
end

function AlliedRacesFrameMixin:OnLoad()
	self:RegisterEventListener();

	self.abilityPool = CreateFramePool("Button", self.RaceInfoFrame.ScrollFrame.Child, "AlliedRaceAbilityTemplate");
	self.Bg:Hide();
	self.TopTileStreaks:Hide();

	self.ModelFrame.BackgroundOverlay:SetAtlas("AlliedRace-UnlockingFrame-ModelFrame", true);

	self.FrameBackground:SetAtlas("AlliedRace-UnlockingFrame-Background", true);

	self.Banner:ClearAllPoints();
	self.Banner:SetPoint("TOPLEFT", self.ModelFrame, "TOPRIGHT", -74, 7);
	self.Banner:SetAtlas("AlliedRace-UnlockingFrame-RaceBanner", true);
end

function AlliedRacesFrameMixin:ASMSG_ALLIED_RACE_OPEN(msg)
	local raceID = tonumber(msg);
	if raceID and C_AlliedRaces.GetRaceInfoByID(raceID) then
		self:LoadRaceData(raceID);
		ShowUIPanel(self);
	end
end

function AlliedRacesFrameMixin:ASMSG_ALLIED_RACE_CLOSE()
    if self:IsShown() then
        HideUIPanel(self);
    end
end