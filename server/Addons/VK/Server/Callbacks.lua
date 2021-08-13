local M = {}

require('Addons.VK.Globals')
require('Addons.VK.Server.Hooks')

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    TimedEvents = require('Addons.VK.TimedEvents'),
    Moderation = require('Addons.VK.Server.Extensions.VK_Moderation.Moderation'),
    Server = require('Addons.VK.Server'),

    CEnvironment = require('Addons.VK.Client.CEnvironment'),
    CPlayerJoin = require('Addons.VK.Client.CPlayerJoin'),
}

local prefix = ''
local nextUpdate = 0

M.Callbacks = {
    ['Initialize'] = function()
        prefix = Modules.Utilities.GetKey(G_ServerLocation, 'options', 'command_prefix')

        G_Verbose = Modules.Utilities.GetKey(G_ServerLocation, 'log', 'verbose')
        G_LogFile = Modules.Utilities.GetKey(G_ServerLocation, 'log', 'file')

        G_DiscordLink = Modules.Utilities.GetKey(G_ServerLocation, 'options', 'discord_link')
        G_PatreonLink = Modules.Utilities.GetKey(G_ServerLocation, 'options', 'patreon_link')

        G_Clients[1337] = Modules.Server.consolePlayer
    end,

    ['OnPlayerConnected'] = function(client_id)
        --[[ Create new User Object if it doesn't exist ]]--
        if not Modules.Utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'rank', G_LevelError, true, true) then
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'rank', 0)
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'warns', {})
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'alias', {connections[client_id]:getName()})
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'bans', {})
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'vehicleLimit', 2)
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'mute_time', 0)
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'playtime', 0)
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'blockList', {})
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'home', {x=709.3377075195312, y=-0.7625573873519897, z=52.24008560180664, xr=-0.006330838892608881, yr=-0.00027202203636989, zr=-0.25916287302970886, w=0.9658128619194032})

            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'roles', {})
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'money', 240)
            Modules.Utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'onduty', false)

            GILog('Creating new user object for %s', connections[client_id]:getName())
        end

        --[[ Add Client to Table ]]--
        Modules.Server.AddClient(client_id)
        local client = G_Clients[client_id]

        GILog('%s is connecting [ %s ]', client.user:getName(), connections[client_id]:getSecret())

        Modules.Server.IsConnected(client, client.user:getName(), function()
            --[[ Connected ]]--
            GILog("%s has connected", client.user:getName())
            Modules.Server.DisplayDialog(client, string.format('%s has joined!', client.user:getName()), 3)

            --[[ Send Webhook ]]--
            Modules.Utilities.SendAPI({
                client = {
                    name = client.user:getName()
                },

                data = 'Connected',
                type = 'user_join_leave'
            })

            --[[ Kick if Unknown (Specified in Server.json) ]]
            if Modules.Utilities.GetKey(G_ServerLocation, 'options', 'kick_unknown') and client.user:getName() == 'Unknown' then
                client.user:kick('Please join back with a different name')
            end

            --[[ Set Client Global Variables ]]--
            client.user:sendLua(Modules.CPlayerJoin.SetGlobals())

            --[[ Set Time of Day ]]--
            client.user:sendLua(string.format('extensions.core_environment.setTimeOfDay({dayscale=%s,nightScale=%s,azimuthOverride=%s,dayLength=%s,time=%s,play=%s})',
                G_Environment.time.dayscale,
                G_Environment.time.nightScale,
                G_Environment.time.azimuthOverride,
                G_Environment.time.dayLength,
                G_Environment.time.time,
                G_Environment.time.play
            ))

            if G_Environment.rain ~= 0 then
                client.user:sendLua(Modules.CEnvironment.setPrecipitation(G_Environment.rain))
                client.user:sendLua(Modules.CEnvironment.createSFXRain(G_Environment.rain / 100))
            end

            if G_Environment.weather then
                Modules.CEnvironment.setWeather(client, G_Environment.weather)
            end

            --[[ Create Waypoints ]]--
            Modules.Server.InitializeMarkers(client)

            client.user:sendLua('kissui.force_disable_nametags = true')

            --[[ User Help ]]--
            Modules.Server.SendChatMessage(client.user:getID(), 'Use /help for a list of commands (only show for your rank)', Modules.Server.ColourSuccess)
            Modules.Server.SendChatMessage(client.user:getID(), 'KissMP 0.4.5 is currently buggy, please download the fixed version from /discord or KissMP\'s Github', Modules.Server.ColourSuccess)
        end)
    end,

    ['OnPlayerDisconnected'] = function(client_id)
        local oldClient = G_Clients[client_id]
        G_Clients[client_id].connected = false
        Modules.Server.RemoveClient(client_id)

        GILog("%s has Disconnected [ %s ]", oldClient.user:getName(), oldClient.user:getSecret())

        Modules.Utilities.SendAPI({
            client = {
                name = oldClient.user:getName()
            },

            data = 'Disconnected',
            type = 'user_join_leave'
        })

        oldClient = nil
    end,

    ['OnVehicleSpawned'] = function(vehicle_id, client_id)
        local client = G_Clients[client_id]
        if vehicles[vehicle_id]:getData():getName() ~= 'unicycle' then
            client.vehicles.count = client.vehicles.count + 1
            Modules.Utilities.SendAPI({
                client = {
                    name = G_Clients[client_id].user:getName()
                },

                data = 'Spawned a ' .. vehicles[vehicle_id]:getData():getName(),
                type = 'vehicle_log'
            })

            client.vehicles.add(client, vehicle_id)
        end
    end,

    ['OnVehicleRemoved'] = function(vehicle_id, client_id)
        if vehicles[vehicle_id] and vehicles[vehicle_id]:getData():getName() ~= 'unicycle' then
            G_Try(function()
                G_Clients[client_id].vehicles.count = G_Clients[client_id].vehicles.count - 1
            end)
        end
    end,

    ['OnChat'] = function(client_id, message)
        local executor = G_Clients[client_id]

        --[[ Check if the Client is Muted ]]--
        local mute_time = G_Clients[client_id].getKey('mute_time')
        if mute_time ~= nil and mute_time > 0 then
            if mute_time <= os.time() then
                executor.editKey('mute_time', 0)
            else
                Modules.Server.SendChatMessage(executor.user:getID(), 'You are muted', Modules.Server.ColourError)
                return ""
            end
        end

        --[[ Check if Command ]]
        if string.sub(message, 1, 1) == '@' then
            local args = Modules.Utilities.ParseCommand(message, ' ')
            args[1] = string.lower(args[1]:sub(2))
            string.gsub(args[1], '@', '')

            local client = Modules.Server.GetUser(args[1])

            -- Check if the client exists
            if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
            client = client.data

            local message = Modules.Utilities.GetMessage(args)

            -- Check if message is valid
            if not message or not args[1] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

            Modules.Server.SendChatMessage(string.format('%s @%s: %s', executor.user:getName(), client.user:getName(), message), Modules.Server.ColourMention)
        else if string.sub(message, 1, 1) == prefix then
            local args = Modules.Utilities.ParseCommand(message, ' ')
            args[1] = string.lower(args[1]:sub(2))

            local command = G_Commands[args[1]]
            if not command then
                for _, cmd in pairs(G_Commands) do
                    if args[1] == cmd.alias then
                        command = cmd
                        break
                    end
                end
            end

            local canExecuteWithRole = false
            if command and command.roles then
                for _, role in pairs(command.roles) do
                    if Modules.Roleplay.HasRole(executor, role) then
                        canExecuteWithRole = true
                    end
                end
            end

            if command and command.roles and canExecuteWithRole or command and not command.roles and not canExecuteWithRole then
                if executor.rank() >= command.rank then
                    --[[ Check current vehicle ]]--
                    table.remove(args, 1)
                    G_Try(function ()
                        command.exec(executor, args)
                    end, function(err)
                        Modules.Server.SendChatMessage(executor.user:getID(), string.format('[ %s Failed. Please post it in bug-reports in /discord ] Message: %s', message, err), Modules.Server.ColourError)
                        GELog('Command failed! User: %s\n  Message: %s', executor.user:getName(), err)
                        return ""
                    end)
                end
            else
                if command and command.roles and not canExecuteWithRole then
                    Modules.Server.DisplayDialogError(executor, G_ErrorInsufficentPermissions)
                else
                    Modules.Server.SendChatMessage(executor.user:getID(), 'Invalid Command, please use /help', Modules.Server.ColourWarning)
                end
            end
        else
            Modules.Utilities.SendAPI({
                client = {
                    name = executor.user:getName()
                },

                data = message,
                type = 'user_message'
            })

            Modules.Moderation.SendUserMessage(executor, 'OOC', message, true)
        end end

        return ""
    end,

    ['OnStdIn'] = function(input)
        if input == '!rl' then
            G_ServerLocation = './addons/VK/Settings/Server.json'

            G_PlayersLocation = './addons/VK/Settings/Players.json'
            G_ColoursLocation = './addons/VK/Settings/Colours.json'

            Modules = G_ReloadModules(Modules, 'Main.lua')
            Hooks.Call('[Main] Initialize')
        end
    end,

    ['Tick'] = function()
        Modules.TimedEvents.Update()

        --[[ Garbage Debugging ]]--
        if os.time() > nextUpdate then
            nextUpdate = os.time() + 4
            collectgarbage("collect")
        end

        -- Server uptime
        G_Uptime = G_Uptime + 1
    end
}

return M