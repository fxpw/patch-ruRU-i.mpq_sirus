local date = date
local ipairs = ipairs
local pcall = pcall
local time = time
local tonumber = tonumber
local tostring = tostring
local type = type
local mathmax = math.max
local utf8byte, utf8clean, utf8gsub, utf8len, utf8remove = utf8.byte, utf8.clean, utf8.gsub, utf8.len, utf8.remove
local strformat, strgmatch, strgsub, strsplit, strtrim = string.format, string.gmatch, string.gsub, string.split, string.trim
local tconcat, tinsert, tsort, twipe = table.concat, table.insert, table.sort, table.wipe

local strconcat = strconcat
local UnitName = UnitName

local FireCustomClientEvent = FireCustomClientEvent
local FormatRelativeDate = FormatRelativeDate
local GMError = GMError
local GetLocalTimezoneOffset = GetLocalTimezoneOffset
local IsInterfaceDevClient = IsInterfaceDevClient
local ParseJSONString = ParseJSONString
local ParseTimeISO8061 = ParseTimeISO8061
local UpgradeLoadedVariables = UpgradeLoadedVariables
local WithinRange = WithinRange

local SERVER_NEWS_EMBED_NO_DESCRIPTION_LINK = SERVER_NEWS_EMBED_NO_DESCRIPTION_LINK

Enum.ServerNews_DataFeedType = {
	Announce = 1,
	Changes = 2,
}

local HIDE_ENTRY_TAG = "##"

local VISIBILITY_TAG = {
	["#x1"] = E_REALM_ID.SOULSEEKER,
	["#x2"] = E_REALM_ID.SCOURGE,
	["#x5"] = E_REALM_ID.SIRUS,
}

local EMOJI = {
	"blush",
	"cherry_blossom",
	"cry",
	"fire",
	"handshake",
	"heart",
	"innocent",
	"jack_o_lantern",
	"kissing_heart",
	"partying_face",
	"pensive",
	"pleading_face",
	"rage",
	"smiling_face_with_3_hearts",
	"smiling_face_with_tear",
	"snowflake",
	"sunglasses",
	"sweat_smile",
	"tada",
	"wink",
	"worried",
}

local CUSTOM_SERVER_NEWS = {DATA_FEED = nil}

