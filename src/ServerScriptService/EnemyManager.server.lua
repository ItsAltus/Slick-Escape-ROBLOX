local EnemyModule = require(game.ReplicatedStorage.Modules.EnemyModule)

local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]
if not player then
    Players.PlayerAdded:Wait()
    player = Players:GetPlayers()[1]
end

local enemies = {}

local enemy1Settings = {
    Speed = 5,
    chaseSpeed = 30,
    VisionSize = Vector3.new(10, 22, 20),
    Transparency = 0.9
}

local enemy2Settings = {
    Speed = 10,
    chaseSpeed = 15,
    VisionSize = Vector3.new(30, 22, 30),
    Transparency = 0.9
}

local enemy1 = EnemyModule.new(workspace.Enemy1, workspace.Waypoint1, workspace.Waypoint2, enemy1Settings, player)
local enemy2 = EnemyModule.new(workspace.Enemy2, workspace.Waypoint3, workspace.Waypoint4, enemy2Settings, player)

table.insert(enemies, enemy1)
table.insert(enemies, enemy2)

for _, enemy in ipairs(enemies) do
    task.spawn(function()
        enemy:Start()
    end)
end
