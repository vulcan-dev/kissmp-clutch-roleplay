local M = {}

local command  = require('clutchrp.command')

local function Draw(dt)
    if command.imgui.BeginTabItem('Fun', command.imgui.BoolPtr(true)) then
        if command.imgui.Button('Imitate', command.buttonSize) then
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
                drawFunction = command.commands['imitate']
            })
        end

        command.imgui.EndTabItem()
    end
end

M.Draw = Draw

return M