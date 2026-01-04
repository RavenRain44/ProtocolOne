-- Most likely needs to be rewritten

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = player.PlayerGui:WaitForChild("CookingMinigameUI")
local frame = gui.BarFrame
local cursor = frame.Cursor
local stopButton = gui.StopButton

local StartCookingEvent = ReplicatedStorage.Remotes:WaitForChild("StartCookingEvent")
local CookingResultEvent = ReplicatedStorage.Remotes:WaitForChild("CookingResultEvent")

-- Hide UI at start
gui.Enabled = false

-- Cursor movement tween
local tween
local playing = false

local function startMinigame()
	gui.Enabled = true
	playing = true

	cursor.Position = UDim2.fromScale(0, cursor.Position.Y.Scale)

	tween = TweenService:Create(
		cursor,
		TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
		{ Position = UDim2.fromScale(1, cursor.Position.Y.Scale) }
	)
	tween:Play()
end

local function stopMinigame()
	if not playing then
		return
	end
	playing = false

	if tween then
		tween:Cancel()
	end

	-- Check cursor x-position
	local x = cursor.AbsolutePosition.X
	local green = frame.GreenZone.AbsolutePosition
	local yellow = frame.YellowZone.AbsolutePosition
	-- local red = frame.RedZone.AbsolutePosition

	local result = "Red"

	if x >= green.X and x <= green.X + frame.GreenZone.AbsoluteSize.X then
		result = "Green"
	elseif x >= yellow.X and x <= yellow.X + frame.YellowZone.AbsoluteSize.X then
		result = "Yellow"
	else
		result = "Red"
	end

	print("Client result:", result)

	-- Send result to server
	CookingResultEvent:FireServer(result)

	-- Hide UI
	gui.Enabled = false
end

-- LISTEN FOR SERVER START
StartCookingEvent.OnClientEvent:Connect(function()
	startMinigame()
end)

-- STOP BUTTON
stopButton.MouseButton1Click:Connect(stopMinigame)
