local M = {}

local GUIModule = require("ge/extensions/editor/api/gui")
M.GUI = { setupEditorGuiTheme = nop }
local UI = ui_imgui

M.Moderation = require('clutchrp.ui.moderation')
M.Roleplay = require('clutchrp.ui.roleplay')
M.Playerlist = require('clutchrp.ui.playerlist')

local Debug = true

if Debug then
    network = {}
    network.connection = {}
    network.players = {
        [1] = {
            name = 'Daniel W',
            rank = 'Developer'
        },
        [2] = {
            name = 'Name 2',
            rank = 'User'
        },
        [3] = {
            name = 'Name 3',
            rank = 'Trusted'
        },
        [4] = {
            name = 'Name 4',
            rank = 'Trusted'
        },
        [5] = {
            name = 'Name 5',
            rank = 'Trusted'
        },
        [6] = {
            name = 'Name 6',
            rank = 'Trusted'
        }
    }
    network.connection.connected = true
    network.connection.server_info = {}
    network.connection.server_info.name = 'NEIN'
end

--[[ Shared Begin ]]--
M.Viewport = nil
M.Style_Main = bit.bor(
    UI.WindowFlags_NoScrollbar, UI.WindowFlags_NoDocking, UI.WindowFlags_NoTitleBar,
    UI.WindowFlags_NoResize, UI.WindowFlags_NoMove, UI.WindowFlags_NoScrollWithMouse, 
    UI.WindowFlags_NoCollapse
)

M.ButtonSize = UI.ImVec2(100, 30)

M.Execute = function(command)
    if network and network.connection.connected and string.find(network.connection.server_info.name, 'Clutch Roleplay') then
        if type(command) == 'string' then
            network.send_data({Chat = command}, true)
        else
            M.Command[command.name]()
        end
    else
        log('E', 'ClutchRoleplay-Command', 'You tried sending "'..command..'" but you are not on Clutch Roleplay')
    end
end

--[[ Shared End ]]

local function ToggleModerationMenu()
    M.Moderation.Show = not M.Moderation.Show
    if M.Moderation.Show then
        M.GUI.showWindow('Moderation')
    else
        M.GUI.hideWindow('Moderation')
    end

    log('D', 'ToggleModerationMenu', 'Show: ' .. tostring(M.Moderation.Show))
end

local function ToggleRoleplayMenu()
    M.Roleplay.Show = not M.Roleplay.Show
    if M.Roleplay.Show then
        M.GUI.showWindow('Roleplay')
    else
        M.GUI.hideWindow('Roleplay')
    end

    log('D', 'ToggleRoleplayMenu', 'Show: ' .. tostring(M.Roleplay.Show))
end

local function ShowPlayerlist()
    M.Playerlist.Show = true
    M.GUI.showWindow('Playerlist')
    log('D', 'Playerlist', 'Showing')
end

local function HidePlayerlist()
    if not M.Playerlist.ShouldHold then
        M.Playerlist.Show = false
        M.GUI.hideWindow('Playerlist')
        log('D', 'Playerlist', 'Hiding')

        M.Playerlist.SelectedUser = 0
    end
end

local function _Update(deltaTime)
    M.Viewport = UI.GetMainViewport()
    M.Moderation._Draw(deltaTime)
    M.Roleplay._Draw(deltaTime)
    M.Playerlist._Draw(deltaTime)
end

local function _ExtensionLoaded()
    GUIModule.initialize(M.GUI)
    M.GUI.registerWindow('Moderation', UI.ImVec2(256, 256))
    M.GUI.registerWindow('Roleplay', UI.ImVec2(256, 256))
    M.GUI.registerWindow('Playerlist', UI.ImVec2(256, 256))

    UI.PushStyleVar1(UI.StyleVar_WindowPadding, 0)
    UI.PushStyleColor2(UI.Col_Border, UI.ImVec4(0, 0, 0, 0))

    if Debug then
        if M.Roleplay.Show then
            M.GUI.showWindow('Roleplay')
        end
    end
end

local function _ExtensionUnloaded()
    UI.PopStyleVar(1)
    UI.PopStyleColor(1)
    Lua:RequestReload()
end

M.ToggleModerationMenu = ToggleModerationMenu
M.ToggleRoleplayMenu = ToggleRoleplayMenu
M.ShowPlayerlist = ShowPlayerlist
M.HidePlayerlist = HidePlayerlist

M.onUpdate = _Update
M.onExtensionLoaded = _ExtensionLoaded
M.onExtensionUnloaded = _ExtensionUnloaded

return M