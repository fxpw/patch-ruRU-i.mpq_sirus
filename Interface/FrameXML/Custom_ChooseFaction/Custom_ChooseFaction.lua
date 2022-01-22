--	Filename:	Custom_ChooseFaction.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

UIPanelWindows["Custom_ChooseFactionFrameParent"] = { area = "center",	pushable = 0,	whileDead = 1 };

enum:E_RENEGADE_ALLEGIANCE_OPEN {
    "FACTIONID",
    "QUESTID"
}

local styleData = {
    nineSliceLayout = "BFAMissionNeutral",

    closeButtonBorder = "UI-Frame-GenericMetal-ExitButtonBorder",
    closeButtonBorderX = 0,
    closeButtonBorderY = 0,
    closeButtonX = 4,
    closeButtonY = 4,
}

Custom_ChooseFactionParentMixin = {}

function Custom_ChooseFactionParentMixin:OnLoad()
    self:RegisterEventListener()
end

function Custom_ChooseFactionParentMixin:OnHide()
    for _, frame in pairs(self.chooseFrame or {}) do
        frame:Hide()
    end

    self:SetWidth(0)
end

function Custom_ChooseFactionParentMixin:GetFreeChooseFrame()
    for _, frame in pairs(self.chooseFrame or {}) do
        if not frame:IsShown() then
            return frame
        end
    end
end

function Custom_ChooseFactionParentMixin:ASMSG_SHOP_RENEGADE_CHARACTER_CHANGEFACTION()
    if self:IsShown() then
        return
    end

    local factionID = C_Unit:GetFactionID("player")

    for i = 0, 2 do
        if factionID ~= i then
            self:GetFreeChooseFrame():Open(GAME_FACTION_TO_SERVER_FACTION[i])
        end
    end

    ShowUIPanel(self)
end

function Custom_ChooseFactionParentMixin:ASMSG_RENEGADE_ALLEGIANCE_OPEN( msg )
    if self:IsShown() then
        return
    end

    local splitData = C_Split(msg, ":")

    local factionID = tonumber(splitData[E_RENEGADE_ALLEGIANCE_OPEN.FACTIONID])
    local questID   = tonumber(splitData[E_RENEGADE_ALLEGIANCE_OPEN.QUESTID])

    self:GetFreeChooseFrame():Open(factionID, questID)

    ShowUIPanel(self)
end

function Custom_ChooseFactionParentMixin:ASMSG_RENEGADE_ALLEGIANCE_CLOSE()
    HideUIPanel(self)
end

Custom_ChooseFactionMixin = {}

function Custom_ChooseFactionMixin:OnLoad()
    self:RegisterEventListener()

    self:SetParentArray("chooseFrame")

    self.onCloseCallback = function()
        local parent = self:GetParent()

        if parent:IsShown() then
            HideUIPanel(parent)
        end
    end

    self.selectedTemplate = styleData

    local nineSliceLayout = NineSliceUtil.GetLayout(self.selectedTemplate.nineSliceLayout)
    NineSliceUtil.ApplyLayout(self, nineSliceLayout)

    self.OverlayElements.CloseButtonBorder:SetAtlas(self.selectedTemplate.closeButtonBorder, true)
    self.OverlayElements.CloseButtonBorder:SetParent(self.CloseButton)
    self.OverlayElements.CloseButtonBorder:SetPoint("CENTER", self.CloseButton, "CENTER", self.selectedTemplate.closeButtonBorderX, self.selectedTemplate.closeButtonBorderY)
end

function Custom_ChooseFactionMixin:SetQuestID( questID )
    self.questID = questID
end

function Custom_ChooseFactionMixin:GetQuestID()
    return self.questID
end

function Custom_ChooseFactionMixin:SetFactionID( factionID )
    self.factionID = factionID
end

function Custom_ChooseFactionMixin:GetFactionID()
    return self.factionID
end

function Custom_ChooseFactionMixin:SetupFaction( factionID )
    local factionGroup = SERVER_PLAYER_FACTION_GROUP[factionID]

    self.Logo:SetAtlas("ChooseFaction-logo-"..factionGroup, true)
    self.BackgroundTile:SetAtlas("ChooseFaction-Background-"..factionGroup)

    self.ChooseButton:SetText(_G["ALLEGIANCE_FOR_THE_"..string.upper(factionGroup)])
end

function Custom_ChooseFactionMixin:Open( factionID, questID )
    self:SetQuestID(questID)
    self:SetFactionID(SERVER_FACTION_TO_GAME_FACTION[factionID])

    self:SetupFaction(factionID)

    local parent = self:GetParent()
    parent:SetWidth((parent:GetWidth() + self:GetWidth()) + 10)

    self:Show()
end

function Custom_ChooseFactionMixin:GetNineSlicePiece( pieceName )
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

function Custom_ChooseFactionMixin:Choose()
    local factionID = self:GetFactionID()

    local dialog 	= StaticPopup_Show("CHOOSE_FACTION_SELECT_FACTION", _G["BATTLEGROUND_CROSS_FACTION_"..factionID])
    dialog.data 	= { factionID = GAME_FACTION_TO_SERVER_FACTION[factionID], questID = self:GetQuestID() }

    HideUIPanel(self:GetParent())
end