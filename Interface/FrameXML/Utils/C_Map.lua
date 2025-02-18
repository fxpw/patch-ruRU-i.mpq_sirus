local select = select
local type = type
local unpack = unpack
local tinsert, twipe = table.insert, table.wipe

local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetCurrentMapContinent = GetCurrentMapContinent
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local GetCurrentMapZone = GetCurrentMapZone
local GetMapZones = GetMapZones
local GetMapContinents = GetMapContinents
local GetMapLandmarkInfo = GetMapLandmarkInfo
local GetNumMapLandmarks = GetNumMapLandmarks
local ProcessMapClick = ProcessMapClick
local SetMapByID = SetMapByID
local SetMapZoom = SetMapZoom
local UpdateMapHighlight = UpdateMapHighlight
local ZoomOut = ZoomOut

local GetServerID = GetServerID
local IsGMAccount = IsGMAccount

local WORLDMAP_MAP_NAME_BY_ID = WORLDMAP_MAP_NAME_BY_ID

local WORLDMAP_HIDDEN_CONTININT_ID = -2
local WORLDMAP_COSMIC_ID = -1
local WORLDMAP_WORLD_ID = 0
local WORLDMAP_KALIMDOR_ID = 1
local WORLDMAP_EASTERN_KINGDOMS_ID = 2
local WORLDMAP_OUTLAND_ID = 3

local MAP_DATA_INDEX = {
	PARENT_WORLD_MAP_ID = 1,
	AREA_NAME_ENGB = 2,
	AREA_NAME_RURU = 3,
}

local HIDDEN_CONTINENTS = {
	[FORBES_ISLAND] = true,
	[NORDERON] = true,
	[GILNEAS] = true,
	[EXILES_REACH] = true,
	[DEEPWIND_GORGE] = true,
	[ASHRAN] = true,
	[SEETHING_SHORE] = true,
	[WARSONG_GULCH] = true,
	[ARATHI_BASIN] = true,
	[EXILES_REACH_SHIP_ALLIANCE] = true,
	[EXILES_REACH_SHIP_HORDE] = true,
}

local HIDDEN_ZONES = {
--[[
	[EASTERN_KINGDOMS] = {
		[NORDERON] = true,
		[GILNEAS] = true,
	},
--]]
}

local CONTINENT_MAP_OVERRIDE = {
--	[KALIMDOR]			= 0,
--	[EASTERN_KINGDOMS]	= 0,
--	[OUTLAND]			= 0,
--	[NORTHREND]			= 0,
	[FORBES_ISLAND]		= 906,
--	[FELYARD]			= 0,
	[NORDERON]			= 953,
	[GILNEAS]			= 955,
	[LOST_ISLAND]		= 897,
	[RISING_DEPTHS]		= 899,
	[MANGROVE_ISLAND]	= 907,
	[TELABIM]			= 971,
	[TOLGAROD]			= 945,
	[ANDRAKKIS]			= 963,
}

local ZONE_MAP_OVERRIDE = {
	[EASTERN_KINGDOMS] = {
		[NORDERON] = 953,
		[GILNEAS] = 955,
	},
}

local MAP_ZOOMOUT_OVERRIDE = {
	[953] = 14,
	[977] = 953,
	[955] = 14,
	[908] = 955,
	[982] = 485,
}

