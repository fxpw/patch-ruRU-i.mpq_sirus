UIPanelWindows["ItemBrowser"] = { area = "left", pushable = 0, whileDead = 1, width = 830, xOffset = "15", yOffset = "-10"}

local type = type
local mathmax = math.max
local strfind, strlower, strtrim = string.find, string.lower, string.trim
local tinsert, twipe = table.insert, table.wipe
local debugprofilestop = debugprofilestop

local COLUMNS = {
	{
		name = "Name",
		dataProviderKey = "name",
		template = "ItemBrowserListCellNameIconTemplate",
	},
	{
		name = "ItemLevel",
		dataProviderKey = "itemLevel",
		width = 70,
		template = "ItemBrowserListCellItemLevelTemplate",
	},
	{
		name = "ID",
		dataProviderKey = "itemID",
		width = 90,
		template = "ItemBrowserListCellItemIDTemplate",
	},
}

ItemBrowserMixin = {}

function ItemBrowserMixin:OnLoad()
	self.TitleText:SetText(ITEM_BROWSER)
	SetPortraitToTexture(self.portrait, [[Interface\Icons\Achievement_General_ClassicBattles_64]])

	self.inset.Bgs:SetAtlas("UI-EJ-BattleforAzeroth")

	do -- tabs
		self:RegisterCustomEvent("SERVICE_DATA_UPDATE")
		self:RegisterCustomEvent("CUSTOM_CHALLENGE_DEACTIVATED")

		self.tab1:SetFrameLevel(1)
		self.tab2:SetFrameLevel(1)
		self.tab3:SetFrameLevel(1)
		self.tab4:SetFrameLevel(1)

		self.maxTabWidth = (self:GetWidth() - 19) / 4

		PanelTemplates_SetNumTabs(self, 4)
	end

	do -- coroutine
		self.COROUTINE_HANDLER = CreateFrame("Frame")
		self.COROUTINE_HANDLER:Hide()

		self.COROUTINE_HANDLER.FRAMETIME_TARGET = 1 / 55
		self.COROUTINE_HANDLER.FRAMETIME_AVAILABLE = 8
		self.COROUTINE_HANDLER.FRAMETIME_RESERVE = 4
		self.COROUTINE_HANDLER.DEBUG = false

		self.COROUTINE_HANDLER:SetScript("OnUpdate", function(this, elapsed)
			local frametimeStep = this.FRAMETIME_TARGET - elapsed

			if frametimeStep ~= 0 then
				frametimeStep = frametimeStep * 1000
				this.FRAMETIME_AVAILABLE = mathmax(5, this.FRAMETIME_AVAILABLE + frametimeStep)
			end

			if this.COROUTINE then
				this.COROUTINE_TIMESTAMP = debugprofilestop()
				local status, result, progress = coroutine.resume(this.COROUTINE)
				if not status then
					this.COROUTINE = nil
					this:Hide()
					self.PROGRESS = 1
					error(result, 2)
				elseif not result then
					if this.DEBUG then print("ITEM_BROWSER_COROUTINE", progress) end
					self.PROGRESS = progress
					self:OnSearchResultUpdate()
				else
					if this.DEBUG then print("ITEM_BROWSER_COROUTINE", 1) end
					this.COROUTINE = nil
					this:Hide()
					self.PROGRESS = 1
					self:OnSearchResultUpdate()
				end
			else
				this:Hide()
			end
		end)
	end

	self.BUTTON_OFFSET_Y = 0
	self.PROGRESS = 1

	self.results = {}

	self.Scroll.ScrollBar:SetBackgroundShown(false)
	self.Scroll.update = function(scrollFrame)
		self:UpdateResultList()
	end
	self.Scroll.ScrollBar.doNotHide = true
	self.Scroll.scrollBar = self.Scroll.ScrollBar
	HybridScrollFrame_CreateButtons(self.Scroll, "ItemBrowserListRowButtonTemplate", 0, 0, nil, nil, nil, -self.BUTTON_OFFSET_Y)

	self.SearchBox:ToggleOnCharFilter(true, 0.3)

	self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.Scroll))
	self.tableBuilder:SetHeaderContainer(self.HeaderHolder)
	self:ConstructTable()
end

function ItemBrowserMixin:OnShow()
	SetParentFrameLevel(self.inset)
	PanelTemplates_SetTab(self, 4)

	self.dirty = true
	self.Scroll.ScrollBar:SetValue(0)
	self:UpdateResultList()

	self.SearchBox:SetFocus()
end

