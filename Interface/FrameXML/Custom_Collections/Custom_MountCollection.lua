--	Filename:	Sirus_MountCollection.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local MountJournalFilterDropDown_Data = {
	{
		{
			text = COLLECTED,
			isNotRadio = true,
			keyValue = "RECEIVED",
			checked = true,
		},
		{
			text = NOT_COLLECTED,
			isNotRadio = true,
			keyValue = "NO_RECEIVED"
		},
		{
			text = MOUNT_GROUND,
			func = function(self,_,_,_) _G["MOUNTJOURNAL_FILTER_"..self.keyValue] = not _G["MOUNTJOURNAL_FILTER_"..self.keyValue] and self.value end,
			isNotRadio = true,
			keyValue = "IS_GROUND",
			value = 1
		},
		{
			text = MOUNT_FLY,
			func = function(self,_,_,_) _G["MOUNTJOURNAL_FILTER_"..self.keyValue] = not _G["MOUNTJOURNAL_FILTER_"..self.keyValue] and self.value end,
			isNotRadio = true,
			keyValue = "IS_FLY",
			value = 2
		},
		{
			text = MOUNT_WATER,
			func = function(self,_,_,_) _G["MOUNTJOURNAL_FILTER_"..self.keyValue] = not _G["MOUNTJOURNAL_FILTER_"..self.keyValue] and self.value end,
			isNotRadio = true,
			keyValue = "IS_WATER",
			value = 4
		},
		{
			text = SOURCES,
			isNotRadio = nil,
			func = nil,
			hasArrow = true,
			notCheckable = true,
			value = 2
		},
		{
			text = EXPANSION_FILTER_TEXT,
			isNotRadio = nil,
			func = nil,
			hasArrow = true,
			notCheckable = true,
			value = 3,
		},
		{
			text = FACTION,
			isNotRadio = nil,
			func = nil,
			hasArrow = true,
			notCheckable = true,
			value = 4,
		},
	},
	{
		{
			text = CHECK_ALL,
			func = function(_,_,_,_)
				MOUNTJOURNAL_FILTER_SOURCE_LOOT = true
				MOUNTJOURNAL_FILTER_SOURCE_QUEST = true
				MOUNTJOURNAL_FILTER_SOURCE_VENDOR = true
				MOUNTJOURNAL_FILTER_SOURCE_CRAFT = true
				MOUNTJOURNAL_FILTER_SOURCE_ACHIEVEMENT = true
				MOUNTJOURNAL_FILTER_SOURCE_EVENT = true
				MOUNTJOURNAL_FILTER_SOURCE_STORE = true
				MOUNTJOURNAL_FILTER_SOURCE_VOTE = true
				MOUNTJOURNAL_FILTER_SOURCE_BATTLE_BASS = true
				MOUNTJOURNAL_FILTER_SOURCE_BLACK_MARKET = true

				CloseDropDownMenus()
			end,
			hasArrow = false,
			isNotRadio = true,
			notCheckable = true
		},
		{
			text = UNCHECK_ALL,
			func = function(_,_,_,_)
				MOUNTJOURNAL_FILTER_SOURCE_LOOT = false
				MOUNTJOURNAL_FILTER_SOURCE_QUEST = false
				MOUNTJOURNAL_FILTER_SOURCE_VENDOR = false
				MOUNTJOURNAL_FILTER_SOURCE_CRAFT = false
				MOUNTJOURNAL_FILTER_SOURCE_ACHIEVEMENT = false
				MOUNTJOURNAL_FILTER_SOURCE_EVENT = false
				MOUNTJOURNAL_FILTER_SOURCE_STORE = false
				MOUNTJOURNAL_FILTER_SOURCE_VOTE = false
				MOUNTJOURNAL_FILTER_SOURCE_BATTLE_BASS = false
				MOUNTJOURNAL_FILTER_SOURCE_BLACK_MARKET = false

				CloseDropDownMenus()
			end,
			hasArrow = false,
			isNotRadio = true,
			notCheckable = true
		},
		{
			text = COLLECTION_PET_SOURCE_1,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_LOOT"
		},
		{
			text = COLLECTION_PET_SOURCE_2,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_QUEST"
		},
		{
			text = COLLECTION_PET_SOURCE_3,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_VENDOR"
		},
		{
			text = COLLECTION_PET_SOURCE_4,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_CRAFT"
		},
		{
			text = COLLECTION_PET_SOURCE_5,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_ACHIEVEMENT"
		},
		{
			text = COLLECTION_PET_SOURCE_6,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_EVENT"
		},
		{
			text = COLLECTION_PET_SOURCE_7,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_STORE"
		},
		{
			text = COLLECTION_PET_SOURCE_8,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_VOTE"
		},
		{
			text = COLLECTION_PET_SOURCE_9,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_BATTLE_BASS"
		},
		{
			text = COLLECTION_PET_SOURCE_10,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "SOURCE_BLACK_MARKET"
		},
	},
	{
		{
			text = CHECK_ALL,
			func = function(_,_,_,_)
				MOUNTJOURNAL_FILTER_EXPANSION_CLASSIC = true
				MOUNTJOURNAL_FILTER_EXPANSION_BURNING_CRUSADE = true
				MOUNTJOURNAL_FILTER_EXPANSION_LICH_KING = true
				MOUNTJOURNAL_FILTER_EXPANSION_CATACLYSM = true
				MOUNTJOURNAL_FILTER_EXPANSION_MISTS_OF_PANDARIA = true
				MOUNTJOURNAL_FILTER_EXPANSION_WARLORDS_OF_DRAENOR = true
				MOUNTJOURNAL_FILTER_EXPANSION_LEGION = true
				MOUNTJOURNAL_FILTER_EXPANSION_BATTLE_FOR_AZEROTH = true
				MOUNTJOURNAL_FILTER_EXPANSION_SHADOWLANDS = true

				CloseDropDownMenus()
			end,
			hasArrow = false,
			isNotRadio = true,
			notCheckable = true
		},
		{
			text = UNCHECK_ALL,
			func = function(_,_,_,_)
				MOUNTJOURNAL_FILTER_EXPANSION_CLASSIC = false
				MOUNTJOURNAL_FILTER_EXPANSION_BURNING_CRUSADE = false
				MOUNTJOURNAL_FILTER_EXPANSION_LICH_KING = false
				MOUNTJOURNAL_FILTER_EXPANSION_CATACLYSM = false
				MOUNTJOURNAL_FILTER_EXPANSION_MISTS_OF_PANDARIA = false
				MOUNTJOURNAL_FILTER_EXPANSION_WARLORDS_OF_DRAENOR = false
				MOUNTJOURNAL_FILTER_EXPANSION_LEGION = false
				MOUNTJOURNAL_FILTER_EXPANSION_BATTLE_FOR_AZEROTH = false
				MOUNTJOURNAL_FILTER_EXPANSION_SHADOWLANDS = false

				CloseDropDownMenus()
			end,
			hasArrow = false,
			isNotRadio = true,
			notCheckable = true
		},
		{
			text = "World of Warcraft: Classic",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_CLASSIC"
		},
		{
			text = "World of Warcraft: The Burning Crusade",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_BURNING_CRUSADE"
		},
		{
			text = "World of Warcraft: Wrath of Lich King",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_LICH_KING"
		},
		{
			text = "World of Warcraft: Cataclysm",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_CATACLYSM"
		},
		{
			text = "World of Warcraft: Mists of Pandaria",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_MISTS_OF_PANDARIA"
		},
		{
			text = "World of Warcraft: Warlords of Draenor",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_WARLORDS_OF_DRAENOR"
		},
		{
			text = "World of Warcraft: Legion",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_LEGION"
		},
		{
			text = "World of Warcraft: Battle for Azeroth",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_BATTLE_FOR_AZEROTH"
		},
		{
			text = "World of Warcraft: Shadowlands",
			isNotRadio = true,
			notCheckable = false,
			keyValue = "EXPANSION_SHADOWLANDS"
		},
	},
	{
		{
			text = CHECK_ALL,
			func = function(_,_,_,_)
				MOUNTJOURNAL_FILTER_FACTION_ALLIANCE = true
				MOUNTJOURNAL_FILTER_FACTION_HORDE = true
				MOUNTJOURNAL_FILTER_FACTION_NEUTRAL = true
				MOUNTJOURNAL_FILTER_FACTION_RENEGATE = true

				CloseDropDownMenus()
			end,
			hasArrow = false,
			isNotRadio = true,
			notCheckable = true
		},
		{
			text = UNCHECK_ALL,
			func = function(_,_,_,_)
				MOUNTJOURNAL_FILTER_FACTION_ALLIANCE = false
				MOUNTJOURNAL_FILTER_FACTION_HORDE = false
				MOUNTJOURNAL_FILTER_FACTION_NEUTRAL = false
				MOUNTJOURNAL_FILTER_FACTION_RENEGATE = false

				CloseDropDownMenus()
			end,
			hasArrow = false,
			isNotRadio = true,
			notCheckable = true
		},
		{
			text = FACTION_ALLIANCE,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "FACTION_ALLIANCE"
		},
		{
			text = FACTION_HORDE,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "FACTION_HORDE"
		},
		{
			text = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "FACTION_NEUTRAL"
		},
		{
			text = BATTLEGROUND_CROSS_FACTION_2,
			isNotRadio = true,
			notCheckable = false,
			keyValue = "FACTION_RENEGATE"
		},
	}
}

