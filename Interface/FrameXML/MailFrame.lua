MailMixIn = {}

MAIL_MAX_COUNT = 50
INBOXITEMS_TO_DISPLAY = 12
STATIONERY_ICON_ROW_HEIGHT = 36
STATIONERYITEMS_TO_DISPLAY = 5
PACKAGEITEMS_TO_DISPLAY = 4
ATTACHMENTS_MAX = 16
ATTACHMENTS_MAX_SEND = 12
ATTACHMENTS_PER_ROW_SEND = 7
ATTACHMENTS_MAX_ROWS_SEND = 2
ATTACHMENTS_MAX_RECEIVE = 16
ATTACHMENTS_PER_ROW_RECEIVE = 7
ATTACHMENTS_MAX_ROWS_RECEIVE = 3
STATIONERY_PATH = "Interface\\Stationery\\"
MAX_COD_AMOUNT = 10000
SEND_MAIL_TAB_LIST = {}
SEND_MAIL_TAB_LIST[1] = "SendMailNameEditBox"
SEND_MAIL_TAB_LIST[2] = "SendMailSubjectEditBox"
SEND_MAIL_TAB_LIST[3] = "SendMailBodyEditBox"
SEND_MAIL_TAB_LIST[4] = "SendMailMoneyGold"
SEND_MAIL_TAB_LIST[5] = "SendMailMoneyCopper"

function MailFrame_OnLoad(self)
	Mixin(self, MailMixIn, PortraitFrameMixin)

	self.maxTabWidth = 128

	-- Init pagenum
	InboxFrame.pageNum = 1
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 2)
	PanelTemplates_SetTab(self, 1)
	PanelTemplates_ResizeTabsToFit(self, 300)
	-- Register for events
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_INBOX_UPDATE")
	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("MAIL_SEND_INFO_UPDATE")
	self:RegisterEvent("MAIL_SEND_SUCCESS")
	self:RegisterEvent("MAIL_FAILED")
	self:RegisterEvent("MAIL_SUCCESS")
	self:RegisterEvent("CLOSE_INBOX_ITEM")
	self:RegisterEvent("MAIL_LOCK_SEND_ITEMS")
	self:RegisterEvent("MAIL_UNLOCK_SEND_ITEMS")
	-- Set previous and next fields
	MoneyInputFrame_SetPreviousFocus(SendMailMoney, SendMailBodyEditBox)
	MoneyInputFrame_SetNextFocus(SendMailMoney, SendMailNameEditBox)

	self.Inset:Hide()
	self.Inset:SetPoint("TOPLEFT", 4, -80)
end

function MailFrame_OnEvent(self, event, ...)
	if ( event == "MAIL_SHOW" ) then
		ShowUIPanel(MailFrame)
		if ( not MailFrame:IsShown() ) then
			CloseMail()
			return
		end

		-- Update the roster so auto-completion works
		if ( IsInGuild() and GetNumGuildMembers() == 0 ) then
			GuildRoster()
		end

		local numItems, totalItems = GetInboxNumItems()
		OpenAllMailButton:SetEnabled(not OpenAllMailButton.workState and numItems > 0)
		AdditionalMailFunctionalButton:SetEnabled(not OpenAllMailButton.workState and numItems > 0)

		OpenBackpack()
		SendMailFrame_Update()
		MailFrameTab_OnClick(nil, 1)
		CheckInbox()
		UpdateInboxToMuchMail()
	elseif ( event == "MAIL_INBOX_UPDATE" ) then
		InboxFrame_Update()
		OpenMail_Update()
	elseif ( event == "MAIL_SEND_INFO_UPDATE" ) then
		SendMailFrame_Update()
	elseif ( event == "MAIL_SEND_SUCCESS" ) then
		SendMailFrame_Reset()
		PlaySound("igAbiliityPageTurn")
		-- If open mail frame is open then switch the mail frame back to the inbox
		if ( SendMailFrame.sendMode == "reply" ) then
			MailFrameTab_OnClick(nil, 1)
		end
	elseif ( event == "MAIL_FAILED" ) then
		SendMailMailButton:Enable()
	elseif ( event == "MAIL_SUCCESS" ) then
		SendMailMailButton:Enable()
		if ( InboxNextPageButton:IsEnabled() ~= 0 ) then
			InboxGetMoreMail()
		end

		local numItems, totalItems = GetInboxNumItems()
		OpenAllMailButton:SetEnabled(not OpenAllMailButton.workState and numItems > 0)
		AdditionalMailFunctionalButton:SetEnabled(not OpenAllMailButton.workState and numItems > 0)
	elseif ( event == "MAIL_CLOSED" ) then
		HideUIPanel(MailFrame)
		StaticPopup_Hide("CONFIRM_MAIL_ITEM_UNREFUNDABLE")
	elseif ( event == "CLOSE_INBOX_ITEM" ) then
		local arg1 = ...
		if ( arg1 == InboxFrame.openMailID ) then
			HideUIPanel(OpenMailFrame)
		end
	elseif ( event == "MAIL_LOCK_SEND_ITEMS" ) then
		local slotNum, itemLink = ...
		SendMailFrameLockSendMail:Show()
		itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink)
		local r, g, b = GetItemQualityColor(itemRarity)
		StaticPopup_Show("CONFIRM_MAIL_ITEM_UNREFUNDABLE", nil, nil, {["texture"] = itemTexture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["slot"] = slotNum})
	elseif ( event == "MAIL_UNLOCK_SEND_ITEMS") then
		SendMailFrameLockSendMail:Hide()
		StaticPopup_Hide("CONFIRM_MAIL_ITEM_UNREFUNDABLE")
	end
end

function MailFrameTab_OnClick(self, tabID)
	if ( not tabID ) then
		tabID = self:GetID()
	end
	PanelTemplates_SetTab(MailFrame, tabID)
	if ( tabID == 1 ) then
		MailFrame:SetWidth(666)
		MailFrame.Inset:Hide()
		PortraitFrameTemplate_SetTitle(MailFrame, INBOX)
		UpdateUIPanelPositions(MailFrame)

		-- Inbox tab clicked
		InboxFrame:Show()
		SendMailFrame:Hide()
		SetSendMailShowing(false)
	else
		MailFrame:SetWidth(338)
		MailFrame.Inset:Show()
		PortraitFrameTemplate_SetTitle(MailFrame, SENDMAIL)
		UpdateUIPanelPositions(MailFrame)

		-- Sendmail tab clicked
		InboxFrame:Hide()
		SendMailFrame:Show()
		SendMailFrame_Update()
		SetSendMailShowing(true)

		-- Set the send mode to dictate the flow after a mail is sent
		SendMailFrame.sendMode = "send"
	end
	PlaySound("igSpellBookOpen")
end

-- Inbox functions

local realmColors = {
	[E_REALM_ID.SIRUS] = CreateColor(0.87, 0.19, 0.2),
	[E_REALM_ID.SCOURGE] = CreateColor(0.73, 0.5, 0.88),
	[E_REALM_ID.FROSTMOURNE] = CreateColor(0.45, 0.56, 1)
}

