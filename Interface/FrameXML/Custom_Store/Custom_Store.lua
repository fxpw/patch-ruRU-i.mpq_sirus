--	Filename:	Custom_Store.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

selectedCategoryID = nil
selectedMoneyID = nil
selectedSubCategoryID = 0
local selectedItemCardPage = 1
local selectedSpecialOfferPage = 1
local selectedShowAllItemCheckBox = 0
local selectedSpecID = nil
local selectedPremiumID = nil
local selectedSubsID = 0

local selectedRemoveOffer = nil

local STORE_SLIDER_NORMAL_UPDATE = 8
local STORE_SLIDER_HOVER_UPDATE = 30

local STORE_REFUND_DATA = {}
local STORE_REFUND_DATA_BY_GUID = {}
local STORE_CATEGORIES_DATA = {}
local STORE_SUB_CATEGORY_DATA = {}
local STORE_SUBSCRIBE_DATA = {}
local STORE_PRODUCT_DATA = {}
local STORE_PRODUCT_LIST = {}
local STORE_SPECIAL_OFFER_INFO_DATA = {}
local STORE_SPECIAL_OFFER_POPUP = {}
local STPRE_SPECIAL_OFFER_DETAILS_DATA = {}
local STORE_SMALL_SPECIAL_OFFER_BUFFER = {}
local STORE_PRODUCT_MONEY_ICON = {"coins", "mmotop", "refer", "loyal"}
local STORE_BLOODLINE_BOOK_ITEMS = {
	[99990] = true,
	[99991] = true,
	[320156] = true,
	[320184] = true,
}

local STORE_TRANSMOGRIFY_CATEGORY_ID = 6
local STORE_SUBSCRIPTIONS_CATEGORY_ID = 5

local STORE_FRAME_DATA = {
	"StoreItemListFrame",
	"StoreSpecialOfferFrame",
	"StoreItemCardFrame",
	"StoreModelPreviewFrame",
	"StoreConfirmationFrame",
	"StoreErrorFrame",
	"StorePurchaseAlertFrame",
	"SpecialOfferInfoFrame",
	"StoreSubCategorySelectFrame",
	"SpecialOfferDetailsInfoFrame",
	"StoreBuyPremiumFrame",
	"StoreSubscribeFrame",
	"StoreSpecialOfferDetailFrame",
	"StoreRefundFrame",
	"StoreDressUPFrame",
	"StoreTransmogrifyFrame",
	"StoreTransmogrifySubCategoryFrame"
}

STORE_HIGHLIGHT_CATEGORY_BUTTON = {}

STORE_ITEM_FLAG_NONE                 = 0x00000000
STORE_ITEM_FLAG_NEW                  = 0x00000001
STORE_ITEM_FLAG_PVP                  = 0x00000002
STORE_ITEM_FLAG_RECOMMENDED          = 0x00000004
STORE_ITEM_FLAG_PROMOTIONAL          = 0x00000008
STORE_ITEM_FLAG_SPECIAL              = 0x00000010
STORE_ITEM_FLAG_ITEM_GIFT			 = 0x00000020
STORE_ITEM_FLAG_MULTIPLE_BUY 		 = 0x00000400

local STORE_FLAG_SERVICE_CUSTOMIZATION 	= 0x008
local STORE_FLAG_SERVICE_CHANGEFACTION 	= 0x040
local STORE_FLAG_SERVICE_CHANGERACE 	= 0x080

local STORE_SERVICE_FLAG_DATA = {
	{
		flag = STORE_FLAG_SERVICE_CUSTOMIZATION,
		text = STORE_SERVICE_LABEL_1,
	},
	{
		flag = STORE_FLAG_SERVICE_CHANGEFACTION,
		text = STORE_SERVICE_LABEL_2,
	},
	{
		flag = STORE_FLAG_SERVICE_CHANGERACE,
		text = STORE_SERVICE_LABEL_3,
	},
}

local STORE_ITEM_FLAG_DATA = {
	{
		flag = STORE_ITEM_FLAG_NEW,
		text = STORE_ITEM_FLAG_1,
		isNew = true,
		isHot = false,
		isPVP = false,
		isDiscount = true
	},
	{
		flag = bit.bor(STORE_ITEM_FLAG_NEW, STORE_ITEM_FLAG_RECOMMENDED),
		text = STORE_ITEM_FLAG_2,
		isNew = true,
		isHot = false,
		isPVP = false,
		isDiscount = true
	},
	{
		flag = bit.bor(STORE_ITEM_FLAG_NEW, STORE_ITEM_FLAG_PROMOTIONAL),
		text = STORE_ITEM_FLAG_3,
		isNew = true,
		isHot = false,
		isPVP = false,
		isDiscount = true
	},
	{
		flag = bit.bor(STORE_ITEM_FLAG_NEW, STORE_ITEM_FLAG_PROMOTIONAL, STORE_ITEM_FLAG_RECOMMENDED),
		text = STORE_ITEM_FLAG_3,
		isNew = true,
		isHot = false,
		isPVP = false,
		isDiscount = true
	},
	{
		flag = STORE_ITEM_FLAG_RECOMMENDED,
		text = STORE_ITEM_FLAG_2,
		isNew = false,
		isHot = true,
		isPVP = false,
		isDiscount = true
	},
	{
		flag = bit.bor(STORE_ITEM_FLAG_RECOMMENDED, STORE_ITEM_FLAG_PROMOTIONAL),
		text = STORE_ITEM_FLAG_3,
		isNew = false,
		isHot = true,
		isPVP = false,
		isDiscount = true
	},
}

local STORE_MONEY_BUTTON_DATA = {
	{
		Icon = "coins",
		Name = STORE_COINS_BUTTON_TOOLTIP_LABEL,
		Description = STORE_COINS_BUTTON_TOOLTIP,
		ChieldFrame = "StoreSpecialOfferFrame",
		Disable = false,
		Selected = true
	},
	{
		Icon = "mmotop",
		Name = STORE_MMOTOP_BUTTON_TOOLTIP_LABEL,
		Description = STORE_MMOTOP_BUTTON_TOOLTIP,
		ChieldFrame = "StoreItemListFrame",
		Disable = false,
		Selected = false
	},
	{
		Icon = "refer",
		Name = STORE_REFER_BUTTON_TOOLTIP_LABEL,
		Description = STORE_REFER_BUTTON_TOOLTIP,
		ChieldFrame = "StoreItemListFrame",
		Disable = false,
		Selected = false
	},
	{
		Icon = "loyal",
		Name = STORE_LOYAL_BUTTON_TOOLTIP_LABEL,
		Description = STORE_LOYAL_BUTTON_TOOLTIP,
		ChieldFrame = "StoreItemListFrame",
		Disable = false,
		Selected = false
	},
}
STORE_CATEGORIES_DATA[1] = {
	{
		Icon = "category-icon-featured",
		Name = STORE_CATEGORY_1,
		IsNew = false,
		Disable = false,
		ChieldFrame = "StoreSpecialOfferFrame",
		Color = {r = 1, g = 0, b = 0}
	},
	{
		Icon = "category-icon-armor",
		Name = STORE_CATEGORY_2,
		IsNew = false,
		Disable = false,
		ChieldFrame = "StoreSubCategorySelectFrame",
		subCategoryFrame = "StoreItemListFrame",
		Level = 12,
		dontItemRequest = true
	},
	{
		Icon = "category-icon-mounts",
		Name = STORE_CATEGORY_3_NEW,
		IsNew = false,
		Disable = false,
		ChieldFrame = "StoreItemCardFrame",
		SlideOther = true,
		subCategoryDefault = true
	},
	{
		Icon = "category-icon-hot",
		Name = STORE_CATEGORY_4_NEW,
		IsNew = false,
		Disable = false,
		ChieldFrame = "StoreItemListFrame",
		Level = 80,
		SlideOther = true,
		subCategoryDefault = true
	},
	{
		Icon = "category-icon-box",
		Name = STORE_CATEGORY_9,
		IsNew = false,
		Disable = true,
		ChieldFrame = "StoreSubscribeFrame",
		Color = {r = 0, g = 1, b = 0},
		Debuff = 90004,
		Level = 80,
		dontItemRequest = true,
		SlideOther = true
	},
	{
		Icon = "category-icon-clothes",
		Name = STORE_CATEGORY_10,
		IsNew = false,
		Disable = false,
		--ChieldFrame = "StoreTransmogrifyFrame",
		ChieldFrame = "StoreTransmogrifySubCategoryFrame",
		subCategoryFrame = "StoreTransmogrifyFrame",
		dontItemRequest = true
	},
}

STORE_SUB_CATEGORY_DATA[STORE_SUBSCRIPTIONS_CATEGORY_ID] = {
	{
		Name = STORE_SUB_CATEGORY_9_1,
		SubCategoryId = 2,
		CategoryId = 9,
		Callback = function() selectedSubCategoryID = 2; StoreSubscribeSetup() end
	},
	{
		Name = STORE_SUB_CATEGORY_9_2,
		SubCategoryId = 3,
		CategoryId = 9,
		Callback = function() selectedSubCategoryID = 3; StoreSubscribeSetup() end
	},
	{
		Name = STORE_SUB_CATEGORY_9_3,
		SubCategoryId = 4,
		CategoryId = 9,
		Callback = function() selectedSubCategoryID = 4; StoreSubscribeSetup() end
	},
	{
		Name = STORE_SUB_CATEGORY_9_4,
		SubCategoryId = 5,
		CategoryId = 9,
		Callback = function() selectedSubCategoryID = 5; StoreSubscribeSetup() end
	},
}

STORE_SUB_CATEGORY_DATA[3] = {
	{
		Name = STORE_SUB_CATEGORY_3_1,
		SubCategoryId = 1,
		CategoryId = 3,
		Callback = function() selectedSubCategoryID = 1; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_3_2,
		SubCategoryId = 2,
		CategoryId = 3,
		Callback = function() selectedSubCategoryID = 2; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_3_3,
		SubCategoryId = 3,
		CategoryId = 3,
		Disabled = true,
		Callback = function() selectedSubCategoryID = 3; StoreSubCategorySelectClick() end
	}
}

STORE_SUB_CATEGORY_DATA[4] = {
	{
		Name = STORE_SUB_CATEGORY_4_1,
		SubCategoryId = 1,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 1; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_2,
		SubCategoryId = 2,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 2; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_3,
		SubCategoryId = 3,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 3; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_4,
		SubCategoryId = 4,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 4; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_5,
		SubCategoryId = 5,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 5; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_6,
		SubCategoryId = 6,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 6; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_7,
		SubCategoryId = 7,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 7; StoreSubCategorySelectClick() end
	},
	{
		Name = STORE_SUB_CATEGORY_4_8,
		SubCategoryId = 8,
		CategoryId = 4,
		Callback = function() selectedSubCategoryID = 8; StoreSubCategorySelectClick() end,
		Check = function() return (not C_Service:IsLockStrengthenStatsFeature()) end
	}
}

local STORE_GIFT_DATA = {
	{
		Text = STORE_GIFT_LABEL_1,
		Value = {Texture = 0, Key = 41}
	},
	{
		Text = STORE_GIFT_LABEL_2,
		Value = {Texture = "Stationery_Chr", Key = 65}
	},
	{
		Text = STORE_GIFT_LABEL_3,
		Value = {Texture = "Stationery_Val", Key = 64}
	},
}

local STORE_PREMIUM_DATA = {
	{
		Text = STORE_PREMIUM_BUY_1,
		Price = 3,
		Info = STORE_PREMIUM_DISCOUNT_INFO_1
	},
	{
		Text = STORE_PREMIUM_BUY_2,
		Price = 9,
		Info = STORE_PREMIUM_DISCOUNT_INFO_2
	},
	{
		Text = STORE_PREMIUM_BUY_3,
		Price = 29,
		Info = STORE_PREMIUM_DISCOUNT_INFO_3
	},
	{
		Text = STORE_PREMIUM_BUY_4,
		Price = 499,
		Info = STORE_PREMIUM_DISCOUNT_INFO_4
	},
}

STORE_CATEGORIES_DATA[2] = {
	text = STORE_CATEGORY_INFO_1
}
STORE_CATEGORIES_DATA[3] = {
	text = STORE_CATEGORY_INFO_2
}
STORE_CATEGORIES_DATA[4] = {
	text = STORE_CATEGORY_INFO_3
}

STORE_SPECIAL_OFFERS_3D = {
	[33] = {
		Name = "Foxy",
		VertexColor =  {0.38, 0.88, 1},
		PopupCreature = 130523,
		BannerModelInfo = {130523, 0.1, "BOTTOM", "TOP", 0, -40, 280, 280, 1},
	}, -- Foxes
	[47] = {
		Name = "Meat",
		VertexColor =  {1, 0.3, 0.3},
		PopupCreature = 130945,
		BannerModelInfo = {130945, -0.3, "BOTTOM", "TOP", 10, -60, 200, 200, 1},
	}, -- Meat wagon
	[35] = {
		Name = "FoxyPink",
		VertexColor =  {1, 0.3, 0.3},
		PopupCreature = 130521,
		BannerModelInfo = {130521, -0.6, "BOTTOM", "TOP", 0, -74, 280, 280, 1},
	}, -- Pink foxes
	[36] = {
		Name = "FlyRat",
		VertexColor =  {0.98, 0.65, 0.68},
		PopupCreature = 200041,
		BannerModelInfo = {200041, -0.5, "BOTTOM", "TOP", 0, 0, 200, 200, 1},
	}, -- Fly rat offer
	[42] = {
		Name = "RainbowSteed",
		VertexColor =  {0.38, 0.88, 1},
		PopupCreature = nil,
		BannerModelInfo = nil,
	}, -- Rainbow steed
	[48] = {
		Name = "Leffel",
		VertexColor =  {0.38, 0.88, 1},
		PopupCreature = 130893,
		BannerModelInfo = {130893, -0.68, "BOTTOM", "TOP", 0, 0, 200, 200, 0.7},
	}, -- Leffel
	[53] = {
		Name = "HandOfSuffer",
		VertexColor =  {0.82, 0.34, 0.12},
		PopupCreature = 131067,
		BannerModelInfo = {131067, -0.68, "BOTTOM", "TOP", 0, -70, 400, 400, 0.7},
	}, -- Hand of suffer
	[54] = {
		Name = "MurMur",
		VertexColor =  {0.82, 0.34, 0.12},
		PopupCreature = 131209,
		BannerModelInfo = {131209, -0.68, "BOTTOM", "TOP", -50, -50, 350, 320, 0.7},
	}, -- Mur mur
	[55] = {
		Name = "HeartGlider",
		VertexColor =  {1, 0.3, 0.3},
		PopupCreature = 131231,
		BannerModelInfo = {131231, -0.68, "BOTTOM", "TOP", 0, -250, 350, 420, 0.7},
	}, -- Heart glider
	[56] = {
		Name = "DeathBreath",
		VertexColor =  {1, 0.3, 0.3},
		PopupCreature = 74539,
		BannerModelInfo = {74539, -0.68, "BOTTOM", "TOP", 0, -30, 150, 220, 0.7},
	}, -- Death Breath
	[57] = {
		Name = "Sirin",
		VertexColor =  {1, 0.3, 0.3},
		PopupCreature = 131250,
		BannerModelInfo = {131250, -0.38, "BOTTOM", "TOP", 0, 20, 350, 220, 0.7},
	}, -- Sirin
}

STORE_CACHE = C_Cache("SIRUS_STORE_CACHE", true)

local NO_CLASS_FILTER = 0
local ALL_EXPANSION_FILTER = -1
local ALL_SOURCE_FILTER = 0
local ALL_WEAPON_FILTER = 0
local ALL_WEAPON_NEW_FILTER = -2

local storeTransmogrifySetsData = {}
local storeTransmogrifySourceDataByStoreID = {}
local storeTransmogrifyNewWeaponTypes = {}

storeTransmogrifyShowShoulders = true

STORE_TRANSMOGRIFY_SETS_STOREID 				= 1
STORE_TRANSMOGRIFY_SETS_NAME 					= 2
STORE_TRANSMOGRIFY_SETS_ICON 					= 3
STORE_TRANSMOGRIFY_SETS_CLASSID 				= 4
STORE_TRANSMOGRIFY_SETS_EXPANSION 				= 5
STORE_TRANSMOGRIFY_SETS_QUALITY 				= 6
STORE_TRANSMOGRIFY_SETS_ITEMS 					= 7
STORE_TRANSMOGRIFY_SETS_WEAPONTYPE 				= 8

STORE_TRANSMOGRIFY_ITEM_ITEMID 					= 1
STORE_TRANSMOGRIFY_ITEM_ICON 					= 2
STORE_TRANSMOGRIFY_ITEM_ITEMLINK 				= 3
STORE_TRANSMOGRIFY_ITEM_QUALITY 				= 4
STORE_TRANSMOGRIFY_ITEM_NAME					= 5

STORE_TRANSMOGRIFY_STORAGE_STOREID 				= 1
STORE_TRANSMOGRIFY_STORAGE_ITEMID				= 2
STORE_TRANSMOGRIFY_STORAGE_CLASSID 				= 3
STORE_TRANSMOGRIFY_STORAGE_EXPANSION 			= 4
STORE_TRANSMOGRIFY_STORAGE_ITEMS 				= 5

STORE_TRANSMOGRIFY_SERVER_STOREID 				= 1
STORE_TRANSMOGRIFY_SERVER_ITEMID 				= 2
STORE_TRANSMOGRIFY_SERVER_ITEMCOUNT 			= 3
STORE_TRANSMOGRIFY_SERVER_STOREPRICE 			= 4
STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNT 		= 5
STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNTPRICE 	= 6
STORE_TRANSMOGRIFY_SERVER_STOREFLAGS 			= 7
STORE_TRANSMOGRIFY_SERVER_ISPVP 				= 8
STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY 			= 9
STORE_TRANSMOGRIFY_SERVER_ALT_PRICE 			= 10
STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY_NAME 	= 11
STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY_ICON 	= 12

STORE_STORAGE_DATA_ID 							= 1
STORE_STORAGE_DATA_ENTRY 						= 2
STORE_STORAGE_DATA_COUNT 						= 3
STORE_STORAGE_DATA_PRICE 						= 4
STORE_STORAGE_DATA_REMAININGTIME 				= 5
STORE_STORAGE_DATA_DISCOUNT 					= 6
STORE_STORAGE_DATA_DISCOUNTEDPRICE 				= 7
STORE_STORAGE_DATA_CREATUREENTRY 				= 8
STORE_STORAGE_DATA_FLAGS 						= 9
STORE_STORAGE_DATA_ALT_CURRENCY 				= 10
STORE_STORAGE_DATA_ALT_PRICE    				= 11
STORE_STORAGE_DATA_ISPVP 						= 12
STORE_STORAGE_DATA_DISCOUNTSHOW 				= 13

local STORE_TRANSMOGRIFY_WEAPON_SUB_CLASSES = {
	ITEM_SUB_CLASS_2_0, ITEM_SUB_CLASS_2_1, ITEM_SUB_CLASS_2_2, ITEM_SUB_CLASS_2_3, ITEM_SUB_CLASS_2_4, ITEM_SUB_CLASS_2_5, ITEM_SUB_CLASS_2_6, ITEM_SUB_CLASS_2_7, ITEM_SUB_CLASS_2_8,
	ITEM_SUB_CLASS_2_10, ITEM_SUB_CLASS_2_13, ITEM_SUB_CLASS_2_14, ITEM_SUB_CLASS_2_15, ITEM_SUB_CLASS_2_16, ITEM_SUB_CLASS_2_18, ITEM_SUB_CLASS_2_19,
	ITEM_SUB_CLASS_4_6
}

STORE_TRANSMOGRIFY_WEAPON_TYPES = {}
for i = 1, #STORE_TRANSMOGRIFY_WEAPON_SUB_CLASSES do
	STORE_TRANSMOGRIFY_WEAPON_TYPES[STORE_TRANSMOGRIFY_WEAPON_SUB_CLASSES[i]] = i
end

STORE_TRANSMOGRIFY_SETS_DATA = {}
STORE_TRANSMOGRIFY_ITEM_DATA = {}
STORE_TRANSMOGRIFY_SERVER_DATA = {}

STORE_TRANSMOGRIFY_SORID = nil
STORE_TRANSMOGRIFY_FILTER_CLASSID = nil
STORE_TRANSMOGRIFY_FILTER_EXPANSION = nil
STORE_TRANSMOGRIFY_FILTER_SOURCE = nil
STORE_TRANSMOGRIFY_FILTER_WEAPON = nil

STORE_SEARCH_TEXT = nil

Store_CoroutineRequestItems = nil

STORE_CATEGORY_NEW_ITEMS_INDICATOR = {}

enum:E_STORE_CATEGORY_NEW_ITEMS_INDICATOR {
	"CURRENCY",
	"CATEGORYID",
	"SUBCATEGORYID"
}

local StoreRequestMoneyID
local StoreRequestCategoryID
local StoreRequestSubCategoryID
local StoreRequestIgnoreFilters

local storeRequestQueue = {}
local storeQueueTimer

function GetStoreHyperlinkInfo( link )
	local splitData = C_Split(link, ":")

	local moneyID 		= tonumber(splitData[2])
	local categoryID 	= tonumber(splitData[3])
	local subCategoryID = tonumber(splitData[4])
	local storeID 		= tonumber(splitData[5])

	ShowUIPanel(StoreFrame)

	_G["StoreMoneyButton"..moneyID]:Click()
	_G["StoreCategoryButton"..categoryID]:Click()

	if not StoreTransmogrifyFrame.selectedSets or StoreTransmogrifyFrame.selectedSets ~= storeID then
		StoreTransmogrifyButton_SelectedSetByStoreID(storeID)
	end
end

function StoreGenerateHyperlink( moneyID, categoryID, subCategoryID, storeID, name )
	return string.format("|cff66bbff|Hstore:%d:%d:%d:%d|h[%s]|h|r", moneyID or 0, categoryID or 0, subCategoryID or 0, storeID or 0, name or "~ unknown name ~")
end

local storeTransmogirfyUseExpansion = {}
function StoreTransmogrifyCreateItemData()
	STORE_TRANSMOGRIFY_SETS_DATA = {}
	STORE_TRANSMOGRIFY_ITEM_DATA = {}
	storeTransmogirfyUseExpansion = {}

	for i = 1, 4 do
		local storage = STORE_TRANSMOGRIFY_STORAGE[i]

		if storage then
			STORE_TRANSMOGRIFY_SETS_DATA[i] = {}
			STORE_TRANSMOGRIFY_ITEM_DATA[i] = {}

			for _, data in pairs(storage) do
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = GetItemInfo(data[STORE_TRANSMOGRIFY_STORAGE_ITEMID])

				if data[STORE_TRANSMOGRIFY_STORAGE_ITEMS] and #data[STORE_TRANSMOGRIFY_STORAGE_ITEMS] > 0 then
					table.insert(STORE_TRANSMOGRIFY_SETS_DATA[i], {
						data[STORE_TRANSMOGRIFY_STORAGE_STOREID],
						itemName,
						itemTexture,
						data[STORE_TRANSMOGRIFY_STORAGE_CLASSID],
						data[STORE_TRANSMOGRIFY_STORAGE_EXPANSION],
						itemRarity,
						data[STORE_TRANSMOGRIFY_STORAGE_ITEMS],
						STORE_TRANSMOGRIFY_WEAPON_TYPES[itemSubType] or -1,
					})
					storeTransmogirfyUseExpansion[data[STORE_TRANSMOGRIFY_STORAGE_EXPANSION]] = true
				else
					STORE_TRANSMOGRIFY_ITEM_DATA[i][data[STORE_TRANSMOGRIFY_STORAGE_STOREID]] = {data[STORE_TRANSMOGRIFY_STORAGE_ITEMID], itemTexture, itemLink, itemRarity, itemName}
				end
			end
		end
	end
end

function StoreTransmogrifyValidation( data )
	if not data then
		return false
	end

	local storeID = data[STORE_TRANSMOGRIFY_SETS_STOREID];
	local serverData = STORE_TRANSMOGRIFY_SERVER_DATA[storeID];

	if not serverData then
		return false;
	end

	local isValidation = true
	local isDisable = false

	if selectedSubCategoryID ~= 2 then
		local classID = data[STORE_TRANSMOGRIFY_SETS_CLASSID]
		local expansionID = data[STORE_TRANSMOGRIFY_SETS_EXPANSION]
		local isPVP = false

		if serverData then
			if serverData[STORE_TRANSMOGRIFY_SERVER_ISPVP] then
				isPVP = serverData[STORE_TRANSMOGRIFY_SERVER_ISPVP]
			end

			if serverData[STORE_TRANSMOGRIFY_SERVER_STOREFLAGS] then
				local flags = serverData[STORE_TRANSMOGRIFY_SERVER_STOREFLAGS]

				isDisable = bit.band(flags, 512) == 512
			end
		end

		if STORE_TRANSMOGRIFY_FILTER_CLASSID ~= NO_CLASS_FILTER then
			if STORE_TRANSMOGRIFY_FILTER_CLASSID ~= classID and classID ~= NO_CLASS_FILTER and classID ~= -1 then
				isValidation = false
			end
		end

		if STORE_TRANSMOGRIFY_FILTER_EXPANSION ~= ALL_EXPANSION_FILTER then
			if bit.lshift(1, STORE_TRANSMOGRIFY_FILTER_EXPANSION) ~= expansionID then
				isValidation = false
			end
		end

		if STORE_TRANSMOGRIFY_FILTER_SOURCE ~= ALL_SOURCE_FILTER then
			local _isPVP = STORE_TRANSMOGRIFY_FILTER_SOURCE == 1

			if _isPVP ~= isPVP then
				isValidation = false
			end
		end
	elseif selectedSubCategoryID == 2 then
		if STORE_TRANSMOGRIFY_FILTER_WEAPON == ALL_WEAPON_NEW_FILTER then
			if not storeID or not serverData or bit.band(serverData[STORE_TRANSMOGRIFY_SERVER_STOREFLAGS] or 0, STORE_ITEM_FLAG_NEW) == 0 then
				isValidation = false
			end
		elseif STORE_TRANSMOGRIFY_FILTER_WEAPON ~= ALL_WEAPON_FILTER then
			if STORE_TRANSMOGRIFY_FILTER_WEAPON ~= data[STORE_TRANSMOGRIFY_SETS_WEAPONTYPE] then
				isValidation = false
			end
		end
	end

	if isDisable then
		isValidation = false
	end

	return isValidation
end

function StoreTransmogrifySearchValidation( data )
	if not data then
		return false
	end

	local text = STORE_SEARCH_TEXT or ""

	if #text <= 2 then
		return true
	end

	text = string.upper(text)

	if string.find(string.upper(data[STORE_TRANSMOGRIFY_SETS_NAME]), text) then
		return true
	end

	for _, storeID in pairs(data[STORE_TRANSMOGRIFY_SETS_ITEMS]) do
		local itemData = STORE_TRANSMOGRIFY_ITEM_DATA[selectedSubCategoryID][storeID]

		if itemData then
			local itemName = itemData[STORE_TRANSMOGRIFY_ITEM_NAME]

			if itemName then
				if string.find(string.upper(itemName), text) then
					return true
				end
			end
		end
	end

	return false
end

function StoreTransmogrifyGenerateData( isFiltered )
	local index = 1
	storeTransmogrifySetsData = {}
	storeTransmogrifySourceDataByStoreID = {}
	storeTransmogrifyNewWeaponTypes = {}

	for _, data in pairs(STORE_TRANSMOGRIFY_SETS_DATA[selectedSubCategoryID] or {}) do
		local storeID = data[STORE_TRANSMOGRIFY_SETS_STOREID]

		if selectedSubCategoryID == 2 then
			local weaponType = data[STORE_TRANSMOGRIFY_SETS_WEAPONTYPE];

			if weaponType and weaponType ~= -1 then
				if STORE_TRANSMOGRIFY_SERVER_DATA[storeID] and bit.band(STORE_TRANSMOGRIFY_SERVER_DATA[storeID][STORE_TRANSMOGRIFY_SERVER_STOREFLAGS] or 0, STORE_ITEM_FLAG_NEW) ~= 0 then
					storeTransmogrifyNewWeaponTypes[weaponType] = true;
				end
			end
		end

		storeTransmogrifySourceDataByStoreID[storeID] = data
		if StoreTransmogrifyValidation(data) and StoreTransmogrifySearchValidation(data) then
			storeTransmogrifySetsData[index] = data
			index = index + 1
		end
	end

	CloseDropDownMenus()
	StoreTransmogrifyFrame_UpdateScrollFrame()

	if isFiltered then
		StoreTransmogrifyFrame.LeftContainer.ScrollFrame.scrollBar:SetValue(0)
		StoreTransmogrifyButton_Selected(1, nil, true)
	end
end

