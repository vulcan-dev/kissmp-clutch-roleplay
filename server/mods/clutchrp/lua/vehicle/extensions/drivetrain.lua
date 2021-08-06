local M = {}

M.torque = 0
M.gear = 0
M.rpm = 0
M.torqueTransmission = 0
M.brake = 0
M.throttle = 0
M.fuelLeakRate = 0 -- L/sec
M.fuelUsage = 0
M.engineLoad = 0
M.engineDisabled = true
M.fuel = math.random(20, 100)
M.fuelCapacity = 100
M.shifterMode = 0
M.shifterPosition = 0
M.wheelCount = 0
M.avgAV = 0
M.engineAV = 0

M.esc = {
    update = nop,
    updateGFX = nop,
    toggleESCMode = nop,
    getCarData = nop,
    escPulse = 0
}

local proxyEngine = nil
local proxyGearbox = nil
local avToRPM = 9.549296596425384

local function updateProxy()
    proxyEngine = powertrain.getDevice("mainEngine")
    proxyGearbox = powertrain.getDevice("gearbox")

    M.torque = proxyEngine and proxyEngine.outputTorque1 or 0
    M.gear = proxyGearbox and proxyGearbox.gearIndex or 0
    M.rpm = proxyEngine and proxyEngine.outputAV1 * avToRPM or 0
    M.torqueTransmission = proxyGearbox and proxyGearbox.outputTorque1 or 0
    M.throttle = electrics.values.throttle or 0
    M.engineDisabled = proxyEngine and proxyEngine.isDisabled or false
    M.engineLoad = proxyEngine and proxyEngine.engineLoad or 0

    M.shifterMode = 2
    M.engineAV = proxyEngine and proxyEngine.outputAV1

    electrics.values.gear_M = proxyGearbox and proxyGearbox.gearIndex
end

local function setShifterMode(mode)
    -- shifterMode = 0 : realistic (manual)
    -- shifterMode = 1 : realistic (manual autoclutch)
    -- shifterMode = 2 : arcade
    -- shifterMode = 3 : realistic (automatic)

    log('D', 'clutchrp.drivetrain', 'mode = ' .. tostring(mode))
    controller.mainController.setGearboxMode('realistic')
end

local function shiftToGear(gear)
    controller.mainController.shiftToGearIndex(gear)
end

local function init()
    obj:queueGameEngineLua("extensions.addModulePath('lua/ge/extensions/clutchrp')")
    obj:queueGameEngineLua("extensions.loadModulesInDirectory('lua/ge/extensions/clutchrp')")

    M.engineDisabled = true
    M.fuel = math.random(20, 100)
    M.fuelCapacity = 100
    M.shifterMode = 0
end

M.reset = init
M.init = init
M.updateGFX = updateProxy
M.shiftToGear = shiftToGear
M.setShifterMode = setShifterMode

return M