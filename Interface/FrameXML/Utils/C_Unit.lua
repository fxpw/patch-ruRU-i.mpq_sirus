local FACTION_OVERRIDE_BY_DEBUFFS = FACTION_OVERRIDE_BY_DEBUFFS
local ZODIAC_DEBUFFS = ZODIAC_DEBUFFS
local S_CATEGORY_SPELL_ID = S_CATEGORY_SPELL_ID
local S_VIP_STATUS_DATA = S_VIP_STATUS_DATA

local UnitClassification = UnitClassification
local UnitAura = UnitAura
local UnitIsPlayer = UnitIsPlayer
local UnitFactionGroup = UnitFactionGroup

C_Unit = {}

local unitHasAura = function(unit, spellList, filter)
	local list = type(spellList) == "table"
	local index = 1
	local name, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, index, filter or "HARMFUL")
	while name do
		if not name then
			break
		elseif list and spellList[spellID] or spellList == spellID then
			return index, name, spellID
		end

		index = index + 1
		name, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, index, filter or "HARMFUL")
	end
end

function C_Unit.GetCategoryInfo(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.GetCategoryInfo(\"unit\")", 2)
	end

	if UnitIsPlayer(unit) then
		local _, name, spellID = unitHasAura(unit, S_CATEGORY_SPELL_ID)
		local categoryName, categorySpellID

		if spellID then
			categoryName = name:gsub("%((.*)%)%s*", "")
			categorySpellID = spellID
		else
			categoryName = PLAYER_NO_CATEGORY
		end

		return categoryName, categorySpellID
	end
end

function C_Unit.GetClassification(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.GetClassification(\"unit\")", 2)
	end

	local classificationInfo 	= {}

	if UnitIsPlayer(unit) then
		local _, name, spellID = unitHasAura(unit, S_VIP_STATUS_DATA)
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

function C_Unit.GetFactionByDebuff(unit)
	if type(unit) ~= "string" then
		error([[Usage: C_Unit.GetFactionByDebuff("unit")]], 2)
	end

	local _, _, spellID = unitHasAura(unit, FACTION_OVERRIDE_BY_DEBUFFS, "HARMFUL|NOT_CANCELABLE")
	if spellID then
		return FACTION_OVERRIDE_BY_DEBUFFS[spellID]
	end
end

function C_Unit.GetZodiacByDebuff(unit)
	if type(unit) ~= "string" then
		error([[Usage: C_Unit.GetZodiacByDebuff("unit")]], 2)
	end

	local _, _, spellID = unitHasAura(unit, ZODIAC_DEBUFFS, "HARMFUL|NOT_CANCELABLE")
	if spellID then
		local raceID = ZODIAC_DEBUFFS[spellID]
		return C_ZodiacSign.GetZodiacSignInfo(raceID)
	end
end

function C_Unit.GetAuraIndexForSpellID(unit, spellID, filter)
	if type(unit) ~= "string" then
		error([[Usage: C_Unit.GetAuraIndexForSpellID("unit", spellID[, filter])]], 2)
	elseif type(spellID) ~= "number" then
		error([[Usage: C_Unit.GetAuraIndexForSpellID("unit", spellID[, filter])]], 2)
	elseif filter ~= nil and type(filter) ~= "string" then
		error([[Usage: C_Unit.GetAuraIndexForSpellID("unit", spellID[, filter])]], 2)
	end

	local index = unitHasAura(unit, spellID, filter or "HELPFUL")
	return index
end

function C_Unit.GetFactionInfo(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.GetFactionInfo(\"unit\")", 2)
	end

	local faction, factionName = UnitFactionGroup(unit)
	if faction then
		return PLAYER_FACTION_GROUP[faction], SERVER_PLAYER_FACTION_GROUP[faction], faction, factionName
	end
end

function C_Unit.GetFactionID(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.GetFactionID(\"unit\")", 2)
	end

	local faction = UnitFactionGroup(unit)
	if faction then
		return PLAYER_FACTION_GROUP[faction]
	end
end

function C_Unit.GetServerFactionID(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.GetServerFactionID(\"unit\")", 2)
	end

	local faction = UnitFactionGroup(unit)
	if faction then
		return SERVER_PLAYER_FACTION_GROUP[faction]
	end
end

function C_Unit.IsRenegade(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.IsRenegade(\"unit\")", 2)
	end

	local faction = UnitFactionGroup(unit)
	if faction then
		return PLAYER_FACTION_GROUP[faction] == PLAYER_FACTION_GROUP.Renegade
	end
end

function C_Unit.IsNeutral(unit)
	if type(unit) ~= "string" then
		error("Usage: C_Unit.IsNeutral(\"unit\")", 2)
	end

	local faction = UnitFactionGroup(unit)
	if faction then
		return PLAYER_FACTION_GROUP[faction] == PLAYER_FACTION_GROUP.Neutral
	end
end