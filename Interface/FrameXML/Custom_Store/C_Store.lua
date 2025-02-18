local _G = _G
local error = error
local next = next
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local select = select
local time = time
local tonumber = tonumber
local type = type
local unpack = unpack
local bitband, bitbor, bitlshift = bit.band, bit.bor, bit.lshift
local mathceil, mathfloor, mathmax, mathmin = math.ceil, math.floor, math.max, math.min
local strconcat, strfind, strformat, strjoin, strlen, strlower, strmatch, strsplit, strsub, strtrim = strconcat, string.find, string.format, string.join, string.len, string.lower, string.match, string.split, string.sub, string.trim
local tCompare, tIndexOf, tconcat, tinsert, tremove, tsort, twipe = tCompare, tIndexOf, table.concat, table.insert, table.remove, table.sort, table.wipe
local utf8len, utf8sub = utf8.len, utf8.sub

local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo
local GetItemStats = GetItemStats
local GetMoney = GetMoney
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitLevel = UnitLevel
local UnitName = UnitName
local issecure = issecure
local securecall = securecall

local Enum = Enum
local C_CVar = C_CVar
local C_Hardcore = C_Hardcore
local C_Heirloom = C_Heirloom
local C_Item = C_Item
local C_Service = C_Service
local C_Texture = C_Texture
local C_Timer = C_Timer
local C_Unit = C_Unit
local CopyTable = CopyTable
local FireClientEvent = FireClientEvent
local FireCustomClientEvent = FireCustomClientEvent
local GMError = GMError
local GetText = GetText
local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient
local RunNextFrame = RunNextFrame
local SecondsToTime = SecondsToTime
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx

local E_REALM_ID = E_REALM_ID
local PLAYER_FACTION_GROUP = PLAYER_FACTION_GROUP
local SECONDS_PER_DAY = SECONDS_PER_DAY

-- List of global strings, which should be cached to prevent modifications
local DONATE_URL = DONATE_URL
local HARDCORE_FEATURE_12_DISABLE = HARDCORE_FEATURE_12_DISABLE
local INVTYPE_HOLDABLE = INVTYPE_HOLDABLE
local MAINMENUBAR_STORE_DISABLE_REASON_HARDCORE = MAINMENUBAR_STORE_DISABLE_REASON_HARDCORE
local MAINMENUBAR_STORE_DISABLE_REASON_LOADING = MAINMENUBAR_STORE_DISABLE_REASON_LOADING
local MAINMENUBAR_STORE_DISABLE_REASON_UNAVAILABLE = MAINMENUBAR_STORE_DISABLE_REASON_UNAVAILABLE
local STORE_BUY_PREMIUM_ERROR_1 = STORE_BUY_PREMIUM_ERROR_1
local STORE_CATEGORY_UNAVAILABLE_LEVEL = STORE_CATEGORY_UNAVAILABLE_LEVEL
local STORE_CATEGORY_UNAVAILABLE_NEUTRAL_FACTION = STORE_CATEGORY_UNAVAILABLE_NEUTRAL_FACTION
local STORE_CATEGORY_UNAVAILABLE_SERVER = STORE_CATEGORY_UNAVAILABLE_SERVER
local STORE_CATEGORY_UNAVAILABLE_STRENGTHEN_STATS = STORE_CATEGORY_UNAVAILABLE_STRENGTHEN_STATS
local STORE_CONFIRM_NOTICE_WARNING_GENERIC = STORE_CONFIRM_NOTICE_WARNING_GENERIC
local STORE_CONFIRM_NOTICE_WARNING_RENEW_LIST = STORE_CONFIRM_NOTICE_WARNING_RENEW_LIST
local STORE_ERROR_FILL_FIELDS = STORE_ERROR_FILL_FIELDS
local STORE_ERROR_PRODUCT_MISSING = STORE_ERROR_PRODUCT_MISSING
local STORE_ERROR_PURCHASE_IN_PROCESS = STORE_ERROR_PURCHASE_IN_PROCESS
local STORE_ERROR_SUBSCRIPTION_PURCHASE_INTERNAL = STORE_ERROR_SUBSCRIPTION_PURCHASE_INTERNAL
local STORE_ERROR_SUBSCRIPTION_TRIAL_UNAVAILABLE = STORE_ERROR_SUBSCRIPTION_TRIAL_UNAVAILABLE
local STORE_ERROR_SUBSCRIPTION_UPGRADE_UNAVAILABLE = STORE_ERROR_SUBSCRIPTION_UPGRADE_UNAVAILABLE
local STORE_FAVORITE_ERROR_1 = STORE_FAVORITE_ERROR_1
local STORE_ILLUSION_REFRESH_TITLE = STORE_ILLUSION_REFRESH_TITLE
local STORE_MOUNT_REFRESH_TITLE = STORE_MOUNT_REFRESH_TITLE
local STORE_PET_REFRESH_TITLE = STORE_PET_REFRESH_TITLE
local STORE_PURCHASE_ERROR_11 = STORE_PURCHASE_ERROR_11
local STORE_PURCHASE_ERROR_BALANCE_BONUS = STORE_PURCHASE_ERROR_BALANCE_BONUS
local STORE_PURCHASE_ERROR_LOYALITY_LEVEL = STORE_PURCHASE_ERROR_LOYALITY_LEVEL
local STORE_REFRESH_DESCRIPTION_GENERIC = STORE_REFRESH_DESCRIPTION_GENERIC
local STORE_REFRESH_DESCRIPTION_TRANSMOG = STORE_REFRESH_DESCRIPTION_TRANSMOG
local STORE_SHOUT_MESSAGE_PREVIEW = STORE_SHOUT_MESSAGE_PREVIEW
local STORE_TRANSMOGRIFY_REFRESH_TITLE = STORE_TRANSMOGRIFY_REFRESH_TITLE
local UNKNOWN = UNKNOWN

Enum.Store = {}
Enum.Store.CurrencyType = Enum.CreateMirror({
	Gold				= 0,
	Bonus				= 1,
	Vote				= 2,
	Referral			= 3,
	Loyality			= 4,
	BattlePassExp		= 5,
	ArenaPoint			= 6,
	Honor				= 7,
})
Enum.Store.Category = {
	Main				= 1,
	Equipment			= 2,
	Collections			= 3,
	SpecialServices		= 4,
	Subscriptions		= 5,
	Transmogrification	= 6,

	-- Alt currencies
	Vote				= -2,
	Referral			= -3,
	Loyality			= -4,
}
Enum.Store.CollectionType = Enum.CreateMirror({
	Mount				= 1,
	Pet					= 2,
	Illusion			= 3,
	Toy					= 4,
})
Enum.Store.ProductType = {
	Item				= 0,
	Subscription		= 1,
	SpecialOffer		= 2,
	SpecialOfferFS		= 3,
	RenewProductList	= 4,
	Refund				= 5,
	BattlePass			= 6,
	VirtualItem			= 7,
}
Enum.Store.SubscriptionType = {
	Julia = 1,
	Pets = 2,
	Mounts = 3,
	Transmogrify = 4,
	AllInclusive = 5,
	StrategicPack = 6,
}
Enum.Store.SubscriptionState = {
	Inactive = 0,
	InactiveTrialAvailable = 1,
	TrialActive = 2,
	StandardActive = 3,
	ExtraActive = 4,
}
Enum.Store.ProductSortType = {
	None = 0,
	Name = 1,
	Price = 2,
	Discount = 3,
	ItemLevel = 4,
	PVP = 5,
}
Enum.Store.GiftType = {
	Normal = 1,
	Loyality = 2,
}

local ALLOW_BONUS_REPLENISHMENT = true
local BLOCK_COLLECTION_LISTS_WITHOUT_ROLL_TIMER = false
local FAVORITE_SORT_AFTER_STATE_CHANGE = false

local ICON_UNKNOWN = [[Interface\Icons\INV_Misc_QuestionMark]]
local ITEM_RARITY_FALLBACK = 1

local CATEGORY_ICON_PATH = [[Interface\Store\]]

local PREMIUM_PERMANENT_TIME = 43200000
local STORE_PERMANENT_PREMIUM = -1
local STORE_VERSION_FALLBACK = -1
local NO_PRODUCT_PRICE = -1

local OFFER_ALERT_LAST_HOUR_SECONDS = 3600
local PROMOCODE_MAX_LENGHT = 8
local GIFT_TEXT_MAX_LETTERS = 500
local REALM_SHOUT_MIN_LETTERS = 3
local REALM_SHOUT_MAX_LETTERS = 256
local FAVORITE_PRODUCTS_PER_CATEGORY = 1

local PRODUCT_MODEL_FACING = math.rad(25)

local QUEARY_ALL_ITEMS = true
local LOADING_DATA_TIME = IsGMAccount() and 0 or 60

local ALLOW_SEARCH_BY_PRODUCT_ID = IsGMAccount() or IsInterfaceDevClient()

local STORE_TRANSMOGRIFY_STORAGE
local STORE_PRODUCT_CACHE = {}
local STORE_DATA_CACHE = {
	HAS_NEW = {},
	SEEN = {},
	ROLLED_ITEM_HASHES = {},
	GLOBAL_DISCOUNTS = {},
	OFFER_LAST_HOUR_SEEN = {},
	EQUIPMENT_ITEM_LEVELS = {},
	FAVORITE_PRODUCTS = {},
}

local PRODUCT_CACHE_TTL = 259200
local PRODUCT_CACHE_FIELD = {
	VERSION			= -1,
	TTL				= -2,
	REALM_STAGE		= -3,
	VERSION_SEEN	= -4,
	PLAYER_GUID		= -5,
}

local PRODUCT_STORAGE_FIELD = {
	VERSION			= -1,
	VERSION_FACTION	= -2,
	VERSION_ROLLED	= -3,
}

local PRODUCT_DATA_FIELD = {
	ORIGINAL_PRODUCT_ID	= -5,
	SUB_CATEGORY_ID		= -4,
	CATEGORY_ID			= -3,
	CURRENCY_ID			= -2,
	PRODUCT_TYPE		= -1,
	PRODUCT_ID			= 1,
	ITEM_ID				= 2,
	ITEM_AMOUNT			= 3,
	PRICE				= 4,
	DISCOUNT			= 5,
	DISCOUNT_PRICE		= 6,
	CREATURE_ID			= 7,
	FLAGS				= 8,
	ALT_CURRENCY		= 9,
	ALT_PRICE			= 10,
	FLAGS_DYNAMIC		= 11,
	BASE_DISCOUNT_PRICE	= 12,
	BASE_DISCOUNT		= 13,
}

local PRODUCT_TEMP_FIELDS = {
	["itemInfo"] = true,
	["itemStats"] = true,
}

local PRODUCT_FLAG = {
	NONE					= 0x0000,
	NEW						= 0x0001,
	PVP						= 0x0002,
	RECOMMENDED				= 0x0004,
	PROMOTIONAL				= 0x0008,
	SPECIAL					= 0x0010,
	GIFTABLE				= 0x0020,
	MULTIPLE_BUY			= 0x0400,
	IGNORE_DISCOUNT			= 0x0800,
}

local PRODUCT_FLAG_DYNAMIC = {
	IS_PERSONAL				= 0x0001,
	ROLLABLE_UNAVAILABLE	= 0x0002,
	NO_PURCHASE_CAN_GIFT	= 0x0004,
	FORBID_GIFT				= 0x0008,
	CAN_FAVORITE			= 0x0010,
}

local OFFER_FLAG = {
	SPEC_SELECTABLE	= 0x1,
	SUBSCRIPTION	= 0x2,
	MULTI_PAYABLE	= 0x4,
	REGULAR			= 0x8,
	GIFTABLE		= 0x10,
}

local SERVICE_FLAG = {
	CUSTOMIZATION		= 0x08,
	CHANGE_FACTION		= 0x40,
	CHANGE_RACE			= 0x80,
	CHANGE_ZODIAC		= 0x80000,
}

local SERVICE_FLAG_DATA = {
	{
		flag = SERVICE_FLAG.CUSTOMIZATION,
		text = STORE_SERVICE_LABEL_1,
	},
	{
		flag = SERVICE_FLAG.CHANGE_FACTION,
		text = STORE_SERVICE_LABEL_2,
	},
	{
		flag = SERVICE_FLAG.CHANGE_RACE,
		text = STORE_SERVICE_LABEL_3,
	},
	{
		flag = SERVICE_FLAG.CHANGE_ZODIAC,
		text = STORE_SERVICE_LABEL_4,
	},
}

local SUBSCRIPTION_OPTIONS = {
	[0] = 3, -- trial
	[1] = 7,
	[2] = 30,
}
local SUBSCRIPTION_UPGRADE_OPTION_INDEX = #SUBSCRIPTION_OPTIONS + 1

local SUBSCRIPTION_PRODUCT_ICON = {
	[Enum.Store.SubscriptionType.Julia]			= [[Interface\Icons\INV_Misc_CrystalEpic]],
	[Enum.Store.SubscriptionType.Pets]			= [[Interface\Icons\Icon_upgradestone_critter_legendary]],
	[Enum.Store.SubscriptionType.Mounts]		= [[Interface\Icons\Icon_upgradestone_flying_legendary]],
	[Enum.Store.SubscriptionType.Transmogrify]	= [[Interface\Icons\Icon_upgradestone_humanoid_legendary]],
	[Enum.Store.SubscriptionType.AllInclusive]	= [[Interface\Icons\Icon_upgradestone_legendary]],
	[Enum.Store.SubscriptionType.StrategicPack]	= [[Interface\Icons\Inv_misc_token_darkmoon_01]],
}

local PROMO_CODE_ITEM_TYPE = {
	[1] = { -- Boost
		icon = [[Interface\Icons\UI_Promotion_CharacterBoost]],
		name = STORE_PROMOCODE_REWARD_FAST_LEVEL_BOOST,
		rarity = LE_ITEM_QUALITY_LEGENDARY,
	},
	[2] = { -- Gold
		icon = [[Interface\Icons\Inv_Misc_Coin_01]],
		name = STORE_PROMOCODE_REWARD_GOLD,
		rarity = LE_ITEM_QUALITY_COMMON,
	},
}

local REALM_SHOUT = {
	price = 99,
	originalPrice = 0,
	currencyType = Enum.Store.CurrencyType.Bonus,
}

local REFUND_STATUS = {
	OK						= 0,
	PRODUCT_NOT_REFUNDABLE	= 1,
	OWNER_GUID_MISSMATCH	= 2,
	TIME_EXPIRED			= 3,
	PENALTY_TOO_HIGH		= 4,
	PRODUCT_GUID_WRONG		= 5,
}

local NO_RETURN_POLICY_ITEMS = {
	[45038] = STORE_CONFIRM_NOTICE_WARNING_QUEST,
	[151696] = STORE_CONFIRM_NOTICE_WARNING_QUEST,
}

local TRANSMOG_OFFER_MAIN_SUB_CATEGORY = 0
local TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY = 100

local BATTLEPASS_CATEGORY = 101
local BATTLEPASS_SUBCATEGORY = {
	EXPERIENCE	= 1,
	PREMIUM		= 2,
}

local INVENTORY_SLOTS = {
	{"HeadSlot", INVTYPE_HEAD},
	{"NeckSlot", INVTYPE_NECK},
	{"ShoulderSlot", INVTYPE_SHOULDER},
	{"BackSlot", INVTYPE_CLOAK},
	{"ChestSlot", INVTYPE_CHEST},
	{"WristSlot", INVTYPE_WRIST},

	{"HandsSlot", INVTYPE_HAND},
	{"WaistSlot", INVTYPE_WAIST},
	{"LegsSlot", INVTYPE_LEGS},
	{"FeetSlot", INVTYPE_FEET},
	{"Finger0Slot", INVTYPE_FINGER},
	{"Trinket0Slot", INVTYPE_TRINKET},

	{"MainHandSlot", INVTYPE_WEAPONMAINHAND},
	{"SecondaryHandSlot", INVTYPE_WEAPONOFFHAND},
	{"RangedSlot", INVTYPE_RANGED},
}
local RELIC_SLOT = {INVTYPE_RELIC, "Interface/PaperDoll/UI-PaperDoll-Slot-Relic"}

local PRIVATE = {
	STORE_ENABLED = false,
	STORE_FRAME = nil,

	STORE_PRODUCT_CACHE = STORE_PRODUCT_CACHE,
	STORE_DATA_CACHE = STORE_DATA_CACHE,

	VERSION = STORE_VERSION_FALLBACK,

	PREMIUM_REMAINING_TIME = 0,
	BALANCE = {},
	LOYALITY = {},
	REFERRAL = {},

	SELECTED_CATEGORY_INDEX = Enum.Store.Category.Main,
	SELECTED_SUB_CATEGORY_INDEX = 0,
	SELECTED_FILTER = QUEARY_ALL_ITEMS and 1 or 0,

	REQUEST_CURRENT = nil,
	REQUEST_QUEUE = {},
	PENDING_PURCHASE_PRODUCT_TYPE = nil,
	PENDING_PURCHASE_PRODUCT_ID = nil,
	PENDING_PURCHASE_AWAIT_ANSWER = nil,

	PRODUCT_LIST = {},
	PRODUCT_LIST_DUPS = {},

	CATEGORY_PRODUCT_LIST = {},
	CATEGORY_PRODUCT_LIST_SORT_INFO = {},
	CATEGORY_PRODUCT_LIST_FILTER_INFO = {},
	QUEUED_PRODUCT_ITEM_INFO = {},

	COLLECTION_PRODUCT_LIST = {},

	TRANSMOG_ITEM_DATA = {},
	TRANSMOG_SET_DATA = {},

	OFFER_LIST = {},
	OFFER_MAP = {},

	OFFER_DETAIL_LIST = {},
	OFFER_IS_NEW = {},
	OFFER_TIMER = {},
	OFFER_POPUP_DATA = {},
	OFFER_POPUP_SMALL_LIST = {},
	OFFER_POPUP_FULLSCREEN = {},
	OFFER_POPUP_FULLSCREEN_ENABLED = true,

	SUBSCRIPTION_MAP = {},
	SUBSCRIPTION_LIST = {},
	REFUND_LIST = {},

	PROMO_CODE_LAST_VALID = nil,
	PROMO_CODE_ITEMS = {},
}

PRIVATE.CURRENCY_INFO = {
	[Enum.Store.CurrencyType.Gold] = {
		name = STORE_CURRENCY_GOLD_LABEL,
		texture = "Interface/Icons/INV_Misc_Coin_02",
		atlas = "PKBT-Icon-Currency-Gold",
	},
	[Enum.Store.CurrencyType.Bonus] = {
		name = STORE_CURRENCY_BONUS_LABEL,
		description = STORE_CURRENCY_BONUS_DESCRIPTION,
		texture = [[Interface\Store\coins]],
		atlas = "PKBT-Icon-Currency-Bonus",
		errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_BONUS,
	},
	[Enum.Store.CurrencyType.Loyality] = {
		name = STORE_CURRENCY_LOYALITY_LABEL,
		description = STORE_CURRENCY_LOYALITY_DESCRIPTION,
		texture = [[Interface\Store\loyal]],
		atlas = "PKBT-Icon-Currency-Loyality",
		errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_LOYALITY,
	},
	[Enum.Store.CurrencyType.Vote] = {
		name = STORE_CURRENCY_VOTE_LABEL,
		description = STORE_CURRENCY_VOTE_DESCRIPTION,
		texture = [[Interface\Store\mmotop]],
	--	atlas = "PKBT-Icon-Currency-Vote",
		atlas = "PKBT-Store-Icon-Logo",
		errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_VOTE,
	},
	[Enum.Store.CurrencyType.Referral] = {
		name = STORE_CURRENCY_REFERRAL_LABEL,
		description = STORE_CURRENCY_REFERRAL_DESCRIPTION,
		texture = [[Interface\Store\refer]],
		atlas = "PKBT-Icon-Currency-Referral",
		errorText = STORE_NOT_ENOUGHT_FOR_PURCHASE_REFERRAL,
	},
	[Enum.Store.CurrencyType.BattlePassExp] = {
		name = BATTLEPASS_EXPERIENCE_LABEL,
		description = BATTLEPASS_EXPERIENCE_DESCRIPTION,
		atlas = "PKBT-BattlePass-Icon-Gem-Sapphire",
	},
	[Enum.Store.CurrencyType.ArenaPoint] = {
		name = ARENA_POINTS,
		description = TOOLTIP_ARENA_POINTS,
		texture = [[Interface\PVPFrame\PVPCurrency-Conquest1-]],
	},
	[Enum.Store.CurrencyType.Honor] = {
		name = HONOR_POINTS,
		description = TOOLTIP_HONOR_POINTS,
		texture = [[Interface\PVPFrame\PVPCurrency-Honor1-]],
	},
}

PRIVATE.CATEGORIES = {
	[Enum.Store.Category.Main] = {
		name = STORE_CATEGORY_SPECIAL_OFFERS,
		icon = strconcat(CATEGORY_ICON_PATH, "category-icon-featured"),
		currencyType = Enum.Store.CurrencyType.Bonus,

		remoteCategoryID = 1,
	--	hasZeroSubCategory = true,
	},
	[Enum.Store.Category.Equipment] = {
		name = STORE_CATEGORY_EQUIPMENT,
		icon = strconcat(CATEGORY_ICON_PATH, "category-icon-armor"),
		currencyType = Enum.Store.CurrencyType.Bonus,

		remoteCategoryID = 2,

		hasOverview = true,
		hasItemList = true,
	},
	[Enum.Store.Category.Collections] = {
		name = STORE_CATEGORY_COLLECTIONS,
		icon = strconcat(CATEGORY_ICON_PATH, "category-icon-mounts"),
		currencyType = Enum.Store.CurrencyType.Bonus,
		remoteCategoryID = 3,
	},
	[Enum.Store.Category.SpecialServices] = {
		name = STORE_CATEGORY_SPECIALS,
		icon = strconcat(CATEGORY_ICON_PATH, "category-icon-hot"),
		currencyType = Enum.Store.CurrencyType.Bonus,
		remoteCategoryID = 4,
		hasItemList = true,
	},
	[Enum.Store.Category.Subscriptions] = {
		name = STORE_CATEGORY_SUPPLIES,
		icon = strconcat(CATEGORY_ICON_PATH, "category-icon-box"),
		currencyType = Enum.Store.CurrencyType.Bonus,
		remoteCategoryID = 5,
		isDisabled = true,
		hasOverview = true,

		IsAvailablePost = function()
			if UnitLevel("player") < 80 then
				return true, false, strformat(STORE_CATEGORY_UNAVAILABLE_LEVEL, 80)
			end
			return true, true
		end,
	},
	[Enum.Store.Category.Transmogrification] = {
		name = STORE_CATEGORY_TRANSMOGRIFICATION,
		icon = strconcat(CATEGORY_ICON_PATH, "category-icon-clothes"),
		currencyType = Enum.Store.CurrencyType.Bonus,
		remoteCategoryID = 6,
		hasItemList = true,
		hasZeroSubCategory = true,
	},

	[Enum.Store.Category.Vote] = {
		name = STORE_CURRENCY_VOTE_LABEL,
		remoteCurrencyID = 2,
		remoteCategoryID = 0,
		isHidden = true,
		hasItemList = true,
		itemListNoFilters = true,
		hasZeroSubCategory = true,
	},
	[Enum.Store.Category.Referral] = {
		name = STORE_CURRENCY_REFERRAL_LABEL,
		remoteCurrencyID = 3,
		remoteCategoryID = 0,
		isHidden = true,
		hasItemList = true,
		itemListNoFilters = true,
		hasZeroSubCategory = true,
	},
	[Enum.Store.Category.Loyality] = {
		name = STORE_CURRENCY_LOYALITY_LABEL,
		remoteCurrencyID = 4,
		remoteCategoryID = 0,
		isHidden = true,
		hasItemList = true,
		itemListNoFilters = true,
		hasZeroSubCategory = true,
	},
}

PRIVATE.SUB_CATEGORIES = {
	[Enum.Store.Category.Main] = {
		[0] = {
			name = STORE_CATEGORY_SPECIAL_OFFERS,
			isHidden = true,
		},
	},
	[Enum.Store.Category.Equipment] = {}, -- generated
	[Enum.Store.Category.Collections] = {
		[Enum.Store.CollectionType.Mount] = {
			name = STORE_SUB_CATEGORY_MOUNTS,
			icon = "PKBT-Store-Icon-Category-Mount",
			IsAvailablePost = function()
				if UnitLevel("player") < 20 then
					return true, false, strformat(STORE_CATEGORY_UNAVAILABLE_LEVEL, 20)
				end
				return true, true
			end,
		},
		[Enum.Store.CollectionType.Pet] = {
			name = STORE_SUB_CATEGORY_PETS,
			icon = "PKBT-Store-Icon-Category-Pet",
		},
		[Enum.Store.CollectionType.Illusion] = {
			name = STORE_SUB_CATEGORY_ILLUSIONS,
			icon = "PKBT-Store-Icon-Category-Illusion",
		},
		[Enum.Store.CollectionType.Toy] = {
			name = STORE_SUB_CATEGORY_TOYS,
			icon = "PKBT-Store-Icon-Category-Toy",
			isDisabled = true,
			isHidden = true,
		},
	},
	[Enum.Store.Category.SpecialServices] = {
		[1] = {
			name = STORE_SUB_CATEGORY_SERVICES,
			icon = "PKBT-Store-Icon-Category-Service",
			IsAvailablePost = function()
				if C_Unit.IsNeutral("player") then
					return true, false, STORE_CATEGORY_UNAVAILABLE_NEUTRAL_FACTION
				elseif UnitLevel("player") < 10 then
					return true, false, strformat(STORE_CATEGORY_UNAVAILABLE_LEVEL, 10)
				end
				return true, true
			end,
		},
		[2] = {
			name = STORE_SUB_CATEGORY_PROFESSIONS,
			icon = "PKBT-Store-Icon-Category-Profession",
		},
		[3] = {
			name = STORE_SUB_CATEGORY_CONSUMABLES,
			icon = "PKBT-Store-Icon-Category-Consumable",
		},
		[4] = {
			name = STORE_SUB_CATEGORY_REAGENTS,
			icon = "PKBT-Store-Icon-Category-Reagent",
		},
		[5] = {
			name = STORE_SUB_CATEGORY_QUESTS,
			icon = "PKBT-Store-Icon-Category-Quest",
			IsAvailablePost = function()
				if UnitLevel("player") < 10 then
					return true, false, strformat(STORE_CATEGORY_UNAVAILABLE_LEVEL, 10)
				end
				return true, true
			end,
		},
		[6] = {
			name = STORE_SUB_CATEGORY_FACTIONS,
			icon = "PKBT-Store-Icon-Category-Faction",
			IsAvailablePost = function()
				if UnitLevel("player") < 20 then
					return true, false, strformat(STORE_CATEGORY_UNAVAILABLE_LEVEL, 20)
				end
				return true, true
			end,
		},
		[7] = {
			name = STORE_SUB_CATEGORY_CURRENCIES,
			icon = "PKBT-Store-Icon-Category-Currency",
		},
		[8] = {
			name = STORE_SUB_CATEGORY_CATEGORIES,
			icon = "PKBT-Store-Icon-Category-Category",
			IsAvailablePost = function()
				if not C_Service.IsStrengthenStatsRealm() then
					return true, false, STORE_CATEGORY_UNAVAILABLE_STRENGTHEN_STATS
				elseif UnitLevel("player") < 80 then
					return true, false, strformat(STORE_CATEGORY_UNAVAILABLE_LEVEL, 80)
				end
				return true, true
			end,
		},
	},
	[Enum.Store.Category.Subscriptions] = {
		[0] = {
			name = STORE_CATEGORY_SUPPLIES,
			isVirtual = true,
			isHidden = true,
			IsAvailablePost = function()
				return #PRIVATE.SUBSCRIPTION_MAP ~= 0
			end,
		},
	},
	[Enum.Store.Category.Transmogrification] = {
		[0] = {
			name = STORE_CATEGORY_TRANSMOGRIFICATION,
			isHidden = true,
		},
		[1] = {
			name = STORE_SUB_CATEGORY_TRANSMOG_HEADGEAR,
			atlas = "PKBT-Store-Cards-Transmog-Artwork-1",
		},
		[2] = {
			name = STORE_SUB_CATEGORY_TRANSMOG_WEAPONS,
			atlas = "PKBT-Store-Cards-Transmog-Artwork-2",
		},
		[3] = {
			name = STORE_SUB_CATEGORY_TRANSMOG_INVISIBLE_ARMOR,
			atlas = "PKBT-Store-Cards-Transmog-Artwork-3",
		},
		[4] = {
			name = STORE_SUB_CATEGORY_TRANSMOG_ARMOR_SETS,
			atlas = "PKBT-Store-Cards-Transmog-Artwork-4",
		},
	},
--[[
	[Enum.Store.Category.Vote] = {
		[0] = {
			isHidden = true,
		},
	},
	[Enum.Store.Category.Referral] = {
		[0] = {
			isHidden = true,
		},
	},
	[Enum.Store.Category.Loyality] = {
		[0] = {
			isHidden = true,
		},
	},
--]]
}

PRIVATE.PREMIUM_BONUSES = {
	{
		text = STORE_PREMIUM_BONUS_1,
		atlas = "PKBT-Store-Icon-Reward-PVPCurrency",
		value = 5,
	},
	{
		text = STORE_PREMIUM_BONUS_2,
		atlas = "PKBT-Store-Icon-Reward-Gold",
		value = 30,
	},
	{
		text = STORE_PREMIUM_BONUS_3,
		atlas = "PKBT-Store-Icon-Reward-XP",
		value = 50,
	},
}

