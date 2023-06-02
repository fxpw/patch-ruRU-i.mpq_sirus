local GetContainerItemID = GetContainerItemID
local GetContainerNumSlots = GetContainerNumSlots
local GetMoney = GetMoney
local UnitFactionGroup = UnitFactionGroup
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitName = UnitName
local UseContainerItem = UseContainerItem

local CopyTable = CopyTable
local FireCustomClientEvent = FireCustomClientEvent
local RoundToSignificantDigits = RoundToSignificantDigits
local RunNextFrame = RunNextFrame
local SendServerMessage = SendServerMessage

local error = error
local ipairs = ipairs
local next = next
local pairs = pairs
local time = time
local tonumber = tonumber
local type = type
local unpack = unpack
local bitband, bitbor = bit.band, bit.bor
local mathfloor, mathmax, mathmin = math.floor, math.max, math.min
local strformat, strgsub, strmatch, strsplit, strtrim = string.format, string.gsub, string.match, string.split, string.trim
local tIndexOf, tinsert, tremove, tsort, twipe = tIndexOf, table.insert, table.remove, table.sort, table.wipe

Enum.BattlePass = {}
Enum.BattlePass.CardState = {
	Default = 1,
	LootAvailable = 2,
	Looted = 3,
}
Enum.BattlePass.RewardType = {
	Free = 0,
	Premium = 1,
}
Enum.BattlePass.QuestType = {
	Daily = 1,
	Weekly = 2,
}
Enum.BattlePass.QuestState = {
	None		= 0,
	Complete	= 1,
	Failed		= 2,
}

local EXPERIENCE_ITEMS = {
	[61850] = 8000,
	[71083] = 400,
	[149192] = 800,
	[149193] = 4000,
	[149194] = 8000,
}

local PREMIUM_ITEMS = {
	[149195] = true,
	[149211] = true,
	[149212] = true,
}

local PURCHASE_EXPERIENCE_OPTIONS = {
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire-Highlight",
		currencyAtlas = "PKBT-Icon-Currency-BonusOld",
	},
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Emerald",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Emerald-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Emerald-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Emerald-Highlight",
		currencyAtlas = "PKBT-Icon-Currency-BonusOld",
	},
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Ruby",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Ruby-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Ruby-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Ruby-Highlight",
		currencyAtlas = "PKBT-Icon-Currency-BonusOld",
	},
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst-Highlight",
		currencyAtlas = "PKBT-Icon-Currency-BonusOld",
	},
}

local STORE_CURRENCY = 1
local STORE_CATEGORY = 101
local STORE_SUBCATEGORY_EXPERIENCE = 1
local STORE_SUBCATEGORY_PREMIUM = 2

local PRODUCT_DATA = {
	PRODUCT_ID		= 1,
	ITEM_ID			= 2,
	ITEM_COUNT		= 3,
	PRICE			= 4,
	DISCOUNT		= 5,
	DISCOUNT_PRICE	= 6,
	CREATURE_ID		= 7,
	FLAGS			= 8,
	ALT_CURRENCY	= 9,
	ALT_PRICE		= 10,
	IS_PVP			= 11,
	SHOW_DISCOUNT	= 12,
	TIME_REMAINING	= 13,
}

local LEVEL_REWARD = {
	ITEM_TYPE = 1,
	ITEM_ID = 2,
	AMOUNT_= 3,
	FLAGS = 4,
}

local ITEM_REWARD_FLAG = {
	ALLIANCE	= 1,
	HORDE		= 2,
	RENEGADE	= 4,
}

local QUEST_MSG_STATUS = {
	OK					= 0,
	DATA_ERROR			= 1,
	NOT_ENOUGH_MONEY	= 2,
	INVALIDE_QUEST		= 3,
	DONT_HAVE_QUEST		= 4,
	QUEST_NOT_COMPLETE	= 5,
}

local QUEST_FLAG = {
	DAILY			= 0x1,
	WEEKLY			= 0x2,
	SHOW_PERCENT	= 0x4,
}

local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD

local SECONDS_PER_DAY = 24 * 60 * 60

local BATTLEPASS_LEVELS
local BATTLEPASS_LEVEL_REWARDS
local CUSTOM_BATTLEPASS_CACHE

local ALLOW_WEEKLY_QUEST_REROLL = false

