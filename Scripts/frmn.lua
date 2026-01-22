local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local worldsFolder = workspace.Worlds.Worlds
local char = player.Character or player.CharacterAdded:Wait()
local ligado = true
local ativo = true
-- Detecta a tecla C
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C then
		ativo = false
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.X then
		ligado = not(ligado)
	end
end)


-- Loop
while ativo do
	local unlocade = player.UnlockedWorlds:GetChildren()
	local word = #unlocade
	local worldName = "World" .. word
	local destino = worldsFolder:FindFirstChild(worldName).Part
	if char and char:FindFirstChild("HumanoidRootPart") and ligado then
		char.HumanoidRootPart.CFrame = destino.CFrame + Vector3.new(0, 15, 0)
	end
	wait(1)
end
