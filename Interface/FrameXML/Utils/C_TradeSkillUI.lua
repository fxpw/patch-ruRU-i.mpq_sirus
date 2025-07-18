local error = error
local ipairs = ipairs
local select = select
local tonumber = tonumber
local type = type
local strformat, strmatch, strsplit = string.format, string.match, string.split
local tconcat, tinsert, tremove = table.concat, table.insert, table.remove

local GetCVar = GetCVar
local GetTradeSkillByRecipeID = GetTradeSkillByRecipeID
local GetTradeSkillRecipeInfo = GetTradeSkillRecipeInfo
local GetTradeSkillRecipeLink = GetTradeSkillRecipeLink
local GetTradeSkillRecipeLinkByID = GetTradeSkillRecipeLinkByID
local GetTradeSkillRecipeReagents = GetTradeSkillRecipeReagents
local GetTradeSkillSelectionIndex = GetTradeSkillSelectionIndex
local IsRecipeProfessionLearned = IsRecipeProfessionLearned
local IsTradeSkillRecipe = IsTradeSkillRecipe
local OpenTradeSkillByRecipeID = OpenTradeSkillByRecipeID
local SetCVar = SetCVar

local FireCustomClientEvent = FireCustomClientEvent
local tIndexOf = tIndexOf

local PROFESSIONS_WATCH_TOO_MANY = PROFESSIONS_WATCH_TOO_MANY

local TRADESKILL_TRACKED_RECIPE_DELIMITER = ";"
local TRADESKILL_TRACKED_RECIPE_LIMIT = 20

PRIVATE = {}

PRIVATE.EventHandler = CreateFrame("Frame")
PRIVATE.EventHandler:Hide()
PRIVATE.EventHandler:RegisterEvent("VARIABLES_LOADED")
PRIVATE.EventHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		PRIVATE.ValidateTrackedRecipes()
	end
end)

PRIVATE.IsValidRecipe = function(recipeID)
	if IsTradeSkillRecipe(recipeID) then
		return true
	end
	return false
end

PRIVATE.GetTrackedRecipes = function()
	local value = GetCVar("trackedProfessionRecipes")
	if value ~= "" then
		local list = {}
		for index, recipeID in ipairs({strsplit(TRADESKILL_TRACKED_RECIPE_DELIMITER, value)}) do
			recipeID = tonumber(recipeID)
			if recipeID then
				tinsert(list, tonumber(recipeID))
			end
		end
		return list
	end
end

PRIVATE.SetTrackedRecipe = function(recipeID, tracked)
	if recipeID < 0
	or not PRIVATE.IsValidRecipe(recipeID)
	then
		return false
	end

	local recipeList = PRIVATE.GetTrackedRecipes()
	if not recipeList then
		if tracked then
			SetCVar("trackedProfessionRecipes", recipeID)
		else
			return false
		end
	else
		if tracked then
			if not tIndexOf(recipeList, recipeID) then
				if #recipeList >= TRADESKILL_TRACKED_RECIPE_LIMIT then
					FireClientEvent("UI_ERROR_MESSAGE", strformat(PROFESSIONS_WATCH_TOO_MANY, TRADESKILL_TRACKED_RECIPE_LIMIT))
					return
				end
				tinsert(recipeList, recipeID)
				SetCVar("trackedProfessionRecipes", tconcat(recipeList, TRADESKILL_TRACKED_RECIPE_DELIMITER))
			else
				return false
			end
		else
			local index = tIndexOf(recipeList, recipeID)
			if index then
				tremove(recipeList, index)
				SetCVar("trackedProfessionRecipes", tconcat(recipeList, TRADESKILL_TRACKED_RECIPE_DELIMITER))
			else
				return false
			end
		end
	end

	tracked = not not tracked
	FireCustomClientEvent("TRACKED_RECIPE_UPDATE", recipeID, tracked)

	return true
end