local PRIVATE = {
	LOCAL_TIME_ZONE_OFFSET = GetLocalTimezoneOffset() or 0,
	MESSAGE_STORAGE = {},
	DATA_FEED_DYNAMIC = {},
	DATA_FEED_VISIBILITY = {},
	EMOJI = {},
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

		if prefix == "ASMSG_DISCORD_NEWS" then
			local msgIndex, data = strsplit(":", msg, 2)
			msgIndex = tonumber(msgIndex)

			if type(msgIndex) ~= "number" then
				GMError(strformat("[ASMSG_DISCORD_NEWS] Error while processing message `%s`", tostring(msgIndex)))
				return
			end

			if msgIndex == -1 then
				twipe(PRIVATE.MESSAGE_STORAGE)
				PRIVATE.MESSAGE_STORAGE.size = tonumber(data)
			else
				tinsert(PRIVATE.MESSAGE_STORAGE, data)

				if (msgIndex + 1) == PRIVATE.MESSAGE_STORAGE.size then
					local fullMessage = tconcat(PRIVATE.MESSAGE_STORAGE, "")

					twipe(PRIVATE.DATA_FEED_DYNAMIC)
					twipe(PRIVATE.DATA_FEED_VISIBILITY)
					twipe(PRIVATE.MESSAGE_STORAGE)
					PRIVATE.MESSAGE_STORAGE.size = nil

					if IsInterfaceDevClient() then
						PRIVATE.jsonMessage = fullMessage
					end

					if fullMessage == "null" then
						CUSTOM_SERVER_NEWS.DATA_FEED = nil
						CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP = nil
						FireCustomClientEvent("SERVER_NEWS_UPDATE")
						return
					end

					local success, res = pcall(ParseJSONString, fullMessage)
					if success then
						local maxTimestamp = 0

						for feedType, feed in ipairs(res) do
							for messageIndex, message in ipairs(feed) do
								if message.timestamp then
									local timestamp, unixTimestamp = ParseTimeISO8061(message.timestamp, true)
									if unixTimestamp then
										message.createdTimestampUnix = unixTimestamp
										maxTimestamp = math.max(maxTimestamp, unixTimestamp)
									end

									message.createdTimestamp = message.timestamp
									message.timestamp = nil

									if not message.createdTimestampUnix then
										message.createdTimestampUnix = message.createdTimestamp
									end
								elseif message.createdTimestamp then
									message.createdTimestamp = message.createdTimestamp / 1000
									message.createdTimestampUnix = message.createdTimestamp
									message.createdTimestampNoOffset = true
									maxTimestamp = math.max(maxTimestamp, message.createdTimestampUnix)
								end
								if message.edited_timestamp then
									local timestamp, unixTimestamp = ParseTimeISO8061(message.edited_timestamp, true)
									if unixTimestamp then
										message.editedTimestampUnix = unixTimestamp
										maxTimestamp = math.max(maxTimestamp, unixTimestamp)
									end

									message.editedTimestamp = message.edited_timestamp
									message.edited_timestamp = nil

									if not message.editedTimestampUnix then
										message.editedTimestampUnix = message.editedTimestamp
									end
								elseif message.editedTimestamp then
									message.editedTimestamp = message.editedTimestamp / 1000
									message.editedTimestampUnix = message.editedTimestamp
									message.editedTimestampNoOffset = true
									maxTimestamp = math.max(maxTimestamp, message.editedTimestampUnix)
								end
							end

							tsort(feed, PRIVATE.SortMessages)
						end

						CUSTOM_SERVER_NEWS.DATA_FEED = res
						CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP = maxTimestamp
						FireCustomClientEvent("SERVER_NEWS_UPDATE")
					else
						GMError(strformat("[ASMSG_DISCORD_NEWS] JSON processing error: %s", res))
						return
					end
				end
			end
		end
	elseif event == "VARIABLES_LOADED" then
		self:UnregisterEvent(event)

		PRIVATE.VARIABLES_LOADED = true
		CUSTOM_SERVER_NEWS = UpgradeLoadedVariables("CUSTOM_SERVER_NEWS", CUSTOM_SERVER_NEWS)

		if type(CUSTOM_SERVER_NEWS.DATA_FEED) == "table" then
			FireCustomClientEvent("SERVER_NEWS_UPDATE")
		end
	elseif event == "PLAYER_LOGOUT" then
		_G.CUSTOM_SERVER_NEWS = CUSTOM_SERVER_NEWS
	end
end)

PRIVATE.SortMessages = function(messageA, messageB)
	local messageTimeA = mathmax(messageA.editedTimestampUnix or messageA.createdTimestampUnix)
	local messageTimeB = mathmax(messageB.editedTimestampUnix or messageB.createdTimestampUnix)

	if messageTimeA ~= messageTimeB then
		return messageTimeA > messageTimeB
	end

	return messageA.id > messageB.id
end

local TIME_DIFF_GROUP = {
	{1, TIME_RELATIVE_NOW},
	{SECONDS_PER_MIN, TIME_RELATIVE_SECOND, function(x) return x end},
	{SECONDS_PER_HOUR, TIME_RELATIVE_MINUT, function(x) return math.floor(x / SECONDS_PER_MIN) end},
	{SECONDS_PER_DAY, TIME_RELATIVE_HOUR, function(x) return math.floor(x / SECONDS_PER_HOUR) end},
	{SECONDS_PER_DAY * 2, TIME_RELATIVE_YESTERDAY},
--	{(SECONDS_PER_DAY * 7), TIME_RELATIVE_DAY, function(x) return math.floor(x / SECONDS_PER_DAY) end},
--	{(SECONDS_PER_DAY * 7) * 4, TIME_RELATIVE_WEEK, function(x) return math.floor(x / (SECONDS_PER_DAY * 7)) end},
	{SECONDS_PER_MONTH, TIME_RELATIVE_DAY, function(x) return math.floor(x / SECONDS_PER_DAY) end},
--	{SECONDS_PER_YEAR, TIME_RELATIVE_MONTH, function(x) return math.floor(x / SECONDS_PER_MONTH) end},
--	{SECONDS_PER_YEAR * 10, TIME_RELATIVE_YEAR, function(x) return math.floor(x / SECONDS_PER_YEAR) end},
}

