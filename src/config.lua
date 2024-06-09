---@meta _
---@diagnostic disable

return {
  version = 1.0,
  enabled = true,
  AlwaysAllowed = true,
  MinimumRarity = 0,
  RareChance = 10,
  EpicChance = 5,
  HeroicChance = 0,
  LegendaryChance = 10,
  DuoChance = 12,
  ReplaceChance = 10,
  InfusionChance = 10,
  InfusionOverride = false,
  InfusionWhenRequirementsMet = false,
    HermesRarity = false,
  NewSaveOverride = false
}, {
  AlwaysAllowed = "Ignore all requirements (Book of Shadows, Insight Into Offerings)",
  MinimumRarity = "Boons will be at least this rarity. Possible values: 0 (Default), 1 (Rare), 2 (Epic), 3 (Heroic)",
  LegendaryChance =
  "% Chance of Legendary boon if you meet the requirements. Default: 10",
  DuoChance = "% Chance of Duo boon if you meet the requirements. Default: 12",
  RareChance = "% Chance of Rare boon. Default: 10",
  EpicChance = "% Chance of Epic boon. Default: 5",
  HeroicChance = "% Chance of Heroic boon. Default: 0",
  ReplaceChance = "% Chance of boon replacement. Default: 10",
  HermesRarity = "Apply rarity chances to Hermes boons. Default: false",
  InfusionChance = "% Chance of Infusion boon. Default: 10",
  InfusionOverride = "Replaces the game's RNG for Infusion boons. Default: false",
    InfusionWhenRequirementsMet = "Only offer Infusion boon if you have the required elements. Default: false",
  NewSaveOverride = "NYI Removes the forced Common rarity from new saves. Default: false"
}
