local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local NextLevelEvent = ReplicatedStorage:WaitForChild("NextLevel")

local playerGui = player:WaitForChild("PlayerGui")
local levelCompleteGui = playerGui:WaitForChild("LevelComplete")
levelCompleteGui.Enabled = false

local completeText = levelCompleteGui:WaitForChild("CompleteText")
local nextButton = levelCompleteGui:WaitForChild("NextButton")

nextButton.Visible = false
completeText.TextTransparency = 1
nextButton.TextTransparency = 1

NextLevelEvent.OnClientEvent:Connect(function()
    print("Level Complete! Showing UI...")
    task.wait(0.5)
    local hrp = PlayerUtils.getHRP()
    if hrp then
        hrp.Anchored = true
    else
        warn("HumanoidRootPart not found when completing level!")
    end
    levelCompleteGui.Enabled = true

    TweenService:Create(completeText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1)
    nextButton.Visible = true
    TweenService:Create(nextButton, TweenInfo.new(1), {TextTransparency = 0}):Play()

    nextButton.MouseButton1Click:Wait()

    levelCompleteGui.Enabled = false
    completeText.TextTransparency = 1
    nextButton.TextTransparency = 1
    nextButton.Visible = false

    print(player.leaderstats.Level.Value)

    hrp = PlayerUtils.getHRP()
    if hrp then
        hrp.Anchored = false
    end

    ReplicatedStorage:WaitForChild("AdvanceLevel"):FireServer()
end)
