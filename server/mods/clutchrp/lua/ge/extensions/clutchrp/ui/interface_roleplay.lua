local M = {}

local imgui = ui_imgui
local command  = require('clutchrp.command')

M.shouldDraw = false

local viewport = imgui.GetMainViewport()
local windowSize = {
    x = 200,
    y = 600
}

local buttonSize = imgui.ImVec2(100, 30)
local windowStyles = bit.bor(
    imgui.WindowFlags_NoScrollbar, imgui.WindowFlags_NoDocking, imgui.WindowFlags_NoTitleBar, 
    imgui.WindowFlags_NoResize, imgui.WindowFlags_NoMove, imgui.WindowFlags_NoScrollWithMouse, imgui.WindowFlags_NoCollapse
)

local function copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
    return res
end

local function SetupStyle()
    --[[ Window Styles ]]--
    imgui.PushStyleVar1(imgui.StyleVar_WindowPadding, 0)

    --[[ Window Colours ]]--
    imgui.PushStyleColor2(imgui.Col_Border, imgui.ImVec4(0, 0, 0, 0))

    imgui.SetNextWindowBgAlpha(0.5)
end

local function PopStyle()
    imgui.PopStyleVar(1)
    imgui.SetNextWindowBgAlpha(1)
end

-- Note: For moderation, I can set a global variable. It'll make it more secure even though it doesn't need to be because I use chat to execute the command

local function Draw(dt)
    if M.shouldDraw then
        viewport = imgui.GetMainViewport()

        --[[ Title ]]--
        imgui.PushStyleVar1(imgui.StyleVar_WindowRounding, 0) -- this is for both windows
        imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, 30))
        imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x - windowSize.x, viewport.Size.y / 2 - windowSize.y / 2 - 30))
        if imgui.Begin('ClutchRP Interface Title', imgui.BoolPtr(true), windowStyles) then
            imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize('Roleplay Menu').x) * 0.5)
            imgui.Text('Roleplay Menu')
            imgui.End()
        end

        imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, windowSize.y))
        imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x - windowSize.x, viewport.Size.y / 2 - windowSize.y / 2))

        SetupStyle()

        --[[ Roleplay Window ]]--
        if imgui.Begin('ClutchRP Interface', imgui.BoolPtr(true), windowStyles) then
            imgui.Columns(2, 'button_column', false)
            if imgui.Button('Refuel', buttonSize) then
                command.Execute('/refuel')
            else if imgui.Button('Hands Up', buttonSize) then
                command.Execute('/hu')
            end end

            imgui.NextColumn()

            if imgui.Button('Repair', buttonSize) then
                command.Execute('/repair')
            else if imgui.Button('Rob', buttonSize) then
                command.Execute('/rob')
            end end

            imgui.NextColumn()

            if imgui.Button('Cuff', buttonSize) then
                command.Execute('/cuff')
            else if imgui.Button('Teleport PD', buttonSize) then
                command.Execute('/pd')
            end end

            imgui.NextColumn()

            if imgui.Button('Drag', buttonSize) then
                command.Execute('/drag')
            else if imgui.Button('911', buttonSize) then
                M.shouldDrawCommand = not M.shouldDrawCommand
                command.Set({
                    shouldDraw = not M.shouldDrawCommand,
                    window = {
                        title = 'Create Call',
                        size = imgui.ImVec2(500, 50),
                        style = windowStyles,
                    },
                    drawFunction = command.commands['911']
                })
            end end

            imgui.NextColumn()

            if imgui.Button('Set Home', buttonSize) then
                command.Execute('/set_home')
            else if imgui.Button('Bank', buttonSize) then
                command.Execute('/bank')
            end end

            imgui.NextColumn()

            if imgui.Button('Home', buttonSize) then
                command.Execute('/home')
            else if imgui.Button('Get Roles', buttonSize) then
                M.shouldDrawCommand = not M.shouldDrawCommand
                command.Set({
                    shouldDraw = not M.shouldDrawCommand,
                    window = {
                        title = 'Get Roles',
                        size = imgui.ImVec2(500, 110),
                        style = windowStyles,
                    },
                    drawFunction = command.commands['get_roles']
                })
            end end

            if imgui.Button('Transfer', buttonSize) then
                M.shouldDrawCommand = not M.shouldDrawCommand
                command.Set({
                    shouldDraw = not M.shouldDrawCommand,
                    window = {
                        title = 'Bank Transfer',
                        size = imgui.ImVec2(500, 140),
                        style = windowStyles,
                    },
                    drawFunction = command.commands['transfer']
                })
            end

            PopStyle()
            imgui.End()
        end
    end
end

M.Draw = Draw

return M