function GetStoreTransmogrifySetsInfo( index )
	index = index or StoreTransmogrifyFrame.selectedIndex

	if not index then
		return
	end

	local data = storeTransmogrifySetsData[index]

	if not data then
		return
	end

	local storeID 		= data[STORE_TRANSMOGRIFY_SETS_STOREID]
	local setName 		= data[STORE_TRANSMOGRIFY_SETS_NAME]
	local iconTexture 	= data[STORE_TRANSMOGRIFY_SETS_ICON]
--	local isPVP 		= nil --data[STORE_TRANSMOGRIFY_SETS_ISPVP]
	local classID 		= data[STORE_TRANSMOGRIFY_SETS_CLASSID]
	local expansionID 	= data[STORE_TRANSMOGRIFY_SETS_EXPANSION]
	local qualityID 	= data[STORE_TRANSMOGRIFY_SETS_QUALITY]
	local itemsStoreID 	= data[STORE_TRANSMOGRIFY_SETS_ITEMS]

	local serverData = STORE_TRANSMOGRIFY_SERVER_DATA[storeID]
	local storePrice, storeDiscount, storeDiscountPrice, isPVP, altCurrency, altPrice, altCurrencyName, altCurrencyIcon

	if serverData then
		storePrice 			= serverData[STORE_TRANSMOGRIFY_SERVER_STOREPRICE]
		storeDiscount 		= serverData[STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNT]
		storeDiscountPrice 	= serverData[STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNTPRICE]
		isPVP 				= serverData[STORE_TRANSMOGRIFY_SERVER_ISPVP]
		altCurrency 		= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY];
		altPrice 			= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_PRICE];
		altCurrencyName 	= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY_NAME];
		altCurrencyIcon 	= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY_ICON];
	end

	return storeID, setName, iconTexture, isPVP, classID, expansionID, qualityID, itemsStoreID, storePrice, storeDiscount, storeDiscountPrice, isPVP, altCurrency, altPrice, altCurrencyName, altCurrencyIcon;
end

function GetNumStoreTransmogrifySets()
	return #storeTransmogrifySetsData
end

function GetNumStoreTransmogrifyItems()
	local index = StoreTransmogrifyFrame.selectedIndex

	if not index then
		return 0
	end

	local _, _, _, _, _, _, _, itemsStoreID = GetStoreTransmogrifySetsInfo()

	if itemsStoreID then
		return #itemsStoreID
	end

	return 0
end

function GetStoreTransmogrifyItemsInfo( index )
	if not index then
		return
	end

	local _, _, _, _, _, _, _, itemsStoreID = GetStoreTransmogrifySetsInfo()

	if not itemsStoreID then
		return
	end

	local storeID = itemsStoreID[index]

	if not storeID then
		return
	end

	local data = STORE_TRANSMOGRIFY_ITEM_DATA[selectedSubCategoryID][storeID]

	if not data then
		return
	end

	local storeID 		= storeID
	local itemID 		= data[STORE_TRANSMOGRIFY_ITEM_ITEMID]
	local iconTexture 	= data[STORE_TRANSMOGRIFY_ITEM_ICON]
	local itemLink 		= data[STORE_TRANSMOGRIFY_ITEM_ITEMLINK]
	local itemRarity 	= data[STORE_TRANSMOGRIFY_ITEM_QUALITY]

	local serverData = STORE_TRANSMOGRIFY_SERVER_DATA[storeID]
	local storePrice, storeDiscount, storeDiscountPrice, isPVP, altCurrency, altPrice, altCurrencyName, altCurrencyIcon;

	if serverData then
		storePrice 			= serverData[STORE_TRANSMOGRIFY_SERVER_STOREPRICE]
		storeDiscount 		= serverData[STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNT]
		storeDiscountPrice 	= serverData[STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNTPRICE]
		isPVP 				= serverData[STORE_TRANSMOGRIFY_SERVER_ISPVP]
		altCurrency 		= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY];
		altPrice 			= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_PRICE];
		altCurrencyName 	= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY_NAME];
		altCurrencyIcon 	= serverData[STORE_TRANSMOGRIFY_SERVER_ALT_CURRENCY_ICON];
	end

	return storeID, itemID, iconTexture, itemLink, itemRarity, storePrice, storeDiscount, storeDiscountPrice, isPVP, altCurrency, altPrice, altCurrencyName, altCurrencyIcon;
end

function StoreGetSpecialOfferByOfferID( offerID )
	for _, value in pairs(STORE_SPECIAL_OFFER_INFO_DATA) do
		if value.offerID == offerID then
			return value
		end
	end

	return nil
end

function StoreGetSpecialOfferByIndex( index )
	if STORE_SPECIAL_OFFER_INFO_DATA[index] then
		return STORE_SPECIAL_OFFER_INFO_DATA[index]
	end

	return nil
end

function StoreGetSpecialOfferCount()
	if STORE_SPECIAL_OFFER_INFO_DATA then
		return #STORE_SPECIAL_OFFER_INFO_DATA
	end

	return nil
end

function StoreRemoveOffer( index )
	if STORE_SPECIAL_OFFER_INFO_DATA[index] then
		if STORE_SPECIAL_OFFER_INFO_DATA[index].Timer then
			STORE_SPECIAL_OFFER_INFO_DATA[index].Timer:Cancel()
			STORE_SPECIAL_OFFER_INFO_DATA[index].Timer = nil
		end

		table.remove(STORE_SPECIAL_OFFER_INFO_DATA, index)
	end
end

function GetStoreProductVersion()
	return STORE_CACHE:Get("ASMSG_SHOP_VERSION")
end

function GetStoreRolledItemsVersion(categoryId)
	return PackNumber(STORE_CACHE:Get("MOUNT_RENEW_WEEK", 0), STORE_CACHE:Get("CATEGORY_DROP_COUNT"..categoryId, 0))
end

function StoreFrame_OnLoad( self, ... )
	self.CategoryFrames = {}
	self.SubCategoryFrames = {}

	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_LOGIN")

	self:SetScale(0.8)
	SetPortraitToTexture(self.portrait, "Interface\\ICONS\\WoW_Store")
	self.TitleText:SetText(STORE_WINDOW_TITLE)

	RegisterForSave("STORE_HIGHLIGHT_CATEGORY_BUTTON")

	StoreTransmogrifyCreateItemData()
end

function StoreCacheDataGenerate( reset )
	if reset then
		STORE_CACHE:Set("PRODUCT_CACHE", {}, 259200)
	end

	STORE_PRODUCT_CACHE = STORE_CACHE:Get("PRODUCT_CACHE", {}, 259200)

	for moneyID = 1, #STORE_CATEGORIES_DATA do
		if not STORE_PRODUCT_CACHE[moneyID] then
			STORE_PRODUCT_CACHE[moneyID] = {}
		end

		for categoryID = 0, #STORE_CATEGORIES_DATA[moneyID] do
			if not STORE_PRODUCT_CACHE[moneyID][categoryID] then
				STORE_PRODUCT_CACHE[moneyID][categoryID] = {}
			end

			if not STORE_PRODUCT_CACHE[moneyID][categoryID][0] then
				STORE_PRODUCT_CACHE[moneyID][categoryID][0] = {}
			end

			for filter = 0, 1 do
				if not STORE_PRODUCT_CACHE[moneyID][categoryID][0][filter] then
					STORE_PRODUCT_CACHE[moneyID][categoryID][0][filter] = {}
				end
			end

			if categoryID == 2 then
				for subCategoryID = 1, 15 do
					if not STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID] then
						STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID] = {}
					end

					for filter = 0, 1 do
						if not STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID][filter] then
							STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID][filter] = {}
						end
					end
				end
			elseif categoryID == STORE_TRANSMOGRIFY_CATEGORY_ID then
				for subCategoryID = 1, 4 do
					if not STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID] then
						STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID] = {}
					end

					for filter = 0, 1 do
						if not STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID][filter] then
							STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID][filter] = {}
						end
					end
				end
			elseif STORE_SUB_CATEGORY_DATA[categoryID] and #STORE_SUB_CATEGORY_DATA[categoryID] > 0 then
				for subCategoryID = 1, #STORE_SUB_CATEGORY_DATA[categoryID] do
					if not STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID] then
						STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID] = {}
					end
					for filter = 0, 1 do
						if not STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID][filter] then
							STORE_PRODUCT_CACHE[moneyID][categoryID][subCategoryID][filter] = {}
						end
					end
				end
			end
		end
	end

	-- BattlePass hardcode.
	if not STORE_PRODUCT_CACHE[1][101] then
		STORE_PRODUCT_CACHE[1][101] = {}
	end

	if not STORE_PRODUCT_CACHE[1][101][1] then
		STORE_PRODUCT_CACHE[1][101][1] = {}
	end

	if not STORE_PRODUCT_CACHE[1][101][2] then
		STORE_PRODUCT_CACHE[1][101][2] = {}
	end

	if not STORE_PRODUCT_CACHE[1][101][1][0] then
		STORE_PRODUCT_CACHE[1][101][1][0] = {}
	end

	if not STORE_PRODUCT_CACHE[1][101][1][1] then
		STORE_PRODUCT_CACHE[1][101][1][1] = {}
	end

	if not STORE_PRODUCT_CACHE[1][101][2][0] then
		STORE_PRODUCT_CACHE[1][101][2][0] = {}
	end

	if not STORE_PRODUCT_CACHE[1][101][2][1] then
		STORE_PRODUCT_CACHE[1][101][2][1] = {}
	end
end

function StoreFrame_OnEvent( self, event, ... )
	if event == "PLAYER_LOGIN" then
		SendServerMessage("ACMSG_SHOP_CATEGORY_NEW_ITEMS_REQUEST")
		SendServerMessage("ACMSG_SHOP_BALANCE_REQUEST")
		SendServerMessage("ACMSG_SHOP_SUBSCRIPTION_LIST_REQUEST")
		STORE_SUBSCRIBE_DATA = {}
	elseif event == "VARIABLES_LOADED" then
		StoreCacheDataGenerate()

		if STORE_CACHE:Get("flashCategoryMountRenew") == true then
			ButtonPulse_StopPulse(StoreMicroButton)
			ButtonPulse_StopPulse(GameMenuButtonStore)

			if StoreMicroButton:IsEnabled() == 1 then
				SetButtonPulse(StoreMicroButton, 60, 0.50)
			end

			if GameMenuButtonStore:IsEnabled() == 1 then
				SetButtonPulse(GameMenuButtonStore, 60, 0.50)
			end
		end
	elseif event == "PLAYER_LEVEL_UP" then
		local unitLevel = select(1, ...)

		if unitLevel == 80 then
			StoreCacheDataGenerate(true)
		end
	end
end

function StoreFrame_OnShow( self, ... )
	selectedSubCategoryID = 0
	selectedCategoryID = 1
	selectedMoneyID = 1

	SendAddonMessage("ACMSG_PREMIUM_INFO_REQUEST", nil, "WHISPER", UnitName("player"))
	SendAddonMessage("ACMSG_SHOP_BALANCE_REQUEST", nil, "WHISPER", UnitName("player"))
	SendAddonMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST", nil, "WHISPER", UnitName("player"))

	self.Ticker = C_Timer:NewTicker(1, function()
		for d = 1, #STORE_PRODUCT_DATA do
			if STORE_PRODUCT_DATA[d] and STORE_PRODUCT_DATA[d].RemainingTime then
				STORE_PRODUCT_DATA[d].RemainingTime = STORE_PRODUCT_DATA[d].RemainingTime - 1
			end
		end
	end, nil)

	StoreCloseAllFrame()
	StoreFrame_UpdateCategories(self)
	UpdateMicroButtons()

	if self.Popup then
		NPE_TutorialPointerFrame:Hide(self.Popup)
		self.Popup = nil
	end

	if not STORE_HIGHLIGHT_CATEGORY_BUTTON[UnitName("player")] then
		STORE_HIGHLIGHT_CATEGORY_BUTTON[UnitName("player")] = {}
	end

	ButtonPulse_StopPulse(StoreMicroButton)
	ButtonPulse_StopPulse(GameMenuButtonStore)

	StoreFrame.TutorialButton:SetShown(selectedCategoryID == 1)

	PlaySound("igCharacterInfoOpen")
end

function StoreFrame_OnHide( self, ... )
	self.Ticker:Cancel()
	self.Ticker = nil

	for i = 1, StoreGetSpecialOfferCount() do
		local offerData = StoreGetSpecialOfferByIndex(i)

		if offerData then
			if offerData.IsNew then
				offerData.IsNew = false
			end
		end
	end

	StoreCloseAllFrame()
	UpdateMicroButtons()

	if STORE_CACHE:Get("flashCategoryMountRenew") == true then
		ButtonPulse_StopPulse(StoreMicroButton)
		ButtonPulse_StopPulse(GameMenuButtonStore)

		if StoreMicroButton:IsEnabled() == 1 then
			SetButtonPulse(StoreMicroButton, 60, 0.50)
		end

		if GameMenuButtonStore:IsEnabled() == 1 then
			SetButtonPulse(GameMenuButtonStore, 60, 0.50)
		end
	end

	if DressUpFrame:IsShown() then
		DressUpFrame:Hide();
	end

	PlaySound("igCharacterInfoClose")
end

function StoreMoneyButton_OnLoad( self, ... )
	local data = STORE_MONEY_BUTTON_DATA[self:GetID()]
	selectedMoneyID = 1

	self.Icon:SetTexture("Interface\\Store\\"..data.Icon)

	if data.Selected then
		self.Selected:Show()
	end

	if data.Disable then
		self:Disable()
		self.Icon:SetDesaturated(1)
		self.Background:SetDesaturated(1)
		self.Selected:Hide()
		self.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
end

function StoreMoneyButton_OnClick( self, ... )
	if self:GetID() == selectedMoneyID then
		return
	end

	local id = self:GetID()
	local data = STORE_MONEY_BUTTON_DATA[id]
	local frame = _G[data.ChieldFrame]
	selectedMoneyID = id
	selectedSubCategoryID = 0

	StoreCloseAllFrame()
	if frame then
		frame:Show()
	end

	self.Selected:Show()
	StoreFrame_UpdateCategories(StoreFrame)
	if id ~= 1 then
		StoreItemListUpdate()
	end

	if id ~= 4 and StoreItemListScrollFrame:GetScript("OnUpdate") then
		StoreItemListScrollFrame:SetScript("OnUpdate", nil)
	end

	StoreFrame.TutorialButton:SetShown(id == 1)
end

function StoreMoneyButton_OnEnter( self, ... )
	local data = STORE_MONEY_BUTTON_DATA[self:GetID()]

	self.Highlight:Show()

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -15)
	GameTooltip:SetText(data.Name)
	GameTooltip:AddLine(data.Description, 1, 1, 1, 1)
	if self.data then
		if tonumber(self.data[2]) ~= 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string.format(SOTRE_LOYAL_NEXT_LEVEL, self.data[1], self.data[2]), 1, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(" ")
			-- loyalCurrent, loyalMax, loyalMin
			StoreLoyalProgressBarSetValue(self.data[1] - self.data[3], self.data[2] - self.data[3])
			StoreLoyalProgressBar:Show()
		end
	end
	GameTooltip:Show()
end

function StoreMoneyButton_OnLeave( self, ... )
	self.Highlight:Hide()
	StoreLoyalProgressBar:Hide()
	GameTooltip:Hide()
end

function StoreCategory_OnLoad( self, ... )
	self.PulseTexture:SetVertexColor(1, 0.5, 0.5)
end

function StoreCategory_OnClick( self, ... )
	if self:GetID() == selectedCategoryID and self:GetID() ~= 2 and self:GetID() ~= STORE_TRANSMOGRIFY_CATEGORY_ID and self.data.SlideOther == nil and selectedSubCategoryID ~= 0 then
		return
	end

	selectedCategoryID = self:GetID()
	selectedSubCategoryID = 0
	if StoreFrame.CategoryFrames[selectedCategoryID].data.subCategoryDefault then
		selectedSubCategoryID = 1
	end

	selectedShowAllItemCheckBox = 0
	StoreShowAllItemCheckButton:SetChecked(false)

	if StoreItemListUpdate() then
		StoreSelectCategory(selectedCategoryID, selectedSubCategoryID)
	end
	if StoreFrame.CategoryFrames[selectedCategoryID].data.subCategoryDefault then
		StoreSubCategory_OnClick(StoreFrame.SubCategoryFrames[selectedCategoryID * 1000 + 1])
	end
end

