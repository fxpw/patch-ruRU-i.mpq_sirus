
--[[---------------------------------------------------------
	Name: Inherit( t, base )
	Desc: Copies any missing data from base to t
-----------------------------------------------------------]]
function table.Inherit( t, base )

	for k, v in pairs( base ) do
		if ( t[ k ] == nil ) then t[ k ] = v end
	end

	t[ "BaseClass" ] = base

	return t

end

--[[---------------------------------------------------------
	Name: Copy(t, lookup_table)
	Desc: Taken straight from http://lua-users.org/wiki/PitLibTablestuff
		and modified to the new Lua 5.1 code by me.
		Original function by PeterPradenot
-----------------------------------------------------------]]
function table.Copy( t, lookup_table )
	if ( t == nil ) then return nil end

	local copy = {}
	setmetatable( copy, debug.getmetatable( t ) )
	for i, v in pairs( t ) do
		if ( not istable( v ) ) then
			copy[ i ] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[ t ] = copy
			if ( lookup_table[ v ] ) then
				copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
			else
				copy[ i ] = table.Copy( v, lookup_table ) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

--[[---------------------------------------------------------
	Name: Empty( tab )
	Desc: Empty a table
-----------------------------------------------------------]]
function table.Empty( tab )
	for k, v in pairs( tab ) do
		tab[ k ] = nil
	end
end

--[[---------------------------------------------------------
	Name: CopyFromTo( FROM, TO )
	Desc: Make TO exactly the same as FROM - but still the same table.
-----------------------------------------------------------]]
function table.CopyFromTo( from, to )

	-- Erase values from table TO
	table.Empty( to )

	-- Copy values over
	table.Merge( to, from )

end

--[[---------------------------------------------------------
	Name: Merge
	Desc: xx
-----------------------------------------------------------]]
function table.Merge( dest, source )

	for k, v in pairs( source ) do
		if ( type( v ) == "table" and type( dest[ k ] ) == "table" ) then
			-- don't overwrite one table with another
			-- instead merge them recurisvely
			table.Merge( dest[ k ], v )
		else
			dest[ k ] = v
		end
	end

	return dest

end

--[[---------------------------------------------------------
	Name: HasValue
	Desc: Returns whether the value is in given table
-----------------------------------------------------------]]
function table.HasValue( t, val )
	for k, v in pairs( t ) do
		if ( v == val ) then return true end
	end
	return false
end

--[[---------------------------------------------------------
	Name: table.Add( dest, source )
	Desc: Unlike merge this adds the two tables together and discards keys.
-----------------------------------------------------------]]
function table.Add( dest, source )

	-- At least one of them needs to be a table or this whole thing will fall on its ass
	if ( type( source ) ~= "table" ) then return dest end
	if ( type( dest ) ~= "table" ) then dest = {} end

	for k, v in pairs( source ) do
		table.insert( dest, v )
	end

	return dest
end

--[[---------------------------------------------------------
	Name: table.SortDesc( table )
	Desc: Like Lua's default sort, but descending
-----------------------------------------------------------]]
function table.SortDesc( t )
	return table.sort( t, function( a, b ) return a > b end )
end

--[[---------------------------------------------------------
	Name: table.SortByKey( table )
	Desc: Returns a table sorted numerically by Key value
-----------------------------------------------------------]]
function table.SortByKey( t, desc )

	local temp = {}

	for key, _ in pairs( t ) do table.insert( temp, key ) end
	if ( desc ) then
		table.sort( temp, function( a, b ) return t[ a ] < t[ b ] end )
	else
		table.sort( temp, function( a, b ) return t[ a ] > t[ b ] end )
	end

	return temp

end

--[[---------------------------------------------------------
	Name: table.Count( table )
	Desc: Returns the number of keys in a table
-----------------------------------------------------------]]
function table.Count( t )
	local i = 0
	for k in pairs( t ) do i = i + 1 end
	return i
end

--[[---------------------------------------------------------
	Name: table.Random( table )
	Desc: Return a random key
-----------------------------------------------------------]]
function table.Random( t )
	local rk = math.random( 1, table.Count( t ) )
	local i = 1
	for k, v in pairs( t ) do
		if ( i == rk ) then return v, k end
		i = i + 1
	end
end

--[[----------------------------------------------------------------------
	Name: table.IsSequential( table )
	Desc: Returns true if the tables
		keys are sequential
-------------------------------------------------------------------------]]
function table.IsSequential( t )
	local i = 1
	for key, value in pairs( t ) do
		if ( t[ i ] == nil ) then return false end
		i = i + 1
	end
	return true