local categoryData = {
	{
		text = MY_COLLECTIONS,
		id = 0,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_01",
		func = function()
			MOUNTJOURNAL_FILTER_RECEIVED = true
		end
	},
	{
		text = FAVORITES,
		id = 0,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_02",
		func = function()
			MOUNTJOURNAL_FILTER_IS_FAVORITE = true
		end
	},
	{
		text = ANIMALS,
		id = 1,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_03",
	},
	{
		sortID = 1,
		hidden = true,
		parent = 1,
		text = TURTLES,
		count = 0
	},
	{
		sortID = 4,
		hidden = true,
		parent = 1,
		text = WOLVES,
		count = 0
	},
	{
		sortID = 5,
		hidden = true,
		parent = 1,
		text = HORSES,
		count = 0
	},
	{
		sortID = 6,
		hidden = true,
		parent = 1,
		text = RAMS,
		count = 0
	},
	{
		sortID = 8,
		hidden = true,
		parent = 1,
		text = PANGOLINS,
		count = 0
	},
	{
		sortID = 9,
		hidden = true,
		parent = 1,
		text = PANTHERS,
		count = 0
	},
	{
		sortID = 10,
		hidden = true,
		parent = 1,
		text = KODO,
		count = 0
	},
	{
		sortID = 11,
		hidden = true,
		parent = 1,
		text = GRIFFINS,
		count = 0
	},
	{
		sortID = 12,
		hidden = true,
		parent = 1,
		text = WYVERNS,
		count = 0
	},
	{
		sortID = 13,
		hidden = true,
		parent = 1,
		text = TIGERS,
		count = 0
	},
	{
		sortID = 15,
		hidden = true,
		parent = 1,
		text = ELEKKI,
		count = 0
	},
	{
		sortID = 16,
		hidden = true,
		parent = 1,
		text = TALBUKS,
		count = 0
	},
	{
		sortID = 17,
		hidden = true,
		parent = 1,
		text = WINGBOOTS,
		count = 0
	},
	{
		sortID = 18,
		hidden = true,
		parent = 1,
		text = BEARS,
		count = 0
	},
	{
		sortID = 19,
		hidden = true,
		parent = 1,
		text = HIPPOGRIFFS,
		count = 0
	},
	{
		sortID = 20,
		hidden = true,
		parent = 1,
		text = MAMMOTHS,
		count = 0
	},
	{
		sortID = 21,
		hidden = true,
		parent = 1,
		text = DRACONDERS,
		count = 0
	},
	{
		sortID = 23,
		hidden = true,
		parent = 1,
		text = YAKI,
		count = 0
	},
	{
		sortID = 24,
		hidden = true,
		parent = 1,
		text = WATER_STRIDERS,
		count = 0
	},
	{
		sortID = 25,
		hidden = true,
		parent = 1,
		text = SCORPIONS,
		count = 0
	},
	{
		sortID = 26,
		hidden = true,
		parent = 1,
		text = CRANES,
		count = 0
	},
	{
		sortID = 27,
		hidden = true,
		parent = 1,
		text = GOATS,
		count = 0
	},
	{
		sortID = 28,
		hidden = true,
		parent = 1,
		text = THE_WILD,
		count = 0
	},
	{
		sortID = 31,
		hidden = true,
		parent = 1,
		text = DEER,
		count = 0
	},
	{
		sortID = 33,
		hidden = true,
		parent = 1,
		text = WINDHORNS,
		count = 0
	},
	{
		sortID = 34,
		hidden = true,
		parent = 1,
		text = SCREAMERS,
		count = 0
	},
	{
		sortID = 35,
		hidden = true,
		parent = 1,
		text = WILD_BOARS,
		count = 0
	},
	{
		sortID = 40,
		hidden = true,
		parent = 1,
		text = TSIILINI,
		count = 0
	},
	{
		sortID = 43,
		hidden = true,
		parent = 1,
		text = BONE_PREDATORS,
		count = 0
	},
	{
		sortID = 44,
		hidden = true,
		parent = 1,
		text = GRONNS,
		count = 0
	},
	{
		sortID = 45,
		hidden = true,
		parent = 1,
		text = YETI,
		count = 0
	},
	{
		sortID = 46,
		hidden = true,
		parent = 1,
		text = FOXES,
		count = 0
	},
	{
		sortID = 47,
		hidden = true,
		parent = 1,
		text = RATS,
		count = 0
	},
	{
		sortID = 48,
		hidden = true,
		parent = 1,
		text = INHABITANTS_OF_THE_DEPTHS,
		count = 0
	},
	{
		sortID = 51,
		hidden = true,
		parent = 1,
		text = LIONS,
		count = 0
	},
	{
		sortID = 52,
		hidden = true,
		parent = 1,
		text = RIVER_MONSTERS,
		count = 0
	},
	{
		sortID = 55,
		hidden = true,
		parent = 1,
		text = UNGULATES,
		count = 0
	},
	{
		sortID = 56,
		hidden = true,
		parent = 1,
		text = MUSHANS,
		count = 0
	},
	{
		sortID = 57,
		hidden = true,
		parent = 1,
		text = SPIDERS,
		count = 0
	},
	{
		text = CREATURES,
		id = 2,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_04",
	},
	{
		sortID = 14,
		hidden = true,
		parent = 2,
		text = INSECTS,
		count = 0
	},
	{
		text = MECHANICAL,
		id = 3,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_05",
	},
	{
		sortID = 7,
		hidden = true,
		parent = 3,
		text = MECHANOSTRIDERS,
		count = 0
	},
	{
		sortID = 36,
		hidden = true,
		parent = 3,
		text = ANNIHILATORS,
		count = 0
	},
	{
		sortID = 37,
		hidden = true,
		parent = 3,
		text = SHREDDERS,
		count = 0
	},
	{
		sortID = 38,
		hidden = true,
		parent = 3,
		text = ROCKETS,
		count = 0
	},
	{
		sortID = 50,
		hidden = true,
		parent = 3,
		text = TRICYCLES,
		count = 0
	},
	{
		sortID = 53,
		hidden = true,
		parent = 3,
		text = MEGACYCLES,
		count = 0
	},
	{
		sortID = 58,
		hidden = true,
		parent = 3,
		text = OTHER,
		count = 0
	},
	{
		text = MAGICAL,
		id = 4,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_06",
	},
	{
		sortID = 2,
		hidden = true,
		parent = 4,
		text = DRAGONS,
		count = 0
	},
	{
		sortID = 3,
		hidden = true,
		parent = 4,
		text = PROTO_DRAGONS,
		count = 0
	},
	{
		sortID = 22,
		hidden = true,
		parent = 4,
		text = CLOUD_SNAKES,
		count = 0
	},
	{
		sortID = 29,
		hidden = true,
		parent = 4,
		text = SLOPES_OF_THE_VOID,
		count = 0
	},
	{
		sortID = 30,
		hidden = true,
		parent = 4,
		text = WINGS_OF_NIGHT,
		count = 0
	},
	{
		sortID = 32,
		hidden = true,
		parent = 4,
		text = PHOENIXES,
		count = 0
	},
	{
		sortID = 39,
		hidden = true,
		parent = 4,
		text = KITES,
		count = 0
	},
	{
		sortID = 41,
		hidden = true,
		parent = 4,
		text = CROWS,
		count = 0
	},
	{
		sortID = 42,
		hidden = true,
		parent = 4,
		text = CARPETS,
		count = 0
	},
	{
		sortID = 49,
		hidden = true,
		parent = 4,
		text = INFERNALS,
		count = 0
	},
	{
		sortID = 54,
		hidden = true,
		parent = 4,
		text = FEL_CATCHERS,
		count = 0
	},
	{
		sortID = 59,
		hidden = true,
		parent = 4,
		text = OTHER,
		count = 0
	},
	{
		text = ALL_MOUNTS,
		id = 0,
		parent = nil,
		collapsed = false,
		isCategory = true,
		icon = "Interface\\ICONS\\INV_Misc_SkullRed_07",
		func = function() end
	},
}

