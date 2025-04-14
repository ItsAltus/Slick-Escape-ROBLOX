-- ============================================================
-- Script Name: EnemyModule.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Controls enemy behavior including movement (chasing and patrolling),
--              detection, state management, and visual updates.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local EnemyModule = {}
EnemyModule.__index = EnemyModule

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local SafeZoneTracker = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SafeZoneTracker"))
local ShakeEvent = ReplicatedStorage:WaitForChild("ShakeCamera")
local Workspace = workspace

local DEFAULT_DT = 0.03

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
--[[
    Function: createRaycastParams
    Description: Creates a new RaycastParams instance with a blacklist filter.
    Parameters:
        filterList - Table of instances to ignore during raycasting.
    Returns: A new RaycastParams instance configured with the filter list.
]]
local function createRaycastParams(filterList)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    params.FilterDescendantsInstances = filterList  -- Set the list of instances to ignore
    return params
end

--[[
    Function: resetChaseState
    Description: Resets enemy-related state variables when the player is lost or respawns.
    Parameters: None
    Returns: None
]]
function EnemyModule:resetChaseState()
    self.playerInSight = false
    self.chasingPlayer = false
    self.playerDetected = false
    self.detectionProgress = 0
    self.playerTouchCount = 0
    self.chaseAxis = nil
    self.state = "Patrolling"
end