local MAP_LEVELS = {
	["SilvermoonCity"] = {1, 80},
	["EversongWoods"] = {1, 10},
	["Ghostlands"] = {10, 20},
	["EasternPlaguelands"] = {53, 60},
	["WesternPlaguelands"] = {51, 58},
	["Tirisfal"] = {1, 10},
	["Silverpine"] = {10, 20},
	["Alterac"] = {30, 40},
	["Hinterlands"] = {45, 50},
	["Hilsbrad"] = {20, 30},
	["Arathi"] = {30, 40},
	["Wetlands"] = {20, 30},
	["DunMorogh"] = {1, 10},
	["Ironforge"] = {1, 80},
	["LochModan"] = {10, 20},
	["SearingGorge"] = {43, 50},
	["Badlands"] = {35, 45},
	["BurningSteppes"] = {50, 58},
	["Elwynn"] = {1, 10},
	["Redridge"] = {15, 25},
	["Westfall"] = {10, 20},
	["Duskwood"] = {18, 30},
	["DeadwindPass"] = {55, 60},
	["SwampOfSorrows"] = {35, 45},
	["Stranglethorn"] = {30, 45},
	["BlastedLands"] = {45, 55},
	["Teldrassil"] = {1, 10},
	["Darnassis"] = {1, 80},
	["BloodmystIsle"] = {10, 20},
	["AzuremystIsle"] = {1, 10},
	["TheExodar"] = {1, 80},
	["Darkshore"] = {10, 20},
	["Winterspring"] = {53, 60},
	["Felwood"] = {48, 55},
	["Ashenvale"] = {18, 30},
	["Aszhara"] = {48, 55},
	["StonetalonMountains"] = {15, 27},
	["Barrens"] = {10, 25},
	["Durotar"] = {1, 10},
	["Mulgore"] = {1, 10},
	["ThunderBluff"] = {1, 80},
	["Feralas"] = {40, 50},
	["Dustwallow"] = {35, 45},
	["ThousandNeedles"] = {25, 35},
	["Silithus"] = {55, 60},
	["UngoroCrater"] = {48, 55},
	["Tanaris"] = {40, 50},
	["Netherstorm"] = {67, 70},
	["BladesEdgeMountains"] = {65, 68},
	["Zangarmarsh"] = {60, 64},
	["Hellfire"] = {58, 63},
	["Nagrand"] = {64, 67},
	["TerokkarForest"] = {62, 65},
	["ShattrathCity"] = {8, 80},
	["ShadowmoonValley"] = {67, 70},
	["BoreanTundra"] = {68, 72},
	["Dragonblight"] = {71, 74},
	["HowlingFjord"] = {68, 72},
	["GrizzlyHills"] = {73, 75},
	["SholazarBasin"] = {76, 78},
	["LakeWintergrasp"] = {77, 80},
	["ZulDrak"] = {74, 77},
	["CrystalsongForest"] = {74, 76},
	["TheStormPeaks"] = {77, 80},
	["IcecrownGlacier"] = {77, 80},
	["ClassicMountHyjal"] = {1, 10},
	["Desolace"] = {30, 40},
	["Moonglade"] = {55, 60}
}

local PRIVATE = {
	AREA_NAME_LOCALE = string.format("AREA_NAME_%s", GetLocale():upper()),

	CONTINENTS_REAL = {},
	CONTINENTS_MAPPED_ARRAY = {},
	CONTINENTS_MAPPED_MAP = {},
	CONTINENTS_MAPPED_MAP_REVERSE = {},
	REMAP_CONTINENT_DONE = false,

	ZONES_REAL = {},
	ZONES_MAPPED_ARRAY = {},
	ZONES_MAPPED_MAP = {},
	ZONES_MAPPED_MAP_REVERSE = {},
	REMAP_ZONE_DONE = {},

	MAP_LANDMARKS = {},
	MAP_LANDMARKS_AREA_ID = nil,
}

PRIVATE.eventHandler = CreateFrame("Frame")
PRIVATE.eventHandler:RegisterEvent("WORLD_MAP_UPDATE")
PRIVATE.eventHandler:Hide()
PRIVATE.eventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "WORLD_MAP_UPDATE" then
		PRIVATE.MAP_LANDMARKS_DIRTY = true
	end
end)


PRIVATE.CreateOrWipeTable = function(t, k)
	if t[k] then
		twipe(t[k])
	else
		t[k] = {}
	end
end

PRIVATE.GetAreaNameByID = function(mapAreaID)
	if not mapAreaID then
		mapAreaID = PRIVATE.GetCurrentMapAreaID()
	end
	return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][MAP_DATA_INDEX[PRIVATE.AREA_NAME_LOCALE]]
end

PRIVATE.GetParentMapID = function(mapAreaID)
	if not mapAreaID then
		mapAreaID = PRIVATE.GetCurrentMapAreaID()
	end
	return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][MAP_DATA_INDEX.PARENT_WORLD_MAP_ID]
end

