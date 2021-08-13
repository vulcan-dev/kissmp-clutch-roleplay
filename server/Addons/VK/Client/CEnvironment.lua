local M = {}

require('Addons.VK.globals')

local function setPrecipitation(rain)
    return string.format([[
        rainObj = getObject("Precipitation", "rain_coverage") or getObject("Precipitation")
        if rainObj then
            rainObj.numDrops = %d
            rainObj.useWind = true
            rainObj.followCam = true
            rainObj.rotateWithCamVel = false
            rainObj.doCollision = true
            rainObj.boxWidth = 2
            rainObj.boxHeight = 10
            rainObj.dataBlock = scenetree.findObject("rain_medium")
            rainObj.useLighting = true
            rainObj.hitPlayers = true
            rainObj.hitVehicles = true
        end
    ]], rain)
end

local function createSFXRain(volume)
    G_Environment.rainVolume = volume

    return string.format([[
        if scenetree.findObject('SFX_CRPRain') then deleteObject('SFX_CRPRain') end
        SFX_CRPRain = createObject('SFXEmitter')
        SFX_CRPRain.name = 'SFX_CRPRain'
        SFX_CRPRain.scale = Point3F(100, 100, 100)
        SFX_CRPRain.fileName = String('/art/sound/environment/amb_rain_medium.ogg')
        SFX_CRPRain.playOnAdd = true
        SFX_CRPRain.isLooping = true
        SFX_CRPRain.volume = %.2f
        SFX_CRPRain.is3D = false
        SFX_CRPRain:registerObject('SFX_CRPRain')
    ]], volume)
end

local function setCloudColour(colour)
    colour.r = colour.r or 254
    colour.g = colour.g or 254
    colour.b = colour.b or 254
    colour.a = colour.a or 254

    return string.format([[
        scenetree.findObject('clouds1').baseColor = Point4F(%d/255, %d/255, %d/255, %d/255)
    ]], colour.r, colour.g, colour.b, colour.a)
end

local function setCloudCoverage(value)
    value = value or 0.200

    return string.format([[
        scenetree.findObject('clouds1').coverage = %.2f
    ]], value)
end

local function setCloudExposure(value)
    value = value or 1.3

    return string.format([[
        scenetree.findObject('clouds1').exposure = %.2f
    ]], value)
end

local function stopSFXRain()
    G_Environment.rainVolume = 0

    return [[
        deleteObject('SFX_CRPRain')
    ]]
end

local function setTime(time)
    return string.format('extensions.core_environment.setTimeOfDay({time = '..time..'})')
end

local function setWeather(client, weather)
    if weather == 'sunny' then
        for _, client in pairs(G_Clients) do
            stopSFXRain()
            client.user:sendLua(setCloudExposure())
            client.user:sendLua(setPrecipitation(0))
            client.user:sendLua(setCloudCoverage(0.2))
        end
    else if weather == 'extrasunny' then
        client.user:sendLua(stopSFXRain())
        client.user:sendLua(setCloudExposure())
        client.user:sendLua(setPrecipitation(0))
        client.user:sendLua(setCloudCoverage(0))
    else if weather == 'cloudy' then
        client.user:sendLua(setCloudCoverage(0.8))
    else if weather == 'rainy' then
        client.user:sendLua(setPrecipitation(50))
        client.user:sendLua(setCloudCoverage(6))
        client.user:sendLua(setCloudExposure(0.4))
        client.user:sendLua(createSFXRain(0.5))
    end end end end
end

local function setWind(wind)
    return G_LuaFormat(string.format([[
        local vehicle = be:getPlayerVehicle(0)
        vehicle:queueLuaCommand('obj:setWind(%d, %d, %d)')
    ]], wind.x or 0, wind.y or 0, wind.z or 0))
end

M.setPrecipitation = setPrecipitation
M.setPrecipitation = setPrecipitation
M.createSFXRain = createSFXRain
M.stopSFXRain = stopSFXRain
M.setCloudColour = setCloudColour
M.setCloudCoverage = setCloudCoverage
M.setCloudExposure = setCloudExposure
M.setWeather = setWeather
M.setTime = setTime
M.setWind = setWind

return M