--[[
    Function: initializeCollisionGroups
    Description: Sets up collision groups for enemy parts and the vision zone.
    Parameters: None
    Returns: None
]]
function EnemyModule:initializeCollisionGroups()
    for _, part in ipairs(self.enemy:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CollisionGroup = "Enemies"  -- Ensure enemy parts collide appropriately
        end
    end
    if self.visionZone:IsA("BasePart") then
        self.visionZone.CollisionGroup = "VisionZones"  -- Separate vision zone collisions
    end
end

--[[
    Function: initializeExclamation
    Description: Initializes the enemy's exclamation mark visuals by setting transparency and storing offsets for later positioning.
    Parameters: None
    Returns: None
]]
function EnemyModule:initializeExclamation()
    if self.exclamation and self.exclamation:IsA("Model") and self.exclamation.PrimaryPart then
        for _, part in ipairs(self.exclamation:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1  -- Hide all parts of the exclamation by default
            end
        end
        self.exclamationOffsetVector = self.exclamation.PrimaryPart.Position - self.enemy.Position  -- Calculate offset for repositioning
        self.originalExclamationRotation = self.exclamation.PrimaryPart.Orientation  -- Store original orientation
    end
end

---------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------
--[[
    Function: new
    Description: Constructs a new EnemyModule instance with given enemy model, waypoints, settings, and player.
    Parameters:
        enemyModel - The model representing the enemy.
        waypoint1, waypoint2 - Waypoints for enemy patrolling.
        settings - Table containing speed, chaseSpeed, VisionSize, and Transparency(vision zone).
        player - The player instance.
    Returns: A new EnemyModule instance.
]]
function EnemyModule.new(enemyModel, waypoint1, waypoint2, settings, player)
    local self = setmetatable({}, EnemyModule)

    -- Initialize self variables
    self.player = player
    self.enemy = enemyModel
    self.visionZone = enemyModel:WaitForChild("VisionZone")
    self.waypoint1 = waypoint1
    self.waypoint2 = waypoint2
    self.currentTarget = waypoint1

    self.settings = settings or {}
    self.speed = self.settings.Speed or 16
    self.chaseSpeed = self.settings.chaseSpeed or 24
    self.dt = DEFAULT_DT

    -- Setup collision groups and vision zone size/transparency
    self:initializeCollisionGroups()
    if self.visionZone:IsA("BasePart") then
        self.visionZone.Transparency = self.settings.Transparency or 0
        if self.settings.VisionSize then
            self.visionZone.Size = self.settings.VisionSize  -- Apply custom vision size if provided
        end
    end

    -- Initialize state variables
    self.playerInSight = false
    self.playerWasMoving = false
    self.hasUsedGrace = false
    self.detectionProgress = 0
    self.detectionRateMoving = -50
    self.detectionRateStationary = -50
    self.suspiciousTimer = 0
    self.suspiciousTimerMax = 2
    self.noticeTimer = 0
    self.noticeTimerMax = 0.2
    self.movementGraceTimer = 0
    self.movementGraceDuration = 0.85
    self.suspicionCooldown = 0
    self.suspicionCooldownMax = 1.5
    self.axisRecheckTimer = 0
    self.axisRecheckCooldown = 0.2
    self.stuckTimer = 0
    self.flashDuration = 0.1
    self.flashTimer = self.flashDuration
    self.flashCount = 0
    self.maxFlashes = 4
    self.isFlashing = false

    self.state = "Patrolling"
    self.lastState = "Patrolling"
    self.playerDetected = false
    self.chasingPlayer = false
    self.chaseAxis = nil

    -- Exclamation mark initialization
    self.exclamationVisible = false
    self.exclamationFlashing = false
    self.exclamation = self.enemy:FindFirstChild("ExclamationMark")
    self:initializeExclamation()

    self.originalVisionTransparency = self.visionZone.Transparency
    self.originalVisionColor = self.visionZone.Color

    self.playerTouchCount = 0

    -- Setup vision zone events for tracking player entry/exit
    self.visionZone.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorWhichIsA("Model")
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            local currentPlayer = PlayerUtils.getPlayer()
            if character == currentPlayer.Character then
                self.playerTouchCount = self.playerTouchCount + 1  -- Increment touch count on entry
                if self.playerTouchCount == 1 then
                    self.playerInSight = true
                    self.hasUsedGrace = false
                    self.movementGraceTimer = self.movementGraceDuration
                end
            end
        end
    end)

    self.visionZone.TouchEnded:Connect(function(hit)
        local character = hit:FindFirstAncestorWhichIsA("Model")
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then
            local currentPlayer = PlayerUtils.getPlayer()
            if character == currentPlayer.Character then
                self.playerTouchCount = math.max(self.playerTouchCount - 1, 0)  -- Decrement and clamp touch count
                if self.playerTouchCount == 0 then
                    self.playerInSight = false
                end
            end
        end
    end)

    -- Reset enemy state when the player's character is added (respawn)
    self.player.CharacterAdded:Connect(function(character)
        self:resetChaseState()  -- Ensure enemy state is reset on respawn
    end)

    return self
end

---------------------------------------------------------------
-- MOVEMENT ROUTINES
-- Separates chasing and patrolling behavior.
---------------------------------------------------------------
--[[
    Function: moveChasing
    Description: Moves the enemy towards the player when in "Chasing" state.
    Parameters:
        hrp - The HumanoidRootPart of the player's character.
    Returns: None
]]
function EnemyModule:moveChasing(hrp)
    local humanoid = hrp.Parent:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        self:resetChaseState()
        return
    end
    if self.stuckTimer > 0 then
        self.stuckTimer = self.stuckTimer - self.dt  -- Countdown until unstuck
        return
    end
    local delta = hrp.Position - self.enemy.Position  -- Calculate vector difference to player
    self.axisRecheckTimer = self.axisRecheckTimer - self.dt
    if not self.chaseAxis or self.axisRecheckTimer <= 0 then
        self.chaseAxis = (math.abs(delta.X) > math.abs(delta.Z)) and "X" or "Z"  -- Choose dominant axis
        self.axisRecheckTimer = self.axisRecheckCooldown  -- Reset timer for rechecking
    end
    local snappedDirection, rotationAngle
    if self.chaseAxis == "X" then
        if math.abs(delta.X) > 0.5 then  -- Only update if distance threshold exceeded
            if delta.X > 0 then
                snappedDirection = Vector3.new(1, 0, 0)
                rotationAngle = math.rad(-90)
            else
                snappedDirection = Vector3.new(-1, 0, 0)
                rotationAngle = math.rad(90)
            end
        else
            self.chaseAxis = "Z"  -- Switch axis if not enough movement on X
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
            self.chaseAxis = "X"  -- Switch axis if not enough movement on Z
        end
    end
    if snappedDirection then
        local moveDistance = self.chaseSpeed * self.dt
        local filterList = { self.enemy, self.visionZone, self.waypoint1, self.waypoint2 }
        local deadBodiesFolder = Workspace:FindFirstChild("DeadBodies")
        if deadBodiesFolder then
            table.insert(filterList, deadBodiesFolder)
        end
        local rayParams = createRaycastParams(filterList)
        local moveRay = Workspace:Raycast(self.enemy.Position, snappedDirection.Unit * (moveDistance + 1), rayParams)
        if not moveRay then
            self.enemy.Position = self.enemy.Position + snappedDirection * moveDistance  -- Move enemy if path is clear
        end
        self.enemy.CFrame = CFrame.new(self.enemy.Position) * CFrame.Angles(0, rotationAngle, 0)
    end
end

--[[
    Function: movePatrolling
    Description: Moves the enemy along its patrol path between two waypoints.
    Parameters: None
    Returns: None
]]
function EnemyModule:movePatrolling()
    local delta = self.currentTarget.Position - self.enemy.Position  -- Vector towards current target
    local moveDistance = self.speed * self.dt
    local moveVector = Vector3.zero
    local filterList = { self.enemy, self.visionZone, self.waypoint1, self.waypoint2 }
    local deadBodiesFolder = Workspace:FindFirstChild("DeadBodies")
    if deadBodiesFolder then
        table.insert(filterList, deadBodiesFolder)
    end
    local rayParams = createRaycastParams(filterList)

    if math.abs(delta.X) > 0.5 then
        local directionX = delta.X > 0 and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0)
        local moveRay = Workspace:Raycast(self.enemy.Position, directionX * (moveDistance + 1), rayParams)
        if not moveRay then
            moveVector = directionX
        end
    end
    if moveVector == Vector3.zero and math.abs(delta.Z) > 0.5 then
        local directionZ = delta.Z > 0 and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1)
        local moveRay = Workspace:Raycast(self.enemy.Position, directionZ * (moveDistance + 1), rayParams)
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
        local randomAxis = math.random(1, 2)  -- Randomly choose an axis to wiggle out if stuck
        local randomDirection = (randomAxis == 1) and ((math.random(0, 1) == 0) and Vector3.new(1, 0, 0) or Vector3.new(-1, 0, 0))
                             or ((math.random(0, 1) == 0) and Vector3.new(0, 0, 1) or Vector3.new(0, 0, -1))
        self.enemy.Position = self.enemy.Position + randomDirection * self.speed * self.dt * 0.5
    end
    if (Vector3.new(self.enemy.Position.X, 0, self.enemy.Position.Z) - Vector3.new(self.currentTarget.Position.X, 0, self.currentTarget.Position.Z)).Magnitude < 1 then
        self.currentTarget = (self.currentTarget == self.waypoint1) and self.waypoint2 or self.waypoint1  -- Switch patrol target when close enough
        self:updateFacingDirection()
    end