local CastSpellByID = CastSpellByID

SIRUS_MOUNTJOURNAL_FAVORITE_PET = {}
SIRUS_MOUNTJOURNAL_PRODUCT_DATA = {}

local MOUNTJOURNAL_MOUNT_DATA_BY_HASH = {}
local MOUNTJOURNAL_MOUNT_SEARCH_DATA = {}
local MOUNTJOURNAL_MASTER_DATA = {}

STORE_PRODUCT_MONEY_ICON = {"coins", "mmotop", "refer", "loyal"}

local totalMounts
local subCategoryFilter
local mountDataBuffer = {}
local displayCategories = {}

local FilterData = {
	"MOUNTJOURNAL_FILTER_RECEIVED",
	"MOUNTJOURNAL_FILTER_NO_RECEIVED",
	"MOUNTJOURNAL_FILTER_IS_GROUND",
	"MOUNTJOURNAL_FILTER_IS_FLY",
	"MOUNTJOURNAL_FILTER_IS_WATER",

	"MOUNTJOURNAL_FILTER_SOURCE_LOOT",
	"MOUNTJOURNAL_FILTER_SOURCE_QUEST",
	"MOUNTJOURNAL_FILTER_SOURCE_VENDOR",
	"MOUNTJOURNAL_FILTER_SOURCE_CRAFT",
	"MOUNTJOURNAL_FILTER_SOURCE_ACHIEVEMENT",
	"MOUNTJOURNAL_FILTER_SOURCE_EVENT",
	"MOUNTJOURNAL_FILTER_SOURCE_STORE",
	"MOUNTJOURNAL_FILTER_SOURCE_VOTE",
	"MOUNTJOURNAL_FILTER_SOURCE_BATTLE_BASS",
	"MOUNTJOURNAL_FILTER_SOURCE_BLACK_MARKET",

	"MOUNTJOURNAL_FILTER_EXPANSION_CLASSIC",
	"MOUNTJOURNAL_FILTER_EXPANSION_BURNING_CRUSADE",
	"MOUNTJOURNAL_FILTER_EXPANSION_LICH_KING",
	"MOUNTJOURNAL_FILTER_EXPANSION_CATACLYSM",
	"MOUNTJOURNAL_FILTER_EXPANSION_MISTS_OF_PANDARIA",
	"MOUNTJOURNAL_FILTER_EXPANSION_WARLORDS_OF_DRAENOR",
	"MOUNTJOURNAL_FILTER_EXPANSION_LEGION",
	"MOUNTJOURNAL_FILTER_EXPANSION_BATTLE_FOR_AZEROTH",
	"MOUNTJOURNAL_FILTER_EXPANSION_SHADOWLANDS",

	"MOUNTJOURNAL_FILTER_FACTION_ALLIANCE",
	"MOUNTJOURNAL_FILTER_FACTION_HORDE",
	"MOUNTJOURNAL_FILTER_FACTION_NEUTRAL",
	"MOUNTJOURNAL_FILTER_FACTION_RENEGATE",

	"MOUNTJOURNAL_FILTER_IS_FAVORITE",
}

local function keyConcat( a, b )
	return tostring(a) .. tostring(b)
end

function MountJournal_ResetVar()
	for i = 1, #FilterData do
		_G[FilterData[i]] = false
	end

	subCategoryFilter = nil
end

function MountJournal_OnLoad( self, ... )
	MountJournal_ResetVar()
	totalMounts = #COLLECTION_MOUNTDATA

	local homeData = {
		name = CATEGORYES,
		OnClick = function()
			MountJournal.selectCategoryID = nil
			MountJournal_ResetVar()
			if self.ListScrollFrame:IsShown() then
				self.ListScrollFrame:Hide()
				self.CategoryScrollFrame:Show()
			end
			MountJournal_UpdateCollectionList()
			NavBar_Reset(MountJournal.navBar)
		end,
	}

	self.navBar.home:SetText(CATEGORYES)
	NavBar_ReconsultationSize(self.navBar.home)
	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow)

	self.ListScrollFrame.update = MountJournal_UpdateMountList
	self.ListScrollFrame.scrollBar.doNotHide = true
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "MountListButtonTemplate", 44, 0)

	self.CategoryScrollFrame.update = MountJournal_UpdateCollectionList
	self.CategoryScrollFrame.scrollBar.doNotHide = true
	HybridScrollFrame_CreateButtons(self.CategoryScrollFrame, "CategoryListButtonTemplate", 0, 0, "TOP", "TOP", 0, 0, "TOP", "BOTTOM")

	self:RegisterEvent("COMPANION_LEARNED")
	self:RegisterEvent("COMPANION_UNLEARNED")
	self:RegisterEvent("COMPANION_UPDATE")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_TALENT_UPDATE");

	UIDropDownMenu_Initialize(self.mountOptionsMenu, MountOptionsMenu_Init, "MENU")
end

