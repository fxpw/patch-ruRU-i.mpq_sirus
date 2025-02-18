local IsGMAccount = IsGMAccount
local IsSpellKnown = IsSpellKnown;

local ITEM_APPEARANCE_STORAGE = ITEM_APPEARANCE_STORAGE;
local ITEM_MODIFIED_APPEARANCE_STORAGE = ITEM_MODIFIED_APPEARANCE_STORAGE;
local ITEM_IGNORED_APPEARANCE_STORAGE = ITEM_IGNORED_APPEARANCE_STORAGE;
local COLLECTION_ENCHANTDATA = COLLECTION_ENCHANTDATA;

local ITEM_APPEARANCE_STORAGE_SOURCES = 2;

local ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID = 1;
local ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE = 2;
local ITEM_MODIFIED_APPEARANCE_STORAGE_CLASSMASK = 3;
local ITEM_MODIFIED_APPEARANCE_STORAGE_FACTIONID = 4;

SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
SIRUS_COLLECTION_RECEIVED_APPEARANCES = {};
SIRUS_COLLECTION_PLAYER_OUTFITS = {};

Enum = Enum or {}
Enum.TransmogCollectionType = {
	None = 0, Head = 1, Shoulder = 2, Back = 3, Chest = 4, Shirt = 5, Tabard = 6, Wrist = 7, Hands = 8, Waist = 9, Legs = 10, Feet = 11,
	Wand = 12, OneHAxe = 13, OneHSword = 14, OneHMace = 15, Dagger = 16, Fist = 17, Shield = 18, Holdable = 19, TwoHAxe = 20,
	TwoHSword = 21, TwoHMace = 22, Staff = 23, Polearm = 24, Bow = 25, Gun = 26, Crossbow = 27, Thrown = 28, FishingPole = 29, OtherWeapon = 30,
};

Enum.TransmogSearchType = {
	Items = 1, BaseSets = 2, UsableSets = 3, Illusions = 4,
};

local GetItemInfoRaw = C_Item.GetItemInfoRaw;
local _, UNIT_CLASS = UnitClass("player");
local _, UNIT_RACE = UnitRace("player");
local UNIT_SEX = UnitSex("player") == 3 and "Female" or "Male";

local ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE = {
	[1] = "Head",
	[3] = "Shoulder",
	[4] = "Shirt",
	[5] = "Chest",
	[20] = "Chest",
	[6] = "Waist",
	[7] = "Legs",
	[8] = "Feet",
	[9] = "Wrist",
	[10] = "Hands",
	[16] = "Back",
	[19] = "Tabard",
};

local WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE = {
	[14] = "Shield",
	[23] = "Holdable",
}

local WEAPON_SUB_CATEGORY_BY_CLASS_ID = {
	[2] = {
		[1] = "TwoHAxe",
		[5] = "TwoHMace",
		[8] = "TwoHSword",
		[0] = "OneHAxe",
		[4] = "OneHMace",
		[7] = "OneHSword",
		[10] = "Staff",
		[6] = "Polearm",
		[13] = "Fist",
		[15] = "Dagger",
		[19] = "Wand",
		[2] = "Bow",
		[3] = "Gun",
		[18] = "Crossbow",
		[16] = "Thrown",
		[20] = "FishingPole",
		[14] = "OtherWeapon",
	},
	[4] = {
		[0] = "OtherWeapon",
	},
}

local TRANSMOG_CATEGORIES = {
	[Enum.TransmogCollectionType.Head] = {name = INVTYPE_HEAD, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Shoulder] = {name = INVTYPE_SHOULDER, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Back] = {name = INVTYPE_CLOAK, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Chest] = {name = INVTYPE_CHEST, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Shirt] = {name = INVTYPE_BODY, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Tabard] = {name = INVTYPE_TABARD, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Wrist] = {name = INVTYPE_WRIST, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Hands] = {name = INVTYPE_HAND, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Waist] = {name = INVTYPE_WAIST, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Legs] = {name = INVTYPE_LEGS, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Feet] = {name = INVTYPE_FEET, isWeapon = false, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = false, subCategories = {}},
	[Enum.TransmogCollectionType.Wand] = {name = ITEM_SUB_CLASS_2_19, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.OneHAxe] = {name = ITEM_SUB_CLASS_2_0, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.OneHSword] = {name = ITEM_SUB_CLASS_2_7, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.OneHMace] = {name = ITEM_SUB_CLASS_2_4, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Dagger] = {name = ITEM_SUB_CLASS_2_15, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Fist] = {name = ITEM_SUB_CLASS_2_13, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Shield] = {name = ITEM_SUB_CLASS_4_6, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Holdable] = {name = INVTYPE_HOLDABLE, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.TwoHAxe] = {name = ITEM_SUB_CLASS_2_1, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.TwoHSword] = {name = ITEM_SUB_CLASS_2_8, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.TwoHMace] = {name = ITEM_SUB_CLASS_2_5, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.Staff] = {name = ITEM_SUB_CLASS_2_10, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.Polearm] = {name = ITEM_SUB_CLASS_2_6, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.Bow] = {name = ITEM_SUB_CLASS_2_2, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.Gun] = {name = ITEM_SUB_CLASS_2_3, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.Crossbow] =  {name = ITEM_SUB_CLASS_2_18, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.Thrown] = {name = ITEM_SUB_CLASS_2_16, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.FishingPole] = {name = ITEM_SUB_CLASS_2_20, isWeapon = true, canEnchant = false, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.OtherWeapon] = {name = ITEM_SUB_CLASS_2_14, isWeapon = true, canEnchant = false, canMainHand = true, canOffHand = true, canRanged = false},
};

for categoryID = Enum.TransmogCollectionType.Head, Enum.TransmogCollectionType.Feet do
	for subCategoryID = 0, 5 do
		TRANSMOG_CATEGORIES[categoryID].subCategories[subCategoryID] = {
			name = _G[string.format("ITEM_SUB_CLASS_4_%d", subCategoryID)]
		};
	end
end

local NUM_TRANSMOG_SOURCE_TYPES = 14;
local TRANSMOG_SOURCE_TYPES = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[7] = 5,
	[8] = 6,
	[10] = 7,
	[11] = 8,
	[12] = 9,
	[13] = 10,
	[14] = 11,
	[15] = 12,
	[16] = 13,
	[17] = 14,
};
local HIDDEN_APPEARANCE_SOURCE_TYPES = {
	[6] = true,
	[9] = true,
};
local HIDDEN_NOT_COLLECTED_APPEARANCE_SOURCE_TYPES = {
	[5] = true,
}
local NO_COLLECTION_MESSAGE_SOURCE_TYPES = {
	[6] = true,
}

local MAX_PLAYER_OUTFITS = 16

local CLASS_FLAGS = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 4,
    ["ROGUE"] = 8,
    ["PRIEST"] = 16,
    ["DEATHKNIGHT"] = 32,
    ["SHAMAN"] = 64,
    ["MAGE"] = 128,
    ["WARLOCK"] = 256,
    ["DEMONHUNTER"] = 512,
    ["DRUID"] = 1024,
};

local PLAYER_CLASS_FLAG = CLASS_FLAGS[UNIT_CLASS];
local PLAYER_FACTION_ID = nil;

local BASE_APPEARANCES = {}
local USABLE_APPEARANCES = {}
local NEW_APPEARANCES = {}

local SEARCH_AND_FILTER_CATEGORY = nil;
local SEARCH_AND_FILTER_SUB_CATEGORY = nil;
local SEARCH_AND_FILTER_EXCLUSION = nil;
local SEARCH_AND_FILTER_APPEARANCES = {};

local SEARCH_TYPE = nil;
local SEARCH_TYPES = {};

local SKILL_ID_BY_NAME = {
	[SKILL_NAME_SWORDS] = 43,
	[SKILL_NAME_AXES] = 44,
	[SKILL_NAME_BOWS] = 45,
	[SKILL_NAME_GUNS] = 46,
	[SKILL_NAME_MACES] = 54,
	[SKILL_NAME_TWO_HANDED_SWORDS] = 55,
	[SKILL_NAME_STAVES] = 136,
	[SKILL_NAME_TWO_HANDED_MACES] = 160,
	[SKILL_NAME_TWO_HANDED_AXES] = 172,
	[SKILL_NAME_DAGGERS] = 173,
	[SKILL_NAME_THROWN] = 176,
	[SKILL_NAME_CROSSBOWS] = 226,
	[SKILL_NAME_WANDS] = 228,
	[SKILL_NAME_POLEARMS] = 229,
	[SKILL_NAME_CHIELD] = 433,
	[SKILL_NAME_FIST_WEAPONS] = 473,
	[SKILL_NAME_FISHING] = 356,

	[SKILL_NAME_PLATE_MAIL] = 293,
	[SKILL_NAME_MAIL] = 413,
	[SKILL_NAME_LEATHER] = 414,
	[SKILL_NAME_CLOTH] = 415,
};

local PLAYER_SKILLS = {};
if UNIT_CLASS == "WARRIOR" or UNIT_CLASS == "HUNTER" or UNIT_CLASS == "ROGUE" or UNIT_CLASS == "SHAMAN" or UNIT_CLASS == "DRUID" then
	PLAYER_SKILLS[SKILL_ID_BY_NAME[SKILL_NAME_FIST_WEAPONS]] = true;
end

local SUBCATEGORY_SKILL_ID = {
	[1] = 415,
	[2] = 414,
	[3] = 413,
	[4] = 293,
}

local WEAPON_SKILL_ID_BY_CATEGORY = {
	[12] = 228,
	[13] = 44,
	[14] = 43,
	[15] = 54,
	[16] = 173,
	[17] = 473,
	[18] = 433,
	[20] = 172,
	[21] = 55,
	[22] = 160,
	[23] = 136,
	[24] = 229,
	[25] = 45,
	[26] = 46,
	[27] = 226,
	[28] = 176,
	[29] = 356,
};

local exclusionCategories = {
	[Enum.TransmogCollectionType.OneHAxe] = true,
	[Enum.TransmogCollectionType.OneHSword] = true,
	[Enum.TransmogCollectionType.OneHMace] = true,
	[Enum.TransmogCollectionType.Dagger] = true,
	[Enum.TransmogCollectionType.Fist] = true,
	[Enum.TransmogCollectionType.OtherWeapon] = true,
};

