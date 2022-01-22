local AcceptBattlefieldPort = AcceptBattlefieldPort

local QueueStatusSuspendType = {
	LFG = 1,
	Battleground = 2,
	WorldPVP = 3,
	ActiveWorldPVP = 4,
};

local QueueStatusActiveType, QueueStatusActiveIndex

----------------------------------------------
---------QueueStatusMinimapButton-------------
----------------------------------------------

function QueueStatusMinimapButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:SetFrameLevel(self:GetFrameLevel() + 1);
	self.glowLocks = {};
end

function QueueStatusMinimapButton_OnEnter(self)
	QueueStatusFrame:Show();
end

function QueueStatusMinimapButton_OnLeave(self)
	QueueStatusFrame:Hide();
end

function QueueStatusMinimapButton_OnClick(self, button)
	if ( button == "RightButton" ) then
		QueueStatusDropDown_Show(self.DropDown, self:GetName());
	else
		if ( IsShiftKeyDown() ) then
			ToggleBattlefieldMinimap()
			return
		end

		local inBattlefield, showScoreboard = QueueStatus_InActiveBattlefield();
		if ( inBattlefield and showScoreboard ) then
			ToggleWorldStateScoreFrame();
		else
			--Just show the dropdown
			QueueStatusDropDown_Show(self.DropDown, self:GetName());
		end
	end
end

function QueueStatusMinimapButton_OnShow(self)
	self.Eye:SetFrameLevel(self:GetFrameLevel() - 1);
end

function QueueStatusMinimapButton_OnHide(self)
	QueueStatusFrame:Hide();
end

----------------------------------------------
------------QueueStatusFrame------------------
----------------------------------------------
function QueueStatusFrame_OnLoad(self)
	--For everything
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");

	--For LFG
	self:RegisterEvent("LFG_UPDATE");
	self:RegisterEvent("LFG_ROLE_CHECK_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_UPDATE");
	self:RegisterEvent("LFG_PROPOSAL_FAILED");
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED");
	self:RegisterEvent("LFG_PROPOSAL_SHOW");
	self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE");

	--For PvP
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");

	--For World PvP stuff
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");

	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_REQUEST_RESPONSE");
	self:RegisterEvent("BATTLEFIELD_MGR_QUEUE_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTRY_INVITE");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECT_PENDING");
	self:RegisterEvent("BATTLEFIELD_MGR_EJECTED");
	self:RegisterEvent("BATTLEFIELD_MGR_ENTERED");

	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

	QueueStatusFrame_CreateEntriesPool(self);
end

function QueueStatusFrame_OnEvent(self)
	QueueStatusActiveType, QueueStatusActiveIndex = QueueStatus_IsActiveQueue()

	QueueStatusFrame_Update(self);
end

function QueueStatusFrame_GetEntry(self, entryIndex)
	local entry = self.statusEntriesPool:Acquire();
	entry.orderIndex = entryIndex;
	return entry;
end

