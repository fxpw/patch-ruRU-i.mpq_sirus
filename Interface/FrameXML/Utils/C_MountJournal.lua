local IsGMAccount = IsGMAccount

local COLLECTION_MOUNTDATA = COLLECTION_MOUNTDATA;

Enum.MountAbility = {
	Speed60 = 1,
	Speed100 = 2,
	Speed280 = 3,
	Speed310 = 4,
	WaterWalk = 5,
	FastSwimming = 6,
	TwoSit = 7,
	ThreeSit = 8,
	MountVendor = 9,
	Unblock310 = 10,
	AccountWide = 11,
};

Enum.MountAbilityFlag = {
	Speed60 = 1,
	Speed100 = 2,
	Speed280 = 4,
	Speed310 = 8,
	WaterWalk = 16,
	FastSwimming = 32,
	TwoSit = 64,
	ThreeSit = 128,
	MountVendor = 256,
	Unblock310 = 512,
	AccountWide = 1024,
};

local NUM_MOUNT_FILTERS = 2;
local NUM_MOUNT_ABILITIES = 11;
local NUM_MOUNT_SOURCES = 10;
local NUM_MOUNT_TRAVELING_MERCHANTS = 3;
local NUM_MOUNT_FACTIONS = 4;

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
local TRAVELING_MERCHANTS = {
	[6101] = 1,
	[6100] = 2,
	[6102] = 3,
}

local CATEGORY_FILTER;
local SEARCH_FILTER = "";

local COMPANION_INFO = {};

local NUM_MOUNTS = 0;

local MOUNT_INFO_BY_INDEX = {};
local MOUNT_INFO_BY_MOUNT_ID = {};
local MOUNT_INFO_BY_ITEM_ID = {};
local MOUNT_INFO_BY_SPELL_ID = {};

local function UpdateCompanionInfo()
	NUM_MOUNTS = 0;
	table.wipe(COMPANION_INFO);

	for index = 1, GetNumCompanions("MOUNT") do
		NUM_MOUNTS = NUM_MOUNTS + 1;

		local creatureID, _, spellID, _, active = GetCompanionInfo("MOUNT", index);
		local mountData = MOUNT_INFO_BY_SPELL_ID[spellID];
		if mountData then
			COMPANION_INFO[mountData.hash] = index;
		end
	end
end

local function SortedMountJornal(a, b)
	local aMountInfo = COLLECTION_MOUNTDATA[a];
	local bMountInfo = COLLECTION_MOUNTDATA[b];

	if COMPANION_INFO[aMountInfo.hash] and not COMPANION_INFO[bMountInfo.hash] then
		return true;
	end

	if not COMPANION_INFO[aMountInfo.hash] and COMPANION_INFO[bMountInfo.hash] then
		return false;
	end

	if COMPANION_INFO[aMountInfo.hash] and COMPANION_INFO[bMountInfo.hash] then
		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[aMountInfo.hash] and not SIRUS_MOUNTJOURNAL_FAVORITE_PET[bMountInfo.hash] then
			return true;
		end
		if not SIRUS_MOUNTJOURNAL_FAVORITE_PET[aMountInfo.hash] and SIRUS_MOUNTJOURNAL_FAVORITE_PET[bMountInfo.hash] then
			return false;
		end
	end

	return (aMountInfo.name or "") < (bMountInfo.name or "");
end

local realmFilterData = {
	[E_REALM_ID.SOULSEEKER]	= 0x1,
	[E_REALM_ID.SCOURGE]	= 0x2,
	[E_REALM_ID.ALGALON]	= 0x4,
	[E_REALM_ID.SIRUS]		= 0x8,
};

local function MountMathesFilter(data, collectedShown, notCollectedShown, isCollected, abilityShown, sourceShown, factionShown, isGM)
	if collectedShown and isCollected then
		return false;
	end

	if notCollectedShown and not isCollected then
		return false;
	end

	if not abilityShown then
		return false;
	end

	if not sourceShown then
		return false;
	end

	if not factionShown then
		return false;
	end

	if SEARCH_FILTER ~= "" then
		if isGM then
			local searchID = tonumber(SEARCH_FILTER)
			if searchID and (searchID == data.itemID or searchID == data.spellID or searchID == data.creatureID) then
				return true
			end
		end

		if not data.name or not string.find(string.lower(data.name), SEARCH_FILTER, 1, true) then
			return false;
		end
	end

	return true;
end