local PRIVATE = {
	ENABLED = false,
	MAX_LEVEL = 1,

	PRODUCT_PREMIUM = nil,
	PRODUCT_EXPERIENCE_LIST = {},

	LEVEL_INFO = {},
	LEVEL_REWARD_AWAIT = {},
	LEVEL_REWARD_ITEMS = {},

	QUEST_LIST = {},
	QUEST_LIST_TYPED = {
		[Enum.BattlePass.QuestType.Daily] = {},
		[Enum.BattlePass.QuestType.Weekly] = {},
	},
	QUEST_PARSED = {},
	QUEST_PARSE_QUEUE = {},

	QUEST_REPLACE_AWAIT = {},
	QUEST_REWARD_AWAIT = {},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("VARIABLES_LOADED")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGOUT")
PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")

PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, msg, distribution, sender = ...
		if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
			return
		end

		if prefix == "ASMSG_BATTLEPASS_INFO" then
			local expTotal, isPremium, questDoneToday, seasonEndTime = strsplit(":", msg)

			CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL = tonumber(expTotal) or 0
			CUSTOM_BATTLEPASS_CACHE.DAILY_QUESTS_DONE = tonumber(questDoneToday) or 0

			local level, levelExp = PRIVATE.GetLevelByExperience(CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL)
			CUSTOM_BATTLEPASS_CACHE.LEVEL = level
			CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE = levelExp

			CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE = isPremium == "1"
			CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME = tonumber(seasonEndTime) or 0

			twipe(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN)

			PRIVATE.ENABLED = true

			FireCustomClientEvent("BATTLEPASS_ACCOUNT_UPDATE", CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE, CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME)
			FireCustomClientEvent("BATTLEPASS_EXPERIENCE_UPDATE", CUSTOM_BATTLEPASS_CACHE.LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE)
		elseif prefix == "ASMSG_BATTLEPASS_SETTINGS" then
			local questRerollPrice, pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1 = strsplit(":", msg)

			CUSTOM_BATTLEPASS_CACHE.REROLL_PRICE		= COPPER_PER_GOLD * (tonumber(questRerollPrice) or 1000)
			CUSTOM_BATTLEPASS_CACHE.POINTS_BG			= tonumber(pointsBG) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA		= tonumber(pointsArena) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_SOLOQ	= tonumber(pointsArenaSoloQ) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_V1		= tonumber(pointsArena1v1) or 0

			FireCustomClientEvent("BATTLEPASS_POINTS_UPDATE")
		elseif prefix == "ASMSG_BATTLEPASS_EXP" then
			local expAdded = strsplit(":", msg)

			CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL = (CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL or 0) + (tonumber(expAdded) or 0)
			local level, levelExp = PRIVATE.GetLevelByExperience(CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL)
			local levelChanged = CUSTOM_BATTLEPASS_CACHE.LEVEL ~= level
			CUSTOM_BATTLEPASS_CACHE.LEVEL = level
			CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE = levelExp

			FireCustomClientEvent("BATTLEPASS_EXPERIENCE_UPDATE", CUSTOM_BATTLEPASS_CACHE.LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE)

			if levelChanged then
				FireCustomClientEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
			end
		elseif prefix == "ASMSG_BATTLEPASS_REWARDS_INFO" then
			for _, reward in ipairs({strsplit(";", (strgsub(msg, ";$", "")))}) do
				local level, rewardType = strsplit(":", reward)

				level = tonumber(level)
				rewardType = tonumber(rewardType)

				local rewardFlag = PRIVATE.GetLevelRewardsFlag(rewardType)
				CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] = bitbor(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] or 0, rewardFlag)
			end

			FireCustomClientEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
		elseif prefix == "ASMSG_BATTLEPASS_TAKE_REWARD" then
			local level, rewardType = strsplit(":", msg)

			level = tonumber(level)
			rewardType = tonumber(rewardType)

			local rewardFlag = PRIVATE.GetLevelRewardsFlag(rewardType)
			CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] = bitbor(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] or 0, rewardFlag)

			FireCustomClientEvent("BATTLEPASS_CARD_UPDATE", level, rewardType)

			for i, reward in ipairs(PRIVATE.LEVEL_REWARD_AWAIT) do
				if reward.level == level and reward.rewardType == rewardType then
					tremove(PRIVATE.LEVEL_REWARD_AWAIT, i)

					local freeItems, premiumItems = PRIVATE.GetLevelRewards(level)
					if rewardType == Enum.BattlePass.RewardType.Premium then
						FireCustomClientEvent("BATTLEPASS_REWARD_ITEMS", premiumItems)
					else
						FireCustomClientEvent("BATTLEPASS_REWARD_ITEMS", freeItems)
					end

					break
				end
			end
		elseif prefix == "ASMSG_BATTLEPASS_QUESTS_INFO" then
			if msg == "" then return end

			for _, questStr in ipairs({strsplit(";", (strgsub(msg, ";$", "")))}) do
				local questID, questFlag, rewardAmount, rerollsDone, totalValue, currentValue, state = strsplit(":", questStr)
				questID = tonumber(questID)
				questFlag = tonumber(questFlag)

				local questType
				if bitband(questFlag, QUEST_FLAG.DAILY) ~= 0 then
					questType = Enum.BattlePass.QuestType.Daily
				elseif bitband(questFlag, QUEST_FLAG.WEEKLY) ~= 0 then
					questType = Enum.BattlePass.QuestType.Weekly
				end

				if PRIVATE.QUEST_LIST[questID] then
					PRIVATE.QUEST_LIST[questID].type			= questType
					PRIVATE.QUEST_LIST[questID].flags			= questFlag
					PRIVATE.QUEST_LIST[questID].rewardAmount	= tonumber(rewardAmount)
					PRIVATE.QUEST_LIST[questID].rerollsDone		= tonumber(rerollsDone)
					PRIVATE.QUEST_LIST[questID].totalValue		= tonumber(totalValue)
					PRIVATE.QUEST_LIST[questID].currentValue	= tonumber(currentValue)
					PRIVATE.QUEST_LIST[questID].state			= tonumber(state)

					local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], questID)

					if not PRIVATE.QUEST_REFRESH then
						FireCustomClientEvent("BATTLEPASS_QUEST_UPDATE", questType, questIndex)

						if PRIVATE.IsQuestComplete(questID) then
							if questType == Enum.BattlePass.QuestType.Daily then
								FireCustomClientEvent("SHOW_TOAST", 9, 0, "battlepas_64x64", BATTLEPASS_TITLE, BATTLEPASS_QUEST_COMPLETED_TOAST_DAILY)
							else
								FireCustomClientEvent("SHOW_TOAST", 9, 0, "battlepas_64x64", BATTLEPASS_TITLE, BATTLEPASS_QUEST_COMPLETED_TOAST_WEEKLY)
							end
						end

						return
					end
				else
					PRIVATE.QUEST_LIST[questID] = {
						type			= questType,
						flags			= questFlag,
						rewardAmount	= tonumber(rewardAmount),
						rerollsDone		= tonumber(rerollsDone),
						totalValue		= tonumber(totalValue),
						currentValue	= tonumber(currentValue),
						state			= tonumber(state),
					}

					tinsert(PRIVATE.QUEST_LIST_TYPED[questType], questID)
					PRIVATE.ParseQuestTooltip(questID)
				end
			end

			for questType, questList in ipairs(PRIVATE.QUEST_LIST_TYPED) do
				tsort(questList, PRIVATE.SortQuests)
			end

			PRIVATE.QUEST_REFRESH = nil
			FireCustomClientEvent("BATTLEPASS_QUEST_LIST_UPDATE")
		elseif prefix == "ASMSG_BATTLEPASS_REPLACE_QUEST" then
			local status, replacedQuestID, questID, questFlag, rewardAmount, rerollsDone, totalValue, currentValue, state = strsplit(":", msg)
			status = tonumber(status)
			replacedQuestID = tonumber(replacedQuestID)

			if status == QUEST_MSG_STATUS.OK then
				questID = tonumber(questID)

				local questType
				if bitband(questFlag, QUEST_FLAG.DAILY) ~= 0 then
					questType = Enum.BattlePass.QuestType.Daily
				elseif bitband(questFlag, QUEST_FLAG.WEEKLY) ~= 0 then
					questType = Enum.BattlePass.QuestType.Weekly
				end

				local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], replacedQuestID)

				if questIndex and PRIVATE.QUEST_LIST[replacedQuestID] then
					PRIVATE.QUEST_LIST_TYPED[questType][questIndex] = questID

					if questType ~= PRIVATE.QUEST_LIST[replacedQuestID].type then
						GMError(strformat("REPLACE_QUEST recived replacement with different questType (old questID `%s` new questID`%s`)", replacedQuestID, questID))
					end
				else
					tinsert(PRIVATE.QUEST_LIST_TYPED[questType], questID)
					questIndex = #PRIVATE.QUEST_LIST_TYPED[questType]

					GMError(strformat("REPLACE_QUEST replaced unlisted questID `%s`", replacedQuestID))
				end

				PRIVATE.QUEST_LIST[replacedQuestID] = nil
				PRIVATE.QUEST_LIST[questID] = {
					type			= questType,
					flags			= questFlag,
					rewardAmount	= tonumber(rewardAmount),
					rerollsDone		= tonumber(rerollsDone),
					totalValue		= tonumber(totalValue),
					currentValue	= tonumber(currentValue),
					state			= tonumber(state),
				}

				PRIVATE.QUEST_REPLACE_AWAIT[replacedQuestID] = nil
				PRIVATE.ParseQuestTooltip(questID)
				FireCustomClientEvent("BATTLEPASS_QUEST_REPLACED", questType, questIndex)
			else
				PRIVATE.HandleStatusMessage(status)
				PRIVATE.QUEST_REPLACE_AWAIT[replacedQuestID] = nil

				if PRIVATE.QUEST_LIST[replacedQuestID] then
					local questType = PRIVATE.QUEST_LIST[replacedQuestID].type
					local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], replacedQuestID)
					FireCustomClientEvent("BATTLEPASS_QUEST_REPLACE_FAILED", questType, questIndex)
				end

				GMError(strformat("BATTLEPASS_REPLACE_QUEST error #%i for questID `%s`", status, replacedQuestID), 1)
			end
		elseif prefix == "ASMSG_BATTLEPASS_QUEST_REWARD" then
			local status, questID = strsplit(":", msg)
			status = tonumber(status)
			questID = tonumber(questID)

			if questID and questID ~= 0 then
				local questType = PRIVATE.QUEST_LIST[questID].type
				local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], questID)

				if status == QUEST_MSG_STATUS.OK then
					PRIVATE.QUEST_LIST[questID] = nil
					tremove(PRIVATE.QUEST_LIST_TYPED[questType], questIndex)
					PRIVATE.QUEST_REWARD_AWAIT[questID] = nil

					FireCustomClientEvent("BATTLEPASS_QUEST_REWARD_RECIVED", questType, questIndex)
					FireCustomClientEvent("BATTLEPASS_QUEST_DONE", questType, questIndex)
				else
					PRIVATE.HandleStatusMessage(status)
					if questType and questIndex then
						FireCustomClientEvent("BATTLEPASS_QUEST_REWARD_FAILED", questType, questIndex)
					end
				end
			else
				GMError(strformat("ASMSG_BATTLEPASS_QUEST_REWARD has no questID (%s)", msg))
			end
		elseif prefix == "ASMSG_PVP_LIMITS_TIMERS" then
			local dailyResetTime, weeklyResetTime = strsplit(":", msg)
			CUSTOM_BATTLEPASS_CACHE.DAILY_RESET_TIME = time() + tonumber(dailyResetTime)
			CUSTOM_BATTLEPASS_CACHE.WEEKLY_RESET_TIME = time() + tonumber(weeklyResetTime)
			FireCustomClientEvent("BATTLEPASS_QUEST_RESET_TIMER_UPDATE")
		end
	elseif event == "CHAT_MSG_LOOT" then
		local text = ...
		local itemID, amount = strmatch(text, "|Hitem:(%d+).+|h|r.*x(%d+)%.?$")

		amount = tonumber(amount)
		if not amount then
			itemID = strmatch(text, "|Hitem:(%d+)")
			amount = 1
		end

		itemID = tonumber(itemID)
		if itemID and itemID == PRIVATE.STORE_AWAIT_ITEMID then
			if PRIVATE.IsExperienceItem(itemID) or PRIVATE.IsPremiumItem(itemID) then
				PRIVATE.eventHandler:UnregisterEvent("CHAT_MSG_LOOT")
				PRIVATE.LAST_PURCHASED_ITEM_ID = itemID
				PRIVATE.LAST_PURCHASED_ITEM_AMOUNT = amount

				FireCustomClientEvent("BATTLEPASS_ITEM_PURCHASED", itemID, amount)
			end
		end
	elseif event == "VARIABLES_LOADED" then
		CUSTOM_BATTLEPASS_CACHE = _G.CUSTOM_BATTLEPASS_CACHE or {}
		if not CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN then
			CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN = {}
		end

		PRIVATE.ENABLED = CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME ~= nil

		if not IsInterfaceDevClient() then
			_G.CUSTOM_BATTLEPASS_CACHE = nil
		else
			_G.BP = PRIVATE
		end

		BATTLEPASS_LEVELS = _G.BATTLEPASS_LEVELS
		BATTLEPASS_LEVEL_REWARDS = _G.BATTLEPASS_LEVEL_REWARDS
		_G.BATTLEPASS_LEVELS = nil
		_G.BATTLEPASS_LEVEL_REWARDS = nil

		PRIVATE.InitializeTooltip()
		PRIVATE.InitializeLevelData()
		PRIVATE.InitializeRewardData()

		if PRIVATE.ENABLED then
			FireCustomClientEvent("BATTLEPASS_ACCOUNT_UPDATE", CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE, CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME)
			FireCustomClientEvent("BATTLEPASS_EXPERIENCE_UPDATE", CUSTOM_BATTLEPASS_CACHE.LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE)
			FireCustomClientEvent("BATTLEPASS_POINTS_UPDATE")
			FireCustomClientEvent("BATTLEPASS_QUEST_RESET_TIMER_UPDATE")
		end
	elseif event == "PLAYER_LOGOUT" then
		_G.CUSTOM_BATTLEPASS_CACHE = CUSTOM_BATTLEPASS_CACHE
	end
