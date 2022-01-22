--	Filename:	Sirus_GMClient.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

GMClientMixIn = {}

GMClientMixIn.accountData = {}
GMClientMixIn.accountDataByName = {}

GMClientMixIn.muteHistoryData = {}

function GMClientMixIn:ShowMuteWindow( playerName )
	GMClientMixIn:RequestPlayerInfoByName(playerName, function()
		GMClient_MuteFrame.playerName = playerName
		GMClient_MuteFrame:Show()
	end)
end

function GMClientMixIn:RequestMuteHistory( accountLogin, callback )
	TrinityCoreMixIn:SendCommand("muteh "..accountLogin, function( data )
		GMClientMixIn:MuteHistoryHandler( data )

		if callback then
			callback()
		end
	end)
end

function GMClientMixIn:MuteHistoryHandler( data )
	if not data then
		return
	end

	local accountLogin = string.match(data[1], "Mutes for account: (.*)")

	if accountLogin then
		if not self.muteHistoryData[accountLogin] then
			self.muteHistoryData[accountLogin] = {}
		end

		for _, line in pairs(data) do
			local muteDate, muteTime, muteReason, muteGiver = string.match(line, "Mute Date:%s+(.*) Mutetime:%s+(.*) mins. Reason: (.*) Set by: (.*)")

			if muteDate and muteTime and muteReason and muteGiver then
				table.insert(self.muteHistoryData[accountLogin], {muteDate = muteDate, muteTime = muteTime, muteReason = muteReason, muteGiver = muteGiver})
			end
		end
	end
end

function GMClientMixIn:RequestPlayerInfoByName( playerName, callback, message )
	TrinityCoreMixIn:SendCommand("pinfo "..playerName, function( data )
		GMClientMixIn:PlayerInfoHandler( data, message )

		if callback then
			callback()
		end
	end)
end

local playerInfoTemplate = {
	"Игрок (.-)%|cffffffff%|Hplayer:(%S+)%|h%[.*%]%|h%|r %(guid: (%d+)%)",
	"GM Режим активен, Фаза: (%S+)",
	"Учетная запись: (.*) %(ID: (%d+)%), GMLevel: (%d+)",
	"Последний вход: (.*) %(Неправильных входов: (%d+)%)",
	"OS: (.*) %- Latency: (%d+) ms",
	"Registration Email: .+%- Email: (.*)",
	"Last IP: (.*) %(Locked: (%S+)%)",
	"Level: (%d+)",
	"Race: (%S+) (.*), (%S+)",
	"Alive %?%: (%S+)",
	"Money: (%d+)g(%d+)s(%d+)c",
	"Map: (%S+), Area: (%S+), Zone: (%S+)",
	"Guild: (.*) %(ID: (%d+)%)",
	"Played time: (%d+)d(%d+)h",
	"Бонусы: (%d+)",
	"Голоса: (%d+)",
	"Лояльность: (%d+) %((%d+)%/(%d+)%)",
	"Версия клиента: (%d+)",
	"Конфиг: (%d+)",
}

