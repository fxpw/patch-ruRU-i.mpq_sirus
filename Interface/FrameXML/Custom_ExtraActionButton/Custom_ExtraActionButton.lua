--	Filename:	Custom_ExtraActionButton.lua
--	Project:	Sirus Game Interface
--	Author:		Nyll
--	E-mail:		nyll@sirus.su
--	Web:		https://sirus.su/

ExtraActionButtonMixIn = {}
ExtraActionButtonMixIn.RegisteredButtons = {}

local CastSpellByID = CastSpellByID
local CastSpellByName = CastSpellByName

function ExtraActionButtonMixIn:AddButton( typeID, entityID, buttonStyle )
	local button = self:RegisterButton( entityID )

	if button then
		local name, icon
		local AttributeType = typeID == 0 and "item" or "spell"

		button:SetAttribute("type", AttributeType)
		button:SetAttribute(AttributeType, AttributeType..":"..entityID)

		if typeID == 0 then
			name, _, _, _, _, _, _, _, _, icon = GetItemInfo(entityID)
		else
			name, _, icon = GetSpellInfo(entityID)
			button:SetAttribute(AttributeType, name)
		end

		button.style:SetTexture("Interface\\ExtraButton\\"..buttonStyle)
		button.icon:SetTexture(icon)

		button.entityID = entityID
		button.typeID = typeID
		button.name = name

        if not self:FindOnActionBar(entityID) then
            button.outro:Stop()
            button.intro:Play()
        else
            button:Hide()
            button.hidden = true
        end
	end

	self:UpdateBar()
end

function ExtraActionButtonMixIn:RemoveButton( typeID, entityID )
	self:UnRegisterButton( entityID )
	self:UpdateBar()
end

function ExtraActionButtonMixIn:RegisterButton( entityID )
	if tCount( self.RegisteredButtons ) == #self.ExtraButtons then
		return nil
	end

	if self.RegisteredButtons[entityID] then
		return self.RegisteredButtons[entityID]
	end

	for i = 1, #self.ExtraButtons do
		local button = self.ExtraButtons[i]

		if not button.usable then
			self.RegisteredButtons[entityID] = button
			self.RegisteredButtons[entityID].usable = true
			return self.RegisteredButtons[entityID]
		end
	end
end

function ExtraActionButtonMixIn:UnRegisterButton( entityID )
	if self.RegisteredButtons[entityID] then
		self.RegisteredButtons[entityID].usable = false
		self.RegisteredButtons[entityID].outro:Play()
		self.RegisteredButtons[entityID] = nil
	end
end

function ExtraActionButtonMixIn:UpdateBindings()
	for i = 1, #self.ExtraButtons do
		local button = self.ExtraButtons[i]
		local key = GetBindingKey("EXTRAACTIONBUTTON"..i)
		local keyText = GetBindingText(key, "KEY_", 1)

		button.HotKey:SetShown(keyText and keyText ~= "")
		button.HotKey:SetText(keyText)
	end
end

function ExtraActionButtonMixIn:UpdateBar()
	local shownButtons = tCount( self.RegisteredButtons )

	self.outro:Stop()
	self.intro:Stop()

	if self:IsShown() then
		if shownButtons == 0 then
			self:Hide()
		end
	else
		if shownButtons > 0 then
			self.intro:Play()
		end
	end

	self:UpdateButtonPosition()
end

