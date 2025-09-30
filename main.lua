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

-- Perfectoinist defaults
mod.DefaultPerfectChance = 0.01

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
        
        -- Setup Perfectoinist functionality
        ScreenData.UpgradeChoice.RarityBackingAnimations.Perfect = "BoonSlotPerfect"
        
        -- Setup Perfect multipliers
        -- aphrodite
        TraitData.AphroditeWeaponBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.AphroditeSpecialBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.AphroditeCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.AphroditeSprintBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.AphroditeManaBoon.RarityLevels.Perfect = { Multiplier = 2.67 }
        TraitData.HighHealthOffenseBoon.RarityLevels.Perfect = { Multiplier = 15 / 5 }
        TraitData.HealthRewardBonusBoon.RarityLevels.Perfect = { Multiplier = 40 / 15 }
        TraitData.DoorHealToFullBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.WeakPotencyBoon.RarityLevels.Perfect = { Multiplier = 2.0 }
        TraitData.WeakVulnerabilityBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ManaBurstBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.FocusRawDamageBoon.RarityLevels.Perfect = { Multiplier = 15 / 5 }

        -- apollo
        TraitData.ApolloWeaponBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ApolloSpecialBoon.RarityLevels.Perfect = { Multiplier = 2.67 }
        TraitData.ApolloCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ApolloExCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ApolloSprintBoon.RarityLevels.Perfect = { Multiplier = 8 / 3 }
        TraitData.ApolloManaBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ApolloRetaliateBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.PerfectDamageBonusBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.BlindChanceBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ApolloBlindBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ApolloCastAreaBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.DoubleStrikeChanceBoon.RarityLevels.Perfect = { Multiplier = 3.5 }

        -- ares
        TraitData.AresWeaponBoon.RarityLevels.Perfect = { Multiplier = 70 / 20 }
        TraitData.AresSpecialBoon.RarityLevels.Perfect = { Multiplier = 80 / 30 }
        TraitData.AresManaBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.AresCastBoon.RarityLevels.Perfect = { Multiplier = 230 / 80 }
        TraitData.AresSprintBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.AresExCastBoon.RarityLevels.Perfect = { Multiplier = 80 / 30 }
        TraitData.RendBloodDropBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.AresStatusDoubleDamageBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.BloodDropRevengeBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.MissingHealthCritBoon.RarityLevels.Perfect = { Multiplier = 0.2 / 0.1 }
        TraitData.LowHealthLifestealBoon.RarityLevels.Perfect = { Multiplier = 6 }
        TraitData.OmegaDelayedDamageBoon.RarityLevels.Perfect = { Multiplier = 240 / 90 }

        -- artemis
        TraitData.InsideCastCritBoon.RarityLevels.Perfect = { Multiplier = 2.5 }
        TraitData.OmegaCastVolleyBoon.RarityLevels.Perfect = { Multiplier = 100 / 50 }
        TraitData.HighHealthCritBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.CritBonusBoon.RarityLevels.Perfect = { Multiplier = 2.67 }
        TraitData.DashOmegaBuffBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.SupportingFireBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.TimedCritVulnerabilityBoon.RarityLevels.Perfect = { Multiplier = 10 / 20 }
        TraitData.FocusCritBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.SorceryCritBoon.RarityLevels.Perfect = { Multiplier = 0.55 / 0.3 }

        -- athena
        TraitData.InvulnerabilityDashBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.RetaliateInvulnerabilityBoon.RarityLevels.Perfect = { Multiplier = 3 / 10 }
        TraitData.FocusLastStandBoon.RarityLevels.Perfect = { Multiplier = 25 / 150 }
        TraitData.AthenaProjectileBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DeathDefianceRefillBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.InvulnerabilityCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ManaSpearBoon.RarityLevels.Perfect = { Multiplier = 400 / 150 }
        TraitData.OlympianSpellCountBoon.RarityLevels.Perfect = { Multiplier = 6 }

        -- demeter
        TraitData.DemeterWeaponBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DemeterSpecialBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DemeterCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DemeterSprintBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DemeterManaBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.CastNovaBoon.RarityLevels.Perfect = { Multiplier = 6 }
        TraitData.PlantHealthBoon.RarityLevels.Perfect = { Multiplier = 2.0 }
        TraitData.BoonGrowthBoon.RarityLevels.Perfect = { Multiplier = 1/6 }
        TraitData.ReserveManaHitShieldBoon.RarityLevels.Perfect = { Multiplier = 1 / 25 }
        TraitData.SlowExAttackBoon.RarityLevels.Perfect = { Multiplier = 2.5 }
        TraitData.CastAttachBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.RootDurationBoon.RarityLevels.Perfect = { Multiplier = 3.5 }

        -- dionysus
        TraitData.CastLobBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HiddenMaxHealthBoon.RarityLevels.Perfect = { Multiplier = 3 }
        TraitData.FirstHangoverBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.PowerDrinkBoon.RarityLevels.Perfect = { Multiplier = 5 / 10 }
        TraitData.CombatEncounterHealBoon.RarityLevels.Perfect = { Multiplier = 2.0 }
        TraitData.FogDamageBonusBoon.RarityLevels.Perfect = { Multiplier = 2.67 }
        TraitData.BankBoon.RarityLevels.Perfect = { Multiplier = 800 / 300 }
        TraitData.RandomBaseDamageBoon.RarityLevels.Perfect = { Multiplier = 3 }

        -- hephaestus
        TraitData.HephaestusWeaponBoon.RarityLevels.Perfect = { Multiplier = 2 / 12 }
        TraitData.HephaestusSpecialBoon.RarityLevels.Perfect = { Multiplier = 2 / 7 }
        TraitData.HephaestusCastBoon.RarityLevels.Perfect = { Multiplier = 2.2 }
        TraitData.HephaestusSprintBoon.RarityLevels.Perfect = { Multiplier = 5 / 10 }
        TraitData.HephaestusManaBoon.RarityLevels.Perfect = { Multiplier = 6 }
        TraitData.AntiArmorBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HeavyArmorBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.ArmorBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.EncounterStartDefenseBuffBoon.RarityLevels.Perfect = { Multiplier = 200 / 75 }
        TraitData.ManaToHealthBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.MassiveDamageBoon.RarityLevels.Perfect = { Multiplier = 200 / 75 }
        TraitData.MassiveKnockupBoon.RarityLevels.Perfect = { Multiplier = 1.40 / 1.15 }

        -- hera
        TraitData.HeraWeaponBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.HeraSpecialBoon.RarityLevels.Perfect = { Multiplier = 1.1 / 0.6 }
        TraitData.HeraCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.SpawnCastDamageBoon.RarityLevels.Perfect = { Multiplier = 8 / 3 }
        TraitData.HeraSprintBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HeraManaBoon.RarityLevels.Perfect = { Multiplier = 0.5 }
        TraitData.CommonGlobalDamageBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DamageShareRetaliateBoon.RarityLevels.Perfect = { Multiplier = 8 / 3 }
        TraitData.BoonDecayBoon.RarityLevels.Perfect = { Multiplier = 6 }
        TraitData.OmegaHeraProjectileBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.DamageSharePotencyBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.LinkedDeathDamageBoon.RarityLevels.Perfect = { Multiplier = 3.5 }

        -- hermes
        TraitData.HermesWeaponBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HermesSpecialBoon.RarityLevels.Perfect = { Multiplier = 2.67 }
        TraitData.SlowProjectileBoon.RarityLevels.Perfect = { Multiplier = 8 / 3 }
        TraitData.MoneyMultiplierBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DodgeChanceBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HermesCastDiscountBoon.RarityLevels.Perfect = { Multiplier = (1-(100/325)) / 0.50 }
        TraitData.SorcerySpeedBoon.RarityLevels.Perfect = { Multiplier = 1.7 }
        TraitData.TimedKillBuffBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.SprintShieldBoon.RarityLevels.Perfect = { Multiplier = 6 }
        TraitData.RestockBoon.RarityLevels.Perfect = { Multiplier = 6 }
        TraitData.LuckyBoon.RarityLevels.Perfect = { Multiplier = 80 / 30 }

        -- hestia
        TraitData.HestiaWeaponBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HestiaSpecialBoon.RarityLevels.Perfect = { Multiplier = 85 / 35 }
        TraitData.HestiaCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HestiaSprintBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.HestiaManaBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.AloneDamageBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.OmegaZeroBurnBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.CastProjectileBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.FireballManaSpecialBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.BurnExplodeBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.BurnArmorBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.BurnStackBoon.RarityLevels.Perfect = { Multiplier = 3.5 }

        -- poseidon
        TraitData.PoseidonWeaponBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.PoseidonSpecialBoon.RarityLevels.Perfect = { Multiplier = 50 / 25 }
        TraitData.PoseidonCastBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.PoseidonExCastBoon.RarityLevels.Perfect = { Multiplier = 400 / 150 }
        TraitData.OmegaPoseidonProjectileBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.PoseidonSprintBoon.RarityLevels.Perfect = { Multiplier = 180 / 80 }
        TraitData.PoseidonManaBoon.RarityLevels.Perfect = { Multiplier = 9 / 4 }
        TraitData.EncounterStartOffenseBuffBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.RoomRewardBonusBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.FocusDamageShaveBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DoubleRewardBoon.RarityLevels.Perfect = { Multiplier = 2 }
        TraitData.PoseidonStatusBoon.RarityLevels.Perfect = { Multiplier = 2.25 }

        -- zeus
        TraitData.ZeusWeaponBoon.RarityLevels.Perfect = { Multiplier = 2.8 }
        TraitData.ZeusSpecialBoon.RarityLevels.Perfect = { Multiplier = 2.5 }
        TraitData.ZeusCastBoon.RarityLevels.Perfect = { Multiplier = 2.0 }
        TraitData.ZeusSprintBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
        TraitData.ZeusManaBoon.RarityLevels.Perfect = { Multiplier = 5 / 10 }
        TraitData.ZeusManaBoltBoon.RarityLevels.Perfect = { Multiplier = 8 / 3 }
        TraitData.BoltRetaliateBoon.RarityLevels.Perfect = { MinMultiplier = 3.3, MaxMultiplier = 3.5 }
        TraitData.CastAnywhereBoon.RarityLevels.Perfect = { Multiplier = 3 }
        TraitData.FocusLightningBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.DoubleBoltBoon.RarityLevels.Perfect = { Multiplier = 3.5 }
        TraitData.EchoExpirationBoon.RarityLevels.Perfect = { Multiplier = 80 / 30 }
        TraitData.LightningDebuffGeneratorBoon.RarityLevels.Perfect = { Multiplier = 2.25 }
    end
end }