--local BULLET_TEXTURE_STR = CreateTextureMarkup([[Interface\EncounterJournal\UI-EncounterJournalTextures]], 512, 1024, 13, 13, 0.974609375, 1, 0.7509765625, 0.763671875, 0, -1)
local BULLET_TEXTURE_STR = CreateTextureMarkup([[Interface\Scenarios\ScenarioIcon-Combat]], 16, 16, 16, 16, 0, 1, 0, 1, 0, 0)
local BULLET_TEXTURE_STR_GSUB = strformat("%%1%s", BULLET_TEXTURE_STR)

local URL_COLOR = "003ACC"
local LINK_GSUB = strformat("%%1|cff%1$s|Hurl:%%2|h[%2$s]|h|r", URL_COLOR, SERVER_NEWS_LINK_TEXT)
local LINK_TEXT_GSUB = strformat("|cff%1$s|Hurl:%%2|h[%%1]|h|r", URL_COLOR)

PRIVATE.Init = function()
	if IsInterfaceDevClient() then
		PRIVATE_SN = PRIVATE
	end

	for index, emoji in ipairs(EMOJI) do
		local atlasName = strformat("Custom-Emoji-32-%s", emoji)
		if C_Texture.HasAtlasInfo(atlasName) then
			PRIVATE.EMOJI[emoji] = CreateAtlasMarkup(atlasName, 16, 16, 2, 2, 256, 256)
		end
	end
end

PRIVATE.RemoveInvisibleUTF8Chars = function(str)
	local index = 1
	local size = utf8len(str)
	while index <= size do
		local byte = utf8byte(str, index, index)
		if byte == 8203 then
			str = utf8remove(str, index, index)
			size = size - 1
		end
		index = index + 1
	end
	return str
end

PRIVATE.ReplaceEmoji = function(str)
	return PRIVATE.EMOJI[str] or ""
end

PRIVATE.ProcessContentText = function(str)
	str = strtrim(str)
	str = utf8clean(str)
	str = PRIVATE.RemoveInvisibleUTF8Chars(str)
	str = strgsub(str, "\124", "\124\124")
	str = strgsub(str, "\n\n\n+", "\n\n")
	str = strgsub(str, "[^%S\n][^%S\n]+", " ")
	str = strgsub(str, "%*%*([^%*]+)%*%*", "%1") -- bold
	str = strgsub(str, "(%s)@[^%s]+%s*", "%1") -- mentions
	str = strgsub(str, "^@[^%s]+%s*", "") -- mentions
	str = strgsub(str, "%s*:([A-z][A-z_0-9-~]+)::[A-z_0-9-~]+:", PRIVATE.ReplaceEmoji) -- emoji
	str = strgsub(str, "%s*:([A-z][A-z_0-9-~]+):", PRIVATE.ReplaceEmoji) -- emoji
	str = strgsub(str, "([%^\n])%* ", BULLET_TEXTURE_STR_GSUB)
	str = strgsub(str, "%*%*([^%*]+)%*%*", "|cff79092D%1|r")
	str = strgsub(str, "%[([^%]]+)%]%((https?:%/%/[^%)]+)%)", LINK_TEXT_GSUB)
	str = strgsub(str, "(%s)(https?://[^%s]+)", LINK_GSUB)
	str = strgsub(str, "^(%s*)(https?://[^%s]+)", LINK_GSUB)
	str = strgsub(str, "[^%S\n][^%S\n]+", " ")
	str = strtrim(str)
	return str
end

PRIVATE.ProcessEmbedText = function(str)
	str = strtrim(str)
	str = utf8clean(str)
	str = PRIVATE.RemoveInvisibleUTF8Chars(str)
	str = strgsub(str, "\124", "\124\124")
	str = strgsub(str, "\n\n\n+", "\n\n")
	str = strgsub(str, "[^%S\n][^%S\n]+", " ")
	str = strgsub(str, "%*%*([^%*]+)%*%*", "%1") -- bold
	str = strgsub(str, "(%s)@[^%s]+%s*", "%1") -- mentions
	str = strgsub(str, "^@[^%s]+%s*", "") -- mentions
	str = strgsub(str, "%s*:([A-z][A-z_0-9-~]+)::[A-z_0-9-~]+:", PRIVATE.ReplaceEmoji) -- emoji
	str = strgsub(str, "%s*:([A-z][A-z_0-9-~]+):", PRIVATE.ReplaceEmoji) -- emoji
	str = utf8gsub(str, "%s*%S*%.%.%.$", "...")
	str = strgsub(str, "[^%S\n][^%S\n]+", " ")
	str = strtrim(str)
	return str
end

