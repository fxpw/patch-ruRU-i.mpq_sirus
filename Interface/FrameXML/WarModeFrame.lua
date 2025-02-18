local WARMODE_STATE = {
	DISABLED = 0,
	ENABLED = 1,
	DISABLED_FORCED = 2,
	ENABLED_FORCED = 3,
}

WarModeMixin = {}

function WarModeMixin:OnLoad()
	self.TLCorner:SetAtlas("Talent-TopLeftCurlies", true)
	self.TRCorner:SetAtlas("Talent-TopRightCurlies", true)
	self.BLCorner:SetAtlas("Talent-BottomLeftCurlies", true)
	self.BRCorner:SetAtlas("Talent-BottomRightCurlies", true)

	self.TopTile:SetAtlas("_Talent-Top-Tile")
	self.BottomTile:SetAtlas("_Talent-Bottom-Tile")

	self.TitleBackground:SetAtlas("GarrMission_RewardsBanner")

	self.Separator.Line:SetAtlas("covenantsanctum-divider-necrolord", true)

	self.ActiveInfo.BackgroundArtwork:SetAtlas("bonusobjectives-title-icon-honor")
	self.ActiveInfo.TextBackground:SetAtlas("covenantchoice-celebration-background")
	self.InactiveInfo.TextBackground:SetAtlas("covenantchoice-celebration-background")

	self.hideOnEscape = true
	self.exclusive = true

	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterCustomEvent("SERVICE_STATE_UPDATE")

	self.onCloseCallback = function()
		StaticPopupSpecial_Hide(self)
	end

	C_FactionManager:RegisterFactionOverrideCallback(function()
		local factionID, _, factionGroup = C_Unit.GetFactionInfo("player")
		self.factionID = factionID
		self.factionGroup = factionGroup
		self:UpdateFactionInfo()
	end, true, true)
end

