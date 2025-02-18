UIPanelWindows["EncounterJournal"] = { area = "left", pushable = 0, whileDead = 1, width = 830, xOffset = "15", yOffset = "-10"}

JOURNALENCOUNTER_BY_ENCOUNTER = {}
JOURNALENCOUNTERITEM_BY_ENTRY = {}

local EJ_SearchData = {}
local EJ_SearchBuffer = {}
local EJ_slotFilter = 0

local EJ_FLAG_INSTANCE_ISRAID = 16
local EJ_FLAG_INSTANCE_HIDE_DIFFICULTY = 64

local EJ_FLAG_CLASSMASK_WARRIOR = 1
local EJ_FLAG_CLASSMASK_PALADIN = 2
local EJ_FLAG_CLASSMASK_HUNTER = 4
local EJ_FLAG_CLASSMASK_ROGUE = 8
local EJ_FLAG_CLASSMASK_PRIEST = 16
local EJ_FLAG_CLASSMASK_DEATHKINGHT = 32
local EJ_FLAG_CLASSMASK_SHAMAN = 64
local EJ_FLAG_CLASSMASK_MAGE = 128
local EJ_FLAG_CLASSMASK_WARLOCK = 256
local EJ_FLAG_CLASSMASK_MONK = 512
local EJ_FLAG_CLASSMASK_DRUID = 1024
local EJ_FLAG_CLASSMASK_DEMONHUNTER = 2048

local EJ_FLAG_ARMOR_CLOTH = 1
local EJ_FLAG_ARMOR_LEATHER = 2
local EJ_FLAG_ARMOR_MAIL = 4
local EJ_FLAG_ARMOR_PLATE = 8

local armorClassFilterMask = {
	[ITEM_SUB_CLASS_4_1] = EJ_FLAG_ARMOR_CLOTH,
	[ITEM_SUB_CLASS_4_2] = EJ_FLAG_ARMOR_LEATHER,
	[ITEM_SUB_CLASS_4_3] = EJ_FLAG_ARMOR_MAIL,
	[ITEM_SUB_CLASS_4_4] = EJ_FLAG_ARMOR_PLATE
}

local weaponClassFilterMask = {
	[ITEM_SUB_CLASS_2_0] = 111,
	[ITEM_SUB_CLASS_2_10] = 1428,
	[ITEM_SUB_CLASS_2_3] = 13,
	[ITEM_SUB_CLASS_2_2] = 13,
	[ITEM_SUB_CLASS_2_18] = 13,
	[ITEM_SUB_CLASS_2_7] = 431,
	[ITEM_SUB_CLASS_2_13] = 72,
	[ITEM_SUB_CLASS_2_15] = 1501,
	[ITEM_SUB_CLASS_2_16] = 13,
	[ITEM_SUB_CLASS_2_19] = 400,
	[ITEM_SUB_CLASS_2_4] = 1147,
	[ITEM_SUB_CLASS_2_6] = 1028,
	[ITEM_SUB_CLASS_2_1] = 39,
	[ITEM_SUB_CLASS_2_8] = 39,
	[ITEM_SUB_CLASS_2_5] = 1059,
	[ITEM_SUB_CLASS_4_6] = 67,
	[ITEM_SUB_CLASS_4_7] = 2,
	[ITEM_SUB_CLASS_4_8] = 1024,
	[ITEM_SUB_CLASS_4_9] = 64,
	[ITEM_SUB_CLASS_4_10] = 32
}

local classLootData = {
	["WARRIOR"] = {fileName = "WARRIOR", flag = EJ_FLAG_CLASSMASK_WARRIOR, armorMask = EJ_FLAG_ARMOR_PLATE, subArmorMask = EJ_FLAG_ARMOR_MAIL},
	["PALADIN"] = {fileName = "PALADIN", flag = EJ_FLAG_CLASSMASK_PALADIN, armorMask = EJ_FLAG_ARMOR_PLATE, subArmorMask = EJ_FLAG_ARMOR_MAIL},
	["HUNTER"] = {fileName = "HUNTER", flag = EJ_FLAG_CLASSMASK_HUNTER, armorMask = EJ_FLAG_ARMOR_MAIL, subArmorMask = EJ_FLAG_ARMOR_LEATHER},
	["ROGUE"] = {fileName = "ROGUE", flag = EJ_FLAG_CLASSMASK_ROGUE, armorMask = EJ_FLAG_ARMOR_LEATHER},
	["PRIEST"] = {fileName = "PRIEST", flag = EJ_FLAG_CLASSMASK_PRIEST, armorMask = EJ_FLAG_ARMOR_CLOTH},
	["DEATHKNIGHT"] = {fileName = "DEATHKNIGHT", flag = EJ_FLAG_CLASSMASK_DEATHKINGHT, armorMask = EJ_FLAG_ARMOR_PLATE},
	["SHAMAN"] = {fileName = "SHAMAN", flag = EJ_FLAG_CLASSMASK_SHAMAN, armorMask = EJ_FLAG_ARMOR_MAIL, subArmorMask = EJ_FLAG_ARMOR_LEATHER},
	["MAGE"] = {fileName = "MAGE", flag = EJ_FLAG_CLASSMASK_MAGE, armorMask = EJ_FLAG_ARMOR_CLOTH},
	["WARLOCK"] = {fileName = "WARLOCK", flag = EJ_FLAG_CLASSMASK_WARLOCK, armorMask = EJ_FLAG_ARMOR_CLOTH},
	["MONK"] = {fileName = "MONK", flag = EJ_FLAG_CLASSMASK_MONK, armorMask = EJ_FLAG_ARMOR_LEATHER},
	["DRUID"] = {fileName = "DRUID", flag = EJ_FLAG_CLASSMASK_DRUID, armorMask = EJ_FLAG_ARMOR_LEATHER},
	["DEMONHUNTER"] = {fileName = "DEMONHUNTER", flag = EJ_FLAG_CLASSMASK_DEMONHUNTER, armorMask = EJ_FLAG_ARMOR_LEATHER}
}

local EJ_FLAG_SECTION_STARTS_OPEN = 1
local EJ_FLAG_SECTION_HEROIC = 2

local EJ_TIER_SELECTED
local EJ_INSTANCE_SELECTED

local EJ_CONST_TIER_ID = 1
local EJ_CONST_TIER_NAME = 2

local EJ_CONST_INSTANCE_NAME = 1
local EJ_CONST_INSTANCE_DESCRIPTION = 2
local EJ_CONST_INSTANCE_BUTTONICON = 3
local EJ_CONST_INSTANCE_SMALLBUTTONICON = 4
local EJ_CONST_INSTANCE_BACKGROUND = 5
local EJ_CONST_INSTANCE_LOREBACKGROUND = 6
local EJ_CONST_INSTANCE_MAPID = 7
local EJ_CONST_INSTANCE_AREAID = 8
local EJ_CONST_INSTANCE_ORDERINDEX = 9
local EJ_CONST_INSTANCE_FLAGS = 10
local EJ_CONST_INSTANCE_ID = 11
local EJ_CONST_INSTANCE_WORLDMAPAREAID = 12

local EJ_CONST_ENCOUNTER_ID = 1
local EJ_CONST_ENCOUNTER_NAME = 2
local EJ_CONST_ENCOUNTER_DESCRIPTION = 3
local EJ_CONST_ENCOUNTER_MAPPOS1 = 4
local EJ_CONST_ENCOUNTER_MAPPOS2 = 5
local EJ_CONST_ENCOUNTER_FLOORINDEX = 6
local EJ_CONST_ENCOUNTER_WORLDMAPAREAID = 7
local EJ_CONST_ENCOUNTER_FIRSTSECTIONID = 8
local EJ_CONST_ENCOUNTER_INSTANCEID = 9
local EJ_CONST_ENCOUNTER_DIFFICULTYMASK = 10
local EJ_CONST_ENCOUNTER_FLAGS = 11
local EJ_CONST_ENCOUNTER_ORDERINDEX = 12

local EJ_CONST_ENCOUNTERCREATURE_NAME = 1
local EJ_CONST_ENCOUNTERCREATURE_DESCRIPTION = 2
local EJ_CONST_ENCOUNTERCREATURE_CREATUREDISPLAYID = 3
local EJ_CONST_ENCOUNTERCREATURE_ICON = 4
local EJ_CONST_ENCOUNTERCREATURE_ENCOUNTERID = 5
local EJ_CONST_ENCOUNTERCREATURE_ORDERINDEX = 6
local EJ_CONST_ENCOUNTERCREATURE_ID = 7
local EJ_CONST_ENCOUNTERCREATURE_CREATUREENTRY = 8
local EJ_CONST_ENCOUNTERCREATURE_DIFFICULY = 9

local EJ_CONST_ENCOUNTERSECTION_ID = 1
local EJ_CONST_ENCOUNTERSECTION_NAME = 2
local EJ_CONST_ENCOUNTERSECTION_DESCRIPTION = 3
local EJ_CONST_ENCOUNTERSECTION_CREATUREDISPLAYID = 4
local EJ_CONST_ENCOUNTERSECTION_DESCRIPTIONSPELLID = 5
local EJ_CONST_ENCOUNTERSECTION_ICONSPELLID = 6
local EJ_CONST_ENCOUNTERSECTION_ENCOUNTERID = 7
local EJ_CONST_ENCOUNTERSECTION_NEXTSECTIONID = 8
local EJ_CONST_ENCOUNTERSECTION_SUBSECTIONID = 9
local EJ_CONST_ENCOUNTERSECTION_PARENTSECTIONID = 10
local EJ_CONST_ENCOUNTERSECTION_FLAGS = 11
local EJ_CONST_ENCOUNTERSECTION_ICONFLAGS = 12
local EJ_CONST_ENCOUNTERSECTION_ORDERINDEX = 13
local EJ_CONST_ENCOUNTERSECTION_TYPE = 14
local EJ_CONST_ENCOUNTERSECTION_DIFFCULTYMASK = 15
local EJ_CONST_ENCOUNTERSECTION_CREATUREENTRY = 16

local EJ_CONST_ENCOUNTERITEM_ITEMENTRY = 1
local EJ_CONST_ENCOUNTERITEM_ENCOUNTERID = 2
local EJ_CONST_ENCOUNTERITEM_DIFFIULTYMASK = 3
local EJ_CONST_ENCOUNTERITEM_FACTIONMASK = 4
local EJ_CONST_ENCOUNTERITEM_FLAGS = 5
local EJ_CONST_ENCOUNTERITEM_ID = 6
local EJ_CONST_ENCOUNTERITEM_CLASSMASK = 7

local CREATURE_DIFFICULTY_FLAG = {
	ALL = 0,
	[1] = 0x1,
	[2] = 0x2,
	[3] = 0x4,
	[4] = 0x8,
}

local ITEM_CLASS_FLAG = {
	WARRIOR		= 0x001,
	PALADIN		= 0x002,
	HUNTER		= 0x004,
	ROGUE		= 0x008,
	PRIEST		= 0x010,
	DEATHKNIGHT = 0x020,
	SHAMAN		= 0x040,
	MAGE		= 0x080,
	WARLOCK		= 0x100,
	DRUID		= 0x400,
}

local SelectedDifficulty = 1
local SelectedLootFilter

local NO_CLASS_FILTER = 0
local NO_INV_TYPE_FILTER = 0
local LOOTJOURNAL_CLASSFILTER
local LOOTJOURNAL_SPECFILTER

--FILE CONSTANTS
local HEADER_INDENT = 15;
local MAX_CREATURES_PER_ENCOUNTER = 9;

local SECTION_BUTTON_OFFSET = 6;
local SECTION_DESCRIPTION_OFFSET = 27;

local EJ_STYPE_ITEM = 0;
local EJ_STYPE_ENCOUNTER = 1;
local EJ_STYPE_CREATURE = 2;
local EJ_STYPE_SECTION = 3;
local EJ_STYPE_INSTANCE = 4;

local EJ_HTYPE_OVERVIEW = 3;

local EJ_NUM_INSTANCE_PER_ROW = 4;

local EJ_LORE_MAX_HEIGHT = 97;
local EJ_MAX_SECTION_MOVE = 320;

local EJ_NUM_SEARCH_PREVIEWS = 5;
local EJ_SHOW_ALL_SEARCH_RESULTS_INDEX = EJ_NUM_SEARCH_PREVIEWS + 1;

AJ_MAX_NUM_SUGGESTIONS = 3;

-- Priority list for *not my spec*
local overviewPriorities = {
	[1] = "DAMAGER",
	[2] = "HEALER",
	[3] = "TANK",
}

local flagsByRole = {
	["DAMAGER"] = 1,
	["HEALER"] = 2,
	["TANK"] = 0,
}

local rolesByFlag = {
	[0] = "TANK",
	[1] = "DAMAGER",
	[2] = "HEALER"
}

local EJ_Tabs = {};

EJ_Tabs[1] = {frame="overviewScroll", button="overviewTab"};
EJ_Tabs[2] = {frame="lootScroll", button="lootTab"};
EJ_Tabs[3] = {frame="detailsScroll", button="bossTab"};
EJ_Tabs[4] = {frame="model", button="modelTab"};


local EJ_section_openTable = {};


local EJ_LINK_INSTANCE 		= 0;
local EJ_LINK_ENCOUNTER		= 1;
local EJ_LINK_SECTION 		= 3;

local EJ_DIFFICULTIES = {
	{ size = "5",  prefix = PLAYER_DIFFICULTY1, difficultyID = 1, difficultyMask = 1 },
	{ size = "5",  prefix = PLAYER_DIFFICULTY2, difficultyID = 2, difficultyMask = 2 },
	{ size = "10", prefix = PLAYER_DIFFICULTY1, difficultyID = 1, difficultyMask = 1 },
	{ size = "25", prefix = PLAYER_DIFFICULTY1, difficultyID = 2, difficultyMask = 2 },
	{ size = "10", prefix = PLAYER_DIFFICULTY2, difficultyID = 3, difficultyMask = 4 },
	{ size = "25", prefix = PLAYER_DIFFICULTY2, difficultyID = 4, difficultyMask = 8 },
}

local EJ_TIER_DATA =
{
	[1] = { backgroundAtlas = "UI-EJ-Classic", r = 1.0, g = 0.8, b = 0.0 },
	[2] = { backgroundAtlas = "UI-EJ-BurningCrusade", r = 0.6, g = 0.8, b = 0.0 },
	[3] = { backgroundAtlas = "UI-EJ-WrathoftheLichKing", r = 0.2, g = 0.8, b = 1.0 },
	[4] = { backgroundAtlas = "UI-EJ-Cataclysm", r = 1.0, g = 0.4, b = 0.0 },
	[5] = { backgroundAtlas = "UI-EJ-MistsofPandaria", r = 0.0, g = 0.6, b = 0.2 },
	[6] = { backgroundAtlas = "UI-EJ-WarlordsofDraenor", r = 0.82, g = 0.55, b = 0.1 },
	[7] = { backgroundAtlas = "UI-EJ-Legion", r = 1.0, g = 0.8, b = 0.0 },
}

EJButtonMixin = {}

function EJButtonMixin:OnLoad()
	local l, t, _, b, r = self.UpLeft:GetTexCoord();
	self.UpLeft:SetTexCoord(l, l + (r-l)/2, t, b);
	l, t, _, b, r = self.UpRight:GetTexCoord();
	self.UpRight:SetTexCoord(l + (r-l)/2, r, t, b);

	l, t, _, b, r = self.DownLeft:GetTexCoord();
	self.DownLeft:SetTexCoord(l, l + (r-l)/2, t, b);
	l, t, _, b, r = self.DownRight:GetTexCoord();
	self.DownRight:SetTexCoord(l + (r-l)/2, r, t, b);

	l, t, _, b, r = self.HighLeft:GetTexCoord();
	self.HighLeft:SetTexCoord(l, l + (r-l)/2, t, b);
	l, t, _, b, r = self.HighRight:GetTexCoord();
	self.HighRight:SetTexCoord(l + (r-l)/2, r, t, b);
end

function EJButtonMixin:OnMouseDown(button)
	self.UpLeft:Hide();
	self.UpRight:Hide();

	self.DownLeft:Show();
	self.DownRight:Show();
end

function EJButtonMixin:OnMouseUp(button)
	self.UpLeft:Show();
	self.UpRight:Show();

	self.DownLeft:Hide();
	self.DownRight:Hide();
end

function GetEJTierData(tier)
	return EJ_TIER_DATA[tier] or EJ_TIER_DATA[1];
end

