----------------
-- DEPRECATED --
----------------
--
-- REWRITE THIS FILE --
-- Check with ChatGPT for how it can be implemented.
--
-- ChatGPT Response: https://chatgpt.com/s/t_6952ee3cf5308191a807e3047bd96868

-- Tracks player money
game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 0
	cash.Parent = leaderstats
end)
