local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

local TweenService = game:GetService("TweenService")

local player = PlayerUtils.getPlayer()
local deathScreen = player:WaitForChild("PlayerGui"):WaitForChild("DeathScreen")
local deathMessage = deathScreen:WaitForChild("DeathMessage")

local humanoid = script.Parent:WaitForChild("Humanoid")

local function showDeathScreen()
    deathScreen.Enabled = true

    local fadeTween = TweenService:Create(deathMessage, TweenInfo.new(1), {TextTransparency = 0})
    fadeTween:Play()

    fadeTween.Completed:Wait()
    task.wait(2)

    respawnRequest:FireServer()
end

humanoid.Died:Connect(function()
    showDeathScreen()
end)
