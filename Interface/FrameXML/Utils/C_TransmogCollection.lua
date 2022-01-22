Enum = Enum or {}
Enum.TransmogCollectionType = {
	None = 0, Head = 1, Shoulder = 2, Back = 3, Chest = 4, Shirt = 5, Tabard = 6, Wrist = 7, Hands = 8, Waist = 9, Legs = 10, Feet = 11,
	Wand = 12, OneHAxe = 13, OneHSword = 14, OneHMace = 15, Dagger = 16, Fist = 17, Shield = 18, Holdable = 19, TwoHAxe = 20,
	TwoHSword = 21, TwoHMace = 22, Staff = 23, Polearm = 24, Bow = 25, Gun = 26, Crossbow = 27, Thrown = 28, FishingPole = 29, OtherWeapon = 30,
};

Enum.TransmogSearchType = {
	Items = 1, BaseSets = 2, UsableSets = 3,
};

TC_CACHE = C_Cache("TRANSMOG_COLLECTION_CACHE", true);

local _GetItemInfo = C_Item._GetItemInfo;
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
	[Enum.TransmogCollectionType.Wand] = {name = ITEM_SUB_CLASS_2_19, isWeapon = true, canEnchant = true, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.OneHAxe] = {name = ITEM_SUB_CLASS_2_0, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.OneHSword] = {name = ITEM_SUB_CLASS_2_7, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.OneHMace] = {name = ITEM_SUB_CLASS_2_4, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Dagger] = {name = ITEM_SUB_CLASS_2_15, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Fist] = {name = ITEM_SUB_CLASS_2_13, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Shield] = {name = ITEM_SUB_CLASS_4_6, isWeapon = true, canEnchant = true, canMainHand = false, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.Holdable] = {name = INVTYPE_HOLDABLE, isWeapon = true, canEnchant = false, canMainHand = false, canOffHand = true, canRanged = false},
	[Enum.TransmogCollectionType.TwoHAxe] = {name = ITEM_SUB_CLASS_2_1, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.TwoHSword] = {name = ITEM_SUB_CLASS_2_8, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.TwoHMace] = {name = ITEM_SUB_CLASS_2_5, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.Staff] = {name = ITEM_SUB_CLASS_2_10, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.Polearm] = {name = ITEM_SUB_CLASS_2_6, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.Bow] = {name = ITEM_SUB_CLASS_2_2, isWeapon = true, canEnchant = true, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.Gun] = {name = ITEM_SUB_CLASS_2_3, isWeapon = true, canEnchant = true, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.Crossbow] =  {name = ITEM_SUB_CLASS_2_18, isWeapon = true, canEnchant = true, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.Thrown] = {name = ITEM_SUB_CLASS_2_16, isWeapon = true, canEnchant = true, canMainHand = false, canOffHand = false, canRanged = true},
	[Enum.TransmogCollectionType.FishingPole] = {name = ITEM_SUB_CLASS_2_20, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = false, canRanged = false},
	[Enum.TransmogCollectionType.OtherWeapon] = {name = ITEM_SUB_CLASS_2_14, isWeapon = true, canEnchant = true, canMainHand = true, canOffHand = true, canRanged = false},
};

for categoryID = Enum.TransmogCollectionType.Head, Enum.TransmogCollectionType.Feet do
	for subCategoryID = 0, 5 do
		TRANSMOG_CATEGORIES[categoryID].subCategories[subCategoryID] = {
			name = _G[string.format("ITEM_SUB_CLASS_4_%d", subCategoryID)]
		};
	end
end

local NUM_TRANSMOG_SOURCE_TYPES = 12;
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
};
local HIDDEN_APPEARANCE_SOURCE_TYPES = {
	[5] = true,
	[6] = true,
	[9] = true,
};

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
local PLAYER_FACTION_ID = 3;

local SEARCH_AND_FILTER_CATEGORY = nil;
local SEARCH_AND_FILTER_SUB_CATEGORY = nil;
local SEARCH_AND_FILTER_APPEARANCES = {};

local COLLECTED_SHOWN = false;
local UNCOLLECTED_SHOWN = false;
local SOURCE_TYPE_FILTER = {};

local SEARCH_TYPE = 1;
local SEARCH_TYPES = {};

