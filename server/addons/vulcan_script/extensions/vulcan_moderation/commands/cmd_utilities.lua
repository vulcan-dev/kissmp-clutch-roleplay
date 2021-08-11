--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local modules = {
    utilities = require('addons.vulcan_script.utilities'),
    moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation'),
    server = require('addons.vulcan_script.server'),

    cl_environment = require('addons.vulcan_script.client_lua.cl_environment')
}

M.commands = {}

--[[ Advertise ]]--
M.commands["advertise"] = {
    rank = modules.moderation.RankOwner,
    category = 'Moderation Utilities',
    description = 'Sends a message to chat without any user',
    usage = '/advertise <message>',
    exec = function(executor, args)
        local message = ''
        for _, str in pairs(args) do
            message = message .. str .. ' '
        end

        -- Check if message is valid
        if not message or not args[1] then modules.server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        modules.server.SendChatMessage('[Advertisement] ' .. tostring(message))
    end
}

--[[ Say ]]--
M.commands["say"] = {
    rank = modules.moderation.RankOwner,
    category = 'Moderation Utilities',
    description = 'Sends a message to chat without any user',
    usage = '/say <message>',
    exec = function(executor, args)
        local message = ''
        for k, v in pairs(args) do
            message = message .. v .. ' '
        end

        -- Check if message is valid
        if not message or not args[1] then modules.server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        if not message then modules.server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end
        modules.server.SendChatMessage('[Console]: ' .. tostring(message))
    end
}

--[[ Time Play ]]--
M.commands["time_play"] = {
    rank = modules.moderation.RankAdmin,
    category = 'Moderation Utilities',
    description = 'Plays the time',
    usage = '/time_play',
    exec = function(executor, args)
        G_Environment.time.play = true

        for _, client in pairs(G_Clients) do
            client.user:sendLua('extensions.core_environment.setTimeOfDay({time='..G_Environment.time.time..',play='..tostring(G_Environment.time.play)..'})')
            modules.server.DisplayDialog(client, '[Enviroment] Time is playing')
        end
    end
}

--[[ Time Stop ]]--
M.commands["time_stop"] = {
    rank = modules.moderation.RankAdmin,
    category = 'Moderation Utilities',
    description = 'Stops the time',
    usage = '/time_stop',
    exec = function(executor, args)
        G_Environment.time.play = false

        for _, client in pairs(G_Clients) do
            client.user:sendLua('extensions.core_environment.setTimeOfDay({time=extensions.core_environment.getTimeOfDay().time, play=false})')
            modules.server.DisplayDialog(client, '[Enviroment] Time is not playing')
        end
    end
}

--[[ DVA ]]--
M.commands["cleanup"] = {
    rank = modules.moderation.RankAdmin,
    category = 'Moderation Utilities',
    description = 'Cleans up everyone\'s car',
    usage = '/cleanup',
    exec = function(executor, args)
        for _, client in pairs(G_Clients) do
            if client.user:getID() ~= 1337 then
                modules.server.DisplayDialog(client, 'Server has been cleaned up')
                client.vehicles.clear(client)
                client.user:sendLua('commands.setFreeCamera()')
            end
        end
    end
}

--[[ Set Wind ]]--
M.commands["set_wind"] = {
    rank = modules.moderation.RankAdmin,
    category = 'Moderation Utilities',
    description = 'Sets the environment temperature',
    usage = '/set_wind (user) (speed_x) (speed_y) (speed_z)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local speed_x = (not client.success and args[1] or args[2]) or 0
        local speed_y = (not client.success and args[2] or args[3]) or 0
        local speed_z = (not client.success and args[3] or args[4]) or 0

        G_Environment.wind.x = speed_x
        G_Environment.wind.y = speed_y
        G_Environment.wind.z = speed_z
        
        if not client.success then
            for _, c in pairs(G_Clients) do
                if connections[c.user:getID()] then
                    c.user:sendLua(modules.cl_environment.setWind({x = speed_x, y = speed_y, z = speed_z}))
                    modules.server.DisplayDialog(c, string.format('[Enviroment] Set wind speed to %s, %s, %s', speed_x, speed_y, speed_z))
                    return
                end
            end
        else
            client = client.data

            client.user:sendLua(modules.cl_environment.setWind({x = speed_x, y = speed_y, z = speed_z}))

            modules.server.DisplayDialog(client, string.format('[Enviroment] Set wind speed to %s, %s, %s', speed_x, speed_y, speed_z))
        end
    end
}

