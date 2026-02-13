--[[
    Script: ESP Flee The Facility (OTIMIZADO)
    Autor: w_ky
    Recursos:
    - ESP Players, Exits, PCs, Pods
    - Minimizar com Ctrl Esquerdo
    - Interface preto/vermelho com animações suaves
    - Zero lag (renderização inteligente)
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
local ESP_Players = {}      -- Cache para ESP de players
local ESP_Exits = {}        -- Cache para saídas
local ESP_PCs = {}          -- Cache para computadores
local ESP_Pods = {}         -- Cache para pods
local ESP_Connection = nil
local MenuVisible = true

-- Configurações
local Settings = {
    ToggleKey = Enum.KeyCode.LeftControl,  -- Ctrl Esquerdo para minimizar
    ShowPlayers = true,
    ShowExits = true,
    ShowPCs = true,
    ShowPods = true,
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

-- Frame principal (menu)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Bordas vermelhas suaves
local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(180, 0, 0)
FrameStroke.Thickness = 2
FrameStroke.Transparency = 0.3
FrameStroke.Parent = MainFrame

-- Barra de título (arrastável)
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
Title.Text = "ESP FLEE • v3"
Title.TextColor3 = Color3.fromRGB(220, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Botão minimizar (preto e vermelho)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 2.5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 0, 0)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.AutoButtonColor = false
CloseBtn.Visible = false
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Container do conteúdo (para animação)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Lista de opções (scroll)
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = Content

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = ScrollingFrame

-- Função para criar botões de toggle
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.Parent = ScrollingFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 0, 0)
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
    toggle.BackgroundColor3 = default and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(40, 40, 40)
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
        
        -- Animação suave
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = toggled and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(40, 40, 40)
        }):Play()
        TweenService:Create(ball, TweenInfo.new(0.2), {
            Position = UDim2.new(toggled and 1 or 0, toggled and -22 or 2, 0.5, -10)
        }):Play()
    end)

    return frame
end

-- Criar toggles
createToggle("Mostrar Players", true, function(v) Settings.ShowPlayers = v end)
createToggle("Mostrar Saídas", true, function(v) Settings.ShowExits = v end)
createToggle("Mostrar PCs", true, function(v) Settings.ShowPCs = v end)
createToggle("Mostrar Pods", true, function(v) Settings.ShowPods = v end)

-- Atualizar canvas size
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

-- Função de arrastar
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

-- Função de minimizar (Ctrl Esquerdo)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleKey then
        MenuVisible = not MenuVisible
        if MenuVisible then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 280, 0, 360)
            }):Play()
            MinimizeBtn.Visible = true
            CloseBtn.Visible = false
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 280, 0, 35)
            }):Play()
            MinimizeBtn.Visible = false
            CloseBtn.Visible = true
        end
    end
end)

-- Botões de minimizar/fechar
MinimizeBtn.MouseButton1Click:Connect(function()
    MenuVisible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 280, 0, 35)
    }):Play()
    MinimizeBtn.Visible = false
    CloseBtn.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuVisible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 280, 0, 360)
    }):Play()
    MinimizeBtn.Visible = true
    CloseBtn.Visible = false
end)

-- ========== ESP ==========

-- Função genérica para criar desenhos
local function createESPDrawing(color, text, isPlayer)
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = color
    box.Visible = false

    local nameLabel = isPlayer and Drawing.new("Text") or nil
    if nameLabel then
        nameLabel.Size = 16
        nameLabel.Center = true
        nameLabel.Outline = true
        nameLabel.Color = Color3.new(1,1,1)
        nameLabel.Visible = false
    end

    local distLabel = Drawing.new("Text")
    distLabel.Size = 14
    distLabel.Center = true
    distLabel.Outline = true
    distLabel.Color = Color3.new(0.8,0.8,0.8)
    distLabel.Visible = false

    return {box, nameLabel, distLabel}
end

-- Atualizar ESP de players
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
                    ESP_Players[player] = createESPDrawing(Color3.new(1,1,1), player.Name, true)
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

                if nameLabel then
                    nameLabel.Visible = true
                    nameLabel.Position = Vector2.new(pos.X, pos.Y - sizeY/2 - 18)
                    nameLabel.Text = player.Name
                end

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

-- Atualizar ESP de objetos (Exits, PCs, Pods)
local function updateObjectESP(objects, cache, color, settingsFlag)
    if not ESP_Enabled or not settingsFlag then
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
                    cache[obj] = createESPDrawing(color, obj.Name, false)
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

-- Loop principal otimizado
local function espLoop()
    while ESP_Enabled do
        -- Players
        updatePlayerESP()

        -- Objetos (encontra no workspace)
        local exits = workspace:FindFirstChild("Exits") and workspace.Exits:GetChildren() or {}
        updateObjectESP(exits, ESP_Exits, Settings.Colors.Exit, Settings.ShowExits)

        local pcs = workspace:FindFirstChild("PCs") and workspace.PCs:GetChildren() or {}
        updateObjectESP(pcs, ESP_PCs, Settings.Colors.PC, Settings.ShowPCs)

        local pods = workspace:FindFirstChild("Pods") and workspace.Pods:GetChildren() or {}
        updateObjectESP(pods, ESP_Pods, Settings.Colors.Pod, Settings.ShowPods)

        RunService.RenderStepped:Wait()
    end
end

-- Atalho para ativar ESP
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
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
                -- Limpa tudo
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

print("🚀 ESP Flee v3 carregado! Ctrl Esquerdo minimiza, Ctrl Direito ativa ESP.")