ExpansionEnumToEJTierDataTableId = {
	[LE_EXPANSION_CLASSIC] = 1,
	[LE_EXPANSION_BURNING_CRUSADE] = 2,
	[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = 3,
	[LE_EXPANSION_CATACLYSM] = 4,
	[LE_EXPANSION_MISTS_OF_PANDARIA] = 5,
	[LE_EXPANSION_WARLORDS_OF_DRAENOR] = 6,
	[LE_EXPANSION_LEGION] = 7,
}

function GetEJTierDataTableID(expansion)
	local data = ExpansionEnumToEJTierDataTableId[expansion];
	if data then
		return data;
	end

	return ExpansionEnumToEJTierDataTableId[LE_EXPANSION_CLASSIC];
end

local EncounterJournalSlotFilters = {
	{ invType = LE_ITEM_FILTER_TYPE_HEAD,		invTypeName = INVTYPE_HEAD,				equipSlot = "INVTYPE_HEAD" },
	{ invType = LE_ITEM_FILTER_TYPE_NECK,		invTypeName = INVTYPE_NECK,				equipSlot = "INVTYPE_NECK" },
	{ invType = LE_ITEM_FILTER_TYPE_SHOULDER,	invTypeName = INVTYPE_SHOULDER,			equipSlot = "INVTYPE_SHOULDER" },
	{ invType = LE_ITEM_FILTER_TYPE_CLOAK,		invTypeName = INVTYPE_CLOAK,			equipSlot = "INVTYPE_CLOAK" },
	{ invType = LE_ITEM_FILTER_TYPE_CHEST,		invTypeName = INVTYPE_CHEST,			equipSlot = {"INVTYPE_CHEST", "INVTYPE_ROBE"} },
	{ invType = LE_ITEM_FILTER_TYPE_WRIST,		invTypeName = INVTYPE_WRIST,			equipSlot = "INVTYPE_WRIST" },
	{ invType = LE_ITEM_FILTER_TYPE_HAND,		invTypeName = INVTYPE_HAND,				equipSlot = "INVTYPE_HAND" },
	{ invType = LE_ITEM_FILTER_TYPE_WAIST,		invTypeName = INVTYPE_WAIST,			equipSlot = "INVTYPE_WAIST" },
	{ invType = LE_ITEM_FILTER_TYPE_LEGS,		invTypeName = INVTYPE_LEGS,				equipSlot = "INVTYPE_LEGS" },
	{ invType = LE_ITEM_FILTER_TYPE_FEET,		invTypeName = INVTYPE_FEET,				equipSlot = "INVTYPE_FEET" },
	{ invType = LE_ITEM_FILTER_TYPE_MAIN_HAND,	invTypeName = INVTYPE_WEAPONMAINHAND,	equipSlot = "INVTYPE_WEAPONMAINHAND" },
	{ invType = LE_ITEM_FILTER_TYPE_OFF_HAND,	invTypeName = INVTYPE_WEAPONOFFHAND,	equipSlot = {"INVTYPE_SHIELD", "INVTYPE_WEAPONOFFHAND", "INVTYPE_HOLDABLE"} },
	{ invType = LE_ITEM_FILTER_TYPE_2HWEAPON,	invTypeName = INVTYPE_2HWEAPON,			equipSlot = "INVTYPE_2HWEAPON" },
	{ invType = LE_ITEM_FILTER_TYPE_HWEAPON,	invTypeName = INVTYPE_WEAPON,			equipSlot = "INVTYPE_WEAPON" },
	{ invType = LE_ITEM_FILTER_TYPE_RANGED,		invTypeName = INVTYPE_RANGEDRIGHT,		equipSlot = {"INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT"} },
	{ invType = LE_ITEM_FILTER_TYPE_FINGER,		invTypeName = INVTYPE_FINGER,			equipSlot = "INVTYPE_FINGER" },
	{ invType = LE_ITEM_FILTER_TYPE_TRINKET,	invTypeName = INVTYPE_TRINKET,			equipSlot = "INVTYPE_TRINKET" },
}

local BOSS_LOOT_BUTTON_HEIGHT = 45;
local INSTANCE_LOOT_BUTTON_HEIGHT = 64;

local BOSS_BUTTON_FIRST_OFFSET = 10;
local BOSS_BUTTON_SECOND_OFFSET = 15;
local BOSS_BUTTON_HEIGHT = 55;

if IsInterfaceDevClient(true) then
	_G.EJ_SearchData = EJ_SearchData
end

local formatHyperlink = function(link)
	local linkType, linkData = string.split(":", link, 2)
	if linkType == "spell" then
		local spellID = tonumber(linkData)
		if spellID then
			local hyperlink = GetSpellLink(spellID)
			if hyperlink then
				return hyperlink:gsub("|cff71d5ff", "|cff2959D3")
			end
		end
	elseif linkType == "kbase" then
		local dataTypeIndex, entryID = string.split(":", linkData)
		dataTypeIndex = tonumber(dataTypeIndex)
		entryID = tonumber(entryID)

		local text
		if dataTypeIndex == SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE then
			if entryID and entryID > 0 then
				Custom_KnowledgeBase.ForceLoadData()

				local entry = KNOWLEDGEBASE_ARTICLES[entryID]
				if entry and (not entry.hidden or IsGMAccount()) then
					text = Custom_KnowledgeBase.GetArticleHeaderByID(entryID)
				end
			end
		end

		if text then
			return string.format("|cfff5e6bd|Hkbase:%i:%i|h[%s]|h|r", dataTypeIndex, entryID, text)
		end
	end
end

function EJ_GetDifficulty()
	return SelectedDifficulty
end

function EJ_GetDifficultyMask( difficulty )
	local value = EJ_GetDifficultyInfo(difficulty or SelectedDifficulty, EJ_IsRaid(EncounterJournal.instanceID))

    if value then
        return value.difficultyMask
    end

    return 1
end

function EJ_GetDifficultyByMask(difficultyMask, instanceID)
	instanceID = instanceID or EncounterJournal.instanceID

	local isRaid = EJ_IsRaid(instanceID)

	for i = 1, #EJ_DIFFICULTIES do
		if isRaid == EJ_DIFFICULTIES[i].size ~= "5" and bit.band(EJ_DIFFICULTIES[i].difficultyMask, difficultyMask) == difficultyMask then
			return EJ_DIFFICULTIES[i].difficultyID
		end
	end
end

function EJ_GetDifficultyInfo( difficultyID, isRaid )
	for i = 1, #EJ_DIFFICULTIES do
        local _isRaid = (EJ_DIFFICULTIES[i].size ~= "5")
        if EJ_DIFFICULTIES[i].difficultyID == difficultyID and isRaid == _isRaid then
            return EJ_DIFFICULTIES[i]
        end
    end

    return nil
end

function EJ_IsValidInstanceDifficulty( difficulty, instanceID )
 	local bossData = JOURNALENCOUNTER[instanceID or EncounterJournal.instanceID]
    local mask = 0
    local isRaid = EJ_IsRaid(instanceID or EncounterJournal.instanceID)
    local info = EJ_GetDifficultyInfo(difficulty, isRaid)

    if not info or not bossData then
        return false
    end

    for key, data in pairs(bossData) do
        mask = data[EJ_CONST_ENCOUNTER_DIFFICULTYMASK]
        if mask == -1 or bit.band(mask, EJ_GetDifficultyMask(difficulty)) == EJ_GetDifficultyMask(difficulty) then
            return true
        end
    end

    return false
end

function EJ_GetNumTiers()
	return JOURNALTIER and tCount(JOURNALTIER) or nil
end

function EJ_GetCurrentTier()
	return EJ_TIER_SELECTED or 3
end

function EJ_GetTierInfo( index )
	if JOURNALTIER and JOURNALTIER[index] then
		local name = JOURNALTIER[index][EJ_CONST_TIER_NAME]
		local tierID = JOURNALTIER[index][EJ_CONST_TIER_ID]
		local hyperlink = string.format("|cff66bbff|Hjournal:3:%d:0|h[%s]|h|r", index, name)

		return name, hyperlink, tierID
	end
	return nil
end

function EJ_SelectTier( index )
	EJ_TIER_SELECTED = index
end

local INSTANCE_REALM_FLAG = {
	[E_REALM_ID.SCOURGE] = 0x80,
	[E_REALM_ID.ALGALON] = 0x100,
	[E_REALM_ID.SIRUS] = 0x200,
	[E_REALM_ID.SOULSEEKER] = 0x400,
};

local function sortInstancesByOrderIndex(idA, idB)
	return JOURNALINSTANCE[idA][EJ_CONST_INSTANCE_ORDERINDEX] < JOURNALINSTANCE[idB][EJ_CONST_INSTANCE_ORDERINDEX]
end

local INSTANCE_BY_INDEX = {}

function EJ_GetInstanceByIndex(index, isRaid)
	isRaid = not not isRaid

	local tierID = select(3, EJ_GetTierInfo(EJ_GetCurrentTier())) or 1
	local realmFlag = INSTANCE_REALM_FLAG[C_Service.GetRealmID() or 0] or 0

	if INSTANCE_BY_INDEX.tierID ~= tierID or INSTANCE_BY_INDEX.realmFlag ~= realmFlag or INSTANCE_BY_INDEX.isRaid ~= isRaid then
		table.wipe(INSTANCE_BY_INDEX)

		for id, data in pairs(JOURNALINSTANCE) do
			local instanceID = data[EJ_CONST_INSTANCE_ID]
			if JOURNALTIERXINSTANCE[instanceID] == tierID
			and bit.band(data[EJ_CONST_INSTANCE_FLAGS], realmFlag) == 0
			and (bit.band(data[EJ_CONST_INSTANCE_FLAGS], EJ_FLAG_INSTANCE_ISRAID) ~= 0) == isRaid
			and C_EncounterJournal.IsInstanceOpen(instanceID)
			then
				table.insert(INSTANCE_BY_INDEX, id)
			end
		end

		table.sort(INSTANCE_BY_INDEX, sortInstancesByOrderIndex)

		INSTANCE_BY_INDEX.tierID = tierID
		INSTANCE_BY_INDEX.realmFlag = realmFlag
		INSTANCE_BY_INDEX.isRaid = isRaid
	end

	local id = INSTANCE_BY_INDEX[index]
	local data = id and JOURNALINSTANCE[id]
	if data then
		local instanceID = data[EJ_CONST_INSTANCE_ID]
		local name = data[EJ_CONST_INSTANCE_NAME]
		local description = data[EJ_CONST_INSTANCE_DESCRIPTION]
		local bgImage = data[EJ_CONST_INSTANCE_BACKGROUND]
		local buttonImage = data[EJ_CONST_INSTANCE_BUTTONICON]
		local loreImage = data[EJ_CONST_INSTANCE_LOREBACKGROUND]
		local buttonSmallImage = data[EJ_CONST_INSTANCE_SMALLBUTTONICON]
		local mapID = data[EJ_CONST_INSTANCE_MAPID]
		local areaMapID = data[EJ_CONST_INSTANCE_AREAID]
		local hyperlink = EJ_LinkGenerate(name, 0, instanceID, nil)
		local shouldDisplayDifficulty = bit.band(data[EJ_CONST_INSTANCE_FLAGS], EJ_FLAG_INSTANCE_HIDE_DIFFICULTY) ~= EJ_FLAG_INSTANCE_HIDE_DIFFICULTY

		return instanceID, name, description, bgImage, buttonImage, loreImage, buttonSmallImage, areaMapID, hyperlink, shouldDisplayDifficulty, mapID
	end
end

function EJ_GetCurrentInstance()
	local currentMapAreaID = GetCurrentMapAreaID()

	for id, data in pairs(JOURNALINSTANCE) do
		if data[EJ_CONST_INSTANCE_WORLDMAPAREAID] == (currentMapAreaID - 1) then
			return id
		end
	end

	return nil
end

function EJ_SelectInstance( instanceID )
	EJ_INSTANCE_SELECTED = instanceID
end

function EJ_GetInstanceInfo( instanceID )
	instanceID = instanceID or EncounterJournal.instanceID

	if instanceID and JOURNALINSTANCE[instanceID] and C_EncounterJournal.IsInstanceOpen(instanceID) then
		local data = JOURNALINSTANCE[instanceID]
		local name = data[EJ_CONST_INSTANCE_NAME]
		local description = data[EJ_CONST_INSTANCE_DESCRIPTION]
		local bgImage = data[EJ_CONST_INSTANCE_BACKGROUND]
		local buttonImage = data[EJ_CONST_INSTANCE_BUTTONICON]
		local loreImage = data[EJ_CONST_INSTANCE_LOREBACKGROUND]
		local buttonSmallImage = data[EJ_CONST_INSTANCE_SMALLBUTTONICON]
		local areaMapID = data[EJ_CONST_INSTANCE_WORLDMAPAREAID]
		local mapID = data[EJ_CONST_INSTANCE_MAPID]
		local hyperlink = EJ_LinkGenerate(name, 0, instanceID)
		local shouldDisplayDifficulty = bit.band(data[EJ_CONST_INSTANCE_FLAGS], EJ_FLAG_INSTANCE_HIDE_DIFFICULTY) ~= EJ_FLAG_INSTANCE_HIDE_DIFFICULTY

		description = string.gsub(description, "{(kbase:[^}]+)}", formatHyperlink)

		return name, description, bgImage, buttonImage, loreImage, buttonSmallImage, areaMapID, hyperlink, shouldDisplayDifficulty, mapID
	end

	return nil
end

function EJ_IsRaid( instanceID )
	if instanceID and JOURNALINSTANCE[instanceID] then
		if bit.band(JOURNALINSTANCE[instanceID][EJ_CONST_INSTANCE_FLAGS], EJ_FLAG_INSTANCE_ISRAID) == EJ_FLAG_INSTANCE_ISRAID then
			return true
		end
	end
	return false
end

function EJ_GetEncounterInfoByIndex( index, instanceID )
	if not EncounterJournal.instanceID and not instanceID then
		return nil
	end

	local buffer = {}
	local factionGroup = UnitFactionGroup("player")
	if factionGroup == "Renegade" then
		factionGroup = select(3, C_FactionManager.GetFactionInfoOriginal())
	end
	local factionFlag = factionGroup == "Alliance" and 4 or 8

	local difficulty = SelectedDifficulty

	if not instanceID then
		instanceID = EncounterJournal.instanceID
	end

	if not JOURNALENCOUNTER[instanceID] then
		return nil
	end

	if not EJ_IsValidInstanceDifficulty(difficulty, EJ_GetCurrentInstance()) and WorldMapFrame:IsShown() then
		difficulty = EJ_GetValidationDifficulty(1, EJ_GetCurrentInstance())
	end

	for bossID, data in pairs(JOURNALENCOUNTER[instanceID]) do
		if data[EJ_CONST_ENCOUNTER_DIFFICULTYMASK] == -1 or bit.band(data[EJ_CONST_ENCOUNTER_DIFFICULTYMASK],  EJ_GetDifficultyMask(difficulty)) ==  EJ_GetDifficultyMask(difficulty) then
			if data[EJ_CONST_ENCOUNTER_FLAGS] == 0 or bit.band(data[EJ_CONST_ENCOUNTER_FLAGS], factionFlag) == factionFlag then
				table.insert(buffer, data)
			end
		end
	end

	if #buffer > 0 then
		table.sort(buffer, function(a, b)
			return a[EJ_CONST_ENCOUNTER_ORDERINDEX] < b[EJ_CONST_ENCOUNTER_ORDERINDEX]
		end)

		if buffer[index] then
			local data = buffer[index]
			local name = data[EJ_CONST_ENCOUNTER_NAME]
			local description = data[EJ_CONST_ENCOUNTER_DESCRIPTION]
			local bossID = data[EJ_CONST_ENCOUNTER_ID]
			local rootSectionID = 1 -- ДОДЕЛАТЬ
			local map_pos1 = data[EJ_CONST_ENCOUNTER_MAPPOS1]
			local map_pos2 = data[EJ_CONST_ENCOUNTER_MAPPOS2]
			local floorIndex = data[EJ_CONST_ENCOUNTER_FLOORINDEX]
			local worldMapAreaID = data[EJ_CONST_ENCOUNTER_WORLDMAPAREAID]
			local link = EJ_LinkGenerate( name, 1, bossID, difficulty )

			return name, description, bossID, rootSectionID, link, instanceID, map_pos1, map_pos2, floorIndex, worldMapAreaID
		end
	end

	return nil
end

function EJ_GetCreatureInfo( index, encounterID )
	if not encounterID and EncounterJournal.encounterID then
		encounterID = EncounterJournal.encounterID
	end

	if not index or not JOURNALENCOUNTERCREATURE[encounterID] then
		return nil
	end

	local difficulty = EJ_GetDifficulty()
	local buffer = {}

	for _, data in ipairs(JOURNALENCOUNTERCREATURE[encounterID]) do
		local creatureDifficulty = data[EJ_CONST_ENCOUNTERCREATURE_DIFFICULY]
		if creatureDifficulty == CREATURE_DIFFICULTY_FLAG.ALL or bit.band(creatureDifficulty, CREATURE_DIFFICULTY_FLAG[difficulty]) ~= 0 then
			table.insert(buffer, data)
		end
	end

	if #buffer > 0 then
		table.sort(buffer, function(a, b)
			return a[EJ_CONST_ENCOUNTERCREATURE_ORDERINDEX] < b[EJ_CONST_ENCOUNTERCREATURE_ORDERINDEX]
		end)

		if buffer[index] then
			local data = buffer[index]
			local id = data[EJ_CONST_ENCOUNTERCREATURE_ID]
			local name = data[EJ_CONST_ENCOUNTERCREATURE_NAME]
			local description = data[EJ_CONST_ENCOUNTERCREATURE_DESCRIPTION]
			local displayInfo = data[EJ_CONST_ENCOUNTERCREATURE_CREATUREDISPLAYID]
			local iconImage = data[EJ_CONST_ENCOUNTERCREATURE_ICON] ~= "" and data[EJ_CONST_ENCOUNTERCREATURE_ICON] or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default"
			local creatureEntry = data[EJ_CONST_ENCOUNTERCREATURE_CREATUREENTRY]
			local encounterID = data[EJ_CONST_ENCOUNTERCREATURE_ENCOUNTERID]
			return id, name, description, displayInfo, iconImage, creatureEntry, encounterID
		end
	end

	return nil
end

function EJ_GetSectionInfo( sectionID )
    local currentDiffMask = EJ_GetDifficultyMask(SelectedDifficulty);
    if JOURNALENCOUNTERSECTION[sectionID] then
        local data = JOURNALENCOUNTERSECTION[sectionID]
        local title = data[EJ_CONST_ENCOUNTERSECTION_NAME]
        local description = data[EJ_CONST_ENCOUNTERSECTION_DESCRIPTION]
        local depth = data[EJ_CONST_ENCOUNTERSECTION_TYPE]
        local abilityIcon = data[EJ_CONST_ENCOUNTERSECTION_DESCRIPTIONSPELLID] > 0 and select(3, GetSpellInfo(data[EJ_CONST_ENCOUNTERSECTION_DESCRIPTIONSPELLID])) or select(3, GetSpellInfo(data[EJ_CONST_ENCOUNTERSECTION_ICONSPELLID]))
        local displayInfo = data[EJ_CONST_ENCOUNTERSECTION_CREATUREDISPLAYID]
        local siblingID = data[EJ_CONST_ENCOUNTERSECTION_NEXTSECTIONID] or nil
        local nextSectionID = data[EJ_CONST_ENCOUNTERSECTION_SUBSECTIONID] or nil
        local filteredByDifficulty = data[EJ_CONST_ENCOUNTERSECTION_DIFFCULTYMASK] ~= -1 and bit.band(data[EJ_CONST_ENCOUNTERSECTION_DIFFCULTYMASK], currentDiffMask) ~=  currentDiffMask
        local link = EJ_LinkGenerate( title, 2, sectionID, SelectedDifficulty )
        local startsOpen = bit.band(data[EJ_CONST_ENCOUNTERSECTION_FLAGS], EJ_FLAG_SECTION_STARTS_OPEN) == EJ_FLAG_SECTION_STARTS_OPEN
        local creatureEntry = data[EJ_CONST_ENCOUNTERSECTION_CREATUREENTRY]

        local iconFlags = {}
        local tempFlags = data[EJ_CONST_ENCOUNTERSECTION_ICONFLAGS]
        if tempFlags ~= 0 then
            for i = 32, 0, -1 do
                local cur  = math.pow(2, i)
                local temp = tempFlags - cur
                if temp >= 0 then
                    table.insert(iconFlags, i)
                    tempFlags = tempFlags - cur
                end
            end
        end
        local returnedFlags = {}
        if #iconFlags > 4 then
            for i = 1, 4, 1 do
                table.insert(returnedFlags, iconFlags[i])
            end
        else
            returnedFlags = iconFlags
        end

        for i=1, math.floor(#returnedFlags / 2) do
            returnedFlags[i], returnedFlags[#returnedFlags - i + 1] = returnedFlags[#returnedFlags - i + 1], returnedFlags[i]
        end

		description = string.gsub(description, "{(spell:[^}]+)}", formatHyperlink)

        return title, description, depth, abilityIcon, displayInfo, siblingID, nextSectionID, filteredByDifficulty, link, startsOpen, creatureEntry, unpack(returnedFlags)
    end

    return nil
end

function EJ_GetEncounterInfo( encounterID )
	local instanceID

	if encounterID and JOURNALENCOUNTER_BY_ENCOUNTER[encounterID] then
		instanceID = JOURNALENCOUNTER_BY_ENCOUNTER[encounterID][EJ_CONST_ENCOUNTER_INSTANCEID]
	else
		instanceID = EncounterJournal.instanceID
	end

	if instanceID then
		if JOURNALENCOUNTER[instanceID] then
			for _, data in pairs(JOURNALENCOUNTER[instanceID]) do
				if data[EJ_CONST_ENCOUNTER_ID] == encounterID then
					local name = data[EJ_CONST_ENCOUNTER_NAME]
					local description = data[EJ_CONST_ENCOUNTER_DESCRIPTION]
					local encounterID = data[EJ_CONST_ENCOUNTER_ID]
					local rootSectionID = data[EJ_CONST_ENCOUNTER_FIRSTSECTIONID]
					local link = EJ_LinkGenerate( name, 1, encounterID, SelectedDifficulty )
					local instanceID = data[EJ_CONST_ENCOUNTER_INSTANCEID]
					local difficultyMask = data[EJ_CONST_ENCOUNTER_DIFFICULTYMASK]

					return name, description, encounterID, rootSectionID, link, instanceID, difficultyMask
				end
			end
		end
	end

	return nil
end

function EJ_InstanceIsRaid()
	if EncounterJournal.instanceID then
		return EJ_IsRaid(EncounterJournal.instanceID)
	end
end

local lootBuffer = {}
local lastBossData = {}
local lastDiffficulty = 0
local lastSlotFilter = 0
local lastClassFilter = 0
function EJ_GetLootInfoByIndex( index )
	if not index then
		return nil
	end

	EJ_BuildLootData()

	if lootBuffer[index] then
		return unpack(lootBuffer[index])
	end

	return nil
end

local ITEM_REALM_FLAG = {
	[E_REALM_ID.SCOURGE] = 0x4,
	[E_REALM_ID.ALGALON] = 0x8,
	[E_REALM_ID.SIRUS] = 0x10,
	[E_REALM_ID.SOULSEEKER] = 0x20,
};

function EJ_BuildLootData()
	local bossData = not EncounterJournal.encounterID and EncounterJournal.encounterList or { EncounterJournal.encounterID }
	local factionGroup = EncounterJournal.playerFactionGroup
	local currentDiffMask = EJ_GetDifficultyMask(SelectedDifficulty)
	local slotFilter = EJ_GetSlotFilter()
	local classFilter = EJ_GetLootFilter()

	local classFlag = ITEM_CLASS_FLAG[classFilter] or 0
	local realmFlag = ITEM_REALM_FLAG[C_Service.GetRealmID() or 0] or 0

	if lastClassFilter ~= classFilter or slotFilter ~= lastSlotFilter or bossData ~= lastBossData or SelectedDifficulty ~= lastDiffficulty then
		lootBuffer = {}
		lastBossData = bossData
		lastDiffficulty = SelectedDifficulty
		lastSlotFilter = slotFilter
		lastClassFilter = classFilter
		for i = 1, #bossData do
			if JOURNALENCOUNTERITEM[bossData[i]] then
				for j = 1, #JOURNALENCOUNTERITEM[bossData[i]] do
					local data = JOURNALENCOUNTERITEM[bossData[i]][j]
					local factionMask = data[EJ_CONST_ENCOUNTERITEM_FACTIONMASK]

					if factionMask == -1 or factionMask == factionGroup then
						local itemClassMask = data[EJ_CONST_ENCOUNTERITEM_CLASSMASK]

						if itemClassMask == -1 or bit.band(itemClassMask, classFlag) ~= 0 then
							local difficultyMask = data[EJ_CONST_ENCOUNTERITEM_DIFFIULTYMASK]
							local flag = data[EJ_CONST_ENCOUNTERITEM_FLAGS]

							if bit.band(flag, realmFlag) == 0 and (data.link and difficultyMask == -1 or bit.band(difficultyMask, currentDiffMask) == currentDiffMask) then
								local itemID = data[EJ_CONST_ENCOUNTERITEM_ITEMENTRY]
								if slotFilter == NO_INV_TYPE_FILTER or EJ_GetSlotFilterValidation(data.equipSlot) then
									if classFilter == NO_CLASS_FILTER or EJ_GetClassFilterValidation(data.subclass, data.armorType, itemID) then
										local encounterID = data[EJ_CONST_ENCOUNTERITEM_ENCOUNTERID]
										table.insert(lootBuffer, {itemID, encounterID, data.name, data.icon, _G[data.equipSlot], data.subclass, data.link, data.armorType})
									end
								end
							end
						end
					end
				end
			end
		end
		table.sort(lootBuffer, function(a, b)
			if a[5] == INVTYPE_CLOAK and b[5] ~= INVTYPE_CLOAK then
				return true
			elseif b[5] == INVTYPE_CLOAK and a[5] ~= INVTYPE_CLOAK then
				return false
			end

			if a[6] == ITEM_SUB_CLASS_4_1 and b[6] ~= ITEM_SUB_CLASS_4_1 then
				return true
			elseif b[6] == ITEM_SUB_CLASS_4_1 and a[6] ~= ITEM_SUB_CLASS_4_1 then
				return false
			end

			if a[6] == ITEM_SUB_CLASS_4_2 and b[6] ~= ITEM_SUB_CLASS_4_2 then
				return true
			elseif b[6] == ITEM_SUB_CLASS_4_2 and a[6] ~= ITEM_SUB_CLASS_4_2 then
				return false
			end

			if a[6] == ITEM_SUB_CLASS_4_3 and b[6] ~= ITEM_SUB_CLASS_4_3 then
				return true
			elseif b[6] == ITEM_SUB_CLASS_4_3 and a[6] ~= ITEM_SUB_CLASS_4_3 then
				return false
			end

			if a[6] == ITEM_SUB_CLASS_4_4 and b[6] ~= ITEM_SUB_CLASS_4_4 then
				return true
			elseif b[6] == ITEM_SUB_CLASS_4_4 and a[6] ~= ITEM_SUB_CLASS_4_4 then
				return false
			end

			if a[5] == INVTYPE_FINGER and b[5] ~= INVTYPE_FINGER then
				return true
			elseif b[5] == INVTYPE_FINGER and a[5] ~= INVTYPE_FINGER then
				return false
			end

			if a[5] == INVTYPE_NECK and b[5] ~= INVTYPE_NECK then
				return true
			elseif b[5] == INVTYPE_NECK and a[5] ~= INVTYPE_NECK then
				return false
			end

			if a[5] == INVTYPE_TRINKET and b[5] ~= INVTYPE_TRINKET then
				return true
			elseif b[5] == INVTYPE_TRINKET and a[5] ~= INVTYPE_TRINKET then
				return false
			end

			if a[5] == INVTYPE_2HWEAPON and b[5] ~= INVTYPE_2HWEAPON then
				return true
			elseif b[5] == INVTYPE_2HWEAPON and a[5] ~= INVTYPE_2HWEAPON then
				return false
			end

			if a[5] == INVTYPE_WEAPON and b[5] ~= INVTYPE_WEAPON then
				return true
			elseif b[5] == INVTYPE_WEAPON and a[5] ~= INVTYPE_WEAPON then
				return false
			end

			if a[5] == INVTYPE_RANGED and b[5] ~= INVTYPE_RANGED then
				return true
			elseif b[5] == INVTYPE_RANGED and a[5] ~= INVTYPE_RANGED then
				return false
			end

			if a[5] == INVTYPE_THROWN and b[5] ~= INVTYPE_THROWN then
				return true
			elseif b[5] == INVTYPE_THROWN and a[5] ~= INVTYPE_THROWN then
				return false
			end

			if a[5] == INVTYPE_RANGEDRIGHT and b[5] ~= INVTYPE_RANGEDRIGHT then
				return true
			elseif b[5] == INVTYPE_RANGEDRIGHT and a[5] ~= INVTYPE_RANGEDRIGHT then
				return false
			end

			if a[5] == INVTYPE_HOLDABLE and b[5] ~= INVTYPE_HOLDABLE then
				return true
			elseif b[5] == INVTYPE_HOLDABLE and a[5] ~= INVTYPE_HOLDABLE then
				return false
			end

			if a[5] == INVTYPE_WEAPONOFFHAND and b[5] ~= INVTYPE_WEAPONOFFHAND then
				return true
			elseif b[5] == INVTYPE_WEAPONOFFHAND and a[5] ~= INVTYPE_WEAPONOFFHAND then
				return false
			end

			if a[5] == INVTYPE_WEAPONMAINHAND and b[5] ~= INVTYPE_WEAPONMAINHAND then
				return true
			elseif b[5] == INVTYPE_WEAPONMAINHAND and a[5] ~= INVTYPE_WEAPONMAINHAND then
				return false
			end

			if a[5] == INVTYPE_RELIC and b[5] ~= INVTYPE_RELIC then
				return true
			elseif b[5] == INVTYPE_RELIC and a[5] ~= INVTYPE_RELIC then
				return false
			end

			if a[5] == INVTYPE_BODY and b[5] ~= INVTYPE_BODY then
				return true
			elseif b[5] == INVTYPE_BODY and a[5] ~= INVTYPE_BODY then
				return false
			end

			if a[5] == INVTYPE_TABARD and b[5] ~= INVTYPE_TABARD then
				return true
			elseif b[5] == INVTYPE_TABARD and a[5] ~= INVTYPE_TABARD then
				return false
			end

			if a[3] and b[3] then
				return a[3] < b[3]
			elseif a[3] then
				return true
			elseif b[3] then
				return false
			else
				return a[1] < b[1]
			end
		end)
	end
end

function EJ_GetNumLoot()
    EJ_BuildLootData()
    return #lootBuffer
end

function EJ_GetSlotFilter()
	return EJ_slotFilter or NO_INV_TYPE_FILTER
end

function EJ_SetSlotFilter( slot )
	EncounterJournal_UpdateScrollPos(EncounterJournal.encounter.info.lootScroll, 1)
	EJ_slotFilter = slot
end

function EJ_GetSlotFilterValidation(equipSlot)
	local slotFilter = EJ_GetSlotFilter()
	if slotFilter == NO_INV_TYPE_FILTER then
		return true
	end

	for index, filterInfo in ipairs(EncounterJournalSlotFilters) do
		if filterInfo.invType == slotFilter then
			if type(filterInfo.equipSlot) == "table" then
				if tIndexOf(filterInfo.equipSlot, equipSlot) then
					return true
				end
			elseif filterInfo.equipSlot == equipSlot then
				return true
			end
		end
	end

	return false
end

local subClassWhiteList = {ITEM_SUB_CLASS_4_5, ITEM_SUB_CLASS_4_6, ITEM_SUB_CLASS_4_8, ITEM_SUB_CLASS_4_9, ITEM_SUB_CLASS_4_10, ITEM_SUB_CLASS_4_7}
local itemClassWhiteList = {
	ITEM_SUB_CLASS_15_2,
	ITEM_SUB_CLASS_5_0,
	ITEM_SUB_CLASS_7_0,
	ITEM_SUB_CLASS_7_1,
	ITEM_SUB_CLASS_7_2,
	ITEM_SUB_CLASS_7_3,
	ITEM_SUB_CLASS_7_4,
	ITEM_SUB_CLASS_7_5,
	ITEM_SUB_CLASS_7_6,
	ITEM_SUB_CLASS_7_7,
	ITEM_SUB_CLASS_7_8,
	ITEM_SUB_CLASS_7_9,
	ITEM_SUB_CLASS_7_10,
	ITEM_SUB_CLASS_7_11,
	ITEM_SUB_CLASS_7_12,
	ITEM_SUB_CLASS_7_13,
	ITEM_SUB_CLASS_7_14,
	ITEM_SUB_CLASS_7_15,
	ITEM_SUB_CLASS_9_0,
	ITEM_SUB_CLASS_9_1,
	ITEM_SUB_CLASS_9_2,
	ITEM_SUB_CLASS_9_3,
	ITEM_SUB_CLASS_9_4,
	ITEM_SUB_CLASS_9_5,
	ITEM_SUB_CLASS_9_6,
	ITEM_SUB_CLASS_9_7,
	ITEM_SUB_CLASS_9_8,
	ITEM_SUB_CLASS_9_9,
	ITEM_SUB_CLASS_9_10,
	ITEM_SUB_CLASS_9_11,
	ITEM_SUB_CLASS_11_3,
	ITEM_SUB_CLASS_12_0,
	ITEM_SUB_CLASS_13_0,
	ITEM_SUB_CLASS_13_1,
	ITEM_SUB_CLASS_14_0,
	ITEM_SUB_CLASS_15_0,
	ITEM_SUB_CLASS_15_1,
	ITEM_SUB_CLASS_15_3,
	ITEM_SUB_CLASS_15_4,
	ITEM_SUB_CLASS_15_5,
	ITEM_SUB_CLASS_2_14,
}

function EJ_GetClassFilterValidation( subclass, armorType, itemEntry )
	if not subclass or not EJ_GetLootFilter() then
		return false
	end

	if EJ_GetLootFilter() == 0 then
		return true
	end

	local _, _, _, _, _, _, _, _, invtype = GetItemInfo(itemEntry)

	if armorType == ITEM_CLASS_2 or invtype == INVTYPE_CLOAK or (armorType == ITEM_CLASS_4 and tContains(subClassWhiteList, subclass)) then
		local classItemMask = weaponClassFilterMask[subclass]

		if classItemMask == -1 then
			return true
		else
			local classMask = classLootData[EJ_GetLootFilter()].flag
			if classItemMask and classMask then
				if bit.band(classItemMask, classMask) ~= 0 then
					return true
				end
			end
		end
	elseif tContains(itemClassWhiteList, subclass) or invtype == "INVTYPE_CLOAK" then
		return true
	else
		local armorClassMask = UnitLevel("player") < 40 and classLootData[EJ_GetLootFilter()].subArmorMask or classLootData[EJ_GetLootFilter()].armorMask
		local armorMask = armorClassFilterMask[subclass]

		if armorMask and armorMask then
			if bit.band(armorClassMask, armorMask) ~= 0 then
				return true
			end
		end
	end

	return false
end

function EJ_SetSearch( text )
	table.wipe(EJ_SearchBuffer)
	text = string.upper(text)

	for _, data in ipairs(EJ_SearchData) do
		if string.find(string.upper(data.name), text, 1, true) then
			table.insert(EJ_SearchBuffer, data)
		end
	end
end

function EJ_GetNumSearchResults()
	return #EJ_SearchBuffer or 0
end

function EJ_GetSearchResult( index )
	if not index then
		return nil
	end

	if EJ_SearchBuffer[index] then
		local data = EJ_SearchBuffer[index]
		return data.id, data.stype, data.difficulty, data.instanceID, data.encounterID, data.link
	end

	return nil
end

function EJ_GetLootInfo( itemEntry )
	if not itemEntry then
		return nil
	end

	if JOURNALENCOUNTERITEM_BY_ENTRY[itemEntry] then
		local data = JOURNALENCOUNTERITEM_BY_ENTRY[itemEntry]
		local itemID = itemEntry
		local encounterID = data[EJ_CONST_ENCOUNTERITEM_ENCOUNTERID]
		local name = BAG_ITEM_QUALITY_COLORS[data.quality]:WrapTextInColorCode(data.name)
		local icon = data.icon
		local slot = data.equipSlot
		local armorType = data.subclass
		local link = nil -- ДОДЕЛАТЬ
		local difficultyMask = data[EJ_CONST_ENCOUNTERITEM_DIFFIULTYMASK];
		local difficultyID = 1;

		if difficultyMask ~= -1 then
			for i = #EJ_DIFFICULTIES, 1, -1 do
				local diffInfo = EJ_DIFFICULTIES[i];
				if bit.band(difficultyMask, diffInfo.difficultyMask) == diffInfo.difficultyMask then
					difficultyID = diffInfo.difficultyID;
					break;
				end
			end
		end

		local factionID = data[EJ_CONST_ENCOUNTERITEM_FACTIONMASK]

		return itemID, encounterID, name, icon, slot, armorType, link, difficultyID, factionID
	end

	return nil
end

function EJ_GetSectionPath( sectionID )
	if not sectionID then
		return nil
	end
	if JOURNALENCOUNTERSECTION[sectionID] then
		local data = JOURNALENCOUNTERSECTION[sectionID]
		local _sectionID = data[EJ_CONST_ENCOUNTERSECTION_ID]
		local parentSectionID = data[EJ_CONST_ENCOUNTERSECTION_PARENTSECTIONID] or nil
		return _sectionID, parentSectionID
	end

	return nil
end

function EJ_GetMapEncounter( index )
	if not index then
		return nil
	end

	local _index = 1
	local buffer = {}
	local currentMapAeraID = GetCurrentMapAreaID()
	local currentMapDungeonLevel = GetCurrentMapDungeonLevel()
	local name, description, bossID, rootSectionID, link, instanceID, map_pos1, map_pos2, floorIndex, worldMapAreaID = EJ_GetEncounterInfoByIndex(_index, EJ_GetCurrentInstance())

	while name do
		if name and (currentMapAeraID - 1) == worldMapAreaID and floorIndex == currentMapDungeonLevel then
			table.insert(buffer, {map_pos1, map_pos2, instanceID, name, description, bossID, rootSectionID})
		end

		_index = _index + 1
		name, description, bossID, rootSectionID, link, instanceID, map_pos1, map_pos2, floorIndex, worldMapAreaID = EJ_GetEncounterInfoByIndex(_index, EJ_GetCurrentInstance())
	end

	if buffer[index] then
		return unpack(buffer[index])
	end

	return nil
end

function EJ_SetLootFilter( filter )
	EncounterJournal_UpdateScrollPos(EncounterJournal.encounter.info.lootScroll, 1)
	SelectedLootFilter = filter
end

function EJ_GetLootFilter()
	local _, fileName = UnitClass("player")
	return SelectedLootFilter or fileName
end

function EJ_ResetLootFilter()
	local _, fileName = UnitClass("player")
	SelectedLootFilter = fileName
	EncounterJournal_UpdateFilterString()
end

function EJ_LinkGenerate( name, jtype, id, difficulty )
	return string.format("|cff66bbff|Hjournal:%d:%d:%d|h[%s]|h|r", jtype or 0, id or 0, difficulty or 1, name or "~NOT NAME~")
end

function EJ_HandleLinkPath( jtype, id )
	local instanceID, encounterID, sectionID, tierIndex

	if jtype == 0 then
		instanceID = id
	elseif jtype == 1 then
		local name, description, _, rootSectionID, link, instID, difficultyMask = EJ_GetEncounterInfo(id)

		instanceID = instID
		encounterID = id
	elseif jtype == 2 then
		local data = JOURNALENCOUNTERSECTION[id]

		if data then
			encounterID = data[EJ_CONST_ENCOUNTERSECTION_ENCOUNTERID]
			instanceID = select(6, EJ_GetEncounterInfo(encounterID))
			sectionID = id
		end
	end

	if instanceID then
		tierIndex = EJ_GetTierIndex(JOURNALTIERXINSTANCE[instanceID])
	end

	return instanceID, encounterID, sectionID, tierIndex
end

function EJ_GetTierIndex( tierID )
	if not tierID then
		return
	end

	for k, v in ipairs(JOURNALTIER) do
		if tierID == v[EJ_CONST_TIER_ID] then
			return k
		end
	end

	return nil
end

function EJ_SetDifficulty( difficulty )
	local _, creatureEntry;
	if EncounterJournal.encounterID then
		_, _, _, _, _, creatureEntry = EJ_GetCreatureInfo(1, EncounterJournal.encounterID);
	end

	SelectedDifficulty = difficulty

	if creatureEntry then
		local index = 1;
		local encounterID;
		_, _, encounterID = EJ_GetEncounterInfoByIndex(index);
		while encounterID do
			if EncounterJournal.encounterID ~= encounterID and select(6, EJ_GetCreatureInfo(1, encounterID)) == creatureEntry then
				EncounterJournal.encounterID = encounterID;
				break;
			end

			index = index + 1;
			_, _, encounterID = EJ_GetEncounterInfoByIndex(index);
		end
	end

	EncounterJournal_UpdateDifficulty(difficulty)
end

function EJ_GetValidationDifficulty( index, instanceID )
	if not index then
		return nil
	end

	local buffer = {}

	for i = 1, #EJ_DIFFICULTIES do
		local entry = EJ_DIFFICULTIES[i]
		if EJ_IsValidInstanceDifficulty(entry.difficultyID, instanceID) and (entry.size ~= "5" == EJ_IsRaid(instanceID or EncounterJournal.instanceID)) then
			table.insert(buffer, entry.difficultyID)
		end
	end

	if buffer[index] then
		return buffer[index]
	end
end

function EJ_SetValidationDifficulty( index )
	EJ_SetDifficulty(EJ_GetValidationDifficulty(index))
end

local function LoadEJData(self)
	if self.loaded then return end
	self.loaded = true

	table.wipe(EJ_SearchData)

	for _, data in pairs(JOURNALINSTANCE) do
		local instanceID = data[EJ_CONST_INSTANCE_ID]

		if C_EncounterJournal.IsInstanceOpen(instanceID) then
			table.insert(EJ_SearchData, {
				id			= instanceID,
				name		= data[EJ_CONST_INSTANCE_NAME],
				stype		= EJ_STYPE_INSTANCE,
				instanceID	= instanceID,
				encounterID	= -1,
				difficulty	= 1,
			--	link		= nil, -- TODO
			})
		end
	end

	for _, container in pairs(JOURNALENCOUNTER) do
		for _, data in ipairs(container) do
			local instanceID = data[EJ_CONST_ENCOUNTER_INSTANCEID]
			local encounterID = data[EJ_CONST_ENCOUNTER_ID]

			JOURNALENCOUNTER_BY_ENCOUNTER[encounterID] = data

			if C_EncounterJournal.IsInstanceOpen(instanceID) then
				table.insert(EJ_SearchData, {
					id			= encounterID,
					name		= data[EJ_CONST_ENCOUNTER_NAME],
					stype		= EJ_STYPE_ENCOUNTER,
					instanceID	= instanceID,
					encounterID	= encounterID,
					difficulty	= data[EJ_CONST_ENCOUNTER_DIFFICULTYMASK],
				--	link		= nil, -- TODO
				})
			end
		end
	end

	for _, container in pairs(JOURNALENCOUNTERCREATURE) do
		for _, data in ipairs(container) do
			local encounterID = data[EJ_CONST_ENCOUNTERCREATURE_ENCOUNTERID]
			local instanceID = JOURNALENCOUNTER_BY_ENCOUNTER[encounterID][EJ_CONST_ENCOUNTER_INSTANCEID]

			if C_EncounterJournal.IsInstanceOpen(instanceID) then
				table.insert(EJ_SearchData, {
					id			= data[EJ_CONST_ENCOUNTERCREATURE_ID],
					name		= data[EJ_CONST_ENCOUNTERCREATURE_NAME],
					stype		= EJ_STYPE_CREATURE,
					instanceID	= instanceID,
					encounterID	= encounterID,
					difficulty	= JOURNALENCOUNTER_BY_ENCOUNTER[encounterID][EJ_CONST_ENCOUNTER_DIFFICULTYMASK],
				--	link		= nil, -- TODO
				})
			end
		end
	end

	for _, data in pairs(JOURNALENCOUNTERSECTION) do
		local encounterID = data[EJ_CONST_ENCOUNTERSECTION_ENCOUNTERID]
		local instanceID = JOURNALENCOUNTER_BY_ENCOUNTER[encounterID][EJ_CONST_ENCOUNTER_INSTANCEID]

		if C_EncounterJournal.IsInstanceOpen(instanceID) then
			table.insert(EJ_SearchData, {
				id			= data[EJ_CONST_ENCOUNTERSECTION_ID],
				name		= data[EJ_CONST_ENCOUNTERSECTION_NAME],
				stype		= EJ_STYPE_SECTION,
				difficulty	= data[EJ_CONST_ENCOUNTERSECTION_DIFFCULTYMASK],
				instanceID	= instanceID,
				encounterID	= encounterID,
			--	link		= nil, -- TODO
			})
		end
	end

	local queuedItems = {}
	local addItemInfo = function(item, itemID, name, link, quality, iLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice)
		item.name			= name
		item.link			= link
		item.quality		= quality
		item.iLevel			= iLevel
		item.reqLevel		= reqLevel
		item.armorType		= armorType
		item.subclass		= subclass
		item.maxStack		= maxStack
		item.equipSlot		= equipSlot
		item.icon			= icon
		item.vendorPrice	= vendorPrice

		local encounterID = item[EJ_CONST_ENCOUNTERITEM_ENCOUNTERID]

		table.insert(EJ_SearchData, {
			id			= itemID,
			name		= item.name,
			stype		= EJ_STYPE_ITEM,
			difficulty	= item[EJ_CONST_ENCOUNTERITEM_DIFFIULTYMASK],
			instanceID	= JOURNALENCOUNTER_BY_ENCOUNTER[encounterID][EJ_CONST_ENCOUNTER_INSTANCEID],
			encounterID	= encounterID,
			link		= item.link,
		})

		JOURNALENCOUNTERITEM_BY_ENTRY[itemID] = item
	end

	local itemCacheResponse = function(itemID, ...)
		local item = queuedItems[itemID]
		if item then
			addItemInfo(item, itemID, ...)
			queuedItems[itemID] = nil
		end
	end

	for encounterID, container in pairs(JOURNALENCOUNTERITEM) do
		local instanceID = JOURNALENCOUNTER_BY_ENCOUNTER[encounterID][EJ_CONST_ENCOUNTER_INSTANCEID]
		if C_EncounterJournal.IsInstanceOpen(instanceID) then
			for _, item in ipairs(container) do
				local itemID = item[EJ_CONST_ENCOUNTERITEM_ITEMENTRY]
				local name, link, quality, iLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice = C_Item.GetItemInfo(itemID, nil, nil, true, true)
				if name then
					addItemInfo(item, itemID, name, link, quality, iLevel, reqLevel, armorType, subclass, maxStack, equipSlot, icon, vendorPrice)
				else
					queuedItems[itemID] = item
					C_Item.RequestServerCache(itemID, itemCacheResponse)
				end
			end
		end
	end
end

function EncounterJournal_InitTab(self)
	if not C_Service.IsRenegadeRealm() then
		PanelTemplates_HideTab(self, 2)
		EncounterJournalTab3:SetPoint("LEFT", EncounterJournalTab1, "RIGHT", -16, 0);
	end
	if not C_Service.IsHardcoreEnabledOnRealm() then
		PanelTemplates_HideTab(self, 3)
	end
	if not C_Service.IsGMAccount() then
		PanelTemplates_HideTab(self, 4)
	end
end

function EncounterJournal_OnLoad(self)
	EncounterJournalTitleText:SetText(ADVENTURE_JOURNAL);
	SetPortraitToTexture(EncounterJournalPortrait,"Interface\\EncounterJournal\\UI-EJ-PortraitIcon");

	do
		SetParentFrameLevel(self.inset)
		SetParentFrameLevel(self.instanceSelect)
		SetParentFrameLevel(self.encounter)
		SetParentFrameLevel(self.encounter.info)

		self.instanceSelect.suggestTab.id = self.instanceSelect.suggestTab:GetID()
		self.instanceSelect.dungeonsTab.id = self.instanceSelect.dungeonsTab:GetID()
		self.instanceSelect.raidsTab.id = self.instanceSelect.raidsTab:GetID()
		self.instanceSelect.LootJournalTab.id = self.instanceSelect.LootJournalTab:GetID()

		local info = EncounterJournal.encounter.info;
		for index, data in ipairs(EJ_Tabs) do
			local tabButton = info[data.button];
			SetParentFrameLevel(tabButton, 10)
		end
	end

	self.encounter.freeHeaders = {};
	self.encounter.usedHeaders = {};
	self.encounterList = {}

	self.encounter.overviewFrame = self.encounter.info.overviewScroll.child;
	self.encounter.overviewFrame.isOverview = true;
	self.encounter.overviewFrame.overviews = {};
	self.encounter.info.overviewScroll.ScrollBar.scrollStep = 30;

	self.encounter.infoFrame = self.encounter.info.detailsScroll.child;
	self.encounter.info.detailsScroll.ScrollBar.scrollStep = 30;

	self.encounter.bossesFrame = self.encounter.info.bossesScroll.child;
	self.encounter.info.bossesScroll.ScrollBar.scrollStep = 30;

	self.encounter.info.overviewTab:Click();

	self.encounter.info.lootScroll.update = EncounterJournal_LootUpdate;
	self.encounter.info.lootScroll.scrollBar.doNotHide = true;
	self.encounter.info.lootScroll.dynamic = EncounterJournal_LootCalcScroll;
	HybridScrollFrame_CreateButtons(self.encounter.info.lootScroll, "EncounterItemTemplate", 0, 0);

	self.searchResults.scrollFrame.update = EncounterJournal_SearchUpdate;
	self.searchResults.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.searchResults.scrollFrame, "EncounterSearchLGTemplate", 0, 0);

	local homeData = {
		name = NAVIGATIONBAR_HOME,
		OnClick = function()
			if self.instanceSelect.selectedTab then
				EJ_ContentTab_Select(self.instanceSelect.selectedTab);
				NavBar_Reset(self.navBar)
			else
				EJSuggestFrame_OpenFrame();
			end
		end,
	}
	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);
	UIDropDownMenu_Initialize(self.encounter.info.lootScroll.lootFilter, EncounterJournal_InitLootFilter, "MENU");
	UIDropDownMenu_Initialize(self.encounter.info.lootScroll.lootSlotFilter, EncounterJournal_InitLootSlotFilter, "MENU");

	-- initialize tabs
	local instanceSelect = EncounterJournal.instanceSelect;
	local tierName = EJ_GetTierInfo(EJ_GetCurrentTier());
	UIDropDownMenu_SetText(instanceSelect.tierDropDown, tierName);

	-- check if tabs are active
	local dungeonInstanceID = EJ_GetInstanceByIndex(1, false);
	if( not dungeonInstanceID ) then
		instanceSelect.dungeonsTab.grayBox:Show();
	end
	local raidInstanceID = EJ_GetInstanceByIndex(1, true);
	if( not raidInstanceID ) then
		instanceSelect.raidsTab.grayBox:Show();
	end
	-- set the suggestion panel frame to open by default
	EJSuggestFrame_OpenFrame();


	self.tab1:SetFrameLevel(1)
	self.tab2:SetFrameLevel(1)
	self.tab3:SetFrameLevel(1)
	self.tab4:SetFrameLevel(1)

	self.maxTabWidth = (self:GetWidth() - 19) / 4

	PanelTemplates_SetNumTabs(self, 4)

	self:RegisterCustomEvent("SERVICE_DATA_UPDATE")
	self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")
	self:RegisterCustomEvent("AJ_ACTION_EJ_DUNGEON")

	C_FactionManager.RegisterCallback(function()
		local factionGroup = UnitFactionGroup("player")
		if factionGroup == "Renegade" then
			factionGroup = select(3, C_FactionManager.GetFactionInfoOriginal())
		end
		self.playerFactionGroup = factionGroup == "Alliance" and -2 or -3
	end, true, true)

	self.helpPlate = {
		FramePos = { x = 0, y = -24 },
		FrameSize = { width = 800, height = 468 },
		[1] = { ButtonPos = { x = 95, y = -26 }, HighLightBox = { x = 17, y = -49, width = 202, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = HEPLPLATE_ENCOUNTER_JOURNAL_TUTORIAL_1 },
		[2] = { ButtonPos = { x = 269, y = -26 }, HighLightBox = { x = 232, y = -49, width = 121, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = HEPLPLATE_ENCOUNTER_JOURNAL_TUTORIAL_2 },
		[3] = { ButtonPos = { x = 389, y = -26 }, HighLightBox = { x = 366, y = -49, width = 92, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = HEPLPLATE_ENCOUNTER_JOURNAL_TUTORIAL_3 },
		[4] = { ButtonPos = { x = 504, y = -26 }, HighLightBox = { x = 471, y = -49, width = 112, height = 36 }, ToolTipDir = "RIGHT", ToolTipText = HEPLPLATE_ENCOUNTER_JOURNAL_TUTORIAL_4 },
		[5] = { ButtonPos = { x = 758, y = -39 }, HighLightBox = { x = 600, y = -45, width = 181, height = 34 }, ToolTipDir = "RIGHT", ToolTipText = HEPLPLATE_ENCOUNTER_JOURNAL_TUTORIAL_5 },
		[6] = { ButtonPos = { x = 773, y = 5 }, HighLightBox = { x = 568, y = -2, width = 228, height = 32 }, ToolTipDir = "RIGHT", ToolTipText = HEPLPLATE_ENCOUNTER_JOURNAL_TUTORIAL_6 },
	}
end

function EncounterJournal_GetLootJournalView()
	return EncounterJournal.lootJournalView;
end

function EncounterJournal_SetLootJournalView(view)
	local self = EncounterJournal;
	local activeViewPanel, inactiveViewPanel = EncounterJournal_GetLootJournalPanels(view);
	self.LootJournalViewDropDown:SetParent(activeViewPanel);
	self.LootJournalViewDropDown:SetPoint("TOPLEFT", 15, -9);
	UIDropDownMenu_SetText(self.LootJournalViewDropDown, view);

	-- if no previous view then it's the init, no need to change which frame is shown
	if self.lootJournalView then
		activeViewPanel:Show();
		inactiveViewPanel:Hide();
	end

	self.lootJournalView = view;
end

function EncounterJournal_GetLootJournalPanels(view)
	local self = EncounterJournal;
	if not view then
		view = self.lootJournalView;
	end
	return self.LootJournalItems, self.LootJournal;
end

function EncounterJournal_EnableTierDropDown()
	local tierName = EJ_GetTierInfo(EJ_GetCurrentTier());
	UIDropDownMenu_SetText(EncounterJournal.instanceSelect.tierDropDown, tierName);
	UIDropDownMenu_EnableDropDown(EncounterJournal.instanceSelect.tierDropDown);
end

function EncounterJournal_DisableTierDropDown(removeText)
	UIDropDownMenu_DisableDropDown(EncounterJournal.instanceSelect.tierDropDown);
	if ( removeText ) then
		UIDropDownMenu_SetText(EncounterJournal.instanceSelect.tierDropDown, nil);
	else
		local tierName = EJ_GetTierInfo(EJ_GetCurrentTier());
		UIDropDownMenu_SetText(EncounterJournal.instanceSelect.tierDropDown, tierName);
	end
end

function EncounterJournal_HasChangedContext(instanceID, instanceType, difficultyID)
	if ( instanceType == "none" ) then
		-- we've gone from a dungeon to the open world
		return EncounterJournal.lastInstance ~= nil;
	elseif ( instanceID ~= 0 and (instanceID ~= EncounterJournal.lastInstance or EncounterJournal.lastDifficulty ~= difficultyID) ) then
		-- dungeon or difficulty has changed
		return true;
	end
	return false;
end

function EncounterJournal_ResetDisplay(instanceID, instanceType, difficultyID)
	if ( instanceType == "none" ) then
		EncounterJournal.lastInstance = nil;
		EncounterJournal.lastDifficulty = nil;
		EJSuggestFrame_OpenFrame();
	else
		EJ_ContentTab_SelectAppropriateInstanceTab(instanceID);

		EncounterJournal_DisplayInstance(instanceID);
		EncounterJournal.lastInstance = instanceID;
		-- try to set difficulty to current instance difficulty
		if ( EJ_IsValidInstanceDifficulty(difficultyID) ) then
			EJ_SetDifficulty(difficultyID);
		end
		EncounterJournal.lastDifficulty = difficultyID;
	end
end

function EncounterJournal_OnShow(self)
	LoadEJData(self)
	PanelTemplates_SetTab(self, 1)

--	MainMenuMicroButton_HideAlert(EncounterJournalMicroButton);
	MicroButtonPulseStop(EncounterJournalMicroButton);

	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	EncounterJournal_LootUpdate();

	local instanceSelect = EncounterJournal.instanceSelect;

	--automatically navigate to the current dungeon if you are in one;
	local instanceID = EJ_GetCurrentInstance();
	local _, instanceType, difficultyID = GetInstanceInfo();
	if ( instanceID and EncounterJournal_HasChangedContext(instanceID, instanceType, difficultyID) ) then
		EncounterJournal_ResetDisplay(instanceID, instanceType, difficultyID);
	end

	local tierData = GetEJTierData(EJ_GetCurrentTier());
	if ( instanceSelect.suggestTab:IsEnabled() ~= 1 or EncounterJournal.suggestFrame:IsShown() ) then
		tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	end
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);
	instanceSelect.raidsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	instanceSelect.dungeonsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);

	EJ_SetSlotFilter(NO_INV_TYPE_FILTER)

	local success = EncounterJournal_CheckAndDisplayEncounter()
	if not success then
		if EncounterJournal.instanceSelect:IsShown() then
			EJ_ContentTab_Select(self.instanceSelect.selectedTab);
		end
		EncounterJournal_ListInstances()
	end

	EventRegistry:TriggerEvent("EncounterJournal.OnShow")
end

function EncounterJournal_CheckAndDisplayEncounter()
	local index = 1
	local bossX, bossY, instanceID, name, description, encounterID = EJ_GetMapEncounter(index)

	if encounterID then
		local unitX, unitY = GetPlayerMapPosition("player")
		local dist = math.sqrt(math.pow(bossX - unitX, 2) + math.pow(bossY - unitY, 2))

		while encounterID do
			if dist < 0.13 then
				NavBar_Reset(EncounterJournal.navBar)
				EncounterJournal_DisplayInstance(instanceID)
				EncounterJournal_DisplayEncounter(encounterID)
				return true
			end

			index = index + 1
			bossX, bossY, instanceID, name, description, encounterID = EJ_GetMapEncounter(index)

			bossX = bossX or 0
			bossY = bossY or 0
			dist = math.sqrt(math.pow(bossX - unitX, 2) + math.pow(bossY - unitY, 2))
		end
	end

	return false
end

function EncounterJournal_OnHide(self)
	EJ_TIER_SELECTED = nil
	EJ_INSTANCE_SELECTED = nil

	LOOTJOURNAL_CLASSFILTER = nil
	LOOTJOURNAL_SPECFILTER = nil

	UpdateMicroButtons();

	self.searchBox:SetText("")

	EJ_ResetLootFilter()
	EJ_SetSlotFilter(NO_INV_TYPE_FILTER)

	PlaySound("igCharacterInfoClose");
	HelpPlate_Hide(false)
	EventRegistry:TriggerEvent("EncounterJournal.OnHide")
end

local function EncounterJournal_GetRootAfterOverviews(rootSectionID)
	local nextSectionID = rootSectionID;

	local headerType, siblingID, _;

	repeat
		_, _, headerType, _, _, siblingID = EJ_GetSectionInfo(nextSectionID);
		if (headerType == EJ_HTYPE_OVERVIEW) then
			nextSectionID = siblingID;
		end
	until headerType ~= EJ_HTYPE_OVERVIEW;

	return nextSectionID;
end

local function EncounterJournal_CheckForOverview(rootSectionID)
	return select(3, EJ_GetSectionInfo(rootSectionID)) == EJ_HTYPE_OVERVIEW;
end

local function EncounterJournal_SearchForOverview(instanceID)
	local bossIndex = 1;
	local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	while bossID do
		local _, _, _, rootSectionID = EJ_GetEncounterInfo(bossID);

		if (EncounterJournal_CheckForOverview(rootSectionID)) then
			return true;
		end

		bossIndex = bossIndex + 1;
		_, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	end

	return false;
end

function EncounterJournal_OnEvent(self, event, ...)
	if event == "SERVICE_DATA_UPDATE"
	or (event == "CUSTOM_CHALLENGE_DEACTIVATED" and select(2, ...) == Enum.HardcoreDeathReason.RESTORE)
	then
		EncounterJournal_InitTab(self)
	elseif event == "AJ_ACTION_EJ_DUNGEON" then
		local dungeonID, difficultyID = ...

		if not self:IsShown() then
			ShowUIPanel(self)
		end

		if dungeonID ~= 0 then
			EncounterJournal_OpenJournal(difficultyID, dungeonID)
		end
	end
end

function EncounterJournal_UpdateDifficulty(newDifficultyID)
	for i = 1, #EJ_DIFFICULTIES do
		local entry = EJ_DIFFICULTIES[i]
		if entry.difficultyID == newDifficultyID then
			if EJ_IsValidInstanceDifficulty(entry.difficultyID) and (entry.size ~= "5" == EJ_IsRaid(EncounterJournal.instanceID)) then
				if entry.size ~= "5" then
					EncounterJournal.encounter.info.difficulty:SetFormattedText("(%s) %s", entry.size, entry.prefix);
				else
					EncounterJournal.encounter.info.difficulty:SetText(entry.prefix);
				end
				EncounterJournal_Refresh();
				break;
			end
		end
	end
end

function EncounterJournal_GetCreatureButton(index)
	if index > MAX_CREATURES_PER_ENCOUNTER then
		return nil;
	end

	local self = EncounterJournal.encounter.info;
	local button = self.creatureButtons[index];
	if (not button) then
		button = CreateFrame("BUTTON", nil, self, "EncounterCreatureButtonTemplate");
		button:SetPoint("TOPLEFT", self.creatureButtons[index-1], "BOTTOMLEFT", 0, 8);
		self.creatureButtons[index] = button;
	end
	return button;
end

local infiniteLoopPolice = false; --design might make a tier that has no instances at all sigh
function EncounterJournal_ListInstances()
	local instanceSelect = EncounterJournal.instanceSelect;

	local tierName = EJ_GetTierInfo(EJ_GetCurrentTier());
	UIDropDownMenu_SetText(instanceSelect.tierDropDown, tierName);
	NavBar_Reset(EncounterJournal.navBar);
	EncounterJournal.encounter:Hide();
	instanceSelect:Show();
	local showRaid = instanceSelect.raidsTab:IsEnabled() ~= 1;

	local scrollFrame = instanceSelect.scroll.child;
	local index = 1;
	local instanceID, name, description, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(index, showRaid);

	--No instances in this tab
	if not instanceID and not infiniteLoopPolice then
		--disable this tab and select the other one.
		infiniteLoopPolice = true;
		if ( showRaid ) then
			instanceSelect.raidsTab.grayBox:Show();
			EJ_ContentTab_Select(instanceSelect.dungeonsTab.id);
		else
			instanceSelect.dungeonsTab.grayBox:Show();
			EJ_ContentTab_Select(instanceSelect.raidsTab.id);
		end
		return;
	end
	infiniteLoopPolice = false;

	while instanceID do
		local instanceButton = scrollFrame["instance"..index];
		if not instanceButton then -- create button
			instanceButton = CreateFrame("BUTTON", scrollFrame:GetParent():GetName().."instance"..index, scrollFrame, "EncounterInstanceButtonTemplate");
			if ( EncounterJournal.localizeInstanceButton ) then
				EncounterJournal.localizeInstanceButton(instanceButton);
			end
			scrollFrame["instance"..index] = instanceButton;
			if mod(index-1, EJ_NUM_INSTANCE_PER_ROW) == 0 then
				instanceButton:SetPoint("TOP", scrollFrame["instance"..(index-EJ_NUM_INSTANCE_PER_ROW)], "BOTTOM", 0, -15);
			else
				instanceButton:SetPoint("LEFT", scrollFrame["instance"..(index-1)], "RIGHT", 15, 0);
			end
		end

		local isOpen, isActual, minItemLevel, maxItemLevel = C_EncounterJournal.GetInstanceInfoEx(instanceID)
		local hasRequirements, requirements = C_EncounterJournal.GetInstanceRequirementsEx(instanceID)

		instanceButton.name:SetText(name);
		instanceButton.bgImage:SetTexture(buttonImage);
		instanceButton.instanceID = instanceID;
		instanceButton.tooltipTitle = name;
		instanceButton.tooltipText = description;
		instanceButton.link = link;
		instanceButton.mapID = mapID;
		instanceButton:Show();

		if minItemLevel ~= 0 then
			if minItemLevel == maxItemLevel then
				instanceButton.range:SetText(minItemLevel)
			else
				instanceButton.range:SetFormattedText("%d - %d", minItemLevel, maxItemLevel)
			end

			if isActual then
				instanceButton.range:SetTextColor(1, 0.82, 0)
			else
				instanceButton.range:SetTextColor(0.5, 0.5, 0.5)
			end

			instanceButton.range:Show()
		else
			instanceButton.range:Hide()
		end

		if hasRequirements then
			instanceButton.Requirements.requirements = requirements
			instanceButton.Requirements:Show()
		else
			instanceButton.Requirements.requirements = nil
			instanceButton.Requirements:Hide()
		end

		index = index + 1;
		instanceID, name, description, _, buttonImage, _, _, _, link, _, mapID = EJ_GetInstanceByIndex(index, showRaid);
	end

	EJ_HideInstances(index);

	--check if the other tab is empty
	local instanceText = EJ_GetInstanceByIndex(1, not showRaid);
	--No instances in the other tab
	if not instanceText then
		--disable the other tab.
		if ( showRaid ) then
			instanceSelect.dungeonsTab.grayBox:Show();
		else
			instanceSelect.raidsTab.grayBox:Show();
		end
	end
end

function EncounterJournalInstanceButton_OnClick(self)
	NavBar_Reset(EncounterJournal.navBar);
	EncounterJournal_DisplayInstance(EncounterJournal.instanceID);
end

local function UpdateDifficultyAnchoring(difficultyFrame)
	local infoFrame = difficultyFrame:GetParent();
	infoFrame.reset:ClearAllPoints();

	if difficultyFrame:IsShown() then
		infoFrame.reset:SetPoint("RIGHT", difficultyFrame, "LEFT", -10, 0);
	else
		infoFrame.reset:SetPoint("TOPRIGHT", infoFrame, "TOPRIGHT", -19, -13);
	end
end

local function UpdateDifficultyVisibility()
	local shouldDisplayDifficulty = select(9, EJ_GetInstanceInfo());

	-- As long as the current tab isn't the model tab, which always suppresses the difficulty, then update the shown state.
	local info = EncounterJournal.encounter.info;
	info.difficulty:SetShown(shouldDisplayDifficulty--[[ and (info.tab ~= 4)]]);

	UpdateDifficultyAnchoring(info.difficulty);
end

function EncounterJournal_DisplayInstance(instanceID, noButton)
	EJ_ResetLootFilter()
	EJ_SetSlotFilter(NO_INV_TYPE_FILTER)
	EncounterJournal_RefreshSlotFilterText()

	EJ_HideNonInstancePanels();

	local self = EncounterJournal.encounter;
	EncounterJournal.instanceSelect:Hide();
	EncounterJournal.encounter:Show();
	EncounterJournal.creatureDisplayID = 0;

	EncounterJournal.instanceID = instanceID;
	EncounterJournal.encounterID = nil;

	EJ_SelectInstance(instanceID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails();

	local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID = EJ_GetInstanceInfo();
	self.instance.title:SetText(instanceName);
	self.instance.titleBG:SetWidth(self.instance.title:GetStringWidth() + 80);
	self.instance.loreBG:SetTexture(loreImage);
	self.info.TitleFrame.instanceTitle:SetText(instanceName);
	self.instance.mapButton:SetShown(dungeonAreaMapID and dungeonAreaMapID > 0);

	self.instance.loreScroll.ScrollBar:Hide();
	self.instance.loreScroll.child.lore:SetWidth(335);
	self.instance.loreScroll.child.lore:SetText(description);

	local loreHeight = self.instance.loreScroll.child.lore:GetHeight();
	self.instance.loreScroll.ScrollBar:SetValue(0);
	if loreHeight > EJ_LORE_MAX_HEIGHT then
		self.instance.loreScroll.ScrollBar:Show();
		self.instance.loreScroll.child.lore:SetWidth(313);
	end

	self.info.instanceButton.instanceID = instanceID;
--	self.info.instanceButton.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
--	self.info.instanceButton.icon:SetTexture(buttonImage);

	buttonImage = buttonImage:lower():gsub("%.blp$", ""):gsub("(\\lfgframe)", "%1\\LFGIcon64")
	local res = self.info.instanceButton.icon:SetTexture(buttonImage)
	if res then
		SetPortraitToTexture(self.info.instanceButton.icon, buttonImage)
	else
		SetPortraitToTexture(self.info.instanceButton.icon, "Interface\\EncounterJournal\\UI-EJ-Home-Icon")
	end

	self.info.model.dungeonBG:SetTexture(bgImage);

	UpdateDifficultyVisibility();

	local bossIndex = 1;
	local name, description, bossID, rootSectionID, link = EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;

	local hasBossAbilities = false;

	EncounterJournal.encounterList = {}

	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
		if not bossButton then -- create a new header;
			bossButton = CreateFrame("BUTTON", "EncounterJournalBossButton"..bossIndex, EncounterJournal.encounter.bossesFrame, "EncounterBossButtonTemplate");
			if bossIndex > 1 then
				bossButton:SetPoint("TOPLEFT", _G["EncounterJournalBossButton"..(bossIndex-1)], "BOTTOMLEFT", 0, -BOSS_BUTTON_SECOND_OFFSET);
			else
				bossButton:SetPoint("TOPLEFT", EncounterJournal.encounter.bossesFrame, "TOPLEFT", 0, -BOSS_BUTTON_FIRST_OFFSET);
			end
		end

		bossButton.link = link;
		if IsGMAccount() then
			local _, _, _, _, _, creatureID, encounterID = EJ_GetCreatureInfo(1, bossID)
			bossButton:SetFormattedText("[%d][%d] %s", encounterID or 0, creatureID or 0, name)
		else
			bossButton:SetText(name);
		end
		bossButton:Show();
		bossButton.encounterID = bossID;
		--Use the boss' first creature as the button icon
		local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, bossID);
		bossImage = bossImage or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
		bossButton.creature:SetTexture(bossImage);
		bossButton:UnlockHighlight();

		if ( not hasBossAbilities ) then
			hasBossAbilities = rootSectionID > 0;
		end

		table.insert(EncounterJournal.encounterList, bossID)

		bossIndex = bossIndex + 1;
		name, description, bossID, rootSectionID, link = EJ_GetEncounterInfoByIndex(bossIndex);
	end

	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.overviewTab, true);
	--disable model tab and abilities tab, no boss selected
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.modelTab, false);
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.bossTab, false);

	if (EncounterJournal_SearchForOverview(instanceID)) then
		EJ_Tabs[1].frame = "overviewScroll";
		EJ_Tabs[3].frame = "detailsScroll"; -- flip them back
		self.info[EJ_Tabs[1].button].tooltip = OVERVIEW;
		self.info[EJ_Tabs[3].button]:Show();
		self.info[EJ_Tabs[4].button]:SetPoint("TOP", self.info[EJ_Tabs[3].button], "BOTTOM", 0, 2)
		self.info.overviewFound = true;
	else
		EJ_Tabs[1].frame = "detailsScroll";
		EJ_Tabs[3].frame = "overviewScroll"; -- flip these so detailsScroll won't get hidden, overview will never be shown here
		if ( hasBossAbilities ) then
			self.info[EJ_Tabs[1].button].tooltip = ABILITIES;
		else
			self.info[EJ_Tabs[1].button].tooltip = OVERVIEW;
		end
		self.info[EJ_Tabs[3].button]:Hide();
		self.info[EJ_Tabs[4].button]:SetPoint("TOP", self.info[EJ_Tabs[2].button], "BOTTOM", 0, 2)
		self.info.overviewFound = false;
	end

	self.instance:Show();
	self.info.overviewScroll:Hide();
	self.info.detailsScroll:Hide();
	self.info.lootScroll:Hide();
	self.info.rightShadow:Hide();

	if (self.info.tab and self.info.tab < 3) then
		self.info[EJ_Tabs[self.info.tab].button]:Click()
	else
		self.info.overviewTab:Click();
	end

	if not noButton then
		local buttonData = {
			id = instanceID,
			name = instanceName,
			OnClick = EJNAV_RefreshInstance,
			listFunc = EJNAV_ListInstance,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end

function EncounterJournal_DisplayEncounter(encounterID, noButton, scrollToEncounter)
	if encounterID == -1 then
		return
	end

	local self = EncounterJournal.encounter;
	local ename, description, _, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounterID);

	if EncounterJournal.encounterID == encounterID or EncounterJournal.instanceID == instanceID then
		EncounterJournal_SetTab(EncounterJournal.encounter.info.tab)
	else
		EncounterJournal_ValidateSelectedTab()
	end

	if rootSectionID == 0 then