function ItemBrowserMixin:OnEvent(event, ...)
	if event == "SERVICE_DATA_UPDATE"
	or (event == "CUSTOM_CHALLENGE_DEACTIVATED" and select(2, ...) ~= Enum.HardcoreDeathReason.FAILED_DEATH)
	then
		if not C_Service.IsRenegadeRealm() then
			PanelTemplates_HideTab(self, 2)
			self.tab3:SetPoint("LEFT", self.tab1, "RIGHT", -16, 0);
		end
		if not C_Service.IsHardcoreEnabledOnRealm() then
			PanelTemplates_HideTab(self, 3)
		end
		if not C_Service.IsGMAccount() then
			PanelTemplates_HideTab(self, 4)
		end
	end
end

function ItemBrowserMixin:GetRowProvider()
	return function(itemIndex)
		if itemIndex > #self.results then
			return nil
		end

		local itemID = self.results[itemIndex]
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = C_Item.GetItemInfo(itemID, false, nil, true, true)

		return {
			itemID = itemID,
			name = itemName,
			itemLink = itemLink,
			itemLevel = itemLevel,
			itemType = itemType,
			itemSubType = itemSubType,
			icon = itemTexture,
		}
	end
end

function ItemBrowserMixin:ConstructTable()
	local textPadding = 1
	local cellPadding = 10

	self.tableBuilder:Reset()
	self.tableBuilder:SetDataProvider(self:GetRowProvider())
	self.tableBuilder:SetTableMargins(5)
	self.tableBuilder:SetTableWidth(self.Scroll:GetWidth() or select(3, self.Scroll:GetRect()))

	for index, columnInfo in ipairs(COLUMNS) do
		local column = self.tableBuilder:AddColumn()
		column:ConstructHeader("Button", "ItemBrowserListHeaderButtonTemplate", columnInfo.name)
		column:ConstrainToHeader(textPadding)
		column:ConstructCells("Frame", columnInfo.template)

		if columnInfo.width then
			column:SetFixedConstraints(columnInfo.width, cellPadding)
		else
			column:SetFillConstraints(1, cellPadding)
		end
	end

	self.tableBuilder:Arrange()
end

function ItemBrowserMixin:GetNumItems()
	if not self.NUM_ITEMS then
		self.NUM_ITEMS = tCount(ItemsCache)
	end
	return self.NUM_ITEMS
end

function ItemBrowserMixin:SearchItem(item)
	item = strtrim(item)
	if item == "" then
		self:ClearResults()
		return
	end

	local itemID = C_Item.GetItemIDFromString(item)
	local searchField, searchValue, useStringFind

	if itemID then
		searchField = Enum.ItemCacheField.ITEM_ID
		searchValue = itemID
	elseif item ~= "" then
		searchField = GetLocale() == "ruRU" and Enum.ItemCacheField.NAME_RURU or Enum.ItemCacheField.NAME_ENGB
		searchValue = strlower(item)
		useStringFind = true
	end

	if not searchField then
		self:ClearResults()
		return
	end

	self:StartSearch(searchField, searchValue, useStringFind)
end

function ItemBrowserMixin:StartSearch(searchField, searchValue, useStringFind)
	if self.SEARCH_FIELD == searchField and self.SEARCH_VALUE == searchValue then
		return
	end

	if self.COROUTINE then
		coroutine.close(self.COROUTINE)
		self.COROUTINE = nil
		self:ClearResults()
	end

	self.SEARCH_FIELD = searchField
	self.SEARCH_VALUE = searchValue
	self.USE_STRING_FIND = useStringFind

	local framerate = GetFramerate()
	self.COROUTINE_HANDLER.FRAMETIME_TARGET = framerate > 63 and (1 / 60) or (1 / 55)
	self.COROUTINE_HANDLER.FRAMETIME_BUDGET = 1000 / framerate - self.COROUTINE_HANDLER.FRAMETIME_RESERVE

	self.COROUTINE_HANDLER.COROUTINE = coroutine.create(self.SearchProcess)
	self.COROUTINE_HANDLER.COROUTINE_TIMESTAMP = debugprofilestop()

	local status, result, progress = coroutine.resume(self.COROUTINE_HANDLER.COROUTINE, self)
	if not status then
		self.COROUTINE_HANDLER.COROUTINE = nil
		self.COROUTINE_HANDLER:Hide()
		self.PROGRESS = 1
		self:ClearResults()
		geterrorhandler()(result)
	elseif coroutine.status(self.COROUTINE_HANDLER.COROUTINE) == "dead" then
		self.COROUTINE_HANDLER.COROUTINE = nil
		self.PROGRESS = 1
	else
		if self.COROUTINE_HANDLER.DEBUG then print("ITEM_BROWSER_COROUTINE", progress) end
		self.PROGRESS = progress
		self.COROUTINE_HANDLER:Show()
	end

	self:OnSearchResultUpdate()
