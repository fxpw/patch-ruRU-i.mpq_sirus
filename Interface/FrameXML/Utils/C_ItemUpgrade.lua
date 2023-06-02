Enum.ItemUpgradeType = {
	None = 0,
	Upgrade = 1,
	Other = 2,
	Both = 3,
};

local tInvert = tInvert;

local ITEM_STATS = {
	"ITEM_MOD_DAMAGE_PER_SECOND_SHORT",
	"RESISTANCE0_NAME",
	"RESISTANCE1_NAME",
	"RESISTANCE2_NAME",
	"RESISTANCE3_NAME",
	"RESISTANCE4_NAME",
	"RESISTANCE5_NAME",
	"RESISTANCE6_NAME",
	"ITEM_MOD_MANA_SHORT",
	"ITEM_MOD_HEALTH_SHORT",
	"ITEM_MOD_AGILITY_SHORT",
	"ITEM_MOD_STRENGTH_SHORT",
	"ITEM_MOD_INTELLECT_SHORT",
	"ITEM_MOD_STAMINA_SHORT",
	"ITEM_MOD_SPIRIT_SHORT",
	"ITEM_MOD_ATTACK_POWER_SHORT",
	"ITEM_MOD_DEFENSE_SKILL_RATING_SHORT",
	"ITEM_MOD_DODGE_RATING_SHORT",
	"ITEM_MOD_PARRY_RATING_SHORT",
	"ITEM_MOD_BLOCK_RATING_SHORT",
	"ITEM_MOD_POWER_REGEN0_SHORT",
	"ITEM_MOD_POWER_REGEN1_SHORT",
	"ITEM_MOD_POWER_REGEN2_SHORT",
	"ITEM_MOD_POWER_REGEN3_SHORT",
	"ITEM_MOD_POWER_REGEN4_SHORT",
	"ITEM_MOD_POWER_REGEN5_SHORT",
	"ITEM_MOD_POWER_REGEN6_SHORT",
	"ITEM_MOD_HIT_MELEE_RATING_SHORT",
	"ITEM_MOD_HIT_RANGED_RATING_SHORT",
	"ITEM_MOD_HIT_SPELL_RATING_SHORT",
	"ITEM_MOD_CRIT_MELEE_RATING_SHORT",
	"ITEM_MOD_CRIT_RANGED_RATING_SHORT",
	"ITEM_MOD_CRIT_SPELL_RATING_SHORT",
	"ITEM_MOD_HIT_TAKEN_MELEE_RATING_SHORT",
	"ITEM_MOD_HIT_TAKEN_RANGED_RATING_SHORT",
	"ITEM_MOD_HIT_TAKEN_SPELL_RATING_SHORT",
	"ITEM_MOD_CRIT_TAKEN_MELEE_RATING_SHORT",
	"ITEM_MOD_CRIT_TAKEN_RANGED_RATING_SHORT",
	"ITEM_MOD_CRIT_TAKEN_SPELL_RATING_SHORT",
	"ITEM_MOD_HASTE_MELEE_RATING_SHORT",
	"ITEM_MOD_HASTE_RANGED_RATING_SHORT",
	"ITEM_MOD_HASTE_SPELL_RATING_SHORT",
	"ITEM_MOD_HIT_RATING_SHORT",
	"ITEM_MOD_CRIT_RATING_SHORT",
	"ITEM_MOD_HIT_TAKEN_RATING_SHORT",
	"ITEM_MOD_CRIT_TAKEN_RATING_SHORT",
	"ITEM_MOD_RESILIENCE_RATING_SHORT",
	"ITEM_MOD_SPELL_HEALING_DONE_SHORT", -- Onslaught
	"ITEM_MOD_HASTE_RATING_SHORT",
	"ITEM_MOD_EXPERTISE_RATING_SHORT",
	"ITEM_MOD_RANGED_ATTACK_POWER_SHORT",
	"ITEM_MOD_SPELL_DAMAGE_DONE_SHORT",
	"ITEM_MOD_MANA_REGENERATION_SHORT",
	"ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT",
	"ITEM_MOD_SPELL_POWER_SHORT",
	"ITEM_MOD_HEALTH_REGEN_SHORT",
	"ITEM_MOD_SPELL_PENETRATION_SHORT",
	"ITEM_MOD_BLOCK_VALUE_SHORT",
	"ITEM_MOD_FERAL_ATTACK_POWER_SHORT",
	"ITEM_MOD_MELEE_ATTACK_POWER_SHORT",
	"ITEM_MOD_HEALTH_REGENERATION_SHORT",
	"EMPTY_SOCKET_BLUE",
	"EMPTY_SOCKET_YELLOW",
	"EMPTY_SOCKET_RED",
	"EMPTY_SOCKET_META",
	"EMPTY_SOCKET_NO_COLOR",
};

