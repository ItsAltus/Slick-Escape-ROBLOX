local EnemyModule = {}
EnemyModule.__index = EnemyModule

local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local SafeZoneTracker = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("SafeZoneTracker"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShakeEvent = ReplicatedStorage:WaitForChild("ShakeCamera")

local RaycastParamsTemplate = RaycastParams.new()
RaycastParamsTemplate.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParamsTemplate.IgnoreWater = true

function EnemyModule.new(enemyModel, waypoint1, waypoint2, settings, player)
    local self = setmetatable({}, EnemyModule)

    self.player = player
    self.enemy = enemyModel
    self.visionZone = enemyModel:WaitForChild("VisionZone")
    self.waypoint1 = waypoint1
    self.waypoint2 = waypoint2
    self.currentTarget = waypoint1

    self.settings = settings or {}
    self.speed = self.settings.Speed or 16
    self.chaseSpeed = self.settings.chaseSpeed or 24
    self.dt = 0.03

    for _, part in ipairs(enemyModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CollisionGroup = "Enemies"
        end
    end
    if self.visionZone:IsA("BasePart") then
        self.visionZone.CollisionGroup = "VisionZones"
    end

    if self.visionZone:IsA("BasePart") then
        self.visionZone.Transparency = self.settings.Transparency or 0

        if self.settings.VisionSize then
            self.visionZone.Size = self.settings.VisionSize
        end
    end

    self.playerInSight = false
    self.playerWasMoving = false
    self.hasUsedGrace = false
    self.detectionProgress = 0
    self.detectionRateMoving = 800
    self.detectionRateStationary = 250
    self.suspiciousTimer = 0
    self.suspiciousTimerMax = 2
    self.noticeTimer = 0
    self.noticeTimerMax = 0.2
    self.movementGraceTimer = 0
    self.movementGraceDuration = 1
    self.suspicionCooldown = 0
    self.suspicionCooldownMax = 2
    self.axisRecheckTimer = 0
    self.axisRecheckCooldown = 0.2
    self.stuckTimer = 0
    self.flashTimer = 0
    self.flashDuration = 0.1
    self.flashCount = 0
    self.maxFlashes = 4
    self.isFlashing = false

    self.state = "Patrolling"
    self.lastState = "Patrolling"
    self.playerDetected = false
    self.chasingPlayer = false
    self.chaseAxis = nil


    self.exclamationVisible = false
    self.exclamationFlashing = false
    self.exclamation = self.enemy:FindFirstChild("ExclamationMark")
    if self.exclamation and self.exclamation:IsA("Model") and self.exclamation.PrimaryPart then
        for _, part in ipairs(self.exclamation:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        self.exclamationOffsetVector = self.exclamation.PrimaryPart.Position - self.enemy.Position
        self.originalExclamationRotation = self.exclamation.PrimaryPart.Orientation
    end

    self.originalVisionTransparency = self.visionZone.Transparency
    self.originalVisionColor = self.visionZone.Color

    self.playerTouchCount = 0
    self.visionZone.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorWhichIsA("Model")
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            local player = PlayerUtils.getPlayer()
            if character == player.Character then
                self.playerTouchCount = self.playerTouchCount + 1
                if self.playerTouchCount == 1 then
                    self.playerInSight = true
                    self.hasUsedGrace = false
                    self.movementGraceTimer = self.movementGraceDuration
                    self.playerInSight = true
                end
            end
        end
    end)

    self.visionZone.TouchEnded:Connect(function(hit)
        local character = hit:FindFirstAncestorWhichIsA("Model")
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            local player = PlayerUtils.getPlayer()
            if character == player.Character then
                self.playerTouchCount = self.playerTouchCount - 1
                if self.playerTouchCount <= 0 then
                    self.playerTouchCount = 0
                    self.playerInSight = false
                end
            end
        end
    end)

    self.player.CharacterAdded:Connect(function(character)
        self.playerTouchCount = 0
        self.playerInSight = false
        self.detectionProgress = 0
        self.chasingPlayer = false
        self.playerDetected = false
        self.chaseAxis = nil
        self.state = "Patrolling"
        print("[SERVER] Player respawned, enemy reset!")
    end)

    return self
end

function EnemyModule:updateFacingDirection()
    local enemyPos = Vector3.new(self.enemy.Position.X, 1, self.enemy.Position.Z)
    local targetPos = Vector3.new(self.currentTarget.Position.X, 1, self.currentTarget.Position.Z)
    local lookAtCFrame = CFrame.lookAt(enemyPos, targetPos, Vector3.new(0, 1, 0))
    self.enemy.CFrame = lookAtCFrame
end

function EnemyModule:showExclamation()
    if self.exclamation then
        for _, part in ipairs(self.exclamation:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        self.exclamationVisible = true
    end
end

function EnemyModule:hideExclamation()
    if self.exclamation then
        for _, part in ipairs(self.exclamation:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        self.exclamationVisible = false
    end
end

function EnemyModule:blinkExclamation()
    if not self.exclamation then return end
    if self.exclamationFlashing then return end
    self.exclamationFlashing = true
    for i = 1, 2 do
        self:hideExclamation()
        task.wait(self.flashDuration)
        self:showExclamation()
        task.wait(self.flashDuration)
    end
    self.exclamationFlashing = false
    self.exclamationVisible = true
end

function EnemyModule:moveEnemy(hrp)
    local RaycastParams = RaycastParamsTemplate
    local filterList = {self.enemy, self.visionZone}
    local deadBodiesFolder = workspace:FindFirstChild("DeadBodies")
    if deadBodiesFolder then
        table.insert(filterList, deadBodiesFolder)
    end
    RaycastParams.FilterDescendantsInstances = {self.enemy, self.visionZone, filterList}

    if self.state == "Chasing" then
        local humanoid = hrp.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            self.playerInSight = false
            self.chasingPlayer = false
            self.playerDetected = false
            self.detectionProgress = 0
            self.playerTouchCount = 0
            self.chaseAxis = nil
            self.state = "Patrolling"
            return
        end
        if self.stuckTimer > 0 then
            self.stuckTimer = self.stuckTimer - self.dt
            return
        end
        local delta = hrp.Position - self.enemy.Position
        self.axisRecheckTimer = self.axisRecheckTimer - self.dt
        if not self.chaseAxis or self.axisRecheckTimer <= 0 then
            if math.abs(delta.X) > math.abs(delta.Z) then
                self.chaseAxis = "X"
            else
                self.chaseAxis = "Z"
            end
            self.axisRecheckTimer = self.axisRecheckCooldown
        end
        local snappedDirection, rotationAngle
        if self.chaseAxis == "X" then
            if math.abs(delta.X) > 0.5 then
                if delta.X > 0 then
                    snappedDirection = Vector3.new(1, 0, 0)
                    rotationAngle = math.rad(-90)
                else
                    snappedDirection = Vector3.new(-1, 0, 0)
                    rotationAngle = math.rad(90)
                end
            else
                self.chaseAxis = "Z"
            end
        elseif self.chaseAxis == "Z" then
            if math.abs(delta.Z) > 0.5 then
                if delta.Z > 0 then
                    snappedDirection = Vector3.new(0, 0, 1)
                    rotationAngle = math.rad(180)
                else
                    snappedDirection = Vector3.new(0, 0, -1)
                    rotationAngle = 0
                end
            else
                self.chaseAxis = "X"
            end
        end
        if snappedDirection then
            local moveDirection = snappedDirection.Unit
            local moveDistance = self.chaseSpeed * self.dt
            local moveRay = workspace:Raycast(self.enemy.Position, moveDirection * (moveDistance + 1), RaycastParams)
            if not moveRay then
                self.enemy.Position = self.enemy.Position + snappedDirection * self.chaseSpeed * self.dt
            else
                self.chaseAxis = (self.chaseAxis == "X") and "Z" or "X"
                self.stuckTimer = 1
                print("[AI] Enemy stuck! Freezing for 1 second.")
                return
            end
            self.enemy.CFrame = CFrame.new(self.enemy.Position) * CFrame.Angles(0, rotationAngle, 0)
        end
    elseif self.state ~= "Patrolling" then
        return
    else
        local delta = self.currentTarget.Position - self.enemy.Position
        local moveVector = Vector3.zero
        local moveDistance = self.speed * self.dt
        if math.abs(delta.X) > 0.5 then
            local directionX = delta.X > 0 and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0)
            local moveRay = workspace:Raycast(self.enemy.Position, directionX * (moveDistance + 1), RaycastParams)
            if not moveRay then
                moveVector = directionX
            end
        end
        if moveVector == Vector3.zero and math.abs(delta.Z) > 0.5 then
            local directionZ = delta.Z > 0 and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1)
            local moveRay = workspace:Raycast(self.enemy.Position, directionZ * (moveDistance + 1), RaycastParams)
            if not moveRay then
                moveVector = directionZ
            end
        end
        if moveVector ~= Vector3.zero then
            self.enemy.Position = self.enemy.Position + moveVector * moveDistance
            local rotationAngle = 0
            if moveVector.X ~= 0 then
                rotationAngle = moveVector.X > 0 and math.rad(-90) or math.rad(90)
            elseif moveVector.Z ~= 0 then
                rotationAngle = moveVector.Z > 0 and math.rad(180) or 0
            end
            self.enemy.CFrame = CFrame.new(self.enemy.Position) * CFrame.Angles(0, rotationAngle, 0)
        else
            local randomAxis = math.random(1, 2)
            local randomDirection
            if randomAxis == 1 then
                randomDirection = (math.random(0, 1) == 0) and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0)
            else
                randomDirection = (math.random(0, 1) == 0) and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1)
            end
            self.enemy.Position = self.enemy.Position + randomDirection * self.speed * self.dt * 0.5
            print("[AI] Enemy stuck while patrolling, wiggling free!")
        end
        if (Vector3.new(self.enemy.Position.X, 0, self.enemy.Position.Z) - Vector3.new(self.currentTarget.Position.X, 0, self.currentTarget.Position.Z)).Magnitude < 1 then
            self.currentTarget = (self.currentTarget == self.waypoint1) and self.waypoint2 or self.waypoint1
            self:updateFacingDirection()
        end
    end

    local forward = self.enemy.CFrame.LookVector
    self.visionZone.Position = self.enemy.Position + Vector3.new(forward.X, 0, forward.Z) * 5
    self.visionZone.Orientation = self.enemy.Orientation
