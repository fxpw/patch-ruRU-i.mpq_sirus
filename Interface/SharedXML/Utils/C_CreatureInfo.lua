C_CreatureInfo = {}

function C_CreatureInfo.GetClassInfo(class)
	if not class then
		error(string.format("Usage: C_CreatureInfo.GetClassInfo(classID|className)", class), 2)
	end
	local classData = S_CLASS_SORT_ORDER[class] or S_CLASS_DATA_LOCALIZATION_ASSOC[class]
	if not classData then
		error(string.format("C_CreatureInfo.GetClassInfo: No class info was found for '%s'", class), 2)
	end

	local ClassInfo = {}

	ClassInfo.classFile 	= classData[2]
	ClassInfo.className 	= classData[4]
	ClassInfo.classID 		= classData[3]
	ClassInfo.classFlag 	= classData[1]
	ClassInfo.localizeName 	= {
		male = classData[4],
		female = classData[5]
	}

	return ClassInfo
end

function C_CreatureInfo.GetFactionInfo(race)
	if type(race) ~= "number" and type(race) ~= "string" then
		error(string.format("Usage: C_CreatureInfo.GetFactionInfo(raceID|raceName)", race), 2)
	end

	if race == RACE_NAGA and IsOnGlueScreen() then
		race = E_CHARACTER_RACES.RACE_NAGA
	end

	local raceData = S_CHARACTER_RACES_INFO[race] or S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC[race]
	if not raceData then
		raceData = S_CHARACTER_RACES_INFO[E_CHARACTER_RACES.RACE_HUMAN]
	end

	local FactionInfo = {}
	local factionTag  = PLAYER_FACTION_GROUP[raceData.factionID]

	FactionInfo.name 		= _G["FACTION_"..string.upper(factionTag)]
	FactionInfo.groupTag 	= factionTag
	FactionInfo.factionID 	= raceData.factionID

	return FactionInfo
end

function C_CreatureInfo.GetRaceInfo(race)
	if type(race) ~= "number" and type(race) ~= "string" then
		error(string.format("Usage: C_CreatureInfo.GetRaceInfo(raceID|raceName)", race), 2)
	end

	if race == RACE_NAGA and IsOnGlueScreen() then
		race = E_CHARACTER_RACES.RACE_NAGA
	end

	local raceData = S_CHARACTER_RACES_INFO[race] or S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC[race]
	if not raceData then
		raceData = S_CHARACTER_RACES_INFO[E_CHARACTER_RACES.RACE_HUMAN]
	end

	local RaceInfo  = {}

	RaceInfo.raceName 			= _G[raceData.raceName]
	RaceInfo.clientFileString 	= raceData.clientFileString
	RaceInfo.raceID 			= raceData.raceID
	RaceInfo.localizeName 		= {
		male = _G[raceData.raceName],
		female = _G[raceData.raceNameFemale]
	}

	return RaceInfo
end