local CATEGORY_MSG = {};
local function CollectItemTypes(categoryID, subCategoryID, invType, classID, subClassID)
	if not subCategoryID then subCategoryID = -1; end

	if not CATEGORY_MSG[categoryID] then CATEGORY_MSG[categoryID] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID] then CATEGORY_MSG[categoryID][subCategoryID] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID][invType] then CATEGORY_MSG[categoryID][subCategoryID][invType] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID][invType][classID] then CATEGORY_MSG[categoryID][subCategoryID][invType][classID] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID][invType][classID][subClassID] then CATEGORY_MSG[categoryID][subCategoryID][invType][classID][subClassID] = true; end
end

local function GetItemModifiedAppearanceCategory(itemModifiedAppearanceID, serverMsg)
	local categoryID, subCategoryID = 0, nil

	local classID, subClassID, equipLocID = select(13, C_Item.GetItemInfo(itemModifiedAppearanceID, nil, nil, nil, true))
	if classID and subClassID and equipLocID  then
		if ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE[equipLocID] then
			categoryID = Enum.TransmogCollectionType[ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE[equipLocID]]
			subCategoryID = subClassID
		elseif WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE[equipLocID] then
			categoryID = Enum.TransmogCollectionType[WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE[equipLocID]]
		elseif WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID] and WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID][subClassID] then
			categoryID = Enum.TransmogCollectionType[WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID][subClassID]]
		end

		if serverMsg then
			CollectItemTypes(categoryID, subCategoryID, equipLocID, classID, subClassID)
		end
	end

	return categoryID, subCategoryID, equipLocID
end

local function IsKnownItemModifiedAppearance(itemModifiedAppearanceID)
	local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID]
	if sourceInfo then
		if HIDDEN_APPEARANCE_SOURCE_TYPES[sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]]
			or bit.band(sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_CLASSMASK], PLAYER_CLASS_FLAG) == 0
			or (PLAYER_FACTION_ID and PLAYER_FACTION_ID < 2 and sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_FACTIONID] ~= 3 and sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_FACTIONID] ~= PLAYER_FACTION_ID)
			or (not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID] and HIDDEN_NOT_COLLECTED_APPEARANCE_SOURCE_TYPES[sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]])
		then
			return false
		else
			return true
		end
	end
	return false
end

local function IsUsableItemModifiedAppearanceByCategory(categoryID, subCategoryID)
	if subCategoryID then
		local armorSkillID = SUBCATEGORY_SKILL_ID[subCategoryID]
		local isSkillKnown = armorSkillID and PLAYER_SKILLS[armorSkillID]
		if not armorSkillID or isSkillKnown then
			return true
		end
	else
		local weaponSkillID = WEAPON_SKILL_ID_BY_CATEGORY[categoryID]
		local isSkillKnown = weaponSkillID and PLAYER_SKILLS[weaponSkillID]
		if not weaponSkillID or isSkillKnown then
			return true
		end
	end
	return false
end

local function IsUsableItemModifiedAppearance(itemModifiedAppearanceID)
	if USABLE_APPEARANCES[itemModifiedAppearanceID] then
		return true
	end
	return false
end

local function IsCollectedAppearance(itemAppearanceID, category, subCategory, exclusion)
	local isTmogCategory = category and subCategory == 5;
	local isExclusion = exclusion and exclusionCategories[category];

	for _, itemModifiedAppearanceID in ipairs(ITEM_APPEARANCE_STORAGE[itemAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]) do
		local categoryID, subCategoryID, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID)

		if ((isExclusion and exclusion ~= invType)
		or (isTmogCategory and categoryID == category and subCategoryID == subCategory)
		or (subCategory and not isTmogCategory and categoryID == category and subCategoryID == subCategory)
		or (not subCategory and not isExclusion and (categoryID == category or not category)))
		and IsUsableItemModifiedAppearance(itemModifiedAppearanceID) and IsKnownItemModifiedAppearance(itemModifiedAppearanceID)
		then
			if SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID] then
				return true
			end
		end
	end

	return false
end

local function SetSearchAndFilterAppearances()
	table.wipe(SEARCH_AND_FILTER_APPEARANCES)

	local isTmogCategory = SEARCH_AND_FILTER_CATEGORY and SEARCH_AND_FILTER_SUB_CATEGORY == 5
	local isExclusion = SEARCH_AND_FILTER_EXCLUSION and exclusionCategories[SEARCH_AND_FILTER_CATEGORY]

	local searchText = C_TransmogCollection.GetSearchText(Enum.TransmogSearchType.Items)
	local isUseSearch = searchText and searchText ~= ""
	local isUseFilters = not C_TransmogCollection.IsUsingDefaultFilters()

	local baseAppearances = BASE_APPEARANCES[SEARCH_AND_FILTER_CATEGORY]
	if baseAppearances then
		local collectedShown = tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_COLLECTED")) == 1
		local uncollectedShown = tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED")) == 1
		local sourceFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SOURCE_FILTERS")) or 0
		local searchID = tonumber(searchText)
		local isGM = IsGMAccount()

		for _, itemAppearanceID in ipairs(baseAppearances) do
			local matchesFilter, isCollected
			if isUseFilters then
				isCollected = IsCollectedAppearance(itemAppearanceID, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY, SEARCH_AND_FILTER_EXCLUSION)
			end
			for _, itemModifiedAppearanceID in ipairs(ITEM_APPEARANCE_STORAGE[itemAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]) do
				local categoryID, subCategoryID, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID);

				if ((isExclusion and SEARCH_AND_FILTER_EXCLUSION ~= invType)
				or (isTmogCategory and categoryID == SEARCH_AND_FILTER_CATEGORY and subCategoryID == SEARCH_AND_FILTER_SUB_CATEGORY)
				or (SEARCH_AND_FILTER_SUB_CATEGORY and not isTmogCategory and categoryID == SEARCH_AND_FILTER_CATEGORY and subCategoryID == SEARCH_AND_FILTER_SUB_CATEGORY)
				or (not SEARCH_AND_FILTER_SUB_CATEGORY and not isExclusion and (categoryID == SEARCH_AND_FILTER_CATEGORY or not SEARCH_AND_FILTER_CATEGORY)))
				and IsUsableItemModifiedAppearance(itemModifiedAppearanceID) and IsKnownItemModifiedAppearance(itemModifiedAppearanceID) then
					if isUseFilters and not collectedShown and isCollected
					or not uncollectedShown and not isCollected
					or not (bit.band(sourceFiltersFlag, bit.lshift(1, (TRANSMOG_SOURCE_TYPES[ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID][ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]] or 0) - 1)) == 0) then
						matchesFilter = nil
					elseif isUseSearch then
						local name = C_Item.GetItemInfo(itemModifiedAppearanceID, nil, nil, true, true);
						if not name or name == "" then
							matchesFilter = nil
						else
							if isGM and searchID and (searchID == itemAppearanceID or searchID == itemModifiedAppearanceID) then
								matchesFilter = true;
							elseif string.find(string.lower(name), searchText, 1, true) ~= nil then
								matchesFilter = true
							else
								matchesFilter = nil
							end
						end
					else
						matchesFilter = true
					end

					if matchesFilter then
						break
					end
				end
			end

			if matchesFilter then
				SEARCH_AND_FILTER_APPEARANCES[#SEARCH_AND_FILTER_APPEARANCES + 1] = itemAppearanceID
			end
		end
	end

	FireCustomClientEvent("TRANSMOG_SEARCH_UPDATED", Enum.TransmogSearchType.Items, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY)
end

local COLLECTED_APPEARANCE = {}
local function CollectItemAppearance(itemAppearanceID, categoryID)
	if not BASE_APPEARANCES[categoryID] then
		BASE_APPEARANCES[categoryID] = {}
		COLLECTED_APPEARANCE[categoryID] = {}
	end

	if not COLLECTED_APPEARANCE[categoryID][itemAppearanceID] then
		COLLECTED_APPEARANCE[categoryID][itemAppearanceID] = true
		BASE_APPEARANCES[categoryID][#BASE_APPEARANCES[categoryID] + 1] = itemAppearanceID
	end
end

local function BuildTransmogCollection()
	table.wipe(CATEGORY_MSG)
	table.wipe(BASE_APPEARANCES)
	table.wipe(USABLE_APPEARANCES)

	for itemModifiedAppearanceID, itemModifiedAppearanceInfo in pairs(ITEM_MODIFIED_APPEARANCE_STORAGE) do
		local categoryID, subCategoryID = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID, true)
		if categoryID ~= 0 then
			local isKnown, isUsable = IsKnownItemModifiedAppearance(itemModifiedAppearanceID)

			if subCategoryID then
				local armorSkillID = SUBCATEGORY_SKILL_ID[subCategoryID];
				local isSkillKnown = armorSkillID and PLAYER_SKILLS[armorSkillID];
				if not armorSkillID or isSkillKnown then
					isUsable = true
				end
			else
				local weaponSkillID = WEAPON_SKILL_ID_BY_CATEGORY[categoryID];
				local isSkillKnown = weaponSkillID and PLAYER_SKILLS[weaponSkillID];
				if not weaponSkillID or isSkillKnown then
					isUsable = true
				end
			end

			if isUsable then
				USABLE_APPEARANCES[itemModifiedAppearanceID] = isUsable

				if isKnown then
					CollectItemAppearance(itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID], categoryID)
				end
			end
		end
	end

	for categoryID, subCategories in pairs(CATEGORY_MSG) do
		for subCategoryID, invTypes in pairs(subCategories) do
			local msg = "";

			if subCategoryID == -1 then
				for invType, classIDs in pairs(invTypes) do
					for classID, subClassIDs in pairs(classIDs) do
						for subClassID in pairs(subClassIDs) do
							msg = strconcat(msg, invType, ":", classID, ":", subClassID, ":");
						end
					end
				end

				CATEGORY_MSG[categoryID] = msg;
			else
				for invType, classIDs in pairs(invTypes) do
					for classID, subClassIDs in pairs(classIDs) do
						for subClassID in pairs(subClassIDs) do
							msg = strconcat(msg, invType, ":", classID, ":", subClassID, ":");
						end
					end
				end

				CATEGORY_MSG[categoryID][subCategoryID] = msg;
			end
		end
	end

	if SEARCH_AND_FILTER_CATEGORY then
		FireCustomClientEvent("TRANSMOG_SEARCH_UPDATED", SEARCH_TYPE, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY);
	end
