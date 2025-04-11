local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShakeEvent = ReplicatedStorage:WaitForChild("ShakeCamera")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

local shaking = false
local shakeIntensity = 0
local shakeTime = 0

ShakeEvent.OnClientEvent:Connect(function(distance)
    if distance then
        shakeIntensity = math.clamp((10 - distance) / 10, 0.05, 0.5)
        shakeTime = 0.5
        shaking = true
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if shaking and shakeTime > 0 then
        shakeTime = shakeTime - dt
        local offset = Vector3.new(
            (math.random() - 0.5) * 2 * shakeIntensity,
            (math.random() - 0.5) * 2 * shakeIntensity,
            0
        )
        Camera.CFrame = Camera.CFrame * CFrame.new(offset)
    elseif shakeTime <= 0 then
        shaking = false
    end
end)
