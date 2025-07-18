ezSpectator_AuraFrame = {}
ezSpectator_AuraFrame.__index = ezSpectator_AuraFrame

function ezSpectator_AuraFrame:Create(Parent, alignLeft, alignTop, ...)
    local self = {}
    setmetatable(self, ezSpectator_AuraFrame)

    self.Parent = Parent

	self.perRow = 9
	self.drawDebuffsFirst = false

	self.iconSize = 20
	self.iconOffsetX = 4
	self.iconOffsetY = 4

	self.showBuffs = true
	self.showDebuffs = true

	self.alignTop = true
	self.alignLeft = true

    self.MainFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.MainFrame:SetFrameLevel(1)
	self.MainFrame:SetSize(192 - 16, 1)
    self.MainFrame:SetScale(_ezSpectatorScale)
    self.MainFrame:SetPoint(...)

	self.buffList = {}
	self.debuffList = {}

	self.buffIcons = {}
	self.debuffIcons = {}

	self.activeIcons = {}
	self.inactiveIcons = {}

    return self
end

function ezSpectator_AuraFrame:Show()
    self.MainFrame:Show()
end

function ezSpectator_AuraFrame:Hide()
    self.MainFrame:Hide()
end

function ezSpectator_AuraFrame:Reset()
	table.wipe(self.buffList)
	table.wipe(self.debuffList)
	table.wipe(self.buffIcons)
	table.wipe(self.debuffIcons)
	self:FreeAllIcons()
end

function ezSpectator_AuraFrame:SetAlpha(Value)
    self.MainFrame:SetAlpha(Value)
end

function ezSpectator_AuraFrame:SetAlignment(alignLeft, alignTop)
	if self.alignLeft ~= alignLeft or self.alignTop ~= alignTop then
		self.alignLeft = alignLeft
		self.alignTop = alignTop
		self:UpdateIconPosition()
	end
end

function ezSpectator_AuraFrame:SetShowBuffs(showBuffs)
	self.showBuffs = showBuffs
end

function ezSpectator_AuraFrame:SetShowDebuffs(showDebuffs)
	self.showDebuffs = showDebuffs
end

function ezSpectator_AuraFrame:CreateIcon()
	local icon = ezSpectator_AuraIcon:Create(self.Parent, self.MainFrame, self.iconSize - 4)
	icon:Hide()
	return icon
end

function ezSpectator_AuraFrame:AcquireIcon()
	local numInactiveIcons = #self.inactiveIcons
	if numInactiveIcons > 0 then
		local icon = self.inactiveIcons[numInactiveIcons]
		table.insert(self.activeIcons, icon)
		self.inactiveIcons[numInactiveIcons] = nil
		return icon
	end

	local icon = self:CreateIcon()
	if icon then
		table.insert(self.activeIcons, icon)
		return icon
	end
end

function ezSpectator_AuraFrame:FreeIcon(icon)
	local index = tIndexOf(self.activeIcons, icon)
	if index then
		icon.auraIndex = nil
		icon.auraInfo = nil
		icon:Hide()
		icon:ClearAllPoints()

		table.insert(self.inactiveIcons, icon)
		table.remove(self.activeIcons, index)
	end
end

function ezSpectator_AuraFrame:FreeAllIcons()
	for index = #self.activeIcons, 1, -1 do
		self:FreeIcon(self.activeIcons[index])
	end
end

function ezSpectator_AuraFrame:GetAligmentPoints()
	if self.alignTop then
		if self.alignLeft then
			return "TOPLEFT", "BOTTOMLEFT"
		else
			return "TOPRIGHT", "BOTTOMRIGHT"
		end
	else
		if self.alignLeft then
			return "BOTTOMLEFT", "TOPLEFT"
		else
			return "BOTTOMRIGHT", "TOPRIGHT"
		end
	end
end

function ezSpectator_AuraFrame:UpdateIconListPosition(iconList, anchor, offsetY)
	local point, relativePoint = self:GetAligmentPoints()

	for index, icon in ipairs(iconList) do
		icon:ClearAllPoints()

		if index == 1 or (index % self.perRow == 1) then
			local iconOffsetY
			if index == 1 then
				iconOffsetY = self.alignTop and -offsetY or offsetY
			else
				iconOffsetY = self.alignTop and -self.iconOffsetY or self.iconOffsetY
			end

			icon:SetPoint(point, anchor, relativePoint, 0, iconOffsetY)

			anchor = icon.MainFrame
		else
			if self.alignLeft then
				icon:SetPoint("TOPLEFT", iconList[index - 1].MainFrame, "TOPRIGHT", self.iconOffsetX, 0)
			else
				icon:SetPoint("TOPRIGHT", iconList[index - 1].MainFrame, "TOPLEFT", -self.iconOffsetX, 0)
			end
		end
	end

	return anchor
end

function ezSpectator_AuraFrame:UpdateIconPosition()
	local anchor = self.MainFrame
	local offsetY = 0

	if self.drawDebuffsFirst then
		if self.showDebuffs then
			anchor = self:UpdateIconListPosition(self.buffIcons, anchor, offsetY)
			offsetY = offsetY + 10
		end
		if self.showBuffs then
			self:UpdateIconListPosition(self.debuffIcons, anchor, offsetY)
		end
	else
		if self.showBuffs then
			anchor = self:UpdateIconListPosition(self.debuffIcons, anchor, offsetY)
			offsetY = offsetY + 10
		end
		if self.showDebuffs then
			self:UpdateIconListPosition(self.buffIcons, anchor, offsetY)
		end
	end
end

