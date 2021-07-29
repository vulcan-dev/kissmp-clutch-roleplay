--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

--[[ My TODO List
    TODO Invalid command args return the args if it's easy to do
    TODO Ban on 3 warns
    TODO Add check for /gps x y z (check if the person puts a comma)
    TODO add /arrest (freeze user for x time (15sec))
    TODO Make veh spawn and edit different (on spawn set var in user to veh and check in spawn)

    TODO Add input to bufio

    local inputActionFilter = extensions.core_input_actionFilter
    inputActionFilter.setGroup('default_blacklist_exploration', {"switch_next_vehicle", "switch_previous_vehicle", "loadHome", "saveHome", "reload_vehicle", "reload_all_vehicles", "vehicle_selector", "parts_selector", "dropPlayerAtCamera", "toggleWalkingMode"} )  

    kissui.force_disable_nametags = true
]]

local modules = {
    utilities = require('addons.vulcan_script.utilities'),
    timed_events = require('addons.vulcan_script.timed_events'),
    server = require('addons.vulcan_script.server')
}

local extensions = {}
local nextUpdate = 0
local nextUpdate2 = 0
local prefix = '/'

-- [[ ==================== Hooking Start ==================== ]] --
hooks.register('OnPlayerConnected', 'VK_PLAYER_CONNECT', function(client_id)
    --[[ Add Client to Table ]]--
    modules.server.AddClient(client_id)
    local client = G_Clients[client_id]

    modules.utilities.LogInfo('%s is connecting [ %s ]', client.user:getName(), client.user:getSecret())

    --[[ Create new User Object if it doesn't exist ]]--
    if not modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'rank', G_LevelError, true, true) then
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'rank', 0)
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'alias', {G_Clients[client_id].user:getName()})
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'warns', {})
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'bans', {})
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'vehicleLimit', 2)
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'mute_time', 0)
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'playtime', 0)

        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'roles', {})
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'money', 240)
        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'onduty', false)

        modules.utilities.LogInfo('Creating new user object for %s', client.user:getName())
    end

    modules.server.IsConnected(client, client.user:getName(), function()
        --[[ Connected ]]--
        modules.utilities.LogInfo("%s has connected", client.user:getName())
        modules.server.DisplayDialog(client, string.format('%s has joined!', client.user:getName()), 3)

        --[[ Send Webhook ]]--
        modules.utilities.SendAPI({
            client = {
                name = client.user:getName()
            },

            data = 'Connected',
            type = 'user_join_leave'
        })

        --[[ Kick if Unknown (Specified in server.json) ]]
        if modules.utilities.GetKey(G_ServerLocation, 'options', 'kick_unknown') and client.user:getName() == 'Unknown' then
            client.user:kick('Please join back with a different name')
        end

        --[[ Set Time of Day ]]--
        client.user:sendLua(string.format('extensions.core_environment.setTimeOfDay({dayscale=%s,nightScale=%s,azimuthOverride=%s,dayLength=%s,time=%s,play=%s})',
            modules.server.environmentTime.dayscale,
            modules.server.environmentTime.nightScale,
            modules.server.environmentTime.azimuthOverride,
            modules.server.environmentTime.dayLength,
            modules.server.environmentTime.time,
            modules.server.environmentTime.play
        ))

        --[[ Create Waypoints ]]--
        modules.server.InitializeMarkers(client)

        client.user:sendLua('kissui.force_disable_nametags = true')

        --[[ User Help ]]--
        modules.server.SendChatMessage(client.user:getID(), 'Use /help for a list of commands (only show for your rank)', modules.server.ColourSuccess)
        modules.server.SendChatMessage(client.user:getID(), 'KissMP 0.4.5 is currently buggy, please download the fixed version from /discord or KissMP\'s Github', modules.server.ColourSuccess)

        --[[ Load Extension Hook VK_PlayerConnect ]]--
        for _, extension in pairs(extensions) do
            if extension.callbacks and extension.callbacks.VK_PlayerConnect then
                extension.callbacks.VK_PlayerConnect(client_id)
            end
        end
    end)
end)

