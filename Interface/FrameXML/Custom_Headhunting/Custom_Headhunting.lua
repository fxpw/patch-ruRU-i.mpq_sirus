--	Filename:	Custom_Headhunting.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

UIPanelWindows["HeadHuntingFrame"] = { area = "left", pushable = 0, whileDead = 1, width = 830, xOffset = "15", yOffset = "-10"}
UIPanelWindows["HeadHuntingSetRewardExternalFrame"] = { area = "center",	pushable = 0,	whileDead = 1}

HEADHUNTING_MIN_CONTRACT_PLAYER_KILLS     = 1
HEADHUNTING_MIN_CONTRACT_GUILD_KILLS      = 10
HEADHUNTING_MIN_CONTRACT_GOLD_PER_KILL    = 100
HEADHUNTING_MAX_CONTRACT_GOLD_PER_KILL    = 10000
HEADHUNTING_MAX_CONTRACT_GOLD_TOTAL       = 200000

enum:E_HEADHUNTING_TAB {
    "HOME",
    "ALL_TARGETS",
    "YOU_TARGETS"
}

enum:E_HEADHUNTING_CATEGORY {
    "REWARD_FOR_HEAD",
    "REWARD_FOR_GUILD"
}

enum:E_HEADHUNTING_RESULTS {
    [0] = "OK",
    [-1] = "INVALID_ARGUMENTS",
    [-2] = "CONTRACT_NOT_FOUND",
    [-3] = "NO_CONTRACTS_FOR_TYPE",
    [-4] = "NOT_ENOUGH_MONEY",
    [-5] = "TARGET_NOT_FOUND",
    [-6] = "CONTRACT_ALREADY_EXIST",
    [-7] = "CONTRACT_IS_NOT_ACTIVE",
    [-8] = "SEARCH_NAME_TOO_SHORT",
    [-9] = "SEARCH_INVALID_NAME",
    [-10] = "SEARCH_NO_TARGETS",
    [-11] = "HEADHUNTING_ERROR_TARGET_SELF_OR_SELF_GUILD",
    [-12] = "HEADHUNTING_ERROR_TARGET_WARMODE_PVE",
}

enum:E_HEADHUNTING_ALL_CONTRACTS_PLAYER {
    "GUID",
    "MONEYPERKILL",
    "MONEYINBANK",
    "HASGUILDCONTRACTS",
    "GUILDNAME",
    "NAME",
    "TEAMID",
    "RACE",
    "CLASS",
    "GENDER",
    "ONLINE"
}

enum:E_HEADHUNTING_ALL_CONTRACTS_GUILD {
    "GUID",
    "MONEYPERKILL",
    "MONEYINBANK",
    "NAME",
    "TEAMID",
    "STYLE",
    "COLOR",
    "BORDERSTYLE",
    "BORDERCOLOR",
    "BACKGROUNDCOLOR",
}

enum:E_HEADHUNTING_PLAYER_CONTRACTS_PLAYER {
    "GUID",
    "MONEYPERKILL",
    "TOTALKILLS",
    "NAME",
    "TEAMID",
    "RACE",
    "CLASS",
    "GENDER",
    "CURRENTKILLS",
    "TIMELEFT"
}

enum:E_HEADHUNTING_PLAYER_CONTRACTS_GUILD {
    "GUID",
    "MONEYPERKILL",
    "TOTALKILLS",
    "NAME",
    "TEAMID",
    "STYLE",
    "COLOR",
    "BORDERSTYLE",
    "BORDERCOLOR",
    "BACKGROUNDCOLOR",
    "CURRENTKILLS",
    "TIMELEFT"
}

enum:E_HEADHUNTING_SEARCH_PLAYER {
    "GUID",
    "NAME",
    "TEAMID",
    "RACE",
    "CLASS",
    "GENDER",
}

enum:E_HEADHUNTING_SEARCH_GUILD {
    "GUID",
    "NAME",
    "TEAMID",
    "STYLE",
    "COLOR",
    "BORDERSTYLE",
    "BORDERCOLOR",
    "BACKGROUNDCOLOR",
}

enum:E_HEADHUNTING_NOTIFICATIONS_INFO {
    "FLAG",
    "STATUS"
}

enum:E_HEADHUNTING_SORT_ORDER {
    [0] = "NAME",
    [1] = "HAS_GUILD_CONTRACTS",
    [2] = "CLASS",
    [3] = "FACTION",
    [4] = "MONEY_PER_KILL",
    [5] = "MONEY_BANK",
    [6] = "ONLINE"
}

enum:E_HEADHUNTING_CONTRACT_DETAILS {
    "MONEYPERKILL",
    "KILLSLEFT",
    "TIMELEFT"
}

enum:E_HEADHUNTING_SUMMARY_INFO {
    "CONTRACTCOUNT",
    "TOTALMONEY"
}

enum:E_HEADHUNTING_CONTRACT_ON_PLAYER {
    "GUID",
    "MONEYPERKILL",
    "MONEYINBANK",
    "HASGUILDCONTRACTS",
}

enum:E_HEADHUNTING_CONTRACT_ON_PLAYER_GUILD {
    "GUID",
    "MONEYPERKILL",
    "MONEYINBANK",
}

enum:HEADHUNTING_FILTER_VALUE {
    [0x01] = "ALL_ONLINE",
    [0x02] = "ONLY_ONLINE",
    [0x04] = "ONLY_OFFLINE",

    [0x08] = "WITH_AND_WITHOUT_GUILD_CONTRACTS",
    [0x10] = "ONLY_GUILD_CONTRACTS",
    [0x20] = "ONLY_WITHOUT_GUILD_CONTRACTS"
}

HeadHuntingSortOrderState = tInvert({
    [1] = "PrimarySorted",
    [0] = "PrimaryReversed",
})

StaticPopupDialogs["HEADHUNTING_OKAY"] = {
    text = "%s",
    button1 = OKAY,
    button2 = nil,
    OnAccept = function()
    end,
    OnCancel = function()
    end,
    timeout = 0,
}

StaticPopupDialogs["HEADHUNTING_REMOVE_CONTRACT"] = {
    text = HEADHUNTING_REMOVE_CONTRACT,
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(_, message)
        SendServerMessage("ACMSG_HEADHUNTING_CONTRACT_CANCEL", message)
        HeadHuntingFrame:RequestContracts()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
};

HeadHuntingMixin = {}

function HeadHuntingMixin:OnLoad()
    self:RegisterEventListener()

    self.panels = {
        [E_HEADHUNTING_TAB.HOME] = {
            name = "HomePanel",
            navBarData = {
                name = HEADHUNTING_HOME,
                OnClick = function()
                    self:SelectedTab(E_HEADHUNTING_TAB.HOME)
                end,
            }
        },
        [E_HEADHUNTING_TAB.ALL_TARGETS] = {
            name = "AllTargetsPanel",
            navBarData = {
                name = HEADHUNTING_TARGETS,
                OnClick = function()
                    self:SelectedTab(E_HEADHUNTING_TAB.ALL_TARGETS)
                end,
            }
        },
        [E_HEADHUNTING_TAB.YOU_TARGETS] = {
            name = "YouTargetsPanel",
            navBarData = {
                name = HEADHUNTING_YOU_TARGETS,
                OnClick = function()
                    self:SelectedTab(E_HEADHUNTING_TAB.YOU_TARGETS)
                end,
            }
        },
    }

    self.categoryNavBarLabel    = {HEADHUNTING_REWARD_FOR_HEADS, HEADHUNTING_REWARD_FOR_GUILDS}
    self.columnButtons          = {}
    self.sortData               = {}

    self.TitleText:SetText(HEADHUNTING)
    SetPortraitToTexture(self.portrait,"Interface\\ICONS\\warrior_skullbanner")

    NavBar_Initialize(self.navBar, "NavButtonTemplate", self.panels[1].navBarData, self.navBar.home, self.navBar.overflow)

    self.tab1:SetFrameLevel(1)
    self.tab2:SetFrameLevel(1)

    PanelTemplates_SetNumTabs(self, 2)
    self.maxTabWidth = (self:GetWidth() - 19) / 2

    self:SetFilterFlags(bit.bor(HEADHUNTING_FILTER_VALUE.ALL_ONLINE, HEADHUNTING_FILTER_VALUE.WITH_AND_WITHOUT_GUILD_CONTRACTS))

    self:SelectedTab(E_HEADHUNTING_TAB.HOME)
    self:SetSelectedCategory(E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD)
end

function HeadHuntingMixin:OnShow()
    PanelTemplates_SetTab(self, 2)

    if HeadHuntingSetRewardExternalFrame and HeadHuntingSetRewardExternalFrame:IsShown() then
        HeadHuntingSetRewardExternalFrame:Hide()
    end
end

function HeadHuntingMixin:OnHide()
    self.Container.YouTargetsPanel.SetRewardFrame:Hide()
    self:CloaseAllPopup()
    StaticPopup_Hide("HEADHUNTING_REMOVE_CONTRACT")
end

function HeadHuntingMixin:SetFilterFlags( flags )
    self.filterFlags = flags
end

function HeadHuntingMixin:GetFilterFlags()
    return self.filterFlags
end

function HeadHuntingMixin:SelectedTab( tabID )
    self:ClearSortData()

    self.topTabs[tabID]:Click()
    self:UpdateNavBar()
end

function HeadHuntingMixin:SetSelectedTab( tabID )
    self.selectedTopTab = tabID

    self:ClearSortData()

    for index, panelData in pairs(self.panels) do
        self.Container[panelData.name]:SetShown(index == tabID)
    end

    self:UpdateContent()
    self:UpdateNavBar()
end

function HeadHuntingMixin:GetSelectedTab()
    return self.selectedTopTab
end

function HeadHuntingMixin:SelectedCategory( categoryID, onlyUpdate )
    self:SetSelectedCategory(categoryID)

    self:UpdateContent(onlyUpdate)
    self:UpdateNavBar()

    self:ShowError(nil)
end

function HeadHuntingMixin:SetSelectedCategory( categoryID )
    self.selectedCategory = categoryID
end

function HeadHuntingMixin:GetSelectedCategory()
    return self.selectedCategory or 1
end

function HeadHuntingMixin:SetFilterSearchName( name )
    self.filterSearchName = name
end

function HeadHuntingMixin:GetFilterSearchName()
    return self.filterSearchName
end

function HeadHuntingMixin:RequestContractsList()
    local selectedCategory = self:GetSelectedCategory()

    local sortOrder         = self:GetSortOrder() or E_HEADHUNTING_SORT_ORDER.MONEY_PER_KILL
    local sortOrderState    = self:GetSortOrderState() or HeadHuntingSortOrderState.PrimarySorted
    local filterFlags       = self:GetFilterFlags()
    local serachName        = self:GetFilterSearchName()

    C_CacheInstance:Set("ASMSG_HEADHUNTING_CONTRACTS_LIST", {})
    self:SendServerRequest("ACMSG_HEADHUNTING_CONTRACTS_LIST", string.format("%s,%s,%s,%s,%s", selectedCategory - 1, sortOrder, sortOrderState, filterFlags, serachName or ""))
end

function HeadHuntingMixin:RequestPlayerContractsList()
    local selectedCategory = self:GetSelectedCategory()

    C_CacheInstance:Set("ASMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST", {})
    self:SendServerRequest("ACMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST", selectedCategory - 1)
end

function HeadHuntingMixin:RequestContracts()
    local selectedTab = self:GetSelectedTab()

    self:SetErrorID(nil)

    if selectedTab == E_HEADHUNTING_TAB.ALL_TARGETS then
        self:RequestContractsList()
    elseif selectedTab == E_HEADHUNTING_TAB.YOU_TARGETS then
        self:RequestPlayerContractsList()
    end
