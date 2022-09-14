local appendArray = function(array, ...)
	for i = 1, select("#", ...) do
		array[#array + 1] = select(i, ...)
	end
	return array
end

do	-- CreateAnimationGroupOfGroups
	local animationGroupMT
	local animationGroupMTOverrides = {
		GetAnimations = function(self)
			local animations = {}
			for _, animGroup in ipairs(self) do
				appendArray(animations, animGroup:GetAnimations())
			end
			return unpack(animations)
		end,
		Pause = function(self)
			for _, animGroup in ipairs(self) do
				animGroup:Pause()
			end
		end,
		Play = function(self)
			for _, animGroup in ipairs(self) do
				animGroup:Play()
			end
		end,
		Stop = function(self)
			for _, animGroup in ipairs(self) do
				if animGroup:IsPlaying() then
					animGroup:Stop()
				end
			end
		end,
		GetName = function(self)
			local name = self[1]:GetName()
			if name then
				return string.format("%sVirtualAnimGroup", name)
			end
		end,
	}
	local virtualAnimationGroupMT = {
		__index = function(self, key)
			if animationGroupMTOverrides[key] then
				return animationGroupMTOverrides[key]
			elseif animationGroupMT and type(animationGroupMT[key]) == "function" then
				return function(this, ...)
					return animationGroupMT[key](this[1], ...)
				end
			end
		end,
		__metatable = false,
	}

	function CreateAnimationGroupOfGroups(obj, ...)
		if type(obj) ~= "table" or select("#", ...) == 0 then
			error("Usage: CreateVirtualAnimationGroup(obj, animation, ...)", 2)
		end

		local virtualGroup = {}

		for i = 1, select("#", ...) do
			local animGroup = select(i, ...)
			if type(animGroup) ~= "table" then
				error(string.format("CreateAnimationGroupOfGroups: Incorrect argument #%i object type (table expected, got %s)", i + 1, type(animGroup)), 2)
			elseif animGroup:GetObjectType() ~= "AnimationGroup" then
				error(string.format("CreateAnimationGroupOfGroups: Incorrect argument #%i widget type (table expected, got %s)", i + 1, animGroup:GetObjectType()), 2)
			else
				virtualGroup[i] = animGroup
			end
		end

		if not animationGroupMT then
			animationGroupMT = getmetatable(virtualGroup[1]).__index
		end

		setmetatable(virtualGroup, virtualAnimationGroupMT)

		return virtualGroup
	end
end

do	-- SetEveryoneIsAssistant
	local isEveryoneAssistant = false

	function EventHandler:ASMSG_SET_EVERYONE_IS_ASSISTANT(msg)
		isEveryoneAssistant = tonumber(msg) == 1
	end

	function IsEveryoneAssistant()
		return isEveryoneAssistant
	end

	local IsRaidLeader = IsRaidLeader
	function SetEveryoneIsAssistant(state)
		if IsRaidLeader() then
			SendServerMessage("ACMSG_SET_EVERYONE_IS_ASSISTANT", state and 1 or 0)
		end
	end
end

do	-- UnitIsGroupLeader
	local PARTY_UNITS = {
		party1 = 1,
		party2 = 2,
		party3 = 3,
		party4 = 4,
	}

	function UnitIsGroupLeader(unit)
		if UnitIsUnit("player", unit) then
			return IsPartyLeader()
		else
			local raidID = UnitInRaid(unit)
			if raidID then
				return select(2, GetRaidRosterInfo(raidID + 1)) == 2
			elseif UnitInParty(unit) then
				local unitIndex = PARTY_UNITS[unit]
				if not unitIndex then
					for partyUnit, partyUnitIndex in pairs(PARTY_UNITS) do
						if UnitIsUnit(partyUnit, unit) then
							unitIndex = partyUnitIndex
							break
						end
					end
				end

				if unitIndex then
					return GetPartyLeaderIndex() == unitIndex
				end
			end
		end

		return false
	end
end