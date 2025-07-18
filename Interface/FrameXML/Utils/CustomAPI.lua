local appendArray = function(array, ...)
	for i = 1, select("#", ...) do
		array[#array + 1] = select(i, ...)
	end
	return array
end

do	-- CreateAnimationGroupOfGroups
	local animationGroupMT
	local animationGroupMTOverrides = {
		GetAnimations = function(self)
			local animations = {}
			for _, animGroup in ipairs(self) do
				appendArray(animations, animGroup:GetAnimations())
			end
			return unpack(animations)
		end,
		Pause = function(self)
			for _, animGroup in ipairs(self) do
				animGroup:Pause()
			end
		end,
		Play = function(self)
			for _, animGroup in ipairs(self) do
				animGroup:Play()
			end
		end,
		Stop = function(self)
			for _, animGroup in ipairs(self) do
				if animGroup:IsPlaying() then
					animGroup:Stop()
				end
			end
		end,
		GetName = function(self)
			local name = self[1]:GetName()
			if name then
				return string.format("%sVirtualAnimGroup", name)
			end
		end,
	}
	local virtualAnimationGroupMT = {
		__index = function(self, key)
			if animationGroupMTOverrides[key] then
				return animationGroupMTOverrides[key]
			elseif animationGroupMT and type(animationGroupMT[key]) == "function" then
				return function(this, ...)
					return animationGroupMT[key](this[1], ...)
				end
			end
		end,
		__metatable = false,
	}

	function CreateAnimationGroupOfGroups(obj, ...)
		if type(obj) ~= "table" or select("#", ...) == 0 then
			error("Usage: CreateVirtualAnimationGroup(obj, animation, ...)", 2)
		end

		local virtualGroup = {}

		for i = 1, select("#", ...) do
			local animGroup = select(i, ...)
			if type(animGroup) ~= "table" then
				error(string.format("CreateAnimationGroupOfGroups: Incorrect argument #%i object type (table expected, got %s)", i + 1, type(animGroup)), 2)
			elseif animGroup:GetObjectType() ~= "AnimationGroup" then
				error(string.format("CreateAnimationGroupOfGroups: Incorrect argument #%i widget type (table expected, got %s)", i + 1, animGroup:GetObjectType()), 2)
			else
				virtualGroup[i] = animGroup
			end
		end

		if not animationGroupMT then
			animationGroupMT = getmetatable(virtualGroup[1]).__index
		end

		setmetatable(virtualGroup, virtualAnimationGroupMT)

		return virtualGroup
	end
end

do	-- SetEveryoneIsAssistant
	local isEveryoneAssistant = false

	function EventHandler:ASMSG_SET_EVERYONE_IS_ASSISTANT(msg)
		isEveryoneAssistant = tonumber(msg) == 1
	end

	function IsEveryoneAssistant()
		return isEveryoneAssistant
	end

	local IsRaidLeader = IsRaidLeader
	function SetEveryoneIsAssistant(state)
		if IsRaidLeader() then
			SendServerMessage("ACMSG_SET_EVERYONE_IS_ASSISTANT", state and 1 or 0)
		end
	end
end

do	-- UnitIsGroupLeader
	local PARTY_UNITS = {
		party1 = 1,
		party2 = 2,
		party3 = 3,
		party4 = 4,
	}

	function UnitIsGroupLeader(unit)
		if UnitIsUnit("player", unit) then
			return IsPartyLeader()
		else
			local raidID = UnitInRaid(unit)
			if raidID then
				return select(2, GetRaidRosterInfo(raidID + 1)) == 2
			elseif UnitInParty(unit) then
				local unitIndex = PARTY_UNITS[unit]
				if not unitIndex then
					for partyUnit, partyUnitIndex in pairs(PARTY_UNITS) do
						if UnitIsUnit(partyUnit, unit) then
							unitIndex = partyUnitIndex
							break
						end
					end
				end

				if unitIndex then
					return GetPartyLeaderIndex() == unitIndex
				end
			end
		end

		return false
	end
end

do	-- UnitInRangeIndex
	local ITEM_FRIENDLY = {
		[40] = 34471,
	}
	local UNIT_RANGE_INDEXES = {10, 28, 38, 40}

	local eventHandler = CreateFrame("Frame")
	eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventHandler:SetScript("OnEvent", function(self, event)
		for _, itemID in pairs(ITEM_FRIENDLY) do
			if not C_Item.GetItemInfoRaw(itemID) then
				C_Item.RequestServerCache(itemID)
			end
		end
		self:UnregisterEvent(event)
	end)

	function UnitInRangeIndex(unit, rangeIndex)
		if rangeIndex == 0 then
			return true
		elseif not UnitExists(unit) or not UNIT_RANGE_INDEXES[rangeIndex] then
			return false
		elseif UnitIsUnit(unit, "player") then
			return true
		end

		local range = UNIT_RANGE_INDEXES[rangeIndex]

		if range == 10 then
			return CheckInteractDistance(unit, 3) == 1
		elseif range == 28 then
			return CheckInteractDistance(unit, 1) == 1
		elseif range == 38 then
			return UnitInRange(unit) == 1
		elseif ITEM_FRIENDLY[range] then
			local itemID = ITEM_FRIENDLY[range]
			local result = IsItemInRange(itemID, unit)
			if not result or result == -1 then
				-- invalide spell, fallback to 38yrd check
				return UnitInRange(unit) == 1
			else
				return result == 1
			end
		end
	end
end

do	-- PlayerHasHearthstone | UseHearthstone
	local NUM_BAG_FRAMES = 4

	---@return integer? hearthstoneID
	---@return integer? bagID
	---@return integer? slotID
	function PlayerHasHearthstone()
		for bagID = 0, NUM_BAG_FRAMES do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, link = GetContainerItemInfo(bagID, slotID)
				if link then
					local itemID = tonumber(string.match(link, "item:(%d+)"))
					if itemID == 6948 then
						return itemID, bagID, slotID
					end
				end
			end
		end
	end

	local PlayerHasHearthstone = PlayerHasHearthstone
	function UseHearthstone()
		local hearthstoneID, bagID, slotID = PlayerHasHearthstone()
		if bagID then
			UseContainerItem(bagID, slotID)
		end
	end
end

do	-- Replace Enchant
	local pcall = pcall;
	local GetActionInfo = GetActionInfo;
	local IsEquippedItem = IsEquippedItem;
	local UnitIsUnit = UnitIsUnit;

	local EndRefund = EndRefund;
	local UseAction = UseAction;
	local UseInventoryItem = UseInventoryItem;
	local PickupInventoryItem = PickupInventoryItem;
	local UseContainerItem = UseContainerItem;
	local ClickTargetTradeButton = ClickTargetTradeButton;

	local ReplaceEnchant = ReplaceEnchant;
	local ReplaceTradeEnchant = ReplaceTradeEnchant;

	local replaceEnchantArg1, replaceEnchantArg2 = nil, nil;
	local replaceEnchantText1, replaceEnchantText2 = nil, nil;
	local tradeReplaceEnchantText1, tradeReplaceEnchantText2 = nil, nil;

	local tooltip = CreateFrame("GameTooltip", "ScanReplaceEnchantTooltip");
	tooltip:AddFontStrings(
		tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
		tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
	);

	local eventHandler = CreateFrame("Frame");
	eventHandler:RegisterEvent("REPLACE_ENCHANT");
	eventHandler:RegisterEvent("TRADE_REPLACE_ENCHANT");
	eventHandler:SetScript("OnEvent", function(this, event, arg1, arg2)
		if event == "REPLACE_ENCHANT" then
			replaceEnchantText1, replaceEnchantText2 = arg1, arg2;
		elseif event == "TRADE_REPLACE_ENCHANT" then
			tradeReplaceEnchantText1, tradeReplaceEnchantText2 = arg1, arg2;
		end
	end);

	local function GetEnchantText(func, replacedText, ...)
		tooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
		tooltip[func](tooltip, ...);
		tooltip:Show();

		local foundEnchant, enchantText = false;
		for i = tooltip:NumLines(), 2, -1 do
			local obj = _G["ScanReplaceEnchantTooltipTextLeft"..i];
			if not obj then
				tooltip:Hide();
				return nil, true;
			end

			local text = obj:GetText();
			if text and text ~= "" then
				if string.find(text, TOOLTIP_ENCHANT_SPELL) then
					enchantText = text;
					foundEnchant = true;
				elseif string.find(text, TOOLTIP_TITANIUM_WEAPON_CHAIN_SPELL, 1, true) then
					enchantText = string.match(text, TOOLTIP_TITANIUM_WEAPON_CHAIN_SPELL);
					foundEnchant = true;
				elseif string.find(text, TOOLTIP_ILLUSION_SPELL) then
					foundEnchant = true;
				elseif replacedText and string.find(text, replacedText, 1, true) then
					foundEnchant = false;
					enchantText = nil;
					break;
				end
			end
		end
		tooltip:Hide();
		return enchantText, not foundEnchant;
	end

	_G.UseAction = function(action, unit, button)
		replaceEnchantText1, replaceEnchantText2 = nil, nil;
		local inventorySlotID;
		if tonumber(action) then
			local actionType, id = GetActionInfo(action);
			if actionType == "item" and id and IsEquippedItem(id) then
				for slotID = 1, 19 do
					if id == GetInventoryItemID("player", slotID) then
						inventorySlotID = slotID;
						replaceEnchantArg1, replaceEnchantArg2 = slotID, nil;
						break;
					end
				end
			end
		end
		local success, result = pcall(UseAction, action, unit, button);
		if not success then
			geterrorhandler()(result);
			return;
		end
		if inventorySlotID and (replaceEnchantText1 and replaceEnchantText2) then
			local enchantText, enchantNotFound = GetEnchantText("SetInventoryItem", replaceEnchantText1, "player", inventorySlotID);
			if enchantText or enchantNotFound then
				if enchantText then
					replaceEnchantText1 = enchantText;
				end
				FireCustomClientEvent("CUSTOM_REPLACE_ENCHANT", replaceEnchantText1, replaceEnchantText2);
			else
				ReplaceEnchant();
			end
		end
	end

	_G.UseInventoryItem = function(slotID, target)
		if type(target) == "string" and not UnitIsUnit(target, "player") then
			return UseInventoryItem(slotID, target);
		end
		replaceEnchantText1, replaceEnchantText2 = nil, nil;
		replaceEnchantArg1, replaceEnchantArg2 = slotID, target;
		UseInventoryItem(slotID);
		if replaceEnchantText1 and replaceEnchantText2 then
			local enchantText, enchantNotFound = GetEnchantText("SetInventoryItem", replaceEnchantText1, "player", slotID);
			if enchantText or enchantNotFound then
				if enchantText then
					replaceEnchantText1 = enchantText;
				end
				FireCustomClientEvent("CUSTOM_REPLACE_ENCHANT", replaceEnchantText1, replaceEnchantText2);
			else
				ReplaceEnchant();
			end
		end
	end

	_G.PickupInventoryItem = function(slotID)
		replaceEnchantText1, replaceEnchantText2 = nil, nil;
		replaceEnchantArg1, replaceEnchantArg2 = slotID, nil;
		PickupInventoryItem(slotID);
		if replaceEnchantText1 and replaceEnchantText2 then
			local enchantText, enchantNotFound = GetEnchantText("SetInventoryItem", replaceEnchantText1, "player", slotID);
			if enchantText or enchantNotFound then
				if enchantText then
					replaceEnchantText1 = enchantText;
				end
				FireCustomClientEvent("CUSTOM_REPLACE_ENCHANT", replaceEnchantText1, replaceEnchantText2);
			else
				ReplaceEnchant();
			end
		end
	end

	_G.UseContainerItem = function(bagID, slotID)
		replaceEnchantText1, replaceEnchantText2 = nil, nil;
		replaceEnchantArg1, replaceEnchantArg2 = bagID, slotID;
		local success, result = pcall(UseContainerItem, bagID, slotID);
		if not success then
			geterrorhandler()(result);
			return;
		end
		if replaceEnchantText1 and replaceEnchantText2 then
			local enchantText, enchantNotFound = GetEnchantText("SetBagItem", replaceEnchantText1, bagID, slotID);
			if enchantText or enchantNotFound then
				if enchantText then
					replaceEnchantText1 = enchantText;
				end
				FireCustomClientEvent("CUSTOM_REPLACE_ENCHANT", replaceEnchantText1, replaceEnchantText2);
			else
				ReplaceEnchant();
			end
		end
	end

	_G.EndRefund = function(...)
		local arg1, arg2 = replaceEnchantArg1, replaceEnchantArg2;
		replaceEnchantText1, replaceEnchantText2 = nil, nil;
		replaceEnchantArg1, replaceEnchantArg2 = nil, nil;
		local success, result = pcall(EndRefund, ...);
		if not success then
			geterrorhandler()(result);
			return;
		end

		if replaceEnchantText1 and replaceEnchantText2 and (arg1 or arg2) then
			local enchantText, enchantNotFound
			if type(arg1) == "number" and type(arg2) == "number" then
				enchantText, enchantNotFound = GetEnchantText("SetBagItem", replaceEnchantText1, arg1, arg2);
			else
				enchantText, enchantNotFound = GetEnchantText("SetInventoryItem", replaceEnchantText1, "player", arg1);
			end
			if enchantText or enchantNotFound then
				if enchantText then
					replaceEnchantText1 = enchantText;
				end
				FireCustomClientEvent("CUSTOM_REPLACE_ENCHANT", replaceEnchantText1, replaceEnchantText2);
			else
				ReplaceEnchant();
			end
		end
	end

	_G.ClickTargetTradeButton = function(index)
		tradeReplaceEnchantText1, tradeReplaceEnchantText2 = nil, nil;
		ClickTargetTradeButton(index);
		if tradeReplaceEnchantText1 and tradeReplaceEnchantText2 then
			local enchantText, enchantNotFound = GetEnchantText("SetTradeTargetItem", replaceEnchantText1, index);
			if enchantText or enchantNotFound then
				if enchantText then
					replaceEnchantText1 = enchantText;
				end
				FireCustomClientEvent("CUSTOM_TRADE_REPLACE_ENCHANT", tradeReplaceEnchantText1, tradeReplaceEnchantText2);
			else
				ReplaceTradeEnchant();
			end
		end
	end
end

do	-- IsComplained | IsIgnoredRawByName
	local CanComplainChat = CanComplainChat
	local GetIgnoreName = GetIgnoreName
	local GetNumIgnores = GetNumIgnores
	local IsIgnored = IsIgnored
	local IsMuted = IsMuted
	local UnitName = UnitName

	AddMute = function() end
	DelMute = function() end
	AddOrDelMute = function() end

	IsComplained = function(token)
		return IsMuted(token)
	end

	IsIgnoredRawByName = function(token)
		if type(token) ~= "string" then
			error("Usage: IsIgnoredRawByName(name) or IsIgnoredRawByName(unit)", 2)
		end
		local name = UnitName(token) or token
		if CanComplainChat(name) and IsMuted(name) then
			for i = 1, GetNumIgnores() do
				if name == GetIgnoreName(i) then
					return true
				end
			end
			return false
		end
		return IsIgnored(name)
	end
end

do	-- GetServerTime
	local date = date
	local time = time
	local GetGameTime = GetGameTime

	local function getTimeDiffSeconds(srvHours, srvMinutes, seconds)
		local timeUTC = date("!*t")
		local timeLocal = date("*t")

		local tzDiffHours = (timeLocal.hour - timeUTC.hour)
		local tzDiffMinutes = (timeLocal.min - timeUTC.min)
		local tzDiffTotalSeconds = tzDiffHours * 3600 + tzDiffMinutes * 60

		local srvOffsetHours = srvHours - timeUTC.hour
		local srvOffsetMinutes = srvMinutes - timeUTC.min
		local srvOffsetSeconds = seconds and (timeUTC.sec - seconds) or 0

		local srvDiffSecondsUTC = (srvOffsetHours * 3600) + (srvOffsetMinutes * 60) - srvOffsetSeconds

		return srvDiffSecondsUTC - tzDiffTotalSeconds
	end

	local srvHours, srvMinutes = GetGameTime()
	local srvDiffSeconds = getTimeDiffSeconds(srvHours, srvMinutes)

	local frame = CreateFrame("Frame")
	frame:SetScript("OnUpdate", function(self)
		local h, m = GetGameTime()
		if m ~= srvMinutes then
			self:Hide()
			srvDiffSeconds = getTimeDiffSeconds(h, m, 0)
		end
	end)

	GetServerTime = function()
		return time() + srvDiffSeconds
	end
end

do	-- GetCategoryList
	local categoryList = {}

	local GetCategoryList = GetCategoryList
	_G.GetCategoryList = function()
		local isLockRenegade = not C_Service.IsRenegadeRealm()
		local isLockStrengthenStats = not C_Service.IsStrengthenStatsRealm()

		if isLockRenegade or isLockStrengthenStats then
			if categoryList and #categoryList == 0 then
				local lockedCategories = {
					[15050] = isLockRenegade,
					[15061] = isLockRenegade,
					[15043] = isLockStrengthenStats,
				}

				for _, categoryID in pairs(GetCategoryList()) do
					if not lockedCategories[categoryID] then
						table.insert(categoryList, categoryID)
					end
				end
			end

			return categoryList
		else
			return GetCategoryList()
		end
	end
end

do -- UpgradeLoadedVariables
	local _G = _G
	local pcall = pcall
	local DeepMergeTable = DeepMergeTable
	local IsInterfaceDevClient = IsInterfaceDevClient

	UpgradeLoadedVariables = function(variableName, localVariable, upgradeHandler)
		if _G[variableName] then
			if type(upgradeHandler) == "function" then
				local success, result = pcall(upgradeHandler, _G[variableName])
				if not success then
					geterrorhandler()(result)
				end
			end

			DeepMergeTable(_G[variableName], localVariable)
			local variables = _G[variableName]

			if not IsInterfaceDevClient() then
				_G[variableName] = nil
			end

			return variables
		else
			if IsInterfaceDevClient() then
				_G[variableName] = localVariable
			end

			return localVariable
		end
	end
end

do -- TaxiRequestEarlyLanding
	TaxiRequestEarlyLanding = function()
		SendServerMessage("ACMSG_TAXI_REQUEST_EARLY_LANDING")
	end
end

do -- GetWhoInfo
	local error = error
	local tonumber = tonumber
	local type = type
	local strmatch = string.match
	local GetWhoInfo = GetWhoInfo

	_G.GetWhoInfo = function(index)
		index = tonumber(index)
		if type(index) ~= "number" then
			error("Usage: GetWhoInfo(index)", 2)
		end

		local name, guild, level, race, class, zone, classFileName = GetWhoInfo(index)
		local itemLevel
		if name and name ~= "" then
			local newName, iLevel = strmatch(name, "(.-)%((%d+)%)")
			if iLevel then
				name = newName
				itemLevel = tonumber(iLevel)
			end
		end

		return name, guild, level, race, class, zone, classFileName, itemLevel or 0
	end
end

do -- FilterOutSpellLearn | IsSpellIDLearnFiltered | EnumSpellLearnFilters
	local SPELL_LEARN_FILTER = {}
	function FilterOutSpellLearn(spellID, spellName)
		if SPELL_LEARN_FILTER[spellID] then
			return
		end
		if not spellName then
			spellName = GetSpellInfo(spellID)
		end
		SPELL_LEARN_FILTER[spellID] = spellName
	end

	function IsSpellIDLearnFiltered(spellID)
		return SPELL_LEARN_FILTER[spellID] ~= nil
	end

	function EnumSpellLearnFilters()
		return pairs(SPELL_LEARN_FILTER)
	end
end

do -- PLAYER_LOOT_ITEM
	local ipairs = ipairs
	local tonumber = tonumber
	local strmatch = string.match
	local StringStartsWith = StringStartsWith

	Enum.PlayerLootEventType = {
		SelfLoot = 1,
		Created = 2,
		Pushed = 3,
	}

	local SELF_LOOT_MESSAGE_VARIANT = {
		strmatch(LOOT_ITEM_SELF, "^([^:]+: )"),
		strmatch(LOOT_ITEM_CREATED_SELF, "^([^:]+: )"),
		strmatch(LOOT_ITEM_PUSHED_SELF, "^([^:]+: )"),
	}

	EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_LOOT", function(event, msg, ...)
		for lootEventType, startLootText in ipairs(SELF_LOOT_MESSAGE_VARIANT) do
			if StringStartsWith(msg, startLootText) then
				local itemID, amount = strmatch(msg, "|Hitem:(%d+).*x(%d+)")

				if not itemID then
					itemID = strmatch(msg, "|Hitem:(%d+)")
				end

				itemID = tonumber(itemID)
				if itemID then
					FireCustomClientEvent("PLAYER_LOOT_ITEM", itemID, amount or 1, lootEventType)
					EventRegistry:TriggerEvent("PlayerLootItem", itemID, amount or 1, lootEventType)
				end

				break
			end
		end
	end, "CUSTOM_API")
