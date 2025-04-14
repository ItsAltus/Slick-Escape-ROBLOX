-- ============================================================
-- Script Name: TeleportBrick.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Kills a player's character if they fall off the map and hit the TeleportBrick.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local part = workspace:WaitForChild("TeleportBrick")
part.Transparency = 1

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
part.Touched:Connect(function(hit)
    local character = hit.Parent
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end
end)
