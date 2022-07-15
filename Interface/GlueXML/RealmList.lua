--	Filename:	RealmList.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

local MAX_REALM_ZONE = 37
local MAX_REALM_COUNT = 18

REALM_SET = {}
REALM_ARRAY = {}

_G._GetNumRealms = GetNumRealms
function _G.GetNumRealms()
	return #REALM_ARRAY
end

_G._GetRealmInfo = GetRealmInfo
function GetRealmInfo(realmIndex, ...)
	if not REALM_ARRAY[realmIndex] then return end
	return unpack(REALM_ARRAY[realmIndex])
end

local function padNumber(x)
	return string.format("%03d", x)
end
local function sortRealms(a, b)
	return a[1]:lower():gsub("%d+", padNumber) < b[1]:lower():gsub("%d+", padNumber)
end

_G._RequestRealmList = RequestRealmList
function _G.RequestRealmList(...)
	_RequestRealmList(...)

	table.wipe(REALM_SET)
	table.wipe(REALM_ARRAY)

	local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types

	for realmZone = 1, MAX_REALM_ZONE do
		for realmID = 1, MAX_REALM_COUNT do
			name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types = _GetRealmInfo(realmZone, realmID)

			if name and not REALM_SET[name] then
				REALM_ARRAY[#REALM_ARRAY + 1] = {name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types, realmZone, realmID}
				REALM_SET[name] = -1
			end
		end
	end

	table.sort(REALM_ARRAY, sortRealms)

	for realmIndex = 1, #REALM_ARRAY do
		REALM_SET[REALM_ARRAY[realmIndex][1]] = realmIndex
	end
end

function GetRealmByName(realmName)
	if not REALM_SET[realmName] then return end
	return unpack(REALM_ARRAY[REALM_SET[realmName]])
end

_G._RealmListUpdateRate = RealmListUpdateRate
function RealmListUpdateRate()
	if S_IsDevClient and S_IsDevClient() then
		return 1
	end
	return _RealmListUpdateRate()
end

local ENTRY_LIST = {
	{"", "Россия/Беларусь", "РУ"},
	{"ProxyEU", "Украина/Европа", "EU"},
	{"Proxy", "Другое", "ДР"},
}

local realmCards = {
	[SHARED_SIRUS_REALM_NAME] = {
		cardFrame = "RealmListSirusRealmCard",
	},
	[SHARED_SCOURGE_REALM_NAME] = {
		cardFrame = "RealmListScourgeRealmCard",
	},
	[SHARED_ALGALON_REALM_NAME] = {
		cardFrame = "RealmListAlgalonRealmCard",
	},
}

local realmCardsData = {
	[SHARED_NELTHARION_REALM_NAME] = {
		name = "Neltharion",
		rate = "x3",
		types = "PvP",
		typesTooltip = "Неотключаемый PvP режим",
		description = "Самый «горячий» из наших миров, заточенный под WPVP сражения. Включает в себя как постепенную прогрессию PVE-контента, так и нонстоп PVP активности по всему миру. Если в свободное от походов в рейды время Вас привлекает охота за головами, противостояние фракций, нападение на столицы и города противника, то Neltharion однозначно Ваш выбор, времяпрепровождение на котором подарит Вам море адреналина.",
		logo = "ServerGameLogo-2",
		desingKey = "Neltharion",
		minimize = true
	},
	--[SHARED_FROSTMOURNE_REALM_NAME] = {
	--	name = "Frostmourne",
	--	rate = "Рейты: x1",
	--	types = "Тип мира: PVE",
	--	description = "Новый мир, ожидающий своих героев, полный достижений и открытий, еще никем не виданных.\n\nСтаньте первым, кто завоюет себе звание настоящего героя и получит предметы невиданной ценности из рейдовых подземелий!",
	--	logo = "ServerGameLogo-2",
	--	desingKey = "Frostmourne"
	--},
	[SHARED_SCOURGE_REALM_NAME] = {
		name = "Scourge",
		rate = "x2",
		types = "Режим войны",
		typesTooltip = "Переключаемый в столицах режим пвп",
		description = "Прогрессивный игровой мир с преуспевающим освоением как PvP, так и PvE-аспектов. Сочетает в себе множество внутриигровых изменений и лучших кастомных внедрений в стандартный клиент. Scourge готов подарить Вам максимум приятных впечатлений от игры. Однако, если Вы хотите стать легендой, то придётся приложить немало усилий. Что бы Вы ни любили: рейды, подземелья, поля боя или арены - этому миру будет что Вам предложить.",
		logo = "ServerGameLogo-3",
		desingKey = "Frostmourne",
	},
	[SHARED_LEGACY_X10_REALM_NAME] = {
		name = "Sirus",
		rate = "x10",
		types = "FFA",
		typesTooltip = "Классический \"Каждый сам за себя\"",
		description = "Мир тех, кто уже достиг настоящих высот, тех, кто стал покорителями Нордскола и Запределья.\n\nЕсли Вы хотите настоящего соревнования, хотите встать на одну вершину с легендами - Вам сюда!",
		logo = "ServerGameLogo-1",
		minimize = true
	},
	[SHARED_ALGALON_REALM_NAME] = {
		name = "Algalon",
		rate = "x4",
		types = "PvP",
		typesTooltip = "Неотключаемый PvP режим",
		description = "Активно развивающийся игровой мир без системы категорий, очков усилений и других кастомных изменений. Перед нами стояла задача сохранить для Вас привычный баланс в PvP времён 3.3.5а с применением только лучших наработок, которые были оценены игроками по достоинству. Поэтапное PvE-освоение и полный набор PvP-атрибутов позволят Вам открыть для себя WoTLK по-новому.",
		logo = "ServerGameLogo-4",
		desingKey = "Algalon",
	},
}

function RealmList_OnLoad(self)
	self.buttonsList = {}
	self:RegisterEvent("OPEN_REALM_LIST")

	self.entryPointIndex = tonumber(C_GlueCVars.GetCVar("REALM_ENTRY_POINT"))
end

function RealmList_OnEvent(self, event)
	if event == "OPEN_REALM_LIST" then
		self:Show()
	end
end

function RealmList_OnShow(self)
	GlueDialog:HideDialog("SERVER_WAITING")

	if self.updateList then
		self.updateList:Cancel()
		self.updateList = nil
	end

	self.updateList = C_Timer:NewTicker(RealmListUpdateRate(), function()
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

	CancelRealmListQuery()
	GlueTooltip:Hide()
end

function RealmList_OnKeyDown( self, key, ... )
	if ( key == "ESCAPE" ) then
		RealmListCancel_OnClick()
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot()
	end
end

function RealmList_Update()
	RequestRealmList()

	local realmCount = GetNumRealms()
	local cardCount = 0
	local miniCardCount = 0
	local buttonsCount = 0

	if realmCount == 0 then
		RealmList.NoRealmText:Show()
	end

	for _, v in pairs(realmCards) do
		table.wipe(_G[v.cardFrame].entryList)
	end

	for realmIndex = 1, realmCount do
		local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types, realmZone, realmID = GetRealmInfo(realmIndex)

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

				for entryIndex = 2, #ENTRY_LIST do
					local entryRealmName = string.format("%s %s", ENTRY_LIST[entryIndex][1], name)
					local _, _, _, proxyRealmDown, _, _, _, _, _, _, _, _, _, _, proxyRealmZone, proxyRealmID = GetRealmByName(entryRealmName)

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
			end

			if not string.find(name, "3.3.5", 1, true) then
				buttonsCount = buttonsCount + 1
				local button = RealmList.buttonsList[buttonsCount]

				if not button then
					button = CreateFrame("Button", "RealmSelectButton"..buttonsCount, RealmList, "NormalChoiceButtonTemplate")

					if buttonsCount == 1 then
						button:SetPoint("TOPLEFT", 15, -15)
					elseif mod(buttonsCount - 1, 4) == 0 then
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
			end

			if RealmList.NoRealmText:IsShown() then
				RealmList.NoRealmText:Hide()
			end

			if false and realmCardsData and realmCardsData[name] and not realmCardsData[name].minimize then
				cardCount = cardCount + 1

				local data = realmCardsData[name]
				local card = _G["RealmListRealmCard"..cardCount]

				if card then
					card.SnowEffect:Hide()

					if data.desingKey and data.desingKey == "Frostmourne" then
						card.BG:SetTexture(0.51, 0.75, 0.89)

						card.BORDER:SetTexture("Interface\\Artifacts\\ArtifactUIDeathKnightFrost")
						card.BORDER:SetTexCoord(0.000976562, 0.875977, 0.000976562, 0.601562)
						card.BORDER:SetAlpha(1)

						card.Art.TitleBackground:SetTexture("Interface\\Artifacts\\ArtifactUIDeathKnightFrost")
						card.Art.TitleBackground:SetTexCoord(0.000976562, 0.704102, 0.603516, 0.725586)
						card.Art.TitleBackground:SetSize(280, 80)
						card.Art.TitleBackground:SetBlendMode("ADD")

						card.Art.TitleBackground:ClearAllPoints()
						card.Art.TitleBackground:SetPoint("TOP", card.Art.Logo, "BOTTOM", 0, -4)

						card.Art.Text:SetFontObject(GameFontNormalFrost)
						card.Art.Text:SetTextColor(0.86, 1, 1)

						card.Art.TextInfo:SetTextColor(0.86, 1, 1)
						card.XP.Text:SetTextColor(0.86, 1, 1)
						card.PVP.Text:SetTextColor(0.86, 1, 1)

						card.RealmButton:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
						card.RealmButton:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
						card.RealmButton:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");

						card.RealmButton:GetNormalTexture():SetTexCoord(0, 0.578125, 0, 0.75)
						card.RealmButton:GetPushedTexture():SetTexCoord(0, 0.578125, 0, 0.75)
						card.RealmButton:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)

						card.BORDER:SetDesaturated(realmDown)
					elseif data.desingKey and data.desingKey == "Neltharion" then
						card.BG:SetTexture(0.93,0.27,0.12)

						card.BORDER:SetTexture("Interface\\GLUES\\RealmStyle\\Neltharion")
						card.BORDER:SetTexCoord(0, 0.2802734375, 0, 0.5283203125)
						card.BORDER:SetAlpha(1)

						card.Art.TitleBackground:SetTexture("Interface\\GLUES\\RealmStyle\\Neltharion")
						card.Art.TitleBackground:SetTexCoord(0.306640625, 0.83984375, 0.1064453125, 0.16796875)
						card.Art.TitleBackground:SetSize(240, 80)

						card.Art.TitleBackground:ClearAllPoints()
						card.Art.TitleBackground:SetPoint("TOP", card.Art.Logo, "BOTTOM", 0, 10)


						card.Art.Text:SetFontObject(GameFontNormalNeltharion)
						card.Art.Text:SetTextColor(0.93,0.27,0.12)

						card.Art.TextInfo:SetTextColor(1,0.81,0.74)
						card.XP.Text:SetTextColor(1,0.81,0.74)
						card.PVP.Text:SetTextColor(1,0.81,0.74)

						card.RealmButton:SetNormalTexture("Interface\\GLUES\\RealmStyle\\Glue-Panel-Button-Up-Neltharion")
						card.RealmButton:SetPushedTexture("Interface\\GLUES\\RealmStyle\\Glue-Panel-Button-Down-Neltharion")
						card.RealmButton:SetHighlightTexture("Interface\\GLUES\\RealmStyle\\Glue-Panel-Button-Highlight-Neltharion")

						card.RealmButton:GetNormalTexture():SetTexCoord(0, 0.578125, 0, 0.75)
						card.RealmButton:GetPushedTexture():SetTexCoord(0, 0.578125, 0, 0.75)
						card.RealmButton:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
					elseif data.desingKey and data.desingKey == "Algalon" then
						card.BG:SetTexture(0.72,0.85,0.91)
						card.BORDER:SetAtlas("Algalon-Realm-Background")

						card.Art.TitleBackground:ClearAndSetPoint("TOP", card.Art.Logo, "BOTTOM", 0, 12)
						card.Art.TitleBackground:SetAtlas("Algalon-Realm-Drive2")
						card.Art.TitleBackground:SetSize(260, 80)

						card.RealmButton:SetNormalAtlas("Algalon-Button-Normal")
						card.RealmButton:SetPushedAtlas("Algalon-Button-Pushed")
						card.RealmButton:GetHighlightTexture():SetVertexColor(0, 1, 1)

						local color = {0.71,0.81,0.9}
						card.Art.TextInfo:SetTextColor(unpack(color))
						card.XP.Text:SetTextColor(unpack(color))
						card.PVP.Text:SetTextColor(unpack(color))
					else
						card.BG:SetTexture(0.6, 0.5, 0.3, 0.3)

						card.BORDER:SetTexture(0, 0, 0)
						card.BORDER:SetAlpha(0.7)

						card.Art.TitleBackground:SetTexture("Interface\\GLUES\\RealmStyle\\divider")
						card.Art.TitleBackground:SetTexCoord(0, 1, 0, 1)

						card.Art.TitleBackground:ClearAllPoints()
						card.Art.TitleBackground:SetPoint("TOP", card.Art.Logo, "BOTTOM", 0, -14)

						card.Art.Text:SetFontObject(SystemFont_Large)
						card.Art.Text:SetTextColor(0, 0, 0)

						card.Art.TextInfo:SetTextColor(1, 1, 1)
						card.XP.Text:SetTextColor(1, 1, 1)
						card.PVP.Text:SetTextColor(1, 1, 1)

						card.RealmButton:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up")
						card.RealmButton:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down")
						card.RealmButton:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight")

						card.RealmButton:GetNormalTexture():SetTexCoord(0, 0.578125, 0, 0.75)
						card.RealmButton:GetPushedTexture():SetTexCoord(0, 0.578125, 0, 0.75)
						card.RealmButton:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
					end

					card.SnowEffect:SetShown(data.desingKey and data.desingKey == "Frostmourne")
					card.FireEffect:SetShown(data.desingKey and data.desingKey == "Neltharion")
					card.AlgalonEffect:SetShown(data.desingKey and data.desingKey == "Algalon")

					card.Art.Logo:SetAtlas(data.logo)
					card.Art.Text:SetText("")
					card.XP.Text:SetText(data.rate)
					card.PVP.Text:SetText(data.types)
					card.Art.TextInfo:SetText(data.description)

					card.Art.Logo:SetDesaturated(realmDown)
					card.XP.Icon:SetDesaturated(realmDown)
					card.PVP.Icon:SetDesaturated(realmDown)
					card.Art.TitleBackground:SetDesaturated(realmDown)
					card.RealmButton:SetEnabled(not realmDown)

					card.RealmButton.realmID = realmID
					card.RealmButton.realmZone = realmZone

					card.PVP.typesTooltip = data.typesTooltip

					--card:Show()
				end
			elseif realmCardsData and realmCardsData[name] and realmCardsData[name].minimize then
				miniCardCount = miniCardCount + 1

				local data = realmCardsData[name]
				local card = _G["RealmListMiniRealmCard"..miniCardCount]

				if card then
					card.RealmButton.realmID = realmID
					card.RealmButton.realmZone = realmZone

					card.RealmName:SetText(name)

					card:Show()
				end
			end
		end
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

	local mainCardOffset = 0

	for i = 1, cardCount do
		local card = _G["RealmListRealmCard"..i]
		if card:IsShown() then
			card:SetPoint("CENTER", RealmList, -((262 / 2) * cardCount) + 262 * mainCardOffset + 128, 0)
			mainCardOffset = mainCardOffset + 1
		end
	end

	local miniCardOffset = 0

	for i = 1, miniCardCount do
		local card = _G["RealmListMiniRealmCard"..i]
		if card:IsShown() then
			card:SetPoint("LEFT", RealmList, 20, -((110 / 2) * miniCardCount) + 80 * miniCardOffset + 50)
			miniCardOffset = miniCardOffset + 1
		end
	end

	local entryList = {}

	for _, v in pairs(realmCards) do
		local frame = _G[v.cardFrame]
		if not v.setup then
			frame:SetDisabledRealm(true)
		else
		--	-- TODO: TEMP
		--	if #frame.entryList > 1 then
		--		frame.entryList[3] = CopyTable(frame.entryList[2])
		--		frame.entryList[3].realmDown = true
		--	end
		--	-- TODO: TEMP

			if #frame.entryList > 2 then
				local realmDown = true
				for entryIndex, entry in ipairs(frame.entryList) do
					entryList[entryIndex] = entryList[entryIndex] or {}
					if entryList[entryIndex].realmDown ~= false then
						entryList[entryIndex].realmDown = entry.realmDown
					end

					if realmDown and not entry.realmDown then
						realmDown = false
					end
				end

				frame:SetDisabledRealm(realmDown)
				frame.ProxyFrame:SetShown(false)
			else
				frame:SetDisabledRealm(frame.entryList[1].realmDown)
				frame.ProxyFrame:SetShown(true)
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

function RealmListRealmSelect_OnClick( self, ... )
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
		ChangeRealm(entryRealmZone or self.realmZone, entryRealmID or self.realmID)
	end
end

function RealmListCancel_OnClick( self, ... )
	PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_CANCEL)
	RealmList:Hide()
	RealmListDialogCancelled()
