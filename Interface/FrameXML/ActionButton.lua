CURRENT_ACTIONBAR_PAGE = 1;
NUM_ACTIONBAR_PAGES = 6;
NUM_ACTIONBAR_BUTTONS = 12;
ATTACK_BUTTON_FLASH_TIME = 0.4;

BOTTOMLEFT_ACTIONBAR_PAGE = 6;
BOTTOMRIGHT_ACTIONBAR_PAGE = 5;
LEFT_ACTIONBAR_PAGE = 4;
RIGHT_ACTIONBAR_PAGE = 3;
RANGE_INDICATOR = "●";

ITEM_ACTION_DATA = {}
SPELL_ACTION_DATA = {}
ON_BAR_HIGHLIGHT_MARKS = {}

-- Table of actionbar pages and whether they're viewable or not
VIEWABLE_ACTION_BAR_PAGES = {1, 1, 1, 1, 1, 1};

--Overlay stuff
local spellOverlayCache = {}
function IsSpellOverlayed( spell, spellRank )
	local spellID

	if SpellOverlay_SpellHighlightAlphaSlider.value == 0 then
		return nil
	end

	if type(spell) == "number" then
		spellID = spell
	else
		spellID = GetSpellIDFromSpellName(spell, spellRank)
	end

	if not spellID then
		return false
	end

	return SPELLOVERLAY_HIGHLIGHT[spellID]
end

function GetSpellIDFromSpellName( spellName, spellRank )
	local spellID = nil

	if spellRank then
		local unitLevel = UnitLevel("player")

		if not spellOverlayCache[unitLevel] then
			spellOverlayCache[unitLevel] = {}

			local index = 1
			local name, rank = GetSpellInfo(index, "spell")
			local spellLink = GetSpellLink(index, "spell")

			while name do
				local _spellID = tonumber(string.match(spellLink, "spell:(%d*)"))
				spellOverlayCache[unitLevel][_spellID] = {name, rank}

				index = index + 1
				name, rank = GetSpellInfo(index, "spell")
				spellLink = GetSpellLink(index, "spell")
			end
		end

		for _spellID, spellData in pairs(spellOverlayCache[unitLevel]) do
			if spellData[1] == spellName and spellData[2] == spellRank then
				spellID = _spellID
				break
			end
		end
	else
		local spellLink = GetSpellLink(spellName)
		if spellLink then
			spellID = tonumber(string.match(spellLink, "spell:(%d*)"))
		end
	end

	return spellID
end

function GetActionSpellID( action )
	local spellType, id, subType, spellID  = GetActionInfo(action)

	if spellType == "spell" or spellType == "flyout" then
		return spellID
	elseif spellType == "macro" then
		local spellName, spellRank, id = GetMacroSpell(id)

		if spellName then
			return GetSpellIDFromSpellName(spellName, spellRank)
		end
	end

	return nil
end

function ActionButton_OverlayAnimInPlay( self )
	if not self:IsShown() then
		self:Show()
	end

	self.spark.animIn:Play()
	self.innerGlow.animIn:Play()
	self.innerGlowOver.animIn:Play()
	self.outerGlow.animIn:Play()
	self.outerGlowOver.animIn:Play()
	self.ants.animIn:Play()
end

function ActionButton_OverlayAnimInStop( self )
	self.spark.animIn:Stop()
	self.innerGlow.animIn:Stop()
	self.innerGlowOver.animIn:Stop()
	self.outerGlow.animIn:Stop()
	self.outerGlowOver.animIn:Stop()
	self.ants.animIn:Stop()
end

function ActionButton_OverlayAnimInIsPlaying( self )
	if not self.spark then
		return false
	end

	for _, anim in pairs({self.spark.animIn, self.innerGlow.animIn, self.innerGlowOver.animIn, self.outerGlow.animIn, self.outerGlowOver.animIn, self.ants.animIn}) do
		if anim:IsPlaying() then
			return true
		end
	end
end

