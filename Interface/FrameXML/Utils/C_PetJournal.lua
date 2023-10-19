local COLLECTION_PETDATA = COLLECTION_PETDATA;

local NUM_PET_FILTERS = 2;
local NUM_PET_TYPES = 10;
local NUM_PET_SOURCES = 10;
local NUM_PET_EXPANSIONS = 9;

local FACTION_FLAGS = {
	Neutral = 0,
	Alliance = 1,
	Horde = 2,
	Renegade = 4,
};

local SOURCE_TYPES = {
	[1] = 1, [2] = 1, [3] = 1,
	[8] = 2, [12] = 2,
	[6] = 3, [13] = 3,
	[9] = 4,
	[7] = 5,
	[10] = 7, [11] = 7, [14] = 7,
	[15] = 8,
	[16] = 9,
	[17] = 10,
};

local SEARCH_FILTER = "";
local PET_FILTER_CHECKED = {};
local PET_TYPE_CHECKED = {};
local PET_EXPANSION_CHECKED = {};

local PET_SORT_PARAMETER = 1;

local COMPANION_INFO = {};
local PET_INFO_BY_INDEX = {};
local PET_INFO_BY_PET_ID = {};
local PET_INFO_BY_ITEM_ID = {};
local PET_INFO_BY_SPELL_ID = {};
local NUM_OWNED_PETS = 0;
local SUMMONED_PET_ID;

local function GetPetInfoByCompanionsSpellID(spellID)
	local petInfo;
	if spellID == 66096 then
		if UnitFactionGroup("player") == "Alliance" then
			petInfo = PET_INFO_BY_ITEM_ID[46820];
		else
			petInfo = PET_INFO_BY_ITEM_ID[46821];
		end
	else
		petInfo = PET_INFO_BY_SPELL_ID[spellID];
	end
	return petInfo;
end

local function UpdateCompanionInfo()
	table.wipe(COMPANION_INFO);

	local foundActive;
	for index = 1, GetNumCompanions("CRITTER") do
		local _, _, spellID, _, active = GetCompanionInfo("CRITTER", index);
		local petInfo = GetPetInfoByCompanionsSpellID(spellID);

		if petInfo then
			COMPANION_INFO[petInfo.hash] = index;

			if active and not foundActive then
				SUMMONED_PET_ID = petInfo.hash;
				foundActive = true;
			end
		end
	end

	if not foundActive then
		SUMMONED_PET_ID = nil;
	end
end

local SORT_PARAMETERS = {
	[1] = "name",
	[2] = "subCategoryID",
}

local function SortedPetJornal(a, b)
	local aPetInfo = COLLECTION_PETDATA[a];
	local bPetInfo = COLLECTION_PETDATA[b];

	if COMPANION_INFO[aPetInfo.hash] and not COMPANION_INFO[bPetInfo.hash] then
		return true;
	end

	if not COMPANION_INFO[aPetInfo.hash] and COMPANION_INFO[bPetInfo.hash] then
		return false;
	end

	if COMPANION_INFO[aPetInfo.hash] and COMPANION_INFO[bPetInfo.hash] then
		if SIRUS_COLLECTION_FAVORITE_PET[aPetInfo.hash] and not SIRUS_COLLECTION_FAVORITE_PET[bPetInfo.hash] then
			return true;
		end
		if not SIRUS_COLLECTION_FAVORITE_PET[aPetInfo.hash] and SIRUS_COLLECTION_FAVORITE_PET[bPetInfo.hash] then
			return false;
		end
	end

	local c = aPetInfo[SORT_PARAMETERS[PET_SORT_PARAMETER]] or "";
	local d = bPetInfo[SORT_PARAMETERS[PET_SORT_PARAMETER]] or "";

	return c < d;
end