PRIVATE.OFFERS_MODEL_DATA = {
	[62] = { -- AF2023
		PopupModelInfo = {50027, -0.68, "BOTTOM", "TOP", 0, -15, 300, 220, 1},

		Banner = {
			BorderColor 		= {0.071, 0.565, 1},
			TimerColor			= {0.733, 0.262, 0.494},
			TitleColor			= {1, 0.8588, 0.9137},
			NameColor			= {0.733, 0.262, 0.494},
			DescriptionColor	= {1, 0.8588, 0.9137},
			PriceLabelColor		= {0.733, 0.262, 0.494},
			PriceColor			= {1, 0.9, 0.9},

			SceneInfo = {
				{50027, 285, 209, {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", -85, 26}, -37, 1, {0, 0, 0}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
				{131198, 229, 90, {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 7}, -37, 1, {0, 0, -0.300}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
			},
		},
	},
	[64] = { -- NY2024
		PopupModelInfo = {131420, -0.68, "BOTTOM", "TOP", -10, -100, 510, 442, 1},

		Banner = {
			BorderColor			= {0.11, 0.67, 0.84},
			TimerColor			= {0.11, 0.67, 0.84},
			TitleColor			= {0.8, 0.86, 0.97},
			NameColor			= {0.11, 0.67, 0.84},
			DescriptionColor	= {0.8, 0.86, 0.97},
			PriceLabelColor		= {0.11, 0.67, 0.84},
			PriceColor			= {0.8, 0.86, 0.97},

			SceneInfo = {
				{131420, 540, 270, {"TOPRIGHT", nil, "TOPRIGHT", 0, -1}, -37, 1, {0, 0, 0}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
				{131674, 240, 184, {"BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, -20}, -37, 1, {0, 0, -0.300}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
			},
		},
	},
	[65] = { -- LoveFoxPink
		PopupModelInfo = {131785, -0.68, "BOTTOM", "TOP", -10, -100, 810, 542, 1},

		Banner = {
			BorderColor			= {0, 1, 1},
			TimerColor			= {0.878, 1, 1},
			TitleColor			= {0, 1, 1},
			NameColor			= {0.878, 1, 1},
			DescriptionColor	= {0, 1, 1},
			PriceLabelColor		= {0.878, 1, 1},
			PriceColor			= {0, 1, 1},

			SceneInfo = {
				{131785, 825, 300, {"TOPRIGHT", nil, "TOPRIGHT", 190, 21}, 35, 1, {0, 0, 0}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
			},
		},
	},
	[66] = { -- LoveFoxBlue
		PopupModelInfo = {131786, -0.68, "BOTTOM", "TOP", -10, -100, 810, 542, 1},

		Banner = {
			BorderColor			= {0, 1, 0},
			TimerColor			= {0, 1, 0},
			TitleColor			= {0.596, 0.984, 0.596},
			NameColor			= {0, 1, 0},
			DescriptionColor	= {0.596, 0.984, 0.596},
			PriceLabelColor		= {0, 1, 0},
			PriceColor			= {0.596, 0.984, 0.596},

			SceneInfo = {
				{131786, 825, 300, {"TOPRIGHT", nil, "TOPRIGHT", 190, 21}, 35, 1, {0, 0, 0}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
			},
		},
	},
	[67] = { -- LoveFoxPurple
		PopupModelInfo = {131787, -0.68, "BOTTOM", "TOP", -10, -100, 810, 542, 1},

		Banner = {
			BorderColor			= {0.933, 0.51, 0.933},
			TimerColor			= {0.933, 0.51, 0.933},
			TitleColor			= {0.902, 0.902, 0.9},
			NameColor			= {0.933, 0.51, 0.933},
			DescriptionColor	= {0.902, 0.902, 0.9},
			PriceLabelColor		= {0.933, 0.51, 0.933},
			PriceColor			= {0.902, 0.902, 0.9},

			SceneInfo = {
				{131787, 825, 300, {"TOPRIGHT", nil, "TOPRIGHT", 190, 21}, 35, 1, {0, 0, 0}, {1, 0, -0.674, -0.428, 0.520, 1, 0.702, 0.702, 0.702, 1, 1, 1, 0.8}},
			},
		},
	},
	[68] = { -- AF20241
		PopupModelInfo = {131224, -0.68, "BOTTOM", "TOP", 30, -80, 420, 300, 1},

		Banner = {
			BorderColor			= {0.55, 0.69, 0.99},
			TimerColor			= {0.55, 0.69, 0.99},
			TitleColor			= {0.55, 0.69, 0.99},
			NameColor			= {0.902, 0.902, 0.98},
			DescriptionColor	= {0.902, 0.902, 0.98},
			PriceLabelColor		= {0.55, 0.69, 0.99},
			PriceColor			= {0.902, 0.902, 0.98},

			SceneInfo = {
				{131224, 455, 250, {"TOPRIGHT", nil, "TOPRIGHT", 40, -30}, 35, 1, {0, 0, 0}, {1, 0, -3.020, 6.796, -5.034, 1.000, 0.702, 0.702, 0.702, 1.000, 1.000, 1.000, 1.000}},
			},
		},
	},
	[69] = { -- AF20242
		PopupModelInfo = {131225, -0.68, "BOTTOM", "TOP", 30, -80, 420, 300, 1},

		Banner = {
			BorderColor			= {0.94, 0.44, 0.4},
			TimerColor			= {0.94, 0.44, 0.4},
			TitleColor			= {0.94, 0.44, 0.4},
			NameColor			= {0.902, 0.902, 0.98},
			DescriptionColor	= {0.902, 0.902, 0.98},
			PriceLabelColor		= {0.94, 0.44, 0.4},
			PriceColor			= {0.902, 0.902, 0.98},

			SceneInfo = {
				{131225, 455, 250, {"TOPRIGHT", nil, "TOPRIGHT", 40, -30}, 35, 1, {0, 0, 0}, {1, 0, -3.020, 6.796, -5.034, 1.000, 0.702, 0.702, 0.702, 1.000, 1.000, 1.000, 1.000}},
			},
		},
	},
	[70] = { -- AF20243
		PopupModelInfo = {131226, -0.68, "BOTTOM", "TOP", 30, -80, 420, 300, 1},

		Banner = {
			BorderColor			= {0.17, 0.75, 0.51},
			TimerColor			= {0.17, 0.75, 0.51},
			TitleColor			= {0.17, 0.75, 0.51},
			NameColor			= {0.902, 0.902, 0.98},
			DescriptionColor	= {0.902, 0.902, 0.98},
			PriceLabelColor		= {0.17, 0.75, 0.51},
			PriceColor			= {0.902, 0.902, 0.98},

			SceneInfo = {
				{131226, 455, 250, {"TOPRIGHT", nil, "TOPRIGHT", 40, -30}, 35, 1, {0, 0, 0}, {1, 0, -3.020, 6.796, -5.034, 1.000, 0.702, 0.702, 0.702, 1.000, 1.000, 1.000, 1.000}},
			},
		},
	},
	[71] = { -- HW2024
		PopupModelInfo = {131436, -0.68, "BOTTOM", "TOP", 30, -80, 420, 300, 1},

		Banner = {
			BorderColor			= {1, 0.53, 0},
			TimerColor			= {1, 0.53, 0},
			TitleColor			= {1, 0.53, 0},
			NameColor			= {0.902, 0.902, 0.98},
			DescriptionColor	= {0.902, 0.902, 0.98},
			PriceLabelColor		= {1, 0.53, 0},
			PriceColor			= {0.902, 0.902, 0.98},
			NameHeight			= 16,

			SceneInfo = {
				{131436, 440, 230, {"TOPRIGHT", nil, "TOPRIGHT", -20, -15}, 35, 1, {0, 0, 0}, {1, 0, -3.020, 6.796, -5.034, 1.000, 0.702, 0.702, 0.702, 1.000, 1.000, 1.000, 1.000}},
			},
		},
	},
	[72] = { -- NY2025
		PopupCreature = 131793,
		PopupModelInfo = {131793, -0.68, "BOTTOM", "TOP", -40, -40, 320, 300, 1},

		Banner = {
			BorderColor			= {0.26, 0.67, 1},
			TimerColor			= {0.26, 0.67, 1},
			TitleColor			= {0.26, 0.67, 1},
			NameColor			= {0.5, 0.78, 1},
			DescriptionColor	= {0.5, 0.78, 1},
			PriceLabelColor		= {0.26, 0.67, 1},
			PriceColor			= {0.5, 0.78, 1},
			NameHeight			= 16,

			SceneInfo = {
				{131793, 270, 270, {"TOPRIGHT", nil, "TOPRIGHT", -60, -5}, 35, 1, {0, 0, 0}, {1, 0, -3.020, 6.796, -5.034, 1.000, 0.702, 0.702, 0.702, 1.000, 1.000, 1.000, 1.000}},
			},
		},
	},
}

PRIVATE.PREMIUM_DATA = {
	{
		text = STORE_PREMIUM_BUY_1,
		discountText = STORE_PREMIUM_DISCOUNT_INFO_1,
		price = 3,
	},
	{
		text = STORE_PREMIUM_BUY_2,
		discountText = STORE_PREMIUM_DISCOUNT_INFO_2,
		price = 9,
	},
	{
		text = STORE_PREMIUM_BUY_3,
		discountText = STORE_PREMIUM_DISCOUNT_INFO_3,
		price = 29,
	},
	{
		text = STORE_PREMIUM_BUY_4,
		discountText = strformat("|cff1AFF1A%s|r", STORE_PREMIUM_DISCOUNT_INFO_4),
		price = 499,
	},
}

PRIVATE.GIFT_OPTIONS = {
	{
		id = 41,
		name = STORE_GIFT_LABEL_1,
		texture = "Interface/Stationery/StationeryTest",
	},
	{
		id = 65,
		name = STORE_GIFT_LABEL_2,
		texture = "Interface/Stationery/Stationery_Chr",
	},
	{
		id = 64,
		name = STORE_GIFT_LABEL_3,
		texture = "Interface/Stationery/Stationery_Val",
	},
}

PRIVATE.TRANSMOG_WEAPON_SUB_CLASS = {
	{name = ITEM_SUB_CLASS_2_0,		classID = 2, subClassID = 0},
	{name = ITEM_SUB_CLASS_2_1,		classID = 2, subClassID = 1},
	{name = ITEM_SUB_CLASS_2_2,		classID = 2, subClassID = 2},
	{name = ITEM_SUB_CLASS_2_3,		classID = 2, subClassID = 3},
	{name = ITEM_SUB_CLASS_2_4,		classID = 2, subClassID = 4},
	{name = ITEM_SUB_CLASS_2_5,		classID = 2, subClassID = 5},
	{name = ITEM_SUB_CLASS_2_6,		classID = 2, subClassID = 6},
	{name = ITEM_SUB_CLASS_2_7,		classID = 2, subClassID = 7},
	{name = ITEM_SUB_CLASS_2_8,		classID = 2, subClassID = 8},
	{name = ITEM_SUB_CLASS_2_10,	classID = 2, subClassID = 10},
	{name = ITEM_SUB_CLASS_2_13,	classID = 2, subClassID = 13},
	{name = ITEM_SUB_CLASS_2_15,	classID = 2, subClassID = 15},
	{name = ITEM_SUB_CLASS_2_16,	classID = 2, subClassID = 16},
	{name = ITEM_SUB_CLASS_2_18,	classID = 2, subClassID = 18},
	{name = ITEM_SUB_CLASS_2_19,	classID = 2, subClassID = 19},
	{name = ITEM_SUB_CLASS_4_6,		classID = 4, subClassID = 6, inventoryType = 14},
}

PRIVATE.EventHandler = CreateFrame("Frame")
PRIVATE.EventHandler:RegisterEvent("PLAYER_LOGIN")
PRIVATE.EventHandler:RegisterEvent("PLAYER_LOGOUT")
PRIVATE.EventHandler:RegisterEvent("VARIABLES_LOADED")
PRIVATE.EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
PRIVATE.EventHandler:RegisterEvent("UNIT_LEVEL")
PRIVATE.EventHandler:RegisterEvent("CHAT_MSG_ADDON")
PRIVATE.EventHandler:RegisterCustomEvent("SERVICE_DATA_UPDATE")
PRIVATE.EventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, message, channel, sender = ...
		if channel == "UNKNOWN" and sender == UnitName("player") then
			if PRIVATE[prefix] then
				PRIVATE[prefix](message)
			end
		end
	elseif event == "SERVICE_DATA_UPDATE" then
		if PRIVATE.VARIABLES_LOADED and STORE_PRODUCT_CACHE then
			PRIVATE.ValidateCacheStorage(true)
		end

		FireCustomClientEvent("STORE_AVAILABILITY_CHANGED")
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isInitialLogin, isReloadingUI = ...
		if isInitialLogin then
			if LOADING_DATA_TIME and LOADING_DATA_TIME > 0 then
				C_CVar:SetSessionCVar("STORE_LOADING_DATA_TIMESTAMP", time())
				FireCustomClientEvent("STORE_AVAILABILITY_CHANGED")
				PRIVATE.StartLoadingTimer()
			end
		end
	elseif event == "PLAYER_LOGIN" then
		PRIVATE.BuildEquipmentSubCategories()

		if LOADING_DATA_TIME and LOADING_DATA_TIME > 0 then
			PRIVATE.StartLoadingTimer()
		end

		PRIVATE.RequestBalance()
		PRIVATE.RequestPremiumInfo()
		PRIVATE.RequestNewCategoryItems()
		PRIVATE.RequestNextSpecialOfferTime()
		PRIVATE.RequestNextTransmogOfferTime()
		PRIVATE.RequestSubscriptions()
		PRIVATE.RequestRefundList()
		PRIVATE.RequestFavoriteList()
	elseif event == "VARIABLES_LOADED" then
		PRIVATE.VARIABLES_LOADED = true

		do -- upgrade storage with data received befora VARIABLES_LOADED
			if type(_G.STORE_PRODUCT_CACHE) == "table" then
				local preloaded = STORE_PRODUCT_CACHE
				STORE_PRODUCT_CACHE = _G.STORE_PRODUCT_CACHE

				for key, value in pairs(preloaded) do
					if type(value) == "table" then
						-- skip product list data to prevent conflicts
					else
						STORE_PRODUCT_CACHE[key] = value
					end
				end
			end

			if type(_G.STORE_DATA_CACHE) == "table" then
				local preloaded = STORE_DATA_CACHE
				STORE_DATA_CACHE = _G.STORE_DATA_CACHE
				PRIVATE.SoftMergeTable(preloaded, STORE_DATA_CACHE)
			end
		end

		if IsInterfaceDevClient() then
			_G.STORE_PRODUCT_CACHE = STORE_PRODUCT_CACHE
			_G.STORE_DATA_CACHE = STORE_DATA_CACHE
			PRIVATE.STORE_PRODUCT_CACHE = STORE_PRODUCT_CACHE
			PRIVATE.STORE_DATA_CACHE = STORE_DATA_CACHE
		else
			_G.STORE_PRODUCT_CACHE = nil
			_G.STORE_DATA_CACHE = nil
		end

		twipe(STORE_DATA_CACHE.ROLLED_ITEM_HASHES)

		if PRIVATE.ValidateCacheStorage() then
			PRIVATE.GenerateProductCacheStorage()
			PRIVATE.PopulateProductListFromCache()
		end

		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Collections, Enum.Store.CollectionType.Mount)
		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Collections, Enum.Store.CollectionType.Pet)
		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Collections, Enum.Store.CollectionType.Illusion)
		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Transmogrification)

		FireCustomClientEvent("STORE_PRODUCTS_CHANGED")

		if PRIVATE.IsCategoryRenewed(Enum.Store.Category.Collections) then
			FireCustomClientEvent("STORE_CATEGORY_NEW_PRODUCTS", Enum.Store.Category.Collections)
		end
	elseif event == "PLAYER_LOGOUT" then
		PRIVATE.RemoveItemInfoFromCache()

		_G.STORE_PRODUCT_CACHE = STORE_PRODUCT_CACHE
		_G.STORE_DATA_CACHE = STORE_DATA_CACHE
	elseif event == "UNIT_LEVEL" then
		local unit = ...
		if unit == "player" then
			local level = UnitLevel("player")
			if level >= 80 then
				PRIVATE.WipeProductCache()
			end
			FireCustomClientEvent("STORE_CATEGORY_INFO_UPDATE")
		end
	end
end)
PRIVATE.EventHandler:SetScript("OnUpdate", function(self, elapsed)
	if next(PRIVATE.QUEUED_PRODUCT_ITEM_INFO) then
		for productList, queuedItemIDs in pairs(PRIVATE.QUEUED_PRODUCT_ITEM_INFO) do
			if not next(queuedItemIDs) then
				PRIVATE.QUEUED_PRODUCT_ITEM_INFO[productList] = nil
			end
			if productList.queuedItemStatsUpdate then
				productList.queuedItemStatsUpdate = nil
				productList.itemStatsUpdate = true
				FireCustomClientEvent("STORE_PRODUCT_LIST_FILTER_UPDATE", productList.categoryIndex, productList.subCategoryIndex, true)
			end
		end
	end

	if next(PRIVATE.OFFER_TIMER) then
		local now = time()
		local index = 1
		local offer = PRIVATE.OFFER_LIST[index]
		while offer do
			local timeLeft = offer.remainingTime + offer.timestamp - now
			if timeLeft > 0 then
				if timeLeft <= OFFER_ALERT_LAST_HOUR_SECONDS
				and not offer.isDynamic
				and not STORE_DATA_CACHE.OFFER_LAST_HOUR_SEEN[offer.offerID]
				then
					STORE_DATA_CACHE.OFFER_LAST_HOUR_SEEN[offer.offerID] = true

					local offerIndex = tIndexOf(PRIVATE.OFFER_LIST, offer)
					if offerIndex then
						FireCustomClientEvent("STORE_SPECIAL_OFFER_ALERT_LAST_HOUR", offerIndex)
					end
				end
				index = index + 1
			else
				PRIVATE.RemoveOfferByID(offer.offerID)
			end
			offer = PRIVATE.OFFER_LIST[index]
		end
	end
end)

PRIVATE.Initialize = function()
	PRIVATE.BuildTransmogItemList()
end

PRIVATE.BuildEquipmentSubCategories = function()
	local equipment = PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Equipment]
	for i, slotInfo in ipairs(INVENTORY_SLOTS) do
		local slotID, textureName, checkRelic = GetInventorySlotInfo(slotInfo[1])
		local name
		if checkRelic and UnitHasRelicSlot("player") then
			name = RELIC_SLOT[1]
			textureName = RELIC_SLOT[2]
		else
			name = slotInfo[2]
		end

		equipment[i] = {
			name = name,
			icon = textureName,
			slotID = slotID,
		}
	end
end

PRIVATE.StartLoadingTimer = function()
	local loadingTimestamp = C_CVar:GetSessionCVar("STORE_LOADING_DATA_TIMESTAMP", nil)
	if loadingTimestamp then
		local timeLeft = (loadingTimestamp + LOADING_DATA_TIME) - time()
		if timeLeft > 0 then
			C_Timer:After(timeLeft, function()
				if C_CVar:GetSessionCVar("STORE_LOADING_DATA_TIMESTAMP", nil) then
					C_CVar:SetSessionCVar("STORE_LOADING_DATA_TIMESTAMP", nil)
					FireCustomClientEvent("STORE_AVAILABILITY_CHANGED")
				end
			end)
		end
	end
end

PRIVATE.LOG = function(...)
	if IsInterfaceDevClient() and _G["DEV_STORE_DEBUG_LOG"] then
		local values = {}
		for i = 1, select("#", ...) do
			local value = select(i, ...)
			if value == nil then
				values[i] = "nil"
			else
				values[i] = value
			end
		end
		print(strconcat("[STORE] ", tconcat(values, " ")))
	end
end

do -- Helpers
	PRIVATE.SoftMergeTable = function(source, target)
		for key, value in pairs(source) do
			if type(value) == "table" and type(target[key]) == "table" then
				PRIVATE.SoftMergeTable(value, target[key])
			else
				target[key] = value
			end
		end
	end

	PRIVATE.SoftMergeUniqueTable = function(source, target)
		for key, value in pairs(source) do
			if type(value) == "table" and type(target[key]) == "table" then
				PRIVATE.SoftMergeUniqueTable(value, target[key])
			elseif target[key] == nil then
				target[key] = value
			end
		end
	end

	PRIVATE.SoftWipeTable = function(t, ignoredKeys)
		for key, value in pairs(t) do
			if not ignoredKeys or not ignoredKeys[key] then
				if type(value) == "table" then
					PRIVATE.SoftWipeTable(value)
				else
					t[key] = nil
				end
			end
		end
	end

	local getPlayerFactionID = function()
		local faction = UnitFactionGroup("player")
		local factionID = PLAYER_FACTION_GROUP[faction]
		return factionID
	end

	PRIVATE.GetPlayerFactionID = function()
		return securecall(getPlayerFactionID)
	end

	PRIVATE.SecureGetGlobalText = function(global, skipEmptyStrings)
		local str = securecall(GetText, global)
		if skipEmptyStrings and str == "" then
			return nil
		end
		return str
	end
end

do -- Product storage
	PRIVATE.ASMSG_SHOP_VERSION = function(msg)
		local version, mountRenewalPrice, petRenewalPrice, illusionRenewalPrice, transmogRenewalPrice = strsplit(":", msg)
		local isReload = mountRenewalPrice == nil

		PRIVATE.VERSION = tonumber(version) or STORE_VERSION_FALLBACK

		PRIVATE.ValidateCacheStorage()

		if mountRenewalPrice then
			STORE_DATA_CACHE.MOUNT_PRICE = tonumber(mountRenewalPrice)
			STORE_DATA_CACHE.PET_PRICE = tonumber(petRenewalPrice)
			STORE_DATA_CACHE.ILLUSION_PRICE = tonumber(illusionRenewalPrice)
			STORE_DATA_CACHE.TRANSMOG_PRICE = tonumber(transmogRenewalPrice)
		end

		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Collections, Enum.Store.CollectionType.Mount)
		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Collections, Enum.Store.CollectionType.Pet)
		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Collections, Enum.Store.CollectionType.Illusion)
		PRIVATE.AddRefreshListProduct(Enum.Store.Category.Transmogrification)

		PRIVATE.RequestNewCategoryItems()

		if isReload then
			FireCustomClientEvent("STORE_RELOADED")
		end
		FireCustomClientEvent("STORE_PRODUCTS_CHANGED")
	end

	PRIVATE.GetProductListVersion = function()
		if PRIVATE.VERSION == STORE_VERSION_FALLBACK then
			if STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION] and STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION] ~= STORE_VERSION_FALLBACK then
				PRIVATE.VERSION = STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION]
			else
				return STORE_VERSION_FALLBACK
			end
		end
		return PRIVATE.VERSION
	end

	PRIVATE.GenerateStorage = function(t, ...)
		for i = 1, select("#", ...) do
			local key = select(i, ...)
			local subTable = t[key]
			if not t[key] then
				subTable = {}
				t[key] = subTable
			end
			t = subTable
		end
		return t
	end

	PRIVATE.GetStorage = function(t, ...)
		for i = 1, select("#", ...) do
			local key = select(i, ...)
			local subTable = t[key]
			if not t[key] then
				return
			end
			t = subTable
		end
		return t
	end

	PRIVATE.GenerateProductCacheStorage = function(wipe)
		if wipe then
			for currencyID, currencyStorage in pairs(STORE_PRODUCT_CACHE) do
				if type(currencyStorage) == "table" then
					for categoryID, categoryStorage in pairs(currencyStorage) do
						PRIVATE.WipeProductStorage(currencyID, categoryID)
					end
				end
			end

			twipe(STORE_PRODUCT_CACHE)
		end

		STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION] = PRIVATE.GetProductListVersion()
		STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.PLAYER_GUID] = UnitGUID("player")

		if wipe
		or (not STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.TTL] or STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.TTL] <= time())
		then
			STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.TTL] = PRODUCT_CACHE_TTL + time()
		end

		local realmStage = C_Service.GetRealmStage()
		if realmStage ~= 0 then
			STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.REALM_STAGE] = realmStage
		end

		if wipe then
			PRIVATE.SignalStoreRenew()
		end
	end

	PRIVATE.WipeProductCache = function()
		PRIVATE.GenerateProductCacheStorage(true)
	end

	PRIVATE.SignalStoreRenew = function()
		for categoryIndex, categoryData in pairs(PRIVATE.CATEGORIES) do
			PRIVATE.SignalCategoryProductsRenew(categoryIndex)
		end
		FireCustomClientEvent("BATTLEPASS_PRODUCT_LIST_RENEW")
	end

	PRIVATE.ValidateCacheStorage = function(isServiceDataUpdate)
		local cacheInvalid

		if (not STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION] or STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION] ~= PRIVATE.GetProductListVersion())
		or (not STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.PLAYER_GUID] or STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.PLAYER_GUID] ~= UnitGUID("player"))
		or (not STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.TTL] or STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.TTL] <= time())
		then
			cacheInvalid = true
		end

		if isServiceDataUpdate then
			local realmStage = C_Service.GetRealmStage()
			if realmStage ~= 0 and realmStage ~= STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.REALM_STAGE] then
				if not PRIVATE.SHOP_ROLLED_TEMS_INFO then
					STORE_DATA_CACHE.COLLECTION_RENEW_TIMESTAMP = nil
					STORE_DATA_CACHE.COLLECTION_RENEW_TIME = nil
					STORE_DATA_CACHE.TRANSMOG_RENEW_TIME = nil

					STORE_DATA_CACHE.MOUNT_RENEW_WEEK = nil

					STORE_DATA_CACHE.CATEGORY_DROP_COUNT_3_1 = nil
					STORE_DATA_CACHE.CATEGORY_DROP_COUNT_3_2 = nil
					STORE_DATA_CACHE.CATEGORY_DROP_COUNT_3_3 = nil
					STORE_DATA_CACHE.CATEGORY_DROP_COUNT_6_1 = nil
				end

				cacheInvalid = true
			end
		end

		if cacheInvalid then
			twipe(STORE_DATA_CACHE.OFFER_LAST_HOUR_SEEN)
			twipe(STORE_DATA_CACHE.EQUIPMENT_ITEM_LEVELS)
			FireCustomClientEvent("STORE_EQUIPMENT_ITEM_LEVELS_OUTDATE")

			PRIVATE.WipeProductCache()

			return false
		end

		return true
	end

	PRIVATE.WipeProductStorage = function(currencyID, categoryID, subCategoryID)
		if subCategoryID then
			local storage = PRIVATE.GenerateStorage(STORE_PRODUCT_CACHE, currencyID, categoryID, subCategoryID)
			for filterIndex, filterData in pairs(storage) do
				for productIndex, productData in ipairs(filterData) do
					if productData[PRODUCT_DATA_FIELD.PRODUCT_ID] then
						PRIVATE.ProductRemove(productData[PRODUCT_DATA_FIELD.PRODUCT_ID])
					end
				end

				twipe(filterData)
			end
		else
			local storage = PRIVATE.GenerateStorage(STORE_PRODUCT_CACHE, currencyID, categoryID)
			for _subCategoryID, subCategoryData in pairs(storage) do
				for filterIndex, filterData in pairs(subCategoryData) do
					for productIndex, productData in ipairs(filterData) do
						if productData[PRODUCT_DATA_FIELD.PRODUCT_ID] then
							PRIVATE.ProductRemove(productData[PRODUCT_DATA_FIELD.PRODUCT_ID])
						end
					end

					twipe(filterData)
				end
			end
		end

		FireCustomClientEvent("STORE_PRODUCTS_CHANGED")
	end

	PRIVATE.IsStorageUpToDate = function(storage, currencyID, categoryID, subCategoryID)
		if not storage[PRODUCT_STORAGE_FIELD.VERSION]
		or storage[PRODUCT_STORAGE_FIELD.VERSION] ~= PRIVATE.GetProductListVersion()
		then
			return false
		end

		if not storage[PRODUCT_STORAGE_FIELD.VERSION_FACTION] then
			return false
		else
			local factionID = PRIVATE.GetPlayerFactionID()
			if storage[PRODUCT_STORAGE_FIELD.VERSION_FACTION] ~= factionID then
				return false
			end
		end

		local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(currencyID, categoryID, subCategoryID)
		if PRIVATE.IsProductRolledCategory(categoryIndex, subCategoryIndex) then
			if not storage[PRODUCT_STORAGE_FIELD.VERSION_ROLLED] or storage[PRODUCT_STORAGE_FIELD.VERSION_ROLLED] ~= PRIVATE.GetRenewalVersion(categoryIndex, subCategoryIndex) then
				return false
			end
		end

		return true
	end

	PRIVATE.GetProductStorageRaw = function(currencyID, categoryID, subCategoryID, filter)
		local storage = PRIVATE.GenerateStorage(STORE_PRODUCT_CACHE, currencyID, categoryID, subCategoryID, filter)
		local dirty = false
		if storage[PRODUCT_STORAGE_FIELD.VERSION] then
			if not PRIVATE.IsStorageUpToDate(storage, currencyID, categoryID, subCategoryID) then
				PRIVATE.WipeProductStorage(currencyID, categoryID, subCategoryID)
				PRIVATE.RequestProducts(currencyID, categoryID, subCategoryID, filter, true, true)
				PRIVATE.LOG("Storage version mismatch", currencyID, categoryID, subCategoryID)
				dirty = true
			end
		else
			PRIVATE.RequestProducts(currencyID, categoryID, subCategoryID, filter, true, true)
			dirty = true
		end
		return storage, dirty
	end

	PRIVATE.GetProductStorage = function(categoryIndex, subCategoryIndex, filter)
		local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)
		return PRIVATE.GetProductStorageRaw(currencyID, categoryID, subCategoryID, filter)
	end

	PRIVATE.IsProductRolledCategory = function(categoryIndex, subCategoryIndex)
		if categoryIndex == Enum.Store.Category.Main then
			if subCategoryIndex == 0 then
				return true
			end
		elseif categoryIndex == Enum.Store.Category.Collections then
			return true
		elseif categoryIndex == Enum.Store.Category.Transmogrification then
			if subCategoryIndex == 1 or subCategoryIndex == 2 or subCategoryIndex == 3 or subCategoryIndex == 4 then
				return true
			end
		end

		return false
	end

	PRIVATE.IsProductRolledCategoryRaw = function(currencyID, categoryID, subCategoryID)
		local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(currencyID, categoryID, subCategoryID)
		return PRIVATE.IsProductRolledCategory(categoryIndex, subCategoryIndex)
	end

	PRIVATE.GetRenewalDropCount = function(categoryIndex, subCategoryIndex)
		local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)
		local dropCount = STORE_DATA_CACHE[strformat("CATEGORY_DROP_COUNT_%i_%i", categoryID, subCategoryID or 0)] or 0
		return dropCount
	end

	PRIVATE.GetRenewalVersion = function(categoryIndex, subCategoryIndex)
		if not PRIVATE.IsProductRolledCategory then
			return nil
		end

		if categoryIndex == Enum.Store.Category.Main then
			return PRIVATE.GetMainRenewalVersion()
		end

		local dropCount = PRIVATE.GetRenewalDropCount(categoryIndex, subCategoryIndex)
		local renewWeek = STORE_DATA_CACHE.MOUNT_RENEW_WEEK or 0
		return strformat("%s.%s", renewWeek, dropCount)
	end

	PRIVATE.GetMainRenewalVersion = function()
		local renewWeek = STORE_DATA_CACHE.MOUNT_RENEW_WEEK or 0
		return strformat("%s.%s", renewWeek, strconcat(
			PRIVATE.GetRenewalDropCount(Enum.Store.Category.Collections, Enum.Store.CollectionType.Mount),
			PRIVATE.GetRenewalDropCount(Enum.Store.Category.Collections, Enum.Store.CollectionType.Pet),
			PRIVATE.GetRenewalDropCount(Enum.Store.Category.Collections, Enum.Store.CollectionType.Illusion),
		--	PRIVATE.GetRenewalDropCount(Enum.Store.Category.Collections, Enum.Store.CollectionType.Toy),
			PRIVATE.GetRenewalDropCount(Enum.Store.Category.Transmogrification, 1)
		))
	end

	PRIVATE.SignalCategoryProductsRenew = function(categoryIndex, subCategoryIndex, suppressEvent)
		local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)
		PRIVATE.WipeProductStorage(currencyID, categoryID, subCategoryID)

		if categoryIndex == Enum.Store.Category.Collections then
			if PRIVATE.COLLECTION_PRODUCT_LIST[subCategoryIndex] then
				twipe(PRIVATE.COLLECTION_PRODUCT_LIST[subCategoryIndex])
				PRIVATE.COLLECTION_PRODUCT_LIST[subCategoryIndex] = nil
			end
		end

		if not suppressEvent then
			PRIVATE.SignalCategoryProductsRenewEvent(categoryIndex, subCategoryIndex)
		end
	end

	PRIVATE.SignalCategoryProductsRenewEvent = function(categoryIndex, subCategoryIndex)
		if categoryIndex == Enum.Store.Category.Transmogrification
		and (subCategoryIndex == TRANSMOG_OFFER_MAIN_SUB_CATEGORY or subCategoryIndex == TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY)
		then
			FireCustomClientEvent("STORE_TRANSMOG_OFFER_RENEW")
		else
			FireCustomClientEvent("STORE_PRODUCT_LIST_RENEW", categoryIndex, subCategoryIndex)
		end
	end

	PRIVATE.ForEachProductFromCache = function(func)
		for currencyID, currencyStorage in pairs(STORE_PRODUCT_CACHE) do
			if type(currencyStorage) == "table" then
				for categoryID, categoryStorage in pairs(currencyStorage) do
					for subCategoryID, subCategoryStorage in pairs(categoryStorage) do
						for filterType, filterStorage in pairs(subCategoryStorage) do
							for productIndex, productData in pairs(filterStorage) do
								if type(productData) == "table" then
									func(productData, currencyID, categoryID, subCategoryID, filterType)
								end
							end
						end
					end
				end
			end
		end
	end

	PRIVATE.PopulateProductListFromCache = function()
		PRIVATE.ForEachProductFromCache(function(productData, currencyID, categoryID, subCategoryID, filterType)
			local productID = productData[PRODUCT_DATA_FIELD.PRODUCT_ID]
			if productID then
				PRIVATE.ProductAdd(productID, productData)
			else
				PRIVATE.WipeProductStorage(currencyID, categoryID, subCategoryID)
			end
		end)
		FireCustomClientEvent("STORE_PRODUCTS_CHANGED")
	end

	PRIVATE.RemoveItemInfoFromCache = function()
		PRIVATE.ForEachProductFromCache(function(productData, currencyID, categoryID, subCategoryID, filterType)
			for key in pairs(PRODUCT_TEMP_FIELDS) do
				productData[key] = nil
			end
		end)
	end

	PRIVATE.ProductAdd = function(productID, productData)
		if PRIVATE.PRODUCT_LIST[productID] then
			if not tCompare(PRIVATE.PRODUCT_LIST[productID], productData) then
				PRIVATE.LOG(strformat("New duplication of productID [%s] has differences", productID))
				PRIVATE.SoftWipeTable(PRIVATE.PRODUCT_LIST[productID], PRODUCT_TEMP_FIELDS)
				PRIVATE.SoftMergeTable(productData, PRIVATE.PRODUCT_LIST[productID])
			end
			PRIVATE.PRODUCT_LIST_DUPS[productID] = (PRIVATE.PRODUCT_LIST_DUPS[productID] or 0) + 1
			return false
		else
			PRIVATE.PRODUCT_LIST[productID] = productData
			return true
		end
	end

	PRIVATE.ProductRemove = function(productID)
		if PRIVATE.PRODUCT_LIST_DUPS[productID] then
			PRIVATE.PRODUCT_LIST_DUPS[productID] = PRIVATE.PRODUCT_LIST_DUPS[productID] - 1
			if PRIVATE.PRODUCT_LIST_DUPS[productID] == 0 then
				PRIVATE.PRODUCT_LIST_DUPS[productID] = nil
			end
			return
		end
		PRIVATE.LOG("remove product", productID)
		PRIVATE.PRODUCT_LIST[productID] = nil
	end

	PRIVATE.GetProductByID = function(productID)
		return PRIVATE.PRODUCT_LIST[productID]
	end

	PRIVATE.GetVirtualProductID = function(productType, uniqueID, uniqueSubID)
		return productType * 100000000 + uniqueID * 100000 + (uniqueSubID or 0)
	end

	PRIVATE.GetProductCategoryInfo = function(product)
		local productCurrencyID = product.currencyID or product[PRODUCT_DATA_FIELD.CURRENCY_ID]
		local productCategoryID = product.categoryID or product[PRODUCT_DATA_FIELD.CATEGORY_ID]
		local productSubCategoryID = product.subCategoryID or product[PRODUCT_DATA_FIELD.SUB_CATEGORY_ID]
		return productCurrencyID, productCategoryID, productSubCategoryID
	end

	PRIVATE.GenerateProductHyperlink = function(product)
		if product.productType == Enum.Store.ProductType.Refund then
			return
		end

		local productCurrencyID, productCategoryID, productSubCategoryID = PRIVATE.GetProductCategoryInfo(product)
		local productID, name

		if product[PRODUCT_DATA_FIELD.PRODUCT_TYPE] then
			productID = product[PRODUCT_DATA_FIELD.PRODUCT_ID]
			name = GetItemInfo(product[PRODUCT_DATA_FIELD.ITEM_ID])
		else
			productID = product.productID

			if product.name then
				name = product.name
			elseif product.itemID then
				name = GetItemInfo(product.itemID)
			end
		end

		return strformat("|cff66bbff|Hstore:%d:%d:%d:%d|h[%s]|h|r", productCurrencyID or 1, productCategoryID or 0, productSubCategoryID or 0, productID or 0, name or UNKNOWN)
	end

	PRIVATE.GetProductHyperlinkInfo = function(link)
		local prefix, currencyID, categoryID, subCategoryID, productID = strsplit(":", link)

		currencyID = tonumber(currencyID)
		categoryID = tonumber(categoryID)
		subCategoryID = tonumber(subCategoryID)
		productID = tonumber(productID)

		if currencyID and categoryID and subCategoryID then
			local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(currencyID, categoryID, subCategoryID)
			local product = productID and PRIVATE.GetProductByID(productID)

			if product and categoryIndex == Enum.Store.Category.Transmogrification then
				subCategoryIndex = product[PRODUCT_DATA_FIELD.SUB_CATEGORY_ID] or subCategoryIndex
			end
			return categoryIndex, subCategoryIndex, product
		end
	end
end