end

function ReloadCollectionModelData()
	ITEM_APPEARANCE_STORAGE = _G.ITEM_APPEARANCE_STORAGE
	ITEM_MODIFIED_APPEARANCE_STORAGE = _G.ITEM_MODIFIED_APPEARANCE_STORAGE
	ITEM_IGNORED_APPEARANCE_STORAGE = _G.ITEM_IGNORED_APPEARANCE_STORAGE
	BuildTransmogCollection()
end

local ILLUSIONS = {};
local ILLUSION_BY_ENCHANTID = {};
local ILLUSION_BY_SPELLID = {};
local ILLUSION_BY_ITEMID = {};
local ILLUSIONS_BY_ITEM_VISUAL = {};
local COLLECTED_ILLUSIONS = {};
local FILTERED_ILLUSIONS = {};

local NUM_ILLUSION_SOURCE_TYPES = 10;

local ILLUSION_SOURCE_TYPES = {
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

local function SortCollectedIllusions(a, b)
	if IsSpellKnown(COLLECTION_ENCHANTDATA[a].spellID) ~= IsSpellKnown(COLLECTION_ENCHANTDATA[b].spellID) then
		return IsSpellKnown(COLLECTION_ENCHANTDATA[a].spellID);
	end
end

local function CollectCollectedIllusions()
	table.wipe(COLLECTED_ILLUSIONS);

	for illusionIndex, illusions in ipairs(ILLUSIONS) do
		local isCollected = false;

		local hasItemVisual = #illusions > 1;
		if hasItemVisual then
			table.sort(illusions, SortCollectedIllusions);

			for _, enchantIndex in ipairs(illusions) do
				if not isCollected then
					isCollected = IsSpellKnown(COLLECTION_ENCHANTDATA[enchantIndex].spellID);

					if isCollected then
						break;
					end
				end
			end
		else
			isCollected = IsSpellKnown(COLLECTION_ENCHANTDATA[illusions[1]].spellID);
		end

		COLLECTED_ILLUSIONS[illusionIndex] = isCollected;
	end
end

local function SearchAndFilterIllusions()
	table.wipe(FILTERED_ILLUSIONS);

	local searchText = SEARCH_TYPE and SEARCH_TYPES[SEARCH_TYPE] and SEARCH_TYPES[SEARCH_TYPE] ~= "";

	local collectedShown = tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_COLLECTED")) == 0;
	local uncollectedShown = tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_UNCOLLECTED")) == 0;
	local sourceFiltersFlag = tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SOURCE_FILTERS")) or 0;
	local searchID = tonumber(SEARCH_TYPES[SEARCH_TYPE])
	local isGM = IsGMAccount()

	for illusionIndex, illusions in ipairs(ILLUSIONS) do
		local isCollected = COLLECTED_ILLUSIONS[illusionIndex];

		local matchesFilter = false;

		for _, enchantIndex in ipairs(illusions) do
			local enchantData = COLLECTION_ENCHANTDATA[enchantIndex];
			if enchantData then
				local productID, price, originalPrice, currencyType = enchantData.hash and C_StorePublic.GetRolledItemInfoByHash(enchantData.hash)
				if not productID then
					currencyType = enchantData.currency;
				end
				local sourceType;
				if enchantData.holidayText ~= "" then
					sourceType = 6;
				elseif currencyType and currencyType ~= 0 and enchantData.lootType ~= 15 then
					sourceType = 7;
				elseif enchantData.lootType == 0 and enchantData.shopCategory == 3 then
					sourceType = 7;
				else
					sourceType = ILLUSION_SOURCE_TYPES[enchantData.lootType] or 1;
				end
				local sourceFlag = ((productID or sourceType == 7) or enchantData.lootType ~= 0) and bit.lshift(1, sourceType - 1) or 0;

				if not collectedShown and isCollected or not uncollectedShown and not isCollected or not (sourceFiltersFlag == 0 or bit.band(sourceFiltersFlag, sourceFlag) ~= sourceFlag) then
					matchesFilter = false;
				else
					if searchText then
						if not enchantData.name or enchantData.name == "" then
							matchesFilter = false;
						else
							if isGM and searchID and (searchID == enchantData.itemID or searchID == enchantData.spellID or searchID == enchantData.enchId) then
								matchesFilter = true;
							elseif string.find(string.lower(enchantData.name), SEARCH_TYPES[SEARCH_TYPE], 1, true) then
								matchesFilter = true;
							else
								matchesFilter = false;
							end
						end
					else
						matchesFilter = true;
					end
				end

				if matchesFilter then
					FILTERED_ILLUSIONS[#FILTERED_ILLUSIONS + 1] = illusionIndex;
					break
				end
			end
		end
	end

	FireCustomClientEvent("TRANSMOG_SEARCH_UPDATED", Enum.TransmogSearchType.Illusions);
end

local function BuildIllusions()
	table.wipe(ILLUSIONS);
	table.wipe(ILLUSION_BY_ENCHANTID)
	table.wipe(ILLUSION_BY_SPELLID)
	table.wipe(ILLUSION_BY_ITEMID)
	table.wipe(ILLUSIONS_BY_ITEM_VISUAL)

	local indexByItemVisual = {};

	for index, enchantData in ipairs(COLLECTION_ENCHANTDATA) do
		enchantData.name = GetSpellInfo(enchantData.spellID);
		enchantData.icon = select(10, GetItemInfo(enchantData.itemID));

		if enchantData.enchId and enchantData.spellID then
			ILLUSION_BY_ENCHANTID[enchantData.enchId] = enchantData;
			ILLUSION_BY_SPELLID[enchantData.spellID] = enchantData;
			ILLUSION_BY_ITEMID[enchantData.itemID] = enchantData;

			local illusionIndex = #ILLUSIONS + 1;

			local itemVisual = enchantData.itemVisual;
			if itemVisual and itemVisual ~= 0 then
				if not ILLUSIONS_BY_ITEM_VISUAL[itemVisual] then
					ILLUSIONS_BY_ITEM_VISUAL[itemVisual] = {};
				end
				table.insert(ILLUSIONS_BY_ITEM_VISUAL[itemVisual], index);

				if not indexByItemVisual[itemVisual] then
					indexByItemVisual[itemVisual] = illusionIndex;
					ILLUSIONS[illusionIndex] = {index};
				else
					table.insert(ILLUSIONS[indexByItemVisual[itemVisual]], index);
				end
			else
				ILLUSIONS[illusionIndex] = {index};
			end

			FilterOutSpellLearn(enchantData.spellID, enchantData.name)
		end
	end
end

local function PopulateIllusionData()
	CollectCollectedIllusions();
	SearchAndFilterIllusions();
end

function ReloadCollectionIllusionData()
	COLLECTION_ENCHANTDATA = _G.COLLECTION_ENCHANTDATA
	BuildIllusions()
end

BuildIllusions()

local CURRENT_NUM_SKILL_LINES = 0;

local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_LOGIN");
frame:RegisterEvent("SKILL_LINES_CHANGED");
frame:RegisterEvent("SPELL_UPDATE_USABLE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterCustomEvent("VARIABLES_LOADED_INITIAL");

if UNIT_CLASS == "WARRIOR" then
	frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	frame:RegisterEvent("CHARACTER_POINTS_CHANGED");
end

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		self:RegisterCustomEvent("STORE_ROLLED_ITEM_HASHES");

		local function UpdatePlayerFactionID()
			local factionID = C_FactionManager.GetFactionOverride() or 3;
			if PLAYER_FACTION_ID ~= factionID then
				PLAYER_FACTION_ID = factionID;
				BuildTransmogCollection();
			end
		end

		C_FactionManager:RegisterFactionOverrideCallback(UpdatePlayerFactionID, true, true);

		PopulateIllusionData();
	elseif event == "SKILL_LINES_CHANGED" then
		local numSkillLines = GetNumSkillLines();
		if CURRENT_NUM_SKILL_LINES ~= numSkillLines then
			local needUpdate;

			for i = 1, numSkillLines do
				local skillName, header = GetSkillLineInfo(i)

				if not header then
					local skillID = SKILL_ID_BY_NAME[skillName];
					if skillID then
						local oldValue = not not PLAYER_SKILLS[skillID];

						PLAYER_SKILLS[skillID] = true;

						if oldValue ~= PLAYER_SKILLS[skillID] then
							needUpdate = true;
						end
					end
				end
			end

			if needUpdate then
				BuildTransmogCollection();
			end

			CURRENT_NUM_SKILL_LINES = numSkillLines;
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELL_UPDATE_USABLE" or event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "CHARACTER_POINTS_CHANGED" then
		if UNIT_CLASS == "WARRIOR" then
			local isTitanGripSelected = select(5, GetTalentInfo(2, 27)) == 1;
			TRANSMOG_CATEGORIES[Enum.TransmogCollectionType.TwoHAxe].canOffHand = isTitanGripSelected;
			TRANSMOG_CATEGORIES[Enum.TransmogCollectionType.TwoHSword].canOffHand = isTitanGripSelected;
			TRANSMOG_CATEGORIES[Enum.TransmogCollectionType.TwoHMace].canOffHand = isTitanGripSelected;
		end
		if event == "SPELL_UPDATE_USABLE" then
			self:UnregisterEvent(event);
		end
	elseif event == "STORE_ROLLED_ITEM_HASHES" then
		SearchAndFilterIllusions();
	elseif event == "VARIABLES_LOADED_INITIAL" then
		table.wipe(SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES);
		table.wipe(SIRUS_COLLECTION_RECEIVED_APPEARANCES);
		table.wipe(SIRUS_COLLECTION_PLAYER_OUTFITS);
	end
end);

local THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE, THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE;

local function frame_OnUpdate(self)
	if THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE then
		FireCustomClientEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
		THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE = nil;
	end
	if THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		FireCustomClientEvent("TRANSMOG_SOURCE_COLLECTABILITY_UPDATE");
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = nil;
	end

	self:SetScript("OnUpdate", nil);
end

local function GetItemInfoCallback()
	if not THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end

		THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE = true;
	end
end

local function GetItemModifiedAppearanceItemInfo(itemModifiedAppearanceID)
	local name, itemLink, quality, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemModifiedAppearanceID, nil, GetItemInfoCallback, true);
	return name, itemLink, string.format(COLLECTION_ITEM_HYPERLINK_FORMAT, itemModifiedAppearanceID, name or ""), quality, icon;
end

C_TransmogCollection = {};

function C_TransmogCollection.AccountCanCollectSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local hasItemData, canCollect = C_TransmogCollection.AccountCanCollectSource(sourceID)", 2);
	end

	return not not GetItemInfoRaw(sourceID), not not ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID];
