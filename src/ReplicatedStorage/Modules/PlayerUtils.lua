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
    local player = PlayerUtils.getPlayer()
    local character = player.Character
    if not character then return nil end

    if character:IsDescendantOf(workspace:FindFirstChild("DeadBodies")) then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

return PlayerUtils
