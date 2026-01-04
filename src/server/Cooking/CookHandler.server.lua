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

local RecipeBook = ReplicatedStorage:WaitForChild("RecipeBook")
local FoodGroups = ReplicatedStorage:WaitForChild("FoodGroups")
local stationsFolder = workspace:WaitForChild("ProductionStations")

-- chooseFoodFromGroup simplified (uses rarity NumberValue)
local function chooseFoodFromGroup(groupFolder, rarityMultiplierPerGroup)
	local weighted = {}
	-- rarityMultiplierPerGroup is table mapping rarity folder name -> multiplier
	for _, rarityFolder in ipairs(groupFolder:GetChildren()) do
		local rarityName = rarityFolder.Name
		local mult = (rarityMultiplierPerGroup and rarityMultiplierPerGroup[rarityName]) or 1
		for _, food in ipairs(rarityFolder:GetChildren()) do
			local rv = food:FindFirstChild("Rarity")
			if rv and type(rv.Value) == "number" then
				local finalWeight = math.max(1, math.floor(rv.Value * mult))
				for _ = 1, finalWeight do
					table.insert(weighted, food)
				end
			end
		end
	end
	if #weighted == 0 then
		return nil
	end
	return weighted[math.random(#weighted)]
end

-- default cook modifiers (you already suggested)
local cookModifiers = {
	Green = { Common = 0.7, Uncommon = 1.0, Rare = 1.2, Epic = 1.3, Legendary = 1.5 },
	Yellow = { Common = 1.0, Uncommon = 1.0, Rare = 1.0, Epic = 1.0, Legendary = 1.0 },
	Red = { Common = 1.5, Uncommon = 1.2, Rare = 0.6, Epic = 0.3, Legendary = 0.1 },
}

-- RequestCook: args: stationName (string)
RequestCook.OnServerEvent:Connect(function(player, stationName)
	if type(stationName) ~= "string" then
		return
	end
	local machineRecipes = RecipeBook[stationName]
	if not machineRecipes then
		Remotes.InventoryUpdated:FireClient(player, {}, {}) -- keep client sync
		return
	end

	local hold = player:FindFirstChild("RecipeHold")
	if not hold then
		return
	end

	-- Build list of names in hold
	local inHold = {}
	for _, tool in ipairs(hold:GetChildren()) do
		if tool:IsA("Tool") then
			table.insert(inHold, tool.Name)
		end
	end

	-- find a recipe that matches exactly (all ingredients present)
	local chosenRecipe = nil
	for _, recipe in ipairs(machineRecipes) do
		local ok = true
		-- duplicates allowed (player wanted duplicates ok)
		local counts = {}
		for _, name in ipairs(inHold) do
			counts[name] = (counts[name] or 0) + 1
		end
		for _, need in ipairs(recipe.Ingredients) do
			if not counts[need] or counts[need] <= 0 then
				ok = false
				break
			end
			counts[need] = counts[need] - 1
		end
		if ok then
			chosenRecipe = recipe
			break
		end
	end

	if not chosenRecipe then
		-- no recipe — notify client so they can show message (we use InventoryUpdated to keep it simple)
		InventoryUpdated:FireClient(player, nil, nil, "NO_RECIPE")
		return
	end

	-- consume the tools in hold (destroy them)
	local needed = {}
	for _, v in ipairs(chosenRecipe.Ingredients) do
		needed[v] = (needed[v] or 0) + 1
	end
	for name, count in pairs(needed) do
		for _ = 1, count do
			local tool = hold:FindFirstChild(name)
			if tool and tool:IsA("Tool") then
				tool:Destroy()
			end
		end
	end

	-- start minigame
	StartCookingEvent:FireClient(player)

	-- wait for result from this player
	local result
	local conn
	conn = CookingResultEvent.OnServerEvent:Connect(function(plr, r)
		if plr == player then
			result = r
			conn:Disconnect()
		end
	end)

	-- wait until result is set (with timeout)
	local maxWait = 30
	local timer = 0
	while not result and timer < maxWait do
		task.wait(0.1)
		timer = timer + 0.1
	end
	if not result then
		-- no result — abort (optionally give back ingredients)
		InventoryUpdated:FireClient(player, nil, nil, "TIMEOUT")
		return
	end

	-- compute rarity multipliers per rarity folder
	local mod = cookModifiers[result] or cookModifiers.Yellow
	-- choose food from this recipe's OutputGroup
	local groupFolder = FoodGroups:FindFirstChild(chosenRecipe.OutputGroup)
	if not groupFolder then
		warn("Missing group for recipe:", chosenRecipe.OutputGroup)
		return
	end

	local selectedFood = chooseFoodFromGroup(groupFolder, mod)
	if not selectedFood then
		warn("No food chosen after selection")
		return
	end

	-- spawn the tool in world at the station spawn point (if exists)
	local station = stationsFolder:FindFirstChild(stationName)
	local spawnPoint = station and station:FindFirstChild("SpawnPoint")
	local clone = selectedFood:Clone()
	clone.Parent = workspace
	if spawnPoint and clone:FindFirstChild("Handle") then
		clone.Handle.CFrame = spawnPoint.CFrame
	end

	-- ensure its handle prompt is enabled so player can pick it up
	local handle = clone:FindFirstChild("Handle")
	if handle then
		local prox = handle:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prox then
			prox.Enabled = true
		end
	end

	-- notify client to refresh inventory state (backpack changed)
	InventoryUpdated:FireClient(player)
end)
