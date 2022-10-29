local _G = _G
local error = error
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local type = type
local unpack = unpack
local floor = math.floor
local strconcat = strconcat
local tconcat, tinsert, tremove, tsort = table.concat, table.insert, table.remove, table.sort

local strbyte		= string.byte
local strchar		= string.char
local strdump		= string.dump
local strfind		= string.find
local strformat		= string.format
local strlen		= string.len
local strlower		= string.lower
local strrep		= string.rep
local strsub		= string.sub
local strupper		= string.upper

local DEBUG = false
local VALIDATE_UTF8_CHAR = false

---Returns the number of bytes used by the UTF-8 character at byte i in s, also doubles as a UTF-8 character validator
---@param str string
---@param i? integer
---@return integer charNumBytes
---@nodiscard
local function utf8charbytes(str, i)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8charbytes' (string expected, got %s)", type(str)), 2)
	elseif i ~= nil and type(i) ~= "number" then
		error(strformat("bad argument #2 to 'utf8charbytes' (number expected, got %s)", type(i)), 2)
	end

	i = i or 1

	local c = strbyte(str, i)

	-- determine bytes needed for character, based on RFC 3629
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1
	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		if VALIDATE_UTF8_CHAR then
			local c2 = strbyte(str, i + 1)

			if not c2 then
				error("UTF-8 string terminated early", 2)
			end

			-- validate byte 2
			if c2 < 128 or c2 > 191 then
				error("Invalid UTF-8 character", 2)
			end
		end

		return 2
	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		if VALIDATE_UTF8_CHAR then
			local c2, c3 = strbyte(str, i + 1, i + 2)

			if not c2 or not c3 then
				error("UTF-8 string terminated early", 2)
			end

			-- validate byte 2
			if c == 224 and (c2 < 160 or c2 > 191) then
				error("Invalid UTF-8 character", 2)
			elseif c == 237 and (c2 < 128 or c2 > 159) then
				error("Invalid UTF-8 character", 2)
			elseif c2 < 128 or c2 > 191 then
				error("Invalid UTF-8 character", 2)
			end

			-- validate byte 3
			if c3 < 128 or c3 > 191 then
				error("Invalid UTF-8 character", 2)
			end
		end

		return 3
	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		if VALIDATE_UTF8_CHAR then
			local c2, c3, c4 = strbyte(str, i + 1, i + 3)

			if not c2 or not c3 or not c4 then
				error("UTF-8 string terminated early", 2)
			end

			-- validate byte 2
			if c == 240 and (c2 < 144 or c2 > 191) then
				error("Invalid UTF-8 character", 2)
			elseif c == 244 and (c2 < 128 or c2 > 143) then
				error("Invalid UTF-8 character", 2)
			elseif c2 < 128 or c2 > 191 then
				error("Invalid UTF-8 character", 2)
			end

			-- validate byte 3
			if c3 < 128 or c3 > 191 then
				error("Invalid UTF-8 character", 2)
			end

			-- validate byte 4
			if c4 < 128 or c4 > 191 then
				error("Invalid UTF-8 character", 2)
			end
		end

		return 4
	else
		if VALIDATE_UTF8_CHAR then
			error("Invalid UTF-8 character", 2)
		else
			return 0
		end
	end
end

---string.len with UTF-8 support
---
---Returns the number of characters in a UTF-8 string
---@param str string
---@return integer length
---@nodiscard
local utf8len = strlenutf8 or function(str)
	if type(str) ~= "string" then
		if DEBUG then
			for k, v in pairs(str) do
				print(strformat([["%s" = "%s"]], tostring(k), tostring(v)))
			end
		end

		error(strformat("bad argument #1 to 'utf8len' (string expected, got %s)", type(str)), 2)
	end

	local bytes = strlen(str)
	local pos = 1
	local len = 0

	while pos <= bytes do
		len = len + 1
		pos = pos + utf8charbytes(str, pos)
	end

	return len
end