do -- Products
	local tempStorage = {}

	PRIVATE.ASMSG_SHOP_ITEM = function(msg)
		local productID, productInfo = strsplit(":", msg, 2)

		local reqCurrencyID, reqCategoryID, reqSubCategoryID, reqFilters = PRIVATE.RequestGetCurrent()
		if not reqCurrencyID then
			return
		end

		if productID == "0" then -- final
			local categoryID, subCategoryID, currencyID = strsplit(":", productInfo)
			categoryID = tonumber(categoryID)
			subCategoryID = tonumber(subCategoryID)
			currencyID = tonumber(currencyID)

			if reqCurrencyID ~= currencyID or reqCategoryID ~= categoryID or reqSubCategoryID ~= subCategoryID then
				GMError(strformat("Missmatch requested categories (currencyID %s != %s) (categoryID %s != %s) (subCategoryID %s != %s)", reqCurrencyID, currencyID or "nil", reqCategoryID, categoryID or "nil", reqSubCategoryID, subCategoryID or "nil"))
			end

			local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(reqCurrencyID, reqCategoryID, reqSubCategoryID)

			PRIVATE.LOG("ASMSG_SHOP_ITEM", reqCurrencyID, reqCategoryID, reqSubCategoryID, reqFilters, strformat("[NUM_ITEMS=%d]", #tempStorage))

			do
				local storage = PRIVATE.GenerateStorage(STORE_PRODUCT_CACHE, reqCurrencyID, reqCategoryID, reqSubCategoryID, reqFilters)
				twipe(storage)

				storage[PRODUCT_STORAGE_FIELD.VERSION] = PRIVATE.GetProductListVersion()
				storage[PRODUCT_STORAGE_FIELD.VERSION_FACTION] = PRIVATE.GetPlayerFactionID()

				if PRIVATE.IsProductRolledCategory(categoryIndex, subCategoryIndex) then
					storage[PRODUCT_STORAGE_FIELD.VERSION_ROLLED] = PRIVATE.GetRenewalVersion(categoryIndex, subCategoryIndex)
				end

				local isOffer
				if currencyID == Enum.Store.CurrencyType.Bonus
				and categoryID == Enum.Store.Category.Transmogrification
				and (subCategoryID == TRANSMOG_OFFER_MAIN_SUB_CATEGORY or subCategoryID == TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY)
				then
					isOffer = true
				end

				for i, product in ipairs(tempStorage) do
					storage[i] = product

					if isOffer then
						local productType
						if product[PRODUCT_DATA_FIELD.PRODUCT_TYPE] == Enum.Store.ProductType.Item then
							productType = Enum.Store.ProductType.VirtualItem
						else
							productType = product[PRODUCT_DATA_FIELD.PRODUCT_TYPE]
						end
						product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID] = product[PRODUCT_DATA_FIELD.PRODUCT_ID]
						product[PRODUCT_DATA_FIELD.PRODUCT_ID] = PRIVATE.GetVirtualProductID(productType, 0, product[PRODUCT_DATA_FIELD.PRODUCT_ID])
					end

					PRIVATE.ProductAdd(product[PRODUCT_DATA_FIELD.PRODUCT_ID], product)
				end

				twipe(tempStorage)
			end

			PRIVATE.RequestComplete()

			if not QUEARY_ALL_ITEMS and reqFilters == 0 and reqCategoryID == Enum.Store.Category.Transmogrification then
				return
			end

			if currencyID == Enum.Store.CurrencyType.Bonus
			and categoryIndex == Enum.Store.Category.Main
			and subCategoryIndex == 1
			then
				FireCustomClientEvent("STORE_RECOMMENDATION_UPDATE")
			elseif currencyID == Enum.Store.CurrencyType.Bonus
			and reqCategoryID == BATTLEPASS_CATEGORY
			then
				FireCustomClientEvent("BATTLEPASS_PRODUCT_LIST_UPDATE")
			elseif currencyID == Enum.Store.CurrencyType.Bonus
			and categoryIndex == Enum.Store.Category.Transmogrification
			and (reqSubCategoryID == TRANSMOG_OFFER_MAIN_SUB_CATEGORY or reqSubCategoryID == TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY)
			then
				FireCustomClientEvent("STORE_TRANSMOG_OFFER_UPDATE")
				-- invalidate illusion cache
				PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Collections, Enum.Store.CollectionType.Illusion)
			else
				FireCustomClientEvent("STORE_PRODUCT_LIST_UPDATE", categoryIndex, subCategoryIndex)
			end

			FireCustomClientEvent("STORE_PRODUCTS_CHANGED")
		else
			local itemID, itemAmount, price, discount, discountedPrice, creatureID, flags,
				altCurrencyID, altPrice, categoryID, subCategoryID, currencyID, flagsDynamic,
				baseDiscount, baseDiscountedPrice = strsplit(":", productInfo)

			currencyID = tonumber(currencyID) or reqCurrencyID
			categoryID = tonumber(categoryID)
			flagsDynamic = tonumber(flagsDynamic) or 0

			local productType
			if categoryID == BATTLEPASS_CATEGORY then
				productType = Enum.Store.ProductType.BattlePass
			else
				productType = Enum.Store.ProductType.Item
			end

			if reqFilters == 0 then
				flagsDynamic = bitbor(flagsDynamic, PRODUCT_FLAG_DYNAMIC.IS_PERSONAL)
			end

			if currencyID == Enum.Store.CurrencyType.Bonus
			and categoryID == Enum.Store.Category.SpecialServices
			and bitband(flagsDynamic, PRODUCT_FLAG_DYNAMIC.IS_PERSONAL) == 0
			then
				flagsDynamic = bitbor(flagsDynamic, PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT)
			end

			tempStorage[#tempStorage + 1] = {
				[PRODUCT_DATA_FIELD.PRODUCT_TYPE]		= productType,
				[PRODUCT_DATA_FIELD.CURRENCY_ID]		= currencyID,
				[PRODUCT_DATA_FIELD.CATEGORY_ID]		= categoryID,
				[PRODUCT_DATA_FIELD.SUB_CATEGORY_ID]	= tonumber(subCategoryID),

				[PRODUCT_DATA_FIELD.PRODUCT_ID]			= tonumber(productID),
				[PRODUCT_DATA_FIELD.ITEM_ID]			= tonumber(itemID),
				[PRODUCT_DATA_FIELD.ITEM_AMOUNT]		= tonumber(itemAmount),
				[PRODUCT_DATA_FIELD.PRICE]				= tonumber(price),
				[PRODUCT_DATA_FIELD.DISCOUNT]			= discount ~= "0" and tonumber(discount) or nil,
				[PRODUCT_DATA_FIELD.DISCOUNT_PRICE]		= discountedPrice ~= "0" and tonumber(discountedPrice) or nil,
				[PRODUCT_DATA_FIELD.CREATURE_ID]		= creatureID ~= "0" and tonumber(creatureID) or nil,
				[PRODUCT_DATA_FIELD.FLAGS]				= tonumber(flags) or 0,
				[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC]		= flagsDynamic,
				[PRODUCT_DATA_FIELD.ALT_CURRENCY]		= altCurrencyID ~= "0" and tonumber(altCurrencyID) or nil,
				[PRODUCT_DATA_FIELD.ALT_PRICE]			= tonumber(altPrice),
				[PRODUCT_DATA_FIELD.BASE_DISCOUNT_PRICE]= tonumber(baseDiscountedPrice),
				[PRODUCT_DATA_FIELD.BASE_DISCOUNT]		= tonumber(baseDiscount),
			}
		end
	end

	PRIVATE.ASMSG_SHOP_ITEMS_DELETE = function(msg)
		local categoryID, subCategoryID = strsplit(":", msg)
		categoryID = tonumber(categoryID)
		subCategoryID = tonumber(subCategoryID)
		local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(Enum.Store.CurrencyType.Bonus, categoryID, subCategoryID)
		PRIVATE.SignalCategoryProductsRenew(categoryIndex, subCategoryIndex)
	end

	PRIVATE.RequestGetCurrent = function()
		local request = PRIVATE.REQUEST_CURRENT
		if request then
			return unpack(request)
		end
	end

	PRIVATE.RequestInQueue = function(request)
		if PRIVATE.REQUEST_CURRENT and tCompare(PRIVATE.REQUEST_CURRENT, request) then
			return true
		end

		for i, r in ipairs(PRIVATE.REQUEST_QUEUE) do
			if tCompare(r, request) then
				return true
			end
		end

		return false
	end

	PRIVATE.RequestAddToQueue = function(request, queueOffset)
		if PRIVATE.RequestInQueue(request) then
			return
		end

		if not PRIVATE.REQUEST_CURRENT then
			PRIVATE.RequestSend(request)
		else
			if queueOffset and queueOffset ~= 1 then
				if queueOffset > 1 then
					queueOffset = mathmin(queueOffset, #PRIVATE.REQUEST_QUEUE + 1)
				elseif queueOffset < 1 then
					queueOffset = #PRIVATE.REQUEST_QUEUE + 1
				end
			end
			tinsert(PRIVATE.REQUEST_QUEUE, queueOffset or 1, request)
		end

		return true
	end

	PRIVATE.RequestComplete = function()
		if #PRIVATE.REQUEST_QUEUE == 0 then
			local request = PRIVATE.REQUEST_CURRENT
			PRIVATE.REQUEST_CURRENT = nil
		else
			local request = tremove(PRIVATE.REQUEST_QUEUE, 1)
			PRIVATE.RequestSend(request)
		end
	end

	PRIVATE.RequestSend = function(request)
		PRIVATE.REQUEST_CURRENT = request
		PRIVATE.LOG("SHOP_ITEM_LIST_REQUEST", unpack(request, 1, 4))
		SendServerMessage("ACMSG_SHOP_ITEM_LIST_REQUEST", strformat("%i:%i:%i:%i", unpack(request, 1, 4)))
	end

	PRIVATE.RequestProducts = function(currencyID, categoryID, subCategoryID, filter, skipConversion, skipValidation)
		currencyID		= currencyID or Enum.Store.CurrencyType.Bonus
		categoryID		= categoryID or PRIVATE.SELECTED_CATEGORY_INDEX or 0
		subCategoryID	= subCategoryID or PRIVATE.SELECTED_SUB_CATEGORY_INDEX or 0
		filter			= filter or PRIVATE.SELECTED_FILTER or 0

		if not skipConversion then
			local category = PRIVATE.CATEGORIES[categoryID]
			local subCategory = PRIVATE.SUB_CATEGORIES[categoryID] and PRIVATE.SUB_CATEGORIES[categoryID][subCategoryID]

			if category.isVirtual
			or (category.hasOverview and subCategoryID == 0)
			or (subCategory and subCategory.isVirtual)
			then
				return
			end

			currencyID, categoryID = PRIVATE.GetRemoteCategoryIDs(categoryID, subCategoryID)
		end

		local request = {currencyID, categoryID, subCategoryID, filter}
		if PRIVATE.RequestInQueue(request) then
			return
		end

		local storage = PRIVATE.GenerateStorage(STORE_PRODUCT_CACHE, currencyID, categoryID, subCategoryID, filter)
		if storage and not skipValidation and PRIVATE.IsStorageUpToDate(STORE_PRODUCT_CACHE, currencyID, categoryID, subCategoryID) then
			return
		end

		twipe(storage)

		local queueOffset = 1
		local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(currencyID, categoryID, subCategoryID)

		if currencyID == Enum.Store.CurrencyType.Bonus
		and categoryIndex == Enum.Store.Category.Collections
		and subCategoryIndex == Enum.Store.CollectionType.Illusion
		then
			-- request transmog offers if we dont have them
			local transmogOfferStorage, dirty = PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY, 0)
			if dirty then
				queueOffset = queueOffset + 1
			end
			transmogOfferStorage, dirty = PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY, 0)
			if dirty then
				queueOffset = queueOffset + 1
			end
		end

		local success = PRIVATE.RequestAddToQueue(request, queueOffset)
		if not success then
			return
		end

		if not QUEARY_ALL_ITEMS then
			if filter == 0
			and currencyID == Enum.Store.CurrencyType.Bonus
			and categoryID == Enum.Store.Category.Transmogrification
			then
				PRIVATE.RequestAddToQueue({currencyID, categoryID, subCategoryID, 1})
			end
		end

		local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(categoryID, subCategoryID)
		FireCustomClientEvent("STORE_PRODUCT_LIST_LOADING", categoryIndex, subCategoryIndex)
	end

	PRIVATE.GetProductInfo = function(product)
		local productInfo

		if product[PRODUCT_DATA_FIELD.PRODUCT_TYPE] then
			local price, originalPrice, currency, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product)
			local modelType, modelID = PRIVATE.GetProductModelInfo(product)
			local isGiftable

			if PRIVATE.CanGiftProduct(product) then
				isGiftable = Enum.Store.GiftType.Normal
			elseif PRIVATE.CanGiftProductWithLoyality(product) then
				isGiftable = Enum.Store.GiftType.Loyality
			end

			productInfo = {
				productID = product[PRODUCT_DATA_FIELD.PRODUCT_ID],
				productType = product[PRODUCT_DATA_FIELD.PRODUCT_TYPE],
				originalProductID = product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID],

				currencyID = product[PRODUCT_DATA_FIELD.CURRENCY_ID],
				categoryID = product[PRODUCT_DATA_FIELD.CATEGORY_ID],
				subCategoryID = product[PRODUCT_DATA_FIELD.SUB_CATEGORY_ID],

				itemID = product[PRODUCT_DATA_FIELD.ITEM_ID],
				amount = product[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1,

				modelType = modelType,
				modelID = modelID,

				isGiftable = isGiftable,

				currencyType = currency,
				price = price,
				originalPrice = originalPrice,

				altCurrencyType = altCurrencyType,
				altPrice = altPrice,
				altOriginalPrice = altOriginalPrice,
			}

			if productInfo.categoryID == Enum.Store.Category.Transmogrification
			and productInfo.subCategoryID == 4
			then
				productInfo.setProducts = PRIVATE.GenerateTransmogItemSetInfo(productInfo.subCategoryID, productInfo.originalProductID or productInfo.productID, productInfo.originalProductID ~= nil)
			end

			local flags = product[PRODUCT_DATA_FIELD.FLAGS]
			if flags then
				productInfo.isNew = (bitband(flags, PRODUCT_FLAG.NEW) ~= 0)
				productInfo.isPVP = (bitband(flags, PRODUCT_FLAG.PVP) ~= 0)
			--	productInfo.isRecommended = (bitband(flags, PRODUCT_FLAG.RECOMMENDED) ~= 0)
			--	productInfo.isPromotional = (bitband(flags, PRODUCT_FLAG.PROMOTIONAL) ~= 0)
			--	productInfo.isSpecial = (bitband(flags, PRODUCT_FLAG.SPECIAL) ~= 0)
				productInfo.canBuyMultiple = (bitband(flags, PRODUCT_FLAG.MULTIPLE_BUY) ~= 0)
			end
			local flagsDynamic = product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC]
			if flagsDynamic then
				local isRollableUnavailable = (bitband(flagsDynamic, PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0)
				if isRollableUnavailable then
					productInfo.isUnavailable = true
					productInfo.isRollableUnavailable = true
				elseif bitband(flagsDynamic, PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0 then
					if isGiftable then
						productInfo.noPurchaseCanGift = true
					else
						productInfo.isUnavailable = true
					end
				end
			end
		else
			productInfo = CopyTable(product)

			if product.productType == Enum.Store.ProductType.SpecialOffer then
				local offerDetails = PRIVATE.OFFER_DETAIL_LIST[product.offerID]
				if offerDetails then
					productInfo.details = CopyTable(offerDetails)
				end

			--[[
				local originalProduct = PRIVATE.GetProductByID(product.originalProductID)
				if originalProduct then
					local originalProductInfo = PRIVATE.GetProductInfo(originalProduct)
					if originalProductInfo then
						PRIVATE.SoftMergeUniqueTable(originalProductInfo, productInfo)
					end
				end
			--]]
			end
		end

		if productInfo.productType == Enum.Store.ProductType.RenewProductList and productInfo.categoryIndex == Enum.Store.Category.Transmogrification then
			productInfo.refundNotice = STORE_CONFIRM_NOTICE_WARNING_RENEW_LIST
		elseif (productInfo.currencyID == Enum.Store.CurrencyType.Bonus and productInfo.categoryID == Enum.Store.Category.Collections)
		or (productInfo.currencyID == Enum.Store.CurrencyType.Bonus and productInfo.categoryID == Enum.Store.Category.Transmogrification)
		or (productInfo.currencyID == Enum.Store.CurrencyType.Bonus and productInfo.categoryID == Enum.Store.Category.SpecialServices and productInfo.subCategoryID == 6)
		then
			productInfo.refundNotice = STORE_CONFIRM_NOTICE_WARNING_GENERIC
		elseif productInfo.itemID then
			if NO_RETURN_POLICY_ITEMS[productInfo.itemID] then
				productInfo.refundNotice = NO_RETURN_POLICY_ITEMS[productInfo.itemID]
			else
				local createdItemID = C_Item.GetCreatedItemIDByItem(productInfo.itemID)
				if C_Heirloom.IsItemHeirloom(createdItemID or productInfo.itemID) then
					productInfo.refundNotice = STORE_CONFIRM_NOTICE_WARNING_GENERIC
				end
			end
		end

		return productInfo
	end

	PRIVATE.GetProductPrice = function(product, skipOverride)
		local currencyType, price, originalPrice
		local altCurrencyType, altPrice, altOriginalPrice

		if product.productType then
			currencyType = product.currencyType or Enum.Store.CurrencyType.Bonus
			price = product.price
			originalPrice = product.originalPrice
		else
			currencyType = product[PRODUCT_DATA_FIELD.CURRENCY_ID] or Enum.Store.CurrencyType.Bonus

			local override
			if not skipOverride then
				local offer = PRIVATE.GetOfferForProduct(product)
				if offer then
					local offerCurrencyType = offer.currencyType or offer[PRODUCT_DATA_FIELD.CURRENCY_ID] or Enum.Store.CurrencyType.Bonus
					if offerCurrencyType == currencyType then
						local offerPrice = offer.price or offer[PRODUCT_DATA_FIELD.DISCOUNT_PRICE]
						local offerOriginalPrice = offer.originalPrice or offer[PRODUCT_DATA_FIELD.PRICE]
						if offerPrice and offerOriginalPrice then
							price = offerPrice
							originalPrice = offerOriginalPrice
							override = true
						end
					end
				end
			end

			if not override then
				if product[PRODUCT_DATA_FIELD.DISCOUNT] then
					price = product[PRODUCT_DATA_FIELD.DISCOUNT_PRICE]
					originalPrice = product[PRODUCT_DATA_FIELD.PRICE]
				else
					price = product[PRODUCT_DATA_FIELD.PRICE]
					originalPrice = price
				end
			end

			altCurrencyType = product[PRODUCT_DATA_FIELD.ALT_CURRENCY]
			altPrice = product[PRODUCT_DATA_FIELD.ALT_PRICE]
			altOriginalPrice = altPrice
		end

		if currencyType == Enum.Store.CurrencyType.Vote
		or currencyType == Enum.Store.CurrencyType.Loyality
		or currencyType == Enum.Store.CurrencyType.Referral
		then
			originalPrice = price
			altOriginalPrice = altPrice
		end

		return price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
	end

	PRIVATE.GetProductGiftPrice = function(product)
		local canGift = PRIVATE.CanGiftProduct(product)
		local canGiftWithLoyality = PRIVATE.CanGiftProductWithLoyality(product)

		if not canGift and not canGiftWithLoyality then
			return -1, -1, 1, -1, -1, 1
		end

		local productType = product.productType or product[PRODUCT_DATA_FIELD.PRODUCT_TYPE]
		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product, true)

		if productType == Enum.Store.ProductType.SpecialOffer then
			local originalProductID = product.originalProductID or product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID]
			local originalProduct = originalProductID and PRIVATE.GetProductByID(originalProductID)
			if originalProduct then
				price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(originalProduct, true)
			end
		elseif productType == Enum.Store.ProductType.Item then
			local originalProductID = product.originalProductID or product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID]
			if originalProductID then
				local originalDiscountPrice = product[PRODUCT_DATA_FIELD.BASE_DISCOUNT_PRICE]
				if originalDiscountPrice then
					price = originalDiscountPrice
				end
			end
		end

		if canGift then
			return price, originalPrice, currencyType, altCurrencyType, altPrice, altOriginalPrice
		else
			price = price + PRIVATE.CalculateLoyalityGiftMarkup(price)
			return price, originalPrice, currencyType, altCurrencyType, altPrice, altOriginalPrice
		end
	end

	PRIVATE.GetProductDiscount = function(product)
		local discount

		if product.productType then
			discount = product.discount or PRIVATE.CalculateDiscount(PRIVATE.GetProductPrice(product))
		else
			local offer = PRIVATE.GetOfferForProduct(product)
			if offer then
				local currencyType = product.currencyType or product[PRODUCT_DATA_FIELD.CURRENCY_ID] or Enum.Store.CurrencyType.Bonus
				local offerCurrencyType = offer.currencyType or offer[PRODUCT_DATA_FIELD.CURRENCY_ID] or Enum.Store.CurrencyType.Bonus
				if offerCurrencyType == currencyType then
					discount = offer.discount or offer[PRODUCT_DATA_FIELD.DISCOUNT]
				end
			end

			if not discount then
				discount = product[PRODUCT_DATA_FIELD.DISCOUNT]
			end
		end

		return discount or 0
	end

	PRIVATE.CalculateLoyalityGiftMarkup = function(price)
		return mathceil(price * 0.1)
	end

	PRIVATE.CalculateDiscount = function(price, originalPrice, markup)
		if originalPrice == 0 then
			return 0
		end
		return mathceil((1 - price / originalPrice * (markup or 1)) * 100)
	end

	PRIVATE.GetProductModelInfo = function(product)
		local modelType, modelID
		local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(PRIVATE.GetProductCategoryInfo(product))

		if categoryIndex == Enum.Store.Category.Collections and subCategoryIndex == Enum.Store.CollectionType.Illusion then
			modelType = Enum.ModelType.Illusion
			modelID = product[PRODUCT_DATA_FIELD.ITEM_ID]
		elseif categoryIndex == Enum.Store.Category.Transmogrification and (subCategoryIndex == 1 or subCategoryIndex == 2) then
			modelType = Enum.ModelType.ItemTransmog
			modelID = product[PRODUCT_DATA_FIELD.ITEM_ID]
		elseif product[PRODUCT_DATA_FIELD.CREATURE_ID] then
			modelType = Enum.ModelType.Creature
			modelID = product[PRODUCT_DATA_FIELD.CREATURE_ID]
		end

		return modelType, modelID
	end

	PRIVATE.CanGiftProduct = function(product)
		if product[PRODUCT_DATA_FIELD.PRODUCT_TYPE] == Enum.Store.ProductType.Item then
			if product[PRODUCT_DATA_FIELD.ITEM_ID]
			and bitband(product[PRODUCT_DATA_FIELD.FLAGS] or 0, PRODUCT_FLAG.GIFTABLE) ~= 0
			and bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC] or 0, PRODUCT_FLAG_DYNAMIC.FORBID_GIFT) == 0
			then
				return true
			end
		elseif product.productType == Enum.Store.ProductType.SpecialOffer then
			if product.isGiftable or PRIVATE.OFFERS_MODEL_DATA[product.offerID] then
				return true
			end
		end
		return false
	end

	PRIVATE.CanGiftProductWithLoyality = function(product)
		if product[PRODUCT_DATA_FIELD.PRODUCT_TYPE] == Enum.Store.ProductType.Item then
			if product[PRODUCT_DATA_FIELD.ITEM_ID]
			and bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC] or 0, PRODUCT_FLAG_DYNAMIC.FORBID_GIFT) == 0
			and product[PRODUCT_DATA_FIELD.CURRENCY_ID] == Enum.Store.CurrencyType.Bonus
			and product[PRODUCT_DATA_FIELD.CATEGORY_ID] ~= Enum.Store.Category.Subscriptions
			and not PRIVATE.IsOfferProduct(product)
			and not PRIVATE.GetOfferForProduct(product)
			and PRIVATE.GetBalance(Enum.Store.CurrencyType.Loyality) >= 30
			then
				return true
			end
		end
		return false
	end

	PRIVATE.IsOfferProduct = function(product)
		local productType = product.productType or product[PRODUCT_DATA_FIELD.PRODUCT_TYPE]
		local originalProductID = product.originalProductID or product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID]

		if productType == Enum.Store.ProductType.SpecialOffer
		or (productType == Enum.Store.ProductType.Item and originalProductID)
		then
			return true, originalProductID
		end

		return false
	end

	PRIVATE.GetOfferForProduct = function(product)
		if PRIVATE.IsOfferProduct(product) then
			return
		end

		local offer

		local itemID = product.itemID or product[PRODUCT_DATA_FIELD.ITEM_ID]
		if itemID then
			offer = PRIVATE.GetSpecialOfferByItemIDWithMaxDiscount(product[PRODUCT_DATA_FIELD.ITEM_ID], product[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1)
		end

	--[[
		if not offer then
			local originalProductID = product.originalProductID or product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID]
			offer = PRIVATE.GetSpecialOfferByProductID(originalProductID)
		end
	--]]

		if not offer then
			local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(PRIVATE.GetProductCategoryInfo(product))
			if categoryIndex == Enum.Store.Category.Transmogrification
			or (categoryIndex == Enum.Store.Category.Collections and subCategoryIndex == Enum.Store.CollectionType.Illusion)
			then
				offer = PRIVATE.GetTransmogItemOfferForProduct(product, Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY, 0)
					or PRIVATE.GetTransmogItemOfferForProduct(product, Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY, 0)
			end
		end

		return offer
	end
end

do -- Balance
	PRIVATE.ASMSG_SHOP_BALANCE_RESPONSE = function(msg)
		local bonus, vote, referral, referralMax, loyalLevel, loyalMin, loyalMax, loyalCurrent = strsplit(":", msg)

		PRIVATE.BALANCE[Enum.Store.CurrencyType.Bonus] = tonumber(bonus)
		PRIVATE.BALANCE[Enum.Store.CurrencyType.Vote] = tonumber(vote)
		PRIVATE.BALANCE[Enum.Store.CurrencyType.Referral] = tonumber(referral)
		PRIVATE.BALANCE[Enum.Store.CurrencyType.Loyality] = tonumber(loyalLevel)

		PRIVATE.REFERRAL.min = 0
		PRIVATE.REFERRAL.max = tonumber(referralMax)
		PRIVATE.REFERRAL.current = tonumber(referral)

		PRIVATE.LOYALITY.min = tonumber(loyalMin)
		PRIVATE.LOYALITY.max = tonumber(loyalMax)
		PRIVATE.LOYALITY.current = tonumber(loyalCurrent)
		PRIVATE.LOYALITY.level = tonumber(loyalLevel)

		PRIVATE.pendingBalanceInfo = nil
		FireCustomClientEvent("STORE_BALANCE_UPDATE")
	end

	PRIVATE.RequestBalance = function()
		if PRIVATE.pendingBalanceInfo then
			return
		end
		PRIVATE.pendingBalanceInfo = true
		SendServerMessage("ACMSG_SHOP_BALANCE_REQUEST")
	end

	PRIVATE.IsValidCurrencyType = function(currencyType)
		if type(currencyType) == "number" and currencyType > 0 then
			return true
		end
		return false
	end

	PRIVATE.GetCurrencyInfo = function(currencyType)
		local currency = PRIVATE.CURRENCY_INFO[currencyType]
		local texture

		if currencyType == Enum.Store.CurrencyType.ArenaPoint
		or currencyType == Enum.Store.CurrencyType.Honor
		then
			local factionID = C_Unit.GetFactionID("player")
			texture = strconcat(currency.texture, PLAYER_FACTION_GROUP[factionID])
		end

		return currency.name, currency.description, texture or currency.texture, currency.atlas
	end

	PRIVATE.GetBalance = function(currencyType)
		if currencyType == Enum.Store.CurrencyType.Gold then
			return GetMoney()
		end

		return PRIVATE.BALANCE[currencyType] or 0
	end
end

do -- Category
	PRIVATE.ASMSG_SHOP_CATEGORY_NEW_ITEMS_RESPONSE = function(msg)
		PRIVATE.NEW_CATEGORY_ITEMS_AWAIT = nil
		twipe(STORE_DATA_CACHE.HAS_NEW)

		for _, productInfo in ipairs({StringSplitEx("|", msg)}) do
			local currencyID, categoryID, subCategoryID = strsplit(":", productInfo)
			currencyID		= tonumber(currencyID)
			categoryID		= tonumber(categoryID)
			subCategoryID	= tonumber(subCategoryID)

			if currencyID and categoryID then
				if not STORE_DATA_CACHE.HAS_NEW[currencyID] then
					STORE_DATA_CACHE.HAS_NEW[currencyID] = {}
				end
				if not STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID] then
					STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID] = {}
				end
				if subCategoryID then
					STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID][subCategoryID] = true
				end
			end
		end

		if next(STORE_DATA_CACHE.HAS_NEW) then
			local version = PRIVATE.GetProductListVersion()
			local newItemsVersion = STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION_SEEN]
			if newItemsVersion ~= version then
				STORE_PRODUCT_CACHE[PRODUCT_CACHE_FIELD.VERSION_SEEN] = version
				FireCustomClientEvent("STORE_NEW_ITEMS_AVAILABLE")
			end
		end

		FireCustomClientEvent("STORE_CATEGORY_INFO_UPDATE")
	end

	PRIVATE.RequestNewCategoryItems = function()
		if not PRIVATE.NEW_CATEGORY_ITEMS_AWAIT then
			PRIVATE.NEW_CATEGORY_ITEMS_AWAIT = true
			SendServerMessage("ACMSG_SHOP_CATEGORY_NEW_ITEMS_REQUEST")
		end
	end

	PRIVATE.GetRemoteCategoryIDs = function(categoryIndex, subCategoryIndex)
		local category = PRIVATE.CATEGORIES[categoryIndex]
		local currencyID = category.remoteCurrencyID or category.currencyType or Enum.Store.CurrencyType.Bonus
		local categoryID = category.remoteCategoryID or categoryIndex
		return currencyID, categoryID, subCategoryIndex
	end
	PRIVATE.GetVirtualCategoryIDs = function(remoteCurrencyID, remoteCategoryID, remoteSubCategoryID)
		for categoryIndex, category in pairs(PRIVATE.CATEGORIES) do
			if (category.remoteCurrencyID == remoteCurrencyID or (not category.remoteCurrencyID and remoteCurrencyID == 1))
			and category.remoteCategoryID == remoteCategoryID
			then
				return categoryIndex, remoteSubCategoryID
			end
		end
		return remoteCategoryID, remoteSubCategoryID
	end

	PRIVATE.CategoryIsAvailable = function(category)
		if category.isHidden then
			return false, false
		end
		if category.isDisabled then
			return true, false, STORE_CATEGORY_UNAVAILABLE_SERVER
		end
		if type(category.IsAvailablePost) == "function" then
			return category.IsAvailablePost()
		end
		return true, true
	end

	PRIVATE.IsCategoryNew = function(categoryIndex, subCategoryIndex, checkRequirements)
		local currencyID, categoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)

		if STORE_DATA_CACHE.HAS_NEW[currencyID] and STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID] then
			if checkRequirements then
				local category = PRIVATE.CATEGORIES[categoryIndex]
				local visible, enabled, reason = PRIVATE.CategoryIsAvailable(category)
				if enabled then
					if subCategoryIndex then
						if STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID][subCategoryIndex] then
							local subCategory = PRIVATE.SUB_CATEGORIES[categoryIndex][subCategoryIndex]
							visible, enabled, reason = PRIVATE.CategoryIsAvailable(subCategory)
							if enabled then
								return true
							end
						end
					else
						local subCategories = PRIVATE.SUB_CATEGORIES[categoryIndex]
						for _subCategoryIndex in pairs(STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID]) do
							local subCategory = subCategories[_subCategoryIndex]
							if subCategory then
								visible, enabled, reason = PRIVATE.CategoryIsAvailable(subCategory)
								if enabled then
									return true
								end
							end
						end
					end
				end
			else
				if not subCategoryIndex or STORE_DATA_CACHE.HAS_NEW[currencyID][categoryID][subCategoryIndex] then
					return true
				end
			end
		end
		return false
	end

	PRIVATE.GetAdjustedSubCategoryIndex = function(categoryIndex, subCategoryIndex)
		local subCategories = PRIVATE.SUB_CATEGORIES[categoryIndex]
		if subCategories and subCategories[subCategoryIndex] then
			return subCategoryIndex
		else
			return 0
		end
	end

	PRIVATE.SetSelectedCategory = function(categoryIndex, subCategoryIndex, forceEvent)
		if PRIVATE.SELECTED_CATEGORY_ACTION_BLOCKED then
			return
		end

		subCategoryIndex = PRIVATE.GetAdjustedSubCategoryIndex(categoryIndex, subCategoryIndex)

		local category = PRIVATE.CATEGORIES[categoryIndex]
		local subCategories = PRIVATE.SUB_CATEGORIES[categoryIndex]

		if subCategoryIndex == 0 and not category.hasZeroSubCategory and not category.hasOverview and subCategories then
			local index = 1
			local subCategory = subCategories[index]
			if subCategory then
				local visible, enabled, reason = PRIVATE.CategoryIsAvailable(subCategory)
				local found = visible and enabled
				while not found and subCategoryIndex < #subCategories do
					index = index + 1
					subCategory = subCategories[index]

					if subCategory then
						visible, enabled, reason = PRIVATE.CategoryIsAvailable(subCategory)
						found = visible and enabled
						if found then
							break
						end
					else
						break
					end
				end

				if found then
					subCategoryIndex = index -- select first available subCategory
				else
					error("No available subcategories found", 2)
				end
			end
		end

		if subCategoryIndex == PRIVATE.SELECTED_SUB_CATEGORY_INDEX and categoryIndex == PRIVATE.SELECTED_CATEGORY_INDEX then
			if forceEvent then
				PRIVATE.SELECTED_CATEGORY_ACTION_BLOCKED = true
				FireCustomClientEvent("STORE_CATEGORY_SELECTED", categoryIndex, subCategoryIndex)
				PRIVATE.SELECTED_CATEGORY_ACTION_BLOCKED = nil
			end
			return
		end

		if category.isNew and not STORE_DATA_CACHE.SEEN[categoryIndex] then
			STORE_DATA_CACHE.SEEN[categoryIndex] = true
		end

		if subCategoryIndex ~= 0 and subCategories and subCategories[subCategoryIndex] and subCategories[subCategoryIndex].isNew then
			local subCategoryNewIndex = categoryIndex * 100 + subCategoryIndex
			if not STORE_DATA_CACHE.SEEN[subCategoryNewIndex] then
				STORE_DATA_CACHE.SEEN[subCategoryNewIndex] = true
			end
		end

		PRIVATE.SELECTED_CATEGORY_INDEX = categoryIndex
		PRIVATE.SELECTED_SUB_CATEGORY_INDEX = subCategoryIndex

		PRIVATE.SELECTED_CATEGORY_ACTION_BLOCKED = true
		FireCustomClientEvent("STORE_CATEGORY_SELECTED", categoryIndex, subCategoryIndex)
		PRIVATE.SELECTED_CATEGORY_ACTION_BLOCKED = nil
	end

	PRIVATE.IsAnyCategoryRenewed = function()
		if STORE_PRODUCT_CACHE.COLLECTION_RENEWED then
			return true
		end

		return false
	end

	PRIVATE.IsCategoryRenewed = function(categoryIndex)
		if categoryIndex == Enum.Store.Category.Collections and STORE_PRODUCT_CACHE.COLLECTION_RENEWED then
			return true
		end

		return false
	end

	PRIVATE.SetCategoryRenewSeen = function(categoryIndex)
		if categoryIndex == Enum.Store.Category.Collections then
			STORE_PRODUCT_CACHE.COLLECTION_RENEWED = nil
		end
	end
end

do -- Global discounts
	PRIVATE.ASMSG_SHOP_DISCOUNTS = function(msg)
		local currentTime = time()
		local oldDisounts = CopyTable(STORE_DATA_CACHE.GLOBAL_DISCOUNTS)

		twipe(STORE_DATA_CACHE.GLOBAL_DISCOUNTS)

		for discountIndex, discountInfo in ipairs({StringSplitEx("|", msg)}) do
			local discountAmount, secondsLeft, categoryList = strsplit(":", discountInfo)
			secondsLeft = tonumber(secondsLeft) or 0

			local discount = {
				amount = tonumber(discountAmount),
				endTime = secondsLeft > 0 and (secondsLeft + currentTime) or 0,
				categoryList = {},
			}

			for index, categoryInfo in ipairs({StringSplitEx(";", categoryList)}) do
				local categoryID, subCategoryID = strsplit(",", categoryInfo)
				tinsert(discount.categoryList, {
					currencyID = Enum.Store.CurrencyType.Bonus,
					categoryID = tonumber(categoryID),
					subCategoryID = tonumber(subCategoryID),
				})
			end

			tinsert(STORE_DATA_CACHE.GLOBAL_DISCOUNTS, discount)
		end

		if PRIVATE.IsGlobalDiscountChanged(oldDisounts) then
			PRIVATE.WipeProductCache()
		end

		FireCustomClientEvent("STORE_GLOBAL_DISCOUNT_UPDATE")
	end

	PRIVATE.IsGlobalDiscountChanged = function(oldGlobalDiscount)
		if #oldGlobalDiscount ~= #STORE_DATA_CACHE.GLOBAL_DISCOUNTS then
			return true
		end

		for discountIndex, discount in ipairs(oldGlobalDiscount) do
			local currentDiscount = STORE_DATA_CACHE.GLOBAL_DISCOUNTS[discountIndex]
			if not currentDiscount
			or discount.amount ~= currentDiscount.amount
			or not tCompare(discount.categoryList, currentDiscount.categoryList)
			then
				return true
			end
		end

		return false
	end

	PRIVATE.GetCategoryGlobalDiscount = function(categoryIndex, subCategoryIndex)
		local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)

		for discountIndex, discount in ipairs(STORE_DATA_CACHE.GLOBAL_DISCOUNTS) do
			for categoryDataIndex, categoryData in ipairs(discount.categoryList) do
				if categoryData.currencyID == currencyID then
					-- 1:0 - all subCategories for 1 categoryID
					-- 0:1 - all categoryID for 1 subCategoryID
					if (categoryData.categoryID == categoryID and categoryData.subCategoryID == 0)
					or (categoryData.subCategoryID == subCategoryID and categoryData.categoryID == 0)
					then
						local timeLeft
						if discount.endTime > 0 then
							timeLeft = mathmax(0, discount.endTime - time())
						else
							timeLeft = 0
						end
						return discount.amount, timeLeft
					end
				end
			end
		end
	end
end

do -- Premium
	PRIVATE.RequestPremiumInfo = function()
		if PRIVATE.PREMIUM_INFO_AWAIT then
			return false
		end

		PRIVATE.PREMIUM_INFO_AWAIT = true
		SendServerMessage("ACMSG_PREMIUM_INFO_REQUEST")

		return true
	end

	PRIVATE.ASMSG_PREMIUM_INFO_RESPONSE = function(msg)
		PRIVATE.PREMIUM_INFO_AWAIT = nil

		local remainingTime = tonumber(msg)

		if remainingTime and remainingTime > 0 then
			if remainingTime >= PREMIUM_PERMANENT_TIME then
				PRIVATE.PREMIUM_REMAINING_TIME = STORE_PERMANENT_PREMIUM
			else
				PRIVATE.PREMIUM_REMAINING_TIME = remainingTime
				PRIVATE.PREMIUM_REQUEST_TIME = time()
			end
		else
			PRIVATE.PREMIUM_REMAINING_TIME = 0
		end

		FireCustomClientEvent("STORE_PREMIUM_UPDATE")
	end

	PRIVATE.ASMSG_PREMIUM_RENEW_RESPONSE = function(msg)
		PRIVATE.pendingPremiumPurchase = nil

		if msg == "ERROR_BALANCE" then
			FireCustomClientEvent("STORE_ERROR", STORE_BUY_PREMIUM_ERROR_1)
			FireCustomClientEvent("STORE_PREMIUM_PURCHASE_FAILED")
		elseif msg == "OK" then
			FireCustomClientEvent("STORE_PREMIUM_PURCHASED")
		end
	end

	PRIVATE.UpdatePremiumRemainingTime = function()
		if PRIVATE.PREMIUM_REQUEST_TIME then
			PRIVATE.PREMIUM_REMAINING_TIME = PRIVATE.PREMIUM_REMAINING_TIME - (time() - PRIVATE.PREMIUM_REQUEST_TIME)
		end
	end

	PRIVATE.PurchasePremium = function(optionIndex)
		if PRIVATE.pendingPremiumPurchase then
			return
		end
		PRIVATE.pendingPremiumPurchase = true
		SendServerMessage("ACMSG_PREMIUM_RENEW_REQUEST", optionIndex)
	end
end

