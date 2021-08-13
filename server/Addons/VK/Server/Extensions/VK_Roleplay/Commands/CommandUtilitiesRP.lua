--[[
    Created by Daniel W (Vitex#1248)
]]--

require('Addons.VK.globals')

local M = {}

local Modules = {
    Moderation = require('Addons.VK.Server.Extensions.VK_Moderation.Moderation'),
    Utilities = require('Addons.VK.Utilities'),
    TimedEvents = require('Addons.VK.TimedEvents'),
    Roleplay = require('Addons.VK.Server.Extensions.VK_Roleplay.Roleplay'),
    Server = require('Addons.VK.Server')
}

local cooldownTime = 0
M.Commands = {}

--[[ Toggle Priority Cooldown ]]--
M.Commands["tprio"] = {
    rank = Modules.Moderation.RankModerator,
    category = 'Moderation',
    description = 'Toggles Priority Cooldown',
    usage = '/tprio',
    exec = function(executor, args)
        if cooldownTime <= 0 then
            local year, month, day, hour, min, sec = os.date('%Y-%m-%d %H:%M:%S'):match('(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')

            local date = {
                year = year,
                month = month,
                day = day,
                hour = hour,
                min = min,
                sec = sec
            }

            date.min = date.min + 20
            local exp_sec = os.time{ year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min, sec = date.sec }

            cooldownTime = exp_sec

            Modules.Server.DisplayDialogWarning('Priority Cooldown has been enabled')
        else
            cooldownTime = 0
            Modules.Server.DisplayDialogSuccess('Priority Cooldown has been disabled')
        end
    end
}

--[[ View Bal ]]--
M.Commands["view_bal"] = {
    rank = Modules.Moderation.RankModerator,
    category = 'Moderation',
    description = 'Prints a users bank account balance',
    usage = '/view_bal <user>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        Modules.Server.SendChatMessage(executor.user:getID(), string.format("%s's balance: $%d", client.user:getName(), client.getKey('money')), Modules.Server.ColourSuccess)
    end
}

--[[ Set Bal ]]--
M.Commands["set_bal"] = {
    rank = Modules.Moderation.RankModerator,
    category = 'Moderation',
    description = 'Sets someones balance',
    usage = '/set_bal <user> <bal>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])
        local balance = tonumber(args[2])

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        client.editKey('money', balance)
        Modules.Server.SendChatMessage(executor.user:getID(), string.format('You set %s balance to $%s', client.user:getName(), balance), Modules.Server.ColourSuccess)
        Modules.Server.SendChatMessage(client.user:getID(), string.format('%s set your balance to $%s', executor.user:getName(), balance), Modules.Server.ColourSuccess)
    end
}

--[[ Add Role ]]--
M.Commands["add_role"] = {
    rank = Modules.Moderation.RankModerator,
    category = 'Roleplay Utilities',
    description = 'Adds a role to the specified user',
    usage = '/add_role <user> <role>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])
        local role = args[2]

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        role = tostring(string.lower(args[2]))

        --[[ Check if role exists ]]--
        local found = false
        for _, k in pairs(Modules.Roleplay.roles) do
            if role == k then found = true end
        end

        if not found then
            Modules.Server.DisplayDialogError(executor, G_ErrorInvalidArguments)
            return
        end

        if not Modules.Roleplay.HasRole(client, role) then
            local data = client.getKey('roles')
            local roles = {}
            for _, v in pairs(data) do
                table.insert( roles, v )
            end

            table.insert(roles, role)
            data = roles
            client.editKey('roles', data)
            Modules.Server.DisplayDialogSuccess(client, string.format('%s Has Assigned You the Role: %s', executor.user:getName(), role))
            Modules.Server.DisplayDialogSuccess(executor, 'Successfully added role to user')

            --[[ Check if role is LEO, if so then increase the vehicle limit ]]--
            if Modules.Roleplay.IsLeo(client) then
                client.editKey('vehicleLimit', 11)
            end
        else
            Modules.Server.DisplayDialogWarning(executor, 'This User has Already Been Assigned This Role')
        end
    end
}

--[[ Remove Role ]]--
M.Commands["remove_role"] = {
    rank = Modules.Moderation.RankModerator,
    category = 'Roleplay Utilities',
    description = 'Removes a role from the specified user',
    usage = '/remove_role <user> <role>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])
        local role = string.lower(args[2])

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        if Modules.Roleplay.HasRole(client, role) then
            local data = client.getKey('roles')
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
            client.editKey('roles', data)
            Modules.Server.DisplayDialog(client, string.format('%s Has Removed Your Role: %s', executor.user:getName(), role))
            Modules.Server.DisplayDialog(executor, 'Successfully Removed Role From User')

            if not Modules.Roleplay.IsLeo(client) then
                client.editKey('vehicleLimit', 2)
            end
        else 
            Modules.Server.DisplayDialog(executor, 'This User Has Not Been Assigned This Role')
        end
    end
}

--[[ Cuff ]]--
M.Commands["cuff"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Handcuff a person, both must be on foot!',
    usage = '/cuff',
    roles = {'police'},
    exec = function(executor, args)
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
                    local their_vehicle = vehicles[their_ply:getCurrentVehicle()]

                    if their_vehicle and their_vehicle:getData():getName() == 'unicycle' then
                        found = true
                        local theirX = their_vehicle:getTransform():getPosition()[1]
                        local theirY = their_vehicle:getTransform():getPosition()[2]

                        if (x > theirX - radius and x < theirX + radius) and (y > theirY - radius and y < theirY + radius) then
                            if not client.cuffed.isCuffed then
                                their_vehicle:sendLua('controller.setFreeze(1)')
                                Modules.Server.SendChatMessage(executor.user:getID(), 'Successfully cuffed '..client.user:getName(), Modules.Server.ColourError)
                                Modules.Server.SendChatMessage(client.user:getID(), 'You have been cuffed', Modules.Server.ColourError)
                                client.cuffed.isCuffed = true

                                client.cuffed.executor = executor
                                return
                            else
                                their_vehicle:sendLua('controller.setFreeze(0)')
                                Modules.Server.SendChatMessage(executor.user:getID(), 'Successfully uncuffed '..client.user:getName(), Modules.Server.ColourSuccess)
                                Modules.Server.SendChatMessage(client.user:getID(), 'You have been uncuffed', Modules.Server.ColourSuccess)
                                client.cuffed.isCuffed = false

                                return
                            end
                        end
                    end
                end
            end
        else
            Modules.Server.DisplayDialogWarning(executor, 'You cannot cuff/uncuff someone whilst in a vehicle')
        end

        if not found then
            Modules.Server.DisplayDialogWarning(executor, 'You cannot cuff/uncuff someone whilst they are in a vehicle')
        end
    end
}

--[[ Drag ]]--
M.Commands["drag"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Drag a handcuffed person',
    roles = {'police'},
    usage = '/drag',
    exec = function(executor, args)
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
                                Modules.Server.SendChatMessage(executor.user:getID(), 'Dragging '..client.user:getName(), Modules.Server.ColourError)
                                client.cuffed.isBeingDragged = true

                                client.cuffed.executor = executor
                                return
                            else
                                for _, c in pairs(G_Clients) do
                                    if c.user:getID() ~= 1337 then
                                        if c.cuffed.isCuffed and c.cuffed.executor.user == executor.user then
                                            Modules.Server.SendChatMessage(executor.user:getID(), 'Undragging '..client.user:getName(), Modules.Server.ColourSuccess)
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
                                        Modules.Server.SendChatMessage(executor.user:getID(), 'Undragging '..client.user:getName(), Modules.Server.ColourSuccess)
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
            Modules.Server.DisplayDialogWarning(executor, 'You cannot drag/undrag someone whilst in a vehicle')
        end

        if not found then
            Modules.Server.DisplayDialogWarning(executor, 'You cannot drag/undrag someone whilst they are in a vehicle')
        end
    end
}

--[[ Get Roles ]]--
M.Commands["get_roles"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Gets the roles of a specific user or yours if not specified',
    usage = '/get_roles (user)',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end
        local client = Modules.Server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then client.data = executor end
        client = client.data

        local roles = client.getKey('roles')
        local count = 0
        for _, role in pairs(roles) do
            count = count + 1
            Modules.Server.SendChatMessage(executor.user:getID(), '  '..role)
        end

        if count == 0 then
            Modules.Server.SendChatMessage(executor.user:getID(), 'This user has no roles', Modules.Server.ColourWarning)
        end
    end
}

--[[ Transfer ]]--
M.Commands["transfer"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Send someone some money',
    usage = '/transfer <user> <amount>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])
        local amount = tonumber(args[2]) or nil

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then client.data = executor end
        client = client.data

        if amount and type(amount) == 'number' then
            local myMoney = executor.getKey('money')
            if amount > myMoney then
                Modules.Server.DisplayDialog(executor, 'You do not even have that much money, lmfao.')
                return
            end

            Modules.Server.DisplayDialog(executor, string.format('You have successfully sent %s $%d', client.user:getName(), amount))
            Modules.Server.DisplayDialog(client, string.format('You have recieved $%d from %s', amount, client.user:getName()))
            client.editKey('money', client.getKey('money') + amount)
            executor.editKey('money', executor.getKey('money') - amount)
        else
            Modules.Server.DisplayDialogError(executor, G_ErrorInvalidArguments)
        end
    end
}

--[[ 911 ]]--
M.Commands["911"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends the police your message',
    usage = '/police <message>',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end
        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            if Modules.Roleplay.HasRole(client, 'police') and Modules.Roleplay.IsOnDuty(client) then
                Modules.Server.SendChatMessage(client.user:getID(), string.format('Call from %s: %s', executor.user:getName(), message))
            end
        end

        Modules.Server.SendChatMessage(executor.user:getID(), 'Successfully phoned police, they should be with you shortly')
    end
}

--[[ EMS ]]--
M.Commands["ems"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends the EMS a message',
    usage = '/ems <message>',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end
        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            if Modules.Roleplay.HasRole(client, 'EMS') then
                Modules.Server.SendChatMessage(client.user:getID(), string.format('Call from %s: %s', executor.user:getName(), message))
            end
        end
    end
}

--[[ Fire ]]--
M.Commands["fire"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends the fire a message',
    usage = '/fire <message>',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end
        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            if Modules.Roleplay.HasRole(client, 'Fire') then
                Modules.Server.SendChatMessage(client.user:getID(), string.format('Call from %s: %s', executor.user:getName(), message))
            end
        end

    end
}

--[[ Dispatch ]]--
M.Commands["dispatch"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends message as Dispatch',
    usage = '/dispatch <message>',
    roles = {'dispatch'},
    exec = function(executor, args)
        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            if Modules.Roleplay.IsLeo(client) then
                Modules.Server.SendChatMessage(client.user:getID(), string.format('Dispatch: %s', message))
            end
        end
    end
}

--[[ PD ]]--
M.Commands["pd"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Teleports you to Police Depertment',
    usage = '/pd',
    roles = {'police', 'dispatch'},
    exec = function(executor, args)
        local ply = connections[executor.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]

        local data = Modules.Utilities.GetKey(G_Locations, 'pd_station')
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
            Modules.Server.DisplayDialogError(executor, G_ErrorNotInVehicle)
        end
    end
}

--[[ FD ]]--
M.Commands["fd"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Teleports you to Fire Depertment',
    usage = '/fd',
    roles = {'fire'},
    exec = function(executor, args)
        local ply = connections[executor.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]

        local data = Modules.Utilities.GetKey(G_Locations, 'fire_station')
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
            Modules.Server.DisplayDialogError(executor, G_ErrorNotInVehicle)
        end
    end
}

--[[ Twitter ]]--
M.Commands["twitter"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends message to twitter',
    usage = '/twitter <message>',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end

        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            Modules.Server.SendChatMessage(client.user:getID(), string.format('[Twitter @%s]: %s', executor.user:getName(), message), Modules.Server.ColourTwitter)
        end
    end
}

--[[ Onduty ]]--
M.Commands["onduty"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Toggles if you\'re an active officer or not',
    usage = '/onduty',
    roles = {'police'},
    exec = function(executor, args)
        local onduty = executor.getKey('onduty')
        executor.editKey('onduty', not onduty)

        if not onduty then
            Modules.Server.DisplayDialog(executor, 'You are now on duty!')
            for _, client in pairs(G_Clients) do
                if Modules.Roleplay.HasRole(client, 'Dispatch') and Modules.Roleplay.HasRole(client, 'police') then
                    Modules.Server.SendChatMessage(client.user:getID(), string.format('Dispatch: %s is now on duty', executor.user:getName()), Modules.Server.ColourSuccess)
                    return
                end
            end
        else
            Modules.Server.DisplayDialog(executor, 'You are now off duty!')
            for _, client in pairs(G_Clients) do
                if Modules.Roleplay.HasRole(client, 'Dispatch') and Modules.Roleplay.HasRole(client, 'police') then
                    Modules.Server.SendChatMessage(client.user:getID(), string.format('Dispatch: %s is now off duty', executor.user:getName()), Modules.Server.ColourWarning)
                    return
                end
            end
        end
    end
}

--[[ Rob ]]--
M.Commands["rob"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Rob a shop',
    usage = '/rob',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end

        if Modules.Roleplay.IsOnDuty(executor) then
            Modules.Server.DisplayDialog(executor, "You are an officer of the law! What do you think you are doing??")
            return
        end

        local count = 0
        for _, client in pairs(G_Clients) do
            if Modules.Roleplay.HasRole(client, 'police') and Modules.Roleplay.IsOnDuty(client) then
                count = count + 1
            end
        end

        if count < 2 then
            Modules.Server.DisplayDialog(executor, 'There are not enough police online right now')
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
            Modules.Server.SendChatMessage(executor.user:getID(), string.format('Priority Cooldown Ends: %s', os.date('%M:%S', cooldownTime - os.time())), Modules.Server.ColourError)
            return
        end

        if not executor.commandCooldown then
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
                local isInRadius = Modules.Server.IsInRadius('robbable_shops', 4, x, y)
                if isInRadius[1] then
                    executor.commandCooldown = true
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
                            if Modules.Roleplay.HasRole(client, 'police') and Modules.Roleplay.IsOnDuty(client) then
                                Modules.Server.SendChatMessage(client.user:getID(), string.format('Dispatch: Silent alarm triggered at the %s, get there quickly!', name), Modules.Server.ColourError)

                                client.gps.enabled = true
                                client.gps.position.x = x
                                client.gps.position.y = y

                                client.user:sendLua('core_groundMarkers.resetAll()')
                                client.user:sendLua('local vec3Destination = vec3('..x..','..y..','..z..') local wps = {} local firstDest, secondDest, distanceDest = map.findClosestRoad(vec3Destination) table.insert(wps, vec3Destination) core_groundMarkers.setFocus(wps)')
                                Modules.Server.SendChatMessage(client.user:getID(), 'Dispatch: Sending you the coordinates of the robbery')
                            end
                        end
                    end

                    Modules.Server.DisplayDialog(executor, 'Robbing store, please wait '..time..' seconds!', time)
                    vehicle:sendLua('controller.setFreeze(1)')
                    Modules.TimedEvents.AddEvent(function()
                        vehicle:sendLua('controller.setFreeze(0)')
                        executor.editKey('money', executor.getKey('money') + cash)
                        Modules.Server.DisplayDialog(executor)
                        executor.commandCooldown = false
                    end, 'rob_'..executor.user:getID(), time, true)

                    Modules.Server.DisplayDialog(executor, message, 4)

                    date.min = date.min + 20
                    local exp_sec = os.time{ year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min, sec = date.sec }

                    cooldownTime = exp_sec
                else
                    Modules.Server.DisplayDialogW(executor, 'You cannot rob this location')
                end
            else
                Modules.Server.DisplayDialogError(executor, G_ErrorNotInVehicle)
            end
        else
            Modules.Server.DisplayDialog(executor, 'You are already doing this')
        end
    end
}

--[[ Darkweb ]]--
M.Commands["darkweb"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends message to the dark web',
    usage = '/darkweb <message>',
    exec = function(executor, args)
        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            if not Modules.Roleplay.IsLeo(client) then
                Modules.Server.SendChatMessage(client.user:getID(), string.format('[Darkweb] Anonymous %d: %s', executor.mid, message), Modules.Server.ColourDarkweb)
            end
        end
    end
}

--[[ PR ]]--
M.Commands["pr"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sends message from the police radio',
    usage = '/pr <message>',
    roles = {'police', 'dispatch', 'fire', 'ems'},
    exec = function(executor, args)
        local message = Modules.Utilities.GetMessage(args, false)

        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        for _, client in pairs(G_Clients) do
            if Modules.Roleplay.IsLeo(client) then
                Modules.Server.SendChatMessage(client.user:getID(), string.format('[Police Radio] %s: %s', executor.user:getName(), message), Modules.Server.ColourPoliceRadio)
            end
        end
    end
}

--[[ Repair ]]--
M.Commands["repair"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Repairs a vehicle (must be near a mechanic)',
    usage = '/repair',
    exec = function(executor, args)
        if executor.user:getSecret() == 'secret_console' then return end

        if not executor.commandCooldown then
            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            if vehicle and vehicle:getData():getName() ~= 'unicycle' then
                local x = vehicle:getTransform():getPosition()[1]
                local y = vehicle:getTransform():getPosition()[2]
                local total = 40
                local client_money = executor.getKey('money')
                if total > client_money then Modules.Server.DisplayDialog(executor, 'You do not have enough money to afford this. Total is: '..total) return end

                local isInRadius = Modules.Server.IsInRadius('repair_stations', 5, x, y)
                if isInRadius[1] then

                    executor.commandCooldown = true
                    Modules.Server.DisplayDialog(executor, 'Reparing, please wait 5 seconds')
                    vehicle:sendLua('controller.setFreeze(1)')
                    Modules.TimedEvents.AddEvent(function()
                        vehicle:sendLua('controller.setFreeze(0)')
                        vehicle:sendLua('recovery.saveHome() recovery.startRecovering() recovery.stopRecovering()')

                        Modules.Server.DisplayDialog(executor, 'Vehicle repaired! That has costed you $' .. total)
                        executor.editKey('money', executor.getKey('money') - total)
                        executor.commandCooldown = false
                    end, 'repair_'..executor.user:getID(), 5, true)
                else
                    Modules.Server.DisplayDialog(executor, 'No repair station found')
                end
            else
                Modules.Server.DisplayDialogError(executor, G_ErrorNotInVehicle)
            end
        else
            Modules.Server.DisplayDialog(executor, 'You are already doing this')
        end
    end
}

--[[ Set Home ]]--
M.Commands["set_home"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sets your home for when you do /home',
    usage = '/set_home',
    exec = function(executor, args)
        local ply = connections[executor.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]

        if vehicle then
            local x = vehicle:getTransform():getPosition()[1]
            local y = vehicle:getTransform():getPosition()[2]
            local z = vehicle:getTransform():getPosition()[3]
            local xr = vehicle:getTransform():getRotation()[1]
            local yr = vehicle:getTransform():getRotation()[2]
            local zr = vehicle:getTransform():getRotation()[3]
            local w = vehicle:getTransform():getRotation()[4]

            executor.setHome(x, y, z, xr, yr, zr, w)

            Modules.Server.DisplayDialog(executor, 'Successfully set your home postion. TP back with /home')
        else
            Modules.Server.DisplayDialogError(executor, G_ErrorNotInVehicle)
        end
    end
}

--[[ Home ]]--
M.Commands["home"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Sets your home for when you do /home',
    usage = '/home',
    exec = function(executor, args)
        local ply = connections[executor.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]

        if vehicle then
            vehicle:setPositionRotation(executor.getHome().x, executor.getHome().y, executor.getHome().z, executor.getHome().xr, executor.getHome().yr, executor.getHome().zr, executor.getHome().w)
            Modules.Server.DisplayDialog(executor, 'Successfully teleported you home')
        end
    end
}

--[[ Refuel ]]--
M.Commands["refuel"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Refuels a vehicle (must be near a fuel station)',
    usage = '/refuel',
    exec = function(executor, args)
        --[[ Check if not already performing this action ]]--
        if not executor.commandCooldown then
            local ply = connections[executor.user:getID()]
            local vehicle = vehicles[ply:getCurrentVehicle()]

            if vehicle and vehicle:getData():getName() ~= 'unicycle' then
                local x = vehicle:getTransform():getPosition()[1]
                local y = vehicle:getTransform():getPosition()[2]
                local total = 20
                local client_money = executor.getKey('money')
                if total > client_money then Modules.Server.DisplayDialog(executor, 'You do not have enough money to afford this. Total is: '..total) return end

                local isInRadius = Modules.Server.IsInRadius('fuel_pumps', 2, x, y)
                if isInRadius[1] then
                    executor.commandCooldown = true

                    Modules.Server.DisplayDialog(executor, 'Refueling, please wait 5 seconds')
                    vehicle:sendLua('controller.setFreeze(1)')
                    Modules.TimedEvents.AddEvent(function()
                        vehicle:sendLua('controller.setFreeze(0)')
                        vehicle:sendLua('energyStorage.reset()')
                        Modules.Server.DisplayDialog(executor, 'Vehicle refueled! That has costed you $' .. total)
                        executor.editKey('money', executor.getKey('money') + total)
                        executor.commandCooldown = false
                    end, 'refuel_'..executor.user:getID(), 5, true)
                    return
                else
                    Modules.Server.DisplayDialog(executor, 'No fuel station found')
                end
            else
                Modules.Server.DisplayDialogError(executor, G_ErrorNotInVehicle)
            end
        else
            Modules.Server.DisplayDialog(executor, 'You are already doing this')
        end
    end
}

--[[ Bank ]]--
M.Commands["bank"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Displays your money',
    usage = '/bank',
    exec = function(executor, args)
        Modules.Server.DisplayDialog(executor, 'Current balance: $' .. tostring(executor.getKey('money')))
    end
}

--[[ Me ]]--
M.Commands["do"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Send a message from your character when performing an action',
    usage = '/do <message>',
    exec = function(executor, args)
        local message = Modules.Utilities.GetMessage(args, false)

        for _, client in pairs(G_Clients) do
            Modules.Server.SendChatMessage(client.user:getID(), string.format('%s: %s', executor.user:getName(), message))
        end
    end
}

--[[ Me ]]--
M.Commands["me"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Send a message from you character. Example: "/me says hi" will output (name): says hi',
    usage = '/me <message>',
    exec = function(executor, args)
        local message = Modules.Utilities.GetMessage(args, false)

        --[[ Check if message is valid ]]--
        if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

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
                        Modules.Server.SendChatMessage(client.user:getID(), string.format('(%s): %s', executor.user:getName(), message))
                    end
                end
            end
        end
    end
}

--[[ GPS ]]--
M.Commands["gps"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Set a GPS location',
    usage = '/gps x y z',
    exec = function(executor, args)
        local x = tonumber(args[1]) or nil
        local y = tonumber(args[2]) or nil
        local z = tonumber(args[3]) or nil

        if not x or not y or not z then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidArguments) end

        executor.gps.enabled = true
        executor.gps.position.x = x
        executor.gps.position.y = y

        executor.user:sendLua('local vec3Destination = vec3('..x..','..y..','..z..') local wps = {} local firstDest, secondDest, distanceDest = map.findClosestRoad(vec3Destination) table.insert(wps, vec3Destination) core_groundMarkers.setFocus(wps)')
        Modules.Server.DisplayDialog(executor, 'Setting GPS Location')
    end
}

