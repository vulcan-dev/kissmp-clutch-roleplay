--[[
    Created by Daniel W (Vitex#1248)
]]--

require('Addons.VK.globals')

local M = {}

local nextUpdatePaycheckRules = 0
local nextUpdateTooltip = 0
local money = 60
local canDrawTooltip = false

local Modules = {
    CommandUtilitiesRP = require('Addons.VK.Server.Extensions.VK_Roleplay.Commands.CommandUtilitiesRP'),
    Utilities = require('Addons.VK.Utilities'),
    TimedEvents = require('Addons.VK.TimedEvents'),
    Moderation = require('Addons.VK.Server.Extensions.VK_Moderation.Moderation'),
    Roleplay = require('Addons.VK.Server.Extensions.VK_Roleplay.Roleplay'),
    Server = require('Addons.VK.Server'),

    CTooltip = require('Addons.VK.Client.CTooltip')
}

M.Callbacks = {
    ['OnVehicleSpawned'] = function(vehicle_id, client_id)
        local client = G_Clients[client_id]

        --[[ Check if vehicle config is allowed ]]

        local vData = decode_json(vehicles[vehicle_id]:getData():getPartsConfig())
        local blacklisted = {
            "lightbar",
            "ramp",
            "citybus_jato_R",
            "citybus_ramplow",
            "semi_ramplow",
            "ramplow",
            "ramplow_L"
        }

        for name, part in pairs(vData.parts) do
            for _, blacklist in pairs(blacklisted) do
                if (string.find(part, blacklist) and (not Modules.Roleplay.IsLeo(client) and name ~= 'van_rollback_lightbar')) or part == blacklist then
                    Modules.Server.DisplayDialogError(client, G_ErrorInvalidVehiclePermissions)
                    client.vehicles.remove(client, connections[client_id]:getCurrentVehicle())
                    client.user:sendLua('commands.setFreeCamera()')
                    return
                end
            end
        end
    end,

    ['Tick'] = function()
        if os.time() >= nextUpdatePaycheckRules then
            nextUpdatePaycheckRules = os.time() + 1200

            for _, client in pairs(G_Clients) do
                if client.user:getID() ~= 1337 and client.connected then
                    -- [[ Send Money ]]
                    if Modules.Roleplay.IsLeo(client) then money = math.random( 200, 400 )
                    else money = math.random( 60, 140 ) end
                    client.editCharacter('money', client.getActiveCharacter().money + money)
                    Modules.Server.DisplayDialog(client, 'You have received a paycheck of $'..money..'!')

                    --[[ Show Discord ]]
                    Modules.Server.SendChatMessage(client.user:getID(), 'Make sure to read our rules at /discord', Modules.Server.ColourSuccess)
                end
            end
        end

        if os.time() >= nextUpdateTooltip then
            nextUpdateTooltip = os.time() + 1
            for _, client in pairs(G_Clients) do
                if client.user:getID() ~= 1337 and client.connected then
                    local my_ply = connections[client.user:getID()]
                    local my_vehicle = vehicles[my_ply:getCurrentVehicle()]
                    if my_vehicle then
                        local mx = my_vehicle:getTransform():getPosition()[1]
                        local my = my_vehicle:getTransform():getPosition()[2]
                        if my_vehicle:getData():getName() ~= 'unicycle' then
                            local inRadiusPump = Modules.Server.IsInRadius('fuel_pumps', 2, mx, my)
                            local inInRadiusRepair = Modules.Server.IsInRadius('repair_stations', 2, mx, my)
                            if inRadiusPump[1] then
                                Modules.CTooltip.canDraw = true
                                Modules.CTooltip.message = 'Open the Roleplay Menu or do /refuel to refuel'
                            else if inInRadiusRepair[1] then
                                Modules.CTooltip.canDraw = true
                                Modules.CTooltip.message = 'Open the Roleplay Menu or do /repair to repair'
                            else
                                Modules.CTooltip.canDraw = false
                            end end
                        end

                        local inInRadiusRob = Modules.Server.IsInRadius('robbable_shops', 2, mx, my)
                        if inInRadiusRob[1] then
                            canDrawTooltip = true
                            Modules.CTooltip.canDraw = true
                            Modules.CTooltip.message = 'Open the Roleplay Menu or do /rob to rob this place'
                        else
                            -- Otherwise this will override everything else and stop it from drawing
                            if not Modules.CTooltip.canDraw then
                                Modules.CTooltip.canDraw = false
                            end
                        end
                    else
                        -- KissMP doesn't like it when you get out and in a car so if you were already drawing a tooltip then it will stay forever
                        if not Modules.CTooltip.canDraw then
                            Modules.CTooltip.canDraw = false
                        end
                    end
                end
            end
        end

        for _, client in pairs(G_Clients) do
            if client.user:getID() ~= 1337 and client.connected then
                --[[ Dragging ]]--
                if client.cuffed.isBeingDragged then
                    local my_ply = connections[client.cuffed.executor.user:getID()]
                    local my_vehicle = vehicles[my_ply:getCurrentVehicle()]
                    local mx = my_vehicle:getTransform():getPosition()[1]
                    local my = my_vehicle:getTransform():getPosition()[2]

                    local mz = my_vehicle:getTransform():getPosition()[3]
                    local mxr = my_vehicle:getTransform():getRotation()[1]
                    local myr = my_vehicle:getTransform():getRotation()[2]
                    local mzr = my_vehicle:getTransform():getRotation()[3]
                    local mw = my_vehicle:getTransform():getRotation()[4]

                    local their_ply = connections[client.user:getID()]
                    local their_vehicle = vehicles[their_ply:getCurrentVehicle()]

                    their_vehicle:setPositionRotation(mx, my+1, mz, mxr, myr, mzr, mw)
                end

                --[[ GPS ]]--
                if client.gps.enabled then
                    local my_ply = connections[client.user:getID()]
                    local my_vehicle = vehicles[my_ply:getCurrentVehicle()]

                    if my_vehicle then
                        local x = my_vehicle:getTransform():getPosition()[1]
                        local y = my_vehicle:getTransform():getPosition()[2]

                        -- FIXME error here
                        if (x > client.gps.position.x - 20 and x < client.gps.position.x + 20) and (y > client.gps.position.y - 20 and y < client.gps.position.y + 20) then
                            client.user:sendLua('core_groundMarkers.resetAll()')
                            client.gps.enabled = false
                            client.gps.position = { x = 0, y = 0, z = 0 }

                            Modules.Server.DisplayDialog(client, '[CRP Navigation] You have arrived at your destination')
                        end
                    else
                        client.user:sendLua('core_groundMarkers.resetAll()')
                        client.gps.enabled = false
                        client.gps.position = { x = 0, y = 0, z = 0 }
                    end
                end

                Modules.CTooltip.Update(client)
            end
        end
    end,

    ['ReloadModules'] = function()
        Modules = G_ReloadModules(Modules, 'VK_Roleplay.lua')
        for _, module in pairs(Modules) do
            if module.ReloadModules then
                module.ReloadModules()
            end
        end

        G_AddCommandTable(Modules.CommandUtilitiesRP.Commands)
    end
}

return M