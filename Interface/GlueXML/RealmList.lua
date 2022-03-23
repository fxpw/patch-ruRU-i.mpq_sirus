--	Filename:	RealmList.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

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
		proxyName = SHARED_SCOURGE_PROXY_REALM_NAME,
	},
	[SHARED_SIRUS_REALM_NAME] = {
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
		proxyName = SHARED_ALGALON_PROXY_REALM_NAME,
	},
}

local proxyRealmCardsData = {
	[SHARED_SCOURGE_PROXY_REALM_NAME] = {
		realm = SHARED_SCOURGE_REALM_NAME,
	},
	[SHARED_ALGALON_PROXY_REALM_NAME] = {
		realm = SHARED_ALGALON_REALM_NAME,
	},
}

local REALM_ZONE = 2
local MAX_REALM_ZONE = 37
local MAX_REALM_COUNT = 18

local realmDataStorage = {}

function GenerateRealmData()
	realmDataStorage = {}

	for realmZone = 1, MAX_REALM_ZONE do
		for realmID = 1, MAX_REALM_COUNT do
			local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types = GetRealmInfo(realmZone, realmID)

			if name and not realmDataStorage[name] then
				realmDataStorage[name] = {name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types, realmZone, realmID}
			end
		end
	end
end

function _GetNumRealms()
	GenerateRealmData()

	return tCount(realmDataStorage)
end

function _GetRealmInfo( realmIndex )
	if not realmIndex then
		return
	end

	GenerateRealmData()

	local buffer = {}
	for _, data in pairs(realmDataStorage) do
		buffer[#buffer + 1] = data
	end

	if buffer[realmIndex] then
		return unpack(buffer[realmIndex])
	end
end

function RealmList_OnLoad( self, ... )
	self.buttonsList = {}

	self:RegisterEvent("OPEN_REALM_LIST")
end

function RealmList_OnShow( self, ... )
	if WaitingDialogFrame then
		WaitingDialogFrame:Hide()
	end

	if self.updateList then
		self.updateList:Cancel()
		self.updateList = nil
	end

	local updateTime = RealmListUpdateRate()

	if S_IsDevClient and S_IsDevClient() then
		updateTime = 1
	end

	self.updateList = C_Timer:NewTicker(updateTime, function()
		if not self:IsShown() and self.updateList then
			self.updateList:Cancel()
			self.updateList = nil
			return
		end

		RealmList_Update()
	end)

	RealmList_Update()
end

function RealmList_OnHide( self, ... )
	if self.updateList then
		self.updateList:Cancel()
		self.updateList = nil
	end
end

function RealmList_OnEvent( self, event, ... )
	if event == "OPEN_REALM_LIST" then
		-- printc("RealmList_OnEvent", event, ...)
		self:Show()
	end
end

function RealmList_OnKeyDown( self, ... )
	-- body
end

function RealmListRealmSelect_OnClick( self, ... )
	if self.realmID then
		RealmList:Hide()
		ChangeRealm(self.realmZone , self.realmID)
	end
end

function RealmListCancel_OnClick( self, ... )
	RealmList:Hide()
	RealmListDialogCancelled()
end


function RealmList_Update()
	RequestRealmList()

	local realmCount = _GetNumRealms()
	local cardCount = 0
	local miniCardCount = 0
	local proxyCardCount = 0

	if not realmCount or realmCount == 0 then
		RealmList.NoRealmText:Show()
	end

	for i = 1, realmCount do
		local name, numCharacters, invalidRealm, realmDown, currentRealm, pvp, rp, load, locked, major, minor, revision, build, types, realmZone, realmID = _GetRealmInfo(i)

		if name then
			local button = RealmList.buttonsList[i]

			if not button then
				button = CreateFrame("Button", "RealmSelectButton"..i, RealmList, "NormalChoiceButtonTemplate")

				if i == 1 then
					button:SetPoint("TOPLEFT", 12, -20)
				elseif mod(i - 1, 4) == 0 then
					button:SetPoint("TOP", RealmList.buttonsList[i - 4], "BOTTOM", 0, 0)
				else
					button:SetPoint("LEFT", RealmList.buttonsList[i - 1], "RIGHT", -14, 0)
				end

				RealmList.buttonsList[i] = button
			end

			button.realmID = realmID
			button.realmZone = realmZone

			button:SetEnabled(not realmDown)
			button:SetText(name)
			button:Show()

			if RealmList.NoRealmText:IsShown() then
				RealmList.NoRealmText:Hide()
			end

			if realmCardsData and realmCardsData[name] and not realmCardsData[name].minimize then
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

						--card.RealmButton:SetBlendMode("DISABLE")

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

					card.proxyName = data.proxyName;

					card:Show()
				end
			elseif realmCardsData and realmCardsData[name] and realmCardsData[name].minimize then
				miniCardCount = miniCardCount + 1

				local data = realmCardsData[name]
				local card = _G["RealmListMiniRealmCard"..miniCardCount]

				if card then
					card.RealmButton.realmID = realmID
					card.RealmButton.realmZone = realmZone

					card.Logo:SetAtlas(data.logo)

					dump(data)

					card:Show()
				end
			elseif proxyRealmCardsData[name] then
				proxyCardCount = proxyCardCount + 1;

				local card = _G["RealmListProxyRealmCard"..proxyCardCount];

				if card then
					card.ProxyButton.realmID = realmID;
					card.ProxyButton.realmZone = realmZone;

					card.name = name;

					card.BORDER:SetDesaturated(realmDown);
					card.ProxyButton:SetEnabled(not realmDown);

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

	for i = 4, proxyCardCount + 1, -1 do
		local card = _G["RealmListProxyRealmCard"..i]

		if card then
			card:Hide()
		end
	end

	for i = realmCount + 1, #RealmList.buttonsList do
		RealmList.buttonsList[i]:Hide()
	end

	if realmCount <= (cardCount + miniCardCount + proxyCardCount) and (cardCount > 0 or miniCardCount > 0 or proxyCardCount > 0) then
		for i = 1, #RealmList.buttonsList do
			RealmList.buttonsList[i]:Hide()
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
			card:SetPoint("LEFT", RealmList, 20, -((110 / 2) * miniCardCount) + 110 * miniCardOffset + 50)
			miniCardOffset = miniCardOffset + 1
		end
	end

	for i = 1, proxyCardCount do
		local proxyCard = _G["RealmListProxyRealmCard"..i];
		if proxyCard:IsShown() then
			local foundRealm;
			for j = 1, cardCount do
				local card = _G["RealmListRealmCard"..j];
				if card:IsShown() and card.proxyName == proxyCard.name then
					proxyCard:ClearAllPoints();
					proxyCard:SetPoint("TOP", card, "BOTTOM", 0, -12);

					foundRealm = true;
					break;
				end
			end
			if not foundRealm then
				proxyCard:Hide();
			end
		end
	end
end

function RealmList_OnKeyDown( self, key, ... )
	if ( key == "ESCAPE" ) then
		RealmListCancel_OnClick()
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot()
	end
end