function StoreSelectCategory( categoryID, subCategoryID )
	local self = StoreFrame.CategoryFrames[categoryID]

	if self then
		local frame = _G[self.data.ChieldFrame]
		local subCategoryFrame = _G[self.data.subCategoryFrame]

		selectedCategoryID = self:GetID()
		selectedSubCategoryID = subCategoryID or 0

		for _, button in pairs(StoreFrame.CategoryFrames) do
			button.SelectedTexture:Hide()
		end

		StoreCloseAllFrame()

		if frame then
			frame:Show()
		end

		if subCategoryFrame and selectedSubCategoryID ~= 0 then
			frame:Hide()
			subCategoryFrame:Show()
		end

		if self.isHighlight and not tContains(STORE_HIGHLIGHT_CATEGORY_BUTTON[UnitName("player")], self:GetName()) then
			table.insert(STORE_HIGHLIGHT_CATEGORY_BUTTON[UnitName("player")], self:GetName())
			self.PulseTexture:Hide()
		end

		if STORE_CACHE:Get("flashCategoryMountRenew") == true and self:GetID() == 3 then
			STORE_CACHE:Set("flashCategoryMountRenew", "false")
			self.PulseTexture:Hide()
		end

		self.SelectedTexture:Show()

		StoreRefreshMountListButton:SetShown(categoryID == 3 and (selectedSubCategoryID == 1 or selectedSubCategoryID == 2))
		StoreRefreshTransmogListButton:SetShown(categoryID == STORE_TRANSMOGRIFY_CATEGORY_ID)
		StoreRefundButton:SetShown(selectedMoneyID == 1 and categoryID == 2 and #STORE_REFUND_DATA > 0);

		for i, button in pairs(StoreFrame.SubCategoryFrames) do
			button:Hide()
		end
		
		if self.data.SlideOther then
			local prevFrame = nil
			local height = 22 * #STORE_SUB_CATEGORY_DATA[categoryID]
			for i, button in pairs(StoreFrame.CategoryFrames) do
				local isHidden = button.data.Hidden;

				if not isHidden and i ~= 1 then
					if i == (categoryID + 1) then
						button:SetPoint("TOPLEFT", StoreFrame.CategoryFrames[i-1], "BOTTOMLEFT", 0, -height)
					else
						button:SetPoint("TOPLEFT", StoreFrame.CategoryFrames[i-1], "BOTTOMLEFT", 0, 0)
					end

					prevFrame = button;
				end
			end

			for i = 1, #STORE_SUB_CATEGORY_DATA[categoryID] do
				local data = STORE_SUB_CATEGORY_DATA[categoryID][i]
				local subFrame = StoreFrame.SubCategoryFrames[categoryID * 1000 + i]

				if ( not subFrame ) then
					subFrame = CreateFrame("Button", "StoreSubCategoryButton"..i, StoreFrameLeftInset, "StoreSubCategoryTemplate")
					if i == 1 then
						subFrame:SetPoint("TOP", StoreFrame.CategoryFrames[categoryID], "BOTTOM", 0, 0)
					else
						subFrame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
					end
					StoreFrame.SubCategoryFrames[categoryID * 1000 + i] = subFrame
				end
				prevFrame = subFrame
				StoreFrame.SubCategoryFrames[categoryID * 1000 + i].data = data
				subFrame:SetID(i)
				subFrame.Text:SetText(data.Name)
				if data.Disabled or (data.Check and not data.Check()) then
					subFrame:Disable()
					subFrame.Category:SetDesaturated(1)
					subFrame.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
				end
				if (categoryID * 1000 + i) == (categoryID * 1000 + selectedSubCategoryID) then
					subFrame.SelectedTexture:Show()
				else
					subFrame.SelectedTexture:Hide()
				end
				
				subFrame:Show()
			end
		else
			local prevFrame;
			for i, button in pairs(StoreFrame.CategoryFrames) do
				local isHidden = button.data.Hidden;

				if not isHidden then
					if i ~= 1 then
						button:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
					end

					prevFrame = button;
				end
			end
		end
	end
	StoreItemListUpdate()
	StoreFrame.TutorialButton:SetShown(selectedCategoryID == 1)
end

function StoreCategory_OnEnter( self, ... )
	self.HighlightTexture:Show()
end

function StoreCategory_OnLeave( self, ... )
	self.HighlightTexture:Hide()
end

function StoreSubCategory_OnEnter( self, ... )
	self.HighlightTexture:Show()
end

function StoreSubCategory_OnLeave( self, ... )
	self.HighlightTexture:Hide()
end

function StoreSubCategory_OnClick( self, ... )
	for _, button in pairs(StoreFrame.SubCategoryFrames) do
		button.SelectedTexture:Hide()
	end
	self.SelectedTexture:Show()
	self.data.Callback()
end

function StoreItemListFrame_OnLoad( self, ... )
	StoreItemListScrollFrame.update = StoreFrame_UpdateItemList
	HybridScrollFrame_CreateButtons(StoreItemListScrollFrame, "StoreItemListButtonTemplate", 0, 0, nil, nil, 0, -5)
	HybridScrollFrame_OnLoad(StoreItemListScrollFrame)

	self.reverseSort = true;
	self.activeSortId = 5;
end

function StoreItemListFrame_OnShow( self, ... )
	StoreShowAllItemCheckButton:SetShown(selectedCategoryID == 2 and selectedMoneyID == 1)

	StoreItemListFrameContainerSortDiscount:SetShown(selectedMoneyID ~= 4 and selectedMoneyID ~= 3)
	StoreItemListFrameContainerSortItemlevel:SetShown(selectedMoneyID ~= 4 and selectedMoneyID ~= 3)
	StoreItemListFrameContainerSortPVP:SetShown(selectedMoneyID ~= 4 and selectedMoneyID ~= 3)

	if selectedMoneyID == 4 then
		StoreItemListFrameContainerSortPrice.Text:SetText(STORE_LEVEL_LABEL)
	else
		StoreItemListFrameContainerSortPrice.Text:SetText(STORE_PRICE_LABEL)
	end
end

function StoreItemListFrame_OnHide( self, ... )
	STORE_PRODUCT_DATA = {}
	STORE_PRODUCT_LIST = {}

	StoreItemListFrame_ResetFilters();
end

function StoreItemListFrame_SetShownSearchBox(show)
	local container = StoreItemListFrameContainer;
	local searchBox = container.SearchBox;

	if show then
		searchBox:Show();
		searchBox:SetText("");
	else
		searchBox:Hide();
		searchBox:SetText("");
	end

	container.SortName:SetShown(not show);
	container.SortDiscount:SetShown(not show);
	container.SortItemlevel:SetShown(not show);
	container.SortPVP:SetShown(not show);
	container.SortPrice:SetShown(not show);
end

function StoreItemListFrame_ResetFilters()
	StoreItemListFrame.reverseSort = true;
	StoreItemListFrame.activeSortId = 5;

	StoreItemListFrame_SetShownSearchBox(false);
	StoreItemListFrameContainer.SortItemlevel.NumericBox:Hide();

	StoreItemListFrame.isDiscount = false;
	StoreItemListFrame.isPvP = false;
	StoreItemListFrame.iLvl = nil;
end

function StoreItemListButtonTooltip(self)
	if self.data.Entry then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink("Hitem:"..self.data.Entry)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(STORE_ITEM_TOOLTIP_CLICK_TO_BUY_LABEL, 0, 0.8, 1)
		GameTooltip:Show()

		self.UpdateTooltip = StoreItemListButtonTooltip;
	else
		self.UpdateTooltip = nil
	end
end

function StoreItemListButton_OnEnter( self, ... )
	StoreItemListScrollFrame.activeButton = self
	StoreItemListButtonTooltip(self)

	self.Icon:SetSize(44 + 5, 44 + 5)
	self.IconBorder:SetSize(53 + 5, 53 + 5)

	if selectedMoneyID == 4 or selectedMoneyID == 3 or selectedMoneyID == 2 then
		if self.data.CreatureEntry and not StoreConfirmationFrame:IsShown() then
			StoreModelPreviewFrame:Hide()
			StoreModelPreviewFrame.data = self.data
			StoreModelPreviewFrame:Show()

			StoreModelPreviewFrame:SetSize(415, 565 - 100)

			StoreModelPreviewFrame:ClearAllPoints()
			StoreModelPreviewFrame:SetPoint("LEFT", StoreFrame, "RIGHT", 6, 0)
		end
	end
end

function StoreItemListButton_OnLeave( self, ... )
	StoreItemListScrollFrame.activeButton = nil
	GameTooltip:Hide()

	self.IconBorder:SetSize(53, 53)
	self.Icon:SetSize(44, 44)

	if StoreModelPreviewFrame:IsShown() and not StoreConfirmationFrame:IsShown() then
		StoreModelPreviewFrame:Hide()
	end
end

function StoreItemListButton_OnClick( self, ... )
	if ( self.data.Entry ) and IsModifiedClick() then
		local _, link = GetItemInfo(self.data.Entry)
		if HandleModifiedItemClick(link) then
			return
		end
	end

	StoreFrame_ProductBuy( self.data )
end

function StoreRequestSpecialOffer()
	selectedSpecialOfferPage = 1
	SendServerMessage("ACMSG_SHOP_SPECIAL_OFFER_LIST_REQUEST")
end

function StoreSpecialOfferSetPage( page )
	if STORE_SPECIAL_OFFER_INFO_DATA[page] then
		selectedSpecialOfferPage = page
	else
		selectedSpecialOfferPage = 1
	end
end

function StoreSpecialOfferInfoUpdate()
	local shownOfferData = STORE_CACHE:Get("STORE_OFFER_HOUR_SHOWN", {})

	for index, offerData in pairs(STORE_SPECIAL_OFFER_INFO_DATA) do
		offerData.pageID = index

		if offerData.Timer then
			offerData.Timer:Cancel()
			offerData.Timer = nil
		end

		local timerTime = 0

		if offerData.EndTime then
			timerTime = (offerData.EndTime - time()) - 3600
		end

		if timerTime > 0 and not shownOfferData[offerData.offerID] then
			offerData.Timer = C_Timer:After(timerTime, function(self)
				local shownOfferData = STORE_CACHE:Get("STORE_OFFER_HOUR_SHOWN", {})

				shownOfferData[self.offerID] = true
				StoreSpecialOfferSetPage(self.pageID)

				if StoreFrame.Popup then
					NPE_TutorialPointerFrame:Hide(StoreFrame.Popup)
					StoreFrame.Popup = nil
				end

				if not StoreMicroButton:IsVisible() or not StoreMicroButton:IsShown() then
					StoreToastButton.TopLine:SetText(STPRE_TOAST_SPECIAL_OFFER_END_TITLE)
					StoreToastButton.MiddleLine:SetText(self.title)
					StoreToastButton:Show()
				else
					StoreFrame.Popup = NPE_TutorialPointerFrame:Show(string.format(STORE_SPECIAL_OFFER_POPUP_LESS_THAN_HOUR, self.title), "DOWN", StoreMicroButton, 0, -5)
				end

				STORE_CACHE:Set("STORE_OFFER_HOUR_SHOWN", shownOfferData)
			end)

			offerData.Timer.offerID = offerData.offerID
			offerData.Timer.pageID 	= index
			offerData.Timer.endTime = offerData.EndTime
			offerData.Timer.title 	= offerData.Title
		end
	end
end

function StoreSpecialOfferSortUpdate()
	table.sort(STORE_SPECIAL_OFFER_INFO_DATA, function(a, b)
		local isNew_A = a and a.IsNew or false
		local isNew_B = b and b.IsNew or false

		local is3D_A = a and STORE_SPECIAL_OFFERS_3D[a.offerID] or false
		local is3D_B = b and STORE_SPECIAL_OFFERS_3D[b.offerID] or false

		if is3D_A and not is3D_B then
			return true
		elseif not is3D_A and is3D_B then
			return false
		end

		if isNew_A and not isNew_B then
			return true
		elseif not isNew_A and isNew_B then
			return false
		end

		local endTime_A = a.EndTime or -1
		local entTime_B = b.EndTime or -1

		return endTime_A < entTime_B
	end)
end

function StoreSpecialOfferFrame_OnLoad( self, ... )
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UNIT_LEVEL")
end

function StoreSpecialOfferFrame_OnEvent(self, event, unit)
	if event == "PLAYER_LOGIN" or (event == "UNIT_LEVEL" and unit == "player" and UnitLevel("player") == 80) then
		StoreRequestSpecialOffer()
	end
end

function StoreSpecialOfferFrame_OnShow( self, ... )
	StoreSliderSetup(STORE_SLIDER_NORMAL_UPDATE)
	StoreFrame_SpecialOfferSetup()
end

function StoreSpecialOfferFrame_OnHide( self, ... )
	STORE_PRODUCT_DATA = {}
	STORE_PRODUCT_LIST = {}

	if self.SliderTicker then
		self.SliderTicker:Cancel()
		self.SliderTicker = nil
	end
end

function StoreToastButton_OnClick( self, ... )
	self:Hide()
	ShowUIPanel(StoreFrame)
end

function StoreItemCardButton_OnClick( self, ... )
	if ( self.data.Entry ) and IsModifiedClick() then
		local _, link = GetItemInfo(self.data.Entry)
		if HandleModifiedItemClick(link) then
			return
		end
	end

	StoreFrame_ProductBuy( self.data )
end

function StoreItemCardButton_OnEnter( self, ... )
	if self.data.Entry then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink("Hitem:"..self.data.Entry)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(STORE_ITEM_TOOLTIP_CLICK_TO_BUY_LABEL, 0, 0.8, 1)
		GameTooltip:Show()
	end

	self.Highlight:Show()
	self.Icon:SetSize(68 + 5, 68 + 5)
	self.IconBorder:SetSize(78 + 5, 78 + 5)

	self.Model:SetModelScale(1.1)

	self.Magnifier:SetShown(self.data.CreatureEntry)
end

function StoreItemCardButton_OnLeave( self, ... )
	GameTooltip:Hide()
	self.Highlight:Hide()
	self.Icon:SetSize(68, 68)
	self.IconBorder:SetSize(78, 78)

	self.Model:SetModelScale(1)

	self.Magnifier:Hide()
end

function StoreSpecialOfferBanner_OnLoad( self, ... )
	-- body
end

function StoreSpecialOfferBanner_OnShow( self, ... )
	selectedItemCardPage = 1
end

function StoreSpecialOfferBanner_OnHide( self, ... )
	-- body
end

function StoreSpecialOfferBanner_OnEnter( self, ... )
	StoreSliderSetup(STORE_SLIDER_HOVER_UPDATE)
end

function StoreSpecialOfferBanner_OnLeave( self, ... )
	StoreSliderSetup(STORE_SLIDER_NORMAL_UPDATE)
end

function StoreItemCardFrame_OnLoad( self, ... )
	-- body
end

function StoreItemCardFrame_OnShow( self, ... )
	selectedItemCardPage = 1
	StoreItemCardFrameNavigationBarPrevPageButton:Disable()
end

function StoreItemCardFrame_OnHide( self, ... )
	STORE_PRODUCT_DATA = {}
	STORE_PRODUCT_LIST = {}
end

function StoreItemCardButtonMagnifyingGlass_OnClick( self, ... )
	StoreModelPreviewFrame.data = self:GetParent().data
	StoreModelPreviewFrame:Show()
end

function StoreItemCardButtonMagnifyingGlass_OnEnter( self, ... )
	StoreItemCardButton_OnEnter(self:GetParent())
end

function StoreItemCardButtonMagnifyingGlass_OnLeave( self, ... )
	StoreItemCardButton_OnLeave(self:GetParent())
end

function StoreItemCardFrameNavigationBarPrevPageButton_OnClick( self, ... )
	selectedItemCardPage = selectedItemCardPage - 1
	StoreFrame_UpdateItemCard()
end

function StoreItemCardFrameNavigationBarNextPageButton_OnClick( self, ... )
	selectedItemCardPage = selectedItemCardPage + 1
	StoreFrame_UpdateItemCard()
end

function StoreConfirmationFrame_OnHide( self, ... )
	if StoreModelPreviewFrame:IsShown() then
		StoreModelPreviewFrame:Hide()
	end
end

function StoreConfirmationBackButton_OnClick( self, ... )
	local data = self:GetParent().backData

	if not data then
		return
	end

	if data.func then
		data.func()
	end

	if data.backFrame then
		data.backFrame:Show()
	end

	self:GetParent():Hide()
end

function StoreConfirmationFrame_OnShow( self, ... )
	StoreConfirmationSendGiftCheckButton:SetChecked(false)
	StoreConfirmationFrame_UpdateState(StoreConfirmationSendGiftCheckButton)
	StoreConfirmationSendGiftCheckButton:SetEnabled(self.data.Flags and bit.band(self.data.Flags, STORE_ITEM_FLAG_ITEM_GIFT) == STORE_ITEM_FLAG_ITEM_GIFT)
	StoreConfirmationSendGiftCheckButton:SetShown(self.data.Flags and bit.band(self.data.Flags, STORE_ITEM_FLAG_ITEM_GIFT) == STORE_ITEM_FLAG_ITEM_GIFT)

	self.data.buyCount = 1
	StoreConfirmationFrame.MultipleBuyFrame:SetShown(self.data.Flags and bit.band(self.data.Flags, STORE_ITEM_FLAG_MULTIPLE_BUY) == STORE_ITEM_FLAG_MULTIPLE_BUY)
	StoreConfirmationFrame.MultipleBuyFrame.EditBox:SetText(1)


	SetPortraitToTexture(self.Art.Icon, self.data.Texture)
	self.Art.ProductName:SetText(self.data.Name)

	self.MailBackgroundRight:Hide()
	self.MailBackgroundLeft:Hide()

	self.BackButton:SetShown(self.backData)

	if self.backData then
		self.BuyButton:SetPoint("BOTTOMRIGHT", -30, 17)
	else
		self.BuyButton:SetPoint("BOTTOM", 0, 17)
	end

	self.isAltCurrency = false;
	self.NoticeFrame.AltCurrencySelectFrame.currency = self.data.AltCurrency;

	StoreConfirmationFrame_Update(self);

	if self.data.DescriptionText then
		self.NoticeFrame.Notice:SetText(self.data.DescriptionText)
	else
		if self.data and self.data.Entry and STORE_BLOODLINE_BOOK_ITEMS[self.data.Entry] then
			self.data.selfSize = {403, 456};
			self.data.noticeSize = {400, 268};

			self.NoticeFrame.Notice:SetFormattedText("%s\n\n%s", STORE_CONFIRM_NOTICE_WARNING2, STORE_CONFIRM_NOTICE)
		elseif selectedCategoryID == 7 or (selectedCategoryID == STORE_TRANSMOGRIFY_CATEGORY_ID and selectedMoneyID == 1) then
			self.NoticeFrame.Notice:SetFormattedText("%s\n\n%s", STORE_CONFIRM_NOTICE_WARNING, STORE_CONFIRM_NOTICE)
		else
			self.NoticeFrame.Notice:SetText(STORE_CONFIRM_NOTICE)
		end
	end

	StoreConfirmationGiftFrame.MessageFrame.EditBox:SetText("")
	StoreConfirmationGiftFrame.CharacterName:SetText("")

	if self.data.SelectedSpec then
		selectedSpecID = 0
		local _, fileName = UnitClass("player")
		local RoleLocale = {
			["DAMAGER"] = DAMAGER,
			["HEALER"] = HEALER,
			["TANK"] = TANK
		}
		self:SetSize(403, 396 + 60)
		self.NoticeFrame:SetSize(400, 208 + 60)

		StoreConfirmationSelectSpec:Show()

		for i = 1, 3 do
			local data = SHARED_CONSTANTS_SPECIALIZATION[fileName][i]
			local button = _G["StoreConfirmationSelectSpecSelectSpecButton"..i]

			button.tooltipTitle = data.name
			button.tooltip = data.description

			button.SpecName:SetText(data.name)
			button.RoleIcon:SetTexCoord(GetTexCoordsForRole(data.role))
			button.SpecIcon:SetTexture(data.icon)
			button.RoleName:SetText(RoleLocale[data.role])

			button:SetShown(StoreSpecialOfferDetailFrame.selectRole == i)
		end
	else
		selectedSpecID = nil
		StoreConfirmationSelectSpec:Hide()
	end

	StoreConfirmationFrame_UpdateSize(self);

	if selectedMoneyID == 4 or selectedMoneyID == 3 or selectedMoneyID == 2 then
		if self.data.CreatureEntry then
			StoreModelPreviewFrame.data = self.data
			StoreModelPreviewFrame:Show()

			StoreModelPreviewFrame:SetSize(415, 565 - 100)

			StoreModelPreviewFrame:ClearAllPoints()
			StoreModelPreviewFrame:SetPoint("LEFT", StoreFrame, "RIGHT", 6, 0)
		end
	end
end

function StoreConfirmationFrameMoneySelectFrame_OnClick(self)
	local id;

	if self.SelectButton then
		id = self:GetID();
	else
		id = self:GetParent():GetID();
	end

	StoreConfirmationFrame.isAltCurrency = id == 2 and true or false;

	StoreConfirmationFrame_Update(StoreConfirmationFrame);
end

function SelectedStyleDropDown_OnLoad( self, ... )
	RaiseFrameLevel(self)
	UIDropDownMenu_Initialize(self, SelectedStyleDropDown_Initialize)
	UIDropDownMenu_SetSelectedValue(self, nil)
	UIDropDownMenu_SetText(self, STORE_MAIL_CHOOSE_STYLE)
	UIDropDownMenu_SetWidth(self, 160)
	UIDropDownMenu_JustifyText(self, "LEFT")

	self.Label:SetText(STORE_MAIL_STYLE)
end

function SelectedStyleDropDown_OnShow( self, ... )
	UIDropDownMenu_Initialize(self, SelectedStyleDropDown_Initialize)
	UIDropDownMenu_SetSelectedValue(self, nil)
	UIDropDownMenu_SetText(self, STORE_MAIL_CHOOSE_STYLE)
end

function SelectedStyleDropDown_Initialize( self, ... )
	local info = UIDropDownMenu_CreateInfo()
	for i = 1, #STORE_GIFT_DATA do
		local data = STORE_GIFT_DATA[i]
		info.text = data.Text
		info.func = SelectedStyleDropDown_OnClick
		info.value = data.Value
		info.checked = checked
		info.owner = UIDROPDOWNMENU_OPEN_MENU
		UIDropDownMenu_AddButton(info)
	end
end

function SelectedStyleDropDown_OnClick( self, ... )
	UIDropDownMenu_SetSelectedValue(self.owner, self.value)
	local frame = StoreConfirmationFrame
	if self.value.Texture == 0 then
		frame.MailBackgroundLeft:Hide()
		frame.MailBackgroundRight:Hide()
	else
		frame.MailBackgroundRight:Show()
		frame.MailBackgroundLeft:Show()
		frame.MailBackgroundRight:SetTexture("Interface\\Stationery\\"..self.value.Texture.."1")
		frame.MailBackgroundLeft:SetTexture("Interface\\Stationery\\"..self.value.Texture.."2")
	end
end

function StoreConfirmationGiftSocialMessageFrame_OnLoad( self, ... )
	self.EditBox:SetFontObject("GameFontHighlight")
	self.EditBox.Instructions:SetFontObject("GameFontHighlight")
	self.maxLetters = 120
	self.instructions = STORE_GIFT_MESSAGE_INSTRUCTION
	InputScrollFrame_OnLoad(self)
end

function StoreConfirmationSendGiftCheckButton_OnClick( self, ... )
	StoreConfirmationFrame_UpdateState(self)

	StoreConfirmationFrame_Update(StoreConfirmationFrame);
	StoreConfirmationFrame_UpdateSize(StoreConfirmationFrame);
end

function StoreConfirmationButton_OnClick( self, ... )
	local parent = self:GetParent();
	local data = parent.data

	if data.confirmationFunc then
		data.confirmationFunc()
		parent:Hide()
		return
	end

	if StoreConfirmationSendGiftCheckButton:GetChecked() then
		local frame = StoreConfirmationGiftFrame
		local name = frame.CharacterName:GetText()
		local dropDown = UIDropDownMenu_GetSelectedValue(frame.SelectedStyle)
		local text = frame.MessageFrame.EditBox:GetText()

		if not name or not dropDown or not text or string.len(text) == 0 then
			StoreShowErrorFrame(STORE_ERROR, STORE_ERROR_FILL_FIELDS)
			return
		end

		SendAddonMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:%d:1:%s:%d:%s", data.ID, data.buyCount or 1, name, dropDown.Key, text), "WHISPER", UnitName("player"))
	else
		if data.SelectedSpec and StoreSpecialOfferDetailFrame.selectRole and StoreSpecialOfferDetailFrame.selectRole ~= 0 then
--			if parent.hasAltCurrency then
				SendAddonMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:%d:0:%d:%d", data.ID, data.buyCount or 1, StoreSpecialOfferDetailFrame.selectRole, parent.isAltCurrency and 1 or 0), "WHISPER", UnitName("player"))
--			else
--				SendAddonMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:%d:0:%d", data.ID, data.buyCount or 1, StoreSpecialOfferDetailFrame.selectRole), "WHISPER", UnitName("player"))
--			end
		elseif data.isSubscribe then
			SendAddonMessage("ACMSG_SHOP_SUBSCRIBE", string.format("%d:%d", data.ID, data.Time), "WHISPER", UnitName("player"))
			STORE_SUBSCRIBE_DATA = {}
		else
--			if parent.hasAltCurrency then
				SendAddonMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:%d:0:0:%d", data.ID, data.buyCount or 1, parent.isAltCurrency and 1 or 0), "WHISPER", UnitName("player"))
--			else
--				SendAddonMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:%d:0:0", data.ID, data.buyCount or 1), "WHISPER", UnitName("player"))
--			end
		end
	end

	if not data.IsReusable and data.Title then
		selectedRemoveOffer = data.pageID
	end
	parent:Hide()
end

function StorePurchaseAlertFrame_OnShow( self, ... )
	self.animIn:Play()
	self.waitAndAnimOut:Play()

	self.glow:Show()
	self.glow.animIn:Play()

	self.shine:Show()
	self.shine.animIn:Play()
end

function StorePurchaseAlertFrame_OnClick( self, ... )
	StorePurchaseAlertFrame_OnHide( self, ... )
	self:Hide()
end

function StorePurchaseAlertFrame_OnHide( self, ... )
	self.animIn:Stop()
	self.waitAndAnimOut:Stop()

	self.glow:Hide()
	self.glow.animIn:Stop()

	self.shine:Hide()
	self.shine.animIn:Stop()
end

function StoreSpecialOfferTopFrameBuyButton_OnClick( self, ... )
	local data = {
		ID = 1488,
		Texture = "Interface\\ICONS\\INV_Misc_Bag_34",
		Name = STORE_STARTER_KIT_NAME,
		Flags = 0,
		Price = 49
	}

	StoreFrame_ProductBuy(data)
end

function StoreSpecialOfferItem_OnEnter( self, ... )
	if self.Link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.Link)
		GameTooltip:Show()
	end

	self.IconBorderHighlight:Show()
end

function StoreSpecialOfferItem_OnLeave( self, ... )
	GameTooltip:Hide()
	self.IconBorderHighlight:Hide()
end

function StoreSpecialOfferItem_OnClick( self, ... )
	if ( self.Link ) and IsModifiedClick() then
		if HandleModifiedItemClick(self.Link) then
			return
		end
	end
end

function SpecialOfferInfoFrame_OnLoad( self, ... )
	self.ItemButton = {}
end

function SpecialOfferInfoFrame_OnShow( self, ... )
	local data = STORE_SPECIAL_OFFER_POPUP
	local size = (44 / 2) * #data.Item
	local offset = 0

	self.Banner:SetTexture("Interface\\Store\\"..data.Texture)
	self.Banner:SetTexCoord(0, 0.5634765625, 0, 0.9765625)

	self.NameText:SetText(data.Title)
	self.DescriptionText:SetText(data.Description)

	if self.Ticker then
		self.Ticker:Cancel()
		self.Ticker = nil
	end

	if data.RemainingTime and not self.Ticker then
		self.TimerText:SetRemainingTime(STORE_SPECIAL_OFFER_POPUP.RemainingTime)
		self.TimerBlock:SetShown(STORE_SPECIAL_OFFER_POPUP.RemainingTime > 0)
		self.Ticker = C_Timer:NewTicker(1, function()
			STORE_SPECIAL_OFFER_POPUP.RemainingTime = STORE_SPECIAL_OFFER_POPUP.RemainingTime - 1
			if self:IsVisible() then
				self.TimerBlock:SetShown(STORE_SPECIAL_OFFER_POPUP.RemainingTime > 0)
				self.TimerText:SetRemainingTime(STORE_SPECIAL_OFFER_POPUP.RemainingTime)
			else
				self.Ticker:Cancel()
				self.Ticker = nil
			end
		end, data.RemainingTime + 1)
	end

	for i = 1, #data.Item do
		local frame = self.ItemButton[i]
		local Entry = data.Item[i].Entry

		if not frame then
			frame = CreateFrame("Button", nil, self, "StoreSpecialOfferItemTemplate")
			self.ItemButton[i] = frame
		end

		local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(Entry)
		frame.Link = link

		frame.Icon:SetTexture(texture)

		frame:SetPoint("BOTTOM", self, -size + 45 * offset + 22, 30)
		frame:Show()
		offset = offset + 1
	end

	for i = #data.Item + 1, #self.ItemButton do
		self.ItemButton[i]:Hide()
	end
end

function SpecialOfferInfoFrame_OnHide( self, ... )
	-- body
end

function StoreSpecialOfferBannerPrevPageButton_OnClick( self, ... )
	selectedSpecialOfferPage = selectedSpecialOfferPage - 1
	StoreFrame_SpecialOfferSetup()
end

function StoreSpecialOfferBannerNextPageButton_OnClick( self, ... )
	selectedSpecialOfferPage = selectedSpecialOfferPage + 1
	StoreFrame_SpecialOfferSetup()
end

function StoreSpecialOfferBannerDetails_OnClick( self, ... )
	local data = StoreGetSpecialOfferByIndex(selectedSpecialOfferPage)
	if data.Price == 0 and not data.FreeSubscribe then
		SendAddonMessage("ACMSG_SHOP_BUY_ITEM", string.format("%d:1:0:0:0", data.ID), "WHISPER", UnitName("player"))
		if not data.IsReusable and data.Title then
			StoreRemoveOffer(data.pageID)
			selectedSpecialOfferPage = 1
			StoreFrame_SpecialOfferSetup()
		end
	elseif data.FreeSubscribe then
		selectedCategoryID = 9
		StoreCloseAllFrame()
		StoreSubscribeFrame:Show()
	else
		StoreSpecialOfferDetailFrame.offerData = data
		StoreSpecialOfferDetailFrame:Show()
	end
end

function SpecialOfferFullScreenBannerBody_OnLoad( self, ... )
	SetPortraitToTexture(self.Icon, "Interface\\ICONS\\INV_Misc_Bag_34")
end

function SpecialOfferFullScreenBannerBody_OnShow( self, ... )
	local data = STORE_SPECIAL_OFFER_POPUP
	self.CountItemButton = 0

	for i = 1, #data.Item do
		local frame = _G["SpecialOfferFullScreenItemButton"..i]
		local Entry = data.Item[i].Entry
		local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(Entry or 0)
		frame.Link = link

		frame.Icon:SetTexture(texture)
		frame:Show()

		self.CountItemButton = self.CountItemButton + 1
	end

	if self.Ticker then
		self.Ticker:Cancel()
		self.Ticker = nil
	end

	for i = #data.Item + 1, self.CountItemButton do
		local frame = _G["SpecialOfferFullScreenItemButton"..i]
		frame:Hide()
	end

	if data.RemainingTime and not self.Ticker then
		self.Timer:SetRemainingTime(data.RemainingTime)
		self.Ticker = C_Timer:NewTicker(1, function()
			data.RemainingTime = data.RemainingTime - 1
			if self:IsVisible() then
				self.Timer:SetRemainingTime(data.RemainingTime)
			else
				self.Ticker:Cancel()
				self.Ticker = nil
			end
		end, data.RemainingTime + 1)
	end
end

function StoreSelectSpecButton_OnClick( self, ... )
	for i = 1, 3 do
		local button = _G["StoreConfirmationSelectSpecSelectSpecButton"..i]
		if button:GetID() ~= self:GetID() then
			button:SetChecked(0)
		end
	end

	selectedSpecID = self:GetID()
end

function StoreSubCategorySelectContainer_OnLoad( self, ... )
	-- body
end

function StoreSubCategorySelectContainer_OnShow( self, ... )
	for index, button in pairs(self.subCategoryButtons) do
		local isNew = StoreFrame_SubCategoryIsNew(selectedMoneyID, selectedCategoryID, index)

		button.IsNewFrame:SetShown(isNew)
	end
end

function StoreSubCategorySelectContainer_OnHide( self, ... )
	-- body
end

function StoreSubCategorySelectButton_OnLoad( self, ... )
	self:SetParentArray("subCategoryButtons")

	local name = strsub(self:GetName(), 32)
	local _, texture = GetInventorySlotInfo(name)

	self.Text:SetText(_G[strupper(name)])
	self.Icon:SetTexture(texture)

	if self:GetID() >= 7 and self:GetID() <= 12 then
		self.Icon:ClearAndSetPoint("RIGHT", 0, 0)
		self.IsNewFrame:ClearAndSetPoint("BOTTOMLEFT", self.IconBorder, "BOTTOMLEFT", 2, 2)
	end

	if self:GetID() == 13 then
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("RIGHT", 0, 0)
		self.Background:SetSize(180, 42)
		self:SetSize(180, 42)
	end

	if self:GetID() == 14 then
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("LEFT", 0, 0)
		self.Background:SetSize(180, 42)
		self:SetSize(180, 42)
	end

	if self:GetID() == 15 then
		self.Background:SetSize(180, 42)
		self:SetSize(180, 42)
		self.Text:SetText(STORE_RANGED)
	end
end

function StoreSubCategorySelectButton_OnEnter( self, ... )
	self.IconBorderHighlight:Show()
	self.BackgroundHighlight:Show()
end

function StoreSubCategorySelectButton_OnLeave( self, ... )
	self.IconBorderHighlight:Hide()
	self.BackgroundHighlight:Hide()
end

function StoreSubCategorySelectButton_OnClick( self, ... )
	selectedSubCategoryID = self:GetID()

	StoreSubCategorySelectClick()
end

function StoreSubCategorySelectClick()
	selectedShowAllItemCheckBox = 0
	StoreShowAllItemCheckButton:SetChecked(false)

	if StoreItemListUpdate() then
		StoreSelectCategory(selectedCategoryID, selectedSubCategoryID)
	end
end

function StoreShowAllItemCheckButton_OnClick( self, ... )
	selectedShowAllItemCheckBox = self:GetChecked() and 1 or 0
	StoreItemListUpdate()
end

function StorePremiumButtons_OnEnter( self, ... )
	self.BorderHighlight:Show()
	self.IconBorderHighlight:Show()
end

function StorePremiumButtons_OnLeave( self, ... )
	self.BorderHighlight:Hide()
	self.IconBorderHighlight:Hide()
end

function StorePremiumButtons_OnClick( self, ... )
	StoreBuyPremiumFrame:Show()
end

function StorePremiumSelectCheckButton_OnLoad( self, ... )
	local data = STORE_PREMIUM_DATA[self:GetID()]

	self.Sched:SetText(data.Text)
	self.Price:SetFormattedText(STORE_PREMIUM_PRICE_FORMAT, data.Price)
	self.SchedInfo:SetText(data.Info)
end

function StorePremiumSelectCheckButton_OnShow( self, ... )
	self:SetChecked(0)

	SelectPremiumButton1:SetChecked(true)
	StoreBuyPremiumFrame.Price:SetText(STORE_PREMIUM_DATA[1].Price)
end

function StorePremiumSelectCheckButton_OnClick( self, ... )
	for i = 1, 4 do
		local button = _G["SelectPremiumButton"..i]
		if button:GetID() ~= self:GetID() then
			button:SetChecked(0)
		else
			button:SetChecked(1)
		end
	end

	selectedPremiumID = self:GetID()
	StoreBuyPremiumFrame.Price:SetText(STORE_PREMIUM_DATA[self:GetID()].Price)
end

function StoreBuyPremiumFrame_OnShow( self, ... )
	selectedPremiumID = 1
	self.infotext:SetText(STORE_PREMIUM_INFO)
end

function StorePremiumBuyButton_OnClick( self, ... )
	SendAddonMessage("ACMSG_PREMIUM_RENEW_REQUEST", selectedPremiumID, "WHISPER", UnitName("player"))
	StoreBuyPremiumFrame:Hide()
end

function StoreSubscribeFrame_OnShow( self, ... )
	SendAddonMessage("ACMSG_SHOP_SUBSCRIPTION_LIST_REQUEST", nil, "WHISPER", UnitName("player"))
	STORE_SUBSCRIBE_DATA = {}
end

function StoreSubscribeItem_OnShow( self, ... )
	self.glow.AnimGlow:Play()
	self.glow2.AnimGlow:Play()
end

function StoreSubscribeItem_OnEnter( self, ... )
	if self.Link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.Link)
		GameTooltip:Show()
	end
end

function StoreSubscribeBuyButton_OnClick( self, ... )
	if STORE_SUBSCRIBE_DATA[selectedSubsID].ShowTrial then
		SendAddonMessage("ACMSG_SHOP_SUBSCRIBE", string.format("%d:%d", STORE_SUBSCRIBE_DATA[selectedSubsID].ID, 1), "WHISPER", UnitName("player"))
		STORE_SUBSCRIBE_DATA = {}
	else
		StoreFrame_ProductBuy(self.SubscribeData)
	end
end

function StoreRefundFrame_OnLoad( self, ... )
	StoreRefundListScrollFrame.scrollBar.doNotHide = true
	StoreRefundListScrollFrameScrollBarBG:Show()
	StoreRefundListScrollFrameScrollBarBG:SetVertexColor(0, 0, 0, 0.3)
	StoreRefundListScrollFrameScrollBarTop:Hide()
	StoreRefundListScrollFrameScrollBarBottom:Hide()
	StoreRefundListScrollFrameScrollBarMiddle:Hide()

	StoreRefundListScrollFrame.update = StoreRefundListScrollFrame_UpdateItemList
	HybridScrollFrame_CreateButtons(StoreRefundListScrollFrame, "StoreRefundButtonTemplate", 2.4, 0, nil, nil, 0, 0, "TOP", "BOTTOM")
end

function StoreRefundFrame_OnShow( self, ... )
	StoreRefundItem_Select(1)
end

function StoreRefundFrame_OnHide( self, ... )
	StoreRefundFrame.selectedItemGUID = nil
	StoreRefundFrame.selectedIndex = nil
end

function StoreRefundListScrollFrame_UpdateItemList()
	local scrollFrame = StoreRefundListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	local numRefundData = #STORE_REFUND_DATA
	local displayedHeight = 0
	local showItem = true

	showItem = numRefundData < 1 and 0 or 1

	for i = 1, #buttons do
		local button = buttons[i]
		local displayIndex = i + offset

		if displayIndex <= numRefundData and STORE_REFUND_DATA[displayIndex] then
			local data = STORE_REFUND_DATA[displayIndex]
			local itemlink = data.bag == "255" and GetInventoryItemLink("player", data.slot) or GetContainerItemLink(data.bag, data.slot)

			if itemlink then
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemlink)
				local buyDate = date("%d.%m.%Y", data.purchaseDate)

				button.itemLink = itemlink
				button.index = displayIndex
				button.data = data

				if StoreRefundFrame.selectedItemGUID == data.itemGUID then
					button.BackgroundSelected:Show()
				else
					button.BackgroundSelected:Hide()
				end

				local penalty = string.format(STORE_REFUND_PANELTY_LABEL, data.penalty > 0 and "FF0000" or "00FF00", data.penalty)

				button.Icon:SetTexture(itemTexture)
				button.ItemName:SetText(itemName.." - "..penalty)

				button.itemDescription:SetRemainingTime(STORE_REFUND_DATA[displayIndex].remainingTime, true)
				button.itemDescription:SetFormattedText(STORE_REFUND_ITEM_DESCRIPTION, buyDate, button.itemDescription:GetText())

				if button.Timer then
					button.Timer:Cancel()
					button.Timer = nil
				end

				button.Timer = C_Timer:NewTicker(1, function()
					if STORE_REFUND_DATA and STORE_REFUND_DATA[displayIndex] then
						STORE_REFUND_DATA[displayIndex].remainingTime = STORE_REFUND_DATA[displayIndex].remainingTime - 1
						button.itemDescription:SetRemainingTime(STORE_REFUND_DATA[displayIndex].remainingTime, true)
						button.itemDescription:SetFormattedText(STORE_REFUND_ITEM_DESCRIPTION, buyDate, button.itemDescription:GetText())

						if STORE_REFUND_DATA[displayIndex].remainingTime <= 0 then
							table.remove(STORE_REFUND_DATA, displayIndex)
							StoreRefundListScrollFrame_UpdateItemList()
						end
					end

					if not button:IsVisible() and button.Timer then
						button.Timer:Cancel()
						button.Timer = nil
					end
				end)

				local rarityColor = BAG_ITEM_QUALITY_COLORS[itemRarity]

				if rarityColor then
					button.ItemName:SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b)
					SetItemButtonQuality(button.IconHitBox, itemRarity, itemlink)
				end

				displayedHeight = displayedHeight + button:GetHeight()
				button:Show()
			end
		else
			button:Hide()
		end
	end

	local totalHeight = (numRefundData * buttons[1]:GetHeight() + 40) - buttons[1]:GetHeight()
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

	if ( not showItem ) then
		StoreRefundFrame.selectedItemGUID = nil
		StoreRefundFrame.selectedIndex = nil
	end
