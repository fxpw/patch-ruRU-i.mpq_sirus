local C_StoreSecure = C_StoreSecure
local IsGMAccount = IsGMAccount
local IsInterfaceDevClient = IsInterfaceDevClient

local ITEM_RARITY_FALLBACK = 1
local SEARCH_UPDATE_ON_CHAR_DELAY = 0.3

local HEADERS_TYPE = {
	ICON = {
		sortType = Enum.Store.ProductSortType.None,
		name = STORE_SORT_RESET,
		dataProviderKey = "icon",
		template = "StoreProductListCellIconTemplate",
		width = 78,
		isResetAction = true,
	},
	NAME = {
		sortType = Enum.Store.ProductSortType.Name,
		name = STORE_PRODUCT_NAME_LABEL,
		dataProviderKey = "name",
		template = "StoreProductListCellNameTemplate",
	},
	DISCOUNT = {
		sortType = Enum.Store.ProductSortType.Discount,
		name = STORE_SORT_DISCOUNT,
		dataProviderKey = "originalPrice",
		width = 164,
		template = "StoreProductListCellSpecialTemplate",
	},
	ITEMLEVEL = {
		sortType = Enum.Store.ProductSortType.ItemLevel,
		name = STORE_SORT_ITEM_LEVEL,
		dataProviderKey = "itemLevel",
		width = 70,
		template = "StoreProductListCellItemLevelTemplate",
	},
	PVP = {
		sortType = Enum.Store.ProductSortType.PVP,
		name = STORE_SORT_PVP,
		dataProviderKey = "isPVP",
		width = 70,
		template = "StoreProductListCellPVPIconTemplate",
	},
	PRICE = {
		sortType = Enum.Store.ProductSortType.Price,
		name = STORE_SORT_PRICE,
		dataProviderKey = "price",
		width = 120,
		template = "StoreProductListCellPriceTemplate",
	},
}

local LIST_VIEW_HEADER = {
	DEFAULT = {
		HEADERS_TYPE.ICON,
		HEADERS_TYPE.NAME,
		HEADERS_TYPE.PRICE,
	},
	EQUIPMENT = {
		HEADERS_TYPE.ICON,
		HEADERS_TYPE.NAME,
		HEADERS_TYPE.ITEMLEVEL,
		HEADERS_TYPE.PVP,
		HEADERS_TYPE.PRICE,
	},
	DRESSUP = {
		HEADERS_TYPE.ICON,
		HEADERS_TYPE.NAME,
		HEADERS_TYPE.DISCOUNT,
		HEADERS_TYPE.PRICE,
	},
}

StoreItemListViewMixin = CreateFromMixins(StoreSubViewMixin)

function StoreItemListViewMixin:OnLoad()
	self.List.Scroll.ScrollBar:SetBackgroundShown(false)
	self.Filter.Scroll.ScrollBar:SetBackgroundShown(false)

	self.List.Scroll.ShadowOverlay:SetFrameLevelOffset(3)

	self.OnSortDirectionChange = function(this, reversed, userInput)
		if userInput then
			if this.isResetAction then
				self:ResetSortOrder()
			else
				self:SetSortOrder(this.sortType, reversed)
			end
		end
	end

	self.List.Scroll.update = function(scrollFrame)
		self:OnItemScrollUpdate()
	end
	self.List.Scroll.ScrollBar.doNotHide = true
	self.List.Scroll.scrollBar = self.List.Scroll.ScrollBar
	HybridScrollFrame_CreateButtons(self.List.Scroll, "StoreProductListRowButtonTemplate", 5, 0)

	self.headerButtons = {}
	self.itemButtons = {}
	self.filterHolders = {}

	self.filterOptionPoolCollection = CreateFramePoolCollection()
	self.filterOptionHolder = self.filterOptionPoolCollection:CreatePool("Frame", self.Filter.Scroll.ScrollChild, "StoreProductFilterHolder", function(framePool, frame)
		frame:Hide()
		frame:ClearAllPoints()
		frame:Clear()
	end, nil, function(frame)
		frame:SetOwner(self)
	end)
	self.filterOptionEditBox = self.filterOptionPoolCollection:CreatePool("EditBox", self.Filter.Scroll.ScrollChild, "StoreProductFilterEditBoxTemplate", function(framePool, frame)
		frame:Hide()
		frame:ClearAllPoints()
		frame.OPTION_KEY = nil
		frame.nextEditBox = nil
		frame.value = nil
		frame:ToggleOnCharFilter(false)
	end)
	self.filterOptionEditBoxNumeric = self.filterOptionPoolCollection:CreatePool("EditBox", self.Filter.Scroll.ScrollChild, "StoreProductFilterNumericEditBoxTemplate", function(framePool, frame)
		frame:Hide()
		frame:ClearAllPoints()
		frame.OPTION_KEY = nil
		frame.nextEditBox = nil
		frame.value = nil
	end)
	self.filterOptionCheckButton = self.filterOptionPoolCollection:CreatePool("CheckButton", self.Filter.Scroll.ScrollChild, "StoreProductFilterCheckButtonTemplate", function(framePool, frame)
		frame:Hide()
		frame:ClearAllPoints()
		frame.OPTION_KEY = nil
		frame.OPTION_KEY_INDEX = nil
		frame.FLAG = nil
		frame.value = nil
	end)
	self.filterOptionRadioButton = self.filterOptionPoolCollection:CreatePool("CheckButton", self.Filter.Scroll.ScrollChild, "StoreProductFilterRadioButtonTemplate", function(framePool, frame)
		frame:Hide()
		frame:ClearAllPoints()
		frame.OPTION_KEY = nil
		frame.FLAG = nil
		frame.value = nil
	end)

	self.Filter.Scroll.ShadowTop:SetAtlas("PKBT-Background-Shadow-Small-Top", true)
	self.Filter.Scroll.ShadowBottom:SetAtlas("PKBT-Background-Shadow-Small-Bottom", true)
	self.Filter.Scroll.ShadowLeft:SetAtlas("PKBT-Background-Shadow-Small-Left", true)
	self.Filter.Scroll.ShadowRight:SetAtlas("PKBT-Background-Shadow-Small-Right", true)

	self.Filter.Scroll.ScrollChild.ResetButton:AddTextureAtlas("PKBT-Icon-Refresh", true)
	self.Filter.Scroll.ScrollChild.ResetButton:AddText(STORE_FILTER_RESET)

	self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.List.Scroll))
	self.tableBuilder:SetHeaderContainer(self.List.Header.HeaderHolder)

	self.DressUp:SetRotateEnabled(true)
