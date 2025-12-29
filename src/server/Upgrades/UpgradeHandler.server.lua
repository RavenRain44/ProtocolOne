-- Rewrite the logic to make it skill based perchance?
-- ChatGPT Response: https://chatgpt.com/s/t_6952f581350c8191b445f6a14b9e30f6 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Example upgrade costs
local upgrades = {
	Speed = {Cost = 100, Bonus = 0.2}, -- +20% speed
	RareChance = {Cost = 150, Bonus = 2} -- +2% rare chance
}

local playerUpgrades = {}

Players.PlayerAdded:Connect(function(player)
	playerUpgrades[player.UserId] = {
		Speed = 0,
		RareChance = 0
	}
end)

local function purchaseUpgrade(player, upgradeName)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local cash = leaderstats:FindFirstChild("Cash")
	if not cash then return end

	local upgrade = upgrades[upgradeName]
	if cash.Value >= upgrade.Cost then
		cash.Value = cash.Value - upgrade.Cost
		playerUpgrades[player.UserId][upgradeName] = playerUpgrades[player.UserId][upgradeName] + upgrade.Bonus
		print(player.Name.." bought "..upgradeName.." upgrade!")
	else
		print("Not enough cash")
	end
end

-- Example usage:
-- purchaseUpgrade(player, "Speed")
-- later hook this to GUI buttons
