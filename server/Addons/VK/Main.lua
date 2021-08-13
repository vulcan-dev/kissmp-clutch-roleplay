--[[
    Created by Daniel W (Vitex#1248)
]]

require('Addons.VK.globals')
require('Addons.VK.Server.Hooks')

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    Callbacks = require('Addons.VK.Server.Callbacks'),
}

local function Initialize()
    G_Level = G_LevelDebug

    Modules = G_ReloadModules(Modules, 'Main.lua')

    --[[ Load Extensions ]]--
    local Extensions = Modules.Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in pairs(Extensions) do
        _Extensions[extension] = Modules.Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]]--
    for name, _ in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end

    for name, _ in pairs(Modules) do
        if Modules[name].Callbacks then
            for callbackName, callback in pairs(Modules[name].Callbacks) do
                Hooks.Register(callbackName, name, callback)
            end
        end
    end

    Hooks.Register('[Main] Initialize', 'Initialize', Initialize)
    Hooks.Reload()
end

Initialize()