do
	local function EntryComparator(left, right)
		if (left.active ~= right.active) then
			return left.active;
		end

		return left.orderIndex < right.orderIndex;
	end

	function QueueStatusFrame_SortAndAnchorEntries(self)
		local entries = {};
		for entry in self.statusEntriesPool:EnumerateActive() do
			entries[#entries + 1] = entry;
		end
		table.sort(entries, EntryComparator);

		local prevEntry;
		for i, entry in ipairs(entries) do
			if ( not prevEntry ) then
				entry:SetPoint("TOP", self, "TOP", 0, 0);
				entry.EntrySeparator:Hide();
			else
				entry:SetPoint("TOP", prevEntry, "BOTTOM", 0, 0);
			end
			prevEntry = entry;
		end
	end
end

do
    local function QueueStatusEntryResetter(pool, frame)
	    frame:Hide();
	    frame:ClearAllPoints();
    
	    frame.EntrySeparator:Show();
	    frame.active = false;
	    frame.orderIndex = nil;
    end

	function QueueStatusFrame_CreateEntriesPool(self)
		self.statusEntriesPool = CreateFramePool("FRAME", self, "QueueStatusEntryTemplate", QueueStatusEntryResetter);
	end
end

function QueueStatusFrame_Update(self)
	local animateEye;
	local shownHearthAndRes;

	local nextEntry = 1;

	local totalHeight = 4; --Add some buffer height

	self.statusEntriesPool:ReleaseAll();

	--Try each LFG type
	local mode, submode = GetLFGMode();
	if ( mode ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpLFG(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;

		if ( mode == "queued" or mode == "listed" or mode == "rolecheck" ) then
			animateEye = true;
		end
	end

	--Try all PvP queues
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpBattlefield(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			if ( status == "queued" ) then
				animateEye = true;
			end
		end
	end

	--Try all World PvP queues
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status and status ~= "none" ) then
			local entry = QueueStatusFrame_GetEntry(self, nextEntry);
			QueueStatusEntry_SetUpWorldPvP(entry, i);
			entry:Show();
			totalHeight = totalHeight + entry:GetHeight();
			nextEntry = nextEntry + 1;

			if ( status == "queued" ) then
				animateEye = true;
			end

			if ( not shownHearthAndRes and GetRealZoneText() == mapName ) then
				shownHearthAndRes = true
			end
		end
	end

	--World PvP areas we're currently in
	if ( CanHearthAndResurrectFromArea() and GetBFQueueStatus(1) == "active" and not shownHearthAndRes ) then
		local entry = QueueStatusFrame_GetEntry(self, nextEntry);
		QueueStatusEntry_SetUpActiveWorldPVP(entry);
		entry:Show();
		totalHeight = totalHeight + entry:GetHeight();
		nextEntry = nextEntry + 1;
	end

	QueueStatusFrame_SortAndAnchorEntries(self);

	--Update the size of this frame to fit everything
	self:SetHeight(totalHeight);

	--Update the minimap icon
	if ( nextEntry > 1 ) then
		QueueStatusMinimapButton:Show();
	else
		QueueStatusMinimapButton:Hide();
	end
	if ( animateEye ) then
		EyeTemplate_StartAnimating(QueueStatusMinimapButton.Eye);
	else
		EyeTemplate_StopAnimating(QueueStatusMinimapButton.Eye);
	end
end

----------------------------------------------
------------QueueStatusEntry------------------
----------------------------------------------

function QueueStatusEntry_SetUpLFG(entry)
	local mode, submode = GetLFGMode();

	if ( QueueStatusActiveType and QueueStatusActiveType ~= QueueStatusSuspendType.LFG ) then
		mode = "suspended"
	end

	--Set up the actual display
	if ( mode == "queued" ) then
		local leader, tank, healer, dps = GetLFGRoles();
		local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, instanceType, instanceName, averageWait, tankWait, healerWait, damageWait, myWait, queuedTime = GetLFGQueueStats();

		QueueStatusEntry_SetFullDisplay(entry, LOOKING_FOR_DUNGEON, queuedTime, myWait, tank, healer, dps, 1, 1, 3, tankNeeds or 1, healerNeeds or 1, dpsNeeds or 3);
	elseif ( mode == "proposal" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LOOKING_FOR_DUNGEON, QUEUED_STATUS_PROPOSAL);
	elseif ( mode == "listed" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LOOKING_FOR_RAID, QUEUED_STATUS_LISTED);
	elseif ( mode == "rolecheck" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LOOKING_FOR_DUNGEON, ROLE_CHECK_IN_PROGRESS_TOOLTIP);
	elseif ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LOOKING_FOR_DUNGEON, QUEUED_STATUS_IN_PROGRESS);
	elseif ( mode == "suspended" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, LOOKING_FOR_DUNGEON, QUEUED_STATUS_SUSPENDED);
	end
end

function QueueStatusEntry_SetUpBattlefield(entry, idx)
	local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(idx);

	if ( status == "queued" ) then
		if ( QueueStatusActiveType and ( QueueStatusActiveType ~= QueueStatusSuspendType.Battleground or QueueStatusActiveIndex ~= idx ) ) then
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
		else
			local queuedTime = GetTime() - GetBattlefieldTimeWaited(idx) / 1000;
			local estimatedTime = GetBattlefieldEstimatedWaitTime(idx) / 1000;
			QueueStatusEntry_SetFullDisplay(entry, mapName, queuedTime, estimatedTime);
		end
	elseif ( status == "confirm" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_PROPOSAL);
	elseif ( status == "active" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
	elseif ( status == "locked" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_LOCKED, QUEUED_STATUS_LOCKED_EXPLANATION);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_UNKNOWN);
	end
end

function QueueStatusEntry_SetUpWorldPvP(entry, idx)
	local status, mapName, queueID, expireTime = GetWorldPVPQueueStatus(idx);
	if ( status == "queued" ) then
		if ( QueueStatusActiveType and ( QueueStatusActiveType ~= QueueStatusSuspendType.WorldPVP or QueueStatusActiveIndex ~= idx ) ) then
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_SUSPENDED);
		else
			QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_QUEUED);
		end
	elseif ( status == "confirm" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_PROPOSAL);
	elseif ( status == "active" ) then
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_IN_PROGRESS);
	else
		QueueStatusEntry_SetMinimalDisplay(entry, mapName, QUEUED_STATUS_UNKNOWN);
	end
