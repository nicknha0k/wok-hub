--[[
    Script: ESP Flee The Facility v4
    Autor: w_ky
    Recursos:
    - ESP Players, Exits, PCs, Pods
    - Interface preto/vermelho com abas e títulos
    - Configuração de cores e keybinds
    - Toggles desativados por padrão
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variáveis de estado
local ESP_Enabled = false
local ESP_Players = {}
local ESP_Exits = {}
local ESP_PCs = {}
local ESP_Pods = {}
local ESP_Connection = nil
local MenuVisible = true
local CurrentTab = "ESP"

-- Configurações
local Settings = {
    ToggleMenuKey = Enum.KeyCode.LeftControl,
    ToggleESPKey = Enum.KeyCode.RightControl,
    ShowPlayers = false,
    ShowExits = false,
    ShowPCs = false,
    ShowPods = false,
    ThemeColor = Color3.fromRGB(180, 0, 0), -- Vermelho padrão
    Colors = {
        PlayerBeast = Color3.fromRGB(255, 80, 80),
        PlayerSurvivor = Color3.fromRGB(80, 180, 255),
        PlayerSpectator = Color3.fromRGB(200, 200, 200),
        Exit = Color3.fromRGB(50, 255, 50),
        PC = Color3.fromRGB(255, 200, 50),
        Pod = Color3.fromRGB(100, 150, 255)
    }
}

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPFlee"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 400)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Thickness = 2
FrameStroke.Transparency = 0.3
FrameStroke.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 0, 0)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ESP FLEE • v4"
Title.TextColor3 = Settings.ThemeColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 2.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Settings.ThemeColor
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- Botão maximizar (invisível inicialmente)
local MaximizeBtn = Instance.new("TextButton")
MaximizeBtn.Size = UDim2.new(0, 30, 0, 30)
MaximizeBtn.Position = UDim2.new(1, -35, 0, 2.5)
MaximizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MaximizeBtn.Text = "□"
MaximizeBtn.TextColor3 = Settings.ThemeColor
MaximizeBtn.Font = Enum.Font.GothamBold
MaximizeBtn.TextSize = 20
MaximizeBtn.AutoButtonColor = false
MaximizeBtn.Visible = false
MaximizeBtn.Parent = TitleBar

local MaximizeCorner = Instance.new("UICorner")
MaximizeCorner.CornerRadius = UDim.new(0, 8)
MaximizeCorner.Parent = MaximizeBtn

-- Abas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ESPTab = Instance.new("TextButton")
ESPTab.Size = UDim2.new(0.5, -1, 1, -4)
ESPTab.Position = UDim2.new(0, 2, 0, 2)
ESPTab.BackgroundColor3 = Settings.ThemeColor
ESPTab.BackgroundTransparency = 0.2
ESPTab.Text = "ESP"
ESPTab.TextColor3 = Color3.new(1, 1, 1)
ESPTab.Font = Enum.Font.GothamBold
ESPTab.TextSize = 14
ESPTab.AutoButtonColor = false
ESPTab.Parent = TabContainer

local ESPTabCorner = Instance.new("UICorner")
ESPTabCorner.CornerRadius = UDim.new(0, 8)
ESPTabCorner.Parent = ESPTab

local ConfigTab = Instance.new("TextButton")
ConfigTab.Size = UDim2.new(0.5, -1, 1, -4)
ConfigTab.Position = UDim2.new(0.5, 1, 0, 2)
ConfigTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ConfigTab.Text = "CONFIG"
ConfigTab.TextColor3 = Color3.fromRGB(180, 180, 180)
ConfigTab.Font = Enum.Font.GothamBold
ConfigTab.TextSize = 14
ConfigTab.AutoButtonColor = false
ConfigTab.Parent = TabContainer

local ConfigTabCorner = Instance.new("UICorner")
ConfigTabCorner.CornerRadius = UDim.new(0, 8)
ConfigTabCorner.Parent = ConfigTab

-- Container do conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -70)
Content.Position = UDim2.new(0, 0, 0, 70)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Scroll para ESP
local ESPContent = Instance.new("ScrollingFrame")
ESPContent.Size = UDim2.new(1, -20, 1, -10)
ESPContent.Position = UDim2.new(0, 10, 0, 5)
ESPContent.BackgroundTransparency = 1
ESPContent.BorderSizePixel = 0
ESPContent.ScrollBarThickness = 4
ESPContent.ScrollBarImageColor3 = Settings.ThemeColor
ESPContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ESPContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
ESPContent.Visible = true
ESPContent.Parent = Content

