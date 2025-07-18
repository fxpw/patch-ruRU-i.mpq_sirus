--[[
	t = elapsed time
	b = begin
	c = change == ending - beginning
	d = duration (total time)
--]]

EasingUtil = {};

local abs = math.abs
local asin	= math.asin
local cos = math.cos
local pi = math.pi
local pow = math.pow
local sin = math.sin
local sqrt = math.sqrt

function EasingUtil.Linear(t, b, c, d)
	return c * t / d + b
end

function EasingUtil.InQuad(t, b, c, d)
	t = t / d
	return c * pow(t, 2) + b
end

function EasingUtil.OutQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function EasingUtil.InOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

function EasingUtil.OutInQuad(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutQuad(t * 2, b, c / 2, d)
	else
		return EasingUtil.InQuad((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InCubic(t, b, c, d)
	t = t / d
	return c * pow(t, 3) + b
end

function EasingUtil.OutCubic(t, b, c, d)
	t = t / d - 1
	return c * (pow(t, 3) + 1) + b
end

function EasingUtil.InOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end

function EasingUtil.OutInCubic(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutCubic(t * 2, b, c / 2, d)
	else
		return EasingUtil.InCubic((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InQuart(t, b, c, d)
	t = t / d
	return c * pow(t, 4) + b
end

function EasingUtil.OutQuart(t, b, c, d)
	t = t / d - 1
	return -c * (pow(t, 4) - 1) + b
end

function EasingUtil.InOutQuart(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 4) + b
	else
		t = t - 2
		return -c / 2 * (pow(t, 4) - 2) + b
	end
end

function EasingUtil.OutInQuart(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutQuart(t * 2, b, c / 2, d)
	else
		return EasingUtil.InQuart((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InQuint(t, b, c, d)
	t = t / d
	return c * pow(t, 5) + b
end

function EasingUtil.OutQuint(t, b, c, d)
	t = t / d - 1
	return c * (pow(t, 5) + 1) + b
end

function EasingUtil.InOutQuint(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(t, 5) + b
	else
		t = t - 2
		return c / 2 * (pow(t, 5) + 2) + b
	end
end

function EasingUtil.OutInQuint(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutQuint(t * 2, b, c / 2, d)
	else
		return EasingUtil.InQuint((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InSine(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

function EasingUtil.OutSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

function EasingUtil.InOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

function EasingUtil.OutInSine(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutSine(t * 2, b, c / 2, d)
	else
		return EasingUtil.InSine((t * 2) -d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InExpo(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
	end
end

function EasingUtil.OutExpo(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
	end
end

function EasingUtil.InOutExpo(t, b, c, d)
	if t == 0 then return b end
	if t == d then return b + c end
	t = t / d * 2
	if t < 1 then
		return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005
	else
		t = t - 1
		return c / 2 * 1.0005 * (-pow(2, -10 * t) + 2) + b
	end
end

function EasingUtil.OutInExpo(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutExpo(t * 2, b, c / 2, d)
	else
		return EasingUtil.InExpo((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InCirc(t, b, c, d)
	t = t / d
	return(-c * (sqrt(1 - pow(t, 2)) - 1) + b)
end

function EasingUtil.OutCirc(t, b, c, d)
	t = t / d - 1
	return(c * sqrt(1 - pow(t, 2)) + b)
end

function EasingUtil.InOutCirc(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return -c / 2 * (sqrt(1 - t * t) - 1) + b
	else
		t = t - 2
		return c / 2 * (sqrt(1 - t * t) + 1) + b
	end
end

function EasingUtil.OutInCirc(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutCirc(t * 2, b, c / 2, d)
	else
		return EasingUtil.InCirc((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d

	if t == 1	then return b + c end

	if not p then p = d * 0.3 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c/a)
	end

	t = t - 1

	return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

-- a: amplitud
-- p: period
function EasingUtil.OutElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d

	if t == 1 then return b + c end

	if not p then p = d * 0.3 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c/a)
	end

	return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

-- p = period
-- a = amplitud
function EasingUtil.InOutElastic(t, b, c, d, a, p)
	if t == 0 then return b end

	t = t / d * 2

	if t == 2 then return b + c end

	if not p then p = d * (0.3 * 1.5) end
	if not a then a = 0 end

	local s

	if not a or a < abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * asin(c / a)
	end

	if t < 1 then
		t = t - 1
		return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
	else
		t = t - 1
		return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
	end
end

-- a: amplitud
-- p: period
function EasingUtil.OutInElastic(t, b, c, d, a, p)
	if t < d / 2 then
		return EasingUtil.OutElastic(t * 2, b, c / 2, d, a, p)
	else
		return EasingUtil.InElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
	end
end

function EasingUtil.InBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

function EasingUtil.OutBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function EasingUtil.InOutBack(t, b, c, d, s)
	if not s then s = 1.70158 end
	s = s * 1.525
	t = t / d * 2
	if t < 1 then
		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	else
		t = t - 2
		return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
	end
end

function EasingUtil.OutInBack(t, b, c, d, s)
	if t < d / 2 then
		return EasingUtil.OutBack(t * 2, b, c / 2, d, s)
	else
		return EasingUtil.InBack((t * 2) - d, b + c / 2, c / 2, d, s)
	end
end

function EasingUtil.OutBounce(t, b, c, d)
	t = t / d
	if t < 1 / 2.75 then
		return c * (7.5625 * t * t) + b
	elseif t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - (2.625 / 2.75)
		return c * (7.5625 * t * t + 0.984375) + b
	end
end

function EasingUtil.InBounce(t, b, c, d)
	return c - EasingUtil.OutBounce(d - t, 0, c, d) + b
end

function EasingUtil.InOutBounce(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.InBounce(t * 2, 0, c, d) * 0.5 + b
	else
		return EasingUtil.OutBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
	end
end

function EasingUtil.OutInBounce(t, b, c, d)
	if t < d / 2 then
		return EasingUtil.OutBounce(t * 2, b, c / 2, d)
	else
		return EasingUtil.InBounce((t * 2) - d, b + c / 2, c / 2, d)
	end
end

function EasingUtil.InCirc2(t, b, c, d)
	t = t / d
	return ((b - c) * (sqrt(1 - pow(t, 2)) - 1) + b)
end

function EasingUtil.OutCirc2(t, b, c, d)
	t = t / d - 1
	return ((c - b) * sqrt(1 - pow(t, 2)) + b)
end

function EasingUtil.InSine2(t, b, c, d)
	return (b - c) * cos(t / d * (pi / 2)) + c
end

function EasingUtil.OutSine2(t, b, c, d)
	return (c - b) * sin(t / d * (pi / 2)) + b
end

function EasingUtil.InOutSine2(t, b, c, d)
	local x = c - b
	if t < d / 2 then
		return EasingUtil.InSine2(t * 2, 0, 0.5, d) * x + b
	else
		return EasingUtil.OutSine2(t * 2 - d, 0.5, 1, d) * x + b
	end
end