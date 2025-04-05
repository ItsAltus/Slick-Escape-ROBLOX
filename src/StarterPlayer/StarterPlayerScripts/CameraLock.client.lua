local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local RunService = game:GetService("RunService")

local player = PlayerUtils.getPlayer()
local camera = workspace.CurrentCamera

local function setupCamera(character)
    local hrp = character:WaitForChild("HumanoidRootPart")
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

local character = PlayerUtils.getCharacter()
if character then
    setupCamera(character)
end

player.CharacterAdded:Connect(function(newCharacter)
    setupCamera(newCharacter)
end)
