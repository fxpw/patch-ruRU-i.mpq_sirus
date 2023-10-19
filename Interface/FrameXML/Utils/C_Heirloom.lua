local COLLECTION_HEIRLOOMDATA = COLLECTION_HEIRLOOMDATA;

local HEIRLOOM_COLLECTED = 1;
local HEIRLOOM_UNCOLLECTED = 2;

local HEIRLOOM_DAMAGER_FLAG = 0x1;
local HEIRLOOM_RANGED_DAMAGER_FLAG = 0x2;
local HEIRLOOM_TANK_FLAG = 0x4;
local HEIRLOOM_HEAL_FLAG = 0x8;

local HEIRLOOM_SPEC_ROLE_FLAG = {
	-- Warrior
	[161] = HEIRLOOM_DAMAGER_FLAG, [164] = HEIRLOOM_DAMAGER_FLAG, [163] = HEIRLOOM_TANK_FLAG,
	-- Paladin
	[382] = HEIRLOOM_HEAL_FLAG, [383] = HEIRLOOM_TANK_FLAG, [381] = HEIRLOOM_DAMAGER_FLAG,
	-- Hunter
	[361] = HEIRLOOM_DAMAGER_FLAG, [363] = HEIRLOOM_DAMAGER_FLAG, [362] = HEIRLOOM_DAMAGER_FLAG,
	-- Rogue
	[182] = HEIRLOOM_DAMAGER_FLAG, [181] = HEIRLOOM_DAMAGER_FLAG, [183] = HEIRLOOM_DAMAGER_FLAG,
	-- Priest
	[201] = HEIRLOOM_HEAL_FLAG, [202] = HEIRLOOM_HEAL_FLAG, [203] = HEIRLOOM_RANGED_DAMAGER_FLAG,
	-- Deathknight
	[398] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG), [399] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG), [400] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG),
	-- Shaman
	[261] = HEIRLOOM_RANGED_DAMAGER_FLAG, [263] = HEIRLOOM_DAMAGER_FLAG, [262] = HEIRLOOM_HEAL_FLAG,
	-- Mage
	[81] = HEIRLOOM_RANGED_DAMAGER_FLAG, [41] = HEIRLOOM_RANGED_DAMAGER_FLAG, [61] = HEIRLOOM_RANGED_DAMAGER_FLAG,
	-- Warlock
	[302] = HEIRLOOM_RANGED_DAMAGER_FLAG, [303] = HEIRLOOM_RANGED_DAMAGER_FLAG, [301] = HEIRLOOM_RANGED_DAMAGER_FLAG,
	-- DemonHunter
	[504] = HEIRLOOM_DAMAGER_FLAG, [505] = HEIRLOOM_DAMAGER_FLAG, [506] = HEIRLOOM_DAMAGER_FLAG,
	-- Druid
	[283] = HEIRLOOM_DAMAGER_FLAG, [281] = bit.bor(HEIRLOOM_DAMAGER_FLAG, HEIRLOOM_TANK_FLAG), [282] = HEIRLOOM_HEAL_FLAG,
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

local FILTER_STRING = "";
local CLASS_FILTER = 0;
local SPEC_FILTER = 0;
local COLLECTED_SHOWN = true;
local UNCOLLECTED_SHOWN = true;

local HEIRLOOM_BY_ITEM_ID = {};

local HEIRLOOMS = {};

local VALID_SOURCE_FILTERS = {
	[3] = true,
	[7] = true,
};

local function PlayerHasHeirloom(itemID)
	local heirloom = HEIRLOOM_BY_ITEM_ID[itemID];
	if heirloom and heirloom.spellID and IsSpellKnown(heirloom.spellID) then
		return true;
	end

	return false;
end

local function CheckFilter(collected, classesFlag, classFlag, roleFlag, specFlag, sourceShown, name)
	if not COLLECTED_SHOWN and collected then
		return false;
	end

	if not UNCOLLECTED_SHOWN and not collected then
		return false;
	end

	if classFlag and classesFlag ~= 0 and bit.band(classesFlag, classFlag) == 0 then
		return false;
	end

	if specFlag and bit.band(roleFlag, specFlag) == 0 then
		return false;
	end

	if not sourceShown then
		return false;
	end

	if FILTER_STRING ~= "" and not string.find(string.lower(name), FILTER_STRING, 1, true) then
		return false;
	end

	return true
end

