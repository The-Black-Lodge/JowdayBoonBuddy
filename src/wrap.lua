---@meta _
---@diagnostic disable

modutil.mod.Path.Wrap("OpenUpgradeChoiceMenu", function(base, source, args)
    local name = source.Name or nil
    if name ~= nil then
        currentGod = name
        -- get entries here, to be used later
        entries = setCodexVarsReturnEntries(name)
    end
    if entries ~= nil then
        -- update the alpha on the boon button
        game.ScreenData.UpgradeChoice.ComponentData.ActionBar.Children.BoonInfoButton["Alpha"] = 1.0
    end
    base(source, args)
end)

modutil.mod.Path.Wrap("AttemptOpenCodexBoonInfo", function(base, codexScreen, button)
    if entries ~= nil then
        -- copy over the real close button
        codexScreen.Components["CloseButton"] = game.DeepCopyTable(CloseButton)
    end
    base(codexScreen, button)
end)

modutil.mod.Path.Wrap("BoonInfoPopulateTraits", function(base, screen)
    if currentGod ~= nil then
        -- more trickery
        screen.CodexScreen["OpenEntryName"] = currentGod
        screen.LootName = currentGod
    end
    base(screen)
end)

modutil.mod.Path.Wrap("CodexUpdateVisibility", function(base, screen, args)
    if currentGod ~= nil then
        screen.ActiveEntries = entries
        screen.NumItems = #entries
        screen.ScrollOffset = 0
        screen.MaxVisibleEntries = 11 -- magic-ish number (CodexData.lua:45)
        args = { IgnoreArrows = true }
    end
    base(screen, args)
end)

modutil.mod.Path.Wrap("CloseUpgradeChoiceScreen", function(base, screen, button)
    -- cleanup the stuff we inserted
    if currentGod ~= nil then
        game.ScreenData.UpgradeChoice.ComponentData.ActionBar.Children.BoonInfoButton["Alpha"] = 0.0
    end
    currentGod = nil
    entries = nil
    base(screen, button)
end)

modutil.mod.Path.Context.Wrap("CreateTraitRequirementList", function()
    modutil.mod.Path.Wrap("CreateTextBox", function(base, textArgs)
        -- only the traits have a LuaValue here
        if textArgs.LuaValue ~= nil then
            traitName = textArgs.LuaValue.TraitName

            if isTraitBanned(traitName) == true then
                setBannedProps(textArgs)
            end
        end

        base(textArgs)
    end)
end)

modutil.mod.Path.Context.Wrap("CreateBoonInfoButton", function(screen, traitName, index)
    modutil.mod.Path.Wrap("CreateTextBox", function(base, textArgs)
        -- args with Name are actually the description text here
        if isTraitBanned(traitName) == true and textArgs.Name == nil then
            setBannedProps(textArgs)
        end
        base(textArgs)
    end)

    modutil.mod.Path.Wrap("BoonInfoScreenUpdateTooltipToggle", function(base, screen, button)
        if isTraitBanned(button.TraitData.Name) then
            game.SetAlpha({Id = button.Id, Duration = 0.1, Fraction = 0.5})

            -- figure out strikethrough effect some other time
            -- local strike = game.CreateScreenComponent({ Name = "rectangle01", X = button.X, Y = button.Y })
            -- game.SetColor({ Id = strike.Id, Color = game.Color.DarkRed })
            -- game.SetScaleY({ Id = strike.Id, Fraction = 0.01 })
            -- game.Attach({ Id = strike.Id, DestinationId = button.Id, OffsetY = -5 })
        end
        base(screen, button)
    end)
end)
