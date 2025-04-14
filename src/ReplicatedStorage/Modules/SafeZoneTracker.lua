local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")
local NextLevelEvent = ReplicatedStorage:WaitForChild("NextLevel")
local playerSafeStatus = {}

SafeZoneEvent.OnServerEvent:Connect(function(player, isSafe)
    if playerSafeStatus[player] ~= isSafe then
        playerSafeStatus[player] = isSafe

        if isSafe then
            print(player.Name .. " completed the level!")
            NextLevelEvent:FireClient(player)
        end
    end
end)

local SafeZoneTracker = {}

SafeZoneTracker.SafeZoneEvent = SafeZoneEvent

function SafeZoneTracker.IsPlayerSafe(player)
    return playerSafeStatus[player] == true
end

return SafeZoneTracker
