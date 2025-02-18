ServerNewsDataFeedMixin = {}

function ServerNewsDataFeedMixin:OnLoad()
	self.Background:SetAtlas("parchmentpopup-background", true)

	self.TopLeftCorner:SetAtlas("parchmentpopup-topleft")
	self.TopRightCorner:SetAtlas("parchmentpopup-topright")
	self.BottomLeftCorner:SetAtlas("parchmentpopup-bottomleft")
	self.BottomRightCorner:SetAtlas("parchmentpopup-bottomright")

	self.TopBorder:SetAtlas("parchmentpopup-top")
	self.BottomBorder:SetAtlas("parchmentpopup-bottom")
	self.LeftBorder:SetAtlas("parchmentpopup-left")
	self.RightBorder:SetAtlas("parchmentpopup-right")

	self.entryFrames = {}
	self.entrySectionStates = {}

	self.entrySectionPool = CreateFramePool("Frame", self, "ServerNewsEntrySectionTemplate", function(framePool, frame)
		FramePool_HideAndClearAnchors(framePool, frame)
	end)

	self.onlyNewEntries = self:GetAttribute("OnlyNewEntries")
	self.initialUpdate = true

	local id = self:GetID()
	if id > 0 then
		self:SetDataFeedType(self:GetID())
	end

	self:RegisterCustomEvent("SERVER_NEWS_UPDATE")
end

function ServerNewsDataFeedMixin:OnEvent(event, ...)
	if event == "SERVER_NEWS_UPDATE" then
		if self.dataFeedType then
			self.dirty = true
			self:UpdateFeed()
		end
	end
end

function ServerNewsDataFeedMixin:OnShow()
	SetParentFrameLevel(self.Title, 7)
	self:UpdateFeed()
	C_ServerNews.MarkEntriesSeen()
end

function ServerNewsDataFeedMixin:SetDataFeedType(dataFeedType)
	if self.dataFeedType == dataFeedType then
		return
	end

	if dataFeedType == 1 then
		self.Title.Text:SetText(SERVER_NEWS_ANNONCES)
		self.Title:Show()
	elseif dataFeedType == 2 then
		self.Title.Text:SetText(SERVER_NEWS_CHANGES)
		self.Title:Show()
	else
		self.Title:Hide()
	end

	self.dataFeedType = dataFeedType
	self.dirty = true
	self:UpdateFeed()
end

function ServerNewsDataFeedMixin:GetDataFeedType()
	return self.dataFeedType
end

function ServerNewsDataFeedMixin:ClearDataFeed()
	for entryIndex = 1, #self.entryFrames do
		self.entryFrames[entryIndex]:Hide()
	end
end

local CONTENT_OFFSET = 5
local ENTRY_PADDING = 5

