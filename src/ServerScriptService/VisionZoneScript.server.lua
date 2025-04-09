local Players = game:GetService("Players")
local visionZone = workspace:WaitForChild("Enemy1"):WaitForChild("VisionZone")
local VisionState = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("VisionState"))

visionZone.Touched:Connect(function(hit)
    local character = hit.Parent
    local player = Players:GetPlayerFromCharacter(character)

    if player then
        print("[VISION] Player entered vision zone: ", player.Name)
        VisionState.PlayerInVisionZone = true
    end
end)

visionZone.TouchEnded:Connect(function(hit)
    local character = hit.Parent
    local player = Players:GetPlayerFromCharacter(character)

    if player then
        print("[VISION] Player left vision zone: ", player.Name)
        VisionState.PlayerInVisionZone = false
    end
end)
