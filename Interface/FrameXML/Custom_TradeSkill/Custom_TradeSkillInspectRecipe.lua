UIPanelWindows["InspectRecipeFrame"] = { area = "left", xOffset = 15, yOffset = "-10", pushable = 1, allowOtherPanels = 1, checkFit = 1, }

InspectRecipeMixin = CreateFromMixins(PortraitFrameMixin)

local InspectRecipeEvents =
{
	"BAG_UPDATE",
	"BAG_UPDATE_DELAYED",
	"TRACKED_RECIPE_UPDATE",
};

function InspectRecipeMixin:OnLoad()

end

function InspectRecipeMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, InspectRecipeEvents);
	SetParentFrameLevel(self.SchematicForm)

	self.SchematicForm.Background:SetAtlas("tradeskill-background-recipe")

	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);
end

function InspectRecipeMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, InspectRecipeEvents);

	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end

function InspectRecipeMixin:OnEvent(event, ...)
	if event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
		self.SchematicForm:Refresh();
	elseif event == "TRACKED_RECIPE_UPDATE" then
		local recipeID, added = ...
		if self.recipeID == recipeID then
			self.SchematicForm.TrackRecipeCheckbox:SetChecked(added)
		end
	end
end

function InspectRecipeMixin:Open(recipeID)
	local name, icon = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
	self:SetTitle(name)
	self:SetPortraitToAsset(icon)

	self.SchematicForm:Init(recipeID)

	ShowUIPanel(self);
end

ProfessionsRecipeSchematicFormMixin = {}

function ProfessionsRecipeSchematicFormMixin:OnLoad()
	local function PoolReset(pool, slot)
		slot:Reset();
		FramePool_HideAndClearAnchors(pool, slot);
	end

	self.reagentSlotPool = CreateFramePool("FRAME", self, "ProfessionsReagentSlotTemplate", PoolReset);
	self.reagentSlots = {}
end

function ProfessionsRecipeSchematicFormMixin:Init(recipeID)
	self.recipeID = recipeID

	self.OutputIcon:SetRecipe(recipeID)
	self.TrackRecipeCheckbox:SetChecked(C_TradeSkillUI.IsRecipeTracked(recipeID))

	self.reagentSlotPool:ReleaseAll()
	table.wipe(self.reagentSlots)

	local reagentsInfo = C_TradeSkillUI.GetRecipeReagentsInfo(recipeID)
	for reagentIndex, reagentInfo in ipairs(reagentsInfo) do
		local slot = self.reagentSlotPool:Acquire()
		table.insert(self.reagentSlots, slot)

		slot:SetID(reagentIndex)

		if reagentIndex == 1 then
			slot:SetPoint("TOPLEFT", self.Reagents, "TOPLEFT", 0, -25)
		elseif reagentIndex % 2 == 1 then
			slot:SetPoint("TOPLEFT", self.reagentSlots[reagentIndex - 2], "BOTTOMLEFT", 0, -8)
		else
			slot:SetPoint("TOPLEFT", self.reagentSlots[reagentIndex - 1], "TOPRIGHT", 3, 0)
		end

		slot:SetReagentInfo(reagentInfo)
		slot:Show()
	end
end

function ProfessionsRecipeSchematicFormMixin:Refresh()
	for index, slot in ipairs(self.reagentSlots) do
		slot:UpdateItemInfo()
	end
end

function ProfessionsRecipeSchematicFormMixin:OnTrackRecipeClicked(button)
	local success
	if self.recipeID then
		local isTracked = C_TradeSkillUI.IsRecipeTracked(self.recipeID)
		success = C_TradeSkillUI.SetRecipeTracked(self.recipeID, not isTracked)
	end
	if not success then
		self.TrackRecipeCheckbox:SetChecked(false)
	end
end

ProfessionsRecipeOutputIconMixin = {}

function ProfessionsRecipeOutputIconMixin:OnLoad()
	self.CountShadow:SetAtlas("BattleBar-SwapPetShadow")

	self.itemCacheCallback = function(itemID)
		if self.itemID == itemID then
			self:UpdateOutputInfo()
		end
	end

	self.UpdateTooltip = self.OnEnter
end

function ProfessionsRecipeOutputIconMixin:OnEnter()
	if self.link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end
end

function ProfessionsRecipeOutputIconMixin:OnLeave()
	GameTooltip:Hide()
end

