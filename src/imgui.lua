---@meta _
---@diagnostic disable

rom.gui.add_imgui(function()
    if rom.ImGui.Begin("BoonBuddy") then
        drawMenu()
        rom.ImGui.End()
    end
end)

rom.gui.add_to_menu_bar(function()
    if rom.ImGui.BeginMenu("Configure") then
        drawMenu()
        rom.ImGui.EndMenu()
    end
end)

function drawMenu()
    value, checked = rom.ImGui.Checkbox("Always allow Book of Shadows during boon selection",
        config.AlwaysAllowed)
    if checked then
        config.AlwaysAllowed = value
        updateBoonListRequirements()
    end

    rom.ImGui.Separator()

    rom.ImGui.Text("Minimum boon rarity")

    value, pressed = rom.ImGui.RadioButton("Common##radio", config.MinimumRarity, 0)
    if pressed then
        config.MinimumRarity = value
        adjustRarityValues()
    end

    rom.ImGui.SameLine()
    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0, 0.54, 1, 1)
    value, pressed = rom.ImGui.RadioButton("Rare##radio", config.MinimumRarity, 1)
    if pressed then
        config.MinimumRarity = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.SameLine()
    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.62, 0.07, 1, 1)
    value, pressed = rom.ImGui.RadioButton("Epic##radio", config.MinimumRarity, 2)
    if pressed then
        config.MinimumRarity = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.SameLine()
    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.97, 0.38, 0.35, 1)
    value, pressed = rom.ImGui.RadioButton("Heroic##radio", config.MinimumRarity, 3)
    if pressed then
        config.MinimumRarity = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.Separator()
    rom.ImGui.Text("Base rarity chances")

    if config.MinimumRarity == 0 then
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0, 0.54, 1, 1)
        value, selected = rom.ImGui.SliderInt("Rare", config.RareChance, 0, 100, '%d%%')
        if selected then
            config.RareChance = value
            adjustRarityValues()
        end
        rom.ImGui.PopStyleColor()
    end

    if config.MinimumRarity < 2 then
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.62, 0.07, 1, 1)
        value, selected = rom.ImGui.SliderInt("Epic", config.EpicChance, 0, 100, '%d%%')
        if selected then
            config.EpicChance = value
            adjustRarityValues()
        end
        rom.ImGui.PopStyleColor()
    end

    if config.MinimumRarity < 3 then
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.97, 0.38, 0.35, 1)
        value, selected = rom.ImGui.SliderInt("Heroic", config.HeroicChance, 0, 100, '%d%%')
        if selected then
            config.HeroicChance = value
            adjustRarityValues()
        end
        rom.ImGui.PopStyleColor()
    end

    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 1, 0.56, 0, 1)
    value, selected = rom.ImGui.SliderInt("Legendary", config.LegendaryChance, 0, 100, '%d%%')
    if selected then
        config.LegendaryChance = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.82, 1, 0.38, 1)
    value, selected = rom.ImGui.SliderInt("Duo", config.DuoChance, 0, 100, '%d%%')
    if selected then
        config.DuoChance = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    value, selected = rom.ImGui.SliderInt("Sacrifice", config.ReplaceChance, 0, 100, '%d%%')
    if selected then
        config.ReplaceChance = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Hermes",
        config.HermesRarity)
    if checked then
        config.HermesRarity = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Artemis",
        config.ArtemisRarity)
    if checked then
        config.ArtemisRarity = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Hades",
        config.HadesRarity)
    if checked then
        config.HadesRarity = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Chaos (Max Epic)",
        config.ChaosRarity)
    if checked then
        config.ChaosRarity = value
        adjustRarityValues()
    end

    -- this appears to be problematic
    -- value, checked = rom.ImGui.Checkbox("Allow increased rarity on new saves",
    -- config.NewSaveOverride)
    -- if checked then
    --     config.NewSaveOverride = value
    --     adjustRarityValues()
    -- end

    reset = rom.ImGui.Button("Reset rarity")
    if reset then
        config.MinimumRarity = 0
        config.RareChance = DefaultBoonRarity.Rare * 100
        config.EpicChance = DefaultBoonRarity.Epic * 100
        config.HeroicChance = 0
        config.LegendaryChance = DefaultBoonRarity.Legendary * 100
        config.DuoChance = DefaultBoonRarity.Duo * 100
        config.ReplaceChance = DefaultReplaceChance * 100
        config.HermesRarity = false
        config.ArtemisRarity = false
        config.ChaosRarity = false
        config.HadesRarity = false
        config.NewSaveOverride = false
        adjustRarityValues()
    end

    rom.ImGui.Separator()

    rom.ImGui.Text("Infusions")

    value, checked = rom.ImGui.Checkbox("Customize Infusion behavior",
        config.InfusionOverride)
    if checked then
        config.InfusionOverride = value
        if value == false then
            config.OnlyOfferInfusionWhenActivated = false
            config.OnlyApplyInfusionChanceWhenActivated = false
            revertInfusionGameStateRequirements()
        end
    end

    if config.InfusionOverride == true then
        value, checked = rom.ImGui.Checkbox("Only offer Infusions when activation requirements are met",
            config.OnlyOfferInfusionWhenActivated)
        if checked then
            config.OnlyOfferInfusionWhenActivated = value
            if value == true then
                overrideInfusionGameStateRequirements()
            else
                revertInfusionGameStateRequirements()
            end
        end

        if config.OnlyOfferInfusionWhenActivated == false then
            value, checked = rom.ImGui.Checkbox("Only apply % chance when activation requirements are met",
                config.OnlyApplyInfusionChanceWhenActivated)
            if checked then
                config.OnlyApplyInfusionChanceWhenActivated = value
            end
        end

        if config.InfusionOverride == true then
            rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 1, 0.29, 1, 1)
            value, selected = rom.ImGui.SliderInt("Infusion", config.InfusionChance, 0, 100, '%d%%')
            if selected then
                config.InfusionChance = value
            end
            rom.ImGui.PopStyleColor()
        end
    end

    local mods = rom.mods
    -- perfectoinist plugin
    local perfectMod = mods['Jowday-Perfectoinist']
    if perfectMod then
        rom.ImGui.Separator()
        rom.ImGui.Text("PLUGINS")
        perfectMod.drawPerfectPlugin()
    end
end
