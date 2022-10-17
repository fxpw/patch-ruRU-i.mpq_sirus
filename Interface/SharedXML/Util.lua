--	Filename:	Util.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local select = select
local UnitName = UnitName
local SendAddonMessage = SendAddonMessage

local LOCAL_ToStringAllTemp = {};
function tostringall(...)
    local n = select('#', ...)
    -- Simple versions for common argument counts
    if (n == 1) then
        return tostring(...)
    elseif (n == 2) then
        local a, b = ...
        return tostring(a), tostring(b)
    elseif (n == 3) then
        local a, b, c = ...
        return tostring(a), tostring(b), tostring(c)
    elseif (n == 0) then
        return
    end

    local needfix
    for i = 1, n do
        local v = select(i, ...)
        if (type(v) ~= "string") then
            needfix = i
            break
        end
    end
    if (not needfix) then return ...; end

    wipe(LOCAL_ToStringAllTemp)
    for i = 1, needfix - 1 do
        LOCAL_ToStringAllTemp[i] = select(i, ...)
    end
    for i = needfix, n do
        LOCAL_ToStringAllTemp[i] = tostring(select(i, ...))
    end
    return unpack(LOCAL_ToStringAllTemp)
end


CHARACTER_RACES_INFO = {
	["HUMAN"] = {id = 1, male = "Человек", female = "Человек", faction = "Alliance"},
	["DWARF"] = {id = 3, male = "Дворф", female = "Дворф", faction = "Alliance"},
	["NIGHTELF"] = {id = 4, male = "Ночной эльф", female = "Ночная эльфийка", faction = "Alliance"},
	["GNOME"] = {id = 7, male = "Гном", female = "Гном", faction = "Alliance"},
	["DRAENEI"] = {id = 11, male = "Дреней", female = "Дреней", faction = "Alliance"},
	["WORGEN"] = {id = 12, male = "Ворген", female = "Ворген", faction = "Alliance"},
	["QUELDO"] = {id = 15, male = "Высший эльф", female = "Высшая эльфийка", faction = "Alliance"},

	["PANDAREN_A"] = {id = 14, male = "Пандарен (Альянс)", female = "Пандарен (Альянс)", faction = "Alliance"},
	["PANDAREN_H"] = {id = 16, male = "Пандарен (Орда)", female = "Пандарен (Орда)", faction = "Horde"},

	["ORC"] = {id = 2, male = "Орк", female = "Орк", faction = "Horde"},
	["SCOURGE"] = {id = 5, male = "Нежить", female = "Нежить", faction = "Horde"},
	["TAUREN"] = {id = 6, male = "Таурен", female = "Таурен", faction = "Horde"},
	["TROLL"] = {id = 8, male = "Тролль", female = "Тролль", faction = "Horde"},
	["GOBLIN"] = {id = 9, male = "Гоблин", female = "Гоблин", faction = "Horde"},
	["BLOODELF"] = {id = 10, male = "Син'Дорей", female = "Син'Дорейка", faction = "Horde"},
	["NAGA"] = {id = 13,  male = "Нага", female = "Нага", faction = "Horde"},
}

function GetRaceInfoByLocaleName(raceName)
	raceName = string.upper(raceName)

	for raceNames, arr in pairs(CHARACTER_RACES_INFO) do
		if string.upper(arr.male) == raceName or string.upper(arr.female) == raceName then
			return arr.id, raceNames, arr.male, arr.female, arr.faction
		end
	end
end

function GetRaceInfoByName(raceName)
	raceName = string.upper(raceName)

	if not CHARACTER_RACES_INFO[raceName] then
		error("Ошибка в GetRaceInfoByName. Нет информации о расе "..raceName..". Свяжитесь с Nyll")
		return
	end

	local arr = CHARACTER_RACES_INFO[raceName]
	return arr.id, raceName, arr.male, arr.female, arr.faction
end

