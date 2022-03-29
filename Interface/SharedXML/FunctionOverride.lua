--	Filename:	FunctionOverride.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

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

local _SetCVar = _SetCVar or SetCVar

function SetCVar( CVar, value, raiseEvent )
	if C_CVar and string.Left(CVar, 7) == "C_CVAR_" then
		return C_CVar:SetValue(CVar, value, raiseEvent)
	end

	return _SetCVar(CVar, value, raiseEvent)
end

local _GetCVar = _GetCVar or GetCVar

function GetCVar( CVar )
	if C_CVar and string.Left(CVar, 7) == "C_CVAR_" then
		return C_CVar:GetValue(CVar)
	end

	return _GetCVar(CVar)
end

local _GetCVarBool = _GetCVarBool or GetCVarBool

function GetCVarBool(CVar)
	if C_CVar and string.Left(CVar, 7) == "C_CVAR_" then
		return ValueToBoolean(C_CVar:GetValue(CVar));
	end

	return _GetCVarBool(CVar);
end

local _GetCVarDefault = _GetCVarDefault or GetCVarDefault

function GetCVarDefault( CVar )
	if C_CVar and string.Left(CVar, 7) == "C_CVAR_" then
		return C_CVar:GetDefaultValue(CVar)
	end

	return _GetCVarDefault(CVar)
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
	if C_Service:IsLockRenegadeFeatures() then
		return _UnitFactionGroup(unit)
	end

	if unit and string.upper(unit) == "PLAYER" then
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

---@param options string
---@return string value
function SecureCmdOptionParse( options )
    local specID = options:match("spec:(%d+)")

    if specID then
        specID = tonumber(specID)

        if C_Talent.GetSelectedTalentGroup() == specID then
            return _SecureCmdOptionParse(options:gsub("spec:(%d+)", ""))
        else
            local lastOptions = options:match(";(.*)")

            if lastOptions and lastOptions ~= "" then
                return string.TrimLeft(lastOptions, " ")
            end
        end
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

local _GetAddOnInfo = _GetAddOnInfo or GetAddOnInfo
function GetAddOnInfo( value )
	if not value then
		return
	end

	local name, title, notes, url, loadable, reason, security, newVersion = _GetAddOnInfo(value)
	local build
	local needUpdate = nil

	if ( name and notes ) then
		local pattern = "%|%@Version: (%d+)%@%|"
		build = string.match(notes, pattern)
		notes = string.gsub(notes, pattern, "")

		if build then
			build = tonumber(build)
		end

		local addonData

		for _, v in pairs(S_ADDON_VERSION or {}) do
			if tContains(v[3], name) then
				addonData = v
				break
			end
		end

		if addonData then
			local dataBuild = addonData[1]
			url = "https://sirus.su/base/addons/"..addonData[2]

			if ( build and build < dataBuild ) then
				needUpdate = true
			elseif ( not build ) then
				needUpdate = true
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

AURA_CACHE = {}
_UnitDebuff = _UnitDebuff or UnitDebuff
function UnitDebuff( unit, index, ... )
	if type(index) == "number" then
		if AURA_CACHE[unit] and AURA_CACHE[unit][index] then
			return _UnitDebuff(unit, AURA_CACHE[unit][index], ...)
		else
			return _UnitDebuff(unit, index, ...)
		end
	else
		return _UnitDebuff(unit, index, ...)
	end
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