local APPEARANCES = {};

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

local ARMOR_SKILL_ID_BY_SUB_CLASS = {
	[4] = {
		[1] = 415,
		[2] = 414,
		[3] = 413,
		[4] = 293,
	}
};

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

local MAX_PLAYER_OUTFITS = 16;

SIRUS_COLLECTION_COLLECTED_APPEARANCES = {};
SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
SIRUS_COLLECTION_FAVORITE_APPEARANCES = {};
SIRUS_COLLECTION_RECEIVED_APPEARANCES = {};
SIRUS_COLLECTION_PLAYER_OUTFITS = {};

local NEW_APPEARANCES = {};

local CATEGORY_MSG = {};
local CURRENT_NUM_SKILL_LINES = 0;

local ITEM_APPEARANCE_STORAGE_SOURCES = 2;

local ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID = 1;
local ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE = 2;
local ITEM_MODIFIED_APPEARANCE_STORAGE_CLASSMASK = 3;
local ITEM_MODIFIED_APPEARANCE_STORAGE_FACTIONID = 4;

local collectedCategory = {};
local function CollectItemAppearance(itemAppearanceID, categoryID, subCategoryID)
	if not ITEM_APPEARANCE_STORAGE[itemAppearanceID] then
		return;
	end

	if not collectedCategory[categoryID] then
		collectedCategory[categoryID] = {};
		APPEARANCES[categoryID] = {};
	end

	if subCategoryID then
		if not collectedCategory[categoryID][subCategoryID] then
			collectedCategory[categoryID][subCategoryID] = {};
			APPEARANCES[categoryID][subCategoryID] = {};
		end

		if not collectedCategory[categoryID][subCategoryID][itemAppearanceID] then
			collectedCategory[categoryID][subCategoryID][itemAppearanceID] = true;
			APPEARANCES[categoryID][subCategoryID][#APPEARANCES[categoryID][subCategoryID] + 1] = itemAppearanceID;
		end
	else
		if not collectedCategory[categoryID][itemAppearanceID] then
			collectedCategory[categoryID][itemAppearanceID] = true;
			APPEARANCES[categoryID][#APPEARANCES[categoryID] + 1] = itemAppearanceID;
		end
	end
end

local function CollectItemTypes(categoryID, subCategoryID, invType, classID, subClassID)
	if not subCategoryID then subCategoryID = -1; end

	if not CATEGORY_MSG[categoryID] then CATEGORY_MSG[categoryID] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID] then CATEGORY_MSG[categoryID][subCategoryID] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID][invType] then CATEGORY_MSG[categoryID][subCategoryID][invType] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID][invType][classID] then CATEGORY_MSG[categoryID][subCategoryID][invType][classID] = {}; end
	if not CATEGORY_MSG[categoryID][subCategoryID][invType][classID][subClassID] then CATEGORY_MSG[categoryID][subCategoryID][invType][classID][subClassID] = true; end
end

function GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID, knownOrUsabe, serverMsg)
	local categoryID, subCategoryID, invType, isUsable, isKnown = 0, nil, 0, false, false;

	local itemCache = ItemsCache[itemModifiedAppearanceID];
	if itemCache then
		local classID, subClassID = itemCache[6] or 0, itemCache[7] or 0;
		invType = itemCache[9] or 0;

		if ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE[invType] then
			categoryID = Enum.TransmogCollectionType[ARMOR_CATEGORY_NAME_BY_INVENTORY_TYPE[invType]];
			subCategoryID = subClassID;
		elseif WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE[invType] then
			categoryID = Enum.TransmogCollectionType[WEAPON_SUB_CATEGORY_BY_INVENTORY_TYPE[invType]];
		elseif WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID] and WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID][subClassID] then
			categoryID = Enum.TransmogCollectionType[WEAPON_SUB_CATEGORY_BY_CLASS_ID[classID][subClassID]];
		end

		if categoryID ~= 0 and knownOrUsabe then
			if serverMsg then
				CollectItemTypes(categoryID, subCategoryID, invType, classID, subClassID);
			end

			local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID];
			if sourceInfo then
				if HIDDEN_APPEARANCE_SOURCE_TYPES[sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]]
					or bit.band(sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_CLASSMASK], PLAYER_CLASS_FLAG) == 0
					or (PLAYER_FACTION_ID < 2 and sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_FACTIONID] ~= 3 and sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_FACTIONID] ~= PLAYER_FACTION_ID)
				then
					isKnown = false;
				else
					isKnown = true;
				end
			end

			if subCategoryID then
				local armorSkillID = ARMOR_SKILL_ID_BY_SUB_CLASS[classID] and ARMOR_SKILL_ID_BY_SUB_CLASS[classID][subClassID];
				local isSkillKnown = armorSkillID and PLAYER_SKILLS[armorSkillID];
				if not armorSkillID or isSkillKnown then
					isUsable = true;
				end
			else
				local weaponSkillID = WEAPON_SKILL_ID_BY_CATEGORY[categoryID];
				local isSkillKnown = weaponSkillID and PLAYER_SKILLS[weaponSkillID];
				if not weaponSkillID or isSkillKnown then
					isUsable = true;
				end
			end
		end
	end

	return categoryID, subCategoryID, invType, isKnown, isUsable;
