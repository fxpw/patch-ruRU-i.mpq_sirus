E_TOAST_CATEGORY = Enum.CreateMirror({
	UNKNOWN = 0,
	FRIENDS = 1,
	HEAD_HUNTING = 2,
	BATTLE_PASS = 3,
	QUEUE = 4,
	AUCTION_HOUSE = 5,
	CALL_OF_ADVENTURE = 6,
	MISC = 7,
})

E_TOAST_DATA = {
	[E_TOAST_CATEGORY.UNKNOWN]				= { sound = SOUNDKIT.UI_BNET_TOAST },
	[E_TOAST_CATEGORY.FRIENDS]				= { sound = SOUNDKIT.UI_BNET_TOAST,				cvar = "C_CVAR_SOCIAL_TOAST_SOUND" },
	[E_TOAST_CATEGORY.HEAD_HUNTING]			= { sound = "UI_PetBattles_InitiateBattle",		cvar = "C_CVAR_HEAD_HUNTING_TOAST_SOUND" },
	[E_TOAST_CATEGORY.BATTLE_PASS]			= { sound = "UI_FightClub_Start",				cvar = "C_CVAR_BATTLE_PASS_TOAST_SOUND" },
	[E_TOAST_CATEGORY.QUEUE]				= { sound = "UI_GroupFinderReceiveApplication",	cvar = "C_CVAR_QUEUE_TOAST_SOUND" },
	[E_TOAST_CATEGORY.AUCTION_HOUSE]		= { sound = "UI_DigsiteCompletion_Toast",		cvar = "C_CVAR_AUCTION_HOUSE_TOAST_SOUND" },
	[E_TOAST_CATEGORY.CALL_OF_ADVENTURE]	= { sound = "UI_CallOfAdventure_Toast",			cvar = "C_CVAR_CALL_OF_ADVENTURE_TOAST_SOUND" },
	[E_TOAST_CATEGORY.MISC]					= { sound = "UI_Misc_Toast",					cvar = "C_CVAR_MISC_TOAST_SOUND" },
}

DefaultAnimOutMixin = {}

function DefaultAnimOutMixin:OnFinished()
    self:GetParent():Hide()
end

SocialToastCloseButtonMixin = {}

function SocialToastCloseButtonMixin:OnEnter()
    self:GetParent():OnEnter()
end

function SocialToastCloseButtonMixin:OnLeave()
    self:GetParent():OnLeave()
end

function SocialToastCloseButtonMixin:OnClick()
    self:GetParent():Hide()
end

SocialToastMixin = {}

function SocialToastMixin:OnHide()
    local parent = self:GetParent()
    parent.toastPool:Release(self)

    local removedIndex
    for index, toastFrame in ipairs(parent.toastFrames) do
        if toastFrame == self then
            table.remove(parent.toastFrames, index)
            removedIndex = index
            break
        end
    end

    if removedIndex then
        local toastFrame = parent.toastFrames[removedIndex]
        if toastFrame then
            toastFrame:AdjustAnchors(removedIndex - 1)
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

	if self.categoryID == E_TOAST_CATEGORY.FRIENDS then
		if not FriendsFrame:IsShown() then
			ToggleFriendsFrame(1);
		end
	elseif self.categoryID == E_TOAST_CATEGORY.HEAD_HUNTING then
		if not HeadHuntingFrame:IsShown() then
			ShowUIPanel(HeadHuntingFrame)
		end
	elseif self.categoryID == E_TOAST_CATEGORY.BATTLE_PASS then
		if PVPQueueFrame.BattlePassToggleButton:IsEnabled() == 1 then
			BattlePassFrame:Show()
		end
	end
end

function SocialToastMixin:AdjustAnchors(index)
    self:ClearAllPoints()

    if index == 0 then
        self:SetPoint("BOTTOM", self:GetParent(), 0, 0)
    else
        self:SetPoint("BOTTOM", self:GetParent().toastFrames[index], "TOP", 0, 10)
    end
end

SocialToastSystemMixin = {}

function SocialToastSystemMixin:OnLoad()
    self:RegisterEventListener()

    self.toastFrames = {}
    self.toastStorage = {}

    local function ToastFrameReset(_, frame)
        frame.categoryID = nil
    end

    self.toastPool = CreateFramePool("Button", self, "SocialToastTemplate", ToastFrameReset)

    hooksecurefunc("FCF_SetButtonSide", function() self:UpdatePosition() end)
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

        local numToasts = #self.toastFrames
        table.insert(self.toastFrames, toastFrame)
        toastFrame:AdjustAnchors(numToasts)
    end

    local toast = table.remove(self.toastStorage, 1)
    local categoryID = toast.categoryID

    toastFrame.TitleText:SetText(toast.toastData.titleText)
    toastFrame.BodyText:SetText(toast.toastData.bodyText)

    local iconSource = toast.toastData.iconSource

    if type(iconSource) == "number" then
		local function setIcon(_, _, _, _, _, _, _, _, _, _, itemTexture)
            toastFrame.Icon:SetTexture(itemTexture)
        end

		local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(iconSource, false, setIcon)

        if itemTexture then
			toastFrame.Icon:SetTexture(itemTexture)
        else
			toastFrame.Icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
        end
    else
		toastFrame.Icon:SetTexture("Interface\\ICONS\\"..iconSource)
    end

    toastFrame.categoryID = categoryID

	if C_CVar:GetValue("C_CVAR_PLAY_TOAST_SOUND") ~= "0" and E_TOAST_DATA[categoryID] then
		if C_CVar:GetValue(E_TOAST_DATA[categoryID].cvar) ~= "0" then
			PlaySound(E_TOAST_DATA[categoryID].sound or E_TOAST_DATA[E_TOAST_CATEGORY.UNKNOWN].sound)
		end
	else
		PlaySound(E_TOAST_DATA[E_TOAST_CATEGORY.UNKNOWN].sound)
	end

	toastFrame:Show()	-- force recalculate text rect
	toastFrame:SetHeight(math.max(50, 29 + toastFrame.TitleText:GetHeight() + toastFrame.BodyText:GetHeight()))

    AlertFrame_ShowNewAlert(toastFrame)
