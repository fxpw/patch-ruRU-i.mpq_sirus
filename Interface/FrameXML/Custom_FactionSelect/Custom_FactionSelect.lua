UIPanelWindows["FactionSelectFrame"] = { area = "center", pushable = 0, whileDead = 1 };

FactionSelectFrameMixin = {}

function FactionSelectFrameMixin:OnLoad()
	self.selectFramesPool = CreateFramePool("Frame", self, "FactionSelectTemplate")
end

function FactionSelectFrameMixin:ShowSelection(state, factionID, race, isDK)
	if state == 0 then
		HideUIPanel(self)
	elseif state == 1 then
		self.selectFramesPool:ReleaseAll()

		if factionID == -1 then
			for i, _factionID in ipairs({PLAYER_FACTION_GROUP.Alliance, PLAYER_FACTION_GROUP.Horde}) do
				local frame = self.selectFramesPool:Acquire()
				frame:SetStyle(_factionID, race, isDK)
				frame:ClearAllPoints()
				if i == 1 then
					frame:SetPoint("CENTER", -(math.ceil(frame:GetWidth() / 2) + 15), 0)
				else
					frame:SetPoint("CENTER", math.ceil(frame:GetWidth() / 2) + 15, 0)
				end
				frame:Show()
			end
		else
			local frame = self.selectFramesPool:Acquire()
			frame:SetStyle(factionID, race, isDK)
			frame:ClearAllPoints()
			frame:SetPoint("CENTER")
			frame:Show()
		end

		ShowUIPanel(self)
	end
end

function FactionSelectFrameMixin:ChooseFaction(factionName)
	local factionID = PLAYER_FACTION_GROUP[factionName]
	StaticPopup_Show("FACTION_SELECT_CONFIRMATION", _G["BATTLEGROUND_CROSS_FACTION_"..factionID], nil, factionID)
end

local factionTemplate = {
	Horde = {
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

		TitleText = FACTION_SELECT_TITLE_HORDE,
		ButtonText = FACTION_SELECT_BUTTON_JOIN_HORDE,
	},
	Alliance = {
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

		TitleText = FACTION_SELECT_TITLE_ALLIANCE,
		ButtonText = FACTION_SELECT_BUTTON_JOIN_ALLIANCE,
	},
}

local raceTemplate = {
	VULPERA = {
		Horde = {
			text = FACTION_SELECT_TEXT_VULPERA_HORDE,
			textDK = FACTION_SELECT_TEXT_DK_HORDE,
			banner = "FactionSelect-Banner-Vulpera-Horde",
		},
		Alliance = {
			text = string.format(FACTION_SELECT_TEXT_VULPERA_ALLIANCE, UnitSex("player") == 2 and FACTION_SELECT_DECIDED_MALE or FACTION_SELECT_DECIDED_FEMALE),
			textDK = FACTION_SELECT_TEXT_DK_ALLIANCE,
			banner = "FactionSelect-Banner-Vulpera-Alliance",
		},
	},
	VULPERA_LATE = {
		Horde = {
			text = string.format(FACTION_SELECT_TEXT_VULPERA_LATE_HORDE, UnitSex("player") == 2 and FACTION_SELECT_FRIEND_MALE or FACTION_SELECT_FRIEND_FEMALE),
			banner = "FactionSelect-Banner-Vulpera-Horde",
		},
		Alliance = {
			text = string.format(FACTION_SELECT_TEXT_VULPERA_LATE_ALLIANCE, UnitSex("player") == 2 and FACTION_SELECT_DECIDED_MALE or FACTION_SELECT_DECIDED_FEMALE, UnitSex("player") == 2 and FACTION_SELECT_GLAD_MALE or FACTION_SELECT_GLAD_FEMALE),
			banner = "FactionSelect-Banner-Vulpera-Alliance",
		},
	},
	PANDAREN = {
		Horde = {
			text = FACTION_SELECT_TEXT_PANDAREN_HORDE,
			textDK = FACTION_SELECT_TEXT_DK_HORDE,
			banner = "FactionSelect-Banner-Pandaren-Horde",
		},
		Alliance = {
			text = FACTION_SELECT_TEXT_PANDAREN_ALLIANCE,
			textDK = FACTION_SELECT_TEXT_DK_ALLIANCE,
			banner = "FactionSelect-Banner-Pandaren-Alliance",
		},
	},
	DRACTHYR = {
		Horde = {
			text = FACTION_SELECT_TEXT_DRACTHYR_HORDE,
			textDK = FACTION_SELECT_TEXT_DK_HORDE,
			banner = "FactionSelect-Banner-Dracthyr-Horde",
		},
		Alliance = {
			text = FACTION_SELECT_TEXT_DRACTHYR_ALLIANCE,
			textDK = FACTION_SELECT_TEXT_DK_ALLIANCE,
			banner = "FactionSelect-Banner-Dracthyr-Alliance",
		},
	},
}