end

function C_TransmogCollection.ClearNewAppearance(visualID)
	if type(visualID) == "string" then
		visualID = tonumber(visualID);
	end
	if type(visualID) ~= "number" then
		error("Usage: C_TransmogCollection.ClearNewAppearance(visualID)", 2);
	end

	NEW_APPEARANCES[visualID] = nil;

--	FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
end

function C_TransmogCollection.ClearSearch(searchType)
	if type(searchType) == "string" then
		searchType = tonumber(searchType);
	end
	if type(searchType) ~= "number" then
		error("Usage: C_TransmogCollection.ClearSearch(searchType)", 2);
	end

	if SEARCH_TYPES[searchType] then
		SEARCH_TYPES[searchType] = nil;

		if searchType == Enum.TransmogSearchType.Items then
			SetSearchAndFilterAppearances()
		elseif searchType == Enum.TransmogSearchType.Illusions then
			SearchAndFilterIllusions()
		else
			FireCustomClientEvent("TRANSMOG_SEARCH_UPDATED", searchType, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY)
		end
	end
end

function C_TransmogCollection.DeleteOutfit(outfitID)
	if type(outfitID) == "string" then
		outfitID = tonumber(outfitID);
	end
	if type(outfitID) ~= "number" then
		error("Usage: C_TransmogCollection.DeleteOutfit(outfitID)", 2);
	end

	SendServerMessage("ACMSG_C_I_TRANSMOGRIFY_SET_DELETE", outfitID);
end

function C_TransmogCollection.EndSearch()

end

function C_TransmogCollection.GetAllAppearanceSources(itemAppearanceID)
	local itemAppearanceInfo = ITEM_APPEARANCE_STORAGE[itemAppearanceID];
	if itemAppearanceInfo and itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] then
		local itemModifiedAppearanceIDs = {};
		for _, itemModifiedAppearanceID in ipairs(itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES]) do
			itemModifiedAppearanceIDs[#itemModifiedAppearanceIDs + 1] = itemModifiedAppearanceID;
		end
		return itemModifiedAppearanceIDs;
	end
end

local CUSTOM_CAMERAS = {
	[30606] = 2500,
};

local CATEGORY_BY_INV_TYPE = {[1] = 1, [3] = 2, [4] = 5, [5] = 12, [6] = 9, [7] = 10, [8] = 11, [9] = 7, [10] = 8, [16] = 3, [19] = 6, [20] = 4};
local WEAPON_ALT_CAMERA_BY_INV_TYPE = {
	[13] = {
		[22] = 43,
	},
	[14] = {
		[22] = 44,
	},
	[15] = {
		[22] = 45,
	},
	[16] = {
		[22] = 46,
	},
	[17] = {
		[22] = 47,
	},
};

function C_TransmogCollection.GetAppearanceCameraID(itemAppearanceID, categoryID, subCategoryID, variation)
	if type(itemAppearanceID) == "string" then
		itemAppearanceID = tonumber(itemAppearanceID);
	end
	if type(categoryID) == "string" then
		categoryID = tonumber(categoryID);
	end
	if type(subCategoryID) == "string" then
		subCategoryID = tonumber(subCategoryID);
	end
	if type(itemAppearanceID) ~= "number" or type(categoryID) ~= "number" then
		return 0;
	end

	if CUSTOM_CAMERAS[itemAppearanceID] then
		return CUSTOM_CAMERAS[itemAppearanceID];
	end

	local itemAppearanceInfo = ITEM_APPEARANCE_STORAGE[itemAppearanceID];
	if itemAppearanceInfo then
		for index = 1, #itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
			local itemModifiedAppearanceCategoryID, itemModifiedAppearanceSubCategoryID, invType = GetItemModifiedAppearanceCategory(itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][index]);
			if itemModifiedAppearanceCategoryID ~= 0 and itemModifiedAppearanceCategoryID == categoryID and itemModifiedAppearanceSubCategoryID == subCategoryID then
				if invType then
					if itemModifiedAppearanceCategoryID >= FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE then
						local altCamera = WEAPON_ALT_CAMERA_BY_INV_TYPE[itemModifiedAppearanceCategoryID] and WEAPON_ALT_CAMERA_BY_INV_TYPE[itemModifiedAppearanceCategoryID][invType];
						return altCamera or itemModifiedAppearanceCategoryID;
					else
						return UI_CAMERA[UNIT_RACE] and UI_CAMERA[UNIT_RACE][UNIT_SEX] and UI_CAMERA[UNIT_RACE][UNIT_SEX][CATEGORY_BY_INV_TYPE[invType]] or 0;
					end
				end
			end
		end
	end

	return 0;
end

function C_TransmogCollection.GetAppearanceCameraIDBySource(itemModifiedAppearanceID, variation)
	if type(itemModifiedAppearanceID) == "string" then
		itemModifiedAppearanceID = tonumber(itemModifiedAppearanceID);
	end
	if type(itemModifiedAppearanceID) ~= "number" then
		return 0;
	end

	local sourceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
	if sourceID and CUSTOM_CAMERAS[sourceID] then
		return CUSTOM_CAMERAS[sourceID];
	end

	local categoryID, _, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID);
	if categoryID ~= 0 then
		if categoryID >= FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE then
			local altCamera = WEAPON_ALT_CAMERA_BY_INV_TYPE[categoryID] and WEAPON_ALT_CAMERA_BY_INV_TYPE[categoryID][invType];
			return altCamera or categoryID;
		else
			return UI_CAMERA[UNIT_RACE] and UI_CAMERA[UNIT_RACE][UNIT_SEX] and UI_CAMERA[UNIT_RACE][UNIT_SEX][CATEGORY_BY_INV_TYPE[invType]] or 0;
		end
	end

	return 0;
end

function C_TransmogCollection.GetAppearanceInfoBySource(itemModifiedAppearanceID)
	local itemAppearanceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
	local appearanceInfo = ITEM_APPEARANCE_STORAGE[itemAppearanceID];

	if itemAppearanceID and appearanceInfo then
		local categoryID, subCategoryID = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID);

		local isUsable = IsUsableItemModifiedAppearance(itemModifiedAppearanceID)
		local isKnown = IsKnownItemModifiedAppearance(itemModifiedAppearanceID)

		local appearanceNumSources = 0;
		for i = 1, #appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
			if SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][i]] then
				appearanceNumSources = appearanceNumSources + 1;
			end
		end

		return {
			appearanceID = itemAppearanceID,
			appearanceIsCollected = IsCollectedAppearance(itemAppearanceID, categoryID, subCategoryID),
			appearanceIsUsable = isUsable,
			sourceIsCollected = not not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID],
			sourceIsKnown = isKnown,
			appearanceNumSources = appearanceNumSources,
		}
	end
end

local EJ_PARTY_FLAGS = {1, 2};
local EJ_RAID_FLAGS = {1, 2, 4, 8};

function C_TransmogCollection.GetAppearanceSourceDrops(itemModifiedAppearanceID)
	local creatureID = JOURNALENCOUNTERITEM_BY_ENTRY[itemModifiedAppearanceID] and JOURNALENCOUNTERITEM_BY_ENTRY[itemModifiedAppearanceID][2];
	if creatureID then
		local instanceID = JOURNALENCOUNTER_BY_ENCOUNTER[creatureID] and JOURNALENCOUNTER_BY_ENCOUNTER[creatureID][9];
		if instanceID and JOURNALINSTANCE[instanceID] then
			local difficulties = {};
			local itemDifficultyFlag = JOURNALENCOUNTERITEM_BY_ENTRY[itemModifiedAppearanceID][3] or -1;
			if itemDifficultyFlag ~= -1 then
				local isRaid = bit.band(JOURNALINSTANCE[instanceID][10] or 0, 16) == 16;
				if isRaid then
					for difficultyID, difficultyFlag in ipairs(EJ_RAID_FLAGS) do
						if bit.band(difficultyFlag, itemDifficultyFlag) == itemDifficultyFlag then
							difficulties[#difficulties + 1] = _G["RAID_DIFFICULTY"..difficultyID];
						end
					end
				else
					for difficultyID, difficultyFlag in ipairs(EJ_PARTY_FLAGS) do
						if bit.band(difficultyFlag, itemDifficultyFlag) == itemDifficultyFlag then
							difficulties[#difficulties + 1] = _G["PLAYER_DIFFICULTY"..difficultyID];
						end
					end
				end
			end
			return {
				{
					encounter = JOURNALENCOUNTER_BY_ENCOUNTER[creatureID][2] or "",
					instance = JOURNALINSTANCE[instanceID][1] or "",
					difficulties = difficulties,
				},
			};
		end
	end
end

function C_TransmogCollection.GetAppearanceSourceInfo(itemModifiedAppearanceID)
	if type(itemModifiedAppearanceID) == "string" then
		itemModifiedAppearanceID = tonumber(itemModifiedAppearanceID);
	end

	if type(itemModifiedAppearanceID) ~= "number" then
		return
	end

	local categoryID, subCategoryID, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID);
	local _, itemLink, transmogLink = GetItemModifiedAppearanceItemInfo(itemModifiedAppearanceID);
	local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID];
	if sourceInfo then
		local visualID = sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
		local canEnchat = not ITEM_IGNORED_APPEARANCE_STORAGE[visualID];
		return categoryID, subCategoryID, visualID, canEnchat, SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID], itemLink, transmogLink, TRANSMOG_SOURCE_TYPES[sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]], invType;
	end
	return categoryID or 0, subCategoryID, 0, false, SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID], itemLink, transmogLink, 0, invType;