end

function QueueStatusEntry_SetUpActiveWorldPVP(entry)
	QueueStatusEntry_SetMinimalDisplay(entry, GetRealZoneText(), QUEUED_STATUS_IN_PROGRESS);
end

function QueueStatusEntry_SetMinimalDisplay(entry, title, status, subTitle, extraText)
	local height = 10;

	entry.Title:SetText(title);
	entry.Status:SetText(status);
	entry.Status:Show();
	entry.SubTitle:ClearAllPoints();
	entry.SubTitle:SetPoint("TOPLEFT", entry.Status, "BOTTOMLEFT", 0, -5);
	entry.active = (status == QUEUED_STATUS_IN_PROGRESS);

	height = height + entry.Status:GetHeight() + entry.Title:GetHeight();

	if ( subTitle ) then
		entry.SubTitle:SetText(subTitle);
		entry.SubTitle:Show();
		height = height + entry.SubTitle:GetHeight() + 5;
	else
		entry.SubTitle:Hide();
	end

	if ( extraText ) then
		entry.ExtraText:SetText(extraText);
		entry.ExtraText:Show();
		entry.ExtraText:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 5));
		height = height + entry.ExtraText:GetHeight() + 5;
	else
		entry.ExtraText:Hide();
	end

	entry.TimeInQueue:Hide();
	entry.AverageWait:Hide();

	for i=1, LFD_NUM_ROLES do
		entry["RoleIcon"..i]:Hide();
	end

	entry.TanksFound:Hide();
	entry.HealersFound:Hide();
	entry.DamagersFound:Hide();

	entry:SetScript("OnUpdate", nil);

	entry:SetHeight(height + 6);
end

function QueueStatusEntry_SetFullDisplay(entry, title, queuedTime, myWait, isTank, isHealer, isDPS, totalTanks, totalHealers, totalDPS, tankNeeds, healerNeeds, dpsNeeds, subTitle, extraText)
	local height = 14;
	
	entry.Title:SetText(title);
	height = height + entry.Title:GetHeight();

	entry.Status:Hide();
	entry.SubTitle:ClearAllPoints();
	entry.SubTitle:SetPoint("TOPLEFT", entry.Title, "BOTTOMLEFT", 0, -5);

	if ( subTitle ) then
		entry.SubTitle:SetText(subTitle);
		entry.SubTitle:Show();
		height = height + entry.SubTitle:GetHeight() + 5;
	else
		entry.SubTitle:Hide();
	end

	--Update your role icons
	local nextRoleIcon = 1;
	if ( isDPS ) then
		local icon = entry["RoleIcon"..nextRoleIcon];
		icon:SetTexCoord(GetTexCoordsForRole("DAMAGER"));
		icon:Show();
		nextRoleIcon = nextRoleIcon + 1;
	end
	if ( isHealer ) then
		local icon = entry["RoleIcon"..nextRoleIcon];
		icon:SetTexCoord(GetTexCoordsForRole("HEALER"));
		icon:Show();
		nextRoleIcon = nextRoleIcon + 1;
	end
	if ( isTank ) then
		local icon = entry["RoleIcon"..nextRoleIcon];
		icon:SetTexCoord(GetTexCoordsForRole("TANK"));
		icon:Show();
		nextRoleIcon = nextRoleIcon + 1;
	end

	for i=nextRoleIcon, LFD_NUM_ROLES do
		entry["RoleIcon"..i]:Hide();
	end

	--Update the role needs
	if ( totalTanks and totalHealers and totalDPS ) then
		entry.HealersFound:SetPoint("TOP", entry, "TOP", 0, -(height + 5));
		entry.TanksFound.Count:SetFormattedText("%d/%d", totalTanks - tankNeeds, totalTanks);
		entry.HealersFound.Count:SetFormattedText("%d/%d", totalHealers - healerNeeds, totalHealers);
		entry.DamagersFound.Count:SetFormattedText("%d/%d", totalDPS - dpsNeeds, totalDPS);

		entry.TanksFound.Texture:SetDesaturated(tankNeeds ~= 0);
		entry.TanksFound.Cover:SetShown(tankNeeds ~= 0);
		entry.HealersFound.Texture:SetDesaturated(healerNeeds ~= 0);
		entry.HealersFound.Cover:SetShown(healerNeeds ~= 0);
		entry.DamagersFound.Texture:SetDesaturated(dpsNeeds ~= 0);
		entry.DamagersFound.Cover:SetShown(dpsNeeds ~= 0);

		entry.TanksFound:Show();
		entry.HealersFound:Show();
		entry.DamagersFound:Show();
		height = height + 68;
	else
		entry.TanksFound:Hide();
		entry.HealersFound:Hide();
		entry.DamagersFound:Hide();
	end

	if ( not myWait or myWait <= 0 ) then
		entry.AverageWait:Hide();
	else
		entry.AverageWait:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 5));
		entry.AverageWait:SetFormattedText(LFG_STATISTIC_AVERAGE_WAIT, SecondsToTime(myWait, false, false, 1));
		entry.AverageWait:Show();
		height = height + entry.AverageWait:GetHeight();
	end

	if ( queuedTime ) then
		entry.queuedTime = queuedTime;
		local elapsed = GetTime() - queuedTime;
		entry.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, (elapsed >= 60) and SecondsToTime(elapsed) or LESS_THAN_ONE_MINUTE);
		entry:SetScript("OnUpdate", QueueStatusEntry_OnUpdate);
	else
		entry.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, LESS_THAN_ONE_MINUTE);
		entry:SetScript("OnUpdate", nil);
	end
	entry.TimeInQueue:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 5));
	entry.TimeInQueue:Show();
	height = height + entry.TimeInQueue:GetHeight();

	if ( extraText ) then
		entry.ExtraText:SetText(extraText);
		entry.ExtraText:Show();
		entry.ExtraText:SetPoint("TOPLEFT", entry, "TOPLEFT", 10, -(height + 10));
		height = height + entry.ExtraText:GetHeight() + 10;
	else
		entry.ExtraText:Hide();
	end

	entry:SetHeight(height + 14);