function ActionButton_OverlayAnimOutPlay( self )
	if self.outerGlow then
		self.outerGlow.animOut:Play()
		self.outerGlowOver.animOut:Play()
		self.ants.animOut:Play()
	end
end

function ActionButton_OverlayAnimOutStop( self )
	if self.outerGlow then
		self.outerGlow.animOut:Stop()
		self.outerGlowOver.animOut:Stop()
		self.ants.animOut:Stop()
	end
end

function ActionButton_OverlayAnimOutIsPlaying( self )
	for _, anim in pairs({self.outerGlow.animOut, self.outerGlowOver.animOut, self.ants.animOut}) do
		if anim:IsPlaying() then
			return true
		end
	end
end

local usedOverlayGlows = {}
local unusedOverlayGlows = {}
local numOverlays = 0
function ActionButton_GetOverlayGlow()
	local overlay = tremove(unusedOverlayGlows);
	if ( not overlay ) then
		numOverlays = numOverlays + 1
		overlay = CreateFrame("Frame", "ActionButtonOverlay"..numOverlays, UIParent, "ActionBarButtonSpellActivationAlert")
	end

	if SpellOverlay_SpellHighlightAlphaSlider.value then
		overlay:SetAlpha(SpellOverlay_SpellHighlightAlphaSlider.value)
	end

	usedOverlayGlows[overlay] = true

	return overlay
end

function ActionButton_UpdateOverlayGlow(self)
	local spellType, id, subType, spellID  = GetActionInfo(self.action)
	if ( spellType == "spell" and IsSpellOverlayed(spellID) ) then
		ActionButton_ShowOverlayGlow(self)
	elseif ( spellType == "macro" ) then
		local spellName, spellRank, id = GetMacroSpell(id)
		if ( spellName ) then
			if ( spellName and IsSpellOverlayed(spellName, spellRank) ) then
				ActionButton_ShowOverlayGlow(self)
			else
				ActionButton_HideOverlayGlow(self)
			end
		end
	else
		ActionButton_HideOverlayGlow(self)
	end
end

function ActionButton_ShowOverlayGlow(self)
	if BonusActionBarFrame:IsShown() and self:GetParent():GetName() == "MainMenuBarArtFrame" then
		return
	end

	if ( self.overlay ) then
		if ( ActionButton_OverlayAnimOutIsPlaying(self.overlay) ) then
			ActionButton_OverlayAnimOutStop(self.overlay)
			ActionButton_OverlayAnimInPlay(self.overlay)
		end
	else
		self.overlay = ActionButton_GetOverlayGlow()
		local frameWidth, frameHeight = self:GetSize()
		self.overlay:SetParent(self)
		self.overlay:ClearAllPoints()
		--Make the height/width available before the next frame:
		self.overlay:SetSize(frameWidth * 1.4, frameHeight * 1.4)
		self.overlay:SetPoint("TOPLEFT", self, "TOPLEFT", -frameWidth * 0.2, frameHeight * 0.2)
		self.overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", frameWidth * 0.2, -frameHeight * 0.2)
		ActionButton_OverlayAnimInPlay(self.overlay)
	end
end

function ActionButton_HideOverlayGlow(self)
	if ( self.overlay ) then
		if ( ActionButton_OverlayAnimInIsPlaying(self.overlay) ) then
			ActionButton_OverlayAnimInStop(self.overlay)
		end
		if ( self:IsVisible() ) then
			ActionButton_OverlayAnimOutPlay(self.overlay)
		else
			ActionButton_OverlayGlowAnimOutFinished(self.overlay.animOut)	--We aren't shown anyway, so we'll instantly hide it.
		end
	end
end

function ActionButton_OverlayGlowAnimOutFinished(animGroup)
	if not animGroup then
		return
	end

	local overlay = animGroup:GetParent():GetParent()
	local actionButton = overlay:GetParent()

	if not actionButton.overlay then
		return
	end

	actionButton.overlay = nil
	overlay:Hide()

	if usedOverlayGlows[overlay] then
		usedOverlayGlows[overlay] = nil
		tinsert(unusedOverlayGlows, overlay)
	end
end