end

function ItemBrowserMixin:SearchProcess()
	twipe(self.results)

	if not ItemsCache then
		return true, 1
	end

	local processedEntries = 0
	local fieldValue

	for itemID, itemInfo in pairs(ItemsCache) do
		processedEntries = processedEntries + 1

		fieldValue = itemInfo[self.SEARCH_FIELD]

		if type(fieldValue) == "string" then
			fieldValue = strlower(fieldValue)
		end

		if fieldValue == self.SEARCH_VALUE
		or (self.USE_STRING_FIND and strfind(fieldValue, self.SEARCH_VALUE, 1, true))
		then
			tinsert(self.results, itemInfo[Enum.ItemCacheField.ITEM_ID])
		end

		if (debugprofilestop() - self.COROUTINE_HANDLER.COROUTINE_TIMESTAMP) > self.COROUTINE_HANDLER.FRAMETIME_BUDGET then
			coroutine.yield(false, processedEntries / self:GetNumItems())
		end
	end

	return true, 1
end

function ItemBrowserMixin:OnSearchResultUpdate()
	self.dirty = true
	self:UpdateSearchProgress()
	self:UpdateResultList()
end

function ItemBrowserMixin:UpdateSearchProgress()
	local progress = Clamp(self.PROGRESS or 1, 0, 1)
	self.SearchProgressBar:SetValue(progress)
	self.SearchProgressBar:SetAlpha(progress < 1 and 1 or 0)
end

function ItemBrowserMixin:ClearResults()
	twipe(self.results)

	self.SEARCH_FIELD = nil
	self.SEARCH_VALUE = nil
	self.USE_STRING_FIND = nil

	self.PROGRESS = 1
	self.dirty = true

	self:UpdateSearchProgress()
	self:UpdateResultList()
end

function ItemBrowserMixin:UpdateResultList()
	local scrollFrame = self.Scroll
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local numResults = self.results and #self.results or 0

	if self.numItems ~= numResults then
		self.numItems = numResults
		self.dirty = true
	end

	local populateCount = math.min(#scrollFrame.buttons, numResults)
	self.tableBuilder:Populate(offset, populateCount)

	local mouseFocus = GetMouseFocus()
	for index, button in ipairs(scrollFrame.buttons) do
		button:SetOwner(self)
		button:SetShown(index <= numResults)
		if button == mouseFocus then
			button:OnEnter()
		end
	end

	if self.dirty then
		local buttonHeight = scrollFrame.buttons[1] and scrollFrame.buttons[1]:GetHeight() or 0
		local scrollHeight = buttonHeight * numResults + self.BUTTON_OFFSET_Y * (numResults - 1) + self.BUTTON_OFFSET_Y / 3
		HybridScrollFrame_Update(scrollFrame, scrollHeight, scrollFrame:GetHeight())
		self.dirty = nil
	end
end

ItemBrowserSearchBoxMixin = CreateFromMixins(PKBT_EditBoxMixin)

function ItemBrowserSearchBoxMixin:OnLoad()
	PKBT_EditBoxMixin.OnLoad(self)

	local l, r, t, b = self:GetTextInsets()
	self:SetTextInsets(l + 10, r + 10, t - 1, b)

	self:SetInstructions(SEARCH)
	self.Instructions:ClearAllPoints()
	self.Instructions:SetPoint("LEFT", 19, -2)

	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6)

	self:SetCustomCharFilter(function(text)
		text = string.gsub(text, "%s%s+", " ")
		text = utf8.gsub(text, "[^A-zА-я0-9' ]+", "")
		return text
	end)

	self.value = ""
end

function ItemBrowserSearchBoxMixin:OnHide()
	self:StopOnCharSearchDelay()
end

function ItemBrowserSearchBoxMixin:OnEnterPressed()
	self:ClearFocus()
	self:DoSearch()
end

function ItemBrowserSearchBoxMixin:OnEditFocusLost()
	SearchBoxTemplate_OnEditFocusLost(self)
	self:HighlightText(0, 0)
	self:DoSearch()
end

function ItemBrowserSearchBoxMixin:OnUpdate(elapsed)
	self.searchDelay = self.searchDelay - elapsed

	if self.searchDelay <= 0 then
		self:SetScript("OnUpdate", nil)
		self.searchDelay = nil
		self:DoSearch()
	end
end

function ItemBrowserSearchBoxMixin:DoSearch()
	local newValue = self:GetText()
	if self.value ~= newValue and not (self.value == nil and newValue == "") then
		self.value = newValue
		self:GetParent():SearchItem(newValue)
	end
