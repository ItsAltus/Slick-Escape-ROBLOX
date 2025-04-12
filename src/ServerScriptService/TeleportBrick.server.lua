local part = workspace:WaitForChild("TeleportBrick")
part.Transparency = 1

local spawnLocation = game.Workspace:FindFirstChild("SpawnLocation")

part.Touched:Connect(function(hit)
    local character = hit.Parent
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and spawnLocation and humanoid.Health > 0 then
        character:MoveTo(spawnLocation.Position)
    end
end)
