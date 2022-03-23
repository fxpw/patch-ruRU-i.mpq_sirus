--	Filename:	C_Talent.lua
--	Project:	Custom Game Interface
--	Author:		Nyll & Blizzard Entertainment

local LAST_SECOND_TALENT_GROUP

C_Talent = {}

---@param key string
---@return table cacheTable
function C_Talent.GetCache( key )
    return TALENT_CACHE:Get(key, nil)
end

---@return table specInfoCache
function C_Talent.GetSpecInfoCache()
    return C_Talent.GetCache("ASMSG_SPEC_INFO")
end

---@return number activeTalentGroup
function C_Talent.GetActiveTalentGroup()
    return C_Talent.GetSpecInfoCache() and C_Talent.GetSpecInfoCache().activeTalentGroup or 1
end

---@return number selectedTalentGroup
function C_Talent.GetSelectedTalentGroup()
    return PlayerTalentFrame.selectedTalentGroup or C_Talent.GetActiveTalentGroup()
end

---@return number numTalentGroups
function C_Talent.GetNumTalentGroups()
    return C_Talent.GetSpecInfoCache() and #C_Talent.GetSpecInfoCache().talentGroupData or 0
end

---@return number lastSecondTalentGroupID
function C_Talent.GetLastSecondTalentGroup()
    return LAST_SECOND_TALENT_GROUP

    --return TALENT_CACHE:Get("secondTalentGroupID")
end

---@param secondTalentGroupID number
function C_Talent.SetLastSecondTalentGroup( secondTalentGroupID )
    LAST_SECOND_TALENT_GROUP = secondTalentGroupID

    --TALENT_CACHE:Set("secondTalentGroupID", secondTalentGroupID)
end

---@return number selectedCurrencyID
function C_Talent.GetSelectedCurrency()
    return PlayerTalentFrame.selectedCurrencyID
end

---@param currencyID number
function C_Talent.SelectedCurrency( currencyID )
    PlayerTalentFrame.selectedCurrencyID = currencyID
end

---@return table talentPoints
function C_Talent.GetTabPointSpent( tabIndex )
    assert(tabIndex, "C_Talent.GetTabPointSpent: не указан обязательный параметр 'tabIndex'")

    local talentGroupData = C_Talent.GetSpecInfoCache().talentGroupData[tabIndex]

    assert(talentGroupData, "C_Talent.GetTabPointSpent: не найдена информация о группе талантов под индексом "..tabIndex)

    return talentGroupData
end

---@return number primaryTabIndex
function C_Talent.GetPrimaryTabIndex( pointTab1, pointTab2, pointTab3 )
    pointTab1   = tonumber(pointTab1) or 0
    pointTab2   = tonumber(pointTab2) or 0
    pointTab3   = tonumber(pointTab3) or 0

    local sortedPointTable  = {pointTab1, pointTab2, pointTab3}
    table.sort(sortedPointTable)

    local highPointsSpent   = 0
    local midPointsSpent    = sortedPointTable[2]
    local lowPointsSpent    = math.huge

    local highPointsSpentIndex
    local lowPointsSpentIndex

    for tabIndex, point in pairs({pointTab1, pointTab2, pointTab3}) do
        if point > highPointsSpent then
            highPointsSpent = point
            highPointsSpentIndex = tabIndex
        end

        if point < lowPointsSpent then
            lowPointsSpent = point
            lowPointsSpentIndex = tabIndex
        end
    end

    if ( 3*(midPointsSpent-lowPointsSpent) < 2*(highPointsSpent-lowPointsSpent) ) then
        return highPointsSpentIndex
    else
        return 0
    end
end

---@param talentGroupID number
function C_Talent.SendRequestSecondSpec( talentGroupID )
    PlayerTalentFrame.LoadingFrame:Show()

    C_Talent.SetLastSecondTalentGroup(talentGroupID)

    SendServerMessage("ACMSG_SET_SECOND_SPEC", talentGroupID)
end

---@param talentGroupID number
function C_Talent.SelectTalentGroup( talentGroupID )
    local lastSecondTalentGroupID = C_Talent.GetLastSecondTalentGroup()
    talentGroupID = talentGroupID or lastSecondTalentGroupID

    for _, button in pairs(PlayerTalentFrame.specTabs) do
        button:SetChecked(button.specIndex == talentGroupID)
        button.EtherealBorder:SetAlpha(button.specIndex == talentGroupID and 0 or 0.7)
    end

    PlayerTalentFrame.selectedTalentGroup = talentGroupID

    if C_Talent.GetActiveTalentGroup() == talentGroupID then
        selectedSpec                    = "spec1"
        PlayerTalentFrame.talentGroup   = 1

        PlayerTalentFrame.LoadingFrame:Hide()
        PlayerTalentFrame_Refresh()
    else
        selectedSpec                    = "spec2"
        PlayerTalentFrame.talentGroup   = 2

        if not lastSecondTalentGroupID or lastSecondTalentGroupID ~= talentGroupID then
            C_Talent.SendRequestSecondSpec(talentGroupID)
        else
            PlayerTalentFrame_Refresh()
        end
    end
