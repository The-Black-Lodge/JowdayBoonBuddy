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

modutil.mod.Path.Wrap("UseLoot", function(base, usee, args, user)
    if config.InfusionOverride == true then
        local elementalTrait, eligible, activated = getEligibleElementalTrait(usee.Traits, usee.UpgradeOptions)
        -- if we got something back, check if we should replace one of the offered boons
        if elementalTrait ~= nil then
            -- only roll if: apply % when activated + activated, OR apply % when activated is unchecked
            if (config.OnlyApplyInfusionChanceWhenActivated == true and activated == true) or
                (config.OnlyApplyInfusionChanceWhenActivated == false and eligible == true)
            then
                -- check if we have replaceable traits, and get their indices
                local replaceableIndices = getReplaceableIndices(usee.UpgradeOptions)
                if #replaceableIndices > 0 then
                    -- set a seed because the in-game rng is weird
                    math.randomseed(game.GetTime())
                    local random = math.random(100)
                    -- roll the dice
                    if config.InfusionChance > random then
                        -- get a random index in the table
                        local replaceIndex = replaceableIndices[math.random(#replaceableIndices)]
                        -- finally replace the thing
                        usee.UpgradeOptions[replaceIndex] = { ItemName = elementalTrait, Type = "Trait", Rarity =
                        "Common" }
                    end
                end
            end
        end
    end
    base(usee, args, user)
end)

-- prevent changes from tainting save data
modutil.mod.Path.Wrap("SaveCheckpoint", function(base, args)
    revertDefaultRarity()
    base(args)
    adjustRarityValues()
end)

modutil.mod.Path.Wrap("IsRarityForcedCommon", function(base, name, args)
    -- override this in most cases
    if name == "StackUpgrade" then
        return true
    elseif name == "WeaponUpgrade" then
        return true
    end
    return false
end)

modutil.mod.Path.Wrap("GetRarityChances", function(base, loot)
    -- in the real code, Daddy appears to inadvertently use BoonData rarity despite having his own rarity table and roll order. possibly a bug
    if loot.Name == 'NPC_Hades_Field_01' and config.HadesRarity == false then return DefaultHadesRarity end

    return base(loot)
end)
