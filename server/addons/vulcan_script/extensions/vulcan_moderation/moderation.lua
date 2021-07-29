--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local modules = {
    utilities = require('addons.vulcan_script.utilities'),
    server = require('addons.vulcan_script.server')
}

local locked = false

local RankUser = 0
local RankTrusted = 1
local RankVIP = 2
local RankModerator = 3
local RankAdmin = 4
local RankOwner = 5
local RankDeveloper = 6
local RankConsole = 7

local StrRanks = {
    [RankUser] = 'user',
    [RankTrusted] = 'trusted',
    [RankVIP] = 'vip',
    [RankModerator] = 'moderator',
    [RankAdmin] = 'admin',
    [RankOwner] = 'owner',
    [RankDeveloper] = 'developer',
    [RankConsole] = 'console'
}

-- Utility Functions
local function GetBans(secret)
    local bans = {}

    for reason, val in pairs(modules.utilities.GetKey(G_PlayersLocation, secret, 'bans')) do
        bans[reason] = val
    end

    return bans
end

local function AddBan(secret, reason, date_of_issue, ban_expirey_date, ban_expirey_date_str, banned_by)
    ban_expirey_date = ban_expirey_date
    if modules.utilities.GetKey(G_PlayersLocation, secret, 'bans') then
        local data = modules.utilities.GetKey(G_PlayersLocation, secret, 'bans')
        data[reason] = {
            date_of_issue = date_of_issue,
            ban_expirey_date = ban_expirey_date,
            ban_expirey_date_str = ban_expirey_date_str,
            banned_by = banned_by
        }

        modules.utilities.EditKey(G_PlayersLocation, secret, 'bans', data)
    end
end

local function RemoveBan(secret, ban_name, disappear)
    if modules.utilities.GetKey(G_PlayersLocation, secret, 'bans') then
        local data = modules.utilities.GetKey(G_PlayersLocation, secret, 'bans')
        if not data[ban_name] then return false end

        if not disappear then -- Just set the time to 0
            data[ban_name]['ban_expirey_date'] = 0
        else -- Completely remove table
            data[ban_name] = nil
        end

        modules.utilities.EditKey(G_PlayersLocation, secret, 'bans', data)
        return true
    end
end

local function IsBanned(secret)
    local banned = false
    local time = 0
    local name = ''

    for reason, v in pairs(modules.utilities.GetKey(G_PlayersLocation, secret, 'bans')) do
        for key, value in pairs(v) do
            if key == 'ban_expirey_date' then
                if tonumber(value) > 0 then
                    banned = true
                    time = v['ban_expirey_date']
                    name = reason
                else
                    banned = false
                    time = 0
                    name = ''
                end
            end
        end
    end

    return {banned = banned, time=time, name = name}
end

--[[ Warns ]]--
local function AddWarn(secret, reason, date_of_issue, warned_by)
    if modules.utilities.GetKey(G_PlayersLocation, secret, 'warns') then
        local data = modules.utilities.GetKey(G_PlayersLocation, secret, 'warns')
        data[reason] = {
            date_of_issue = date_of_issue,
            warned_by = warned_by
        }
        
        modules.utilities.EditKey(G_PlayersLocation, secret, 'warns', data)
    end
end

local function GetWarns(secret)
    local warns = {}

    for reason, v in pairs(modules.utilities.GetKey(G_PlayersLocation, secret, 'warns')) do
        warns[reason] = v
    end

    return warns
end

--[[ Utilities ]]--
local function SendUserMessage(executor, prefix, message, all)
    all = all or true

    local rankStr = M.StrRanks[executor.rank()]
    local rankColour = modules.utilities.GetKey(G_ColoursLocation, rankStr)
    local name = G_Clients[executor.user:getID()].user:getName()
    local output = string.format('[%s] %s: %s', modules.utilities.ToTitle(rankStr), name, message)

    if prefix ~= nil then
        output = string.format('(%s) [%s] %s: %s', prefix, modules.utilities.ToTitle(rankStr), name, message)
    end

    rankColour = modules.utilities.GetColour(rankColour)

    if all then
        modules.server.SendChatMessage(output, rankColour)
    else
        modules.server.SendChatMessage(executor.user:getID(), output, rankColour)
    end
end

local function ReloadModules()
    modules = G_ReloadModules(modules, 'moderation.lua')
end

M.locked = locked

--[[ Table Bans ]]
M.IsBanned = IsBanned
M.AddBan = AddBan
M.RemoveBan = RemoveBan
M.GetBans = GetBans

--[[ Table Warns ]]--
M.AddWarn = AddWarn
M.GetWarns = GetWarns

--[[ Table Ranks ]]
M.RankUser = RankUser
M.RankTrusted = RankTrusted
M.RankVIP = RankVIP
M.RankModerator = RankModerator
M.RankAdmin = RankAdmin
M.RankOwner = RankOwner
M.RankDeveloper = RankDeveloper

--[[ Table Utilities ]]
M.SendUserMessage = SendUserMessage
M.StrRanks = StrRanks
M.ReloadModules = ReloadModules

return M