end

function QueueStatusEntry_OnUpdate(self, elapsed)
	--Don't update every tick (can't do 1 second beause it might be 1.01 seconds and we'll miss a tick.
	--Also can't do slightly less than 1 second (0.9) because we'll end up with some lingering numbers
	self.updateThrottle = (self.updateThrottle or 0.1) - elapsed;
	if ( self.updateThrottle <= 0 ) then
		local elapsed = GetTime() - self.queuedTime;
		self.TimeInQueue:SetFormattedText(TIME_IN_QUEUE, (elapsed >= 60) and SecondsToTime(elapsed) or LESS_THAN_ONE_MINUTE);
		self.updateThrottle = 0.1;
	end
end

----------------------------------------------
------------QueueStatusDropDown---------------
----------------------------------------------
function QueueStatusDropDown_Show(self, relativeTo)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	ToggleDropDownMenu(1, nil, self, relativeTo, 0, 0);
end

local wrappedFuncs = {};
local function wrapFunc(func) --Lets us directly set .func = on dropdown entries.
	if ( not wrappedFuncs[func] ) then
		wrappedFuncs[func] = function(button, ...) func(...) end;
	end
	return wrappedFuncs[func];
end

function QueueStatusDropDown_Update()
	local numQueuesInQueued = 0;

	--All LFG types
	local mode, submode = GetLFGMode();
	if ( mode ) then
		QueueStatusDropDown_AddLFGButtons();

		if mode == "queued" then
			numQueuesInQueued = numQueuesInQueued + 1;
		end
	end

	local shownHearthAndRes
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(i);
		if ( status and status ~= "none" ) then
			shownHearthAndRes = QueueStatusDropDown_AddBattlefieldButtons(i, shownHearthAndRes);

			if status == "queued" then
				numQueuesInQueued = numQueuesInQueued + 1;
			end
		end
	end

	--World PvP
	for i=1, MAX_WORLD_PVP_QUEUES do
		local status, mapName, queueID = GetWorldPVPQueueStatus(i);
		if ( status and status ~= "none" ) then
			shownHearthAndRes = QueueStatusDropDown_AddWorldPvPButtons(i, shownHearthAndRes);

			if status == "queued" then
				numQueuesInQueued = numQueuesInQueued + 1;
			end
		end
	end

	if ( CanHearthAndResurrectFromArea() and GetBFQueueStatus(1) == "active" and not shownHearthAndRes ) then
		local info = UIDropDownMenu_CreateInfo();
		local name = GetRealZoneText();
		info.text = "|cff19ff19"..name.."|r";
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info.text = format(LEAVE_ZONE, name);
		info.isTitle = false;
		info.disabled = false;
		info.func = wrapFunc(HearthAndResurrectFromArea);
		UIDropDownMenu_AddButton(info);
	end

	if numQueuesInQueued > 1 then
		local info = UIDropDownMenu_CreateInfo();
		info.hasArrow = false;
		info.dist = 0;
		info.isTitle = true;
		info.isUninteractable = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);

		info.text = LEAVE_ALL_QUEUES;
		info.isTitle = false;
		info.disabled = false;
		info.func = wrapFunc(QueueStatus_LeaveAllQueues);
		UIDropDownMenu_AddButton(info);
	end
