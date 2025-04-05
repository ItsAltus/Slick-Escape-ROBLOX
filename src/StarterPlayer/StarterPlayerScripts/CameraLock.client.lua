-- src/StarterPlayer/StarterPlayerScripts/CameraLock.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function setupCamera(character)
    -- Wait for character to load
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Lock Camera
    camera.CameraType = Enum.CameraType.Scriptable

    RunService.RenderStepped:Connect(function()
        if hrp and hrp.Parent then
            local cameraHeight = 35

            camera.CFrame = CFrame.new(
                hrp.Position + Vector3.new(0, cameraHeight, 0)
            ) * CFrame.Angles(math.rad(-85), 0, math.pi)
        end
    end)
end

if player.Character then
    setupCamera(player.Character)
end

player.CharacterAdded:Connect(function(character)
    setupCamera(character)
end)
