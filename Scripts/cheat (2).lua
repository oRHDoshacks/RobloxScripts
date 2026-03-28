-- znx9901 - Cheat GUI Simples com Anti-AFK V2 (WASD)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/znx99/Lua_scripst/main/cheat.lua"))()

---------------- SERVICES ----------------
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

---------------- PLAYER ----------------
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- atualiza referencias no respawn
player.CharacterAdded:Connect(function(c)
	char = c
	hrp = c:WaitForChild("HumanoidRootPart")
	humanoid = c:WaitForChild("Humanoid")
end)

---------------- CONTROLE ----------------
local SCRIPT_ENABLED = true
local UI_OPEN = true

local Functions = {
	AutoCollect = false,
	AutoDeposit = false,
	TesteFunction = false,
	AutoBuy = false,
	AutoUpgrade = false,
	BringBanana = false,
	FollowPlayer = false,
	BugPlayer = false,
	AntiAFK = false -- Controlado pelo botão na interface
}

-- para funções que precisam de nome de player
local FollowTargetName = ""
local BugTargetName = ""

---------------- GUI SIMPLES ----------------
local gui = Instance.new("ScreenGui")
gui.Name = "Znx99Cheat"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.fromOffset(400, 330)
main.Position = UDim2.fromScale(0.3, 0.3)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Visible = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
main.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Znx99 Cheat - Anti-AFK V2 (WASD)"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

-- Linha divisória
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 2)
divider.Position = UDim2.new(0, 0, 0, 30)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
divider.BorderSizePixel = 0
divider.Parent = main

-- Área de inputs
local inputsFrame = Instance.new("Frame")
inputsFrame.Size = UDim2.new(1, -20, 0, 60)
inputsFrame.Position = UDim2.new(0, 10, 0, 35)
inputsFrame.BackgroundTransparency = 1
inputsFrame.Parent = main

-- Input para Follow Player
local followInput = Instance.new("TextBox")
followInput.Size = UDim2.new(0.48, 0, 0, 25)
followInput.Position = UDim2.new(0, 0, 0, 0)
followInput.PlaceholderText = "Nick para seguir"
followInput.Text = ""
followInput.Font = Enum.Font.Gotham
followInput.TextSize = 12
followInput.TextColor3 = Color3.new(1, 1, 1)
followInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
followInput.BorderSizePixel = 0
Instance.new("UICorner", followInput).CornerRadius = UDim.new(0, 5)
followInput.Parent = inputsFrame

followInput.FocusLost:Connect(function()
	FollowTargetName = followInput.Text
end)

-- Input para Bug Player
local bugInput = Instance.new("TextBox")
bugInput.Size = UDim2.new(0.48, 0, 0, 25)
bugInput.Position = UDim2.new(0.52, 0, 0, 0)
bugInput.PlaceholderText = "Nick para bugar"
bugInput.Text = ""
bugInput.Font = Enum.Font.Gotham
bugInput.TextSize = 12
bugInput.TextColor3 = Color3.new(1, 1, 1)
bugInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bugInput.BorderSizePixel = 0
Instance.new("UICorner", bugInput).CornerRadius = UDim.new(0, 5)
bugInput.Parent = inputsFrame

bugInput.FocusLost:Connect(function()
	BugTargetName = bugInput.Text
end)

-- Botão para limpar inputs
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, 0, 0, 25)
clearBtn.Position = UDim2.new(0, 0, 0, 30)
clearBtn.Text = "Limpar Nomes"
clearBtn.Font = Enum.Font.Gotham
clearBtn.TextSize = 12
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
clearBtn.BorderSizePixel = 0
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)
clearBtn.Parent = inputsFrame

clearBtn.MouseButton1Click:Connect(function()
	followInput.Text = ""
	bugInput.Text = ""
	FollowTargetName = ""
	BugTargetName = ""
end)

---------------- BOTÕES DAS FUNÇÕES (3 COLUNAS) ----------------
local buttons = {}

local function createButton(name, posX, posY, width)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(width, 0, 0, 30)
	btn.Position = UDim2.new(posX, 0, posY, 0)
	btn.Text = name .. ": OFF"
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = main

	btn.MouseButton1Click:Connect(function()
		if not SCRIPT_ENABLED then return end
		Functions[name] = not Functions[name]
		if Functions[name] then
			btn.Text = name .. ": ON"
			btn.BackgroundColor3 = Color3.fromRGB(70, 170, 90)
		else
			btn.Text = name .. ": OFF"
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end
	end)
	
	return btn
end

-- Posicionamento dos botões (3 colunas)
local buttonLayout = {
	{name = "AutoCollect", col = 1, row = 1},
	{name = "AutoDeposit", col = 2, row = 1},
	{name = "TesteFunction", col = 3, row = 1},
	{name = "AutoBuy", col = 1, row = 2},
	{name = "AutoUpgrade", col = 2, row = 2},
	{name = "BringBanana", col = 3, row = 2},
	{name = "FollowPlayer", col = 1, row = 3},
	{name = "BugPlayer", col = 2, row = 3},
	{name = "AntiAFK", col = 3, row = 3}
}

local btnWidth = 0.3
local startY = 0.35

for _, layout in ipairs(buttonLayout) do
	local posX = (layout.col - 1) * 0.33 + 0.02
	local posY = startY + (layout.row - 1) * 0.12
	buttons[layout.name] = createButton(layout.name, posX, posY, btnWidth)
end

---------------- ANTI-AFK V2 (LÓGICA INTEGRADA) ----------------
local afkKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}