--[[ Enable Nametags ]]--
M.commands["enable_tags"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation Utilties',
    description = 'Enable name tags (should only be used when moderating)',
    usage = '/enable_tags',
    alias = 'et',
    exec = function(executor, args)
        executor.user:sendLua('kissui.force_disable_nametags = false')
        modules.server.DisplayDialog(executor, 'Successfully enabled nametags')
    end
}

--[[ Disable Nametags ]]--
M.commands["disable_tags"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation Utilties',
    description = 'Disable name tags',
    usage = '/disable_tags',
    alias = 'dt',
    exec = function(executor, args)
        executor.user:sendLua('kissui.force_disable_nametags = true')
        modules.server.DisplayDialog(executor, 'Successfully disabled nametags')
    end
}

--[[ Set Time ]]--
M.commands["set_rain"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation Utilities',
    description = 'Sets the rain amount',
    usage = '/set_rain (amount_of_rain)',
    exec = function(executor, args)
        local rainAmount = args[1] or 40

        G_Environment.weather.rain = rainAmount

        for _, client in pairs(G_Clients) do
            client.user:sendLua(modules.cl_environment.setPrecipitation(rainAmount))
        end
    end
}

--[[ Set Time ]]--
M.commands["set_time"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation Utilities',
    alias = "time_set",
    description = 'Sets the time for everyone',
    usage = '/set_time <hh:mm:ss>',
    exec = function(executor, args)
        if not args[1] then modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments) return end
        local time_args = {}

        local i = 1
        for token in string.gmatch(args[1], "[^:]+") do
            time_args[i] = token

            i = i + 1
        end

        if not modules.utilities.IsNumber(time_args[1]) then modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments) return end

        time_args[1] = time_args[1] or 0

        if not time_args[1] then time_args[1] = args[1] end

        time_args[2] = time_args[2] or 0
        time_args[3] = time_args[3] or 0

        local time = (((time_args[1] * 3600 + time_args[2] * 60 + time_args[3]) / 86400) + 0.5) % 1
        G_Environment.time.time = time

        for _, client in pairs(G_Clients) do
            client.user:sendLua(modules.cl_environment.setTime(time))
            modules.server.DisplayDialog(client, string.format('[Enviroment] Set time to %s', args[1]))
        end
    end
}

--[[ Set Weather ]]--
M.commands["set_weather"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation Utilities',
    description = 'Sets the weather',
    usage = '/set_weather (sunny, thunder, rain)',
    exec = function(executor, args)

    end
}

--[[ Set Fog ]]--
M.commands["set_fog"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation Utilities',
    description = 'Sets the fog level',
    usage = '/set_fog (client) <value>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local fog = (not client.success and args[1] or args[2]) or 0

        if not tonumber(fog) then modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments) return end

        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then
            fog = args[1] / 10
            for _, c in pairs(G_Clients) do
                c.user:sendLua('extensions.core_environment.setFogDensity('..fog..')')
                modules.server.DisplayDialog(c, string.format('[Enviroment] Set fog density to %s', fog))
            end
        else
            fog = fog / 10
            client = client.data
            client.user:sendLua('extensions.core_environment.setFogDensity('..fog..')')
            modules.server.DisplayDialog(client, string.format('[Enviroment] Set fog density to %s', fog))
        end
    end
}

