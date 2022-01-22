
function DressUpItemLink(link)
	if ( not link or not IsDressableItem(link) ) then
		if ( link ) then
			local itemID = tonumber(string.match(link, "item:(%d+)"))
			if ( itemID ) then
				if ( LootCasePreviewFrame:IsPreview(itemID) ) then
					LootCasePreviewFrame:SetPreview(itemID);
				else
					local _, petID, _, _, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByItemID(itemID);
					if ( petID and creatureID ) then
						DressUpModel.petID = petID;
					else
						for index, data in ipairs(COLLECTION_MOUNTDATA) do
							if ( data.itemID == itemID and data.creatureID ) then
								creatureID = data.creatureID
								DressUpModel.index = index;
								break;
							end
						end
					end

					if ( creatureID ) then
						if ( not DressUpFrame:IsShown() ) then
							if ( StoreFrame:IsShown() ) then
								DressUpFrame:Show();
								DressUpFrame:ClearAllPoints();
								DressUpFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", UIParent:GetAttribute("LEFT_OFFSET") + 15, UIParent:GetAttribute("TOP_OFFSET") -10);
							else
								ShowUIPanel(DressUpFrame);
							end
						end
						if ( not DressUpModel.isCreature ) then
							DressUpModel.disabledZooming = true;
							DressUpModel.isCreature = true;
						end

						DressUpFrame.ResetButton:SetText(GO_TO_COLLECTION);
						DressUpModel:SetCreature(creatureID);
					end
				end
			end
		end
		return;
	end
	if StoreFrame:IsShown() then
		if not StoreDressUPFrame:IsShown() then
			StoreDressUPFrame:Show()
			StoreDressUPFrame.Display.DressUPModel:SetUnit("player")
		end
		StoreDressUPFrame.Display.DressUPModel:TryOn(link)
	else
		if ( DressUpModel.isCreature ) then
			DressUpFrame.ResetButton:SetText(RESET);
			DressUpModel.disabledZooming = nil;
			DressUpModel:SetUnit("player", true);
			DressUpModel.isCreature = false;
			DressUpModel.petID = nil;
			DressUpModel.index = nil;
		end

		if ( not DressUpFrame:IsShown() ) then
			ShowUIPanel(DressUpFrame);
			DressUpModel:SetUnit("player", true);
		end
		DressUpModel:TryOn(link);
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
