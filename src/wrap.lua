---@meta _
---@diagnostic disable

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
            game.SetAlpha({ Id = button.Id, Duration = 0.1, Fraction = 0.5 })

            -- figure out strikethrough effect some other time
            -- local strike = game.CreateScreenComponent({ Name = "rectangle01", X = button.X, Y = button.Y })
            -- game.SetColor({ Id = strike.Id, Color = game.Color.DarkRed })
            -- game.SetScaleY({ Id = strike.Id, Fraction = 0.01 })
            -- game.Attach({ Id = strike.Id, DestinationId = button.Id, OffsetY = -5 })
        end
        base(screen, button)
    end)
end)
