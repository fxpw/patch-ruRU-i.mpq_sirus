--	Filename:	C_WhoManager.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_WhoManagerMixin = {}

function C_WhoManagerMixin:OnLoad()
    self._GetWhoInfo = GetWhoInfo
end

function C_WhoManagerMixin:GetWhoInfo( index )
    local name, guild, level, race, class, zone, classFileName = self._GetWhoInfo(index)
    local ilevel

    if name then
        name, ilevel = string.match(name, "(.-)%((%d+)%)")
    end

    return name, guild, level, race, class, zone, classFileName, ilevel
end

---@class C_WhoManagerMixin
C_WhoManager = CreateFromMixins(C_WhoManagerMixin)
C_WhoManager:OnLoad()

function GetWhoInfo( whoIndex )
    return C_WhoManager:GetWhoInfo(whoIndex)
end