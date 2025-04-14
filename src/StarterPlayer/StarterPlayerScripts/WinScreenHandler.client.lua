-- ============================================================
-- Script Name: WinScreenHandler.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Displays the win screen when the game is won, resets player level,
--              and returns the player to the main menu. It anchors the player's character
--              and resets the camera for UI input after a win.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local WinGameEvent = ReplicatedStorage:WaitForChild("WinGame")
local RespawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

local playerGui = player:WaitForChild("PlayerGui")
local winScreen = playerGui:WaitForChild("WinScreen")
local levelCompleteGui = playerGui:WaitForChild("LevelComplete")
local mainMenu = playerGui:WaitForChild("MainMenu")
local settingsMenu = playerGui:WaitForChild("SettingsMenu")
local settingsButton = mainMenu:WaitForChild("SettingsButton")

local winText = winScreen:WaitForChild("WinText")
local returnButton = winScreen:WaitForChild("ReturnButton")

---------------------------------------------------------------
-- INITIAL UI CONFIGURATION
---------------------------------------------------------------
winScreen.Enabled = false
returnButton.Visible = false
winText.TextTransparency = 1
returnButton.TextTransparency = 1

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
--[[
    Function: anchorPlayer
    Description: Anchors or unanchors the player's character by modifying the HumanoidRootPart.
    Parameters:
        isAnchored - Boolean indicating whether to anchor (true) or unanchor (false).
    Returns: None
]]
local function anchorPlayer(isAnchored)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.Anchored = isAnchored
end

--[[
    Function: waitForCharacter
    Description: Waits for the player's character to be available.
    Returns: The player's character.
]]
local function waitForCharacter()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
    end
    return char
end

---------------------------------------------------------------
-- EVENT CONNECTIONS: WIN GAME HANDLING
---------------------------------------------------------------
WinGameEvent.OnClientEvent:Connect(function()
    -- Disable the level complete GUI before showing win screen
    levelCompleteGui.Enabled = false

    -- Enable and display the win screen
    winScreen.Enabled = true
    TweenService:Create(winText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1)
    returnButton.Visible = true
    TweenService:Create(returnButton, TweenInfo.new(1), {TextTransparency = 0}):Play()

    -- Wait until the player clicks the return button
    returnButton.MouseButton1Click:Wait()

    -- Reset the player's level and spawn attribute
    player.leaderstats.Level.Value = 0
    player:SetAttribute("CurrentSpawn", nil)

    -- Fire the server event to respawn the player
    RespawnRequest:FireServer()

    -- Return to main menu: Disable unnecessary GUIs and anchor player until menu active.
    mainMenu.Enabled = true
    settingsButton.Enabled = false
    settingsMenu.Enabled = false
    winScreen.Enabled = false
    anchorPlayer(true)

    -- Reset the camera so that UI elements can receive input.
    local character = waitForCharacter()
    local humanoid = character:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
end)
