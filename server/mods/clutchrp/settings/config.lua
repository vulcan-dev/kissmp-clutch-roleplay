--[[
Created by vJoeyz#5115 (Uncle Joey)
Installed on 2Fast Racing Servers
Please do not redistribute
]]--

local config = {}
config.reset = {}
config.motd = {}
config.timesync = {}
config.weathersync = {}

config.messageDuration = 6000 -- global toast message duration in ms

config.restrictMenu = false -- enables or disables (side-)menu for mods, spawning vehicles, tuning, environment, trackbuilder and replay

config.restrictActions = true -- enables or disables restricting actions globally (see below)
config.disabledActions = {
    "switch_next_vehicle", -- switches focus to next vehicle
    "switch_previous_vehicle", -- switches focus to previous vehicle
    "loadHome", -- moves the vehicle to its home position
    "saveHome", -- stores current vehicle position for quick access
    --"recover_vehicle", -- rewinds vehicle position
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

config.reset.enabled = true -- enables or disables the ability to reset vehicles
config.reset.timeout = 60 -- how often a vehicle can be reset, -1 for no limit
config.reset.title = "Vehicle Reset Limiter" -- title shown when resetting is limited or disabled
config.reset.message = "You can reset your vehicle in {secondsLeft} seconds." -- message shown when resetting is limited
config.reset.disabledMessage = "Vehicle resetting is disabled on this server." -- message shown when resetting is completely disabled

config.motd.enabled = true -- enables or disables the motd
config.motd.type = "htmlOnly" -- htmlOnly: simple (large) motd || selectableVehicle: motd with the ability to select a vehicle
config.motd.title = "Welcome to Clutch Roleplay Community!"
config.motd.description = [[
    [center][img]uj_base/logo.jpeg[/img][/center]
    [h2]Introduction[/h2]
    Thank you for choosing us! We are always looking for active moderators so if you're up for it do /discord and ask there, one of the staff members will answer you.
    [br]
	[h2]Rules[/h2]
    [list]
        [*]1. No Foul Language.
        [*]2. No Racial, Political or Sexual Talk.
		[*]3. No Inapproperate Usernames.
        [*]4. No Negative/Toxic Behaviour.
		[*]5. Do Not Spam Chat.
		[*]7. Do Not Share Links.
        [*]8. Do Not Ram People.
		[*]9. Do No Spawn Abuse.
		[*]11. No Cop-Baiting.
		[*]12. No Metagaming.
		[*]13. No VDM.
        [*]14. No FailRP
        [*]15. No Driving Unrealistically
        [*]16. Must read rules
    [/list]
    [br]
]] -- all bbcodes can be found in README.md

config.timesync.enabled = false -- enables or disables in-game time syncing to real world time
config.timesync.offsetHours = 0 -- 0 for utc, can be positive (+) or negative (-)
config.timesync.realtime = false -- whether in-game time should be actively synced with real world time (only works when timesync.enabled = true)

-- NOTE: not all weather settings work on all maps
config.weathersync.enabled = true -- enables or disables in-game weather syncing
config.weathersync.cloudCover = 20 -- 0-100 (0 = no clouds; 100 = very cloudy)
config.weathersync.windSpeed = 1 -- 0-10 (0 = no wind; 10 = very windy) -- affects clouds and rain
config.weathersync.rainDrops = 0 -- 0-100 (0 = no rain; 100 = very rainy)
config.weathersync.rainIsSnow = 0 -- set to true to enable snow
config.weathersync.fogDensity = 9 -- 0-100 (0 = no fog; 100 = very foggy)
config.weathersync.gravity = -9.81 -- -9.81 = earth

return config
