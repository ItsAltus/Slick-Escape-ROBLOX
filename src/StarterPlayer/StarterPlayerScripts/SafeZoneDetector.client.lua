-- src/StarterPlayer/StarterPlayerScripts/SafeZoneDetector.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local safeZonesFolder = workspace:WaitForChild("SafeZones")

-- State
local isInSafeZone = false

-- Helper function to check if inside any safe zone
local function isPointInsidePart(point, part)
    local relative = part.CFrame:PointToObjectSpace(point)
    local halfSize = part.Size / 2
    return math.abs(relative.X) <= halfSize.X and
           math.abs(relative.Y) <= halfSize.Y and
           math.abs(relative.Z) <= halfSize.Z
end

local function checkSafeZone()
    for _, zone in pairs(safeZonesFolder:GetChildren()) do
        if zone:IsA("BasePart") then
            if isPointInsidePart(hrp.Position, zone) then
                return true
            end
        end
    end
    return false
end

-- Update every frame
RunService.RenderStepped:Connect(function()
    if hrp and hrp.Parent then
        isInSafeZone = checkSafeZone()
        SafeZoneEvent:FireServer(isInSafeZone)
    end
end)

-- Expose safe zone status to other scripts
_G.IsInSafeZone = function()
    return isInSafeZone
end
