-- ============================================================
-- Script Name: PlayerUtils.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Provides utility functions to retrieve the player,
--              the character, and the HumanoidRootPart for both
--              client and server code.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local Players = game:GetService("Players")
local PlayerUtils = {}

---------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------

--[[
    Function: getPlayer
    Description: Returns the local player if available; otherwise, it returns the first available player.
    Returns: The Player instance.
]]
function PlayerUtils.getPlayer()
    if Players.LocalPlayer then
        return Players.LocalPlayer  -- For client-side scripts, LocalPlayer is available
    else
        local players = Players:GetPlayers()  -- Get list of all players for server-side scripts
        if #players > 0 then
            return players[1]  -- Return first player if available
        else
            return Players.PlayerAdded:Wait()  -- Wait for a player to join if none exist
        end
    end
end

--[[
    Function: getCharacter
    Description: Retrieves the player's character or waits for it to load.
    Returns: The player's character model, or nil if not found.
]]
function PlayerUtils.getCharacter()
    local player = PlayerUtils.getPlayer()
    if not player then
        return nil  -- No player available
    end
    return player.Character or player.CharacterAdded:Wait()  -- Return character immediately or wait until it loads
end

--[[
    Function: getHRP
    Description: Retrieves the HumanoidRootPart from the player's character,
                 returning nil if the character is not found or is in the DeadBodies folder.
    Returns: The HumanoidRootPart instance, or nil if not available.
]]
function PlayerUtils.getHRP()
    local player = PlayerUtils.getPlayer()
    local character = player.Character
    if not character then 
        return nil  -- No character available
    end

    -- If character is inside the "DeadBodies" folder, do not return HRP.
    if character:IsDescendantOf(workspace:FindFirstChild("DeadBodies")) then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")  -- Return HRP if available
end

return PlayerUtils
