local securecall = securecall

local IN_GLUE_STATE = IsOnGlueScreen()

do	-- CVars
	if IN_GLUE_STATE then
		local SetCVar = SetCVar
		_G.SetCVar = function(cvar, value, raiseEvent)
			if C_GlueCVars and C_GlueCVars.HasCVar(cvar) then
				C_GlueCVars.SetCVar(cvar, value)
				return
			end

			SetCVar(cvar, value, raiseEvent)
		end

		local GetCVar = GetCVar
		_G.GetCVar = function(cvar)
			if C_GlueCVars and C_GlueCVars.HasCVar(cvar) then
				return C_GlueCVars.GetCVar(cvar)
			end
			return GetCVar(cvar)
		end

		local GetCVarBool = GetCVarBool
		_G.GetCVarBool = function(cvar)
			if C_GlueCVars and C_GlueCVars.HasCVar(cvar) then
				return ValueToBoolean(C_GlueCVars.GetCVar(cvar))
			end
			return GetCVarBool(cvar)
		end

		local GetCVarDefault = GetCVarDefault
		_G.GetCVarDefault = function(cvar)
			if C_GlueCVars and C_GlueCVars.HasCVar(cvar) then
				return C_GlueCVars.GetCVarDefault(cvar)
			end
			return GetCVarDefault(cvar)
		end
	else
		TRACKED_CVARS = {
			"autoDismountFlying",
			"C_CVAR_DRACTHYR_RETURN_MORTAL_FORM",
			"C_CVAR_WARMODE_PVP_ASSIST_ENABLED",
			"C_CVAR_BLOCK_GROUP_INVITES",
			"C_CVAR_BLOCK_GUILD_INVITES",
			"C_CVAR_AUTO_ACCEPT_GROUP_INVITES",
		}

		local tonumber = tonumber
		local tostring = tostring
		local strformat, strsub = string.format, string.sub
		local TRACKED_CVARS = TRACKED_CVARS

		local CVAR_FORCE_VALUE = {
			showItemLevel = "1",
			projectedTextures = "1",
			previewTalents = "1",
		}

		local SetCVar = SetCVar
		local _SetCVar = function(cvar, value, raiseEvent)
			if CVAR_FORCE_VALUE[cvar] and CVAR_FORCE_VALUE[cvar] ~= tostring(value) then
				return
			end

			if strsub(cvar, 1, 7) == "C_CVAR_" then
				return C_CVar:SetValue(cvar, value, raiseEvent)
			end

			local trackedIndex = tIndexOf(TRACKED_CVARS, cvar)
			if trackedIndex then
				SendServerMessage("ACMSG_I_S", strformat("%i:%i", trackedIndex, tonumber(value) or 0))
			end

			SetCVar(cvar, value, raiseEvent)
		end
		_G.SetCVar = function(cvar, value, raiseEvent)
			securecall(_SetCVar, cvar, value, raiseEvent)
		end

		local GetCVar = GetCVar
		local _GetCVar = function(cvar)
			if strsub(cvar, 1, 7) == "C_CVAR_" then
				return C_CVar:GetValue(cvar)
			end
			return GetCVar(cvar)
		end
		_G.GetCVar = function(cvar)
			return securecall(_GetCVar, cvar)
		end

		local GetCVarBool = GetCVarBool
		local _GetCVarBool = function(cvar)
			if strsub(cvar, 1, 7) == "C_CVAR_" then
				return ValueToBoolean(C_CVar:GetValue(cvar))
			end
			return GetCVarBool(cvar)
		end
		_G.GetCVarBool = function(cvar)
			return securecall(_GetCVarBool, cvar)
		end

		local GetCVarDefault = GetCVarDefault
		local _GetCVarDefault = function(cvar)
			if strsub(cvar, 1, 7) == "C_CVAR_" then
				return C_CVar:GetDefaultValue(cvar)
			end
			return GetCVarDefault(cvar)
		end
		_G.GetCVarDefault = function(cvar)
			return securecall(_GetCVarDefault, cvar)
		end
	end

	_G.GetSafeCVar = function(cvar, default)
		local success, res = pcall(GetCVar, cvar)
		if not success then
			return default
		elseif res then
			return res
		end
	end
	_G.SetSafeCVar = function(cvar, value, raiseEvent)
		local val = GetSafeCVar(cvar)
		if val then
			SetCVar(cvar, value, raiseEvent)
		end
	end
