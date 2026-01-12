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
-- local StartCookingEvent = Remotes:WaitForChild("StartCookingEvent")
-- local CookingResultEvent = Remotes:WaitForChild("CookingResultEvent")
local InventoryUpdated = Remotes:WaitForChild("InventoryUpdated")
local FoodTools = ReplicatedStorage:WaitForChild("FoodTools")
local OpenStationUI = Remotes:WaitForChild("OpenStationUI")

local RecipeBook = require(ReplicatedStorage.Shared.Modules.Food:WaitForChild("RecipeBook"))


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

function gatherIngredients(player): { [string]: number }
	local recipeHold = player:FindFirstChild("RecipeHold")
	local inputtedIngredients = {}

	if not recipeHold then
		return inputtedIngredients
	end

	for _, item in ipairs(recipeHold:GetChildren()) do
		if item:IsA("Tool") then
			local itemName = item.Name:gsub("_slot$", "")
			inputtedIngredients[itemName] = (inputtedIngredients[itemName] or 0) + 1
			item:Destroy()
		end
	end

	return inputtedIngredients
end

-- Calculate normalized chances based on inputted ingredients
function calculateNormalizedChances(inputtedIngredients: { [string]: number }) --, craftmanshipGrade: string): { ChanceEntry } FOR LATER USE
	-- Create table of chances for every item in the RecipeBook
	local chancesTable = {}
	for recipeName, recipeData in pairs(RecipeBook) do
		local recipeIngredients = recipeData.Recipe
		local totalChance = 0

		-- Calculate chance based on ingredients
		for _, ingredient in ipairs(recipeIngredients) do
			if not inputtedIngredients[ingredient.Name] then
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

-- Handle cooking requests
RequestCook.OnServerEvent:Connect(function(player) -- , craftmanshipGrade) FOR LATER USE
	-- Gather ingredients
	local inputtedIngredients = gatherIngredients(player)

	-- Calculate normalized chances
	local normalizedChances = calculateNormalizedChances(inputtedIngredients)

	-- Select food based on normalized chances
	local roll = math.random()
	local cumulative = 0
	local food = nil

	for _, entry in ipairs(normalizedChances) do
		cumulative += entry.chance
		if roll <= cumulative then
			food = entry.item
			break
		end
	end

	-- Floating-point safety fallback
	if not food and #normalizedChances > 0 then
		food = normalizedChances[#normalizedChances].item
	end

	-- Select rarity of food based on RecipeBook rarity table for the item
	local rarityTable = normalizeChances(RecipeBook[food].Rarity)
	roll = math.random()
	cumulative = 0
	local createdFood = nil

	for _, entry in ipairs(rarityTable) do
		cumulative += entry.chance
		if roll <= cumulative then
			createdFood = entry.item
			break
		end
	end

	-- Floating-point safety fallback
	if not createdFood and #rarityTable > 0 then
		createdFood = rarityTable[#rarityTable].item
	end

	-- Fire cooking result back to client
	local foodType = FoodTools:FindFirstChild(food)
	local toolToGive = foodType:FindFirstChild(createdFood)
	if toolToGive then
		-- Give the player the cooked food item
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local clonedTool = toolToGive:Clone()
			clonedTool.Parent = backpack
		end
	end
end)
