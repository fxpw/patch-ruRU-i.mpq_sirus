local TOY_BOX_COLLECTED = 1;
local TOY_BOX_UNCOLLECTED = 2;

local NUM_SOURCE_TYPES = 10;

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

local REALMS = {
	[E_REALM_ID.FROSTMOURNE] = 1,
	[E_REALM_ID.SCOURGE] = 2,
	[E_REALM_ID.NELTHARION] = 4,
	[E_REALM_ID.LEGACY_X10] = 8,
}

local FILTER_STRING = "";
local COLLECTED_SHOWN = true;
local UNCOLLECTED_SHOWN = true;
local FILTERED_TOYS = {};

local TOYS = {};

local TOY_BY_SPELL_ID = {};
local TOY_BY_ITEM_ID = {};

local PLAYER_FACTION_ID;

local FACTIONS = {
	[PLAYER_FACTION_GROUP.Neutral] = 0,
	[PLAYER_FACTION_GROUP.Alliance] = 1,
	[PLAYER_FACTION_GROUP.Horde] = 2,
	[PLAYER_FACTION_GROUP.Renegade] = 4,
}

local function isLearnedToy(itemID)
	local toy = TOY_BY_ITEM_ID[itemID];
	if toy and toy.spellName and GetSpellInfo(toy.spellName, toy.spellRank) then
		return true;
	end

	return false;
end