task.spawn(function()
	while true do
		if Functions.AntiAFK and SCRIPT_ENABLED then
			local randomKey = afkKeys[math.random(1, #afkKeys)]
			
			-- Simula pressionar
			pcall(function()
				VirtualInputManager:SendKeyEvent(true, randomKey, false, game)
				task.wait(math.random(2, 5) / 10)
				VirtualInputManager:SendKeyEvent(false, randomKey, false, game)
			end)
			
			task.wait(math.random(5, 12)) -- Intervalo entre movimentos
		else
			task.wait(1)
		end
	end
end)

-- Proteção extra contra ociosidade
player.Idled:Connect(function()
	if Functions.AntiAFK and SCRIPT_ENABLED then
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.1)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
	end
end)

---------------- HELPERS ----------------
local function getPlayerHRPByName(playerName)
	if not playerName or playerName == "" then return nil end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Name:lower() == playerName:lower() then
			local c = plr.Character
			if c then
				return c:FindFirstChild("HumanoidRootPart")
			end
		end
	end
	return nil
end

---------------- COUNTERS ----------------
local colects = 0
local time_to_buy = 0
local time_to_upgrade = 0

---------------- MAIN LOOP ----------------
task.spawn(function()
	while true do
		task.wait(0.1)
		
		if not SCRIPT_ENABLED then continue end

		-- Atualiza referência do personagem
		if not char or not char.Parent or not hrp or not humanoid then
			char = player.Character
			if char then
				hrp = char:FindFirstChild("HumanoidRootPart")
				humanoid = char:FindFirstChild("Humanoid")
			end
			if not hrp then continue end
		end

		-- Incrementos de contadores
		if Functions.AutoDeposit then colects = colects + 1 end
		if Functions.AutoBuy then time_to_buy = time_to_buy + 1 end
		if Functions.AutoUpgrade then time_to_upgrade = time_to_upgrade + 1 end

		-- AUTO COLLECT
		if Functions.AutoCollect then
			local part = workspace:FindFirstChild("Dropper_Drop", true)
			if part and part:IsA("BasePart") then
				pcall(function() hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0)) end)
			end
		end

		-- AUTO DEPOSIT
		if Functions.AutoDeposit and colects >= 200 then
			colects = 0
			local deposit = workspace:FindFirstChild("DepositButton", true)
			if deposit then
				local deposit_glow = deposit:FindFirstChild("Glow", true)
				if deposit_glow and deposit_glow:IsA("BasePart") then
					pcall(function() hrp.CFrame = CFrame.new(deposit_glow.Position + Vector3.new(0, 5, 0)) end)
				end
			end
		end

		-- AUTO BUY
		if Functions.AutoBuy and time_to_buy >= 200 then
			time_to_buy = 0
			local initial_cframe = hrp.CFrame
			local buy_button = workspace:FindFirstChild("BuyDropper5", true)
			if buy_button then
				local buy_glow = buy_button:FindFirstChild("Glow", true)
				if buy_glow and buy_glow:IsA("BasePart") then
					pcall(function() hrp.CFrame = CFrame.new(buy_glow.Position) end)
					task.wait(0.6)
					pcall(function() hrp.CFrame = initial_cframe end)
				end
			end
		end

		-- AUTO UPGRADE
		if Functions.AutoUpgrade and time_to_upgrade >= 150 then
			time_to_upgrade = 0
			local initial_cframe = hrp.CFrame
			local upgrade_button = workspace:FindFirstChild("BuySpeed", true)
			if upgrade_button then
				local upgrade_base = upgrade_button:FindFirstChild("Base", true)
				if upgrade_base and upgrade_base:IsA("BasePart") then
					pcall(function() hrp.CFrame = CFrame.new(upgrade_base.Position) end)
					task.wait(0.2)
					pcall(function() hrp.CFrame = initial_cframe end)
				end
			end
		end

		-- BRING BANANA
		if Functions.BringBanana then
			local banana = workspace:FindFirstChild("Dropper_Drop", true) or
						  workspace:FindFirstChild("BananaDrop", true) or
						  workspace:FindFirstChild("BananaModel", true)
			if banana then
				local rootPart = banana:IsA("BasePart") and banana or banana:FindFirstChildWhichIsA("BasePart")
				if rootPart then
					pcall(function() rootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0) end)
				end
			end
		end

		-- FOLLOW PLAYER
		if Functions.FollowPlayer and FollowTargetName ~= "" then
			local targetHRP = getPlayerHRPByName(FollowTargetName)
			if targetHRP and targetHRP.Parent then
				pcall(function() hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3) end)
			end
		end

		-- BUG PLAYER
		if Functions.BugPlayer and BugTargetName ~= "" then
			local targetHRP = getPlayerHRPByName(BugTargetName)
			if targetHRP and targetHRP.Parent then
				pcall(function() targetHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -2) end)
			end
		end
	end
end)

---------------- CONTROLES DE TECLADO ----------------
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- INSERT = DESATIVA TUDO
	if input.KeyCode == Enum.KeyCode.Insert then
		SCRIPT_ENABLED = false
		UI_OPEN = false
		main.Visible = false

		for name in pairs(Functions) do
			Functions[name] = false
			if buttons[name] then
				buttons[name].Text = name .. ": OFF"
				buttons[name].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			end
		end
		print("Script desativado!")
	end

	-- 0 = TOGGLE UI
	if input.KeyCode == Enum.KeyCode.Zero then
		if SCRIPT_ENABLED then
			UI_OPEN = not UI_OPEN
			main.Visible = UI_OPEN
		end
	end
end)

print("Znx99 Cheat Final (Anti-AFK WASD Integrado) Carregado!")
