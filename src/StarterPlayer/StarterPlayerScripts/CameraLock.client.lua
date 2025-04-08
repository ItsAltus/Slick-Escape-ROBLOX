local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local RunService = game:GetService("RunService")

local player = PlayerUtils.getPlayer()

local cameraUpdateConnection = nil

local function setupCamera(character)
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable

    if cameraUpdateConnection then
        cameraUpdateConnection:Disconnect()
    end

    cameraUpdateConnection = RunService.RenderStepped:Connect(function()
        local hrp = PlayerUtils.getHRP()
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
    local oldCamera = workspace.CurrentCamera

    local newCamera = Instance.new("Camera")
    newCamera.CFrame = CFrame.new(0, 10, 0)
    workspace.CurrentCamera = newCamera
    newCamera.CameraType = Enum.CameraType.Custom

    task.wait(0.05)

    local humanoid = newCharacter:WaitForChild("Humanoid")
    local hrp = newCharacter:WaitForChild("HumanoidRootPart", 5)

    newCamera.CameraSubject = humanoid
    newCamera.CameraType = Enum.CameraType.Scriptable

    setupCamera(newCharacter)

    oldCamera:Destroy()
end)
