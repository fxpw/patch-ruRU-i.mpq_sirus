local function getObjTypeMeta(objType)
	local obj = CreateFrame(objType)
	obj:Hide()
	return getmetatable(obj).__index, obj
end

local FrameMeta, FrameObj = getObjTypeMeta("Frame")
local FontStringMeta = getmetatable(FrameObj:CreateFontString()).__index
local TextureMeta = getmetatable(FrameObj:CreateTexture()).__index

local ButtonMeta = getObjTypeMeta("Button")
local CheckButtonMeta = getObjTypeMeta("CheckButton")
local EditBoxMeta = getObjTypeMeta("EditBox")
local SimpleHTMLMeta = getObjTypeMeta("SimpleHTML")
local SliderMeta = getObjTypeMeta("Slider")
local StatusBarMeta = getObjTypeMeta("StatusBar")
local ScrollFrameMeta = getObjTypeMeta("ScrollFrame")
local MessageFrameMeta = getObjTypeMeta("MessageFrame")
local ScrollingMessageFrameMeta = getObjTypeMeta("ScrollingMessageFrame")
local ModelMeta = getObjTypeMeta("Model")
--local ColorSelectMeta = createAndGetMeta("ColorSelect")
--local MovieFrameMeta = createAndGetMeta("MovieFrame")

local GameTooltipMeta, PlayerModelMeta, DressUpModelMeta, TabardModelMeta, ModelFFXMeta

if IsOnGlueScreen() then
	ModelFFXMeta = getObjTypeMeta("ModelFFX")
else
	GameTooltipMeta = getObjTypeMeta("GameTooltip")
	PlayerModelMeta = getObjTypeMeta("PlayerModel")
	DressUpModelMeta = getObjTypeMeta("DressUpModel")
	TabardModelMeta = getObjTypeMeta("TabardModel")

--	local CooldownMeta = createAndGetMeta("Cooldown")
--	local MinimapMeta = createAndGetMeta("Minimap")
--	local TaxiRouteFrameMeta = createAndGetMeta("TaxiRouteFrame")
--	local QuestPOIFrameMeta = createAndGetMeta("QuestPOIFrame")
--	local WorldFrameMeta = createAndGetMeta("WorldFrame")
end

local function nop() end

local function ScriptRegion_SetShown(self, show)
	if show then
		self:Show()
	else
		self:Hide()
	end
end

local function ScriptRegion_GetScaledRect(self)
	local left, bottom, width, height = self:GetRect()
	if left and bottom and width and height then
		local scale = self:GetEffectiveScale()
		return left * scale, bottom * scale, width * scale, height * scale
	end
end

local function ScriptRegion_IsMouseOverEx(self, ignoreVisibility)
	if ignoreVisibility or self:IsVisible() then
		local l, r, t, b = self:GetHitRectInsets()
		return self:IsMouseOver(-t, b, l, -r)
	end
	return false
end

local function ScriptRegionResizing_ClearAndSetPoint(self, ...)
	self:ClearAllPoints()
	self:SetPoint(...)
end

local function Region_GetEffectiveScale(self)
	return self:GetParent():GetEffectiveScale()
end

local function LayoutFrame_SetParentArray(self, arrayName, element, setInSelf)
	local parent = not setInSelf and self:GetParent() or self

	if not parent[arrayName] then
		parent[arrayName] = {}
	end

	table.insert(parent[arrayName], element or self)
end

local RegisterCustomEvent = RegisterCustomEvent
local UnregisterCustomEvent = UnregisterCustomEvent

local function Frame_RegisterCustomEvent(self, event)
	RegisterCustomEvent(self, event)
end

local function Frame_UnregisterCustomEvent(self, event)
	UnregisterCustomEvent(self, event)
end

