local CUF_SPELL_BOSS_AURA = CUF_SPELL_BOSS_AURA
local CUF_SPELL_CAN_APPLY_AURAS = CUF_SPELL_CAN_APPLY_AURAS
local CUF_SPELL_VISIBILITY_RANK_LINKS = CUF_SPELL_VISIBILITY_RANK_LINKS
local CUF_SPELL_VISIBILITY_SELF_BUFF = CUF_SPELL_VISIBILITY_SELF_BUFF

local CUF_SPELL_PRIORITY_AURA = CUF_SPELL_PRIORITY_AURA
local CUF_SPELL_VISIBILITY_BLACKLIST = CUF_SPELL_VISIBILITY_BLACKLIST
local CUF_SPELL_VISIBILITY_DATA = CUF_SPELL_VISIBILITY_DATA
local CUF_SPELL_VISIBILITY_TYPES = CUF_SPELL_VISIBILITY_TYPES

local FACTION_OVERRIDE_BY_DEBUFFS = FACTION_OVERRIDE_BY_DEBUFFS
local S_CATEGORY_SPELL_ID = S_CATEGORY_SPELL_ID
local S_VIP_STATUS_DATA = S_VIP_STATUS_DATA
local ZODIAC_DEBUFFS = ZODIAC_DEBUFFS

local unitPetOwnerMap = {
	pet = "player",
};
for i = 1, MAX_RAID_MEMBERS do
	unitPetOwnerMap["raidpet"..i] = "raid"..i;
end
for i = 1, MAX_PARTY_MEMBERS do
	unitPetOwnerMap["party"..i] = "party"..i;
end

--Widget Handlers
local OPTION_TABLE_NONE = {};
BOSS_DEBUFF_SIZE_INCREASE = 9;
CUF_READY_CHECK_DECAY_TIME = 11;
DISTANCE_THRESHOLD_SQUARED = 250*250;
CUF_NAME_SECTION_SIZE = 15;
CUF_AURA_BOTTOM_OFFSET = 2;

function CompactUnitFrame_OnLoad(self)
	-- Names are required for concatenation of compact unit frame names. Search for
	-- Name.."HealthBar" for examples. This is ignored by nameplates.
	if not self.ignoreCUFNameRequirement and not self:GetName() then
		self:Hide();
		error("CompactUnitFrames must have a name");
	end

	self:RegisterEvent("UNIT_MAXHEALTH");
	self:RegisterEvent("UNIT_HEALTH");

	self:RegisterEvent("UNIT_MANA");
	self:RegisterEvent("UNIT_RAGE");
	self:RegisterEvent("UNIT_FOCUS");
	self:RegisterEvent("UNIT_ENERGY");
	self:RegisterEvent("UNIT_RUNIC_POWER");
	self:RegisterEvent("UNIT_MAXMANA");
	self:RegisterEvent("UNIT_MAXRAGE");
	self:RegisterEvent("UNIT_MAXFOCUS");
	self:RegisterEvent("UNIT_MAXENERGY");
	self:RegisterEvent("UNIT_MAXRUNIC_POWER");

	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("UNIT_NAME_UPDATE");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("UNIT_PET");
	self:RegisterEvent("READY_CHECK");
	self:RegisterEvent("READY_CHECK_FINISHED");
	self:RegisterEvent("READY_CHECK_CONFIRM");
	self:RegisterEvent("PARTY_MEMBER_DISABLE");
	self:RegisterEvent("PARTY_MEMBER_ENABLE");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");
	self:RegisterCustomEvent("INCOMING_RESURRECT_CHANGED");
	self:RegisterCustomEvent("INCOMING_SUMMON_CHANGED");
	self:RegisterEvent("RAID_TARGET_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");

	self.name = self.healthBar.name;
	self.statusText = self.healthBar.statusText;
	self.roleGroupIcon = self.healthBar.roleGroupIcon;
	self.roleIcon = self.healthBar.roleIcon;
	self.raidTargetIcon = self.healthBar.raidTargetIcon;
	self.aggroHighlight = self.healthBar.aggroHighlight;

	local frameLevel = self:GetFrameLevel();
	self.healthBar:SetFrameLevel(frameLevel);
	self.powerBar:SetFrameLevel(frameLevel);

	self.maxBuffs = 0;
	self.maxDebuffs = 0;
	self.maxDispelDebuffs = 0;
	CompactUnitFrame_SetOptionTable(self, OPTION_TABLE_NONE);

	if not self.disableMouse then
		CompactUnitFrame_SetUpClicks(self);
	end
end

function CompactUnitFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == self.updateAllEvent and (not self.updateAllFilter or self.updateAllFilter(self, event, ...)) ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		CompactUnitFrame_UpdateAll(self);
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		CompactUnitFrame_UpdateSelectionHighlight(self);
		CompactUnitFrame_UpdateName(self);
	elseif ( event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" ) then
		CompactUnitFrame_UpdateAuras(self);	--We filter differently based on whether the player is in Combat, so we need to update when that changes.
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) then
		CompactUnitFrame_UpdateRoleIcon(self);
		CompactUnitFrame_UpdateRoleGroupIcon(self);
	elseif ( event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		CompactUnitFrame_UpdateRoleGroupIcon(self);
	elseif ( event == "READY_CHECK" ) then
		CompactUnitFrame_UpdateReadyCheck(self);
	elseif ( event == "READY_CHECK_FINISHED" ) then
		CompactUnitFrame_FinishReadyCheck(self);
	elseif ( event == "RAID_TARGET_UPDATE" ) then
		CompactUnitFrame_UpdateRaidTargetIcon(self);
	else
		local unitMatches = arg1 == self.unit or arg1 == self.displayedUnit;
		if ( unitMatches ) then
			if ( event == "UNIT_MAXHEALTH" or (event == "UNIT_PORTRAIT_UPDATE" and string.find(arg1, "pet", 1, true)) ) then
				CompactUnitFrame_UpdateMaxHealth(self);
				CompactUnitFrame_UpdateHealth(self);

				CompactUnitFrame_UpdateHealthColor(self);
				CompactUnitFrame_UpdatePowerColor(self);
				CompactUnitFrame_UpdateStatusText(self);
			elseif ( event == "UNIT_HEALTH" ) then
				CompactUnitFrame_UpdateHealth(self);
				CompactUnitFrame_UpdateStatusText(self);
			elseif ( event == "UNIT_MANA" or event == "UNIT_RAGE" or event == "UNIT_FOCUS" or event == "UNIT_ENERGY" or event == "UNIT_RUNIC_POWER"
					or event == "UNIT_MAXMANA" or event == "UNIT_MAXRAGE" or event == "UNIT_MAXFOCUS" or event == "UNIT_MAXENERGY" or event == "UNIT_MAXRUNIC_POWER" ) then
				CompactUnitFrame_UpdateMaxPower(self);
				CompactUnitFrame_UpdatePower(self);
			elseif ( event == "UNIT_DISPLAYPOWER" ) then
				CompactUnitFrame_UpdateMaxPower(self);
				CompactUnitFrame_UpdatePower(self);
				CompactUnitFrame_UpdatePowerColor(self);
			elseif ( event == "UNIT_NAME_UPDATE" ) then
				CompactUnitFrame_UpdateName(self);
				CompactUnitFrame_UpdateHealthColor(self);	--This may signify that we now have the unit's class (the name cache entry has been received).
			elseif ( event == "UNIT_AURA" ) then
				CompactUnitFrame_UpdateAuras(self);
			elseif ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
				CompactUnitFrame_UpdateAggroHighlight(self);
			elseif ( event == "PARTY_MEMBER_ENABLE" or event == "PARTY_MEMBER_DISABLE" ) then
				--Might want to set the health/mana to max as well so it's easily visible? This happens unless the player is out of AOI.
				CompactUnitFrame_UpdateHealthColor(self);
				CompactUnitFrame_UpdatePowerColor(self);
				CompactUnitFrame_UpdateStatusText(self);
			elseif ( event == "UNIT_PET" ) then
				CompactUnitFrame_UpdateAll(self);
			elseif ( event == "READY_CHECK_CONFIRM" ) then
				CompactUnitFrame_UpdateReadyCheck(self);
			elseif ( event == "INCOMING_RESURRECT_CHANGED" ) then
				CompactUnitFrame_UpdateCenterStatusIcon(self);
			elseif ( event == "PLAYER_FLAGS_CHANGED" ) then
				CompactUnitFrame_UpdateStatusText(self);
				CompactUnitFrame_UpdateRoleGroupIcon(self);
			elseif ( event == "INCOMING_SUMMON_CHANGED" ) then
				CompactUnitFrame_UpdateCenterStatusIcon(self);
			end
		end

		if ( unitMatches or arg1 == "player" ) then
			if ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" ) then
				CompactUnitFrame_UpdateAll(self);
			end
		end
	end
end

--DEBUG FIXME - We should really try to avoid having OnUpdate on every frame. An event when going in/out of range would be greatly preferred.
function CompactUnitFrame_OnUpdate(self, elapsed)
	CompactUnitFrame_UpdateInRange(self);
	CompactUnitFrame_CheckReadyCheckDecay(self, elapsed);
end

--Externally accessed functions
function CompactUnitFrame_SetUnit(frame, unit)
	if ( unit ~= frame.unit or frame.hideCastbar ~= frame.optionTable.hideCastbar ) then
		frame.unit = unit;
		frame.displayedUnit = unit;	--May differ from unit if unit is in a vehicle.
		frame.inVehicle = false;
		frame.readyCheckStatus = nil
		frame.readyCheckDecay = nil;
		frame.isTanking = nil;
		frame.hideCastbar = frame.optionTable.hideCastbar;
		frame.healthBar.healthBackground = nil;
		frame:SetAttribute("unit", unit);
		if ( unit ) then
			CompactUnitFrame_RegisterEvents(frame);
		else
			CompactUnitFrame_UnregisterEvents(frame);
		end
		CompactUnitFrame_UpdateAll(frame);
	end
end

--PLEEEEEASE FIX ME. This makes me very very sad. (Unfortunately, there isn't a great way to deal with the lack of "raid1targettarget" events though)
function CompactUnitFrame_SetUpdateAllOnUpdate(self, doUpdate)
	if ( doUpdate ) then
		if ( not self.onUpdateFrame ) then
			self.onUpdateFrame = CreateFrame("Frame")	--Need to use this so UpdateAll is called even when the frame is hidden.
			self.onUpdateFrame.func = function(updateFrame, elapsed) if ( self.displayedUnit ) then CompactUnitFrame_UpdateAll(self) end end;
		end
		self.onUpdateFrame:SetScript("OnUpdate", self.onUpdateFrame.func);
	else
		if ( self.onUpdateFrame ) then
			self.onUpdateFrame:SetScript("OnUpdate", nil);
		end
	end
end

--Things you'll have to set up to get everything looking right:
--1. Frame size
--2. Health/Mana bar positions
--3. Health/Mana bar textures (also, optionally, background textures)
--4. Name position
--5. Buff/Debuff/Dispellable positions
--6. Call CompactUnitFrame_SetMaxBuffs, _SetMaxDebuffs, and _SetMaxDispelDebuffs. (If you're setting it to greater than the default, make sure to create new buff/debuff frames and position them.)
--7. Selection highlight position and texture.
--8. Aggro highlight position and texture
--9. Role icon position
function CompactUnitFrame_SetUpFrame(frame, func)
	func(frame);
	CompactUnitFrame_UpdateAll(frame);
end

function CompactUnitFrame_SetOptionTable(frame, optionTable)
	frame.optionTable = optionTable;
end

function CompactUnitFrame_RegisterEvents(frame)
	local onEventHandler = frame.OnEvent or CompactUnitFrame_OnEvent;
	frame:SetScript("OnEvent", onEventHandler);

	local onUpdate = frame.OnUpdate or CompactUnitFrame_OnUpdate;
	frame:SetScript("OnUpdate", onUpdate);
end

function CompactUnitFrame_UnregisterEvents(frame)
	frame:SetScript("OnEvent", nil);
	frame:SetScript("OnUpdate", nil);
end

function CompactUnitFrame_SetUpClicks(frame)
	frame:SetAttribute("*type1", "target");
	frame:SetAttribute("*type2", "toggleraidmenu");
	--NOTE: Make sure you also change the CompactAuraTemplate. (It has to be registered for clicks to be able to pass them through.)
	frame:RegisterForClicks("AnyUp");
	CompactUnitFrame_SetMenuFunc(frame, CompactUnitFrameDropDown_Initialize);
end

function CompactUnitFrame_SetMenuFunc(frame, menuFunc)
	UIDropDownMenu_Initialize(frame.dropDown, menuFunc, "MENU");
	frame.menu = function()
		ToggleDropDownMenu(1, nil, frame.dropDown, frame:GetName(), 0, 0);
	end
end

function CompactUnitFrame_SetMaxBuffs(frame, numBuffs)
	frame.maxBuffs = numBuffs;
end

function CompactUnitFrame_SetMaxDebuffs(frame, numDebuffs)
	frame.maxDebuffs = numDebuffs;
end

function CompactUnitFrame_SetMaxDispelDebuffs(frame, numDispelDebuffs)
	frame.maxDispelDebuffs = numDispelDebuffs;
end

function CompactUnitFrame_SetUpdateAllEvent(frame, updateAllEvent, updateAllFilter)
	if ( frame.updateAllEvent ) then
		frame:UnregisterEvent(frame.updateAllEvent);
	end
	frame.updateAllEvent = updateAllEvent;
	frame.updateAllFilter = updateAllFilter;
	frame:RegisterEvent(updateAllEvent);
end

--Internally accessed functions

--Update Functions
function CompactUnitFrame_UpdateAll(frame)
	CompactUnitFrame_UpdateInVehicle(frame);
	CompactUnitFrame_UpdateVisible(frame);
	if ( UnitExists(frame.displayedUnit) ) then
		CompactUnitFrame_UpdateMaxHealth(frame);
		CompactUnitFrame_UpdateHealth(frame);
		CompactUnitFrame_UpdateHealthColor(frame);
		CompactUnitFrame_UpdateMaxPower(frame);
		CompactUnitFrame_UpdatePower(frame);
		CompactUnitFrame_UpdatePowerColor(frame);
		CompactUnitFrame_UpdateName(frame);
		CompactUnitFrame_UpdateSelectionHighlight(frame);
		CompactUnitFrame_UpdateAggroHighlight(frame);
		CompactUnitFrame_UpdateInRange(frame);
		CompactUnitFrame_UpdateStatusText(frame);
		CompactUnitFrame_UpdateRoleIcon(frame);
		CompactUnitFrame_UpdateRoleGroupIcon(frame);
		CompactUnitFrame_UpdateReadyCheck(frame);
		CompactUnitFrame_UpdateAuras(frame);
		CompactUnitFrame_UpdateCenterStatusIcon(frame);
		CompactUnitFrame_UpdateRaidTargetIcon(frame);
	end
end

function CompactUnitFrame_UpdateInVehicle(frame)
	local shouldTargetVehicle = UnitHasVehicleUI(frame.unit);
	local unitVehicleToken;

	if ( shouldTargetVehicle ) then
		local raidID = UnitInRaid(frame.unit);
		if ( raidID and not UnitTargetsVehicleInRaidUI(frame.unit) ) then
			shouldTargetVehicle = false;
		end
	end

	if ( shouldTargetVehicle ) then
		local prefix, id, suffix = string.match(frame.unit, "([^%d]+)([%d]*)(.*)")
		unitVehicleToken = prefix.."pet"..id..suffix;
		if ( not UnitExists(unitVehicleToken) ) then
			shouldTargetVehicle = false;
		end
	end

	if ( shouldTargetVehicle ) then
		if ( not frame.hasValidVehicleDisplay ) then
			frame.hasValidVehicleDisplay = true;
			frame.displayedUnit = unitVehicleToken;
			frame:SetAttribute("unit", frame.displayedUnit);
		end
	else
		if ( frame.hasValidVehicleDisplay ) then
			frame.hasValidVehicleDisplay = false;
			frame.displayedUnit = frame.unit;
			frame:SetAttribute("unit", frame.displayedUnit);
		end
	end
end

function CompactUnitFrame_UpdateVisible(frame)
	if ( UnitExists(frame.unit) or UnitExists(frame.displayedUnit) ) then
		if ( not frame.unitExists ) then
			frame.newUnit = true;
		end

		frame.unitExists = true;
		frame:Show();
	else
		frame:Hide();
		frame.unitExists = false;
	end
end

function CompactUnitFrame_IsTapDenied(frame)
	return frame.optionTable.greyOutWhenTapDenied and not UnitPlayerControlled(frame.unit) and (UnitIsTapped(frame.unit) and not UnitIsTappedByPlayer(frame.unit) and not UnitIsTappedByAllThreatList(frame.unit));
end

function CompactUnitFrame_UpdateHealthColor(frame)
	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	elseif (UnitIsDead(frame.unit)) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		--Try to color it by class.
		local _, englishClass = UnitClass(unitPetOwnerMap[frame.unit] or frame.unit);
		local classColor = RAID_CLASS_COLORS[englishClass];
		if ( not classColor ) then
			classColor = RAID_CLASS_COLORS["PRIEST"];
		end
		if ( (frame.optionTable.allowClassColorsForNPCs or UnitIsPlayer(frame.unit)) and classColor and frame.optionTable.useClassColors ) or
		( frame.optionTable.allowClassColorsForPets and classColor and frame.optionTable.useOwnerClassColors ) then
			-- Use class colors for players if class color option is turned on
			r, g, b = classColor.r, classColor.g, classColor.b;
		elseif ( CompactUnitFrame_IsTapDenied(frame) ) then
			-- Use grey if not a player and can't get tap on unit
			r, g, b = 0.9, 0.9, 0.9;
		elseif ( UnitIsFriend("player", frame.unit) ) then
			r, g, b = 0.0, 1.0, 0.0;
		else
			r, g, b = 1.0, 0.0, 0.0;
		end
	end
	if ( r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b ) then
		frame.healthBar:SetStatusBarColor(r, g, b);

		frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b;
	end
end

function CompactUnitFrame_UpdateMaxHealth(frame)
	local maxHealth = UnitHealthMax(frame.displayedUnit);
	frame.healthBar:SetMinMaxValues(0, maxHealth);
end

function CompactUnitFrame_UpdateHealth(frame)
	local health = UnitHealth(frame.displayedUnit);
	frame.healthBar:SetValue(health);
end

function CompactUnitFrame_UpdateMaxPower(frame)
	if frame.powerBar then
		frame.powerBar:SetMinMaxValues(0, UnitPowerMax(frame.displayedUnit));
	end
end

function CompactUnitFrame_UpdatePower(frame)
	if frame.powerBar then
		frame.powerBar:SetValue(UnitPower(frame.displayedUnit));
	end
end

function CompactUnitFrame_UpdatePowerColor(frame)
	if not frame.powerBar then
		return;
	end

	local r, g, b;
	if ( not UnitIsConnected(frame.unit) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	else
		--Set it to the proper power type color.
		local powerType, powerToken, altR, altG, altB = UnitPowerType(frame.displayedUnit);
		local info = PowerBarColor[powerToken];
		if ( info ) then
			r, g, b = info.r, info.g, info.b;
		else
			if ( not altR ) then
				-- couldn't find a power token entry...default to indexing by power type or just mana if we don't have that either
				info = PowerBarColor[powerType] or PowerBarColor["MANA"];
				r, g, b = info.r, info.g, info.b;
			else
				r, g, b = altR, altG, altB;
			end
		end
	end
	frame.powerBar:SetStatusBarColor(r, g, b);
end

function CompactUnitFrame_UpdateName(frame)
	if ( not frame.optionTable.displayName ) then
		frame.name:Hide();
		return
	end

	frame.name:SetText(GetUnitName(frame.unit, true));
	frame.name:Show();
end

function CompactUnitFrame_UpdateSelectionHighlight(frame)
	if ( not frame.optionTable.displaySelectionHighlight ) then
		frame.selectionHighlight:Hide();
		return;
	end

	if ( UnitIsUnit(frame.displayedUnit, "target") ) then
		frame.selectionHighlight:Show();
	else
		frame.selectionHighlight:Hide();
	end
end

function CompactUnitFrame_UpdateAggroHighlight(frame)
	if ( not frame.optionTable.displayAggroHighlight ) then
		frame.aggroHighlight:Hide();
		return;
	end

	local status = UnitThreatSituation(frame.displayedUnit);
	if ( status and status > 0 ) then
		frame.aggroHighlight:SetVertexColor(GetThreatStatusColor(status));
		frame.aggroHighlight:Show();
	else
		frame.aggroHighlight:Hide();
	end
end

function CompactUnitFrame_UpdateInRange(frame)
	if ( not frame.optionTable.fadeOutOfRange ) then
		return;
	end

	local inRange = UnitInRangeIndex(frame.displayedUnit, frame.optionTable.rangeCheck);
	if ( inRange ) then
		frame:SetAlpha(1);
	else
		frame:SetAlpha(frame.optionTable.rangeAlpha / 100);
	end
end

function CompactUnitFrame_UpdateStatusText(frame)
	if ( not frame.statusText ) then
		return;
	end
	if ( not frame.optionTable.displayStatusText ) then
		frame.statusText:Hide();
		return;
	end

	if ( not UnitIsConnected(frame.unit) ) then
		frame.statusText:SetText(PLAYER_OFFLINE)
		frame.statusText:Show();
	elseif ( UnitIsDeadOrGhost(frame.displayedUnit) ) then
		frame.statusText:SetText(DEAD);
		frame.statusText:Show();
	elseif ( frame.optionTable.healthText == "health" ) then
		frame.statusText:SetText(UnitHealth(frame.displayedUnit));
		frame.statusText:Show();
	elseif ( frame.optionTable.healthText == "losthealth" ) then
		local healthLost = UnitHealthMax(frame.displayedUnit) - UnitHealth(frame.displayedUnit);
		if ( healthLost > 0 ) then
			frame.statusText:SetFormattedText(LOST_HEALTH, healthLost);
			frame.statusText:Show();
		else
			frame.statusText:Hide();
		end
	elseif ( (frame.optionTable.healthText == "perc") and (UnitHealthMax(frame.displayedUnit) > 0) ) then
		local perc = math.ceil(100 * (UnitHealth(frame.displayedUnit)/UnitHealthMax(frame.displayedUnit)));
		frame.statusText:SetFormattedText("%d%%", perc);
		frame.statusText:Show();
	else
		frame.statusText:Hide();
	end
end

--WARNING: This function is very similar to the function UnitFrameUtil_UpdateFillBar in UnitFrame.lua.
--If you are making changes here, it is possible you may want to make changes there as well.
function CompactUnitFrameUtil_UpdateFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	local totalWidth, totalHeight = frame.healthBar:GetSize();

	if ( totalWidth == 0 or amount == 0 ) then
		bar:Hide();
		if ( bar.overlay ) then
			bar.overlay:Hide();
		end
		return previousTexture;
	end

	local barOffsetX = 0;
	if ( barOffsetXPercent ) then
		barOffsetX = totalWidth * barOffsetXPercent;
	end

	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0);
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0);

	local _, totalMax = frame.healthBar:GetMinMaxValues();

	local barSize = (amount / totalMax) * totalWidth;
	bar:SetWidth(barSize);
	bar:Show();
	if ( bar.overlay ) then
		bar.overlay:SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize);
		bar.overlay:Show();
	end
	return bar;
end

function CompactUnitFrame_UpdateRoleIcon(frame)
	if not frame.roleIcon then
		return;
	end

	local size = frame.roleIcon:GetHeight();	--We keep the height so that it carries from the set up, but we decrease the width to 1 to allow room for things anchored to the role (e.g. name).
	local raidID = UnitInRaid(frame.unit);
	if ( UnitInVehicle(frame.unit) and UnitHasVehicleUI(frame.unit) ) then
		frame.roleIcon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Raid-Icon");
		frame.roleIcon:SetTexCoord(0, 1, 0, 1);
		frame.roleIcon:Show();
		frame.roleIcon:SetSize(size, size);
	elseif ( frame.optionTable.displayRaidRoleIcon and raidID and select(10, GetRaidRosterInfo(raidID + 1)) ) then
		local role = select(10, GetRaidRosterInfo(raidID + 1))
		frame.roleIcon:SetTexture("Interface\\GroupFrame\\UI-Group-"..role.."Icon");
		frame.roleIcon:SetTexCoord(0, 1, 0, 1);
		frame.roleIcon:Show();
		frame.roleIcon:SetSize(size, size);
	else
		local isTank, isHealer, isDamage = UnitGroupRolesAssigned(frame.unit);
		local role = isTank and "TANK" or isHealer and "HEALER" or isDamage and "DAMAGER"
		if ( frame.optionTable.displayRoleIcon and (role == "TANK" or role == "HEALER" or role == "DAMAGER") ) then
			frame.roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES");
			frame.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role));
			frame.roleIcon:Show();
			frame.roleIcon:SetSize(size, size);
		else
			frame.roleIcon:Hide();
			frame.roleIcon:SetSize(1, size);
		end
	end