function ActionButton_AllOverlayAlphaUpdate( alpha )
	for overlay in pairs(usedOverlayGlows) do
		overlay:SetAlpha(alpha)
	end
end

function ActionButton_OverlayGlowOnUpdate(self, elapsed)
	_AnimateTexCoords(self.ants, 256, 256, 48, 48, 22, elapsed, 0.01)
	-- local cooldown = self:GetParent().cooldown
	-- -- we need some threshold to avoid dimming the glow during the gdc
	-- -- (using 1500 exactly seems risky, what if casting speed is slowed or something?)
	-- local start, duration, enable = GetActionCooldown(self:GetParent().action)
	-- if(cooldown and cooldown:IsShown()) and duration > 3000 then
	-- 	-- self:SetAlpha(0.5)
	-- else
	-- 	-- self:SetAlpha(1.0)
	-- end
end
-- ======

function ActionButtonDown(id)
	local button;
	if ( VehicleMenuBar:IsShown() and id <= VEHICLE_MAX_ACTIONBUTTONS ) then
		button = _G["VehicleMenuBarActionButton"..id];
	elseif ( BonusActionBarFrame:IsShown() ) then
		button = _G["BonusActionButton"..id];
	else
		button = _G["ActionButton"..id];
	end
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function ActionButtonUp(id)
	local button;
	if ( VehicleMenuBar:IsShown() and id <= VEHICLE_MAX_ACTIONBUTTONS ) then
		button = _G["VehicleMenuBarActionButton"..id];
	elseif ( BonusActionBarFrame:IsShown() ) then
		button = _G["BonusActionButton"..id];
	else
		button = _G["ActionButton"..id];
	end
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		SecureActionButton_OnClick(button, "LeftButton");
		ActionButton_UpdateState(button);
	end
end

function ActionBar_PageUp()
	local nextPage;
	for i=GetActionBarPage() + 1, NUM_ACTIONBAR_PAGES do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			nextPage = i;
			break;
		end
	end

	if ( not nextPage ) then
		nextPage = 1;
	end
	ChangeActionBarPage(nextPage);
end

function ActionBar_PageDown()
	local prevPage;
	for i=GetActionBarPage() - 1, 1, -1 do
		if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
			prevPage = i;
			break;
		end
	end

	if ( not prevPage ) then
		for i=NUM_ACTIONBAR_PAGES, 1, -1 do
			if ( VIEWABLE_ACTION_BAR_PAGES[i] ) then
				prevPage = i;
				break;
			end
		end
	end
	ChangeActionBarPage(prevPage);
end

local actionButtonStorage = {}

function ActionButton_UpdateAllAction()
	for _, action in pairs(actionButtonStorage) do
		ActionButton_UpdateOverlayGlow(action)
	end
end

function ActionButton_OnLoad (self)
	table.insert(actionButtonStorage, self)

	self.flashing = 0;
	self.flashtime = 0;
	self:SetAttribute("_ignore", true);
	self:SetAttribute("showgrid", 0);
	self:SetAttribute("type", "action");
	self:SetAttribute("checkselfcast", true);
	self:SetAttribute("checkfocuscast", true);
	self:SetAttribute("useparent-unit", true);
	self:SetAttribute("useparent-actionpage", true);
	self:SetAttribute("_ignore", nil);
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ACTIONBAR_SHOWGRID");
	self:RegisterEvent("ACTIONBAR_HIDEGRID");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	ActionButton_UpdateAction(self);
	ActionButton_UpdateHotkeys(self, self.buttonType);
end

function ActionButton_UpdateHotkeys (self, actionButtonType)
	local id;
    if ( not actionButtonType ) then
        actionButtonType = "ACTIONBUTTON";
		id = self:GetID();
	else
		if ( actionButtonType == "MULTICASTACTIONBUTTON" ) then
			id = self.buttonIndex;
		else
			id = self:GetID();
		end
    end

    local hotkey = _G[self:GetName().."HotKey"];
    local key = GetBindingKey(actionButtonType..id) or
                GetBindingKey("CLICK "..self:GetName()..":LeftButton");

	local text = GetBindingText(key, "KEY_", 1);
    if ( text == "" ) then
        hotkey:SetText(RANGE_INDICATOR);
        hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -2);
        hotkey:Hide();
    else
        hotkey:SetText(text);
        hotkey:SetPoint("TOPLEFT", self, "TOPLEFT", -2, -2);
        hotkey:Show();
    end
