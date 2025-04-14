-- ============================================================
-- Script Name: LaunchBrick.server.lua
-- Project: Slick Escape
-- Author: DrChicken2424
-- Description: Applies a BodyVelocity to player's character when they touch
--              a launch brick, then removes the velocity after a delay.
-- ============================================================

---------------------------------------------------------------
-- VARIABLES & SERVICES
---------------------------------------------------------------
local launchBricksFolder = workspace:WaitForChild("LaunchBricks")

---------------------------------------------------------------
-- EVENT CONNECTIONS & LOGIC
---------------------------------------------------------------
for _, part in ipairs(launchBricksFolder:GetChildren()) do
	if part:IsA("BasePart") then
		-- Connect Touched event for each BasePart in the folder
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local hrp = character:FindFirstChild("HumanoidRootPart")

			if humanoid and hrp then
				-- Create and configure BodyVelocity to launch the character
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = hrp.CFrame.LookVector * 55  -- Launch in the facing direction
				bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
				bodyVelocity.Parent = hrp

				-- Remove the BodyVelocity after a delay to stop the launch effect
				task.delay(0.5, function()
					bodyVelocity:Destroy()
				end)
			end
		end)
	end
end
