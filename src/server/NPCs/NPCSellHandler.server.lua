-- Check if this should be rewritten
-- ChatGPT Response: https://chatgpt.com/s/t_6952f27f67308191bcdacaca678653e1

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SellPointsFolder = workspace:WaitForChild("SellPoints")
local ToolTracker = game.ServerScriptService:WaitForChild("ToolTracker")

-- MODULE (do not rename anymore)
local NPCSellRules = ReplicatedStorage:WaitForChild("NPCSellRules")

--print("DEBUG: NPCSellRules loaded:", NPCSellRules)

-- Loop through ALL descendants looking for ProximityPrompts
for _, descendant in ipairs(SellPointsFolder:GetDescendants()) do
	if descendant:IsA("ProximityPrompt") then
		local prompt = descendant
		local npc = prompt.Parent
		local npcName = npc.Name

		--print("DEBUG: Found NPC:", npcName)

		prompt.Triggered:Connect(function(player)
			--print("\n========== SELL TRIGGERED ==========")
			--print("DEBUG: Player triggered:", player.Name)
			--print("DEBUG: NPC triggered:", npcName)

			local allowedFoods = NPCSellRules[npcName]
			if not allowedFoods then
				warn("DEBUG: No sell rules for NPC:", npcName)
				return
			end

			-- Check tracked tool
			local tool = ToolTracker[player]
			if not tool then
				warn("DEBUG: Player has no tracked tool")
				return
			end

			--print("DEBUG: Player is holding:", tool.Name)

			-- Check if NPC accepts this food
			local isAllowed = false
			for _, foodName in ipairs(allowedFoods) do
				if foodName == tool.Name then
					isAllowed = true
					break
				end
			end

			--print("DEBUG: NPC allowed foods:", table.concat(allowedFoods, ", "))
			--print("DEBUG: Is food allowed?", isAllowed)

			if not isAllowed then
				warn("DEBUG: NPC does NOT accept:", tool.Name)
				return
			end

			-- Get cash value
			local value = tool:GetAttribute("CashValue")
			if not value then
				warn("DEBUG: Tool has NO CashValue attribute")
				return
			end

			--print("DEBUG: CashValue =", value)

			-- Destroy tool + clear tracker
			tool:Destroy()
			ToolTracker[player] = nil
			--print("DEBUG: Tool destroyed & tracker cleared")

			-- Leaderstats
			local leaderstats = player:FindFirstChild("leaderstats")
			local cash = leaderstats and leaderstats:FindFirstChild("Cash")

			if not leaderstats then
				warn("DEBUG: No leaderstats found for player")
				return
			end
			if not cash then
				warn("DEBUG: No Cash stat found")
				return
			end

			-- Add money
			cash.Value += value

			--print("DEBUG: Player new cash =", cash.Value)
			--print("DEBUG: SELL COMPLETE for:", tool.Name)
			--print("====================================\n")
		end)
	end
end

--print("DEBUG: Sell script initialization complete.")
