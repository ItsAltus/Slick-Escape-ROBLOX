-- ============================================================
-- Script Name: ShakeCamera.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Applies a camera shake effect when the server triggers
--              the ShakeEvent (when an enemy is close to the player while state == "Chasing"),
--              using a random offset applied each frame.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShakeEvent = ReplicatedStorage:WaitForChild("ShakeCamera")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

local shaking = false     -- Whether the camera is currently shaking
local shakeIntensity = 0  -- Current intensity of the shake effect
local shakeTime = 0       -- Remaining time for the shake effect

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
-- Listen for the ShakeEvent from the server.
ShakeEvent.OnClientEvent:Connect(function(distance)
    if distance then
        -- Calculate shake intensity based on enemy-player distance (closer equals stronger shake)
        shakeIntensity = math.clamp((10 - distance) / 10, 0.05, 0.5)
        shakeTime = 0.5  -- Set shake duration to half a second
        shaking = true
    end
end)

-- Update the camera each frame if shaking is active.
RunService.RenderStepped:Connect(function(dt)
    if shaking and shakeTime > 0 then
        shakeTime = shakeTime - dt  -- Decrease remaining shake time by delta time
        local offset = Vector3.new(
            (math.random() - 0.5) * 2 * shakeIntensity,  -- Random offset in X
            (math.random() - 0.5) * 2 * shakeIntensity,  -- Random offset in Y
            0                                           -- No offset in Z
        )
        -- Apply the offset to the current camera CFrame
        Camera.CFrame = Camera.CFrame * CFrame.new(offset)
    elseif shakeTime <= 0 then
        shaking = false  -- Stop shaking when time is up
    end
end)
