---@meta _
---@diagnostic disable

-- preserve localization but update bind
local originalText = game.GetDisplayName({ Text = "Menu_BoonInfo" })
local boonListText = string.gsub(originalText, "{MX}", "{CN}")

BoonInfoButton = game.DeepCopyTable(game.ScreenData.Codex.ComponentData.ActionBar.Children.BoonInfoButton)
BoonInfoButton.Data.ControlHotkeys = { "Cancel" }
BoonInfoButton.Alpha = 1.0
BoonInfoButton.Text = boonListText
if config.AlwaysAllowed == true then
    BoonInfoButton["Requirements"] = {}
end

CloseButton = game.DeepCopyTable(game.ScreenData.BoonInfo.ComponentData.ActionBarRight.Children.CloseButton)

-- copy over boon button and child order
table.insert(game.ScreenData.UpgradeChoice.ComponentData.ActionBar.ChildrenOrder, "BoonInfoButton")
game.ScreenData.UpgradeChoice.ComponentData.ActionBar.Children["BoonInfoButton"] = game.DeepCopyTable(
    BoonInfoButton)

function setBannedProps(textArgs)
    textArgs.Color = game.Color.DarkRed
    textArgs.ShadowBlur = 0
    textArgs.ShadowColor = game.Color.Black
    textArgs.ShadowOffset = { 0, 1 }
end