end

function ActionButton_CalculateAction (self, button)
	if ( not button ) then
		button = SecureButton_GetEffectiveButton(self);
	end
	if ( self:GetID() > 0 ) then
		local page = SecureButton_GetModifiedAttribute(self, "actionpage", button);
		if ( not page ) then
			page = GetActionBarPage();
			if ( self.isBonus and (page == 1 or self.alwaysBonus) ) then
				local offset = GetBonusBarOffset();
				if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
					offset = BonusActionBarFrame.lastBonusBar;
				end
				page = NUM_ACTIONBAR_PAGES + offset;
			elseif ( self.buttonType == "MULTICASTACTIONBUTTON" ) then
				page = NUM_ACTIONBAR_PAGES + GetMultiCastBarOffset();
			end
		end
		return (self:GetID() + ((page - 1) * NUM_ACTIONBAR_BUTTONS));
	else
		return SecureButton_GetModifiedAttribute(self, "action", button) or 1;
	end
end

function ActionButton_UpdateAction (self)
	local action = ActionButton_CalculateAction(self);
	if ( action ~= self.action ) then
		self.action = action;
		ActionButton_Update(self);
	end
end


function FindSpellActionButtons( spellID )
	if not spellID or spellID == "" then
		return
	end

	local frameData = {}

	for k, v in pairs(SPELL_ACTION_DATA) do
		if v == spellID then
			local frame = _G[k]
			if frame then
				table.insert(frameData, frame)
			end
		end
	end
	return frameData
end

function FindItemActionButtons( itemID )
	if not itemID or itemID == "" then
		return
	end

	local frameData = {}

	for k, v in pairs(ITEM_ACTION_DATA) do
		if v == itemID then
			local frame = _G[k]
			if frame then
				table.insert(frameData, frame)
			end
		end
	end
	return frameData
end

function ClearOnBarHighlightMarks()
	local frameData = {}
	for k, v in pairs(SPELL_ACTION_DATA) do
		local frame = _G[k]
		if frame then
			table.insert(frameData, frame)
		end
	end
	SharedActionButton_RefreshSpellHighlight(frameData, false)
end

function UpdateOnBarHighlightMarksBySpell(spellID)
	ClearOnBarHighlightMarks()
	SharedActionButton_RefreshSpellHighlight(FindSpellActionButtons(spellID), true)
end

function SharedActionButton_RefreshSpellHighlight(data, shown)
	if not data then
		return
	end

	for i = 1, #data do
		local frame = data[i]
		if frame then
			if frame.SpellHighlightTexture then
				if ( shown ) then
					frame.SpellHighlightTexture:Show();
					frame.SpellHighlightTexture.SpellHighlightAnim:Play();
				else
					frame.SpellHighlightTexture:Hide();
					frame.SpellHighlightTexture.SpellHighlightAnim:Stop();
				end
			end
		end
	end
end


