--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local modules = {
    moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation'),
    utilities = require('addons.vulcan_script.utilities'),
    timed_events = require('addons.vulcan_script.timed_events'),
    rp = require('addons.vulcan_script.extensions.vulcan_rp.rp'),
    server = require('addons.vulcan_script.server')
}

local cooldownTime = 0
M.commands = {
    -- Moderator Commands
    add_role = {
        rank = modules.moderation.RankModerator,
        category = 'Roleplay Utilities',
        description = 'Adds a role to the specified user',
        usage = '/add_role <user> <role>',
        exec = function(executor, args)
            local client = modules.server.GetUser(args[1])
            local role = args[2]

            -- Check if the client exists
            if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(G_ErrorInvalidUser, executor) return end
            client = client.data

            --[[ Check if role exists ]]--
            local found = false
            for _, k in pairs(modules.rp.roles) do
                if role == k then found = true end
            end

            if not found then
                modules.server.DisplayDialogError(G_ErrorInvalidArguments, executor)
                return
            end

            if not modules.rp.HasRole(client, role) then
                local data = modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'roles')
                local roles = {}
                for _, v in pairs(data) do
                    table.insert( roles, v )
                end

                table.insert(roles, role)
                data = roles
                modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'roles', data)
                modules.server.DisplayDialog(client, string.format('%s Has Assigned You the Role: %s', executor.user:getName(), role))
                modules.server.DisplayDialog(executor, 'Successfully added role to user')

                --[[ Check if role is LEO, if so then increase the vehicle limit ]]--
                if modules.rp.IsLeo(client) then
                    modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'vehicleLimit', 11) --[[ 10 cones for example ]]--
                end
            else
                modules.server.DisplayDialog(executor, '[Error] This User has Already Been Assigned This Role')
            end
        end
    },

    remove_role = {
        rank = modules.moderation.RankModerator,
        category = 'Roleplay Utilities',
        description = 'Removes a role from the specified user',
        usage = '/remove_role <user> <role>',
        exec = function(executor, args)
            local client = modules.server.GetUser(args[1])
            local role = args[2]

            -- Check if the client exists
            if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(G_ErrorInvalidUser, executor) return end
            client = client.data

            if modules.rp.HasRole(client, role) then
                local data = modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'roles')
                local roles = {}
                local pos = 1
                for _, v in pairs(data) do
                    if v == role then
                        table.remove( roles, pos)
                    else
                        table.insert( roles, v )
                    end

                    pos = pos + 1
                end

                data = roles
                modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'roles', data)
                modules.server.DisplayDialog(client, string.format('%s Has Removed Your Role: %s', executor.user:getName(), role))
                modules.server.DisplayDialog(executor, 'Successfully Removed Role From User')

                if not modules.rp.IsLeo(client) then
                    modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'vehicleLimit', 2)
                end
            else 
                modules.server.DisplayDialog(executor, 'This User Has Not Been Assigned This Role')
            end
        end
    },

    -- User Commands
    cuff = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Handcuff a person, both must be on foot!',
        usage = '/cuff',
        exec = function(executor, args)
            if not modules.rp.HasRole(executor, 'Police') then modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor) return end

            --[[ Get my vehicle ]]--
            local my_ply = connections[executor.user:getID()]
            local my_vehicle = vehicles[my_ply:getCurrentVehicle()]
            local found = false

            if tostring(my_vehicle:getData():getName()) == 'unicycle' then
                --[[ Get my coords ]]--
                local x = my_vehicle:getTransform():getPosition()[1]
                local y = my_vehicle:getTransform():getPosition()[2]
                local radius = 2

                for _, client in pairs(G_Clients) do
                    --[[ Loop over all clients and get their person ]]
                    if client.user ~= executor.user and client.user:getSecret() ~= 'secret_console' then
                        local their_ply = connections[client.user:getID()]
                        local their_vehicle = vehicles[their_ply:getCurrentVehicle()] or nil

                        if their_vehicle and their_vehicle:getData():getName() == 'unicycle' then
                            found = true
                            local theirX = their_vehicle:getTransform():getPosition()[1]
                            local theirY = their_vehicle:getTransform():getPosition()[2]

                            if (x > theirX - radius and x < theirX + radius) and (y > theirY - radius and y < theirY + radius) then
                                if not client.cuffed.isCuffed then
                                    their_vehicle:sendLua('controller.setFreeze(1)')
                                    modules.server.SendChatMessage(executor.user:getID(), 'Successfully cuffed '..client.user:getName(), modules.server.ColourError)
                                    modules.server.SendChatMessage(client.user:getID(), 'You have been cuffed', modules.server.ColourError)
                                    client.cuffed.isCuffed = true

                                    client.cuffed.executor = executor
                                    return
                                else
                                    their_vehicle:sendLua('controller.setFreeze(0)')
                                    modules.server.SendChatMessage(executor.user:getID(), 'Successfully uncuffed '..client.user:getName(), modules.server.ColourSuccess)
                                    modules.server.SendChatMessage(client.user:getID(), 'You have been uncuffed', modules.server.ColourSuccess)
                                    client.cuffed.isCuffed = false

                                    return
                                end
                            end
                        end
                    end
                end
            else
                modules.server.DisplayDialog(executor, 'You cannot cuff/uncuff someone whilst in a vehicle')
            end

            if not found then
                modules.server.DisplayDialog(executor, 'You cannot cuff/uncuff someone whilst they are in a vehicle')
            end
        end
    },

    drag = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Drag a handcuffed person',
        usage = '/drag',
        exec = function(executor, args)
            if not modules.rp.HasRole(executor, 'Police') then modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor) return end

            --[[ Get my vehicle ]]--
            local my_ply = connections[executor.user:getID()]
            local my_vehicle = vehicles[my_ply:getCurrentVehicle()]
            local found = false

            if tostring(my_vehicle:getData():getName()) == 'unicycle' then
                --[[ Get my coords ]]--
                local x = my_vehicle:getTransform():getPosition()[1]
                local y = my_vehicle:getTransform():getPosition()[2]
                local radius = 2

                for _, client in pairs(G_Clients) do
                    --[[ Loop over all clients and get their person ]]
                    if client.user ~= executor.user and client.user:getSecret() ~= 'secret_console' then
                        local their_ply = connections[client.user:getID()]
                        local their_vehicle = vehicles[their_ply:getCurrentVehicle()] or nil

                        if their_vehicle and their_vehicle:getData():getName() == 'unicycle' then
                            found = true
                            local theirX = their_vehicle:getTransform():getPosition()[1]
                            local theirY = their_vehicle:getTransform():getPosition()[2]

                            if (x > theirX - radius and x < theirX + radius) and (y > theirY - radius and y < theirY + radius) then
                                if client.cuffed.isCuffed and not client.cuffed.isBeingDragged then
                                    modules.server.SendChatMessage(executor.user:getID(), 'Dragging '..client.user:getName(), modules.server.ColourError)
                                    client.cuffed.isBeingDragged = true

                                    client.cuffed.executor = executor
                                    return
                                else
                                    for _, c in pairs(G_Clients) do
                                        if c.user:getID() ~= 1337 then
                                            if c.cuffed.isCuffed and c.cuffed.executor.user == executor.user then
                                                modules.server.SendChatMessage(executor.user:getID(), 'Undragging '..client.user:getName(), modules.server.ColourSuccess)
                                                client.cuffed.isBeingDragged = false

                                                return
                                            end
                                        end
                                    end
                                end
                            else
                                for _, c in pairs(G_Clients) do
                                    if c.user:getID() ~= 1337 then
                                        if c.cuffed.isCuffed and c.cuffed.executor.user == executor.user then
                                            modules.server.SendChatMessage(executor.user:getID(), 'Undragging '..client.user:getName(), modules.server.ColourSuccess)
                                            client.cuffed.isBeingDragged = false

                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                modules.server.DisplayDialog(executor, 'You cannot drag/undrag someone whilst in a vehicle')
            end

            if not found then
                modules.server.DisplayDialog(executor, 'You cannot drag/undrag someone whilst they are in a vehicle')
            end
        end
    },

    get_roles = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Gets the roles of a specific user or yours if not specified',
        usage = '/get_roles (user)',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end
            local client = modules.server.GetUser(args[1])

            -- Check if the client exists
            if not client.success or not modules.server.GetUserKey(client.data, 'rank') then client.data = executor end
            client = client.data

            local roles = modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'roles')
            local count = 0
            for _, role in pairs(roles) do
                count = count + 1
                modules.server.SendChatMessage(executor.user:getID(), '  '..role)
            end

            if count == 0 then
                modules.server.SendChatMessage(executor.user:getID(), 'This user has no roles', modules.server.ColourWarning)
            end
        end
    },

    transfer = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Send someone some money',
        usage = '/transfer <user> <amount>',
        exec = function(executor, args)
            local client = modules.server.GetUser(args[1])
            local amount = tonumber(args[2]) or nil

            -- Check if the client exists
            if not client.success or not modules.server.GetUserKey(client.data, 'rank') then client.data = executor end
            client = client.data

            if amount and type(amount) == 'number' then
                local myMoney = modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money')
                if amount > myMoney then
                    modules.server.DisplayDialog(executor, 'You do not even have that much money, lmfao.')
                    return
                end

                modules.server.DisplayDialog(executor, string.format('You have successfully sent %s $%d', client.user:getName(), amount))
                modules.server.DisplayDialog(client, string.format('You have recieved $%d from %s', amount, client.user:getName()))
                modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'money', modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'money') + amount)
                modules.utilities.EditKey(G_PlayersLocation, executor.user:getSecret(), 'money', modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money') - amount)
            else
                modules.server.DisplayDialogError(G_ErrorInvalidArguments, executor)
            end
        end
    },

    police = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends the police your message',
        usage = '/police <message>',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end
            local message = ''
            for _, v in pairs(args) do
                message = message .. v .. ' '
            end
            
            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            for _, client in pairs(G_Clients) do
                if modules.rp.HasRole(client, 'Police') and modules.rp.IsOnDuty(client) then
                    modules.server.SendChatMessage(client.user:getID(), string.format('Call from %s: %s', executor.user:getName(), message))
                end
            end
        end
    },

    ems = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends the EMS a message',
        usage = '/ems <message>',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end
            local message = ''
            for k, v in pairs(args) do
                message = message .. v .. ' '
            end

            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            for _, client in pairs(G_Clients) do
                if modules.rp.HasRole(client, 'EMS') then
                    modules.server.SendChatMessage(client.user:getID(), string.format('Call from %s: %s', executor.user:getName(), message))
                end
            end

        end
    },

    fire = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends the fire a message',
        usage = '/fire <message>',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end
            local message = ''
            
            for k, v in pairs(args) do
                message = message .. v .. ' '
            end
            
            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end
            
            for _, client in pairs(G_Clients) do
                if modules.rp.HasRole(client, 'Fire') then
                    modules.server.SendChatMessage(client.user:getID(), string.format('Call from %s: %s', executor.user:getName(), message))
                end
            end

        end
    },

    dispatch = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends message as Dispatch',
        usage = '/dispatch <message>',
        exec = function(executor, args)
            if not modules.rp.HasRole(executor, 'Dispatch') then modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor) return end
            local message = ''

            for _, v in pairs(args) do
                message = message .. v .. ' '
            end
            
            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            for _, client in pairs(G_Clients) do
                if modules.rp.IsLeo(client) then
                    modules.server.SendChatMessage(client.user:getID(), string.format('Dispatch: %s', message))
                end
            end
        end
    },

    pd = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Teleports you to Police Depertment',
        usage = '/pd',
        exec = function(executor, args)
            if not modules.rp.HasRole(executor, 'Police') then modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor) return end
            
            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            local data = modules.utilities.GetKey(G_Locations, 'pd_station')
            if vehicle then
                local x = data['x']
                local y = data['y']
                local z = data['z']
                local xr = data['xr']
                local yr = data['yr']
                local zr = data['zr']
                local w = data['w']

                vehicle:setPositionRotation(x, y, z, xr, yr, zr, w)
            else
                modules.server.DisplayDialogError(G_ErrorNotInVehicle, executor)
            end
        end
    },

    fd = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Teleports you to Fire Depertment',
        usage = '/fd',
        exec = function(executor, args)
            if not modules.rp.HasRole(executor, 'Fire') then modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor) return end
            
            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            local data = modules.utilities.GetKey(G_Locations, 'fire_station')
            if vehicle then
                local x = data['x']
                local y = data['y']
                local z = data['z']
                local xr = data['xr']
                local yr = data['yr']
                local zr = data['zr']
                local w = data['w']

                vehicle:setPositionRotation(x, y, z, xr, yr, zr, w)
            else
                modules.server.DisplayDialogError(G_ErrorNotInVehicle, executor)
            end
        end
    },

    twitter = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends message to twitter',
        usage = '/twitter <message>',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end

            local message = ''
            for _, v in pairs(args) do
                message = message .. v .. ' '
            end

            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            for _, client in pairs(G_Clients) do
                modules.server.SendChatMessage(client.user:getID(), string.format('[Twitter @%s]: %s', executor.user:getName(), message), modules.server.ColourTwitter)
            end
        end
    },

    onduty = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Toggles if you\'re an active officer or not',
        usage = '/onduty',
        exec = function(executor, args)
            if not modules.rp.HasRole(executor, 'Police') then modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor) return end

            local onduty = modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'onduty')
            modules.utilities.EditKey(G_PlayersLocation, executor.user:getSecret(), 'onduty', not onduty)

            if not onduty then
                modules.server.DisplayDialog(executor, 'You are now on duty!')
                for _, client in pairs(G_Clients) do
                    if modules.rp.HasRole(client, 'Dispatch') and modules.rp.HasRole(client, 'Police') then
                        modules.server.SendChatMessage(client.user:getID(), string.format('Dispatch: %s is now on duty', executor.user:getName()), modules.server.ColourSuccess)
                        return
                    end
                end
            else
                modules.server.DisplayDialog(executor, 'You are now off duty!')
                for _, client in pairs(G_Clients) do
                    if modules.rp.HasRole(client, 'Dispatch') and modules.rp.HasRole(client, 'Police') then
                        modules.server.SendChatMessage(client.user:getID(), string.format('Dispatch: %s is now off duty', executor.user:getName()), modules.server.ColourWarning)
                        return
                    end
                end
            end
        end
    },

    rob = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Rob a shop',
        usage = '/rob',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end

            if modules.rp.IsOnDuty(executor) then
                modules.server.DisplayDialog(executor, "You are an officer of the law! What do you think you are doing??")
                return
            end

            local count = 0
            for _, client in pairs(G_Clients) do
                if modules.rp.HasRole(client, 'Police') and modules.rp.IsOnDuty(client) then
                    count = count + 1
                end
            end

            if count < 2 then
                modules.server.DisplayDialog(executor, 'There are not enough police online right now')
                return
            end

            local year, month, day, hour, min, sec = os.date('%Y-%m-%d %H:%M:%S'):match('(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')

            local date = {
                year = year,
                month = month,
                day = day,
                hour = hour,
                min = min,
                sec = sec
            }

            if cooldownTime > os.time() then
                modules.server.SendChatMessage(executor.user:getID(), string.format('Priority Cooldown Ends: %s', os.date('%M:%S', cooldownTime - os.time())), modules.server.ColourError)
                return
            end

            if executor.canExecute then
                local ply = connections[executor.user:getID()]
                local vehicle = vehicles[ply:getCurrentVehicle()]

                if vehicle then
                    local x = vehicle:getTransform():getPosition()[1]
                    local y = vehicle:getTransform():getPosition()[2]
                    local z = vehicle:getTransform():getPosition()[2]

                    local name = ''
                    local cash = nil
                    local randomWords = {"Rabbit", "Dildo", "Canvas", "Lighter", "Shoe Lace", "Plastic Bag", "Beauty Magazine", "Torch"}
                    math.randomseed(os.time())

                    local stolen = randomWords[math.random(#randomWords)]
                    local message = ''
                    local time = 20
                    local isInRadius = modules.server.IsInRadius('robbable_shops', 4, x, y)
                    if isInRadius[1] then
                        executor.canExecute = false
                        if isInRadius[2] == 'convenience_store_town' then
                            cash = math.random(320, 1950)
                            name = 'Convenience store in the town'
                            message = 'Successfully stolen 3 beers, a '..stolen..' and $'..cash..'!'
                        elseif isInRadius[2] == 'town_cafe' then
                            cash = math.random(100, 300)
                            message = 'Successfully stolen $'..cash
                            name = 'Town Cafe'
                        elseif isInRadius[2] == 'bank' then
                            time = 40
                            cash = math.random(600, 19000)
                            message = 'Successfully stolen $'..cash
                            name = 'Firwood Savings Bank'
                        end

                        if math.random(0, 100) > 50 then
                            for _, client in pairs(G_Clients) do
                                if modules.rp.HasRole(client, 'Police') and modules.rp.IsOnDuty(client) then
                                    modules.server.SendChatMessage(client.user:getID(), string.format('Dispatch: Silent alarm triggered at the %s, get there quickly!', name), modules.server.ColourError)

                                    client.gps.enabled = true
                                    client.gps.position.x = x
                                    client.gps.position.y = y

                                    client.user:sendLua('core_groundMarkers.resetAll()')
                                    client.user:sendLua('local vec3Destination = vec3('..x..','..y..','..z..') local wps = {} local firstDest, secondDest, distanceDest = map.findClosestRoad(vec3Destination) table.insert(wps, vec3Destination) core_groundMarkers.setFocus(wps)')
                                    modules.server.SendChatMessage(client.user:getID(), 'Dispatch: Sending you the coordinates of the robbery')
                                end
                            end
                        end

                        modules.server.DisplayDialog(executor, 'Robbing store, please wait '..time..' seconds!', time)
                        vehicle:sendLua('controller.setFreeze(1)')
                        modules.timed_events.AddEvent(function()
                            vehicle:sendLua('controller.setFreeze(0)')
                            modules.utilities.EditKey(G_PlayersLocation, executor.user:getSecret(), 'money', modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money') + cash)
                            modules.server.DisplayDialog(executor)
                            executor.canExecute = true
                        end, 'rob_'..executor.user:getID(), time, true)

                        date.min = date.min + 20
                        local exp_sec = os.time{ year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min, sec = date.sec }

                        cooldownTime = exp_sec
                    else
                        modules.server.DisplayDialog(executor, 'You cannot rob this location')
                    end
                else
                    modules.server.DisplayDialogError(G_ErrorNotInVehicle, executor)
                end
            else
                modules.server.DisplayDialog(executor, 'You are already doing this')
            end
        end
    },

    darkweb = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends message to the dark web',
        usage = '/darkweb <message>',
        exec = function(executor, args)
            local message = ''
            for _, v in pairs(args) do
                message = message .. v .. ' '
            end

            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            for _, client in pairs(G_Clients) do
                if not modules.rp.IsLeo(client) then
                    modules.server.SendChatMessage(client.user:getID(), string.format('[Darkweb] Anonymous %d: %s', executor.mid, message), modules.server.ColourDarkweb)
                end
            end
        end
    },

    pr = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sends message from the police radio',
        usage = '/pr <message>',
        exec = function(executor, args)
            local message = ''
            for _, v in pairs(args) do
                message = message .. v .. ' '
            end

            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            for _, client in pairs(G_Clients) do
                if modules.rp.IsLeo(client) then
                    modules.server.SendChatMessage(client.user:getID(), string.format('[Police Radio] %s: %s', executor.user:getName(), message), modules.server.ColourPoliceRadio)
                end
            end
        end
    },

    repair = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Repairs a vehicle (must be near a mechanic)',
        usage = '/repair',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end

            if executor.canExecute then
                local ply = connections[executor.user:getID()]
                local vehicle = vehicles[ply:getCurrentVehicle()]

                if vehicle and vehicle:getData():getName() ~= 'unicycle' then
                    local x = vehicle:getTransform():getPosition()[1]
                    local y = vehicle:getTransform():getPosition()[2]
                    local total = 40
                    local client_money = modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money')
                    if total > client_money then modules.server.DisplayDialog(executor, 'You do not have enough money to afford this. Total is: '..total) return end

                    local isInRadius = modules.server.IsInRadius('repair_stations', 5, x, y)
                    if isInRadius[1] then

                        executor.canExecute = false
                        modules.server.DisplayDialog(executor, 'Reparing, please wait 5 seconds')
                        vehicle:sendLua('controller.setFreeze(1)')
                        modules.timed_events.AddEvent(function()
                            vehicle:sendLua('controller.setFreeze(0)')
                            vehicle:sendLua('recovery.saveHome() recovery.startRecovering() recovery.stopRecovering()')

                            modules.server.DisplayDialog(executor, 'Vehicle repaired! That has costed you $' .. total)
                            modules.utilities.EditKey(G_PlayersLocation, executor.user:getSecret(), 'money', modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money') - total)
                            executor.canExecute = true
                        end, 'repair_'..executor.user:getID(), 5, true)
                    else
                        modules.server.DisplayDialog(executor, 'No repair station found')
                    end
                else
                    modules.server.DisplayDialog(executor, 'You are not in a vehicle')
                end
            else
                modules.server.DisplayDialog(executor, 'You are already doing this')
            end
        end
    },

    set_home = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sets your home for when you do /home',
        usage = '/set_home',
        exec = function(executor, args)
            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            if vehicle then
                executor.home.x = vehicle:getTransform():getPosition()[1]
                executor.home.y = vehicle:getTransform():getPosition()[2]
                executor.home.z = vehicle:getTransform():getPosition()[3]
                executor.home.xr = vehicle:getTransform():getRotation()[1]
                executor.home.yr = vehicle:getTransform():getRotation()[2]
                executor.home.zr = vehicle:getTransform():getRotation()[3]
                executor.home.w = vehicle:getTransform():getRotation()[4]

                modules.server.DisplayDialog(executor, 'Successfully set your home postion. TP back with /home')
            else
                modules.server.DisplayDialog(executor, 'It appears you are not in a vehicle')
            end
        end
    },

    home = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Sets your home for when you do /home',
        usage = '/set_home',
        exec = function(executor, args)
            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            if vehicle then
                vehicle:setPositionRotation(executor.home.x, executor.home.y, executor.home.z, executor.home.xr, executor.home.yr, executor.home.zr, executor.home.w)
                modules.server.DisplayDialog(executor, 'Successfully teleported you home')
            end
        end
    },

    refuel = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Refuels a vehicle (must be near a fuel station)',
        usage = '/refuel',
        exec = function(executor, args)
            if executor.user:getSecret() == 'secret_console' then return end

            --[[ Check if not already performing this action ]]--
            if executor.canExecute then
                local ply = connections[executor.user:getID()]
                local vehicle = vehicles[ply:getCurrentVehicle()]

                if vehicle and vehicle:getData():getName() ~= 'unicycle' then
                    local x = vehicle:getTransform():getPosition()[1]
                    local y = vehicle:getTransform():getPosition()[2]
                    local total = 20
                    local client_money = modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money')
                    if total > client_money then modules.server.DisplayDialog(executor, 'You do not have enough money to afford this. Total is: '..total) return end

                    local isInRadius = modules.server.IsInRadius('fuel_pumps', 2, x, y)
                    if isInRadius[1] then
                        executor.canExecute = false

                        modules.server.DisplayDialog(executor, 'Refueling, please wait 5 seconds')
                        vehicle:sendLua('controller.setFreeze(1)')
                        modules.timed_events.AddEvent(function()
                            vehicle:sendLua('controller.setFreeze(0)')
                            vehicle:sendLua('energyStorage.reset()')
                            modules.server.DisplayDialog(executor, 'Vehicle refueled! That has costed you $' .. total)
                            modules.utilities.EditKey(G_PlayersLocation, executor.user:getSecret(), 'money', modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money') - total)
                            executor.canExecute = true
                        end, 'refuel_'..executor.user:getID(), 5, true)
                        return
                    else
                        modules.server.DisplayDialog(executor, 'No fuel station found')
                    end
                else
                    modules.server.DisplayDialog(executor, 'You are not in a vehicle')
                end
            else
                modules.server.DisplayDialog(executor, 'You are already doing this')
            end
        end
    },

    bank = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Displays your money',
        usage = '/bank',
        exec = function(executor, args)
            local balance = modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'money')
            modules.server.DisplayDialog(executor, 'Current balance: $' .. balance)
        end
    },

    me = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Send a message from you character. Example: "/me says hi" will output (name): says hi',
        usage = '/me message',
        exec = function(executor, args)
            --[[ Put all arguments into the message string ]]
            local message = ''
            for _, v in pairs(args) do
                message = message .. v .. ' '
            end

            --[[ Check if message is valid ]]--
            if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

            --[[ Get my vehicle ]]--
            local my_ply = connections[executor.user:getID()]
            local my_vehicle = vehicles[my_ply:getCurrentVehicle()]

            --[[ Get my coords ]]--
            local x = my_vehicle:getTransform():getPosition()[1]
            local y = my_vehicle:getTransform():getPosition()[2]
            local radius = 10

            for _, client in pairs(G_Clients) do
                if client.user:getID() ~= 1337 and client.connected then
                    --[[ Loop over all clients and get their vehicle ]]
                    local their_ply = connections[client.user:getID()]
                    local their_vehicle = vehicles[their_ply:getCurrentVehicle()]

                    if my_vehicle and their_vehicle then
                        local theirX = their_vehicle:getTransform():getPosition()[1]
                        local theirY = their_vehicle:getTransform():getPosition()[2]

                        if (x > theirX - radius and x < theirX + radius) and (y > theirY - radius and y < theirY + radius) then
                            modules.server.SendChatMessage(client.user:getID(), string.format('(%s): %s', executor.user:getName(), message))
                        end
                    end
                end
            end
        end
    },

    gps = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Set a GPS location',
        usage = '/gps x y z',
        exec = function(executor, args)
            local x = tonumber(args[1]) or nil
            local y = tonumber(args[2]) or nil
            local z = tonumber(args[3]) or nil

            if not x or not y or not z then modules.server.DisplayDialogError(G_ErrorInvalidArguments, executor) end

            executor.gps.enabled = true
            executor.gps.position.x = x
            executor.gps.position.y = y

            executor.user:sendLua('local vec3Destination = vec3('..x..','..y..','..z..') local wps = {} local firstDest, secondDest, distanceDest = map.findClosestRoad(vec3Destination) table.insert(wps, vec3Destination) core_groundMarkers.setFocus(wps)')
            modules.server.DisplayDialog(executor, 'Setting GPS Location')
        end
    },
    gps_clear = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Clear your GPS location',
        usage = '/gps_clear',
        exec = function(executor, args)
            if executor.gps.enabled then
                executor.user:sendLua('core_groundMarkers.resetAll()')
            end
        end
    },

    send_gps = {
        rank = modules.moderation.RankUser,
        category = 'Roleplay Utilities',
        description = 'Send someone your GPS coords',
        usage = '/send_gps <client>',
        exec = function(executor, args)
            local client = modules.server.GetUser(args[1])

            -- Check if the client exists
            if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(G_ErrorInvalidUser, executor) return end
            client = client.data

            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            if vehicle then
                local x = vehicle:getTransform():getPosition()[1]
                local y = vehicle:getTransform():getPosition()[2]
                local z = vehicle:getTransform():getPosition()[3]

                modules.server.DisplayDialog(executor, 'Successfully Send Your Location to '..client.user:getName())
                modules.server.SendChatMessage(client.user:getID(), string.format('%s send to their GPS coords: %s, %s, %s', executor.user:getName(), math.floor(x), math.floor(y), math.floor(z)))
            end
        end
    }
}

local function ReloadModules()
    modules = G_ReloadModules(modules, 'cmd_utilities_rp.lua')
    modules.moderation.ReloadModules()
end

M.ReloadModules = ReloadModules
M.commands = M.commands

return M