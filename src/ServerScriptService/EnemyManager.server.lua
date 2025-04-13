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

local enemy3Settings = {
    Speed = 5,
    chaseSpeed = 20,
    VisionSize = Vector3.new(40, 22, 15),
    Transparency = 0.9
}

local enemy4Settings = {
    Speed = 10,
    chaseSpeed = 15,
    VisionSize = Vector3.new(30, 22, 30),
    Transparency = 0.9
}

local enemy5Settings = {
    Speed = 20,
    chaseSpeed = 22,
    VisionSize = Vector3.new(15, 22, 50),
    Transparency = 0.9
}

local enemy6Settings = {
    Speed = 5,
    chaseSpeed = 10,
    VisionSize = Vector3.new(25, 22, 20),
    Transparency = 0.9
}

local enemy1 = EnemyModule.new(workspace.Enemy1, workspace.Waypoint1, workspace.Waypoint2, enemy1Settings, player)
local enemy2 = EnemyModule.new(workspace.Enemy2, workspace.Waypoint3, workspace.Waypoint4, enemy2Settings, player)
local enemy3 = EnemyModule.new(workspace.Enemy3, workspace.Waypoint5, workspace.Waypoint6, enemy3Settings, player)
local enemy4 = EnemyModule.new(workspace.Enemy4, workspace.Waypoint7, workspace.Waypoint8, enemy4Settings, player)
local enemy5 = EnemyModule.new(workspace.Enemy5, workspace.Waypoint9, workspace.Waypoint10, enemy5Settings, player)
local enemy6 = EnemyModule.new(workspace.Enemy6, workspace.Waypoint11, workspace.Waypoint12, enemy6Settings, player)

table.insert(enemies, enemy1)
table.insert(enemies, enemy2)
table.insert(enemies, enemy3)
table.insert(enemies, enemy4)
table.insert(enemies, enemy5)
table.insert(enemies, enemy6)

for _, enemy in ipairs(enemies) do
    task.spawn(function()
        enemy:Start()
    end)
end
