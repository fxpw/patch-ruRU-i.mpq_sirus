local error = error
local type = type
local tonumber = tonumber
local strlower, strsplit = string.lower, string.split
local tinsert, twipe = table.insert, table.wipe

local IsInGuild = IsInGuild
local GetSpellInfo = GetSpellInfo

local FireCustomClientEvent = FireCustomClientEvent
local SendServerMessage = SendServerMessage
local StringSplitEx = StringSplitEx

local UNKNOWN = UNKNOWN

local QUESTION_MARK_ICON = [[Interface\Icons\INV_Misc_QuestionMark]]

local GUILD_MAX_LEVEL = 25
local REPLACE_GUILD_MASTER_DAYS = 90

local PRIVATE = {
	QUEUE_SPELL_REPUTATION_REQUEST = true,

	LEVEL = 1,
	XP_CURRENT = 0,
	XP_NEXT_LEVEL = 0,
	XP_DAILY_CAP = 0,

	REPUTATION_STANDING_ID = 3,
	REPUTATION_MIN = 0,
	REPUTATION_MAX = 0,

	PERKS = {},
	REPUTATION_REWARDS = {},

	MEMBER_ITEM_LEVEL = {},
	MEMBER_CATEGORY = {},
	MEMBER_CHALLANGE = {},

	INVITE_REQUEST = {},
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:RegisterEvent("PLAYER_LOGIN")
PRIVATE.eventHandler:RegisterEvent("PLAYER_GUILD_UPDATE")
PRIVATE.eventHandler:RegisterEvent("GUILD_INVITE_REQUEST")
--PRIVATE.eventHandler:RegisterEvent("GUILD_INVITE_CANCEL")
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if IsInGuild() then
			SendServerMessage("ACMSG_GUILD_LEVEL_REQUEST")
			SendServerMessage("ACMSG_GUILD_REPUTATION_REQUEST")
			SendServerMessage("ACMSG_GUILD_SPELLS_REQUEST")
			SendServerMessage("ACMSG_GUILD_REPUTATION_REWARDS_REQUEST")
			SendServerMessage("ACMSG_GUILD_ONLINE_REQUEST")
			SendServerMessage("ACMSG_GUILD_EMBLEM_REQUEST")
			SendServerMessage("ACMSG_GUILD_ILVLS_REQUEST")
			SendServerMessage("ACMSG_GUILD_CATEGORY_REQUEST")
			SendServerMessage("ACMSG_GUILD_CHALLENGE_REQUEST")

			PRIVATE.QUEUE_SPELL_REPUTATION_REQUEST = nil
		end
	elseif event == "PLAYER_GUILD_UPDATE" then
		if IsInGuild() then
			if PRIVATE.QUEUE_SPELL_REPUTATION_REQUEST then
				SendServerMessage("ACMSG_GUILD_SPELLS_REQUEST")
				SendServerMessage("ACMSG_GUILD_REPUTATION_REWARDS_REQUEST")
				SendServerMessage("ACMSG_GUILD_REPUTATION_REQUEST")

				PRIVATE.QUEUE_SPELL_REPUTATION_REQUEST = nil
			end
		else
			if not PRIVATE.QUEUE_SPELL_REPUTATION_REQUEST then
				PRIVATE.QUEUE_SPELL_REPUTATION_REQUEST = true
			end
		end
	elseif event == "GUILD_INVITE_REQUEST" then
		local inviterName, guildName = ...

		local guildLevel = PRIVATE.INVITE_REQUEST.GUILD_LEVEL
		local oldGuildName = nil
		local isNewGuild = false

		FireCustomClientEvent("GUILD_INVITE_REQUEST_EX", inviterName, guildName, guildLevel, oldGuildName, isNewGuild,
			PRIVATE.INVITE_REQUEST.EMBLEM_STYLE,
			PRIVATE.INVITE_REQUEST.EMBLEM_COLOR,
			PRIVATE.INVITE_REQUEST.EMBLEM_BORDER_STYLE,
			PRIVATE.INVITE_REQUEST.EMBLEM_BORDER_COLOR,
			PRIVATE.INVITE_REQUEST.EMBLEM_BACKGROUND_COLOR
		)
	elseif event == "GUILD_INVITE_CANCEL" then
		twipe(PRIVATE.INVITE_REQUEST)
	end
end)

PRIVATE.OnDataLoaded = function()
	if PRIVATE.IsRequiredDataLoaded() then
		FireCustomClientEvent("GUILD_DATA_LOADED")
	end
end

PRIVATE.IsRequiredDataLoaded = function()
	if PRIVATE.XP_RECEIVED and PRIVATE.XP_RECEIVED and #PRIVATE.PERKS > 0 and #PRIVATE.REPUTATION_REWARDS > 0 then
		return true
	end
	return false
end