end

function HeadHuntingMixin:UpdateContent( onlyUpdate, dontUpdateColumns )
    local selectedTab = self:GetSelectedTab()

    if selectedTab ~= E_HEADHUNTING_TAB.HOME then
        if HeadHuntingSetRewardExternalFrame and HeadHuntingSetRewardExternalFrame:IsShown() then
            HeadHuntingSetRewardExternalFrame.CentralContainer.ScrollFrame:UpdateButtons()
            return
        end

        if not dontUpdateColumns then
            self.Container[self.panels[selectedTab].name]:UpdateColumns()
        end

        if self.Container[self.panels[selectedTab].name].ContractOnPlayer then
            local selectedCategory = self:GetSelectedCategory()
            local data = C_CacheInstance:Get("ASMSG_HEADHUNTING_CONTRACTS_ON_PLAYER", {})

            self.Container[self.panels[selectedTab].name].ContractOnPlayer:ToggleContractContent(not data[selectedCategory])
        end

        self.Container[self.panels[selectedTab].name].ScrollFrame:UpdateButtons()

        if self.Container[self.panels[selectedTab].name].SetRewardFrame then
            if not onlyUpdate then
                self.Container[self.panels[selectedTab].name].SetRewardFrame:ClearData()
            end

            self.Container[self.panels[selectedTab].name].SetRewardFrame.SearchFrame:UpdateContent()
            self.Container[self.panels[selectedTab].name].SetRewardFrame.HelpBoxFrame:UpdateContent()
            self.Container[self.panels[selectedTab].name].SetRewardFrame.CentralContainer.ScrollFrame:UpdateButtons()
        end

        if not onlyUpdate then
            self:RequestContracts()
        end
    end
end

function HeadHuntingMixin:ShowLoading()
    if self.loadingTimer then
        self.loadingTimer:Cancel()
        self.loadingTimer = nil
    end

    self.loadingTimer = C_Timer:NewTicker(0.300, function()
        local selectedTab = self:GetSelectedTab()
        local panel = self.Container[self.panels[selectedTab].name]

        panel.ScrollFrame.Spinner:Show()

        if panel.SetRewardFrame then
            panel.SetRewardButton:Disable()

            panel.SetRewardFrame.CloseButton:Disable()
            panel.SetRewardFrame.CentralContainer.ScrollFrame.Spinner:Show()
            panel.SetRewardFrame.SearchFrame.SearchButton:SetButtonState(true)
            panel.SetRewardFrame.SearchFrame.SearchBox.clearButton:Disable()
            panel.SetRewardFrame.SetRewardButton:SetButtonState(true)
        end

        if panel.DetailsFrame then
            panel.DetailsFrame.Container.NotifyWhenKilling:Disable()
            panel.DetailsFrame.Container.NotifyWhenComplete:Disable()
            panel.DetailsFrame.RemoveContractButton:Disable()
        end

        for _, tab in pairs(self.topTabs) do
            tab:SetButtonState(true)
        end

        for _, columnButton in pairs(self.columnButtons) do
            columnButton:SetButtonState(true)
        end

        self.isLoading = true
        self:UpdateNavBar()
    end, 1)

    self:ShowError(nil)
end

function HeadHuntingMixin:HideLoading()
    if self.loadingTimer then
        self.loadingTimer:Cancel()
        self.loadingTimer = nil

        if not self.isLoading then
            return
        end
    end

    local selectedTab = self:GetSelectedTab()
    local panel = self.Container[self.panels[selectedTab].name]

    if panel.ScrollFrame then
        panel.ScrollFrame.Spinner:Hide()
    end

    if panel.SetRewardFrame then
        panel.SetRewardButton:Enable()

        panel.SetRewardFrame.CloseButton:Enable()
        panel.SetRewardFrame.CentralContainer.ScrollFrame.Spinner:Hide()
        panel.SetRewardFrame.SearchFrame.SearchButton:SetButtonState(false)
        panel.SetRewardFrame.SearchFrame.SearchBox.clearButton:Enable()
        panel.SetRewardFrame.SetRewardButton:SetButtonState(false)
    end

    if panel.DetailsFrame then
        panel.DetailsFrame.Container.NotifyWhenKilling:Enable()
        panel.DetailsFrame.Container.NotifyWhenComplete:Enable()
        panel.DetailsFrame.RemoveContractButton:Enable()
    end

    for _, tab in pairs(self.topTabs) do
        tab:SetButtonState(false)
    end

    for _, columnButton in pairs(self.columnButtons) do
        columnButton:SetButtonState(false)
    end

    self.isLoading = false

    self:UpdateNavBar()
end

function HeadHuntingMixin:IsLoading()
    return self.isLoading
end

function HeadHuntingMixin:UpdateNavBar()
    local selectedTab = self:GetSelectedTab()

    NavBar_Reset(self.navBar)
    CloseDropDownMenus()

    if selectedTab == E_HEADHUNTING_TAB.HOME then
        return
    end

    NavBar_AddButton(self.navBar, self.panels[selectedTab].navBarData)
    NavBar_AddButton(self.navBar, {
        isDisabled = self:IsLoading(),
        name = self.categoryNavBarLabel[self:GetSelectedCategory()],
        listFunc = function(_, index)
            return self.categoryNavBarLabel[index], function(_, _index) self:SelectedCategory( _index ) end
        end,
    })
end

function HeadHuntingMixin:BuildPlayerInfo( key, structure, msg )
    local playerStorage = C_Split(msg, "|")

    if not playerStorage or #playerStorage == 0 then
        return
    end

    local playerContractStorage = C_CacheInstance:Get(key, {})

    if not playerContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] then
        playerContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] = {}
    end

    for _, playerInfo in pairs(playerStorage) do
        local playerData    = C_Split(playerInfo, ",")

        -- Статичные
        local GUID          = tonumber(playerData[structure.GUID])
        local name          = playerData[structure.NAME]
        local teamID        = tonumber(playerData[structure.TEAMID])
        local raceID        = tonumber(playerData[structure.RACE])
        local classID       = tonumber(playerData[structure.CLASS])
        local genderID      = tonumber(playerData[structure.GENDER])

        -- Опциональный
        local moneyInBank       = structure.MONEYINBANK and tonumber(playerData[structure.MONEYINBANK])
        local moneyPerKill      = structure.MONEYPERKILL and tonumber(playerData[structure.MONEYPERKILL])
        local totalKills        = structure.TOTALKILLS and tonumber(playerData[structure.TOTALKILLS])
        local currentKills      = structure.CURRENTKILLS and tonumber(playerData[structure.CURRENTKILLS])
        local timeLeft          = structure.TIMELEFT and tonumber(playerData[structure.TIMELEFT])
        local isOnline          = structure.ONLINE and tonumber(playerData[structure.ONLINE]) == 1
        local hasGuildContracts = structure.HASGUILDCONTRACTS and tonumber(playerData[structure.HASGUILDCONTRACTS]) == 1
        local guildName         = structure.GUILDNAME and playerData[structure.GUILDNAME]

        if not moneyInBank and (moneyPerKill and totalKills) then
            moneyInBank = moneyPerKill * totalKills
        end

        playerContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD][#playerContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] + 1] = {
            -- Статичные
            GUID                = GUID,
            name                = name,
            teamID              = SERVER_FACTION_TO_GAME_FACTION[teamID],
            raceID              = raceID,
            classID             = classID,
            genderID            = genderID,

            -- Опциональный
            moneyPerKill        = moneyPerKill,
            moneyInBank         = moneyInBank,
            totalKills          = totalKills,
            currentKills        = currentKills,
            timeLeft            = timeLeft,
            isOnline            = isOnline,
            hasGuildContracts   = hasGuildContracts,
            guildName           = guildName
        }
    end

    self:UpdateContent(true, true)
end

function HeadHuntingMixin:BuildGuildInfo( key, structure, msg )
    local guildStorage = C_Split(msg, "|")

    if not guildStorage or #guildStorage == 0 then
        return
    end

    local guildContractStorage = C_CacheInstance:Get(key, {})

    if not guildContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] then
        guildContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] = {}
    end

    for _, guildInfo in pairs(guildStorage) do
        local guildData     = C_Split(guildInfo, ",")

        -- Статичные
        local GUID              = tonumber(guildData[structure.GUID])
        local name              = guildData[structure.NAME]
        local teamID            = tonumber(guildData[structure.TEAMID])
        local emblemID          = tonumber(guildData[structure.STYLE])
        local emblemColorID     = tonumber(guildData[structure.COLOR])
        local borderStyleID     = tonumber(guildData[structure.BORDERSTYLE])
        local borderColorID     = tonumber(guildData[structure.BORDERCOLOR])
        local backgroundColorID = tonumber(guildData[structure.BACKGROUNDCOLOR])

        -- Опциональный
        local moneyInBank       = structure.MONEYINBANK and tonumber(guildData[structure.MONEYINBANK])
        local moneyPerKill      = structure.MONEYPERKILL and tonumber(guildData[structure.MONEYPERKILL])
        local totalKills        = structure.TOTALKILLS and tonumber(guildData[structure.TOTALKILLS])
        local currentKills      = structure.CURRENTKILLS and tonumber(guildData[structure.CURRENTKILLS])
        local timeLeft          = structure.TIMELEFT and tonumber(guildData[structure.TIMELEFT])

        if not moneyInBank and (moneyPerKill and totalKills) then
            moneyInBank = moneyPerKill * totalKills
        end

        guildContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD][#guildContractStorage[E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] + 1] = {
            -- Статичные
            GUID                = GUID,
            name                = name,
            teamID              = SERVER_FACTION_TO_GAME_FACTION[teamID],
            emblemID            = emblemID,
            emblemColorID       = emblemColorID,
            borderStyleID       = borderStyleID,
            borderColorID       = borderColorID,
            backgroundColorID   = backgroundColorID,

            -- Опциональный
            moneyPerKill        = moneyPerKill,
            moneyInBank         = moneyInBank,
            totalKills          = totalKills,
            currentKills        = currentKills,
            timeLeft            = timeLeft,
        }
    end

    self:UpdateContent(true, true)
end

function HeadHuntingMixin:GetNumRecords()
    local selectedTab   = self:GetSelectedTab()
    local numRecords    = 0

    if selectedTab == E_HEADHUNTING_TAB.ALL_TARGETS then
        local data = C_CacheInstance:Get("ASMSG_HEADHUNTING_CONTRACTS_LIST", {})
        numRecords = tCount(data[self:GetSelectedCategory()])
    elseif selectedTab == E_HEADHUNTING_TAB.YOU_TARGETS then
        local data = C_CacheInstance:Get("ASMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST", {})
        numRecords = tCount(data[self:GetSelectedCategory()])
    end

    return numRecords
end

function HeadHuntingMixin:GetRecord( index )
    local selectedTab   = self:GetSelectedTab()
    local data

    if selectedTab == E_HEADHUNTING_TAB.ALL_TARGETS then
        data = C_CacheInstance:Get("ASMSG_HEADHUNTING_CONTRACTS_LIST", {})
    elseif selectedTab == E_HEADHUNTING_TAB.YOU_TARGETS then
        data = C_CacheInstance:Get("ASMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST", {})
    end

    return data[self:GetSelectedCategory()] and data[self:GetSelectedCategory()][index]
end

function HeadHuntingMixin:GetSortOrderState()
    return self.sortData.sortOrderState
end

function HeadHuntingMixin:SetSort()
    self:RequestContractsList()