end

--[[---------------------------------------------------------
	Name: table.ToString( table,name,nice )
	Desc: Convert a simple table to a string
		table = the table you want to convert (table)
		name  = the name of the table (string)
		nice  = whether to add line breaks and indents (bool)
-----------------------------------------------------------]]
local function MakeTable( t, nice, indent, done )
	local str = ""
	local done = done or {}
	local indent = indent or 0
	local idt = ""
	if nice then idt = string.rep( "\t", indent ) end
	local nl, tab  = "", ""
	if ( nice ) then nl, tab = "\n", "\t" end

	local sequential = table.IsSequential( t )

	for key, value in pairs( t ) do

		str = str .. idt .. tab .. tab

		if not sequential then
			if type( key ) == "number" or type( key ) == "boolean" then
				key = "[" .. tostring( key ) .. "]" .. tab .. "="
			else
				key = tostring( key ) .. tab .. "="
			end
		else
			key = ""
		end

		if ( istable( value ) and not done[ value ] ) then

			done [ value ] = true
			str = str .. key .. tab .. "{" .. nl .. MakeTable( value, nice, indent + 1, done )
			str = str .. idt .. tab .. tab .. tab .. tab .."},".. nl

		else

			if ( type( value ) == "string" ) then
				value = '"' .. tostring( value ) .. '"'
			elseif ( type( value ) == "Vector" ) then
				value = "Vector(" .. value.x .. "," .. value.y .. "," .. value.z .. ")"
			elseif ( type( value ) == "Angle" ) then
				value = "Angle(" .. value.pitch .. "," .. value.yaw .. "," .. value.roll .. ")"
			else
				value = tostring( value )
			end

			str = str .. key .. tab .. value .. "," .. nl

		end

	end
	return str
end

function table.ToString( t, n, nice )
	local nl, tab  = "", ""
	if ( nice ) then nl, tab = "\n", "\t" end

	local str = ""
	if ( n ) then str = n .. tab .. "=" .. tab end
	return str .. "{" .. nl .. MakeTable( t, nice ) .. "}"
end

--[[---------------------------------------------------------
	Name: table.Sanitise( table )
	Desc: Converts a table containing vectors, angles, bools so it can be converted to and from keyvalues
-----------------------------------------------------------]]
function table.Sanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do

		if ( istable( v ) and not done[ v ] ) then

			done[ v ] = true
			tbl[ k ] = table.Sanitise( v, done )

		else

			if ( type( v ) == "Vector" ) then

				local x, y, z = v.x, v.y, v.z
				if y == 0 then y = nil end
				if z == 0 then z = nil end
				tbl[ k ] = { __type = "Vector", x = x, y = y, z = z }

			elseif ( type( v ) == "Angle" ) then

				local p, y, r = v.pitch, v.yaw, v.roll
				if p == 0 then p = nil end
				if y == 0 then y = nil end
				if r == 0 then r = nil end
				tbl[ k ] = { __type = "Angle", p = p, y = y, r = r }

			elseif ( type( v ) == "boolean" ) then

				tbl[ k ] = { __type = "Bool", tostring( v ) }

			else

				tbl[ k ] = tostring( v )

			end

		end

	end

	return tbl

end

--[[---------------------------------------------------------
	Name: table.DeSanitise( table )
	Desc: Converts a Sanitised table back
-----------------------------------------------------------]]
function table.DeSanitise( t, done )

	local done = done or {}
	local tbl = {}

	for k, v in pairs ( t ) do

		if ( istable( v ) and not done[ v ] ) then

			done[ v ] = true

			if ( v.__type ) then

				if ( v.__type == "Vector" ) then

					tbl[ k ] = Vector( v.x, v.y, v.z )

				elseif ( v.__type == "Angle" ) then

					tbl[ k ] = Angle( v.p, v.y, v.r )

				elseif ( v.__type == "Bool" ) then

					tbl[ k ] = ( v[ 1 ] == "true" )

				end

			else

				tbl[ k ] = table.DeSanitise( v, done )

			end

		else

			tbl[ k ] = v

		end

	end

	return tbl

end

function table.ForceInsert( t, v )

	if ( t == nil ) then t = {} end

	table.insert( t, v )

	return t

end