end)
PRIVATE.eventHandler:SetScript("OnAttributeChanged", function(self, name, value)
	if name == "state" then
		if value == "use" then
			local itemID = self:GetAttribute("itemID")
			local amount = self:GetAttribute("amount")
			if not itemID then
				self:SetAttribute("state", "clear")
				return
			end

			local NUM_BAG_FRAMES = 4
			for containerID = 0, NUM_BAG_FRAMES do
				local numSlots = GetContainerNumSlots(containerID)
				local slotID = 1
				while slotID < numSlots do
					if itemID == GetContainerItemID(containerID, slotID) then
						UseContainerItem(containerID, slotID)
						amount = amount - 1

						if amount == 0 then
							self:SetAttribute("state", "clear")
							return
						end
					else
						slotID = slotID + 1
					end
				end
			end

			self:SetAttribute("state", "clear")
		elseif value == "clear" then
			self:SetAttribute("itemID", nil)
			self:SetAttribute("amount", nil)
			self:SetAttribute("state", nil)
		end
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	PRIVATE.ProcessQuestParseQueue()
end)

PRIVATE.IsEnabled = function()
	return PRIVATE.ENABLED
end

PRIVATE.HandleStatusMessage = function(status)
	if status == QUEST_MSG_STATUS.OK then
		-- pass
	elseif status == QUEST_MSG_STATUS.DATA_ERROR then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_QUEST_MSG_STATUS_DATA_ERROR)
	elseif status == QUEST_MSG_STATUS.NOT_ENOUGH_MONEY then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", ERR_NOT_ENOUGH_GOLD)
	elseif status == QUEST_MSG_STATUS.INVALIDE_QUEST then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_QUEST_MSG_STATUS_INVALIDE_QUEST)
	elseif status == QUEST_MSG_STATUS.DONT_HAVE_QUEST then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_QUEST_MSG_STATUS_DONT_HAVE_QUEST)
	elseif status == QUEST_MSG_STATUS.QUEST_NOT_COMPLETE then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_QUEST_MSG_STATUS_QUEST_NOT_COMPLETE)
	end
