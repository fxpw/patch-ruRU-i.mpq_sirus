local error = error
local ipairs = ipairs
local next = next
local pairs = pairs
local scrub = scrub
local time = time
local tonumber = tonumber
local type = type
local unpack = unpack
local bitband, bitbnot, bitbor, bitlshift = bit.band, bit.bnot, bit.bor, bit.lshift
local mathfloor, mathmax, mathmin = math.floor, math.max, math.min
local strformat, strmatch, strsplit, strtrim = string.format, string.match, string.split, string.trim
local tIndexOf, tconcat, tinsert, tremove, tsort, twipe = tIndexOf, table.concat, table.insert, table.remove, table.sort, table.wipe

local GetContainerItemID = GetContainerItemID
local GetContainerNumSlots = GetContainerNumSlots
local GetMoney = GetMoney
local UnitFactionGroup = UnitFactionGroup
local UnitName = UnitName
local UseContainerItem = UseContainerItem

local CopyTable = CopyTable
local FireCustomClientEvent = FireCustomClientEvent
local IsInGMMode = C_Service.IsInGMMode
local RoundToSignificantDigits = RoundToSignificantDigits
local RunNextFrame = RunNextFrame
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx
local UpgradeLoadedVariables = UpgradeLoadedVariables

local BATTLEPASS_QUEST_LINK_FALLBACK_DAILY = BATTLEPASS_QUEST_LINK_FALLBACK_DAILY
local BATTLEPASS_QUEST_LINK_FALLBACK_WEEKLY = BATTLEPASS_QUEST_LINK_FALLBACK_WEEKLY

Enum.BattlePass = {}
Enum.BattlePass.CardState = {
	Unavailable = 0,
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
	[77080] = 400,
	[149192] = 800,
	[149193] = 4000,
	[149194] = 8000,
}

local PREMIUM_ITEMS = {
	[149195] = true,
	[149211] = true,
	[149212] = true,
}

local MODEL_FACING = math.rad(25)

local PURCHASE_EXPERIENCE_OPTIONS = {
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Sapphire-Highlight",
	},
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Emerald",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Emerald-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Emerald-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Emerald-Highlight",
	},
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Ruby",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Ruby-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Ruby-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Ruby-Highlight",
	},
	{
		iconAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst",
		iconAnimAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst-Animated",
		checkedAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst-Selected",
		highlightAtlas = "PKBT-BattlePass-Icon-Gem-Amethyst-Highlight",
	},
}

local SPLASH_DATA = {
	[1] = {
		title = BATTLE_PASS_SPLASH_NEW_SEASON_TITLE,
		artwork = "Custom-Splash-BattlePass-2023-1",
		buttonText = BATTLE_PASS_SPLASH_ACTION_LABLE,
		buttonPoint = {"BOTTOM", 0, 20},
	},
	[2] = {
		title = BATTLE_PASS_SPLASH_NEW_SEASON_TITLE,
		artwork = "Custom-Splash-BattlePass-2024-1",
		buttonText = SPLASH_ACTION_OPEN_LABLE,
		buttonWidth = 110,
		buttonPoint = {"CENTER", 0, 0},
		buttonNormalFont = "PKBT_Button_Font_18",
		buttonHighlightFont = "PKBT_ButtonHighlight_Font_18",
		buttonDisabledFont = "PKBT_ButtonDisable_Font_18",
		buttonNormalAtlas = "Custom-Splash-BattlePass-2024-1-Assets-Button",
		buttonHighlightAtlas = "Custom-Splash-BattlePass-2024-1-Assets-Button-Highlight",
	},
	[3] = {
		artwork = "Custom-Splash-BattlePass-2024-2",
		buttonText = SPLASH_ACTION_OPEN_LABLE,
		buttonWidth = 160,
		buttonPoint = {"BOTTOM", 0, -26},
		buttonNormalFont = "PKBT_Button_Font_18",
		buttonHighlightFont = "PKBT_ButtonHighlight_Font_18",
		buttonDisabledFont = "PKBT_ButtonDisable_Font_18",
		buttonTemplate = "PKBT-128-RedButton",
		buttonPushedOffsetX = 2, buttonPushedOffsetY = -2,
		models = {
			width = 100, height = 135,
			offsetX = 40, offsetY = 45,
			containerPoint = {"CENTER", 0, -25},
			cardBorderLayour = "SplashBattlePass_2024_2",
			cardBackgroundAtlas = "Custom-Splash-BattlePass-2024-2-Assets-Card-Background",
			items = {
				{157754, 153381, 110302, 155850, 155697},
			},
			modelHolderScales = {
				{1, 1, 1.5, 1, 1},
			},
		},
	},
	[4] = {
		artworkTemplate = "BattlePassSplashArtwork-2024-3-Template",
		models = {
			width = 180, height = 180,
			offsetX = 20, offsetY = 0,
			containerPoint = {"CENTER", 0, -10},
			cardBorderAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Card-Border",
			cardBackgroundAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Background",
			cardBackgroundGlowAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Card-BackgroundGlow",
			cardBackgroundGlowColors = {
				{{1, 0.72, 0.15}, {0.77, 0.38, 1}, {0.19, 0.58, 1}, {1, 0.4, 0.2}, nil},
			},
			items = {
				{157501, 157092, 110126, 157365, 157490},
			},
			modelScales = {
				{1.75, 1.75, 1.50, 1.40, 1.75},
			},
		},
	},
	[5] = {
		artworkTemplate = "BattlePassSplashArtwork-2024-4-Template",
		models = {
			width = 180, height = 180,
			offsetX = 20, offsetY = 0,
			containerPoint = {"CENTER", 0, -10},
			cardBorderAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Card-Border",
			cardBackgroundAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Background",
			cardBackgroundGlowAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Card-BackgroundGlow",
			cardBackgroundGlowColors = {
				{{0.01, 0.91, 0.93}, {0.01, 0.81, 0.83}, {0.01, 0.71, 0.73}, {0.01, 0.61, 0.63}, {0.01, 0.51, 0.53}},
			},
			items = {
				{157632, 157360, 110303, 157068, 157676},
			},
			itemBaseOverride = {
				{nil, nil, 136083, nil, nil},
			},
			modelScales = {
				{1.75, 1.75, 2.15, 1.40, 1.75},
			},
			modelFacing = {
				{MODEL_FACING, MODEL_FACING, nil, nil, nil},
			},
			modelPosOffset = {
				{nil, nil, {-1.5, 1, 1}, {0, 0.5, 0}, nil}
			},
		},
	},
	[6] = {
		artworkTemplate = "BattlePassSplashArtwork-2025-1-Template",
		models = {
			width = 180, height = 180,
			offsetX = 20, offsetY = 0,
			containerPoint = {"CENTER", 0, -10},
			cardBorderAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Card-Border",
			cardBackgroundAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Background",
			cardBackgroundGlowAtlas = "Custom-Splash-BattlePass-2024-3-Assets-Card-BackgroundGlow",
			cardBackgroundGlowColors = {
				{{0.01, 0.91, 0.93}, {0.01, 0.81, 0.83}, {0.01, 0.71, 0.73}, {0.01, 0.61, 0.63}, {0.01, 0.51, 0.53}},
			},
			items = {
				{157604, 157347, 110305, 153455, 157630},
			},
			itemBaseOverride = {
				{nil, nil, 136083, nil, nil},
			},
			modelScales = {
				{1.1, 1.70, 2.15, 1.70, 1.1},
			},
			modelFacing = {
				{MODEL_FACING, MODEL_FACING, nil, nil, nil},
			},
			modelPosOffset = {
				{nil, {0, 0, 0.1}, {-1.5, 1, 1}, nil, nil}
			},
		},
	},
}

local LEVEL_REWARD = {
	ITEM_TYPE = 1,
	ITEM_INDEX = 2,
	ITEM_ID = 3,
	AMOUNT_= 4,
	FLAGS = 5,
}