end

function HeadHuntingMixin:ClearSortData()
    self.sortData = {}
end

function HeadHuntingMixin:SetDefaultOrder( sortOrder, button, sortOrderState )
    self.sortData = {
        sortOrder       = sortOrder,
        button          = button,
        sortOrderState  = sortOrderState
    }
end

function HeadHuntingMixin:SetSortOrder( sortOrder, button )
    if self.sortData.button and self.sortData.button == button then
        if not self.sortData.sortOrderState then
            self.sortData.sortOrderState = HeadHuntingSortOrderState.PrimarySorted
        else
            self.sortData.sortOrderState = self.sortData.sortOrderState == HeadHuntingSortOrderState.PrimarySorted and HeadHuntingSortOrderState.PrimaryReversed or HeadHuntingSortOrderState.PrimarySorted
        end

        self:SetSort(sortOrder, self.sortData.sortOrderState)
        return
    elseif self.sortData.button then
        self.sortData.button.Arrow:Hide()
    end

    self.sortData = {
        sortOrder       = sortOrder,
        button          = button,
        sortOrderState  = HeadHuntingSortOrderState.PrimarySorted
    }

    self:SetSort(sortOrder, HeadHuntingSortOrderState.PrimarySorted)
end

function HeadHuntingMixin:GetSortOrder()
    return self.sortData.sortOrder
end

function HeadHuntingMixin:SetErrorID( errorID )
    self.errorID = errorID
end

function HeadHuntingMixin:GetErrorID()
    return self.errorID
end

function HeadHuntingMixin:ErrorBuilder( errorID )
    if isOneOf(errorID,
            E_HEADHUNTING_RESULTS.CONTRACT_NOT_FOUND,
            E_HEADHUNTING_RESULTS.NO_CONTRACTS_FOR_TYPE,
            E_HEADHUNTING_RESULTS.SEARCH_NO_TARGETS) then
        self:ShowError(errorID)
    else
        local text = E_HEADHUNTING_RESULTS[errorID] and (_G["HEADHUNTING_"..E_HEADHUNTING_RESULTS[errorID]] or E_HEADHUNTING_RESULTS[errorID]) or errorID
        self:ShowPopup(text)
    end
end

function HeadHuntingMixin:ShowError( errorID )
    local text              = E_HEADHUNTING_RESULTS[errorID] and (_G["HEADHUNTING_"..E_HEADHUNTING_RESULTS[errorID]] or E_HEADHUNTING_RESULTS[errorID]) or errorID
    local selectedTab       = self:GetSelectedTab()
    local panel             = self.Container[self.panels[selectedTab].name]
    local isSearchFrame     = false
    local textFrame

    if not errorID or isOneOf(errorID, E_HEADHUNTING_RESULTS.SEARCH_NAME_TOO_SHORT, E_HEADHUNTING_RESULTS.SEARCH_INVALID_NAME, E_HEADHUNTING_RESULTS.SEARCH_NO_TARGETS) then
        if panel.SetRewardFrame and panel.SetRewardFrame:IsShown() then
            textFrame = panel.SetRewardFrame.CentralContainer.ScrollFrame.TextFrame
        elseif HeadHuntingSetRewardExternalFrame and HeadHuntingSetRewardExternalFrame:IsShown() then
            textFrame = HeadHuntingSetRewardExternalFrame.CentralContainer.ScrollFrame.TextFrame
        end

        isSearchFrame = true
    end

    if not errorID or not isSearchFrame then
        if panel.ScrollFrame and not (panel.SetRewardFrame and panel.SetRewardFrame:IsShown()) then
            textFrame = panel.ScrollFrame.TextFrame
        end
    end

    self:SetErrorID(errorID)

    if textFrame then
        textFrame:SetText(text or HEADHUNTING_UNKNOWN_ERROR)
        textFrame:SetShown(errorID and text)
        textFrame:GetParent():UpdateContent()
    end
end

function HeadHuntingMixin:SendServerRequest( prefix, msg )
    self:ShowLoading()

    SendServerMessage(prefix, msg)
end

function HeadHuntingMixin:CloaseAllPopup()
    for _, frame in pairs(self.popupFrames) do
        frame:Hide()
    end
end

function HeadHuntingMixin:GetFreePopup()
    for _, frame in pairs(self.popupFrames) do
        if not frame:IsShown() then
            return frame
        end
    end
end

function HeadHuntingMixin:ShowPopup( text )
    local popupFrame = self:GetFreePopup()

    if popupFrame then
        popupFrame:SetText(text)
        popupFrame:Show()
    end
end

function HeadHuntingMixin:ASMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST( msg )
    local resultID = tonumber(msg)

    if resultID then
        if E_HEADHUNTING_RESULTS.OK ~= resultID then
            self:ErrorBuilder(resultID)
        end

        self:HideLoading()
        return
    end

    local searchData    = C_Split(msg, ":")
    local responseType  = tonumber(table.remove(searchData, 1)) + 1

    if responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD then
        self:BuildPlayerInfo("ASMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST", E_HEADHUNTING_PLAYER_CONTRACTS_PLAYER, searchData[1])
    elseif responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
        self:BuildGuildInfo("ASMSG_HEADHUNTING_PLAYER_CONTRACTS_LIST", E_HEADHUNTING_PLAYER_CONTRACTS_GUILD, searchData[1])
    end
end

function HeadHuntingMixin:ASMSG_HEADHUNTING_CONTRACTS_LIST( msg )
    local resultID = tonumber(msg)

    if resultID then
        if E_HEADHUNTING_RESULTS.OK ~= resultID then
            self:ErrorBuilder(resultID)
        end

        self:HideLoading()
        return
    end

    local searchData    = C_Split(msg, ":")
    local responseType  = tonumber(table.remove(searchData, 1)) + 1

    if responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD then
        self:BuildPlayerInfo("ASMSG_HEADHUNTING_CONTRACTS_LIST", E_HEADHUNTING_ALL_CONTRACTS_PLAYER, searchData[1])
    elseif responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
        self:BuildGuildInfo("ASMSG_HEADHUNTING_CONTRACTS_LIST", E_HEADHUNTING_ALL_CONTRACTS_GUILD, searchData[1])
    end
end

function HeadHuntingMixin:ASMSG_HEADHUNTING_ZONE_NOTIFICATIONS( msg )
    local resultID = tonumber(msg)

    if resultID then
        if E_HEADHUNTING_RESULTS[resultID] and E_HEADHUNTING_RESULTS.OK ~= resultID then
            self:ErrorBuilder(resultID)
            return
        end

        C_CacheInstance:Set("ASMSG_HEADHUNTING_ZONE_NOTIFICATIONS", resultID)
    end
end

HeadHuntingTabMixin = {}

function HeadHuntingTabMixin:OnLoad()
    self:GetParent():SetParentArray("topTabs", self)

    self.storedHeight = self:GetHeight()
    self:SetHeight(self.storedHeight - 4)
    self:SetWidth(max(self:GetTextWidth() + 20, 70))

    self.selectedGlow:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

function HeadHuntingTabMixin:OnClick()
    if self.forceDisable then
        return
    end

    for _, button in pairs(self:GetParent():GetParent().topTabs) do
        local selectedButton = button == self
        local color = selectedButton and NORMAL_FONT_COLOR or HIGHLIGHT_FONT_COLOR

        button:GetFontString():SetTextColor(color.r, color.g, color.b)
        button.selectedGlow:SetShown(selectedButton)
        button:SetEnabled(not selectedButton)

        button.isSelected = selectedButton
    end

    self:GetParent():GetParent():SetSelectedTab(self:GetID())
end

function HeadHuntingTabMixin:SetButtonState( isDisabled )
    self.forceDisable = isDisabled
    self:UpdateButtonState()
end

function HeadHuntingTabMixin:UpdateButtonState()
    if self:IsEnabled() == 0 then
        return
    end

    self.leftSelect:SetDesaturated(self.forceDisable)
    self.midSelect:SetDesaturated(self.forceDisable)
    self.rightSelect:SetDesaturated(self.forceDisable)
    self.grayBox:SetShown(self.forceDisable)
end

HeadHuntingPanelMixin = {}

function HeadHuntingPanelMixin:OnShow()
    self:UpdateColumns()
end

function HeadHuntingPanelMixin:OnHide()
    CloseChildWindows()
end

function HeadHuntingPanelMixin:UpdateColumns()
    if self.HeaderContainer then
        self.HeaderContainer:ColumnTemplateSetup(HeadHuntingFrame:GetSelectedTab(), HeadHuntingFrame:GetSelectedCategory())
    end
end

HeadHuntingColumnMixin = {}

function HeadHuntingColumnMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame
    self.mainFrame:SetParentArray("columnButtons", self, true)

    self.Arrow:SetAtlas("auctionhouse-ui-sortarrow", true)
    self.Arrow:ClearAndSetPoint("LEFT", self.Text, "RIGHT", 3, 0)
end

function HeadHuntingColumnMixin:OnClick()
    self.mainFrame:SetSortOrder(self.sortOrder, self)
    self:UpdateArrow()
end

function HeadHuntingColumnMixin:UpdateArrow()
    local sortOrderState = self.mainFrame:GetSortOrderState()
    self:SetArrowState(sortOrderState)
end

function HeadHuntingColumnMixin:SetArrowState( sortOrderState )
    self.Arrow:SetShown(sortOrderState == HeadHuntingSortOrderState.PrimarySorted or sortOrderState == HeadHuntingSortOrderState.PrimaryReversed)
    self.Arrow:SetTexCoord(0.987305, 0.996094, 0.0253906, 0.0341797)

    if sortOrderState == HeadHuntingSortOrderState.PrimarySorted then
        self.Arrow:SetSubTexCoord(0, 1, 1, 0)
    elseif sortOrderState == HeadHuntingSortOrderState.PrimaryReversed then
        self.Arrow:SetSubTexCoord(0, 1, 0, 1)
    end
end

function HeadHuntingColumnMixin:SetupData( data )
    self:SetText(data.text)
    self:SetWidth(data.width)

    self.sortOrder = data.sortOrder
    self:UpdateButtonState()

    if data.defaultSortState then
        self.mainFrame:SetDefaultOrder(self.sortOrder, self, data.defaultSortState)
        self:UpdateArrow()
    else
        self.Arrow:Hide()
    end
end

function HeadHuntingColumnMixin:SetButtonState( isDisabled )
    self.forceDisable = isDisabled
    self:UpdateButtonState()
end

function HeadHuntingColumnMixin:UpdateButtonState()
    self:SetEnabled(self.sortOrder and not self.forceDisable)

    local textColor = self.forceDisable and GRAY_FONT_COLOR or NORMAL_FONT_COLOR
    self.Text:SetTextColor(textColor.r, textColor.g, textColor.b)
end

HeadHuntingHeaderContainerMixin = {}

