local Players = game:GetService("Players")
local PlayerUtils = {}

function PlayerUtils.getPlayer()
    if Players.LocalPlayer then
        return Players.LocalPlayer
    else
        local players = Players:GetPlayers()
        if #players > 0 then
            return players[1]
        else
            return Players.PlayerAdded:Wait()
        end
    end
end

function PlayerUtils.getCharacter()
    local player = PlayerUtils.getPlayer()
    if not player then
        return nil
    end
    return player.Character or player.CharacterAdded:Wait()
end

function PlayerUtils.getHRP()
    local character = PlayerUtils.getCharacter()
    return character:WaitForChild("HumanoidRootPart")
end

return PlayerUtils
