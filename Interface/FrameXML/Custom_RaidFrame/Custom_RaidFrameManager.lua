--	Filename:	Sirus_RaidFrameManager.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local CastSpellByID = CastSpellByID

NUM_WORLD_RAID_MARKERS = 8
NUM_RAID_ICONS = 8

local MARK_TYPE_SQUARE 		= 0
local MARK_TYPE_TRIANGLE 	= 1
local MARK_TYPE_CIRCLE 		= 2
local MARK_TYPE_DIAMOND 	= 3
local MARK_TYPE_CROSS 		= 4
local MARK_TYPE_MOON 		= 5
local MARK_TYPE_SKULL 		= 6
local MARK_TYPE_STAR 		= 7

WORLD_RAID_MARKER_ORDER = {}
WORLD_RAID_MARKER_ORDER[1] = {MARK_TYPE_SKULL, 		306653}
WORLD_RAID_MARKER_ORDER[2] = {MARK_TYPE_CROSS, 		306651}
WORLD_RAID_MARKER_ORDER[3] = {MARK_TYPE_SQUARE, 	306647}
WORLD_RAID_MARKER_ORDER[4] = {MARK_TYPE_MOON, 		306652}
WORLD_RAID_MARKER_ORDER[5] = {MARK_TYPE_TRIANGLE, 	306648}
WORLD_RAID_MARKER_ORDER[6] = {MARK_TYPE_DIAMOND, 	306650}
WORLD_RAID_MARKER_ORDER[7] = {MARK_TYPE_CIRCLE, 	306649}
WORLD_RAID_MARKER_ORDER[8] = {MARK_TYPE_STAR, 		306654}

WORLD_RAID_MARKER_ASSOCIATION = {}
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_SKULL] 		= WORLD_RAID_MARKER_ORDER[1]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_CROSS] 		= WORLD_RAID_MARKER_ORDER[2]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_SQUARE] 	= WORLD_RAID_MARKER_ORDER[3]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_MOON]		= WORLD_RAID_MARKER_ORDER[4]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_TRIANGLE] 	= WORLD_RAID_MARKER_ORDER[5]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_DIAMOND] 	= WORLD_RAID_MARKER_ORDER[6]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_CIRCLE] 	= WORLD_RAID_MARKER_ORDER[7]
WORLD_RAID_MARKER_ASSOCIATION[MARK_TYPE_STAR] 		= WORLD_RAID_MARKER_ORDER[8]

local RAID_MANAGER_CACHE = C_Cache("SIRUS_RAID_MANAGER_CACHE", true)

function PlaceRaidMarker( markerIndex )
	if not markerIndex then
		return
	end

	if ((IsRaidLeader() or IsRaidOfficer()) and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers() > 0) then
		local spellID = WORLD_RAID_MARKER_ORDER[markerIndex][2]

		if spellID then
			CastSpellByID(spellID)
		end
	end
end

function ClearRaidMarker( markerIndex )
	if ((IsRaidLeader() or IsRaidOfficer()) and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers() > 0) then
		if not markerIndex then
			SendServerMessage("ACMSG_GROUP_MARK_REMOVE", -1)
		else
			local markerID = WORLD_RAID_MARKER_ORDER[markerIndex][1]
			SendServerMessage("ACMSG_GROUP_MARK_REMOVE", markerID)
		end
	end
end

function CompactRaidFrameManager_OnLoad( self, ... )
	self:RegisterEvent("RAID_TARGET_UPDATE")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("VARIABLES_LOADED")

	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
end

function CompactRaidFrameManager_OnEvent( self, event, ... )
	if event == "PLAYER_ENTERING_WORLD" then
		CompactRaidFrameManager_UpdateRaidIcons()
		CompactRaidFrameManager_UpdateLeaderButton()
		CompactRaidFrameManager_UpdateWindow()
	elseif event == "VARIABLES_LOADED" then
		self.offsetY = RAID_MANAGER_CACHE:Get("OFFSET_Y", -140)
		CompactRaidFrameManager_Collapse(self, true)
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "PARTY_LEADER_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		CompactRaidFrameManager_UpdateLeaderButton()
		CompactRaidFrameManager_UpdateWindow()
	elseif event == "PLAYER_TARGET_CHANGED" or event == "RAID_TARGET_UPDATE" then
		CompactRaidFrameManager_UpdateRaidIcons()
	end