local ITEM_REWARD_FLAG = {
	ALLIANCE	= 1,
	HORDE		= 2,
	RENEGADE	= 4,
}

local QUEST_MSG_STATUS = {
	OK						= 0,
	QUEST_DATA_ERROR		= 1,
	NOT_ENOUGH_MONEY		= 2,
	INVALIDE_QUEST			= 3,
	DONT_HAVE_QUEST			= 4,
	QUEST_NOT_COMPLETE		= 5,
	QUEST_ALREADY_COMPLETE	= 6,
	REWARD_NOT_FOUND		= 7,
	REWARD_INV_FULL			= 8,
	ITEM_AMOUNT_LIMIT		= 9,
}

local QUEST_FLAG = {
	DAILY			= 0x1,
	WEEKLY			= 0x2,
	SHOW_PERCENT	= 0x4,
	NO_REPLACEMENT	= 0x8,
}

local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD = 100
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD

local SECONDS_PER_DAY = 24 * 60 * 60

local BATTLEPASS_LEVELS
local BATTLEPASS_LEVEL_REWARDS
local CUSTOM_BATTLEPASS_CACHE = {LEVEL_REWARD_TAKEN = {}, SEEN_QUEST = {}}

local ALLOW_DAILY_QUEST_CANCEL = true
local ALLOW_WEEKLY_QUEST_REROLL = false

local PRIVATE = {
	ENABLED = false,
	PER_REALM_DB = true,
	MAX_LEVEL = 1,
	SPLASH_ID = 6,

	LEVEL_INFO = {},
	LEVEL_REWARD_ITEMS = {},
	LEVEL_REWARD_AWAIT = {},
	LEVEL_REWARD_ALL_AWAIT = nil,

	QUEST_LIST = {},
	QUEST_LIST_TYPED = {
		[Enum.BattlePass.QuestType.Daily] = {},
		[Enum.BattlePass.QuestType.Weekly] = {},
	},
	QUEST_PARSED = {},
	QUEST_PARSE_QUEUE = {},

	QUEST_REPLACE_AWAIT = {},
	QUEST_CANCEL_AWAIT = {},
	QUEST_REWARD_AWAIT = {},
}

local C_StoreSecure
EventRegistry:RegisterFrameEventAndCallback("STORE_API_LOADED", function(owner, ...)
	C_StoreSecure = _G.C_StoreSecure
	EventRegistry:UnregisterFrameEventAndCallback("STORE_API_LOADED", owner)
end, "BattlePass")

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:RegisterEvent("VARIABLES_LOADED")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGIN")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGOUT")
PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_ADDON")

PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, msg, distribution, sender = ...
		if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
			return
		end

		if prefix == "ASMSG_BATTLEPASS_INFO" then
			local expTotal, isPremium, questDoneToday, seasonEndTime, dailyResetTime, weeklyResetTime, enabled = strsplit(":", msg)

			CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL = tonumber(expTotal) or 0
			CUSTOM_BATTLEPASS_CACHE.DAILY_QUESTS_DONE = tonumber(questDoneToday) or 0

			local level, levelExp = PRIVATE.GetLevelByExperience(CUSTOM_BATTLEPASS_CACHE.EXPERIENCE_TOTAL)
			CUSTOM_BATTLEPASS_CACHE.LEVEL = level
			CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE = levelExp

			CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE = isPremium == "1"

			seasonEndTime = tonumber(seasonEndTime) or 0
			CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME = seasonEndTime == 0 and 0 or seasonEndTime + time()

			CUSTOM_BATTLEPASS_CACHE.DAILY_RESET_TIME = time() + (tonumber(dailyResetTime) or -1)
			CUSTOM_BATTLEPASS_CACHE.WEEKLY_RESET_TIME = time() + (tonumber(weeklyResetTime) or -1)

			if not PRIVATE.VARIABLES_LOADED then
				PRIVATE.QUEUED_REWARD_WIPE = true
			end

			twipe(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN)
			CUSTOM_BATTLEPASS_CACHE.SEASON_END_QUEST_LIST = nil

			CUSTOM_BATTLEPASS_CACHE.ENABLED = (tonumber(enabled) or 1) == 1
			PRIVATE.ENABLED = CUSTOM_BATTLEPASS_CACHE.ENABLED
			PRIVATE.eventHandler:Show()

			if PRIVATE.ENABLED then
				FireCustomClientEvent("BATTLEPASS_SEASON_UPDATE", CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME)
				FireCustomClientEvent("BATTLEPASS_ACCOUNT_UPDATE", CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE)
				FireCustomClientEvent("BATTLEPASS_EXPERIENCE_UPDATE", CUSTOM_BATTLEPASS_CACHE.LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE)
				FireCustomClientEvent("BATTLEPASS_QUEST_RESET_TIMER_UPDATE")

				if PRIVATE.VARIABLES_LOADED then
					PRIVATE.FireSplashScreenEvent()
				end
			else
				if PRIVATE.VARIABLES_LOADED then
					twipe(CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST)
				else
					PRIVATE.QUEUED_SEEN_QUEST_WIPE = true
				end
				FireCustomClientEvent("BATTLEPASS_SEASON_UPDATE", 0)
				FireCustomClientEvent("BATTLEPASS_ACCOUNT_UPDATE", false)
				FireCustomClientEvent("BATTLEPASS_EXPERIENCE_UPDATE", 0, 0)
				FireCustomClientEvent("BATTLEPASS_QUEST_RESET_TIMER_UPDATE")
			end
		elseif prefix == "ASMSG_BATTLEPASS_SETTINGS" then
			local questRerollPrice, pointsBG, pointsArena, pointsArenaSoloQ, pointsArena1v1, pointsMiniGame = strsplit(":", msg)

			CUSTOM_BATTLEPASS_CACHE.REROLL_PRICE		= COPPER_PER_GOLD * (tonumber(questRerollPrice) or 1000)
			CUSTOM_BATTLEPASS_CACHE.POINTS_BG			= tonumber(pointsBG) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA		= tonumber(pointsArena) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_SOLOQ	= tonumber(pointsArenaSoloQ) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_V1		= tonumber(pointsArena1v1) or 0
			CUSTOM_BATTLEPASS_CACHE.POINTS_MINIGAME		= tonumber(pointsMiniGame) or 30

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
			for _, reward in ipairs({StringSplitEx(";", msg)}) do
				local level, rewardType, rewardFlag = strsplit(":", reward)

				level = tonumber(level)
				rewardType = tonumber(rewardType)
				rewardFlag = tonumber(rewardFlag)

				PRIVATE.SetLevelRewardFlag(level, rewardType, rewardFlag)
			end

			FireCustomClientEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
		elseif prefix == "ASMSG_BATTLEPASS_TAKE_REWARD" then
			local status, level, rewardType, rewardFlag = strsplit(":", msg)
			status = tonumber(status)
			level = tonumber(level)
			rewardType = tonumber(rewardType)
			rewardFlag = tonumber(rewardFlag)

			if status == QUEST_MSG_STATUS.OK then
				local newRewardsFlag = PRIVATE.SetLevelRewardFlag(level, rewardType, rewardFlag)

				if PRIVATE.RemoveLevelRewardTypeAwait(level, rewardType) then
					if newRewardsFlag ~= -1 then
						local items = PRIVATE.GetLevelRewards(level, rewardType, newRewardsFlag)
						FireCustomClientEvent("BATTLEPASS_REWARD_ITEMS", items)
					end
				end
			else
				PRIVATE.SetLevelRewardFlag(level, rewardType, rewardFlag)
				PRIVATE.RemoveLevelRewardTypeAwait(level, rewardType)

				local errorHandled = PRIVATE.HandleStatusMessage(status)
				if not errorHandled then
					GMError(strformat("ASMSG_BATTLEPASS_TAKE_REWARD error #%i for level `%s` and reward type `%s`", status, tostring(level), tostring(rewardType)), 1)
				end
			end

			FireCustomClientEvent("BATTLEPASS_CARD_UPDATE", level, rewardType)
		elseif prefix == "ASMSG_BATTLEPASS_TAKE_ALL_REWARDS" then
			local status = tonumber(msg)

			if status == QUEST_MSG_STATUS.OK then
				PRIVATE.LEVEL_REWARD_ALL_AWAIT = nil
				twipe(PRIVATE.LEVEL_REWARD_AWAIT)
			else
				PRIVATE.HandleStatusMessage(status)
				PRIVATE.LEVEL_REWARD_ALL_AWAIT = nil
			end

			FireCustomClientEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
		elseif prefix == "ASMSG_BATTLEPASS_QUESTS_INFO" then
			if msg == "" then return end

			local isActive = PRIVATE.IsActive()

			for _, questStr in ipairs({StringSplitEx(";", msg)}) do
				local questID, questFlag, rewardAmount, rerollsDone, totalValue, currentValue, state = strsplit(":", questStr)
				questID = tonumber(questID)
				questFlag = tonumber(questFlag)

				if isActive then
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
				else
					if tonumber(state) == Enum.BattlePass.QuestState.Complete then
						PRIVATE.CollectQuestReward(questID)
					end
				end
			end

			if PRIVATE.QUESTS_REQUESTED and PRIVATE.QUEST_REFRESH then
				PRIVATE.QUESTS_RECEIVED = true
			end

			if not isActive then
				return
			end

			for questType, questList in ipairs(PRIVATE.QUEST_LIST_TYPED) do
				tsort(questList, PRIVATE.SortQuests)
			end

			PRIVATE.QUEST_REFRESH = nil
			FireCustomClientEvent("BATTLEPASS_QUEST_LIST_UPDATE")
		elseif prefix == "ASMSG_BATTLEPASS_REPLACE_QUEST" then
			local status, replacedQuestID, questID, questFlag, rewardAmount, rerollsDone, totalValue, currentValue, state = strsplit(":", (msg:gsub(";$", "")))
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
				CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[replacedQuestID] = nil
				CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[questID] = nil
				PRIVATE.ParseQuestTooltip(questID)
				FireCustomClientEvent("BATTLEPASS_QUEST_REPLACED", questType, questIndex)
			else
				local errorHandled = PRIVATE.HandleStatusMessage(status)
				PRIVATE.QUEST_REPLACE_AWAIT[replacedQuestID] = nil

				if PRIVATE.QUEST_LIST[replacedQuestID] then
					local questType = PRIVATE.QUEST_LIST[replacedQuestID].type
					local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], replacedQuestID)
					FireCustomClientEvent("BATTLEPASS_QUEST_REPLACE_FAILED", questType, questIndex)
				end

				if not errorHandled then
					GMError(strformat("BATTLEPASS_REPLACE_QUEST error #%i for questID `%s`", status, replacedQuestID), 1)
				end
			end
		elseif prefix == "ASMSG_BATTLEPASS_QUEST_CANCEL" then
			local status, questID = strsplit(":", msg)
			status = tonumber(status)
			questID = tonumber(questID)

			local questType = PRIVATE.QUEST_LIST[questID].type
			local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], questID)

			if status == QUEST_MSG_STATUS.OK then
				PRIVATE.QUEST_CANCEL_AWAIT[questID] = nil
				PRIVATE.QUEST_LIST[questID] = nil
				tremove(PRIVATE.QUEST_LIST_TYPED[questType], questIndex)
				CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[questID] = nil
				FireCustomClientEvent("BATTLEPASS_QUEST_CANCELED", questType, questIndex)
			else
				local errorHandled = PRIVATE.HandleStatusMessage(status)
				if questType and questIndex then
					PRIVATE.QUEST_CANCEL_AWAIT[questID] = nil
					FireCustomClientEvent("BATTLEPASS_QUEST_CANCEL_FAILED", questType, questIndex)
				end

				if not errorHandled then
					GMError(strformat("BATTLEPASS_QUEST_CANCEL error #%i for questID `%s`", status, questID), 1)
				end
			end
		elseif prefix == "ASMSG_BATTLEPASS_QUEST_REWARD" then
			local status, questID = strsplit(":", msg)
			status = tonumber(status)
			questID = tonumber(questID)

			if questID and questID ~= 0 then
				if PRIVATE.IsActive() then
					local questType = PRIVATE.QUEST_LIST[questID].type
					local questIndex = tIndexOf(PRIVATE.QUEST_LIST_TYPED[questType], questID)

					if status == QUEST_MSG_STATUS.OK then
						PRIVATE.QUEST_LIST[questID] = nil
						tremove(PRIVATE.QUEST_LIST_TYPED[questType], questIndex)
						PRIVATE.QUEST_REWARD_AWAIT[questID] = nil
						CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[questID] = nil

						FireCustomClientEvent("BATTLEPASS_QUEST_REWARD_RECIVED", questType, questIndex)
						FireCustomClientEvent("BATTLEPASS_QUEST_DONE", questType, questIndex)
					else
						local errorHandled = PRIVATE.HandleStatusMessage(status)

						if questType and questIndex then
							PRIVATE.QUEST_REWARD_AWAIT[questID] = nil
							FireCustomClientEvent("BATTLEPASS_QUEST_REWARD_FAILED", questType, questIndex)
						end

						if not errorHandled then
							GMError(strformat("ASMSG_BATTLEPASS_QUEST_REWARD error #%i for questID `%s`", status, questID), 1)
						end
					end
				end
			else
				GMError(strformat("ASMSG_BATTLEPASS_QUEST_REWARD has no questID (%s)", msg))
			end
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
		if itemID then
			if itemID == PRIVATE.STORE_AWAIT_ITEMID then
				if PRIVATE.IsExperienceItem(itemID) then
					PRIVATE.eventHandler:UnregisterEvent("CHAT_MSG_LOOT")
					PRIVATE.LAST_PURCHASED_ITEM_ID = itemID
					PRIVATE.LAST_PURCHASED_ITEM_AMOUNT = amount

					FireCustomClientEvent("BATTLEPASS_ITEM_PURCHASED", itemID, amount)
				end
			elseif PRIVATE.LAST_PURCHASED_OPTION_LIST then
				local done = true

				for index, option in ipairs(PRIVATE.LAST_PURCHASED_OPTION_LIST) do
					if option.itemID == itemID then
						if option.lootedAmount then
							option.lootedAmount = option.lootedAmount + amount
						else
							option.lootedAmount = amount
						end
					end

					if not option.lootedAmount then
						done = false
					end
				end

				if done then
					PRIVATE.eventHandler:UnregisterEvent("CHAT_MSG_LOOT")
					FireCustomClientEvent("BATTLEPASS_ITEM_PURCHASED", itemID, amount)
				end
			end
		end
	elseif event == "VARIABLES_LOADED" then
		PRIVATE.VARIABLES_LOADED = true

		CUSTOM_BATTLEPASS_CACHE = UpgradeLoadedVariables("CUSTOM_BATTLEPASS_CACHE", CUSTOM_BATTLEPASS_CACHE, function(savedVariables)
			if PRIVATE.QUEUED_REWARD_WIPE then
				PRIVATE.QUEUED_REWARD_WIPE = nil
				if savedVariables.LEVEL_REWARD_TAKEN then
					twipe(savedVariables.LEVEL_REWARD_TAKEN)
				end
				savedVariables.SEASON_END_QUEST_LIST = nil
			end
			if PRIVATE.QUEUED_SEEN_QUEST_WIPE then
				PRIVATE.QUEUED_SEEN_QUEST_WIPE = nil
				twipe(savedVariables.SEEN_QUEST)
			end
		end)

		PRIVATE.ENABLED = CUSTOM_BATTLEPASS_CACHE.ENABLED

		if PRIVATE.ENABLED then
			PRIVATE.eventHandler:Show()
			FireCustomClientEvent("BATTLEPASS_SETTINGS_LOADED")
			FireCustomClientEvent("BATTLEPASS_SEASON_UPDATE", CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME)
			FireCustomClientEvent("BATTLEPASS_ACCOUNT_UPDATE", CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE)
			FireCustomClientEvent("BATTLEPASS_EXPERIENCE_UPDATE", CUSTOM_BATTLEPASS_CACHE.LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE)
			FireCustomClientEvent("BATTLEPASS_POINTS_UPDATE")
			FireCustomClientEvent("BATTLEPASS_QUEST_RESET_TIMER_UPDATE")
			PRIVATE.FireSplashScreenEvent()
		end
	elseif event == "PLAYER_LOGIN" then
		if PRIVATE.SPLASH_AWAIT_LOGIN then
			PRIVATE.SPLASH_AWAIT_LOGIN = nil
			PRIVATE.FireSplashScreenEvent()
		end
	elseif event == "PLAYER_LOGOUT" then
		if PRIVATE.QUESTS_RECEIVED then
			for questID in pairs(CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST) do
				if not PRIVATE.QUEST_LIST[questID] then
					CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[questID] = nil
				end
			end
		end

		_G.CUSTOM_BATTLEPASS_CACHE = CUSTOM_BATTLEPASS_CACHE
	end