end

function C_TransmogCollection.GetAppearanceSources(appearanceID, categoryID, subCategoryID, exclusion)
	if type(appearanceID) == "string" then
		appearanceID = tonumber(appearanceID);
	end
	if type(categoryID) == "string" then
		categoryID = tonumber(categoryID);
	end
	if type(subCategoryID) == "string" then
		subCategoryID = tonumber(subCategoryID);
	end
	if type(appearanceID) ~= "number" then
		error("Usage: local sources = C_TransmogCollection.GetAppearanceSources(appearanceID, categoryID[, subCategoryID, exclusion])", 2);
	end

	local sources = {}

	local appearanceInfo = ITEM_APPEARANCE_STORAGE[appearanceID]
	if appearanceInfo then
		local isTmogCategory = categoryID and subCategoryID == 5
		local isExclusion = exclusion and exclusionCategories[categoryID]

		for index = 1, #appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
			local itemModifiedAppearanceID = appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][index]

			if IsUsableItemModifiedAppearance(itemModifiedAppearanceID) and IsKnownItemModifiedAppearance(itemModifiedAppearanceID) then
				local itemModifiedAppearanceCategoryID, itemModifiedAppearanceSubCategoryID, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID)

				local shouldAdd = false

				if isExclusion and exclusion ~= invType
				or isTmogCategory and itemModifiedAppearanceCategoryID == categoryID and itemModifiedAppearanceSubCategoryID == subCategoryID
				or subCategoryID and not isTmogCategory and itemModifiedAppearanceCategoryID == categoryID and itemModifiedAppearanceSubCategoryID == subCategoryID
				or not subCategoryID and not isExclusion and (itemModifiedAppearanceCategoryID == categoryID or not categoryID) then
					shouldAdd = true
				end

				if shouldAdd then
					local name, _, quality, _, _, _, _, _, _, _, _, _, _, _, invType = C_Item.GetItemInfo(itemModifiedAppearanceID, nil, nil)
					sources[#sources + 1] = {
						visualID = appearanceID,
						sourceID = itemModifiedAppearanceID,
						isCollected = not not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID],
						invType = invType,
						categoryID = itemModifiedAppearanceCategoryID,
						subCategoryID = itemModifiedAppearanceSubCategoryID,
						sourceType = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID] and TRANSMOG_SOURCE_TYPES[ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]],
						name = name,
						quality = quality,
						isHideVisual = false
					}
				end
			end
		end
	end

	return sources
end

function C_TransmogCollection.CanEnchantAppearance(appearanceID)
	if type(appearanceID) == "string" then
		appearanceID = tonumber(appearanceID);
	end
	if type(appearanceID) ~= "number" then
		error("Usage: local cantEnchant = C_TransmogCollection.CanEnchantAppearance(appearanceID)", 2);
	end

	if ITEM_APPEARANCE_STORAGE[appearanceID] and not ITEM_IGNORED_APPEARANCE_STORAGE[appearanceID] then
		return true;
	end
	return false;
end

function C_TransmogCollection.GetCategoryAppearances(category, subCategory, exclusion)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: local count = C_TransmogCollection.GetCategoryAppearances(category[, subCategory, exclusion])", 2);
	end

	local appearances = {}

	if SEARCH_AND_FILTER_CATEGORY then
		for _, appearanceID in ipairs(SEARCH_AND_FILTER_APPEARANCES) do
			appearances[#appearances + 1] = {
				isCollected = IsCollectedAppearance(appearanceID, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY, SEARCH_AND_FILTER_EXCLUSION),
				isUsable = true,
				isFavorite = SIRUS_COLLECTION_FAVORITE_APPEARANCES[appearanceID],
				isHideVisual = false,
				hasActiveRequiredHoliday = false,
				uiOrder = appearanceID * 100,
				visualID = appearanceID
			}
		end
	elseif BASE_APPEARANCES[category] then
		for _, itemAppearanceID in ipairs(BASE_APPEARANCES[category]) do
			for _, itemModifiedAppearanceID in ipairs(ITEM_APPEARANCE_STORAGE[itemAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]) do
				local categoryID, subCategoryID, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID)
				if categoryID and categoryID == category and (not subCategory or subCategoryID == subCategory) then
					local shouldAdd = IsUsableItemModifiedAppearance(itemModifiedAppearanceID) and IsKnownItemModifiedAppearance(itemModifiedAppearanceID)
					if exclusion and exclusionCategories[category] then
						if exclusion == invType then
							shouldAdd = false
						end
					end
					if shouldAdd then
						appearances[#appearances + 1] = {
							isCollected = IsCollectedAppearance(itemAppearanceID, category, subCategory, exclusion),
							isUsable = true,
							isFavorite = SIRUS_COLLECTION_FAVORITE_APPEARANCES[itemAppearanceID],
							isHideVisual = false,
							hasActiveRequiredHoliday = false,
							uiOrder = itemAppearanceID * 100,
							visualID = itemAppearanceID
						}
						break
					end
				end
			end
		end
	end

	return appearances
end

function C_TransmogCollection.GetCategoryCollectedCount(category, subCategory, exclusion)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: local count = C_TransmogCollection.GetCategoryCollectedCount(category[, subCategory, exclusion])", 2);
	end

	local count = 0;

	if SEARCH_AND_FILTER_CATEGORY then
		for _, appearanceID in ipairs(SEARCH_AND_FILTER_APPEARANCES) do
			if IsCollectedAppearance(appearanceID, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY, SEARCH_AND_FILTER_EXCLUSION) then
				count = count + 1
			end
		end
	elseif BASE_APPEARANCES[category] then
		for _, itemAppearanceID in ipairs(BASE_APPEARANCES[category]) do
			if IsCollectedAppearance(itemAppearanceID, category, subCategory, exclusion) then
				count = count + 1
			end
		end
	end

	return count;
end

function C_TransmogCollection.GetCategory(classID, subClassID, invType)
	if type(classID) == "string" then
		classID = tonumber(classID);
	end
	if type(subClassID) == "string" then
		subClassID = tonumber(subClassID);
	end
	if type(classID) ~= "number" or type(subClassID) ~= "number" then
		error("Usage: local isUsable, category, subCategory = C_TransmogCollection.GetCategoryByClass(classID, subClassID[, invType])", 2);
	end

	local categoryID, subCategoryID;

	if invType then
		if ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE[invType] then
			categoryID = Enum.TransmogCollectionType[ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE[invType]];
			subCategoryID = subClassID;
		elseif WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE[invType] then
			categoryID = Enum.TransmogCollectionType[WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE[invType]];
		end
	elseif WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID] and WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID][subClassID] then
		categoryID = Enum.TransmogCollectionType[WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID][subClassID]];
	end

	if categoryID then
		if subCategoryID then
			local armorSkillID = SUBCATEGORY_SKILL_ID[subCategoryID];
			local isSkillKnown = armorSkillID and PLAYER_SKILLS[armorSkillID];

			return not armorSkillID or isSkillKnown, categoryID, subCategoryID;
		else
			local weaponSkillID = WEAPON_SKILL_ID_BY_CATEGORY[categoryID];
			local isSkillKnown = weaponSkillID and PLAYER_SKILLS[weaponSkillID];

			return not weaponSkillID or isSkillKnown, categoryID;
		end
	end

	return false;
end

function C_TransmogCollection.GetCategoryInfo(category)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(category) ~= "number" then
		error("Usage: local name, isWeapon, subCategories = C_TransmogCollection.GetCategoryInfo(category)", 2);
	end

	if not BASE_APPEARANCES[category] then
		return
	end

	local categoryInfo = TRANSMOG_CATEGORIES[category];
	if categoryInfo then
		if categoryInfo.subCategories then
			local subCategories = {};
			for subCategory in pairs(categoryInfo.subCategories) do
				subCategories[#subCategories + 1] = subCategory;
			end
			table.sort(subCategories);
			return categoryInfo.name, categoryInfo.isWeapon, categoryInfo.canEnchant, categoryInfo.canMainHand, categoryInfo.canOffHand, categoryInfo.canRanged, subCategories;
		else
			return categoryInfo.name, categoryInfo.isWeapon, categoryInfo.canEnchant, categoryInfo.canMainHand, categoryInfo.canOffHand, categoryInfo.canRanged;
		end
	end
end

function C_TransmogCollection.GetSubCategoryInfo(category, subCategory)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: local name, canEnchant = C_TransmogCollection.GetSubCategoryInfo(category, subCategory)", 2);
	end

	if not BASE_APPEARANCES[category] then
		return
	end

	local categoryInfo = TRANSMOG_CATEGORIES[category];
	if categoryInfo then
		if not subCategory then
			return categoryInfo.name, categoryInfo.canEnchant;
		else
			local skillID = SUBCATEGORY_SKILL_ID[subCategory]
			if not skillID or PLAYER_SKILLS[skillID] then
				categoryInfo = TRANSMOG_CATEGORIES[category].subCategories and TRANSMOG_CATEGORIES[category].subCategories[subCategory];
				if categoryInfo then
					local foundAppearance
					for _, itemAppearanceID in ipairs(BASE_APPEARANCES[category]) do
						for _, itemModifiedAppearanceID in ipairs(ITEM_APPEARANCE_STORAGE[itemAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]) do
							local categoryID, subCategoryID = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID)
							if categoryID == category and subCategoryID == subCategory then
								foundAppearance = true
								break
							end
						end
						if foundAppearance then
							break
						end
					end
					if foundAppearance then
						return categoryInfo.name, categoryInfo.canEnchant
					end
				end
			end
		end
	end
end

