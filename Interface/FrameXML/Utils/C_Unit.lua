--	Filename:	C_Unit.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local FACTION_OVERRIDE_BY_DEBUFFS = FACTION_OVERRIDE_BY_DEBUFFS
local S_CATEGORY_SPELL_ID = S_CATEGORY_SPELL_ID
local S_VIP_STATUS_DATA = S_VIP_STATUS_DATA

local UnitFactionGroup = UnitFactionGroup

---@class C_UnitMixin : Mixin
C_UnitMixin = {}

local UnitHasAuraFromList = function(unit, spellList)
	local index = 1
	local name, _, _, _, _, _, _, _, _, _, spellID = UnitDebuff(unit, index)
	while name do
		if not name then
			break
		elseif spellList[spellID] then
			return name, spellID
		end

		index = index + 1
		name, _, _, _, _, _, _, _, _, _, spellID = UnitDebuff(unit, index)
	end

	return false
end

function C_UnitMixin:GetCategoryInfo( unit )
	assert(unit, "C_UnitMixin:GetCategoryInfo: не указан unit.")

	if UnitExists(unit) and UnitIsPlayer(unit) then
		local categoryInfo = {}

		local name, spellID = UnitHasAuraFromList(unit, S_CATEGORY_SPELL_ID)
		if spellID then
			categoryInfo.categoryName = name:gsub("%((.*)%)%s*", "")
			categoryInfo.categorySpellID = spellID

			return categoryInfo
		end

		categoryInfo.categoryName = PLAYER_NO_CATEGORY

		return categoryInfo
	end
end

function C_UnitMixin:GetClassification( unit )
	assert(unit, "C_UnitMixin:GetClassification: не указан unit.")

	local classificationInfo 	= {}

	if UnitExists(unit) and UnitIsPlayer(unit) then
		local name, spellID = UnitHasAuraFromList(unit, S_VIP_STATUS_DATA)
		if spellID then
			local data = S_VIP_STATUS_DATA[spellID]

			if data then
				classificationInfo.vipSpellID 		= spellID
				classificationInfo.vipName 			= name
				classificationInfo.color 			= data.color
				classificationInfo.vipCategory 		= data.category

				if classificationInfo.vipCategory == 1 then
					classificationInfo.unitFrameTexture = "UI-TargetingFrame-Rare"
				elseif classificationInfo.vipCategory == 2 then
					classificationInfo.unitFrameTexture = "UI-TARGETINGFRAME-RARE-ELITE"
				elseif classificationInfo.vipCategory == 3 then
					if classificationInfo.vipSpellID == 308227 then
						classificationInfo.unitFrameTexture = "UI-TARGETINGFRAME-EMERALD"
					elseif classificationInfo.vipSpellID == 313090 then
						classificationInfo.unitFrameTexture = "UI-TARGETINGFRAME-SAPPHIRE"
					elseif classificationInfo.vipSpellID == 313093 then
						classificationInfo.unitFrameTexture = "UI-TARGETINGFRAME-RUBY"
					end
				end

				classificationInfo.classification 	= classificationInfo.vipCategory == 1 and "rare" or "rareelite"

				return classificationInfo
			end
		end
	end

	local classification = UnitClassification(unit)

	classificationInfo.color 			= HIGHLIGHT_FONT_COLOR
	classificationInfo.classification 	= classification

	local texture
	if classification == "worldboss" or classification == "elite" then
		texture = "UI-TargetingFrame-Elite"
	elseif classification == "rareelite" then
		texture = "UI-TargetingFrame-Rare-Elite"
	elseif classification == "rare" then
		texture = "UI-TargetingFrame-Rare"
	else
		texture = "UI-TargetingFrame"
	end

	classificationInfo.unitFrameTexture = texture

	return classificationInfo
end

function C_UnitMixin:GetFactionByDebuff( unit )
	assert(unit, "C_UnitMixin:GetFactionByDebuff: не указан unit.")

	local _, spellID = UnitHasAuraFromList(unit, FACTION_OVERRIDE_BY_DEBUFFS)
	if spellID then
		return FACTION_OVERRIDE_BY_DEBUFFS[spellID]
	end
end

function C_UnitMixin:GetFactionID( unit )
	assert(unit, "C_UnitMixin:GetFactionID: не указан unit.")

	local unitFaction = UnitFactionGroup(unit)

	if unitFaction then
		return PLAYER_FACTION_GROUP[unitFaction]
	end
end

function C_UnitMixin:GetServerFactionID( unit )
	assert(unit, "C_UnitMixin:GetFactionID: не указан unit.")

	local unitFaction = UnitFactionGroup(unit)

	if unitFaction then
		return SERVER_PLAYER_FACTION_GROUP[unitFaction]
	end
end

function C_UnitMixin:IsRenegade( unit )
	assert(unit, "C_UnitMixin:IsRenegade: не указан unit.")

	return self:GetFactionID(unit) == PLAYER_FACTION_GROUP.Renegade
end

---@class C_Unit : C_UnitMixin
C_Unit = CreateFromMixins(C_UnitMixin)

function C_Unit.IsNeutral(unit)
	local faction = UnitFactionGroup(unit)
	return PLAYER_FACTION_GROUP[faction] == PLAYER_FACTION_GROUP.Neutral
end