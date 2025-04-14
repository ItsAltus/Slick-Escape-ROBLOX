local ReplicatedStorage = game:GetService("ReplicatedStorage")
local respawnRequest = ReplicatedStorage:WaitForChild("RespawnRequest")

game.Players.PlayerAdded:Connect(function(player)
	player:LoadCharacter()
end)

respawnRequest.OnServerEvent:Connect(function(player)
    player:LoadCharacter()

     local character = player.Character or player.CharacterAdded:Wait()
     local hrp = character:WaitForChild("HumanoidRootPart")

     local spawnCFrame = player:GetAttribute("CurrentSpawn")
     if spawnCFrame then
         hrp.CFrame = spawnCFrame + Vector3.new(0, 3, 0)
     else
         warn("No spawn set for player!")
     end
end)