end)
PRIVATE.useItem = function(itemID, amount)
	local NUM_BAG_FRAMES = 4
	for containerID = 0, NUM_BAG_FRAMES do
		local numSlots = GetContainerNumSlots(containerID)
		local slotID = 1
		while slotID < numSlots do
			if itemID == GetContainerItemID(containerID, slotID) then
				UseContainerItem(containerID, slotID)
				amount = amount - 1

				if amount == 0 then
					if PRIVATE.eventHandler:GetAttribute("state") == "use-single" then
						PRIVATE.eventHandler:SetAttribute("state", "clear")
					end
					return 0
				end
			else
				slotID = slotID + 1
			end
		end
	end
	return amount
end

PRIVATE.eventHandler:SetScript("OnAttributeChanged", function(self, name, value)
	if name == "state" then
		if value == "use-single" then
			local itemID = self:GetAttribute("itemID")
			local amount = self:GetAttribute("amount")
			if not itemID then
				self:SetAttribute("state", "clear")
				return
			end

			local amountLeft = PRIVATE.useItem(itemID, amount)
			self:SetAttribute("state", "clear")

			if amountLeft > 0 then
				GMError(strformat("BattlePass missing items on use-single: [itemID=%i, amount=%i/%i]", itemID, amount - amountLeft, amount))
			end
		elseif value == "use-pack" then
			local itemsMissing = {}

			for i = 1, self:GetAttribute("itemCount") do
				local itemID = self:GetAttribute("itemID-"..i)
				local amount = self:GetAttribute("itemID-"..i.."-amount")
				local amountLeft = PRIVATE.useItem(itemID, amount)
				if amountLeft > 0 then
					tinsert(itemsMissing, strformat("[itemID=%i, amount=%i/%i]", itemID, amount - amountLeft, amount))
				end
			end

			self:SetAttribute("state", "clear")

			if #itemsMissing > 0 then
				GMError(strformat("BattlePass missing items on use-pack: %s", tconcat(itemsMissing, " ")))
			end
		elseif value == "clear" then
			local itemCount = self:GetAttribute("itemCount")
			if itemCount then
				for i = 1, itemCount do
					self:SetAttribute("itemID-"..i, nil)
					self:SetAttribute("itemID-"..i.."-amount", nil)
				end
			end
			self:SetAttribute("itemCount", nil)

			self:SetAttribute("itemID", nil)
			self:SetAttribute("amount", nil)
			self:SetAttribute("state", nil)
		end
	end
end)
PRIVATE.eventHandler:SetScript("OnUpdate", function(self, elapsed)
	PRIVATE.CheckSeasonTimer()
end)

PRIVATE.IsEnabled = function()
	return PRIVATE.ENABLED
end

PRIVATE.IsActive = function()
	return PRIVATE.ENABLED and CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME > 0 or false
end

PRIVATE.IsPremiumActive = function()
	if not PRIVATE.ENABLED then
		return false
	end
	return CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE or false
end

PRIVATE.IsFrameShown = function()
	return PRIVATE.UI_FRAME and PRIVATE.UI_FRAME:IsShown()
end

PRIVATE.HandleStatusMessage = function(status)
	if status == QUEST_MSG_STATUS.OK then
		-- pass
	elseif status == QUEST_MSG_STATUS.QUEST_DATA_ERROR then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_QUEST_DATA_ERROR)
	elseif status == QUEST_MSG_STATUS.NOT_ENOUGH_MONEY then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", ERR_NOT_ENOUGH_GOLD)
	elseif status == QUEST_MSG_STATUS.INVALIDE_QUEST then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_INVALIDE_QUEST)
	elseif status == QUEST_MSG_STATUS.DONT_HAVE_QUEST then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_DONT_HAVE_QUEST)
	elseif status == QUEST_MSG_STATUS.QUEST_NOT_COMPLETE then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_QUEST_NOT_COMPLETE)
	elseif status == QUEST_MSG_STATUS.QUEST_ALREADY_COMPLETE then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_QUEST_ALREADY_COMPLETE)
	elseif status == QUEST_MSG_STATUS.REWARD_NOT_FOUND then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_REWARD_NOT_FOUND)
	elseif status == QUEST_MSG_STATUS.REWARD_INV_FULL then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_LEVEL_REWARD_INV_FULL)
	elseif status == QUEST_MSG_STATUS.ITEM_AMOUNT_LIMIT then
		FireCustomClientEvent("BATTLEPASS_OPERATION_ERROR", BATTLEPASS_STATUS_ITEM_AMOUNT_LIMIT)
	else
		return false
	end

	return true
end

PRIVATE.InitializeLevelData = function()
	if PRIVATE.PER_REALM_DB then
		local serverID = GetServerID()
		BATTLEPASS_LEVELS = _G.BATTLEPASS_LEVELS[serverID] or _G.BATTLEPASS_LEVELS[9]
		BATTLEPASS_LEVEL_REWARDS = _G.BATTLEPASS_LEVEL_REWARDS[serverID] or _G.BATTLEPASS_LEVEL_REWARDS[9]
	else
		BATTLEPASS_LEVELS = _G.BATTLEPASS_LEVELS
		BATTLEPASS_LEVEL_REWARDS = _G.BATTLEPASS_LEVEL_REWARDS
	end
	_G.BATTLEPASS_LEVELS = nil
	_G.BATTLEPASS_LEVEL_REWARDS = nil

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

	PRIVATE.tooltipChecker = CreateFrame("Frame")
	PRIVATE.tooltipChecker:Hide()
	PRIVATE.tooltipChecker:SetScript("OnUpdate", function()
		PRIVATE.ProcessQuestParseQueue()
	end)

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

PRIVATE.Initialize = function()
	PRIVATE.InitializeTooltip()
	PRIVATE.InitializeLevelData()
	PRIVATE.InitializeRewardData()
end

PRIVATE.CanShowSplashScreen = function()
	if PRIVATE.SPLASH_ID and SPLASH_DATA[PRIVATE.SPLASH_ID]
	and PRIVATE.IsActive() and not PRIVATE.HasAnyClaimedReward() and UnitLevel("player") >= 20
	and not C_RealmInfo.IsLegacyRealm(C_Service.GetRealmID())
	then
		return true
	end
	return false
end

PRIVATE.IsSplashScreenSeen = function()
	return CUSTOM_BATTLEPASS_CACHE.SPLASH_SEEN == PRIVATE.SPLASH_ID --and not IsInterfaceDevClient()
end

