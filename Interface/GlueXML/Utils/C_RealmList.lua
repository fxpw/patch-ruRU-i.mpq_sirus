local MAX_REALM_ZONE = 37
local MAX_REALM_COUNT = 18

local REALM_SET = {}
local REALM_ARRAY = {}

C_RealmList = {}

function C_RealmList.GetMaxRealmZones()
	return MAX_REALM_ZONE
end

function C_RealmList.GetMaxRealmsPerZone()
	return MAX_REALM_COUNT
end

function C_RealmList.GetNumRealms()
	return #REALM_ARRAY
end

function C_RealmList.GetRealmInfo(realmIndex, ...)
	if not REALM_ARRAY[realmIndex] then return end
	return unpack(REALM_ARRAY[realmIndex])
end

function C_RealmList.GetRealmByName(realmName)
	if not REALM_SET[realmName] then return end
	return unpack(REALM_ARRAY[REALM_SET[realmName]])
end

function C_RealmList.RealmListUpdateRate()
	if IsDevClient(true) then
		return 1
	end
	return RealmListUpdateRate()
end

local function padNumber(x)
	return string.format("%03d", x)
end
local function sortRealms(a, b)
	return a[1]:lower():gsub("%d+", padNumber) < b[1]:lower():gsub("%d+", padNumber)
end

function C_RealmList.RequestRealmList(showDialog)
	RequestRealmList(showDialog)

	table.wipe(REALM_SET)
	table.wipe(REALM_ARRAY)

	for realmZone = 1, MAX_REALM_ZONE do
		local realmID = 1
		local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types = GetRealmInfo(realmZone, realmID)

		while name do
			if name and not REALM_SET[name] then
				REALM_ARRAY[#REALM_ARRAY + 1] = {name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types, realmZone, realmID}
				REALM_SET[name] = -1
			end

			realmID = realmID + 1
			name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types = GetRealmInfo(realmZone, realmID)
		end
	end

	table.sort(REALM_ARRAY, sortRealms)

	for realmIndex = 1, #REALM_ARRAY do
		REALM_SET[REALM_ARRAY[realmIndex][1]] = realmIndex
	end
end

function C_RealmList.CancelRealmListQuery()
	CancelRealmListQuery()
end

function C_RealmList.ChangeRealm(category, index)
	ChangeRealm(category, index)
end

function C_RealmList.RealmListDialogCancelled()
	RealmListDialogCancelled()
end

function C_RealmList.SortRealms(sortType)
	SortRealms(sortType)
end

function C_RealmList.GetSelectedCategory()
	return GetSelectedCategory()
end

function C_RealmList.GetRealmCategories()
	return GetRealmCategories()
end

function C_RealmList.IsInvalidLocale(category)
	return IsInvalidLocale(category)
end

function C_RealmList.IsTournamentRealmCategory(category)
	return IsTournamentRealmCategory(category)
end

function C_RealmList.IsInvalidTournamentRealmCategory(category)
	return IsInvalidTournamentRealmCategory(category)
end

function C_RealmList.SetPreferredInfo(index, pvp, rp)
	return SetPreferredInfo(index, pvp, rp)
end