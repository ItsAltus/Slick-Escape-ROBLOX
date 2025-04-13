local launchBricksFolder = workspace:WaitForChild("LaunchBricks")

for _, part in ipairs(launchBricksFolder:GetChildren()) do
	if part:IsA("BasePart") then
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local hrp = character:FindFirstChild("HumanoidRootPart")

			if humanoid and hrp then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = hrp.CFrame.LookVector * 55
				bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
				bodyVelocity.Parent = hrp

				task.delay(0.5, function()
					bodyVelocity:Destroy()
				end)
			end
		end)
	end
end