--[[---------------------------------------------------------
	Name: table.SortByMember( table )
	Desc: Sorts table by named member
-----------------------------------------------------------]]
function table.SortByMember( Table, MemberName, bAsc )

	local TableMemberSort = function( a, b, MemberName, bReverse )

		--
		-- All this error checking kind of sucks, but really is needed
		--
		if ( not istable( a ) ) then return not bReverse end
		if ( not istable( b ) ) then return bReverse end
		if ( not a[ MemberName ] ) then return not bReverse end
		if ( not b[ MemberName ] ) then return bReverse end

		if ( type( a[ MemberName ] ) == "string" ) then

			if ( bReverse ) then
				return a[ MemberName ]:lower() < b[ MemberName ]:lower()
			else
				return a[ MemberName ]:lower() > b[ MemberName ]:lower()
			end

		end

		if ( bReverse ) then
			return a[ MemberName ] < b[ MemberName ]
		else
			return a[ MemberName ] > b[ MemberName ]
		end

	end

	table.sort( Table, function( a, b ) return TableMemberSort( a, b, MemberName, bAsc or false ) end )

end

--[[---------------------------------------------------------
	Name: table.LowerKeyNames( table )
	Desc: Lowercase the keynames of all tables
-----------------------------------------------------------]]
function table.LowerKeyNames( Table )

	local OutTable = {}

	for k, v in pairs( Table ) do

		-- Recurse
		if ( istable( v ) ) then
			v = table.LowerKeyNames( v )
		end

		OutTable[ k ] = v

		if ( isstring( k ) ) then

			OutTable[ k ]  = nil
			OutTable[ string.lower( k ) ] = v

		end

	end

	return OutTable

end

--[[---------------------------------------------------------
	Name: table.LowerKeyNames( table )
	Desc: Lowercase the keynames of all tables
-----------------------------------------------------------]]
function table.CollapseKeyValue( Table )

	local OutTable = {}

	for k, v in pairs( Table ) do

		local Val = v.Value

		if ( istable( Val ) ) then
			Val = table.CollapseKeyValue( Val )
		end

		OutTable[ v.Key ] = Val

	end

	return OutTable

end

--[[---------------------------------------------------------
	Name: table.ClearKeys( table, bSaveKey )
	Desc: Clears the keys, converting to a numbered format
-----------------------------------------------------------]]
function table.ClearKeys( Table, bSaveKey )

	local OutTable = {}

	for k, v in pairs( Table ) do
		if ( bSaveKey ) then
			v.__key = k
		end
		table.insert( OutTable, v )
	end

	return OutTable

end

local function keyValuePairs( state )

	state.Index = state.Index + 1

	local keyValue = state.KeyValues[ state.Index ]
	if ( not keyValue ) then return end

	return keyValue.key, keyValue.val

end

local function toKeyValues( tbl )

	local result = {}

	for k,v in pairs( tbl ) do
		table.insert( result, { key = k, val = v } )
	end

	return result

end

--[[---------------------------------------------------------
	A Pairs function
		Sorted by TABLE KEY
-----------------------------------------------------------]]
function SortedPairs( pTable, Desc )

	local sortedTbl = toKeyValues( pTable )

	if ( Desc ) then
		table.sort( sortedTbl, function( a, b ) return a.key > b.key end )
	else
		table.sort( sortedTbl, function( a, b ) return a.key < b.key end )
	end

	return keyValuePairs, { Index = 0, KeyValues = sortedTbl }

end

--[[---------------------------------------------------------
	A Pairs function
		Sorted by VALUE
-----------------------------------------------------------]]
function SortedPairsByValue( pTable, Desc )

	local sortedTbl = toKeyValues( pTable )

	if ( Desc ) then
		table.sort( sortedTbl, function( a, b ) return a.val > b.val end )
	else
		table.sort( sortedTbl, function( a, b ) return a.val < b.val end )
	end

	return keyValuePairs, { Index = 0, KeyValues = sortedTbl }

end

--[[---------------------------------------------------------
	A Pairs function
		Sorted by Member Value (All table entries must be a tablenot )
-----------------------------------------------------------]]
function SortedPairsByMemberValue( pTable, pValueName, Desc )

	local sortedTbl = toKeyValues( pTable )

	for k,v in pairs( sortedTbl ) do
		v.member = v.val[ pValueName ]
	end

	table.SortByMember( sortedTbl, "member", not Desc )

	return keyValuePairs, { Index = 0, KeyValues = sortedTbl }