--		EncounterJournal_SetTab(EncounterJournal.encounter.info.lootTab:GetID())
	end

	if (EncounterJournal.encounterID == encounterID) then
		--navbar is already set to the right button, don't add another
		noButton = true;
	elseif (EncounterJournal.encounterID) then
		--make sure the previous navbar button is the instance button
		NavBar_OpenTo(EncounterJournal.navBar, EncounterJournal.instanceID);
	end

	EncounterJournal.encounterID = encounterID;
--	EJ_SelectEncounter(encounterID);
	EncounterJournal_LootUpdate();
	--need to clear details, but don't want to scroll to top of bosses list
	local bossListScrollValue = self.info.bossesScroll.ScrollBar:GetValue()
	EncounterJournal_ClearDetails();
	EncounterJournal.encounter.info.bossesScroll.ScrollBar:SetValue(bossListScrollValue);

	self.info.TitleFrame.encounterTitle:SetText(ename);

	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.overviewTab, (rootSectionID > 0));

	local overviewFound;
	if (EncounterJournal_CheckForOverview(rootSectionID)) then
		local _, overviewDescription = EJ_GetSectionInfo(rootSectionID)
		self.overviewFrame.loreDescription:SetHeight(0);
		self.overviewFrame.loreDescription:SetWidth(self.overviewFrame:GetWidth() - 5);
		self.overviewFrame.loreDescription:SetText(description);
		self.overviewFrame.overviewDescription:SetWidth(self.overviewFrame:GetWidth() - 5);
		self.overviewFrame.overviewDescription.Text:SetWidth(self.overviewFrame:GetWidth() - 5);
		EncounterJournal_SetBullets(self.overviewFrame.overviewDescription, overviewDescription, false);
		local bulletHeight = 0;
		if (self.overviewFrame.Bullets and #self.overviewFrame.Bullets > 0) then
			for i = 1, #self.overviewFrame.Bullets do
				bulletHeight = bulletHeight + self.overviewFrame.Bullets[i]:GetHeight();
			end
			local bullet = self.overviewFrame.Bullets[1];
			bullet:ClearAllPoints();
			bullet:SetPoint("TOPLEFT", self.overviewFrame.overviewDescription, "BOTTOMLEFT", 0, -9);
		end
		self.overviewFrame.descriptionHeight = self.overviewFrame.loreDescription:GetHeight() + self.overviewFrame.overviewDescription:GetHeight() + bulletHeight + 42;
		self.overviewFrame.rootOverviewSectionID = rootSectionID;
		rootSectionID = EncounterJournal_GetRootAfterOverviews(rootSectionID);
		overviewFound = true;
	end

	self.infoFrame.description:SetWidth(self.infoFrame:GetWidth() -5);
	self.infoFrame.description:SetText(description);
	self.infoFrame.descriptionHeight = self.infoFrame.description:GetHeight();

	self.infoFrame.encounterID = encounterID;
	self.infoFrame.rootSectionID = rootSectionID;
	self.infoFrame.expanded = false;

	EncounterJournal.encounterList = {}

	local selectedEncounterIndex;

	local bossIndex = 1;
	local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;
	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
		if not bossButton then -- create a new header;
			bossButton = CreateFrame("BUTTON", "EncounterJournalBossButton"..bossIndex, EncounterJournal.encounter.bossesFrame, "EncounterBossButtonTemplate");
			if bossIndex > 1 then
				bossButton:SetPoint("TOPLEFT", _G["EncounterJournalBossButton"..(bossIndex-1)], "BOTTOMLEFT", 0, -BOSS_BUTTON_SECOND_OFFSET);
			else
				bossButton:SetPoint("TOPLEFT", EncounterJournal.encounter.bossesFrame, "TOPLEFT", 0, -BOSS_BUTTON_FIRST_OFFSET);
			end
		end

		bossButton.link = link;
		if IsGMAccount() then
			local _, _, _, _, _, creatureID, encounterID = EJ_GetCreatureInfo(1, bossID)
			bossButton:SetFormattedText("[%d][%d] %s", encounterID or 0, creatureID or 0, name)
		else
			bossButton:SetText(name);
		end
		bossButton:Show();
		bossButton.encounterID = bossID;
		--Use the boss' first creature as the button icon
		local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, bossID);
		bossImage = bossImage or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
		bossButton.creature:SetTexture(bossImage);

		if (encounterID == bossID) then
			bossButton:LockHighlight();
			selectedEncounterIndex = bossIndex;
		else
			bossButton:UnlockHighlight();
		end

		table.insert(EncounterJournal.encounterList, bossID)

		bossIndex = bossIndex + 1;
		name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	end

	if selectedEncounterIndex and scrollToEncounter then
		bossIndex = bossIndex - 1;

		local value, maxScrollRange = ScrollFrame_GetScrollValueForIndex(EncounterJournal.encounter.info.bossesScroll, selectedEncounterIndex, bossIndex, BOSS_BUTTON_HEIGHT, BOSS_BUTTON_SECOND_OFFSET)
		ScrollFrame_OnScrollRangeChanged(EncounterJournal.encounter.info.bossesScroll, 0, maxScrollRange);
		EncounterJournal.encounter.info.bossesScroll.ScrollBar:SetValue(value);
	end

	-- Setup Creatures
	local id, name, displayInfo, iconImage, creatureID;
	for i=1,MAX_CREATURES_PER_ENCOUNTER do
		id, name, description, displayInfo, iconImage, creatureID = EJ_GetCreatureInfo(i);
		if id then
			local button = EncounterJournal_GetCreatureButton(i);
		--	SetPortraitTexture(button.creature, displayInfo);
			button.creature:SetPortrait(displayInfo)
			button.name = name;
			button.id = id;
			button.description = description;
			button.displayInfo = creatureID;
		end
	end

	--enable model and abilities tab
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.modelTab, true);
	EncounterJournal_SetTabEnabled(EncounterJournal.encounter.info.bossTab, true);

	if (overviewFound) then
		EncounterJournal_ToggleHeaders(self.overviewFrame);
		self.overviewFrame:Show();
	else
		self.overviewFrame:Hide();
	end

	EncounterJournal_ToggleHeaders(self.infoFrame);

	self:Show();

	--make sure we stay on the tab we were on
	self.info[EJ_Tabs[self.info.tab].button]:Click()

	if not noButton then
		local buttonData = {
			id = encounterID,
			name = ename,
			OnClick = EJNAV_RefreshEncounter,
			listFunc = EJNAV_ListEncounter,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end

function EncounterJournal_DisplayCreature(self)
	if EncounterJournal.encounter.info.shownCreatureButton then
		EncounterJournal.encounter.info.shownCreatureButton:Enable();
	end

	EncounterJournal.encounter.info.model:SetCreature(self.displayInfo)
	EncounterJournal.creatureDisplayID = self.displayInfo

	EncounterJournal.encounter.info.model.imageTitle:SetText(self.name)

	self:Disable();
	EncounterJournal.encounter.info.shownCreatureButton = self;
end

function EncounterJournal_ShowCreatures()
	for index, creatureButton in ipairs(EncounterJournal.encounter.info.creatureButtons) do
		if (creatureButton.displayInfo) then
			creatureButton:Show();
			if index == 1 then
				EncounterJournal_DisplayCreature(creatureButton);
			end
		end
	end
end

function EncounterJournal_HideCreatures(clearDisplayInfo)
	for index, creatureButton in ipairs(EncounterJournal.encounter.info.creatureButtons) do
		creatureButton:Hide();

		if clearDisplayInfo then
			creatureButton.displayInfo = nil;
		end
	end
end

local toggleTempList = {};
local headerCount = 0;
local loopedSections = {};

function EncounterJournal_UpdateButtonState(self)
	local oldtex = self.textures.expanded;
	if self:GetParent().expanded then
		self.tex = self.textures.expanded;
		oldtex = self.textures.collapsed;
		self.expandedIcon:SetTextColor(0.929, 0.788, 0.620);
		self.title:SetTextColor(0.929, 0.788, 0.620);
	else
		self.tex = self.textures.collapsed;
		self.expandedIcon:SetTextColor(0.827, 0.659, 0.463);
		self.title:SetTextColor(0.827, 0.659, 0.463);
	end

	oldtex.up[1]:Hide();
	oldtex.up[2]:Hide();
	oldtex.up[3]:Hide();
	oldtex.down[1]:Hide();
	oldtex.down[2]:Hide();
	oldtex.down[3]:Hide();


	self.tex.up[1]:Show();
	self.tex.up[2]:Show();
	self.tex.up[3]:Show();
	self.tex.down[1]:Hide();
	self.tex.down[2]:Hide();
	self.tex.down[3]:Hide();
end

function EncounterJournal_OnClick(self)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		if self.link then
			ChatEdit_InsertLink(self.link);
		end
		return;
	end

	EncounterJournal_ToggleHeaders(self:GetParent())
	self:GetScript("OnShow")(self);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function EncounterJournal_OnHyperlinkEnter(self, link, text)
	local linkType = string.split(":", link, 2)

	if linkType == "kbase" then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		GameTooltip:AddLine(KNOWLEDGE_BASE, 1, 1, 1)
		GameTooltip:Show()
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(link);
	end
end

function EncounterJournal_CleanBullets(self, start, keep)
	if (not self.Bullets) then return end
    start = start or 1;
	for i = start, #self.Bullets do
		self.Bullets[i]:Hide();
		if (not keep) then
			if (not self.BulletCache) then
				self.BulletCache = {};
			end
			self.Bullets[i]:ClearAllPoints();
			tinsert(self.BulletCache, self.Bullets[i]);
			self.Bullets[i] = nil;
		end
	end
end

function EncounterJournal_SetBullets(object, description, hideBullets)
	local parent = object:GetParent();
	local parentWidth = 60
	local characterHeight = 16

	if (not string.find(description, "%$bullet;")) then
		object.Text:SetText(description);
		object.textString = description;
		local height = (strlenutf8(description) / parentWidth) * characterHeight
		object:SetHeight(height)
	--	object:SetHeight(object.Text:GetContentHeight());
		EncounterJournal_CleanBullets(parent);
		return;
	end

	local desc = string.match(description, "(.-)%$bullet;");

	if (desc) then
		object.Text:SetText(desc);
		object.textString = desc;
		local height = (strlenutf8(desc) / parentWidth) * characterHeight
		object:SetHeight(height)
	--	object:SetHeight(object.Text:GetContentHeight());
	end

	local bullets = {}
	for v in string.gmatch(description,"%$bullet;([^$]+)") do
		tinsert(bullets, v);
	end

	local k = 1;
	local skipped = 0;
	for j = 1,#bullets do
		local text = bullets[j];
		if (text and text ~= "") then
			local bullet;
			bullet = parent.Bullets and parent.Bullets[k];
			if (not bullet) then
				if (parent.BulletCache and #parent.BulletCache > 0) then
					-- We only need to check for BulletCache because the BulletCache is created when we clean the bullets, so the BulletCache existing also means the Bullets exist.
					parent.Bullets[k] = tremove(parent.BulletCache);
					bullet = parent.Bullets[k];
				else
					bullet = CreateFrame("Frame", nil, parent, "EncounterOverviewBulletTemplate");
				end
				bullet:SetWidth(307)
				bullet.Text:SetWidth(300 - 26)
			--	bullet:SetWidth(parent:GetWidth() - 13);
			--	bullet.Text:SetWidth(parentWidth - 26);
			end
			bullet:ClearAllPoints();
			if (k == 1) then
				if (parent.button) then
					bullet:SetPoint("TOPLEFT", parent.button, "BOTTOMLEFT", 13, -9 - object:GetHeight());
				else
					bullet:SetPoint("TOPLEFT", parent, "TOPLEFT", 13, -9 - object:GetHeight());
				end
			else
				bullet:SetPoint("TOP", parent.Bullets[k-1], "BOTTOM", 0, -8);
			end
			bullet.Text:SetText(text);

			local height = (strlenutf8(text) / parentWidth) * characterHeight
			if (height ~= 0) then
				bullet:SetHeight(height);
			end
--[[
			if (bullet.Text:GetContentHeight() ~= 0) then
				bullet:SetHeight(bullet.Text:GetContentHeight());
			end
--]]
			if (hideBullets) then
				bullet:Hide();
			else
				bullet:Show();
			end
			k = k + 1;
		else
			skipped = skipped + 1;
		end
	end

	EncounterJournal_CleanBullets(parent, (#bullets - skipped) + 1);
end

function EncounterJournal_SetDescriptionWithBullets(infoHeader, description)
	description = EncounterJournal_ParseDifficultyMacros(description)
	EncounterJournal_SetBullets(infoHeader.overviewDescription, description, true);

	infoHeader.descriptionBG:ClearAllPoints();
	infoHeader.descriptionBG:SetPoint("TOPLEFT", infoHeader.button, "BOTTOMLEFT", 1, 0);
	if (infoHeader.Bullets and #infoHeader.Bullets > 0) then
		infoHeader.descriptionBG:SetPoint("BOTTOMRIGHT", infoHeader.Bullets[#infoHeader.Bullets], -1, -11);
	else
		infoHeader.descriptionBG:SetPoint("BOTTOMRIGHT", infoHeader.overviewDescription, 9, -11);
	end
	infoHeader.descriptionBG:Hide();
	infoHeader.descriptionBGBottom:Hide();
end

function EncounterJournal_SetUpOverview(self, role, index)
	local infoHeader;
	if not self.overviews[index] then -- create a new header;
		infoHeader = CreateFrame("FRAME", "EncounterJournalOverviewInfoHeader"..index, EncounterJournal.encounter.overviewFrame, "EncounterInfoTemplate");
		infoHeader.description:Hide();
		infoHeader.overviewDescription:Hide();
		infoHeader.descriptionBG:Hide();
		infoHeader.descriptionBGBottom:Hide();
		infoHeader.button.abilityIcon:Hide();
		infoHeader.button.portrait:Hide();
		infoHeader.button.portrait.name = nil;
		infoHeader.button.portrait.displayInfo = nil;
		infoHeader.button.icon2:Hide();
		infoHeader.button.icon3:Hide();
		infoHeader.button.icon4:Hide();
		infoHeader.overviewIndex = index;
		infoHeader.isOverview = true;

		local textLeftAnchor = infoHeader.button.expandedIcon;
		local textRightAnchor = infoHeader.button.icon1;
		infoHeader.button.title:SetPoint("LEFT", textLeftAnchor, "RIGHT", 5, 0);
		infoHeader.button.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0);

		self.overviews[index] = infoHeader;
	else
		infoHeader = self.overviews[index];
	end

	infoHeader.button.expandedIcon:SetText("+");
	infoHeader.expanded = false;

	infoHeader:ClearAllPoints();
	if (index == 1) then
		infoHeader:SetPoint("TOPLEFT", 0, -15 - self.descriptionHeight - SECTION_BUTTON_OFFSET);
		infoHeader:SetPoint("TOPRIGHT", 0, -15 - self.descriptionHeight - SECTION_BUTTON_OFFSET);
	else
		infoHeader:SetPoint("TOPLEFT", self.overviews[index-1], "BOTTOMLEFT", 0, -9);
		infoHeader:SetPoint("TOPRIGHT", self.overviews[index-1], "BOTTOMRIGHT", 0, -9);
	end

	infoHeader.description:Hide();

	for i = 1, #infoHeader.Bullets do
		infoHeader.Bullets[i]:Hide();
	end

	wipe(infoHeader.Bullets);
	local title, description, siblingID, link, filteredByDifficulty, flag1

	local _, _, _, _, _, _, nextSectionID =  EJ_GetSectionInfo(self.rootOverviewSectionID)

	while nextSectionID do
		title, description, _, _, _, siblingID, _, filteredByDifficulty, link, _, _, flag1 = EJ_GetSectionInfo(nextSectionID)
		if (role == rolesByFlag[flag1] and not filteredByDifficulty) then
			break
		end
		nextSectionID = siblingID
	end

	if (not title) then
		infoHeader:Hide();
		return;
	end

	infoHeader.button.icon1:Show()
	EncounterJournal_SetFlagIcon(infoHeader.button.icon1.icon, flag1)

	infoHeader.button.title:SetText(title)
	infoHeader.button.link = link;
	infoHeader.sectionID = nextSectionID;

	infoHeader.overviewDescription:SetWidth(infoHeader:GetWidth() - 20);
	EncounterJournal_SetDescriptionWithBullets(infoHeader, description);
	infoHeader:Show();
end


function EncounterJournal_ToggleHeaders(self, doNotShift)
	local numAdded = 0;
	local infoHeader, parentID, _;
	local hWidth = self:GetWidth();
	local nextSectionID;
	local topLevelSection = false;

	local isOverview = self.isOverview;

	local hideHeaders;
	if (not self.isOverview or (self.isOverview and self.overviewIndex)) then
		self.expanded = not self.expanded;
		hideHeaders = not self.expanded;
	end

	if hideHeaders then
		self.button.expandedIcon:SetText("+");
		self.description:Hide();
		if (self.overviewDescription) then
			self.overviewDescription:Hide();
		end
		self.descriptionBG:Hide();
		self.descriptionBGBottom:Hide();

		EncounterJournal_CleanBullets(self, nil, true);

		if (self.overviewIndex) then
			local overview = EncounterJournal.encounter.overviewFrame.overviews[self.overviewIndex + 1];

			if (overview) then
				overview:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -9);
			end
		else
			EncounterJournal_ClearChildHeaders(self);
		end
	else
		if (not isOverview) then
			if strlen(self.description:GetText() or "") > 2 then
				self.description:Show();
				if (self.overviewDescription) then
					self.overviewDescription:Hide();
				end
				if self.button then
					self.descriptionBG:Show();
					self.descriptionBGBottom:Show();
					self.button.expandedIcon:SetText("-");
				end
			elseif self.button then
				self.description:Hide();
				if (self.overviewDescription) then
					self.overviewDescription:Hide();
				end
				self.descriptionBG:Hide();
				self.descriptionBGBottom:Hide();
				self.button.expandedIcon:SetText("-");
			end
		else
			if (self.overviewIndex) then
				self.button.expandedIcon:SetText("-");
				for i = 1, #self.Bullets do
					self.Bullets[i]:Show();
				end
				self.description:Hide();
				self.overviewDescription:Show();
				self.descriptionBG:Show();
				self.descriptionBGBottom:Show();

				local overview = EncounterJournal.encounter.overviewFrame.overviews[self.overviewIndex + 1];

				if (overview) then
					if (self.Bullets and #self.Bullets > 0) then
						overview:SetPoint("TOPLEFT", self.Bullets[#self.Bullets], "BOTTOMLEFT", -13, -18);
					else
						local yoffset = -18 - self:GetHeight();
						overview:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, yoffset);
					end
				end
				EncounterJournal_UpdateButtonState(self.button);
			end
		end

		-- Get Section Info
		if (not isOverview) then
			local freeHeaders = EncounterJournal.encounter.freeHeaders;
			local usedHeaders = EncounterJournal.encounter.usedHeaders;

			local listEnd = #usedHeaders;

			if self.myID then  -- this is from a button click
				_, _, _, _, _, _, nextSectionID =  EJ_GetSectionInfo(self.myID);
				parentID = self.myID;
				self.description:SetWidth(self:GetWidth() -20);
				hWidth = hWidth - HEADER_INDENT;
			else
				--This sets the base encounter header
				parentID = self.encounterID;
				nextSectionID = self.rootSectionID;
				topLevelSection = true;
			end

			local pass
			while nextSectionID do
				local title, description, headerType, abilityIcon, displayInfo, siblingID, nextNextSectionID, fileredByDifficulty, link, startsOpen, creatureEntry, flag1, flag2, flag3, flag4 = EJ_GetSectionInfo(nextSectionID)

				if nextNextSectionID and nextNextSectionID ~= 0 then
					local _, childSectionID = EJ_GetSectionPath(nextSectionID)
					if childSectionID == nextNextSectionID then
						loopedSections[#loopedSections + 1] = nextSectionID
						pass = true
					end
				end

				if pass then
					pass = nil
				elseif not title then
					break
				elseif not fileredByDifficulty then
					if #freeHeaders == 0 then -- create a new header;
						headerCount = headerCount + 1; -- the is a file local
						infoHeader = CreateFrame("FRAME", "EncounterJournalInfoHeader"..headerCount, EncounterJournal.encounter.infoFrame, "EncounterInfoTemplate");
						infoHeader:Hide();
					else
						infoHeader = freeHeaders[#freeHeaders];
						freeHeaders[#freeHeaders] = nil;
					end

					numAdded = numAdded + 1;
					toggleTempList[#toggleTempList+1] = infoHeader;

					infoHeader.button.link = link;
					infoHeader.parentID = parentID;
					infoHeader.myID = nextSectionID;

					description = EncounterJournal_ParseDifficultyMacros(description);
					-- Spell names can show up in white, which clashes with the parchment, strip out white color codes.
					description = description:gsub("|cffffffff(.-)|r", "%1");

					infoHeader.description:SetText(description)
					infoHeader.button.title:SetText(title)
					if topLevelSection then
						infoHeader.button.title:SetFontObject("GameFontNormalMed3");
					else
						infoHeader.button.title:SetFontObject("GameFontNormal");
					end

					--All headers start collapsed
					infoHeader.expanded = false
					infoHeader.description:Hide();
					infoHeader.descriptionBG:Hide();
					infoHeader.descriptionBGBottom:Hide();
					infoHeader.button.expandedIcon:SetText("+");

					for i = 1, #infoHeader.Bullets do
						infoHeader.Bullets[i]:Hide();
					end

					local textLeftAnchor = infoHeader.button.expandedIcon;
					--Show ability Icon
					if abilityIcon then
						infoHeader.button.abilityIcon:SetTexture(abilityIcon);
						infoHeader.button.abilityIcon:Show();
						textLeftAnchor = infoHeader.button.abilityIcon;
					else
						infoHeader.button.abilityIcon:Hide();
					end

					--Show Creature Portrait
					if displayInfo ~= 0 then
					--	SetPortraitTexture(infoHeader.button.portrait.icon, displayInfo)
						infoHeader.button.portrait.icon:SetPortrait(displayInfo)
						infoHeader.button.portrait.name = title;
						infoHeader.button.portrait.displayInfo = creatureEntry;
						infoHeader.button.portrait:Show();
						textLeftAnchor = infoHeader.button.portrait;
						infoHeader.button.abilityIcon:Hide();
					else
						infoHeader.button.portrait:Hide();
						infoHeader.button.portrait.name = nil;
						infoHeader.button.portrait.displayInfo = nil;
					end
					infoHeader.button.title:SetPoint("LEFT", textLeftAnchor, "RIGHT", 5, 0);

					local textRightAnchor = nil
					infoHeader.button.icon1:Hide()
					infoHeader.button.icon2:Hide()
					infoHeader.button.icon3:Hide()
					infoHeader.button.icon4:Hide()
					if flag1 then
						textRightAnchor = infoHeader.button.icon1
						infoHeader.button.icon1:Show()
						infoHeader.button.icon1.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag1]
						infoHeader.button.icon1.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag1]
						EncounterJournal_SetFlagIcon(infoHeader.button.icon1.icon, flag1)
						if flag2 then
							textRightAnchor = infoHeader.button.icon2
							infoHeader.button.icon2:Show()
							EncounterJournal_SetFlagIcon(infoHeader.button.icon2.icon, flag2)
							infoHeader.button.icon2.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag2]
							infoHeader.button.icon2.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag2]
							if flag3 then
								textRightAnchor = infoHeader.button.icon3
								infoHeader.button.icon3:Show()
								EncounterJournal_SetFlagIcon(infoHeader.button.icon3.icon, flag3)
								infoHeader.button.icon3.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag3]
								infoHeader.button.icon3.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag3]
								if flag4 then
									textRightAnchor = infoHeader.button.icon4
									infoHeader.button.icon4:Show()
									EncounterJournal_SetFlagIcon(infoHeader.button.icon4.icon, flag4)
									infoHeader.button.icon4.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag4]
									infoHeader.button.icon4.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag4]
								end
							end
						end
					end
					if textRightAnchor then
						infoHeader.button.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0)
					else
						infoHeader.button.title:SetPoint("RIGHT", infoHeader.button, "RIGHT", -5, 0)
					end

					infoHeader.index = nil;
					infoHeader:SetWidth(hWidth);

					-- If this section has not be seen and should start open
					if EJ_section_openTable[infoHeader.myID] == nil and startsOpen then
						EJ_section_openTable[infoHeader.myID] = true;
					end

					--toggleNested?
					if EJ_section_openTable[infoHeader.myID]  then
						infoHeader.expanded = false; -- setting false to expand it in EncounterJournal_ToggleHeaders
						numAdded = numAdded + EncounterJournal_ToggleHeaders(infoHeader, true);
					end

					infoHeader:Show();
				end -- if not filteredByDifficulty

				nextSectionID = siblingID;
			end

			if not doNotShift and numAdded > 0 then
				--fix the usedlist
				local startIndex = self.index or 0;
				for i=listEnd,startIndex+1,-1 do
					usedHeaders[i+numAdded] = usedHeaders[i];
					usedHeaders[i+numAdded].index = i + numAdded;
					usedHeaders[i] = nil
				end
				for i=1,numAdded do
					usedHeaders[startIndex + i] = toggleTempList[i];
					usedHeaders[startIndex + i].index = startIndex + i;
					toggleTempList[i] = nil;
				end
			end

			if topLevelSection and usedHeaders[1] then
				usedHeaders[1]:SetPoint("TOPRIGHT", 0 , -8 - EncounterJournal.encounter.infoFrame.descriptionHeight - SECTION_BUTTON_OFFSET);
			end

			if not doNotShift and #loopedSections ~= 0 then
				StaticPopup_Show("ENCOUNTER_JOURNAL_SECTION_LOOP_ERROR_DIALOG", table.concat(loopedSections, ", "))
				table.wipe(loopedSections)
			end
		elseif (not self.overviewIndex) then
			for i = 1, #self.overviews do
				self.overviews[i]:Hide();
			end

			EncounterJournal.overviewDefaultRole = nil;

			if (not self.rootOverviewSectionID) then
				return;
			end

			local spec, role;
--[[
			spec = GetSpecialization();
			if (spec) then
				role = GetSpecializationRole(spec);
			else
				role = "DAMAGER";
			end
--]]

			role = "DAMAGER"

			EncounterJournal_SetUpOverview(self, role, 1)

			local k = 2
			for i = 1, 3 do
				local otherRole = overviewPriorities[i]
				if (otherRole ~= role) then
					EncounterJournal_SetUpOverview(self, otherRole, k)
					k = k + 1
				end
			end

			if (self.linkSection) then
				for i = 1, 3 do
					local overview = self.overviews[i];
					if (overview.sectionID == self.linkSection) then
						overview.expanded = false;
							EncounterJournal_ToggleHeaders(overview);
						overview.cbCount = 0;
						overview.button.glow.flashAnim:Play();
						overview:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
					else
						overview.expanded = true;
							EncounterJournal_ToggleHeaders(overview);
						overview.button.glow.flashAnim:Stop();
						overview:SetScript("OnUpdate", nil);
					end
				end
				self.linkSection = nil;
			elseif self.overviews and self.overviews[1] then
				self.overviews[1].expanded = false;
				EncounterJournal.overviewDefaultRole = role;
				EncounterJournal_ToggleHeaders(self.overviews[1]);
			end
		end
	end

	if (not isOverview) then
		if self.myID then
			EJ_section_openTable[self.myID] = self.expanded;
		end

		if not doNotShift then
			EncounterJournal_ShiftHeaders(self.index or 1);

			--check to see if it is offscreen
			if self.index then
				local scrollValue = EncounterJournal.encounter.info.detailsScroll.ScrollBar:GetValue();
				local cutoff = EncounterJournal.encounter.info.detailsScroll:GetHeight() + scrollValue;

				local _, _, _, _, anchorY = self:GetPoint();
				anchorY = anchorY - self:GetHeight();
				if self.description:IsShown() then
					anchorY = anchorY - self.description:GetHeight() - SECTION_DESCRIPTION_OFFSET;
				end

				if cutoff < abs(anchorY) then
					self.frameCount = 0;
					self:SetScript("OnUpdate", EncounterJournal_MoveSectionUpdate);
				end
			end
		end
		return numAdded;
	else
		return 0;
	end
end

function EncounterJournal_ShiftHeaders(index)
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	if not usedHeaders[index] then
		return;
	end

	local _, _, _, _, anchorY = usedHeaders[index]:GetPoint();
	for i=index,#usedHeaders-1 do
		anchorY = anchorY - usedHeaders[i]:GetHeight();
		if usedHeaders[i].description:IsShown() then
			anchorY = anchorY - usedHeaders[i].description:GetHeight() - SECTION_DESCRIPTION_OFFSET;
		else
			anchorY = anchorY - SECTION_BUTTON_OFFSET;
		end

		usedHeaders[i+1]:SetPoint("TOPRIGHT", 0 , anchorY);
	end
end

function EncounterJournal_ResetHeaders()
	for key,_ in pairs(EJ_section_openTable) do
		EJ_section_openTable[key] = nil;
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
	EncounterJournal_UpdateScrollPos(EncounterJournal.encounter.info.lootScroll, 1)
	EJ_SetValidationDifficulty(1)
	EJ_ResetLootFilter()
	EncounterJournal_Refresh();
end

function EncounterJournal_FocusSection(sectionID)
	if (not EncounterJournal_CheckForOverview(sectionID)) then
		local usedHeaders = EncounterJournal.encounter.usedHeaders;
		for _, section in pairs(usedHeaders) do
			if section.myID == sectionID then
				section.cbCount = 0;
				section.button.glow.flashAnim:Play();
				section:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
			else
				section.button.glow.flashAnim:Stop();
				section:SetScript("OnUpdate", nil);
			end
		end
	end
end

function EncounterJournal_FocusSectionCallback(self)
	if self.cbCount > 0 then
		local _, _, _, _, anchorY = self:GetPoint();
		anchorY = abs(anchorY);
		anchorY = anchorY - EncounterJournal.encounter.info.detailsScroll:GetHeight()/2
		EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(anchorY)
		self:SetScript("OnUpdate", nil);
	end
	self.cbCount = self.cbCount + 1;
end

function EncounterJournal_MoveSectionUpdate(self)
	if self.frameCount > 0 then
		local _, _, _, _, anchorY = self:GetPoint();
		local height = min(EJ_MAX_SECTION_MOVE, self:GetHeight() + self.description:GetHeight() + SECTION_DESCRIPTION_OFFSET);
		local scrollValue = abs(anchorY) - (EncounterJournal.encounter.info.detailsScroll:GetHeight()-height);
		EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(scrollValue);
		self:SetScript("OnUpdate", nil);
	end
	self.frameCount = self.frameCount + 1;
end

function EncounterJournal_ClearChildHeaders(self, doNotShift)
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local numCleared = 0
	for key,header in pairs(usedHeaders) do
		if header.parentID == self.myID then
			if header.expanded then
				numCleared = numCleared + EncounterJournal_ClearChildHeaders(header, true)
			end
			header:Hide();
			usedHeaders[key] = nil;
			freeHeaders[#freeHeaders+1] = header;
			numCleared = numCleared + 1;
		end
	end

	if numCleared > 0 and not doNotShift then
		local placeIndex = self.index + 1;
		local shiftHeader = usedHeaders[placeIndex + numCleared];
		while shiftHeader do
			usedHeaders[placeIndex] = shiftHeader;
			usedHeaders[placeIndex].index = placeIndex;
			usedHeaders[placeIndex + numCleared] = nil;
			placeIndex = placeIndex + 1;
			shiftHeader = usedHeaders[placeIndex + numCleared];
		end
	end
	return numCleared
end

function EncounterJournal_ClearDetails()
	EncounterJournal.encounter.instance:Hide();
	EncounterJournal.encounter.infoFrame.description:SetText("");
	EncounterJournal.encounter.info.TitleFrame.encounterTitle:SetText("");

	EncounterJournal.encounter.info.overviewScroll.ScrollBar:SetValue(0);
	EncounterJournal.encounter.info.lootScroll.scrollBar:SetValue(0);
	EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(0);
	EncounterJournal.encounter.info.bossesScroll.ScrollBar:SetValue(0);

	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local usedHeaders = EncounterJournal.encounter.usedHeaders;

	for key,used in pairs(usedHeaders) do
		used:Hide();
		usedHeaders[key] = nil;
		freeHeaders[#freeHeaders+1] = used;
	end

	local clearDisplayInfo = true;
	EncounterJournal_HideCreatures(clearDisplayInfo);

	local bossIndex = 1
	local bossButton = _G["EncounterJournalBossButton"..bossIndex];
	while bossButton do
		bossButton:Hide();
		bossIndex = bossIndex + 1;
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
	end

--	EncounterJournal.searchResults:Hide();
--	EncounterJournal_HideSearchPreview();
--	EncounterJournal.searchBox:ClearFocus();
end

function EncounterJournal_TabClicked(self, button)
	local tabType = self:GetID();
	EncounterJournal_SetTab(tabType);
	PlaySound("igAbiliityPageTurn");
end

function EncounterJournal_SetTab(tabType)
	local info = EncounterJournal.encounter.info;
	info.tab = tabType;
	for key, data in pairs(EJ_Tabs) do
		if key == tabType then
			info[data.frame]:Show();
			info[data.button].selected:Show();
			info[data.button].unselected:Hide();
			info[data.button]:LockHighlight();
		else
			info[data.frame]:Hide();
			info[data.button].selected:Hide();
			info[data.button].unselected:Show();
			info[data.button]:UnlockHighlight();
		end
	end

	UpdateDifficultyVisibility();
end

function EncounterJournal_SetTabEnabled(tab, enabled)
	tab:SetEnabled(enabled);
	tab:GetDisabledTexture():SetDesaturated(not enabled);
	tab.unselected:SetDesaturated(not enabled);
	if not enabled then
		EncounterJournal_ValidateSelectedTab();
	end
end

function EncounterJournal_ValidateSelectedTab()
	local info = EncounterJournal.encounter.info;
	local selectedTabButton = info[EJ_Tabs[info.tab].button];
	if selectedTabButton:IsEnabled() ~= 1 then
		for index, data in ipairs(EJ_Tabs) do
			local tabButton = info[data.button];
			if tabButton:IsEnabled() == 1 then
				EncounterJournal_SetTab(index);
				break;
			end
		end
	end
end

function EncounterJournal_SetLootButton(item)
	local itemID, encounterID, name, icon, slot, armorType, link = EJ_GetLootInfoByIndex(item.index);

	if ( name ) then
		item.name:SetText(name);
		item.icon:SetTexture(icon);
		item.slot:SetText(slot);
		item.armorType:SetText(armorType == ITEM_SUB_CLASS_15_0 and "" or armorType);

		item.boss:SetFormattedText(BOSS_INFO_STRING, EJ_GetEncounterInfo(encounterID));

		local itemName, _, quality = GetItemInfo(link)
		SetItemButtonQuality(item, quality, itemID)

		if (quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality]) then
			item.name:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
		end
	else
		item.name:SetText(RETRIEVING_ITEM_INFO);
		item.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		item.slot:SetText("");
		item.armorType:SetText("");
		item.boss:SetText("");
		item:Hide();
	end

	item.encounterID = encounterID;
	item.itemID = itemID;
	item.link = link;
	item:Show();

	if item.showingTooltip then
		EncounterJournal_SetTooltip(link);
	end
end

function EncounterJournal_LootUpdate()
	EncounterJournal_UpdateFilterString();
	local scrollFrame = EncounterJournal.encounter.info.lootScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local item, index;

	local numLoot = EJ_GetNumLoot();
	local buttonSize = BOSS_LOOT_BUTTON_HEIGHT;
	local buttons = scrollFrame.buttons;

	for i = 1, #buttons do
		local button = buttons[i];
		index = offset + i;
		if index <= numLoot then
			if (EncounterJournal.encounterID) then
				button:SetHeight(BOSS_LOOT_BUTTON_HEIGHT);
				button.boss:Hide();
				button.bossTexture:Hide();
				button.bosslessTexture:Show();
			else
				buttonSize = INSTANCE_LOOT_BUTTON_HEIGHT;
				button:SetHeight(INSTANCE_LOOT_BUTTON_HEIGHT);
				button.boss:Show();
				button.bossTexture:Show();
				button.bosslessTexture:Hide();
			end
			button.index = index;
			EncounterJournal_SetLootButton(button);
			button.glow.flashAnim:Stop()
		else
			button:Hide();
		end
	end

	local totalHeight = numLoot * buttonSize;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end

function EncounterJournal_LootCalcScroll(offset)
	local buttonHeight = BOSS_LOOT_BUTTON_HEIGHT;

	if (not EncounterJournal.encounterID) then
		buttonHeight = INSTANCE_LOOT_BUTTON_HEIGHT;
	end

	local index = floor(offset/buttonHeight)
	return index, offset - (index*buttonHeight);
end

function EncounterJournal_Loot_OnUpdate(self)
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end

function EncounterJournal_Loot_OnClick(self)
	if (EncounterJournal.encounterID ~= self.encounterID) then
		PlaySound("igSpellBookOpen");
		EncounterJournal_DisplayEncounter(self.encounterID);
	end
end

function EncounterJournal_SetTooltip(link)
	if (not link) then
		return;
	end

	GameTooltip:SetAnchorType("ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(link);
end

function EncounterJournal_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;

	-- Mythic flag should use heroic Icon
	if (index == 12) then
		index = 3;
	end

	local l = mod(index, columns) / columns;
	local r = l + (1/columns);
	local t = floor(index/columns) / rows;
	local b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end

function EncounterJournal_Refresh(self)
	EncounterJournal_LootUpdate();

	if EncounterJournal.encounterID then
		EncounterJournal_DisplayEncounter(EncounterJournal.encounterID, true)
	elseif EncounterJournal.instanceID then
		EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
	end
end

function EncounterJournal_GetSearchDisplay(index)
	local name, icon, path, typeText, displayInfo, itemID, _;
	local id, stype, _, instanceID, encounterID, itemLink = EJ_GetSearchResult(index);
	if stype == EJ_STYPE_INSTANCE then
		name, _, _, icon = EJ_GetInstanceInfo(id);
		typeText = ENCOUNTER_JOURNAL_INSTANCE;
	elseif stype == EJ_STYPE_ENCOUNTER then
		name = EJ_GetEncounterInfo(id);
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER;
		path = EJ_GetInstanceInfo(instanceID);
		icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
		--_, _, _, displayInfo = EJ_GetCreatureInfo(1, encounterID)
	elseif stype == EJ_STYPE_SECTION then
		name, _, _, icon, displayInfo = EJ_GetSectionInfo(id)
		if displayInfo and displayInfo > 0 then
			typeText = ENCOUNTER_JOURNAL_ENCOUNTER_ADD;
			displayInfo = nil;
			icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature";
		else
			typeText = ENCOUNTER_JOURNAL_ABILITY;
		end
		path = EJ_GetInstanceInfo(instanceID).." > "..EJ_GetEncounterInfo(encounterID);
	elseif stype == EJ_STYPE_ITEM then
		itemID, _, name, icon = EJ_GetLootInfo(id)
		typeText = ENCOUNTER_JOURNAL_ITEM;
		path = EJ_GetInstanceInfo(instanceID).." > "..EJ_GetEncounterInfo(encounterID);
	elseif stype == EJ_STYPE_CREATURE then
		for i=1,MAX_CREATURES_PER_ENCOUNTER do
			local cId, cName, _, cDisplayInfo = EJ_GetCreatureInfo(i, encounterID);
			if cId == id then
				name = cName
				displayInfo = cDisplayInfo
				break;
			end
		end
		icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
		typeText = CREATURE
		path = EJ_GetInstanceInfo(instanceID).." > "..EJ_GetEncounterInfo(encounterID);
	end
	return name, icon, path, typeText, displayInfo, itemID, stype, itemLink;
end

function EncounterJournal_SelectSearch(index)
	local _;
	local id, stype, difficultyMask, instanceID, encounterID = EJ_GetSearchResult(index);
	local sectionID, creatureID, itemID;
	if stype == EJ_STYPE_INSTANCE then
		instanceID = id;
	elseif stype == EJ_STYPE_SECTION then
		sectionID = id;
	elseif stype == EJ_STYPE_ITEM then
		itemID = id;
	elseif stype == EJ_STYPE_CREATURE then
		creatureID = id;
	end

	local difficultyID = EJ_GetDifficultyByMask(difficultyMask, instanceID) or 1

	if not EJ_IsValidInstanceDifficulty(difficultyID, instanceID) then
		difficultyID = EJ_GetValidationDifficulty(1)
	end

	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID);
	EncounterJournal.searchResults:Hide();
	EncounterJournal_HideSearchPreview()
	EncounterJournal.searchBox:ClearFocus()
end

function EncounterJournal_SearchUpdate()
	local scrollFrame = EncounterJournal.searchResults.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local results = scrollFrame.buttons;
	local result, index;

	local numResults = EJ_GetNumSearchResults();

	for i = 1,#results do
		result = results[i];
		index = offset + i;
		if index <= numResults then
			local name, icon, path, typeText, displayInfo, itemID, stype, itemLink = EncounterJournal_GetSearchDisplay(index);
			if stype == EJ_STYPE_INSTANCE then
				result.icon:SetTexCoord(0.16796875, 0.51171875, 0.03125, 0.71875);
			else
				result.icon:SetTexCoord(0, 1, 0, 1);
			end

			result.name:SetText(name);
			result.resultType:SetText(typeText);
			result.path:SetText(path);
			result.icon:SetTexture(icon);
			result.link = itemLink;
			if displayInfo and displayInfo > 0 then
			--	SetPortraitTexture(result.icon, displayInfo);
				result.icon:SetPortrait(displayInfo)
			end
			result:SetID(index);
			result:Show();

			if result.showingTooltip then
				if itemLink then
					GameTooltip:SetOwner(result, "ANCHOR_RIGHT");
					GameTooltip:SetHyperlink(itemLink);
					GameTooltip_ShowCompareItem();
				else
					GameTooltip:Hide();
				end
			end
		else
			result:Hide();
		end
	end

	local totalHeight = numResults * 49;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 370);
end

function EncounterJournal_ShowFullSearch()
	local numResults = EJ_GetNumSearchResults();
	if numResults == 0 then
		EncounterJournal.searchResults:Hide();
		return;
	end

	EncounterJournal.searchResults.TitleText:SetFormattedText(ENCOUNTER_JOURNAL_SEARCH_RESULTS, EncounterJournal.searchBox:GetText(), numResults);
	EncounterJournal.searchResults:Show();
	EncounterJournal_SearchUpdate();
	EncounterJournal.searchResults.scrollFrame.scrollBar:SetValue(0);
	EncounterJournal_HideSearchPreview();
	EncounterJournal.searchBox:ClearFocus();
end

function EncounterJournal_RestartSearchTracking()
	if EJ_GetNumSearchResults() > 0 then
		EncounterJournal_ShowSearch();
	else
		EncounterJournal.searchBox.searchPreviewUpdateDelay = 0;
		EncounterJournal.searchBox:SetScript("OnUpdate", EncounterJournalSearchBox_OnUpdate);

		--Since we just restarted the search we hide the progress bar until the search delay is done.
		EncounterJournal.searchBox.searchProgress:Hide();
		EncounterJournal_FixSearchPreviewBottomBorder();
	end
end

function EncounterJournal_ShowSearch()
	if EncounterJournal.searchResults:IsShown() then
		EncounterJournal_ShowFullSearch();
	else
		EncounterJournal_UpdateSearchPreview();
	end
end

function EncounterJournal_ToggleTutorial()
	if not HelpPlate_IsShowing(EncounterJournal.helpPlate) then
		HelpPlate_Show(EncounterJournal.helpPlate, EncounterJournal, EncounterJournal.TutorialButton)
	else
		HelpPlate_Hide(true)
	end
end

function EncounterJournal_UpdateScrollPos(self, visibleIndex)
	local buttons = self.buttons
	local height = math.max(0, math.floor(self.buttonHeight * (visibleIndex - (#buttons)/2)))
	HybridScrollFrame_SetOffset(self, height)
	self.scrollBar:SetValue(height)
end

-- There is a delay before the search is updated to avoid a search progress bar if the search
-- completes within the grace period.
local ENCOUNTER_JOURNAL_SEARCH_PREVIEW_UPDATE_DELAY = 0.6;
function EncounterJournalSearchBox_OnUpdate(self, elapsed)
	if EJ_GetNumSearchResults() > 0 then
		EncounterJournal_ShowSearch();
		self.searchPreviewUpdateDelay = nil;
		self:SetScript("OnUpdate", nil);
		return;
	end

	self.searchPreviewUpdateDelay = (self.searchPreviewUpdateDelay or 0) + elapsed;

	if self.searchPreviewUpdateDelay > ENCOUNTER_JOURNAL_SEARCH_PREVIEW_UPDATE_DELAY then
		self.searchPreviewUpdateDelay = nil;
		self:SetScript("OnUpdate", nil);
		EncounterJournal_UpdateSearchPreview();
		return;
	end
end

function EncounterJournalSearchBoxSearchProgressBar_OnLoad(self)
	self:SetStatusBarColor(0, .6, 0, 1);
	self:SetMinMaxValues(0, 1000);
	self:SetValue(0);
	self:GetStatusBarTexture():SetDrawLayer("BORDER");
end

function EncounterJournalSearchBoxSearchProgressBar_OnShow(self)
--	self:SetScript("OnUpdate", EncounterJournalSearchBoxSearchProgressBar_OnUpdate);
end

function EncounterJournalSearchBoxSearchProgressBar_OnHide(self)
	self:SetScript("OnUpdate", nil);
	self:SetValue(0);
	self.previousResults = nil;
end

function EncounterJournal_UpdateSearchPreview()
	if strlen(EncounterJournal.searchBox:GetText()) < MIN_CHARACTER_SEARCH then
		EncounterJournal_HideSearchPreview();
		EncounterJournal.searchResults:Hide();
		return;
	end

	local numResults = EJ_GetNumSearchResults();

	if numResults == 0 then
		EncounterJournal_HideSearchPreview();
		return;
	end

	local lastShown = EncounterJournal.searchBox;
	for index = 1, EJ_NUM_SEARCH_PREVIEWS do
		local button = EncounterJournal.searchBox.searchPreview[index];
		if index <= numResults then
			local name, icon, path, typeText, displayInfo, itemID, stype, itemLink = EncounterJournal_GetSearchDisplay(index)
			if stype == EJ_STYPE_INSTANCE then
				button.icon:SetTexCoord(0.16796875, 0.51171875, 0.03125, 0.71875)
			else
				button.icon:SetTexCoord(0, 1, 0, 1)
			end

			button.name:SetText(name);
			button.icon:SetTexture(icon);
			button.link = itemLink;
			if displayInfo and displayInfo > 0 then
			--	SetPortraitTexture(button.icon, displayInfo);
				button.icon:SetPortrait(displayInfo)
			end
			button:SetID(index);
			button:Show();
			lastShown = button;
		else
			button:Hide();
		end
	end

	EncounterJournal.searchBox.showAllResults:Hide();
	EncounterJournal.searchBox.searchProgress:Hide();

	EncounterJournal.searchBox.showAllResults.text:SetFormattedText(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults)

	EncounterJournal_FixSearchPreviewBottomBorder();
	EncounterJournal.searchBox.searchPreviewContainer:Show();
end

function EncounterJournal_FixSearchPreviewBottomBorder()
	EncounterJournal.searchBox.showAllResults:SetShown(EJ_GetNumSearchResults() >= EJ_SHOW_ALL_SEARCH_RESULTS_INDEX)

	local lastShownButton = nil;
	if EncounterJournal.searchBox.showAllResults:IsShown() then
		lastShownButton = EncounterJournal.searchBox.showAllResults;
	elseif EncounterJournal.searchBox.searchProgress:IsShown() then
		lastShownButton = EncounterJournal.searchBox.searchProgress;
	else
		for index = 1, EJ_NUM_SEARCH_PREVIEWS do
			local button = EncounterJournal.searchBox.searchPreview[index];
			if button:IsShown() then
				lastShownButton = button;
			end
		end
	end

	if lastShownButton ~= nil then
		EncounterJournal.searchBox.searchPreviewContainer.botRightCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8);
		EncounterJournal.searchBox.searchPreviewContainer.botLeftCorner:SetPoint("BOTTOM", lastShownButton, "BOTTOM", 0, -8);
	else
		EncounterJournal_HideSearchPreview();
	end
end

function EncounterJournal_HideSearchPreview()
	EncounterJournal.searchBox.showAllResults:Hide();
	EncounterJournal.searchBox.searchProgress:Hide();

	local index = 1;
	local unusedButton = EncounterJournal.searchBox.searchPreview[index];
	while unusedButton do
		unusedButton:Hide();
		index = index + 1;
		unusedButton = EncounterJournal.searchBox.searchPreview[index];
	end

	EncounterJournal.searchBox.searchPreviewContainer:Hide();
end

function EncounterJournalSearchBox_OnLoad(self)
	SearchBoxTemplate_OnLoad(self);
	self.HasStickyFocus = function()
		local ancestry = EncounterJournal.searchBox;
		return DoesAncestryInclude(ancestry, GetMouseFocus());
	end
	self.selectedIndex = 1;
end

function EncounterJournalSearchBox_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function EncounterJournalSearchBox_OnHide(self)
	self.searchPreviewUpdateDelay = nil;
	self:SetScript("OnUpdate", nil);
end

function EncounterJournalSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	local text = self:GetText();
	if strlen(text) < MIN_CHARACTER_SEARCH then
	--	EJ_ClearSearch();
		EncounterJournal_HideSearchPreview();
		EncounterJournal.searchResults:Hide();
		return;
	end

	EncounterJournal_SetSearchPreviewSelection(1);
	EJ_SetSearch(text);
	EncounterJournal_RestartSearchTracking();
end

function EncounterJournalSearchBox_OnEnterPressed(self)
	if self.selectedIndex > EJ_SHOW_ALL_SEARCH_RESULTS_INDEX or self.selectedIndex < 0 then
		return;
	elseif self.selectedIndex == EJ_SHOW_ALL_SEARCH_RESULTS_INDEX then
		if EncounterJournal.searchBox.showAllResults:IsShown() then
			EncounterJournal.searchBox.showAllResults:Click();
		end
	else
		local preview = EncounterJournal.searchBox.searchPreview[self.selectedIndex];
		if preview:IsShown() then
			preview:Click();
		end
	end

	EncounterJournal_HideSearchPreview();
end

function EncounterJournalSearchBox_OnTabPressed(self)
	if IsShiftKeyDown() then
		EncounterJournal_SetSearchPreviewSelection(EncounterJournal.searchBox.selectedIndex - 1);
	else
		EncounterJournal_SetSearchPreviewSelection(EncounterJournal.searchBox.selectedIndex + 1);
	end
end

function EncounterJournalSearchBox_OnFocusLost(self)
	SearchBoxTemplate_OnEditFocusLost(self);
	EncounterJournal_HideSearchPreview();
end

function EncounterJournalSearchBox_OnFocusGained(self)
	SearchBoxTemplate_OnEditFocusGained(self);
	EncounterJournal.searchResults:Hide();
	EncounterJournal_SetSearchPreviewSelection(1);
	EncounterJournal_UpdateSearchPreview();
end

function EncounterJournalSearchBoxShowAllResults_OnEnter(self)
	EncounterJournal_SetSearchPreviewSelection(EJ_SHOW_ALL_SEARCH_RESULTS_INDEX);
end

function EncounterJournal_SetSearchPreviewSelection(selectedIndex)
	local searchBox = EncounterJournal.searchBox;
	local numShown = 0;
	for index = 1, EJ_NUM_SEARCH_PREVIEWS do
		searchBox.searchPreview[index].selectedTexture:Hide();

		if searchBox.searchPreview[index]:IsShown() then
			numShown = numShown + 1;
		end
	end

	if searchBox.showAllResults:IsShown() then
		numShown = numShown + 1;
	end

	searchBox.showAllResults.selectedTexture:Hide();

	if numShown == 0 then
		selectedIndex = 1;
	elseif selectedIndex > numShown then
		-- Wrap under to the beginning.
		selectedIndex = 1;
	elseif selectedIndex < 1 then
		-- Wrap over to the end;
		selectedIndex = numShown;
	end

	searchBox.selectedIndex = selectedIndex;

	if selectedIndex == EJ_SHOW_ALL_SEARCH_RESULTS_INDEX then
		searchBox.showAllResults.selectedTexture:Show();
	else
		searchBox.searchPreview[selectedIndex].selectedTexture:Show();
	end
end

function EncounterJournal_OpenJournalLink(tag, jtype, id, difficultyID)
	jtype = tonumber(jtype);
	id = tonumber(id);
	difficultyID = tonumber(difficultyID);
	local instanceID, encounterID, sectionID, tierIndex = EJ_HandleLinkPath(jtype, id);
	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, nil, nil, tierIndex);
end

function EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID, tierIndex)
	EJ_HideNonInstancePanels();
	ShowUIPanel(EncounterJournal);
	if instanceID then
		NavBar_Reset(EncounterJournal.navBar);
		EJ_ContentTab_SelectAppropriateInstanceTab(instanceID);

		EncounterJournal_DisplayInstance(instanceID);
		if not difficultyID or difficultyID == -1 then
			EJ_SetValidationDifficulty(1)
		else
			EJ_SetDifficulty(difficultyID);
		end

		if encounterID then
			if sectionID then
				if (EncounterJournal_CheckForOverview(sectionID)) then
					EncounterJournal.encounter.overviewFrame.linkSection = sectionID;
				else
					local sectionPath = {EJ_GetSectionPath(sectionID)};
					for _, id in pairs(sectionPath) do
						EJ_section_openTable[id] = true;
					end
				end
			end
			EncounterJournal_DisplayEncounter(encounterID, nil, true);
			if sectionID then
				if (EncounterJournal_CheckForOverview(sectionID) or not EncounterJournal_SearchForOverview(instanceID)) then
					EncounterJournal.encounter.info.overviewTab:Click();
				else
					EncounterJournal.encounter.info.bossTab:Click();
				end
				EncounterJournal_FocusSection(sectionID);
			elseif itemID then
				local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemID)

				if not EJ_GetClassFilterValidation(itemSubType, itemType, itemID) then
					EJ_SetLootFilter(0)
					EncounterJournal_LootUpdate()
				end

				EncounterJournal.encounter.info.lootTab:Click();

				local index = 1
				local _itemID, _encounterID, _name, _icon, _slot, _armorType, _link = EJ_GetLootInfoByIndex(index)

				while _itemID do
					if _itemID == itemID then
						EncounterJournal_UpdateScrollPos(EncounterJournal.encounter.info.lootScroll, index)

						local buttons = EncounterJournal.encounter.info.lootScroll.buttons
						for i = 1, #buttons do
							local button = buttons[i]

							if button.itemID == itemID then
								button.glow.flashAnim:Play()
								break
							end
						end
						break
					end

					index = index + 1
					_itemID, _encounterID, _name, _icon, _slot, _armorType, _link = EJ_GetLootInfoByIndex(index)
				end
			end

		end
	elseif tierIndex then
		EncounterJournal_TierDropDown_Select(EncounterJournal, tierIndex+1);
	else
		EncounterJournal_ListInstances();
	end
end

function EncounterJournal_SelectDifficulty(self, value)
	EJ_SetDifficulty(value);
end

function EncounterJournal_DifficultyInit(self, level)
	local currDifficulty = EJ_GetDifficulty();
	local info = UIDropDownMenu_CreateInfo();
	for i, entry in ipairs(EJ_DIFFICULTIES) do
		if EJ_IsValidInstanceDifficulty(entry.difficultyID) and (entry.size ~= "5" == EJ_IsRaid(EncounterJournal.instanceID)) then
			info.func = EncounterJournal_SelectDifficulty;
			if (entry.size ~= "5") then
				info.text = string.format("(%s) %s", entry.size, entry.prefix)
			else
				info.text = entry.prefix;
			end
			info.arg1 = entry.difficultyID;
			info.checked = currDifficulty == entry.difficultyID;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function EJ_HideInstances(index)
	if ( not index ) then
		index = 1;
	end

	local scrollChild = EncounterJournal.instanceSelect.scroll.child;
	local instanceButton = scrollChild["instance"..index];
	while instanceButton do
		instanceButton:Hide();
		index = index + 1;
		instanceButton = scrollChild["instance"..index];
	end
end

function EJSuggestTab_GetPlayerTierIndex()
	local playerLevel = UnitLevel("player");
	local expansionId = LE_EXPANSION_LEVEL_CURRENT;
	local minDiff = MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT];
	for tierId, tierLevel in pairs(MAX_PLAYER_LEVEL_TABLE) do
		local diff = tierLevel - playerLevel;
		if ( diff > 0 and diff < minDiff ) then
			expansionId = tierId;
			minDiff = diff;
		end
	end
	return GetEJTierDataTableID(expansionId);
end

function EJ_ContentTab_OnClick(self)
	EJ_ContentTab_Select(self.id);
end

function EJ_ContentTab_Select(id)
	local instanceSelect = EncounterJournal.instanceSelect;

	local selectedTab = nil;
	for i = 1, #instanceSelect.Tabs do
		local tab = instanceSelect.Tabs[i];
		if ( tab.id ~= id ) then
			tab:Enable();
			tab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			tab.selectedGlow:Hide();
		else
			tab:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			tab:Disable();
			selectedTab = tab;
		end
	end

	EncounterJournal.instanceSelect.selectedTab = id;

	-- Setup background
	local tierData;
	if ( id == instanceSelect.suggestTab.id ) then
		tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	elseif id == instanceSelect.LootJournalTab.id then
		tierData = GetEJTierData(1)
	else
		tierData = GetEJTierData(EJ_GetCurrentTier());
	end
	selectedTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	selectedTab.selectedGlow:Show();
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);
	EncounterJournal.encounter:Hide();
	EncounterJournal.instanceSelect:Show();

	if ( id == instanceSelect.suggestTab.id ) then
		EJ_HideInstances();
		EJ_HideLootJournalPanel();
		instanceSelect.scroll:Hide();
		EncounterJournal.suggestFrame:Show();
		if ( not instanceSelect.dungeonsTab.grayBox:IsShown() or not instanceSelect.raidsTab.grayBox:IsShown() ) then
			EncounterJournal_DisableTierDropDown(true);
		else
			EncounterJournal_EnableTierDropDown();
		end
	elseif ( id == instanceSelect.LootJournalTab.id ) then
		EJ_HideInstances();
		EJ_HideSuggestPanel();
		instanceSelect.scroll:Hide();
		EncounterJournal_DisableTierDropDown(true);
		EJ_ShowLootJournalPanel();
	elseif ( id == instanceSelect.dungeonsTab.id or id == instanceSelect.raidsTab.id ) then
		EJ_HideNonInstancePanels();
		instanceSelect.scroll:Show();
		EncounterJournal_ListInstances();
		EncounterJournal_EnableTierDropDown();
	end
	PlaySound("igMainMenuOptionCheckBoxOn");
	EncounterJournal.TutorialButton:SetShown(id == instanceSelect.suggestTab.id or id == instanceSelect.dungeonsTab.id or id == instanceSelect.raidsTab.id)

	EventRegistry:TriggerEvent("EncounterJournal.SetTab", id)