function C_TransmogCollection.GetCategoryTotal(category, subCategory, exclusion)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: local total = C_TransmogCollection.GetCategoryTotal(category[, subCategory, exclusion])", 2);
	end

	if SEARCH_AND_FILTER_CATEGORY then
		return #SEARCH_AND_FILTER_APPEARANCES
	elseif BASE_APPEARANCES[category] then
		local total = 0
		for _, itemAppearanceID in ipairs(BASE_APPEARANCES[category]) do
			for _, itemModifiedAppearanceID in ipairs(ITEM_APPEARANCE_STORAGE[itemAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]) do
				local categoryID, subCategoryID, invType = GetItemModifiedAppearanceCategory(itemModifiedAppearanceID)
				if categoryID and categoryID == category and (not subCategory or subCategoryID == subCategory) then
					local shouldAdd = IsUsableItemModifiedAppearance(itemModifiedAppearanceID) and IsKnownItemModifiedAppearance(itemModifiedAppearanceID)
					if exclusion and exclusionCategories[category] then
						if exclusion == invType then
							shouldAdd = false
						end
					end
					if shouldAdd then
						total = total + 1
						break
					end
				end
			end
		end
		return total
	end
	return 0
end

function C_TransmogCollection.GetCollectedShown()
	return tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_COLLECTED")) == 1;
end

function C_TransmogCollection.GetIsAppearanceFavorite(itemAppearanceID)
	if type(itemAppearanceID) == "string" then
		itemAppearanceID = tonumber(itemAppearanceID);
	end
	if type(itemAppearanceID) ~= "number" then
		error("Usage: local isFavorite = C_TransmogCollection.GetIsAppearanceFavorite(itemAppearanceID)", 2);
	end

	return SIRUS_COLLECTION_FAVORITE_APPEARANCES[itemAppearanceID];
end

function C_TransmogCollection.GetLatestAppearance()
	return nil, nil, nil;
end

function C_TransmogCollection.GetNumMaxOutfits()
	return MAX_PLAYER_OUTFITS;
end

function C_TransmogCollection.GetNumTransmogSources()
	return NUM_TRANSMOG_SOURCE_TYPES;
end

function C_TransmogCollection.GetOutfitInfo(outfitID)
	if type(outfitID) == "string" then
		outfitID = tonumber(outfitID);
	end
	if type(outfitID) ~= "number" then
		error("Usage: local name, icon = C_TransmogCollection.GetOutfitInfo(outfitID)", 2);
	end

	local outfitInfo = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID];
	if outfitInfo then
		return outfitInfo.name or "", outfitInfo.icon and strconcat("Interface\\ICONS\\", outfitInfo.icon) or "Interface\\ICONS\\INV_Misc_QuestionMark";
	end
end

function C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID)
	if type(outfitID) == "string" then
		outfitID = tonumber(outfitID);
	end
	if type(outfitID) ~= "number" then
		error("Usage: C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID)", 2);
	end

	local list = {};

	local itemList = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] and SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].itemList;
	local enchantList = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] and SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].enchantList;

	if itemList then
		for _, slotID in ipairs(TransmogSlotOrder) do
			list[slotID] = CreateAndInitFromMixin(ItemTransmogInfoMixin, itemList[slotID] or 0, enchantList and enchantList[slotID] or 0);
		end
	end

	return list;
end

function C_TransmogCollection.GetOutfits()
	local outfitIDs = {};

	for outfitID = 1, MAX_PLAYER_OUTFITS do
		if SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] then
			outfitIDs[#outfitIDs + 1] = outfitID;
		end
	end

	return outfitIDs;
end

function C_TransmogCollection.GetUncollectedShown()
	return tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED")) == 1;
end

function C_TransmogCollection.IsCategoryValidForItem(categoryID, subCategoryID, equippedItemID)
	return true;
end

function C_TransmogCollection.IsNewAppearance(visualID)
	if type(visualID) == "string" then
		visualID = tonumber(visualID);
	end
	if type(visualID) ~= "number" then
		error("Usage: local isNew = C_TransmogCollection.IsNewAppearance(visualID)", 2);
	end

	if NEW_APPEARANCES[visualID] then
		return true;
	end

	return false;
end

function C_TransmogCollection.IsCollectedAppearance(visualID)
	if type(visualID) == "string" then
		visualID = tonumber(visualID);
	end
	if type(visualID) ~= "number" then
		error("Usage: local isCollected = C_TransmogCollection.IsCollectedAppearance(visualID)", 2);
	end

	if ITEM_APPEARANCE_STORAGE[visualID] then
		return IsCollectedAppearance(visualID);
	end

	return false
end

function C_TransmogCollection.IsCollectedSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local isCollected = C_TransmogCollection.IsCollectedSource(sourceID)", 2);
	end

	if ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID] then
		return IsCollectedAppearance(ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID][1]);
	end

	return false;
end

function C_TransmogCollection.IsSourceTypeFilterChecked(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local checked = C_TransmogCollection.IsSourceTypeFilterChecked(index)", 2);
	end

	if not C_CVar:GetCVarBitfield("C_CVAR_WARDROBE_SOURCE_FILTERS", index) then
		return true;
	end

	return false;
end

function C_TransmogCollection.ModifyOutfit(outfitID, itemTransmogInfoList)
	if type(outfitID) == "string" then
		outfitID = tonumber(outfitID);
	end
	if type(outfitID) ~= "number" or type(itemTransmogInfoList) ~= "table" then
		error("Usage: C_TransmogCollection.ModifyOutfit(outfitID, itemTransmogInfoList)", 2);
	end

	local outfitInfo = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID];
	if outfitInfo and outfitInfo.icon and outfitInfo.name then
		local appearances = "";
		for _, slotID in ipairs(TransmogSlotOrder) do
			local itemTransmogInfo = itemTransmogInfoList[slotID];
			if itemTransmogInfo and itemTransmogInfo.appearanceID ~= NO_TRANSMOG_VISUAL_ID then
				if slotID == 16 or slotID == 17 then
					appearances = strconcat(appearances, ";", slotID, ":", itemTransmogInfo.appearanceID, ":", itemTransmogInfo.illusionID or 0);
				else
					appearances = strconcat(appearances, ";", slotID, ":", itemTransmogInfo.appearanceID);
				end
			end
		end

		SendServerMessage("ACMG_C_I_TRANSMOGRIFY_SET_SAVE", strconcat(outfitID, ";", outfitInfo.icon, ";", outfitInfo.name, appearances));
	end
end

function C_TransmogCollection.NewOutfit(name, icon, itemTransmogInfoList)
	if type(itemTransmogInfoList) ~= "table" or type(name) ~= "string" or type(icon) ~= "string" then
		error("Usage: local outfitID = C_TransmogCollection.NewOutfit(name, icon, itemTransmogInfoList)", 2);
	end

	local outfitID = 0;

	for index = 1, MAX_PLAYER_OUTFITS do
		if not SIRUS_COLLECTION_PLAYER_OUTFITS[index] then
			outfitID = index;
			break;
		end
	end

	if outfitID == 0 then
		return;
	end

	local appearances = "";
	for _, slotID in ipairs(TransmogSlotOrder) do
		local itemTransmogInfo = itemTransmogInfoList[slotID];
		if itemTransmogInfo and itemTransmogInfo.appearanceID ~= NO_TRANSMOG_VISUAL_ID then
			if slotID == 16 or slotID == 17 then
				appearances = strconcat(appearances, ";", slotID, ":", itemTransmogInfo.appearanceID, ":", itemTransmogInfo.illusionID or 0);
			else
				appearances = strconcat(appearances, ";", slotID, ":", itemTransmogInfo.appearanceID);
			end
		end
	end

	icon = string.match(icon, "([^\\]+)$") or "INV_Misc_QuestionMark";

	SendServerMessage("ACMG_C_I_TRANSMOGRIFY_SET_SAVE", strconcat(outfitID, ";", icon, ";", name, appearances));

	return outfitID;
end

local function PlayerCanCollectSourceCallBack(itemID)
	if not THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE = true;
	end
end

function C_TransmogCollection.PlayerCanCollectSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)", 2);
	end

	local hasItemData = true
	if not GetItemInfoRaw(sourceID) then
		C_Item.RequestServerCache(sourceID, PlayerCanCollectSourceCallBack)
		hasItemData = false
	end

	return hasItemData, ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID] and IsUsableItemModifiedAppearance(sourceID) and IsKnownItemModifiedAppearance(sourceID);
end

function C_TransmogCollection.PlayerKnowsSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local isKnown = C_TransmogCollection.PlayerKnowsSource(sourceID)", 2);
	end

	if ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID] and IsKnownItemModifiedAppearance(sourceID) then
		return true;
	end

	return false;
end

function C_TransmogCollection.RenameOutfit(outfitID, name)
	if type(outfitID) == "string" then
		outfitID = tonumber(outfitID);
	end
	if type(outfitID) ~= "number" or type(name) ~= "string" then
		error("Usage: C_TransmogCollection.RenameOutfit(outfitID, name)", 2);
	end

	local outfitInfo = SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID];
	if outfitInfo and outfitInfo.icon and outfitInfo.name and outfitInfo.itemList then
		local appearances = "";
		for _, slotID in ipairs(TransmogSlotOrder) do
			local appearanceID = outfitInfo.itemList[slotID];
			if appearanceID and appearanceID ~= NO_TRANSMOG_VISUAL_ID then
				if slotID == 16 or slotID == 17 then
					appearances = strconcat(appearances, ";", slotID, ":", appearanceID, ":", outfitInfo.enchantList[slotID] or 0);
				else
					appearances = strconcat(appearances, ";", slotID, ":", appearanceID);
				end
			end
		end

		SendServerMessage("ACMG_C_I_TRANSMOGRIFY_SET_SAVE", strconcat(outfitID, ";", outfitInfo.icon, ";", name, appearances));
	end
end

function C_TransmogCollection.SetAllSourceTypeFilters(checked)
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index = 1, NUM_TRANSMOG_SOURCE_TYPES do
		C_CVar:SetCVarBitfield("C_CVAR_WARDROBE_SOURCE_FILTERS", index, not checked);
	end

	SetSearchAndFilterAppearances()
end

function C_TransmogCollection.SetCollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = checked and true or false;
	end

	local collectedShown = tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_COLLECTED")) == 1
	if checked ~= collectedShown then
		C_CVar:SetValue("C_CVAR_WARDROBE_SHOW_COLLECTED", checked and "1" or "0");

		SetSearchAndFilterAppearances()
	end
end

