local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local worldsFolder = workspace.Worlds.Worlds
local char = player.Character or player.CharacterAdded:Wait()
local ligado = true
local ativo = true
local delayteleport = 1
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

task.spawn(function()
-- Loop
while ativo do
	local unlocade = player.UnlockedWorlds:GetChildren()
	local word = #unlocade
	local worldName = "World" .. word
	local destino = worldsFolder:FindFirstChild(worldName).Part
	if char and char:FindFirstChild("HumanoidRootPart") and ligado then
		char.HumanoidRootPart.CFrame = destino.CFrame + Vector3.new(0, 15, 0)
	end
	task.wait(delayteleport)
end
end)
local Window = Luna:CreateWindow({
	Name = "White Crow Hub", 
	Subtitle = nil, 
	LogoID = "82795327169782", 
	LoadingEnabled = true, 
	LoadingTitle = "White Crow Hub", 
	LoadingSubtitle = "Script by Avelino",

	ConfigSettings = {
		RootFolder = nil, 
		ConfigFolder = "WhiteCrowHub" 
	},

	KeySystem = false, 
	KeySettings = {
		Title = "Luna Example Key",
		Subtitle = "Key System",
		Note = "Best Key System Ever! Also, Please Use A HWID Keysystem like Pelican, Luarmor etc. that provide key strings based on your HWID since putting a simple string is very easy to bypass",
		SaveInRoot = false, 
		SaveKey = true, 
		Key = {"Example Key"},
		SecondAction = {
			Enabled = true, 
			Type = "Link", 
			Parameter = "" 
		}
	}
})

local Tab = Window:CreateTab({
	Name = "Tab Example",
	Icon = "view_in_ar",
	ImageSource = "Material",
	ShowTitle = true
})