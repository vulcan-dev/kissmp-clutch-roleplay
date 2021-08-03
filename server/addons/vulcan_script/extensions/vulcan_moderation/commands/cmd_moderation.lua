--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local modules = {
    utilities = require('addons.vulcan_script.utilities'),
    moderation = require('addons.vulcan_script.extensions.vulcan_moderation.moderation'),
    timed_events = require('addons.vulcan_script.timed_events'),
    server = require('addons.vulcan_script.server')
}

M.commands = {}

--[[ Ban ]]--
M.commands["ban"] = {
    rank = modules.moderation.RankAdmin,
    category = 'Moderation',
    description = 'Bans a user for a specified amount of time',
    usage = '/ban <user> (reason) (time - prefix: y, mo, d, h, m)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local reason = args[2] or 'No reason specified'
        local time = args[3] or '1y'

        --[[ Check if Client Exists ]]--
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        --[[ Compare the Ranks between Executor and Client ]]--
        if executor.rank() <= client.rank() then
            modules.server.DisplayDialogError(executor, G_ErrorCannotPerformUser)
            return
        end

        --[[ Get the first number variable ]]--
        local time_fmt = time:sub(-1)
        if modules.utilities.IsNumber(time_fmt) then
            modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
            return
        end

        --[[ Get the full time ]]--
        time = time:sub(1, -2)
        if not modules.utilities.IsNumber(time) then
            modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
            return
        end

        if modules.utilities.IsNumber(time) then
            --[[ Setup the Time ]]--
            local year, month, day, hour, min, sec = os.date('%Y-%m-%d %H:%M:%S'):match('(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')

            local date = {
                year = year,
                month = month,
                day = day,
                hour = hour,
                min = min,
                sec = sec
            }

            if time_fmt == 'y' then
                date.year = date.year + time
            elseif time_fmt == 'mo' then
                date.month = date.month + time
            elseif time_fmt == 'd' then
                date.day = date.day + time
            elseif time_fmt == 'h' then
                date.hour = date.hour + time
            elseif time_fmt == 'm' then
                date.min = date.min + time
            else
                modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
                return
            end

            local exp_sec = os.time{ year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min, sec = date.sec }

            --[[ Ban the Client ]]--
            modules.moderation.AddBan(client.user:getSecret(), reason, os.date('%Y-%m-%d %H:%M:%S'), exp_sec, os.date('%Y-%m-%d %H:%M:%S', exp_sec), executor.user:getName())

            --[[ Check if the Client is In-Game, if so kick them ]]--
            modules.utilities.SendAPI({
                executor = {
                    name = executor.user:getName()
                },
                client = {
                    name = client.user:getName()
                },
                time_str = os.date('%Y-%m-%d %H:%M:%S', exp_sec),
                reason = reason,
                data = 'kicked',
                type = 'mod_log'
            })

            modules.server.SendChatMessage(string.format('[Moderation] %s has been banned by %s', client.user:getName(), executor.user:getName()))

            if G_Clients[client.user:getID()] then
                client.user:kick(string.format('You have been banned by %s. Unban Date: %s', executor.user:getName(), os.date('%Y-%m-%d %H:%M:%S', exp_sec)))
            end
        end
    end
}

--[[ Lock ]]--
M.commands["lock"] = {
    rank = modules.moderation.RankAdmin,
    category = 'Moderation',
    description = 'Locks the server and kicks all users',
    usage = '/lock',
    exec = function(executor, args)
        modules.moderation.locked = not modules.moderation.locked
        
        if modules.moderation.locked then
            for _, client in pairs(G_Clients) do
                --[[ Kick all Users that are < RankVIP ]]--
                if client.rank() < modules.moderation.RankVIP then
                    client.user:kick('Server has been locked')
                end
            end

            modules.server.SendChatMessage('Server has been locked!', modules.server.ColourSuccess)
        else
            modules.server.SendChatMessage('Server has been unlocked!', modules.server.ColourSuccess)
        end
    end
}