function MountJournal_OnEvent( self, event, arg1, ... )
	if event == "PLAYER_LOGIN" then
		MountJournal_CreateData()
	elseif event == "COMPANION_UPDATE" and arg1 == "MOUNT" or event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" then
		mountDataBuffer = {}

		for i = 1, GetNumCompanions("MOUNT") do
			local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i)
			mountDataBuffer[keyConcat(creatureID, spellID)] = {creatureID = creatureID, creatureName = creatureName, spellID = spellID, icon = icon, active = active, mountIndex = i}
		end

		if event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" then
			MountJournal_CreateData()
		end

		if self:IsVisible() then
			MountJournal_UpdateFilter(true)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:RegisterEvent("COMMENTATOR_ENTER_WORLD");
		self:UnregisterEvent(event);
	elseif event == "COMMENTATOR_ENTER_WORLD" then
		table.wipe(SIRUS_MOUNTJOURNAL_FAVORITE_PET);
		self:UnregisterEvent(event);
	elseif event == "PLAYER_TALENT_UPDATE" then
		self:UnregisterEvent("COMMENTATOR_ENTER_WORLD");
		self:UnregisterEvent(event);
	end
end

function MountJournal_UpdateCollectionList()
	local scrollFrame = MountJournal.CategoryScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	local categories = categoryData
	local element

	for i in next, displayCategories do
		displayCategories[i] = nil
	end

	local selection = MountJournal.selectCategoryID
	local parent

	if selection then
		for _, category in next, categories do
			if category.id then
				if category.id == selection then
					if parent ~= category.id and MountJournal.CategoryScrollFrame:IsShown() then
						NavBar_Reset(MountJournal.navBar)
						-- print("NavBar_Reset category")
						local buttonData = {
							id = category.id,
							name = category.text,
							OnClick = function(self)
								MountJournal.selectCategoryID = self.id
								if MountJournal.ListScrollFrame:IsShown() then
									MountJournal.ListScrollFrame:Hide()
									MountJournal.CategoryScrollFrame:Show()
								end
								NavBar_Reset(MountJournal.navBar)
								MountJournal_UpdateCollectionList()
							end
						}
						NavBar_AddButton(MountJournal.navBar, buttonData)
					end
					parent = category.id
				end
			end
		end
	else
		if MountJournal.CategoryScrollFrame:IsShown() then
			NavBar_Reset(MountJournal.navBar)
			-- print("NavBar_Reset")
		end
	end

	for _, category in next, categories do
		if not category.hidden then
			table.insert(displayCategories, category)
		elseif parent and category.parent == parent then
			category.collapsed = false
			table.insert(displayCategories, category)
		elseif parent and category.parent and category.parent == parent then
			category.hidden = false
			table.insert(displayCategories, category)
		end
	end

	local numCategories = #displayCategories
	local numButtons = #buttons

	local totalHeight = numCategories * buttons[1]:GetHeight()
	local displayedHeight = 0

	for i = 1, numButtons do
		element = displayCategories[i + offset]
		displayedHeight = displayedHeight + buttons[i]:GetHeight()

		if element then
			MountJournal_CategoryDisplayButton( buttons[i], element )
			if not element.func and selection and element.id == selection then
				buttons[i]:LockHighlight()
				buttons[i]:GetHighlightTexture():SetAlpha(0.7)
			else
				buttons[i]:UnlockHighlight()
				buttons[i]:GetHighlightTexture():SetAlpha(0.3)
			end

			buttons[i]:Show()
		else
			buttons[i].element = nil
			buttons[i]:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

	return displayCategories
end

function ListScrollFrame_OnShow( _, ... )
	if not subCategoryFilter and not MountJournal_CanUseFilter() then
		MountJournal_FilterToggle(true)
	end
	MountJournal.LeftInset.Bgs:SetVertexColor(1, 1, 1, 1)
end

function MountJournal_CanUseFilter()
	local canUseFilter = false

	for i = 1, #FilterData do
		if _G[FilterData[i]] then
			canUseFilter = true
			break
		end
	end

	return canUseFilter
end

function CategoryScrollFrame_OnShow( _, ... )
	MountJournal_FilterToggle(false)
	MountJournal_ResetVar()
	MountJournal.LeftInset.Bgs:SetVertexColor(1, 0, 0, 0.9)
end

function MountJournal_FilterToggle( value )
	if value then
		MountJournal.FilterButton:Enable()
		MountJournal.searchBox:EnableMouse(1)
	else
		MountJournal.FilterButton:Disable()
		MountJournal.searchBox:SetText("")
		MountJournal.searchBox:ClearFocus()
		MountJournal.searchBox:EnableMouse(0)
	end
end

function MountJournal_CategoryDisplayButton( button, element )
	if ( not element ) then
		button.element = nil
		button:Hide()
		return
	end

	button.Background:SetVertexColor(0.8, 0.8, 0.8)

	if element.icon then
		button.Icon:SetTexture(element.icon)
	end

	if element.isCategory then
		-- button:SetWidth(250)
		button:SetSize(262, 62)
		button.Background:SetSize(262, 62)
		button:GetHighlightTexture():SetSize(262, 62)

		button.Background:SetTexCoord(0.00195313, 0.60742188, 0.00390625, 0.28515625)
		button:GetHighlightTexture():SetTexCoord(0.00195313, 0.60742188, 0.00390625, 0.28515625)

		button.categoryName:SetPoint("CENTER", 24, 0)
		button.categoryName:SetJustifyH("LEFT")
	else
		button:SetSize(230, 62)
		button.Background:SetSize(230, 62)
		button:GetHighlightTexture():SetSize(230, 62)

		button.Background:SetTexCoord(0, 0.53125, 0.76171875, 1)
		button:GetHighlightTexture():SetTexCoord(0, 0.53125, 0.76171875, 1)

		button.categoryName:SetPoint("CENTER", 0, 1)
		button.categoryName:SetJustifyH("LEFT")
	end

	button.categoryName:SetText(element.text)

	button.element = element

	button:Show()
end

function CategoryListButton_OnEnter( _, ... )
	-- body
end

function CategoryListButton_OnLeave( _, ... )
	-- body
end

function CategoryListButton_OnClick( button, ... )
	Categorylist_SelectButton( button )
	MountJournal_UpdateCollectionList()
end

function Categorylist_SelectButton( button )
	local id = button.element.id
	local data = button.element

	if data.func then
		MountJournal.selectCategoryID = nil
		MountJournal_ResetVar()
		data.func()

		MountJournal.ListScrollFrame:Show()
		MountJournal.CategoryScrollFrame:Hide()
		MountJournal_UpdateFilter()
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)

		NavBar_Reset(MountJournal.navBar)
		local buttonData = {
			name = data.text
		}
		NavBar_AddButton(MountJournal.navBar, buttonData)
		return
	end

	if data.sortID then
		subCategoryFilter = data.sortID

		local buttonData = {
			name = data.text
		}
		NavBar_AddButton(MountJournal.navBar, buttonData)
		-- print("NavBar_AddButton")

		MountJournal.ListScrollFrame:Show()
		MountJournal.CategoryScrollFrame:Hide()
		MountJournal_UpdateFilter()
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
	end

	if not data.isCategory then
		return
	end

	if MountJournal.selectCategoryID == id then
		MountJournal.selectCategoryID = nil
		return
	end

	MountJournal.selectCategoryID = id
end