local function FontString_IsTruncated(fontString)
	local stringWidth = fontString:GetStringWidth()
	local width = fontString:GetWidth()
	fontString:SetWidth(width + 10000)
	local isTruncated = fontString:GetStringWidth() ~= stringWidth
	fontString:SetWidth(width)
	if not isTruncated then
		local stringHeight = fontString:GetStringHeight()
		local height = fontString:GetHeight()
		fontString:SetHeight(height + 10000)
		isTruncated = fontString:GetStringHeight() ~= stringHeight
		fontString:SetHeight(height)
	end
	return isTruncated
end

local function FontString_SetDesaturated(self, toggle, color)
	if toggle then
		self:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	else
		if type(color) == "table" then
			self:SetTextColor(color.r, color.g, color.b)
		else
			self:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
	end
end

local SECONDS_PER_DAY = 86400
local function FontString_SetRemainingTime(self, seconds, daysformat)
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
	elseif seconds >= SECONDS_PER_DAY then
		local days = string.format(DAY_ONELETTER_ABBR_SHORT, math.floor(seconds / SECONDS_PER_DAY))
		self:SetFormattedText("%s %s", days, date("!%X", seconds % SECONDS_PER_DAY))
	elseif seconds >= 0 then
		self:SetText(date("!%X", seconds))
	else
		self:SetText("")
	end
end

local function Texture_SetSubTexCoord(self, left, right, top, bottom)
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

local ATLAS_FIELD_WIDTH			= 1
local ATLAS_FIELD_HEIGHT		= 2
local ATLAS_FIELD_LEFT			= 3
local ATLAS_FIELD_RIGHT			= 4
local ATLAS_FIELD_TOP			= 5
local ATLAS_FIELD_BOTTOM		= 6
local ATLAS_FIELD_TILESHORIZ	= 7
local ATLAS_FIELD_TILESVERT		= 8
local ATLAS_FIELD_TEXTUREPATH	= 9

local S_ATLAS_STORAGE = S_ATLAS_STORAGE

local function Texture_SetAtlas(self, atlasName, useAtlasSize, filterMode)
	if type(self) ~= "table" then
		error("Attempt to find 'this' in non-table object (used '.' instead of ':' ?)", 3)
	elseif type(atlasName) ~= "string" then
		error(string.format("Usage: %s:SetAtlas(\"atlasName\"[, useAtlasSize])", self:GetName() or tostring(self)), 3)
	end

	local atlas = S_ATLAS_STORAGE[atlasName]
	if not atlas then
		error(string.format("%s:SetAtlas: Atlas %s does not exist", self:GetName() or tostring(self), atlasName), 3)
	end

	local success = self:SetTexture(atlas[ATLAS_FIELD_TEXTUREPATH] or "", atlas[ATLAS_FIELD_TILESHORIZ], atlas[ATLAS_FIELD_TILESVERT])
	if success then
		if useAtlasSize then
			self:SetWidth(atlas[ATLAS_FIELD_WIDTH])
			self:SetHeight(atlas[ATLAS_FIELD_HEIGHT])
		end

		self:SetTexCoord(atlas[ATLAS_FIELD_LEFT], atlas[ATLAS_FIELD_RIGHT], atlas[ATLAS_FIELD_TOP], atlas[ATLAS_FIELD_BOTTOM])

		self:SetHorizTile(atlas[ATLAS_FIELD_TILESHORIZ])
		self:SetVertTile(atlas[ATLAS_FIELD_TILESVERT])
	end

	return success
end

local function Texture_SetPortrait(self, displayID)
	local portrait = strconcat("Interface\\PORTRAITS\\Portrait_model_", tonumber(displayID))
	local success = self:SetTexture(portrait)
	return success
end

local function Button_SetEnabled(self, enabled)
	if enabled then
		self:Enable()
	else
		self:Disable()
	end
end

