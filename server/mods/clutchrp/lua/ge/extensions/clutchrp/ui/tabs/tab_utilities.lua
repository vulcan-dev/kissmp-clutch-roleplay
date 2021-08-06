local M = {}

local command  = require('clutchrp.command')

local function Draw(dt)
    if command.imgui.BeginTabItem('Utilities', command.imgui.BoolPtr(true)) then
        M.viewport = command.imgui.GetMainViewport()
        -- command.imgui.SetCursorPosY(100)
        command.imgui.Columns(6, 'utility_tab', false)

        --[[ Environment ]]--
        command.imgui.BeginChild1('time', command.imgui.ImVec2(100, 270), true)
        command.imgui.Separator()
        command.imgui.SetCursorPosX((100 - command.imgui.CalcTextSize('Environment').x) * 0.5)
        command.imgui.Text('Environment')
        command.imgui.Separator()
        if command.imgui.Button('Stop Time', command.buttonSize) then
            command.Execute('/time_stop')
        else if command.imgui.Button('Start Time', command.buttonSize) then
            command.Execute('/time_start')
        else if command.imgui.Button('Set Time', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Time',
                    size = command.imgui.ImVec2(500, 50),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['ui_same'],
                command = 'set_time'
            })
        else if command.imgui.Button('Set Wind', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Wind',
                    size = command.imgui.ImVec2(500, 50),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['ui_same'],
                command = 'set_wind'
            })
        else if command.imgui.Button('Set Rain', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Rain',
                    size = command.imgui.ImVec2(500, 50),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['ui_same'],
                command = 'set_rain'
            })
        else if command.imgui.Button('Set Fog', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Fog',
                    size = command.imgui.ImVec2(500, 50),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['ui_same'],
                command = 'set_fog'
            })
        else if command.imgui.Button('Set Gravity', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Gravity',
                    size = command.imgui.ImVec2(500, 50),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['ui_same'],
                command = 'set_gravity'
            })
        end end end end end end end

        command.imgui.EndChild()

        --[[ Tags ]]--
        command.imgui.BeginChild1('tags', command.imgui.ImVec2(100, 100))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((100 - command.imgui.CalcTextSize('Tags').x) * 0.5)
        command.imgui.Text('Tags')
        command.imgui.Separator()
        if command.imgui.Button('Enable Tags', command.buttonSize) then
            command.Execute('/et')
        else if command.imgui.Button('Disable Tags', command.buttonSize) then
            command.Execute('/dt')
        end end

        command.imgui.EndChild()
        command.imgui.NextColumn()
        command.imgui.SetCursorPosY(37)

        --[[ Teleport ]]--
        command.imgui.BeginChild1('teleport', command.imgui.ImVec2(100, 100))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((100 - command.imgui.CalcTextSize('Teleport').x) * 0.5)
        command.imgui.Text('Teleport')
        command.imgui.Separator()
        if command.imgui.Button('Teleport To', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Teleport To',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['teleport_to'],
            })
        else if command.imgui.Button('Teleport User To', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Teleport User To',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['teleport_user_to']
            })
        end end

        command.imgui.EndChild()
        command.imgui.NextColumn()
        command.imgui.SetCursorPosY(37)

        --[[ Unnamed ]]--
        command.imgui.BeginChild1('unnamed', command.imgui.ImVec2(100, 180))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((100 - command.imgui.CalcTextSize('Unnamed').x) * 0.5)
        command.imgui.Text('Unnamed')
        command.imgui.Separator()
        if command.imgui.Button('Online Mods', command.buttonSize) then
            command.Execute('/mods')
        else if command.imgui.Button('Delete Vehicle', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Delete User Vehicle',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['delete_vehicle']
            })
        else if command.imgui.Button('Cleanup', command.buttonSize) then
            command.Execute('/cleanup')
        else if command.imgui.Button('DVA', command.buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Delete all User Vehicles',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['delete_all_user_vehicles']
            })
        end end end end

        command.imgui.EndChild()

        command.imgui.Columns(1)
        command.imgui.EndTabItem()
    end
end

M.Draw = Draw

return M