end

function QueueStatusDropDown_AddWorldPvPButtons(idx, shownHearthAndRes)
	local info = UIDropDownMenu_CreateInfo();
	local status, mapName, queueID = GetWorldPVPQueueStatus(idx);

	local name = mapName;

	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( status == "queued" or status == "confirm" ) then
		if ( CanHearthAndResurrectFromArea() and not shownHearthAndRes and GetRealZoneText() == mapName ) then
			info.text = format(LEAVE_ZONE, GetRealZoneText());
			info.func = wrapFunc(HearthAndResurrectFromArea);
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
			shownHearthAndRes = true;
		end

		if ( status == "queued" ) then
			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(BattlefieldMgrExitRequest);
			info.arg1 = queueID;
			UIDropDownMenu_AddButton(info);
		elseif ( status == "confirm" ) then
			info.text = ENTER_BATTLE;
			info.func = wrapFunc(BattlefieldMgrEntryInviteResponse);
			info.arg1 = queueID;
			info.arg2 = 1;
			UIDropDownMenu_AddButton(info);

			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(BattlefieldMgrExitRequest);
			info.arg1 = queueID;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end
	end

	return shownHearthAndRes
end

function QueueStatusDropDown_AddBattlefieldButtons(idx, shownHearthAndRes)
	local info = UIDropDownMenu_CreateInfo();
	local status, mapName, _, _, _, teamSize, registeredMatch = GetBattlefieldStatus(idx);

	local name = mapName;
	if ( name and status == "active" ) then
		name = "|cff19ff19"..name.."|r";
	end
	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( status == "queued" or status == "confirm" ) then
		if ( CanHearthAndResurrectFromArea() and not shownHearthAndRes and GetRealZoneText() == mapName ) then
			info.text = format(LEAVE_ZONE, GetRealZoneText());
			info.func = wrapFunc(HearthAndResurrectFromArea);
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info);
			shownHearthAndRes = true;
		end

		if ( status == "queued" ) then
			info.text = LEAVE_QUEUE;
			info.func = wrapFunc(AcceptBattlefieldPort);
			info.arg1 = idx;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		elseif ( status == "confirm" ) then
			info.disabled = UnitAffectingCombat("player");
			info.text = ENTER_BATTLE;
			info.func = wrapFunc(AcceptBattlefieldPort);
			info.arg1 = idx;
			info.arg2 = 1;
			UIDropDownMenu_AddButton(info);

			if ( teamSize == 0 ) then
				info.disabled = false;
				info.text = LEAVE_QUEUE;
				info.func = wrapFunc(AcceptBattlefieldPort);
				info.arg1 = idx;
				info.arg2 = nil;
				UIDropDownMenu_AddButton(info);
			end
		end
	elseif ( status == "locked" ) then
		info.text = LEAVE_BATTLEGROUND;
		info.disabled = true;
		UIDropDownMenu_AddButton(info);
	elseif ( status == "active" ) then
		local inArena = IsActiveBattlefieldArena();

		if ( not inArena or GetBattlefieldWinner() ) then
			info.text = TOGGLE_SCOREBOARD;
			info.func = wrapFunc(ToggleWorldStateScoreFrame);
			info.arg1 = nil;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end

		if ( not inArena ) then
			info.text = TOGGLE_BATTLEFIELD_MAP;
			info.func = wrapFunc(ToggleBattlefieldMinimap);
			info.arg1 = nil;
			info.arg2 = nil;
			UIDropDownMenu_AddButton(info);
		end

		if ( inArena ) then
			info.text = LEAVE_ARENA;
			info.func = wrapFunc(LeaveBattlefield);
			info.arg1 = nil;
			info.arg2 = nil;
		else
			info.text = LEAVE_BATTLEGROUND;
			if not GetBattlefieldWinner() then
				info.func = wrapFunc(SendServerMessage);
				info.arg1 = "ACMSG_BG_DESERTION_REQUEST";
				info.arg2 = nil;
			else
				info.func = wrapFunc(LeaveBattlefield);
				info.arg1 = nil;
				info.arg2 = nil;
			end
		end

		UIDropDownMenu_AddButton(info);
	end

	return shownHearthAndRes;
