do
	local _, _, _, enabled, _, reason = GetAddOnInfo("CombatLogFix")
	if reason ~= "MISSING" and enabled then
		return
	end
end

local playerSpells = setmetatable({}, {
	__index = function(tbl, name)
		local _, _, _, cost = GetSpellInfo(name)
		rawset(tbl, name, not not (cost and cost > 0))
		return rawget(tbl, name)
	end
})

local CLF = CreateFrame("Frame")
CLF:Hide()
CLF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
CLF:RegisterEvent("PLAYER_ENTERING_WORLD")
CLF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
CLF:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

CLF:SetScript("OnUpdate", function(self, elapsed)
	self.TIMEOUT = self.TIMEOUT - elapsed
	if self.TIMEOUT > 0 then return end

	self:Hide()

	if self.LAST_EVENT_TIME and (GetTime() - self.LAST_EVENT_TIME > (self.EVENT_MAX_LATANCY or 1)) then
		CombatLogClearEntries()
	end
end)

CLF:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		self.LAST_EVENT_TIME = GetTime()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, spellName, spellRank, castID = ...
		if UnitIsUnit(unit, "player") and spellName and playerSpells[spellName] then
			local _, _, latencyMS = GetNetStats()
			self.TIMEOUT = 0.50 + latencyMS * 0.001
			self.EVENT_MAX_LATANCY = self.TIMEOUT * 2
			self:Show()
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		local _, instanceType = IsInInstance()
		if self.CURRENT_INSTANCE_TYPE ~= instanceType then
			self.CURRENT_INSTANCE_TYPE = instanceType
			CombatLogClearEntries()
		end
	end
end)