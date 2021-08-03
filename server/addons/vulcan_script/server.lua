local M = {}

local modules = {
    utilities = require('addons.vulcan_script.utilities'),
    timed_events = require('addons.vulcan_script.timed_events')
}

--[[ Colours ]]--
local ColourSuccess = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'success'))
local ColourWarning = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'warning'))
local ColourError = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'error'))
local ColourDarkweb = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'darkweb'))
local ColourTwitter = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'twitter'))
local ColourPoliceRadio = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'police_radio'))
local ColourMention = modules.utilities.GetColour(modules.utilities.GetKey(G_ColoursLocation, 'mention'))

--[[ Enviroment Variables ]]--
local environmentTime = {
    dayscale = 0.5,
    nightScale = 0.5,
    azimuthOverride = 0,
    dayLength = 1800,
    time = 0.80599999427795,
    play = false
}

local environmentWind = {
    x = 0,
    y = 0,
    z = 0
}

--[[ Player Tables ]]
local consolePlayer = {
    --[[ User Table ]]--
    user = {
        getID = function() return 1337 end,
        getName = function() return 'Console' end,
        getSecret = function() return 'secret_console' end,
        getCurrentVehicle = function() return nil end,
        sendChatMessage = function() end,
        kick = function() end,
        sendLua = function() end,
        getIpAddr = function() return nil end
    },

    --[[ Functions ]]--
    rank = function() return 7 end,

    --[[ Variables ]]--
    connected = true,
    blockList = function() return {} end,
    mid = 1337,
}

local function SetClientDefaults(client)
    if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'rank', G_LevelError, true, true) then -- Rank
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'rank', 0)
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'alias', G_LevelError, true, true) then -- Alias
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'alias', {client:getName()})
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'warns', G_LevelError, true, true) then -- Warns
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'warns', {})
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'bans', G_LevelError, true, true) then -- bans
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'bans', {})
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'vehicleLimit', G_LevelError, true, true) then -- vehicleLimit
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'vehicleLimit', 2)
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'mute_time', G_LevelError, true, true) then -- mute_time
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'mute_time', 0)
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'playtime', G_LevelError, true, true) then -- playtime
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'playtime', 0)
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'blockList', G_LevelError, true, true) then -- blockList
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'blockList', {})
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'home', G_LevelError, true, true) then -- home
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'home', {x=0.9658128619194032, y=709.3377075195312, z=-0.006330838892608881, xr=-0.7625573873519897, yr=-0.00027202203636989, zr=52.24008560180664, w=-0.25916287302970886})
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'roles', G_LevelError, true, true) then -- roles
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'roles', {})
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'money', G_LevelError, true, true) then -- money
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'money', 240)
    else if not modules.utilities.GetKey(G_PlayersLocation, client:getSecret(), 'onduty', G_LevelError, true, true) then -- onduty
        modules.utilities.EditKey(G_PlayersLocation, client:getSecret(), 'onduty', false)
    end end end end end end end end end end end end
end

