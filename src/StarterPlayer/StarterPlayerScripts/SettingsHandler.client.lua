-- ============================================================
-- Script Name: SettingsHandler.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Manages the settings UI for volume and music selection,
--              allowing players to adjust the background music volume and select a track.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local mainMenu = playerGui:WaitForChild("MainMenu")
local settingsMenu = playerGui:WaitForChild("SettingsMenu")
local settingsButton = mainMenu:WaitForChild("SettingsButton")
local backButton = settingsMenu.MainFrame:WaitForChild("BackButton")

local volumeSlider = settingsMenu.MainFrame:WaitForChild("VolumeSlider")
local fill = volumeSlider:WaitForChild("Fill")
local handle = volumeSlider:WaitForChild("Handle")
fill.Size = UDim2.new(0.5, 0, 1, 0)  -- Initialize fill size at 50%
handle.Position = UDim2.new(0.5, -10, 0.5, -10)  -- Center handle on initial fill

local music1Button = settingsMenu.MainFrame:WaitForChild("Music1Button")
local music2Button = settingsMenu.MainFrame:WaitForChild("Music2Button")
local music3Button = settingsMenu.MainFrame:WaitForChild("Music3Button")

local backgroundMusic = SoundService:FindFirstChild("BackgroundMusic")
if not backgroundMusic then
    backgroundMusic = Instance.new("Sound")
    backgroundMusic.Name = "BackgroundMusic"
    backgroundMusic.Looped = true
    backgroundMusic.Volume = 0.5
    backgroundMusic.Parent = SoundService
end

local musicTracks = {
    "rbxassetid://95153067183538",
    "rbxassetid://89436261283894",
    "rbxassetid://90896056368857"
}

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
settingsButton.MouseButton1Click:Connect(function()
    mainMenu.Enabled = false
    settingsMenu.Enabled = true
end)

backButton.MouseButton1Click:Connect(function()
    settingsMenu.Enabled = false
    mainMenu.Enabled = true
end)

---------------------------------------------------------------
-- MUSIC HANDLING
---------------------------------------------------------------
--[[
    Function: playMusic
    Description: Sets the background music track to the provided id and plays it.
    Parameters:
        id - The sound asset id.
    Returns: None
]]
local function playMusic(id)
    backgroundMusic.SoundId = id
    backgroundMusic:Play()
end

music1Button.MouseButton1Click:Connect(function()
    playMusic(musicTracks[1])
end)

music2Button.MouseButton1Click:Connect(function()
    playMusic(musicTracks[2])
end)

music3Button.MouseButton1Click:Connect(function()
    playMusic(musicTracks[3])
end)

---------------------------------------------------------------
-- VOLUME ADJUSTMENT
---------------------------------------------------------------
local dragging = false

--[[
    Function: updateVolume
    Description: Updates the volume slider UI and background music volume based on mouse X position.
    Parameters:
        mouseX - The current mouse X coordinate.
    Returns: None
]]
local function updateVolume(mouseX)
    local sliderPos = volumeSlider.AbsolutePosition.X
    local sliderSize = volumeSlider.AbsoluteSize.X
    local newFillSize = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)  -- Calculate fill size as a fraction

    fill.Size = UDim2.new(newFillSize, 0, 1, 0)
    handle.Position = UDim2.new(newFillSize, -10, 0.5, -10)

    backgroundMusic.Volume = newFillSize  -- Set music volume proportional to the fill size
end

handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true  -- Begin dragging the slider
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false  -- Stop dragging the slider
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateVolume(input.Position.X)  -- Update volume continuously during dragging
    end
end)

---------------------------------------------------------------
-- INITIAL MUSIC PLAYBACK
---------------------------------------------------------------
backgroundMusic.SoundId = musicTracks[1]
backgroundMusic:Play()
