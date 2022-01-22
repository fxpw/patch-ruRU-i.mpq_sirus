--	Filename:	Custom_VulperaFactionSelectUI.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

VulperaFactionSelectMixin = {
	WindowStyleTemplate = {}
}

UIPanelWindows["VulperaSelectFactionFrame"] = { area = "center", pushable = 0, whileDead = 1 };

VulperaFactionSelectMixin.WindowStyleTemplate["Horde"] = {
	TitleScrollOffset = 6,
	TitleColor = CreateColor(0.192, 0.051, 0.008, 1),

	TopperOffset = -60,
	Topper = "HordeFrame-Header",

	closeButtonBorder = "HordeFrame_ExitBorder",
	closeButtonBorderX = -1,
	closeButtonBorderY = 1,
	closeButtonX = 4,
	closeButtonY = 4,

	nineSliceLayout = "BFAMissionHorde",

	BackgroundTile = "UI-Frame-Horde-BackgroundTile",

	TitleLeft = "UI-Frame-Horde-TitleLeft",
	TitleRight = "UI-Frame-Horde-TitleRight",
	TitleMiddle = "_UI-Frame-Horde-TitleMiddle",

	ContentBackground = "UI-Frame-Horde-CardParchmentWider",
	ContentImageBorder = "UI-Frame-Horde-PortraitWider",
	ContentImageBackGround = "vulpera_banner_horde"
}

VulperaFactionSelectMixin.WindowStyleTemplate["Alliance"] = {
	TitleScrollOffset = -5,
	TitleColor = CreateColor(0.008, 0.051, 0.192, 1),

	TopperOffset = -52,
	Topper = "AllianceFrame-Header",

	closeButtonBorder = "AllianceFrame_ExitBorder",
	closeButtonBorderX = 0,
	closeButtonBorderY = -1,
	closeButtonX = 4,
	closeButtonY = 4,

	nineSliceLayout = "BFAMissionAlliance",

	BackgroundTile = "UI-Frame-Alliance-BackgroundTile",

	TitleLeft = "UI-Frame-Alliance-TitleLeft",
	TitleRight = "UI-Frame-Alliance-TitleRight",
	TitleMiddle = "_UI-Frame-Alliance-TitleMiddle",

	ContentBackground = "UI-Frame-Alliance-CardParchmentWider",
	ContentImageBorder = "UI-Frame-Alliance-PortraitWider",
	ContentImageBackGround = "vulpera_banner_alliance"
}

function VulperaFactionSelectMixin:OnLoad()
	self.Top:SetAtlas("_Garr_WoodFrameTile-Top", true)
end

function VulperaFactionSelectMixin:SetStyle( style, isDK )
	self.selectedTemplate 	= self.WindowStyleTemplate[style]
	self.selectedStyle 		= style

	local nineSliceLayout = NineSliceUtil.GetLayout(self.selectedTemplate.nineSliceLayout)
	NineSliceUtil.ApplyLayout(self, nineSliceLayout)

	self.BackgroundTile:SetAtlas(self.selectedTemplate.BackgroundTile)

	self.OverlayElements.Topper:SetPoint("BOTTOM", self.Top, "TOP", 0, self.selectedTemplate.TopperOffset)
	self.OverlayElements.Topper:SetAtlas(self.selectedTemplate.Topper, true)

	self.OverlayElements.CloseButtonBorder:SetAtlas(self.selectedTemplate.closeButtonBorder, true)
	self.OverlayElements.CloseButtonBorder:SetParent(self.CloseButton)
	self.OverlayElements.CloseButtonBorder:SetPoint("CENTER", self.CloseButton, "CENTER", self.selectedTemplate.closeButtonBorderX, self.selectedTemplate.closeButtonBorderY)

	self.Title.Left:SetAtlas(self.selectedTemplate.TitleLeft, true)
	self.Title.Right:SetAtlas(self.selectedTemplate.TitleRight, true)
	self.Title.Middle:SetAtlas(self.selectedTemplate.TitleMiddle, true)

	self.ContentFrame.Background:SetAtlas(self.selectedTemplate.ContentBackground, true)
	self.ContentFrame.ImageBorder:SetAtlas(self.selectedTemplate.ContentImageBorder, true)
	self.ContentFrame.ImageBackground:SetTexture("Interface\\QuestionFrame\\"..self.selectedTemplate.ContentImageBackGround)

	if self.selectedStyle == "Alliance" then
		self.Title.Text:SetText(VULPERA_TITLE_TEXT_ALLIANCE)

		if isDK then
			self.ContentFrame.Text:SetText(VULPERA_FACTION_SELECT_TEXT_DK_ALLIANCE)
		else
			self.ContentFrame.Text:SetFormattedText(VULPERA_FACTION_SELECT_TEXT_ALLIANCE, UnitSex("player") == 2 and DECIDED_MALE or DECIDED_FEMALE)
		end

		self.ContentFrame.ChooseFaction:SetText(VULPERA_JOIN_TO_ALLIANCE)
	else
		self.Title.Text:SetText(VULPERA_TITLE_TEXT_HORDE)
		self.ContentFrame.Text:SetText(isDK and VULPERA_FACTION_SELECT_TEXT_DK_HORDE or VULPERA_FACTION_SELECT_TEXT_HORDE)
		self.ContentFrame.ChooseFaction:SetText(VULPERA_JOIN_TO_HORDE)
	end
end

function VulperaFactionSelectMixin:GetNineSlicePiece( pieceName )
	if pieceName == "TopLeftCorner" then
		return self.TopLeftCorner
	elseif pieceName == "TopRightCorner" then
		return self.TopRightCorner
	elseif pieceName == "BottomLeftCorner" then
		return self.BotLeftCorner
	elseif pieceName == "BottomRightCorner" then
		return self.BotRightCorner
	elseif pieceName == "TopEdge" then
		return self.TopBorder
	elseif pieceName == "BottomEdge" then
		return self.BottomBorder
	elseif pieceName == "LeftEdge" then
		return self.LeftBorder
	elseif pieceName == "RightEdge" then
		return self.RightBorder
	end
end

function VulperaFactionSelectMixin:ChooseFaction()
	local factionID = PLAYER_FACTION_GROUP[self.selectedStyle]
	local dialog 	= StaticPopup_Show("VULPERA_SELECT_FACTION", _G["BATTLEGROUND_CROSS_FACTION_"..factionID])
	dialog.data 	= factionID
end

function VulperaFactionSelectMixin:Toggle( state, factionID, isDK )
	if state == 0 then
		HideUIPanel(VulperaSelectFactionFrame)
	elseif state == 1 and factionID then
		self:SetStyle(PLAYER_FACTION_GROUP[factionID], isDK)

		ShowUIPanel(VulperaSelectFactionFrame)
	end
end

function EventHandler:ASMSG_FACTION_SELECT_UI_VULPERA( msg )
	local splitData = C_Split(msg, ":")

	local state 		= tonumber(splitData[1])
	local factionID 	= splitData[2] and tonumber(splitData[2])
	local isDK 			= splitData[3] and tonumber(splitData[3])

	VulperaSelectFactionFrame:Toggle(state, factionID, isDK)
end