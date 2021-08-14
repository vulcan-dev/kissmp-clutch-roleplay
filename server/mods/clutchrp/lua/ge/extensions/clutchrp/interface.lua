--[[ This module is not needed but I'll keep it for now, might need to keep stuff seperated in the future ]]--

--[[
    TODO Make a weather system with custom presets
]]

local M = {}

local interface_roleplay = require('clutchrp.ui.interface_roleplay')
local interface_moderation = require('clutchrp.ui.interface_moderation')
local interface_phone = require('clutchrp.ui.interface_phone')
local character_selector = require('clutchrp.ui.character_selector')
local tooltip = require('clutchrp.ui.tooltip')
local command = require('clutchrp.command')

local function ToggleInterfaceRP()
    interface_roleplay.shouldDraw = not interface_roleplay.shouldDraw
    interface_roleplay.shouldDrawCommnad = false
    command.drawData.shouldDraw = false
    log('I', 'interface', 'interface_roleplay: ' .. tostring(interface_roleplay.shouldDraw))
end

local function ToggleInterfacePhone()
    interface_phone.shouldDraw = not interface_phone.shouldDraw
    command.drawData.shouldDraw = false
    log('I', 'interface', 'interface_phone: ' .. tostring(interface_phone.shouldDraw))
end

local function ToggleInterfaceModeration()
    interface_moderation.shouldDraw = not interface_moderation.shouldDraw
    interface_moderation.shouldDrawCommand = false
    command.drawData.shouldDraw = false

    log('I', 'interface', 'interface_moderation: ' .. tostring(interface_moderation.shouldDraw))
end

local wasOnServer = false

local function Update(dt)
    if network and network.connection and network.connection.connected and string.find(network.connection.server_info.name, 'Clutch') then
        if not wasOnServer then
            wasOnServer = true

            -- fix ui not showing
            FS:unmount('/kissmp_mods/clutchrp')
            FS:mount('/kissmp_mods/clutchrp')
            core_vehicles.clearCache()
        end
        if character_selector.shouldDraw then
            character_selector.Draw(dt)
        end

        if interface_roleplay.shouldDraw then
            interface_roleplay.Draw(dt)
        end

        if interface_moderation.shouldDraw then
            interface_moderation.Draw(dt)
        end

        if interface_phone.shouldDraw then
            interface_phone.Draw(dt)
        end

        if tooltip.shouldDraw then
            tooltip.Draw(dt)
        end

        if interface_moderation.shouldDraw or interface_roleplay.shouldDraw then
            command.Draw(dt)
        end
    else
        if wasOnServer then
            M.character_selector.shouldDraw = false
            kissui.force_disable_nametags = false


        end
    end
end

local function OnExtensionLoaded()
    interface_phone.OnExtensionLoaded()
end

M.tooltip = tooltip
M.interface_phone = interface_phone
M.character_selector = character_selector
M.ToggleInterfaceRP = ToggleInterfaceRP
M.ToggleInterfaceModeration = ToggleInterfaceModeration
M.ToggleInterfacePhone = ToggleInterfacePhone
M.Update = Update
M.onExtensionLoaded = OnExtensionLoaded

return M

--[[
        "clutchrp":{
      "active":false,
      "dateAdded":1.62785068e+09,
      "dirname":"/mods/unpacked/clutchrp/",
      "filename":"",
      "fullpath":"/mods/unpacked/clutchrp/",
      "hash":"wip",
      "modType":"unknown",
      "modname":"clutchrp",
      "orgZipFilename":"/mods/clutchrp.zip",
      "stat":{
        "accesstime":1.6278627e+09,
        "createtime":1.62786239e+09,
        "filesize":4096,
        "filetype":"dir",
        "modtime":1.62786251e+09,
        "readonly":false
      },
      "unpackedPath":"/mods/unpacked/clutchrp/"
    },
]]