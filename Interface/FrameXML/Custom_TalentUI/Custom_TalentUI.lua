--	Filename:	Sirus_TalentUI.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

TALENT_CACHE = C_Cache("SIRUS_TALENT_CACHE_V2", true)

StaticPopupDialogs["CONFIRM_LEARN_PREVIEW_TALENTS"] = {
    text         = CONFIRM_LEARN_PREVIEW_TALENTS,
    button1      = YES,
    button2      = NO,
    OnAccept     = function(_)
        LearnPreviewTalents(PlayerTalentFrame.pet);
    end,
    OnCancel     = function(_)
    end,
    hideOnEscape = 1,
    timeout      = 0,
    exclusive    = 1,
}

UIPanelWindows["PlayerTalentFrame"]                 = { area = "left", pushable = 1, whileDead = 1, xOffset = "15", yOffset = "-10" };


-- global constants
TALENTS_TAB                                         = 1
PET_TALENTS_TAB                                     = 2
GLYPH_TALENT_TAB                                    = 3
NUM_TALENT_FRAME_TABS                               = 3

RESET_TALENTS_OK                                    = 0
RESET_TALENTS_NO_USED_TALENT_POINTS                 = 1
RESET_TALENTS_NO_MONEY                              = 2
RESET_TALENTS_NOT_IN_REST_ZONE                      = 3

NUM_TALENT_POPUP_ICONS_SHOWN = 35
NUM_TALENT_POPUP_ICONS_PER_ROW = 5
NUM_TALENT_POPUP_ICON_ROWS = 7
TALENT_POPUP_ICON_ROW_HEIGHT = 36

-- speed references
local next                                          = next;
local ipairs                                        = ipairs;

-- local data
local specs                                         = {
    ["spec1"]    = {
        name               = TALENT_SPEC_PRIMARY,
        talentGroup        = 1,
        unit               = "player",
        pet                = false,
        tooltip            = TALENT_SPEC_PRIMARY,
        portraitUnit       = "player",
        defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
        hasGlyphs          = true,
        glyphName          = TALENT_SPEC_PRIMARY_GLYPH,
    },
    ["spec2"]    = {
        name               = TALENT_SPEC_SECONDARY,
        talentGroup        = 2,
        unit               = "player",
        pet                = false,
        tooltip            = TALENT_SPEC_SECONDARY,
        portraitUnit       = "player",
        defaultSpecTexture = "Interface\\Icons\\Ability_Marksmanship",
        hasGlyphs          = true,
        glyphName          = TALENT_SPEC_SECONDARY_GLYPH,
    },
    ["petspec1"] = {
        name               = TALENT_SPEC_PET_PRIMARY,
        talentGroup        = 1,
        unit               = "pet",
        tooltip            = TALENT_SPEC_PET_PRIMARY,
        pet                = true,
        portraitUnit       = "pet",
        defaultSpecTexture = nil,
        hasGlyphs          = false,
        glyphName          = nil,
    },
};

local specTabs                                      = { };    -- filled in by PlayerSpecTab_OnLoad
local numSpecTabs                                   = 0;
selectedSpec                                        = nil
local activeSpec;


-- cache talent info so we can quickly display cool stuff like the number of points spent in each tab
local talentSpecInfoCache                           = {
    ["spec1"]    = { },
    ["spec2"]    = { },
    ["petspec1"] = { },
};
-- cache talent tab widths so we can resize tabs to fit for localization
local talentTabWidthCache                           = { };



-- ACTIVESPEC_DISPLAYTYPE values:
-- "BLUE", "GOLD_INSIDE", "GOLD_BACKGROUND"
local ACTIVESPEC_DISPLAYTYPE;

-- SELECTEDSPEC_DISPLAYTYPE values:
-- "BLUE", "GOLD_INSIDE", "PUSHED_OUT", "PUSHED_OUT_CHECKED"
local SELECTEDSPEC_DISPLAYTYPE                      = "GOLD_INSIDE";
local SELECTEDSPEC_OFFSETX;
if (SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT" or SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT_CHECKED") then
    SELECTEDSPEC_OFFSETX = 5;
else
    SELECTEDSPEC_OFFSETX = 0;
end

SIRUS_TALENT_CACHE     = {}
local talentPattern    = "0zMcmVokRsaqbdrfwihuGINALpTjnyxtgevElBCDFHJKOPQSUWXYZ123456789"
local classAssociation = {
    ["z"]           = "WARRIOR",
    ["M"]           = "PALADIN",
    ["c"]           = "HUNTER",
    ["m"]           = "ROGUE",
    ["V"]           = "PRIEST",
    ["o"]           = "DEATHKNIGHT",
    ["k"]           = "SHAMAN",
    ["R"]           = "MAGE",
    ["s"]           = "WARLOCK",
    ["q"]           = "DRUID",
    ["WARRIOR"]     = "z",
    ["PALADIN"]     = "M",
    ["HUNTER"]      = "c",
    ["ROGUE"]       = "m",
    ["PRIEST"]      = "V",
    ["DEATHKNIGHT"] = "o",
    ["SHAMAN"]      = "k",
    ["MAGE"]        = "R",
    ["WARLOCK"]     = "s",
    ["DRUID"]       = "q"
}

function GetTalentHyperlinkInfo(link)
    wipe(SIRUS_TALENT_CACHE)
    SIRUS_TALENT_CACHE.talentData = {}

    local linkData                = C_Split(link, ":")
    link                          = linkData[2]

    if linkData[3] then
        SIRUS_TALENT_CACHE.playerName = linkData[3]
    end

    local talentData, glyphData          = unpack(C_Split(link, "."))
    local classfile, spec1, spec2, spec3 = strsplit("Z", talentData)
    local talentSpec                     = { classfile, spec1, spec2, spec3 }

    if talentSpec and #talentSpec > 1 then
        local className = classAssociation[table.remove(talentSpec, 1)]

        if not className then
            return
        end

        SIRUS_TALENT_CACHE.className = className

        for i = 1, #talentSpec do
            local data = talentSpec[i]

            if not SIRUS_TALENT_CACHE.talentData[i] then
                SIRUS_TALENT_CACHE.talentData[i] = {}
            end

            for point = 1, strlenutf8(data) do
                local letter           = string.sub(data, point, point)
                local talent1, talent2 = TalentLetterDecode(letter)

                table.insert(SIRUS_TALENT_CACHE.talentData[i], talent1)
                table.insert(SIRUS_TALENT_CACHE.talentData[i], talent2)
            end
        end

        if glyphData and #glyphData > 0 then
            local glyphMajorData, glyphMinorData = strsplit("Z", glyphData)

            local glyphMajorList                 = glyphMajorData and C_Split(glyphMajorData, ";") or nil
            local glyphMinorList                 = glyphMinorData and C_Split(glyphMinorData, ";") or nil

            if not SIRUS_TALENT_CACHE.glyphData then
                SIRUS_TALENT_CACHE.glyphData    = {}
                SIRUS_TALENT_CACHE.glyphData[1] = {}
                SIRUS_TALENT_CACHE.glyphData[2] = {}
            end

            for i = 1, 3 do
                if glyphMajorList then
                    local glyphID = glyphMajorList[i]

                    if glyphID then
                        table.insert(SIRUS_TALENT_CACHE.glyphData[1], tonumber(glyphID))
                    end
                end
            end

            for i = 1, 3 do
                if glyphMinorList then
                    local glyphID = glyphMinorList[i]

                    if glyphID then
                        table.insert(SIRUS_TALENT_CACHE.glyphData[2], tonumber(glyphID))
                    end
                end
            end
        end
    end

    local _, classFileName = UnitClass("player")
    if classFileName == SIRUS_TALENT_CACHE.className then
        TalentFramePreviewShow()
    else
        StaticPopup_Show("PLAYER_TALENT_PREVIEW_CLASS_ERROR", GetClassColorObj(SIRUS_TALENT_CACHE.className):WrapTextInColorCode(LOCALIZED_CLASS_NAMES_MALE[SIRUS_TALENT_CACHE.className]))
    end
end

function TalentLetterDecode(letter)
    local point = (string.find(talentPattern, letter) - 1)

    if point then
        local value1 = point % 6
        local value2 = (point - value1) / 6

        return value2, value1
    end

    return nil
end

function TalentPreviewExport()
    local buffer                      = {}
    local specPointSpent              = {}

    buffer.talentData                 = {}
    buffer.glyphData                  = {}
    buffer.glyphData[GLYPHTYPE_MAJOR] = {}
    buffer.glyphData[GLYPHTYPE_MINOR] = {}

    for talentTree = 1, 3 do
        local _, _, pointsSpent, _, previewPointsSpent = GetTalentTabInfo(talentTree, PlayerTalentFrame.inspect, PlayerTalentFrame.pet, GetActiveTalentGroup())
        specPointSpent[talentTree]                     = (pointsSpent + previewPointsSpent)

        buffer.talentData[talentTree]                  = ""

        for talentIndex = 1, 40 do
            local _, _, _, _, rank, _, _, _, _, _ = GetTalentInfo(talentTree, talentIndex, PlayerTalentFrame.inspect, PlayerTalentFrame.pet, GetActiveTalentGroup())
            buffer.talentData[talentTree]         = buffer.talentData[talentTree] .. rank
        end

        for i = strlenutf8(buffer.talentData[talentTree]), 1, -1 do
            local number = tonumber(string.sub(buffer.talentData[talentTree], i, i))
            if number ~= 0 then
                buffer.talentData[talentTree] = string.sub(buffer.talentData[talentTree], 1, i)
                break
            end
        end

        if strlenutf8(buffer.talentData[talentTree]) == 40 then
            buffer.talentData[talentTree] = ""
        end

        if strlenutf8(buffer.talentData[talentTree]) ~= 0 then
            local patternBuffer = ""

            for i = 1, strlenutf8(buffer.talentData[talentTree]), 2 do
                local couple          = string.sub(buffer.talentData[talentTree], i, i + 1)
                local coupleNumber    = { string.sub(couple, 1, 1), string.sub(couple, 2, 2) == "" and "0" or string.sub(couple, 2, 2) }

                local patternPosition = ((coupleNumber[1] * 6) + coupleNumber[2]) + 1
                local pattern         = string.sub(talentPattern, patternPosition, patternPosition)

                patternBuffer         = patternBuffer .. pattern
            end

            buffer.talentData[talentTree] = patternBuffer
        end
    end

    for i = 1, 6 do
        local _, glyphType, glyphSpell, _ = GetGlyphSocketInfo(i, GetActiveTalentGroup())

        if glyphSpell and glyphType then
            table.insert(buffer.glyphData[glyphType], glyphSpell)
        end
    end

    local glyphMajorString = ""
    if #buffer.glyphData[GLYPHTYPE_MAJOR] > 0 then
        glyphMajorString = table.concat(buffer.glyphData[GLYPHTYPE_MAJOR], ";")
    end

    local glyphMinorString = ""
    if #buffer.glyphData[GLYPHTYPE_MINOR] > 0 then
        glyphMinorString = "Z" .. table.concat(buffer.glyphData[GLYPHTYPE_MINOR], ";")
    end

    local glyphString = ""
    if glyphMajorString ~= "" or glyphMinorString ~= "" then
        glyphString = string.format(".%s%s", glyphMajorString, glyphMinorString)
    end

    local _, classFileName = UnitClass("player")
    local encodeString     = string.format("%sZ%sZ%sZ%s%s", classAssociation[classFileName], buffer.talentData[1], buffer.talentData[2], buffer.talentData[3], glyphString)

    local selectedTalentGroup = C_Talent.GetSelectedTalentGroup()
    local primaryTab          = ""

    if selectedTalentGroup then
        local pointSpent        = C_Talent.GetTabPointSpent(selectedTalentGroup)
        local primaryTabIndex   = C_Talent.GetPrimaryTabIndex(unpack(pointSpent))

        primaryTab = GetTalentTabInfo(primaryTabIndex, false, false, 1)
    end

    return encodeString, classFileName, primaryTab, unpack(specPointSpent)
end

function TalentImportGenerateHyperlink()
    local url, classFileName, primaryTab, pointsSpent1, pointsSpent2, pointsSpent3 = TalentPreviewExport()
    if pointsSpent1 == 0 and pointsSpent2 == 0 and pointsSpent3 == 0 then
        return
    end
    local playerName            = UnitName("player")
    local playerGender          = UnitSex("player")
    local classLocalizationName = playerGender == 2 and LOCALIZED_CLASS_NAMES_MALE[classFileName] or LOCALIZED_CLASS_NAMES_FEMALE[classFileName]

    return string.format("%s|Htalents:%s:%s|h[%s:%d/%d/%d]|h|r", GetClassColorObj(classFileName):GenerateHexColorMarkup(), url, playerName, primaryTab or classLocalizationName, pointsSpent1, pointsSpent2, pointsSpent3)