function IsGuildDataLoaded()
	return PRIVATE.IsRequiredDataLoaded()
end

do -- ASMSG_GUILD_EVENT
	local GUILD_EVENT_ACTION = {
		PLAYER_JOINED_GUILD = 0,
	}

	function EventHandler:ASMSG_GUILD_EVENT(msg)
		local actionType = tonumber(msg)
		if actionType == GUILD_EVENT_ACTION.PLAYER_JOINED_GUILD then
			EventRegistry:TriggerEvent("GuildEvent.Joined")
		end
	end
end

do -- ACMSG_GUILD_LEVEL_REQUEST
	function EventHandler:ASMSG_GUILD_LEVEL_INFO(msg)
		local level, currentXP, nextLevelXP, dailtyCapXP = strsplit(":", msg)

		PRIVATE.LEVEL = tonumber(level) or 1
		PRIVATE.XP_CURRENT = tonumber(currentXP) or 0
		PRIVATE.XP_NEXT_LEVEL = tonumber(nextLevelXP) or 0
		PRIVATE.XP_DAILY_CAP = tonumber(dailtyCapXP) or 0

		if not PRIVATE.XP_RECEIVED then
			PRIVATE.XP_RECEIVED = true
			PRIVATE.OnDataLoaded()
		end

		FireCustomClientEvent("GUILD_XP_UPDATE")
	end

	function GetGuildLevel()
		return PRIVATE.LEVEL, GUILD_MAX_LEVEL
	end

	function UnitGetGuildXP(unit)
		if type(unit) ~= "string" then
			error("Usage: UnitGetGuildXP(\"unit\")", 2)
		end

		if UnitIsUnit(unit, "player") then
			return PRIVATE.XP_CURRENT, PRIVATE.XP_NEXT_LEVEL
		end

		return 0, 0
	end

	function GetGuildXPDailtyCap()
		return PRIVATE.XP_DAILY_CAP
	end
end

do -- ACMSG_GUILD_REPUTATION_REQUEST
	function EventHandler:ASMSG_GUILD_REPUTATION_INFO(msg)
		local standingID, valueMin, valueMax = strsplit(":", msg)

		PRIVATE.REPUTATION_STANDING_ID = tonumber(standingID) or 3
		PRIVATE.REPUTATION_MIN = tonumber(valueMin) or 0
		PRIVATE.REPUTATION_MAX = tonumber(valueMax) or 0

		if not PRIVATE.REPUTATION_RECEIVED then
			PRIVATE.REPUTATION_RECEIVED = true
			PRIVATE.OnDataLoaded()
		end

		FireCustomClientEvent("GUILD_FACTION_UPDATE")
	end

	function GetGuildReputation()
		if PRIVATE.REPUTATION_RECEIVED then
			return PRIVATE.REPUTATION_STANDING_ID, PRIVATE.REPUTATION_MIN, PRIVATE.REPUTATION_MAX
		end
	end
end

do -- ACMSG_GUILD_SPELLS_REQUEST
	function EventHandler:ASMSG_GUILD_SPELLS_RESPONSE(msg)
		twipe(PRIVATE.PERKS)

		for index, rewardStr in ipairs({StringSplitEx(",", msg)}) do
			local spellID, spellLevel = strsplit(":", rewardStr)
			tinsert(PRIVATE.PERKS, {
				tonumber(spellID), tonumber(spellLevel)
			})
		end

		PRIVATE.OnDataLoaded()
	end

	function GetNumGuildPerks()
		return #PRIVATE.PERKS
	end

	function GetGuildPerkInfo(index)
		if type(index) ~= "number" then
			error("Usage: GetGuildPerkInfo(index)", 2)
		end

		local perk = PRIVATE.PERKS[index]
		if perk then
			local spellID, spellLevel = perk[1], perk[2]
			local name, _, iconTexture = GetSpellInfo(spellID)
			return name or UNKNOWN, spellID, iconTexture or QUESTION_MARK_ICON, spellLevel
		end
	end
end

