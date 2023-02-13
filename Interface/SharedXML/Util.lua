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

function GetTexCoordsByMask(ws, hs, x, y, w, h)
    return {x/ws, x/ws + w/ws, y/hs, y/hs + h/hs}
end

function GetSpriteFromImage(x, y, w, h, iw, ih)
    return (x*w)/iw, ((x+1)*w)/iw, (y*h)/ih, ((y+1)*h)/ih
end

local strfind = string.find
local strlen = string.len
local strsub = string.sub
function C_Split(str, delimiter)
	local ret = {}

	if delimiter == "" then
		for i = 1, strlen(str) do
			ret[i] = strsub(str, i, i)
		end
		return ret
	end

	local currentPos = 1

	for i = 1, strlen(str) do
		local startPos, endPos = strfind(str, delimiter, currentPos, true)
		if not startPos then break end
		ret[i] = strsub(str, currentPos, startPos - 1)
		if ret[i] == "" then
			ret[i] = nil
		end
		currentPos = endPos + 1
	end

	ret[#ret + 1] = strsub(str, currentPos)
	if ret[#ret] == "" then
		ret[#ret] = nil
	end

	return ret
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

function SendServerMessage(prefix, ...)
	if select("#", ...) > 1 then
		SendAddonMessage(prefix, strjoin(" ", tostringall(...)), "WHISPER", UnitName("player"))
	else
		SendAddonMessage(prefix, ..., "WHISPER", UnitName("player"))
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

	if next(animationObject) then
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