end

PRIVATE.InitializeLevelData = function()
	PRIVATE.MAX_LEVEL = #BATTLEPASS_LEVELS

	PRIVATE.LEVEL_INFO[0] = {
		totalLevelExperience = 0,
		requiredExperience = BATTLEPASS_LEVELS[1] or 0,
	}

	local requiredExperience = BATTLEPASS_LEVELS[PRIVATE.MAX_LEVEL]
	PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL] = {
		totalLevelExperience = requiredExperience + BATTLEPASS_LEVELS[PRIVATE.MAX_LEVEL - 1],
		requiredExperience = requiredExperience,
	}

	for level = PRIVATE.MAX_LEVEL - 1, 1, -1 do
		local totalLevelExperience = BATTLEPASS_LEVELS[level]
		PRIVATE.LEVEL_INFO[level] = {
			totalLevelExperience = totalLevelExperience,
			requiredExperience = PRIVATE.LEVEL_INFO[level + 1].totalLevelExperience - totalLevelExperience,
		}
	end
end

PRIVATE.InitializeRewardData = function()
	for level, items in ipairs(BATTLEPASS_LEVEL_REWARDS) do
		for _, item in ipairs(items) do
			local itemID = item[2]
			PRIVATE.LEVEL_REWARD_ITEMS[itemID] = true
		end
	end
end

PRIVATE.InitializeTooltip = function()
	PRIVATE.tooltip = CreateFrame("GameTooltip")
	PRIVATE.tooltip:Hide()

	PRIVATE.tooltip.linesLeft = {}
	PRIVATE.tooltip.linesRight = {}

	for i = 1, 3 do
		local leftLine = PRIVATE.tooltip:CreateFontString(nil, nil, "GameTooltipText")
		local rightLine = PRIVATE.tooltip:CreateFontString(nil, nil, "GameTooltipText")

		PRIVATE.tooltip.linesLeft[i] = leftLine
		PRIVATE.tooltip.linesRight[i] = rightLine
		PRIVATE.tooltip:AddFontStrings(leftLine, rightLine)
	end
end

PRIVATE.ProcessQuestParseQueue = function()
	local index = 1
	while index <= #PRIVATE.QUEST_PARSE_QUEUE do
		local questID = PRIVATE.QUEST_PARSE_QUEUE[index]
		if PRIVATE.ParseQuestTooltip(questID, true) then
			tremove(PRIVATE.QUEST_PARSE_QUEUE, index)

			local questType = PRIVATE.QUEST_LIST[questID].type
			local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], questID)
			FireCustomClientEvent("BATTLEPASS_QUEST_UPDATE_TEXT", questType, questIndex)
		else
			index = index + 1
		end
	end

	if #PRIVATE.QUEST_PARSE_QUEUE == 0 then
		PRIVATE.eventHandler:Hide()
	end
end

PRIVATE.ParseQuestTooltip = function(questID, rescan)
	if PRIVATE.QUEST_PARSED[questID] then
		return true
	end

	PRIVATE.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	PRIVATE.tooltip:SetHyperlink(strformat("quest:%i", questID))

	local title = PRIVATE.tooltip.linesLeft[1]:GetText()
	if not title then
		if not rescan then
			tinsert(PRIVATE.QUEST_PARSE_QUEUE, questID)
			PRIVATE.eventHandler:Show()
		end
		return false
	end

	local desc = PRIVATE.tooltip.linesLeft[3]:GetText()
	PRIVATE.QUEST_PARSED[questID] = {strtrim(title), strtrim(desc or "")}

	return true
end

PRIVATE.SortQuests = function(a, b)
	return a < b
end

PRIVATE.SortProductsByID = function(a, b)
	return a[PRODUCT_DATA.PRODUCT_ID] < b[PRODUCT_DATA.PRODUCT_ID]
end

