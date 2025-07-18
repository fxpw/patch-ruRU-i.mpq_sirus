local function GetRecipeID(block)
	return math.abs(block.id);
end

local function IsRecraftBlock(block)
	return block.id < 0;
end

local settings = {
	headerText = PROFESSIONS_TRACKER_HEADER_PROFESSION,
	events = { "TRACKED_RECIPE_UPDATE", "BAG_UPDATE_DELAYED" },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
	collapseType = Enum.ObjectiveTrackerCollapsedStateType.ProfessionRecipeTracker,
};

ProfessionsRecipeTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

local IsRecrafting = true;

function ProfessionsRecipeTrackerMixin:OnEvent(event, ...)
	if event == "TRACKED_RECIPE_UPDATE" then
		local recipeID, added = ...;
		if added then
			self:SetNeedsFanfare(recipeID);
		end
		self:MarkDirty();
	elseif event == "BAG_UPDATE_DELAYED" then
		self:MarkDirty();
	end
end

function ProfessionsRecipeTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = C_TradeSkillUI.GetRecipeLink(GetRecipeID(block));
		if link then
			ChatEdit_InsertLink(link);
		end
	elseif mouseButton ~= "RightButton" then
		if not TradeSkillFrame then
			TradeSkillFrame_LoadUI()
		end
		if IsModifiedClick("QUESTWATCHTOGGLE") then
			local track = false;
			C_TradeSkillUI.SetRecipeTracked(GetRecipeID(block), track, IsRecraftBlock(block));
		else
			if not IsRecraftBlock(block) then
				local recipeID = GetRecipeID(block);
				if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
					C_TradeSkillUI.OpenRecipe(recipeID)
				else
					InspectRecipeFrame:Open(recipeID)
				end
			end
		end
	else
		self:ToggleDropDown(block)
	end
end

function ProfessionsRecipeTrackerMixin:InitDropDown(block)
	local index = block.index

	local info = UIDropDownMenu_CreateInfo()
	info.text = PROFESSIONS_UNTRACK_RECIPE
	info.func = function()
		local track = false
		C_TradeSkillUI.SetRecipeTracked(GetRecipeID(block), track, IsRecraftBlock(block))
	end
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

function ProfessionsRecipeTrackerMixin:LayoutContents()
--	self:AddRecipes(IsRecrafting)
	self:AddRecipes(not IsRecrafting)
end

function ProfessionsRecipeTrackerMixin:AddRecipes(isRecraft)
	for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
		if not self:AddRecipe(recipeID, isRecraft) then
			return false;
		end
	end
	return true;
end

function ProfessionsRecipeTrackerMixin:AddRecipe(recipeID, isRecraft)
	local name = C_TradeSkillUI.GetRecipeInfo(recipeID)
	local blockID = NegateIf(recipeID, isRecraft);
	local block = self:GetBlock(blockID);
	local blockName = isRecraft and PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER:format(name) or name;
	block:SetHeader(blockName);

	if not self.itemCacheCallback then
		self.itemCacheCallback = function()
			self:MarkDirty()
		end
	end

	local reagentsInfo = C_TradeSkillUI.GetRecipeReagentsInfo(recipeID)
	for reagentIndex, reagentInfo in ipairs(reagentsInfo) do
		local reagentName = C_Item.GetItemInfo(reagentInfo.itemID, false, self.itemCacheCallback, true)
		if reagentName then
			local slotIndex = reagentIndex
			local quantityRequired = reagentInfo.quantityRequired
			local quantity = GetItemCount(reagentInfo.itemID)

			local text = PROFESSIONS_TRACKER_REAGENT_FORMAT:format(PROFESSIONS_TRACKER_REAGENT_COUNT_FORMAT:format(quantity, quantityRequired), reagentName)
			local metQuantity = quantity >= quantityRequired;
			local dashStyle = metQuantity and OBJECTIVE_DASH_STYLE_HIDE or OBJECTIVE_DASH_STYLE_SHOW;
			local colorStyle = OBJECTIVE_TRACKER_COLOR[metQuantity and "Complete" or "Normal"];
			local line = block:AddObjective(slotIndex, text, nil, nil, dashStyle, colorStyle);
			line.Icon:SetShown(metQuantity);
			if metQuantity then
				line.Icon:SetAtlas("UI-QuestTracker-Tracker-Check", false);
			end
		end
	end

	return self:LayoutBlock(block);
end