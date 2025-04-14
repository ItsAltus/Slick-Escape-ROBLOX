-- ============================================================
-- Script Name: SafeZoneDetector.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Checks each frame if the player is inside any safe zone parts
--              and sends that status to the server via the SafeZoneEvent.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")

local safeZonesFolder = workspace:WaitForChild("SafeZones")

local isInSafeZone = false  -- Tracks current safe zone status

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
--[[
    Function: isPointInsidePart
    Description: Determines if a given point is within the boundaries of a part.
    Parameters:
        point - The Vector3 point to test.
        part  - The BasePart whose boundaries are used.
    Returns: True if the point is inside the part; false otherwise.
]]
local function isPointInsidePart(point, part)
    local relative = part.CFrame:PointToObjectSpace(point)  -- Convert point to the part's local space
    local halfSize = part.Size / 2
    return math.abs(relative.X) <= halfSize.X and
           math.abs(relative.Y) <= halfSize.Y and
           math.abs(relative.Z) <= halfSize.Z
end

--[[
    Function: checkSafeZone
    Description: Iterates over all safe zone parts and returns true if the player's HRP is inside any.
    Returns: Boolean indicating whether the player is in a safe zone.
]]
local function checkSafeZone()
    local hrp = PlayerUtils.getHRP()
    for _, zone in pairs(safeZonesFolder:GetChildren()) do
        if zone:IsA("BasePart") then
            if isPointInsidePart(hrp.Position, zone) then
                return true  -- Player is inside a safe zone
            end
        end
    end
    return false  -- Player is not inside any safe zone
end

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
-- Update safe zone status every frame and inform the server
RunService.RenderStepped:Connect(function()
    local hrp = PlayerUtils.getHRP()
    if hrp and hrp.Parent then
        isInSafeZone = checkSafeZone()  -- Determine safe zone status
        SafeZoneEvent:FireServer(isInSafeZone)  -- Send status to server
    end
end)