function InboxFrame_Update()
	local numItems, totalItems = GetInboxNumItems()
	local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1
	local icon, button, expireTime, senderText, subjectText, buttonIcon

	OpenAllMailButton:SetEnabled(not OpenAllMailButton.workState and numItems > 0)
	AdditionalMailFunctionalButton:SetEnabled(not OpenAllMailButton.workState and numItems > 0)

	if ( totalItems > MAIL_MAX_COUNT ) then
		if ( not InboxFrame.maxShownMails ) then
			InboxFrame.maxShownMails = numItems
		end
		InboxFrame.overflowMails = totalItems - numItems
		InboxFrame.shownMails = numItems
	else
		InboxFrame.overflowMails = nil
	end

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local messageFrame = _G["MailItem"..i]

		if not messageFrame then
			return
		end

		if index <= numItems then
			local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, x, y, z, isGM, firstItemQuantity = GetInboxHeaderInfo(index)
			local isServerMessage

			if sender and sender == UnitName("player") then
				local bodyText = GetInboxText(index)
				local itemEntry, itemCount, resoult, money, sellerName = strsplit(":", bodyText)
				local itemName = GetItemInfo(itemEntry) or UNKNOWN

				subject = string.format(tonumber(resoult) == 3 and MAIL_AUCTION_WIN or MAIL_AUCTION_OUTBID, itemName)
				sender = MAIL_BLACK_MARKET
			end

			if isGM then
				isServerMessage = true
			end

			if isServerMessage then
				local color = realmColors[GetServerID()] or realmColors[E_REALM_ID.SCOURGE]

				messageFrame.Background:SetAtlas("TalkingHeads-Server-TextBackground")
				messageFrame.Background:SetVertexColor(color.r, color.g, color.b)

				messageFrame.ServerCornerTexture:Show()
			else
				messageFrame.Background:SetAtlas("TalkingHeads-Neutral2-TextBackground")
				messageFrame.Background:SetVertexColor(1, 1, 1)

				messageFrame.ServerCornerTexture:Hide()
			end

			messageFrame.Button.index = index
			messageFrame.Button.hasItem = itemCount
			messageFrame.Button.itemCount = itemCount

			messageFrame.Button.Icon:SetTexture(packageIcon or stationeryIcon)
			SetItemButtonCount(messageFrame.Button, firstItemQuantity)

			messageFrame.Sender:SetText(sender or UNKNOWN)
			messageFrame.Subject:SetText(subject)

			messageFrame.BackgroundOverlay:SetShown(wasRead)
			SetDesaturation(messageFrame.Button.Icon, wasRead)

			if CODAmount and CODAmount > 0 then
				messageFrame.Button.cod = CODAmount
			else
				messageFrame.Button.cod = nil
			end

			messageFrame.CODTexture:SetShown(CODAmount and CODAmount > 0)

			if money and money > 0 then
				messageFrame.Button.money = money
			else
				messageFrame.Button.money = nil
			end

			if InboxFrame.openMailID == index then
				messageFrame.Button:SetChecked(1)
				SetPortraitToTexture(OpenMailFrame.portrait, packageIcon or stationeryIcon)
			else
				messageFrame.Button:SetChecked(nil)
			end

			if daysLeft and daysLeft >= 1 then
				daysLeft = GREEN_FONT_COLOR:WrapTextInColorCode(string.format(DAYS_ABBR, floor(daysLeft)))
			else
				daysLeft = RED_FONT_COLOR:WrapTextInColorCode(SecondsToTime(floor(daysLeft * 24 * 60 * 60)))
			end

			messageFrame.ExpireTime:SetText(daysLeft)
			messageFrame.ExpireTime:SetWidth(messageFrame.ExpireTime:GetTextWidth())

			if InboxItemCanDelete(index) then
				messageFrame.ExpireTime.tooltip = TIME_UNTIL_DELETED
			else
				messageFrame.ExpireTime.tooltip = TIME_UNTIL_RETURNED
			end

			messageFrame:Show()
		else
			messageFrame:Hide()
		end
		index = index + 1
	end

	-- Handle page arrows
	if ( InboxFrame.pageNum == 1 ) then
		InboxPrevPageButton:Disable()
	else
		InboxPrevPageButton:Enable()
	end
	if ( (InboxFrame.pageNum * INBOXITEMS_TO_DISPLAY) < numItems ) then
		InboxNextPageButton:Enable()
	else
		InboxNextPageButton:Disable()
	end
	UpdateInboxToMuchMail()
end

function UpdateInboxToMuchMail()
	local numItems, totalItems = GetInboxNumItems()
	if ( totalItems > MAIL_MAX_COUNT ) then
		InboxTooMuchMail:Show()
	else
		InboxTooMuchMail:Hide()
	end
end

function InboxFrame_OnClick(self, index)
	if ( self:GetChecked() ) then
		InboxFrame.openMailID = index
		OpenMailFrame.updateButtonPositions = true
		OpenMail_Update()
		--OpenMailFrame:Show()
		ShowUIPanel(OpenMailFrame)
		OpenMailFrameInset:SetPoint("TOPLEFT", 4, -80)
		PlaySound("igSpellBookOpen")
	else
		CloseOpenMailFrame()
	end
	InboxFrame_Update()
end

function CloseOpenMailFrame()
	InboxFrame.openMailID = 0
	HideUIPanel(OpenMailFrame)
end

function InboxFrame_OnModifiedClick(self, index)
	local _, _, _, _, _, cod = GetInboxHeaderInfo(index)
	if ( cod <= 0 ) then
		AutoLootMailItem(index)
	end
	InboxFrame_OnClick(self, index)
end

function InboxFrameItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if ( self.hasItem ) then
		if ( self.itemCount == 1) then
			GameTooltip:SetInboxItem(self.index)
		else
			GameTooltip:AddLine(MAIL_MULTIPLE_ITEMS.." ("..self.itemCount..")")
		end
	end
	if (self.money) then
		if ( self.hasItem ) then
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(ENCLOSED_MONEY, "", 1, 1, 1)
		SetTooltipMoney(GameTooltip, self.money)
		SetMoneyFrameColor("GameTooltipMoneyFrame1", "white")
	elseif (self.cod) then
		if ( self.hasItem ) then
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(COD_AMOUNT, "", 1, 1, 1)
		SetTooltipMoney(GameTooltip, self.cod)
		if ( self.cod > GetMoney() ) then
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "red")
		else
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "white")
		end
	end
	GameTooltip:Show()
end

function InboxNextPage()
	PlaySound("igMainMenuOptionCheckBoxOn")
	InboxFrame.pageNum = InboxFrame.pageNum + 1
	InboxGetMoreMail()
	InboxFrame_Update()
end

function InboxPrevPage()
	PlaySound("igMainMenuOptionCheckBoxOn")
	InboxFrame.pageNum = InboxFrame.pageNum - 1
	InboxGetMoreMail()
	InboxFrame_Update()
end

function InboxGetMoreMail()
	-- Игроку и так будет показана почта которая пришла. Нет нужды обновлять это при открытом окне.
	-- Убрано по просьбе Игоря.

	if true then
		return
	end
	-- get more mails if there is an overflow and less than max are being shown
	if ( InboxFrame.overflowMails and InboxFrame.shownMails < InboxFrame.maxShownMails ) then
		CheckInbox()
	end
end

-- Open Mail functions

function OpenMailFrame_OnHide()
	StaticPopup_Hide("DELETE_MAIL")
	if ( not InboxFrame.openMailID ) then
		InboxFrame_Update()
		PlaySound("igSpellBookClose")
		return
	end

	-- Determine if this is an auction temp invoice
	local bodyText, texture, isTakeable, isInvoice = GetInboxText(InboxFrame.openMailID)
	local isAuctionTempInvoice = false
	if ( isInvoice ) then
		local invoiceType, itemName, playerName, bid, buyout, deposit, consignment, moneyDelay, etaHour, etaMin = GetInboxInvoiceInfo(InboxFrame.openMailID)
		if (invoiceType == "seller_temp_invoice") then
			isAuctionTempInvoice = true
		end
	end

	-- If mail contains no items, then delete it on close
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated  = GetInboxHeaderInfo(InboxFrame.openMailID)
	if ( money == 0 and not itemCount and textCreated and not isAuctionTempInvoice ) then
		DeleteInboxItem(InboxFrame.openMailID)
	end
	InboxFrame.openMailID = 0
	InboxFrame_Update()
	PlaySound("igSpellBookClose")
end