--[[ Warn ]]--
M.commands["warn"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Warns a user',
    usage = '/warn <user> (reason)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local reason = args[2] or 'No reason specified'

        --[[ Check if the Client Exists ]]--
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        --[[ Compare the Executor's Rank with the Client ]]--
        if executor.rank() <= client.rank() then
            modules.server.DisplayDialogError(executor, G_ErrorCannotPerformUser)
            return
        end

        --[[ Warn the user ]]--
        modules.moderation.AddWarn(client.user:getSecret(), reason, os.date('%Y-%m-%d %H:%M:%S', os.time()), executor.user:getName())
        modules.server.DisplayDialogWarning(client, string.format('You have been warned by %s for: %s', executor.user:getName(), reason))

        modules.server.DisplayDialogSuccess(executor, string.format('Successfully warned %s', client.user:getName()))

        modules.utilities.SendAPI({
            executor = {
                name = executor.user:getName()
            },
            client = {
                name = client.user:getName()
            },
            reason = reason,
            data = 'warn',
            type = 'mod_log'
        })

        --[[ Check if the Client is In-Game, if so send them a dialog ]]--
        if G_Clients[client.user:getID()] then
            modules.server.DisplayDialogWarning(client, string.format('%s has warned you for: %s', client.user:getName(), reason))
        end
    end
}

--[[ Unban ]]--
M.commands["unban"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Unbans a user',
    usage = '/unban <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local ban_name = args[2]

        if not ban_name then modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments) return end

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        -- Check if they're already banned
        if not modules.moderation.IsBanned(client.user:getSecret()) then
            modules.server.DisplayDialogWarning(executor, client.user:getName()..' is not banned')
            return
        end

        modules.utilities.SendAPI({
            executor = {
                name = executor.user:getName()
            },
            client = {
                name = client.user:getName()
            },
            data = 'unbanned',
            type = 'mod_log'
        })

        if modules.moderation.removeBan(client.user:getSecret(), ban_name) then
            modules.server.DisplayDialogSuccess(executor, 'Successfully unbanned '..client.user:getName())
        else
            modules.server.DisplayDialogWarning(executor, 'Ban not found')
        end
    end
}

--[[ Get Bans ]]--
M.commands["get_bans"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Checks the bans for a user',
    usage = '/get_bans <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data
        
        local ban_data = modules.moderation.GetBans(client.user:getSecret())

        local count = 0
        for k, ban in pairs(ban_data) do
            if ban.ban_expirey_date > 0 then
                modules.server.SendChatMessage(executor.user:getID(), string.format('  [ Active: %s ]\n  Expires: %s\n  Date of Issue: %s\n  Banned by: %s', k, ban.ban_expirey_date, ban.date_of_issue, ban.banned_by))
            else
                modules.server.SendChatMessage(executor.user:getID(), string.format('  [ Inactive: %s ]\n  Expired: %s\n  Date of Issue: %s\n  Banned by: %s', k, ban.ban_expirey_date, ban.date_of_issue, ban.banned_by))
            end

            count = count + 1
        end

        if count == 0 then
            modules.server.DisplayDialogWarning(executor, 'This user has no bans')
        end
    end
}

--[[ Get Warns ]]--
M.commands["get_warns"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Gets all warnings from a user',
    usage = '/get_bans <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data
        
        local warn_data = modules.moderation.getWarns(client.user:getSecret())

        local count = 0
        for reason, warn in pairs(warn_data) do
            modules.server.SendChatMessage(executor.user:getID(), string.format('  Reason: %s - Warned by: %s', reason, warn.warned_by))
            count = count + 1
        end

        if count == 0 then
            modules.server.DisplayDialogWarning(executor, 'This user has no warns')
        end
    end
}

--[[ Remove Warn ]]--
M.commands["remove_warn"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Remove a warning from a user',
    usage = '/remove_warn <user> <reason>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local warn = args[2]

        if not warn then modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments) return end
        
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data
        
        local warn_data = modules.utilities.GetKey(G_PlayersLocation, client.user:getSecret(), 'warns')
        local count = 0
        for k, _ in pairs(warn_data) do
            if k == warn then
                warn_data[k] = nil
                modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'warns', warn_data)
                modules.server.DisplayDialogSuccess(executor, 'Successfully removed warn from user')
                count = count + 1

                modules.utilities.SendAPI({
                    executor = {
                        name = executor.user:getName()
                    },
                    client = {
                        name = client.user:getName()
                    },
                    data = 'remove_warn',
                    type = 'mod_log'
                })
                return
            end
        end


        if count == 0 then
            modules.server.DisplayDialogWarning(executor, 'The specified reason has not been found')
        end
    end
}

--[[ Kick ]]--
M.commands["kick"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Kicks a user',
    usage = '/kick <user> (reason)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local reason = args[2] or 'No reason specified'

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        modules.utilities.SendAPI({
            Executor = {
                Name = executor.user:getName(),
            },
            Client = {
                Name = client.user:getName(),
            },
            Data = reason,
            Type = "user_kick"
        })

        -- Check if the executor is able to run the command against the client
        if executor.rank() <= client.rank() then
            modules.server.DisplayDialogError(executor, G_ErrorCannotPerformUser)
            modules.utilities.LogInfo('[Moderation] %s tried to kick %s. Reason: %s', executor.user:getName(), client.user:getName(), reason)

            return
        end

        client.user:kick(string.format('You have been kicked by %s\nReason: %s', executor.user:getName(), reason))

        modules.server.SendChatMessage(string.format('[Moderation] %s has been kicked by %s', client.user:getName(), executor.user:getName()))
    end
}

