--	Filename:	C_ObjectGUID.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

enum:E_OBJECT_GUID_TYPES {
    PLAYER          = 0x0,
    WORLD_OBJECT    = 0x1,
    CREATURE        = 0x3,
    PET             = 0x4,
    VEHICLE         = 0x5
}

C_ObjectGUIDMixin = {}

function C_ObjectGUIDMixin:SetGUID( GUID )
    if not GUID or GUID == "" then
        GUID = 0
    end

    if type(GUID) == "number" then
        GUID = string.format("0x%016X", GUID)
    end

    self._GUID = GUID
end

function C_ObjectGUIDMixin:GetType()
    return bit.band(tonumber(self._GUID:sub(5, 5)), 0x7)
end

function C_ObjectGUIDMixin:GetGUIDLow()
    return tonumber(self._GUID:sub(13, 18))
end

function C_ObjectGUIDMixin:IsPlayer()
    return self:GetType() == E_OBJECT_GUID_TYPES.PLAYER
end

function C_ObjectGUIDMixin:IsWorldObject()
    return self:GetType() == E_OBJECT_GUID_TYPES.WORLD_OBJECT
end

function C_ObjectGUIDMixin:IsCreature()
    return self:GetType() == E_OBJECT_GUID_TYPES.CREATURE
end

function C_ObjectGUIDMixin:IsPet()
    return self:GetType() == E_OBJECT_GUID_TYPES.PET
end

function C_ObjectGUIDMixin:IsVehicle()
    return self:GetType() == E_OBJECT_GUID_TYPES.VEHICLE
end

function C_ObjectGUIDMixin:IsEmpty()
    return self:GetGUIDLow() == 0
end

function C_ObjectGUIDMixin:GetRawValue()
    return self._GUID
end

---@class C_ObjectGUIDMixin
C_ObjectGUID = {}

function C_ObjectGUID:CreateGUID( GUID )
    local instance = CreateFromMixins(C_ObjectGUIDMixin)
    instance:SetGUID(GUID)

    return instance
end