end

function EJ_ContentTab_SelectAppropriateInstanceTab(instanceID)
	local isRaid = EJ_IsRaid(instanceID);
	local desiredTabID = isRaid and EncounterJournal.instanceSelect.raidsTab:GetID() or EncounterJournal.instanceSelect.dungeonsTab:GetID();
	EJ_ContentTab_Select(desiredTabID);
end

function EJ_HideSuggestPanel()
	local instanceSelect = EncounterJournal.instanceSelect;
	local suggestTab = instanceSelect.suggestTab;
	if ( not suggestTab:IsEnabled() or EncounterJournal.suggestFrame:IsShown() ) then
		suggestTab:Enable();
		suggestTab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		suggestTab.selectedGlow:Hide();
		EncounterJournal.suggestFrame:Hide();

		EncounterJournal_EnableTierDropDown();

		local tierData = GetEJTierData(EJ_GetCurrentTier());
		instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);
		instanceSelect.raidsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
		instanceSelect.dungeonsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
		instanceSelect.scroll:Show();

		EncounterJournal.suggestFrame:Hide();
	end
end

function EJ_HideLootJournalPanel()
	if ( EncounterJournal.LootJournal ) then
		EncounterJournal.LootJournal:Hide();
	end
	if ( EncounterJournal.LootJournalItems ) then
		EncounterJournal.LootJournalItems:Hide();
	end
