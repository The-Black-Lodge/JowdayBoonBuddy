---@meta _
---@diagnostic disable

rom.gui.add_to_menu_bar(function()
    if rom.ImGui.BeginMenu("Configure") then
        -- implement later
        -- value, checked = rom.ImGui.Checkbox("Always allow Book of Shadows during boon selection",
        --     config.AlwaysAllowed)
        -- if checked then
        --     config.AlwaysAllowed = value
        -- end

        -- rom.ImGui.Separator()

        rom.ImGui.Text("Minimum boon rarity:")

        value, pressed = rom.ImGui.RadioButton("Common", config.MinimumRarity, 0)
        if pressed then
            config.MinimumRarity = value
            adjustRarityRolls()
         end

        rom.ImGui.SameLine()
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0, 0.54, 1, 1)
        value, pressed = rom.ImGui.RadioButton("Rare", config.MinimumRarity, 1)
        if pressed then
            config.MinimumRarity = value
            adjustRarityRolls()
 end
        rom.ImGui.PopStyleColor()

        rom.ImGui.SameLine()
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.62, 0.07, 1, 1)
        value, pressed = rom.ImGui.RadioButton("Epic", config.MinimumRarity, 2)
        if pressed then
            config.MinimumRarity = value
            adjustRarityRolls()
 end
        rom.ImGui.PopStyleColor()

        rom.ImGui.SameLine()
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.97, 0.38, 0.35, 1)
        value, pressed = rom.ImGui.RadioButton("Heroic", config.MinimumRarity, 3)
        if pressed then
            config.MinimumRarity = value
            adjustRarityRolls()
 end
        rom.ImGui.PopStyleColor()

        rom.ImGui.Separator()
        rom.ImGui.Text("Base rarity chances:")

        if config.MinimumRarity == 0 then
            rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0, 0.54, 1, 1)
            value, selected = rom.ImGui.SliderInt("% Rare", config.RareChance, 0, 100)
            if selected then
                config.RareChance = value
                adjustRarityRolls()
 end
            rom.ImGui.PopStyleColor()
        end

        if config.MinimumRarity < 2 then
            rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.62, 0.07, 1, 1)
            value, selected = rom.ImGui.SliderInt("% Epic", config.EpicChance, 0, 100)
            if selected then
                config.EpicChance = value
                adjustRarityRolls()
 end
            rom.ImGui.PopStyleColor()
        end

        if config.MinimumRarity < 3 then
            rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.97, 0.38, 0.35, 1)
            value, selected = rom.ImGui.SliderInt("% Heroic", config.HeroicChance, 0, 100)
            if selected then
                config.HeroicChance = value
                adjustRarityRolls()
 end
            rom.ImGui.PopStyleColor()
        end

        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 1, 0.56, 0, 1)
        value, selected = rom.ImGui.SliderInt("% Legendary", config.LegendaryChance, 0, 100)
        if selected then
            config.LegendaryChance = value
            adjustRarityRolls()
 end
        rom.ImGui.PopStyleColor()

        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.82, 1, 0.38, 1)
        value, selected = rom.ImGui.SliderInt("% Duo", config.DuoChance, 0, 100)
        if selected then
            config.DuoChance = value
            adjustRarityRolls()
 end
        rom.ImGui.PopStyleColor()

        reset = rom.ImGui.Button("Reset boon rarity")
        if reset then
            config.MinimumRarity = 0
            config.RareChance = 10
            config.EpicChance = 5
            config.HeroicChance = 0
            config.LegendaryChance = 10
            config.DuoChance = 12
            adjustRarityRolls()
        end

        rom.ImGui.EndMenu()
    end
end)
