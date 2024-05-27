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

    table.insert(game.ScreenData.UpgradeChoice.ComponentData.ActionBar.ChildrenOrder, "BoonInfoButton")
    game.ScreenData.UpgradeChoice.ComponentData.ActionBar.Children["BoonInfoButton"] = BoonInfoButton

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
        if name == '' then return nil, nil end

        if name == 'TrialUpgrade' then
            game.CodexStatus.SelectedChapterName = 'OtherDenizens'
            game.CodexStatus.SelectedEntryNames.OtherDenizens = 'TrialUpgrade'
            return game.CodexData.OtherDenizens.Entries
        end

        if name == 'SpellDrop' then
            game.CodexStatus.SelectedChapterName = 'ChthonicGods'
            game.CodexStatus.SelectedEntryNames.OtherDenizens = 'SpellDrop'
            return game.CodexData.ChthonicGods.Entries
        end

        game.CodexStatus.SelectedChapterName = 'OlympianGods'
        game.CodexStatus.SelectedEntryNames.OlympianGods = name
        return game.CodexData.OlympianGods.Entries
    end

    modutil.mod.Path.Wrap("AttemptOpenCodexBoonInfo", function(base, codexScreen, button)
        currentGod = nil
        entries = {}

        local name = codexScreen.SubjectName or ''
        if name ~= '' then
            currentGod = name
            -- get entries here, to be used in CodexUpdateVisibility
            entries = setCodexVarsReturnEntries(name)
            -- trickery
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
            screen.MaxVisibleEntries = 11 -- magic-ish number
            args = { IgnoreArrows = true }
        end
        base(screen, args)
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
