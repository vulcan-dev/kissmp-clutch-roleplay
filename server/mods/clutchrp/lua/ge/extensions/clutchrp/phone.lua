local M = {}

local interface_phone = require('clutchrp.ui.interface_phone')

M.addMessage = function(message)
    interface_phone.addMessage(message)
end

return M