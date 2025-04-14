-- ============================================================
-- Script Name: MainMenuHandler.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Handles the main menu UI behavior including game start,
--              switching to settings, and anchoring the player's character
--              based on their leaderstats.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local player = game.Players.LocalPlayer
local mainMenu = script.Parent:WaitForChild("MainMenu")
local settingsMenu = script.Parent:WaitForChild("SettingsMenu")
local startButton = mainMenu:WaitForChild("StartButton")
local settingsButton = mainMenu:WaitForChild("SettingsButton")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local setSpawnEvent = ReplicatedStorage:WaitForChild("SetSpawn")
local startGameEvent = ReplicatedStorage:WaitForChild("StartGame")
local playerGui = player:WaitForChild("PlayerGui")
local winScreen = playerGui:WaitForChild("WinScreen")
local levelCompleteGui = playerGui:WaitForChild("LevelComplete")

local Level1Spawn = workspace:WaitForChild("Level1Spawn")

mainMenu.Enabled = true
winScreen.Enabled = false
levelCompleteGui.Enabled = false

---------------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------------
local function anchorPlayer(isAnchored)
    -- Retrieve the player's character (or wait for one to load)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.Anchored = isAnchored  -- Anchor or unanchor the character as needed
end

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
startButton.MouseButton1Click:Connect(function()
    mainMenu.Enabled = false
    player.Character.Archivable = true  -- Ensure the character can be cloned if needed

    startGameEvent:FireServer()  -- Notify the server to start the game
    setSpawnEvent:FireServer(Level1Spawn.CFrame)  -- Set the player's spawn location

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = Level1Spawn.CFrame + Vector3.new(0, 3, 0)  -- Position the character above the spawn

    hrp.Anchored = false  -- Unanchor the character once positioned
end)

settingsButton.MouseButton1Click:Connect(function()
    mainMenu.Enabled = false
    settingsMenu.Enabled = true
end)

---------------------------------------------------------------
-- INITIAL UI STATE BASED ON LEADERSTATS
---------------------------------------------------------------
if player:WaitForChild("leaderstats"):WaitForChild("Level").Value == 0 then
    mainMenu.Enabled = true  -- Show main menu if player hasn't started the game yet
    anchorPlayer(true)      -- Anchor the player to prevent movement until game start
else
    mainMenu.Enabled = false -- Hide main menu if player has started the game
    anchorPlayer(false)      -- Allow the player to move
end