--	self.DressUp:SetZoomEnabled(true)
--	self.DressUp:SetPanningEnabled(true)
	self.DressUp.onClose = function(this)
		self:ToggleDressUp(false)
	end
	self.DressUp.PurchaseButton:SetAllowReplenishment(C_StoreSecure.IsBonusReplenishmentAllowed(), false)
	self.isDressUpShown = false

	self.AnnonceBlock.OnCountdownFinish = function(this)
		self:UpdateView(false)
	end

	Mixin(self.PageHeader, PKBT_OwnerMixin, PKBT_CountdownThrottledBaseMixin)
	self.PageHeader:SetOwner(self)
	self.PageHeader.Background:SetSubTexCoord(0, 1, 1, 0)

	self.PageHeader.OnCountdownUpdate = function(this, timeLeft, timerFinished)
		if timeLeft > 0 and not timerFinished then
			self.PageHeader.Timer:SetFormattedText(STORE_REFRESH_PRODUCTS_INFO_SHORT_FORMAT, GetRemainingTime(timeLeft))
			self.PageHeader.Timer:Show()
			self.PageHeader.TimerIcon:Show()
		else
			self.PageHeader.Timer:Hide()
			self.PageHeader.TimerIcon:Hide()
		end
	end

	self.PageHeader.RefreshButton:AddTextureAtlas("PKBT-Icon-Refresh", true)
	self.PageHeader.RefreshButton:AddText(STORE_REFRESH_PRODUCTS)

	self:RegisterViewMode(Enum.StoreViewMode.ItemList)

	self:RegisterCustomEvent("STORE_PRODUCT_LIST_UPDATE")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_SORT_UPDATE")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_FILTER_UPDATE")
	self:RegisterCustomEvent("STORE_PRODUCT_LIST_RENEW")
	self:RegisterCustomEvent("STORE_GLOBAL_DISCOUNT_UPDATE")
	self:RegisterCustomEvent("STORE_RANDOM_ITEM_POLL_UPDATE")
end

function StoreItemListViewMixin:GetRowProvider()
	if not self.rowProvider then
		self.rowProvider = function(itemIndex)
			if itemIndex > self.numItems then
				return nil
			end

			local name, link, rarity, icon, itemLevel, amount, isPVP, isNew, isUnavailable, isRollableUnavailable, noPurchaseCanGift, productID, price, originalPrice, currencyType = C_StoreSecure.GetCategoryProductInfo(self.categoryIndex, self.subCategoryIndex, itemIndex)
			return {
				name = name,
				link = link,
				rarity = rarity,
				icon = icon,
				amount = amount,
				itemLevel = itemLevel,
				isPVP = isPVP,
				isNew = isNew,
				isUnavailable = isUnavailable,
				isRollableUnavailable = isRollableUnavailable,
				noPurchaseCanGift = noPurchaseCanGift,
				productID = productID,
				price = price,
				originalPrice = originalPrice,
				currencyType = currencyType,
			}
		end
	end
	return self.rowProvider
end

function StoreItemListViewMixin:GetItemListHeader()
	if self.categoryIndex == Enum.Store.Category.Equipment then
		return LIST_VIEW_HEADER.EQUIPMENT
	else
		return LIST_VIEW_HEADER.DEFAULT
	end
end

function StoreItemListViewMixin:ConstructTable()
	local textPadding = 1
	local cellPadding = 10

	self.tableBuilder:Reset()
	self.tableBuilder:SetDataProvider(self:GetRowProvider())
	self.tableBuilder:SetTableMargins(5)
	self.tableBuilder:SetTableWidth(self:GetScrollChildWidth())

	for index, columnInfo in ipairs(self:GetItemListHeader()) do
		local column = self.tableBuilder:AddColumn()
		column:ConstructHeader("Button", "StoreProductListHeaderButtonTemplate", columnInfo.name, columnInfo.sortType, columnInfo.isResetAction)
		column:ConstrainToHeader(textPadding)
		column:ConstructCells("Frame", columnInfo.template)

		if columnInfo.width then
			column:SetFixedConstraints(columnInfo.width, cellPadding)
		else
			column:SetFillConstraints(1, cellPadding)
		end

		column:GetHeaderFrame().OnDirectionChange = self.OnSortDirectionChange
	end

	self.tableBuilder:Arrange()
end

function StoreItemListViewMixin:UpdateHeaderArrows()
	local sortType, reversed = C_StoreSecure.GetCategoryProductSortType(self.categoryIndex, self.subCategoryIndex)
	for index, column in ipairs(self.tableBuilder:GetColumns()) do
		local header = column:GetHeaderFrame()
		if not header.isResetAction and header.sortType == sortType then
			header:SetReversed(reversed)
		else
			header:ClearDirection()
		end
	end
end

function StoreItemListViewMixin:OnEvent(event, ...)
	if not self:IsVisible() then
		self.dirty = true
		return
	end

	if event == "STORE_PRODUCT_LIST_UPDATE" then
		local categoryIndex, subCategoryIndex = ...
		if self.categoryIndex == categoryIndex and self.subCategoryIndex == subCategoryIndex then
			self:UpdateView(true)
		end
	elseif event == "STORE_PRODUCT_LIST_SORT_UPDATE" then
		local categoryIndex, subCategoryIndex = ...
		if self.categoryIndex == categoryIndex and self.subCategoryIndex == subCategoryIndex then
			self:UpdateHeaderArrows()
			self:OnItemScrollUpdate()
		end
	elseif event == "STORE_PRODUCT_LIST_FILTER_UPDATE" then
		local categoryIndex, subCategoryIndex, cacheReceived = ...
		if self.categoryIndex == categoryIndex and self.subCategoryIndex == subCategoryIndex then
			self:UpdateFilters(cacheReceived)
			self:OnItemScrollUpdate(cacheReceived)
		end
	elseif event == "STORE_PRODUCT_LIST_LOADING" then
		local categoryIndex, subCategoryIndex = ...
		if self.categoryIndex == categoryIndex and self.subCategoryIndex == subCategoryIndex then
			self.Loading:Show()
		end
	elseif event == "STORE_PRODUCT_LIST_RENEW" then
		local categoryIndex, subCategoryIndex = ...
		if self.categoryIndex == categoryIndex then
			if not subCategoryIndex or self.subCategoryIndex == subCategoryIndex then
				self:UpdateView(false)
			end
		end
	elseif event == "STORE_GLOBAL_DISCOUNT_UPDATE" then
		self:UpdateView(false)
	elseif event == "STORE_RANDOM_ITEM_POLL_UPDATE" then
		self:UpdateReRollTimer()
	end
end

function StoreItemListViewMixin:OnShow()
	StoreSubViewMixin.OnShow(self)

	SetParentFrameLevel(self.List.Header, 5)
	SetParentFrameLevel(self.List.NoProduct, 8)
	SetParentFrameLevel(self.PageHeader, 7)
	SetParentFrameLevel(self.Loading, 12)

	self.Loading:Show()

	self.dirty = true
	self.List.Scroll.ScrollBar:SetValue(0)
	self.Filter.Scroll:SetVerticalScroll(0)
	self:ClearList()
end

function StoreItemListViewMixin:OnHide()
	StoreSubViewMixin.OnHide(self)
	self.Loading:Hide()
end

function StoreItemListViewMixin:ClearList()
	for index, button in ipairs(self.List.Scroll.buttons) do
		button:Hide()
	end
end

function StoreItemListViewMixin:SetViewCategory(categoryIndex, subCategoryIndex)
	self.categoryIndex = categoryIndex
	self.subCategoryIndex = subCategoryIndex

	self.Loading:Show()
	self:ToggleDressUp(false, true)

	if categoryIndex == Enum.Store.Category.Transmogrification and subCategoryIndex ~= 3 then
		self.isPageHeaderShown = true
	else
		self.isPageHeaderShown = nil
	end

	local selectedCategoryIndex, selectedSubCategoryIndex = C_StoreSecure.GetSelectedCategory()
	if selectedCategoryIndex ~= categoryIndex or selectedSubCategoryIndex ~= subCategoryIndex then
		self:ClearList()
		C_StoreSecure.SetSelectedCategory(categoryIndex, subCategoryIndex)
	else
		self:UpdateView()
	end