function ActionButton_Update (self)
	local name = self:GetName();

	local action = self.action;
	local icon = _G[name.."Icon"];
	local buttonCooldown = _G[name.."Cooldown"];
	local texture = GetActionTexture(action);

	if action then
		SPELL_ACTION_DATA[name] = nil
		ITEM_ACTION_DATA[name] = nil
	end

	if ( HasAction(action) ) then
		local actionType, id, subType, spellID = GetActionInfo(action)

		if spellID then
			SPELL_ACTION_DATA[name] = spellID
		elseif actionType == "macro" and id then
			local spellName, spellRank = GetMacroSpell(id)
			if spellName then
				local spellLink = GetSpellLink(spellName, spellRank)

				if spellLink then
					spellID = tonumber(string.match(spellLink, "spell:(%d+)"))

					if spellID then
						SPELL_ACTION_DATA[name] = spellID
					end
				end
			end
		elseif actionType == "item" and id then
			ITEM_ACTION_DATA[name] = id
		end

		if ( not self.eventsRegistered ) then
			self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
			self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self:RegisterEvent("UPDATE_INVENTORY_ALERTS");
			self:RegisterEvent("PLAYER_TARGET_CHANGED");
			self:RegisterEvent("TRADE_SKILL_SHOW");
			self:RegisterEvent("TRADE_SKILL_CLOSE");
			self:RegisterEvent("PLAYER_ENTER_COMBAT");
			self:RegisterEvent("PLAYER_LEAVE_COMBAT");
			self:RegisterEvent("START_AUTOREPEAT_SPELL");
			self:RegisterEvent("STOP_AUTOREPEAT_SPELL");
			self:RegisterEvent("UNIT_ENTERED_VEHICLE");
			self:RegisterEvent("UNIT_EXITED_VEHICLE");
			self:RegisterEvent("COMPANION_UPDATE");
			self:RegisterEvent("UNIT_INVENTORY_CHANGED");
			self:RegisterEvent("LEARNED_SPELL_IN_TAB");
			self.eventsRegistered = true;
		end

		if ( not self:GetAttribute("statehidden") ) then
			self:Show();
		end
		ActionButton_UpdateState(self);
		ActionButton_UpdateUsable(self);
		ActionButton_UpdateCooldown(self);
		ActionButton_UpdateFlash(self);
	else
		SPELL_ACTION_DATA[name] = false
		ITEM_ACTION_DATA[name] = false
		if ( self.eventsRegistered ) then
			self:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
			self:UnregisterEvent("PLAYER_TARGET_CHANGED");
			self:UnregisterEvent("TRADE_SKILL_SHOW");
			self:UnregisterEvent("TRADE_SKILL_CLOSE");
			self:UnregisterEvent("PLAYER_ENTER_COMBAT");
			self:UnregisterEvent("PLAYER_LEAVE_COMBAT");
			self:UnregisterEvent("START_AUTOREPEAT_SPELL");
			self:UnregisterEvent("STOP_AUTOREPEAT_SPELL");
			self:UnregisterEvent("UNIT_ENTERED_VEHICLE");
			self:UnregisterEvent("UNIT_EXITED_VEHICLE");
			self:UnregisterEvent("COMPANION_UPDATE");
			self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
			self:UnregisterEvent("LEARNED_SPELL_IN_TAB");
			self.eventsRegistered = nil;
		end

		if ( self:GetAttribute("showgrid") == 0 ) then
			self:Hide();
		else
			buttonCooldown:Hide();
		end

		if ActionButton_IsFlashing(self) then
			ActionButton_StopFlash(self);
		end

		self:SetChecked(false);
	end

	-- Add a green border if button is an equipped item
	local border = _G[name.."Border"];
	if border then
		if ( IsEquippedAction(action) ) then
			border:SetVertexColor(0, 1.0, 0, 0.35);
			border:Show();
		else
			border:Hide();
		end
	end

	-- Update Action Text
	local actionName = _G[name.."Name"];
	if actionName then
		if ( not IsConsumableAction(action) and not IsStackableAction(action) ) then
			actionName:SetText(GetActionText(action));
		else
			actionName:SetText("");
		end
	end

	-- Update icon and hotkey text
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		self.rangeTimer = -1;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
	else
		icon:Hide();
		buttonCooldown:Hide();
		self.rangeTimer = nil;
		self:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
		local hotkey = _G[name.."HotKey"];
        if ( hotkey:GetText() == RANGE_INDICATOR ) then
			hotkey:Hide();
		else
			hotkey:SetVertexColor(0.6, 0.6, 0.6);
		end
	end
	ActionButton_UpdateCount(self);
	ActionButton_UpdateFlyout(self)
	-- ActionButton_UpdateOverlayGlow(self)

	-- Update tooltip
	if ( GameTooltip:GetOwner() == self ) then
		ActionButton_SetTooltip(self);
	end

	self.feedback_action = action;
