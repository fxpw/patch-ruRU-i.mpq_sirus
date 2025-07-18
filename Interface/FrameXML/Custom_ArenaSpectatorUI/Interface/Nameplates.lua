ezSpectator_Nameplates = {}
ezSpectator_Nameplates.__index = ezSpectator_Nameplates

function ezSpectator_Nameplates:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_Nameplates)

    self.Parent = Parent

	self.lastChildern = 0
	self.numChildren = 0
	self.nameplates = {}

	self.EventFrame = CreateFrame("Frame")
	self.EventFrame:Hide()
	self.EventFrame:SetScript("OnUpdate", function(this, elapsed)
		self.numChildren = WorldFrame:GetNumChildren()
		if self.lastChildern ~= self.numChildren then
			self:FindNewNamePlates(WorldFrame:GetChildren())
			self.lastChildern = self.numChildren
		end
	end)

    return self
end

function ezSpectator_Nameplates:SetScanEnabled(isEnabled)
	self.EventFrame:SetShown(isEnabled)
	self:ForceUpdate()
end

function ezSpectator_Nameplates:ForceUpdate()
	for nameplate in pairs(self.nameplates) do
		self:UpdateNameplate(nameplate)
	end
end

function ezSpectator_Nameplates:FindNewNamePlates(...)
	for i = self.lastChildern + 1, self.numChildren do
		local frame = select(i, ...)
		if not self.nameplates[frame]
		and not frame.UnitFrame -- nameplate addons
		then
			local _, border = frame:GetRegions()
			if border and border:GetObjectType() == "Texture" and border:GetTexture() == [[Interface\Tooltips\Nameplate-Border]] then
				self:UpdateNameplate(frame)
				self.nameplates[frame] = true
			end
		end
	end
end

function ezSpectator_Nameplates:HideOriginalObject(object, altRoute)
	local objectType = object:GetObjectType()
	if objectType == "Texture" then
		if altRoute == 1 then
			if not object.__original then
				object.__originalAlpha = object:GetAlpha()
				object.__original = true
			end
			object:SetAlpha(0)
		elseif altRoute == 2 then
			if not object.__original then
				object.__originalWidth = object:GetWidth()
				object.__original = true
			end
			object:SetWidth(0.001)
		else
			if not object.__original then
				object.__originalTexture = object:GetTexture()
				object.__originalCoords = {object:GetTexCoord()}
				object.__original = true
			end
			object:SetTexture("")
			object:SetTexCoord(0, 0, 0, 0)
		end
	elseif objectType == "FontString" then
		if not object.__original then
			object.__original = true
		end
		object:SetWidth(0.001)
	elseif objectType == "StatusBar" then
		if not object.__original then
			object.__originalTexture = object:GetStatusBarTexture():GetTexture()
			object.__original = true
		end
		object:SetStatusBarTexture("")
	end
end

function ezSpectator_Nameplates:RestoreOriginalObject(object, altRoute)
	if not object.__original then
		return
	end

	local objectType = object:GetObjectType()
	if objectType == "Texture" then
		if altRoute == 1 then
			object:SetAlpha(object.__originalAlpha or 1)
		elseif altRoute == 2 then
			object:SetWidth(object.__originalWidth or 1)
		else
			object:SetTexture(object.__originalTexture)
			object:SetTexCoord(unpack(object.__originalCoords))
		end
	elseif objectType == "FontString" then
		object:SetWidth(0)
	elseif objectType == "StatusBar" then
		object:SetStatusBarTexture(object.__originalTexture)
	end
end

function ezSpectator_Nameplates:HideOriginalNameplate(nameplate, healthBar, castBar, threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon)
	if nameplate.arenaSpectatorEnabled then
		return
	end

	self:HideOriginalObject(healthBar)
	self:HideOriginalObject(castBar)
	self:HideOriginalObject(threatGlow)
	self:HideOriginalObject(healthBorder)
	self:HideOriginalObject(castBorder)
	self:HideOriginalObject(castUninterruptible)
	self:HideOriginalObject(highlightTexture)

	self:HideOriginalObject(nameText)
	self:HideOriginalObject(levelText)

	self:HideOriginalObject(eliteIcon, 1)
	self:HideOriginalObject(bossIcon, 1)
	self:HideOriginalObject(raidIcon, 1)
	self:HideOriginalObject(spellIcon, 2)

	nameplate.arenaSpectatorEnabled = true
end

