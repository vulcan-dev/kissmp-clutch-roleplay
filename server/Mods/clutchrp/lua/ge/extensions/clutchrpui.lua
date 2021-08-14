local M = {}

M.gui = {setupEditorGuiTheme = nop}

local gui_module = require("ge/extensions/editor/api/gui")
M.interface = require('clutchrp.interface')
local imgui = ui_imgui

local function Update(dt)
    M.interface.Update(dt)
end

M.onUpdate = Update

return M