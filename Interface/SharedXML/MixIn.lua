
-- Mixin code
function Mixin(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		if type(mixin) == "table" then
			for k, v in pairs(mixin) do
				object[k] = v
			end
		else
			geterrorhandler()(string.format("Bad argument #%i to \"Mixin\" (table expected, got %s)", i + 1, type(mixin)))
		end
	end

	object["RegisterEventListener"] = function(self)
		--printec("Mixin:RegisterEventListener", self, EventHandler)
		EventHandler:RegisterListener(self)
	end

	object["RegisterHookListener"] = function(self)
		--printec("Mixin:RegisterHookListener", self, Hook)
		Hook:RegisterListener(self)
	end

	-- Connect hooks
	object["RegisterCallbacks"] = function(_ , ...)
		for _ ,v in pairs({ ...}) do
			assert(object[v] ~= nil, string.format("Обработчик колбека %s не обнаружен в миксине", v))

			Hook:RegisterCallback(tostring(object), v, function(...)
				object[v](object, ...)
			end)
		end
	end

	return object
end

function CreateFromMixins(...)
	return Mixin({ }, ...)
end

function CreateAndInitFromMixin(mixin, ...)
	local object = CreateFromMixins(mixin);
	object:Init(...);
	return object;
end