function ServerNewsDataFeedMixin:UpdateFeed()
	if not self.dataFeedType or not self.dirty or not self:IsVisible() or not C_ServerNews.CanViewNews() then
		return
	end

	self.entrySectionPool:ReleaseAll()

	local isInitialUpdate = self.initialUpdate
	self.initialUpdate = nil

	local _, _, feedWidth, feedlHeight = self.ScrollFrame:GetRect()
	self.ScrollFrame.ScrollChild:SetWidth(Round(feedWidth - 16))

	local _, _, feedScrollWidth, feedScrollHeight = self.ScrollFrame.ScrollChild:GetRect()

	local messageIDs = {}
	local entryWidth = Round(feedScrollWidth - ENTRY_PADDING * 3)

	local seenTimestamp = self.onlyNewEntries and C_ServerNews.GetLastSeenTimestamp() or 0
	local numEntries = C_ServerNews.GetNumEntriesForDataFeedType(self.dataFeedType, seenTimestamp)

	for entryIndex = 1, numEntries do
		local entry = self.entryFrames[entryIndex]
		if not entry then
			entry = CreateFrame("Frame", string.format("$parentEntry%i", entryIndex), self, "ServerNewsEntryTemplate")
			entry:SetID(entryIndex)
			entry:SetOwner(self)
			entry:SetParent(self.ScrollFrame.ScrollChild)
			self.entryFrames[entryIndex] = entry
		end

		local entryHeight = 0
		local hasEmbed

		local entryData = C_ServerNews.GetEntryForDataFeedType(self.dataFeedType, entryIndex, seenTimestamp)

		entry.messageID = entryData.id
		entry.TextContent:SetText(entryData.content)

		if entryData.editedTimestamp then
			if entryData.editedTimestampRelative then
				entry.Timestamp.Text:SetText(entryData.editedTimestampRelative)
				entry.Timestamp.tooltipTitle = entryData.editedTimestamp
			else
				entry.Timestamp.Text:SetText(entryData.editedTimestamp)
				entry.Timestamp.tooltipTitle = nil
			end
			entry.UpdateIndicator:Show()
			entry.UpdateIndicator.tooltipTitle = SERVER_NEWS_ENTRY_UPDATE_TOOLTIP_1
			entry.UpdateIndicator.tooltipText = string.format(SERVER_NEWS_ENTRY_UPDATE_TOOLTIP_2, entryData.createdTimestamp)
		else
			if entryData.createdTimestampRelative then
				entry.Timestamp.Text:SetText(entryData.createdTimestampRelative)
				entry.Timestamp.tooltipTitle = entryData.createdTimestamp
			else
				entry.Timestamp.Text:SetText(entryData.createdTimestamp)
				entry.Timestamp.tooltipTitle = nil
			end
			entry.UpdateIndicator:Hide()
			entry.UpdateIndicator.tooltipTitle = nil
			entry.UpdateIndicator.tooltipText = nil
		end

		entry:SetWidth(entryWidth)
		entry.TextContent:SetWidth(entryWidth)
		entry.Timestamp:SetSize(entry.Timestamp.Text:GetStringWidth(), entry.Timestamp.Text:GetHeight())

		if entryIndex == 1 then
			entry:SetPoint("TOPLEFT", ENTRY_PADDING, -ENTRY_PADDING - 15)
		else
			entry:SetPoint("TOPLEFT", self.entryFrames[entryIndex - 1], "BOTTOMLEFT", 0, -ENTRY_PADDING)
			entryHeight = entryHeight + CONTENT_OFFSET
		end

		if type(entryData.embeds) == "table" then
			local numEmbeds = #entryData.embeds
			local lastSection

			hasEmbed = numEmbeds > 0

			for embedIndex, embed in ipairs(entryData.embeds) do
				local section = self.entrySectionPool:Acquire()
				section:SetID(embedIndex)
				section:SetOwner(entry)
				section:SetParent(entry)
				section:SetWidth(entryWidth - 20)
				section:Show()

				if embedIndex == 1 then
					section:SetPoint("TOPLEFT", entry.TextContent, "BOTTOMLEFT", 5, -10)
					entryHeight = entryHeight + 10
				else
					section:SetPoint("TOPLEFT", lastSection, "BOTTOMLEFT", 0, -5)
					entryHeight = entryHeight + 5
				end

				section.HeaderButton.Title:SetText(embed.title)
				section.Description:SetText(embed.description)
				section.Description:SetWidth(entryWidth - 40)
				section.url = embed.url

				local sectionState = self.entrySectionStates[entryData.id] and self.entrySectionStates[entryData.id][embedIndex]
				if sectionState == 1 then
					section:SetExpanded(true, true)
				elseif sectionState == 0 then
					section:SetExpanded(false, true)
				else
					local expanded = isInitialUpdate and numEmbeds == 1 or false
					section:SetExpanded(expanded, true)
					self:SetMessageSectionState(entryData.id, embedIndex, expanded)
				end

				entryHeight = entryHeight + section:GetHeight()

				lastSection = section
			end
		end

		entryHeight = entryHeight + entry.Timestamp:GetHeight() + 5 + entry.TextContent:GetHeight() + ENTRY_PADDING * 2

		entry.Separator:SetShown(entryIndex < numEntries and not hasEmbed)
		entry:SetHeight(math.ceil(entryHeight))
		entry:Show()

		messageIDs[entryData.id] = true
	end

	local lastEntry = self.entryFrames[numEntries]
	if lastEntry then
		self.ScrollFrame.ScrollChild.Spacer:SetPoint("TOPLEFT", lastEntry, "BOTTOMLEFT", 0, -15)
		self.ScrollFrame.ScrollChild.Spacer:Show()
	else
		self.ScrollFrame.ScrollChild.Spacer:Hide()
	end

	for entryIndex = numEntries + 1, #self.entryFrames do
		self.entryFrames[entryIndex]:Hide()
	end

	for messageID in pairs(self.entrySectionStates) do
		if not messageIDs[messageID] then
			self.entrySectionStates[messageID] = nil
		end
	end

	self.dirty = nil
