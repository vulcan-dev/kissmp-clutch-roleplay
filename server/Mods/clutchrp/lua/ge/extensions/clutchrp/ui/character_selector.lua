local M = {}

local imgui = ui_imgui

M.shouldDraw = false

local viewport = imgui.GetMainViewport()
local windowSize = {
    x = 700,
    y = 500
}

local command  = require('clutchrp.command')

M.buttonSizeSelect = imgui.ImVec2(140, 30)

local windowStyles = bit.bor(
    imgui.WindowFlags_NoScrollbar, imgui.WindowFlags_NoDocking, imgui.WindowFlags_NoTitleBar, 
    imgui.WindowFlags_NoResize, imgui.WindowFlags_NoMove, imgui.WindowFlags_NoScrollWithMouse, imgui.WindowFlags_NoCollapse
)

local function SetupStyle()
    --[[ Window Styles ]]--
    imgui.PushStyleVar1(imgui.StyleVar_WindowPadding, 0)

    --[[ Window Colours ]]--
    imgui.PushStyleColor2(imgui.Col_Border, imgui.ImVec4(0, 0, 0, 0))
end

local c = {
    ['David Adams'] = {
        money = 1000,
        roles = {'Police', 'EMS'},
        age = 37,
        full_name = 'David Adams',
        first_name = 'David',
        second_name = 'Adams'
    },
    ['ABC'] = {
        money = 1000,
        roles = {'Police', 'EMS'},
        age = 31,
        full_name = 'Davwid dAddams',
        first_name = 'Davsid',
        second_name = 'Addaams'
    },
    ['David Aams'] = {
        money = 1000,
        roles = {'Police', 'EMS'},
        age = 37,
        full_name = 'da daw',
        first_name = 'w',
        second_name = 'Adsams'
    },
    ['Did Adms'] = {
        money = 1000,
        roles = {'Police', 'EMS'},
        age = 37,
        full_name = 'David daws',
        first_name = 'Davdwid',
        second_name = 'a'
    }
}

local name = imgui.ArrayChar(32, 'Name')
local age = imgui.ArrayChar(4, 'Age')

local function Draw(dt)
    viewport = imgui.GetMainViewport()

    --[[ Title ]]--
    imgui.PushStyleVar1(imgui.StyleVar_WindowRounding, 0) -- this is for both windows
    imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, 30))
    imgui.SetNextWindowBgAlpha(0.5)
    imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x / 2 - windowSize.x / 2, viewport.Size.y / 2 - windowSize.y / 2 - 30))
    if imgui.Begin('ClutchRP Moderation Title', imgui.BoolPtr(true), windowStyles) then
        imgui.SetCursorPosX((windowSize.x - imgui.CalcTextSize('Moderation').x) * 0.5)
        imgui.Text('Character Selector')
        imgui.End()
    end

    SetupStyle()

    imgui.SetNextWindowSize(imgui.ImVec2(windowSize.x, windowSize.y))
    imgui.SetNextWindowBgAlpha(1.0)
    imgui.SetNextWindowPos(imgui.ImVec2(viewport.Size.x / 2 - windowSize.x / 2, viewport.Size.y / 2 - windowSize.y / 2))
    if imgui.Begin('Moderation Menu', imgui.BoolPtr(true), windowStyles) then
        imgui.Columns(4, 'why_do_i_do_this_to_myself_;-;', false)
        for name, character in pairs(_Characters) do
            imgui.SetCursorPosX((imgui.GetCursorPosX() + imgui.GetColumnWidth() - M.buttonSizeSelect.x) - M.buttonSizeSelect.x / 2 * 0.35)
            if imgui.Button(character.full_name, M.buttonSizeSelect) then
                command.Execute('/select_character ' .. character.full_name)
            end

            imgui.NextColumn()
        end

        imgui.Columns(1)
        imgui.SetCursorPosY(100)
        imgui.BeginChild1('create')
        imgui.PushItemWidth(250)
        imgui.SetCursorPosX(windowSize.x / 2 - 250 / 2)
        imgui.InputText('##name', name, nil)
        imgui.SetCursorPosX(windowSize.x / 2 - 250 / 2)
        imgui.InputText('##age', age)
        imgui.PopItemWidth()
        imgui.SetCursorPosX(windowSize.x / 2 - 100)
        if imgui.Button('CREATE', imgui.ImVec2(200, 30)) then
            local tbl = {}
            for val in string.gmatch(ffi.string(name), "[^%s]+") do
                table.insert(tbl, val)
            end
            local firstName = tbl[1] or nil
            local secondName = tbl[2] or nil
            command.Execute('/create_character ' .. firstName .. ' ' .. secondName .. ' ' .. ffi.string(age))
            -- server can check for valid shiet
        end
        imgui.EndChild()

        imgui.End()
    end

    imgui.PopStyleVar(1)
    imgui.SetNextWindowBgAlpha(1.0)
end

M.Draw = Draw

return M