end

function EnemyModule:checkSafeZone(player)
    if SafeZoneTracker.IsPlayerSafe and SafeZoneTracker.IsPlayerSafe(player) then
        if self.chasingPlayer or self.playerDetected then
            self.chasingPlayer = false
            self.playerDetected = false
            self.detectionProgress = 0
            self.chaseAxis = nil
            self.state = "Patrolling"
            print("[SAFE] Player entered safe zone.")
        end
    end
end

function EnemyModule:hasClearLineOfSight(enemyPos, playerModel)
    local RaycastParams = RaycastParamsTemplate
    RaycastParams.FilterDescendantsInstances = {self.enemy, self.visionZone, playerModel}
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

function EnemyModule:handleDetection(player, hrp)
    local humanoid = hrp.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local playerIsMoving = humanoid.MoveDirection.Magnitude > 0
    if self.playerInSight then
        if playerIsMoving then
            if self.movementGraceTimer > 0 then
                self.movementGraceTimer = self.movementGraceTimer - self.dt
            else
                if self.state == "Suspicious" then
                    self.detectionProgress = self.detectionProgress + 60
                    print("[DETECTION] Player moved after grace expired! Instant bump.")
                end
            end
        else
            if not self.hasUsedGrace then
                self.movementGraceTimer = self.movementGraceDuration
                self.hasUsedGrace = true
            end
        end
    end
    self.playerWasMoving = playerIsMoving
    if not self.playerInSight then
        self.noticeTimer = 0
    end
    if self.suspicionCooldown > 0 then
        self.suspicionCooldown = self.suspicionCooldown - self.dt
    end
    if self.detectionProgress >= 100 then
        if self.state ~= "Chasing" then
            self.state = "Chasing"
            self.chasingPlayer = true
            self.playerDetected = true
            self.hasUsedGrace = false
            self.movementGraceTimer = 0
            self:hideExclamation()
            print("[STATE] Full Detection! Chasing player!")
        end
    end
    local hasLineOfSight = self:hasClearLineOfSight(self.enemy.Position, hrp.Parent)
    if self.playerInSight and hasLineOfSight and self.suspicionCooldown <= 0 then
        if self.state == "Patrolling" then
            self.noticeTimer = self.noticeTimer + self.dt
            if self.noticeTimer >= self.noticeTimerMax then
                self.state = "Suspicious"
                self.suspiciousTimer = self.suspiciousTimerMax
                print("[STATE] Became Suspicious...")
            end
        end
        if self.state == "Suspicious" then
            if self.movementGraceTimer <= 0 then
                if playerIsMoving then
                    self.detectionProgress = self.detectionProgress + (self.detectionRateMoving * 2) * self.dt
                    self.suspiciousTimer = self.suspiciousTimerMax
                else
                    self.detectionProgress = self.detectionProgress - (self.detectionRateStationary) * self.dt
                    self.suspiciousTimer = self.suspiciousTimer - self.dt
                end
            else
                self.movementGraceTimer = self.movementGraceTimer - self.dt
            end
            self.detectionProgress = math.clamp(self.detectionProgress, 0, 100)
            if self.suspiciousTimer <= 0 then
                self.state = "Patrolling"
                self.detectionProgress = 0
                self.chaseAxis = nil
                self.suspicionCooldown = self.suspicionCooldownMax
                self:hideExclamation()
                print("[STATE] Player froze long enough. Returning to Patrol.")
            end
        elseif self.state == "Chasing" then
            if playerIsMoving then
                self.detectionProgress = self.detectionProgress + self.detectionRateMoving * self.dt
            else
                self.detectionProgress = self.detectionProgress + self.detectionRateStationary * self.dt
            end
        end
    else
        if self.state == "Suspicious" then
            self.detectionProgress = self.detectionProgress - 100 * self.dt
        else
            self.detectionProgress = self.detectionProgress - 10 * self.dt
        end
        if self.detectionProgress <= 0 and (self.state == "Suspicious" or self.state == "Chasing") then
            self.state = "Patrolling"
            self.chasingPlayer = false
            self.playerDetected = false
            self.chaseAxis = nil
            self:hideExclamation()
            print("[STATE] Back to Patrolling...")
        end
    end
    self.detectionProgress = math.clamp(self.detectionProgress, 0, 100)
    self:updateVisualState()
