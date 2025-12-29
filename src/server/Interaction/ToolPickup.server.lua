----------------
-- DEPRECATED --
----------------
--
-- REWRITE THIS FILE --
-- Check with ChatGPT for how it can be implemented.
--
-- ChatGPT Response: https://chatgpt.com/s/t_6952eda94b9881918d0930d9dd7c30d7

local Players = game:GetService("Players")

workspace.ChildAdded:Connect(function(obj)
	if not obj:IsA("Tool") then return end

	local handle = obj:FindFirstChild("Handle")
	if not handle then return end

	local prompt = handle:FindFirstChildWhichIsA("ProximityPrompt")
	if not prompt then return end

	-- 🔹 Pickup logic
	prompt.Triggered:Connect(function(player)
		if player and player:FindFirstChild("Backpack") then
			obj.Parent = player.Backpack
		end
	end)

	-- 🔹 Hide prompt while equipped
	obj.Equipped:Connect(function()
		prompt.Enabled = false
	end)

	obj.Unequipped:Connect(function()
		prompt.Enabled = true
	end)
end)
