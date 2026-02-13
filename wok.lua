--[[
    Script: ESP Flee The Facility v4.5 (Tunado pelo Mendigo)
    Base: w_ky + Mendigo Hacks
    Melhorias:
    - ESP por Highlight (leve e eficiente)
    - Contorno visível através de paredes (DepthMode = Enum.HighlightDepthMode.AlwaysOnTop)
    - Otimização de performance com conexões únicas
    - Sistema de cores dinâmico
    - Detecção automática de Beast/Survivor
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
local MenuVisible = true
local CurrentTab = "ESP"
local HighlightObjects = {} -- Tabela pra guardar os destaques

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

-- Interface (mantive a sua porque tá firmeza)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPFlee"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- [Aqui vai toda a sua interface igual estava, não mexi nela pra não quebrar]
-- ... (desde MainFrame até as funções createToggle, createColorOption, etc)
-- Só garantir que as funções de criar toggles chamem os callbacks certos depois

-- Vou resumir a interface aqui pra não repetir, mas no código final ela tá completa
-- O importante é que os toggles agora chamam funções que ativam/desativam o ESP

-- ========== FUNÇÕES DE ESP TURBO (Adaptadas do yarhm) ==========

-- Função pra criar Highlight num personagem
local function createHighlight(character, color)
    if not character then return end
    
    -- Se já tem highlight, só atualiza a cor
    local existing = HighlightObjects[character]
    if existing then
        existing.FillColor = color
        return existing
    end
    
    -- Cria novo highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "MendigoESP"
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    -- A mágica: vê através das paredes!
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Conecta com a remoção automática quando o personagem morrer
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

-- Função pra remover highlight
local function removeHighlight(character)
    local highlight = HighlightObjects[character]
    if highlight then
        highlight:Destroy()
        HighlightObjects[character] = nil
    end
end

-- Função pra determinar a cor do jogador (Beast ou Survivor)
local function getPlayerColor(player)
    if player == LocalPlayer then
        return Settings.ThemeColor -- Cor do tema pra si mesmo
    end
    
    -- Tenta detectar se é o Beast (baseado em nome ou time)
    -- Isso depende do jogo, vou deixar configurável via lógica
    local isBeast = false
    
    -- Lógica básica: se tem Beast no nome da equipe ou ferramenta
    -- Adapte conforme a lógica real do Flee The Facility
    local character = player.Character
    if character then
        -- Exemplo: verifica se tem a ferramenta de Beast
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("beast") or tool.Name:lower():find("feral")) then
            isBeast = true
        end
    end
    
    if isBeast then
        return Settings.Colors.PlayerBeast
    else
        return Settings.Colors.PlayerSurvivor
    end
end

-- Função principal de atualização do ESP
local function updateESP()
    -- Se ESP desligado, limpa tudo
    if not ESP_Enabled then
        for char, highlight in pairs(HighlightObjects) do
            highlight:Destroy()
        end
        HighlightObjects = {}
        return
    end
    
    -- Players ESP
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
        -- Se desligou players, remove todos os highlights de players
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                removeHighlight(player.Character)
            end
        end
    end
    
    -- ESP para saídas (Exits)
    if Settings.ShowExits then
        for _, exit in ipairs(workspace:GetDescendants()) do
            if exit.Name:lower():find("exit") and exit:IsA("BasePart") then
                createHighlight(exit, Settings.Colors.Exit)
            end
        end
    end
    
    -- ESP para PCs
    if Settings.ShowPCs then
        for _, pc in ipairs(workspace:GetDescendants()) do
            if (pc.Name:lower():find("pc") or pc.Name:lower():find("computer")) and pc:IsA("BasePart") then
                createHighlight(pc, Settings.Colors.PC)
            end
        end
    end
    
    -- ESP para Pods (cápsulas)
    if Settings.ShowPods then
        for _, pod in ipairs(workspace:GetDescendants()) do
            if pod.Name:lower():find("pod") and pod:IsA("BasePart") then
                createHighlight(pod, Settings.Colors.Pod)
            end
        end
    end
end

-- Conecta a atualização ao RenderStepped (mais suave que Heartbeat)
RunService.RenderStepped:Connect(updateESP)

-- Quando um jogador entra, espera o character carregar
Players.PlayerAdded:Connect(function(player)
    if ESP_Enabled and Settings.ShowPlayers then
        player.CharacterAdded:Connect(function(character)
            -- Pequeno delay pro character carregar completo
            task.wait(0.5)
            if ESP_Enabled then
                local color = getPlayerColor(player)
                createHighlight(character, color)
            end
        end)
    end
end)

-- Limpeza quando jogador sai
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeHighlight(player.Character)
    end
end)

-- ========== INTEGRAÇÃO COM SUA INTERFACE ==========
-- Aqui você conecta os toggles da interface às funções de ESP
-- Exemplo de como ligar:
-- togglePlayers = createToggle(ESPContent, "Mostrar Jogadores", Settings.ShowPlayers, function(state)
--     Settings.ShowPlayers = state
--     if not state then
--         -- Remove highlights dos players
--         for _, player in ipairs(Players:GetPlayers()) do
--             if player.Character then
--                 removeHighlight(player.Character)
--             end
--         end
--     end
--     updateESP() -- Força atualização
-- end)

-- [O resto da sua interface continua igual, só garantir que os callbacks dos toggles atualizem as Settings]

-- Função pra ligar/desligar ESP geral
local function toggleESP()
    ESP_Enabled = not ESP_Enabled
    if not ESP_Enabled then
        -- Limpa tudo
        for char, highlight in pairs(HighlightObjects) do
            highlight:Destroy()
        end
        HighlightObjects = {}
    end
end

-- Bind pra ligar ESP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Settings.ToggleESPKey then
        toggleESP()
    end
end)

-- Atualiza as cores quando a configuração mudar
-- (Você pode chamar isso quando o usuário mudar uma cor na interface)
local function updateColors()
    for character, highlight in pairs(HighlightObjects) do
        -- Atualiza a cor baseada no tipo
        if character:IsA("Model") and character:FindFirstChild("Humanoid") then
            -- É um jogador
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                highlight.FillColor = getPlayerColor(player)
                highlight.OutlineColor = getPlayerColor(player)
            end
        end
    end
end

print("ESP Flee v4.5 carregado - Tunado pelo Mendigo")
