--	Filename:	C_Map.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_MapMixin = {}

enum:E_WORLDMAP_MAP_NAME_BY_ID {
    "PARENT_WORLD_MAP_ID",
    "AREA_NAME_ENGB",
    "AREA_NAME_RURU"
}

---@param mapAreaID
---@return string areaName
function C_MapMixin:GetAreaNameByID( mapAreaID )
    return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][E_WORLDMAP_MAP_NAME_BY_ID[GetLocalizedName("AREA_NAME")]]
end

---@param mapAreaID
---@return number parentMapID
function C_MapMixin:GetParentMapID( mapAreaID )
    return WORLDMAP_MAP_NAME_BY_ID[mapAreaID] and WORLDMAP_MAP_NAME_BY_ID[mapAreaID][E_WORLDMAP_MAP_NAME_BY_ID.PARENT_WORLD_MAP_ID]
end

---@class C_MapMixin
C_Map = CreateFromMixins(C_MapMixin)