function C_TransmogCollection.SetIsAppearanceFavorite(itemAppearanceID, isFavorite)
	if type(itemAppearanceID) == "string" then
		itemAppearanceID = tonumber(itemAppearanceID);
	end
	if type(itemAppearanceID) ~= "number" or isFavorite == nil then
		error("Usage: C_TransmogCollection.SetIsAppearanceFavorite(itemAppearanceID, isFavorite)", 2);
	end

	if isFavorite then
		SendServerMessage("ACMSG_C_A_F", string.format("%d|%d", CHAR_COLLECTION_APPEARANCE, itemAppearanceID));
	else
		SendServerMessage("ACMSG_C_R_F", string.format("%d|%d", CHAR_COLLECTION_APPEARANCE, itemAppearanceID));
	end

	SIRUS_COLLECTION_FAVORITE_APPEARANCES[itemAppearanceID] = isFavorite;

	FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
end

function C_TransmogCollection.SetSearch(searchType, searchText)
	if type(searchType) == "string" then
		searchType = tonumber(searchType);
	end
	if type(searchType) ~= "number" or type(searchText) ~= "string" then
		error("Usage: C_TransmogCollection.SetSearch(searchType, searchText)", 2);
	end

	SEARCH_TYPE = searchType;
	SEARCH_TYPES[searchType] = string.lower(searchText);

	if searchType == Enum.TransmogSearchType.Items then
		SetSearchAndFilterAppearances()
	elseif searchType == Enum.TransmogSearchType.Illusions then
		SearchAndFilterIllusions()
	else
		FireCustomClientEvent("TRANSMOG_SEARCH_UPDATED", searchType, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY)
	end
end

function C_TransmogCollection.SetSearchType(searchType)
	if type(searchType) == "string" then
		searchType = tonumber(searchType);
	end
	if type(searchType) ~= "number" then
		error("Usage: C_TransmogCollection.SetSearchType(searchType)", 2);
	end

	SEARCH_TYPE = searchType;

	if searchType == Enum.TransmogSearchType.Items then
		SetSearchAndFilterAppearances()
	elseif searchType == Enum.TransmogSearchType.Illusions then
		SearchAndFilterIllusions()
	else
		FireCustomClientEvent("TRANSMOG_SEARCH_UPDATED", searchType, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY)
	end
end

function C_TransmogCollection.GetSearchText(searchType)
	if type(searchType) == "string" then
		searchType = tonumber(searchType);
	end
	if type(searchType) ~= "number" then
		error("Usage: C_TransmogCollection.GetSearchText(searchType)", 2);
	end

	return SEARCH_TYPES[searchType];
end

function C_TransmogCollection.SetSearchAndFilterCategory(category, subCategory, exclusion)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: C_TransmogCollection.SetSearchAndFilterCategory(category[, subCategory, exclusion])", 2);
	end

	SEARCH_AND_FILTER_CATEGORY = category;
	SEARCH_AND_FILTER_SUB_CATEGORY = subCategory;
	SEARCH_AND_FILTER_EXCLUSION = exclusion;

	if CATEGORY_MSG[category] then
		if not SIRUS_COLLECTION_RECEIVED_APPEARANCES then
			SIRUS_COLLECTION_RECEIVED_APPEARANCES = {};
		end

		if subCategory then
			if not SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] then
				SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] = {};
			end

			if CATEGORY_MSG[category][subCategory] and not SIRUS_COLLECTION_RECEIVED_APPEARANCES[category][subCategory] then
				SendServerMessage("ACMSG_C_I_GET_MODELS", CATEGORY_MSG[category][subCategory]);

				SIRUS_COLLECTION_RECEIVED_APPEARANCES[category][subCategory] = true;
			end
		else
			if type(CATEGORY_MSG[category]) == "table" then
				if not SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] then
					SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] = {};
				end

				local message = ""
				for subCategoryID, msg in pairs(CATEGORY_MSG[category]) do
					if not SIRUS_COLLECTION_RECEIVED_APPEARANCES[category][subCategoryID] then
						message = strconcat(message, msg)
						SIRUS_COLLECTION_RECEIVED_APPEARANCES[category][subCategoryID] = true
					end
				end
				if message ~= "" then
					SendServerMessage("ACMSG_C_I_GET_MODELS", message)
				end
			else
				if not SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] then
					SendServerMessage("ACMSG_C_I_GET_MODELS", CATEGORY_MSG[category]);

					SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] = true;
				end
			end
		end
	end

	SetSearchAndFilterAppearances()
end

function C_TransmogCollection.SetSourceTypeFilter(index, checked)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" or checked == nil then
		error("Usage: C_TransmogCollection.SetSourceTypeFilter(index, checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if index > 0 and index <= NUM_TRANSMOG_SOURCE_TYPES then
		C_CVar:SetCVarBitfield("C_CVAR_WARDROBE_SOURCE_FILTERS", index, not checked);

		SetSearchAndFilterAppearances()
	end
end

function C_TransmogCollection.SetUncollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = checked and true or false;
	end

	local uncollectedShown = tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED")) == 1;
	if checked ~= uncollectedShown then
		C_CVar:SetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED", checked and "1" or "0");

		SetSearchAndFilterAppearances()
	end
end

function C_TransmogCollection.UpdateUsableAppearances()

end

function C_TransmogCollection.SetDefaultFilters()
	C_CVar:SetValue("C_CVAR_WARDROBE_SHOW_COLLECTED", "1");
	C_CVar:SetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED", "1");
	C_CVar:SetValue("C_CVAR_WARDROBE_SOURCE_FILTERS", "0");

	SetSearchAndFilterAppearances()
end

function C_TransmogCollection.IsUsingDefaultFilters()
	if tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_COLLECTED")) ~= 1 or tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED")) ~= 1 or tonumber(C_CVar:GetValue("C_CVAR_WARDROBE_SOURCE_FILTERS")) ~= 0 then
		return false;
	end

 	return true;
end

function C_TransmogCollection.GetFallbackWeaponAppearance()
	return 2018;
end

function C_TransmogCollection.GetIllusions()
	local illusions = {};

	for _, enchantIndex in ipairs(FILTERED_ILLUSIONS) do
		local enchantData = COLLECTION_ENCHANTDATA[ILLUSIONS[enchantIndex][1]];
		if enchantData then
			illusions[#illusions + 1] = {
				visualID = enchantData.enchId,
				sourceID = enchantData.enchId,
				itemID = enchantData.itemID,
				spellID = enchantData.spellID,
				descriptionText = enchantData.descriptionText,
				priceText = enchantData.priceText,
				holidayText = enchantData.holidayText,
				factionSide = enchantData.factionSide,
				itemVisual = enchantData.itemVisual,
				isCollected = IsSpellKnown(enchantData.spellID),
				isUsable = true,
				isHideVisual = false,
			};
		end
	end

	return illusions;
end

function C_TransmogCollection.GetIllusionsByItemVisual(sourceID, itemVisual)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(itemVisual) == "string" then
		itemVisual = tonumber(itemVisual);
	end
	if type(sourceID) ~= "number" or type(itemVisual) ~= "number" then
		error("Usage: C_TransmogCollection.GetIllusionsByItemVisual(sourceID, itemVisual)", 2);
	end

	local illusions = {};

	if ILLUSIONS_BY_ITEM_VISUAL[itemVisual] then
		for _, enchantIndex in ipairs(ILLUSIONS_BY_ITEM_VISUAL[itemVisual]) do
			local enchantData = COLLECTION_ENCHANTDATA[enchantIndex];

			if enchantData then
				illusions[#illusions + 1] = {
					visualID = enchantData.enchId,
					sourceID = enchantData.enchId,
					itemID = enchantData.itemID,
					spellID = enchantData.spellID,
					descriptionText = enchantData.descriptionText,
					priceText = enchantData.priceText,
					holidayText = enchantData.holidayText,
					factionSide = enchantData.factionSide,
					itemVisual = enchantData.itemVisual,
					isCollected = IsSpellKnown(enchantData.spellID),
					isUsable = true,
					isHideVisual = false,
				};
			end
		end
	else
		local enchantData = ILLUSION_BY_ENCHANTID[sourceID];
		if enchantData then
			illusions[#illusions + 1] = {
				visualID = enchantData.enchId,
				sourceID = enchantData.enchId,
				itemID = enchantData.itemID,
				spellID = enchantData.spellID,
				descriptionText = enchantData.descriptionText,
				priceText = enchantData.priceText,
				holidayText = enchantData.holidayText,
				factionSide = enchantData.factionSide,
				itemVisual = enchantData.itemVisual,
				isCollected = IsSpellKnown(enchantData.spellID),
				isUsable = true,
				isHideVisual = false,
			};
		end
	end

	return illusions;
end

function C_TransmogCollection.GetIllusionInfo(sourceID)
	local illusionInfo = ILLUSION_BY_ENCHANTID[sourceID];
	if illusionInfo then
		return {
			visualID = illusionInfo.enchId,
			sourceID = illusionInfo.enchId,
			icon = illusionInfo.icon,
			isCollected = IsSpellKnown(illusionInfo.spellID),
			isUsable = true,
			isHideVisual = false,
		};
	end
end

