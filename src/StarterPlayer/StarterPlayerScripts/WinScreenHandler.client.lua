-- WinScreenHandler.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local WinGameEvent = ReplicatedStorage:WaitForChild("WinGame")
local RespawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

-- Get GUI objects
local playerGui = player:WaitForChild("PlayerGui")
local winScreen = playerGui:WaitForChild("WinScreen")
local levelCompleteGui = playerGui:WaitForChild("LevelComplete")
local mainMenu = playerGui:WaitForChild("MainMenu")
local settingsMenu = playerGui:WaitForChild("SettingsMenu")
local settingsButton = mainMenu:WaitForChild("SettingsButton")

local winText = winScreen:WaitForChild("WinText")
local returnButton = winScreen:WaitForChild("ReturnButton")

-- Configure initial UI state
winScreen.Enabled = false
returnButton.Visible = false
winText.TextTransparency = 1
returnButton.TextTransparency = 1

local function anchorPlayer(isAnchored)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.Anchored = isAnchored
end

-- Helper function: Wait for character to exist and load the Humanoid (with a timeout if needed)
local function waitForCharacter()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
    end
    return char
end

-- When the win event fires, show the win screen and then reset the game state.
WinGameEvent.OnClientEvent:Connect(function()
    print("Game Won! Showing Win Screen...")

    -- Disable the level complete GUI
    levelCompleteGui.Enabled = false

    -- Enable the win screen
    winScreen.Enabled = true

    TweenService:Create(winText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1)
    returnButton.Visible = true
    TweenService:Create(returnButton, TweenInfo.new(1), {TextTransparency = 0}):Play()

    -- Wait for the player to click the return button
    returnButton.MouseButton1Click:Wait()

    -- Reset the player's level and spawn attribute
    player.leaderstats.Level.Value = 0
    player:SetAttribute("CurrentSpawn", nil)

    -- Fire the server event to respawn the player
    RespawnRequest:FireServer()

    -- Return to main menu – ensure all other GUIs are disabled
    mainMenu.Enabled = true
    settingsButton.Enabled = false
    settingsMenu.Enabled = false
    winScreen.Enabled = false

    -- Anchor the player's character until the menu is active
    anchorPlayer(true)

    -- Reset the camera so that UI elements can receive input
    local character = waitForCharacter()
    local humanoid = character:WaitForChild("Humanoid")
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid

    print("Returned to Main Menu; camera reset for UI input.")
end)
