local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LabelEvent = ReplicatedStorage:WaitForChild("FoodLabelEvent")
local Template = ReplicatedStorage:WaitForChild("BillboardGuiTemplates"):WaitForChild("FoodLabel")

local rarityColors = {
	Common = Color3.fromRGB(200, 200, 200),
	Uncommon = Color3.fromRGB(80, 255, 80),
	Rare = Color3.fromRGB(80, 150, 255),
	Epic = Color3.fromRGB(180, 80, 255),
	Legendary = Color3.fromRGB(255, 170, 0)
}

LabelEvent.OnClientEvent:Connect(function(data)
	local tool = data.tool
	if not tool or not tool:FindFirstChild("Handle") then return end

	-- prevent duplicates
	if tool:FindFirstChild("FoodLabel_GUI") then return end

	local gui = Template:Clone()
	gui.Name = "FoodLabel_GUI"
	gui.Parent = tool.Handle

	gui.Title.Text = data.rarityClass
	gui.Value.Text = "RARITY: " .. data.rarityValue
	gui.NameLabel.Text = data.name  -- if you name the textlabel NameLabel

	-- color based on rarity
	local col = rarityColors[data.rarityClass] or Color3.new(1,1,1)
	gui.Title.TextColor3 = col
	--gui.Value.TextColor3 = col
	--gui.NameLabel.TextColor3 = col
end)
