local WORLDMAP_MAP_NAME_BY_ID = WORLDMAP_MAP_NAME_BY_ID

local MAP_DATA_INDEX = {
	PARENT_WORLD_MAP_ID = 1,
	AREA_NAME_ENGB = 1,
	AREA_NAME_RURU = 1,
}

local AREA_NAME_LOCALE = string.format("AREA_NAME_%s", GetLocale():upper())

local function getCurrentMapAreaID()
	local currenctMapAreaID = GetCurrentMapAreaID()
	if currenctMapAreaID and currenctMapAreaID > 0 then
		return currenctMapAreaID - 1
	else
		return 0
	end
end

C_Map = {}

---@param mapAreaID? integer
---@return string areaName
function C_Map.GetAreaNameByID(mapAreaID)
	if not mapAreaID then
		mapAreaID = getCurrentMapAreaID()
	end
	return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][MAP_DATA_INDEX[AREA_NAME_LOCALE]]
end

---@param mapAreaID? integer
---@return number parentMapID
function C_Map.GetParentMapID(mapAreaID)
	if not mapAreaID then
		mapAreaID = getCurrentMapAreaID()
	end
	return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][MAP_DATA_INDEX.PARENT_WORLD_MAP_ID]
end