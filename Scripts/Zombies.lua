local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()
local Players = game:GetService("Players")
local Word =  game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Zombies = Word.Zombies
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsMouseButton1Down = false
local ShowNames = true
local ShowBoxes = false
local ShowHealthBars = false
local ShowLines = false
local RotationEnabled = true
local MouseMovementAimEnabled = false
local AimFovRadius = 300
local ShowFovCircle = true
local TeleportBehindEnabled = false
local TeleportDistance = 5
local VisibleCheck = false
local TransparentObjectsEnabled = false
local ActivationButton = Enum.UserInputType.MouseButton1
local ScriptRunning = true
local InputBeganConnection
local InputEndedConnection
local VisualConnection
local TransparentParts = {}
local VisualObjects = {}
local FovCircle
local CurrentTargetPosition
local CurrentTarget

local function RestoreTransparency()
    for part, properties in pairs(TransparentParts) do
        if part and part.Parent then
            part.LocalTransparencyModifier = properties.LocalTransparencyModifier
            part.CanCollide = properties.CanCollide
        end
    end
    table.clear(TransparentParts)
end

local function RemoveScript()
    ScriptRunning = false
    IsMouseButton1Down = false
    RestoreTransparency()

    if InputBeganConnection then
        InputBeganConnection:Disconnect()
    end

    if InputEndedConnection then
        InputEndedConnection:Disconnect()
    end

    if VisualConnection then
        VisualConnection:Disconnect()
    end

    if FovCircle then
        FovCircle:Remove()
        FovCircle = nil
    end

    for model, objects in pairs(VisualObjects) do
        for _, object in pairs(objects) do
            object:Remove()
        end
        VisualObjects[model] = nil
    end

    for _, zombie in ipairs(Zombies:GetChildren()) do
        local head = zombie:FindFirstChild("Head")
        local pedInfo = head and head:FindFirstChild("PedInfo")
        if pedInfo then
            pedInfo:Destroy()
        end
    end

    Luna:Destroy()
end

local Window = Luna:CreateWindow({
    Name = "DEAD MOON",
    Subtitle = "",
    LoadingEnabled = false,
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "ZombieTools"
    },
    KeySystem = false
})

local AimTab = Window:CreateTab({
    Name = "Mira",
    Icon = "gps_fixed",
    ImageSource = "Material",
    ShowTitle = true
})

local VisualTab = Window:CreateTab({
    Name = "Visual",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true
})

local ExtrasTab = Window:CreateTab({
    Name = "Extras",
    Icon = "extension",
    ImageSource = "Material",
    ShowTitle = true
})

local ConfigTab = Window:CreateTab({
    Name = "Config",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})

AimTab:CreateToggle({
    Name = "Rotacao da camera",
    Description = "Permite girar a camera enquanto o botao escolhido estiver pressionado",
    CurrentValue = true,
    Callback = function(value)
        RotationEnabled = value
    end
}, "RotationEnabled")

AimTab:CreateToggle({
    Name = "Movimento do mouse",
    Description = "Usa o movimento do cursor para mirar, separado da rotacao da camera",
    CurrentValue = false,
    Callback = function(value)
        MouseMovementAimEnabled = value
    end
}, "MouseMovementAimEnabled")

AimTab:CreateToggle({
    Name = "Visivel",
    Description = "Considera apenas zumbis sem objetos entre o jogador e a cabeca",
    CurrentValue = false,
    Callback = function(value)
        VisibleCheck = value
        if value then
            RestoreTransparency()
        end
    end
}, "VisibleCheck")

AimTab:CreateSlider({
    Name = "Raio do FOV",
    Description = "Define a distancia maxima do alvo a partir do centro da tela",
    Range = {50, 1000},
    Increment = 10,
    CurrentValue = 300,
    Callback = function(value)
        AimFovRadius = value
    end
}, "AimFovRadius")

AimTab:CreateToggle({
    Name = "Mostrar FOV",
    Description = "Exibe a regiao usada pela mira",
    CurrentValue = true,
    Callback = function(value)
        ShowFovCircle = value
    end
}, "ShowFovCircle")

AimTab:CreateDropdown({
    Name = "Botao de ativacao",
    Description = "Escolha o botao usado para girar a camera",
    Options = {"MouseButton1", "MouseButton2"},
    CurrentOption = {"MouseButton1"},
    MultipleOptions = false,
    Callback = function(option)
        if option == "MouseButton2" then
            ActivationButton = Enum.UserInputType.MouseButton2
        else
            ActivationButton = Enum.UserInputType.MouseButton1
        end
        IsMouseButton1Down = false
    end
}, "ActivationButton")