PRIVATE.ValidateTrackedRecipes = function()
	local recipeList = PRIVATE.GetTrackedRecipes()
	if recipeList then
		local changed
		local index = #recipeList
		local recipeID = recipeList[index]
		while recipeID do
			if index > TRADESKILL_TRACKED_RECIPE_LIMIT or not PRIVATE.IsValidRecipe(recipeID) then
				tremove(recipeList, index)
				changed = true
			else
				index = index - 1
			end
			recipeID = recipeList[index]
		end
		if changed then
			SetCVar("trackedProfessionRecipes", tconcat(recipeList, TRADESKILL_TRACKED_RECIPE_DELIMITER))
		end
		return changed
	end
	return false
end

PRIVATE.BuildRecipeReagents = function(...)
	local numEntries = select("#", ...)
	if numEntries == 0 then
		return
	end

	local reagentList = {}
	for reagentInfoOffset = 1, numEntries, 2 do
		local recipeItemID, reagentQuantityRequired = select(reagentInfoOffset, ...)
		tinsert(reagentList, {
			itemID = recipeItemID,
			quantityRequired = reagentQuantityRequired,
		})
	end
	return reagentList
end

PRIVATE.GetRecipeIDForIndex = function(index)
	local recipeLink = GetTradeSkillRecipeLink(index)
	if recipeLink then
		local recipeID = strmatch(recipeLink, "enchant:(%d+)")
		if recipeID then
			return tonumber(recipeID)
		end
	end
end

C_TradeSkillUI = {}

function C_TradeSkillUI.OpenRecipe(recipeID)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.OpenRecipe' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	OpenTradeSkillByRecipeID(recipeID)
end

function C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.GetProfessionInfoByRecipeID' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	return GetTradeSkillByRecipeID(recipeID)
end

function C_TradeSkillUI.GetTradeSkillSelectionRecipeID()
	local selectedIndex = GetTradeSkillSelectionIndex()
	if selectedIndex then
		return PRIVATE.GetRecipeIDForIndex(selectedIndex)
	end
end

function C_TradeSkillUI.GetTradeSkillRecipeIDForIndex(index)
	if type(index) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.GetTradeSkillRecipeIDForIndex' (number expected, got %s)", index ~= nil and type(index) or "no value"), 2)
	end

	return PRIVATE.GetRecipeIDForIndex(index)
end

function C_TradeSkillUI.GetRecipeLink(recipeID)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.GetRecipeLink' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	return GetTradeSkillRecipeLinkByID(recipeID)
end

function C_TradeSkillUI.IsRecipeTracked(recipeID)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.IsRecipeTracked' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	local recipeList = PRIVATE.GetTrackedRecipes()
	if recipeList then
		return tIndexOf(recipeList, recipeID) ~= nil
	end
	return false
end

function C_TradeSkillUI.IsRecipeProfessionLearned(recipeID)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.IsRecipeProfessionLearned' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	local isProfessionLearned, isRecipeLearned = IsRecipeProfessionLearned(recipeID)
	if isProfessionLearned and isRecipeLearned then
		return true
	end
	return false
end

function C_TradeSkillUI.CanTrackRecipe(recipeID)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.CanTrackRecipe' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	return PRIVATE.IsValidRecipe(recipeID)
end

function C_TradeSkillUI.SetRecipeTracked(recipeID, tracked, isRecraft)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.SetRecipeTracked' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	return PRIVATE.SetTrackedRecipe(recipeID, tracked)
end

function C_TradeSkillUI.GetRecipesTracked(isRecraft)
	return PRIVATE.GetTrackedRecipes() or {}
end

function C_TradeSkillUI.GetRecipeInfo(recipeID, isRecraft)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.GetRecipeInfo' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	if not IsTradeSkillRecipe(recipeID) then
		return
	end

	return GetTradeSkillRecipeInfo(recipeID)
end

function C_TradeSkillUI.GetRecipeReagentsInfo(recipeID, isRecraft)
	if type(recipeID) ~= "number" then
		error(strformat("bad argument #1 to 'C_TradeSkillUI.GetRecipeReagentsInfo' (number expected, got %s)", recipeID ~= nil and type(recipeID) or "no value"), 2)
	end

	if not IsTradeSkillRecipe(recipeID) then
		return
	end

	return PRIVATE.BuildRecipeReagents(GetTradeSkillRecipeReagents(recipeID)) or {}
end