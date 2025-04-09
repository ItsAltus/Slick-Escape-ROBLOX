local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VisionEvents = ReplicatedStorage:WaitForChild("VisionEvents")
local PlayerSeenEvent = VisionEvents:WaitForChild("PlayerSeenEvent")
local PlayerLostEvent = VisionEvents:WaitForChild("PlayerLostEvent")

local player = Players.LocalPlayer

local function onCharacterAdded(character)
    local visionZone = workspace:WaitForChild("Enemy1"):WaitForChild("VisionZone")

    visionZone.Touched:Connect(function(hit)
        if hit:IsDescendantOf(character) then
            print("[CLIENT] Touched VisionZone")
            PlayerSeenEvent:FireServer(player)
        end
    end)

    visionZone.TouchEnded:Connect(function(hit)
        if hit:IsDescendantOf(character) then
            print("[CLIENT] Left VisionZone")
            PlayerLostEvent:FireServer(player)
        end
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)