local FilteredMountJornal;
function FilteredMountJornal()
	table.wipe(MOUNT_INFO_BY_INDEX);

	if CATEGORY_FILTER then
		for i = 1, #COLLECTION_MOUNTDATA do
			local mountInfo = COLLECTION_MOUNTDATA[i];

			if CATEGORY_FILTER == LE_MOUNT_JOURNAL_FILTER_COLLECTED and COMPANION_INFO[mountInfo.hash] then
				MOUNT_INFO_BY_INDEX[#MOUNT_INFO_BY_INDEX + 1] = i;
			elseif CATEGORY_FILTER == LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED and not COMPANION_INFO[mountInfo.hash] then
				MOUNT_INFO_BY_INDEX[#MOUNT_INFO_BY_INDEX + 1] = i;
			elseif CATEGORY_FILTER == LE_MOUNT_JOURNAL_FILTER_FAVORITES and SIRUS_MOUNTJOURNAL_FAVORITE_PET[mountInfo.hash] then
				MOUNT_INFO_BY_INDEX[#MOUNT_INFO_BY_INDEX + 1] = i;
			end
		end
	else
		local collectedShown = C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS", LE_MOUNT_JOURNAL_FILTER_COLLECTED);
		local notCollectedShown = C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS", LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED);
		local abilityFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER")) or 0;
		local sourceFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER")) or 0;
		local travelingMerchantFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER")) or 0;
		local factionFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER")) or 0;
		local isGM = IsGMAccount()

		for i = 1, #COLLECTION_MOUNTDATA do
			local mountInfo = COLLECTION_MOUNTDATA[i];
			local productID, price, originalPrice, currencyType = mountInfo.hash and C_StorePublic.GetRolledItemInfoByHash(mountInfo.hash)
			if not productID then
				currencyType = mountInfo.currency;
			end
			local sourceType;
			if mountInfo.holidayText ~= "" then
				sourceType = 6;
			elseif currencyType and currencyType ~= 0 and mountInfo.lootType ~= 15 then
				sourceType = 7;
			elseif mountInfo.lootType == 0 and mountInfo.shopCategory == 3 then
				sourceType = 7;
			else
				sourceType = SOURCE_TYPES[mountInfo.lootType] or 1;
			end
			local sourceFlag = ((productID or sourceType == 7) or mountInfo.lootType ~= 0) and bit.lshift(1, sourceType - 1) or 0;
			local travelingMerchantFlag = 0;
			if type(mountInfo.ownersList) == "table" and #mountInfo.ownersList > 0 then
				for _, ownerID in ipairs(mountInfo.ownersList) do
					local ownerFlag = TRAVELING_MERCHANTS[ownerID];
					if ownerFlag then
						travelingMerchantFlag = bit.bor(travelingMerchantFlag, bit.lshift(1, ownerFlag - 1));
					end
				end
			end
			local factionFlag = 0;
			if mountInfo.factionSide == 0 then
				factionFlag = bit.lshift(1, 3 - 1);
			else
				if bit.band(mountInfo.factionSide, 1) ~= 0 then
					factionFlag = bit.bor(factionFlag, bit.lshift(1, 1 - 1));
				end
				if bit.band(mountInfo.factionSide, 2) ~= 0 then
					factionFlag = bit.bor(factionFlag, bit.lshift(1, 2 - 1));
				end
				if bit.band(mountInfo.factionSide, 4) ~= 0 then
					factionFlag = bit.bor(factionFlag, bit.lshift(1, 4 - 1));
				end
			end

			if MountMathesFilter(mountInfo, collectedShown, notCollectedShown, COMPANION_INFO[mountInfo.hash],
				abilityFiltersFlag == 0 or bit.band(abilityFiltersFlag, (mountInfo.specialAbilities or 0)) ~= (mountInfo.specialAbilities or 0),
				(sourceFiltersFlag == 0 and travelingMerchantFiltersFlag == 0) or (bit.band(sourceFiltersFlag, sourceFlag) ~= sourceFlag or bit.band(travelingMerchantFiltersFlag, travelingMerchantFlag) ~= travelingMerchantFlag),
				factionFiltersFlag == 0 or bit.band(factionFiltersFlag, factionFlag) ~= factionFlag,
				isGM)
			then
				MOUNT_INFO_BY_INDEX[#MOUNT_INFO_BY_INDEX + 1] = i;
			end
		end
	end

	table.sort(MOUNT_INFO_BY_INDEX, SortedMountJornal);

	FireCustomClientEvent("MOUNT_JOURNAL_SEARCH_UPDATED");
end
_G.FilteredMountJornal = FilteredMountJornal;

local function InitMountInfo()
	local realmID = C_Service.GetRealmID();
	local realmFlag = realmFilterData[realmID];

	for i = #COLLECTION_MOUNTDATA, 1, -1 do
		local data = COLLECTION_MOUNTDATA[i];

		local isValid = true;
		if realmFlag and data.flags and data.flags ~= 0 then
			if bit.band(data.flags, realmFlag) == data.flags then
				table.remove(COLLECTION_MOUNTDATA, i);
				isValid = false;
			end
		end

		if isValid then
			local name, _, icon = GetSpellInfo(data.spellID);
			data.name = name;
			data.icon = icon;

			MOUNT_INFO_BY_MOUNT_ID[data.hash] = data;
			MOUNT_INFO_BY_ITEM_ID[data.itemID] = data;
			MOUNT_INFO_BY_SPELL_ID[data.spellID] = data;
		end
	end
end

local function PopulateMountInfo()
	UpdateCompanionInfo();
	FilteredMountJornal();
end

function ReloadCollectionMountData()
	COLLECTION_MOUNTDATA = _G.COLLECTION_MOUNTDATA
	table.wipe(MOUNT_INFO_BY_MOUNT_ID)
	table.wipe(MOUNT_INFO_BY_ITEM_ID)
	table.wipe(MOUNT_INFO_BY_SPELL_ID)
	InitMountInfo()
end

InitMountInfo()

local function GetMountInfo(infoTable, value)
	local mountInfo = infoTable[value];
	if mountInfo then
		local _, active, isFavorite, isFactionSpecific, faction, isCollected, priceText = nil, false, false, false, nil, false, nil;
		if COMPANION_INFO[mountInfo.hash] then
			_, _, _, _, active = GetCompanionInfo("MOUNT", COMPANION_INFO[mountInfo.hash]);
			isCollected = true;
		end

		local productID, price, originalPrice, currencyType = mountInfo.hash and C_StorePublic.GetRolledItemInfoByHash(mountInfo.hash)
		if not productID then
			currencyType = mountInfo.currency;
			price = mountInfo.price;
		end

		local sourceType = mountInfo.holidayText ~= "" and 6 or (currencyType and currencyType ~= 0 and mountInfo.lootType ~= 15 and 7 or (SOURCE_TYPES[mountInfo.lootType] or 1));
		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[mountInfo.hash] then
			isFavorite = true;
		end
		if mountInfo.factionSide == 2 then
			isFactionSpecific = true;
			faction = 0;
			priceText = mountInfo.priceText:gsub("-Team.", "-Horde.");
		elseif mountInfo.factionSide == 1 then
			isFactionSpecific = true;
			faction = 1;
			priceText = mountInfo.priceText:gsub("-Team.", "-Alliance.");
		else
			local factionGroup = UnitFactionGroup("player");
			priceText = mountInfo.priceText:gsub("-Team.", "-"..factionGroup..".");
		end

		return mountInfo.name, mountInfo.spellID, mountInfo.icon, active, sourceType, isFavorite,
			isFactionSpecific, faction, isCollected, mountInfo.hash,
			mountInfo.creatureID, mountInfo.itemID, currencyType, price, productID,
			priceText or "", mountInfo.descriptionText or "", mountInfo.holidayText or "";
	end
end

local abilityIcons = {
	[1] = "Interface/Custom/CollectionIcons/s_speed_60",
	[2] = "Interface/Custom/CollectionIcons/s_speed_100",
	[3] = "Interface/Custom/CollectionIcons/s_speed_280",
	[4] = "Interface/Custom/CollectionIcons/s_speed_310",
	[5] = "Interface/Custom/CollectionIcons/s_water_walk",
	[6] = "Interface/Custom/CollectionIcons/s_swimming_mount",
	[7] = "Interface/Custom/CollectionIcons/s_two_sits",
	[8] = "Interface/Custom/CollectionIcons/s_three_sits",
	[9] = "Interface/Custom/CollectionIcons/s_mount_vendor",
	[10] = "Interface/Custom/CollectionIcons/s_unblock_310",
	[11] = "Interface/Custom/CollectionIcons/s_accountwide_mount_2",
};

local function GetMountAbilitiesInfo(infoTable, value)
	local abilities = {};

	local mountInfo = infoTable[value];
	if mountInfo and mountInfo.specialAbilities then
		for index = 1, 11 do
			if bit.band(mountInfo.specialAbilities, bit.lshift(1, index - 1)) ~= 0 then
				abilities[#abilities + 1] = index;
			end
		end
	end

	return abilities;
end

local frame = CreateFrame("Frame");
frame:Hide();
frame:RegisterEvent("COMPANION_UPDATE");
frame:RegisterEvent("COMPANION_LEARNED");
frame:RegisterEvent("COMPANION_UNLEARNED");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("PLAYER_LOGIN");
frame:SetScript("OnEvent", function(_, event, companionType)
	if (event == "COMPANION_UPDATE" and (not companionType or companionType == "CRITTER")) or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" then
		PopulateMountInfo()
	elseif event == "VARIABLES_LOADED" then
		frame:RegisterCustomEvent("STORE_ROLLED_ITEM_HASHES");
	elseif event == "PLAYER_LOGIN" then
		PopulateMountInfo();
	elseif event == "STORE_ROLLED_ITEM_HASHES" then
		FilteredMountJornal();
	end
end);

C_MountJournal = {};

function C_MountJournal.GetDisplayedMountID(displayIndex)
end

function C_MountJournal.GetMountCompanionIndex(mountID)
	if type(mountID) == "number" then
		mountID = tostring(mountID);
	end
	if type(mountID) ~= "string" then
		error("Usage: C_MountJournal.GetMountCompanionIndex(mountID)", 2);
	end

	return COMPANION_INFO[mountID];
end

function C_MountJournal.GetDisplayedMountInfo(displayIndex)
	if type(displayIndex) == "string" then
		displayIndex = tonumber(displayIndex);
	end
	if type(displayIndex) ~= "number" then
		error("Usage: C_MountJournal.GetDisplayedMountInfo(displayIndex)", 2);
	end

	local mountIndex = MOUNT_INFO_BY_INDEX[displayIndex];
	if mountIndex then
		return GetMountInfo(COLLECTION_MOUNTDATA, mountIndex);
	end
end

function C_MountJournal.GetMountFromItem(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: C_MountJournal.GetMountFromItem(itemID)", 2);
	end

	return GetMountInfo(MOUNT_INFO_BY_ITEM_ID, itemID);
end

function C_MountJournal.GetMountFromSpell(spellID)
	if type(spellID) == "string" then
		spellID = tonumber(spellID);
	end
	if type(spellID) ~= "number" then
		error("Usage: C_MountJournal.GetMountFromSpell(spellID)", 2);
	end

	return GetMountInfo(MOUNT_INFO_BY_SPELL_ID, spellID);
end

function C_MountJournal.GetMountInfoByID(mountID)
	if type(mountID) == "number" then
		mountID = tostring(mountID);
	end
	if type(mountID) ~= "string" then
		error("Usage: C_MountJournal.GetMountInfoByID(mountID)", 2);
	end

	return GetMountInfo(MOUNT_INFO_BY_MOUNT_ID, mountID);
end

function C_MountJournal.GetDisplayedMountAbilitiesInfo(displayIndex)
	if type(displayIndex) == "string" then
		displayIndex = tonumber(displayIndex);
	end
	if type(displayIndex) ~= "number" then
		error("Usage: C_MountJournal.GetDisplayedMountInfo(displayIndex)", 2);
	end

	local mountIndex = MOUNT_INFO_BY_INDEX[displayIndex];
	if mountIndex then
		return GetMountAbilitiesInfo(COLLECTION_MOUNTDATA, mountIndex);
	end
end

function C_MountJournal.GetMountAbilitiesInfoByID(mountID)
	if type(mountID) == "number" then
		mountID = tostring(mountID);
	end
	if type(mountID) ~= "string" then
		error("Usage: C_MountJournal.GetMountAbilitiesInfoByID(mountID)", 2);
	end

	return GetMountAbilitiesInfo(MOUNT_INFO_BY_MOUNT_ID, mountID);
end

function C_MountJournal.GetMountAbilitiesInfoByItemID(itemID)
	if type(itemID) == "string" then
		if string.find(itemID, "item:", 1, true) then
			itemID = string.match(itemID, "item:(%d+)")
		end
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: C_MountJournal.GetMountAbilitiesInfoByItemID(itemID)", 2);
	end

	return GetMountAbilitiesInfo(MOUNT_INFO_BY_ITEM_ID, itemID);
end

function C_MountJournal.GetAbilityInfo(abilityID)
	if type(abilityID) == "string" then
		abilityID = tonumber(abilityID);
	end
	if type(abilityID) ~= "number" then
		error("Usage: C_MountJournal.GetAbilityInfo(abilityID)", 2);
	end

	local icon = abilityIcons[abilityID];
	if icon then
		return _G[string.format("COLLECTION_MOUNT_ABILITY_%d", abilityID)], icon, _G[string.format("COLLECTION_MOUNT_ABILITY_TEXT_%d", abilityID)], _G[string.format("COLLECTION_MOUNT_ABILITY_DESCRIPTION_%d", abilityID)];
	end
end

function C_MountJournal.GetNumDisplayedMounts()
	return #MOUNT_INFO_BY_INDEX;
end

function C_MountJournal.GetNumMounts()
	return NUM_MOUNTS;
end

function C_MountJournal.GetIsFavorite(mountIndex)
	if type(mountIndex) == "string" then
		mountIndex = tonumber(mountIndex);
	end
	if type(mountIndex) ~= "number" then
		error("Usage: local isFavorite, canSetFavorite = C_MountJournal.GetIsFavorite(mountIndex)", 2);
	end

	local isFavorite, canSetFavorite = false, false;

	local displayIndex = MOUNT_INFO_BY_INDEX[mountIndex];
	local mountInfo = displayIndex and COLLECTION_MOUNTDATA[displayIndex];
	if mountInfo then
		if COMPANION_INFO[mountInfo.hash] then
			canSetFavorite = true;
		end
		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[mountInfo.hash] then
			isFavorite = true;
		end
	end

	return isFavorite, canSetFavorite;
end

function C_MountJournal.SetIsFavorite(mountIndex, isFavorite)
	if type(mountIndex) == "string" then
		mountIndex = tonumber(mountIndex);
	end
	if type(mountIndex) ~= "number" or isFavorite == nil then
		error("Usage: C_MountJournal.SetIsFavorite(mountIndex, isChecked)", 2);
	end
	if type(isFavorite) ~= "boolean" then
		isFavorite = not not isFavorite;
	end

	local displayIndex = MOUNT_INFO_BY_INDEX[mountIndex];
	local mountInfo = displayIndex and COLLECTION_MOUNTDATA[displayIndex];
	if mountInfo then
		if SIRUS_MOUNTJOURNAL_FAVORITE_PET[mountInfo.hash] then
			SendServerMessage("ACMSG_C_R_F", string.format("%d|%s", CHAR_COLLECTION_MOUNT, mountInfo.hash));
		else
			SendServerMessage("ACMSG_C_A_F", string.format("%d|%s", CHAR_COLLECTION_MOUNT, mountInfo.hash));
		end
	end
end

function C_MountJournal.SetCategoryFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: C_MountJournal.SetCategoryFilter(filterIndex)", 2);
	end

	CATEGORY_FILTER = filterIndex;
	FilteredMountJornal();
end

function C_MountJournal.GetCategoryFilter()
	return CATEGORY_FILTER;
end

function C_MountJournal.ClearCategoryFilter()
	CATEGORY_FILTER = nil;
	FilteredMountJornal();
end

function C_MountJournal.SetSearch(searchValue)
	SEARCH_FILTER = string.lower(strtrim(searchValue or ""));
	FilteredMountJornal();
end

function C_MountJournal.SetCollectedFilterSetting(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_MountJournal.SetCollectedFilterSetting(filterIndex, isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	if filterIndex > 0 and filterIndex <= NUM_MOUNT_FILTERS then
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS", filterIndex, not isChecked);

		FilteredMountJornal();
	end
end

function C_MountJournal.GetCollectedFilterSetting(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: C_MountJournal.GetCollectedFilterSetting(filterIndex)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS", filterIndex) then
		return false;
	end

	return true;
end

function C_MountJournal.GetNumMountAbilities()
	return NUM_MOUNT_ABILITIES;
end

function C_MountJournal.SetAbilityFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_MountJournal.SetAbilityFilter(filterIndex, isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	if filterIndex > 0 and filterIndex <= NUM_MOUNT_ABILITIES then
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER", filterIndex, not isChecked);

		FilteredMountJornal();
	end
end

function C_MountJournal.SetAllAbilityFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_MountJournal.SetAllAbilityFilters(isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	for index = 1, NUM_MOUNT_ABILITIES do
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER", index, not isChecked);
	end

	FilteredMountJornal();
end

function C_MountJournal.IsAbilityChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_MountJournal.IsAbilityChecked(filterIndex)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER", filterIndex) then
		return false;
	end

	return true;
end

function C_MountJournal.IsValidAbilityFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_MountJournal.IsValidAbilityFilter(filterIndex)", 2);
	end

	if filterIndex <= 0 or filterIndex > NUM_MOUNT_ABILITIES then
		return false;
	end

	return true;
end

function C_MountJournal.SetSourceFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_MountJournal.SetSourceFilter(filterIndex, isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	if filterIndex > 0 and filterIndex <= NUM_MOUNT_SOURCES then
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER", filterIndex, not isChecked);

		FilteredMountJornal();
	end
end

function C_MountJournal.SetAllSourceFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_MountJournal.SetAllSourceFilters(isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	for index = 1, NUM_MOUNT_SOURCES do
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER", index, not isChecked);
	end

	FilteredMountJornal();
end

function C_MountJournal.IsSourceChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_MountJournal.IsSourceChecked(filterIndex)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER", filterIndex) then
		return false;
	end

	return true;
end

function C_MountJournal.IsValidSourceFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_MountJournal.IsValidSourceFilter(filterIndex)", 2);
	end

	if filterIndex <= 0 or filterIndex > NUM_MOUNT_SOURCES then
		return false;
	end

	return true;
end

function C_MountJournal.GetNumTravelingMerchantFilters()
	return NUM_MOUNT_TRAVELING_MERCHANTS;
end

function C_MountJournal.SetTravelingMerchantFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_MountJournal.SetTravelingMerchantFilter(filterIndex, isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	if filterIndex > 0 and filterIndex <= NUM_MOUNT_TRAVELING_MERCHANTS then
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER", filterIndex, not isChecked);

		FilteredMountJornal();
	end
end

function C_MountJournal.SetAllTravelingMerchantFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_MountJournal.SetAllTravelingMerchantFilters(isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	for index = 1, NUM_MOUNT_TRAVELING_MERCHANTS do
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER", index, not isChecked);
	end

	FilteredMountJornal();
end

function C_MountJournal.IsTravelingMerchantChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_MountJournal.IsTravelingMerchantChecked(filterIndex)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER", filterIndex) then
		return false;
	end

	return true;
end

function C_MountJournal.IsValidTravelingMerchantFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_MountJournal.IsValidTravelingMerchantFilter(filterIndex)", 2);
	end

	if filterIndex <= 0 or filterIndex > NUM_MOUNT_TRAVELING_MERCHANTS then
		return false;
	end

	return true;
end

function C_MountJournal.SetFactionFilter(filterIndex, isChecked)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" or isChecked == nil then
		error("Usage: C_MountJournal.SetFactionFilter(filterIndex, isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	if filterIndex > 0 and filterIndex <= NUM_MOUNT_FACTIONS then
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER", filterIndex, not isChecked);

		FilteredMountJornal();
	end
end

function C_MountJournal.SetAllFactionFilters(isChecked)
	if isChecked == nil then
		error("Usage: C_MountJournal.SetAllFactionFilters(isChecked)", 2);
	end
	if type(isChecked) ~= "boolean" then
		isChecked = not not isChecked;
	end

	for index = 1, NUM_MOUNT_FACTIONS do
		C_CVar:SetCVarBitfield("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER", index, not isChecked);
	end

	FilteredMountJornal();
end

function C_MountJournal.IsFactionChecked(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isChecked = C_MountJournal.IsFactionChecked(petSourceIndex)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER", filterIndex) then
		return false;
	end

	return true;
end

function C_MountJournal.IsValidFactionFilter(filterIndex)
	if type(filterIndex) == "string" then
		filterIndex = tonumber(filterIndex);
	end
	if type(filterIndex) ~= "number" then
		error("Usage: local isValid = C_MountJournal.IsValidFactionFilter(filterIndex)", 2);
	end

	if filterIndex <= 0 or filterIndex > NUM_MOUNT_FACTIONS then
		return false;
	end

	return true;
end

function C_MountJournal.SetDefaultFilters()
	C_CVar:SetValue("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS", "0");
	C_CVar:SetValue("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER", "0");
	C_CVar:SetValue("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER", "0");
	C_CVar:SetValue("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER", "0");
	C_CVar:SetValue("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER", "0");

	FilteredMountJornal();
end

function C_MountJournal.IsUsingDefaultFilters()
	if tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_GENERAL_FILTERS")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_ABILITY_FILTER")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_SOURCE_FILTER")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_TRAVELING_MERCHANT_FILTER")) ~= 0
	or tonumber(C_CVar:GetValue("C_CVAR_MOUNT_JOURNAL_FACTION_FILTER")) ~= 0
	then
		return false;
	end

 	return true;
end