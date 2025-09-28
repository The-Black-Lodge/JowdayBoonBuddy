---@meta _
---@diagnostic disable

-- Track previous values to avoid unnecessary updates
local previousConfig = {
    MinimumRarity = nil,
    RareChance = nil,
    EpicChance = nil,
    HeroicChance = nil,
    LegendaryChance = nil,
    DuoChance = nil,
    ReplaceChance = nil,
    HermesRarity = nil,
    ArtemisRarity = nil,
    HadesRarity = nil,
    ChaosRarity = nil
}

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
    rom.ImGui.Text("Minimum boon rarity")

    value, pressed = rom.ImGui.RadioButton("Common##radio", config.MinimumRarity, 0)
    if pressed and value ~= previousConfig.MinimumRarity then
        config.MinimumRarity = value
        previousConfig.MinimumRarity = value
        adjustRarityValues()
    end

    rom.ImGui.SameLine()
    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0, 0.54, 1, 1)
    value, pressed = rom.ImGui.RadioButton("Rare##radio", config.MinimumRarity, 1)
    if pressed and value ~= previousConfig.MinimumRarity then
        config.MinimumRarity = value
        previousConfig.MinimumRarity = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.SameLine()
    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.62, 0.07, 1, 1)
    value, pressed = rom.ImGui.RadioButton("Epic##radio", config.MinimumRarity, 2)
    if pressed and value ~= previousConfig.MinimumRarity then
        config.MinimumRarity = value
        previousConfig.MinimumRarity = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.SameLine()
    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.97, 0.38, 0.35, 1)
    value, pressed = rom.ImGui.RadioButton("Heroic##radio", config.MinimumRarity, 3)
    if pressed and value ~= previousConfig.MinimumRarity then
        config.MinimumRarity = value
        previousConfig.MinimumRarity = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.Separator()
    rom.ImGui.Text("Base rarity chances")

    if config.MinimumRarity == 0 then
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0, 0.54, 1, 1)
        value, selected = rom.ImGui.SliderInt("Rare", config.RareChance, 0, 100, '%d%%')
        if selected and value ~= previousConfig.RareChance then
            config.RareChance = value
            previousConfig.RareChance = value
            adjustRarityValues()
        end
        rom.ImGui.PopStyleColor()
    end

    if config.MinimumRarity < 2 then
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.62, 0.07, 1, 1)
        value, selected = rom.ImGui.SliderInt("Epic", config.EpicChance, 0, 100, '%d%%')
        if selected and value ~= previousConfig.EpicChance then
            config.EpicChance = value
            previousConfig.EpicChance = value
            adjustRarityValues()
        end
        rom.ImGui.PopStyleColor()
    end

    if config.MinimumRarity < 3 then
        rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.97, 0.38, 0.35, 1)
        value, selected = rom.ImGui.SliderInt("Heroic", config.HeroicChance, 0, 100, '%d%%')
        if selected and value ~= previousConfig.HeroicChance then
            config.HeroicChance = value
            previousConfig.HeroicChance = value
            adjustRarityValues()
        end
        rom.ImGui.PopStyleColor()
    end

    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 1, 0.56, 0, 1)
    value, selected = rom.ImGui.SliderInt("Legendary", config.LegendaryChance, 0, 100, '%d%%')
    if selected and value ~= previousConfig.LegendaryChance then
        config.LegendaryChance = value
        previousConfig.LegendaryChance = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    rom.ImGui.PushStyleColor(rom.ImGuiCol.Text, 0.82, 1, 0.38, 1)
    value, selected = rom.ImGui.SliderInt("Duo", config.DuoChance, 0, 100, '%d%%')
    if selected and value ~= previousConfig.DuoChance then
        config.DuoChance = value
        previousConfig.DuoChance = value
        adjustRarityValues()
    end
    rom.ImGui.PopStyleColor()

    value, selected = rom.ImGui.SliderInt("Sacrifice", config.ReplaceChance, 0, 100, '%d%%')
    if selected and value ~= previousConfig.ReplaceChance then
        config.ReplaceChance = value
        previousConfig.ReplaceChance = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Hermes",
        config.HermesRarity)
    if checked and value ~= previousConfig.HermesRarity then
        config.HermesRarity = value
        previousConfig.HermesRarity = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Artemis",
        config.ArtemisRarity)
    if checked and value ~= previousConfig.ArtemisRarity then
        config.ArtemisRarity = value
        previousConfig.ArtemisRarity = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Hades",
        config.HadesRarity)
    if checked and value ~= previousConfig.HadesRarity then
        config.HadesRarity = value
        previousConfig.HadesRarity = value
        adjustRarityValues()
    end

    value, checked = rom.ImGui.Checkbox("Apply to Chaos (Max Epic)",
        config.ChaosRarity)
    if checked and value ~= previousConfig.ChaosRarity then
        config.ChaosRarity = value
        previousConfig.ChaosRarity = value
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
        
        -- Update previous config values to match reset values
        previousConfig.MinimumRarity = config.MinimumRarity
        previousConfig.RareChance = config.RareChance
        previousConfig.EpicChance = config.EpicChance
        previousConfig.HeroicChance = config.HeroicChance
        previousConfig.LegendaryChance = config.LegendaryChance
        previousConfig.DuoChance = config.DuoChance
        previousConfig.ReplaceChance = config.ReplaceChance
        previousConfig.HermesRarity = config.HermesRarity
        previousConfig.ArtemisRarity = config.ArtemisRarity
        previousConfig.ChaosRarity = config.ChaosRarity
        previousConfig.HadesRarity = config.HadesRarity
        
        adjustRarityValues()
    end

    if rom.ImGui.CollapsingHeader("Infusions") then
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
    end

    if rom.ImGui.CollapsingHeader("Miscellaneous") then
        value, checked = rom.ImGui.Checkbox("Always allow Book of Shadows during boon selection",
            config.AlwaysAllowed)
        if checked then
            config.AlwaysAllowed = value
            updateBoonListRequirements()
        end
    end

    local mods = rom.mods
    local compatibleMods = 0

    -- perfectoinist plugin
    local perfectMod = mods['Jowday-Perfectoinist']
    if perfectMod then compatibleMods = compatibleMods + 1 end

    if compatibleMods > 0 then
        if rom.ImGui.CollapsingHeader("Plugins") then
            if perfectMod then
                perfectMod.drawPerfectPlugin()
            end
        end
    end
end
