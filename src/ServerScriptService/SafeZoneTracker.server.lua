local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")

-- Track which players are in safe zones
local playerSafeStatus = {}

SafeZoneEvent.OnServerEvent:Connect(function(player, isSafe)
    playerSafeStatus[player] = isSafe
end)

-- Global access for other scripts
_G.IsPlayerSafe = function(player)
    return playerSafeStatus[player] == true
end