function C_TransmogCollection.GetIllusionStrings(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local name = C_TransmogCollection.GetIllusionStrings(sourceID)", 2);
	end

	local illusionInfo = ILLUSION_BY_ENCHANTID[sourceID];
	if illusionInfo then
		local _, _, quality = C_Item.GetItemInfo(illusionInfo.itemID, nil, nil, true);

		return illusionInfo.name, string.format(COLLECTION_ILLUSION_HYPERLINK_FORMAT, sourceID, illusionInfo.name or ""), quality;
	end
end

function C_TransmogCollection.GetIllusionInfoByItemID(itemID)
	if type(itemID) == "string" then
		itemID = tonumber(itemID);
	end
	if type(itemID) ~= "number" then
		error("Usage: local name, sourceID = C_TransmogCollection.GetIllusionInfoByItemID(sourceID)", 2);
	end

	local illusionInfo = ILLUSION_BY_ITEMID[itemID];
	if illusionInfo then
		return illusionInfo.name, illusionInfo.enchId;
	end
end

function C_TransmogCollection.SetIllusionCollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = checked and true or false;
	end

	local collectedShown = tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_COLLECTED")) == 0;
	if checked ~= collectedShown then
		C_CVar:SetValue("C_CVAR_ILLUSION_SHOW_COLLECTED", checked and "0" or "1");

		SearchAndFilterIllusions();
	end
end

function C_TransmogCollection.GetIllusionCollectedShown()
	return tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_COLLECTED")) == 0;
end

function C_TransmogCollection.SetIllusionUncollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = checked and true or false;
	end

	local uncollectedShown = tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_UNCOLLECTED")) == 0;
	if checked ~= uncollectedShown then
		C_CVar:SetValue("C_CVAR_ILLUSION_SHOW_UNCOLLECTED", checked and "0" or "1");

		SearchAndFilterIllusions();
	end
end

function C_TransmogCollection.GetIllusionUncollectedShown()
	return tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_UNCOLLECTED")) == 0;
end

function C_TransmogCollection.SetIllusionSourceTypeFilter(index, checked)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" or checked == nil then
		error("Usage: C_TransmogCollection.SetIllusionSourceTypeFilter(index, checked)", 2);
	end
	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	if index > 0 and index <= NUM_TRANSMOG_SOURCE_TYPES then
		C_CVar:SetCVarBitfield("C_CVAR_ILLUSION_SOURCE_FILTERS", index, not checked);

		SearchAndFilterIllusions();
	end
end

function C_TransmogCollection.IsIllusionSourceTypeFilterChecked(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local checked = C_TransmogCollection.IsIllusionSourceTypeFilterChecked(index)", 2);
	end

	if C_CVar:GetCVarBitfield("C_CVAR_ILLUSION_SOURCE_FILTERS", index) then
		return false;
	end

	return true;
end

local function PopulateHelpText(t, helpPrefix)
	local i = 1;
	local text = _G[helpPrefix..i];
	while text do
		table.insert(t, text);
		i = i + 1;
		text = _G[helpPrefix..i];
	end
end

function C_TransmogCollection.GetHelpTextByCategory(category, subCategory)
	local result = {};

	PopulateHelpText(result, "TRANSMOG_HELP_BODY_");

	if category then
		if category < Enum.TransmogCollectionType.Wand then
			if subCategory ~= 5 then
				if category ~= Enum.TransmogCollectionType.Back and category ~= Enum.TransmogCollectionType.Shirt and category ~= Enum.TransmogCollectionType.Tabard then
					PopulateHelpText(result, "TRANSMOG_HELP_CATEGORY_ARMOR_");
				end
			else
				PopulateHelpText(result, "TRANSMOG_HELP_CATEGORY_TMOG_");
			end
		else
			PopulateHelpText(result, "TRANSMOG_HELP_CATEGORY_"..category.."_");
		end
	end

	return table.concat(result, "\n\n");
end

function C_TransmogCollection.GetItemVisualID(itemID)
	local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID];
	if sourceInfo then
		return sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
	end
end

C_IllusionInfo = {};

function C_IllusionInfo.SetDefaultFilters()
	C_CVar:SetValue("C_CVAR_ILLUSION_SHOW_COLLECTED", "0");
	C_CVar:SetValue("C_CVAR_ILLUSION_SHOW_UNCOLLECTED", "0");
	C_CVar:SetValue("C_CVAR_ILLUSION_SOURCE_FILTERS", "0");

	SearchAndFilterIllusions();
end

function C_IllusionInfo.IsUsingDefaultFilters()
	if tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_COLLECTED")) ~= 0 or tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SHOW_UNCOLLECTED")) ~= 0 or tonumber(C_CVar:GetValue("C_CVAR_ILLUSION_SOURCE_FILTERS")) ~= 0 then
		return false;
	end

 	return true;
end

function C_IllusionInfo.SetAllSourceFilters(checked)
	if checked == nil then
		error("Usage: C_IllusionInfo.SetAllSourceFilters(checked)", 2);
	end

	if type(checked) ~= "boolean" then
		checked = not not checked;
	end

	for index = 1, NUM_ILLUSION_SOURCE_TYPES do
		C_CVar:SetCVarBitfield("C_CVAR_ILLUSION_SOURCE_FILTERS", index, not checked);
	end

	SearchAndFilterIllusions();
end

function EventHandler:ASMSG_C_I_GET_MODELS(msg)
	if not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES then
		SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
	end

	local triggerUpdate = false

	for _, itemID in pairs({StringSplitEx(",", msg)}) do
		itemID = tonumber(itemID);

		if itemID then
			SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemID] = true;

			local itemModifiedAppearanceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID]
			if itemModifiedAppearanceInfo then
				local appearanceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
				if appearanceID then
					if HIDDEN_NOT_COLLECTED_APPEARANCE_SOURCE_TYPES[itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]] then
						local categoryID, subCategoryID = GetItemModifiedAppearanceCategory(itemID);
						if IsUsableItemModifiedAppearanceByCategory(categoryID, subCategoryID) and IsKnownItemModifiedAppearance(itemID) then
							CollectItemAppearance(itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID], categoryID);
							triggerUpdate = true
						end
					end
				end
			end
		end
	end

	if triggerUpdate then
		FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
	end

	if not THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = true;
	end

	SetSearchAndFilterAppearances()
end

function EventHandler:ASMSG_C_I_ADD_MODEL(msg)
	local itemID = tonumber(msg);

	if itemID and itemID ~= 157730 then
		if not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES then
			SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
		end

		SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemID] = true;

		local addCollectionMessage = true

		local itemModifiedAppearanceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID]
		if itemModifiedAppearanceInfo then
			local appearanceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
			if appearanceID then
				NEW_APPEARANCES[appearanceID] = true;
				if HIDDEN_NOT_COLLECTED_APPEARANCE_SOURCE_TYPES[itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]] then
					local categoryID, subCategoryID = GetItemModifiedAppearanceCategory(itemID);
					if IsUsableItemModifiedAppearanceByCategory(categoryID, subCategoryID) and IsKnownItemModifiedAppearance(itemID) then
						CollectItemAppearance(itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID], categoryID)
					end
				end
				FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
			end

			if NO_COLLECTION_MESSAGE_SOURCE_TYPES[itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]] then
				addCollectionMessage = false
			end
		end

		if addCollectionMessage then
			AddChatTyppedMessage("SYSTEM", string.format(COLLECTION_ADD_FORMAT, string.format(COLLECTION_ITEM_HYPERLINK_FORMAT, itemID, GetItemInfo(itemID) or "")));
		end
	end

	if not THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = true;
	end

	SetSearchAndFilterAppearances()
end

function EventHandler:ASMSG_C_I_REMOVE_MODEL(msg)
	local itemID = tonumber(msg);

	if itemID then
		if not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES then
			SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
		end

		SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemID] = nil;

		local appearanceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
		if appearanceID then
			local appearanceInfo = ITEM_APPEARANCE_STORAGE[appearanceID];
			if appearanceInfo then
				local foundCollected;

				for i = 1, #appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
					local sourceID = appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][i];
					if SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[sourceID] then
						foundCollected = true;
						break;
					end
				end

				if not foundCollected then
					SIRUS_COLLECTION_FAVORITE_APPEARANCES[appearanceID] = nil;
					NEW_APPEARANCES[appearanceID] = nil;
				end
			end

			FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
		end

		AddChatTyppedMessage("SYSTEM", string.format(COLLECTION_REMOVE_FORMAT, string.format(COLLECTION_ITEM_HYPERLINK_FORMAT, itemID, GetItemInfo(itemID) or "")));
	end

	if not THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = true;
	end

	SetSearchAndFilterAppearances()
end

function EventHandler:ASMS_C_I_TRANSMOGRIFY_SETS(msg)
	if not SIRUS_COLLECTION_PLAYER_OUTFITS then
		SIRUS_COLLECTION_PLAYER_OUTFITS = {};
	end

	table.wipe(SIRUS_COLLECTION_PLAYER_OUTFITS);

	for _, setMesssage in ipairs({strsplit("|", msg)}) do
		local outfitID, icon, name, items = strsplit(";", setMesssage, 4);
		outfitID = tonumber(outfitID);

		if outfitID then
			SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] = {
				name = name,
				icon = icon,
				itemList = {},
				enchantList = {},
			};

			for _, itemData in ipairs({strsplit(";", items)}) do
				local slotID, itemID, enchantID = strsplit(":", itemData);
				slotID, itemID, enchantID = tonumber(slotID), tonumber(itemID), tonumber(enchantID);
				if slotID and itemID and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] then
					SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].itemList[slotID] = itemID;
				end
				if enchantID and ILLUSION_BY_ENCHANTID[enchantID] then
					SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].enchantList[slotID] = enchantID;
				end
			end
		end
	end

	FireCustomClientEvent("TRANSMOG_OUTFITS_CHANGED");
end

function EventHandler:ASMG_C_I_TRANSMOGRIFY_SET_SAVE(msg)
	local errorIndex = tonumber(msg);
	if errorIndex == 1 then
		UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_SAVE_ERROR_1, 1.0, 0.1, 0.1, 1.0);
	elseif errorIndex == 2 then
		UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_SAVE_ERROR_2, 1.0, 0.1, 0.1, 1.0);
	elseif errorIndex == 3 then
		UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_SAVE_ERROR_3, 1.0, 0.1, 0.1, 1.0);
	end
end

function EventHandler:ASMSG_C_I_TRANSMOGRIFY_SET_DELETE(msg)
	local errorIndex = tonumber(msg);
	if errorIndex == 1 then
		UIErrorsFrame:AddMessage(TRANSMOG_OUTFIT_DELETE_ERROR_1, 1.0, 0.1, 0.1, 1.0);
	end
end

function EventHandler:ASMSG_C_E_ADD(msg)
	local spellID = tonumber(msg);
	if spellID then
		local enchantData = ILLUSION_BY_SPELLID[spellID];
		if enchantData then
			AddChatTyppedMessage("SYSTEM", string.format(COLLECTION_ILLUSION_ADD_FORMAT, string.format(COLLECTION_ILLUSION_HYPERLINK_FORMAT, enchantData.enchId, enchantData.name or "")));

			NEW_APPEARANCES[enchantData.enchId] = true;

			CollectCollectedIllusions();
			SearchAndFilterIllusions();

			FireCustomClientEvent("TRANSMOG_COLLECTION_UPDATED");
		end
	end
end