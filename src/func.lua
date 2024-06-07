---@meta _
---@diagnostic disable

function isTraitBanned(traitName)
    for k, v in pairs(game.CurrentRun.BannedTraits) do
        if traitName:match(k) then
            return true
        end
    end
    return false
end

function adjustRarityValues()
    game.TraitRarityData.BoonRarityRollOrder = { "Common", "Rare", "Epic", "Heroic", "Duo", "Legendary" }
    game.TraitRarityData.BoonRarityReverseRollOrder = { "Legendary", "Duo", "Heroic", "Epic", "Rare", "Common" }

    -- make sure everything is a number
    local min, rare, epic, heroic, duo, legendary, replace
    if type(config.MinimumRarity) == 'number' then
        min = config.MinimumRarity
    else
        min = 0
    end
    if type(config.RareChance) == 'number' then
        rare = math.min(config.RareChance / 100, 1)
    else
        rare = 10
    end
    if type(config.EpicChance) == 'number' then
        epic = math.min(config.EpicChance / 100, 1)
    else
        epic = 5
    end
    if type(config.HeroicChance) == 'number' then
        heroic = math.min(config.HeroicChance / 100, 1)
    else
        heroic = 0
    end
    if type(config.DuoChance) == 'number' then
        duo = math.min(config.DuoChance / 100, 1)
    else
        duo = 12
    end
    if type(config.LegendaryChance) == 'number' then
        legendary = math.min(config.LegendaryChance / 100, 1)
    else
        legendary = 10
    end
    if type(config.ReplaceChance) == 'number' then
        replace = math.min(config.ReplaceChance / 100, 1)
    else
        replace = 10
     end

    -- apply MinimumRarity overrides
    local hermes = config.HermesRarity
    if min == 1 then
        game.CurrentRun.Hero.BoonData.RarityChances.Rare = 1
        if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Rare = 1 end
    elseif min == 2 then
        game.CurrentRun.Hero.BoonData.RarityChances.Epic = 1
        if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Epic = 1 end
    elseif min == 3 then
        game.CurrentRun.Hero.BoonData.RarityChances.Heroic = 1
        if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Heroic = 1 end
    end
    -- apply Chance overrides
    if min == 0 then
        game.CurrentRun.Hero.BoonData.RarityChances.Rare = rare
        if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Rare = rare end
    end
    if min < 2 then
        game.CurrentRun.Hero.BoonData.RarityChances.Epic = epic
        if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Epic = epic end
    end
    if min < 3 then
        game.CurrentRun.Hero.BoonData.RarityChances.Heroic = heroic
        if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Heroic = heroic end
    end
    game.CurrentRun.Hero.BoonData.RarityChances.Duo = duo
    game.CurrentRun.Hero.BoonData.RarityChances.Legendary = legendary
    game.CurrentRun.Hero.BoonData.ReplaceChance = replace
    if hermes == true then game.CurrentRun.Hero.HermesData.RarityChances.Legendary = legendary end

    -- if hermes is unchecked, reset all the things
    if hermes == false then
        game.CurrentRun.Hero.HermesData.RarityChances.Rare = 0.06
        game.CurrentRun.Hero.HermesData.RarityChances.Epic = 0.03
        game.CurrentRun.Hero.HermesData.RarityChances.Heroic = 0
        game.CurrentRun.Hero.HermesData.RarityChances.Legendary = 0.01
    end
end

-- RoomLogic.IsRarityForcedCommon, GetRarityChances
-- CurrentRun.CurrentRoom.BoonRaritiesOverride