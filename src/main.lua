---@meta _
---@diagnostic disable

-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = PLUGIN

---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game

---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto()
-- ^ this updates our config.toml in the config folder!
public.config = config -- so other mods can access our config

local function on_ready()
    -- what to do when we are ready, but not re-do on reload.
    if config.enabled == false then return end

    local BoonInfoButton =
    {
        Requirements =
        {
            {
                PathTrue = { "GameState", "WorldUpgrades", "WorldUpgradeBoonList" },
            }
        },
        Graphic = "ContextualActionButton",
        GroupName = "Combat_Menu_Overlay",
        Data =
        {
            OnMouseOverFunctionName = "MouseOverContextualAction",
            OnMouseOffFunctionName = "MouseOffContextualAction",
            OnPressedFunctionName = "AttemptOpenCodexBoonInfo",
            ControlHotkeys = { "MenuInfo", },
        },
        Text = "Menu_TraitList",
        TextArgs = game.UIData.ContextualButtonFormatRight,
    }

    local CloseButton =
    {
        Graphic = "ContextualActionButton",
        Data =
        {
            OnMouseOverFunctionName = "MouseOverContextualAction",
            OnMouseOffFunctionName = "MouseOffContextualAction",
            OnPressedFunctionName = "CloseBoonInfoScreen",
            ControlHotkeys = { "Cancel", },
        },
        Text = "Menu_CloseSubmenu",
        TextArgs = game.UIData.ContextualButtonFormatRight,
    }

    local currentGod = nil
    local entries = {}

    local function setCodexVarsReturnEntries(name)
        if name == nil then return nil end

        if name == 'TrialUpgrade'
            or name == 'NPC_Arachne_01'
            -- or name == 'NPC_Echo_01'
            or name == 'NPC_Narcissus_01'
            or name == 'NPC_Hades_Field_01'
        then
            game.CodexStatus.SelectedChapterName = 'OtherDenizens'
            game.CodexStatus.SelectedEntryNames.OtherDenizens = name
            return game.CodexOrdering.OtherDenizens
        end

        -- NYI - selene's boon presentation is not in UpgradeChoice
        -- if name == 'SpellDrop' then
        --     game.CodexStatus.SelectedChapterName = 'ChthonicGods'
        --     game.CodexStatus.SelectedEntryNames.OtherDenizens = 'SpellDrop'
        --     return game.CodexOrdering.ChthonicGods
        -- end

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
            return game.CodexOrdering.OlympianGods
        end

        return nil
    end

    modutil.mod.Path.Wrap("OpenUpgradeChoiceMenu", function(base, source, args)
        local name = source.Name or nil
        if name ~= nil then
            currentGod = name
            -- get entries here, to be used later
            entries = setCodexVarsReturnEntries(name)
                if entries ~= nil then
                table.insert(game.ScreenData.UpgradeChoice.ComponentData.ActionBar.ChildrenOrder, "BoonInfoButton")
                game.ScreenData.UpgradeChoice.ComponentData.ActionBar.Children["BoonInfoButton"] = BoonInfoButton
            end
        end
        base(source, args)
    end)

    modutil.mod.Path.Wrap("AttemptOpenCodexBoonInfo", function(base, codexScreen, button)
        if entries ~= nil then
            -- insert some things that need to be cleaned up later
            codexScreen.Components["CloseButton"] = CloseButton
        end
        base(codexScreen, button)
    end)

    modutil.mod.Path.Wrap("BoonInfoPopulateTraits", function(base, screen)
        if currentGod ~= nil then
            -- more trickery
            screen.CodexScreen["OpenEntryName"] = currentGod
            screen.LootName = currentGod
        end
        base(screen)
    end)

    modutil.mod.Path.Wrap("CodexUpdateVisibility", function(base, screen, args)
        if currentGod ~= nil then
            screen.ActiveEntries = entries
            screen.NumItems = #entries
            screen.ScrollOffset = 0
            screen.MaxVisibleEntries = 11 -- magic-ish number (CodexData.lua:45)
            args = { IgnoreArrows = true }
        end
        base(screen, args)
    end)

    modutil.mod.Path.Wrap("CloseUpgradeChoiceScreen", function(base, screen, button)
        -- cleanup the stuff we inserted
        if currentGod ~= nil then
            table.remove(game.ScreenData.UpgradeChoice.ComponentData.ActionBar.ChildrenOrder, nil)
        game.ScreenData.UpgradeChoice.ComponentData.ActionBar.Children["BoonInfoButton"] = nil
        end
        currentGod = nil
        entries = nil

        base(screen, button)
    end)
end

local function on_reload()

end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.on_ready_final(function()
    loader.load(on_ready, on_reload)
end)