end

local SearchAndFilterCategory

local function BuildTransmogCollection()
	table.wipe(collectedCategory);
	table.wipe(APPEARANCES);
	table.wipe(CATEGORY_MSG);

	for itemModifiedAppearanceID, itemModifiedAppearanceInfo in pairs(ITEM_MODIFIED_APPEARANCE_STORAGE) do
		local categoryID, subCategoryID, _, isUsable, isKnown = GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID, true, true);
		if isKnown and isUsable then
			CollectItemAppearance(itemModifiedAppearanceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID], categoryID, subCategoryID);
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
		SearchAndFilterCategory();
	end
end

local frame = CreateFrame("Frame");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("SKILL_LINES_CHANGED");
frame:RegisterEvent("SPELL_UPDATE_USABLE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");

if UNIT_CLASS == "WARRIOR" then
	frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
	frame:RegisterEvent("CHARACTER_POINTS_CHANGED");
end

frame:SetScript("OnEvent", function(self, event)
	if event == "VARIABLES_LOADED" then
		local function UpdatePlayerFactionID()
			local factionID = C_FactionManager:GetOriginalFaction() or 3;
			if PLAYER_FACTION_ID ~= factionID then
				PLAYER_FACTION_ID = factionID;
				BuildTransmogCollection();
			end
		end

		C_FactionManager:RegisterFactionOverrideCallback(UpdatePlayerFactionID, true, true);

		COLLECTED_SHOWN = C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_COLLECTED") == "1";
		UNCOLLECTED_SHOWN = C_CVar:GetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED") == "1";

		for index = 1, NUM_TRANSMOG_SOURCE_TYPES do
			SOURCE_TYPE_FILTER[index] = C_CVar:GetCVarBitfield("C_CVAR_WARDROBE_SOURCE_FILTERS", index);
		end
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
	elseif event == "COMMENTATOR_ENTER_WORLD" then
		table.wipe(SIRUS_COLLECTION_COLLECTED_APPEARANCES);
		table.wipe(SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES);
		table.wipe(SIRUS_COLLECTION_RECEIVED_APPEARANCES);
		table.wipe(SIRUS_COLLECTION_PLAYER_OUTFITS);

		self:UnregisterEvent(event);
	elseif event == "PLAYER_TALENT_UPDATE" then
		self:UnregisterEvent("COMMENTATOR_ENTER_WORLD");
		self:UnregisterEvent(event);
	elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELL_UPDATE_USABLE" or event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "CHARACTER_POINTS_CHANGED" then
		if UNIT_CLASS == "WARRIOR" then
			local isTitanGripSelected = select(5, GetTalentInfo(2, 27)) == 1;
			TRANSMOG_CATEGORIES[Enum.TransmogCollectionType.TwoHAxe].canOffHand = isTitanGripSelected;
			TRANSMOG_CATEGORIES[Enum.TransmogCollectionType.TwoHSword].canOffHand = isTitanGripSelected;
			TRANSMOG_CATEGORIES[Enum.TransmogCollectionType.TwoHMace].canOffHand = isTitanGripSelected;
		end

		if event == "PLAYER_ENTERING_WORLD" then
			self:RegisterEvent("PLAYER_TALENT_UPDATE");
			self:RegisterEvent("COMMENTATOR_ENTER_WORLD");
			self:UnregisterEvent(event);
		elseif event == "SPELL_UPDATE_USABLE" then
			self:UnregisterEvent(event);
		end
	end
end);

local THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE, THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE;

local function frame_OnUpdate(self)
	if THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_COLLECTION_ITEM_UPDATE);
		THROTTLED_TRANSMOG_COLLECTION_ITEM_UPDATE = nil;
	end
	if THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_SOURCE_COLLECTABILITY_UPDATE);
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
	local name, itemLink, quality, _, _, _, _, _, _, icon = _GetItemInfo(itemModifiedAppearanceID);
	if not name then
		_, itemLink, quality, _, _, _, _, _, _, icon = GetItemInfo(itemModifiedAppearanceID, nil, GetItemInfoCallback);
	end

	return name, itemLink, string.format(COLLECTION_ITEM_HYPERLINK_FORMAT, itemModifiedAppearanceID, name or ""), quality, icon;
end

function SearchAndFilterCategory()
	table.wipe(SEARCH_AND_FILTER_APPEARANCES);

	local appearances = APPEARANCES[SEARCH_AND_FILTER_CATEGORY];
	if appearances then
		if SEARCH_AND_FILTER_SUB_CATEGORY then
			appearances = appearances[SEARCH_AND_FILTER_SUB_CATEGORY];
		end
	end

	if appearances then
		local searchText = SEARCH_TYPE and SEARCH_TYPES[SEARCH_TYPE] and SEARCH_TYPES[SEARCH_TYPE] ~= "";

		for i = 1, #appearances do
			local itemAppearanceID = appearances[i];
			local itemAppearanceInfo = ITEM_APPEARANCE_STORAGE[itemAppearanceID];
			local isCollected = SIRUS_COLLECTION_COLLECTED_APPEARANCES[itemAppearanceID];
			if itemAppearanceInfo and itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] and #itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] > 0 then
				local matchesFilter = true;

				for j = 1, #itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
					local itemModifiedAppearanceID = itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][j];

					local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID];
					local categoryID, subCategoryID, _, isUsable, isKnown = GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID, true);
					if sourceInfo and isKnown and isUsable then
						if categoryID == SEARCH_AND_FILTER_CATEGORY and subCategoryID == SEARCH_AND_FILTER_SUB_CATEGORY then
							if not COLLECTED_SHOWN and isCollected or not UNCOLLECTED_SHOWN and not isCollected or SOURCE_TYPE_FILTER[TRANSMOG_SOURCE_TYPES[sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]]] then
								matchesFilter = false;
							else
								if searchText then
									local name = GetItemInfo(itemModifiedAppearanceID);
									if not name or name == "" then
										matchesFilter = false;
									elseif string.find(string.lower(name), SEARCH_TYPES[1], 1, true) ~= nil then
										matchesFilter = true;
									else
										matchesFilter = false;
									end
								end
							end

							if matchesFilter then
								break
							end
						end
					end
				end

				if matchesFilter then
					SEARCH_AND_FILTER_APPEARANCES[#SEARCH_AND_FILTER_APPEARANCES + 1] = itemAppearanceID;
				end
			end
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_SEARCH_UPDATED, Enum.TransmogSearchType.Items, SEARCH_AND_FILTER_CATEGORY, SEARCH_AND_FILTER_SUB_CATEGORY);
end

C_TransmogCollection = {};

function C_TransmogCollection.AccountCanCollectSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local hasItemData, canCollect = C_TransmogCollection.AccountCanCollectSource(sourceID)", 2);
	end

	return not not _GetItemInfo(sourceID), not not ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID];
end

function C_TransmogCollection.ClearNewAppearance(visualID)
	if type(visualID) == "string" then
		visualID = tonumber(visualID);
	end
	if type(visualID) ~= "number" then
		error("Usage: C_TransmogCollection.ClearNewAppearance(visualID)", 2);
	end

	NEW_APPEARANCES[visualID] = nil;

