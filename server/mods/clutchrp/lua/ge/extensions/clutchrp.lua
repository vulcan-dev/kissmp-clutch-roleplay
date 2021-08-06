local M = {}

M.gui = {setupEditorGuiTheme = nop}

M.interface = require('clutchrp.interface')

local function Update(dt)
    M.interface.Update(dt)
end

M.onUpdate = Update

return M