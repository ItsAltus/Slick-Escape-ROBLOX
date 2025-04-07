local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

respawnRequest.OnServerEvent:Connect(function(player)
    player:LoadCharacter()
end)
