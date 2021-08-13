--[[
    Created by Daniel W (Vitex#1248)
--]]

require('Addons.VK.globals')

local M = {}

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    Moderation = require('Addons.VK.Server.Extensions.VK_Moderation.Moderation'),
    Server = require('Addons.VK.Server')
}

M.Commands = {}

--[[ Imitate ]]--
M.Commands["imitate"] = {
    rank = Modules.Moderation.RankAdmin,
    category = 'Moderation Fun',
    description = 'Imitates a user',
    usage = '/imitate <user> <message>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])
        -- Check if the client exists
        if not client.success or not Modules.Server.GetUserKey(client.data, 'rank') then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidUser) return end
        client = client.data

        if not args[2] then Modules.Server.DisplayDialogError(executor, G_ErrorInvalidMessage) return end

        local message = Modules.Utilities.GetMessage(args)

        Modules.Moderation.SendUserMessage(client, nil, message)
    end
}

--[[ Set Gravity ]]--
M.Commands["set_gravity"] = {
    rank = Modules.Moderation.RankAdmin,
    category = 'Moderation Fun',
    description = 'Sets gravity for everyone or for a specific user',
    usage = '/set_gravity (user) <value>',
    exec = function(executor, args)
        local client = Modules.Server.GetUser(args[1])
        local gravity = (not client.success and args[1] or args[2]) or -9.81

        if not client.success then
            client = executor
        else
            client = client.data
        end

        if Modules.Utilities.IsNumber(gravity) then
            client.user:sendLua('core_environment.setGravity('..gravity..')')
            Modules.Server.DisplayDialog(client, '[Enviroment] Gravity set to ' .. gravity)
        else
            Modules.Server.DisplayDialogError(executor, G_ErrorInvalidArguments)
        end
    end
}

--[[ Reload Modules ]]
local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'CommandFun.lua')
end

--[[ Return ]]
M.ReloadModules = ReloadModules
M.Commands = M.Commands

return M