local ITEM_STAT_TEXTS = {
	ITEM_MOD_DEFENSE_SKILL_RATING = true,
	ITEM_MOD_DODGE_RATING = true,
	ITEM_MOD_PARRY_RATING = true,
	ITEM_MOD_BLOCK_RATING = true,
	ITEM_MOD_HIT_MELEE_RATING = true,
	ITEM_MOD_HIT_RANGED_RATING = true,
	ITEM_MOD_HIT_SPELL_RATING = true,
	ITEM_MOD_CRIT_MELEE_RATING = true,
	ITEM_MOD_CRIT_RANGED_RATING = true,
	ITEM_MOD_CRIT_SPELL_RATING = true,
	ITEM_MOD_HIT_TAKEN_MELEE_RATING = true,
	ITEM_MOD_HIT_TAKEN_RANGED_RATING = true,
	ITEM_MOD_HIT_TAKEN_SPELL_RATING = true,
	ITEM_MOD_CRIT_TAKEN_MELEE_RATING = true,
	ITEM_MOD_CRIT_TAKEN_RANGED_RATING = true,
	ITEM_MOD_CRIT_TAKEN_SPELL_RATING = true,
	ITEM_MOD_HASTE_MELEE_RATING = true,
	ITEM_MOD_HASTE_RANGED_RATING = true,
	ITEM_MOD_HASTE_SPELL_RATING = true,
	ITEM_MOD_HIT_RATING = true,
	ITEM_MOD_CRIT_RATING = true,
	ITEM_MOD_HIT_TAKEN_RATING = true,
	ITEM_MOD_CRIT_TAKEN_RATING = true,
	ITEM_MOD_RESILIENCE_RATING = true,
	ITEM_MOD_HASTE_RATING = true,
	ITEM_MOD_EXPERTISE_RATING = true,
	ITEM_MOD_ATTACK_POWER = true,
	ITEM_MOD_RANGED_ATTACK_POWER = true,
	ITEM_MOD_SPELL_HEALING_DONE = true, -- Onslaught
	ITEM_MOD_SPELL_DAMAGE_DONE = true,
	ITEM_MOD_MANA_REGENERATION = true,
	ITEM_MOD_ARMOR_PENETRATION_RATING = true,
	ITEM_MOD_SPELL_POWER = true,
	ITEM_MOD_HEALTH_REGEN = true,
	ITEM_MOD_SPELL_PENETRATION = true,
	ITEM_MOD_BLOCK_VALUE = true,
};

local STATS_SORT_ORDER = tInvert(ITEM_STATS);

local ItemUpgrade = {
	ToEntry = 1,
	UpgradeGroupID = 2,
	ItemRequirementID = 3,
	ItemCostID = 4,
	IsSaveEnchants = 5,
	RealmFlag = 6,
};

local ItemUpgradeCost = {
	Gold = 1,
	Honor = 2,
	Arena = 3,
	Bracket = 4,
	Rating = 5,
	Item1 = 6,
	Item2 = 7,
	Item3 = 8,
	Item4 = 9,
	Item5 = 10,
	ItemCount1 = 11,
	ItemCount2 = 12,
	ItemCount3 = 13,
	ItemCount4 = 14,
	ItemCount5 = 15,
};

local ItemUpgradeRequirements = {
	RaceMask = 1,
	ClassMask = 2,
	SpecID = 3,
	IconID = 4,
	SpellID = 5,
};

local UPGRADE_INFO = {};

local scanTooltip = CreateFrame("GameTooltip", "ItemUpgradeScanTooltip");
scanTooltip:AddFontStrings(
	scanTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
	scanTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);

local function ItemCacheCallback(itemID)
	FireCustomClientEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
end

local function SortStats(a, b)
	return (STATS_SORT_ORDER[a.statName] or 99) < (STATS_SORT_ORDER[b.statName] or 99);
end

local itemSocketTexture = {
	EMPTY_SOCKET_BLUE = "UI-EmptySocket-Blue",
	EMPTY_SOCKET_YELLOW = "UI-EmptySocket-Yellow",
	EMPTY_SOCKET_RED = "UI-EmptySocket-Red",
	EMPTY_SOCKET_META = "UI-EmptySocket-Meta",
	EMPTY_SOCKET_NO_COLOR = "UI-EmptySocket",
};

local statIdicatorEnum = {
	None = 0,
	Positive = 1,
	Negative = 2,
}

