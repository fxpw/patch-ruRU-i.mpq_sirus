local LINK_TYPE = {
	NORMAL		= 0,
	LOOT_CASE	= 1,
	PET			= 2,
	MOUNT		= 3,
	ILLUSION	= 4,
}

function DressUpItemLink(link)
	if not link then
		return;
	end

	local id, linkType, collectionID

	if IsDressableItem(link) then
		id = link
		linkType = LINK_TYPE.NORMAL
	else
		local itemID = tonumber(string.match(link, "item:(%d+)"))
		if itemID then
			if LootCasePreviewFrame:IsPreview(itemID) then
				id = itemID
				linkType = LINK_TYPE.LOOT_CASE
			else
				local creatureID, petID
				petID, creatureID = select(9, C_PetJournal.GetPetInfoByItemID(itemID))

				if petID then
					id = creatureID
					linkType = LINK_TYPE.PET
					collectionID = petID
				else
					local mountID
					mountID, creatureID = select(10, C_MountJournal.GetMountFromItem(itemID))
					if mountID then
						id = creatureID
						linkType = LINK_TYPE.MOUNT
						collectionID = mountID
					end
				end

				if not creatureID then
					local _, enchantID = C_TransmogCollection.GetIllusionInfoByItemID(itemID)
					if enchantID then
						local weaponItemID = (GetInventoryTransmogID("player", 16) or GetInventoryItemID("player", 16)) or C_TransmogCollection.GetFallbackWeaponAppearance()
						if weaponItemID then
							id = string.format("item:%d:%d", weaponItemID, enchantID)
							linkType = LINK_TYPE.ILLUSION
						end
					end
				end
			end
		end
		if not linkType then
			return
		end
	end

	local wasCreature = DressUpModel.isCreature
	local isStoreDressUp = StoreFrame:IsShown()
	local isBattlePass = BattlePassFrame:IsShown()

	if isStoreDressUp then
		StoreDressUPFrame.creatureID = nil
	else
		DressUpModel.disabledZooming = nil
		DressUpModel.isCreature = nil
		DressUpModel.petID = nil
		DressUpModel.mountID = nil

		if isBattlePass then
			DressUpFrame:SetParent(BattlePassFrame)
			DressUpFrame:ClearAllPoints()

			local cursortPositionX = GetScaledCursorPosition()
			if cursortPositionX / GetScreenWidth() > 0.4 then
				DressUpFrame:SetPoint("LEFT", BattlePassFrame.Inset, "LEFT", 6, 16)
			else
				DressUpFrame:SetPoint("RIGHT", BattlePassFrame.Inset, "RIGHT", 0, 16)
			end

			DressUpFrame.ResetButton:Hide()
		else
			DressUpFrame.ResetButton:Show()

			if linkType == LINK_TYPE.PET or linkType == LINK_TYPE.MOUNT then
				DressUpFrame.ResetButton:SetText(GO_TO_COLLECTION)
			else
				DressUpFrame.ResetButton:SetText(RESET)
			end
		end
	end

	if linkType == LINK_TYPE.LOOT_CASE then
		LootCasePreviewFrame:SetPreview(id)
	elseif linkType == LINK_TYPE.PET or linkType == LINK_TYPE.MOUNT then
		if isStoreDressUp then
			if not StoreDressUPFrame:IsShown() then
				StoreDressUPFrame:Show()
			end
			StoreDressUPFrame.creatureID = id
			StoreDressUPFrame.Display.DressUPModel:SetCreature(id)
		else
			if linkType == LINK_TYPE.PET then
				DressUpModel.petID = collectionID
			else
				DressUpModel.mountID = collectionID
			end

			if not wasCreature then
				DressUpModel.disabledZooming = true
				DressUpModel.isCreature = true
			end

			DressUpFrame:Show()
			DressUpModel:SetCreature(id)
		end
	elseif linkType == LINK_TYPE.NORMAL or linkType == LINK_TYPE.ILLUSION then
		if isStoreDressUp then
			if not StoreDressUPFrame:IsShown() then
				StoreDressUPFrame:Show()
				StoreDressUPFrame.Display.DressUPModel:SetUnit("player")
			end
			StoreDressUPFrame.Display.DressUPModel:TryOn(id)
		else
			if wasCreature then
				DressUpModel:SetUnit("player", true)
			end

			if not DressUpFrame:IsShown() then
				if isBattlePass then
					DressUpFrame:Show()
				else
					ShowUIPanel(DressUpFrame)
				end
				DressUpModel:SetUnit("player", true)
			end

			if isBattlePass then
				DressUpFrame:ClearAllPoints()
				local cursortPositionX = GetScaledCursorPosition()
				if cursortPositionX / GetScreenWidth() > 0.4 then
					DressUpFrame:SetPoint("LEFT", BattlePassFrame.Inset, "LEFT", 6, 16)
				else
					DressUpFrame:SetPoint("RIGHT", BattlePassFrame.Inset, "RIGHT", 0, 16)
				end
			end

			DressUpModel:TryOn(id)
		end
	end
end

function DressUpTexturePath()
	return GetDressUpTexturePath("player")
end

function GetDressUpTexturePath( unit )
	local race, fileName = UnitRace(unit or "player")

	if string.upper(fileName) == "QUELDO" then
		fileName = "Nightborne"
	elseif string.upper(fileName) == "NAGA" then
		fileName = "NightElf"
	elseif string.upper(fileName) == "LIGHTFORGED" then
		fileName = "LightforgedDraenei"
	end

	if not fileName then
		fileName = "Orc"
	end

	return "Interface\\DressUpFrame\\DressUpBackground-"..fileName;
end

function GetDressUpTextureAlpha( unit )
	local race, fileName = UnitRace(unit or "player")

	if string.upper(fileName) == "BLOODELF" then
		return 0.8
	elseif string.upper(fileName) == "NIGHTELF" or string.upper(fileName) == "NAGA" then
		return 0.6
	elseif string.upper(fileName) == "SCOURGE" then
		return 0.3
	elseif string.upper(fileName) == "TROLL" or string.upper(fileName) == "ORC" then
		return 0.6
	elseif string.upper(fileName) == "WORGEN" then
		return 0.5
	elseif string.upper(fileName) == "GOBLIN" then
		return 0.6
	else
		return 0.7
	end
end

function DressUpFrame_OnLoad(self, ...)
	local _, classFileName = UnitClass("player")
	DressUpModel.ModelBackground:SetAtlas("dressingroom-background-"..string.lower(classFileName), true)

	self.TitleText:SetText(DRESSUP_FRAME)
end