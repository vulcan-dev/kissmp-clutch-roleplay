local M = {}

local function BeginHook()
    return [[
        extensions.clutchrp_interface.onUpdate = function(dt)
            windowMain._Draw(dt)
        end
    ]]
end

M.BeginHook = BeginHook

return M