local function Button_SetNormalAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetNormalTexture()
	if not texture then
		self:SetNormalTexture("")
		texture = self:GetNormalTexture()
	end
	Texture_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Button_SetPushedAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetPushedTexture()
	if not texture then
		self:SetPushedTexture("")
		texture = self:GetPushedTexture()
	end
	Texture_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Button_SetDisabledAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetDisabledTexture()
	if not texture then
		self:SetDisabledTexture("")
		texture = self:GetDisabledTexture()
	end
	Texture_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Button_SetHighlightAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetHighlightTexture()
	if not texture then
		self:SetHighlightTexture("")
		texture = self:GetHighlightTexture()
	end
	Texture_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function Button_ClearNormalTexture(self)
	self:SetNormalTexture("")
end

local function Button_ClearPushedTexture(self)
	self:SetPushedTexture("")
end

local function Button_ClearDisabledTexture(self)
	self:SetDisabledTexture("")
end

local function Button_ClearHighlightTexture(self)
	self:SetHighlightTexture("")
end

local function CheckButton_SetCheckedAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetCheckedTexture()
	if not texture then
		self:SetCheckedTexture("")
		texture = self:GetCheckedTexture()
	end
	Texture_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function CheckButton_SetDisabledCheckedAtlas(self, atlasName, useAtlasSize, filterMode)
	local texture = self:GetDisabledCheckedTexture()
	if not texture then
		self:SetDisabledCheckedTexture("")
		texture = self:GetDisabledCheckedTexture()
	end
	Texture_SetAtlas(texture, atlasName, useAtlasSize, filterMode)
end

local function CheckButton_ClearCheckedTexture(self)
	self:SetCheckedTexture("")
end

local function CheckButton_ClearDisabledCheckedTexture(self)
	self:SetDisabledCheckedTexture("")
end

local function EditBox_IsEnabled(self)
	return self.__ext_Disabled ~= true
end

local function EditBox_Enabled(self)
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

local function EditBox_Disable(self)
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

local function DressUpModel_SetUnit(self, unit, isCustomPosition, positionData)
	local objectType = self:GetObjectType()

	if isCustomPosition then
		if objectType == "TabardModel" then
			self:SetPosition(0, 0, 0)
		else
			self:SetPosition(1, 1, 1)
		end
	end

	self:SetUnitRaw(unit)

	if isCustomPosition then
		local unitSex = UnitSex(unit) or 2
		local _, unitRace = UnitRace(unit)
		local positionStorage = positionData or (objectType == "TabardModel" and TABARDMODEL_CAMERA_POSITION or DRESSUPMODEL_CAMERA_POSITION)
		local data = positionStorage[string.format("%s%d", unitRace or "Human", unitSex)]

		if data then
			local positionX, positionY, positionZ = unpack(data, 1, 3)
			self.basePositionOverrideX = positionX
			self.basePositionOverrideY = positionY
			self.basePositionOverrideZ = positionZ
			self.basePositionOverrideXasZ = true
			self:SetPosition(positionX or 0, positionY or 0, positionZ or 0)

			if data[4] then
				self:SetFacing(math.rad(data[4]))
			end
			return
		end
	end

	self.basePositionOverrideX = nil
	self.basePositionOverrideY = nil
	self.basePositionOverrideZ = nil
	self.basePositionOverrideXasZ = nil
end

FrameMeta.SetShown = ScriptRegion_SetShown
FrameMeta.GetScaledRect = ScriptRegion_GetScaledRect
FrameMeta.IsMouseOverEx = ScriptRegion_IsMouseOverEx
FrameMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
FrameMeta.SetParentArray = LayoutFrame_SetParentArray
FrameMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
FrameMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

FontStringMeta.SetShown = ScriptRegion_SetShown
FontStringMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
FontStringMeta.GetEffectiveScale = Region_GetEffectiveScale
FontStringMeta.SetParentArray = LayoutFrame_SetParentArray
FontStringMeta.GetScaledRect = ScriptRegion_GetScaledRect
FontStringMeta.IsTruncated = FontString_IsTruncated
FontStringMeta.SetDesaturated = FontString_SetDesaturated
FontStringMeta.SetRemainingTime = FontString_SetRemainingTime

