E_TOAST_CATEGORY = Enum.CreateMirror({
	INTERFACE_HANDLED = -1,
	DEFAULT = 0,
	FRIENDS = 1,
	HEAD_HUNTING = 2,
	BATTLE_PASS = 3,
	QUEUE = 4,
	AUCTION_HOUSE = 5,
	CALL_OF_ADVENTURE = 6,
	MISC = 7,
	VOTE_KICK = 8,
	BATTLE_PASS_QUEST = 9,
	RAID = 10,
	GUILD_INVITE = 11,
})

E_TOAST_DATA = {
	[E_TOAST_CATEGORY.INTERFACE_HANDLED]	= { allowCustomEvent = true, },
	[E_TOAST_CATEGORY.DEFAULT]				= { sound = SOUNDKIT.UI_BNET_TOAST },
	[E_TOAST_CATEGORY.FRIENDS]				= { sound = SOUNDKIT.UI_BNET_TOAST,				cvar = "C_CVAR_SOCIAL_TOAST_SOUND" },
	[E_TOAST_CATEGORY.HEAD_HUNTING]			= { sound = "UI_PetBattles_InitiateBattle",		cvar = "C_CVAR_HEAD_HUNTING_TOAST_SOUND" },
	[E_TOAST_CATEGORY.BATTLE_PASS]			= { sound = "UI_FightClub_Start",				cvar = "C_CVAR_BATTLE_PASS_TOAST_SOUND" },
	[E_TOAST_CATEGORY.BATTLE_PASS_QUEST]	= { sound = "UI_FightClub_Start",				cvar = "C_CVAR_BATTLE_PASS_TOAST_SOUND", allowCustomEvent = true },
	[E_TOAST_CATEGORY.QUEUE]				= { sound = "UI_GroupFinderReceiveApplication",	cvar = "C_CVAR_QUEUE_TOAST_SOUND" },
	[E_TOAST_CATEGORY.AUCTION_HOUSE]		= { sound = "UI_DigsiteCompletion_Toast",		cvar = "C_CVAR_AUCTION_HOUSE_TOAST_SOUND" },
	[E_TOAST_CATEGORY.CALL_OF_ADVENTURE]	= { sound = "UI_CallOfAdventure_Toast",			cvar = "C_CVAR_CALL_OF_ADVENTURE_TOAST_SOUND" },
	[E_TOAST_CATEGORY.MISC]					= { sound = "UI_Misc_Toast",					cvar = "C_CVAR_MISC_TOAST_SOUND" },
	[E_TOAST_CATEGORY.VOTE_KICK]			= { sound = "ReadyCheck",						forced = true, allowCustomEvent = true },
	[E_TOAST_CATEGORY.RAID]					= { sound = SOUNDKIT.UI_BNET_TOAST,				forced = true, },
	[E_TOAST_CATEGORY.GUILD_INVITE]			= { sound = "LevelUp",							forced = true, },
}

local CATEGORY_BLOCKING_CVARS = {
	[E_TOAST_CATEGORY.FRIENDS]				= "C_CVAR_SHOW_SOCIAL_TOAST",
	[E_TOAST_CATEGORY.BATTLE_PASS]			= "C_CVAR_SHOW_BATTLE_PASS_TOAST",
	[E_TOAST_CATEGORY.BATTLE_PASS_QUEST]	= "C_CVAR_SHOW_BATTLE_PASS_TOAST",
	[E_TOAST_CATEGORY.AUCTION_HOUSE]		= "C_CVAR_SHOW_AUCTION_HOUSE_TOAST",
	[E_TOAST_CATEGORY.CALL_OF_ADVENTURE]	= "C_CVAR_SHOW_CALL_OF_ADVENTURE_TOAST",
	[E_TOAST_CATEGORY.MISC]					= "C_CVAR_SHOW_MISC_TOAST",
}

SocialToastMixin = {}

function SocialToastMixin:OnHide()
    local parent = self:GetParent()
    parent.toastPool:Release(self)

	local activeIndex = tIndexOf(parent.activeToasts, self)
	if activeIndex then
		table.remove(parent.activeToasts, activeIndex)

		local toastFrame = parent.activeToasts[activeIndex]
		if toastFrame then
			toastFrame:AdjustAnchors(activeIndex - 1)
		end
	end

    C_Timer:After(0.1, function () parent:CheckShowToast() end)
end

function SocialToastMixin:OnEnter()
    AlertFrame_PauseOutAnimation(self)
