local contents = {};
local issecure = issecure;
local type = type;
local pairs = pairs;
local select = select;

--Create a local version of this function just so we don't have to worry about changes
local function copyTable(tab)
	local copy = {};
	for k, v in pairs(tab) do
		if ( type(v) == "table" ) then
			copy[k] = copyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

function SecureCapsuleGet(name)
	if ( not issecure() ) then
		return;
	end

	if ( type(contents[name]) == "table" ) then
		--Segment the users
		return copyTable(contents[name]);
	else
		return contents[name];
	end
end

-------------------------------
--Local functions for retaining.
-------------------------------

--Retains a copy of name
local function retain(name)
	if ( type(_G[name]) == "table" ) then
		contents[name] = copyTable(_G[name]);
	else
		contents[name] = _G[name];
	end
end

--Takes name and removes it from the global environment (note: make sure that nothing else has saved off a copy)
local function take(name)
	contents[name] = _G[name];
	_G[name] = nil;
end

--Removes something from the global environment entirely (note: make sure that any saved references are local and will not be returned or otherwise exposed under any circumstances)
local function remove(name)
	_G[name] = nil;
end

-- We create the "Enum" table directly in contents because we dont want the reference from _G in the secure environment
local function retainenum(name)
	if (not contents["Enum"]) then
		contents["Enum"] = {};
	end
	contents["Enum"][name] = copyTable(_G.Enum[name]);
end

local function takeenum(name)
	if (not contents["Enum"]) then
		contents["Enum"] = {};
	end
	contents["Enum"][name] = _G.Enum[name];
	_G.Enum[name] = nil;
end

-------------------------------
--Things we actually want to save
-------------------------------

--If storing off Lua functions, be careful that they don't in turn call any other Lua functions that may have been swapped out.

--For store
--take("C_StoreSecure");
--take("CreateForbiddenFrame");
--retain("IsGMClient");
--retain("IsOnGlueScreen");
retain("math");
retain("table");
retain("string");
retain("bit");
retain("pairs");
retain("ipairs");
retain("next");
retain("select");
retain("unpack");
retain("tostring");
retain("tonumber");
retain("date");
retain("time");
retain("type");
retain("wipe");
retain("error");
retain("assert");
retain("strtrim");
--retain("LoadURLIndex");
retain("GetContainerNumFreeSlots");
retain("GetCursorPosition");
retain("GetRealmName");
retain("PlaySound");
retain("SetPortraitToTexture");
retain("SetPortraitTexture");
retain("getmetatable");
retain("BACKPACK_CONTAINER");
retain("NUM_BAG_SLOTS");
retain("RAID_CLASS_COLORS");
retain("CLASS_ICON_TCOORDS");
retain("C_Timer");
--retain("C_ModelInfo");
retain("IsModifiedClick");
retain("GetTime");
retain("UnitAffectingCombat");
retain("GetCVar");
retain("GMError");
retain("GetMouseFocus");
retain("LOCALE_enGB");
retain("CreateFrame");
retain("Lerp");
retain("Clamp");
retain("PercentageBetween");
retain("Saturate");
--retain("DeltaLerp");
retain("SOUNDKIT");
retain("GetScreenWidth");
retain("GetScreenHeight");
--retain("GetPhysicalScreenSize");
--retain("GetScreenDPIScale");
--retain("IsTrialAccount");
--retain("IsVeteranTrialAccount");
--retain("C_StorePublic");
--retain("C_Club");
retain("UnitFactionGroup");
retain("FrameUtil");
retain("strlenutf8");
retain("UnitRace");
retain("UnitSex");
--retain("GetURLIndexAndLoadURL");
--retain("GetUnscaledFrameRect");
--retain("BLIZZARD_STORE_EXTERNAL_LINK_BUTTON_TEXT");
retain("Round");
--retain("IsCharacterNPERestricted");

