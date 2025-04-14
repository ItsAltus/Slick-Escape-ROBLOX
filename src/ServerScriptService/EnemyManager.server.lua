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
    Speed = 7,
    chaseSpeed = 12,
    VisionSize = Vector3.new(25, 22, 20),
    Transparency = 1
}

local enemy7Settings = {
    Speed = 7,
    chaseSpeed = 18,
    VisionSize = Vector3.new(28, 22, 30),
    Transparency = 1
}

local enemy8Settings = {
    Speed = 20,
    chaseSpeed = 25,
    VisionSize = Vector3.new(35, 22, 50),
    Transparency = 1
}

local enemy9Settings = {
    Speed = 10,
    chaseSpeed = 20,
    VisionSize = Vector3.new(30, 22, 25),
    Transparency = 1
}

local enemy10Settings = {
    Speed = 6,
    chaseSpeed = 10,
    VisionSize = Vector3.new(30, 22, 40),
    Transparency = 1
}

local enemy11Settings = {
    Speed = 6,
    chaseSpeed = 18,
    VisionSize = Vector3.new(30, 22, 40),
    Transparency = 1
}

local enemy12Settings = {
    Speed = 25,
    chaseSpeed = 40,
    VisionSize = Vector3.new(100, 22, 100),
    Transparency = 1
}

local enemy13Settings = {
    Speed = 12,
    chaseSpeed = 20,
    VisionSize = Vector3.new(20, 22, 30),
    Transparency = 1
}

local enemy14Settings = {
    Speed = 12,
    chaseSpeed = 20,
    VisionSize = Vector3.new(20, 22, 30),
    Transparency = 1
}

local enemy15Settings = {
    Speed = 12,
    chaseSpeed = 20,
    VisionSize = Vector3.new(30, 22, 40),
    Transparency = 1
}


local enemy1 = EnemyModule.new(workspace.Enemy1, workspace.Waypoint1, workspace.Waypoint2, enemy1Settings, player)
local enemy2 = EnemyModule.new(workspace.Enemy2, workspace.Waypoint3, workspace.Waypoint4, enemy2Settings, player)
local enemy3 = EnemyModule.new(workspace.Enemy3, workspace.Waypoint5, workspace.Waypoint6, enemy3Settings, player)
local enemy4 = EnemyModule.new(workspace.Enemy4, workspace.Waypoint7, workspace.Waypoint8, enemy4Settings, player)
local enemy5 = EnemyModule.new(workspace.Enemy5, workspace.Waypoint9, workspace.Waypoint10, enemy5Settings, player)
local enemy6 = EnemyModule.new(workspace.Enemy6, workspace.Waypoint11, workspace.Waypoint12, enemy6Settings, player)
local enemy7 = EnemyModule.new(workspace.Enemy7, workspace.Waypoint13, workspace.Waypoint14, enemy7Settings, player)
local enemy8 = EnemyModule.new(workspace.Enemy8, workspace.Waypoint17, workspace.Waypoint18, enemy8Settings, player)
local enemy9 = EnemyModule.new(workspace.Enemy9, workspace.Waypoint15, workspace.Waypoint16, enemy9Settings, player)
local enemy10 = EnemyModule.new(workspace.Enemy10, workspace.Waypoint19, workspace.Waypoint20, enemy10Settings, player)
local enemy11 = EnemyModule.new(workspace.Enemy11, workspace.Waypoint21, workspace.Waypoint22, enemy11Settings, player)
local enemy12 = EnemyModule.new(workspace.Enemy12, workspace.Waypoint23, workspace.Waypoint24, enemy12Settings, player)
local enemy13 = EnemyModule.new(workspace.Enemy13, workspace.Waypoint25, workspace.Waypoint26, enemy13Settings, player)
local enemy14 = EnemyModule.new(workspace.Enemy14, workspace.Waypoint27, workspace.Waypoint28, enemy14Settings, player)
local enemy15 = EnemyModule.new(workspace.Enemy15, workspace.Waypoint29, workspace.Waypoint30, enemy15Settings, player)

table.insert(enemies, enemy1)
table.insert(enemies, enemy2)
table.insert(enemies, enemy3)
table.insert(enemies, enemy4)
table.insert(enemies, enemy5)
table.insert(enemies, enemy6)
table.insert(enemies, enemy7)
table.insert(enemies, enemy8)
table.insert(enemies, enemy9)
table.insert(enemies, enemy10)
table.insert(enemies, enemy11)
table.insert(enemies, enemy12)
table.insert(enemies, enemy13)
table.insert(enemies, enemy14)
table.insert(enemies, enemy15)

for _, enemy in ipairs(enemies) do
    task.spawn(function()
        enemy:Start()
    end)
end
