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
local PET_SOURCE_CHECKED = {};
local PET_EXPANSION_CHECKED = {};

local PET_SORT_PARAMETER = 1;

SIRUS_COLLECTION_FAVORITE_PET = {};
local COMPANION_INFO = {};
local PET_INFO_BY_INDEX = {};
local PET_INFO_BY_PET_ID = {};
local PET_INFO_BY_ITEM_ID = {};
local PET_INFO_BY_PET_HASH = {};
local NUM_OWNED_PETS = 0;
local SUMMONED_PET_ID;

local function GetPetID(creatureID, spellID)
	return string.format("%s%s", tostring(creatureID), tostring(spellID));
end

local function UpdateCompanionInfo()
	table.wipe(COMPANION_INFO);

	local foundActive;
	for index = 1, GetNumCompanions("CRITTER") do
		local creatureID, _, spellID, _, active = GetCompanionInfo("CRITTER", index);
		local petID = GetPetID(creatureID, spellID);

		COMPANION_INFO[petID] = index;

		if active and not foundActive then
			SUMMONED_PET_ID = petID;
			foundActive = true;
		end

		if PET_INFO_BY_PET_ID[petID] then
			PET_INFO_BY_PET_ID[petID].petIndex = index;
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
	if a.isOwned and not b.isOwned then
		return true;
	end

	if not a.isOwned and b.isOwned then
		return false;
	end

	if a.isOwned and b.isOwned then
		if a.isFavorite and not b.isFavorite then
			return true;
		end
		if not a.isFavorite and b.isFavorite then
			return false;
		end
	end

	local c = a[SORT_PARAMETERS[PET_SORT_PARAMETER]] or "";
	local d = b[SORT_PARAMETERS[PET_SORT_PARAMETER]] or "";

	return c < d;
end

local function PetMathesFilter(isOwned, subCategoryID, sourceType, expansion, name)
	if PET_FILTER_CHECKED[LE_PET_JOURNAL_FILTER_COLLECTED] and isOwned then
		return false;
	end

	if PET_FILTER_CHECKED[LE_PET_JOURNAL_FILTER_NOT_COLLECTED] and not isOwned then
		return false;
	end

	if next(PET_SOURCE_CHECKED) and not sourceType then
		return false;
	end

	if PET_TYPE_CHECKED[subCategoryID] or PET_SOURCE_CHECKED[sourceType] or PET_EXPANSION_CHECKED[expansion] then
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

	for i = 1, #COLLECTION_PETDATA do
		local data = COLLECTION_PETDATA[i];
		local petID = GetPetID(data.creatureID, data.spellID);

		local _, name, icon;
		local petInfoByHash = PET_INFO_BY_PET_HASH[data.hash];
		if petInfoByHash then
			name, icon = petInfoByHash.name, petInfoByHash.icon;
		else
			name, _, icon = GetSpellInfo(data.spellID);
		end

		local petIndex = COMPANION_INFO[petID];
		local isOwned = petIndex and true or false;
		local isFavorite = SIRUS_COLLECTION_FAVORITE_PET[data.hash] and true or false;
		local currency = petInfoByHash and petInfoByHash.currency or data.currency;
		local sourceType = (currency ~= 0 and 7 or SOURCE_TYPES[data.lootType]);

		if isOwned then
			NUM_OWNED_PETS = NUM_OWNED_PETS + 1;
		end

		if PetMathesFilter(isOwned, data.subCategoryID, sourceType, data.expansion or 0, name or "") then
			PET_INFO_BY_INDEX[#PET_INFO_BY_INDEX + 1] = {
				hash = data.hash,
				petID = petID,
				petIndex = petIndex,
				isOwned = isOwned,
				isFavorite = isFavorite,
				name = name,
				icon = icon,
				subCategoryID = data.subCategoryID,
				spellID = data.spellID,
			};
		end
	end

	table.sort(PET_INFO_BY_INDEX, SortedPetJornal);

	Hook:FireEvent("PET_JOURNAL_LIST_UPDATE");
end