end

function StoreItemListViewMixin:UpdateView(cacheReceived)
	self.dirty = true

	local discountAmount, discountTimeLeft = C_StoreSecure.GetCategoryGlobalDiscount(self.categoryIndex, self.subCategoryIndex)
	if discountAmount then
		self.List:SetPoint("TOPLEFT", self.AnnonceBlock, "BOTTOMLEFT", 0, 0)
		self.Filter:SetPoint("TOPRIGHT", self.AnnonceBlock, "BOTTOMRIGHT", 0, 0)
		self.AnnonceBlock:SetHeader(string.format(STORE_GLOBAL_DISCOUNT_LABEL, discountAmount))
		self.AnnonceBlock:SetAnnonceCountdown(discountTimeLeft)
		self.AnnonceBlock:Show()
	else
		self.List:SetPoint("TOPLEFT", 0, 0)
		self.Filter:SetPoint("TOPRIGHT", 0, 0)
		self.AnnonceBlock:Hide()
	end

	if self.isPageHeaderShown then
		local name, icon, isNew, enabled, reason = C_StoreSecure.GetCategoryInfo(self.categoryIndex, self.subCategoryIndex)
		self.PageHeader:SetLabel(name)
		self.PageHeader:Show()
		self:UpdateReRollTimer()
	else
		self.PageHeader:Hide()
	end

	if self.isDressUpShown then
		if discountAmount then
			self.DressUp:SetPoint("TOPRIGHT", self.AnnonceBlock, "BOTTOMRIGHT", 0, 0)
		else
			self.DressUp:SetPoint("TOPRIGHT", 0, 0)
		end

		if self.isPageHeaderShown then
			self.PageHeader:SetPoint("BOTTOMRIGHT", self.DressUp, "BOTTOMLEFT", -3, 0)
			self.List:SetPoint("BOTTOMRIGHT", self.PageHeader, "TOPRIGHT", 0, -2)
			self.List.NineSliceInset:SetPoint("BOTTOMRIGHT", self.PageHeader, "BOTTOMRIGHT", 0, 0)
		else
			self.List:SetPoint("BOTTOMRIGHT", self.DressUp, "BOTTOMLEFT", -3, 0)
			self.List.NineSliceInset:SetPoint("BOTTOMRIGHT", self.List, "BOTTOMRIGHT", 0, 0)
		end

		self.Filter:Hide()
		self.DressUp:Show()
	elseif C_StoreSecure.IsCategoryProductFiltersAvailable(self.categoryIndex, self.subCategoryIndex) then
		if self.isPageHeaderShown then
			self.PageHeader:SetPoint("BOTTOMRIGHT", self.Filter, "BOTTOMLEFT", -3, 0)
			self.List:SetPoint("BOTTOMRIGHT", self.PageHeader, "TOPRIGHT", 0, -2)
			self.List.NineSliceInset:SetPoint("BOTTOMRIGHT", self.PageHeader, "BOTTOMRIGHT", 0, 0)
		else
			self.List:SetPoint("BOTTOMRIGHT", self.Filter, "BOTTOMLEFT", -3, 0)
			self.List.NineSliceInset:SetPoint("BOTTOMRIGHT", self.List, "BOTTOMRIGHT", 0, 0)
		end
		self.Filter:Show()
		self.DressUp:Hide()
		self:UpdateFilters(cacheReceived)
	else
		if self.isPageHeaderShown then
			self.PageHeader:SetPoint("BOTTOMRIGHT", self.Filter, "BOTTOMLEFT", -3, 0)
			self.List:SetPoint("BOTTOMRIGHT", self.PageHeader, "TOPRIGHT", 0, -2)
			self.List.NineSliceInset:SetPoint("BOTTOMRIGHT", self.PageHeader, "BOTTOMRIGHT", 0, 0)
		else
			self.List:SetPoint("BOTTOMRIGHT", self.Filter, "BOTTOMRIGHT", -3, 0)
			self.List.NineSliceInset:SetPoint("BOTTOMRIGHT", self.List, "BOTTOMRIGHT", 0, 0)
		end
		self.Filter:Hide()
		self.DressUp:Hide()
	end

	self:UpdateViewTable()

	self.Loading:SetShown(not C_StoreSecure.IsCategoryProductsLoaded(self.categoryIndex, self.subCategoryIndex))
end

function StoreItemListViewMixin:UpdateViewTable()
	self.List.Scroll.ScrollChild:SetWidth(self:GetScrollChildWidth())
	self.List.Scroll:UpdateScrollChildRect()
	self:ConstructTable()
	self:OnItemScrollUpdate()
	self:UpdateHeaderArrows()
end

function StoreItemListViewMixin:GetScrollChildWidth()
	local scrollOffsetX = select(4, self.List.Scroll:GetPoint(2)) or 32
	if self.isPageHeaderShown then
		local listOffsetX = select(4, self.PageHeader:GetPoint(2)) or 3
		return (select(3, self.PageHeader:GetRect()) or 0) + (scrollOffsetX + listOffsetX)
	else
		local listOffsetX = select(4, self.List:GetPoint(2)) or 3
		return (select(3, self.List:GetRect()) or 0) + (scrollOffsetX + listOffsetX)
	end
end