end

function CompactUnitFrame_UpdateRoleGroupIcon(frame)
	if not frame.roleGroupIcon then
		return;
	end

	local size = frame.roleGroupIcon:GetHeight();	--We keep the height so that it carries from the set up, but we decrease the width to 1 to allow room for things anchored to the role (e.g. name).
	local raidID = UnitInRaid(frame.unit);

	if frame.optionTable.displayRaidRoleGroupIcon and (raidID and select(2, GetRaidRosterInfo(raidID + 1)) > 0 or UnitIsGroupLeader(frame.unit)) then
		local role = (UnitIsGroupLeader(frame.unit) or select(2, GetRaidRosterInfo(raidID + 1)) == 2) and "Leader" or "Assistant"
		frame.roleGroupIcon:SetTexture("Interface\\GroupFrame\\UI-Group-"..role.."Icon")
		frame.roleGroupIcon:Show()
		frame.roleGroupIcon:SetSize(size, size)
	else
		frame.roleGroupIcon:Hide()
		frame.roleGroupIcon:SetSize(1, size)
	end
end

function CompactUnitFrame_UpdateRaidTargetIcon(frame)
	if not frame.raidTargetIcon then
		return;
	end

	local size = frame.raidTargetIcon:GetHeight();
	local raidTargetIndex = GetRaidTargetIndex(frame.unit)

	if frame.optionTable.raidTargetIcon and raidTargetIndex then
		frame.raidTargetIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_"..raidTargetIndex)
		frame.raidTargetIcon:Show()
		frame.raidTargetIcon:SetSize(size, size)
	else
		frame.raidTargetIcon:Hide()
		frame.raidTargetIcon:SetSize(1, size)
	end
