local M = {}

M.Show = false

local UI = ui_imgui

local WindowSize = {
    x = 200,
    y = 400
}

local Buttons = {
    ['Refuel'] = '/refuel',
    ['Hands Up'] = '/hu',
    ['Repair'] = '/repair',
    ['Rob'] = '/rob',
    ['Cuff'] = '/cuff',
    ['PD'] = '/pd',
    ['Drag'] = '/drag',
    ['Set Home'] = '/set_home',
    ['Bank'] = '/bank',
    ['Home'] = '/home',
    ['Get Roles'] = '/get_roles',
    ['_911'] = '/911',
    ['_Transfer'] = '/transfer',
    ['_SendLocation'] = '/send_gps'
}

local SelectedUserID = 0

local function CreatePopup(title, drawPopup, windowSize)
    UI.SetNextWindowBgAlpha(1.0)
    UI.SetNextWindowSize(UI.ImVec2(windowSize.x, 20))
    UI.SetNextWindowPos(UI.ImVec2(Clutch.Viewport.Size.x / 2 - windowSize.x / 2, 10))
    UI.PushStyleVar1(UI.StyleVar_WindowRounding, 0)
    if UI.Begin(title, UI.BoolPtr(true), Clutch.Style_Main) then
        UI.SetCursorPosX((windowSize.x - UI.CalcTextSize(title).x) * 0.5)
        UI.Text(title)
        UI.End()
    end

    UI.SetNextWindowBgAlpha(0.5)
    UI.SetNextWindowPos(UI.ImVec2(Clutch.Viewport.Size.x / 2 - windowSize.x / 2, windowSize.y - windowSize.y + 40))
    UI.SetNextWindowSize(UI.ImVec2(windowSize.x, windowSize.y))
    drawPopup()

    UI.PopStyleVar(1)
end

local Functions = {}
local Count = 0
local lastActive = ''

--[[ Set Window Size Based off of Buttons ]]--

local function _Draw(dt)
    if not Clutch.GUI.isWindowVisible('Roleplay') then return end

    UI.PushStyleVar1(UI.StyleVar_WindowRounding, 0) -- this is for both windows
    UI.SetNextWindowSize(UI.ImVec2(WindowSize.x, 30))
    UI.SetNextWindowPos(UI.ImVec2(Clutch.Viewport.Size.x - WindowSize.x, Clutch.Viewport.Size.y / 2 - WindowSize.y / 2 - 30))
    if UI.Begin('Roleplay Menu', UI.BoolPtr(true), Clutch.Style_Main) then
        UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Roleplay Menu').x) * 0.5)
        UI.Text('Roleplay Menu')
        UI.End()
    end

    UI.SetNextWindowSize(UI.ImVec2(WindowSize.x, WindowSize.y))
    UI.SetNextWindowPos(UI.ImVec2(Clutch.Viewport.Size.x - WindowSize.x, Clutch.Viewport.Size.y / 2 - WindowSize.y / 2))
    UI.SetNextWindowBgAlpha(0.5)
    if UI.Begin('Roleplay', UI.BoolPtr(true), Clutch.Style_Main) then
        UI.Columns(2, 'C_RoleplayButtons', false)

        --[[ Buttons Begin ]]--
        for name, command in pairs(Buttons) do
            if UI.Button(name, Clutch.ButtonSize) then
                SelectedUserID = 0
                if name:sub(1, 1) == '_' then
                    if lastActive == name then
                        Functions[lastActive].active = false
                        lastActive = ''
                    else
                        lastActive = name
                        Functions[lastActive].active = true
                    end
                else
                    if lastActive then lastActive = '' end
                    Clutch.Execute(command)
                end
            end

            Count = Count + 1
            if Count == 2 then
                UI.NextColumn()
                Count = 0
            end
        end
        --[[ Buttons End ]]--

        UI.NextColumn()

        if lastActive and Functions[lastActive] and Functions[lastActive].active then
            Functions[lastActive].Draw(dt)
        end
        UI.End()
    end
end

--[[ Buffers ]]--
local buffer = UI.ArrayChar(256, '')
local sliderInt = UI.IntPtr(100)

--[[ Windows ]]--
Functions['_911'] = {
    Draw = function(dt)
        CreatePopup('Create 911 Call', function()
            if UI.Begin('CM_Create911', UI.BoolPtr(true), Clutch.Style_Main) then
                UI.PushItemWidth(480)
                UI.SetCursorPosX(60)
                UI.SetCursorPosY(13)

                if UI.InputText('##I_PoliceCall', buffer, nil, UI.InputTextFlags_EnterReturnsTrue) then
                    Clutch.Execute('/911 ' .. ffi.string(buffer))
                    buffer = UI.ArrayChar(256, '')
                end

                UI.PopItemWidth()

                UI.End()
            end
        end, UI.ImVec2(600, 50))
    end,

    active = false
}

Functions['_Transfer'] = {
    Draw = function(dt)
        CreatePopup('Bank Transfer', function()
            if UI.Begin('CM_BankTransfer', UI.BoolPtr(true), Clutch.Style_Main) then
                UI.Columns(4, 'player_column', true)
                for id, client in pairs(network.players) do
                    UI.SetCursorPosX((UI.GetCursorPosX() + UI.GetColumnWidth() - Clutch.ButtonSize.x) - Clutch.ButtonSize.x / 4 * 0.5)
                    if UI.Button(client.name, Clutch.ButtonSize) then
                        if SelectedUserID == id then
                            SelectedUserID = 0

                        else
                            SelectedUserID = id
                        end
                    end

                    UI.NextColumn()
                end

                if SelectedUserID > 0 then
                    UI.Columns(1) -- Reset

                    UI.PushItemWidth(WindowSize.x - 200)
                    UI.SetCursorPosX(WindowSize.x - 100)
                    UI.SetCursorPosY(UI.GetCursorPosY() + 20)
                    UI.SliderInt("##sliderInt", sliderInt, 100, 2000)
                    UI.PopItemWidth()
                    UI.SetCursorPosX()
                    UI.Button('Transfer', Clutch.ButtonSize)

                    -- if UI.IsItemHovered() then
                    --     if UI.IsKeyPressed(UI.GetKeyIndex(UI.Key_LeftArrow)) then
                    --         sliderInt = UI.IntPtr(sliderInt - UI.IntPtr(5))
                    --     end
                    -- end
                end

                UI.End()
            end
        end, UI.ImVec2(550, 240))
    end,
}

Functions['_SendLocation'] = {
    Draw = function(dt)

    end,
}

M._Draw = _Draw

return M