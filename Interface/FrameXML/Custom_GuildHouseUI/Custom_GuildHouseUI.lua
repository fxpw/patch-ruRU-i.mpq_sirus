--	Filename:	Sirus_GuildHouseUI.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local PH_HOUSE_SLOTS_DATA_PH = {
	-- Large House
	[1] = {
		name 			= "Тест Дом ID: 1",
		description 	= "Описание тестового дома ID: 1",
		slotsType 		= 1,
		icon 			= "INV_INGOT_GHOSTIRON",
		tooltipHeader 	= "Заголовой Тест Дома ID: 1",
		tooltip 		= "Содержание тоолтипа тест дома ID: 1"
	},
	[2] = {
		name 			= "Тест Дом ID: 2",
		description 	= "Описание тестового дома ID: 2",
		slotsType 		= 1,
		icon 			= "INV_Ingot_Trillium",
		tooltipHeader 	= "Заголовой Тест Дома ID: 2",
		tooltip 		= "Содержание тоолтипа тест дома ID: 2"
	},
	[3] = {
		name 			= "Тест Дом ID: 3",
		description 	= "Описание тестового дома ID: 3",
		slotsType 		= 1,
		icon 			= "INV_INGOT_GHOSTIRON",
		tooltipHeader 	= "Заголовой Тест Дома ID: 3",
		tooltip 		= "Содержание тоолтипа тест дома ID: 3"
	},
	-- Medium house
	[4] = {
		name 			= "Тест Дом ID: 4",
		description 	= "Описание тестового дома ID: 4",
		slotsType 		= 2,
		icon 			= "INV_Ingot_LivingSteel",
		tooltipHeader 	= "Заголовой Тест Дома ID: 4",
		tooltip 		= "Содержание тоолтипа тест дома ID: 4"
	},
	[5] = {
		name 			= "Тест Дом ID: 5",
		description 	= "Описание тестового дома ID: 5",
		slotsType 		= 2,
		icon 			= "INV_Ingot_LivingSteel",
		tooltipHeader 	= "Заголовой Тест Дома ID: 5",
		tooltip 		= "Содержание тоолтипа тест дома ID: 5"
	},
	[6] = {
		name 			= "Тест Дом ID: 6",
		description 	= "Описание тестового дома ID: 6",
		slotsType 		= 2,
		icon 			= "INV_Ingot_LivingSteel",
		tooltipHeader 	= "Заголовой Тест Дома ID: 6",
		tooltip 		= "Содержание тоолтипа тест дома ID: 6"
	},
	-- Small House
	[7] = {
		name 			= "Тест Дом ID: 7",
		description 	= "Описание тестового дома ID: 7",
		slotsType 		= 3,
		icon 			= "INV_Ingot_Manticyte",
		tooltipHeader 	= "Заголовой Тест Дома ID: 7",
		tooltip 		= "Содержание тоолтипа тест дома ID: 7"
	},
	[8] = {
		name 			= "Тест Дом ID: 8",
		description 	= "Описание тестового дома ID: 8",
		slotsType 		= 3,
		icon 			= "INV_Ingot_Manticyte",
		tooltipHeader 	= "Заголовой Тест Дома ID: 8",
		tooltip 		= "Содержание тоолтипа тест дома ID: 8"
	},
	[9] = {
		name 			= "Тест Дом ID: 9",
		description 	= "Описание тестового дома ID: 9",
		slotsType 		= 3,
		icon 			= "INV_Ingot_Manticyte",
		tooltipHeader 	= "Заголовой Тест Дома ID: 9",
		tooltip 		= "Содержание тоолтипа тест дома ID: 9"
	},
}
local PH_PLOT_DATA_PH = {
	[1] = {

	}
}

GuildHouseMixIn = {}
GuildHousePlotMixIn = {}
GuildHousePlotInfoMixIn = {}

GUILD_HOUSE_PLOT_INFO = {}
GUILD_HOUSE_PLOT_INFO[1] = Mixin({
	plotType 	 = 1,
	emptyTexture = "GarrisonMissionUIInfoBoxBackgroundTile",
	tooltipLabel = GUILD_HOUSE_PLOT_LARGE_TOOLTIP_LABEL,
	tooltip 	 = GUILD_HOUSE_PLOT_LARGE_TOOLTIP
}, GuildHousePlotInfoMixIn)
GUILD_HOUSE_PLOT_INFO[2] = Mixin({
	plotType 	 = 2,
	emptyTexture = "GarrisonMissionUIInfoBoxBackgroundTile",
	tooltipLabel = GUILD_HOUSE_PLOT_MEDIUM_TOOLTIP_LABEL,
	tooltip 	 = GUILD_HOUSE_PLOT_MEDIUM_TOOLTIP
}, GuildHousePlotInfoMixIn)
GUILD_HOUSE_PLOT_INFO[3] = Mixin({
	plotType 	 = 3,
	emptyTexture = "GarrisonMissionUIInfoBoxBackgroundTile",
	tooltipLabel = GUILD_HOUSE_PLOT_SMALL_TOOLTIP_LABEL,
	tooltip 	 = GUILD_HOUSE_PLOT_SMALL_TOOLTIP
}, GuildHousePlotInfoMixIn)

