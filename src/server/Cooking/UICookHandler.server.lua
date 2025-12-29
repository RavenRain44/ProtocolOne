-- Maybe rewrite
-- ChatGPT Response: https://chatgpt.com/s/t_6952f4fe104881919f910d950c6952a4

-- UICookHandler (Script)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RecipeBook = ReplicatedStorage:WaitForChild("RecipeBook")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StartCookingEvent = Remotes:WaitForChild("StartCookingEvent")
local CookingResultEvent = Remotes:WaitForChild("CookingResultEvent")
local UICookRequest = Remotes:WaitForChild("UICookRequest")
local FoodGroupsFolder = ReplicatedStorage:WaitForChild("FoodGroups")
local stationsFolder = workspace:WaitForChild("ProductionStations")

-- Category base multipliers (if you want them)
local categoryBase = {
	Common = 1,
	Uncommon = 1,
	Rare = 1,
	Epic = 1,
	Legendary = 1
}

-- Cooking quality modifiers per rarity category
local cookModifiers = {
	Green = { Common = 0.7, Uncommon = 1.0, Rare = 1.2, Epic = 1.3, Legendary = 1.5 },
	Yellow = { Common = 1.0, Uncommon = 1.0, Rare = 1.0, Epic = 1.0, Legendary = 1.0 },
	Red = { Common = 1.5, Uncommon = 1.2, Rare = 0.6, Epic = 0.3, Legendary = 0.1 }
}

-- Helper: check player has required ingredients given a list (needs multiplicity)
local function playerHasIngredientsServer(player, required)
	local inventory = {}

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		for _, t in ipairs(backpack:GetChildren()) do
			if t:IsA("Tool") then
				inventory[t.Name] = (inventory[t.Name] or 0) + 1
			end
		end
	end

	local char = player.Character
	if char then
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") then
				inventory[t.Name] = (inventory[t.Name] or 0) + 1
			end
		end
	end

	-- required may contain duplicates; count them
	local neededCounts = {}
	for _, name in ipairs(required) do
		neededCounts[name] = (neededCounts[name] or 0) + 1
	end

	for name, count in pairs(neededCounts) do
		if (inventory[name] or 0) < count then
			return false
		end
	end
	return true
end

-- Helper: consume ingredients (destroy Tools, backpack first)
local function consumeIngredientsServer(player, required)
	local neededCounts = {}
	for _, name in ipairs(required) do
		neededCounts[name] = (neededCounts[name] or 0) + 1
	end

	-- remove from backpack first
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		for name, count in pairs(neededCounts) do
			while count > 0 do
				local tool = backpack:FindFirstChild(name)
				if not tool then break end
				tool:Destroy()
				count = count - 1
				neededCounts[name] = count
			end
		end
	end

	-- then character
	local char = player.Character
	if char then
		for name, count in pairs(neededCounts) do
			while count > 0 do
				local tool = char:FindFirstChild(name)
				if not tool then break end
				tool:Destroy()
				count = count - 1
				neededCounts[name] = count
			end
		end
	end
end

-- Choose food from group using rarity weights * categoryBase * cookModifier
local function chooseFoodFromGroup(groupFolder, rarityAdjustments)
	local weighted = {}
	for _, rarityFolder in ipairs(groupFolder:GetChildren()) do
		local categoryName = rarityFolder.Name
		local categoryMult = (categoryBase[categoryName] or 1) * (rarityAdjustments[categoryName] or 1)
		for _, food in ipairs(rarityFolder:GetChildren()) do
			local r = food:FindFirstChild("Rarity")
			if r and type(r.Value) == "number" then
				local finalWeight = math.max(1, math.floor(r.Value * categoryMult))
				for i = 1, finalWeight do
					table.insert(weighted, food)
				end
			end
		end
	end
	if #weighted == 0 then return nil end
	return weighted[math.random(#weighted)]
end

-- Server handler for UICookRequest
UICookRequest.OnServerEvent:Connect(function(player, stationName, selectedItems)
	-- Validate station exists
	local station = stationsFolder:FindFirstChild(stationName)
	if not station then
		warn("UICookRequest: station not found:", stationName)
		return
	end

	-- Validate recipe list for station
	local machineRecipes = RecipeBook[stationName]
	if not machineRecipes then
		warn("UICookRequest: no recipes for station:", stationName)
		return
	end

	-- Check whether selectedItems match any recipe in machineRecipes
	-- (Allow duplicates; we require exact multiset == recipe.Ingredients multiset)
	local function itemsMatchRecipe(itemsList, recipeIngredients)
		local need = {}
		for _, nm in ipairs(recipeIngredients) do need[nm] = (need[nm] or 0) + 1 end
		local have = {}
		for _, nm in ipairs(itemsList) do have[nm] = (have[nm] or 0) + 1 end
		-- Every required must be present at least as many
		for reqName, reqCount in pairs(need) do
			if (have[reqName] or 0) < reqCount then return false end
		end
		-- It's OK if have has extra items (user may have extra); we only require recipe satisfied
		return true
	end

	local chosenRecipe = nil
	for _, recipe in ipairs(machineRecipes) do
		if itemsMatchRecipe(selectedItems, recipe.Ingredients) then
			-- additionally verify server-side player actually has the required Tools
			if playerHasIngredientsServer(player, recipe.Ingredients) then
				chosenRecipe = recipe
				break
			end
		end
	end

	if not chosenRecipe then
		-- no valid recipe or player lacks ingredients
		-- you could fire a client message here to notify the player
		warn("UICookRequest: no valid recipe or missing ingredients for player", player.Name)
		return
	end

	-- Consume ingredients now (server-side)
	consumeIngredientsServer(player, chosenRecipe.Ingredients)

	-- Start the cooking minigame on the client
	StartCookingEvent:FireClient(player)

	-- wait for the client's result (one-shot)
	local cookResult
	local conn
	conn = CookingResultEvent.OnServerEvent:Connect(function(plr, result)
		if plr == player then
			cookResult = result
			conn:Disconnect()
		end
	end)

	repeat task.wait() until cookResult ~= nil

	-- cookResult is expected to be "Green"/"Yellow"/"Red"
	local modifiers = cookModifiers[cookResult] or cookModifiers.Yellow

	-- spawn output: pick folder and then item based on modifiers
	local groupFolder = FoodGroupsFolder:FindFirstChild(chosenRecipe.OutputGroup)
	if not groupFolder then
		warn("UICookRequest: output group missing:", chosenRecipe.OutputGroup)
		return
	end

	local selectedFood = chooseFoodFromGroup(groupFolder, modifiers)
	if not selectedFood then
		warn("UICookRequest: no food chosen")
		return
	end

	-- Spawn the tool in the world at station.SpawnPoint
	local spawnPoint = station:FindFirstChild("SpawnPoint")
	local clone = selectedFood:Clone()
	clone.Parent = workspace
	if clone:FindFirstChild("Handle") and spawnPoint and spawnPoint:IsA("BasePart") then
		clone.Handle.CFrame = spawnPoint.CFrame
	end

	-- Enable its proximity prompt (if it has one)
	local prox = clone:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prox then
		prox.Enabled = true
	end

end)
