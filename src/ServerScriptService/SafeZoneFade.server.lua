-- ============================================================
-- Script Name: SafeZoneFade.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Continuously fades safe zone parts in and out to create a visual effect.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local safeZonesFolder = game.Workspace:WaitForChild("SafeZones")

---------------------------------------------------------------
-- SAFE ZONE FADE LOGIC
---------------------------------------------------------------
for _, safeZone in ipairs(safeZonesFolder:GetChildren()) do
    if safeZone:IsA("BasePart") then
        -- Use a coroutine for each safe zone to run the fade loop independently.
        coroutine.wrap(function()
            while true do
                -- Gradually increase transparency from 0.5 to 1
                for transparency = 0.5, 1, 0.05 do
                    safeZone.Transparency = transparency
                    task.wait(0.1)
                end
                -- Gradually decrease transparency from 1 to 0.5
                for transparency = 1, 0.5, -0.05 do
                    safeZone.Transparency = transparency
                    task.wait(0.1)
                end
            end
        end)()
    end
end