end

function TalentImportGenerateEscapeHyperlink()
    local url, classFileName, primaryTab, pointsSpent1, pointsSpent2, pointsSpent3 = TalentPreviewExport()
    if pointsSpent1 == 0 and pointsSpent2 == 0 and pointsSpent3 == 0 then
        return
    end
    local playerName = UnitName("player")
    return string.format("\\124c%s\\124Htalents:%s:%s\\124h[%s:%d/%d/%d]\\124h\\124r", GetClassColorObj(classFileName):GenerateHexColor(), url, playerName, primaryTab, pointsSpent1, pointsSpent2, pointsSpent3)
end

local toggleElements = {
    -- "PlayerTalentFrameLearnButton",
    "PlayerTalentFrameResetButton",
    "PlayerTalentFrameTab1",
    "PlayerTalentFrameTab2",
    "PlayerTalentFrameTab3"
}

function TalentFramePreviewShow()
    PlayerTalentFrame.pointSprent = 0

    for i = 1, 3 do
        local _, _, pointsSpent, _, previewPointsSpent = GetTalentTabInfo(i, PlayerTalentFrame.inspect, PlayerTalentFrame.pet, 1)
        PlayerTalentFrame.pointSprent                  = PlayerTalentFrame.pointSprent + (pointsSpent + previewPointsSpent)
    end

    PlayerTalentFrame.previewState = true

    PlayerGlyphPreviewFrame_OnShow(PlayerGlyphPreviewFrame)

    SendServerMessage("ACMSG_PLAYER_FAKE_TALENTS", 1)
end

function ParceTalentImportURL(url)
    local link = string.match(url, "talents#(.*)")
    if link then
        GetTalentHyperlinkInfo("talents:" .. link)
    else
        UIErrorsFrame:AddMessage(ERR_TALENTS_IMPORT_URL, 1.0, 0.1, 0.1, 1.0)
    end
end

function PlayerTalentExportGenerateURL()
    local url = TalentPreviewExport()
    return string.format("https://sirus.su/base/talents#%s", url)
end

function PlayerTalentLinkToButton_OnClick(self, ...)
    local link = TalentImportGenerateHyperlink()
    if link then
        if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
            local text = MacroFrameText:GetText() .. link
            if strlenutf8(text) <= MacroFrameText:GetMaxLetters() then
                MacroFrameText:Insert(link)
            end
        else
            local activeEditBox = ChatEdit_GetActiveWindow()
            if activeEditBox then
                ChatEdit_InsertLink(link)
            else
                ToggleDropDownMenu(1, nil, self:GetParent().LinkToDropDown, self, 25, 25)
            end
        end
    end
end

function PlayerTalentLinkToDropDownInit(_, _)
    local info        = UIDropDownMenu_CreateInfo()
    local channels    = { GetChannelList() }

    info.text         = TRADESKILL_POST
    info.isTitle      = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    info.isTitle      = nil
    info.notCheckable = true
    info.func         = function(_, channel)
        local link = TalentImportGenerateHyperlink()

        if link then
            ChatFrame_OpenChat(channel .. " " .. link, DEFAULT_CHAT_FRAME)
        end
    end

    info.text         = GUILD
    info.arg1         = SLASH_GUILD1
    info.disabled     = not IsInGuild()
    UIDropDownMenu_AddButton(info)

    info.text     = PARTY
    info.arg1     = SLASH_PARTY1
    info.disabled = GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0
    UIDropDownMenu_AddButton(info)

    info.text     = RAID
    info.disabled = GetRealNumPartyMembers() == 0 and GetRealNumRaidMembers() == 0
    info.arg1     = SLASH_RAID1
    UIDropDownMenu_AddButton(info)

    info.disabled = false

    for i = 1, #channels, 2 do
        local name = Chat_GetChannelShortcutName(channels[i])
        info.text  = name
        info.arg1  = "/" .. channels[i]
        UIDropDownMenu_AddButton(info)
    end

    UIDropDownMenu_AddSeparator(info)

    info              = UIDropDownMenu_CreateInfo()
    info.text         = OTHER
    info.isTitle      = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)
    info.isTitle  = nil

    info.text     = TALENT_GET_URL_ADRESS_DROPDOWN_TITLE
    info.disabled = false
    info.func     = function()
        StaticPopup_Show("TALENTS_EXPORT_URL_POPUP")
    end
    UIDropDownMenu_AddButton(info)

    info.text     = TALENT_GET_HYPERLINK_DROPDOWN_TITLE
    info.disabled = false
    info.func     = function()
        StaticPopup_Show("TALENTS_EXPORT_INGAMELINK_POPUP")
    end
    UIDropDownMenu_AddButton(info)
end

function TalentFramePreviewHide(skippServerMessage)
    PlayerTalentFrame.previewState = false
    if not skippServerMessage then
        SendServerMessage("ACMSG_PLAYER_FAKE_TALENTS", 0)
    end

    PlayerGlyphPreviewFrame:Hide()
end

function PlayerGlyphPreviewFrame_OnShow(_, ...)
    if SIRUS_TALENT_CACHE.glyphData and SIRUS_TALENT_CACHE.glyphData[1] and SIRUS_TALENT_CACHE.glyphData[2] then
        for i = 1, 3 do
            local majorGlyphID = SIRUS_TALENT_CACHE.glyphData[1][i]
            local majorframe   = _G["PlayerGlyphPreviewFrameMajorSlot" .. i]

            local minorGlyphID = SIRUS_TALENT_CACHE.glyphData[2][i]
            local minorframe   = _G["PlayerGlyphPreviewFrameMinorSlot" .. i]

            if majorframe then
                if majorGlyphID then
                    local name, _, icon, _, _, _, _, _, _ = GetSpellInfo(majorGlyphID)

                    majorframe.spellID                    = majorGlyphID

                    majorframe.Name:SetText(name)
                    majorframe.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
                    SetItemButtonTexture(majorframe, icon)
                    SetItemButtonTextureVertexColor(majorframe, 1, 1, 1)
                else
                    majorframe.spellID = nil

                    majorframe.Name:SetText(EMPTY)
                    majorframe.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
                    SetItemButtonTexture(majorframe, "Interface\\PaperDoll\\UI-PaperDoll-Slot-Back")
                    SetItemButtonTextureVertexColor(majorframe, 0.5, 0.5, 0.5)
                end
            end

            if minorframe then
                if minorGlyphID then
                    local name, _, icon, _, _, _, _, _, _ = GetSpellInfo(minorGlyphID)

                    minorframe.spellID                    = minorGlyphID

                    minorframe.Name:SetText(name)
                    minorframe.Name:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
                    SetItemButtonTexture(minorframe, icon)
                    SetItemButtonTextureVertexColor(minorframe, 1, 1, 1)
                else
                    minorframe.spellID = nil

                    minorframe.Name:SetText(EMPTY)
                    minorframe.Name:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
                    SetItemButtonTexture(minorframe, "Interface\\PaperDoll\\UI-PaperDoll-Slot-Back")
                    SetItemButtonTextureVertexColor(minorframe, 0.5, 0.5, 0.5)
                end
            end
        end
    end
end

function TalentFrameSetupPreviewTalents()
    if SIRUS_TALENT_CACHE and SIRUS_TALENT_CACHE.talentData then
        for i = 1, 3 do
            local data = SIRUS_TALENT_CACHE.talentData[i]

            if data and #data > 0 then
                for t = 1, #data do
                    local talentCount = data[t]
                    AddPreviewTalentPoints(i, t, talentCount)
                end
            end
        end
    end
end

function GenerateTalentPreviewData()
    local buffer = {}

    if SIRUS_TALENT_CACHE and SIRUS_TALENT_CACHE.talentData then
        for i = 1, 3 do
            local data = SIRUS_TALENT_CACHE.talentData[i]

            buffer[i]  = {}

            if data and #data > 0 then
                for t = 1, #data do
                    local talentCount = data[t]
                    if talentCount > 0 then
                        table.insert(buffer[i], { t, talentCount })
                    end
                end
            end
        end
    end

    return buffer
end

local talentData
function PlayerTalentFrame_OnUpdate(self, elapsed, ...)
    if PlayerTalentFrame.learnPreviewTalentsAnimation then
        self.elapsed = self.elapsed + elapsed

        if self.elapsed > 0.070 then
            if not PlayerTalentFrame.learnPreviewData[self.removeSpecKey] then
                self.removeSpecKey                             = 1
                self.elapsed                                   = 0

                PlayerTalentFrame.learnPreviewTalentsAnimation = nil
                LearnPreviewTalents(false)
                return
            end

            talentData = table.remove(PlayerTalentFrame.learnPreviewData[self.removeSpecKey], 1)

            if talentData then
                RunTalentLearnAnim(_G["PlayerTalentFramePanel" .. self.removeSpecKey .. "Talent" .. talentData[1] .. ""])
                AddPreviewTalentPoints(self.removeSpecKey, talentData[1], talentData[2])
            else
                if self.removeSpecKey < 4 then
                    self.removeSpecKey = self.removeSpecKey + 1
                end
            end
            self.elapsed = 0
        end
    end

    if C_Talent.GetSelectedTalentGroup() > 2 then
        local selectedCurrency = C_Talent.GetSelectedCurrency()

        if selectedCurrency then
            local currencyInfo = C_Talent.GetCurrencyInfo(selectedCurrency)

            PlayerTalentFrameActivateButton:SetEnabled(currencyInfo and currencyInfo.count > 0)
            PlayerTalentFrameActivateButton.disabledReason = TALENTS_ACTIVE_BUTTON_DISABLE_REASON_1
        else
            PlayerTalentFrameActivateButton:Disable()
            PlayerTalentFrameActivateButton.disabledReason = TALENTS_ACTIVE_BUTTON_DISABLE_REASON_1 -- TALENTS_ACTIVE_BUTTON_DISABLE_REASON_2
        end
    else
        PlayerTalentFrameActivateButton:Enable()
    end
end

function RunTalentLearnAnim(self)
    self.CrestSparks.RuneAnim:Play()
    self.CrestSparks.RuneAnim:Play()
    self.CrestGlowies.RuneAnim:Play()
    self.CrestGlowies2.RuneAnim:Play()
    self.CrestGlowies3.RuneAnim:Play()
    self.CrestGlowies4.RuneAnim:Play()
    self.CrestGlowies5.RuneAnim:Play()
    self.CrestGlowies6.RuneAnim:Play()

    self.CrestRune1.RuneAnim:Play()
    self.GlowBorderAnim.RuneAnim:Play()
end

function GetNumTalentPoints()
    local unspentTalentPoints = GetUnspentTalentPoints() - GetGroupPreviewTalentPointsSpent()
    local spentTalentPoints   = 0
    for i = 1, 3 do
        local _, _, pointsSpent, _, previewPointsSpent = GetTalentTabInfo(i)
        spentTalentPoints                              = spentTalentPoints + (pointsSpent - previewPointsSpent)
    end

    return spentTalentPoints + unspentTalentPoints
end

function PlayerTalentFrameResetCVar()
    PlayerTalentFrame_Update()
end

function PlayerTalentFrame_Toggle(pet)
    local hidden;
    local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame);
    
    if (not PlayerTalentFrame:IsShown()) then
        ShowUIPanel(PlayerTalentFrame);
        hidden = false;
    else
        if not PlayerTalentFrame.previewState then
            if (selectedTab == TALENTS_TAB and not pet) then
                -- if a talent tab is selected then toggle the frame off
                HideUIPanel(PlayerTalentFrame);
                hidden = true;
            elseif (selectedTab == PET_TALENTS_TAB and pet) then
                HideUIPanel(PlayerTalentFrame);
                hidden = true;
            elseif selectedTab == GLYPH_TALENT_TAB then
                HideUIPanel(PlayerTalentFrame);
                hidden = true;
            else
                hidden = false;
            end
        else
            hidden = false
        end
    end
end

function PlayerTalentFrame_Open(talentGroup)
    ShowUIPanel(PlayerTalentFrame);

    -- Show the talents tab
    PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab" .. TALENTS_TAB]);

    -- open the spec with the requested talent group
    for index, spec in next, specs do
        if (spec.talentGroup == talentGroup) then
            PlayerSpecTab_OnClick(specTabs[index]);
            break ;
        end
    end