PRIVATE.UpdateStoreData = function()
	if PRIVATE.storeProductsUpdated then
		return true
	end

	local storeData = STORE_PRODUCT_CACHE and STORE_PRODUCT_CACHE[STORE_CURRENCY] and STORE_PRODUCT_CACHE[STORE_CURRENCY][STORE_CATEGORY]
	if storeData then
		local premiumProducts = storeData[STORE_SUBCATEGORY_PREMIUM]
		if premiumProducts and premiumProducts[0] and premiumProducts[0].data then
			local productID, product = next(premiumProducts[0].data)
			PRIVATE.PRODUCT_PREMIUM = product
		else
			PRIVATE.PRODUCT_PREMIUM = nil
		end

		twipe(PRIVATE.PRODUCT_EXPERIENCE_LIST)

		local experienceProducts = storeData[STORE_SUBCATEGORY_EXPERIENCE]
		if experienceProducts and experienceProducts[0] and experienceProducts[0].data then
			for productID, product in pairs(experienceProducts[0].data) do
				tinsert(PRIVATE.PRODUCT_EXPERIENCE_LIST, product)
			end

			tsort(PRIVATE.PRODUCT_EXPERIENCE_LIST, PRIVATE.SortProductsByID)

			for index, product in ipairs(PRIVATE.PRODUCT_EXPERIENCE_LIST) do
				local price, originalPrice, currency, altCurrency, altPrice = PRIVATE.GetProductPrice(product)
				PURCHASE_EXPERIENCE_OPTIONS[index].price = price
				PURCHASE_EXPERIENCE_OPTIONS[index].originalPrice = 0
				PURCHASE_EXPERIENCE_OPTIONS[index].currencyType = Enum.Store.CurrencyType.Bonus
				PURCHASE_EXPERIENCE_OPTIONS[index].experience = EXPERIENCE_ITEMS[product[PRODUCT_DATA.ITEM_ID]] or 0
			end
		end

		PRIVATE.storeProductsUpdated = PRIVATE.PRODUCT_PREMIUM and #PRIVATE.PRODUCT_EXPERIENCE_LIST > 0

		return true
	end

	return false
end

PRIVATE.GetProductPrice = function(product)
	local price = product[PRODUCT_DATA.PRICE]
	local discount = product[PRODUCT_DATA.DISCOUNT] and product[PRODUCT_DATA.DISCOUNT_PRICE] or 0
	local currency = Enum.Store.CurrencyType.Bonus
	local altCurrency = product[PRODUCT_DATA.ALT_CURRENCY]
	local altPrice = product[PRODUCT_DATA.ALT_PRICE]

	return price, discount, currency, altCurrency, altPrice
end

PRIVATE.GetPremiumPrice = function()
	if PRIVATE.UpdateStoreData() and PRIVATE.PRODUCT_PREMIUM then
		local price, originalPrice, currency, altCurrency, altPrice = PRIVATE.GetProductPrice(PRIVATE.PRODUCT_PREMIUM)
		return price, 0, currency
	end

	return -1, 0, 0
end

PRIVATE.IsLevelRewardItem = function(itemID)
	return PRIVATE.LEVEL_REWARD_ITEMS[itemID] ~= nil
end

PRIVATE.IsExperienceItem = function(itemID)
	return EXPERIENCE_ITEMS[itemID] ~= nil
end

PRIVATE.IsPremiumItem = function(itemID)
	return PREMIUM_ITEMS[itemID] ~= nil
end

PRIVATE.GetExperienceOptionProduct = function(optionIndex)
	if PRIVATE.UpdateStoreData() then
		return PRIVATE.PRODUCT_EXPERIENCE_LIST[optionIndex]
	end
end

PRIVATE.GetQuestTypeTimeLeft = function(questType)
	local changed = false

	if questType == Enum.BattlePass.QuestType.Daily then
		if CUSTOM_BATTLEPASS_CACHE.DAILY_RESET_TIME then
			local now = time()
			local timestamp = CUSTOM_BATTLEPASS_CACHE.DAILY_RESET_TIME - now
			if timestamp <= 0 then
				CUSTOM_BATTLEPASS_CACHE.DAILY_RESET_TIME = now + timestamp + SECONDS_PER_DAY
				timestamp = CUSTOM_BATTLEPASS_CACHE.DAILY_RESET_TIME - now
				changed = true
				PRIVATE.RESET_TIMER_CHANGER = true
			end

			return timestamp, changed
		end
	elseif questType == Enum.BattlePass.QuestType.Weekly then
		if CUSTOM_BATTLEPASS_CACHE.WEEKLY_RESET_TIME then
			local now = time()
			local timestamp = CUSTOM_BATTLEPASS_CACHE.WEEKLY_RESET_TIME - now
			if timestamp <= 0 then
				CUSTOM_BATTLEPASS_CACHE.WEEKLY_RESET_TIME = now + timestamp + SECONDS_PER_DAY * 7
				timestamp = CUSTOM_BATTLEPASS_CACHE.WEEKLY_RESET_TIME - now
				changed = true
				PRIVATE.RESET_TIMER_CHANGER = true
			end

			return timestamp, changed
		end
	end

	return 0, changed
end

PRIVATE.GetMaxLevel = function()
	return mathmax(PRIVATE.MAX_LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL)
end

PRIVATE.GetNumVisiableCards = function()
	return mathmax(CUSTOM_BATTLEPASS_CACHE.LEVEL + 10, PRIVATE.GetMaxLevel())
end

PRIVATE.GetLevelByExperience = function(experience)
	local maxLevelExperience = PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].totalLevelExperience
	local isBonusLevel = experience >= maxLevelExperience
	if isBonusLevel then
		experience = experience - maxLevelExperience
		local level = mathfloor(experience / PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].requiredExperience)
		local levelExperience = experience % PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].requiredExperience
		return PRIVATE.MAX_LEVEL + level, levelExperience
	end

	for levelIndex, levelInfo in ipairs(PRIVATE.LEVEL_INFO) do
		if experience < levelInfo.totalLevelExperience then
			local level = levelIndex - 1
			local levelExperience = experience - PRIVATE.LEVEL_INFO[level].totalLevelExperience

			return level, levelExperience
		end
	end

	return 0, experience
end

PRIVATE.GetLevelRewardsFlag = function(rewardType)
	if rewardType == Enum.BattlePass.RewardType.Premium then
		return 2
	else
		return 1
	end
end

PRIVATE.IsCardRewardAvailable = function(level, rewardType)
	if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] then
		return bitband(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level], PRIVATE.GetLevelRewardsFlag(rewardType)) == 0
	end
	return true
end

