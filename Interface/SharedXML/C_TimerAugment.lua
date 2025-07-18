local C_Timer2 = C_Timer2

C_Timer = {}

function C_Timer:NewTicker(duration, callback, iterations)
	return C_Timer2.NewTicker(duration, callback, iterations)
end

function C_Timer:After(duration, callback)
	return C_Timer2.NewTimer(duration, callback)
end

C_Timer.NewTimer = C_Timer2.NewTimer