function ezSpectator_AuraFrame:GetAurasIconForAuraInfo(auraInfo)
	local isDebuff = auraInfo.isDebuff
	local auraList = isDebuff and self.debuffList or self.buffList
	local iconList = isDebuff and self.debuffIcons or self.buffIcons
	local auraListIndex = tIndexOf(auraList, auraInfo)
	return iconList[auraListIndex]
end

function ezSpectator_AuraFrame:UpdateAurasIcon(auraInfo, icon, forceAnimation)
	if auraInfo._AWAIT_UPDATE then
		local skipFadeAnimation = not auraInfo._AWAIT_UPDATE
		icon:SetAuraInfo(auraInfo, skipFadeAnimation or forceAnimation)
		auraInfo._AWAIT_UPDATE = nil
	end
end

function ezSpectator_AuraFrame:OnAuraUpdate(auraInfo, auraIndex)
	local icon = self:GetAurasIconForAuraInfo(auraInfo)
	self:UpdateAurasIcon(auraInfo, icon)
end

function ezSpectator_AuraFrame:OnAuraAdd(auraInfo)
	local isDebuff = auraInfo.isDebuff
	local auraList = isDebuff and self.debuffList or self.buffList
	local iconList = isDebuff and self.debuffIcons or self.buffIcons

	local icon = self:AcquireIcon()
	self:UpdateAurasIcon(auraInfo, icon)

	table.insert(auraList, auraInfo)
	table.insert(iconList, icon)

	self:UpdateIconPosition()
end

function ezSpectator_AuraFrame:OnAuraRemove(auraInfo)
	if auraInfo.isDebuff then
		local debuffIndex = tIndexOf(self.debuffList, auraInfo)
		if debuffIndex then
			table.remove(self.debuffList, debuffIndex)

			local icon = table.remove(self.debuffIcons, debuffIndex)
			self:FreeIcon(icon)
		end
	else
		local buffIndex = tIndexOf(self.buffList, auraInfo)
		if buffIndex then
			table.remove(self.buffList, buffIndex)

			local icon = table.remove(self.buffIcons, buffIndex)
			self:FreeIcon(icon)
		end
	end

	self:UpdateIconPosition()
end

function ezSpectator_AuraFrame:GetBestCrowdControlAura(minPriority, currentCCAuraInfo)
	local priorityInfo = self.Parent.Data.CrowdControlPriority
	local maxPriority = minPriority or 1
	local ccAura

	local now
	local currentTimeLeft

	if currentCCAuraInfo and currentCCAuraInfo.castTime then
		now = C_ArenaSpectator.GetMatchTime()
		currentTimeLeft = (currentCCAuraInfo.duration / 1000) - (now - currentCCAuraInfo.castTime)
	end

	for index, auraInfo in ipairs(self.debuffList) do
		local priority = priorityInfo[auraInfo.spellID]
		if priority and priority >= maxPriority then
			if currentTimeLeft then
				local timeLeft = (auraInfo.duration / 1000) - (now - auraInfo.castTime)
				if timeLeft >= currentTimeLeft then
					maxPriority = priority
					ccAura = auraInfo
				end
			else
				maxPriority = priority
				ccAura = auraInfo
			end
		end
	end
	for index, auraInfo in ipairs(self.buffList) do
		local priority = priorityInfo[auraInfo.spellID]
		if priority and priority >= maxPriority then
			if currentTimeLeft then
				local timeLeft = auraInfo.duration - (now - auraInfo.castTime)
				if timeLeft >= currentTimeLeft then
					maxPriority = priority
					ccAura = auraInfo
				end
			else
				maxPriority = priority
				ccAura = auraInfo
			end
		end
	end

	return maxPriority, ccAura
end

function ezSpectator_AuraFrame:FindAuraBySpellForCaster(spellID, isDebuff, casterGUID)
	local auraList = isDebuff and self.debuffList or self.buffList
	for index, auraInfo in ipairs(auraList) do
		if auraInfo.spellID == spellID and (auraInfo.casterGUID == casterGUID) then
			return auraInfo, index
		end
	end
end

function ezSpectator_AuraFrame:SetAura(spellID, isRemoved, stackCount, expirationTime, duration, debuffType, isDebuff, casterGUID)
	if (isDebuff and not self.showDebuffs)
	or (not isDebuff and not self.showBuffs)
	then
		return
	end

	local spellIcon = select(3, GetSpellInfo(spellID))
	if not spellIcon then
		return
	end

	local auraInfo, auraIndex = self:FindAuraBySpellForCaster(spellID, isDebuff, casterGUID)
	if auraInfo then
		if auraInfo.isDebuff ~= isDebuff then
			-- remove old
			self:OnAuraRemove(auraInfo)

			-- treat as new
			auraIndex = nil
			auraInfo = {_AWAIT_UPDATE = true}
		elseif auraInfo.stackCount ~= stackCount
		or auraInfo.expirationTime ~= expirationTime
		or auraInfo.duration ~= duration
		then
			auraInfo._AWAIT_UPDATE = true
		end
	elseif isRemoved then
		return
	else
		auraInfo = {_AWAIT_UPDATE = true}
	end

	if isRemoved then
		self:OnAuraRemove(auraInfo)
	else
		auraInfo.spellID = spellID
		auraInfo.debuffType = debuffType
		auraInfo.isDebuff = isDebuff
		auraInfo.casterGUID = casterGUID
		auraInfo.stackCount = stackCount
		auraInfo.expirationTime = expirationTime
		auraInfo.duration = duration

		if auraIndex then
			self:OnAuraUpdate(auraInfo, auraIndex)
		else
			auraInfo.castTime = C_ArenaSpectator.GetMatchTime()
			self:OnAuraAdd(auraInfo)
		end
	end
end