end

function EnemyModule:checkPlayerCaught(hrp)
    if hrp and self.chasingPlayer then
        local distance = (self.enemy.Position - hrp.Position).Magnitude
        if distance < 10 then
            ShakeEvent:FireClient(self.player, distance)
        end
        if distance <= 3.5 then
            local humanoid = hrp.Parent:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
                self.playerInSight = false
                self.chasingPlayer = false
                self.playerDetected = false
                self.detectionProgress = 0
                self.playerTouchCount = 0
                self.chaseAxis = nil
                self.state = "Patrolling"
                print("Player has been caught and killed!")
            end
        end
    end
end

function EnemyModule:updateVisionZone()
    local forward = self.enemy.CFrame.LookVector
    local halfDepth = self.visionZone.Size.Z / 2
    self.visionZone.Position = self.enemy.Position + Vector3.new(forward.X, 0, forward.Z) * halfDepth
    self.visionZone.Orientation = self.enemy.Orientation
end

function EnemyModule:updateVisualState()
    if self.state ~= self.lastState then
        if self.state == "Patrolling" and self.lastState ~= "Patrolling" then
            self.visionZone.Color = Color3.fromRGB(0, 255, 0)
            self.visionZone.Transparency = 0.5
            task.wait(self.flashDuration)
        end
        self.isFlashing = true
        self.flashCount = 0
        self.flashTimer = self.flashDuration
        self.lastState = self.state
        self.visionZone.Transparency = self.originalVisionTransparency
    end

    if self.isFlashing then
        self.flashTimer = self.flashTimer - self.dt
        if self.flashTimer <= 0 then
            self.flashTimer = self.flashDuration
            self.flashCount = self.flashCount + 1

            if self.flashCount % 2 == 1 then
                if self.state == "Suspicious" then
                    self.visionZone.Color = Color3.fromRGB(255, 255, 0)
                    self.visionZone.Transparency = 0.5
                elseif self.state == "Chasing" then
                    self.visionZone.Color = Color3.fromRGB(255, 0, 0)
                    self.visionZone.Transparency = 0.5
                end
            else
                self.visionZone.Color = self.originalVisionColor
                self.visionZone.Transparency = self.originalVisionTransparency
            end

            if self.flashCount >= self.maxFlashes then
                self.isFlashing = false
            end
        end
    else
        if self.state == "Chasing" then
            self:hideExclamation()
            self.visionZone.Color = self.originalVisionColor
            self.visionZone.Transparency = 1
        else
            self.visionZone.Color = self.originalVisionColor
            self.visionZone.Transparency = self.originalVisionTransparency
        end
    end

    if self.state == "Suspicious" then
        if not self.exclamationVisible and not self.exclamationFlashing then
            task.spawn(function()
                self:blinkExclamation()
            end)
        end
    else
        if self.exclamationVisible then
            self:hideExclamation()
        end
    end
