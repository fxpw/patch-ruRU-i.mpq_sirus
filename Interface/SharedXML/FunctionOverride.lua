local securecall = securecall

do	-- CVars
	local strsub = string.sub

	local SetCVar = SetCVar
	local _SetCVar = function(cvar, value, raiseEvent)
		if C_CVar and strsub(cvar, 1, 7) == "C_CVAR_" then
			return C_CVar:SetValue(cvar, value, raiseEvent)
		end
		return SetCVar(cvar, value, raiseEvent)
	end
	_G.SetCVar = function(cvar, value, raiseEvent)
		return securecall(_SetCVar, cvar, value, raiseEvent)
	end

	local GetCVar = GetCVar
	local _GetCVar = function(cvar)
		if C_CVar and strsub(cvar, 1, 7) == "C_CVAR_" then
			return C_CVar:GetValue(cvar)
		end
		return GetCVar(cvar)
	end
	_G.GetCVar = function(cvar)
		return securecall(_GetCVar, cvar)
	end

	local GetCVarBool = GetCVarBool
	local _GetCVarBool = function(cvar)
		if C_CVar and strsub(cvar, 1, 7) == "C_CVAR_" then
			return ValueToBoolean(C_CVar:GetValue(cvar))
		end
		return GetCVarBool(cvar);
	end
	_G.GetCVarBool = function(cvar)
		return securecall(_GetCVarBool, cvar)
	end
	
	local GetCVarDefault = GetCVarDefault
	local _GetCVarDefault = function( cvar )
		if C_CVar and strsub(cvar, 1, 7) == "C_CVAR_" then
			return C_CVar:GetDefaultValue(cvar)
		end
		return GetCVarDefault(cvar)
	end
	_G.GetCVarDefault = function( cvar )
		return securecall(_GetCVarDefault, cvar)
	end

	function GetSafeCVar(cvar, default)
		local success, res = pcall(GetCVar, cvar)
		if not success then
			return default
		elseif res then
			return res
		end
	end
	function SetSafeCVar(cvar, value, raiseEvent)
		local val = GetSafeCVar(cvar)
		if val then
			SetCVar(cvar, value, raiseEvent)
		end
	end
end

local _GetMapLandmarkInfo = _GetMapLandmarkInfo or GetMapLandmarkInfo

function GetMapLandmarkInfo( index )
	local name, description, textureIndex, x, y, maplinkID, showInBattleMap = _GetMapLandmarkInfo(index)

	if GetCurrentMapAreaID() == 917 and textureIndex == 45 then
		textureIndex = 192
	end

	return name, description, textureIndex, x, y, maplinkID, showInBattleMap
end

local _CancelLogout = _CancelLogout or CancelLogout

function CancelLogout()
	C_CacheInstance:SetSavedState(false)
	_CancelLogout()
end

local _Logout = _Logout or Logout

function Logout()
	C_CacheInstance:SaveData()
	_Logout()
end

local _ConsoleExec = _ConsoleExec or ConsoleExec

function ConsoleExec( command )
	if string.upper(command) == "RELOADUI" then
		C_CacheInstance:SaveData()
		_ConsoleExec(command)
		return
	end

	_ConsoleExec(command)
end

local _ReloadUI = _ReloadUI or ReloadUI

function ReloadUI()
	C_CacheInstance:SaveData()
	_ReloadUI()
end

local _RestartGx = _RestartGx or RestartGx

function RestartGx()
	C_CacheInstance:SaveData()
	_RestartGx()
end

local _SendChatMessage = _SendChatMessage or SendChatMessage

function SendChatMessage(...)
	local args = {...}

	if not args[3] then
		args[3] = GetDefaultLearnLanguage()
	end

	_SendChatMessage(unpack(args))
end

local _EnterWorld = _EnterWorld or EnterWorld

function EnterWorld()
	C_CacheInstance:SaveData()
	_EnterWorld()
end

local _GetCategoryList = _GetCategoryList or GetCategoryList -- TEMP
local categoryList = {}