function ProfessionsRecipeOutputIconMixin:OnClick(button)
	if self.link then
		HandleModifiedItemClick(self.link)
	end
end

function ProfessionsRecipeOutputIconMixin:Reset()
	self.link = nil
	self.itemID = nil
	self.spellID = nil
	self.craftedType = nil
end

function ProfessionsRecipeOutputIconMixin:SetRecipe(recipeID)
	self:Reset()

	local recipeName, craftedType, craftedID, quantityMin, quantityMax = C_TradeSkillUI.GetRecipeInfo(recipeID)

	if craftedType == "spell" then
		self.spellID = craftedID
	else
		self.itemID = craftedID
	end
	self.craftedType = craftedType

	self:UpdateOutputInfo()

	if quantityMax > 1 then
		if quantityMin == quantityMax then
			self.Count:SetText(quantityMin);
		else
			self.Count:SetFormattedText("%d-%d", quantityMin, quantityMax);
		end
		local magicWidth = 39;
		if self.Count:GetWidth() > magicWidth then
			self.Count:SetFormattedText("~%d", math.floor(Lerp(quantityMin, quantityMax, .5)));
		end
		self.CountShadow:Show();
	else
		self.Count:SetText("");
		self.CountShadow:Hide();
	end
end

function ProfessionsRecipeOutputIconMixin:UpdateOutputInfo()
	local name, icon, quality, link

	if self.craftedType == "item" then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = C_Item.GetItemInfo(self.itemID, false, self.itemCacheCallback, true)
		if itemName then
			name = itemName
			icon = itemTexture
			quality = itemRarity
			link = itemLink
		else
			icon = select(5, GetItemInfoInstant(self.itemID))
			quality = Enum.ItemQuality.Common
		end
	elseif self.craftedType == "spell" then
		local spellName, subSpellName, texture, cost, isFunnel, powerType, castTime, minRage, maxRange = GetSpellInfo(self.spellID)
		name = spellName
		icon = texture
		quality = Enum.ItemQuality.Common
		link = C_TradeSkillUI.GetRecipeLink(self.spellID)
	end

	local text = WrapTextInColor(name or UNKNOWN, ITEM_QUALITY_COLORS[quality or Enum.ItemQuality.Common].color)
	self.Text:SetText(text)

	SetPortraitToTexture(self.Icon, icon or "Interface/Icons/INV_Misc_QuestionMark")
	SetItemButtonQuality(self, quality or Enum.ItemQuality.Common);

	self.link = link
end

ProfessionsReagentSlotMixin = {}

function ProfessionsReagentSlotMixin:OnLoad()
	self.itemCacheCallback = function(itemID)
		if self.itemID == itemID then
			self:UpdateItemInfo()
		end
	end

	self.Button.UpdateTooltip = self.OnButtonEnter
end

function ProfessionsReagentSlotMixin:OnButtonEnter()
	if self.itemLink then
		GameTooltip:SetOwner(self.Button, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end
end

function ProfessionsReagentSlotMixin:OnButtonLeave()
	GameTooltip:Hide()
end

function ProfessionsReagentSlotMixin:OnButtonClick(button)
	if self.itemLink then
		HandleModifiedItemClick(self.itemLink)
	end
end

function ProfessionsReagentSlotMixin:Reset()
	self.itemLink = nil
	self.itemID = nil
	self.reagentInfo = nil
end

function ProfessionsReagentSlotMixin:SetReagentInfo(reagentInfo)
	self.reagentInfo = reagentInfo
	self:UpdateItemInfo()
end

function ProfessionsReagentSlotMixin:UpdateItemInfo()
	if not self.reagentInfo then
		return
	end

	self.itemID = self.reagentInfo.itemID

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, vendorPrice = C_Item.GetItemInfo(self.reagentInfo.itemID, false, self.itemCacheCallback, true)
	if itemName then
		local quantityRequired = self.reagentInfo.quantityRequired
		local quantity = GetItemCount(self.reagentInfo.itemID)

		local metQuantity = quantity >= quantityRequired
		local color = metQuantity and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR
		local quantityText = TRADESKILL_REAGENT_COUNT:format(quantity, quantityRequired);

		self.Name:SetText(("%s %s"):format(quantityText, itemName))
		self.Name:SetTextColor(color:GetRGB())
		self.Button.icon:SetTexture(itemTexture)
		SetItemButtonQuality(self.Button, itemRarity or Enum.ItemQuality.Common);

		self.itemLink = itemLink
	end
end