end

function SocialToastMixin:OnLeave()
    AlertFrame_ResumeOutAnimation(self)
end

function SocialToastMixin:OnClick(button)
	if button ~= "LeftButton" then
		return
	end

	if self.toastID == 70 then
		if not C_Unit.IsNeutral("player") and IsInGuild() then
			ShowUIPanel(GuildFrame)
			GuildFrame_TabClicked(4)
			GuildInfoFrameTab3:Click()
		end
	elseif self.toastID == 71 then
		if not C_Unit.IsNeutral("player") and not IsInGuild() then
			ShowUIPanel(LookingForGuildFrame)
			if LookingForGuildFrame.PendingTab:IsEnabled() == 1 then
				LookingForGuildFrame.PendingTab:Click()
			end
		end
	elseif self.categoryID == E_TOAST_CATEGORY.FRIENDS then
		if not FriendsFrame:IsShown() then
			ToggleFriendsFrame(1);
		end
	elseif self.categoryID == E_TOAST_CATEGORY.HEAD_HUNTING then
		if not HeadHuntingFrame:IsShown() then
			ShowUIPanel(HeadHuntingFrame)
		end
	elseif self.categoryID == E_TOAST_CATEGORY.BATTLE_PASS then
		if C_BattlePass.IsEnabled() then
			BattlePassFrame:ShowPage(1)
		end
	elseif self.categoryID == E_TOAST_CATEGORY.BATTLE_PASS_QUEST then
		if C_BattlePass.IsEnabled() then
			BattlePassFrame:ShowPage(2)
		end
	elseif self.categoryID == E_TOAST_CATEGORY.VOTE_KICK then
		local voteInProgress, didVote, myVote, targetName, totalVotes, bootVotes, timeLeft, reason = GetLFGBootProposal()
		if voteInProgress and not didVote and targetName then
			local inInstance, instanceType = IsInInstance()
			local targetNameColored = GetClassColoredTextForUnit(targetName, targetName)
			if instanceType == "pvp" then
				if C_Service.IsBattlegroundKickEnabled() then
					StaticPopup_Show("VOTE_BOOT_PLAYER_PVP", targetNameColored, reason, targetName)
				end
			end
		end
	end
end

function SocialToastMixin:AdjustAnchors(index)
    self:ClearAllPoints()

    if index == 0 then
        self:SetPoint("BOTTOM", self:GetParent(), 0, 0)
    else
		self:SetPoint("BOTTOM", self:GetParent().activeToasts[index], "TOP", 0, 10)
    end
end

SocialToastSystemMixin = {}

function SocialToastSystemMixin:OnLoad()
    self:RegisterEventListener()
	self:RegisterCustomEvent("SHOW_TOAST")

	self.activeToasts = {}
	self.queue = {}

	self.toastPool = CreateFramePool("Button", self, "SocialToastTemplate", function(framePool, frame)
		frame.toastID = nil
		frame.categoryID = nil
	end)

    hooksecurefunc("FCF_SetButtonSide", function() self:UpdatePosition() end)
end

function SocialToastSystemMixin:OnEvent(event, ...)
	if event == "SHOW_TOAST" then
		local categoryID, toastID, iconSource, title, text, sound = ...

		if E_TOAST_DATA[categoryID] and E_TOAST_DATA[categoryID].allowCustomEvent and not self:IsCategoryBlocked(categoryID) then
			self:AddToast({
				toastID		= toastID,
				categoryID	= categoryID,
				titleText	= title,
				bodyText	= text,
				iconSource	= self:GetIconSource(toastID, iconSource),
				sound		= sound,
			})
		end
	end
end

function SocialToastSystemMixin:OnShow()
    self:UpdatePosition()
end

function SocialToastSystemMixin:UpdatePosition()
    local positionSettings = C_CVar:GetValue("C_CVAR_TOAST_POSITION")

    if positionSettings then
        self:ClearAndSetPoint(positionSettings.point, positionSettings.xOffset * GetScreenWidth(), positionSettings.yOffset * GetScreenHeight())
        self:SetUserPlaced(true)
        return
    end

    if DEFAULT_CHAT_FRAME.buttonFrame and (DEFAULT_CHAT_FRAME.buttonFrame:IsShown() and DEFAULT_CHAT_FRAME.buttonFrame:IsVisible()) then
        if DEFAULT_CHAT_FRAME.buttonSide == "left" then
            self:ClearAndSetPoint("BOTTOMLEFT", DEFAULT_CHAT_FRAME.buttonFrame, "TOPLEFT", 0, 44)
        else
            self:ClearAndSetPoint("BOTTOMRIGHT", DEFAULT_CHAT_FRAME.buttonFrame, "TOPRIGHT", 0, 44)
        end
    else
        if DEFAULT_CHAT_FRAME then
            self:ClearAndSetPoint("BOTTOMLEFT", DEFAULT_CHAT_FRAME, "TOPLEFT", 0, 44)
        else
            self:ClearAndSetPoint("TOP", 0, -140)
        end
    end

    self:SetUserPlaced(false)