end

function PlayerTalentFrame_ToggleGlyphFrame(suggestedTalentGroup)
    GlyphFrame_LoadUI();
    if (GlyphFrame) then
        local hidden;
        if (not PlayerTalentFrame:IsShown()) then
            ShowUIPanel(PlayerTalentFrame);
            hidden = false;
        else
            local spec = selectedSpec and specs[selectedSpec];
            if (spec and spec.hasGlyphs and
                    PanelTemplates_GetSelectedTab(PlayerTalentFrame) == GLYPH_TALENT_TAB) then
                -- if the glyph tab is selected then toggle the frame off
                HideUIPanel(PlayerTalentFrame);
                hidden = true;
            else
                hidden = false;
            end
        end
        if (not hidden) then
            -- open the spec with the requested talent group (or the current talent group if the selected
            -- spec has one)
            if (selectedSpec) then
                local spec = specs[selectedSpec];
                if (spec.hasGlyphs) then
                    suggestedTalentGroup = spec.talentGroup;
                end
            end
            for _, index in ipairs(TALENT_SORT_ORDER) do
                local spec = specs[index];
                if (spec.hasGlyphs and spec.talentGroup == suggestedTalentGroup) then
                    PlayerSpecTab_OnClick(specTabs[index]);
                    break ;
                end
            end
        end
    end
end

function PlayerTalentFrame_OpenGlyphFrame(talentGroup)
    GlyphFrame_LoadUI();
    if (GlyphFrame) then
        ShowUIPanel(PlayerTalentFrame);
        -- open the spec with the requested talent group
        PlayerSpecTab_OnClick(PlayerTalentFrame.specTabs[talentGroup])
    end
end

function PlayerTalentFrame_ShowGlyphFrame()
    GlyphFrame_LoadUI();
    if (GlyphFrame) then
        -- show/update the glyph frame
        if (GlyphFrame:IsShown()) then
            GlyphFrame_Update();
        else
            GlyphFrame:Show();
        end
    end
end

function PlayerTalentFrame_HideGlyphFrame()
    if (not GlyphFrame or not GlyphFrame:IsShown()) then
        return ;
    end

    GlyphFrame_LoadUI();
    if (GlyphFrame) then
        GlyphFrame:Hide();
    end
end

function PlayerTalentFrame_OnLoad(self)
    self.specTabs = {}

    self:RegisterEvent("VARIABLES_LOADED")
end

function PlayerTalentFramePanel_OnLoad(self)
    self.inspect          = false;
    self.talentGroup      = 1;
    self.talentButtonSize = 30;
    self.initialOffsetX   = 20;
    self.initialOffsetY   = 50;
    self.buttonSpacingX   = 46;
    self.buttonSpacingY   = 40;
    self.arrowInsetX      = 2;
    self.arrowInsetY      = 2;

    TalentFrame_Load(self);
end

local TalentFrameCloseTime
function PlayerTalentFrame_OnShow(self)
    PlayerFrame_UpdateSpecTabs(self)

    local currentTime = time()

    if (not TalentFrameCloseTime or currentTime - TalentFrameCloseTime >= S_RESET_FRAME_STATE_TIME) then
        self.secureLastTabIndex = nil
    end

    local lastTab = _G["PlayerTalentFrameTab1"]

    if (self.secureLastTabIndex) then
        lastTab = _G["PlayerTalentFrameTab" .. self.secureLastTabIndex]
    end

    if not self.advertisingButton then
        self.advertisingButton = CreateFrame("CheckButton", "PlayerSpecTabAdvertising", self, "PlayerSpecTabAdvertisingTemplate")
    end

    self.advertisingButton:ClearAndSetPoint("TOPLEFT", self.specTabs[#self.specTabs], "BOTTOMLEFT", 0, -22)
    self.advertisingButton:SetShown(false) -- #self.specTabs < 3

    -- Stop buttons from flashing after skill up
    SetButtonPulse(TalentMicroButton, 0, 1);

    PlaySound("TalentScreenOpen");
    UpdateMicroButtons();

    C_Talent.SelectTalentGroup(C_Talent.GetActiveTalentGroup())

    -- Set flag
    if (not GetCVarBool("talentFrameShown")) then
        SetCVar("talentFrameShown", 1);
        -- UIFrameFlash(PlayerTalentFrameScrollButtonOverlay, 0.5, 0.5, 60);
    end

    PlayerTalentFramePanel1.ShadowFrame:Hide()
    PlayerTalentFramePanel1.Summary:Hide()
    --
    PlayerTalentFramePanel1.Summary.needAnimation     = false
    PlayerTalentFramePanel1.Summary.elapsed           = 0
    PlayerTalentFramePanel1.Summary.isHiddenAnimation = false

    PlayerTalentFramePanel2.ShadowFrame:Hide()
    PlayerTalentFramePanel2.Summary:Hide()
    --
    PlayerTalentFramePanel2.Summary.needAnimation     = false
    PlayerTalentFramePanel2.Summary.elapsed           = 0
    PlayerTalentFramePanel2.Summary.isHiddenAnimation = false

    PlayerTalentFramePanel3.ShadowFrame:Hide()
    PlayerTalentFramePanel3.Summary:Hide()
    --
    PlayerTalentFramePanel3.Summary.needAnimation     = false
    PlayerTalentFramePanel3.Summary.elapsed           = 0
    PlayerTalentFramePanel3.Summary.isHiddenAnimation = false
    --PlayerTalentTab_OnClick(lastTab)
end

function PlayerTalentFrame_OnHide( self )
    PanelTemplates_SetTab(PlayerTalentFrame, 1)

    TalentFrameCloseTime = time()

    UpdateMicroButtons();
    PlaySound("TalentScreenClose");

    if PlayerTalentFrame.learnPreviewTalentsAnimation then
        TalentFrameSetupPreviewTalents()
        LearnPreviewTalents(false)
        PlayerTalentFrame.learnPreviewTalentsAnimation = nil
    end

    -- UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
    -- clear caches
    for _, info in next, talentSpecInfoCache do
        wipe(info);
    end
    TalentFramePreviewHide()
    wipe(talentTabWidthCache);

    self.LoadingFrame:Hide()

    StaticPopup_Hide("TALENTS_IMPORT_POPUP")

    PlayerTalentPopupFrame:Hide()
end

function PlayerTalentFrame_OnEvent(self, event, ...)
    if (event == "PLAYER_TALENT_UPDATE" or event == "PET_TALENT_UPDATE") then
        PlayerTalentFrame_Refresh();
    elseif (event == "PREVIEW_TALENT_POINTS_CHANGED") then
        --local talentIndex, tabIndex, groupIndex, points = ...;
        if (selectedSpec and not specs[selectedSpec].pet) then
            PlayerTalentFrame_Refresh();
        end
    elseif (event == "PREVIEW_PET_TALENT_POINTS_CHANGED") then
        --local talentIndex, tabIndex, groupIndex, points = ...;
        PlayerTalentFrame_Refresh()
    elseif (event == "UNIT_PORTRAIT_UPDATE") then
        local unit = ...;
        -- update the talent frame's portrait
        if (unit == PlayerTalentFramePortrait.unit) then
            SetPortraitTexture(PlayerTalentFramePortrait, unit);
        end
    elseif (event == "UNIT_PET") then
        local summoner = ...;
        if (summoner == "player") then
            if (selectedSpec and specs[selectedSpec].pet) then
                -- if the selected spec is a pet spec...
                local numTalentGroups = GetNumTalentGroups(false, true);
                if (numTalentGroups == 0) then
                    --...and a pet spec is not available, select the default spec
                    PlayerSpecTab_OnClick(activeSpec and specTabs[activeSpec] or specTabs[DEFAULT_TALENT_SPEC]);
                    return ;
                end
            end
            PlayerTalentFrame_Refresh();
        end
    elseif (event == "PLAYER_LEVEL_UP") then
        if (selectedSpec and not specs[selectedSpec].pet) then
            local level = ...;
            PlayerTalentFrame_Update(level);
        end
    elseif event == "VARIABLES_LOADED" then
        self:RegisterEvent("ADDON_LOADED");
        self:RegisterEvent("PREVIEW_TALENT_POINTS_CHANGED");
        self:RegisterEvent("PREVIEW_PET_TALENT_POINTS_CHANGED");
        self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
        self:RegisterEvent("UNIT_PET");
        self:RegisterEvent("PLAYER_LEVEL_UP");
        self:RegisterEvent("PLAYER_TALENT_UPDATE");
        self:RegisterEvent("PET_TALENT_UPDATE")
        self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

        self.unit               = "player";
        self.inspect            = false;
        self.pet                = false;
        self.talentGroup        = 1;
        self.updateFunction     = PlayerTalentFrame_Update;
        self.selectedPlayerSpec = DEFAULT_TALENT_SPEC;

        self.elapsed            = 0
        self.removeSpecKey      = 1
        self.previewCVar        = nil

        TalentFrame_Load(self);
        SetPortraitToTexture(PlayerTalentFramePortrait, "Interface\\Icons\\Ability_Marksmanship")

        SendServerMessage("ACMSG_PLAYER_FAKE_TALENTS", 0)

        UIDropDownMenu_Initialize(self.LinkToDropDown, PlayerTalentLinkToDropDownInit, "MENU")

        -- setup tabs
        PanelTemplates_SetNumTabs(self, NUM_TALENT_FRAME_TABS)
        PlayerTalentFrameTab_OnClick(PlayerTalentFrameTab1)

        -- initialize active spec as a fail safe
        if not C_Talent.GetSpecInfoCache() then
            return
        end

        local activeTalentGroup = GetActiveTalentGroup();
        local numTalentGroups   = GetNumTalentGroups();
        PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup, numTalentGroups);

        -- setup active spec highlight
        if (ACTIVESPEC_DISPLAYTYPE == "BLUE") then
            PlayerTalentFrameActiveSpecTabHighlight:SetDrawLayer("OVERLAY");
            PlayerTalentFrameActiveSpecTabHighlight:SetBlendMode("ADD");
            PlayerTalentFrameActiveSpecTabHighlight:SetTexture("Interface\\Buttons\\UI-Button-Outline");
        elseif (ACTIVESPEC_DISPLAYTYPE == "GOLD_INSIDE") then
            PlayerTalentFrameActiveSpecTabHighlight:SetDrawLayer("OVERLAY");
            PlayerTalentFrameActiveSpecTabHighlight:SetBlendMode("ADD");
            PlayerTalentFrameActiveSpecTabHighlight:SetTexture("Interface\\Buttons\\CheckButtonHilight");
        elseif (ACTIVESPEC_DISPLAYTYPE == "GOLD_BACKGROUND") then
            PlayerTalentFrameActiveSpecTabHighlight:SetDrawLayer("BACKGROUND");
            PlayerTalentFrameActiveSpecTabHighlight:SetWidth(74);
            PlayerTalentFrameActiveSpecTabHighlight:SetHeight(86);
            PlayerTalentFrameActiveSpecTabHighlight:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab-Glow");
        end
    end
end

function PlayerTalentFrame_Update(playerLevel)
    if not C_Talent.GetSpecInfoCache() then
        return
    end

    local activeTalentGroup, numTalentGroups = GetActiveTalentGroup(false, PlayerTalentFrame.pet), GetNumTalentGroups(false, PlayerTalentFrame.pet);
    -- local activePetTalentGroup, numPetTalentGroups = GetActiveTalentGroup(false, true), GetNumTalentGroups(false, true);

    -- update specs
    if (not PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups)) then
        -- the current spec is not selectable any more, discontinue updates
        return false;
    end

    -- update tabs
    if (not PlayerTalentFrame_UpdateTabs(playerLevel)) then
        -- the current spec is not selectable any more, discontinue updates
        return false;
    end

    -- set the frame portrait
    SetPortraitTexture(PlayerTalentFramePortrait, PlayerTalentFrame.unit);

    -- update active talent group stuff
    PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup, numTalentGroups);

    -- update talent controls
    PlayerTalentFrame_UpdateControls(activeTalentGroup, numTalentGroups);

    for _, button in pairs(PlayerTalentFrame.specTabs) do
        button:SetShown(not PlayerTalentFrame.pet and not PlayerTalentFrame.previewState)
    end

    if PlayerTalentFrame.pet then
        PlayerTalentFrame_UpdatePetInfo(PlayerTalentFrame)
    end

    return true
end