local function PetMathesFilter(isOwned, subCategoryID, sourceShown, expansion, name)
	if PET_FILTER_CHECKED[LE_PET_JOURNAL_FILTER_COLLECTED] and isOwned then
		return false;
	end

	if PET_FILTER_CHECKED[LE_PET_JOURNAL_FILTER_NOT_COLLECTED] and not isOwned then
		return false;
	end

	if not sourceShown then
		return false;
	end

	if PET_TYPE_CHECKED[subCategoryID] or PET_EXPANSION_CHECKED[expansion] then
		return false;
	end

	if SEARCH_FILTER ~= "" and not string.find(string.lower(name), SEARCH_FILTER, 1, true) then
		return false;
	end

	return true;
end

local function FilteredPetJornal()
	NUM_OWNED_PETS = 0;
	table.wipe(PET_INFO_BY_INDEX);

	local sourceFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_SOURCE_FILTERS")) or 0;

	for i = 1, #COLLECTION_PETDATA do
		local data = COLLECTION_PETDATA[i];

		local _, name, icon;
		local petInfoByItemID = PET_INFO_BY_ITEM_ID[data.itemID];
		if petInfoByItemID then
			name, icon = petInfoByItemID.name, petInfoByItemID.icon;
		else
			name, _, icon = GetSpellInfo(data.spellID);
		end

		local petIndex = COMPANION_INFO[data.hash];
		local isOwned = petIndex and true or false;
		local product = CUSTOM_ROLLED_ITEMS_IN_SHOP[data.hash];
		local currency = product and product.currency or data.currency;
		local sourceType;
		if data.holidayText ~= "" then
			sourceType = 6;
		elseif currency and currency ~= 0 and data.lootType ~= 15 then
			sourceType = 7;
		elseif data.lootType == 0 and data.shopCategory == 3 then
			sourceType = 7;
		else
			sourceType = SOURCE_TYPES[data.lootType] or 1;
		end
		local sourceFlag = ((product or sourceType == 7) or data.lootType ~= 0) and bit.lshift(1, sourceType - 1) or 0;

		if isOwned then
			NUM_OWNED_PETS = NUM_OWNED_PETS + 1;
		end

		if PetMathesFilter(isOwned, data.subCategoryID, sourceFiltersFlag == 0 or bit.band(sourceFiltersFlag, sourceFlag) ~= sourceFlag, data.expansion or 0, name or "") then
			PET_INFO_BY_INDEX[#PET_INFO_BY_INDEX + 1] = i;
		end
	end

	table.sort(PET_INFO_BY_INDEX, SortedPetJornal);

	FireCustomClientEvent("PET_JOURNAL_LIST_UPDATE");
end

local function InitPetInfo()
	for i = #COLLECTION_PETDATA, 1, -1 do
		local data = COLLECTION_PETDATA[i];
		local name, _, icon = GetSpellInfo(data.spellID);

		data.name = name;
		data.icon = icon;

		PET_INFO_BY_PET_ID[data.hash] = data;
		PET_INFO_BY_ITEM_ID[data.itemID] = data;
		PET_INFO_BY_SPELL_ID[data.spellID] = data;
	end

	UpdateCompanionInfo();
	FilteredPetJornal();
end

local function GetPetInfo(infoTable, value)
	local petInfo = infoTable[value];
	if petInfo then
		local _, active, isFavorite, isCollected, currency, price, productID, priceText = nil, false, false, false, nil, nil, nil, nil;
		if COMPANION_INFO[petInfo.hash] then
			_, _, _, _, active = GetCompanionInfo("MOUNT", COMPANION_INFO[petInfo.hash]);
			isCollected = true;
		end
		local product = CUSTOM_ROLLED_ITEMS_IN_SHOP[petInfo.hash];
		if product then
			currency = product.currency;
			price = product.price;
			productID = product.productID;
		else
			currency = petInfo.currency;
			price = petInfo.price;
		end
		local sourceType = petInfo.holidayText ~= "" and 6 or (currency and currency ~= 0 and petInfo.lootType ~= 15 and 7 or (SOURCE_TYPES[petInfo.lootType] or 1));
		if SIRUS_COLLECTION_FAVORITE_PET[petInfo.hash] then
			isFavorite = true;
		end
		if petInfo.factionSide == 2 then
			priceText = petInfo.priceText:gsub("-Team.", "-Horde.");
		elseif petInfo.factionSide == 1 then
			isFactionSpecific = true;
			faction = 1;
			priceText = petInfo.priceText:gsub("-Team.", "-Alliance.");
		else
			local factionGroup = UnitFactionGroup("player");
			priceText = petInfo.priceText:gsub("-Team.", "-"..factionGroup..".");
		end

		return petInfo.name, petInfo.spellID, petInfo.icon, petInfo.subCategoryID, active, sourceType, isFavorite,
			isCollected, petInfo.hash,
			petInfo.creatureID, petInfo.itemID, currency, price, productID,
			priceText or "", petInfo.descriptionText or "", petInfo.holidayText or "";
	end
end

local frame = CreateFrame("Frame");
frame:Hide();
frame:RegisterEvent("COMPANION_UPDATE");
frame:RegisterEvent("COMPANION_LEARNED");
frame:RegisterEvent("COMPANION_UNLEARNED");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:SetScript("OnEvent", function(_, event, arg1)
	if (event == "COMPANION_UPDATE" and (not arg1 or arg1 == "CRITTER")) or event == "COMPANION_LEARNED" or event == "COMPANION_LEARNED" then
		UpdateCompanionInfo();
		FilteredPetJornal();
	elseif event == "VARIABLES_LOADED" then
		frame:RegisterCustomEvent("SESSION_VARIABLES_LOADED");
		frame:RegisterCustomEvent("STORE_ROLLED_ITEMS_IN_SHOP");

		for index = 1, NUM_PET_FILTERS do
			PET_FILTER_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_FILTERS", index);
		end

		for index = 1, NUM_PET_TYPES do
			PET_TYPE_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_TYPE_FILTERS", index);
		end

		for index = 1, NUM_PET_EXPANSIONS do
			PET_EXPANSION_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", index);
		end

		PET_SORT_PARAMETER = tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_SORT")) or 1;
	elseif event == "PLAYER_LOGIN" then
		InitPetInfo();
	elseif event == "SESSION_VARIABLES_LOADED" then
		table.wipe(SIRUS_MOUNTJOURNAL_FAVORITE_PET);
		table.wipe(SIRUS_COLLECTION_FAVORITE_PET);
		table.wipe(SIRUS_COLLECTION_FAVORITE_APPEARANCES);
		table.wipe(SIRUS_COLLECTION_FAVORITE_TOY);
	elseif event == "STORE_ROLLED_ITEMS_IN_SHOP" then
		FilteredPetJornal();
	end
end);

C_PetJournal = {};

function C_PetJournal.SetSearchFilter(searchText)
	SEARCH_FILTER = string.lower(strtrim(searchText or ""));
	FilteredPetJornal();
end

function C_PetJournal.ClearSearchFilter()
	SEARCH_FILTER = "";
	FilteredPetJornal();
end

function C_PetJournal.SetFilterChecked(filterType, value)
	if type(filterType) == "string" then
		filterType = tonumber(filterType);
	end
	if type(filterType) ~= "number" or value == nil then
		error("Usage: C_PetJournal.SetFilterChecked(filterType, value)", 2);
	end
	if type(value) ~= "boolean" then
		value = not not value;
	end

	if LE_PET_JOURNAL_FILTER_COLLECTED or LE_PET_JOURNAL_FILTER_NOT_COLLECTED then
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_FILTERS", filterType, not value);

		PET_FILTER_CHECKED[filterType] = not value;

		FilteredPetJornal();
	end
end

function C_PetJournal.IsFilterChecked(filterType)
	if type(filterType) == "string" then
		filterType = tonumber(filterType);
	end
	if type(filterType) ~= "number" then
		error("Usage: local isChecked = C_PetJournal.IsFilterChecked(filterType)", 2);
	end

	return not PET_FILTER_CHECKED[filterType];
end

function C_PetJournal.SetPetSortParameter(sortParametr)
	PET_SORT_PARAMETER = sortParametr;
	C_CVar:SetValue("C_CVAR_PET_JOURNAL_SORT", tostring(sortParametr));
	FilteredPetJornal();
end

function C_PetJournal.GetPetSortParameter()
	return PET_SORT_PARAMETER;
end

function C_PetJournal.GetNumPets()
	return #PET_INFO_BY_INDEX, NUM_OWNED_PETS;
end

function C_PetJournal.GetNumPetSources()
	return NUM_PET_SOURCES;
end

function C_PetJournal.GetNumPetTypes()
	return NUM_PET_TYPES;
end

function C_PetJournal.GetNumPetExpansions()
	return NUM_PET_EXPANSIONS;
end

function C_PetJournal.SetPetTypeFilter(petTypeIndex, value)
	if type(petTypeIndex) == "string" then
		petTypeIndex = tonumber(petTypeIndex);
	end
	if type(petTypeIndex) ~= "number" or value == nil then
		error("Usage: C_PetJournal.SetPetTypeFilter(petTypeIndex, value)", 2);
	end
	if type(value) ~= "boolean" then
		value = not not value;
	end

	if petTypeIndex > 0 and petTypeIndex <= NUM_PET_TYPES then
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_TYPE_FILTERS", petTypeIndex, not value);

		PET_TYPE_CHECKED[petTypeIndex] = not value;

		FilteredPetJornal();
	end
end

function C_PetJournal.IsPetTypeChecked(petTypeIndex)
	if type(petTypeIndex) == "string" then
		petTypeIndex = tonumber(petTypeIndex);
	end
	if type(petTypeIndex) ~= "number" then
		error("Usage: local isChecked = C_PetJournal.IsPetTypeChecked(petTypeIndex)", 2);
	end

	return not PET_TYPE_CHECKED[petTypeIndex];
end

function C_PetJournal.SetAllPetTypesChecked(checked)
	if checked == nil then
		error("Usage: C_PetJournal.SetAllPetTypesChecked(checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index = 1, NUM_PET_TYPES do
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_TYPE_FILTERS", index, not checked);

		PET_TYPE_CHECKED[index] = not checked;
	end

	FilteredPetJornal();
end

function C_PetJournal.SetPetSourceChecked(petSourceIndex, value)
	if type(petSourceIndex) == "string" then
		petSourceIndex = tonumber(petSourceIndex);
	end
	if type(petSourceIndex) ~= "number" or value == nil then
		error("Usage: C_PetJournal.SetPetSourceChecked(petSourceIndex, value)", 2);
	end
	if type(value) ~= "boolean" then
		value = not not value;
	end

	if petSourceIndex > 0 and petSourceIndex <= NUM_PET_SOURCES then
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", petSourceIndex, not value);

		FilteredPetJornal();
	end
end

function C_PetJournal.IsPetSourceChecked(petSourceIndex)
	if type(petSourceIndex) == "string" then
		petSourceIndex = tonumber(petSourceIndex);
	end
	if type(petSourceIndex) ~= "number" then
		error("Usage: local isChecked = C_PetJournal.IsPetSourceChecked(petSourceIndex)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", petSourceIndex) then
		return false;
	end

	return true;
end

function C_PetJournal.SetAllPetSourcesChecked(checked)
	if checked == nil then
		error("Usage: C_PetJournal.SetAllPetSourcesChecked(checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index = 1, NUM_PET_SOURCES do
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", index, not checked);
	end

	FilteredPetJornal();
end

function C_PetJournal.SetPetExpansionChecked(petExpansionIndex, value)
	if type(petExpansionIndex) == "string" then
		petExpansionIndex = tonumber(petExpansionIndex);
	end
	if type(petExpansionIndex) ~= "number" or value == nil then
		error("Usage: C_PetJournal.SetPetExpansionChecked(petExpansionIndex, value)", 2);
	end
	if type(value) ~= "boolean" then
		value = not not value;
	end

	if petExpansionIndex > 0 and petExpansionIndex <= NUM_PET_EXPANSIONS then
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", petExpansionIndex, not value);

		PET_EXPANSION_CHECKED[petExpansionIndex] = not value;

		FilteredPetJornal();
	end
end

function C_PetJournal.IsPetExpansionChecked(petExpansionIndex)
	if type(petExpansionIndex) == "string" then
		petExpansionIndex = tonumber(petExpansionIndex);
	end
	if type(petExpansionIndex) ~= "number" then
		error("Usage: local isChecked = C_PetJournal.IsPetExpansionChecked(petExpansionIndex)", 2);
	end

	return not PET_EXPANSION_CHECKED[petExpansionIndex];
end

function C_PetJournal.SetAllPetExpansionsChecked(checked)
	if checked == nil then
		error("Usage: C_PetJournal.SetAllPetExpansionsChecked(checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index = 1, NUM_PET_EXPANSIONS do
		C_CVar:SetCVarBitfield("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", index, not checked);

		PET_EXPANSION_CHECKED[index] = not checked;
	end

	FilteredPetJornal();
end

function C_PetJournal.GetPetCompanionIndex(petID)
	return COMPANION_INFO[petID];
end

function C_PetJournal.GetPetInfoByIndex(index)
	local petIndex = PET_INFO_BY_INDEX[index];
	if petIndex then
		return GetPetInfo(COLLECTION_PETDATA, petIndex);
	end
end

function C_PetJournal.GetPetInfoByPetID(petID)
	return GetPetInfo(PET_INFO_BY_PET_ID, petID);
end

function C_PetJournal.GetPetInfoByItemID(itemID)
	return GetPetInfo(PET_INFO_BY_ITEM_ID, itemID);
end

function C_PetJournal.GetPetInfoBySpellID(spellID)
	return GetPetInfo(PET_INFO_BY_SPELL_ID, spellID);
end

function C_PetJournal.GetSummonedPetID()
	return SUMMONED_PET_ID;
end

function C_PetJournal.PetIsSummonable(petID)
	local petInfo = PET_INFO_BY_PET_ID[petID];
	if petInfo then
		local isSummonable = COMPANION_INFO[petID] and true or false;
		if petInfo.factionSide ~= 0 and petInfo.factionSide ~= 4 then
			local factionGroup = UnitFactionGroup("player");
			local factionFlag = factionGroup and FACTION_FLAGS[factionGroup];
			if factionFlag and factionFlag ~= petInfo.factionSide then
				isSummonable = false;
			end
		end
		return isSummonable;
	end
end

function C_PetJournal.GetPetSummonInfo(petID)
	local petInfo = PET_INFO_BY_PET_ID[petID];
	if petInfo then
		local isSummonable, errorType, errorText = COMPANION_INFO[petID] and true or false, 0;
		if petInfo.factionSide ~= 0 and petInfo.factionSide ~= 4 then
			local factionGroup = UnitFactionGroup("player");
			local factionFlag = factionGroup and FACTION_FLAGS[factionGroup];
			if factionFlag and factionFlag ~= petInfo.factionSide then
				isSummonable, errorType, errorText = false, 1, PET_JOURNAL_PET_IS_WRONG_FACTION;
			end
		end
		return isSummonable, errorType, errorText;
	end
end

function C_PetJournal.SummonPetByPetID(petID)
	local petIndex = COMPANION_INFO[petID];
	if petIndex then
		local _, _, spellID = GetCompanionInfo("CRITTER", petIndex);
		local petInfo = GetPetInfoByCompanionsSpellID(spellID);
		if petInfo and SUMMONED_PET_ID == petInfo.hash then
			DismissCompanion("CRITTER");
		else
			CallCompanion("CRITTER", petIndex);
		end
	end
end

function C_PetJournal.PetIsFavorite(petID)
	return SIRUS_COLLECTION_FAVORITE_PET[petID];
end

function C_PetJournal.SetFavorite(petID, isFavorite)
	if isFavorite then
		SendServerMessage("ACMSG_C_A_F", string.format("%d|%s", CHAR_COLLECTION_PET, petID));
	else
		SendServerMessage("ACMSG_C_R_F", string.format("%d|%s", CHAR_COLLECTION_PET, petID));
	end
end

function C_PetJournal.GetPetLink(petID)
	local petInfo = PET_INFO_BY_PET_ID[petID];
	if petInfo and petInfo.itemID then
		return string.format(COLLECTION_PETS_HYPERLINK_FORMAT, petInfo.itemID, GetSpellInfo(petInfo.spellID) or "")
	end

	return "";
end

function C_PetJournal.SetDefaultFilters()
	C_CVar:SetValue("C_CVAR_PET_JOURNAL_FILTERS", "0");
	C_CVar:SetValue("C_CVAR_PET_JOURNAL_TYPE_FILTERS", "0");
	C_CVar:SetValue("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", "0");
	C_CVar:SetValue("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", "0");

	table.wipe(PET_FILTER_CHECKED);
	table.wipe(PET_TYPE_CHECKED);
	table.wipe(PET_EXPANSION_CHECKED);

	FilteredPetJornal();
end

function C_PetJournal.IsUsingDefaultFilters()
	if tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_FILTERS")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_TYPE_FILTERS")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_SOURCE_FILTERS")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS")) ~= 0
	then
		return false;
	end

 	return true;
end

SIRUS_MOUNTJOURNAL_FAVORITE_PET = {};
SIRUS_COLLECTION_FAVORITE_PET = {};
SIRUS_COLLECTION_FAVORITE_APPEARANCES = {};
SIRUS_COLLECTION_FAVORITE_TOY = {};

function EventHandler:ASMSG_C_F_L(msg)
	local collectionType, favoriteList = string.split("|", msg);
	collectionType = tonumber(collectionType);
	if collectionType == CHAR_COLLECTION_MOUNT then
		for _, item in ipairs({string.split(",", favoriteList)}) do
			if item then
				SIRUS_MOUNTJOURNAL_FAVORITE_PET[item] = true;
			end
		end
	elseif collectionType == CHAR_COLLECTION_PET then
		for _, item in ipairs({string.split(",", favoriteList)}) do
			if item then
				SIRUS_COLLECTION_FAVORITE_PET[item] = true;
			end
		end
	elseif collectionType == CHAR_COLLECTION_APPEARANCE then
		for _, item in ipairs({string.split(",", favoriteList)}) do
			item = tonumber(item);
			if item then
				SIRUS_COLLECTION_FAVORITE_APPEARANCES[item] = true;
			end
		end
	elseif collectionType == CHAR_COLLECTION_TOY then
		for _, item in ipairs({string.split(",", favoriteList)}) do
			if item then
				SIRUS_COLLECTION_FAVORITE_TOY[item] = true;
			end
		end
	end
end

function EventHandler:ASMSG_C_A_F(msg)
	local collectionType, item = string.split("|", msg);
	collectionType = tonumber(collectionType);

	if collectionType == CHAR_COLLECTION_MOUNT then
		SIRUS_MOUNTJOURNAL_FAVORITE_PET[item] = true;

		FilteredMountJornal();
	elseif collectionType == CHAR_COLLECTION_PET then
		SIRUS_COLLECTION_FAVORITE_PET[item] = true;

		FilteredPetJornal();
	elseif collectionType == CHAR_COLLECTION_APPEARANCE then
		SIRUS_COLLECTION_FAVORITE_APPEARANCES[tonumber(item)] = true;

		FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
	elseif collectionType == CHAR_COLLECTION_TOY then
		SIRUS_COLLECTION_FAVORITE_TOY[item] = true;

		C_ToyBox.ForceToyRefilter();
	end
end

function EventHandler:ASMSG_C_R_F(msg)
	local collectionType, item = string.split("|", msg);
	collectionType = tonumber(collectionType);

	if collectionType == CHAR_COLLECTION_MOUNT then
		SIRUS_MOUNTJOURNAL_FAVORITE_PET[item] = nil;

		FilteredMountJornal();
	elseif collectionType == CHAR_COLLECTION_PET then
		SIRUS_COLLECTION_FAVORITE_PET[item] = nil;

		FilteredPetJornal();
	elseif collectionType == CHAR_COLLECTION_APPEARANCE then
		SIRUS_COLLECTION_FAVORITE_APPEARANCES[tonumber(item)] = nil;

		FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
	elseif collectionType == CHAR_COLLECTION_TOY then
		SIRUS_COLLECTION_FAVORITE_TOY[item] = nil;

		C_ToyBox.ForceToyRefilter();
	end
end