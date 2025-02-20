StaticPopup_DisplayedFrames = { };

STATICPOPUP_NUMDIALOGS = 4;
STATICPOPUP_TIMEOUT = 60;
STATICPOPUP_TEXTURE_ALERT = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew";
STATICPOPUP_TEXTURE_ALERTGEAR = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertOther";
StaticPopupDialogs = { };

local AcceptBattlefieldPort = AcceptBattlefieldPort
local GuildInvite = GuildInvite
local GuildSetLeader = GuildSetLeader

function StaticPopup_StandardConfirmationTextHandler(self, expectedText)
	local parent = self:GetParent();
	parent.button1:SetEnabled(ConfirmationEditBoxMatches(parent.editBox, expectedText));
end

function StaticPopup_StandardNonEmptyTextHandler(self)
	local parent = self:GetParent();
	parent.button1:SetEnabled(UserEditBoxNonEmpty(parent.editBox));
end

function StaticPopup_StandardEditBoxOnEscapePressed(self)
	self:GetParent():Hide();
end

StaticPopupDialogs["CONFIRM_OVERWRITE_EQUIPMENT_SET"] = {
	text = CONFIRM_OVERWRITE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) SaveEquipmentSet(self.data, self.selectedIcon); GearManagerDialogPopup:Hide(); end,
	OnCancel = function (self) end,
	OnHide = function (self) self.data = nil; self.selectedIcon = nil; end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_DELETE_EQUIPMENT_SET"] = {
	text = CONFIRM_DELETE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) DeleteEquipmentSet(self.data); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_REMOVE_GLYPH"] = {
	text = CONFIRM_REMOVE_GLYPH,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveTalentGroup() ) then
			RemoveGlyphFromSocket(self.data);
		end
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_GLYPH_PLACEMENT"] = {
	text = CONFIRM_GLYPH_PLACEMENT,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) PlaceGlyphInSocket(self.data); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_RESET_VIDEO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = function ()
		VideoOptionsFrame_SetAllToDefaults();
	end,
	OnAlt = function ()
		VideoOptionsFrame_SetCurrentToDefaults();
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_RESET_AUDIO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = function ()
		AudioOptionsFrame_SetAllToDefaults();
	end,
	OnAlt = function ()
		AudioOptionsFrame_SetCurrentToDefaults();
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_RESET_INTERFACE_SETTINGS"] = {
	text = CONFIRM_RESET_INTERFACE_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = function ()
		InterfaceOptionsFrame_SetAllToDefaults();
	end,
	OnAlt = function ()
		InterfaceOptionsFrame_SetCurrentToDefaults();
	end,
	OnCancel = function() end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_PURCHASE_TOKEN_ITEM"] = {
	text = CONFIRM_PURCHASE_TOKEN_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function()

	end,
	OnShow = function()

	end,
	OnHide = function()

	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["CONFIRM_EXCHANGE_LEGENDARY_ITEM"] = {
	text = CONFIRM_EXCHANGE_LEGENDARY_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function()

	end,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
		self.HelpBox.Text:SetText(CONFIRM_EXCHANGE_LEGENDARY_INFO)
		_G[self:GetName().."ItemFrame"]:SetPoint("BOTTOM", self.button1, "TOP", 0, 58)
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		_G[self:GetName().."ItemFrame"]:SetPoint("BOTTOM", self.button1, "TOP", 0, 8)
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() == 1 ) then
			BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
			self:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, CONFIRM_TEXT_AGREE);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self)
		ClearCursor()
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
	hasEditBox = 1,
	maxLetters = 32,
	HelpBox = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_TOKEN_ITEM"] = {
	text = CONFIRM_REFUND_TOKEN_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local currentHonor, maxHonor = GetHonorCurrency();
		local currentArenaPoints, maxArenaPoints = GetArenaCurrency();
		local overflowHonor = MerchantFrame.honorPoints and ( MerchantFrame.honorPoints + currentHonor > maxHonor );
		local overflowArena = MerchantFrame.arenaPoints and ( MerchantFrame.arenaPoints + currentArenaPoints > maxArenaPoints );
		if ( overflowHonor and overflowArena ) then
			StaticPopup_Show("CONFIRM_REFUND_MAX_HONOR_AND_ARENA", (MerchantFrame.honorPoints + currentHonor - maxHonor), (MerchantFrame.arenaPoints + currentArenaPoints - maxArenaPoints) )
		elseif ( overflowHonor ) then
			StaticPopup_Show("CONFIRM_REFUND_MAX_HONOR", (MerchantFrame.honorPoints + currentHonor - maxHonor) )
		elseif ( overflowArena ) then
			StaticPopup_Show("CONFIRM_REFUND_MAX_ARENA_POINTS", (MerchantFrame.arenaPoints + currentArenaPoints - maxArenaPoints))
		else
			ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot, MerchantFrame.refundItemEquipped);
		end
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function(self)
		if(MerchantFrame.price ~= 0) then
			MoneyFrame_Update(self.moneyFrame, MerchantFrame.price);
		end
	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_HONOR"] = {
	text = CONFIRM_REFUND_MAX_HONOR,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()

	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_ARENA_POINTS"] = {
	text = CONFIRM_REFUND_MAX_ARENA_POINTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()

	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_HONOR_AND_ARENA"] = {
	text = CONFIRM_REFUND_MAX_HONOR_AND_ARENA,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()

	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_HIGH_COST_ITEM"] = {
	text = CONFIRM_HIGH_COST_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function()

	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, MerchantFrame.price*MerchantFrame.count);
	end,
	OnHide = function()

	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
}

StaticPopupDialogs["CONFIRM_COMPLETE_EXPENSIVE_QUEST"] = {
	text = CONFIRM_COMPLETE_EXPENSIVE_QUEST,
	button1 = COMPLETE_QUEST,
	button2 = CANCEL,
	OnAccept = function()
		GetQuestReward(QuestInfoFrame.itemChoice);
		PlaySound("igQuestListComplete");
	end,
	OnCancel = function()
		DeclineQuest();
		PlaySound("igQuestCancel");
	end,
	OnShow = function()
		QuestInfoFrame.acceptButton:Disable();
		QuestInfoFrame.cancelButton:Disable();
	end,
	OnHide = function()
		QuestInfoFrame.cancelButton:Enable();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};
StaticPopupDialogs["CONFIRM_ACCEPT_PVP_QUEST"] = {
	text = CONFIRM_ACCEPT_PVP_QUEST,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		AcceptQuest();
	end,
	OnCancel = function()
		DeclineQuest();
		PlaySound("igQuestCancel");
	end,
	OnShow = function()
		QuestFrameAcceptButton:Disable();
		QuestFrameDeclineButton:Disable();
	end,
	OnHide = function()
		QuestFrameDeclineButton:Enable();
	end,
	timeout = 0,
	hideOnEscape = 1,
};
StaticPopupDialogs["USE_GUILDBANK_REPAIR"] = {
	text = USE_GUILDBANK_REPAIR,
	button1 = USE_PERSONAL_FUNDS,
	button2 = OKAY,
	OnAccept = function()
		RepairAllItems();
		PlaySound("ITEM_REPAIR");
	end,
	OnCancel = function ()
		RepairAllItems(1);
		PlaySound("ITEM_REPAIR");
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_WITHDRAW"] = {
	text = GUILDBANK_WITHDRAW,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(self.moneyInputFrame));
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent():GetParent();
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(parent.moneyInputFrame));
		parent:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_DEPOSIT"] = {
	text = GUILDBANK_DEPOSIT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(self.moneyInputFrame));
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent():GetParent();
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(parent.moneyInputFrame));
		parent:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BUY_GUILDBANK_TAB"] = {
	text = CONFIRM_BUY_GUILDBANK_TAB,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		BuyGuildBankTab();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetGuildBankTabCost());
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["TOO_MANY_LUA_ERRORS"] = {
	text = TOO_MANY_LUA_ERRORS,
	button1 = DISABLE_ADDONS,
	button2 = IGNORE_ERRORS,
	OnAccept = function(self)
		DisableAllAddOns();
		ReloadUI();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_ACCEPT_SOCKETS"] = {
	text = CONFIRM_ACCEPT_SOCKETS,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		AcceptSockets();
		PlaySound("JewelcraftingFinalize");
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["TAKE_GM_SURVEY"] = {
	text = TAKE_GM_SURVEY,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		TicketStatusFrame:Hide();
	end,
	OnCancel = function(self)
		TicketStatusFrame.hasGMSurvey = false;
		TicketStatusFrame:Hide();
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RESET_INSTANCES"] = {
	text = CONFIRM_RESET_INSTANCES,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		ResetInstances();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_GUILD_DISBAND"] = {
	text = CONFIRM_GUILD_DISBAND,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GuildDisband();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		PurchaseSlot();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, BankFrame.nextSlotCost);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["MACRO_ACTION_FORBIDDEN"] = {
	text = MACRO_ACTION_FORBIDDEN,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
	text = ADDON_ACTION_FORBIDDEN,
	button1 = DISABLE,
	button2 = IGNORE_DIALOG,
	OnAccept = function(self, data)
		DisableAddOn(data);
		ReloadUI();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"] = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		GiveMasterLoot(LootFrame.selectedSlot, data);
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = LEAVE_QUEUE,
	OnShow = function(self, data)
		if IsDevClient(true) and GetCVarBool("devSkipBattlegroundInvite") then
			C_Timer:After(0.5, function() AcceptBattlefieldPort(data, 1) end)
		end

		local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, registeredMatch = GetBattlefieldStatus(data);
		if ( teamSize == 0 ) then
			self.button2:Enable();
		else
			self.button2:Disable();
		end

		self.bar:SetMinMaxValues(0, 1)
		self.bar:Show()
       	self.elapsedTime = 0
        self.animTime = GetBattlefieldPortExpiration(self.data) + 1
        self.fromValue = (GetBattlefieldPortExpiration(self.data) + 1) / 60

		FlashClientIcon()
	end,
	OnHide = function(self, data)
		self.bar:Hide()
	end,
	OnAccept = function(self, data)
		if ( not AcceptBattlefieldPort(data, 1) ) then
			return 1;
		end
		if ( StaticPopup_Visible( "DEATH" ) ) then
			StaticPopup_Hide( "DEATH" );
		end
	end,
	OnCancel = function(self, data)
		if ( not AcceptBattlefieldPort(data, 0) ) then	--Actually declines the battlefield port.
			return 1;
		end
	end,
	OnUpdate = function(self, elapsed)
		local time = GetBattlefieldPortExpiration(self.data) + 1
		local minutes, seconds = floor(time/60), floor(mod(time, 60))

        local elapsedTime = self.elapsedTime
        elapsedTime = elapsedTime + elapsed
        self.elapsedTime = elapsedTime
        local fromValue = self.fromValue

		self.bar:SetValue(linear(elapsedTime, fromValue, -fromValue, self.animTime))
		self.bar.timeText:SetText(string.format("%d:%02d", minutes, seconds))

		if UnitAffectingCombat("player") then
			self.button1:Disable();
		else
			self.button1:Enable();
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	noCancelOnEscape = 1,
	noCancelOnReuse = 1,
	multiple = 1,
	closeButton = 1,
	closeButtonIsHide = 1,
    elapsedTime = 0,
    animTime = 60,
    fromValue = 1
};

StaticPopupDialogs["BFMGR_CONFIRM_WORLD_PVP_QUEUED"] = {
	text = WORLD_PVP_QUEUED,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_CONFIRM_WORLD_PVP_QUEUED_WARMUP"] = {
	text = WORLD_PVP_QUEUED_WARMUP,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_DENY_WORLD_PVP_QUEUED"] = {
	text = WORLD_PVP_FAIL,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_INVITED_TO_QUEUE"] = {
	text = WORLD_PVP_INVITED,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		BattlefieldMgrQueueInviteResponse(1,1);
	end,
	OnCancel = function(self, data)
		BattlefieldMgrQueueInviteResponse(1,0);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_INVITED_TO_QUEUE_WARMUP"] = {
	text = WORLD_PVP_INVITED_WARMUP;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		BattlefieldMgrQueueInviteResponse(1,1);
	end,
	OnCancel = function(self, data)
		BattlefieldMgrQueueInviteResponse(1,0);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_INVITED_TO_ENTER"] = {
	text = WORLD_PVP_ENTER,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = select(4, GetWorldPVPQueueStatus(1));
		FlashClientIcon()
	end,
	OnAccept = function(self, data)
		BattlefieldMgrEntryInviteResponse(1,1);
	end,
	OnCancel = function(self, data)
		BattlefieldMgrEntryInviteResponse(1,0);
	end,
	timeout = 0,
	timeoutInformationalOnly = 1;
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_EJECT_PENDING"] = {
	text = WORLD_PVP_PENDING,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_EJECT_PENDING_REMOTE"] = {
	text = WORLD_PVP_PENDING_REMOTE,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_PLAYER_EXITED_BATTLE"] = {
	text = WORLD_PVP_EXITED_BATTLE,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_PLAYER_LOW_LEVEL"] = {
	text = WORLD_PVP_LOW_LEVEL,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_GUILD_LEAVE"] = {
	text = CONFIRM_GUILD_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		GuildLeave();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_GUILD_PROMOTE"] = {
	text = CONFIRM_GUILD_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, name)
		GuildSetLeader(name);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() == 1 ) then
			GuildSetLeader(self:GetParent().data)
			self:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, CONFIRM_GUILD_PROMOTE_WORD);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
};