function PlayerFrame_UpdateSpecTabs(self)
	for i = max(#self.specTabs, 1), C_Talent.GetNumTalentGroups() do
		local specTab = self.specTabs[i]

		if not specTab then
			specTab = CreateFrame("CheckButton", "PlayerSpecTab"..i, self, "PlayerSpecTabTemplate")
			specTab.specIndex = i

			self.specTabs[i] = specTab
		end

		if i == 1 then
			specTab:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, -40)
		else
			specTab:SetPoint("TOPLEFT", self.specTabs[i - 1], "BOTTOMLEFT", 0, -22)

			if i > 2 then
				specTab:GetHighlightTexture():SetTexture("Interface\\Buttons\\ButtonHilight-Square-Purple")
				specTab:GetCheckedTexture():SetTexture("Interface\\Buttons\\CheckButtonHilight-Purple")
				specTab.EtherealBorder:Show()
			end
		end

		local talentPointsSpent = C_Talent.GetTabPointSpent(i)
		local primaryTabIndex   = C_Talent.GetPrimaryTabIndex(unpack(talentPointsSpent))
		specTab.primaryTabIndex = primaryTabIndex

		for j = 1, 3 do
			local name, icon, _, _, _  = GetTalentTabInfo(j, false, false, 1)

			if not specTab.tabInfo then
				specTab.tabInfo = {}
			end

			specTab.tabInfo[j] = {
				name        = name,
				icon        = icon,
				pointsSpent = talentPointsSpent[j],
				isPrimary   = primaryTabIndex == j
			}
		end

		specTab:GetNormalTexture():SetTexture(specTab.tabInfo[primaryTabIndex]and specTab.tabInfo[primaryTabIndex].icon or "Interface\\Icons\\Ability_Marksmanship")
	end
end

function PlayerTalentFrame_UpdatePetInfo(self)
    if (self.pet) then
        if (UnitCreatureFamily("pet")) then
            PlayerTalentFramePetTypeText:SetText(UnitCreatureFamily("pet"))
        else
            PlayerTalentFramePetTypeText:SetText("")
        end

        if (UnitLevel("pet")) then
            PlayerTalentFramePetLevelText:SetFormattedText(UNIT_LEVEL_TEMPLATE, UnitLevel("pet"))
        else
            PlayerTalentFramePetLevelText:SetText("")
        end

        if (UnitName("pet")) then
            PlayerTalentFramePetNameText:SetText(UnitName("pet"))
        else
            PlayerTalentFramePetNameText:SetText("")
        end

        PlayerTalentFramePetIcon:SetTexture(GetPetIcon())
    end
end

function PlayerTalentFrame_ShowTalentTab()
    PlayerTalentFrameTalents:Show()
end

function PlayerTalentFrame_HideTalentTab()
    PlayerTalentFrameTalents:Hide()
end

function PlayerTalentFrame_ShowPetTalentTab()
    PlayerTalentFramePetTalents:Show()
end

function PlayerTalentFrame_HidePetTalentTab()
    PlayerTalentFramePetTalents:Hide()
end

function PlayerTalentFrame_Collapse()
    PlayerTalentFrame:SetWidth(542)
    PlayerTalentFrame.Expanded = false
    UpdateUIPanelPositions(PlayerTalentFrame)
    ButtonFrameTemplate_HideButtonBar(PlayerTalentFrame)
end

function PlayerTalentFrame_Expand()
    PlayerTalentFrame:SetWidth(646)
    PlayerTalentFrame.Expanded = true
    UpdateUIPanelPositions(PlayerTalentFrame)
    ButtonFrameTemplate_ShowButtonBar(PlayerTalentFrame)
end

local iconYOffset = 0
function PlayerTalentFrame_Refresh()
    local selectedTab       = PanelTemplates_GetSelectedTab(PlayerTalentFrame)

    -- HACK - If this is the Pet Talents Tab, ignore the selected spec since pets only display one spec
    --if (selectedTab == PET_TALENTS_TAB) then
    --    selectedSpec                  = "spec1";
    --    PlayerTalentFrame.talentGroup = 1;
    --else
    --    selectedSpec                  = PlayerTalentFrame.selectedPlayerSpec;
    --    PlayerTalentFrame.talentGroup = specs[selectedSpec].talentGroup;
    --end

    if (selectedTab == GLYPH_TALENT_TAB) then
        PlayerTalentFrame_HideTalentTab()
        PlayerTalentFrame_HidePetTalentTab()
        PlayerTalentFrame.pet = false
        PlayerTalentFrame_ShowGlyphFrame()
        PlayerTalentFrame_Collapse()
    elseif (selectedTab == PET_TALENTS_TAB) then
        PlayerTalentFrame_HideGlyphFrame()
        PlayerTalentFrame_HideTalentTab()
        PlayerTalentFrame_ShowPetTalentTab()
        PlayerTalentFrame.pet = true
        PlayerTalentFrame_Expand()
    else
        PlayerTalentFrame_HideGlyphFrame()
        PlayerTalentFrame_HidePetTalentTab()
        PlayerTalentFrame_ShowTalentTab()
        PlayerTalentFrame.pet = false
        PlayerTalentFrame_Expand()
    end

    PlayerTalentFramePanel1.talentGroup = PlayerTalentFrame.talentGroup
    PlayerTalentFramePanel2.talentGroup = PlayerTalentFrame.talentGroup
    PlayerTalentFramePanel3.talentGroup = PlayerTalentFrame.talentGroup

    if (not PlayerTalentFrame_Update()) then
        return
    end

    iconYOffset = 0

    if (PlayerTalentFramePanel1:IsVisible()) then
        PlayerTalentFramePanel_Update(PlayerTalentFramePanel1)
    end
    if (PlayerTalentFramePanel2:IsVisible()) then
        PlayerTalentFramePanel_Update(PlayerTalentFramePanel2)
    end
    if (PlayerTalentFramePanel3:IsVisible()) then
        PlayerTalentFramePanel_Update(PlayerTalentFramePanel3)
    end
    if (PlayerTalentFramePetPanel:IsVisible()) then
        PlayerTalentFramePanel_Update(PlayerTalentFramePetPanel)
    end


    for i = 1, 3 do
        -- hack
        local summary = _G["PlayerTalentFramePanel" .. i .. "Summary"]

        summary.ActiveBonus1:ClearAllPoints()
        summary.ActiveBonus1:SetPoint("TOPLEFT", summary.DescriptionText, "TOPLEFT", 10, 56 + iconYOffset)
    end

    PlayerTalentFrame.CurrencySelectFrame.Currency1.Icon:SetDesaturated(true)
    PlayerTalentFrame.CurrencySelectFrame.Currency2.Icon:SetDesaturated(true)

    PlayerTalentFrame.CurrencySelectFrame.Currency1:Disable()
    PlayerTalentFrame.CurrencySelectFrame.Currency2:Disable()

    for i = 1, 2 do
        local currencyInfo = C_Talent.GetCurrencyInfo(i)

        if currencyInfo then
            local currencyButton = _G["PlayerTalentFrameCurrencySelectFrameCurrency"..i]

            currencyButton.Icon:SetDesaturated(not currencyInfo.count or currencyInfo.count == 0)
            currencyButton.Count:SetText(currencyInfo.count > 99 and "99.." or currencyInfo.count)
            currencyButton.name = currencyInfo.name

            currencyButton:SetEnabled(currencyInfo.count and currencyInfo.count > 0)

            if currencyInfo.count and currencyInfo.count > 0 then
                if not C_Talent.GetSelectedCurrency() then
                    currencyButton:Click()
                end
            else
                currencyButton:SetChecked(false)
            end
        end
    end

    PlayerTalentFrame_RefreshSpecTabs()

    --for i = 1, GetCurrencyListSize() do
    --    local name, _, _, _, _, count, _, _, itemID = GetCurrencyListInfo(i)
    --
    --    if itemID == 100584 then
    --        PlayerTalentFrame.CurrencySelectFrame.Currency1.Icon:SetDesaturated(not count or count == 0)
    --        PlayerTalentFrame.CurrencySelectFrame.Currency1.Count:SetText(count > 99 and "99.." or count)
    --        PlayerTalentFrame.CurrencySelectFrame.Currency1.name = name
    --
    --        PlayerTalentFrame.CurrencySelectFrame.Currency1:SetEnabled(count and count > 0)
    --    elseif itemID == 100585 then
    --        PlayerTalentFrame.CurrencySelectFrame.Currency2.Icon:SetDesaturated(not count or count == 0)
    --        PlayerTalentFrame.CurrencySelectFrame.Currency2.Count:SetText(count > 99 and "99.." or count)
    --        PlayerTalentFrame.CurrencySelectFrame.Currency2.name = name
    --
    --        PlayerTalentFrame.CurrencySelectFrame.Currency2:SetEnabled(count and count > 0)
    --    end
    --end
end

function PlayerTalentFrame_RefreshSpecTabs()
    for _, button in pairs(PlayerTalentFrame.specTabs) do
        local pointSpent        = C_Talent.GetTabPointSpent(button.specIndex)
        local primaryTabIndex   = C_Talent.GetPrimaryTabIndex(unpack(pointSpent))
        local _, icon           = GetTalentTabInfo(primaryTabIndex, false, false, 1)
        local _, texture        = C_Talent.GetTalentGroupSettings(button.specIndex)

        button:GetNormalTexture():SetTexture(texture or (icon or "Interface\\Icons\\Ability_Marksmanship"))
    end
end

function TalentFramePanelSummary_OnUpdate(self, elapsed, ...)
    if not self:IsShown() then
        return
    end

    if self.needAnimation then
        local easing = outSine(self.elapsed, 0, 250 + iconYOffset, 0.500)
        local offset = 0

        if self.isHiddenAnimation then
            offset = (250 + iconYOffset) - easing
        else
            offset = easing
        end

        if offset > 0 then
            self:SetAlpha(1)
        elseif offset == 0 then
            self:SetAlpha(0)
        end

        self:SetHeight(offset)

        self.elapsed = self.elapsed + elapsed
        if self.elapsed > 0.500 then
            self.needAnimation = false
            self.elapsed       = 0

            if self.isHiddenAnimation then
                self:Hide()
                self:GetParent().ShadowFrame:Hide()
            end
        end
    end
end

local function PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, spellId, spellId2, formatString, _)
    local name, _, icon = GetSpellInfo(spellId)
    if (spellId2) then
        local name2, _, _ = GetSpellInfo(spellId2)
        if (name2) then
            name = name .. "/" .. name2
        end
    end
    bonusFrame.Icon:SetTexture(icon)
    if (formatString) then
        bonusFrame.Label:SetFormattedText(formatString, name)
    else
        bonusFrame.Label:SetText(name)
    end

    bonusFrame.spellId      = spellId
    bonusFrame.spellId2     = spellId2
    bonusFrame.extraTooltip = nil
    bonusFrame.Label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

    bonusFrame:Show()
end

local classSpecRoleLocale = {
    [1] = "DAMAGER",
    [2] = "HEALER",
    [4] = "TANK"
}

function GetClassSpecRole(class, specID)
    if not class or not specID or not SIRUS_TALENT_INFO[class] then
        return
    end

    local buffer = {}

    for _, specFlag in pairs({ SIRUS_ROLE_FLAG_DAMAGER, SIRUS_ROLE_FLAG_HEAL, SIRUS_ROLE_FLAG_TANK }) do
        if bit.band(SIRUS_TALENT_INFO[class][specID].role, specFlag) == specFlag then
            if classSpecRoleLocale[specFlag] then
                table.insert(buffer, classSpecRoleLocale[specFlag])
            end
        end
    end

    return unpack(buffer)
end

