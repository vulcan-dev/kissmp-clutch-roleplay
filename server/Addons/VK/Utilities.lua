--[[
    Created by Daniel W (Vitex#1248)
--]]

require('Addons.VK.globals')

local M = {}

local Modules = {
    TimedEvents = require('Addons.VK.TimedEvents')
}

--[[ JSON Locations ]]--
G_ServerLocation = './addons/VK/Settings/Server.json'
G_PlayersLocation = './addons/VK/Settings/Players.json'
G_ColoursLocation = './addons/VK/Settings/Colours.json'
G_BlacklistLocation = './addons/VK/Settings/Blacklist.json'
G_Locations = './addons/VK/Settings/Locations.json'

--[[ Utility Functions ]]--
local function FileToJSON(path)
    return decode_json(io.open(path, 'r'):read('*a'))
end

local function LuaStrEscape(str, q)
    local escapeMap = {
        ["\n"] = [[\n]],
        ["\\"] = [[\]]
    }

    local qOther = nil
    if not q then
        q = "'"
    end
    if q == "'" then
        qOther = '"'
    end

    local serializedStr = q
    for i = 1, str:len(), 1 do
        local c = str:sub(i, i)
        if c == q then
            serializedStr = serializedStr .. q .. " .. " .. qOther .. c .. qOther .. " .. " .. q
        elseif escapeMap[c] then
            serializedStr = serializedStr .. escapeMap[c]
        else
            serializedStr = serializedStr .. c
        end
    end
    serializedStr = serializedStr .. q
    return serializedStr
end

--[[ Logging ]]--

-- https://stackoverflow.com/questions/22123970/in-lua-how-to-get-all-arguments-including-nil-for-variable-number-of-arguments
function table.pack(...)
    return { n = select("#", ...); ... }
end

local function SendAPI(json)
    print('[API]: ' .. encode_json(json))
end

--[[ Utility Data ]]--
local function EditKey(filename, object, key, value, log_level)
    if not object then GLog({level=G_LevelError}, 'Invalid object specified in EditKey') return end
    log_level = log_level or G_LevelError

    -- Read all contents from file
    local file = io.open(filename, 'r')
    local current_data = decode_json(file:read('*all'))
    file:close()

    -- Write contents back to file with edits
    if not current_data[object] then current_data[object] = {} end

    if object and key and value or type(value) == 'boolean' then
        current_data[object][key] = value
    else
        if object and not key and not value then
            current_data[object] = {}
        end
    end

    file = io.open(filename, 'w+')
    file:write(encode_json_pretty(current_data))
    file:close()
end

local function GetKey(filename, object, key, log_level, bypass, create)
    if object == 'secret_console' then return end

    log_level = log_level or G_LevelError
    bypass = bypass or false

    local file = G_Try(function()
        return io.open(filename, 'r');
    end, function()
        GELog('Error opening "%s"', filename)
    end)

    local json_data = decode_json(file:read('*all'))

    file:close()

    if not object and not key then
        return json_data
    end

    if object and key then
        return G_Try(function()
            if create and not json_data[object] then
                EditKey(filename, object, {})
                return nil
            else
                return json_data[object][key]
            end
        end, function()
            if not bypass then
                GLog({level=log_level}, string.format('Failed reading %s.%s from file "%s"', object, key, filename)) 
            end
        end)
    else
        if object and not key then
            return G_Try(function()
                return json_data[object]
            end, function()
                if not bypass then GLog({level=log_level}, string.format('Failed reading %s from file "%s"', object, filename)) end
                return nil
            end)
        end
    end

    if json_data[object] ~= nil then
        if json_data[object] and not json_data[object][key] then
            return json_data[object]
        else
            if json_data[object][key] then
                return json_data[object][key]
            end
        end
    else
        return nil
    end
end

local function ParseCommand(cmd)
    local parts = {}
    local len = cmd:len()
    local escape_sequence_stack = 0
    local in_quotes = false

    local cur_part = ""
    for i = 1, len, 1 do
        local char = cmd:sub(i, i)
        if escape_sequence_stack > 0 then
            escape_sequence_stack = escape_sequence_stack + 1
        end
        local in_escape_sequence = escape_sequence_stack > 0
        if char == "\\" then
            escape_sequence_stack = 1
        elseif char == " " and not in_quotes then
            table.insert(parts, cur_part)
            cur_part = ""
        elseif char == '"' and not in_escape_sequence then
            in_quotes = not in_quotes
        else
            cur_part = cur_part .. char
        end
        if escape_sequence_stack > 1 then
            escape_sequence_stack = 0
        end
    end
    if cur_part:len() > 0 then
        table.insert(parts, cur_part)
    end
    return parts
end

local function StartsWith(string, start)
    return string.sub(string,1,string.len(start))==start
end

local function GetColour(colour)
    for key, value in pairs(colour) do -- Convert RGB 0-255 to 0-1
        colour[key] = value / 255
    end

    return colour
end

local function GetMessage(args, remove)
    if remove then table.remove(args, 1) end

    local message = ''
    for _, v in pairs(args) do
        message = message .. v .. ' '
    end

    return message
end

local function IsNumber(sIn)
    return tonumber(sIn) ~= nil
end

local function ToTitle(str)
    if str then return (str:gsub("^%l", string.upper)) else return "" end
end

local function LoadExtension(name)
    return require(string.format('Addons.VK.Server.Extensions.%s.%s', name, name))
end

local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'Utilities.lua')
end

M.FileToJSON = FileToJSON
M.LuaStrEscape = LuaStrEscape
M.GetMessage = GetMessage
M.IsNumber = IsNumber

M.SendAPI = SendAPI

M.ParseCommand = ParseCommand
M.GetKey = GetKey
M.EditKey = EditKey
M.GetColour = GetColour
M.StartsWith = StartsWith
M.ToTitle = ToTitle
M.LoadExtension = LoadExtension
M.ReloadModules = ReloadModules

return M