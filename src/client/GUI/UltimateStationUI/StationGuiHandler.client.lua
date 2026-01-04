-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer

-- REMOTES
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryUpdated = Remotes:WaitForChild("InventoryUpdated")
local ToggleIngredient = Remotes:WaitForChild("ToggleIngredient")
local RequestCook = Remotes:WaitForChild("RequestCook")

-- UI REFERENCES
local screen = player.PlayerGui:WaitForChild("StationGUI")
local background = screen:WaitForChild("Background")

local invFrame = background:WaitForChild("Inventory")
local invTemplate = invFrame:WaitForChild("TemplateLeft")

local recipeFrame = background:WaitForChild("Recipes")
local recipeTemplate = recipeFrame:WaitForChild("TemplateRight")

local cookBtn = background.Frame:WaitForChild("Cook")
local exitBtn = background:WaitForChild("ExitButton")

local hotbar = player.PlayerGui:WaitForChild("Custom Inventory")
local hotbarFrame = hotbar:WaitForChild("hotBar")

screen.Enabled = false

----------------------------------------------------------------
-- UTIL
----------------------------------------------------------------
local function clearSlots(parent, template)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Frame") and child ~= template then
			child:Destroy()
		end
	end
end

----------------------------------------------------------------
-- SLOT CREATION
----------------------------------------------------------------
local function createSlot(parent, template, itemName, itemNumber)
	if not itemName then
		return
	end

	local slot = template:Clone()
	slot.Visible = true
	slot.Parent = parent
	slot.Name = itemName .. "_slot"

	local side = template.Name

	-- Text Button
	local foodNameLabel = slot:FindFirstChild("FoodName")
	if not foodNameLabel then
		warn("Slot missing FoodName:", slot:GetFullName())
		return
	end
	foodNameLabel.Text = itemName
	foodNameLabel.Active = true
	foodNameLabel.ZIndex = 10

	-- Number
	local numberCount = foodNameLabel:FindFirstChild("NumberCount")
	if numberCount ~= nil then
		numberCount.Text = tostring(itemNumber)
	else
		warn("Slot " .. slot.Name .. "does not have a NumberCount field")
	end

	foodNameLabel.MouseButton1Click:Connect(function()
		print("[StationsLocal] Clicked on:", itemName, "on side", side)
		ToggleIngredient:FireServer(itemName, side)

		-- Part instantiation
		if side == "TemplateLeft" then
			local ingredient = ReplicatedStorage.FoodGroups.StartingIngredients:FindFirstChild(itemName)
			local part = ingredient.Handle:Clone()
			part.Parent = workspace.ProductionStations.UltimateStation.IngredientParts
			part.Anchored = false
			part.position = workspace.ProductionStations.UltimateStation.SpawnPoint.Position
			part.CanCollide = true
		elseif side == "TemplateRight" then
			local part = workspace.ProductionStations.UltimateStation.IngredientParts:FindFirstChild(itemName)
			part:Destroy()
		end
	end)
end

----------------------------------------------------------------
-- SERVER → CLIENT FULL STATE UPDATE
----------------------------------------------------------------
InventoryUpdated.OnClientEvent:Connect(function(leftTools, rightTools)
	clearSlots(invFrame, invTemplate)
	clearSlots(recipeFrame, recipeTemplate)

	-- LEFT (inventory)
	local inventoryMap = {}
	for _, itemName in ipairs(leftTools or {}) do
		inventoryMap[itemName] = (inventoryMap[itemName] or 0) + 1
	end
	for item, number in inventoryMap do
		createSlot(invFrame, invTemplate, item, number)
	end

	-- RIGHT (selected ingredients)
	local recipeMap = {}
	for _, itemName in ipairs(rightTools or {}) do
		recipeMap[itemName] = (recipeMap[itemName] or 0) + 1
	end
	for item, number in recipeMap do
		createSlot(recipeFrame, recipeTemplate, item, number)
	end
end)

----------------------------------------------------------------
-- OPEN UI
----------------------------------------------------------------
ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)
	if triggeringPlayer ~= player then
		return
	end

	if prompt.Name == "StationPrompt" then
		screen.Enabled = true
		hotbarFrame.Visible = false
	end
end)

----------------------------------------------------------------
-- CLOSE UI
----------------------------------------------------------------
function close()
	screen.Enabled = false
	hotbarFrame.Visible = true
end

----------------------------------------------------------------
-- COOK
----------------------------------------------------------------
cookBtn.MouseButton1Click:Connect(function()
	RequestCook:FireServer()
	close()
end)

----------------------------------------------------------------
-- EXIT
----------------------------------------------------------------
exitBtn.MouseButton1Click:Connect(function()
	close()
end)
