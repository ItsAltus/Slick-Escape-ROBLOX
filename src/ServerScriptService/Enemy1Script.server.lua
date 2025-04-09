local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local SafeZoneTracker = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SafeZoneTracker"))
local VisionState = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("VisionState"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VisionEvents = ReplicatedStorage:WaitForChild("VisionEvents")
local PlayerSeenEvent = VisionEvents:WaitForChild("PlayerSeenEvent")
local PlayerLostEvent = VisionEvents:WaitForChild("PlayerLostEvent")

local enemy = workspace:WaitForChild("Enemy1")
local visionZone = enemy:WaitForChild("VisionZone")
local waypoint1 = workspace:WaitForChild("Waypoint1")
local waypoint2 = workspace:WaitForChild("Waypoint2")

local currentTarget = waypoint1
local speed = 11
local dt = 0.03

local playerInSight = false

PlayerSeenEvent.OnServerEvent:Connect(function(player)
    playerInSight = true
end)

PlayerLostEvent.OnServerEvent:Connect(function(player)
    playerInSight = false
end)

local detectionProgress = 0
local detectionRateMoving = 40
local detectionRateStationary = -20
local detectionThreshold = 100

local playerDetected = false
local chasingPlayer = false

local function updateFacingDirection()
    local enemyPos = Vector3.new(enemy.Position.X, 1, enemy.Position.Z)
    local targetPos = Vector3.new(currentTarget.Position.X, 1, currentTarget.Position.Z)
    local lookAtCFrame = CFrame.lookAt(enemyPos, targetPos, Vector3.new(0, 1, 0))
    enemy.CFrame = lookAtCFrame
end

local function moveEnemy(hrp)
    if chasingPlayer then
        local humanoid = hrp.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            chasingPlayer = false
            playerDetected = false
            detectionProgress = 0
            return
        end

        local chaseDirection = (hrp.Position - enemy.Position).Unit
        local moveVector = Vector3.new(chaseDirection.X, 0, chaseDirection.Z)
        enemy.Position = enemy.Position + (moveVector * speed * dt)

    else
        if VisionState.PlayerInVisionZone then
            return
        end

        local patrolDirection = (currentTarget.Position - enemy.Position).Unit
        local moveVector = Vector3.new(patrolDirection.X, 0, patrolDirection.Z)
        enemy.Position = enemy.Position + (moveVector * speed * dt)
    end

    local forward = enemy.CFrame.LookVector
    visionZone.Position = enemy.Position + Vector3.new(forward.X, 0, forward.Z) * 5
    visionZone.Orientation = enemy.Orientation

    if (Vector3.new(enemy.Position.X, 0, enemy.Position.Z) - Vector3.new(currentTarget.Position.X, 0, currentTarget.Position.Z)).Magnitude < 1 then
        if currentTarget == waypoint1 then
            currentTarget = waypoint2
        else
            currentTarget = waypoint1
        end
        updateFacingDirection()
    end
end

local function checkSafeZone(player)
    if SafeZoneTracker.IsPlayerSafe and SafeZoneTracker.IsPlayerSafe(player) then
        if chasingPlayer or playerDetected then
            chasingPlayer = false
            playerDetected = false
            detectionProgress = 0
            print("Phew! Entered a safezone.")
        end
    end
end

local function handleDetection(player, hrp)
    local humanoid = hrp.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local playerIsMoving = humanoid.MoveDirection.Magnitude > 0

    if VisionState.PlayerInVisionZone then
        if playerIsMoving then
            detectionProgress = detectionProgress + detectionRateMoving * dt
        else
            detectionProgress = detectionProgress + detectionRateStationary * dt
        end

        if detectionProgress < 0 then detectionProgress = 0 end

        if detectionProgress >= detectionThreshold and not playerDetected then
            if not SafeZoneTracker.IsPlayerSafe(player) then
                playerDetected = true
                chasingPlayer = true
                print("DETECTED! (Progress: ", detectionProgress,")")
            end
        end
    else
        detectionProgress = detectionProgress + detectionRateStationary * 2 * dt
        if detectionProgress < 0 then detectionProgress = 0 end

        if detectionProgress < detectionThreshold and playerDetected then
            chasingPlayer = false
            playerDetected = false
            print("Phew. Got away. Progress: ", detectionProgress,")")
        end
    end

    if playerInSight then
        print("[VISION] Seeing player | Detection Progress:", math.floor(detectionProgress))
    else
        print("[VISION] NOT seeing player | Detection Progress:", math.floor(detectionProgress))
    end
end

local function checkPlayerCaught(hrp)
    if hrp and chasingPlayer then
        local distance = (enemy.Position - hrp.Position).Magnitude
        if distance <= 0.7 then
            local humanoid = hrp.Parent:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                chasingPlayer = false
                playerDetected = false
                detectionProgress = 0
                print("Player has been caught and killed!")
            end
        end
    end
end

updateFacingDirection()

while true do
    local player = PlayerUtils.getPlayer()
    local hrp = PlayerUtils.getHRP()

    if player and hrp then
        moveEnemy(hrp)
        checkSafeZone(player)
        handleDetection(player, hrp)
        checkPlayerCaught(hrp)
    end

    task.wait(dt)
end