--For auth challenge
--take("C_AuthChallenge");
retain("IsShiftKeyDown");
retain("GetBindingFromClick");

--For character services
--retain("C_SharedCharacterServices");
--retain("C_CharacterServices");
--retain("C_ClassTrial");

--For secure transfer
--take("C_SecureTransfer");

--GlobalStrings
--retain("BLIZZARD_STORE");
--retain("HTML_START");
--retain("HTML_START_CENTERED");
--retain("HTML_END");

retain("GOLD_AMOUNT_SYMBOL");
retain("GOLD_AMOUNT_TEXTURE");
--retain("GOLD_AMOUNT_TEXTURE_STRING");
retain("SILVER_AMOUNT_SYMBOL");
retain("SILVER_AMOUNT_TEXTURE");
--retain("SILVER_AMOUNT_TEXTURE_STRING");
retain("COPPER_AMOUNT_SYMBOL");
retain("COPPER_AMOUNT_TEXTURE");
--retain("COPPER_AMOUNT_TEXTURE_STRING");
retain("SHORTDATE");
--retain("SHORTDATE_EU");
retain("AUCTION_TIME_LEFT1_DETAIL");
retain("AUCTION_TIME_LEFT2_DETAIL");
retain("AUCTION_TIME_LEFT3_DETAIL");
retain("AUCTION_TIME_LEFT4_DETAIL");
--retain("WEEKS_ABBR");
retain("DAYS_ABBR");
retain("HOURS_ABBR");
retain("MINUTES_ABBR");
retain("OKAY");
--retain("LARGE_NUMBER_SEPERATOR");
--retain("DECIMAL_SEPERATOR");
retain("TOOLTIP_DEFAULT_COLOR");
retain("TOOLTIP_DEFAULT_BACKGROUND_COLOR");
retain("ACCEPT");
retain("CANCEL");
retain("CREATE_AUCTION");
retain("CONTINUE");
retain("FACTION_HORDE");
retain("FACTION_ALLIANCE");
retain("LIST_DELIMITER");

--take("SEND_ITEMS_TO_STRANGER_WARNING");
--take("SEND_MONEY_TO_STRANGER_WARNING");
--take("TRADE_ACCEPT_CONFIRMATION");

retain("RED_FONT_COLOR");

--Lua enums

--Tag enums

-- Secure Mixins
-- where ... are the mixins to mixin
function SecureMixin(object, ...)
	if ( not issecure() ) then
		return;
	end

	for i = 1, select("#", ...) do
		local mixin = select(i, ...);
		for k, v in pairs(mixin) do
			object[k] = v;
		end
	end

	return object;
end

-- This is Private because we need a pristine copy to reference in CreateFromSecureMixins.
local SecureMixinPrivate = SecureMixin;

-- where ... are the mixins to mixin
function CreateFromSecureMixins(...)
	if ( not issecure() ) then
		return;
	end

	return SecureMixinPrivate({}, ...)
end

take("SecureMixin");
take("CreateFromSecureMixins");

retain("GetFinalNameFromTextureKit")
retain("C_Texture");

--retain("C_RecruitAFriend");

-- retain shared constants

remove("SECURE_IsForbidden");
remove("SECURE_SetForbidden");

retain("FACTION_OVERRIDE_BY_DEBUFFS");
retain("S_CATEGORY_SPELL_ID");
retain("S_VIP_STATUS_DATA");

take("CUF_SPELL_BOSS_AURA");
take("CUF_SPELL_CAN_APPLY_AURAS");
take("CUF_SPELL_VISIBILITY_RANK_LINKS");
take("CUF_SPELL_VISIBILITY_SELF_BUFF");

take("CUF_SPELL_PRIORITY_AURA");
take("CUF_SPELL_VISIBILITY_BLACKLIST");
take("CUF_SPELL_VISIBILITY_DATA");
take("CUF_SPELL_VISIBILITY_TYPES");