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