function SetItemButtonQuality(button, quality, itemIDOrLink)
	if itemIDOrLink and IsArtifactRelicItem(itemIDOrLink) then
		button.IconBorder:SetTexture([[Interface\Artifacts\RelicIconFrame]]);
	else
		button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]]);
	end

	if quality then
		if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
			button.IconBorder:Show();
			button.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
		else
			button.IconBorder:Hide();
		end
	else
		button.IconBorder:Hide();
	end
end

function GetFinalNameFromTextureKit(fmt, textureKit)
	return fmt:format(textureKit);
end

function SetClampedTextureRotation(texture, rotationDegrees)
	if (rotationDegrees ~= 0 and rotationDegrees ~= 90 and rotationDegrees ~= 180 and rotationDegrees ~= 270) then
		error("SetRotation: rotationDegrees must be 0, 90, 180, or 270");
		return;
	end

	if not (texture.rotationDegrees) then
		texture.origTexCoords = {texture:GetTexCoord()};
		texture.origWidth = texture:GetWidth();
		texture.origHeight = texture:GetHeight();
	end

	if (texture.rotationDegrees == rotationDegrees) then
		return;
	end

	texture.rotationDegrees = rotationDegrees;

	if (rotationDegrees == 0 or rotationDegrees == 180) then
		texture:SetWidth(texture.origWidth);
		texture:SetHeight(texture.origHeight);
	else
		texture:SetWidth(texture.origHeight);
		texture:SetHeight(texture.origWidth);
	end

	if (rotationDegrees == 0) then
		texture:SetTexCoord( texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[7], texture.origTexCoords[8] );
	elseif (rotationDegrees == 90) then
		texture:SetTexCoord( texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[5], texture.origTexCoords[6] );
	elseif (rotationDegrees == 180) then
		texture:SetTexCoord( texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[3], texture.origTexCoords[4],
											texture.origTexCoords[1], texture.origTexCoords[2] );
	elseif (rotationDegrees == 270) then
		texture:SetTexCoord( texture.origTexCoords[5], texture.origTexCoords[6],
											texture.origTexCoords[1], texture.origTexCoords[2],
											texture.origTexCoords[7], texture.origTexCoords[8],
											texture.origTexCoords[3], texture.origTexCoords[4] );
	end
end

function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)
	local widthPerGrid = gridWidth/textureWidth;
	local heightPerGrid = gridHeight/textureHeight;
	return (xOffset-1)*widthPerGrid, (xOffset)*widthPerGrid, (yOffset-1)*heightPerGrid, (yOffset)*heightPerGrid;
end

function GetTexCoordsForRole(role)
	local textureHeight, textureWidth = 256, 256;
	local roleHeight, roleWidth = 67, 67;

	if ( role == "GUIDE" ) then
		return GetTexCoordsByGrid(1, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "TANK" ) then
		return GetTexCoordsByGrid(1, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "HEALER" ) then
		return GetTexCoordsByGrid(2, 1, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "DAMAGER" ) then
		return GetTexCoordsByGrid(2, 2, textureWidth, textureHeight, roleWidth, roleHeight);
	elseif ( role == "RANGEDAMAGER" ) then
		return GetTexCoordsByGrid(3, 3, textureWidth, textureHeight, roleWidth, roleHeight);
	else
		error("Unknown role: "..tostring(role));
	end
end

function GetTexCoordsByMask(ws, hs, x, y, w, h)
    return {x/ws, x/ws + w/ws, y/hs, y/hs + h/hs}
end

function GetSpriteFromImage(x, y, w, h, iw, ih)
    return (x*w)/iw, ((x+1)*w)/iw, (y*h)/ih, ((y+1)*h)/ih
end

function GetTexCoordsForRoleSmallCircle(role)
	if ( role == "TANK" ) then
		return 0, 19/64, 22/64, 41/64;
	elseif ( role == "HEALER" ) then
		return 20/64, 39/64, 1/64, 20/64;
	elseif ( role == "DAMAGER" ) then
		return 20/64, 39/64, 22/64, 41/64;
	else
		error("Unknown role: "..tostring(role));
	end
