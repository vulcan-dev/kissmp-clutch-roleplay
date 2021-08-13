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

local function setTime(time)
    return string.format('extensions.core_environment.setTimeOfDay({time = '..time..'})')
end

local function setWind(wind)
    return G_LuaFormat(string.format([[
        local vehicle = be:getPlayerVehicle(0)
        vehicle:queueLuaCommand('obj:setWind(%d, %d, %d)')
    ]], wind.x or 0, wind.y or 0, wind.z or 0))
end

M.setPrecipitation = setPrecipitation
M.setTime = setTime
M.setWind = setWind

return M