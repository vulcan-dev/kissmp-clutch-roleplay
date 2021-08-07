local M = {}

local command  = require('clutchrp.command')

local buttonSize = command.imgui.ImVec2(120, 30)

local function Draw(dt)
    if command.imgui.BeginTabItem('Utilities', command.imgui.BoolPtr(true)) then
        M.viewport = command.imgui.GetMainViewport()
        -- command.imgui.SetCursorPosY(100)
        command.imgui.Columns(4, 'utility_tab', false)
        command.imgui.SetColumnWidth(0, 180)

        --[[ Environment ]]--
        command.imgui.BeginChild1('time', command.imgui.ImVec2(140, 270), true)
        command.imgui.Separator()
        command.imgui.SetCursorPosX((140 - command.imgui.CalcTextSize('Environment').x) * 0.5)
        command.imgui.Text('Environment')
        command.imgui.Separator()
        if command.imgui.Button('Stop Time', buttonSize) then
            command.Execute('/time_stop')
        else if command.imgui.Button('Start Time', buttonSize) then
            command.Execute('/time_play')
        else if command.imgui.Button('Set Time', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Time',
                    size = command.imgui.ImVec2(100, 80),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['set_time']
            })
        else if command.imgui.Button('Set Wind', buttonSize) then
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
        else if command.imgui.Button('Set Rain', buttonSize) then
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
        else if command.imgui.Button('Set Fog', buttonSize) then
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
        else if command.imgui.Button('Set Gravity', buttonSize) then
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
        command.imgui.BeginChild1('tags', command.imgui.ImVec2(120, 100))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((120 - command.imgui.CalcTextSize('Tags').x) * 0.5)
        command.imgui.Text('Tags')
        command.imgui.Separator()
        if command.imgui.Button('Enable Tags', buttonSize) then
            command.Execute('/et')
        else if command.imgui.Button('Disable Tags', buttonSize) then
            command.Execute('/dt')
        end end

        command.imgui.EndChild()
        command.imgui.NextColumn()
        command.imgui.SetCursorPosY(37)

        --[[ Teleport ]]--
        command.imgui.BeginChild1('teleport', command.imgui.ImVec2(120, 100))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((120 - command.imgui.CalcTextSize('Teleport').x) * 0.5)
        command.imgui.Text('Teleport')
        command.imgui.Separator()
        if command.imgui.Button('Teleport To', buttonSize) then
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
        else if command.imgui.Button('Teleport User To', buttonSize) then
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
        command.imgui.BeginChild1('unnamed', command.imgui.ImVec2(120, 180))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((120 - command.imgui.CalcTextSize('Unnamed').x) * 0.5)
        command.imgui.Text('Unnamed')
        command.imgui.Separator()
        if command.imgui.Button('Online Mods', buttonSize) then
            command.Execute('/mods')
        else if command.imgui.Button('Delete Vehicle', buttonSize) then
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
        else if command.imgui.Button('Cleanup', buttonSize) then
            command.Execute('/cleanup')
        else if command.imgui.Button('DVA', buttonSize) then
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

        -- need a get_roles

        command.imgui.EndChild()
        command.imgui.NextColumn()
        command.imgui.SetCursorPosY(37)

        --[[ Roles ]]--
        command.imgui.BeginChild1('roles', command.imgui.ImVec2(120, 180))
        command.imgui.Separator()
        command.imgui.SetCursorPosX((120 - command.imgui.CalcTextSize('Roles').x) * 0.5)
        command.imgui.Text('Roles')
        command.imgui.Separator()
        if command.imgui.Button('Get Roles', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Get User Roles',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['get_roles']
            })
        else if command.imgui.Button('Add Role', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Add User Role',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['add_role']
            })
        else if command.imgui.Button('Remove Role', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Remove User Role',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(M.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['remove_role']
            })
        end end end

        command.imgui.EndChild()
        command.imgui.Columns(1)
        command.imgui.EndTabItem()
    end
end

M.Draw = Draw

return M