function MountJournal_OnShow( self, ... )
	SetPortraitToTexture(CollectionsJournalPortrait, "Interface\\Icons\\MountJournalPortrait");

	RaiseFrameLevelByThree(self.searchBox)
	RaiseFrameLevelByThree(self.FilterButton)
	RaiseFrameLevelByThree(self.MountDisplay)
	RaiseFrameLevelByThree(self.MountCount)

	self.selectCategoryID = nil
	self.IsOpenStore = nil

	if CollectionsJournal.resetPositionTimer then
		CollectionsJournal.resetPositionTimer:Cancel()
		CollectionsJournal.resetPositionTimer = nil
	end

	for i = 1, 7 do
		local button = _G["MountJournalButtomFrameMountButtonColor"..i]
		button:Hide()
	end

	MountJournal.bottomFrame:SetShown(false)
	MountJournal.RightBottomInset:SetShown(false)

	for _, v in pairs(SIRUS_MOUNTJOURNAL_FAVORITE_PET) do
		if MOUNTJOURNAL_MOUNT_DATA_BY_HASH and MOUNTJOURNAL_MOUNT_DATA_BY_HASH[v] then
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[v].isFavorite = true
		end
	end

	for i = 1, #SIRUS_MOUNTJOURNAL_PRODUCT_DATA do
		local data = SIRUS_MOUNTJOURNAL_PRODUCT_DATA[i]
		if data and data.hash and MOUNTJOURNAL_MOUNT_DATA_BY_HASH and MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash] then
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].currency = tonumber(data.currency)
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].price = tonumber(data.price)
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].productID = tonumber(data.productID)
		end
	end

	MountJournal_CreateData()
	MountJournal_UpdateFilter(true)
end

function MountJournal_OnHide( self, ... )
	if not self.IsOpenStore then
		if CollectionsJournal.resetPositionTimer then
			CollectionsJournal.resetPositionTimer:Cancel()
			CollectionsJournal.resetPositionTimer = nil
		end

		CollectionsJournal.resetPositionTimer = C_Timer:After(5, function()
			-- print("Reset OnHide timer")
			MountJournal.selectCategoryID = nil
			MountJournal.searchBox:SetText("")
			MountJournal_ResetVar()
			MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
			MountJournal_UpdateFilter()
			MountJournal_Select(1)

			if CollectionsJournal.resetPositionTimer then
				CollectionsJournal.resetPositionTimer:Cancel()
				CollectionsJournal.resetPositionTimer = nil
			end
		end)
	end
end

function MountJournal_OnSearchTextChanged( self, ... )
	-- print("MountJournal_OnSearchTextChanged")
	SearchBoxTemplate_OnTextChanged( self )
	MountJournal_UpdateFilter()

	if not MountJournal.selectedItemID then
		MountJournal_Select(1)
	end
end

function MountJournal_CheckFilter( data )
	local countFiltre = 0

	if MOUNTJOURNAL_FILTER_RECEIVED then
		countFiltre = countFiltre + 1
		if data.mountIndex then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_NO_RECEIVED then
		countFiltre = countFiltre + 1
		if not data.mountIndex then
			return true
		end
	end

	local inhabitFilterData = {"MOUNTJOURNAL_FILTER_IS_GROUND", "MOUNTJOURNAL_FILTER_IS_FLY", "MOUNTJOURNAL_FILTER_IS_WATER"}
	local inhabitFilterMask = 0

	for i = 1, #inhabitFilterData do
		local _data = _G[inhabitFilterData[i]]

		if _data then
			inhabitFilterMask = bit.bor(inhabitFilterMask, _data)
		end
	end

	if inhabitFilterMask ~= 0 then
		countFiltre = countFiltre + 1
		if bit.band(inhabitFilterMask, data.inhabitType) ~= 0 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_LOOT then
		countFiltre = countFiltre + 1
		if data.lootType == 1 or data.lootType == 2 or data.lootType == 3 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_QUEST then
		countFiltre = countFiltre + 1
		if data.lootType == 8 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_VENDOR then
		countFiltre = countFiltre + 1
		if data.lootType == 6 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_CRAFT then
		countFiltre = countFiltre + 1
		if data.lootType == 9 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_ACHIEVEMENT then
		countFiltre = countFiltre + 1
		if data.lootType == 7 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_EVENT then
		countFiltre = countFiltre + 1
		if data.lootType == 70 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_STORE then
		countFiltre = countFiltre + 1
		if data.currency ~= 0 or data.lootType == 10 or data.lootType == 11 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_VOTE then
		countFiltre = countFiltre + 1
		if data.lootType == 15 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_BATTLE_BASS then
		countFiltre = countFiltre + 1
		if data.lootType == 16 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_SOURCE_BLACK_MARKET then
		countFiltre = countFiltre + 1
		if data.lootType == 17 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_CLASSIC then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_CLASSIC then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_BURNING_CRUSADE then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_BURNING_CRUSADE then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_LICH_KING then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_CATACLYSM then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_CATACLYSM then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_MISTS_OF_PANDARIA then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_MISTS_OF_PANDARIA then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_WARLORDS_OF_DRAENOR then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_WARLORDS_OF_DRAENOR then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_LEGION then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_LEGION then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_BATTLE_FOR_AZEROTH then
		countFiltre = countFiltre + 1
		if data.expansion == LE_EXPANSION_BATTLE_FOR_AZEROTH then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_EXPANSION_SHADOWLANDS then
		countFiltre = countFiltre + 1
		if data.expansion == 256 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_FACTION_ALLIANCE then
		countFiltre = countFiltre + 1
		if data.factionSide == 1 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_FACTION_HORDE then
		countFiltre = countFiltre + 1
		if data.factionSide == 2 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_FACTION_NEUTRAL then
		countFiltre = countFiltre + 1
		if data.factionSide == 0 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_FACTION_RENEGATE then
		countFiltre = countFiltre + 1
		if data.factionSide == 4 then
			return true
		end
	end

	if MOUNTJOURNAL_FILTER_IS_FAVORITE then
		countFiltre = countFiltre + 1
		if data.isFavorite then
			return true
		end
	end

	if subCategoryFilter then
		countFiltre = countFiltre + 1
		if subCategoryFilter == data.subCategoryID then
			return true
		end
	end

	if countFiltre == 0 then
		NavBar_Reset(MountJournal.navBar)
		local buttonData = {
			name = ALL_MOUNTS
		}
		NavBar_AddButton(MountJournal.navBar, buttonData)
		return true
	end

	return false
end