end

function StoreRefundButton_OnClick( self, ... )
	StoreRefundItem_Select(self.index)
end

function StoreRefundItem_Select( index )
	if STORE_REFUND_DATA and STORE_REFUND_DATA[index] then
		local data = STORE_REFUND_DATA[index]
		if StoreRefundFrame.selectedItemGUID ~= data.itemGUID then
			StoreRefundFrame.selectedItemGUID = data.itemGUID
			StoreRefundFrame.selectedIndex = index

			StoreRefundFrame.price:SetText(data.refundBonuses)

			StoreRefundListScrollFrame_UpdateItemList()
		end
	end
end

function RefundButton_OnClick( self, ... )
	if STORE_REFUND_DATA and STORE_REFUND_DATA[StoreRefundFrame.selectedIndex] then
		local data = STORE_REFUND_DATA[StoreRefundFrame.selectedIndex]
		SendAddonMessage("ACMSG_SHOP_PURCHASE_REFUND", data.itemGUID, "WHISPER", UnitName("player"))

		StoreRefundFrame.RefundButton:Disable()
		StoreRefundFrame:Hide()
	end
end

function StoreRefundButtonHitBox_OnEnter( self, ... )
	if not self:GetParent().itemLink then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink(self:GetParent().itemLink)
	GameTooltip:Show()
end

function StoreRefundButtonHitBox_OnLeave( self, ... )
	GameTooltip:Hide()
end

function StoreRefundButtonHitBox_OnClick( self, ... )
	local itemLink = self:GetParent().itemLink
	if ( itemLink ) and IsModifiedClick() then
		if HandleModifiedItemClick(itemLink) then
			return
		end
	end
end

function IsStoreRefundableItem( itemID )
	if not itemID then
		return;
	end

	for _, data in ipairs(STORE_REFUND_DATA) do
		if itemID == data.itemID and data.remainingTime - (GetTime() - data.requestTime) > 0 then
			return true;
		end
	end
end

function StoreSpecialOfferDetailFrame_OnLoad( self, ... )
	self.selectRole = 1
	self.offerID = 1
	self.offerData = {}

	StoreSpecialOfferDetailFrameListScrollFrame.update = StoreSpecialOfferDetailFrame_UpdateItemList
	StoreSpecialOfferDetailFrameListScrollFrame.ScrollBar.doNotHide = true
	StoreSpecialOfferDetailFrameListScrollFrameScrollBarBG:Hide()
	StoreSpecialOfferDetailFrameListScrollFrameScrollBarTop:Hide()
	StoreSpecialOfferDetailFrameListScrollFrameScrollBarBottom:Hide()
	StoreSpecialOfferDetailFrameListScrollFrameScrollBarMiddle:Hide()
	HybridScrollFrame_CreateButtons(StoreSpecialOfferDetailFrameListScrollFrame, "StoreSpecialOfferDetailItemTemplate", 0, 0)
	HybridScrollFrame_OnLoad(StoreSpecialOfferDetailFrameListScrollFrame)

	self.noItems.text:SetText(STORE_SPECIAL_OFFER_DETAIL_NO_ITEM_LEBEL)
	self.selectRoleFrame.text:SetText(STORE_SPECIAL_OFFER_DETAIL_ROLE_INFO)
end

local offerDetailData = {
	{
		{47078, 40343, 47789, 48381, 100367, 47209, 47432, 45978}
	},
	{
		{1}
	},
	{
		{48650, 39419, 42267, 47423}
	}
}

function StoreSpecialOfferDetailFrame_UpdateItemList()
	local scrollFrame = StoreSpecialOfferDetailFrameListScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local role = StoreSpecialOfferDetailFrame.selectRole
	local offerID = StoreSpecialOfferDetailFrame.offerID
	local numProduct
	if STPRE_SPECIAL_OFFER_DETAILS_DATA and STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID] and STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID]["items"] and STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID]["items"][role] then
		numProduct = #STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID]["items"][role]
	else
		numProduct = -1
	end
	local displayedHeight = 0

	local roleName = {STORE_MELEE_FIGHTER, STORE_RANGED_FIGHTER, STORE_TANK, STORE_HEALER}

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if numProduct ~= -1 and STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID]["items"][role][index] then
			local itemID = STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID]["items"][role][index].itemID
			local count = STPRE_SPECIAL_OFFER_DETAILS_DATA[offerID]["items"][role][index].count
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemID)

			if itemID == 0 then
				itemName = GUILDCONTROL_OPTION16
				itemRarity = 1
				itemTexture = "Interface\\ICONS\\INV_Misc_Coin_02"
			end

			local rarityColor = BAG_ITEM_QUALITY_COLORS[itemRarity]

			if rarityColor then
				button.ItemName:SetTextColor(rarityColor.r, rarityColor.g, rarityColor.b)
				SetItemButtonQuality(button.IconHitBox, itemRarity, itemLink)
			end

			count = itemID == 0 and count / 10000 or count

			button.Icon:SetTexture(itemTexture)
			button.ItemName:SetText(itemName)
			button.roleName:SetText("x"..count)

			button.itemLink = itemLink

			displayedHeight = displayedHeight + button:GetHeight()
			button:Show()
		else
			button:Hide()
		end
	end

	scrollFrame:SetShown(numProduct ~= -1)
	StoreSpecialOfferDetailFrame.noItems.text:SetShown(numProduct == -1)

	local totalHeight = (numProduct * buttons[1]:GetHeight() + 40) - buttons[1]:GetHeight()
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end

function StoreSpecialOfferDetailFrame_OnShow( self, ... )
	local oldKeyValue
	self.offerID = self.offerData.offerID

	self.Bottom.BuyButton:Disable()

	self.Shown = true

	self.header.description:SetText(STPRE_SPECIAL_OFFER_DETAILS_DATA[self.offerID]["description"])
	self.header.Title:SetText(STPRE_SPECIAL_OFFER_DETAILS_DATA[self.offerID]["title"])

	self.Bottom.Price:SetText(STPRE_SPECIAL_OFFER_DETAILS_DATA[self.offerID]["price"])

	self:SetSize(400, 400)
	self.Role:Show()

	self.BlockLayer:ClearAllPoints()
	self.BlockLayer:SetPoint("TOPLEFT", self.ParchmentMiddle, 20, -200)
	self.BlockLayer:SetPoint("BOTTOMRIGHT", self.ParchmentMiddle, -20, 80)

	for i = 1, 3 do
		local button = _G["StoreSpecialOfferDetailRoleButton"..i]
		button:Disable()
	end

	for k, v in pairs(STPRE_SPECIAL_OFFER_DETAILS_DATA[self.offerID]["items"]) do
		if k and k ~= 0 then
			local button = _G["StoreSpecialOfferDetailRoleButton"..k]
			if button then
				button:Enable()
				if not oldKeyValue then
					oldKeyValue = true
					if self.isBack then
						StoreSpecialOfferDetailRoleButton_OnClick( button )
					else
						StoreSpecialOfferDetailFrameListScrollFrame:Hide()
						self.selectRoleFrame:Show()
					end
				end
			end
		elseif k == 0 then
			StoreSpecialOfferDetailFrame.selectRole = k
		end

		if k == 0 or tCount(STPRE_SPECIAL_OFFER_DETAILS_DATA[self.offerID]["items"]) == 0 then
			StoreSpecialOfferDetailFrame:SetSize(400, 500)

			self.BlockLayer:ClearAllPoints()
			self.BlockLayer:SetPoint("TOPLEFT", self.ParchmentMiddle, 20, -135)
			self.BlockLayer:SetPoint("BOTTOMRIGHT", self.ParchmentMiddle, -20, 80)

			StoreSpecialOfferDetailFrame.selectRole = k
			StoreSpecialOfferDetailFrame_UpdateItemList()

			self.Role:Hide()

			StoreSpecialOfferDetailFrame.selectRoleFrame:Hide()
			StoreSpecialOfferDetailFrame.Bottom.BuyButton:Enable()
		end
	end
end

function StoreSpecialOfferDetailFrame_OnHide( self, ... )
	self.Shown = false
end

function StoreSpecialOfferDetailRoleButton_OnLoad( self, ... )
	local id = self:GetID()
	local _, fileName = UnitClass("player")
	local data = SHARED_CONSTANTS_SPECIALIZATION[fileName][id]

	if data then
		SetPortraitToTexture(self.specIcon, data.icon)
	end
end

function StoreSpecialOfferDetailItemHitBox_OnEnter( self, ... )
	if not self:GetParent().itemLink then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink(self:GetParent().itemLink)
	GameTooltip:Show()
end

function StoreSpecialOfferDetailItemHitBox_OnLeave( self, ... )
	GameTooltip:Hide()
end

function StoreSpecialOfferDetailItemHitBox_OnClick( self, ... )
	local itemLink = self:GetParent().itemLink
	if ( itemLink ) and IsModifiedClick() then
		if HandleModifiedItemClick(itemLink) then
			return
		end
	end
end

function StoreSpecialOfferDetailRoleButton_OnShow( self, ... )
	self.IconGlow:Hide()
	self.Arrow:Hide()
end

function StoreSpecialOfferDetailRoleButton_OnEnter( self, ... )
	self.IconBorderHighlight:Show()
end

function StoreSpecialOfferDetailRoleButton_OnLeave( self, ... )
	self.IconBorderHighlight:Hide()
end

function StoreSpecialOfferDetailRoleButton_OnClick( self, ... )
	self.IconGlow:Show()
	self.Arrow:Show()
	StoreSpecialOfferDetailFrame.selectRole = self:GetID()
	StoreSpecialOfferDetailFrame_UpdateItemList()

	StoreSpecialOfferDetailFrame.selectRoleFrame:Hide()
	StoreSpecialOfferDetailFrame.Bottom.BuyButton:Enable()

	if StoreSpecialOfferDetailFrame.isBack then
		StoreSpecialOfferDetailFrame:SetSize(400, 600)
		StoreSpecialOfferDetailFrame.isBack = false
	end

	local _, _sizeY = StoreSpecialOfferDetailFrame:GetSize()
	_sizeY = math.ceil( _sizeY )

	if _sizeY < 600 and StoreSpecialOfferDetailFrame.Shown then
		local sizeY = 400
		StoreSpecialOfferDetailFrame.Shown = false
		StoreSpecialOfferDetailFrame.ListScrollFrame.AnimIn:Play()

		StoreSpecialOfferDetailFrame.ScaleTimer = C_Timer:NewTicker(0.0001, function()
			sizeY = sizeY + 6
			StoreSpecialOfferDetailFrame:SetSize(400, sizeY)
			if sizeY >= 600 and StoreSpecialOfferDetailFrame.ScaleTimer then
				StoreSpecialOfferDetailFrame:SetSize(400, 600)
				StoreSpecialOfferDetailFrame_UpdateItemList()
				StoreSpecialOfferDetailFrame.ScaleTimer:Cancel()
				StoreSpecialOfferDetailFrame.ScaleTimer = nil
			end
		end)
	end

	for i = 1, 3 do
		if i ~= self:GetID() then
			local button = _G["StoreSpecialOfferDetailRoleButton"..i]

			if button then
				button.IconGlow:Hide()
				button.Arrow:Hide()
			end
		end
	end
end

function StoreSpecialOfferDetailFrame_OnClick( self, ... )
	StoreSpecialOfferDetailFrame:Hide()

	local backData = {
		backFrame = StoreSpecialOfferDetailFrame,
		func = function() StoreSpecialOfferDetailFrame.isBack = true end
	}

	StoreFrame_ProductBuy(StoreSpecialOfferDetailFrame.offerData, backData)
end

