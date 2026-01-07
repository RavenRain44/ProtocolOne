-- This is the "production" script
-- Rewrite this; ChatGPT Response: https://chatgpt.com/s/t_6952f69055448191af390f61cfdcd00c

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FoodGroupsFolder = ReplicatedStorage:WaitForChild("FoodGroups")
local RecipeBook = ReplicatedStorage.Shared.Modules.Food:WaitForChild("RecipeBook")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StartCookingEvent = Remotes:WaitForChild("StartCookingEvent")
local CookingResultEvent = Remotes:WaitForChild("CookingResultEvent")

local stationsFolder = workspace:WaitForChild("ProductionStations")

---------------------------------------------------------------------
-- COOKING QUALITY MODIFIERS (multiplies the food's own rarity value)
---------------------------------------------------------------------
local CookModifiers = {
	Green = {
		Common = 0.7,
		Uncommon = 1.0,
		Rare = 1.2,
		Epic = 1.3,
		Legendary = 1.5,
	},
	Yellow = {
		Common = 1,
		Uncommon = 1,
		Rare = 1,
		Epic = 1,
		Legendary = 1,
	},
	Red = {
		Common = 1.5,
		Uncommon = 1.2,
		Rare = 0.6,
		Epic = 0.3,
		Legendary = 0.1,
	},
}

---------------------------------------------------------------------
-- Weighted random using: Food.Rarity.Value * CookModifier[its rarity]
---------------------------------------------------------------------
local function chooseModifiedFood(groupFolder, cookResult)
	local weightedList = {}
	local mod = CookModifiers[cookResult]

	for _, rarityFolder in ipairs(groupFolder:GetChildren()) do
		local rarityName = rarityFolder.Name
		local rarityBoost = mod[rarityName] or 1

		for _, food in ipairs(rarityFolder:GetChildren()) do
			local rarityValue = food:FindFirstChild("Rarity")

			if rarityValue then
				local finalWeight = math.max(1, math.floor(rarityValue.Value * rarityBoost))

				-- DEBUG PRINT
				--print(food.Name,
				--"Base:", rarityValue.Value,
				--"x Modifier:", rarityBoost,
				--"=", finalWeight)

				for _ = 1, finalWeight do
					table.insert(weightedList, food)
				end
			end
		end
	end

	if #weightedList == 0 then
		return nil
	end
	return weightedList[math.random(#weightedList)]
end

---------------------------------------------------------------------
-- INGREDIENT CHECK
---------------------------------------------------------------------
local function playerHasIngredients(player, required)
	local backpack = player:WaitForChild("Backpack")
	local character = player.Character
	local names = {}

	for _, tool in ipairs(backpack:GetChildren()) do
		names[tool.Name] = true
	end
	if character then
		for _, tool in ipairs(character:GetChildren()) do
			if tool:IsA("Tool") then
				names[tool.Name] = true
			end
		end
	end

	for _, r in ipairs(required) do
		if not names[r] then
			return false
		end
	end

	return true
end

---------------------------------------------------------------------
-- INGREDIENT CONSUMPTION
---------------------------------------------------------------------
local function consumeIngredients(player, requiredIngredients)
	local backpack = player:WaitForChild("Backpack")
	local character = player.Character

	for _, name in ipairs(requiredIngredients) do
		local tool = backpack:FindFirstChild(name)
		if tool then
			tool:Destroy()
			continue
		end
		if character then
			local tool2 = character:FindFirstChild(name)
			if tool2 then
				tool2:Destroy()
			end
		end
	end
end

---------------------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------------------
for _, station in ipairs(stationsFolder:GetChildren()) do
	local prompt = station:FindFirstChild("Prompt")
	local spawnPoint = station:FindFirstChild("SpawnPoint")

	if not prompt or not spawnPoint then
		warn("Missing station parts:", station.Name)
		continue
	end

	local machineRecipes = RecipeBook[station.Name]

	prompt.Triggered:Connect(function(player)
		if not machineRecipes then
			return
		end

		-- Find first recipe player can make
		local recipe = nil
		for _, r in ipairs(machineRecipes) do
			if playerHasIngredients(player, r.Ingredients) then
				recipe = r
				break
			end
		end
		if not recipe then
			warn("Player missing ingredients")
			return
		end

		-----------------------------------------------------------------
		-- Start client minigame
		-----------------------------------------------------------------
		StartCookingEvent:FireClient(player)

		-- Wait for result
		local cookResult = nil
		local conn
		conn = CookingResultEvent.OnServerEvent:Connect(function(plr, result)
			if plr == player then
				cookResult = result
			end
		end)
		repeat
			task.wait()
		until cookResult
		conn:Disconnect()

		--print("Cook Result:", cookResult)

		-----------------------------------------------------------------
		-- Remove ingredients
		-----------------------------------------------------------------
		consumeIngredients(player, recipe.Ingredients)

		-----------------------------------------------------------------
		-- Pick food using rarity * cook modifier
		-----------------------------------------------------------------
		local groupFolder = FoodGroupsFolder:FindFirstChild(recipe.OutputGroup)
		if not groupFolder then
			return
		end

		local chosenFood = chooseModifiedFood(groupFolder, cookResult)
		if not chosenFood then
			return
		end

		--print("FINAL PICKED FOOD:", chosenFood.Name)

		-----------------------------------------------------------------
		-- Spawn food
		-----------------------------------------------------------------
		local clone = chosenFood:Clone()
		clone.Parent = workspace
		clone.Handle.CFrame = spawnPoint.CFrame

		-- Pickup
		local prox = clone.Handle:FindFirstChildWhichIsA("ProximityPrompt")
		if prox then
			prox.Enabled = true
			prox.Triggered:Connect(function(plr)
				clone.Parent = plr.Backpack
				prox.Enabled = false
			end)
		end
	end)
end
