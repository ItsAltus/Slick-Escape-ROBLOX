-- ============================================================
-- Script Name: SetSpawnHandler.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Listens for the SetSpawn event and stores the provided spawn CFrame
--              as an attribute on the player.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local setSpawnEvent = ReplicatedStorage:WaitForChild("SetSpawn")

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
-- Listen for the SetSpawn event from the client.
setSpawnEvent.OnServerEvent:Connect(function(player, spawnCFrame)
    -- Store the provided spawn location for use on respawn.
    player:SetAttribute("CurrentSpawn", spawnCFrame)
end)
