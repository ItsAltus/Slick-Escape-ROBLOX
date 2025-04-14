-- ============================================================
-- Script Name: RespawnHandler.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Automatically loads the player's character when they join
--              and handles respawn requests by loading the character and
--              repositioning them at their set spawn.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
-- Automatically load the player's character when they join the game.
game.Players.PlayerAdded:Connect(function(player)
    player:LoadCharacter()
end)

-- Handle respawn requests from the client.
respawnRequest.OnServerEvent:Connect(function(player)
    player:LoadCharacter()  -- Reload the character when the respawn request is received

    -- Wait for the character to be available and retrieve its HumanoidRootPart.
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Retrieve the player's spawn location from attributes.
    local spawnCFrame = player:GetAttribute("CurrentSpawn")
    if spawnCFrame then
        -- Offset the spawn location slightly upward so the character doesn't clip through the floor.
        hrp.CFrame = spawnCFrame + Vector3.new(0, 3, 0)
    else
        warn("No spawn set for player!")
    end
end)