do -- ACMSG_GUILD_REPUTATION_REWARDS_REQUEST
	local sortRewards = function(a, b)
		if a[3] ~= b[3] then
			return a[3] < b[3]
		elseif a[2] ~= b[2] then
			return a[2] < b[2]
		end
		return a[1] < b[1]
	end

	function EventHandler:ASMSG_GUILD_REPUTATION_REWARDS_RESPONSE(msg)
		twipe(PRIVATE.REPUTATION_REWARDS)

		for index, rewardStr in ipairs({StringSplitEx(",", msg)}) do
			local itemID, reputationID, moneyCost = strsplit(":", rewardStr)
			tinsert(PRIVATE.REPUTATION_REWARDS, {
				tonumber(itemID), tonumber(reputationID), tonumber(moneyCost)
			})
		end

		table.sort(PRIVATE.REPUTATION_REWARDS, sortRewards)

		PRIVATE.OnDataLoaded()
	end

	function GetNumGuildRewards()
		return #PRIVATE.REPUTATION_REWARDS
	end

	function GetGuildRewardInfo(index)
		if type(index) ~= "number" then
			error("Usage: GetGuildRewards(index)", 2)
		end

		local reward = PRIVATE.REPUTATION_REWARDS[index]
		if reward then
			local achievementID
			local itemID, reputationID, moneyCost = reward[1], reward[2], reward[3]
			local itemName, iconTexture, _
			if itemID then
				itemName, _, _, _, _, _, _, _, _, iconTexture = C_Item.GetItemInfo(itemID, nil, nil, true, false)
			end
			return achievementID, itemID, itemName, iconTexture or QUESTION_MARK_ICON, reputationID, moneyCost
		end
	end
end

do -- ACMSG_GUILD_ONLINE_REQUEST
	function EventHandler:ASMSG_GUILD_PLAYERS_COUNT(msg)
		local onlinePlayer, totalPlayer = strsplit(":", msg)
		PRIVATE.NUM_PLAYERS_ONLINE = tonumber(onlinePlayer)
		PRIVATE.NUM_PLAYERS_TOTAL = tonumber(totalPlayer)
	end

	function GetGuildOnline()
		return PRIVATE.NUM_PLAYERS_ONLINE or GetNumGuildMembers(), PRIVATE.NUM_PLAYERS_TOTAL or GetNumGuildMembers(true)
	end
end

do -- ACMSG_GUILD_EMBLEM_REQUEST
	function EventHandler:ASMSG_PLAYER_GUILD_EMBLEM_INFO(msg)
		local emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = strsplit(":", msg)

		PRIVATE.EMBLEM_STYLE = tonumber(emblemStyle)
		PRIVATE.EMBLEM_COLOR = tonumber(emblemColor)
		PRIVATE.EMBLEM_BORDER_STYLE = tonumber(emblemBorderStyle)
		PRIVATE.EMBLEM_BORDER_COLOR = tonumber(emblemBorderColor)
		PRIVATE.EMBLEM_BACKGROUND_COLOR = tonumber(emblemBackgroundColor)

		local isFullInfo = false
		if PRIVATE.EMBLEM_STYLE and PRIVATE.EMBLEM_COLOR and PRIVATE.EMBLEM_BORDER_STYLE and PRIVATE.EMBLEM_BORDER_COLOR and PRIVATE.EMBLEM_BACKGROUND_COLOR then
			isFullInfo = true
		end

		FireCustomClientEvent("GUILD_EMBLEM_UPDATE", isFullInfo)
	end

	function GetGuildEmblemInfo()
		return PRIVATE.EMBLEM_STYLE or 1,
			PRIVATE.EMBLEM_COLOR or 1,
			PRIVATE.EMBLEM_BORDER_STYLE or 1,
			PRIVATE.EMBLEM_BORDER_COLOR or 1,
			PRIVATE.EMBLEM_BACKGROUND_COLOR or 1
	end
end

do -- ASMSG_GUILD_TEAM
	function EventHandler:ASMSG_GUILD_TEAM(msg)
		C_CacheInstance:Set("ASMSG_GUILD_TEAM", tonumber(msg))
		FireCustomClientEvent("GUILD_FACTION_CHANGED")
	end

	function GetGuildFaction()
		local serverFactionGroupID = C_CacheInstance:Get("ASMSG_GUILD_TEAM")
		local factionTag = serverFactionGroupID and SERVER_PLAYER_FACTION_GROUP[serverFactionGroupID] or UnitFactionGroup("player")
		local factionID = PLAYER_FACTION_GROUP[factionTag]
		return factionTag, factionID
	end
end

do -- ACMSG_GUILD_ILVLS_REQUEST
	function EventHandler:ASMSG_GUILD_PLAYERS_ILVL(msg)
		for index, memberItemLevelStr in ipairs({StringSplitEx("|", msg)}) do
			local name, avgItemLevel = strsplit(":", memberItemLevelStr)
			if name then
				PRIVATE.MEMBER_ITEM_LEVEL[strlower(name)] = tonumber(avgItemLevel)
			end
		end

		FireCustomClientEvent("GUILD_ROSTER_UPDATE_EX")
	end

	function GetGuildMemberItemLevel(name)
		if type(name) ~= "string" then
			error("Usage: GetGuildMemberItemLevel(\"guildMemberName\")", 2)
		end
		return PRIVATE.MEMBER_ITEM_LEVEL[strlower(name)]
	end
end

