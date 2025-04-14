local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end)

local moveSpeed = 16
local dashSpeed = 35
local isDashing = false
local dashCooldown = 2
local lastDashTime = 0
local slideMomentum = Vector3.zero

local moveDirection = Vector3.zero
local activeKey = nil

local moveKeys = {
    W = Vector3.new(0, 0, 1),
    A = Vector3.new(1, 0, 0),
    S = Vector3.new(0, 0, -1),
    D = Vector3.new(-1, 0, 0)
}

local dashAnimation = Instance.new("Animation")
dashAnimation.AnimationId = "rbxassetid://94156304050794"
local dashAnimTrack = humanoid:LoadAnimation(dashAnimation)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    local keyName = input.KeyCode.Name
    if moveKeys[keyName] then
        activeKey = keyName
        moveDirection = moveKeys[activeKey]
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        local now = tick()
        if now - lastDashTime >= dashCooldown and (not isDashing) then
            isDashing = true

            if dashAnimTrack then
                dashAnimTrack:Play()
            end

            humanoid.WalkSpeed = dashSpeed
            lastDashTime = now
            task.delay(0.3, function()
                if humanoid then
                    humanoid.WalkSpeed = moveSpeed
                end
                isDashing = false
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end

    if activeKey == input.KeyCode.Name then
        activeKey = nil
        moveDirection = Vector3.zero
    end
end)

local isOnIce = false
local function checkIfOnIce()
    if not hrp then return false end

    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -3, 0)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if result and result.Instance then
        if CollectionService:HasTag(result.Instance, "IceZone") then
            return true
        end
    end

    return false
end

RunService.RenderStepped:Connect(function()
    if not humanoid or humanoid.Health <= 0 then return end

    isOnIce = checkIfOnIce()

    if isOnIce then
        local maxSlideSpeed = isDashing and 4 or 3

        if moveDirection.Magnitude > 0 then
            local accel = isDashing and 0.2 or 0.1
            slideMomentum = slideMomentum + moveDirection.Unit * accel
        else
            slideMomentum = slideMomentum * 0.98
            if slideMomentum.Magnitude < 0.1 then
                slideMomentum = Vector3.zero
            end
        end

        if slideMomentum.Magnitude > maxSlideSpeed then
            slideMomentum = slideMomentum.Unit * maxSlideSpeed
        end

        humanoid:Move(slideMomentum, false)
    else
        slideMomentum = Vector3.zero
        if moveDirection.Magnitude > 0 then
            humanoid:Move(moveDirection, false)
        end
    end
end)