PRIVATE.RemapContinents = function(...)
	local isGM = IsGMAccount()

	twipe(PRIVATE.CONTINENTS_REAL)
	twipe(PRIVATE.CONTINENTS_MAPPED_ARRAY)
	twipe(PRIVATE.CONTINENTS_MAPPED_MAP)
	twipe(PRIVATE.CONTINENTS_MAPPED_MAP_REVERSE)

	local newIndex = 0
	for index = 1, select("#", ...) do
		local name = select(index, ...)

		PRIVATE.CONTINENTS_REAL[index] = name
		PRIVATE.CONTINENTS_REAL[name] = index

		if not HIDDEN_CONTINENTS[name] or isGM then
			newIndex = newIndex + 1
			if HIDDEN_CONTINENTS[name] then
				name = string.format("%s (|cff00FF00GM|r)", name)
			end
			PRIVATE.CONTINENTS_MAPPED_ARRAY[newIndex] = name
			PRIVATE.CONTINENTS_MAPPED_MAP[index] = newIndex
			PRIVATE.CONTINENTS_MAPPED_MAP_REVERSE[newIndex] = index
		end
	end
end

PRIVATE.RemapZones = function(continentIndex, ...)
	local isGM = IsGMAccount()

	PRIVATE.CreateOrWipeTable(PRIVATE.ZONES_REAL, continentIndex)
	PRIVATE.CreateOrWipeTable(PRIVATE.ZONES_MAPPED_ARRAY, continentIndex)
	PRIVATE.CreateOrWipeTable(PRIVATE.ZONES_MAPPED_MAP, continentIndex)
	PRIVATE.CreateOrWipeTable(PRIVATE.ZONES_MAPPED_MAP_REVERSE, continentIndex)

	local newIndex = 0
	for index = 1, select("#", ...) do
		local name = select(index, ...) or ("NONAME"..index)

		PRIVATE.ZONES_REAL[continentIndex][index] = name
		PRIVATE.ZONES_REAL[continentIndex][name] = index

		local continentName = PRIVATE.CONTINENTS_REAL[continentIndex]

		if not HIDDEN_ZONES[continentName] or not HIDDEN_ZONES[continentName][name] or isGM then
			newIndex = newIndex + 1
			if HIDDEN_ZONES[continentName] and HIDDEN_ZONES[continentName][name] then
				name = string.format("%s (|cff00FF00GM|r)", name)
			end
			PRIVATE.ZONES_MAPPED_ARRAY[continentIndex][newIndex] = name
			PRIVATE.ZONES_MAPPED_MAP[continentIndex][index] = newIndex
			PRIVATE.ZONES_MAPPED_MAP_REVERSE[continentIndex][newIndex] = index
		end
	end
end

PRIVATE.UpdateContinents = function()
	if PRIVATE.REMAP_CONTINENT_DONE then return end
	PRIVATE.RemapContinents(GetMapContinents())
	PRIVATE.REMAP_CONTINENT_DONE = true
end

PRIVATE.UpdateZones = function(continentIndex)
	if PRIVATE.REMAP_ZONE_DONE[continentIndex] then return end
	PRIVATE.UpdateContinents()
	PRIVATE.RemapZones(continentIndex, GetMapZones(continentIndex))
	PRIVATE.REMAP_ZONE_DONE[continentIndex] = true
end

PRIVATE.GetAdjustedContinentIndex = function(continentIndex)
	PRIVATE.UpdateContinents()
	return PRIVATE.CONTINENTS_MAPPED_MAP[continentIndex] or continentIndex
end

PRIVATE.GetAdjustedZoneIndex = function(continentIndex, zoneIndex)
	PRIVATE.UpdateZones(continentIndex)
	continentIndex = PRIVATE.GetAdjustedContinentIndex(continentIndex)
	if PRIVATE.ZONES_MAPPED_MAP[continentIndex] then
		return PRIVATE.ZONES_MAPPED_MAP[continentIndex][zoneIndex] or zoneIndex
	end
	return zoneIndex
end

PRIVATE.GetCurrentMapAreaID = function()
	local currentMapAreaID = GetCurrentMapAreaID()
	if currentMapAreaID and currentMapAreaID > 0 then
		return currentMapAreaID - 1
	else
		return 0
	end
end

function ReloadWorldMapData()
	WORLDMAP_MAP_NAME_BY_ID = _G.WORLDMAP_MAP_NAME_BY_ID
end

_G.UpdateMapHighlight = function(x, y)
	local name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY = UpdateMapHighlight(x, y)
	local minLevel, maxLevel
	if fileName and MAP_LEVELS[fileName] then
		minLevel, maxLevel = unpack(MAP_LEVELS[fileName], 1, 2)
	end
	return name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY, minLevel or 0, maxLevel or 0
