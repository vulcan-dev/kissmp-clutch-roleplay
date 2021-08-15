local M = {}

M.Show = false
M.ShouldHold = false
M.SelectedUser = 0

local UI = ui_imgui

local WindowSize = {
    x = 800,
    y = 600
}

M.PopupSize = {
    x = 150,
    y = 30 * 9
}

local function ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

M.DefaultPopupSize = ShallowCopy(M.PopupSize)

local ButtonSize = UI.ImVec2(M.PopupSize.x, 30)

local buffer = UI.ArrayChar(128)

local playerCount = 0
local RightClick = 1
local childColour = UI.ImVec4(36/255, 41/255, 46/255, 1)

local function _Draw(dt)
    if not Clutch.GUI.isWindowVisible('Playerlist') then return end

    WindowSize.x = Clutch.Viewport.Size.x / 2
    WindowSize.y = #network.players * 50

    --[[ Top Bar ]]--
    UI.SetNextWindowPos(UI.ImVec2(Clutch.Viewport.Size.x / 2 - WindowSize.x / 2, 50))
    UI.SetNextWindowSize(UI.ImVec2(WindowSize.x, WindowSize.y))
    UI.SetNextWindowBgAlpha(0.8)
    UI.PushStyleVar2(UI.StyleVar_WindowPadding, UI.ImVec2(0.0, 10.0))
    UI.PushStyleVar1(UI.StyleVar_WindowRounding, 0.0)
    UI.PushStyleVar1(UI.StyleVar_ChildRounding, 0.0)
    if UI.Begin('Playerlist', UI.BoolPtr(true), Clutch.Style_Main) then
        -- Name | Rank | Active Player | Ping
        -- UI.SetCursorPosX((WindowSize.x - WindowSize.x - UI.CalcTextSize('Name').x) + 100)
        UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Rank').x) * 0.2)
        UI.Text('Name')

        UI.SameLine()

        UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Rank').x) * 0.4)
        UI.Text('Rank')

        UI.SameLine()

        UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Active Player').x) * 0.6)
        UI.Text('Active Player')

        UI.SameLine()

        UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Ping').x) * 0.8)
        UI.Text('Ping')

        UI.SetCursorPosY(40)
        for clientID, clientTable in pairs(network.players) do -- when user joins set the custom data
            -- playerCount = playerCount + 1

            -- if playerCount % 2 == 0 then
            --     childColour = UI.ImVec4(36/255, 41/255, 46/255, 0.5)
            -- else
            --     childColour = UI.ImVec4(36/255, 41/255, 46/255, 1)
            -- end

            UI.PushStyleColor2(UI.Col_ChildBg, childColour)
            UI.PushStyleVar2(UI.StyleVar_FramePadding, UI.ImVec2(0.0, 0.0))
            UI.BeginChild1('##'..clientID, UI.ImVec2(WindowSize.x, 40), false)

            UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize(clientTable.name).x) * 0.2)
            UI.SetCursorPosY(10)
            UI.Text(clientTable.name)

            UI.SameLine()

            UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize(clientTable.rank).x) * 0.4)
            UI.Text(clientTable.rank)

            UI.SameLine()

            UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Active Player').x) * 0.6)
            UI.Text('Active Player')

            UI.SameLine()

            UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Ping').x) * 0.8)
            UI.Text('Ping')

            UI.EndChild()

            if UI.IsItemHovered() then
                if UI.IsItemClicked(0) then
                    M.SelectedUser = 0
                end

                if UI.IsItemClicked(RightClick) then
                    if M.SelectedUser ~= clientID then
                        M.SelectedUser = clientID
                    else
                        M.SelectedUser = 0
                    end
                end
            end

            UI.PopStyleColor(1)
            UI.PopStyleVar(1)

            -- if playerCount == #network.connection then
            --     playerCount = 0
            -- end
        end
    end

    if M.SelectedUser > 0 then
        UI.SetNextWindowPos(UI.ImVec2(Clutch.Viewport.Size.x / 2 - M.PopupSize.x / 2, WindowSize.y + 55))
        UI.SetNextWindowSize(UI.ImVec2(M.PopupSize.x, M.PopupSize.y))
        UI.SetNextWindowBgAlpha(1)
        UI.PushStyleVar2(UI.StyleVar_WindowPadding, UI.ImVec2(0.0, 0.0))
        UI.PushStyleVar1(UI.StyleVar_WindowBorderSize, 0)
        if UI.Begin('PlayerlistDropdown', UI.BoolPtr(true), Clutch.Style_Main) then
            --[[ Quick Action Title ]]--
            local padding = UI.GetStyle().FramePadding

            local rectMin = UI.GetCursorScreenPos()
            rectMin.x = rectMin.x - padding.x
            rectMin.y = rectMin.y - padding.y
          
            local rectMax = UI.GetCursorScreenPos()
            rectMax.x = rectMax.x + M.PopupSize.x + padding.x

            UI.ImDrawList_AddRectFilled(UI.GetWindowDrawList(), rectMin, UI.ImVec2(rectMax.x, rectMax.y + 30 + padding.y), UI.GetColorU322(UI.ImVec4(1, 0, 0, 1)))

            UI.SetCursorPosX((M.PopupSize.x - UI.CalcTextSize('Quick Actions').x) * 0.5)
            UI.SetCursorPosY(5)
            UI.Text('Quick Actions')

            rectMax.y = rectMax.y + M.PopupSize.y + padding.y

            --[[ Actions ]]--
            UI.PushStyleVar2(UI.StyleVar_ItemSpacing, UI.ImVec2(0, 0))
            UI.PushStyleVar1(UI.StyleVar_FrameRounding, 0)

            UI.SetCursorPosY(30)
            UI.Columns(1, 'C_QuickActions', true)
            if UI.Button('Kick', ButtonSize) then
                if M.DefaultPopupSize.x ~= M.PopupSize.x then
                    M.PopupSize = ShallowCopy(M.DefaultPopupSize)
                    M.ShouldHold = false
                else
                    UI.SetCursorPosX(300)
                    UI.SetCursorPosY(50)
                    UI.Text('fesnunfesunfnseunfesbnuiesbuisbrui')

                    M.ShouldHold = true
                    M.PopupSize.x = M.PopupSize.x + 300
                end
            end
            UI.NextColumn()
            UI.Button('Freeze', ButtonSize)
            UI.NextColumn()
            UI.Button('Unfreeze', ButtonSize)
            UI.NextColumn()
            UI.Button('Teleport To', ButtonSize)
            UI.NextColumn()
            UI.Button('Bring', ButtonSize)
            UI.NextColumn()
            UI.Button('Return', ButtonSize)
            UI.NextColumn()
            UI.Button('Mute', ButtonSize)
            UI.NextColumn()
            UI.Button('Unmute', ButtonSize)
            UI.NextColumn()

            UI.PopStyleVar(2)

            UI.End()
        end

        UI.PopStyleVar(2)
    end

    UI.PopStyleVar(3)
end

M._Draw = _Draw

return M

-- UI.SetCursorPosX((WindowSize.x - UI.CalcTextSize('Name').x) * 0.5)

--[[ References ]]--
--[[
    Separator()
    M.ImDrawList_AddText1(ImDrawList_ctx, ImVec2_pos, ImU32_col, string_text_begin, string_text_end)
    M.ImDrawList_AddText2(ImDrawList_ctx, ImFont_font, float_font_size, ImVec2_pos, ImU32_col, string_text_begin, string_text_end, float_wrap_width, ImVec4_cpu_fine_clip_rect)
    M.TextColored(ImVec4_col, string_fmt, ...)
]]