--[[ Teleport ]]--
M.commands["tp"] = {
    rank = modules.moderation.RankTrusted,
    category = 'Moderation Utilities',
    description = 'Teleports you to user or user to other user',
    usage = '/tp <user> (user2)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1]) or nil
        local client2 = modules.server.GetUser(args[2]) or nil

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        -- TODO: When user is TP'd send lua to recover their car to avoid going inside eachother

        if not client2.success then
            local my_ply = connections[executor.user:getID()]
            local my_vehicle = vehicles[my_ply:getCurrentVehicle()]

            local their_ply = connections[client.user:getID()]
            local their_vehicle = vehicles[their_ply:getCurrentVehicle()]

            if not their_vehicle then
                modules.server.DisplayDialogError(client, G_ErrorNotInVehicle)
                return
            end

            local position = their_vehicle:getTransform():getPosition()
            local rotation = their_vehicle:getTransform():getRotation()
            my_vehicle:setPositionRotation(position[1]+3, position[2], position[3], rotation[1], rotation[2], rotation[3], rotation[4])

            modules.server.DisplayDialogSuccess(executor, 'Successfully teleported to ' .. client.user:getName())
        else
            -- Teleport client to client2
            client2 = client2.data

            local ply1 = connections[client.user:getID()]
            local vehicle1 = vehicles[ply1:getCurrentVehicle()]

            local ply2 = connections[client2.user:getID()]
            local vehicle2 = vehicles[ply2:getCurrentVehicle()]

            if not vehicle1 or not vehicle2 then
                modules.server.DisplayDialogError(executor, G_ErrorNotInVehicle)
                return
            end

            local position = vehicle2:getTransform():getPosition()
            local rotation = vehicle2:getTransform():getRotation()
            vehicle1:setPositionRotation(position[1]+3, position[2], position[3], rotation[1], rotation[2], rotation[3], rotation[4])

            modules.server.DisplayDialogSuccess(executor, string.format('Successfully teleported %s to %s', client.user:getName(), client2.user:getName()))
        end

        client.user:sendLua('recovery.startRecovering() recovery.stopRecovering()')
    end
}

--[[ Help ]]--
M.commands["help"] = {
    rank = modules.moderation.RankUser,
    category = 'Moderation Utilities',
    description = 'Displays all commands',
    usage = '/help (command) (category)',
    exec = function(executor, args)
        local search = args[1]
        local result = ''

        local map = {
            [1] = "Moderation",
            [2] = "Moderation Fun",
            [3] = "Moderation Utilities",
            [4] = "Roleplay Utilities",
            [5] = "Utilities"
        }

        local sorted = {}
        for k, v in pairs(map) do table.insert( sorted, k) end
        table.sort( map, function (a, b)
            return a < b
        end )

        if not search then
            result = 'Categories:\n'
            for k in pairs(sorted) do
                result = result .. string.format('  - %d. %s\n', k, map[k])
            end

            modules.server.SendChatMessage(executor.user:getID(), result, modules.server.ColourWarning)
            return
        end

        local count = 0
        if G_Commands[search] ~= nil then
            local command = G_Commands[search]
            if executor.rank() >= command.rank and command.description and command.usage then
                modules.server.SendChatMessage(executor.user:getID(),
                    'Description: ' .. command.description ..
                    '\nUsage: ' .. command.usage .. '\n\n'
                )

                count = count + 1
            else
                modules.server.SendChatMessage(executor.user:getID(), 'You are unable to view this command', modules.server.ColourError)
                return
            end
        else
            if map[tonumber(search)] then
                for name, command in pairs(G_Commands) do
                    if executor.rank() >= command.rank then
                        if command.category then
                            if command.category == tostring(map[tonumber(search)]) then
                                result = result .. string.format('Command: /%s\nDescription: %s\nUsage: %s\n', name, command.description, command.usage)

                                if command.alias then
                                    result = result .. 'Alias: /' .. command.alias .. '\n\n'
                                else
                                    result = result .. '\n'
                                end
                                count = count + 1
                            end
                        end
                    end
                end
            end
        end

        if count == 0 then
            modules.server.SendChatMessage(executor.user:getID(), 'Nothing has shown because you do not have the required rank to view these commands', modules.server.ColourError)
        else
            modules.server.SendChatMessage(executor.user:getID(), result)
        end
    end
}