end

function ActionButton_ShowGrid (button)
	assert(button);

	if ( issecure() ) then
		button:SetAttribute("showgrid", button:GetAttribute("showgrid") + 1);
	end

	_G[button:GetName().."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5);

	if ( button:GetAttribute("showgrid") >= 1 and not button:GetAttribute("statehidden") ) then
		button:Show();
	end
end

function ActionButton_HideGrid (button)
	assert(button);

	local showgrid = button:GetAttribute("showgrid");

	if ( issecure() ) then
		if ( showgrid > 0 ) then
			button:SetAttribute("showgrid", showgrid - 1);
		end
	end

	if ( button:GetAttribute("showgrid") == 0 and not HasAction(button.action) ) then
		button:Hide();
	end
end

function ActionButton_UpdateState (button)
	assert(button);

	local action = button.action;
	if ( IsCurrentAction(action) or IsAutoRepeatAction(action) ) then
		button:SetChecked(1);
	else
		button:SetChecked(0);
	end
end

function ActionButton_UpdateUsable(self)
	local name = self:GetName();
	local icon = _G[name.."Icon"];
	local normalTexture = _G[name.."NormalTexture"];
	if ( not normalTexture ) then
		return;
	end

	local isUsable, notEnoughMana = IsUsableAction(self.action);
	if ( isUsable ) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);

		Hook:FireEvent("UPDATE_USABLE_ACTION", "ENABLED", self)
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
		normalTexture:SetVertexColor(0.5, 0.5, 1.0);

		Hook:FireEvent("UPDATE_USABLE_ACTION", "ENABLED_NOT_ENOUGH_RESOURCE", self)
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
		normalTexture:SetVertexColor(1.0, 1.0, 1.0);

		Hook:FireEvent("UPDATE_USABLE_ACTION", "DISABLED", self)
	end
end

function ActionButton_UpdateCount (self)
	local text = _G[self:GetName().."Count"];
	local action = self.action;
	if ( IsConsumableAction(action) or IsStackableAction(action) ) then
		local count = GetActionCount(action);
		if ( count > (self.maxDisplayCount or 9999 ) ) then
			text:SetText("*");
		else
			text:SetText(count);
		end
	else
		text:SetText("");
	end
end

function ActionButton_UpdateCooldown (self)
	local cooldown = _G[self:GetName().."Cooldown"];
	local start, duration, enable

	if self.spellID then
		start, duration, enable = GetSpellCooldown(self.spellID)
	else
		start, duration, enable = GetActionCooldown(self.action)
	end

	CooldownFrame_SetTimer(cooldown, start, duration, enable)
end

function ActionButton_OnEvent (self, event, ...)
	local arg1 = ...;
	if ((event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") or event == "LEARNED_SPELL_IN_TAB") then
		if ( GameTooltip:GetOwner() == self ) then
			ActionButton_SetTooltip(self);
		end
	end
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == tonumber(self.action) ) then
			ActionButton_Update(self);
			ExtraActionBarFrame_OnActionBarSlotUpdate(ExtraActionBarFrame);
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		ActionButton_Update(self);
		ExtraActionBarFrame_OnActionBarSlotUpdate(ExtraActionBarFrame);
		return;
	end
	if ( event == "ACTIONBAR_PAGE_CHANGED" or event == "UPDATE_BONUS_ACTIONBAR" ) then
		ActionButton_UpdateAction(self);
		return;
	end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		ActionButton_ShowGrid(self);
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		ActionButton_HideGrid(self);
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys(self, self.buttonType);
		return;
	end

	-- All event handlers below this line are only set when the button has an action

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( (event == "ACTIONBAR_UPDATE_STATE") or
		((event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) or
		((event == "COMPANION_UPDATE") and (arg1 == "MOUNT")) ) then
		ActionButton_UpdateState(self);
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" ) then
		ActionButton_UpdateUsable(self);
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		ActionButton_UpdateCooldown(self);
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		ActionButton_UpdateState(self);
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(self.action) ) then
			ActionButton_StartFlash(self);
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(self.action) ) then
			ActionButton_StopFlash(self);
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(self.action) ) then
			ActionButton_StartFlash(self);
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( ActionButton_IsFlashing(self) and not IsAttackAction(self.action) ) then
			ActionButton_StopFlash(self);
		end
	end
