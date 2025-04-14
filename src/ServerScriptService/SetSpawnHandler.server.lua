local ReplicatedStorage = game:GetService("ReplicatedStorage")
local setSpawnEvent = ReplicatedStorage:WaitForChild("SetSpawn")

setSpawnEvent.OnServerEvent:Connect(function(player, spawnCFrame)
    player:SetAttribute("CurrentSpawn", spawnCFrame)
end)