end

function GetTexCoordsForRoleSmall(role)
	if ( role == "TANK" ) then
		return 0.5, 0.75, 0, 1;
	elseif ( role == "HEALER" ) then
		return 0.75, 1, 0, 1;
	elseif ( role == "DAMAGER" ) then
		return 0.25, 0.5, 0, 1;
	else
		error("Unknown role: "..tostring(role));
	end
end

function tDeleteItem(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			tremove(table, index);
		else
			index = index + 1;
		end
	end
end

function tCount( t )
	t = t or {}
	local i = 0
	for k in pairs(t) do i = i + 1 end
	return i
end

function tDifference(a, b)
    local ai = {}
    local r = {}
    for k,v in pairs(a) do r[k] = v; ai[v]=true end
    for k,v in pairs(b) do
        if ai[v]~=nil then   r[k] = nil   end
    end
    return r
end

function tIndexOf(tbl, item)
	for i, v in ipairs(tbl) do
		if item == v then
			return i;
		end
	end
end

function tContains(table, item)
	local index = 1;
	while table[index] do
		if (item and item == table[index] ) then
			return true;
		end
		index = index + 1;
	end
	return false;
end

function tContainsWithReturn(table, item)
	local index = 1;
	while table[index] do
		if (item and item == table[index] ) then
			return item;
		end
		index = index + 1;
	end
	return false;
end

-- This is a deep compare on the values of the table (based on depth) but not a deep comparison
-- of the keys, as this would be an expensive check and won't be necessary in most cases.
function tCompare(lhsTable, rhsTable, depth)
	depth = depth or 1;
	for key, value in pairs(lhsTable) do
		if type(value) == "table" then
			local rhsValue = rhsTable[key];
			if type(rhsValue) ~= "table" then
				return false;
			end
			if depth > 1 then
				if not tCompare(value, rhsValue, depth - 1) then
					return false;
				end
			end
		elseif value ~= rhsTable[key] then
			return false;
		end
	end

	-- Check for any keys that are in rhsTable and not lhsTable.
	for key, value in pairs(rhsTable) do
		if lhsTable[key] == nil then
			return false;
		end
	end

	return true;
end

function tInvert(tbl)
	local inverted = {};
	for k, v in pairs(tbl) do
		inverted[v] = k;
	end
	return inverted;
end

function tAppendAll(table, addedArray)
	for i, element in ipairs(addedArray) do
		tinsert(table, element);
	end
end

function CopyTable(settings)
	local copy = {};
	for k, v in pairs(settings) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end
function rgb( r, g, b )
	return r / 255, g / 255, b / 255
end

function ConvertRGBtoColorString(color)
	local colorString = "|cff";
	local r = color.r * 255;
	local g = color.g * 255;
	local b = color.b * 255;
	colorString = colorString..string.format("%2x%2x%2x", r, g, b);
	return colorString;
end

function SetLargeGuildTabardTextures( frame, id )
	local emblemSize = 64 / 1024
	local columns = 16
	local offset = 0

	local xCoord = mod(id, columns) * emblemSize
	local yCoord = floor(id / columns) * emblemSize
	frame:SetTexCoord(xCoord + offset, xCoord + emblemSize - offset, yCoord + offset, yCoord + emblemSize - offset)
end

function SetSmallGuildTabardTextures( frame, id )
	local emblemSize = 18 / 256
	local columns = 14
	local offset = 1 / 256

	local xCoord = mod(id, columns) * emblemSize
	local yCoord = floor(id / columns) * emblemSize
	frame:SetTexCoord(xCoord + offset, xCoord + emblemSize - offset, yCoord + offset, yCoord + emblemSize - offset)
end

function CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom)
	return ("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"):format(
		  file
		, height
		, width
		, fileWidth
		, fileHeight
		, left * fileWidth
		, right * fileWidth
		, top * fileHeight
		, bottom * fileHeight
	);