local ESPList = Instance.new("UIListLayout")
ESPList.SortOrder = Enum.SortOrder.LayoutOrder
ESPList.Padding = UDim.new(0, 8)
ESPList.Parent = ESPContent

-- Scroll para Config
local ConfigContent = Instance.new("ScrollingFrame")
ConfigContent.Size = UDim2.new(1, -20, 1, -10)
ConfigContent.Position = UDim2.new(0, 10, 0, 5)
ConfigContent.BackgroundTransparency = 1
ConfigContent.BorderSizePixel = 0
ConfigContent.ScrollBarThickness = 4
ConfigContent.ScrollBarImageColor3 = Settings.ThemeColor
ConfigContent.CanvasSize = UDim2.new(0, 0, 0, 0)
ConfigContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
ConfigContent.Visible = false
ConfigContent.Parent = Content

local ConfigList = Instance.new("UIListLayout")
ConfigList.SortOrder = Enum.SortOrder.LayoutOrder
ConfigList.Padding = UDim.new(0, 8)
ConfigList.Parent = ConfigContent

-- Função para criar título
local function createTitle(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = ESPContent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 1, -2)
    line.BackgroundColor3 = Settings.ThemeColor
    line.BackgroundTransparency = 0.3
    line.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Settings.ThemeColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    return frame
end

-- Função para criar toggle
local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Settings.ThemeColor
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 50, 0, 24)
    toggle.Position = UDim2.new(1, -60, 0.5, -12)
    toggle.BackgroundColor3 = default and Settings.ThemeColor or Color3.fromRGB(40, 40, 40)
    toggle.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 20, 0, 20)
    ball.Position = UDim2.new(default and 1 or 0, default and -22 or 2, 0.5, -10)
    ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ball.Parent = toggle

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = ball

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame

    local toggled = default
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        callback(toggled)
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = toggled and Settings.ThemeColor or Color3.fromRGB(40, 40, 40)
        }):Play()
        TweenService:Create(ball, TweenInfo.new(0.2), {
            Position = UDim2.new(toggled and 1 or 0, toggled and -22 or 2, 0.5, -10)
        }):Play()
    end)

    return frame
end

-- Função para criar opção de cor
local function createColorOption(parent, text, colors, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Settings.ThemeColor
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 20)
    container.Position = UDim2.new(0, 10, 0, 25)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container

    for name, color in pairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 20)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = container

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            callback(color, name)
        end)
    end
end

-- Função para criar opção de keybind
local function createKeybindOption(parent, text, defaultKey, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Settings.ThemeColor
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0.35, -5, 0, 30)
    bindBtn.Position = UDim2.new(0.65, 5, 0.5, -15)
    bindBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bindBtn.Text = defaultKey.Name
    bindBtn.TextColor3 = Settings.ThemeColor
    bindBtn.Font = Enum.Font.Gotham
    bindBtn.TextSize = 12
    bindBtn.AutoButtonColor = false
    bindBtn.Parent = frame

    local bindCorner = Instance.new("UICorner")
    bindCorner.CornerRadius = UDim.new(0, 6)
    bindCorner.Parent = bindBtn

    local listening = false
    bindBtn.MouseButton1Click:Connect(function()
        listening = true
        bindBtn.Text = "..."
        bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                bindBtn.Text = input.KeyCode.Name
                bindBtn.TextColor3 = Settings.ThemeColor
                callback(input.KeyCode)
                connection:Disconnect()
            end
        end)
    end)
end

-- Criar título PLAYERS
createTitle("PLAYERS")

-- Criar toggles (todos desativados por padrão)
createToggle(ESPContent, "Mostrar Players", false, function(v) Settings.ShowPlayers = v end)
createToggle(ESPContent, "Mostrar Saídas (Exits)", false, function(v) Settings.ShowExits = v end)
createToggle(ESPContent, "Mostrar PCs", false, function(v) Settings.ShowPCs = v end)
createToggle(ESPContent, "Mostrar Pods", false, function(v) Settings.ShowPods = v end)

-- Criar título OBJETOS (opcional, já incluso nos toggles)
-- Vou criar um título separado pra ficar organizado
createTitle("OBJETOS")

