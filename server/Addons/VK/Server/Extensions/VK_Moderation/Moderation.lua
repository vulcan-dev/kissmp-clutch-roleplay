--[[
    Created by Daniel W (Vitex#1248)
--]]

require('Addons.VK.globals')

local M = {}

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    Server = require('Addons.VK.Server')
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

    for reason, val in pairs(Modules.Utilities.GetKey(G_PlayersLocation, secret, 'bans')) do
        bans[reason] = val
    end

    return bans
end

local function AddBan(secret, reason, date_of_issue, ban_expirey_date, ban_expirey_date_str, banned_by)
    ban_expirey_date = ban_expirey_date
    if Modules.Utilities.GetKey(G_PlayersLocation, secret, 'bans') then
        local data = Modules.Utilities.GetKey(G_PlayersLocation, secret, 'bans')
        data[reason] = {
            date_of_issue = date_of_issue,
            ban_expirey_date = ban_expirey_date,
            ban_expirey_date_str = ban_expirey_date_str,
            banned_by = banned_by
        }

        Modules.Utilities.EditKey(G_PlayersLocation, secret, 'bans', data)
    end
end

local function RemoveBan(secret, ban_name, disappear)
    if Modules.Utilities.GetKey(G_PlayersLocation, secret, 'bans') then
        local data = Modules.Utilities.GetKey(G_PlayersLocation, secret, 'bans')
        if not data[ban_name] then return false end

        if not disappear then -- Just set the time to 0
            data[ban_name]['ban_expirey_date'] = 0
        else -- Completely remove table
            data[ban_name] = nil
        end

        Modules.Utilities.EditKey(G_PlayersLocation, secret, 'bans', data)
        return true
    end
end

local function IsBanned(secret)
    local banned = false
    local time = 0
    local name = ''

    for reason, v in pairs(Modules.Utilities.GetKey(G_PlayersLocation, secret, 'bans')) do
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
    if Modules.Utilities.GetKey(G_PlayersLocation, secret, 'warns') then
        local data = Modules.Utilities.GetKey(G_PlayersLocation, secret, 'warns')
        data[reason] = {
            date_of_issue = date_of_issue,
            warned_by = warned_by
        }
        
        Modules.Utilities.EditKey(G_PlayersLocation, secret, 'warns', data)
    end
end

local function GetWarns(secret)
    local warns = {}

    for reason, v in pairs(Modules.Utilities.GetKey(G_PlayersLocation, secret, 'warns')) do
        warns[reason] = v
    end

    return warns
end

--[[ Utilities ]]--
local function SendUserMessage(executor, prefix, message)
    local rankStr = M.StrRanks[executor.rank()]
    local rankColour = Modules.Utilities.GetKey(G_ColoursLocation, rankStr)
    local name = G_Clients[executor.user:getID()].user:getName()
    local output = string.format('[%s] %s: %s', Modules.Utilities.ToTitle(rankStr), name, message)

    if prefix ~= nil then
        output = string.format('(%s) [%s] %s: %s', prefix, Modules.Utilities.ToTitle(rankStr), name, message)
    end

    rankColour = Modules.Utilities.GetColour(rankColour)

    if executor and type(executor) == 'table' and G_Clients[executor.user:getID()] then
        Modules.Server.SendChatMessage(output, rankColour)
    else
        Modules.Server.SendChatMessage(executor.user:getID(), output, rankColour)
    end
end

local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'Moderation.lua')
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