--	Filename:	Sirus_SpellOverlay.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local sizeScale = 0.8
local longSide = 256 * sizeScale
local shortSide = 128 * sizeScale

local actionButtonState = {}
local complexLocationTable = {
	["RIGHT (FLIPPED)"] = {
		RIGHT = {	hFlip = true },
	},
	["BOTTOM (FLIPPED)"] = {
		BOTTOM = { vFlip = true },
	},
	["LEFT + RIGHT (FLIPPED)"] = {
		LEFT = {},
		RIGHT = { hFlip = true },
	},
	["TOP + BOTTOM (FLIPPED)"] = {
		TOP = {},
		BOTTOM = { vFlip = true },
	},
}

local auraTrackerStorage = {}

function AuraTrackerFrame_OnLoad( self, ... )
	self:RegisterEvent("UNIT_AURA")
	AuraTrackerFrame_UpdateAura()
end

function AuraTrackerFrame_OnEvent( self, event, unit )
	if ( event == "UNIT_AURA" ) then
		if unit == "player" then
			AuraTrackerFrame_UpdateAura()
		end
	end
end

local auraFilterStorage = {"HELPFUL", "HARMFUL"}
function AuraTrackerFrame_UpdateAura()
	for i = 1, 2 do
		local auraFilter = auraFilterStorage[i]

		for auraIndex = 1, 40 do
			local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3 = UnitAura("player", auraIndex, auraFilter)

			if name and spellID then
				local hasAura = auraTrackerStorage[spellID] and auraTrackerStorage[spellID][1]

				if hasAura == nil then
					Hook:FireEvent("UNIT_AURA", auraFilter, "ADD_AURA", name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3)
				else
					local data = auraTrackerStorage[spellID]

					if data[3] ~= count then
						Hook:FireEvent("UNIT_AURA", auraFilter, "UPDATE_COUNT", name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3)
					elseif data[4] ~= expirationTime then
						Hook:FireEvent("UNIT_AURA", auraFilter, "UPDATE_EXPIRATION_TIME", name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3)
					end
				end

				auraTrackerStorage[spellID] = {false, auraFilter, count, expirationTime}
			end
		end
	end

	for spellID, auraData in pairs(auraTrackerStorage) do
		if not auraData[1] then
			auraTrackerStorage[spellID][1] = true
		else
			Hook:FireEvent("UNIT_AURA", auraTrackerStorage[spellID][2], "REMOVE_AURA", name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellID, canApplyAura, isBossDebuff, isCastByPlayer, value2, value3)
			auraTrackerStorage[spellID] = nil
		end
	end
end

function SpellOverlay_RegisterAuraTracker()
	Hook:RegisterCallback("SPELL_OVERLAY", "UNIT_AURA", function(auraType, actionType, _, _, _, count, _, _, _, _, _, _, spellID)
		if actionType == "ADD_AURA" or actionType == "UPDATE_COUNT" then
			for _, data in pairs(SPELLOVERLAY_STORAGE) do
				local showThisOverlay = {}

				local auraTriggerData = data[2]
				local spellOverlayData = data[3]

				for _, spell in pairs(auraTriggerData) do
					if type(spell) == "table" then
						if spell[3] then
							if spell[1] == spellID then
								showThisOverlay = {true, false, spell[2] > count, spell[3]}
								break
							end
						else
							if spell[1] == spellID and spell[2] == count then
								showThisOverlay = {true, true}
								break
							end
						end
					else
						if spell == spellID then
							showThisOverlay = {true, false}
							break
						end
					end
				end

				if showThisOverlay[1] then
					local overlayData = data[1]

					if overlayData then
						local texturePath = "Interface\\SpellActivationOverlay\\"..overlayData[1]
						local positions = overlayData[2]
						local scale = overlayData[3] or 1
						local color = overlayData[4] or CreateColor(1, 1, 1)
						local r, g, b = color:GetRGB()
						local vFlip = overlayData[5]
						local hFlip = overlayData[6]

						if showThisOverlay[2] then
							texturePath = texturePath.."_"..count
						end

						SpellActivationOverlay_ShowAllOverlays(SpellActivationOverlayFrame, spellID, texturePath, positions, scale, r, g, b, vFlip, hFlip)

						if showThisOverlay[3] and showThisOverlay[4] then
							SpellActivationOverlay_HideOverlaysByPosition(SpellActivationOverlayFrame, spellID, showThisOverlay[4]);
						end
					end

					for _, spell in pairs(spellOverlayData or {}) do
						if not SPELLOVERLAY_HIGHLIGHT[spell] or type(SPELLOVERLAY_HIGHLIGHT[spell]) ~= "table" then
							SPELLOVERLAY_HIGHLIGHT[spell] = {}
						end

						SPELLOVERLAY_HIGHLIGHT[spell][spellID] = true
					end

					SpellActivationOverlayFrame.spellOverlayData[spellID] = spellOverlayData
					ActionButton_UpdateAllAction()
				end
			end
		elseif actionType == "REMOVE_AURA" then
			if SpellActivationOverlayFrame.spellOverlayData[spellID] then
				for _, spell in pairs(SpellActivationOverlayFrame.spellOverlayData[spellID]) do
					SPELLOVERLAY_HIGHLIGHT[spell][spellID] = nil

					if tCount(SPELLOVERLAY_HIGHLIGHT[spell]) == 0 then
						SPELLOVERLAY_HIGHLIGHT[spell] = nil
					end
				end
				SpellActivationOverlayFrame.spellOverlayData[spellID] = nil
			end

			SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, spellID)
			ActionButton_UpdateAllAction()
		end
	end)
