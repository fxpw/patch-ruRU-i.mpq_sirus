--	Filename:	C_Guild.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

C_GuildMixin = {}

function C_GuildMixin:GetTabardEmblemCoords( emblemSize, columns, offset, emblemID )
    local xCoord = mod(emblemID, columns) * emblemSize
    local yCoord = floor(emblemID / columns) * emblemSize

    return {xCoord + offset, xCoord + emblemSize - offset, yCoord + offset, yCoord + emblemSize - offset}
end

function C_GuildMixin:GetTabardLargeEmblemCoords( emblemID )
    return self:GetTabardEmblemCoords(64 / 1024, 16, 0, emblemID)
end

function C_GuildMixin:GetTabardSmallEmblemCoords( emblemID )
    return self:GetTabardEmblemCoords(18 / 256, 14, 1 / 256, emblemID)
end

function C_GuildMixin:GetTabardEmblemColor( colorID )
    return GUILD_TABARD_EMBLEM_COLOR[colorID]
end

function C_GuildMixin:GetTabardBackgroundColor( colorID )
    return GUILD_TABARD_BACKGROUND_COLOR[colorID]
end

function C_GuildMixin:GetTabardBorderColor( borderStyleID, colorID )
    return GUILD_TABARD_BORDER_COLOR[borderStyleID] and GUILD_TABARD_BORDER_COLOR[borderStyleID][colorID] or GUILD_TABARD_BORDER_COLOR["ALL"][colorID]
end

---@class C_GuildMixin
C_Guild = CreateFromMixins(C_GuildMixin)