function GMClientMixIn:PlayerInfoHandler( data, message )
	if not data then
		return
	end

	local lineData = {}

	local info = ChatTypeInfo["SYSTEM"]
	for _, line in pairs(data) do
		if message then
			DEFAULT_CHAT_FRAME:AddMessage(line, info.r, info.g, info.b)
		end

		for i = 1, #playerInfoTemplate do
			lineData[i] = string.match(line, playerInfoTemplate[i]) and {string.match(line, playerInfoTemplate[i])} or lineData[i]
		end
	end

	if not self.accountData[lineData[3][2]] then
		self.accountData[lineData[3][2]] = {}
	end

	local data = self.accountData[lineData[3][2]]

	data.isOffline = lineData[1][1] == "(не в сети) "
	data.playerName = lineData[1][2]
	data.playerGUID = tonumber(lineData[1][3])
	data.isGMStatusActive = isset(lineData[2])
	data.phase = data.isGMStatusActive and tonumber(lineData[2][1]) or nil
	data.accountLogin = lineData[3][1]
	data.accountGUID = tonumber(lineData[3][2])
	data.accountGMLevel = tonumber(lineData[3][3])
	data.lastLogin = lineData[4][1]
	data.failLoginCount = tonumber(lineData[4][2])
	data.os = lineData[5][1]
	data.latency = tonumber(lineData[5][2])
	data.email = lineData[6][1]
	data.lastIP = lineData[7][1]
	data.isIPLock = lineData[7][2] == "Да"
	data.level = tonumber(lineData[8][1])
	data.gender = lineData[9][1]
	data.race = lineData[9][2]
	data.class = lineData[9][3]
	data.alive = lineData[10][1] == "Да"
	data.money = {tonumber(lineData[11][1]), tonumber(lineData[11][2]), tonumber(lineData[11][3])}
	data.map = lineData[12] and lineData[12][1] or nil
	data.area = lineData[12] and lineData[12][2] or nil
	data.zone = lineData[12] and lineData[12][3] or nil
	data.guildName = lineData[13] and lineData[13][1] or nil
	data.guildID = lineData[13] and lineData[13][2] or nil
	-- data.playerTime = {tonumber(lineData[14][1]), tonumber(lineData[14][2])}
	data.bonuses = tonumber(lineData[15][1])
	data.vote = tonumber(lineData[16][1])
	data.loyal = {tonumber(lineData[17][1]), tonumber(lineData[17][2]), tonumber(lineData[17][3])}
	data.clientVersion = tonumber(lineData[18][1])
	data.config = tonumber(lineData[19][1])

	if not self.accountDataByName[data.playerName] then
		self.accountDataByName[data.playerName] = {}
	end

	self.accountDataByName[data.playerName] = self.accountData[lineData[3][2]]
end

function GMClient_MuteFrame_OnLoad( self, ... )
	Mixin(self, GMClientMixIn)

	ButtonFrameTemplate_HideButtonBar(self)
	ButtonFrameTemplate_HideAttic(self)
	ButtonFrameTemplate_HidePortrait(self)

	self.BottomInset.MuteHistoryScrollFrame.update = GMClient_UpdateMuteHistoryList
	self.BottomInset.MuteHistoryScrollFrame.scrollBar.doNotHide = true
	HybridScrollFrame_CreateButtons(self.BottomInset.MuteHistoryScrollFrame, "MuteHistoryButtonTemplate", 0, 0, "TOP", "TOP", 0, 0, "TOP", "BOTTOM")

	self:RegisterForDrag("LeftButton")

	self.Inset:Hide()
end

function GMClient_MuteFrame_OnShow( self, ... )
	local data = self.accountDataByName[self.playerName]

	if data then
		self.TitleText:SetFormattedText("%s (%s - %d)", data.playerName, data.accountLogin, data.accountGUID)

		self.TopInset.Container.ReasonEditBox.Instructions:SetText("")
		self.TopInset.Container.TimeEditBox.Instructions:SetText("")

		self.BottomInset.NoMuteHistoryLabel:Show()
		self.BottomInset.MuteHistoryScrollFrame:Hide()

		GMClientMixIn:RequestMuteHistory(data.accountLogin, GMClient_UpdateMuteHistoryList)
	end
end

local muteDropDownTemplates = {
	{"Флуд", "Флуд в общих каналах", 15},
	{"Оскорбление пользователей", "Нецензурная лексика/Оскорбление игроков", 60},
	{"Оскорбление администрации", "Оскорбление администрации/Очернение проекта", 1440},
	{"Межнациональная дискриминация", "Расовая/межнациональная дискриминация", 600},
	{"Жалоба с форума", "Жалоба в теме \"Нарушители чата\"", 60},
	{"Анусисты", "Скилл-флуд", 500},
	{"Рулетка", "Игорный бизнес запрещен", 1440}
}

function GMClient_MuteFrame_TemplateDropDown_OnShow( self, ... )
	UIDropDownMenu_Initialize(self, GMClient_MuteFrame_TemplateDropDown_Initialize)
	UIDropDownMenu_SetSelectedValue(GMClient_MuteFrame.TemplateDropDown, nil)
	UIDropDownMenu_SetText(self, "Шаблон не выбран")
	UIDropDownMenu_SetWidth(self, 140)