--	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_COLLECTION_UPDATED);
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

		SearchAndFilterCategory();
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

	local itemAppearanceInfo = ITEM_APPEARANCE_STORAGE[itemAppearanceID];
	if itemAppearanceInfo then
		for index = 1, #itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
			local itemModifiedAppearanceCategoryID, itemModifiedAppearanceSubCategoryID, invType = GetItemModifiedAppearanceCategoryInfo(itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][index]);
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

	local categoryID, _, invType = GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID);
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
	local sourceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
	local appearanceInfo = ITEM_APPEARANCE_STORAGE[sourceID];

	if sourceID and appearanceInfo then
		local _, _, _, isUsable, isKnown = GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID, true);

		if isUsable and isKnown then
			local appearanceNumSources = 0;
			for i = 1, #appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
				if SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][i]] then
					appearanceNumSources = appearanceNumSources + 1;
				end
			end

			return {
				appearanceID = sourceID,
				appearanceIsCollected = not not SIRUS_COLLECTION_COLLECTED_APPEARANCES[sourceID],
				appearanceIsUsable = isUsable,
				sourceIsCollected = not not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID],
				sourceIsKnown = isKnown,
				appearanceNumSources = appearanceNumSources,
			}
		end
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

	if not itemModifiedAppearanceID then
		return;
	end

	local categoryID, subCategoryID, invType = GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID);
	local _, itemLink, transmogLink = GetItemModifiedAppearanceItemInfo(itemModifiedAppearanceID);
	local sourceInfo = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID];
	if sourceInfo then
		return categoryID, subCategoryID, sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID], true, SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID], itemLink, transmogLink, TRANSMOG_SOURCE_TYPES[sourceInfo[ITEM_MODIFIED_APPEARANCE_STORAGE_SOURCETYPE]], invType;
	end
	return categoryID or 0, subCategoryID, 0, true, SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID], itemLink, transmogLink, 0, invType;
end

function C_TransmogCollection.GetAppearanceSources(appearanceID, categoryID, subCategoryID)
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
		error("Usage: local sources = C_TransmogCollection.GetAppearanceSources(appearanceID, categoryID[, subCategoryID])", 2);
	end

	local sources = {};

	local appearanceInfo = ITEM_APPEARANCE_STORAGE[appearanceID];
	if appearanceInfo then
		local isCollected = SIRUS_COLLECTION_COLLECTED_APPEARANCES[appearanceID];

		for index = 1, #appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
			local itemModifiedAppearanceID = appearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][index];
			local itemModifiedAppearanceCategoryID, itemModifiedAppearanceSubCategoryID, invType, isUsable, isKnown = GetItemModifiedAppearanceCategoryInfo(itemModifiedAppearanceID, true);

			if not categoryID or (isKnown and isUsable and (isCollected or itemModifiedAppearanceCategoryID == categoryID and itemModifiedAppearanceSubCategoryID == subCategoryID)) then
				local name, _, quality = GetItemInfo(itemModifiedAppearanceID);
				sources[#sources + 1] = {
					name = name,
					quality = quality,
					categoryID = itemModifiedAppearanceCategoryID,
					subCategoryID = itemModifiedAppearanceSubCategoryID,
					invType = invType,
					isCollected = not not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemModifiedAppearanceID],
					isHideVisual = false,
					sourceID = itemModifiedAppearanceID,
					sourceType = ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID] and TRANSMOG_SOURCE_TYPES[ITEM_MODIFIED_APPEARANCE_STORAGE[itemModifiedAppearanceID][ITEM_APPEARANCE_STORAGE_SOURCES]],
					visualID = appearanceID
				};
			end
		end
	end

	return sources;
end

local exclusionCategories = {
	[Enum.TransmogCollectionType.OneHAxe] = true,
	[Enum.TransmogCollectionType.OneHSword] = true,
	[Enum.TransmogCollectionType.OneHMace] = true,
	[Enum.TransmogCollectionType.Dagger] = true,
	[Enum.TransmogCollectionType.Fist] = true,
	[Enum.TransmogCollectionType.OtherWeapon] = true,
};

