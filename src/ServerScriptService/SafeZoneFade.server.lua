local safeZonesFolder = game.Workspace:WaitForChild("SafeZones")

for _, safeZone in safeZonesFolder:GetChildren() do
    if safeZone:IsA("BasePart") then
        coroutine.wrap(function()
            while true do
                for transparency = 0.5, 1, 0.05 do
                    safeZone.Transparency = transparency
                    task.wait(0.1)
                end
                for transparency = 1, 0.5, -0.05 do
                    safeZone.Transparency = transparency
                    task.wait(0.1)
                end
            end
        end)()
    end
end