function PlayerTalentFramePanel_UpdateSummary(self)
    local name, icon, _, _, _ = GetTalentTabInfo(self.talentTree, self.inspect, self.pet, self.talentGroup)

    if (self.Summary and icon) then
        local summary      = self.Summary
        local _, class     = UnitClass("player")
        local talentInfo   = SIRUS_TALENT_INFO[class] or SIRUS_TALENT_INFO["default"]
        local role1, role2 = GetClassSpecRole(class, self.talentTree)

        if (role1 == "TANK" or role1 == "HEALER" or role1 == "DAMAGER") then
            summary.RoleIcon.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role1))
            summary.RoleIcon:Show()
            summary.RoleIcon.role = role1
        else
            summary.RoleIcon:Hide()
        end

        if (role2 == "TANK" or role2 == "HEALER" or role2 == "DAMAGER") then
            summary.RoleIcon2.Icon:SetTexCoord(GetTexCoordsForRoleSmallCircle(role2))
            summary.RoleIcon2:Show()
            summary.RoleIcon2.role = role2
            summary.RoleIcon:SetPoint("BOTTOMRIGHT", summary.IconBorder, -9, -1)
        else
            summary.RoleIcon2:Hide();
            summary.RoleIcon:SetPoint("BOTTOMRIGHT", summary.IconBorder, -1, 3)
        end

        SetPortraitToTexture(summary.Icon, icon)
        summary.TitleText:SetText(name)

        summary.Icon:ClearAllPoints()
        summary.Icon:SetPoint("BOTTOM", summary.ActiveBonus1, "TOP", -14, 10)

        if (PlayerTalentFrame.primaryTree and self.talentTree == PlayerTalentFrame.primaryTree) then
            summary.GlowTopLeft:Show()
            summary.GlowTop:Show()
            summary.GlowTopRight:Show()
            summary.GlowRight:Show()
            summary.GlowBottomRight:Show()
            summary.GlowBottom:Show()
            summary.GlowBottomLeft:Show()
            summary.GlowLeft:Show()
            summary.Border:SetVertexColor(0, 0, 0)

            local desaturate = (selectedSpec ~= activeSpec)
            summary.GlowTopLeft:SetDesaturated(desaturate)
            summary.GlowTop:SetDesaturated(desaturate)
            summary.GlowTopRight:SetDesaturated(desaturate)
            summary.GlowRight:SetDesaturated(desaturate)
            summary.GlowBottomRight:SetDesaturated(desaturate)
            summary.GlowBottom:SetDesaturated(desaturate)
            summary.GlowBottomLeft:SetDesaturated(desaturate)
            summary.GlowLeft:SetDesaturated(desaturate)
        else
            summary.GlowTopLeft:Hide()
            summary.GlowTop:Hide()
            summary.GlowTopRight:Hide()
            summary.GlowRight:Hide()
            summary.GlowBottomRight:Hide()
            summary.GlowBottom:Hide()
            summary.GlowBottomLeft:Hide()
            summary.GlowLeft:Hide()
        end

        local numSmallBonuses = 0

        if talentInfo[self.talentTree].ActiveBonus then
            for i = 1, #talentInfo[self.talentTree].ActiveBonus do
                local bonusFrame = _G[summary:GetName() .. "ActiveBonus" .. i]
                if (bonusFrame) then
                    -- numSmallBonuses = numSmallBonuses + 1
                    PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, talentInfo[self.talentTree].ActiveBonus[i], nil, nil, 0)
                end
            end
        end

        if talentInfo[self.talentTree].PassiveBonus then
            for i = 1, #talentInfo[self.talentTree].PassiveBonus do
                local bonusFrame = _G[summary:GetName() .. "Bonus" .. i]
                if (bonusFrame) then
                    numSmallBonuses       = numSmallBonuses + 1
                    bonusFrame.showButton = true
                    PlayerTalentFramePanel_UpdateBonusAbility(bonusFrame, talentInfo[self.talentTree].PassiveBonus[i], nil, nil, 0)
                end
            end
        end

        for i = numSmallBonuses, 5 do
            if _G[summary:GetName() .. "Bonus" .. i] then
                _G[summary:GetName() .. "Bonus" .. i].showButton = false
                _G[summary:GetName() .. "Bonus" .. i]:Hide()
            end
        end

        local offsetY = 20 * numSmallBonuses

        if offsetY >= iconYOffset then
            iconYOffset = offsetY
        end

        summary.DescriptionText:SetText(talentInfo[self.talentTree].Description)
    end
end

function PlayerTalentFramePanel_Update(self)
    local _, class                                       = UnitClass("player")
    local name, icon, pointsSpent, _, previewPointsSpent = GetTalentTabInfo(self.talentTree, self.inspect, self.pet, self.talentGroup)
    local primaryTree                                    = PlayerTalentFrame.primaryTree

    if self.PointsSpent then
        self.PointsSpent:SetText(pointsSpent + previewPointsSpent)
    end

    if self.HeaderIcon then
        local pointSpent = C_Talent.GetTabPointSpent(C_Talent.GetSelectedTalentGroup())[self.talentTree] or (pointsSpent + previewPointsSpent)

        self.HeaderIcon.Icon:SetTexture(icon)
        self.HeaderIcon.PointsSpent:SetText(pointSpent)
    end

    if self.NameLarge then
        self.NameLarge:SetText(name)
    end

    if self.Name then
        self.Name:SetText(name)
    end

    local talentInfo
    if self.pet then
        talentInfo = SIRUS_TALENT_INFO["PET_410"]
    else
        talentInfo = SIRUS_TALENT_INFO[class] or SIRUS_TALENT_INFO["default"]
    end

    local color = talentInfo and talentInfo[self.talentTree] and talentInfo[self.talentTree].color;
    if color then
        self.HeaderBackground:SetVertexColor(color.r, color.g, color.b)
        if self.HeaderBackgroundHighlight then
            self.HeaderBackgroundHighlight:SetVertexColor(color.r, color.g, color.b)
        end
        if self.Summary then
            self.Summary.Border:SetVertexColor(color.r, color.g, color.b)
            self.Summary.IconGlow:SetVertexColor(color.r, color.g, color.b)
        end
    else
        self.HeaderBackground:SetVertexColor(1, 1, 1)
    end

    TalentFrame_Update(self)
    PlayerTalentFramePanel_UpdateSummary(self)

    if (self.SelectTreeButton) then
        if (not primaryTree and GetNumTalentPoints() > 0) then
            self.SelectTreeButton:Show()
            self.SelectTreeButton:SetText(name)
            if (selectedSpec and (activeSpec == selectedSpec)) then
                self.SelectTreeButton:Enable()
            else
                self.SelectTreeButton:Disable()
            end
        else
            self.SelectTreeButton:Hide()
        end
    end

    if (self.HeaderIcon and not self.pet) then
        if (primaryTree == self.talentTree) then
            self.HeaderIcon.PointsSpent:Show()
            self.HeaderIcon.PrimaryBorder:Show()
            self.HeaderIcon.PointsSpentBgGold:Show()
            self.HeaderIcon.SecondaryBorder:Hide()
            self.HeaderIcon.PointsSpentBgSilver:Hide()
            self.HeaderIcon.LockIcon:Hide()
        else
            self.HeaderIcon.PointsSpent:Show()
            self.HeaderIcon.PrimaryBorder:Hide()
            self.HeaderIcon.PointsSpentBgGold:Hide()
            self.HeaderIcon.LockIcon:Hide()
            self.HeaderIcon.PointsSpentBgSilver:Show()

            local selectedTalentGroup = C_Talent.GetSelectedTalentGroup()

            self.HeaderIcon.SecondaryBorder:SetShown(selectedTalentGroup < 3)
            self.HeaderBorder:SetShown(selectedTalentGroup < 3)

            self.EtherealHeaderBorder:SetShown(selectedTalentGroup > 2)
            self.HeaderIcon.EtherealBorder:SetShown(selectedTalentGroup > 2)
            self.HeaderIcon.EtherealGlow:SetShown(selectedTalentGroup > 2)
        end
    end

    if (self.RoleIcon) then
        local role1, role2 = GetClassSpecRole(class, self.talentTree)

        -- swap roles to match order on the summary screen
        if (role2) then
            role1, role2 = role2, role1;
        end

        -- Update roles
        if (role1 == "TANK" or role1 == "HEALER" or role1 == "DAMAGER") then
            self.RoleIcon.Icon:SetTexCoord(GetTexCoordsForRoleSmall(role1))
            self.RoleIcon:Show()
            self.RoleIcon.role = role1
        else
            self.RoleIcon:Hide()
        end

        if (role2 == "TANK" or role2 == "HEALER" or role2 == "DAMAGER") then
            self.RoleIcon2.Icon:SetTexCoord(GetTexCoordsForRoleSmall(role2))
            self.RoleIcon2:Show()
            self.RoleIcon2.role = role2
        else
            self.RoleIcon2:Hide()
        end
    end
end

function PlayerTalentFrame_UpdateActiveSpec(activeTalentGroup, numTalentGroups)
    -- set the active spec
    activeSpec = DEFAULT_TALENT_SPEC;
    for index, spec in next, specs do
        if (not spec.pet and spec.talentGroup == activeTalentGroup) then
            activeSpec = index;
            break ;
        end
    end
    -- make UI adjustments
    local spec = selectedSpec and specs[selectedSpec];
    local hasMultipleTalentGroups = numTalentGroups > 1;
    local selectedTalentGroup     = C_Talent.GetSelectedTalentGroup()

    if (spec and hasMultipleTalentGroups) then
        local name = C_Talent.GetTalentGroupSettings(selectedTalentGroup)
        if name and name ~= "" then
            PlayerTalentFrameTitleText:SetText(name);
        else
            PlayerTalentFrameTitleText:SetFormattedText(TALENT_TAB_NAME, selectedTalentGroup);
        end
    else
        PlayerTalentFrameTitleText:SetText(TALENTS);
    end

    if (selectedSpec == activeSpec and hasMultipleTalentGroups) then
        --PlayerTalentFrameActiveTalentGroupFrame:Show();
    else
        -- PlayerTalentFrameActiveTalentGroupFrame:Hide();
    end

    if selectedTalentGroup > 2 then
        PlayerTalentFrameTitleGlowLeft:SetTexture("Interface\\TalentFrame\\TalentFrame-Parts-purple")
        PlayerTalentFrameTitleGlowRight:SetTexture("Interface\\TalentFrame\\TalentFrame-Parts-purple")
        PlayerTalentFrameTitleGlowCenter:SetTexture("Interface\\TalentFrame\\TalentFrame-Horizontal-purple")
    else
        PlayerTalentFrameTitleGlowLeft:SetTexture("Interface\\TalentFrame\\TalentFrame-Parts")
        PlayerTalentFrameTitleGlowRight:SetTexture("Interface\\TalentFrame\\TalentFrame-Parts")
        PlayerTalentFrameTitleGlowCenter:SetTexture("Interface\\TalentFrame\\TalentFrame-Horizontal")
    end

    PlayerTalentFrame.EtherealBackground:SetShown(selectedTalentGroup > 2)

    PlayerTalentFrame.EtherealLines:SetShown(selectedTalentGroup > 2)
    PlayerTalentFrame.EtherealLinesGlow1:SetShown(selectedTalentGroup > 2)

    --AnimationStopAndPlay(PlayerTalentFrame.EtherealLines.animIn, PlayerTalentFrame.EtherealLines.animIn)
    AnimationStopAndPlay(PlayerTalentFrame.EtherealLinesGlow1.animIn, PlayerTalentFrame.EtherealLinesGlow1.animIn)
end

function PlayerTalentCurrency_OnClick( self )
    for _, button in pairs(self:GetParent().currencyButtons) do
        button:SetChecked(self == button)
    end

    C_Talent.SelectedCurrency(self:GetID())
end