function ExtraActionButtonMixIn:UpdateButtonPosition()
	local buttonBuffer = {}

	for entityID, button in pairs(self.RegisteredButtons) do
		if not button.hidden then
			table.insert(buttonBuffer, button)
		end
	end

	local size = (230 / 2) * #buttonBuffer
	local offset = 0

	for i = 1, #buttonBuffer do
		local button = buttonBuffer[i]

		if button then
			button:ClearAllPoints()
			button:SetPoint("CENTER", -size + 230 * offset + 115, 0)

			offset = offset + 1
		end
	end

	self:SetWidth(#buttonBuffer * 230)
	self.Background:SetShown(self.isMovable and #buttonBuffer > 0)
end

function ExtraActionButtonMixIn:FindOnActionBar( entityID )
	local actionItemData = FindItemActionButtons( entityID )[1]
	local actionSpellData = FindSpellActionButtons( entityID )[1]

	if actionItemData or actionSpellData then
		return true
	end

	return false
end

function ExtraActionButtonMixIn:ToggleMoveBar( value )
	self.isMovable = value
	self.Background:SetShown(self.isMovable)

	if not value then
		self:StopMovingOrSizing()
	end
end

function ExtraActionBarFrame_OnLoad( self, ... )
	Mixin(self, ExtraActionButtonMixIn)

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:RegisterEvent("CVAR_UPDATE")

	self:RegisterForDrag("LeftButton")
end

function ExtraActionBarFrame_OnEvent( self, event, ... )
	if event == "UPDATE_BINDINGS" then
		self:UpdateBindings()
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		for entityID, button in pairs(self.RegisteredButtons) do
			if self:FindOnActionBar(entityID) then
				if not button.hidden then
					button.hidden = true
					-- button.outro:Play()
					button:Hide()
				end
			else
				if button.hidden then
					button.hidden = false
					-- button.intro:Play()
					button:Show()
				end
			end
		end
		self:UpdateButtonPosition()
	elseif event == "CVAR_UPDATE" then
		-- self:ToggleMoveBar( GetCVarBool("unlockMoveExtraButton") )
	end
end

function ExtraActionBarFrame_OnUpdate( self, ... )
	if self:IsShown() and IsShiftKeyDown() and self:IsMouseOver() then
		if not self.isMovable then
			self:ToggleMoveBar(true)
		end
	else
		if self.isMovable then
			self:ToggleMoveBar(false)
		end
	end
end

function ExtraActionButton_OnUpdate( self, elapsed, ... )
	self.elapsed = self.elapsed + elapsed

	if self.elapsed >= 0.1 then
		local count, start, duration, enable

		if self.typeID == 0 then
			count = GetItemCount(self.entityID, false, true)
			start, duration, enable = GetItemCooldown(self.entityID)
		else
			if self.name then
				count = GetSpellCount(self.name)
			end
			start, duration, enable = GetSpellCooldown(self.entityID)
		end

		self.Count:SetShown(count and count > 0)

		if count then
			self.Count:SetText(count)
		else
			self.Count:SetText(" ")
		end

		CooldownFrame_SetTimer(self.cooldown, start, duration, enable)

		self.elapsed = 0
	end
end

function ExtraActionButton_OnEnter( self, ... )
	if self.typeID and self.entityID then
		local AttributeType = self.typeID == 0 and "item" or "spell"

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
		GameTooltip:SetHyperlink("H"..AttributeType..":"..self.entityID)
		GameTooltip:AddLine(EXTRA_ACTION_BUTTON_MOVE_HELP, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

function ExtraActionButton_OnClick( self, button )
	local spell = SecureButton_GetModifiedAttribute(self, "spell", button)

	if spell then
		local spellID = tonumber(spell)
		if ( spellID) then
			CastSpellByID(spellID, unit)
		elseif ( spell ) then
			CastSpellByName(spell, unit)
		end
	else
		local item = SecureButton_GetModifiedAttribute(self, "item", button)
		local name, bag, slot = SecureCmdItemParse(item)

		if ( IsEquippableItem(name) and not IsEquippedItem(name) ) then
			EquipItemByName(name)
		else
			SecureCmdUseItem(name, bag, slot, unit)
		end
	end
end

function ExtraActionButton_OnDragStart( self, ... )
	local spell = self:GetAttribute("spell")
	local item = self:GetAttribute("item")

	if spell then
		PickupSpell(spell)
	elseif item then
		PickupItem(item)
	end
end

function ExtraActionButtonKey(id, isDown)
	if not ExtraActionBarFrame:IsShown() then
		return
	end

	local button = _G["ExtraActionBarFrameButton"..id]

	if isDown then
		if button:GetButtonState() == "NORMAL"  then
			button:SetButtonState("PUSHED")
		end
		if GetCVarBool("ActionButtonUseKeyDown") then
			button:Click()
		end
	else
		if button:GetButtonState() == "PUSHED" then
			button:SetButtonState("NORMAL")
			if not GetCVarBool("ActionButtonUseKeyDown") then
				button:Click()
			end
		end
	end
end

function EventHandler:INVOKE_CLIENT_BUTTON( msg )
	local typeID, entityID, buttonStyle = unpack(C_Split(msg, ":"))

	typeID 		= tonumber(typeID)
	entityID 	= tonumber(entityID)

	securecall(ExtraActionBarFrame.AddButton, ExtraActionBarFrame, typeID, entityID, buttonStyle)
end

function EventHandler:REMOVE_CLIENT_BUTTON( msg )
	local typeID, entityID = unpack(C_Split(msg, ":"))

	typeID 		= tonumber(typeID)
	entityID	= tonumber(entityID)

	ExtraActionBarFrame:RemoveButton( typeID, entityID )
end