end

_G.ProcessMapClick = function(x, y)
	local name = UpdateMapHighlight(x, y)
	if CONTINENT_MAP_OVERRIDE[name] and CONTINENT_MAP_OVERRIDE[name] ~= 0 then
		SetMapByID(CONTINENT_MAP_OVERRIDE[name])
		return
	end
	ProcessMapClick(x, y)
end

_G.GetMapContinents = function()
	PRIVATE.UpdateContinents()
	return unpack(PRIVATE.CONTINENTS_MAPPED_ARRAY)
end

_G.GetCurrentMapContinent = function()
	PRIVATE.UpdateContinents()
	local index = GetCurrentMapContinent()
	if HIDDEN_CONTINENTS[PRIVATE.CONTINENTS_REAL[index]] then
		return WORLDMAP_HIDDEN_CONTININT_ID
	end
	return PRIVATE.GetAdjustedContinentIndex(index)
end

_G.GetCurrentMapZone = function()
	local realContinentIndex = GetCurrentMapContinent()
	PRIVATE.UpdateZones(realContinentIndex)
	local zoneIndex = GetCurrentMapZone(realContinentIndex)
	local hiddenZones = HIDDEN_ZONES[PRIVATE.CONTINENTS_REAL[realContinentIndex]]
	if hiddenZones and hiddenZones[PRIVATE.ZONES_REAL[zoneIndex]] then
		return WORLDMAP_HIDDEN_CONTININT_ID
	end
	return PRIVATE.GetAdjustedZoneIndex(realContinentIndex, zoneIndex)
end

_G.GetMapZones = function(continentIndex)
	if continentIndex == WORLDMAP_HIDDEN_CONTININT_ID then
		local realContinentIndex = GetCurrentMapContinent()
		if HIDDEN_CONTINENTS[PRIVATE.CONTINENTS_REAL[realContinentIndex]] then
			continentIndex = realContinentIndex
		end
	elseif type(continentIndex) == "number" and continentIndex > 0 then
		local realContinentIndex = PRIVATE.GetRealContinentIndex(continentIndex)
		PRIVATE.UpdateZones(realContinentIndex)
		return unpack(PRIVATE.ZONES_MAPPED_ARRAY[realContinentIndex])
	end

	return GetMapZones(continentIndex)
end

PRIVATE.GetRealContinentIndex = function(continentIndex)
	if continentIndex == WORLDMAP_HIDDEN_CONTININT_ID then
		return GetCurrentMapContinent()
	elseif continentIndex > 0 then
		return PRIVATE.CONTINENTS_MAPPED_MAP_REVERSE[continentIndex]
	end
	return continentIndex
end

_G.SetMapZoom = function(continentIndex, zoneIndex)
	if type(continentIndex) == "number" then
		PRIVATE.UpdateContinents()

		if type(zoneIndex) == "number" then
			local realContinentIndex = PRIVATE.GetRealContinentIndex(continentIndex)
			PRIVATE.UpdateZones(realContinentIndex)

			if zoneIndex > 0 and PRIVATE.ZONES_MAPPED_MAP_REVERSE[realContinentIndex] then
				local realZoneIndex = PRIVATE.ZONES_MAPPED_MAP_REVERSE[realContinentIndex][zoneIndex]

				local continentName = PRIVATE.CONTINENTS_REAL[realContinentIndex]
				if ZONE_MAP_OVERRIDE[continentName] then
					local zoneName = PRIVATE.ZONES_REAL[realContinentIndex][realZoneIndex]
					if ZONE_MAP_OVERRIDE[continentName][zoneName] then
						SetMapByID(ZONE_MAP_OVERRIDE[continentName][zoneName])
						return
					end
				end

				zoneIndex = realZoneIndex
			end

			continentIndex = realContinentIndex
		else
			local currentRealContinentIndex = GetCurrentMapContinent()
			local currentContinentIndex = PRIVATE.GetAdjustedContinentIndex(currentRealContinentIndex)

			local zoomOut = --[[not zoneIndex and]] continentIndex == currentContinentIndex or continentIndex == WORLDMAP_HIDDEN_CONTININT_ID
			if zoomOut then
				local continentName = PRIVATE.CONTINENTS_REAL[currentRealContinentIndex]
				if CONTINENT_MAP_OVERRIDE[continentName] then
					local mapAreaID = PRIVATE.GetCurrentMapAreaID()
					if MAP_ZOOMOUT_OVERRIDE[mapAreaID] then
						SetMapByID(MAP_ZOOMOUT_OVERRIDE[mapAreaID])
						return
					else
						SetMapZoom(WORLDMAP_WORLD_ID)
						return
					end
				else
					SetMapZoom(currentRealContinentIndex)
					return
				end
			else
				if currentRealContinentIndex ~= WORLDMAP_COSMIC_ID then
					local realContinentIndex = PRIVATE.CONTINENTS_MAPPED_MAP_REVERSE[continentIndex]
					local continentName = PRIVATE.CONTINENTS_REAL[realContinentIndex]
					if continentName and CONTINENT_MAP_OVERRIDE[continentName] then
						SetMapByID(CONTINENT_MAP_OVERRIDE[continentName])
						return
					elseif continentIndex > 0 then
						continentIndex = realContinentIndex
					end
				end
			end
		end
	end

	SetMapZoom(continentIndex, zoneIndex)