local function GetStatString(name, value1, value2, statIdicator)
	if itemSocketTexture[name] then
		name = string.format("|TInterface\\ItemSocketingFrame\\%s.blp:12|t %s", itemSocketTexture[name], _G[name]);
	else
		name = _G[name];
	end

	if value2 then
		if (value2 - value1) > 0 then
			if name == "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
				return string.format("|cff20ff20%.1f (+%.1f)|r %s", value2, value2 - value1, name);
			else
				return string.format("|cff20ff20%d (+%d)|r %s", value2, value2 - value1, name);
			end
		elseif (value1 - value2) > 0 then
			if name == "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
				return string.format("|cffff2020%.1f (-%.1f)|r %s", value2, value1 - value2, name);
			else
				return string.format("|cffff2020%d (-%d)|r %s", value2, value1 - value2, name);
			end
		end
	end

	if statIdicator == 2 then
		if name == "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
			return string.format("|cffff2020-%.1f|r %s", value1, name);
		else
			return string.format("|cffff2020-%d|r %s", value1, name);
		end
	elseif statIdicator == 1 then
		if name == "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
			return string.format("|cff20ff20+%.1f|r %s", value1, name);
		else
			return string.format("|cff20ff20+%d|r %s", value1, name);
		end
	else
		if name == "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
			return string.format("%.1f %s", value1, name);
		else
			return string.format("%d %s", value1, name);
		end
	end
end

local BIND_TYPES = {
	[ITEM_SOULBOUND] = true,
	[ITEM_BIND_TO_ACCOUNT] = true,
	[ITEM_BIND_ON_PICKUP] = true,
	[ITEM_BIND_QUEST] = true,
	[ITEM_BIND_ON_EQUIP] = true,
	[ITEM_BIND_ON_USE] = true,
	[ITEM_STARTS_QUEST] = true,
};

local function GetEffectTexts(itemID, exclusions)
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
	scanTooltip:ClearLines();
	scanTooltip:SetHyperlink(string.format("item:%d", itemID));
	scanTooltip:Show();

	local _, _, _, _, _, itemType, _, _, invType = C_Item.GetItemInfo(itemID, nil, nil, true);

	-- colorblindMode
	for i = ENABLE_COLORBLIND_MODE == "1" and 3 or 2, scanTooltip:NumLines() do
		local obj = _G["ItemUpgradeScanTooltipTextLeft"..i];
		if not obj then
			return;
		end

		local text = obj:GetText();
		if text and text ~= " " then
			if itemType == ITEM_CLASS_3 then
				if not BIND_TYPES[text] then
					return text;
				end
			elseif invType == "INVTYPE_TRINKET" or invType == "INVTYPE_RELIC" then
				local newText
				if string.find(text, ITEM_SPELL_TRIGGER_ONEQUIP) and not exclusions[text] then
					newText = string.match(text, string.format("^%s ([^\n$]+)", ITEM_SPELL_TRIGGER_ONEQUIP));
				elseif string.find(text, ITEM_SPELL_TRIGGER_ONUSE) then
					newText = string.match(text, string.format("^%s ([^\n$]+)", ITEM_SPELL_TRIGGER_ONUSE));
				end

				if newText then
					return newText;
				end
			end
		end
	end
end