local function InitPetInfo()
	for i = 1, #COLLECTION_PETDATA do
		local data = COLLECTION_PETDATA[i];
		local petID = GetPetID(data.creatureID, data.spellID);
		local name, _, icon = GetSpellInfo(data.spellID);

		data.petID = petID;
		data.name = name;
		data.icon = icon;

		PET_INFO_BY_PET_ID[petID] = data;
		PET_INFO_BY_ITEM_ID[data.itemID] = data;
		PET_INFO_BY_PET_HASH[data.hash] = data;
	end

	UpdateCompanionInfo();
	FilteredPetJornal();
end

local frame = CreateFrame("Frame");
frame:Hide();
frame:RegisterEvent("COMPANION_UPDATE");
frame:RegisterEvent("COMPANION_LEARNED");
frame:RegisterEvent("COMPANION_UNLEARNED");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");

frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_TALENT_UPDATE");
frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "COMPANION_UPDATE" and arg1 == "CRITTER" or event == "COMPANION_LEARNED" or event == "COMPANION_LEARNED" then
		UpdateCompanionInfo();
		FilteredPetJornal();
	elseif event == "VARIABLES_LOADED" then
		for index = 1, NUM_PET_FILTERS do
			PET_FILTER_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_FILTERS", index);
		end

		for index = 1, NUM_PET_TYPES do
			PET_TYPE_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_TYPE_FILTERS", index);
		end

		for index = 1, NUM_PET_SOURCES do
			PET_SOURCE_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_SOURCE_FILTERS", index) and true or nil;
		end

		for index = 1, NUM_PET_EXPANSIONS do
			PET_EXPANSION_CHECKED[index] = C_CVar:GetCVarBitfield("C_CVAR_PET_JOURNAL_EXPANSION_FILTERS", index);
		end

		PET_SORT_PARAMETER = tonumber(C_CVar:GetValue("C_CVAR_PET_JOURNAL_SORT")) or 1;
	elseif event == "PLAYER_LOGIN" then
		InitPetInfo();
	elseif event == "PLAYER_ENTERING_WORLD" then
		frame:RegisterEvent("COMMENTATOR_ENTER_WORLD");
		frame:UnregisterEvent(event);
	elseif event == "COMMENTATOR_ENTER_WORLD" then
		table.wipe(SIRUS_COLLECTION_FAVORITE_PET);
		frame:UnregisterEvent(event);
	elseif event == "PLAYER_TALENT_UPDATE" then
		frame:UnregisterEvent("COMMENTATOR_ENTER_WORLD");
		frame:UnregisterEvent(event);
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

		PET_SOURCE_CHECKED[petSourceIndex] = not value and true or nil;

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

	return not PET_SOURCE_CHECKED[petSourceIndex] and true or false;
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

		PET_SOURCE_CHECKED[index] = not checked and true or nil;
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

function C_PetJournal.GetPetInfoByIndex(index)
	local petInfo = PET_INFO_BY_INDEX[index] or {};
	local hash = petInfo.hash
	local isFavorite = hash and SIRUS_COLLECTION_FAVORITE_PET[hash];
	return hash, petInfo.petID, petInfo.petIndex, petInfo.isOwned, isFavorite, petInfo.name, petInfo.icon, petInfo.subCategoryID, petInfo.spellID;
end

function C_PetJournal.GetPetInfoByItemID(itemID)
	local petInfo = PET_INFO_BY_ITEM_ID[itemID] or {};
	local hash = petInfo.hash;
	local isFavorite = hash and SIRUS_COLLECTION_FAVORITE_PET[hash];
	return isFavorite, petInfo.petID, petInfo.name, petInfo.icon, petInfo.subCategoryID, petInfo.lootType, petInfo.currency, petInfo.price, petInfo.creatureID, petInfo.spellID, petInfo.itemID, petInfo.priceText, petInfo.descriptionText;
end

function C_PetJournal.GetPetInfoByPetID(petID)
	local petInfo = PET_INFO_BY_PET_ID[petID] or {};
	local hash = petInfo.hash;
	local isFavorite = hash and SIRUS_COLLECTION_FAVORITE_PET[hash];
	return petInfo.hash, petInfo.petIndex, isFavorite, petInfo.name, petInfo.icon, petInfo.subCategoryID, petInfo.lootType, petInfo.currency, petInfo.price, petInfo.creatureID, petInfo.spellID, petInfo.itemID, petInfo.priceText, petInfo.descriptionText;