function StoreItemListViewMixin:OnItemScrollUpdate(cacheReceived)
	local scrollFrame = self.List.Scroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local numItems = C_StoreSecure.GetNumCategoryProducts(self.categoryIndex, self.subCategoryIndex)

	if self.numItems ~= numItems then
		self.numItems = numItems
		self.dirty = true
	end

	local populateCount = math.min(#scrollFrame.buttons, numItems)
	self.tableBuilder:Populate(offset, populateCount)

	local mouseFocus = GetMouseFocus()
	for index, button in ipairs(scrollFrame.buttons) do
		button:SetOwner(self)
		button:SetShown(index <= numItems)
		if button == mouseFocus then
			button:OnEnter()
		end
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		self.List:GetRect()
		HybridScrollFrame_Update(scrollFrame, buttonHeight * numItems, scrollFrame:GetHeight())

		if numItems > 0 then
			if self.categoryIndex == Enum.Store.Category.Referral then
				local itemIndex = 1
				local name, link, rarity, icon, itemLevel, amount, isPVP, isNew, isUnavailable, isRollableUnavailable, noPurchaseCanGift, productID, price, originalPrice, currencyType = C_StoreSecure.GetCategoryProductInfo(self.categoryIndex, self.subCategoryIndex, itemIndex)
				local allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton = false, true, false, true
				self:ShowProductDressUp(productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
			end
		end

		self.dirty = nil
	end

	local isLoaded = C_StoreSecure.IsCategoryProductsLoaded(self.categoryIndex, self.subCategoryIndex)
	self.List.NoProduct:SetShown(isLoaded and numItems == 0)
	self.Loading:SetShown(not isLoaded)
end

function StoreItemListViewMixin:OnItemClick(item)
	if IsAltKeyDown() and C_StoreSecure.AddProductItems(item.productID) then
		return
	end
	if IsModifiedClick("CHATLINK") then
	--	local link = C_StoreSecure.GenerateProductHyperlink(item.productID)
		if item.itemLink then
			ChatEdit_InsertLink(item.itemLink)
			return
		end
	elseif self.categoryIndex == Enum.Store.Category.Referral then
		local allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton = false, true, false, true
		local success = self:ShowProductDressUp(item.productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
		if success then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		return
	elseif self.categoryIndex == Enum.Store.Category.Transmogrification then
		local allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton = true, true, true, true
		local success = self:ShowProductDressUp(item.productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
		if success then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end
		return
	elseif IsModifiedClick("DRESSUP") then
		local linkType, id, collectionID = GetDressUpItemLinkInfo(item.itemLink)
		if linkType == Enum.DressUpLinkType.LootCase then
			LootCasePreviewFrame:SetPreview(id)
			LootCasePreviewFrame:Show()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		else
			local allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton = true, true, false, false

			if self.categoryIndex == Enum.Store.Category.Equipment and self.subCategoryIndex == 1 then
				allowPortraitCamera = true
			end

			local success = self:ShowProductDressUp(item.productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
			if success then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			end
		end
		return
	end

	C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(item.productID)
	PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
end

function StoreItemListViewMixin:ShowProductDressUp(productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
	local success = self.DressUp:SetProduct(productID, allowToHide, allowEquipmentToggle, allowPortraitCamera, showPurchaseButton)
	if success then
		self:ToggleDressUp(true)
	end
	return success
end

function StoreItemListViewMixin:HideDressUp(productID)
	self.List:SetPoint("BOTTOMRIGHT", "$parentFilter", "BOTTOMLEFT", -3, 0)
	self.Filter:Show()
	self.DressUp:Hide()
end

function StoreItemListViewMixin:ToggleDressUp(state, skipUpdate)
	state = not not state

	if self.isDressUpShown == state then
		return
	end

	self.isDressUpShown = state

	if not skipUpdate then
		self:UpdateView()
	end
end

function StoreItemListViewMixin:IsFilterOptionListChanged(cacheReceived)
	local filterType, hasDynamicOptions = C_StoreSecure.GetCategoryProductFilterOptionTypes(self.categoryIndex, self.subCategoryIndex)

	if self.filterType == filterType
	and not hasDynamicOptions
	and not cacheReceived
	and self.filterCategoryIndex == self.categoryIndex and self.filterSubCategoryIndex == self.subCategoryIndex
	then
		return false
	end

	local _, filterOptionList = C_StoreSecure.GetCategoryProductFilterOptions(self.categoryIndex, self.subCategoryIndex)

	if not self.filterOptionList or #self.filterOptionList ~= #filterOptionList then
		return true, filterType, filterOptionList
	end

	for filterIndex, filterTypeData in ipairs(filterOptionList) do
		local cachedFilter = self.filterOptionList[filterIndex]
		if filterTypeData.type ~= cachedFilter.type or #filterTypeData.options ~= #cachedFilter.options
		or (filterTypeData.type == Enum.Store.ProductFilterOption.ITEM_LEVEL_RANGE and (filterTypeData.minValue ~= cachedFilter.minValue or filterTypeData.maxValue ~= cachedFilter.maxValue))
		or (filterTypeData.type == Enum.Store.ProductFilterOption.PRODUCT_PRICE_RANGE and (filterTypeData.minValue ~= cachedFilter.minValue or filterTypeData.maxValue ~= cachedFilter.maxValue))
		then
			return true, filterType, filterOptionList
		end
	end

	return false
end

function StoreItemListViewMixin:UpdateFilters(cacheReceived)
	local optionListChanged, filterType, filterOptionList = self:IsFilterOptionListChanged(cacheReceived)
	if not optionListChanged then
		self:UpdateFilterValues()
		self:UpdateFilterHeaders()
		return
	end

	self.filterOptionPoolCollection:ReleaseAll()
	table.wipe(self.filterHolders)

	self.filterCategoryIndex = self.categoryIndex
	self.filterSubCategoryIndex = self.subCategoryIndex
	self.filterType = filterType
	self.filterOptionList = filterOptionList

	local numOptionTypes = #filterOptionList
	local scrollHeight = 40

	for filterIndex, filterTypeData in ipairs(filterOptionList) do
		local holder = self.filterOptionHolder:Acquire()
		holder:SetID(filterIndex)
		holder:ClearAllPoints()
		holder.type = filterTypeData.type
		holder.isBitMask = filterTypeData.isBitField
		holder.isValTable = filterTypeData.isValTable
		holder.invertedFilter = filterTypeData.invertedFilter
		holder.hintText = filterTypeData.hintText
		holder.isRadioButton = nil
		holder.Hint:SetShown(holder.hintText)

		if filterIndex == 1 then
			holder:SetPoint("TOPLEFT", 0, -50)
		else
			holder:SetPoint("TOPLEFT", self.filterHolders[filterIndex - 1], "BOTTOMLEFT", 0, -5)
		end

		holder:SetPoint("RIGHT", 0, 0)

		if filterTypeData.type == Enum.Store.ProductFilterOption.SEARCH_NAME then
			holder:SetLabel("")

			local optionKey, optionName = unpack(filterTypeData.options, 1, 2)
			local editBox = self.filterOptionEditBox:Acquire()
			editBox:SetID(1)
			editBox.OPTION_KEY = optionKey
			editBox:SetInstructions(optionName)

			local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, editBox.OPTION_KEY)
			editBox.value = value
			editBox:SetText(value)

			editBox:Show()
			editBox:ToggleOnCharFilter(true, SEARCH_UPDATE_ON_CHAR_DELAY)

			holder:AddOptionWidget(editBox, false, true)
		elseif filterTypeData.type == Enum.Store.ProductFilterOption.NON_CLASS_ITEMS
		or filterTypeData.type == Enum.Store.ProductFilterOption.NEW_PRODUCT
		then
			holder:SetLabel("")

			local optionKey, optionName = unpack(filterTypeData.options, 1, 2)

			local checkButton = self.filterOptionCheckButton:Acquire()
			checkButton:SetID(1)
			checkButton.OPTION_KEY = optionKey
			checkButton:SetText(optionName)

			local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, optionKey)
			checkButton.value = value
			checkButton:SetChecked(value)
			checkButton:Show()

			holder:AddOptionWidget(checkButton)
		elseif filterTypeData.type == Enum.Store.ProductFilterOption.RARITY
		or filterTypeData.type == Enum.Store.ProductFilterOption.ARMOR_SUB_CLASS
		or filterTypeData.type == Enum.Store.ProductFilterOption.WEAPON_SUB_CLASS
		then
			holder:SetLabel(filterTypeData.name)

			for optionIndex, optionData in ipairs(filterTypeData.options) do
				local optionKey, optionName, flag = unpack(optionData, 1, filterTypeData.isBitField and 3 or 2)
				local checkButton = self.filterOptionCheckButton:Acquire()
				checkButton:SetID(optionIndex)
				checkButton.OPTION_KEY = optionKey
				checkButton.FLAG = flag
				checkButton:SetText(optionName)

				local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, optionKey)
				checkButton.value = bit.band(value, flag) ~= 0
				checkButton:SetChecked(checkButton.value)
				checkButton:Show()

				holder:AddOptionWidget(checkButton)
			end
		elseif filterTypeData.type == Enum.Store.ProductFilterOption.ITEM_STATS then
			holder:SetLabel(filterTypeData.name)

			for optionIndex, optionData in ipairs(filterTypeData.options) do
				local optionKey, optionName, optionKeyIndex = unpack(optionData, 1, filterTypeData.isValTable and 3 or 2)
				local checkButton = self.filterOptionCheckButton:Acquire()
				checkButton:SetID(optionIndex)
				checkButton.OPTION_KEY = optionKey
				checkButton.OPTION_KEY_INDEX = optionKeyIndex
				checkButton:SetText(optionName)

				local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, optionKey, optionKeyIndex)
				checkButton.value = value or false
				checkButton:SetChecked(checkButton.value)
				checkButton:Show()

				holder:AddOptionWidget(checkButton)
			end
		elseif filterTypeData.type == Enum.Store.ProductFilterOption.CLASS then
			holder:SetLabel(filterTypeData.name)
			holder.isRadioButton = true

			for optionIndex, optionData in ipairs(filterTypeData.options) do
				local optionKey, optionName, flag = unpack(optionData, 1, filterTypeData.isBitField and 3 or 2)
				local radioButton = self.filterOptionRadioButton:Acquire()
				radioButton:SetID(optionIndex)
				radioButton.OPTION_KEY = optionKey
				radioButton.FLAG = flag
				radioButton:SetText(optionName)

				local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, optionKey)
				radioButton.value = bit.band(value, flag) ~= 0
				radioButton:SetChecked(radioButton.value)
				radioButton:Show()

				holder:AddOptionWidget(radioButton)
			end
		elseif filterTypeData.type == Enum.Store.ProductFilterOption.ITEM_LEVEL_RANGE
		or filterTypeData.type == Enum.Store.ProductFilterOption.PRODUCT_PRICE_RANGE
		then
			local maxLetters
			if filterTypeData.type == Enum.Store.ProductFilterOption.ITEM_LEVEL_RANGE then
				maxLetters = 3
			else
				maxLetters = 5
			end

			holder:SetLabel(filterTypeData.name)

			for optionIndex, optionData in ipairs(filterTypeData.options) do
				local optionKey, optionName = unpack(optionData, 1, 2)

				local widget = self.filterOptionEditBoxNumeric:Acquire()
				widget:SetID(optionIndex)
				widget.OPTION_KEY = optionKey
				widget:SetWidth(111)
				widget:SetInstructions(string.format("%s %s", optionName, filterTypeData[optionIndex == 1 and "minValue" or "maxValue"] or ""))
				widget:SetMaxLetters(maxLetters)

				local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, optionKey)
				widget.value = value
				widget:SetValue(value)

				if filterTypeData.isRange and optionIndex == 2 then
					widget:SetPoint("TOPLEFT", holder:GetWidgets()[optionIndex - 1], "TOPRIGHT", 20, 0)
					holder:AddOptionWidget(widget, true)
				else
					holder:AddOptionWidget(widget)
				end

				widget:Show()
			end

			local widgets = holder:GetWidgets()
			widgets[1].nextEditBox = widgets[2]
			widgets[2].nextEditBox = widgets[1]
		end

		local isValueChanged = C_StoreSecure.IsCategoryProductFilterOptionValueChanged(self.categoryIndex, self.subCategoryIndex, filterTypeData.type)
		holder:SetResetAvailable(isValueChanged)

		holder.Divider:SetShown(filterIndex ~= numOptionTypes)
		holder:Show()
		self.filterHolders[filterIndex] = holder
		scrollHeight = scrollHeight + holder:GetHeight()
	end

	self:UpdateFilterHeaders()

	self.Filter.Scroll.ScrollChild:SetSize(self.Filter.Scroll:GetWidth(), scrollHeight)
	self.Filter.Scroll:UpdateScrollChildRect()
