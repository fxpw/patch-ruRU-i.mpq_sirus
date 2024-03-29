local FrameObj = CreateFrame("Frame")
local Frame = getmetatable(FrameObj)
local Button = getmetatable(CreateFrame("Button"))
local Slider = getmetatable(CreateFrame("Slider"))
local StatusBar = getmetatable(CreateFrame("StatusBar"))
local SimpleHTML = getmetatable(CreateFrame("SimpleHTML"))
local ScrollFrame = getmetatable(CreateFrame("ScrollFrame"))
local CheckButton = getmetatable(CreateFrame("CheckButton"))
local Model = getmetatable(CreateFrame("Model"))
local GameTooltip, PlayerModel, DressUpModel, TabardModel

local EditBox = CreateFrame("EditBox")
EditBox:Hide()
EditBox = getmetatable(EditBox)

if not IsOnGlueScreen() then
	GameTooltip = getmetatable(CreateFrame("GameTooltip"))
	PlayerModel = getmetatable(CreateFrame("PlayerModel"))
	DressUpModel = getmetatable(CreateFrame("DressUpModel"))
	TabardModel = getmetatable(CreateFrame("TabardModel"))
end

local Texture = getmetatable(FrameObj:CreateTexture())
local FontString = getmetatable(FrameObj:CreateFontString())

-- local Cooldown = getmetatable(CreateFrame("Cooldown"))
-- local ColorSelect = getmetatable(CreateFrame("ColorSelect"))
-- local MessageFrame = getmetatable(CreateFrame("MessageFrame"))
-- local Model = getmetatable(CreateFrame("Model"))
-- local Minimap = getmetatable(CreateFrame("Minimap"))

local function nop() end

local function Method_SetShown( self, ... )
	if ... then
		self:Show()
	else
		self:Hide()
	end
end

local function Method_SetEnabled( self, ... )
	if ... then
		self:Enable()
	else
		self:Disable()
	end
end

local SECONDS_PER_DAY = 86400
local function Method_SetRemainingTime(self, seconds, daysformat)
	if type(seconds) ~= "number" then
		self:SetText("")
		return
	end

	if daysformat then
		if seconds >= SECONDS_PER_DAY then
			self:SetFormattedText(D_DAYS_FULL, math.floor(seconds / SECONDS_PER_DAY))
		else
			self:SetText(date("!%X", seconds))
		end
	elseif seconds and seconds >= 0 then
		if seconds >= SECONDS_PER_DAY then
			local days = string.format(DAY_ONELETTER_ABBR_SHORT, math.floor(seconds / SECONDS_PER_DAY))
			self:SetFormattedText("%s %s", days, date("!%X", seconds % SECONDS_PER_DAY))
		else
			self:SetText(date("!%X", seconds))
		end
	else
		self:SetText("")
	end
end

local function Method_SetSubTexCoord( self, left, right, top, bottom )
    local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = self:GetTexCoord()

    local leftedge = ULx
    local rightedge = URx
    local topedge = ULy
    local bottomedge = LLy

    local width  = rightedge - leftedge
    local height = bottomedge - topedge

    leftedge = ULx + width * left
    topedge  = ULy  + height * top
    rightedge = math.max(rightedge * right, ULx)
    bottomedge = math.max(bottomedge * bottom, ULy)

    ULx = leftedge
    ULy = topedge
    LLx = leftedge
    LLy = bottomedge
    URx = rightedge
    URy = topedge
    LRx = rightedge
    LRy = bottomedge

    self:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

