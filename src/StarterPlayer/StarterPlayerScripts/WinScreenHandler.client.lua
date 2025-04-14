local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local WinGameEvent = ReplicatedStorage:WaitForChild("WinGame")

local playerGui = player:WaitForChild("PlayerGui")
local winScreen = playerGui:WaitForChild("WinScreen")
local levelCompleteGui = playerGui:WaitForChild("LevelComplete")

local winText = winScreen:WaitForChild("WinText")
local returnButton = winScreen:WaitForChild("ReturnButton")

winScreen.Enabled = false
returnButton.Visible = false
winText.TextTransparency = 1
returnButton.TextTransparency = 1

WinGameEvent.OnClientEvent:Connect(function()
    print("Game Won! Showing Win Screen...")
    levelCompleteGui.Enabled = false
    winScreen.Enabled = true

    TweenService:Create(winText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1)
    returnButton.Visible = true
    TweenService:Create(returnButton, TweenInfo.new(1), {TextTransparency = 0}):Play()

    returnButton.MouseButton1Click:Wait()

    player.leaderstats.Level.Value = "0"
    player:SetAttribute("CurrentSpawn", nil)
    game.ReplicatedStorage.RespawnRequest:FireServer()
end)