local function InitToys()
	table.wipe(TOYS);

	local realmFlag = REALMS[C_Service:GetRealmID()];
	local faction = FACTIONS[PLAYER_FACTION_ID];

	local failedSpells = {};

	for i = 1, #COLLECTION_TOYDATA do
		local data = COLLECTION_TOYDATA[i];
		local spellName, spellRank, spellIcon = GetSpellInfo(data.spellID);

		if not spellName or spellName == "" then
			table.insert(failedSpells, data.spellID);
		end

		data.spellName = spellName;
		data.spellRank = spellRank;
		data.spellIcon = spellIcon;

		if (not data.flags or data.flags == 0 or (realmFlag and bit.band(data.flags, realmFlag) == 0)) and (data.factionSide == 0 or bit.band(data.factionSide, faction) ~= 0) then
			TOYS[#TOYS + 1] = data;
		end

		TOY_BY_SPELL_ID[data.spellID] = data;
		TOY_BY_ITEM_ID[data.itemID] = data;

		if not spellbookCustomHiddenChatSpell[data.spellID] then
			spellbookCustomHiddenChatSpell[data.spellID] = spellName;
		end
	end

	if #failedSpells ~= 0 then
		StaticPopup_Show("TOYBOX_LOAD_ERROR_DIALOG", table.concat(failedSpells, ", "));
	end
end

local function SortFilteredToys(a, b)
	if SIRUS_COLLECTION_FAVORITE_TOY[a.hash] ~= SIRUS_COLLECTION_FAVORITE_TOY[b.hash] then
		return SIRUS_COLLECTION_FAVORITE_TOY[a.hash];
	end

	return (a.spellName or "") < (b.spellName or "");
end

local function FilterToy(collected, sourceShown, name)
	if not COLLECTED_SHOWN and collected then
		return false;
	end

	if not UNCOLLECTED_SHOWN and not collected then
		return false;
	end

	if not sourceShown then
		return false;
	end

	if FILTER_STRING ~= "" and not string.find(string.lower(name), FILTER_STRING, 1, true) then
		return false;
	end

	return true;
end

local function SetFilteredToys()
	table.wipe(FILTERED_TOYS);

	local sourceFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_TOY_BOX_SOURCE_FILTERS")) or 0;

	for i = 1, #TOYS do
		local data = TOYS[i];

		local sourceFlag = data.lootType ~= 0 and bit.lshift(1, ((data.currency ~= 0 and data.lootType ~= 15 and 7 or SOURCE_TYPES[data.lootType]) or 1) - 1) or 0;
		if data.holidayText ~= "" then
			sourceFlag = bit.bor(sourceFlag, bit.lshift(1, 6 - 1));
		end

		if FilterToy(isLearnedToy(data.itemID), sourceFiltersFlag == 0 or bit.band(sourceFiltersFlag, sourceFlag) ~= sourceFlag, data.spellName or "") then
			FILTERED_TOYS[#FILTERED_TOYS + 1] = data;
		end
	end

	table.sort(FILTERED_TOYS, SortFilteredToys);

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TOYS_UPDATED);
end

local frame = CreateFrame("Frame");
frame:Hide();
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:SetScript("OnEvent", function(_, event)
	if event == "VARIABLES_LOADED" then
		COLLECTED_SHOWN = not C_CVar:GetCVarBitfield("C_CVAR_TOY_BOX_COLLECTED_FILTERS", TOY_BOX_COLLECTED);
		UNCOLLECTED_SHOWN = not C_CVar:GetCVarBitfield("C_CVAR_TOY_BOX_COLLECTED_FILTERS", TOY_BOX_UNCOLLECTED);
	elseif event == "PLAYER_LOGIN" then
		local function UpdatePlayerFactionID()
			local factionID = C_FactionManager:GetFactionOverrideCVar() or 3;
			if PLAYER_FACTION_ID ~= factionID then
				PLAYER_FACTION_ID = factionID;
				InitToys();
				SetFilteredToys();
			end
		end

		C_FactionManager:RegisterFactionOverrideCallback(UpdatePlayerFactionID, true, true);
	end
end);

function IsToy(spellID)
	if type(spellID) == "string" then
		spellID = tonumber(spellID);
	end
	if type(spellID) ~= "number" then
		error("Usage: local isToy = IsToy(spellID)", 2);
	end

	if TOY_BY_SPELL_ID[spellID] then
		return true;
	end

	return false;
end

function PlayerHasToy(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local hasToy = PlayerHasToy(itemID)", 2);
	end

	return isLearnedToy(itemID);
end

C_ToyBox = {};

function C_ToyBox.GetNumToys()
	return #TOYS;
end

function C_ToyBox.ForceToyRefilter()
	SetFilteredToys();
end

function C_ToyBox.GetNumFilteredToys()
	return #FILTERED_TOYS;
end

function C_ToyBox.GetToyInfo(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local itemID, spellID, name, icon, isFavorite = C_ToyBox.GetToyInfo(itemID)", 2);
	end

	local toy = TOY_BY_ITEM_ID[itemID];
	if toy then
		return toy.itemID, toy.spellID, toy.spellName or "", toy.spellIcon, SIRUS_COLLECTION_FAVORITE_TOY[toy.hash] and isLearnedToy(itemID), toy.descriptionText, toy.priceText, toy.holidayText;
	end
end

function C_ToyBox.GetToyFromIndex(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local itemID = C_ToyBox.GetToyFromIndex(index)", 2);
	end

	if not FILTERED_TOYS[index] then
		return -1, -1;
	end

	return FILTERED_TOYS[index].itemID, FILTERED_TOYS[index].spellID;
end

function C_ToyBox.GetNumTotalDisplayedToys()
	return #TOYS;
end

function C_ToyBox.GetNumLearnedDisplayedToys()
	local numLearned = 0;

	for i = 1, #TOYS do
		if isLearnedToy(TOYS[i].itemID) then
			numLearned = numLearned + 1;
		end
	end

	return numLearned;
end

function C_ToyBox.SetIsFavorite(itemID, isFavorite)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" or isFavorite == nil then
		error("Usage: C_ToyBox.SetIsFavorite(itemID, isFavorite)", 2);
	end

	local toy = TOY_BY_ITEM_ID[itemID];
	if toy then
		if isFavorite then
			SendServerMessage("ACMSG_C_A_F", string.format("%d|%s", CHAR_COLLECTION_TOY, toy.hash));
		else
			SendServerMessage("ACMSG_C_R_F", string.format("%d|%s", CHAR_COLLECTION_TOY, toy.hash));
		end
	end

	SetFilteredToys();
end

function C_ToyBox.GetIsFavorite(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local isFavorite = C_ToyBox.GetIsFavorite(itemID)", 2);
	end

	local toy = TOY_BY_ITEM_ID[itemID];
	if toy and SIRUS_COLLECTION_FAVORITE_TOY[toy.hash] and isLearnedToy(itemID) then
		return true;
	end

	return false;
end

function C_ToyBox.HasFavorites()
	if next(SIRUS_COLLECTION_FAVORITE_TOY) then
		return true;
	end

	return false;
end

function C_ToyBox.SetSourceTypeFilter(index, checked)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" or checked == nil then
		error("Usage: C_ToyBox.SetSourceTypeFilter(index, checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if index > 0 and index <= NUM_SOURCE_TYPES then
		C_CVar:SetCVarBitfield("C_CVAR_TOY_BOX_SOURCE_FILTERS", index, not checked);

		SetFilteredToys();
	end
end

function C_ToyBox.SetAllSourceTypeFilters(checked)
	if checked == nil then
		error("Usage: C_ToyBox.SetAllSourceTypeFilters(checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index = 1, NUM_SOURCE_TYPES do
		C_CVar:SetCVarBitfield("C_CVAR_TOY_BOX_SOURCE_FILTERS", index, not checked);
	end

	SetFilteredToys();
end

function C_ToyBox.IsSourceTypeFilterChecked(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local isChecked = C_ToyBox.IsSourceTypeFilterChecked(index)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_TOY_BOX_SOURCE_FILTERS", index) then
		return false;
	end

	return true;
end

function C_ToyBox.SetFilterString(filterString)
	if type(filterString) ~= "string" then
		error("Usage: C_ToyBox.SetFilterString(filterString)", 2);
	end

	FILTER_STRING = string.lower(filterString);

	SetFilteredToys();
end

function C_ToyBox.SetCollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if checked ~= COLLECTED_SHOWN then
		C_CVar:SetCVarBitfield("C_CVAR_TOY_BOX_COLLECTED_FILTERS", TOY_BOX_COLLECTED, not checked);

		COLLECTED_SHOWN = checked;

		SetFilteredToys();
	end
end

function C_ToyBox.GetCollectedShown()
	return COLLECTED_SHOWN;
end

function C_ToyBox.SetUncollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if checked ~= UNCOLLECTED_SHOWN then
		C_CVar:SetCVarBitfield("C_CVAR_TOY_BOX_COLLECTED_FILTERS", TOY_BOX_UNCOLLECTED, not checked);

		UNCOLLECTED_SHOWN = checked;

		SetFilteredToys();
	end
end

function C_ToyBox.GetUncollectedShown()
	return UNCOLLECTED_SHOWN;
end

function C_ToyBox.GetToyLink(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local itemLink = C_ToyBox.GetToyLink(index)", 2);
	end

	local toy = TOY_BY_ITEM_ID[itemID];
	if toy and toy.itemID then
		return string.format(COLLECTION_TOY_HYPERLINK_FORMAT, toy.itemID, toy.spellName or "");
	end

	return "";
end

local tooltip = CreateFrame("GameTooltip", "Test", nil)
function C_ToyBox.SetToyTooltipByItemID(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: C_ToyBox.SetToyTooltipByItemID(itemID)", 2);
	end

	local toy = TOY_BY_ITEM_ID[itemID];
	if toy then
		GameTooltip:SetHyperlink("item:"..itemID);
	end

	return false;
end

C_ToyBoxInfo = {};

function C_ToyBoxInfo.SetDefaultFilters()
	C_CVar:SetValue("C_CVAR_TOY_BOX_COLLECTED_FILTERS", "0");
	C_CVar:SetValue("C_CVAR_TOY_BOX_SOURCE_FILTERS", "0");

	COLLECTED_SHOWN = true;
	UNCOLLECTED_SHOWN = true;

	SetFilteredToys();
end

function C_ToyBoxInfo.IsUsingDefaultFilters()
	if tonumber(C_CVar:GetValue("C_CVAR_TOY_BOX_COLLECTED_FILTERS")) ~= 0 or tonumber(C_CVar:GetValue("C_CVAR_TOY_BOX_SOURCE_FILTERS")) ~= 0 then
		return false;
	end

 	return true;
end

function C_ToyBoxInfo.IsToySourceValid(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local isValid = C_ToyBoxInfo.IsToySourceValid(index)", 2);
	end

	if index < 1 or index > NUM_SOURCE_TYPES then
		return false;
	end

	return true;
end

function EventHandler:ASMSG_C_ADD_TOY(msg)
	local spellID = tonumber(msg);
	if spellID then
		local toy = TOY_BY_SPELL_ID[spellID];
		if toy then
			SendChatMessageType(string.format(COLLECTION_TOY_ADD_FORMAT, string.format(COLLECTION_TOY_HYPERLINK_FORMAT, toy.itemID, GetItemInfo(toy.itemID) or "")), "SYSTEM");

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TOYS_UPDATED, toy.itemID, true);
		end
	end
end