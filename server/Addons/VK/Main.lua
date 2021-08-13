require('Addons.VK.globals')
require('Addons.VK.Server.Hooks')

--[[
    @Sky Sunny
    scenetree.findObject('clouds1').isRenderEnabled = false

    @Sky Storm
    scenetree.findObject('clouds1').baseColor = Point4F(0.2, 0.2, 0.2, 1)
    scenetree.findObject('sunsky').brightness = .2
    scenetree.findObject('ocean'):setField('position', 0, '0 0 10')

    @Create Rain
    soundObject.name = 'SFX_CRPRain'
    soundObject.scale = Point3F(100, 100, 100)
    soundObject.fileName = String('/art/sound/environment/amb_rain_medium.ogg')
    soundObject.playOnAdd = true
    soundObject.isLooping = true
    soundObject.volume = 100
    soundObject.is3D = false
    soundObject:registerObject('')

    @Particle Black Smoke
    ClassName: ParticleEmitterNode
    Emitter: BNGP_32

    @Particle Small Fire
    ClassName: ParticleEmitterNode
    Emitter: BNGP_26

    @Particle Medium Small Fire
    ClassName: ParticleEmitterNode
    Emitter: BNGP_27

    @Particle Big Fire
    ClassName: ParticleEmitterNode
    Emitter: BNGP_31
]]

local Modules = {
    Utilities = require('Addons.VK.Utilities'),
    Callbacks = require('Addons.VK.Server.Callbacks'),
}

local function Initialize()
    Modules = G_ReloadModules(Modules, 'Main.lua')

    --[[ Load Extensions ]]--
    local Extensions = Modules.Utilities.FileToJSON('Addons\\VK\\Settings\\Extensions.json')['Extensions']
    for _, extension in pairs(Extensions) do
        _Extensions[extension] = Modules.Utilities.LoadExtension(extension)
        GILog('Loaded Extension: %s', extension)
    end

    --[[ Setup Callbacks ]]--
    for name, _ in pairs(_Extensions) do
        for callbackName, callback in pairs(_Extensions[name].Callbacks) do
            Hooks.Register(callbackName, name, callback)
        end
    end

    for name, _ in pairs(Modules) do
        if Modules[name].Callbacks then
            for callbackName, callback in pairs(Modules[name].Callbacks) do
                Hooks.Register(callbackName, name, callback)
            end
        end
    end

    Hooks.Register('[Main] Initialize', 'Initialize', Initialize)
    Hooks.Reload()
end

Initialize()