end

do -- C_CacheInstance
	if IN_GLUE_STATE then
		local EnterWorld = EnterWorld
		_G.EnterWorld = function()
			C_CacheInstance:SaveData()
			EnterWorld()
		end
	else
		local CancelLogout = CancelLogout
		_G.CancelLogout = function()
			C_CacheInstance:SetSavedState(false)
			CancelLogout()
		end

		local Logout = Logout
		_G.Logout = function()
			C_CacheInstance:SaveData()
			Logout()
		end
	end

	local ConsoleExec = ConsoleExec
	_G.ConsoleExec = function(command)
		if string.upper(command) == "RELOADUI" then
			C_CacheInstance:SaveData()
		end
		ConsoleExec(command)
	end

	local ReloadUI = ReloadUI
	_G.ReloadUI = function()
		C_CacheInstance:SaveData()
		ReloadUI()
	end

	local RestartGx = RestartGx
	_G.RestartGx = function()
		C_CacheInstance:SaveData()
		RestartGx()
	end
end

do -- AddonManager
	local strgsub, strmatch = string.gsub, string.match
	local S_ADDON_VERSION = S_ADDON_VERSION

	local ADDON_URL = "https://sirus.su/base/addons/"
	local ADDON_VERSION_PATTERN = "%|%@Version: (%d+)%@%|"
	local CUSTOM_INFO_BEHAVIOUR = false

	local function checkAddonVersion(name, notes)
		local build, url, hasUpdate
		if notes then
			build = strmatch(notes, ADDON_VERSION_PATTERN)
			notes = strgsub(notes, ADDON_VERSION_PATTERN, "")
		end

		if build then
			build = tonumber(build)
		end

		if S_ADDON_VERSION then
			for _, addonData in ipairs(S_ADDON_VERSION) do
				if tContains(addonData[3], name) then
					url = strconcat(ADDON_URL, addonData[2])

					if not build or build < addonData[1] then
						hasUpdate = true
					end

					break
				end
			end
		end

		return notes, build, url, hasUpdate or false
	end

	local GetAddOnInfo = GetAddOnInfo
	if IN_GLUE_STATE then -- GetAddOnInfo
		_G.GetAddOnInfo = function(addonIndex)
			if not addonIndex then
				GMError("GetAddOnInfo was executed without addon index")
				return
			end
			local name, title, notes, url, loadable, reason, security, newVersion = GetAddOnInfo(addonIndex)
			local build
			notes, build, url, newVersion = checkAddonVersion(name, notes)
			return name, title, notes, url, loadable, reason, security, newVersion, build
		end
	else
		_G.GetAddOnInfo = function(addon)
			if not addon then
				return
			end
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addon)
			local build, url, newVersion
			notes, build, url, newVersion = checkAddonVersion(name, notes)

			if CUSTOM_INFO_BEHAVIOUR then
				return name, title, notes, url, loadable, reason, security, newVersion, build
			else
				return name, title, notes, enabled, loadable, reason, security, newVersion, build, url
			end
		end
	end

	local EnableAddOn = EnableAddOn
	if IN_GLUE_STATE then -- EnableAddOn
		_G.EnableAddOn = function(character, addonIndex)
			local _, _, _, _, _, _, _, newVersion = _G.GetAddOnInfo(addonIndex)
			if not newVersion then
				EnableAddOn(character, addonIndex)
			end
		end
	else
		_G.EnableAddOn = function(addon)
			local _, _, _, _, _, _, _, newVersion = _G.GetAddOnInfo(addon)
			if not newVersion then
				EnableAddOn(addon)
			end
		end
	end

	local select = select
	local GetAddOnEnableState = GetAddOnEnableState
	_G.GetAddOnEnableState = function(characterName, addonIndex)
		if type(characterName) == "number" and addonIndex == nil then
			addonIndex = characterName
			if IN_GLUE_STATE then
				characterName = nil
			else
				characterName = UnitName("player")
			end
		end

		local newVersion

		if IN_GLUE_STATE then
			newVersion = select(8, _G.GetAddOnInfo(addonIndex))
		else
			newVersion = select(8, _G.GetAddOnInfo(addonIndex))
		end

		if newVersion then
			return 0
		end

		return GetAddOnEnableState(characterName, addonIndex)
	end

	if not IN_GLUE_STATE then
		local customAddons = {
			blizzard_barbershopui = true,
			blizzard_battlefieldminimap = true,
			blizzard_calendar = true,
			blizzard_glyphui = true,
			blizzard_inspectui = true,
			blizzard_itemsocketingui = true,
			blizzard_macroui = true,
			blizzard_raidui = true,
			blizzard_talentui = true,
			blizzard_timemanager = true,
			blizzard_tokenui = true,
			blizzard_tradeskillui = true,
			blizzard_trainerui = true,
			blizzard_vehicleui = true,
		}

		local isCustomAddon = function(addon)
			if type(addon) == "number" then
				local addonName = GetAddOnInfo(addon)
				return customAddons[string.lower(addonName)]
			elseif type(addon) == "string" then
				return customAddons[string.lower(addon)]
			end
		end

		local LoadAddOn = LoadAddOn
		_G.LoadAddOn = function(addon)
			if isCustomAddon(addon) then
				return 1, nil
			end

			return LoadAddOn(addon)
		end

		local IsAddOnLoaded = IsAddOnLoaded
		_G.IsAddOnLoaded = function(addon)
			if isCustomAddon(addon) then
				return 1, 1
			end

			return IsAddOnLoaded(addon)
		end

		local IsAddOnLoadOnDemand = IsAddOnLoadOnDemand
		_G.IsAddOnLoadOnDemand = function(addon)
			if isCustomAddon(addon) then
				return nil
			end

			return IsAddOnLoadOnDemand(addon)
		end
	end