end

function StoreItemListViewMixin:UpdateFilterValues()
	for filterIndex, filterTypeData in ipairs(self.filterOptionList) do
		local holder = self.filterHolders[filterIndex]
		for optionIndex, widget in ipairs(holder:GetWidgets()) do
			local value = C_StoreSecure.GetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, widget.OPTION_KEY, widget.OPTION_KEY_INDEX)
			if widget.FLAG then
				value = bit.band(value, widget.FLAG) ~= 0
			end

			if filterTypeData.type == Enum.Store.ProductFilterOption.SEARCH_NAME then
				widget.value = value
				widget:SetText(value)
			elseif filterTypeData.type == Enum.Store.ProductFilterOption.NON_CLASS_ITEMS
			or filterTypeData.type == Enum.Store.ProductFilterOption.NEW_PRODUCT
			or filterTypeData.type == Enum.Store.ProductFilterOption.RARITY
			or filterTypeData.type == Enum.Store.ProductFilterOption.ARMOR_SUB_CLASS
			or filterTypeData.type == Enum.Store.ProductFilterOption.WEAPON_SUB_CLASS
			or filterTypeData.type == Enum.Store.ProductFilterOption.ITEM_STATS
			or filterTypeData.type == Enum.Store.ProductFilterOption.CLASS
			then
				widget.value = value
				widget:SetChecked(value)
			elseif filterTypeData.type == Enum.Store.ProductFilterOption.ITEM_LEVEL_RANGE
			or filterTypeData.type == Enum.Store.ProductFilterOption.PRODUCT_PRICE_RANGE
			then
				widget.value = value
				widget:SetValue(value)
			end
		end
	end
end

function StoreItemListViewMixin:UpdateFilterHeaders()
	for filterIndex, filterTypeData in ipairs(self.filterOptionList) do
		local holder = self.filterHolders[filterIndex]
		local isValueChanged = C_StoreSecure.IsCategoryProductFilterOptionValueChanged(self.categoryIndex, self.subCategoryIndex, filterTypeData.type)
		holder:SetResetAvailable(isValueChanged)
	end
end

function StoreItemListViewMixin:SetSortOrder(sortType, reversed)
	if self.sortType ~= sortType or self.sortReversed ~= reversed then
		C_StoreSecure.SetCategoryProductSortType(self.categoryIndex, self.subCategoryIndex, sortType, reversed)
	end
end

function StoreItemListViewMixin:ResetSortOrder()
	C_StoreSecure.ResetCategoryProductSortType(self.categoryIndex, self.subCategoryIndex)
end

function StoreItemListViewMixin:FilterApplied(filterIndex, optionIndex, key, value, optionKeyIndex)
	C_StoreSecure.SetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, key, value, optionKeyIndex)
end

function StoreItemListViewMixin:ResetFilterOption(filterIndex, optionType)
	C_StoreSecure.ResetCategoryProductFilterOptionValue(self.categoryIndex, self.subCategoryIndex, optionType)
end