do -- Refund
	PRIVATE.SortRefunds = function(a, b)
		if a.remainingTime ~= b.remainingTime then
			return a.remainingTime < b.remainingTime
		end
		return a.itemGUID < b.itemGUID
	end

	PRIVATE.ASMSG_SHOP_REFUNDABLE_PURCHASE_LIST = function(msg)
		PRIVATE.REFUND_LIST_AWAIT = nil
		PRIVATE.REFUND_BLOCK_UPDATE = nil
		twipe(PRIVATE.REFUND_LIST)

		if msg ~= "" then
			local requestTime = time()

			for _, itemInfo in ipairs({StringSplitEx("|", msg)}) do
				local itemGUID, bag, slot, purchaseDate, remainingTime, originalPrice, penalty, refundCurrencyAmount, refundCurrencyType = strsplit(":", itemInfo)
				if itemGUID and bag and slot then
					local itemID, itemLink

					bag = tonumber(bag)
					slot = tonumber(slot)
					penalty = tonumber(penalty) or 0
					refundCurrencyAmount = tonumber(refundCurrencyAmount) or 0
					originalPrice = tonumber(originalPrice) or 0

					if bag == 255 then
						itemID = GetInventoryItemID("player", slot)
						itemLink = GetInventoryItemLink("player", slot)
					else
						itemID = GetContainerItemID(bag, slot)
						itemLink = GetContainerItemLink(bag, slot)
					end

					if penalty == 0 then
						originalPrice = refundCurrencyAmount
					else
						originalPrice = originalPrice
					end

					local currencyType
					if refundCurrencyType == "0" then
						currencyType = Enum.Store.CurrencyType.Bonus
					else
						currencyType = tonumber(refundCurrencyType)
					end

					tinsert(PRIVATE.REFUND_LIST, {
						productType		= Enum.Store.ProductType.Refund,

					--	bag				= bag,
					--	slot			= slot,

						penalty			= penalty,
						purchaseDate	= purchaseDate,
						remainingTime	= tonumber(remainingTime),

						currencyType	= currencyType,
						price			= refundCurrencyAmount,
						originalPrice	= originalPrice,

						itemGUID		= itemGUID,
						itemID			= itemID,
						itemLink		= itemLink,
						requestTime		= requestTime,
					})
				end
			end

			tsort(PRIVATE.REFUND_LIST, PRIVATE.SortRefunds)
		end

		FireCustomClientEvent("STORE_REFUND_LIST_UPDATE")
	end

	PRIVATE.ASMSG_SHOP_PURCHASE_REFUND_RESPONSE = function(msg)
		PRIVATE.REFUND_RESULT_AWAIT = nil

		local success, errorList
		local refundCurrencyTypes = {}

		for _, productData in ipairs({strsplit(";", msg)}) do
			local status, itemGUID, altCurrencyType = strsplit(":", productData)
			status = tonumber(status)

			if status == REFUND_STATUS.OK then
				success = true

				local currencyType
				if altCurrencyType == "0" then
					currencyType = Enum.Store.CurrencyType.Bonus
				elseif currencyType ~= "" then
					currencyType = tonumber(altCurrencyType)
				end

				if not tIndexOf(refundCurrencyTypes, currencyType) then
					tinsert(refundCurrencyTypes, currencyType)
				end
			else
				if not errorList then
					errorList = {}
				end

				for _, item in ipairs(PRIVATE.REFUND_LIST) do
					if item.itemGUID == itemGUID then
						tinsert(errorList, strformat(PRIVATE.SecureGetGlobalText("STORE_REFUND_STATUS_ERROR_"..status), item.itemLink or strformat("|cffFFD200%s|r", itemGUID)))
						break
					end
				end
			end
		end

		if errorList then
			FireCustomClientEvent("STORE_REFUND_ERROR", tconcat("\n", errorList))
		end

		if success then
			tsort(refundCurrencyTypes)
			FireCustomClientEvent("STORE_REFUND_SUCCESS", refundCurrencyTypes)
		end

		FireCustomClientEvent("STORE_REFUND_READY")
		PRIVATE.RequestRefundList(true)
	end

	PRIVATE.RequestRefundList = function(listChanged)
		if PRIVATE.REFUND_LIST_AWAIT then
			return false
		end

		PRIVATE.REFUND_LIST_AWAIT = true
		FireCustomClientEvent("STORE_REFUND_LIST_WAIT")
		SendServerMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST")
		return true
	end

	PRIVATE.RequestRefundItemGUID = function(...)
		if PRIVATE.REFUND_RESULT_AWAIT then
			return false
		end

		PRIVATE.REFUND_RESULT_AWAIT = true
		FireCustomClientEvent("STORE_REFUND_WAIT")
		SendServerMessage("ACMSG_SHOP_PURCHASE_REFUND", strjoin(":", ...))

		return true
	end

	PRIVATE.RemoveRefundCheckBlocker = function()
		PRIVATE.REFUND_BLOCK_UPDATE = nil
	end

	PRIVATE.CheckRefundProductTimers = function()
		if PRIVATE.REFUND_BLOCK_UPDATE then
			return
		end

		local listChanged
		local now = time()
		local index = #PRIVATE.REFUND_LIST
		local product = PRIVATE.REFUND_LIST[index]
		while product do
			if product.remainingTime - (now - product.requestTime) <= 0 then
				tremove(PRIVATE.REFUND_LIST, index)
				listChanged = true
			else
				index = index - 1
			end
			product = PRIVATE.REFUND_LIST[index]
		end

		PRIVATE.REFUND_BLOCK_UPDATE = true
		if listChanged then
			PRIVATE.RequestRefundList(true)
		else
			RunNextFrame(PRIVATE.RemoveRefundCheckBlocker)
		end
	end

	PRIVATE.IsItemRefundable = function(itemID)
		for _, product in ipairs(PRIVATE.REFUND_LIST) do
			if product.itemID == itemID then
				return product.remainingTime - (time() - product.requestTime) > 0
			end
		end
		return false
	end
end

do -- Equipment
	PRIVATE.RequestEquipmentItemLevels = function()
		if PRIVATE.EQUIPMENT_ITEM_LEVELS_AWAIT
		or next(STORE_DATA_CACHE.EQUIPMENT_ITEM_LEVELS)
		then
			return false
		end

		PRIVATE.EQUIPMENT_ITEM_LEVELS_AWAIT = true
		FireCustomClientEvent("STORE_EQUIPMENT_ITEM_LEVELS_WAIT")
		SendServerMessage("ACMSG_SHOP_EQUIPMENT_ITEM_LEVELS")

		return true
	end

	PRIVATE.ASMSG_SHOP_EQUIPMENT_ITEM_LEVELS = function(msg)
		PRIVATE.EQUIPMENT_ITEM_LEVELS_AWAIT = nil

		if msg == "" then
			return
		end

		twipe(STORE_DATA_CACHE.EQUIPMENT_ITEM_LEVELS)

		for subCategoryIndex, itemLevel in ipairs({strsplit(":", msg)}) do
			STORE_DATA_CACHE.EQUIPMENT_ITEM_LEVELS[subCategoryIndex] = tonumber(itemLevel)
		end

		FireCustomClientEvent("STORE_EQUIPMENT_ITEM_LEVELS_READY")
	end

	PRIVATE.GetEquipedItemLevelByStoreSlotIndex = function(slotIndex)
		local slotInfo = INVENTORY_SLOTS[slotIndex]
		local slotID, textureName, checkRelic = GetInventorySlotInfo(slotInfo[1])
		local link = GetInventoryItemLink("player", slotID)

		if not link then
			if slotInfo[1] == "SecondaryHandSlot" then
				slotID, textureName, checkRelic = GetInventorySlotInfo("MainHandSlot")
				link = GetInventoryItemLink("player", slotID)
				if not link then
					return 0
				end

				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = C_Item.GetItemInfo(link, false, nil, true, true)
				if itemEquipLoc == "INVTYPE_2HWEAPON" then
					return itemLevel
				end
			end

			return 0
		end

		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = C_Item.GetItemInfo(link, false, nil, true, true)
		return itemLevel or 0
	end

	PRIVATE.HasEquipmentSlotUpgradeItems = function(subCategoryIndex)
		if PRIVATE.EQUIPMENT_ITEM_LEVELS_AWAIT then
			return false
		end

		local availableItemLevel = STORE_DATA_CACHE.EQUIPMENT_ITEM_LEVELS[subCategoryIndex]
		if not availableItemLevel or availableItemLevel <= 0 then
			return false
		end

		return availableItemLevel > PRIVATE.GetEquipedItemLevelByStoreSlotIndex(subCategoryIndex)
	end
end

do -- Offer
	PRIVATE.SortSpecialOffers = function(a, b)
		if PRIVATE.OFFERS_MODEL_DATA[a.offerID] ~= PRIVATE.OFFERS_MODEL_DATA[b.offerID] then
			return not PRIVATE.OFFERS_MODEL_DATA[b.offerID]
		end

		if a.timestamp ~= b.timestamp then
			return a.timestamp > b.timestamp
		end

		if a.remainingTime ~= b.remainingTime then
			return a.remainingTime > b.remainingTime
		end

		return a.name < b.name
	end

	PRIVATE.RemoveOfferByID = function(offerID, skipReusable)
		local offer = PRIVATE.OFFER_MAP[offerID]
		if offer then
			if skipReusable and offer.isReusable then
				return
			end

			PRIVATE.ProductRemove(offer.productID)

			PRIVATE.OFFER_MAP[offerID] = nil
			STORE_DATA_CACHE.OFFER_LAST_HOUR_SEEN[offerID] = nil

			local offerListIndex = tIndexOf(PRIVATE.OFFER_LIST, offer)
			if offerListIndex then
				tremove(PRIVATE.OFFER_LIST, offerListIndex)
			end

			FireCustomClientEvent("STORE_SPECIAL_OFFER_UPDATE", offer.offerID, true)

			PRIVATE.OFFER_POPUP_DATA[offerID] = nil

			local offerPopupIndex = tIndexOf(PRIVATE.OFFER_POPUP_SMALL_LIST, offerID)
			if offerPopupIndex then
				tremove(PRIVATE.OFFER_POPUP_DATA, offerPopupIndex)
				FireCustomClientEvent("STORE_SPECIAL_OFFER_POPUP_SMALL_HIDE", offerID)
			end

			FireCustomClientEvent("STORE_PRODUCTS_CHANGED")

			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Main)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Equipment)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Collections)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.SpecialServices)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Transmogrification)
		end
	end

	PRIVATE.RequestNextSpecialOfferTime = function()
		if not PRIVATE.SPECIAL_OFFER_NEXT_AWAIT then
			PRIVATE.SPECIAL_OFFER_NEXT_AWAIT = true
			FireCustomClientEvent("STORE_SPECIAL_OFFER_NEXT_TIMER_WAIT")
			SendServerMessage("ACMSG_SHOP_SPECIAL_OFFER_NEXT_TIMER")
		end
	end

	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_NEXT_TIMER = function(msg)
		local remainingTime = tonumber(msg)
		if remainingTime then
			STORE_DATA_CACHE.SPECIAL_OFFER_NEXT_TIMESTAMP = time() + remainingTime
		else
			STORE_DATA_CACHE.SPECIAL_OFFER_NEXT_TIMESTAMP = nil
		end
		PRIVATE.SPECIAL_OFFER_NEXT_AWAIT = nil
		FireCustomClientEvent("STORE_SPECIAL_OFFER_NEXT_TIMER_READY")
	end

	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_INFO = function(msg)
		local offerID, offerStr = strsplit("|", msg, 2)
		offerID = tonumber(offerID)

		if offerID then
			local isNewOffer
			local offer = PRIVATE.OFFER_MAP[offerID]
			if not offer then
				offer = {}
				isNewOffer = true
			end

			local background, title, name, description, remainingTime,
				productID, itemID, price, discount, discountPrice, flags = strsplit("|", offerStr)

			productID = tonumber(productID)
			price = tonumber(price) or 0
			discount = tonumber(discount) or 0
			discountPrice = tonumber(discountPrice) or 0
			flags = tonumber(flags) or 0

			offer.productType		= Enum.Store.ProductType.SpecialOffer

			offer.productID			= PRIVATE.GetVirtualProductID(offer.productType, 0, productID)
			offer.originalProductID	= productID
			offer.offerID			= offerID
			offer.itemID			= tonumber(itemID)

			offer.background		= background
			offer.title				= title
			offer.name				= name
			offer.description		= description
			offer.remainingTime		= tonumber(remainingTime) or -1
			offer.timestamp			= time()

			offer.currencyType		= Enum.Store.CurrencyType.Bonus
			offer.discount			= discount

			if offer.discount ~= 0 then
				offer.price			= discountPrice
				offer.originalPrice	= price
			else
				offer.price			= price
				offer.originalPrice	= price
			end

			offer.flags				= flags
			offer.hasSpecOptions	= bitband(flags, OFFER_FLAG.SPEC_SELECTABLE) ~= 0
			offer.isFreeSubscribe	= bitband(flags, OFFER_FLAG.SUBSCRIPTION) ~= 0
			offer.isReusable		= bitband(flags, OFFER_FLAG.MULTI_PAYABLE) ~= 0
			offer.isDynamic			= bitband(flags, OFFER_FLAG.REGULAR) ~= 0
			offer.isGiftable		= (bitband(flags, OFFER_FLAG.GIFTABLE) ~= 0 or PRIVATE.OFFERS_MODEL_DATA[offerID] ~= nil) and Enum.Store.GiftType.Normal

			if isNewOffer then
				tinsert(PRIVATE.OFFER_LIST, offer)
				PRIVATE.OFFER_MAP[offerID] = offer
			end

			PRIVATE.ProductAdd(offer.productID, offer)

			tsort(PRIVATE.OFFER_LIST, PRIVATE.SortSpecialOffers)

			FireCustomClientEvent("STORE_SPECIAL_OFFER_UPDATE", offer.offerID, isNewOffer)
			FireCustomClientEvent("STORE_PRODUCTS_CHANGED")

			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Main)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Equipment)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Collections)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.SpecialServices)
			PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Transmogrification)
		end

		if PRIVATE.OFFER_LIST_AWAIT then
			PRIVATE.OFFER_LIST_AWAIT = nil
			FireCustomClientEvent("STORE_SPECIAL_OFFER_LIST_READY")
		end
	end

	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_REMOVE = function(msg)
		local offerID = tonumber(msg)
		if offerID then
			PRIVATE.RemoveOfferByID(offerID)
		end
	end

	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_DETAILS = function(msg)
		local offerID, title, description, price, itemData = strsplit("|", msg)
		offerID = tonumber(offerID)
		price = tonumber(price)

		if offerID and title and description and price then
			local offerDetails = PRIVATE.OFFER_DETAIL_LIST[offerID]
			if offerDetails then
				twipe(offerDetails.items)
			else
				offerDetails = {items = {}}
				PRIVATE.OFFER_DETAIL_LIST[offerID] = offerDetails
			end

			offerDetails.productType	= Enum.Store.ProductType.SpecialOffer

			offerDetails.title			= title
			offerDetails.description	= description

			offerDetails.currencyType	= Enum.Store.CurrencyType.Bonus
			offerDetails.price			= price
			offerDetails.originalPrice	= price

			if itemData then
				for _, itemInfo in ipairs({strsplit(":", itemData)}) do
					local itemID, role, amount = strmatch(itemInfo, "(%d+)<(%d+)><(%d+)>")
					itemID = tonumber(itemID)
					role = tonumber(role)
					amount = tonumber(amount)

					if itemID and role and amount then
						if not offerDetails.items[role] then
							offerDetails.items[role] = {}
						end

						local isCurrency
						if itemID == 0 then	-- currency
							amount = mathfloor(amount / 10000)
							isCurrency = true
						end

						tinsert(offerDetails.items[role], {
							itemID	= itemID,
							amount	= amount,
							isCurrency = isCurrency,
						})
					end
				end
			end
		end
	end

	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_POPUP_SMALL = function(msg)
		local offerID, text = strsplit("|", msg)
		offerID = tonumber(offerID)

		if not offerID then
			return
		end

		local offer = PRIVATE.OFFER_POPUP_DATA[offerID]
		if not offer then
			offer = {}
			PRIVATE.OFFER_POPUP_DATA[offerID] = offer
		end

		offer.text = text

		local offerIndex = tIndexOf(PRIVATE.OFFER_POPUP_SMALL_LIST, offerID)
		if not offerIndex then
			offerIndex = #PRIVATE.OFFER_POPUP_SMALL_LIST + 1
			PRIVATE.OFFER_POPUP_SMALL_LIST[offerIndex] = offerID
		end

		PRIVATE.OFFER_IS_NEW[offerID] = true

		FireCustomClientEvent("STORE_SPECIAL_OFFER_POPUP_SMALL_SHOW", offerIndex)
	end

	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_DATA_READY = function(msg)
		PRIVATE.RequestSpecialOfferInfo()
	end

	local loadstring = loadstring
	PRIVATE.ASMSG_SHOP_SPECIAL_OFFER_POPUP = function(msg)
		if strsub(msg, 1, 1) == "~" then
			-- SpecialOffer call
			local successLS, resFunc = pcall(loadstring, strsub(msg, 2))
			if not successLS then
				GMError(strconcat("[ASMSG_SHOP_SPECIAL_OFFER_POPUP] loadstring compilation error:", resFunc))
				return
			end

			local success, resExec = pcall(resFunc)
			if not success then
				GMError(strconcat("[ASMSG_SHOP_SPECIAL_OFFER_POPUP] loadstring call error:", resExec))
				return
			end
		else
			local texture, title, name, description, id, remainingTime, itemStr = strsplit("|", msg, 7)
			local items = {}

			if itemStr then
				local itemData = strsplit("|", itemStr)
				local itemIndex = 1
				for i = 1, #itemData, 2 do
					local itemID = itemData[i]
					local amount = itemData[i + 1]

					items[itemIndex] = {tonumber(itemID), tonumber(amount) or 0}
					itemIndex = itemIndex + 1
				end
			end

			local offer = PRIVATE.OFFER_POPUP_FULLSCREEN
			offer.productType	= Enum.Store.ProductType.SpecialOfferFS
			offer.id			= tonumber(id)
			offer.texture		= texture
			offer.title			= title
			offer.name			= name
			offer.description	= description
			offer.remainingTime	= tonumber(remainingTime)
			offer.timestamp		= time()
			offer.items			= items

			if PRIVATE.OFFER_POPUP_FULLSCREEN_ENABLED then
				FireCustomClientEvent("STORE_OFFER_POPUP_FULLSCREEN")
			end
		end
	end

	PRIVATE.RequestSpecialOfferInfo = function()
		if not PRIVATE.OFFER_LIST_AWAIT then
			PRIVATE.OFFER_LIST_AWAIT = true
			FireCustomClientEvent("STORE_SPECIAL_OFFER_LIST_WAIT")
			SendServerMessage("ACMSG_SHOP_SPECIAL_OFFER_LIST_REQUEST")
		end
	end

	PRIVATE.GetSpecialOfferByItemID = function(itemID)
		for offerIndex, offer in ipairs(PRIVATE.OFFER_LIST) do
			if offer.itemID == itemID then
				return offer
			end
		end
	end

	PRIVATE.GetSpecialOfferByItemIDWithMaxDiscount = function(itemID, amount)
		local bestOffer
		for offerIndex, offer in ipairs(PRIVATE.OFFER_LIST) do
			if offer.itemID == itemID then
				if not bestOffer or bestOffer.discount < offer.discount then
					if amount <= 1 then
						bestOffer = offer
					else
						local offerDetails = PRIVATE.OFFER_DETAIL_LIST[offer.offerID]
						if offerDetails and offerDetails.items and offerDetails.items[0] and #offerDetails.items[0] == 1 then
							if offerDetails.items[0][1].amount == amount then
								bestOffer = offer
							end
						end
					end
				end
			end
		end
		return bestOffer
	end

	PRIVATE.GetSpecialOfferByProductID = function(productID)
		for offerIndex, offer in ipairs(PRIVATE.OFFER_LIST) do
			if offer.originalProductID and offer.originalProductID == productID then
				return offer
			end
		end
	end
end

do -- PromoCode
	PRIVATE.ASMSG_PROMOCODE_REWARD = function(msg)
		local isValid = strfind(msg, "|", 1, true)

		local code = PRIVATE.PROMO_CODE_ACTIVATE_AWAIT

		if isValid then
			if not PRIVATE.PROMO_CODE_ITEMS[code] then
				PRIVATE.PROMO_CODE_ITEMS[code] = {}
			else
				twipe(PRIVATE.PROMO_CODE_ITEMS[code])
			end

			local itemList = {strsplit("|", msg)}
			local canActivate = tremove(itemList) == "1"

			for _, itemDataStr in ipairs(itemList) do
				local itemType, itemID, amount = strsplit(":", itemDataStr)
				tinsert(PRIVATE.PROMO_CODE_ITEMS, {
					itemType = itemType,
					itemID = itemID,
					amount = amount,
				})
			end

			PRIVATE.PROMO_CODE_LAST_VALID = code
			FireCustomClientEvent("STORE_PROMOCODE_ITEMLIST", code, canActivate)
		else
			if PRIVATE.PROMO_CODE_ITEMS[code] then
				twipe(PRIVATE.PROMO_CODE_ITEMS[code])
				PRIVATE.PROMO_CODE_ITEMS[code] = nil
			end

			PRIVATE.PROMO_CODE_LAST_VALID = nil

			local errorID = tonumber(msg)
			if errorID then
				FireCustomClientEvent("STORE_PROMOCODE_ERROR", PRIVATE.SecureGetGlobalText("STORE_PROMOCODE_REWARD_ERROR_"..errorID))
			end
		end

		PRIVATE.PROMO_CODE_ACTIVATE_AWAIT = nil
		FireCustomClientEvent("STORE_PROMOCODE_READY")
	end
	PRIVATE.ASMSG_PROMOCODE_SUBMIT = function(msg)
		local status, message = strsplit(":", msg)
		status = tonumber(status)

		local code = PRIVATE.PROMO_CODE_CLAIM_AWAIT
		if PRIVATE.PROMO_CODE_ITEMS[code] then
			twipe(PRIVATE.PROMO_CODE_ITEMS[code])
			PRIVATE.PROMO_CODE_ITEMS[code] = nil
		end

		if message then
			FireCustomClientEvent("STORE_PROMOCODE_REWARD_CLAIMED", code, message)
		else
			FireCustomClientEvent("STORE_PROMOCODE_ERROR", PRIVATE.SecureGetGlobalText("STORE_PROMOCODE_SUBMIT_ERROR_"..status))
		end

		PRIVATE.PROMO_CODE_CLAIM_AWAIT = nil
		FireCustomClientEvent("STORE_PROMOCODE_READY")
	end
end

do -- Subscription
	local tempStorage = {}

	PRIVATE.ASMSG_SHOP_SUBSCRIPTION_INFO = function(msg)
		local category = PRIVATE.CATEGORIES[Enum.Store.Category.Subscriptions]
		if tonumber(msg) == -1 then
			category.isDisabled = true
			FireCustomClientEvent("STORE_CATEGORY_INFO_UPDATE", Enum.Store.Category.Subscriptions)
			return
		end

		local status, subscriptionInfoStr = strsplit(":", msg, 2)
		if status == "1" then
			PRIVATE.SUBSCRIPTION_LIST_LOADING = true
			FireCustomClientEvent("STORE_SUBSCRIPTION_LIST_LOADING", true)
			twipe(tempStorage)
		elseif not PRIVATE.SUBSCRIPTION_LIST_LOADING then
			if status == "3" then
				PRIVATE.pendingSubscriptionInfo = nil
				PRIVATE.RequestSubscriptions()
			end
			return
		end

		category.isDisabled = nil

		if subscriptionInfoStr and subscriptionInfoStr ~= "" then
			tinsert(tempStorage, subscriptionInfoStr)
		end

		if status ~= "3" then
			return
		end

		PRIVATE.WipeSubscriptions()

		local timestamp = time()

		for index, subscriptionInfo in ipairs(tempStorage) do
			local headerStr, dailyItemStr, onSubscribeItemStr = strmatch(subscriptionInfo, "(.*):EVERYDAY:(.*):ONSUBSCRIBE:(.*)")
			local subscriptionID, priceShort, priceLong, priceExtra, flags, remainingDays, nextSupplySeconds, trialAvailable, trialActive, extraActive, name, description = strsplit(":", headerStr)

			local dailyItems = {}
			local onSubscribeItems = {}

			do
				local items = {strsplit(":", dailyItemStr)}
				for i = 1, #items, 2 do
					if not items[i + 1] then
						break
					end

					local itemID = tonumber(items[i])
					local amount = tonumber(items[i + 1])

					if itemID and itemID > 0 and amount and amount > 0 then
						tinsert(dailyItems, {
							itemID = itemID,
							amount = amount,
						})
					end
				end
			end
			do
				local items = {strsplit(":", onSubscribeItemStr)}
				for i = 1, #items, 2 do
					if not items[i + 1] then
						break
					end

					local itemID = tonumber(items[i])
					local amount = tonumber(items[i + 1])

					if itemID and itemID > 0 and amount and amount > 0 then
						tinsert(onSubscribeItems, {
							itemID = itemID,
							amount = amount,
						})
					end
				end
			end

			subscriptionID = tonumber(subscriptionID)
			tinsert(PRIVATE.SUBSCRIPTION_MAP, subscriptionID)

			priceShort = tonumber(priceShort)
			priceLong = tonumber(priceLong)
			priceExtra = tonumber(priceExtra)

			remainingDays = tonumber(remainingDays) or 0
			nextSupplySeconds = tonumber(nextSupplySeconds) or 0

			local subscription = {
				productType			= Enum.Store.ProductType.Subscription,
				currencyType		= Enum.Store.CurrencyType.Bonus,

				subscriptionID		= subscriptionID,
				name				= name,
				description			= description,
				flags				= flags ~= "0" and tonumber(flags) or nil,

				trialAvailable		= trialAvailable ~= "0",
				trialActive			= trialActive ~= "0",
				extraActive			= extraActive ~= "0",

				dailyItems			= dailyItems,
				onSubscribeItems	= onSubscribeItems,

				icon				= SUBSCRIPTION_PRODUCT_ICON[subscriptionID],
			}

			if remainingDays > 0 then
				subscription.timestamp = timestamp
				subscription.remainingDays = remainingDays
				subscription.nextSupplySeconds = nextSupplySeconds + 1
				subscription.remainingSubscriptionSeconds = subscription.nextSupplySeconds + remainingDays * SECONDS_PER_DAY
			end

			do -- virtual products
				subscription.virtualProducts = {}

				local productType = subscription.productType

				local isActive = subscription.remainingSubscriptionSeconds ~= nil
				local numOptions = #SUBSCRIPTION_OPTIONS

				local firstOptionIndex = subscription.trialAvailable and 0 or 1
				local lastOptionIndex = isActive and SUBSCRIPTION_UPGRADE_OPTION_INDEX or numOptions

				for optionIndex = firstOptionIndex, lastOptionIndex do
					local product = CopyTable(subscription)
					local productID = PRIVATE.GetVirtualProductID(productType, optionIndex, subscriptionID)

					product.productType = productType
					product.productID = productID
					product.optionIndex = optionIndex
					product.subscriptionID = subscriptionID

					product.currencyType = subscription.currencyType

					if optionIndex == 0 then
						product.price = 0
					elseif optionIndex == 1 then
						product.price = priceShort
					elseif optionIndex == 2 then
						product.price = priceLong
					elseif optionIndex == 3 then
						product.price = priceExtra
					end

					product.originalPrice = product.price

					if optionIndex <= numOptions then
						product.days = SUBSCRIPTION_OPTIONS[optionIndex]
					else--if optionIndex == SUBSCRIPTION_UPGRADE_OPTION_INDEX then
						-- extra upgrade
						product.days = subscription.remainingDays
					end

					subscription.virtualProducts[optionIndex] = product
					PRIVATE.ProductAdd(productID, product)
				end
			end

			subscription.priceShort		= tonumber(priceShort)
			subscription.priceLong		= tonumber(priceLong)
			subscription.priceExtra		= tonumber(priceExtra)

			PRIVATE.SUBSCRIPTION_LIST[subscriptionID] = subscription

			tsort(PRIVATE.SUBSCRIPTION_LIST, PRIVATE.SortSubscriptions)

			tinsert(PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Subscriptions], {
				name = name,
				isVirtual = true,
			})
		end

		twipe(tempStorage)

		PRIVATE.SUBSCRIPTION_LIST_LOADING = nil
		FireCustomClientEvent("STORE_SUBSCRIPTION_LIST_LOADING", false)
		FireCustomClientEvent("STORE_SUBSCRIPTION_LIST_UPDATE")
		FireCustomClientEvent("STORE_CATEGORY_INFO_UPDATE", Enum.Store.Category.Subscriptions)
		FireCustomClientEvent("STORE_PRODUCTS_CHANGED")
	end

	local SUBSCRIPTION_STATUS = {
		SUCCESS	= 0,
		ERROR_BALANCE = 11,
	}

	PRIVATE.ACMSG_SHOP_SUBSCRIBE_RESULT = function(msg)
		local status = tonumber(msg)
		if status == SUBSCRIPTION_STATUS.SUCCESS then
			PRIVATE.OnPurchaseSuccess()
		else
			PRIVATE.ClearPendingPurchase()

			local event = PRIVATE.GetPurchaseErrorEventName()
			if status == SUBSCRIPTION_STATUS.ERROR_BALANCE then
				FireCustomClientEvent(event, STORE_PURCHASE_ERROR_BALANCE_BONUS)
			else
				FireCustomClientEvent(event, strformat(STORE_ERROR_SUBSCRIPTION_PURCHASE_INTERNAL, status or -1))
			end
		end
	end

	PRIVATE.SortSubscriptions = function(a, b)
		return a.subscriptionID < b.subscriptionID
	end

	PRIVATE.WipeSubscriptions = function()
		PRIVATE.pendingSubscriptionInfo = nil

		for _subscriptionID, _subscription in pairs(PRIVATE.SUBSCRIPTION_LIST) do
			for _optionIndex, product in pairs(_subscription.virtualProducts) do
				PRIVATE.ProductRemove(product.productID)
			end
		end

		twipe(PRIVATE.SUBSCRIPTION_LIST)
		twipe(PRIVATE.SUBSCRIPTION_MAP)
		twipe(PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Subscriptions])
	end

	PRIVATE.RequestSubscriptions = function()
		if PRIVATE.pendingSubscriptionInfo then
			return
		end
		PRIVATE.pendingSubscriptionInfo = true
		SendServerMessage("ACMSG_SHOP_SUBSCRIPTION_LIST_REQUEST")
	end

	PRIVATE.PurchaseSubscription = function(product)
		SendServerMessage("ACMSG_SHOP_SUBSCRIBE", strformat("%d:%d", product.subscriptionID, product.optionIndex + 1))
		return true
	end
end

do -- Renew Collection and Transmog product lists
	PRIVATE.ASMSG_ROLLED_ITEMS_IN_SHOP = function(msg)
		for _, subCategoryMsg in ipairs({StringSplitEx(";", msg)}) do
			local subCategoryID, subCategoryData = strsplit(":", subCategoryMsg, 2)
			subCategoryID = tonumber(subCategoryID)

			if subCategoryID and subCategoryData and subCategoryData ~= "" then
				for _, data in ipairs({StringSplitEx("|", subCategoryData)}) do
					local hash, currencyType, price, productID = strsplit(",", data)
					currencyType = tonumber(currencyType)
					price = tonumber(price)
					productID = tonumber(productID)

					if hash and currencyType and price and productID then
						STORE_DATA_CACHE.ROLLED_ITEM_HASHES[hash] = {
							productID = productID,
							currency = currencyType,
							price = price,
						}
					end
				end
			end
		end

		FireCustomClientEvent("STORE_ROLLED_ITEM_HASHES")
	end

	PRIVATE.ASMSG_SHOP_ROLLED_TEMS_INFO = function(msg)
		local renewWeeks, mountRenewTime, transmogRenewTime = strsplit(":", msg)
		renewWeeks = tonumber(renewWeeks)

		PRIVATE.SHOP_ROLLED_TEMS_INFO = true

		STORE_DATA_CACHE.COLLECTION_RENEW_TIMESTAMP = time()
		STORE_DATA_CACHE.COLLECTION_RENEW_TIME = tonumber(mountRenewTime) or -1
		STORE_DATA_CACHE.TRANSMOG_RENEW_TIME = tonumber(transmogRenewTime) or -1

		local changed = renewWeeks ~= (STORE_DATA_CACHE.MOUNT_RENEW_WEEK or 0)
		if changed then
			STORE_DATA_CACHE.MOUNT_RENEW_WEEK = renewWeeks
			STORE_DATA_CACHE.CATEGORY_DROP_COUNT_3_1 = 1
			STORE_DATA_CACHE.CATEGORY_DROP_COUNT_3_2 = 1
			STORE_DATA_CACHE.CATEGORY_DROP_COUNT_3_3 = 1
			STORE_DATA_CACHE.CATEGORY_DROP_COUNT_6_1 = 1

			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Collections)
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY)
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Transmogrification, 1)
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Transmogrification, 2)
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Transmogrification, 3)
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Transmogrification, 4)
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Main, 1)

			STORE_PRODUCT_CACHE.COLLECTION_RENEWED = true
		end

		FireCustomClientEvent("STORE_RANDOM_ITEM_POLL_UPDATE", changed)
	end

	PRIVATE.ASMSG_SHOP_RENEW_ITEMS = function(msg)
		local productID = PRIVATE.PENDING_PURCHASE_PRODUCT_ID

		if PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER and PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE == Enum.Store.ProductType.RenewProductList then
			PRIVATE.OnPurchaseComplete()
		end

		local status, categoryID, subCategoryID, isAltCurrency = strsplit(":", msg)
		status = tonumber(status)

		if status == 0 then
			categoryID = tonumber(categoryID)
			subCategoryID = tonumber(subCategoryID)
			isAltCurrency = isAltCurrency == "1"

			local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(Enum.Store.CurrencyType.Bonus, categoryID, subCategoryID)

			if not isAltCurrency then
				if categoryIndex == Enum.Store.Category.Collections then
					if subCategoryID == 1 then
						STORE_DATA_CACHE.MOUNT_PRICE = 3
					elseif subCategoryID == 2 then
						STORE_DATA_CACHE.PET_PRICE = 3
					elseif subCategoryID == 3 then
						STORE_DATA_CACHE.ILLUSION_PRICE = 5
					end
				elseif categoryIndex == Enum.Store.Category.Transmogrification then
					STORE_DATA_CACHE.TRANSMOG_PRICE = 10
				end

				PRIVATE.AddRefreshListProduct(categoryIndex, subCategoryIndex)
			end

			local cacheName

			if categoryIndex == Enum.Store.Category.Collections then
				cacheName = strformat("CATEGORY_DROP_COUNT_%i_%i", categoryID, subCategoryID)
			elseif categoryIndex == Enum.Store.Category.Transmogrification then
				cacheName = strformat("CATEGORY_DROP_COUNT_%i_%i", categoryID, 1)
			end

			local dropCount = STORE_DATA_CACHE[cacheName] or 0
			STORE_DATA_CACHE[cacheName] = dropCount + 1

			if categoryIndex == Enum.Store.Category.Transmogrification
			or (categoryIndex == Enum.Store.Category.Collections and subCategoryIndex == Enum.Store.CollectionType.Illusion)
			then
				PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY, true)
				PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY, 0)
			end

			if categoryIndex == Enum.Store.Category.Transmogrification then
				PRIVATE.SignalCategoryProductsRenew(categoryIndex, 1)
				PRIVATE.SignalCategoryProductsRenew(categoryIndex, 2)
				PRIVATE.SignalCategoryProductsRenew(categoryIndex, 3)
				PRIVATE.SignalCategoryProductsRenew(categoryIndex, 4)
			else
				PRIVATE.SignalCategoryProductsRenew(categoryIndex, subCategoryIndex)
			end
			PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Main, 1)

			FireCustomClientEvent("STORE_PURCHASE_COMPLETE", productID, nil, false)
			FireCustomClientEvent("STORE_PRODUCTS_CHANGED")
		else
			FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_PURCHASE_ERROR_BALANCE_BONUS)
		end
	end

	PRIVATE.AddRefreshListProduct = function(categoryIndex, subCategoryIndex)
		local name, description, price, altCurrencyType, altPrice

		if categoryIndex == Enum.Store.Category.Collections then
			if subCategoryIndex == Enum.Store.CollectionType.Mount then
				name = STORE_MOUNT_REFRESH_TITLE
				price = STORE_DATA_CACHE.MOUNT_PRICE or NO_PRODUCT_PRICE
				altCurrencyType = 280521
				altPrice = 45
			elseif subCategoryIndex == Enum.Store.CollectionType.Pet then
				name = STORE_PET_REFRESH_TITLE
				price = STORE_DATA_CACHE.PET_PRICE or NO_PRODUCT_PRICE
				altCurrencyType = 280520
				altPrice = 45
			elseif subCategoryIndex == Enum.Store.CollectionType.Illusion then
				name = STORE_ILLUSION_REFRESH_TITLE
				price = STORE_DATA_CACHE.ILLUSION_PRICE or NO_PRODUCT_PRICE
			end
		elseif categoryIndex == Enum.Store.Category.Transmogrification then
			subCategoryIndex = 0
			name = STORE_TRANSMOGRIFY_REFRESH_TITLE
			description = STORE_REFRESH_DESCRIPTION_TRANSMOG
			price = STORE_DATA_CACHE.TRANSMOG_PRICE or NO_PRODUCT_PRICE
			altCurrencyType = 280522
			altPrice = 150
		end

		if not name then
			return false
		end

		local productID = PRIVATE.GetListRefreshProductID(categoryIndex, subCategoryIndex)

		local product = {
			productType = Enum.Store.ProductType.RenewProductList,
			productID = productID,

			categoryIndex = categoryIndex,
			subCategoryIndex = subCategoryIndex,

			name = name,
			description = description or STORE_REFRESH_DESCRIPTION_GENERIC,
			icon = [[Interface\Custom\Misc\Wow-Store-Circle]],

			currencyType = Enum.Store.CurrencyType.Bonus,
			price = price,
			originalPrice = price,

			altCurrencyType = altCurrencyType,
			altPrice = altPrice,
			altOriginalPrice = altPrice,
		}

		if PRIVATE.GetProductByID(productID) then
			PRIVATE.ProductRemove(productID)
		end

		PRIVATE.ProductAdd(productID, product)

		return true
	end

	PRIVATE.GetListRefreshProductID = function(categoryIndex, subCategoryIndex)
		local productType = Enum.Store.ProductType.RenewProductList
		local productID = PRIVATE.GetVirtualProductID(productType, categoryIndex, subCategoryIndex)
		return productID
	end

	PRIVATE.GetCollectionRefreshTimeLeft = function(subCategoryIndex)
		if subCategoryIndex == Enum.Store.CollectionType.Illusion then
			return PRIVATE.GetTransmogRefreshTimeLeft()
		else
			local renewTime = STORE_DATA_CACHE.COLLECTION_RENEW_TIME or -1
			if renewTime >= 0 then
				local timeLeft = STORE_DATA_CACHE.COLLECTION_RENEW_TIMESTAMP - (time() - renewTime)
				if timeLeft > 0 then
					return timeLeft, true
				else
					STORE_DATA_CACHE.COLLECTION_RENEW_TIME = -1
					subCategoryIndex = PRIVATE.GetAdjustedSubCategoryIndex(Enum.Store.Category.Collections, subCategoryIndex)
					PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Collections, subCategoryIndex)
					return -1, true
				end
			end
		end
		return -1, false
	end

	PRIVATE.GetTransmogRefreshTimeLeft = function()
		local renewTime = STORE_DATA_CACHE.TRANSMOG_RENEW_TIME or -1
		if renewTime >= 0 then
			local timeLeft = STORE_DATA_CACHE.COLLECTION_RENEW_TIMESTAMP - (time() - renewTime)
			if timeLeft > 0 then
				return timeLeft, true
			else
				STORE_DATA_CACHE.TRANSMOG_RENEW_TIME = -1
				PRIVATE.SignalCategoryProductsRenewEvent(Enum.Store.Category.Transmogrification)
				return -1, true
			end
		end
		return -1, false
	end

	PRIVATE.PurchaseRenewProductList = function(product, useAltCurrency)
		local request

		if product.categoryIndex == Enum.Store.Category.Collections then
			local timeLeft, isRefreshAvailable = PRIVATE.GetCollectionRefreshTimeLeft(product.subCategoryIndex)
			if timeLeft > 0 and isRefreshAvailable then
				if product.subCategoryIndex == Enum.Store.CollectionType.Mount then
					request = strformat("%s:%s:%s", Enum.Store.Category.Collections, product.subCategoryIndex, useAltCurrency and 1 or 0)
				elseif product.subCategoryIndex == Enum.Store.CollectionType.Pet then
					request = strformat("%s:%s:%s", Enum.Store.Category.Collections, product.subCategoryIndex, useAltCurrency and 1 or 0)
				elseif product.subCategoryIndex == Enum.Store.CollectionType.Illusion then
					request = strformat("%s:%s:%s", Enum.Store.Category.Collections, product.subCategoryIndex, useAltCurrency and 1 or 0)
				end
			end
		elseif product.categoryIndex == Enum.Store.Category.Transmogrification then
			local timeLeft, isRefreshAvailable = PRIVATE.GetTransmogRefreshTimeLeft()
			if timeLeft > 0 and isRefreshAvailable then
				request = strformat("%s:%s:%s", Enum.Store.Category.Transmogrification, 1, useAltCurrency and 1 or 0)
			end
		end

		if request then
			SendServerMessage("ACMSG_SHOP_RENEW_ITEMS", request)
			return true
		end

		return false
	end
