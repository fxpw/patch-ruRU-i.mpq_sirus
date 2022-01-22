--	Filename:	API_Guild.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

SIRUS_GUILD_RENAME = {}

API_Guild = CreateFrame("Frame")
API_Guild.SendRequest = true
API_Guild:RegisterEvent("PLAYER_LOGIN")
API_Guild:RegisterEvent("PLAYER_GUILD_UPDATE")
API_Guild:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		if IsInGuild() then
			SendAddonMessage("ACMSG_GUILD_LEVEL_REQUEST", nil, "WHISPER", UnitName("player"))
			SendAddonMessage("ACMSG_GUILD_REPUTATION_REQUEST", nil, "WHISPER", UnitName("player"))
			SendAddonMessage("ACMSG_GUILD_SPELLS_REQUEST", nil, "WHISPER", UnitName("player"))
			SendAddonMessage("ACMSG_GUILD_REPUTATION_REWARDS_REQUEST", nil, "WHISPER", UnitName("player"))
			SendAddonMessage("ACMSG_GUILD_ONLINE_REQUEST", nil, "WHISPER", UnitName("player"))
			SendAddonMessage("ACMSG_GUILD_CATEGORY_REQUEST", nil, "WHISPER", UnitName("player"))

			self.SendRequest = false;
		end
	elseif event == "PLAYER_GUILD_UPDATE" then
		if IsInGuild() then
			if self.SendRequest then
				SendAddonMessage("ACMSG_GUILD_SPELLS_REQUEST", nil, "WHISPER", UnitName("player"))
				SendAddonMessage("ACMSG_GUILD_REPUTATION_REWARDS_REQUEST", nil, "WHISPER", UnitName("player"))
				SendAddonMessage("ACMSG_GUILD_REPUTATION_REQUEST", nil, "WHISPER", UnitName("player"))

				self.SendRequest = false;
			end
		else
			if not self.SendRequest then
				self.SendRequest = true;
			end
		end
	end
end)

-- ##################################################
-- Request: ACMSG_GUILD_LEVEL_REQUEST
-- ##################################################

function EventHandler:ASMSG_GUILD_LEVEL_INFO( msg )
	local level, experience, nextLevelxperience, remaining = strsplit(":", msg)
	API_Guild.LevelData = { tonumber(level), tonumber(experience), tonumber(nextLevelxperience), tonumber(remaining) }

	GuildLevelFrameText:SetText(level)

	if GuildFrame:IsShown() and PanelTemplates_GetSelectedTab(GuildFrame) == 2 then
		GuildBar_SetProgress(GuildXPBar, tonumber(experience), tonumber(nextLevelxperience), tonumber(remaining))
	end

	UpdateMicroButtons()
end

function GetGuildXP()
	if API_Guild.LevelData then
		return unpack(API_Guild.LevelData)
	else
		return nil
	end
end

-- ##################################################
-- Request: ACMSG_GUILD_REPUTATION_REQUEST
-- ##################################################

function EventHandler:ASMSG_GUILD_REPUTATION_INFO( msg )
	local reputationRank, reputationMin, reputationMax = strsplit(":", msg)
	API_Guild.ReputationData = { tonumber(reputationRank), tonumber(reputationMin), tonumber(reputationMax) }
	if GuildFrame:IsShown() and PanelTemplates_GetSelectedTab(GuildFrame) == 3 then
		GuildBar_SetProgress(GuildXPBar, tonumber(reputationMin), tonumber(reputationMax), 0)
	end

	UpdateMicroButtons()
end

function GetGuildReputation()
	if API_Guild.ReputationData then
		return unpack(API_Guild.ReputationData)
	else
		return nil
	end
end

-- ##################################################
-- Request: ACMSG_GUILD_SPELLS_REQUEST
-- ##################################################

function EventHandler:ASMSG_GUILD_SPELLS_RESPONSE( msg )
	API_Guild.PerksData = {}

	for spellID, spellLevel in string.gmatch(msg, "(%d+):(%d+),") do
		table.insert(API_Guild.PerksData, { tonumber(spellID), tonumber(spellLevel) })
	end

	UpdateMicroButtons()
end

function GetGuildNumPerks()
	return API_Guild.PerksData and #API_Guild.PerksData or 0
end

function GetGuildPerks( index )
	if API_Guild.PerksData[index] then
		return unpack(API_Guild.PerksData[index])
	else
		return nil
	end
end

-- ##################################################
-- Request: ACMSG_GUILD_REPUTATION_REWARDS_REQUEST
-- ##################################################

function EventHandler:ASMSG_GUILD_REPUTATION_REWARDS_RESPONSE( msg )
	API_Guild.RewardsData = {}

	for itemID, reputationID, moneyCost in string.gmatch(msg, "(%d+):(%d+):(%d+),") do
		table.insert(API_Guild.RewardsData, { tonumber(itemID), tonumber(reputationID), tonumber(moneyCost) })
	end

	table.sort(API_Guild.RewardsData, function(a, b) return a[3] < b[3] end)

	UpdateMicroButtons()
end

function GetGuildNumRewards()
	return API_Guild.RewardsData and #API_Guild.RewardsData or 0
end

function GetGuildRewards( index )
	if API_Guild.RewardsData[index] then
		return unpack(API_Guild.RewardsData[index])
	else
		return nil
	end
end

-- ##################################################
-- Request: ACMSG_GUILD_ONLINE_REQUEST
-- ##################################################

function EventHandler:ASMSG_GUILD_PLAYERS_COUNT( msg )
	local onlinePlayer, totalPlayer = strsplit(":", msg)
	API_Guild.OnlineData = { tonumber(onlinePlayer), tonumber(totalPlayer) }
end

function GetGuildOnline()
	if API_Guild.OnlineData then
		return unpack(API_Guild.OnlineData)
	else
		return -1, -1
	end
end

-- ##################################################
-- Request: ACMSG_GUILD_CATEGORY_REQUEST
-- ##################################################

function EventHandler:ASMSG_GUILD_PLAYERS_CATEGORY( msg )
	if not API_Guild.CategoryData then
		API_Guild.CategoryData = {}
	end

	for name, spellID in string.gmatch(msg, "(.-):(%d+)|") do
		API_Guild.CategoryData[name] = tonumber(spellID)
	end

	GuildRosterFrame_OnEvent(GuildRosterFrame, "GUILD_ROSTER_UPDATE", nil)
end

function GetGuildCharacterCategory( name )
	if API_Guild.CategoryData and API_Guild.CategoryData[name] then
		return API_Guild.CategoryData[name]
	else
		return nil
	end
end

-- ##################################################
-- Response: ASMSG_GUILD_SET_CAN_RENAME
-- ##################################################

function EventHandler:ASMSG_GUILD_SET_CAN_RENAME( msg )
	local can, use = strsplit(":", msg)

	can = tonumber(can) == 1
	use = tonumber(use) == 1

	SIRUS_GUILD_RENAME = {can, use}

	GuildFrame_RenameButtonToggle(can)

	if can and use then
		StaticPopup_Show("SIRUS_RENAME_GUILD")
	end
end