StaticPopupDialogs["RENAME_GUILD"] = {
	text = RENAME_GUILD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		RenamePetition(text);
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SIRUS_RENAME_GUILD_COMPLETE"] = {
	text = GUILD_RENAME_SUCCESSFULLY,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
}

StaticPopupDialogs["SIRUS_RENAME_GUILD_ERROR"] = {
	text = GUILD_RENAME_ERROR_TEXT,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
}

StaticPopupDialogs["SIRUS_RENAME_GUILD"] = {
	text = RENAME_GUILD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		self:Hide()
		StaticPopup_Show("SIRUS_RENAME_GUILD_CONFIRM", nil, nil, text)
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		self:GetParent():Hide();
		StaticPopup_Show("SIRUS_RENAME_GUILD_CONFIRM", nil, nil, text)
	end,
	OnCancel = function(self)
		if not GuildMicroButtonHelpBox:IsShown() and not GuildFrame:IsShown() then
			GuildMicroButtonHelpBox:Show()
		end
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SIRUS_RENAME_GUILD_CONFIRM"] = {
	text = GUILD_RENAME_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		SubmitGuildRename(data)
	end,
	OnCancel = function(self)
		if not GuildMicroButtonHelpBox:IsShown() and not GuildFrame:IsShown() then
			GuildMicroButtonHelpBox:Show()
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["RENAME_ARENA_TEAM"] = {
	text = RENAME_ARENA_TEAM_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText();
		RenamePetition(text);
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_LEAVE"] = {
	text = CONFIRM_TEAM_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, team)
		ArenaTeamLeave(team);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_PROMOTE"] = {
	text = CONFIRM_TEAM_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, team, name)
		ArenaTeamSetLeaderByName(team, name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_KICK"] = {
	text = CONFIRM_TEAM_KICK,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, team, name)
		ArenaTeamUninviteByName(team, name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_QUEUE_DISABLED"] = {
	text = HELP_TICKET_QUEUE_DISABLED,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
}

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["CLIENT_LOGOUT_ALERT"] = {
	text = CLIENT_LOGOUT_ALERT,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["COD_ALERT"] = {
	text = COD_INSUFFICIENT_MONEY,
	button1 = CLOSE,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["COD_CONFIRMATION"] = {
	text = COD_CONFIRMATION_ALERT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		TakeInboxItem(InboxFrame.openMailID, OpenMailFrame.lastTakeAttachment);

		self.lockTimeLeft = nil;
	end,
	OnShow = function(self)
		self.button1:Disable();
		self.lockTimeLeft = 3;
		MoneyFrame_Update(self.moneyFrame, OpenMailFrame.cod);
	end,
	OnUpdate = function(self, elapsed)
		if self.lockTimeLeft then
			local lockTimeLeft = self.lockTimeLeft - elapsed;
			if lockTimeLeft <= 0 then
				self.lockTimeleft = nil;
				self.button1:SetText(ACCEPT);
				self.button1:Enable();
				return;
			end
			self.lockTimeLeft = lockTimeLeft;
			self.button1:SetText(ceil(lockTimeLeft));
		end
	end,
	OnCancel = function(self)
		self.lockTimeLeft = nil;
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
	showAlert = 1
};

StaticPopupDialogs["COD_CONFIRMATION_AUTO_LOOT"] = {
	text = COD_CONFIRMATION_ALERT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, index)
		AutoLootMailItem(index);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
	showAlert = 1
};

StaticPopupDialogs["DELETE_MAIL"] = {
	text = DELETE_MAIL_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["FAST_DELETE_MAIL"] = {
	text = MAIL_FAST_DELETE_CONFIRMATION,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self, data)
		DeleteInboxItem(data)
		HideUIPanel(OpenMailFrame)
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
}

StaticPopupDialogs["DELETE_MONEY"] = {
	text = DELETE_MONEY_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, OpenMailFrame.money);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["SEND_MONEY"] = {
	text = SEND_MONEY_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		if ( SetSendMailMoney(MoneyInputFrame_GetCopper(SendMailMoney)) ) then
			SendMailFrame_SendMail();
		end
	end,
	OnCancel = function(self)
		SendMailMailButton:Enable();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, MoneyInputFrame_GetCopper(SendMailMoney));
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_SPAM_CHAT"] = {
	text = REPORT_SPAM_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, lineID)
		ComplainChat(lineID);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_SPAM_MAIL"] = {
	text = REPORT_SPAM_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, index)
		ComplainInboxItem(index);
	end,
	OnCancel = function(self, index)
		OpenMailReportSpamButton:Enable();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["JOIN_CHANNEL"] = {
	text = ADD_CHANNEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function(self)
		local channel = self.editBox:GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		self.editBox:SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local editBox = parent.editBox;
		local channel = editBox:GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		editBox:SetText("");
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["CHANNEL_INVITE"] = {
	text = CHANNEL_INVITE,
	button1 = ACCEPT_ALT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.CHANINVITE,
	maxLetters = 31,
	whileDead = 1,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	OnAccept = function(self, data)
		local name = self.editBox:GetText();
		ChannelInvite(data, name);
		self.editBox:SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		local editBox = parent.editBox;
		ChannelInvite(data, editBox:GetText());
		editBox:SetText("");
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["CHANNEL_PASSWORD"] = {
	text = CHANNEL_PASSWORD,
	button1 = ACCEPT_ALT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	OnAccept = function(self, data)
		local password = self.editBox:GetText();
		SetChannelPassword(data, password);
		self.editBox:SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		local editBox = parent.editBox
		local password = editBox:GetText();
		SetChannelPassword(data, password);
		editBox:SetText("");
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["NAME_CHAT"] = {
	text = NAME_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function(self, renameID)
		local name = self.editBox:GetText();
		if ( renameID ) then
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			local frame = FCF_OpenNewWindow(name);
			FCF_CopyChatSettings(frame, DEFAULT_CHAT_FRAME);
		end
		self.editBox:SetText("");
		FCF_DockUpdate();
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, renameID)
		local parent = self:GetParent();
		local editBox = parent.editBox
		local name = editBox:GetText();
		if ( renameID ) then
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			local frame = FCF_OpenNewWindow(name);
			FCF_CopyChatSettings(frame, DEFAULT_CHAT_FRAME);
		end
		editBox:SetText("");
		FCF_DockUpdate();
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["RESET_CHAT"] = {
	text = RESET_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function(self)
		FCF_ResetChatWindows();
		if ( ChatConfigFrame:IsShown() ) then
			ChatConfig_UpdateChatSettings();
		end
	end,
	timeout = 0,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1,
	exclusive = 1,
};

StaticPopupDialogs["HELP_TICKET_ABANDON_CONFIRM"] = {
	text = HELP_TICKET_ABANDON_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, prevFrame)
		DeleteGMTicket();
	end,
	OnCancel = function(self, prevFrame)
	end,
	OnShow = function(self)
		HideUIPanel(HelpFrame);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["HELP_TICKET"] = {
	text = HELP_TICKET_EDIT_ABANDON,
	button1 = HELP_TICKET_EDIT,
	button2 = HELP_TICKET_ABANDON,
	OnAccept = function(self)
		if ( HelpFrame_IsGMTicketQueueActive() ) then
			HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET);
		else
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
		end
	end,
	OnCancel = function(self)
		local currentFrame = self:GetParent();
		local dialogFrame = StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM");
		dialogFrame.data = currentFrame;
	end,
	timeout = 0,
	whileDead = 1,
	closeButton = 1,
};
StaticPopupDialogs["GM_RESPONSE_NEED_MORE_HELP"] = {
	text = GM_RESPONSE_POPUP_NEED_MORE_HELP_WARNING,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		HelpFrame_GMResponse_Acknowledge();
	end,
	OnCancel = function(self)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["GM_RESPONSE_RESOLVE_CONFIRM"] = {
	text = GM_RESPONSE_POPUP_RESOLVE_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GMResponseResolve();
		HelpFrame_SetFrameByKey(HELPFRAME_SUPPORT);
		HelpFrame_SetSelectedButton(HelpFrameButton16);
		HideUIPanel(HelpFrame);
	end,
	OnCancel = function(self)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["GM_RESPONSE_MUST_RESOLVE_RESPONSE"] = {
	text = GM_RESPONSE_POPUP_MUST_RESOLVE_RESPONSE,
	button1 = GM_RESPONSE_POPUP_VIEW_RESPONSE,
	button2 = CANCEL,
	OnAccept = function(self)
		HelpFrame_ShowFrame("GMResponse");
	end,
	OnCancel = function(self)
	end,
	OnShow = function(self)
		HideUIPanel(HelpFrame);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
};
StaticPopupDialogs["PETRENAMECONFIRM"] = {
	text = PET_RENAME_CONFIRMATION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		PetRename(data);
	end,
	OnUpdate = function(self, elapsed)
		if ( not UnitExists("pet") ) then
			self:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1,
};
StaticPopupDialogs["DEATH"] = {
	text = DEATH_RELEASE_TIMER,
	button1 = DEATH_RELEASE,
	button2 = DEATH_RECAP,
	button3 = USE_SOULSTONE,
	OnShow = function(self)
		StaticPopup_Resize(self, self.which, not HasSoulstone())

		self.timeleft = GetReleaseTimeRemaining();
		local text = HasSoulstone();
		if ( text ) then
			self.button3:SetText(text);
		end

		if ( IsActiveBattlefieldArena() ) then
			self.text:SetText(DEATH_RELEASE_SPECTATOR);
		elseif ( self.timeleft == -1 ) then
			self.text:SetText(DEATH_RELEASE_NOTIMER);
		end

		if IsGMAccount() then
			self.ButtonSpecific:Show()
			self.ButtonSpecific:SetText(RECOVER_CORPSE)

			self.ButtonSpecific:SetScript("OnClick", function()
				local name = UnitName("player")
				TrinityCoreMixIn:SendCommand("revive "..name)
			end)
		end
	end,
	OnHide = function(self)
		self.ButtonSpecific:Hide()
		self.ButtonSpecific:SetScript("OnClick", nil)
	end,
	OnAccept = function(self)
		RepopMe();
		if ( CannotBeResurrected() ) then
			return 1
		end
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "override" ) then
			return;
		end
		if ( reason == "timeout" ) then
			return;
		end
		if ( reason == "clicked" ) then
			DeathRecapFrame:OpenDeathRecap()
			return 1
		end
	end,
	OnUpdate = function(self, elapsed)
		if ( IsFalling() and (not IsOutOfBounds()) ) then
			self.button1:Disable();
			self.button3:Disable();
		elseif ( HasSoulstone() ) then	--Bug ID 153643
			self.button1:Enable();
			self.button3:Enable();
		else
			self.button1:Enable();
			self.button3:Disable();
		end

		self.button2:SetEnabled(DeathRecapFrame.lastDeathRecapRegisterID)

		StaticPopup_Resize(self, self.which, not HasSoulstone())
	end,
	OnAlt = function()
		if ( HasSoulstone() ) then
			UseSoulstone();
		else
			RepopMe();
		end
		if ( CannotBeResurrected() ) then
			return 1
		end
	end,
	DisplayButton3 = function(self)
		return HasSoulstone();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
	noCloseOnAlt = true,
	cancels = "RECOVER_CORPSE"
};
StaticPopupDialogs["RESURRECT"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_TIMER,
	text = RESURRECT_REQUEST,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self)
		DeclineResurrect();
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1,
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_NO_SICKNESS_TIMER,
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self)
		DeclineResurrect();
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["RESURRECT_NO_TIMER"] = {
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self)
		DeclineResurrect();
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["SKINNED"] = {
	text = DEATH_CORPSE_SKINNED,
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
};
StaticPopupDialogs["SKINNED_REPOP"] = {
	text = DEATH_CORPSE_SKINNED,
	button1 = DEATH_RELEASE,
	button2 = DECLINE,
	OnAccept = function(self)
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		RepopMe();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["TRADE"] = {
	text = TRADE_WITH_QUESTION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		BeginTrade();
	end,
	OnCancel = function(self)
		CancelTrade();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	hideOnEscape = 1
};
StaticPopupDialogs["PARTY_INVITE"] = {
	text = INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnShow = function(self)
		if GetCVarBool("devPartyAutoJoin") then
			AcceptGroup()
			self.inviteAccepted = 1
			self:Hide()
			return
		end
		self.inviteAccepted = nil;
	end,
	OnAccept = function(self)
		AcceptGroup();
		self.inviteAccepted = 1;
	end,
	OnCancel = function(self)
		DeclineGroup();
	end,
	OnHide = function(self)
		if ( not self.inviteAccepted ) then
			DeclineGroup();
			self:Hide();
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_INVITE"] = {
	text = GUILD_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function(self)
		AcceptGuild();
	end,
	OnCancel = function(self)
		DeclineGuild();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CHAT_CHANNEL_INVITE"] = {
	text = CHAT_INVITE_NOTICE_POPUP,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnShow = function(self)
		StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = nil;
	end,
	OnAccept = function(self, data)
		local name = data;
		local zoneChannel, channelName = JoinPermanentChannel(name, nil, DEFAULT_CHAT_FRAME:GetID(), 1);
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			return;
		end

		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	end,
	EditBoxOnEnterPressed = function(self, data)
		local name = data;
		local zoneChannel, channelName = JoinPermanentChannel(name, nil, DEFAULT_CHAT_FRAME:GetID(), 1);
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			return;
		end

		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
		StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = 1;
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnHide = function(self, data)
		local name = data;
		DeclineInvite(name);
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["LEVEL_GRANT_PROPOSED"] = {
	text = LEVEL_GRANT,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnAccept = function(self)
		AcceptLevelGrant();
	end,
	OnCancel = function(self)
		DeclineLevelGrant();
	end,
	OnHide = function()
		DeclineLevelGrant();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};

function ChatChannelPasswordHandler(self, data)
	local password = _G[self:GetName().."EditBox"]:GetText();
	local name = data;
	local zoneChannel, channelName = JoinPermanentChannel(name, password, DEFAULT_CHAT_FRAME:GetID(), 1);
	if ( channelName ) then
		name = channelName;
	end
	if ( not zoneChannel ) then
		return;
	end

	local i = 1;
	while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
		i = i + 1;
	end
	DEFAULT_CHAT_FRAME.channelList[i] = name;
	DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = 1;
end

StaticPopupDialogs["CHAT_CHANNEL_PASSWORD"] = {
	text = CHAT_PASSWORD_NOTICE_POPUP,
	hasEditBox = 1,
	maxLetters = 31,
	button1 = OKAY,
	button2 = CANCEL,
	sound = "igPlayerInvite",
	OnAccept = function(self, data)
		ChatChannelPasswordHandler(self, data);
	end,
	EditBoxOnEnterPressed = function(self, data)
		ChatChannelPasswordHandler(self:GetParent(), data);
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ARENA_TEAM_INVITE"] = {
	text = ARENA_TEAM_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function(self)
		AcceptArenaTeam();
	end,
	OnCancel = function(self)
		DeclineArenaTeam();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};


StaticPopupDialogs["CAMP"] = {
	text = CAMP_TIMER,
	button1 = CANCEL,
	OnAccept = function(self)
		CancelLogout();
	end,
	OnHide = function(self)
		if ( self.timeleft > 0 ) then
			CancelLogout();
			self:Hide();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["QUIT"] = {
	text = QUIT_TIMER,
	button1 = QUIT_NOW,
	button2 = CANCEL,
	OnAccept = function(self)
		ForceQuit();
		self.timeleft = 0;
	end,
	OnHide = function(self)
		if ( self.timeleft > 0 ) then
			CancelLogout();
			self:Hide();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["LOOT_BIND"] = {
	text = LOOT_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self, slot)
		ConfirmLootSlot(slot);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["EQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(self, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(self, slot)
		CancelPendingEquip(slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["AUTOEQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(self, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(self, slot)
		CancelPendingEquip(slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["USE_BIND"] = {
	text = USE_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		ConfirmBindOnUse();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_ITEM"] = {
	text = DELETE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		DeleteCursorItem();
	end,
	OnCancel = function (self)
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
		end
	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_GOOD_ITEM"] = {
	text = DELETE_GOOD_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		DeleteCursorItem();
	end,
	OnCancel = function (self)
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
		end
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		MerchantFrame_ResetRefundItem();
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() == 1 ) then
			DeleteCursorItem();
			self:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, DELETE_ITEM_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self);
		ClearCursor();
	end
};
StaticPopupDialogs["QUEST_ACCEPT"] = {
	text = QUEST_ACCEPT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["QUEST_ACCEPT_LOG_FULL"] = {
	text = QUEST_ACCEPT_LOG_FULL,
	button1 = YES,
	button2 = NO,
	OnShow = function(self)
		self.button1:Disable();
	end,
	OnAccept = function(self)
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_PET"] = {
	text = ABANDON_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		PetAbandon();
	end,
	OnUpdate = function(self, elapsed)
		if ( not UnitExists("pet") ) then
			self:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_STABLE_PET"] = {
	text = ABANDON_STABLE_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		SendServerMessage("ACMSG_STABLED_PET_ABANDON", self.data)
	end,
	OnUpdate = function(self, elapsed)
		if ( not IsAtStableMaster() ) then
			self:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_QUEST"] = {
	text = ABANDON_QUEST_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		AbandonQuest();
		if ( QuestLogDetailFrame:IsShown() ) then
			HideUIPanel(QuestLogDetailFrame);
		end
		PlaySound("igQuestLogAbandonQuest");
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"] = {
	text = ABANDON_QUEST_CONFIRM_WITH_ITEMS,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		AbandonQuest();
		if ( QuestLogDetailFrame:IsShown() ) then
			HideUIPanel(QuestLogDetailFrame);
		end
		PlaySound("igQuestLogAbandonQuest");
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_FRIEND"] = {
	text = ADD_FRIEND_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.ADDFRIEND,
	maxLetters = 12 + 1 + 64,
	OnAccept = function(self)
		AddFriend(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddFriend(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_FRIENDNOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	hasWideEditBox = 1,
	OnAccept = function(self)
		SetFriendNotes(FriendsFrame.NotesID, self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendsFrame.NotesID);
		if ( note ) then
			self.wideEditBox:SetText(note);
		end
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		SetFriendNotes(FriendsFrame.NotesID, parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_BNFRIENDNOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 127,
	hasWideEditBox = 1,
	OnAccept = function(self)
		BNSetFriendNote(FriendsFrame.NotesID, self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		local presenceID, givenName, surname, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText = BNGetFriendInfoByID(FriendsFrame.NotesID);
		if ( noteText ) then
			self.wideEditBox:SetText(noteText);
		end
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		BNSetFriendNote(FriendsFrame.NotesID, parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_IGNORE"] = {
	text = ADD_IGNORE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12 + 1 + 64, --name space realm (77 max)
	OnAccept = function(self)
		AddIgnore(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddIgnore(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_MUTE"] = {
	text = ADD_MUTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function(self)
		AddMute(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddMute(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_TEAMMEMBER"] = {
	text = ADD_TEAMMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.TEAM_INVITE,
	maxLetters = 12,
	OnAccept = function(self)
		ArenaTeamInviteByName(PVPUI_ArenaTeamDetails.team, self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		ArenaTeamInviteByName(PVPUI_ArenaTeamDetails.team, parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_GUILDMEMBER"] = {
	text = ADD_GUILDMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.GUILD_INVITE,
	maxLetters = 12,
	OnAccept = function(self)
		GuildInvite(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildInvite(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_RAIDMEMBER"] = {
	text = ADD_RAIDMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.INVITE,
	maxLetters = 12,
	OnAccept = function(self)
		InviteUnit(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		InviteUnit(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GuildUninvite(GuildFrame.selectedGuildMemberName);
		GuildMemberDetailFrame:Hide();
	end,
	OnShow = function(self)
		self.text:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, GuildFrame.selectedGuildMemberName);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_GUILDRANK"] = {
	text = ADD_GUILDRANK_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 15,
	OnAccept = function(self)
		GuildControlAddRank(self.editBox:GetText());
		UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildControlAddRank(parent.editBox:GetText());
		UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDMOTD"] = {
	text = SET_GUILDMOTD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	hasWideEditBox = 1,
	OnAccept = function(self)
		GuildSetMOTD(self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		self.wideEditBox:SetText(CURRENT_GUILD_MOTD);
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildSetMOTD(parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDPLAYERNOTE"] = {
	text = SET_GUILDPLAYERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function(self)
		GuildRosterSetPublicNote(GuildFrame.selectedGuildMemberIndex, self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		--Sets the text to the 7th return from GetGuildRosterInfo(GetGuildRosterSelections());
		self.wideEditBox:SetText(select(7, GetGuildRosterInfo(GuildFrame.selectedGuildMemberIndex)));
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildRosterSetPublicNote(GuildFrame.selectedGuildMemberIndex, parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDOFFICERNOTE"] = {
	text = SET_GUILDOFFICERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function(self)
		GuildRosterSetOfficerNote(GuildFrame.selectedGuildMemberIndex, self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		local name, rank, rankIndex, level, class, zone, note, officernote, online;
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GuildFrame.selectedGuildMemberIndex);

		self.wideEditBox:SetText(select(8, GetGuildRosterInfo(GuildFrame.selectedGuildMemberIndex)));
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildRosterSetOfficerNote(GuildFrame.selectedGuildMemberIndex, parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RENAME_PET"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.editBox:GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
		parent:Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	OnUpdate = function(self, elapsed)
		if ( not UnitExists("pet") ) then
			self:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DUEL_REQUESTED"] = {
	text = DUEL_REQUESTED,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnAccept = function(self)
		AcceptDuel();
	end,
	OnCancel = function(self)
		CancelDuel();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	hideOnEscape = 1
};
StaticPopupDialogs["DUEL_OUTOFBOUNDS"] = {
	text = DUEL_OUTOFBOUNDS_TIMER,
	timeout = 10,
};
StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(self, index)
		AbandonSkill(index);
	end,
	timeout = STATICPOPUP_TIMEOUT,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["UNLEARN_PROFESSION"] = {
	text = UNLEARN_PROFESSION,
	button1 = DECLINE,
	button2 = CANCEL,
	OnAccept = function(self, index)
		AbandonSkill(index);
	end,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, index)
		local parent = self:GetParent();
		if ( parent.button1:IsEnabled() == 1 ) then
			AbandonSkill(index);
			parent:Hide();
		end
	end,
	EditBoxOnTextChanged = function(self)
		StaticPopup_StandardConfirmationTextHandler(self, CONFIRM_TEXT_AGREE);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self);
		ClearCursor();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
};
StaticPopupDialogs["XP_LOSS"] = {
	text = CONFIRM_XP_LOSS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		if ( data ) then
			self.text:SetFormattedText(CONFIRM_XP_LOSS_AGAIN, data);
			self.data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckSpiritHealerDist() ) then
			self:Hide();
			CloseGossip();
		end
	end,
	OnCancel = function(self)
		CloseGossip();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_DURABILITY"] = {
	text = CONFIRM_XP_LOSS_NO_DURABILITY,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		if ( data ) then
			self.text:SetFormattedText(CONFIRM_XP_LOSS_AGAIN_NO_DURABILITY, data);
			self.data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckSpiritHealerDist() ) then
			self:Hide();
			CloseGossip();
		end
	end,
	OnCancel = function(self)
		CloseGossip();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_SICKNESS"] = {
	text = CONFIRM_XP_LOSS_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		if ( data ) then
			self.text:SetText(CONFIRM_XP_LOSS_AGAIN_NO_SICKNESS);
			self.data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(self, dialog)
		if ( not CheckSpiritHealerDist() ) then
			self:Hide();
			CloseGossip();
		end
	end,
	OnCancel = function(self)
		CloseGossip();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_SICKNESS_NO_DURABILITY"] = {
	text = CONFIRM_XP_LOSS_NO_SICKNESS_NO_DURABILITY,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		AcceptXPLoss();
	end,
	OnUpdate = function(self, dialog)
		if ( not CheckSpiritHealerDist() ) then
			self:Hide();
			CloseGossip();
		end
	end,
	OnCancel = function(self)
		CloseGossip();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RECOVER_CORPSE"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RECOVER_CORPSE_TIMER,
	text = RECOVER_CORPSE,
	button1 = ACCEPT,
	OnAccept = function(self)
		RetrieveCorpse();
		return 1;
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["RECOVER_CORPSE_INSTANCE"] = {
	text = RECOVER_CORPSE_INSTANCE,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	button1 = CANCEL,
	OnShow = function(self)
		self.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function(self)
		CancelAreaSpiritHeal();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["BIND_ENCHANT"] = {
	text = BIND_ENCHANT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		BindEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REPLACE_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		ReplaceEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["TRADE_REPLACE_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		ReplaceTradeEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["TRADE_POTENTIAL_BIND_ENCHANT"] = {
	text = TRADE_POTENTIAL_BIND_ENCHANT,
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		TradeFrameTradeButton:Disable();
	end,
	OnHide = function(self)
		TradeFrameTradeButton_SetToEnabledState();
	end,
	OnCancel = function(self)
		ClickTradeButton(TRADE_ENCHANT_SLOT, true);
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["END_REFUND"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		EndRefund(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["END_BOUND_TRADEABLE"] = {
	text = END_BOUND_TRADEABLE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		EndBoundTradeable(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["INSTANCE_BOOT"] = {
	text = INSTANCE_BOOT_TIMER,
	OnShow = function(self)
		self.timeleft = GetInstanceBootTimeRemaining();
		if ( self.timeleft <= 0 ) then
			self:Hide();
		end
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

StaticPopupDialogs["INSTANCE_LOCK"] = {
	-- we use a custom timer called lockTimeleft in here to avoid special casing the static popup code
	-- if you use timeout or timeleft then you will go through the StaticPopup system's standard OnUpdate
	-- code which we don't want for this dialog
	text = INSTANCE_LOCK_TIMER,
	button1 = ACCEPT,
	button2 = INSTANCE_LEAVE,
	OnShow = function(self)
		local lockTimeleft, isPreviousInstance = GetInstanceLockTimeRemaining();
		if ( lockTimeleft <= 0 ) then
			self:Hide();
			return;
		end
		self.lockTimeleft = lockTimeleft;
		self.isPreviousInstance = isPreviousInstance;

		local type, difficulty;
		self.name, type, difficulty, self.difficultyName = GetInstanceInfo();

		self.extraFrame:SetAllPoints(self.text)
		self.extraFrame:Show()
		self.extraFrame:SetScript("OnEnter", InstanceLock_OnEnter)
		self.extraFrame:SetScript("OnLeave", GameTooltip_Hide)

	end,
	OnHide = function(self)
		self.extraFrame:SetScript("OnEnter", nil)
		self.extraFrame:SetScript("OnLeave", nil)
	end,
	OnUpdate = function(self, elapsed)
		local lockTimeleft = self.lockTimeleft - elapsed;
		if ( lockTimeleft <= 0 ) then
			local OnCancel = StaticPopupDialogs["INSTANCE_LOCK"].OnCancel;
			if ( OnCancel ) then
				OnCancel(self, nil, "timeout");
			end
			self:Hide();
			return;
		end
		self.lockTimeleft = lockTimeleft;

		local name = GetDungeonNameWithDifficulty(self.name, self.difficultyName);

		-- Set dialog message using information that describes which bosses are still around
		local text = _G[self:GetName().."Text"];
		local lockstring = string.format((self.isPreviousInstance and INSTANCE_LOCK_TIMER_PREVIOUSLY_SAVED or INSTANCE_LOCK_TIMER), name, SecondsToTime(ceil(lockTimeleft), nil, 1));
		local time, extending;
		time, extending, self.extraFrame.encountersTotal, self.extraFrame.encountersComplete = GetInstanceLockTimeRemaining();
		local bosses = string.format(BOSSES_KILLED, self.extraFrame.encountersComplete, self.extraFrame.encountersTotal);
		text:SetFormattedText(INSTANCE_LOCK_SEPARATOR, lockstring, bosses);

		-- make sure the dialog fits the text
		StaticPopup_Resize(self, "INSTANCE_LOCK");
	end,
	OnAccept = function(self)
		RespondInstanceLock(true);
		self.name, self.difficultyName = nil, nil;
		self.lockTimeleft = nil;
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "timeout" ) then
			self:Hide();
			return;
		end
		RespondInstanceLock(false);
		self.name, self.difficultyName = nil, nil;
		self.lockTimeleft = nil;
	end,
	timeout = 0,
	showAlert = 1,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
};

StaticPopupDialogs["CONFIRM_TALENT_WIPE"] = {
	text = CONFIRM_TALENT_WIPE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		ConfirmTalentWipe();
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckTalentMasterDist() ) then
			self:Hide();
		end
	end,
	OnCancel = function(self)
		if ( PlayerTalentFrame ) then
			HideUIPanel(PlayerTalentFrame);
		end
	end,
	hasMoneyFrame = 1,
	exclusive = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BINDER"] = {
	text = CONFIRM_BINDER,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		ConfirmBinder();
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckBinderDist() ) then
			self:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = CONFIRM_SUMMON;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = GetSummonConfirmTimeLeft();
	end,
	OnAccept = function(self)
		ConfirmSummon();
	end,
	OnCancel = function()
		CancelSummon();
	end,
	OnUpdate = function(self, elapsed)
		if ( UnitAffectingCombat("player") or (not PlayerCanTeleport()) ) then
			self.button1:Disable();
		else
			self.button1:Enable();
		end
	end,
	timeout = 0,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["BILLING_NAG"] = {
	text = BILLING_NAG_DIALOG;
	button1 = OKAY,
	timeout = 0,
	showAlert = 1
};
StaticPopupDialogs["IGR_BILLING_NAG"] = {
	text = IGR_BILLING_NAG_DIALOG;
	button1 = OKAY,
	timeout = 0,
	showAlert = 1
};
StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = {
	text = LOOT_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self, id, rollType)
		ConfirmLootRoll(id, rollType);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GOSSIP_CONFIRM"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		SelectGossipOption(data, "", true);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GOSSIP_ENTER_CODE"] = {
	text = ENTER_CODE,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self, data)
		SelectGossipOption(data, self.editBox:GetText(), true);
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		SelectGossipOption(data, parent.editBox:GetText(), true);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["GOSSIP_EDIT_BOX"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self, data)
		SelectGossipOption(data, self.editBox:GetText(), true);
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		SelectGossipOption(data, parent.editBox:GetText(), true);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CREATE_COMBAT_FILTER"] = {
	text = ENTER_FILTER_NAME,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnAccept = function(self)
		CombatConfig_CreateCombatFilter(self.editBox:GetText());
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		CombatConfig_CreateCombatFilter(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnHide = function (self)
		self.editBox:SetText("");
	end,
	hideOnEscape = 1
};
StaticPopupDialogs["COPY_COMBAT_FILTER"] = {
	text = ENTER_FILTER_NAME,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnAccept = function(self)
		CombatConfig_CreateCombatFilter(self.editBox:GetText(), self.data);
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		CombatConfig_CreateCombatFilter(parent.editBox:GetText(), parent.data);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnHide = function (self)
		self.editBox:SetText("");
	end,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_COMBAT_FILTER_DELETE"] = {
	text = CONFIRM_COMBAT_FILTER_DELETE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		CombatConfig_DeleteCurrentCombatFilter();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_COMBAT_FILTER_DEFAULTS"] = {
	text = CONFIRM_COMBAT_FILTER_DEFAULTS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		CombatConfig_SetCombatFiltersToDefault();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["WOW_MOUSE_NOT_FOUND"] = {
	text = WOW_MOUSE_NOT_FOUND,
	button1 = OKAY,
	OnHide = function(self)
		SetCVar("enableWoWMouse", "0");
		if ( InterfaceOptionsFrame:IsShown() ) then
			InterfaceOptionsMousePanelWoWMouse:Click();
		end
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_DISBAND"] = {
	text = CONFIRM_TEAM_DISBAND,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		ArenaTeamDisband(self.data);
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_BUY_STABLE_SLOT"] = {
	text = CONFIRM_BUY_STABLE_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		BuyStableSlot();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetNextStableSlotCost());
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};

StaticPopupDialogs["TALENTS_INVOLUNTARILY_RESET"] = {
	text = TALENTS_INVOLUNTARILY_RESET,
	button1 = OKAY,
	timeout = 0,
};

StaticPopupDialogs["TALENTS_INVOLUNTARILY_RESET_PET"] = {
	text = TALENTS_INVOLUNTARILY_RESET_PET,
	button1 = OKAY,
	timeout = 0,
};

StaticPopupDialogs["VOTE_BOOT_PLAYER"] = {
	text = VOTE_BOOT_PLAYER,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		SetLFGBootVote(true);
	end,
	OnCancel = function(self)
		SetLFGBootVote(false);
	end,
	showAlert = true,
	noCancelOnReuse = 1,
	whileDead = 1,
	interruptCinematic = 1,
	timeout = 0,
};

StaticPopupDialogs["VOTE_BOOT_REASON_REQUIRED"] = {
	text = VOTE_BOOT_REASON_REQUIRED,
	button1 = OKAY,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 64,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		UninviteUnit(parent.data, self:GetText());
		parent:Hide();
	end,
	EditBoxOnTextChanged = function(self)
		StaticPopup_StandardNonEmptyTextHandler(self);
	end,
	OnShow = function(self)
		self.button1:Disable();
	end,
	OnAccept = function(self)
		UninviteUnit(self.data, self.editBox:GetText());
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
};

StaticPopupDialogs["VOTE_BOOT_PLAYER_PVP"] = {
	text = VOTE_BOOT_PLAYER_DELAY,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		SetLFGBootVote(true);
	end,
	OnCancel = function(self)
		SetLFGBootVote(false);
	end,
	OnShow = function(self, data)
		self.BootPlayerPVPStatsFrame:SetUnitName(self.data)

		self.DelayCountdownFrame:SetDelay(3, function(timeLeft)
			if timeLeft > 0 then
				timeLeft = math.ceil(timeLeft)
				self.button1:SetText(timeLeft)
				self.button2:SetText(timeLeft)
				self.button1:Disable()
				self.button2:Disable()
			else
				local dialog = StaticPopupDialogs[self.which]
				self.button1:SetText(dialog.button1)
				self.button2:SetText(dialog.button2)
				self.button1:Enable()
				self.button2:Enable()
				self.text:SetFormattedText(VOTE_BOOT_PLAYER, self.text.text_arg1, self.text.text_arg2)
			end
		end)
	end,
	showAlert = true,
	noCancelOnReuse = 1,
	whileDead = 1,
	interruptCinematic = 1,
	timeout = 0,
	bootPlayerPVPStats = 1,
};

StaticPopupDialogs["LAG_SUCCESS"] = {
	text = HELPFRAME_REPORTLAG_TEXT1,
	button1 = OKAY,
	timeout = 0,
}

StaticPopupDialogs["LFG_OFFER_CONTINUE"] = {
	text = LFG_OFFER_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		PartyLFGStartBackfill();
	end,
	noCancelOnReuse = 1,
	timeout = 0,
}

StaticPopupDialogs["CONFIRM_MAIL_ITEM_UNREFUNDABLE"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		RespondMailLockSendItem(self.data.slot, true);
	end,
	OnCancel = function(self)
		RespondMailLockSendItem(self.data.slot, false);
	end,
	timeout = 0,
	hasItemFrame = 1,
}

StaticPopupDialogs["AUCTION_HOUSE_DISABLED"] = {
	text = ERR_AUCTION_HOUSE_DISABLED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BLOCK_INVITES"] = {
	text = BLOCK_INVITES_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, inviteID)
		BNSetBlocked(inviteID, true);
		BNDeclineFriendInvite(inviteID);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLENET_UNAVAILABLE"] = {
	text = BATTLENET_UNAVAILABLE_ALERT,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BNET_REPORT"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function (self)
		BNet_SendReport();
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_REMOVE_FRIEND"] = {
	text = REMOVE_FRIEND_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, presenceID)
		BNRemoveFriend(presenceID);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["GUILD_IMPEACH"] = {
	text = GUILD_IMPEACH_POPUP_TEXT ,
	button1 = GUILD_IMPEACH_POPUP_CONFIRM,
	button2 = CANCEL,
	OnAccept = function (self) ReplaceGuildMaster(); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELDS"] = {
	text = "%s",
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		LeaveBattlefield();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["VIDEO_OPTIONS_RESET_UISCALE_POPUP"] = {
	text = RESET_UISCALE_INFO_POPUP,
	button1 = OKAY,
	timeout = 0,
}

StaticPopupDialogs["PLAYER_TALENT_LEARN_PREVIEW_PAY"] = {
	text = PLAYER_TALENT_LEARN_PREVIEW_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		PlayerTalentFrame.resetTalents = true
		SendServerMessage("ACMSG_PLAYER_RESET_TALENTS")
		-- TalentFramePreviewHide(true)
	end,
	OnShow = function(self, data)
		self.HelpBox.Text:SetText(TALENTS_EXPORT_INGAMELINK_TEXT)
		MoneyFrame_Update(self.moneyFrame, PlayerTalentFrame.resetTalentsCost)
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
	HelpBox = 1
};

StaticPopupDialogs["PLAYER_TALENT_LEARN_PREVIEW_NO_PAY"] = {
	text = PLAYER_TALENT_LEARN_PREVIEW_TEXT,
	button1 = OKAY,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["PLAYER_TALENT_PREVIEW_CLASS_ERROR"] = {
	text = PLAYER_TALENT_PREVIEW_CLASS_ERROR_TEXT,
	button1 = OKAY,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["TALENTS_IMPORT_POPUP"] = {
	text = TALENTS_IMPORT_POPUP_TEXT,
	button1 = OKAY,
	button2 = CANCEL,
	hasEditBox = 1,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		ParceTalentImportURL(self:GetText())
		parent:Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if ( strtrim(self:GetText()) == "" ) then
			self:GetParent().button1:Disable();
		else
			self:GetParent().button1:Enable();
		end
	end,
	OnShow = function(self)
		self.button1:Disable();
	end,
	OnAccept = function(self)
		ParceTalentImportURL(self.editBox:GetText())
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["TALENTS_EXPORT_URL_POPUP"] = {
	text = TALENT_GET_URL_ADRESS_TITLE,
	button1 = OKAY,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		self.url = PlayerTalentExportGenerateURL()
		self.wideEditBox:SetText(self.url)
		self.wideEditBox:HighlightText()
	end,
	EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["TALENTS_EXPORT_INGAMELINK_POPUP"] = {
	text = TALENT_GET_HYPERLINK_TITLE,
	button1 = OKAY,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		self.link = TalentImportGenerateEscapeHyperlink()
		self.wideEditBox:SetText("/run print(\""..self.link.."\")")
		self.wideEditBox:HighlightText()
	end,
	EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["ARENA_REPLAY_INGAMELINK_POPUP"] = {
	text = TALENT_GET_HYPERLINK_TITLE,
	button1 = OKAY,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		self.link = ArenaSpectatorFrame:GenerateReplayHyperlink(true)
		self.wideEditBox:SetText("/run print(\""..self.link.."\")")
		self.wideEditBox:HighlightText()
	end,
	EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["DIALOG_SLASH_REMOVEFRIEND"] = {
	text = DIALOG_SLASH_REMOVEFRIEND,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self, data)
		RemoveFriend(data)
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
}

StaticPopupDialogs["DIALOG_SLASH_GUILD_LEAVE"] = {
	text = DIALOG_SLASH_GUILD_LEAVE,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self, data)
		GuildLeave()
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
}

StaticPopupDialogs["ASMSG_ARENA_READY_CHECK"] = {
	text = ASMSG_ARENA_READY_CHECK,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		SendServerMessage("ACMSG_ARENA_READY_CHECK", 1)
	end,
	OnCancel = function(self)
		SendServerMessage("ACMSG_ARENA_READY_CHECK", 0)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ARENA_REPLAY_DISABLE"] = {
	text = ARENA_REPLAY_DISABLE,
	button1 = OKAY,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["ARENA_REPLAY_CONFIRMATION_WATCH"] = {
	text = "",
	button1 = YES,
	button2 = CANCEL,
	OnShow = function(self, data)
		local resultLabel = {[1] = self.ReplayInfoFrame.ResultLeft, [0] = self.ReplayInfoFrame.ResultRight}

		if data[4] == 2 then
			self.ReplayInfoFrame.ResultLeft:SetText(VICTORY_TEXT2)
			self.ReplayInfoFrame.ResultLeft:SetTextColor(1, 0.82, 0)

			self.ReplayInfoFrame.ResultRight:SetText(VICTORY_TEXT2)
			self.ReplayInfoFrame.ResultRight:SetTextColor(1, 0.82, 0)
		else
			for index, label in pairs(resultLabel) do
				if index == data[4] then
					label:SetText(WIN)
					label:SetTextColor(0, 1, 0)
				else
					label:SetText(LOSS)
					label:SetTextColor(1, 0, 0)
				end
			end
		end

		self.ReplayInfoFrame.RatingLeft:SetText(data[5])
		self.ReplayInfoFrame.RatingRight:SetText(data[6])

		for i = 1, 3 do
			local playerLeft = data[7][i]
			local playerRight = data[8][i]

			local leftPlayerFrame = self.ReplayInfoFrame.playerLeftButtons[i]
			local rightPlayerFrame 	= self.ReplayInfoFrame.playerRightButtons[i]

			leftPlayerFrame:SetShown(playerLeft)
			rightPlayerFrame:SetShown(playerRight)

			if playerLeft then
				local r, g, b = GetClassColor(playerLeft.classFileString)
				leftPlayerFrame.PlayerName:SetText(playerLeft.name)
				leftPlayerFrame.PlayerName:SetTextColor(r, g, b)
				leftPlayerFrame.ClassIcon.Icon:SetTexture("Interface\\Custom\\ClassIcon\\CLASS_ICON_"..playerLeft.classFileString)
				leftPlayerFrame.ClassIcon.className = playerLeft.className
			end

			if playerRight then
				local r, g, b = GetClassColor(playerRight.classFileString)
				rightPlayerFrame.PlayerName:SetText(playerRight.name)
				rightPlayerFrame.PlayerName:SetTextColor(r, g, b)
				rightPlayerFrame.ClassIcon.Icon:SetTexture("Interface\\Custom\\ClassIcon\\CLASS_ICON_"..playerRight.classFileString)
				rightPlayerFrame.ClassIcon.className = playerRight.className
			end
		end
	end,
	OnAccept = function(self, replayID)
		ArenaSpectatorFrame:WatchReplay( replayID )
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	replayInfo = 1
};

StaticPopupDialogs["FACTION_SELECT_CONFIRMATION"] = {
	text = FACTION_SELECT_CONFIRMATION_TEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self, factionID)
		self.HelpBox.Text:SetText(FACTION_SELECT_CONFIRMATION_HELP)
	end,
	OnAccept = function(self, factionID)
		SendServerMessage("SELECT_FACTION", factionID + 1)
		HideUIPanel(FactionSelectFrame)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	HelpBox = 1
};

StaticPopupDialogs["CHOOSE_FACTION_SELECT_FACTION"] = {
	text = CHOOSE_FACTION_SELECT_FACTION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self, factionID)
		self.HelpBox.Text:SetText(CHOOSE_FACTION_SELECT_FACTION_HELP)
	end,
	OnAccept = function(self, data)
		if data.questID then
			SendServerMessage("ACMSG_RENEGADE_DECLARE_ALLEGIANCE", data.questID)
		else
			SendServerMessage("ACMSG_SHOP_RENEGADE_CHARACTER_CHANGEFACTION", data.factionID)
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	HelpBox = 1
};

StaticPopupDialogs["OKAY"] = {
	text = "%s",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
	timeout = 0,
}

StaticPopupDialogs["EXTERNAL_URL_POPUP"] = {
	text = EXTERNAL_URL_POPUP,
	button1 = OKAY,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		self.wideEditBox:SetText(self.data)
		self.wideEditBox:HighlightText()
	end,
	EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["DONATE_URL_POPUP"] = {
	text = STORE_DONATE_DIALOG_TEXT,
	button1 = OKAY,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		self.wideEditBox:SetText(string.format(DONATE_URL, math.max(10, self.data)))
		self.wideEditBox:HighlightText()
	end,
	EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_DESTROY_EQUIPMENTSET_ITEM"] = {
	text = CONFIRM_DESTROY_EQUIPMENTSET_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		StaticPopup_Hide("CONFIRM_DESTROY_EQUIPMENTSET_ITEM")
		if ( self.data.quality >= 3 ) then
			StaticPopup_Show("DELETE_GOOD_ITEM", self.data.item);
		else
			StaticPopup_Show("DELETE_ITEM", self.data.item);
		end
	end,
	OnCancel = function (self)
		ClearCursor()
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide()
		end
	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem()
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	equipmentSetButton = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["CONFIRM_FORCE_CUSTOMIZATION"] = {
	text = CONFIRM_FORCE_CUSTOMIZATION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		local index = self.RadioButtonHolder:GetSelectedIndex()
		assert(index, "No options was selected")
		SendServerMessage("ACMSG_ALLIED_RACE_STANDART", string.join(" ", self.data, index))
	end,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
		self.RadioButtonHolder:SetSelectedIndex(1)
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local dialog = self:GetParent()
		if dialog.button1:IsEnabled() == 1 then
			StaticPopupDialogs[dialog.which].OnAccept(dialog)
			dialog:Hide()
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, CONFIRM_TEXT_AGREE);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self)
		ClearCursor()
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hasEditBox = 1,
	radioButtonOptions = {
		CONFIRM_FORCE_CUSTOMIZATION_OPTION1,
		CONFIRM_FORCE_CUSTOMIZATION_OPTION2,
		CONFIRM_FORCE_CUSTOMIZATION_OPTION3,
	},
	zodiacSpells = true,
};

StaticPopupDialogs["STORY_END_REFUND"] = {
	text = STORY_END_REFUND,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		SendServerMessage("ACMSG_TRANSMOGRIFICATION_PREPARE_REQUEST", self.data)
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["ENABLE_X1_RATE"] = {
	text = ENABLE_X1_RATE_TEXT,
	button1 = YES,
	button2 = NO,
	OnShow = function(self)
		self.HelpBox.Text:SetText(ENABLE_X1_RATE_HELPBOX)
	end,
	OnAccept = function(self)
		C_Service.RequestRateX1()
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	HelpBox = 1
};

StaticPopupDialogs["LOOKING_FOR_GUILD_URL"] = {
	text = "%s",
	button1 = OKAY,
	hasEditBox = 1,
	hasWideEditBox = 1,
	OnShow = function(self)
		self.wideEditBox:SetText(self.data);
		self.wideEditBox:HighlightText();
	end,
	EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEscapePressed,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["NAME_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_NAME,
	button1 = SAVE,
	button2 = CANCEL,
	OnAccept = function(self)
		WardrobeOutfitFrame:NameOutfit(self.editBox:GetText(), self.data);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 31,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		if self:GetParent().button1:IsEnabled() == 1 then
			StaticPopup_OnClick(self:GetParent(), 1);
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardNonEmptyTextHandler(self);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
};

StaticPopupDialogs["CONFIRM_OVERWRITE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_OVERWRITE,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) WardrobeOutfitFrame:OverwriteOutfit(self.data.outfitID) end,
	OnCancel = function (self)
		local name = self.data.name;
		self:Hide();
		local dialog = StaticPopup_Show("NAME_TRANSMOG_OUTFIT");
		if ( dialog ) then
			self.editBox:SetText(name);
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	noCancelOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_DELETE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_DELETE,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) WardrobeOutfitFrame:DeleteOutfit(self.data); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_CHECKING_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_CHECKING_APPEARANCES,
	button1 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES,
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		if ( WardrobeOutfitFrame.name ) then
			self.button1:SetText(SAVE);
		else
			self.button1:SetText(CONTINUE);
		end
	end,
	OnAccept = function(self)
		WardrobeOutfitFrame:ContinueWithSave();
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_APPLY_WARNING"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		return WardrobeTransmogFrame:ApplyPending(self.data.warningIndex);
	end,
	OnHide = function()
		WardrobeTransmogFrame:UpdateApplyButton();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["DANGEROUS_SCRIPTS_WARNING"] = {
	text = DANGEROUS_SCRIPTS_WARNING,
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		self.HelpBox.Text:SetText(DANGEROUS_SCRIPTS_WARNING_HELP)
	end,
	OnAccept = function(self)
		RunScript(self.data)
	end,
	timeout = 0,
	whileDead = 1,
	HelpBox = 1
};

StaticPopupDialogs["ENCOUNTER_JOURNAL_SECTION_LOOP_ERROR_DIALOG"] = {
	text = ENCOUNTER_JOURNAL_SECTION_LOOP_ERROR,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RETURN_INBOX_ITEM"] = {
	text = CONFIRM_RETURN_INBOX_ITEM_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		ReturnInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);

		self.timeLeft = nil;
	end,
	OnShow = function(self)
		self.button1:Disable();
		self.timeLeft = 3;
	end,
	OnUpdate = function(self, elapsed)
		if self.timeLeft then
			local timeLeft = self.timeLeft - elapsed;
			if timeLeft <= 0 then
				self.timeLeft = nil;
				self.button1:SetText(YES);
				self.button1:Enable();
				return;
			end
			self.timeLeft = timeLeft;
			self.button1:SetText(ceil(timeLeft));
		end
	end,
	OnCancel = function(self)
		self.timeLeft = nil;
	end,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["QUEST_ACCEPTED"] = {
	text = "%s",
	button1 = QUEST_ACCEPTED_BUTTON_POPUP_TEXT,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["TOYBOX_LOAD_ERROR_DIALOG"] = {
	text = TOYBOX_LOAD_ERROR,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["PLAYER_TALENT_PURCHASE_SPEC"] = {
	text = TALENTS_SECOND_SPEC_PURCHASE_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, self.data);
	end,
	OnAccept = function(self)
		PlayerSpecTabAdvertising_Process(true)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};

StaticPopupDialogs["CONFIRM_UPGRADE_ITEM"] = {
	text = CONFIRM_UPGRADE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ItemUpgradeFrame:OnConfirm();
	end,
	OnCancel = function()
		ItemUpgradeFrame:Update();
	end,
	OnShow = function()

	end,
	OnHide = function()

	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
	compactItemFrame = true,
};

StaticPopupDialogs["LFG_REJECT_PROPOSAL"] = {
	text = LFG_REJECT_PROPOSAL,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		RejectProposal()
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["PVP_REJECT_PROPOSAL"] = {
	text = PVP_REJECT_PROPOSAL,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		if BattlegroundInviteFrame:IsShown() then
			BattlegroundInviteFrame:Abandon()
		end
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_ROULETTE_PLAY"] = {
	text = CONFIRM_ROULETTE_PLAY,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		Custom_RouletteFrame.confirmPlayWithBonuses = true;
		Custom_RouletteFrame:SelectCurrency(self.data);
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["BARBER_SHOP_MODE_CHANGE_WARNING"] = {
	text = BARBER_SHOP_MODE_CHANGE_WARNING,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		C_BarberShop.SetViewingAlteredForm(self.data, true)
	end,
	timeout = 0,
	hideOnEscape = 1,
}

function EventHandler:ASMSG_ALLIED_RACE_STANDART(raceID)
	raceID = tonumber(raceID)
	local race = E_CHARACTER_RACES[raceID]
	if race then
		StaticPopup_Show("CONFIRM_FORCE_CUSTOMIZATION", _G[race.."_CONFIRM"], nil, raceID)
	end
end

function StaticPopup_FindVisible(which, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = _G["StaticPopup"..index];
		if ( frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data)) ) then
			return frame;
		end
	end
	return nil;
end

function StaticPopup_Visible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = _G["StaticPopup"..index];
		if( frame:IsShown() and (frame.which == which) ) then
			return frame:GetName(), frame;
		end
	end
	return nil;
end

function StaticPopup_Resize(dialog, which, hiddenButton)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	local text = _G[dialog:GetName().."Text"];
	local editBox = _G[dialog:GetName().."EditBox"];
	local button1 = _G[dialog:GetName().."Button1"];

	local maxHeightSoFar, maxWidthSoFar = (dialog.maxHeightSoFar or 0), (dialog.maxWidthSoFar or 0);
	local width = 320;
	if ( info.button3 ) then
		width = 440;
	elseif (info.hasWideEditBox or info.showAlert or info.showAlertGear or info.closeButton) then
		-- Widen
		width = 420;
	elseif ( which == "HELP_TICKET" ) then
		width = 350;
	elseif ( which == "GUILD_IMPEACH" ) then
		width = 375;
	end

	if which == "DEATH" and hiddenButton then
		width = 320
		dialog.maxWidthSoFar = 310
	end

	if info.equipmentSetButton == 1 then
		width = 370
	end

	if ( width > maxWidthSoFar )  then
		dialog:SetWidth(width);
		dialog.maxWidthSoFar = width;
	end

	local height = 32 + text:GetHeight() + 8 + button1:GetHeight();
	if ( info.hasEditBox ) then
		if ( info.hasWideEditBox  ) then

		end
		local editBoxHeight = editBox:GetHeight();
		if info.hasMultiLine then
			local wideEditBox = _G[dialog:GetName().."WideEditBox"];
			local multiLineEditBox = wideEditBox:IsShown() and wideEditBox or editBox;
			editBoxHeight = 8 + (multiLineEditBox:GetHeight() or 16);
		end
		height = height + 8 + editBoxHeight;
	elseif ( info.hasMoneyFrame ) then
		height = height + 16;
	elseif ( info.hasMoneyInputFrame ) then
		height = height + 22;
	end
	if ( info.hasItemFrame ) then
		height = height + 64;
	end

	if info.replayInfo then
		if dialog.data[2] == 5 then
			height = height + 80
			dialog.ReplayInfoFrame:SetHeight(48)
		elseif dialog.data[2] == 1 then
			height = height + 100
			dialog.ReplayInfoFrame:SetHeight(68)
		else
			height = height + 120
			dialog.ReplayInfoFrame:SetHeight(88)
		end
	end

	if dialog.equipmentSetCount then
		height = height + max(44, (44 * Round(dialog.equipmentSetCount / 2))) + 12
	end

	if type(info.radioButtonOptions) == "table" and #info.radioButtonOptions > 0 then
		height = height + dialog.RadioButtonHolder:GetHeight() + 6
	end

	if info.checkButtonText then
		height = height + dialog.CheckButton:GetHeight() + 6
	end

	if ( height > maxHeightSoFar ) then
		dialog:SetHeight(height);
		dialog.maxHeightSoFar = height;
	end

	if info.HelpBox then
		dialog.HelpBox:SetWidth(width - 10)
		dialog.HelpBox.Text:SetWidth(dialog.HelpBox:GetWidth() - 10)

		dialog.HelpBox:SetHeight(dialog.HelpBox.Text:GetHeight() + 20)
	end
end

function StaticPopup_Show(which, text_arg1, text_arg2, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if ( UnitIsDeadOrGhost("player") and not info.whileDead ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( InCinematic() and not info.interruptCinematic ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( info.exclusive ) then
		StaticPopup_HideExclusive();
	end

	if ( info.cancels ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and (frame.which == info.cancels) ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	if ( (which == "CAMP") or (which == "QUIT") ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and not StaticPopupDialogs[frame.which].notClosableByLogout ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	if ( which == "DEATH" ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
			if ( frame:IsShown() and not StaticPopupDialogs[frame.which].whileDead ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	dialog = StaticPopup_FindVisible(which, data);

	if ( dialog ) then
		if ( not info.noCancelOnReuse ) then
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog, dialog.data, "override");
			end
		end
		dialog:Hide();
	end
	if ( not dialog ) then
		-- Find a free dialog
		local index = 1;
		if ( info.preferredIndex ) then
			index = info.preferredIndex;
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup"..i];
			if ( not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end

		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if ( not dialog and info.preferredIndex ) then
			for i = 1, info.preferredIndex do
				local frame = _G["StaticPopup"..i];
				if ( not frame:IsShown() ) then
					dialog = frame;
					break;
				end
			end
		end
	end
	if ( not dialog ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	dialog.HelpBox:SetShown(info.HelpBox)
	dialog.ReplayInfoFrame:SetShown(info.replayInfo)
	dialog.BootPlayerPVPStatsFrame:SetShown(info.bootPlayerPVPStats)

	if info.zodiacSpells then
		dialog.ZodiacSpellFrame:SetZodiacSpells(data)
	else
		dialog.ZodiacSpellFrame:Hide()
	end

	dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0;
	-- Set the text of the dialog
	local text = _G[dialog:GetName().."Text"];
	if ( (which == "DEATH") or
	     (which == "CAMP") or
		 (which == "QUIT") or
		 (which == "DUEL_OUTOFBOUNDS") or
		 (which == "RECOVER_CORPSE") or
		 (which == "RESURRECT") or
		 (which == "RESURRECT_NO_SICKNESS") or
		 (which == "INSTANCE_BOOT") or
		 (which == "INSTANCE_LOCK") or
		 (which == "CONFIRM_SUMMON") or
		 (which == "BFMGR_INVITED_TO_ENTER") or
		 (which == "AREA_SPIRIT_HEAL") ) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		text:SetFormattedText(info.text, text_arg1, MINUTES);
	else
		text:SetFormattedText(info.text, text_arg1 or "~not text_arg1~", text_arg2 or "~not text_arg2~");
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	end

	-- Show or hide the alert icon
	local alertIcon = _G[dialog:GetName().."AlertIcon"];
	if ( info.showAlert ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
	elseif ( info.showAlertGear ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR);
	else
		alertIcon:SetTexture();
	end

	-- Show or hide the close button
	if ( info.closeButton ) then
		local closeButton = _G[dialog:GetName().."CloseButton"];
		if ( info.closeButtonIsHide ) then
			closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up");
			closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down");
		else
			closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up");
			closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down");
		end
		closeButton:Show();
	else
		_G[dialog:GetName().."CloseButton"]:Hide();
	end

	-- Set the editbox of the dialog
	local wideEditBox = _G[dialog:GetName().."WideEditBox"];
	local editBox = _G[dialog:GetName().."EditBox"];
	if ( info.hasEditBox ) then
		if ( info.hasWideEditBox ) then
			wideEditBox:Show();
			editBox:Hide();

			if info.hasMultiLine then
				wideEditBox:SetHeight(64);
				wideEditBox:SetMultiLine(true);
			else
				wideEditBox:SetMultiLine(false);
				wideEditBox:SetHeight(14);
			end

			if ( info.maxLetters ) then
				wideEditBox:SetMaxLetters(info.maxLetters);
			end
			if ( info.maxBytes ) then
				wideEditBox:SetMaxBytes(info.maxBytes);
			end
			wideEditBox:SetText("");
		else
			wideEditBox:Hide();
			editBox:Show();

			if info.hasMultiLine then
				editBox:SetHeight(32);
				editBox:SetMultiLine(true);
			else
				editBox:SetMultiLine(false);
				wideEditBox:SetHeight(32);
			end

			if ( info.maxLetters ) then
				editBox:SetMaxLetters(info.maxLetters);
			end
			if ( info.maxBytes ) then
				editBox:SetMaxBytes(info.maxBytes);
			end
			editBox:SetText("");
		end
	else
		wideEditBox:Hide();
		editBox:Hide();

		wideEditBox:SetMultiLine(false);
		editBox:SetMultiLine(false);
		wideEditBox:SetHeight(14);
		editBox:SetHeight(32);
	end

	-- Show or hide money frame
	if ( info.hasMoneyFrame ) then
		_G[dialog:GetName().."MoneyFrame"]:Show();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	elseif ( info.hasMoneyInputFrame ) then
		_G[dialog:GetName().."MoneyInputFrame"]:Show();
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		-- Set OnEnterPress for money input frames
		if ( info.EditBoxOnEnterPressed ) then
			_G[dialog:GetName().."MoneyInputFrameGold"]:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			_G[dialog:GetName().."MoneyInputFrameSilver"]:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			_G[dialog:GetName().."MoneyInputFrameCopper"]:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
		else
			_G[dialog:GetName().."MoneyInputFrameGold"]:SetScript("OnEnterPressed", nil);
			_G[dialog:GetName().."MoneyInputFrameSilver"]:SetScript("OnEnterPressed", nil);
			_G[dialog:GetName().."MoneyInputFrameCopper"]:SetScript("OnEnterPressed", nil);
		end
	else
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	end

	-- Show or hide item button
	if ( info.hasItemFrame ) then
		dialog.ItemFrame:Show();
		if ( data and type(data) == "table" ) then
			dialog.ItemFrame.link = data.link
			_G[dialog:GetName().."ItemFrameIconTexture"]:SetTexture(data.texture);
			local nameText = _G[dialog:GetName().."ItemFrameText"];
			nameText:SetTextColor(unpack(data.color or {1, 1, 1, 1}));
			nameText:SetText(data.name);
			if ( data.count and data.count > 1 ) then
				_G[dialog:GetName().."ItemFrameCount"]:SetText(data.count);
				_G[dialog:GetName().."ItemFrameCount"]:Show();
			else
				_G[dialog:GetName().."ItemFrameCount"]:Hide();
			end
		end
	else
		dialog.ItemFrame:Hide();
	end

	if type(info.radioButtonOptions) == "table" and #info.radioButtonOptions > 0 then
		local offset = 0
		if info.hasEditBox then
			if info.hasWideEditBox then
				offset = offset + wideEditBox:GetHeight() + 5
			else
				offset = offset + editBox:GetHeight() + 5
			end
		end
		dialog.RadioButtonHolder:SetOptions(info.radioButtonOptions)
		dialog.RadioButtonHolder:SetPoint("BOTTOM", 0, offset + 44)
		dialog.RadioButtonHolder:Show()
	else
		dialog.RadioButtonHolder:Clear()
	end

	if info.checkButtonText then
		dialog.CheckButton.hint = info.checkButtonHint
		dialog.CheckButton.ButtonText:SetText(info.checkButtonText)
		dialog.CheckButton:SetChecked(info.checkButtonChecked)

		local offset = 0
		if info.hasEditBox then
			if info.hasWideEditBox then
				offset = offset + wideEditBox:GetHeight() + 5
			else
				offset = offset + editBox:GetHeight() + 5
			end
		end
		if dialog.RadioButtonHolder:IsShown() then
			offset = offset + dialog.RadioButtonHolder:GetHeight() + 5
		end

		dialog.CheckButton:SetOffset(offset + 43)
		dialog.CheckButton:Show()
	else
		dialog.CheckButton:Hide()
	end

	-- Set the buttons of the dialog
	local button1 = _G[dialog:GetName().."Button1"];
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];

	if type(info.button1Tooltip) == "function" then
		button1:SetMotionScriptsWhileDisabled(true);
		button1:SetScript("OnEnter", info.button1Tooltip);
		button1:SetScript("OnLeave", GameTooltip_Hide);
	else
		button1:SetMotionScriptsWhileDisabled(false);
		button1:SetScript("OnEnter", nil);
		button1:SetScript("OnLeave", nil);
	end

	if ( info.button3 and ( not info.DisplayButton3 or info.DisplayButton3() ) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		button3:ClearAllPoints();
		button1:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -72, 16);
		button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
		button2:SetText(info.button2);
		button3:SetText(info.button3);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Enable();
		button2:Show();

		width = button3:GetTextWidth();
		if ( width > 110 ) then
			button3:SetWidth(width + 20);
		else
			button3:SetWidth(120);
		end
		button3:Enable();
		button3:Show();
	elseif ( info.button2 and
	   ( not info.DisplayButton2 or info.DisplayButton2() ) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		button1:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -6, 16);
		button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		button2:SetText(info.button2);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Enable();
		button2:Show();
		button3:Hide();
	else
		button1:ClearAllPoints();
		button1:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 16);
		button2:Hide();
		button3:Hide();
	end
	if ( info.button1 ) then
		button1:SetText(info.button1);
		local width = button1:GetTextWidth();
		if ( width > 120 ) then
			button1:SetWidth(width + 20);
		else
			button1:SetWidth(120);
		end
		button1:Enable();
		button1:Show();
	else
		button1:Hide();
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.timeleft = info.timeout;
	dialog.hideOnEscape = info.hideOnEscape;
	dialog.exclusive = info.exclusive;
	dialog.enterClicksFirstButton = info.enterClicksFirstButton;
	-- Clear out data
	dialog.data = data;

	if ( info.StartDelay ) then
		dialog.startDelay = info.StartDelay();
		button1:Disable();
	else
		dialog.startDelay = nil;
		button1:Enable();
	end

	editBox.autoCompleteParams = info.autoCompleteParams;
	wideEditBox.autoCompleteParams = info.autoCompleteParams;
	editBox.hasMultiLine = info.hasMultiLine;
	wideEditBox.hasMultiLine = info.hasMultiLine;

	editBox.autoCompleteRegex = info.autoCompleteRegex;
	wideEditBox.autoCompleteRegex = info.autoCompleteRegex;

	editBox.autoCompleteFormatRegex = info.autoCompleteFormatRegex;
	wideEditBox.autoCompleteFormatRegex = info.autoCompleteFormatRegex;

	editBox.addHighlightedText = true;
	wideEditBox.autoCompleteFormatRegex = true;

	-- Finally size and show the dialog
	StaticPopup_SetUpPosition(dialog);
	dialog:Show();

	if info.equipmentSetButton then
		local equipmentData = data.setsData
		if #equipmentData > 0 then
			dialog.slotStorage = {}
			for index, equipmentSetName in pairs(equipmentData) do
				local icon = GetEquipmentSetInfoByName(equipmentSetName)

				if icon then
					local slot = dialog.itemPool:Acquire()

					table.insert(dialog.slotStorage, slot)

					if index == 1 then
						if #equipmentData == 1 then
							slot:SetPoint("TOP", dialog.text, "BOTTOM", 0, -10)
						else
							slot:SetPoint("TOPLEFT", dialog.text, "BOTTOMLEFT", -20, -10)
						end

					elseif mod(index - 1, 2) == 0 then
						slot:SetPoint("TOP", dialog.slotStorage[index - 2], "BOTTOM", 0, -6)
					else
						slot:SetPoint("LEFT", dialog.slotStorage[index - 1], "RIGHT", 10, 0)
					end

					slot.IconFrame.icon:SetTexture("Interface\\ICONS\\"..icon)
					slot.NameFrame.Text:SetText(equipmentSetName)

					slot.IconFrame.name = equipmentSetName

					slot:Show()
				end
			end

			dialog.equipmentSetCount = #equipmentData
		else
			dialog.equipmentSetCount = nil
		end
	else
		dialog.equipmentSetCount = nil
	end

	StaticPopup_Resize(dialog, which);

	if ( info.sound ) then
		PlaySound(info.sound);
	end

	return dialog;
end

function StaticPopup_Hide(which, data)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local dialog = _G["StaticPopup"..index];
		if ( dialog:IsShown() and (dialog.which == which) and (not data or (data == dialog.data)) ) then
			dialog:Hide();
		end
	end
end

function StaticPopup_OnUpdate(dialog, elapsed)
	if ( dialog.timeleft > 0 ) then
		local which = dialog.which;
		local timeleft = dialog.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			if ( not StaticPopupDialogs[which].timeoutInformationalOnly ) then
				dialog.timeleft = 0;
				local OnCancel = StaticPopupDialogs[which].OnCancel;
				if ( OnCancel ) then
					OnCancel(dialog, dialog.data, "timeout");
				end
				dialog:Hide();
			end
			return;
		end
		dialog.timeleft = timeleft;

		if ( (which == "DEATH") or
		     (which == "CAMP")  or
			 (which == "QUIT") or
			 (which == "DUEL_OUTOFBOUNDS") or
			 (which == "INSTANCE_BOOT") or
			 (which == "CONFIRM_SUMMON") or
			 (which == "BFMGR_INVITED_TO_ENTER") or
			 (which == "AREA_SPIRIT_HEAL")) then
			local text = _G[dialog:GetName().."Text"];
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( which == "INSTANCE_BOOT" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "CONFIRM_SUMMON" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), ceil(timeleft / 60), MINUTES);
				end
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(dialog, which);
			end
		end
	end
	if ( dialog.startDelay ) then
		local which = dialog.which;
		local timeleft = dialog.startDelay - elapsed;
		if ( timeleft <= 0 ) then
			dialog.startDelay = nil;
			local text = _G[dialog:GetName().."Text"];
			text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, text.text_arg2);
			local button1 = _G[dialog:GetName().."Button1"];
			button1:Enable();
			StaticPopup_Resize(dialog, which);
			return;
		end
		dialog.startDelay = timeleft;

		if ( which == "RECOVER_CORPSE" or (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
			local text = _G[dialog:GetName().."Text"];
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].delayText, text.text_arg1, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].delayText, text.text_arg1, ceil(timeleft / 60), MINUTES);
				end
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].delayText, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].delayText, ceil(timeleft / 60), MINUTES);
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(dialog, which);
			end
		end
	end

	local onUpdate = StaticPopupDialogs[dialog.which].OnUpdate;
	if ( onUpdate ) then
		onUpdate(dialog, elapsed);
	end
end

function StaticPopup_EditBoxOnEnterPressed(self)
	local EditBoxOnEnterPressed, which, dialog;
	local parent = self:GetParent();
	if ( parent.which ) then
		which = parent.which;
		dialog = parent;
	elseif ( parent:GetParent().which ) then
		-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
		which = parent:GetParent().which;
		dialog = parent:GetParent();
	end
	if ( not self.autoCompleteParams or not AutoCompleteEditBox_OnEnterPressed(self) ) then
		EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
		if ( EditBoxOnEnterPressed ) then
			EditBoxOnEnterPressed(self, dialog.data);
		end
	end
end

function StaticPopup_EditBoxOnEscapePressed(self)
	local EditBoxOnEscapePressed = StaticPopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function StaticPopup_EditBoxOnTextChanged(self, userInput)
	if self.hasMultiLine then
		StaticPopup_OnEvent(self:GetParent());
	end

	if ( not self.autoCompleteParams or not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
		if ( EditBoxOnTextChanged ) then
			EditBoxOnTextChanged(self, self:GetParent().data);
		end
	end
end

function StaticPopup_OnLoad(self)
	local name = self:GetName();
	self.button1 = _G[name .. "Button1"];
	self.button2 = _G[name .. "Button2"];
	self.button3 = _G[name .. "Button3"];
	self.text = _G[name .. "Text"];
	self.icon = _G[name .. "AlertIcon"];
	self.moneyInputFrame = _G[name .. "MoneyInputFrame"];
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");

	self.itemPool = CreateFramePool("Button", self, "EquipmentSetButtonTemplate")
end

function StaticPopup_OnShow(self)
	PlaySound("igMainMenuOpen");

	local dialog = StaticPopupDialogs[self.which];
	local OnShow = dialog.OnShow;

	if ( OnShow ) then
		OnShow(self, self.data);
	end
	if ( dialog.hasMoneyInputFrame ) then
		_G[self:GetName().."MoneyInputFrameGold"]:SetFocus();
	end
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", StaticPopup_OnKeyDown);
	end
end

function StaticPopup_OnHide(self)
	PlaySound("igMainMenuClose");

	self.itemPool:ReleaseAll()
	StaticPopup_CollapseTable();

	local dialog = StaticPopupDialogs[self.which];
	local OnHide = dialog.OnHide;
	if ( OnHide ) then
		OnHide(self, self.data);
	end
	self.extraFrame:Hide();
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", nil);
	end
end

function StaticPopup_OnClick(dialog, index)
	if ( not dialog:IsShown() ) then
		return;
	end
	local which = dialog.which;
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	local hide = true;
	if ( index == 1 ) then
		local OnAccept = info.OnAccept;
		if ( OnAccept ) then
			hide = not OnAccept(dialog, dialog.data, dialog.data2);
		end
	elseif ( index == 3 ) then
		local OnAlt = info.OnAlt;
		if ( OnAlt ) then
			OnAlt(dialog, dialog.data, "clicked");
		end
	else
		local OnCancel = info.OnCancel;
		if ( OnCancel ) then
			hide = not OnCancel(dialog, dialog.data, "clicked");
		end
	end

	if ( hide and (which == dialog.which) ) then
		-- can dialog.which change inside one of the On* functions???
		dialog:Hide();
	end
end

function StaticPopup_OnKeyDown(self, key)
	-- previously, StaticPopup_EscapePressed() captured the escape key for dialogs, but now we need
	-- to catch it here
	if ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		return StaticPopup_EscapePressed();
	elseif ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end

	local dialog = StaticPopupDialogs[self.which];
	if ( dialog ) then
		if ( key == "ENTER" and dialog.enterClicksFirstButton ) then
			local frameName = self:GetName();
			local button;
			local i = 1;
			while ( true ) do
				button = _G[frameName.."Button"..i];
				if ( button ) then
					if ( button:IsShown() ) then
						if ( button:IsEnabled() == 1 ) then
							StaticPopup_OnClick(self, i);
						end
						return;
					end
					i = i + 1;
				else
					break;
				end
			end
		end
	end
end

function StaticPopup_EscapePressed()
	local closed = nil;
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if( frame:IsShown() and frame.hideOnEscape ) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if ( standardDialog ) then
				local OnCancel = standardDialog.OnCancel;
				local noCancelOnEscape = standardDialog.noCancelOnEscape;
				if ( OnCancel and not noCancelOnEscape) then
					OnCancel(frame, frame.data, "clicked");
				end
				frame:Hide();
			else
				StaticPopupSpecial_Hide(frame);
			end
			closed = 1;
		end
	end
	return closed;
end

function StaticPopup_SetUpPosition(dialog)
	if ( not tContains(StaticPopup_DisplayedFrames, dialog) ) then
		StaticPopup_SetUpAnchor(dialog, #StaticPopup_DisplayedFrames + 1);
		tinsert(StaticPopup_DisplayedFrames, dialog);
	end
end

function StaticPopup_SetUpAnchor(dialog, idx)
	local lastFrame = StaticPopup_DisplayedFrames[idx - 1];
	if ( lastFrame ) then
		dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, 0);
	else
		dialog:SetPoint("TOP", UIParent, "TOP", 0, dialog.topOffset or -135);
	end
end

function StaticPopup_CollapseTable()
	local displayedFrames = StaticPopup_DisplayedFrames;
	local index = #displayedFrames;
	while ( ( index >= 1 ) and ( not displayedFrames[index]:IsShown() ) ) do
		tremove(displayedFrames, index);
		index = index - 1;
	end
end

function StaticPopupSpecial_Show(frame)
	if ( frame.exclusive ) then
		StaticPopup_HideExclusive();
	end
	StaticPopup_SetUpPosition(frame);
	frame:Show();
end

function StaticPopupSpecial_Hide(frame)
	frame:Hide();
	StaticPopup_CollapseTable();
end

--Used to figure out if we can resize a frame
function StaticPopup_IsLastDisplayedFrame(frame)
	for i=#StaticPopup_DisplayedFrames, 1, -1 do
		local popup = StaticPopup_DisplayedFrames[i];
		if ( popup:IsShown() ) then
			return frame == popup
		end
	end
	return false;
end

function StaticPopup_OnEvent(self)
	self.maxHeightSoFar = 0;
	StaticPopup_Resize(self, self.which);
end

function StaticPopup_HideExclusive()
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if ( frame:IsShown() and frame.exclusive ) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if ( standardDialog ) then
				frame:Hide();
				local OnCancel = standardDialog.OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			else
				StaticPopupSpecial_Hide(frame);
			end
			break;
		end
	end
end

function EventHandler:ASMSG_ARENA_READY_CHECK( msg )
	msg = tonumber(msg or 0)

	if msg == 1 then
		StaticPopup_Hide("ASMSG_ARENA_READY_CHECK")
	else
		StaticPopup_Show("ASMSG_ARENA_READY_CHECK")
	end
end

StaticPopupCheckButtonMixin = {}

function StaticPopupCheckButtonMixin:OnShow()
	self:UpdateRectAndPosition()
end

function StaticPopupCheckButtonMixin:OnEnter()
	if self.hint then
		GameTooltip:SetOwner(self, "ANCHOT_RIGHT")
		GameTooltip:AddLine(self.hint)
		GameTooltip:Show()
	end
end

function StaticPopupCheckButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function StaticPopupCheckButtonMixin:OnEnable()
	self.ButtonText:SetTextColor(1, 0.82, 0)
end

function StaticPopupCheckButtonMixin:OnDisable()
	self.ButtonText:SetTextColor(0.5, 0.5, 0.5)
end

function StaticPopupCheckButtonMixin:SetText(text)
	self.ButtonText:SetText(text)
	self:UpdateRectAndPosition()
end

function StaticPopupCheckButtonMixin:SetFormattedText(...)
	self:SetText(string.format(...))
end

function StaticPopupCheckButtonMixin:SetOffset(y)
	self.offsetY = y
end

function StaticPopupCheckButtonMixin:UpdateRectAndPosition()
	self.ButtonText:SetWidth(self:GetParent():GetWidth() - 70)

	local textWidth = self.ButtonText:GetStringWidth()
	self:SetHitRectInsets(0, -textWidth, 0, 0)
	self:SetPoint("BOTTOM", -(textWidth / 2), self.offsetY or 43)
end

StaticPopupRadioButtonHolderMixin = {}

function StaticPopupRadioButtonHolderMixin:OnLoad()
	local onChecked = function(this, button, userInput)
		if userInput then
			self:SetSelectedIndex(this:GetID())
		end
	end
	self.buttonPool = CreateFramePool("CheckButton", self, "PKBT_RadioButtonTemplate", function(pool, this)
		this:SetChecked(false)
	end, nil, function(this)
		this.OnChecked = onChecked
		this:SetSize(18, 18)
		this.ButtonText:SetFontObject("PKBT_Font_13")
	end)
	self.paddingY = 3
end

function StaticPopupRadioButtonHolderMixin:OnShow()
	self:UpdateRect()
end

function StaticPopupRadioButtonHolderMixin:Clear()
	self.buttonPool:ReleaseAll()
	self:Hide()
end

function StaticPopupRadioButtonHolderMixin:UpdateRect()
	local numActive = self.buttonPool:GetNumActive()
	if numActive > 0 then
		local width = 0

		for radioButton in self.buttonPool:EnumerateActive() do
			width = math.max(width, radioButton.ButtonText:GetStringWidth())
		end

		local buttonWidth, buttonHeight = self.buttonPool:GetNextActive():GetSize()
		self:SetSize(width + 5 + buttonWidth, buttonHeight * numActive + self.paddingY * (numActive - 1))
	else
		self:SetSize(1, 1)
		self:Hide()
	end
end

function StaticPopupRadioButtonHolderMixin:SetOptions(options)
	self.buttonPool:ReleaseAll()

	local lastButton
	for index, optionText in ipairs(options) do
		local button = self.buttonPool:Acquire()
		button:SetID(index)
		button.ButtonText:SetText(optionText)
		if not lastButton then
			button:SetPoint("TOPLEFT", 0, 0)
		else
			button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -self.paddingY)
		end
		button:Show()
		lastButton = button
	end

	self:UpdateRect()
end

function StaticPopupRadioButtonHolderMixin:SetSelectedIndex(index)
	for radioButton in self.buttonPool:EnumerateActive() do
		radioButton:SetChecked(radioButton:GetID() == index)
	end
end

function StaticPopupRadioButtonHolderMixin:GetSelectedIndex()
	for radioButton in self.buttonPool:EnumerateActive() do
		if radioButton:GetChecked() == 1 then
			return radioButton:GetID()
		end
	end
end

StaticPopupBootPlayerPVPStatsMixin = {}

function StaticPopupBootPlayerPVPStatsMixin:OnLoad()
	self.cellFrames = {}
	self.defaultStats = {STATS_KILLS, STATS_DEATH, SCORE_DAMAGE_DONE, SCORE_HEALING_DONE}
	self.includeMapStats = true
end

function StaticPopupBootPlayerPVPStatsMixin:OnUpdate()
	RequestBattlefieldScoreData()
end

function StaticPopupBootPlayerPVPStatsMixin:OnEvent(event, ...)
	if event == "UPDATE_BATTLEFIELD_SCORE" then
		self:UpdateScore()
	elseif event == "PLAYER_ENTERING_WORLD" then
		local _, instanceType = GetInstanceInfo()
		if instanceType ~= "pvp" then
			self:GetParent():Hide()
		end
	end
end

function StaticPopupBootPlayerPVPStatsMixin:OnHide()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
	self.unitName = nil

	for _, cell in ipairs(self.cellFrames) do
		cell:Reset()
	end
end

function StaticPopupBootPlayerPVPStatsMixin:SetUnitName(name)
	if not UnitInBattleground(name) then
		GMError("[ERROR] PVP vote to kick stats: not in battleground!")
		self:Hide()
		return
	end

	self.unitName = name

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

	RequestBattlefieldScoreData()

	self:UpdateScore(true)
end

function StaticPopupBootPlayerPVPStatsMixin:UpdateScore(init)
	local scoreIndex, name, killingBlows, honorableKills, deaths, honorGained, faction, rank, race, class, classToken, damageDone, healingDone, additionalStatData = C_BattlefieldScore.GetEntryByName(self.unitName)
	if scoreIndex then
		if self.includeMapStats and additionalStatData then
			self:SetStats(init, faction, killingBlows, deaths, damageDone, healingDone, unpack(additionalStatData))
		else
			self:SetStats(init, faction, killingBlows, deaths, damageDone, healingDone)
		end
	end

	self.Border:SetShown(scoreIndex ~= nil)
	self.Container:SetShown(scoreIndex ~= nil)
end

function StaticPopupBootPlayerPVPStatsMixin:SetStats(init, faction, ...)
	local CELL_OFFSET_X = 2
	local CELL_OFSET_X_BASE = 0

	local numDefaultStats = #self.defaultStats
	local numStats = select("#", ...)

	local cellWidth
	if numStats > 6 then
		cellWidth = 70
		local dialogWidth = numStats * cellWidth + 40
		self:GetParent():SetWidth(dialogWidth)
		CELL_OFSET_X_BASE = math.ceil((dialogWidth - CELL_OFFSET_X * (numStats - 1)) / numStats - cellWidth)
	else
		self:GetParent():SetWidth(420)
		cellWidth = (self.Container:GetWidth() - CELL_OFFSET_X * (numStats - 1)) / numStats
	end

	for statIndex = 1, numStats do
		local cell = self.cellFrames[statIndex]
		if not cell then
			cell = CreateFrame("Frame", string.format("$parentStat%i", statIndex), self.Container, "BootPlayerPVPStatCellTemplate")
			cell:SetID(statIndex)
			cell:SetLabel(self.defaultStats[statIndex] or "")

			if statIndex == 1 then
				cell:SetPoint("TOPLEFT", CELL_OFSET_X_BASE, 0)
			else
				cell:SetPoint("TOPLEFT", self.cellFrames[statIndex - 1], "TOPRIGHT", CELL_OFFSET_X, 0)
			end

			self.cellFrames[statIndex] = cell
		end

		local statValue = select(statIndex, ...)

		if statIndex <= numDefaultStats then
			cell:SetValue(statValue, statIndex ~= 2, init)
		else -- additional stats
			local additionalStatIndex = statIndex - numDefaultStats
			local text, icon, tooltip = GetBattlefieldStatInfo(additionalStatIndex)
			cell:SetLabel(text:gsub(" ", "\n"), faction, icon)
			cell.tooltip = tooltip

			cell:SetValue(statValue)
		end

		cell:SetWidth(cellWidth)
		cell:Show()
	end

	for statIndex = numStats + 1, #self.cellFrames do
		self.cellFrames[statIndex]:Hide()
	end
end

BootPlayerPVPStatCellMixin = {}

function BootPlayerPVPStatCellMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(self.tooltip, 1, 1, 1, 1)
		GameTooltip:Show()
	end
end

function BootPlayerPVPStatCellMixin:OnLeave()
	if self.tooltip then
		GameTooltip_Hide()
	end
end

function BootPlayerPVPStatCellMixin:SetLabel(text, faction, icon)
	self.Label:SetText(text)
	self.faction = faction

	if icon and icon ~= "" then
		self.Icon:SetTexture(strconcat(icon, faction or 0))
		self.Value:SetPoint("BOTTOM", 7, 0)
	else
		self.Icon:SetTexture(icon)
		self.Value:SetPoint("BOTTOM", 0, 0)
	end
end

function BootPlayerPVPStatCellMixin:SetValue(value, colorizeDiff, isBaseValue)
	local int = tonumber(value) or 0
	if isBaseValue or not self.baseValue then
		self.baseValue = tonumber(value)
		self.Value:SetText(int)
	else
		if self.baseValue ~= int then
			if colorizeDiff then
				self.Value:SetFormattedText("%s\n(|cff00ff00+%s|r)", int, int - self.baseValue)
			else
				self.Value:SetFormattedText("%s\n(+%s)", int, int - self.baseValue)
			end
		end
	end
end

function BootPlayerPVPStatCellMixin:Reset()
	self.baseValue = nil
	self.Value:SetText("")
end

StatusPopupDelayCountdownMixin = {}

function StatusPopupDelayCountdownMixin:SetDelay(delay, onUpdate)
	if type(delay) ~= "number" or delay <= 0 or type(onUpdate) ~= "function" then
		self:Hide()
	else
		self.timeLeft = delay
		self.OnCountdownUpdate = onUpdate
		self:SetScript("OnUpdate", self.OnUpdate)
		self:Show()
		onUpdate(self.timeLeft)
	end
end

function StatusPopupDelayCountdownMixin:OnHide()
	self.OnCountdownUpdate = nil
	self.timeLeft = nil
	self:SetScript("OnUpdate", nil)
end

function StatusPopupDelayCountdownMixin:OnUpdate(elapsed)
	self.timeLeft = self.timeLeft - elapsed

	local success, err = pcall(self.OnCountdownUpdate, self.timeLeft)
	if not success then
		geterrorhandler()(err)
		self:Hide()
		return
	end

	if self.timeLeft <= 0 then
		self:Hide()
	end
end

StatusPopupZodiacSpellMixin = {}

function StatusPopupZodiacSpellMixin:OnLoad()
	self.spellButtonPool = CreateFramePool("Frame", self, "StatisPopupSpellButtonTemplate")
end

function StatusPopupZodiacSpellMixin:OnShow()
	SetParentFrameLevel(self.Border)
end

function StatusPopupZodiacSpellMixin:SetZodiacSpells(raceID)
	if E_CHARACTER_RACES[raceID] then
		local activaSpells, passiveSpells = C_ZodiacSign.GetZodiacSignSpells(raceID)
		if activaSpells then
			local firstButtonOffsetX = 10 + math.max(self.ActiveSpells.Label:GetStringWidth(), self.PassiveSpells.Label:GetStringWidth())
			self:CreateSpellButtons(self.ActiveSpells, activaSpells, firstButtonOffsetX)
			self:CreateSpellButtons(self.PassiveSpells, passiveSpells, firstButtonOffsetX)

			if self.ActiveSpells:GetWidth() < self.PassiveSpells:GetWidth() then
				self.ActiveSpells:SetWidth(self.PassiveSpells:GetWidth())
			end

			self:Show()
			return
		end
	end
	self:Hide()
end

function StatusPopupZodiacSpellMixin:CreateSpellButtons(parent, spellList, firstButtonOffsetX, offsetX)
	if not offsetX then
		offsetX = 10
	end
	local buttonSize = 0

	local lastSpell
	for index, spellID in ipairs(spellList) do
		local spell = self.spellButtonPool:Acquire()
		spell:SetID(index)
		spell:SetParent(parent)

		if not lastSpell then
			spell:SetPoint("LEFT", firstButtonOffsetX or 0, 0)
		else
			spell:SetPoint("LEFT", lastSpell, "RIGHT", offsetX, 0)
		end

		local _, _, icon = GetSpellInfo(spellID)
		spell.Icon:SetTexture(icon)
		spell.spellID = spellID
		spell:Show()

		lastSpell = spell
		if buttonSize == 0 then
			buttonSize = spell:GetWidth()
		end
	end

	parent:SetSize(firstButtonOffsetX + buttonSize * #spellList + offsetX * (#spellList - 1), buttonSize)
end

StatusPopupZodiacSpellButtonMixin = {}

function StatusPopupZodiacSpellButtonMixin:OnLoad()
	self.Border:SetAtlas("PKBT-ItemBorder-Default")
end

function StatusPopupZodiacSpellButtonMixin:OnEnter()
	if self.spellID then
		local spellLink, tradeSkillLink = GetSpellLink(self.spellID)
		if spellLink or tradeSkillLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(tradeSkillLink or spellLink)
			GameTooltip:Show()
		end
	end
end

function StatusPopupZodiacSpellButtonMixin:OnLeave()
	GameTooltip:Hide()
end

function StatusPopupZodiacSpellButtonMixin:OnClick(button)
	if self.spellID and IsModifiedClick("CHATLINK") then
		local spellLink, tradeSkillLink = GetSpellLink(self.spellID)
		if spellLink or tradeSkillLink then
			ChatEdit_InsertLink(tradeSkillLink or spellLink)
		end
	end
end