end

--[[---------------------------------------------------------
	A Pairs function
-----------------------------------------------------------]]
function RandomPairs( pTable, Desc )

	local sortedTbl = toKeyValues( pTable )

	for k,v in pairs( sortedTbl ) do
		v.rand = math.random( 1, 1000000 )
	end

	-- descending/ascending for a random order, really?
	if ( Desc ) then
		table.sort( sortedTbl, function(a,b) return a.rand > b.rand end )
	else
		table.sort( sortedTbl, function(a,b) return a.rand < b.rand end )
	end

	return keyValuePairs, { Index = 0, KeyValues = sortedTbl }

end

--[[---------------------------------------------------------
	GetFirstKey
-----------------------------------------------------------]]
function table.GetFirstKey( t )
	local k, v = next( t )
	return k
end

function table.GetFirstValue( t )
	local k, v = next( t )
	return v
end

function table.GetLastKey( t )
	local k, v = next( t, table.Count( t ) - 1 )
	return k
end

function table.GetLastValue( t )
	local k, v = next( t, table.Count( t ) - 1 )
	return v
end

function table.FindNext( tab, val )
	local bfound = false
	for k, v in pairs( tab ) do
		if ( bfound ) then return v end
		if ( val == v ) then bfound = true end
	end

	return table.GetFirstValue( tab )
end

function table.FindPrev( tab, val )

	local last = table.GetLastValue( tab )
	for k, v in pairs( tab ) do
		if ( val == v ) then return last end
		last = v
	end

	return last

end

function table.GetWinningKey( tab )

	local highest = -10000
	local winner = nil

	for k, v in pairs( tab ) do
		if ( v > highest ) then
			winner = k
			highest = v
		end
	end

	return winner

end

function table.KeyFromValue( tbl, val )
	for key, value in pairs( tbl ) do
		if ( value == val ) then return key end
	end
end

function table.RemoveByValue( tbl, val )

	local key = table.KeyFromValue( tbl, val )
	if ( not key ) then return false end

	table.remove( tbl, key )
	return key

end

function table.KeysFromValue( tbl, val )
	local res = {}
	for key, value in pairs( tbl ) do
		if ( value == val ) then res[ #res + 1 ] = key end
	end
	return res
end

function table.Reverse( tbl )

	local len = #tbl
	local ret = {}

	for i = len, 1, -1 do
		ret[ len - i + 1 ] = tbl[ i ]
	end

	return ret

end

function table.ForEach( tab, funcname )

	for k, v in pairs( tab ) do
		funcname( k, v )
	end

end

function table.GetKeys( tab )

	local keys = {}
	local id = 1

	for k, v in pairs( tab ) do
		keys[ id ] = k
		id = id + 1
	end

	return keys
end

function table.enum(a)
    local t = {}
    for k,v in pairs(a) do t[v] = k end
    return t
end

function table.tonumber( ... )
	local args = {...}

	if type(args[1]) == "table" then
		args = args[1]
	end

	local tableTemp = {}

	for k, v in pairs(args) do
		tableTemp[k] = tonumber(v)
	end

	return unpack(tableTemp)
end

function table.next( tbl )
	for k, v in pairs(tbl) do
		if type(k) == "number" then
			table.remove(tbl, k)
		else
			tbl[k] = nil
		end

		return v
	end
end

local type = type
local rawset = rawset
local rawget = rawget

local array_mt
array_mt = {
    __index = function(t, k)
        local i = tostring(k):sub(1, 1) == "#"
        local v = rawget(t, i and k:sub(2, k:len()) or k)
        if not v and not i then
            v = {}
            rawset(t, k, array(v))
        else
            if type(v) == "table" then
                setmetatable(v, array_mt)
            end
        end
        return v
    end,
    __newindex = function(t, k, v)
        if type(v) == "table" then
            array(v)
        end
        rawset(t, k, v)
    end
}

function array(tab)
    local tab = tab or {}

    for k,v in pairs(tab) do
        if type(v) == "table" then
            array(v)
        end
    end

    setmetatable(tab, array_mt)

    return tab
end

function table.lockTable( t )
    setmetatable(t, {
        __newindex = function(_, key, value)
            local msg = print or printc
            msg("LOCKTABLE: attempt to update a read-only table, operation " .. tostring(key) .. " = " .. tostring(value) .. " not performed\n"..debugstack(2))
        end,
		__metatable = false
    })
end