function HeadHuntingHeaderContainerMixin:OnLoad()
    self.columnTemplate = {
        [E_HEADHUNTING_TAB.ALL_TARGETS] = {
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] = {
                {text = HEADHUNTING_COLUMN_PLAYER,          width = 160,    sortOrder = E_HEADHUNTING_SORT_ORDER.NAME}, -- 30
                {text = HEADHUNTING_COLUMN_GUILD_WANTED,    width = 172,     sortOrder = E_HEADHUNTING_SORT_ORDER.HAS_GUILD_CONTRACTS},
                {text = HEADHUNTING_COLUMN_CLASS,           width = 56,     sortOrder = E_HEADHUNTING_SORT_ORDER.CLASS}, -- 10
                {text = HEADHUNTING_COLUMN_FACTION,         width = 70,     sortOrder = E_HEADHUNTING_SORT_ORDER.FACTION},
                {text = HEADHUNTING_COLUMN_REWARD_PER_KILL, width = 90,    sortOrder = E_HEADHUNTING_SORT_ORDER.MONEY_PER_KILL,    defaultSortState = HeadHuntingSortOrderState.PrimarySorted}, -- 40
                {text = HEADHUNTING_COLUMN_TOTAL_REWARDS,   width = 120,    sortOrder = E_HEADHUNTING_SORT_ORDER.MONEY_BANK},
                {text = HEADHUNTING_COLUMN_STATUS,          width = 108,    sortOrder = E_HEADHUNTING_SORT_ORDER.ONLINE}, -- 18
            },
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] = {
                {text = HEADHUNTING_COLUMN_GUILD_NAME,      width = 418,    sortOrder = E_HEADHUNTING_SORT_ORDER.NAME},
                {text = HEADHUNTING_COLUMN_FACTION,         width = 100,    sortOrder = E_HEADHUNTING_SORT_ORDER.FACTION},
                {text = HEADHUNTING_COLUMN_REWARD_PER_KILL, width = 120,    sortOrder = E_HEADHUNTING_SORT_ORDER.MONEY_PER_KILL,    defaultSortState = HeadHuntingSortOrderState.PrimarySorted},
                {text = HEADHUNTING_COLUMN_TOTAL_REWARDS,   width = 120,    sortOrder = E_HEADHUNTING_SORT_ORDER.MONEY_BANK},
            },
        },
        [E_HEADHUNTING_TAB.YOU_TARGETS] = {
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] = {
                {text = HEADHUNTING_COLUMN_PLAYER,          width = 298},
                {text = HEADHUNTING_COLUMN_CLASS,           width = 80},
                {text = HEADHUNTING_COLUMN_FACTION,         width = 80},
                {text = HEADHUNTING_COLUMN_KILLED,          width = 90},
                {text = HEADHUNTING_COLUMN_TIME_LEFT,       width = 90},
                {text = HEADHUNTING_COLUMN_TOTAL_REWARDS,   width = 120},
            },
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] = {
                {text = HEADHUNTING_COLUMN_GUILD_NAME,      width = 356},
                {text = HEADHUNTING_COLUMN_FACTION,         width = 80},
                {text = HEADHUNTING_COLUMN_KILLED,          width = 90},
                {text = HEADHUNTING_COLUMN_TIME_LEFT,       width = 90},
                {text = HEADHUNTING_COLUMN_TOTAL_REWARDS,   width = 140},
            },
        },
    }

    self.mainFrame = HeadHuntingFrame
end

function HeadHuntingHeaderContainerMixin:ColumnTemplateSetup( tabID, categoryID )
    if not self.columnTemplate[tabID] or not self.columnTemplate[tabID][categoryID] then
        return
    end

    for _, button in pairs(self.mainFrame.columnButtons) do
        button:Hide()
    end

    for index, columnData in pairs(self.columnTemplate[tabID][categoryID]) do
        local button = self.mainFrame.columnButtons[index] or CreateFrame("Button", self:GetName().."Column"..index, self, "HeadHuntingColumnTemplate")

        if index == 1 then
            button:SetPoint("TOPLEFT", 0, 0)
        else
            button:SetPoint("LEFT", self.mainFrame.columnButtons[index - 1], "RIGHT", 0, 0)
        end

        button:SetParent(self.mainFrame.Container[self.mainFrame.panels[tabID].name])
        button:SetupData(columnData)
        button:Show()
    end
end

HeadHuntingScrollFrameMixin = {}

function HeadHuntingScrollFrameMixin:OnLoad()
    self.buttonStorage = {}
    self.updateContentData = {
        [E_HEADHUNTING_TAB.ALL_TARGETS] = {
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] = {func = self.UpdateContentAllTargetsRewardForHead, tmpl = "HeadHuntingAllTargetsScrollPlayerButtonTemplate"},
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] = {func = self.UpdateContentAllTargetsRewardForGuild, tmpl = "HeadHuntingAllTargetsScrollGuildButtonTemplate"},
        },
        [E_HEADHUNTING_TAB.YOU_TARGETS] = {
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] = {func = self.UpdateContentYouTargetsRewardForHead, tmpl = "HeadHuntingYouTargetsScrollPlayerButtonTemplate"},
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] = {func = self.UpdateContentYouTargetsRewardForGuild, tmpl = "HeadHuntingYouTargetsScrollGuildButtonTemplate"},
        },
    }

    self.mainFrame = HeadHuntingFrame

    self.update = function() self:UpdateContent() end
    HybridScrollFrame_SetDoNotHideScrollBar(self, true)

    self:SetFrameLevel(self:GetParent().HeaderContainer:GetFrameLevel() + 3)
end

function HeadHuntingScrollFrameMixin:SetSelectedGUID( GUID )
    self.selectedGUID = GUID
end

function HeadHuntingScrollFrameMixin:GetSelectedGUID()
    return self.selectedGUID
end

function HeadHuntingScrollFrameMixin:SetSelectedButton( button )
    self.selectedButton = button
end

function HeadHuntingScrollFrameMixin:GetSelectedButton()
    return self.selectedButton
end

function HeadHuntingScrollFrameMixin:UpdateButtons()
    local template = self.updateContentData[self.mainFrame:GetSelectedTab()][self.mainFrame:GetSelectedCategory()].tmpl

    for _, button in pairs(self.buttons or {}) do
        button:Hide()
    end

    self.buttons = self.buttonStorage[template]

    HybridScrollFrame_CreateButtons(self, template, 0, -2, nil, nil, nil, -2)

    self.buttonStorage[template] = self.buttons

    self:UpdateContent()
end

function HeadHuntingScrollFrameMixin:UpdateContent()
    self.offset = HybridScrollFrame_GetOffset(self)
    self.numButtons = self.buttons and #self.buttons or 0
    self.numRecords = self.mainFrame:GetNumRecords()

    self.updateContentData[self.mainFrame:GetSelectedTab()][self.mainFrame:GetSelectedCategory()].func(self)

    local totalHeight = self.numRecords * (self.buttons and self.buttons[1]:GetHeight() or 0) + (self.numRecords - 1) * 2
    HybridScrollFrame_Update(self, totalHeight, self:GetHeight())
end

function HeadHuntingScrollFrameMixin:UpdateContentAllTargetsRewardForHead()
    local button, index
    local selectedGUID = self:GetSelectedGUID()

    for i = 1, self.numButtons do
        button = self.buttons[i]
        index = self.offset + i

        local data = self.mainFrame:GetRecord(index)

        if index <= self.numRecords and data then
            button.index        = index
            button.GUID         = data.GUID
            button.playerData   = {data.name, data.raceID, data.classID, data.genderID}

            button.PlayerFrame:SetPlayer(data.name, data.raceID, data.classID, data.genderID)
            button.ClassFrame:SetClass(data.classID)
            button.FactionFrame:SetFaction(data.teamID)

            button.RewardForKillFrame:SetMoney(data.moneyPerKill)
            button.TotalRewardFrame:SetMoney(data.moneyInBank)

            button.StatusFrame:SetStatus(data.isOnline)
            button.GuildMinimalizeFrame:SetGuild(data.guildName, data.hasGuildContracts)

            if selectedGUID and selectedGUID == data.GUID then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end

            button.Background:SetShown(index % 2 ~= 0)
            button:Show()
        else
            button:Hide()
        end
    end
end

function HeadHuntingScrollFrameMixin:UpdateContentAllTargetsRewardForGuild()
    local button, index
    local selectedGUID = self:GetSelectedGUID()

    for i = 1, self.numButtons do
        button = self.buttons[i]
        index = self.offset + i

        local data = self.mainFrame:GetRecord(index)

        if index <= self.numRecords then
            button.index        = index
            button.GUID         = data.GUID
            button.guildData    = {data.name, data.emblemID, data.borderStyleID, data.emblemColorID, data.backgroundColorID, data.borderColorID}

            button.GuildFrame:SetGuild(data.name, data.emblemID, data.borderStyleID, data.emblemColorID, data.backgroundColorID, data.borderColorID)
            button.FactionFrame:SetFaction(data.teamID)

            button.RewardForKillFrame:SetMoney(data.moneyPerKill)
            button.TotalRewardFrame:SetMoney(data.moneyInBank)

            if selectedGUID and selectedGUID == data.GUID then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end

            button.Background:SetShown(index % 2 ~= 0)
            button:Show()
        else
            button:Hide()
        end
    end
end

function HeadHuntingScrollFrameMixin:UpdateContentYouTargetsRewardForHead()
    local button, index
    local selectedGUID = self:GetSelectedGUID()

    for i = 1, self.numButtons do
        button = self.buttons[i]
        index = self.offset + i

        local data = self.mainFrame:GetRecord(index)

        if index <= self.numRecords then
            button.index        = index
            button.GUID         = data.GUID

            button.PlayerFrame:SetPlayer(data.name, data.raceID, data.classID, data.genderID)
            button.ClassFrame:SetClass(data.classID)
            button.FactionFrame:SetFaction(data.teamID)
            button.KillsFrame:SetKills(data.currentKills .." / ".. data.totalKills)
            button.TimeFrame:SetTime(data.timeLeft)

            button.TotalRewardFrame:SetMoney(data.moneyInBank)

            if selectedGUID and selectedGUID == data.GUID then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end

            button.Background:SetShown(index % 2 ~= 0)
            button:Show()
        else
            button:Hide()
        end
    end
end

function HeadHuntingScrollFrameMixin:UpdateContentYouTargetsRewardForGuild()
    local button, index

    for i = 1, self.numButtons do
        button = self.buttons[i]
        index = self.offset + i

        local data = self.mainFrame:GetRecord(index)

        if index <= self.numRecords then
            button.index = index
            button.GUID = data.GUID

            button.GuildFrame:SetGuild(data.name, data.emblemID, data.borderStyleID, data.emblemColorID, data.backgroundColorID, data.borderColorID)
            button.FactionFrame:SetFaction(data.teamID)
            button.KillsFrame:SetKills(data.currentKills .." / ".. data.totalKills)
            button.TimeFrame:SetTime(data.timeLeft)
            button.TotalRewardFrame:SetMoney(data.moneyInBank)

            button.Background:SetShown(index % 2 ~= 0)
            button:Show()
        else
            button:Hide()
        end
    end
end

HeadHuntingPlayerFrameMixin = {}

function HeadHuntingPlayerFrameMixin:SetPlayer( name, raceID, classID, gender )
    local classInfo = C_CreatureInfo.GetClassInfo(classID)
    local raceInfo  = C_CreatureInfo.GetRaceInfo(raceID)
    local raceIcon  = string.format("Interface\\Custom_LoginScreen\\RaceIcon\\RACE_ICON_%s%s", string.upper(raceInfo.clientFileString), S_GENDER_FILESTRING[gender or 0])
    local playerName = GetClassColorObj(classInfo.classFile):WrapTextInColorCode(name or "~no name~")

    self.Name:SetText(playerName)
    self:GetParent().name = name
    self:GetParent().stylishName = playerName

    SetPortraitToTexture(self.RaceIcon, raceIcon)
end

HeadHuntingClassFrameMixin = {}

function HeadHuntingClassFrameMixin:SetClass( classID )
    local classInfo = C_CreatureInfo.GetClassInfo(classID)

    SetPortraitToTexture(self.ClassIcon, "Interface\\Custom_LoginScreen\\ClassIcon\\CLASS_ICON_"..string.upper(classInfo.classFile))
