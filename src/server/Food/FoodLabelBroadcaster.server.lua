----------------
-- DEPRECATED --
----------------
--
-- REWRITE THIS FILE --
-- The logic for the remote event must be remade. Check with ChatGPT for how it can be implemented.
--
-- ChatGPT Response: https://chatgpt.com/s/t_6952eb6d6f3c8191b74414beeb440d25 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local FoodGroups = ReplicatedStorage:WaitForChild("FoodGroups")

local LabelEvent = Instance.new("RemoteEvent")
LabelEvent.Name = "FoodLabelEvent"
LabelEvent.Parent = ReplicatedStorage

-- Checks if object is a food tool
local function getFoodData(tool)
	if not tool:IsA("Tool") then return end
	local rarityValue = tool:FindFirstChild("Rarity")
	if not rarityValue then return end

	-- Detect Rarity Class based on its parent folder inside FoodGroups
	local rarityClass
	for _, group in pairs(FoodGroups:GetChildren()) do
		for _, rarityFolder in pairs(group:GetChildren()) do
			if rarityFolder:FindFirstChild(tool.Name) then
				rarityClass = rarityFolder.Name
			end
		end
	end

	if not rarityClass then return end

	return {
		tool = tool,
		rarityClass = rarityClass,
		rarityValue = rarityValue.Value,
		name = tool.Name
	}
end

-- Fires event when food appears anywhere
local function scanItem(tool)
	local data = getFoodData(tool)
	if data then
		LabelEvent:FireAllClients(data)
	end
end

-- Watch workspace + player backpacks
workspace.DescendantAdded:Connect(scanItem)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		char.DescendantAdded:Connect(scanItem)
	end)

	player.Backpack.DescendantAdded:Connect(scanItem)
end)