function GetCategoryList()
	local isLockRenegade = C_Service:IsLockRenegadeFeatures()
	local isLockStrengthenStats = C_Service:IsLockStrengthenStatsFeature()

	if isLockRenegade or isLockStrengthenStats then
		if categoryList and #categoryList == 0 then
			local lockedCategories = {
				[15050] = isLockRenegade,
				[15061] = isLockRenegade,
				[15043] = isLockStrengthenStats,
			}

			for _, id in pairs(_GetCategoryList()) do
				if not lockedCategories[id] then
					table.insert(categoryList, id)
				end
			end
		end

		return categoryList
	else
		return _GetCategoryList()
	end
end

local _GetBackpackCurrencyInfo = _GetBackpackCurrencyInfo or GetBackpackCurrencyInfo

---@param index number
---@return string name
---@return number count
---@return number extraCurrencyType
---@return string icon
---@return number itemID
function GetBackpackCurrencyInfo( index )
	local name, count, extraCurrencyType, icon, itemID = _GetBackpackCurrencyInfo(index)

	if itemID then
		local factionID = C_Unit:GetFactionID("player")

		if factionID then
			if itemID == 43307 then -- Arena
				icon = "Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID]
			elseif itemID == 43308 then -- Honor
				icon = "Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID]
			end
		end
	end

	return name, count, extraCurrencyType, icon, itemID
end

local _GetCurrencyListInfo = _GetCurrencyListInfo or GetCurrencyListInfo

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
function GetCurrencyListInfo( index )
	local name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID = _GetCurrencyListInfo(index)

	if itemID then
		local factionID = C_Unit:GetFactionID("player")

		if factionID then
			if itemID == 43307 then -- Arena
				icon = "Interface\\PVPFrame\\PVPCurrency-Conquest1-"..PLAYER_FACTION_GROUP[factionID]
			elseif itemID == 43308 then -- Honor
 				icon = "Interface\\PVPFrame\\PVPCurrency-Honor1-"..PLAYER_FACTION_GROUP[factionID]
			end
		end
	end

	return name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon, itemID
end

local _UnitFactionGroup = _UnitFactionGroup or UnitFactionGroup

---@param unit string
---@return string englishFaction
---@return string localizedFaction
function UnitFactionGroup( unit )
	if not UnitExists(unit) or C_Service:IsLockRenegadeFeatures() then
		return _UnitFactionGroup(unit)
	end

	if UnitIsUnit("player", unit) then
		local factionID = C_FactionManager:GetFactionOverride()

		if factionID then
			local factionTag = PLAYER_FACTION_GROUP[factionID]
			return factionTag, _G["FACTION_"..string.upper(factionTag)]
		else
			return _UnitFactionGroup(unit)
		end
	else
		local factionTag, localizedFaction 	= _UnitFactionGroup(unit)
		local ovverideFactionID 			= C_Unit:GetFactionByDebuff(unit)

		if ovverideFactionID and factionTag then
			local ovverideFactionTag = PLAYER_FACTION_GROUP[ovverideFactionID]

			if ovverideFactionTag ~= factionTag then
				return ovverideFactionTag, _G["FACTION_"..string.upper(ovverideFactionTag)]
			end
		end

		return factionTag, localizedFaction
	end
end

local _GetDefaultLanguage = _GetDefaultLanguage or GetDefaultLanguage

-----@return string defaultLanguage
function GetDefaultLanguage()
	local factionID = C_FactionManager:GetFactionOverride()

	if factionID and factionID ~= PLAYER_FACTION_GROUP.Neutral then
		return PLAYER_FACTION_LANGUAGE[factionID]
	else
		return _GetDefaultLanguage()
	end
end

local _SecureCmdOptionParse = _SecureCmdOptionParse or SecureCmdOptionParse

local fixSpecIDs = function(specStr)
	for specID in string.gmatch(specStr, "(%d+)") do
		if C_Talent.GetActiveTalentGroup() == tonumber(specID) then
			return "spec:1"
		end
	end
	return "spec:0"
end

---@param options string
---@return string value
function SecureCmdOptionParse(options)
	local specs = options:match("spec:([^,%]]+)")

	if specs then
		return _SecureCmdOptionParse(options:gsub("spec:([^,%]]+)", fixSpecIDs))
	else
		return _SecureCmdOptionParse(options)
	end
