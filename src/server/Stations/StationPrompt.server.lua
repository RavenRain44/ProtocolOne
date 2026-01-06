-- Maybe rewrite
-- ChatGPT Response: https://chatgpt.com/s/t_6952f47d68fc8191adfe773fadb8ad83 

-- StationPromptServer.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local OpenStationUI = Remotes:WaitForChild("OpenStationUI")

local stationsFolder = workspace:WaitForChild("ProductionStations")

for _, station in ipairs(stationsFolder:GetChildren()) do
	local prompt = station:FindFirstChild("StationPrompt")
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt.Triggered:Connect(function(player)
			-- send the station name so client can show StationName in UI
			OpenStationUI:FireClient(player, station.Name)
		end)
	else
		warn("Station missing Prompt or wrong class:", station.Name)
	end
end