local function AddClient(client_id)
    SetClientDefaults(connections[client_id])
    G_CurrentPlayers = G_CurrentPlayers + 1

    G_Clients[client_id] = {}

    local client = G_Clients[client_id]
    client.user = connections[client_id]

    client.rank = function() return tonumber(modules.utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'rank')) end
    client.roles = function() return string.lower(modules.utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'roles')) end

    client.blockList = function() return modules.utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'blockList') end

    client.mid = G_CurrentPlayers

    client.commandCooldown = false

    client.setHome = function(x, y, z, xr, yr, zr, w)
        modules.utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'home', {x = x, y = y, z = z, xr = xr, yr = yr, zr = zr, w = w})
    end

    client.getHome = function()
        return modules.utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'home')
    end

    --[[ Needed to update players ]]--
    if not client.getHome() then
        client.setHome(709.3377075195312, -0.7625573873519897, 52.24008560180664, -0.006330838892608881, -0.00027202203636989, -0.25916287302970886, 0.9658128619194032)
    end

    if not modules.utilities.GetKey(G_PlayersLocation, connections[client_id]:getSecret(), 'blockList', G_LevelDebug, true) then
        modules.utilities.EditKey(G_PlayersLocation, connections[client_id]:getSecret(), 'blockList', {})
    end

    --[[ Client Vehicles ]]--
    client.vehicles = {}
    client.vehicles.count = 0

    client.vehicles.add = function(player, vehicleID)
        player.vehicles[vehicleID] = vehicles[vehicleID]
        GDLog('%s vehicle count: %d', player.user:getName(), player.vehicles.count)

        -- modules.timed_events.AddEvent(function()
        --     local ply = connections[player.user:getID()]
        --     local vehicle = vehicles[ply:getCurrentVehicle()]
        --     player.vehicles.current = vehicle
        -- end, 'add_current_vehicle_'..player.user:getID()..'_'..vehicleID, 2, true)
    end

    client.vehicles.remove = function(player, vehicleID)
        GDLog('%s vehicle count: %d', player.user:getName(), player.vehicles.count)
        if type(vehicleID) == 'number' then
            if player.vehicles[vehicleID] then
                G_Try(function ()
                    vehicles[vehicleID]:remove()
                end)
                player.vehicles[vehicleID] = nil

                if client.vehicles.count -1 >= 0 then
                    client.vehicles.count = client.vehicles.count - 1
                end
            end
        end
    end

    client.vehicles.clear = function(player)
        for id, _ in pairs(player.vehicles) do
            if type(id) == 'number' then
                if player.vehicles[id] then
                    player.vehicles.remove(player, id)
                end
            end
        end
    end

    --[[ Client GPS ]]--
    client.gps = {}
    client.gps.enabled = false
    client.gps.position = {}

    client.gps.position.x = 0
    client.gps.position.y = 0
    client.gps.position.z = 0

    --[[ Client Cuffed ]]--
    client.cuffed = {}
    client.cuffed.isCuffed = false
    client.cuffed.isBeingDragged = false
    client.cuffed.dragPosition = { x = 0, y = 0, z = 0, xr = 0, yr = 0, zr = 0, w = 0 }
    client.cuffed.executor = nil

    GDLog('Client added: %s', G_Clients[client_id].user:getName())
end

local function RemoveClient(client_id)
    G_Clients[client_id] = nil
end

local function GetUser(user) -- ID, Name, Secret
    if not user then return {data=nil, success=false} end

    local utilities = require('addons.vulcan_script.utilities')
    local userFoundCount = 0
    local userFound = {}

    for _, client in pairs(G_Clients) do
        if user == client.user:getName() then
            --[[ (In-Game) Client Name was Found ]]--
            return {data=client, success=true}
        else if tonumber(user) == client.mid then
            --[[ (In-Game) Client MID was Found ]]--
            return {data=client, success=true}
        else if tonumber(user) == client.user:getID() then
            --[[ (In-Game) Client ID was Found ]]--
            return {data=client, success=true}
        else if user == client.user:getSecret() then
            --[[ (In-Game) Client Secret was Found ]]--
            return {data=client, success=true}
        else
            if type(user) == 'table' or type(client.user:getName()) == 'table' then
                GWLog('GetUser(user) is a table')
                for k, v in pairs(user) do
                    GWLog('-> ' .. tostring(k) .. ' ' .. tostring(v))
                end
            else
                if string.match(string.lower(client.user:getName()), string.lower(user)) ~= nil then
                    userFoundCount = userFoundCount + 1
                    userFound = client
                end
            end
        end end end end
    end

    if userFoundCount == 1 then
        return {data=userFound, success=true}
    else
        return {data=nil, success=false}
    end

    --[[ (Not In-Game) Get User by Client Secret ]]--
    if utilities.GetKey(G_PlayersLocation, user) then
        --[[ Secret was found, create fake data and return ]]--
        local data = {
            user = {
                getSecret = function() return user end,
                getName = function() return utilities.GetKey(G_PlayersLocation, user, 'alias')[1] end,
                sendChatMessage = function() end,
                getID = function() return nil end,
                sendLua = function() end,
                kick = function() end
            },

            blockList = function() return utilities.GetKey(G_PlayersLocation, user, 'blockList') end,
            rank = function() return utilities.GetKey(G_PlayersLocation, user, 'rank') end,
            roles = function() return utilities.GetKey(G_PlayersLocation, user, 'roles') end,
            mid = -1
        }

        return {data=data, success=true}
    else
        for secret, _ in pairs(utilities.GetKey(G_PlayersLocation)) do
            --[[ (Not In-Game) Get Client Alias ]]--

            if secret ~= 'secret_console' then
                if user == utilities.GetKey(G_PlayersLocation, secret, 'alias')[1] then
                    --[[ Alias has been found, create fake data and return ]]--
                    local data = {
                        user = {
                            getSecret = function() return secret end,
                            getName = function() return utilities.GetKey(G_PlayersLocation, secret, 'alias')[1] end,
                            sendChatMessage = function() end,
                            getID = function() return nil end,
                            sendLua = function() end
                        },

                        rank = function() return utilities.GetKey(G_PlayersLocation, secret, 'rank') end,
                        roles = function() return utilities.GetKey(G_PlayersLocation, secret, 'roles') end,
                        mid = -1
                    }

                    return {data=data, success=true}
                end
            end
        end
    end

    return {data=nil, success=false}