function MountJournal_UpdateScrollPos(self, visibleIndex)
	local buttons = self.buttons
	local height = math.max(0, math.floor(self.buttonHeight * (visibleIndex - (#buttons)/2)))
	HybridScrollFrame_SetOffset(self, height)
	self.scrollBar:SetValue(height)
end

local realmFilterData = {
	[E_REALM_ID.FROSTMOURNE] = 1,
	[E_REALM_ID.SCOURGE] = 2,
	[E_REALM_ID.NELTHARION] = 4,
	[E_REALM_ID.SIRUS] = 8,
}

function MountJournal_CreateData()
	local defaultMountData = {}

	MOUNTJOURNAL_MOUNT_DATA_BY_HASH = {}
	MOUNTJOURNAL_MOUNT_SEARCH_DATA = {}

	for i = 1, GetNumCompanions("MOUNT") do
		local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i)
		if creatureID then
			defaultMountData[keyConcat(creatureID, spellID)] = {creatureID = creatureID, creatureName = creatureName, spellID = spellID, icon = icon, active = active, mountIndex = i}
		end
	end

	for i = 1, #COLLECTION_MOUNTDATA do
		local data = COLLECTION_MOUNTDATA[i]

		if data then
			if data.flags and data.flags ~= 0 then
				local realmFlag = realmFilterData[C_Service:GetRealmID()]

				if realmFlag then
					if bit.band(data.flags, realmFlag) == data.flags then
						table.remove(COLLECTION_MOUNTDATA, i)
					end
				end
			end

			if not data.spellName then
				local spellName,_ , texture,_ ,_ ,_ ,_ ,_ ,_ = GetSpellInfo(data.spellID)

				data.spellName                               = spellName
				data.spellTexture                            = texture
			end

			if not data.mountIndex then
				local defaultData = defaultMountData[keyConcat(data.creatureID, data.spellID)]

				if defaultData then
					data.mountActive = defaultData.active
					data.mountIndex = defaultData.mountIndex
				end
			end
		end
	end

	MountJournal_UpdateSort()
	MountJournal_GenerateSearchData()
end

function MountJournal_GenerateSearchData()
	for i = 1, #COLLECTION_MOUNTDATA do
		local data = COLLECTION_MOUNTDATA[i]

		if data then
			table.insert(MOUNTJOURNAL_MOUNT_SEARCH_DATA, {name = string.upper( data.spellName or UNKNOWN ), hash = data.hash, creatureID = data.creatureID, spellID = data.spellID})
			MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash] = data
		end
	end
end

function MountJournal_UpdateFilter(doNotUpdateScroll)
	local text = string.upper( MountJournal.searchBox:GetText() )
	local textCount = MountJournal.searchBox:GetNumLetters()
	local sourceData = MOUNTJOURNAL_MOUNT_SEARCH_DATA
	text = textCount > 1 and text or ""

	MOUNTJOURNAL_MASTER_DATA = {}

	for i = 1, #sourceData do
		local data = sourceData[i]
		if string.find( data.name, text, 1, true ) then
			if MountJournal_CheckFilter( MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash] ) then
				if mountDataBuffer[keyConcat(data.creatureID, data.spellID)] then
					local mountData = mountDataBuffer[keyConcat(data.creatureID, data.spellID)]
					MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].mountIndex = mountData.mountIndex
					MOUNTJOURNAL_MOUNT_DATA_BY_HASH[data.hash].mountActive = mountData.active
				end

				table.insert(MOUNTJOURNAL_MASTER_DATA, data)
			end
		end
	end

	-- print("MountJournal_UpdateFilter")
	if textCount > 1 and not doNotUpdateScroll then
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
	end

	MountJournal_UpdateMountList()
end

function MountJournal_UpdateSort()
	table.sort(COLLECTION_MOUNTDATA, function(a, b)
		if a.mountIndex and not b.mountIndex then
			return true
		end
		if not a.mountIndex and b.mountIndex then
			return false
		end
		if a.mountIndex and b.mountIndex then
			if a.isFavorite and not b.isFavorite then
				return true
			end
			if not a.isFavorite and b.isFavorite then
				return false
			end
		end

		if a.spellName and b.spellName then
			return a.spellName < b.spellName
		end
	end)
end

function MountJournal_ClearSearch( _, ... )
	-- body
end

function MountJournal_UpdateDefaultMountList()
	local creatureData = {}
	local activeData = {}

	for i = 1, GetNumCompanions("MOUNT") do
		local creatureID,_ ,_ ,_ , active = GetCompanionInfo("MOUNT", i)
		if creatureID then
			table.insert(creatureData, creatureID)
		end
		if active then
			table.insert(activeData, creatureID)
		end
	end

	return creatureData, activeData
end

function MountJournal_UpdateMountList()
	local scrollFrame = MountJournalListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	local showMounts = true
	local numMounts = #MOUNTJOURNAL_MASTER_DATA

	MountJournal.numOwned = 0

	MountJournal.MountDisplay.NoMounts:SetShown(numMounts < 1)
	MountJournal.MountDisplay.NoMountsTex:SetShown(numMounts < 1)

	if numMounts > 0 then
		MountJournal.MountDisplay.ModelScene:Show()
	else
		MountJournal.MountDisplay.ModelScene:Hide()
	end
	MountJournal.MountDisplay.ModelScene.InfoButton:SetShown(numMounts > 0)
	MountJournal.MountDisplay.YesMountsTex:SetShown(numMounts > 0)

	showMounts = numMounts < 1 and 0 or 1

	for i = 1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset

		if displayIndex <= numMounts and showMounts == 1 and MOUNTJOURNAL_MASTER_DATA[displayIndex] then
			local data = MOUNTJOURNAL_MOUNT_DATA_BY_HASH[MOUNTJOURNAL_MASTER_DATA[displayIndex].hash]
			local index = displayIndex

			button.index = index
			button.hash = data.hash
			button.spellID = data.spellID
			button.creatureID = data.creatureID
			button.itemID = data.itemID
			button.mountIndex = nil
			button.data = data

			button.name:SetText(data.spellName)
			button.icon:SetTexture(data.spellTexture)

			button.DragButton.ActiveTexture:SetShown(data.mountActive)
			button:Show()

			if MountJournal.selectedItemID == data.itemID then
				button.selected = true
				button.selectedTexture:Show()
			else
				button.selected = false
				button.selectedTexture:Hide()
			end

			button:SetEnabled(true)
			button.unusable:Hide()
			button.iconBorder:Hide()
			button.background:SetVertexColor(1, 1, 1, 1)

			if data.mountIndex then
				button.mountIndex = data.mountIndex

				button.additionalText = nil
				button.icon:SetDesaturated(false)
				button.icon:SetAlpha(1.0)
				button.name:SetFontObject("GameFontNormal")
			else
				button.icon:SetDesaturated(true)
				button.icon:SetAlpha(0.25)
				button.additionalText = nil
				button.name:SetFontObject("GameFontDisable")
			end

			button.favorite:SetShown(data.isFavorite)
			button.MountJournalIcons_Horde:SetShown(data.factionSide and data.factionSide == 2)
			button.MountJournalIcons_Alliance:SetShown(data.factionSide and data.factionSide == 1)

			if ( button.showingTooltip ) then
				MountJournalMountButton_UpdateTooltip(button)
			end

		else
			button.name:SetText("")
			button.icon:SetTexture("Interface\\PetBattles\\MountJournalEmptyIcon")
			button.index = nil
			button.spellID = 0
			button.itemID = nil
			button.selected = false
			button.unusable:Hide()
			button.DragButton.ActiveTexture:Hide()
			button.selectedTexture:Hide()
			button:SetEnabled(false)
			button.DragButton:SetEnabled(false)
			button.icon:SetDesaturated(true)
			button.icon:SetAlpha(0.5)
			button.favorite:Hide()
			button.MountJournalIcons_Horde:Hide()
			button.MountJournalIcons_Alliance:Hide()
			button.background:SetVertexColor(1, 1, 1, 1)
			button.iconBorder:Hide()
		end
	end

	local totalHeight = numMounts * 46
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
	MountJournal.MountCount.Count:SetText(string.format("%d / %d", GetNumCompanions("MOUNT"), totalMounts))
	if ( not showMounts ) then
		MountJournal.selectedItemID = nil
		MountJournal.selectedMountID = nil
	end
end

function MountListDragButton_OnClick( self, button, ... )
	local parent = self:GetParent()
	local spellID = parent.spellID;
	local itemID = parent.itemID;

	if ( button ~= "LeftButton" ) then
		if parent.mountIndex then
			MountJournal_ShowMountDropdown(parent.mountIndex, self, 0, 0)
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(spellID)
			ChatEdit_InsertLink(spellName)
		elseif itemID then
			ChatEdit_InsertLink(string.format(COLLECTION_MOUNTS_HYPERLINK_FORMAT, itemID, GetSpellInfo(spellID) or ""));
		end
	else
		if parent.mountIndex then
			PickupCompanion( "MOUNT", parent.mountIndex )
		end
	end
