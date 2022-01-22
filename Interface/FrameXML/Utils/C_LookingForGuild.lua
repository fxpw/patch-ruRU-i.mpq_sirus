local LF_GUILD_SETTINGS_FLAGS = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096};
local LF_GUILD_INTERESTS_FLAGS = {1, 2, 4, 8, 16};
local LF_GUILD_AVAILABILITY_FLAGS = {1, 2};
local LF_GUILD_CLASS_ROLES_FLAGS = {1, 2, 4};

local RECRUITING_GUILD_SELECTION;
local NUM_RECRUITING_GUILDS = 0;
local RECRUITING_GUILD_INFO = {};

local NUM_GUILD_MEMBERSHIP_APPS = 0;
local NUM_GUILD_MEMBERSHIP_APPS_REMAINING = 0;
local GUILD_MEMBERSHIP_REQUEST_INFO = {};

local GUILD_APPLICANT_SELECTION;
GUILD_RECRUITMENT_SETTINGS = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ""};

local NUM_GUILD_APPLICANTS = 0;
local GUILD_APPLICANT_INFO = {};

function SetGuildApplicantSelection(index)
	GUILD_APPLICANT_SELECTION = index;
end

function GetGuildApplicantSelection()
	return GUILD_APPLICANT_SELECTION;
end

local function SendGuildRecruitmentSettings()
	local interests, availability, classRoles, level = 0, 0, 0, 0;

	for i = 1, 5 do
		if GUILD_RECRUITMENT_SETTINGS[i] then
			interests = bit.bor(interests, LF_GUILD_INTERESTS_FLAGS[i]);
		end
	end

	for i = 6, 7 do
		if GUILD_RECRUITMENT_SETTINGS[i] then
			availability = bit.bor(availability, LF_GUILD_AVAILABILITY_FLAGS[i - 5]);
		end
	end

	for i = 8, 10 do
		if GUILD_RECRUITMENT_SETTINGS[i] then
			classRoles = bit.bor(classRoles, LF_GUILD_CLASS_ROLES_FLAGS[i - 7]);
		end
	end

	if interests > 0 and availability > 0 and classRoles > 0 then
		SendServerMessage("ACMSG_GF_SET_GUILD_POST", string.format("%d|%d|%d|%d|%d|%s", GUILD_RECRUITMENT_SETTINGS[12] and 2 or 1, classRoles, availability, interests, GUILD_RECRUITMENT_SETTINGS[13] and 1 or 0, GUILD_RECRUITMENT_SETTINGS[14]));
	end
end

function SetGuildRecruitmentSettings(index, bool)
	if type(index) ~= "number" or index < 1 or index > 13 then
		error("Usage: SetGuildRecruitmentSettings(index, true/false)", 2);
	end

	if index == 11 then
		GUILD_RECRUITMENT_SETTINGS[12] = not bool;
	elseif index == 12 then
		GUILD_RECRUITMENT_SETTINGS[11] = not bool;
	end

	GUILD_RECRUITMENT_SETTINGS[index] = bool;

	SendGuildRecruitmentSettings();
end

function GetGuildRecruitmentSettings()
	return unpack(GUILD_RECRUITMENT_SETTINGS, 1, 13);
end

function GetGuildRecruitmentComment()
	return GUILD_RECRUITMENT_SETTINGS[14] or "";
end

function SetGuildRecruitmentComment(text)
	GUILD_RECRUITMENT_SETTINGS[14] = text;

	SendGuildRecruitmentSettings();
end

function SetRecruitingGuildSelection(index)
	RECRUITING_GUILD_SELECTION = index;
end

function GetRecruitingGuildSelection()
	return RECRUITING_GUILD_SELECTION;
end

function SetLookingForGuildSettings(index, bool)
	if type(index) ~= "number" or index < 1 or index > 10 then
		error("Usage: SetLookingForGuildSettings(index, true/false)", 2);
	end

	local value = C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS");
	local flag = LF_GUILD_SETTINGS_FLAGS[index];

	if bool then
		C_CVar:SetValue("C_CVAR_FL_GUILD_SETTINGS", bit.bor(value, flag));
	else
		C_CVar:SetValue("C_CVAR_FL_GUILD_SETTINGS", bit.band(value, bit.bnot(flag)));
	end
