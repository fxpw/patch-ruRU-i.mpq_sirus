EnumUtil = {};

function EnumUtil.MakeEnum(...)
	return tInvert({...});
end

function EnumUtil.IsValid(enumClass, enumValue)
	return tContains(enumClass, enumValue);
end

Enum = {}

enum = {}
do
	local mt = {}
	local mt2 = {}

	function mt.__call(...)
		local args = {...}
		local nm = args[1][1]

		_G[nm] = {}
		setmetatable(_G[nm], mt2)

		for k,v in pairs(args[3]) do
			if type(k) == "number" then
				_G[nm][v] = k
				_G[nm][k] = v

				if not _G[nm.."_"..v] then
					_G[nm.."_"..v] = k
				else
					printc(string.format("enum: Variable %s already exists! %s", nm, v, k))
				end
			else
				_G[nm][k] = v
				if not _G[nm.."_"..k] then
					_G[nm.."_"..k] = v
				else
					printc(string.format("enum: %s Variable %s already exists!", nm, k))
				end
			end
		end

		args[2][nm] = nil
	end

	function mt.__index( t, k )
		t[k] = {k}
		setmetatable(t[k], mt)
		return t[k]
	end

	setmetatable(enum, mt)

	function mt2.__call( t, k, v )
		if t[k] then
			return t[k]
		else
			return nil
		end
	end
end

local function readOnlyError()
	error("This is a read only table and cannot be modified.", 2)
end

local issecure = issecure
function Enum.CreateMirror(t)
	local mirror = {}

	for k, v in pairs(t) do
		mirror[k] = v
		mirror[v] = k
	end

	setmetatable(t, {
		__index = function(self, key)
			return mirror[key]
		end,
		__call = function(self, key, value)
			if value and issecure() then
				rawset(self, key, value)
			else
				return mirror[key]
			end
		end,
		__newindex = readOnlyError,
		__metatable = false,
	})

	return t
end