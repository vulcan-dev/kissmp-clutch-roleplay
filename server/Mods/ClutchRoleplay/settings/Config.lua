local Config = {}

Config.reset = {}
Config.restrictActions = true

Config.disabledActions = {
    "switch_next_vehicle", -- switches focus to next vehicle
    "switch_previous_vehicle", -- switches focus to previous vehicle
    "loadHome", -- moves the vehicle to its home position
    "saveHome", -- stores current vehicle position for quick access
    "nodegrabberGrab",
    "nodegrabberRender",
    "recover_vehicle", -- rewinds vehicle position
    --"reload_vehicle", -- reloads vehicle files from disk
    --"reload_all_vehicles", -- reloads all vehicles files from disk
    --"vehicle_selector", -- opens the vehicle selection screen
    --"parts_selector", -- opens the vehicle configuration screen
    "nodegrabberStrength", -- displays nodes that can be grabbed
    "slower_motion", -- slows down time
    "faster_motion", -- speeds up time
    "toggle_slow_motion", -- slows time down or resets if back to real time
    --"dropPlayerAtCamera", -- puts the player at the camera
}

Config.reset.enabled = true -- enables or disables the ability to reset vehicles
Config.reset.timeout = 60 -- how often a vehicle can be reset, -1 for no limit
Config.reset.title = "Vehicle Reset Limiter" -- title shown when resetting is limited or disabled
Config.reset.message = "You can reset your vehicle in {secondsLeft} seconds." -- message shown when resetting is limited
Config.reset.disabledMessage = "Vehicle resetting is disabled on this server." -- message shown when resetting is completely disabled

return Config