end

function GetLookingForGuildSettings()
	local value = C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS");

	return bit.band(value, LF_GUILD_SETTINGS_FLAGS[1]) == LF_GUILD_SETTINGS_FLAGS[1],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[2]) == LF_GUILD_SETTINGS_FLAGS[2],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[3]) == LF_GUILD_SETTINGS_FLAGS[3],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[4]) == LF_GUILD_SETTINGS_FLAGS[4],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[5]) == LF_GUILD_SETTINGS_FLAGS[5],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[6]) == LF_GUILD_SETTINGS_FLAGS[6],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[7]) == LF_GUILD_SETTINGS_FLAGS[7],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[8]) == LF_GUILD_SETTINGS_FLAGS[8],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[9]) == LF_GUILD_SETTINGS_FLAGS[9],
	bit.band(value, LF_GUILD_SETTINGS_FLAGS[10]) == LF_GUILD_SETTINGS_FLAGS[10];
end

function SetLookingForGuildComment(text)
	C_CVar:SetValue("C_CVAR_FL_GUILD_COMMENT", text);
end

function GetLookingForGuildComment()
	return C_CVar:GetValue("C_CVAR_FL_GUILD_COMMENT");
end

function CancelGuildMembershipRequest(index)
	if type(index) == "number" and GUILD_MEMBERSHIP_REQUEST_INFO[index] and GUILD_MEMBERSHIP_REQUEST_INFO[index][15] then
		SendServerMessage("ACMSG_GF_REMOVE_RECRUIT", GUILD_MEMBERSHIP_REQUEST_INFO[index][15]);
	end
end

function DeclineGuildApplicant(index)
	if type(index) == "number" and GUILD_APPLICANT_INFO[index] and GUILD_APPLICANT_INFO[index][17] then
		SendServerMessage("ACMSG_GF_DECLINE_RECRUIT", GUILD_APPLICANT_INFO[index][17]);

		GUILD_APPLICANT_SELECTION = nil;
	end
end

function GetGuildApplicantInfo(index)
	return unpack(GUILD_APPLICANT_INFO[index] or {}, 1, 17);
end

function GetGuildMembershipRequestInfo(index)
	return unpack(GUILD_MEMBERSHIP_REQUEST_INFO[index] or {}, 1, 4);
end

function GetGuildMembershipRequestSettings(index)
	return unpack(GUILD_MEMBERSHIP_REQUEST_INFO[index] or {}, 5, 14);
end

function GetNumGuildApplicants()
	return NUM_GUILD_APPLICANTS;
end

function GetNumGuildMembershipRequests()
	return NUM_GUILD_MEMBERSHIP_APPS, NUM_GUILD_MEMBERSHIP_APPS_REMAINING;
end

function GetNumRecruitingGuilds()
	return NUM_RECRUITING_GUILDS;
end

function GetRecruitingGuildInfo(index)
	return unpack(RECRUITING_GUILD_INFO[index] or {}, 1, 5);
end

function GetRecruitingGuildTabardInfo(index)
	return unpack(RECRUITING_GUILD_INFO[index] or {}, 6, 10);
end

function GetRecruitingGuildSettings(index)
	return unpack(RECRUITING_GUILD_INFO[index] or {}, 11, 20);
end

function RequestGuildApplicantsList()
	SendServerMessage("ACMSG_GF_GET_RECRUITS", "");
end

function RequestGuildMembershipList()
	SendServerMessage("ACMSG_GF_GET_APPLICATIONS", "");
end