function C_TransmogCollection.GetCategoryAppearances(category, subCategory, exclusion)
	local appearances = {};

	local itemAppearances;

	if category == SEARCH_AND_FILTER_CATEGORY and subCategory == SEARCH_AND_FILTER_SUB_CATEGORY then
		itemAppearances = SEARCH_AND_FILTER_APPEARANCES;
	else
		if type(APPEARANCES[category]) ~= "table" or (subCategory and type(APPEARANCES[category][subCategory]) ~= "table") then
			return appearances;
		end

		itemAppearances = subCategory and APPEARANCES[category][subCategory] or APPEARANCES[category];
	end

	for i = 1, #itemAppearances do
		local itemAppearanceID = itemAppearances[i];

		local shouldAdd = false;

		if exclusion and exclusionCategories[category] then
			local itemAppearanceInfo = ITEM_APPEARANCE_STORAGE[itemAppearanceID];
			if itemAppearanceInfo then
				for j = 1, #itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES] do
					local _, _, invType = GetItemModifiedAppearanceCategoryInfo(itemAppearanceInfo[ITEM_APPEARANCE_STORAGE_SOURCES][j]);
					if exclusion ~= invType then
						shouldAdd = true;
						break;
					end
				end
			end
		else
			shouldAdd = true;
		end

		if shouldAdd then
			appearances[#appearances + 1] = {
				isCollected = not not SIRUS_COLLECTION_COLLECTED_APPEARANCES[itemAppearanceID],
				isUsable = true,
				isFavorite = SIRUS_COLLECTION_FAVORITE_APPEARANCES[itemAppearanceID],
				isHideVisual = false,
				hasActiveRequiredHoliday = false,
				uiOrder = itemAppearanceID * 100,
				visualID = itemAppearanceID
			};
		end
	end

	return appearances;
end

function C_TransmogCollection.GetCategoryCollectedCount(category, subCategory)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: local count = C_TransmogCollection.GetCategoryCollectedCount(category[, subCategory])", 2);
	end

	if type(APPEARANCES[category]) ~= "table" or (subCategory and type(APPEARANCES[category][subCategory]) ~= "table") then
		return 0;
	end

	local count = 0;

	for _, itemAppearanceID in ipairs(subCategory and APPEARANCES[category][subCategory] or APPEARANCES[category]) do
		if SIRUS_COLLECTION_COLLECTED_APPEARANCES[itemAppearanceID] then
			count = count + 1;
		end
	end

	return count;
end

function C_TransmogCollection.GetCategoryInfo(category)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(category) ~= "number" then
		error("Usage: local name, isWeapon, subCategories = C_TransmogCollection.GetCategoryInfo(category)", 2);
	end

	if not APPEARANCES[category] then
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

	local categoryInfo = TRANSMOG_CATEGORIES[category];
	if categoryInfo then
		if not APPEARANCES[category] then
			return;
		end

		if not subCategory then
			return categoryInfo.name, categoryInfo.canEnchant;
		else
			if not APPEARANCES[category][subCategory] then
				return;
			end

			categoryInfo = TRANSMOG_CATEGORIES[category].subCategories and TRANSMOG_CATEGORIES[category].subCategories[subCategory];
			if categoryInfo then
				return categoryInfo.name, categoryInfo.canEnchant;
			end
		end
	end
end

function C_TransmogCollection.GetCategoryTotal(category, subCategory)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: local total = C_TransmogCollection.GetCategoryTotal(category[, subCategory])", 2);
	end

	if type(APPEARANCES[category]) ~= "table" then
		return 0;
	end

	if subCategory then
		return APPEARANCES[category][subCategory] and #APPEARANCES[category][subCategory] or 0;
	else
		return #APPEARANCES[category] or 0;
	end
end

function C_TransmogCollection.GetCollectedShown()
	return COLLECTED_SHOWN;
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
	if itemList then
		for slotID, itemID in pairs(itemList) do
			list[slotID] = CreateAndInitFromMixin(ItemTransmogInfoMixin, itemID);
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
	return UNCOLLECTED_SHOWN;
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

	return not not NEW_APPEARANCES[visualID];
end