PRIVATE.FireSplashScreenEvent = function(showSeen)
	if (showSeen or not PRIVATE.IsSplashScreenSeen()) and PRIVATE.CanShowSplashScreen() then
		local splash = PRIVATE.SPLASH_ID and SPLASH_DATA[PRIVATE.SPLASH_ID]
		if splash then
			if IsLoggedIn() then
				CUSTOM_BATTLEPASS_CACHE.SPLASH_SEEN = PRIVATE.SPLASH_ID
				FireCustomClientEvent("BATTLEPASS_SPLASH_SCREEN", PRIVATE.SPLASH_ID, CopyTable(splash))
			else
				PRIVATE.SPLASH_AWAIT_LOGIN = true
			end
		end
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
		PRIVATE.tooltipChecker:Hide()
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
			PRIVATE.tooltipChecker:Show()
		end
		return false
	end

	local desc = PRIVATE.tooltip.linesLeft[3]:GetText()
	PRIVATE.QUEST_PARSED[questID] = {strtrim(title), strtrim(desc or "")}

	return true
end

PRIVATE.CheckSeasonTimer = function()
	if (CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME + 1) <= time() then
		PRIVATE.eventHandler:Hide()

		if CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME == 0 and not next(PRIVATE.QUEST_LIST) then
			return
		end

		CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME = 0

		for questType, questList in ipairs(PRIVATE.QUEST_LIST_TYPED) do
			twipe(questList)
		end

		local completeQuestList = {}

		for questID, quest in pairs(PRIVATE.QUEST_LIST) do
			if quest.state == Enum.BattlePass.QuestState.Complete then
				completeQuestList[questID] = quest
			end
			PRIVATE.QUEST_LIST[questID] = nil
		end

		if next(completeQuestList) then
			CUSTOM_BATTLEPASS_CACHE.SEASON_END_QUEST_LIST = completeQuestList

			if PRIVATE.IsFrameShown() then
				PRIVATE.CheckSeasonEnd()
			else
				PRIVATE.SEASON_END_QUEST_TIMER = C_Timer:After(math.random(5000, 25000) / 1000, function()
					PRIVATE.CheckSeasonEnd()
				end)
			end
		end

		FireCustomClientEvent("BATTLEPASS_QUEST_LIST_UPDATE")
		FireCustomClientEvent("BATTLEPASS_SEASON_UPDATE", CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME)
	end
end

PRIVATE.CheckSeasonEnd = function()
	if PRIVATE.SEASON_END_QUEST_TIMER then
		PRIVATE.SEASON_END_QUEST_TIMER:Cancel()
		PRIVATE.SEASON_END_QUEST_TIMER = nil
	end

	if CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME == 0 and CUSTOM_BATTLEPASS_CACHE.SEASON_END_QUEST_LIST then
		for questID, quest in pairs(CUSTOM_BATTLEPASS_CACHE.SEASON_END_QUEST_LIST) do
			PRIVATE.CollectQuestReward(questID)
			CUSTOM_BATTLEPASS_CACHE.SEASON_END_QUEST_LIST[questID] = nil
		end
		CUSTOM_BATTLEPASS_CACHE.SEASON_END_QUEST_LIST = nil
	end
end

PRIVATE.SortQuests = function(questIDa, questIDb)
	return questIDa < questIDb
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
				PRIVATE.RESET_TIMER_CHANGED = true
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
				PRIVATE.RESET_TIMER_CHANGED = true
			end

			return timestamp, changed
		end
	end

	return 0, changed
end

PRIVATE.CollectQuestReward = function(questID)
	SendServerMessage("ACMSG_BATTLEPASS_QUEST_REWARD", questID)
end

PRIVATE.GetMaxLevel = function()
	return mathmax(PRIVATE.MAX_LEVEL, CUSTOM_BATTLEPASS_CACHE.LEVEL)
end

PRIVATE.GetTotalLevelExperience = function(level)
	if level < 0 then
		return 0
	elseif level <= PRIVATE.MAX_LEVEL then
		return PRIVATE.LEVEL_INFO[level].totalLevelExperience
	else
		return PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].totalLevelExperience + PRIVATE.LEVEL_INFO[PRIVATE.MAX_LEVEL].requiredExperience * (level - PRIVATE.MAX_LEVEL)
	end
end

PRIVATE.GetRequiredExperienceForLevel = function(level)
	if level <= CUSTOM_BATTLEPASS_CACHE.LEVEL then
		return 0
	end

	local currentExperience = PRIVATE.GetTotalLevelExperience(CUSTOM_BATTLEPASS_CACHE.LEVEL) + CUSTOM_BATTLEPASS_CACHE.LEVEL_EXPERIENCE

	if level > PRIVATE.MAX_LEVEL then
		return PRIVATE.GetTotalLevelExperience(level) - currentExperience
	else
		return PRIVATE.LEVEL_INFO[level].totalLevelExperience - currentExperience
	end
end

PRIVATE.SortExperienceOptionsForLevel = function(a, b)
	return a.optionIndex < b.optionIndex
end

PRIVATE.GetRequiredExperienceOptionsForLevel = function(level, targetCurrencyType)
	local experienceRequired = PRIVATE.GetRequiredExperienceForLevel(level)
	if experienceRequired <= 0 then
		return {}, -1, -1, targetCurrencyType
	end

	local options = {}
	local finalPrice = 0
	local finalOriginalPrice = 0
	local numOptions = 0

	for optionIndex = 1, PRIVATE.GetNumExperiencePurchaseOptions() do
		local itemID, experience, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = PRIVATE.GetExperiencePurchaseOptionInfo(optionIndex)
		if experience and currencyType == targetCurrencyType then
			local amount = 0

			if numOptions == 0 then
				local experienceMod = experienceRequired % experience
				amount = mathfloor(experienceRequired / experience)

				if experienceMod > 0 then
					amount = amount + 1
				end
			else
				local optionPrev = options[numOptions]
				local mult = mathfloor(experience / optionPrev.experience)
				amount = mathfloor(optionPrev.amount / mult)

				if amount > 0 then
					if optionPrev.amount > mult * amount then
						optionPrev.amount = optionPrev.amount - mult * amount
					else
						tremove(options, numOptions)
						numOptions = numOptions - 1
					end
				end
			end

			if amount > 0 then
				tinsert(options, {
					optionIndex = optionIndex,
					experience = experience,
					amount = amount,
					itemID = itemID,
					price = price,
					originalPrice = originalPrice,
				})
				numOptions = numOptions + 1
			end
		end
	end

	if numOptions > 0 then
		tsort(options, PRIVATE.SortExperienceOptionsForLevel)

		for index, option in ipairs(options) do
			finalPrice = finalPrice + option.price * option.amount
			finalOriginalPrice = finalOriginalPrice + option.originalPrice * option.amount
		end
	else
		finalPrice = -1
		finalOriginalPrice = -1
	end

	return options, finalPrice, finalOriginalPrice, targetCurrencyType
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

PRIVATE.GetLevelRewardAwaitFlag = function(rewardType)
	if rewardType == Enum.BattlePass.RewardType.Premium then
		return 2
	else
		return 1
	end
end

PRIVATE.IsLevelRewardTypeAwaiting = function(level, rewardType)
	if PRIVATE.LEVEL_REWARD_AWAIT[level] then
		local rewardAwaitFlag = PRIVATE.GetLevelRewardAwaitFlag(rewardType)
		return bitband(PRIVATE.LEVEL_REWARD_AWAIT[level], rewardAwaitFlag) ~= 0
	end
	return false
end

PRIVATE.AddLevelRewardTypeAwait = function(level, rewardType)
	if not PRIVATE.IsLevelRewardTypeAwaiting(level, rewardType) then
		local rewardAwaitFlag = PRIVATE.GetLevelRewardAwaitFlag(rewardType)
		PRIVATE.LEVEL_REWARD_AWAIT[level] = bitbor(PRIVATE.LEVEL_REWARD_AWAIT[level] or 0, rewardAwaitFlag)
		return true
	end
	return false
end