end

function SocialToastSystemMixin:ShowToast(toastFrame)
    if not toastFrame then
        toastFrame = self.toastPool:Acquire()

		local numToasts = #self.activeToasts
		table.insert(self.activeToasts, toastFrame)
        toastFrame:AdjustAnchors(numToasts)
    end

	local toastInfo = table.remove(self.queue, 1)

	toastFrame.TitleText:SetText(toastInfo.titleText)
	toastFrame.BodyText:SetText(toastInfo.bodyText)

	if type(toastInfo.iconSource) == "number" then
		toastFrame.Icon:SetTexture(GetItemIcon(toastInfo.iconSource) or QUESTION_MARK_ICON)
	else
		toastFrame.Icon:SetTexture(toastInfo.iconSource or QUESTION_MARK_ICON)
	end

	toastFrame.toastID = toastInfo.toastID
	toastFrame.categoryID = toastInfo.categoryID

	if E_TOAST_DATA[toastInfo.categoryID] then
		if toastInfo.categoryID == E_TOAST_CATEGORY.INTERFACE_HANDLED then
			if toastInfo.sound then
				PlaySound(toastInfo.sound)
			end
		elseif E_TOAST_DATA[toastInfo.categoryID].forced
		or (C_CVar:GetValue("C_CVAR_PLAY_TOAST_SOUND") ~= "0" and C_CVar:GetValue(E_TOAST_DATA[toastInfo.categoryID].cvar) ~= "0")
		then
			PlaySound(E_TOAST_DATA[toastInfo.categoryID].sound or E_TOAST_DATA[E_TOAST_CATEGORY.DEFAULT].sound)
		end
	else
		PlaySound(E_TOAST_DATA[E_TOAST_CATEGORY.DEFAULT].sound)
	end

	toastFrame:Show()	-- force recalculate text rect
	toastFrame:SetHeight(math.max(50, 29 + toastFrame.TitleText:GetHeight() + toastFrame.BodyText:GetHeight()))

    AlertFrame_ShowNewAlert(toastFrame)
end

function SocialToastSystemMixin:RemoveToast(targetToastInfo)
	for index, toastInfo in ipairs(self.queue) do
		if toastInfo == targetToastInfo
		or (toastInfo.categoryID == targetToastInfo.categoryID and targetToastInfo.categoryID == E_TOAST_CATEGORY.QUEUE)
		then
			table.remove(self.queue, index)
			return
		end
	end
end

function SocialToastSystemMixin:AddToast(toastInfo)
	self:RemoveToast(toastInfo)
	table.insert(self.queue, toastInfo)

    if not self:IsShown() then
        self:Show()
    end

	if toastInfo.categoryID == E_TOAST_CATEGORY.QUEUE then
		for _, toastFrame in ipairs(self.activeToasts) do
			if toastFrame.categoryID == toastInfo.categoryID then
                self:ShowToast(toastFrame)
                return
            end
        end
    end

	if #self.activeToasts < C_CVar:GetValue("C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS") then
		self:ShowToast()
	end
end

function SocialToastSystemMixin:CheckShowToast()
	if #self.queue > 0 and #self.activeToasts < C_CVar:GetValue("C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS") then
		self:ShowToast()
	elseif #self.activeToasts == 0 and not self.MoveFrame:IsShown() then
		self:Hide()
	end
end