end

function ItemBrowserSearchBoxMixin:ToggleOnCharFilter(state, searchUpdateDelay)
	if state then
		self.searchUpdateDelay = searchUpdateDelay
		self.searchDelay = searchUpdateDelay
	else
		self:SetScript("OnUpdate", nil)
		self.searchUpdateDelay = nil
		self.searchDelay = nil
	end
end

function ItemBrowserSearchBoxMixin:OnTextChanged(userInput)
	PKBT_EditBoxMixin.OnTextChanged(self, userInput)
	SearchBoxTemplate_OnTextChanged(self)
end

function ItemBrowserSearchBoxMixin:OnTextValueChanged(value, userInput)
	if userInput then
		if self.searchUpdateDelay then
			self.searchDelay = self.searchUpdateDelay
			self:SetScript("OnUpdate", self.OnUpdate)
		end
	else
		self:StopOnCharSearchDelay()
	end
end

function ItemBrowserSearchBoxMixin:OnUpdate(elapsed)
	self.searchDelay = self.searchDelay - elapsed

	if self.searchDelay <= 0 then
		self:SetScript("OnUpdate", nil)
		self.searchDelay = nil
		self:DoSearch()
	end
end

function ItemBrowserSearchBoxMixin:StopOnCharSearchDelay()
	self:SetScript("OnUpdate", nil)

	if self.searchUpdateDelay then
		self.searchDelay = self.searchUpdateDelay
	end
end

function ItemBrowserSearchBoxMixin:OnClearClick(button)
	SearchBoxTemplateClearButton_OnClick(self.clearButton, button)
	self:StopOnCharSearchDelay()
	self:DoSearch()
end

ItemBrowserListHeaderButtonMixin = CreateFromMixins(TableBuilderElementMixin)

function ItemBrowserListHeaderButtonMixin:Init(name)
	self:SetText(name)
end

function ItemBrowserListHeaderButtonMixin:OnClick(button)
end

ItemBrowserListRowButton = CreateFromMixins(PKBT_OwnerMixin, TableBuilderRowMixin)

function ItemBrowserListRowButton:OnLoad()
	self.UpdateTooltip = self.OnEnter
end

function ItemBrowserListRowButton:OnEnter()
	if self.itemLink then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end
end

function ItemBrowserListRowButton:OnLeave()
	GameTooltip:Hide()
end

function ItemBrowserListRowButton:OnClick(button)
	if self.itemLink then
		HandleModifiedItemClick(self.itemLink)
	end
end

function ItemBrowserListRowButton:Populate(rowData, dataIndex)
	self:SetID(dataIndex)
	self.itemID = rowData.itemID
	self.itemLink = rowData.itemLink
end

ItemBrowserListCellMixin = {}

function ItemBrowserListCellMixin:OnLoad()
end

function ItemBrowserListCellMixin:Init(dataProviderKey)
	self.dataProviderKey = dataProviderKey
end

function ItemBrowserListCellMixin:Populate(rowData, dataIndex)
	local value = rowData[self.dataProviderKey]
	self.Text:SetJustifyH(self.textAlignment or "CENTER")
	self.Text:SetText(value or "?")
end

ItemBrowserListCellNameIconMixin = CreateFromMixins(ItemBrowserListCellMixin)

function ItemBrowserListCellNameIconMixin:Populate(rowData, dataIndex)
	local textWidth = self:GetWidth() - 10

	self.Text:SetText(rowData.name or UNKNOWN)
	self.Text:SetWidth(textWidth)
	self.SubText:SetWidth(textWidth)

	if rowData.itemType and rowData.itemSubType then
		self.SubText:SetFormattedText("%s - %s", rowData.itemType, rowData.itemSubType)
	elseif rowData.itemType or rowData.itemSubType then
		self.SubText:SetText(rowData.itemType or rowData.itemSubType)
	else
		self.SubText:SetText("")
	end

	self.Icon:SetTexture(rowData.icon or QUESTION_MARK_ICON)
	local r, g, b = GetItemQualityColor(rowData.rarity or 1)
	self.Border:SetVertexColor(r, g, b)
end

ItemBrowserListCellItemLevelMixin = CreateFromMixins(ItemBrowserListCellMixin)

function ItemBrowserListCellItemLevelMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.itemLevel and rowData.itemLevel ~= 0 and rowData.itemLevel or "")
end

ItemBrowserListCellItemIDMixin = CreateFromMixins(ItemBrowserListCellMixin)

function ItemBrowserListCellItemIDMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.itemID)
end