end

---@param talentGroupID number
function C_Talent.SetActiveTalentGroup( talentGroupID )
    talentGroupID = talentGroupID or C_Talent.GetLastSecondTalentGroup()

    if talentGroupID > 2 then
        local selectedCurrencyID = C_Talent.GetSelectedCurrency()

        assert(selectedCurrencyID, "C_Talent.SetActiveTalentGroup: не указана валюта для смены группы талантов.")

        SendServerMessage("ACMSG_ACTIVATE_SPEC", talentGroupID..":"..selectedCurrencyID - 1)
    else
        SendServerMessage("ACMSG_ACTIVATE_SPEC", talentGroupID..":-1")
    end
end

enum:E_TALENT_CURRENCY {
    100584,
    100585,
}

---@param currencyID number
---@return table currencyInfo
function C_Talent.GetCurrencyInfo( currencyID )
    local currencyItemID = E_TALENT_CURRENCY[currencyID]

    assert(currencyItemID, "C_Talent.GetCurrencyInfo: не найден ItemID для валюты по currencyID "..currencyID)

    local currencyInfo = {}

    for i = 1, GetCurrencyListSize() do
        local name, _, _, _, _, count, _, _, itemID = GetCurrencyListInfo(i)

        if currencyItemID == itemID then
            currencyInfo.name   = name
            currencyInfo.count  = count
            currencyInfo.itemID = itemID

            return currencyInfo
        end
    end
end

enum:E_TALENT_SETTINGS {
    ["NAME"] = 1,
    ["TEXTURE"] = 2,
}

local EDIT_TALENT_GROUP
function C_Talent.SetEditTalentGroup(talentGroupID)
    EDIT_TALENT_GROUP = talentGroupID
end

function C_Talent.GetEditTalentGroup()
    return EDIT_TALENT_GROUP
end

function C_Talent.GetTalentGroupSettings(talentGroupID)
    local cache = TALENT_CACHE:Get("ASMSG_SPEC_INFO", {})
    local talentGroupSettings = cache.talentGroupSettings

    if type(talentGroupSettings) == "table" and talentGroupSettings[talentGroupID] then
        return talentGroupSettings[talentGroupID][E_TALENT_SETTINGS.NAME], talentGroupSettings[talentGroupID][E_TALENT_SETTINGS.TEXTURE]
    end
end

function C_Talent.SetTalentGroupSettings(name, texture)
    if EDIT_TALENT_GROUP then
        if type(name) ~= "string" then
            error("bad argument #1 to 'SetTalentGroupSettings' (Usage: C_Talent.SetTalentGroupSettings(name [, texture])) ", 2)
        end

        name = strtrim(name)
        if name == "" then
            name = nil
        end

        if texture == "Interface\\Icons\\INV_Misc_QuestionMark" then
            texture = nil
        end

        local cache = TALENT_CACHE:Get("ASMSG_SPEC_INFO", {})

        if name or texture then
            cache.talentGroupSettings = cache.talentGroupSettings or {}
            cache.talentGroupSettings[EDIT_TALENT_GROUP] = cache.talentGroupSettings[EDIT_TALENT_GROUP] or {}
            cache.talentGroupSettings[EDIT_TALENT_GROUP][E_TALENT_SETTINGS.NAME] = name
            cache.talentGroupSettings[EDIT_TALENT_GROUP][E_TALENT_SETTINGS.TEXTURE] = texture
        elseif cache.talentGroupSettings then
            cache.talentGroupSettings[EDIT_TALENT_GROUP] = nil

            if not next(cache.talentGroupSettings) then
                cache.talentGroupSettings = nil
            end
        end

        EDIT_TALENT_GROUP = nil
    end
end

-- Переопределение дефолтных методов для работы с талантами.
-- Необходимо для корректной работы аддонов и интерфейса в целом.

---@return number
function GetNumTalentGroups()
    return C_Talent.GetNumTalentGroups()
end

---@return number
function GetActiveTalentGroup()
    return 1
end
