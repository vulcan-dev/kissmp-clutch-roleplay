Hooks = {}

require('Addons.VK.Globals')

Hooks.ValidHooks = {
    ['OnPlayerConnected']=0,
    ['OnPlayerDisconnected']=0,
    ['OnVehicleSpawned']=0,
    ['OnVehicleResetted']=0,
    ['OnVehicleRemoved']=0,
    ['OnStdIn']=0,
    ['OnChat']=0,
    ['Tick']=0
}

Hooks.CustomHooks = {}

Hooks.Register = function(hook, subname, callback)
    if Hooks.ValidHooks[hook] then
        hooks.register(hook, subname, callback)
        GILog('Registered Callback { ' .. hook .. ' } : -> { ' .. subname .. ' }')
    else
        Hooks.CustomHooks[hook] = callback
        GILog('Registered Custom Callback { ' .. hook .. ' } -> { ' .. subname..' }')
    end
end

Hooks.Reload = function()
    for name, hook in pairs(Hooks.CustomHooks) do
        if string.find(name, 'ReloadModules') then
            hook()
        end
    end
end

Hooks.Call = function(hook, ...)
    if Hooks.CustomHooks[hook] then
        Hooks.CustomHooks[hook](...)
    else
        GELog('No hook named: %s', hook)
    end
end