end

do -- Renew Transmog offers
	PRIVATE.RequestNextTransmogOfferTime = function()
		if not PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT then
			PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT = true
			FireCustomClientEvent("STORE_TRANSMOG_OFFER_NEXT_TIMER_WAIT")
			SendServerMessage("ACMSG_SHOP_TRANSMOG_OFFER_NEXT_TIMER")
		end
	end

	PRIVATE.ASMSG_SHOP_TRANSMOG_OFFER_NEXT_TIMER = function(msg)
		local remainingTime = tonumber(msg)
		if remainingTime then
			STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP = time() + remainingTime
		else
			STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP = nil
		end
		PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT = nil
		FireCustomClientEvent("STORE_TRANSMOG_OFFER_NEXT_TIMER_READY")
	end
end

do -- Purchase product
	local PURCHASE_PRODUCT_STATUS = {
		SUCCESS								= 0, -- itemID, productID
		ERROR_SHOP_DISABLED					= 1,
		ERROR_HARDCORE_FEATURE				= 2,
		ERROR_PARAMS						= 3,
		ERROR_LEVEL							= 4,
		ERROR_ITEM_DISABLED					= 5,
		ERROR_BP_TIME_ELAPSED				= 6,
		ERROR_CANT_GIFT_DUE_TO_LOYAL		= 7,
		ERROR_CANT_GIFT_ALT_CURRENCY		= 8,
		ERROR_CANT_GIFT_STATIONERY			= 9,
		ERROR_RECEIVER_NOT_FOUND			= 10,
		ERROR_CANNOT_GIFT_TO_SELF			= 11,
		ERROR_CANNOT_GIFT_HARDCORE_FEATURE	= 12,
		ERROR_NO_SPECIAL_OFFERS				= 13,
		ERROR_NOT_AVAILABLE_FOR				= 14, -- characterName
		ERROR_NO_SHOP_ROLLED_ITEMS			= 15,
		ERROR_BP_DISABLED					= 16,
		ERROR_REWARD_ALREADY_RECEIVED		= 17,
		ERROR_BALANCE						= 18, -- currencyType
		ERROR_UNCONFIRMED					= 19,
		ERROR_LEVEL_FOR						= 20, -- characterName
		ERROR_FACTION_FOR					= 21, -- characterName
		ERROR_CLASS_FOR						= 22, -- characterName
		ERROR_SPELL_FOR						= 23, -- characterName
		ERROR_OFFLINE_FOR					= 24, -- characterName
	}

	PRIVATE.ASMSG_SHOP_BUY_ITEM_RESPONSE = function(msg)
		local status, value, productID = strsplit(":", msg)
		status = tonumber(status)

		if status == PURCHASE_PRODUCT_STATUS.SUCCESS then
			local itemID = tonumber(value)
			productID = tonumber(productID)
			local wasGifted = PRIVATE.PENDING_PURCHASE_IS_GIFT or false
			PRIVATE.OnPurchaseSuccess(productID, itemID, wasGifted)
		else
			PRIVATE.OnPurchaseError(status, value)
		end
	end

	PRIVATE.OnPurchaseSuccess = function(productID, itemID, wasGifted)
		if productID and PRIVATE.PENDING_PURCHASE_PRODUCT_ID ~= productID then
			GMError(strformat("[ASMSG_SHOP_BUY_ITEM_RESPONSE] Missmatch of requested productID (%s) and received productID (%s)", PRIVATE.PENDING_PURCHASE_PRODUCT_ID or "nil", productID or "nil"))
		end

		PRIVATE.OnPurchaseComplete()

		if PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE ~= Enum.Store.ProductType.Subscription then
			PRIVATE.RequestRefundList(true)
		end

		FireCustomClientEvent("STORE_PURCHASE_COMPLETE", productID, itemID, wasGifted)
	end

	PRIVATE.OnPurchaseError = function(status, ...)
		local event = PRIVATE.GetPurchaseErrorEventName()
		local debugInfo = strjoin(".", status or " ", PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE or " ", PRIVATE.PENDING_PURCHASE_PRODUCT_ID or " ")

		PRIVATE.ClearPendingPurchase()

		if status == PURCHASE_PRODUCT_STATUS.ERROR_BALANCE then
			local currencyType = ...
			if tonumber(currencyType) == Enum.Store.Category.Loyality then
				FireCustomClientEvent(event, STORE_PURCHASE_ERROR_LOYALITY_LEVEL, debugInfo)
			else
				FireCustomClientEvent(event, STORE_PURCHASE_ERROR_BALANCE_BONUS, debugInfo)
			end
		elseif status == PURCHASE_PRODUCT_STATUS.ERROR_NOT_AVAILABLE_FOR
		or status == PURCHASE_PRODUCT_STATUS.ERROR_LEVEL_FOR
		or status == PURCHASE_PRODUCT_STATUS.ERROR_FACTION_FOR
		or status == PURCHASE_PRODUCT_STATUS.ERROR_CLASS_FOR
		or status == PURCHASE_PRODUCT_STATUS.ERROR_SPELL_FOR
		or status == PURCHASE_PRODUCT_STATUS.ERROR_OFFLINE_FOR
		then
			local playerName = ...

			local errorText = PRIVATE.SecureGetGlobalText(strformat("STORE_PURCHASE_ERROR_%d", status), true)
			if errorText then
				errorText = strformat(errorText, playerName or UNKNOWN)
			else
				errorText = strformat("[STORE_PURCHASE_ERROR] Error code '%s' for '%s'", status or "nil", playerName or UNKNOWN)
			end

			FireCustomClientEvent(event, errorText, debugInfo)

			if status == PURCHASE_PRODUCT_STATUS.ERROR_NOT_AVAILABLE_FOR then
				PRIVATE.RequestProducts()
			end
		elseif status then
			local errorText = PRIVATE.SecureGetGlobalText(strformat("STORE_PURCHASE_ERROR_%d", status), true)
			if not errorText then
				errorText = strformat("[STORE_PURCHASE_ERROR] Error code '%s'", status or "nil")
			end
			FireCustomClientEvent(event, errorText, debugInfo)
		else
			FireCustomClientEvent(event, "[STORE_PURCHASE_ERROR] Error without code", debugInfo)
		end
	end

	PRIVATE.GetPurchaseErrorEventName = function(productType)
		if not productType then
			productType = PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE
		end
		if productType == Enum.Store.ProductType.BattlePass then
			return "BATTLEPASS_OPERATION_ERROR"
		else
			return "STORE_PURCHASE_ERROR"
		end
	end

	PRIVATE.OnPurchaseComplete = function()
		if PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE == Enum.Store.ProductType.SpecialOffer then
		--[[
			local originalProductID = PRIVATE.GetVirtualProductID(PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE, 0, PRIVATE.PENDING_PURCHASE_PRODUCT_ID)
			local originalProduct = PRIVATE.GetProductByID(originalProductID)
			if originalProduct and originalProduct.offerID then
				PRIVATE.RemoveOfferByID(originalProduct.offerID, true)
			end
		-]]
		elseif PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE == Enum.Store.ProductType.Item then
		--[[
			local product = PRIVATE.GetProductByID(PRIVATE.PENDING_PURCHASE_PRODUCT_ID)

			local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(PRIVATE.GetProductCategoryInfo(product))

			if categoryIndex == Enum.Store.Category.Collections
			or categoryIndex == Enum.Store.Category.Transmogrification
			then
				PRIVATE.SignalCategoryProductsRenew(Enum.Store.Category.Main, 1)
			end
		--]]
		end

		PRIVATE.ClearPendingPurchase()
	end

	PRIVATE.ClearPendingPurchase = function()
		PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER = nil
		PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE = nil
		PRIVATE.PENDING_PURCHASE_PRODUCT_ID = nil
		PRIVATE.PENDING_PURCHASE_IS_GIFT = nil
	end

	PRIVATE.PurchaseProduct = function(product, options)
		if PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER then
			FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_ERROR_PURCHASE_IN_PROCESS)
			return false
		end

		local productType = product.productType or product[PRODUCT_DATA_FIELD.PRODUCT_TYPE]
		local productID = product.productID or product[PRODUCT_DATA_FIELD.PRODUCT_ID]

		if not productType or not productID then
			FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_ERROR_PRODUCT_MISSING:format(productID or "?", productType or "?"))
			return false
		end
--[[
		if not issecure() then
			return false
		end
--]]
		local originalProductID = product.originalProductID or product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID]
		if originalProductID then
			productID = originalProductID
		end

		PRIVATE.PENDING_PURCHASE_PRODUCT_TYPE = productType
		PRIVATE.PENDING_PURCHASE_PRODUCT_ID = productID
		PRIVATE.PENDING_PURCHASE_IS_GIFT = nil

		local amount, specIndex, isGift, giftCharacterName, giftStationeryType, giftMessage, useAltCurrency

		if type(options) == "table" then
			amount = options.amount
			specIndex = options.specIndex

			isGift = options.isGift
			giftCharacterName = options.giftCharacterName
			giftMessage = options.giftMessage
			useAltCurrency = options.useAltCurrency

			if isGift then
				if type(giftCharacterName) ~= "string" or utf8len(giftCharacterName) < 2 then
					FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_ERROR_FILL_FIELDS)
					return false
				elseif giftCharacterName == UnitName("player") then
					FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_PURCHASE_ERROR_11)
					return false
				end

				if type(options.giftStationeryType) == "number"
				and options.giftStationeryType > 0
				and options.giftStationeryType <= #PRIVATE.GIFT_OPTIONS
				then
					giftStationeryType = options.giftStationeryType
				else
					giftStationeryType = 1
				end

				giftStationeryType = PRIVATE.GIFT_OPTIONS[giftStationeryType].id

				if type(giftMessage) == "string" then
					giftMessage = strtrim(giftMessage)

					if utf8len(giftMessage) > GIFT_TEXT_MAX_LETTERS then
						giftMessage = strtrim(utf8sub(giftMessage, 1, GIFT_TEXT_MAX_LETTERS))
					end
				end
			end
		end

		local success

		if productType == Enum.Store.ProductType.Subscription then
			PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER = true
			success = PRIVATE.PurchaseSubscription(product)
		elseif productType == Enum.Store.ProductType.RenewProductList then
			PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER = true
			success = PRIVATE.PurchaseRenewProductList(product, useAltCurrency)
		else
			local request

			if product.productType == Enum.Store.ProductType.SpecialOffer and product.hasSpecOptions then
				request = strformat("%d|%d|0|%d|%d", productID, amount or 1, specIndex, useAltCurrency and 1 or 0)
			elseif isGift and (PRIVATE.CanGiftProduct(product) or PRIVATE.CanGiftProductWithLoyality(product)) then
				request = strformat("%d|%d|1|%s|%d|%s", productID, amount or 1, giftCharacterName or 0, giftStationeryType or 0, giftMessage or 0)
				PRIVATE.PENDING_PURCHASE_IS_GIFT = true
			else
				request = strformat("%d|%d|0|0|%d", productID, amount or 1, useAltCurrency and 1 or 0)
			end

			PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER = true
			SendServerMessage("ACMSG_SHOP_BUY_ITEM", request)
			success = true
		end

		if not success then
			PRIVATE.ClearPendingPurchase()
		end

		return success or false
	end
end

do -- Transmog
	PRIVATE.BuildTransmogItemList = function(rebuild)
		if PRIVATE.TRANSMOG_DATA_BUILT and not rebuild then
			return
		end

		local transmogWeaponTypes = {}
		for index, subClass in ipairs(PRIVATE.TRANSMOG_WEAPON_SUB_CLASS) do
			transmogWeaponTypes[subClass.name] = index
		end

		STORE_TRANSMOGRIFY_STORAGE = _G.STORE_TRANSMOGRIFY_STORAGE or {}

		for subCategoryID, productList in ipairs(STORE_TRANSMOGRIFY_STORAGE) do
			PRIVATE.TRANSMOG_ITEM_DATA[subCategoryID] = {}
			PRIVATE.TRANSMOG_SET_DATA[subCategoryID] = {}

			for _, item in ipairs(productList) do
				local productID, itemID, classFlag, expansionID, setProductList = unpack(item, 1, 5)
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = C_Item.GetItemInfo(itemID, false, nil, true, true)

				local transmogData = {
					productID		= productID,
					itemID			= itemID,
					classFlag		= classFlag,
					weaponType		= transmogWeaponTypes[itemSubType] or -1,
				--	expansionID		= expansionID,
				}

				if setProductList and #setProductList > 0 then
					transmogData.setProductList = setProductList
					PRIVATE.TRANSMOG_SET_DATA[subCategoryID][productID] = transmogData
				else
					PRIVATE.TRANSMOG_ITEM_DATA[subCategoryID][productID] = transmogData
				end

				PRIVATE.TRANSMOG_ITEM_DATA[productID] = transmogData
			end
		end

		_G.STORE_TRANSMOGRIFY_STORAGE = nil
		PRIVATE.TRANSMOG_DATA_BUILT = true
	end

	PRIVATE.GenerateTransmogItemSetInfo = function(subCategoryID, productID, useVirtualProducts)
		if PRIVATE.TRANSMOG_SET_DATA[subCategoryID] then
			local transmogData = PRIVATE.TRANSMOG_SET_DATA[subCategoryID][productID]
			if transmogData and transmogData.setProductList then
				local setProducts = {}
				for index, setItemProductID in ipairs(transmogData.setProductList) do
					local itemData = PRIVATE.TRANSMOG_ITEM_DATA[setItemProductID]
					local setProduct = {
						productID = setItemProductID,
						itemID = itemData and itemData.itemID or nil,
					}

					if useVirtualProducts then
						setProduct.originalProductID = setProduct.productID
						setProduct.productID = PRIVATE.GetVirtualProductID(Enum.Store.ProductType.VirtualItem, 0, setProduct.productID)
					end

					setProducts[index] = setProduct
				end
				return setProducts
			end
		end
	end

	PRIVATE.GetTransmogItemOfferForProduct = function(product, categoryIndex, subCategoryIndex, filter)
		local productID = product.productID or product[PRODUCT_DATA_FIELD.PRODUCT_ID]
		if productID then
			local storage, storageDirty = PRIVATE.GetProductStorage(categoryIndex, subCategoryIndex, filter)
			for index, storageProduct in ipairs(storage) do
				local originalProductID = storageProduct.originalProductID or storageProduct[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID]
				if originalProductID and originalProductID == productID then
					return storageProduct
				end
			end
		end
	end
end

do -- Favorite products
	PRIVATE.ASMSG_SHOP_FAVORITE_LIST = function(msg)
		PRIVATE.FAVORITE_LIST_AWAIT = nil

		twipe(STORE_DATA_CACHE.FAVORITE_PRODUCTS)

		for index, productID in ipairs({strsplit(":", msg)}) do
			productID = tonumber(productID)
			if productID then
				STORE_DATA_CACHE.FAVORITE_PRODUCTS[productID] = true
			end
		end

		FireCustomClientEvent("STORE_FAVORITE_UPDATE")
	end

	PRIVATE.ASMSG_SHOP_FAVORITE_SET = function(msg)
		local productID = PRIVATE.FAVORITE_SET_PRODUCT_ID
		local setFavorite = PRIVATE.FAVORITE_SET_OPERATION

		PRIVATE.FAVORITE_SET_AWAIT = nil
		PRIVATE.FAVORITE_SET_PRODUCT_ID = nil
		PRIVATE.FAVORITE_SET_OPERATION = nil

		local status = tonumber(msg)
		if status == 0 then
			if productID then
				if setFavorite then
					STORE_DATA_CACHE.FAVORITE_PRODUCTS[productID] = true
				else
					STORE_DATA_CACHE.FAVORITE_PRODUCTS[productID] = nil
				end
				FireCustomClientEvent("STORE_FAVORITE_UPDATE")

				if FAVORITE_SORT_AFTER_STATE_CHANGE then
					local product = PRIVATE.GetProductByID(productID)
					if product then
						local productCurrencyID, productCategoryID, productSubCategoryID = PRIVATE.GetProductCategoryInfo(product)
						local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(productCurrencyID, productCategoryID, productSubCategoryID)
						if categoryIndex == Enum.Store.Category.Collections then
							local productList = PRIVATE.GenerateStorage(PRIVATE.COLLECTION_PRODUCT_LIST, subCategoryIndex)
							productList.dirty = true
							FireCustomClientEvent("STORE_PRODUCT_LIST_UPDATE", categoryIndex, subCategoryIndex)
						else
							local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
							if isValidCategory then
								PRIVATE.SortCategoryProductList(productList, false, true, true)
							end
						end
					end
				end
			end
		else
			local debugInfo = strjoin(".", status or " ", productID or " ", setFavorite and "1" or 0)
			if status == 1 then
				FireCustomClientEvent("STORE_ERROR", strformat(STORE_FAVORITE_ERROR_1, FAVORITE_PRODUCTS_PER_CATEGORY), debugInfo)
			elseif status then
				local errorText = PRIVATE.SecureGetGlobalText(strformat("STORE_FAVORITE_ERROR_%d", status), true)
				if not errorText then
					errorText = strformat("[STORE_FAVORITE_SET] Error code '%s'", status or "nil")
				end
				FireCustomClientEvent("STORE_ERROR", errorText, debugInfo)
			else
				FireCustomClientEvent("STORE_ERROR", "[STORE_FAVORITE_SET] Error without code", debugInfo)
			end
		end
	end

	PRIVATE.RequestFavoriteList = function()
		if PRIVATE.FAVORITE_LIST_AWAIT then
			return
		end
		PRIVATE.FAVORITE_LIST_AWAIT = true
		FireCustomClientEvent("STORE_FAVORITE_AWAIT")
		SendServerMessage("ACMSG_SHOP_FAVORITE_LIST")
	end

	PRIVATE.SetFavoriteProductID = function(productID, isFavorite)
		if PRIVATE.FAVORITE_SET_AWAIT then
			return false
		end

		PRIVATE.FAVORITE_SET_AWAIT = true
		PRIVATE.FAVORITE_SET_PRODUCT_ID = productID
		PRIVATE.FAVORITE_SET_OPERATION = isFavorite
		FireCustomClientEvent("STORE_FAVORITE_AWAIT")
		SendServerMessage("ACMSG_SHOP_FAVORITE_SET", isFavorite and "1" or 0, productID)

		return true
	end

	PRIVATE.IsFavoriteProductID = function(productID)
		if STORE_DATA_CACHE.FAVORITE_PRODUCTS[productID] then
			return true
		end
		return false
	end

	PRIVATE.CanFavoriteProductID = function(productID)
		local product = PRIVATE.GetProductByID(productID)
		if not product then
			return false
		end

		if product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC] then
			if bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.CAN_FAVORITE) == 0
			or bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0
			then
				return false
			end
			if bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0
			and not PRIVATE.CanGiftProduct(product)
			and not PRIVATE.CanGiftProductWithLoyality(product)
			then
				return false
			end
		end

		local productCurrencyID, productCategoryID, productSubCategoryID = PRIVATE.GetProductCategoryInfo(product)

		local isValidCategory
		if productCurrencyID == Enum.Store.CurrencyType.Bonus then
			if productCategoryID == Enum.Store.Category.Collections then
				if productSubCategoryID == Enum.Store.CollectionType.Mount
				or productSubCategoryID == Enum.Store.CollectionType.Pet
				then
					isValidCategory = true
				end
			elseif productCategoryID == Enum.Store.Category.Transmogrification then
				if productSubCategoryID == 1 or productSubCategoryID == 2 or productSubCategoryID == 4 then
					isValidCategory = true
				end
			end
		end

		if not isValidCategory then
			return false
		end

		local favorites = 0

		for favoriteProductID, state in pairs(STORE_DATA_CACHE.FAVORITE_PRODUCTS) do
			if state and favoriteProductID ~= productID then
				local favProduct = PRIVATE.GetProductByID(favoriteProductID)
				if favProduct then
					local favProductCurrencyID, favProductCategoryID, favProductSubCategoryID = PRIVATE.GetProductCategoryInfo(favProduct)

					if favProductCurrencyID == productCurrencyID
					and favProductCategoryID == productCategoryID
					and favProductSubCategoryID == productSubCategoryID
					then
						favorites = favorites + 1

						if favorites == FAVORITE_PRODUCTS_PER_CATEGORY then
							return false
						end
					end
				end
			end
		end

		return true
	end
end

do -- Other
	PRIVATE.ASMSG_ACTIVATE_SHOP_SERVICE = function(msg)
		local flag = tonumber(msg)
		if type(flag) == "number" then
			for _, flagData in ipairs(SERVICE_FLAG_DATA) do
				if bitband(flag, flagData.flag) == flagData.flag then
					FireCustomClientEvent("STORE_SERVICE_DIALOG", flagData.text)
				end
			end
		else
			GMError(strformat("ASMSG_ACTIVATE_SHOP_SERVICE flag is non number '%s'", msg or "nil"))
		end
	end
end

do -- Initialize
	if IsInterfaceDevClient() then
		_G.PRIVATE_STORE = PRIVATE
	end
	PRIVATE.Initialize()
end

C_StoreSecure = {}

function C_StoreSecure.SetStoreFrame(frame)
	if type(frame) ~= "table" or not frame.IsObjectType then
		error("C_StoreSecure.SetShowFrame: Wrong object type", 2)
	end

	PRIVATE.STORE_FRAME = frame
end

function C_StoreSecure.GetStoreFrame()
	return PRIVATE.STORE_FRAME
end

function C_StoreSecure.WipeProductCache()
	PRIVATE.WipeProductCache()
end

function C_StoreSecure.IsBonusReplenishmentAllowed()
	return ALLOW_BONUS_REPLENISHMENT
end

function C_StoreSecure.GetProductListVersion()
	return PRIVATE.GetProductListVersion()
end

function C_StoreSecure.GetDonationLink()
	return "https://sirus.su/pay"
end

function C_StoreSecure.GenerateDonationLinkForAmount(amount)
	return strformat(DONATE_URL, mathmax(10, amount))
end

function C_StoreSecure.GetVoteLink()
	return "https://sirus.su/vote"
end

function C_StoreSecure.GetReferralLink()
	return strformat("https://welcome.sirus.su/#/page-9?ref=%u", C_Service.GetAccountID())
end

function C_StoreSecure.GetReferralExternalInfoLink()
	return "https://forum.sirus.su/resources/faq-priglasi-druga.126/"
end

function C_StoreSecure.GetAccountInfo()
--	local accountName = GetCVar("accountName")
	local name = UnitName("player")
	return name or UNKNOWN
end

function C_StoreSecure.GetBalance(currencyType)
	if type(currencyType) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetBalance' (number expected, got %s)", currencyType ~= nil and type(currencyType) or "no value"), 2)
	elseif currencyType < 0 then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetBalance' (index %s out of range)", currencyType), 2)
	end

	if currencyType > #Enum.Store.CurrencyType then
		return GetItemCount(currencyType)
	else
		return PRIVATE.GetBalance(currencyType)
	end
end

function C_StoreSecure.CanReplenishCurrency(currencyType)
	if type(currencyType) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.CanReplenishCurrency' (number expected, got %s)", currencyType ~= nil and type(currencyType) or "no value"), 2)
	elseif currencyType < 0 then
		error(strformat("bad argument #1 to 'C_StoreSecure.CanReplenishCurrency' (index %s out of range)", currencyType), 2)
	end

	return currencyType == Enum.Store.CurrencyType.Bonus
end

function C_StoreSecure.GetLoyalityInfo()
	return PRIVATE.LOYALITY.level or 0,
		PRIVATE.LOYALITY.current or 0,
		PRIVATE.LOYALITY.min or 0,
		PRIVATE.LOYALITY.max or 0
end

function C_StoreSecure.GetReferralInfo()
	return PRIVATE.REFERRAL.current or 0,
		PRIVATE.REFERRAL.min or 0,
		PRIVATE.REFERRAL.max or 0
end

function C_StoreSecure.CalculateDiscount(price, originalPrice, markup)
	if type(price) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.CalculateDiscount' (number expected, got %s)", price ~= nil and type(price) or "no value"), 2)
	elseif type(originalPrice) ~= "number" then
		error(strformat("bad argument #2 to 'C_StoreSecure.CalculateDiscount' (number expected, got %s)", originalPrice ~= nil and type(originalPrice) or "no value"), 2)
	end

	return PRIVATE.CalculateDiscount(price, originalPrice, markup)
end

function C_StoreSecure.GetDiscountForProductID(productID)
	if type(productID) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetDiscountForProductID' (number expected, got %s)", productID ~= nil and type(productID) or "no value"), 2)
	end

	local product = PRIVATE.GetProductByID(productID)
	if product then
		return PRIVATE.GetProductDiscount(product)
	end
end

function C_StoreSecure.GetProductGiftPrice(productID)
	if type(productID) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetProductGiftPrice' (number expected, got %s)", productID ~= nil and type(productID) or "no value"), 2)
	end

	local product = PRIVATE.GetProductByID(productID)
	if product then
		return PRIVATE.GetProductGiftPrice(product)
	end
end

function C_StoreSecure.CalculateLoyalityGiftMarkup(price)
	if type(price) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.CalculateLoyalityGiftMarkup' (number expected, got %s)", price ~= nil and type(price) or "no value"), 2)
	end

	return PRIVATE.CalculateLoyalityGiftMarkup(price)
end

function C_StoreSecure.GetCategoryGlobalDiscount(categoryIndex, subCategoryIndex)
	if type(categoryIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryGlobalDiscount' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
	elseif type(subCategoryIndex) ~= "number" then
		error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryGlobalDiscount' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
	end

	return PRIVATE.GetCategoryGlobalDiscount(categoryIndex, subCategoryIndex)
end

function C_StoreSecure.GetVirtualCategoryByRemoteID(currencyID, categoryID, subCategoryID)
	if type(currencyID) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetVirtualCategoryByRemoteID' (number expected, got %s)", currencyID ~= nil and type(currencyID) or "no value"), 2)
	elseif type(categoryID) ~= "number" then
		error(strformat("bad argument #2 to 'C_StoreSecure.GetVirtualCategoryByRemoteID' (number expected, got %s)", categoryID ~= nil and type(categoryID) or "no value"), 2)
	elseif type(subCategoryID) ~= "number" then
		error(strformat("bad argument #3 to 'C_StoreSecure.GetVirtualCategoryByRemoteID' (number expected, got %s)", subCategoryID ~= nil and type(subCategoryID) or "no value"), 2)
	end

	local categoryIndex, subCategoryIndex = PRIVATE.GetVirtualCategoryIDs(currencyID, categoryID, subCategoryID)
	subCategoryIndex = PRIVATE.GetAdjustedSubCategoryIndex(categoryIndex, subCategoryIndex)
	return categoryIndex, subCategoryIndex
end

function C_StoreSecure.HasProductID(productID)
	local product = PRIVATE.GetProductByID(productID)
	return product ~= nil
end

function C_StoreSecure.GetProductInfo(productID)
	local product = PRIVATE.GetProductByID(productID)
	if product then
		return PRIVATE.GetProductInfo(product)
	end
end

function C_StoreSecure.GetProductFlags(productID)
	local product = PRIVATE.GetProductByID(productID)
	if product then
		return product[PRODUCT_DATA_FIELD.FLAGS] or product.flags, product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC]
	end
end

function C_StoreSecure.GetProductPrice(productID)
	local product = PRIVATE.GetProductByID(productID)
	if product then
		return PRIVATE.GetProductPrice(product)
	end
end

function C_StoreSecure.IsFavoriteProductID(productID)
	return PRIVATE.IsFavoriteProductID(productID)
end

function C_StoreSecure.CanFavoriteProductID(productID)
	return PRIVATE.CanFavoriteProductID(productID)
end

function C_StoreSecure.SetFavoriteProductID(productID, isFavorite)
	if isFavorite then
		if PRIVATE.CanFavoriteProductID(productID) then
			return PRIVATE.SetFavoriteProductID(productID, isFavorite)
		end
	else
		if PRIVATE.IsFavoriteProductID(productID) then
			return PRIVATE.SetFavoriteProductID(productID, isFavorite)
		end
	end
	return false
end

function C_StoreSecure.AddProductItems(productID)
	return false
end

function C_StoreSecure.AddItem(itemLink)
	return false
end

function C_StoreSecure.GenerateProductHyperlink(productID)
	if type(productID) ~= "number" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GenerateProductHyperlink' (number expected, got %s)", productID ~= nil and type(productID) or "no value"), 2)
	end

	local product = PRIVATE.GetProductByID(productID)
	if not product then
		error(strformat("bad argument #1 to 'C_StoreSecure.GenerateProductHyperlink' (productID %s not found)", productID), 2)
	end

	return PRIVATE.GenerateProductHyperlink(product)
end

function C_StoreSecure.GetProductHyperlinkInfo(link)
	if type(link) ~= "string" then
		error(strformat("bad argument #1 to 'C_StoreSecure.GetProductHyperlinkInfo' (string expected, got %s)", link ~= nil and type(link) or "no value"), 2)
	end

	local categoryIndex, subCategoryIndex, product = PRIVATE.GetProductHyperlinkInfo(link)
	local productID = product and product.productID or product[PRODUCT_DATA_FIELD.PRODUCT_ID]

	return categoryIndex, subCategoryIndex, productID
end

function C_StoreSecure.GetProductItemLink(productID)
	local product = PRIVATE.GetProductByID(productID)
	if product then
		if product.itemLink then
			return product.itemLink
		else
			local itemID = product.itemID or product[PRODUCT_DATA_FIELD.ITEM_ID]
			if itemID then
				return strformat("item:%d", product.itemID)
			end
		end
	end
end

function C_StoreSecure.GenerateBalanceError(productType, currencyType, debugInfo)
	local event = PRIVATE.GetPurchaseErrorEventName(productType or Enum.Store.ProductType.Item)
	if currencyType == Enum.Store.Category.Loyality then
		FireCustomClientEvent(event, STORE_PURCHASE_ERROR_LOYALITY_LEVEL, debugInfo)
	else
		FireCustomClientEvent(event, STORE_PURCHASE_ERROR_BALANCE_BONUS, debugInfo)
	end
end