PRIVATE.RemoveLevelRewardTypeAwait = function(level, rewardType)
	if PRIVATE.IsLevelRewardTypeAwaiting(level, rewardType) then
		local rewardAwaitFlag = PRIVATE.GetLevelRewardAwaitFlag(rewardType)
		if PRIVATE.LEVEL_REWARD_AWAIT[level] == rewardAwaitFlag then
			PRIVATE.LEVEL_REWARD_AWAIT[level] = nil
		else
			PRIVATE.LEVEL_REWARD_AWAIT[level] = PRIVATE.LEVEL_REWARD_AWAIT[level] - rewardAwaitFlag
		end
		return true
	end
	return false
end

PRIVATE.SetLevelRewardFlag = function(level, rewardType, rewardFlag)
	local diffRewardFlag

	if type(rewardFlag) ~= "number" or rewardFlag == -1 then
		if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] and CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] then
			CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] = nil
			if not next(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][level]) then
				CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] = nil
			end
		end

		diffRewardFlag = -1
	else
		if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] then
			local oldRewardFlag = CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType]
			if not oldRewardFlag then
				diffRewardFlag = rewardFlag
			elseif oldRewardFlag == rewardFlag then
				diffRewardFlag = -1
			else
				diffRewardFlag = bitband(rewardFlag, bitbnot(oldRewardFlag))
			end
		else
			CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] = {}
			diffRewardFlag = rewardFlag
		end

		CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] = rewardFlag
	end

	return diffRewardFlag
end

PRIVATE.GetItemIndexFlag = function(itemIndex)
	return bitlshift(1, itemIndex - 1)
end

PRIVATE.IsLevelRewardCollectedAll = function(level, rewardType)
	if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] then
		return CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] == 0
	end
	return false
end

PRIVATE.IsLevelRewardCollectedAny = function(level, rewardType)
	if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] and CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] then
		return true
	end
	return false
end

PRIVATE.IsLevelRewardCollectedItemIndex = function(level, rewardType, itemIndex)
	if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level] and CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] then
		if CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType] == 0 then
			return true
		else
			return bitband(CUSTOM_BATTLEPASS_CACHE.LEVEL_REWARD_TAKEN[level][rewardType], PRIVATE.GetItemIndexFlag(itemIndex)) ~= 0
		end
	end
	return false
end

PRIVATE.IsCardRewardAvailable = function(level, rewardType)
	return not PRIVATE.IsLevelRewardCollectedAll(level, rewardType)
end

PRIVATE.GetLevelRewards = function(level, rewardType, rewardFlag)
	local items = {}

	local faction = UnitFactionGroup("player")
	local factionFlag = ITEM_REWARD_FLAG[faction]

	for _, item in ipairs(BATTLEPASS_LEVEL_REWARDS[mathmin(level, PRIVATE.MAX_LEVEL)]) do
		local itemType, itemIndex, itemID, amount, flags = unpack(item, 1, 5)

		if itemType == rewardType then
			if flags == 0 or bitband(flags, factionFlag) ~= 0 then
				itemIndex = itemIndex + 1
				if not rewardFlag or rewardFlag == 0 or bitband(rewardFlag, PRIVATE.GetItemIndexFlag(itemIndex)) ~= 0 then
					local isCollected = PRIVATE.IsLevelRewardCollectedItemIndex(level, rewardType, itemIndex)
					tinsert(items, {index = itemIndex, itemID = itemID, amount = amount, isCollected = isCollected})
				end
			end
		end
	end

	return items
end

PRIVATE.HasAnyClaimedReward = function()
	if CUSTOM_BATTLEPASS_CACHE.LEVEL == 0 then
		return false
	end

	for level = 1, CUSTOM_BATTLEPASS_CACHE.LEVEL do
		if PRIVATE.IsLevelRewardCollectedAny(level, Enum.BattlePass.RewardType.Free)
		or (CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE and PRIVATE.IsLevelRewardCollectedAny(level, Enum.BattlePass.RewardType.Premium))
		then
			return true
		end
	end

	return false
end

PRIVATE.HasUnclaimedReward = function()
	if CUSTOM_BATTLEPASS_CACHE.LEVEL == 0 then
		return false
	end

	for level = 1, CUSTOM_BATTLEPASS_CACHE.LEVEL do
		if PRIVATE.IsCardRewardAvailable(level, Enum.BattlePass.RewardType.Free)
		or (CUSTOM_BATTLEPASS_CACHE.PREMIUM_ACTIVE and PRIVATE.IsCardRewardAvailable(level, Enum.BattlePass.RewardType.Premium))
		then
			return level
		end
	end

	return false
end

PRIVATE.HasCompleteQuests = function()
	for _, questList in ipairs(PRIVATE.QUEST_LIST_TYPED) do
		for _, questID in ipairs(questList) do
			if PRIVATE.IsQuestComplete(questID) then
				return true
			end
		end
	end

	return false
end

PRIVATE.IsAwaitingQuestAction = function(questID)
	if PRIVATE.QUEST_REPLACE_AWAIT[questID]
	or PRIVATE.QUEST_REWARD_AWAIT[questID]
	or PRIVATE.QUEST_CANCEL_AWAIT[questID]
	then
		return true
	end
	return false
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

PRIVATE.IsQuestReplaceAllowed = function(questID)
	if PRIVATE.QUEST_LIST[questID].type == Enum.BattlePass.QuestType.Weekly and not ALLOW_WEEKLY_QUEST_REROLL then
		return false
	end
	return bitband(PRIVATE.QUEST_LIST[questID].flags, QUEST_FLAG.NO_REPLACEMENT) == 0
end

PRIVATE.CanReplaceQuest = function(questID, skipBalanceCheck)
	if not PRIVATE.IsQuestReplaceAllowed(questID) then
		return false
	end

	if PRIVATE.IsQuestComplete(questID) then
		return false
	end

	return skipBalanceCheck or PRIVATE.GetQuestReplacePrice(questID) <= GetMoney() or IsGMAccount()
end

PRIVATE.CanCancelQuest = function(questID)
	if PRIVATE.IsQuestComplete(questID) then
		return false
	end
	return PRIVATE.QUEST_LIST[questID].type == Enum.BattlePass.QuestType.Daily and ALLOW_DAILY_QUEST_CANCEL
end

do
	if IsInterfaceDevClient() then
		PRIVATE_BP = PRIVATE
	end
	PRIVATE.Initialize()
end

C_BattlePass = {}

function C_BattlePass.IsEnabled()
	return PRIVATE.IsEnabled()
end

function C_BattlePass.IsActive()
	return PRIVATE.IsActive()
end

function C_BattlePass.IsActiveOrHasRewards()
	if not PRIVATE.IsEnabled() then
		return false
	end

	if not PRIVATE.IsActive()
	and not PRIVATE.HasUnclaimedReward()
	and not PRIVATE.HasCompleteQuests()
	then
		return false
	end

	return true
end

function C_BattlePass.SetUIFrame(obj)
	if type(obj) ~= "table" or not obj.GetObjectType then
		error(strformat("bad argument #1 to 'C_BattlePass.CalculateAddedExperience' (table expected, got %s)", obj ~= nil and type(obj) or "no value"), 2)
	elseif PRIVATE.UI_FRAME then
		return
	end

	PRIVATE.UI_FRAME = obj
end

function C_BattlePass.GetMaxLevel()
	return PRIVATE.MAX_LEVEL - 1
end

function C_BattlePass.GetSourceExperience()
	return CUSTOM_BATTLEPASS_CACHE.POINTS_BG or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_SOLOQ or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_ARENA_V1 or 0,
		CUSTOM_BATTLEPASS_CACHE.POINTS_MINIGAME or 30
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

function C_BattlePass.GetRequiredExperienceForLevel(level)
	if not PRIVATE.IsEnabled() then
		return 0
	end

	if type(level) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.GetRequiredExperienceForLevel' (number expected, got %s)", type(level)), 2)
	end

	return PRIVATE.GetRequiredExperienceForLevel(level)
end

