game.Players.PlayerAdded:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player

        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 0
        level.Parent = leaderstats
    end
end)