--[[ Uptime ]]--
M.commands["uptime"] = {
    rank = modules.moderation.RankUser,
    category = 'Moderation Utilities',
    description = 'Displays server uptime',
    usage = '/uptime',
    exec = function(executor, args)
        modules.server.SendChatMessage(executor.user:getID(), 'Server Uptime: ' .. modules.utilities.GetDateTime('%H:%M:%S', G_Uptime), modules.server.ColourSuccess)
    end
}

--[[ Playime ]]--
M.commands["playtime"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Displays playtime',
    usage = '/playtime (user)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local message = 'Playtime: '

        if not client.success then
            client = executor
        else
            client = client.data
            message = client.user:getName() .. '\'s playtime: '
        end

        modules.server.SendChatMessage(executor.user:getID(), message .. modules.utilities.GetDateTime('%H:%M:%S', client.getKey('playtime')), modules.server.ColourSuccess)
    end
}

--[[ Mods ]]--
M.commands["mods"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Displays active moderators',
    usage = '/mods',
    exec = function(executor, args)
        for _, client in pairs(G_Clients) do
            if client.rank() >= modules.moderation.RankModerator then
                if client.user:getSecret() ~= 'secret_console' then
                    modules.server.SendChatMessage(executor.user:getID(), client.user:getName())
                end
            end
        end
    end
}

--[[ Discord ]]--
M.commands["discord"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Displays the discord server',
    usage = '/discord',
    exec = function(executor, args)
        executor.user:sendLua("openWebBrowser('"..G_DiscordLink.."')");
    end
}

--[[ PM ]]--
M.commands["pm"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Send a user a private message',
    usage = '/pm <user> <message>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        table.remove(args, 1)

        local message = ''
        for _, v in pairs(args) do
            message = message .. v .. ' '
        end

        -- Check if message is valid
        if not message or not args[1] then modules.server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        modules.server.SendChatMessage(executor.user:getID(), string.format('you -> %s: %s', client.user:getName(), message))
        modules.server.SendChatMessage(client.user:getID(), string.format('%s -> you: %s', executor.user:getName(), message))
    end
}

--[[ Force Recover ]]--
M.commands["force_recover"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    alias = 'fr',
    description = 'Recovers your vehicle but also notifies staff members',
    usage = '/force_recover',
    exec = function(executor, args)
        local ply = connections[executor.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]
        vehicle:sendLua('recovery.saveHome() recovery.startRecovering() recovery.stopRecovering()')
        for _, client in pairs(G_Clients) do
            if client.rank() >= modules.moderation.RankModerator then
                modules.server.SendChatMessage(client.user:getID(), '[Recover] ' .. executor.user:getName() .. ' Used /force_recover', modules.server.ColourWarning)
            end
        end
    end
}

--[[ Block ]]--
M.commands["block"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Blocks a user',
    usage = '/block <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        if client.rank() <= modules.moderation.RankVIP then
            local blocked = false
            for key, name in pairs(client.getKey('blockList')) do
                if name == client.user:getName() then
                    blocked = true
                else
                    blocked = false
                end
            end

            if blocked then
                modules.server.DisplayDialogWarning(executor, 'User is already blocked')
                return
            else
                local data = {}
                data[client.user:getSecret()] = client.user:getName()
                executor.editKey('blockList', data)
                modules.server.DisplayDialogSuccess(executor, 'Successfully blocked ' .. client.user:getName())
            end
        else
            modules.server.DisplayDialogWarning(executor, 'Unable to block a staff member')
        end
    end
}