VisualTab:CreateToggle({
    Name = "Mostrar nomes",
    Description = "Exibe ou oculta os nomes dos zumbis",
    CurrentValue = true,
    Callback = function(value)
        ShowNames = value
        if not value then
            RemoveZombieNames()
        end
    end
}, "ShowNames")

VisualTab:CreateToggle({
    Name = "Mostrar boxes",
    Description = "Exibe uma caixa ao redor dos zumbis",
    CurrentValue = false,
    Callback = function(value)
        ShowBoxes = value
        for model in pairs(VisualObjects) do
            RemoveVisualObjects(model)
        end
    end
}, "ShowBoxes")

VisualTab:CreateToggle({
    Name = "Mostrar barra de vida",
    Description = "Exibe a vida atual dos zumbis",
    CurrentValue = false,
    Callback = function(value)
        ShowHealthBars = value
        for model in pairs(VisualObjects) do
            RemoveVisualObjects(model)
        end
    end
}, "ShowHealthBars")

VisualTab:CreateToggle({
    Name = "Mostrar linhas",
    Description = "Exibe uma linha da tela ate os zumbis",
    CurrentValue = false,
    Callback = function(value)
        ShowLines = value
        for model in pairs(VisualObjects) do
            RemoveVisualObjects(model)
        end
    end
}, "ShowLines")

ExtrasTab:CreateToggle({
    Name = "Deixar objetos transparentes",
    Description = "Deixa transparentes os objetos entre o jogador e o zombie quando Visivel esta desligado",
    CurrentValue = false,
    Callback = function(value)
        TransparentObjectsEnabled = value
        if not value or VisibleCheck then
            RestoreTransparency()
        end
    end
}, "TransparentObjectsEnabled")

ExtrasTab:CreateToggle({
    Name = "Teleporte para tras",
    Description = "Teleporta para tras do alvo ao pressionar E",
    CurrentValue = false,
    Callback = function(value)
        TeleportBehindEnabled = value
    end
}, "TeleportBehindEnabled")

ExtrasTab:CreateSlider({
    Name = "Distancia do teleporte",
    Description = "Define quantos studs o jogador ficara atras do alvo",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        TeleportDistance = value
    end
}, "TeleportDistance")

ConfigTab:CreateButton({
    Name = "Remover script",
    Callback = RemoveScript
})

local function HeadText(Ped, Text)
    local head = Ped:FindFirstChild("Head")

    if not head then
        return
    end
    	if head:FindFirstChild("PedInfo") then
            head.PedInfo.TextLabel.Text = Text
            return
        end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PedInfo"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 10)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = Text
    text.TextScaled = true
    text.TextColor3 = Color3.fromRGB(255, 0, 0)
    text.TextStrokeTransparency = 0
    text.Parent = billboard
end
function distanceMinima(Player, Ped)
    local PlayerPosition = Word:WaitForChild(Player.Name):GetPivot().Position
    local PedPosition = Ped:GetPivot().Position
    local distance = (PlayerPosition - PedPosition).Magnitude
    return distance
end

function IsZombieVisible(zombie, head)
    local character = Player.Character
    local originPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
    if not originPart or not head then
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local ignoredCharacters = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            table.insert(ignoredCharacters, player.Character)
        end
    end
    raycastParams.FilterDescendantsInstances = ignoredCharacters

    local direction = head.Position - originPart.Position
    local result = Word:Raycast(originPart.Position, direction, raycastParams)

    return not result or result.Instance:IsDescendantOf(zombie)
end

