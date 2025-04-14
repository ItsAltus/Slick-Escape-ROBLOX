local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdvanceLevel = ReplicatedStorage:WaitForChild("AdvanceLevel")
local startGameEvent = ReplicatedStorage:WaitForChild("StartGame")
local TutorialEvent = ReplicatedStorage:WaitForChild("TutorialEvent")

startGameEvent.OnServerEvent:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level")
        if level then
            level.Value = 1
            print(player.Name .. " started the game at Level 1")

            TutorialEvent:FireClient(player, "Welcome to Slick Escape!\nUse WASD to move.\nPress SHIFT to dash.\nStay out of enemy's vision zones.\nIf an enemy sees you, try freezing in place!\nReach the safezone!")
        else
            warn(player.Name .. " has no Level stat!")
        end
    else
        warn(player.Name .. " has no leaderstats!")
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

    print("Current Level:", player.leaderstats.Level.Value)
    player.leaderstats.Level.Value += 1
    print("New Level:", player.leaderstats.Level.Value)

    local newSpawn = workspace:FindFirstChild("Level" .. player.leaderstats.Level.Value .. "Spawn")
    if newSpawn then
        player:SetAttribute("CurrentSpawn", newSpawn.CFrame)

        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = newSpawn.CFrame + Vector3.new(0, 3, 0)

        print(player.Name .. " moved to Level " .. player.leaderstats.Level.Value)

        if player.leaderstats.Level.Value == 1 then
            TutorialEvent:FireClient(player, "Welcome to Slick Escape!\nUse WASD to move.\nPress SHIFT to dash.\nStay out of enemy's vision zones.\nIf an enemy sees you, try freezing in place!\nReach the safezone!")
        elseif player.leaderstats.Level.Value == 2 then
            TutorialEvent:FireClient(player, "Ice is slippery!\nTry to stop sliding before enemies see you.\nPurple launch blocks will launch you across gaps.")
        elseif player.leaderstats.Level.Value == 3 then
            TutorialEvent:FireClient(player, "Final level! Let's ramp up the difficulty and combine all of the elements.\nOne final tip, if there's a place to hide, enemies can't see you.\nOh yeah, and you can't see enemy's vision zones anymore.\nGood luck!")
        end

    else
        print(player.Name .. " finished the game!")
        local WinGameEvent = ReplicatedStorage:WaitForChild("WinGame")
        WinGameEvent:FireClient(player)
    end
end)