end

function ActionButton_SetTooltip (self)
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		local parent = self:GetParent();
		if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end
	end
	if ( GameTooltip:SetAction(self.action) ) then
		self.UpdateTooltip = ActionButton_SetTooltip;
	else
		self.UpdateTooltip = nil;
	end
end

function ActionButton_OnUpdate (self, elapsed)
	if ( ActionButton_IsFlashing(self) ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;

		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = _G[self:GetName().."Flash"];
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end

		self.flashtime = flashtime;
	end

	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed;

		if ( rangeTimer <= 0 ) then
			local count = _G[self:GetName().."HotKey"];
			local valid = IsActionInRange(self.action);
			if ( count:GetText() == RANGE_INDICATOR ) then
				if ( valid == 0 ) then
					count:Show();
					count:SetVertexColor(1.0, 0.1, 0.1);
				elseif ( valid == 1 ) then
					count:Show();
					count:SetVertexColor(0.6, 0.6, 0.6);
				else
					count:Hide();
				end
			else
				if ( valid == 0 ) then
					count:SetVertexColor(1.0, 0.1, 0.1);
				else
					count:SetVertexColor(0.6, 0.6, 0.6);
				end
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end

		self.rangeTimer = rangeTimer;
	end
end

function ActionButton_GetPagedID (self)
    return self.action;
end

function ActionButton_UpdateFlash (self)
	local action = self.action;
	if ( (IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action) ) then
		ActionButton_StartFlash(self);
	else
		ActionButton_StopFlash(self);
	end
end

function ActionButton_StartFlash (self)
	self.flashing = 1;
	self.flashtime = 0;
	ActionButton_UpdateState(self);
end

function ActionButton_StopFlash (self)
	self.flashing = 0;
	_G[self:GetName().."Flash"]:Hide();
	ActionButton_UpdateState (self);
end

function ActionButton_IsFlashing (self)
	if ( self.flashing == 1 ) then
		return 1;
	end

	return nil;
end

function ActionButton_UpdateFlyout(self)
	if not self.FlyoutArrow then
		return;
	end

	local actionType = GetActionInfo(self.action);
	if (actionType == "flyout") then
		-- Update border and determine arrow position
		local arrowDistance;
		if ((SpellFlyout and SpellFlyout:IsShown() and SpellFlyout:GetParent() == self) or GetMouseFocus() == self) then
			self.FlyoutBorder:Show();
			self.FlyoutBorderShadow:Show();
			arrowDistance = 5;
		else
			self.FlyoutBorder:Hide();
			self.FlyoutBorderShadow:Hide();
			arrowDistance = 2;
		end

		-- Update arrow
		self.FlyoutArrow:Show();
		self.FlyoutArrow:ClearAllPoints();
		local direction = self:GetAttribute("flyoutDirection");
		if (direction == "LEFT") then
			self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0);
			SetClampedTextureRotation(self.FlyoutArrow, 270);
		elseif (direction == "RIGHT") then
			self.FlyoutArrow:SetPoint("RIGHT", self, "RIGHT", arrowDistance, 0);
			SetClampedTextureRotation(self.FlyoutArrow, 90);
		elseif (direction == "DOWN") then
			self.FlyoutArrow:SetPoint("BOTTOM", self, "BOTTOM", 0, -arrowDistance);
			SetClampedTextureRotation(self.FlyoutArrow, 180);
		else
			self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance);
			SetClampedTextureRotation(self.FlyoutArrow, 0);
		end
	else
		self.FlyoutBorder:Hide();
		self.FlyoutBorderShadow:Hide();
		self.FlyoutArrow:Hide();
	end
end