function MakeBlockingObjectsTransparent(zombie, head)
    local character = Player.Character
    local originPart = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
    if not originPart or not head then
        return
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local ignoredInstances = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            table.insert(ignoredInstances, player.Character)
        end
    end
    table.insert(ignoredInstances, zombie)

    local direction = head.Position - originPart.Position
    local remainingDirection = direction
    local currentOrigin = originPart.Position
    local raycastSteps = 0

    while remainingDirection.Magnitude > 0.01 and raycastSteps < 16 do
        raycastSteps += 1
        raycastParams.FilterDescendantsInstances = ignoredInstances
        local result = Word:Raycast(currentOrigin, remainingDirection, raycastParams)
        if not result then
            break
        end

        local part = result.Instance
        local isZombiePart = part:IsDescendantOf(Zombies)
        local isPlayerPart = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and part:IsDescendantOf(player.Character) then
                isPlayerPart = true
                break
            end
        end

        if part:IsA("BasePart") and not isZombiePart and not isPlayerPart then
            if TransparentParts[part] == nil then
                TransparentParts[part] = {
                    LocalTransparencyModifier = part.LocalTransparencyModifier,
                    CanCollide = part.CanCollide
                }
            end
            part.LocalTransparencyModifier = 1
            part.CanCollide = false
        end

        if not isZombiePart and not isPlayerPart then
            table.insert(ignoredInstances, part)
        else
            break
        end
        local distanceFromOrigin = (result.Position - currentOrigin).Magnitude
        currentOrigin = result.Position + remainingDirection.Unit * 0.01
        remainingDirection = direction - (currentOrigin - originPart.Position)

        if distanceFromOrigin <= 0.01 then
            break
        end
    end
end

function GetZombieHead(zombie)
    local head = zombie:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head
    end
    return nil
end

function GetBoss()
    local map = Word:FindFirstChild("Map")
    local bossFolder = map and map:FindFirstChild("BossFolder")
    return bossFolder and bossFolder:FindFirstChild("Boss")
end

function UpdateZombieNames()
    local boss = GetBoss()
    local bossHead = boss and GetZombieHead(boss)
    if bossHead then
        local playerPosition = Word:WaitForChild(Player.Name):GetPivot().Position
        local bossDistance = (playerPosition - bossHead.Position).Magnitude
        local bossName = boss:FindFirstChild("ZombieName")
        local displayName = bossName and tostring(bossName.Value) or "Boss"
        HeadText(boss, displayName .. " (" .. math.floor(bossDistance) .. ")")
    end

    local playerCharacter = Word:WaitForChild(Player.Name)
    local playerPosition = playerCharacter:GetPivot().Position
    for _, zombie in ipairs(Zombies:GetChildren()) do
        local head = GetZombieHead(zombie)
        local zombieName = zombie:FindFirstChild("ZombieName")
        if head and zombieName then
            local distance = (playerPosition - head.Position).Magnitude
            HeadText(zombie, tostring(zombieName.Value) .. " (" .. math.floor(distance) .. ")")
        end
    end
end

function RemoveZombieNames()
    for _, zombie in ipairs(Zombies:GetChildren()) do
        local head = zombie:FindFirstChild("Head")
        local pedInfo = head and head:FindFirstChild("PedInfo")
        if pedInfo then
            pedInfo:Destroy()
        end
    end

    local boss = GetBoss()
    local bossHead = boss and boss:FindFirstChild("Head")
    local pedInfo = bossHead and bossHead:FindFirstChild("PedInfo")
    if pedInfo then
        pedInfo:Destroy()
    end
end

function HideVisualObjects()
    for _, objects in pairs(VisualObjects) do
        for _, object in pairs(objects) do
            object.Visible = false
        end
    end
end

function RemoveVisualObjects(model)
    local objects = VisualObjects[model]
    if not objects then
        return
    end

    for _, object in pairs(objects) do
        object:Remove()
    end
    VisualObjects[model] = nil
end

function CreateVisualObjects(model)
    if not Drawing or type(Drawing.new) ~= "function" then
        return nil
    end

    local objects = {}
    if ShowBoxes then
        local success, box = pcall(Drawing.new, "Square")
        if not success then
            return nil
        end
        box.Color = Color3.fromRGB(255, 255, 255)
        box.Thickness = 1
        box.Filled = false
        objects.Box = box
    end

    if ShowHealthBars then
        local success, background = pcall(Drawing.new, "Square")
        if not success then
            for _, object in pairs(objects) do
                object:Remove()
            end
            return nil
        end
        local fillSuccess, fill = pcall(Drawing.new, "Square")
        if not fillSuccess then
            background:Remove()
            for _, object in pairs(objects) do
                object:Remove()
            end
            return nil
        end
        background.Color = Color3.fromRGB(0, 0, 0)
        background.Filled = true
        fill.Filled = true
        objects.HealthBackground = background
        objects.HealthFill = fill
    end

    if ShowLines then
        local success, line = pcall(Drawing.new, "Line")
        if not success then
            for _, object in pairs(objects) do
                object:Remove()
            end
            return nil
        end
        line.Thickness = 1
        objects.Line = line
    end

    VisualObjects[model] = objects
    return objects
end

