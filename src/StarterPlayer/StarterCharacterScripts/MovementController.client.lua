local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Settings
local moveSpeed = 16
local dashSpeed = 35
local isDashing = false
local dashCooldown = 2
local lastDashTime = 0
local slideMomentum = Vector3.new(0, 0, 0)

-- Define movement keys and their corresponding vectors (in local space)
local moveKeys = {
	W = Vector3.new(0, 0, 1),
	A = Vector3.new(1, 0, 0),
	S = Vector3.new(0, 0, -1),
	D = Vector3.new(-1, 0, 0)
}

-- Table to track current pressed keys
local keysPressed = {}

-- Update the overall move direction based on keys currently pressed
local function updateMoveDirection()
	local sum = Vector3.new(0, 0, 0)
	for key, pressed in pairs(keysPressed) do
		if pressed and moveKeys[key] then
			sum = sum + moveKeys[key]
		end
	end
	if sum.Magnitude > 0 then
		return sum.Unit
	else
		return Vector3.new(0, 0, 0)
	end
end

local moveDirection = Vector3.new(0, 0, 0)

-- Handle WASD input using UserInputService (for movement keys)
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

-- Use ContextActionService for dash action; this works regardless of shiftlock
local function dashAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		local now = tick()
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

			task.delay(0.3, function()
				humanoid.WalkSpeed = moveSpeed
				isDashing = false
			end)
		end
	end
	return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("DashAction", dashAction, false, Enum.KeyCode.LeftShift)

-- Ice check function: casts downward ray and returns true if it hits a part tagged "IceZone"
local function checkIfOnIce()
	local rayOrigin = hrp.Position
	local rayDirection = Vector3.new(0, -3, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if result and result.Instance and CollectionService:HasTag(result.Instance, "IceZone") then
		return true
	end
	return false
end

-- Main loop for moving the character
RunService.RenderStepped:Connect(function()
	if humanoid.Health <= 0 then return end

	local onIce = checkIfOnIce()

	if onIce then
		local maxSlideSpeed = isDashing and 3 or 1.5
		if moveDirection.Magnitude > 0 then
			local accel = isDashing and 0.2 or 0.04
			slideMomentum = slideMomentum + moveDirection * accel
		else
			slideMomentum = slideMomentum * 0.975
			if slideMomentum.Magnitude < 0.1 then
				slideMomentum = Vector3.new(0, 0, 0)
			end
		end

		if slideMomentum.Magnitude > maxSlideSpeed then
			slideMomentum = slideMomentum.Unit * maxSlideSpeed
		end

		humanoid:Move(slideMomentum, false)
	else
		slideMomentum = Vector3.new(0, 0, 0)
		if moveDirection.Magnitude > 0 then
			humanoid:Move(moveDirection, false)
		end
	end
end)
