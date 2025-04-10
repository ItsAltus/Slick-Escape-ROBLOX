local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local moveSpeed = 16
local dashSpeed = 35
local isDashing = false
local dashCooldown = 2
local lastDashTime = 0
local slideMomentum = Vector3.new(0, 0, 0)

local moveDirection = Vector3.new(0, 0, 0)
local activeKey = nil

local moveKeys = {
    W = Vector3.new(0, 0, 1),
    A = Vector3.new(1, 0, 0),
    S = Vector3.new(0, 0, -1),
    D = Vector3.new(-1, 0, 0)
}

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
            humanoid.WalkSpeed = dashSpeed
            lastDashTime = now
            task.delay(0.3, function()
                humanoid.WalkSpeed = moveSpeed
                isDashing = false
            end)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end

    if activeKey == input.KeyCode.Name then
        activeKey = nil
        moveDirection = Vector3.new(0, 0, 0)
    end
end)

local isOnIce = false
local function checkIfOnIce()
    local rayOrigin = character.HumanoidRootPart.Position
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
    if humanoid.Health <= 0 then return end

    isOnIce = checkIfOnIce()

    if isOnIce then
        local maxSlideSpeed = isDashing and 3 or 1.5

        if moveDirection.Magnitude > 0 then
            local accel = isDashing and 0.2 or 0.04
            slideMomentum = slideMomentum + moveDirection.Unit * accel
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
        slideMomentum = Vector3.zero
        if moveDirection.Magnitude > 0 then
            humanoid:Move(moveDirection, false)
        end
    end
end)