function C_BattlePass.GetRequiredExperienceOptionsForLevel(level)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() or PRIVATE.GetNumExperiencePurchaseOptions() == 0 then
		return {}, -1, -1, Enum.Store.CurrencyType.Bonus
	end

	return PRIVATE.GetRequiredExperienceOptionsForLevel(level, Enum.Store.CurrencyType.Bonus)
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
	local itemID, productID, price, originalPrice, currencyType = C_StoreSecure.GetBattlePassPremiumProductInfo()
	return price, originalPrice, currencyType
end

function C_BattlePass.IsPremiumActive()
	return PRIVATE.IsPremiumActive()
end

function C_BattlePass.GetSeasonEndTime()
	if not PRIVATE.IsEnabled() then
		return 0
	end
	return CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME or 0
end

function C_BattlePass.GetSeasonTimeLeft()
	if not PRIVATE.IsEnabled() then
		return 0
	end

	if not CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME or CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME <= 0 then
		return 0
	end

	return mathmax(0, CUSTOM_BATTLEPASS_CACHE.SEASON_END_TIME - time())
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
	local freeItems = PRIVATE.GetLevelRewards(cardIndex, Enum.BattlePass.RewardType.Free)
	local premiumItems = PRIVATE.GetLevelRewards(cardIndex, Enum.BattlePass.RewardType.Premium)

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
			if PRIVATE.IsActive() or PRIVATE.IsPremiumActive() then
				premiumState = Enum.BattlePass.CardState.LootAvailable
			else
				premiumState = Enum.BattlePass.CardState.Unavailable
			end
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