end

function CreateAtlasMarkup(atlasName, width, height, offsetX, offsetY, fileWidth, fileHeight)
	if S_ATLAS_STORAGE[atlasName] then
		local atlasWidth, atlasHeight, left, right, top, bottom, _, _, texturePath = unpack(S_ATLAS_STORAGE[atlasName])
		width = width or atlasWidth
		height = height or atlasHeight
		return ("|T%s:%d:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"):format(
			  texturePath
			, width
			, height
			, offsetX
			, offsetY
			, fileWidth
			, fileHeight
			, math.ceil(left * fileWidth)
			, math.ceil(right * fileWidth)
			, math.ceil(top * fileHeight)
			, math.ceil(bottom * fileHeight)
		);
	else
		return ""
	end
end

-- https://gist.github.com/gdeglin/4128882
-- returns the number of bytes used by the UTF-8 character at byte i in s
-- also doubles as a UTF-8 character validator
function utf8charbytes(s, i)
    -- argument defaults
    i = i or 1
    local c = string.byte(s, i)
    -- determine bytes needed for character, based on RFC 3629
    if c > 0 and c <= 127 then
        -- UTF8-1
        return 1
    elseif c >= 194 and c <= 223 then
        -- UTF8-2
        local c2 = string.byte(s, i + 1)
        return 2
    elseif c >= 224 and c <= 239 then
        -- UTF8-3
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        return 3
    elseif c >= 240 and c <= 244 then
        -- UTF8-4
        local c2 = s:byte(i + 1)
        local c3 = s:byte(i + 2)
        local c4 = s:byte(i + 3)
        return 4
    end
end

