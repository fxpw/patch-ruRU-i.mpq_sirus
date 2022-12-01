
local pairs = pairs;
local select = select;
local type = type;
local strformat = string.format

-- where ​... are the mixins to mixin
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		if type(mixin) == "table" then
			for k, v in pairs(mixin) do
				object[k] = v;
			end
		else
			geterrorhandler()(strformat("Bad argument #%i to \"Mixin\" (table expected, got %s)", i + 1, type(mixin)))
		end
	end

	object["RegisterEventListener"] = function(self)
		EventHandler:RegisterListener(self)
	end

	object["RegisterHookListener"] = function(self)
		Hook:RegisterListener(self)
	end

	object["RegisterCallbacks"] = function(self, ...)
		for _, callbackHandler in pairs({...}) do
			if type(object[callbackHandler]) ~= "function" then
				error(strformat("Cannot find event handler for event %s", callbackHandler), 2)
			end

			Hook:RegisterCallback(tostring(object), callbackHandler, function(...)
				object[callbackHandler](object, ...)
			end)
		end
	end

	return object;
end

local PrivateMixin = Mixin;

-- where ​... are the mixins to mixin
function CreateFromMixins(...)
	return PrivateMixin({}, ...)
end

local PrivateCreateFromMixins = CreateFromMixins;

function CreateAndInitFromMixin(mixin, ...)
	local object = PrivateCreateFromMixins(mixin);
	object:Init(...);
	return object;
end

-- Note: This should only be used for security purposes during the initial load process in-game.
function CreateSecureMixinCopy(mixin)
	local mixinCopy = PrivateMixin({}, mixin);
	setmetatable(mixinCopy, { __metatable = false, });
	return mixinCopy;
end