end

--[[
    Function: moveEnemy
    Description: Chooses the appropriate movement routine based on the enemy's state.
    Parameters:
        hrp - The HumanoidRootPart of the player's character.
    Returns: None
]]
function EnemyModule:moveEnemy(hrp)
    if self.state == "Chasing" then
        self:moveChasing(hrp)
    elseif self.state == "Patrolling" then
        self:movePatrolling()
    else
        return
    end

    local forward = self.enemy.CFrame.LookVector  -- Determine enemy's forward direction
    self.visionZone.Position = self.enemy.Position + Vector3.new(forward.X, 0, forward.Z) * 5  -- Offset vision zone in front of enemy
    self.visionZone.Orientation = self.enemy.Orientation
end

---------------------------------------------------------------
-- DETECTION & LINE-OF-SIGHT
---------------------------------------------------------------
--[[
    Function: checkSafeZone
    Description: Checks if the player is in a safe zone and resets enemy state if so.
    Parameters:
        player - The player instance.
    Returns: None
]]
function EnemyModule:checkSafeZone(player)
    if SafeZoneTracker.IsPlayerSafe and SafeZoneTracker.IsPlayerSafe(player) then
        if self.chasingPlayer or self.playerDetected then
            self.chasingPlayer = false
            self.playerDetected = false
            self.detectionProgress = 0
            self.chaseAxis = nil
            self.state = "Patrolling"
        end
    end
end

--[[
    Function: hasClearLineOfSight
    Description: Determines if the enemy has a clear line-of-sight to the player.
    Parameters:
        enemyPos - The enemy's position.
        playerModel - The player's character model.
    Returns: Boolean true if clear line-of-sight; false otherwise.
]]
function EnemyModule:hasClearLineOfSight(enemyPos, playerModel)
    local filterList = { self.enemy, self.visionZone, playerModel }
    local rayParams = createRaycastParams(filterList)
    local pointsToCheck = {
        playerModel:FindFirstChild("Head"),
        playerModel:FindFirstChild("HumanoidRootPart"),
        playerModel:FindFirstChild("LeftFoot"),
        playerModel:FindFirstChild("RightFoot"),
    }
    for _, part in ipairs(pointsToCheck) do
        if part then
            local direction = part.Position - enemyPos  -- Vector from enemy to part
            local result = Workspace:Raycast(enemyPos, direction, rayParams)
            if not result then
                return true  -- Clear line-of-sight found if raycast does not hit an object
            end
        end
    end
    return false
end