function RequestGuildMembership(index, text)
	if type(index) == "number" and RECRUITING_GUILD_INFO[index] and RECRUITING_GUILD_INFO[index][21] then
		local value = C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS");

		local interests, availability, classRoles = 0, 0, 0;

		for i = 1, 5 do
			if bit.band(value, LF_GUILD_SETTINGS_FLAGS[i]) ~= 0 then
				interests = bit.bor(interests, LF_GUILD_INTERESTS_FLAGS[i]);
			end
		end

		for i = 6, 7 do
			if bit.band(value, LF_GUILD_SETTINGS_FLAGS[i]) ~= 0 then
				availability = bit.bor(availability, LF_GUILD_AVAILABILITY_FLAGS[i - 5]);
			end
		end

		for i = 8, 10 do
			if bit.band(value, LF_GUILD_SETTINGS_FLAGS[i]) ~= 0 then
				classRoles = bit.bor(classRoles, LF_GUILD_CLASS_ROLES_FLAGS[i - 7]);
			end
		end

		SendServerMessage("ACMSG_GF_ADD_RECRUIT", string.format("%d|%d|%d|%d|%s", classRoles, interests, availability, RECRUITING_GUILD_INFO[index][21], text));

		RECRUITING_GUILD_INFO[index][5] = true;
	end
end

function RequestGuildRecruitmentSettings()
	SendServerMessage("ACMSG_GF_POST_REQUEST", "");
end

function RequestRecruitingGuildsList()
	local value = C_CVar:GetValue("C_CVAR_FL_GUILD_SETTINGS");

	local interests, availability, classRoles = 0, 0, 0;

	for i = 1, 5 do
		if bit.band(value, LF_GUILD_SETTINGS_FLAGS[i]) ~= 0 then
			interests = bit.bor(interests, LF_GUILD_INTERESTS_FLAGS[i]);
		end
	end

	for i = 6, 7 do
		if bit.band(value, LF_GUILD_SETTINGS_FLAGS[i]) ~= 0 then
			availability = bit.bor(availability, LF_GUILD_AVAILABILITY_FLAGS[i - 5]);
		end
	end

	for i = 8, 10 do
		if bit.band(value, LF_GUILD_SETTINGS_FLAGS[i]) ~= 0 then
			classRoles = bit.bor(classRoles, LF_GUILD_CLASS_ROLES_FLAGS[i - 7]);
		end
	end

	SendServerMessage("ACMSG_GF_BROWSE", string.format("%s|%s|%s", classRoles, availability, interests));
end

function EventHandler:ASMSG_GF_BROWSE_UPDATED(msg)
	table.wipe(RECRUITING_GUILD_INFO);

	NUM_RECRUITING_GUILDS = tonumber(msg) or 0;

	if NUM_RECRUITING_GUILDS == 0 then
		LookingForGuild_Update();
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
};