function OpenMailFrame_UpdateButtonPositions(letterIsTakeable, textCreated, stationeryIcon, money)
	if ( OpenMailFrame.activeAttachmentButtons ) then
		while (#OpenMailFrame.activeAttachmentButtons > 0) do
			tremove(OpenMailFrame.activeAttachmentButtons)
		end
	else
		OpenMailFrame.activeAttachmentButtons = {}
	end
	if ( OpenMailFrame.activeAttachmentRowPositions ) then
		while (#OpenMailFrame.activeAttachmentRowPositions  > 0) do
			tremove(OpenMailFrame.activeAttachmentRowPositions )
		end
	else
		OpenMailFrame.activeAttachmentRowPositions = {}
	end

	local rowAttachmentCount = 0

	-- letter
	if ( letterIsTakeable and not textCreated ) then
		SetItemButtonTexture(OpenMailLetterButton, stationeryIcon)
		tinsert(OpenMailFrame.activeAttachmentButtons, OpenMailLetterButton)
		rowAttachmentCount = rowAttachmentCount + 1
	else
		SetItemButtonTexture(OpenMailLetterButton, "")
	end
	-- money
	if ( money == 0 ) then
		SetItemButtonTexture(OpenMailMoneyButton, "")
	else
		SetItemButtonTexture(OpenMailMoneyButton, GetCoinIcon(money))
		tinsert(OpenMailFrame.activeAttachmentButtons, OpenMailMoneyButton)
		rowAttachmentCount = rowAttachmentCount + 1
	end
	-- items
	for i=1, ATTACHMENTS_MAX_RECEIVE do
		local name, itemTexture, count, quality, canUse = GetInboxItem(InboxFrame.openMailID, i)
		local attachmentButton = _G["OpenMailAttachmentButton"..i]
		if ( name ) then
			tinsert(OpenMailFrame.activeAttachmentButtons, attachmentButton)
			rowAttachmentCount = rowAttachmentCount + 1

			SetItemButtonTexture(attachmentButton, itemTexture)
			SetItemButtonCount(attachmentButton, count)
			if ( canUse ) then
				SetItemButtonTextureVertexColor(attachmentButton, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			else
				SetItemButtonTextureVertexColor(attachmentButton, 1.0, 0.1, 0.1)
			end
		else
			attachmentButton:Hide()
		end

		if ( rowAttachmentCount >= ATTACHMENTS_PER_ROW_RECEIVE ) then
			tinsert(OpenMailFrame.activeAttachmentRowPositions, {cursorxstart=0,cursorxend=ATTACHMENTS_PER_ROW_RECEIVE - 1})
			rowAttachmentCount = 0
		end
	end
	-- insert last row's position data
	if ( rowAttachmentCount > 0 ) then
		local xstart = (ATTACHMENTS_PER_ROW_RECEIVE - rowAttachmentCount) / 2
		local xend = xstart + rowAttachmentCount - 1
		tinsert(OpenMailFrame.activeAttachmentRowPositions, {cursorxstart=xstart,cursorxend=xend})
	end

	-- hide unusable attachment buttons
	for i=ATTACHMENTS_MAX_RECEIVE + 1, ATTACHMENTS_MAX do
		_G["OpenMailAttachmentButton"..i]:Hide()
	end
end

function OpenMail_Update()
	if ( not InboxFrame.openMailID ) then
		return
	end
	if ( CanComplainInboxItem(InboxFrame.openMailID) ) then
		OpenMailReportSpamButton:Enable()
		OpenMailReportSpamButton:Show()
	else
		OpenMailReportSpamButton:Hide()
	end

	-- Setup mail item
	local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply = GetInboxHeaderInfo(InboxFrame.openMailID)
	-- Set sender and subject
	if ( not sender or not canReply ) then
		OpenMailReplyButton:Disable()
	else
		OpenMailReplyButton:Enable()
	end
	if ( not sender ) then
		sender = UNKNOWN
	end
	-- Save sender name to pass to a potential spam report
	InboxFrame.openMailSender = sender
	OpenMailSender:SetText(sender)
	OpenMailSubject:SetText(subject)
	-- Set Text
	local bodyText, texture, isTakeable, isInvoice = GetInboxText(InboxFrame.openMailID)
	OpenMailBodyText:SetText(bodyText)

	if ( texture ) then
		OpenStationeryBackgroundLeft:SetTexture(STATIONERY_PATH..texture.."1")
		OpenStationeryBackgroundRight:SetTexture(STATIONERY_PATH..texture.."2")
	end

	local _invoiceType, _itemName, _playerName, _bid, _buyout, _itemCount

	if sender == UnitName("player") then
		local itemEntry, itemCount, resoult, money, sellerName = strsplit(":", bodyText)

		if itemEntry and itemCount and resoult and money and sellerName then
			itemEntry = tonumber(itemEntry)
			itemCount = tonumber(itemCount)
			resoult = tonumber(resoult)
			money = tonumber(money)

			_invoiceType = resoult == 3 and "buyer" or "refund"
			_itemName = GetItemInfo(itemEntry)
			_playerName = sellerName
			_bid = money
			_buyout = -1
			_itemCount = itemCount

			isInvoice = true

			OpenMailBodyText:SetText("")
			OpenMailSender:SetText(MAILFRAME_BLACK_MARKET)
			OpenMailSubject:SetFormattedText(resoult == 3 and AUCTION_WON_MAIL_SUBJECT or AUCTION_OUTBID_MAIL_SUBJECT, _itemName)
		end
	end

	-- Is an invoice
	if ( isInvoice ) then
		local invoiceType, itemName, playerName, bid, buyout, deposit, consignment, moneyDelay, etaHour, etaMin = GetInboxInvoiceInfo(InboxFrame.openMailID)

		invoiceType = _invoiceType or invoiceType
		playerName = _playerName or playerName
		bid = _bid or bid
		buyout = _buyout or buyout
		itemName = _itemName or itemName

		if ( _itemCount and _itemCount > 1 ) then
			itemName = string.format("%s (%d)", itemName, _itemCount)
		end

		if ( playerName ) then
			-- Setup based on whether player is the buyer or the seller
			local buyMode
			if ( invoiceType == "buyer" ) then
				if ( bid == buyout ) then
					buyMode = "("..BUYOUT..")"
				elseif (buyout == -1) then
					buyMode = ""
				else
					buyMode = "("..HIGH_BIDDER..")"
				end
				OpenMailInvoiceItemLabel:SetText(ITEM_PURCHASED_COLON.." "..itemName.."  "..buyMode)
				OpenMailInvoicePurchaser:SetText(SOLD_BY_COLON.." "..playerName)
				OpenMailInvoiceAmountReceived:SetText(AMOUNT_PAID_COLON)
				-- Clear buymode
				OpenMailInvoiceBuyMode:SetText("")
				-- Position amount paid
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceSalePrice", "TOPRIGHT", 0, 0)
				-- Update purchase price
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid)
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, 0)
				-- Not used for a purchase invoice
				OpenMailInvoiceSalePrice:Hide()
				OpenMailInvoiceDeposit:Hide()
				OpenMailInvoiceHouseCut:Hide()
				OpenMailDepositMoneyFrame:Hide()
				OpenMailHouseCutMoneyFrame:Hide()
				OpenMailSalePriceMoneyFrame:Hide()
				OpenMailInvoiceNotYetSent:Hide()
				OpenMailInvoiceMoneyDelay:Hide()
			elseif (invoiceType == "seller") then
				OpenMailInvoiceItemLabel:SetText(ITEM_SOLD_COLON.." "..itemName)
				OpenMailInvoicePurchaser:SetText(PURCHASED_BY_COLON.." "..playerName)
				OpenMailInvoiceAmountReceived:SetText(AMOUNT_RECEIVED_COLON)
				-- Determine if auction was bought out or bid on
				if ( bid == buyout ) then
					OpenMailInvoiceBuyMode:SetText("("..BUYOUT..")")
				else
					OpenMailInvoiceBuyMode:SetText("("..HIGH_BIDDER..")")
				end
				-- Position amount received
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceHouseCut", "BOTTOMRIGHT", 0, -18)
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoiceHouseCut", "BOTTOMRIGHT", 0, 9)
				MoneyFrame_Update("OpenMailSalePriceMoneyFrame", bid)
				MoneyFrame_Update("OpenMailDepositMoneyFrame", deposit)
				MoneyFrame_Update("OpenMailHouseCutMoneyFrame", consignment)
				SetMoneyFrameColor("OpenMailHouseCutMoneyFrame", "red")
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid+deposit-consignment)

				-- Show these guys if the player was the seller
				OpenMailInvoiceSalePrice:Show()
				OpenMailInvoiceDeposit:Show()
				OpenMailInvoiceHouseCut:Show()
				OpenMailDepositMoneyFrame:Show()
				OpenMailHouseCutMoneyFrame:Show()
				OpenMailSalePriceMoneyFrame:Show()
				OpenMailInvoiceNotYetSent:Hide()
				OpenMailInvoiceMoneyDelay:Hide()
			elseif (invoiceType == "seller_temp_invoice") then
				if ( bid == buyout ) then
					buyMode = "("..BUYOUT..")"
				else
					buyMode = "("..HIGH_BIDDER..")"
				end
				OpenMailInvoiceItemLabel:SetText(ITEM_SOLD_COLON.." "..itemName.."  "..buyMode)
				OpenMailInvoicePurchaser:SetText(PURCHASED_BY_COLON.." "..playerName)
				OpenMailInvoiceAmountReceived:SetText(AUCTION_INVOICE_PENDING_FUNDS_COLON)
				-- Clear buymode
				OpenMailInvoiceBuyMode:SetText("")
				-- Position amount to be received
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceSalePrice", "TOPRIGHT", 0, 0)
				-- Update purchase price
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid+deposit-consignment)
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, 0)
				-- How long they have to wait to get the money
				OpenMailInvoiceMoneyDelay:SetFormattedText(AUCTION_INVOICE_FUNDS_DELAY, GameTime_GetFormattedTime(etaHour, etaMin, true))
				-- Not used for a temp sale invoice
				OpenMailInvoiceSalePrice:Hide()
				OpenMailInvoiceDeposit:Hide()
				OpenMailInvoiceHouseCut:Hide()
				OpenMailDepositMoneyFrame:Hide()
				OpenMailHouseCutMoneyFrame:Hide()
				OpenMailSalePriceMoneyFrame:Hide()
				OpenMailInvoiceNotYetSent:Show()
				OpenMailInvoiceMoneyDelay:Show()
			elseif ( invoiceType == "refund" ) then
				OpenMailInvoiceItemLabel:SetFormattedText(MAILFRAME_ITEM_NOT_PURCHASED, itemName)
				OpenMailInvoicePurchaser:SetText(SOLD_BY_COLON.." "..playerName)
				OpenMailInvoiceAmountReceived:SetText(MAILFRAME_AMOUNT_REFUNDED)
				-- Clear buymode
				OpenMailInvoiceBuyMode:SetText("")
				-- Position amount paid
				OpenMailInvoiceAmountReceived:SetPoint("TOPRIGHT", "OpenMailInvoiceSalePrice", "TOPRIGHT", 0, 0)
				-- Update purchase price
				MoneyFrame_Update("OpenMailTransactionAmountMoneyFrame", bid)
				-- Position buy line
				OpenMailArithmeticLine:SetPoint("TOP", "OpenMailInvoicePurchaser", "BOTTOMLEFT", 125, 0)
				-- Not used for a purchase invoice
				OpenMailInvoiceSalePrice:Hide()
				OpenMailInvoiceDeposit:Hide()
				OpenMailInvoiceHouseCut:Hide()
				OpenMailDepositMoneyFrame:Hide()
				OpenMailHouseCutMoneyFrame:Hide()
				OpenMailSalePriceMoneyFrame:Hide()
				OpenMailInvoiceNotYetSent:Hide()
				OpenMailInvoiceMoneyDelay:Hide()
			end
			OpenMailInvoiceFrame:Show()
		end
	else
		OpenMailInvoiceFrame:Hide()
	end

	local itemButtonCount, itemRowCount = OpenMail_GetItemCounts(isTakeable, textCreated, money)
	if ( OpenMailFrame.updateButtonPositions ) then
		OpenMailFrame_UpdateButtonPositions(isTakeable, textCreated, stationeryIcon, money)
	end
	if ( OpenMailFrame.activeAttachmentRowPositions ) then
		itemRowCount = #OpenMailFrame.activeAttachmentRowPositions
	end

	-- record the original number of buttons that the mail needs
	OpenMailFrame.itemButtonCount = itemButtonCount

	-- Determine starting position for buttons
	local marginxl = 10 + 4
	local marginxr = 43 + 4
	local areax = OpenMailFrame:GetWidth() - marginxl - marginxr
	local iconx = OpenMailAttachmentButton1:GetWidth() + 2
	local icony = OpenMailAttachmentButton1:GetHeight() + 2
	local gapx1 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_RECEIVE)) / (ATTACHMENTS_PER_ROW_RECEIVE - 1))
	local gapx2 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_RECEIVE) - (gapx1 * (ATTACHMENTS_PER_ROW_RECEIVE - 1))) / 2)
	local gapy1 = 3
	local gapy2 = 3
	local areay = gapy2 + OpenMailAttachmentText:GetHeight() + gapy2 + (icony * itemRowCount) + (gapy1 * (itemRowCount - 1)) + gapy2
	local indentx = marginxl + gapx2
	local indenty = 28 + gapy2
	local tabx = (iconx + gapx1) + 6 --this magic number changes the button spacing
	local taby = (icony + gapy1)
	local scrollHeight = 305 - areay
	if (scrollHeight > 256) then
		scrollHeight = 256
		areay = 305 - scrollHeight
	end

	-- Resize the scroll frame
	OpenMailScrollFrame:SetHeight(scrollHeight)
	OpenMailScrollChildFrame:SetHeight(scrollHeight)
	OpenMailHorizontalBarLeft:SetPoint("TOPLEFT", "OpenMailFrame", "BOTTOMLEFT", 2, 39 + areay)
	OpenScrollBarBackgroundTop:SetHeight(min(scrollHeight, 256))
	OpenScrollBarBackgroundTop:SetTexCoord(0, 0.484375, 0, min(scrollHeight, 256) / 256)
	OpenStationeryBackgroundLeft:SetHeight(scrollHeight)
	OpenStationeryBackgroundLeft:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256)
	OpenStationeryBackgroundRight:SetHeight(scrollHeight)
	OpenStationeryBackgroundRight:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256)

	-- Set attachment text
	if ( itemButtonCount > 0 ) then
		OpenMailAttachmentText:SetText(TAKE_ATTACHMENTS)
		OpenMailAttachmentText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		OpenMailAttachmentText:SetPoint("TOPLEFT", "OpenMailFrame", "BOTTOMLEFT", indentx, indenty + (icony * itemRowCount) + (gapy1 * (itemRowCount - 1)) + gapy2 + OpenMailAttachmentText:GetHeight())
	else
		OpenMailAttachmentText:SetText(NO_ATTACHMENTS)
		OpenMailAttachmentText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		OpenMailAttachmentText:SetPoint("TOPLEFT", "OpenMailFrame", "BOTTOMLEFT", marginxl + (areax - OpenMailAttachmentText:GetWidth()) / 2, indenty + (areay - OpenMailAttachmentText:GetHeight()) / 2 + OpenMailAttachmentText:GetHeight())
	end
	-- Set letter
	if ( isTakeable and not textCreated ) then
		OpenMailLetterButton:Show()
	else
		OpenMailLetterButton:Hide()
	end
	-- Set Money
	if ( money == 0 ) then
		OpenMailMoneyButton:Hide()
		OpenMailFrame.money = nil
	else
		OpenMailMoneyButton:Show()
		OpenMailFrame.money = money
	end
	-- Set Items
	if ( itemRowCount > 0 and OpenMailFrame.activeAttachmentButtons ) then
		local firstAttachName
		local rowIndex = 1
		local cursorx = OpenMailFrame.activeAttachmentRowPositions[1].cursorxstart
		local cursorxend = OpenMailFrame.activeAttachmentRowPositions[1].cursorxend
		local cursory = itemRowCount - 1
		for i, attachmentButton in pairs(OpenMailFrame.activeAttachmentButtons) do
			attachmentButton:SetPoint("TOPLEFT", OpenMailFrame, "BOTTOMLEFT", indentx + (tabx * cursorx), indenty + icony + (taby * cursory))
			if ( attachmentButton ~= OpenMailLetterButton and attachmentButton ~= OpenMailMoneyButton ) then
				local name, itemTexture, count, quality, canUse = GetInboxItem(InboxFrame.openMailID, attachmentButton:GetID())
				if ( name and cursory >= 0 ) then
					if ( not firstAttachName ) then
						firstAttachName = name
					end

					attachmentButton:Enable()
					attachmentButton:Show()
				else
					attachmentButton:Hide()
				end
			end

			cursorx = cursorx + 1
			if (cursorx > cursorxend) then
				rowIndex = rowIndex + 1

				cursory = cursory - 1
				if ( rowIndex <= itemRowCount ) then
					cursorx = OpenMailFrame.activeAttachmentRowPositions[rowIndex].cursorxstart
					cursorxend = OpenMailFrame.activeAttachmentRowPositions[rowIndex].cursorxend
				end
			end
		end

		OpenMailFrame.itemName = firstAttachName
	else
		OpenMailFrame.itemName = nil
	end

	-- Set COD
	if ( CODAmount > 0 ) then
		OpenMailFrame.cod = CODAmount
	else
		OpenMailFrame.cod = nil
	end
	-- Set button to delete or return to sender
	if ( InboxItemCanDelete(InboxFrame.openMailID) ) then
		OpenMailDeleteButton:SetText(DELETE)
	else
		OpenMailDeleteButton:SetText(MAIL_RETURN)
	end