function WarModeMixin:OnEvent(event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, msg, distribution, sender = ...
		if distribution ~= "UNKNOWN" or sender ~= UnitName("player") then
			return
		end

		if prefix == "ASMSG_WARMODE_SET_MODE" then
			local status, state, cooldownSeconds = string.split(":", msg)
			status = tonumber(status)

			if status == 0 then
				local cache = C_CacheInstance:Get("WARMODE")
				if not cache then
					cache = {}
					C_CacheInstance:Set("WARMODE", cache)
				end

				cache.state = tonumber(state) or -1
				cache.cooldown = time() + (tonumber(cooldownSeconds) or 0)

				local playAnimation
				if self.awaitAnswer then
					playAnimation = true
					self.awaitAnswer = nil
				end

				self.ActivateButton:UpdateState(playAnimation)
			else
				local errorText = _G["WARMODE_ERROR_"..status]
				if errorText then
					UIErrorsFrame:AddMessage(errorText, 1.0, 0.1, 0.1, 1.0)
				else
					GMError(string.format("[ASMSG_WARMODE_SET_MODE] Unknown Warmode status #%s", status))
				end
			end
		elseif prefix == "ASMSG_WARMODE_ASSIST_SET_INACTIVE" then
			FireCustomClientEvent("WARMODE_ASSIST_SET_INACTIVE", msg == "1")
		end
	elseif event == "SERVICE_STATE_UPDATE" then
		self.ActivateButton:UpdateState()
	end
end

function WarModeMixin:OnShow()
	SetParentFrameLevel(self.Separator, 0)
	SetParentFrameLevel(self.ActiveInfo, 0)
	SetParentFrameLevel(self.InactiveInfo, 0)
	SetParentFrameLevel(self.StateInfo, 1)
	SetParentFrameLevel(self.ActivateButton, 2)

	self:UpdateFactionInfo()
end

function WarModeMixin:UpdateFactionInfo()
	if self.factionID == PLAYER_FACTION_GROUP.Neutral then
		return
	end

	self.ActivateButton.Glow:SetAtlas("BattlegroundInvite-Queue-Button-Glow-"..self.factionGroup)
	self.ActivateButton:SetNormalAtlas("BattlegroundInvite-Queue-Button-Normal-"..self.factionGroup, true)
	self.ActivateButton:SetDisabledAtlas("BattlegroundInvite-Queue-Button-Normal-"..self.factionGroup, true)
	self.ActivateButton.DisabledTexture:SetDesaturated(true)
	self.ActivateButton:SetHighlightAtlas("BattlegroundInvite-Queue-Button-Highlight-"..self.factionGroup, true)

	self.ActivateButton.NormalTexture:SetVertexColor(0.41, 0.28, 0.06)
	self.ActivateButton.HighlightTexture:SetVertexColor(0.41, 0.28, 0.06)

	self.BottomGlowTexture:SetAtlas("scoreboard-header-"..self.factionGroup:lower())

	self.StateInfo.Background:SetAtlas("TalkingHeads-"..self.factionGroup.."-TextBackground")
	self.StateInfo.Text:SetText(self.factionID == PLAYER_FACTION_GROUP.Renegade and WAR_MODE_NORMAL_RENEGADE_TEXT or WAR_MODE_NORMAL_ALERT_TEXT)

	self.ActivateButton:UpdateState()
end

function WarModeMixin:GetTimeLeft()
	local cache = C_CacheInstance:Get("WARMODE")
	if cache and cache.cooldown then
		return cache.cooldown - time()
	end
	return -1
end

function WarModeMixin:GetState()
	local cache = C_CacheInstance:Get("WARMODE")
	return cache and cache.state or -1
end

function WarModeMixin:IsActive()
	local state = self:GetState()
	return state == WARMODE_STATE.ENABLED or state == WARMODE_STATE.ENABLED_FORCED
end

function WarModeMixin:CanChangeState()
	if self.factionID == PLAYER_FACTION_GROUP.Neutral
	or self.factionID == PLAYER_FACTION_GROUP.Renegade
	or self.BottomGlowTexture.animOut:IsPlaying()
	or self.BottomGlowTexture.animIn:IsPlaying()
	or not C_Service.CanChangeWarMode()
	or C_Service.HasActiveChallenges()
	then
		return false
	end
	return true
end

function WarModeMixin:ChangeState()
	if not self:CanChangeState() then
		return
	end

	if self.factionID == PLAYER_FACTION_GROUP.Renegade then
		UIErrorsFrame:AddMessage(WARMODE_ERROR_2, 1.0, 0.1, 0.1, 1.0)
	elseif not self.awaitAnswer then
		self.awaitAnswer = true
		SendServerMessage("ACMSG_WARMODE_SET_MODE", self:IsActive() and 0 or 1)
	end
end

WarModeActivateMixin = {}

function WarModeActivateMixin:OnClick(button)
	self:GetParent():ChangeState()
end

local STATE_TEXT = {
	[WARMODE_STATE.DISABLED]		= WAR_MODE_INACTIVE_STATUS_TEXT,
	[WARMODE_STATE.ENABLED]			= WAR_MODE_ACTIVE_STATUS_TEXT,
	[WARMODE_STATE.DISABLED_FORCED]	= WAR_MODE_INACTIVE_FORCED_STATUS_TEXT,
	[WARMODE_STATE.ENABLED_FORCED]	= WAR_MODE_ACTIVE_FORCED_STATUS_TEXT,
}

function WarModeActivateMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
	GameTooltip:AddLine(STATE_TEXT[self:GetParent():GetState()])
	if not self:GetParent():CanChangeState() and C_Service.HasActiveChallenges() then
		GameTooltip:AddLine(WAR_MODE_INACTIVE_REASON_HARDCORE, 1, 1, 1)
	end
	GameTooltip:Show()
end

function WarModeActivateMixin:OnLeave()
	GameTooltip:Hide()
end

function WarModeActivateMixin:OnEnable()
	self:UpdateState()
end

function WarModeActivateMixin:UpdateState(playAnimation)
	self.LockFrame:CheckCooldownTime()

	if self:GetParent():IsActive() then
		self.NormalTexture:SetVertexColor(1, 1, 1)
		self.HighlightTexture:SetVertexColor(1, 1, 1)

		self:GetParent().BottomGlowTexture:Show()
		self.Glow:Show()

		if playAnimation then
			self:GetParent().BottomGlowTexture.animIn:Play()
			self.animIn:Play()
			self.Glow.animIn:Play()
		end
	else
		self.NormalTexture:SetVertexColor(0.41, 0.28, 0.06)
		self.HighlightTexture:SetVertexColor(0.41, 0.28, 0.06)

		if playAnimation then
			self:GetParent().BottomGlowTexture.animOut:Play()
		end
	end

	if self:IsEnabled() == 1 and self:IsMouseOver() then
		self:OnEnter()
	end
end

function WarModeActivateMixin:StarInAnimation()
	self.NormalTexture:SetVertexColor(1, 1, 1)
	self.HighlightTexture:SetVertexColor(1, 1, 1)
end

WarModeActivateLockMixin = {}

function WarModeActivateLockMixin:OnLoad()
	self.LockIcon:SetAtlas("Monuments-Lock")
	self.LockIcon:SetDesaturated(true)
	self.TextBackground:SetAtlas("Monuments-LockedOverlay", true)
end

function WarModeActivateLockMixin:OnShow()
	self:GetParent():Disable()
end

function WarModeActivateLockMixin:OnHide()
	self:GetParent():Enable()
end

function WarModeActivateLockMixin:UpdateTime()
	if self.timeLeft > 0 then
		self.Timer:SetFormattedText(GetRemainingTime(math.ceil(self.timeLeft)))
		self.Timer:Show()
	else
		self.Timer:Hide()
	end
end

function WarModeActivateLockMixin:OnUpdate(elapsed)
	self.timeLeft = self.timeLeft - elapsed
	self:UpdateTime()
end

function WarModeActivateLockMixin:CheckCooldownTime()
	local mainFrame = self:GetParent():GetParent()
	local state = mainFrame:GetState()

	self.timeLeft = mainFrame:GetTimeLeft()

	if (self.timeLeft > 0 and not C_Service.IsInGMMode())
	or mainFrame.factionID == PLAYER_FACTION_GROUP.Neutral
	or mainFrame.factionID == PLAYER_FACTION_GROUP.Renegade
	or state == WARMODE_STATE.ENABLED_FORCED
	or state == WARMODE_STATE.DISABLED_FORCED
	then
		self:SetScript("OnUpdate", self.timeLeft > 0 and self.OnUpdate or nil)
		self:UpdateTime()
		self:Show()
	else
		self:Hide()
	end
end