PRIVATE.FormatWebLink = function(url, text)
	return strformat("|cff%1$s|Hurl:%2$s|h[%3$s]|h|r", URL_COLOR, url, text)
end

PRIVATE.FormatDate = function(unixTimestamp, offsetSeconds, fmt)
	if fmt ~= nil and type(fmt) ~= "string" then
		error(strformat("bad argument #1 to 'FormatDate' (string or nil expected, got %s)", type(fmt)), 2)
	elseif offsetSeconds ~= nil and type(offsetSeconds) ~= "number" then
		error(strformat("bad argument #1 to 'FormatDate' (number or nil expected, got %s)", type(offsetSeconds)), 2)
	end

	return date(fmt or "%Y-%m-%d %H:%M:%S", unixTimestamp + (offsetSeconds or 0))
end

PRIVATE.ShouldShowEntry = function(entry)
	if entry.content == "" then
		if #entry.embeds > 0 then
			local anyText = false

			for index, embed in ipairs(entry.embeds) do
				local title = embed.title and PRIVATE.ProcessEmbedText(embed.title)
				local description = embed.description and PRIVATE.ProcessEmbedText(embed.description)

				local hasTitle = type(title) == "string" and title ~= ""
				local hasDescription = type(description) == "string" and description ~= ""

				if hasTitle or hasDescription then
					anyText = true
					break
				end
			end

			if not anyText then
				return false
			end
		else
			return false
		end
	end

	if entry.content then
		if not PRIVATE.REALM_ID then
			PRIVATE.REALM_ID = C_Service.GetRealmID()
		end

		if strfind(entry.content, HIDE_ENTRY_TAG, 1, true) then
			return false
		end

		do
			local isValid

			for tag in strgmatch(entry.content, "(#x%d+)") do
				if VISIBILITY_TAG[tag] == PRIVATE.REALM_ID then
					isValid = true
				elseif isValid == nil then
					isValid = false
				end
			end

			if isValid == false then
				return false
			end
		end

		do
			local isValid = true

			for index, embed in ipairs(entry.embeds) do
				if embed.description then
					if strfind(embed.description, HIDE_ENTRY_TAG, 1, true) then
						return false
					end

					for tag in strgmatch(embed.description, "(#x%d+)") do
						if VISIBILITY_TAG[tag] == PRIVATE.REALM_ID then
							isValid = true
						elseif isValid == nil then
							isValid = false
						end
					end
				end
			end

			if isValid == false then
				return false
			end
		end
	end

	return true
end

PRIVATE.IsValidEntry = function(entry)
	local visibilityData = PRIVATE.DATA_FEED_VISIBILITY[entry.id or entry]
	if visibilityData ~= nil then
		return visibilityData
	end

	local isValid = PRIVATE.ShouldShowEntry(entry)
	PRIVATE.DATA_FEED_VISIBILITY[entry.id or entry] = isValid

	return isValid
end

PRIVATE.Init()

C_ServerNews = {}

function C_ServerNews.CanViewNews()
	return true
end

function C_ServerNews.HasAnyNewEntries(ignorePreviousTimestamp)
	if not CUSTOM_SERVER_NEWS.DATA_FEED
	or (not CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP or CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP <= 0)
	then
		return false
	end

	if not CUSTOM_SERVER_NEWS.LAST_SEEN_TIMESTAMP or CUSTOM_SERVER_NEWS.LAST_SEEN_TIMESTAMP == 0 then
		return true
	end

	if CUSTOM_SERVER_NEWS.LAST_SEEN_TIMESTAMP < CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP then
		return true
	elseif PRIVATE.PREVIOUS_SEEN_TIMESTAMP and not ignorePreviousTimestamp then
		return true
	end

	return false
end

function C_ServerNews.MarkEntriesSeen()
	if not CUSTOM_SERVER_NEWS.DATA_FEED
	or (not CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP or CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP <= 0)
	then
		return false
	end

	if CUSTOM_SERVER_NEWS.LAST_SEEN_TIMESTAMP ~= CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP then
		PRIVATE.PREVIOUS_SEEN_TIMESTAMP = CUSTOM_SERVER_NEWS.LAST_SEEN_TIMESTAMP or 0
	end

	CUSTOM_SERVER_NEWS.LAST_SEEN_TIMESTAMP = CUSTOM_SERVER_NEWS.LAST_MESSAGE_TIMESTAMP

	return true
end

