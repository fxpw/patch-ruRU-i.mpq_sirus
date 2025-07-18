ezSpectator_CooldownFrame = {}
ezSpectator_CooldownFrame.__index = ezSpectator_CooldownFrame

function ezSpectator_CooldownFrame:Create(parent)
	local self = {}
	setmetatable(self, ezSpectator_CooldownFrame)

	self.perRow = 22
	self.numRows = 1
	self.maxIcons = self.perRow * self.numRows
	self.iconSize = 27
	self.textureSize = self.iconSize * 0.70

	self.iconOffsetX = 0
	self.iconOffsetY = 0

	self.Parent = parent

	self.MainFrame = CreateFrame("Frame", nil, ArenaSpectatorFrame)
	self.MainFrame:SetFrameLevel(1)
	self.MainFrame:SetFrameStrata("HIGH")
	self.MainFrame:SetScale(_ezSpectatorScale)
	self.MainFrame:SetSize(1, 1)

	self.CooldownLinks = {}
	self.CooldownIcons = {}
	self.activeIcons = {}
	self.inactiveIcons = {}

	self.UpdateFrame = CreateFrame("Frame", nil, ArenaSpectatorFrame)
	self.UpdateFrame.elapsed = 0
	self.UpdateFrame:SetScript("OnUpdate", function(this, elapsed)
		if C_ArenaSpectator.IsPaused() then
			return
		end

		local speed = C_ArenaSpectator.GetPlaybackSpeed()
		this.elapsed = this.elapsed + elapsed * speed

		if this.elapsed >= 1 then
			local listChanged
			local index = 1
			local icon = self.activeIcons[index]
			while icon do
				icon.cooldownTime = math.max(0, icon.cooldownTime - this.elapsed)
				icon:SetTime(icon.cooldownTime)

				if icon.cooldownTime == 0 then
					self:FreeIcon(icon)
					listChanged = true
				else
					index = index + 1
				end

				icon = self.activeIcons[index]
			end

			this.elapsed = 0

			if listChanged then
				self:UpdateIconPosition()
			end
		end
	end)

	return self
end

function ezSpectator_CooldownFrame:Show()
	self.MainFrame:Show()
end

function ezSpectator_CooldownFrame:Hide()
	self.MainFrame:Hide()
	self:FreeAllIcons()
end

function ezSpectator_CooldownFrame:SetDisplaySettings(perRow, numRows)
	self.perRow = perRow
	self.numRows = numRows
	self.maxIcons = self.perRow * self.numRows
	self:UpdateIconPosition()
end

function ezSpectator_CooldownFrame:SetAlignment(alignLeft)
	if self.alignLeft ~= alignLeft then
		self.alignLeft = alignLeft
		self:UpdateIconPosition()
	end
end

function ezSpectator_CooldownFrame:CreateIcon()
	local numIcons = #self.CooldownIcons
	if numIcons >= self.maxIcons then
		return
	end

	local icon = ezSpectator_ClickIcon:Create(self.Parent, self.MainFrame, "mild", self.iconSize, "TOPLEFT", self.MainFrame, "TOPLEFT", 0, 0)
	icon:Hide()
	icon:SetTextInteractive(true)
	icon.Cooldown:SetReverse(true)

	icon.Reactor:SetScript("OnMouseUp", function(this)
		if icon.Backdrop:IsShown() and icon.spellID then
			icon.Parent.Tooltip:ShowSpell(icon.Backdrop, icon.spellID, true)
		end
	end)

	tinsert(self.CooldownIcons, icon)

	return icon
end

function ezSpectator_CooldownFrame:AcquireIcon()
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

function ezSpectator_CooldownFrame:FreeIcon(icon)
	local index = tIndexOf(self.activeIcons, icon)
	if index then
		if icon.spellID then
			self.CooldownLinks[icon.spellID] = nil
		end

	--	icon:SetTexture(nil, self.textureSize, false)
		icon.spellID = nil
		icon.cooldownTime = nil
		icon.Cooldown:Clear()
		icon:Hide()

		table.insert(self.inactiveIcons, icon)
		table.remove(self.activeIcons, index)
	end
end

function ezSpectator_CooldownFrame:FreeAllIcons()
	table.wipe(self.CooldownLinks)

	for index = #self.activeIcons, 1, -1 do
		self:FreeIcon(self.activeIcons[index])
	end
end

function ezSpectator_CooldownFrame:UpdateIconPosition()
	for index, icon in ipairs(self.activeIcons) do
		if index == 1 then
			if self.alignLeft then
				icon:SetPoint("TOPLEFT", self.MainFrame, "BOTTOMLEFT", 0, 0)
			else
				icon:SetPoint("TOPRIGHT", self.MainFrame, "BOTTOMRIGHT", 0, 0)
			end
		elseif index % self.perRow == 1 then
			if self.alignLeft then
				icon:SetPoint("TOPLEFT", self.activeIcons[index - self.perRow].Normal, "BOTTOMLEFT", 0, -self.iconOffsetY)
			else
				icon:SetPoint("TOPRIGHT", self.activeIcons[index - self.perRow].Normal, "BOTTOMRIGHT", 0, -self.iconOffsetY)
			end
		else
			if self.alignLeft then
				icon:SetPoint("TOPLEFT", self.activeIcons[index - 1].Normal, "TOPRIGHT", self.iconOffsetX, 0)
			else
				icon:SetPoint("TOPRIGHT", self.activeIcons[index - 1].Normal, "TOPLEFT", -self.iconOffsetX, 0)
			end
		end
	end
end

function ezSpectator_CooldownFrame:StartCooldown(unitName, spellID, cooldownTime)
	if not cooldownTime or cooldownTime < 0 then
		return
	end

	if self.Parent.Data.CooldownBlacklist[spellID] or self.Parent.Data.Trinkets[spellID] then
		return
	end

	local icon = self.CooldownLinks[spellID]
	if icon then
		local index = tIndexOf(self.activeIcons, icon)
		self.CooldownLinks[spellID]:SetCooldown(C_ArenaSpectator.GetMatchTime(), cooldownTime)
		self.CooldownLinks[spellID]:SetTime(cooldownTime)
		-- move icon in array to change display order
		table.remove(self.activeIcons, index)
		table.insert(self.activeIcons, icon)
		self:UpdateIconPosition()
	else
		icon = self:AcquireIcon()
		if not icon then
			return
		end

		icon.cooldownTime = cooldownTime
		icon.spellID = spellID

		local spellIcon
		if self.Parent.Data.Trinkets[spellID] then
			spellIcon = [[Interface\Icons\INV_Jewelry_TrinketPVP_02]]
		else
			spellIcon = select(3, GetSpellInfo(spellID)) or [[Interface\Icons\INV_Misc_QuestionMark]]
		end

		local classID = self.Parent.Interface.Players[unitName].Class or 1
		icon:SetBorderClassColor(classID)
		icon:SetTexture(spellIcon, self.textureSize, true)
		icon:SetCooldown(C_ArenaSpectator.GetMatchTime(), cooldownTime)
		icon:SetTime(cooldownTime)
		icon:Show()

		self.CooldownLinks[spellID] = icon
		self:UpdateIconPosition()
	end
end