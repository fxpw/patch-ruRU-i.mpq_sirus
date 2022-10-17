--	Filename:	C_Map.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

---@class C_MapMixin : Mixin
C_MapMixin = {}

enum:E_WORLDMAP_MAP_NAME_BY_ID {
    "PARENT_WORLD_MAP_ID",
    "AREA_NAME_ENGB",
    "AREA_NAME_RURU"
}

local AREA_NAME_LOCALE = string.format("AREA_NAME_%s", GetLocale():upper())

---@param mapAreaID integer
---@return string areaName
function C_MapMixin:GetAreaNameByID( mapAreaID )
	return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][E_WORLDMAP_MAP_NAME_BY_ID[AREA_NAME_LOCALE]]
end

---@param mapAreaID integer
---@return number parentMapID
function C_MapMixin:GetParentMapID( mapAreaID )
    return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][E_WORLDMAP_MAP_NAME_BY_ID.PARENT_WORLD_MAP_ID]
end

---@class C_Map : C_MapMixin
C_Map = CreateFromMixins(C_MapMixin)