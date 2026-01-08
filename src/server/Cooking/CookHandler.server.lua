----------------
-- DEPRECATED --
----------------
--
-- REWRITE THIS FILE --
-- Check with ChatGPT for how it can be implemented.
--
-- ChatGPT Response: https://chatgpt.com/s/t_6952ed1fde288191a885b26f7a8187a6

-- CookHandlerServer.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestCook = Remotes:WaitForChild("RequestCook")
local StartCookingEvent = Remotes:WaitForChild("StartCookingEvent")
local CookingResultEvent = Remotes:WaitForChild("CookingResultEvent")
local InventoryUpdated = Remotes:WaitForChild("InventoryUpdated")
local FoodTools = ReplicatedStorage:WaitForChild("FoodTools")

local RecipeBook = require(ReplicatedStorage.Shared.Modules.Food:WaitForChild("RecipeBook"))
local FoodGroups = ReplicatedStorage:WaitForChild("FoodGroups")
local stationsFolder = workspace:WaitForChild("ProductionStations")


type ChanceEntry = {
	item: string,
	chance: number,
}

-- Calculate normalized Gaussian curve value
function calcNormCurve(inputtedAmount, actualAmount: number, weight: number)
	return weight * math.exp(1) ^ (-((inputtedAmount - actualAmount) ^ 2) / (2 * (1 ^ 2)))
end

-- Normalize chances table into array of ChanceEntry
function normalizeChances(chancesTable: { [string]: number }): { ChanceEntry }
	local total = 0

	-- Sum all chances
	for _, chance in pairs(chancesTable) do
		total += chance
	end

	assert(total > 0, "Chance table total must be > 0")

	-- Build ordered array
	local normalized: { ChanceEntry } = {}

	for item, chance in pairs(chancesTable) do
		table.insert(normalized, {
			item = item,
			chance = chance / total,
		})
	end

	return normalized
end

function calculateNormalizedChances(inputtedIngredients: { [string]: number }, craftmanshipGrade: string): { ChanceEntry }
	-- Create table of chances for every item in the RecipeBook
	local chancesTable = {}
	for recipeName, recipeData in pairs(RecipeBook) do
		local recipeIngredients = recipeData.Recipe
		local totalChance = 0

		-- Calculate chance based on ingredients
		for _, ingredient in ipairs(recipeIngredients) do
			if not inputtedIngredients[ingredient.Name] then
				totalChance = 0
				continue
			end
			local inputtedAmount = inputtedIngredients[ingredient.Name] or 0
			local ingredientChance = calcNormCurve(inputtedAmount, ingredient.Amount, ingredient.Weight)
			totalChance = totalChance + ingredientChance
		end

		-- Void if totalChance is zero
		if totalChance == 0 then
			continue
		end

		chancesTable[recipeName] = totalChance
	end

	-- Normalize chances
	assert(next(chancesTable) ~= nil, "No valid recipes matched input ingredients")

	return normalizeChances(chancesTable)
end

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

-- default cook modifiers (you already suggested)
local cookModifiers = {
	Green = { Common = 0.7, Uncommon = 1.0, Rare = 1.2, Epic = 1.3, Legendary = 1.5 },
	Yellow = { Common = 1.0, Uncommon = 1.0, Rare = 1.0, Epic = 1.0, Legendary = 1.0 },
	Red = { Common = 1.5, Uncommon = 1.2, Rare = 0.6, Epic = 0.3, Legendary = 0.1 },
}

-- Handle cooking requests
RequestCook.OnServerEvent:Connect(function(player, craftmanshipGrade)
	local recipeHold = player:FindFirstChild("RecipeHold")
	if not recipeHold then
		return
	end

	-- Gather ingredients
	local inputtedIngredients = {}
	for _, item in ipairs(recipeHold:GetChildren()) do
		if item:IsA("Tool") then
			local itemName = item.Name:gsub("_slot$", "")
			inputtedIngredients[itemName] = (inputtedIngredients[itemName] or 0) + 1

			-- Remove ingredient from RecipeHold and UI
			item:Destroy()
			sendInventoryState(player)
		end
	end

	normalizedChances = calculateNormalizedChances(inputtedIngredients, craftmanshipGrade)

	-- Select food based on normalized chances
	local roll = math.random()
	local cumulative = 0
	local createdFood = nil

	for _, entry in ipairs(normalizedChances) do
		cumulative += entry.chance
		if roll <= cumulative then
			createdFood = entry.item
			break
		end
	end

	-- Floating-point safety fallback
	if not createdFood and #normalizedChances > 0 then
		createdFood = normalizedChances[#normalizedChances].item
	end

	-- Fire cooking result back to client
	local toolToGive = FoodTools:FindFirstChild(createdFood)
	if toolToGive then
		-- Give the player the cooked food item
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local clonedTool = toolToGive:Clone()
			clonedTool.Parent = backpack
		end
	end
end)