end

function CompactUnitFrame_UpdateReadyCheck(frame)
	if ( not frame.readyCheckIcon or frame.readyCheckDecay and GetReadyCheckTimeLeft() <= 0 ) then
		return;
	end

	local readyCheckStatus = GetReadyCheckStatus(frame.unit);
	frame.readyCheckStatus = readyCheckStatus;
	if ( readyCheckStatus == "ready" ) then
		frame.readyCheckIcon:SetTexture(READY_CHECK_READY_TEXTURE);
		frame.readyCheckIcon:Show();
	elseif ( readyCheckStatus == "notready" ) then
		frame.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
		frame.readyCheckIcon:Show();
	elseif ( readyCheckStatus == "waiting" ) then
		frame.readyCheckIcon:SetTexture(READY_CHECK_WAITING_TEXTURE);
		frame.readyCheckIcon:Show();
	else
		frame.readyCheckIcon:Hide();
	end
end

function CompactUnitFrame_FinishReadyCheck(frame)
	if ( not frame.readyCheckIcon)  then
		return;
	end
	if ( frame:IsVisible() ) then
		frame.readyCheckDecay = CUF_READY_CHECK_DECAY_TIME;

		if ( frame.readyCheckStatus == "waiting" ) then	--If you haven't responded, you are not ready.
			frame.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
			frame.readyCheckIcon:Show();
		end
	else
		CompactUnitFrame_UpdateReadyCheck(frame);
	end
end

function CompactUnitFrame_CheckReadyCheckDecay(frame, elapsed)
	if ( frame.readyCheckDecay ) then
		if ( frame.readyCheckDecay > 0 ) then
			frame.readyCheckDecay = frame.readyCheckDecay - elapsed;
		else
			frame.readyCheckDecay = nil;
			CompactUnitFrame_UpdateReadyCheck(frame);
		end
	end
end

function CompactUnitFrame_UpdateCenterStatusIcon(frame)
	if ( frame.centerStatusIcon ) then
		if ( frame.optionTable.displayIncomingResurrect and UnitHasIncomingResurrection(frame.unit) ) then
			frame.centerStatusIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez");
			frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
			frame.centerStatusIcon.border:Hide();
			frame.centerStatusIcon.tooltip = nil;
			frame.centerStatusIcon:Show();
		elseif ( frame.optionTable.displayIncomingSummon and C_IncomingSummon.HasIncomingSummon(frame.unit) ) then
			local status = C_IncomingSummon.IncomingSummonStatus(frame.unit);
			if(status == Enum.SummonStatus.Pending) then
				frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonPending");
				frame.centerStatusIcon.border:Hide();
				frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING;
				frame.centerStatusIcon:Show();
			elseif( status == Enum.SummonStatus.Accepted ) then
				frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonAccepted");
				frame.centerStatusIcon.border:Hide();
				frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED;
				frame.centerStatusIcon:Show();
			elseif( status == Enum.SummonStatus.Declined ) then
				frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonDeclined");
				frame.centerStatusIcon.border:Hide();
				frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED;
				frame.centerStatusIcon:Show();
			end
		else
			frame.centerStatusIcon:Hide();
		end
	end
end