end

function MountJournal_ShowMountDropdown( index, anchorTo, offsetX, offsetY )
	if not index then
		return
	end

	MountJournal.menuMountID = anchorTo.creatureID
	MountJournal.menuData = anchorTo.data

	ToggleDropDownMenu(1, nil, MountJournal.mountOptionsMenu, anchorTo, offsetX, offsetY)
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function MountOptionsMenu_Init(_ ,level, ... )
	if not MountJournal.menuData then
		return
	end

	local info = UIDropDownMenu_CreateInfo()
	local data = MountJournal.menuData

	info.notCheckable = true
	info.text = data.mountActive and BINDING_NAME_DISMOUNT or MOUNT
	info.func = function()
		if data.mountIndex then
			if data.mountActive then
				DismissCompanion("MOUNT")
			else
				CallCompanion("MOUNT", data.mountIndex)
			end
		end
	end
	UIDropDownMenu_AddButton(info, level)

	if data.mountIndex then
		if data.isFavorite then
			info.text = DELETE_FAVORITE
			info.func = function() SendAddonMessage("ACMSG_C_M_REMOVE_FROM_FAVORITES", data.hash, "WHISPER", UnitName("player")) end
		else
			info.text = COMMUNITIES_LIST_DROP_DOWN_FAVORITE
			info.func = function() SendAddonMessage("ACMSG_C_M_ADD_TO_FAVORITES", data.hash, "WHISPER", UnitName("player")) end
		end
		UIDropDownMenu_AddButton(info, level)
	end

	info.text = CANCEL
	info.func = nil
	UIDropDownMenu_AddButton(info, level)
end

