-- ============================================================
-- Script Name: MovementController.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Handles character movement using WASD keys and dashing,
--              including special behavior when the player is on ice.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

---------------------------------------------------------------
-- CONFIGURATION & STATE VARIABLES
---------------------------------------------------------------
local moveSpeed = 16
local dashSpeed = 35
local isDashing = false
local dashCooldown = 2
local lastDashTime = 0
local slideMomentum = Vector3.new(0, 0, 0)

-- Define movement keys and their corresponding vectors (in local space)
-- NOTE: These movement vectors are not typical due to the way the camera orientation is set up
local moveKeys = {
	W = Vector3.new(0, 0, 1),
	A = Vector3.new(1, 0, 0),
	S = Vector3.new(0, 0, -1),
	D = Vector3.new(-1, 0, 0)
}

-- Table to track current pressed keys
local keysPressed = {}

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
--[[
    Function: updateMoveDirection
    Description: Sums active movement key vectors and returns a unit direction vector.
    Returns: Unit Vector3 if movement keys are pressed; otherwise, zero vector.
]]
local function updateMoveDirection()
	local sum = Vector3.new(0, 0, 0)
	for key, pressed in pairs(keysPressed) do
		if pressed and moveKeys[key] then
			sum = sum + moveKeys[key]
		end
	end
	if sum.Magnitude > 0 then
		return sum.Unit  -- Normalize the vector if movement is present
	else
		return Vector3.new(0, 0, 0)
	end
end

local moveDirection = Vector3.new(0, 0, 0)  -- Current overall movement direction

---------------------------------------------------------------
-- INPUT HANDLERS
---------------------------------------------------------------
-- Handle WASD input via UserInputService for movement keys.
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	local keyName = input.KeyCode.Name
	if moveKeys[keyName] then
		keysPressed[keyName] = true
		moveDirection = updateMoveDirection()
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if processed then return end
	local keyName = input.KeyCode.Name
	if moveKeys[keyName] then
		keysPressed[keyName] = false
		moveDirection = updateMoveDirection()
	end
end)

-- Use ContextActionService for dash action (works regardless of shift lock)
--[[
    Function: dashAction
    Description: Initiates a dash when LeftShift is pressed if cooldown allows.
    Parameters:
        actionName - The action name (unused in logic).
        inputState - The state of input (e.g., Begin).
        inputObject - The input event object.
    Returns: A ContextActionResult value.
]]
local function dashAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		local now = tick()  -- Get the current time
		if now - lastDashTime >= dashCooldown and not isDashing then
			isDashing = true

			-- Optionally play a dash animation
			local dashAnimation = Instance.new("Animation")
			dashAnimation.AnimationId = "rbxassetid://94156304050794"
			local dashAnimTrack = humanoid:LoadAnimation(dashAnimation)
			dashAnimTrack.Priority = Enum.AnimationPriority.Action
			dashAnimTrack:Play()

			humanoid.WalkSpeed = dashSpeed
			lastDashTime = now

			-- Reset the dash after a brief delay
			task.delay(0.3, function()
				humanoid.WalkSpeed = moveSpeed
				isDashing = false
			end)
		end
	end
	return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("DashAction", dashAction, false, Enum.KeyCode.LeftShift)

---------------------------------------------------------------
-- ICE CHECK FUNCTION
---------------------------------------------------------------
--[[
    Function: checkIfOnIce
    Description: Casts a downward ray from the player's HRP to detect if the player is on an "IceZone".
    Returns: True if the ray hits a part tagged "IceZone"; false otherwise.
]]
local isOnIce = false
local function checkIfOnIce()
    -- Ensure that the HRP exists and belongs to an active character (i.e. not in DeadBodies)
    if not hrp or not hrp.Parent or hrp.Parent:IsDescendantOf(workspace:FindFirstChild("DeadBodies")) then
        return false
    end

    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -3, 0)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}  -- Ignore the player's own character parts
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result and result.Instance then
        if CollectionService:HasTag(result.Instance, "IceZone") then
            return true
        end
    end

    return false
end

---------------------------------------------------------------
-- MAIN MOVEMENT LOOP
---------------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if humanoid.Health <= 0 then return end  -- Do not process movement if dead

	isOnIce = checkIfOnIce()

	if isOnIce then
		-- Set maximum sliding speed depending on whether the player is dashing.
		local maxSlideSpeed = isDashing and 4 or 3
		if moveDirection.Magnitude > 0 then
			-- Increase slide momentum gradually when moving
			local accel = isDashing and 0.2 or 0.1
			slideMomentum = slideMomentum + moveDirection * accel
		else
			-- Gradually decrease slide momentum if no directional input
			slideMomentum = slideMomentum * 0.98
			if slideMomentum.Magnitude < 0.1 then
				slideMomentum = Vector3.zero
			end
		end

		if slideMomentum.Magnitude > maxSlideSpeed then
			-- Clamp slide momentum to the maximum allowed speed
			slideMomentum = slideMomentum.Unit * maxSlideSpeed
		end

		humanoid:Move(slideMomentum, false)  -- Move according to sliding momentum
	else
		slideMomentum = Vector3.zero  -- Reset slide momentum when not on ice
		if moveDirection.Magnitude > 0 then
			humanoid:Move(moveDirection, false)  -- Normal movement
		end
	end
end)