do -- ACMSG_GUILD_CATEGORY_REQUEST
	function EventHandler:ASMSG_GUILD_PLAYERS_CATEGORY(msg)
		for index, memberCategoryStr in ipairs({StringSplitEx("|", msg)}) do
			local name, spellID = strsplit(":", memberCategoryStr)
			if name then
				PRIVATE.MEMBER_CATEGORY[strlower(name)] = tonumber(spellID)
			end
		end

		FireCustomClientEvent("GUILD_ROSTER_UPDATE_EX")
	end

	function GetGuildCharacterCategory(name)
		if type(name) ~= "string" then
			error("Usage: GetGuildCharacterCategory(\"guildMemberName\")", 2)
		end
		return PRIVATE.MEMBER_CATEGORY[strlower(name)]
	end
end

do -- ACMSG_GUILD_CHALLENGE_REQUEST
	function EventHandler:ASMSG_GUILD_PLAYERS_CHALLENGE(msg)
		for index, memberChallengeStr in ipairs({StringSplitEx("|", msg)}) do
			local name, challengeID = strsplit(":", memberChallengeStr)
			if name then
				PRIVATE.MEMBER_CHALLANGE[strlower(name)] = tonumber(challengeID)
			end
		end

		FireCustomClientEvent("GUILD_ROSTER_UPDATE_EX")
	end

	function GetGuildMemberChallenge(name)
		if type(name) ~= "string" then
			error("Usage: GetGuildMemberChallenge(\"guildMemberName\")", 2)
		end
		return PRIVATE.MEMBER_CHALLANGE[strlower(name)]
	end
end

do -- ASMSG_GUILD_SET_CAN_RENAME
	function EventHandler:ASMSG_GUILD_SET_CAN_RENAME(msg)
		local available, forced = strsplit(":", msg)

		PRIVATE.RENAME_AVAILABLE = available == "1"
		PRIVATE.RENAME_FORCED = forced == "1"

		FireCustomClientEvent("GUILD_RENAME_AVAILABLE", PRIVATE.RENAME_AVAILABLE, PRIVATE.RENAME_FORCED)
	end

	function EventHandler:ASMSG_GUILD_RENAME_RESPONSE(msg)
		msg = tonumber(msg)
		FireCustomClientEvent("GUILD_RENAME_RESULT", msg == 0, msg)
	end

	function CanRenameGuild()
		return PRIVATE.RENAME_AVAILABLE or false, PRIVATE.RENAME_FORCED or false
	end

	function SubmitGuildRename(newGuildName)
		SendServerMessage("ACMSG_GUILD_RENAME_REQUEST", newGuildName)
	end
end

do -- ACMSG_GUILD_REPLACE_GUILD_MASTER
	function EventHandler:ASMSG_GUILD_REPLACE_GUILD_MASTER(msg)
		local oldGM, newGM = strsplit(",", msg)
		AddChatTyppedMessage("SYSTEM", string.format(ERR_GUILD_LEADER_REPLACED, oldGM, newGM))
		FireCustomClientEvent("GUILD_REPLACE_GUILD_MASTER")
	end

	function CanReplaceGuildMaster()
		if IsInGuild() and not IsGuildLeader() then
			local playerName = UnitName("player")
			local gmCanBeReplaced, playerCanBeGM
			for i = 1, GetNumGuildMembers() do
				local name, rank, rankIndex = GetGuildRosterInfo(i)
				if rankIndex == 0 then
					local year, month, day, hour = GetGuildRosterLastOnline(i)
					day = (day or 0) + (month and month * 30 or 0) + (year and year * 365 or 0)
					if day >= REPLACE_GUILD_MASTER_DAYS then
						gmCanBeReplaced = true
					end
				elseif name == playerName and rankIndex == 1 then
					playerCanBeGM = true
				end
			end

			if gmCanBeReplaced and playerCanBeGM then
				return true
			end
		end

		return false
	end

	function ReplaceGuildMaster()
		if CanReplaceGuildMaster() then
			SendServerMessage("ACMSG_GUILD_REPLACE_GUILD_MASTER")
		end
	end
end

do -- ASMSG_GUILD_INVITE_REQUEST
	function EventHandler:ASMSG_GUILD_INVITE_REQUEST(msg)
		local guildLevel, emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = strsplit(":", msg)

		PRIVATE.INVITE_REQUEST.GUILD_LEVEL = tonumber(guildLevel)
		PRIVATE.INVITE_REQUEST.EMBLEM_STYLE = tonumber(emblemStyle)
		PRIVATE.INVITE_REQUEST.EMBLEM_COLOR = tonumber(emblemColor)
		PRIVATE.INVITE_REQUEST.EMBLEM_BORDER_STYLE = tonumber(emblemBorderStyle)
		PRIVATE.INVITE_REQUEST.EMBLEM_BORDER_COLOR = tonumber(emblemBorderColor)
		PRIVATE.INVITE_REQUEST.EMBLEM_BACKGROUND_COLOR = tonumber(emblemBackgroundColor)
	end
end