TextureMeta.SetShown = ScriptRegion_SetShown
TextureMeta.GetScaledRect = ScriptRegion_GetScaledRect
TextureMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
TextureMeta.GetEffectiveScale = Region_GetEffectiveScale
TextureMeta.SetParentArray = LayoutFrame_SetParentArray
TextureMeta.SetSubTexCoord = Texture_SetSubTexCoord
TextureMeta.SetAtlas = Texture_SetAtlas
TextureMeta.SetPortrait = Texture_SetPortrait

ButtonMeta.SetShown = ScriptRegion_SetShown
ButtonMeta.GetScaledRect = ScriptRegion_GetScaledRect
ButtonMeta.IsMouseOverEx = ScriptRegion_IsMouseOverEx
ButtonMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
ButtonMeta.SetParentArray = LayoutFrame_SetParentArray
ButtonMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
ButtonMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
ButtonMeta.SetEnabled = Button_SetEnabled
ButtonMeta.SetNormalAtlas = Button_SetNormalAtlas
ButtonMeta.SetPushedAtlas = Button_SetPushedAtlas
ButtonMeta.SetDisabledAtlas = Button_SetDisabledAtlas
ButtonMeta.SetHighlightAtlas = Button_SetHighlightAtlas
ButtonMeta.ClearClearNormalTexture = Button_ClearNormalTexture
ButtonMeta.ClearPushedTexture = Button_ClearPushedTexture
ButtonMeta.ClearDisabledTexture = Button_ClearDisabledTexture
ButtonMeta.ClearHighlightTexture = Button_ClearHighlightTexture

CheckButtonMeta.SetShown = ScriptRegion_SetShown
CheckButtonMeta.IsMouseOverEx = ScriptRegion_IsMouseOverEx
CheckButtonMeta.GetScaledRect = ScriptRegion_GetScaledRect
CheckButtonMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
CheckButtonMeta.SetParentArray = LayoutFrame_SetParentArray
CheckButtonMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
CheckButtonMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
CheckButtonMeta.SetEnabled = Button_SetEnabled
CheckButtonMeta.SetNormalAtlas = Button_SetNormalAtlas
CheckButtonMeta.SetPushedAtlas = Button_SetPushedAtlas
CheckButtonMeta.SetDisabledAtlas = Button_SetDisabledAtlas
CheckButtonMeta.SetHighlightAtlas = Button_SetHighlightAtlas
CheckButtonMeta.SetCheckedAtlas = CheckButton_SetCheckedAtlas
CheckButtonMeta.SetDisabledCheckedAtlas = CheckButton_SetDisabledCheckedAtlas
CheckButtonMeta.ClearClearNormalTexture = Button_ClearNormalTexture
CheckButtonMeta.ClearPushedTexture = Button_ClearPushedTexture
CheckButtonMeta.ClearDisabledTexture = Button_ClearDisabledTexture
CheckButtonMeta.ClearHighlightTexture = Button_ClearHighlightTexture
CheckButtonMeta.ClearDisabledCheckedTexture = CheckButton_ClearCheckedTexture
CheckButtonMeta.ClearDisabledCheckedTexture = CheckButton_ClearDisabledCheckedTexture

EditBoxMeta.SetShown = ScriptRegion_SetShown
EditBoxMeta.GetScaledRect = ScriptRegion_GetScaledRect
EditBoxMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
EditBoxMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
EditBoxMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
EditBoxMeta.SetEnabled = Button_SetEnabled
EditBoxMeta.IsEnabled = EditBox_IsEnabled
EditBoxMeta.Enable = EditBox_Enabled
EditBoxMeta.Disable = EditBox_Disable