function StoreItemListViewMixin:OnResetFiltersClick(button)
	C_StoreSecure.ResetCategoryProductFilters(self.categoryIndex, self.subCategoryIndex)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function StoreItemListViewMixin:UpdateReRollTimer()
	if self.PageHeader:IsShown() then
		local timeLeft, isRefreshAvailable = C_StoreSecure.GetTransmogRefrestTimeLeft()
		if timeLeft > 0 then
			self.PageHeader.RefreshButton:SetEnabled(isRefreshAvailable)
			self.PageHeader.RefreshButton:Show()
		else
			self.PageHeader.RefreshButton:Disable()
			self.PageHeader.RefreshButton:Hide()
		end
		self.PageHeader:SetTimeLeft(isRefreshAvailable and timeLeft or 0)
	end
end

function StoreItemListViewMixin:OnReRollClick(button)
	if self.categoryIndex == Enum.Store.Category.Transmogrification then
		local productID = C_StoreSecure.GetRefreshTransmogProductID()
		assert(productID, "No product id for category refresh")
		C_StoreSecure.GetStoreFrame():ShowProductPurchaseDialog(productID)
		PlaySound(SOUNDKIT.UI_IG_STORE_BUY_BUTTON)
	end
end

local SORT_DIRECTION = {
	None = 0,
	Ascending = 1,
	Descending = 2,
}

StoreProductListHeaderButtonMixin = CreateFromMixins(TableBuilderElementMixin)

function StoreProductListHeaderButtonMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-SortHeader-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-SortHeader-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-SortHeader-Background-Center")

	self.Arrow:SetPoint("LEFT", self.ButtonText, "RIGHT", -2, 0)

	self.direction = SORT_DIRECTION.None
end

function StoreProductListHeaderButtonMixin:OnClick(button)
	if self.isResetAction then
		self:FireDirectionChangeScript(true)
	else
		self:ChangeDirection(true)
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

function StoreProductListHeaderButtonMixin:Init(name, sortType, isResetAction)
	self.sortType = sortType
	self.isResetAction = isResetAction
	self:SetText(name)
	self:SetDirection(SORT_DIRECTION.None)
end

function StoreProductListHeaderButtonMixin:SetReversed(reversed, userInput, force)
	local direction = reversed and SORT_DIRECTION.Descending or SORT_DIRECTION.Ascending
	self:SetDirection(direction, userInput, force)
end

function StoreProductListHeaderButtonMixin:ChangeDirection(userInput, force)
	if self.direction == SORT_DIRECTION.None or self.direction == SORT_DIRECTION.Descending then
		self:SetDirection(SORT_DIRECTION.Ascending, userInput, force)
	else
		self:SetDirection(SORT_DIRECTION.Descending, userInput, force)
	end
end

function StoreProductListHeaderButtonMixin:SetDirection(direction, userInput, force)
	if self.direction == direction then
		if force then
			self:FireDirectionChangeScript(userInput)
		end
		return
	end

	if direction == SORT_DIRECTION.None then
		self:ClearDirection(userInput, force)
		return
	end

	self.direction = direction
	self.ButtonText:SetPoint("CENTER", -4, 2)
	self.Arrow:Show()

	if direction == SORT_DIRECTION.None or direction == SORT_DIRECTION.Descending then
		self.Arrow:SetAtlas("PKBT-Arrow-Down", true)
	else
		self.Arrow:SetAtlas("PKBT-Arrow-Up", true)
	end

	self:FireDirectionChangeScript(userInput)
end

function StoreProductListHeaderButtonMixin:ClearDirection(userInput, force)
	local changed
	if self.direction ~= SORT_DIRECTION.None then
		self.ButtonText:SetPoint("CENTER", 0, 2)
		self.Arrow:Hide()
		self.direction = SORT_DIRECTION.None
		changed = true
	end

	if changed or force then
		self:FireDirectionChangeScript(userInput)
	end
end

function StoreProductListHeaderButtonMixin:FireDirectionChangeScript(userInput)
	if type(self.OnDirectionChange) == "function" then
		local isReversed = self.direction ~= SORT_DIRECTION.Ascending
		self.OnDirectionChange(self, isReversed, userInput)
	end
end

StoreProductListRowButtonMixin = CreateFromMixins(PKBT_OwnerMixin, TableBuilderRowMixin)

function StoreProductListRowButtonMixin:OnLoad()
	self.BackgroundLeft:SetAtlas("PKBT-Store-ItemPlate-Background-Left", true)
	self.BackgroundRight:SetAtlas("PKBT-Store-ItemPlate-Background-Right", true)
	self.BackgroundCenter:SetAtlas("PKBT-Store-ItemPlate-Background-Center")
	self.NewIndicator:SetAtlas("PKBT-Icon-New-CornerTopRight-GreenW", true)

	self:RegisterCustomEvent("STORE_FAVORITE_UPDATE")

	self.UpdateTooltip = self.OnEnter
end

function StoreProductListRowButtonMixin:OnEvent(event, ...)
	if event == "STORE_FAVORITE_UPDATE" then
		if self.productID and self:IsShown() then
			self:UpdateFavorite()
		end
	end
end

function StoreProductListRowButtonMixin:OnHide()
	self.NineSliceHighlight:Hide()
end

function StoreProductListRowButtonMixin:OnEnter()
	if self:IsEnabled() == 1 then
		self.NineSliceHighlight:Show()
	end

	if self.showFavoriteOnEnter then
		self.FavoriteButton:Show()
	end

	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetHyperlink(self.itemLink)
		if self.productID and (IsGMAccount() or IsInterfaceDevClient()) then
			GameTooltip:AddDoubleLine("ProductID", self.productID, 0.44, 0.54, 0.68, 1, 1, 1)
			local flags, dynamicFlags = C_StoreSecure.GetProductFlags(self.productID)
			if flags then
				GameTooltip:AddDoubleLine("ProductFlags", string.format("0x%x", flags), 0.44, 0.54, 0.68, 1, 1, 1)
			end
			if dynamicFlags then
				GameTooltip:AddDoubleLine("ProductDynFlags", string.format("0x%x", dynamicFlags), 0.44, 0.54, 0.68, 1, 1, 1)
			end
		end
		GameTooltip:Show()
	end
end

function StoreProductListRowButtonMixin:OnLeave()
	self.NineSliceHighlight:Hide()

	if self.showFavoriteOnEnter and not self.FavoriteButton:IsMouseOverEx() then
		self.FavoriteButton:Hide()
	end

	if self.itemLink then
		GameTooltip:Hide()
	end
end

function StoreProductListRowButtonMixin:OnClick(button)
	self:GetOwner():OnItemClick(self, button)
end

function StoreProductListRowButtonMixin:Populate(rowData, dataIndex)
	self:SetID(dataIndex)
	self.itemLink = rowData.link
	self.productID = rowData.productID
	self.NewIndicator:SetShown(rowData.isNew)
	self:UpdateFavorite()
end

