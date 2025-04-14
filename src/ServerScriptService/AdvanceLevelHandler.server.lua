-- ============================================================
-- Script Name: AdvanceLevelHandler.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Handles level progression, updating leaderstats and player spawns,
--              and sends tutorial messages when levels change.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdvanceLevel = ReplicatedStorage:WaitForChild("AdvanceLevel")
local startGameEvent = ReplicatedStorage:WaitForChild("StartGame")
local TutorialEvent = ReplicatedStorage:WaitForChild("TutorialEvent")

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
startGameEvent.OnServerEvent:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level")
        if level then
            level.Value = 1

            -- Send a tutorial message to the player on game start
            TutorialEvent:FireClient(player, "Welcome to Slick Escape!\nUse WASD to move.\nPress SHIFT to dash.\nStay out of enemy's vision zones.\nIf an enemy sees you, try freezing in place!\nReach the safezone!")
        else
            warn(player.Name .. " has no Level stat!")  -- Level stat not found
        end
    else
        warn(player.Name .. " has no leaderstats!")  -- Leaderstats folder not found
    end
end)

AdvanceLevel.OnServerEvent:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        warn("No leaderstats for player:", player.Name)
        return
    end

    local level = leaderstats:FindFirstChild("Level")
    if not level then
        warn("No Level stat for player:", player.Name)
        return
    end

    player.leaderstats.Level.Value += 1

    -- Construct the spawn name by concatenating "Level", the current level, and "Spawn"
    local newSpawn = workspace:FindFirstChild("Level" .. player.leaderstats.Level.Value .. "Spawn")
    if newSpawn then
        player:SetAttribute("CurrentSpawn", newSpawn.CFrame)  -- Store the spawn location as an attribute

        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = newSpawn.CFrame + Vector3.new(0, 3, 0)  -- Move character slightly above spawn point

        if player.leaderstats.Level.Value == 1 then
            TutorialEvent:FireClient(player, "Welcome to Slick Escape!\nUse WASD to move.\nPress SHIFT to dash.\nStay out of enemy's vision zones.\nIf an enemy sees you, try freezing in place!\nReach the safezone!")
        elseif player.leaderstats.Level.Value == 2 then
            TutorialEvent:FireClient(player, "Ice is slippery!\nTry to stop sliding before enemies see you.\nPurple launch blocks will launch you across gaps.")
        elseif player.leaderstats.Level.Value == 3 then
            TutorialEvent:FireClient(player, "Final level! Let's ramp up the difficulty and combine all of the elements.\nOne final tip, if there's a place to hide, enemies can't see you.\nOh yeah, and you can't see enemy's vision zones anymore.\nGood luck!")
        end

    else
        local WinGameEvent = ReplicatedStorage:WaitForChild("WinGame")
        WinGameEvent:FireClient(player)
    end
end)
