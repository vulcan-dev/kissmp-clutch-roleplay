--[[
    Created by Daniel W (Vitex#1248)
]]

require('addons.vulcan_script.globals')

local M = {}

local modules = {
    timed_events = require('addons.vulcan_script.timed_events')
}

--[[ JSON Locations ]]--
G_ServerLocation = './addons/vulcan_script/settings/server.json'
G_PlayersLocation = './addons/vulcan_script/settings/players.json'
G_ColoursLocation = './addons/vulcan_script/settings/colours.json'
G_BlacklistLocation = './addons/vulcan_script/settings/blacklist.json'
G_Locations = './addons/vulcan_script/settings/locations.json'

--[[ Utility Functions ]]--
local function GetDateTime(format, time)
    format = format or '%Y-%m-%d %H:%M:%S'

    return os.date(format, time)
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

local function Log(message, ...)
    print('['..GetDateTime()..'] ' .. tostring(string.format(message, ...)))
end

local function LogDebug(debug, ...) if G_Level == G_LevelDebug then Log('[DEBUG]: ' .. debug, ...) end end
local function LogInfo(info, ...) Log('[INFO]: ' .. info, ...) end
local function LogError(error, ...) Log('[ERRO]: ' .. error, ...) end
local function LogWarning(warning, ...) Log('[WARN]: ' .. warning, ...) end
local function LogFatal(fatal, ...) Log('[FATAL]: ' .. fatal, ...) os.execute('pause') os.exit(1) end

local function LogReturn(...) Log('[Return] ' .. ...) end

local function SendAPI(json)
    print('[API]: ' .. encode_json  (json))
end

--[[ Utility Data ]]--
local function EditKey(filename, object, key, value, log_level)
    if not object then Log({level=G_LevelError}, 'Invalid object specified in EditKey') return end
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
        LogError('Error opening "%s"', filename)
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
                Log({level=log_level}, string.format('Failed reading %s.%s from file "%s"', object, key, filename)) 
            end
        end)
    else
        if object and not key then
            return G_Try(function()
                return json_data[object]
            end, function()
                if not bypass then Log({level=log_level}, string.format('Failed reading %s from file "%s"', object, filename)) end
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
    for key, value in pairs(colour) do -- Convert RGB uint8 to 0-1
        colour[key] = value / 255
    end

    return colour
end

local function IsNumber(sIn)
    return tonumber(sIn) ~= nil
end

local function ReloadModules()
    modules = G_ReloadModules(modules, 'utilities.lua')
end

M.GetDateTime = GetDateTime
M.LuaStrEscape = LuaStrEscape
-- M.Log = Log
M.IsNumber = IsNumber

M.LogError = LogError
M.LogInfo = LogInfo
M.LogWarning = LogWarning
M.LogDebug = LogDebug
M.LogFatal = LogFatal
M.LogReturn = LogReturn
M.SendAPI = SendAPI

M.ParseCommand = ParseCommand
M.GetKey = GetKey
M.EditKey = EditKey
M.GetColour = GetColour
M.StartsWith = StartsWith
M.ReloadModules = ReloadModules

return M