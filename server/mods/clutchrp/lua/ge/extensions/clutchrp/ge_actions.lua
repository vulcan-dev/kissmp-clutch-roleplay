local M = {}

local config

local function disableActions()
    if config.restrictActions then
        extensions.core_input_actionFilter.setGroup('clutchrp', config.disabledActions)
        extensions.core_input_actionFilter.addAction(0, 'clutchrp', true)
    end
end

local function onExtensionLoaded()
    config = require("settings/config")
    disableActions()
end

local function onExtensionUnloaded()
    extensions.core_input_actionFilter.addAction(0, 'clutchrp', false)
end

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded

return M