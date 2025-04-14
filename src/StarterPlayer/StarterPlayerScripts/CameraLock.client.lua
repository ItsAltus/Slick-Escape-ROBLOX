-- ============================================================
-- Script Name: CameraLock.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Sets up a custom scriptable camera that tracks the player's character from above.
--              When the character spawns (or respawns), the camera is reconfigured accordingly.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local RunService = game:GetService("RunService")

local player = PlayerUtils.getPlayer()

local cameraUpdateConnection = nil  -- Holds the RenderStepped connection for updating the camera

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
--[[
    Function: setupCamera
    Description: Configures the current camera to follow the given character using RenderStepped.
    Parameters:
        character - The player's character model.
    Returns: None
]]
local function setupCamera(character)
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable  -- Set camera to Scriptable mode so we control it

    if cameraUpdateConnection then
        cameraUpdateConnection:Disconnect()  -- Disconnect previous update if exists
    end

    -- Update the camera each frame to maintain the desired view position
    cameraUpdateConnection = RunService.RenderStepped:Connect(function()
        local hrp = character:WaitForChild("HumanoidRootPart", 5)  -- Wait up to 5 seconds for HRP
        if hrp and hrp.Parent then
            local cameraHeight = 35  -- Set the height above the HRP to position the camera
            camera.CFrame = CFrame.new(
                hrp.Position + Vector3.new(0, cameraHeight, 0)
            ) * CFrame.Angles(math.rad(-85), 0, math.pi)  -- Apply a fixed angle for a cinematic view
        end
    end)
end

---------------------------------------------------------------
-- INITIAL SETUP
---------------------------------------------------------------
local character = PlayerUtils.getCharacter()
if character then
    setupCamera(character)
end

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
player.CharacterAdded:Connect(function(newCharacter)
    local oldCamera = workspace.CurrentCamera

    -- Create a new camera for the new character spawn
    local newCamera = Instance.new("Camera")
    newCamera.CFrame = CFrame.new(0, 10, 0)  -- Initial position for the new camera
    workspace.CurrentCamera = newCamera
    newCamera.CameraType = Enum.CameraType.Custom  -- Temporarily set to Custom

    task.wait(0.05)  -- Brief delay for character and camera setup

    local humanoid = newCharacter:WaitForChild("Humanoid")

    newCamera.CameraSubject = humanoid
    newCamera.CameraType = Enum.CameraType.Scriptable  -- Set back to Scriptable mode for controlled updates

    setupCamera(newCharacter)

    oldCamera:Destroy()  -- Remove the old camera once the new one is active
end)