local function Method_SetTransmogrifyItem(self, transmogID, hasPending, hasUndo)
	local lastTransmogText, transmogTextHeight;

	if not self.TransmogText1:IsShown() and not self.TransmogText2:IsShown() then
		if hasUndo then
			self.TransmogText1:Show();
			self.TransmogText1:SetText(TRANSMOGRIFY_TOOLTIP_REVERT);

			lastTransmogText = self.TransmogText1;
			transmogTextHeight = self.TransmogText1:GetHeight() + 2;
		elseif transmogID then
			local name = GetItemInfo(transmogID);
			if name then
				self.TransmogText1:Show();
				self.TransmogText2:Show();
				if hasPending then
					self.TransmogText1:SetText(WILL_BE_TRANSMOGRIFIED_HEADER);
				else
					self.TransmogText1:SetText(TRANSMOGRIFIED_HEADER);
				end
				self.TransmogText2:SetText(name);

				lastTransmogText = self.TransmogText2;
				transmogTextHeight = (self.TransmogText1:GetHeight() + self.TransmogText2:GetHeight()) + 4;
			end
		end
	end

	if lastTransmogText and transmogTextHeight then
		self.TextLeft2:ClearAllPoints();
		self.TextLeft2:SetPoint("TOPLEFT", lastTransmogText, "BOTTOMLEFT", 0, -2);

		self:SetHeight(self:GetHeight() + transmogTextHeight);

		Hook:FireEvent("TRANSMOGRIFY_ITEM_UPDATE", self, transmogID);
	end
end

local function Method_SetPortrait( self, displayID )
	local portrait = "Interface\\PORTRAITS\\Portrait_model_"..tonumber(displayID)
	self:SetTexture(portrait)
end

local Panels = {"CollectionsJournal", "EncounterJournal"}
local function Method_FixOpenPanel( self )
	-- Хак, в связи с странностями работы системы позиционирования.
	-- Необходим для корректной работы системы Профессий.
	for i = 1, #Panels do
		local panel = _G[Panels[i]]

		if panel then
			if panel:IsShown() then
				HideUIPanel(panel)
				ShowUIPanel(self)
				return true
			end
		end
	end
end

local CONST_ATLAS_WIDTH			= 1
local CONST_ATLAS_HEIGHT		= 2
local CONST_ATLAS_LEFT			= 3
local CONST_ATLAS_RIGHT			= 4
local CONST_ATLAS_TOP			= 5
local CONST_ATLAS_BOTTOM		= 6
local CONST_ATLAS_TILESHORIZ	= 7
local CONST_ATLAS_TILESVERT		= 8
local CONST_ATLAS_TEXTUREPATH	= 9

local S_ATLAS_STORAGE = S_ATLAS_STORAGE

local function Method_SetAtlas( self, atlasName, useAtlasSize, filterMode )
	if type(self) ~= "table" then
		error("Attempt to find 'this' in non-table object (used '.' instead of ':' ?)", 3)
	elseif type(atlasName) ~= "string" then
		error(string.format("Usage: %s:SetAtlas(\"atlasName\"[, useAtlasSize])", self:GetName() or tostring(self)), 3)
	end

	local atlas = S_ATLAS_STORAGE[atlasName]
	if not atlas then
		error(string.format("%s:SetAtlas: Atlas %s does not exist", self:GetName() or tostring(self), atlasName), 3)
	end

	self:SetTexture(atlas[CONST_ATLAS_TEXTUREPATH] or "", atlas[CONST_ATLAS_TILESHORIZ], atlas[CONST_ATLAS_TILESVERT])

	if useAtlasSize then
		self:SetWidth(atlas[CONST_ATLAS_WIDTH])
		self:SetHeight(atlas[CONST_ATLAS_HEIGHT])
	end

	self:SetTexCoord(atlas[CONST_ATLAS_LEFT], atlas[CONST_ATLAS_RIGHT], atlas[CONST_ATLAS_TOP], atlas[CONST_ATLAS_BOTTOM])

	self:SetHorizTile(atlas[CONST_ATLAS_TILESHORIZ])
	self:SetVertTile(atlas[CONST_ATLAS_TILESVERT])
end

local function Method_SmoothSetValue( self, value )
	-- local smoothFrame = self._SmoothUpdateFrame or CreateFrame("Frame")
	-- self._SmoothUpdateFrame =  smoothFrame
end