end

function ServerNewsDataFeedMixin:SetMessageSectionState(messageID, sectionIndex, state)
	local entryStateData = self.entrySectionStates[messageID]
	if not entryStateData then
		entryStateData = {}
		self.entrySectionStates[messageID] = entryStateData
	end
	if state ~= nil then
		state = state and 1 or 0
	end
	entryStateData[sectionIndex] = state
end

ServerNewsEntryMixin = CreateFromMixins(PKBT_OwnerMixin)

function ServerNewsEntryMixin:OnLoad()
	self.TopLeftFiligree:SetAtlas("parchmentpopup-filigree")
	self.TopRightFiligree:SetAtlas("parchmentpopup-filigree")
	self.TopRightFiligree:SetSubTexCoord(1, 0, 0, 1)
	self.Separator:SetAtlas("UI-PaperOverlay-AbilityTextBottomBorder")
	self.UpdateIndicator.Icon:SetAtlas("PKBT-Icon-Notification-White")
end

function ServerNewsEntryMixin:GetDataFeedType()
	return self:GetOwner():GetDataFeedType()
end

function ServerNewsEntryMixin:OnShow()

end

function ServerNewsEntryMixin:SetSectionState(sectionIndex, state, updateFeed)
	local feed = self:GetOwner()
	feed:SetMessageSectionState(self.messageID, sectionIndex, state)

	if updateFeed then
		feed.dirty = true
		feed:UpdateFeed()
	end
end

function ServerNewsEntryMixin:OnHyperlinkClick(this, link, text, button)
	if button ~= "LeftButton" then return end

	local linkType, linkData = string.split(":", link, 2)
	if linkType == "url" then
		StaticPopup_Show("EXTERNAL_URL_POPUP", nil, nil, linkData)
	else
		GMError(string.format("[SERVER_NEWS] Unknown hyperlink type [%s] for link \"%s\"", tostring(linkType), tostring(linkData)))
	end
end

function ServerNewsEntryMixin:ShowHyperlinkTooltip(this, link, data, isHyperlink)
	if not data then
		GMError(string.format("[SERVER_NEWS] No link data for \"%s\"", link), 2)
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 10, 10)
	if isHyperlink then
		GameTooltip:SetHyperlink(data)
	else
		GameTooltip:AddLine(data, 1, 1, 1)
	end
	GameTooltip:Show()
end

function ServerNewsEntryMixin:OnHyperlinkEnter(this, link, text)
	local linkType, linkData = string.split(":", link, 2)
	if linkType == "url" then
		self:ShowHyperlinkTooltip(this, link, linkData, false)
		SetCursor("Interface/Cursor/Cast")
	end
end

function ServerNewsEntryMixin:OnHyperlinkLeave(this, link, text)
	ResetCursor()
	GameTooltip:Hide()
end

ServerNewsEntrySectionMixin = CreateFromMixins(PKBT_OwnerMixin)

function ServerNewsEntrySectionMixin:OnLoad()
	self.expanded = true
	self.DescriptionBG:SetPoint("TOPLEFT", self.Description, -9, 12)
	self.DescriptionBG:SetPoint("BOTTOMRIGHT", self.Description, 9, -11)
end

function ServerNewsEntrySectionMixin:GetDataFeedType()
	return self:GetOwner():GetDataFeedType()
end

function ServerNewsEntrySectionMixin:OnShow()

end

function ServerNewsEntrySectionMixin:IsExpanded()
	return not not self.expanded
end

function ServerNewsEntrySectionMixin:OnHyperlinkClick(this, link, text, button)
	self:GetOwner():OnHyperlinkClick(this, link, text, button)
end

function ServerNewsEntrySectionMixin:OnHyperlinkEnter(this, link, text)
	self:GetOwner():OnHyperlinkEnter(this, link, text)
end

function ServerNewsEntrySectionMixin:OnHyperlinkLeave(this, link, text)
	self:GetOwner():OnHyperlinkLeave(this, link, text)
end