function C_ServerNews.GetLastSeenTimestamp()
	return PRIVATE.PREVIOUS_SEEN_TIMESTAMP or 0
end

function C_ServerNews.IsAnyDataFeedAvailable()
	if not CUSTOM_SERVER_NEWS.DATA_FEED then
		return false
	end

	for datafeedType, dataFeed in ipairs(CUSTOM_SERVER_NEWS.DATA_FEED) do
		if #dataFeed > 0 then
			return true
		end
	end

	return false
end

function C_ServerNews.IsDataFeedAvailable(dataFeedType)
	if type(dataFeedType) ~= "number" then
		error(strformat("bad argument #1 to 'C_ServerNews.IsDataFeedAvailable' (number expected, got %s)", type(dataFeedType)), 2)
	elseif not WithinRange(dataFeedType, 1, 2) then
		error(strformat("bad argument #1 to 'C_ServerNews.IsDataFeedAvailable' (dataFeedType out of range `%i`)", type(dataFeedType)), 2)
	end

	local dataFeed = CUSTOM_SERVER_NEWS.DATA_FEED and CUSTOM_SERVER_NEWS.DATA_FEED[dataFeedType]

	if type(dataFeed) ~= "table" then
		return false
	end

	return #dataFeed > 0
end

function C_ServerNews.GetNumEntriesForDataFeedType(dataFeedType, fromTimeStamp)
	if type(dataFeedType) ~= "number" then
		error(strformat("bad argument #1 to 'C_ServerNews.GetNumEntriesForDataFeedType' (number expected, got %s)", type(dataFeedType)), 2)
	elseif not WithinRange(dataFeedType, 1, 2) then
		error(strformat("bad argument #1 to 'C_ServerNews.GetNumEntriesForDataFeedType' (dataFeedType out of range `%i`)", type(dataFeedType)), 2)
	elseif fromTimeStamp ~= nil and type(fromTimeStamp) ~= "number" then
		error(strformat("bad argument #2 to 'C_ServerNews.GetNumEntriesForDataFeedType' (number expected, got %s)", type(fromTimeStamp)), 2)
	end

	local dataFeed = CUSTOM_SERVER_NEWS.DATA_FEED and CUSTOM_SERVER_NEWS.DATA_FEED[dataFeedType]

	if type(dataFeed) ~= "table" then
		return 0
	end

	local numNotSeenMessages = 0

	if not fromTimeStamp or fromTimeStamp <= 0 then
		for messageIndex, message in ipairs(dataFeed) do
			if PRIVATE.IsValidEntry(message) then
				numNotSeenMessages = numNotSeenMessages + 1
			end
		end
	else
		for messageIndex, message in ipairs(dataFeed) do
			local unitTimestamp = message.editedTimestampUnix or message.createdTimestampUnix

			if unitTimestamp and (unitTimestamp == 0 or unitTimestamp > fromTimeStamp)
			and PRIVATE.IsValidEntry(message)
			then
				numNotSeenMessages = numNotSeenMessages + 1
			end
		end
	end

	return numNotSeenMessages
end