end

HeadHuntingFactionFrameMixin = {}

function HeadHuntingFactionFrameMixin:OnLoad()
    self.factionIcons = {
        [PLAYER_FACTION_GROUP.Horde]    = "right",
        [PLAYER_FACTION_GROUP.Alliance] = "left",
        [PLAYER_FACTION_GROUP.Renegade] = "Renegade",
    }
end

function HeadHuntingFactionFrameMixin:SetFaction( factionID )
    self.FactionIcon:SetAtlas("objectivewidget-icon-"..self.factionIcons[factionID])
end

HeadHuntingMoneyFrameMixin = {}

function HeadHuntingMoneyFrameMixin:OnLoad()
    self.Coin:ClearAndSetPoint("LEFT", self.Text, "RIGHT", 2, 0)
end

function HeadHuntingMoneyFrameMixin:SetMoney( money )
    self.Text:SetText(money)
end

HeadHuntingStatusFrameMixin = {}

function HeadHuntingStatusFrameMixin:SetStatus( isOnline )
    self.StatusTexture:SetTexture("Interface\\FriendsFrame\\StatusIcon-"..(isOnline and "Online" or "Offline"))
    self.Status:SetText(isOnline and FRIENDS_LIST_ONLINE or FRIENDS_LIST_OFFLINE)
end

HeadHuntingGuildFrameMixin = {}

function HeadHuntingGuildFrameMixin:SetGuild( name, emblemID, borderStyleID, emblemColorID, backgroundColorID, borderColorID )
    local emblemCoords      = C_Guild:GetTabardSmallEmblemCoords(emblemID)
    local emblemColor       = C_Guild:GetTabardEmblemColor(emblemColorID)
    local backgroundColor   = C_Guild:GetTabardBackgroundColor(backgroundColorID)
    local borderColor       = C_Guild:GetTabardBorderColor(borderStyleID, borderColorID)

    self.Name:SetText(name)
    self:GetParent().name = name

    self.Emblem:SetTexCoord(unpack(emblemCoords))

    self.Emblem:SetVertexColor(emblemColor.r, emblemColor.g, emblemColor.b)
    self.Banner:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b)
    self.BannerBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
end

HeadHuntingKillsFrameMixin = {}

function HeadHuntingKillsFrameMixin:SetKills( numKills )
    self.Text:SetText(numKills)
end

HeadHuntingTimeFrameMixin = {}

function HeadHuntingTimeFrameMixin:OnLoad()
    self.TimeFormatter = CreateFromMixins(SecondsFormatterMixin)
    self.TimeFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true, nil, 1)

    self.TimeFormatter.GetMinInterval = function()
        return SecondsFormatter.Interval.Hours
    end

    self.TimeFormatter.GetDesiredUnitCount = function()
        return 1
    end
end

function HeadHuntingTimeFrameMixin:SetTime( seconds )
    self.Text:SetText(self.TimeFormatter:Format(seconds))
end

HeadHuntingDetailsFrameMixin = {}

function HeadHuntingDetailsFrameMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame
    self.panelFrame = self:GetParent()

    self:RegisterEventListener()
end

function HeadHuntingDetailsFrameMixin:OnShow()
    self.panelFrame.ScrollFrame:UpdateContent()
end

function HeadHuntingDetailsFrameMixin:OnHide()
    self.panelFrame.ScrollFrame:SetSelectedGUID(nil)
    self:SetGUID(nil)

    if self.panelFrame:IsShown() then
        self.panelFrame.ScrollFrame:UpdateContent()
    end
end

function HeadHuntingDetailsFrameMixin:SetGUID( GUID )
    self.GUID = GUID
end

function HeadHuntingDetailsFrameMixin:GetGUID()
    return self.GUID
end

function HeadHuntingDetailsFrameMixin:ShowDetails( GUID )
    if self:GetGUID() == GUID then
        return
    end

    self:SetGUID(GUID)

    local selectedCategory = self.mainFrame:GetSelectedCategory() - 1

    self.mainFrame:SendServerRequest("ACMSG_HEADHUNTING_CONTRACT_NOTIFICATIONS", string.format("%s,%s", selectedCategory, GUID))
end

function HeadHuntingDetailsFrameMixin:RemoveContract()
    local selectedCategory  = self.mainFrame:GetSelectedCategory() - 1
    local selectedGUID      = self:GetGUID()

    local popup = StaticPopup_Show("HEADHUNTING_REMOVE_CONTRACT")
    popup.data = string.format("%s,%s", selectedCategory, selectedGUID)

    self:Hide()
end

function HeadHuntingDetailsFrameMixin:ASMSG_HEADHUNTING_CONTRACT_CANCEL( msg )
    local resultID = tonumber(msg)

    if resultID then
        if E_HEADHUNTING_RESULTS.OK == resultID then
            self.mainFrame:ShowPopup(HEADHUNTING_TOAST_CONTRACT_SUCCESSFULLY_CANCEL)
            self.mainFrame:RequestContracts()
        else
            self.mainFrame:ErrorBuilder(resultID)
        end

        self.mainFrame:HideLoading()
    end
end

function HeadHuntingDetailsFrameMixin:ASMSG_HEADHUNTING_CONTRACT_CHANGE_NOTIFICATIONS( msg )
    local resultID = tonumber(msg)

    self.mainFrame:HideLoading()

    if resultID then
        if E_HEADHUNTING_RESULTS.OK ~= resultID then
            self.mainFrame:ErrorBuilder(resultID)
        end
    end
end

function HeadHuntingDetailsFrameMixin:ASMSG_HEADHUNTING_CONTRACT_NOTIFICATIONS( msg )
    local resultID = tonumber(msg)

    self.mainFrame:HideLoading()

    if resultID then
        self.mainFrame:ErrorBuilder(resultID)

        self:SetGUID(nil)
        self.panelFrame.ScrollFrame:SetSelectedGUID(nil)
        self.panelFrame.ScrollFrame:UpdateContent()
        return
    end

    local messageData = C_Split(msg, ":")
    local notificationStorage = C_Split(messageData[2], "|")

    for _, notificationData in pairs(notificationStorage) do
        local data      = C_Split(notificationData, ",")

        local flag      = tonumber(data[E_HEADHUNTING_NOTIFICATIONS_INFO.FLAG])
        local status    = tonumber(data[E_HEADHUNTING_NOTIFICATIONS_INFO.STATUS]) == 1

        self.settingsCheckButtons[flag]:SetChecked(status)
    end

    self:Show()
end

HeadHuntingYouTargetsBaseScrollButtonTemplateMixin = {}

function HeadHuntingYouTargetsBaseScrollButtonTemplateMixin:OnLoad()
    self.panelFrame = self:GetParent():GetParent():GetParent()
end

function HeadHuntingYouTargetsBaseScrollButtonTemplateMixin:OnClick()
    self.panelFrame.ScrollFrame:SetSelectedGUID(self.GUID)
    self.panelFrame.DetailsFrame:ShowDetails(self.GUID)
end

HeadHuntingCheckButtonMixin = {}

function HeadHuntingCheckButtonMixin:OnLoad()
    self:RegisterEventListener()

    self.text           = _G[self:GetAttribute("text")] or self:GetAttribute("text")
    self.tooltipHead    = _G[self:GetAttribute("tooltipHead")] or self:GetAttribute("toocltipHead")
    self.tooltipBody    = _G[self:GetAttribute("tooltipBody")] or self:GetAttribute("tooltipBody")
    self.addonMessage   = self:GetAttribute("addonMessage")

    self.detailsFrame   = self:GetParent():GetParent()
    self.mainFrame      = HeadHuntingFrame

    if not self.detailsFrame.settingsCheckButtons then
        self.detailsFrame.settingsCheckButtons = {}
    end

    self.detailsFrame.settingsCheckButtons[self:GetID()] = self

    self.Text:SetText(self.text)
end

function HeadHuntingCheckButtonMixin:OnClick()
    self.mainFrame:SendServerRequest(self.addonMessage, string.format("%s,%s,%s,%s",
            self.mainFrame:GetSelectedCategory() - 1,
            self.detailsFrame:GetGUID(),
            self:GetID(),
            self:GetChecked() or 0
    ))
end

function HeadHuntingCheckButtonMixin:OnEnter()
    if not self.tooltipHead then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(self.tooltipHead, 1, 1, 1)

    if self.tooltipBody then
        GameTooltip:AddLine(self.tooltipBody, nil, nil, nil, true)
    end

    GameTooltip:Show()
end

HeadHuntingSetRewardFrameMixin = {}

function HeadHuntingSetRewardFrameMixin:OnLoad()
    self:RegisterEventListener()

    self.mainFrame = HeadHuntingFrame

    self:SetBorder("ButtonFrameTemplateNoPortrait")
    self:SetPortraitShown(false)

    self:SetTitle(HEADHUNTING_SET_REWARD)
end

function HeadHuntingSetRewardFrameMixin:OnShow()
    self:ClearData()
end

function HeadHuntingSetRewardFrameMixin:GetNumRecords()
    local data = C_CacheInstance:Get("ASMSG_HEADHUNTING_SEARCH_RESPONSE", {})
    local numRecords = tCount(data[self.mainFrame:GetSelectedCategory()])

    return numRecords or 0
end

function HeadHuntingSetRewardFrameMixin:GetRecord( index )
    local storage = C_CacheInstance:Get("ASMSG_HEADHUNTING_SEARCH_RESPONSE", {})
    local data = storage[self.mainFrame:GetSelectedCategory()] and storage[self.mainFrame:GetSelectedCategory()][index]

    return data
end

function HeadHuntingSetRewardFrameMixin:ClearData( dontResetUI )
    C_CacheInstance:Set("ASMSG_HEADHUNTING_SEARCH_RESPONSE", {})

    if not dontResetUI then
        local selectedCategory = self.mainFrame:GetSelectedCategory()

        self:SelectedGUID(nil)
        self.mainFrame:ShowError(nil)
        self.GoldPerKillsEditBox:SetText(100)
        self.NumKills:SetText(selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD and 10 or 1)
        self.SearchFrame.SearchBox:SetText("")
        self.SetRewardButton:UpdateButtonState()
        self.CentralContainer.ScrollFrame:UpdateContent()
    end

    for _, frame in pairs(self.HelpBoxFrame.stepFrames) do
        frame:SetStatus(false)
    end

    self.HelpBoxFrame:UpdateTotalMoney()
end

function HeadHuntingSetRewardFrameMixin:SelectedGUID( GUID )
    self:SetSelectedGUID(GUID)
    self.SetRewardButton:UpdateButtonState()

    self.HelpBoxFrame:SetStepStatus("selectedTarget", GUID)
end

function HeadHuntingSetRewardFrameMixin:SetSelectedGUID( GUID )
    self.selectedGUID = GUID
end

function HeadHuntingSetRewardFrameMixin:GetSelectedGUID()
    return self.selectedGUID
end

function HeadHuntingSetRewardFrameMixin:ASMSG_HEADHUNTING_CONTRACT_REGISTER( msg )
    if not self:IsShown() then
        return
    end

    local resultID = tonumber(msg)

    self.mainFrame:HideLoading()

    if resultID then
        if E_HEADHUNTING_RESULTS.OK == resultID then
            self.mainFrame:ShowPopup(HEADHUNTING_TOAST_CONTRACT_SUCCESSFULLY_REGISTER)

            HideUIPanel(self)
            self.mainFrame:RequestContracts()
        else
            self.mainFrame:ErrorBuilder(resultID)
        end
        return
    end
end