end

function EJ_ShowLootJournalPanel()
	local activeLootPanel = EncounterJournal_GetLootJournalPanels();
	activeLootPanel:Show();
end

function EJ_HideNonInstancePanels()
	EJ_HideSuggestPanel();
	EJ_HideLootJournalPanel();
end

function EJTierDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	local numTiers = EJ_GetNumTiers();

	local currTier = EJ_GetCurrentTier();
	for i=1,numTiers do
		info.text = EJ_GetTierInfo(i);
		info.func = EncounterJournal_TierDropDown_Select
		info.checked = i == currTier;
		info.arg1 = i;
		UIDropDownMenu_AddButton(info, level)
	end
end

function EncounterJournal_TierDropDown_Select(_, tier)
	EJ_SelectTier(tier);

	local instanceSelect = EncounterJournal.instanceSelect;
	instanceSelect.dungeonsTab.grayBox:Hide();
	instanceSelect.raidsTab.grayBox:Hide();

	local tierData = GetEJTierData(tier);
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);
	instanceSelect.raidsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	instanceSelect.dungeonsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);

	UIDropDownMenu_SetText(instanceSelect.tierDropDown, EJ_GetTierInfo(EJ_GetCurrentTier()));

	EncounterJournal_ListInstances();
end

function EncounterJournal_OnFilterChanged(self)
	CloseDropDownMenus(1);
	EncounterJournal_LootUpdate();
