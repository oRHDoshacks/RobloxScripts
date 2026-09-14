local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()
local Players = game:GetService("Players")
local Word =  game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Zombies = Word.Zombies
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local IsMouseButton1Down = false
local ShowNames = true
local RotationEnabled = true
local VisibleCheck = false
local TransparentObjectsEnabled = false
local ActivationButton = Enum.UserInputType.MouseButton1
local ScriptRunning = true
local InputBeganConnection
local InputEndedConnection
local TransparentParts = {}

local function RestoreTransparency()
    for part, properties in pairs(TransparentParts) do
        if part and part.Parent then
            part.LocalTransparencyModifier = properties.LocalTransparencyModifier
            part.CanCollide = properties.CanCollide
            part.CanQuery = properties.CanQuery
            part.CanTouch = properties.CanTouch
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
    end
}, "ShowNames")

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

ConfigTab:CreateButton({
    Name = "Remover script",
    Description = "Desativa o script e remove os nomes exibidos",
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

    while remainingDirection.Magnitude > 0.01 do
        raycastParams.FilterDescendantsInstances = ignoredInstances
        local result = Word:Raycast(currentOrigin, remainingDirection, raycastParams)
        if not result then
            break
        end

        local part = result.Instance
        if part:IsA("BasePart") then
            if TransparentParts[part] == nil then
                TransparentParts[part] = {
                    LocalTransparencyModifier = part.LocalTransparencyModifier,
                    CanCollide = part.CanCollide,
                    CanQuery = part.CanQuery,
                    CanTouch = part.CanTouch
                }
            end
            part.LocalTransparencyModifier = 1
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
        end

        table.insert(ignoredInstances, part)
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

function Z_ombies()
if TransparentObjectsEnabled then
    RestoreTransparency()
end

local zombies = Zombies:GetChildren()
local mindistance = math.huge
local minposition = nil
local headPosition = nil
local targetZombie = nil
for _, zombie in ipairs(zombies) do    	
    local head = GetZombieHead(zombie)
    if not head then
        continue
    end

    local position = head.Position
    local playerPosition = Word:WaitForChild(Player.Name):GetPivot().Position
    local distance = (playerPosition - head.Position).Magnitude
    if ShowNames then
        HeadText(zombie, zombie.ZombieName.Value .. " (" .. math.floor(distance) .. ")")
    else
        local pedInfo = head and head:FindFirstChild("PedInfo")
        if pedInfo then
            pedInfo:Destroy()
        end
    end
    if (not VisibleCheck or IsZombieVisible(zombie, head)) and mindistance > distance then
		mindistance = distance
		minposition = position
        headPosition = head.Position
        targetZombie = zombie
    end
end

if TransparentObjectsEnabled and not VisibleCheck and targetZombie then
    MakeBlockingObjectsTransparent(targetZombie, targetZombie:FindFirstChild("Head"))
end

print(mindistance)
print(minposition)
print(headPosition)
    return headPosition
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

InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == ActivationButton then
        IsMouseButton1Down = true
    end
end)

InputEndedConnection = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == ActivationButton then
        IsMouseButton1Down = false
    end
end)

while true do
    task.wait()
    if not ScriptRunning then
        break
    end

    local minPosition = Z_ombies()
    if RotationEnabled and IsMouseButton1Down then
        RotateView(minPosition)
        RotateViewUsingFocus(minPosition)
    end
end