end

local _FillLocalizedClassList = _FillLocalizedClassList or FillLocalizedClassList
function FillLocalizedClassList( classTable, isFemale )
	_FillLocalizedClassList(classTable, isFemale)

	classTable.DEMONHUNTER = nil

	return classTable
end

local _GetHonorCurrency = _GetHonorCurrency or GetHonorCurrency
function GetHonorCurrency()
	return select(1, _GetHonorCurrency()), 2500000
end

local _UnitClass = _UnitClass or UnitClass
function UnitClass( unit )
	local className, classToken = _UnitClass(unit)
	local classID, classFlag

	for key, data in pairs(S_CLASS_SORT_ORDER) do
		if data[2] == classToken then
			classID = key
			classFlag = data[1]
			break
		end
	end

	return className, classToken, classID, classFlag
end

local _GetAddOnInfo = GetAddOnInfo
function GetAddOnInfo( value )
	if not value then
		return
	end

	local name, title, notes, url, loadable, reason, security, newVersion = _GetAddOnInfo(value)
	local build, needUpdate

	if name and notes then
		local pattern = "%|%@Version: (%d+)%@%|"
		build = string.match(notes, pattern)
		notes = string.gsub(notes, pattern, "")

		if build then
			build = tonumber(build)
		end
		
		if S_ADDON_VERSION then
			for _, addonData in ipairs(S_ADDON_VERSION) do
				if tContains(addonData[3], name) then
					url = strconcat("https://sirus.su/base/addons/", addonData[2])

					if not build or build < addonData[1] then
						needUpdate = true
					end

					break
				end
			end
		end
	end

	newVersion = needUpdate

	return name, title, notes, url, loadable, reason, security, newVersion, needUpdate, build
end

local _GetAddOnEnableState = _GetAddOnEnableState or GetAddOnEnableState
function GetAddOnEnableState( character, addonIndex )
	local addonEnableStatus = _GetAddOnEnableState(character, addonIndex)

	if GetAddOnInfo then
		local name, title, notes, url, loadable, reason, security, newVersion, needUpdate, major, minor, build = GetAddOnInfo(addonIndex)

		if newVersion then
			addonEnableStatus = 0
		end
	end

	return addonEnableStatus
end

local _EnableAddOn = _EnableAddOn or EnableAddOn
function EnableAddOn( character, addonIndex )
	if GetAddOnInfo then
		local _, _, _, _, _, _, _, newVersion, _, _, _, _ = GetAddOnInfo(addonIndex)

		if not newVersion then
			_EnableAddOn(character, addonIndex)
		end
	else
		_EnableAddOn(character, addonIndex)
	end
end

local _GetActionInfo = _GetActionInfo or GetActionInfo
function GetActionInfo( action )
	local actionType, id, subType, spellID = _GetActionInfo(action)

	if FLYOUT_STORAGE[spellID] then
		actionType = "flyout"
	end

	return actionType, id, subType, spellID
end

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

local _RemoveFriend = _RemoveFriend or RemoveFriend
function RemoveFriend(name)
	if type(name) == "string" and tonumber(name) then
		local numFriends = GetNumFriends()
		if numFriends > 0 then
			for i = 1, numFriends do
				if name == GetFriendInfo(i) then
					return _RemoveFriend(i)
				end
			end
		end
	else
		return _RemoveFriend(name)
	end
end

local _GetInstanceInfo = _GetInstanceInfo or GetInstanceInfo;
function GetInstanceInfo()
	local name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = _GetInstanceInfo();
	if difficultyIndex == 1 and type == "raid" and maxPlayers == 25 then
		difficultyIndex = 2;
	end
	return name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic;
end

local _GetInstanceDifficulty = _GetInstanceDifficulty or GetInstanceDifficulty;
function GetInstanceDifficulty()
	local difficulty = _GetInstanceDifficulty();
	if difficulty == 1 then
		local _, type, difficultyIndex, _, maxPlayers = _GetInstanceInfo();
		if difficultyIndex == 1 and type == "raid" and maxPlayers == 25 then
			difficulty = 2;
		end
	end
	return difficulty;
end

local customAddons = {
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