end

function QueueStatusDropDown_AddLFGButtons()
	local info = UIDropDownMenu_CreateInfo();

	local mode, submode = GetLFGMode();

	local name = LOOKING_FOR_DUNGEON;
	if ( mode == "lfgparty" or mode == "abandonedInDungeon" ) then
		name = "|cff19ff19"..name.."|r";
	end
	info.text = name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false;
	info.isTitle = nil;
	info.leftPadding = 10;

	if ( IsPartyLFG() ) then
		local addButton = false;
		if ( IsInLFGDungeon() ) then
			info.text = TELEPORT_OUT_OF_DUNGEON;
			info.func = wrapFunc(LFGTeleport);
			info.arg1 = true;
			addButton = true;
		elseif ( ( GetNumPartyMembers() > 0 ) or ( GetNumRaidMembers() > 0 ) ) then
			info.text = TELEPORT_TO_DUNGEON;
			info.func = wrapFunc(LFGTeleport);
			info.arg1 = false;
			addButton = true;
		end
		if ( addButton ) then
			UIDropDownMenu_AddButton(info);
		end
	end

	if ( mode == "proposal" and submode == "unaccepted" ) then
		info.text = ENTER_DUNGEON;
		info.func = wrapFunc(AcceptProposal);
		UIDropDownMenu_AddButton(info);

		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(RejectProposal);
		UIDropDownMenu_AddButton(info);
	elseif ( mode == "queued" ) then
		info.text = LEAVE_QUEUE;
		info.func = wrapFunc(LeaveLFG);
		info.disabled = (submode == "unempowered");
		UIDropDownMenu_AddButton(info);
	elseif ( mode == "listed" ) then
		if ( ( GetNumPartyMembers() > 0 ) or ( GetNumRaidMembers() > 0 ) ) then
			info.text = UNLIST_MY_GROUP;
		else
			info.text = UNLIST_ME;
		end
		info.func = wrapFunc(LeaveLFG);
		info.disabled = (submode == "unempowered");
		UIDropDownMenu_AddButton(info);
	end
end

----------------------------------------------
-------QueueStatus Utility Functions----------
----------------------------------------------
function QueueStatus_InActiveBattlefield()
	for i=1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i);
		if ( status == "active" ) then
			local canShowScoreboard = false;
			local inArena = IsActiveBattlefieldArena();
			if not inArena or GetBattlefieldWinner() then
				canShowScoreboard = true;
			end
			return true, canShowScoreboard;
		end
	end
end

function QueueStatus_IsActiveQueue()
	local mode = GetLFGMode()
	if mode and (mode == "proposal" or mode == "rolecheck" or mode == "lfgparty" or mode == "abandonedInDungeon") then
		return QueueStatusSuspendType.LFG
	end

	for index = 1, C_BattlefieldStatusManager:GetMaxID() do
		local status = C_BattlefieldStatusManager:GetStatus(index)
		if status and (status == "confirm" or status == "active") then
			return QueueStatusSuspendType.Battleground, index
		end
	end

	for i = 1, MAX_WORLD_PVP_QUEUES do
		local status = GetWorldPVPQueueStatus(i);
		if status and (status == "confirm") then
			return QueueStatusSuspendType.WorldPVP, i
		end

		status = GetBFQueueStatus(i);
		if status and (status == "confirm" or status == "active") then
			return QueueStatusSuspendType.WorldPVP, i
		end
	end
end

function QueueStatus_LeaveAllQueues()
	local mode = GetLFGMode();
	if mode == "queued" then
		LeaveLFG();
	end

	for index = 1, C_BattlefieldStatusManager:GetMaxID() do
		local status = C_BattlefieldStatusManager:GetStatus(index);
		if status and status == "queued" then
			AcceptBattlefieldPort(index);
		end
	end

	for i = 1, MAX_WORLD_PVP_QUEUES do
		local status = GetWorldPVPQueueStatus(i);
		if status and status == "queued" then
			BattlefieldMgrExitRequest(i);
		end
	end
end