end

function OpenMail_GetItemCounts(letterIsTakeable, textCreated, money)
	local itemButtonCount = 0
	local itemRowCount = 0
	local numRows = 0
	if ( letterIsTakeable and not textCreated ) then
		itemButtonCount = itemButtonCount + 1
		itemRowCount = itemRowCount + 1
	end
	if ( money ~= 0 ) then
		itemButtonCount = itemButtonCount + 1
		itemRowCount = itemRowCount + 1
	end
	for i=1, ATTACHMENTS_MAX_RECEIVE do
		local name, itemTexture, count, quality, canUse = GetInboxItem(InboxFrame.openMailID, i)
		if ( name ) then
			itemButtonCount = itemButtonCount + 1
			itemRowCount = itemRowCount + 1
		end

		if ( itemRowCount >= ATTACHMENTS_PER_ROW_RECEIVE ) then
			numRows = numRows + 1
			itemRowCount = 0
		end
	end
	if ( itemRowCount > 0 ) then
		numRows = numRows + 1
	end
	return itemButtonCount, numRows
end

function OpenMail_Reply()
	MailFrameTab_OnClick(nil, 2)
	SendMailNameEditBox:SetText(OpenMailSender:GetText())
	local subject = OpenMailSubject:GetText()
	local prefix = MAIL_REPLY_PREFIX.." "
	if ( strsub(subject, 1, strlen(prefix)) ~= prefix ) then
		subject = prefix..subject
	end
	SendMailSubjectEditBox:SetText(subject)
	SendMailBodyEditBox:SetFocus()

	-- Set the send mode so the work flow can change accordingly
	SendMailFrame.sendMode = "reply"
