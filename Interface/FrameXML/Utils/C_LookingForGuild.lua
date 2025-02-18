local NUM_LF_GUILD_SETTINGS_FLAGS = 13;
local NUM_LF_GUILD_INTERESTS_FLAGS = 5;
local NUM_LF_GUILD_AVAILABILITY_FLAGS = 2;
local NUM_LF_GUILD_CLASS_ROLES_FLAGS = 3;
local NUM_LF_GUILD_ACTIVITY_TIME_FLAGS = 4;

local RECRUITING_GUILD_SELECTION;
local NUM_RECRUITING_GUILDS = 0;
local RECRUITING_GUILD_INFO = {};

local NUM_GUILD_MEMBERSHIP_APPS = 0;
local NUM_GUILD_MEMBERSHIP_APPS_REMAINING = 0;
local GUILD_MEMBERSHIP_REQUEST_INFO = {};
local GUILD_MEMBERSHIP_REQUESTS = {};

local GUILD_APPLICANT_SELECTION;
local GUILD_RECRUITMENT_SETTINGS = {};

local NUM_GUILD_APPLICANTS = 0;
local GUILD_APPLICANT_INFO = {};

function SetGuildApplicantSelection(index)
	GUILD_APPLICANT_SELECTION = index;
end

function GetGuildApplicantSelection()
	return GUILD_APPLICANT_SELECTION;
end

local function SendGuildRecruitmentSettings()
	local interests, availability, classRoles, activityTimes = 0, 0, 0, 0;

	local index = 0;
	for param = LFGUILD_PARAM_QUESTS, LFGUILD_PARAM_RP do
		if GUILD_RECRUITMENT_SETTINGS[param] then
			interests = bit.bor(interests, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_WEEKDAYS, LFGUILD_PARAM_WEEKENDS do
		if GUILD_RECRUITMENT_SETTINGS[param] then
			availability = bit.bor(availability, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_TANK, LFGUILD_PARAM_DAMAGE do
		if GUILD_RECRUITMENT_SETTINGS[param] then
			classRoles = bit.bor(classRoles, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_MORNING, LFGUILD_PARAM_NIGHT do
		if GUILD_RECRUITMENT_SETTINGS[param] then
			activityTimes = bit.bor(activityTimes, bit.lshift(1, index));
		end
		index = index + 1;
	end

	if interests > 0 and availability > 0 and classRoles > 0 then
		SendServerMessage("ACMSG_GF_SET_GUILD_POST", string.format("%d|%d|%d|%d|%d|%d|%s", GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_MAX_LEVEL] and 2 or 1, classRoles, availability, interests, activityTimes, GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_LOOKING] and 1 or 0, GUILD_RECRUITMENT_SETTINGS[20] or ""));
	end
end

function SetGuildRecruitmentSettings(index, bool)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" or type(bool) ~= "boolean" then
		error("Usage: SetGuildRecruitmentSettings(index, true/false)", 2);
	end

	if index == LFGUILD_PARAM_ANY_LEVEL then
		GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_MAX_LEVEL] = not bool;
	elseif index == LFGUILD_PARAM_MAX_LEVEL then
		GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_ANY_LEVEL] = not bool;
	end

	if index > 0 then
		GUILD_RECRUITMENT_SETTINGS[index] = bool;

		SendGuildRecruitmentSettings();
	end
end