end

function SpellOverlay_RegisterSpellUsableTracker()
	Hook:RegisterCallback("SPELL_OVERLAY", "UPDATE_USABLE_ACTION", function(status, actionSlot)
		local spellID = GetActionSpellID(actionSlot.action)

		if spellID then
			if status == "ENABLED" or status == "ENABLED_NOT_ENOUGH_RESOURCE" then
				if SPELLOVERLAY_ACTIVE_HIGHLIGHT[spellID] then
					if not SPELLOVERLAY_HIGHLIGHT[spellID] then
						SPELLOVERLAY_HIGHLIGHT[spellID] = {}
					end

					SPELLOVERLAY_HIGHLIGHT[spellID][0] = true
				end
			elseif status == "DISABLED" then
				if SPELLOVERLAY_HIGHLIGHT[spellID] then
					SPELLOVERLAY_HIGHLIGHT[spellID][0] = nil

					if tCount(SPELLOVERLAY_HIGHLIGHT[spellID]) == 0 then
						SPELLOVERLAY_HIGHLIGHT[spellID] = nil
					end
				else
					SPELLOVERLAY_HIGHLIGHT[spellID] = nil
				end
			end
		end

		ActionButton_UpdateOverlayGlow(actionSlot)
	end)
end

function SpellActivationOverlay_OnLoad(self)
	self.overlaysInUse = {}

	self.unusedOverlays = {}
	self.spellOverlayData = {}
	self.waitOverlayData = {}

	self:SetSize(longSide, longSide)

	SpellOverlay_RegisterSpellUsableTracker()
	SpellOverlay_RegisterAuraTracker()
end

function SpellActivationOverlay_ShowAllOverlays(self, spellID, texturePath, positions, scale, r, g, b, vFlip, hFlip)
	if SpellOverlay_OverlayArtAlphaSlider.value and SpellOverlay_OverlayArtAlphaSlider.value ~= 0 then
		positions = strupper(positions)
		if ( complexLocationTable[positions] ) then
			for location, info in pairs(complexLocationTable[positions]) do
				SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, location, scale, r, g, b, info.vFlip, info.hFlip)
			end
		else
			SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, positions, scale, r, g, b, vFlip, hFlip)
		end
	else
		self.waitOverlayData[spellID] = {self, spellID, texturePath, positions, scale, r, g, b, vFlip, hFlip}
	end
end

function SpellActivationOverlay_RestoreAllOverlays(self)
	if tCount(self.waitOverlayData) > 0 then
		for _, overlayData in pairs(self.waitOverlayData) do
			SpellActivationOverlay_ShowAllOverlays(unpack(overlayData))
		end
	end
end