function StoreSubscribeSetup()
	-- main subs always first
	selectedSubsID = selectedSubCategoryID > 0 and selectedSubCategoryID or 1
	local data = STORE_SUBSCRIBE_DATA[selectedSubsID]
	if data == nil then
		return
	end

	StoreSubscribeSetupModel();

	if StoreSubscribeFrame.Ticker then
		StoreSubscribeFrame.Ticker:Cancel()
		StoreSubscribeFrame.Ticker = nil
	end

	StoreSubscribeContainer.Active.timer1:SetRemainingTime(STORE_SUBSCRIBE_DATA[selectedSubsID].Seconds)
	StoreSubscribeFrame.Ticker = C_Timer:NewTicker(1, function()
		STORE_SUBSCRIBE_DATA[selectedSubsID].Seconds = STORE_SUBSCRIBE_DATA[selectedSubsID].Seconds - 1
		if StoreSubscribeContainer.Active.timer1:IsVisible() then
			StoreSubscribeContainer.Active.timer1:SetRemainingTime(STORE_SUBSCRIBE_DATA[selectedSubsID].Seconds)
		else
			StoreSubscribeFrame.Ticker:Cancel()
			StoreSubscribeFrame.Ticker = nil
		end
	end, data.Seconds)
	
	for d = 1, 3 do
		local button = _G["StoreSubscribeItemButton"..d]
		button:Hide()
	end

	for k = 1, 1 do
		local button = _G["StoreSubscribeSubItemButton"..k]
		button:Hide()
	end

	for i = 1, 4 do
		local button = _G["StoreSubscribeContainerBuyButton"..i]

		if button then
			button:Hide()
		end
	end

	if #data.EveryDayItem == 1 then
		local button = _G["StoreSubscribeItemButton"..2]
		if button then
			local Entry = data.EveryDayItem[1].Entry
			local Count = data.EveryDayItem[1].Count
			local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(tonumber(Entry))
			button.Link = link

			button.iconTexture:SetTexture(texture)
			button.name:SetText(name)
			button.count:SetText(Count)

			button:Show()
		end
	else
		for i = 1, #data.EveryDayItem do
			local button = _G["StoreSubscribeItemButton"..i]
			if button then
				local Entry = data.EveryDayItem[i].Entry
				local Count = data.EveryDayItem[i].Count
				local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(tonumber(Entry))
				button.Link = link

				button.iconTexture:SetTexture(texture)
				button.name:SetText(name)
				button.count:SetText(Count)

				button:Show()
			end
		end
	end

	for s = 1, #data.OnSubscribeItem do
		local button = _G["StoreSubscribeSubItemButton"..s]
		if button then
			local Entry = data.OnSubscribeItem[s].Entry
			local Count = data.OnSubscribeItem[s].Count
			local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(tonumber(Entry))
			button.Link = link

			button.iconTexture:SetTexture(texture)
			button.name:SetText(name)
			button.count:SetText(Count)
			button:Show()
		end
	end

	if data.Dayz then
		StoreSubscribeFrame.BackgroundTile:SetVertexColor(0.6, 1, 0.6)
		StoreSubscribeContainer.Active.timer2:SetFormattedText(STORE_SUBSCRIBE_ACTIVE_TIME_LABEL, data.Dayz)
	else
		StoreSubscribeFrame.BackgroundTile:SetVertexColor(1, 1, 1)
		StoreSubscribeContainer.Inactive.ItemContainer:SetShown(#data.OnSubscribeItem > 0)
		StoreSubscribeContainer.Inactive.BuyText:SetShown(#data.OnSubscribeItem <= 0)
	end

	local subData = STORE_SUBSCRIBE_DATA[selectedSubsID];

	if data.ShowTrial and not data.Dayz then
		StoreSubscribeContainer.BuyButton1:SetText(STORE_BUY_FOR_FREE)

		StoreSubscribeContainer.BuyButton1:Show()
	elseif not data.ShowTrial and not data.Dayz then
		StoreSubscribeContainer.BuyButton1:SetFormattedText(STORE_SUBSCRIBE_BUY_1, data.ShortPrice)
		StoreSubscribeContainer.BuyButton2:SetFormattedText(STORE_SUBSCRIBE_BUY_2, data.LongPrice)

		StoreSubscribeContainer.BuyButton1.SubscribeData = StoreConfigurateSubscribeData(2, string.format(STORE_SUBSCRIBE_BUY_TIME, subData.Name, 7), data.ShortPrice, string.format(STORE_SUBSCRIBE_BUY_DESCRIPTION, subData.Name))
		StoreSubscribeContainer.BuyButton2.SubscribeData = StoreConfigurateSubscribeData(3, string.format(STORE_SUBSCRIBE_BUY_TIME, subData.Name, 30), data.LongPrice, string.format(STORE_SUBSCRIBE_BUY_DESCRIPTION, subData.Name))

		StoreSubscribeContainer.BuyButton1:Show()
		StoreSubscribeContainer.BuyButton2:Show()
	elseif not data.ActiveTrial and data.Dayz and not data.ActiveExtra then
		StoreSubscribeContainer.BuyButton1:SetFormattedText(STORE_SUBSCRIBE_PROLONG_1, data.ShortPrice)
		StoreSubscribeContainer.BuyButton2:SetFormattedText(STORE_SUBSCRIBE_PROLONG_2, data.LongPrice)
		StoreSubscribeContainer.BuyButton3:SetFormattedText(STORE_EXTRA_SUBSCRIBE_UPGRADE, data.ExtraPrice)

		StoreSubscribeContainer.BuyButton1.SubscribeData = StoreConfigurateSubscribeData(2, string.format(STORE_SUBSCRIBE_BUY_TIME, subData.Name, 7 + 1), data.ShortPrice, string.format(STORE_SUBSCRIBE_BUY_DESCRIPTION, subData.Name))
		StoreSubscribeContainer.BuyButton2.SubscribeData = StoreConfigurateSubscribeData(3, string.format(STORE_SUBSCRIBE_BUY_TIME, subData.Name, 30 + 3), data.LongPrice, string.format(STORE_SUBSCRIBE_BUY_DESCRIPTION, subData.Name))
		StoreSubscribeContainer.BuyButton3.SubscribeData = StoreConfigurateSubscribeData(4, string.format(STORE_EXTRA_SUBSCRIBE_BUYUP_TIME, subData.Name, data.Dayz), data.ExtraPrice, string.format(STORE_EXTRA_SUBSCRIBE_BUY_DESCRIPTION, subData.Name))

		StoreSubscribeContainer.BuyButton3:ShowGlow(true)

		StoreSubscribeContainer.BuyButton1:Show()
		StoreSubscribeContainer.BuyButton2:Show()
		StoreSubscribeContainer.BuyButton3:Show()
	elseif not data.ActiveTrial and data.Dayz and data.ActiveExtra then
		StoreSubscribeContainer.BuyButton1:SetFormattedText(STORE_SUBSCRIBE_PROLONG_1, data.ShortPrice)
		StoreSubscribeContainer.BuyButton2:SetFormattedText(STORE_SUBSCRIBE_PROLONG_2, data.LongPrice)

		StoreSubscribeContainer.BuyButton1.SubscribeData = StoreConfigurateSubscribeData(2, string.format(STORE_EXTRA_SUBSCRIBE_BUY_TIME, subData.Name, 7 + 1), data.ShortPrice, STORE_EXTRA_SUBSCRIBE_BUY_DESCRIPTION)
		StoreSubscribeContainer.BuyButton2.SubscribeData = StoreConfigurateSubscribeData(3, string.format(STORE_EXTRA_SUBSCRIBE_BUY_TIME, subData.Name, 30 + 3), data.LongPrice, STORE_EXTRA_SUBSCRIBE_BUY_DESCRIPTION)

		StoreSubscribeContainer.BuyButton1:ShowGlow(nil, 0.5)
		StoreSubscribeContainer.BuyButton2:ShowGlow(nil, 0.5)

		StoreSubscribeContainer.BuyButton1:Show()
		StoreSubscribeContainer.BuyButton2:Show()
	end

	if data.ActiveExtra then
		StoreSubscribeContainer.HeaderText:SetText(STORE_EXTRA_SUBSCRIBE .. " " .. data.Name)
	else
		StoreSubscribeContainer.HeaderText:SetText(data.Name)
	end

    StoreSubscribeContainer.infotext:SetText(data.Description)

	StoreSubscribeContainer.VIPBackground:SetShown(data.Dayz and data.ActiveExtra)
	StoreSubscribeContainer.BackgroundColor:SetShown(data.Dayz and data.ActiveExtra)
	StoreSubscribeContainer.HeaderBackgroundAlpha:SetShown(data.Dayz and data.ActiveExtra)

	StoreSubscribeContainer.Inactive:SetShown(not data.Dayz)
	StoreSubscribeContainer.Active:SetShown(data.Dayz)
end

function StoreSubscribeSetupModel(self)
	self = self or StoreSubscribeContainer.ModelLeft;

	if selectedSubsID ~= 1 then
		self:SetRotation(0.40);
		self:SetCreature(9000295);
	elseif C_Service:IsStrengthenStatsRealm() then
		self:SetRotation(0.40);
		self:SetCreature(50001);
	end
end

function StoreConfigurateSubscribeData( ID, name, cost, description, icon )
	local SubscribeData = {
		Texture = icon or "Interface\\ICONS\\inv_misc_crystalepic",
		Name = name,
		Price = cost,
		isSubscribe = true,
		ID = STORE_SUBSCRIBE_DATA[selectedSubsID].ID,
		Time = ID,
		DescriptionText = description
	}
	
	return SubscribeData
end

function StoreSliderSetup( time )
	if StoreSpecialOfferFrame.SliderTicker then
		StoreSpecialOfferFrame.SliderTicker:Cancel()
		StoreSpecialOfferFrame.SliderTicker = nil
	end

	StoreSpecialOfferFrame.SliderTicker = C_Timer:NewTicker(time, function()
		local offerCount = StoreGetSpecialOfferCount()

		if offerCount ~= 0 and StoreSpecialOfferFrame:IsVisible() then
			selectedSpecialOfferPage = selectedSpecialOfferPage + 1
			if selectedSpecialOfferPage > offerCount then
				selectedSpecialOfferPage = 1
			end
			StoreFrame_SpecialOfferSetup()
		else
			if StoreSpecialOfferFrame.SliderTicker then
				StoreSpecialOfferFrame.SliderTicker:Cancel()
				StoreSpecialOfferFrame.SliderTicker = nil
			end
		end
	end, nil)
end

function StoreFrame_SpecialOfferSetup()
	local self = StoreSpecialOfferBanner

	local offerCount = StoreGetSpecialOfferCount()
	local offerData = StoreGetSpecialOfferByIndex(selectedSpecialOfferPage)

	self.NavigationBar.PrevPageButton:SetEnabled(selectedSpecialOfferPage > 1)
	self.NavigationBar.NextPageButton:SetEnabled(selectedSpecialOfferPage ~= offerCount)

	if offerData and offerCount > 0 then
		self.data = offerData

		local leftPanel
		local offer3DName = STORE_SPECIAL_OFFERS_3D[offerData.offerID] and STORE_SPECIAL_OFFERS_3D[offerData.offerID].Name or ""

		if offer3DName ~= "" then
			leftPanel = self[offer3DName .. "Offer"].LeftPanel
		else
			leftPanel = self.LeftPanel
		end

		self.LeftPanel.BuyButton.Glow:SetShown(offerData.IsNew)
		self.Overlay.GlowBorder:SetShown(offerData.IsNew)
		self.NavigationBar.PageText:SetFormattedText(STORE_PAGE_NUMBER, selectedSpecialOfferPage, offerCount)

		if STORE_SMALL_SPECIAL_OFFER_BUFFER and STORE_SMALL_SPECIAL_OFFER_BUFFER[offerData.offerID] then
			STORE_SMALL_SPECIAL_OFFER_BUFFER[offerData.offerID] = nil
		end

		self.Background:SetTexture("Interface\\Store\\SpecialOfferBanner\\"..offerData.Background)
		self.Background:SetTexCoord(0, 0.5634765625, 0.02734375, 1)

		leftPanel.TitleText:SetText(offerData.MainTitle)
		leftPanel.NameText:SetText(offerData.Title)
		leftPanel.DescriptionText:SetText(offerData.Description)

		if offerData.Price == 0 then
			self.LeftPanel.BuyButton:SetText(STORE_SPECIAL_OFFER_FREE_LABEL)
		else
			self.LeftPanel.BuyButton:SetText(STORE_SPECIAL_OFFER_MORE_LABEL)
		end

		if offerData.FreeSubscribe then
			self.LeftPanel.BuyButton:SetText(STORE_SPECIAL_OFFER_MORE_LABEL)
		end

		leftPanel.TimerText:SetShown(offerData.EndTime)
		self.LeftPanel.TimerLabel:SetShown(offerData.EndTime)

		if offerData.EndTime then
			local remainingTime = offerData.EndTime - time()
			leftPanel.TimerText:SetRemainingTime(remainingTime)

			if remainingTime and remainingTime <= 3600 then
				self.LeftPanel.TimerText:SetTextColor(1, 0, 0)
			else
				self.LeftPanel.TimerText:SetTextColor(1, 1, 1)
			end

			if self.LeftPanel.TimerText.Ticker then
				self.LeftPanel.TimerText.Ticker:Cancel()
				self.LeftPanel.TimerText.Ticker = nil
			end

			self.LeftPanel.TimerText.Ticker = C_Timer:NewTicker(1, function()
				local offerCount = StoreGetSpecialOfferCount()
				local offerData = StoreGetSpecialOfferByIndex(selectedSpecialOfferPage)

				if self:IsVisible() and offerData and offerData.EndTime then
					local currentOfferRemainingTime = offerData.EndTime - time()
					leftPanel.TimerText:SetRemainingTime(currentOfferRemainingTime)

					if currentOfferRemainingTime and currentOfferRemainingTime <= 3600 then
						self.LeftPanel.TimerText:SetTextColor(1, 0, 0)
					else
						self.LeftPanel.TimerText:SetTextColor(1, 1, 1)
					end

					for i = 1, offerCount do
						local offerData = StoreGetSpecialOfferByIndex(i)
						if offerData and offerData.EndTime then
							local remainingTime = offerData.EndTime - time()

							if remainingTime <= 0 then
								StoreRemoveOffer(i)
								selectedSpecialOfferPage = 1

								StoreSpecialOfferSortUpdate()
								StoreSpecialOfferInfoUpdate()
								StoreFrame_SpecialOfferSetup()
							end
						end
					end
				else
					self.LeftPanel.TimerText:Hide()
					self.LeftPanel.TimerLabel:Hide()

					self.LeftPanel.TimerText.Ticker:Cancel()
					self.LeftPanel.TimerText.Ticker = nil
				end
			end)
		end
	else
		self.Background:SetTexture("Interface\\Store\\SpecialOfferBanner\\m0")
		self.Background:SetTexCoord(0, 0.5634765625, 0.02734375, 1)

		self.LeftPanel.TimerText:Hide()
		self.Overlay.GlowBorder:Hide()
	end

	self.NavigationBar.PrevPageButton:SetShown(offerCount > 0)
	self.NavigationBar.NextPageButton:SetShown(offerCount > 0)
	self.NavigationBar.PageText:SetShown(offerCount > 0)
	self.LeftPanel:SetShown(offerCount > 0)

	StoreSpecialOfferSetupTemplate(self)
end

function StoreSpecialOfferSetupTemplate( self )
	local offerCount = StoreGetSpecialOfferCount()

	if self.data and offerCount > 0 then
		local data = self.data

		if data.offerID then
			local offer3DName = STORE_SPECIAL_OFFERS_3D[data.offerID] and STORE_SPECIAL_OFFERS_3D[data.offerID].Name or ""
			for k, v in pairs(STORE_SPECIAL_OFFERS_3D) do
				if k ~= data.offerID and self[v.Name .. "Offer"]:IsShown() then
					self[v.Name .. "Offer"]:SetShown(false)
				end
			end

			if offer3DName ~= "" and not self[offer3DName .. "Offer"]:IsShown() then
				self[offer3DName .. "Offer"]:SetShown(true);
				StoreSpecialOfferCustomUpdateState(_G["StoreSpecialOfferBanner" .. offer3DName .. "Offer"])
			end

			if offer3DName ~= "" then
				data.Flags = STORE_ITEM_FLAG_ITEM_GIFT
			end
		end
	end
end

function StoreSpecialOfferCustomUpdateState( self )
	local isShown = self:IsShown()

	if isShown then
		self:GetParent().NavigationBar.PageText:ClearAllPoints()
		self:GetParent().NavigationBar.PrevPageButton:ClearAllPoints()

		self:GetParent().NavigationBar.PageText:SetPoint("TOPRIGHT", -74, -17)
		self:GetParent().NavigationBar.PrevPageButton:SetPoint("TOPRIGHT", -40, -7)

		local color = STORE_SPECIAL_OFFERS_3D[self:GetParent().data.offerID] and STORE_SPECIAL_OFFERS_3D[self:GetParent().data.offerID].VertexColor or nil
		self:GetParent().Border:SetVertexColor(color[1], color[2], color[3])

		self:GetParent().Background:SetTexCoord(0, 0.564453125, 0.015625, 1)

		if self:GetParent().data then
			self.LeftPanel.Price:SetText(self:GetParent().data.Price or 0)
		end
	else
		local offerCount = StoreGetSpecialOfferCount()

		if offerCount > 0 then
			self:GetParent().NavigationBar.PageText:ClearAllPoints()
			self:GetParent().NavigationBar.PrevPageButton:ClearAllPoints()

			self:GetParent().NavigationBar.PageText:SetPoint("BOTTOMRIGHT", -74, 17)
			self:GetParent().NavigationBar.PrevPageButton:SetPoint("BOTTOMRIGHT", -40, 7)

			self:GetParent().Background:SetTexCoord(0, 0.5634765625, 0.02734375, 1)
			self:GetParent().Border:SetVertexColor(1, 1, 1)
		end
	end

	self:GetParent().LeftPanel:SetShown(not isShown)
end

function StoreLoyalProgressBarSetValue( minv, maxv )
	local MAX_BAR = StoreLoyalProgressBar:GetWidth() - 4
	local progresss = min(MAX_BAR * minv / maxv, MAX_BAR)
	StoreLoyalProgressBar.progress:SetWidth(progresss + 1)
end

function StoreCloseAllFrame()
	for _, frame in pairs(STORE_FRAME_DATA) do
		local Frame = _G[frame]
		if Frame and not Frame.dontHide then
			Frame:Hide()
		end
	end
end

function StoreShowPurchaseAlert( name, texture )
	StorePurchaseAlertFrame:Show()

	StorePurchaseAlertFrame.Icon:SetTexture(texture)
	StorePurchaseAlertFrame.Title:SetText(name)
end

function StoreShowErrorFrame( title, text, parent, dontHide )
	if not parent then
		StoreErrorFrame:SetParent("StoreFrame")
	else
		StoreErrorFrame:SetParent(parent)
	end

	StoreErrorFrame:Show()
	StoreErrorFrame.dontHide = dontHide
	StoreErrorFrame.Title:SetText(title)
	StoreErrorFrame.Description:SetText(text)
	StoreErrorFrame.CloseButton:Hide()
end

function StoreConfirmationFrame_Update(self)
	local giftChecked = StoreConfirmationSendGiftCheckButton:IsShown() and StoreConfirmationSendGiftCheckButton:GetChecked();
	local hasAltCurrency = not giftChecked and self.data.AltCurrency and self.data.AltCurrency ~= 0;
	self.hasAltCurrency = hasAltCurrency;

	self.NoticeFrame.TotalLabel:SetShown(not hasAltCurrency);
	self.NoticeFrame.AltCurrencyLabel:SetShown(hasAltCurrency);

	self.NoticeFrame.MoneyIcon:SetShown(not hasAltCurrency);
	self.NoticeFrame.Price:SetShown(not hasAltCurrency);
	self.NoticeFrame.MoneySelectFrame:SetShown(hasAltCurrency);
	self.NoticeFrame.AltCurrencySelectFrame:SetShown(hasAltCurrency);

	local moneyIcon = "Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[selectedMoneyID];
	local price = self.data.DiscountedPrice and self.data.DiscountedPrice or self.data.Price;
	self.NoticeFrame.Price:SetText(price);
	self.NoticeFrame.MoneyIcon:SetTexture(moneyIcon);

	if hasAltCurrency then
		local moneyData = STORE_MONEY_BUTTON_DATA[selectedMoneyID or 1];
		self.NoticeFrame.MoneySelectFrame.SelectButton.Text:SetText(moneyData.Name);
		self.NoticeFrame.MoneySelectFrame.MoneyFrame.Icon:SetTexture(moneyIcon);
		self.NoticeFrame.MoneySelectFrame.MoneyFrame.Price:SetText(price);

		self.NoticeFrame.AltCurrencySelectFrame.SelectButton.Text:SetText(self.data.AltCurrencyName);
		self.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Icon:SetTexture(self.data.AltCurrencyIcon);
		self.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Price:SetText(self.data.AltPrice);
	end

	self.AlphaLayer:SetPoint("BOTTOMRIGHT", self.ParchmentMiddle, 0, hasAltCurrency and 82 or 62);
	self.Line2:SetPoint("BOTTOM", self.ParchmentMiddle, "BOTTOM", 0, hasAltCurrency and 80 or 60);

	if giftChecked then
		self.isAltCurrency = false;
	end

	if self.isAltCurrency then
		self.NoticeFrame.MoneySelectFrame.SelectButton:SetChecked(nil);
		self.NoticeFrame.AltCurrencySelectFrame.SelectButton:SetChecked(1);

		self.NoticeFrame.MoneySelectFrame.MoneyFrame.Icon:SetSize(20, 20);
		self.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Icon:SetSize(26, 26);
		self.NoticeFrame.MoneySelectFrame.MoneyFrame.Price:SetFontObject(GameFontNormalShadowHuge12);
		self.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Price:SetFontObject(GameFontNormalShadowHuge17);
	else
		self.NoticeFrame.MoneySelectFrame.SelectButton:SetChecked(1);
		self.NoticeFrame.AltCurrencySelectFrame.SelectButton:SetChecked(nil);

		self.NoticeFrame.MoneySelectFrame.MoneyFrame.Icon:SetSize(30, 30);
		self.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Icon:SetSize(17, 17);
		self.NoticeFrame.MoneySelectFrame.MoneyFrame.Price:SetFontObject(GameFontNormalShadowHuge17);
		self.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Price:SetFontObject(GameFontNormalShadowHuge12);
	end

	StoreConfirmationSendGiftCheckButton:SetEnabled(not self.isAltCurrency);
end

function StoreConfirmationFrame_UpdateSize(self)
	local giftChecked = StoreConfirmationSendGiftCheckButton:IsShown() and StoreConfirmationSendGiftCheckButton:GetChecked();

	local width, height = 403, 396;
	local noticeWidth, noticeHeight = 396, 208;

	if not self.data.SelectedSpec and self.data.selfSize then
		width, height = self.data.selfSize[1], self.data.selfSize[2];

		if self.data.noticeSize then
			noticeWidth, noticeHeight = self.data.noticeSize[1], self.data.noticeSize[2];
		end
	end

	if self.data.SelectedSpec then
		height = height + 60;
		noticeHeight = noticeHeight + 60;
	else
		if giftChecked then
			height = height + 180;
			noticeHeight = noticeHeight + 180;
		end
		if self.hasAltCurrency then
			height = height + 20;
			noticeHeight = noticeHeight + 20;
		end
	end

	self:SetSize(width, height);
	self.NoticeFrame:SetSize(noticeWidth, noticeHeight);
end


function StoreConfirmationFrame_UpdateState( self )
	if self:GetChecked() then
		StoreConfirmationGiftFrame:Show()
	else
		StoreConfirmationGiftFrame:Hide()
		StoreConfirmationFrame.MailBackgroundRight:Hide()
		StoreConfirmationFrame.MailBackgroundLeft:Hide()
	end
end

function StoreFrame_ProductBuy( data, backData )
	StoreConfirmationFrame.data = data
	StoreConfirmationFrame.backData = backData
	StoreConfirmationFrame:Show()
end

function StoreFrame_ProductBuyWithOpenPage( data )
	ShowUIPanel(StoreFrame)
	if data.currency and data.currency ~= 0 then
		_G["StoreMoneyButton"..data.currency]:Click()
	end
	StoreFrame_ProductBuy(data)
end

function StoreFrame_UpdateItemCard()
	local numButtons
	local buttonName

	if StoreItemCardFrame:IsShown() then
		buttonName = "StoreItemCardButton"
		numButtons = 8
	else
		buttonName = "StoreSpecialOfferCardButton"
		numButtons = 4
	end

	StoreItemCardFrameNavigationBarPrevPageButton:SetEnabled(selectedItemCardPage ~= 1)

	for i = 1, numButtons do
		local button = _G[string.format("%s%d", buttonName, i)]
		local data = STORE_PRODUCT_LIST[i + numButtons * (selectedItemCardPage - 1)]
		if data then
			button.data = data
			if data.Count then
				button.Count:SetText("x"..data.Count)
			end
			button.Name:SetText(data.Name)
			button.MoneyIcon:SetTexture("Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[selectedMoneyID])

			local hasAltCurrency = data.AltCurrency and data.AltCurrency ~= 0;
			button.AltCurrencyIcon:SetShown(hasAltCurrency);
			if hasAltCurrency then
				button.AltCurrencyIcon:SetTexture(data.AltCurrencyIcon);
			end

			button.Count:SetShown(data.Count)

			if data.DiscountedPrice and data.Discount then
				button.NormalPrice:Hide()
				button.SalePrice:Show()
				button.Strikethrough:Show()
				button.CurrentPrice:Show()

				button.CurrentPrice:SetText(data.Price)
				button.SalePrice:SetText(data.DiscountedPrice)
			else
				button.NormalPrice:Show()
				button.SalePrice:Hide()
				button.Strikethrough:Hide()
				button.CurrentPrice:Hide()

				button.NormalPrice:SetText(data.Price)
			end

			if data.Discount then
				button.Discount:Show()
				button.DiscountText:Show()
				button.DiscountText:SetFormattedText("-%s%%", data.Discount)
			else
				button.Discount:Hide()
				button.DiscountText:Hide()
			end

			if data.CreatureEntry then
				button.IconBorder:Hide()
				button.Icon:Hide()
				button.Model:Show()

				button.Model:SetCreature(data.CreatureEntry)
			else
				button.Model:Hide()
				button.IconBorder:Show()
				button.Icon:Show()

				SetPortraitToTexture(button.Icon, data.Texture)
			end
			button:Show()
		else
			button:Hide()
		end
		local numPages = math.ceil(#STORE_PRODUCT_LIST / numButtons)
		StoreItemCardFrameNavigationBarNextPageButton:SetEnabled(selectedItemCardPage ~= numPages)
	end
end

function StoreFrame_UpdateItemList()
	local scrollFrame = StoreItemListScrollFrame
	scrollFrame.ScrollBar.doNotHide = true
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local numProduct = #STORE_PRODUCT_LIST
	local displayedHeight = 0
	local currentLoyal = StoreMoneyButton4.data[4]

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i
		if STORE_PRODUCT_LIST[index] then
			local data = STORE_PRODUCT_LIST[index]
			button.data = data

			button.MoneyIcon:SetTexture("Interface\\Store\\"..STORE_PRODUCT_MONEY_ICON[selectedMoneyID])

			local hasAltCurrency = data.AltCurrency and data.AltCurrency ~= 0;
			button.AltCurrencyIcon:SetShown(hasAltCurrency);

			button.CurrentPrice:ClearAllPoints();
			button.NormalPrice:ClearAllPoints();
			if hasAltCurrency then
				button.AltCurrencyIcon:SetTexture(data.AltCurrencyIcon);

				button.CurrentPrice:SetPoint("LEFT", button.AltCurrencyIcon, "RIGHT", 3, 0);
				button.NormalPrice:SetPoint("LEFT", button.AltCurrencyIcon, "RIGHT", 5, 6);
			else
				button.CurrentPrice:SetPoint("LEFT", button.MoneyIcon, "RIGHT", 0, 0);
				button.NormalPrice:SetPoint("LEFT", button.MoneyIcon, "RIGHT", 2, 6);
			end

			button.Name:SetText(data.Name)
			button.iLevel:SetText(data.Ilevel)

			button.iLevel:SetShown((selectedMoneyID ~= 4 and selectedMoneyID ~= 3) and (data.Ilevel and data.Ilevel > 1))

			if data.Quality then
				local r, g, b = GetItemQualityColor(data.Quality)
				button.Name:SetTextColor(r, g, b)
				button.Name.originalColor = {r, g, b}
			end

			SetPortraitToTexture(button.Icon, data.Texture)

			button.Count:SetShown(data.Count)
			button.Count:SetText(data.Count)
			button.PVPIcon:SetShown(bit.band(data.Flags, STORE_ITEM_FLAG_PVP) == STORE_ITEM_FLAG_PVP)

			button.DiscountText:Hide()
			button.New:Hide()
			button.Hot:Hide()
			button.Discount:Hide()

			button.DiscountTimerText:SetShown(data.RemainingTime)

			for i = 1, #STORE_ITEM_FLAG_DATA do
				local flagData = STORE_ITEM_FLAG_DATA[i]
				if bit.band(data.Flags, flagData.flag) == flagData.flag then
					button.DiscountText:SetText(flagData.text)

					button.DiscountText:SetShown(flagData.text)
					button.New:SetShown(flagData.isNew)
					button.Hot:SetShown(flagData.isHot)
					button.Discount:SetShown(flagData.isDiscount)

					STORE_PRODUCT_LIST[index].DiscountShow = true
				end
			end

			if data.DiscountedPrice and data.Discount then
				button.NormalPrice:Show()
				button.SalePrice:Show()
				button.Strikethrough:Show()
				button.CurrentPrice:Hide()

				button.NormalPrice:SetText(data.Price)
				button.SalePrice:SetText(data.DiscountedPrice)
			else
				button.NormalPrice:Hide()
				button.SalePrice:Hide()
				button.Strikethrough:Hide()
				button.CurrentPrice:Show()

				button.CurrentPrice:SetText(data.Price)
			end

			if data.Discount and (selectedMoneyID ~= 4 and selectedMoneyID ~= 3) then
				button.Discount:Show()
				button.DiscountText:Show()
				button.DiscountText:SetFormattedText(STORE_ITEM_DISCOUNT_LABEL, data.Discount)

				STORE_PRODUCT_LIST[index].DiscountShow = true
			end

			if data.RemainingTime and not buttons[i].Ticker then
				buttons[i].DiscountTimerText:SetRemainingTime(buttons[i].data.RemainingTime)
				buttons[i].Ticker = C_Timer:NewTicker(1, function()
					if buttons[i]:IsVisible() then
						buttons[i].DiscountTimerText:SetRemainingTime(buttons[i].data.RemainingTime)
					else
						buttons[i].Ticker:Cancel()
						buttons[i].Ticker = nil
					end
				end, data.RemainingTime + 1)
			end

			if selectedMoneyID and selectedMoneyID == 4 and currentLoyal then
				button:SetAlpha(data.Price <= currentLoyal and 1 or 0.5)
			else
				button:SetAlpha(1)
			end

			displayedHeight = displayedHeight + button:GetHeight()
			button:Show()
		else
			if buttons[i].Ticker then
				buttons[i].Ticker:Cancel()
				buttons[i].Ticker = nil
			end
			button:Hide()
		end
	end

	local totalHeight = numProduct * buttons[1]:GetHeight() + (numProduct - 1) * 5 + 4
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())

	if ( StoreItemListScrollFrame.activeButton ) then
		StoreItemListButton_OnEnter(StoreItemListScrollFrame.activeButton)
	end
end

local function sortItemList(a, b)
	if StoreItemListFrame.activeSortId == 5 then
		if a.Price ~= b.Price then
			if StoreItemListFrame.reverseSort then
				return a.Price > b.Price;
			else
				return a.Price < b.Price;
			end
		end
	elseif StoreItemListFrame.activeSortId == 4 then
		if a.IsPVP ~= b.IsPVP then
			if StoreItemListFrame.reverseSort then
				return b.IsPVP and not a.IsPVP;
			else
				return a.IsPVP and not b.IsPVP;
			end
		end
	elseif StoreItemListFrame.activeSortId == 3 then
		if a.Ilevel ~= b.Ilevel then
			if StoreItemListFrame.reverseSort then
				return a.Ilevel > b.Ilevel;
			else
				return a.Ilevel < b.Ilevel;
			end
		end
	elseif StoreItemListFrame.activeSortId == 2 then
		if a.DiscountShow ~= b.DiscountShow then
			if StoreItemListFrame.reverseSort then
				return b.DiscountShow and not a.DiscountShow;
			else
				return a.DiscountShow and not b.DiscountShow;
			end
		end
	elseif StoreItemListFrame.activeSortId == 1 then
		if a.Name ~= b.Name then
			if StoreItemListFrame.reverseSort then
				return a.Name > b.Name;
			else
				return a.Name < b.Name;
			end
		end
	end

	if a.Quality ~= b.Quality then
		return a.Quality > b.Quality;
	elseif a.Name ~= b.Name then
		return a.Name < b.Name;
	elseif a.Price ~= b.Price then
		return a.Price > b.Price;
	else
		return (a.Count or 1) > (b.Count or 1);
	end
end

function StoreDataTableCopy(useFilter)
	local hasUseFilters = StoreItemListFrame.isPvP or StoreItemListFrame.isDiscount or StoreItemListFrame.iLvl;

	if useFilter and hasUseFilters then
		STORE_PRODUCT_LIST = {};

		for i = 1, #STORE_PRODUCT_DATA do
			local product = STORE_PRODUCT_DATA[i];

			if (StoreItemListFrame.isPvP and product.IsPVP) or (StoreItemListFrame.isDiscount and product.DiscountShow) or (StoreItemListFrame.iLvl and StoreItemListFrame.iLvl == product.Ilevel) then
				STORE_PRODUCT_LIST[#STORE_PRODUCT_LIST + 1] = product;
			end
		end
	else
		STORE_PRODUCT_LIST = STORE_PRODUCT_DATA
	end

	table.sort(STORE_PRODUCT_LIST, sortItemList);

	StoreFrame_UpdateItemList()
	StoreFrame_UpdateItemCard()

	StoreItemListScrollFrame.ScrollBar:SetValue(0)

	if selectedMoneyID == 4 then
		local currentLoyal 	= StoreMoneyButton4.data[4]
		local numProduct 	= #STORE_PRODUCT_LIST

		if currentLoyal and numProduct > 0 then
			local elapsed = 0

			StoreItemListScrollFrame:SetScript("OnUpdate", function( _, diff )
				local scrollIndex = C_inOutSine(elapsed, 4, numProduct - currentLoyal, 1)
				elapsed = elapsed + diff

				MountJournal_UpdateScrollPos(StoreItemListScrollFrame, scrollIndex)

				if elapsed >= 1 then
					elapsed = 0
					MountJournal_UpdateScrollPos(StoreItemListScrollFrame, numProduct - currentLoyal)

					StoreItemListScrollFrame:SetScript("OnUpdate", nil)
				end
			end)
		end
	end
end

function StoreRequestBattlePass()
	selectedMoneyID = 1
	selectedCategoryID = 1

	StoreRequestShopItems(1, 101, 1)
	StoreRequestShopItems(1, 101, 2)
end

function StoreItemListUpdate()
	if (STORE_CATEGORIES_DATA[selectedMoneyID][selectedCategoryID] and STORE_CATEGORIES_DATA[selectedMoneyID][selectedCategoryID].dontItemRequest) then
		if not selectedSubCategoryID or selectedSubCategoryID == 0 then
			return true
		end
	end

	STORE_PRODUCT_DATA 	= {}
	STORE_PRODUCT_LIST 	= {}

	local storage = STORE_PRODUCT_CACHE[selectedMoneyID][selectedCategoryID][selectedSubCategoryID][selectedShowAllItemCheckBox]

	local function clearStorage()
		STORE_PRODUCT_CACHE[selectedMoneyID][selectedCategoryID][selectedSubCategoryID][selectedShowAllItemCheckBox] = {}
	end

	if storage and storage.version then
		if GetStoreProductVersion() == storage.version then
			local unitFaction = UnitFactionGroup("player") or "Alliance"
			if not storage.unitFaction or storage.unitFaction ~= unitFaction then
				clearStorage()
				STORE_PRODUCT_CACHE[selectedMoneyID][selectedCategoryID][selectedSubCategoryID][selectedShowAllItemCheckBox].unitFaction = unitFaction
				STORE_PRODUCT_CACHE[selectedMoneyID][selectedCategoryID][selectedSubCategoryID][selectedShowAllItemCheckBox].rolledItemsVersion = GetStoreRolledItemsVersion(selectedCategoryID)

				StoreRequestShopItems( selectedMoneyID, selectedCategoryID, selectedSubCategoryID, selectedShowAllItemCheckBox )
			else
				if ((selectedCategoryID == 3 and (selectedSubCategoryID == 1 or selectedSubCategoryID == 2)) or selectedCategoryID == STORE_TRANSMOGRIFY_CATEGORY_ID) and (not storage.rolledItemsVersion or storage.rolledItemsVersion ~= GetStoreRolledItemsVersion(selectedCategoryID)) then
					clearStorage()
					STORE_PRODUCT_CACHE[selectedMoneyID][selectedCategoryID][selectedSubCategoryID][selectedShowAllItemCheckBox].rolledItemsVersion = GetStoreRolledItemsVersion(selectedCategoryID)

					StoreRequestShopItems( selectedMoneyID, selectedCategoryID, selectedSubCategoryID, selectedShowAllItemCheckBox )
				else
					if storage.data then
						for storeID, data in pairs(storage.data) do
							local altCurrency = data[STORE_STORAGE_DATA_ALT_CURRENCY];

							local altCurrencyName, altCurrencyIcon = "", "";
							if altCurrency and altCurrency ~= 0 then
								altCurrencyName, _, _, _, _, _, _, _, _, altCurrencyIcon = GetItemInfo(data[STORE_STORAGE_DATA_ALT_CURRENCY])
							end

							if selectedMoneyID == 1 and selectedCategoryID == STORE_TRANSMOGRIFY_CATEGORY_ID then
								STORE_TRANSMOGRIFY_SERVER_DATA[storeID] = {
									storeID,
									data[STORE_STORAGE_DATA_ENTRY],
									data[STORE_STORAGE_DATA_COUNT],
									data[STORE_STORAGE_DATA_PRICE],
									data[STORE_STORAGE_DATA_DISCOUNT],
									data[STORE_STORAGE_DATA_DISCOUNTEDPRICE],
									data[STORE_STORAGE_DATA_FLAGS],
									data[STORE_STORAGE_DATA_ISPVP],
									altCurrency,
									data[STORE_STORAGE_DATA_ALT_PRICE],
									altCurrencyName,
									altCurrencyIcon,
								}
							else
								local name, link, quality, ilevel, _, _, _, _, _, texture = GetItemInfo(data[STORE_STORAGE_DATA_ENTRY])

								table.insert(STORE_PRODUCT_DATA, {
									ID 				= data[STORE_STORAGE_DATA_ID],
									Entry 			= data[STORE_STORAGE_DATA_ENTRY],
									Count 			= data[STORE_STORAGE_DATA_COUNT],
									Price 			= data[STORE_STORAGE_DATA_PRICE],
									RemainingTime 	= data[STORE_STORAGE_DATA_REMAININGTIME],
									Discount 		= data[STORE_STORAGE_DATA_DISCOUNT],
									DiscountedPrice = data[STORE_STORAGE_DATA_DISCOUNTEDPRICE],
									CreatureEntry 	= data[STORE_STORAGE_DATA_CREATUREENTRY],
									Flags 			= data[STORE_STORAGE_DATA_FLAGS],
									AltCurrency		= altCurrency,
									AltPrice		= data[STORE_STORAGE_DATA_ALT_PRICE],
									AltCurrencyName	= altCurrencyName,
									AltCurrencyIcon	= altCurrencyIcon,
									Name 			= name,
									Link 			= link,
									Quality 		= quality or 1,
									Ilevel 			= ilevel,
									Texture 		= texture,
									IsPVP 			= data[STORE_STORAGE_DATA_ISPVP],
									DiscountShow	= data[STORE_STORAGE_DATA_DISCOUNTSHOW],
								})
							end
						end

						if selectedMoneyID == 1 and selectedCategoryID == STORE_TRANSMOGRIFY_CATEGORY_ID then
							StoreTransmogrifyFrame_UpdateRightContainer()
							StoreTransmogrifyGenerateData(true)
						else
							StoreDataTableCopy()
						end

						return true
					end
				end
			end
		else
			clearStorage()
			StoreRequestShopItems( selectedMoneyID, selectedCategoryID, selectedSubCategoryID, selectedShowAllItemCheckBox )
		end
	else
		StoreRequestShopItems( selectedMoneyID, selectedCategoryID, selectedSubCategoryID, selectedShowAllItemCheckBox )
	end

	return false
end

function StoreFrame_UpdateCategories( self )
	local categories = STORE_CATEGORIES_DATA[selectedMoneyID]

	StoreFrameLeftInset.BrowseNotice:Hide()

	for _, button in pairs(StoreFrame.SubCategoryFrames) do
		button:Hide()
	end
	for i, button in pairs(StoreFrame.CategoryFrames) do
		if i ~= 1 then
			button:SetPoint("TOPLEFT", StoreFrame.CategoryFrames[i-1], "BOTTOMLEFT", 0, 0)
		end
	end

	local prevFrame
	if categories and #categories > 0 then
		for i = 1, #categories do
			local frame = self.CategoryFrames[i]
			local data = categories[i]

			if ( not frame ) then
				frame = CreateFrame("Button", "StoreCategoryButton"..i, StoreFrameLeftInset, "StoreCategoryTemplate")
				if i == 1 then
					frame:SetPoint("TOP", 0, -20)
				else
					frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
				end

				self.CategoryFrames[i] = frame
			end

			frame:SetID(i)
			frame.Icon:SetTexture("Interface\\Store\\"..data.Icon)
			frame.Text:SetText(data.Name)
			frame.SelectedTexture:Hide()

			self.CategoryFrames[i].data = data

			if i == 1 then
				local ChieldFrame = _G[data.ChieldFrame]
				selectedCategoryID = 1
				frame.SelectedTexture:Show()
				StoreItemListUpdate()

				if ChieldFrame then
					ChieldFrame:Show()
				end
			end

			local isNew = StoreFrame_CategoryIsNew(selectedMoneyID, i)

			frame.NewItems:SetShown(isNew)

			if data.Color then
				frame.ColoredTexture:SetVertexColor(data.Color.r, data.Color.g, data.Color.b)
			end

			if data.Disable or ( data.Level and data.Level > UnitLevel("player") ) then
				frame:Disable()
				frame.Icon:SetDesaturated(1)
				frame.Category:SetDesaturated(1)
				frame.NewItems:SetDesaturated(1)
				frame.Text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
				frame.isEnable = false
			else
				frame.ColoredTexture:SetShown(data.Color)
				frame:Enable()
				frame.Icon:SetDesaturated(0)
				frame.Category:SetDesaturated(0)
				frame.NewItems:SetDesaturated(0)
				frame.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
				frame.isEnable = true

				if data.Level and not tContains(STORE_HIGHLIGHT_CATEGORY_BUTTON[UnitName("player")], frame:GetName()) then
					frame.PulseTexture:Show()
					frame.isHighlight = true
				end

				if STORE_CACHE:Get("flashCategoryMountRenew") == true and i == 3 then
					frame.PulseTexture:Show()
					frame.isHighlight = true
				end
			end
			prevFrame = frame
			frame:Show()
		end
	else
		selectedCategoryID = 0
		StoreFrameLeftInset.BrowseNotice:Show()
		StoreFrameLeftInset.BrowseNotice:SetText(categories.text)
	end

	StoreFrameLeftInset.ReferAFriendFrame:SetShown(selectedMoneyID == 3)
	StoreFrameLeftInset.InviteFriendButton:SetShown(selectedMoneyID == 3)
	StoreFrameLeftInset.ReferDetailsButton:SetShown(selectedMoneyID == 3)

	for i = #categories + 1, #self.CategoryFrames do
		self.CategoryFrames[i]:Hide()
	end

	for i = 1, #STORE_MONEY_BUTTON_DATA do
		local button = _G["StoreMoneyButton"..i]
		button.Selected:Hide()
	end
	_G["StoreMoneyButton"..selectedMoneyID].Selected:Show()

	StoreShowAllItemCheckButton:ClearAllPoints()
	StoreShowAllItemCheckButton:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -4)
end

function StoreSortButton_OnClick( self, button, ... )
	local id = self:GetID();

	if button == "LeftButton" then
		if id == 0 then
			StoreItemListFrame_ResetFilters();
			StoreDataTableCopy();
		else
			StoreItemListFrame.reverseSort = id ~= StoreItemListFrame.activeSortId and false or not StoreItemListFrame.reverseSort;
			StoreItemListFrame.activeSortId = id;

			table.sort(STORE_PRODUCT_LIST, sortItemList);
		end

		StoreFrame_UpdateItemList();
	elseif button == "RightButton" then
		if id == 1 then
			StoreItemListFrame_SetShownSearchBox(true);
		elseif id == 2 then
			StoreItemListFrame.isDiscount = not StoreItemListFrame.isDiscount;

			StoreDataTableCopy(true);
		elseif id == 3 then
			local numericBox = self.NumericBox;
			if numericBox and not numericBox:IsShown() then
				numericBox:Show();
				numericBox:SetText("");
			end
		elseif id == 4 then
			StoreItemListFrame.isPvP = not StoreItemListFrame.isPvP;

			StoreDataTableCopy(true);
		end
	end
end

function StoreSortButton_OnEnter(self)
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(self.tooltipText, 0, 1, 0);
		GameTooltip:Show();
	end
end


local searchStats = {}

local searchBoxFilters = {
	{
		name = STORE_SEARCH_OPTION_ARMOR,
		desc = STORE_SEARCH_OPTION_ARMOR_DESC,
		filters = {
			"ITEM_SUB_CLASS_4_1",
			"ITEM_SUB_CLASS_4_2",
			"ITEM_SUB_CLASS_4_3",
			"ITEM_SUB_CLASS_4_4",
		},
		func = function(option, filter, itemID, itemLink, itemName)
			if itemID then
				local _, _, _, _, _, _, itemSubType = GetItemInfo(itemID);
				local nameName = _G[filter];

				if nameName and itemSubType and itemSubType == nameName then
					return true;
				end
			end
		end,
	},
	{
		name = STORE_SEARCH_OPTION_STATISTIC,
		desc = STORE_SEARCH_OPTION_STATISTIC_DESC,
		func = function(option, filter, itemID, itemLink, itemName)
			if itemLink then
				table.wipe(searchStats);

				searchStats = GetItemStats(itemLink, searchStats);

				if searchStats then
					for statName in pairs(searchStats) do
						if statName == filter then
							return true;
						end
					end
				end
			end
		end,
		filters = {
			"EMPTY_SOCKET_BLUE",
			"EMPTY_SOCKET_YELLOW",
			"EMPTY_SOCKET_RED",
			"EMPTY_SOCKET_META",
			"EMPTY_SOCKET_NO_COLOR",
			"ITEM_MOD_AGILITY_SHORT",
			"ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
			"ITEM_MOD_ATTACK_POWER_SHORT",
			"ITEM_MOD_BLOCK_RATING_SHORT",
			"ITEM_MOD_BLOCK_VALUE_SHORT",
			"ITEM_MOD_CRIT_MELEE_RATING_SHORT",
			"ITEM_MOD_CRIT_RANGED_RATING_SHORT",
			"ITEM_MOD_CRIT_RATING_SHORT",
			"ITEM_MOD_CRIT_SPELL_RATING_SHORT",
			"ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT",
			"ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT",
			"ITEM_MOD_CRIT_TAKEN_RATING_SHORT",
			"ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT",
			"ITEM_MOD_DAMAGE_PER_SECOND_SHORT",
			"ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
			"ITEM_MOD_DODGE_RATING_SHORT",
			"ITEM_MOD_EXPERTISE_RATING_SHORT",
			"ITEM_MOD_FERAL_ATTACK_POWER_SHORT",
			"ITEM_MOD_HASTE_MELEE_RATING_SHORT",
			"ITEM_MOD_HASTE_RANGED_RATING_SHORT",
			"ITEM_MOD_HASTE_RATING_SHORT",
			"ITEM_MOD_HASTE_SPELL_RATING_SHORT",
			"ITEM_MOD_HEALTH_REGENERATION_SHORT",
			"ITEM_MOD_HEALTH_REGEN_SHORT",
			"ITEM_MOD_HEALTH_SHORT",
			"ITEM_MOD_HIT_MELEE_RATING_SHORT",
			"ITEM_MOD_HIT_RANGED_RATING_SHORT",
			"ITEM_MOD_HIT_RATING_SHORT",
			"ITEM_MOD_HIT_SPELL_RATING_SHORT",
			"ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT",
			"ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT",
			"ITEM_MOD_HIT_TAKEN_RATING_SHORT",
			"ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT",
			"ITEM_MOD_INTELLECT_SHORT",
			"ITEM_MOD_MANA_REGENERATION_SHORT",
			"ITEM_MOD_MANA_SHORT",
			"ITEM_MOD_MELEE_ATTACK_POWER_SHORT",
			"ITEM_MOD_PARRY_RATING_SHORT",
			"ITEM_MOD_POWER_REGEN0_SHORT",
			"ITEM_MOD_POWER_REGEN1_SHORTEMPTY_SOCKET_BLUE",
			"ITEM_MOD_POWER_REGEN2_SHORTEMPTY_SOCKET_YELLOW",
			"ITEM_MOD_POWER_REGEN3_SHORTEMPTY_SOCKET_RED",
			"ITEM_MOD_POWER_REGEN4_SHORTEMPTY_SOCKET_META",
			"ITEM_MOD_POWER_REGEN5_SHORTEMPTY_SOCKET_NO_COLOR",
			"ITEM_MOD_POWER_REGEN6_SHORT",
			"ITEM_MOD_RANGED_ATTACK_POWER_SHORT",
			"ITEM_MOD_RESILIENCE_RATING_SHORT",
			"ITEM_MOD_SPELL_DAMAGE_DONE_SHORT",
			"ITEM_MOD_SPELL_HEALING_DONE_SHORT",
			"ITEM_MOD_SPELL_PENETRATION_SHORT",
			"ITEM_MOD_SPELL_POWER_SHORT",
			"ITEM_MOD_SPIRIT_SHORT",
			"ITEM_MOD_STAMINA_SHORT",
			"ITEM_MOD_STRENGTH_SHORT",
			"RESISTANCE0_NAME",
			"RESISTANCE1_NAME",
			"RESISTANCE2_NAME",
			"RESISTANCE3_NAME",
			"RESISTANCE4_NAME",
			"RESISTANCE5_NAME",
			"RESISTANCE6_NAME",
		},
	},
	{
		name = STORE_SEARCH_OPTION_NAME,
		desc = STORE_SEARCH_OPTION_NAME_DESC,
		func = function(option, filter, itemID, itemLink, itemName)
			return itemName and itemName ~= "" and string.find(strlower(itemName), filter, 1, true)
		end,
	},
}

local function SortOptionFilters(a, b)
	local aName, bName = _G[a], _G[b];

	if aName and bName then
		return aName < bName;
	end
end

function StoreSortButtonSearchBox_OnLoad(self)
	SearchBoxTemplate_OnLoad(self);

	self.HasStickyFocus = function()
		return DoesAncestryInclude(self.PreviewContainer, GetMouseFocus()) or DoesAncestryInclude(self.SearchOption, GetMouseFocus()) or DoesAncestryInclude(self.FilterFrom, GetMouseFocus());
	end

	self.Filters = {};

	for i = 1, #searchBoxFilters do
		local optionInfo = searchBoxFilters[i];
		local filters = optionInfo.filters;

		if filters then
			table.sort(filters, SortOptionFilters);
		end
	end

	self.Left:SetTexture("Interface\\Store\\Store-Main");
	self.Left:SetSize(31, 31);
	self.Left:SetPoint("LEFT", -15, -1);
	self.Left:SetTexCoord(0.734375, 0.7646484375, 0.4970703125, 0.52734375);
	self.Right:SetTexture("Interface\\Store\\Store-Main");
	self.Right:SetSize(31, 31);
	self.Right:SetPoint("RIGHT", 10, -1);
	self.Right:SetTexCoord(0.8720703125, 0.90234375, 0.4970703125, 0.52734375);
	self.Middle:SetTexture("Interface\\Store\\Store-Main");
	self.Middle:SetHeight(31);
	self.Middle:SetTexCoord(0.7646484375, 0.8720703125, 0.4970703125, 0.52734375);
end

function StoreSortButtonSearchBox_OnShow(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);

	self:SetFocus();
end

function StoreSortButtonSearchBox_OnHide(self)
	self.SearchOption:Hide();
	self.FilterFrom:Hide();
	self.SearchResults:Hide();
end

function StoreSortButtonSearchBox_OnMouseDown(self, button)
	if not self:HasFocus() then
		if button == "RightButton" then
			self.clearFocus = true;
		end
	end
end

function StoreSortButtonSearchBox_OnMouseUp(self, button)
	if button == "RightButton" then
		StoreItemListFrame_SetShownSearchBox(false);
	end
end

function StoreSortButtonSearchBox_OnEnterPressed(self)
	if self.FilterFrom:IsShown() then
		if self.FilterFrom.buttons[1] then
			self.FilterFrom.buttons[1]:Click();
		end
	elseif self.PreviewContainer:IsShown() then
		if strlen(self:GetText()) < MIN_CHARACTER_SEARCH then
			return;
		end

		if self.selectedIndex == 6 then
			if self.PreviewContainer.ShowAllSearchResults:IsShown() then
				self.PreviewContainer.ShowAllSearchResults:Click();
			end
		elseif self.selectedIndex then
			local preview = self.PreviewContainer.SearchPreviews[self.selectedIndex];
			if preview:IsShown() then
				preview:Click();
			end
		end
	end
end

function StoreSortButtonSearchBox_OnEditFocusLost(self)
	SearchBoxTemplate_OnEditFocusLost(self);

	StoreSortButtonSearchBox_HideSearchPreview(self);
	self.SearchOption:Hide();
	self.FilterFrom:Hide();
end

function StoreSortButtonSearchBox_OnEditFocusGained(self)
	if self.clearFocus then
		self:ClearFocus();

		self.clearFocus = nil;
	else
		SearchBoxTemplate_OnEditFocusGained(self);
		self.SearchResults:Hide();
		StoreSortButtonSearchBox_ShowSearchPreviewResults(self);
	end
end

function StoreSortButtonSearchBox_OnTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	if self:HasFocus() then
		StoreSortButtonSearchBox_ShowSearchPreviewResults(self);
	end
end

function StoreSortButtonSearchBox_OnCursorChanged(self, x, y, w, h)

end

local s_qualityToAtlasColorName = {
	[Enum.ItemQuality.Poor] = "gray",
	[Enum.ItemQuality.Common] = "white",
	[Enum.ItemQuality.Uncommon] = "green",
	[Enum.ItemQuality.Rare] = "blue",
	[Enum.ItemQuality.Epic] = "purple",
	[Enum.ItemQuality.Legendary] = "orange",
	[Enum.ItemQuality.Artifact] = "artifact"
};

function StoreSortButtonSearchBox_ShowSearchOptions(self, hideOptionName)
	local lastButton;

	table.wipe(self.SearchOption.buttons);
	self.SearchOption.optionPool:ReleaseAll();

	for i = 1, #searchBoxFilters do
		local optionInfo = searchBoxFilters[i];
		local optionName = optionInfo.name;

		if not hideOptionName or not hideOptionName[optionName] then
			local optionButton = self.SearchOption.optionPool:Acquire();
			optionButton:SetPoint("TOPLEFT", lastButton or self.SearchOption.HeaderBackground, "BOTTOMLEFT");

			optionButton.OptionName:SetText(optionName);
			optionButton.FilterName:SetText(optionInfo.desc);
			optionButton:Show();

			lastButton = optionButton;

			self.SearchOption.buttons[#self.SearchOption.buttons + 1] = optionButton;
		end
	end

	if lastButton then
		self.SearchOption.BorderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -8);
		self.SearchOption:Show();
	else
		self.SearchOption:Hide();
	end
end

function StoreSortButtonSearchBox_ShowSearchFilters(self, filter, filterText)
	if not filter or not filter.filters then
		self.FilterFrom:Hide();
		return;
	end

	local lastButton;

	self.FilterFrom.HeaderText:SetText(filter.desc);

	table.wipe(self.FilterFrom.buttons);
	self.FilterFrom.filterPool:ReleaseAll();

	for i = 1, #filter.filters do
		local name = _G[filter.filters[i]];

		if name then
			local lowerName = strlower(name);

			if name and (not filterText or string.find(lowerName, filterText, 1, true)) then
				local filterButton = self.FilterFrom.filterPool:Acquire();
				filterButton:SetPoint("TOPLEFT", lastButton or self.FilterFrom.HeaderBackground, "BOTTOMLEFT");

				filterButton.FilterName:SetText(lowerName);
				filterButton:Show();

				lastButton = filterButton;

				self.FilterFrom.buttons[#self.FilterFrom.buttons + 1] = filterButton;

				if #self.FilterFrom.buttons == 8 then
					break;
				end
			end
		end
	end

	if lastButton then
		self.FilterFrom.BorderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -8);
		self.FilterFrom:Show();
	else
		self.FilterFrom:Hide();
	end
end

function StoreSortButtonSearchBox_ShowSearchPreviewResults(self)
	table.wipe(self.Filters);
	table.wipe(self.PreviewContainer.Results);

	local usageOptions = {};
	local shouldShowOptions, shouldShowFilters = true, false;

	local filterText;

	local searchBoxText = self:GetText() or "";
	local trimmedText = strtrim(searchBoxText) == "";

	if trimmedText then
		usageOptions[STORE_SEARCH_OPTION_NAME] = true;
		StoreSortButtonSearchBox_ShowSearchOptions(self, usageOptions);
		self.FilterFrom:Hide();
		StoreSortButtonSearchBox_HideSearchPreview(self);
		return;
	end

	local utf8CursorPosition = self:GetUTF8CursorPosition();
	local cursorPosition = self:GetCursorPosition();

	local searchText = searchBoxText;
	for i = 1, #searchBoxFilters do
		local name = searchBoxFilters[i].name;

		if name then
			searchText = string.gsub(searchText, name, strconcat("|", name, "|"));
		end
	end

	local parsedFilter = {strsplit("|", searchText)};
	table.remove(parsedFilter, 1);

	self.textCursorX = nil;
	self.textCursorY = nil;

	local foundOption;

	for i = 1, #parsedFilter, 2 do
		local option = parsedFilter[i];
		local filter = parsedFilter[i + 1] or "";

		for j = 1, #searchBoxFilters do
			local searchOption = searchBoxFilters[j];

			if searchOption.name == option then
				usageOptions[option] = true;

				local optionX, optionY = strfind(searchBoxText, option, -cursorPosition, true);
				local filterX, filterY = strfind(searchBoxText, filter, optionY or 1, true);

				local lowerFilter = strlower(filter);

				if searchOption.filters then
					local foundTrimmed, foundFilter;

					for k = 1, #searchOption.filters do
						local optionFilter = searchOption.filters[k];
						local filterName = _G[searchOption.filters[k]];

						if filterName then
							local lowerFilterName = strlower(filterName);

							if strfind(lowerFilterName, lowerFilter, 1, true) then
								self.textCursorX = filterX;
								self.textCursorY = filterY;

								shouldShowFilters = searchOption;
								filterText = lowerFilter;
							end

							if not foundTrimmed and lowerFilterName == strtrim(lowerFilter) then
								foundTrimmed = optionFilter;
							end

							if lowerFilterName == lowerFilter then
								foundFilter = optionFilter;
							end
						end
					end

					shouldShowOptions = foundTrimmed and not foundFilter;

					if foundTrimmed then
						shouldShowFilters = false;

						if foundFilter or foundTrimmed then
							self.Filters[foundFilter or foundTrimmed] = searchOption.func;

							if foundFilter then
								filterText = nil;
							end
						end
					end
				else
					shouldShowOptions = false;

					self.Filters[lowerFilter] = searchOption.func;
				end

				foundOption = true;

				break;
			end
		end
	end

	if not foundOption then
		shouldShowOptions = false;
	end

	if shouldShowFilters then
		StoreSortButtonSearchBox_ShowSearchFilters(self, shouldShowFilters, filterText);

		self.SearchOption:Hide();
		StoreSortButtonSearchBox_HideSearchPreview(self);
		return;
	else
		if shouldShowOptions then
			StoreSortButtonSearchBox_ShowSearchOptions(self, usageOptions);
			StoreSortButtonSearchBox_HideSearchPreview(self);
			return;
		else
			self.SearchOption:Hide();
		end

		self.FilterFrom:Hide();
	end

	local onlyTextSearch = not parsedFilter[1] and not (shouldShowOptions and shouldShowFilters and parsedFilter[2])
	local foundFilter = next(self.Filters) or onlyTextSearch;

	if foundFilter then
		for index = 1, #STORE_PRODUCT_LIST do
			local product = STORE_PRODUCT_LIST[index];

			local macthFilter = true;

			if onlyTextSearch then
				local name = product.Name;

				if not name or name == "" or not string.find(strlower(name), searchText, 1, true) then
					macthFilter = false;
				end
			else
				for filter, func in pairs(self.Filters) do
					if not func(nil, filter, product.Entry, product.Link, product.Name) then
						macthFilter = false;
						break;
					end
				end
			end

			if macthFilter then
				self.PreviewContainer.Results[#self.PreviewContainer.Results + 1] = index;
			end
		end
	end

	local numResults = #self.PreviewContainer.Results;
	if numResults > 0 then
		StoreSortButtonSearchBox_SetSearchPreviewSelection(self, 1);
	end

	local lastButton;

	for index = 1, 5 do
		local searchPreview = self.PreviewContainer.SearchPreviews[index];
		local productIndex = self.PreviewContainer.Results[index];
		local product = productIndex and STORE_PRODUCT_LIST[productIndex];

		if index <= numResults and product then
			searchPreview.Name:SetText(product.Name);
			searchPreview.Icon:SetTexture(product.Texture);

			searchPreview.SelectedTexture:Hide();

			local borderType;

			if product.Quality then
				local r, g, b = GetItemQualityColor(product.Quality);
				searchPreview.Name:SetTextColor(r, g, b);

				borderType = s_qualityToAtlasColorName[product.Quality];
			else
				searchPreview.Name:SetTextColor(0.96875, 0.8984375, 0.578125);
			end

			searchPreview.IconBorder:SetAtlas("dressingroom-itemborder-"..(borderType or "gray"));

			searchPreview.productIndex = productIndex;
			searchPreview:Show();

			lastButton = searchPreview;
		else
			searchPreview.productIndex = nil;
			searchPreview:Hide();
		end
	end

	if numResults > 5 then
		self.PreviewContainer.ShowAllSearchResults:Show();
		lastButton = self.PreviewContainer.ShowAllSearchResults;
		self.PreviewContainer.ShowAllSearchResults.Text:SetText(string.format(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults));
	else
		self.PreviewContainer.ShowAllSearchResults:Hide();
	end

	if lastButton then
		self.PreviewContainer.BorderAnchor:SetPoint("BOTTOM", lastButton, "BOTTOM", 0, -8);
		self.PreviewContainer.Background:Hide();
		self.PreviewContainer:Show();
	else
		self.PreviewContainer:Hide();
	end
end

function StoreSortButtonSearchBox_HideSearchPreview(self)
	self.PreviewContainer:Hide();

	for index = 1, 5 do
		self.PreviewContainer.SearchPreviews[index]:Hide();
	end

	self.PreviewContainer.ShowAllSearchResults:Hide();
end

function StoreSortButtonSearchBox_SetSearchPreviewSelection(self, selectedIndex)
	local numShown = 0;

	for index = 1, 5 do
		local searchPreview = self.PreviewContainer.SearchPreviews[index];
		searchPreview.SelectedTexture:Hide();

		if searchPreview:IsShown() then
			numShown = numShown + 1;
		end
	end

	if self.PreviewContainer.ShowAllSearchResults:IsShown() then
		numShown = numShown + 1;
	end

	self.PreviewContainer.ShowAllSearchResults.SelectedTexture:Hide();

	if numShown <= 0 then
		selectedIndex = 1;
	else
		selectedIndex = (selectedIndex - 1) % numShown + 1;
	end

	self.selectedIndex = selectedIndex;

	if selectedIndex == 6 then
		self.PreviewContainer.ShowAllSearchResults.SelectedTexture:Show();
	else
		self.PreviewContainer.SearchPreviews[selectedIndex].SelectedTexture:Show();
	end
end

function StoreSortButtonSearchBox_ShowFullSearch(self)
	if #self.PreviewContainer.Results == 0 then
		self.SearchResults:Hide();
		return;
	end

	StoreSortButtonSearchBox_UpdateFullSearchResults();
	StoreSortButtonSearchBox_HideSearchPreview(self);
	self:ClearFocus();
	self.SearchResults:Show();
end

function StoreSortButtonSearchPreviewButton_OnLoad(self)
	self.NormalTexture:SetDrawLayer("BACKGROUND");
	self.PushedTexture:SetDrawLayer("BACKGROUND");

	self:SetParentArray("SearchPreviews");
end

function StoreSortButtonSearchPreviewButton_OnEnter(self)
	local previewContainer = self:GetParent();
	StoreSortButtonSearchBox_SetSearchPreviewSelection(previewContainer:GetParent(), self:GetID());
end

function StoreSortButtonSearchPreviewButton_OnClick(self)
	if self.productIndex then
		MountJournal_UpdateScrollPos(StoreItemListScrollFrame, self.productIndex);

		local previewContainer = self:GetParent();
		local searchBox = previewContainer:GetParent();
		searchBox.SearchResults:Hide();
		StoreSortButtonSearchBox_HideSearchPreview(searchBox);
		searchBox:ClearFocus();
	end
end

function StoreSortButtonSearchBox_UpdateFullSearchResults()
	local searchBox = StoreItemListFrameContainer.SearchBox;
	local results = searchBox.PreviewContainer.Results;
	local numResults = #results;

	local scrollFrame = searchBox.SearchResults.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	for i = 1, #buttons do
		local button = buttons[i];
		local index = offset + i;

		local productIndex = results[index];
		local product = productIndex and STORE_PRODUCT_LIST[productIndex];

		if index <= numResults and product then
			button.Name:SetText(product.Name);
			button.Icon:SetTexture(product.Texture);

			local borderType

			if product.Quality then
				local r, g, b = GetItemQualityColor(product.Quality);
				button.Name:SetTextColor(r, g, b);

				borderType = s_qualityToAtlasColorName[product.Quality];
			else
				button.Name:SetTextColor(0.96875, 0.8984375, 0.578125);
			end

			button.IconBorder:SetAtlas("dressingroom-itemborder-"..(borderType or "gray"));

			button.productIndex = productIndex;
			button:Show();
		else
			button:Hide();
			button.productIndex = nil;
		end
	end

	local totalHeight = numResults * 49;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 270);

	searchBox.SearchResults.TitleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, searchBox:GetText(), numResults));
end

function StoreSortButtonNumericBox_OnLoad(self)
	self:SetTextInsets(0, 16, 0, 0);

	self.Left:Hide();
	self.Right:Hide();
	self.Middle:Hide();
end

function StoreSortButtonNumericBox_OnShow(self)
	local buttonText = self:GetParent().Text;
	if buttonText then
		buttonText:Hide();
	end

	self:SetFocus();
end

function StoreSortButtonNumericBox_OnHide(self)
	local buttonText = self:GetParent().Text;
	if buttonText then
		buttonText:Show();
	end
end

function StoreSortButtonNumericBox_OnMouseDown(self, button)
	if button == "RightButton" and not self:HasFocus() then
		self.clearFocus = true;
	end
end

function StoreSortButtonNumericBox_OnMouseUp(self, button)
	if button == "RightButton" then
		self:Hide();
	end
end

function StoreSortButtonNumericBox_OnEnter(self)
	self:GetParent():LockHighlight();
end

function StoreSortButtonNumericBox_OnLeave(self)
	self:GetParent():UnlockHighlight();
end

function StoreSortButtonNumericBox_OnEditFocusLost(self)
	if self:GetText() == "" then
		if not self.ClearButton:IsMouseOver() then
			self.ClearButton:Hide();
		end
	end
end

function StoreSortButtonNumericBox_OnEditFocusGained(self)
	if self.clearFocus then
		self:ClearFocus();

		self.clearFocus = nil;
	else
		self.ClearButton:Show();
	end
end

function StoreSortButtonNumericBox_OnTextChanged(self)
	if not self:HasFocus() and self:GetText() == "" then
		self.ClearButton:Hide();
	else
		self.ClearButton:Show();
	end

	InputBoxInstructions_OnTextChanged(self);

	local number = self:GetNumber();
	if not number or number == 0 then
		StoreItemListFrame.iLvl = nil;
	else
		StoreItemListFrame.iLvl = number;
	end

	StoreDataTableCopy(true);
end

function StoreSortButtonNumericBoxClearButton_OnClick(self)
	SearchBoxTemplateClearButton_OnClick(self);

	self:GetParent():Hide();

	StoreItemListFrame.iLvl = nil;
	StoreDataTableCopy(true);
end

function StoreDressUPFrame_OnLoad( self, ... )
	ButtonFrameTemplate_HidePortrait(self)
	ButtonFrameTemplate_HideAttic(self)

	self:SetFrameLevel(StoreFrame:GetFrameLevel() + 2)

	self.TitleText:SetText(STORE_DRESSUP_TITLE)
	self.Inset:Hide()

	self:RegisterForDrag("LeftButton")
end

function StoreDressUPFrame_OnShow( self, ... )
	-- body
end

function StoreDressUPFrame_OnHide( self, ... )
	-- body
end

function StoreTransmogrifyFrame_OnLoad( self, ... )
	local _, _, classID, classMask = UnitClass("player")

	STORE_TRANSMOGRIFY_SORID = 4
	STORE_TRANSMOGRIFY_FILTER_CLASSID = classMask
	STORE_TRANSMOGRIFY_FILTER_EXPANSION = ALL_EXPANSION_FILTER
	STORE_TRANSMOGRIFY_FILTER_SOURCE = ALL_SOURCE_FILTER
	STORE_TRANSMOGRIFY_FILTER_WEAPON = ALL_WEAPON_FILTER

	for i = 1, 4 do
		StoreTransmogrifySetSorted(STORE_TRANSMOGRIFY_SORID, i)
	end

	self.LeftContainer.ScrollFrame.update = StoreTransmogrifyFrame_UpdateScrollFrame
	self.LeftContainer.ScrollFrame.scrollBar.doNotHide = true
	HybridScrollFrame_CreateButtons(self.LeftContainer.ScrollFrame, "StoreTransmogrifyFrameScrollButtonTemplate", 1, 0)

	StoreTransmogrifyGenerateData()
end

function StoreTransmogrifyButtonSetIconBorder( button, quality )
	if quality == LE_ITEM_QUALITY_UNCOMMON then
		button.IconBorder:SetAtlas("loottab-set-itemborder-green")
	elseif quality == LE_ITEM_QUALITY_RARE then
		button.IconBorder:SetAtlas("loottab-set-itemborder-blue")
	elseif quality == LE_ITEM_QUALITY_EPIC then
		button.IconBorder:SetAtlas("loottab-set-itemborder-purple")
	elseif quality == LE_ITEM_QUALITY_LEGENDARY then
		button.IconBorder:SetAtlas("loottab-set-itemborder-orange")
	else
		button.IconBorder:SetAtlas("loottab-set-itemborder-white")
	end
end

function StoreTransmogrifyFrame_UpdateScrollFrame()
	local scrollFrame = StoreTransmogrifyFrame.LeftContainer.ScrollFrame
	local rightContainer = StoreTransmogrifyFrame.RightContainer
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index

	local numSets = GetNumStoreTransmogrifySets()

	rightContainer.ContentFrame:SetShown(numSets > 0)
	rightContainer.ReceiptLine:SetShown(numSets > 0)
	rightContainer.EmptyFrame:SetShown(numSets == 0)

	for i = 1, numButtons do
		button = buttons[i]
		index = offset + i

		if index <= numSets then
			local storeID, setName, iconTexture, isPVP, classID, expansionID, qualityID, itemsStoreID = GetStoreTransmogrifySetsInfo(index)

			button.index = index

			button.Name:SetText(setName)
			button.Icon:SetTexture(iconTexture)

			StoreTransmogrifyButtonSetIconBorder(button, qualityID)

			button.selectedTexture:SetShown(StoreTransmogrifyFrame.selectedIndex and StoreTransmogrifyFrame.selectedIndex == index)

			local serverData = STORE_TRANSMOGRIFY_SERVER_DATA[storeID]

			if serverData then
				local flags = serverData[STORE_TRANSMOGRIFY_SERVER_STOREFLAGS]

				if flags then
					local isNew = bit.band(flags, STORE_ITEM_FLAG_NEW) == STORE_ITEM_FLAG_NEW

					button.NewItems:SetShown(isNew)
				end
			end

			button:Show()
		else
			button:Hide()
		end
	end

	local totalHeight = numSets * buttons[1]:GetHeight()
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
end

function StoreTransmogrifyFrame_UpdateRightContainer()
	local itemCount = GetNumStoreTransmogrifyItems()
	local storeID, setName = GetStoreTransmogrifySetsInfo()
	local containerFrame = StoreTransmogrifyFrame.RightContainer.ContentFrame.OverlayElements
	local buttonsList = StoreTransmogrifyFrame.RightContainer.ContentFrame.Buttons
	local modelFrame = StoreTransmogrifyFrame.RightContainer.ContentFrame.Model
	local size = (34 / 2) * itemCount

	containerFrame:GetParent().previewItems = {}
	containerFrame.selectedItem = nil

	modelFrame:Undress()

	if selectedSubCategoryID == 1 then
		modelFrame:SetUnit("player", true, STORE_TRANSMOGRIFY_CAMERA_SETTINGS_HEAD)
		modelFrame:Undress()

		StoreTransmogrifyFrame.RightContainer.Background:SetTexCoord(0.14453125, 0.7578125, 0.107421875, 0.791015625)
	else
		modelFrame:SetUnit("player", true)
		modelFrame:Undress()
	end

	if selectedSubCategoryID == 1 then
		Store_TryOnModel(modelFrame, 1, not storeTransmogrifyShowShoulders and 3 or 0)
	elseif selectedSubCategoryID == 3 then
		Store_TryOnModel(modelFrame)
	end

	containerFrame.Title:SetText(setName)

	for i = 1, itemCount do
		local storeID, itemID, iconTexture, itemLink, itemRarity, storePrice, storeDiscount, storeDiscountPrice, isPVP = GetStoreTransmogrifyItemsInfo(i)
		local button = buttonsList[i]

		button.itemLink = itemLink
		table.insert(containerFrame:GetParent().previewItems, itemLink)

		button.Icon:SetTexture(iconTexture)
		StoreTransmogrifyButtonSetIconBorder(button, itemRarity)

		button.Icon:SetDesaturated(false)
		button.Icon:SetAlpha(1)
		button.IconBorder:SetDesaturated(false)
		button.IconBorder:SetAlpha(1)

		modelFrame:TryOn(itemLink)

		button:SetPoint("CENTER", containerFrame.IconRowBackground, -size + 34 * i - 17, 0)
		button:Show()
	end

	StoreTransmogrifyUpdatePrice()

	for i = (itemCount + 1), 9 do
		local button = buttonsList[i]
		button:Hide()
	end
end

function StoreTransmogrifyFrameScrollButton_OnClick( self, ... )
	if ( IsModifiedClick("CHATLINK") ) then
		local storeID, setName = GetStoreTransmogrifySetsInfo(self.index)
		if ( ChatEdit_InsertLink(StoreGenerateHyperlink( 1, STORE_TRANSMOGRIFY_CATEGORY_ID, 0, storeID, setName )) ) then
			return true
		end
	end

	StoreTransmogrifyButton_Selected(self.index)
end

function StoreTransmogrifyButton_SelectedSetByStoreID( storeID )
	if not storeID then
		return
	end

	local setClassID = storeTransmogrifySourceDataByStoreID[storeID][STORE_TRANSMOGRIFY_SETS_CLASSID]

	STORE_TRANSMOGRIFY_FILTER_CLASSID = setClassID
	StoreTransmogrifyGenerateData()


	for index, data in pairs(storeTransmogrifySetsData) do
		if data[STORE_TRANSMOGRIFY_SETS_STOREID] == storeID then
			StoreTransmogrifyButton_Selected(index, true)
			return
		end
	end
end

function StoreTransmogrifyButton_Selected( index, focusScroll, forceUpdate )
	if forceUpdate or focusScroll or StoreTransmogrifyFrame.selectedIndex ~= index then
		StoreTransmogrifyFrame.selectedIndex = index
		StoreTransmogrifyFrame_UpdateScrollFrame()

		if focusScroll then
			MountJournal_UpdateScrollPos(StoreTransmogrifyFrame.LeftContainer.ScrollFrame, index)
		end

		StoreTransmogrifyFrame.RightContainer.ContentFrame.selectedItem = nil

		local storeID = GetStoreTransmogrifySetsInfo(index)
		if not StoreTransmogrifyFrame.selectedSets or StoreTransmogrifyFrame.selectedSets ~= storeID then
			StoreTransmogrifyFrame_UpdateRightContainer()
		end
		StoreTransmogrifyFrame.selectedSets = storeID
	end
end

function StoreTransmogrifyItemButton_OnEnter( self, ... )
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end
end

function StoreTransmogrifyItemButton_OnLeave( self, ... )
	GameTooltip:Hide()
end

function StoreTransmogrifyUpdatePrice()
	local _, storePrice, storeDiscount, storeDiscountPrice, altCurrency, altCurrencyIcon;
	local containerFrame = StoreTransmogrifyFrame.RightContainer.ContentFrame.OverlayElements
	local selectedItem = StoreTransmogrifyFrame.RightContainer.ContentFrame.selectedItem

	if selectedItem then
		_, _, _, _, _, storePrice, storeDiscount, storeDiscountPrice, _, altCurrency, _, _, altCurrencyIcon = GetStoreTransmogrifyItemsInfo(selectedItem)
	else
		_, _, _, _, _, _, _, _, storePrice, storeDiscount, storeDiscountPrice, _, altCurrency, _, _, altCurrencyIcon = GetStoreTransmogrifySetsInfo()
	end

	if not storePrice or not storeDiscountPrice then
		return
	end

	if storeDiscountPrice and storeDiscount then
		containerFrame.Price:SetFontObject(GameFontNormal13)
	else
		containerFrame.Price:SetFontObject(GameFontNormal16)
	end

	local hasAltCurrency = altCurrency and altCurrency ~= 0;
	containerFrame.AltCurrencyIcon:SetShown(hasAltCurrency);
	if hasAltCurrency then
		containerFrame.AltCurrencyIcon:SetTexture(altCurrencyIcon);

		containerFrame.PriceIcon:SetPoint("BOTTOMRIGHT", -40, 68);
	else
		containerFrame.PriceIcon:SetPoint("BOTTOMRIGHT", -20, 68);
	end

	containerFrame.Price:SetText(storePrice)
	containerFrame.DiscountPrice:SetText(storeDiscountPrice or 0)

	containerFrame.DiscountPrice:SetShown(storeDiscountPrice and storeDiscount)
	containerFrame.Strikethrough:SetShown(storeDiscountPrice and storeDiscount)
end

function StoreTransmogrifyItemButton_OnClick( self, ... )
	if HandleModifiedItemClick(self.itemLink) then
		return
	end

	if StoreDressUPFrame:IsShown() then
		return
	end

	local containerFrame = StoreTransmogrifyFrame.RightContainer.ContentFrame
	local modelFrame = containerFrame.Model
	local buttonID = self:GetID()

	containerFrame.previewItems = {}

	modelFrame:Undress()

	if containerFrame.selectedItem == buttonID then
		containerFrame.selectedItem = nil
		StoreTransmogrifyFrame_UpdateRightContainer()
		return
	end

	for i = 1, 9 do
		local button = self:GetParent().Buttons[i]

		if button then
			if button:GetID() == buttonID then
				button.Icon:SetDesaturated(false)
				button.Icon:SetAlpha(1)
				button.IconBorder:SetDesaturated(false)
				button.IconBorder:SetAlpha(1)

				table.insert(containerFrame.previewItems, button.itemLink)

				modelFrame:TryOn(button.itemLink)
			else
				button.Icon:SetDesaturated(true)
				button.Icon:SetAlpha(0.3)
				button.IconBorder:SetDesaturated(true)
				button.IconBorder:SetAlpha(0.3)
			end
		end
	end

	containerFrame.selectedItem = buttonID
	StoreTransmogrifyUpdatePrice()
end

function StoreTransmogrifyFrameRightContainerContentFrameModelMagnifier_OnClick( self, ... )
	local previewItems = StoreTransmogrifyFrame.RightContainer.ContentFrame.previewItems

	if not StoreDressUPFrame:IsShown() then
		StoreDressUPFrame:Show()
	end
	StoreDressUPFrame.Display.DressUPModel:SetUnit("player")
	StoreDressUPFrame.Display.DressUPModel:Undress()

	if selectedSubCategoryID == 1 then
		Store_TryOnModel(StoreDressUPFrame.Display.DressUPModel, 1, not storeTransmogrifyShowShoulders and 3 or 0)
	end

	for _, itemLink in pairs(previewItems) do
		StoreDressUPFrame.Display.DressUPModel:TryOn(itemLink)
	end
end

function StoreTransmogrifyFilterDropDown_OnLoad( self, ... )
	UIDropDownMenu_Initialize(self, StoreTransmogrifyFilterDropDown_Initialize, "MENU")
end

function StoreTransmogrifySorted( _, sortID )
	StoreTransmogrifySetSorted( sortID, selectedSubCategoryID )
	StoreTransmogrifyGenerateData(true)
end

function StoreTransmogrifySetSorted( sortID, subcategoryID )
	subcategoryID = subcategoryID or selectedSubCategoryID

	if not STORE_TRANSMOGRIFY_SETS_DATA[subcategoryID] then
		return
	end

	if sortID == 1 then
		table.sort(STORE_TRANSMOGRIFY_SETS_DATA[subcategoryID], function(a, b)
			return a[STORE_TRANSMOGRIFY_SETS_QUALITY] > b[STORE_TRANSMOGRIFY_SETS_QUALITY]
		end)
	elseif sortID == 2 then
		table.sort(STORE_TRANSMOGRIFY_SETS_DATA[subcategoryID], function(a, b)
			return a[STORE_TRANSMOGRIFY_SETS_NAME] > b[STORE_TRANSMOGRIFY_SETS_NAME]
		end)
	elseif sortID == 3 then
		table.sort(STORE_TRANSMOGRIFY_SETS_DATA[subcategoryID], function(a, b)
			local a_StoreID = a[STORE_TRANSMOGRIFY_SETS_STOREID]
			local b_StoreID = b[STORE_TRANSMOGRIFY_SETS_STOREID]

			if STORE_TRANSMOGRIFY_SERVER_DATA[a_StoreID][STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNT] and STORE_TRANSMOGRIFY_SERVER_DATA[b_StoreID][STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNT] then
				return STORE_TRANSMOGRIFY_SERVER_DATA[a_StoreID][STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNTPRICE] > STORE_TRANSMOGRIFY_SERVER_DATA[b_StoreID][STORE_TRANSMOGRIFY_SERVER_STOREDISCOUNTPRICE]
			else
				return STORE_TRANSMOGRIFY_SERVER_DATA[a_StoreID][STORE_TRANSMOGRIFY_SERVER_STOREPRICE] > STORE_TRANSMOGRIFY_SERVER_DATA[b_StoreID][STORE_TRANSMOGRIFY_SERVER_STOREPRICE]
			end
		end)
	elseif sortID == 4 then
		table.sort(STORE_TRANSMOGRIFY_SETS_DATA[subcategoryID], function(a, b)
			return a[STORE_TRANSMOGRIFY_SETS_EXPANSION] > b[STORE_TRANSMOGRIFY_SETS_EXPANSION]
		end)
	elseif sortID == 5 then
		table.sort(STORE_TRANSMOGRIFY_SETS_DATA[subcategoryID], function(a, b)
			return a[STORE_TRANSMOGRIFY_SETS_WEAPONTYPE] > b[STORE_TRANSMOGRIFY_SETS_WEAPONTYPE]
		end)
	end

	STORE_TRANSMOGRIFY_SORID = sortID
end

function StoreTransmogrifySetClassFilter( _, classMask )
	STORE_TRANSMOGRIFY_FILTER_CLASSID = classMask
	StoreTransmogrifyGenerateData(true)
end

function StoreTransmogrifySetExpansionFilter( _, expansionID )
	STORE_TRANSMOGRIFY_FILTER_EXPANSION = expansionID
	StoreTransmogrifyGenerateData(true)
end

function StoreTransmogrifySetSourceFilter( _, sourceID )
	STORE_TRANSMOGRIFY_FILTER_SOURCE = sourceID
	StoreTransmogrifyGenerateData(true)
end

function StoreTransmogrifySetWeaponFilter( _, weaponID )
	STORE_TRANSMOGRIFY_FILTER_WEAPON = weaponID
	StoreTransmogrifyGenerateData(true)
end

function StoreTransmogrifyResetAllFilter()
	local _, _, classID, classMask = UnitClass("player")

	STORE_TRANSMOGRIFY_SORID = 4
	STORE_TRANSMOGRIFY_FILTER_CLASSID = classMask
	STORE_TRANSMOGRIFY_FILTER_EXPANSION = ALL_EXPANSION_FILTER
	STORE_TRANSMOGRIFY_FILTER_SOURCE = ALL_SOURCE_FILTER
	STORE_TRANSMOGRIFY_FILTER_WEAPON = ALL_WEAPON_FILTER
	StoreTransmogrifySetSorted( STORE_TRANSMOGRIFY_SORID )

	StoreTransmogrifyFrame_ClearSearch(StoreTransmogrifyFrame.LeftContainer.searchBox)
end

local newIconString = "|TInterface\\Store\\Store-Main.blp:18:18:2:0:1024:1024:957:967:286:304|t";

function StoreTransmogrifyFilterDropDown_Initialize( self, level )
	local info = UIDropDownMenu_CreateInfo()

	if selectedSubCategoryID ~= 2 then
		if UIDROPDOWNMENU_MENU_VALUE == 1 then
			info.text = ALL_CLASSES
			info.checked = STORE_TRANSMOGRIFY_FILTER_CLASSID == NO_CLASS_FILTER
			info.arg1 = NO_CLASS_FILTER
			info.func = StoreTransmogrifySetClassFilter
			UIDropDownMenu_AddButton(info, level)

			local numClasses = GetNumClasses()
			for i = 1, numClasses do
				local classDisplayName, classTag, classID, classMask = GetClassInfo(i)
				if classID ~= 10 then -- temp remove demonhunter
					info.text = classDisplayName
					info.checked = STORE_TRANSMOGRIFY_FILTER_CLASSID == classMask
					info.arg1 = classMask
					info.func = StoreTransmogrifySetClassFilter
					UIDropDownMenu_AddButton(info, level)
				end
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
			info.text = STORE_TRANSMOGRIFY_FILTER_ALL_EXPANSION
			info.checked = STORE_TRANSMOGRIFY_FILTER_EXPANSION == ALL_EXPANSION_FILTER
			info.arg1 = ALL_EXPANSION_FILTER
			info.func = StoreTransmogrifySetExpansionFilter
			UIDropDownMenu_AddButton(info, level)

			local numExpansion = GetNumWoWExpansion()
			for i = 0, numExpansion do
				local expansionName, expansionID = GetWoWExpansionInfo(i)

				info.text = "World of Warcraft: "..expansionName
				info.checked = STORE_TRANSMOGRIFY_FILTER_EXPANSION == expansionID
				info.arg1 = expansionID
				info.func = StoreTransmogrifySetExpansionFilter
				info.disabled = not storeTransmogirfyUseExpansion[bit.lshift(1, expansionID)]
				UIDropDownMenu_AddButton(info, level)
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == 3 then
			info.text = STORE_TRANSMOGRIFY_FILTER_ALL_SOURCE
			info.checked = STORE_TRANSMOGRIFY_FILTER_SOURCE == ALL_SOURCE_FILTER
			info.arg1 = ALL_SOURCE_FILTER
			info.func = StoreTransmogrifySetSourceFilter
			UIDropDownMenu_AddButton(info, level)

			info.text = STORE_TRANSMOGRIFY_FILTER_PVP_REWARD
			info.checked = STORE_TRANSMOGRIFY_FILTER_SOURCE == 1
			info.arg1 = 1
			info.func = StoreTransmogrifySetSourceFilter
			UIDropDownMenu_AddButton(info, level)

			info.text = STORE_TRANSMOGRIFY_FILTER_PVE_REWARD
			info.checked = STORE_TRANSMOGRIFY_FILTER_SOURCE == 2
			info.arg1 = 2
			info.func = StoreTransmogrifySetSourceFilter
			UIDropDownMenu_AddButton(info, level)
		end
	elseif selectedSubCategoryID == 2 and UIDROPDOWNMENU_MENU_VALUE == 4 then
		info.text = STORE_TRANSMOGRIFY_FILTER_NEW
		info.checked = STORE_TRANSMOGRIFY_FILTER_WEAPON == ALL_WEAPON_NEW_FILTER
		info.arg1 = ALL_WEAPON_NEW_FILTER
		info.func = StoreTransmogrifySetWeaponFilter
		UIDropDownMenu_AddButton(info, level)

		info.text = STORE_TRANSMOGRIFY_FILTER_ALL_WEAPON
		info.checked = STORE_TRANSMOGRIFY_FILTER_WEAPON == ALL_WEAPON_FILTER
		info.arg1 = ALL_WEAPON_FILTER
		info.func = StoreTransmogrifySetWeaponFilter
		UIDropDownMenu_AddButton(info, level)

		for i, subClass in ipairs(STORE_TRANSMOGRIFY_WEAPON_SUB_CLASSES) do
			if subClass == ITEM_SUB_CLASS_2_14 then
				subClass = INVTYPE_WEAPONOFFHAND
			end

			if storeTransmogrifyNewWeaponTypes[i] then
				info.text = subClass..newIconString
			else
				info.text = subClass
			end

			info.checked = STORE_TRANSMOGRIFY_FILTER_WEAPON == i
			info.arg1 = i
			info.func = StoreTransmogrifySetWeaponFilter
			UIDropDownMenu_AddButton(info, level)
		end
	end

	if level == 1 then
		info.text = STORE_TRANSMOGRIFY_FILTER_SORT_TITLE
		info.isTitle = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)

		info.isTitle = false
		info.notCheckable = false
		info.disabled = false

		info.text = STORE_TRANSMOGRIFY_SORT_BY_QUALITY
		info.func = StoreTransmogrifySorted
		info.arg1 = 1
		info.checked = STORE_TRANSMOGRIFY_SORID == 1
		UIDropDownMenu_AddButton(info, level)

		info.text = STORE_TRANSMOGRIFY_SORT_BY_NAME
		info.func = StoreTransmogrifySorted
		info.arg1 = 2
		info.checked = STORE_TRANSMOGRIFY_SORID == 2
		UIDropDownMenu_AddButton(info, level)

		info.text = STORE_TRANSMOGRIFY_SORT_BY_PRICE
		info.func = StoreTransmogrifySorted
		info.arg1 = 3
		info.checked = STORE_TRANSMOGRIFY_SORID == 3
		UIDropDownMenu_AddButton(info, level)

		info.text = STORE_TRANSMOGRIFY_SORT_BY_EXPANSION
		info.func = StoreTransmogrifySorted
		info.arg1 = 4
		info.checked = STORE_TRANSMOGRIFY_SORID == 4
		UIDropDownMenu_AddButton(info, level)

		info.text = STORE_TRANSMOGRIFY_SORT_BY_WEAPON
		info.func = StoreTransmogrifySorted
		info.arg1 = 5
		info.checked = STORE_TRANSMOGRIFY_SORID == 5
		UIDropDownMenu_AddButton(info, level)

		info.func = nil

		info.text = STORE_TRANSMOGRIFY_FILTER_LABEL
		info.isTitle = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)

		info.isTitle = false
		info.notCheckable = false
		info.disabled = false

		if selectedSubCategoryID ~= 2 then
			info.text = STORE_TRANSMOGRIFY_CLASS_LABEL
			info.func =  nil
			info.notCheckable = true
			info.hasArrow = true
			info.value = 1
			UIDropDownMenu_AddButton(info, level)

			info.text = STORE_TRANSMOGRIFY_EXPANSION_LABEL
			info.func =  nil
			info.notCheckable = true
			info.hasArrow = true
			info.value = 2
			UIDropDownMenu_AddButton(info, level)

			info.text = STORE_TRANSMOGRIFY_SOURCE_LABEL
			info.func =  nil
			info.notCheckable = true
			info.hasArrow = true
			info.value = 3
			UIDropDownMenu_AddButton(info, level)
		elseif selectedSubCategoryID == 2 then
			info.text = STORE_TRANSMOGRIFY_WEAPON_LABEL
			info.func =  nil
			info.notCheckable = true
			info.hasArrow = true
			info.value = 4
			UIDropDownMenu_AddButton(info, level)
		end

		UIDropDownMenu_AddSeparator(info)

		local info = UIDropDownMenu_CreateInfo()

		info.isTitle = nil
		info.notCheckable = true

		info.text = STORE_TRANSMOGRIFY_RESET_ALL
		info.func = StoreTransmogrifyResetAllFilter
		info.arg1 = nil
		info.checked = nil
		UIDropDownMenu_AddButton(info, level)
	end