do -- Product list
	local PRODUCT_ITEM_INFO = {
		NAME			= 1,
		LINK			= 2,
		RARITY			= 3,
		ITEM_LEVEL		= 4,
		ITEM_MIN_LEVEL	= 5,
		ITEM_TYPE		= 6,
		ITEM_SUB_TYPE	= 7,
		STACK_COUNT		= 8,
		EQUIP_LOCATION	= 9,
		ICON			= 10,
		VENDOR_PRICE	= 11,
		-- additional data
		ITEM_ID			= 12,
		CLASS_ID		= 13,
		SUB_CLASS_ID	= 14,
		EQUIP_LOC_ID	= 15,
		NO_CLIENT_CACHE	= 16,
	}

	local PRODUCT_LIST_SORT_TYPE = Enum.CreateMirror(CopyTable(Enum.Store.ProductSortType))

	Enum.Store.ProductFilterType = {
		Default = 0,
		Armor = 1,
		Weapon = 2,
		TransmogArmor = 3,
		TransmogWeapon = 4,
		TransmogItemSet = 5,
	}
	Enum.Store.ProductFilterOption = {
		SEARCH_NAME			= 0,
		NON_CLASS_ITEMS		= 1,
		NEW_PRODUCT			= 2,
		RARITY				= 3,
		ARMOR_SUB_CLASS		= 4,
		WEAPON_SUB_CLASS	= 5,
		ITEM_STATS			= 6,
		ITEM_LEVEL_RANGE	= 7,
		PRODUCT_PRICE_RANGE	= 8,
		CLASS				= 9,
	}
	local PRODUCT_LIST_FILTER_TYPE = CopyTable(Enum.Store.ProductFilterType)
	local PRODUCT_LIST_FILTER_OPTION = Enum.CreateMirror(CopyTable(Enum.Store.ProductFilterOption))

	local ARMOR_SUB_CLASS_OPTIONS = {
		ITEM_SUB_CLASS_4_1,
		ITEM_SUB_CLASS_4_2,
		ITEM_SUB_CLASS_4_3,
		ITEM_SUB_CLASS_4_4,
		ITEM_SUB_CLASS_7_11,
	}
	local WEAPON_SUB_CLASS_OPTIONS = {
		ITEM_SUB_CLASS_2_0,
		ITEM_SUB_CLASS_2_10,
		ITEM_SUB_CLASS_2_3,
		ITEM_SUB_CLASS_2_2,
		ITEM_SUB_CLASS_2_18,
		ITEM_SUB_CLASS_2_7,
		ITEM_SUB_CLASS_2_13,
		ITEM_SUB_CLASS_2_15,
		ITEM_SUB_CLASS_2_16,
		ITEM_SUB_CLASS_2_19,
		ITEM_SUB_CLASS_2_4,
		ITEM_SUB_CLASS_2_6,
		ITEM_SUB_CLASS_2_1,
		ITEM_SUB_CLASS_2_8,
		ITEM_SUB_CLASS_2_5,
		ITEM_SUB_CLASS_4_6,
		ITEM_SUB_CLASS_4_7,
		ITEM_SUB_CLASS_4_8,
		ITEM_SUB_CLASS_4_9,
		ITEM_SUB_CLASS_4_10,
		INVTYPE_HOLDABLE,
	}
	local RARITY_OPTIONS = {
		ITEM_QUALITY0_DESC,
		ITEM_QUALITY1_DESC,
		ITEM_QUALITY2_DESC,
		ITEM_QUALITY3_DESC,
		ITEM_QUALITY4_DESC,
		ITEM_QUALITY5_DESC,
		ITEM_QUALITY6_DESC,
		ITEM_QUALITY7_DESC,
	}

	local FILTER_OPTIONS = {
		ARMOR_SUB_CLASS = ARMOR_SUB_CLASS_OPTIONS,
		WEAPON_SUB_CLASS = WEAPON_SUB_CLASS_OPTIONS,
		RARITY = RARITY_OPTIONS,
	}

	local ITEM_STAT_BLACKLIST = {
		RESISTANCE0_NAME = true,		-- armor
		ITEM_MOD_STAMINA_SHORT = true,	-- stamina
	}

	local CATEGORY_PRODUCT_FILTER_TYPE = {
		[PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME] = {
			type = PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			name = SEARCHING_FOR_ITEMS,
			options = {"SEARCH_NAME", STORE_PRODUCT_NAME_LABEL},
		},
		[PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS] = {
			type = PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS,
			name = STORE_FILTER_LABEL_NON_CLASS_ITEMS_LABEL,
			options = {"NON_CLASS_ITEMS", STORE_FILTER_LABEL_NON_CLASS_ITEMS_LABEL},
			dynamic = true,
		},
		[PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT] = {
			type = PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			name = STORE_FILTER_LABEL_NEW_ITEMS_LABEL,
			options = {"NEW_PRODUCT", STORE_FILTER_LABEL_NEW_ITEMS_LABEL},
			dynamic = true,
		},
		[PRODUCT_LIST_FILTER_OPTION.RARITY] = {
			type = PRODUCT_LIST_FILTER_OPTION.RARITY,
			name = RARITY,
			dynamic = true,
			isBitField = true,
			options = {},
		},
		[PRODUCT_LIST_FILTER_OPTION.CLASS] = {
			type = PRODUCT_LIST_FILTER_OPTION.CLASS,
			name = STORE_FILTER_LABEL_CLASS,
			dynamic = true,
			isBitField = true,
			manual = true,
		--	hintText = STORE_FILTER_HINT_BITMASK,
			options = {},
		},
		[PRODUCT_LIST_FILTER_OPTION.ARMOR_SUB_CLASS] = {
			type = PRODUCT_LIST_FILTER_OPTION.ARMOR_SUB_CLASS,
			name = STORE_FILTER_LABEL_ARMOR_SUBTYPE,
			dynamic = true,
			isBitField = true,
		--	hintText = STORE_FILTER_HINT_BITMASK,
			options = {},
		},
		[PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS] = {
			type = PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS,
			name = STORE_FILTER_LABEL_WEAPON_SUBTYPE,
			dynamic = true,
			isBitField = true,
		--	hintText = STORE_FILTER_HINT_BITMASK,
			options = {},
		},
		[PRODUCT_LIST_FILTER_OPTION.ITEM_STATS] = {
			type = PRODUCT_LIST_FILTER_OPTION.ITEM_STATS,
			name = STORE_FILTER_LABEL_STATS,
			dynamic = true,
			isValTable = true,
			invertedFilter = true,
			hintText = STORE_FILTER_HINT_BITMASK_INVERTED,
			options = {},
		},
		[PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE] = {
			type = PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE,
			name = AUCTION_HOUSE_SEARCH_BAR_LEVEL_RANGE_LABEL,
			dynamic = true,
			isRange = true,
			options = {
				{"ITEM_LEVEL_RANGE_MIN", STORE_FILTER_RANGE_MIN},
				{"ITEM_LEVEL_RANGE_MAX", STORE_FILTER_RANGE_MAX},
			},
		},
		[PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE] = {
			type = PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
			name = STORE_COST,
			dynamic = true,
			isRange = true,
			options = {
				{"PRODUCT_PRICE_RANGE_MIN", STORE_FILTER_RANGE_MIN},
				{"PRODUCT_PRICE_RANGE_MAX", STORE_FILTER_RANGE_MAX},
			},
		},
	}

	local CLASS_ID_DEMONHUNTER = CLASS_ID_DEMONHUNTER
	local S_CLASS_SORT_ORDER = CopyTable(S_CLASS_SORT_ORDER)
	local PLAYER_SEX = UnitSex("player")
	local PLAYER_CLASS_FLAG = select(4, UnitClass("player"))
	local CLASS_NAME_INDEX = PLAYER_SEX == 3 and 5 or 4

	PRIVATE.GetClassesByFlag = function(flag)
		local classes = {}

		for index, classData in ipairs(S_CLASS_SORT_ORDER) do
			if index ~= CLASS_ID_DEMONHUNTER then
				if flag == -1 or bitband(classData[1], flag) ~= 0 then
					tinsert(classes, classData[CLASS_NAME_INDEX])
				end
			end
		end

		return classes
	end
	PRIVATE.CopyFilterValue = function(value)
		if type(value) == "table" then
			return CopyTable(value)
		end
		return value
	end

	do -- manually generated filter options
		local sortedClasses = {}
		for index, classData in ipairs(S_CLASS_SORT_ORDER) do
			tinsert(sortedClasses, classData)
		end
		tsort(sortedClasses, function(a, b)
			return a[CLASS_NAME_INDEX] < b[CLASS_NAME_INDEX]
		end)

		local filter = CATEGORY_PRODUCT_FILTER_TYPE[PRODUCT_LIST_FILTER_OPTION.CLASS]
		local allEnabledMask = 0
		for index, classData in ipairs(sortedClasses) do
			local typeName = PRODUCT_LIST_FILTER_OPTION[filter.type]
			filter.options[index] = {typeName, classData[CLASS_NAME_INDEX], classData[1]}
			allEnabledMask = allEnabledMask + classData[1]
		end
		filter.allEnabledMask = allEnabledMask
	end
	do -- generated filter options
		for filterType, filter in pairs(CATEGORY_PRODUCT_FILTER_TYPE) do
			if filter.isBitField and not filter.manual then
				local typeName = PRODUCT_LIST_FILTER_OPTION[filter.type]
				local array = FILTER_OPTIONS[typeName]
				if array and next(array) then
					local allEnabledMask = 0
					for index, valueName in ipairs(array) do
						local value = bitlshift(1, (index - 1))
						filter.options[index] = {typeName, valueName, value}
						allEnabledMask = allEnabledMask + value
					end
					filter.allEnabledMask = allEnabledMask
				end
			end
		end
	end

	local CATEGORY_PRODUCT_FILTER_LIST = {
		[PRODUCT_LIST_FILTER_TYPE.Default] = {
			PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS,
			PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
		},
		[PRODUCT_LIST_FILTER_TYPE.Armor] = {
			PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS,
			PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			PRODUCT_LIST_FILTER_OPTION.RARITY,
			PRODUCT_LIST_FILTER_OPTION.ARMOR_SUB_CLASS,
			PRODUCT_LIST_FILTER_OPTION.ITEM_STATS,
			PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE,
			PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
		},
		[PRODUCT_LIST_FILTER_TYPE.Weapon] = {
			PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS,
			PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			PRODUCT_LIST_FILTER_OPTION.RARITY,
			PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS,
			PRODUCT_LIST_FILTER_OPTION.ITEM_STATS,
			PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE,
			PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
		},

		[PRODUCT_LIST_FILTER_TYPE.TransmogArmor] = {
			PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS,
			PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
		},
		[PRODUCT_LIST_FILTER_TYPE.TransmogWeapon] = {
			PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS,
			PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS,
			PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
		},
		[PRODUCT_LIST_FILTER_TYPE.TransmogItemSet] = {
			PRODUCT_LIST_FILTER_OPTION.SEARCH_NAME,
			PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT,
			PRODUCT_LIST_FILTER_OPTION.CLASS,
			PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE,
		},
	}

	local CATEGORY_PRODUCT_LIST_FILTER = {
		[-1] = {
			SEARCH_NAME = "",
			NON_CLASS_ITEMS = false,
			NEW_PRODUCT = false,
			RARITY = 0,
			WEAPON_SUB_CLASS = 0,
			ARMOR_SUB_CLASS = 0,
			CLASS = PLAYER_CLASS_FLAG,
			ITEM_STATS = {},
			ITEM_LEVEL_RANGE_MIN = 0, ITEM_LEVEL_RANGE_MAX = 0,
			PRODUCT_PRICE_RANGE_MIN = 0, PRODUCT_PRICE_RANGE_MAX = 0,
		},
	}
	do -- generate filter defaults
		local defaultFilter = CATEGORY_PRODUCT_LIST_FILTER[-1]
		if defaultFilter then
			for filterCategoryType, filter in pairs(CATEGORY_PRODUCT_FILTER_LIST) do
				local filterDefaults = {}

				for index, filterType in ipairs(filter) do
					local filterOptionName = PRODUCT_LIST_FILTER_OPTION[filterType]
					local filterTypeInfo = CATEGORY_PRODUCT_FILTER_TYPE[filterType]

					if strsub(filterOptionName, -6, -1) == "_RANGE" then
						local filterOptionNameMin = strconcat(filterOptionName, "_MIN")

						if defaultFilter[filterOptionNameMin] ~= nil then
							if filterTypeInfo.isValTable then
								filterDefaults[filterOptionNameMin] = CopyTable(defaultFilter[filterOptionNameMin])
							else
								filterDefaults[filterOptionNameMin] = defaultFilter[filterOptionNameMin]
							end
						else
							PRIVATE.LOG(strformat("FILTER KEY [%s][%s] NOT FOUND for filter type [%s]", filterType, filterOptionNameMin or "nil", filterCategoryType))
						end

						filterOptionName = strconcat(filterOptionName, "_MAX")
					end

					if defaultFilter[filterOptionName] ~= nil then
						if filterTypeInfo.isValTable then
							filterDefaults[filterOptionName] = CopyTable(defaultFilter[filterOptionName])
						else
							filterDefaults[filterOptionName] = defaultFilter[filterOptionName]
						end
					else
						PRIVATE.LOG(strformat("FILTER KEY [%s][%s] NOT FOUND for filter type [%s]", filterType, filterOptionName or "nil", filterCategoryType))
					end
				end

				if next(filterDefaults) then
					CATEGORY_PRODUCT_LIST_FILTER[filterCategoryType] = filterDefaults
				end
			end
		end
	end

	PRIVATE.GetCategoryProductSettingsInfo = function(settings, categoryIndex, subCategoryIndex)
		local productCategory = PRIVATE[settings][categoryIndex]
		if not productCategory then
			productCategory = {}
			PRIVATE[settings][categoryIndex] = productCategory
		end
		local productSubCategory = productCategory[subCategoryIndex]
		if not productSubCategory then
			productSubCategory = {dirty = true, init = true}
			productCategory[subCategoryIndex] = productSubCategory
		end
		return productSubCategory
	end

	PRIVATE.SortCategoryProductListHandler = function(productA, productB, sortType, prioritizeNewSorting)
		local isFavoriteA = PRIVATE.IsFavoriteProductID(productA[PRODUCT_DATA_FIELD.PRODUCT_ID])
		local isFavoriteB = PRIVATE.IsFavoriteProductID(productB[PRODUCT_DATA_FIELD.PRODUCT_ID])
		if isFavoriteA ~= isFavoriteB then
			return isFavoriteA
		end

		local isRollableUnavailableA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0
		local isRollableUnavailableB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0
		if isRollableUnavailableA ~= isRollableUnavailableB then
			return isRollableUnavailableB
		end

		local hasOfferA = PRIVATE.GetOfferForProduct(productA) ~= nil
		local hasOfferB = PRIVATE.GetOfferForProduct(productB) ~= nil
		if hasOfferA ~= hasOfferB then
			return hasOfferA
		end

		local noPurchaseCanGiftA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0 and not PRIVATE.CanGiftProduct(productA)
		local noPurchaseCanGiftB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0 and not PRIVATE.CanGiftProduct(productB)
		if noPurchaseCanGiftA ~= noPurchaseCanGiftB then
			return noPurchaseCanGiftB
		end

		if prioritizeNewSorting then
			local isNewA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
			local isNewB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
			if isNewA ~= isNewB then
				return isNewA
			end
		end

		if sortType == PRODUCT_LIST_SORT_TYPE.Name then
			if productA.itemInfo[PRODUCT_ITEM_INFO.NAME] ~= productB.itemInfo[PRODUCT_ITEM_INFO.NAME] then
				return (productA.itemInfo[PRODUCT_ITEM_INFO.NAME] or "") < (productB.itemInfo[PRODUCT_ITEM_INFO.NAME] or ""), true
			end
		elseif sortType == PRODUCT_LIST_SORT_TYPE.ItemLevel then
			if productA.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] ~= productB.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] then
				return (productA.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] or 0) > (productB.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] or 0), true
			end
		elseif sortType == PRODUCT_LIST_SORT_TYPE.PVP then
			local isPVPa = bitband(productA[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.PVP) ~= 0
			local isPVPb = bitband(productB[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.PVP) ~= 0
			if isPVPa ~= isPVPb then
				return isPVPa and not isPVPb, true
			end
		elseif sortType == PRODUCT_LIST_SORT_TYPE.Price then
			local priceA = PRIVATE.GetProductPrice(productA)
			local priceB = PRIVATE.GetProductPrice(productB)
			if priceA ~= priceB then
				return priceA < priceB, true
			end
		elseif sortType == PRODUCT_LIST_SORT_TYPE.Discount then
		--	local discountA = PRIVATE.CalculateDiscount(PRIVATE.GetProductPrice(productA))
		--	local discountB = PRIVATE.CalculateDiscount(PRIVATE.GetProductPrice(productB))
			local discountA = PRIVATE.GetProductDiscount(productA)
			local discountB = PRIVATE.GetProductDiscount(productB)
			if discountA ~= discountB then
				return discountA < discountB, true
			end
		end

		if not prioritizeNewSorting then
			local isNewA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
			local isNewB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
			if isNewA ~= isNewB then
				return isNewA
			end
		end

		if productA.itemInfo[PRODUCT_ITEM_INFO.NAME] ~= productB.itemInfo[PRODUCT_ITEM_INFO.NAME] then
			return (productA.itemInfo[PRODUCT_ITEM_INFO.NAME] or "") < (productB.itemInfo[PRODUCT_ITEM_INFO.NAME] or "")
		elseif productA.itemInfo[PRODUCT_ITEM_INFO.RARITY] ~= productB.itemInfo[PRODUCT_ITEM_INFO.RARITY] then
			return (productA.itemInfo[PRODUCT_ITEM_INFO.RARITY] or ITEM_RARITY_FALLBACK) < (productB.itemInfo[PRODUCT_ITEM_INFO.RARITY] or ITEM_RARITY_FALLBACK)
		elseif productA.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] ~= productB.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] then
			return (productA.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] or 0) < (productB.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL] or 0)
		elseif productA[PRODUCT_DATA_FIELD.ITEM_AMOUNT] ~= productB[PRODUCT_DATA_FIELD.ITEM_AMOUNT] then
			return (productA[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1) < (productB[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1)
		end

		local priceA = PRIVATE.GetProductPrice(productA)
		local priceB = PRIVATE.GetProductPrice(productB)
		if priceA ~= priceB then
			return priceA < priceB
		end

		return productA[PRODUCT_DATA_FIELD.PRODUCT_ID] > productB[PRODUCT_DATA_FIELD.PRODUCT_ID]
	end
	PRIVATE.SortCategoryProductList = function(productList, resetSortType, forceSort, fireEvent)
		local categoryIndex = productList.categoryIndex
		local subCategoryIndex = productList.subCategoryIndex

		if resetSortType then
			PRIVATE.ResetCategoryProductSortType(categoryIndex, subCategoryIndex)
		end

		local sortInfo = PRIVATE.GetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex)
		if sortInfo.dirty or forceSort then
			local prioritizeNewSorting
			if categoryIndex == Enum.Store.Category.Transmogrification then
				prioritizeNewSorting = true
			else
				prioritizeNewSorting = false
			end

			tsort(productList.filtered, function(productA, productB)
				local res, customSort = PRIVATE.SortCategoryProductListHandler(productA, productB, sortInfo.type, prioritizeNewSorting)
				if customSort and sortInfo.reversed then
					return not res
				else
					return res
				end
			end)

			sortInfo.dirty = nil

			if fireEvent then
				FireCustomClientEvent("STORE_PRODUCT_LIST_SORT_UPDATE", categoryIndex, subCategoryIndex)
			end
		end
	end
	PRIVATE.GetDefaultProductSortType = function(categoryIndex, subCategoryIndex)
		local sortType, reverse
		if categoryIndex == Enum.Store.Category.Referral
		or categoryIndex == Enum.Store.Category.Loyality
		or categoryIndex == Enum.Store.Category.Vote
		then
			sortType = PRODUCT_LIST_SORT_TYPE.Price
			reverse = true
		else
		--	sortType = PRODUCT_LIST_SORT_TYPE.Name
		--	reverse = false
			sortType = PRODUCT_LIST_SORT_TYPE.Price
			reverse = true
		end
		return sortType, reverse
	end
	PRIVATE.GetCategoryProductSortTypeInfo = function(categoryIndex, subCategoryIndex)
		local sortInfo = PRIVATE.GetCategoryProductSettingsInfo("CATEGORY_PRODUCT_LIST_SORT_INFO", categoryIndex, subCategoryIndex)
		if sortInfo.init then
			local sortType, reverse = PRIVATE.GetDefaultProductSortType(categoryIndex, subCategoryIndex)
			sortInfo.type = sortType
			sortInfo.reversed = reverse
			sortInfo.init = nil
		end
		return sortInfo
	end
	PRIVATE.SetCategoryProductSortTypeInfo = function(categoryIndex, subCategoryIndex, sortType, reversed)
		local sortInfo = PRIVATE.GetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex)
		if sortInfo.type ~= sortType or sortInfo.reversed ~= reversed then
			sortInfo.type = sortType
			sortInfo.reversed = reversed
			sortInfo.dirty = true
		end
	end
	PRIVATE.ResetCategoryProductSortType = function(categoryIndex, subCategoryIndex)
		local sortType, reverse = PRIVATE.GetDefaultProductSortType(categoryIndex, subCategoryIndex)
		PRIVATE.SetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex, sortType, reverse)
	end

	PRIVATE.GetDefaultProductFilter = function(categoryIndex, subCategoryIndex)
		local filterOptionType = PRIVATE.GetCategoryProductFilterOptions(categoryIndex, subCategoryIndex)
		return CATEGORY_PRODUCT_LIST_FILTER[filterOptionType] or CATEGORY_PRODUCT_LIST_FILTER[-1]
	end
	PRIVATE.FilterCategoryProductListHandler = function(product, filterInfo, filterStats, hasClassFilters)
		if QUEARY_ALL_ITEMS then
			if not filterInfo.NON_CLASS_ITEMS and (bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.IS_PERSONAL) == 0) then
				return false
			end
		end

		if filterInfo.SEARCH_NAME then
			local searchName = strtrim(filterInfo.SEARCH_NAME)
			local found

			local id = tonumber(searchName)
			if id then
				if product.itemInfo[PRODUCT_ITEM_INFO.ITEM_ID] == id
				or (ALLOW_SEARCH_BY_PRODUCT_ID and product[PRODUCT_DATA_FIELD.PRODUCT_ID] == id)
				then
					found = true
				end
			end

			if not found and searchName ~= "" and not strfind(strlower(product.itemInfo[PRODUCT_ITEM_INFO.NAME]), strlower(searchName), 1, true) then
				return false
			end
		end

		if filterInfo.NEW_PRODUCT and (bitband(product[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) == 0) then
			return false
		end

		if (filterInfo.ITEM_LEVEL_RANGE_MIN and filterInfo.ITEM_LEVEL_RANGE_MIN > 0 and filterInfo.ITEM_LEVEL_RANGE_MIN > product.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL])
		or (filterInfo.ITEM_LEVEL_RANGE_MAX and filterInfo.ITEM_LEVEL_RANGE_MAX > 0 and filterInfo.ITEM_LEVEL_RANGE_MAX < product.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL])
		then
			return false
		end

		if (filterInfo.PRODUCT_PRICE_RANGE_MIN and filterInfo.PRODUCT_PRICE_RANGE_MIN > 0)
		or (filterInfo.PRODUCT_PRICE_RANGE_MAX and filterInfo.PRODUCT_PRICE_RANGE_MAX > 0)
		then
			local price = PRIVATE.GetProductPrice(product)
			if (filterInfo.PRODUCT_PRICE_RANGE_MIN and filterInfo.PRODUCT_PRICE_RANGE_MIN > 0 and filterInfo.PRODUCT_PRICE_RANGE_MIN > price)
			or (filterInfo.PRODUCT_PRICE_RANGE_MAX and filterInfo.PRODUCT_PRICE_RANGE_MAX > 0 and filterInfo.PRODUCT_PRICE_RANGE_MAX < price)
			then
				return false
			end
		end

		if filterInfo.RARITY and filterInfo.RARITY ~= 0 then
			local rarity = product.itemInfo[PRODUCT_ITEM_INFO.RARITY] or ITEM_RARITY_FALLBACK
			local filterData = CATEGORY_PRODUCT_FILTER_TYPE[PRODUCT_LIST_FILTER_OPTION.RARITY]

			if not rarity and filterInfo.RARITY ~= filterData.allEnabledMask then
				return false
			end

			local rarityOption = filterData.options[rarity + 1]
			if rarityOption and bitband(filterInfo.RARITY, rarityOption[3]) ~= rarityOption[3] then
				return false
			end
		end

		if filterInfo.WEAPON_SUB_CLASS and filterInfo.WEAPON_SUB_CLASS ~= 0 then
			local itemSubType = product.itemInfo[PRODUCT_ITEM_INFO.ITEM_SUB_TYPE]
			local itemEquipLoc = product.itemInfo[PRODUCT_ITEM_INFO.EQUIP_LOCATION]

			local filterData = CATEGORY_PRODUCT_FILTER_TYPE[PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS]
			if itemEquipLoc == "INVTYPE_HOLDABLE" then
				itemSubType = INVTYPE_HOLDABLE
			end

			if not itemSubType and filterInfo.WEAPON_SUB_CLASS ~= filterData.allEnabledMask then
				return false
			end

			local optionIndex = tIndexOf(WEAPON_SUB_CLASS_OPTIONS, itemSubType)
			local subTypeOption = filterData.options[optionIndex]
			if subTypeOption and bitband(filterInfo.WEAPON_SUB_CLASS, subTypeOption[3]) ~= subTypeOption[3] then
				return false
			end
		end

		if filterInfo.ARMOR_SUB_CLASS and filterInfo.ARMOR_SUB_CLASS ~= 0 then
			local itemSubType = product.itemInfo[PRODUCT_ITEM_INFO.ITEM_SUB_TYPE]
			local filterData = CATEGORY_PRODUCT_FILTER_TYPE[PRODUCT_LIST_FILTER_OPTION.ARMOR_SUB_CLASS]

			if not itemSubType and filterInfo.ARMOR_SUB_CLASS ~= filterData.allEnabledMask then
				return false
			end

			local optionIndex = tIndexOf(ARMOR_SUB_CLASS_OPTIONS, itemSubType)
			local subTypeOption = filterData.options[optionIndex]
			if subTypeOption and bitband(filterInfo.ARMOR_SUB_CLASS, subTypeOption[3]) ~= subTypeOption[3] then
				return false
			end
		end

		if hasClassFilters and filterInfo.CLASS and filterInfo.CLASS ~= 0 then
			local transmogData = PRIVATE.TRANSMOG_ITEM_DATA[product[PRODUCT_DATA_FIELD.PRODUCT_ID]]
			if transmogData
			and transmogData.classFlag ~= -1
			and bitband(filterInfo.CLASS, transmogData.classFlag) == 0
			then
				return false
			end
		end

		if filterInfo.ITEM_STATS and next(filterInfo.ITEM_STATS) then
			if not product.itemStats then -- cache not loaded
				return false
			end

			for _, statKey in ipairs(filterStats) do
				if not product.itemStats[statKey] then
					return false
				end
			end
		end

		return true
	end
	PRIVATE.FilterCategoryProductList = function(productList, resetFilter, fireEvent)
		local categoryIndex = productList.categoryIndex
		local subCategoryIndex = productList.subCategoryIndex
		local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)

		if resetFilter then
			PRIVATE.ResetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
			productList.filterUpdateQueued = nil
			filterInfo.dirty = true -- filterInfo.NON_CLASS_ITEMS == false
		elseif productList.filterUpdateQueued then
			productList.filterUpdateQueued = nil
			filterInfo.dirty = true
		end

		if filterInfo.dirty then
			if not productList.filtered then
				productList.filtered = {}
			else
				twipe(productList.filtered)
			end

			local filterStats
			local itemStats = filterInfo.ITEM_STATS
			if itemStats and next(itemStats) then
				local isInverted = CATEGORY_PRODUCT_FILTER_TYPE[PRODUCT_LIST_FILTER_OPTION.ITEM_STATS].invertedFilter

				filterStats = {}
				for index, statOption in pairs(productList.itemStats) do
					if (isInverted and filterInfo.ITEM_STATS[statOption[3]])
					or (not isInverted and not filterInfo.ITEM_STATS[statOption[3]])
					then
						tinsert(filterStats, statOption[4])
					end
				end
			end

			local hasClassFilters = productList.categoryIndex == Enum.Store.Category.Transmogrification and productList.subCategoryIndex == 4
			for index, product in ipairs(productList.storage) do
				if product.itemInfo then
					if productList.itemListNoFilters
					or PRIVATE.FilterCategoryProductListHandler(product, filterInfo, filterStats, hasClassFilters)
					then
						tinsert(productList.filtered, product)
					end
				else
					PRIVATE.LOG(strconcat("No item info: ", product[PRODUCT_DATA_FIELD.ITEM_ID]))
				end
			end

			filterInfo.dirty = nil

			if fireEvent then
				FireCustomClientEvent("STORE_PRODUCT_LIST_FILTER_UPDATE", categoryIndex, subCategoryIndex)
			end
		elseif resetFilter then
			productList.filtered = CopyTable(productList.storage, true)
			filterInfo.dirty = nil

			if fireEvent then
				FireCustomClientEvent("STORE_PRODUCT_LIST_FILTER_UPDATE", categoryIndex, subCategoryIndex)
			end
		end
	end
	PRIVATE.GetCategoryProductFilterInfo = function(categoryIndex, subCategoryIndex)
		local filterInfo = PRIVATE.GetCategoryProductSettingsInfo("CATEGORY_PRODUCT_LIST_FILTER_INFO", categoryIndex, subCategoryIndex)
		if filterInfo.init then
			local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)
			for name, value in pairs(filterDefaults) do
				filterInfo[name] = PRIVATE.CopyFilterValue(value)
			end
			filterInfo.init = nil
		end
		return filterInfo
	end
	PRIVATE.SetCategoryProductFilterInfo = function(categoryIndex, subCategoryIndex, filter, checkFields)
		local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
		filterInfo.dirty = nil

		if checkFields then
			local isDirty
			local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)

			-- cleanup
			for name, value in pairs(filter) do
				if filterDefaults[name] == nil then
					filter[name] = nil
				end
			end

			-- add defaults
			for name, value in pairs(filterDefaults) do
				if QUEARY_ALL_ITEMS then
					if filter[name] == nil then
						filter[name] = PRIVATE.CopyFilterValue(value)
					end
				else
					if filter[name] == nil and (checkFields or name ~= "NON_CLASS_ITEMS") then
						filter[name] = PRIVATE.CopyFilterValue(value)
					end
				end
			end

			-- merge
			for name, value in pairs(filter) do
				if filterInfo[name] ~= value then
					filterInfo[name] = PRIVATE.CopyFilterValue(value)
					isDirty = true
				end
			end
			filterInfo.dirty = isDirty
		elseif not next(filterInfo) or not tCompare(filterInfo, filter, 2) then
			twipe(filterInfo)
			for name, value in pairs(filter) do
				filterInfo[name] = PRIVATE.CopyFilterValue(value)
			end
			filterInfo.dirty = true
		end
	end
	PRIVATE.ResetCategoryProductFilterInfo = function(categoryIndex, subCategoryIndex)
		local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)
		PRIVATE.SetCategoryProductFilterInfo(categoryIndex, subCategoryIndex, filterDefaults)
	end
	PRIVATE.SortItemStatFilter = function(optionA, optionB)
		return optionA[2] < optionB[2]
	end
	PRIVATE.GetCategoryProductFilterOptions = function(categoryIndex, subCategoryIndex)
		if PRIVATE.IsValidCategoryProductList(categoryIndex, subCategoryIndex) then
			local filterOptionType
			if categoryIndex == Enum.Store.Category.Equipment then
				if subCategoryIndex <= 12 then
					filterOptionType = PRODUCT_LIST_FILTER_TYPE.Armor
				else
					filterOptionType = PRODUCT_LIST_FILTER_TYPE.Weapon
				end
			elseif categoryIndex == Enum.Store.Category.Transmogrification then
				if subCategoryIndex == 2 then
					filterOptionType = PRODUCT_LIST_FILTER_TYPE.TransmogWeapon
				elseif subCategoryIndex == 4 then
					filterOptionType = PRODUCT_LIST_FILTER_TYPE.TransmogItemSet
				else
					filterOptionType = PRODUCT_LIST_FILTER_TYPE.TransmogArmor
				end
			end

			if not filterOptionType or not CATEGORY_PRODUCT_FILTER_LIST[filterOptionType] then
				filterOptionType = PRODUCT_LIST_FILTER_TYPE.Default
			end

			return filterOptionType, CATEGORY_PRODUCT_FILTER_LIST[filterOptionType]
		end
	end

	local STORAGE_TYPE = {
		[0] = "StoragePersonal",
		[1] = "StorageAll",
	}

	PRIVATE.GenerateProductList = function(categoryIndex, subCategoryIndex)
		local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)

		local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
		local filter

		if QUEARY_ALL_ITEMS then
			filter = 1
		else
			filter = filterInfo.NON_CLASS_ITEMS and 1 or 0
		end

		if categoryIndex == Enum.Store.Category.Transmogrification and subCategoryIndex == 4 then
			filterInfo.NON_CLASS_ITEMS = true
			filter = 1
		end

		local storage, storageDirty = PRIVATE.GetProductStorageRaw(currencyID, categoryID, subCategoryID, filter)

		local productList = PRIVATE.GenerateStorage(PRIVATE.CATEGORY_PRODUCT_LIST, currencyID, categoryID, subCategoryID)
		if productList.categoryIndex and storageDirty then
			productList.itemStatsUpdate = nil
			productList.filterUpdateQueued = nil
			productList.dirtyItemInfo = true
			productList.dirtyFilter = true
		end

		if storageDirty then
			return storage -- just empty table
		end

		if not productList.categoryIndex then
			local category = PRIVATE.CATEGORIES[categoryIndex]
			productList.categoryIndex = categoryIndex
			productList.subCategoryIndex = subCategoryIndex
			productList.itemListNoFilters = category.itemListNoFilters or false

			productList.itemStatsUpdate = nil
			productList.filterUpdateQueued = nil
			productList.dirtyItemInfo = true
			productList.dirtyFilter = true
		end

		if QUEARY_ALL_ITEMS then
			if not productList.filter or productList.dirtyFilter then
				productList.filter = filter

				if categoryIndex == Enum.Store.Category.Transmogrification
				and PRIVATE.TRANSMOG_SET_DATA[subCategoryID]
				then
					local setProducts = {}
					for index, product in ipairs(storage) do
						local productID = product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID] or product[PRODUCT_DATA_FIELD.PRODUCT_ID]
						if PRIVATE.TRANSMOG_SET_DATA[subCategoryID][productID] then
							tinsert(setProducts, product)
						end
					end
					productList.storage = setProducts
				else
					productList.storage = CopyTable(storage)
				end

				local sortInfo = PRIVATE.GetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex)
				sortInfo.dirty = true
				filterInfo.dirty = true
				productList.dirtyItemInfo = true
				productList.dirtyFilter = nil
			end

			PRIVATE.SELECTED_FILTER = filter
		else -- switch storage
			if not productList[STORAGE_TYPE[filter]] then
				if categoryIndex == Enum.Store.Category.Transmogrification
				and PRIVATE.TRANSMOG_SET_DATA[subCategoryID]
				then
					local setProducts = {}
					for index, product in ipairs(storage) do
						local productID = product[PRODUCT_DATA_FIELD.ORIGINAL_PRODUCT_ID] or product[PRODUCT_DATA_FIELD.PRODUCT_ID]
						if PRIVATE.TRANSMOG_SET_DATA[subCategoryID][productID] then
							tinsert(setProducts, product)
						end
					end
					productList[STORAGE_TYPE[filter]] = setProducts
				else
					productList[STORAGE_TYPE[filter]] = CopyTable(storage)
				end
			end

			if productList.filter ~= filter then
				productList.filter = filter
				productList.storage = productList[STORAGE_TYPE[filter]]

				local sortInfo = PRIVATE.GetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex)
				sortInfo.dirty = true
				filterInfo.dirty = true
				productList.dirtyItemInfo = true
			end

			PRIVATE.SELECTED_FILTER = filter
		end

		do -- upgrade cache
			if productList.itemStatsUpdate then
				if productList.itemStats then
					twipe(productList.itemStats)
				end
				productList.dirtyItemInfo = true
				productList.itemStatsUpdate = nil
				productList.filterUpdateQueued = true
			end
		end

		return productList
	end
	PRIVATE.IsValidCategoryProductList = function(categoryIndex, subCategoryIndex)
		return PRIVATE.CATEGORIES[categoryIndex] and PRIVATE.CATEGORIES[categoryIndex].hasItemList
	end
	PRIVATE.OnFilterItemInfoReceived = function(itemID)
		for productList, queuedItemIDs in pairs(PRIVATE.QUEUED_PRODUCT_ITEM_INFO) do
			if queuedItemIDs[itemID] then
				queuedItemIDs[itemID] = nil
				productList.queuedItemStatsUpdate = true
			end
		end
	end
	PRIVATE.UpdateCategoryProductListItemInfo = function(productList)
		productList.dirtyItemInfo = nil

		if not productList.productStats then
			productList.productStats = {}
		else
			twipe(productList.productStats)
		end
		if not productList.itemStats then
			productList.itemStats = {}
		else
			twipe(productList.itemStats)
		end

		local itemStats = {}

		local classMask = 0
		local hasClassFilters = productList.categoryIndex == Enum.Store.Category.Transmogrification and productList.subCategoryIndex == 4

		local filterOptionType = PRIVATE.GetCategoryProductFilterOptions(productList.categoryIndex, productList.subCategoryIndex)
		local subTypeOptionIndex, useWeaponSubType
		if tIndexOf(CATEGORY_PRODUCT_FILTER_LIST[filterOptionType], PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS) then
			subTypeOptionIndex = PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS
			useWeaponSubType = true
		else
			subTypeOptionIndex = PRODUCT_LIST_FILTER_OPTION.ARMOR_SUB_CLASS
		end

		for index, product in ipairs(productList.storage) do
			local itemID = C_Item.GetCreatedItemIDByItem(product[PRODUCT_DATA_FIELD.ITEM_ID]) or product[PRODUCT_DATA_FIELD.ITEM_ID]
			product.itemInfo = {C_Item.GetItemInfo(itemID, false, PRIVATE.OnFilterItemInfoReceived)}

			if product.itemInfo[PRODUCT_ITEM_INFO.NO_CLIENT_CACHE] then
				if not PRIVATE.QUEUED_PRODUCT_ITEM_INFO[productList] then
					PRIVATE.QUEUED_PRODUCT_ITEM_INFO[productList] = {}
				end
				PRIVATE.QUEUED_PRODUCT_ITEM_INFO[productList][itemID] = true
			else
				if not product.itemStats then
					product.itemStats = {}
				else
					twipe(product.itemStats)
				end

				local itemLink = product.itemInfo[PRODUCT_ITEM_INFO.LINK]
				if itemLink then
					GetItemStats(itemLink, product.itemStats)

					for statName in pairs(product.itemStats) do
						itemStats[statName] = true
					end
				end
			end

			if product.itemInfo[PRODUCT_ITEM_INFO.NAME] then
				do
					local rarityIndex = product.itemInfo[PRODUCT_ITEM_INFO.RARITY] or ITEM_RARITY_FALLBACK
					local rarityName = rarityIndex and RARITY_OPTIONS[rarityIndex + 1] or RARITY_OPTIONS[2]
					local itemRarity = productList.productStats[PRODUCT_LIST_FILTER_OPTION.RARITY]
					if not itemRarity then
						itemRarity = {
							[rarityName] = true
						}
						productList.productStats[PRODUCT_LIST_FILTER_OPTION.RARITY] = itemRarity
					else
						itemRarity[rarityName] = true
					end
				end

				do
					local subClass = product.itemInfo[PRODUCT_ITEM_INFO.ITEM_SUB_TYPE]
					if subClass then
						if useWeaponSubType then
							if product.itemInfo[PRODUCT_ITEM_INFO.EQUIP_LOCATION] == "INVTYPE_HOLDABLE" then
								subClass = INVTYPE_HOLDABLE
							end
						end

						local itemSubClass = productList.productStats[subTypeOptionIndex]
						if not itemSubClass then
							itemSubClass = {
								[subClass] = true
							}
							productList.productStats[subTypeOptionIndex] = itemSubClass
						else
							itemSubClass[subClass] = true
						end
					end
				end

				do
					local itemLevel = product.itemInfo[PRODUCT_ITEM_INFO.ITEM_LEVEL]
					local itemLevelRange = productList.productStats[PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE]
					if not itemLevelRange and itemLevel then
						itemLevelRange = {
							min = itemLevel, max = itemLevel,
						}
						productList.productStats[PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE] = itemLevelRange
					else
						itemLevelRange.min = mathmin(itemLevelRange.min, itemLevel)
						itemLevelRange.max = mathmax(itemLevelRange.max, itemLevel)
					end
				end
			end

			do
				if bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.IS_PERSONAL) == 0 then
					productList.productStats[PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS] = true
				end
				if bitband(product[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0 then
					productList.productStats[PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT] = true
				end
			end

			do
				local price = PRIVATE.GetProductPrice(product)
				local priceRange = productList.productStats[PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE]
				if not priceRange and price and price >= 0 then
					priceRange = {
						min = price, max = price,
					}
					productList.productStats[PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE] = priceRange
				else
					priceRange.min = mathmin(priceRange.min, price)
					priceRange.max = mathmax(priceRange.max, price)
				end
			end

			if hasClassFilters then
				local transmogData = PRIVATE.TRANSMOG_ITEM_DATA[product[PRODUCT_DATA_FIELD.PRODUCT_ID]]
				if transmogData and transmogData.classFlag and transmogData.classFlag > 0 then
					classMask = bitbor(classMask, transmogData.classFlag)
				end
			end
		end

		if hasClassFilters then
			local classList = productList.productStats[PRODUCT_LIST_FILTER_OPTION.CLASS]
			if not classList then
				classList = {}
				productList.productStats[PRODUCT_LIST_FILTER_OPTION.CLASS] = classList
			end
			for index, className in ipairs(PRIVATE.GetClassesByFlag(classMask)) do
				classList[className] = true
			end
		end

		do
			local newStats = 0
			for statKey, statValue in pairs(itemStats) do
				if not ITEM_STAT_BLACKLIST[statKey] then
					newStats = newStats + 1
					local statIndex = #productList.itemStats + 1
					local statName = PRIVATE.SecureGetGlobalText(statKey, true)
					productList.itemStats[statIndex] = {"ITEM_STATS", statName and strlower(statName) or statKey, statIndex, statKey}
				end
			end

			if newStats > 0 then
				tsort(productList.itemStats, PRIVATE.SortItemStatFilter)
			end
		end
	end
	PRIVATE.GetCategoryProductList = function(categoryIndex, subCategoryIndex)
		if not PRIVATE.IsValidCategoryProductList(categoryIndex, subCategoryIndex) then
			return nil, false
		end

		local productList = PRIVATE.GenerateProductList(categoryIndex, subCategoryIndex)
		if not productList.storage then
			return nil, false
		end

		local listChanged = productList.dirtyItemInfo
		if productList.dirtyItemInfo then
			PRIVATE.UpdateCategoryProductListItemInfo(productList)
		end

		if (not productList.filtered or listChanged or productList.filterUpdateQueued) then
			PRIVATE.FilterCategoryProductList(productList--[[, not productList.filterUpdateQueued]])
			PRIVATE.SortCategoryProductList(productList, false, true)
		end

		return productList, true
	end

	function C_StoreSecure.IsCategoryProductsLoaded(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.IsCategoryProductsLoaded' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.IsCategoryProductsLoaded' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(categoryIndex, subCategoryIndex)
		local filter

		if QUEARY_ALL_ITEMS and PRIVATE.CATEGORIES[categoryIndex].hasItemList then
			filter = 1
		else
			local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
			filter = filterInfo.NON_CLASS_ITEMS and 1 or 0
		end

		local storage = PRIVATE.GenerateStorage(STORE_PRODUCT_CACHE, currencyID, categoryID, subCategoryID, filter)
		return storage[PRODUCT_STORAGE_FIELD.VERSION] ~= nil, storage[PRODUCT_STORAGE_FIELD.VERSION] == PRIVATE.GetProductListVersion()
	end
	function C_StoreSecure.GetNumCategoryProducts(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetNumCategoryProducts' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetNumCategoryProducts' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory then
			return #productList.filtered
		else
			return 0
		end
	end
	function C_StoreSecure.GetCategoryProductInfo(categoryIndex, subCategoryIndex, itemIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryProductInfo' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryProductInfo' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if not isValidCategory or itemIndex <= 0 or itemIndex > #productList.filtered then
			error(strformat("bad argument #3 to 'C_StoreSecure.GetCategoryProductInfo' (index %s out of range)", itemIndex), 2)
		end

		local product = productList.filtered[itemIndex]
		if not product then
			return UNKNOWN, nil, nil, nil, ICON_UNKNOWN
		end

		local name, itemLink, rarity, itemLevel, itemMinLevel, itemType, itemSubType, stackCount, equipLoc, icon, vendorPrice = unpack(product.itemInfo)
		local productID = product[PRODUCT_DATA_FIELD.PRODUCT_ID]
		local amount = product[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1
		local isPVP = bitband(product[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.PVP) ~= 0
		local isNew = bitband(product[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
		local isRollableUnavailable = bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0
		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product)

		local noPurchaseCanGift = false
		local isUnavailable = false

		if isRollableUnavailable then
			isUnavailable = true
		elseif bitband(product[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0 then
			if PRIVATE.CanGiftProduct(product) or PRIVATE.CanGiftProductWithLoyality(product) then
				noPurchaseCanGift = true
			else
				isUnavailable = true
			end
		end

		return name or UNKNOWN, itemLink, rarity, icon or ICON_UNKNOWN, itemLevel, amount, isPVP, isNew, isUnavailable, isRollableUnavailable, noPurchaseCanGift, productID, price, originalPrice, currencyType
	end

	function C_StoreSecure.ResetCategoryProductSortType(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.ResetCategoryProductSortType' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.ResetCategoryProductSortType' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory then
		--	PRIVATE.ResetProductSortType(categoryIndex, subCategoryIndex)
			PRIVATE.SortCategoryProductList(productList, true, false, true)
		end
	end
	function C_StoreSecure.SetCategoryProductSortType(categoryIndex, subCategoryIndex, sortType, reversed)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.SetCategoryProductSortType' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.SetCategoryProductSortType' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(sortType) ~= "number" then
			error(strformat("bad argument #3 to 'C_StoreSecure.SetCategoryProductSortType' (number expected, got %s)", sortType ~= nil and type(sortType) or "no value"), 2)
		elseif sortType < 0 or sortType > #PRODUCT_LIST_SORT_TYPE then
			error("bad argument #3 to 'C_StoreSecure.SetCategoryProductSortType' (incorrect sort type)", 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory then
			PRIVATE.SetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex, sortType, not not reversed)
			PRIVATE.SortCategoryProductList(productList, false, false, true)
		end
	end
	function C_StoreSecure.GetCategoryProductSortType(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryProductSortType' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryProductSortType' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		if PRIVATE.IsValidCategoryProductList(categoryIndex, subCategoryIndex) then
			local sortInfo = PRIVATE.GetCategoryProductSortTypeInfo(categoryIndex, subCategoryIndex)
			return sortInfo.type, sortInfo.reversed
		else
			return 0, false
		end
	end

	function C_StoreSecure.IsCategoryProductFiltersAvailable(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.IsCategoryProductFiltersAvailable' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.IsCategoryProductFiltersAvailable' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory then
			return not productList.itemListNoFilters
		end

		return false
	end
	function C_StoreSecure.ResetCategoryProductFilters(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.ResetCategoryProductFilters' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.ResetCategoryProductFilters' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory then
		--	PRIVATE.ResetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
			PRIVATE.FilterCategoryProductList(productList, true, true)
			PRIVATE.SortCategoryProductList(productList, false, true, true)
		end
	end
	function C_StoreSecure.SetCategoryProductFilters(categoryIndex, subCategoryIndex, filters)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.SetCategoryProductFilters' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.SetCategoryProductFilters' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(filters) ~= "table" then
			error(strformat("bad argument #3 to 'C_StoreSecure.SetCategoryProductFilters' (table expected, got %s)", filters ~= nil and type(filters) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory then
			PRIVATE.SetCategoryProductFilterInfo(categoryIndex, subCategoryIndex, filters, true)
			PRIVATE.SortCategoryProductList(productList, false, false, true)
		end
	end
	function C_StoreSecure.GetCategoryProductFilterOptionTypes(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryProductFilterOptionTypes' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryProductFilterOptionTypes' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		if PRIVATE.IsValidCategoryProductList(categoryIndex, subCategoryIndex) then
			local filterType, filterOptionList = PRIVATE.GetCategoryProductFilterOptions(categoryIndex, subCategoryIndex)
			if filterOptionList then
				local hasDynamicOptions

				for filterIndex, filterOptionType in ipairs(filterOptionList) do
					local filterData = CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]
					if filterData and filterData.dynamic then
						hasDynamicOptions = true
						break
					end
				end

				return filterType, hasDynamicOptions or false
			end
		end

		return -1, false
	end
	function C_StoreSecure.GetCategoryProductFilterOptions(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryProductFilterOptions' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryProductFilterOptions' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory and not productList.itemListNoFilters then
			local filterType, filterOptionList = PRIVATE.GetCategoryProductFilterOptions(categoryIndex, subCategoryIndex)
			if filterOptionList then
				local optionList = {}

				for filterIndex, filterOptionType in ipairs(filterOptionList) do
					local filterData = CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]
					if filterData and filterData.dynamic then
						if filterOptionType == PRODUCT_LIST_FILTER_OPTION.RARITY
						or filterOptionType == PRODUCT_LIST_FILTER_OPTION.ARMOR_SUB_CLASS
						or filterOptionType == PRODUCT_LIST_FILTER_OPTION.WEAPON_SUB_CLASS
						or filterOptionType == PRODUCT_LIST_FILTER_OPTION.CLASS
						then
							local options = {}
							for _, optionData in pairs(filterData.options) do
								if productList.productStats[filterOptionType] and productList.productStats[filterOptionType][optionData[2]] then
									tinsert(options, optionData)
								end
							end

							if #options > 1 then
								local filterInfo = {}

								for k, v in pairs(filterData) do
									if k ~= "options" then
										if type(v) == "table" then
											filterInfo[k] = CopyTable(v)
										else
											filterInfo[k] = v
										end
									end
								end

								filterInfo.options = options

								tinsert(optionList, filterInfo)
							end
						elseif filterOptionType == PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS
						or filterOptionType == PRODUCT_LIST_FILTER_OPTION.NEW_PRODUCT
						then
							if productList.productStats[filterOptionType] then
								local filterInfo = CopyTable(filterData)
								tinsert(optionList, filterInfo)
							end
						elseif filterOptionType == PRODUCT_LIST_FILTER_OPTION.ITEM_LEVEL_RANGE
						or filterOptionType == PRODUCT_LIST_FILTER_OPTION.PRODUCT_PRICE_RANGE
						then
							if productList.productStats[filterOptionType] then
								local filterInfo = CopyTable(filterData)
								filterInfo.minValue = productList.productStats[filterOptionType].min
								filterInfo.maxValue = productList.productStats[filterOptionType].max
								tinsert(optionList, filterInfo)
							end
						elseif filterOptionType == PRODUCT_LIST_FILTER_OPTION.ITEM_STATS then
							if productList.itemStats and #productList.itemStats > 1 then
								local filterInfo = {}

								for k, v in pairs(filterData) do
									if k ~= "options" then
										if type(v) == "table" then
											filterInfo[k] = CopyTable(v)
										else
											filterInfo[k] = v
										end
									end
								end

								local options = CopyTable(productList.itemStats)
								options.invertedFilter = not CATEGORY_PRODUCT_FILTER_TYPE[PRODUCT_LIST_FILTER_OPTION.ITEM_STATS].invertedFilter
								filterInfo.options = options

								tinsert(optionList, filterInfo)
							end
						end
					else
						local filterInfo = CopyTable(filterData)
						filterInfo.manual = nil
						tinsert(optionList, filterInfo)
					end
				end

				return filterType, optionList
			end
		end

		return -1, {}
	end
	function C_StoreSecure.GetCategoryProductFilterOptionValue(categoryIndex, subCategoryIndex, filterKey, filterKeyIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryProductFilterOptionValue' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryProductFilterOptionValue' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(filterKey) ~= "string" and type(filterKey) ~= "number" then
			error(strformat("bad argument #3 to 'C_StoreSecure.GetCategoryProductFilterOptionValue' (string|number expected, got %s)", filterKey ~= nil and type(filterKey) or "no value"), 2)
		elseif filterKeyIndex ~= nil and type(filterKeyIndex) ~= "number" then
			error(strformat("bad argument #4 to 'C_StoreSecure.GetCategoryProductFilterOptionValue' (number expected, got %s)", filterKeyIndex ~= nil and type(filterKeyIndex) or "no value"), 2)
		end

		if PRIVATE.IsValidCategoryProductList(categoryIndex, subCategoryIndex) then
			if type(filterKey) == "number" then
				filterKey = PRODUCT_LIST_FILTER_OPTION[filterKey]
			end

			local filterOptionType = PRODUCT_LIST_FILTER_OPTION[filterKey]
			local filterOption = filterOptionType and CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]

			if filterOption and filterOption.isValTable then
				if not filterKeyIndex then
					error("bad argument #4 to 'C_StoreSecure.GetCategoryProductFilterOptionValue' (no filterKeyIndex provided for ValTable filter)", 2)
				end

				local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
				if filterInfo[filterKey] and filterInfo[filterKey][filterKeyIndex] ~= nil then
					return filterInfo[filterKey][filterKeyIndex]
				end

				local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)
				if filterDefaults[filterKey] and filterDefaults[filterKey][filterKeyIndex] ~= nil then
					return filterDefaults[filterKey][filterKeyIndex]
				end
			else
				local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
				if filterInfo[filterKey] ~= nil then
					return filterInfo[filterKey]
				end

				local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)
				if filterDefaults[filterKey] ~= nil then
					return filterDefaults[filterKey]
				end
			end
		end
	end
	function C_StoreSecure.GetCategoryProductFilterOptionValueDefault(categoryIndex, subCategoryIndex, filterKey, filterKeyIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryProductFilterOptionValueDefault' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryProductFilterOptionValueDefault' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(filterKey) ~= "string" and type(filterKey) ~= "number" then
			error(strformat("bad argument #3 to 'C_StoreSecure.GetCategoryProductFilterOptionValueDefault' (string|number expected, got %s)", filterKey ~= nil and type(filterKey) or "no value"), 2)
		elseif filterKeyIndex ~= nil and type(filterKeyIndex) ~= "number" then
			error(strformat("bad argument #4 to 'C_StoreSecure.GetCategoryProductFilterOptionValueDefault' (number expected, got %s)", filterKeyIndex ~= nil and type(filterKeyIndex) or "no value"), 2)
		end

		if PRIVATE.IsValidCategoryProductList(categoryIndex, subCategoryIndex) then
			if type(filterKey) == "number" then
				filterKey = PRODUCT_LIST_FILTER_OPTION[filterKey]
			end

			local filterOptionType = PRODUCT_LIST_FILTER_OPTION[filterKey]
			local filterOption = filterOptionType and CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]

			if filterOption and filterOption.isValTable then
				if not filterKeyIndex then
					error("bad argument #4 to 'C_StoreSecure.GetCategoryProductFilterOptionValue' (no filterKeyIndex provided for ValTable filter)", 2)
				end
				local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)
				if filterDefaults[filterKey] and filterDefaults[filterKey][filterKeyIndex] ~= nil then
					return filterDefaults[filterKey][filterKeyIndex]
				end
			else
				local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)
				if filterDefaults[filterKey] ~= nil then
					return filterDefaults[filterKey]
				end
			end
		end
	end
	function C_StoreSecure.SetCategoryProductFilterOptionValue(categoryIndex, subCategoryIndex, filterKey, value, filterKeyIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.SetCategoryProductFilterOptionValue' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.SetCategoryProductFilterOptionValue' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(filterKey) ~= "string" and type(filterKey) ~= "number" then
			error(strformat("bad argument #3 to 'C_StoreSecure.SetCategoryProductFilterOptionValue' (string|number expected, got %s)", filterKey ~= nil and type(filterKey) or "no value"), 2)
		elseif filterKeyIndex ~= nil and type(filterKeyIndex) ~= "number" then
			error(strformat("bad argument #4 to 'C_StoreSecure.SetCategoryProductFilterOptionValue' (number expected, got %s)", filterKeyIndex ~= nil and type(filterKeyIndex) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory and not productList.itemListNoFilters then
			if type(filterKey) == "number" then
				filterKey = PRODUCT_LIST_FILTER_OPTION[filterKey]
			end

			local filterOptionType = PRODUCT_LIST_FILTER_OPTION[filterKey]
			local filterOption = filterOptionType and CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]

			local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
			local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)

			local filterChanged
			if filterOption and filterOption.isValTable then
				if not filterKeyIndex then
					error("bad argument #4 to 'C_StoreSecure.SetCategoryProductFilterOptionValue' (no filterKeyIndex provided for ValTable filter)", 2)
				end

				if value == false then
					value = nil
				end
				if filterInfo[filterKey][filterKeyIndex] ~= value then
					filterInfo[filterKey][filterKeyIndex] = value
					filterInfo.dirty = true
					filterChanged = true
				end
			else
				if filterDefaults[filterKey] ~= nil and filterInfo[filterKey] ~= value then
					filterInfo[filterKey] = value
					filterInfo.dirty = true
					filterChanged = true
				end
			end

			if filterChanged then
				PRIVATE.FilterCategoryProductList(productList, false, true)
				PRIVATE.SortCategoryProductList(productList, false, true, true)

				if not QUEARY_ALL_ITEMS and PRODUCT_LIST_FILTER_OPTION[filterKey] == PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS then
					FireCustomClientEvent("STORE_PRODUCT_LIST_FILTER_UPDATE", categoryIndex, subCategoryIndex)
				end
			end
		end
	end
	function C_StoreSecure.ResetCategoryProductFilterOptionValue(categoryIndex, subCategoryIndex, filterKey)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.ResetCategoryProductFilterOptionValue' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.ResetCategoryProductFilterOptionValue' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(filterKey) ~= "string" and type(filterKey) ~= "number" then
			error(strformat("bad argument #3 to 'C_StoreSecure.ResetCategoryProductFilterOptionValue' (string|number expected, got %s)", filterKey ~= nil and type(filterKey) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory and not productList.itemListNoFilters then
			if type(filterKey) == "number" then
				filterKey = PRODUCT_LIST_FILTER_OPTION[filterKey]
			end

			local filterOptionType = PRODUCT_LIST_FILTER_OPTION[filterKey]
			local filterOption = filterOptionType and CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]

			local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
			local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)

			local filterChanged
			if filterOption and filterOption.isValTable then
				if filterInfo[filterKey] and not tCompare(filterInfo[filterKey], filterDefaults[filterKey], 3) then
					filterInfo[filterKey] = CopyTable(filterDefaults[filterKey])
					filterInfo.dirty = true
					filterChanged = true
				end
			else
				if strsub(filterKey, -6, -1) == "_RANGE" then
					local filterKeyMin = strconcat(filterKey, "_MIN")
					if filterInfo[filterKeyMin] ~= filterDefaults[filterKeyMin] then
						filterInfo[filterKeyMin] = filterDefaults[filterKeyMin]
						filterInfo.dirty = true
						filterChanged = true
					end
					filterKey = strconcat(filterKey, "_MAX")
				end

				if filterInfo[filterKey] ~= filterDefaults[filterKey] then
					filterInfo[filterKey] = filterDefaults[filterKey]
					filterInfo.dirty = true
					filterChanged = true
				end
			end

			if filterChanged then
				PRIVATE.FilterCategoryProductList(productList, false, true)
				PRIVATE.SortCategoryProductList(productList, false, true, true)

				if not QUEARY_ALL_ITEMS and PRODUCT_LIST_FILTER_OPTION[filterKey] == PRODUCT_LIST_FILTER_OPTION.NON_CLASS_ITEMS then
					FireCustomClientEvent("STORE_PRODUCT_LIST_FILTER_UPDATE", categoryIndex, subCategoryIndex)
				end
			end
		end
	end
	function C_StoreSecure.IsCategoryProductFilterOptionValueChanged(categoryIndex, subCategoryIndex, filterKey)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.IsCategoryProductFilterOptionValueChanged' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.IsCategoryProductFilterOptionValueChanged' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(filterKey) ~= "string" and type(filterKey) ~= "number" then
			error(strformat("bad argument #3 to 'C_StoreSecure.IsCategoryProductFilterOptionValueChanged' (string|number expected, got %s)", filterKey ~= nil and type(filterKey) or "no value"), 2)
		end

		local productList, isValidCategory = PRIVATE.GetCategoryProductList(categoryIndex, subCategoryIndex)
		if isValidCategory and not productList.itemListNoFilters then
			if type(filterKey) == "number" then
				filterKey = PRODUCT_LIST_FILTER_OPTION[filterKey]
			end

			local filterOptionType = PRODUCT_LIST_FILTER_OPTION[filterKey]
			local filterOption = filterOptionType and CATEGORY_PRODUCT_FILTER_TYPE[filterOptionType]

			local filterInfo = PRIVATE.GetCategoryProductFilterInfo(categoryIndex, subCategoryIndex)
			local filterDefaults = PRIVATE.GetDefaultProductFilter(categoryIndex, subCategoryIndex)

			if filterOption and filterOption.isValTable then
				if filterInfo[filterKey] and not tCompare(filterInfo[filterKey], filterDefaults[filterKey], 3) then
					return true
				end
			else
				if strsub(filterKey, -6, -1) == "_RANGE" then
					local filterKeyMin = strconcat(filterKey, "_MIN")
					if filterInfo[filterKeyMin] ~= filterDefaults[filterKeyMin] then
						return true
					end
					filterKey = strconcat(filterKey, "_MAX")
				end

				if filterInfo[filterKey] ~= filterDefaults[filterKey] then
					return true
				end
			end
		end

		return false
	end
end

do -- Premium
	function C_StoreSecure.IsPremiumActive()
		PRIVATE.UpdatePremiumRemainingTime()
		return PRIVATE.PREMIUM_REMAINING_TIME ~= 0
	end

	function C_StoreSecure.IsPremiumPermanent()
		PRIVATE.UpdatePremiumRemainingTime()
		return PRIVATE.PREMIUM_REMAINING_TIME == STORE_PERMANENT_PREMIUM
	end

	function C_StoreSecure.GetPremiumTimeLeft()
		PRIVATE.UpdatePremiumRemainingTime()
		return mathfloor(PRIVATE.PREMIUM_REMAINING_TIME)
	end

	function C_StoreSecure.GetNumPremiumBonuses()
		return #PRIVATE.PREMIUM_BONUSES
	end

	function C_StoreSecure.GetPremiumBonusInfo(index)
		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetPremiumBonusInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		elseif index < 1 or index > #PRIVATE.PREMIUM_BONUSES then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetPremiumBonusInfo' (index %s out of range)", index), 2)
		end

		local bonus = PRIVATE.PREMIUM_BONUSES[index]
		local value
		if index == 3 and C_Service.GetRealmID() == E_REALM_ID.SOULSEEKER then
			value = 20
		else
			value = bonus.value
		end

		return strformat(bonus.text, value), bonus.atlas
	end

	function C_StoreSecure.GetNumPremiumOptions()
		return #PRIVATE.PREMIUM_DATA
	end

	function C_StoreSecure.GetPremiumOptionInfo(index)
		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetPremiumOptionInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		elseif index < 1 or index > #PRIVATE.PREMIUM_DATA then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetPremiumOptionInfo' (index %s out of range)", index), 2)
		end

		local option = PRIVATE.PREMIUM_DATA[index]
		return option.text, option.discountText, option.price, 0, Enum.Store.CurrencyType.Bonus
	end

	function C_StoreSecure.PurchasePremiumOption(index)
		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.PurchasePremiumOption' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		elseif index < 1 or index > #PRIVATE.PREMIUM_DATA then
			error(strformat("bad argument #1 to 'C_StoreSecure.PurchasePremiumOption' (index %s out of range)", index), 2)
		end

		local option = PRIVATE.PREMIUM_DATA[index]

		if option.price > PRIVATE.GetBalance(Enum.Store.CurrencyType.Bonus) and not C_Service.IsInGMMode() then
			FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_PURCHASE_ERROR_BALANCE_BONUS)
			return
		end

		PRIVATE.PurchasePremium(index)
	end
end

do -- Categories
	function C_StoreSecure.RequestNewCategoryItems()
		PRIVATE.RequestNewCategoryItems()
	end

	function C_StoreSecure.GetNumCategories()
		return #PRIVATE.CATEGORIES
	end

	function C_StoreSecure.GetNumSubCategories(categoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetNumSubCategories' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif categoryIndex < 1 or categoryIndex > #PRIVATE.CATEGORIES then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetNumSubCategories' (index %s out of range)", categoryIndex), 2)
		end

		if PRIVATE.SUB_CATEGORIES[categoryIndex] then
			local num = 0
			for i, subCategory in ipairs(PRIVATE.SUB_CATEGORIES[categoryIndex]) do
				if not subCategory.isHidden then
					num = num + 1
				end
			end
			return num
		else
			return 0
		end
	end

	function C_StoreSecure.GetSelectedCategory()
		return PRIVATE.SELECTED_CATEGORY_INDEX, PRIVATE.SELECTED_SUB_CATEGORY_INDEX
	end

	function C_StoreSecure.SetSelectedCategory(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.SetSelectedCategory' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif subCategoryIndex ~= nil and type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.SetSelectedCategory' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		end

		PRIVATE.SetSelectedCategory(categoryIndex, subCategoryIndex)
	end

	function C_StoreSecure.GetCategoryInfo(categoryIndex, subCategoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryInfo' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		elseif categoryIndex < 1 or categoryIndex > #PRIVATE.CATEGORIES then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCategoryInfo' (index %s out of range)", categoryIndex), 2)
		elseif subCategoryIndex ~= nil and type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCategoryInfo' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		end

		local category = PRIVATE.CATEGORIES[categoryIndex]
		subCategoryIndex = PRIVATE.GetAdjustedSubCategoryIndex(categoryIndex, subCategoryIndex)

		if subCategoryIndex == 0 then -- category info
			local visible, enabled, reason = PRIVATE.CategoryIsAvailable(category)
			if visible then
				local name = category.name
				local icon = category.icon
				local isNew = PRIVATE.IsCategoryNew(categoryIndex, nil, true)

				if not icon then
					icon = strconcat(CATEGORY_ICON_PATH, "category-icon-placeholder")
				end

				return name, icon, isNew or false, enabled, reason
			end
		else -- subCategory info
			local subCategory = PRIVATE.SUB_CATEGORIES[categoryIndex][subCategoryIndex]
			local visible, enabled, reason = PRIVATE.CategoryIsAvailable(subCategory)
			if visible then
				local name = subCategory.name
				local icon = subCategory.icon
				local isNew = PRIVATE.IsCategoryNew(categoryIndex, subCategoryIndex, true)

				if not icon or not C_Texture.HasAtlasInfo(icon) then
					icon = "PKBT-Store-Icon-Category-Placeholder"
				end
				return name, icon, isNew, enabled, reason
			end
		end
	end

	function C_StoreSecure.IsAnyCategoryRenewed()
		return PRIVATE.IsAnyCategoryRenewed()
	end

	function C_StoreSecure.IsCategoryRenewed(categoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.IsCategoryRenewed' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		end

		return PRIVATE.IsCategoryRenewed(categoryIndex)
	end

	function C_StoreSecure.SetCategoryRenewSeen(categoryIndex)
		if type(categoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.SetCategoryRenewSeen' (number expected, got %s)", categoryIndex ~= nil and type(categoryIndex) or "no value"), 2)
		end

		PRIVATE.SetCategoryRenewSeen(categoryIndex)
	end
end

do -- Recommendations
	function C_StoreSecure.GetNumRecommendations()
		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Main, 1, 0)
		return #storage
	end

	function C_StoreSecure.GetRecommendationInfo(index)
		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetRecommendationInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		end

		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Main, 1, 0)

		if index < 1 or index > #storage then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetRecommendationInfo' (index %s out of range)", index), 2)
		end

		local product = storage[index]
		if not product then
			return
		end

		local name, link, rarity, itemLevel, minLevel, itemType, itemSubType, stackCount, equipLoc, icon, vendorPrice = GetItemInfo(product[PRODUCT_DATA_FIELD.ITEM_ID])
		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product)
		local modelType, modelID = PRIVATE.GetProductModelInfo(product)
		local artwork

		return name, link, rarity or ITEM_RARITY_FALLBACK, icon or ICON_UNKNOWN,
			artwork, modelType, modelID,
			product[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1,
			product[PRODUCT_DATA_FIELD.PRODUCT_ID],
			price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
	end
end

do -- Offer
	function C_StoreSecure.RequestNextSpecialOfferTime()
		PRIVATE.RequestNextSpecialOfferTime()
	end

	function C_StoreSecure.IsNextSpecialOfferLoaded()
		return not PRIVATE.SPECIAL_OFFER_NEXT_AWAIT
	end

	function C_StoreSecure.GetNextSpecialOfferTimeLeft()
		if not STORE_DATA_CACHE.SPECIAL_OFFER_NEXT_TIMESTAMP then
			return 0
		end
		local timeLeft = mathmax(0, STORE_DATA_CACHE.SPECIAL_OFFER_NEXT_TIMESTAMP - time())
		if timeLeft == 0 then
			STORE_DATA_CACHE.SPECIAL_OFFER_NEXT_TIMESTAMP = nil
		end
		return timeLeft
	end

	function C_StoreSecure.RequestSpecialOfferInfo()
		PRIVATE.RequestSpecialOfferInfo()
	end

	function C_StoreSecure.IsSpecialOfferLoaded()
		return not PRIVATE.OFFER_LIST_AWAIT
	end

	function C_StoreSecure.ClearOfferNewFlag(offerIndex)
		if type(offerIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.ClearOfferNewFlag' (number expected, got %s)", offerIndex ~= nil and type(offerIndex) or "no value"), 2)
		elseif offerIndex < 1 or offerIndex > #PRIVATE.OFFER_LIST then
			error(strformat("bad argument #1 to 'C_StoreSecure.ClearOfferNewFlag' (index %s out of range)", offerIndex), 2)
		end

		local offer = PRIVATE.OFFER_LIST[offerIndex]
		PRIVATE.OFFER_IS_NEW[offer.offerID] = false
	end

	function C_StoreSecure.GetNumSpecialOffers()
		return #PRIVATE.OFFER_LIST
	end

	function C_StoreSecure.GetSpecialOfferIndexByID(offerID)
		if type(offerID) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSpecialOfferIndexByID' (number expected, got %s)", offerID ~= nil and type(offerID) or "no value"), 2)
		end

		local offer = PRIVATE.OFFER_MAP[offerID]
		if not offer then
			return
		end

		return tIndexOf(PRIVATE.OFFER_LIST, offer)
	end

	function C_StoreSecure.GetSpecialOfferInfo(offerIndex)
		if type(offerIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSpecialOfferInfo' (number expected, got %s)", offerIndex ~= nil and type(offerIndex) or "no value"), 2)
		elseif offerIndex < 1 or offerIndex > #PRIVATE.OFFER_LIST then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSpecialOfferInfo' (index %s out of range)", offerIndex), 2)
		end

		local offer = PRIVATE.OFFER_LIST[offerIndex]
		local remainingTime
		if offer.remainingTime > 0 then
			remainingTime = offer.remainingTime - (time() - offer.timestamp)
		else
			remainingTime = -1
		end

		local isNew = PRIVATE.OFFER_IS_NEW[offer.offerID] or false

		return offer.offerID, offer.title, offer.name, offer.description, remainingTime,
			offer.price, offer.originalPrice, offer.currencyType,
			offer.productID, offer.isFreeSubscribe, isNew
	end

	function C_StoreSecure.GetSpecialOfferStyleInfo(offerIndex)
		if type(offerIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSpecialOfferStyleInfo' (number expected, got %s)", offerIndex ~= nil and type(offerIndex) or "no value"), 2)
		elseif offerIndex < 1 or offerIndex > #PRIVATE.OFFER_LIST then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSpecialOfferStyleInfo' (index %s out of range)", offerIndex), 2)
		end

		local offer = PRIVATE.OFFER_LIST[offerIndex]
		local style

		if PRIVATE.OFFERS_MODEL_DATA[offer.offerID] and PRIVATE.OFFERS_MODEL_DATA[offer.offerID].Banner then
			style = CopyTable(PRIVATE.OFFERS_MODEL_DATA[offer.offerID].Banner)
		else
			style = {
				BorderColor			= {0.38, 0.88, 1},
				NameColor			= {1, 1, 1},
				DescriptionColor	= {1, 0.9294, 0.7607},
				TimerColor			= {0.92, 0.9, 1},
				TitleColor			= {1, 0.9294, 0.7607},
				PriceLabelColor		= {0.67, 0.34, 0.63},
				PriceColor			= {1, 1, 1},
			}
		end

		style.background = strconcat([[Interface\Custom\StoreBanner\]], offer.background)
		style.backgroundTexCoords = {0, 0.570312, 0, 1}

		return style
	end

	function C_StoreSecure.GetOfferPopupInfo(offerPopupIndex)
		if type(offerPopupIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetOfferPopupInfo' (number expected, got %s)", offerPopupIndex ~= nil and type(offerPopupIndex) or "no value"), 2)
		elseif offerPopupIndex < 1 or offerPopupIndex > #PRIVATE.OFFER_POPUP_SMALL_LIST then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetOfferPopupInfo' (index %s out of range)", offerPopupIndex), 2)
		end

		local offerID = PRIVATE.OFFER_POPUP_SMALL_LIST[offerPopupIndex]
		local offer = PRIVATE.OFFER_POPUP_DATA[offerID]
		local offerModelData = PRIVATE.OFFERS_MODEL_DATA[offerID]

		if offerModelData and offerModelData.PopupModelInfo then
			return offerID, offer.text, CopyTable(offerModelData.PopupModelInfo)
		else
			return offerID, offer.text
		end
	end

	function C_StoreSecure.GetSpecialOfferFullscreenPopupInfo()
		if not PRIVATE.OFFER_POPUP_FULLSCREEN_ENABLED or not PRIVATE.OFFER_POPUP_FULLSCREEN.id then
			return nil, nil, nil, nil, -1, {}
		end

		local offer = PRIVATE.OFFER_POPUP_FULLSCREEN
		local remainingTime = offer.remainingTime - (time() - offer.timestamp)
		local items = CopyTable(offer.items)

		return offer.title, offer.name, offer.description, offer.texture, remainingTime, items
	end
end

do -- Refund
	function C_StoreSecure.RequestRefundList()
		PRIVATE.RequestRefundList()
	end

	function C_StoreSecure.GetNumRefundProducts()
		PRIVATE.CheckRefundProductTimers()
		return #PRIVATE.REFUND_LIST
	end

	function C_StoreSecure.GetRefundProductInfo(index)
		PRIVATE.CheckRefundProductTimers()

		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetRefundProductInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		elseif index < 1 or index > #PRIVATE.REFUND_LIST then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetRefundProductInfo' (index %s out of range)", index), 2)
		end

		local product = PRIVATE.REFUND_LIST[index]
		local remainingTime = mathmax(0, product.remainingTime - (time() - product.requestTime))

		return product.itemLink or product.itemID,
			product.amount or 1,
			product.purchaseDate,
			remainingTime,
			product.penalty,
			product.price,
			product.originalPrice,
			product.currencyType
	end

	function C_StoreSecure.IsAwaitingRefundList()
		return PRIVATE.REFUND_LIST_AWAIT ~= nil
	end

	function C_StoreSecure.IsAwaitingRefundAnswer()
		return PRIVATE.REFUND_RESULT_AWAIT ~= nil
	end

	local checkRefundProductArg = function(index, productIndex)
		if type(productIndex) ~= "number" then
			error(strformat("bad argument #%d to 'C_StoreSecure.RefundProductIndexes' (number expected, got %s)", index, productIndex ~= nil and type(productIndex) or "no value"), 3)
		elseif productIndex < 1 or productIndex > #PRIVATE.REFUND_LIST then
			error(strformat("bad argument #%d to 'C_StoreSecure.RefundProductIndexes' (index %s out of range)", index, productIndex), 3)
		end
		return true
	end

	function C_StoreSecure.RefundProductIndexes(...)
		checkRefundProductArg(1, ...)

		if PRIVATE.REFUND_RESULT_AWAIT then
			return
		end

		local itemGUIDs = {}

		for index = 1, select("#", ...) do
			local productIndex = select(index, ...)
			checkRefundProductArg(index, productIndex)

			local item = PRIVATE.REFUND_LIST[productIndex]
			if item.itemGUID then
				tinsert(itemGUIDs, item.itemGUID)
			end
		end

		if #itemGUIDs ~= 0 then
			local success = PRIVATE.RequestRefundItemGUID(unpack(itemGUIDs))
			return success
		end

		return false
	end
end

do -- Equipment
	function C_StoreSecure.GetNumEquipmentSlots()
		return #PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Equipment]
	end

	function C_StoreSecure.GetEquipmentSlotInfo(slotIndex)
		if type(slotIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetEquipmentSlotInfo' (number expected, got %s)", slotIndex ~= nil and type(slotIndex) or "no value"), 2)
		elseif slotIndex < 1 or slotIndex > #PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Equipment] then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetEquipmentSlotInfo' (index %s out of range)", slotIndex), 2)
		end

		local slotInfo = PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Equipment][slotIndex]
		return slotInfo.slotID, slotInfo.name, slotInfo.icon
	end

	function C_StoreSecure.HasEquipmentSlotNewItems(slotIndex)
		if type(slotIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.HasEquipmentSlotNewItems' (number expected, got %s)", slotIndex ~= nil and type(slotIndex) or "no value"), 2)
		elseif slotIndex < 1 or slotIndex > #PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Equipment] then
			error(strformat("bad argument #1 to 'C_StoreSecure.HasEquipmentSlotNewItems' (index %s out of range)", slotIndex), 2)
		end

		return PRIVATE.IsCategoryNew(Enum.Store.Category.Equipment, slotIndex)
	end

	function C_StoreSecure.RequestEquipmentItemLevels()
		return PRIVATE.RequestEquipmentItemLevels()
	end

	function C_StoreSecure.HasEquipmentSlotUpgradeItems(slotIndex)
		if type(slotIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.HasEquipmentSlotUpgradeItems' (number expected, got %s)", slotIndex ~= nil and type(slotIndex) or "no value"), 2)
		elseif slotIndex < 1 or slotIndex > #PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Equipment] then
			error(strformat("bad argument #1 to 'C_StoreSecure.HasEquipmentSlotUpgradeItems' (index %s out of range)", slotIndex), 2)
		end

		return PRIVATE.HasEquipmentSlotUpgradeItems(slotIndex)
	end
end

do -- Purchase product
	function C_StoreSecure.GetGiftTextMaxLetters()
		return GIFT_TEXT_MAX_LETTERS
	end

	function C_StoreSecure.GetNumPurchaseGiftOptions()
		return #PRIVATE.GIFT_OPTIONS
	end

	function C_StoreSecure.GetPurchaseGiftOption(index)
		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetPurchaseGiftOption' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		elseif index < 1 or index > #PRIVATE.GIFT_OPTIONS then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetPurchaseGiftOption' (index %s out of range)", index), 2)
		end

		local options = PRIVATE.GIFT_OPTIONS[index]
		return options.id, options.name, options.texture.."1", options.texture.."2"
	end

	function C_StoreSecure.IsAwaitingPurchaseAnswer()
		return PRIVATE.PENDING_PURCHASE_AWAIT_ANSWER ~= nil
	end

	function C_StoreSecure.PurchaseProduct(productID, options)
		if type(productID) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.PurchaseProduct' (number expected, got %s)", productID ~= nil and type(productID) or "no value"), 2)
		elseif options and type(options) ~= "table" then
			error(strformat("bad argument #2 to 'C_StoreSecure.PurchaseProduct' (table expected, got %s)", options ~= nil and type(options) or "no value"), 2)
		end

		local product = PRIVATE.GetProductByID(productID)
		if not product then
			error(strformat("C_StoreSecure.PurchaseProduct: Product #%s not found", productID))
		end

		local success = PRIVATE.PurchaseProduct(product, options)
		return success
	end
end

do -- Subscription
	PRIVATE.GetSubscriptionRemainingTime = function(subscription)
		if not subscription.timestamp then
			return 0, 0, 0
		end

		local timeSinceUpdate = time() - subscription.timestamp
		local remainingTime = subscription.remainingSubscriptionSeconds - timeSinceUpdate
		local nextSupplyTime, remainingSupplyTimes

		if remainingTime <= 0 then
			subscription.remainingSubscriptionSeconds = nil
			subscription.nextSupplySeconds = nil
			subscription.remainingDays = nil

			-- verify end of subscription
			PRIVATE.RequestSubscriptions()
		end

		if remainingTime and remainingTime > 0 then
			if timeSinceUpdate < subscription.nextSupplySeconds then
				nextSupplyTime = subscription.nextSupplySeconds - timeSinceUpdate
			else
				nextSupplyTime = remainingTime % SECONDS_PER_DAY
			end
			remainingSupplyTimes = mathfloor((remainingTime - nextSupplyTime) / SECONDS_PER_DAY)
		else
			remainingTime = 0
			nextSupplyTime = 0
			remainingSupplyTimes = 0
		end

		return remainingTime, nextSupplyTime, remainingSupplyTimes
	end

	PRIVATE.GetSubscriptionState = function(subscription)
		local remainingTime, nextSupplyTime, remainingSupplyTimes = PRIVATE.GetSubscriptionRemainingTime(subscription)
		local state

		if remainingTime > 0 then
			if subscription.trialActive then
				state = Enum.Store.SubscriptionState.TrialActive
			elseif subscription.extraActive then
				state = Enum.Store.SubscriptionState.ExtraActive
			else
				state = Enum.Store.SubscriptionState.StandardActive
			end
		else
			if subscription.trialAvailable then
				state = Enum.Store.SubscriptionState.InactiveTrialAvailable
			else
				state = Enum.Store.SubscriptionState.Inactive
			end
		end

		return state, remainingTime, nextSupplyTime, remainingSupplyTimes
	end

	PRIVATE.GetNumSubscriptionOptions = function(subscription)
		local state = PRIVATE.GetSubscriptionState(subscription)
		if state == Enum.Store.SubscriptionState.InactiveTrialAvailable then
			return 1
		end
		return #SUBSCRIPTION_OPTIONS
	end

	function C_StoreSecure.RequestSubscriptions()
		PRIVATE.RequestSubscriptions()
	end

	function C_StoreSecure.GetSubscriptionIndexByID(subscriptionID)
		if type(subscriptionID) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSubscriptionIndexByID' (number expected, got %s)", subscriptionID ~= nil and type(subscriptionID) or "no value"), 2)
		end

		local index = tIndexOf(PRIVATE.SUBSCRIPTION_MAP, subscriptionID)
		return index
	end

	function C_StoreSecure.IsSubscriptionsLoaded()
		return not PRIVATE.SUBSCRIPTION_LIST_LOADING
	end

	function C_StoreSecure.GetNumSubscriptions()
		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return 0
		end
		return #PRIVATE.SUBSCRIPTION_MAP
	end

	local SUBSCRIPTION_ATLAS_SUFFIX = {
		[Enum.Store.SubscriptionType.Julia]			= "Julia",
		[Enum.Store.SubscriptionType.Pets]			= "Pets",
		[Enum.Store.SubscriptionType.Mounts]		= "Mounts",
		[Enum.Store.SubscriptionType.Transmogrify]	= "Transmogrify",
		[Enum.Store.SubscriptionType.AllInclusive]	= "AllInclusive",
		[Enum.Store.SubscriptionType.StrategicPack]	= "StrategicPack",
	}

	function C_StoreSecure.GetSubscriptionInfo(subscriptionIndex)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSubscriptionInfo' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]

		local remainingTime, nextSupplyTime, remainingDays = PRIVATE.GetSubscriptionRemainingTime(subscription)

		local name = subscription.name
		local description = subscription.description

		local atlasSuffix = SUBSCRIPTION_ATLAS_SUFFIX[subscriptionID] or SUBSCRIPTION_ATLAS_SUFFIX[1]
		local backgroundAtlas = "PKBT-Store-Subscription-Background-" .. atlasSuffix
		local bannerAtlas = "PKBT-Store-Subscription-Banner-" .. atlasSuffix
		local artworkAtlas = "PKBT-Store-Subscription-Artwork-" .. atlasSuffix
		local styleType = remainingTime > 0 and 1 or 2

		return subscriptionID, name, description, styleType, backgroundAtlas, bannerAtlas, artworkAtlas
	end

	function C_StoreSecure.GetSubscriptionItems(subscriptionIndex, includeBonusItems)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSubscriptionItems' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return {}
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]

		local itemList = {}
		for i = 1, #subscription.dailyItems do
			local item = subscription.dailyItems[i]
			itemList[#itemList + 1] = {item.itemID, item.amount, false}
		end
		if includeBonusItems then
			for i = 1, #subscription.onSubscribeItems do
				local item = subscription.onSubscribeItems[i]
				itemList[#itemList + 1] = {item.itemID, item.amount, true}
			end
		end

		return itemList
	end

	function C_StoreSecure.GetSubscriptionState(subscriptionIndex)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSubscriptionState' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]

		return PRIVATE.GetSubscriptionState(subscription)
	end

	function C_StoreSecure.GetSubscriptionUpgradeInfo(subscriptionIndex)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSubscriptionUpgradeInfo' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]

		local upgradeMultiplier = subscription.extraActive and 2 or 1
		local currencyType = Enum.Store.CurrencyType.Bonus

		local state, remainingTime, nextSupplyTime = PRIVATE.GetSubscriptionState(subscription)
		if state ~= Enum.Store.SubscriptionState.StandardActive or remainingTime == 0 then
			return upgradeMultiplier, currencyType, NO_PRODUCT_PRICE, NO_PRODUCT_PRICE, nil
		end

		local upgradeOption = subscription.virtualProducts[SUBSCRIPTION_UPGRADE_OPTION_INDEX]
		if not upgradeOption then
			return upgradeMultiplier, currencyType, NO_PRODUCT_PRICE, NO_PRODUCT_PRICE, nil
		end

		local productID = upgradeOption.productID
		local price = subscription.priceExtra
		local originalPrice = price

		return upgradeMultiplier, currencyType, price, originalPrice, productID
	end

	function C_StoreSecure.GetNumSubscriptionOptions(subscriptionIndex)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetNumSubscriptionOptions' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]

		return PRIVATE.GetNumSubscriptionOptions(subscription)
	end

	function C_StoreSecure.GetSubscriptionOptionInfo(subscriptionIndex, optionIndex)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetSubscriptionOptionInfo' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		elseif not optionIndex or type(optionIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetSubscriptionOptionInfo' (number expected, got %s)", optionIndex ~= nil and type(optionIndex) or "no value"), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]

		if optionIndex < 0 or optionIndex > PRIVATE.GetNumSubscriptionOptions(subscription) then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetSubscriptionOptionInfo' (index %s out of range)", optionIndex), 2)
		end

		local state = PRIVATE.GetSubscriptionState(subscription)
		local days, isTrial, price, originalPrice, currencyType, productID

		if state == Enum.Store.SubscriptionState.InactiveTrialAvailable then
			days = 2
			isTrial = true
			currencyType = Enum.Store.CurrencyType.Bonus
			price = 0
			originalPrice = 0
			productID = subscription.virtualProducts[0].productID
		else
			days = SUBSCRIPTION_OPTIONS[optionIndex]
			isTrial = false
			currencyType = Enum.Store.CurrencyType.Bonus

			if optionIndex == 1 then
				if state == Enum.Store.SubscriptionState.StandardActive
				or state == Enum.Store.SubscriptionState.ExtraActive
				then
					days = days + 1
				end
				price = subscription.priceShort
			elseif optionIndex == 2 then
				if state == Enum.Store.SubscriptionState.StandardActive
				or state == Enum.Store.SubscriptionState.ExtraActive
				then
					days = days + 3
				end
				price = subscription.priceLong
			end

			originalPrice = price
			productID = subscription.virtualProducts[optionIndex].productID
		end

		return days, isTrial, price, originalPrice or 0, currencyType, productID
	end

	function C_StoreSecure.PurchaseSubcription(subscriptionIndex, optionIndex)
		if type(subscriptionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.PurchaseSubcription' (number expected, got %s)", subscriptionIndex ~= nil and type(subscriptionIndex) or "no value"), 2)
		elseif not optionIndex or type(optionIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.PurchaseSubcription' (number expected, got %s)", optionIndex ~= nil and type(optionIndex) or "no value"), 2)
		elseif optionIndex < 0 or optionIndex > SUBSCRIPTION_UPGRADE_OPTION_INDEX then
			error(strformat("bad argument #2 to 'C_StoreSecure.PurchaseSubcription' (index %s out of range)", optionIndex), 2)
		end

		if PRIVATE.SUBSCRIPTION_LIST_LOADING then
			return
		end

		local subscriptionID = PRIVATE.SUBSCRIPTION_MAP[subscriptionIndex]
		local subscription = PRIVATE.SUBSCRIPTION_LIST[subscriptionID]
		local product = subscription.virtualProducts[optionIndex]
		if not product then
			error("bad argument #2 to 'C_StoreSecure.PurchaseSubcription' (product for optionIndex not found)", 2)
		end

		if product.optionIndex == 0 and not subscription.trialAvailable then
			FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_ERROR_SUBSCRIPTION_TRIAL_UNAVAILABLE)
			return false
		end

		if product.optionIndex == SUBSCRIPTION_UPGRADE_OPTION_INDEX then
			local state, remainingTime, nextSupplyTime = PRIVATE.GetSubscriptionState(subscription)
			if remainingTime == 0 then
				FireCustomClientEvent(PRIVATE.GetPurchaseErrorEventName(), STORE_ERROR_SUBSCRIPTION_UPGRADE_UNAVAILABLE)
				return false
			end
		end

		local success = PRIVATE.PurchaseProduct(product)
		return success
	end
end

do -- Collection
	PRIVATE.SortCollectionProducts = function(productA, productB)
		local isFavoriteA = PRIVATE.IsFavoriteProductID(productA[PRODUCT_DATA_FIELD.PRODUCT_ID])
		local isFavoriteB = PRIVATE.IsFavoriteProductID(productB[PRODUCT_DATA_FIELD.PRODUCT_ID])
		if isFavoriteA ~= isFavoriteB then
			return isFavoriteA
		end

		local isRollableUnavailableA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0
		local isRollableUnavailableB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.ROLLABLE_UNAVAILABLE) ~= 0
		if isRollableUnavailableA ~= isRollableUnavailableB then
			return isRollableUnavailableB
		end

		local hasOfferA = PRIVATE.GetOfferForProduct(productA) ~= nil
		local hasOfferB = PRIVATE.GetOfferForProduct(productB) ~= nil
		if hasOfferA ~= hasOfferB then
			return hasOfferA
		end

		local noPurchaseCanGiftA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0 and not PRIVATE.CanGiftProduct(productA)
		local noPurchaseCanGiftB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS_DYNAMIC], PRODUCT_FLAG_DYNAMIC.NO_PURCHASE_CAN_GIFT) ~= 0 and not PRIVATE.CanGiftProduct(productB)
		if noPurchaseCanGiftA ~= noPurchaseCanGiftB then
			return noPurchaseCanGiftB
		end

		local isNewA = bitband(productA[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
		local isNewB = bitband(productB[PRODUCT_DATA_FIELD.FLAGS], PRODUCT_FLAG.NEW) ~= 0
		if isNewA ~= isNewB then
			return isNewA
		end

		local priceA = PRIVATE.GetProductPrice(productA)
		local priceB = PRIVATE.GetProductPrice(productB)
		if priceA ~= priceB then
			return priceA > priceB
		end

		return productA[PRODUCT_DATA_FIELD.PRODUCT_ID] > productB[PRODUCT_DATA_FIELD.PRODUCT_ID]
	end

	PRIVATE.GetCollectionProductStorage = function(subCategoryIndex)
		if BLOCK_COLLECTION_LISTS_WITHOUT_ROLL_TIMER then
			local timeLeft, isRefreshAvailable = PRIVATE.GetCollectionRefreshTimeLeft(subCategoryIndex)
			if timeLeft == -1 then
				-- await for timer
				return
			elseif timeLeft <= 0 then
				-- force invalidate storage and request new data
				local currencyID, categoryID, subCategoryID = PRIVATE.GetRemoteCategoryIDs(Enum.Store.Category.Collections, subCategoryIndex)
				PRIVATE.WipeProductStorage(currencyID, categoryID, subCategoryID)
				PRIVATE.GetProductStorage(Enum.Store.Category.Collections, subCategoryIndex, 0)
				return
			end
		end

		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Collections, subCategoryIndex, 0)
		return storage, storageDirty
	end

	PRIVATE.GetCollectionProductList = function(subCategoryIndex)
		local storage, storageDirty = PRIVATE.GetCollectionProductStorage(subCategoryIndex)
		if not storage or storageDirty or #storage == 0 then
			return
		end

		local productList = PRIVATE.GenerateStorage(PRIVATE.COLLECTION_PRODUCT_LIST, subCategoryIndex)

		if not productList.VERSION
		or productList.VERSION ~= storage[PRODUCT_STORAGE_FIELD.VERSION]
		or productList.VERSION_FACTION ~= storage[PRODUCT_STORAGE_FIELD.VERSION_FACTION]
		or productList.VERSION_ROLLED ~= storage[PRODUCT_STORAGE_FIELD.VERSION_ROLLED]
		then
			productList.VERSION = storage[PRODUCT_STORAGE_FIELD.VERSION]
			productList.VERSION_FACTION = storage[PRODUCT_STORAGE_FIELD.VERSION_FACTION]
			productList.VERSION_ROLLED = storage[PRODUCT_STORAGE_FIELD.VERSION_ROLLED]
			productList.dirty = true
		end

		if productList.dirty then
			if not productList.products then
				productList.products = {}
			else
				twipe(productList.products)
			end

			for index, product in ipairs(storage) do
				productList.products[index] = product
			end

			tsort(productList.products, PRIVATE.SortCollectionProducts)

			productList.dirty = nil
		end

		return productList.products
	end

	function C_StoreSecure.GetNumCollectionProducts(subCategoryIndex)
		local storage, storageDirty = PRIVATE.GetCollectionProductStorage(subCategoryIndex)
		if not storage or storageDirty then
			return 0
		end
		return #storage
	end

	function C_StoreSecure.GetCollectionProductID(subCategoryIndex, index)
		if type(subCategoryIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCollectionProductID' (number expected, got %s)", subCategoryIndex ~= nil and type(subCategoryIndex) or "no value"), 2)
		elseif type(index) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCollectionProductID' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		elseif subCategoryIndex < 1 or subCategoryIndex > #Enum.Store.CollectionType then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetCollectionProductID' (index %s out of range)", subCategoryIndex), 2)
		end

		local productList = PRIVATE.GetCollectionProductList(subCategoryIndex)
		if not productList then
			return 0
		end

		if index < 1 or index > #productList then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetCollectionProductID' (index %s out of range)", index), 2)
		end

		local product = productList[index]
		if not product then
			return
		end

		return product[PRODUCT_DATA_FIELD.PRODUCT_ID]
	end

	function C_StoreSecure.GetCollectionRefreshTimeLeft(subCategoryIndex)
		return PRIVATE.GetCollectionRefreshTimeLeft(subCategoryIndex)
	end

	function C_StoreSecure.GetRefreshCollectionProductID(subCategoryIndex)
		local productID = PRIVATE.GetListRefreshProductID(Enum.Store.Category.Collections, subCategoryIndex)
		if PRIVATE.GetProductByID(productID) then
			return productID
		end
	end
end

do -- Transmog
	function C_StoreSecure.RequestNextTransmogOfferTime()
		PRIVATE.RequestNextTransmogOfferTime()
	end

	function C_StoreSecure.IsNextTransmogOfferLoaded()
		return not PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT
	end

	function C_StoreSecure.GetNextTransmogOfferTimeLeft()
		if not STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP then
			return 0
		end
		local timeLeft = mathmax(0, STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP - time())
		if timeLeft == 0 then
			STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP = nil
		end
		return timeLeft
	end

	function C_StoreSecure.GetNumTransmogSubCategories()
		return #PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Transmogrification]
	end

	function C_StoreSecure.GetTransmogSubCategoryArtwork(transmogTypeIndex)
		if type(transmogTypeIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetTransmogSubCategoryArtwork' (number expected, got %s)", transmogTypeIndex ~= nil and type(transmogTypeIndex) or "no value"), 2)
		elseif transmogTypeIndex < 1 or transmogTypeIndex > #PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Transmogrification] then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetTransmogSubCategoryArtwork' (index %s out of range)", transmogTypeIndex), 2)
		end

		local transomType = PRIVATE.SUB_CATEGORIES[Enum.Store.Category.Transmogrification][transmogTypeIndex]
		return transomType.atlas
	end

	function C_StoreSecure.GetNumTransmogOffers()
		if PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT
		or not STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP
		then
			return 0
		end

		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY, 0)
		return #storage
	end

	function C_StoreSecure.GetTransmogOfferInfo(index)
		if type(index) ~= "number" then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetTransmogOfferInfo' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
		end

		if PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT
		or not STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP
		then
			return
		end

		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_MAIN_SUB_CATEGORY, 0)

		if index < 1 or index > #storage then
			error(strformat("bad argument #1 to 'C_StoreSecure.GetTransmogOfferInfo' (index %s out of range)", index), 2)
		end

		local product = storage[index]
		if not product then
			return
		end

		local name, link, rarity, itemLevel, minLevel, itemType, itemSubType, stackCount, equipLoc, icon, vendorPrice = GetItemInfo(product[PRODUCT_DATA_FIELD.ITEM_ID])
		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product)

		return name, link, rarity or ITEM_RARITY_FALLBACK, icon or ICON_UNKNOWN,
			product[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1,
			product[PRODUCT_DATA_FIELD.PRODUCT_ID],
			price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
	end

	function C_StoreSecure.GetTransomgItemSetOffer()
		if PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT
		or not STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP
		then
			return
		end

		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY, 0)

		local product = storage[1]
		if not product then
			return
		end

		local name, link, rarity, itemLevel, minLevel, itemType, itemSubType, stackCount, equipLoc, icon, vendorPrice = GetItemInfo(product[PRODUCT_DATA_FIELD.ITEM_ID])
		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product)

		return name, link, rarity or ITEM_RARITY_FALLBACK, icon or ICON_UNKNOWN,
			product[PRODUCT_DATA_FIELD.ITEM_AMOUNT] or 1,
			product[PRODUCT_DATA_FIELD.PRODUCT_ID],
			price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
	end

	function C_StoreSecure.GetTransomgItemSetOfferProductID()
		if PRIVATE.TRANSMOG_OFFER_NEXT_AWAIT
		or not STORE_DATA_CACHE.TRANSMOG_OFFER_NEXT_TIMESTAMP
		then
			return
		end

		local storage, storageDirty = PRIVATE.GetProductStorage(Enum.Store.Category.Transmogrification, TRANSMOG_OFFER_ITEM_SET_SUB_CATEGORY, 0)

		local product = storage[1]
		if not product then
			return
		end

		return product[PRODUCT_DATA_FIELD.PRODUCT_ID]
	end

	function C_StoreSecure.GetTransmogRefrestTimeLeft()
		return PRIVATE.GetTransmogRefreshTimeLeft()
	end

	function C_StoreSecure.GetRefreshTransmogProductID()
		local productID = PRIVATE.GetListRefreshProductID(Enum.Store.Category.Transmogrification, 0)
		if PRIVATE.GetProductByID(productID) then
			return productID
		end
	end
end

do -- PromoCode
	PRIVATE.IsCorrectPromoCodeFormat = function(code)
		if type(code) ~= "string" then
			return false
		end

		local length = strlen(code)
		return length >= 4 and length <= PROMOCODE_MAX_LENGHT and not strfind(code, "[^A-z]")
	end

	function C_StoreSecure.GetPromoCodeMaxLenght()
		return PROMOCODE_MAX_LENGHT
	end

	function C_StoreSecure.IsCorrectPromoCodeFormat(code)
		return PRIVATE.IsCorrectPromoCodeFormat(code)
	end

	function C_StoreSecure.ActivatePromoCode(code)
		if not PRIVATE.PROMO_CODE_ACTIVATE_AWAIT and PRIVATE.IsCorrectPromoCodeFormat(code) --[[and code ~= PRIVATE.PROMO_CODE_LAST_VALID]] then
			PRIVATE.PROMO_CODE_ACTIVATE_AWAIT = code
			FireCustomClientEvent("STORE_PROMOCODE_WAIT")
			SendServerMessage("ACMSG_PROMOCODE_REWARD", code)
			return true
		end
		return false
	end

	function C_StoreSecure.ClaimPromoCodeRewards(code)
		if not PRIVATE.PROMO_CODE_CLAIM_AWAIT and PRIVATE.IsCorrectPromoCodeFormat(code) then
			PRIVATE.PROMO_CODE_CLAIM_AWAIT = code
			FireCustomClientEvent("STORE_PROMOCODE_WAIT")
			SendServerMessage("ACMSG_PROMOCODE_SUBMIT", code)
		end
	end

	function C_StoreSecure.GetNumPromoCodeItems(code)
		if not code then
			code = PRIVATE.PROMO_CODE_LAST_VALID
		end

		local itemList = PRIVATE.PROMO_CODE_ITEMS[code]
		return itemList and #itemList or 0
	end

	function C_StoreSecure.GetPromoCodeItemsInfo(code, itemIndex)
		if not code then
			code = PRIVATE.PROMO_CODE_LAST_VALID
		end

		local itemList = PRIVATE.PROMO_CODE_ITEMS[code]
		if not itemList then
			return
		end

		if type(itemIndex) ~= "number" then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetPromoCodeItemsInfo' (number expected, got %s)", itemIndex ~= nil and type(itemIndex) or "no value"), 2)
		elseif itemIndex < 1 or itemIndex > #itemList then
			error(strformat("bad argument #2 to 'C_StoreSecure.GetProductCurrencyOptionInfo' (index %s out of range)", itemIndex), 2)
		end

		local item = itemList[itemIndex]

		if item.itemType == 0 then
			local name, link, rarity, level, minLevel, itemType, itemSubType, stackCount, equipLoc, icon, vendorPrice = GetItemInfo(item.itemID)
			return name, link, rarity or ITEM_RARITY_FALLBACK, icon or ICON_UNKNOWN, item.amount
		else
			local itemTypeData = PROMO_CODE_ITEM_TYPE[item.itemType]
			if not itemTypeData then
				GMError(strformat("Unknown item type '%s' of item #%u for '%s' code!", item.itemType, itemIndex, code))
				return UNKNOWN, nil, itemTypeData.rarity or ITEM_RARITY_FALLBACK, ICON_UNKNOWN, 0
			end

			return itemTypeData.name, nil, itemTypeData.rarity or ITEM_RARITY_FALLBACK, itemTypeData.icon or ICON_UNKNOWN, item.amount or 1
		end
	end
end

do -- Realm Shout
	PRIVATE.IsRealmShoutAvailable = function(skipBalanceCheck)
		if PRIVATE.GetBalance(Enum.Store.CurrencyType.Loyality) >= 30
		and (skipBalanceCheck or PRIVATE.GetBalance(REALM_SHOUT.currencyType) >= REALM_SHOUT.currencyType)
		then
			return true
		end
		return IsGMAccount() or false
	end

	PRIVATE.IsRealmShoutTextValid = function(text)
		if not text then
			return false
		end
		local len = utf8len(strtrim(text))
		return len >= REALM_SHOUT_MIN_LETTERS and len <= REALM_SHOUT_MAX_LETTERS
	end

	function C_StoreSecure.IsRealmShoutAvailable()
		return PRIVATE.IsRealmShoutAvailable(true)
	end

	function C_StoreSecure.GetRealmShoutPrice()
		return REALM_SHOUT.price, REALM_SHOUT.originalPrice, REALM_SHOUT.currencyType
	end

	function C_StoreSecure.GetRealmShoutTextMaxLetters()
		return REALM_SHOUT_MAX_LETTERS
	end

	function C_StoreSecure.IsRealmShoutTextValid(text)
		return PRIVATE.IsRealmShoutTextValid(text)
	end

	function C_StoreSecure.PreviewRealmShout(text)
		if PRIVATE.IsRealmShoutAvailable(true) and PRIVATE.IsRealmShoutTextValid(text) then
			local message = strformat(STORE_SHOUT_MESSAGE_PREVIEW, UnitName("player"), strtrim(text))
			FireClientEvent("CHAT_MSG_SYSTEM", message, "", "", "", "", "", 0, 0, "", 0, 36, "", 0)
		end
	end

	function C_StoreSecure.PurchaseRealmShout(text)
		if PRIVATE.IsRealmShoutAvailable() and PRIVATE.IsRealmShoutTextValid(text) then
			SendServerMessage("ACMSG_WORLD_YELL", strtrim(text))
		end
	end
end

do -- BattlePass
	function C_StoreSecure.RequestBattlePassProducts()
		PRIVATE.RequestProducts(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.EXPERIENCE, 0, true)
		PRIVATE.RequestProducts(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.PREMIUM, 0, true)
	end

	function C_StoreSecure.GetBattlePassPremiumProductInfo()
		local storage, storageDirty = PRIVATE.GetProductStorageRaw(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.PREMIUM, 0)
		local premiumProduct = storage[1]

		if not premiumProduct then
			return nil, nil, NO_PRODUCT_PRICE, NO_PRODUCT_PRICE, Enum.Store.CurrencyType.Bonus
		end

		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(premiumProduct)
		return premiumProduct[PRODUCT_DATA_FIELD.ITEM_ID], premiumProduct[PRODUCT_DATA_FIELD.PRODUCT_ID],
			price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
	end

	function C_StoreSecure.PurchaseBattlePassPremium()
		local storage, storageDirty = PRIVATE.GetProductStorageRaw(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.PREMIUM, 0)
		local premiumProduct = storage[1]

		if not premiumProduct then
			GMError("No premium product id avaliable")
			return
		end

		local success = PRIVATE.PurchaseProduct(premiumProduct)
		return success
	end

	function C_StoreSecure.GetNumBattlePassExperienceOptions()
		local storage, storageDirty = PRIVATE.GetProductStorageRaw(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.EXPERIENCE, 0)
		return #storage
	end

	function C_StoreSecure.GetBattlePassExperienceOption(optionIndex)
		if type(optionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_BattlePass.GetBattlePassExperienceOption' (number expected, got %s)", type(optionIndex)), 2)
		end

		local storage, storageDirty = PRIVATE.GetProductStorageRaw(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.EXPERIENCE, 0)

		if optionIndex < 1 or optionIndex > #storage then
			error(strformat("optionIndex out of range `%i`", optionIndex), 2)
		end

		local product = storage[optionIndex]
		local price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetProductPrice(product)

		return product[PRODUCT_DATA_FIELD.ITEM_ID], product[PRODUCT_DATA_FIELD.PRODUCT_ID],
			price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
	end

	function C_StoreSecure.PurchaseBattlePassExperience(optionIndex, amount)
		if type(optionIndex) ~= "number" then
			error(strformat("bad argument #1 to 'C_BattlePass.PurchaseBattlePassExperience' (number expected, got %s)", type(optionIndex)), 2)
		end

		local storage, storageDirty = PRIVATE.GetProductStorageRaw(Enum.Store.CurrencyType.Bonus, BATTLEPASS_CATEGORY, BATTLEPASS_SUBCATEGORY.EXPERIENCE, 0)

		if optionIndex < 1 or optionIndex > #storage then
			error(strformat("bad argument #1 to 'C_BattlePass.PurchaseBattlePassExperience: optionIndex out of range `%i`", optionIndex), 2)
		end

		local product = storage[optionIndex]
		local options
		if type(amount) == "number" and amount > 1 then
			options = {amount = amount}
		end

		local success = PRIVATE.PurchaseProduct(product, options)
		return success
	end
end

C_StorePublic = {}

function C_StorePublic.IsEnabled()
	-- enabled, isLoading, reason
	if not C_Service.IsStoreEnabled() then
		return false, false, MAINMENUBAR_STORE_DISABLE_REASON_UNAVAILABLE
	elseif C_Service.IsHardcoreCharacter() then
		if not C_Hardcore.GetActiveChallengeID() then
			return false, false, MAINMENUBAR_STORE_DISABLE_REASON_HARDCORE
		elseif C_Hardcore.IsFeatureAvailable(Enum.Hardcore.Features.GAME_SHOP) then
			local name = C_Hardcore.GetChallengeInfoByID(C_Hardcore.GetActiveChallengeID())
			return false, false, strformat(HARDCORE_FEATURE_12_DISABLE, name or UNKNOWN)
		end
	end

	local loadingTimestamp = C_CVar:GetSessionCVar("STORE_LOADING_DATA_TIMESTAMP")
	if loadingTimestamp then
		local timeLeft = (loadingTimestamp + LOADING_DATA_TIME) - time()
		if timeLeft > 0 then
			return false, true, strformat(MAINMENUBAR_STORE_DISABLE_REASON_LOADING, SecondsToTime(timeLeft))
		else
			C_CVar:SetSessionCVar("STORE_LOADING_DATA_TIMESTAMP", nil)
		end
	end

	return true, false, nil
end

function C_StorePublic.GetPreferredModelFacing()
	return PRODUCT_MODEL_FACING
end

function C_StorePublic.IsItemRefundable(itemID)
	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_StorePublic.IsItemRefundable' (number expected, got %s)", itemID ~= nil and type(itemID) or "no value"), 3)
	end

	return PRIVATE.IsItemRefundable(itemID)
end

function C_StorePublic.GetBalance(currencyType)
	if type(currencyType) ~= "number" then
		error(strformat("bad argument #1 to 'C_StorePublic.GetBalance' (number expected, got %s)", currencyType ~= nil and type(currencyType) or "no value"), 2)
	elseif currencyType < 0 then
		error(strformat("bad argument #1 to 'C_StorePublic.GetBalance' (index %s out of range)", currencyType), 2)
	end

	if currencyType > #Enum.Store.CurrencyType then
		return GetItemCount(currencyType)
	else--if issecure() then
		return PRIVATE.GetBalance(currencyType)
	end
	return 0
end

function C_StorePublic.IsValidCurrencyType(currencyType)
	return PRIVATE.IsValidCurrencyType(currencyType)
end

function C_StorePublic.GetCurrencyInfo(currencyType)
	if type(currencyType) ~= "number" then
		error(strformat("bad argument #1 to 'C_StorePublic.GetCurrencyInfo' (number expected, got %s)", currencyType ~= nil and type(currencyType) or "no value"), 2)
	end

	if PRIVATE.CURRENCY_INFO[currencyType] then
		local name, description, texture, iconAtlas = PRIVATE.GetCurrencyInfo(currencyType)
		return name, description, nil, texture, iconAtlas
	else
		local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(currencyType)
		return name, nil, link, texture, nil
	end
end

function C_StorePublic.GetRolledItemInfoByHash(hash)
	if type(hash) ~= "string" then
		error(strformat("bad argument #1 to 'C_StorePublic.GetRolledItemInfoByHash' (string expected, got %s)", hash ~= nil and type(hash) or "no value"), 2)
	end

	local product = STORE_DATA_CACHE.ROLLED_ITEM_HASHES[hash]
	if product then
		return product.productID, product.price, product.originalPrice or product.price, product.currencyType
	end
end

EventRegistry:TriggerEvent("STORE_API_LOADED")