function StoreProductListRowButtonMixin:UpdateFavorite()
	if C_StoreSecure.IsFavoriteProductID(self.productID) then
		self.FavoriteButton:SetNormalAtlas("auctionhouse-icon-favorite", true)
		self.FavoriteButton:SetHighlightAtlas("auctionhouse-icon-favorite-off", true)
		self.FavoriteButton:Show()
		self.showFavoriteOnEnter = nil
	elseif C_StoreSecure.CanFavoriteProductID(self.productID) then
		self.FavoriteButton:SetNormalAtlas("auctionhouse-icon-favorite-off", true)
		self.FavoriteButton:SetHighlightAtlas("auctionhouse-icon-favorite", true)
		self.FavoriteButton:SetShown(self:IsMouseOverEx())
		self.showFavoriteOnEnter = true
	else
		self.FavoriteButton:Hide()
		self.showFavoriteOnEnter = nil
	end

	if self.FavoriteButton:IsMouseOverEx() then
		self:OnFavoriteEnter()
	end
end

function StoreProductListRowButtonMixin:OnFavoriteClick(button)
	if not self.productID then
		return
	end

	local isFavorite = C_StoreSecure.IsFavoriteProductID(self.productID)
	local success = C_StoreSecure.SetFavoriteProductID(self.productID, not isFavorite)
	if success then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
end

function StoreProductListRowButtonMixin:OnFavoriteEnter()
	if not self.productID then
		return
	end
	GameTooltip:SetOwner(self.FavoriteButton, "ANCHOR_RIGHT")
	if C_StoreSecure.IsFavoriteProductID(self.productID) then
		GameTooltip:AddLine(STORE_FAVORITE_UNSET)
	else
		GameTooltip:AddLine(STORE_FAVORITE_SET)
	end
	GameTooltip:Show()
end

function StoreProductListRowButtonMixin:OnFavoriteLeave()
	GameTooltip:Hide()
end

StoreProductListCellMixin = {}

function StoreProductListCellMixin:OnLoad()
end

function StoreProductListCellMixin:Init(dataProviderKey)
	self.dataProviderKey = dataProviderKey
end

function StoreProductListCellMixin:Populate(rowData, dataIndex)
	local value = rowData[self.dataProviderKey]
	self.Text:SetJustifyH(self.textAlignment or "CENTER")
	self.Text:SetText(value or "?")
end

StoreProductListCellIconMixin = CreateFromMixins(StoreProductListCellMixin)

function StoreProductListCellIconMixin:OnLoad()
	self.Border:SetAtlas("PKBT-ItemBorder-Default", true)
end

function StoreProductListCellIconMixin:Populate(rowData, dataIndex)
	self.Icon:SetTexture(rowData.icon)
	self.Amount:SetText(rowData.amount > 1 and rowData.amount or "")
	local r, g, b = GetItemQualityColor(rowData.rarity or ITEM_RARITY_FALLBACK)
	self.Border:SetVertexColor(r, g, b)

	self.Icon:SetDesaturated(rowData.isUnavailable)
	self.Border:SetDesaturated(rowData.isUnavailable)
	if rowData.isUnavailable then
		self.Amount:SetTextColor(0.5, 0.5, 0.5)
	else
		self.Amount:SetTextColor(1, 1, 1)
	end
end

StoreProductListCellNameMixin = CreateFromMixins(StoreProductListCellMixin)

function StoreProductListCellNameMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.name)
	self.Text:SetWidth(self:GetWidth() - 10)
	if rowData.isUnavailable then
		self.Text:SetTextColor(0.5, 0.5, 0.5)
	else
		self.Text:SetTextColor(1, 1, 1)
	end
end

StoreProductListCellItemLevelMixin = CreateFromMixins(StoreProductListCellMixin)

function StoreProductListCellItemLevelMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.itemLevel and rowData.itemLevel ~= 0 and rowData.itemLevel or "")
	if rowData.isUnavailable then
		self.Text:SetTextColor(0.5, 0.5, 0.5)
	else
		self.Text:SetTextColor(1, 1, 1)
	end
end

StoreProductListCellSpecialMixin = CreateFromMixins(StoreProductListCellMixin)

function StoreProductListCellSpecialMixin:Populate(rowData, dataIndex)
	if rowData.originalPrice and rowData.originalPrice ~= rowData.price and rowData.originalPrice > 0 then
		self.Text:SetFormattedText(STORE_PRODUCT_DISCOUNT, C_StoreSecure.GetDiscountForProductID(rowData.productID))
		self:SetDesaturated(rowData.isUnavailable)
		self:Show()
	else
		self:Hide()
	end
end

StoreProductListCellPVPIconMixin = CreateFromMixins(StoreProductListCellMixin)

function StoreProductListCellPVPIconMixin:OnLoad()
	self.Icon:SetAtlas("PKBT-Store-ItemPlate-Icon-Prestige", true)
end

function StoreProductListCellPVPIconMixin:Populate(rowData, dataIndex)
	self:SetShown(rowData.isPVP)
	self.Icon:SetDesaturated(rowData.isUnavailable)
end

StoreProductListCellPriceMixin = CreateFromMixins(StoreProductListCellMixin)

function StoreProductListCellPriceMixin:OnLoad()
	self.Price:SetOriginalOnTop(true)
end

function StoreProductListCellPriceMixin:Populate(rowData, dataIndex)
	self.Price:SetPrice(rowData.price, rowData.originalPrice, rowData.currencyType)
	self.Price:SetPriceDesaturated(rowData.isUnavailable)
end

StoreProductFilterHolderMixin = CreateFromMixins(PKBT_OwnerMixin)

function StoreProductFilterHolderMixin:OnLoad()
	self.Divider:SetAtlas("PKBT-Divider-Dark", true)

	self.labelPaddingOffsetY = 8
	self.widgetPaddingOffsetX = 15
	self.widgetPaddingOffsetY = 8

	self.Label:SetPoint("TOPLEFT", self.widgetPaddingOffsetX, -self.labelPaddingOffsetY)

	self.widgets = {}
end

function StoreProductFilterHolderMixin:OnShow()
	self:UpdateRect()
end

