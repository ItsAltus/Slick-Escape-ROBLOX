local ReplicatedStorage = game:GetService("ReplicatedStorage")
local removeBodyPartsEvent = ReplicatedStorage:WaitForChild("RemoveBodyParts")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

local deadBodiesFolder = workspace:FindFirstChild("DeadBodies")
if not deadBodiesFolder then
    deadBodiesFolder = Instance.new("Folder")
    deadBodiesFolder.Name = "DeadBodies"
    deadBodiesFolder.Parent = workspace
end

removeBodyPartsEvent.OnServerEvent:Connect(function(player)
    local character = player.Character
    if character then
        character.Parent = deadBodiesFolder

        local parts = {}
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CollisionGroup = "DeadBodies"
                part.CanCollide = false
                table.insert(parts, part)
            end
        end

        local tweenInfo = TweenInfo.new(1)
        local tweenGoals = {Transparency = 1}
        local tweens = {}

        for _, part in ipairs(parts) do
            local tween = TweenService:Create(part, tweenInfo, tweenGoals)
            tween:Play()
            table.insert(tweens, tween)
        end

        for _, tween in ipairs(tweens) do
            tween.Completed:Wait()
        end
        task.wait(0.1)
        character:Destroy()
    end
end)
