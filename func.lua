---@meta _
---@diagnostic disable

-- Create the global mod object if it doesn't exist
if not JowdayBoonBuddy then
    JowdayBoonBuddy = {}
end

local mod = JowdayBoonBuddy

function mod.getDefaults()
    for traitName, vals in pairs(TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            mod.DefaultInfusionGameStateRequirements[traitName] = DeepCopyTable(vals.GameStateRequirements)
        end
    end

    for traitName, vals in pairs(TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            mod.DefaultInfusionActivationRequirements[traitName] = DeepCopyTable(vals.ActivationRequirements)
        end
    end

    mod.DefaultBoonRarity = ShallowCopyTable(HeroData.BoonData.RarityChances)
    mod.DefaultHermesRarity = ShallowCopyTable(HeroData.HermesData.RarityChances)
    mod.DefaultReplaceChance = HeroData.BoonData.ReplaceChance
    mod.DefaultArtemisRarity = ShallowCopyTable(UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances)
    mod.DefaultArtemisRollOrder = ShallowCopyTable(UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder)
    mod.DefaultHadesRarity = ShallowCopyTable(UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances)
    mod.DefaultHadesRollOrder = ShallowCopyTable(UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder)
    mod.DefaultChaosRarity = ShallowCopyTable(LootSetData.Chaos.TrialUpgrade.BoonRaritiesOverride)
    mod.DefaultRarityOrder = ShallowCopyTable(TraitRarityData.BoonRarityRollOrder)
    mod.DefaultRarityReverseOrder = ShallowCopyTable(TraitRarityData.BoonRarityReverseRollOrder)
    mod.DefaultRarityUpgradeOrder = ShallowCopyTable(TraitRarityData.RarityUpgradeOrder)
end

function mod.overrideInfusionGameStateRequirements()
    for traitName, vals in pairs(TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            TraitData[traitName].GameStateRequirements = DeepCopyTable(vals.ActivationRequirements)
        end
    end
end

function mod.revertInfusionGameStateRequirements()
    for traitName, vals in pairs(TraitData) do
        if vals.IsElementalTrait and vals.ActivationRequirements ~= nil then
            TraitData[traitName].GameStateRequirements = DeepCopyTable(mod.DefaultInfusionGameStateRequirements[traitName])
        end
    end
end

function mod.getEligibleElementalTrait(traits, options)
    -- pretty sure options can never be nil, but just in case
    if traits == nil or options == nil then return nil end

    -- check for an elemental trait
    local elementalTrait = nil
    for _, traitName in ipairs(traits) do
        if TraitData[traitName].IsElementalTrait then
            elementalTrait = traitName
        end
    end

    -- did we find anything?
    if elementalTrait == nil then return nil end

    -- check if we have it already
    if HeroHasTrait(elementalTrait) then return nil end

    -- check if it was banned
    if mod.isTraitBanned(elementalTrait) then return nil end

    -- check for elemental requirement
    local activationReqs = DeepCopyTable(mod.DefaultInfusionActivationRequirements[elementalTrait])
    local activated = IsGameStateEligible(CurrentRun, activationReqs)

    local requirements = TraitData[elementalTrait].GameStateRequirements
    local eligible = IsGameStateEligible(CurrentRun, requirements)
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

function mod.adjustRarityValues()
    -- make sure everything is a number
    local min, rare, epic, heroic, duo, legendary, replace
    if type(mod.Config.MinimumRarity) == 'number' then
        min = mod.Config.MinimumRarity
    else
        min = 0
    end
    if type(mod.Config.RareChance) == 'number' then
        rare = math.min(mod.Config.RareChance / 100, 1)
    else
        rare = mod.DefaultBoonRarity.Rare * 100
    end
    if type(mod.Config.EpicChance) == 'number' then
        epic = math.min(mod.Config.EpicChance / 100, 1)
    else
        epic = mod.DefaultBoonRarity.Epic * 100
    end
    if type(mod.Config.HeroicChance) == 'number' then
        heroic = math.min(mod.Config.HeroicChance / 100, 1)
    else
        heroic = 0
    end
    if type(mod.Config.DuoChance) == 'number' then
        duo = math.min(mod.Config.DuoChance / 100, 1)
    else
        duo = mod.DefaultBoonRarity.Duo * 100
    end
    if type(mod.Config.LegendaryChance) == 'number' then
        legendary = math.min(mod.Config.LegendaryChance / 100, 1)
    else
        legendary = mod.DefaultBoonRarity.Legendary * 100
    end
    if type(mod.Config.ReplaceChance) == 'number' then
        replace = math.min(mod.Config.ReplaceChance / 100, 1)
    else
        replace = mod.DefaultReplaceChance * 100
    end

    -- apply MinimumRarity overrides
    local hermes = mod.Config.HermesRarity
    local artemis = mod.Config.ArtemisRarity
    local hades = mod.Config.HadesRarity
    local chaos = mod.Config.ChaosRarity

    local rarityTable = {}

    -- insert slider values
    rarityTable.Rare = rare
    rarityTable.Epic = epic
    rarityTable.Heroic = heroic
    rarityTable.Duo = duo
    rarityTable.Legendary = legendary

    -- adds Heroic to the rolls
    local rarityOrder = ShallowCopyTable(mod.DefaultRarityOrder)
    if heroic > 0 or min > 2 then rarityOrder = { "Common", "Rare", "Epic", "Heroic", "Duo", "Legendary" } end

    local reverseOrder = ShallowCopyTable(mod.DefaultRarityReverseOrder)
    if heroic > 0 or min > 2 then reverseOrder = { "Legendary", "Duo", "Heroic", "Epic", "Rare", "Common" } end

    local upgradeOrder = ShallowCopyTable(mod.DefaultRarityUpgradeOrder)

    -- Perfectoinist plugin
    local perfect
    if type(mod.Config.PerfectChance) == 'number' then
        perfect = math.min(mod.Config.PerfectChance / 100, 1)
    else
        perfect = mod.DefaultPerfectChance
    end
    rarityTable.Perfect = perfect
    if perfect > 0 then
        table.insert(rarityOrder, "Perfect")
        table.insert(reverseOrder, 1, "Perfect")
    end
    if mod.Config.AllowPerfectSacrifice then
        table.insert(upgradeOrder, "Perfect")
    end

    -- apply roll order after plugins/etc
    TraitRarityData.BoonRarityRollOrder = rarityOrder
    TraitRarityData.BoonRarityReverseRollOrder = reverseOrder
    TraitRarityData.RarityUpgradeOrder = upgradeOrder
    UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder = rarityOrder
    -- this seems to be ignored currently, but putting it here anyway
    UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder = rarityOrder

    -- apply overrides
    if min > 0 then rarityTable.Rare = 1 end
    if min > 1 then rarityTable.Epic = 1 end
    if min > 2 then rarityTable.Heroic = 1 end

    -- apply to regular boons
    HeroData.BoonData.RarityChances = rarityTable

    -- apply to friends
    if hermes == true then
        HeroData.HermesData.RarityChances = rarityTable
    else
        HeroData.HermesData.RarityChances = ShallowCopyTable(mod.DefaultHermesRarity)
    end
    if artemis == true then
        UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances = rarityTable
    else
        UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityChances = ShallowCopyTable(mod.DefaultArtemisRarity)
        UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.RarityRollOrder = ShallowCopyTable(mod.DefaultArtemisRollOrder)
    end
    -- this doesn't do anything currently - see the GetRarityChances wrap
    if hades == true then
        UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances = rarityTable
    else
        UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityChances = ShallowCopyTable(mod.DefaultHadesRarity)
        UnitSetData.NPC_Hades.NPC_Hades_Field_01.RarityRollOrder = ShallowCopyTable(mod.DefaultHadesRollOrder)
    end
    if chaos == true then
        LootSetData.Chaos.TrialUpgrade.BoonRaritiesOverride = rarityTable
    else
        LootSetData.Chaos.TrialUpgrade.BoonRaritiesOverride = ShallowCopyTable(mod.DefaultChaosRarity)
    end
end

function mod.revertDefaultRarity()
    HeroData.BoonData = DeepCopyTable(HeroData.BoonData)
    HeroData.HermesData = DeepCopyTable(HeroData.HermesData)
end

function mod.getReplaceableIndices(options)
    local indices = {}
    for i, option in ipairs(options) do
        if option.Rarity ~= "Duo" and option.Rarity ~= "Legendary" then
            table.insert(indices, i)
        end
    end
    return indices
end

function mod.isTraitBanned(traitName)
    if CurrentRun.BannedTraits[traitName] then return true end
    return false
end

-- offerings button override functions
-- UpgradeChoiceData:340
function mod.updateBoonListRequirements()
    if mod.Config.AlwaysAllowed == true then
        ScreenData.UpgradeChoice.ComponentData.ActionBarLeft.Children.BoonListButton["Requirements"] = {}
    else
        ScreenData.UpgradeChoice.ComponentData.ActionBarLeft.Children.BoonListButton["Requirements"] = { { PathTrue = { "GameState", "WorldUpgrades", "WorldUpgradeBoonList" } } }
    end
end