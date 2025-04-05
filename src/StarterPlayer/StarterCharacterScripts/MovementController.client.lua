local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local moveSpeed = 16
local dashSpeed = 40
local isDashing = false
local dashCooldown = 2
local lastDashTime = 0

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

RunService.RenderStepped:Connect(function()
    humanoid:Move(moveDirection, false)
end)

humanoid.WalkSpeed = moveSpeed
