---@meta _
---@diagnostic disable

function getDefaults()
    for traitName, vals in pairs(game.TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            DefaultInfusionGameStateRequirements[traitName] = game.DeepCopyTable(vals.GameStateRequirements)
        end
    end

    DefaultBoonRarity = game.HeroData.BoonData.RarityChances
    DefaultHermesRarity = game.HeroData.HermesData.RarityChances
    DefaultReplaceChance = game.HeroData.BoonData.ReplaceChance
    DefaultArtemisRarity = game.DeepCopyTable(game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances)
    DefaultArtemisRollOrder = game.DeepCopyTable(game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder)
    DefaultHadesRarity = game.DeepCopyTable(game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances)
    DefaultHadesRollOrder = game.DeepCopyTable(game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder)
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
            game.TraitData[traitName].GameStateRequirements = game.DeepCopyTable(DefaultInfusionGameStateRequirements
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
    -- adds Heroic to the rolls
    local rarityOrder = { "Common", "Rare", "Epic", "Heroic", "Duo", "Legendary", "Perfect" }
    game.TraitRarityData.BoonRarityRollOrder = rarityOrder
    game.TraitRarityData.BoonRarityReverseRollOrder = { "Perfect", "Legendary", "Duo", "Heroic", "Epic", "Rare", "Common" }
    game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder = rarityOrder
    game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder = rarityOrder

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
        rare = DefaultBoonRarity.Rare * 100
    end
    if type(config.EpicChance) == 'number' then
        epic = math.min(config.EpicChance / 100, 1)
    else
        epic = DefaultBoonRarity.Epic * 100
    end
    if type(config.HeroicChance) == 'number' then
        heroic = math.min(config.HeroicChance / 100, 1)
    else
        heroic = 0
    end
    if type(config.DuoChance) == 'number' then
        duo = math.min(config.DuoChance / 100, 1)
    else
        duo = DefaultBoonRarity.Duo * 100
    end
    if type(config.LegendaryChance) == 'number' then
        legendary = math.min(config.LegendaryChance / 100, 1)
    else
        legendary = DefaultBoonRarity.Legendary * 100
    end
    if type(config.ReplaceChance) == 'number' then
        replace = math.min(config.ReplaceChance / 100, 1)
    else
        replace = DefaultReplaceChance * 100
    end

    -- apply MinimumRarity overrides
    local hermes = config.HermesRarity
    local artemis = config.ArtemisRarity
    local hades = config.HadesRarity

    local rarityTable = {}

    -- insert slider values
    rarityTable.Rare = rare
    rarityTable.Epic = epic
    rarityTable.Heroic = heroic
    rarityTable.Duo = duo
    rarityTable.Legendary = legendary
    rarityTable.Perfect = 1

    -- apply overrides
    if min == 1 then rarityTable.Rare = 1 end
    if min == 2 then rarityTable.Epic = 1 end
    if min == 3 then rarityTable.Heroic = 1 end

    -- apply to regular boons
    game.CurrentRun.Hero.BoonData.RarityChances = rarityTable

    -- apply to friends
    if hermes == true then
        game.CurrentRun.Hero.HermesData.RarityChances = rarityTable
    else
        game.CurrentRun.Hero.HermesData.RarityChances = game.DeepCopyTable(DefaultHermesRarity)
    end
    if artemis == true then
        game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances = rarityTable
    else
        game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances = game.DeepCopyTable(DefaultArtemisRarity)
        game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder = game.DeepCopyTable(DefaultArtemisRollOrder)
    end
    -- this doesn't do anything currently - see the GetRarityChances wrap
    if hades == true then
        game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances = rarityTable
    else
        game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances = game.DeepCopyTable(DefaultHadesRarity)
        game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder = game.DeepCopyTable(DefaultHadesRollOrder)
    end
end

function revertDefaultRarity()
    game.CurrentRun.Hero.BoonData = game.DeepCopyTable(game.HeroData.BoonData)
    game.CurrentRun.Hero.HermesData = game.DeepCopyTable(game.HeroData.HermesData)
end

-- vow of forsaking functions
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

-- offerings button override functions
-- UpgradeChoiceData:340
function updateBoonListRequirements()
    if config.AlwaysAllowed == true then
        game.ScreenData.UpgradeChoice.ComponentData.ActionBarLeft.Children.BoonListButton["Requirements"] = {}
    else
        game.ScreenData.UpgradeChoice.ComponentData.ActionBarLeft.Children.BoonListButton["Requirements"] = { { PathTrue = { "GameState", "WorldUpgrades", "WorldUpgradeBoonList" } } }
    end
end