function HeadHuntingSetRewardFrameMixin:ASMSG_HEADHUNTING_SEARCH_RESPONSE( msg )
    if not self:IsShown() then
        return
    end

    local resultID = tonumber(msg)

    self.mainFrame:HideLoading()

    if resultID then
        if E_HEADHUNTING_RESULTS.OK ~= resultID then
            self.mainFrame:ErrorBuilder(resultID)
        end
        return
    end

    local searchData = C_Split(msg, ":")
    local responseType = tonumber(table.remove(searchData, 1)) + 1

    if responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD then
        self.mainFrame:BuildPlayerInfo("ASMSG_HEADHUNTING_SEARCH_RESPONSE", E_HEADHUNTING_SEARCH_PLAYER, searchData[1])
    elseif responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
        self.mainFrame:BuildGuildInfo("ASMSG_HEADHUNTING_SEARCH_RESPONSE", E_HEADHUNTING_SEARCH_GUILD, searchData[1])
    end

    self.HelpBoxFrame:SetStepStatus("search", true)
    self.SearchFrame.SearchButton:UpdateButtonState()
    self.CentralContainer.ScrollFrame:UpdateContent()
end

HeadHuntingSearchFrameMixin = {}

function HeadHuntingSearchFrameMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame
end

function HeadHuntingSearchFrameMixin:Search()
    self:GetParent():SelectedGUID(nil)
    self:GetParent():ClearData(true)
    self.mainFrame:ShowError(nil)

    self.mainFrame:SendServerRequest("ACMSG_HEADHUNTING_SEARCH_REQUEST", string.format("%s,%s", self.mainFrame:GetSelectedCategory() - 1, self.SearchBox:GetText()))

    self.SearchButton:UpdateButtonState()
end

function HeadHuntingSearchFrameMixin:UpdateContent()
    local selectedCategory  = self.mainFrame:GetSelectedCategory()
    local instructions      = selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD and HEADHUNTING_SEARCH_INSTRUCTION_GUILD or HEADHUNTING_SEARCH_INSTRUCTION_PLAYER

    self.SearchBox.Instructions:SetText(instructions)
end

HeadHuntingSearchScrollFrameMixin = {}

function HeadHuntingSearchScrollFrameMixin:OnLoad()
    self.buttonStorage = {}
    self.mainFrame = HeadHuntingFrame
    self.rewardFrame = self:GetParent():GetParent()

    self.updateContentData = {
        [E_HEADHUNTING_TAB.YOU_TARGETS] = {
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD] = {func = self.UpdateContentSearchPlayer, tmpl = "HeadHuntingSearchScrollPlayerButtonTemplate"},
            [E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD] = {func = self.UpdateContentSearchGuild, tmpl = "HeadHuntingSearchScrollGuildButtonTemplate"},
        },
    }

    self.update = function() self:UpdateContent() end
    HybridScrollFrame_SetDoNotHideScrollBar(self, true)

    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 3)
end

function HeadHuntingSearchScrollFrameMixin:UpdateContent()
    self.offset = HybridScrollFrame_GetOffset(self)
    self.numButtons = self.buttons and #self.buttons or 0
    self.numRecords = self.rewardFrame:GetNumRecords()

    self.updateContentData[self.mainFrame:GetSelectedTab()][self.mainFrame:GetSelectedCategory()].func(self)

    local totalHeight = self.numRecords * (self.buttons and self.buttons[1]:GetHeight() or 0) + (self.numRecords - 1) * 2
    HybridScrollFrame_Update(self, totalHeight, self:GetHeight())
end

function HeadHuntingSearchScrollFrameMixin:UpdateContentSearchPlayer()
    local button, index
    local selectedGUID = self.rewardFrame:GetSelectedGUID()

    for i = 1, self.numButtons do
        button = self.buttons[i]
        index = self.offset + i

        local data = self.rewardFrame:GetRecord(index)

        if index <= self.numRecords and data then
            button.index        = index
            button.GUID         = data.GUID

            button.PlayerFrame:SetPlayer(data.name, data.raceID, data.classID, data.genderID)
            button.ClassFrame:SetClass(data.classID)
            button.FactionFrame:SetFaction(data.teamID)

            if selectedGUID and selectedGUID == button.GUID then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end

            button.Background:SetShown(index % 2 ~= 0)
            button:Show()
        else
            button:Hide()
        end
    end
end

function HeadHuntingSearchScrollFrameMixin:UpdateContentSearchGuild()
    local button, index
    local selectedGUID = self.rewardFrame:GetSelectedGUID()

    for i = 1, self.numButtons do
        button = self.buttons[i]
        index = self.offset + i

        local data = self.rewardFrame:GetRecord(index)

        if index <= self.numRecords and data then
            button.index        = index
            button.GUID         = data.GUID

            button.GuildFrame:SetGuild(data.name, data.emblemID, data.borderStyleID, data.emblemColorID, data.backgroundColorID, data.borderColorID)
            button.FactionFrame:SetFaction(data.teamID)

            if selectedGUID and selectedGUID == button.GUID then
                button:LockHighlight()
            else
                button:UnlockHighlight()
            end

            button.Background:SetShown(index % 2 ~= 0)
            button:Show()
        else
            button:Hide()
        end
    end
end

HeadHuntingSearchScrollButtonTemplateMixin = {}

function HeadHuntingSearchScrollButtonTemplateMixin:OnLoad()
    self.setRewardFrame = self:GetParent():GetParent():GetParent():GetParent()
end

function HeadHuntingSearchScrollButtonTemplateMixin:OnClick()
    local selectedGUID = self.setRewardFrame:GetSelectedGUID()
    if not selectedGUID or selectedGUID ~= self.GUID then
        self.setRewardFrame:SelectedGUID(self.GUID)
    else
        self.setRewardFrame:SelectedGUID(nil)
    end

    self.setRewardFrame.SetRewardButton:UpdateButtonState()
    self.setRewardFrame.CentralContainer.ScrollFrame:UpdateContent()
end

HeadHuntingSetRewardButtonMixin = {}

function HeadHuntingSetRewardButtonMixin:OnLoad()
    self.setRewardFrame     = self:GetParent()
    self.numKillsEditBox    = self:GetParent().NumKills
    self.goldPerKillEditBox = self:GetParent().GoldPerKillsEditBox
    self.HelpBoxFrame       = self:GetParent().HelpBoxFrame
end

function HeadHuntingSetRewardButtonMixin:OnClick()
    local numKills          = self.numKillsEditBox:GetText()
    local goldPerKill       = self.goldPerKillEditBox:GetText()
    local selectedCategory  = self.setRewardFrame.mainFrame:GetSelectedCategory() - 1
    local selectedGUID      = self.setRewardFrame:GetSelectedGUID()

    if (not numKills or numKills == "") or (not goldPerKill or goldPerKill == "") then
        return
    end

    self.setRewardFrame.mainFrame:SendServerRequest("ACMSG_HEADHUNTING_CONTRACT_REGISTER", string.format("%s,%s,%s,%s", selectedCategory, selectedGUID, numKills, goldPerKill))
end

function HeadHuntingSetRewardButtonMixin:SetButtonState( isDisabled )
    self.forceDisable = isDisabled
    self:UpdateButtonState()
end

function HeadHuntingSetRewardButtonMixin:UpdateButtonState()
    local selectedCategory      = self.setRewardFrame.mainFrame:GetSelectedCategory()
    local numKills              = tonumber(self.numKillsEditBox:GetText())
    local goldPerKill           = tonumber(self.goldPerKillEditBox:GetText())
    local selectedGUID          = self.setRewardFrame:GetSelectedGUID()
    local numKillsValidation    = false
    local selectedGuildCategory = selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD

    self.disableReason          = {}

    self.HelpBoxFrame:UpdateTotalMoney()

    if numKills then
        if selectedGuildCategory then
            numKillsValidation = numKills >= HEADHUNTING_MIN_CONTRACT_GUILD_KILLS
        else
            numKillsValidation = numKills >= HEADHUNTING_MIN_CONTRACT_PLAYER_KILLS
        end
    end

    if not numKillsValidation then
        local requiredNumKills = selectedGuildCategory and HEADHUNTING_MIN_CONTRACT_GUILD_KILLS or HEADHUNTING_MIN_CONTRACT_PLAYER_KILLS

        table.insert(self.disableReason, string.format(HEADHUNTING_SET_REWARD_BUTTON_DISABLE_REASON_1, requiredNumKills))
    end

    if not goldPerKill or goldPerKill == 0 then
        table.insert(self.disableReason, HEADHUNTING_SET_REWARD_BUTTON_DISABLE_REASON_2)
    end

    if not selectedGUID then
        table.insert(self.disableReason, HEADHUNTING_SET_REWARD_BUTTON_DISABLE_REASON_4)
    end

    if self.HelpBoxFrame.moneyError then
        table.insert(self.disableReason, self.HelpBoxFrame.moneyError)
    end

    local isEnabled = not self.forceDisable and #self.disableReason == 0
    self:SetEnabled(isEnabled)

    if self:IsMouseOver() then
        self:OnEnter()
    end
end

function HeadHuntingSetRewardButtonMixin:OnEnter()
    if #self.disableReason > 0 and self:GetParent():IsShown() then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetText(HEADHUNTING_SET_REWARD_BUTTON_TOOLTIP)
        GameTooltip:AddLine(HEADHUNTING_SET_REWARD_BUTTON_TOOLTIP_DESC, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)

        for _, text in pairs(self.disableReason) do
            GameTooltip:AddLine(text, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, nil, true)
        end

        GameTooltip:Show()
    else
        GameTooltip_Hide()
    end
end

HeadHuntingScrollTextFrameMixin = {}

function HeadHuntingScrollTextFrameMixin:SetText( text )
    self.Text:SetText(text)
end

HeadHuntingSearchButtonMixin = {}

function HeadHuntingSearchButtonMixin:SetButtonState( isDisabled )
    self.forceDisable = isDisabled
    self:UpdateButtonState()
end

function HeadHuntingSearchButtonMixin:UpdateButtonState()
    local isEnabled = not self.forceDisable and #self:GetParent().SearchBox:GetText() >= 3
    self:SetEnabled(isEnabled)
end

HeadHuntingSetRewardExternalFrameMixin = {}

function HeadHuntingSetRewardExternalFrameMixin:Init()
    self.SearchFrame.Search = function( self, GUID )
        local name = self.SearchBox:GetText()

        self:GetParent():ClearData(true)

        self.mainFrame:SendServerRequest("ACMSG_HEADHUNTING_SEARCH_REQUEST", string.format("%s,%s", 0, GUID and tonumber(GUID) or name))
        self.SearchButton:UpdateButtonState()
    end

    self:OnLoad()
end

function HeadHuntingSetRewardExternalFrameMixin:OpenAndSearch( name, GUID )
    HeadHuntingFrame:SelectedTab(E_HEADHUNTING_TAB.YOU_TARGETS)
    HeadHuntingFrame:SetSelectedCategory(E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD)

    self:ClearData()

    if not self:IsShown() then
        ShowUIPanel(self)
    end

    self.HelpBoxFrame:UpdateContent()

    C_Timer:After(0.2, function()
        self.SearchFrame.SearchBox:SetText(name)
        self.SearchFrame:Search(GUID, name)
    end)
end

HeadHuntingAllTargetsBaseScrollButtonTemplateMixin = {}

function HeadHuntingAllTargetsBaseScrollButtonTemplateMixin:OnLoad()
    self.scrollFrame    = self:GetParent():GetParent()
    self.mainFrame      = HeadHuntingFrame
end

