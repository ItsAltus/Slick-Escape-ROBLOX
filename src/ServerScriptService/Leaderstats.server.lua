-- ============================================================
-- Script Name: Leaderstats.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Creates leaderstats for each player upon joining the game.
--              Leaderstats include an initial Level stat set to 0.
-- ============================================================

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
--[[
    Function: PlayerAdded Handler
    Description: Creates a "leaderstats" folder and a "Level" stat (IntValue)
                 for each player if they do not already exist.
    Parameters:
        player - The player instance that just joined.
    Returns: None
]]
game.Players.PlayerAdded:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        -- Create the leaderstats folder and set its name
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player

        -- Create the Level stat and initialize to 0
        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 0
        level.Parent = leaderstats
    end
end)
