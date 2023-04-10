local GetNumTalentGroups = GetNumTalentGroups
local GetActiveTalentGroup = GetActiveTalentGroup

local SELECTED_TALENT_GROUP
local SELECTED_CURRENCY_ID
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
function C_Talent.GetActiveTalentGroup(isInspect, isPet)
	if isInspect or isPet then
		return GetActiveTalentGroup(isInspect, isPet)
	end

	local specInfo = C_Talent.GetSpecInfoCache()
	return specInfo and specInfo.activeTalentGroup or 1
end

---@return number numTalentGroups
function C_Talent.GetNumTalentGroups(isInspect, isPet)
	if isInspect or isPet then
		return GetNumTalentGroups(isInspect, isPet)
	end

	local specInfo = C_Talent.GetSpecInfoCache()
	return specInfo and #specInfo.talentGroupData or 0
end

---@return number selectedTalentGroup
function C_Talent.GetSelectedTalentGroup()
	return SELECTED_TALENT_GROUP or C_Talent.GetActiveTalentGroup()
end

---@return number lastSecondTalentGroupID
function C_Talent.GetLastSecondTalentGroup()
	return LAST_SECOND_TALENT_GROUP
end

---@param secondTalentGroupID number
function C_Talent.SetLastSecondTalentGroup(secondTalentGroupID)
	LAST_SECOND_TALENT_GROUP = secondTalentGroupID
end

---@return number selectedCurrencyID
function C_Talent.GetSelectedCurrency()
	return SELECTED_CURRENCY_ID
end

---@param currencyID number
function C_Talent.SelectedCurrency(currencyID)
	SELECTED_CURRENCY_ID = currencyID
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
	LAST_SECOND_TALENT_GROUP = talentGroupID
    SendServerMessage("ACMSG_SET_SECOND_SPEC", talentGroupID)
end

---@param talentGroupID? number
function C_Talent.SelectTalentGroup(talentGroupID)
	if not talentGroupID then
		talentGroupID = LAST_SECOND_TALENT_GROUP
	end

    for _, button in pairs(PlayerTalentFrame.specTabs) do
        button:SetChecked(button.specIndex == talentGroupID)
        button.EtherealBorder:SetAlpha(button.specIndex == talentGroupID and 0 or 0.7)
    end

	SELECTED_TALENT_GROUP = talentGroupID

    if C_Talent.GetActiveTalentGroup() == talentGroupID then
        selectedSpec                    = "spec1"
        PlayerTalentFrame.talentGroup   = 1

        PlayerTalentFrame.LoadingFrame:Hide()
        PlayerTalentFrame_Refresh()
    else
        selectedSpec                    = "spec2"
        PlayerTalentFrame.talentGroup   = 2

		if not LAST_SECOND_TALENT_GROUP or LAST_SECOND_TALENT_GROUP ~= talentGroupID then
            C_Talent.SendRequestSecondSpec(talentGroupID)
        else
            PlayerTalentFrame_Refresh()
        end
    end
end

---@param talentGroupID? number
function C_Talent.SetActiveTalentGroup(talentGroupID)
	if not talentGroupID then
		talentGroupID = LAST_SECOND_TALENT_GROUP
	end

	if talentGroupID > 2 then
		assert(SELECTED_CURRENCY_ID, "C_Talent.SetActiveTalentGroup: не указана валюта для смены группы талантов.")
		SendServerMessage("ACMSG_ACTIVATE_SPEC", string.format("%i:%i", talentGroupID, SELECTED_CURRENCY_ID - 1))
	else
		SendServerMessage("ACMSG_ACTIVATE_SPEC", string.format("%i:%i", talentGroupID, -1))
	end
end

enum:E_TALENT_CURRENCY {
    100584,
    100585,
}

---@param currencyID number
---@return table? currencyInfo
function C_Talent.GetCurrencyInfo( currencyID )
    local currencyItemID = E_TALENT_CURRENCY[currencyID]

    assert(currencyItemID, "C_Talent.GetCurrencyInfo: не найден ItemID для валюты по currencyID "..currencyID)

	local currencyName, currencyCount, headerIndex, headerExpandEndIndex
	local numCurrencies = GetCurrencyListSize()
	local index = 1

	while index <= numCurrencies do
		local name, isHeader, isExpanded, _, _, count, _, _, itemID = GetCurrencyListInfo(index)

		if isHeader and not isExpanded then
			ExpandCurrencyList(index, 1)
			local newNum = GetCurrencyListSize()
			headerIndex = index
			headerExpandEndIndex = index + (newNum - numCurrencies)
			numCurrencies = newNum
		elseif currencyItemID == itemID then
			currencyName = name
			currencyCount = count
			break
		elseif index == headerExpandEndIndex then
			ExpandCurrencyList(headerIndex, 0)
			numCurrencies = numCurrencies - (headerExpandEndIndex - headerIndex)
			index = headerIndex
			headerIndex = nil
			headerExpandEndIndex = nil
		end

		index = index + 1
	end

	if headerIndex then
		ExpandCurrencyList(headerIndex, 0)
	end

	if currencyName then
		return {
			name	= currencyName,
			count	= currencyCount,
			itemID	= currencyItemID,
		}
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

---@return number
_G.GetNumTalentGroups = function(isInspect, isPet)
	return C_Talent.GetNumTalentGroups(isInspect, isPet)
end

---@return number
_G.GetActiveTalentGroup = function(isInspect, isPet)
	if isInspect or isPet then
		return GetActiveTalentGroup(isInspect, isPet)
	end
	return 1
end