--Other internal functions
do
	local function SetDebuffsHelper(debuffFrames, frameNum, maxDebuffs, filter, isBossAura, isBossBuff, auras)
		if auras then
			for i = 1,#auras do
				local aura = auras[i];
				if frameNum > maxDebuffs then
					break;
				end
				local debuffFrame = debuffFrames[frameNum];
				local index, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellId = aura[1], aura[2], aura[3], aura[4], aura[5], aura[6], aura[7], aura[8], aura[9], aura[10], aura[11], aura[12];
				CompactUnitFrame_UtilSetDebuff(debuffFrame, index, filter, isBossAura, isBossBuff, name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellId);
				frameNum = frameNum + 1;

				if isBossAura then
					--Boss auras are about twice as big as normal debuffs, so we may need to display fewer buffs
					local bossDebuffScale = (debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE)/debuffFrame.baseSize;
					maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
				end
			end
		end
		return frameNum, maxDebuffs;
	end

	local function NumElements(arr)
		return arr and #arr or 0;
	end

	local dispellableDebuffTypes = { Magic = true, Curse = true, Disease = true, Poison = true};

	-- This interleaves updating buffFrames, debuffFrames and dispelDebuffFrames to reduce the number of calls to UnitAuraSlots/UnitAuraBySlot
	local function CompactUnitFrame_UpdateAurasInternal(frame)
		local doneWithBuffs = not frame.buffFrames or not frame.optionTable.displayBuffs or frame.maxBuffs == 0;
		local doneWithDebuffs = not frame.debuffFrames or not frame.optionTable.displayDebuffs or frame.maxDebuffs == 0;
		local doneWithDispelDebuffs = not frame.dispelDebuffFrames or not frame.optionTable.displayDispelDebuffs or frame.maxDispelDebuffs == 0;

		local numUsedBuffs = 0;
		local numUsedDebuffs = 0;
		local numUsedDispelDebuffs = 0;

		local displayOnlyDispellableDebuffs = frame.optionTable.displayOnlyDispellableDebuffs;

		-- The following is the priority order for debuffs
		local bossDebuffs, bossBuffs, priorityDebuffs, nonBossDebuffs, nonBossRaidDebuffs;
		local index = 1;
		local batchCount = frame.maxDebuffs;

		if not doneWithDebuffs then
			AuraUtil.ForEachAura(frame.displayedUnit, "HARMFUL", batchCount, function(...)
				if CompactUnitFrame_Util_IsBossAura(...) then
					if not bossDebuffs then
						bossDebuffs = {};
					end
					tinsert(bossDebuffs, {index, ...});
					numUsedDebuffs = numUsedDebuffs + 1;
					if numUsedDebuffs == frame.maxDebuffs then
						doneWithDebuffs = true;
						return true;
					end
				elseif CompactUnitFrame_Util_IsPriorityDebuff(...) then
					if not priorityDebuffs then
						priorityDebuffs = {};
					end
					tinsert(priorityDebuffs, {index, ...});
				elseif not displayOnlyDispellableDebuffs and CompactUnitFrame_Util_ShouldDisplayDebuff(frame.displayedUnit, ...) then
					if not nonBossDebuffs then
						nonBossDebuffs = {};
					end
					tinsert(nonBossDebuffs, {index, ...});
				end

				index = index + 1;
				return false;
			end);
		end

		if not doneWithBuffs or not doneWithDebuffs then
			index = 1;
			batchCount = math.max(frame.maxDebuffs, frame.maxBuffs);
			AuraUtil.ForEachAura(frame.displayedUnit, "HELPFUL", batchCount, function(...)
				if CompactUnitFrame_Util_IsBossAura(...) then
					-- Boss Auras are considered Debuffs for our purposes.
					if not doneWithDebuffs then
						if not bossBuffs then
							bossBuffs = {};
						end
						tinsert(bossBuffs, {index, ...});
						numUsedDebuffs = numUsedDebuffs + 1;
						if numUsedDebuffs == frame.maxDebuffs then
							doneWithDebuffs = true;
						end
					end
				elseif CompactUnitFrame_UtilShouldDisplayBuff(frame.displayedUnit, ...) then
					if not doneWithBuffs then
						numUsedBuffs = numUsedBuffs + 1;
						local buffFrame = frame.buffFrames[numUsedBuffs];
						CompactUnitFrame_UtilSetBuff(buffFrame, index, ...);
						if numUsedBuffs == frame.maxBuffs then
							doneWithBuffs = true;
						end
					end
				end

				index = index + 1;
				return doneWithBuffs and doneWithDebuffs;
			end);
		end

		numUsedDebuffs = math.min(frame.maxDebuffs, numUsedDebuffs + NumElements(priorityDebuffs));
		if numUsedDebuffs == frame.maxDebuffs then
			doneWithDebuffs = true;
		end

		if not doneWithDispelDebuffs then
			--Clear what we currently have for dispellable debuffs
			for debuffType, display in pairs(dispellableDebuffTypes) do
				if ( display ) then
					frame["hasDispel"..debuffType] = false;
				end
			end
		end

		if not doneWithDispelDebuffs or not doneWithDebuffs then
			batchCount = math.max(frame.maxDebuffs, frame.maxDispelDebuffs);
			index = 1;
			AuraUtil.ForEachAura(frame.displayedUnit, "HARMFUL|RAID", batchCount, function(...)
				if not doneWithDebuffs and displayOnlyDispellableDebuffs then
					if CompactUnitFrame_Util_ShouldDisplayDebuff(frame.displayedUnit, ...) and not CompactUnitFrame_Util_IsBossAura(...) and not CompactUnitFrame_Util_IsPriorityDebuff(...) then
						if not nonBossRaidDebuffs then
							nonBossRaidDebuffs = {};
						end
						tinsert(nonBossRaidDebuffs, {index, ...});
						numUsedDebuffs = numUsedDebuffs + 1;
						if numUsedDebuffs == frame.maxDebuffs then
							doneWithDebuffs = true;
						end
					end
				end
				if not doneWithDispelDebuffs then
					local debuffType = select(5, ...);
					if ( dispellableDebuffTypes[debuffType] and not frame["hasDispel"..debuffType] ) then
						frame["hasDispel"..debuffType] = true;
						numUsedDispelDebuffs = numUsedDispelDebuffs + 1;
						local dispellDebuffFrame = frame.dispelDebuffFrames[numUsedDispelDebuffs];
						CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
						if numUsedDispelDebuffs == frame.maxDispelDebuffs then
							doneWithDispelDebuffs = true;
						end
					end
				end
				index = index + 1;
				return (doneWithDebuffs or not displayOnlyDispellableDebuffs) and doneWithDispelDebuffs;
			end);
		end

		local frameNum = 1;
		local maxDebuffs = frame.maxDebuffs;

		do
			local isBossAura = true;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL", isBossAura, isBossBuff, bossDebuffs);
		end
		do
			local isBossAura = true;
			local isBossBuff = true;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HELPFUL", isBossAura, isBossBuff, bossBuffs);
		end
		do
			local isBossAura = false;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL", isBossAura, isBossBuff, priorityDebuffs);
		end
		do
			local isBossAura = false;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL|RAID", isBossAura, isBossBuff, nonBossRaidDebuffs);
		end
		do
			local isBossAura = false;
			local isBossBuff = false;
			frameNum, maxDebuffs = SetDebuffsHelper(frame.debuffFrames, frameNum, maxDebuffs, "HARMFUL", isBossAura, isBossBuff, nonBossDebuffs);
		end
		numUsedDebuffs = frameNum - 1;

		CompactUnitFrame_HideAllBuffs(frame, numUsedBuffs + 1);
		CompactUnitFrame_HideAllDebuffs(frame, numUsedDebuffs + 1);
		CompactUnitFrame_HideAllDispelDebuffs(frame, numUsedDispelDebuffs + 1);
	end

	function CompactUnitFrame_UpdateAuras(frame)
		CompactUnitFrame_UpdateAurasInternal(frame);
	end
end

--Utility Functions
function CompactUnitFrame_UtilShouldDisplayBuff(unit, ...)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellId = ...;

	if CUF_SPELL_VISIBILITY_BLACKLIST[spellId] then
		return false
	end

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
	else
		return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and not shouldConsolidate and PlayerCanApplyAura(spellId, unit, unitCaster, duration) and not SpellIsSelfBuff(spellId);
	end