end

function C_PetJournal.GetPetInfoByPetHash(hash)
	local petInfo = PET_INFO_BY_PET_HASH[hash] or {};
	local isFavorite = hash and SIRUS_COLLECTION_FAVORITE_PET[hash];
	return petInfo.petIndex, isFavorite, petInfo.name, petInfo.icon, petInfo.subCategoryID, petInfo.lootType, petInfo.currency, petInfo.price, petInfo.productID, petInfo.creatureID, petInfo.spellID, petInfo.itemID, petInfo.priceText, petInfo.descriptionText;
end

function C_PetJournal.GetSummonedPetID()
	return SUMMONED_PET_ID;
end

function C_PetJournal.PetIsSummonable(petID)
	local petInfo = PET_INFO_BY_PET_ID[petID];
	if petInfo then
		local isSummonable = PET_INFO_BY_PET_ID[petID].petIndex and true or false;
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
		local isSummonable, errorType, errorText = PET_INFO_BY_PET_ID[petID].petIndex and true or false, 0;
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
	local petIndex = PET_INFO_BY_PET_ID[petID] and PET_INFO_BY_PET_ID[petID].petIndex;
	if petIndex then
		local creatureID, _, spellID = GetCompanionInfo("CRITTER", petIndex);
		if SUMMONED_PET_ID == GetPetID(creatureID, spellID) then
			DismissCompanion("CRITTER");
		else
			CallCompanion("CRITTER", petIndex);
		end
	end
end

function C_PetJournal.PetIsFavorite(petID)
	local hash = PET_INFO_BY_PET_ID[petID] and PET_INFO_BY_PET_ID[petID].hash;
	if hash then
		return SIRUS_COLLECTION_FAVORITE_PET[hash];
	end
end

function C_PetJournal.SetFavorite(petID, isFavorite)
	local hash = PET_INFO_BY_PET_ID[petID] and PET_INFO_BY_PET_ID[petID].hash;
	if hash then
		if isFavorite then
			SendAddonMessage("ACMSG_C_P_ADD_TO_FAVORITES", hash, "WHISPER", UnitName("player"));
			SIRUS_COLLECTION_FAVORITE_PET[hash] = true;
		else
			SendAddonMessage("ACMSG_C_P_REMOVE_FROM_FAVORITES", hash, "WHISPER", UnitName("player"));
			SIRUS_COLLECTION_FAVORITE_PET[hash] = nil;
		end
	end
end

function C_PetJournal.GetPetLink(petID)
	local petInfo = PET_INFO_BY_PET_ID[petID];
	if petInfo and petInfo.itemID then
		return string.format(COLLECTION_PETS_HYPERLINK_FORMAT, petInfo.itemID, GetSpellInfo(petInfo.spellID) or "")
	end

	return "";
end

function EventHandler:ACMSG_C_P_ADD_TO_FAVORITES(msg)
	SIRUS_COLLECTION_FAVORITE_PET[msg] = true;

	FilteredPetJornal();
	PetJournal_UpdatePetList();
end

function EventHandler:ASMSG_C_P_REMOVE_FROM_FAVORITES_R(msg)
	SIRUS_COLLECTION_FAVORITE_PET[msg] = nil;

	FilteredPetJornal();
	PetJournal_UpdatePetList();
end

function EventHandler:ASMSG_C_P_FAVORITES_LIST(msg)
	for _, v in pairs({strsplit(",", msg)}) do
		if v then
			SIRUS_COLLECTION_FAVORITE_PET[v] = true;
		end
	end
end

function EventHandler:ASMSG_COLLECTION_PET_IN_SHOP(msg)
	local blockData = {strsplit("|", msg)};
	for i = 1, #blockData do
		local hash, currency, price, productID = strsplit(",", blockData[i]);
		currency, price, productID = tonumber(currency), tonumber(price), tonumber(productID);
		if hash and productID and price and PET_INFO_BY_PET_HASH[hash] then
			PET_INFO_BY_PET_HASH[hash].currency = currency;
			PET_INFO_BY_PET_HASH[hash].price = price;
			PET_INFO_BY_PET_HASH[hash].productID = productID;
		end
	end
	FilteredPetJornal();
end