end

function CompactRaidFrameManager_Toggle(self)
	if not CompactRaidFrameManager.playingExpandAnimation or not CompactRaidFrameManager.playingCollapseAnimation then
		if ( self.collapsed ) then
			CompactRaidFrameManager_Expand(self)
		else
			CompactRaidFrameManager_Collapse(self)
		end
	end
end

function CompactRaidFrameManager_Expand(self, forced)
	self.collapsed = false
	if forced then
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -7, self.offsetY)
	else
		self.elapsed = 0
		self.offset = 0
		self.playingExpandAnimation = true
		self.displayFrame.AnimOut:Play()
	end
	self.toggleButton:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
end

function CompactRaidFrameManager_Collapse(self, forced)
	self.collapsed = true
	if forced then
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -182, self.offsetY)
	else
		self.elapsed = 0
		self.offset = 0
		self.playingCollapseAnimation = true
		self.displayFrame.AnimIn:Play()
	end
	self.toggleButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 1)
end

function CompactRaidFrameManager_UpdateRaidIcons()
	local unit = "target"
	local unitTarget = (UnitExists(unit) and not UnitPlayerOrPetInParty(unit) and not UnitPlayerOrPetInRaid(unit)) and (UnitIsPlayer(unit) and (not UnitCanCooperate("player", unit) and not UnitIsUnit(unit, "player")))

	for i = 1, NUM_RAID_ICONS do
		local button = _G["CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarker"..i]
		if ( not UnitExists(unit) or unitTarget == true or button:GetID() == GetRaidTargetIndex(unit) ) then
			button:GetNormalTexture():SetDesaturated(true)
			button:SetAlpha(0.7)
			button:Disable()
		else
			button:GetNormalTexture():SetDesaturated(false)
			button:SetAlpha(1)
			button:Enable()
		end
	end

	local removeButton = CompactRaidFrameManagerDisplayFrameRaidMarkersRaidMarkerRemove
	if ( not GetRaidTargetIndex(unit) ) then
		removeButton:GetNormalTexture():SetDesaturated(true)
		removeButton:Disable()
	else
		removeButton:GetNormalTexture():SetDesaturated(false)
		removeButton:Enable()
	end
end

function CompactRaidFrameManager_UpdateLeaderButton()
	if ( GetNumRaidMembers() == 0 ) then
		if ( UnitExists("party1") and IsPartyLeader() and UnitLevel("player") >= 10 ) then
			CompactRaidFrameManager.displayFrame.convertToRaid:Enable()
		else
			CompactRaidFrameManager.displayFrame.convertToRaid:Disable()
		end
	else
		CompactRaidFrameManager.displayFrame.convertToRaid:Disable()
	end

	local enabledLeaderButton = ((IsRaidLeader() or IsRaidOfficer()) and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers() > 0)
	CompactRaidFrameManager.displayFrame.readyCheckButton:SetEnabled(enabledLeaderButton)
	CompactRaidFrameManager.displayFrame.RaidWorldMarkerButton:SetEnabled(enabledLeaderButton)
	CompactRaidFrameManager.displayFrame.RaidWorldMarkerButton:GetNormalTexture():SetDesaturated(enabledLeaderButton)
	CompactRaidFrameManager.displayFrame.RaidWorldMarkerButton:GetNormalTexture():SetAlpha(enabledLeaderButton and 1 or 0.5)
end

function CompactRaidFrameManager_UpdateWindow()
	local raidMembers = GetNumRaidMembers()
	local partyMembers = GetNumPartyMembers()

	if raidMembers > 0 then
		CompactRaidFrameManager.displayFrame.label:SetText(RAID_MEMBERS)
		CompactRaidFrameManager.displayFrame.memberCountLabel:SetFormattedText("%s/40", raidMembers)
	else
		CompactRaidFrameManager.displayFrame.label:SetText(PARTY_MEMBERS)
		CompactRaidFrameManager.displayFrame.memberCountLabel:SetFormattedText("%s/5", partyMembers + 1)
	end

	CompactRaidFrameManager:SetShown(raidMembers > 0 or partyMembers > 0)

	if raidMembers == 0 and partyMembers == 0 then
		EventHandler:ASMSG_GROUP_MARK_LIST("0,0,0,0,0,0,0")
	end