end

function SocialToastSystemMixin:RemoveToast(categoryID, toastData)
    for toastIndex, toast in ipairs(self.toastStorage) do
        if toast.categoryID == categoryID and (categoryID == E_TOAST_CATEGORY.QUEUE or toast.toastData == toastData) then
            table.remove(self.toastStorage, toastIndex)
            return
        end
    end
end

function SocialToastSystemMixin:AddToast( categoryID, toastData )
    self:RemoveToast(categoryID, toastData)
    table.insert(self.toastStorage, { categoryID = categoryID, toastData = toastData })

    if not self:IsShown() then
        self:Show()
    end

    if categoryID == E_TOAST_CATEGORY.QUEUE then
        for _, toastFrame in ipairs(self.toastFrames) do
            if toastFrame.categoryID == categoryID then
                self:ShowToast(toastFrame)
                return
            end
        end
    end

    if #self.toastFrames < C_CVar:GetValue("C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS") then
        self:ShowToast()
    end
end

function SocialToastSystemMixin:CheckShowToast()
    if #self.toastStorage > 0 and #self.toastFrames < C_CVar:GetValue("C_CVAR_NUM_DISPLAY_SOCIAL_TOASTS") then
        self:ShowToast()
    elseif #self.toastFrames == 0 and not self.MoveFrame:IsShown() then
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

local TOAST_MESSAGE_DATA = {
	TEXT_ID				= 1,
	CATEGORY_ID			= 2,
	FLAGS				= 3,
	ICONSOURCE			= 4,
	TITLE_PARAMS_COUNT	= 5,
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

function SocialToastSystemMixin:ASMSG_TOAST( msg )
    local toastData = C_Split(msg, "|")

	local toastID			= tonumber(table.remove(toastData, 1))
    local categoryID        = tonumber(table.remove(toastData, 1))
    local flags             = tonumber(table.remove(toastData, 1))
    local iconSource        = table.remove(toastData, 1)
    local titleParamsCount  = tonumber(table.remove(toastData, 1))

    if flags ~= 1 then
		if C_CVar:GetValue("C_CVAR_SHOW_TOASTS") ~= "1" then
			return
		elseif categoryID == E_TOAST_CATEGORY.FRIENDS then
            if C_CVar:GetValue("C_CVAR_SHOW_SOCIAL_TOAST") ~= "1" then
                return
            end
        elseif categoryID == E_TOAST_CATEGORY.BATTLE_PASS then
            if C_CVar:GetValue("C_CVAR_SHOW_BATTLE_PASS_TOAST") ~= "1" then
                return
            end
        elseif categoryID == E_TOAST_CATEGORY.AUCTION_HOUSE then
            if C_CVar:GetValue("C_CVAR_SHOW_AUCTION_HOUSE_TOAST") ~= "1" then
                return
            end
		elseif categoryID == E_TOAST_CATEGORY.CALL_OF_ADVENTURE then
			if C_CVar:GetValue("C_CVAR_SHOW_CALL_OF_ADVENTURE_TOAST") ~= "1" then
				return
			end
		elseif categoryID == E_TOAST_CATEGORY.MISC then
			if C_CVar:GetValue("C_CVAR_SHOW_MISC_TOAST") ~= "1" then
				return
			end
        end
    end

	local iconID = TOAST_ICON_ID[toastID] or toastID
	local typeID = TOAST_TITLE_ID[toastID] or toastID
	local textID = TOAST_TEXT_ID[toastID] or toastID

	if iconSource == "0" then
		if TOAST_TYPE_ICONS[iconID] then
			if TOAST_FACTION_ICON[iconID] then
				iconSource = strconcat(TOAST_TYPE_ICONS[iconID], (UnitFactionGroup("player")))
			else
				iconSource = TOAST_TYPE_ICONS[iconID]
			end
		else
			iconSource = "INV_Misc_QuestionMark"
		end
	end

    local titleTextParams = {}

    for i = 1, titleParamsCount do
        table.insert(titleTextParams, toastData[i])
    end

    local bodyTextParams = {}

    for i = titleParamsCount + 1, #toastData do
        table.insert(bodyTextParams, toastData[i])
    end

    self:AddToast(categoryID, {
        titleText   = #titleTextParams > 0 and string.format(_G["TOAST_TITLE_"..typeID] or "%s", unpack(titleTextParams)) or _G["TOAST_TITLE_"..typeID],
        bodyText    = #bodyTextParams > 0 and string.format(_G["TOAST_BODY_"..textID] or "%s", unpack(bodyTextParams)) or _G["TOAST_BODY_"..textID],
        iconSource  = iconSource,
        flags       = flags
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