local function Method_SetUnit( self, unit, isCustomPosition, positionData )
	local objectType = self:GetObjectType()

	if isCustomPosition then
		if objectType == "TabardModel" then
			self:SetPosition(0, 0, 0)
		else
			self:SetPosition(1, 1, 1)
		end
	end

	self:__SetUnit(unit)

	if isCustomPosition then
		local unitSex = UnitSex(unit) or 2
		local _, unitRace = UnitRace(unit)
		local positionStorage = positionData or (objectType == "TabardModel" and TABARDMODEL_CAMERA_POSITION or DRESSUPMODEL_CAMERA_POSITION)
		local data = positionStorage[string.format("%s%d", unitRace or "Human", unitSex)]

		if data then
			local positionX, positionY, positionZ = unpack(data)

			self.positionX = positionX
			self.positionY = positionY
			self.positionZ = positionZ
			self:SetPosition(positionX, positionY, positionZ)

			if data[4] then
				self:SetFacing(math.rad(data[4]))
			end
		end
	end
end

function Method_SetDesaturated( self, toggle, color )
	if toggle then
		self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	else
		if color then
			self:SetTextColor(color.r, color.g, color.b)
		else
			self:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	end
end

function Method_SetParentArray( self, arrayName, element, setInSelf)
	local parent = not setInSelf and self:GetParent() or self

    if not parent[arrayName] then
		parent[arrayName] = {}
    end

    table.insert(parent[arrayName], element or self)
end

function Method_ClearAndSetPoint( self, ... )
	self:ClearAllPoints()
	self:SetPoint(...)
end

function Method_GetScaledRect(self)
	local left, bottom, width, height = self:GetRect()
	if left and bottom and width and height then
		local scale = self:GetEffectiveScale()
		return left * scale, bottom * scale, width * scale, height * scale
	end
end

function Method_EditBox_IsEnabled(self)
	return self.__ext_Disabled ~= true
end

function Method_EditBox_Enabled(self)
	if self.__ext_mouseEnabled then
		self:EnableMouse(true)
	end
	if self.__ext_autoFocus then
		self:SetAutoFocus(true)
		self:SetFocus()
		self:HighlightText(0, 0)
	end
	self.SetFocus = nil
	self.__ext_Disabled = nil
	self.__ext_autoFocus = nil
	self.__ext_mouseEnabled = nil
end

function Method_EditBox_Disable(self)
	if not self.__ext_Disabled then
		self.__ext_autoFocus = self:IsAutoFocus() == 1
		self.__ext_mouseEnabled = self:IsMouseEnabled() == 1
	end
	self:SetAutoFocus(false)
	self:ClearFocus()
	self:EnableMouse(false)
	self.SetFocus = nop
	self.__ext_Disabled = true
end

local RegisterCustomEvent = RegisterCustomEvent
local UnregisterCustomEvent = UnregisterCustomEvent

function Method_RegisterCustomEvent(self, event)
	RegisterCustomEvent(self, event)
end

function Method_UnregisterCustomEvent(self, event)
	UnregisterCustomEvent(self, event)
end

function Method_IsTruncated(fontString)
	local stringWidth = fontString:GetStringWidth();
	local width = fontString:GetWidth();
	fontString:SetWidth(width + 10000);
	local isTruncated = fontString:GetStringWidth() ~= stringWidth;
	fontString:SetWidth(width);
	return isTruncated;
 end

function Method_SetDisabled( self, ... )
	if ... then
		self:Disable()
	else
		self:Enable()
	end
end

local function Method_SetNormalAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetNormalTexture()
	if not texture then
		self:SetNormalTexture("")
		texture = self:GetNormalTexture()
	end
	Method_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Method_SetPushedAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetPushedTexture()
	if not texture then
		self:SetPushedTexture("")
		texture = self:GetPushedTexture()
	end
	Method_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Method_SetDisabledAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetDisabledTexture()
	if not texture then
		self:SetDisabledTexture("")
		texture = self:GetDisabledTexture()
	end
	Method_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Method_SetHighlightAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetHighlightTexture()
	if not texture then
		self:SetHighlightTexture("")
		texture = self:GetHighlightTexture()
	end
	Method_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Method_SetCheckedAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetCheckedTexture()
	if not texture then
		self:SetCheckedTexture("")
		texture = self:GetCheckedTexture()
	end
	Method_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Method_ClearNormalTexture(self)
	self:SetNormalTexture("")
end

local function Method_ClearPushedTexture(self)
	self:SetPushedTexture("")
end

local function Method_ClearDisabledTexture(self)
	self:SetDisabledTexture("")
end

local function Method_ClearHighlightTexture(self)
	self:SetHighlightTexture("")