function PlayerTalentFrameTalent_OnClick(self, button)
    if PlayerTalentFrame.previewState then
        return
    end

    if (IsModifiedClick("CHATLINK")) then
        local link = GetTalentLink(self:GetParent().talentTree, self:GetID(),
                PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalents"));
        if (link) then
            ChatEdit_InsertLink(link);
        end
    elseif (selectedSpec and (activeSpec == selectedSpec)) then
        -- only allow functionality if an active spec is selected
        if (button == "LeftButton") then
            if (GetCVarBool("previewTalents")) then
                AddPreviewTalentPoints(self:GetParent().talentTree, self:GetID(), 1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
            else
                LearnTalent(self:GetParent().talentTree, self:GetID(), PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
            end
        elseif (button == "RightButton") then
            if (GetCVarBool("previewTalents")) then
                AddPreviewTalentPoints(self:GetParent().talentTree, self:GetID(), -1, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
            end
        end
    end
end

function PlayerTalentFrameTalent_OnEvent(self, _, ...)
    if (GameTooltip:IsOwned(self)) then
        GameTooltip:SetTalent(self:GetParent().talentTree, self:GetID(),
                PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalents"));
    end
end

function PlayerTalentFrameTalent_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetTalent(self:GetParent().talentTree, self:GetID(),
            PlayerTalentFrame.inspect, PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup, GetCVarBool("previewTalents"));

    local _, _, spellID = GameTooltip:GetSpell()
    if spellID then
        self.spellID = spellID
    end
end

function PlayerTalentFrame_UpdateControls(_, numTalentGroups)
    local spec               = selectedSpec and specs[selectedSpec];

    local isActiveSpec       = selectedSpec == activeSpec;

    -- show the multi-spec status frame if this is not a pet spec or we have more than one talent group
    local showStatusFrame    = not spec.pet and numTalentGroups > 1;
    -- show the activate button if we were going to show the status frame but this is not the active spec
    local showActivateButton = showStatusFrame and not isActiveSpec;

    if (showActivateButton) then
        local selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)

        PlayerTalentFrameActivateButton:SetShown(selectedTab ~= 3);
        PlayerTalentFrame.CurrencySelectFrame:SetShown(selectedTab ~= 3 and C_Talent.GetSelectedTalentGroup() > 2)
        PlayerTalentFrameStatusFrame:Hide();
    else
        PlayerTalentFrameActivateButton:Hide();
        PlayerTalentFrame.CurrencySelectFrame:Hide()
        if (showStatusFrame) then
            PlayerTalentFrameStatusFrame:Show();
        else
            PlayerTalentFrameStatusFrame:Hide();
        end
    end

    local preview      = GetCVarBool("previewTalents");

    -- enable the control bar if this is the active spec, preview is enabled, and preview points were spent
    local talentPoints = GetUnspentTalentPoints(false, PlayerTalentFrame.pet, spec.talentGroup);
    if ((spec.pet or isActiveSpec) and talentPoints > 0 and preview) then
        PlayerTalentFramePreviewBar:Show();
        -- squish all frames to make room for this bar
        PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFramePreviewBar, "TOP", 0, -4);
    else
        PlayerTalentFramePreviewBar:Hide();
        -- unsquish frames since the bar is now hidden
        PlayerTalentFramePointsBar:SetPoint("BOTTOM", PlayerTalentFrame, "BOTTOM", 0, 81);
    end

    -- enable accept/cancel buttons if preview talent points were spent
    if (GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, spec.talentGroup) > 0) and not PlayerTalentFrame.learnPreviewTalentsAnimation then
        PlayerTalentFrameLearnButton:Enable();
        PlayerTalentFrameResetButton:Enable();
    else
        PlayerTalentFrameLearnButton:Disable();
        PlayerTalentFrameResetButton:Disable();
    end

    local unspentPreviewPoints = talentPoints - GetGroupPreviewTalentPointsSpent(PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup)
    local selectedTab          = PanelTemplates_GetSelectedTab(PlayerTalentFrame)

    PlayerTalentFrameResetButton:SetShown(selectedTab ~= GLYPH_TALENT_TAB)
    PlayerTalentFrameLearnButton:SetShown(selectedTab ~= GLYPH_TALENT_TAB)

    if PlayerTalentFrameHeaderText then
        if PlayerTalentFrame.previewState then
            PlayerTalentFrameHeaderText:SetFormattedText(PREVIEW_UNSPENT_TALENT_POINTS, unspentPreviewPoints)
        else
            PlayerTalentFrameHeaderText:SetFormattedText(PlayerTalentFrame.pet and PET_UNSPENT_TALENT_POINTS or PLAYER_UNSPENT_TALENT_POINTS, unspentPreviewPoints)
        end
        PlayerTalentFrameHeaderText:SetShown(not PlayerTalentFrame.resetTalents and not PlayerTalentFrame.learnPreviewTalentsAnimation)
        PlayerTalentFrameHeaderSubText:Hide()
        PlayerTalentFrameHeaderFrame:SetShown(unspentPreviewPoints and unspentPreviewPoints > 0 and selectedTab ~= GLYPH_TALENT_TAB and isActiveSpec)
    end

    PlayerTalentFrameResetButton:SetShown(preview)
    PlayerTalentFrameLearnButton:SetShown(preview)
    PlayerTalentFrameBackButton:SetShown(PlayerTalentFrame.previewState)
    PlayerTalentFrameScreenshotButton:SetShown(PlayerTalentFrame.previewState)

    PlayerTalentLinkButton:SetShown(not showActivateButton and selectedTab == TALENTS_TAB and not PlayerTalentFrame.previewState)

    if PlayerTalentFrame.previewState then
        for i = 1, #toggleElements do
            local element = _G[toggleElements[i]]

            if element then
                element:Hide()
            end
        end
    end
end

function ToggleSummariesButton_OnClick(_, ...)
    if PlayerTalentFramePanel1.Summary.needAnimation then
        return
    end

    PlayerTalentFrameToggleSummariesHelpBox:Hide()

    for i = 1, 3 do
        local panel = _G["PlayerTalentFramePanel" .. i]

        panel.Summary:SetHeight(0)
        panel.Summary.needAnimation     = true
        panel.Summary.elapsed           = 0
        panel.Summary.isHiddenAnimation = panel.Summary:IsShown()

        if not panel.Summary.isHiddenAnimation then
            panel.Summary:Show()
            panel.ShadowFrame:Show()

            AnimationStopAndPlay(panel.Summary.TitleText.animIN, panel.Summary.TitleText.animOUT)
            AnimationStopAndPlay(panel.Summary.IconBorder.animIN, panel.Summary.IconBorder.animOUT)
            AnimationStopAndPlay(panel.Summary.Icon.animIN, panel.Summary.Icon.animOUT)
            AnimationStopAndPlay(panel.Summary.IconGlow.animIN, panel.Summary.IconGlow.animOUT)
            AnimationStopAndPlay(panel.Summary.DescriptionText.animIN, panel.Summary.DescriptionText.animOUT)
            AnimationStopAndPlay(panel.Summary.RoleIcon.animIN, panel.Summary.RoleIcon.animOUT)
            AnimationStopAndPlay(panel.Summary.RoleIcon2.animIN, panel.Summary.RoleIcon2.animOUT)
            AnimationStopAndPlay(panel.Summary.ActiveBonus1.animIN, panel.Summary.ActiveBonus1.animOUT)
            AnimationStopAndPlay(panel.Summary.Bonus1.animIN, panel.Summary.Bonus1.animOUT)
            AnimationStopAndPlay(panel.Summary.Bonus2.animIN, panel.Summary.Bonus2.animOUT)
            AnimationStopAndPlay(panel.Summary.Bonus3.animIN, panel.Summary.Bonus3.animOUT)
            AnimationStopAndPlay(panel.Summary.Bonus4.animIN, panel.Summary.Bonus4.animOUT)
            AnimationStopAndPlay(panel.Summary.Bonus5.animIN, panel.Summary.Bonus5.animOUT)

            AnimationStopAndPlay(panel.ShadowFrame.animIN, panel.ShadowFrame.animOUT)
        else
            AnimationStopAndPlay(panel.Summary.TitleText.animOUT, panel.Summary.TitleText.animIN)
            AnimationStopAndPlay(panel.Summary.IconBorder.animOUT, panel.Summary.IconBorder.animIN)
            AnimationStopAndPlay(panel.Summary.Icon.animOUT, panel.Summary.Icon.animIN)
            AnimationStopAndPlay(panel.Summary.IconGlow.animOUT, panel.Summary.IconGlow.animIN)
            AnimationStopAndPlay(panel.Summary.DescriptionText.animOUT, panel.Summary.DescriptionText.animIN)
            AnimationStopAndPlay(panel.Summary.RoleIcon.animOUT, panel.Summary.RoleIcon.animIN)
            AnimationStopAndPlay(panel.Summary.RoleIcon2.animOUT, panel.Summary.RoleIcon2.animIN)
            AnimationStopAndPlay(panel.Summary.ActiveBonus1.animOUT, panel.Summary.ActiveBonus1.animIN)
            AnimationStopAndPlay(panel.Summary.Bonus1.animOUT, panel.Summary.Bonus1.animIN)
            AnimationStopAndPlay(panel.Summary.Bonus2.animOUT, panel.Summary.Bonus2.animIN)
            AnimationStopAndPlay(panel.Summary.Bonus3.animOUT, panel.Summary.Bonus3.animIN)
            AnimationStopAndPlay(panel.Summary.Bonus4.animOUT, panel.Summary.Bonus4.animIN)
            AnimationStopAndPlay(panel.Summary.Bonus5.animOUT, panel.Summary.Bonus5.animIN)

            AnimationStopAndPlay(panel.ShadowFrame.animOUT, panel.ShadowFrame.animIN)
        end
    end
end

function PlayerTalentFrameActivateButton_OnLoad(self)
    self:SetWidth(self:GetTextWidth() + 40);
end

function PlayerTalentFrameActivateButton_OnClick()
    C_Talent.SetActiveTalentGroup()
end

function PlayerTalentFrameActivateButton_OnShow(self)
    self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
    PlayerTalentFrameActivateButton_Update();
end

function PlayerTalentFrameActivateButton_OnHide(self)
    self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function PlayerTalentFrameActivateButton_OnEvent(_, _, ...)
    PlayerTalentFrameActivateButton_Update();
end

function PlayerTalentFrameActivateButton_Update()
    local spec = selectedSpec and specs[selectedSpec];
    if (spec and PlayerTalentFrameActivateButton:IsShown()) then
        -- if the activation spell is being cast currently, disable the activate button
        if (IsCurrentSpell(TALENT_ACTIVATION_SPELLS[spec.talentGroup])) then
            PlayerTalentFrameActivateButton:Disable();
        else
            PlayerTalentFrameActivateButton:Enable();
        end
    end
end

function PlayerTalentFrameResetButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(TALENT_TOOLTIP_RESETTALENTGROUP);
end

function PlayerTalentFrameResetButton_OnClick(_)
    ResetGroupPreviewTalentPoints(PlayerTalentFrame.pet, PlayerTalentFrame.talentGroup);
end

function PlayerTalentFrameLearnButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(TALENT_TOOLTIP_LEARNTALENTGROUP);
end

function PlayerTalentFrameLearnButton_OnClick(_)
    if PlayerTalentFrame.previewState then
        if PlayerTalentFrame.pointSprent == 0 then
            SendServerMessage("ACMSG_PLAYER_RESET_TALENTS")
        else
            SendServerMessage("ACMSG_PLAYER_RESET_TALENTS_COST")
        end
    else
        StaticPopup_Show("CONFIRM_LEARN_PREVIEW_TALENTS");
    end
end


-- PlayerTalentFrameDownArrow

function PlayerTalentFrameDownArrow_OnClick(self, _)
    local parent = self:GetParent();
    parent:SetValue(parent:GetValue() + (parent:GetHeight() / 2));
    PlaySound("UChatScrollButton");
    -- UIFrameFlashStop(PlayerTalentFrameScrollButtonOverlay);
end


-- PlayerTalentFrameTab

function PlayerTalentFrame_UpdateTabs(playerLevel)
    local totalTabWidth              = 0;
    local firstShownTab              = _G["PlayerTalentFrameTab" .. TALENTS_TAB];
    local selectedTab                = PanelTemplates_GetSelectedTab(PlayerTalentFrame) or TALENTS_TAB;
    local numVisibleTabs             = 0;
    local tab;

    -- setup talent tab
    talentTabWidthCache[TALENTS_TAB] = 0;
    tab                              = _G["PlayerTalentFrameTab" .. TALENTS_TAB];
    if (tab) then
        tab:Show();
        firstShownTab = firstShownTab or tab;
        PanelTemplates_TabResize(tab, 0);
        talentTabWidthCache[TALENTS_TAB] = PanelTemplates_GetTabWidth(tab);
        totalTabWidth                    = totalTabWidth + talentTabWidthCache[TALENTS_TAB];
        numVisibleTabs                   = numVisibleTabs + 1;
    end

    -- setup pet talents tab
    talentTabWidthCache[PET_TALENTS_TAB] = 0;
    tab                                  = _G["PlayerTalentFrameTab" .. PET_TALENTS_TAB];
    local petTalentGroups                = GetNumTalentGroups(false, true);
    if (tab and petTalentGroups > 0 and HasPetUI()) then
        tab:Show();
        firstShownTab = firstShownTab or tab;
        PanelTemplates_TabResize(tab, 0);
        talentTabWidthCache[PET_TALENTS_TAB] = PanelTemplates_GetTabWidth(tab);
        totalTabWidth                        = totalTabWidth + talentTabWidthCache[PET_TALENTS_TAB];
        numVisibleTabs                       = numVisibleTabs + 1;
    else
        tab:Hide();
        talentTabWidthCache[PET_TALENTS_TAB] = 0;
    end

    -- setup glyph tab
    playerLevel           = playerLevel or UnitLevel("player");
    local meetsGlyphLevel = playerLevel >= SHOW_INSCRIPTION_LEVEL;
    tab                   = _G["PlayerTalentFrameTab" .. GLYPH_TALENT_TAB];
    if (meetsGlyphLevel) then
        tab:Show();
        firstShownTab = firstShownTab or tab;
        PanelTemplates_TabResize(tab, 0);
        talentTabWidthCache[GLYPH_TALENT_TAB] = PanelTemplates_GetTabWidth(tab);
        totalTabWidth                         = totalTabWidth + talentTabWidthCache[GLYPH_TALENT_TAB];
        numVisibleTabs                        = numVisibleTabs + 1;
    else
        tab:Hide();
        talentTabWidthCache[GLYPH_TALENT_TAB] = 0;
    end

    -- select the first shown tab if the selected tab does not exist for the selected spec
    tab = _G["PlayerTalentFrameTab" .. selectedTab];
    if (tab and not tab:IsShown()) then
        if (firstShownTab) then
            PlayerTalentFrameTab_OnClick(firstShownTab);
        end
        return false;
    end

    -- readjust tab sizes to fit
    local maxTotalTabWidth = PlayerTalentFrame:GetWidth();
    while (totalTabWidth >= maxTotalTabWidth) do
        -- progressively shave 10 pixels off of the largest tab until they all fit within the max width
        local largestTab = 1;
        for i = 2, #talentTabWidthCache do
            if (talentTabWidthCache[largestTab] < talentTabWidthCache[i]) then
                largestTab = i;
            end
        end
        -- shave the width
        talentTabWidthCache[largestTab] = talentTabWidthCache[largestTab] - 10;
        -- apply the shaved width
        tab                             = _G["PlayerTalentFrameTab" .. largestTab];
        PanelTemplates_TabResize(tab, 0, talentTabWidthCache[largestTab]);
        -- now update the total width
        totalTabWidth = totalTabWidth - 10;
    end

    -- Reposition the visible tabs
    local x = 15;
    for i = 1, NUM_TALENT_FRAME_TABS do
        tab = _G["PlayerTalentFrameTab" .. i];
        if (tab:IsShown()) then
            tab:ClearAllPoints();
            tab:SetPoint("TOPLEFT", PlayerTalentFrame, "BOTTOMLEFT", x, 1);
            x = x + talentTabWidthCache[i] - 15;
        end
    end

    -- update the tabs
    PanelTemplates_UpdateTabs(PlayerTalentFrame);

    return true;
end

function PlayerTalentFrameTab_OnLoad(self)
    self:SetFrameLevel(self:GetFrameLevel() + 2);
end

function PlayerTalentFrameTab_OnClick(self)
    local id                             = self:GetID();

    PlayerTalentFrame.secureLastTabIndex = id
    PanelTemplates_SetTab(PlayerTalentFrame, id)
    PlayerTalentFrame_Refresh()
    PlayerTalentPopupFrame:Hide()
    PlaySound("igCharacterInfoTab")
end

function PlayerTalentFrameTab_OnEnter(self)
    if (self.textWidth and self.textWidth > self:GetTextWidth()) then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
        GameTooltip:SetText(self:GetText());
    end
end


-- PlayerTalentTab

function PlayerTalentTab_OnLoad(self)
    PlayerTalentFrameTab_OnLoad(self);

    self:RegisterEvent("PLAYER_LEVEL_UP");
end

function PlayerTalentTab_OnClick(self)
    PlayerTalentFrameTab_OnClick(self);
    for i = 1, MAX_TALENT_TABS do
        SetButtonPulse(_G["PlayerTalentFrameTab" .. i], 0, 0);
    end
end

function PlayerTalentTab_OnEvent(self, _, ...)
    if (UnitLevel("player") == (SHOW_TALENT_LEVEL - 1) and PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID()) then
        SetButtonPulse(self, 60, 0.75);
    end
end

function PlayerTalentTab_GetBestDefaultTab(specIndex)
    if (not specIndex) then
        return DEFAULT_TALENT_TAB;
    end

    local spec = specs[specIndex];
    if (not spec) then
        return DEFAULT_TALENT_TAB;
    end

    local specInfoCache = talentSpecInfoCache[specIndex];
    TalentFrame_UpdateSpecInfoCache(specInfoCache, false, spec.pet, spec.talentGroup);
    if (specInfoCache.primaryTabIndex > 0) then
        return talentSpecInfoCache[specIndex].primaryTabIndex;
    else
        return DEFAULT_TALENT_TAB;
    end
end


-- PlayerGlyphTab

function PlayerGlyphTab_OnLoad(self)
    PlayerTalentFrameTab_OnLoad(self);

    self:RegisterEvent("PLAYER_LEVEL_UP");
    GLYPH_TALENT_TAB = self:GetID();
    -- we can record the text width for the glyph tab now since it never changes
    self.textWidth   = self:GetTextWidth();
end

function PlayerGlyphTab_OnClick(self)
    PlayerTalentFrameTab_OnClick(self);
    SetButtonPulse(_G["PlayerTalentFrameTab" .. GLYPH_TALENT_TAB], 0, 0);
end

function PlayerGlyphTab_OnEvent(self, _, ...)
    if (UnitLevel("player") == (SHOW_INSCRIPTION_LEVEL - 1) and PanelTemplates_GetSelectedTab(PlayerTalentFrame) ~= self:GetID()) then
        SetButtonPulse(self, 60, 0.75);
    end
end


-- Specs

-- PlayerTalentFrame_UpdateSpecs is a helper function for PlayerTalentFrame_Update.
-- Returns true on a successful update, false otherwise. An update may fail if the currently
-- selected tab is no longer selectable. In this case, the first selectable tab will be selected.
function PlayerTalentFrame_UpdateSpecs(activeTalentGroup, numTalentGroups)
    -- set the active spec highlight to be hidden initially, if a spec is the active one then it will
    -- be shown in PlayerSpecTab_Update
    PlayerTalentFrameActiveSpecTabHighlight:Hide();

    -- update each of the spec tabs
    local firstShownTab, lastShownTab;
    local numShown = 0;
    local offsetX  = 0;
    for i = 1, numSpecTabs do
        local frame     = _G["PlayerSpecTab" .. i];
        local specIndex = frame.specIndex;
        if (PlayerSpecTab_Update(frame, activeTalentGroup, numTalentGroups)) then
            firstShownTab = firstShownTab or frame;
            numShown      = numShown + 1;
            frame:ClearAllPoints();
            -- set an offsetX fudge if we're the selected tab, otherwise use the previous offsetX
            offsetX = specIndex == selectedSpec and SELECTEDSPEC_OFFSETX or offsetX;
            if (numShown == 1) then
                --...start the first tab off at a base location
                frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPRIGHT", offsetX, -36);
                -- we'll need to negate the offsetX after the first tab so all subsequent tabs offset
                -- to their default positions
                offsetX = -offsetX;
            else
                --...offset subsequent tabs from the previous one
                frame:SetPoint("TOPLEFT", lastShownTab, "BOTTOMLEFT", 0 + offsetX, -22);
            end
            lastShownTab = frame;
        else
            -- if the selected tab is not shown then clear out the selected spec
            if (specIndex == selectedSpec) then
                selectedSpec = nil;
            end
        end
    end

    if (not selectedSpec) then
        if (firstShownTab) then
            PlayerSpecTab_OnClick(firstShownTab);
        end
        return false;
    end

    if (numShown == 1 and lastShownTab) then
        -- if we're only showing one tab, we might as well hide it since it doesn't need to be there
        lastShownTab:Hide();
    end

    return true;
end

function PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups)
    local specIndex = self.specIndex;
    local spec      = specs[specIndex];

    -- determine whether or not we need to hide the tab
    local canShow   = spec.talentGroup <= numTalentGroups;

    if (not canShow) then
        self:Hide();
        return false;
    end

    local isSelectedSpec = specIndex == selectedSpec;
    local isActiveSpec   = spec.talentGroup == activeTalentGroup;
    local normalTexture  = self:GetNormalTexture();

    -- set the background based on whether or not we're selected
    if (isSelectedSpec and (SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT" or SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT_CHECKED")) then
        local name              = self:GetName();
        local backgroundTexture = _G[name .. "Background"];

        backgroundTexture:SetTexture("Interface\\TalentFrame\\UI-TalentFrame-SpecTab");
        backgroundTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -13, 11);

        if (SELECTEDSPEC_DISPLAYTYPE == "PUSHED_OUT_CHECKED") then
            self:GetCheckedTexture():Show();
        else
            self:GetCheckedTexture():Hide();
        end

    else
        local name              = self:GetName();
        local backgroundTexture = _G[name .. "Background"];
        backgroundTexture:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab");
        backgroundTexture:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 11);
    end

    -- update the active spec info
    local hasMultipleTalentGroups = numTalentGroups > 1;
    if (isActiveSpec and hasMultipleTalentGroups) then
        PlayerTalentFrameActiveSpecTabHighlight:ClearAllPoints();
        if (ACTIVESPEC_DISPLAYTYPE == "BLUE") then
            PlayerTalentFrameActiveSpecTabHighlight:SetParent(self);
            PlayerTalentFrameActiveSpecTabHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -13, 14);
            PlayerTalentFrameActiveSpecTabHighlight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 15, -14);
            PlayerTalentFrameActiveSpecTabHighlight:Show();
        elseif (ACTIVESPEC_DISPLAYTYPE == "GOLD_INSIDE") then
            PlayerTalentFrameActiveSpecTabHighlight:SetParent(self);
            PlayerTalentFrameActiveSpecTabHighlight:SetAllPoints(self);
            PlayerTalentFrameActiveSpecTabHighlight:Show();
        elseif (ACTIVESPEC_DISPLAYTYPE == "GOLD_BACKGROUND") then
            PlayerTalentFrameActiveSpecTabHighlight:SetParent(self);
            PlayerTalentFrameActiveSpecTabHighlight:SetPoint("TOPLEFT", self, "TOPLEFT", -3, 20);
            PlayerTalentFrameActiveSpecTabHighlight:Show();
        else
            PlayerTalentFrameActiveSpecTabHighlight:Hide();
        end
    end

    -- update the spec info cache
    TalentFrame_UpdateSpecInfoCache(talentSpecInfoCache[specIndex], false, PlayerTalentFrame.pet, spec.talentGroup);

    if (hasMultipleTalentGroups) then
        local specInfoCache   = talentSpecInfoCache[specIndex]
        local primaryTabIndex = specInfoCache.primaryTabIndex

        if specInfoCache[primaryTabIndex] and specInfoCache[primaryTabIndex].icon then
            normalTexture:SetTexture(specInfoCache[primaryTabIndex].icon)
        else
            normalTexture:SetTexture(spec.defaultSpecTexture)
        end
    end

    PlayerTalentFrame.talentCache = talentSpecInfoCache

    self:SetShown(not PlayerTalentFrame.pet)
    return true;
