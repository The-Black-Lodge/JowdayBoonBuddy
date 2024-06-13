---@meta _
---@diagnostic disable

function getDefaults()
    for traitName, vals in pairs(game.TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            DefaultInfusionGameStateRequirements[traitName] = game.DeepCopyTable(vals.GameStateRequirements)
        end
    end

    for traitName, vals in pairs(game.TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            DefaultInfusionActivationRequirements[traitName] = game.DeepCopyTable(vals.ActivationRequirements)
        end
    end

    DefaultBoonRarity = game.ShallowCopyTable(game.HeroData.BoonData.RarityChances)
    DefaultHermesRarity = game.ShallowCopyTable(game.HeroData.HermesData.RarityChances)
    DefaultReplaceChance = game.HeroData.BoonData.ReplaceChance
    DefaultArtemisRarity = game.ShallowCopyTable(game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances)
    DefaultArtemisRollOrder = game.ShallowCopyTable(game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder)
    DefaultHadesRarity = game.ShallowCopyTable(game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances)
    DefaultHadesRollOrder = game.ShallowCopyTable(game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder)
    DefaultChaosRarity = game.ShallowCopyTable(game.LootSetData.Chaos.TrialUpgrade.BoonRaritiesOverride)
    DefaultRarityOrder = game.ShallowCopyTable(game.TraitRarityData.BoonRarityRollOrder)
    DefaultRarityReverseOrder = game.ShallowCopyTable(game.TraitRarityData.BoonRarityReverseRollOrder)
    DefaultRarityUpgradeOrder = game.ShallowCopyTable(game.TraitRarityData.RarityUpgradeOrder)
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
    local activationReqs = game.DeepCopyTable(DefaultInfusionActivationRequirements[elementalTrait])
    local activated = game.IsGameStateEligible(game.CurrentRun, activationReqs)

    local requirements = game.TraitData[elementalTrait].GameStateRequirements
    local eligible = game.IsGameStateEligible(game.CurrentRun, requirements)
    if eligible == false then
        return nil
    end

    -- check that it isn't already being offered
    local offered = false
    for _, trait in ipairs(options) do
        if trait.ItemName == elementalTrait then offered = true end
    end
    if offered == true then return end

    return elementalTrait, eligible, activated
end

function public.adjustRarityValues()
    -- load up perfectoinist
    local mods = rom.mods
    local perfectMod = mods['Jowday-Perfectoinist']

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
    local chaos = config.ChaosRarity

    local rarityTable = {}

    -- insert slider values
    rarityTable.Rare = rare
    rarityTable.Epic = epic
    rarityTable.Heroic = heroic
    rarityTable.Duo = duo
    rarityTable.Legendary = legendary

    -- adds Heroic to the rolls
    local rarityOrder = game.ShallowCopyTable(DefaultRarityOrder)
    if heroic > 0 or min > 2 then rarityOrder = { "Common", "Rare", "Epic", "Heroic", "Duo", "Legendary" } end

    local reverseOrder = game.ShallowCopyTable(DefaultRarityReverseOrder)
    if heroic > 0 or min > 2 then reverseOrder = { "Legendary", "Duo", "Heroic", "Epic", "Rare", "Common" } end

    local upgradeOrder = game.ShallowCopyTable(DefaultRarityUpgradeOrder)

    -- perfectoinist plugin
    if perfectMod then
        local perfect
        if type(perfectMod.config.PerfectChance) == 'number' then
            perfect = math.min(perfectMod.config.PerfectChance / 100, 1)
        else
            perfect = perfectMod.DefaultPerfectChance
        end
        rarityTable.Perfect = perfect
        if perfect > 0 then
            table.insert(rarityOrder, "Perfect")
            table.insert(reverseOrder, 1, "Perfect")
        end
        if perfectMod.config.AllowPerfectSacrifice then
            table.insert(upgradeOrder, "Perfect")
        end
    end

    -- apply roll order after plugins/etc
    game.TraitRarityData.BoonRarityRollOrder = rarityOrder
    game.TraitRarityData.BoonRarityReverseRollOrder = reverseOrder
    game.TraitRarityData.RarityUpgradeOrder = upgradeOrder
    game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder = rarityOrder
    -- this seems to be ignored currently, but putting it here anyway
    game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder = rarityOrder

    -- apply overrides
    if min > 0 then rarityTable.Rare = 1 end
    if min > 1 then rarityTable.Epic = 1 end
    if min > 2 then rarityTable.Heroic = 1 end

    -- apply to regular boons
    game.CurrentRun.Hero.BoonData.RarityChances = rarityTable

    -- apply to friends
    if hermes == true then
        game.CurrentRun.Hero.HermesData.RarityChances = rarityTable
    else
        game.CurrentRun.Hero.HermesData.RarityChances = game.ShallowCopyTable(DefaultHermesRarity)
    end
    if artemis == true then
        game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances = rarityTable
    else
        game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances = game.ShallowCopyTable(DefaultArtemisRarity)
        game.UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder = game.ShallowCopyTable(
        DefaultArtemisRollOrder)
    end
    -- this doesn't do anything currently - see the GetRarityChances wrap
    if hades == true then
        game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances = rarityTable
    else
        game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances = game.ShallowCopyTable(DefaultHadesRarity)
        game.UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder = game.ShallowCopyTable(DefaultHadesRollOrder)
    end
    if chaos == true then
        game.LootSetData.Chaos.TrialUpgrade.BoonRaritiesOverride = rarityTable
    else
        game.LootSetData.Chaos.TrialUpgrade.BoonRaritiesOverride = game.ShallowCopyTable(DefaultChaosRarity)
    end
end

function revertDefaultRarity()
    game.CurrentRun.Hero.BoonData = game.DeepCopyTable(game.HeroData.BoonData)
    game.CurrentRun.Hero.HermesData = game.DeepCopyTable(game.HeroData.HermesData)
end

function getReplaceableIndices(options)
    local indices = {}
    for i, option in ipairs(options) do
        if option.Rarity ~= "Duo" and option.Rarity ~= "Legendary" then
            table.insert(indices, i)
        end
    end
    return indices
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