local function SetFilteredHeirlooms()
	table.wipe(HEIRLOOMS);

	local sourceFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_HEIRLOOM_SOURCE_FILTERS")) or 0;
	local classFlag = CLASS_FILTER ~= 0 and bit.lshift(1, CLASS_FILTER - 1);
	local specFlag = SPEC_FILTER ~= 0 and HEIRLOOM_SPEC_ROLE_FLAG[SPEC_FILTER];

	for i = 1, #COLLECTION_HEIRLOOMDATA do
		local data = COLLECTION_HEIRLOOMDATA[i];

		local spellName = GetSpellInfo(data.spellID);

		local sourceFlag = data.lootType ~= 0 and bit.lshift(1, ((data.currency ~= 0 and data.lootType ~= 15 and 7 or SOURCE_TYPES[data.lootType]) or 1) - 1) or 0;
		if data.holidayText ~= "" then
			sourceFlag = bit.bor(sourceFlag, bit.lshift(1, 6 - 1));
		end

		if CheckFilter(PlayerHasHeirloom(data.itemID), data.classFlags, classFlag, data.roleFlag, specFlag, sourceFiltersFlag == 0 or bit.band(sourceFiltersFlag, sourceFlag) ~= sourceFlag, spellName or "") then
			HEIRLOOMS[#HEIRLOOMS + 1] = data;
		end
	end
end

local frame = CreateFrame("Frame");
frame:Hide();
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:SetScript("OnEvent", function(_, event)
	if event == "VARIABLES_LOADED" then
		COLLECTED_SHOWN = not C_CVar:GetCVarBitfield("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", HEIRLOOM_COLLECTED);
		UNCOLLECTED_SHOWN = not C_CVar:GetCVarBitfield("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", HEIRLOOM_UNCOLLECTED);
	elseif event == "PLAYER_LOGIN" then
		for i = 1, #COLLECTION_HEIRLOOMDATA do
			local data = COLLECTION_HEIRLOOMDATA[i];

			local spellName = GetSpellInfo(data.spellID);

			HEIRLOOM_BY_ITEM_ID[data.itemID] = data;

			if not spellbookCustomHiddenChatSpell[data.spellID] then
				spellbookCustomHiddenChatSpell[data.spellID] = spellName;
			end
		end

		SetFilteredHeirlooms();

		FireCustomClientEvent("HEIRLOOMS_UPDATED");
	end
end);

function IsHeirloom(spellID)
	if spellbookCustomHiddenChatSpell[spellID] then
		return true;
	end
	return false;
end

C_Heirloom = {};

function C_Heirloom.GetNumLearnedHeirlooms()
	local num = 0;
	for i = 1, #COLLECTION_HEIRLOOMDATA do
		if PlayerHasHeirloom(COLLECTION_HEIRLOOMDATA[i].itemID) then
			num = num + 1;
		end
	end
	return num;
end

function C_Heirloom.GetNumDisplayedHeirlooms()
	return #HEIRLOOMS;
end

function C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: C_Heirloom.GetHeirloomItemIDFromDisplayedIndex(index)", 2);
	end

	return HEIRLOOMS[index] and HEIRLOOMS[index].itemID;
end

function C_Heirloom.GetHeirloomSpellID(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end

	if type(itemID) ~= "number" then
		error("Usage: local spellID = C_Heirloom.GetHeirloomSpellID(itemID)", 2);
	end

	local data = HEIRLOOM_BY_ITEM_ID[itemID];
	if data then
		return data.spellID;
	end
end

function C_Heirloom.GetHeirloomInfo(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end

	if type(itemID) ~= "number" then
		error("Usage: local name, itemEquipLoc, icon, descriptionText, priceText = C_Heirloom.GetHeirloomInfo(itemID)", 2);
	end

	local data = HEIRLOOM_BY_ITEM_ID[itemID];
	if data then
		local spellName = GetSpellInfo(data.spellID);
		local _, _, _, _, _, _, _, _, itemEquipLoc, itemIcon = C_Item.GetItemInfo(data.itemID, nil, nil, nil, true);

		return spellName, itemEquipLoc, itemIcon, data.descriptionText, data.priceText;
	end
end

function C_Heirloom.SetSearch(filterString)
	if type(filterString) ~= "string" then
		error("Usage: C_ToyBox.SetFilterString(filterString)", 2);
	end

	FILTER_STRING = string.lower(filterString);

	SetFilteredHeirlooms();
end

function C_Heirloom.SetClassAndSpecFilters(classID, specID)
	if type(classID) == "string" then
		classID = tonumber(classID);
	end

	if type(specID) == "string" then
		specID = tonumber(specID);
	end

	if type(classID) ~= "number" or type(specID) ~= "number" then
		error("Usage: C_Heirloom.SetClassAndSpecFilters(classID, specID)", 2);
	end

	CLASS_FILTER, SPEC_FILTER = classID, specID;

	SetFilteredHeirlooms();
end

function C_Heirloom.GetClassAndSpecFilters()
	return CLASS_FILTER, SPEC_FILTER;
end

function C_Heirloom.SetHeirloomSourceFilter(index, checked)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" or checked == nil then
		error("Usage: C_Heirloom.SetHeirloomSourceFilter(index, checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if VALID_SOURCE_FILTERS[index] then
		C_CVar:SetCVarBitfield("C_CVAR_HEIRLOOM_SOURCE_FILTERS", index, not checked);

		SetFilteredHeirlooms();
	end
end

function C_Heirloom.GetHeirloomSourceFilter(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local isChecked = C_Heirloom.GetHeirloomSourceFilter(index)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_HEIRLOOM_SOURCE_FILTERS", index) then
		return false;
	end

	return true;
end

function C_Heirloom.SetCollectedHeirloomFilter(checked)
	if checked == nil then
		error("Usage: C_Heirloom.SetCollectedHeirloomFilter(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if checked ~= COLLECTED_SHOWN then
		C_CVar:SetCVarBitfield("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", HEIRLOOM_COLLECTED, not checked);

		COLLECTED_SHOWN = checked;

		SetFilteredHeirlooms();
	end
end

function C_Heirloom.GetCollectedHeirloomFilter()
	return COLLECTED_SHOWN;
end

function C_Heirloom.SetUncollectedHeirloomFilter(checked)
	if checked == nil then
		error("Usage: C_Heirloom.SetUncollectedHeirloomFilter(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if checked ~= UNCOLLECTED_SHOWN then
		C_CVar:SetCVarBitfield("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", HEIRLOOM_UNCOLLECTED, not checked);

		UNCOLLECTED_SHOWN = checked;

		SetFilteredHeirlooms();
	end
end

function C_Heirloom.GetUncollectedHeirloomFilter()
	return UNCOLLECTED_SHOWN;
end

function C_Heirloom.CreateHeirloom()

end

function C_Heirloom.GetHeirloomItemIDs()

end

function C_Heirloom.GetHeirloomLink(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local itemLink = C_Heirloom.GetHeirloomLink(index)", 2);
	end

	local heirloom = HEIRLOOM_BY_ITEM_ID[itemID];
	if heirloom and heirloom.itemID then
		local spellName = GetSpellInfo(heirloom.spellID);
		return string.format(COLLECTION_HEIRLOOM_HYPERLINK_FORMAT, heirloom.itemID, spellName or "");
	end

	return "";
end

function C_Heirloom.IsItemHeirloom(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local isHeirloom = C_Heirloom.IsItemHeirloom(itemID)", 2);
	end

	if HEIRLOOM_BY_ITEM_ID[itemID] then
		return true;
	end

	return false;
end

function C_Heirloom.PlayerHasHeirloom(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: C_Heirloom.PlayerHasHeirloom(itemID)", 2);
	end

	return PlayerHasHeirloom(itemID);
end

C_HeirloomInfo = {};

function C_HeirloomInfo.SetDefaultFilters()
	C_CVar:SetValue("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", "0");
	C_CVar:SetValue("C_CVAR_HEIRLOOM_SOURCE_FILTERS", "0");

	COLLECTED_SHOWN = true;
	UNCOLLECTED_SHOWN = true;

	SetFilteredHeirlooms();
end

function C_HeirloomInfo.IsUsingDefaultFilters()
	if tonumber(C_CVar:GetValue("C_CVAR_HEIRLOOM_COLLECTED_FILTERS")) ~= 0 or tonumber(C_CVar:GetValue("C_CVAR_HEIRLOOM_SOURCE_FILTERS")) ~= 0 then
		return false;
	end

 	return true;
end

function C_HeirloomInfo.IsHeirloomSourceValid(source)
	if type(source) == "string" then
		source = tonumber(source);
	end

	if type(source) ~= "number" then
		error("Usage: local isHeirloomSourceValid = C_HeirloomInfo.IsHeirloomSourceValid(source)", 2);
	end

	if VALID_SOURCE_FILTERS[source] then
		return true;
	end

	return false;
end

function C_HeirloomInfo.SetAllCollectionFilters(checked)
	if checked == nil then
		error("Usage: C_HeirloomInfo.SetAllCollectionFilters(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	C_CVar:SetValue("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", HEIRLOOM_COLLECTED);
	C_CVar:SetValue("C_CVAR_HEIRLOOM_COLLECTED_FILTERS", HEIRLOOM_UNCOLLECTED);

	SetFilteredHeirlooms();
end

function C_HeirloomInfo.SetAllSourceFilters(checked)
	if checked == nil then
		error("Usage: C_HeirloomInfo.SetAllSourceFilters(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index in pairs(VALID_SOURCE_FILTERS) do
		C_CVar:SetCVarBitfield("C_CVAR_HEIRLOOM_SOURCE_FILTERS", index, not checked);
	end

	SetFilteredHeirlooms();
end

function EventHandler:ASMSG_C_H_ADD(msg)
	local itemID = tonumber(msg);

	if itemID then
		AddChatTyppedMessage("SYSTEM", string.format(COLLECTION_HEIRLOOM_ADD_FORMAT, string.format(COLLECTION_HEIRLOOM_HYPERLINK_FORMAT, itemID, GetItemInfo(itemID) or "")));

		SetFilteredHeirlooms();

		FireCustomClientEvent("HEIRLOOMS_UPDATED", itemID, true);
	end
end