--[[
    Function: handleDetection
    Description: Processes player detection based on movement and line-of-sight, then updates enemy state accordingly.
    Parameters:
        player - The player instance.
        hrp - The HumanoidRootPart of the player's character.
    Returns: None
]]
function EnemyModule:handleDetection(player, hrp)
    local humanoid = hrp.Parent:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local playerIsMoving = humanoid.MoveDirection.Magnitude > 0
    if self.playerInSight then
        if playerIsMoving then
            if self.movementGraceTimer > 0 then
                self.movementGraceTimer = self.movementGraceTimer - self.dt  -- Countdown grace period
            else
                if self.state == "Suspicious" then
                    self.detectionProgress = self.detectionProgress + 60  -- Instant detection after grace expires
                end
            end
        else
            if not self.hasUsedGrace then
                self.movementGraceTimer = self.movementGraceDuration  -- Reset grace timer if player stops
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
        end
    end
    local hasLOS = self:hasClearLineOfSight(self.enemy.Position, hrp.Parent)
    if self.playerInSight and hasLOS and self.suspicionCooldown <= 0 then
        if self.state == "Patrolling" then
            self.noticeTimer = self.noticeTimer + self.dt
            if self.noticeTimer >= self.noticeTimerMax then
                self.state = "Suspicious"
                self.suspiciousTimer = self.suspiciousTimerMax
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
        end
    end
    self.detectionProgress = math.clamp(self.detectionProgress, 0, 100)
    self:updateVisualState()
end

--[[
    Function: checkPlayerCaught
    Description: Checks if the enemy is close enough to catch the player, then resets state accordingly.
    Parameters:
        hrp - The HumanoidRootPart of the player's character.
    Returns: None
]]
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
                self:resetChaseState()
            end
        end
    end
end

---------------------------------------------------------------
-- VISUAL UPDATES
---------------------------------------------------------------
--[[
    Function: updateFacingDirection
    Description: Updates enemy orientation to face its current target.
    Parameters: None
    Returns: None
]]
function EnemyModule:updateFacingDirection()
    local enemyPos = Vector3.new(self.enemy.Position.X, 1, self.enemy.Position.Z)
    local targetPos = Vector3.new(self.currentTarget.Position.X, 1, self.currentTarget.Position.Z)
    local lookAtCFrame = CFrame.lookAt(enemyPos, targetPos, Vector3.new(0, 1, 0))
    self.enemy.CFrame = lookAtCFrame
end

--[[
    Function: updateVisionZone
    Description: Updates the position and orientation of the enemy's vision zone.
    Parameters: None
    Returns: None
]]
function EnemyModule:updateVisionZone()
    local forward = self.enemy.CFrame.LookVector
    local halfDepth = self.visionZone.Size.Z / 2
    self.visionZone.Position = self.enemy.Position + Vector3.new(forward.X, 0, forward.Z) * halfDepth
    self.visionZone.Orientation = self.enemy.Orientation
end

--[[
    Function: showExclamation
    Description: Makes the enemy's exclamation mark visible.
    Parameters: None
    Returns: None
]]
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

--[[
    Function: hideExclamation
    Description: Hides the enemy's exclamation mark.
    Parameters: None
    Returns: None
]]
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

--[[
    Function: blinkExclamation
    Description: Temporarily blinks the exclamation mark for visual feedback.
    Parameters: None
    Returns: None
]]
function EnemyModule:blinkExclamation()
    if not self.exclamation or self.exclamationFlashing then return end
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

--[[
    Function: updateVisualState
    Description: Handles color and transparency updates based on the enemy's current state.
    Parameters: None
    Returns: None
]]
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
        self.flashTimer = self.flashTimer - self.dt  -- Count down the flash timer
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

--[[
    Function: updateExclamation
    Description: Updates the position and orientation of the exclamation mark relative to the enemy.
    Parameters: None
    Returns: None
]]
function EnemyModule:updateExclamation()
    local exclamation = self.enemy:FindFirstChild("ExclamationMark")
    if exclamation and exclamation:IsA("Model") and exclamation.PrimaryPart and self.exclamationOffsetVector and self.originalExclamationRotation then
        local newPos = self.enemy.Position + self.exclamationOffsetVector  -- Calculate new position based on offset
        local desiredRotation = CFrame.fromOrientation(
            math.rad(self.originalExclamationRotation.X),
            math.rad(self.originalExclamationRotation.Y),
            math.rad(self.originalExclamationRotation.Z)
        )
        exclamation:SetPrimaryPartCFrame(CFrame.new(newPos) * desiredRotation)
    end
end

---------------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------------
--[[
    Function: Start
    Description: The main loop that updates enemy behavior each frame.
    Parameters: None
    Returns: None
]]
function EnemyModule:Start()
    self:updateFacingDirection()
    while true do
        local currentPlayer = PlayerUtils.getPlayer()  -- Get current player each iteration
        local character = currentPlayer and currentPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")

        if character and humanoid and humanoid.Health > 0 then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                self:moveEnemy(hrp)
                self:checkSafeZone(currentPlayer)
                self:handleDetection(currentPlayer, hrp)
                self:checkPlayerCaught(hrp)
                self:updateVisionZone()
                self:updateExclamation()
            end
        else
            -- Reset state if player is not active
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
        end

        task.wait(self.dt)
    end
end

return EnemyModule
