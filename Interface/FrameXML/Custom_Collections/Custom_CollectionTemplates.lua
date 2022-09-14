function CollectionsButton_OnLoad(self)
	self.SlotFrameUncollectedInnerGlow:SetAtlas("collections-itemborder-uncollected-innerglow", true);
	self.NewGlow:SetAtlas("collections-newglow");
	self.SlotFrameCollected:SetAtlas("collections-itemborder-collected");
	self.SlotFrameUncollected:SetAtlas("collections-itemborder-uncollected");
	self.CooldownWrapper.SlotFavorite:SetAtlas("collections-icon-favorites", true);
end

function CollectionsButton_OnEvent(self, event, ...)
	if GameTooltip:GetOwner() == self then
		self:GetScript("OnEnter")(self);
	end

	self.updateFunction(self);
end

function CollectionsSpellButton_OnLoad(self, updateFunction)
	CollectionsButton_OnLoad(self);

	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");

	self.updateFunction = updateFunction;
end

function CollectionsSpellButton_OnShow(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");

	self.updateFunction(self);
end

function CollectionsSpellButton_OnHide(self)
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
end

function CollectionsSpellButton_UpdateCooldown(self)
	if self.spellID == -1 or self.spellID == nil then
		return;
	end

	local cooldown = self.Cooldown;
	local name, rank = GetSpellInfo(self.spellID);
	if not name or name == "" then
		cooldown:Hide();
		return;
	end

	local start, duration, enable = GetSpellCooldown(name, rank);
	if cooldown and start and duration then
		if enable then
			cooldown:Hide();
		else
			cooldown:Show();
		end
		CooldownFrame_SetTimer(cooldown, start, duration, enable);
	else
		cooldown:Hide();
	end
end

CollectionsPagingMixin = {};

function CollectionsPagingMixin:OnLoad()
	self.currentPage = 1;
	self.maxPages = 1;

	self:Update();
end

function CollectionsPagingMixin:SetMaxPages(maxPages)
	maxPages = math.max(maxPages, 1);
	if self.maxPages == maxPages then
		return;
	end
	self.maxPages = maxPages;
	if self.maxPages < self.currentPage then
		self.currentPage = self.maxPages;
	end
	self:Update();
end

function CollectionsPagingMixin:GetMaxPages()
	return self.maxPages;
end

function CollectionsPagingMixin:SetCurrentPage(page, userAction)
	page = Clamp(page, 1, self.maxPages);
	if self.currentPage ~= page then
		self.currentPage = page;
		self:Update();

		if self:GetParent().OnPageChanged then
			self:GetParent():OnPageChanged(userAction);
		end
	end
end

function CollectionsPagingMixin:GetCurrentPage()
	return self.currentPage;
end

function CollectionsPagingMixin:NextPage()
	self:SetCurrentPage(self.currentPage + 1, true);
end

function CollectionsPagingMixin:PreviousPage()
	self:SetCurrentPage(self.currentPage - 1, true);
end

function CollectionsPagingMixin:OnMouseWheel(delta)
	if delta > 0 then
		self:PreviousPage();
	else
		self:NextPage();
	end
end

function CollectionsPagingMixin:Update()
	self.PageText:SetFormattedText(COLLECTION_PAGE_NUMBER, self.currentPage, self.maxPages);
	if self.currentPage <= 1 then
		self.PrevPageButton:Disable();
	else
		self.PrevPageButton:Enable();
	end
	if self.currentPage >= self.maxPages then
		self.NextPageButton:Disable();
	else
		self.NextPageButton:Enable();
	end
end