-- EnemyManager.server.lua
local EnemyModule = require(game.ReplicatedStorage.Modules.EnemyModule)
local Players = game:GetService("Players")

local player = Players:GetPlayers()[1]
if not player then
    Players.PlayerAdded:Wait()
    player = Players:GetPlayers()[1]
end

-- Define enemy configurations using a table for clarity and ease of extension
local enemyConfigs = {
    {
        enemyModel = workspace.Enemy1,
        waypoint1 = workspace.Waypoint1,
        waypoint2 = workspace.Waypoint2,
        settings = { Speed = 5, chaseSpeed = 30, VisionSize = Vector3.new(10, 22, 20), Transparency = 0.9 }
    },
    {
        enemyModel = workspace.Enemy2,
        waypoint1 = workspace.Waypoint3,
        waypoint2 = workspace.Waypoint4,
        settings = { Speed = 10, chaseSpeed = 15, VisionSize = Vector3.new(30, 22, 30), Transparency = 0.9 }
    },
    {
        enemyModel = workspace.Enemy3,
        waypoint1 = workspace.Waypoint5,
        waypoint2 = workspace.Waypoint6,
        settings = { Speed = 5, chaseSpeed = 20, VisionSize = Vector3.new(40, 22, 15), Transparency = 0.9 }
    },
    {
        enemyModel = workspace.Enemy4,
        waypoint1 = workspace.Waypoint7,
        waypoint2 = workspace.Waypoint8,
        settings = { Speed = 10, chaseSpeed = 15, VisionSize = Vector3.new(30, 22, 30), Transparency = 0.9 }
    },
    {
        enemyModel = workspace.Enemy5,
        waypoint1 = workspace.Waypoint9,
        waypoint2 = workspace.Waypoint10,
        settings = { Speed = 20, chaseSpeed = 22, VisionSize = Vector3.new(15, 22, 50), Transparency = 0.9 }
    },
    {
        enemyModel = workspace.Enemy6,
        waypoint1 = workspace.Waypoint11,
        waypoint2 = workspace.Waypoint12,
        settings = { Speed = 7, chaseSpeed = 12, VisionSize = Vector3.new(25, 22, 20), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy7,
        waypoint1 = workspace.Waypoint13,
        waypoint2 = workspace.Waypoint14,
        settings = { Speed = 7, chaseSpeed = 18, VisionSize = Vector3.new(28, 22, 30), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy8,
        waypoint1 = workspace.Waypoint17,
        waypoint2 = workspace.Waypoint18,
        settings = { Speed = 20, chaseSpeed = 25, VisionSize = Vector3.new(35, 22, 50), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy9,
        waypoint1 = workspace.Waypoint15,
        waypoint2 = workspace.Waypoint16,
        settings = { Speed = 10, chaseSpeed = 20, VisionSize = Vector3.new(30, 22, 25), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy10,
        waypoint1 = workspace.Waypoint19,
        waypoint2 = workspace.Waypoint20,
        settings = { Speed = 6, chaseSpeed = 10, VisionSize = Vector3.new(30, 22, 40), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy11,
        waypoint1 = workspace.Waypoint21,
        waypoint2 = workspace.Waypoint22,
        settings = { Speed = 6, chaseSpeed = 18, VisionSize = Vector3.new(30, 22, 40), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy12,
        waypoint1 = workspace.Waypoint23,
        waypoint2 = workspace.Waypoint24,
        settings = { Speed = 25, chaseSpeed = 40, VisionSize = Vector3.new(100, 22, 100), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy13,
        waypoint1 = workspace.Waypoint25,
        waypoint2 = workspace.Waypoint26,
        settings = { Speed = 12, chaseSpeed = 20, VisionSize = Vector3.new(20, 22, 30), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy14,
        waypoint1 = workspace.Waypoint27,
        waypoint2 = workspace.Waypoint28,
        settings = { Speed = 12, chaseSpeed = 20, VisionSize = Vector3.new(20, 22, 30), Transparency = 1 }
    },
    {
        enemyModel = workspace.Enemy15,
        waypoint1 = workspace.Waypoint29,
        waypoint2 = workspace.Waypoint30,
        settings = { Speed = 12, chaseSpeed = 20, VisionSize = Vector3.new(30, 22, 40), Transparency = 1 }
    },
}

local enemies = {}

for _, config in ipairs(enemyConfigs) do
    local enemy = EnemyModule.new(config.enemyModel, config.waypoint1, config.waypoint2, config.settings, player)
    table.insert(enemies, enemy)
    task.spawn(function()
        enemy:Start()
    end)
end
