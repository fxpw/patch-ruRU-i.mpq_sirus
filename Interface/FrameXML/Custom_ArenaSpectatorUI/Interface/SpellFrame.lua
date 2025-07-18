ezSpectator_SpellFrame = {}
ezSpectator_SpellFrame.__index = ezSpectator_SpellFrame

function ezSpectator_SpellFrame:Create(Parent, maxIcons, ...)
    local self = {}
    setmetatable(self, ezSpectator_SpellFrame)

    self.Parent = Parent

	self.icons = {}
	self.maxIcons = maxIcons

    self.MainFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.MainFrame:SetSize(1, 1)
    self.MainFrame:SetScale(_ezSpectatorScale)

	for index = 1, self.maxIcons do
		self.icons[index] = ezSpectator_SpellIcon:Create(self.Parent, self.MainFrame)
	end

    return self
end

function ezSpectator_SpellFrame:Show()
    self.MainFrame:Show()
end

function ezSpectator_SpellFrame:Hide()
    self.MainFrame:Hide()
end

function ezSpectator_SpellFrame:ClearAllPoints(...)
	self.MainFrame:ClearAllPoints(...)
end

function ezSpectator_SpellFrame:SetPoint(...)
	self.MainFrame:SetPoint(...)
end

function ezSpectator_SpellFrame:SetAlpha(Value)
    self.MainFrame:SetAlpha(Value)
end

function ezSpectator_SpellFrame:SetAlignment(alignLeft)
	if self.alignLeft ~= alignLeft then
		self.alignLeft = alignLeft
		self:UpdateIconPosition()
	end
end

function ezSpectator_SpellFrame:UpdateIconPosition()
	local relativeTo
	for index, icon in ipairs(self.icons) do
		if index == 1 then
			relativeTo = self.MainFrame
		else
			relativeTo = self.icons[index - 1].Normal
		end

		icon.Normal:ClearAllPoints()

		if self.alignLeft then
			icon.Normal:SetPoint("LEFT", relativeTo, "RIGHT", -3, 0)
		else
			icon.Normal:SetPoint("RIGHT", relativeTo, "LEFT", 3, 0)
		end
	end
end

function ezSpectator_SpellFrame:LogSpellCast(spellID)
	if self.Parent.Data.CastBlacklist[spellID] then
		return
	end

	local spellIcon
	if self.Parent.Data.Trinkets[spellID] then
		spellIcon = [[Interface\Icons\INV_Jewelry_TrinketPVP_02]]
	else
		spellIcon = select(3, GetSpellInfo(spellID)) or [[Interface\Icons\INV_Misc_QuestionMark]]
	end

	for index = self.maxIcons, 2, -1 do
		local previousIcon = self.icons[index - 1]
		self.icons[index]:SetSpell(previousIcon.spellID, previousIcon.spellIcon, previousIcon.Normal:GetAlpha())
	end

	self.icons[1]:SetSpell(spellID, spellIcon, 1)
end