---@class C_CacheMixin : Mixin
C_CacheMixin = {}

function C_CacheMixin:OnLoad()
    self:RegisterHookListener()

    if not GetSafeCVar("showToolsUI") and RegisterCVar then
        RegisterCVar("showToolsUI", "return {}")
    end

    self:SetSavedState(false)
    self._cache = {}

	if not IsOnGlueScreen() then
		self:LoadData()
	end
end

function C_CacheMixin:SetSavedState( isSaved )
    self.savedData = isSaved
end

function C_CacheMixin:GetSavedState()
    return self.savedData
end

function C_CacheMixin:PLAYER_LOGOUT()
    if not self:GetSavedState() then
        SetSafeCVar("showToolsUI", "return {}")
    end
end

function C_CacheMixin:VARIABLES_LOADED()
	self:LoadData()
end

function C_CacheMixin:SaveData()
    self:SetSavedState(true)
    SetSafeCVar("showToolsUI", DataDumper(self._cache))
end

local function tableCopyUnique(to, from)
	for key, value in pairs(from) do
		if to[key] == nil then
			to[key] = value
		elseif type(value) == "table" and type(to[key]) == "table" then
			tableCopyUnique(to[key], value)
		end
	end
end

function C_CacheMixin:LoadData()
	local isSuccess, data = pcall(function()
		return loadstring(strconcat("return (function() ", GetSafeCVar("showToolsUI", "return {}"), " end)()"))()
	end)

	if self._cache and next(self._cache) == nil then
		if isSuccess then
			self._cache = data
		end
	elseif isSuccess then
		tableCopyUnique(self._cache, data)
	end
end

---@param key string
---@param value string | table | boolean | number
---@param timeToLife? number
function C_CacheMixin:Set( key, value, timeToLife )
    self._cache[key] = {
        ttl = timeToLife and timeToLife + time() or 0,
        value = value
    }
end

---@param key string
---@param value? string | table | boolean | number
---@param timeToLife? number
function C_CacheMixin:Get( key, value, timeToLife )
	local expiredTTL
    if (self._cache[key] and self._cache[key].ttl) and self._cache[key].ttl ~= 0 and self._cache[key].ttl < time() then
        self._cache[key] = nil
		expiredTTL = true
    end

    if not self._cache[key] then
        if value then
            self._cache[key] = {
                ttl = timeToLife and timeToLife + time() or 0,
                value = value
            }
        else
            return nil, expiredTTL
        end
    end

    return self._cache[key].value, expiredTTL
end

---@class C_CacheInstance : C_CacheMixin
C_CacheInstance = CreateFromMixins(C_CacheMixin)
C_CacheInstance:OnLoad()