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
fill.Size = UDim2.new(0.5, 0, 1, 0)
handle.Position = UDim2.new(0.5, -10, 0.5, -10)

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

settingsButton.MouseButton1Click:Connect(function()
    mainMenu.Enabled = false
    settingsMenu.Enabled = true
end)

backButton.MouseButton1Click:Connect(function()
    settingsMenu.Enabled = false
    mainMenu.Enabled = true
end)

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

local dragging = false

local function updateVolume(mouseX)
    local sliderPos = volumeSlider.AbsolutePosition.X
    local sliderSize = volumeSlider.AbsoluteSize.X
    local newFillSize = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)

    fill.Size = UDim2.new(newFillSize, 0, 1, 0)
    handle.Position = UDim2.new(newFillSize, -10, 0.5, -10)

    backgroundMusic.Volume = newFillSize
end

handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateVolume(input.Position.X)
    end
end)

backgroundMusic.SoundId = musicTracks[1]
backgroundMusic:Play()