end

function StoreTransmogrifyFrame_OnSearchTextChanged( self, ... )
	SearchBoxTemplate_OnTextChanged(self)
	STORE_SEARCH_TEXT = self:GetText()
	StoreTransmogrifyGenerateData(true)
end

function StoreTransmogrifyFrame_ClearSearch( self, ... )
	self:SetText("")
	STORE_SEARCH_TEXT = nil
	StoreTransmogrifyGenerateData(true)
end

local storeLoadingScreenTimer
function StoreToggleLoadingScreen( isActive, forceState )
	if storeLoadingScreenTimer then
		storeLoadingScreenTimer:Cancel()
		storeLoadingScreenTimer = nil
	end

	if isActive then
		if forceState then
			StoreLoadingFrame:Show()
		else
			storeLoadingScreenTimer = C_Timer:NewTicker(0.200, function()
				StoreLoadingFrame:Show()
			end, 1)
		end
	else
		if StoreLoadingFrame:IsShown() then
			if forceState then
				StoreLoadingFrame:Hide()
			else
				C_Timer:After(2, function()
					StoreLoadingFrame:Hide()
				end)
			end
		end
	end
end

function StoreSetDesaturatedAndDisableButtonInLoadingScreen( toggle )
	local categories = STORE_CATEGORIES_DATA[selectedMoneyID] or {}

	for i = 1, 4 do
		local moneyButton = _G["StoreMoneyButton"..i]

		if moneyButton then
			moneyButton.Icon:SetDesaturated(toggle)
			moneyButton.Background:SetDesaturated(toggle)
			moneyButton.Highlight:SetDesaturated(toggle)
			moneyButton.Selected:SetDesaturated(toggle)
			moneyButton.Text:SetDesaturated(toggle)
			moneyButton:SetEnabled(not toggle)
		end
	end

	for i = 1, #categories do
		local categoryButton = _G["StoreCategoryButton"..i]

		if categoryButton then
			if categoryButton.isEnable then
				categoryButton.Category:SetDesaturated(toggle)
				categoryButton.SelectedTexture:SetDesaturated(toggle)
				categoryButton.HighlightTexture:SetDesaturated(toggle)
				categoryButton.ColoredTexture:SetDesaturated(toggle)
				categoryButton.PulseTexture:SetDesaturated(toggle)
				categoryButton.Text:SetDesaturated(toggle)
				categoryButton.NewItems:SetDesaturated(toggle)
				categoryButton.Icon:SetDesaturated(toggle)
				categoryButton:SetEnabled(not toggle)
			end
		end
	end

	StorePremiumButtons.Background:SetDesaturated(toggle)
	StorePremiumButtons.Border:SetDesaturated(toggle)
	StorePremiumButtons.BorderHighlight:SetDesaturated(toggle)
	StorePremiumButtons.Text:SetDesaturated(toggle, StorePremiumButtons.Text.color)
	StorePremiumButtons.Icon:SetDesaturated(toggle)
	StorePremiumButtons.IconBorder:SetDesaturated(toggle)
	StorePremiumButtons.IconBorderHighlight:SetDesaturated(toggle)
	StorePremiumButtons:SetEnabled(not toggle)