end

function PlayerSpecTab_Load(self, specIndex)
    self.specIndex      = specIndex;
    specTabs[specIndex] = self;
    numSpecTabs         = numSpecTabs + 1;

    -- set the spec's portrait
    local spec          = specs[self.specIndex];
    if (spec.portraitUnit) then
        SetPortraitTexture(self:GetNormalTexture(), spec.portraitUnit);
        self.usingPortraitTexture = true;
    else
        self.usingPortraitTexture = false;
    end

    -- set the checked texture
    if (SELECTEDSPEC_DISPLAYTYPE == "BLUE") then
        local checkedTexture = self:GetCheckedTexture();
        checkedTexture:SetTexture("Interface\\Buttons\\UI-Button-Outline");
        checkedTexture:SetWidth(64);
        checkedTexture:SetHeight(64);
        checkedTexture:ClearAllPoints();
        checkedTexture:SetPoint("CENTER", self, "CENTER", 0, 0);
    elseif (SELECTEDSPEC_DISPLAYTYPE == "GOLD_INSIDE") then
        local checkedTexture = self:GetCheckedTexture();
        checkedTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight");
    end

    local activeTalentGroup, numTalentGroups       = GetActiveTalentGroup(false, false), GetNumTalentGroups(false, false);
    local activePetTalentGroup, numPetTalentGroups = GetActiveTalentGroup(false, true), GetNumTalentGroups(false, true);
    PlayerSpecTab_Update(self, activeTalentGroup, numTalentGroups, activePetTalentGroup, numPetTalentGroups);
end

