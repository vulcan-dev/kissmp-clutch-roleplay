local M = {}

require('Addons.VK.globals')

-- local pos = {}
-- print('{"x": ' .. tostring(pos.x) .. ', "y": ' .. tostring(pos.y) .. ', "z": ' .. tostring(pos.z) .. '}')

local function draw()
    return G_LuaFormat([[
        local pos = be:getPlayerVehicle(0):getPosition()
        local rot = be:getPlayerVehicle(0):getRotation()

        imgui.Text('[Position] X: ' .. tostring(pos.x) .. ' Y: ' .. tostring(pos.y) .. ' Z: ' .. tostring(pos.z))
        if imgui.IsItemClicked(1) then
            showrc = true
        end

        if showrc then
            if imgui.Begin('Save Data', imgui.BoolPtr(true), bit.bor(imgui.WindowFlags_NoScrollbar ,imgui.WindowFlags_NoResize, imgui.WindowFlags_AlwaysAutoResize)) then
                if imgui.Button('Save text') then
                    imgui.SetClipboardText(tostring(pos.x) .. ', ' .. tostring(pos.y) .. ', ' .. tostring(pos.z))
                end
                imgui.SameLine()
                if imgui.Button('Save JSON') then
                    imgui.SetClipboardText('{\n    "x": ' .. tostring(pos.x) .. ',\n    "y": ' .. tostring(pos.y) .. ',\n    "z": ' .. tostring(pos.z) .. '\n}')
                end
                if imgui.Button('Close') then
                    showrc = false
                end

                imgui.End()
            end
        end

        imgui.Text('[Rotation] RX: ' .. tostring(rot.x) .. ' RY: ' .. tostring(rot.y) .. ' RZ: ' .. tostring(rot.z) .. ' W: ' .. tostring(rot.w))
    ]])
end

M.draw = draw

return M