--[[ Unblock ]]--
M.commands["unblock"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Unblocks a user',
    usage = '/unblock <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        local blocked = false
        for key, name in pairs(client.getKey('blockList')) do
            if name == client.user:getName() then
                blocked = true
            else
                blocked = false
            end
        end

        if not blocked then
            modules.server.DisplayDialogWarning(executor, 'User is not blocked')
            return
        else
            local data = {}
            data[client.user:getSecret()] = nil
            executor.editKey('blockList', data)
            modules.server.DisplayDialogSuccess(executor, 'Successfully unblocked ' .. client.user:getName())
        end
    end
}

--[[ Get Blocks ]]--
M.commands["get_blocks"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilties',
    description = 'Lists all blocked users',
    usage = '/get_blocks',
    exec = function(executor, args)
        local j = 1
        for i=1, #executor.blockList do
            local client = modules.server.GetUser(executor.blockList[i])
            if client.success then
                modules.server.SendChatMessage(executor.user:getID(), client.data.user:getName())
            end

            j = i
        end

        if j <= 1 then
            modules.server.SendChatMessage(executor.user:getID(), '[You have not blocked anyone]', modules.server.ColourWarning)
        end
    end
}

--[[ Donate ]]--
M.commands["donate"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Displays patreon link',
    usage = '/donate',
    exec = function(executor, args)
        executor.user:sendLua("openWebBrowser('"..G_PatreonLink.."')");
    end
}

--[[ DV ]]--
M.commands["dv"] = {
    rank = modules.moderation.RankUser,
    category = 'Utilities',
    description = 'Deletes current vehicle',
    usage = '/dv (user)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- TODO return if client specified and doesn't exist

       --[[ Check if a client has been passed through ]]--
        if client.success then
            client = client.data
            if client.rank() > modules.moderation.RankVIP then
                --[[ Delete clients vehicle ]]--
                client.vehicles.remove(client, connections[client.user:getID()]:getCurrentVehicle())
                client.user:sendLua('commands.setFreeCamera()')

                modules.server.DisplayDialogSuccess(executor, 'Successfully removed clients vehicle')
            else
                modules.server.DisplayDialogError(executor, G_ErrorInsufficentPermissions)
            end
        else
            --[[ Delete executors vehicle ]]--
            if executor.vehicles and connections[executor.user:getID()]:getCurrentVehicle() ~= 0 then
                executor.vehicles.remove(executor, connections[executor.user:getID()]:getCurrentVehicle())
                executor.user:sendLua('commands.setFreeCamera()')
            end
        end
    end
}

--[[ DVA ]]--
M.commands["dva"] = {
    rank = modules.moderation.RankUser,
    category = 'Moderation Utilities',
    description = 'Deletes current vehicle',
    usage = '/dva (user)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- TODO return if client specified and doesn't exist

       --[[ Check if a client has been passed through ]]--
        if client.success then
            client = client.data
            if client.rank() > modules.moderation.RankVIP then
                --[[ Delete clients vehicle ]]--
                client.vehicles.clear(client)
                client.user:sendLua('commands.setFreeCamera()')

                modules.server.DisplayDialogSuccess(executor, 'Successfully removed clients vehicle')
            else
                modules.server.DisplayDialogError(executor, G_ErrorInsufficentPermissions)
            end
        else
            --[[ Delete executors vehicle ]]--
            executor.vehicles.clear(executor)
            executor.user:sendLua('commands.setFreeCamera()')
        end
    end
}

--[[ GP ]]--
M.commands["gp"] = {
    rank = modules.moderation.RankDeveloper,
    exec = function(executor, args)
        local ply = connections[executor.user:getID()]
        local position = vehicles[ply:getCurrentVehicle()]:getTransform():getPosition()
        local rotation = vehicles[ply:getCurrentVehicle()]:getTransform():getRotation()

        GILog('\n%s, %s, %s\n%s, %s, %s, %s',
            position[1], position[2], position[3],
            rotation[1], rotation[2], rotation[3], rotation[4]
        )
    end
}

local function ReloadModules()
    modules = G_ReloadModules(modules, 'cmd_utilities.lua')
end

M.ReloadModules = ReloadModules
M.commands = M.commands

return M