end

function EncounterJournal_SetClassAndSpecFilter(self, classFileName)
	EJ_SetLootFilter(classFileName);
	EncounterJournal_OnFilterChanged(self);
end

function EncounterJournal_RefreshSlotFilterText(self)
	local text = ALL_INVENTORY_SLOTS;
	local slotFilter = EJ_GetSlotFilter();
	if slotFilter ~= NO_INV_TYPE_FILTER then
		for _, slot in ipairs(EncounterJournalSlotFilters) do
			if ( slot.invType == slotFilter ) then
				text = slot.invTypeName;
				break;
			end
		end
	end

	EncounterJournal.encounter.info.lootScroll.slotFilter:SetText(text);
end

function EncounterJournal_SetSlotFilter(self, slot)
	EJ_SetSlotFilter(slot);
	EncounterJournal_RefreshSlotFilterText(self);
	EncounterJournal_OnFilterChanged(self);
end

function EncounterJournal_UpdateFilterString()
	local name = LOCALIZED_CLASS_NAMES_MALE[EJ_GetLootFilter()]
--[[
	local classID, specID = EJ_GetLootFilter();

	if (specID > 0) then
		_, name = GetSpecializationInfoByID(specID, UnitSex("player"))
	elseif (classID > 0) then
		name = GetClassInfoByID(classID);
	end
--]]

	if name then
		EncounterJournal.encounter.info.lootScroll.classClearFilter.text:SetFormattedText(EJ_CLASS_FILTER, name);
		EncounterJournal.encounter.info.lootScroll.classClearFilter:Show();
		EncounterJournal.encounter.info.lootScroll:SetHeight(360);
	else
		EncounterJournal.encounter.info.lootScroll.classClearFilter:Hide();
		EncounterJournal.encounter.info.lootScroll:SetHeight(382);
	end
