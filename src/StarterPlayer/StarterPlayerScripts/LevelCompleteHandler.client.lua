-- ============================================================
-- Script Name: LevelCompleteHandler.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Listens for the NextLevelEvent from the server and shows a UI
--              for level completion. It anchors the player's character during UI
--              display, then unanchors and fires a server event to advance the level.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
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

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
NextLevelEvent.OnClientEvent:Connect(function()
    print("Level Complete! Showing UI...")
    task.wait(0.5)

    -- Anchor the player's character during the UI display to prevent movement
    local hrp = PlayerUtils.getHRP()
    if hrp then
        hrp.Anchored = true
    else
        warn("HumanoidRootPart not found when completing level!")
    end

    levelCompleteGui.Enabled = true

    -- Tween the complete text to fade in
    TweenService:Create(completeText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1)

    nextButton.Visible = true
    -- Tween the next button to fade in
    TweenService:Create(nextButton, TweenInfo.new(1), {TextTransparency = 0}):Play()

    nextButton.MouseButton1Click:Wait()  -- Wait until the player clicks the next button

    -- Reset UI elements to their original state
    levelCompleteGui.Enabled = false
    completeText.TextTransparency = 1
    nextButton.TextTransparency = 1
    nextButton.Visible = false

    print(player.leaderstats.Level.Value)

    -- Unanchor the player's character after UI is dismissed
    hrp = PlayerUtils.getHRP()
    if hrp then
        hrp.Anchored = false
    end

    ReplicatedStorage:WaitForChild("AdvanceLevel"):FireServer()  -- Trigger level advancement on the server
end)