end

function EnemyModule:updateExclamation()
    local exclamation = self.enemy:FindFirstChild("ExclamationMark")
    if exclamation and exclamation:IsA("Model") and exclamation.PrimaryPart and self.exclamationOffsetVector and self.originalExclamationRotation then
        local newPos = self.enemy.Position + self.exclamationOffsetVector
        local desiredRotation = CFrame.fromOrientation(
            math.rad(self.originalExclamationRotation.X),
            math.rad(self.originalExclamationRotation.Y),
            math.rad(self.originalExclamationRotation.Z)
        )
        exclamation:SetPrimaryPartCFrame(CFrame.new(newPos) * desiredRotation)
    end
end

function EnemyModule:Start()
    self:updateFacingDirection()
    while true do
        local player = PlayerUtils.getPlayer()
        local hrp = PlayerUtils.getHRP()
        local humanoid = hrp.Parent:FindFirstChild("Humanoid")

        if not hrp or (hrp and hrp.Parent:FindFirstChild("Humanoid") and hrp.Parent:FindFirstChild("Humanoid").Health <= 0) then
            self.state = "Patrolling"
            self.lastState = "Patrolling"
            self.detectionProgress = 0
            self.playerInSight = false
            self.chasingPlayer = false
            self.playerDetected = false
            self.chaseAxis = nil
            self.noticeTimer = 0
            self.suspicionCooldown = 0
            self.axisRecheckTimer = 0

            self.isFlashing = false
            self.flashCount = 0
            self.flashTimer = self.flashDuration

            self.visionZone.Color = self.originalVisionColor
            self.visionZone.Transparency = self.originalVisionTransparency

            self:hideExclamation()

            self:moveEnemy(self.enemy)
        else
            self:moveEnemy(hrp)
            self:checkSafeZone(player)
            self:handleDetection(player, hrp)
            self:checkPlayerCaught(hrp)
            self:updateVisionZone()
            self:updateExclamation()
        end

        task.wait(self.dt)
    end
end

return EnemyModule