end

function EncounterJournal_InitLootFilter()
	local classFileName = EJ_GetLootFilter()
	local info = UIDropDownMenu_CreateInfo()

	-- info.text = EJ_FILTER_ALL_CLASS
	-- info.checked = classFileName == NO_CLASS_FILTER
	-- info.arg1 = NO_CLASS_FILTER
	-- info.func = EncounterJournal_SetClassAndSpecFilter
	-- UIDropDownMenu_AddButton(info)

	info.func = EncounterJournal_SetClassAndSpecFilter

	for k, v in pairs(classLootData) do
		local className = LOCALIZED_CLASS_NAMES_MALE[v.fileName]

		if className then
			info.text = className
			info.arg1 = v.fileName
			info.checked = classFileName == v.fileName
			UIDropDownMenu_AddButton(info)
		end
	end
end

function EncounterJournal_InitLootSlotFilter()
	local slotFilter = EJ_GetSlotFilter();

	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL_INVENTORY_SLOTS;
	info.checked = slotFilter == NO_INV_TYPE_FILTER;
	info.arg1 = NO_INV_TYPE_FILTER;
	info.func = EncounterJournal_SetSlotFilter;
	UIDropDownMenu_AddButton(info);

	for _, slot in ipairs(EncounterJournalSlotFilters) do
		info.text = slot.invTypeName;
		info.checked = slotFilter == slot.invType;
		info.arg1 = slot.invType;
		UIDropDownMenu_AddButton(info);
	end
end


----------------------------------------
--------------Nav Bar Func--------------
----------------------------------------
function EJNAV_RefreshInstance()
	EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
end

function EJNAV_SelectInstance(self, index, navBar)
	local instanceID = EJ_GetInstanceByIndex(index, EJ_InstanceIsRaid());

	--Clear any previous selection.
	NavBar_Reset(navBar);

	EncounterJournal_DisplayInstance(instanceID);
end

function EJNAV_ListInstance(self, index)
	local _, name = EJ_GetInstanceByIndex(index, EJ_InstanceIsRaid())
	return name, EJNAV_SelectInstance
end

function EJNAV_RefreshEncounter()
	EncounterJournal_DisplayInstance(EncounterJournal.encounterID);
end

function EJNAV_SelectEncounter(self, index, navBar)
	local _, _, bossID = EJ_GetEncounterInfoByIndex(index);
	EncounterJournal_DisplayEncounter(bossID);
end

function EJNAV_ListEncounter(self, index)
	local name = EJ_GetEncounterInfoByIndex(index)
	return name, EJNAV_SelectEncounter
end

-------------------------------------------------
--------------Suggestion Panel Func--------------
-------------------------------------------------
function EJSuggestFrame_OnLoad(self)
	self.suggestions = {};

	self:RegisterCustomEvent("AJ_REWARD_DATA_RECEIVED");
	self:RegisterCustomEvent("AJ_REFRESH_DISPLAY");
end

function EJSuggestFrame_OnEvent(self, event, ...)
	if ( event == "AJ_REFRESH_DISPLAY" ) then
		if self:GetParent().selectedTab == EncounterJournal.instanceSelect.suggestTab.id then
			EJSuggestFrame_RefreshDisplay();
			local newAdventureNotice = ...;
			if ( newAdventureNotice ) then
--				EncounterJournalMicroButton:UpdateNewAdventureNotice();
			end
		end
	elseif ( event == "AJ_REWARD_DATA_RECEIVED" ) then
		EJSuggestFrame_RefreshRewards()
	end
end

function EJSuggestFrame_OnShow(self)
	SetParentFrameLevel(self)
--	EncounterJournalMicroButton:ClearNewAdventureNotice();

	C_AdventureJournal.UpdateSuggestions();
	EJSuggestFrame_RefreshDisplay();
	EncounterJournal_RefreshSlotFilterText();
end

function EJSuggestFrame_NextSuggestion()
	if ( C_AdventureJournal.GetPrimaryOffset() < C_AdventureJournal.GetNumAvailableSuggestions()-1 ) then
		C_AdventureJournal.SetPrimaryOffset(C_AdventureJournal.GetPrimaryOffset()+1);
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	end
end

function EJSuggestFrame_PrevSuggestion()
	if( C_AdventureJournal.GetPrimaryOffset() > 0 ) then
		C_AdventureJournal.SetPrimaryOffset(C_AdventureJournal.GetPrimaryOffset()-1);
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
	end
end

function EJSuggestFrame_OnMouseWheel( self, value )
	if ( value > 0 ) then
		EJSuggestFrame_PrevSuggestion();
	else
		EJSuggestFrame_NextSuggestion()
	end
end

function EJSuggestFrame_OpenFrame()
	EJ_ContentTab_Select(EncounterJournal.instanceSelect.suggestTab.id);
	NavBar_Reset(EncounterJournal.navBar);
end

function EJSuggestFrame_UpdateRewards(suggestion)
	local rewardData = C_AdventureJournal.GetReward( suggestion.index );
	suggestion.reward.data = rewardData;
	if ( rewardData ) then
		if rewardData.isRewardList then
			local numRewards = 0

			for index = 1, #suggestion.rewardFrames do
				local itemRewardData = rewardData[index]
				if itemRewardData then
					local texture = itemRewardData.itemIcon or "Interface\\Icons\\achievement_guildperk_mobilebanking";
					local rewardFrame = suggestion.rewardFrames[index]
				--	rewardFrame.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
				--	rewardFrame.icon:SetTexture(texture);
					SetPortraitToTexture(rewardFrame.icon, texture)
					rewardFrame.data = rewardData
					rewardFrame:Show()
					numRewards = numRewards + 1
				else
					suggestion.rewardFrames[index].data = nil
					suggestion.rewardFrames[index]:Hide()
				end
			end

			if suggestion.index == 1 then
				if numRewards > 1 then
					local offsetX = 0
					if numRewards == 2 then
						offsetX = 4
					elseif numRewards > 2 then
						offsetX = 4 + 11 * (numRewards - 2)
					end
					suggestion.reward:SetPoint("BOTTOM", -((numRewards - 1) * suggestion.rewardFrames[2]:GetWidth() + offsetX) / 2, 53)
				else
					suggestion.reward:SetPoint("BOTTOM", 0, 53)
				end
			end

			return
		end

		local texture = rewardData.itemIcon or rewardData.currencyIcon or
						"Interface\\Icons\\achievement_guildperk_mobilebanking";
		if ( rewardData.isRewardTable ) then
			texture = "Interface\\Icons\\achievement_guildperk_mobilebanking";
		end
	--	suggestion.reward.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	--	suggestion.reward.icon:SetTexture(texture);
		SetPortraitToTexture(suggestion.reward.icon, texture)
		suggestion.reward:Show();

		if suggestion.index == 1 then
			suggestion.reward:SetPoint("BOTTOM", 0, 53)
		end

		for index = 2, #suggestion.rewardFrames do
			suggestion.rewardFrames[index].data = nil
			suggestion.rewardFrames[index]:Hide()
		end
	end
end

AdventureJournal_LeftTitleFonts = {
	"DestinyFontHuge",		-- 32pt font
	"QuestFont_Enormous",	-- 30pt font
	"QuestFont_Super_Huge",	-- 24pt font
	"QuestFont22",			-- 24pt font
};

local AdventureJournal_RightTitleFonts = {
	"QuestFont_Huge", 	-- 18pt font
	"Fancy16Font",		-- 16pt font
};

local AdventureJournal_RightDescriptionFonts = {
	"SystemFont_Med1",	-- 12pt font
	-- "SystemFont_Small", -- 10pt font
};