--[[ GPS Clear ]]--
M.Commands["gps_clear"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Clear your GPS location',
    alias = 'clear_gps',
    usage = '/gps_clear',
    exec = function(executor, args)
        if executor.gps.enabled then
            executor.user:sendLua('core_groundMarkers.resetAll()')
        end
    end
}

--[[ Send GPS ]]--
M.Commands["send_gps"] = {
    rank = Modules.Moderation.RankUser,
    category = 'Roleplay Utilities',
    description = 'Send someone your GPS coords',
    usage = '/send_gps <client>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        local ply = connections[executor.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]

        if vehicle then
            local x = vehicle:getTransform():getPosition()[1]
            local y = vehicle:getTransform():getPosition()[2]
            local z = vehicle:getTransform():getPosition()[3]

            Modules.Server.DisplayDialog(executor, 'Successfully Send Your Location to '..client.user:getName())
            Modules.Server.SendChatMessage(client.user:getID(), string.format('%s send to their GPS coords: %s, %s, %s', executor.user:getName(), math.floor(x), math.floor(y), math.floor(z)))
        end
    end
}

--[[ Add Twitter Message (For Phone) ]]--
M.Commands["addtm"] = {
    rank = Modules.Moderation.RankUser,
    exec = function(executor, args) -- executor will be user. run this command from the mod!
        -- TODO: Save all messages in json and load them in for the user when they join, I might make a seperate function in the mod so I'm not calling it a ton. I can simply just load the json data into it
        if args[1] then
            local message = Modules.Utilities.GetMessage(args, false)

            message = executor.user:getName() .. ': ' .. message

            for _, client in pairs(G_Clients) do
                client.user:sendLua(G_LuaFormat(string.format([[
                    extensions.clutchrp.phone.addMessage('%s')
                ]], message)))
            end
        end
    end
}

local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'CommandUtilitiesRoleplay.lua')
    Modules.Moderation.ReloadModules()
end

M.ReloadModules = ReloadModules
M.Commands = M.Commands

return M