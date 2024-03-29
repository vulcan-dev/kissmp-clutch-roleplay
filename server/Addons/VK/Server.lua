local M = {}

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    TimedEvents = require('Addons.VK.TimedEvents'),
    CVehicle = require('Addons.VK.Client.CVehicle')
}

--[[ Colours ]]--
local ColourSuccess = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'success'))
local ColourWarning = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'warning'))
local ColourError = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'error'))
local ColourDarkweb = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'darkweb'))
local ColourTwitter = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'twitter'))
local ColourPoliceRadio = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'police_radio'))
local ColourMention = Modules.Utilities.GetColour(Modules.Utilities.GetKey(G_ColoursLocation, 'mention'))

--[[ Globals ]]--
G_Environment = {
    time = {
        dayscale = 0.5,
        nightScale = 0.5,
        azimuthOverride = 0,
        dayLength = 1800,
        time = 0.80599999427795,
        play = false
    },

    wind = {
        x = 0,
        y = 0,
        z = 0
    },

    rain = 0,
    weather = 'extrasunny'
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

local function AddClient(client_id)
    G_CurrentPlayers = G_CurrentPlayers + 1

    G_Clients[client_id] = {}

    local client = G_Clients[client_id]
    client.user = connections[client_id]

    client.editKey = function(key, value)
        Modules.Utilities.EditKey(G_PlayersLocation, G_Clients[client_id].user:getSecret(), key, value)
    end

    client.getKey = function(key)
        return Modules.Utilities.GetKey(G_PlayersLocation, G_Clients[client_id].user:getSecret(), key)
    end

    client.firstConnect = true

    client.getActiveCharacter = function()
        for _, character in pairs(client.getKey('characters')) do
            if character.active then return character end
        end

        return false
    end

    client.editCharacter = function(key, value)
        local data = {}
        for k, v in pairs(client.getKey('characters')) do
            data[k] = v
        end

        data[client.getActiveCharacter().full_name][string.format('%s', key)] = value
        client.editKey('characters', data)
    end

    client.deleteCharacter = function(name)
        local data = {}
        local found = false
        for k, v in pairs(client.getKey('characters')) do
            if k ~= name then
                data[k] = v
            else found = true end
        end

        if not found then
            return false
        else
            data[name] = nil
            if client.getActiveCharacter().full_name == name then
                client.user:sendLua(G_LuaFormat("_Characters = jsonDecode('" .. encode_json(data) .. "')"))
                client.user:sendLua('extensions.clutchrpui.interface.character_selector.shouldDraw = true')
                client.user:sendLua(Modules.CVehicle.setFreeze(1))
            end

            client.editKey('characters', data)
            return true
        end
    end

    client.rank = function() return tonumber(client.getKey('rank')) end
    client.roles = function()
        local roles = {}
        for role, _ in pairs(client.getActiveCharacter().roles) do
            table.insert( roles, string.lower(role) )
        end
        return roles
    end

    client.blockList = function() return client.getKey('blockList') end

    client.mid = G_CurrentPlayers

    client.commandCooldown = false
    client.renderMenu = false

    client.setHome = function(x, y, z, xr, yr, zr, w)
        client.editKey('home', {x = x, y = y, z = z, xr = xr, yr = yr, zr = zr, w = w})
    end

    client.getHome = function()
        return client.getKey('home')
    end

    --[[ Needed to update players ]]--
    if not client.getHome() then
        client.setHome(709.3377075195312, -0.7625573873519897, 52.24008560180664, -0.006330838892608881, -0.00027202203636989, -0.25916287302970886, 0.9658128619194032)
    end

    --[[ Client Vehicles ]]--
    client.vehicles = {}
    client.vehicles.count = 0

    client.vehicles.add = function(player, vehicleID)
        player.vehicles[vehicleID] = vehicles[vehicleID]
        GDLog('%s vehicle count: %d', player.user:getName(), player.vehicles.count)
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
    if Modules.sUtilities.GetKey(G_PlayersLocation, user) then
        --[[ Secret was found, create fake data and return ]]--
        local data = {
            user = {
                getSecret = function() return user end,
                getName = function() return Modules.Utilities.GetKey(G_PlayersLocation, user, 'alias')[1] end,
                sendChatMessage = function() end,
                getID = function() return nil end,
                sendLua = function() end,
                kick = function() end
            },

            blockList = function() return Modules.Utilities.GetKey(G_PlayersLocation, user, 'blockList') end,
            rank = function() return Modules.Utilities.GetKey(G_PlayersLocation, user, 'rank') end,
            roles = function() return Modules.Utilities.GetKey(G_PlayersLocation, user, 'roles') end,
            mid = -1
        }

        return {data=data, success=true}
    else
        for secret, _ in pairs(Modules.Utilities.GetKey(G_PlayersLocation)) do
            --[[ (Not In-Game) Get Client Alias ]]--

            if secret ~= 'secret_console' then
                if user == Modules.Utilities.GetKey(G_PlayersLocation, secret, 'alias')[1] then
                    --[[ Alias has been found, create fake data and return ]]--
                    local data = {
                        user = {
                            getSecret = function() return secret end,
                            getName = function() return Modules.Utilities.GetKey(G_PlayersLocation, secret, 'alias')[1] end,
                            sendChatMessage = function() end,
                            getID = function() return nil end,
                            sendLua = function() end
                        },

                        rank = function() return Modules.Utilities.GetKey(G_PlayersLocation, secret, 'rank') end,
                        roles = function() return Modules.Utilities.GetKey(G_PlayersLocation, secret, 'roles') end,
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

    for _, client in pairs(G_Clients) do
        --[[ Iterate Over All Clients ]]--

        if user == client.user:getSecret() then
            --[[ (In-Game) Client Secret Was Found ]]--
            return Modules.Utilities.GetKey(G_PlayersLocation, client.user:getSecret(), key) -- in-game name
        else
            if tonumber(user) == client.mid then
                --[[ (In-Game) Client MID Was Found ]]
                return {data=client, success=true} -- mapped id
            else
                for secret, _ in pairs(Modules.Utilities.GetKey(G_PlayersLocation)) do
                    --[[ Find an Alias of a Client (In-Game & Not In-Game) ]]--

                    for _, name in pairs(_) do
                        if type(name) == 'table' then
                            --[[ Alias Table ]]--

                            for a, b in pairs(name) do
                                --[[ Check if Alias is Equal to User ]]--

                                if a == 1 and user == b then
                                    --[[ Return Player Data ]]--
                                    return Modules.Utilities.GetKey(G_PlayersLocation, secret, key)
                                end
                            end
                        else
                            if name == user then
                                --[[ No Alias ]]--
                                return Modules.Utilities.GetKey(G_PlayersLocation, secret, key)
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

    Modules.TimedEvents.AddEvent(function()
        if not vch[name].vehicle then
            if connections[client.user:getID()] then
                vch[name].vehicle_id = connections[client.user:getID()]:getCurrentVehicle() or nil
                vch[name].vehicle = vehicles[vch[name].vehicle_id] or nil
            end
        else
            client.connected = true
            exec()

            Modules.TimedEvents.RemoveEvent(name)
        end

    end, name, 2, false)
end

local function IsInRadius(location, radius, x, y)
    local data = Modules.Utilities.GetKey(G_Locations, location) or location
    for _, v in pairs(data) do
        if type(v.x) == 'number' and type(v.y) == 'number' and type(v.z) == 'number' then
            if (x > v.x - radius and x < v.x + radius) and (y > v.y - radius and y < v.y + radius) then
                -- GDLog('[Number] Location Found\nYour coords: %s, %s\nRequired Coords: %s, %s', x, y, v.x, v.y)
                return {true, _}
            end
        else
            for k, j in pairs(v) do
                if (x > j.x - radius and x < j.x + radius) and (y > j.y - radius and y < j.y + radius) then
                    -- GDLog('[Table] Location Found\nYour coords: %s, %s\nRequired Coords: %s, %s', x, y, j.x, j.y)
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
    for townName, fuelStation in pairs(Modules.Utilities.GetKey(G_Locations, 'fuel_pumps')) do
        for _, location in pairs(fuelStation) do
            count = count + 1
            CreateMarker(client, 'pump_'..townName..count, 'art/shapes/interface/checkpoint_marker_base.dae', location.x, location.y, location.z-0.3)
        end
    end

    count = 0

    --[[ Robbable Stores ]]
    for storeName, store in pairs(Modules.Utilities.GetKey(G_Locations, 'robbable_shops')) do
        count = count + 1
        CreateMarker(client, 'repair_'..storeName..count, 'art/shapes/interface/checkpoint_marker_base.dae', store.x, store.y, store.z-0.4, {0.7, 0.19, 0.23, 1}, {1, 1, 2})
    end

    count = 0

    --[[ Mechanics ]]
    for mechanicName, repairStation in pairs(Modules.Utilities.GetKey(G_Locations, 'repair_stations')) do
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
    --[[ Check if we're using normal Modules.Server.DisplayDialog() or Modules.Server.DisplayDialogError() ]]
    if not G_Errors[error] then
        time = message
        message = client
        client = error
        error = nil
    end

    time = time or 3

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

local function DisplayDialogError(client, message)
    if client and G_Errors[message] then
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", G_Errors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(G_Clients) do
            client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='error', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function DisplayDialogWarning(client, message)
    if client and G_Errors[message] then
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", G_Errors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(G_Clients) do
            client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='warning', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function DisplayDialogSuccess(client, message)
    if client and G_Errors[message] then
        client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", G_Errors[message]))
    else
        if type(client) ~= 'table' then message = client end
        for _, client in pairs(G_Clients) do
            client.user:sendLua(string.format("guihooks.trigger('toastrMsg', {type='success', title='%s', config = {timeOut = 3000}})", tostring(message)))
        end
    end
end

local function SendChatMessage(client_id, message, colour)
    if not G_Clients[client_id] then
        colour = message
        message = client_id
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
                client.user:sendLua('kissui.add_message(' .. Modules.Utilities.LuaStrEscape(message) .. ', {r=' ..
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
            G_Clients[client_id].user:sendLua('kissui.add_message(' .. Modules.Utilities.LuaStrEscape(message) .. ', {r=' ..
            tostring(colour.r) .. ",g=" .. tostring(colour.g) .. ",b=" ..
            tostring(colour.b) .. ",a=1})")
            canSend = false
        end
    end
end

--[[ Utility Functions ]]--
local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'Server.lua')
end

--[[ Colour Variables ]]--
M.ColourSuccess = ColourSuccess
M.ColourWarning = ColourWarning
M.ColourError = ColourError

M.ColourTwitter = ColourTwitter
M.ColourDarkweb = ColourDarkweb
M.ColourPoliceRadio = ColourPoliceRadio

M.ColourMention = ColourMention 

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