function EventHandler:ASMSG_GF_BROWSE_UPDATE(msg)
	local guild = {strsplit("|", msg)};

	local guildInfo = {};
	guildInfo[1] = guild[GF_BROWSE_UPDATE.Name];
	guildInfo[2] = tonumber(guild[GF_BROWSE_UPDATE.Level]) or 1;
	guildInfo[3] = tonumber(guild[GF_BROWSE_UPDATE.MemberCount]) or 1;
	guildInfo[4] = guild[GF_BROWSE_UPDATE.Comment];
	guildInfo[5] = guild[GF_BROWSE_UPDATE.HasRequest] == "true";

	local tabardInfo = {strsplit(":", guild[GF_BROWSE_UPDATE.EmblemInfo])}
	for i = 1, 5 do
		guildInfo[#guildInfo + 1] = tonumber(tabardInfo[i]) or 0;
	end

	local interests = tonumber(guild[GF_BROWSE_UPDATE.Interests]) or 0;
	for _, mask in ipairs(LF_GUILD_INTERESTS_FLAGS) do
		guildInfo[#guildInfo + 1] = bit.band(interests, mask) == mask;
	end

	local availability = tonumber(guild[GF_BROWSE_UPDATE.Availability]) or 0;
	for _, mask in ipairs(LF_GUILD_AVAILABILITY_FLAGS) do
		guildInfo[#guildInfo + 1] = bit.band(availability, mask) == mask;
	end

	local classRoles = tonumber(guild[GF_BROWSE_UPDATE.ClassRoles]) or 0;
	for _, mask in ipairs(LF_GUILD_CLASS_ROLES_FLAGS) do
		guildInfo[#guildInfo + 1] = bit.band(classRoles, mask) == mask;
	end

	guildInfo[21] = tonumber(guild[GF_BROWSE_UPDATE.GuildID]);

	RECRUITING_GUILD_INFO[#RECRUITING_GUILD_INFO + 1] = guildInfo;

	if #RECRUITING_GUILD_INFO == NUM_RECRUITING_GUILDS then
		LookingForGuild_Update();
	end
end

function EventHandler:ASMSG_GF_MEMBERSHIP_LIST_UPDATED(msg)
	table.wipe(GUILD_MEMBERSHIP_REQUEST_INFO);

	local numApps, numAppsRemaining = strsplit("|", msg);

	NUM_GUILD_MEMBERSHIP_APPS = tonumber(numApps) or 0;
	NUM_GUILD_MEMBERSHIP_APPS_REMAINING = tonumber(numAppsRemaining) or 0;

	if NUM_GUILD_MEMBERSHIP_APPS == 0 then
		LookingForGuildFrame_OnEvent(nil, "LF_GUILD_MEMBERSHIP_LIST_UPDATED", NUM_GUILD_MEMBERSHIP_APPS_REMAINING);
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
};

function EventHandler:ASMSG_GF_MEMBERSHIP_LIST_UPDATE(msg)
	local request = {strsplit("|", msg)};

	local requestInfo = {};
	requestInfo[1] = request[GF_MEMBERSHIP_LIST_UPDATE.Name];
	requestInfo[2] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.TimeSince]) or 0;
	requestInfo[3] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.TimeLeft]) or 0;
	requestInfo[4] = false; -- declined

	local interests = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.Interests]) or 0;
	for _, mask in ipairs(LF_GUILD_INTERESTS_FLAGS) do
		requestInfo[#requestInfo + 1] = bit.band(interests, mask) == mask;
	end

	local availability = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.Availability]) or 0;
	for _, mask in ipairs(LF_GUILD_AVAILABILITY_FLAGS) do
		requestInfo[#requestInfo + 1] = bit.band(availability, mask) == mask;
	end

	local classRoles = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.ClassRoles]) or 0;
	for _, mask in ipairs(LF_GUILD_CLASS_ROLES_FLAGS) do
		requestInfo[#requestInfo + 1] = bit.band(classRoles, mask) == mask;
	end

	requestInfo[15] = tonumber(request[GF_MEMBERSHIP_LIST_UPDATE.GuildID]);

	GUILD_MEMBERSHIP_REQUEST_INFO[#GUILD_MEMBERSHIP_REQUEST_INFO + 1] = requestInfo;

	if #GUILD_MEMBERSHIP_REQUEST_INFO == NUM_GUILD_MEMBERSHIP_APPS then
		LookingForGuildFrame_OnEvent(nil, "LF_GUILD_MEMBERSHIP_LIST_UPDATED", NUM_GUILD_MEMBERSHIP_APPS_REMAINING);
	end
end

function EventHandler:ASMSG_GF_RECRUIT_LIST_UPDATED(msg)
	table.wipe(GUILD_APPLICANT_INFO);

	NUM_GUILD_APPLICANTS = tonumber(msg) or 0;

	if NUM_GUILD_APPLICANTS == 0 then
		GuildInfoFrameApplicants_Update();
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
};

function EventHandler:ASMSG_GF_RECRUIT_LIST_UPDATE(msg)
	local request = {strsplit("|", msg)};

	local requestInfo = {};
	requestInfo[1] = request[GF_RECRUIT_LIST_UPDATE.Name];
	requestInfo[2] = tonumber(request[GF_RECRUIT_LIST_UPDATE.Level]) or 0;
	requestInfo[3] = select(2, GetClassInfo( tonumber(request[GF_RECRUIT_LIST_UPDATE.Class]) or 1 ));

	local interests = tonumber(request[GF_RECRUIT_LIST_UPDATE.Interests]) or 0;
	for _, mask in ipairs(LF_GUILD_INTERESTS_FLAGS) do
		requestInfo[#requestInfo + 1] = bit.band(interests, mask) == mask;
	end

	local availability = tonumber(request[GF_RECRUIT_LIST_UPDATE.Availability]) or 0;
	for _, mask in ipairs(LF_GUILD_AVAILABILITY_FLAGS) do
		requestInfo[#requestInfo + 1] = bit.band(availability, mask) == mask;
	end

	local classRoles = tonumber(request[GF_RECRUIT_LIST_UPDATE.ClassRoles]) or 0;
	for _, mask in ipairs(LF_GUILD_CLASS_ROLES_FLAGS) do
		requestInfo[#requestInfo + 1] = bit.band(classRoles, mask) == mask;
	end

	requestInfo[14] = request[GF_RECRUIT_LIST_UPDATE.Comment];
	requestInfo[15] = tonumber(request[GF_RECRUIT_LIST_UPDATE.TimeSince]) or 0;
	requestInfo[16] = tonumber(request[GF_RECRUIT_LIST_UPDATE.TimeLeft]) or 0;
	requestInfo[17] = tonumber(request[GF_RECRUIT_LIST_UPDATE.Guid]);

	GUILD_APPLICANT_INFO[#GUILD_APPLICANT_INFO + 1] = requestInfo;

	if #GUILD_APPLICANT_INFO == NUM_GUILD_APPLICANTS then
		GuildInfoFrameApplicants_Update();
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
};

function EventHandler:ASMSG_GF_POST_UPDATED(msg)
	local settrings = {strsplit("|", msg)};

	local index = 1;
	local interests = tonumber(settrings[GF_POST_UPDATED.Interests]) or 0;
	for _, mask in ipairs(LF_GUILD_INTERESTS_FLAGS) do
		GUILD_RECRUITMENT_SETTINGS[index] = bit.band(interests, mask) == mask;
		index = index + 1;
	end

	local availability = tonumber(settrings[GF_POST_UPDATED.Availability]) or 0;
	for _, mask in ipairs(LF_GUILD_AVAILABILITY_FLAGS) do
		GUILD_RECRUITMENT_SETTINGS[index] = bit.band(availability, mask) == mask;
		index = index + 1;
	end

	local classRoles = tonumber(settrings[GF_POST_UPDATED.ClassRoles]) or 0;
	for _, mask in ipairs(LF_GUILD_CLASS_ROLES_FLAGS) do
		GUILD_RECRUITMENT_SETTINGS[index] = bit.band(classRoles, mask) == mask;
		index = index + 1;
	end

	GUILD_RECRUITMENT_SETTINGS[12] = settrings[GF_POST_UPDATED.Level] == "2";
	GUILD_RECRUITMENT_SETTINGS[11] = not GUILD_RECRUITMENT_SETTINGS[12];
	GUILD_RECRUITMENT_SETTINGS[13] = settrings[GF_POST_UPDATED.IsListed] == "1";
	GUILD_RECRUITMENT_SETTINGS[14] = settrings[GF_POST_UPDATED.Comment] or "";

	GuildInfoFrame_OnEvent(nil, "LF_GUILD_POST_UPDATED");
end

function EventHandler:ASMSG_GF_APPLICANT_LIST_UPDATED(msg)
	RequestGuildApplicantsList();

	if GuildFrame and GuildMicroButton and not GuildFrame:IsShown() then
		MicroButtonPulse(GuildMicroButton);
	end
end

function EventHandler:ASMSG_GF_APPLICATIONS_LIST_CHANGED(msg)
	RequestGuildMembershipList();

	if LookingForGuildFrame and GuildMicroButton and not LookingForGuildFrame:IsShown() then
		MicroButtonPulse(GuildMicroButton);
	end
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