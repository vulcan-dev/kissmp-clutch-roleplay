local M = {}

M.gui = {setupEditorGuiTheme = nop}

M.interface = require('clutchrp.interface')
M.phone = require('clutchrp.phone')

local function Update(dt)
    M.interface.Update(dt)
end

M.onUpdate = Update

return M