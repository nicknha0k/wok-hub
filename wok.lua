-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local ESP_Enabled = false
local MenuVisible = true
local CurrentTab = "ESP"
local HighlightObjects = {}

-- Configurações
local Settings = {
    ToggleMenuKey = Enum.KeyCode.LeftControl,
    ToggleESPKey = Enum.KeyCode.RightControl,
    ShowPlayers = false,
    ShowExits = false,
    ShowPCs = false,
    ShowPods = false,
    ThemeColor = Color3.fromRGB(180, 0, 0),
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
Title.Text = "ESP FLEE • v4.5"
Title.TextColor3 = Settings.ThemeColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

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

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -70)
Content.Position = UDim2.new(0, 0, 0, 70)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

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

-- Funções da Interface
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

-- ========== FUNÇÕES DE ESP ==========

local function createHighlight(character, color)
    if not character then return end
    
    local existing = HighlightObjects[character]
    if existing then
        existing.FillColor = color
        existing.OutlineColor = color
        return existing
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "MendigoESP"
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local connection
    connection = character.AncestryChanged:Connect(function()
        if not character:IsDescendantOf(workspace) then
            if highlight then
                highlight:Destroy()
            end
            if connection then
                connection:Disconnect()
            end
            HighlightObjects[character] = nil
        end
    end)
    
    HighlightObjects[character] = highlight
    return highlight
end

local function removeHighlight(character)
    local highlight = HighlightObjects[character]
    if highlight then
        highlight:Destroy()
        HighlightObjects[character] = nil
    end
end

local function getPlayerColor(player)
    if player == LocalPlayer then
        return Settings.ThemeColor
    end
    
    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("beast") or tool.Name:lower():find("feral")) then
            return Settings.Colors.PlayerBeast
        end
    end
    
    return Settings.Colors.PlayerSurvivor
end

local function updateESP()
    if not ESP_Enabled then
        for char, highlight in pairs(HighlightObjects) do
            highlight:Destroy()
        end
        HighlightObjects = {}
        return
    end
    
    if Settings.ShowPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local color = getPlayerColor(player)
                    createHighlight(character, color)
                else
                    removeHighlight(character)
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                removeHighlight(player.Character)
            end
        end
    end
    
    if Settings.ShowExits then
        for _, exit in ipairs(workspace:GetDescendants()) do
            if exit.Name:lower():find("exit") and exit:IsA("BasePart") then
                createHighlight(exit, Settings.Colors.Exit)
            end
        end
    end
    
    if Settings.ShowPCs then
        for _, pc in ipairs(workspace:GetDescendants()) do
            if (pc.Name:lower():find("pc") or pc.Name:lower():find("computer")) and pc:IsA("BasePart") then
                createHighlight(pc, Settings.Colors.PC)
            end
        end
    end
    
    if Settings.ShowPods then
        for _, pod in ipairs(workspace:GetDescendants()) do
            if pod.Name:lower():find("pod") and pod:IsA("BasePart") then
                createHighlight(pod, Settings.Colors.Pod)
            end
        end
    end
end

-- Conecta a atualização
RunService.RenderStepped:Connect(updateESP)

-- Eventos de jogador
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if ESP_Enabled and Settings.ShowPlayers then
            local color = getPlayerColor(player)
            createHighlight(character, color)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeHighlight(player.Character)
    end
end)

-- Toggle ESP por bind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Settings.ToggleESPKey then
        ESP_Enabled = not ESP_Enabled
        if not ESP_Enabled then
            for char, highlight in pairs(HighlightObjects) do
                highlight:Destroy()
            end
            HighlightObjects = {}
        end
    end
end)

-- ========== CRIAÇÃO DOS TOGGLES ==========

createTitle("PLAYERS")
createToggle(ESPContent, "Mostrar Jogadores", Settings.ShowPlayers, function(state)
    Settings.ShowPlayers = state
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                removeHighlight(player.Character)
            end
        end
    end
end)

createTitle("OBJETOS")
createToggle(ESPContent, "Mostrar Saídas", Settings.ShowExits, function(state)
    Settings.ShowExits = state
end)

createToggle(ESPContent, "Mostrar PCs", Settings.ShowPCs, function(state)
    Settings.ShowPCs = state
end)

createToggle(ESPContent, "Mostrar Pods", Settings.ShowPods, function(state)
    Settings.ShowPods = state
end)

-- Configurações
createTitle("CONTROLES")
local toggleMenuLabel = "Menu: " .. Settings.ToggleMenuKey.Name
local toggleESPLabel = "ESP: " .. Settings.ToggleESPKey.Name

local menuKeyFrame = Instance.new("Frame")
menuKeyFrame.Size = UDim2.new(1, 0, 0, 30)
menuKeyFrame.BackgroundTransparency = 1
menuKeyFrame.Parent = ConfigContent

local menuKeyLabel = Instance.new("TextLabel")
menuKeyLabel.Size = UDim2.new(1, -10, 1, 0)
menuKeyLabel.Position = UDim2.new(0, 10, 0, 0)
menuKeyLabel.BackgroundTransparency = 1
menuKeyLabel.Text = toggleMenuLabel
menuKeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
menuKeyLabel.Font = Enum.Font.Gotham
menuKeyLabel.TextSize = 14
menuKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
menuKeyLabel.Parent = menuKeyFrame

local espKeyFrame = Instance.new("Frame")
espKeyFrame.Size = UDim2.new(1, 0, 0, 30)
espKeyFrame.BackgroundTransparency = 1
espKeyFrame.Parent = ConfigContent

local espKeyLabel = Instance.new("TextLabel")
espKeyLabel.Size = UDim2.new(1, -10, 1, 0)
espKeyLabel.Position = UDim2.new(0, 10, 0, 0)
espKeyLabel.BackgroundTransparency = 1
espKeyLabel.Text = toggleESPLabel
espKeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
espKeyLabel.Font = Enum.Font.Gotham
espKeyLabel.TextSize = 14
espKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
espKeyLabel.Parent = espKeyFrame

-- Toggle do menu
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 280, 0, 35), "Out", "Quad", 0.3, true)
    MinimizeBtn.Visible = false
    MaximizeBtn.Visible = true
    Content.Visible = false
    TabContainer.Visible = false
end)

MaximizeBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0, 280, 0, 400), "Out", "Quad", 0.3, true)
    MaximizeBtn.Visible = false
    MinimizeBtn.Visible = true
    Content.Visible = true
    TabContainer.Visible = true
end)

-- Troca de abas
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
    CurrentTab = "Config"
    ConfigTab.BackgroundColor3 = Settings.ThemeColor
    ConfigTab.TextColor3 = Color3.new(1, 1, 1)
    ESPTab.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ESPTab.TextColor3 = Color3.fromRGB(180, 180, 180)
    ESPContent.Visible = false
    ConfigContent.Visible = true
end)

print("ESP Flee v4.5 carregado - Use RightControl para ligar/desligar")