function C_ServerNews.GetEntryForDataFeedType(dataFeedType, entryIndex, fromTimeStamp)
	if type(dataFeedType) ~= "number" then
		error(strformat("bad argument #1 to 'C_ServerNews.GetEntryForDataFeedType' (number expected, got %s)", type(dataFeedType)), 2)
	elseif not WithinRange(dataFeedType, 1, 2) then
		error(strformat("bad argument #1 to 'C_ServerNews.GetEntryForDataFeedType' (dataFeedType out of range `%i`)", type(dataFeedType)), 2)
	elseif fromTimeStamp and type(fromTimeStamp) ~= "number" then
		error(strformat("bad argument #3 to 'C_ServerNews.GetEntryForDataFeedType' (number expected, got %s)", type(fromTimeStamp)), 2)
	end

	local dataFeed = CUSTOM_SERVER_NEWS.DATA_FEED and CUSTOM_SERVER_NEWS.DATA_FEED[dataFeedType]

	if type(dataFeed) ~= "table" then
		error(strformat("bad argument #1 to 'C_ServerNews.GetEntryForDataFeedType' (DataFeed not found)", type(entryIndex)), 2)
	end

	local entry

	if not fromTimeStamp or fromTimeStamp <= 0 then
		local numNotSeenMessages = 0
		for messageIndex, message in ipairs(dataFeed) do
			if PRIVATE.IsValidEntry(message) then
				numNotSeenMessages = numNotSeenMessages + 1
				if numNotSeenMessages == entryIndex then
					entry = message
					break
				end
			end
		end
	else
		local numNotSeenMessages = 0
		for messageIndex, message in ipairs(dataFeed) do
			local unitTimestamp = message.editedTimestampUnix or message.createdTimestampUnix

			if unitTimestamp and (unitTimestamp == 0 or unitTimestamp > fromTimeStamp)
			and PRIVATE.IsValidEntry(message)
			then
				numNotSeenMessages = numNotSeenMessages + 1
				if numNotSeenMessages == entryIndex then
					entry = message
					break
				end
			end
		end
	end

	if not entry then
		error(strformat("bad argument #1 to 'C_ServerNews.GetEntryForDataFeedType' (entryIndex out of range `%i`)", type(entryIndex)), 2)
	end

	local dynamicData = PRIVATE.DATA_FEED_DYNAMIC[entry.id or entry]
	if not dynamicData then
		-- cache processed text
		dynamicData = {}

		if entry.content then
			dynamicData.content = PRIVATE.ProcessContentText(entry.content)
		end

		if entry.createdTimestampUnix then
			local offset = entry.createdTimestampNoOffset and 0 or PRIVATE.LOCAL_TIME_ZONE_OFFSET
			dynamicData.createdTimestamp = PRIVATE.FormatDate(entry.createdTimestampUnix, offset) or entry.createdTimestamp
		else
			dynamicData.createdTimestamp = entry.createdTimestamp
		end

		if entry.editedTimestampUnix then
			local offset = entry.editedTimestampNoOffset and 0 or PRIVATE.LOCAL_TIME_ZONE_OFFSET
			dynamicData.editedTimestamp = PRIVATE.FormatDate(entry.editedTimestampUnix, offset) or entry.editedTimestamp
		else
			dynamicData.editedTimestamp = entry.editedTimestamp
		end

		if #entry.embeds > 0 then
			local hasContent = dynamicData.content and dynamicData.content ~= ""

			for index, embed in ipairs(entry.embeds) do
				local title = embed.title and PRIVATE.ProcessEmbedText(embed.title)
				local description = embed.description and PRIVATE.ProcessEmbedText(embed.description)

				local hasTitle = type(title) == "string" and title ~= ""
				local hasDescription = type(description) == "string" and description ~= ""

				if embed.url and embed.url ~= "" then
					description = strconcat(description or "", hasDescription and "\n" or "", PRIVATE.FormatWebLink(embed.url, SERVER_NEWS_EMBED_NO_DESCRIPTION_LINK))
				end

				if hasTitle and (hasDescription or embed.url) then
					dynamicData[index] = {
						title = hasTitle and title,
						description = hasDescription and description or "",
						url = embed.url,
					}

					if not hasContent then
						if description and description ~= "" then
						--	dynamicData.content = strconcat(title, "\n", description)
							if hasDescription then
								dynamicData.content = description
								hasContent = true
							elseif hasTitle then
								dynamicData.content = title
								hasContent = true
							end
						end

						dynamicData[index].skip = true
					end
				end
			end
		end

		PRIVATE.DATA_FEED_DYNAMIC[entry.id or entry] = dynamicData
	end

	local entryData = {
		id = entry.id,
		content = dynamicData.content,
		createdTimestamp = dynamicData.createdTimestamp,
		editedTimestamp = dynamicData.editedTimestamp,
	}

	do -- always regenerate relative time
		local currentTime = time()
		if entry.createdTimestampUnix then
			entryData.createdTimestampRelative = FormatRelativeDate(entry.createdTimestampUnix, PRIVATE.LOCAL_TIME_ZONE_OFFSET, currentTime, true, TIME_DIFF_GROUP)
		end
		if entry.editedTimestampUnix then
			entryData.editedTimestampRelative = FormatRelativeDate(entry.editedTimestampUnix, PRIVATE.LOCAL_TIME_ZONE_OFFSET, currentTime, true, TIME_DIFF_GROUP)
		end
	end

	local embeds = {}

	for index, embed in ipairs(entry.embeds) do
		if dynamicData[index] and not dynamicData[index].skip then
			tinsert(embeds, {
				title = dynamicData[index].title,
				description = dynamicData[index].description,
				url = embed.url
			})
		end
	end

	entryData.embeds = embeds

	return entryData
end