FactionSelectTemplateMixin = {}

function FactionSelectTemplateMixin:OnLoad()
	SetParentFrameLevel(self.OverlayElements, 3)
	self.Top:SetAtlas("_Garr_WoodFrameTile-Top", true)
	self.OverlayElements.CloseButtonBorder:SetParent(self.CloseButton)
end

function FactionSelectTemplateMixin:GetNineSlicePiece(pieceName)
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

function FactionSelectTemplateMixin:SetStyle(factionID, race, isDK)
	local factitonName = PLAYER_FACTION_GROUP[factionID]
	self.factitonName = factitonName
	self.factionTemplate = factionTemplate[factitonName]
	self.raceTemplate = raceTemplate[race][factitonName]

	local nineSliceLayout = NineSliceUtil.GetLayout(self.factionTemplate.nineSliceLayout)
	NineSliceUtil.ApplyLayout(self, nineSliceLayout)

	self.BackgroundTile:SetAtlas(self.factionTemplate.BackgroundTile)

	self.OverlayElements.Topper:SetPoint("BOTTOM", self.Top, "TOP", 0, self.factionTemplate.TopperOffset)
	self.OverlayElements.Topper:SetAtlas(self.factionTemplate.Topper, true)

	self.OverlayElements.CloseButtonBorder:SetAtlas(self.factionTemplate.closeButtonBorder, true)
	self.OverlayElements.CloseButtonBorder:SetPoint("CENTER", self.CloseButton, "CENTER", self.factionTemplate.closeButtonBorderX, self.factionTemplate.closeButtonBorderY)

	self.Title.Left:SetAtlas(self.factionTemplate.TitleLeft, true)
	self.Title.Right:SetAtlas(self.factionTemplate.TitleRight, true)
	self.Title.Middle:SetAtlas(self.factionTemplate.TitleMiddle, true)

	self.ContentFrame.Background:SetAtlas(self.factionTemplate.ContentBackground, true)
	self.ContentFrame.ImageBorder:SetAtlas(self.factionTemplate.ContentImageBorder, true)
	self.ContentFrame.ImageBackground:SetTexture(string.format("Interface\\QuestionFrame\\%s", self.raceTemplate.banner))

	self.Title.Text:SetText(self.factionTemplate.TitleText)
	self.ContentFrame.ChooseFaction:SetText(self.factionTemplate.ButtonText)

	if isDK then
		self.ContentFrame.Text:SetText(self.raceTemplate.textDK)
	else
		self.ContentFrame.Text:SetText(self.raceTemplate.text)
	end
end

function FactionSelectTemplateMixin:Close()
	HideUIPanel(FactionSelectFrame)
end

function FactionSelectTemplateMixin:ChooseFaction()
	self:GetParent():ChooseFaction(self.factitonName)
end

function EventHandler:SHOW_FACTION_SELECT_UI(msg) -- deprecated
	FactionSelectFrame:ShowSelection(1, -1, "PANDAREN", false)
end

function EventHandler:ASMSG_FACTION_SELECT(msg)
	if msg == "0" then
		FactionSelectFrame:ShowSelection(0)
	else
		local state, factionID, raceName, isDK = string.split(":", msg)
		FactionSelectFrame:ShowSelection(tonumber(state), tonumber(factionID), raceName, tonumber(isDK) == 1)
	end
end