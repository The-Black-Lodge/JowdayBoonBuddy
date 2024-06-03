---@meta _
---@diagnostic disable

function setCodexVarsReturnEntries(name)
    if name == nil then return nil end

    if name == 'TrialUpgrade'
    then
        game.CodexStatus.SelectedChapterName = 'OtherDenizens'
        game.CodexStatus.SelectedEntryNames.OtherDenizens = name
        return game.DeepCopyTable(game.CodexOrdering.OtherDenizens)
    end

    if name == "ZeusUpgrade"
        or name == "HeraUpgrade"
        or name == "PoseidonUpgrade"
        or name == "DemeterUpgrade"
        or name == "ApolloUpgrade"
        or name == "AphroditeUpgrade"
        or name == "HephaestusUpgrade"
        or name == "HestiaUpgrade"
        or name == "HermesUpgrade"
        or name == "NPC_Artemis_01" -- need to check?
    then
        game.CodexStatus.SelectedChapterName = 'OlympianGods'
        game.CodexStatus.SelectedEntryNames.OlympianGods = name
        return game.DeepCopyTable(game.CodexOrdering.OlympianGods)
    end

    return nil
end

function isTraitBanned(traitName)
    for k, v in pairs(game.CurrentRun.BannedTraits) do
        if traitName:match(k) then
            return true
        end
    end
    return false
end