function UpdateVisuals()
    UpdateFovCircle()

    if not ShowBoxes and not ShowHealthBars and not ShowLines then
        HideVisualObjects()
        return
    end

    local camera = Word.CurrentCamera
    if not camera then
        return
    end

    local models = {}
    local boss = GetBoss()
    if boss then
        table.insert(models, boss)
    end
    for _, zombie in ipairs(Zombies:GetChildren()) do
        table.insert(models, zombie)
    end

    local activeModels = {}
    for _, model in ipairs(models) do
        local head = GetZombieHead(model)
        if head then
            activeModels[model] = true
            local isBoss = model == boss
            local objects = VisualObjects[model] or CreateVisualObjects(model)
            if objects then
                local boxCFrame, boxSize = model:GetBoundingBox()
                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                local visibleCorners = 0

                for x = -1, 1, 2 do
                    for y = -1, 1, 2 do
                        for z = -1, 1, 2 do
                            local corner = boxCFrame:PointToWorldSpace(Vector3.new(
                                boxSize.X * x / 2,
                                boxSize.Y * y / 2,
                                boxSize.Z * z / 2
                            ))
                            local screenPoint = camera:WorldToViewportPoint(corner)
                            if screenPoint.Z > 0 then
                                visibleCorners += 1
                                minX = math.min(minX, screenPoint.X)
                                minY = math.min(minY, screenPoint.Y)
                                maxX = math.max(maxX, screenPoint.X)
                                maxY = math.max(maxY, screenPoint.Y)
                            end
                        end
                    end
                end

                local isVisible = visibleCorners > 0
                if objects.Box then
                    objects.Box.Visible = isVisible and ShowBoxes
                    objects.Box.Color = isBoss
                        and Color3.fromRGB(170, 0, 255)
                        or Color3.fromRGB(255, 255, 255)
                    objects.Box.Position = Vector2.new(minX, minY)
                    objects.Box.Size = Vector2.new(maxX - minX, maxY - minY)
                end

                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local healthRatio = humanoid and math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1) or 0
                if objects.HealthBackground then
                    local barX = minX - 6
                    local barHeight = maxY - minY
                    objects.HealthBackground.Visible = isVisible and ShowHealthBars
                    objects.HealthBackground.Position = Vector2.new(barX, minY)
                    objects.HealthBackground.Size = Vector2.new(4, barHeight)
                    objects.HealthFill.Visible = isVisible and ShowHealthBars
                    objects.HealthFill.Position = Vector2.new(barX, maxY - barHeight * healthRatio)
                    objects.HealthFill.Size = Vector2.new(4, barHeight * healthRatio)
                    objects.HealthFill.Color = Color3.new(1 - healthRatio, healthRatio, 0)
                end

                if objects.Line then
                    local viewportSize = camera.ViewportSize
                    objects.Line.Visible = isVisible and ShowLines
                    objects.Line.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    objects.Line.To = Vector2.new((minX + maxX) / 2, maxY)
                    objects.Line.Color = isBoss
                        and Color3.fromRGB(170, 0, 255)
                        or Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end

    for model in pairs(VisualObjects) do
        if not activeModels[model] or not model.Parent then
            RemoveVisualObjects(model)
        end
    end
end

function IsPositionInsideAimFov(position)
    local camera = Word.CurrentCamera
    if not camera then
        return false
    end

    local screenPoint = camera:WorldToViewportPoint(position)
    if screenPoint.Z <= 0 then
        return false
    end

    local viewportSize = camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
    return (screenPosition - center).Magnitude <= AimFovRadius
end

function UpdateFovCircle()
    if not Drawing or type(Drawing.new) ~= "function" then
        return
    end

    if not FovCircle then
        local success, circle = pcall(Drawing.new, "Circle")
        if not success then
            return
        end
        circle.Color = Color3.fromRGB(255, 255, 255)
        circle.Thickness = 1
        circle.Filled = false
        FovCircle = circle
    end

    local camera = Word.CurrentCamera
    if not camera then
        FovCircle.Visible = false
        return
    end

    local viewportSize = camera.ViewportSize
    FovCircle.Visible = ShowFovCircle
    FovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FovCircle.Radius = AimFovRadius
end

function Z_ombies()
if TransparentObjectsEnabled then
    RestoreTransparency()
end

local zombies = Zombies:GetChildren()
local mindistance = math.huge
local minposition = nil
local headPosition = nil
local targetZombie = nil

