local player = game.Players.LocalPlayer
local mainMenu = script.Parent:WaitForChild("MainMenu")
local settingsMenu = script.Parent:WaitForChild("SettingsMenu")
local startButton = mainMenu:WaitForChild("StartButton")
local settingsButton = mainMenu:WaitForChild("SettingsButton")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local setSpawnEvent = ReplicatedStorage:WaitForChild("SetSpawn")
local startGameEvent = ReplicatedStorage:WaitForChild("StartGame")

local Level1Spawn = workspace:WaitForChild("Level1Spawn")

mainMenu.Enabled = true

local function anchorPlayer(isAnchored)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.Anchored = isAnchored
end

startButton.MouseButton1Click:Connect(function()
    mainMenu.Enabled = false
    player.Character.Archivable = true

    startGameEvent:FireServer()

    setSpawnEvent:FireServer(Level1Spawn.CFrame)

    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    hrp.CFrame = Level1Spawn.CFrame + Vector3.new(0, 3, 0)

    hrp.Anchored = false
end)

settingsButton.MouseButton1Click:Connect(function()
    mainMenu.Enabled = false
    settingsMenu.Enabled = true
end)

if player:WaitForChild("leaderstats"):WaitForChild("Level").Value == 0 then
    mainMenu.Enabled = true
    anchorPlayer(true)
else
    mainMenu.Enabled = false
    anchorPlayer(false)
end
