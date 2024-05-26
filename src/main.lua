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
        --Alpha = 0.0,
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
        GroupName = "Combat_Menu_Overlay",
        Data =
        {
            OnMouseOverFunctionName = "MouseOverContextualAction",
            OnMouseOffFunctionName = "MouseOffContextualAction",
            --OnPressedFunctionName = {"CloseBoonInfoScreen", "CloseCodexScreen"},
            OnPressedFunctionName = "CloseBoonInfoScreen",
            ControlHotkeys = { "Cancel", },
            MouseControlHotkeys = { "Cancel", "Codex", }
        },
        Text = "Menu_Close",
        TextArgs = game.UIData.ContextualButtonFormatRight,
    }

    local currentGod = nil

    -- skips over chaos/selene
    local function checkValidGods(name)
    local validGods = { "ZeusUpgrade", "HeraUpgrade", "PoseidonUpgrade", "DemeterUpgrade", "ApolloUpgrade",
        "AphroditeUpgrade", "HephaestusUpgrade", "HestiaUpgrade", "HermesUpgrade", "NPC_Artemis_01" }
            for k, v in pairs(validGods) do
                if name:match("^" .. v) then
                    return true
                end
            end
            return false
        end

    modutil.mod.Path.Wrap("AttemptOpenCodexBoonInfo", function(base, codexScreen, button)
        currentGod = nil
        local name = codexScreen.SubjectName or ''
        print(tostring(checkValidGods(name)))
        if checkValidGods(codexScreen.SubjectName) == true then
            print('AttemptOpenCodexBoonInfo: ' .. codexScreen.SubjectName)
            currentGod = codexScreen.SubjectName
            game.CodexStatus.SelectedChapterName = 'OlympianGods'
            game.CodexStatus.SelectedEntryNames.OlympianGods = currentGod
            -- trickery
            codexScreen.Components["CloseButton"] = CloseButton
        end
        base(codexScreen, button)
    end)

    modutil.mod.Path.Wrap("BoonInfoPopulateTraits", function(base, screen)
        if currentGod ~= nil then
            -- more trickery
            print('BoonInfoPopulateTraits: ' .. currentGod)
            screen.CodexScreen["OpenEntryName"] = currentGod
            screen.LootName = currentGod
        end
        base(screen)
    end)

    modutil.mod.Path.Wrap("CodexUpdateVisibility", function(base, screen, args)
        print(currentGod)
        if currentGod ~= nil then
            screen.ActiveEntries = game.CodexOrdering.OlympianGods
            screen.ScrollOffset = 0
            screen.MaxVisibleEntries = 11 -- magic number
            args = { IgnoreArrows = true }
        end

        print('CodexUpdateVisibility: ' .. game.TableToJSONString(screen.ActiveEntries))

        base(screen, args)
    end)

    modutil.mod.Path.Wrap("CloseCodexScreen", function(base, screen, button)
        
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