end

function OpenMail_Delete()
	if ( InboxItemCanDelete(InboxFrame.openMailID) ) then
		if ( OpenMailFrame.itemName ) then
			StaticPopup_Show("DELETE_MAIL", OpenMailFrame.itemName)
			return
		elseif ( OpenMailFrame.money ) then
			StaticPopup_Show("DELETE_MONEY")
			return
		else
			DeleteInboxItem(InboxFrame.openMailID)
		end
	else
		ReturnInboxItem(InboxFrame.openMailID)
		StaticPopup_Hide("COD_CONFIRMATION")
	end
	InboxFrame.openMailID = nil
	HideUIPanel(OpenMailFrame)
end

function OpenMail_ReportSpam()
	local dialog = StaticPopup_Show("CONFIRM_REPORT_SPAM_MAIL", InboxFrame.openMailSender)
	if ( dialog ) then
		dialog.data = InboxFrame.openMailID
	end
	OpenMailReportSpamButton:Disable()
end

function OpenMailAttachment_OnEnter(self, index)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetInboxItem(InboxFrame.openMailID, index)

	if ( OpenMailFrame.cod ) then
		SetTooltipMoney(GameTooltip, OpenMailFrame.cod)
		if ( OpenMailFrame.cod > GetMoney() ) then
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "red")
		else
			SetMoneyFrameColor("GameTooltipMoneyFrame1", "white")
		end
	end
	GameTooltip:Show()
end

function OpenMailAttachment_OnClick(self, index)
	if ( OpenMailFrame.cod and (OpenMailFrame.cod > GetMoney()) ) then
		StaticPopup_Show("COD_ALERT")
	elseif ( OpenMailFrame.cod ) then
		OpenMailFrame.lastTakeAttachment = index

		local itemList = {}
		for i = 1, ATTACHMENTS_MAX do
			local itemLink = GetInboxItemLink(InboxFrame.openMailID, i)
			if itemLink then
				local _, _, count = GetInboxItem(InboxFrame.openMailID, i)
				itemList[#itemList + 1] = count > 1 and string.format("%sx%d", itemLink, count) or itemLink
			end
		end

		StaticPopup_Show("COD_CONFIRMATION", table.concat(itemList, "\n"))
		OpenMailFrame.updateButtonPositions = false
	else
		TakeInboxItem(InboxFrame.openMailID, index)
		OpenMailFrame.updateButtonPositions = false
	end
	PlaySound("igMainMenuOptionCheckBoxOn")
end

-- SendMail functions

function SendMailMailButton_OnClick(self)
	self:Disable()
	local copper = MoneyInputFrame_GetCopper(SendMailMoney)
	SetSendMailCOD(0)
	SetSendMailMoney(0)
	if ( SendMailSendMoneyButton:GetChecked() ) then
		-- Send Money
		if ( copper > 0 ) then
			-- Open confirmation dialog
			StaticPopup_Show("SEND_MONEY", SendMailNameEditBox:GetText())
			return
		end
	else
		-- Send C.O.D.
		if ( copper > 0 ) then
			SetSendMailCOD(copper)
		end
	end
	SendMailFrame_SendMail()
end

function SendMailFrame_SendMail()
	SendMail(SendMailNameEditBox:GetText(), SendMailSubjectEditBox:GetText(), SendMailBodyEditBox:GetText())
end

function SendMailFrame_Update()
	-- Update the item(s) being sent
	local itemCount = 0
	local itemTitle
	local gap
	local last = 0
	for i=1, ATTACHMENTS_MAX_SEND do
		-- get info about the attachment
		local itemName, itemTexture, stackCount, quality = GetSendMailItem(i)
		-- set attachment texture info
		_G["SendMailAttachment"..i]:SetNormalTexture(itemTexture)
		-- set the stack count
		if ( stackCount <= 1 ) then
			_G["SendMailAttachment"..i.."Count"]:SetText("")
		else
			_G["SendMailAttachment"..i.."Count"]:SetText(stackCount)
		end
		-- determine what a name for the message in case it doesn't already have one
		if ( itemName ) then
			itemCount = itemCount + 1
			if ( not itemTitle ) then
				if ( stackCount <= 1 ) then
					itemTitle = itemName
				else
					itemTitle = itemName.." ("..stackCount..")"
				end
			end
			if ((last + 1) ~= i) then
				gap = 1
			end
			last = i
		end
	end
	-- Enable or disable C.O.D. depending on whether or not there's an item to send
	if ( itemCount > 0 ) then
		SendMailCODButton:Enable()
		SendMailCODButtonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

		if ( SendMailSubjectEditBox:GetText() == "" or SendMailSubjectEditBox:GetText() == SendMailFrame.previousItem ) then
			SendMailSubjectEditBox:SetText(itemTitle)
			SendMailFrame.previousItem = itemTitle
		end
	else
		-- If no itemname see if the subject is the name of the previously held item, if so clear the subject
		if ( SendMailSubjectEditBox:GetText() == SendMailFrame.previousItem ) then
			SendMailSubjectEditBox:SetText("")
		end
		SendMailFrame.previousItem = ""

		SendMailRadioButton_OnClick(1)
		SendMailCODButton:Disable()
		SendMailCODButtonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	end
	-- Update the cost
	MoneyFrame_Update("SendMailCostMoneyFrame", GetSendMailPrice())

	-- Color the postage text
	if ( GetSendMailPrice() > GetMoney() ) then
		SetMoneyFrameColor("SendMailCostMoneyFrame", "red")
	else
		SetMoneyFrameColor("SendMailCostMoneyFrame", "white")
	end

	-- Determine how many rows of attachments to show
	local itemRowCount = 1
	local temp = last
	while ((temp > ATTACHMENTS_PER_ROW_SEND) and (itemRowCount < ATTACHMENTS_MAX_ROWS_SEND)) do
		itemRowCount = itemRowCount + 1
		temp = temp - ATTACHMENTS_PER_ROW_SEND
	end
	if (not gap and (temp == ATTACHMENTS_PER_ROW_SEND) and (itemRowCount < ATTACHMENTS_MAX_ROWS_SEND)) then
		itemRowCount = itemRowCount + 1
	end
	if (SendMailFrame.maxRowsShown and (last > 0) and (itemRowCount < SendMailFrame.maxRowsShown)) then
		itemRowCount = SendMailFrame.maxRowsShown
	else
		SendMailFrame.maxRowsShown = itemRowCount
	end

	-- Compute sizes
	local cursorx = 0
	local cursory = itemRowCount - 1
	local marginxl = 8 + 6
	local marginxr = 40 + 6
	local areax = SendMailFrame:GetWidth() - marginxl - marginxr
	local iconx = SendMailAttachment1:GetWidth() + 2
	local icony = SendMailAttachment1:GetHeight() + 2
	local gapx1 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_SEND)) / (ATTACHMENTS_PER_ROW_SEND - 1))
	local gapx2 = floor((areax - (iconx * ATTACHMENTS_PER_ROW_SEND) - (gapx1 * (ATTACHMENTS_PER_ROW_SEND - 1))) / 2)
	local gapy1 = 5
	local gapy2 = 6
	local areay = (gapy2 * 2) + (gapy1 * (itemRowCount - 1)) + (icony * itemRowCount)
	local indentx = marginxl + gapx2
	local indenty = 170 + gapy2 + icony
	local tabx = (iconx + gapx1) - 2 --this magic number changes the attachment spacing
	local taby = (icony + gapy1)
	local scrollHeight = 249 - areay

	-- Resize the scroll frame
	SendMailScrollFrame:SetHeight(scrollHeight)
	SendMailScrollChildFrame:SetHeight(scrollHeight)
	SendMailHorizontalBarLeft2:SetPoint("TOPLEFT", SendMailFrame, "BOTTOMLEFT", 2, 184 + areay)
	SendScrollBarBackgroundTop:SetHeight(min(scrollHeight, 256))
	SendScrollBarBackgroundTop:SetTexCoord(0, 0.484375, 0, min(scrollHeight, 256) / 256)
	SendStationeryBackgroundLeft:SetHeight(min(scrollHeight, 256))
	SendStationeryBackgroundLeft:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256)
	SendStationeryBackgroundRight:SetHeight(min(scrollHeight, 256))
	SendStationeryBackgroundRight:SetTexCoord(0, 1.0, 0, min(scrollHeight, 256) / 256)
	SendStationeryBackgroundLeft:SetTexture("Interface/Stationery/stationerytest1")
	SendStationeryBackgroundRight:SetTexture("Interface/Stationery/stationerytest2")

	-- Set Items
	for i=1, ATTACHMENTS_MAX_SEND do
		if (cursory >= 0) then
			_G["SendMailAttachment"..i]:Enable()
			_G["SendMailAttachment"..i]:Show()
			_G["SendMailAttachment"..i]:SetPoint("TOPLEFT", "SendMailFrame", "BOTTOMLEFT", indentx + (tabx * cursorx), indenty + (taby * cursory))

			cursorx = cursorx + 1
			if (cursorx >= ATTACHMENTS_PER_ROW_SEND) then
				cursory = cursory - 1
				cursorx = 0
			end
		else
			_G["SendMailAttachment"..i]:Hide()
		end
	end
	for i=ATTACHMENTS_MAX_SEND+1, ATTACHMENTS_MAX do
		_G["SendMailAttachment"..i]:Hide()
	end

	SendMailFrame_CanSend()
