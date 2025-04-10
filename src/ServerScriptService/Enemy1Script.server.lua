local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local SafeZoneTracker = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SafeZoneTracker"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParams.IgnoreWater = true

local VisionEvents = ReplicatedStorage:WaitForChild("VisionEvents")
local PlayerSeenEvent = VisionEvents:WaitForChild("PlayerSeenEvent")
local PlayerLostEvent = VisionEvents:WaitForChild("PlayerLostEvent")

local enemy = workspace:WaitForChild("Enemy1")
local visionZone = enemy:WaitForChild("VisionZone")
local waypoint1 = workspace:WaitForChild("Waypoint1")
local waypoint2 = workspace:WaitForChild("Waypoint2")

local currentTarget = waypoint1
local speed = 16
local dt = 0.03

local playerInSight = false
local playerWasMoving = false

PlayerSeenEvent.OnServerEvent:Connect(function(player)
    playerInSight = true
end)

PlayerLostEvent.OnServerEvent:Connect(function(player)
    playerInSight = false
end)

local detectionProgress = 0
local detectionRateMoving = 800
local detectionRateStationary = 250

local suspiciousTimer = 0
local suspiciousTimerMax = 2
local noticeTimer = 0
local noticeTimerMax = 0.2
local suspicionCooldown = 0
local suspicionCooldownMax = 2

local axisRecheckTimer = 0
local axisRecheckCooldown = 0.2
local stuckTimer = 0

local state = "Patrolling"
local playerDetected = false
local chasingPlayer = false
local chaseAxis = nil

local function updateFacingDirection()
    local enemyPos = Vector3.new(enemy.Position.X, 1, enemy.Position.Z)
    local targetPos = Vector3.new(currentTarget.Position.X, 1, currentTarget.Position.Z)
    local lookAtCFrame = CFrame.lookAt(enemyPos, targetPos, Vector3.new(0, 1, 0))
    enemy.CFrame = lookAtCFrame
end

local function moveEnemy(hrp)
    if state == "Chasing" then
        local humanoid = hrp.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            chasingPlayer = false
            playerDetected = false
            detectionProgress = 0
            chaseAxis = nil
            return
        end

        if stuckTimer > 0 then
            stuckTimer = stuckTimer - dt
            return
        end

        local delta = hrp.Position - enemy.Position

        axisRecheckTimer = axisRecheckTimer - dt

        if not chaseAxis or axisRecheckTimer <= 0 then
            if math.abs(delta.X) > math.abs(delta.Z) then
                chaseAxis = "X"
            else
                chaseAxis = "Z"
            end
            axisRecheckTimer = axisRecheckCooldown
        end

        local snappedDirection
        local rotationAngle

        if chaseAxis == "X" then
            if math.abs(delta.X) > 0.5 then
                if delta.X > 0 then
                    snappedDirection = Vector3.new(1, 0, 0)
                    rotationAngle = math.rad(-90)
                else
                    snappedDirection = Vector3.new(-1, 0, 0)
                    rotationAngle = math.rad(90)
                end
            else
                chaseAxis = "Z"
            end
        elseif chaseAxis == "Z" then
            if math.abs(delta.Z) > 0.5 then
                if delta.Z > 0 then
                    snappedDirection = Vector3.new(0, 0, 1)
                    rotationAngle = math.rad(180)
                else
                    snappedDirection = Vector3.new(0, 0, -1)
                    rotationAngle = 0
                end
            else
                chaseAxis = "X"
            end
        end

        if snappedDirection then
            RaycastParams.FilterDescendantsInstances = {enemy, visionZone}
            local moveDirection = snappedDirection.Unit
            local moveDistance = speed * dt
            local moveRay = workspace:Raycast(enemy.Position, moveDirection * (moveDistance + 1), RaycastParams)

            if not moveRay then
                enemy.Position = enemy.Position + (snappedDirection * speed * dt)
            else
                if chaseAxis == "X" then
                    chaseAxis = "Z"
                else
                    chaseAxis = "X"
                end

                if chaseAxis == "X" then
                    if delta.X > 0 then
                        snappedDirection = Vector3.new(1, 0, 0)
                        rotationAngle = math.rad(-90)
                    else
                        snappedDirection = Vector3.new(-1, 0, 0)
                        rotationAngle = math.rad(90)
                    end
                else
                    if delta.Z > 0 then
                        snappedDirection = Vector3.new(0, 0, 1)
                        rotationAngle = math.rad(180)
                    else
                        snappedDirection = Vector3.new(0, 0, -1)
                        rotationAngle = 0
                    end
                end

                moveDirection = snappedDirection.Unit
                moveRay = workspace:Raycast(enemy.Position, moveDirection * (moveDistance + 1), RaycastParams)

                if not moveRay then
                    enemy.Position = enemy.Position + (snappedDirection * speed * dt)
                else
                    stuckTimer = 1
                    print("[AI] Enemy stuck! Freezing for 1 second.")
                    return
                end
            end

            enemy.CFrame = CFrame.new(enemy.Position) * CFrame.Angles(0, rotationAngle, 0)

            delta = hrp.Position - enemy.Position

            if chaseAxis == "X" and math.abs(delta.X) < 0.5 then
                chaseAxis = nil
            elseif chaseAxis == "Z" and math.abs(delta.Z) < 0.5 then
                chaseAxis = nil
            end
        end

    else
        if state ~= "Patrolling" then
            return
        end

        local delta = currentTarget.Position - enemy.Position

        RaycastParams.FilterDescendantsInstances = {enemy, visionZone}

        local moveVector = Vector3.zero
        local moveDistance = speed * dt

        if math.abs(delta.X) > 0.5 then
            local directionX = delta.X > 0 and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0)
            local moveRay = workspace:Raycast(enemy.Position, directionX * (moveDistance + 1), RaycastParams)

            if not moveRay then
                moveVector = directionX
            end
        end

        if moveVector == Vector3.zero and math.abs(delta.Z) > 0.5 then
            local directionZ = delta.Z > 0 and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1)
            local moveRay = workspace:Raycast(enemy.Position, directionZ * (moveDistance + 1), RaycastParams)

            if not moveRay then
                moveVector = directionZ
            end
        end

        if moveVector ~= Vector3.zero then
            enemy.Position = enemy.Position + (moveVector * speed * dt)
            local rotationAngle = 0

            if moveVector.X ~= 0 then
                rotationAngle = moveVector.X > 0 and math.rad(-90) or math.rad(90)
            elseif moveVector.Z ~= 0 then
                rotationAngle = moveVector.Z > 0 and math.rad(180) or 0
            end

            enemy.CFrame = CFrame.new(enemy.Position) * CFrame.Angles(0, rotationAngle, 0)

        else
            local randomAxis = math.random(1, 2)
            local randomDirection

            if randomAxis == 1 then
                randomDirection = math.random(0, 1) == 0 and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0)
            else
                randomDirection = math.random(0, 1) == 0 and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1)
            end
            enemy.Position = enemy.Position + (randomDirection * speed * dt * 0.5)
            print("[AI] Enemy stuck while patrolling, wiggling free!")
        end
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
            chaseAxis = nil
            state = "Patrolling"
            print("Phew! Entered a safezone.")
        end
    end