function GuildHousePlotInfoMixIn:GetType()
	return self.plotType
end

function GuildHousePlotInfoMixIn:GetEmptyTexture()
	return "Interface\\Garrison\\"..self.emptyTexture
end

function GuildHousePlotInfoMixIn:GetTooltipLabel()
	return self.tooltipLabel
end

function GuildHousePlotInfoMixIn:GetTooltipText()
	return self.tooltip
end

function GuildHouseMixIn:GuildTabardSetup( emblemStyle, emblemColors, emblemBorderStyle, emblemBorderColors, emblemBackgroundColors )
	local backgroundColor, emblemColor, borderColor

	if SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColors] then
		backgroundColor = CreateColor(unpack(SHARED_TABARD_BACKGROUND_COLOR[emblemBackgroundColors])):ConvertToGameRGB()
	end

	if SHARED_TABARD_EMBLEM_COLOR[emblemColors] then
		emblemColor = CreateColor(unpack(SHARED_TABARD_EMBLEM_COLOR[emblemColors])):ConvertToGameRGB()
	end

	if SHARED_TABARD_BORDER_COLOR[emblemBorderStyle] and SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColors] then
		borderColor = CreateColor(unpack(SHARED_TABARD_BORDER_COLOR[emblemBorderStyle][emblemBorderColors])):ConvertToGameRGB()
	elseif SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColors] then
		borderColor = CreateColor(unpack(SHARED_TABARD_BORDER_COLOR["ALL"][emblemBorderColors])):ConvertToGameRGB()
	end

	if backgroundColor and emblemColor and borderColor then
		self.GuildPortrait.Background:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
		self.GuildPortrait.Border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
		self.GuildPortrait.Emblem:SetVertexColor(emblemColor.r, emblemColor.g, emblemColor.b)

		SetSmallGuildTabardTextures(self.GuildPortrait.Emblem, emblemStyle)
	end
end

function GuildHouseFrame_OnLoad( self, ... )
	Mixin(self, GuildHouseMixIn)

	self.TopRightCorner:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
	self.BotLeftCorner:SetSubTexCoord(0.0, 1.0, 1.0, 0.0)
	self.BotRightCorner:SetSubTexCoord(1.0, 0.0, 1.0, 0.0)

	self.Right:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
end

function GuildHouseFrame_OnShow( self, ... )
	-- body
end

function GuildHouseFrame_OnHide( self, ... )
	-- body
end

function GuildHousePlotMixIn:UpdateSize()
	local width, height = self:GetSize()

	self.Icon:SetSize(width - 10, height - 10)
	self.IconBorder:SetSize(width, height)
	self.SpikeyGlow:SetSize(width * 2.2, height * 2.2)
	self.Highlight:SetSize(width, height)
end

function GuildHousePlotMixIn:UpdateIcons()
	-- body
end

function GuildHousePlotMixIn:UpdatePlot()
	local buttonsData = SetParentArray(self:GetParent(), "PlotButtons", self)

	self:SetID(#buttonsData)
	self.DebugID:SetText(#buttonsData)

	self:UpdateSize()
	self:UpdateIcons()
end

function GuildHousePlotMixIn:GetType()
	return self:GetAttribute("HOUSE_SLOT_TYPE")
end

function GuildHousePlotMixIn:GetInfo()
	local data = PH_PLOT_DATA_PH[self:GetID()]
	local plotInfo = GUILD_HOUSE_PLOT_INFO[self:GetType()]
	local isEmpty, icon, tooltipLabel, tooltip, name, description, houseLevel, canUpgrade, needGuildLevel, isLock, lockReason, cooldownStart, cooldownDuration

	-- if data then
	-- 	isEmpty = false
	-- else
	-- 	icon 		 = plotInfo:GetEmptyTexture()
	-- 	tooltipLabel = plotInfo:GetTooltipLabel()
	-- 	tooltip 	 = plotInfo:GetTooltipText()
	-- 	isEmpty 	 = true
	-- end

	return isEmpty, icon, tooltipLabel, tooltip, name, description
end

function GuildHousePlot_OnLoad( self, ... )
	Mixin(self, GuildHousePlotMixIn)

	self:UpdatePlot()

	-- SetPortraitToTexture(self.Icon, "Interface\\ICONS\\"..GUILD_HOUSE_BUILDINGS_TEMP_ICONS[math.random(1, #GUILD_HOUSE_BUILDINGS_TEMP_ICONS)])
	-- SetPortraitToTexture(self.Icon, "Interface\\Garrison\\GarrisonMissionUIInfoBoxBackgroundTile")
end

function EventHandler:ASMSG_PLAYER_GUILD_EMBLEM_INFO( msg )
	local borderInfo = C_Split(msg, ":")

	if borderInfo and #borderInfo > 0 then
		local emblemStyle, emblemColor, emblemBorderStyle, emblemBorderColor, emblemBackgroundColor = unpack(borderInfo)
		GuildHouseFrame:GuildTabardSetup(tonumber(emblemStyle), tonumber(emblemColor), tonumber(emblemBorderStyle), tonumber(emblemBorderColor), tonumber(emblemBackgroundColor))
	end
end
