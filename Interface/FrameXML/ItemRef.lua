
function SetItemRef(link, text, button, chatFrame)
	if ( strsub(link, 1, 6) == "player" ) then
		local namelink, isGMLink;
		if ( strsub(link, 7, 8) == "GM" ) then
			namelink = strsub(link, 10);
			isGMLink = true;
		else
			namelink = strsub(link, 8);
		end

		local name, lineid, chatType, chatTarget = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_MUTE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_FRIEND");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_GUILDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_TEAMMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_RAIDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("CHANNEL_INVITE");
				if ( staticPopup ) then
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				if ( ChatEdit_GetActiveWindow() ) then
					ChatEdit_InsertLink(name);
				elseif ( HelpFrameOpenTicketEditBox:IsVisible() ) then
					HelpFrameOpenTicketEditBox:Insert(name);
				else
					SendWho(WHO_TAG_NAME..name);
				end

			elseif ( button == "RightButton" and (not isGMLink) ) then
				FriendsFrame_ShowDropdown(name, 1, lineid, chatType, chatFrame);
			else
				ChatFrame_SendTell(name, chatFrame);
			end
		end
		return;
	elseif ( strsub(link, 1, 8) == "BNplayer" ) then
		local namelink = strsub(link, 10);

		local name, presenceID, lineid, chatType, chatTarget = strsplit(":", namelink);
		if ( name and (strlen(name) > 0) ) then
			if ( IsModifiedClick("CHATLINK") ) then
				local staticPopup;
				staticPopup = StaticPopup_Visible("ADD_IGNORE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_MUTE");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_FRIEND");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_GUILDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_TEAMMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("ADD_RAIDMEMBER");
				if ( staticPopup ) then
					-- If add ignore dialog is up then enter the name into the editbox
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				staticPopup = StaticPopup_Visible("CHANNEL_INVITE");
				if ( staticPopup ) then
					_G[staticPopup.."EditBox"]:SetText(name);
					return;
				end
				if ( ChatEdit_GetActiveWindow() ) then
					ChatEdit_InsertLink(name);
				elseif ( HelpFrameOpenTicketEditBox:IsVisible() ) then
					HelpFrameOpenTicketEditBox:Insert(name);
				end

			elseif ( button == "RightButton" ) then
				if ( not BNIsSelf(presenceID) ) then
					FriendsFrame_ShowBNDropdown(name, 1, nil, chatType, chatFrame, nil, BNet_GetPresenceID(name));
				end
			else
				if ( not BNIsSelf(presenceID) ) then
					ChatFrame_SendTell(name, chatFrame);
				end
			end
		end
		return;
	elseif ( strsub(link, 1, 7) == "channel" ) then
		if ( IsModifiedClick("CHATLINK") ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			if ( strupper(chatType) == "BN_CONVERSATION" ) then
				BNListConversation(chatTarget);
			else
				ToggleFriendsFrame(3);
			end
		elseif ( button == "LeftButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);

			if ( strupper(chatType) == "CHANNEL" ) then
				if ( GetChannelName(tonumber(chatTarget))~=0 ) then
					ChatFrame_OpenChat("/"..chatTarget, chatFrame);
				end
			elseif ( strupper(chatType) == "BN_CONVERSATION" ) then
				if ( BNGetConversationInfo(chatTarget) ) then
					ChatFrame_OpenChat("/"..(chatTarget + MAX_WOW_CHAT_CHANNELS), chatFrame);
				end
			else
				ChatFrame_OpenChat("/"..chatType, chatFrame);
			end
		elseif ( button == "RightButton" ) then
			local chanLink = strsub(link, 9);
			local chatType, chatTarget = strsplit(":", chanLink);
			if not ( (strupper(chatType) == "CHANNEL" and GetChannelName(tonumber(chatTarget)) == 0) or	--Don't show the dropdown if this is a channel we are no longer in.
				(strupper(chatType) == "BN_CONVERSATION" and not BNGetConversationInfo(chatTarget)) ) then	--Or a conversation we are no longer in.
				ChatChannelDropDown_Show(chatFrame, strupper(chatType), chatTarget, Chat_GetColoredChatName(strupper(chatType), chatTarget));
			end
		end
		return;
	elseif ( strsub(link, 1, 6) == "GMChat" ) then
		GMChatStatusFrame_OnClick();
		return;
	elseif ( strsub(link, 1, 5) == "death" ) then
		if ( IsModifiedClick() ) then
			local fixedLink = GetFixedLink(text)
			HandleModifiedItemClick(fixedLink)
			return
		end

		DeathRecapFrame:OnHyperlinkClick(link)
		return
	elseif ( strsub(link, 1, 7) == "journal" ) then
		if ( not HandleModifiedItemClick(GetFixedLink(text)) ) then
			EncounterJournal_OpenJournalLink(strsplit(":", link))
		end
		return
	elseif ( strsub(link, 1, 7) == "talents" ) then
		GetTalentHyperlinkInfo(link)
		return
	elseif ( strsub(link, 1, 3) == "url" ) then
		ChatUrlHyperlink_OnClick(link, text)
		return
	elseif ( strsub(link, 1, 5) == "store" ) then
		GetStoreHyperlinkInfo(link)
		return
	elseif ( strsub(link, 1, 6) == "replay" ) then
		ArenaSpectatorFrame:WatchReplayAtHyperlink(link)
		return
	elseif ( strsub(link, 1, 4) == "http" ) then
		StaticPopup_Show("EXTERNAL_URL_POPUP", nil, nil, link)
		return
	elseif ( strsub(link, 1, 10) == "collection" ) then
		local _, collectionType, itemID = strsplit(":", link);
		collectionType, itemID = tonumber(collectionType), tonumber(itemID);

		if ( IsModifiedClick("CHATLINK") ) then
			local fixedLink = GetFixedLink(text);
			HandleModifiedItemClick(fixedLink);
		else
			if ( CollectionsJournal ) then
				if ( collectionType == CHAR_COLLECTION_MOUNT ) then
					for index, data in ipairs(COLLECTION_MOUNTDATA) do
						if ( data.itemID == itemID and data.creatureID ) then
							SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
							MountJournal_Select(index);
							break;
						end
					end
				elseif ( collectionType == CHAR_COLLECTION_PET ) then
					local _, petID = C_PetJournal.GetPetInfoByItemID(itemID);
					if ( petID ) then
						SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_PETS);
						PetJournal_SelectByPetID(petID);
					end
				elseif ( collectionType == CHAR_COLLECTION_APPEARANCE ) then
					TransmogUtil.OpenCollectionToItem(itemID);
				elseif ( collectionType == CHAR_COLLECTION_TOY ) then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
				elseif ( collectionType == CHAR_COLLECTION_HEIRLOOM ) then
					SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS);
					if ( itemID and HeirloomsJournal ) then
						HeirloomsJournal:SetFindPageForHeirloomePage(itemID);
						HeirloomsJournal:RefreshViewIfVisible();
					end
				elseif ( collectionType == CHAR_COLLECTION_ILLUSION ) then
					TransmogUtil.OpenCollectionToIllusion(itemID);
				end
			end
		end
		return;
	elseif ( strsub(link, 1, 5) == "kbase" ) then
		local _, dataTypeIndex, entryID = string.split(":", link)
		dataTypeIndex = tonumber(dataTypeIndex)
		entryID = tonumber(entryID)

		ShowUIPanel(HelpFrame, true)
		HelpFrame_SetFrameByKey(HELPFRAME_KNOWLEDGE_BASE)
		HelpFrame_SetSelectedButton(HelpFrameNavTbl[1].button)

		if dataTypeIndex == SIRUS_KNOWLEDGE_BASE_IDS.ROOT.ARTICLE then
			if entryID > 0 then
				local entry = KNOWLEDGEBASE_ARTICLES[entryID]
				if entry and (not entry.hidden or IsGMAccount()) then
					KnowledgeBase_SetNavBarPath(entry.articleID)
					KnowledgeBase_ArticleOnClick({
						articleId = entry.articleID,
						articleHeader = Custom_KnowledgeBase.GetArticleHeaderByID(entry.articleID),
					}, "LeftButton", true)
				end
			end
		elseif dataTypeIndex == SIRUS_KNOWLEDGE_BASE_IDS.ROOT.CATEGORY then
			if entryID == -1 then
				NavBar_Reset(HelpFrame.kbase.navBar)
				KnowledgeBase_SelectCategory({index = entryID})
			elseif entryID == -2 then
				KnowledgeBase_SnapToTopIssues()
			elseif entryID > 0 then
				for categoryIndex = 1, Custom_KnowledgeBase.KBSetup_GetCategoryCount() do
					local categoryID = Custom_KnowledgeBase.KBSetup_GetCategoryData(categoryIndex)
					if categoryID == entryID then
						NavBar_Reset(HelpFrame.kbase.navBar)
						KnowledgeBase_SelectCategory({index = categoryIndex + 2})	-- Offset for first two virtual categories
						break
					end
				end
			end
		elseif dataTypeIndex == SIRUS_KNOWLEDGE_BASE_IDS.ROOT.SUB_CATEGORY then
			if entryID == -1 then
				NavBar_Reset(HelpFrame.kbase.navBar)
				KnowledgeBase_SelectSubCategory({index = entryID})
			elseif entryID > 0 then
				local entry = KNOWLEDGEBASE_SUB_CATEGORIES[entryID]
				if entry and entry.parentID ~= -1 then
					for categoryIndex = 1, Custom_KnowledgeBase.KBSetup_GetCategoryCount() do
						local categoryID, categoryName = Custom_KnowledgeBase.KBSetup_GetCategoryData(categoryIndex)
						if categoryID == entry.parentID then
							for subCategoryIndex = 1, Custom_KnowledgeBase.KBSetup_GetSubCategoryCount(categoryIndex) do
								local subCategoryID = Custom_KnowledgeBase.KBSetup_GetSubCategoryData(categoryIndex, subCategoryIndex)
								if subCategoryID == entryID then
									NavBar_Reset(HelpFrame.kbase.navBar)

									NavBar_AddButton(HelpFrame.kbase.navBar, {
										name = categoryName,
										OnClick = KnowledgeBase_DisplaySubCategories,
										listFunc = KnowledgeBase_ListSubCategory,
										category = categoryIndex,
									})
									HelpFrame.kbase.category = categoryIndex

									KnowledgeBase_SelectSubCategory({index = subCategoryIndex + 1})	-- Offset for first virtual categories

									break
								end
							end

							break
						end
					end
				end
			end
		end

		return
	end

	if ( IsModifiedClick() ) then
		local fixedLink = GetFixedLink(text);
		HandleModifiedItemClick(fixedLink);
	else
		ShowUIPanel(ItemRefTooltip);
		if ( not ItemRefTooltip:IsShown() ) then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
		end
		ItemRefTooltip:SetHyperlink(link);

		if ( strsub(link, 1, 11) == "achievement" ) then
			local achievementID, GUID, completed = strsplit(":", strsub(link, 13));
			local playerGUID = UnitGUID("player");

			if ( completed == "0" and playerGUID and strsub(playerGUID, 3) == GUID and GetAchievementNumCriteria(achievementID) > 0 ) then
				local criteriaString, _, criteriaCompleted, quantity, totalQuantity = GetAchievementCriteriaInfo(achievementID, 1);
				if ( criteriaString and quantity and totalQuantity and totalQuantity > 1 ) then
					local index = 1;
					local numLines = ItemRefTooltip:NumLines();

					for i = 2, numLines do
						local textLeft = _G["ItemRefTooltipTextLeft"..i]:GetText();
						local textRight = _G["ItemRefTooltipTextRight"..i]:GetText();

						if ( not criteriaCompleted and textLeft and textLeft == criteriaString ) then
							_G["ItemRefTooltipTextLeft"..i]:SetFormattedText("%d / %d %s", quantity, totalQuantity, criteriaString);
							index = index + 1;
							criteriaString, _, criteriaCompleted, quantity, totalQuantity = GetAchievementCriteriaInfo(achievementID, index);
						end

						if ( not criteriaCompleted and textRight and textRight == criteriaString ) then
							_G["ItemRefTooltipTextRight"..i]:SetFormattedText("%d / %d %s", quantity, totalQuantity, criteriaString);
							index = index + 1;
							criteriaString, _, criteriaCompleted, quantity, totalQuantity = GetAchievementCriteriaInfo(achievementID, index);
						end
					end

					ItemRefTooltip:Show();
				end
			end
		end
	end
end

function GetFixedLink(text)
	local startLink = strfind(text, "|H");
	if ( not strfind(text, "|c") ) then
		if ( strsub(text, startLink + 2, startLink + 6) == "quest" ) then
			--We'll always color it yellow. We really need to fix this for Cata. (It will appear the correct color in the chat log)
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 12) == "achievement" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffff00%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 7) == "talent" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cff4e96f7%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 6) == "trade" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 8) == "enchant" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffffd000%1|r", 1));
		elseif ( strsub(text, startLink + 2, startLink + 11) == "collection" ) then
			return (gsub(text, "(|H.+|h.+|h)", "|cffff80ff%1|r", 1));
		end
	end

	--Nothing to change.
	return text;
end