function ServerNewsEntrySectionMixin:SetExpanded(expanded, forceSet)
	expanded = not not expanded
	if not forceSet and self:IsExpanded() == expanded then
		return
	end

	self.expanded = expanded

	if expanded then
		self.HeaderButton.ExpandedIcon:SetText("-")
		self.Description:Show()
		self.DescriptionBG:Show()
		self.DescriptionBGBottom:Show()
		self:SetHeight(self.HeaderButton:GetHeight() + 19 + self.Description:GetHeight())
	else
		self.HeaderButton.ExpandedIcon:SetText("+")
		self.Description:Hide()
		self.DescriptionBG:Hide()
		self.DescriptionBGBottom:Hide()
		self:SetHeight(self.HeaderButton:GetHeight())
	end

	self:UpdateHeaderButtonTextures()

	if not forceSet then
		self:GetOwner():SetSectionState(self:GetID(), expanded, true)
	end
end

function ServerNewsEntrySectionMixin:UpdateHeaderButtonTextures()
	self.HeaderButton:GetScript("OnShow")(self.HeaderButton)
end

ServerNewsFrameMixin = CreateFromMixins(PKBT_OwnerMixin)

function ServerNewsFrameMixin:OnLoad()
	self.dataFeeds = {
		[1] = self.ServerAnnounces,
		[2] = self.ServerChanges,
	}

	self:RegisterCustomEvent("SERVER_NEWS_UPDATE")
end

function ServerNewsFrameMixin:OnEvent(event, ...)
	if event == "SERVER_NEWS_UPDATE" then
		if C_ServerNews.CanViewNews() and C_ServerNews.HasAnyNewEntries() and C_ServerNews.IsAnyDataFeedAvailable() then
			ShowUIPanel(self)
		else
			HideUIPanel(self)
		end
	end
end

function ServerNewsFrameMixin:OnShow()
	self:UpdateFeeds()
	C_ServerNews.MarkEntriesSeen()
end

function ServerNewsFrameMixin:UpdateFeeds()
	local width = 0
	local lastFeed

	for index, dataFeed in ipairs(self.dataFeeds) do
		if C_ServerNews.IsDataFeedAvailable(dataFeed:GetID()) then
			if lastFeed then
				dataFeed:SetPoint("TOPLEFT", lastFeed, "TOPRIGHT", -15, 0)
				width = width - 15
			else
				dataFeed:SetPoint("TOPLEFT", 0, 0)
			end
			dataFeed:Show()

			width = width + dataFeed:GetWidth()
			lastFeed = dataFeed
		else
			dataFeed:Hide()
		end
	end

	self:SetWidth(width)
end

ServerNewsPanelMixin = {}

function ServerNewsPanelMixin:OnLoad()
	self.onlyNewEntries = self.DataFeed:GetAttribute("OnlyNewEntries")
	self.checkNewTimestamps = false

	local id = self:GetID()
	if id > 0 then
		self:SetDataFeedType(id)
	end
end

function ServerNewsPanelMixin:OnEvent(event, ...)
	if event == "SERVER_NEWS_UPDATE" then
		self:UpdateState()
	end
end

function ServerNewsPanelMixin:SetDataFeedType(dataFeedType)
	if self.dataFeedType == dataFeedType then
		return
	end

	self.dataFeedType = dataFeedType
	self:RegisterCustomEvent("SERVER_NEWS_UPDATE")

	self:UpdateState()
	self.DataFeed:SetDataFeedType(dataFeedType)
end

function ServerNewsPanelMixin:GetListSeenTimestamp()
	if self.onlyNewEntries then
		return C_ServerNews.GetLastSeenTimestamp()
	end
	return 0
end

function ServerNewsPanelMixin:UpdateState()
	if self.dataFeedType
	and C_ServerNews.CanViewNews()
	and C_ServerNews.HasAnyNewEntries(self.checkNewTimestamps)
	and C_ServerNews.IsDataFeedAvailable(self.dataFeedType)
	and C_ServerNews.GetNumEntriesForDataFeedType(self.dataFeedType, self:GetListSeenTimestamp()) > 0
	then
		self.checkNewTimestamps = false
		self:Show()
	else
		self:Hide()
	end
end

function ServerNewsPanelMixin:Close()
	self.checkNewTimestamps = true
	self:Hide()
end