function C_TransmogCollection.IsSourceTypeFilterChecked(index)
	if type(index) == "string" then
		index = tonumber(index);
	end
	if type(index) ~= "number" then
		error("Usage: local checked = C_TransmogCollection.IsSourceTypeFilterChecked(index)", 2);
	end

	return SOURCE_TYPE_FILTER[index] and true or false;
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
			appearances = strconcat(appearances, ";", slotID, ":", itemTransmogInfo and itemTransmogInfo.appearanceID or 0);
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
		appearances = strconcat(appearances, ";", slotID, ":", itemTransmogInfo and itemTransmogInfo.appearanceID or 0);
	end

	icon = string.match(icon, "([^\\]+)$") or "INV_Misc_QuestionMark";

	SendServerMessage("ACMG_C_I_TRANSMOGRIFY_SET_SAVE", strconcat(outfitID, ";", icon, ";", name, appearances));

	return outfitID;
end

function C_TransmogCollection.PlayerCanCollectSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local hasItemData, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)", 2);
	end

	local _, _, _, isUsable, isKnown = GetItemModifiedAppearanceCategoryInfo(sourceID, true);

	return not not _GetItemInfo(sourceID), ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID] and isUsable and isKnown;
end

function C_TransmogCollection.PlayerKnowsSource(sourceID)
	if type(sourceID) == "string" then
		sourceID = tonumber(sourceID);
	end
	if type(sourceID) ~= "number" then
		error("Usage: local isKnown = C_TransmogCollection.PlayerKnowsSource(sourceID)", 2);
	end

	if  ITEM_MODIFIED_APPEARANCE_STORAGE[sourceID] and select(5, GetItemModifiedAppearanceCategoryInfo(sourceID, true)) then
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
			appearances = strconcat(appearances, ";", slotID, ":", outfitInfo.itemList[slotID] or 0);
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

		SOURCE_TYPE_FILTER[index] = not checked;
	end

	SearchAndFilterCategory();
end

function C_TransmogCollection.SetCollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = checked and true or false;
	end

	if checked ~= COLLECTED_SHOWN then
		COLLECTED_SHOWN = not COLLECTED_SHOWN;
		C_CVar:SetValue("C_CVAR_WARDROBE_SHOW_COLLECTED", checked and "1" or "0");
		SearchAndFilterCategory();
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
		SendServerMessage("ACMSG_C_I_ADD_FAVORITE", itemAppearanceID);
	else
		SendServerMessage("ACMSG_C_I_REMOVE_FAVORITE", itemAppearanceID);
	end

	SIRUS_COLLECTION_FAVORITE_APPEARANCES[itemAppearanceID] = isFavorite;

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_COLLECTION_UPDATED);
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
	SearchAndFilterCategory();
end

function C_TransmogCollection.SetSearchAndFilterCategory(category, subCategory)
	if type(category) == "string" then
		category = tonumber(category);
	end
	if type(subCategory) == "string" then
		subCategory = tonumber(subCategory);
	end
	if type(category) ~= "number" then
		error("Usage: C_TransmogCollection.SetSearchAndFilterCategory(category[, subCategory])", 2);
	end

	SEARCH_AND_FILTER_CATEGORY = category;
	SEARCH_AND_FILTER_SUB_CATEGORY = subCategory;

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
			if not SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] then
				SendServerMessage("ACMSG_C_I_GET_MODELS", CATEGORY_MSG[category]);

				SIRUS_COLLECTION_RECEIVED_APPEARANCES[category] = true;
			end
		end
	end

	SearchAndFilterCategory();
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

		SOURCE_TYPE_FILTER[index] = not checked;

		SearchAndFilterCategory();
	end
end

function C_TransmogCollection.SetUncollectedShown(checked)
	if type(checked) ~= "boolean" then
		checked = checked and true or false;
	end

	if checked ~= UNCOLLECTED_SHOWN then
		UNCOLLECTED_SHOWN = not UNCOLLECTED_SHOWN;
		C_CVar:SetValue("C_CVAR_WARDROBE_SHOW_UNCOLLECTED", checked and "1" or "0");
		SearchAndFilterCategory();
	end
end

function C_TransmogCollection.UpdateUsableAppearances()

end