end

function SendMailFrame_Reset()
	SendMailNameEditBox:SetText("")
	SendMailNameEditBox:SetFocus()
	SendMailSubjectEditBox:SetText("")
	SendMailBodyEditBox:SetText("")
	StationeryPopupFrame.selectedIndex = nil
	SendMailFrame_Update()
	StationeryPopupButton_OnClick(nil, 1)
	MoneyInputFrame_ResetMoney(SendMailMoney)
	SendMailRadioButton_OnClick(1)
	SendMailFrame.maxRowsShown = 0
end

function SendMailFrame_CanSend()
	local checks = 0
	local checksRequired = 3
	-- If has stationery
	if ( StationeryPopupFrame.selectedIndex ~= nil ) then
		checks = checks + 1
	end
	-- and has a sendee
	if ( strlen(SendMailNameEditBox:GetText()) > 0 ) then
		checks = checks + 1
	end
	-- and has a subject
	if ( strlen(SendMailSubjectEditBox:GetText()) > 0 ) then
		checks = checks + 1
	end
	-- check c.o.d. amount
	if ( SendMailCODButton:GetChecked() ) then
		checksRequired = 4
		-- COD must be less than 10000 gold
		if ( MoneyInputFrame_GetCopper(SendMailMoney) > MAX_COD_AMOUNT*COPPER_PER_GOLD ) then
			if ( ENABLE_COLORBLIND_MODE ~= "1" ) then
				SendMailErrorCoin:Show()
			end
			SendMailErrorText:Show()
		else
			SendMailErrorText:Hide()
			SendMailErrorCoin:Hide()
			checks = checks + 1
		end
	end

	if ( checks == checksRequired ) then
		SendMailMailButton:Enable()
	else
		SendMailMailButton:Disable()
	end
end

function SendMailRadioButton_OnClick(index)
	if ( index == 1 ) then
		SendMailSendMoneyButton:SetChecked(1)
		SendMailCODButton:SetChecked(nil)
		SendMailMoneyText:SetText(AMOUNT_TO_SEND)
	else
		SendMailSendMoneyButton:SetChecked(nil)
		SendMailCODButton:SetChecked(1)
		SendMailMoneyText:SetText(COD_AMOUNT)
	end
	PlaySound("igMainMenuOptionCheckBoxOn")
end

-- Stationery functions

function StationeryPopupFrame_Update()
	local numStationeries = GetNumStationeries()
	local index = FauxScrollFrame_GetOffset(StationeryPopupScrollFrame) + 1
	local name, texture, cost
	local button
	for i=1, STATIONERYITEMS_TO_DISPLAY do
		button = _G["StationeryPopupButton"..i]
		if ( index <= numStationeries ) then
			name, texture, cost = GetStationeryInfo(index)
			_G["StationeryPopupButton"..i.."Name"]:SetText(name)
			if ( cost ) then
				MoneyFrame_Update("StationeryPopupButton"..i.."MoneyFrame", cost)
				-- If player can't afford
				if ( cost > GetMoney() ) then
					button:Disable()
					SetMoneyFrameColor("StationeryPopupButton"..i.."MoneyFrame", "red")
				else
					button:Enable()
					SetMoneyFrameColor("StationeryPopupButton"..i.."MoneyFrame", "white")
				end
			else
				-- Is a stationery in player's inventory or is free
				MoneyFrame_Update("StationeryPopupButton"..i.."MoneyFrame", 0)
			end
			_G["StationeryPopupButton"..i.."Icon"]:SetTexture(texture)
			button:Show()
		else
			_G["StationeryPopupButton"..i.."Name"]:SetText("")
			MoneyFrame_Update("StationeryPopupButton"..i.."MoneyFrame", 0)
			_G["StationeryPopupButton"..i.."Icon"]:SetTexture("")
			button:Hide()
		end

		if ( index == StationeryPopupFrame.selectedIndex ) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end
		button.index = index
		index = index + 1
	end

	-- Scrollbar stuff
	FauxScrollFrame_Update(StationeryPopupScrollFrame, numStationeries , STATIONERYITEMS_TO_DISPLAY, STATIONERY_ICON_ROW_HEIGHT )
end

function StationeryPopupButton_OnClick(self, index)
	if ( not index ) then
		index = self.index
	end
	SelectStationery(index)
	StationeryPopupFrame.selectedIndex = index
	SendMailFrame_CanSend()
	-- Set the stationery texture
	local texture = GetSelectedStationeryTexture()
	if ( texture ) then
		SendStationeryBackgroundLeft:SetTexture(STATIONERY_PATH..texture.."1")
		SendStationeryBackgroundRight:SetTexture(STATIONERY_PATH..texture.."2")
	end
	StationeryPopupFrame_Update()
end

function SendMailMoneyButton_OnClick()
	local cursorMoney = GetCursorMoney()
	if ( cursorMoney > 0 ) then
		local money = MoneyInputFrame_GetCopper(SendMailMoney)
		if ( money > 0 ) then
			cursorMoney = cursorMoney + money
		end
		MoneyInputFrame_SetCopper(SendMailMoney, cursorMoney)
		DropCursorMoney()
	end
end

function SendMailAttachmentButton_OnClick(self, button)
	ClickSendMailItemButton(self:GetID(), button == "RightButton")
