NUM_BROWSE_TO_DISPLAY = 8;
NUM_AUCTION_ITEMS_PER_PAGE = 50;
NUM_AUCTION_FILTERS_TO_DISPLAY = 20;
BROWSE_FILTER_HEIGHT = 20;
NUM_BIDS_TO_DISPLAY = 9;
NUM_AUCTIONS_TO_DISPLAY = 9;
AUCTIONS_BUTTON_HEIGHT = 37;
CLASS_FILTERS = {};
AUCTION_TIMER_UPDATE_DELAY = 0.3;
MAXIMUM_BID_PRICE = 2000000000;
AUCTION_CANCEL_COST =  5;	--5% of the current bid
NUM_TOKEN_LOGS_TO_DISPLAY = 14;


AuctionCategories = {};

local function FindDeepestCategory(categoryIndex, ...)
	local categoryInfo = AuctionCategories[categoryIndex];
	for i = 1, select("#", ...) do
		local subCategoryIndex = select(i, ...);
		if categoryInfo and categoryInfo.subCategories and categoryInfo.subCategories[subCategoryIndex] then
			categoryInfo = categoryInfo.subCategories[subCategoryIndex];
		else
			break;
		end
	end
	return categoryInfo;
end

function AuctionFrame_GetDetailColumnString(categoryIndex, subCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex);
	return categoryInfo and categoryInfo:GetDetailColumnString() or REQ_LEVEL_ABBR;
end

function AuctionFrame_GetDetailColumnStringUnsafe(categoryIndex, subCategoryIndex)
	local categoryInfo = FindDeepestCategory(categoryIndex, subCategoryIndex);
	return categoryInfo and categoryInfo:GetDetailColumnStringUnsafe() or nil;
end

function AuctionFrame_CreateCategory(name)
	local category = CreateFromMixins(AuctionCategoryMixin);
	category.name = name;
	AuctionCategories[#AuctionCategories + 1] = category;
	return category;
end

AuctionCategoryMixin = {};

function AuctionCategoryMixin:SetDetailColumnString(detailColumnString)
	self.detailColumnString = detailColumnString;
end

function AuctionCategoryMixin:GetDetailColumnString()
	if self.detailColumnString then
		return self.detailColumnString;
	end
	if self.parent then
		return self.parent:GetDetailColumnString();
	end
	return REQ_LEVEL_ABBR;
end

function AuctionCategoryMixin:GetDetailColumnStringUnsafe()
	if self.detailColumnString then
		return self.detailColumnString;
	end
	if self.parent then
		return self.parent:GetDetailColumnStringUnsafe();
	end
	return nil;
end

function AuctionCategoryMixin:CreateSubCategory(classID, subClassID, inventoryType)
	local name = "subClassID";
	if inventoryType then
		name = GetItemInventorySlotInfo(inventoryType);
	elseif classID and subClassID then
		name = GetItemSubClassInfo(classID, subClassID);
	elseif classID then
		name = GetItemClassInfo(classID);
	end
	return self:CreateNamedSubCategory(name);
end

function AuctionCategoryMixin:CreateNamedSubCategory(name)
	self.subCategories = self.subCategories or {};

	local subCategory = CreateFromMixins(AuctionCategoryMixin);
	self.subCategories[#self.subCategories + 1] = subCategory;

	assert(name and #name > 0);
	subCategory.name = name;
	subCategory.parent = self;
	subCategory.sortIndex = #self.subCategories;
	return subCategory;
end

function AuctionCategoryMixin:CreateNamedSubCategoryAndFilter(name, classID, subClassID, inventoryType)
	local category = self:CreateNamedSubCategory(name);
	category:AddFilter(classID, subClassID, inventoryType);

	return category;
end

function AuctionCategoryMixin:CreateSubCategoryAndFilter(classID, subClassID, inventoryType)
	local category = self:CreateSubCategory(classID, subClassID, inventoryType);
	category:AddFilter(classID, subClassID, inventoryType);

	return category;
end

function AuctionCategoryMixin:AddBulkInventoryTypeCategories(classID, subClassID, inventoryTypes)
	for i, inventoryType in ipairs(inventoryTypes) do
		self:CreateSubCategoryAndFilter(classID, subClassID, inventoryType);
	end
end

function AuctionCategoryMixin:AddFilter(classID, subClassID, inventoryType)
	if not classID and not subClassID and not inventoryType then
		return;
	end

	self.filters = self.filters or {};
	self.filters[#self.filters + 1] = { classID = classID, subClassID = subClassID, inventoryType = inventoryType, };

	if self.parent then
		self.parent:AddFilter(classID, subClassID, inventoryType);
	end
end

do
	local function GenerateSubClassesHelper(self, classID, subClasses)
		for i = 1, #subClasses do
			local subClassID = subClasses[i];
			self:CreateSubCategoryAndFilter(classID, subClassID);
		end
	end

	function AuctionCategoryMixin:GenerateSubCategoriesAndFiltersFromSubClass(classID)
		GenerateSubClassesHelper(self, classID, C_AuctionHouse.GetAuctionItemSubClasses(classID));
	end
end

function AuctionCategoryMixin:FindSubCategoryByName(name)
	if self.subCategories then
		for i, subCategory in ipairs(self.subCategories) do
			if subCategory.name == name then
				return subCategory;
			end
		end
	end
end

function AuctionCategoryMixin:SortSubCategories()
	if self.subCategories then
		table.sort(self.subCategories, function(left, right)
			return left.sortIndex < right.sortIndex;
		end)
	end
end

function AuctionCategoryMixin:SetSortIndex(sortIndex)
	self.sortIndex = sortIndex
end

--[[
do
	for index, class in ipairs({GetAuctionItemClasses()}) do
		local categoty = AuctionFrame_CreateCategory(class)
		local subCategories = {GetAuctionItemSubClasses(index)}
		if #subCategories > 0 then
			for subIndex, subClass in ipairs(subCategories) do
				local subCategory = categoty:CreateNamedSubCategory(subClass)
				local invTypes = {GetAuctionInvTypes(index, subIndex)}
				if #invTypes > 0 then
					for invIndex, invType in pairs(invTypes) do
						if invIndex % 2 ~= 0 and invTypes[invIndex + 1] then
							subCategory:CreateNamedSubCategory(_G[invType])
						end
					end
				end
			end
		end
	end
end
]]

do -- Weapons
	local weaponsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_WEAPONS);
	weaponsCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);
	weaponsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_WEAPON);
end

do -- Armor
	local ArmorInventoryTypes = {
		Enum.InventoryType.IndexHeadType,
		Enum.InventoryType.IndexShoulderType,
		Enum.InventoryType.IndexChestType,
		Enum.InventoryType.IndexWaistType,
		Enum.InventoryType.IndexLegsType,
		Enum.InventoryType.IndexFeetType,
		Enum.InventoryType.IndexWristType,
		Enum.InventoryType.IndexHandType,
	};

	local armorCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_ARMOR);
	armorCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);

	local miscCategory = armorCategory:CreateSubCategory(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexHeadType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexNeckType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexBodyType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexFingerType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexTrinketType);
	miscCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_GENERIC, Enum.InventoryType.IndexHoldableType);

	local clothCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH);
	clothCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, ArmorInventoryTypes);

	clothCategory:CreateNamedSubCategoryAndFilter(INVTYPE_CLOAK, LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_CLOTH, Enum.InventoryType.IndexCloakType);

	local leatherCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER);
	leatherCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LEATHER, ArmorInventoryTypes);

	local mailCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL);
	mailCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_MAIL, ArmorInventoryTypes);

	local plateCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE);
	plateCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_PLATE, ArmorInventoryTypes);

	local cosmeticCategory = armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_COSMETIC);
	cosmeticCategory:AddBulkInventoryTypeCategories(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_COSMETIC, ArmorInventoryTypes);

	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SHIELD);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_LIBRAM);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_IDOL);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_TOTEM);
	armorCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_ARMOR, LE_ITEM_ARMOR_SIGIL);