end

local function GetUserKey(user, key)
    --[[ Check if Key is nil ]]--
    if not key then return end

    local utilities = require('addons.vulcan_script.utilities')

    for _, client in pairs(G_Clients) do
        --[[ Iterate Over All Clients ]]--

        if user == client.user:getSecret() then
            --[[ (In-Game) Client Secret Was Found ]]--
            return utilities.GetKey(G_PlayersLocation, client.user:getSecret(), key) -- in-game name
        else
            if tonumber(user) == client.mid then
                --[[ (In-Game) Client MID Was Found ]]
                return {data=client, success=true} -- mapped id
            else
                for secret, _ in pairs(utilities.GetKey(G_PlayersLocation)) do
                    --[[ Find an Alias of a Client (In-Game & Not In-Game) ]]--

                    for _, name in pairs(_) do
                        if type(name) == 'table' then
                            --[[ Alias Table ]]--

                            for a, b in pairs(name) do
                                --[[ Check if Alias is Equal to User ]]--

                                if a == 1 and user == b then
                                    --[[ Return Player Data ]]--
                                    return utilities.GetKey(G_PlayersLocation, secret, key)
                                end
                            end
                        else
                            if name == user then
                                --[[ No Alias ]]--
                                return utilities.GetKey(G_PlayersLocation, secret, key)
                            else
                                --[[ Nothing found?? Idk, returns secret I guess ]]--
                                return secret
                            end
                        end
                    end
                end
            end
        end
    end
end

local vch = {}

local function IsConnected(client, name, exec)
    local vehicle_id = connections[client.user:getID()]:getCurrentVehicle() or nil
    local vehicle = vehicles[vehicle_id] or nil
    vch[name] = {
        vehicle_id = vehicle_id,
        vehicle = vehicle
    }

    modules.timed_events.AddEvent(function()
        if not vch[name].vehicle then
            if connections[client.user:getID()] then
                vch[name].vehicle_id = connections[client.user:getID()]:getCurrentVehicle() or nil
                vch[name].vehicle = vehicles[vch[name].vehicle_id] or nil
            end
        else
            client.connected = true
            exec()

            modules.timed_events.RemoveEvent(name)
        end

    end, name, 2, false)
end

local function IsInRadius(location, radius, x, y)
    local data = modules.utilities.GetKey(G_Locations, location)
    for _, v in pairs(data) do
        if type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number' then
            if (x > v.x - radius and x < v.x + radius) and (y > v.y - radius and y < v.y + radius) then
                GDLog('[Number] Location Found\nYour coords: %s, %s\nRequired Coords: %s, %s', x, y, v.x, v.y)
                return {true, _}
            end
        else
            for k, j in pairs(v) do
                if (x > j.x - radius and x < j.x + radius) and (y > j.y - radius and y < j.y + radius) then
                    GDLog('[Table] Location Found\nYour coords: %s, %s\nRequired Coords: %s, %s', x, y, j.x, j.y)
                    return {true, k}
                end
            end
        end
    end

    return {false, nil}