SimpleHTMLMeta.SetShown = ScriptRegion_SetShown
SimpleHTMLMeta.GetScaledRect = ScriptRegion_GetScaledRect
SimpleHTMLMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
SimpleHTMLMeta.SetParentArray = LayoutFrame_SetParentArray
SimpleHTMLMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
SimpleHTMLMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

SliderMeta.SetShown = ScriptRegion_SetShown
SliderMeta.GetScaledRect = ScriptRegion_GetScaledRect
SliderMeta.IsMouseOverEx = ScriptRegion_IsMouseOverEx
SliderMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
SliderMeta.SetParentArray = LayoutFrame_SetParentArray
SliderMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
SliderMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
SliderMeta.SetEnabled = Button_SetEnabled

StatusBarMeta.SetShown = ScriptRegion_SetShown
StatusBarMeta.GetScaledRect = ScriptRegion_GetScaledRect
StatusBarMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
StatusBarMeta.SetParentArray = LayoutFrame_SetParentArray
StatusBarMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
StatusBarMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

ScrollFrameMeta.SetShown = ScriptRegion_SetShown
ScrollFrameMeta.GetScaledRect = ScriptRegion_GetScaledRect
ScrollFrameMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
ScrollFrameMeta.SetParentArray = LayoutFrame_SetParentArray
ScrollFrameMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
ScrollFrameMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

MessageFrameMeta.SetShown = ScriptRegion_SetShown
MessageFrameMeta.GetScaledRect = ScriptRegion_GetScaledRect
MessageFrameMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
MessageFrameMeta.SetParentArray = LayoutFrame_SetParentArray
MessageFrameMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
MessageFrameMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

ScrollingMessageFrameMeta.SetShown = ScriptRegion_SetShown
ScrollingMessageFrameMeta.GetScaledRect = ScriptRegion_GetScaledRect
ScrollingMessageFrameMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
ScrollingMessageFrameMeta.SetParentArray = LayoutFrame_SetParentArray
ScrollingMessageFrameMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
ScrollingMessageFrameMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

ModelMeta.SetShown = ScriptRegion_SetShown
ModelMeta.GetScaledRect = ScriptRegion_GetScaledRect
ModelMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
ModelMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
ModelMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

if IsOnGlueScreen() then
	ModelFFXMeta.SetShown = ScriptRegion_SetShown
	ModelFFXMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
	ModelFFXMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
else
	GameTooltipMeta.GetScaledRect = ScriptRegion_GetScaledRect
	GameTooltipMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
	GameTooltipMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

	PlayerModelMeta.SetShown = ScriptRegion_SetShown
	PlayerModelMeta.GetScaledRect = ScriptRegion_GetScaledRect
	PlayerModelMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
	PlayerModelMeta.SetParentArray = LayoutFrame_SetParentArray
	PlayerModelMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
	PlayerModelMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent

	DressUpModelMeta.SetShown = ScriptRegion_SetShown
	DressUpModelMeta.GetScaledRect = ScriptRegion_GetScaledRect
	DressUpModelMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
	DressUpModelMeta.SetParentArray = LayoutFrame_SetParentArray
	DressUpModelMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
	DressUpModelMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
	DressUpModelMeta.SetUnitRaw = DressUpModelMeta.SetUnit
	DressUpModelMeta.SetUnit = DressUpModel_SetUnit

	TabardModelMeta.SetShown = ScriptRegion_SetShown
	TabardModelMeta.GetScaledRect = ScriptRegion_GetScaledRect
	TabardModelMeta.ClearAndSetPoint = ScriptRegionResizing_ClearAndSetPoint
	TabardModelMeta.SetParentArray = LayoutFrame_SetParentArray
	TabardModelMeta.RegisterCustomEvent = Frame_RegisterCustomEvent
	TabardModelMeta.UnregisterCustomEvent = Frame_UnregisterCustomEvent
	TabardModelMeta.SetUnitRaw = TabardModelMeta.SetUnit
	TabardModelMeta.SetUnit = DressUpModel_SetUnit
end