end

function SendMailAttachmentButton_OnDropAny()
	ClickSendMailItemButton()
end

function SendMailAttachment_OnEnter(self)
	local index = self:GetID()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if ( GetSendMailItem(index) ) then
		GameTooltip:SetSendMailItem(index)
	else
		GameTooltip:SetText(ATTACHMENT_TEXT, 1.0, 1.0, 1.0)
	end
end

function InboxFrame_OnMouseWheel( self, value )
	if self.WaitFrame:IsShown() then
		return
	end

	if value == 1 then
		if InboxPrevPageButton:IsEnabled() == 1 then
			InboxPrevPage()
		end
	else
		if InboxNextPageButton:IsEnabled() == 1 then
			InboxNextPage()
		end
	end
end

function HasInboxMoney( mailIndex )
	local _, _, _, _, money, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(mailIndex)

	if isGM then
		return
	end

	return money and money > 0
end

function HasInboxItem( mailIndex, attachmentIndex )
	local name = GetInboxItem(mailIndex, attachmentIndex)
	local _, _, _, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(mailIndex)

	if isGM then
		return
	end

	return name
end

local InboxFrame_HelpPlate = {
	FramePos = { x = 2, y = -2 },
	FrameSize = { width = 660, height = 360 },
	[1] = { ButtonPos = { x = 306, y = -145 }, HighLightBox = { x = 0, y = 0, width = 658, height = 320 }, ToolTipDir = "UP", ToolTipText = INBOXFRAME_TUTORIAL_1 },
	[2] = { ButtonPos = { x = 230, y = -316 }, HighLightBox = { x = 74, y = -324, width = 179, height = 30 }, ToolTipDir = "UP", ToolTipText = INBOXFRAME_TUTORIAL_2 },
	[3] = { ButtonPos = { x = 560, y = -316 }, HighLightBox = { x = 405, y = -324, width = 179, height = 30 }, ToolTipDir = "UP", ToolTipText = INBOXFRAME_TUTORIAL_3 },
}

function InboxFrame_ToggleTutorial( self, ... )
	local helpPlate = InboxFrame_HelpPlate
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, InboxFrame, InboxFrame.TutorialButton )
	else
		HelpPlate_Hide(true)
	end
end

-------------------------------------------------------------------------------------------
---------------------------------------- MailMixIn ----------------------------------------
-------------------------------------------------------------------------------------------

function MailMixIn:CalculateInboxContainerSize()
	local width, height = InboxFrame:GetSize()

	InboxFrame.LeftContainer:SetSize((width / 2), height)
	InboxFrame.RightContainer:SetSize((width / 2), height)
end

MailManagmentMixin = {}

local OPEN_ALL_MAIL_MIN_DELAY = 0.15

function MailManagmentMixin:Reset()
	self.mailIndex = 1
	self.attachmentIndex = ATTACHMENTS_MAX
	self.timeUntilNextRetrieval = nil
	self.blacklistedItemIDs = nil
	self.CommandPending = false
	self.takeItemsList = nil
	self.workState = nil

	self.initiallyAttachment = {}
	self.finalAttachment = {}
end

function MailManagmentMixin:InboxScan( table )
	local numMails = GetInboxNumItems()

	for mailIndex = 1, numMails do
		local _, _, _, _, money, CODAmount = GetInboxHeaderInfo(mailIndex)

		if CODAmount == 0 then
			if money ~= 0 then
				if not table[-1] then
					table[-1] = money
				else
					table[-1] = table[-1] + money
				end
			end

			for attachmentIndex = 1, ATTACHMENTS_MAX do
				local _, _, count = GetInboxItem(mailIndex, attachmentIndex)
				local itemLink = GetInboxItemLink(mailIndex, attachmentIndex)

				if not itemLink then
					break
				end

				if not table[itemLink] then
					table[itemLink] = count
				else
					table[itemLink] = table[itemLink] + count
				end
			end
		end
	end
end

function MailManagmentMixin:StartManagment( workState )
	InboxFrame.WaitFrame:Show()

	self:Reset()

	self:InboxScan(self.initiallyAttachment)

	self:Disable()
	self:RegisterEvent("MAIL_INBOX_UPDATE")
	self:RegisterEvent("MAIL_FAILED")
	self:RegisterEvent("MAIL_SUCCESS")
	self.numToOpen = GetInboxNumItems()
	self.workState = workState or 0

	if self.workState == 0 or self.workState == 2 then
		self.takeMoney = GetMoney()
	end

	AdditionalMailFunctionalButton:Disable()
	CloseDropDownMenus()

	if self.workState == 0 or self.workState == 2 or self.workState == 3 then
		self:SetText(OPEN_ALL_MAIL_BUTTON_OPENING)
		self:AdvanceAndProcessNextItem()
	elseif self.workState == 1 then
		self:DeleteAllReadMail()
	end
end

function MailManagmentMixin:StopManagment()
	local numItems = GetInboxNumItems()

	self:InboxScan(self.finalAttachment)

	InboxFrame.WaitFrame:Hide()
	self:PrintTakeItemList()

	self:Reset()
	self:SetText(OPEN_ALL_MAIL_BUTTON)
	self:UnregisterEvent("MAIL_INBOX_UPDATE")
	self:UnregisterEvent("MAIL_FAILED")
	self:UnregisterEvent("MAIL_SUCCESS")

	self:SetEnabled(numItems > 0)
	AdditionalMailFunctionalButton:SetEnabled(numItems > 0)

	if self.takeMoney then
		local money = GetMoney() - self.takeMoney

		if money > 0 then
			DEFAULT_CHAT_FRAME:AddMessage(string.format(LOOT_ITEM_SELF, GetMoneyString(money)), SYSTEM_FONT_COLOR.r, SYSTEM_FONT_COLOR.g, SYSTEM_FONT_COLOR.b)
		end

		self.takeMoney = nil
	end
end

function MailManagmentMixin:FoundAttachment()
	local foundAttachment = false
	while ( not foundAttachment ) do
		local _, _, _, _, money, CODAmount, daysLeft, itemCount, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)
		local itemLink = GetInboxItemLink(self.mailIndex, self.attachmentIndex)
		local itemID = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
		local hasBlacklistedItem = self:IsItemBlacklisted(itemID)
		local hasCOD = CODAmount and CODAmount > 0
		local hasMoneyOrItem

		if self.workState == 0 or self.workState == 1 then
			hasMoneyOrItem = HasInboxMoney(self.mailIndex) or HasInboxItem(self.mailIndex, self.attachmentIndex)
		elseif self.workState == 2 then
			hasMoneyOrItem = HasInboxMoney(self.mailIndex)
		elseif self.workState == 3 then
			hasMoneyOrItem = HasInboxItem(self.mailIndex, self.attachmentIndex)
		end

		if ( not hasBlacklistedItem and not hasCOD and hasMoneyOrItem ) then
			foundAttachment = true
		else
			self.attachmentIndex = self.attachmentIndex - 1
			if ( self.attachmentIndex == 0 ) then
				break
			end
		end
	end

	return foundAttachment
end

function MailManagmentMixin:DeleteMailNextCheck()
	self.mailIndex = self.mailIndex + 1
	self.attachmentIndex = ATTACHMENTS_MAX
	self:DeleteAllReadMail()
end

function MailManagmentMixin:DeleteAllReadMail()
	if self.mailIndex > GetInboxNumItems() then
		self:StopManagment()
		return
	end

	self.CommandPending = true
	local _, _, _, subject, money, CODAmount, daysLeft, itemCount, wasRead, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)

	if isGM or (CODAmount and CODAmount > 0) then
		return self:DeleteMailNextCheck()
	end

	if wasRead then
		if self:FoundAttachment() then
			return self:DeleteMailNextCheck()
		else
			if InboxItemCanDelete(self.mailIndex) then
				DeleteInboxItem(self.mailIndex)
				self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY
			else
				UIErrorsFrame:AddMessage(string.format(MAIL_DELETE_ERROR, subject), RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1)
				return self:DeleteMailNextCheck()
			end
		end
	else
		self:DeleteMailNextCheck()
	end
end

function MailManagmentMixin:AdvanceToNextItem()
	if not self:FoundAttachment() then
		self.mailIndex = self.mailIndex + 1
		self.attachmentIndex = ATTACHMENTS_MAX

		if ( self.mailIndex > GetInboxNumItems() ) then
			return false
		end

		return self:AdvanceToNextItem()
	end

	return true
