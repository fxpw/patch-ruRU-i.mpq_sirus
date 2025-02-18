local ENTRY_LIST = {
	{"", "Россия/Беларусь", "РУ"},
	{"ProxyEU", "Украина/Европа", "EU"},
	{"Proxy", "Другое", "ДР"},
}

local realmCards = {
	[C_RealmInfo.GetServerListName(E_REALM_ID.SOULSEEKER)] = {
		cardFrame = "RealmListSoulseekerRealmCard",
	},
	[C_RealmInfo.GetServerListName(E_REALM_ID.SIRUS)] = {
		cardFrame = "RealmListSirusRealmCard",
	},
	[C_RealmInfo.GetServerListName(E_REALM_ID.SCOURGE)] = {
		cardFrame = "RealmListScourgeRealmCard",
	},
}

local realmCardsMini = {
	[C_RealmInfo.GetServerListName(E_REALM_ID.NELTHARION)] = true,
	[C_RealmInfo.GetServerListName(E_REALM_ID.LEGACY_X10)] = true,
	[C_RealmInfo.GetServerListName(E_REALM_ID.ALGALON)] = true,
}

function RealmList_OnLoad(self)
	self.buttonsList = {}
	self:RegisterEvent("OPEN_REALM_LIST")
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")

	self.entryPointIndex = tonumber(C_GlueCVars.GetCVar("REALM_ENTRY_POINT"))

	local scale = GetScreenWidth() < 1100 and GetScreenWidth() / 1100 or 1
	self.MainRealmCardHolder:SetScale(scale)

	self.realmCards = {}

	for realmName, cardData in pairs(realmCards) do
		local card = _G[cardData.cardFrame]
		card:SetScale(scale)
		table.insert(self.realmCards, card)
	end

	self.MainRealmCardHolder:SetWidth(250 * #self.realmCards + 20 * (#self.realmCards - 1))
end

function RealmList_OnEvent(self, event)
	if event == "OPEN_REALM_LIST" then
		self:Show()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		for index, card in ipairs(self.realmCards) do
			card.BorderFrame:SetScale(PixelUtil.GetPixelToUIUnitFactor())
		end
	end
end

function RealmList_OnShow(self)
	GlueDialog:HideDialog("SERVER_WAITING")

	if self.updateList then
		self.updateList:Cancel()
		self.updateList = nil
	end

	self.updateList = C_Timer:NewTicker(C_RealmList.RealmListUpdateRate(), function()
		if not self:IsShown() and self.updateList then
			self.updateList:Cancel()
			self.updateList = nil
			return
		end

		RealmList_Update()
	end)

	RealmList_Update()
end

function RealmList_OnHide(self)
	if self.updateList then
		self.updateList:Cancel()
		self.updateList = nil
	end

	C_RealmList.CancelRealmListQuery()
	GlueTooltip:Hide()
end

function RealmList_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		RealmListCancel_OnClick()
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot()
	end
end

function RealmList_Update()
	C_RealmList.RequestRealmList()

	local realmCount = C_RealmList.GetNumRealms()
	local cardCount = 0
	local miniCardCount = 0
	local buttonsCount = 0

	RealmList.NoRealmText:SetShown(realmCount == 0)

	for _, v in pairs(realmCards) do
		table.wipe(_G[v.cardFrame].entryList)
	end

	for realmIndex = 1, realmCount do
		local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types, realmZone, realmID = C_RealmList.GetRealmInfo(realmIndex)

		if name then
			local realmcardSettings = realmCards[name]

			if realmcardSettings then
				local frame = _G[realmcardSettings.cardFrame]

				frame.realmZone = realmZone
				frame.realmID = realmID
				frame.entryList[#frame.entryList + 1] = {
					realmZone = realmZone,
					realmID = realmID,
					realmDown = realmDown == 1,
				}

				frame:SetDisabledRealm(realmDown == 1)

				for entryIndex = 2, #ENTRY_LIST do
					local entryRealmName = string.format("%s %s", ENTRY_LIST[entryIndex][1], name)
					local _, _, _, proxyRealmDown, _, _, _, _, _, _, _, _, _, _, proxyRealmZone, proxyRealmID = C_RealmList.GetRealmByName(entryRealmName)

					if (proxyRealmID) then
						frame.entryList[#frame.entryList + 1] = {
							realmZone = proxyRealmZone,
							realmID = proxyRealmID,
							realmDown = proxyRealmDown == 1,
						}

						if ENTRY_LIST[entryIndex][1] == "Proxy" then
							frame.ProxyFrame.ProxyButton.realmZone = proxyRealmZone
							frame.ProxyFrame.ProxyButton.realmID = proxyRealmID

							frame.ProxyFrame.ProxyButton:SetEnabled(not proxyRealmDown)
						end
					end
				end

				realmcardSettings.setup = true
			elseif realmCardsMini[name] then
				miniCardCount = miniCardCount + 1
				local card = _G["RealmListMiniRealmCard"..miniCardCount]

				if card then
					card.RealmButton.realmID = realmID
					card.RealmButton.realmZone = realmZone

					card.RealmName:SetText(name)

					card:Show()
				end
			elseif not string.find(name, "3.3.5", 1, true) then
				buttonsCount = buttonsCount + 1
				local button = RealmList.buttonsList[buttonsCount]

				if not button then
					button = CreateFrame("Button", "RealmSelectButton"..buttonsCount, RealmList, "RealmListButtonTemplate")

					if buttonsCount == 1 then
						button:SetPoint("TOPLEFT", 15, -15)
					elseif buttonsCount % 4 == 1 then
						button:SetPoint("TOP", RealmList.buttonsList[buttonsCount - 4], "BOTTOM", 0, -5)
					else
						button:SetPoint("LEFT", RealmList.buttonsList[buttonsCount - 1], "RIGHT", 10, 0)
					end

					RealmList.buttonsList[buttonsCount] = button
				end

				button.realmID = realmID
				button.realmZone = realmZone

				button:SetEnabled(not realmDown)
				button:SetText(name)
				button:Show()
			elseif not C_RealmInfo.GetServerIDByName(name) then
				if IsInterfaceDevClient() then
					GMError(string.format("Unknown realm '%s'", name))
				end
			end
		end
	end

	for i = buttonsCount + 1, #RealmList.buttonsList do
		RealmList.buttonsList[i]:Hide()
	end

	for i = 4, cardCount + 1, -1 do
		local card = _G["RealmListRealmCard"..i]

		if card then
			card:Hide()
		end
	end

	for i = 4, miniCardCount + 1, -1 do
		local card = _G["RealmListMiniRealmCard"..i]

		if card then
			card:Hide()
		end
	end

	local miniCardOffset = 0
	local lastMiniCard

	for i = 1, miniCardCount do
		local card = _G["RealmListMiniRealmCard"..i]
		if card:IsShown() then
			miniCardOffset = miniCardOffset + 1
			if lastMiniCard then
				card:SetPoint("BOTTOMLEFT", lastMiniCard, "TOPLEFT", 0, 20)
			else
				card:SetPoint("BOTTOMLEFT", 20, 20)
			end
			lastMiniCard = card
		end
	end

	local entryList = {}

	for _, v in pairs(realmCards) do
		local frame = _G[v.cardFrame]
		if not v.setup then
			frame:SetDisabledRealm(true)
		else
			if #frame.entryList > 2 then
				for entryIndex, entry in ipairs(frame.entryList) do
					if not entryList[entryIndex] then
						entryList[entryIndex] = {}
						entryList[entryIndex].realmDown = true
					end

					if not entry.realmDown then
						entryList[entryIndex].realmDown = false
					end
				end

				frame.ProxyFrame:SetShown(false)
			else
				frame.ProxyFrame:SetShown(#frame.entryList ~= 0)
			end
		end
	end

	if #entryList > 2 then
		RealmList.EntryPoint:SetProxyList(entryList)

		if not RealmList.entryPointIndex then
			RealmProxyDialog:Show()
		end
	end

	RealmList.EntryPoint:SetShown(#entryList > 2)
end

function RealmListRealmSelect_OnClick(self, button)
	if self.realmID then
		local entryRealmZone, entryRealmID

		if self.entryList and RealmList.EntryPoint:IsShown() then
			local realmEntryIndex = RealmList.entryPointIndex or 1
			local entryData = self.entryList[realmEntryIndex] or self.entryList[1]
			if not entryData.realmDown then
				entryRealmZone = entryData.realmZone
				entryRealmID = entryData.realmID
			else
				RealmProxyDialog.skipHelp = true
				RealmProxyDialog:Show()
				RealmProxyDialog:UpdateProxyList(self.entryList)
				return
			end
		end

		RealmList:Hide()
		PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
		C_RealmList.ChangeRealm(entryRealmZone or self.realmZone, entryRealmID or self.realmID)
	end
end

function RealmListCancel_OnClick(self, button)
	PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_CANCEL)
	RealmList:Hide()
	C_RealmList.RealmListDialogCancelled()
end

local REALM_CARDS = {
	Sirus = {
		id = E_REALM_ID.SIRUS,
		overlay = true,
		color = {1, 0.796, 0.0784},
		models = {
			{
				file = [[World\Expansion02\doodads\ulduar\ul_banister01.m2]],
				scale = 0.037,
				position = {0.076, 0.209, 0},
			},
			{
				file = [[spells\s_realm_card_fx.m2]],
				scale = 0.003,
				position = {0.072, 0.209, 0},
				alpha = 0.7,
			},
		},
	},
	Algalon = {
		id = E_REALM_ID.ALGALON,
		color = {0.0902, 0.314, 0.714},
		models = {
			{
				file = [[World\Expansion02\doodads\ulduar\ul_brain_01.m2]],
				scale = 0.008,
				position = {0.082, 0.206, 0},
				alpha = 0.4,
			},
		},
	},
	Scourge = {
		id = E_REALM_ID.SCOURGE,
		color = {0, 0.443, 0.4235},
		models = {
			{
				file = [[World\Expansion02\doodads\generic\scourge\sc_castingcircle_01.m2]],
				scale = 0.021,
				position = {0.079, 0.209, 0},
				alpha = 0.1,
			},
			{
				file = [[World\Expansion02\doodads\generic\scourge\sc_spirits_01.m2]],
				scale = 0.011,
				position = {0.072, 0.202, 0},
				alpha = 0.2,
			},
		},
	},
	Soulseeker = {
		id = E_REALM_ID.SOULSEEKER,
		bgColor = {0, 0, 0},
		color = {0.314, 0.541, 0.584},
		solidBorders = true,
		scaleLogo = true,
		models = {
			{
				file = [[world\expansion08\doodads\fx\9fx_maw_soulriver_straight_01.m2]],
				scale = 0.0028,
				position = {0.079, 0.085, 0.000},
				alpha = 1,
				angle = 90,
			},
			{
				file = [[world\expansion08\doodads\fx\9fx_torghast_soulriver_06.m2]],
				scale = 0.0025,
				position = {0.079, 0.210, 0.000},
				alpha = 1,
			},
		},
	},
}

local baseHeight = 768
local baseWidth = 1920 / 1080 * baseHeight
local baseCamera = math.sqrt(baseWidth * baseWidth + baseHeight * baseHeight)

local function GetScaledModelPosition(model, x, y, z)
	local effectiveScale = model:GetEffectiveScale()
	local width = GetScreenWidth() * effectiveScale
	local height = GetScreenHeight() * effectiveScale
	local scaledCamera = math.sqrt(width * width + height * height)
	local mult = (baseCamera / scaledCamera)

	return x * mult, y * mult, z * mult
end

RealmListCardTemplateMixin = {}

function RealmListCardTemplateMixin:OnLoad()
	self.BorderFrame.borders = {
		self.BorderFrame.Top,
		self.BorderFrame.Bottom,
		self.BorderFrame.Left,
		self.BorderFrame.Right,
	}

	self.models = {}
	self.entryList = {}

	self:UpdateStyle()
end

function RealmListCardTemplateMixin:OnShow()
	self:UpdateFrameLevels()
end

function RealmListCardTemplateMixin:UpdateFrameLevels()
	local frameLevel = self:GetFrameLevel()

	self.ProxyFrame:SetFrameLevel(frameLevel)
	self.BackgroundFrame:SetFrameLevel(frameLevel)

	for i, model in ipairs(self.models) do
		model:SetFrameLevel(frameLevel + i)
	end

	local numModels = #self.models
	self.ContentFrame:SetFrameLevel(frameLevel + numModels + 1)
	self.OverlayFrame:SetFrameLevel(frameLevel + numModels + 2)
	self.LogoFrame:SetFrameLevel(frameLevel + numModels + 3)
	self.EnterButton:SetFrameLevel(frameLevel + numModels + 4)
	self.BorderFrame:SetFrameLevel(frameLevel + numModels + 5)
end

function RealmListCardTemplateMixin:UpdateStyle()
	local styleName = self:GetAttribute("style")
	local style = REALM_CARDS[styleName]
	if not style then
		error(string.format("Card with '%s' style not found", tostring(styleName)), 2)
	end

	local name, description, rates, realmType, label = C_RealmInfo.GetServerInfo(style.id)
	local logo = C_RealmInfo.GetServerLogo(style.id)
	local colorR, colorG, colorB = unpack(style.color, 1, 3)

	self.EnterButton.NormalTexture:SetAtlas("Custom-Realm-Card-Button")
	self.EnterButton.DisabledTexture:SetAtlas("Custom-Realm-Card-Button")
	self.EnterButton.PushedTexture:SetAtlas("Custom-Realm-Card-Button-Pressed")
	self.EnterButton.HighlightTexture:SetAtlas("Custom-Realm-Card-Button")
	self.EnterButton.NormalTexture:SetVertexColor(colorR, colorG, colorB)
	self.EnterButton.DisabledTexture:SetVertexColor(0.5, 0.5, 0.5)
	self.EnterButton.PushedTexture:SetVertexColor(colorR, colorG, colorB)
	self.EnterButton.HighlightTexture:SetVertexColor(colorR, colorG, colorB)

	if style.bgColor then
		self.BackgroundFrame.Background:SetTexture(unpack(style.bgColor, 1, 3))
	end

	if style.solidBorders then
		self.BorderFrame:SetScale(PixelUtil.GetPixelToUIUnitFactor())
		for _, border in ipairs(self.BorderFrame.borders) do
			border:SetTexture(colorR, colorG, colorB)
			border:Show()
		end
		self.solidBorders = true
	else
		self.BorderFrame.Border:Show()
		self.BackgroundFrame.Background:SetAtlas(("Custom-Realm-Card-%s-Background"):format(styleName))
		self.BorderFrame.Border:SetAtlas(("Custom-Realm-Card-%s-Border"):format(styleName))
	end

	if style.scaleLogo then
		local atlasInfo = C_Texture.GetAtlasInfo(logo)
		self.LogoFrame:SetWidth(math.ceil(atlasInfo.width * (self.LogoFrame:GetHeight() / atlasInfo.height)))
	end

	self.LogoFrame.Logo:SetAtlas(logo)
	self.ContentFrame.RealmName:SetFormattedText("%s x%i", name:upper(), rates)
	self.ContentFrame.RealmDescription:SetText(description)
	self.ContentFrame.RealmRate:SetFormattedText("x%i", rates)
	self.ContentFrame.RealmPVPStatus:SetText(_G["REALM_TYPE_"..realmType])

	if style.overlay then
		self.OverlayFrame.Overlay:SetAtlas(("Custom-Realm-Card-%s-Overlay"):format(styleName))
		self.OverlayFrame:Show()
	end

	if label then
		self.LabelFrame.Background:SetAtlas(("Custom-Realm-Card-%s-Driver"):format(styleName))
		self.LabelFrame.Text:SetText(label)
		self.LabelFrame:Show()
	end

	for i, modelData in ipairs(style.models) do
		local model = self.models[i]
		if not model then
			model = CreateFrame("Model", ("$parentModel%i"):format(i), self.BackgroundFrame)
			self.models[i] = model
		end
		model:SetPoint("TOPLEFT", 1, -1)
		model:SetPoint("BOTTOMRIGHT", 0, 0)

		model:SetModel(modelData.file)
		model:SetPosition(GetScaledModelPosition(model, unpack(modelData.position)))
		model:SetModelScale(modelData.scale or 1)
		model:SetAlpha(modelData.alpha or 1)
		model:SetFacing(math.rad(modelData.angle or 0))
	end

	if self:IsShown() then
		self:UpdateFrameLevels()
	end
end

function RealmListCardTemplateMixin:SetDisabledRealm(toggle)
	self.BackgroundFrame.Background:SetDesaturated(toggle)
	self.LogoFrame.Logo:SetDesaturated(toggle)
	self.LabelFrame.Background:SetDesaturated(toggle)
	self.OverlayFrame.Overlay:SetDesaturated(toggle)

	if self.solidBorders then
		for _, border in ipairs(self.BorderFrame.borders) do
			border:SetDesaturated(toggle)
		end
	else
		self.BorderFrame.Border:SetDesaturated(toggle)
	end

	self.EnterButton:SetEnabled(not toggle)
end

RealmProxyDialogMixin = {}

function RealmProxyDialogMixin:OnLoad()
	self.buttonPool = CreateFramePool("Button", self.Container, "GlueDark_ButtonTemplate")
end

function RealmProxyDialogMixin:OnShow()
	self:SetStep(1)
	self:UpdateProxyList()
end

function RealmProxyDialogMixin:OnHide()
	self.step = nil
	self.skipHelp = nil
	self.selectedEntryIndex = nil
end

function RealmProxyDialogMixin:OnKeyDown(key)
	if key == "ESCAPE" then
		self:Cancel()
	elseif key == "ENTER" and self.step == 2 then
		self:SetStep(3)
	end
end

function RealmProxyDialogMixin:SetStep(step)
	self.step = step

	if step == 1 then
		self.Container.OKButton:Hide()
		self.Container.CancelButton:Show()
		self.Background:Show()
		self.Container:SetWidth(250)
		self.Container.Title:Show()
		self.Container.Text:Hide()
	elseif step == 2 then
		self.Container.OKButton:Show()
		self.Container.CancelButton:Hide()
		self.buttonPool:ReleaseAll()
		self.Background:Hide()
		self.Container:SetSize(410, 170)
		self.Container.Title:Hide()
		self.Container.Text:SetFormattedText(WORLD_PROXY_LOCATION_TEXT, ENTRY_LIST[self.selectedEntryIndex][3])
		self.Container.Text:Show()

		C_GlueCVars.SetCVar("REALM_ENTRY_POINT", self.selectedEntryIndex)
		RealmList.entryPointIndex = self.selectedEntryIndex
		RealmList.EntryPoint:SetProxyList(nil, true)

		self:SetupHelpFrame()
	elseif step == 3 then
		RealmList.EntryPoint.BG:Hide()
		RealmList.EntryPoint.HelpArrow:Hide()
		RealmList.EntryPoint:SetFrameStrata(RealmList.EntryPoint._strata)
		RealmList.EntryPoint:SetFrameLevel(RealmList.EntryPoint._flevel)
		RealmList.EntryPoint._strata = nil
		RealmList.EntryPoint._flevel = nil
		self:Hide()
	end
end

function RealmProxyDialogMixin:NextStep(hide)
	self:SetStep(self.step + 1)
	if self.step == 2 and self.skipHelp then
		self:SetStep(self.step + 1)
	end
	PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_ACCT_OPTIONS)
end

function RealmProxyDialogMixin:Cancel()
	if self.step == 1 then
		RealmList.entryPointIndex = 1
		C_GlueCVars.SetCVar("REALM_ENTRY_POINT", 1)
		RealmList.EntryPoint:SetProxyList(nil, true)
		self:Hide()
	elseif self.step == 2 then
		self:SetStep(3)
	end
end

local selectEntryButtonOnClick = function(self, button)
	if button ~= "LeftButton" then return end
	self.parent.selectedEntryIndex = self:GetID()
	self.parent:NextStep()
end

function RealmProxyDialogMixin:UpdateProxyList(entryList)
	self.buttonPool:ReleaseAll()

	local realmProxyIndex = 1

	local prevButton
	for i = 1, #ENTRY_LIST do
		local button = self.buttonPool:Acquire()
		button.parent = self
		button:SetFormattedText("%i. %s", i, ENTRY_LIST[i][2])
		button:SetID(i)

		if i == 1 then
			button:SetPoint("TOP", self.Container, "TOP", 0, -50)
		else
			button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, -10)
		end

		button:SetScript("OnClick", selectEntryButtonOnClick)

		if entryList then
			button:SetEnabled(not entryList[i].realmDown)
		else
			button:Enable()
		end

		button:Show()
		prevButton = button
	end

	self.Container:SetHeight(#ENTRY_LIST * 20 + 180)
	self.selectedEntryIndex = realmProxyIndex
end

function RealmProxyDialogMixin:SetupHelpFrame()
	self.HelpHightlight.Left:ClearAllPoints()
	self.HelpHightlight.Left:SetPoint("TOPRIGHT", RealmList.EntryPoint.BG, "TOPLEFT", 0, 0)
	self.HelpHightlight.Left:SetPoint("BOTTOMRIGHT", RealmList.EntryPoint.BG, "BOTTOMLEFT", 0, 0)
	self.HelpHightlight.Left:SetPoint("LEFT", GlueParent, "LEFT", 0, 0)

	self.HelpHightlight.Right:ClearAllPoints()
	self.HelpHightlight.Right:SetPoint("TOPLEFT", RealmList.EntryPoint.BG, "TOPRIGHT", 0, 0)
	self.HelpHightlight.Right:SetPoint("BOTTOMLEFT", RealmList.EntryPoint.BG, "BOTTOMRIGHT", 0, 0)
	self.HelpHightlight.Right:SetPoint("RIGHT", GlueParent, "RIGHT", 0, 0)

	self.HelpHightlight.Top:ClearAllPoints()
	self.HelpHightlight.Top:SetPoint("TOPLEFT", GlueParent, "TOPLEFT", 0, 0)
	self.HelpHightlight.Top:SetPoint("BOTTOMRIGHT", self.HelpHightlight.Right, "TOPRIGHT", 0, 0)

	self.HelpHightlight.Bottom:ClearAllPoints()
	self.HelpHightlight.Bottom:SetPoint("BOTTOMLEFT", GlueParent, "BOTTOMLEFT", 0, 0)
	self.HelpHightlight.Bottom:SetPoint("TOPRIGHT", self.HelpHightlight.Right, "BOTTOMRIGHT", 0, 0)

	RealmList.EntryPoint.BG:Show()
	RealmList.EntryPoint.HelpArrow:Show()
	RealmList.EntryPoint._strata = RealmList.EntryPoint:GetFrameStrata()
	RealmList.EntryPoint._flevel = RealmList.EntryPoint:GetFrameLevel()
	RealmList.EntryPoint:SetFrameStrata("FULLSCREEN")
	RealmList.EntryPoint:SetFrameLevel(50)

	self.HelpHightlight:Show()
end

RealmEntryPointMixin = {}

function RealmEntryPointMixin:OnLoad()
	self.buttonPool = CreateFramePool("Button", self, "RealmEntrySelectButtonTemplate")
	SetClampedTextureRotation(self.HelpArrow, 90)
end

local ENTRY_BUTTON_OFFSET = -3
local ENTRY_BUTTON_HEIGHT = 32
local ENTRY_BUTTON_WIDTH = 32
function RealmEntryPointMixin:SetProxyList(entryList, forceUpdate)
	if forceUpdate and not entryList then
		entryList = self.entryList
	elseif not forceUpdate and self.entryList and tCompare(self.entryList, entryList) then
		return
	end

	self.entryList = entryList
	self.buttonPool:ReleaseAll()

	if #entryList == 0 then
		self:Hide()
		return
	end

	local realmEntryIndex = RealmList.entryPointIndex or 1

	local prevButton
	for i, entry in ipairs(entryList) do
		local button = self.buttonPool:Acquire()
		button.parent = self
		button:SetFormattedText(ENTRY_LIST[i][3])
		button:SetID(i)

		if i == 1 then
			button:SetPoint("LEFT", self, "LEFT", 0, 0)
		else
			button:SetPoint("LEFT", prevButton, "RIGHT", ENTRY_BUTTON_OFFSET, 0)
		end

	--	button.realmZone = entry.realmZone
	--	button.realmID = entry.realmID

		button:SetWidth(ENTRY_BUTTON_WIDTH)
		button:SetActive(i == realmEntryIndex)
		button:SetEnabled(not entry.realmDown)

		button:Show()
		prevButton = button
	end

	self.selectedEntryIndex = realmEntryIndex
	self:SetWidth((#entryList - 1) * (ENTRY_BUTTON_WIDTH + ENTRY_BUTTON_OFFSET) + ENTRY_BUTTON_WIDTH)
	self:SetHeight(ENTRY_BUTTON_HEIGHT)
	self:Show()
end

function RealmEntryPointMixin:OnEnter()
	local text = string.format(WORLD_PROXY_LOCATION_TEXT, ENTRY_LIST[self.selectedEntryIndex][2])
	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GlueTooltip:SetText(text, 1.0, 1.0, 1.0, 1.0, 1)
	GlueTooltip:Show()
end

function RealmEntryPointMixin:OnLeave()
	GlueTooltip:Hide()
end

RealmEntrySelectButtonMixin = {}

function RealmEntrySelectButtonMixin:OnLoad()
	self.BorderHightlight.Left:SetVertexColor(0.5, 0.5, 0)
	self.BorderHightlight.Middle:SetVertexColor(0.5, 0.5, 0)
	self.BorderHightlight.Right:SetVertexColor(0.5, 0.5, 0)
end

function RealmEntrySelectButtonMixin:OnEnter()
	GlueTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self:IsEnabled() == 1 then
		GlueTooltip:SetText(ENTRY_LIST[self:GetID()][2], 1, 1, 1, 1, 1)
	else
		GlueTooltip:SetText(ENTRY_LIST[self:GetID()][2], 0.5, 0.5, 0.5, 1, 1)
		GlueTooltip:AddLine(CHAR_LOGIN_NO_WORLD, 1, 1, 1, 1, 1)
	end
	GlueTooltip:Show()
end

function RealmEntrySelectButtonMixin:OnLeave()
	GlueTooltip:Hide()
end

function RealmEntrySelectButtonMixin:OnClick(button)
	if button ~= "LeftButton" then return end

	local index = self:GetID()

	if self.parent.selectedEntryIndex == index then
		self:SetActive(true)
		return
	end

	for buttonObj in self.parent.buttonPool:EnumerateActive() do
		if buttonObj ~= self then
			buttonObj:SetActive(false)
		end
	end

	self:SetActive(true)

	self.parent.selectedEntryIndex = index
	RealmList.entryPointIndex = index
	C_GlueCVars.SetCVar("REALM_ENTRY_POINT", index)

	GlueTooltip:Hide()
	self:GetParent():OnEnter()

	PlaySound("igMainMenuOptionCheckBoxOn")
end

function RealmEntrySelectButtonMixin:SetActive(active)
	self.BorderHightlight:SetShown(active)
end