function MountJournalMountButton_UpdateTooltip( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink("spell:"..self.spellID)
	GameTooltip:Show()
end

function MountListItem_OnClick( self, button, ... )
	if ( button ~= "LeftButton" ) then
		if self.mountIndex then
			MountJournal_ShowMountDropdown(self.mountIndex, self, 0, 0)
		end
	elseif ( IsModifiedClick("CHATLINK") ) then
		local spellID = self.spellID;
		local itemID = self.itemID;

		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(spellID)
			ChatEdit_InsertLink(spellName)
		elseif itemID then
			ChatEdit_InsertLink(string.format(COLLECTION_MOUNTS_HYPERLINK_FORMAT, itemID, GetSpellInfo(spellID) or ""));
		end
	elseif ( self.spellID ~= MountJournal.selectedItemID ) then
		MountJournal_Select(self.index)
		MountJournal.searchBox:ClearFocus()
	end
end

function MountListItem_OnDoubleClick( self, button, ... )
	if self.mountIndex and button == "LeftButton" then
		if self.data.mountActive then
			DismissCompanion("MOUNT")
		else
			CallCompanion("MOUNT", self.mountIndex)
		end
	end
end

function MountJournal_UpdateMountDisplay()
	local data = MountJournal.data

	MountJournal.bottomFrame:SetShown(#data.colorData > 0)
	MountJournal.RightBottomInset:SetShown(#data.colorData > 0)

	if IsGMAccount() then
		MountJournal.MountDisplay.ModelScene.DebugInfo:SetFormattedText("CreatureID: %s", data.creatureID);
		MountJournal.MountDisplay.ModelScene.DebugInfo:Show();
	else
		MountJournal.MountDisplay.ModelScene.DebugInfo:Hide();
	end
	MountJournal.MountDisplay.ModelScene.DebugFrame:SetShown(IsGMAccount());

	MountJournal.MountDisplay.ModelScene.creatureID = data.creatureID

	local insetPointY = #data.colorData > 0 and 80 or 0
	MountJournal.RightTopInset:ClearAllPoints()
	MountJournal.RightTopInset:SetPoint("TOPRIGHT", -6, -60)
	MountJournal.RightTopInset:SetPoint("BOTTOMLEFT", MountJournal.LeftInset, "BOTTOMRIGHT", 20, insetPointY)

	if data.factionSide == 1 then
		data.priceText = data.priceText:gsub("-Team.", "-Alliance.")
	elseif data.factionSide == 2 then
		data.priceText = data.priceText:gsub("-Team.", "-Horde.")
	else
		local faction = UnitFactionGroup("player")
		data.priceText = data.priceText:gsub("-Team.", "-"..faction..".")
	end

	MountJournal.MountDisplay.ModelScene.InfoButton.Icon:SetTexture(data.spellTexture)
	MountJournal.MountDisplay.ModelScene.InfoButton.Name:SetText(data.spellName)
	MountJournal.MountDisplay.ModelScene.InfoButton.Source:SetText(data.priceText)
	MountJournal.MountDisplay.ModelScene.InfoButton.Lore:SetText(data.descriptionText)

	MountJournal.MountDisplay.ModelScene:Hide()
	MountJournal.MountDisplay.ModelScene:Show()

	if data.lootType == 16 then
		MountJournal.MountDisplay.ModelScene.buyFrame:SetShown(BattlePassFrame:GetEndTime() ~= 0 and not data.mountIndex)
		MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(GO_TO_BATTLE_BASS)
		MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetEnabled(true)
		MountJournal.MountDisplay.ModelScene.buyFrame.priceText:SetText("")
		MountJournal.MountDisplay.ModelScene.buyFrame.MoneyIcon:SetTexture("")
	elseif data.currency and data.currency ~= 0 then
		MountJournal.MountDisplay.ModelScene.buyFrame:SetShown(not data.mountIndex)

		if data.currency == 4 then
			MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(PICK_UP)
		else
			MountJournal.MountDisplay.ModelScene.buyFrame.buyButton:SetText(GO_TO_STORE)
		end

		MountJournal.MountDisplay.ModelScene.buyFrame.MoneyIcon:SetTexture("Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[data.currency])
		MountJournal.MountDisplay.ModelScene.buyFrame.priceText:SetText(data.price)
	else
		MountJournal.MountDisplay.ModelScene.buyFrame:Hide()
	end

	if data.itemID then
		local canOpened = LootJournal_CanOpenItemByEntry(data.itemID, true)

		MountJournal.MountDisplay.ModelScene.EJFrame.OpenEJButton.itemID = data.itemID
		MountJournal.MountDisplay.ModelScene.EJFrame:SetShown(canOpened)
	else
		MountJournal.MountDisplay.ModelScene.EJFrame:Hide()
	end

	MountJournal.MountButton:SetEnabled(data.mountIndex)

	MountJournal_UpdateFavoriteData()
end

function MountJournal_UpdateFavoriteData()
	local data = MountJournal.data
	if data then
		MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetShown(data.mountIndex)

		if data.isFavorite then
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetChecked(true)
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton.isFavorite = true
		else
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton:SetChecked(false)
			MountJournal.MountDisplay.ModelScene.InfoButton.favoriteButton.isFavorite = false
		end
	end
end

function FavoriteButton_OnClick(_ , ... )
	local data = MountJournal.data

	if data.isFavorite then
		SendAddonMessage("ACMSG_C_M_REMOVE_FROM_FAVORITES", data.hash, "WHISPER", UnitName("player"))
	else
		SendAddonMessage("ACMSG_C_M_ADD_TO_FAVORITES", data.hash, "WHISPER", UnitName("player"))
	end
end

function MountJournalMountButton_OnClick(_ , ... )
	local data = MountJournal.data

	if data.mountIndex then
		if data.mountActive then
			DismissCompanion("MOUNT")
		else
			CallCompanion("MOUNT", data.mountIndex)
		end
	end
end

function MountJournalBuyButton_OnClick(_ , ... )
	MountJournal.IsOpenStore = true

	HideUIPanel(CollectionsJournal)
	-- ShowUIPanel(StoreFrame)

	if CollectionsJournal.resetPositionTimer then
		CollectionsJournal.resetPositionTimer:Cancel()
		CollectionsJournal.resetPositionTimer = nil
	end

	CollectionsJournal.resetPositionTimer = C_Timer:After(30, function()
		-- print("Reset open store")
		MountJournal.selectCategoryID = nil
		MountJournal.searchBox:SetText("")
		MountJournal_ResetVar()
		MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
		MountJournal_UpdateFilter()
		MountJournal_Select(1)

		MountJournal.IsOpenStore = false
		if CollectionsJournal.resetPositionTimer then
			CollectionsJournal.resetPositionTimer:Cancel()
			CollectionsJournal.resetPositionTimer = nil
		end
	end)

	local data = MountJournal.data

	if data.lootType == 16 then
		BattlePassFrame:Show()
	else
		local productData = {
			Texture = data.spellTexture,
			Name = data.spellName,
			Price = data.price,
			ID = data.productID,
			currency = data.currency
		}

		-- _G["StoreMoneyButton"..data.currency]:Click()

		-- StoreFrame_ProductBuy(productData)

		StoreFrame_ProductBuyWithOpenPage(productData)
	end
end

function MountJournal_Select( index )
	if MOUNTJOURNAL_MASTER_DATA[index] and MOUNTJOURNAL_MOUNT_DATA_BY_HASH[MOUNTJOURNAL_MASTER_DATA[index].hash] then
		local data = MOUNTJOURNAL_MOUNT_DATA_BY_HASH[MOUNTJOURNAL_MASTER_DATA[index].hash]
		if MountJournal.selectedItemID ~= data.itemID then
			MountJournal.selectedItemID = data.itemID
			MountJournal.selectedMountID = data.creatureID
			MountJournal.data = data
			MountJournal_HideMountDropdown()
			MountJournal_UpdateMountList()
			MountJournal_UpdateMountDisplay()
		end
	end
end

function MountJournal_HideMountDropdown()
	if UIDropDownMenu_GetCurrentDropDown() == MountJournal.mountOptionsMenu then
		HideDropDownMenu(1)
	end
end

function MountJournalSummonRandomFavoriteButton_OnLoad( self, ... )
	self.spellID           = 305495
	local _ ,_ , spellIcon = GetSpellInfo(self.spellID)
	self.texture:SetTexture(spellIcon)
	self:RegisterForDrag("LeftButton")
end

function MountJournalSummonRandomFavoriteButton_OnClick(self,_ , ... )
	CastSpellByID(self.spellID)
end

function MountJournalSummonRandomFavoriteButton_OnDragStart( self, ... )
	local spellname = GetSpellInfo(self.spellID)
	PickupSpell(spellname)
end

function MountJournalSummonRandomFavoriteButton_OnEnter( self, ... )
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("spell:"..self.spellID)
end

function MountJournalFilterDropDown_OnLoad( self, ... )
	UIDropDownMenu_Initialize(self, MountJournalFilterDropDown_Initialize, "MENU")
end

function MountJournalFilterDropDown_Initialize(_ ,level )
	local _level = level ~= 1 and UIDROPDOWNMENU_MENU_VALUE or level
	if MountJournalFilterDropDown_Data and MountJournalFilterDropDown_Data[_level] then
		for i = 1, #MountJournalFilterDropDown_Data[_level] do
			local data = MountJournalFilterDropDown_Data[_level][i]
			local info = UIDropDownMenu_CreateInfo()

			info.keepShownOnClick = true

			if data.keyValue then
				info.keyValue = data.keyValue
				info.checked = _G["MOUNTJOURNAL_FILTER_"..data.keyValue] or false
			end

			info.text = data.text
			info.func = function( self, _, _, value )
				if data.func then
					data.func( self, _, _, value )
				else
					if self.keyValue then
						_G["MOUNTJOURNAL_FILTER_"..self.keyValue] = not _G["MOUNTJOURNAL_FILTER_"..self.keyValue]
					end
				end
				MountJournal_UpdateScrollPos(MountJournalListScrollFrame, 1)
				MountJournal_UpdateFilter()
			end
			info.isNotRadio = data.isNotRadio

			if data.hasArrow then
				info.hasArrow = data.hasArrow
			end

			if data.notCheckable then
				info.notCheckable = data.notCheckable
			end

			if data.value then
				info.value = data.value
			end

			UIDropDownMenu_AddButton(info, level)
		end
	end
end

function MountColorButton_OnEnter( self, ... )
	self.BorderHighlight:Show()

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")

	if GameTooltip:SetHyperlink("spell:"..self.colorData.spellID) then
		self.UpdateTooltip = MountColorButton_OnEnter
	else
		self.UpdateTooltip = nil
	end

	GameTooltip:Show()
end

function MountColorButton_OnLeave( self, ... )
	self.BorderHighlight:Hide()
	GameTooltip:Hide()
end

function MountColorButton_OnClick( self, ... )
	self.CheckGlow:Show()
	self.LockIcon.CheckGlow:Show()

	for i = 1, 7 do
		local button = _G["MountJournalButtomFrameMountButtonColor"..i]
		if button and button:GetID() ~= self:GetID() then
			button.CheckGlow:Hide()
			button.LockIcon.CheckGlow:Hide()
		end
	end
end

function EventHandler:ACMSG_C_M_ADD_TO_FAVORITES( msg )
	if MOUNTJOURNAL_MOUNT_DATA_BY_HASH[msg] then
		MOUNTJOURNAL_MOUNT_DATA_BY_HASH[msg].isFavorite = true
		table.insert(SIRUS_MOUNTJOURNAL_FAVORITE_PET, msg)
	end

	MountJournal_CreateData()
	MountJournal_UpdateMountList()
end

function EventHandler:ASMSG_C_M_REMOVE_FROM_FAVORITES_R( msg )
	if MOUNTJOURNAL_MOUNT_DATA_BY_HASH[msg] then
		MOUNTJOURNAL_MOUNT_DATA_BY_HASH[msg].isFavorite = false
		tDeleteItem(SIRUS_MOUNTJOURNAL_FAVORITE_PET, msg)
	end

	MountJournal_CreateData()
	MountJournal_UpdateMountList()
end

function EventHandler:ASMSG_C_M_FAVORITES_LIST( msg )
	for _, v in pairs({strsplit(",", msg)}) do
		if v then
			table.insert(SIRUS_MOUNTJOURNAL_FAVORITE_PET, v)
		end
	end
end

function EventHandler:ASMSG_COLLECTION_MOUNT_IN_SHOP( msg )
	SIRUS_MOUNTJOURNAL_PRODUCT_DATA = {}

	if msg then
		local blockData = {strsplit("|", msg)}

		for i = 1, #blockData do
			if blockData[i] then
				local hash, currency, price, productID = strsplit(",", blockData[i])
				if hash and productID and price then
					table.insert(SIRUS_MOUNTJOURNAL_PRODUCT_DATA, {hash = hash, currency = currency, price = price, productID = productID})
				end
			end
		end
	end
end