--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local nextUpdatePaycheckRules = 0
local nextUpdateTooltip = 0
local money = 60
local canDrawTooltip = false

local modules = {
    cmd_utilities_rp = require('addons.vulcan_script.extensions.vulcan_rp.commands.cmd_utilities_rp'),
    utilities = require('addons.vulcan_script.utilities'),
    timed_events = require('addons.vulcan_script.timed_events'),
    moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation'),
    rp = require('addons.vulcan_script.extensions.vulcan_rp.rp'),
    server = require('addons.vulcan_script.server'),

    cl_tooltip = require('addons.vulcan_script.client_lua.cl_tooltip')
}

M.callbacks = {
    VK_PlayerDisconnect = function(client)
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'onduty', false)
    end,

    VK_VehicleSpawn = function(vehicle_id, client_id)
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
                if (string.find(part, blacklist) and (not modules.rp.IsLeo(client) and name ~= 'van_rollback_lightbar')) or part == blacklist then
                    modules.server.DisplayDialogError(client, G_ErrorInvalidVehiclePermissions)
                    client.vehicles.remove(client, connections[client_id]:getCurrentVehicle())
                    client.user:sendLua('commands.setFreeCamera()')
                    return
                end
            end
        end
    end,

    VK_Tick = function()
        if os.time() >= nextUpdatePaycheckRules then
            nextUpdatePaycheckRules = os.time() + 1200

            for _, client in pairs(G_Clients) do
                if client.user:getID() ~= 1337 and client.connected then
                    -- [[ Send Money ]]
                    if modules.rp.IsLeo(client) then money = math.random( 200, 400 )
                    else money = math.random( 60, 140 ) end
                    modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'money', modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'money') + money)
                    modules.server.DisplayDialog(client, 'You have received a paycheck of $'..money..'!')

                    --[[ Show Discord ]]
                    modules.server.SendChatMessage(client.user:getID(), 'Make sure to read our rules at /discord', modules.server.ColourSuccess)
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
                            local inRadiusPump = modules.server.IsInRadius('fuel_pumps', 2, mx, my)
                            local inInRadiusRepair = modules.server.IsInRadius('repair_stations', 2, mx, my)
                            if inRadiusPump[1] then
                                modules.cl_tooltip.canDraw = true
                                modules.cl_tooltip.message = 'Open the Roleplay Menu or do /refuel to refuel'
                            else if inInRadiusRepair[1] then
                                modules.cl_tooltip.canDraw = true
                                modules.cl_tooltip.message = 'Open the Roleplay Menu or do /repair to repair'
                            else
                                modules.cl_tooltip.canDraw = false
                            end end
                        end

                        local inInRadiusRob = modules.server.IsInRadius('robbable_shops', 2, mx, my)
                        if inInRadiusRob[1] then
                            canDrawTooltip = true
                            modules.cl_tooltip.canDraw = true
                            modules.cl_tooltip.message = 'Open the Roleplay Menu or do /rob to rob this place'
                        else
                            -- Otherwise this will override everything else and stop it from drawing
                            if not modules.cl_tooltip.canDraw then
                                modules.cl_tooltip.canDraw = false
                            end
                        end
                    else
                        -- KissMP doesn't like it when you get out and in a car so if you were already drawing a tooltip then it will stay forever
                        if not modules.cl_tooltip.canDraw then
                            modules.cl_tooltip.canDraw = false
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

                            modules.server.DisplayDialog(client, '[CRP Navigation] You have arrived at your destination')
                        end
                    end
                end

                modules.cl_tooltip.Update(client)
            end
        end
    end
}

local function ReloadModules()
    modules = G_ReloadModules(modules, 'vulcan_rp.lua')
    for _, module in pairs(modules) do
        if module.ReloadModules then
            module.ReloadModules()
        end
    end

    G_AddCommandTable(modules.cmd_utilities_rp.commands)
end

M.callbacks = M.callbacks
M.ReloadModules = ReloadModules

return M