end

do -- IsGameEventActive
	function EventHandler:ASMSG_GAME_EVENT_LIST(msg)
		local gameEvents = C_GlobalStorage.GetVar("GAME_EVENT_LIST")
		if not gameEvents then
			gameEvents = {}
			C_GlobalStorage.SetVar("GAME_EVENT_LIST", gameEvents)
		else
			table.wipe(gameEvents)
		end

		for index, gameEventID in ipairs({StringSplitEx(";", msg)}) do
			gameEvents[tonumber(gameEventID)] = true
		end

		FireCustomClientEvent("GAME_EVENT_LIST_UPDATE")
	end

	function EventHandler:ASMSG_GAME_EVENT_CHANGE(msg)
		local gameEventID, state = string.split(":", msg)

		local gameEvents = C_GlobalStorage.GetVar("GAME_EVENT_LIST")
		if not gameEvents then
			gameEvents = {}
			C_GlobalStorage.SetVar("GAME_EVENT_LIST", gameEvents)
		end

		gameEvents[tonumber(gameEventID)] = state == "1" and true or nil
		FireCustomClientEvent("GAME_EVENT_LIST_UPDATE")
	end

	function IsGameEventActive(gameEventID)
		local gameEvents = C_GlobalStorage.GetVar("GAME_EVENT_LIST")
		if gameEvents and gameEvents[gameEventID] then
			return true
		end
		return false
	end
end

do -- BAG_UPDATE_DELAYED
	local EVENT_HANDLER = CreateFrame("Frame")
	EVENT_HANDLER:Hide()
	EVENT_HANDLER:RegisterEvent("BAG_UPDATE")
	EVENT_HANDLER:SetScript("OnEvent", function(self, event, ...)
		self:Show()
	end)
	EVENT_HANDLER:SetScript("OnUpdate", function(self, elapsed)
		self:Hide()
		FireCustomClientEvent("BAG_UPDATE_DELAYED")
	end)
end