--[[ Set Rank ]]--
M.commands["set_rank"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Sets a user rank',
    usage = '/set_rank <user> <rank (id or name)>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local rank = args[2] or nil

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.SendChatMessage(executor.user:getID(), 'Invalid user specified') return end
        client = client.data

        if not rank then
            modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
            return
        end

        local found = false
        local outStr = ''

        -- Check if the rank is valid (string)
        for num, rankStr in pairs(modules.moderation.StrRanks) do
            if tostring(string.lower(rank)) == tostring(rankStr) then
                outStr = rankStr
                rank = tonumber(num)
                found = true
                break
            end
        end


        if not found and not modules.moderation.StrRanks[tonumber(rank)] then
            modules.server.DisplayDialogError(executor, 'Invalid rank specified')
        else
            if not found and modules.moderation.StrRanks[tonumber(rank)] then
                outStr = modules.moderation.StrRanks[tonumber(rank)]
                found = true
            end
        end

        -- Check if the rank is valid (int)
        if not found then return end

        -- Check if the executor is able to run the command against the client
        if tonumber(executor.rank()) <= tonumber(client.rank()) then
            modules.server.DisplayDialogError(executor, G_ErrorCannotPerformUser)
            return
        end

        if G_Clients[client.user:getID()] then
            modules.server.SendChatMessage(client.user:getID(), string.format('[Moderation] %s has set your rank to %s', executor.user:getName(), outStr), modules.server.ColourSuccess)
            modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'rank', rank)
        end

        modules.server.SendChatMessage(string.format('[Moderation] %s is now a %s', client.user:getName(), outStr), modules.server.ColourSuccess)
    end
}

--[[ Mute ]]--
M.commands["mute"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Mute a user for a specified amount of time',
    usage = '/mute <user> (reason) <time>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local reason = args[2] or 'No reason specified'
        local time = args[3] or '10m'

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        -- Check if the executor is able to run the command against the client
        if executor.rank() <= client.rank() then
            modules.server.DisplayDialogError(executor, G_ErrorCannotPerformUser)
            modules.utilities.LogInfo('[Moderation] %s tried to mute %s. Reason: %s', executor.user:getName(), client.user:getName(), reason)

            return
        end

        local time_fmt = time:sub(-1) -- Get the prefix (for year, month, days, hours, etc...)
        if modules.utilities.IsNumber(time_fmt) then
            modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
            return
        end

        time = time:sub(1, -2) -- Get the actual time
        if not modules.utilities.IsNumber(time) then
            modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
            return
        end

        if modules.utilities.IsNumber(time) then
            local year, month, day, hour, min, sec = os.date('%Y-%m-%d %H:%M:%S'):match('(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')

            local date = {
                year = year,
                month = month,
                day = day,
                hour = hour,
                min = min,
                sec = sec
            }
            
            if time_fmt == 'y' then
                date.year = date.year + time
            elseif time_fmt == 'mo' then
                date.month = date.month + time
            elseif time_fmt == 'd' then
                date.day = date.day + time
            elseif time_fmt == 'h' then
                date.hour = date.hour + time
            elseif time_fmt == 'm' then
                date.min = date.min + time
            else
                modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments)
                return
            end
            
            local exp_sec = os.time{ year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min, sec = date.sec }

            modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'mute_time', exp_sec)

            if G_Clients[client.user:getID()] then
                modules.server.SendChatMessage(client.user:getID(), string.format('You have been muted by %s. Unmute Date: %s', executor.user:getName(), os.date('%Y-%m-%d %H:%M:%S', exp_sec)))
            end

            modules.server.SendChatMessage(string.format('[Moderation] %s has been muted by %s', executor.user:getName(), client.user:getName()))
            modules.utilities.SendAPI({
                executor = {
                    name = executor.user:getName()
                },
                client = {
                    name = client.user:getName()
                },
                time_str = os.date('%Y-%m-%d %H:%M:%S', exp_sec),
                reason = reason,
                data = 'muted',
                type = 'mod_log'
            })
        end
    end
}

