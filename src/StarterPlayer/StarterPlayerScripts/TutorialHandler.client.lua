local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

------------------------------------------------------------
-- Helper functions to re-fetch our GUI objects dynamically --
------------------------------------------------------------
local function getTutorialGui()
    local playerGui = player:WaitForChild("PlayerGui")
    local tutGui = playerGui:WaitForChild("TutorialGui")
    print("Found TutorialGui:", tutGui)
    return tutGui
end

local function getMainFrame()
    local tutGui = getTutorialGui()
    local mf = tutGui:WaitForChild("MainFrame")
    print("Found MainFrame:", mf)
    return mf
end

local function getCharacterViewport()
    local mainFrame = getMainFrame()
    local cv = mainFrame:WaitForChild("CharacterViewport")
    print("Found CharacterViewport:", cv)
    return cv
end

local function getTutorialText()
    local mainFrame = getMainFrame()
    local tt = mainFrame:WaitForChild("TutorialText")
    print("Found TutorialText:", tt)
    return tt
end

---------------------------------------------
-- Set up a dedicated camera for the viewport
---------------------------------------------
local camera = Instance.new("Camera")
camera.FieldOfView = 70

local isTyping = false
local finishedTyping = false

------------------------------
-- Remove existing clones
------------------------------
local function cleanupCharacterClone()
    local cv = getCharacterViewport()
    for _, child in ipairs(cv:GetChildren()) do
        if child:IsA("Model") then
            child:Destroy()
        end
    end
end

---------------------------------------------
-- Wait for a valid character with a primary part
---------------------------------------------
local function waitForValidCharacter()
    local character = player.Character or player.CharacterAdded:Wait(5)
    while not character or not character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.1)
        character = player.Character or player.CharacterAdded:Wait(5)
    end
    return character
end

---------------------------------------------
-- Clone the player's character for the viewport
---------------------------------------------
local function setupCharacterView()
    local characterViewport = getCharacterViewport()
    if not characterViewport then
        warn("CharacterViewport not found!")
        return
    end

    characterViewport.CurrentCamera = camera

    local character = waitForValidCharacter()
    if not character then
        warn("No character found!")
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("No humanoid found in character!")
        return
    end

    task.wait(1)

    local success, charClone = pcall(function()
        return character:Clone()
    end)
    if not success or not charClone then
        warn("Failed to clone character! Error:", tostring(charClone))
        return
    end

    -- Remove any LocalScripts
    for _, desc in ipairs(charClone:GetDescendants()) do
        if desc:IsA("LocalScript") then
            desc:Destroy()
        elseif desc:IsA("BasePart") then
            desc.Anchored = true
            desc.CanCollide = false
        end
    end

    cleanupCharacterClone()
    charClone.Parent = characterViewport
    print("Cloned character and parented to CharacterViewport.")

    -- Pivot the clone to a known position & orientation
    local head = charClone:FindFirstChild("Head")
    local rootPart = charClone:FindFirstChild("HumanoidRootPart") or head
    if rootPart then
        charClone.PrimaryPart = rootPart
        local pivot = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0)
        charClone:PivotTo(pivot)
    end

    -- Position the camera to see the face
    if head then
        local forwardOffset = 2.5
        local verticalOffset = 0.5
        local downwardAngleDeg = 15

        local cameraPosition = head.Position + Vector3.new(0, verticalOffset, forwardOffset)
        local lookAtPosition = head.Position
        local pivot = CFrame.lookAt(cameraPosition, lookAtPosition)
        local finalCameraCFrame = pivot * CFrame.Angles(math.rad(-downwardAngleDeg), 0, 0)

        camera.CFrame = finalCameraCFrame
        print("Camera angled downward to view the face.")
    else
        if rootPart then
            camera.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 2, 5), rootPart.Position)
            print("No Head found; used HumanoidRootPart for camera.")
        else
            warn("No suitable part found to set the camera view!")
        end
    end
end


---------------------------------------------
-- Typewriter effect for tutorial text
---------------------------------------------
local function typeText(fullText)
    local tutorialText = getTutorialText()
    tutorialText.Text = ""
    isTyping = true
    finishedTyping = false

    for i = 1, #fullText do
        if not isTyping then
            tutorialText.Text = fullText
            break
        end
        tutorialText.Text = string.sub(fullText, 1, i)
        task.wait(0.04)  -- Adjust the speed of the typewriter effect if needed
    end

    isTyping = false
    finishedTyping = true
end

---------------------------------------------
-- Show the tutorial overlay with text and a character preview
---------------------------------------------
local function showTutorial(text)
    local character = waitForValidCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true -- Freeze player's movement while the tutorial is active
    end

    setupCharacterView()

    local tutorialGui = getTutorialGui()
    tutorialGui.Enabled = true
    typeText(text)
end

---------------------------------------------
-- Input listener to allow skipping typing or closing the tutorial
---------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        local tutorialGui = getTutorialGui()
        if tutorialGui.Enabled then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if isTyping then
                    isTyping = false -- Skip typewriter effect and show full text immediately
                elseif finishedTyping then
                    tutorialGui.Enabled = false
                    local character = waitForValidCharacter()
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Anchored = false -- Unfreeze the player
                    end
                    cleanupCharacterClone()
                end
            end
        end
    end
end)

---------------------------------------------
-- Listen for the TutorialEvent from the server
---------------------------------------------
local TutorialEvent = ReplicatedStorage:WaitForChild("TutorialEvent")
TutorialEvent.OnClientEvent:Connect(function(text)
    print("TutorialEvent received with text:", text)
    showTutorial(text)
end)