end

function CompactUnitFrame_HideAllBuffs(frame, startingIndex)
	if frame.buffFrames then
		for i=startingIndex or 1, #frame.buffFrames do
			frame.buffFrames[i]:Hide();
		end
	end
end

function CompactUnitFrame_HideAllDebuffs(frame, startingIndex)
	if frame.debuffFrames then
		for i=startingIndex or 1, #frame.debuffFrames do
			frame.debuffFrames[i]:Hide();
		end
	end
end

function CompactUnitFrame_HideAllDispelDebuffs(frame, startingIndex)
	if frame.dispelDebuffFrames then
		for i=startingIndex or 1, #frame.dispelDebuffFrames do
			frame.dispelDebuffFrames[i]:Hide();
		end
	end
end

function CompactUnitFrame_UtilSetBuff(buffFrame, index, ...)
	local _, _, icon, count, _, duration, expirationTime = ...;
	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		buffFrame.count:Show();
		buffFrame.count:SetText(countText);
	else
		buffFrame.count:Hide();
	end
	buffFrame:SetID(index);
	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_SetTimer(buffFrame.cooldown, startTime, duration, 1);
	else
		buffFrame.cooldown:Hide();
	end
	buffFrame:Show();
end

function CompactUnitFrame_Util_ShouldDisplayDebuff(unit, ...)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, shouldConsolidate, spellId = ...;

	if CUF_SPELL_VISIBILITY_BLACKLIST[spellId]
	or FACTION_OVERRIDE_BY_DEBUFFS[spellId]
	or ZODIAC_DEBUFFS[spellId]
	or S_CATEGORY_SPELL_ID[spellId]
	or S_VIP_STATUS_DATA[spellId]
	then
		return false
	end

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");
	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
	else
		return true;
	end
end

function CompactUnitFrame_Util_IsBossAura(...)
	local spellId = select(11, ...);

	if CUF_SPELL_VISIBILITY_BLACKLIST[spellId]
	or CUF_SPELL_VISIBILITY_SELF_BUFF[spellId]
	or FACTION_OVERRIDE_BY_DEBUFFS[spellId]
	or ZODIAC_DEBUFFS[spellId]
	or S_CATEGORY_SPELL_ID[spellId]
	or S_VIP_STATUS_DATA[spellId]
	then
		return false
	end

	return CUF_SPELL_BOSS_AURA[spellId];
end

do
	local _, classFilename = UnitClass("player");
	if ( classFilename == "PALADIN" ) then
		CompactUnitFrame_Util_IsPriorityDebuff = function(...)
			local spellId = select(11, ...);
			local isForbearance = (spellId == 25771);
			return isForbearance or SpellIsPriorityAura(spellId);
		end
	elseif ( classFilename == "PRIEST" ) then
		CompactUnitFrame_Util_IsPriorityDebuff = function(...)
			local spellId = select(11, ...);
			local isWeakenedSoul = (spellId == 6788);
			return isWeakenedSoul or SpellIsPriorityAura(spellId);
		end
	else
		CompactUnitFrame_Util_IsPriorityDebuff = function(...)
			local spellId = select(11, ...);
			return SpellIsPriorityAura(spellId);
		end
	end
end

function CompactUnitFrame_UtilSetDebuff(debuffFrame, index, filter, isBossAura, isBossBuff, ...)
	-- make sure you are using the correct index here!
	--isBossAura says make this look large.
	--isBossBuff looks in HELPFULL auras otherwise it looks in HARMFULL ones
	local _, _, icon, count, debuffType, duration, expirationTime = ...;
	debuffFrame.filter = filter;
	debuffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 100 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		debuffFrame.count:Show();
		debuffFrame.count:SetText(countText);
	else
		debuffFrame.count:Hide();
	end
	debuffFrame:SetID(index);
	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		local startTime = expirationTime - duration;
		CooldownFrame_SetTimer(debuffFrame.cooldown, startTime, duration, 1);
	else
		debuffFrame.cooldown:Hide();
	end

	local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
	debuffFrame.border:SetVertexColor(color.r, color.g, color.b);

	debuffFrame.isBossBuff = isBossBuff;
	if ( isBossAura ) then
		local size = min(debuffFrame.baseSize + BOSS_DEBUFF_SIZE_INCREASE, debuffFrame.maxHeight);
		debuffFrame:SetSize(size, size);
	else
		debuffFrame:SetSize(debuffFrame.baseSize, debuffFrame.baseSize);
	end

	debuffFrame:Show();
end

function CompactUnitFrame_UtilSetDispelDebuff(dispellDebuffFrame, debuffType, index)
	dispellDebuffFrame:Show();
	dispellDebuffFrame.icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff"..debuffType);
	dispellDebuffFrame:SetID(index);
end

--Dropdown
function CompactUnitFrameDropDown_Initialize(self)
	local unit = self:GetParent().unit;
	if ( not unit ) then
		return;
	end
	local menu;
	local name;
	local id;
	if ( UnitIsUnit(unit, "player") ) then
		menu = "SELF";
	elseif ( UnitIsUnit(unit, "vehicle") ) then
		-- NOTE: vehicle check must come before pet check for accuracy's sake because
		-- a vehicle may also be considered your pet
		menu = "VEHICLE";
	elseif ( UnitIsUnit(unit, "pet") ) then
		menu = "PET";
	elseif ( UnitIsPlayer(unit) ) then
		id = UnitInRaid(unit);
		if ( id ) then
			menu = "RAID_PLAYER";
		elseif ( UnitInParty(unit) ) then
			menu = "PARTY";
		else
			menu = "PLAYER";
		end
	else
		menu = "TARGET";
		name = RAID_TARGET_ICON;
	end
	if ( menu ) then
		UnitPopup_ShowMenu(self, menu, unit, name, id);
	end
end

------The default setup function
local texCoords = {
	["Raid-AggroFrame"] = {  0.00781250, 0.55468750, 0.00781250, 0.27343750 },
	["Raid-TargetFrame"] = { 0.00781250, 0.55468750, 0.28906250, 0.55468750 },
}

DefaultCompactUnitFrameOptions = {
	useClassColors = true,
	displaySelectionHighlight = true,
	displayAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = true,
	displayStatusText = true,
	displayRoleIcon = true,
	displayRaidRoleIcon = true,
	displayRaidRoleGroupIcon = false,
	displayDispelDebuffs = true,
	displayBuffs = true,
	displayDebuffs = true,
	displayOnlyDispellableDebuffs = false,
	displayNonBossDebuffs = true,
	healthText = "none",
	displayIncomingResurrect = true,
	displayIncomingSummon = true,
	displayInOtherGroup = true,
	displayInOtherPhase = true,
	rangeCheck = 3,
	rangeAlpha = 55,
	raidTargetIcon = false,

	--If class colors are enabled also show the class colors for npcs in your raid frames or
	--raid-frame-style party frames.
	allowClassColorsForNPCs = true,
}

local NATIVE_UNIT_FRAME_HEIGHT = 36;
local NATIVE_UNIT_FRAME_WIDTH = 72;
DefaultCompactUnitFrameSetupOptions = {
	displayPowerBar = true,
	height = NATIVE_UNIT_FRAME_HEIGHT,
	width = NATIVE_UNIT_FRAME_WIDTH,
	displayBorder = true,
}

