-- No lugar onde você cria o toggle de Players
createToggle(ESPContent, "Mostrar Jogadores", Settings.ShowPlayers, function(state)
    Settings.ShowPlayers = state
    if not state then
        -- Remove highlights dos players
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                removeHighlight(player.Character)
            end
        end
    end
end)