function EJSuggestFrame_RefreshDisplay()
	local instanceSelect = EncounterJournal.instanceSelect;
	local tab = EncounterJournal.instanceSelect.suggestTab;
	local tierData = GetEJTierData(EJSuggestTab_GetPlayerTierIndex());
	tab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	tab.selectedGlow:Show();
	instanceSelect.bg:SetAtlas(tierData.backgroundAtlas, true);

	local self = EncounterJournal.suggestFrame;
	C_AdventureJournal.GetSuggestions(self.suggestions);

	-- hide all the display info
	for i = 1, AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = self["Suggestion"..i];
		suggestion.centerDisplay:Hide();
		if ( i == 1 ) then
			-- the left suggestion's button isn't on the centerDisplay frame
			suggestion.button:Hide();
		else
			suggestion.centerDisplay.button:Hide();
		end
	--	suggestion.reward:Hide();
		suggestion.icon:Hide();
		suggestion.iconRing:Hide();

		for index, rewardFrame in ipairs(suggestion.rewardFrames) do
			rewardFrame:Hide()
		end
	end

	-- setup the primary suggestion display
	if ( #self.suggestions > 0 ) then
		local suggestion = self.Suggestion1;
		local data = self.suggestions[1];

		local centerDisplay = suggestion.centerDisplay;
		local titleText = centerDisplay.title.text;
		local descText = centerDisplay.description.text;

		centerDisplay:SetHeight(suggestion:GetHeight());
		centerDisplay:Show();
	--	centerDisplay.title:SetHeight(0);
	--	centerDisplay.description:SetHeight(0);
		titleText:SetText(data.title);
		descText:SetText(data.description);

		-- find largest font that will not go past 2 lines
--[[
		for i = 1, #AdventureJournal_LeftTitleFonts do
			titleText:SetFontObject(AdventureJournal_LeftTitleFonts[i]);
			local numLines = titleText:GetNumLines();
			if ( numLines <= 2 and not titleText:IsTruncated() ) then
				break;
			end
		end

		-- resize the title to be 2 lines at most
		local numLines = min(2, titleText:GetNumLines());
		local fontHeight = select(2, titleText:GetFont());
		centerDisplay.title:SetHeight(numLines * fontHeight + 2);
		centerDisplay.description:SetHeight(descText:GetStringHeight());

		-- adjust the center display to keep the text centered
		local top = centerDisplay.title:GetTop();
		local bottom = centerDisplay.description:GetBottom();
		centerDisplay:SetHeight(top - bottom);
--]]

		centerDisplay.title:SetHeight(centerDisplay.title.text:GetHeight())
		centerDisplay.description:SetHeight(centerDisplay.description.text:GetHeight())

		centerDisplay:SetHeight(math.min(180, centerDisplay.title:GetHeight() + 10 + centerDisplay.description:GetHeight()))

		if ( data.buttonText and #data.buttonText > 0 ) then
			suggestion.button:SetText( data.buttonText );

			local btnWidth = max( suggestion.button:GetTextWidth()+42, 150 );
			btnWidth = min( btnWidth, centerDisplay:GetWidth() );
			suggestion.button:SetWidth( btnWidth );
			suggestion.button:Show();
		end

		suggestion.icon:Show();
		suggestion.iconRing:Show();
		if ( data.iconPath ) then
		--	suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
		--	suggestion.icon:SetTexture(data.iconPath);
			SetPortraitToTexture(suggestion.icon, data.iconPath)
		else
		--	suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
		--	suggestion.icon:SetTexture(QUESTION_MARK_ICON);
			SetPortraitToTexture(suggestion.icon, QUESTION_MARK_ICON)
		end

		suggestion.prevButton:SetEnabled(C_AdventureJournal.GetPrimaryOffset() > 0);
		suggestion.nextButton:SetEnabled(C_AdventureJournal.GetPrimaryOffset() < C_AdventureJournal.GetNumAvailableSuggestions()-1);

	--[[
		if ( titleText:IsTruncated() ) then
			centerDisplay.title:SetScript("OnEnter", EJSuggestFrame_SuggestionTextOnEnter);
			centerDisplay.title:SetScript("OnLeave", GameTooltip_Hide);
		else
			centerDisplay.title:SetScript("OnEnter", nil);
			centerDisplay.title:SetScript("OnLeave", nil);
		end
	--]]

		EJSuggestFrame_UpdateRewards(suggestion);
	else
		local suggestion = self.Suggestion1;
		suggestion.prevButton:SetEnabled(false);
		suggestion.nextButton:SetEnabled(false);
	end

	-- setup secondary suggestions display
	if ( #self.suggestions > 1 ) then
		local minTitleIndex = 1;
		local minDescIndex = 1;

		for i = 2, #self.suggestions do
			local suggestion = self["Suggestion"..i];
			if ( not suggestion ) then
				break;
			end

			suggestion.centerDisplay:Show();

			local data = self.suggestions[i];
			suggestion.centerDisplay.title.text:SetText(data.title);
			suggestion.centerDisplay.description.text:SetText(data.description ~= "" and data.description or " ");

			-- find largest font that will not truncate the title
			suggestion.centerDisplay.title.text:SetFontObject(AdventureJournal_RightTitleFonts[2]);
			minTitleIndex = 2
--[[
			for fontIndex = minTitleIndex, #AdventureJournal_RightTitleFonts do
				suggestion.centerDisplay.title.text:SetFontObject(AdventureJournal_RightTitleFonts[fontIndex]);
				minTitleIndex = fontIndex
				if (not suggestion.centerDisplay.title.text:IsTruncated()) then
					break;
				end
			end
--]]

			-- find largest font that will not go past 4 lines
			suggestion.centerDisplay.description.text:SetFontObject(AdventureJournal_RightDescriptionFonts[1]);
			minDescIndex = 1;
--[[
			for fontIndex = minDescIndex, #AdventureJournal_RightDescriptionFonts do
				suggestion.centerDisplay.description.text:SetFontObject(AdventureJournal_RightDescriptionFonts[fontIndex]);
				minDescIndex = fontIndex;
				if ( suggestion.centerDisplay.description.text:GetNumLines() <= 4 and
						not suggestion.centerDisplay.description.text:IsTruncated() ) then
					break;
				end
			end
]]

			if ( data.buttonText and #data.buttonText > 0 ) then
				suggestion.centerDisplay.button:SetText( data.buttonText );

				local btnWidth = max(suggestion.centerDisplay.button:GetTextWidth()+42, 116);
				btnWidth = min( btnWidth, suggestion.centerDisplay:GetWidth() );
				suggestion.centerDisplay.button:SetWidth( btnWidth );
				suggestion.centerDisplay.button:Show();
			end

			suggestion.icon:Show();
			suggestion.iconRing:Show();
			if ( data.iconPath ) then
			--	suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			--	suggestion.icon:SetTexture(data.iconPath);
				SetPortraitToTexture(suggestion.icon, data.iconPath)
			else
			--	suggestion.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			--	suggestion.icon:SetTexture(QUESTION_MARK_ICON);
				SetPortraitToTexture(suggestion.icon, QUESTION_MARK_ICON)
			end

			EJSuggestFrame_UpdateRewards(suggestion);
		end
		-- set the fonts to be the same for both right side sections
		-- adjust the center display to keep the text centered
		for i = 2, #self.suggestions do
			local suggestion = self["Suggestion"..i];
			suggestion.centerDisplay:SetHeight(suggestion:GetHeight());

			local title = suggestion.centerDisplay.title;
			local description = suggestion.centerDisplay.description;
			title.text:SetFontObject(AdventureJournal_RightTitleFonts[minTitleIndex]);
			description.text:SetFontObject(AdventureJournal_RightDescriptionFonts[minDescIndex]);
			local fontHeight = select(2, title.text:GetFont());
			title:SetHeight(fontHeight);
--[[
			local numLines = min(4, description.text:GetNumLines());
			fontHeight = select(2, description.text:GetFont());
			description:SetHeight(numLines * fontHeight);
--]]
			local numLines = 4
			fontHeight = select(2, description.text:GetFont());
			description:SetHeight(numLines * fontHeight);

			-- adjust the center display to keep the text centered
			local top = title:GetTop();
			local bottom = description:GetBottom();
			if ( suggestion.centerDisplay.button:IsShown() ) then
				bottom = suggestion.centerDisplay.button:GetBottom();
			end

		--[[
			if ( title.text:IsTruncated() ) then
				title:SetScript("OnEnter", EJSuggestFrame_SuggestionTextOnEnter);
				title:SetScript("OnLeave", GameTooltip_Hide);
			else
				title:SetScript("OnEnter", nil);
				title:SetScript("OnLeave", nil);
			end

			if ( description.text:IsTruncated() ) then
				description:SetScript("OnEnter", EJSuggestFrame_SuggestionTextOnEnter);
				description:SetScript("OnLeave", GameTooltip_Hide);
			else
				description:SetScript("OnEnter", nil);
				description:SetScript("OnLeave", nil);
			end
		--]]

			suggestion.centerDisplay:SetHeight(top - bottom);
		end
	end

	-- fix SimpleHTML hyperlinks positions
	for i = 1, AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = self["Suggestion"..i];
		suggestion:Hide()
		suggestion:Show()
	end
end

function EJSuggestFrame_SuggestionTextOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(self.text:GetText(), 1, 1, 1, 1, true);
	GameTooltip:Show();
end

function EJSuggestFrame_RefreshRewards()
	for i = 1, AJ_MAX_NUM_SUGGESTIONS do
		local suggestion = EncounterJournal.suggestFrame["Suggestion"..i];
		suggestion.reward:Hide();
		EJSuggestFrame_UpdateRewards(suggestion);
	end
end

function EJSuggestFrame_OnClick(self)
	C_AdventureJournal.ActivateEntry(self.index);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function AdventureJournal_Reward_OnEnter(self)
	local rewardData = self.data;
	if ( rewardData ) then
		if rewardData.isRewardList then
			local reward = rewardData[self:GetID()]
			if reward and reward.itemLink then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(reward.itemLink)
				GameTooltip:Show()
			end
			self.isRewardList = true
			return
		else
			self.isRewardList = nil
		end

		local frame = EncounterJournalTooltip;
		frame:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
		frame.clickText:Hide();

		local suggestion = EncounterJournal.suggestFrame.suggestions[self:GetParent().index];

		local rewardHeaderText = "";
		if ( rewardData.rewardDesc ) then
			rewardHeaderText = rewardData.rewardDesc;
		elseif ( rewardData.isRewardTable ) then
			if ( not suggestion.hideDifficulty and suggestion.difficultyID and suggestion.difficultyID > 1 ) then
				local difficultyStr = EJ_DIFFICULTIES[suggestion.difficultyID] and EJ_DIFFICULTIES[suggestion.difficultyID].prefix or ""
				if( rewardData.itemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DIFFICULTY_TEXT, suggestion.title, difficultyStr, rewardData.itemLevel);
				elseif ( rewardData.minItemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DIFFICULTY_IRANGE_TEXT, suggestion.title, difficultyStr, rewardData.minItemLevel, rewardData.maxItemLevel);
				end
			else
				if( rewardData.itemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DEFAULT_TEXT, suggestion.title, rewardData.itemLevel);
				elseif ( rewardData.minItemLevel ) then
					rewardHeaderText = format(AJ_LFG_REWARD_DEFAULT_IRANGE_TEXT, suggestion.title, rewardData.minItemLevel, rewardData.maxItemLevel);
				end
			end

			if( rewardData.itemLink ) then
				rewardHeaderText = rewardHeaderText..AJ_SAMPLE_REWARD_TEXT;
			end
		end

		if ( rewardData.itemLink and rewardData.currencyType ) then
			local itemName, _, quality = GetItemInfo(rewardData.itemLink);
			frame.Item1.text:SetText(itemName);
			frame.Item1.text:Show();
			frame.Item1.icon:SetTexture(rewardData.itemIcon);
			frame.Item1.tooltip:Hide();
			frame.Item1:SetSize(256, 28);
			frame.Item1:Show();

			if ( rewardData.itemQuantity and rewardData.itemQuantity > 1 ) then
				frame.Item1.Count:SetText(rewardData.itemQuantity);
				frame.Item1.Count:Show();
			else
				frame.Item1.Count:Hide();
			end

			SetItemButtonQuality(frame.Item1, quality, rewardData.itemLink);

			if (quality > Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
				frame.Item1.text:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			end

			local currencyName, _, quality, _, _, _, _, _, _, currencyIcon = C_Item.GetItemInfo(rewardData.currencyType, nil, nil, true)
			frame.Item2.icon:SetTexture(currencyIcon);
			frame.Item2.text:SetText(currencyName);
			frame.Item2:Show();

			SetItemButtonQuality(frame.Item2, quality);
			if (quality > Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
				frame.Item2.text:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
			end

			if ( rewardData.currencyQuantity and rewardData.currencyQuantity > 1 ) then
				frame.Item2.Count:SetText(rewardData.currencyQuantity);
				frame.Item2.Count:Show();
			else
				frame.Item2.Count:Hide();
			end
			local height = 100;

			frame:SetWidth(256);

			if ( rewardHeaderText and rewardHeaderText ~= "" ) then
				frame.headerText:SetText(rewardHeaderText);
				frame.Item1:SetPoint("TOPLEFT", frame.headerText, "BOTTOMLEFT", 0, -16);
				height = height + frame.headerText:GetHeight();
				frame.headerText:Show();
			else
				frame.headerText:Hide();
				frame.Item1:SetPoint("TOPLEFT", 11, -10);
			end

			frame:SetHeight(height);
		elseif ( rewardData.itemLink or rewardData.currencyType ) then
			frame.Item2:Hide();
			frame.Item1:Show();
			frame.Item1.text:Hide();

			local tooltip = frame.Item1.tooltip;
			tooltip:SetOwner(frame.Item1, "ANCHOR_NONE");
			frame.Item1.UpdateTooltip = function() AdventureJournal_Reward_OnEnter(self) end;
			if ( rewardData.itemLink ) then
				tooltip:SetHyperlink(rewardData.itemLink);
				GameTooltip_ShowCompareItem(tooltip, frame.Item1.tooltip);

				local quality = select(3, GetItemInfo(rewardData.itemLink));
				SetItemButtonQuality(frame.Item1, quality, rewardData.itemLink);

				if ( rewardData.itemQuantity and rewardData.itemQuantity > 1 ) then
					frame.Item1.Count:SetText(rewardData.itemQuantity);
					frame.Item1.Count:Show();
				else
					frame.Item1.Count:Hide();
				end

				self:SetScript("OnUpdate", EncounterJournal_AJ_OnUpdate);
				frame.Item1.icon:SetTexture(rewardData.itemIcon);
			elseif ( rewardData.currencyType ) then
				tooltip:SetHyperlink(strconcat("item:", rewardData.currencyType));

				local _, _, quality = C_Item.GetItemInfo(rewardData.currencyType, nil, nil, true);

				SetItemButtonQuality(frame.Item1, quality);

				if ( rewardData.currencyQuantity and rewardData.currencyQuantity > 1 ) then
					frame.Item1.Count:SetText(rewardData.currencyQuantity);
					frame.Item1.Count:Show();
				else
					frame.Item1.Count:Hide();
				end

				frame.Item1.icon:SetTexture(rewardData.currencyIcon);
			end

			frame:SetWidth(tooltip:GetWidth()+54);

			if ( rewardHeaderText and rewardHeaderText ~= "" ) then
				frame.headerText:SetText(rewardHeaderText);
				frame.headerText:Show();
				frame.Item1:SetPoint("TOPLEFT", frame.headerText, "BOTTOMLEFT", 0, -16);
			else
				frame.headerText:Hide();
				frame.Item1:SetPoint("TOPLEFT", 11, -10);
			end

			tooltip:SetPoint("TOPLEFT", frame.Item1.icon, "TOPRIGHT", 0, 10);
			tooltip:Show();

			frame.Item1:SetSize(tooltip:GetWidth()+44, tooltip:GetHeight());

			local height = tooltip:GetHeight() + 6;
			if ( frame.headerText:IsShown() ) then
				height = height + frame.headerText:GetHeight() + 14;
			end
			if (rewardData.isRewardTable) then
				frame.clickText:Show();
				self.iconRingHighlight:Show();
				height = height + 24;
			end

			frame:SetHeight(height);
		elseif ( rewardHeaderText and rewardHeaderText ~= "" ) then
		--	frame:SetWidth(256);
			frame.Item1:Hide();
			frame.Item2:Hide();

			frame.headerText:SetText(rewardHeaderText);
			frame:SetWidth(frame.headerText:GetStringWidth()+22); -- add padding for tooltip border
			frame:SetHeight(frame.headerText:GetStringHeight()+20); -- add padding for tooltip border
			frame.headerText:Show();
		else
			return;
		end
		frame:Show();
	end
end

function EncounterJournal_AJ_OnUpdate(self)
	local frame = EncounterJournalTooltip;
	local tooltip = frame.Item1.tooltip;
end

function AdventureJournal_Reward_OnLeave(self)
	if self.isRewardList then
		GameTooltip:Hide()
		return
	end

	EncounterJournalTooltip:Hide();
	self:SetScript("OnUpdate", nil);
	ResetCursor();

	self.iconRingHighlight:Hide();
end

function AdventureJournal_Reward_OnMouseDown(self)
	local index = self:GetParent().index;
	local data = EncounterJournal.suggestFrame.suggestions[index];
	if ( data.ej_instanceID ) then
		EncounterJournal_DisplayInstance(data.ej_instanceID);
		-- try to set difficulty to current instance difficulty
		if ( EJ_IsValidInstanceDifficulty(data.difficultyID) ) then
			EJ_SetDifficulty(data.difficultyID);
		end

		-- select the loot tab
		EncounterJournal.encounter.info[EJ_Tabs[2].button]:Click();
	elseif ( data.isRandomDungeon ) then
		EJ_ContentTab_Select(EncounterJournal.instanceSelect.dungeonsTab.id);
		EncounterJournal_TierDropDown_Select(nil, data.expansionLevel);
	end
end

function EncounterJournalBossButton_OnClick(self)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		if self.link then
			ChatEdit_InsertLink(self.link);
		end
		return;
	end
	local _, _, _, rootSectionID = EJ_GetEncounterInfo(self.encounterID);
	if ( rootSectionID == 0 ) then
		EncounterJournal_SetTab(EncounterJournal.encounter.info.lootTab:GetID());
	end
	EncounterJournal_DisplayEncounter(self.encounterID);
	PlaySound("igAbiliityPageTurn");
end

function EncounterInstanceButtonTemplate_OnClick(self)
	if not ChatEdit_TryInsertChatLink(self.link) then
		EncounterJournal_DisplayInstance(self.instanceID);
		local instanceID = EJ_GetCurrentInstance()
		if instanceID ~= self.instanceID then
			EJ_SetValidationDifficulty(1)
		end
		PlaySound("igSpellBookOpen");
	end
end

function EncounterInstanceButtonRequirements_OnLoad(self)
	EncounterJournal_SetFlagIcon(self.Icon, 3)
	self.awaitQuestCache = {}
end

function EncounterInstanceButtonRequirements_OnEvent(self, event, ...)
	if event == "QUEST_DATA_LOAD_RESULT" then
		if self:IsVisible() and GameTooltip:GetOwner() == self then
			local success, questID = ...
			if self.awaitQuestCache[questID] then
				self.awaitQuestCache[questID] = true

				if success then
					if self:IsMouseOverEx() then
						EncounterInstanceButtonRequirements_OnEnter(self)
					end
				end
			end
		end
	end
end

function EncounterInstanceButtonRequirements_OnEnter(self)
	if self:GetParent():IsMouseOverEx() then
		self:GetParent():LockHighlight()
	end

	if self.requirements then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip_AddNormalLine(GameTooltip, EJ_INSTANCE_REQUIREMENT_LABLE, true)

		for index, requirement in ipairs(self.requirements) do
			GameTooltip_AddBlankLineToTooltip(GameTooltip)

			local difficultyInfo = EJ_GetDifficultyInfo(requirement.difficultyID, requirement.isRaid)
			local difficultyStr
			if difficultyInfo then
				difficultyStr = string.format("(%s) %s", difficultyInfo.size, difficultyInfo.prefix)
			else
				difficultyStr = requirement.difficultyID
			end

			GameTooltip_AddNormalLine(GameTooltip, string.format(EJ_INSTANCE_REQUIREMENT_DIFFICULTY, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(difficultyStr)), true)

			if requirement.minLevel and requirement.maxLevel then
				local completed = WithinRange(UnitLevel("player"), requirement.minLevel or 1, requirement.maxLevel or MAX_PLAYER_LEVEL)
				local color = completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
				if requirement.minLevel == requirement.maxLevel then
					GameTooltip_AddNormalLine(GameTooltip, string.format(EJ_INSTANCE_REQUIREMENT_LEVEL, color:WrapTextInColorCode(requirement.maxLevel)), true)
				else
					GameTooltip_AddNormalLine(GameTooltip, string.format(EJ_INSTANCE_REQUIREMENT_LEVEL_RANGE, color:WrapTextInColorCode(requirement.minLevel), color:WrapTextInColorCode(requirement.maxLevel)), true)
				end
			end

			if requirement.itemLevel then
				local playerItemLevel = ItemLevelMixIn:GetItemLevel(UnitGUID("player"))
				local completed = playerItemLevel and playerItemLevel >= requirement.itemLevel
				local color = completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
				GameTooltip_AddNormalLine(GameTooltip, string.format(EJ_INSTANCE_REQUIREMENT_ITEM_LEVEL, color:WrapTextInColorCode(requirement.itemLevel)), true)
			end

			if requirement.quests then
				self:RegisterCustomEvent("QUEST_DATA_LOAD_RESULT")

				GameTooltip_AddNormalLine(GameTooltip, EJ_INSTANCE_REQUIREMENT_QUESTS, true)
				for questIndex, questID in ipairs(requirement.quests) do
					local completed = IsQuestCompleted(questID)
					local name = GetQuestNameByID(questID)
					if not name and not self.awaitQuestCache[questID] then
						self.awaitQuestCache[questID] = true
					end
					if IsGMAccount() then
						name = string.format("%s [%d]", name or UNKNOWN, questID)
					end
					local color = completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
					GameTooltip_AddColoredLine(GameTooltip, name, color, true)
				end
			end

			if requirement.achievements then
				GameTooltip_AddNormalLine(GameTooltip, EJ_INSTANCE_REQUIREMENT_ACHIEVEMENTS, true)
				for achievementIndex, achievementID in ipairs(requirement.achievements) do
					local id, name, points, completed, month, day, year, description, flags, icon = GetAchievementInfo(achievementID)
					if IsGMAccount() then
						name = string.format("%s [%d]", name, achievementID)
					end
					local color = completed and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR
					GameTooltip_AddColoredLine(GameTooltip, name, color, true)
				end
			end
		end

		GameTooltip:Show()
	end
end

function EncounterInstanceButtonRequirements_OnLeave(self)
	self:GetParent():UnlockHighlight()
	GameTooltip:Hide()
	self:UnregisterCustomEvent("QUEST_DATA_LOAD_RESULT")
end

function EncounterTabTemplate_OnClick(self, button)
	EncounterJournal_TabClicked(self, button);
	if (not EncounterJournal.encounterID and EncounterJournal.instanceID) then
		EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
	end
end

function EncounterItemTemplate_OnClick(self)
	if (not HandleModifiedItemClick(self.link)) then
		EncounterJournal_Loot_OnClick(self);
	else
		PlaySound("igMainMenuOption");
	end
end

function EncounterItemTemplate_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	EncounterJournal_SetTooltip(self.link);
	self.showingTooltip = true;
	self:SetScript("OnUpdate", EncounterJournal_Loot_OnUpdate);
end

function EncounterItemTemplate_OnLeave(self)
	GameTooltip:Hide();
	self.showingTooltip = false;
	self:SetScript("OnUpdate", nil);
	ResetCursor();
end

function EncounterJournal_ParseDifficultyMacros(description)
    if not string.find(description, "$[", 1, true) then
        return description
    end

	local realmStage = C_Service.GetRealmStage()
    local toReplace = {}

    for modificator, difficulty, text in string.gmatch(description,"%$%[(!?)([%d,]+)%s(.-)%$%]") do
    	local difficultyData = {strsplit(",", difficulty)}

		local valuesList = {strsplit(",", text)}
		for index, valueStr in ipairs(valuesList) do
			local stage, value = strsplit(":", valueStr)

			if not value then
				value = stage
				stage = nil
			else
				stage = tonumber(stage)
			end

			if not stage or stage <= realmStage or index == #valuesList then
				local textDefault = string.format("$%%[%s%s %s$%%]", modificator, difficulty, text)
				if tContains(difficultyData, tostring(SelectedDifficulty)) then
					if modificator == "!" then
						value = string.gsub(value, "^([\n]*)(%s*%w.*)", "%1|TInterface\\EncounterJournal\\UI-EJ-WarningTextIcon.blp:0|t|cffb70e0e%2|r")
					end
					table.insert(toReplace, {textDefault, value or ""})
				else
					table.insert(toReplace, {textDefault, ""})
				end

				break
			end
		end
    end

	for _, value in ipairs(toReplace) do
		description = description:gsub(value[1], value[2], 1)
    end

    return description
end

function LootJournal_GetEJItemInfoByEntry( itemEntry )
	if not itemEntry then
		return
	end

	local _, encounterID, _, _, _, _, _, difficultyID, factionID = EJ_GetLootInfo(itemEntry)

	if encounterID then
		local _, _, _, _, _, instanceID = EJ_GetEncounterInfo(encounterID)

		if difficultyID and encounterID and instanceID and encounterID then
			return difficultyID, encounterID, instanceID, encounterID, factionID
		end
	end

	return
end

function LootJournal_OpenItemByEntry( itemEntry )
	if not itemEntry then
		return
	end

	local difficultyID, encounterID, instanceID, encounterID = LootJournal_GetEJItemInfoByEntry(itemEntry)

	if encounterID then
		EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, nil, nil, itemEntry)
	end
end

local factionData = {
	[PLAYER_FACTION_GROUP.Horde] = -3,
	[PLAYER_FACTION_GROUP.Alliance] = -2,
	[PLAYER_FACTION_GROUP.Renegade] = -4,
	[PLAYER_FACTION_GROUP.Neutral] = -1,
}

function LootJournal_CanOpenItemByEntry( itemEntry, dontIgnoredFaction )
	local _, encounterID, _, _, factionID = LootJournal_GetEJItemInfoByEntry(itemEntry)
	local canOpened = false

	if encounterID then
		canOpened = true
	end

	if dontIgnoredFaction then
		local playerFactionID 		= C_Unit.GetFactionID("player")
		local convertedFactionID 	= factionData[playerFactionID]

		if factionID ~= convertedFactionID and factionID ~= -1 then
			canOpened = false
		end
	end

	return canOpened
end