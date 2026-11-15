--!nocheck
--[[
	Proximity · Core/Tween
	One place for motion. Respects Tween.Speed (0 = instant, reduced motion).
]]

local TweenService = game:GetService("TweenService")

local Tween = {
	Speed = 1, -- global multiplier for durations; 0 disables animation
	Style = Enum.EasingStyle.Quint,
	Direction = Enum.EasingDirection.Out,
}

function Tween.Info(time: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?, ...): TweenInfo
	return TweenInfo.new((time or 0.2) * Tween.Speed, style or Tween.Style, direction or Tween.Direction, ...)
end

-- Tween.Play(frame, { BackgroundTransparency = 0 }, 0.2)
function Tween.Play(instance: Instance, goal: { [string]: any }, time: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween?
	if not instance then
		return nil
	end
	local duration = (time or 0.2) * Tween.Speed
	if duration <= 0 then
		for k, v in goal do
			instance[k] = v
		end
		return nil
	end
	local tween = TweenService:Create(instance, TweenInfo.new(duration, style or Tween.Style, direction or Tween.Direction), goal)
	tween:Play()
	return tween
end

-- Same as Play but yields until done.
function Tween.Await(instance: Instance, goal: { [string]: any }, time: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?)
	local tween = Tween.Play(instance, goal, time, style, direction)
	if tween then
		tween.Completed:Wait()
	end
end

-- Numeric animation driven by Heartbeat, for values that are not properties.
function Tween.Value(from: number, to: number, time: number, step: (number) -> (), style: Enum.EasingStyle?)
	local duration = time * Tween.Speed
	if duration <= 0 then
		step(to)
		return
	end
	local RunService = game:GetService("RunService")
	local start = os.clock()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local alpha = math.clamp((os.clock() - start) / duration, 0, 1)
		local eased = TweenService:GetValue(alpha, style or Tween.Style, Enum.EasingDirection.Out)
		step(from + (to - from) * eased)
		if alpha >= 1 then
			connection:Disconnect()
		end
	end)
	return connection
end

return Tween