end

local function RaidWorldMarker_OnClick(self, arg1, arg2, checked)
	if ( checked ) then
		ClearRaidMarker(arg1)
	else
		PlaceRaidMarker(arg1)
	end
end

local function ClearRaidWorldMarker_OnClick(self, arg1, arg2, checked)
	ClearRaidMarker()
end

function IsRaidMarkerActive( index )
	local markStorage = RAID_MANAGER_CACHE:Get("MARK_CHECKED", nil)

	if markStorage then
		return markStorage[index]
	end
end

function CRFManager_RaidWorldMarkerDropDown_Update()
	local info = UIDropDownMenu_CreateInfo()

	info.isNotRadio = true

	for i=1, NUM_WORLD_RAID_MARKERS do
		local index = WORLD_RAID_MARKER_ORDER[i][1]
		info.text = string.format("(%d) %s", i, _G["WORLD_MARKER"..index])
		info.func = RaidWorldMarker_OnClick
		info.checked = IsRaidMarkerActive(index)
		info.arg1 = i
		UIDropDownMenu_AddButton(info)
	end

	info.notCheckable = 1
	info.text = REMOVE_WORLD_MARKERS
	info.func = ClearRaidWorldMarker_OnClick
	info.arg1 = nil
	UIDropDownMenu_AddButton(info)
end

function CompactRaidFrameManager_StartDragResizing()
	local point, relativeTo, relativePoint, xOffset, yOffset = CompactRaidFrameManager:GetPoint()
	local _, statrY = GetCursorPosition()

	CompactRaidFrameManager.resizingTicker = C_Timer:NewTicker(0, function()
		local x, y = GetCursorPosition()
		local offsetY = yOffset - (statrY - y)

		if offsetY < -20 and offsetY > -550 then
			if CompactRaidFrameManager.offsetY ~= offsetY then
				RAID_MANAGER_CACHE:Set("OFFSET_Y", offsetY)
			end

			CompactRaidFrameManager.offsetY = offsetY
		end

		CompactRaidFrameManager:ClearAllPoints()
		CompactRaidFrameManager:SetPoint(point, relativeTo, relativePoint, xOffset, CompactRaidFrameManager.offsetY)

		if not CompactRaidFrameManager.resizer.IsMouseButtonDown then
			CompactRaidFrameManager_StopDragResizing()
		end
	end)
end

function CompactRaidFrameManager_StopDragResizing()
	if CompactRaidFrameManager.resizingTicker then
		CompactRaidFrameManager.resizingTicker:Cancel()
		CompactRaidFrameManager.resizingTicker = nil
	end
end

local animationTime = 0.500
local raidFrameManagerDefaultOffset = 175
function CompactRaidFrameManager_OnUpdate( self, elapsed, ... )
	if self.playingExpandAnimation or self.playingCollapseAnimation then
		self.elapsed = math.min(self.elapsed + elapsed, animationTime)
		local easing = inSine(self.elapsed, 0, raidFrameManagerDefaultOffset, animationTime)
		local offsetX

		if self.playingExpandAnimation then
			offsetX = (raidFrameManagerDefaultOffset) - easing
		else
			offsetX = easing
		end

		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -(offsetX + 7), self.offsetY)

		if self.elapsed >= animationTime then
			self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self.playingExpandAnimation and -7 or -182, self.offsetY)

			self.playingExpandAnimation = false
			self.playingCollapseAnimation = false
			self.elapsed = 0
		end
	end
end

function EventHandler:ASMSG_GROUP_MARK_LIST( msg )
	local markStorage = C_Split(msg, ",")
	local markCheckedBuffer = {}

	if markStorage and #markStorage > 0 then
		for i = 1, #markStorage do
			local show = tonumber(markStorage[i]) == 1
			markCheckedBuffer[i - 1] = show
		end
	end

	RAID_MANAGER_CACHE:Set("MARK_CHECKED", markCheckedBuffer)
end