function StoreProductFilterHolderMixin:HintOnEnter()
	if self.hintText then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(self.hintText, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

function StoreProductFilterHolderMixin:HintOnLeave()
	GameTooltip:Hide()
end

function StoreProductFilterHolderMixin:SetLabel(label)
	if not label or label == "" then
		self.Label:Hide()
	else
		self.Label:SetText(label)
		self.Label:Show()
	end
	self:UpdateResetButton()
end

function StoreProductFilterHolderMixin:SetResetAvailable(canReset)
	self.canReset = canReset
	self:UpdateResetButton()
end

function StoreProductFilterHolderMixin:UpdateResetButton()
	if self.canReset and self.Label:IsShown() then
		self.ResetButton:Show()
	else
		self.ResetButton:Hide()
	end
end

function StoreProductFilterHolderMixin:AddOptionWidget(widget, preservePoints, fullwidth)
	table.insert(self.widgets, widget)
	widget:SetParent(self)
	widget.__preservePoints = preservePoints
	widget.__fullwidth = fullwidth
	self.dity = true
end

function StoreProductFilterHolderMixin:GetWidgets()
	return self.widgets
end

function StoreProductFilterHolderMixin:Clear()
	table.wipe(self.widgets)
	self.canReset = nil
	self.dity = true
	self.ResetButton:Hide()
end

function StoreProductFilterHolderMixin:UpdateRect()
	if not self.dity then
		return
	end

	if #self.widgets == 0 then
		self:SetHeight(-5) -- yes, use negative height as offset compensation
		self:Hide()
		GMError(string.format("[STORE_LIST_VIEW] No filter options for filter \"%s\"", self.Label:GetText()))
		return
	else
		self:Show()
	end

	local height = 0
	local lastPointWidget

	if self.Label:IsShown() then
		height = height + self.Label:GetHeight() + self.labelPaddingOffsetY
	end

	for i, widget in ipairs(self.widgets) do
		if i == 1 then
			if self.Label:IsShown() then
				widget:SetPoint("TOPLEFT", self.Label, "BOTTOMLEFT", 0, -self.labelPaddingOffsetY)
			else
				widget:SetPoint("TOPLEFT", self, self.widgetPaddingOffsetX, -self.widgetPaddingOffsetY)
			end
			height = height + widget:GetHeight()
			lastPointWidget = widget
		elseif not widget.__preservePoints then
			widget:SetPoint("TOPLEFT", lastPointWidget, "BOTTOMLEFT", 0, -self.widgetPaddingOffsetY)
			height = height + widget:GetHeight() + self.widgetPaddingOffsetY
			lastPointWidget = widget
		end

		if widget:IsObjectType("CheckButton") then
			widget.ButtonText:SetPoint("RIGHT", self, "RIGHT", -self.widgetPaddingOffsetX, 0)
		elseif widget.__fullwidth then
			widget:SetPoint("RIGHT", -self.widgetPaddingOffsetX, 0)
		end
	end

	self.dity = nil
	self:SetHeight(height + 20)
end

function StoreProductFilterHolderMixin:FilterApplied(optionID, optionKey, value, optionKeyIndex)
	if self.isBitMask and not self.isRadioButton then
		local mask = 0
		for _, widget in ipairs(self.widgets) do
			if widget.FLAG and widget:GetChecked() then
				mask = mask + widget.FLAG
			end
		end
		self:GetOwner():FilterApplied(self:GetID(), optionID, optionKey, mask, optionKeyIndex)
	else
		self:GetOwner():FilterApplied(self:GetID(), optionID, optionKey, value, optionKeyIndex)
	end
end

function StoreProductFilterHolderMixin:ResetOptions()
	self:GetOwner():ResetFilterOption(self:GetID(), self.type)
end

StoreProductFilterCheckButtonMixin = CreateFromMixins(PKBT_CheckButtonMixin)

function StoreProductFilterCheckButtonMixin:OnEnter()
	if false and self.ButtonText:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(self.ButtonText:GetText())
		GameTooltip:Show()
	end
end

function StoreProductFilterCheckButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function StoreProductFilterCheckButtonMixin:OnChecked(checked, userInput)
	if userInput and self.value ~= checked then
		local optionIndex, value
		if self.FLAG then
			if checked  then
				value = self.FLAG or 1
			else
				value = 0
			end
		else
			value = checked
		end
		self:GetParent():FilterApplied(self:GetID(), self.OPTION_KEY, value, self.OPTION_KEY_INDEX)
		self.value = checked
	end
end

StoreProductFilterRadioButtonMixin = CreateFromMixins(PKBT_RadioButtonMixin)
StoreProductFilterRadioButtonMixin.OnEnter = StoreProductFilterCheckButtonMixin.OnEnter
StoreProductFilterRadioButtonMixin.OnLeave = StoreProductFilterCheckButtonMixin.OnLeave

function StoreProductFilterRadioButtonMixin:OnChecked(checked, userInput)
	if userInput and not checked then -- block uncheck
		self:SetChecked(true)
	else
		StoreProductFilterCheckButtonMixin.OnChecked(self, checked, userInput)
	end
end

StoreProductFilterEditBoxMixin = CreateFromMixins(PKBT_EditBoxMixin)

function StoreProductFilterEditBoxMixin:OnLoad()
	PKBT_EditBoxMixin.OnLoad(self)

	self:SetCustomCharFilter(function(text)
		text = string.gsub(text, "%s%s+", " ")
		text = utf8.gsub(text, "[^A-zА-я0-9' ]+", "")
		return text
	end)
end

function StoreProductFilterEditBoxMixin:OnHide()
	self:StopOnCharFilterDelay()
end

function StoreProductFilterEditBoxMixin:OnEnterPressed()
	self:ClearFocus()
	self:ApplyFilter()
end

function StoreProductFilterEditBoxMixin:OnEditFocusLost()
	self:HighlightText(0, 0)
	self:ApplyFilter()
end

function StoreProductFilterEditBoxMixin:OnEscapePressed()
	self:SetText(self.value or "")
	PKBT_EditBoxMixin.OnEscapePressed(self)
end

function StoreProductFilterEditBoxMixin:ApplyFilter()
	local newValue = self:GetText()
	if self.value ~= newValue and not (self.value == nil and newValue == "") then
		self:GetParent():FilterApplied(self:GetID(), self.OPTION_KEY, newValue)
		self.value = newValue
	end
end

function StoreProductFilterEditBoxMixin:ToggleOnCharFilter(state, filterUpdateDelay)
	if state then
		self.filterUpdateDelay = filterUpdateDelay
		self.filterDelay = filterUpdateDelay
	else
		self:SetScript("OnUpdate", nil)
		self.filterUpdateDelay = nil
		self.filterDelay = nil
	end
end

function StoreProductFilterEditBoxMixin:OnTextValueChanged(value, userInput)
	if userInput then
		if self.filterUpdateDelay then
			self.filterDelay = self.filterUpdateDelay
			self:SetScript("OnUpdate", self.OnUpdate)
		end
	else
		self:StopOnCharFilterDelay()
	end
end

function StoreProductFilterEditBoxMixin:OnUpdate(elapsed)
	self.filterDelay = self.filterDelay - elapsed

	if self.filterDelay <= 0 then
		self:SetScript("OnUpdate", nil)
		self.filterDelay = nil
		self:ApplyFilter()
	end
end

function StoreProductFilterEditBoxMixin:StopOnCharFilterDelay()
	self:SetScript("OnUpdate", nil)

	if self.filterUpdateDelay then
		self.filterDelay = self.filterUpdateDelay
	end
end

StoreProductFilterNumericEditBoxMixin = CreateFromMixins(PKBT_EditBoxMixin)

function StoreProductFilterNumericEditBoxMixin:OnEnterPressed()
	self:ClearFocus()
	self:ApplyFilter()
end

function StoreProductFilterNumericEditBoxMixin:OnEditFocusLost()
	self:HighlightText(0, 0)
	self:ApplyFilter()
end

function StoreProductFilterNumericEditBoxMixin:OnEscapePressed()
	self:SetValue(self.value or 0)
	PKBT_EditBoxMixin.OnEscapePressed(self)
end

function StoreProductFilterNumericEditBoxMixin:SetValue(value)
	self:SetText(value ~= 0 and value or "")
end

function StoreProductFilterNumericEditBoxMixin:ApplyFilter()
	local newValue = self:GetNumber()
	if self.value ~= newValue and not (self.value == nil and newValue == "") then
		self:GetParent():FilterApplied(self:GetID(), self.OPTION_KEY, newValue)
		self.value = newValue
	end
end