--[[ Unmute ]]--
M.commands["unmute"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Unmute a user',
    usage = '/unmute <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        -- Check if the executor is able to run the command against the client
        if executor.rank() <= client.rank() then
            modules.server.DisplayDialogError(executor, G_ErrorCannotPerformUser)
            return
        end

        modules.utilities.EditKey(G_PlayersLocation, client.user:getSecret(), 'mute_time', 0)

        if G_Clients[client.user:getID()] then
            modules.server.SendChatMessage(client.user:getID(), string.format('You have been unmuted by %s', executor.user:getName()))
            modules.server.DisplayDialogWarning(executor, 'User it not muted')
        end

        modules.utilities.SendAPI({
            executor = {
                name = executor.user:getName()
            },
            client = {
                name = client.user:getName()
            },
            data = 'unmuted',
            type = 'mod_log'
        })

        modules.server.SendChatMessage(string.format('[Moderation] %s has been unmuted by %s', executor.user:getName(), client.user:getName()))
    end
}

--[[ Freeze ]]--
M.commands["freeze"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Freeze a user',
    usage = '/freeze <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        local ply = connections[client.user:getID()] or nil
        local vehicle = vehicles[ply:getCurrentVehicle()] or nil

        if vehicle then
            vehicle:sendLua('controller.setFreeze(1)')
            modules.server.DisplayDialogWarning(client, 'You have been frozen')
        else
            modules.server.DisplayDialogError(executor, G_ErrorNotInVehicle)
        end
    end
}

--[[ Unfreezw ]]--
M.commands["unfreeze"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Unfreeze a user',
    usage = '/unfreeze <user>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        local ply = connections[client.user:getID()]
        local vehicle = vehicles[ply:getCurrentVehicle()]

        if vehicle then
            vehicle:sendLua('controller.setFreeze(0)')
            modules.server.DisplayDialogSuccess(client, 'You have been unfrozen')
        else
            modules.server.DisplayDialogError(executor, G_ErrorNotInVehicle)
        end
    end
}

--[[ Send Message (UI) ]]--
M.commands["send_message"] = {
    rank = modules.moderation.RankModerator,
    category = 'Moderation',
    description = 'Puts a message on the users screen',
    usage = '/send_message <user> <message>',
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

        client.user:sendLua("extensions.core_gamestate.setGameState(nil, 'proceduralScenario', nil, nil)")

        modules.timed_events.AddEvent(function()
            client.user:sendLua("guihooks.trigger('ScenarioFlashMessage', {{'"..message.."'  , 5, 0, true}})")
        end, '_set_message_ui_'..client.user:getID(), 1, true)

        modules.timed_events.AddEvent(function()
            client.user:sendLua("extensions.core_gamestate.setGameState(nil, 'freeroam', nil, nil)")
        end, '_set_normal_ui_'..client.user:getID(), 6, true)
    end
}

--[[ Report ]]--
M.commands["report"] = {
    rank = modules.moderation.RankUser,
    category = 'Moderation',
    description = 'Reports a user',
    usage = '/report <user> <message>',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])
        local reason = args[2] or nil

        table.remove(args, 1)

        print('Oi mate')

        local message = ''
        for _, v in pairs(args) do
            message = message .. v .. ' '
        end
        reason = message

        -- Check if the client exists
        if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        if not reason then modules.server.DisplayDialogError(executor, G_ErrorInvalidArguments) return end
        
        -- Send report to all moderators
        for _, c in pairs(G_Clients) do
            if c.rank() > modules.moderation.RankVIP then
                modules.server.DisplayDialogWarning(c, string.format('%s reported %s for: %s', executor.user:getName(), client.user:getName(), reason), 6)
            end
        end
    end
}

--[[ Get ids ]]--
M.commands["get_ids"] = {
    rank = modules.moderation.RankUser,
    category = 'Moderation',
    description = 'Returns a list of users and their in-game ID\'s',
    usage = '/get_ids (user)',
    exec = function(executor, args)
        local client = modules.server.GetUser(args[1])

        -- Check if the client exists
        if args[1] then
            if not client.success or not modules.server.GetUserKey(client.data, 'rank') then modules.server.DisplayDialogError(executor, G_ErrorInvalidUser) return end

            if client.success then
                modules.server.SendChatMessage(executor.user:getID(), client.data.user:getName() .. ' - ' .. client.data.mid)
            end
        else
            for _, c in pairs(G_Clients) do
                modules.server.SendChatMessage(executor.user:getID(), c.user:getName() .. ' - ' .. c.mid)
            end
        end
    end
}

local function ReloadModules()
    modules = G_ReloadModules(modules, 'cmd_moderation.lua')
end

M.ReloadModules = ReloadModules
M.commands = M.commands

return M