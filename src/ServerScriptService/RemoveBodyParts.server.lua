-- ============================================================
-- Script Name: RemoveBodyParts.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Listens for the RemoveBodyParts event. When triggered,
--              this script moves the player's character to a "DeadBodies" folder,
--              applies tweening to fade out all BaseParts, waits for the tweens to complete,
--              then destroys the character.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local removeBodyPartsEvent = ReplicatedStorage:WaitForChild("RemoveBodyParts")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

-- Ensure there is a DeadBodies folder in the workspace for moving dead characters.
local deadBodiesFolder = workspace:FindFirstChild("DeadBodies")
if not deadBodiesFolder then
    deadBodiesFolder = Instance.new("Folder")
    deadBodiesFolder.Name = "DeadBodies"
    deadBodiesFolder.Parent = workspace
end

---------------------------------------------------------------
-- EVENT CONNECTIONS
---------------------------------------------------------------
removeBodyPartsEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    if character then
        -- Move the character to the DeadBodies folder
        character.Parent = deadBodiesFolder

        local parts = {}
        -- Gather all BaseParts in the character and update their properties
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CollisionGroup = "DeadBodies"
                part.CanCollide = false
                table.insert(parts, part)
            end
        end

        -- Set up tweening to fade out each BasePart over one second
        local tweenInfo = TweenInfo.new(1)
        local tweenGoals = {Transparency = 1}
        local tweens = {}

        for _, part in ipairs(parts) do
            local tween = TweenService:Create(part, tweenInfo, tweenGoals)
            tween:Play()
            table.insert(tweens, tween)
        end

        -- Wait for all tweens to complete before destroying the character
        for _, tween in ipairs(tweens) do
            tween.Completed:Wait()
        end

        task.wait(0.1)
        character:Destroy()  -- Remove the character from the game
    end
end)