PRIVATE.GetLevelRewards = function(level)
	local freeItems = {}
	local premiumItems = {}

	local faction = UnitFactionGroup("player")
	local factionFlag = ITEM_REWARD_FLAG[faction]

	for _, item in ipairs(BATTLEPASS_LEVEL_REWARDS[mathmin(level, PRIVATE.MAX_LEVEL)]) do
		local itemType, itemID, amount, flags = unpack(item, 1, 4)
		if flags == 0 or bitband(flags, factionFlag) ~= 0 then
			if itemType == Enum.BattlePass.RewardType.Premium then
				tinsert(premiumItems, {itemID = itemID, amount = amount})
			else
				tinsert(freeItems, {itemID = itemID, amount = amount})
			end
		end
	end

	return freeItems, premiumItems
end

PRIVATE.IsQuestComplete = function(questID)
	local quest = PRIVATE.QUEST_LIST[questID]
	if quest then
		return quest.state == Enum.BattlePass.QuestState.Complete
	end
	return false
end

PRIVATE.GetQuestReplacePrice = function(questID)
	return PRIVATE.QUEST_LIST[questID].rerollsDone * CUSTOM_BATTLEPASS_CACHE.REROLL_PRICE
end

C_BattlePass = {}

function C_BattlePass.IsEnabled()
	return PRIVATE.IsEnabled()
end

function C_BattlePass.GetMaxLevel()
	return PRIVATE.MAX_LEVEL - 1
end

function C_BattlePass.GetSourceExperience()
	return CUSTOM_BATTLEPASS_CACHE.POINTS_BG or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_SOLOQ or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_V1 or 0
end

function C_BattlePass.GetLevelInfo()
	if not PRIVATE.IsEnabled() then
		return 0, 0, 0
	end

	local requiredExperience
	if CUSTOM_BATTLEPASS_CACHE.LEVEL < PRIVATE.MAX_LEVEL then
		requiredExperience = PRIVATE.LEVEL_INFO[CUSTOM_BATTLEPASS_CACHE.LEVEL].requiredExperience
	else
		requiredExperience = PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].requiredExperience
	end

	return CUSTOM_BATTLEPASS_CACHE.LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE, requiredExperience
end

function C_BattlePass.CalculateAddedExperience(experience)
	if not PRIVATE.IsEnabled() then
		return 0, 0, 0
	end

	if type(experience) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.CalculateAddedExperience' (number expected, got %s)", type(experience)), 2)
	end

	local newExp = CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL + experience
	local level, levelExp = PRIVATE.GetLevelByExperience(newExp)
	local requiredExperience

	if level < PRIVATE.MAX_LEVEL then
		requiredExperience = PRIVATE.LEVEL_INFO[level].requiredExperience
	else
		requiredExperience = PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].requiredExperience
	end

	return level, levelExp, requiredExperience
end

function C_BattlePass.IsLevelRewardItem(itemID)
	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.IsLevelRewardItem' (number expected, got %s)", type(itemID)), 2)
	end
	return PRIVATE.IsLevelRewardItem(itemID)
end

function C_BattlePass.IsPremiumItem(itemID)
	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.IsPremiumItem' (number expected, got %s)", type(itemID)), 2)
	end
	return PRIVATE.IsPremiumItem(itemID)
end

function C_BattlePass.IsExperienceItem(itemID)
	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.IsExperienceItem' (number expected, got %s)", type(itemID)), 2)
	end
	return PRIVATE.IsExperienceItem(itemID)
end

function C_BattlePass.IsBattlePassItem(itemID)
	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.IsBattlePassItem' (number expected, got %s)", type(itemID)), 2)
	end
	return PRIVATE.IsPremiumItem(itemID) or PRIVATE.IsExperienceItem(itemID) or PRIVATE.IsLevelRewardItem(itemID)
end

function C_BattlePass.GetExperienceItemExpAmount(itemID)
	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.IsExperienceItem' (number expected, got %s)", type(itemID)), 2)
	end
	return EXPERIENCE_ITEMS[itemID] or 0
end

function C_BattlePass.GetPremiumPrice()
	return PRIVATE.GetPremiumPrice()
end

function C_BattlePass.IsPremiumActive()
	if not PRIVATE.IsEnabled() then
		return false
	end
	return CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE or false
end

function C_BattlePass.GetSeasonTimeLeft()
	if not PRIVATE.IsEnabled() then
		return 0
	end
	return CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME or 0
end

function C_BattlePass.GetNumLevelCards()
	if not PRIVATE.IsEnabled() then
		return 0
	end
	return PRIVATE.GetNumVisiableCards()
end

