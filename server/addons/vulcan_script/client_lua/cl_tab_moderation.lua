local M = {}

require('addons.vulcan_script.globals')

local function draw()
    return G_LuaFormat([[
        imgui.BeginChild1('Buttons', imgui.ImVec2(0, 60), true)
        for id, tbl in pairs(clients) do
            if clientModeration and clientModeration.id == tbl.id then
                shouldPop = true
                imgui.PushStyleColor2(imgui.Col_Button, imgui.ImVec4(1, 0, 0, 1))
            end

            imgui.SameLine()
            if imgui.Button(tbl.name) then
                if clientModeration and clientModeration.id == tbl.id then
                    clientModeration = nil
                else
                    clientModeration = tbl
                end
            end
            
            if shouldPop then
                imgui.PopStyleColor(1)
                shouldPop = false
            end
        end
        imgui.EndChild()

        if imgui.Button('Teleport to') then
            if clientModeration then
                local myVehicle = be:getPlayerVehicle(0)
                local theirVehicle = be:getObjectByID(vehiclemanager.id_map[clientModeration.current_vehicle or -1] or -1)
                local position = theirVehicle:getPosition()
                local rotation = theirVehicle:getRotation()
                myVehicle:setPositionRotation(position.x+3, position.y, position.z, rotation.x, rotation.y, rotation.z, rotation.w)
            else
                log('I', 'teleport', 'client', 'client not selected')
            end
        end

        imgui.SameLine()
        
        if imgui.Button('Bring') then
            if clientModeration then
                local position = be:getPlayerVehicle(0):getPosition()
                local rotation = be:getPlayerVehicle(0):getRotation()
                local theirVehicle = be:getObjectByID(vehiclemanager.id_map[clientModeration.current_vehicle or -1] or -1)
                theirVehicle:setPositionRotation(position.x+3, position.y, position.z, rotation.x, rotation.y, rotation.z, rotation.w)
            end
        end

        imgui.SameLine()

        if imgui.Button('Enable Tags') then
            kissui.force_disable_nametags = false
        end

        imgui.SameLine()

        if imgui.Button('Disable Tags') then
            kissui.force_disable_nametags = true
        end

        imgui.SameLine()

        if imgui.Button('Teleport to PD') then
            if clientModeration then
                for _, role in pairs(clientModeration.roles) do
                    if string.lower(tostring(role)) == 'police' then
                        local veh = be:getPlayerVehicle(0)
                        veh:setPositionRotation(
                            392.60241699219,
                            101.65773773193,
                            54.220634460449,
                            -0.016780914738774,
                            -0.00033428712049499,
                            -0.4248620569706,
                            0.90510249137878
                        )
                    end
                end
            end
        end
    ]])
end

M.draw = draw

return M