function SpellActivationOverlay_ShowOverlay(self, spellID, texturePath, position, scale, r, g, b, vFlip, hFlip)
	if not scale then
		scale = 1
	end

	local overlay = SpellActivationOverlay_GetOverlay(self, spellID, position)

	overlay:SetAlpha(SpellOverlay_OverlayArtAlphaSlider.value)

	overlay.spellID = spellID
	overlay.position = position

	overlay:ClearAllPoints()

	local texLeft, texRight, texTop, texBottom = 0, 1, 0, 1
	if ( vFlip ) then
		texTop, texBottom = 1, 0
	end
	if ( hFlip ) then
		texLeft, texRight = 1, 0
	end
	overlay.texture:SetTexCoord(texLeft, texRight, texTop, texBottom)

	local width, height
	if ( position == "CENTER" ) then
		width, height = longSide, longSide
		overlay:SetPoint("CENTER", self, "CENTER", 0, 0)
	elseif ( position == "LEFT" ) then
		width, height = shortSide, longSide
		overlay:SetPoint("RIGHT", self, "LEFT", 0, 0)
	elseif ( position == "RIGHT" ) then
		width, height = shortSide, longSide
		overlay:SetPoint("LEFT", self, "RIGHT", 0, 0)
	elseif ( position == "TOP" ) then
		width, height = longSide, shortSide
		overlay:SetPoint("BOTTOM", self, "TOP", 0, 0)
	elseif ( position == "BOTTOM" ) then
		width, height = longSide, shortSide
		overlay:SetPoint("TOP", self, "BOTTOM")
	elseif ( position == "TOPRIGHT" ) then
		width, height = shortSide, shortSide
		overlay:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0)
	elseif ( position == "TOPLEFT" ) then
		width, height = shortSide, shortSide
		overlay:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 0)
	elseif ( position == "BOTTOMRIGHT" ) then
		width, height = shortSide, shortSide
		overlay:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0)
	elseif ( position == "BOTTOMLEFT" ) then
		width, height = shortSide, shortSide
		overlay:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", 0, 0)
	else
		-- GMError("Unknown SpellActivationOverlay position: "..tostring(position))
	end

	overlay:SetSize(width * scale, height * scale)

	overlay.texture:SetTexture(texturePath)
	overlay.texture:SetVertexColor(r, g, b)

	overlay.animOut:Stop()	--In case we're in the process of animating this out.
	PlaySound(SOUNDKIT.UI_POWER_AURA_GENERIC)
	overlay:Show()
end

function SpellActivationOverlay_GetOverlay(self, spellID, position)
	local overlayList = self.overlaysInUse[spellID]
	local overlay
	if ( overlayList ) then
		for i=1, #overlayList do
			if ( overlayList[i].position == position ) then
				overlay = overlayList[i]
			end
		end
	end

	if ( not overlay ) then
		overlay = SpellActivationOverlay_GetUnusedOverlay(self)
		if ( overlayList ) then
			tinsert(overlayList, overlay)
		else
			self.overlaysInUse[spellID] = { overlay }
		end
	end

	return overlay
end

function SpellActivationOverlay_HideOverlaysByPosition(self, spellID, position)
	local overlayList = self.overlaysInUse[spellID];
	if overlayList then
		for i = 1, #overlayList do
			local overlay = overlayList[i];

			if overlay.position == position then
				overlay.pulse:Pause();
				overlay.animOut:Play();
			end
		end
	end
end

function SpellActivationOverlay_HideOverlays(self, spellID)
	local overlayList = self.overlaysInUse[spellID]
	if ( overlayList ) then
		for i=1, #overlayList do
			local overlay = overlayList[i]
			overlay.pulse:Pause()
			overlay.animOut:Play()
		end
	end

	self.waitOverlayData[spellID] = nil
end

function SpellActivationOverlay_HideAllOverlays(self)
	for spellID, overlayList in pairs(self.overlaysInUse) do
		SpellActivationOverlay_HideOverlays(self, spellID)
	end
end

function SpellActivationOverlay_UpdateAlphaAllOverlays(self)
	for spellID, overlayList in pairs(self.overlaysInUse) do
		for i=1, #overlayList do
			local overlay = overlayList[i]
			overlay:SetAlpha(self:GetAlpha())
		end
	end
end

function SpellActivationOverlay_GetUnusedOverlay(self)
	local overlay = tremove(self.unusedOverlays, #self.unusedOverlays)
	if ( not overlay ) then
		overlay = SpellActivationOverlay_CreateOverlay(self)
	end
	return overlay
end

function SpellActivationOverlay_CreateOverlay(self)
	return CreateFrame("Frame", nil, self, "SpellActivationOverlayTemplate")
end

function SpellActivationOverlayTexture_OnShow(self)
	self.animIn:Play()
end

function SpellActivationOverlayTexture_OnFadeInPlay(animGroup)
	animGroup:GetParent():SetAlpha(0)
end

function SpellActivationOverlayTexture_OnFadeInFinished(animGroup)
	local overlay = animGroup:GetParent()
	overlay:SetAlpha(1)
	overlay.pulse:Play()
end

function SpellActivationOverlayTexture_OnFadeOutFinished(anim)
	local overlay = anim:GetRegionParent()
	local overlayParent = overlay:GetParent()
	overlay.pulse:Stop()
	overlay:Hide()
	tDeleteItem(overlayParent.overlaysInUse[overlay.spellID], overlay)
	tinsert(overlayParent.unusedOverlays, overlay)
end