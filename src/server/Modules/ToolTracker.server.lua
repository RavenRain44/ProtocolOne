-- Maybe Rewrite
-- ChatGPT Response: https://chatgpt.com/s/t_6952f620b4688191a746d1057a130117

-- ServerScriptService/ToolTracker
local Players = game:GetService("Players")

local equippedTools = {}

local function trackCharacter(player, character)
	equippedTools[player] = nil

	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			equippedTools[player] = child
			print(player.Name.." equipped "..child.Name)
		end
	end)

	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			if equippedTools[player] == child then
				equippedTools[player] = nil
				print(player.Name.." unequipped "..child.Name)
			end
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		trackCharacter(player, char)
	end)
end)

return equippedTools