local function SummaryItemStats(itemStats1, itemID1, itemStats2, itemID2)
	local stats1, stats2, effects1, effects2 = {}, {}, {}, {};

	local statsExclusions = {};

	local hasItemStats2 = next(itemStats2);

	if itemStats1["ITEM_MOD_SPELL_POWER_SHORT"] then
		itemStats1["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = itemStats1["ITEM_MOD_SPELL_POWER_SHORT"];
		itemStats1["ITEM_MOD_SPELL_POWER_SHORT"] = nil;
	end

	if itemStats2["ITEM_MOD_SPELL_POWER_SHORT"] then
		itemStats2["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = itemStats2["ITEM_MOD_SPELL_POWER_SHORT"];
		itemStats2["ITEM_MOD_SPELL_POWER_SHORT"] = nil;
	end

	for statName1, statValue1 in pairs(itemStats1) do
		local statValue2 = itemStats2[statName1];

		if statName1 == "ITEM_MOD_SPELL_HEALING_DONE_SHORT" then
			local spellDamage = itemStats1["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"];
			if spellDamage then
				statValue1 = statValue1 - spellDamage;
			end

			spellDamage = itemStats2["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"];
			if statValue2 and spellDamage then
				statValue2 = statValue2 - spellDamage;
			end
		elseif statName1 == "ITEM_MOD_SPELL_DAMAGE_DONE_SHORT" then
			statName1 = "ITEM_MOD_SPELL_POWER_SHORT";
		end

		local statText;
		if statName1 == "ITEM_MOD_POWER_REGEN0_SHORT" then
			statText = "ITEM_MOD_MANA_REGENERATION";
		else
			statText = string.sub(statName1, 1, -7);
		end

		if statText and ITEM_STAT_TEXTS[statText] then
			statsExclusions[string.format("%s %s", ITEM_SPELL_TRIGGER_ONEQUIP, string.format(_G[statText], statValue1))] = true;
		end

		if statValue2 then
			if (statValue2 - statValue1) ~= 0 then
				table.insert(stats1, {
					displayString = GetStatString(statName1, statValue1),
					statName = statName1,
					statValue = statValue1,
					active = true,
				});

				table.insert(stats2, {
					displayString = GetStatString(statName1, statValue1, statValue2),
					statName = statName1,
					upgradeValue = statValue2,
					active = true,
				});
			end
		else
			table.insert(stats1, {
				displayString = GetStatString(statName1, statValue1, nil, hasItemStats2 and statIdicatorEnum.Negative or statIdicatorEnum.None),
				statName = statName1,
				statValue = statValue1,
				active = true,
			});
		end
	end

	for statName2, statValue2 in pairs(itemStats2) do
		local statValue1 = itemStats1[statName2];

		if statName2 == "ITEM_MOD_SPELL_HEALING_DONE_SHORT" then
			local spellDamage = itemStats2["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"];
			if spellDamage then
				statValue2 = statValue2 - spellDamage;
			end
		elseif statName2 == "ITEM_MOD_SPELL_DAMAGE_DONE_SHORT" then
			statName2 = "ITEM_MOD_SPELL_POWER_SHORT";
		end

		local statText;
		if statName2 == "ITEM_MOD_POWER_REGEN0_SHORT" then
			statText = "ITEM_MOD_MANA_REGENERATION";
		else
			statText = string.sub(statName2, 1, -7);
		end

		if statText and ITEM_STAT_TEXTS[statText] then
			statsExclusions[string.format("%s %s", ITEM_SPELL_TRIGGER_ONEQUIP, string.format(_G[statText], statValue2))] = true;
		end

		if not statValue1 then
			table.insert(stats2, {
				displayString = GetStatString(statName2, statValue2, nil, statIdicatorEnum.Positive),
				statName = statName2,
				statValue = statValue2,
				active = true,
			});
		end
	end

	table.sort(stats1, SortStats);
	table.sort(stats2, SortStats);

	if itemID1 then
		local effectText = GetEffectTexts(itemID1, statsExclusions);
		if effectText then
			table.insert(effects1, effectText);
		end
	end

	if itemID2 then
		local effectText = GetEffectTexts(itemID2, statsExclusions);
		if effectText then
			table.insert(effects2, effectText);
		end
	end

	return stats1, stats2, effects1, effects2;
end

local function GetCostsToUpgrade(upgradeCostInfo)
	local costsToUpgrade = {};

	if upgradeCostInfo then
		local gold = upgradeCostInfo[ItemUpgradeCost.Gold];
		if gold ~= 0 then
			costsToUpgrade[#costsToUpgrade + 1] = {
				type = "money",
				cost = gold / (100 * 100),
			};
		end

		local honor = upgradeCostInfo[ItemUpgradeCost.Honor];
		if honor ~= 0 then
			costsToUpgrade[#costsToUpgrade + 1] = {
				type = "currency",
				cost = honor,
				itemID = 43308,
			};
		end

		local arena = upgradeCostInfo[ItemUpgradeCost.Arena];
		if arena ~= 0 then
			costsToUpgrade[#costsToUpgrade + 1] = {
				type = "currency",
				cost = arena,
				itemID = 43307,
			};
		end

		for i = 1, 5 do
			local item = upgradeCostInfo[ItemUpgradeCost.Rating + i];
			local count = upgradeCostInfo[ItemUpgradeCost.Item5 + i];
			if item ~= 0 and count ~= 0 then
				costsToUpgrade[#costsToUpgrade + 1] = {
					type = "item",
					cost = count,
					itemID = item,
				};
			end
		end
	end

	return costsToUpgrade;
end

local function GetRequirementToUpgrade(upgradeCostInfo)
	if upgradeCostInfo then
		local rating = upgradeCostInfo[ItemUpgradeCost.Rating];
		if rating ~= 0 then
			local bracket = upgradeCostInfo[ItemUpgradeCost.Bracket];
			if bracket == 0 then
				local arenaRating = math.max(GetArenaRating(1) or 0, GetArenaRating(2) or 0);

				return string.format(ITEM_REQ_ARENA_RATING, rating), arenaRating < rating;
			elseif bracket == 1 then
				local _, _, _, _, battlegroundRating = GetRatedBattlegroundRankInfo();

				return string.format(ITEM_REQ_ARENA_RATING_3V3, rating), battlegroundRating < rating;
			end
		end
	end
end

local function GetRaceFlag(raceName)
	for _, raceInfo in pairs(S_CHARACTER_RACES_INFO) do
		if _G[raceInfo.raceName] == raceName then
			local raceIndex = E_CHARACTER_RACES_DBC[raceInfo.raceName];
			if raceIndex then
				return bit.lshift(1, raceIndex - 1);
			end
		end
 	end

	return 0;
end

local PLAYER_RACE_FLAG = GetRaceFlag(UnitRace("player"));

local _, PLAYER_CLASS = UnitClass("player");
local CLASS_FLAGS = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 4,
    ["ROGUE"] = 8,
    ["PRIEST"] = 16,
    ["DEATHKNIGHT"] = 32,
    ["SHAMAN"] = 64,
    ["MAGE"] = 128,
    ["WARLOCK"] = 256,
    ["DEMONHUNTER"] = 512,
    ["DRUID"] = 1024,
};

local PLAYER_CLASS_FLAG = CLASS_FLAGS[PLAYER_CLASS] or 0;

local REALM_FLAGS = {
	[E_REALM_ID.SCOURGE] = 1,
	[E_REALM_ID.ALGALON] = 2,
	[E_REALM_ID.SIRUS] = 4,
};

local function SetFilterUpgradeItems(upgradeItemInfo)
	if not upgradeItemInfo then
		return false;
	end

	if upgradeItemInfo[ItemUpgrade.ItemCostID] == 0 then
		return false;
	end

	local realmID = C_Service:GetRealmID();
	if REALM_FLAGS[realmID] and bit.band(upgradeItemInfo[ItemUpgrade.RealmFlag], REALM_FLAGS[realmID]) == 0 then
		return false;
	end

	local requirements = ITEM_TEMPLATE_UPGRADE_REQUIREMENTS[upgradeItemInfo[ItemUpgrade.ItemRequirementID]];
	if not requirements then
		return false;
	end

	local raceMask = requirements[ItemUpgradeRequirements.RaceMask] or 0;
	if raceMask ~= 0 and bit.band(raceMask, PLAYER_RACE_FLAG) == 0 then
		return false;
	end

	local classMask = requirements[ItemUpgradeRequirements.ClassMask] or 0;
	if classMask ~= 0 and bit.band(classMask, PLAYER_CLASS_FLAG) == 0 then
		return false;
	end

	local spellID = requirements[ItemUpgradeRequirements.SpellID] or 0;
	if spellID ~= 0 and not (IsSpellKnown(spellID) or C_Unit.GetAuraIndexForSpellID("player", spellID, "HARMFUL")) then
		return false;
	end

	return true;
end

local function SetItemUpgradeItemInfo()
	local itemID = UPGRADE_INFO.itemID;
	if not itemID then
		return;
	end

	local upgradeInfo = ITEM_TEMPLATE_UPGRADES[itemID];

	local numItems = 0;
	local numGroups = 0;

	local itemGroups = {};

	if upgradeInfo then
		for index, upgradeItemInfo in ipairs(upgradeInfo) do
			if SetFilterUpgradeItems(upgradeItemInfo) then
				local groupID = upgradeItemInfo[ItemUpgrade.UpgradeGroupID];

				if not itemGroups[groupID] then
					numGroups = numGroups + 1;

					itemGroups[groupID] = {};
				end

				numItems = numItems + 1;

				table.insert(itemGroups[groupID], index);
			end
		end
	end

	local numGropItems = {};
	local targetItems = {};
	local groupItemsFound;
	for groupID, groupItems in pairs(itemGroups) do
		if #groupItems > 1 and not groupItemsFound then
			if numGroups == 1 or (UPGRADE_INFO.itemSelection and UPGRADE_INFO.itemSelection < 0 and UPGRADE_INFO.itemSelection == -groupItems[1]) then
				for _, index in ipairs(groupItems) do
					table.insert(targetItems, index);
				end
				groupItemsFound = true;
			elseif not UPGRADE_INFO.itemSelection then
				table.insert(targetItems, -groupItems[1]);
				numGropItems[groupItems[1]] = #groupItems;
			end
		elseif #groupItems == 1 and (not UPGRADE_INFO.itemSelection or UPGRADE_INFO.itemSelection > 0) then
			table.insert(targetItems, groupItems[1]);
		end
	end

	local canItemsSelection;
	if UPGRADE_INFO.itemSelection and UPGRADE_INFO.itemSelection < 0 then
		canItemsSelection = false;
	else
		canItemsSelection = numGroups > 1 and (#targetItems > 1 or numItems > 1)
	end

	local itemUpgradeable = numItems > 0;
	local numTargetItems = itemUpgradeable and #targetItems or 0;

	local selectedItemIndex = itemUpgradeable and ((numTargetItems == 1 and 1 or UPGRADE_INFO.itemSelection));

	UPGRADE_INFO.itemUpgradeable = itemUpgradeable;
	UPGRADE_INFO.canItemsSelection = canItemsSelection;

	local name, _, quality, iLvl, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID, nil, ItemCacheCallback, true);

	UPGRADE_INFO.icon = icon;
	UPGRADE_INFO.name = name or "";
	UPGRADE_INFO.quality = quality or 5;
	UPGRADE_INFO.iLvl = iLvl;

	UPGRADE_INFO.selectedItemIndex = selectedItemIndex;

	UPGRADE_INFO.stats = nil;
	UPGRADE_INFO.effects = nil;
	UPGRADE_INFO.groupID = nil;

	UPGRADE_INFO.upgradeInfo = upgradeInfo;

	local itemStats = GetItemStats(string.format("item:%d", itemID)) or {};

	UPGRADE_INFO.upgradeInfos = {};

	local itemIndex = 0;
	for i = 1, numTargetItems do
		local index = targetItems[i];

		if index < 0 then
			local groupIndex = math.abs(index);

			UPGRADE_INFO.upgradeInfos[i] = {
				index = index,
				itemID = nil,
				numItems = numGropItems[groupIndex],
				name = UPGRADE_RANDOM_ITEM,
				icon = "Interface\\Icons\\custom_icon_dice",
				displayQuality = 1,
				itemLevelIncrement = 0,
				realmFlag = ITEM_TEMPLATE_UPGRADES[itemID][groupIndex][ItemUpgrade.RealmFlag],
				costsToUpgrade = GetCostsToUpgrade(ITEM_TEMPLATE_UPGRADE_COSTS[upgradeInfo[groupIndex][ItemUpgrade.ItemCostID]]),
				stats = {},
				effects = {},
			};
		elseif upgradeInfo[index] then
			itemIndex = itemIndex + 1;

			local upgradeItemInfo = upgradeInfo[index];
			local toEntry = upgradeItemInfo[ItemUpgrade.ToEntry];

			local itemCostID = upgradeItemInfo[ItemUpgrade.ItemCostID];
			local upgradeCosts = ITEM_TEMPLATE_UPGRADE_COSTS[itemCostID];

			local entryName, _, entryQuality, entryILvl, _, _, _, _, _, entryIcon = C_Item.GetItemInfo(toEntry, nil, ItemCacheCallback, true);

			UPGRADE_INFO.upgradeInfos[i] = {
				index = itemIndex,
				itemID = toEntry,
				itemCostID = itemCostID,
				name = entryName,
				icon = entryIcon;
				displayQuality = entryQuality,
				itemLevelIncrement = (entryILvl or 0) - (iLvl or 0),
				realmFlag = upgradeItemInfo[ItemUpgrade.RealmFlag],

				costsToUpgrade = GetCostsToUpgrade(upgradeCosts),
			};

			local upgradeRequirements = ITEM_TEMPLATE_UPGRADE_REQUIREMENTS[upgradeItemInfo[ItemUpgrade.ItemRequirementID]];
			if upgradeRequirements then
				UPGRADE_INFO.upgradeInfos[i].specID = upgradeRequirements[ItemUpgradeRequirements.SpecID];
				UPGRADE_INFO.upgradeInfos[i].iconID = upgradeRequirements[ItemUpgradeRequirements.IconID];
			end

			local requirementText, isNotCompleted = GetRequirementToUpgrade(upgradeCosts);
			if requirementText and isNotCompleted then
				UPGRADE_INFO.upgradeInfos[i].failureMessage = requirementText;
			end

			if itemIndex == selectedItemIndex then
				local entryStats = GetItemStats(string.format("item:%d", toEntry)) or {};

				local stats1, stats2, effects1, effects2 = SummaryItemStats(itemStats, itemID, entryStats, toEntry);

				UPGRADE_INFO.stats = stats1;
				UPGRADE_INFO.effects = effects1;

				UPGRADE_INFO.upgradeInfos[i].stats = stats2;
				UPGRADE_INFO.upgradeInfos[i].effects = effects2;

				UPGRADE_INFO.isSaveEnchants = upgradeItemInfo[ItemUpgrade.IsSaveEnchants] == 1;

				UPGRADE_INFO.groupID = upgradeItemInfo[ItemUpgrade.UpgradeGroupID];
			else
				UPGRADE_INFO.upgradeInfos[i].stats = {};
				UPGRADE_INFO.upgradeInfos[i].effects = {};

				if UPGRADE_INFO.isSaveEnchants == nil then
					UPGRADE_INFO.isSaveEnchants = upgradeItemInfo[ItemUpgrade.IsSaveEnchants] == 1;
				end

				if UPGRADE_INFO.groupID == nil then
					UPGRADE_INFO.groupID = upgradeItemInfo[ItemUpgrade.UpgradeGroupID];
				end
			end
		end
	end

	if not UPGRADE_INFO.stats then
		local stats1, _, effects1 = SummaryItemStats(itemStats, itemID, {})
		UPGRADE_INFO.stats = stats1;
		UPGRADE_INFO.effects = effects1;
	end

	return true;
end

C_ItemUpgrade = {};

function C_ItemUpgrade.GetItemHyperlink()
	return UPGRADE_INFO.itemLink;
end

function C_ItemUpgrade.GetItemUpgradeItemInfo()
	local currentItemID = UPGRADE_INFO.itemID;
	if not currentItemID then
		return;
	end

	local isSet = SetItemUpgradeItemInfo();
	if not isSet then
		return;
	end

	local itemUpgradeItemInfo = {};
	itemUpgradeItemInfo.icon = UPGRADE_INFO.icon;
	itemUpgradeItemInfo.name = UPGRADE_INFO.name;
	itemUpgradeItemInfo.displayQuality = UPGRADE_INFO.quality;
	itemUpgradeItemInfo.itemUpgradeable = UPGRADE_INFO.itemUpgradeable;
	itemUpgradeItemInfo.canItemsSelection = UPGRADE_INFO.canItemsSelection;
	itemUpgradeItemInfo.isSaveEnchants = UPGRADE_INFO.isSaveEnchants;

	itemUpgradeItemInfo.itemLevelIncrement = 0;

	itemUpgradeItemInfo.stats = CopyTable(UPGRADE_INFO.stats);
	itemUpgradeItemInfo.effects = CopyTable(UPGRADE_INFO.effects);
	itemUpgradeItemInfo.upgradeInfos = CopyTable(UPGRADE_INFO.upgradeInfos);

	return itemUpgradeItemInfo;
end

function C_ItemUpgrade.GetNumItemUpgradeEffects()
	if not UPGRADE_INFO.itemID then
		return 0;
	end

	local numEffects1 = UPGRADE_INFO.effects and #UPGRADE_INFO.effects or 0;
	local numEffects2 = 0;

	local targetInfo = UPGRADE_INFO.upgradeInfos and UPGRADE_INFO.upgradeInfos[UPGRADE_INFO.selectedItemIndex];
	if targetInfo and targetInfo.effects then
		numEffects2 = #targetInfo.effects;
	end

	return math.max(numEffects1, numEffects2);
end

function C_ItemUpgrade.GetItemUpgradeEffect(index)
	if not UPGRADE_INFO.itemID or not UPGRADE_INFO.effects then
		return;
	end

	local effect1 = UPGRADE_INFO.effects and UPGRADE_INFO.effects[index];
	local effect2;

	local itemUpgradeInfo = UPGRADE_INFO.upgradeInfos and UPGRADE_INFO.upgradeInfos[UPGRADE_INFO.selectedItemIndex];
	if itemUpgradeInfo and itemUpgradeInfo.effects then
		effect2 = itemUpgradeInfo.effects[index];
	end

	return effect1, effect2;
end

function C_ItemUpgrade.SetItemUpgradeItemSelection(id)
	if not UPGRADE_INFO.itemID then
		return;
	end

	if UPGRADE_INFO.itemSelection ~= id then
		UPGRADE_INFO.itemSelection = id;

		FireCustomClientEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
	end
end

function C_ItemUpgrade.GetItemUpgradeItemSelection()
	return UPGRADE_INFO.itemSelection;
end

function C_ItemUpgrade.CanItemUpgradeItemsSelection()
	if not UPGRADE_INFO.itemID then
		return false;
	end

	return UPGRADE_INFO.canItemsSelection;
end

function C_ItemUpgrade.SetUpgradeItemListTooltip(index)
	if not UPGRADE_INFO.itemID then
		return false;
	end

	local itemUpgradeInfo = UPGRADE_INFO.upgradeInfos and UPGRADE_INFO.upgradeInfos[index];
	if itemUpgradeInfo then
		GameTooltip:SetHyperlink(string.format("item:%d", itemUpgradeInfo.itemID));

		local requirementText, isNotCompleted = GetRequirementToUpgrade(ITEM_TEMPLATE_UPGRADE_COSTS[itemUpgradeInfo.itemCostID]);
		if requirementText then
			for i = 1, GameTooltip:NumLines() do
				local line = _G[GameTooltip:GetName().."TextLeft"..i];
				if line then
					local text = line:GetText();
					if text and text ~= " " then
						local iLvl = string.match(text, ITEM_LEVEL_PATTERN);
						if iLvl then
							requirementText = isNotCompleted and string.format("|cffff2020%s|r", requirementText) or string.format("|cffffffff%s|r", requirementText);

							line:SetText(string.format("%s\n%s", requirementText, string.format(ITEM_LEVEL, iLvl)));
							break;
						end
					end
				end
			end

			GameTooltip:Show();
		end
	end
end

function C_ItemUpgrade.GetItemUpgradeCurrentLevel()
	if not UPGRADE_INFO.itemID then
		return 0;
	end

	if UPGRADE_INFO.iLvl then
		return UPGRADE_INFO.iLvl;
	end

	return select(4, GetItemInfo(UPGRADE_INFO.itemID)) or 0;
end

function C_ItemUpgrade.CanUpgradeItem(itemLocation)
	if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
		error("Usage: local canUpgrade = C_ItemUpgrade.CanUpgradeItem(itemLocation)", 2);
	end

	local canUpgrade = false;
	local upgradeType = Enum.ItemUpgradeType.None;

	local itemID = itemLocation:IsValid();
	if itemID then
		local iLvl = select(4, GetItemInfo(itemID)) or 0;

		local upgradeInfo = ITEM_TEMPLATE_UPGRADES[itemID];
		if upgradeInfo then
			for _, upgradeItemInfo in ipairs(upgradeInfo) do
				if SetFilterUpgradeItems(upgradeItemInfo) then
					canUpgrade = true;

					local toEntry = upgradeItemInfo[ItemUpgrade.ToEntry];
					local entryILvl = select(4, GetItemInfo(toEntry)) or 0;

					if entryILvl > iLvl then
						upgradeType = Enum.ItemUpgradeType.Upgrade;
					elseif upgradeType ~= Enum.ItemUpgradeType.None then
						upgradeType = Enum.ItemUpgradeType.Both;
					end
				end
			end

			if upgradeType == Enum.ItemUpgradeType.None then
				upgradeType = Enum.ItemUpgradeType.Other;
			end
		end
	end

	return canUpgrade, upgradeType;
end

function C_ItemUpgrade.CloseItemUpgrade()
	table.wipe(UPGRADE_INFO);
end

function C_ItemUpgrade.ClearItemUpgrade()
	table.wipe(UPGRADE_INFO);

	FireCustomClientEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
end

function C_ItemUpgrade.SetItemUpgradeFromCursorItem()
	table.wipe(UPGRADE_INFO);

	local cursorType, itemID, itemLink = GetCursorInfo();
	local cursorItem = C_Cursor.GetCursorItem();

	if cursorItem and cursorItem:IsValid() then
		if cursorItem:IsEquipmentSlot() then
			UPGRADE_INFO.itemLocation = ItemLocation:CreateFromEquipmentSlot(cursorItem:GetEquipmentSlot());
		elseif cursorItem:IsBagAndSlot() then
			UPGRADE_INFO.itemLocation = ItemLocation:CreateFromBagAndSlot(cursorItem:GetBagAndSlot());
		end

		UPGRADE_INFO.itemID = itemID;
		UPGRADE_INFO.itemLink = itemLink;
	end

	FireCustomClientEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
end

function C_ItemUpgrade.SetItemUpgradeFromLocation(itemLocation)
	if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
		error("Usage: C_ItemUpgrade.SetItemUpgradeFromLocation(itemLocation)", 2);
	end

	table.wipe(UPGRADE_INFO);

	local itemID = itemLocation:IsValid();
	local itemLink = C_Item.GetItemLink(itemLocation);

	if itemLocation and itemLocation:IsValid() then
		if itemLocation:IsEquipmentSlot() then
			UPGRADE_INFO.itemLocation = ItemLocation:CreateFromEquipmentSlot(itemLocation:GetEquipmentSlot());
		elseif itemLocation:IsBagAndSlot() then
			UPGRADE_INFO.itemLocation = ItemLocation:CreateFromBagAndSlot(itemLocation:GetBagAndSlot());
		end

		UPGRADE_INFO.itemID = itemID;
		UPGRADE_INFO.itemLink = itemLink;
	end

	FireCustomClientEvent("ITEM_UPGRADE_MASTER_SET_ITEM");
end

function C_ItemUpgrade.UpgradeItem()
	if UPGRADE_INFO.groupID and UPGRADE_INFO.itemLocation and UPGRADE_INFO.itemLocation:IsValid() then
		if UPGRADE_INFO.itemLocation:IsEquipmentSlot() then
			local slotID = UPGRADE_INFO.itemLocation:GetEquipmentSlot();

			SendServerMessage("ACMSG_UPGRADE_ITEM_REQUEST", string.format("%d:%d:%d", -1, slotID, UPGRADE_INFO.groupID));
		elseif UPGRADE_INFO.itemLocation:IsBagAndSlot() then
			local bagID, slotID = UPGRADE_INFO.itemLocation:GetBagAndSlot();

			SendServerMessage("ACMSG_UPGRADE_ITEM_REQUEST", string.format("%d:%d:%d", bagID, slotID, UPGRADE_INFO.groupID));
		end
	end
end

function EventHandler:ACMSG_UPGRADE_ITEM_RESPONSE(msg)
	local errorID = tonumber(msg);

	UPGRADE_INFO.itemSelection = nil;
	UPGRADE_INFO.itemUpgradeable = nil;
	UPGRADE_INFO.canItemsSelection = nil;
	UPGRADE_INFO.selectedItemIndex = nil;

	if errorID == 0 then
		local itemLocation = UPGRADE_INFO.itemLocation;
		if itemLocation then
			local itemID = itemLocation:IsValid();
			local itemLink = C_Item.GetItemLink(itemLocation);

			if itemLocation:IsValid() then
				UPGRADE_INFO.itemID = itemID;
				UPGRADE_INFO.itemLink = itemLink;
			end
		end

		FireCustomClientEvent("ITEM_UPGRADE_SUCCESS");
	else
		FireCustomClientEvent("ITEM_UPGRADE_FAILED", errorID);
	end
end

function EventHandler:ASMSG_ITEM_UPGRADE_OPEN(msg)
	FireCustomClientEvent("ITEM_UPGRADE_OPEN");
end

function EventHandler:ASMSG_ITEM_UPGRADE_CLOSE(msg)
	FireCustomClientEvent("ITEM_UPGRADE_CLOSE");
end