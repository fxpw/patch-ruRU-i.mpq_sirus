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

do	-- UnitInRangeIndex
	local ITEM_FRIENDLY = {
		[40] = 34471,
	}
	local UNIT_RANGE_INDEXES = {10, 28, 38, 40}

	local eventHandler = CreateFrame("Frame")
	eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventHandler:SetScript("OnEvent", function(self, event)
		for _, itemID in pairs(ITEM_FRIENDLY) do
			C_Item.RequestServerCache(itemID)
		end
		self:UnregisterEvent(event)
	end)

	function UnitInRangeIndex(unit, rangeIndex)
		if rangeIndex == 0 then
			return true
		elseif not UnitExists(unit) or not UNIT_RANGE_INDEXES[rangeIndex] then
			return false
		elseif UnitIsUnit(unit, "player") then
			return true
		end

		local range = UNIT_RANGE_INDEXES[rangeIndex]

		if range == 10 then
			return CheckInteractDistance(unit, 3) == 1
		elseif range == 28 then
			return CheckInteractDistance(unit, 1) == 1
		elseif range == 38 then
			return UnitInRange(unit) == 1
		elseif ITEM_FRIENDLY[range] then
			local itemID = ITEM_FRIENDLY[range]
			local result = IsItemInRange(itemID, unit)
			if not result or result == -1 then
				-- invalide spell, fallback to 38yrd check
				return UnitInRange(unit) == 1
			else
				return result == 1
			end
		end
	end
end

do	-- PlayerHasHearthstone | UseHearthstone
	local NUM_BAG_FRAMES = 4

	---@return integer? hearthstoneID
	---@return integer? bagID
	---@return integer? slotID
	function PlayerHasHearthstone()
		for bagID = 0, NUM_BAG_FRAMES + 1 do
			for slotID = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, link = GetContainerItemInfo(bagID, slotID)
				if link then
					local itemID = tonumber(string.match(link, "item:(%d+)"))
					if itemID == 6948 then
						return itemID, bagID, slotID
					end
				end
			end
		end
	end

	local PlayerHasHearthstone = PlayerHasHearthstone
	function UseHearthstone()
		local hearthstoneID, bagID, slotID = PlayerHasHearthstone()
		if bagID then
			UseContainerItem(bagID, slotID)
		end
	end
end