end

if not IN_GLUE_STATE then
	local GetDefaultLanguage = GetDefaultLanguage
	_G.GetDefaultLanguage = function()
		local factionID = C_FactionManager.GetFactionOverride()
		if factionID and factionID ~= PLAYER_FACTION_GROUP.Neutral then
			return PLAYER_FACTION_LANGUAGE[factionID]
		else
			return GetDefaultLanguage()
		end
	end

	local SendChatMessage = SendChatMessage
	_G.SendChatMessage = function(arg1, arg2, arg3, ...)
		if not arg3 then
			arg3 = GetDefaultLearnLanguage()
		end
		SendChatMessage(arg1, arg2, arg3, ...)
	end

	local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
	---@param index number
	---@return string name
	---@return number count
	---@return number extraCurrencyType
	---@return string icon
	---@return number itemID
	_G.GetBackpackCurrencyInfo = function(index)
		local name, count, extraCurrencyType, icon, itemID = GetBackpackCurrencyInfo(index)

		if itemID then
			if itemID == 43307 then -- Arena
				local factionID = C_Unit.GetFactionID("player")
				if factionID then
					icon = "Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID]
				end
			elseif itemID == 43308 then -- Honor
				local factionID = C_Unit.GetFactionID("player")
				if factionID then
					icon = "Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID]
				end
			end
		end

		return name, count, extraCurrencyType, icon, itemID
	end

	local GetCurrencyListInfo = GetCurrencyListInfo
	---@param index number
	---@return string name
	---@return boolean isHeader
	---@return boolean isExpanded
	---@return boolean isUnused
	---@return boolean isWatched
	---@return number count
	---@return number extraCurrencyType
	---@return string icon
	---@return number itemID
	_G.GetCurrencyListInfo = function(index)
		local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = GetCurrencyListInfo(index)

		if itemID then
			if itemID == 43307 then -- Arena
				local factionID = C_Unit.GetFactionID("player")
				if factionID then
					icon = "Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID]
				end
			elseif itemID == 43308 then -- Honor
				local factionID = C_Unit.GetFactionID("player")
				if factionID then
					icon = "Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID]
				end
			end
		end

		return name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID
	end

	local UnitExists = UnitExists
	local UnitIsUnit = UnitIsUnit
	local UnitFactionGroup = UnitFactionGroup
	---@param unit string
	---@return string englishFaction
	---@return string localizedFaction
	_G.UnitFactionGroup = function(unit)
		if not UnitExists(unit) then
			return UnitFactionGroup(unit)
		end

		if UnitIsUnit("player", unit) then
			local factionID = C_FactionManager.GetFactionOverride()

			if factionID then
				local factionTag = PLAYER_FACTION_GROUP[factionID]
				return factionTag, _G["FACTION_"..string.upper(factionTag)]
			else
				return UnitFactionGroup(unit)
			end
		else
			local factionTag, localizedFaction = UnitFactionGroup(unit)
			local overrideFactionID = C_Unit.GetFactionByDebuff(unit)

			if overrideFactionID then
				local overrideFactionTag = PLAYER_FACTION_GROUP[overrideFactionID]

				if overrideFactionTag ~= factionTag then
					return overrideFactionTag, _G["FACTION_"..string.upper(overrideFactionTag)]
				end
			end

			return factionTag, localizedFaction
		end
	end

	do -- SecureCmdOptionParse
		local tonumber = tonumber
		local strgmatch, strgsub, strmatch = string.gmatch, string.gsub, string.match

		local fixSpecIDs = function(specStr)
			for specID in strgmatch(specStr, "(%d+)") do
				if C_Talent.GetActiveTalentGroup() == tonumber(specID) then
					return "spec:1"
				end
			end
			return "spec:0"
		end

		---@param options string
		---@return string value
		local SecureCmdOptionParse = SecureCmdOptionParse
		_G.SecureCmdOptionParse = function(options)
			local specs = strmatch(options, "spec:([^,%]]+)")
			if specs then
				return SecureCmdOptionParse(strgsub(options, "spec:([^,%]]+)", fixSpecIDs))
			else
				return SecureCmdOptionParse(options)
			end
		end
	end

	local FillLocalizedClassList = FillLocalizedClassList
	_G.FillLocalizedClassList = function(classTable, isFemale)
		FillLocalizedClassList(classTable, isFemale)
		classTable.DEMONHUNTER = nil
		return classTable
	end

	local GetHonorCurrency = GetHonorCurrency
	_G.GetHonorCurrency = function()
		return GetHonorCurrency(), 2500000
	end
	local GetArenaCurrency = GetArenaCurrency
	_G.GetArenaCurrency = function()
		return GetArenaCurrency(), 25000
	end

	local pairs = pairs
	local UnitClass = UnitClass
	_G.UnitClass = function(unit)
		local className, classToken = UnitClass(unit)
		local classID, classFlag

		for id, classInfo in pairs(S_CLASS_SORT_ORDER) do
			if classInfo[2] == classToken then
				classID = id
				classFlag = classInfo[1]
				break
			end
		end

		return className, classToken, classID, classFlag
	end

	local UnitRace = UnitRace
	_G.UnitRace = function(unit)
		local localizedRace, race = UnitRace(unit)
		local raceData = S_CHARACTER_RACES_INFO_LOCALIZATION_ASSOC[localizedRace]
		local raceID = raceData and raceData.raceID or -1

		if raceID == E_CHARACTER_RACES.RACE_PANDAREN_ALLIANCE
		or raceID == E_CHARACTER_RACES.RACE_PANDAREN_HORDE
		or raceID == E_CHARACTER_RACES.RACE_PANDAREN_NEUTRAL
		or raceID == E_CHARACTER_RACES.RACE_VULPERA_ALLIANCE
		or raceID == E_CHARACTER_RACES.RACE_VULPERA_HORDE
		or raceID == E_CHARACTER_RACES.RACE_VULPERA_NEUTRAL
		then
			localizedRace = string.gsub(localizedRace, "%s*%([^%)]+%)", "")
		end

		return localizedRace, race, raceID
	end

	local GetActionInfo = GetActionInfo
	_G.GetActionInfo = function(action)
		local actionType, id, subType, spellID = GetActionInfo(action)

		if FLYOUT_STORAGE[spellID] then
			actionType = "flyout"
		end

		return actionType, id, subType, spellID
	end

	do -- CalculateAuctionDeposit
		local AUCTION_DEPOSIT_THRESHOLD = 500 * 10000
		local AUCTION_MIN_DEPOSIT = 100

		_CalculateAuctionDeposit = _CalculateAuctionDeposit or CalculateAuctionDeposit
		function CalculateAuctionDeposit(runTime, ...)
			local name = GetAuctionSellItemInfo()
			local itemName, _, _, _, _, itemType = GetItemInfo(name)
			if itemName and itemName ~= "" and itemType == ITEM_CLASS_7 then
				local numStacks = AuctionsNumStacksEntry:GetNumber()

				local startPrice = MoneyInputFrame_GetCopper(StartPrice)
				local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice)
				if AuctionFrameAuctions.priceType == 2 then
					startPrice = startPrice / AuctionsStackSizeEntry:GetNumber()
					buyoutPrice = buyoutPrice / AuctionsStackSizeEntry:GetNumber()
				end

				local maxPrice = math.max(startPrice, buyoutPrice)
				if maxPrice < AUCTION_DEPOSIT_THRESHOLD then
					return (AUCTION_MIN_DEPOSIT + math.ceil(maxPrice * 0.2)) * numStacks
				else
					return _CalculateAuctionDeposit(runTime, ...)
				end
			end

			return _CalculateAuctionDeposit(runTime, ...)
		end
	end

	local GetNumFriends = GetNumFriends
	local RemoveFriend = RemoveFriend
	_G.RemoveFriend = function(name)
		if type(name) == "string" and tonumber(name) then
			for i = 1, GetNumFriends() do
				if name == GetFriendInfo(i) then
					return RemoveFriend(i)
				end
			end
		else
			return RemoveFriend(name)
		end
	end

	local GetInstanceInfo = GetInstanceInfo
	_G.GetInstanceInfo = function()
		local name, instanceType, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo()
		if difficultyIndex == 1 and instanceType == "raid" and maxPlayers == 25 then
			difficultyIndex = 2
		end
		return name, instanceType, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic
	end

	local GetInstanceDifficulty = GetInstanceDifficulty
	_G.GetInstanceDifficulty = function()
		local difficulty = GetInstanceDifficulty()
		if difficulty == 1 then
			local _, instanceType, difficultyIndex, _, maxPlayers = GetInstanceInfo()
			if difficultyIndex == 1 and instanceType == "raid" and maxPlayers == 25 then
				difficulty = 2
			end
		end
		return difficulty
	end

	do
		local ShowHelm = ShowHelm
		local ShowingHelm = ShowingHelm

		local helmToggleStep

		local eventHandler = CreateFrame("Frame")
		eventHandler:RegisterEvent("BARBER_SHOP_CLOSE")
		eventHandler:SetScript("OnEvent", function(this, event, ...)
			if event == "BARBER_SHOP_CLOSE" then
				if ValueToBoolean(ShowingHelm()) then
					helmToggleStep = 1
					eventHandler:RegisterEvent("UNIT_MODEL_CHANGED")
					eventHandler:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED")
				end
			elseif event == "UNIT_MODEL_CHANGED" or event == "BARBER_SHOP_APPEARANCE_APPLIED" then
				local unit = ...
				if unit == "player" then
					eventHandler:UnregisterEvent("BARBER_SHOP_APPEARANCE_APPLIED")

					if helmToggleStep == 1 then
						ShowHelm(false)
						helmToggleStep = 2
					elseif helmToggleStep == 2 then
						eventHandler:UnregisterEvent("UNIT_MODEL_CHANGED")
						helmToggleStep = nil
						ShowHelm(true)
					end
				end
			end
		end)
	end

	do -- GetMoney
		local GetMoney = GetMoney
		local PlaySound = PlaySound

		local MAX_NATIVE_MONEY = 2^31 - 1

		local eventHandler = CreateFrame("Frame")
		eventHandler:RegisterEvent("CHAT_MSG_ADDON")
		eventHandler:SetScript("OnEvent", function(this, event, ...)
			if event == "CHAT_MSG_ADDON" then
				local prefix, msg, distribution, sender = ...
				if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
					return
				end
				if prefix == "ASMSG_P_M" then
					local money = tonumber(msg)
					money = type(money) == "number" and money or nil

					local customMoney = C_CacheInstance and tonumber(C_CacheInstance:Get("PLAYER_MONEY")) or nil
					if customMoney -- skip initial msg
					and customMoney ~= money -- changed
					and customMoney >= MAX_NATIVE_MONEY -- native was already overflowed
					then
						PlaySound("LOOTWINDOWCOINSOUND")
					end
					C_CacheInstance:Set("PLAYER_MONEY", money)
					FireClientEvent("PLAYER_MONEY")
				end
			end
		end)

		_G.GetMoney = function()
			local customMoney = C_CacheInstance and C_CacheInstance:Get("PLAYER_MONEY") or nil
			return customMoney and tonumber(customMoney) or GetMoney()
		end
	end
end