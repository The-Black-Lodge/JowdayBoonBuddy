---@meta _
---@diagnostic disable

function setBannedProps(textArgs)
    textArgs.Color = game.Color.DarkRed
    textArgs.ShadowBlur = 0
    textArgs.ShadowColor = game.Color.Black
    textArgs.ShadowOffset = { 0, 1 }
end

function isTraitBanned(traitName)
    if game.CurrentRun.BannedTraits[traitName] then return true end
    return false
end

function getInfusionGameStateRequirements()
    for traitName, vals in pairs(game.TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            InfusionGameStateRequirements[traitName] = game.DeepCopyTable(vals.GameStateRequirements)
        end
    end

    if config.InfusionWhenRequirementsMet == true then
        overrideInfusionGameStateRequirements()
    end
end

function overrideInfusionGameStateRequirements()
    for traitName, vals in pairs(game.TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            game.TraitData[traitName].GameStateRequirements = game.DeepCopyTable(vals.ActivationRequirements)
        end
    end
end

function revertInfusionGameStateRequirements()
    for traitName, vals in pairs(game.TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            game.TraitData[traitName].GameStateRequirements = game.DeepCopyTable(InfusionGameStateRequirements
            [traitName])
        end
    end
end

function getEligibleElementalTrait(traits, options)
    -- pretty sure options can never be nil, but just in case
    if traits == nil or options == nil then return nil end

    -- check for an elemental trait
    local elementalTrait = nil
    for _, traitName in ipairs(traits) do
        if game.TraitData[traitName].IsElementalTrait then
            elementalTrait = traitName
        end
    end

    -- did we find anything?
    if elementalTrait == nil then return nil end

    -- check if we have it already
    if game.HeroHasTrait(elementalTrait) then return nil end

    -- check if it was banned
    if isTraitBanned(elementalTrait) then return nil end

    -- check for elemental requirement
    local requirements = game.TraitData[elementalTrait].GameStateRequirements
    local eligible = game.IsGameStateEligible(game.CurrentRun, requirements)
    if eligible == false then return nil end

    -- check that it isn't already being offered
    local offered = false
    for _, trait in ipairs(options) do
        if trait.ItemName == elementalTrait then offered = true end
    end
    if offered == true then return end

    return elementalTrait
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

-- UpgradeChoiceData:340
function updateBoonListRequirements()
    if config.AlwaysAllowed == true then
        game.ScreenData.UpgradeChoice.ComponentData.ActionBarLeft.Children.BoonListButton["Requirements"] = {}
    else
        game.ScreenData.UpgradeChoice.ComponentData.ActionBarLeft.Children.BoonListButton["Requirements"] = { { PathTrue = { "GameState", "WorldUpgrades", "WorldUpgradeBoonList" } } }
    end
end
