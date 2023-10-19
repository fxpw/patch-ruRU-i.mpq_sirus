local select = select
local type = type
local unpack = unpack
local twipe = table.wipe

local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetCurrentMapContinent = GetCurrentMapContinent
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local GetCurrentMapZone = GetCurrentMapZone
local GetMapZones = GetMapZones
local GetMapContinents = GetMapContinents
local GetMapLandmarkInfo = GetMapLandmarkInfo
local ProcessMapClick = ProcessMapClick
local SetMapByID = SetMapByID
local SetMapZoom = SetMapZoom
local UpdateMapHighlight = UpdateMapHighlight
local ZoomOut = ZoomOut

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
}

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
		local name = select(index, ...) or "NONAME"..index

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
	if not GetCurrentMapDungeonLevel() and PRIVATE.GetParentMapID() == 0 then
		SetMapZoom(WORLDMAP_COSMIC_ID)
	else
		ZoomOut()
	end
end

_G.GetMapLandmarkInfo = function(index)
	local name, description, textureIndex, x, y, maplinkID, showInBattleMap = GetMapLandmarkInfo(index)
	if PRIVATE.GetCurrentMapAreaID() == 916 and textureIndex == 45 then
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