end

function GMClient_MuteFrame_TemplateDropDown_OnClick( self, ... )
	local data = muteDropDownTemplates[self.value]

	GMClient_MuteFrame.TopInset.Container.ReasonEditBox.Instructions:SetText(data[2])
	GMClient_MuteFrame.TopInset.Container.TimeEditBox.Instructions:SetText(data[3])

	UIDropDownMenu_SetSelectedValue(GMClient_MuteFrame.TemplateDropDown, self.value)
end

function GMClient_MuteFrame_TemplateDropDown_Initialize( self, ... )
	local info = UIDropDownMenu_CreateInfo()

	info.func = GMClient_MuteFrame_TemplateDropDown_OnClick

	for i = 1, #muteDropDownTemplates do
		local data = muteDropDownTemplates[i]

		info.text = data[1]
		info.value = i
		info.checked = UIDropDownMenu_GetSelectedValue(self) == i

		UIDropDownMenu_AddButton(info)
	end
end

function GMClient_MuteButton_OnClick( self, ... )
	local reason = GMClient_MuteFrame.TopInset.Container.ReasonEditBox:GetText() ~= "" and GMClient_MuteFrame.TopInset.Container.ReasonEditBox:GetText() or GMClient_MuteFrame.TopInset.Container.ReasonEditBox.Instructions:GetText()
	local time = GMClient_MuteFrame.TopInset.Container.TimeEditBox:GetText() ~= "" and GMClient_MuteFrame.TopInset.Container.TimeEditBox:GetText() or GMClient_MuteFrame.TopInset.Container.TimeEditBox.Instructions:GetText()
	local playerName = GMClient_MuteFrame.playerName

	TrinityCoreMixIn:SendCommand(string.format("mute %s %d %s", playerName, time, reason))
end

function GMClient_UnMuteButton_OnClick( self, ... )
	local playerName = GMClient_MuteFrame.playerName

	TrinityCoreMixIn:SendCommand("unmute "..playerName)
end

function GMClient_UpdateMuteHistoryList()
	local scrollFrame = GMClient_MuteFrame.BottomInset.MuteHistoryScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons
	local numButtons = #buttons
	local button, index
	local muteHistoryCount = 0

	local data = GMClientMixIn.accountDataByName[GMClient_MuteFrame.playerName]

	if data then
		local muteData = GMClientMixIn.muteHistoryData[string.upper(data.accountLogin)]
		if muteData then
			muteHistoryCount = #muteData

			if not muteHistoryCount or muteHistoryCount == 0 then
				scrollFrame:Hide()
				GMClient_MuteFrame.BottomInset.NoMuteHistoryLabel:Show()
				return
			else
				GMClient_MuteFrame.BottomInset.NoMuteHistoryLabel:Hide()
				scrollFrame:Show()
			end

			for i = 1, numButtons do
				button = buttons[i]
				index = offset + i

				if muteData and muteData[index] then
					local data = muteData[index]

					button.TopLine:SetText(data.muteReason)
					button.MiddleLine:SetFormattedText("%s, %sm. %s", data.muteGiver, data.muteTime, data.muteDate)

					button:Show()
				else
					button:Hide()
				end
			end
		else
			scrollFrame:Hide()
			GMClient_MuteFrame.BottomInset.NoMuteHistoryLabel:Show()
		end
	end

	local totalHeight = muteHistoryCount * 60
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())
end

function GMClient_BanFrame_BanButton_OnClick( self, ... )
	local buttonID = self:GetID()
	local reason = self:GetParent().ReasonEditBox:GetText()
	local unBannedPrice = not self:GetParent().UnBannedPrice:GetChecked() and 0 or 1
	local banTime

	if buttonID == 1 then
		banTime = "1h"
	elseif buttonID == 2 then
		banTime = "7d"
	elseif buttonID == 3 then
		banTime = "30d"
	end

	TrinityCoreMixIn:SendCommand(string.format("ban plaeraccount %s %s %d %s", self:GetParent():GetParent().playerName, banTime, unBannedPrice, reason))
end
