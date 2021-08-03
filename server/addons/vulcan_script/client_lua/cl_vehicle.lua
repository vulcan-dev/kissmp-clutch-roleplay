local M = {}

local function setFreeze(value)
    return G_LuaFormat(string.format([[
        local vehicle = be:getPlayerVehicle(0)
        vehicle:queueLuaCommand('controller.setFreeze(%d)')
    ]], value or 0))
end

M.setFreeze = setFreeze

return M