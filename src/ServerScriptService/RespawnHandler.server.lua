local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

game.Players.PlayerAdded:Connect(function(player)
	player:LoadCharacter()
end)

respawnRequest.OnServerEvent:Connect(function(player)
    player:LoadCharacter()
end)