function GetGuildRecruitmentSettingsByIndex(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: local value = GetGuildRecruitmentSettingsByIndex(index)", 2);
	end

	if GUILD_RECRUITMENT_SETTINGS[index] then
		return true;
	end

	return false;
end

function GetGuildRecruitmentSettings()
	return unpack(GUILD_RECRUITMENT_SETTINGS, 1, LFGUILD_PARAM_LOOKING);
end

function GetGuildRecruitmentComment()
	return GUILD_RECRUITMENT_SETTINGS[20] or "";
end

function SetGuildRecruitmentComment(text)
	GUILD_RECRUITMENT_SETTINGS[20] = text;

	SendGuildRecruitmentSettings();
end

function SetRecruitingGuildSelection(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: SetRecruitingGuildSelection(index)", 2);
	end

	RECRUITING_GUILD_SELECTION = index;
end

function GetRecruitingGuildSelection()
	return RECRUITING_GUILD_SELECTION;
end

function SetLookingForGuildSettings(index, bool)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" or type(bool) ~= "boolean" then
		error("Usage: SetLookingForGuildSettings(index, true/false)", 2);
	end

	if bool and (index == LFGUILD_PARAM_SMALL or index == LFGUILD_PARAM_MEDIUM or index == LFGUILD_PARAM_LARGE) then
		C_CVar:SetCVarBitfield("C_CVAR_FL_GUILD_SETTINGS2", LFGUILD_PARAM_SMALL, false);
		C_CVar:SetCVarBitfield("C_CVAR_FL_GUILD_SETTINGS2", LFGUILD_PARAM_MEDIUM, false);
		C_CVar:SetCVarBitfield("C_CVAR_FL_GUILD_SETTINGS2", LFGUILD_PARAM_LARGE, false);
	end

	if index > 0 then
		C_CVar:SetCVarBitfield("C_CVAR_FL_GUILD_SETTINGS2", index, bool);
	end
end

function GetLookingForGuildSettingsByIndex(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: local value = GetLookingForGuildSettingsByIndex(index)", 2);
	end

	return C_CVar:GetCVarBitfield("C_CVAR_FL_GUILD_SETTINGS2", index);
end

function GetLookingForGuildFlagsSelectedCount()
	local selectedCount = 0;

	local value = C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS2") or 0;

	for index = (LFGUILD_PARAM_QUESTS - 1), (LFGUILD_PARAM_NIGHT - 1) do
		if bit.band(value, bit.lshift(1, index)) ~= 0 then
			selectedCount = selectedCount + 1;
		end
	end

	return selectedCount;
end

function SetLookingForGuildComment(text)
	C_CVar:SetValue("C_CVAR_FL_GUILD_COMMENT", text);
end

function GetLookingForGuildComment()
	return C_CVar:GetValue("C_CVAR_FL_GUILD_COMMENT");
end

function CancelGuildMembershipRequest(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: CancelGuildMembershipRequest(index)", 2);
	end

	local guildID = GUILD_MEMBERSHIP_REQUEST_INFO[index] and GUILD_MEMBERSHIP_REQUEST_INFO[index][30];
	if guildID then
		SendServerMessage("ACMSG_GF_REMOVE_RECRUIT", guildID);

		GUILD_MEMBERSHIP_REQUESTS[guildID] = nil;
		table.remove(GUILD_MEMBERSHIP_REQUEST_INFO, index);

		FireCustomClientEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED", (NUM_GUILD_MEMBERSHIP_APPS_REMAINING - 1));
	end
end

function DeclineGuildApplicant(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: DeclineGuildApplicant(index)", 2);
	end

	if GUILD_APPLICANT_INFO[index] and GUILD_APPLICANT_INFO[index][2] then
		SendServerMessage("ACMSG_GF_DECLINE_RECRUIT", GUILD_APPLICANT_INFO[index][2]);
		GUILD_APPLICANT_SELECTION = nil;
	end
end

function GetGuildApplicantInfo(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetGuildApplicantInfo(index)", 2);
	end

	return unpack(GUILD_APPLICANT_INFO[index] or {}, 1, 23);
end

function GetGuildMembershipRequestInfo(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetGuildMembershipRequestInfo(index)", 2);
	end


	if GUILD_MEMBERSHIP_REQUEST_INFO[index] then
		return unpack(GUILD_MEMBERSHIP_REQUEST_INFO[index], 1, 8)
	end
end

function GetGuildMembershipRequestSettings(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetGuildMembershipRequestSettings(index)", 2);
	end

	if GUILD_MEMBERSHIP_REQUEST_INFO[index] then
		return unpack(GUILD_MEMBERSHIP_REQUEST_INFO[index], 9, 22)
	end
end

function GetGuildMembershipRequestTabardInfo(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetRecruitingGuildTabardInfo(index)", 2);
	end

	if GUILD_MEMBERSHIP_REQUEST_INFO[index] then
		return unpack(GUILD_MEMBERSHIP_REQUEST_INFO[index], 23, 27)
	end
end

function GetNumGuildApplicants()
	return NUM_GUILD_APPLICANTS;
end

function GetNumGuildMembershipRequests()
	return NUM_GUILD_MEMBERSHIP_APPS, NUM_GUILD_MEMBERSHIP_APPS_REMAINING;
end

function GetNumRecruitingGuilds()
	return #RECRUITING_GUILD_INFO;
end

function GetRecruitingGuildInfo(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetRecruitingGuildInfo(index)", 2);
	end

	local recruitingGuildInfo = RECRUITING_GUILD_INFO[index];
	if recruitingGuildInfo then
		local guildID = recruitingGuildInfo[30];

		return recruitingGuildInfo[1], recruitingGuildInfo[2], recruitingGuildInfo[3], recruitingGuildInfo[4], GUILD_MEMBERSHIP_REQUESTS[guildID];
	end
end

function GetRecruitingGuildTabardInfo(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetRecruitingGuildTabardInfo(index)", 2);
	end

	return unpack(RECRUITING_GUILD_INFO[index] or {}, 6, 10);
end

function GetRecruitingGuildSettings(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetRecruitingGuildSettings(index)", 2);
	end

	return unpack(RECRUITING_GUILD_INFO[index] or {}, 11, 24);
end

function GetRecruitingGuildID(index)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" then
		error("Usage: GetRecruitingGuildID(index)", 2);
	end

	return RECRUITING_GUILD_INFO[index] and RECRUITING_GUILD_INFO[index][30];
end

function RequestGuildApplicantsList()
	SendServerMessage("ACMSG_GF_GET_RECRUITS", "");
end

function RequestGuildMembershipList()
	SendServerMessage("ACMSG_GF_GET_APPLICATIONS", "");
end

function RequestGuildMembership(index, text)
	if type(index) == "string" then
		index = tonumber(index);
	end

	if type(index) ~= "number" or type(text) ~= "string" then
		error("Usage: RequestGuildMembership(index, text)", 2);
	end

	local guildID = RECRUITING_GUILD_INFO[index] and RECRUITING_GUILD_INFO[index][30];
	if guildID then
		local value = tonumber(C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS2")) or 0;

		local interests, availability, classRoles, activityTimes = 0, 0, 0, 0;

		local flagIndex = 0;
		for param = LFGUILD_PARAM_QUESTS, LFGUILD_PARAM_RP do
			if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
				interests = bit.bor(interests, bit.lshift(1, flagIndex));
			end
			flagIndex = flagIndex + 1;
		end

		flagIndex = 0;
		for param = LFGUILD_PARAM_WEEKDAYS, LFGUILD_PARAM_WEEKENDS do
			if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
				availability = bit.bor(availability, bit.lshift(1, flagIndex));
			end
			flagIndex = flagIndex + 1;
		end

		flagIndex = 0;
		for param = LFGUILD_PARAM_TANK, LFGUILD_PARAM_DAMAGE do
			if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
				classRoles = bit.bor(classRoles, bit.lshift(1, flagIndex));
			end
			flagIndex = flagIndex + 1;
		end

		flagIndex = 0;
		for param = LFGUILD_PARAM_MORNING, LFGUILD_PARAM_NIGHT do
			if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
				activityTimes = bit.bor(activityTimes, bit.lshift(1, flagIndex));
			end
			flagIndex = flagIndex + 1;
		end

		SendServerMessage("ACMSG_GF_ADD_RECRUIT", string.format("%d|%d|%d|%d|%d|%s", classRoles, interests, availability, guildID, activityTimes, text));

		RECRUITING_GUILD_INFO[index][5] = true;
		GUILD_MEMBERSHIP_REQUESTS[guildID] = true;

		FireCustomClientEvent("LF_GUILD_BROWSE_UPDATED");
	end
end

function RequestGuildRecruitmentSettings()
	SendServerMessage("ACMSG_GF_POST_REQUEST", "");
end

function RequestRecruitingGuildsList(searchName)
	if type(searchName) ~= "string" then
		searchName = "";
	end

	local value = tonumber(C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS2")) or 0;

	local interests, availability, classRoles, activityTimes, guildSize = 0, 0, 0, 0, 0;

	local index = 0;
	for param = LFGUILD_PARAM_QUESTS, LFGUILD_PARAM_RP do
		if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
			interests = bit.bor(interests, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_WEEKDAYS, LFGUILD_PARAM_WEEKENDS do
		if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
			availability = bit.bor(availability, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_TANK, LFGUILD_PARAM_DAMAGE do
		if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
			classRoles = bit.bor(classRoles, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_MORNING, LFGUILD_PARAM_NIGHT do
		if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
			activityTimes = bit.bor(activityTimes, bit.lshift(1, index));
		end
		index = index + 1;
	end

	index = 0;
	for param = LFGUILD_PARAM_SMALL, LFGUILD_PARAM_LARGE do
		if bit.band(value, bit.lshift(1, param - 1)) ~= 0 then
			guildSize = bit.bor(guildSize, bit.lshift(1, index));
		end
		index = index + 1;
	end

	SendServerMessage("ACMSG_GF_BROWSE", string.format("%s|%s|%s|%s|%s|%s", classRoles, availability, interests, activityTimes, guildSize, searchName));
end

function AcceptGuildMembership(index)
	if type(index) ~= "number" then
		error("Usage: AcceptGuildMembership(index)", 2)
	end

	local requestInfo = GUILD_MEMBERSHIP_REQUEST_INFO[index]
	if requestInfo and requestInfo[8] then
		local guildID = requestInfo[30]
		if guildID then
			SendServerMessage("ACMSG_GF_ACCEPT_INVITE", guildID)
		end
	end
end

function EventHandler:ASMSG_GF_BROWSE_UPDATED(msg)
	table.wipe(GUILD_MEMBERSHIP_REQUESTS);
	table.wipe(RECRUITING_GUILD_INFO);

	NUM_RECRUITING_GUILDS = tonumber(msg) or 0;

	if NUM_RECRUITING_GUILDS == 0 then
		FireCustomClientEvent("LF_GUILD_BROWSE_UPDATED");
	end
end

local GF_BROWSE_UPDATE = {
	GuildID = 1,
	EmblemInfo = 2,
	Comment = 3,
	Interests = 4,
	Level = 5,
	Name = 6,
	HasRequest = 7,
	Availability = 8,
	ClassRoles = 9,
	MemberCount = 10,
	ActivityTimes = 11,
};

function EventHandler:ASMSG_GF_BROWSE_UPDATE(msg)
	local guild = {strsplit("|", msg)};

	local guildID = tonumber(guild[GF_BROWSE_UPDATE.GuildID]) or 0;
	local requestPending = guild[GF_BROWSE_UPDATE.HasRequest] == "true";

	local guildInfo = {};
	guildInfo[1] = guild[GF_BROWSE_UPDATE.Name];
	guildInfo[2] = tonumber(guild[GF_BROWSE_UPDATE.Level]) or 1;
	guildInfo[3] = tonumber(guild[GF_BROWSE_UPDATE.MemberCount]) or 1;
	guildInfo[4] = guild[GF_BROWSE_UPDATE.Comment];
	guildInfo[5] = requestPending;

	local tabardInfo = {strsplit(":", guild[GF_BROWSE_UPDATE.EmblemInfo])}
	for i = 1, 5 do
		guildInfo[#guildInfo + 1] = tonumber(tabardInfo[i]) or 0;
	end

	local interests = tonumber(guild[GF_BROWSE_UPDATE.Interests]) or 0;
	for index = 0, (NUM_LF_GUILD_INTERESTS_FLAGS - 1) do
		guildInfo[#guildInfo + 1] = bit.band(interests, bit.lshift(1, index)) ~= 0;
	end

	local availability = tonumber(guild[GF_BROWSE_UPDATE.Availability]) or 0;
	for index = 0, (NUM_LF_GUILD_AVAILABILITY_FLAGS - 1) do
		guildInfo[#guildInfo + 1] = bit.band(availability, bit.lshift(1, index)) ~= 0;
	end

	local classRoles = tonumber(guild[GF_BROWSE_UPDATE.ClassRoles]) or 0;
	for index = 0, (NUM_LF_GUILD_CLASS_ROLES_FLAGS - 1) do
		guildInfo[#guildInfo + 1] = bit.band(classRoles, bit.lshift(1, index)) ~= 0;
	end

	local activityTimes = tonumber(guild[GF_BROWSE_UPDATE.ActivityTimes]) or 0;
	for index = 0, (NUM_LF_GUILD_ACTIVITY_TIME_FLAGS - 1) do
		guildInfo[#guildInfo + 1] = bit.band(activityTimes, bit.lshift(1, index)) ~= 0;
	end

	guildInfo[30] = guildID;

	GUILD_MEMBERSHIP_REQUESTS[guildID] = requestPending;

	RECRUITING_GUILD_INFO[#RECRUITING_GUILD_INFO + 1] = guildInfo;

	if #RECRUITING_GUILD_INFO == NUM_RECRUITING_GUILDS then
		FireCustomClientEvent("LF_GUILD_BROWSE_UPDATED");
	end
end

function EventHandler:ASMSG_GF_MEMBERSHIP_LIST_UPDATED(msg)
	table.wipe(GUILD_MEMBERSHIP_REQUEST_INFO);

	local numApps, numAppsRemaining = strsplit("|", msg);

	NUM_GUILD_MEMBERSHIP_APPS = tonumber(numApps) or 0;
	NUM_GUILD_MEMBERSHIP_APPS_REMAINING = tonumber(numAppsRemaining) or 0;

	if NUM_GUILD_MEMBERSHIP_APPS == 0 then
		FireCustomClientEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED", NUM_GUILD_MEMBERSHIP_APPS_REMAINING);
	end
end

local GF_MEMBERSHIP_LIST_UPDATE = {
	GuildID = 1,
	Comment = 2,
	Name = 3,
	Availability = 4,
	TimeLeft = 5,
	ClassRoles = 6,
	TimeSince = 7,
	Interests = 8,
	ActivityTimes = 9,
	Level = 10,
	MemberCount = 11,
	GuildComment = 12,
	EmblemInfo = 13,
	HAS_INVITE = 14,
};

function EventHandler:ASMSG_GF_MEMBERSHIP_LIST_UPDATE(msg)
	local request = {strsplit("|", msg)};

	local requestInfo = {};
	requestInfo[1] = request[GF_MEMBERSHIP_LIST_UPDATE.Name];
	requestInfo[2] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.Level]) or 1;
	requestInfo[3] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.MemberCount]) or 1;
	requestInfo[4] = request[GF_MEMBERSHIP_LIST_UPDATE.GuildComment];
	requestInfo[5] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.TimeSince]) or 0;
	requestInfo[6] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.TimeLeft]) or 0;
	requestInfo[7] = false; -- declined
	requestInfo[8] = request[GF_MEMBERSHIP_LIST_UPDATE.HAS_INVITE] == "1"

	local interests = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.Interests]) or 0;
	for index = 0, (NUM_LF_GUILD_INTERESTS_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(interests, bit.lshift(1, index)) ~= 0;
	end

	local availability = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.Availability]) or 0;
	for index = 0, (NUM_LF_GUILD_AVAILABILITY_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(availability, bit.lshift(1, index)) ~= 0;
	end

	local classRoles = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.ClassRoles]) or 0;
	for index = 0, (NUM_LF_GUILD_CLASS_ROLES_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(classRoles, bit.lshift(1, index)) ~= 0;
	end

	local activityTimes = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.ActivityTimes]) or 0;
	for index = 0, (NUM_LF_GUILD_ACTIVITY_TIME_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(activityTimes, bit.lshift(1, index)) ~= 0;
	end

	local tabardInfo = {strsplit(":", request[GF_MEMBERSHIP_LIST_UPDATE.EmblemInfo])}
	for i = 1, 5 do
		requestInfo[#requestInfo + 1] = tonumber(tabardInfo[i]) or 0;
	end

	requestInfo[30] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.GuildID]);

	table.insert(GUILD_MEMBERSHIP_REQUEST_INFO, requestInfo);

	if #GUILD_MEMBERSHIP_REQUEST_INFO == NUM_GUILD_MEMBERSHIP_APPS then
		FireCustomClientEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED", NUM_GUILD_MEMBERSHIP_APPS_REMAINING);
	end
end

function EventHandler:ASMSG_GF_RECRUIT_LIST_UPDATED(msg)
	table.wipe(GUILD_APPLICANT_INFO);

	NUM_GUILD_APPLICANTS = tonumber(msg) or 0;

	if NUM_GUILD_APPLICANTS == 0 then
		FireCustomClientEvent("LF_GUILD_RECRUITS_UPDATED");
	end
end

local GF_RECRUIT_LIST_UPDATE = {
	Guid = 1,
	GameTime = 2,
	Level = 3,
	TimeSince = 4,
	Availability = 5,
	ClassRoles = 6,
	Interests = 7,
	TimeLeft = 8,
	Name = 9,
	Comment = 10,
	Class = 11,
	ActivityTimes = 12,
	Online = 13,
	InviteSent = 14,
};

function EventHandler:ASMSG_GF_RECRUIT_LIST_UPDATE(msg)
	local request = {strsplit("|", msg)};

	local requestInfo = {};
	requestInfo[1] = request[GF_RECRUIT_LIST_UPDATE.Name];
	requestInfo[2] = tonumber(request[GF_RECRUIT_LIST_UPDATE.Guid]);
	requestInfo[3] = tonumber(request[GF_RECRUIT_LIST_UPDATE.Level]) or 0;
	requestInfo[4] = select(2, GetClassInfo( tonumber(request[GF_RECRUIT_LIST_UPDATE.Class]) or 1 ));
	requestInfo[5] = tonumber(request[GF_RECRUIT_LIST_UPDATE.Online]) == 1;
	requestInfo[6] = tonumber(request[GF_RECRUIT_LIST_UPDATE.InviteSent]) == 1

	local interests = tonumber(request[GF_RECRUIT_LIST_UPDATE.Interests]) or 0;
	for index = 0, (NUM_LF_GUILD_INTERESTS_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(interests, bit.lshift(1, index)) ~= 0;
	end

	local availability = tonumber(request[GF_RECRUIT_LIST_UPDATE.Availability]) or 0;
	for index = 0, (NUM_LF_GUILD_AVAILABILITY_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(availability, bit.lshift(1, index)) ~= 0;
	end

	local classRoles = tonumber(request[GF_RECRUIT_LIST_UPDATE.ClassRoles]) or 0;
	for index = 0, (NUM_LF_GUILD_CLASS_ROLES_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(classRoles, bit.lshift(1, index)) ~= 0;
	end

	local activityTimes = tonumber(request[GF_RECRUIT_LIST_UPDATE.ActivityTimes]) or 0;
	for index = 0, (NUM_LF_GUILD_ACTIVITY_TIME_FLAGS - 1) do
		requestInfo[#requestInfo + 1] = bit.band(activityTimes, bit.lshift(1, index)) ~= 0;
	end

	requestInfo[21] = request[GF_RECRUIT_LIST_UPDATE.Comment];
	requestInfo[22] = tonumber(request[GF_RECRUIT_LIST_UPDATE.TimeSince]) or 0;
	requestInfo[23] = tonumber(request[GF_RECRUIT_LIST_UPDATE.TimeLeft]) or 0;

	GUILD_APPLICANT_INFO[#GUILD_APPLICANT_INFO + 1] = requestInfo;

	if #GUILD_APPLICANT_INFO == NUM_GUILD_APPLICANTS then
		FireCustomClientEvent("LF_GUILD_RECRUITS_UPDATED");
	end
end

local GF_POST_UPDATED = {
	IsGuildMaster = 1,
	IsListed = 2,
	Level = 3,
	Comment = 4,
	Availability = 5,
	ClassRoles = 6,
	Interests = 7,
	ActivityTimes = 8,
};

function EventHandler:ASMSG_GF_POST_UPDATED(msg)
	local settrings = {strsplit("|", msg)};

	local index = 0;
	local interests = tonumber(settrings[GF_POST_UPDATED.Interests]) or 0;
	for param = LFGUILD_PARAM_QUESTS, LFGUILD_PARAM_RP do
		GUILD_RECRUITMENT_SETTINGS[param] = bit.band(interests, bit.lshift(1, index)) ~= 0;
		index = index + 1;
	end

	index = 0;
	local availability = tonumber(settrings[GF_POST_UPDATED.Availability]) or 0;
	for param = LFGUILD_PARAM_WEEKDAYS, LFGUILD_PARAM_WEEKENDS do
		GUILD_RECRUITMENT_SETTINGS[param] = bit.band(availability, bit.lshift(1, index)) ~= 0;
		index = index + 1;
	end

	index = 0;
	local classRoles = tonumber(settrings[GF_POST_UPDATED.ClassRoles]) or 0;
	for param = LFGUILD_PARAM_TANK, LFGUILD_PARAM_DAMAGE do
		GUILD_RECRUITMENT_SETTINGS[param] = bit.band(classRoles, bit.lshift(1, index)) ~= 0;
		index = index + 1;
	end

	index = 0;
	local activityTimes = tonumber(settrings[GF_POST_UPDATED.ActivityTimes]) or 0;
	for param = LFGUILD_PARAM_MORNING, LFGUILD_PARAM_NIGHT do
		GUILD_RECRUITMENT_SETTINGS[param] = bit.band(activityTimes, bit.lshift(1, index)) ~= 0;
		index = index + 1;
	end

	GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_MAX_LEVEL] = settrings[GF_POST_UPDATED.Level] == "2";
	GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_ANY_LEVEL] = not GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_MAX_LEVEL];
	GUILD_RECRUITMENT_SETTINGS[LFGUILD_PARAM_LOOKING] = settrings[GF_POST_UPDATED.IsListed] == "1";
	GUILD_RECRUITMENT_SETTINGS[20] = settrings[GF_POST_UPDATED.Comment] or "";

	FireCustomClientEvent("LF_GUILD_POST_UPDATED");
end

function EventHandler:ASMSG_GF_APPLICANT_LIST_UPDATED(msg)
	FireCustomClientEvent("LF_GUILD_RECRUIT_LIST_CHANGED");
end

function EventHandler:ASMSG_GF_APPLICATIONS_LIST_CHANGED(msg)
	FireCustomClientEvent("LF_GUILD_MEMBERSHIP_LIST_CHANGED");
end

function UnitGetAvailableRoles(unit)
	if not unit or type(unit) ~= "string" then
		return false, false, false;
	end

	local _, class = UnitClass(unit);

	if class == "PALADIN" or class == "DRUID" then
		return true, true, true;
	elseif class == "WARRIOR" or class == "DEATHKNIGHT" then
		return true, false, true;
	elseif class == "PRIEST" or class == "SHAMAN" then
		return false, true, true;
	else
		return false, false, true;
	end
end