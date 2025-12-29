----------------
-- DEPRECATED --
----------------
--
-- REWRITE THIS FILE --
-- Check with ChatGPT for how it can be implemented.
--
-- ChatGPT Response: https://chatgpt.com/s/t_6952ed1fde288191a885b26f7a8187a6

-- RecipeInventoryServer.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ToggleIngredient = Remotes:WaitForChild("ToggleIngredient")
local InventoryUpdated = Remotes:WaitForChild("InventoryUpdated")

-- helper to send current state to player
local function sendInventoryState(player)
	local backpack = player:FindFirstChild("Backpack")
	local hold = player:FindFirstChild("RecipeHold")
	local left = {}
	local right = {}

	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(left, tool.Name)
			end
		end
	end

	if hold then
		for _, tool in ipairs(hold:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(right, tool.Name)
			end
		end
	end

	InventoryUpdated:FireClient(player, left, right)
end

Players.PlayerAdded:Connect(function(player)
	-- create RecipeHold folder
	local hold = Instance.new("Folder")
	hold.Name = "RecipeHold"
	hold.Parent = player

	-- small initial state send after spawn
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		sendInventoryState(player)
	end)
end)

ToggleIngredient.OnServerEvent:Connect(function(player, toolName, side)
	if not toolName or type(toolName) ~= "string" then 
		return 
	end
	local backpack = player:FindFirstChild("Backpack")
	local hold = player:FindFirstChild("RecipeHold")

	if not backpack or not hold then 
		return 
	end

	-- if tool is in the left side (backpack), move to hold
	if side == "TemplateLeft" then
		-- Verify the amount is less than 6, break if it isn't
		local count = 0
		for _, item in ipairs(hold:GetChildren()) do
			if item.Name == toolName then
				count += 1
			end
		end
		if count == 6 then
			return
		end
		
		local tool = backpack:FindFirstChild(toolName)
		if tool and tool:IsA("Tool") then
			tool.Parent = hold
			-- disable handle prompt while held server-side if exists
			local handle = tool:FindFirstChild("Handle")
			if handle then
				local prox = handle:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prox then prox.Enabled = false end
			end
			sendInventoryState(player)
			return
		end
	end

	-- if tool in the right side (hold), move back to backpack
	if side == "TemplateRight" then
		local tool2 = hold:FindFirstChild(toolName)
		if tool2 and tool2:IsA("Tool") then
			tool2.Parent = backpack
			local handle = tool2:FindFirstChild("Handle")
			if handle then
				local prox = handle:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prox then prox.Enabled = true end
			end
			sendInventoryState(player)
			return
		end
	end
end)
