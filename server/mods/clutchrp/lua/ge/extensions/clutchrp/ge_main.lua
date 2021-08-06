local M = {}

local function onExtensionLoaded()
    log('I', 'clutchrp.onExtensionLoaded', 'called')
end

local function onExtensionUnloaded()
    log('I', 'clutchrp.onExtensionUnloaded', 'called')
end

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M