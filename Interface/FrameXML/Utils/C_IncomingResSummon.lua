Enum = Enum or {};
Enum.SummonStatus = {
	None = 0,
	Pending = 1,
	Accepted = 2,
	Declined = 3,
}

local summonList = {}
local resurrectList = {}

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
eventHandler:RegisterEvent("UNIT_MAXRAGE")
eventHandler:SetScript("OnEvent", function(self, event, unit)
	if event == "UNIT_MAXRAGE" then
		local unitName = UnitName(unit)
		if resurrectList[unitName] and not UnitIsDeadOrGhost(unit) then
			resurrectList[unitName] = nil
			FireCustomClientUnitNameGroupEvent("INCOMING_RESURRECT_CHANGED", unitName)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for unitName in pairs(resurrectList) do
			FireCustomClientUnitNameGroupEvent("INCOMING_RESURRECT_CHANGED", unitName)
			resurrectList[unitName] = nil
		end
		for unitName in pairs(summonList) do
			FireCustomClientUnitNameGroupEvent("INCOMING_SUMMON_CHANGED", unitName)
			summonList[unitName] = nil
		end
	end
end)

function EventHandler:ASMSG_INCOMING_SUMMON_CHANGED(msg)
	local status, unitName = string.split(",", msg)
	status = tonumber(status)
	summonList[unitName] = status
	FireCustomClientUnitNameGroupEvent("INCOMING_SUMMON_CHANGED", unitName)

	if status == Enum.SummonStatus.Accepted or status == Enum.SummonStatus.Declined then
		C_Timer:After(5, function()
			summonList[unitName] = nil
			FireCustomClientUnitNameGroupEvent("INCOMING_SUMMON_CHANGED", unitName)
		end)
	end
end

C_IncomingSummon = {}

function C_IncomingSummon.HasIncomingSummon(unit)
	for name, status in pairs(summonList) do
		if UnitIsUnit(unit, name) then
			return true
		end
	end
	return false
end

function C_IncomingSummon.IncomingSummonStatus(unit)
	for name, status in pairs(summonList) do
		if UnitIsUnit(unit, name) then
			return status
		end
	end
	return 0
end

function EventHandler:ASMSG_INCOMING_RESURRECT_CHANGED(msg)
	local status, unitName = string.split(",", msg)
	resurrectList[unitName] = tonumber(status) == 1 and true or nil
	FireCustomClientUnitNameGroupEvent("INCOMING_RESURRECT_CHANGED", unitName)
end

function UnitHasIncomingResurrection(unit)
	for name, status in pairs(resurrectList) do
		if UnitIsUnit(unit, name) then
			return true
		end
	end
	return false
end