function HeadHuntingAllTargetsBaseScrollButtonTemplateMixin:OnClick()
    if self.scrollFrame:GetSelectedGUID() == self.GUID then
        return
    end

    local selectedCategory = self.mainFrame:GetSelectedCategory() - 1

    self.scrollFrame:SetSelectedGUID(self.GUID)
    self.scrollFrame:SetSelectedButton(self)

    self.mainFrame:SendServerRequest("ACMSG_HEADHUNTING_CONTRACT_DETAILS", string.format("%s,%s", selectedCategory, self.GUID))
end

HeadHuntingInfoFrameMixin = {}

function HeadHuntingInfoFrameMixin:OnLoad()
    self.panelFrame = self:GetParent()
    self.mainFrame = HeadHuntingFrame

    self.TimeFormatter = CreateFromMixins(SecondsFormatterMixin)
    self.TimeFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true, nil, 1)

    self:RegisterEventListener()
end

function HeadHuntingInfoFrameMixin:OnShow()
    self.panelFrame.ScrollFrame:UpdateContent()
end

function HeadHuntingInfoFrameMixin:OnHide()
    self.panelFrame.ScrollFrame:SetSelectedGUID(nil)
    self.panelFrame.ScrollFrame:SetSelectedButton(nil)

    if self.panelFrame:IsShown() then
        self.panelFrame.ScrollFrame:UpdateContent()
    end
end

function HeadHuntingInfoFrameMixin:ASMSG_HEADHUNTING_CONTRACT_DETAILS( msg )
    local resultID = tonumber(msg)

    self.mainFrame:HideLoading()

    if resultID then
        if E_HEADHUNTING_RESULTS.OK ~= resultID then
            self.mainFrame:ErrorBuilder(resultID)

            local selectedTab = self.mainFrame:GetSelectedTab()
            self.mainFrame.Container[self.panels[selectedTab].name].ScrollFrame:SetSelectedGUID(nil)
        end
        return
    end

    local contractsStorage  = C_Split(msg, "|")
    local finalyString      = ""

    for _, contract in pairs(contractsStorage) do
        local contractData  = C_Split(contract, ",")
        local moneyPerKill  = tonumber(contractData[E_HEADHUNTING_CONTRACT_DETAILS.MONEYPERKILL])
        local killsLeft     = tonumber(contractData[E_HEADHUNTING_CONTRACT_DETAILS.KILLSLEFT])
        local timeLeft      = tonumber(contractData[E_HEADHUNTING_CONTRACT_DETAILS.TIMELEFT])

        finalyString = finalyString .. string.format(HEADHUNTING_CONTRACT_DETAILS, killsLeft, killsLeft * moneyPerKill, moneyPerKill, self.TimeFormatter:Format(timeLeft))
    end

    local selectedButton = self.panelFrame.ScrollFrame:GetSelectedButton()

    if selectedButton then
        self.Container.ScrollFrame.Info.GuildFrame:SetShown(selectedButton.guildData)
        self.Container.ScrollFrame.Info.PlayerFrame:SetShown(selectedButton.playerData)

        if selectedButton.playerData then
            self.Container.ScrollFrame.Info.PlayerFrame:SetPlayer(unpack(selectedButton.playerData))
        elseif selectedButton.guildData then
            self.Container.ScrollFrame.Info.GuildFrame:SetGuild(unpack(selectedButton.guildData))
        end
    end

    self.Container.ScrollFrame.Info.Contracts:SetText(finalyString)

    self:Show()
end

HeadHuntingStatsFrameMixin = {}

function HeadHuntingStatsFrameMixin:OnLoad()
    self:RegisterHookListener()

    self.text = _G[self:GetAttribute("text")] or self:GetAttribute("text")

    self:SetParentArray("statsFrame")

    self.Background:SetAtlas("jailerstower-animapowerlist-dropdown-openbg")
end

function HeadHuntingStatsFrameMixin:SetStats( count, money )
    self.Text:SetFormattedText(self.text, tonumber(count), money)
end

function HeadHuntingStatsFrameMixin:InitData()
    local statsStorage = C_CacheInstance:Get("ASMSG_HEADHUNTING_SUMMARY_INFO", {})
    local statsData = statsStorage[self:GetID()]

    if statsData then
        self:SetStats(statsData.contractCount or 0, statsData.totalMoney or 0)
    end

    self:SetShown(statsData and statsData.contractCount > 0)
end

function HeadHuntingStatsFrameMixin:VARIABLES_LOADED()
    self:InitData()
end

HeadHuntingSummaryFrameMixin = {}

function HeadHuntingSummaryFrameMixin:OnLoad()
    self:RegisterEventListener()
end

function HeadHuntingSummaryFrameMixin:ASMSG_HEADHUNTING_SUMMARY_INFO( msg )
    local dataStorage = C_Split(msg, "|")

    for index, dataMSG in pairs(dataStorage) do
        local data = C_Split(dataMSG, ",")

        C_CacheInstance:Set("ASMSG_HEADHUNTING_SUMMARY_INFO", {
            [index] = {
                contractCount   = tonumber(data[E_HEADHUNTING_SUMMARY_INFO.CONTRACTCOUNT] or 0),
                totalMoney      = tonumber(data[E_HEADHUNTING_SUMMARY_INFO.TOTALMONEY] or 0)
            }
        })

        self.statsFrame[index]:InitData()
    end
end

HeadHuntingSetRewardHelpBoxFrameMixin = {}

function HeadHuntingSetRewardHelpBoxFrameMixin:OnLoad()
    self:RegisterHookListener()

    self.mainFrame = HeadHuntingFrame
end

function HeadHuntingSetRewardHelpBoxFrameMixin:PLAYER_MONEY()
    self:UpdateTotalMoney()
end

function HeadHuntingSetRewardHelpBoxFrameMixin:SetStepStatus( key, status )
    self.stepFrames[key]:SetStatus(status)
end

function HeadHuntingSetRewardHelpBoxFrameMixin:UpdateContent()
    local selectedCategory = self.mainFrame:GetSelectedCategory() or E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD
    local requiredNumKills = selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD and HEADHUNTING_MIN_CONTRACT_GUILD_KILLS or HEADHUNTING_MIN_CONTRACT_PLAYER_KILLS
    local targetText       = selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD and HEADHUNTING_SET_REWARD_HELP_BOX_GUILD or HEADHUNTING_SET_REWARD_HELP_BOX_PLAYER
    local selectedText     = selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD and HEADHUNTING_SET_REWARD_HELP_BOX_STEP_2_GUILD or HEADHUNTING_SET_REWARD_HELP_BOX_STEP_2_PLAYER

    self.stepFrames["setNumKills"].Text:SetFormattedText(HEADHUNTING_SET_REWARD_HELP_BOX_STEP_3, requiredNumKills)
    self.stepFrames["search"].Text:SetFormattedText(HEADHUNTING_SET_REWARD_HELP_BOX_STEP_1, targetText)
    self.stepFrames["selectedTarget"].Text:SetText(selectedText)
end

local function ceil(num, cnt)
    cnt = math.pow(10, cnt)
    if (math.floor(num * cnt)/ cnt) % 1 > 0 then
        num = math.floor(num) + 1
    end
    return num
end

function HeadHuntingSetRewardHelpBoxFrameMixin:UpdateTotalMoney()
    local selectedCategory      = self.mainFrame:GetSelectedCategory() or E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD
    local goldPerKill           = tonumber(self:GetParent().GoldPerKillsEditBox:GetText())
    local numKills              = tonumber(self:GetParent().NumKills:GetText())
    local numKillsValidation    = false
    local totalMoney            = (numKills and goldPerKill) and ceil(numKills * goldPerKill * 1.1, 8) or 0
    local playerGold            = floor(GetMoney() / (COPPER_PER_SILVER * SILVER_PER_GOLD))
    local moneyValidation       = C_InRange(goldPerKill, HEADHUNTING_MIN_CONTRACT_GOLD_PER_KILL, HEADHUNTING_MAX_CONTRACT_GOLD_PER_KILL)
    self.moneyError             = nil

    if numKills then
        if selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
            numKillsValidation = numKills >= HEADHUNTING_MIN_CONTRACT_GUILD_KILLS
        else
            numKillsValidation = numKills >= HEADHUNTING_MIN_CONTRACT_PLAYER_KILLS
        end
    end

    if (goldPerKill and goldPerKill > 0) and not moneyValidation then
        self.moneyError = HEADHUNTING_SET_REWARD_HELP_MONEY_ERROR_2
    elseif totalMoney >= playerGold then
        self.moneyError = string.format(HEADHUNTING_SET_REWARD_HELP_MONEY_ERROR_3, totalMoney)
    end


    self:SetStepStatus("setNumKills", numKillsValidation)
    self:SetStepStatus("setGoldPerKill", goldPerKill and moneyValidation)

    self.TotalMoney:SetFormattedText(HEADHUNTING_SET_REWARD_HELP_BOX_TOTAL_MONEY, totalMoney)

    self.MoneyError:SetText(self.moneyError)
    self.MoneyError:SetShown(self.moneyError)
    self.TotalMoney:SetShown(not self.moneyError)
end

HeadHuntingSetRewardHelpBoxStepFrameMixin = {}

function HeadHuntingSetRewardHelpBoxStepFrameMixin:OnLoad()
    self.text = _G[self:GetAttribute("text")] or self:GetAttribute("text")
    self.key  = self:GetAttribute("key")

    self.Text:SetText(self.text)
    self:SetHeight(self.Text:GetHeight() + 2)

    self:SetStatus(false)

    local parent = self:GetParent()

    if not parent.stepFrames then
        parent.stepFrames = {}
    end

    parent.stepFrames[self.key] = self
end

function HeadHuntingSetRewardHelpBoxStepFrameMixin:SetStatus( status )
    local color = status and GREEN_FONT_COLOR or GRAY_FONT_COLOR

    self.Text:SetTextColor(color.r, color.g, color.b)
end

HeadHuntingContractOnPlayerFrameMixin = {}

function HeadHuntingContractOnPlayerFrameMixin:OnLoad()
    self:RegisterEventListener()

    self.mainFrame = HeadHuntingFrame

    self.Background:SetAtlas("PVPLadder-mystats-background", false, true, true)
    self.Right:SetSubTexCoord(1.0, 0.0, 0.0, 1.0)
end