---string.sub with UTF-8 support
---
---Returns the substring of the string that starts at `i` and continues until `j`.
---
-- functions identically to string.sub except that `i` and `j` are UTF-8 characters instead of bytes
---@param str string
---@param i integer
---@param j? integer
---@return string
---@nodiscard
local function utf8sub(str, i, j)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8sub' (string expected, got %s)", type(str)), 2)
	elseif type(i) ~= "number" then
		error(strformat("bad argument #2 to 'utf8sub' (number expected, got %s)", type(i)), 2)
	elseif j ~= nil and type(j) ~= "number" then
		error(strformat("bad argument #3 to 'utf8sub' (number expected, got %s)", type(j)), 2)
	end

	j = j or -1

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8len(str)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar	= (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	local bytes = strlen(str)
	local pos = 1
	local len = 0

	-- byte offsets to pass to string.sub
	local startByte = 1
	local endByte = bytes

	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(str, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end

	if startChar > len then
		startByte = bytes + 1
	end
	if endChar < 1 then
		endByte = 0
	end

	return strsub(str, startByte, endByte)
end

---utf8sub with extra argument, and extra result value
---@param str string
---@param i integer
---@param j integer?
---@param sb integer?
---@return string
---@return integer endByte
---@nodiscard
local function utf8subWithBytes(str, i, j, sb)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8subWithBytes' (string expected, got %s)", type(str)), 2)
	elseif type(i) ~= "number" then
		error(strformat("bad argument #2 to 'utf8subWithBytes' (number expected, got %s)", type(i)), 2)
	elseif j ~= nil and type(j) ~= "number" then
		error(strformat("bad argument #3 to 'utf8subWithBytes' (number expected, got %s)", type(j)), 2)
	elseif sb ~= nil and type(sb) ~= "number" then
		error(strformat("bad argument #4 to 'utf8subWithBytes' (number expected, got %s)", type(sb)), 2)
	end

	j = j or -1

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8len(str)
	local startChar = (i >= 0) and i or l + i + 1
	local endChar	= (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if startChar > endChar then
		return ""
	end

	local bytes = strlen(str)
	local pos = sb or 1
	local len = 0

	-- byte offsets to pass to string.sub
	local startByte = 1
	local endByte = bytes

	while pos <= bytes do
		len = len + 1

		if len == startChar then
			startByte = pos
		end

		pos = pos + utf8charbytes(str, pos)

		if len == endChar then
			endByte = pos - 1
			break
		end
	end

	if startChar > len then
		startByte = bytes + 1
	end
	if endChar < 1 then
		endByte = 0
	end

	return strsub(str, startByte, endByte), endByte + 1
end

---Replace UTF-8 characters based on a mapping table
---@param str string
---@param mapping table
---@return string
local function utf8replace(str, mapping)
	local bytes = strlen(str)
	local pos = 1
	local charbytes, c

	if strconcat then
		local newstr = ""

		while pos <= bytes do
			charbytes = utf8charbytes(str, pos)
			c = strsub(str, pos, pos + charbytes - 1)

			newstr = strconcat(newstr, (mapping[c] or c))

			pos = pos + charbytes
		end

		return newstr
	else
		local newstr = {}
		local index = 1

		while pos <= bytes do
			charbytes = utf8charbytes(str, pos)
			c = strsub(str, pos, pos + charbytes - 1)

			newstr[index] = (mapping[c] or c)

			index = index + 1
			pos = pos + charbytes
		end

		return tconcat(newstr, "")
	end
end

---string.reverse with UTF-8 support
---
---Returns a string that is the string `s` reversed.
---@param str string
---@return string
---@nodiscard
local function utf8reverse(str)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8reverse' (string expected, got %s)", type(str)), 2)
	end

	local bytes = strlen(str)
	local pos = bytes
	local charbytes, c

	if strconcat then
		local newstr = ""

		while pos > 0 do
			c = strbyte(str, pos)
			while c >= 128 and c <= 191 do
				pos = pos - 1
				c = strbyte(str, pos)
			end

			charbytes = utf8charbytes(str, pos)

			newstr = strconcat(newstr, strsub(str, pos, pos + charbytes - 1))

			pos = pos - 1
		end

		return newstr
	else
		local newstr = {}
		local index = 1

		while pos > 0 do
			c = strbyte(str, pos)
			while c >= 128 and c <= 191 do
				pos = pos - 1
				c = strbyte(str, pos)
			end

			charbytes = utf8charbytes(str, pos)

			newstr[index] = strsub(str, pos, pos + charbytes - 1)

			index = index + 1
			pos = pos - 1
		end

		return tconcat(newstr, "")
	end
end

---string.char with UTF-8 support
---
---Returns a string with length equal to the number of arguments, in which each character has the internal numeric code equal to its corresponding argument.
---@param char string
---@return integer byte
---@nodiscard
local function utf8char(char)
	if type(char) ~= "string" then
		error(strformat("bad argument #1 to 'utf8char' (string expected, got %s)", type(char)), 2)
	end

	if char <= 0x7F then
		return strchar(char)
	elseif char <= 0x7FF then
		local byte0 = 0xC0 + floor(char / 0x40)
		local byte1 = 0x80 + (char % 0x40)
		return strchar(byte0, byte1)
	elseif char <= 0xFFFF then
		local byte0 = 0xE0 + floor(char / 0x1000)
		local byte1 = 0x80 + (floor(char / 0x40) % 0x40)
		local byte2 = 0x80 + (char % 0x40)
		return strchar(byte0, byte1, byte2)
	elseif char <= 0x10FFFF then
		local code = char
		local byte3 = 0x80 + (code % 0x40)
		code = floor(code / 0x40)
		local byte2 = 0x80 + (code % 0x40)
		code = floor(code / 0x40)
		local byte1 = 0x80 + (code % 0x40)
		code = floor(code / 0x40)
		local byte0 = 0xF0 + code

		return strchar(byte0, byte1, byte2, byte3)
	end

	if VALIDATE_UTF8_CHAR then
		error("Invalid UTF-8 character. Unicode cannot be greater than U+10FFFF!", 2)
	end
end

local SHIFT_6	= 2^6
local SHIFT_12	= 2^12
local SHIFT_18	= 2^18

---@param str string
---@param i? integer
---@param j? integer
---@param strLen integer
---@param bytePos? integer
---@return integer char
---@return ... char
local utf8byteget
utf8byteget = function(str, i, j, strLen, bytePos)
	if i > j then return end

	local char, bytes

	if bytePos then
		bytes = utf8charbytes(str, bytePos)
		char = strsub(str, bytePos, bytePos - 1 + bytes)
	else
		char, bytePos = utf8sub(str, i, i), 1
		bytes = #char
	end

	local byte

	if bytes == 1 then
		byte = strbyte(char)
	elseif bytes == 2 then
		local byte0, byte1 = strbyte(char, 1, 2)
		local code0, code1 = byte0 - 0xC0, byte1 - 0x80
		byte = code0 * SHIFT_6 + code1
	elseif bytes == 3 then
		local byte0, byte1, byte2 = strbyte(char, 1, 3)
		local code0, code1, code2 = byte0 - 0xE0, byte1 - 0x80, byte2 - 0x80
		byte = code0 * SHIFT_12 + code1 * SHIFT_6 + code2
	elseif bytes == 4 then
		local byte0, byte1, byte2, byte3 = strbyte(char, 1, 4)
		local code0, code1, code2, code3 = byte0 - 0xF0, byte1 - 0x80, byte2 - 0x80, byte3 - 0x80
		byte = code0 * SHIFT_18 + code1 * SHIFT_12 + code2 * SHIFT_6 + code3
	end

	local nextByte = bytePos + bytes
	if nextByte <= strLen then
		return byte, utf8byteget(str, i + 1, j, strLen, bytePos + bytes)
	else
		return byte
	end
end

---string.byte with UTF-8 support
---
---Returns the internal numeric codes of the characters `s[i], s[i+1], ..., s[j]`.
---@param str string
---@param i? integer
---@param j? integer
---@return integer char
---@return ... char
---@nodiscard
local utf8byte = function(str, i, j)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8byte' (string expected, got %s)", type(str)), 2)
	elseif i ~= nil and type(i) ~= "number" then
		error(strformat("bad argument #2 to 'utf8byte' (number expected, got %s)", type(i)), 2)
	elseif j ~= nil and type(j) ~= "number" then
		error(strformat("bad argument #3 to 'utf8byte' (number expected, got %s)", type(j)), 2)
	end

	if str == "" then
		return
	end

	i = i or 1
	j = j or i

	return utf8byteget(str, i, j, #str)
end

---Returns an iterator which returns the next substring and its byte interval
---@param str string
---@param subLen integer?
---@return function
local function utf8gensub(str, subLen)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8gensub' (string expected, got %s)", type(str)), 2)
	elseif subLen ~= nil and type(subLen) ~= "number" then
		error(strformat("bad argument #2 to 'utf8gensub' (number expected, got %s)", type(subLen)), 2)
	end

	subLen = subLen or 1

	local byte_pos = 1
	local len = #str

	return function(skip)
		if skip then byte_pos = byte_pos + skip end
		local char_count = 0
		local start = byte_pos

		repeat
			if byte_pos > len then
				return
			end

			local bytes = utf8charbytes(str, byte_pos)
			char_count = char_count + 1
			byte_pos = byte_pos + bytes

		until char_count == subLen

		local last = byte_pos - 1
		local sub = strsub(str, start, last)

		return sub, start, last
	end
end

---@param sortedTable table
---@param item string
---@param comp boolean?
---@return boolean
---@return number?
local function binsearch(sortedTable, item, comp)
	local head, tail = 1, #sortedTable
	local mid = floor((head + tail) / 2)

	if not comp then
		while (tail - head) > 1 do
			if sortedTable[tonumber(mid)] > item then
				tail = mid
			else
				head = mid
			end

			mid = floor((head + tail) / 2)
		end
	end

	if sortedTable[tonumber(head)] == item then
		return true, tonumber(head)
	elseif sortedTable[tonumber(tail)] == item then
		return true, tonumber(tail)
	else
		return false
	end
end

---@param class string
---@param plain boolean?
---@return function
---@return integer startIndex?
local function classMatchGenerator(class, plain)
	local codes = {}
	local ranges = {}
	local ignore = false
	local range = false
	local firstletter = true
	local unmatch = false

	local it = utf8gensub(class)

	local skip
	for c, bs, be in it do
		skip = be
		if not ignore and not plain then
			if c == "%" then
				ignore = true
			elseif c == "-" then
				tinsert(codes, utf8byte(c))
				range = true
			elseif c == "^" then
				if not firstletter then
					error("!!!")
				else
					unmatch = true
				end
			elseif c == "]" then
				break
			else
				if not range then
					tinsert(codes, utf8byte(c))
				else
					tremove(codes) -- removing "-"
					tinsert(ranges, {tremove(codes), utf8byte(c)})
					range = false
				end
			end
		elseif ignore and not plain then
			if c == "a" then -- %a: represents all letters. (ONLY ASCII)
				tinsert(ranges, {65, 90}) -- A - Z
				tinsert(ranges, {97, 122}) -- a - z
			elseif c == "c" then -- %c: represents all control characters.
				tinsert(ranges, {0, 31})
				tinsert(codes, 127)
			elseif c == "d" then -- %d: represents all digits.
				tinsert(ranges, {48, 57}) -- 0 - 9
			elseif c == "g" then -- %g: represents all printable characters except space.
				tinsert(ranges, {1, 8})
				tinsert(ranges, {14, 31})
				tinsert(ranges, {33, 132})
				tinsert(ranges, {134, 159})
				tinsert(ranges, {161, 5759})
				tinsert(ranges, {5761, 8191})
				tinsert(ranges, {8203, 8231})
				tinsert(ranges, {8234, 8238})
				tinsert(ranges, {8240, 8286})
				tinsert(ranges, {8288, 12287})
			elseif c == "l" then -- %l: represents all lowercase letters. (ONLY ASCII)
				tinsert(ranges, {97, 122}) -- a - z
			elseif c == "p" then -- %p: represents all punctuation characters. (ONLY ASCII)
				tinsert(ranges, {33, 47})
				tinsert(ranges, {58, 64})
				tinsert(ranges, {91, 96})
				tinsert(ranges, {123, 126})
			elseif c == "s" then -- %s: represents all space characters.
				tinsert(ranges, {9, 13})
				tinsert(codes, 32)
				tinsert(codes, 133)
				tinsert(codes, 160)
				tinsert(codes, 5760)
				tinsert(ranges, {8192, 8202})
				tinsert(codes, 8232)
				tinsert(codes, 8233)
				tinsert(codes, 8239)
				tinsert(codes, 8287)
				tinsert(codes, 12288)
			elseif c == "u" then -- %u: represents all uppercase letters. (ONLY ASCII)
				tinsert(ranges, {65, 90}) -- A - Z
			elseif c == "w" then -- %w: represents all alphanumeric characters. (ONLY ASCII)
				tinsert(ranges, {48, 57}) -- 0 - 9
				tinsert(ranges, {65, 90}) -- A - Z
				tinsert(ranges, {97, 122}) -- a - z
			elseif c == "x" then -- %x: represents all hexadecimal digits.
				tinsert(ranges, {48, 57}) -- 0 - 9
				tinsert(ranges, {65, 70}) -- A - F
				tinsert(ranges, {97, 102}) -- a - f
			else
				if not range then
					tinsert(codes, utf8byte(c))
				else
					tremove(codes) -- removing "-"
					tinsert(ranges, {tremove(codes), utf8byte(c)})
					range = false
				end
			end
			ignore = false
		else
			if not range then
				tinsert(codes, utf8byte(c))
			else
				tremove(codes) -- removing "-"
				tinsert(ranges, {tremove(codes), utf8byte(c)})
				range = false
			end
			ignore = false
		end

		firstletter = false
	end

	tsort(codes)

	local function inRanges(charCode)
		for _, r in ipairs(ranges) do
			if r[1] <= charCode and charCode <= r[2] then
				return true
			end
		end
		return false
	end
	if not unmatch then
		return function(charCode)
			return binsearch(codes, charCode) or inRanges(charCode)
		end, skip
	else
		return function(charCode)
			return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
		end, skip
	end
end

local cache = setmetatable({}, {__mode = "kv"})
local cachePlain = setmetatable({}, {__mode = "kv"})
local function matcherGenerator(pattern, plain)
	local matcher = {
		functions = {},
		captures = {}
	}
	if not plain then
		cache[pattern] = matcher
	else
		cachePlain[pattern] = matcher
	end
	local function simple(func)
		return function(cC)
			if func(cC) then
				matcher:nextFunc()
				matcher:nextStr()
			else
				matcher:reset()
			end
		end
	end
	local function star(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextFunc()
				matcher:nextStr()
			else
				matcher:nextFunc()
			end
		end
	end
	local function minus(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextStr()
			end
			matcher:nextFunc()
		end
	end
	local function question(func)
		return function(cC)
			if func(cC) then
				matcher:fullResetOnNextFunc()
				matcher:nextStr()
			end
			matcher:nextFunc()
		end
	end

	local function capture(id)
		return function(cC)
			local l = matcher.captures[id][2] - matcher.captures[id][1]
			local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
			local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
			if captured == check then
				for i = 0, l do
					matcher:nextStr()
				end
				matcher:nextFunc()
			else
				matcher:reset()
			end
		end
	end
	local function captureStart(id)
		return function(cC)
			matcher.captures[id][1] = matcher.str
			matcher:nextFunc()
		end
	end
	local function captureStop(id)
		return function(cC)
			matcher.captures[id][2] = matcher.str - 1
			matcher:nextFunc()
		end
	end

	local function balancer(str)
		local sum = 0
		local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
		local skip = strlen(bc) + strlen(ec)
		bc, ec = utf8byte(bc), utf8byte(ec)
		return function(cC)
			if cC == ec and sum > 0 then
				sum = sum - 1
				if sum == 0 then
					matcher:nextFunc()
				end
				matcher:nextStr()
			elseif cC == bc then
				sum = sum + 1
				matcher:nextStr()
			else
				if sum == 0 or cC == -1 then
					sum = 0
					matcher:reset()
				else
					matcher:nextStr()
				end
			end
		end, skip
	end

	matcher.functions[1] = function(cC)
		matcher:fullResetOnNextStr()
		matcher.seqStart = matcher.str
		matcher:nextFunc()
		if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
			matcher.stop = true
			matcher.seqStart = nil
		end
	end

	local lastFunc
	local ignore = false
	local skip = nil
	local it = (function()
		local gen = utf8gensub(pattern)
		return function()
			return gen(skip)
		end
	end)()

	local cs = {}
	for c, bs, be in it do
		skip = nil
		if plain then
			tinsert(matcher.functions, simple(classMatchGenerator(c, plain)))
		else
			if ignore then
				if strfind("123456789", c, 1, true) then
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					tinsert(matcher.functions, capture(tonumber(c)))
				elseif c == "b" then
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end
					local b
					b, skip = balancer(strsub(pattern, be + 1, be + 9))
					tinsert(matcher.functions, b)
				else
					lastFunc = classMatchGenerator("%" .. c)
				end
				ignore = false
			else
				if c == "*" then
					if lastFunc then
						tinsert(matcher.functions, star(lastFunc))
						lastFunc = nil
					else
						error(strformat("invalid regex after %s", strsub(pattern, 1, bs)), 2)
					end
				elseif c == "+" then
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
						tinsert(matcher.functions, star(lastFunc))
						lastFunc = nil
					else
						error(strformat("invalid regex after %s", strsub(pattern, 1, bs)), 2)
					end
				elseif c == "-" then
					if lastFunc then
						tinsert(matcher.functions, minus(lastFunc))
						lastFunc = nil
					else
						error(strformat("invalid regex after %s", strsub(pattern, 1, bs)), 2)
					end
				elseif c == "?" then
					if lastFunc then
						tinsert(matcher.functions, question(lastFunc))
						lastFunc = nil
					else
						error(strformat("invalid regex after %s", strsub(pattern, 1, bs)), 2)
					end
				elseif c == "^" then
					if bs == 1 then
						matcher.fromStart = true
					else
						error(strformat("invalid regex after %s", strsub(pattern, 1, bs)), 2)
					end
				elseif c == "$" then
					if be == strlen(pattern) then
						matcher.toEnd = true
					else
						error(strformat("invalid regex after %s", strsub(pattern, 1, bs)), 2)
					end
				elseif c == "[" then
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
					end
					lastFunc, skip = classMatchGenerator(strsub(pattern, be + 1))
				elseif c == "(" then
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end

					tinsert(matcher.captures, {})
					tinsert(cs, #matcher.captures)
					tinsert(matcher.functions, captureStart(cs[#cs]))

					if strsub(pattern, be + 1, be + 1) == ")" then
						matcher.captures[#matcher.captures].empty = true
					end
				elseif c == ")" then
					if lastFunc then
						table.insert(matcher.functions, simple(lastFunc))
						lastFunc = nil
					end

					local cap = table.remove(cs)
					if not cap then
						error("invalid capture: '(' missing", 2)
					end

					tinsert(matcher.functions, captureStop(cap))
				elseif c == "." then
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
					end
					lastFunc = function(cC) return cC ~= -1 end
				elseif c == "%" then
					ignore = true
				else
					if lastFunc then
						tinsert(matcher.functions, simple(lastFunc))
					end
					lastFunc = classMatchGenerator(c)
				end
			end
		end
	end

	if #cs > 0 then
		error("invalid capture: ')' missing", 2)
	end
	if lastFunc then
		tinsert(matcher.functions, simple(lastFunc))
	end
	lastFunc = nil
	ignore = nil

	tinsert(matcher.functions, function()
		if matcher.toEnd and matcher.str ~= matcher.stringLen then
			matcher:reset()
		else
			matcher.stop = true
		end
	end)

	matcher.nextFunc = function(self)
		self.func = self.func + 1
	end
	matcher.nextStr = function(self)
		self.str = self.str + 1
	end
	matcher.strReset = function(self)
		local oldReset = self.reset
		local str = self.str
		self.reset = function(s)
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.fullResetOnNextFunc = function(self)
		local oldReset = self.reset
		local func = self.func + 1
		local str = self.str
		self.reset = function(s)
			s.func = func
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.fullResetOnNextStr = function(self)
		local oldReset = self.reset
		local str = self.str + 1
		local func = self.func
		self.reset = function(s)
			s.func = func
			s.str = str
			s.reset = oldReset
		end
	end
	matcher.process = function(self, str, start)
		self.func = 1
		self.startStr = (start >= 0) and start or utf8len(str) + start + 1
		self.seqStart = self.startStr
		self.str = self.startStr
		self.stringLen = utf8len(str) + 1
		self.string = str
		self.stop = false

		self.reset = function(s)
			s.func = 1
		end

	--	local lastPos = self.str
	--	local lastByte
		local char
		while not self.stop do
			if self.str < self.stringLen then
			--[[
				if lastPos < self.str then
					print("last byte", lastByte)
					char, lastByte = utf8subWithBytes(str, 1, self.str - lastPos - 1, lastByte)
					char, lastByte = utf8subWithBytes(str, 1, 1, lastByte)
					lastByte = lastByte - 1
				else
					char, lastByte = utf8subWithBytes(str, self.str, self.str)
				end
				lastPos = self.str
			]]
				char = utf8sub(str, self.str, self.str)
			--	print("char", char, utf8unicode(char))
				self.functions[self.func](utf8byte(char))
			else
				self.functions[self.func](-1)
			end
		end

		if self.seqStart then
			local captures = {}
			for _,pair in pairs(self.captures) do
				if pair.empty then
					tinsert(captures, pair[1])
				else
					tinsert(captures, utf8sub(str, pair[1], pair[2]))
				end
			end
			return self.seqStart, self.str - 1, unpack(captures)
		end
	end

	return matcher
end

---string.find with UTF-8 support
---
---Looks for the first match of `pattern` in the string.
---@param str string
---@param pattern string
---@param init? integer
---@param plain? boolean
---@return integer start
---@return integer end
---@return ... captured
---@nodiscard
local function utf8find(str, pattern, init, plain)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8find' (string expected, got %s)", type(str)), 2)
	elseif type(pattern) ~= "string" then
		error(strformat("bad argument #2 to 'utf8find' (string expected, got %s)", type(pattern)), 2)
	elseif init ~= nil and type(init) ~= "number" then
		error(strformat("bad argument #3 to 'utf8find' (number expected, got %s)", type(init)), 2)
	elseif plain ~= nil and type(plain) ~= "boolean" then
		plain = not not plain
	end

	init = init or 1

	local matcher = cache[pattern] or matcherGenerator(pattern, plain)
	return matcher:process(str, init)
end

---string.match with UTF-8 support
---
---Looks for the first match of `pattern` in the string.
---@param str string
---@param pattern string
---@param init? integer
---@return string | number captured
---@nodiscard
local function utf8match(str, pattern, init)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8match' (string expected, got %s)", type(str)), 2)
	elseif type(pattern) ~= "string" then
		error(strformat("bad argument #2 to 'utf8match' (string expected, got %s)", type(pattern)), 2)
	elseif init ~= nil and type(init) ~= "number" then
		error(strformat("bad argument #3 to 'utf8match' (number expected, got %s)", type(init)), 2)
	end

	init = init or 1

	local found = {utf8find(str, pattern, init)}
	if found[1] then
		if found[3] then
			return unpack(found, 3)
		end
		return utf8sub(str, found[1], found[2])
	end
end

---string.gmatch with UTF-8 support
---
---Returns an iterator function that, each time it is called, returns the next captures from `pattern` over the string `str`.
---@param str string
---@param pattern string
---@return fun():string, ...
---@nodiscard
local function utf8gmatch(str, pattern)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8gmatch' (string expected, got %s)", type(str)), 2)
	elseif type(pattern) ~= "string" then
		error(strformat("bad argument #2 to 'utf8gmatch' (string expected, got %s)", type(pattern)), 2)
	end

	pattern = (utf8sub(pattern, 1, 1) ~= "^") and pattern or "%" .. pattern
	local lastChar = 1

	return function()
		local found = {utf8find(str, pattern, lastChar)}
		if found[1] then
			lastChar = found[2] + 1
			if found[3] then
				return unpack(found, 3)
			end
			return utf8sub(str, found[1], found[2])
		end
	end
end

local function utf8gmatchall(str, pattern, all)
	pattern = (utf8sub(pattern, 1, 1) ~= "^") and pattern or "%" .. pattern
	local lastChar = 1

	return function()
		local found = {utf8find(str, pattern, lastChar)}
		if found[1] then
			lastChar = found[2] + 1
			if found[all and 1 or 3] then
				return unpack(found, all and 1 or 3)
			end
			return utf8sub(str, found[1], found[2])
		end
	end
end
local function replace(repl, replType, args)
	if replType == "string" then
		local ignore = false
		local num = 0

		if strconcat then
			local ret = ""

			for c in utf8gensub(repl) do
				if not ignore then
					if c == "%" then
						ignore = true
					else
						ret = strconcat(ret, c)
					end
				else
					num = tonumber(c)
					if num then
						ret = strconcat(ret, args[num])
					else
						ret = strconcat(ret, c)
					end
					ignore = false
				end
			end

			return ret
		else
			local index = 1
			local ret = {}

			for c in utf8gensub(repl) do
				if not ignore then
					if c == "%" then
						ignore = true
					else
						ret[index] = c
						index = index + 1
					end
				else
					num = tonumber(c)
					if num then
						ret[index] = args[num]
					else
						ret[index] = c
					end
					index = index + 1
					ignore = false
				end
			end

			return tconcat(ret, "")
		end
	elseif replType == "table" then
		return repl[args[1] or args[0]] or ""
	elseif replType == "function" then
		if #args > 0 then
			return repl(unpack(args, 1)) or ""
		else
			return repl(args[0]) or ""
		end
	end
end
---string.gsub with UTF-8 support
---
---Returns a copy of s in which all (or the first `n`, if given) occurrences of the `pattern` have been replaced by a replacement string specified by `repl`.
---@param str string
---@param pattern string
---@param repl string|table|function
---@param limit? integer
---@return string
---@return integer count
---@nodiscard
local function utf8gsub(str, pattern, repl, limit)
	if type(str) ~= "string" then
		error(strformat("bad argument #1 to 'utf8gsub' (string expected, got %s)", type(str)), 2)
	elseif type(pattern) ~= "string" then
		error(strformat("bad argument #2 to 'utf8gsub' (string expected, got %s)", type(pattern)), 2)
	elseif limit ~= nil and type(limit) ~= "number" then
		error(strformat("bad argument #4 to 'utf8gsub' (number expected, got %s)", type(limit)), 2)
	end

	local replType = type(repl)
	if replType ~= "number" and replType ~= "string" and replType ~= "function" and replType ~= "table" then
		error(strformat("bad argument #3 to 'utf8gsub' (string/function/table expected, got %s)", type(repl)), 2)
	end

	limit = limit or -1

	local prevEnd = 1
	local n = 0
	local it = utf8gmatchall(str, pattern, true)
	local found = {it()}

	if strconcat then
		local ret = ""

		while #found > 0 and limit ~= n do
			local args = {[0] = utf8sub(str, found[1], found[2]), unpack(found, 3)}

			ret = strconcat(ret, utf8sub(str, prevEnd, found[1] - 1), replace(repl, replType, args))

			prevEnd = found[2] + 1
			n = n + 1
			found = {it()}
		end

		return strconcat(ret, utf8sub(str, prevEnd)), n
	else
		local index = 1
		local ret = {}

		while #found > 0 and limit ~= n do
			local args = {[0] = utf8sub(str, found[1], found[2]), unpack(found, 3)}

			ret[index] = utf8sub(str, prevEnd, found[1] - 1)
			ret[index + 1] = replace(repl, replType, args)
			index = index + 2

			prevEnd = found[2] + 1
			n = n + 1
			found = {it()}
		end

		ret[index] = utf8sub(str, prevEnd)

		return tconcat(ret, ""), n
	end
end

do
	local utf8 = {}

	utf8.byte		= utf8byte
	utf8.char		= utf8char
	utf8.dump		= strdump
	utf8.find		= utf8find
	utf8.format		= strformat
	utf8.gensub		= utf8gensub
	utf8.gmatch		= utf8gmatch
	utf8.gsub		= utf8gsub
	utf8.len		= utf8len
	utf8.lower		= strlower
	utf8.match		= utf8match
	utf8.rep		= strrep
	utf8.reverse	= utf8reverse
	utf8.sub		= utf8sub
	utf8.unicode	= utf8byte
	utf8.upper		= strupper

	_G.utf8 = utf8

	_G.utf8byte		= utf8byte
	_G.utf8char		= utf8char
	_G.utf8dump		= strdump
	_G.utf8find		= utf8find
	_G.utf8format	= strformat
	_G.utf8gensub	= utf8gensub
	_G.utf8gmatch	= utf8gmatch
	_G.utf8gsub		= utf8gsub
	_G.utf8len		= utf8len
	_G.utf8lower	= strlower
	_G.utf8match	= utf8match
	_G.utf8rep		= strrep
	_G.utf8reverse	= utf8reverse
	_G.utf8sub		= utf8sub
	_G.utf8unicode	= utf8byte
	_G.utf8upper	= strupper
end