function SocialToastSystemMixin:SavedPosition()
    local centerX = self:GetLeft() + self:GetWidth() / 2
    local centerY = self:GetBottom() + self:GetHeight() / 2

    local horizPoint, vertPoint
    local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
    local xOffset, yOffset
    if ( centerX > screenWidth / 2 ) then
        horizPoint = "RIGHT"
        xOffset = (self:GetRight() - screenWidth)/screenWidth
    else
        horizPoint = "LEFT"
        xOffset = self:GetLeft()/screenWidth
    end

    if ( centerY > screenHeight / 2 ) then
        vertPoint = "TOP"
        yOffset = (self:GetTop() - screenHeight)/screenHeight
    else
        vertPoint = "BOTTOM"
        yOffset = self:GetBottom()/screenHeight
    end

    C_CVar:SetValue("C_CVAR_TOAST_POSITION", {
        point   = vertPoint..horizPoint,
        xOffset = xOffset,
        yOffset = yOffset
    })
end

function SocialToastSystemMixin:ClearPosition()
    C_CVar:SetValue("C_CVAR_TOAST_POSITION", nil)
end

local TOAST_ITEM_ICON = {
	[67] = true,
	[68] = true,
}

local TOAST_FACTION_ICON = {
	[19] = true,
}

local TOAST_TYPE_ICONS = {
	[1] = "wow_token01",
	[2] = "wow_token02",
	[3] = "warrior_skullbanner",
	[4] = "battlepas_64x64",
	[5] = "spell_deathknight_classicon",
	[6] = "inv_misc_coin_01",
	[7] = "inv_belt_mail_vrykuldragonrider_b_01",
	[8] = "ability_rogue_disguise",
	[9] = "spell_nature_web",
	[10] = "achievement_bg_defendxtowers_av",
	[11] = "ability_warlock_demonicpower",
	[12] = "achievement_dungeon_icecrown_icecrownentrance",
	[13] = "achievement_featsofstrength_gladiator_08",
	[14] = "achievement_featsofstrength_gladiator_09",
	[15] = "achievement_dungeon_auchindoun",
	[16] = "achievement_zone_zangarmarsh",
	[17] = "achievement_zone_hellfirepeninsula_01",
	[18] = "achievement_zone_easternplaguelands",
	[19] = "pvpcurrency-honor-",
	[20] = "achievement_quests_completed_vashjir",
	[21] = "item_shop_giftbox01",
	[22] = "ability_warrior_endlessrage",
	[23] = "inv_engineering_failure detection pylon",
}

local TOAST_ICON_ID = {
	[1] = 1,
	[2] = 2,
	[3] = 3, [4] = 3, [5] = 3, [6] = 3, [7] = 3, [8] = 3, [9] = 3, [10] = 3, [11] = 3, [12] = 3, [13] = 3,
	[14] = 4, [15] = 4, [16] = 4, [17] = 4,
	[18] = 5,
	[21] = 6, [22] = 6, [23] = 6,
	[24] = 7, [25] = 7,
	[26] = 8,
	[27] = 9,
	[28] = 10, [29] = 10, [30] = 10,
	[31] = 11, [32] = 11, [33] = 11,
	[34] = 12, [35] = 12, [36] = 12,
	[37] = 13, [38] = 13, [39] = 13, [55] = 13,
	[40] = 14, [41] = 14, [42] = 14, [56] = 14,
	[43] = 15, [44] = 15, [45] = 15,
	[46] = 16, [47] = 16, [48] = 16,
	[49] = 17, [50] = 17, [51] = 17,
	[52] = 18, [53] = 18, [54] = 18,
	[57] = 19,
	[58] = 20, [59] = 20,
	[60] = 21, [61] = 21, [62] = 21, [63] = 21,
	[65] = 22,
	[66] = 23,
}

local TOAST_TITLE_ID = {
	[28] = 28, [29] = 28, [30] = 28,
	[31] = 29, [32] = 29, [33] = 29,
	[34] = 30, [35] = 30, [36] = 30,
	[37] = 31, [38] = 31, [39] = 31,
	[40] = 32, [41] = 32, [42] = 32,
	[43] = 33, [44] = 33, [45] = 33,
	[46] = 34, [47] = 34, [48] = 34,
	[49] = 35, [50] = 35, [51] = 35,
	[52] = 36, [53] = 36, [54] = 36,
	[58] = 58, [59] = 58,
}

local TOAST_TEXT_ID = {
--	[28] = 28, [29] = 29, [30] = 30,
	[31] = 28, [32] = 29, [33] = 30,
	[34] = 28, [35] = 29, [36] = 30,
	[37] = 28, [38] = 29, [39] = 30,
	[40] = 28, [41] = 29, [42] = 30,
	[43] = 28, [44] = 29, [45] = 30,
	[46] = 28, [47] = 29, [48] = 30,
	[49] = 28, [50] = 29, [51] = 30,
	[52] = 28, [53] = 29, [54] = 30,
}

