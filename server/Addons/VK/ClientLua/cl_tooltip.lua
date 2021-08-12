local M = {}

require('Addons.VK.globals')

M.canDraw = false
M.message = ''

local function Update(client)
    if M.canDraw then
        client.user:sendLua(G_LuaFormat(string.format([[
            extensions.clutchrp.interface.tooltip.drawData.message = '%s'
            extensions.clutchrp.interface.tooltip.shouldDraw = true
        ]], M.message)))
    else
        client.user:sendLua([[
            extensions.clutchrp.interface.tooltip.drawData.message = ''
            extensions.clutchrp.interface.tooltip.shouldDraw = false
        ]])
    end
end

M.Update = Update

return M