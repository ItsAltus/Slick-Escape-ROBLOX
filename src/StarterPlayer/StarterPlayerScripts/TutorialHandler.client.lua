-- ============================================================
-- Script Name: TutorialHandler.client.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Handles the tutorial overlay by dynamically fetching and managing
--              GUI elements, setting up a character viewport with a dedicated camera,
--              implementing a typewriter effect for tutorial text, and handling input
--              to skip or close the tutorial.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

---------------------------------------------------------------
-- HELPER FUNCTIONS: GUI FETCHING
---------------------------------------------------------------
--[[
    Function: getTutorialGui
    Description: Retrieves the TutorialGui from the player's PlayerGui.
    Returns: The TutorialGui instance.
]]
local function getTutorialGui()
    local playerGui = player:WaitForChild("PlayerGui")
    local tutGui = playerGui:WaitForChild("TutorialGui")
    return tutGui
end

--[[
    Function: getMainFrame
    Description: Retrieves the MainFrame from the TutorialGui.
    Returns: The MainFrame instance.
]]
local function getMainFrame()
    local tutGui = getTutorialGui()
    local mf = tutGui:WaitForChild("MainFrame")
    return mf
end

--[[
    Function: getCharacterViewport
    Description: Retrieves the CharacterViewport from the MainFrame.
    Returns: The CharacterViewport instance.
]]
local function getCharacterViewport()
    local mainFrame = getMainFrame()
    local cv = mainFrame:WaitForChild("CharacterViewport")
    return cv
end

--[[
    Function: getTutorialText
    Description: Retrieves the TutorialText from the MainFrame.
    Returns: The TutorialText instance.
]]
local function getTutorialText()
    local mainFrame = getMainFrame()
    local tt = mainFrame:WaitForChild("TutorialText")
    return tt
end

---------------------------------------------------------------
-- HELPER FUNCTIONS: CHARACTER VIEWPORT SETUP
---------------------------------------------------------------
---------------------------------------------
-- Set up a dedicated camera for the viewport.
---------------------------------------------
local camera = Instance.new("Camera")
camera.FieldOfView = 70

local isTyping = false
local finishedTyping = false

---------------------------------------------
-- Remove existing clones.
---------------------------------------------
--[[
    Function: cleanupCharacterClone
    Description: Removes any existing character clones from the CharacterViewport.
    Returns: None.
]]
local function cleanupCharacterClone()
    local cv = getCharacterViewport()
    for _, child in ipairs(cv:GetChildren()) do
        if child:IsA("Model") then
            child:Destroy()
        end
    end
end

---------------------------------------------
-- Wait for a valid character with a primary part.
---------------------------------------------
--[[
    Function: waitForValidCharacter
    Description: Waits for a valid character to load that contains a HumanoidRootPart.
    Returns: The valid character model.
]]
local function waitForValidCharacter()
    local character = player.Character or player.CharacterAdded:Wait(5)
    -- Check if character is a descendant of the DeadBodies folder
    while not character or not character:FindFirstChild("HumanoidRootPart") or 
          (character:IsDescendantOf(workspace:FindFirstChild("DeadBodies"))) do
        task.wait(0.1)
        character = player.Character or player.CharacterAdded:Wait(5)
    end
    return character
end

---------------------------------------------
-- Clone the player's character for the viewport.
---------------------------------------------
--[[
    Function: setupCharacterView
    Description: Clones the player's character and sets it up in the CharacterViewport.
    Returns: None.
]]
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

    task.wait(1)  -- Wait briefly for character stabilization

    -- Ensure the character can be cloned
    character.Archivable = true

    local success, charClone = pcall(function()
        return character:Clone()
    end)
    if not success or not charClone then
        warn("Failed to clone character! Error:", tostring(charClone))
        return
    end

    -- Remove any LocalScripts from the clone and freeze parts for stable display
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

    -- Pivot the clone to proper position & orientation
    local head = charClone:FindFirstChild("Head")
    local rootPart = charClone:FindFirstChild("HumanoidRootPart") or head
    if rootPart then
        charClone.PrimaryPart = rootPart
        local pivot = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0)
        charClone:PivotTo(pivot)
    end

    -- Position the camera to view the character's face
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

---------------------------------------------------------------
-- TYPEWRITER EFFECT FOR TUTORIAL TEXT
---------------------------------------------------------------
--[[
    Function: typeText
    Description: Implements a typewriter effect to display the provided text gradually.
    Parameters:
        fullText - The complete text string to display.
    Returns: None.
]]
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
        task.wait(0.04)  -- Wait briefly between each character
    end

    isTyping = false
    finishedTyping = true
end

---------------------------------------------------------------
-- SHOW TUTORIAL OVERLAY
---------------------------------------------------------------
--[[
    Function: showTutorial
    Description: Displays the tutorial overlay with text and a character preview,
                 anchoring the player's character during the tutorial.
    Parameters:
        text - The tutorial message to display.
    Returns: None.
]]
local function showTutorial(text)
    local character = waitForValidCharacter()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true  -- Freeze player's movement while tutorial is active
    end

    setupCharacterView()

    local tutorialGui = getTutorialGui()
    tutorialGui.Enabled = true
    typeText(text)
end

---------------------------------------------------------------
-- INPUT LISTENER: SKIP OR CLOSE TUTORIAL
---------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        local tutorialGui = getTutorialGui()
        if tutorialGui.Enabled then
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if isTyping then
                    isTyping = false  -- Skip typewriter effect and immediately display full text
                elseif finishedTyping then
                    tutorialGui.Enabled = false  -- Close the tutorial overlay
                    local character = waitForValidCharacter()
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Anchored = false  -- Unfreeze the player's movement
                    end
                    cleanupCharacterClone()  -- Remove cloned character from the viewport
                end
            end
        end
    end
end)

---------------------------------------------------------------
-- EVENT CONNECTION: LISTEN FOR TUTORIAL EVENT
---------------------------------------------------------------
local TutorialEvent = ReplicatedStorage:WaitForChild("TutorialEvent")
TutorialEvent.OnClientEvent:Connect(function(text)
    showTutorial(text)
end)
