--[[ This module is not needed but I'll keep it for now, might need to keep stuff seperated in the future ]]--

local M = {}

local interface_roleplay = require('clutchrp.ui.interface_roleplay')
local interface_moderation = require('clutchrp.ui.interface_moderation')
local interface_phone = require('clutchrp.ui.interface_phone')
local command = require('clutchrp.command')

local function ToggleInterfaceRP()
    interface_roleplay.shouldDraw = not interface_roleplay.shouldDraw
    log('I', 'interface', 'interface_roleplay: ' .. tostring(interface_roleplay.shouldDraw))
end

local function ToggleInterfacePhone()
    interface_phone.shouldDraw = not interface_phone.shouldDraw
    log('I', 'interface', 'interface_phone: ' .. tostring(interface_phone.shouldDraw))
end

local function ToggleInterfaceModeration()
    interface_moderation.shouldDraw = not interface_moderation.shouldDraw
    log('I', 'interface', 'interface_moderation: ' .. tostring(interface_moderation.shouldDraw))
end

local function Update(dt)
    if interface_roleplay.shouldDraw then
        interface_roleplay.Draw(dt)
    end

    if interface_moderation.shouldDraw then
        interface_moderation.Draw(dt)
    end

    if interface_phone.shouldDraw then
        interface_phone.Draw(dt)
    end

    command.Draw(dt)
end

local function OnExtensionLoaded()
    interface_phone.OnExtensionLoaded()
end

M.interface_phone = interface_phone
M.ToggleInterfaceRP = ToggleInterfaceRP
M.ToggleInterfaceModeration = ToggleInterfaceModeration
M.ToggleInterfacePhone = ToggleInterfacePhone
M.Update = Update
M.onExtensionLoaded = OnExtensionLoaded

return M