function C_BattlePass.IsAwaitingLevelReward(cardIndex, rewardType)
	if not PRIVATE.IsEnabled() then
		return false
	end

	if type(cardIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.IsAwaitingLevelReward' (number expected, got %s)", type(cardIndex)), 2)
	elseif type(rewardType) ~= "number" then
		error(strformat("bad argument #2 to 'C_BattlePass.IsAwaitingLevelReward' (number expected, got %s)", type(rewardType)), 2)
	elseif cardIndex < 1 or cardIndex > PRIVATE.GetMaxLevel() then
		error(strformat("cardIndex out of range `%i`", cardIndex), 2)
	elseif rewardType < 0 or rewardType > 1 then
		error(strformat("rewardType out of range `%i`", rewardType), 2)
	end

	if PRIVATE.LEVEL_REWARD_ALL_AWAIT
	or PRIVATE.IsLevelRewardTypeAwaiting(cardIndex, rewardType)
	then
		return true
	end

	return false
end

function C_BattlePass.IsAwaitingAllLevelReward()
	if not PRIVATE.IsEnabled() then
		return false
	end

	return PRIVATE.LEVEL_REWARD_ALL_AWAIT ~= nil
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

	if PRIVATE.LEVEL_REWARD_ALL_AWAIT then
		return
	end

	if PRIVATE.AddLevelRewardTypeAwait(cardIndex, rewardType) then
		FireCustomClientEvent("BATTLEPASS_CARD_REWARD_AWAIT", cardIndex, rewardType)
		SendServerMessage("ACMSG_BATTLEPASS_TAKE_REWARD", strformat("%u:%u", cardIndex, rewardType))
	end
end

function C_BattlePass.SetTakeAllRewards(state)
	CUSTOM_BATTLEPASS_CACHE.TAKE_ALL_LEVEL_REWARD = not not scrub(state)
end

function C_BattlePass.IsTakeAllRewardsEnabled()
	return not not CUSTOM_BATTLEPASS_CACHE.TAKE_ALL_LEVEL_REWARD
end

function C_BattlePass.TakeAllLevelRewards()
	if not PRIVATE.IsEnabled() then
		return
	end

	if not PRIVATE.LEVEL_REWARD_ALL_AWAIT and PRIVATE.HasUnclaimedReward() then
		PRIVATE.LEVEL_REWARD_ALL_AWAIT = true
		FireCustomClientEvent("BATTLEPASS_CARD_UPDATE_BUCKET")
		SendServerMessage("ACMSG_BATTLEPASS_TAKE_ALL_REWARDS")
	end
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
	if not PRIVATE.IsEnabled() then
		return false
	end
	return PRIVATE.HasUnclaimedReward()
end

function C_BattlePass.CheckSeasonEnd()
	if not PRIVATE.IsEnabled() then
		return
	end
	PRIVATE.CheckSeasonEnd()
end

function C_BattlePass.RequestQuests()
	if not PRIVATE.IsEnabled() then
		return
	end

	if PRIVATE.QUESTS_REQUESTED then
		if not PRIVATE.IsActive() then
			PRIVATE.CheckSeasonEnd()
			return
		elseif not PRIVATE.RESET_TIMER_CHANGED then
			local _, changedDaily = PRIVATE.GetQuestTypeTimeLeft(Enum.BattlePass.QuestType.Daily)
			local _, changedWeekly = PRIVATE.GetQuestTypeTimeLeft(Enum.BattlePass.QuestType.Weekly)
			if not changedDaily and not changedWeekly then
				return
			end
		end
	end

	PRIVATE.QUESTS_REQUESTED = true
	PRIVATE.QUEST_REFRESH = true
	PRIVATE.RESET_TIMER_CHANGED = nil
	SendServerMessage("ACMSG_BATTLEPASS_QUESTS_REQUEST")
end

function C_BattlePass.HasCompleteQuests()
	if not PRIVATE.IsEnabled() then
		return false
	end
	return PRIVATE.HasCompleteQuests()
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
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
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

function C_BattlePass.GetQuestLink(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.GetQuestLink", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	local questTextData = PRIVATE.QUEST_PARSED[questID]
	local name
	if questTextData and questTextData[1] then
		name = questTextData[1]
	elseif questType == Enum.BattlePass.QuestType.Daily then
		name = BATTLEPASS_QUEST_LINK_FALLBACK_DAILY
	elseif questType == Enum.BattlePass.QuestType.Weekly then
		name = BATTLEPASS_QUEST_LINK_FALLBACK_WEEKLY
	end
	return strformat("|cffffff00|Hquest:%u:-1|h[%s]|h|r", questID, name)
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
	return PRIVATE.IsAwaitingQuestAction(questID)
end

function C_BattlePass.GetQuestReplacePrice(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return 0
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.GetQuestReplacePrice", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if not PRIVATE.CanReplaceQuest(questID, true) then
		return 0
	end

	return PRIVATE.GetQuestReplacePrice(questID)
end

function C_BattlePass.IsQuestReplaceAllowed(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.IsQuestReplaceAllowed", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	return PRIVATE.IsQuestReplaceAllowed(questID)
end

function C_BattlePass.CanReplaceQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.CanReplaceQuest", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	return PRIVATE.CanReplaceQuest(questID)
end

function C_BattlePass.ReplaceQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.ReplaceQuest", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if PRIVATE.CanReplaceQuest(questID) and not PRIVATE.IsAwaitingQuestAction(questID) then
		PRIVATE.QUEST_REPLACE_AWAIT[questID] = true
		FireCustomClientEvent("BATTLEPASS_QUEST_ACTION_AWAIT", questType, questIndex)
		SendServerMessage("ACMSG_BATTLEPASS_REPLACE_QUEST", questID)
	end
end

function C_BattlePass.CanCancelQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return false
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.CanCancelQuest", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	return PRIVATE.CanCancelQuest(questID)
end

function C_BattlePass.CancelQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.CanCancelQuest", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if PRIVATE.CanCancelQuest(questID) and not PRIVATE.IsAwaitingQuestAction(questID) then
		PRIVATE.QUEST_CANCEL_AWAIT[questID] = true
		FireCustomClientEvent("BATTLEPASS_QUEST_ACTION_AWAIT", questType, questIndex)
		SendServerMessage("ACMSG_BATTLEPASS_QUEST_CANCEL", questID)
	end
end

function C_BattlePass.CollectQuestReward(questType, questIndex)
	if not PRIVATE.IsEnabled() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.CollectQuestReward", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if PRIVATE.IsQuestComplete(questID) and not PRIVATE.IsAwaitingQuestAction(questID) then
		PRIVATE.QUEST_REWARD_AWAIT[questID] = true
		FireCustomClientEvent("BATTLEPASS_QUEST_ACTION_AWAIT", questType, questIndex)
		PRIVATE.CollectQuestReward(questID)
	end
end

function C_BattlePass.IsNewQuest(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.IsNewQuest", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if questID and CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[questID] then
		return false
	end

	return true
end

function C_BattlePass.MarkQuestSeen(questType, questIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	PRIVATE.ValidateQuestArgs("C_BattlePass.MarkQuestSeen", questType, questIndex)

	local questID = PRIVATE.QUEST_LIST_TYPED[questType][questIndex]
	if questID then
		CUSTOM_BATTLEPASS_CACHE.SEEN_QUEST[questID] = true
	end
end

function C_BattlePass.RequestProductData()
	C_StoreSecure.RequestBattlePassProducts()
end

function C_BattlePass.GetNumExperiencePurchaseOptions()
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return 0
	end

	return PRIVATE.GetNumExperiencePurchaseOptions()
end

PRIVATE.GetNumExperiencePurchaseOptions = function()
	return C_StoreSecure.GetNumBattlePassExperienceOptions()
end

PRIVATE.GetExperiencePurchaseOptionInfo = function(optionIndex)
	local itemID, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetBattlePassExperienceOption(optionIndex)
	local experience = EXPERIENCE_ITEMS[itemID] or 0
	return itemID, experience, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType
end

function C_BattlePass.GetExperiencePurchaseOptionInfo(optionIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	if type(optionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.GetExperiencePurchaseOptionInfo' (number expected, got %s)", type(optionIndex)), 2)
	elseif optionIndex < 1 or optionIndex > C_BattlePass.GetNumExperiencePurchaseOptions() then
		error(strformat("bad argument #1 to 'C_BattlePass.GetExperiencePurchaseOptionInfo' (out of range `%i`)", optionIndex), 2)
	end

	return PRIVATE.GetExperiencePurchaseOptionInfo(optionIndex)
end

function C_BattlePass.GetExperiencePurchaseOptionArtKit(optionIndex)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	if type(optionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.GetExperiencePurchaseOptionArtKit' (number expected, got %s)", type(optionIndex)), 2)
	elseif optionIndex < 1 or optionIndex > #PURCHASE_EXPERIENCE_OPTIONS then
		error(strformat("bad argument #1 to 'C_BattlePass.GetExperiencePurchaseOptionArtKit' (out of range `%i`)", optionIndex), 2)
	end

	local artKit = PURCHASE_EXPERIENCE_OPTIONS[optionIndex]
	return artKit.iconAtlas, artKit.iconAnimAtlas, artKit.checkedAtlas, artKit.highlightAtlas
end

function C_BattlePass.PurchaseExperience(optionIndex, amount)
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	if type(optionIndex) ~= "number" then
		error(strformat("bad argument #1 to 'C_BattlePass.PurchaseExperience' (number expected, got %s)", type(optionIndex)), 2)
	elseif type(amount) ~= "number" then
		error(strformat("bad argument #2 to 'C_BattlePass.PurchaseExperience' (number expected, got %s)", type(amount)), 2)
	elseif optionIndex < 1 or optionIndex > #PURCHASE_EXPERIENCE_OPTIONS then
		error(strformat("bad argument #1 to 'C_BattlePass.PurchaseExperience' (optionIndex out of range `%i`)", optionIndex), 2)
	elseif amount < 1 then
		error(strformat("bad argument #2 to 'C_BattlePass.PurchaseExperience' (amount out of range `%i`)", amount), 2)
	end

	local itemID, productID, price, originalPrice, currencyType, altPrice, altOriginalPrice, altCurrencyType = C_StoreSecure.GetBattlePassExperienceOption(optionIndex)
	if productID then
		price = price * amount
		if price <= C_StoreSecure.GetBalance(currencyType) or IsInGMMode() then
			local success = C_StoreSecure.PurchaseBattlePassExperience(optionIndex, amount)
			if success and itemID then
				PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_LOOT")
				PRIVATE.STORE_AWAIT_ITEMID = itemID
				PRIVATE.LAST_PURCHASED_OPTION_LIST = nil
			end
		else
			C_StoreSecure.GenerateBalanceError(Enum.Store.ProductType.BattlePass, currencyType, string.join(".", "BPPE", productID))
		end
	else
		GMError(strformat("No experience product id avaliable for %u option", optionIndex))
	end
end

function C_BattlePass.PurchaseExperienceOptionsForLevel(level)
	local options, price, originalPrice, currencyType = PRIVATE.GetRequiredExperienceOptionsForLevel(level, Enum.Store.CurrencyType.Bonus)
	if not next(options) then
		PRIVATE.LAST_PURCHASED_OPTION_LIST = nil
		return
	end

	if price <= C_StoreSecure.GetBalance(currencyType) or IsInGMMode() then
		PRIVATE.STORE_AWAIT_ITEMID = nil

		local registerEvent

		for _, option in ipairs(options) do
			local success = C_StoreSecure.PurchaseBattlePassExperience(option.optionIndex, option.amount)
			if success and not registerEvent then
				registerEvent = true
				PRIVATE.LAST_PURCHASED_OPTION_LIST = options
				PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_LOOT")
			end
		end
	end
end

function C_BattlePass.PurchasePremium()
	if not PRIVATE.IsEnabled() or not PRIVATE.IsActive() then
		return
	end

	local itemID, productID, price, originalPrice, currencyType = C_StoreSecure.GetBattlePassPremiumProductInfo()
	if productID then
		if price <= C_StoreSecure.GetBalance(currencyType) or IsInGMMode() then
			local success = C_StoreSecure.PurchaseBattlePassPremium()
			if success and itemID then
				PRIVATE.eventHandler:RegisterEvent("CHAT_MSG_LOOT")
				PRIVATE.STORE_AWAIT_ITEMID = itemID
			end
		else
			C_StoreSecure.GenerateBalanceError(Enum.Store.ProductType.BattlePass, currencyType, string.join(".", "BPPP", productID))
		end
	else
		GMError("No premium product id avaliable")
	end
end

function C_BattlePass.UsePurchasedItem()
	if not PRIVATE.IsEnabled() then
		return
	end

	if PRIVATE.LAST_PURCHASED_ITEM_ID then
		local itemID = PRIVATE.LAST_PURCHASED_ITEM_ID
		local amount = PRIVATE.LAST_PURCHASED_ITEM_AMOUNT

		PRIVATE.LAST_PURCHASED_ITEM_ID = nil
		PRIVATE.LAST_PURCHASED_ITEM_AMOUNT = nil

		RunNextFrame(function()
			PRIVATE.eventHandler:SetAttribute("itemID", itemID)
			PRIVATE.eventHandler:SetAttribute("amount", amount)
			PRIVATE.eventHandler:SetAttribute("state", "use-single")

			FireCustomClientEvent("BATTLEPASS_PURCHASED_ITEM_USED")
		end)
	elseif PRIVATE.LAST_PURCHASED_OPTION_LIST then
		local list = PRIVATE.LAST_PURCHASED_OPTION_LIST

		PRIVATE.LAST_PURCHASED_OPTION_LIST = nil

		RunNextFrame(function()
			for i, option in ipairs(list) do
				PRIVATE.eventHandler:SetAttribute("itemID-"..i, option.itemID)
				PRIVATE.eventHandler:SetAttribute("itemID-"..i.."-amount", option.amountLooted or option.amount)
			end
			PRIVATE.eventHandler:SetAttribute("itemCount", #list)
			PRIVATE.eventHandler:SetAttribute("state", "use-pack")

			FireCustomClientEvent("BATTLEPASS_PURCHASED_ITEM_USED")
		end)
	end
end

function C_BattlePass.HasSplashScreen()
	return PRIVATE.CanShowSplashScreen()
end

function C_BattlePass.RequestSplashScreen(showSeen)
	PRIVATE.FireSplashScreenEvent(showSeen)
end