function utf8sub(s, i, j)
	j = j or -1

	local pos = 1
	local bytes = strlen(s)
	local len = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or strlenutf8(s)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	-- byte offsets to pass to string.sub
	local startByte, endByte = 1, bytes

	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(s, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end

	return strsub(s, startByte, endByte)
end

function BitMaskCalculate( ... )
	local value = {...}
	local mask = 0

	for i = 1, #value do
		local data = value[i]

		if data then
			mask = bit.bor(mask, data)
		end
	end

	return mask
end

local totable = string.ToTable
local string_sub = string.sub
local string_find = string.find
local string_len = string.len

function string.Explode(separator, str, withpattern)
    if ( separator == "" ) then return totable( str ) end
    if ( withpattern == nil ) then withpattern = false end

    local ret = {}
    local current_pos = 1

    for i = 1, string_len( str ) do
        local start_pos, end_pos = string_find( str, separator, current_pos, not withpattern )
        if ( not start_pos ) then break end
        ret[ i ] = string_sub( str, current_pos, start_pos - 1 )
        if ret[ i ] == "" then
            ret[ i ] = nil
        end
        current_pos = end_pos + 1
    end

    ret[ #ret + 1 ] = string_sub( str, current_pos )
    if ret[ #ret ] == "" then
        ret[ #ret ] = nil
    end

    return ret
end

function C_Split( str, delimiter )
    return string.Explode( delimiter, str )
end

function C_InRange( value, min, max )
	return value and value >= min and value <= max or false
end

function GetClassFile(localizedClassName)
	for classfile, localizedClassNameM in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if localizedClassNameM == localizedClassName then
			return classfile
		end
	end

	for classfile, localizedClassNameF in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		if localizedClassNameF == localizedClassName then
			return classfile
		end
	end
end

function WrapTextInColorCode(text, colorHexString)
	return ("|c%s%s|r"):format(colorHexString, text);
end

-- ################ Mixins ################

ColorMixin = {}

function CreateColor(r, g, b, a)
	local color = CreateFromMixins(ColorMixin)
	color:OnLoad(r, g, b, a)
	return color
end

function AreColorsEqual(left, right)
	if left and right then
		return left:IsEqualTo(right)
	end
	return left == right
end

function ColorMixin:OnLoad(r, g, b, a)
	self:SetRGBA(r, g, b, a)
end

function ColorMixin:IsEqualTo(otherColor)
	return self.r == otherColor.r
		and self.g == otherColor.g
		and self.b == otherColor.b
		and self.a == otherColor.a
end

function ColorMixin:GetRGB()
	return self.r, self.g, self.b
end

function ColorMixin:GetRGBAsBytes()
	return math.Round(self.r * 255), math.Round(self.g * 255), math.Round(self.b * 255)
end

function ColorMixin:GetRGBA()
	return self.r, self.g, self.b, self.a
end

function ColorMixin:GetRGBAAsBytes()
	return math.Round(self.r * 255), math.Round(self.g * 255), math.Round(self.b * 255), math.Round((self.a or 1) * 255)
end

function ColorMixin:SetRGBA(r, g, b, a)
	self.r = r
	self.g = g
	self.b = b
	self.a = a
end

function ColorMixin:SetRGB(r, g, b)
	self:SetRGBA(r, g, b, nil)
end

function ColorMixin:ConvertToGameRGB()
	self:SetRGBA(self.r / 255, self.g / 255, self.b / 255, self.a)
	return self
end

function ColorMixin:GenerateHexColor()
	return ("ff%.2x%.2x%.2x"):format(self:GetRGBAsBytes())
end

function ColorMixin:GenerateHexColorMarkup()
	return "|c"..self:GenerateHexColor()
end

function ColorMixin:WrapTextInColorCode(text)
	return WrapTextInColorCode(text, self:GenerateHexColor())
end

local RAID_CLASS_COLORS = {
	["HUNTER"] = CreateColor(0.67, 0.83, 0.45),
	["WARLOCK"] = CreateColor(0.58, 0.51, 0.79),
	["PRIEST"] = CreateColor(1.0, 1.0, 1.0),
	["PALADIN"] = CreateColor(0.96, 0.55, 0.73),
	["MAGE"] = CreateColor(0.41, 0.8, 0.94),
	["ROGUE"] = CreateColor(1.0, 0.96, 0.41),
	["DRUID"] = CreateColor(1.0, 0.49, 0.04),
	["SHAMAN"] = CreateColor(0.0, 0.44, 0.87),
	["WARRIOR"] = CreateColor(0.78, 0.61, 0.43),
	["DEATHKNIGHT"] = CreateColor(0.77, 0.12 , 0.23),
	["MONK"] = CreateColor(0.0, 1.00 , 0.59),
	["DEMONHUNTER"] = CreateColor(0.64, 0.19, 0.79),
};

for _, v in pairs(RAID_CLASS_COLORS) do
	v.colorStr = v:GenerateHexColor()
end

function GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename]
	if color then
		return color.r, color.g, color.b, color.colorStr
	end

	return 1, 1, 1, "ffffffff";
end

function GetClassColorObj(classFilename)
	return RAID_CLASS_COLORS[classFilename]
end

function GetFactionColor(factionGroupTag)
	return PLAYER_FACTION_COLORS[PLAYER_FACTION_GROUP[factionGroupTag]]
end

function SendServerMessage(prefix, ...)
--	printec("Send ->", prefix, ...)
	if select("#", ...) > 1 then
		SendAddonMessage(prefix, strjoin(" ", tostringall(...)), "WHISPER", UnitName("player"))
	else
		SendAddonMessage(prefix, ..., "WHISPER", UnitName("player"))
	end
end

function AnimateTexCoordsBFA(texture, textureWidth, textureHeight, frameWidth, frameHeight, numFrames, elapsed, throttle)
	if ( not texture.frame ) then
		-- initialize everything
		texture.frame = 1;
		texture.throttle = throttle;
		texture.numColumns = floor(textureWidth/frameWidth);
		texture.numRows = floor(textureHeight/frameHeight);
		texture.columnWidth = frameWidth/textureWidth;
		texture.rowHeight = frameHeight/textureHeight;
	end
	local frame = texture.frame;
	if ( not texture.throttle or texture.throttle > throttle ) then
		local framesToAdvance = floor(texture.throttle / throttle);
		while ( frame + framesToAdvance > numFrames ) do
			frame = frame - numFrames;
		end
		frame = frame + framesToAdvance;
		texture.throttle = 0;
		local left = mod(frame-1, texture.numColumns)*texture.columnWidth;
		local right = left + texture.columnWidth;
		local bottom = ceil(frame/texture.numColumns)*texture.rowHeight;
		local top = bottom - texture.rowHeight;
		texture:SetTexCoord(left, right, top, bottom);

		texture.frame = frame;
	else
		texture.throttle = texture.throttle + elapsed;
	end
end

function CreateScaleAnim(group, order, duration, x, y, delay, smoothing)
	local scale = group:CreateAnimation("Scale")

	scale:SetOrder(order)
	scale:SetDuration(duration)
	scale:SetScale(x, y)

	if(delay) then
		scale:SetStartDelay(delay)
	end

	if(smoothing) then
		scale:SetSmoothing(smoothing)
	end
end

function TriStateCheckbox_SetState(checked, checkButton)
	local checkedTexture = _G[checkButton:GetName().."CheckedTexture"];
	if ( not checkedTexture ) then
		message("Can't find checked texture");
	end
	if ( not checked or checked == 0 ) then
		-- nil or 0 means not checked
		checkButton:SetChecked(false);
		checkButton.state = 0;
	elseif ( checked == 2 ) then
		-- 2 is a normal
		checkButton:SetChecked(true);
		checkedTexture:SetVertexColor(1, 1, 1);
		checkedTexture:SetDesaturated(false);
		checkButton.state = 2;
	else
		-- 1 is a gray check
		checkButton:SetChecked(true);
		checkedTexture:SetDesaturated(true);
		checkButton.state = 1;
	end
end

function SetParentArray(frame, parentArray, value)
	assert(frame)

	local parent = frame:GetParent()

	if not parent[parentArray] then
		parent[parentArray] = {}
	end

	table.insert(parent[parentArray], value)
	return parent[parentArray]
end

function printc(...)
	if S_Print then
    	S_Print(strjoin(" ", tostringall(...)))
    end
end

print = print or printc

function printec( ... )
	if S_PrintConsole then
		S_PrintConsole(strjoin(" ", tostringall(...)))
	end
end

function AnimationStopAndPlay( object, ... )
	local animationObject = {...}

	if animationObject then
		for _, stopObject in pairs(animationObject) do
			if stopObject then
				if stopObject:IsPlaying() then
					stopObject:Stop()
				end
			end
		end
	end

	if object then
		if object:IsPlaying() then
			object:Stop()
		end

		object:Play()
	end
end

function isOneOf(val, ...)
	for i = 1, select("#", ...) do
		if select(i, ...) == val then
			return true
		end
	end
	return false
end

function IsDevClient()
	return S_IsDevClient and S_IsDevClient()
end

function IsInterfaceDevClient()
	return S_IsInterfaceDevClient and S_IsInterfaceDevClient()
end

function IsNyllClient()
	return S_IsNyllClient and S_IsNyllClient()
end

function PackNumber(n1, n2)
	return bit.bor(n1, bit.lshift(n2, 16))
end

function UnpackNumber(n)
	local n1 = bit.band(n, 0xFFFF)
	local n2 = bit.band(bit.rshift(n, 16), 0xFFFF)

	return n1, n2
end

function IsWideScreen()
	return GetScreenWidth() > 1024
end

function GMError(err)
	if C_Service:IsGM() then
		geterrorhandler()(err)
	end
end