function SocialToastSystemMixin:IsCategoryBlocked(categoryID)
	if categoryID == E_TOAST_CATEGORY.INTERFACE_HANDLED then
		return false
	end
	if C_CVar:GetValue("C_CVAR_SHOW_TOASTS") ~= "1"
	or (CATEGORY_BLOCKING_CVARS[categoryID] and C_CVar:GetValue(CATEGORY_BLOCKING_CVARS[categoryID]) ~= "1")
	then
		return true
	end
	return false
end

function SocialToastSystemMixin:GetIconSource(toastID, iconSource)
	if not iconSource or iconSource == "" then
		return
	end

	if iconSource == "0" then
		local iconID = TOAST_ICON_ID[toastID] or toastID
		if TOAST_TYPE_ICONS[iconID] then
			if TOAST_FACTION_ICON[iconID] then
				return strconcat([[Interface\Icons\]], TOAST_TYPE_ICONS[iconID], (UnitFactionGroup("player")))
			else
				return strconcat([[Interface\Icons\]], TOAST_TYPE_ICONS[iconID])
			end
		end
	elseif TOAST_ITEM_ICON[toastID] then
		return tonumber(iconSource)
	else
		return strconcat([[Interface\Icons\]], iconSource)
	end
end

function SocialToastSystemMixin:GetTitleText(toastID, ...)
	local titleID = TOAST_TITLE_ID[toastID] or toastID
	if select("#", ...) > 0 then
		return string.format(_G["TOAST_TITLE_"..titleID] or "%s", ...)
	end
	return _G["TOAST_TITLE_"..titleID]
end

function SocialToastSystemMixin:GetBodyText(toastID, ...)
	local textID = TOAST_TEXT_ID[toastID] or toastID
	if select("#", ...) > 0 then
		return string.format(_G["TOAST_BODY_"..textID] or "%s", ...)
	end
	return _G["TOAST_BODY_"..textID]
end

function SocialToastSystemMixin:ASMSG_TOAST(msg)
	local toastID, categoryID, flags, iconSource, numTitleParams, textParams = StringSplitEx("|", msg, 6)

	categoryID = tonumber(categoryID)
	flags = tonumber(flags)

	if flags ~= 1 and self:IsCategoryBlocked(categoryID) then
		return
	end

	toastID = tonumber(toastID)
	numTitleParams = tonumber(numTitleParams) or 0

	local titleID = TOAST_TITLE_ID[toastID] or toastID
	local textID = TOAST_TEXT_ID[toastID] or toastID

	local titleText, bodyText
	if textParams and #textParams > 0 then
		local textParamList = {string.split("|", textParams)}
		local numTextParams = #textParamList - numTitleParams

		if numTitleParams > 0 then
			titleText = string.format(_G["TOAST_TITLE_"..titleID] or "%s", unpack(textParamList, 1, numTitleParams))
		end
		if numTextParams > 0 then
			bodyText = string.format(_G["TOAST_BODY_"..textID] or "%s", unpack(textParamList, numTitleParams + 1, #textParamList))
		end
	end

	self:AddToast({
		toastID		= toastID,
		categoryID	= categoryID,
		titleText	= titleText or _G["TOAST_TITLE_"..titleID] or "",
		bodyText	= bodyText or _G["TOAST_BODY_"..textID] or "",
		iconSource	= self:GetIconSource(toastID, iconSource),
	})
end

SocialToastMoveFrameMixin = {}

function SocialToastMoveFrameMixin:OnLoad()
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
    self:RegisterForDrag("LeftButton")
end

function SocialToastMoveFrameMixin:OnShow()
    if InterfaceOptionsNotificationPanelToggleMove then
        InterfaceOptionsNotificationPanelToggleMove:SetChecked(true)
    end
end

function SocialToastMoveFrameMixin:OnHide()
    if InterfaceOptionsNotificationPanelToggleMove then
        InterfaceOptionsNotificationPanelToggleMove:SetChecked(false)
    end
end

function SocialToastMoveFrameMixin:OnDragStart()
    self:GetParent():StartMoving()
end

function SocialToastMoveFrameMixin:OnDragStop()
    self:GetParent():StopMovingOrSizing()
    self:GetParent():SavedPosition()
end

function SocialToastMoveFrameMixin:OnMouseUp( button )
    if button == "RightButton" then
        self:Hide()
        self:GetParent():Hide()
    end
end