end

-- Frame Method
function Frame.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Frame.__index:FixOpenPanel( ... ) Method_FixOpenPanel( self, ... ) end
function Frame.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function Frame.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function Frame.__index:GetScaledRect() return Method_GetScaledRect(self) end
function Frame.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function Frame.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- Button Method
function Button.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Button.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function Button.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function Button.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function Button.__index:SetNormalAtlas(atlasName, useAtlasSize, filterMode) Method_SetNormalAtlas(self, atlasName, useAtlasSize, filterMode) end
function Button.__index:SetPushedAtlas(atlasName, useAtlasSize, filterMode) Method_SetPushedAtlas(self, atlasName, useAtlasSize, filterMode) end
function Button.__index:SetDisabledAtlas(atlasName, useAtlasSize, filterMode) Method_SetDisabledAtlas(self, atlasName, useAtlasSize, filterMode) end
function Button.__index:SetHighlightAtlas(atlasName, useAtlasSize, filterMode) Method_SetHighlightAtlas(self, atlasName, useAtlasSize, filterMode) end
function Button.__index:ClearClearNormalTexture() Method_ClearNormalTexture(self) end
function Button.__index:ClearPushedTexture() Method_ClearPushedTexture(self) end
function Button.__index:ClearDisabledTexture() Method_ClearDisabledTexture(self) end
function Button.__index:ClearHighlightTexture() Method_ClearHighlightTexture(self) end
function Button.__index:GetScaledRect() return Method_GetScaledRect(self) end
function Button.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function Button.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- Slider Method
function Slider.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Slider.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function Slider.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function Slider.__index:GetScaledRect() return Method_GetScaledRect(self) end
function Slider.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function Slider.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- Texture Method
function Texture.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Texture.__index:SetSubTexCoord( left, right, top, bottom ) Method_SetSubTexCoord( self, left, right, top, bottom ) end
function Texture.__index:SetPortrait( displayID ) Method_SetPortrait( self, displayID ) end
function Texture.__index:SetAtlas( atlasName, useAtlasSize, filterMode ) Method_SetAtlas( self, atlasName, useAtlasSize, filterMode ) end
function Texture.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function Texture.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function Texture.__index:GetEffectiveScale() return self:GetParent():GetEffectiveScale() end
function Texture.__index:GetScaledRect() return Method_GetScaledRect(self) end

-- StatusBar Method
function StatusBar.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function StatusBar.__index:SmoothSetValue( value ) Method_SmoothSetValue( self, value ) end
function StatusBar.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function StatusBar.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function StatusBar.__index:GetScaledRect() return Method_GetScaledRect(self) end
function StatusBar.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function StatusBar.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- SimpleHTML Method
function SimpleHTML.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function SimpleHTML.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function SimpleHTML.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function SimpleHTML.__index:GetScaledRect() return Method_GetScaledRect(self) end
function SimpleHTML.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function SimpleHTML.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- FontString Method
function FontString.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function FontString.__index:SetRemainingTime( time, daysformat ) Method_SetRemainingTime( self, time, daysformat ) end
function FontString.__index:SetDesaturated( toggle, color ) Method_SetDesaturated( self, toggle, color ) end
function FontString.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function FontString.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function FontString.__index:GetEffectiveScale() return self:GetParent():GetEffectiveScale() end
function FontString.__index:GetScaledRect() return Method_GetScaledRect(self) end
function FontString.__index:IsTruncated() return Method_IsTruncated(self) end

