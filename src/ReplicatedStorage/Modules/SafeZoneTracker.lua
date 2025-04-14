-- ============================================================
-- Script Name: SafeZoneTracker.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Tracks when a player is in a safe zone and triggers level progression.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")
local NextLevelEvent = ReplicatedStorage:WaitForChild("NextLevel")
local playerSafeStatus = {}  -- Table to hold each player's safe zone status

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
-- Listen for safe zone events from clients
SafeZoneEvent.OnServerEvent:Connect(function(player, isSafe)
    -- Update player's safe status only if there is a change
    if playerSafeStatus[player] ~= isSafe then
        playerSafeStatus[player] = isSafe

        if isSafe then
            print(player.Name .. " completed the level!")
            NextLevelEvent:FireClient(player)  -- Notify the player to advance to the next level
        end
    end
end)

---------------------------------------------------------------
-- SAFE ZONE TRACKER MODULE
---------------------------------------------------------------
local SafeZoneTracker = {}

-- Expose the SafeZoneEvent for potential external reference
SafeZoneTracker.SafeZoneEvent = SafeZoneEvent

--[[
    Function: IsPlayerSafe
    Description: Checks whether a given player is marked as safe.
    Parameters:
        player - The player instance to check.
    Returns: Boolean true if the player's safe status is true, false otherwise.
]]
function SafeZoneTracker.IsPlayerSafe(player)
    return playerSafeStatus[player] == true
end

return SafeZoneTracker