end

local function hasClearLineOfSight(enemyPos, playerModel)
    RaycastParams.FilterDescendantsInstances = {enemy, visionZone, playerModel}
    local pointsToCheck = {
        playerModel:FindFirstChild("Head"),
        playerModel:FindFirstChild("HumanoidRootPart"),
        playerModel:FindFirstChild("LeftFoot"),
        playerModel:FindFirstChild("RightFoot"),
    }

    for _, part in ipairs(pointsToCheck) do
        if part then
            local direction = (part.Position - enemyPos).Unit * (part.Position - enemyPos).Magnitude
            local result = workspace:Raycast(enemyPos, direction, RaycastParams)
            if not result then
                return true
            end
        end
    end

    return false
end

local function handleDetection(player, hrp)
    local humanoid = hrp.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local playerIsMoving = humanoid.MoveDirection.Magnitude > 0

    if playerInSight and playerIsMoving and not playerWasMoving then
        if state == "Suspicious" then
            detectionProgress += 60
            print("[DETECTION] Player moved suddenly! Instant bump.")
        end
    end

    playerWasMoving = playerIsMoving

    if not playerInSight then
        noticeTimer = 0
    end

    if suspicionCooldown > 0 then
        suspicionCooldown = suspicionCooldown - dt
    end

    if detectionProgress >= 100 then
        if state ~= "Chasing" then
            state = "Chasing"
            chasingPlayer = true
            playerDetected = true
            print("[STATE] Full Detection! Chasing player!")
        end
    end

    local hasLineOfSight = hasClearLineOfSight(enemy.Position, hrp.Parent)
    print("[DEBUG] Can See Player:", hasLineOfSight)

    if playerInSight and hasLineOfSight and suspicionCooldown <= 0 then
        if state == "Patrolling" then
            noticeTimer += dt
            if noticeTimer >= noticeTimerMax then
                state = "Suspicious"
                suspiciousTimer = suspiciousTimerMax
                print("[STATE] Became Suspicious...")
            end
        end

        if state == "Suspicious" then
            if playerIsMoving then
                detectionProgress = detectionProgress + (detectionRateMoving * 2) * dt
                suspiciousTimer = suspiciousTimerMax
            else
                detectionProgress = detectionProgress - (detectionRateStationary) * dt
                suspiciousTimer = suspiciousTimer - dt
            end

            detectionProgress = math.clamp(detectionProgress, 0, 100)

            if suspiciousTimer <= 0 then
                state = "Patrolling"
                detectionProgress = 0
                chaseAxis = nil
                suspicionCooldown = suspicionCooldownMax
                print("[STATE] Player frozen long enough. Returning to Patrol.")
            end
        elseif state == "Chasing" then
            if playerIsMoving then
                detectionProgress = detectionProgress + detectionRateMoving * dt
            else
                detectionProgress = detectionProgress + detectionRateStationary * dt
            end
        end
    else
        if state == "Suspicious" then
            detectionProgress = detectionProgress - 100 * dt
        else
            detectionProgress = detectionProgress - 10 * dt
        end

        if detectionProgress <= 0 and (state == "Suspicious" or state == "Chasing") then
            state = "Patrolling"
            chasingPlayer = false
            playerDetected = false
            chaseAxis = nil
            print("[STATE] Back to Patrolling...")
        end
    end

    detectionProgress = math.clamp(detectionProgress, 0, 100)

    print("[VISION] State:", state, "| Detection Progress:", math.floor(detectionProgress))
end

local function checkPlayerCaught(hrp)
    if hrp and chasingPlayer then
        local distance = (enemy.Position - hrp.Position).Magnitude
        if distance <= 3.5 then
            local humanoid = hrp.Parent:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                chasingPlayer = false
                playerDetected = false
                detectionProgress = 0
                chaseAxis = nil
                state = "Patrolling"
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
