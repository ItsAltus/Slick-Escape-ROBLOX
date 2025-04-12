local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = PlayerUtils.getPlayer()
local deathScreen = player:WaitForChild("PlayerGui"):WaitForChild("DeathScreen")
local deathMessage = deathScreen:WaitForChild("DeathMessage")
local retryButton = deathScreen:WaitForChild("RetryButton")

local character = PlayerUtils.getCharacter()
local humanoid = script.Parent:WaitForChild("Humanoid")

local blur = Instance.new("BlurEffect")
blur.Size = 24
blur.Parent = Lighting
blur.Enabled = false

local function showDeathScreen()
    deathScreen.Enabled = true
    blur.Enabled = true

    local fadeTween = TweenService:Create(deathMessage, TweenInfo.new(1), {TextTransparency = 0})
    fadeTween:Play()
    fadeTween.Completed:Wait()

    retryButton.Visible = true
    local retryFade = TweenService:Create(retryButton, TweenInfo.new(1), {TextTransparency = 0})
    retryFade:Play()

    local clicked = false
    retryButton.MouseButton1Click:Connect(function()
        clicked = true
    end)
    repeat
        task.wait(0.1)
    until clicked

    blur.Enabled = false
    blur:Destroy()
    deathScreen.Enabled = false
    respawnRequest:FireServer()
end

humanoid.Died:Connect(function()
    game.ReplicatedStorage:WaitForChild("RemoveBodyParts"):FireServer()
    task.wait(1.2)
    showDeathScreen()
end)