end

function StoreLoadingFrame_OnShow( self, ... )
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 20)
	StoreSetDesaturatedAndDisableButtonInLoadingScreen(true)
end

function StoreLoadingFrame_OnHide( self, ... )
	StoreSetDesaturatedAndDisableButtonInLoadingScreen(false)
end

function StoreTransmogrifyBuyButton_OnClick( self, ... )
	local containerFrame = StoreTransmogrifyFrame.RightContainer.ContentFrame
	local storeID, name, itemID, iconTexture, itemLink, itemRarity, isPVP, classID, expansionID, qualityID, itemsStoreID, storePrice, storeDiscount, storeDiscountPrice, isPVP, price, altCurrency, altPrice, altCurrencyName, altCurrencyIcon

	if containerFrame.selectedItem then
		storeID, itemID, iconTexture, itemLink, itemRarity, storePrice, storeDiscount, storeDiscountPrice, isPVP, altCurrency, altPrice, altCurrencyName, altCurrencyIcon = GetStoreTransmogrifyItemsInfo(containerFrame.selectedItem)
	else
		storeID, name, iconTexture, isPVP, classID, expansionID, qualityID, itemsStoreID, storePrice, storeDiscount, storeDiscountPrice, isPVP, altCurrency, altPrice, altCurrencyName, altCurrencyIcon = GetStoreTransmogrifySetsInfo()
	end

	name 	= name or GetItemInfo(itemID)
	price 	= storeDiscount and storeDiscountPrice or storePrice

	local storeBuyData = {
		Texture 		= iconTexture,
		Name 			= name,
		Price 			= price,
		ID 				= storeID,
		Flags 			= STORE_TRANSMOGRIFY_SERVER_DATA[storeID][STORE_TRANSMOGRIFY_SERVER_STOREFLAGS],
		AltCurrency 	= altCurrency,
		AltPrice 		= altPrice,
		AltCurrencyName = altCurrencyName,
		AltCurrencyIcon = altCurrencyIcon,
	}


	StoreFrame_ProductBuy(storeBuyData)
end


local StoreTransmogrify_HelpPlate = {
	FramePos = { x = 2, y = -2 },
	FrameSize = { width = 594, height = 468 },
	[1] = { ButtonPos = { x = 84, y = -212 }, HighLightBox = { x = 0, y = 0, width = 216, height = 465 }, ToolTipDir = "RIGHT", ToolTipText = STORE_TRANSMOGRIFY_TUTORIAL_1 }
}

function StoreTransmogrify_ToggleTutorial( self, ... )
	local titleHeight = StoreTransmogrifyFrame.RightContainer.ContentFrame.Title:GetStringHeight()

	if titleHeight > 20 then
		StoreTransmogrify_HelpPlate[2] = { ButtonPos = { x = 390, y = -97 }, HighLightBox = { x = 246, y = -67, width = 340, height = 50 }, ToolTipDir = "DOWN", ToolTipText = STORE_TRANSMOGRIFY_TUTORIAL_2 }
	else
		StoreTransmogrify_HelpPlate[2] = { ButtonPos = { x = 390, y = -80 }, HighLightBox = { x = 246, y = -50, width = 340, height = 50 }, ToolTipDir = "DOWN", ToolTipText = STORE_TRANSMOGRIFY_TUTORIAL_2 }
	end

	local helpPlate = StoreTransmogrify_HelpPlate
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, StoreTransmogrifyFrame, StoreTransmogrifyFrame.TutorialButton )
	else
		HelpPlate_Hide(true)
	end
end

local Store_HelpPlate = {
	FramePos = { x = 2, y = -24 },
	FrameSize = { width = 794, height = 506 },
	[1] = { ButtonPos = { x = 70, y = -200 }, HighLightBox = { x = 2, y = -40, width = 190, height = 386 }, ToolTipDir = "RIGHT", ToolTipText = STORE_TUTORIAL_1 },
	[2] = { ButtonPos = { x = 464, y = -380 }, HighLightBox = { x = 198, y = -308, width = 592, height = 200 }, ToolTipDir = "UP", ToolTipText = STORE_TUTORIAL_2 },
	[3] = { ButtonPos = { x = 464, y = -140 }, HighLightBox = { x = 198, y = -40, width = 592, height = 264 }, ToolTipDir = "DOWN", ToolTipText = STORE_TUTORIAL_3 },
	[4] = { ButtonPos = { x = 320, y = 4 }, HighLightBox = { x = 54, y = 2, width = 574, height = 40 }, ToolTipDir = "DOWN", ToolTipText = STORE_TUTORIAL_4 },
	[5] = { ButtonPos = { x = 680, y = 4 }, HighLightBox = { x = 630, y = 2, width = 160, height = 40 }, ToolTipDir = "DOWN", ToolTipText = STORE_TUTORIAL_5 },
}

function StoreFrame_ToggleTutorial(self, ...)
	local helpPlate = Store_HelpPlate
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, StoreFrame, StoreFrame.TutorialButton )
	else
		HelpPlate_Hide(true)
	end
end

function StoreFrame_CategoryIsNew( currency, category )
	return STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency] and STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][category]
end

function StoreFrame_SubCategoryIsNew( currency, category, subCategory )
	if STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency] and STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][category] then
		return STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][category][subCategory]
	end
end

function StoreFrame_MultipleBuyUpdateCount(self)
	local confirmFrame = self:GetParent():GetParent()
	local text = tonumber(self:GetText())

	if not text or text < 1 then
		self:SetText(1)
		confirmFrame.data.buyCount = 1
		return
	end

	local price = (confirmFrame.data.DiscountedPrice or confirmFrame.data.Price) * text
	confirmFrame.NoticeFrame.Price:SetText(price)
	if confirmFrame.hasAltCurrency then
		confirmFrame.NoticeFrame.MoneySelectFrame.MoneyFrame.Price:SetText(price);
		confirmFrame.NoticeFrame.AltCurrencySelectFrame.MoneyFrame.Price:SetText(confirmFrame.data.AltPrice * text);
	end
	confirmFrame.data.buyCount = text
