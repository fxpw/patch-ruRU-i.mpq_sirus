local pcall = pcall
local setmetatable = setmetatable
local tinsert, tremove = table.insert, table.remove

local issecure = issecure
local securecall = securecall

local TIMER_DURATION = 1
local TIMER_TICKER = 2

local function updateTimers(elapsed, timers, secure)
	for i = 1, #timers do
		local timer = tremove(timers, 1)
		if timer[TIMER_TICKER]._cancelled then
			-- skip
		elseif timer[TIMER_DURATION] > elapsed then
			timer[TIMER_DURATION] = timer[TIMER_DURATION] - elapsed
			tinsert(timers, timer)
		else
			local success, err
			if secure then
				success, err = securecall(pcall, timer[TIMER_TICKER]._callback)
			else
				success, err = pcall(timer[TIMER_TICKER]._callback)
			end

			if not success then
				geterrorhandler()(err)
			end
		end
	end
end

local secureTimers = {}
local addonTimers = {}
local updateHandler = CreateFrame("Frame")
updateHandler:SetScript("OnUpdate", function(self, elapsed)
	updateTimers(elapsed, secureTimers, true)
	updateTimers(elapsed, addonTimers)
end)

local function addDelayedCall(delay, func)
	local callbackData = {
		[TIMER_DURATION] = delay,
		[TIMER_TICKER] = func,
	}

	if issecure() then
		tinsert(secureTimers, callbackData)
	else
		tinsert(addonTimers, callbackData)
	end
end

C_Timer = {}

local TickerPrototype = {}
local TickerMetatable = {
	__index = TickerPrototype,
	__metatable = true
}

function C_Timer:NewTicker(duration, callback, iterations)
	local ticker = setmetatable({}, TickerMetatable)
	ticker._remainingIterations = iterations
	ticker._duration = duration
	ticker._callback = function()
		securecall(callback, ticker)

		if ticker._remainingIterations then
			ticker._remainingIterations = ticker._remainingIterations - 1
		end

		if not ticker._remainingIterations or ticker._remainingIterations > 0 then
			addDelayedCall(ticker._duration, ticker)
		end
	end

	addDelayedCall(ticker._duration, ticker)

	return ticker
end

function C_Timer:After(duration, callback)
	return C_Timer:NewTicker(duration, callback, 1)
end

function TickerPrototype:Cancel()
	self._cancelled = true
end

function TickerPrototype:IsCancelled()
	return self._cancelled;
end