end

_G.ZoomOut = function()
	local mapAreaID = PRIVATE.GetCurrentMapAreaID()
	local parentMapID = PRIVATE.GetParentMapID(mapAreaID)
	if not GetCurrentMapDungeonLevel() and parentMapID == 0 then
		SetMapZoom(WORLDMAP_COSMIC_ID)
	elseif MAP_ZOOMOUT_OVERRIDE[mapAreaID] then
		SetMapByID(MAP_ZOOMOUT_OVERRIDE[mapAreaID])
	else
		ZoomOut()
	end
end

PRIVATE.GetMapLandmarks = function()
	local mapAreaID = PRIVATE.GetCurrentMapAreaID()
	local realContinentIndex = GetCurrentMapContinent()

	if not PRIVATE.MAP_LANDMARKS_DIRTY
	and PRIVATE.MAP_LANDMARKS_AREA_ID == mapAreaID
	and PRIVATE.MAP_LANDMARKS_CONTINENT_INDEX == realContinentIndex
	then
		return PRIVATE.MAP_LANDMARKS
	end

	twipe(PRIVATE.MAP_LANDMARKS)

	local isGM = IsGMAccount()
	local realmID = GetServerID()

	for landmarkIndex = 1, GetNumMapLandmarks() do
		local name, description, textureIndex, x, y, maplinkID, showInBattleMap = GetMapLandmarkInfo(landmarkIndex)
		if (not isGM and textureIndex == 41)
		or (not isGM and textureIndex == 174 and realmID == E_REALM_ID.ALGALON)
		or (textureIndex == 171 and (mapAreaID == 504 or mapAreaID == 510) and realmID == E_REALM_ID.SOULSEEKER)
		then
			-- ignore
		else
			tinsert(PRIVATE.MAP_LANDMARKS, landmarkIndex)
		end
	end

	PRIVATE.MAP_LANDMARKS_AREA_ID = mapAreaID
	PRIVATE.MAP_LANDMARKS_CONTINENT_INDEX = realContinentIndex
	PRIVATE.MAP_LANDMARKS_DIRTY = nil

	return PRIVATE.MAP_LANDMARKS
end

_G.GetNumMapLandmarks = function()
	local mapLandmarks = PRIVATE.GetMapLandmarks()
	return #mapLandmarks
end

_G.GetMapLandmarkInfo = function(index)
	if type(index) ~= "number" then
		error("Usage: GetMapLandmarkInfo(index)", 2)
	end

	local mapLandmarks = PRIVATE.GetMapLandmarks()
	local landmarkIndex = mapLandmarks[index]

	if not landmarkIndex then
		return nil, nil, 0, 0, 0, nil, nil
	end

	local name, description, textureIndex, x, y, maplinkID, showInBattleMap = GetMapLandmarkInfo(landmarkIndex)
	if PRIVATE.MAP_LANDMARKS_AREA_ID == 916 and textureIndex == 45 then
		textureIndex = 192
	end
	return name, description, textureIndex, x, y, maplinkID, showInBattleMap
end

C_Map = {}

function C_Map.GetAreaNameByID(mapAreaID)
	return PRIVATE.GetAreaNameByID(mapAreaID)
end

function C_Map.GetParentMapID(mapAreaID)
	return PRIVATE.GetParentMapID(mapAreaID)
end