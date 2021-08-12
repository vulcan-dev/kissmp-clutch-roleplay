local M = {}

require('Addons.VK.globals')

--[[
                for vehID, _ in pairs(clients[id].vehicles) do
                if type(_) == 'table' then
                    imgui.Text(tostring(clients[id].vehicles[vehID].getTransform.getPosition[1]))
                end
            end
]]

local function draw()
    return G_LuaFormat([[
        for id, tbl in pairs(clients) do
            if clientPlayers and clientPlayers.id == tbl.id then
                shouldPop = true
                imgui.PushStyleColor2(imgui.Col_Button, imgui.ImVec4(1, 0, 0, 1))
            end

            if imgui.Button(tbl.name) then
                if clientPlayers and clientPlayers.id == tbl.id then
                    clientPlayers = nil
                else
                    clientPlayers = tbl
                end

                drawPlayerInfo = not drawPlayerInfo
            end

            if drawPlayerInfo and clientPlayers then
                imgui.Text('ID: ' .. tostring(clientPlayers.id))
                imgui.Text('Mapped ID: ' .. tostring(clientPlayers.mid))

                imgui.Text('Vehicles: ')
                imgui.SameLine()
                for vehID, veh in pairs(clients[id].vehicles) do
                    if type(veh) == 'table' then
                        imgui.Text(veh.getData.getName)
                        if imgui.IsItemClicked(0) then
                            drawCarInfo = not drawCarInfo
                        end

                        if drawCarInfo then
                            imgui.Begin(clientPlayers.name .. ' - ' .. veh.getData.getName)
                            local pos = veh.getTransform.getPosition
                            local rot = veh.getTransform.getRotation
                            imgui.Text('[Position] X: ' .. tostring(pos[1]) .. ' Y: ' .. tostring(pos[2]) .. ' Z: ' .. tostring(pos[3]))
                            imgui.End()
                        end
                    end
                end
            end
            
            if shouldPop then
                imgui.PopStyleColor(1)
                shouldPop = false
            end
        end
    ]])
end

M.draw = draw

return M