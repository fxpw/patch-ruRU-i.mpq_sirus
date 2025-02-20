ezSpectator_MessageHandler = {}
ezSpectator_MessageHandler.__index = ezSpectator_MessageHandler

function ezSpectator_MessageHandler:Create(Parent)
    local self = {}
    setmetatable(self, ezSpectator_MessageHandler)

    self.Parent = Parent

    self.EventFrame = CreateFrame('Frame', nil, ArenaSpectatorFrame)
    self.EventFrame.Parent = self

    self.EventFrame:RegisterEvent('CHAT_MSG_ADDON')
    self.EventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    self.EventFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self.EventFrame:SetScript('OnEvent', self.EventHandler)

    return self
end



--noinspection UnusedDef
function ezSpectator_MessageHandler:EventHandler(event, prefix, message, distribution, sender)
	if event == "CHAT_MSG_ADDON" then
		if prefix == "ARENASPEC" and distribution == "WHISPER" and sender == "" then
			self.Parent:ProcessMessage(message)
		elseif prefix == "ASMSG_AR_PAUSED" and distribution == "UNKNOWN" and sender == UnitName("player") then
			self.Parent.Parent.Interface.IsPaused = self.Parent.Parent.Interface.TopFrame.Play:IsShown() == 1
		end
	end
end



function ezSpectator_MessageHandler:ProcessMessage(Message)
    if Message:find(';AUR=') then
        local AuraTarget, Message = strsplit(';', Message)
        local DataPart = select(2, strsplit('=', Message))
        local aremove, astack, aexpiration, aduration, aspellId, adebyfftype, aisdebuff, acaster = strsplit(',', DataPart)

        self:ProcessCommand(AuraTarget, 'AUR', tonumber(aremove), tonumber(astack), tonumber(aexpiration), tonumber(aduration), tonumber(aspellId), tonumber(adebyfftype), tonumber(aisdebuff), acaster)
        return
    end

    local DataPosition = strfind(Message, ';', DelimiterPosition)
    local MessageTarget = strsub(Message, 1, DataPosition - 1)
    local DelimiterPosition = DataPosition + 1

    repeat
        DataPosition = strfind(Message, ';', DelimiterPosition)
        if (DataPosition ~= nil) then
            local Command = strsub(Message, DelimiterPosition, DataPosition - 1)
            DelimiterPosition = DataPosition + 1

            local Prefix = strsub(Command, 1, strfind(Command, '=') - 1)
            local Value = strsub(Command, strfind(Command, '=') + 1)

            self:ProcessCommand(MessageTarget, Prefix, Value)
        end
    until DataPosition == nil
end



function ezSpectator_MessageHandler:ProcessCommand(Target, Prefix, ...)
    local Value = ...
    local TeamID

    if self.Parent.Interface.Players[Target] == nil then
        if Target == '67' then
            TeamID = 1
        end

        if Target == '469' then
            TeamID = 2
        end

        if not TeamID then
            self.Parent.Interface.Players[Target] = ezSpectator_PlayerWorker:Create(self.Parent)
            self.Parent.Interface.Players[Target]:SetNickname(Target)
            self.Parent.Interface.Players[Target]:Hide()
        end
    else
        if self.Parent.Interface.Players[Target]:IsReady() and not self.Parent.Interface.Players[Target]:IsShown() then
            self.Parent.Interface.Players[Target]:Show()
        end
    end

    if Prefix == 'CHP' then
        self.Parent.Interface.Players[Target]:SetHealth(tonumber(Value))
    elseif Prefix == 'MHP' then
        self.Parent.Interface.Players[Target]:SetMaxHealth(tonumber(Value))
    elseif Prefix == 'CPW' then
        self.Parent.Interface.Players[Target]:SetPower(tonumber(Value))
    elseif Prefix == 'MPW' then
        self.Parent.Interface.Players[Target]:SetMaxPower(tonumber(Value))
    elseif Prefix == 'PWT' then
        self.Parent.Interface.Players[Target]:SetPowerType(tonumber(Value))
    elseif Prefix == 'TEM' then
        self.Parent.Interface.Players[Target]:SetTeam(tonumber(Value))
    elseif Prefix == 'STA' then
        self.Parent.Interface.Players[Target]:SetStatus(tonumber(Value))
    elseif Prefix == 'CLA' then
        self.Parent.Interface.Players[Target]:SetClass(tonumber(Value))
    elseif Prefix == 'SPE' then
		local start = strfind(Value, ',')
		if start then
			self.Parent.Interface.Players[Target]:SetCast(tonumber(strsub(Value, 1, start - 1)), tonumber(strsub(Value, start + 1)))
		else
			local spellID = tonumber(Value)
			if spellID then
				self.Parent.Interface.Players[Target]:SetCast(spellID, 0)
			end
		end
    elseif Prefix == 'AUR' then
        self.Parent.Interface.Players[Target]:SetAura(...)
    elseif Prefix == 'TRG' then
        self.Parent.Interface.Players[Target]:SetTarget(self.Parent.Interface.Players[Value])
    elseif Prefix == 'LEV' then -- I don't know
        self.Parent.Interface.Players[Target]:SetLock(tonumber(Value))
    elseif Prefix == 'ELA' then -- Сколько времени длится матч (шлётся при начале матча, после препа) так как у нас реплеи, используем как отметку начала самого боя
        self.Parent.Interface:SetMatchElapsed(tonumber(Value))
    elseif Prefix == 'TAL' then -- Установка спека игрока, шлём номер спека, наш функционал вернёт остальное
        self.Parent.Interface.Players[Target]:SetSpec(Value)
    elseif Prefix == 'NAM' then -- Имя команды
        self.Parent.Interface:SetTeamName(TeamID, Value)
    elseif Prefix == 'COL' then -- Ну, цвет команды. gold или любой другой цвет
        self.Parent.Interface:SetTeamColor(TeamID, Value)
    elseif Prefix == 'SRC' then -- Общий процент ХП, нужно подумать нужно ли оно нам
        self.Parent.Interface:SetTeamScore(TeamID, Value)
    elseif Prefix == 'CDN' then -- Кд на спелл, айди + запятая + время (секунды)
		local start = strfind(Value, ',')
		if start then
			self.Parent.Interface.Players[Target]:SetCooldown(tonumber(strsub(Value, 1, start - 1)), tonumber(strsub(Value, start + 1)))
		else
			local spellID = tonumber(Value)
			if spellID then
				self.Parent.Interface.Players[Target]:SetCooldown(spellID, 0)
			end
		end
    elseif Prefix == 'STAGE' then -- Стейдж турнира (TournamentStages)
        self.Parent.Interface:SetStage(Value)
    elseif Prefix == 'BOX' then -- Для турнирки, выводит надпись про количество игр, судя по всему
        self.Parent.Interface:SetBOX(Value)
    elseif Prefix == 'ENB' then -- Включение / отключение аддона, 0 - выключен, 1 - включен, 2 - турнир
        SendServerMessage("ACMSG_AR_GET_META_INFO", ArenaSpectatorFrame:GetWatchReplayID())
        self.Parent.Interface:SetMode(tonumber(Value))
    else
        DEFAULT_CHAT_FRAME:AddMessage('Unhandled prefix: ' .. Prefix .. '. Try to update to newer version')
    end

    self.Parent.Interface:UpdateTeams()
    self.Parent.Interface:UpdateTargets()
end