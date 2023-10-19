C_Cache = setmetatable({
	items = {}
},
{
	__call = function(self, cacheKey, isLocal)
		function itemKey(isGlobal)
			return (isLocal and not isGlobal) and UnitName("player") or "__global__"
		end

		_G[cacheKey] = {}

		local cache = setmetatable({
			Set = function(this, key, value, ttl, isGlobal)
				if not key then
					return nil
				end

				ttl = ttl or 0

				local items = _G[cacheKey]
				local itemKey = itemKey(isGlobal)
				if not items[itemKey] then
					items[itemKey] = {}
				end
				items[itemKey][key] = {
					ttl = ttl == 0 and 0 or time() + ttl,
					value = value
				}
			end,
			Get = function(this, key, value, ttl, global)
				local itemKey = itemKey(global)
				local items = _G[cacheKey]
				if items[itemKey] or value then
					if not items[itemKey] then
						items[itemKey] = {}
					end
					local item = items[itemKey][key]

					if item and (item.ttl ~= 0 and item.ttl < time()) then
						item = nil
						items[itemKey][key] = nil
					end

					if item then
						return item.value
					elseif value then
						rawget(this, "Set")(this, key, value, ttl)
						return value
					end
				end
			end,
			Clear = function(this, key, isGlobal)
				local itemKey = itemKey(isGlobal)
				local items = _G[cacheKey]
				if items[itemKey] then
					if key then
						if items[itemKey][key] then
							items[itemKey][key] = nil
						end
					else
						table.wipe(items[itemKey])
					end
				end
			end,
			ClearAll = function(this)
				table.wipe(_G[cacheKey])
			end,
			GetRaw = function(this, isGlobal)
				local itemKey = itemKey(isGlobal)
				local items = _G[cacheKey]
				return items[itemKey]
			end,
		}, {
			__index = function(this, key)
				return rawget(this, "Get")(this, key)
			end,
			__newindex = function(this, key, value)
				rawget(this, "Set")(this, key, value, 0)
			end
		})

		self.items[cacheKey] = cache
		RegisterForSave(cacheKey)

		return cache
	end
})