function EventHandler:ASMSG_C_I_GET_MODELS(msg)
	if not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES then
		SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
	end
	if not SIRUS_COLLECTION_COLLECTED_APPEARANCES then
		SIRUS_COLLECTION_COLLECTED_APPEARANCES = {};
	end

	for _, itemID in pairs({strsplit(",", msg)}) do
		itemID = tonumber(itemID);

		if itemID then
			SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemID] = true;

			local appearanceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
			if appearanceID and not SIRUS_COLLECTION_COLLECTED_APPEARANCES[appearanceID] then
				SIRUS_COLLECTION_COLLECTED_APPEARANCES[appearanceID] = true;
			end
		end
	end

	if not THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = true;
	end

	SearchAndFilterCategory();
end

function EventHandler:ASMSG_C_I_ADD_MODEL(msg)
	local itemID = tonumber(msg);

	if itemID then
		if not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES then
			SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
		end
		if not SIRUS_COLLECTION_COLLECTED_APPEARANCES then
			SIRUS_COLLECTION_COLLECTED_APPEARANCES = {};
		end

		SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES[itemID] = true;

		local appearanceID = ITEM_MODIFIED_APPEARANCE_STORAGE[itemID] and ITEM_MODIFIED_APPEARANCE_STORAGE[itemID][ITEM_MODIFIED_APPEARANCE_STORAGE_APPERANCEID];
		if appearanceID then
			NEW_APPEARANCES[appearanceID] = true;
			SIRUS_COLLECTION_COLLECTED_APPEARANCES[appearanceID] = true;

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_COLLECTION_UPDATED);
		end

		SendChatMessageType(string.format(COLLECTION_ADD_FORMAT, string.format(COLLECTION_ITEM_HYPERLINK_FORMAT, itemID, GetItemInfo(itemID) or "")), "SYSTEM");
	end

	if not THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = true;
	end

	SearchAndFilterCategory();
end

function EventHandler:ASMSG_C_I_REMOVE_MODEL(msg)
	local itemID = tonumber(msg);

	if itemID then
		if not SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES then
			SIRUS_COLLECTION_COLLECTED_ITEM_APPEARANCES = {};
		end
		if not SIRUS_COLLECTION_COLLECTED_APPEARANCES then
			SIRUS_COLLECTION_COLLECTED_APPEARANCES = {};
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

			FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_COLLECTION_UPDATED);
		end

		SendChatMessageType(string.format(COLLECTION_REMOVE_FORMAT, string.format(COLLECTION_ITEM_HYPERLINK_FORMAT, itemID, GetItemInfo(itemID) or "")), "SYSTEM");
	end

	if not THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE then
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame_OnUpdate);
		end
		THROTTLED_TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = true;
	end

	SearchAndFilterCategory();
end

function EventHandler:ASMSG_C_I_FAVORITES_LIST(msg)
	if not SIRUS_COLLECTION_FAVORITE_APPEARANCES then
		SIRUS_COLLECTION_FAVORITE_APPEARANCES = {};
	end

	for _, appearanceID in pairs({strsplit(",", msg)}) do
		appearanceID = tonumber(appearanceID);

		if appearanceID then
			SIRUS_COLLECTION_FAVORITE_APPEARANCES[appearanceID] = true;
		end
	end
end

function EventHandler:ASMS_C_I_TRANSMOGRIFY_SETS(msg)
	if not SIRUS_COLLECTION_PLAYER_OUTFITS then
		SIRUS_COLLECTION_PLAYER_OUTFITS = {};
	end

	table.wipe(SIRUS_COLLECTION_PLAYER_OUTFITS);

	for _, setMesssage in pairs({strsplit("|", msg)}) do
		local outfitData = {strsplit(";", setMesssage)};

		local outfitID = tonumber(outfitData[1]);
		if outfitID then
			SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID] = {
				name = outfitData[3],
				icon = outfitData[2],
				itemList = {},
			};

			for i = 4, #outfitData do
				local slotID, itemID = string.match(outfitData[i], "(%d+):(%d+)");
				slotID, itemID = tonumber(slotID), tonumber(itemID);
				if slotID and itemID then
					SIRUS_COLLECTION_PLAYER_OUTFITS[outfitID].itemList[slotID] = itemID;
				end
			end
		end
	end

	FireCustomClientEvent(E_CLIEN_CUSTOM_EVENTS.TRANSMOG_OUTFITS_CHANGED);
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