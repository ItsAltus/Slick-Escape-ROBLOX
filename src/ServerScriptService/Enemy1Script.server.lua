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
local chasingPlayer = false

local function moveEnemy(hrp)
    if chasingPlayer then
        local chaseDirection = (hrp.Position - enemy.Position).Unit
        enemy.CFrame = enemy.CFrame + (chaseDirection * speed * 0.03)
    else
        local patrolDirection = (currentTarget.Position - enemy.Position).Unit
        enemy.CFrame = enemy.CFrame + (patrolDirection * speed * 0.03)
    end

    if (enemy.Position - currentTarget.Position).Magnitude < 1 then
        if currentTarget == waypoint1 then
            currentTarget = waypoint2
        else
            currentTarget = waypoint1
        end
    end
end

local function checkSafeZone(player)
    if SafeZoneTracker.IsPlayerSafe and SafeZoneTracker.IsPlayerSafe(player) then
        if chasingPlayer or playerDetected then
            chasingPlayer = false
            playerDetected = false
            detectionTimer = 0
            print("Phew! Entered a safezone.")
        end
    end
end

local function handleDetection(player, hrp)
    local distance = (enemy.Position - hrp.Position).Magnitude

    if distance <= visionRadius then
        detectionTimer += 0.03

        if detectionTimer >= detectionGrace and not playerDetected then
            if not SafeZoneTracker.IsPlayerSafe(player) then
                playerDetected = true
                chasingPlayer = true
                print("DETECTED!")
            end
        end
        playerCurrentlyInRange = true
    else
        if playerCurrentlyInRange then
            if playerDetected then
                chasingPlayer = false
                print("Phew. Got away.")
            end
            playerCurrentlyInRange = false
            playerDetected = false
            detectionTimer = 0
        end
    end
end

while true do
    local player = PlayerUtils.getPlayer()
    local hrp = PlayerUtils.getHRP()

    if player and hrp then
        moveEnemy(hrp)
        checkSafeZone(player)
        handleDetection(player, hrp)
    end

    task.wait(0.03)
end