function DefaultCompactUnitFrameSetup(frame)
	local options = DefaultCompactUnitFrameSetupOptions;
	local componentScale = min(options.height / NATIVE_UNIT_FRAME_HEIGHT, options.width / NATIVE_UNIT_FRAME_WIDTH);

	frame:SetAlpha(1);

	frame:SetSize(options.width, options.height);
	local powerBarHeight = 8;
	local powerBarUsedHeight = options.displayPowerBar and powerBarHeight or 0;

	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);

	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1 + powerBarUsedHeight);

	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");

	if ( frame.powerBar ) then
		if ( options.displayPowerBar ) then
			if ( options.displayBorder ) then
				frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, -2);
			else
				frame.powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, 0);
			end
			frame.powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
			frame.powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill", "BORDER");
			frame.powerBar.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Background");
			frame.powerBar:Show();
		else
			frame.powerBar:Hide();
		end
	end

	local NAME_LINE_HEIGHT = min(10 * max(1.15, componentScale), 14)

	frame.raidTargetIcon:ClearAllPoints();
	frame.raidTargetIcon:SetPoint("TOPLEFT", 2, -2);
	frame.raidTargetIcon:SetSize(NAME_LINE_HEIGHT, NAME_LINE_HEIGHT)

	frame.roleIcon:ClearAllPoints();
	frame.roleIcon:SetPoint("TOPLEFT", frame.raidTargetIcon, "TOPRIGHT", 1, 0);
	frame.roleIcon:SetSize(NAME_LINE_HEIGHT, NAME_LINE_HEIGHT);

	frame.roleGroupIcon:ClearAllPoints();
	frame.roleGroupIcon:SetPoint("TOPLEFT", frame.roleIcon, "TOPRIGHT", 1, 0);
	frame.roleGroupIcon:SetSize(NAME_LINE_HEIGHT, NAME_LINE_HEIGHT);

	local fontNameN, _, fontFlagsN = frame.name:GetFont();
	frame.name:SetFont(fontNameN, NAME_LINE_HEIGHT, fontFlagsN);
	frame.name:SetPoint("TOPLEFT", frame.roleGroupIcon, "TOPRIGHT", 0, 1);
	frame.name:SetPoint("TOPRIGHT", -3, -3);
	frame.name:SetJustifyH("LEFT");
	frame.name:SetHeight(NAME_LINE_HEIGHT);

	local STATUS_LINE_HEIGHT = 12 * max(1.1, componentScale);
	local fontName, _, fontFlags = frame.statusText:GetFont();
	frame.statusText:SetFont(fontName, STATUS_LINE_HEIGHT, fontFlags);
	frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 3, options.height / 3 - 2);
	frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, options.height / 3 - 2);
	frame.statusText:SetHeight(STATUS_LINE_HEIGHT);

	local readyCheckSize = 15 * componentScale;
	frame.readyCheckIcon:ClearAllPoints();
	frame.readyCheckIcon:SetPoint("BOTTOM", frame, "BOTTOM", 0, options.height / 3 - 4);
	frame.readyCheckIcon:SetSize(readyCheckSize, readyCheckSize);

	local buffSize = 11 * componentScale;

	CompactUnitFrame_SetMaxBuffs(frame, 3);
	CompactUnitFrame_SetMaxDebuffs(frame, 3);
	CompactUnitFrame_SetMaxDispelDebuffs(frame, 3);

	local buffPos, buffRelativePoint, buffOffset = "BOTTOMRIGHT", "BOTTOMLEFT", CUF_AURA_BOTTOM_OFFSET + powerBarUsedHeight;
	frame.buffFrames[1]:ClearAllPoints();
	frame.buffFrames[1]:SetPoint(buffPos, frame, "BOTTOMRIGHT", -3, buffOffset);
	for i=1, #frame.buffFrames do
		if ( i > 1 ) then
			frame.buffFrames[i]:ClearAllPoints();
			frame.buffFrames[i]:SetPoint(buffPos, frame.buffFrames[i - 1], buffRelativePoint, 0, 0);
		end
		frame.buffFrames[i]:SetSize(buffSize, buffSize);
	end

	local debuffPos, debuffRelativePoint, debuffOffset = "BOTTOMLEFT", "BOTTOMRIGHT", CUF_AURA_BOTTOM_OFFSET + powerBarUsedHeight;
	frame.debuffFrames[1]:ClearAllPoints();
	frame.debuffFrames[1]:SetPoint(debuffPos, frame, "BOTTOMLEFT", 3, debuffOffset);
	for i=1, #frame.debuffFrames do
		if ( i > 1 ) then
			frame.debuffFrames[i]:ClearAllPoints();
			frame.debuffFrames[i]:SetPoint(debuffPos, frame.debuffFrames[i - 1], debuffRelativePoint, 0, 0);
		end
		frame.debuffFrames[i].baseSize = buffSize;
		frame.debuffFrames[i].maxHeight = options.height - powerBarUsedHeight - CUF_AURA_BOTTOM_OFFSET - CUF_NAME_SECTION_SIZE;
		--frame.debuffFrames[i]:SetSize(11, 11);
	end

	frame.dispelDebuffFrames[1]:SetPoint("TOPRIGHT", -3, -2);
	for i=1, #frame.dispelDebuffFrames do
		if ( i > 1 ) then
			frame.dispelDebuffFrames[i]:SetPoint("RIGHT", frame.dispelDebuffFrames[i - 1], "LEFT", 0, 0);
		end
		frame.dispelDebuffFrames[i]:SetSize(12, 12);
	end

	frame.selectionHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.selectionHighlight:SetTexCoord(unpack(texCoords["Raid-TargetFrame"]));
	frame.selectionHighlight:SetAllPoints(frame);

	frame.aggroHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.aggroHighlight:SetTexCoord(unpack(texCoords["Raid-AggroFrame"]));
	frame.aggroHighlight:SetAllPoints(frame);

	frame.centerStatusIcon:ClearAllPoints();
	frame.centerStatusIcon:SetPoint("CENTER", frame, "BOTTOM", 0, options.height / 3 + 2);
	frame.centerStatusIcon:SetSize(buffSize * 2, buffSize * 2);

	if ( options.displayBorder ) then
		frame.horizTopBorder:ClearAllPoints();
		frame.horizTopBorder:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -7);
		frame.horizTopBorder:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -7);
		frame.horizTopBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizTopBorder:SetHeight(8);
		frame.horizTopBorder:Show();

		frame.horizBottomBorder:ClearAllPoints();
		frame.horizBottomBorder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1);
		frame.horizBottomBorder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1);
		frame.horizBottomBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizBottomBorder:SetHeight(8);
		frame.horizBottomBorder:Show();

		frame.vertLeftBorder:ClearAllPoints();
		frame.vertLeftBorder:SetPoint("TOPRIGHT", frame, "TOPLEFT", 7, 0);
		frame.vertLeftBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 7, 0);
		frame.vertLeftBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertLeftBorder:SetWidth(8);
		frame.vertLeftBorder:Show();

		frame.vertRightBorder:ClearAllPoints();
		frame.vertRightBorder:SetPoint("TOPLEFT", frame, "TOPRIGHT", -1, 0);
		frame.vertRightBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -1, 0);
		frame.vertRightBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertRightBorder:SetWidth(8);
		frame.vertRightBorder:Show();

		if ( options.displayPowerBar ) then
			frame.horizDivider:ClearAllPoints();
			frame.horizDivider:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1 + powerBarUsedHeight);
			frame.horizDivider:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1 + powerBarUsedHeight);
			frame.horizDivider:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
			frame.horizDivider:SetHeight(8);
			frame.horizDivider:Show();
		else
			frame.horizDivider:Hide();
		end
	else
		frame.horizTopBorder:Hide();
		frame.horizBottomBorder:Hide();
		frame.vertLeftBorder:Hide();
		frame.vertRightBorder:Hide();

		frame.horizDivider:Hide();
	end

	CompactUnitFrame_SetOptionTable(frame, DefaultCompactUnitFrameOptions)
end