-- ScrollFrame Method
function ScrollFrame.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function ScrollFrame.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function ScrollFrame.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function ScrollFrame.__index:GetScaledRect() return Method_GetScaledRect(self) end
function ScrollFrame.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function ScrollFrame.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- CheckButton Method
function CheckButton.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function CheckButton.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function CheckButton.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
function CheckButton.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function CheckButton.__index:SetNormalAtlas(atlasName, useAtlasSize, filterMode) Method_SetNormalAtlas(self, atlasName, useAtlasSize, filterMode) end
function CheckButton.__index:SetPushedAtlas(atlasName, useAtlasSize, filterMode) Method_SetPushedAtlas(self, atlasName, useAtlasSize, filterMode) end
function CheckButton.__index:SetDisabledAtlas(atlasName, useAtlasSize, filterMode) Method_SetDisabledAtlas(self, atlasName, useAtlasSize, filterMode) end
function CheckButton.__index:SetHighlightAtlas(atlasName, useAtlasSize, filterMode) Method_SetHighlightAtlas(self, atlasName, useAtlasSize, filterMode) end
function CheckButton.__index:SetCheckedAtlas(atlasName, useAtlasSize, filterMode) Method_SetCheckedAtlas(self, atlasName, useAtlasSize, filterMode) end
function CheckButton.__index:ClearClearNormalTexture() Method_ClearNormalTexture(self) end
function CheckButton.__index:ClearPushedTexture() Method_ClearPushedTexture(self) end
function CheckButton.__index:ClearDisabledTexture() Method_ClearDisabledTexture(self) end
function CheckButton.__index:ClearHighlightTexture() Method_ClearHighlightTexture(self) end
function CheckButton.__index:GetScaledRect() return Method_GetScaledRect(self) end
function CheckButton.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function CheckButton.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end
function CheckButton.__index:SetDisabled( ... ) Method_SetDisabled( self, ... ) end

-- Model
function Model.__index:SetShown( ... ) Method_SetShown( self, ... ) end
function Model.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
function Model.__index:GetScaledRect() return Method_GetScaledRect(self) end
function Model.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function Model.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

-- EditBox
function EditBox.__index:SetShown(...) Method_SetShown(self, ...) end
function EditBox.__index:SetEnabled( ... ) Method_SetEnabled( self, ... ) end
function EditBox.__index:IsEnabled( ... ) Method_EditBox_IsEnabled( self, ... ) end
function EditBox.__index:Enable( ... ) Method_EditBox_Enabled( self, ... ) end
function EditBox.__index:Disable( ... ) Method_EditBox_Disable( self, ... ) end
function EditBox.__index:ClearAndSetPoint(...) Method_ClearAndSetPoint(self, ...) end
function EditBox.__index:GetScaledRect() return Method_GetScaledRect(self) end
function EditBox.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
function EditBox.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

if not IsOnGlueScreen() then
	-- GameTooltip Method
	function GameTooltip.__index:SetTransmogrifyItem(transmogID, hasPending, hasUndo) Method_SetTransmogrifyItem(self, transmogID, hasPending, hasUndo) end
	function GameTooltip.__index:GetScaledRect() return Method_GetScaledRect(self) end
	function GameTooltip.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
	function GameTooltip.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

	-- PlayerModel Method
	function PlayerModel.__index:SetShown( ... ) Method_SetShown( self, ... ) end
	function PlayerModel.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
	function PlayerModel.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
	function PlayerModel.__index:GetScaledRect() return Method_GetScaledRect(self) end
	function PlayerModel.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
	function PlayerModel.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

	-- DressUpModel
	DressUpModel.__index.__SetUnit = DressUpModel.__index.__SetUnit or DressUpModel.__index.SetUnit
	function DressUpModel.__index:SetUnit( ... ) Method_SetUnit( self, ... ) end
	function DressUpModel.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
	function DressUpModel.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
	function DressUpModel.__index:GetScaledRect() return Method_GetScaledRect(self) end
	function DressUpModel.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
	function DressUpModel.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end

	-- TabardModel
	TabardModel.__index.__SetUnit = TabardModel.__index.__SetUnit or TabardModel.__index.SetUnit
	function TabardModel.__index:SetUnit( ... ) Method_SetUnit( self, ... ) end
	function TabardModel.__index:SetParentArray( arrayName, element, setInSelf ) Method_SetParentArray( self, arrayName, element, setInSelf ) end
	function TabardModel.__index:ClearAndSetPoint( ... ) Method_ClearAndSetPoint( self, ... ) end
	function TabardModel.__index:GetScaledRect() return Method_GetScaledRect(self) end
	function TabardModel.__index:RegisterCustomEvent(event) return Method_RegisterCustomEvent(self, event) end
	function TabardModel.__index:UnregisterCustomEvent(event) return Method_UnregisterCustomEvent(self, event) end
end