hooks.register('OnPlayerDisconnected', 'VK_PLAYER_DISCONNECT', function(client_id)
    local oldClient = G_Clients[client_id]
    G_Clients[client_id].connected = false
    modules.server.RemoveClient(client_id)

    modules.utilities.LogInfo("%s has Disconnected [ %s ]", oldClient.user:getName(), oldClient.user:getSecret())

    modules.utilities.SendAPI({
        client = {
            name = oldClient.user:getName()
        },

        data = 'Disconnected',
        type = 'user_join_leave'
    })

    --[[ Load Extension Hook VK_PlayerDisconnect ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_PlayerDisconnect then
            extension.callbacks.VK_PlayerDisconnect(oldClient)
        end
    end

    oldClient = nil
end)

hooks.register('OnVehicleSpawned', 'VK_PLAYER_VEHICLE_SPAWN', function(vehicle_id, client_id)
    local client = G_Clients[client_id]
    client.vehicles.count = client.vehicles.count + 1
    if vehicles[vehicle_id]:getData():getName() ~= 'unicycle' then
        modules.utilities.SendAPI({
            client = {
                name = G_Clients[client_id].user:getName()
            },

            data = 'Spawned a ' .. vehicles[vehicle_id]:getData():getName(),
            type = 'vehicle_log'
        })

        client.vehicles.add(client, vehicle_id)
    end


    --[[ Load Extension Hook VK_VehicleSpawn ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_VehicleSpawn then
            extension.callbacks.VK_VehicleSpawn(vehicle_id, client_id)
        end
    end
end) -- Vehicle Spawned

hooks.register('OnVehicleRemoved', 'VK_PLAYER_VEHICLE_REMOVED', function(vehicle_id, client_id)
    if vehicles[vehicle_id] and vehicles[vehicle_id]:getData():getName() ~= 'unicycle' then
        --G_Clients[client_id].vehicles.remove(G_Clients[client_id], vehicle_id)
        -- G_Try(function()
        --     modules.utilities.SendAPI({
        --         client = {
        --             name = G_Clients[client_id].user:getName()
        --         },

        --         data = 'Removed a ' .. vehicles[vehicle_id]:getData():getName(),
        --         type = 'vehicle_log'
        --     })
        -- end, function() modules.utilities.LogWarning("Failed to get clientName in hook \"SendAPI\"") end )

        G_Try(function()
            --[[ If I call vehicles.remove(...) then obviously no client_id is passed through so I just see if that was called or if the user manually deleted it via the ig menu ]]--
            G_Clients[client_id].vehicles.count = G_Clients[client_id].vehicles.count - 1
        end)
    end

    --[[ Load Extension Hook VK_VehicleRemoved ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_VehicleRemoved then
            extension.callbacks.VK_VehicleRemoved(vehicle_id, client_id)
        end
    end
end)

hooks.register('OnVehicleResetted', 'VK_PLAYER_VEHICLE_RESET', function(vehicle_id, client_id)
    --[[ Load Extension Hook VK_VehicleReset ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_VehicleReset then
            extension.callbacks.VK_VehicleReset(vehicle_id, client_id)
        end
    end
end)

hooks.register('OnChat', 'VK_PLAYER_CHAT', function(client_id, message)
    local executor = G_Clients[client_id]

    --[[ Check if the Client is Muted ]]--
    local mute_time = modules.utilities.GetKey(G_PlayersLocation, executor.user:getSecret(), 'mute_time')
    if mute_time ~= nil and mute_time > 0 then
        if mute_time <= os.time() then
            modules.utilities.EditKey(G_PlayersLocation, executor.user:getSecret(), 'mute_time', 0)
        else
            modules.server.SendChatMessage(executor.user:getID(), 'You are muted', modules.server.ColourError)
            return ""
        end
    end

    --[[ Check if Command ]]
    modules.utilities.LogInfo('%s said: %s', G_Clients[client_id].user:getName(), message)
    if string.sub(message, 1, 1) == '@' then
        local args = modules.utilities.ParseCommand(message, ' ')
        args[1] = string.lower(args[1]:sub(2))
        string.gsub(args[1], '@', '')

        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(G_ErrorInvalidUser, executor) return end
        client = client.data

        table.remove(args, 1)

        local message = ''
        for _, v in pairs(args) do
            message = message .. v .. ' '
        end

        -- Check if message is valid
        if not message or not args[1] then modules.server.DisplayDialogError(G_ErrorInvalidMessage, executor) return end

        modules.server.SendChatMessage(string.format('%s @%s: %s', executor.user:getName(), client.user:getName(), message), modules.server.ColourMention)
    else if string.sub(message, 1, 1) == prefix then
        G_CommandExecuted = true
        local args = modules.utilities.ParseCommand(message, ' ')
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
                if modules.rp.HasRole(executor, role) then
                    canExecuteWithRole = true
                end
            end
        end

        if command and command.roles and canExecuteWithRole or command and not command.roles and not canExecuteWithRole then
            if executor.rank() >= command.rank then
                table.remove(args, 1)
                G_Try(function ()
                    modules.moderation.SendUserMessage(executor, 'Command', message, false)
                    command.exec(executor, args)
                end, function(err)
                    modules.server.SendChatMessage(executor.user:getID(), string.format('[ %s Failed. Please post it in bug-reports in /discord ] Message: %s', message, err), modules.server.ColourError)
                    modules.utilities.LogError('Command failed! User: %s\n  Message: %s', executor.user:getName(), err)
                    G_CommandExecuted = false
                    return ""
                end)
            end
        else
            if command and command.roles and not canExecuteWithRole then
                modules.server.DisplayDialogError(G_ErrorInsufficentPermissions, executor)
            else
                modules.server.SendChatMessage(executor.user:getID(), 'Invalid Command, please use /help', modules.server.ColourWarning)
            end
        end
    else
        modules.utilities.SendAPI({
            client = {
                name = executor.user:getName()
            },

            data = message,
            type = 'user_message'
        })

        modules.moderation.SendUserMessage(executor, 'OOC', message)
    end end

    --[[ Load Extension Hook VK_OnMessageReceive ]]--
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_OnMessageReceive then
            extension.callbacks.VK_OnMessageReceive(client_id, message)
        end
    end

    return ""
end) -- OnChat

hooks.register('OnStdIn', 'VK_PLAYER_STDIN', function(input);
    --[[ Reload all Modules ]]--
    if input == '!rl' then
        G_ServerLocation = './addons/vulcan_script/settings/server.json'

        G_PlayersLocation = './addons/vulcan_script/settings/players.json'
        G_ColoursLocation = './addons/vulcan_script/settings/colours.json'

        --[[ Load all Extensions ]]--
        extensions = G_ReloadExtensions(extensions, 'main.lua')
        modules = G_ReloadModules(modules, 'main.lua')

        modules.moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation')
        modules.rp = require('addons.vulcan_script.extensions.vulcan_rp.rp')

        --[[ Load all Extension Modules ]]--
        for _, v in pairs(extensions) do
            v.ReloadModules()
        end
    end

    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_OnStdIn then
            extension.callbacks.VK_OnStdIn(input)
        end
    end
end)

hooks.register("Tick", "VK_TICK", function()
    modules.timed_events.Update()

    --[[ Garbage Debugging ]]--
    if os.time() > nextUpdate then
        nextUpdate = os.time() + 4
        collectgarbage("collect")
    end

    if os.time() > nextUpdate2 then
        nextUpdate2 = os.time() + 1200
        modules.server.SendChatMessage('[This server is using Vulcan-Moderation by Vitex#1248]', modules.server.ColourWarning)
    end

    -- Server uptime
    G_Uptime = G_Uptime + 1

    -- Update extension hook
    for _, extension in pairs(extensions) do
        if extension.callbacks and extension.callbacks.VK_Tick then
            extension.callbacks.VK_Tick(1 - 60)
        end
    end
end)
-- [[ ==================== Hooking End ==================== ]] --

local function Initialize()
    if G_FirstLoad then
        --[[ Make sure to change the log level if you don't want console spam :) ]]--
        G_Level = G_LevelDebug
        modules.utilities.LogInfo('[Server] Initialized')

        modules = G_ReloadModules(modules, 'main.lua')

        --[[ Load all Extensions ]]--
        extensions = G_ReloadExtensions(extensions, 'main.lua')

        --[[ Load all Extension Modules ]]--
        for _, v in pairs(extensions) do
            v.ReloadModules()
        end

        G_Verbose = modules.utilities.GetKey(G_ServerLocation, 'log', 'verbose')
        G_LogFile = modules.utilities.GetKey(G_ServerLocation, 'log', 'file')

        G_UseDiscord = modules.utilities.GetKey(G_ServerLocation, 'options', 'use_discord')

        G_DiscordLink = modules.utilities.GetKey(G_ServerLocation, 'options', 'discord_link')
        G_PatreonLink = modules.utilities.GetKey(G_ServerLocation, 'options', 'patreon_link')

        prefix = modules.utilities.GetKey(G_ServerLocation, 'options', 'command_prefix')

        -- modules.utilities.SendAPI({
        --     Executor = {
        --         Name = "executor",
        --         ID = 1,
        --         MID = 2,
        --         Secret = "Secret"
        --     },
        --     Client = {
        --         Name = "client",
        --         ID = 4,
        --         MID = 3,
        --         Secret = "Secret2"
        --     },
        --     Data = "test data",
        --     Type = "user_kick"
        -- })

        --[[ Create Console ]]--
        G_Clients[1337] = modules.server.consolePlayer

        -- modules.vulcan_debug = require('addons.vulcan_script.extensions.vulcan_debug.vulcan_debug')
        modules.moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation')
        modules.rp = require('addons.vulcan_script.extensions.vulcan_rp.rp')

        G_FirstLoad = false
    end
end

Initialize()