end

function MailManagmentMixin:AdvanceAndProcessNextItem()
	if ( CalculateTotalNumberOfFreeBagSlots() == 0 ) then
		UIErrorsFrame:AddMessage(MAIL_ERROR_BAG_IS_FULL, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1)
		self:StopManagment()
		return
	end

	if ( self:AdvanceToNextItem() ) then
		if InboxFrame.pageNum ~= 1 then
			InboxFrame.pageNum = 1
			InboxGetMoreMail()
			InboxFrame_Update()
		end

		self:ProcessNextItem()
	else
		self:StopManagment()
	end
end

function MailManagmentMixin:ProcessNextItem()
	local _, _, _, _, money, CODAmount, daysLeft, itemCount, wasRead, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)
	local itemLink = GetInboxItemLink(self.mailIndex, self.attachmentIndex)
	local itemID = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
	local _, _, count = GetInboxItem(self.mailIndex, self.attachmentIndex)

	if ( isGM or (CODAmount and CODAmount > 0) ) then
		self:AdvanceAndProcessNextItem()
		return
	end

	if (self.workState == 0 or self.workState == 2) and money > 0 then
		self.CommandPending = true
		TakeInboxMoney(self.mailIndex)
		self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY
		self:AddTakeItem(-1, money)

		GetInboxText(self.mailIndex)
	elseif (self.workState == 0 or self.workState == 3) and (itemCount and itemCount > 0) then
		self.CommandPending = true
		TakeInboxItem(self.mailIndex, self.attachmentIndex)
		self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY
		self:AddTakeItem(itemID, count)

		GetInboxText(self.mailIndex)
	else
		self:AdvanceAndProcessNextItem()
	end
end

function MailManagmentMixin:OnLoad()
	self:Reset()
end

function MailManagmentMixin:IsCommandPending()
	return self.CommandPending
end

function MailManagmentMixin:OnEvent(event, ...)
	if event == "MAIL_SUCCESS" then
		self.CommandPending = false
	elseif event == "MAIL_INBOX_UPDATE" then
		if ( self.numToOpen ~= GetInboxNumItems() ) then
			self.mailIndex = 1
			self.attachmentIndex = ATTACHMENTS_MAX
		end
	elseif ( event == "MAIL_FAILED" ) then
		local itemID = ...
		if ( itemID ) then
			self:AddBlacklistedItem(itemID)
		end
	end
end

function MailManagmentMixin:OnUpdate(dt)
	if ( self.timeUntilNextRetrieval ) then
		self.timeUntilNextRetrieval = self.timeUntilNextRetrieval - dt
		if ( self.timeUntilNextRetrieval <= 0 ) then
			if ( not self:IsCommandPending() ) then
				self.timeUntilNextRetrieval = nil
				if self.workState == 0 or self.workState == 2 or self.workState == 3 then
					self:AdvanceAndProcessNextItem()
				elseif self.workState == 1 then
					self:DeleteAllReadMail()
				end
			else
				-- Delay until the current mail command is done processing.
				self.timeUntilNextRetrieval = OPEN_ALL_MAIL_MIN_DELAY
			end
		end
	end
end

function MailManagmentMixin:OnClick()
	self:StartManagment(0)
end

function MailManagmentMixin:OnHide()
	self:StopManagment()
end

function MailManagmentMixin:AddBlacklistedItem(itemID)
	if ( not self.blacklistedItemIDs ) then
		self.blacklistedItemIDs = {}
	end

	self.blacklistedItemIDs[itemID or -2] = true
end

function MailManagmentMixin:IsItemBlacklisted(itemID)
	return self.blacklistedItemIDs and self.blacklistedItemIDs[itemID or 0]
end

function MailManagmentMixin:AddTakeItem( itemID, itemCount )
	if not self.takeItemsList then
		self.takeItemsList = {}
	end

	if not self.takeItemsList[itemID] then
		self.takeItemsList[itemID] = itemCount
	else
		self.takeItemsList[itemID] = self.takeItemsList[itemID] + itemCount
	end
end

function MailManagmentMixin:CreateFinalData()
	for link, count in pairs(self.finalAttachment) do
		if self.initiallyAttachment[link] then
			self.initiallyAttachment[link] = self.initiallyAttachment[link] - count

			if self.initiallyAttachment[link] == 0 then
				self.initiallyAttachment[link] = nil
			end
		end
	end

	return self.initiallyAttachment
end

function MailManagmentMixin:PrintTakeItemList()
	local takeAttachments = self:CreateFinalData()

	if takeAttachments then
		local color = LOOT_FONT_COLOR

		for link, count in pairs(takeAttachments) do
			if link ~= -1 then
				if count > 1 then
					DEFAULT_CHAT_FRAME:AddMessage(string.format(LOOT_ITEM_SELF_MULTIPLE, link, count), color.r, color.g, color.b)
				else
					DEFAULT_CHAT_FRAME:AddMessage(string.format(LOOT_ITEM_SELF, link), color.r, color.g, color.b)
				end
			end
		end
	end
end

MailListUpdateMixin = {}

function MailListUpdateMixin:OnShow()
	self.disableTime = C_CacheInstance:Get("ASMSG_MAIL_LIST_UPDATE", 0)
	self.elapsed = 0

	if self.disableTime - time() < 0 then
		self:Reset()
	else
		self:UpdateState()
	end
end

function MailListUpdateMixin:OnClick()
	CloseOpenMailFrame()
	SendServerMessage("ACMSG_MAIL_LIST_UPDATE")
	UpdateInboxToMuchMail()
end

function MailListUpdateMixin:OnUpdate( elapsed )
	self.elapsed = self.elapsed + elapsed

	if self.elapsed >= 1 then
		self.elapsed = 0

		if self.disableTime == 0 then
			return
		end

		self:UpdateState()
	end
end

function MailListUpdateMixin:Reset()
	self:Enable()
	self:SetText(MAIL_LIST_UPDATE)

	self.disableTime = 0
	C_CacheInstance:Set("ASMSG_MAIL_LIST_UPDATE", 0)
end

function MailListUpdateMixin:UpdateState()
	local timeRemaning = (self.disableTime - time())

	if self:IsEnabled() == 1 then
		self:Disable()
	end

	self:SetFormattedText(MAIL_LIST_UPDATE_TIMER, timeRemaning)

	if timeRemaning <= 0 then
		self:Reset()
	end
end

AdditionalMailFunctionalMixin = {}

function AdditionalMailFunctionalMixin:OnLoad()
	local function InitializeDropDown(self)
		self:GetParent():InitializeDropDown()
	end

	UIDropDownMenu_Initialize(AdditionalMailFunctionalDropDown, InitializeDropDown, "MENU")
end

function AdditionalMailFunctionalMixin:InitializeDropDown()
	local function OnSelection( button )
		self:OnSelection(button.value, button.checked)
	end

	local info = UIDropDownMenu_CreateInfo()

	info.isNotRadio = true
	info.keepShownOnClick = true
	info.notCheckable = true
	info.func = OnSelection

	info.text = MAIL_DELETE_READ_MAIL
	info.value = 1
	info.disabled = GetInboxNumItems() == 0
	UIDropDownMenu_AddButton(info)

	info.disabled = false
	info.text = MAIL_TAKE_ONLY_ALL_GOLD
	info.value = 2
	info.disabled = GetInboxNumItems() == 0
	UIDropDownMenu_AddButton(info)

	info.text = MAIL_TAKE_ONLY_ALL_ITEM
	info.value = 3
	info.disabled = GetInboxNumItems() == 0
	UIDropDownMenu_AddButton(info)
end

function AdditionalMailFunctionalMixin:OnSelection( value, checked )
	OpenAllMailButton:StartManagment(value)
	CloseDropDownMenus()
end


function EventHandler:ASMSG_MAIL_LIST_UPDATE( msg )
	local timer = min(math.floor(max(tonumber(msg), 0) / 1000), 10)
	local currentTime = time()

	timer = currentTime + timer
	C_CacheInstance:Set("ASMSG_MAIL_LIST_UPDATE", timer)

	UpdateMailButton.disableTime = timer
	UpdateMailButton:UpdateState()
end