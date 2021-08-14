local M = {}

require('Addons.VK.globals')

M.canDraw = false
M.message = ''

local function Update(client)
    if M.canDraw then
        client.user:sendLua(G_LuaFormat(string.format([[
            extensions.clutchrpui.interface.tooltip.drawData.message = '%s'
            extensions.clutchrpui.interface.tooltip.shouldDraw = true
        ]], M.message)))
    else
        client.user:sendLua(G_LuaFormat[[
            extensions.clutchrpui.interface.tooltip.drawData.message = ''
            extensions.clutchrpui.interface.tooltip.shouldDraw = false
        ]])
    end
end

M.Update = Update

return M