function HeadHuntingContractOnPlayerFrameMixin:ToggleContractContent( isNoContract )
    local selectedCategory  = self.mainFrame:GetSelectedCategory()
    local guildName         = GetGuildInfo("player")
    local noContractText

    if selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
        if guildName then
            noContractText = HEADHUNTING_NO_CONTRACT_ON_PLAYER_GUILD
        else
            noContractText = HEADHUNTING_PLAYER_NO_GUILD
        end
    else
        noContractText = HEADHUNTING_NO_CONTRACT_ON_PLAYER
    end

    self.NoContractText:SetText(noContractText)
    self.NoContractText:SetShown(isNoContract)

    self.Background:SetDesaturated(isNoContract)
    self.Left:SetDesaturated(isNoContract)
    self.Right:SetDesaturated(isNoContract)
    self.Middle:SetDesaturated(isNoContract)

    self.PlayerFrame:SetShown(not isNoContract and selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD)
    self.GuildFrame:SetShown(not isNoContract and selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD)

    local contentStorage    = C_CacheInstance:Get("ASMSG_HEADHUNTING_CONTRACTS_ON_PLAYER", {})
    local contentData       = contentStorage[selectedCategory] and contentStorage[selectedCategory][1]

    if not contentData then
        return
    end

    if selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD then
        local playerName    = UnitName("player")
        local raceName      = UnitRace("player")
        local _, _, classID = UnitClass("player")
        local genderID      = UnitSex("player")
        local raceInfo      = C_CreatureInfo.GetRaceInfo(raceName)
        local factionID     = C_Unit:GetFactionID("player")


        self.PlayerFrame.PlayerFrame:SetPlayer(playerName, raceInfo.raceID, classID, S_GENDER_FILESTRING_INVERT[E_SEX[genderID]])
        self.PlayerFrame.ClassFrame:SetClass(classID)
        self.PlayerFrame.FactionFrame:SetFaction(factionID)

        self.PlayerFrame.RewardForKillFrame:SetMoney(contentData.moneyPerKill)
        self.PlayerFrame.TotalRewardFrame:SetMoney(contentData.moneyInBank)
    elseif selectedCategory == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
        local playerFactionTag  = UnitFactionGroup("player")
        local factionTag        = C_CacheInstance:Get("ASMSG_GUILD_TEAM", playerFactionTag)
        local teamID            = PLAYER_FACTION_GROUP[factionTag]

        self.GuildFrame.GuildFrame:SetGuild(guildName,
                PLAYER_GUILD_EMBLEM_DATA.emblemStyle or 1,
                PLAYER_GUILD_EMBLEM_DATA.emblemColor or 1,
                PLAYER_GUILD_EMBLEM_DATA.emblemBorderStyle or 1,
                PLAYER_GUILD_EMBLEM_DATA.emblemBorderColor or 1,
                PLAYER_GUILD_EMBLEM_DATA.emblemBackgroundColor or 1)

        self.GuildFrame.FactionFrame:SetFaction(teamID or 1)
        self.GuildFrame.RewardForKillFrame:SetMoney(contentData.moneyPerKill)
        self.GuildFrame.TotalRewardFrame:SetMoney(contentData.moneyInBank)
    end
end

function HeadHuntingContractOnPlayerFrameMixin:ASMSG_HEADHUNTING_CONTRACTS_ON_PLAYER( msg )
    local contractStorage       = C_Split(msg, ":")
    local responseType          = tonumber(table.remove(contractStorage, 1)) + 1

    if contractStorage[1] then
        if responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_HEAD then
            self.mainFrame:BuildPlayerInfo("ASMSG_HEADHUNTING_CONTRACTS_ON_PLAYER", E_HEADHUNTING_CONTRACT_ON_PLAYER, contractStorage[1])
        elseif responseType == E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD then
            self.mainFrame:BuildGuildInfo("ASMSG_HEADHUNTING_CONTRACTS_ON_PLAYER", E_HEADHUNTING_CONTRACT_ON_PLAYER_GUILD, contractStorage[1])
        end
    end

    self:ToggleContractContent(not contractStorage[1])
end

HeadHuntingPopupFrameMixin = {}

function HeadHuntingPopupFrameMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame

    self:SetParentArray("popupFrames")
end

function HeadHuntingPopupFrameMixin:OnHide()
    self:SetText(nil)

    self:RecalculateHeight()
end

function HeadHuntingPopupFrameMixin:SetText( text )
    self.Text:SetText(text)

    self:RecalculateHeight()
end

function HeadHuntingPopupFrameMixin:RecalculateHeight()
    local height = 32 + self.Text:GetHeight() + 8 + self.Button1:GetHeight()
    self:SetHeight(height)
end

HeadHuntingFilterDropDownMenuMixin = {}

function HeadHuntingFilterDropDownMenuMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame

    self.Text:SetJustifyH("CENTER")
    self.Button:Show()

    self.filterCategory = {
        [1] = bit.bor(HEADHUNTING_FILTER_VALUE.ALL_ONLINE, HEADHUNTING_FILTER_VALUE.ONLY_ONLINE, HEADHUNTING_FILTER_VALUE.ONLY_OFFLINE),
        [2] = bit.bor(HEADHUNTING_FILTER_VALUE.WITH_AND_WITHOUT_GUILD_CONTRACTS, HEADHUNTING_FILTER_VALUE.ONLY_GUILD_CONTRACTS, HEADHUNTING_FILTER_VALUE.ONLY_WITHOUT_GUILD_CONTRACTS),
    }

    UIDropDownMenu_Initialize(self, function(_, level) self:Init(level) end, "MENU")
end

function HeadHuntingFilterDropDownMenuMixin:OnClick( flag, menuValue )
    if bit.band(self.filterCategory[menuValue], flag) ~= 0 then
        self.mainFrame:SetFilterFlags(bit.band(self.mainFrame:GetFilterFlags(), bit.bnot(self.filterCategory[menuValue])))
    end

    self.mainFrame:SetFilterFlags(bit.bor(self.mainFrame:GetFilterFlags(), flag))
    self.mainFrame:RequestContractsList()
end

function HeadHuntingFilterDropDownMenuMixin:Init( level )
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        info.checked = 	nil
        info.isNotRadio = nil
        info.func = nil
        info.notCheckable = true
        info.keepShownOnClick = true
        info.hasArrow = true

        info.text = HEADHUNTING_FILTER_PLAYER_STATUS
        info.value = 1
        UIDropDownMenu_AddButton(info, level)

        info.text = HEADHUNTING_FILTER_HAS_GUILD_CONTRACTS
        info.value = 2
        UIDropDownMenu_AddButton(info, level)
    elseif level == 2 then
        info.hasArrow = false
        info.notCheckable = false
        info.keepShownOnClick = false

        info.func = function(_, arg1) self:OnClick(arg1, UIDROPDOWNMENU_MENU_VALUE, level)  end

        if UIDROPDOWNMENU_MENU_VALUE == 1 then
            info.text = HEADHUNTING_FILTER_STATUS_SHOW_ALL
            info.arg1 = HEADHUNTING_FILTER_VALUE.ALL_ONLINE
            info.checked = bit.band(self.mainFrame:GetFilterFlags(), HEADHUNTING_FILTER_VALUE.ALL_ONLINE) == HEADHUNTING_FILTER_VALUE.ALL_ONLINE
            UIDropDownMenu_AddButton(info, level)

            info.text = HEADHUNTING_FILTER_STATUS_ONLY_ONLINE
            info.arg1 = HEADHUNTING_FILTER_VALUE.ONLY_ONLINE
            info.checked = bit.band(self.mainFrame:GetFilterFlags(), HEADHUNTING_FILTER_VALUE.ONLY_ONLINE) == HEADHUNTING_FILTER_VALUE.ONLY_ONLINE
            UIDropDownMenu_AddButton(info, level)

            info.text = HEADHUNTING_FILTER_STATUS_ONLY_OFFLINE
            info.arg1 = HEADHUNTING_FILTER_VALUE.ONLY_OFFLINE
            info.checked = bit.band(self.mainFrame:GetFilterFlags(), HEADHUNTING_FILTER_VALUE.ONLY_OFFLINE) == HEADHUNTING_FILTER_VALUE.ONLY_OFFLINE
            UIDropDownMenu_AddButton(info, level)
        elseif UIDROPDOWNMENU_MENU_VALUE == 2 then
            info.text = HEADHUNTING_FILTER_HAS_GUILD_CONTRACTS_SHOW_ALL
            info.arg1 = HEADHUNTING_FILTER_VALUE.WITH_AND_WITHOUT_GUILD_CONTRACTS
            info.checked = bit.band(self.mainFrame:GetFilterFlags(), HEADHUNTING_FILTER_VALUE.WITH_AND_WITHOUT_GUILD_CONTRACTS) == HEADHUNTING_FILTER_VALUE.WITH_AND_WITHOUT_GUILD_CONTRACTS
            UIDropDownMenu_AddButton(info, level)

            info.text = HEADHUNTING_FILTER_ONLY_GUILD_CONTRACTS
            info.arg1 = HEADHUNTING_FILTER_VALUE.ONLY_GUILD_CONTRACTS
            info.checked = bit.band(self.mainFrame:GetFilterFlags(), HEADHUNTING_FILTER_VALUE.ONLY_GUILD_CONTRACTS) == HEADHUNTING_FILTER_VALUE.ONLY_GUILD_CONTRACTS
            UIDropDownMenu_AddButton(info, level)

            info.text = HEADHUNTING_FILTER_ONLY_WITHOUT_GUILD_CONTRACTS
            info.arg1 = HEADHUNTING_FILTER_VALUE.ONLY_WITHOUT_GUILD_CONTRACTS
            info.checked = bit.band(self.mainFrame:GetFilterFlags(), HEADHUNTING_FILTER_VALUE.ONLY_WITHOUT_GUILD_CONTRACTS) == HEADHUNTING_FILTER_VALUE.ONLY_WITHOUT_GUILD_CONTRACTS
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

HeadHuntingDropDownMenuButtonMixin = {}

function HeadHuntingDropDownMenuButtonMixin:OnClick()
    ToggleDropDownMenu(1, nil, self:GetParent().FilterDropDownMenu, self, 0, 0)

    PlaySound("igMainMenuOptionCheckBoxOn")
end

HeadHuntingSearchFrameAllTargetsPanelMixin = {}

function HeadHuntingSearchFrameAllTargetsPanelMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame

    self.SearchBox.clearButton:HookScript("OnClick", function()
        self.mainFrame:SetFilterSearchName(nil)
        self.mainFrame:RequestContractsList()
    end)

    self.SearchBox:SetWidth(self:GetWidth())
    self.SearchButton:SetHeight(22)
end

function HeadHuntingSearchFrameAllTargetsPanelMixin:Search()
    self.mainFrame:SetFilterSearchName(self.SearchBox:GetText())
    self.mainFrame:RequestContractsList()
end

HeadHuntingGuildMinimalizeFrameMixin = {}

function HeadHuntingGuildMinimalizeFrameMixin:OnLoad()
    self.mainFrame = HeadHuntingFrame

    self.ShadowBackground:SetAtlas("scoreboard-footer-horde-glow")
end

function HeadHuntingGuildMinimalizeFrameMixin:SetGuild( guildName, hasGuildContracts )
    self:SetShown(guildName)

    self.GuildName:SetText(guildName or "")
    self.ShadowBackground:SetShown(hasGuildContracts)

    self.hasGuildContracts  = hasGuildContracts
    self.guildName          = guildName
end

function HeadHuntingGuildMinimalizeFrameMixin:OnEnter()
    self:GetParent():LockHighlight()

    if not self.hasGuildContracts then
        return
    end

    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
    GameTooltip:SetText(HEADHUNTING_GUILD_WANTED_TOOLTIP, 1, 1, 1)
    GameTooltip:AddLine(HEADHUNTING_GUILD_WANTED_TOOLTIP_BODY, nil, nil, nil, true)

    GameTooltip:Show()

    self.ShadowBackground:SetAlpha(1)
    self.GuildName:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

function HeadHuntingGuildMinimalizeFrameMixin:OnLeave()
    self:GetParent():UnlockHighlight()

    if not self.hasGuildContracts then
        return
    end

    GameTooltip:Hide()

    self.ShadowBackground:SetAlpha(0.5)
    self.GuildName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end

function HeadHuntingGuildMinimalizeFrameMixin:OnMouseDown()
    if not self.hasGuildContracts then
        self:GetParent():OnClick()
        return
    end

    self.mainFrame:SelectedTab(E_HEADHUNTING_TAB.ALL_TARGETS)
    self.mainFrame:SelectedCategory(E_HEADHUNTING_CATEGORY.REWARD_FOR_GUILD, true)

    self.mainFrame.Container.AllTargetsPanel.SearchFrame.SearchBox:SetText(self.guildName)
    self.mainFrame.Container.AllTargetsPanel.SearchFrame:Search()
end