function C_BattlePass.GetLevelCardRewardInfo(cardIndex)
	if not PRIVATE.IsEnabled() then
		return 0, 0, 0, 0, {}, {}
	end

	if type(cardIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.GetLevelCardRewardInfo' (number expected, got %s)", type(cardIndex)), 2)
	elseif cardIndex < 1 or cardIndex > PRIVATE.GetNumVisiableCards() then
		error(strformat("cardIndex out of range `%i`", cardIndex), 2)
	end

	local level = cardIndex
	local freeItems, premiumItems = PRIVATE.GetLevelRewards(cardIndex)

	local freeState, premiumState, shieldState
	if cardIndex > CUSTOM_BATTLEPASS_CACHE.LEVEL then
		freeState = Enum.BattlePass.CardState.Default
		premiumState = Enum.BattlePass.CardState.Default
		shieldState = Enum.BattlePass.CardState.Default
	else
		if PRIVATE.IsCardRewardAvailable(level, Enum.BattlePass.RewardType.Free) then
			freeState = Enum.BattlePass.CardState.LootAvailable
		else
			freeState = Enum.BattlePass.CardState.Looted
		end

		if PRIVATE.IsCardRewardAvailable(level, Enum.BattlePass.RewardType.Premium) then
			premiumState = Enum.BattlePass.CardState.LootAvailable
		else
			premiumState = Enum.BattlePass.CardState.Looted
		end

		if freeState == Enum.BattlePass.CardState.LootAvailable
		or premiumState == Enum.BattlePass.CardState.LootAvailable
		then
			shieldState = Enum.BattlePass.CardState.LootAvailable
		else
			shieldState = Enum.BattlePass.CardState.Looted
		end
	end

	return level, freeState, premiumState, shieldState, freeItems, premiumItems
end

function C_BattlePass.TakeLevelReward(cardIndex, rewardType)
	if not PRIVATE.IsEnabled() then
		return
	end

	if type(cardIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.TakeLevelReward' (number expected, got %s)", type(cardIndex)), 2)
	elseif type(rewardType) ~= "number" then
		error(strformat("bad argument #2 to 'C_BattlePass.TakeLevelReward' (number expected, got %s)", type(rewardType)), 2)
	elseif cardIndex < 1 or cardIndex > PRIVATE.GetMaxLevel() then
		error(strformat("cardIndex out of range `%i`", cardIndex), 2)
	elseif rewardType < 0 or rewardType > 1 then
		error(strformat("rewardType out of range `%i`", rewardType), 2)
	end

	tinsert(PRIVATE.LEVEL_REWARD_AWAIT, {level = cardIndex, rewardType = rewardType})
	SendServerMessage("ACMSG_BATTLEPASS_TAKE_REWARD", strformat("%u:%u", cardIndex, rewardType))
end

function C_BattlePass.GetLevelCardWithRewardItemID(itemID)
	if not PRIVATE.IsEnabled() then
		return
	end

	if type(itemID) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.GetLevelCardWithRewardItemID' (number expected, got %s)", type(itemID)), 2)
	end

	for level, items in ipairs(BATTLEPASS_LEVEL_REWARDS) do
		for _, item in ipairs(items) do
			if item[LEVEL_REWARD.ITEM_ID] == itemID then
				return level
			end
		end
	end
end

function C_BattlePass.HasUnclaimedReward()
	if not PRIVATE.IsEnabled() or CUSTOM_BATTLEPASS_CACHE.LEVEL == 0 then
		return false
	end

	local claimedMask = PRIVATE.GetLevelRewardsFlag(Enum.BattlePass.RewardType.Free)
	if CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE then
		claimedMask = claimedMask + PRIVATE.GetLevelRewardsFlag(Enum.BattlePass.RewardType.Premium)
	end

	for level = 1, CUSTOM_BATTLEPASS_CACHE.LEVEL do
		if not CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level]
		or CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN == 0
		or CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN ~= claimedMask
		then
			return level
		end
	end
end

function C_BattlePass.RequestQuests()
	if not PRIVATE.IsEnabled() then
		return
	end

	if PRIVATE.QUESTS_REQUESTED and not PRIVATE.RESET_TIMER_CHANGER then
		local _, changedDaily = PRIVATE.GetQuestTypeTimeLeft(Enum.BattlePass.QuestType.Daily)
		local _, changedWeekly = PRIVATE.GetQuestTypeTimeLeft(Enum.BattlePass.QuestType.Weekly)
		if not changedDaily and not changedWeekly then
			return
		end
	end

	PRIVATE.QUESTS_REQUESTED = true
	PRIVATE.QUEST_REFRESH = true
	PRIVATE.RESET_TIMER_CHANGER = nil
	SendServerMessage("ACMSG_BATTLEPASS_QUESTS_REQUEST")
end

function C_BattlePass.HasCompleteQuests()
	if not PRIVATE.IsEnabled() then
		return false
	end

	for _, questList in ipairs(PRIVATE.QUEST_LIST_TYPED) do
		for _, questID in ipairs(questList) do
			if PRIVATE.IsQuestComplete(questID) then
				return true
			end
		end
	end

	return false
end

PRIVATE.ValidateQuestTypeArgs = function(funcName, questType)
	if type(questType) ~= "number" then
		error(strformat("bad argument #1 to '%s' (number expected, got %s)", funcName, type(questType)), 3)
	elseif questType < 1 or questType > #PRIVATE.QUEST_LIST_TYPED then
		error(strformat("questTypeIndex out of range `%i`", questType), 3)
	end
end

PRIVATE.ValidateQuestArgs = function(funcName, questType, questIndex)
	if type(questType) ~= "number" then
		error(strformat("bad argument #1 to '%s' (number expected, got %s)", funcName, type(questType)), 3)
	elseif type(questIndex) ~= "number" then
		error(strformat("bad argument #2 to '%s' (number expected, got %s)", type(questIndex)), 3)
	elseif questType < 1 or questType > #PRIVATE.QUEST_LIST_TYPED then
		error(strformat("questTypeIndex out of range `%i`", questType), 3)
	elseif questIndex < 1 or questIndex > #PRIVATE.QUEST_LIST_TYPED[questType] then
		error(strformat("questIndex out of range `%i`", questIndex), 3)
	end
end

function C_BattlePass.GetQuestTypeTimeLeft(questType)
	if not PRIVATE.IsEnabled() then
		return 0
	end

	PRIVATE.ValidateQuestTypeArgs("C_BattlePass.GetQuestTypeTimeLeft", questType)

	return (PRIVATE.GetQuestTypeTimeLeft(questType))
end

function C_BattlePass.GetNumQuests(questType)
	if not PRIVATE.IsEnabled() then
		return 0
	end

	PRIVATE.ValidateQuestTypeArgs("C_BattlePass.GetNumQuests", questType)
	return #PRIVATE.QUEST_LIST_TYPED[questType]
end

function C_BattlePass.GetQuestInfo(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return "", "", 0, 0, 0, false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.GetQuestInfo", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	local quest = PRIVATE.QUEST_LIST[questID]

	local name, description
	local questTextData = PRIVATE.QUEST_PARSED[questID]
	if questTextData then
		name, description = unpack(questTextData, 1, 2)
	end

	local rewardAmount = quest.rewardAmount
	local isPercents = bitband(quest.flags, QUEST_FLAG.SHOW_PERCENT) ~= 0
	local progressValue, progressMaxValue

	if PRIVATE.IsQuestComplete(questID) then
		progressMaxValue = mathmax(quest.totalValue, 1)
		progressValue = progressMaxValue
	elseif isPercents then
		progressMaxValue = 100
		progressValue = RoundToSignificantDigits(quest.currentValue / quest.totalValue * 100, 2)
	else
		progressMaxValue = quest.totalValue
		progressValue = quest.currentValue
	end

	return name or "", description or "", rewardAmount, progressValue, progressMaxValue, isPercents
end

function C_BattlePass.IsQuestComplete(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.IsQuestComplete", questType, questIndex)
	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	return PRIVATE.IsQuestComplete(questID)
end

function C_BattlePass.IsAwaitingQuestAction(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.IsAwaitingQuestAction", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	return PRIVATE.QUEST_REPLACE_AWAIT[questID] or PRIVATE.QUEST_REWARD_AWAIT[questID] and true or false
end

function C_BattlePass.GetQuestReplacePrice(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return 0
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.GetQuestReplacePrice", questType, questIndex)

	if questType == Enum.BattlePass.QuestType.Weekly and not ALLOW_WEEKLY_QUEST_REROLL then
		return 0
	end

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	return PRIVATE.GetQuestReplacePrice(questID)
end

function C_BattlePass.IsQuestReplaceAllowed(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.IsQuestReplaceAllowed", questType, questIndex)

	if questType == Enum.BattlePass.QuestType.Weekly and not ALLOW_WEEKLY_QUEST_REROLL then
		return false
	end

	return true
end

function C_BattlePass.CanReplaceQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.CanReplaceQuest", questType, questIndex)

	if questType == Enum.BattlePass.QuestType.Weekly and not ALLOW_WEEKLY_QUEST_REROLL then
		return false
	end

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]

	if PRIVATE.IsQuestComplete(questID) then
		return false
	end

	return PRIVATE.GetQuestReplacePrice(questID) <= GetMoney() or IsGMAccount()
end

function C_BattlePass.ReplaceQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.ReplaceQuest", questType, questIndex)

	if questType == Enum.BattlePass.QuestType.Weekly and not ALLOW_WEEKLY_QUEST_REROLL then
		return
	end

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if not PRIVATE.IsQuestComplete(questID) and not PRIVATE.QUEST_REPLACE_AWAIT[questID] then
		PRIVATE.QUEST_REPLACE_AWAIT[questID] = true
		FireCustomClientEvent("BATTLEPASS_QUEST_ACTION_AWAIT", questType, questIndex)
		SendServerMessage("ACMSG_BATTLEPASS_REPLACE_QUEST", questID)
	end
end

function C_BattlePass.CollectQuestReward(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.CollectQuestReward", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if PRIVATE.IsQuestComplete(questID) and not PRIVATE.QUEST_REWARD_AWAIT[questID] then
		PRIVATE.QUEST_REWARD_AWAIT[questID] = true
		FireCustomClientEvent("BATTLEPASS_QUEST_ACTION_AWAIT", questType, questIndex)
		SendServerMessage("ACMSG_BATTLEPASS_QUEST_REWARD", questID)
	end
end

function C_BattlePass.RequestProductData()
	if not PRIVATE.PRODUCTS_REQUESTED then
		PRIVATE.PRODUCTS_REQUESTED = true
		StoreRequestBattlePass()
	end
end

function C_BattlePass.GetNumExperiencePurchaseOptions()
	if not PRIVATE.IsEnabled() then
		return 0
	end
	PRIVATE.UpdateStoreData()
	return #PRIVATE.PRODUCT_EXPERIENCE_LIST
end

function C_BattlePass.GetExperiencePurchaseOptionInfo(optionIndex)
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.UpdateStoreData()

	if type(optionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.GetExperiencePurchaseOptionInfo' (number expected, got %s)", type(optionIndex)), 2)
	elseif optionIndex < 1 or optionIndex > #PRIVATE.PRODUCT_EXPERIENCE_LIST then
		error(strformat("optionIndex out of range `%i`", optionIndex), 2)
	end

	return CopyTable(PURCHASE_EXPERIENCE_OPTIONS[optionIndex])
end

function C_BattlePass.PurchaseExperience(optionIndex, amount)
	if not PRIVATE.IsEnabled() then
		return
	end

	if type(optionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.PurchaseExperience' (number expected, got %s)", type(optionIndex)), 2)
	elseif type(amount) ~= "number" then
		error(strformat("bad argument #2 to 'C_BattlePass.PurchaseExperience' (number expected, got %s)", type(amount)), 2)
	elseif optionIndex < 1 or optionIndex > #PURCHASE_EXPERIENCE_OPTIONS then
		error(strformat("optionIndex out of range `%i`", optionIndex), 2)
	elseif amount < 1 then
		error(strformat("amount out of range `%i`", amount), 2)
	end

	PRIVATE.UpdateStoreData()

	local option = PURCHASE_EXPERIENCE_OPTIONS[optionIndex]
	local price = option.price * amount
	if price <= Store_GetBalance(option.currencyType) then
		local product = PRIVATE.GetExperienceOptionProduct(optionIndex)
		PRIVATE.STORE_AWAIT_ITEMID = product[PRODUCT_DATA.ITEM_ID]
		PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_LOOT")
		SendServerMessage("ACMSG_SHOP_BUY_ITEM", strformat("%i|%u|0|0|0", product[PRODUCT_DATA.PRODUCT_ID], amount))
	end
end

function C_BattlePass.PurchasePremium()
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.UpdateStoreData()

	local price, originalPrice, currency = PRIVATE.GetPremiumPrice()
	if price ~= -1 then
		if price <= Store_GetBalance(currency) then
			PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_LOOT")
			PRIVATE.STORE_AWAIT_ITEMID = PRIVATE.PRODUCT_PREMIUM[PRODUCT_DATA.ITEM_ID]
			SendServerMessage("ACMSG_SHOP_BUY_ITEM", strformat("%i|1|0|0|0", PRIVATE.PRODUCT_PREMIUM[PRODUCT_DATA.PRODUCT_ID]))
		else
			FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", STORE_BUY_ITEM_ERROR_5)
		end
	else
		GMError("No premium product id avaliable")
	end
end

function C_BattlePass.UsePurchasedItem()
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.UpdateStoreData()

	if not PRIVATE.LAST_PURCHASED_ITEM_ID or UnitIsDeadOrGhost("player") then
		return
	end

	local itemID = PRIVATE.LAST_PURCHASED_ITEM_ID
	local amount = PRIVATE.LAST_PURCHASED_ITEM_AMOUNT

	PRIVATE.LAST_PURCHASED_ITEM_ID = nil
	PRIVATE.LAST_PURCHASED_ITEM_AMOUNT = nil

	RunNextFrame(function()
		PRIVATE.eventHandler:SetAttribute("itemID", itemID)
		PRIVATE.eventHandler:SetAttribute("amount", amount)
		PRIVATE.eventHandler:SetAttribute("state", "use")

		FireCustomClientEvent("BATTLEPASS_PURCHASED_ITEM_USED")
	end)
end