local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local SafeZoneTracker = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SafeZoneTracker"))

local enemy = workspace:WaitForChild("Enemy1")
local waypoint1 = workspace:WaitForChild("Waypoint1")
local waypoint2 = workspace:WaitForChild("Waypoint2")

local currentTarget = waypoint1
local speed = 8
local visionRadius = 10
local detectionGrace = 0.8
local detectionTimer = 0

local playerDetected = false
local playerCurrentlyInRange = false

while true do
    local direction = (currentTarget.Position - enemy.Position).Unit
    enemy.CFrame = enemy.CFrame + (direction * speed * 0.03)

    if (enemy.Position - currentTarget.Position).Magnitude < 1 then
        if currentTarget == waypoint1 then
            currentTarget = waypoint2
        else
            currentTarget = waypoint1
        end
    end

    local player = PlayerUtils.getPlayer()
    local hrp = PlayerUtils.getHRP()
    if hrp then
        local playerPosition = hrp.Position
        local distance = (enemy.Position - playerPosition).Magnitude

        if distance <= visionRadius then
            detectionTimer += 0.03

            if detectionTimer >= detectionGrace and not playerDetected then
                local safe = false
                if SafeZoneTracker.IsPlayerSafe then
                    safe = SafeZoneTracker.IsPlayerSafe(player)
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