function PlayerSpecTab_OnClick(self, button)
    self = self or PlayerTalentFrame.specTabs[1]

    local selectedTalentGroup = C_Talent.GetSelectedTalentGroup()

    if button == "RightButton" then
        C_Talent.SetEditTalentGroup(self.specIndex)
        if not PlayerTalentPopupFrame:IsShown() then
            PlayerTalentPopupFrame:Show()
        else
            PlayerTalentPopupFrame_UpdateSettings(PlayerTalentPopupFrame)
        end

        self:SetChecked(selectedTalentGroup == self.specIndex)

        return
    elseif button == "LeftButton" then
        if PlayerTalentPopupFrame:IsShown() then
            PlayerTalentPopupFrame:Hide()
        end
    end

    if not selectedTalentGroup or selectedTalentGroup ~= self.specIndex then
        C_Talent.SelectTalentGroup( self.specIndex )
    else
        self:SetChecked(true)
    end
end

function PlayerSpecTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    local name = C_Talent.GetTalentGroupSettings(self.specIndex)
    if name and name ~= "" then
        GameTooltip:AddLine(name)
    else
        GameTooltip:AddLine(string.format(TALENT_TAB_NAME, self.specIndex))
    end

    if self.specIndex == C_Talent.GetActiveTalentGroup() then
        GameTooltip:AddLine(TALENT_ACTIVE_SPEC_STATUS, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
    end

    local pointsColor
    for index, tabInfo in pairs(self.tabInfo) do
        local tabPointSpent = C_Talent.GetTabPointSpent(self.specIndex)

        if tabInfo.isPrimary then
            pointsColor = GREEN_FONT_COLOR
        else
            pointsColor = HIGHLIGHT_FONT_COLOR
        end

        GameTooltip:AddDoubleLine(
                tabInfo.name,
                tabPointSpent[index],
                HIGHLIGHT_FONT_COLOR.r,
                HIGHLIGHT_FONT_COLOR.g,
                HIGHLIGHT_FONT_COLOR.b,
                pointsColor.r,
                pointsColor.g,
                pointsColor.b
        )
    end

    GameTooltip:AddLine(" ");
    GameTooltip:AddLine(CLICK_TALENT_TAB_SETTING, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, 1);
    GameTooltip:Show()
end

function PlayerTalentFrameTalent_OnDragStart(self, ...)
    if self.isExceptional and not self._isDisable then
        PickupSpell(GetSpellInfo(self.spellID))
    end
end

function TalentFrameButtonTemplate_OnUpdate( self )
    local name = self:GetName()

    if self:IsEnabled() == 0 then
        _G[name.."Left"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
        _G[name.."Middle"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
        _G[name.."Right"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
    else
        local selectedTalentGroup = C_Talent.GetSelectedTalentGroup()

        if selectedTalentGroup then
            local etherealPrefix = C_Talent.GetSelectedTalentGroup() > 2 and "-Ethereal" or ""

            if self.IsMouseDown then
                _G[name.."Left"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down"..etherealPrefix)
                _G[name.."Middle"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down"..etherealPrefix)
                _G[name.."Right"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down"..etherealPrefix)
            else
                _G[name.."Left"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up"..etherealPrefix)
                _G[name.."Middle"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up"..etherealPrefix)
                _G[name.."Right"]:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up"..etherealPrefix)
            end

            self:GetHighlightTexture():SetTexture("Interface\\Buttons\\UI-Panel-Button-Highlight"..etherealPrefix)
        end
    end
end

function PlayerTalentPopupFrame_OnLoad(self)
    self.buttons = {};
    self.searchResult = {};
    self.hasSearchResults = false;

    local previousButton = CreateFrame("CheckButton", "PlayerTalentPopupButton1", self, "PlayerTalentPopupButtonTemplate")
    self.buttons[1] = previousButton
    local cornerButton = previousButton
    previousButton:SetPoint("TOPLEFT", 24, -95)

    local numIcons = NUM_TALENT_POPUP_ICONS_PER_ROW * NUM_TALENT_POPUP_ICON_ROWS;
    for i = 2, numIcons do
        local newButton = CreateFrame("CheckButton", "PlayerTalentPopupButton"..i, self, "PlayerTalentPopupButtonTemplate")
        self.buttons[i] = newButton

        if i % NUM_TALENT_POPUP_ICONS_PER_ROW == 1 then
            newButton:SetPoint("TOPLEFT", cornerButton, "BOTTOMLEFT", 0, -8)
            cornerButton = newButton
        else
            newButton:SetPoint("LEFT", previousButton, "RIGHT", 10, 0)
        end

        previousButton = newButton
        newButton:Hide()
    end
end

function PlayerTalentPopupFrame_OnShow(self)
    PlayerTalentPopupFrame_UpdateSettings(self)
end

function PlayerTalentPopupFrame_OnHide(self)
    PlayerTalentPopupFrame_ResetSearch(self)
    C_Talent.SetEditTalentGroup(nil)
end

function PlayerTalentPopupFrame_UpdateSettings(self)
    local editTalentGroup = C_Talent.GetEditTalentGroup() or 1

    self.BorderBox.EditBox.Instructions:SetFormattedText(TALENT_TAB_NAME, editTalentGroup)

    local name, texture = C_Talent.GetTalentGroupSettings(editTalentGroup)
    self.BorderBox.EditBox:SetText(name or "")
    self.selectedIconTexture = texture or "Interface\\Icons\\INV_Misc_QuestionMark"

    PlayerTalentPopupFrame_Update()
end

function PlayerTalentPopupFrame_Update()
    local popupFrame = PlayerTalentPopupFrame
    local searchResults = popupFrame.searchResult
    local hasSearchResults = popupFrame.hasSearchResults
    local numIcons = hasSearchResults and #searchResults or GetNumMacroIcons()
    local offset = FauxScrollFrame_GetOffset(popupFrame.ScrollFrame)

    for i, popupButton in ipairs(popupFrame.buttons) do
        local index = (offset * NUM_ICONS_PER_ROW) + i
        local texture = GetMacroIconInfo(hasSearchResults and (searchResults[index] or 0) or index)

        if texture and texture ~= "" and index <= numIcons then
            popupButton.Icon:SetTexture(texture)
            popupButton:Show()
        else
            popupButton.Icon:SetTexture("")
            popupButton:Hide()
        end

        popupButton:SetChecked(PlayerTalentPopupFrame.selectedIconTexture == texture)
    end

    FauxScrollFrame_Update(popupFrame.ScrollFrame, ceil(numIcons / NUM_TALENT_POPUP_ICONS_PER_ROW), NUM_TALENT_POPUP_ICON_ROWS, TALENT_POPUP_ICON_ROW_HEIGHT)
end

function PlayerTalentPopupFrame_ResetSearch(self)
    self.BorderBox.SearchBox:SetText("")
    table.wipe(self.searchResult)
    self.hasSearchResults = false
end

function PlayerTalentPopupFrame_SearchUpdate(self)
    local searchText = strtrim(self.BorderBox.SearchBox:GetText() or "")

    if searchText == "" then
        self.hasSearchResults = false
    else
        table.wipe(self.searchResult)
        searchText = string.lower(searchText)

        for index = 1, GetNumMacroIcons() do
            local texture = GetMacroIconInfo(index)
            if texture and string.find(string.lower(texture), searchText, 1, true) then
                self.searchResult[#self.searchResult + 1] = index
            end
        end

        self.hasSearchResults = true
    end
end

function PlayerTalentPopupButton_OnClick(self)
    PlayerTalentPopupFrame.selectedIconTexture = self.Icon:GetTexture()
    PlayerTalentPopupFrame_Update()
end

function PlayerTalentPopuptCancelButton_OnClick(self)
    PlayerTalentPopupFrame:Hide()
    PlaySound("gsTitleOptionOK")
end

function PlayerTalentPopupOkayButton_OnClick(self)
    local popupFrame = PlayerTalentPopupFrame

    C_Talent.SetTalentGroupSettings(popupFrame.BorderBox.EditBox:GetText(), popupFrame.selectedIconTexture)

    PlayerTalentPopupFrame:Hide()
    PlayerTalentFrame_UpdateActiveSpec(GetActiveTalentGroup(), GetNumTalentGroups())
    PlayerTalentFrame_RefreshSpecTabs()
    PlaySound("gsTitleOptionOK")
end

function EventHandler:ASMSG_PLAYER_FAKE_TALENTS(msg)
    if tonumber(msg) == 1 and PlayerTalentFrame.previewState then
        TalentFrameSetupPreviewTalents()
        PlayerTalentFrame_Toggle()
        if SIRUS_TALENT_CACHE.playerName then
            PlayerTalentFrameTitleText:SetFormattedText(PLAYER_TALENT_PREVIEW_PLAYER_TITLE, SIRUS_TALENT_CACHE.playerName)
        else
            PlayerTalentFrameTitleText:SetText(PLAYER_TALENT_PREVIEW_TITLE)
        end
        PlayerGlyphPreviewFrame:SetShown(SIRUS_TALENT_CACHE.glyphData and
                SIRUS_TALENT_CACHE.glyphData[1] and
                SIRUS_TALENT_CACHE.glyphData[2] and
                (#SIRUS_TALENT_CACHE.glyphData[1] > 0 or #SIRUS_TALENT_CACHE.glyphData[2] > 0))
    end
end

function EventHandler:ASMSG_PLAYER_RESET_TALENTS_COST(msg)
    PlayerTalentFrame.resetTalentsCost = tonumber(msg)

    if PlayerTalentFrame.resetTalentsCost < 0 then
        StaticPopup_Show("PLAYER_TALENT_LEARN_PREVIEW_NO_PAY", PLAYER_TALENT_LEARN_PREVIEW_TEXT_NO_PAY)
    else
        PlayerTalentFrame.resetTalentsCost = (PlayerTalentFrame.resetTalentsCost * 100) * 100
        StaticPopup_Show("PLAYER_TALENT_LEARN_PREVIEW_PAY", PLAYER_TALENT_LEARN_PREVIEW_TEXT_PAY)
    end
end

function EventHandler:ASMSG_PLAYER_RESET_TALENTS(msg)
    msg = tonumber(msg)

    if msg == RESET_TALENTS_NO_USED_TALENT_POINTS then
        ResetGroupPreviewTalentPoints(false, PlayerTalentFrame.talentGroup)
    end

    TalentFramePreviewHide(true)

    if msg == RESET_TALENTS_OK or msg == RESET_TALENTS_NO_USED_TALENT_POINTS then
        PlayerTalentFrameHeaderFrame:Hide()
        PlayerTalentFrame.learnPreviewData             = GenerateTalentPreviewData()
        PlayerTalentFrame.learnPreviewTalentsAnimation = true
        TalentFrame_Update(PlayerTalentFramePanel1)
        TalentFrame_Update(PlayerTalentFramePanel2)
        TalentFrame_Update(PlayerTalentFramePanel3)
    elseif msg == RESET_TALENTS_NO_MONEY then
        UIErrorsFrame:AddMessage(ERR_NOT_ENOUGH_MONEY, 1.0, 0.1, 0.1, 1.0)
        TalentFramePreviewHide()
    elseif msg == RESET_TALENTS_NOT_IN_REST_ZONE then
        UIErrorsFrame:AddMessage(ERR_NOT_IN_REST_ZONE, 1.0, 0.1, 0.1, 1.0)
        TalentFramePreviewHide()
    end

    PlayerTalentFrame.resetTalents = nil
end

function EventHandler:ASMSG_SPEC_INFO( msg )
    local groupStorage      = C_Split(msg, "|")
    local activeTalentGroup = table.remove(groupStorage, 1)

    local cache = TALENT_CACHE:Get("ASMSG_SPEC_INFO", {})

    cache.activeTalentGroup = tonumber(activeTalentGroup)
    cache.talentGroupData   = {}

    for index, groupData in pairs(groupStorage) do
        local groupDataStorage = C_Split(groupData, ":")

        cache.talentGroupData[index] = {
            [1] = tonumber(groupDataStorage[1]),
            [2] = tonumber(groupDataStorage[2]),
            [3] = tonumber(groupDataStorage[3]),
        }
    end

    PlayerFrame_UpdateSpecTabs(PlayerTalentFrame)
    PlayerTalentFrame_Refresh()
end

enum:E_TALENTS_REFRESH_RESPONSE {
    "OK",
    "NOT_ENOUGH_ITEMS",
    "NOT_REST_ZONE"
}

function EventHandler:ASMSG_TALENTS_REFRESH( msg )
    msg = tonumber(msg)

    if msg == E_TALENTS_REFRESH_RESPONSE.OK then
        C_Talent.SelectTalentGroup()
    else
        UIErrorsFrame:AddMessage(_G["TALENTS_REFRESH_ERROR_"..msg], 1.0, 0.1, 0.1, 1.0)
    end

    PlayerTalentFrame.LoadingFrame:Hide()
end