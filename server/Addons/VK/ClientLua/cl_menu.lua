local M = {}

require('Addons.VK.globals')

local Modules = {
    cl_tab_Moderation = require('Addons.VK.ClientLua.cl_tab_moderation'),
    cl_tab_debug = require('Addons.VK.ClientLua.cl_tab_debug'),
    cl_tab_players = require('Addons.VK.ClientLua.cl_tab_players'),
    Utilities = require('Addons.VK.Utilities')
}

--[[
    In teleport I can check the player ID via 
        for k, v in pairs(kissplayers.players_in_cars) do print(k) end

        This returns all players_id's that are in a car
]]

--[[
    TODO 2 buttons to enable/disable tags
]]

local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

local clients

local function UpdateClients(executor)
    clients = copy(G_Clients)
    clients[1337] = nil

    for id, _ in pairs(clients) do
        clients[id].rank = clients[id].rank()
        clients[id].roles = clients[id].roles()
        clients[id].blockList = clients[id].blockList()
        clients[id].getHome = clients[id].getHome()
        clients[id].name = clients[id].user:getName()
        clients[id].id = clients[id].user:getID()
        clients[id].secret = clients[id].user:getSecret()
        clients[id].vehicles.add = nil
        clients[id].vehicles.clear = nil
        clients[id].vehicles.remove = nil

        for k, v in pairs(Modules.Utilities.GetKey(G_PlayersLocation, clients[id].user:getSecret(), 'roles')) do
            clients[id].roles[k] = v
        end
    end

    for k, v in pairs(connections) do
        clients[k].vehicles[v:getCurrentVehicle()] = {
            getData = {
                getInGameID = vehicles[v:getCurrentVehicle()]:getData():getInGameID(),
                getID = vehicles[v:getCurrentVehicle()]:getData():getInGameID(),
                getColor = vehicles[v:getCurrentVehicle()]:getData():getColor(),
                getPalete0 = vehicles[v:getCurrentVehicle()]:getData():getInGameID(),
                getPalete1 = vehicles[v:getCurrentVehicle()]:getData():getPalete1(),
                getPlate = vehicles[v:getCurrentVehicle()]:getData():getPlate(),
                getName = vehicles[v:getCurrentVehicle()]:getData():getName(),
                getOwner = vehicles[v:getCurrentVehicle()]:getData():getOwner(),
            },
            getTransform = {
                getPosition = vehicles[v:getCurrentVehicle()]:getTransform():getPosition(),
                getRotation = vehicles[v:getCurrentVehicle()]:getTransform():getRotation(),
                getVelocity = vehicles[v:getCurrentVehicle()]:getTransform():getVelocity(),
                getAngularVelocity = vehicles[v:getCurrentVehicle()]:getTransform():getAngularVelocity()
            }
        }
    end

    executor.user:sendLua(G_LuaFormat(string.format([[
        extensions.clutchrp_interface.UpdatePlayers('%s')
    ]], encode_json(clients))))
end

--[[

]]

local function BeginHook(executor)
    executor.user:sendLua(G_LuaFormat(string.format([[
        log('I', 'clutchrp_interface', 'BeginHook')

        local me = %d

        local clientModeration = nil
        local clientPlayers = nil
        local clients = jsonDecode(extensions.clutchrp_interface.ui.clients)
        local imgui = ui_imgui
        local shouldPop = false
        local showrc = false
        local drawPlayerInfo = false
        local drawCarInfo = false

        local function _CallbackRender(dt, _, _)
            clients = jsonDecode(extensions.clutchrp_interface.ui.clients)
            local display_size = imgui.GetIO().DisplaySize
            imgui.Begin('Vulcan Moderation')
                if imgui.BeginTabBar('##tabs') then
                    if imgui.BeginTabItem('Moderation') then
                        %s
                        imgui.EndTabItem()
                    end

                    if imgui.BeginTabItem('Debug') then
                        %s
                        imgui.EndTabItem()
                    end

                    if imgui.BeginTabItem('Players') then
                        %s
                        imgui.EndTabItem()
                    end
                    
                    imgui.EndTabBar()
                end
            imgui.End()
        end

        oldUIHook = extensions.clutchrp_interface.ui._Render
        extensions.clutchrp_interface.ui._Render = _CallbackRender
    ]], executor.user:getID(), Modules.cl_tab_Moderation.draw(), Modules.cl_tab_debug.draw(), Modules.cl_tab_players.draw())))
end

local function EndHook(executor)
    executor.user:sendLua(G_LuaFormat([[
        log('I', 'clutchrp_interface', 'EndHook')
        extensions.clutchrp_interface.ui._Render = oldUIHook
    ]]))
end

local function ToggleMenu(executor)
    if executor.renderMenu then BeginHook(executor) else EndHook(executor) end

    return G_LuaFormat([[
        extensions.clutchrp_interface.show = not extensions.clutchrp_interface.show
    ]])
end

local function ReloadModules()
    Modules = G_ReloadModules(Modules, 'cl_menu.lua')
end

M.UpdateClients = UpdateClients
M.ToggleMenu = ToggleMenu
M.ReloadModules = ReloadModules

return M