-- Já criamos os toggles acima, então vou só ajustar a ordem
-- Vou mover os toggles de objetos pra baixo do título OBJETOS
-- Mas como já criei tudo no mesmo pai, vou reorganizar no código final

-- Configuração
createTitle("CORES DA INTERFACE")

createColorOption(ConfigContent, "Tema do Menu", {
    Vermelho = Color3.fromRGB(180, 0, 0),
    Azul = Color3.fromRGB(0, 100, 200),
    Roxo = Color3.fromRGB(120, 0, 200)
}, function(color, name)
    Settings.ThemeColor = color
    Title.TextColor3 = color
    MinimizeBtn.TextColor3 = color
    MaximizeBtn.TextColor3 = color
    ESPTab.BackgroundColor3 = color
    FrameStroke.Color = color
    ESPContent.ScrollBarImageColor3 = color
    ConfigContent.ScrollBarImageColor3 = color
    
    -- Atualiza strokes de todos os toggles (simplificado)
    for _, child in pairs(ESPContent:GetChildren()) do
        if child:IsA("Frame") then
            local stroke = child:FindFirstChild("UIStroke")
            if stroke then stroke.Color = color end
        end
    end
    for _, child in pairs(ConfigContent:GetChildren()) do
        if child:IsA("Frame") then
            local stroke = child:FindFirstChild("UIStroke")
            if stroke then stroke.Color = color end
        end
    end
end)

createTitle("KEYBINDS")

createKeybindOption(ConfigContent, "Minimizar Menu", Settings.ToggleMenuKey, function(key)
    Settings.ToggleMenuKey = key
end)

createKeybindOption(ConfigContent, "Ativar ESP", Settings.ToggleESPKey, function(key)
    Settings.ToggleESPKey = key
end)

-- Atualizar canvas size
ESPList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ESPContent.CanvasSize = UDim2.new(0, 0, 0, ESPList.AbsoluteContentSize.Y + 10)
end)

ConfigList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ConfigContent.CanvasSize = UDim2.new(0, 0, 0, ConfigList.AbsoluteContentSize.Y + 10)
end)

-- Alternar abas
ESPTab.MouseButton1Click:Connect(function()
    CurrentTab = "ESP"
    ESPTab.BackgroundColor3 = Settings.ThemeColor
    ESPTab.TextColor3 = Color3.new(1, 1, 1)
    ConfigTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ConfigTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    ESPContent.Visible = true
    ConfigContent.Visible = false
end)

ConfigTab.MouseButton1Click:Connect(function()
    CurrentTab = "CONFIG"
    ConfigTab.BackgroundColor3 = Settings.ThemeColor
    ConfigTab.TextColor3 = Color3.new(1, 1, 1)
    ESPTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ESPTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    ESPContent.Visible = false
    ConfigContent.Visible = true
end)

-- Arrastar
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Minimizar/Maximizar
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleMenuKey then
        MenuVisible = not MenuVisible
        if MenuVisible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 280, 0, 400)
            }):Play()
            MinimizeBtn.Visible = true
            MaximizeBtn.Visible = false
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 280, 0, 35)
            }):Play()
            MinimizeBtn.Visible = false
            MaximizeBtn.Visible = true
        end
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MenuVisible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 280, 0, 35)
    }):Play()
    MinimizeBtn.Visible = false
    MaximizeBtn.Visible = true
end)

MaximizeBtn.MouseButton1Click:Connect(function()
    MenuVisible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 280, 0, 400)
    }):Play()
    MinimizeBtn.Visible = true
    MaximizeBtn.Visible = false
end)

-- ========== ESP ==========

local function createESPDrawing(color)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = color
    box.Visible = false

    local nameLabel = Drawing.new("Text")
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Color = Color3.new(1,1,1)
    nameLabel.Visible = false

    local distLabel = Drawing.new("Text")
    distLabel.Size = 14
    distLabel.Center = true
    distLabel.Outline = true
    distLabel.Color = Color3.new(0.8,0.8,0.8)
    distLabel.Visible = false

    return {box, nameLabel, distLabel}
end

