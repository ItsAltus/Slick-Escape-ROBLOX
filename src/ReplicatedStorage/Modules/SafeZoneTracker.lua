local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")
local playerSafeStatus = {}

SafeZoneEvent.OnServerEvent:Connect(function(player, isSafe)
    playerSafeStatus[player] = isSafe
end)

local SafeZoneTracker = {}

SafeZoneTracker.SafeZoneEvent = SafeZoneEvent

function SafeZoneTracker.IsPlayerSafe(player)
    return playerSafeStatus[player] == true
end

return SafeZoneTracker
