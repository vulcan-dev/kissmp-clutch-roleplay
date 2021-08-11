--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local roles = {
    'dispatch',
    'police',
    'fire',
    'ems',
}

local modules = {
    utilities = require('addons.vulcan_script.utilities')
}

-- [[ Fucntions ]] --
local function HasRole(client, role)
    if client.user:getSecret() == 'secret_console' then return end

    local found = false

    local count = 0
    for _, v in ipairs(client.getKey('roles')) do
        if tostring(role) == tostring(v) then
            found = true
            break
        else
            found = false
        end

        count = count + 1
    end

    return found
end

local function IsLeo(client)
    if HasRole(client, 'dispatch') or HasRole(client, 'police') or HasRole(client, 'fire') or HasRole(client, 'ems') then
        return true
    end

    return false
end

local function IsOnDuty(client)
    return client.getKey('onduty')
end

local function ReloadModules()
    modules = G_ReloadModules(modules, 'moderation.lua')
end

--[[ Getters ]]--
M.HasRole = HasRole
M.IsLeo = IsLeo
M.IsOnDuty = IsOnDuty

--[[ Variables ]]--
M.roles = roles

--[[ Reload Modules ]]--
M.ReloadModules = ReloadModules

return M