end

local function CreateMarker(client, name, obj, x, y, z, colour, scale)
    colour = colour or {255, 255, 255, 255}
    scale = scale or {1, 1, 1}
    -- t.useInstanceRenderData = 1 t.instanceColor = ColorF('..colour[1]..','..colour[2]..','..colour[3]..','..colour[4]'):asLinear4F()
    -- t:setField("instanceColor", 0, "'..colour[1]..','..colour[2]..','..colour[3]..','..colour[4]'")
    -- function CreateMarker(client, name, obj, x, y, z, colour, scale)    colour = colour or {255, 255, 255, 255}    scale = scale or {1, 1, 1}    local t = createObject("TSStatic") t.shapeName = obj t:setPosition(Point3F(x,y,z)) t:setScale(Point3F(scale[1],scale[2],scale[3])) t.useInstanceRenderData = 1 t.instanceColor = ColorF(colour[1],colour[2],colour[3],colour[4]):asLinear4F() t:registerObject(name) end
    client.user:sendLua('local t = createObject("TSStatic") t.shapeName = "'..obj..'" t:setPosition(Point3F('..x..', '..y..', '..z..')) t:setScale(Point3F('..scale[1]..','..scale[2]..','..scale[3]..')) t.useInstanceRenderData = 1 t.instanceColor = ColorF('..colour[1]..','..colour[2]..','..colour[3]..','..colour[4]..'):asLinear4F() t:registerObject("'..name..'")')
end

local function InitializeMarkers(client)
    local count = 0

    --[[ Petrol Stations ]]
    for townName, fuelStation in pairs(modules.utilities.GetKey(G_Locations, 'fuel_pumps')) do
        for _, location in pairs(fuelStation) do
            count = count + 1
            CreateMarker(client, 'pump_'..townName..count, 'art/shapes/interface/checkpoint_marker_base.dae', location.x, location.y, location.z-0.3)
        end
    end

    count = 0

    --[[ Robbable Stores ]]
    for storeName, store in pairs(modules.utilities.GetKey(G_Locations, 'robbable_shops')) do
        count = count + 1
        CreateMarker(client, 'repair_'..storeName..count, 'art/shapes/interface/checkpoint_marker_base.dae', store.x, store.y, store.z-0.4, {0.7, 0.19, 0.23, 1}, {1, 1, 2})
    end

    count = 0

    --[[ Mechanics ]]
    for mechanicName, repairStation in pairs(modules.utilities.GetKey(G_Locations, 'repair_stations')) do
        count = count + 1
        if type(repairStation.x) == 'number' and type(repairStation.y) == 'number' and type(repairStation.z) == 'number' then
            CreateMarker(client, 'repair_'..mechanicName..count, 'art/shapes/interface/checkpoint_marker_base.dae', repairStation.x, repairStation.y, repairStation.z-0.4, {0.8, 0.4, 0.03, 2}, {4, 4, 1})
        else
            for _, location in pairs(repairStation) do
                CreateMarker(client, 'repair_'..mechanicName..count, 'art/shapes/interface/checkpoint_marker_base.dae', location.x, location.y, location.z-0.4, {0.8, 0.4, 0.03, 1}, {2, 2, 2})
            end
        end
    end

    count = 0
end