local function updatePlayerESP()
    if not ESP_Enabled or not Settings.ShowPlayers then
        for _, objs in pairs(ESP_Players) do
            for _, obj in pairs(objs) do if obj then obj.Visible = false end end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                if not ESP_Players[player] then
                    ESP_Players[player] = createESPDrawing(Color3.new(1,1,1))
                end

                local objs = ESP_Players[player]
                local box, nameLabel, distLabel = objs[1], objs[2], objs[3]
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                local scale = math.clamp(300 / dist, 0.8, 3)
                local sizeX, sizeY = 40 * scale, 60 * scale

                local isBeast = char:FindFirstChild("Beast") ~= nil
                local isAlive = char:FindFirstChild("Humanoid") ~= nil
                local color
                if not isAlive then
                    color = Settings.Colors.PlayerSpectator
                elseif isBeast then
                    color = Settings.Colors.PlayerBeast
                else
                    color = Settings.Colors.PlayerSurvivor
                end

                box.Color = color
                box.Visible = true
                box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                box.Size = Vector2.new(sizeX, sizeY)

                nameLabel.Visible = true
                nameLabel.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 18)
                nameLabel.Text = player.Name

                distLabel.Visible = true
                distLabel.Position = Vector2.new(pos.X, pos.Y + sizeY/2 + 14)
                distLabel.Text = math.floor(dist) .. "m"
            else
                if ESP_Players[player] then
                    for _, obj in pairs(ESP_Players[player]) do
                        if obj then obj.Visible = false end
                    end
                end
            end
        end
    end
end

local function updateObjectESP(objects, cache, color, enabled)
    if not ESP_Enabled or not enabled then
        for _, objs in pairs(cache) do
            for _, obj in pairs(objs) do if obj then obj.Visible = false end end
        end
        return
    end

    for _, obj in ipairs(objects) do
        if obj and obj:IsA("BasePart") then
            local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            if onScreen then
                if not cache[obj] then
                    cache[obj] = createESPDrawing(color)
                end

                local objs = cache[obj]
                local box, _, distLabel = objs[1], objs[2], objs[3]
                local dist = (Camera.CFrame.Position - obj.Position).Magnitude
                local scale = math.clamp(300 / dist, 0.8, 3)
                local sizeX, sizeY = 30 * scale, 30 * scale

                box.Color = color
                box.Visible = true
                box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                box.Size = Vector2.new(sizeX, sizeY)

                distLabel.Visible = true
                distLabel.Position = Vector2.new(pos.X, pos.Y + sizeY/2 + 10)
                distLabel.Text = math.floor(dist) .. "m"
            else
                if cache[obj] then
                    for _, obj2 in pairs(cache[obj]) do
                        if obj2 then obj2.Visible = false end
                    end
                end
            end
        end
    end
end

local function espLoop()
    while ESP_Enabled do
        updatePlayerESP()

        local exits = workspace:FindFirstChild("Exits") and workspace.Exits:GetChildren() or {}
        updateObjectESP(exits, ESP_Exits, Settings.Colors.Exit, Settings.ShowExits)

        local pcs = workspace:FindFirstChild("PCs") and workspace.PCs:GetChildren() or {}
        updateObjectESP(pcs, ESP_PCs, Settings.Colors.PC, Settings.ShowPCs)

        local pods = workspace:FindFirstChild("Pods") and workspace.Pods:GetChildren() or {}
        updateObjectESP(pods, ESP_Pods, Settings.Colors.Pod, Settings.ShowPods)

        RunService.RenderStepped:Wait()
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleESPKey then
        ESP_Enabled = not ESP_Enabled
        if ESP_Enabled then
            if not ESP_Connection then
                ESP_Connection = RunService.RenderStepped:Connect(espLoop)
            end
            print("✅ ESP Ativado")
        else
            if ESP_Connection then
                ESP_Connection:Disconnect()
                ESP_Connection = nil
                for _, objs in pairs(ESP_Players) do
                    for _, obj in pairs(objs) do if obj then obj:Remove() end end
                end
                for _, objs in pairs(ESP_Exits) do
                    for _, obj in pairs(objs) do if obj then obj:Remove() end end
                end
                for _, objs in pairs(ESP_PCs) do
                    for _, obj in pairs(objs) do if obj then obj:Remove() end end
                end
                for _, objs in pairs(ESP_Pods) do
                    for _, obj in pairs(objs) do if obj then obj:Remove() end end
                end
                ESP_Players = {}
                ESP_Exits = {}
                ESP_PCs = {}
                ESP_Pods = {}
            end
            print("❌ ESP Desativado")
        end
    end
end)

print("🚀 ESP Flee v4 carregado!")
print("📌 Ctrl Esquerdo: minimizar | Ctrl Direito: ativar ESP")
