-- src/Workspace/Enemy1Script.lua

local enemy = workspace:WaitForChild("Enemy1")
local waypoint1 = workspace:WaitForChild("Waypoint1")
local waypoint2 = workspace:WaitForChild("Waypoint2")

local currentTarget = waypoint1
local speed = 8 -- Adjust enemy speed here

while true do
    local direction = (currentTarget.Position - enemy.Position).Unit
    enemy.CFrame = enemy.CFrame + (direction * speed * 0.03)

    if (enemy.Position - currentTarget.Position).Magnitude < 1 then
        -- Switch target when close
        if currentTarget == waypoint1 then
            currentTarget = waypoint2
        else
            currentTarget = waypoint1
        end
    end

    task.wait(0.03)
end