--[[ Game Functions ]]--
local function DisplayDialog(error, client, message, time)
    --[[ Check if we're using normal modules.server.DisplayDialog() or modules.server.DisplayDialogError() ]]
    if not G_Errors[error] then
        time = message
        message = client
        client = error
        error = nil
    end

    time = time or 3

    if G_CommandExecuted then
        --modules.utilities.LogReturn(message)
    end

    if client.user then
        --[[ Send to One Client ]]--
        client.user:sendLua(string.format("ui_message('%s', %s)", message, time))
    else
        --[[ Send to All Clients ]]--
        for _, c in pairs(G_Clients) do
            c.user:sendLua(string.format("ui_message('%s', %s)", message, time))
        end
    end
end

local function DisplayDialogError(client, error)
    if G_Errors[error] then
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", G_Errors[error]))
        --DisplayDialog(error, client, G_Errors[error], time)
    else
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", tostring(error)))
    end
end

local function DisplayDialogWarning(client, error)
    if G_Errors[error] then
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", G_Errors[error]))
        --DisplayDialog(error, client, G_Errors[error], time)
    else
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", tostring(error)))
    end
end

local function DisplayDialogSuccess(client, error)
    if G_Errors[error] then
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", G_Errors[error]))
        --DisplayDialog(error, client, G_Errors[error], time)
    else
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", tostring(error)))
    end
end

local function SendChatMessage(client_id, message, colour)
    --if G_CurrentPlayers == 1 then return end --[[ Don't Send Anything to Prevent Spam ]]--
    --GDLog('Sending Message (client_id, msg, colour): %s %s %s', client_id or nil, message or nil, colour or nil)
    --[[ Check if Client is Valid ]]--
    if not G_Clients[client_id] then
        colour = message
        message = client_id
    end

    if G_CommandExecuted then
        --modules.utilities.LogReturn(message)
    end

    --[[ Check if Colour is Valid ]]--
    if type(colour) ~= 'table' then colour = {} end
    colour.r = colour.r or 1
    colour.g = colour.g or 1
    colour.b = colour.b or 1

    local canSend = true

    --[[ Send to All Because Client is nil ]]--
    if not G_Clients[client_id] then
        message = client_id

        for _, client in pairs(G_Clients) do
            for key, name in pairs(client.blockList()) do
                if key == client.user:getSecret() then
                    canSend = false
                else
                    canSend = true
                end
            end

            --[[ Send Message to All Clients ]]--
            if canSend then
                client.user:sendLua('kissui.add_message(' .. modules.utilities.LuaStrEscape(message) .. ', {r=' ..
                tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
                tostring(colour.b) .. ",a=1})")
            end
        end
    else
        for key, name in pairs(G_Clients[client_id].blockList()) do
            if key == G_Clients[client_id].user:getSecret() then
                canSend = false
            else
                canSend = true
            end
        end

        --[[ Send Message to Client ]]--
        if canSend then
            G_Clients[client_id].user:sendLua('kissui.add_message(' .. modules.utilities.LuaStrEscape(message) .. ', {r=' ..
            tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
            tostring(colour.b) .. ",a=1})")
            canSend = false
        end
    end
end

--[[ Utility Functions ]]--
local function ReloadModules()
    GDLog("Reloaded")
    modules = G_ReloadModules(modules, 'server.lua')
    GDLog("Reloaded")
end

--[[ Colour Variables ]]--
M.ColourSuccess = ColourSuccess
M.ColourWarning = ColourWarning
M.ColourError = ColourError

M.ColourTwitter = ColourTwitter
M.ColourDarkweb = ColourDarkweb
M.ColourPoliceRadio = ColourPoliceRadio

M.ColourMention = ColourMention

--[[ Enviroment Variables ]]--
M.environmentTime = environmentTime
M.environmentWind = environmentWind

--[[ Player Functions & Variables ]]--
M.consolePlayer = consolePlayer
M.AddClient = AddClient
M.RemoveClient = RemoveClient
M.GetUser = GetUser
M.GetUserKey = GetUserKey
M.IsConnected = IsConnected
M.IsInRadius = IsInRadius

M.SendChatMessage = SendChatMessage
M.DisplayDialog = DisplayDialog
M.DisplayDialogError = DisplayDialogError
M.DisplayDialogWarning = DisplayDialogWarning
M.DisplayDialogSuccess = DisplayDialogSuccess

--[[ Utility Functions ]]--
M.InitializeMarkers = InitializeMarkers
M.ReloadModules = ReloadModules

return M