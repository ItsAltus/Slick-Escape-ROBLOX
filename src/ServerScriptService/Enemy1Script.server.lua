local Players = game:GetService("Players")
-- src/Workspace/Enemy1Script.lua

local Players = game:GetService("Players")

local enemy = workspace:WaitForChild("Enemy1")
local waypoint1 = workspace:WaitForChild("Waypoint1")
local waypoint2 = workspace:WaitForChild("Waypoint2")

local currentTarget = waypoint1
local speed = 8 -- Adjust enemy speed here
local visionRadius = 10 -- Vision range to detect player
local detectionGrace = 0.8 -- Time allowed inside radius until detection
local detectionTimer = 0 -- How long player has been inside radius

local playerDetected = false
local playerCurrentlyInRange = false

local function getPlayerCharacter()
    local player = Players:GetPlayers()[1]
    if player and player.Character then
        return player.Character
    end
    return nil
end

local function getPlayer()
    local players = Players:GetPlayers()
    if #players > 0 then
        return players[1]
    end
    return nil
end

while true do
    local direction = (currentTarget.Position - enemy.Position).Unit
    enemy.CFrame = enemy.CFrame + (direction * speed * 0.03)

    if (enemy.Position - currentTarget.Position).Magnitude < 1 then
        -- Switch target when close
        if currentTarget == waypoint1 then
            currentTarget = waypoint2
        else
            currentTarget = waypoint1
        end
    end

    local character = getPlayerCharacter()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local playerPosition = character.HumanoidRootPart.Position
        local distance = (enemy.Position - playerPosition).Magnitude

        if distance <= visionRadius then
            detectionTimer += 0.03

            if detectionTimer >= detectionGrace and not playerDetected then
                local safe = false
                local player = getPlayer()
                if player and _G.IsPlayerSafe then
                    safe = _G.IsPlayerSafe(player)
                end

                if not safe then
                    print("DETECTED!")
                    playerDetected = true
                end
            end
            playerCurrentlyInRange = true
        else
            if playerCurrentlyInRange then
                if playerDetected then
                    print("Phew. Undetected.")
                end
                playerCurrentlyInRange = false
                playerDetected = false
                detectionTimer = 0
            end
        end
    end

    task.wait(0.03)
end
