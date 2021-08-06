local M = {}

local tryResetOld

local function replaceResetHook()
    if network and network.connection.connected and string.find(network.connection.server_info.name, 'Clutch') then
        tryResetOld = extensions.freeroam_freeroam.onResetGameplay
        extensions.freeroam_freeroam.onResetGameplay = function()
            guihooks.trigger('toastrMsg', {type='error', title = 'Vehicle Reset', msg = 'Vehicle resetting has been disabled', config = {timeOut = 2000}})
        end
    end
end

local function onExtensionLoaded()
    replaceResetHook()
end

local function onExtensionUnloaded()
    extensions.freeroam_freeroam.onResetGameplay = tryResetOld
end

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M