function ezSpectator_Nameplates:ShowOriginalNameplate(nameplate, healthBar, castBar, threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon)
	if not nameplate.arenaSpectatorEnabled then
		return
	end

	self:RestoreOriginalObject(healthBar)
	self:RestoreOriginalObject(castBar)
	self:RestoreOriginalObject(threatGlow)
	self:RestoreOriginalObject(healthBorder)
	self:RestoreOriginalObject(castBorder)
	self:RestoreOriginalObject(castUninterruptible)
	self:RestoreOriginalObject(highlightTexture)

	self:RestoreOriginalObject(nameText)
	self:RestoreOriginalObject(levelText)

	self:RestoreOriginalObject(eliteIcon, 1)
	self:RestoreOriginalObject(bossIcon, 1)
	self:RestoreOriginalObject(raidIcon, 1)
	self:RestoreOriginalObject(spellIcon, 2)

	nameplate.spectatorNP:Hide()
	nameplate.arenaSpectatorEnabled = nil
end

function ezSpectator_Nameplates:ProcessNameplate(skipAnimation, nameplate, healthBar, castBar, ...)
	local isActive = C_ArenaSpectator.IsActive() and (C_ArenaSpectator.IsInProgress() or C_ArenaSpectator.IsInPreparation())
	if not isActive then
		if nameplate.arenaSpectatorEnabled then
			self:ShowOriginalNameplate(nameplate, healthBar, castBar, ...)
		end
	else
		if not nameplate.arenaSpectatorEnabled then
			self:HideOriginalNameplate(nameplate, healthBar, castBar, ...)
		end

		local threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon = ...

		if not nameplate.spectatorNP then
			nameplate.spectatorNP = ezSpectator_Nameplate:Create(self.Parent, healthBar, "BOTTOM", healthBorder, "BOTTOM", 0, 10)
		else
			nameplate.spectatorNP:Show()
		end

		local value = healthBar:GetValue()
		local minValue, maxValue = healthBar:GetMinMaxValues()
		nameplate.spectatorNP:SetMaxValue(maxValue)

		if not skipAnimation then
			skipAnimation = nameplate.spectatorNP.IsUpdating
			nameplate.spectatorNP.IsUpdating = false
		else
			nameplate.spectatorNP.IsUpdating = true
		end

		if skipAnimation then
			nameplate.spectatorNP:ResetAnimation()
		end
		nameplate.spectatorNP:SetValue(value, skipAnimation)

		local unitName = nameText:GetText()
		local playerObject = self.Parent.Interface.Players[unitName]

		nameplate.spectatorNP:SetNickname(unitName)

		if playerObject then
			nameplate.spectatorNP:SetTeam(playerObject.Team)
			nameplate.spectatorNP:SetClass(playerObject.Class)

			playerObject:SetNameplate(nameplate.spectatorNP)
			nameplate.spectatorNP:SetPlayer(playerObject)
		else
			nameplate.spectatorNP:SetTeam(nil)
			nameplate.spectatorNP:SetClass(nil)
			nameplate.spectatorNP:SetPlayer(nil)
		end

		if self.Parent.Interface.Viewpoint then
			if self.Parent.Interface.Viewpoint.TargetObject
			and self.Parent.Interface.Viewpoint.TargetObject.Nickname == unitName
			then
				nameplate.spectatorNP:SetAlpha(1)
				nameplate.spectatorNP.IsTarget = true
			else
				nameplate.spectatorNP:SetAlpha(self.Parent.VIEWPOINT_NAMEPLATE_ALPHA)
				nameplate.spectatorNP.IsTarget = false
			end
		else
			nameplate.spectatorNP:SetAlpha(1)
			nameplate.spectatorNP.IsTarget = false
		end
	end
end

function ezSpectator_Nameplates:UpdateNameplate(nameplate)
	local healthBar, castBar = nameplate:GetChildren()
	local threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon = nameplate:GetRegions()

	if not nameplate.spectatorHooks then
		healthBar:HookScript("OnShow", function(this)
			if nameplate.arenaSpectatorEnabled then
				self:ProcessNameplate(true, nameplate, healthBar, castBar, threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon)
			end
		end)
		healthBar:SetScript("OnUpdate", function(this, elapsed)
			if nameplate.arenaSpectatorEnabled then
				self:ProcessNameplate(false, nameplate, healthBar, castBar, threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon)
			end
		end)
		nameplate.spectatorHooks = true
	end

	self:ProcessNameplate(false, nameplate, healthBar, castBar, threatGlow, healthBorder, castBorder, castUninterruptible, spellIcon, highlightTexture, nameText, levelText, bossIcon, raidIcon, eliteIcon)
end