end

do -- Containers
	local containersCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONTAINERS);
	containersCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_CONTAINER_SLOTS);
	containersCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_CONTAINER);
end

do -- Consumables
	local consumablesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_CONSUMABLES);
	consumablesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_REQUIRED_LEVEL);
	consumablesCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_CONSUMABLE);
end

do -- Glyphs
	local glyphsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GLYPHS);
	glyphsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_GLYPH);
end

do -- Trade Goods
	local tradeGoodsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_TRADE_GOODS);
	tradeGoodsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_TRADEGOODS);
end

do -- Ammo
	local ammoCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_AMMO);
	ammoCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_AMMO);
end

do -- Quiver
	local quiverCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUIVER);
	quiverCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_QUIVER);
end

do -- Recipes
	local recipesCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_RECIPES);
	recipesCategory:SetDetailColumnString(AUCTION_HOUSE_BROWSE_HEADER_RECIPE_SKILL);

	recipesCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_RECIPE);
end

do -- Gems
	local gemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_GEMS);
	gemsCategory:SetDetailColumnString(ITEM_LEVEL_ABBR);
	gemsCategory:GenerateSubCategoriesAndFiltersFromSubClass(LE_ITEM_CLASS_GEM);
end

do -- Miscellaneous
	local miscellaneousCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_MISCELLANEOUS);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_JUNK);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_REAGENT);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_PET);
	miscellaneousCategory:CreateSubCategoryAndFilter(8, 0); -- Toy
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_HOLIDAY);
	miscellaneousCategory:CreateSubCategoryAndFilter(LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_OTHER);
end

do -- Quest Items
	local questItemsCategory = AuctionFrame_CreateCategory(AUCTION_CATEGORY_QUEST_ITEMS);
	questItemsCategory:AddFilter(LE_ITEM_CLASS_QUESTITEM);
end

function AuctionHouseCategory_FindDeepest(categoryIndex, ...)
	local categoryInfo = AuctionCategories[categoryIndex];
	for i = 1, select("#", ...) do
		local subCategoryIndex = select(i, ...);
		if categoryInfo and categoryInfo.subCategories and categoryInfo.subCategories[subCategoryIndex] then
			categoryInfo = categoryInfo.subCategories[subCategoryIndex];
		else
			break;
		end
	end
	return categoryInfo;
end
