---@meta _
---@diagnostic disable

-- Create the global mod object if it doesn't exist
if not JowdayBoonBuddy then
    JowdayBoonBuddy = {}
end

local mod = JowdayBoonBuddy

-- Initialize default game values
mod.DefaultInfusionGameStateRequirements = {}
mod.DefaultInfusionActivationRequirements = {}
mod.DefaultBoonRarity = {}
mod.DefaultHermesRarity = {}
mod.DefaultReplaceChance = 0.1
mod.DefaultArtemisRarity = {}
mod.DefaultArtemisRollOrder = {}
mod.DefaultHadesRarity = {}
mod.DefaultHadesRollOrder = {}
mod.DefaultChaosRarity = {}
mod.DefaultRarityOrder = {}
mod.DefaultRarityReverseOrder = {}
mod.DefaultRarityUpgradeOrder = {}

-- UseLoot wrap for infusion boon replacement
ModUtil.Path.Wrap("UseLoot", function(base, usee, args, user)
    if mod.Config.InfusionOverride == true then
        local elementalTrait, eligible, activated = mod.getEligibleElementalTrait(usee.Traits, usee.UpgradeOptions)
        -- if we got something back, check if we should replace one of the offered boons
        if elementalTrait ~= nil then
            -- only roll if: apply % when activated + activated, OR apply % when activated is unchecked
            if (mod.Config.OnlyApplyInfusionChanceWhenActivated == true and activated == true) or
                (mod.Config.OnlyApplyInfusionChanceWhenActivated == false and eligible == true)
            then
                -- check if we have replaceable traits, and get their indices
                local replaceableIndices = mod.getReplaceableIndices(usee.UpgradeOptions)
                if #replaceableIndices > 0 then
                    -- set a seed because the in-game rng is weird
                    math.randomseed(GetTime())
                    local random = math.random(100)
                    -- roll the dice
                    if mod.Config.InfusionChance > random then
                        -- get a random index in the table
                        local replaceIndex = replaceableIndices[math.random(#replaceableIndices)]
                        -- finally replace the thing
                        usee.UpgradeOptions[replaceIndex] = {
                            ItemName = elementalTrait,
                            Type = "Trait",
                            Rarity = "Common"
                        }
                    end
                end
            end
        end
    end
    return base(usee, args, user)
end)

-- GetBoonRarityChances wrap for rarity modifications
ModUtil.Path.Wrap("GetBoonRarityChances", function(base, args)
    if mod.Config.enabled == false then return base(args) end
    
    local result = base(args)
    
    -- Apply rarity modifications
    if mod.Config.AlwaysAllowed == true then
        result.MinimumRarity = mod.Config.MinimumRarity
    end
    
    if mod.Config.RareChance ~= nil then
        result.RareChance = mod.Config.RareChance
    end
    if mod.Config.EpicChance ~= nil then
        result.EpicChance = mod.Config.EpicChance
    end
    if mod.Config.HeroicChance ~= nil then
        result.HeroicChance = mod.Config.HeroicChance
    end
    if mod.Config.LegendaryChance ~= nil then
        result.LegendaryChance = mod.Config.LegendaryChance
    end
    if mod.Config.DuoChance ~= nil then
        result.DuoChance = mod.Config.DuoChance
    end
    
    return result
end)

-- Run on game load
OnAnyLoad { function()
    if mod.Config.enabled then
        mod.getDefaults()
        mod.adjustRarityValues()
        mod.updateBoonListRequirements()
        if mod.Config.OnlyOfferInfusionWhenActivated == true then
            mod.overrideInfusionGameStateRequirements()
        end
    end
end }