local boss = GetBoss()
local bossHead = boss and GetZombieHead(boss)
if bossHead and IsPositionInsideAimFov(bossHead.Position)
    and (not VisibleCheck or IsZombieVisible(boss, bossHead)) then
    local playerPosition = Word:WaitForChild(Player.Name):GetPivot().Position
    local bossDistance = (playerPosition - bossHead.Position).Magnitude
    local bossName = boss:FindFirstChild("ZombieName")
    local displayName = bossName and tostring(bossName.Value) or "Boss"

    if TransparentObjectsEnabled and not VisibleCheck then
        MakeBlockingObjectsTransparent(boss, bossHead)
    end

    return bossHead.Position, boss
end

local playerCharacter = Word:WaitForChild(Player.Name)
local playerPosition = playerCharacter:GetPivot().Position

for _, zombie in ipairs(zombies) do    	
    local head = GetZombieHead(zombie)
    if not head then
        continue
    end

    local position = head.Position
    local distance = (playerPosition - head.Position).Magnitude
    if IsPositionInsideAimFov(position)
        and (not VisibleCheck or IsZombieVisible(zombie, head))
        and mindistance > distance then
		mindistance = distance
		minposition = position
        headPosition = head.Position
        targetZombie = zombie
    end
end

if TransparentObjectsEnabled and not VisibleCheck and targetZombie then
    MakeBlockingObjectsTransparent(targetZombie, targetZombie:FindFirstChild("Head"))
end

    return headPosition, targetZombie
end

function GetTeleportTarget()
    local boss = GetBoss()
    local bossHead = boss and GetZombieHead(boss)
    if bossHead then
        return bossHead.Position, boss
    end

    local character = Word:FindFirstChild(Player.Name)
    if not character then
        return nil, nil
    end

    local playerPosition = character:GetPivot().Position
    local nearestDistance = math.huge
    local nearestPosition = nil
    local nearestZombie = nil

    for _, zombie in ipairs(Zombies:GetChildren()) do
        local head = GetZombieHead(zombie)
        if head then
            local distance = (playerPosition - head.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPosition = head.Position
                nearestZombie = zombie
            end
        end
    end

    return nearestPosition, nearestZombie
end

function TeleportBehindNearest()
    local character = Player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local targetPosition, target = GetTeleportTarget()
    if not targetPosition or not target or not rootPart then
        return
    end

    local targetPivot = target:GetPivot()
    local destination = targetPivot.Position - targetPivot.LookVector * TeleportDistance
    rootPart.CFrame = CFrame.lookAt(destination, targetPosition)
end

function RotateView(targetPosition)
    if not targetPosition then
        return
    end

    local camera = Word.CurrentCamera
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPosition)
end

function RotateViewUsingFocus(targetPosition)
    if not targetPosition then
        return
    end

    local camera = Word.CurrentCamera
    camera.CFrame = CFrame.new(camera.Focus.Position, targetPosition)
end

function RotateViewUsingMouse(targetPosition)
    if not targetPosition or type(mousemoverel) ~= "function" then
        return
    end

    local camera = Word.CurrentCamera
    local screenPoint = camera:WorldToViewportPoint(targetPosition)

    local viewportSize = camera.ViewportSize
    local targetX = math.clamp(screenPoint.X, 0, viewportSize.X)
    local targetY = math.clamp(screenPoint.Y, 0, viewportSize.Y)
    local shiftX = (targetX - viewportSize.X / 2) / 4
    local shiftY = (targetY - viewportSize.Y / 2) / 4
    mousemoverel(shiftX, shiftY)
end

InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E and TeleportBehindEnabled then
        TeleportBehindNearest()
        return
    end

    if not gameProcessed and input.UserInputType == ActivationButton then
        IsMouseButton1Down = true
    end
end)

InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == ActivationButton then
        IsMouseButton1Down = false
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not ScriptRunning then
            break
        end

        CurrentTargetPosition, CurrentTarget = Z_ombies()
    end
end)

VisualConnection = RunService.RenderStepped:Connect(UpdateVisuals)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not ScriptRunning then
            break
        end

        if RotationEnabled and IsMouseButton1Down then
            RotateView(CurrentTargetPosition)
            RotateViewUsingFocus(CurrentTargetPosition)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not ScriptRunning then
            break
        end

        if MouseMovementAimEnabled and IsMouseButton1Down then
            RotateViewUsingMouse(CurrentTargetPosition)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not ScriptRunning then
            break
        end

        if ShowNames then
            UpdateZombieNames()
        else
            RemoveZombieNames()
        end
    end
end)