end

function EventHandler:ASMSG_SHOP_BALANCE_RESPONSE( msg )
	local Bonus, Vote, Refer, loyalLevel, loyalMin, loyalMax, loyalCurrent = strsplit(":", msg)

	Bonus 			= tonumber(Bonus)
	Vote 			= tonumber(Vote)
	Refer 			= tonumber(Refer)
	loyalLevel 		= tonumber(loyalLevel)
	loyalMin 		= tonumber(loyalMin)
	loyalMax 		= tonumber(loyalMax)
	loyalCurrent 	= tonumber(loyalCurrent)

	_G["StoreMoneyButton1"].Text:SetText(Bonus)
	_G["StoreMoneyButton2"].Text:SetText(Vote)
	_G["StoreMoneyButton3"].Text:SetText(Refer)
	_G["StoreMoneyButton4"].Text:SetText(loyalLevel)
	_G["StoreMoneyButton4"].data = {loyalCurrent, loyalMax, loyalMin, loyalLevel}

	Hook:FireEvent("PLAYER_BALANCE_UPDATE", Bonus, Vote, Refer, loyalLevel, loyalMin, loyalMax, loyalCurrent)
end

function EventHandler:ASMSG_SHOP_CATEGORY_NEW_ITEMS_RESPONSE( msg )
	local storage = C_Split(msg, "|")

	wipe(STORE_CATEGORY_NEW_ITEMS_INDICATOR)

	for _, splitedMsg in pairs(storage) do
		local data 			= C_Split(splitedMsg, ":")
		local currency 		= tonumber(data[E_STORE_CATEGORY_NEW_ITEMS_INDICATOR.CURRENCY])
		local categoryID 	= tonumber(data[E_STORE_CATEGORY_NEW_ITEMS_INDICATOR.CATEGORYID])
		local subCategoryID = tonumber(data[E_STORE_CATEGORY_NEW_ITEMS_INDICATOR.SUBCATEGORYID])

		if currency and categoryID then
			if not STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency] then
				STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency] = {}
			end

			if not STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][categoryID] then
				STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][categoryID] = {}
			end

			if (STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency] and STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][categoryID]) and subCategoryID then
				STORE_CATEGORY_NEW_ITEMS_INDICATOR[currency][categoryID][subCategoryID] = true
			end
		end
	end
end

function EventHandler:ASMSG_SHOP_ITEM( msg )
	local ID, Entry, count, Price, Discount, DiscountedPrice, creatureEntry, Flags, altCurrency, altPrice, categoryID, subCategoryID = strsplit(":", msg)

	local storeID 				= tonumber(ID)
	local itemEntry 			= tonumber(Entry)
	local itemCount 			= tonumber(count)
	local storePrice 			= tonumber(Price)
	local storeDiscount 		= tonumber(Discount)
	local storeDiscountPrice 	= tonumber(DiscountedPrice)
	local creatureEntry 		= tonumber(creatureEntry)
	local storeFlags 			= tonumber(Flags)
	local storeCategoryID 		= tonumber(categoryID)
	local storeSubCategoryID 	= tonumber(subCategoryID)
	local isPVP 				= bit.band(storeFlags, STORE_ITEM_FLAG_PVP) == STORE_ITEM_FLAG_PVP

	storeDiscount = storeDiscount ~= 0 and storeDiscount
	itemCount = itemCount > 1 and itemCount
	storeDiscountPrice = storeDiscountPrice ~= 0 and storeDiscountPrice
	creatureEntry = creatureEntry ~= 0 and creatureEntry

	local storage = STORE_PRODUCT_CACHE[StoreRequestMoneyID][StoreRequestCategoryID][StoreRequestSubCategoryID][StoreRequestIgnoreFilters]

	if storeID == 0 then
		local categoryID 	= itemEntry
		local subCategoryID = tonumber(count)

		storage.version = GetStoreProductVersion()
		if STORE_SUB_CATEGORY_DATA[categoryID] then
			STORE_SUB_CATEGORY_DATA[categoryID][subCategoryID].Disabled = (not storage.data) and true or false
		end

		StoreSelectCategory(categoryID, subCategoryID)

		StoreRequestMoneyID 		= nil
		StoreRequestCategoryID 		= nil
		StoreRequestSubCategoryID 	= nil
		StoreRequestIgnoreFilters 	= nil

		storeRequestQueue[1][2] = true
		-- coroutine.resume(Store_CoroutineRequestItems)

		StoreToggleLoadingScreen(false, true)
		return
	end

	if not storage.data then
		storage.data = {}
	end

	storage.data[storeID] = {
		storeID,
		itemEntry,
		itemCount,
		storePrice,
		nil,
		storeDiscount,
		storeDiscountPrice,
		creatureEntry,
		storeFlags,
		tonumber(altCurrency),
		tonumber(altPrice),
		isPVP,
		false,
	}
end

function EventHandler:ASMSG_SHOP_BUY_ITEM_RESPONSE( msg )
	local Response, value = strsplit(":", msg)
	local parent

	if BattlePassFrame and BattlePassFrame:IsShown() then
		parent = BattlePassFrame
	end

	if Response == "ERROR_RECEIVER_NOT_FOUND" then
		StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_1, parent)
	elseif Response == "ERROR_CANNOT_GIFT_TO_SELF" then
		StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_2, parent)
	elseif Response == "ERROR_NOT_AVAILABLE_FOR" then
		StoreShowErrorFrame(STORE_ERROR, string.format(STORE_BUY_ITEM_ERROR_3, value), parent, not parent and true or nil)

		StoreRequestShopItems()
	elseif Response == "ERROR_LOYALTY_ALREADY_TAKEN" then
		StoreShowErrorFrame(STORE_ERROR, ERROR_LOYALTY_ALREADY_TAKEN, parent)
	elseif Response == "ERROR_BALANCE" then
		if selectedMoneyID == 4 then
			StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_4, parent)
		else
			StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_5, parent)
		end
	elseif Response == "OK" then
		local name, _, _, _, _, _, _, _, _, texture = GetItemInfo(tonumber(value))
		StoreShowPurchaseAlert(name, texture)

		SendAddonMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST", nil, "WHISPER", UnitName("player"))

		if selectedRemoveOffer then
			selectedSpecialOfferPage = 1
			table.remove(STORE_SPECIAL_OFFER_INFO_DATA, selectedRemoveOffer)
			selectedRemoveOffer = nil
			StoreFrame_SpecialOfferSetup()
		end
	end
end

function EventHandler:ASMSG_SHOP_SPECIAL_OFFER_INFO( msg )
	local splitData = C_Split(msg, "|")

	if splitData and #splitData > 0 then
		local offerID 		= tonumber(splitData[1])
		local background 	= splitData[2]
		local headline 		= splitData[3]
		local title 		= splitData[4]
		local description 	= splitData[5]
		local remainingTime = tonumber(splitData[6])
		local endTime 		= splitData[6] ~= "0" and time() + remainingTime or nil
		local productID 	= tonumber(splitData[7])
		local itemEntry 	= tonumber(splitData[8])
		local price 		= tonumber(splitData[9])
		local selectedSpec  = splitData[10] ~= "0"
		local freeSubscribe = splitData[11] ~= "0"
		local isReusable 	= splitData[12] ~= "0"
		local IsNew 		= STORE_SMALL_SPECIAL_OFFER_BUFFER[offerID]

		local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemEntry)

		if not StoreGetSpecialOfferByOfferID(offerID) then
			table.insert(STORE_SPECIAL_OFFER_INFO_DATA, {
				ID 				= productID,
				Background 		= background,
				MainTitle 		= headline,
				Title 			= title,
				Description 	= description,
				EndTime 		= endTime,
				Name 			= itemName,
				Texture 		= itemTexture,
				SelectedSpec 	= selectedSpec,
				Price 			= price,
				FreeSubscribe 	= freeSubscribe,
				IsReusable 		= isReusable,
				offerID 		= offerID,
				IsNew 			= IsNew
			})
		end
	end

	StoreSpecialOfferSortUpdate()
	StoreSpecialOfferInfoUpdate()
	StoreFrame_SpecialOfferSetup()
end

function EventHandler:ASMSG_SHOP_SPECIAL_OFFER_POPUP( msg )
	if msg:sub(1, 1) == "~" then
		loadstring(string.format([[%s]], msg:sub(2)))() -- Для динамического отображения SpecialOffer.
	else
		local tempdata = {}
		local data = {strsplit("|", msg)}

		for i = 6, #data, 2 do
			table.insert(tempdata, {Entry = data[i], Count = data[i + 1]})
		end

		STORE_SPECIAL_OFFER_POPUP = {
			Texture 		= data[1],
			MainTitle 		= data[2],
			Title 			= data[3],
			Description 	= data[4],
			ID 				= tonumber(data[5]),
			RemainingTime 	= tonumber(data[6]),
			Item 			= CopyTable(tempdata)
		}
	end
end

function EventHandler:ASMSG_SHOP_SPECIAL_OFFER_POPUP_SMALL( msg )
	local splitData = C_Split(msg, "|")
	local offerID 	= tonumber(splitData[1])

	if StoreFrame.Popup then
		NPE_TutorialPointerFrame:Hide(StoreFrame.Popup)
		StoreFrame.Popup = nil
	end

	STORE_SMALL_SPECIAL_OFFER_BUFFER[offerID] = true

	if not StoreMicroButton:IsVisible() or not StoreMicroButton:IsShown() then
		StoreToastButton.TopLine:SetText(STPRE_TOAST_SPECIAL_OFFER_TITLE)
		StoreToastButton.MiddleLine:SetText(STORE_TOAST_SPECIAL_OFFER_BODY)
		StoreToastButton:Show()

		local offer3DModel = STORE_SPECIAL_OFFERS_3D[offerID] and STORE_SPECIAL_OFFERS_3D[offerID].PopupCreature or nil

		StoreToastButton.ModelFrame:SetShown(offer3DModel ~= nil)

		if offer3DModel ~= nil then
			StoreToastButton.ModelFrame:SetCreature(offer3DModel)
		end
	else
		local offerBanner3DModel = STORE_SPECIAL_OFFERS_3D[offerID] and STORE_SPECIAL_OFFERS_3D[offerID].BannerModelInfo or nil
		if offerBanner3DModel ~= nil then
			StoreFrame.Popup = NPE_TutorialPointerFrame:Show(splitData[2], "DOWN", StoreMicroButton, 0, -5, nil, nil, offerBanner3DModel)
		else
			StoreFrame.Popup = NPE_TutorialPointerFrame:Show(splitData[2], "DOWN", StoreMicroButton, 0, -5)
		end
	end

	StoreRequestSpecialOffer()
end

local premiumGreenColor = CreateColor(0, 1, 0)
local premiumRedColor = CreateColor(0, 1, 0)
function EventHandler:ASMSG_PREMIUM_INFO_RESPONSE( msg )
	local timer = tonumber(msg)

	if timer ~= 0 then
		StorePremiumButtons.Text:SetTextColor(premiumGreenColor.r, premiumGreenColor.g, premiumGreenColor.b)
		StorePremiumButtons.Text:SetRemainingTime(timer, true)
		StorePremiumButtons.Text.color = premiumGreenColor

		if timer < 86400 then
			StorePremiumButtons.Text:SetTextColor(premiumRedColor.r, premiumRedColor.g, premiumRedColor.b)
			StorePremiumButtons.Text.color = premiumRedColor
		elseif timer >= 43200000 then
			StorePremiumButtons.Text:SetText(STORE_PREMIUM_FOREVER_LABEL)
			StorePremiumButtons.Text:SetTextColor(premiumGreenColor.r, premiumGreenColor.g, premiumGreenColor.b)
			StorePremiumButtons.Text.color = premiumGreenColor
			return
		end

		if StorePremiumButtons.Ticker then
			StorePremiumButtons.Ticker:Cancel()
			StorePremiumButtons.Ticker = nil
		end

		StorePremiumButtons.Ticker = C_Timer:NewTicker(1, function()
			if StorePremiumButtons:IsVisible() then
				timer = timer - 1
				StorePremiumButtons.Text:SetRemainingTime(timer, true)
			else
				StorePremiumButtons.Ticker:Cancel()
				StorePremiumButtons.Ticker = nil
			end
		end)
	else
		StorePremiumButtons.Text:SetText(STORE_BUY)
		StorePremiumButtons.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		StorePremiumButtons.Text.color = NORMAL_FONT_COLOR
	end
end

function EventHandler:ASMSG_PREMIUM_RENEW_RESPONSE( msg )
	if msg == "ERROR_BALANCE" then
		StoreShowErrorFrame(STORE_ERROR, STORE_BUY_PREMIUM_ERROR_1)
	elseif msg == "OK" then
		StoreShowPurchaseAlert(STORE_PREMIUM_STATUS_LABEL, "Interface\\ICONS\\VIP")
	end
end

function EventHandler:ASMSG_SHOP_SUBSCRIPTION_INFO( msg )
	if tonumber(msg) == -1 then
		STORE_CATEGORIES_DATA[1][STORE_SUBSCRIPTIONS_CATEGORY_ID].Hidden = true
		return
	end

	if STORE_CATEGORIES_DATA[1][STORE_SUBSCRIPTIONS_CATEGORY_ID].Disable then
		STORE_CATEGORIES_DATA[1][STORE_SUBSCRIPTIONS_CATEGORY_ID].Disable = false
	end

	local everyDayItem = {}
	local onSubscribeItem = {}
	local arg = {string.match(msg, "(.*):EVERYDAY:(.*):ONSUBSCRIBE:(.*)")}
	local ID, ShortPrice, LongPrice, ExtraPrice, Flags, Dayz, Seconds, ShowTrial, ActiveTrial, ActiveExtra, Name, Description = strsplit(":", arg[1])
	local everyDay = {strsplit(":", arg[2])}
	local onSubscribe = {strsplit(":", arg[3])}

	for i = 1, #everyDay, 2 do
		if everyDay[i] and everyDay[i + 1] then
			table.insert(everyDayItem, {Entry = everyDay[i], Count = everyDay[i + 1]})
		end
	end
	for s = 1, #onSubscribe, 2 do
		if onSubscribe[s] and onSubscribe[s + 1] then
			table.insert(onSubscribeItem, {Entry = onSubscribe[s], Count = onSubscribe[s + 1]})
		end
	end

	Flags = Flags ~= "0" and tonumber(Flags) or nil
	Dayz = Dayz ~= "0" and tonumber(Dayz) or nil
	Seconds = Seconds ~= "0" and tonumber(Seconds) or nil
	ShowTrial = ShowTrial ~= "0"
	ActiveTrial = ActiveTrial ~= "0"
	ActiveExtra = ActiveExtra ~= "0"

	local tempTable = {
		ID 					= tonumber(ID),
		ShortPrice 			= tonumber(ShortPrice),
		LongPrice 			= tonumber(LongPrice),
		ExtraPrice			= tonumber(ExtraPrice),
		Flags 				= Flags,
		Dayz 				= Dayz,
		Seconds 			= Seconds,
		ShowTrial 			= ShowTrial,
		EveryDayItem 		= CopyTable(everyDayItem),
		OnSubscribeItem 	= CopyTable(onSubscribeItem),
		ActiveTrial			= ActiveTrial,
		ActiveExtra			= ActiveExtra,
        Name                = Name,
		Description			= Description
	}
	
	table.insert(STORE_SUBSCRIBE_DATA, tempTable)

	StoreSubscribeSetup()
end

StaticPopupDialogs["STORE_SERVICE_DIALOG"] = {
	text = STORE_SERVICE_POPUP_TEXT,
	button1 = EXIT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		Logout()
	end,
	OnCancel = function(self) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

function Store_TryOnModel( frame, ... )
	frame:Undress()

	for i = 2, 19 do
		local link = GetInventoryItemLink("player", i)

		if link and not isOneOf(i, ...) then
			frame:TryOn(link)
		end
	end
end

function EventHandler:ASMSG_ACTIVATE_SHOP_SERVICE( msg )
	for i = 1, #STORE_SERVICE_FLAG_DATA do
		local data = STORE_SERVICE_FLAG_DATA[i]
		if data then
			if bit.band(tonumber(msg), data.flag) == data.flag then
				StaticPopup_Show("STORE_SERVICE_DIALOG", data.text)
			end
		end
	end
end

function EventHandler:ASMSG_SHOP_SPECIAL_OFFER_DETAILS( msg )
	local id, title, description, price, itemData = strsplit("|", msg)

	if id and title and description and price then

		id = tonumber( id )
		price = tonumber( price )

		STPRE_SPECIAL_OFFER_DETAILS_DATA[id] = {}
		STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["items"] = {}
		STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["title"] = title
		STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["description"] = description
		STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["price"] = price

		if itemData then
			local items = {strsplit(":", itemData)}
			for i = 1, #items do
				local itemID, role, count = string.match( items[i], "(%d+)\<(%d+)\>\<(%d+)\>" )
				if itemID and role and count then
					itemID = tonumber( itemID )
					role = tonumber( role )
					count = tonumber( count )

					if STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["items"] and not STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["items"][role] then
						STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["items"][role] = {}
					end

					if STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["items"][role] then
						table.insert(STPRE_SPECIAL_OFFER_DETAILS_DATA[id]["items"][role], {itemID = itemID, count = count})
					end
				end
			end
		end
	end
end

function EventHandler:ASMSG_SHOP_REFUNDABLE_PURCHASE_LIST( msg )
	local listData = {strsplit("|", msg)}

	STORE_REFUND_DATA = {}

	if listData and #listData > 0 then
		for i = 1, #listData do
			local itemGUID, bag, slot, purchaseDate, remainingTime, penalty, refundBonuses = string.match( listData[i], "(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)" )
			if bag and slot and itemGUID then
				table.insert(STORE_REFUND_DATA, {
					bag = bag,
					slot = slot,
					purchaseDate = purchaseDate,
					remainingTime = tonumber(remainingTime),
					penalty = tonumber(penalty),
					refundBonuses = refundBonuses,
					itemGUID = itemGUID,
					itemID = bag == "255" and GetInventoryItemID("player", slot) or GetContainerItemID(bag, slot),
					requestTime = GetTime(),
				})
			end
		end
	end

	StoreRefundListScrollFrame_UpdateItemList()
end

function EventHandler:ASMSG_SHOP_PURCHASE_REFUND_RESPONSE( msg )
	msg = tonumber(msg)

	if msg == 0 then
		StoreShowPurchaseAlert(STORE_BONUS_COIN_LABEL, "Interface\\ICONS\\WoW_Store")
		StoreRefundFrame.RefundButton:Enable()

		SendAddonMessage("ACMSG_SHOP_REFUNDABLE_PURCHASE_LIST_REQUEST", nil, "WHISPER", UnitName("player"))
	else
		StoreShowErrorFrame(STORE_ERROR, STORE_REFUND_ERROR_PERFORM_ANOTHER_OPERATION)
		StoreRefundFrame.RefundButton:Disable()
	end
end

function EventHandler:ASMSG_SHOP_ROLLED_TEMS_INFO( msg )
	ReportBug("Configuration")

	local renewWeeks 		= tonumber(msg)
	local cacheRenewWeeks 	= STORE_CACHE:Get("MOUNT_RENEW_WEEK", 0)

	if cacheRenewWeeks ~= renewWeeks then
		STORE_CACHE:Set("MOUNT_RENEW_WEEK", renewWeeks)
		STORE_CACHE:Set("CATEGORY_DROP_COUNT"..3, 1)
		STORE_CACHE:Set("CATEGORY_DROP_COUNT"..6, 1)

		ButtonPulse_StopPulse(StoreMicroButton)
		ButtonPulse_StopPulse(GameMenuButtonStore)

		Hook:RegisterCallback("SERVICE", "SERVICE_DATA_RECEIVED", function( isGM, realmID, isStoreEnabled, accountID )
			if not isStoreEnabled then
				ButtonPulse_StopPulse(StoreMicroButton)
				ButtonPulse_StopPulse(GameMenuButtonStore)
			end
		end)

		if StoreMicroButton:IsEnabled() == 1 then
			SetButtonPulse(StoreMicroButton, 60, 0.50)
		end

		if GameMenuButtonStore:IsEnabled() == 1 then
			SetButtonPulse(GameMenuButtonStore, 60, 0.50)
		end
	end
end

function EventHandler:ASMSG_SHOP_RENEW_MOUNTS( msg )
	local responseID = tonumber(msg)

	if responseID == 0 then
		local cacheDropsCount = STORE_CACHE:Get("MOUNT_DROP_COUNT", 0)
		STORE_CACHE:Set("MOUNT_DROP_COUNT", cacheDropsCount + 1)
		StoreToggleLoadingScreen(true, true)

		StoreItemListUpdate()
		StoreFrame_UpdateItemCard()
	else
		StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_5)
	end
end

function EventHandler:ASMSG_SHOP_RENEW_PETS( msg )
	local responseID = tonumber(msg)

	if responseID == 0 then
		local cacheDropsCount = STORE_CACHE:Get("MOUNT_DROP_COUNT", 0)
		STORE_CACHE:Set("MOUNT_DROP_COUNT", cacheDropsCount + 1)
		StoreToggleLoadingScreen(true, true)

		StoreItemListUpdate()
		StoreFrame_UpdateItemCard()
	else
		StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_5)
	end
end

function EventHandler:ASMSG_SHOP_RENEW_ITEMS( msg )
	local answer = C_Split(msg, ":")
	local responseID = tonumber(answer[1])
	local categoryId = tonumber(answer[2])

	if responseID == 0 then
		local cacheDropsCount = STORE_CACHE:Get("CATEGORY_DROP_COUNT"..categoryId, 0)
		STORE_CACHE:Set("CATEGORY_DROP_COUNT"..categoryId, cacheDropsCount + 1)
		if categoryId == STORE_TRANSMOGRIFY_CATEGORY_ID then
			STORE_TRANSMOGRIFY_SERVER_DATA = {}
		end
		StoreToggleLoadingScreen(true, true)

		StoreItemListUpdate()
		StoreFrame_UpdateItemCard()
	else
		StoreShowErrorFrame(STORE_ERROR, STORE_BUY_ITEM_ERROR_5)
	end
end

function StoreRequestShopItems( moneyID, categoryID, subCategoryID, ignireFilters )
	local _StoreRequestMoneyID 			= (moneyID or selectedMoneyID) or 0
	local _StoreRequestCategoryID 		= (categoryID or selectedCategoryID) or 0
	local _StoreRequestSubCategoryID 	= (subCategoryID or selectedSubCategoryID) or 0
	local _StoreRequestIgnoreFilters 	= (ignireFilters or selectedShowAllItemCheckBox) or 0

	--                             Request  Response
	table.insert(storeRequestQueue, {false, false,
			_StoreRequestMoneyID,
			_StoreRequestCategoryID,
			_StoreRequestSubCategoryID,
			_StoreRequestIgnoreFilters
		})

	if not storeQueueTimer and #storeRequestQueue > 0 then
		storeQueueTimer = C_Timer:NewTicker(0.1, function()
			if #storeRequestQueue > 0 then
				if not storeRequestQueue[1][1] then
					StoreRequestMoneyID 		= storeRequestQueue[1][3]
					StoreRequestCategoryID 		= storeRequestQueue[1][4]
					StoreRequestSubCategoryID 	= storeRequestQueue[1][5]
					StoreRequestIgnoreFilters 	= storeRequestQueue[1][6]

					SendServerMessage("ACMSG_SHOP_ITEM_LIST_REQUEST", string.format("%d:%d:%d:%d",
							StoreRequestMoneyID,
							StoreRequestCategoryID,
							StoreRequestSubCategoryID,
							StoreRequestIgnoreFilters
						))

					storeRequestQueue[1][1] = true
					StoreToggleLoadingScreen(true, false)
				else
					if storeRequestQueue[1][2] then
						table.remove(storeRequestQueue, 1)
					end
				end
			else
				storeQueueTimer:Cancel()
				storeQueueTimer = nil
			end
		end)
	end
end

function EventHandler:ASMSG_SHOP_VERSION( msg )
	local version = tonumber(msg)
	STORE_CACHE:Set("ASMSG_SHOP_VERSION", version)
end

StoreTransmogrifySubCategoryFrameMixin = {}

function StoreTransmogrifySubCategoryFrameMixin:OnLoad()
	self.Background:SetAtlas("Store-Transmogrify-Page-Background")
end

StoreTransmogrifySubCategoryCardMixin = {}

function StoreTransmogrifySubCategoryCardMixin:OnLoad()
	self.iconAtlas 				= self:GetAttribute("iconAtlas")
	self.disabledSubCategory 	= self:GetAttribute("disabledSubCategory")
	self.text 					= self:GetAttribute("text") and _G[self:GetAttribute("text")] or self:GetAttribute("text")

	self:SetParentArray("cardButtons")

	self.Title:SetText(self.text)
	self.Icon:SetAtlas(self.iconAtlas)
	self.BackgroundTexture:SetAtlas("shop-card-bundle")

	local textColor = not self.disabledSubCategory and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR
	self.Title:SetTextColor(textColor.r, textColor.g, textColor.b)

	self.BackgroundTexture:SetDesaturated(self.disabledSubCategory)
	self.Icon:SetDesaturated(self.disabledSubCategory)
	self.Icon:SetAlpha(self.disabledSubCategory and 0.5 or 1)

	self.Button:SetEnabled(not self.disabledSubCategory)
end

StoreTransmogrifySubCategoryFrameButtonMixin = {}

STORE_TRANSMOGRIFY_CAMERA_SETTINGS_HEAD = {
	["Human2"] = {2.455001, 1.023000, 0.369000},
	["Human3"] = {2.148000, 1.020001, 0.409000},
	["Dwarf2"] = {2.734001, 0.993001, 0.532000},
	["Dwarf3"] = {1.988001, 0.962001, 0.656000},
	["NightElf2"] = {2.941001, 1.000000, 0.226000},
	["NightElf3"] = {3.675001, 0.985001, 0.295000},
	["Gnome2"] = {1.712001, 1.000000, 0.790000},
	["Gnome3"] = {1.657001, 1.000000, 0.862001},
	["Draenei2"] = {3.863001, 1.000000, 0.224000},
	["Draenei3"] = {3.402001, 0.951001, 0.175000},
	["Worgen2"] = {3.299001, 0.982001, 0.277000},
	["Worgen3"] = {4.119000, 1.609001, 0.380001},
	["Queldo2"] = {3.299001, 1.014001, 0.281000},
	["Queldo3"] = {2.839001, 1.033000, 0.426001},
	["Orc2"] = {2.429001, 1.046000, 0.380001},
	["Orc3"] = {2.875001, 0.987001, 0.411000},
	["Scourge2"] = {2.582000, 1.057001, 0.431001},
	["Scourge3"] = {3.552001, 1.031000, 0.482000},
	["Tauren2"] = {3.200001, 1.007001, 0.431001},
	["Tauren3"] = {2.838001, 1.025001, 0.596000},
	["Goblin2"] = {2.377001, 1.028000, 0.790000},
	["Goblin3"] = {2.429001, 1.000000, 0.790000},
	["Troll2"] = {3.351001, 0.959001, 0.534001},
	["Troll3"] = {3.504001, 1.011001, 0.380001},
	["Naga2"] = {3.351001, 1.076001, 0.534001},
	["Naga3"] = {3.863001, 1.099001, 0.482000},
	["BloodElf2"] = {3.299001, 1.013000, 0.277000},
	["BloodElf3"] = {2.736001, 1.036000, 0.450000},
	["Pandaren2"] = {2.917001, 1.022001, 0.305000},
	["Pandaren3"] = {2.149001, 1.022001, 0.356000},
	["Vulpera2"] = {3.248001, 1.037001, 0.867001},
	["Vulpera3"] = {3.556001, 1.028000, 0.818000},
	["Nightborne2"] = {2.941001, 0.979000, 0.226000},
	["Nightborne3"] = {2.839001, 1.021001, 0.426001},
	["VoidElf2"] = {2.582000, 1.044001, 0.431001},
	["VoidElf3"] = {2.839001, 0.968001, 0.426001},
}

function StoreTransmogrifySubCategoryFrameButtonMixin:OnClick()
	selectedSubCategoryID = self:GetParent():GetID()

	if StoreItemListUpdate() then
		StoreSelectCategory(selectedCategoryID, selectedSubCategoryID)
	end

	StoreTransmogrifyFrame.RightContainer.ContentFrame.OverlayElements.ShowShoulders:SetShown(selectedSubCategoryID == 1)

	if CharacterCreateZoomDebugPanel and IsDevClient() then
		CharacterCreateZoomDebugPanel:InitPosition()
	end
end