local PlayerUtils = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("PlayerUtils"))
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeZoneEvent = ReplicatedStorage:WaitForChild("SafeZoneEvent")

local safeZonesFolder = workspace:WaitForChild("SafeZones")

local isInSafeZone = false

local function isPointInsidePart(point, part)
    local relative = part.CFrame:PointToObjectSpace(point)
    local halfSize = part.Size / 2
    return math.abs(relative.X) <= halfSize.X and
           math.abs(relative.Y) <= halfSize.Y and
           math.abs(relative.Z) <= halfSize.Z
end

local function checkSafeZone()
    local hrp = PlayerUtils.getHRP()
    for _, zone in pairs(safeZonesFolder:GetChildren()) do
        if zone:IsA("BasePart") then
            if isPointInsidePart(hrp.Position, zone) then
                return true
            end
        end
    end
    return false
end

RunService.RenderStepped:Connect(function()
    local hrp = PlayerUtils.getHRP()
    if hrp and hrp.Parent then
        isInSafeZone = checkSafeZone()
        SafeZoneEvent:FireServer(isInSafeZone)
    end
end)