DefaultCompactMiniFrameOptions = {
	displaySelectionHighlight = true,
	displayAggroHighlight = true,
	displayName = true,
	fadeOutOfRange = true,
	rangeCheck = 3,
	rangeAlpha = 55,
	raidTargetIcon = false,
	useOwnerClassColors = false,
	allowClassColorsForPets = true,
	--displayStatusText = true,
	--displayDispelDebuffs = true,
}

DefaultCompactMiniFrameSetUpOptions = {
	height = 18,
	width = 72,
	displayBorder = true,
}

function DefaultCompactMiniFrameSetup(frame)
	local options = DefaultCompactMiniFrameSetUpOptions;
	frame:SetAlpha(1);
	frame:SetSize(options.width, options.height);
	frame.background:SetTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Bg");
	frame.background:SetTexCoord(0, 1, 0, 0.53125);
	frame.healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1);
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1);
	frame.healthBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill", "BORDER");

	frame.name:SetPoint("LEFT", 5, 1);
	frame.name:SetPoint("RIGHT", -3, 1);
	frame.name:SetHeight(12);
	frame.name:SetJustifyH("LEFT");

	frame.selectionHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.selectionHighlight:SetTexCoord(unpack(texCoords["Raid-TargetFrame"]));
	frame.selectionHighlight:SetAllPoints(frame);

	frame.aggroHighlight:SetTexture("Interface\\RaidFrame\\Raid-FrameHighlights");
	frame.aggroHighlight:SetTexCoord(unpack(texCoords["Raid-AggroFrame"]));
	frame.aggroHighlight:SetAllPoints(frame);

	if ( options.displayBorder ) then
		frame.horizTopBorder:ClearAllPoints();
		frame.horizTopBorder:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, -7);
		frame.horizTopBorder:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -7);
		frame.horizTopBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizTopBorder:SetHeight(8);
		frame.horizTopBorder:Show();

		frame.horizBottomBorder:ClearAllPoints();
		frame.horizBottomBorder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1);
		frame.horizBottomBorder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1);
		frame.horizBottomBorder:SetTexture("Interface\\RaidFrame\\Raid-HSeparator");
		frame.horizBottomBorder:SetHeight(8);
		frame.horizBottomBorder:Show();

		frame.vertLeftBorder:ClearAllPoints();
		frame.vertLeftBorder:SetPoint("TOPRIGHT", frame, "TOPLEFT", 7, 0);
		frame.vertLeftBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 7, 0);
		frame.vertLeftBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertLeftBorder:SetWidth(8);
		frame.vertLeftBorder:Show();

		frame.vertRightBorder:ClearAllPoints();
		frame.vertRightBorder:SetPoint("TOPLEFT", frame, "TOPRIGHT", -1, 0);
		frame.vertRightBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -1, 0);
		frame.vertRightBorder:SetTexture("Interface\\RaidFrame\\Raid-VSeparator");
		frame.vertRightBorder:SetWidth(8);
		frame.vertRightBorder:Show();
	else
		frame.horizTopBorder:Hide();
		frame.horizBottomBorder:Hide();
		frame.vertLeftBorder:Hide();
		frame.vertRightBorder:Hide();
	end

	CompactUnitFrame_SetOptionTable(frame, DefaultCompactMiniFrameOptions)
end

local _, PLAYER_CLASS = UnitClass("player");

---@param spellId integer|string
---@return boolean
function SpellIsSelfBuff(spellId)
	if type(spellId) == "string" then
		spellId = tonumber(spellId);
	end
	if type(spellId) ~= "number" then
		error("Usage: SpellIsSelfBuff(spellID)", 2);
	end

	return CUF_SPELL_VISIBILITY_SELF_BUFF[spellId] or false;
end

---@param spellId integer|string
---@param visType string @ "RAID_INCOMBAT | RAID_OUTOFCOMBAT | ENEMY_TARGET"
---@return boolean hasCustom @"whether the spell visibility should be customized, if false it means always display"
---@return boolean? alwaysShowMine @whether to show the spell if cast by the player/player's pet/vehicle (e.g. the Paladin Forbearance debuff)
---@return boolean? showForMySpec @whether to show the spell for the current specialization of the player
---[Documentation](https://wowpedia.fandom.com/wiki/API_SpellGetVisibilityInfo)
---Checks if the spell should be visible, depending on spellId and raid combat status
function SpellGetVisibilityInfo(spellId, visType)
	if type(spellId) == "string" then
		spellId = tonumber(spellId);
	end
	if type(spellId) ~= "number" or type(visType) ~= "string" then
		error("Usage: SpellGetVisibilityInfo(spellID, \"visType\")", 2)
	end

	local visIndex = CUF_SPELL_VISIBILITY_TYPES[visType];
	if not visIndex then
		error("SpellGetVisibilityInfo: Invalid visType. Valid types: \"RAID_INCOMBAT\", \"RAID_OUTOFCOMBAT\", \"ENEMY_TARGET\"", 2)
	end

	if CUF_SPELL_VISIBILITY_BLACKLIST[spellId] then
		return true, false, false
	end

	spellId = CUF_SPELL_VISIBILITY_RANK_LINKS[spellId] or spellId;

	local info = CUF_SPELL_VISIBILITY_DATA[spellId];
	if info then
		local visInfo = info[visIndex];

		if visInfo then
			local talents = visInfo.talents;
			local currentSpecTabID = C_Talent.GetCurrentSpecTabIndex()

			if talents and talents[PLAYER_CLASS] and currentSpecTabID ~= 0 then
				return true, bit.band(visInfo.flag, 1) ~= 0, talents[PLAYER_CLASS][currentSpecTabID] or false;
			else
				return true, bit.band(visInfo.flag, 1) ~= 0, false;
			end
		end
	end

	return false;
end

---@param spellId integer|string
function SpellIsPriorityAura(spellId)
	if type(spellId) == "string" then
		spellId = tonumber(spellId);
	end
	if type(spellId) ~= "number" then
		error("Usage: SpellIsPriorityAura(spellID)", 2);
	end

	return LOSS_OF_CONTROL_SPELL_DATA[spellId] ~= nil or CUF_SPELL_PRIORITY_AURA[spellId] ~= nil or false;
end

---@param spellId integer|string
---@return boolean
function CompactUnitFrame_Util_SpellIsBlacklisted(spellId)
	if type(spellId) == "string" then
		spellId = tonumber(spellId);
	end
	if type(spellId) ~= "number" then
		error("Usage: SpellIsSelfBuff(spellID)", 2);
	end

	if CUF_SPELL_VISIBILITY_BLACKLIST[spellId]
	or FACTION_OVERRIDE_BY_DEBUFFS[spellId]
	or ZODIAC_DEBUFFS[spellId]
	or S_CATEGORY_SPELL_ID[spellId]
	or S_VIP_STATUS_DATA[spellId]
	then
		return true;
	end
	return false;
end

do
	local CLASS_FAMILY = {
		MAGE		= 3,
		WARRIOR		= 4,
		WARLOCK		= 5,
		PRIEST		= 6,
		DRUID		= 7,
		ROGUE		= 8,
		HUNTER		= 9,
		PALADIN		= 10,
		SHAMAN		= 11,
		DEATHKNIGHT = 15,
	}

	local PLAYER_CLASS_FAMILY = CLASS_FAMILY[PLAYER_CLASS]

	function PlayerCanApplyAura(spellId, unit, unitCaster, duration)
		local canApplyAura = CUF_SPELL_CAN_APPLY_AURAS[PLAYER_CLASS_FAMILY][spellId]
		if canApplyAura and duration > 0 then
			if unit and CUF_SPELL_VISIBILITY_SELF_BUFF[spellId] then
				return UnitIsUnit("player", unit) and true or false
			else
				return UnitIsUnit("player", unitCaster) and true or false
			end
		end
		return false
	end
end