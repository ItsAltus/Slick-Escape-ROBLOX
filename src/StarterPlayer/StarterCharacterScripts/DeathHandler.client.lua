-- ============================================================
-- Script Name: DeathHandler.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Displays a death screen with a blur effect and tween when the player dies.
--              After pressing retry, the player's respawn is requested.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
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

---------------------------------------------------------------
-- BLUR EFFECT SETUP
---------------------------------------------------------------
local blur = Instance.new("BlurEffect")
blur.Size = 24  -- Set blur intensity
blur.Parent = Lighting
blur.Enabled = false

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
--[[
    Function: showDeathScreen
    Description: Displays the death screen and blur effect; waits for the player to click retry;
                 then hides UI elements and fires a respawn request to the server.
    Parameters: None
    Returns: None
]]
local function showDeathScreen()
    deathScreen.Enabled = true
    blur.Enabled = true

    -- Tween the death message to fade in
    local fadeTween = TweenService:Create(deathMessage, TweenInfo.new(1), {TextTransparency = 0})
    fadeTween:Play()
    fadeTween.Completed:Wait()

    retryButton.Visible = true
    -- Tween the retry button to fade in
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

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
humanoid.Died:Connect(function()
    -- Fire event to remove body parts for death effect
    game.ReplicatedStorage:WaitForChild("RemoveBodyParts"):FireServer()
    task.wait(1.2)
    showDeathScreen()
end)
