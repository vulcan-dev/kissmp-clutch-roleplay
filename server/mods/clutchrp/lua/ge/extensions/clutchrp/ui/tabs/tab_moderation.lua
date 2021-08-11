local M = {}

local command  = require('clutchrp.command')

local buttonSize = command.imgui.ImVec2(120, 30) -- need to set column size

local function Draw(dt)
    if command.imgui.BeginTabItem('Moderation', command.imgui.BoolPtr(true)) then
        command.viewport = command.imgui.GetMainViewport()
        command.imgui.Columns(6, 'moderation_tab', false)
        command.imgui.SetColumnWidth(0, 140)

        --[[ Environment ]]--
        command.imgui.BeginChild1('user', command.imgui.ImVec2(140, 440), false)
        command.imgui.Separator()
        command.imgui.SetCursorPosX((140 - command.imgui.CalcTextSize('User').x) * 0.5)
        command.imgui.Text('User')
        command.imgui.Separator()
        if command.imgui.Button('Ban', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Ban User',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['ban']
            })
        else if command.imgui.Button('Unban', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Unban User',
                    size = command.imgui.ImVec2(480, 50),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['unban']
            })
        else if command.imgui.Button('Kick', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Kick User',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['kick']
            })
        else if command.imgui.Button('Warn', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Warn User',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['warn']
            })
        else if command.imgui.Button('Remove Warn', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Remove Warn',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['remove_warn']
            })
        else if command.imgui.Button('Set Rank', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Set Rank',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['set_rank']
            })
        else if command.imgui.Button('Mute', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Mute User',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['mute']
            })
        else if command.imgui.Button('Unmute', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Unmute User',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['unmute']
            })
        else if command.imgui.Button('Freeze', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Freeze User',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['freeze']
            })
        else if command.imgui.Button('Unfreeze', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Unfreeze User',
                    size = command.imgui.ImVec2(480, 110),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['unfreeze']
            })
        else if command.imgui.Button('Display Message', buttonSize) then
            command.shouldDrawCommand = not command.shouldDrawCommand
            command.Set({
                shouldDraw = command.shouldDrawCommand,
                window = {
                    title = 'Display Message',
                    size = command.imgui.ImVec2(480, 140),
                    style = command.windowStyles,
                    posTitle = command.imgui.ImVec2(command.viewport.Size.x / 2 - command.windowSize.x / 2, 20),
                    sizeTitle = command.imgui.ImVec2(command.windowSize.x, 30)
                },
                drawFunction = command.commands['display_message']
            })
        end end end end end end end end end end end
        command.imgui.EndChild()
        command.imgui.Columns(1)
        command.imgui.EndTabItem()
    end
end

M.Draw = Draw

return M