end

local REALM_CARDS = {
	Sirus = {
		name = "SIRUS",
		desc = REALM_SIRUS_DESCRIPTION,
		rate = 5,
		pvp = "Всегда включен",
		logo = "ServerGameLogo-11",
	--	label = "НОВЫЙ ИГРОВОЙ МИР",
		overlay = true,
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
		name = "ALGALON",
		desc = REALM_ALGALON_DESCRIPTION,
		rate = 4,
		pvp = "Всегда включен",
		logo = "ServerGameLogo-13",
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
		name = "SCOURGE",
		desc = REALM_SCOURGE_DESCRIPTION,
		rate = 2,
		pvp = "Режим войны",
		logo = "ServerGameLogo-12",
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
	local cardName = self:GetAttribute("card")
	local card = REALM_CARDS[cardName]
	if not (cardName and card) then
		error(string.format("Card with '%s' name not found", tostring(cardName)), 2)
	end

	local frameLevel = self:GetFrameLevel()
	self.BackgroundFrame:SetFrameLevel(frameLevel)
	self.ContentFrame:SetFrameLevel(frameLevel + #card.models + 1)
	self.OverlayFrame:SetFrameLevel(frameLevel + #card.models + 2)
	self.LogoFrame:SetFrameLevel(frameLevel + #card.models + 3)
	self.EnterButton:SetFrameLevel(frameLevel + #card.models + 4)
	self.BorderFrame:SetFrameLevel(frameLevel + #card.models + 5)
	self.ProxyFrame:SetFrameLevel(frameLevel)

	self.BackgroundFrame.Background:SetAtlas(("RealmList-Card-%s-Background"):format(cardName))
	self.BorderFrame.Border:SetAtlas(("RealmList-Card-%s-Border"):format(cardName))
	self.LogoFrame.Logo:SetAtlas(card.logo)

	self.EnterButton.NormalTexture:SetAtlas(("RealmList-Card-%s-Button-Static"):format(cardName))
	self.EnterButton.PushedTexture:SetAtlas(("RealmList-Card-%s-Button-Press"):format(cardName))
	self.EnterButton.HighlightTexture:SetAtlas(("RealmList-Card-%s-Button-Static"):format(cardName))

	self.ContentFrame.RealmName:SetFormattedText("%s x%i", card.name, card.rate)
	self.ContentFrame.RealmDescription:SetText(card.desc)
	self.ContentFrame.RealmRate:SetFormattedText("x%i", card.rate)
	self.ContentFrame.RealmPVPStatus:SetText(card.pvp)

	if card.overlay then
		self.OverlayFrame.Overlay:SetAtlas(("RealmList-Card-%s-Overlay"):format(cardName))
		self.OverlayFrame:Show()
	end

	if card.label then
		self.LabelFrame.Background:SetAtlas(("RealmList-Card-%s-Driver"):format(cardName))
		self.LabelFrame.Text:SetText(card.label)
		self.LabelFrame:Show()
	end

	self.entryList = {}
	self.models = {}

	for i, modelData in ipairs(card.models) do
		local model = CreateFrame("Model", ("$parentBackgroundModel%i"):format(i), self.BackgroundFrame)
		model:SetPoint("TOPLEFT", 2, -2)
		model:SetPoint("BOTTOMRIGHT", 2, -2)
		model:SetFrameLevel(self.BackgroundFrame:GetFrameLevel() + i)

		model:SetModel(modelData.file)
		model:SetPosition(GetScaledModelPosition(model, unpack(modelData.position)))
		model:SetModelScale(modelData.scale or 1)
		model:SetAlpha(modelData.alpha or 1)

		self.models[i] = model
	end
end

function RealmListCardTemplateMixin:SetDisabledRealm(toggle)
	self.BackgroundFrame.Background:SetDesaturated(toggle)
	self.BorderFrame.Border:SetDesaturated(toggle)
	self.LogoFrame.Logo:SetDesaturated(toggle)
	self.LabelFrame.Background:SetDesaturated(toggle)
	self.OverlayFrame.Overlay:SetDesaturated(toggle)

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
	self.HelpHightlight.Left:SetPoint("TOPRIGHT", RealmList.EntryPoint, "TOPLEFT", -5, 0)
	self.HelpHightlight.Left:SetPoint("BOTTOMRIGHT", RealmList.EntryPoint, "BOTTOMLEFT", -5, 0)
	self.HelpHightlight.Left:SetPoint("LEFT", GlueParent, "LEFT", 0, 0)

	self.HelpHightlight.Right:ClearAllPoints()
	self.HelpHightlight.Right:SetPoint("TOPLEFT", RealmList.EntryPoint, "TOPRIGHT", 5, 0)
	self.HelpHightlight.Right:SetPoint("BOTTOMLEFT", RealmList.EntryPoint, "BOTTOMRIGHT", 5, 0)
	self.HelpHightlight.Right:SetPoint("RIGHT", GlueParent, "RIGHT", 0, 0)

	self.HelpHightlight.Top:ClearAllPoints()
	self.HelpHightlight.Top:SetPoint("TOPLEFT", GlueParent, "TOPLEFT", 0, 0)
	self.HelpHightlight.Top:SetPoint("BOTTOMRIGHT", self.HelpHightlight.Right, "TOPRIGHT", 0, 5)

	self.HelpHightlight.Bottom:ClearAllPoints()
	self.HelpHightlight.Bottom:SetPoint("BOTTOMLEFT", GlueParent, "BOTTOMLEFT", 0, 0)
	self.HelpHightlight.Bottom:SetPoint("TOPRIGHT", self.HelpHightlight.Right, "BOTTOMRIGHT", 0, -5)

	RealmList.EntryPoint.BG:Show()
	RealmList.EntryPoint._strata = RealmList.EntryPoint:GetFrameStrata()
	RealmList.EntryPoint._flevel = RealmList.EntryPoint:GetFrameLevel()
	RealmList.EntryPoint:SetFrameStrata("FULLSCREEN")
	RealmList.EntryPoint:SetFrameLevel(50)

	self.HelpHightlight:Show()
end

RealmEntryPointMixin = {}

function RealmEntryPointMixin:OnLoad()
	self.buttonPool = CreateFramePool("Button", self, "RealmEntrySelectButtonTemplate")
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
	GlueTooltip_SetOwner(self, nil, nil, nil, nil, "TOPRIGHT")
	GlueTooltip_SetText(text, GlueTooltip, 1.0, 1.0, 1.0, 1.0, 1)
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
	GlueTooltip_SetOwner(self, nil, nil, nil, nil, "TOPRIGHT")
	if self:IsEnabled() == 1 then
		GlueTooltip_SetText(ENTRY_LIST[self:GetID()][2], GlueTooltip, 1, 1, 1, 1, 1)
	else
		GlueTooltip_SetText(ENTRY_LIST[self:GetID()][2], GlueTooltip, 0.5, 0.5, 0.5, 1, 1)
		GlueTooltip:AddLine(CHAR_LOGIN_NO_WORLD, 1, 1, 1, 1, 1)
	end
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